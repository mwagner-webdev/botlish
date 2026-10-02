; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 7715  (per function: 68 461 461 81 81 357 412 412 279 279 81 496 430 585 1069 352 783 215 488 325)
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
     b27:	mov    QWORD PTR [rsp+0x38],r14
     b2c:	mov    r13,rdi
     b2f:	mov    QWORD PTR [rsp],rsi
     b33:	mov    r12,rsi
     b36:	mov    QWORD PTR [rsp+0x8],rdx
     b3b:	mov    rbx,rdx
     b3e:	mov    rsi,r12
     b41:	mov    rdi,r13
     b44:	call   b49 <botlish_fn_11+0x39>
			b45: R_X86_64_PLT32	rt_str_len-0x4
     b49:	mov    rcx,rbx
     b4c:	and    rcx,rax
     b4f:	mov    rdx,rax
     b52:	test   rcx,0x1
     b59:	jne    b7f <botlish_fn_11+0x6f>
     b5f:	mov    rsi,rbx
     b62:	mov    rdi,r13
     b65:	call   b6a <botlish_fn_11+0x5a>
			b66: R_X86_64_PLT32	rt_int_cmp-0x4
     b6a:	mov    ecx,0x2
     b6f:	test   rax,rax
     b72:	cmovge rcx,QWORD PTR [rip+0x106]        # c80 <botlish_fn_11+0x170>
     b7a:	jmp    b92 <botlish_fn_11+0x82>
     b7f:	mov    ecx,0x2
     b84:	mov    rax,rbx
     b87:	cmp    rax,rdx
     b8a:	cmovge rcx,QWORD PTR [rip+0xee]        # c80 <botlish_fn_11+0x170>
     b92:	cmp    rcx,0x6
     b96:	je     c50 <botlish_fn_11+0x140>
     b9c:	mov    QWORD PTR [rsp+0x10],0x3
     ba5:	mov    rdx,rbx
     ba8:	test   rdx,0x1
     baf:	je     bcd <botlish_fn_11+0xbd>
     bb5:	mov    rdx,rbx
     bb8:	mov    rcx,rdx
     bbb:	add    rcx,0x2
     bbf:	mov    r14,rcx
     bc2:	seto   al
     bc5:	test   al,al
     bc7:	je     be0 <botlish_fn_11+0xd0>
     bcd:	mov    edx,0x3
     bd2:	mov    rsi,rbx
     bd5:	mov    rdi,r13
     bd8:	call   bdd <botlish_fn_11+0xcd>
			bd9: R_X86_64_PLT32	rt_int_add-0x4
     bdd:	mov    r14,rax
     be0:	mov    rcx,r14
     be3:	mov    rdx,rbx
     be6:	mov    rsi,r12
     be9:	mov    rdi,r13
     bec:	call   bf1 <botlish_fn_11+0xe1>
			bed: R_X86_64_PLT32	rt_str_region_check-0x4
     bf1:	test   rax,rax
     bf4:	jne    c1d <botlish_fn_11+0x10d>
     bfa:	xor    rdx,rdx
     bfd:	mov    rax,rdx
     c00:	mov    rbx,QWORD PTR [rsp+0x20]
     c05:	mov    r12,QWORD PTR [rsp+0x28]
     c0a:	mov    r13,QWORD PTR [rsp+0x30]
     c0f:	mov    r14,QWORD PTR [rsp+0x38]
     c14:	add    rsp,0x40
     c18:	mov    rsp,rbp
     c1b:	pop    rbp
     c1c:	ret
     c1d:	mov    rcx,r14
     c20:	mov    rdx,rbx
     c23:	mov    rsi,r12
     c26:	mov    rdi,r13
     c29:	call   c2e <botlish_fn_11+0x11e>
			c2a: R_X86_64_PLT32	rt_str_slice_short-0x4
     c2e:	mov    edx,0x1
     c33:	mov    rbx,QWORD PTR [rsp+0x20]
     c38:	mov    r12,QWORD PTR [rsp+0x28]
     c3d:	mov    r13,QWORD PTR [rsp+0x30]
     c42:	mov    r14,QWORD PTR [rsp+0x38]
     c47:	add    rsp,0x40
     c4b:	mov    rsp,rbp
     c4e:	pop    rbp
     c4f:	ret
     c50:	mov    rax,0xffffffffffffffff
     c57:	mov    edx,0x1
     c5c:	mov    rbx,QWORD PTR [rsp+0x20]
     c61:	mov    r12,QWORD PTR [rsp+0x28]
     c66:	mov    r13,QWORD PTR [rsp+0x30]
     c6b:	mov    r14,QWORD PTR [rsp+0x38]
     c70:	add    rsp,0x40
     c74:	mov    rsp,rbp
     c77:	pop    rbp
     c78:	ret
     c79:	add    BYTE PTR [rax],al
     c7b:	add    BYTE PTR [rax],al
     c7d:	add    BYTE PTR [rax],al
     c7f:	add    BYTE PTR [rsi],al
     c81:	add    BYTE PTR [rax],al
     c83:	add    BYTE PTR [rax],al
     c85:	add    BYTE PTR [rax],al
	...

0000000000000c88 <botlish_entry_11: peek<str, int>>:
     c88:	push   rbp
     c89:	mov    rbp,rsp
     c8c:	sub    rsp,0x10
     c90:	mov    QWORD PTR [rsp],r12
     c94:	mov    QWORD PTR [rsp+0x8],r15
     c99:	mov    r15,rdi
     c9c:	mov    rsi,QWORD PTR [rdx]
     c9f:	mov    rdx,QWORD PTR [rdx+0x8]
     ca3:	call   ca8 <botlish_entry_11+0x20>
			ca4: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
     ca8:	mov    r12,rdx
     cab:	mov    r10,QWORD PTR [rip+0x0]        # cb2 <botlish_entry_11+0x2a>
			cae: R_X86_64_GOTPCREL	rt_short_to_str-0x4
     cb2:	mov    rsi,rax
     cb5:	mov    rdi,r15
     cb8:	call   r10
     cbb:	mov    rcx,rax
     cbe:	xor    rax,rax
     cc1:	mov    rdx,r12
     cc4:	test   rdx,rdx
     cc7:	cmovne rax,rcx
     ccb:	mov    r12,QWORD PTR [rsp]
     ccf:	mov    r15,QWORD PTR [rsp+0x8]
     cd4:	add    rsp,0x10
     cd8:	mov    rsp,rbp
     cdb:	pop    rbp
     cdc:	ret
     cdd:	add    BYTE PTR [rax],al
	...

0000000000000ce0 <botlish_fn_12: peek<str, int>>:
     ce0:	push   rbp
     ce1:	mov    rbp,rsp
     ce4:	sub    rsp,0x50
     ce8:	mov    QWORD PTR [rsp+0x20],rbx
     ced:	mov    QWORD PTR [rsp+0x28],r12
     cf2:	mov    QWORD PTR [rsp+0x30],r13
     cf7:	mov    QWORD PTR [rsp+0x38],r14
     cfc:	mov    QWORD PTR [rsp+0x40],r15
     d01:	mov    r12,rcx
     d04:	mov    r14,rdi
     d07:	mov    QWORD PTR [rsp],rsi
     d0b:	mov    r13,rsi
     d0e:	mov    QWORD PTR [rsp+0x8],rdx
     d13:	mov    rbx,rdx
     d16:	mov    rsi,r13
     d19:	mov    rdi,r14
     d1c:	call   d21 <botlish_fn_12+0x41>
			d1d: R_X86_64_PLT32	rt_str_len-0x4
     d21:	mov    rcx,rbx
     d24:	and    rcx,rax
     d27:	mov    rdx,rax
     d2a:	test   rcx,0x1
     d31:	jne    d57 <botlish_fn_12+0x77>
     d37:	mov    rsi,rbx
     d3a:	mov    rdi,r14
     d3d:	call   d42 <botlish_fn_12+0x62>
			d3e: R_X86_64_PLT32	rt_int_cmp-0x4
     d42:	mov    ecx,0x2
     d47:	test   rax,rax
     d4a:	cmovge rcx,QWORD PTR [rip+0x11e]        # e70 <botlish_fn_12+0x190>
     d52:	jmp    d67 <botlish_fn_12+0x87>
     d57:	mov    ecx,0x2
     d5c:	cmp    rbx,rdx
     d5f:	cmovge rcx,QWORD PTR [rip+0x109]        # e70 <botlish_fn_12+0x190>
     d67:	cmp    rcx,0x6
     d6b:	je     e2b <botlish_fn_12+0x14b>
     d71:	mov    QWORD PTR [rsp+0x10],0x3
     d7a:	test   rbx,0x1
     d81:	je     da4 <botlish_fn_12+0xc4>
     d87:	mov    rax,rbx
     d8a:	add    rax,0x2
     d8e:	seto   cl
     d91:	test   cl,cl
     d93:	jne    da4 <botlish_fn_12+0xc4>
     d99:	mov    rdi,r14
     d9c:	mov    r15,rax
     d9f:	jmp    dba <botlish_fn_12+0xda>
     da4:	mov    edx,0x3
     da9:	mov    rsi,rbx
     dac:	mov    rdi,r14
     daf:	call   db4 <botlish_fn_12+0xd4>
			db0: R_X86_64_PLT32	rt_int_add-0x4
     db4:	mov    r15,rax
     db7:	mov    rdi,r14
     dba:	mov    rdi,r14
     dbd:	mov    rcx,r15
     dc0:	mov    rdx,rbx
     dc3:	mov    rsi,r13
     dc6:	call   dcb <botlish_fn_12+0xeb>
			dc7: R_X86_64_PLT32	rt_str_region_check-0x4
     dcb:	test   rax,rax
     dce:	jne    df9 <botlish_fn_12+0x119>
     dd4:	xor    rax,rax
     dd7:	mov    rbx,QWORD PTR [rsp+0x20]
     ddc:	mov    r12,QWORD PTR [rsp+0x28]
     de1:	mov    r13,QWORD PTR [rsp+0x30]
     de6:	mov    r14,QWORD PTR [rsp+0x38]
     deb:	mov    r15,QWORD PTR [rsp+0x40]
     df0:	add    rsp,0x50
     df4:	mov    rsp,rbp
     df7:	pop    rbp
     df8:	ret
     df9:	mov    rcx,r12
     dfc:	mov    QWORD PTR [rcx],rbx
     dff:	mov    rax,r15
     e02:	mov    QWORD PTR [rcx+0x8],rax
     e06:	mov    rax,r13
     e09:	mov    rbx,QWORD PTR [rsp+0x20]
     e0e:	mov    r12,QWORD PTR [rsp+0x28]
     e13:	mov    r13,QWORD PTR [rsp+0x30]
     e18:	mov    r14,QWORD PTR [rsp+0x38]
     e1d:	mov    r15,QWORD PTR [rsp+0x40]
     e22:	add    rsp,0x50
     e26:	mov    rsp,rbp
     e29:	pop    rbp
     e2a:	ret
     e2b:	mov    rcx,r12
     e2e:	mov    rdi,r14
     e31:	mov    rax,QWORD PTR [rdi+0x10]
     e35:	mov    rax,QWORD PTR [rax+0x10]
     e39:	mov    QWORD PTR [rcx],0x1
     e40:	mov    QWORD PTR [rcx+0x8],0x1
     e48:	mov    rbx,QWORD PTR [rsp+0x20]
     e4d:	mov    r12,QWORD PTR [rsp+0x28]
     e52:	mov    r13,QWORD PTR [rsp+0x30]
     e57:	mov    r14,QWORD PTR [rsp+0x38]
     e5c:	mov    r15,QWORD PTR [rsp+0x40]
     e61:	add    rsp,0x50
     e65:	mov    rsp,rbp
     e68:	pop    rbp
     e69:	ret
     e6a:	add    BYTE PTR [rax],al
     e6c:	add    BYTE PTR [rax],al
     e6e:	add    BYTE PTR [rax],al
     e70:	(bad)
     e71:	add    BYTE PTR [rax],al
     e73:	add    BYTE PTR [rax],al
     e75:	add    BYTE PTR [rax],al
	...

0000000000000e78 <botlish_entry_12: peek<str, int>>:
     e78:	push   rbp
     e79:	mov    rbp,rsp
     e7c:	ud2

0000000000000e7e <botlish_fn_13: scan_unquoted<str, int, int>>:
     e7e:	push   rbp
     e7f:	mov    rbp,rsp
     e82:	sub    rsp,0x80
     e89:	mov    QWORD PTR [rsp+0x50],rbx
     e8e:	mov    QWORD PTR [rsp+0x58],r12
     e93:	mov    QWORD PTR [rsp+0x60],r13
     e98:	mov    QWORD PTR [rsp+0x68],r14
     e9d:	mov    QWORD PTR [rsp+0x70],r15
     ea2:	mov    QWORD PTR [rsp+0x30],rdi
     ea7:	mov    QWORD PTR [rsp+0x18],0x0
     eb0:	mov    QWORD PTR [rsp],rsi
     eb4:	mov    r15,rsi
     eb7:	mov    QWORD PTR [rsp+0x8],rdx
     ebc:	mov    r14,rdx
     ebf:	mov    QWORD PTR [rsp+0x10],rcx
     ec4:	lea    r13,[rsp+0x20]
     ec9:	mov    QWORD PTR [rsp+0x38],rcx
     ece:	mov    rcx,r13
     ed1:	mov    rdx,QWORD PTR [rsp+0x38]
     ed6:	mov    rsi,r15
     ed9:	mov    rdi,QWORD PTR [rsp+0x30]
     ede:	call   ee3 <botlish_fn_13+0x65>
			edf: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     ee3:	mov    rsi,rax
     ee6:	mov    QWORD PTR [rsp+0x40],rax
     eeb:	test   rax,rsi
     eee:	je     1048 <botlish_fn_13+0x1ca>
     ef4:	mov    rbx,QWORD PTR [rsp+0x20]
     ef9:	mov    r12,QWORD PTR [rsp+0x28]
     efe:	mov    rdi,QWORD PTR [rsp+0x30]
     f03:	mov    rcx,QWORD PTR [rdi+0x10]
     f07:	mov    r8,QWORD PTR [rcx+0x10]
     f0b:	mov    rcx,r12
     f0e:	mov    rdx,rbx
     f11:	mov    rsi,QWORD PTR [rsp+0x40]
     f16:	call   f1b <botlish_fn_13+0x9d>
			f17: R_X86_64_PLT32	rt_str_region_eq-0x4
     f1b:	cmp    rax,0x6
     f1f:	je     f60 <botlish_fn_13+0xe2>
     f25:	mov    rdi,QWORD PTR [rsp+0x30]
     f2a:	mov    rax,QWORD PTR [rdi+0x10]
     f2e:	mov    r8,QWORD PTR [rax+0x18]
     f32:	mov    rcx,r12
     f35:	mov    rdx,rbx
     f38:	mov    rsi,QWORD PTR [rsp+0x40]
     f3d:	call   f42 <botlish_fn_13+0xc4>
			f3e: R_X86_64_PLT32	rt_str_region_eq-0x4
     f42:	cmp    rax,0x6
     f46:	je     f56 <botlish_fn_13+0xd8>
     f4c:	mov    eax,0x2
     f51:	jmp    f65 <botlish_fn_13+0xe7>
     f56:	mov    eax,0x6
     f5b:	jmp    f65 <botlish_fn_13+0xe7>
     f60:	mov    eax,0x6
     f65:	cmp    rax,0x6
     f69:	je     faa <botlish_fn_13+0x12c>
     f6f:	mov    rdi,QWORD PTR [rsp+0x30]
     f74:	mov    rax,QWORD PTR [rdi+0x10]
     f78:	mov    r8,QWORD PTR [rax+0x20]
     f7c:	mov    rcx,r12
     f7f:	mov    rdx,rbx
     f82:	mov    rsi,QWORD PTR [rsp+0x40]
     f87:	call   f8c <botlish_fn_13+0x10e>
			f88: R_X86_64_PLT32	rt_str_region_eq-0x4
     f8c:	cmp    rax,0x6
     f90:	je     fa0 <botlish_fn_13+0x122>
     f96:	mov    eax,0x2
     f9b:	jmp    faf <botlish_fn_13+0x131>
     fa0:	mov    eax,0x6
     fa5:	jmp    faf <botlish_fn_13+0x131>
     faa:	mov    eax,0x6
     faf:	cmp    rax,0x6
     fb3:	je     102a <botlish_fn_13+0x1ac>
     fb9:	mov    QWORD PTR [rsp+0x18],0x3
     fc2:	mov    rsi,QWORD PTR [rsp+0x38]
     fc7:	test   rsi,0x1
     fce:	je     ff5 <botlish_fn_13+0x177>
     fd4:	mov    rsi,QWORD PTR [rsp+0x38]
     fd9:	mov    rax,rsi
     fdc:	add    rax,0x2
     fe0:	seto   sil
     fe4:	test   sil,sil
     fe7:	jne    ff5 <botlish_fn_13+0x177>
     fed:	mov    rsi,r15
     ff0:	jmp    100c <botlish_fn_13+0x18e>
     ff5:	mov    edx,0x3
     ffa:	mov    rsi,QWORD PTR [rsp+0x38]
     fff:	mov    rdi,QWORD PTR [rsp+0x30]
    1004:	call   1009 <botlish_fn_13+0x18b>
			1005: R_X86_64_PLT32	rt_int_add-0x4
    1009:	mov    rsi,r15
    100c:	mov    QWORD PTR [rsp],rsi
    1010:	mov    rdx,r14
    1013:	mov    QWORD PTR [rsp+0x8],rdx
    1018:	mov    QWORD PTR [rsp+0x10],rax
    101d:	mov    r15,rsi
    1020:	mov    QWORD PTR [rsp+0x38],rax
    1025:	jmp    ece <botlish_fn_13+0x50>
    102a:	mov    rdx,r14
    102d:	mov    rsi,r15
    1030:	mov    rdi,QWORD PTR [rsp+0x30]
    1035:	mov    rcx,QWORD PTR [rsp+0x38]
    103a:	call   103f <botlish_fn_13+0x1c1>
			103b: R_X86_64_PLT32	rt_substr-0x4
    103f:	test   rax,rax
    1042:	jne    1073 <botlish_fn_13+0x1f5>
    1048:	xor    rdx,rdx
    104b:	mov    rax,rdx
    104e:	mov    rbx,QWORD PTR [rsp+0x50]
    1053:	mov    r12,QWORD PTR [rsp+0x58]
    1058:	mov    r13,QWORD PTR [rsp+0x60]
    105d:	mov    r14,QWORD PTR [rsp+0x68]
    1062:	mov    r15,QWORD PTR [rsp+0x70]
    1067:	add    rsp,0x80
    106e:	mov    rsp,rbp
    1071:	pop    rbp
    1072:	ret
    1073:	mov    rdx,QWORD PTR [rsp+0x38]
    1078:	mov    rbx,QWORD PTR [rsp+0x50]
    107d:	mov    r12,QWORD PTR [rsp+0x58]
    1082:	mov    r13,QWORD PTR [rsp+0x60]
    1087:	mov    r14,QWORD PTR [rsp+0x68]
    108c:	mov    r15,QWORD PTR [rsp+0x70]
    1091:	add    rsp,0x80
    1098:	mov    rsp,rbp
    109b:	pop    rbp
    109c:	ret

000000000000109d <botlish_entry_13: scan_unquoted<str, int, int>>:
    109d:	push   rbp
    109e:	mov    rbp,rsp
    10a1:	ud2

00000000000010a3 <botlish_fn_14: scan_quoted<str, int, str>>:
    10a3:	push   rbp
    10a4:	mov    rbp,rsp
    10a7:	sub    rsp,0xc0
    10ae:	mov    QWORD PTR [rsp+0x90],rbx
    10b6:	mov    QWORD PTR [rsp+0x98],r12
    10be:	mov    QWORD PTR [rsp+0xa0],r13
    10c6:	mov    QWORD PTR [rsp+0xa8],r14
    10ce:	mov    QWORD PTR [rsp+0xb0],r15
    10d6:	mov    r15,rdi
    10d9:	mov    QWORD PTR [rsp+0x18],0x0
    10e2:	mov    QWORD PTR [rsp],rsi
    10e6:	mov    QWORD PTR [rsp+0x8],rdx
    10eb:	mov    QWORD PTR [rsp+0x10],rcx
    10f0:	mov    r13,rcx
    10f3:	lea    r14,[rsp+0x60]
    10f8:	lea    rbx,[rsp+0x20]
    10fd:	mov    r12,rsi
    1100:	mov    QWORD PTR [rsp+0x80],rdx
    1108:	mov    rdx,QWORD PTR [rsp+0x80]
    1110:	mov    rsi,r12
    1113:	mov    rdi,r15
    1116:	call   111b <botlish_fn_14+0x78>
			1117: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    111b:	test   rdx,rdx
    111e:	je     143b <botlish_fn_14+0x398>
    1124:	cmp    rax,0x22
    1128:	mov    QWORD PTR [rsp+0x88],rax
    1130:	je     1234 <botlish_fn_14+0x191>
    1136:	mov    QWORD PTR [rsp+0x18],0x3
    113f:	mov    rsi,QWORD PTR [rsp+0x80]
    1147:	test   rsi,0x1
    114e:	je     1170 <botlish_fn_14+0xcd>
    1154:	mov    rdi,rsi
    1157:	add    rdi,0x2
    115b:	seto   r8b
    115f:	test   r8b,r8b
    1162:	jne    1170 <botlish_fn_14+0xcd>
    1168:	mov    rsi,rdi
    116b:	jmp    1180 <botlish_fn_14+0xdd>
    1170:	mov    edx,0x3
    1175:	mov    rdi,r15
    1178:	call   117d <botlish_fn_14+0xda>
			1179: R_X86_64_PLT32	rt_int_add-0x4
    117d:	mov    rsi,rax
    1180:	mov    QWORD PTR [rsp+0x8],rsi
    1185:	mov    rax,QWORD PTR [rsp+0x88]
    118d:	mov    QWORD PTR [rsp+0x80],rsi
    1195:	lea    rcx,[rax+0x1]
    1199:	cmp    rcx,0x101
    11a0:	jb     11b3 <botlish_fn_14+0x110>
    11a6:	mov    rsi,QWORD PTR [rsp+0x88]
    11ae:	jmp    11cf <botlish_fn_14+0x12c>
    11b3:	mov    rdi,r15
    11b6:	mov    rax,QWORD PTR [rdi+rcx*8+0x648]
    11be:	test   rax,rax
    11c1:	jne    11d7 <botlish_fn_14+0x134>
    11c7:	mov    rsi,QWORD PTR [rsp+0x88]
    11cf:	mov    rdi,r15
    11d2:	call   11d7 <botlish_fn_14+0x134>
			11d3: R_X86_64_PLT32	rt_short_to_str-0x4
    11d7:	mov    QWORD PTR [rsp+0x18],rax
    11dc:	mov    QWORD PTR [rsp+0x60],0x0
    11e5:	mov    QWORD PTR [rsp+0x68],r13
    11ea:	mov    QWORD PTR [rsp+0x70],0x0
    11f3:	mov    QWORD PTR [rsp+0x78],rax
    11f8:	mov    esi,0x2
    11fd:	mov    edx,0x4
    1202:	mov    rcx,r14
    1205:	mov    rdi,r15
    1208:	call   120d <botlish_fn_14+0x16a>
			1209: R_X86_64_PLT32	rt_construct-0x4
    120d:	test   rax,rax
    1210:	je     143b <botlish_fn_14+0x398>
    1216:	mov    QWORD PTR [rsp],r12
    121a:	mov    rsi,QWORD PTR [rsp+0x80]
    1222:	mov    QWORD PTR [rsp+0x8],rsi
    1227:	mov    QWORD PTR [rsp+0x10],rax
    122c:	mov    r13,rax
    122f:	jmp    1108 <botlish_fn_14+0x65>
    1234:	mov    QWORD PTR [rsp+0x18],0x3
    123d:	mov    rsi,QWORD PTR [rsp+0x80]
    1245:	test   rsi,0x1
    124c:	je     126c <botlish_fn_14+0x1c9>
    1252:	mov    rsi,QWORD PTR [rsp+0x80]
    125a:	mov    rdx,rsi
    125d:	add    rdx,0x2
    1261:	seto   al
    1264:	test   al,al
    1266:	je     1284 <botlish_fn_14+0x1e1>
    126c:	mov    edx,0x3
    1271:	mov    rsi,QWORD PTR [rsp+0x80]
    1279:	mov    rdi,r15
    127c:	call   1281 <botlish_fn_14+0x1de>
			127d: R_X86_64_PLT32	rt_int_add-0x4
    1281:	mov    rdx,rax
    1284:	mov    QWORD PTR [rsp+0x18],rdx
    1289:	mov    rcx,rbx
    128c:	mov    rsi,r12
    128f:	mov    rdi,r15
    1292:	call   1297 <botlish_fn_14+0x1f4>
			1293: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1297:	test   rax,rax
    129a:	mov    rsi,rax
    129d:	je     143b <botlish_fn_14+0x398>
    12a3:	mov    rdx,QWORD PTR [rsp+0x20]
    12a8:	mov    rcx,QWORD PTR [rsp+0x28]
    12ad:	mov    rdi,r15
    12b0:	mov    rax,QWORD PTR [rdi+0x10]
    12b4:	mov    r8,QWORD PTR [rax+0x28]
    12b8:	call   12bd <botlish_fn_14+0x21a>
			12b9: R_X86_64_PLT32	rt_str_region_eq-0x4
    12bd:	cmp    rax,0x6
    12c1:	je     1389 <botlish_fn_14+0x2e6>
    12c7:	xor    rsi,rsi
    12ca:	lea    rcx,[rsp+0x50]
    12cf:	mov    QWORD PTR [rsp+0x50],0x0
    12d8:	mov    QWORD PTR [rsp+0x58],r13
    12dd:	mov    edx,0x2
    12e2:	mov    rdi,r15
    12e5:	call   12ea <botlish_fn_14+0x247>
			12e6: R_X86_64_PLT32	rt_construct-0x4
    12ea:	test   rax,rax
    12ed:	je     143b <botlish_fn_14+0x398>
    12f3:	mov    QWORD PTR [rsp],rax
    12f7:	mov    rbx,rax
    12fa:	mov    QWORD PTR [rsp+0x10],0x3
    1303:	mov    rsi,QWORD PTR [rsp+0x80]
    130b:	test   rsi,0x1
    1312:	je     133a <botlish_fn_14+0x297>
    1318:	mov    rsi,QWORD PTR [rsp+0x80]
    1320:	mov    rdx,rsi
    1323:	add    rdx,0x2
    1327:	seto   al
    132a:	test   al,al
    132c:	jne    133a <botlish_fn_14+0x297>
    1332:	mov    rax,rbx
    1335:	jmp    1355 <botlish_fn_14+0x2b2>
    133a:	mov    edx,0x3
    133f:	mov    rsi,QWORD PTR [rsp+0x80]
    1347:	mov    rdi,r15
    134a:	call   134f <botlish_fn_14+0x2ac>
			134b: R_X86_64_PLT32	rt_int_add-0x4
    134f:	mov    rdx,rax
    1352:	mov    rax,rbx
    1355:	mov    rbx,QWORD PTR [rsp+0x90]
    135d:	mov    r12,QWORD PTR [rsp+0x98]
    1365:	mov    r13,QWORD PTR [rsp+0xa0]
    136d:	mov    r14,QWORD PTR [rsp+0xa8]
    1375:	mov    r15,QWORD PTR [rsp+0xb0]
    137d:	add    rsp,0xc0
    1384:	mov    rsp,rbp
    1387:	pop    rbp
    1388:	ret
    1389:	mov    QWORD PTR [rsp+0x18],0x5
    1392:	mov    rsi,QWORD PTR [rsp+0x80]
    139a:	test   rsi,0x1
    13a1:	je     13cd <botlish_fn_14+0x32a>
    13a7:	mov    rsi,QWORD PTR [rsp+0x80]
    13af:	add    rsi,0x4
    13b3:	seto   dil
    13b7:	test   dil,dil
    13ba:	jne    13cd <botlish_fn_14+0x32a>
    13c0:	mov    QWORD PTR [rsp+0x80],rsi
    13c8:	jmp    13ed <botlish_fn_14+0x34a>
    13cd:	mov    edx,0x5
    13d2:	mov    rsi,QWORD PTR [rsp+0x80]
    13da:	mov    rdi,r15
    13dd:	call   13e2 <botlish_fn_14+0x33f>
			13de: R_X86_64_PLT32	rt_int_add-0x4
    13e2:	mov    rsi,rax
    13e5:	mov    QWORD PTR [rsp+0x80],rax
    13ed:	mov    QWORD PTR [rsp+0x8],rsi
    13f2:	mov    rdi,r15
    13f5:	mov    rax,QWORD PTR [rdi+0x10]
    13f9:	mov    rax,QWORD PTR [rax+0x28]
    13fd:	mov    QWORD PTR [rsp+0x18],rax
    1402:	lea    rcx,[rsp+0x30]
    1407:	mov    QWORD PTR [rsp+0x30],0x0
    1410:	mov    QWORD PTR [rsp+0x38],r13
    1415:	mov    QWORD PTR [rsp+0x40],0x0
    141e:	mov    QWORD PTR [rsp+0x48],rax
    1423:	mov    esi,0x2
    1428:	mov    edx,0x4
    142d:	call   1432 <botlish_fn_14+0x38f>
			142e: R_X86_64_PLT32	rt_construct-0x4
    1432:	test   rax,rax
    1435:	jne    1475 <botlish_fn_14+0x3d2>
    143b:	xor    rdx,rdx
    143e:	mov    rax,rdx
    1441:	mov    rbx,QWORD PTR [rsp+0x90]
    1449:	mov    r12,QWORD PTR [rsp+0x98]
    1451:	mov    r13,QWORD PTR [rsp+0xa0]
    1459:	mov    r14,QWORD PTR [rsp+0xa8]
    1461:	mov    r15,QWORD PTR [rsp+0xb0]
    1469:	add    rsp,0xc0
    1470:	mov    rsp,rbp
    1473:	pop    rbp
    1474:	ret
    1475:	mov    QWORD PTR [rsp],r12
    1479:	mov    rsi,QWORD PTR [rsp+0x80]
    1481:	mov    QWORD PTR [rsp+0x8],rsi
    1486:	mov    QWORD PTR [rsp+0x10],rax
    148b:	mov    r13,rax
    148e:	jmp    1108 <botlish_fn_14+0x65>

0000000000001493 <botlish_entry_14: scan_quoted<str, int, str>>:
    1493:	push   rbp
    1494:	mov    rbp,rsp
    1497:	ud2

0000000000001499 <botlish_fn_15: scan_field<str, int>>:
    1499:	push   rbp
    149a:	mov    rbp,rsp
    149d:	sub    rsp,0x50
    14a1:	mov    QWORD PTR [rsp+0x30],rbx
    14a6:	mov    QWORD PTR [rsp+0x38],r12
    14ab:	mov    QWORD PTR [rsp+0x40],r13
    14b0:	mov    r12,rdi
    14b3:	mov    r13,rdx
    14b6:	mov    QWORD PTR [rsp+0x10],0x0
    14bf:	mov    QWORD PTR [rsp],rsi
    14c3:	mov    rbx,rsi
    14c6:	mov    QWORD PTR [rsp+0x8],rdx
    14cb:	lea    rcx,[rsp+0x18]
    14d0:	mov    rdx,r13
    14d3:	mov    rsi,rbx
    14d6:	mov    rdi,r12
    14d9:	call   14de <botlish_fn_15+0x45>
			14da: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    14de:	test   rax,rax
    14e1:	mov    rsi,rax
    14e4:	je     15af <botlish_fn_15+0x116>
    14ea:	mov    rdx,QWORD PTR [rsp+0x18]
    14ef:	mov    rcx,QWORD PTR [rsp+0x20]
    14f4:	mov    rdi,r12
    14f7:	mov    rax,QWORD PTR [rdi+0x10]
    14fb:	mov    r8,QWORD PTR [rax+0x28]
    14ff:	call   1504 <botlish_fn_15+0x6b>
			1500: R_X86_64_PLT32	rt_str_region_eq-0x4
    1504:	cmp    rax,0x6
    1508:	je     1540 <botlish_fn_15+0xa7>
    150e:	mov    rcx,r13
    1511:	mov    rsi,rbx
    1514:	mov    rdi,r12
    1517:	mov    rdx,rcx
    151a:	call   151f <botlish_fn_15+0x86>
			151b: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    151f:	test   rax,rax
    1522:	je     15af <botlish_fn_15+0x116>
    1528:	mov    rbx,QWORD PTR [rsp+0x30]
    152d:	mov    r12,QWORD PTR [rsp+0x38]
    1532:	mov    r13,QWORD PTR [rsp+0x40]
    1537:	add    rsp,0x50
    153b:	mov    rsp,rbp
    153e:	pop    rbp
    153f:	ret
    1540:	mov    rcx,r13
    1543:	mov    QWORD PTR [rsp+0x10],0x3
    154c:	test   rcx,0x1
    1553:	jne    1561 <botlish_fn_15+0xc8>
    1559:	mov    r13,rcx
    155c:	jmp    1576 <botlish_fn_15+0xdd>
    1561:	mov    rdx,rcx
    1564:	add    rdx,0x2
    1568:	mov    r13,rcx
    156b:	seto   al
    156e:	test   al,al
    1570:	je     1589 <botlish_fn_15+0xf0>
    1576:	mov    edx,0x3
    157b:	mov    rsi,r13
    157e:	mov    rdi,r12
    1581:	call   1586 <botlish_fn_15+0xed>
			1582: R_X86_64_PLT32	rt_int_add-0x4
    1586:	mov    rdx,rax
    1589:	mov    QWORD PTR [rsp+0x8],rdx
    158e:	mov    rdi,r12
    1591:	mov    rax,QWORD PTR [rdi+0x10]
    1595:	mov    rcx,QWORD PTR [rax+0x10]
    1599:	mov    QWORD PTR [rsp+0x10],rcx
    159e:	mov    rsi,rbx
    15a1:	call   15a6 <botlish_fn_15+0x10d>
			15a2: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    15a6:	test   rax,rax
    15a9:	jne    15cd <botlish_fn_15+0x134>
    15af:	xor    rdx,rdx
    15b2:	mov    rax,rdx
    15b5:	mov    rbx,QWORD PTR [rsp+0x30]
    15ba:	mov    r12,QWORD PTR [rsp+0x38]
    15bf:	mov    r13,QWORD PTR [rsp+0x40]
    15c4:	add    rsp,0x50
    15c8:	mov    rsp,rbp
    15cb:	pop    rbp
    15cc:	ret
    15cd:	mov    rbx,QWORD PTR [rsp+0x30]
    15d2:	mov    r12,QWORD PTR [rsp+0x38]
    15d7:	mov    r13,QWORD PTR [rsp+0x40]
    15dc:	add    rsp,0x50
    15e0:	mov    rsp,rbp
    15e3:	pop    rbp
    15e4:	ret

00000000000015e5 <botlish_entry_15: scan_field<str, int>>:
    15e5:	push   rbp
    15e6:	mov    rbp,rsp
    15e9:	ud2

00000000000015eb <botlish_fn_16: scan_record_rest<str, int, mutarray, int>>:
    15eb:	push   rbp
    15ec:	mov    rbp,rsp
    15ef:	sub    rsp,0x90
    15f6:	mov    QWORD PTR [rsp+0x60],rbx
    15fb:	mov    QWORD PTR [rsp+0x68],r12
    1600:	mov    QWORD PTR [rsp+0x70],r13
    1605:	mov    QWORD PTR [rsp+0x78],r14
    160a:	mov    QWORD PTR [rsp+0x80],r15
    1612:	mov    r15,rdi
    1615:	mov    QWORD PTR [rsp+0x20],0x0
    161e:	mov    QWORD PTR [rsp],rsi
    1622:	mov    QWORD PTR [rsp+0x8],rdx
    1627:	mov    QWORD PTR [rsp+0x10],rcx
    162c:	mov    QWORD PTR [rsp+0x18],r8
    1631:	lea    r12,[rsp+0x28]
    1636:	mov    rbx,rsi
    1639:	mov    QWORD PTR [rsp+0x38],rdx
    163e:	mov    QWORD PTR [rsp+0x40],rcx
    1643:	mov    QWORD PTR [rsp+0x48],r8
    1648:	mov    rcx,r12
    164b:	mov    rdx,QWORD PTR [rsp+0x38]
    1650:	mov    rsi,rbx
    1653:	mov    rdi,r15
    1656:	call   165b <botlish_fn_16+0x70>
			1657: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    165b:	test   rax,rax
    165e:	mov    QWORD PTR [rsp+0x50],rax
    1663:	je     1827 <botlish_fn_16+0x23c>
    1669:	mov    r14,QWORD PTR [rsp+0x28]
    166e:	mov    r13,QWORD PTR [rsp+0x30]
    1673:	mov    rdi,r15
    1676:	mov    rcx,QWORD PTR [rdi+0x10]
    167a:	mov    r8,QWORD PTR [rcx+0x18]
    167e:	mov    rcx,r13
    1681:	mov    rdx,r14
    1684:	mov    rsi,QWORD PTR [rsp+0x50]
    1689:	call   168e <botlish_fn_16+0xa3>
			168a: R_X86_64_PLT32	rt_str_region_eq-0x4
    168e:	cmp    rax,0x6
    1692:	je     17a0 <botlish_fn_16+0x1b5>
    1698:	mov    rdi,r15
    169b:	mov    rax,QWORD PTR [rdi+0x10]
    169f:	mov    r8,QWORD PTR [rax+0x20]
    16a3:	mov    rcx,r13
    16a6:	mov    rdx,r14
    16a9:	mov    rsi,QWORD PTR [rsp+0x50]
    16ae:	call   16b3 <botlish_fn_16+0xc8>
			16af: R_X86_64_PLT32	rt_str_region_eq-0x4
    16b3:	cmp    rax,0x6
    16b7:	je     1705 <botlish_fn_16+0x11a>
    16bd:	mov    rdx,QWORD PTR [rsp+0x48]
    16c2:	mov    rsi,QWORD PTR [rsp+0x40]
    16c7:	mov    rdi,r15
    16ca:	call   16cf <botlish_fn_16+0xe4>
			16cb: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    16cf:	test   rax,rax
    16d2:	je     1827 <botlish_fn_16+0x23c>
    16d8:	mov    rdx,QWORD PTR [rsp+0x38]
    16dd:	mov    rbx,QWORD PTR [rsp+0x60]
    16e2:	mov    r12,QWORD PTR [rsp+0x68]
    16e7:	mov    r13,QWORD PTR [rsp+0x70]
    16ec:	mov    r14,QWORD PTR [rsp+0x78]
    16f1:	mov    r15,QWORD PTR [rsp+0x80]
    16f9:	add    rsp,0x90
    1700:	mov    rsp,rbp
    1703:	pop    rbp
    1704:	ret
    1705:	mov    rdx,QWORD PTR [rsp+0x48]
    170a:	mov    rsi,QWORD PTR [rsp+0x40]
    170f:	mov    rdi,r15
    1712:	call   1717 <botlish_fn_16+0x12c>
			1713: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1717:	test   rax,rax
    171a:	je     1827 <botlish_fn_16+0x23c>
    1720:	mov    QWORD PTR [rsp],rax
    1724:	mov    rbx,rax
    1727:	mov    QWORD PTR [rsp+0x10],0x3
    1730:	mov    rdx,QWORD PTR [rsp+0x38]
    1735:	test   rdx,0x1
    173c:	je     1760 <botlish_fn_16+0x175>
    1742:	mov    rdx,QWORD PTR [rsp+0x38]
    1747:	add    rdx,0x2
    174b:	seto   sil
    174f:	test   sil,sil
    1752:	jne    1760 <botlish_fn_16+0x175>
    1758:	mov    rax,rbx
    175b:	jmp    1778 <botlish_fn_16+0x18d>
    1760:	mov    edx,0x3
    1765:	mov    rsi,QWORD PTR [rsp+0x38]
    176a:	mov    rdi,r15
    176d:	call   1772 <botlish_fn_16+0x187>
			176e: R_X86_64_PLT32	rt_int_add-0x4
    1772:	mov    rdx,rax
    1775:	mov    rax,rbx
    1778:	mov    rbx,QWORD PTR [rsp+0x60]
    177d:	mov    r12,QWORD PTR [rsp+0x68]
    1782:	mov    r13,QWORD PTR [rsp+0x70]
    1787:	mov    r14,QWORD PTR [rsp+0x78]
    178c:	mov    r15,QWORD PTR [rsp+0x80]
    1794:	add    rsp,0x90
    179b:	mov    rsp,rbp
    179e:	pop    rbp
    179f:	ret
    17a0:	mov    rsi,QWORD PTR [rsp+0x38]
    17a5:	mov    edx,0x3
    17aa:	mov    r13,rdx
    17ad:	mov    QWORD PTR [rsp+0x20],0x3
    17b6:	test   rsi,0x1
    17bd:	je     17d5 <botlish_fn_16+0x1ea>
    17c3:	mov    rdx,rsi
    17c6:	add    rdx,0x2
    17ca:	seto   al
    17cd:	test   al,al
    17cf:	je     17e3 <botlish_fn_16+0x1f8>
    17d5:	mov    rdx,r13
    17d8:	mov    rdi,r15
    17db:	call   17e0 <botlish_fn_16+0x1f5>
			17dc: R_X86_64_PLT32	rt_int_add-0x4
    17e0:	mov    rdx,rax
    17e3:	mov    QWORD PTR [rsp+0x8],rdx
    17e8:	mov    rsi,rbx
    17eb:	mov    rdi,r15
    17ee:	call   17f3 <botlish_fn_16+0x208>
			17ef: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    17f3:	test   rax,rax
    17f6:	je     1827 <botlish_fn_16+0x23c>
    17fc:	mov    QWORD PTR [rsp+0x8],rax
    1801:	mov    rcx,rax
    1804:	mov    QWORD PTR [rsp+0x20],rdx
    1809:	mov    rsi,QWORD PTR [rsp+0x40]
    180e:	mov    r14,rdx
    1811:	mov    rdx,QWORD PTR [rsp+0x48]
    1816:	mov    rdi,r15
    1819:	call   181e <botlish_fn_16+0x233>
			181a: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
    181e:	test   rax,rax
    1821:	jne    1855 <botlish_fn_16+0x26a>
    1827:	xor    rdx,rdx
    182a:	mov    rax,rdx
    182d:	mov    rbx,QWORD PTR [rsp+0x60]
    1832:	mov    r12,QWORD PTR [rsp+0x68]
    1837:	mov    r13,QWORD PTR [rsp+0x70]
    183c:	mov    r14,QWORD PTR [rsp+0x78]
    1841:	mov    r15,QWORD PTR [rsp+0x80]
    1849:	add    rsp,0x90
    1850:	mov    rsp,rbp
    1853:	pop    rbp
    1854:	ret
    1855:	mov    QWORD PTR [rsp+0x8],rax
    185a:	mov    QWORD PTR [rsp+0x38],rax
    185f:	mov    QWORD PTR [rsp+0x10],0x3
    1868:	mov    rdx,QWORD PTR [rsp+0x48]
    186d:	test   rdx,0x1
    1874:	jne    1887 <botlish_fn_16+0x29c>
    187a:	mov    rdx,r13
    187d:	mov    rsi,QWORD PTR [rsp+0x48]
    1882:	jmp    18a6 <botlish_fn_16+0x2bb>
    1887:	mov    rdx,QWORD PTR [rsp+0x48]
    188c:	mov    rax,rdx
    188f:	add    rax,0x2
    1893:	seto   cl
    1896:	test   cl,cl
    1898:	je     18ae <botlish_fn_16+0x2c3>
    189e:	mov    rdx,r13
    18a1:	mov    rsi,QWORD PTR [rsp+0x48]
    18a6:	mov    rdi,r15
    18a9:	call   18ae <botlish_fn_16+0x2c3>
			18aa: R_X86_64_PLT32	rt_int_add-0x4
    18ae:	mov    QWORD PTR [rsp],rbx
    18b2:	mov    rdx,r14
    18b5:	mov    QWORD PTR [rsp+0x8],rdx
    18ba:	mov    rcx,QWORD PTR [rsp+0x38]
    18bf:	mov    QWORD PTR [rsp+0x10],rcx
    18c4:	mov    QWORD PTR [rsp+0x18],rax
    18c9:	mov    QWORD PTR [rsp+0x38],rdx
    18ce:	mov    QWORD PTR [rsp+0x40],rcx
    18d3:	mov    QWORD PTR [rsp+0x48],rax
    18d8:	jmp    1648 <botlish_fn_16+0x5d>

00000000000018dd <botlish_entry_16: scan_record_rest<str, int, mutarray, int>>:
    18dd:	push   rbp
    18de:	mov    rbp,rsp
    18e1:	ud2

00000000000018e3 <botlish_fn_17: scan_record<str, int>>:
    18e3:	push   rbp
    18e4:	mov    rbp,rsp
    18e7:	sub    rsp,0x40
    18eb:	mov    QWORD PTR [rsp+0x20],rbx
    18f0:	mov    QWORD PTR [rsp+0x28],r12
    18f5:	mov    QWORD PTR [rsp+0x30],r14
    18fa:	mov    r14,rdi
    18fd:	mov    QWORD PTR [rsp+0x10],0x0
    1906:	mov    QWORD PTR [rsp+0x18],0x0
    190f:	mov    QWORD PTR [rsp],rsi
    1913:	mov    r12,rsi
    1916:	mov    QWORD PTR [rsp+0x8],rdx
    191b:	mov    rsi,r12
    191e:	mov    rdi,r14
    1921:	call   1926 <botlish_fn_17+0x43>
			1922: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    1926:	test   rax,rax
    1929:	je     197e <botlish_fn_17+0x9b>
    192f:	mov    QWORD PTR [rsp+0x8],rax
    1934:	mov    rsi,rax
    1937:	mov    QWORD PTR [rsp+0x10],rdx
    193c:	mov    rbx,rdx
    193f:	mov    rdi,r14
    1942:	call   1947 <botlish_fn_17+0x64>
			1943: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<str>
    1947:	test   rax,rax
    194a:	je     197e <botlish_fn_17+0x9b>
    1950:	mov    QWORD PTR [rsp+0x8],rax
    1955:	mov    rcx,rax
    1958:	mov    r8d,0x3
    195e:	mov    QWORD PTR [rsp+0x18],0x3
    1967:	mov    rdx,rbx
    196a:	mov    rsi,r12
    196d:	mov    rdi,r14
    1970:	call   1975 <botlish_fn_17+0x92>
			1971: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record_rest<str, int, mutarray, int>
    1975:	test   rax,rax
    1978:	jne    199c <botlish_fn_17+0xb9>
    197e:	xor    rdx,rdx
    1981:	mov    rax,rdx
    1984:	mov    rbx,QWORD PTR [rsp+0x20]
    1989:	mov    r12,QWORD PTR [rsp+0x28]
    198e:	mov    r14,QWORD PTR [rsp+0x30]
    1993:	add    rsp,0x40
    1997:	mov    rsp,rbp
    199a:	pop    rbp
    199b:	ret
    199c:	mov    rbx,QWORD PTR [rsp+0x20]
    19a1:	mov    r12,QWORD PTR [rsp+0x28]
    19a6:	mov    r14,QWORD PTR [rsp+0x30]
    19ab:	add    rsp,0x40
    19af:	mov    rsp,rbp
    19b2:	pop    rbp
    19b3:	ret

00000000000019b4 <botlish_entry_17: scan_record<str, int>>:
    19b4:	push   rbp
    19b5:	mov    rbp,rsp
    19b8:	ud2
    19ba:	add    BYTE PTR [rax],al
    19bc:	add    BYTE PTR [rax],al
	...

00000000000019c0 <botlish_fn_18: scan_records<str, int, mutarray, int>>:
    19c0:	push   rbp
    19c1:	mov    rbp,rsp
    19c4:	sub    rsp,0x60
    19c8:	mov    QWORD PTR [rsp+0x30],rbx
    19cd:	mov    QWORD PTR [rsp+0x38],r12
    19d2:	mov    QWORD PTR [rsp+0x40],r13
    19d7:	mov    QWORD PTR [rsp+0x48],r14
    19dc:	mov    QWORD PTR [rsp+0x50],r15
    19e1:	mov    r13,rdi
    19e4:	mov    QWORD PTR [rsp+0x20],0x0
    19ed:	mov    QWORD PTR [rsp],rsi
    19f1:	mov    QWORD PTR [rsp+0x8],rdx
    19f6:	mov    r12,rdx
    19f9:	mov    QWORD PTR [rsp+0x10],rcx
    19fe:	mov    QWORD PTR [rsp+0x18],r8
    1a03:	mov    rbx,rsi
    1a06:	mov    r14,r8
    1a09:	mov    r15,rcx
    1a0c:	mov    rsi,rbx
    1a0f:	mov    rdi,r13
    1a12:	call   1a17 <botlish_fn_18+0x57>
			1a13: R_X86_64_PLT32	rt_str_len-0x4
    1a17:	mov    rcx,r12
    1a1a:	and    rcx,rax
    1a1d:	mov    rdx,rax
    1a20:	test   rcx,0x1
    1a27:	jne    1a4d <botlish_fn_18+0x8d>
    1a2d:	mov    rsi,r12
    1a30:	mov    rdi,r13
    1a33:	call   1a38 <botlish_fn_18+0x78>
			1a34: R_X86_64_PLT32	rt_int_cmp-0x4
    1a38:	mov    ecx,0x2
    1a3d:	test   rax,rax
    1a40:	cmovge rcx,QWORD PTR [rip+0x128]        # 1b70 <botlish_fn_18+0x1b0>
    1a48:	jmp    1a5d <botlish_fn_18+0x9d>
    1a4d:	mov    ecx,0x2
    1a52:	cmp    r12,rdx
    1a55:	cmovge rcx,QWORD PTR [rip+0x113]        # 1b70 <botlish_fn_18+0x1b0>
    1a5d:	cmp    rcx,0x6
    1a61:	je     1b0c <botlish_fn_18+0x14c>
    1a67:	mov    rdx,r12
    1a6a:	mov    rsi,rbx
    1a6d:	mov    rdi,r13
    1a70:	call   1a75 <botlish_fn_18+0xb5>
			1a71: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1a75:	test   rax,rax
    1a78:	je     1b23 <botlish_fn_18+0x163>
    1a7e:	mov    QWORD PTR [rsp+0x8],rax
    1a83:	mov    rcx,rax
    1a86:	mov    QWORD PTR [rsp+0x20],rdx
    1a8b:	mov    rsi,r15
    1a8e:	mov    r12,rdx
    1a91:	mov    rdx,r14
    1a94:	mov    rdi,r13
    1a97:	call   1a9c <botlish_fn_18+0xdc>
			1a98: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1a9c:	test   rax,rax
    1a9f:	je     1b23 <botlish_fn_18+0x163>
    1aa5:	mov    QWORD PTR [rsp+0x8],rax
    1aaa:	mov    r15,rax
    1aad:	mov    QWORD PTR [rsp+0x10],0x3
    1ab6:	mov    rsi,r14
    1ab9:	test   rsi,0x1
    1ac0:	je     1adb <botlish_fn_18+0x11b>
    1ac6:	mov    rsi,r14
    1ac9:	mov    rax,rsi
    1acc:	add    rax,0x2
    1ad0:	seto   cl
    1ad3:	test   cl,cl
    1ad5:	je     1aeb <botlish_fn_18+0x12b>
    1adb:	mov    edx,0x3
    1ae0:	mov    rsi,r14
    1ae3:	mov    rdi,r13
    1ae6:	call   1aeb <botlish_fn_18+0x12b>
			1ae7: R_X86_64_PLT32	rt_int_add-0x4
    1aeb:	mov    QWORD PTR [rsp],rbx
    1aef:	mov    rdx,r12
    1af2:	mov    QWORD PTR [rsp+0x8],rdx
    1af7:	mov    rcx,r15
    1afa:	mov    QWORD PTR [rsp+0x10],rcx
    1aff:	mov    QWORD PTR [rsp+0x18],rax
    1b04:	mov    r14,rax
    1b07:	jmp    1a0c <botlish_fn_18+0x4c>
    1b0c:	mov    rdx,r14
    1b0f:	mov    rsi,r15
    1b12:	mov    rdi,r13
    1b15:	call   1b1a <botlish_fn_18+0x15a>
			1b16: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1b1a:	test   rax,rax
    1b1d:	jne    1b48 <botlish_fn_18+0x188>
    1b23:	xor    rax,rax
    1b26:	mov    rbx,QWORD PTR [rsp+0x30]
    1b2b:	mov    r12,QWORD PTR [rsp+0x38]
    1b30:	mov    r13,QWORD PTR [rsp+0x40]
    1b35:	mov    r14,QWORD PTR [rsp+0x48]
    1b3a:	mov    r15,QWORD PTR [rsp+0x50]
    1b3f:	add    rsp,0x60
    1b43:	mov    rsp,rbp
    1b46:	pop    rbp
    1b47:	ret
    1b48:	mov    rbx,QWORD PTR [rsp+0x30]
    1b4d:	mov    r12,QWORD PTR [rsp+0x38]
    1b52:	mov    r13,QWORD PTR [rsp+0x40]
    1b57:	mov    r14,QWORD PTR [rsp+0x48]
    1b5c:	mov    r15,QWORD PTR [rsp+0x50]
    1b61:	add    rsp,0x60
    1b65:	mov    rsp,rbp
    1b68:	pop    rbp
    1b69:	ret
    1b6a:	add    BYTE PTR [rax],al
    1b6c:	add    BYTE PTR [rax],al
    1b6e:	add    BYTE PTR [rax],al
    1b70:	(bad)
    1b71:	add    BYTE PTR [rax],al
    1b73:	add    BYTE PTR [rax],al
    1b75:	add    BYTE PTR [rax],al
	...

0000000000001b78 <botlish_entry_18: scan_records<str, int, mutarray, int>>:
    1b78:	push   rbp
    1b79:	mov    rbp,rsp
    1b7c:	mov    rsi,QWORD PTR [rdx]
    1b7f:	mov    r9,QWORD PTR [rdx+0x8]
    1b83:	mov    rcx,QWORD PTR [rdx+0x10]
    1b87:	mov    r8,QWORD PTR [rdx+0x18]
    1b8b:	mov    rdx,r9
    1b8e:	call   1b93 <botlish_entry_18+0x1b>
			1b8f: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1b93:	mov    rsp,rbp
    1b96:	pop    rbp
    1b97:	ret

0000000000001b98 <botlish_fn_19: csv_parse<str>>:
    1b98:	push   rbp
    1b99:	mov    rbp,rsp
    1b9c:	sub    rsp,0x40
    1ba0:	mov    QWORD PTR [rsp+0x20],rbx
    1ba5:	mov    QWORD PTR [rsp+0x28],r12
    1baa:	mov    QWORD PTR [rsp+0x30],r13
    1baf:	mov    rbx,rdi
    1bb2:	mov    QWORD PTR [rsp+0x8],0x0
    1bbb:	mov    QWORD PTR [rsp+0x10],0x0
    1bc4:	mov    QWORD PTR [rsp+0x18],0x0
    1bcd:	mov    QWORD PTR [rsp],rsi
    1bd1:	mov    r12,rsi
    1bd4:	mov    rsi,r12
    1bd7:	mov    rdi,rbx
    1bda:	call   1bdf <botlish_fn_19+0x47>
			1bdb: R_X86_64_PLT32	rt_str_len-0x4
    1bdf:	sar    rax,1
    1be2:	test   rax,rax
    1be5:	je     1c74 <botlish_fn_19+0xdc>
    1beb:	mov    edx,0x1
    1bf0:	mov    QWORD PTR [rsp+0x8],0x1
    1bf9:	mov    rsi,r12
    1bfc:	mov    rdi,rbx
    1bff:	call   1c04 <botlish_fn_19+0x6c>
			1c00: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1c04:	test   rax,rax
    1c07:	je     1c8b <botlish_fn_19+0xf3>
    1c0d:	mov    QWORD PTR [rsp+0x8],rax
    1c12:	mov    rsi,rax
    1c15:	mov    QWORD PTR [rsp+0x10],rdx
    1c1a:	mov    r13,rdx
    1c1d:	mov    rdi,rbx
    1c20:	call   1c25 <botlish_fn_19+0x8d>
			1c21: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<List[str]>
    1c25:	test   rax,rax
    1c28:	je     1c8b <botlish_fn_19+0xf3>
    1c2e:	mov    QWORD PTR [rsp+0x8],rax
    1c33:	mov    rcx,rax
    1c36:	mov    r8d,0x3
    1c3c:	mov    QWORD PTR [rsp+0x18],0x3
    1c45:	mov    rdx,r13
    1c48:	mov    rsi,r12
    1c4b:	mov    rdi,rbx
    1c4e:	call   1c53 <botlish_fn_19+0xbb>
			1c4f: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1c53:	test   rax,rax
    1c56:	je     1c8b <botlish_fn_19+0xf3>
    1c5c:	mov    rbx,QWORD PTR [rsp+0x20]
    1c61:	mov    r12,QWORD PTR [rsp+0x28]
    1c66:	mov    r13,QWORD PTR [rsp+0x30]
    1c6b:	add    rsp,0x40
    1c6f:	mov    rsp,rbp
    1c72:	pop    rbp
    1c73:	ret
    1c74:	xor    rdx,rdx
    1c77:	mov    rdi,rbx
    1c7a:	mov    rsi,rdx
    1c7d:	call   1c82 <botlish_fn_19+0xea>
			1c7e: R_X86_64_PLT32	rt_list_new-0x4
    1c82:	test   rax,rax
    1c85:	jne    1ca6 <botlish_fn_19+0x10e>
    1c8b:	xor    rax,rax
    1c8e:	mov    rbx,QWORD PTR [rsp+0x20]
    1c93:	mov    r12,QWORD PTR [rsp+0x28]
    1c98:	mov    r13,QWORD PTR [rsp+0x30]
    1c9d:	add    rsp,0x40
    1ca1:	mov    rsp,rbp
    1ca4:	pop    rbp
    1ca5:	ret
    1ca6:	mov    rbx,QWORD PTR [rsp+0x20]
    1cab:	mov    r12,QWORD PTR [rsp+0x28]
    1cb0:	mov    r13,QWORD PTR [rsp+0x30]
    1cb5:	add    rsp,0x40
    1cb9:	mov    rsp,rbp
    1cbc:	pop    rbp
    1cbd:	ret

0000000000001cbe <botlish_entry_19: csv_parse<str>>:
    1cbe:	push   rbp
    1cbf:	mov    rbp,rsp
    1cc2:	mov    rsi,QWORD PTR [rdx]
    1cc5:	call   1cca <botlish_entry_19+0xc>
			1cc6: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    1cca:	mov    rsp,rbp
    1ccd:	pop    rbp
    1cce:	ret

; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 7974  (per function: 68 461 461 81 81 357 412 412 279 279 81 365 430 664 1122 364 961 239 520 337)
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
     e0a:	sub    rsp,0x90
     e11:	mov    QWORD PTR [rsp+0x60],rbx
     e16:	mov    QWORD PTR [rsp+0x68],r12
     e1b:	mov    QWORD PTR [rsp+0x70],r13
     e20:	mov    QWORD PTR [rsp+0x78],r14
     e25:	mov    QWORD PTR [rsp+0x80],r15
     e2d:	mov    r14,rdi
     e30:	mov    QWORD PTR [rsp+0x18],0x0
     e39:	mov    QWORD PTR [rsp],rsi
     e3d:	mov    QWORD PTR [rsp+0x40],rsi
     e42:	mov    QWORD PTR [rsp+0x8],rdx
     e47:	mov    r15,rdx
     e4a:	mov    QWORD PTR [rsp+0x10],rcx
     e4f:	lea    r13,[rsp+0x20]
     e54:	mov    QWORD PTR [rsp+0x48],rcx
     e59:	mov    rcx,r13
     e5c:	mov    rdx,QWORD PTR [rsp+0x48]
     e61:	mov    rsi,QWORD PTR [rsp+0x40]
     e66:	mov    rdi,r14
     e69:	call   e6e <botlish_fn_13+0x68>
			e6a: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     e6e:	mov    r10,rax
     e71:	mov    QWORD PTR [rsp+0x50],rax
     e76:	test   rax,r10
     e79:	je     fdb <botlish_fn_13+0x1d5>
     e7f:	mov    rbx,QWORD PTR [rsp+0x20]
     e84:	mov    r12,QWORD PTR [rsp+0x28]
     e89:	mov    rdi,r14
     e8c:	mov    rcx,QWORD PTR [rdi+0x10]
     e90:	mov    r8,QWORD PTR [rcx+0x10]
     e94:	mov    rcx,r12
     e97:	mov    rdx,rbx
     e9a:	mov    rsi,QWORD PTR [rsp+0x50]
     e9f:	call   ea4 <botlish_fn_13+0x9e>
			ea0: R_X86_64_PLT32	rt_str_region_eq-0x4
     ea4:	cmp    rax,0x6
     ea8:	je     ee7 <botlish_fn_13+0xe1>
     eae:	mov    rdi,r14
     eb1:	mov    rax,QWORD PTR [rdi+0x10]
     eb5:	mov    r8,QWORD PTR [rax+0x18]
     eb9:	mov    rcx,r12
     ebc:	mov    rdx,rbx
     ebf:	mov    rsi,QWORD PTR [rsp+0x50]
     ec4:	call   ec9 <botlish_fn_13+0xc3>
			ec5: R_X86_64_PLT32	rt_str_region_eq-0x4
     ec9:	cmp    rax,0x6
     ecd:	je     edd <botlish_fn_13+0xd7>
     ed3:	mov    eax,0x2
     ed8:	jmp    eec <botlish_fn_13+0xe6>
     edd:	mov    eax,0x6
     ee2:	jmp    eec <botlish_fn_13+0xe6>
     ee7:	mov    eax,0x6
     eec:	cmp    rax,0x6
     ef0:	je     f2f <botlish_fn_13+0x129>
     ef6:	mov    rdi,r14
     ef9:	mov    rax,QWORD PTR [rdi+0x10]
     efd:	mov    r8,QWORD PTR [rax+0x20]
     f01:	mov    rcx,r12
     f04:	mov    rdx,rbx
     f07:	mov    rsi,QWORD PTR [rsp+0x50]
     f0c:	call   f11 <botlish_fn_13+0x10b>
			f0d: R_X86_64_PLT32	rt_str_region_eq-0x4
     f11:	cmp    rax,0x6
     f15:	je     f25 <botlish_fn_13+0x11f>
     f1b:	mov    eax,0x2
     f20:	jmp    f34 <botlish_fn_13+0x12e>
     f25:	mov    eax,0x6
     f2a:	jmp    f34 <botlish_fn_13+0x12e>
     f2f:	mov    eax,0x6
     f34:	cmp    rax,0x6
     f38:	je     fbd <botlish_fn_13+0x1b7>
     f3e:	mov    QWORD PTR [rsp+0x18],0x3
     f47:	mov    rsi,QWORD PTR [rsp+0x48]
     f4c:	test   rsi,0x1
     f53:	je     f81 <botlish_fn_13+0x17b>
     f59:	mov    rsi,QWORD PTR [rsp+0x48]
     f5e:	mov    rdi,rsi
     f61:	add    rdi,0x2
     f65:	seto   r9b
     f69:	test   r9b,r9b
     f6c:	jne    f81 <botlish_fn_13+0x17b>
     f72:	mov    rsi,QWORD PTR [rsp+0x40]
     f77:	mov    QWORD PTR [rsp+0x48],rdi
     f7c:	jmp    f9d <botlish_fn_13+0x197>
     f81:	mov    edx,0x3
     f86:	mov    rsi,QWORD PTR [rsp+0x48]
     f8b:	mov    rdi,r14
     f8e:	call   f93 <botlish_fn_13+0x18d>
			f8f: R_X86_64_PLT32	rt_int_add-0x4
     f93:	mov    rsi,QWORD PTR [rsp+0x40]
     f98:	mov    QWORD PTR [rsp+0x48],rax
     f9d:	mov    QWORD PTR [rsp],rsi
     fa1:	mov    rdx,r15
     fa4:	mov    QWORD PTR [rsp+0x8],rdx
     fa9:	mov    rax,QWORD PTR [rsp+0x48]
     fae:	mov    QWORD PTR [rsp+0x10],rax
     fb3:	mov    QWORD PTR [rsp+0x40],rsi
     fb8:	jmp    e59 <botlish_fn_13+0x53>
     fbd:	mov    rdx,r15
     fc0:	mov    rsi,QWORD PTR [rsp+0x40]
     fc5:	mov    rcx,QWORD PTR [rsp+0x48]
     fca:	mov    rdi,r14
     fcd:	call   fd2 <botlish_fn_13+0x1cc>
			fce: R_X86_64_PLT32	rt_substr-0x4
     fd2:	test   rax,rax
     fd5:	jne    1006 <botlish_fn_13+0x200>
     fdb:	xor    rax,rax
     fde:	mov    rbx,QWORD PTR [rsp+0x60]
     fe3:	mov    r12,QWORD PTR [rsp+0x68]
     fe8:	mov    r13,QWORD PTR [rsp+0x70]
     fed:	mov    r14,QWORD PTR [rsp+0x78]
     ff2:	mov    r15,QWORD PTR [rsp+0x80]
     ffa:	add    rsp,0x90
    1001:	mov    rsp,rbp
    1004:	pop    rbp
    1005:	ret
    1006:	mov    QWORD PTR [rsp],rax
    100a:	lea    rcx,[rsp+0x30]
    100f:	mov    QWORD PTR [rsp+0x30],rax
    1014:	mov    rsi,QWORD PTR [rsp+0x48]
    1019:	mov    QWORD PTR [rsp+0x38],rsi
    101e:	mov    esi,0x1
    1023:	mov    edx,0x2
    1028:	mov    rdi,r14
    102b:	call   1030 <botlish_fn_13+0x22a>
			102c: R_X86_64_PLT32	rt_struct_new-0x4
    1030:	mov    rbx,QWORD PTR [rsp+0x60]
    1035:	mov    r12,QWORD PTR [rsp+0x68]
    103a:	mov    r13,QWORD PTR [rsp+0x70]
    103f:	mov    r14,QWORD PTR [rsp+0x78]
    1044:	mov    r15,QWORD PTR [rsp+0x80]
    104c:	add    rsp,0x90
    1053:	mov    rsp,rbp
    1056:	pop    rbp
    1057:	ret

0000000000001058 <botlish_entry_13: scan_unquoted<str, int, int>>:
    1058:	push   rbp
    1059:	mov    rbp,rsp
    105c:	mov    rsi,QWORD PTR [rdx]
    105f:	mov    r8,QWORD PTR [rdx+0x8]
    1063:	mov    rcx,QWORD PTR [rdx+0x10]
    1067:	mov    rdx,r8
    106a:	call   106f <botlish_entry_13+0x17>
			106b: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    106f:	mov    rsp,rbp
    1072:	pop    rbp
    1073:	ret

0000000000001074 <botlish_fn_14: scan_quoted<str, int, str>>:
    1074:	push   rbp
    1075:	mov    rbp,rsp
    1078:	sub    rsp,0xe0
    107f:	mov    QWORD PTR [rsp+0xb0],rbx
    1087:	mov    QWORD PTR [rsp+0xb8],r12
    108f:	mov    QWORD PTR [rsp+0xc0],r13
    1097:	mov    QWORD PTR [rsp+0xc8],r14
    109f:	mov    QWORD PTR [rsp+0xd0],r15
    10a7:	mov    r14,rdi
    10aa:	mov    QWORD PTR [rsp+0x18],0x0
    10b3:	mov    QWORD PTR [rsp+0x20],0x0
    10bc:	mov    QWORD PTR [rsp],rsi
    10c0:	mov    QWORD PTR [rsp+0x8],rdx
    10c5:	mov    QWORD PTR [rsp+0x10],rcx
    10ca:	mov    r12,rcx
    10cd:	lea    r13,[rsp+0x78]
    10d2:	lea    rbx,[rsp+0x28]
    10d7:	mov    r15,rsi
    10da:	mov    QWORD PTR [rsp+0x98],rdx
    10e2:	mov    rdx,QWORD PTR [rsp+0x98]
    10ea:	mov    rsi,r15
    10ed:	mov    rdi,r14
    10f0:	call   10f5 <botlish_fn_14+0x81>
			10f1: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    10f5:	test   rax,rax
    10f8:	je     141a <botlish_fn_14+0x3a6>
    10fe:	mov    QWORD PTR [rsp+0x18],rax
    1103:	mov    rdi,r14
    1106:	mov    QWORD PTR [rsp+0xa0],rax
    110e:	mov    rdi,QWORD PTR [rdi+0x10]
    1112:	mov    rsi,QWORD PTR [rdi+0x28]
    1116:	mov    edx,0x1
    111b:	mov    ecx,0x3
    1120:	mov    rdi,r14
    1123:	mov    r8,QWORD PTR [rsp+0xa0]
    112b:	call   1130 <botlish_fn_14+0xbc>
			112c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1130:	cmp    rax,0x6
    1134:	je     11f8 <botlish_fn_14+0x184>
    113a:	mov    QWORD PTR [rsp+0x20],0x3
    1143:	mov    rsi,QWORD PTR [rsp+0x98]
    114b:	test   rsi,0x1
    1152:	je     1172 <botlish_fn_14+0xfe>
    1158:	mov    rcx,rsi
    115b:	add    rcx,0x2
    115f:	seto   al
    1162:	test   al,al
    1164:	jne    1172 <botlish_fn_14+0xfe>
    116a:	mov    rsi,rcx
    116d:	jmp    1182 <botlish_fn_14+0x10e>
    1172:	mov    edx,0x3
    1177:	mov    rdi,r14
    117a:	call   117f <botlish_fn_14+0x10b>
			117b: R_X86_64_PLT32	rt_int_add-0x4
    117f:	mov    rsi,rax
    1182:	mov    QWORD PTR [rsp+0x8],rsi
    1187:	mov    QWORD PTR [rsp+0x98],rsi
    118f:	mov    QWORD PTR [rsp+0x78],0x0
    1198:	mov    QWORD PTR [rsp+0x80],r12
    11a0:	mov    QWORD PTR [rsp+0x88],0x0
    11ac:	mov    rax,QWORD PTR [rsp+0xa0]
    11b4:	mov    QWORD PTR [rsp+0x90],rax
    11bc:	mov    esi,0x2
    11c1:	mov    edx,0x4
    11c6:	mov    rcx,r13
    11c9:	mov    rdi,r14
    11cc:	call   11d1 <botlish_fn_14+0x15d>
			11cd: R_X86_64_PLT32	rt_construct-0x4
    11d1:	test   rax,rax
    11d4:	je     141a <botlish_fn_14+0x3a6>
    11da:	mov    QWORD PTR [rsp],r15
    11de:	mov    rsi,QWORD PTR [rsp+0x98]
    11e6:	mov    QWORD PTR [rsp+0x8],rsi
    11eb:	mov    QWORD PTR [rsp+0x10],rax
    11f0:	mov    r12,rax
    11f3:	jmp    10e2 <botlish_fn_14+0x6e>
    11f8:	mov    QWORD PTR [rsp+0x18],0x3
    1201:	mov    rsi,QWORD PTR [rsp+0x98]
    1209:	test   rsi,0x1
    1210:	je     1230 <botlish_fn_14+0x1bc>
    1216:	mov    rsi,QWORD PTR [rsp+0x98]
    121e:	mov    rdx,rsi
    1221:	add    rdx,0x2
    1225:	seto   al
    1228:	test   al,al
    122a:	je     1248 <botlish_fn_14+0x1d4>
    1230:	mov    edx,0x3
    1235:	mov    rsi,QWORD PTR [rsp+0x98]
    123d:	mov    rdi,r14
    1240:	call   1245 <botlish_fn_14+0x1d1>
			1241: R_X86_64_PLT32	rt_int_add-0x4
    1245:	mov    rdx,rax
    1248:	mov    QWORD PTR [rsp+0x18],rdx
    124d:	mov    rcx,rbx
    1250:	mov    rsi,r15
    1253:	mov    rdi,r14
    1256:	call   125b <botlish_fn_14+0x1e7>
			1257: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    125b:	test   rax,rax
    125e:	mov    rsi,rax
    1261:	je     141a <botlish_fn_14+0x3a6>
    1267:	mov    rdx,QWORD PTR [rsp+0x28]
    126c:	mov    rcx,QWORD PTR [rsp+0x30]
    1271:	mov    rdi,r14
    1274:	mov    rax,QWORD PTR [rdi+0x10]
    1278:	mov    r8,QWORD PTR [rax+0x28]
    127c:	call   1281 <botlish_fn_14+0x20d>
			127d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1281:	cmp    rax,0x6
    1285:	je     1368 <botlish_fn_14+0x2f4>
    128b:	xor    rsi,rsi
    128e:	lea    rcx,[rsp+0x58]
    1293:	mov    QWORD PTR [rsp+0x58],0x0
    129c:	mov    QWORD PTR [rsp+0x60],r12
    12a1:	mov    edx,0x2
    12a6:	mov    rdi,r14
    12a9:	call   12ae <botlish_fn_14+0x23a>
			12aa: R_X86_64_PLT32	rt_construct-0x4
    12ae:	test   rax,rax
    12b1:	je     141a <botlish_fn_14+0x3a6>
    12b7:	mov    QWORD PTR [rsp],rax
    12bb:	mov    rbx,rax
    12be:	mov    QWORD PTR [rsp+0x10],0x3
    12c7:	mov    rsi,QWORD PTR [rsp+0x98]
    12cf:	test   rsi,0x1
    12d6:	je     12f6 <botlish_fn_14+0x282>
    12dc:	mov    rsi,QWORD PTR [rsp+0x98]
    12e4:	mov    rax,rsi
    12e7:	add    rax,0x2
    12eb:	seto   cl
    12ee:	test   cl,cl
    12f0:	je     130b <botlish_fn_14+0x297>
    12f6:	mov    edx,0x3
    12fb:	mov    rsi,QWORD PTR [rsp+0x98]
    1303:	mov    rdi,r14
    1306:	call   130b <botlish_fn_14+0x297>
			1307: R_X86_64_PLT32	rt_int_add-0x4
    130b:	mov    QWORD PTR [rsp+0x8],rax
    1310:	lea    rcx,[rsp+0x68]
    1315:	mov    rdx,rbx
    1318:	mov    QWORD PTR [rsp+0x68],rdx
    131d:	mov    QWORD PTR [rsp+0x70],rax
    1322:	mov    esi,0x1
    1327:	mov    edx,0x2
    132c:	mov    rdi,r14
    132f:	call   1334 <botlish_fn_14+0x2c0>
			1330: R_X86_64_PLT32	rt_struct_new-0x4
    1334:	mov    rbx,QWORD PTR [rsp+0xb0]
    133c:	mov    r12,QWORD PTR [rsp+0xb8]
    1344:	mov    r13,QWORD PTR [rsp+0xc0]
    134c:	mov    r14,QWORD PTR [rsp+0xc8]
    1354:	mov    r15,QWORD PTR [rsp+0xd0]
    135c:	add    rsp,0xe0
    1363:	mov    rsp,rbp
    1366:	pop    rbp
    1367:	ret
    1368:	mov    QWORD PTR [rsp+0x18],0x5
    1371:	mov    rsi,QWORD PTR [rsp+0x98]
    1379:	test   rsi,0x1
    1380:	je     13ac <botlish_fn_14+0x338>
    1386:	mov    rsi,QWORD PTR [rsp+0x98]
    138e:	add    rsi,0x4
    1392:	seto   r8b
    1396:	test   r8b,r8b
    1399:	jne    13ac <botlish_fn_14+0x338>
    139f:	mov    QWORD PTR [rsp+0x98],rsi
    13a7:	jmp    13cc <botlish_fn_14+0x358>
    13ac:	mov    edx,0x5
    13b1:	mov    rsi,QWORD PTR [rsp+0x98]
    13b9:	mov    rdi,r14
    13bc:	call   13c1 <botlish_fn_14+0x34d>
			13bd: R_X86_64_PLT32	rt_int_add-0x4
    13c1:	mov    rsi,rax
    13c4:	mov    QWORD PTR [rsp+0x98],rax
    13cc:	mov    QWORD PTR [rsp+0x8],rsi
    13d1:	mov    rdi,r14
    13d4:	mov    rax,QWORD PTR [rdi+0x10]
    13d8:	mov    rax,QWORD PTR [rax+0x28]
    13dc:	mov    QWORD PTR [rsp+0x18],rax
    13e1:	lea    rcx,[rsp+0x38]
    13e6:	mov    QWORD PTR [rsp+0x38],0x0
    13ef:	mov    QWORD PTR [rsp+0x40],r12
    13f4:	mov    QWORD PTR [rsp+0x48],0x0
    13fd:	mov    QWORD PTR [rsp+0x50],rax
    1402:	mov    esi,0x2
    1407:	mov    edx,0x4
    140c:	call   1411 <botlish_fn_14+0x39d>
			140d: R_X86_64_PLT32	rt_construct-0x4
    1411:	test   rax,rax
    1414:	jne    1451 <botlish_fn_14+0x3dd>
    141a:	xor    rax,rax
    141d:	mov    rbx,QWORD PTR [rsp+0xb0]
    1425:	mov    r12,QWORD PTR [rsp+0xb8]
    142d:	mov    r13,QWORD PTR [rsp+0xc0]
    1435:	mov    r14,QWORD PTR [rsp+0xc8]
    143d:	mov    r15,QWORD PTR [rsp+0xd0]
    1445:	add    rsp,0xe0
    144c:	mov    rsp,rbp
    144f:	pop    rbp
    1450:	ret
    1451:	mov    QWORD PTR [rsp],r15
    1455:	mov    rsi,QWORD PTR [rsp+0x98]
    145d:	mov    QWORD PTR [rsp+0x8],rsi
    1462:	mov    QWORD PTR [rsp+0x10],rax
    1467:	mov    r12,rax
    146a:	jmp    10e2 <botlish_fn_14+0x6e>

000000000000146f <botlish_entry_14: scan_quoted<str, int, str>>:
    146f:	push   rbp
    1470:	mov    rbp,rsp
    1473:	mov    rsi,QWORD PTR [rdx]
    1476:	mov    r8,QWORD PTR [rdx+0x8]
    147a:	mov    rcx,QWORD PTR [rdx+0x10]
    147e:	mov    rdx,r8
    1481:	call   1486 <botlish_entry_14+0x17>
			1482: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    1486:	mov    rsp,rbp
    1489:	pop    rbp
    148a:	ret

000000000000148b <botlish_fn_15: scan_field<str, int>>:
    148b:	push   rbp
    148c:	mov    rbp,rsp
    148f:	sub    rsp,0x50
    1493:	mov    QWORD PTR [rsp+0x30],rbx
    1498:	mov    QWORD PTR [rsp+0x38],r12
    149d:	mov    QWORD PTR [rsp+0x40],r13
    14a2:	mov    r12,rdi
    14a5:	mov    r13,rdx
    14a8:	mov    QWORD PTR [rsp+0x10],0x0
    14b1:	mov    QWORD PTR [rsp],rsi
    14b5:	mov    rbx,rsi
    14b8:	mov    QWORD PTR [rsp+0x8],rdx
    14bd:	lea    rcx,[rsp+0x18]
    14c2:	mov    rdx,r13
    14c5:	mov    rsi,rbx
    14c8:	mov    rdi,r12
    14cb:	call   14d0 <botlish_fn_15+0x45>
			14cc: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    14d0:	test   rax,rax
    14d3:	mov    rsi,rax
    14d6:	je     15a1 <botlish_fn_15+0x116>
    14dc:	mov    rdx,QWORD PTR [rsp+0x18]
    14e1:	mov    rcx,QWORD PTR [rsp+0x20]
    14e6:	mov    rdi,r12
    14e9:	mov    rax,QWORD PTR [rdi+0x10]
    14ed:	mov    r8,QWORD PTR [rax+0x28]
    14f1:	call   14f6 <botlish_fn_15+0x6b>
			14f2: R_X86_64_PLT32	rt_str_region_eq-0x4
    14f6:	cmp    rax,0x6
    14fa:	je     1532 <botlish_fn_15+0xa7>
    1500:	mov    rcx,r13
    1503:	mov    rsi,rbx
    1506:	mov    rdi,r12
    1509:	mov    rdx,rcx
    150c:	call   1511 <botlish_fn_15+0x86>
			150d: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    1511:	test   rax,rax
    1514:	je     15a1 <botlish_fn_15+0x116>
    151a:	mov    rbx,QWORD PTR [rsp+0x30]
    151f:	mov    r12,QWORD PTR [rsp+0x38]
    1524:	mov    r13,QWORD PTR [rsp+0x40]
    1529:	add    rsp,0x50
    152d:	mov    rsp,rbp
    1530:	pop    rbp
    1531:	ret
    1532:	mov    rcx,r13
    1535:	mov    QWORD PTR [rsp+0x10],0x3
    153e:	test   rcx,0x1
    1545:	jne    1553 <botlish_fn_15+0xc8>
    154b:	mov    r13,rcx
    154e:	jmp    1568 <botlish_fn_15+0xdd>
    1553:	mov    rdx,rcx
    1556:	add    rdx,0x2
    155a:	mov    r13,rcx
    155d:	seto   al
    1560:	test   al,al
    1562:	je     157b <botlish_fn_15+0xf0>
    1568:	mov    edx,0x3
    156d:	mov    rsi,r13
    1570:	mov    rdi,r12
    1573:	call   1578 <botlish_fn_15+0xed>
			1574: R_X86_64_PLT32	rt_int_add-0x4
    1578:	mov    rdx,rax
    157b:	mov    QWORD PTR [rsp+0x8],rdx
    1580:	mov    rdi,r12
    1583:	mov    rax,QWORD PTR [rdi+0x10]
    1587:	mov    rcx,QWORD PTR [rax+0x10]
    158b:	mov    QWORD PTR [rsp+0x10],rcx
    1590:	mov    rsi,rbx
    1593:	call   1598 <botlish_fn_15+0x10d>
			1594: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    1598:	test   rax,rax
    159b:	jne    15bc <botlish_fn_15+0x131>
    15a1:	xor    rax,rax
    15a4:	mov    rbx,QWORD PTR [rsp+0x30]
    15a9:	mov    r12,QWORD PTR [rsp+0x38]
    15ae:	mov    r13,QWORD PTR [rsp+0x40]
    15b3:	add    rsp,0x50
    15b7:	mov    rsp,rbp
    15ba:	pop    rbp
    15bb:	ret
    15bc:	mov    rbx,QWORD PTR [rsp+0x30]
    15c1:	mov    r12,QWORD PTR [rsp+0x38]
    15c6:	mov    r13,QWORD PTR [rsp+0x40]
    15cb:	add    rsp,0x50
    15cf:	mov    rsp,rbp
    15d2:	pop    rbp
    15d3:	ret

00000000000015d4 <botlish_entry_15: scan_field<str, int>>:
    15d4:	push   rbp
    15d5:	mov    rbp,rsp
    15d8:	mov    rsi,QWORD PTR [rdx]
    15db:	mov    rdx,QWORD PTR [rdx+0x8]
    15df:	call   15e4 <botlish_entry_15+0x10>
			15e0: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    15e4:	mov    rsp,rbp
    15e7:	pop    rbp
    15e8:	ret

00000000000015e9 <botlish_fn_16: scan_record_rest<str, int, mutarray, int>>:
    15e9:	push   rbp
    15ea:	mov    rbp,rsp
    15ed:	sub    rsp,0xb0
    15f4:	mov    QWORD PTR [rsp+0x80],rbx
    15fc:	mov    QWORD PTR [rsp+0x88],r12
    1604:	mov    QWORD PTR [rsp+0x90],r13
    160c:	mov    QWORD PTR [rsp+0x98],r14
    1614:	mov    QWORD PTR [rsp+0xa0],r15
    161c:	mov    r15,rdi
    161f:	mov    QWORD PTR [rsp+0x20],0x0
    1628:	mov    QWORD PTR [rsp],rsi
    162c:	mov    QWORD PTR [rsp+0x8],rdx
    1631:	mov    QWORD PTR [rsp+0x10],rcx
    1636:	mov    QWORD PTR [rsp+0x18],r8
    163b:	lea    rbx,[rsp+0x28]
    1640:	mov    r12,rsi
    1643:	mov    QWORD PTR [rsp+0x58],rdx
    1648:	mov    QWORD PTR [rsp+0x60],rcx
    164d:	mov    QWORD PTR [rsp+0x68],r8
    1652:	mov    rcx,rbx
    1655:	mov    rdx,QWORD PTR [rsp+0x58]
    165a:	mov    rsi,r12
    165d:	mov    rdi,r15
    1660:	call   1665 <botlish_fn_16+0x7c>
			1661: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1665:	test   rax,rax
    1668:	mov    QWORD PTR [rsp+0x70],rax
    166d:	je     189e <botlish_fn_16+0x2b5>
    1673:	mov    r14,QWORD PTR [rsp+0x28]
    1678:	mov    r13,QWORD PTR [rsp+0x30]
    167d:	mov    rdi,r15
    1680:	mov    rcx,QWORD PTR [rdi+0x10]
    1684:	mov    r8,QWORD PTR [rcx+0x18]
    1688:	mov    rcx,r13
    168b:	mov    rdx,r14
    168e:	mov    rsi,QWORD PTR [rsp+0x70]
    1693:	call   1698 <botlish_fn_16+0xaf>
			1694: R_X86_64_PLT32	rt_str_region_eq-0x4
    1698:	cmp    rax,0x6
    169c:	je     17ff <botlish_fn_16+0x216>
    16a2:	mov    rdi,r15
    16a5:	mov    rcx,QWORD PTR [rdi+0x10]
    16a9:	mov    r8,QWORD PTR [rcx+0x20]
    16ad:	mov    rcx,r13
    16b0:	mov    rdx,r14
    16b3:	mov    rsi,QWORD PTR [rsp+0x70]
    16b8:	call   16bd <botlish_fn_16+0xd4>
			16b9: R_X86_64_PLT32	rt_str_region_eq-0x4
    16bd:	cmp    rax,0x6
    16c1:	je     173e <botlish_fn_16+0x155>
    16c7:	mov    rdx,QWORD PTR [rsp+0x68]
    16cc:	mov    rsi,QWORD PTR [rsp+0x60]
    16d1:	mov    rdi,r15
    16d4:	call   16d9 <botlish_fn_16+0xf0>
			16d5: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    16d9:	test   rax,rax
    16dc:	je     189e <botlish_fn_16+0x2b5>
    16e2:	mov    QWORD PTR [rsp],rax
    16e6:	lea    rcx,[rsp+0x48]
    16eb:	mov    QWORD PTR [rsp+0x48],rax
    16f0:	mov    rsi,QWORD PTR [rsp+0x58]
    16f5:	mov    QWORD PTR [rsp+0x50],rsi
    16fa:	xor    rsi,rsi
    16fd:	mov    edx,0x2
    1702:	mov    rdi,r15
    1705:	call   170a <botlish_fn_16+0x121>
			1706: R_X86_64_PLT32	rt_struct_new-0x4
    170a:	mov    rbx,QWORD PTR [rsp+0x80]
    1712:	mov    r12,QWORD PTR [rsp+0x88]
    171a:	mov    r13,QWORD PTR [rsp+0x90]
    1722:	mov    r14,QWORD PTR [rsp+0x98]
    172a:	mov    r15,QWORD PTR [rsp+0xa0]
    1732:	add    rsp,0xb0
    1739:	mov    rsp,rbp
    173c:	pop    rbp
    173d:	ret
    173e:	mov    rdx,QWORD PTR [rsp+0x68]
    1743:	mov    rsi,QWORD PTR [rsp+0x60]
    1748:	mov    rdi,r15
    174b:	call   1750 <botlish_fn_16+0x167>
			174c: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1750:	test   rax,rax
    1753:	je     189e <botlish_fn_16+0x2b5>
    1759:	mov    QWORD PTR [rsp],rax
    175d:	mov    rbx,rax
    1760:	mov    QWORD PTR [rsp+0x10],0x3
    1769:	mov    rsi,QWORD PTR [rsp+0x58]
    176e:	test   rsi,0x1
    1775:	je     1792 <botlish_fn_16+0x1a9>
    177b:	mov    rsi,QWORD PTR [rsp+0x58]
    1780:	mov    rax,rsi
    1783:	add    rax,0x2
    1787:	seto   cl
    178a:	test   cl,cl
    178c:	je     17a4 <botlish_fn_16+0x1bb>
    1792:	mov    edx,0x3
    1797:	mov    rsi,QWORD PTR [rsp+0x58]
    179c:	mov    rdi,r15
    179f:	call   17a4 <botlish_fn_16+0x1bb>
			17a0: R_X86_64_PLT32	rt_int_add-0x4
    17a4:	mov    QWORD PTR [rsp+0x8],rax
    17a9:	lea    rcx,[rsp+0x38]
    17ae:	mov    rdx,rbx
    17b1:	mov    QWORD PTR [rsp+0x38],rdx
    17b6:	mov    QWORD PTR [rsp+0x40],rax
    17bb:	xor    rsi,rsi
    17be:	mov    edx,0x2
    17c3:	mov    rdi,r15
    17c6:	call   17cb <botlish_fn_16+0x1e2>
			17c7: R_X86_64_PLT32	rt_struct_new-0x4
    17cb:	mov    rbx,QWORD PTR [rsp+0x80]
    17d3:	mov    r12,QWORD PTR [rsp+0x88]
    17db:	mov    r13,QWORD PTR [rsp+0x90]
    17e3:	mov    r14,QWORD PTR [rsp+0x98]
    17eb:	mov    r15,QWORD PTR [rsp+0xa0]
    17f3:	add    rsp,0xb0
    17fa:	mov    rsp,rbp
    17fd:	pop    rbp
    17fe:	ret
    17ff:	mov    edx,0x3
    1804:	mov    r13,rdx
    1807:	mov    QWORD PTR [rsp+0x20],0x3
    1810:	mov    rsi,QWORD PTR [rsp+0x58]
    1815:	test   rsi,0x1
    181c:	jne    182c <botlish_fn_16+0x243>
    1822:	mov    rsi,QWORD PTR [rsp+0x58]
    1827:	jmp    1848 <botlish_fn_16+0x25f>
    182c:	mov    rsi,QWORD PTR [rsp+0x58]
    1831:	mov    rdx,rsi
    1834:	add    rdx,0x2
    1838:	seto   al
    183b:	test   al,al
    183d:	je     1856 <botlish_fn_16+0x26d>
    1843:	mov    rsi,QWORD PTR [rsp+0x58]
    1848:	mov    rdx,r13
    184b:	mov    rdi,r15
    184e:	call   1853 <botlish_fn_16+0x26a>
			184f: R_X86_64_PLT32	rt_int_add-0x4
    1853:	mov    rdx,rax
    1856:	mov    QWORD PTR [rsp+0x8],rdx
    185b:	mov    rsi,r12
    185e:	mov    rdi,r15
    1861:	call   1866 <botlish_fn_16+0x27d>
			1862: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    1866:	test   rax,rax
    1869:	je     189e <botlish_fn_16+0x2b5>
    186f:	mov    QWORD PTR [rsp+0x8],rax
    1874:	mov    rcx,QWORD PTR [rax+0x18]
    1878:	mov    r14,rax
    187b:	mov    rcx,QWORD PTR [rcx]
    187e:	mov    QWORD PTR [rsp+0x20],rcx
    1883:	mov    rsi,QWORD PTR [rsp+0x60]
    1888:	mov    rdx,QWORD PTR [rsp+0x68]
    188d:	mov    rdi,r15
    1890:	call   1895 <botlish_fn_16+0x2ac>
			1891: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
    1895:	test   rax,rax
    1898:	jne    18d5 <botlish_fn_16+0x2ec>
    189e:	xor    rax,rax
    18a1:	mov    rbx,QWORD PTR [rsp+0x80]
    18a9:	mov    r12,QWORD PTR [rsp+0x88]
    18b1:	mov    r13,QWORD PTR [rsp+0x90]
    18b9:	mov    r14,QWORD PTR [rsp+0x98]
    18c1:	mov    r15,QWORD PTR [rsp+0xa0]
    18c9:	add    rsp,0xb0
    18d0:	mov    rsp,rbp
    18d3:	pop    rbp
    18d4:	ret
    18d5:	mov    QWORD PTR [rsp+0x8],rax
    18da:	mov    rcx,rax
    18dd:	mov    rax,r14
    18e0:	mov    r14,rcx
    18e3:	mov    rax,QWORD PTR [rax+0x18]
    18e7:	mov    rsi,QWORD PTR [rax+0x8]
    18eb:	mov    QWORD PTR [rsp+0x58],rsi
    18f0:	mov    QWORD PTR [rsp+0x10],rsi
    18f5:	mov    QWORD PTR [rsp+0x20],0x3
    18fe:	mov    rdx,QWORD PTR [rsp+0x68]
    1903:	test   rdx,0x1
    190a:	jne    191d <botlish_fn_16+0x334>
    1910:	mov    rdx,r13
    1913:	mov    rsi,QWORD PTR [rsp+0x68]
    1918:	jmp    193c <botlish_fn_16+0x353>
    191d:	mov    rdx,QWORD PTR [rsp+0x68]
    1922:	mov    rax,rdx
    1925:	add    rax,0x2
    1929:	seto   cl
    192c:	test   cl,cl
    192e:	je     1944 <botlish_fn_16+0x35b>
    1934:	mov    rdx,r13
    1937:	mov    rsi,QWORD PTR [rsp+0x68]
    193c:	mov    rdi,r15
    193f:	call   1944 <botlish_fn_16+0x35b>
			1940: R_X86_64_PLT32	rt_int_add-0x4
    1944:	mov    QWORD PTR [rsp],r12
    1948:	mov    rsi,QWORD PTR [rsp+0x58]
    194d:	mov    QWORD PTR [rsp+0x8],rsi
    1952:	mov    rcx,r14
    1955:	mov    QWORD PTR [rsp+0x10],rcx
    195a:	mov    QWORD PTR [rsp+0x18],rax
    195f:	mov    QWORD PTR [rsp+0x60],rcx
    1964:	mov    QWORD PTR [rsp+0x68],rax
    1969:	jmp    1652 <botlish_fn_16+0x69>

000000000000196e <botlish_entry_16: scan_record_rest<str, int, mutarray, int>>:
    196e:	push   rbp
    196f:	mov    rbp,rsp
    1972:	mov    rsi,QWORD PTR [rdx]
    1975:	mov    r9,QWORD PTR [rdx+0x8]
    1979:	mov    rcx,QWORD PTR [rdx+0x10]
    197d:	mov    r8,QWORD PTR [rdx+0x18]
    1981:	mov    rdx,r9
    1984:	call   1989 <botlish_entry_16+0x1b>
			1985: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record_rest<str, int, mutarray, int>
    1989:	mov    rsp,rbp
    198c:	pop    rbp
    198d:	ret

000000000000198e <botlish_fn_17: scan_record<str, int>>:
    198e:	push   rbp
    198f:	mov    rbp,rsp
    1992:	sub    rsp,0x40
    1996:	mov    QWORD PTR [rsp+0x20],rbx
    199b:	mov    QWORD PTR [rsp+0x28],r12
    19a0:	mov    QWORD PTR [rsp+0x30],r14
    19a5:	mov    rbx,rdi
    19a8:	mov    QWORD PTR [rsp+0x10],0x0
    19b1:	mov    QWORD PTR [rsp+0x18],0x0
    19ba:	mov    QWORD PTR [rsp],rsi
    19be:	mov    r14,rsi
    19c1:	mov    QWORD PTR [rsp+0x8],rdx
    19c6:	mov    rsi,r14
    19c9:	mov    rdi,rbx
    19cc:	call   19d1 <botlish_fn_17+0x43>
			19cd: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    19d1:	test   rax,rax
    19d4:	je     1a35 <botlish_fn_17+0xa7>
    19da:	mov    rcx,QWORD PTR [rax+0x18]
    19de:	mov    rdx,QWORD PTR [rcx+0x8]
    19e2:	mov    QWORD PTR [rsp+0x8],rdx
    19e7:	mov    r12,rdx
    19ea:	mov    rax,QWORD PTR [rax+0x18]
    19ee:	mov    rsi,QWORD PTR [rax]
    19f1:	mov    QWORD PTR [rsp+0x10],rsi
    19f6:	mov    rdi,rbx
    19f9:	call   19fe <botlish_fn_17+0x70>
			19fa: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<str>
    19fe:	test   rax,rax
    1a01:	je     1a35 <botlish_fn_17+0xa7>
    1a07:	mov    QWORD PTR [rsp+0x10],rax
    1a0c:	mov    rcx,rax
    1a0f:	mov    r8d,0x3
    1a15:	mov    QWORD PTR [rsp+0x18],0x3
    1a1e:	mov    rdx,r12
    1a21:	mov    rsi,r14
    1a24:	mov    rdi,rbx
    1a27:	call   1a2c <botlish_fn_17+0x9e>
			1a28: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record_rest<str, int, mutarray, int>
    1a2c:	test   rax,rax
    1a2f:	jne    1a50 <botlish_fn_17+0xc2>
    1a35:	xor    rax,rax
    1a38:	mov    rbx,QWORD PTR [rsp+0x20]
    1a3d:	mov    r12,QWORD PTR [rsp+0x28]
    1a42:	mov    r14,QWORD PTR [rsp+0x30]
    1a47:	add    rsp,0x40
    1a4b:	mov    rsp,rbp
    1a4e:	pop    rbp
    1a4f:	ret
    1a50:	mov    rbx,QWORD PTR [rsp+0x20]
    1a55:	mov    r12,QWORD PTR [rsp+0x28]
    1a5a:	mov    r14,QWORD PTR [rsp+0x30]
    1a5f:	add    rsp,0x40
    1a63:	mov    rsp,rbp
    1a66:	pop    rbp
    1a67:	ret

0000000000001a68 <botlish_entry_17: scan_record<str, int>>:
    1a68:	push   rbp
    1a69:	mov    rbp,rsp
    1a6c:	mov    rsi,QWORD PTR [rdx]
    1a6f:	mov    rdx,QWORD PTR [rdx+0x8]
    1a73:	call   1a78 <botlish_entry_17+0x10>
			1a74: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1a78:	mov    rsp,rbp
    1a7b:	pop    rbp
    1a7c:	ret
    1a7d:	add    BYTE PTR [rax],al
	...

0000000000001a80 <botlish_fn_18: scan_records<str, int, mutarray, int>>:
    1a80:	push   rbp
    1a81:	mov    rbp,rsp
    1a84:	sub    rsp,0x60
    1a88:	mov    QWORD PTR [rsp+0x30],rbx
    1a8d:	mov    QWORD PTR [rsp+0x38],r12
    1a92:	mov    QWORD PTR [rsp+0x40],r13
    1a97:	mov    QWORD PTR [rsp+0x48],r14
    1a9c:	mov    QWORD PTR [rsp+0x50],r15
    1aa1:	mov    r13,rdi
    1aa4:	mov    QWORD PTR [rsp+0x20],0x0
    1aad:	mov    QWORD PTR [rsp],rsi
    1ab1:	mov    QWORD PTR [rsp+0x8],rdx
    1ab6:	mov    r12,rdx
    1ab9:	mov    QWORD PTR [rsp+0x10],rcx
    1abe:	mov    QWORD PTR [rsp+0x18],r8
    1ac3:	mov    rbx,rsi
    1ac6:	mov    r14,r8
    1ac9:	mov    r15,rcx
    1acc:	mov    rsi,rbx
    1acf:	mov    rdi,r13
    1ad2:	call   1ad7 <botlish_fn_18+0x57>
			1ad3: R_X86_64_PLT32	rt_str_len-0x4
    1ad7:	mov    rcx,r12
    1ada:	and    rcx,rax
    1add:	mov    rdx,rax
    1ae0:	test   rcx,0x1
    1ae7:	jne    1b0d <botlish_fn_18+0x8d>
    1aed:	mov    rsi,r12
    1af0:	mov    rdi,r13
    1af3:	call   1af8 <botlish_fn_18+0x78>
			1af4: R_X86_64_PLT32	rt_int_cmp-0x4
    1af8:	mov    ecx,0x2
    1afd:	test   rax,rax
    1b00:	cmovge rcx,QWORD PTR [rip+0x140]        # 1c48 <botlish_fn_18+0x1c8>
    1b08:	jmp    1b20 <botlish_fn_18+0xa0>
    1b0d:	mov    ecx,0x2
    1b12:	mov    rax,r12
    1b15:	cmp    rax,rdx
    1b18:	cmovge rcx,QWORD PTR [rip+0x128]        # 1c48 <botlish_fn_18+0x1c8>
    1b20:	cmp    rcx,0x6
    1b24:	je     1be6 <botlish_fn_18+0x166>
    1b2a:	mov    rdx,r12
    1b2d:	mov    rsi,rbx
    1b30:	mov    rdi,r13
    1b33:	call   1b38 <botlish_fn_18+0xb8>
			1b34: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1b38:	test   rax,rax
    1b3b:	je     1bfd <botlish_fn_18+0x17d>
    1b41:	mov    QWORD PTR [rsp+0x8],rax
    1b46:	mov    rcx,QWORD PTR [rax+0x18]
    1b4a:	mov    r12,rax
    1b4d:	mov    rcx,QWORD PTR [rcx]
    1b50:	mov    QWORD PTR [rsp+0x20],rcx
    1b55:	mov    rsi,r15
    1b58:	mov    rdx,r14
    1b5b:	mov    rdi,r13
    1b5e:	call   1b63 <botlish_fn_18+0xe3>
			1b5f: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1b63:	test   rax,rax
    1b66:	je     1bfd <botlish_fn_18+0x17d>
    1b6c:	mov    QWORD PTR [rsp+0x8],rax
    1b71:	mov    r15,rax
    1b74:	mov    rax,r12
    1b77:	mov    rax,QWORD PTR [rax+0x18]
    1b7b:	mov    rdx,QWORD PTR [rax+0x8]
    1b7f:	mov    r12,rdx
    1b82:	mov    QWORD PTR [rsp+0x10],rdx
    1b87:	mov    QWORD PTR [rsp+0x20],0x3
    1b90:	mov    rsi,r14
    1b93:	test   rsi,0x1
    1b9a:	je     1bb5 <botlish_fn_18+0x135>
    1ba0:	mov    rsi,r14
    1ba3:	mov    rax,rsi
    1ba6:	add    rax,0x2
    1baa:	seto   cl
    1bad:	test   cl,cl
    1baf:	je     1bc5 <botlish_fn_18+0x145>
    1bb5:	mov    edx,0x3
    1bba:	mov    rsi,r14
    1bbd:	mov    rdi,r13
    1bc0:	call   1bc5 <botlish_fn_18+0x145>
			1bc1: R_X86_64_PLT32	rt_int_add-0x4
    1bc5:	mov    QWORD PTR [rsp],rbx
    1bc9:	mov    rdx,r12
    1bcc:	mov    QWORD PTR [rsp+0x8],rdx
    1bd1:	mov    rcx,r15
    1bd4:	mov    QWORD PTR [rsp+0x10],rcx
    1bd9:	mov    QWORD PTR [rsp+0x18],rax
    1bde:	mov    r14,rax
    1be1:	jmp    1acc <botlish_fn_18+0x4c>
    1be6:	mov    rdx,r14
    1be9:	mov    rsi,r15
    1bec:	mov    rdi,r13
    1bef:	call   1bf4 <botlish_fn_18+0x174>
			1bf0: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1bf4:	test   rax,rax
    1bf7:	jne    1c22 <botlish_fn_18+0x1a2>
    1bfd:	xor    rax,rax
    1c00:	mov    rbx,QWORD PTR [rsp+0x30]
    1c05:	mov    r12,QWORD PTR [rsp+0x38]
    1c0a:	mov    r13,QWORD PTR [rsp+0x40]
    1c0f:	mov    r14,QWORD PTR [rsp+0x48]
    1c14:	mov    r15,QWORD PTR [rsp+0x50]
    1c19:	add    rsp,0x60
    1c1d:	mov    rsp,rbp
    1c20:	pop    rbp
    1c21:	ret
    1c22:	mov    rbx,QWORD PTR [rsp+0x30]
    1c27:	mov    r12,QWORD PTR [rsp+0x38]
    1c2c:	mov    r13,QWORD PTR [rsp+0x40]
    1c31:	mov    r14,QWORD PTR [rsp+0x48]
    1c36:	mov    r15,QWORD PTR [rsp+0x50]
    1c3b:	add    rsp,0x60
    1c3f:	mov    rsp,rbp
    1c42:	pop    rbp
    1c43:	ret
    1c44:	add    BYTE PTR [rax],al
    1c46:	add    BYTE PTR [rax],al
    1c48:	(bad)
    1c49:	add    BYTE PTR [rax],al
    1c4b:	add    BYTE PTR [rax],al
    1c4d:	add    BYTE PTR [rax],al
	...

0000000000001c50 <botlish_entry_18: scan_records<str, int, mutarray, int>>:
    1c50:	push   rbp
    1c51:	mov    rbp,rsp
    1c54:	mov    rsi,QWORD PTR [rdx]
    1c57:	mov    r9,QWORD PTR [rdx+0x8]
    1c5b:	mov    rcx,QWORD PTR [rdx+0x10]
    1c5f:	mov    r8,QWORD PTR [rdx+0x18]
    1c63:	mov    rdx,r9
    1c66:	call   1c6b <botlish_entry_18+0x1b>
			1c67: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1c6b:	mov    rsp,rbp
    1c6e:	pop    rbp
    1c6f:	ret

0000000000001c70 <botlish_fn_19: csv_parse<str>>:
    1c70:	push   rbp
    1c71:	mov    rbp,rsp
    1c74:	sub    rsp,0x40
    1c78:	mov    QWORD PTR [rsp+0x20],rbx
    1c7d:	mov    QWORD PTR [rsp+0x28],r12
    1c82:	mov    QWORD PTR [rsp+0x30],r13
    1c87:	mov    rbx,rdi
    1c8a:	mov    QWORD PTR [rsp+0x8],0x0
    1c93:	mov    QWORD PTR [rsp+0x10],0x0
    1c9c:	mov    QWORD PTR [rsp+0x18],0x0
    1ca5:	mov    QWORD PTR [rsp],rsi
    1ca9:	mov    r12,rsi
    1cac:	mov    rsi,r12
    1caf:	mov    rdi,rbx
    1cb2:	call   1cb7 <botlish_fn_19+0x47>
			1cb3: R_X86_64_PLT32	rt_str_len-0x4
    1cb7:	sar    rax,1
    1cba:	test   rax,rax
    1cbd:	je     1d58 <botlish_fn_19+0xe8>
    1cc3:	mov    edx,0x1
    1cc8:	mov    QWORD PTR [rsp+0x8],0x1
    1cd1:	mov    rsi,r12
    1cd4:	mov    rdi,rbx
    1cd7:	call   1cdc <botlish_fn_19+0x6c>
			1cd8: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1cdc:	test   rax,rax
    1cdf:	je     1d6f <botlish_fn_19+0xff>
    1ce5:	mov    rcx,QWORD PTR [rax+0x18]
    1ce9:	mov    rdx,QWORD PTR [rcx+0x8]
    1ced:	mov    QWORD PTR [rsp+0x8],rdx
    1cf2:	mov    r13,rdx
    1cf5:	mov    rax,QWORD PTR [rax+0x18]
    1cf9:	mov    rsi,QWORD PTR [rax]
    1cfc:	mov    QWORD PTR [rsp+0x10],rsi
    1d01:	mov    rdi,rbx
    1d04:	call   1d09 <botlish_fn_19+0x99>
			1d05: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<List[str]>
    1d09:	test   rax,rax
    1d0c:	je     1d6f <botlish_fn_19+0xff>
    1d12:	mov    QWORD PTR [rsp+0x10],rax
    1d17:	mov    rcx,rax
    1d1a:	mov    r8d,0x3
    1d20:	mov    QWORD PTR [rsp+0x18],0x3
    1d29:	mov    rdx,r13
    1d2c:	mov    rsi,r12
    1d2f:	mov    rdi,rbx
    1d32:	call   1d37 <botlish_fn_19+0xc7>
			1d33: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1d37:	test   rax,rax
    1d3a:	je     1d6f <botlish_fn_19+0xff>
    1d40:	mov    rbx,QWORD PTR [rsp+0x20]
    1d45:	mov    r12,QWORD PTR [rsp+0x28]
    1d4a:	mov    r13,QWORD PTR [rsp+0x30]
    1d4f:	add    rsp,0x40
    1d53:	mov    rsp,rbp
    1d56:	pop    rbp
    1d57:	ret
    1d58:	xor    rdx,rdx
    1d5b:	mov    rdi,rbx
    1d5e:	mov    rsi,rdx
    1d61:	call   1d66 <botlish_fn_19+0xf6>
			1d62: R_X86_64_PLT32	rt_list_new-0x4
    1d66:	test   rax,rax
    1d69:	jne    1d8a <botlish_fn_19+0x11a>
    1d6f:	xor    rax,rax
    1d72:	mov    rbx,QWORD PTR [rsp+0x20]
    1d77:	mov    r12,QWORD PTR [rsp+0x28]
    1d7c:	mov    r13,QWORD PTR [rsp+0x30]
    1d81:	add    rsp,0x40
    1d85:	mov    rsp,rbp
    1d88:	pop    rbp
    1d89:	ret
    1d8a:	mov    rbx,QWORD PTR [rsp+0x20]
    1d8f:	mov    r12,QWORD PTR [rsp+0x28]
    1d94:	mov    r13,QWORD PTR [rsp+0x30]
    1d99:	add    rsp,0x40
    1d9d:	mov    rsp,rbp
    1da0:	pop    rbp
    1da1:	ret

0000000000001da2 <botlish_entry_19: csv_parse<str>>:
    1da2:	push   rbp
    1da3:	mov    rbp,rsp
    1da6:	mov    rsi,QWORD PTR [rdx]
    1da9:	call   1dae <botlish_entry_19+0xc>
			1daa: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    1dae:	mov    rsp,rbp
    1db1:	pop    rbp
    1db2:	ret

; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 7365  (per function: 176 184 485 541 422 422 198 501 558 698 913 482 886 616 283)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> geo_new<generic>
;   botlish_fn_2 / botlish_entry_2 -> geo_new_capacity<int, int>
;   botlish_fn_3 / botlish_entry_3 -> geo_grow<mutarray, int>
;   botlish_fn_4 / botlish_entry_4 -> geo_append<list[mutarray, int], str>
;   botlish_fn_5 / botlish_entry_5 -> geo_append<list[mutarray, int], list>
;   botlish_fn_6 / botlish_entry_6 -> geo_finish<list[mutarray, int]>
;   botlish_fn_7 / botlish_entry_7 -> peek<str, int>
;   botlish_fn_8 / botlish_entry_8 -> peek<str, int>
;   botlish_fn_9 / botlish_entry_9 -> scan_unquoted<str, int, int>
;   botlish_fn_10 / botlish_entry_10 -> scan_quoted<str, int, str>
;   botlish_fn_11 / botlish_entry_11 -> scan_field<str, int>
;   botlish_fn_12 / botlish_entry_12 -> scan_record<str, int, list[mutarray, int]>
;   botlish_fn_13 / botlish_entry_13 -> scan_records<str, int, list[mutarray, int]>
;   botlish_fn_14 / botlish_entry_14 -> csv_parse<str>


csv_geometric.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x10
       8:	mov    QWORD PTR [rsp],r13
       c:	mov    QWORD PTR [rsp+0x8],r14
      11:	mov    r13,QWORD PTR [rdi]
      14:	mov    rax,QWORD PTR [rdi+0x8]
      18:	lea    rcx,[r13+0x8]
      1c:	cmp    rcx,rax
      1f:	ja     83 <botlish_fn_0+0x83>
      25:	lea    rax,[r13+0x8]
      29:	mov    QWORD PTR [rdi],rax
      2c:	mov    QWORD PTR [r13+0x0],0x0
      34:	mov    rax,QWORD PTR [rdi+0x10]
      38:	mov    r14,rdi
      3b:	mov    rsi,QWORD PTR [rax]
      3e:	mov    QWORD PTR [r13+0x0],rsi
      42:	call   47 <botlish_fn_0+0x47>
			43: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
      47:	test   rax,rax
      4a:	jne    6b <botlish_fn_0+0x6b>
      50:	mov    rdi,r14
      53:	mov    QWORD PTR [rdi],r13
      56:	xor    rax,rax
      59:	mov    r13,QWORD PTR [rsp]
      5d:	mov    r14,QWORD PTR [rsp+0x8]
      62:	add    rsp,0x10
      66:	mov    rsp,rbp
      69:	pop    rbp
      6a:	ret
      6b:	mov    rdi,r14
      6e:	mov    QWORD PTR [rdi],r13
      71:	mov    r13,QWORD PTR [rsp]
      75:	mov    r14,QWORD PTR [rsp+0x8]
      7a:	add    rsp,0x10
      7e:	mov    rsp,rbp
      81:	pop    rbp
      82:	ret
      83:	call   88 <botlish_fn_0+0x88>
			84: R_X86_64_PLT32	rt_stack_overflow-0x4
      88:	xor    rax,rax
      8b:	mov    r13,QWORD PTR [rsp]
      8f:	mov    r14,QWORD PTR [rsp+0x8]
      94:	add    rsp,0x10
      98:	mov    rsp,rbp
      9b:	pop    rbp
      9c:	ret

000000000000009d <botlish_entry_0: <program entry>>:
      9d:	push   rbp
      9e:	mov    rbp,rsp
      a1:	call   a6 <botlish_entry_0+0x9>
			a2: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      a6:	mov    rsp,rbp
      a9:	pop    rbp
      aa:	ret

00000000000000ab <botlish_fn_1: geo_new<generic>>:
      ab:	push   rbp
      ac:	mov    rbp,rsp
      af:	sub    rsp,0x10
      b3:	mov    QWORD PTR [rsp],r13
      b7:	mov    QWORD PTR [rsp+0x8],r14
      bc:	mov    r13,QWORD PTR [rdi]
      bf:	mov    rax,QWORD PTR [rdi+0x8]
      c3:	lea    rcx,[r13+0x8]
      c7:	cmp    rcx,rax
      ca:	ja     133 <botlish_fn_1+0x88>
      d0:	lea    rax,[r13+0x8]
      d4:	mov    QWORD PTR [rdi],rax
      d7:	mov    r14,rdi
      da:	mov    esi,0x1
      df:	mov    QWORD PTR [r13+0x0],0x1
      e7:	mov    rdi,r14
      ea:	call   ef <botlish_fn_1+0x44>
			eb: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      ef:	test   rax,rax
      f2:	jne    116 <botlish_fn_1+0x6b>
      f8:	mov    rdi,r14
      fb:	mov    QWORD PTR [rdi],r13
      fe:	xor    rdx,rdx
     101:	mov    rax,rdx
     104:	mov    r13,QWORD PTR [rsp]
     108:	mov    r14,QWORD PTR [rsp+0x8]
     10d:	add    rsp,0x10
     111:	mov    rsp,rbp
     114:	pop    rbp
     115:	ret
     116:	mov    rdi,r14
     119:	mov    QWORD PTR [rdi],r13
     11c:	mov    edx,0x1
     121:	mov    r13,QWORD PTR [rsp]
     125:	mov    r14,QWORD PTR [rsp+0x8]
     12a:	add    rsp,0x10
     12e:	mov    rsp,rbp
     131:	pop    rbp
     132:	ret
     133:	call   138 <botlish_fn_1+0x8d>
			134: R_X86_64_PLT32	rt_stack_overflow-0x4
     138:	xor    rdx,rdx
     13b:	mov    rax,rdx
     13e:	mov    r13,QWORD PTR [rsp]
     142:	mov    r14,QWORD PTR [rsp+0x8]
     147:	add    rsp,0x10
     14b:	mov    rsp,rbp
     14e:	pop    rbp
     14f:	ret

0000000000000150 <botlish_entry_1: geo_new<generic>>:
     150:	push   rbp
     151:	mov    rbp,rsp
     154:	ud2
	...

0000000000000158 <botlish_fn_2: geo_new_capacity<int, int>>:
     158:	push   rbp
     159:	mov    rbp,rsp
     15c:	sub    rsp,0x20
     160:	mov    QWORD PTR [rsp],rbx
     164:	mov    QWORD PTR [rsp+0x8],r12
     169:	mov    QWORD PTR [rsp+0x10],r13
     16e:	mov    QWORD PTR [rsp+0x18],r14
     173:	mov    rbx,QWORD PTR [rdi]
     176:	mov    rax,QWORD PTR [rdi+0x8]
     17a:	lea    rcx,[rbx+0x18]
     17e:	cmp    rcx,rax
     181:	ja     2ce <botlish_fn_2+0x176>
     187:	lea    rax,[rbx+0x18]
     18b:	mov    QWORD PTR [rdi],rax
     18e:	mov    r13,rdi
     191:	mov    QWORD PTR [rbx],0x0
     198:	mov    QWORD PTR [rbx+0x8],0x0
     1a0:	mov    QWORD PTR [rbx+0x10],0x0
     1a8:	mov    QWORD PTR [rbx],rsi
     1ab:	mov    QWORD PTR [rbx+0x8],rdx
     1af:	mov    r12,rdx
     1b2:	mov    QWORD PTR [rbx+0x10],0x5
     1ba:	test   rsi,0x1
     1c1:	je     1e3 <botlish_fn_2+0x8b>
     1c7:	mov    rax,rsi
     1ca:	sar    rax,1
     1cd:	imul   QWORD PTR [rip+0x124]        # 2f8 <botlish_fn_2+0x1a0>
     1d4:	seto   cl
     1d7:	or     rax,0x1
     1db:	test   cl,cl
     1dd:	je     1f0 <botlish_fn_2+0x98>
     1e3:	mov    edx,0x5
     1e8:	mov    rdi,r13
     1eb:	call   1f0 <botlish_fn_2+0x98>
			1ec: R_X86_64_PLT32	rt_int_mul-0x4
     1f0:	mov    rcx,rax
     1f3:	and    rcx,r12
     1f6:	mov    r14,rax
     1f9:	test   rcx,0x1
     200:	jne    22c <botlish_fn_2+0xd4>
     206:	mov    rdx,r12
     209:	mov    rsi,r14
     20c:	mov    rdi,r13
     20f:	call   214 <botlish_fn_2+0xbc>
			210: R_X86_64_PLT32	rt_int_cmp-0x4
     214:	mov    ecx,0x2
     219:	test   rax,rax
     21c:	cmovle rcx,QWORD PTR [rip+0xdc]        # 300 <botlish_fn_2+0x1a8>
     224:	mov    rax,r14
     227:	jmp    23f <botlish_fn_2+0xe7>
     22c:	mov    ecx,0x2
     231:	mov    rax,r14
     234:	cmp    rax,r12
     237:	cmovle rcx,QWORD PTR [rip+0xc1]        # 300 <botlish_fn_2+0x1a8>
     23f:	cmp    rcx,0x6
     243:	je     26b <botlish_fn_2+0x113>
     249:	mov    rdi,r13
     24c:	mov    QWORD PTR [rdi],rbx
     24f:	mov    rbx,QWORD PTR [rsp]
     253:	mov    r12,QWORD PTR [rsp+0x8]
     258:	mov    r13,QWORD PTR [rsp+0x10]
     25d:	mov    r14,QWORD PTR [rsp+0x18]
     262:	add    rsp,0x20
     266:	mov    rsp,rbp
     269:	pop    rbp
     26a:	ret
     26b:	mov    QWORD PTR [rbx],0x3
     272:	test   r12,0x1
     279:	je     299 <botlish_fn_2+0x141>
     27f:	mov    rax,r12
     282:	add    rax,0x2
     286:	seto   cl
     289:	test   cl,cl
     28b:	jne    299 <botlish_fn_2+0x141>
     291:	mov    rdi,r13
     294:	jmp    2ac <botlish_fn_2+0x154>
     299:	mov    edx,0x3
     29e:	mov    rsi,r12
     2a1:	mov    rdi,r13
     2a4:	call   2a9 <botlish_fn_2+0x151>
			2a5: R_X86_64_PLT32	rt_int_add-0x4
     2a9:	mov    rdi,r13
     2ac:	mov    rdi,r13
     2af:	mov    QWORD PTR [rdi],rbx
     2b2:	mov    rbx,QWORD PTR [rsp]
     2b6:	mov    r12,QWORD PTR [rsp+0x8]
     2bb:	mov    r13,QWORD PTR [rsp+0x10]
     2c0:	mov    r14,QWORD PTR [rsp+0x18]
     2c5:	add    rsp,0x20
     2c9:	mov    rsp,rbp
     2cc:	pop    rbp
     2cd:	ret
     2ce:	mov    r13,rdi
     2d1:	call   2d6 <botlish_fn_2+0x17e>
			2d2: R_X86_64_PLT32	rt_stack_overflow-0x4
     2d6:	xor    rax,rax
     2d9:	mov    rbx,QWORD PTR [rsp]
     2dd:	mov    r12,QWORD PTR [rsp+0x8]
     2e2:	mov    r13,QWORD PTR [rsp+0x10]
     2e7:	mov    r14,QWORD PTR [rsp+0x18]
     2ec:	add    rsp,0x20
     2f0:	mov    rsp,rbp
     2f3:	pop    rbp
     2f4:	ret
     2f5:	add    BYTE PTR [rax],al
     2f7:	add    BYTE PTR [rax+rax*1],al
     2fa:	add    BYTE PTR [rax],al
     2fc:	add    BYTE PTR [rax],al
     2fe:	add    BYTE PTR [rax],al
     300:	(bad)
     301:	add    BYTE PTR [rax],al
     303:	add    BYTE PTR [rax],al
     305:	add    BYTE PTR [rax],al
	...

0000000000000308 <botlish_entry_2: geo_new_capacity<int, int>>:
     308:	push   rbp
     309:	mov    rbp,rsp
     30c:	mov    rsi,QWORD PTR [rdx]
     30f:	mov    rdx,QWORD PTR [rdx+0x8]
     313:	call   318 <botlish_entry_2+0x10>
			314: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     318:	mov    rsp,rbp
     31b:	pop    rbp
     31c:	ret
     31d:	add    BYTE PTR [rax],al
	...

0000000000000320 <botlish_fn_3: geo_grow<mutarray, int>>:
     320:	push   rbp
     321:	mov    rbp,rsp
     324:	sub    rsp,0x30
     328:	mov    QWORD PTR [rsp],rbx
     32c:	mov    QWORD PTR [rsp+0x8],r12
     331:	mov    QWORD PTR [rsp+0x10],r13
     336:	mov    QWORD PTR [rsp+0x18],r14
     33b:	mov    QWORD PTR [rsp+0x20],r15
     340:	mov    rbx,QWORD PTR [rdi]
     343:	mov    rax,QWORD PTR [rdi+0x8]
     347:	lea    rcx,[rbx+0x18]
     34b:	cmp    rcx,rax
     34e:	ja     4d0 <botlish_fn_3+0x1b0>
     354:	lea    rax,[rbx+0x18]
     358:	mov    QWORD PTR [rdi],rax
     35b:	mov    r13,rdi
     35e:	mov    QWORD PTR [rbx],0x0
     365:	mov    QWORD PTR [rbx+0x8],0x0
     36d:	mov    QWORD PTR [rbx+0x10],0x0
     375:	mov    QWORD PTR [rbx],rsi
     378:	mov    r14,rsi
     37b:	mov    QWORD PTR [rbx+0x8],rdx
     37f:	mov    r12,rdx
     382:	mov    rsi,r14
     385:	mov    rdi,r13
     388:	call   38d <botlish_fn_3+0x6d>
			389: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     38d:	mov    r15,rax
     390:	mov    QWORD PTR [rbx+0x10],rax
     394:	mov    rcx,r12
     397:	and    rcx,rax
     39a:	test   rcx,0x1
     3a1:	jne    3cd <botlish_fn_3+0xad>
     3a7:	mov    rdx,r15
     3aa:	mov    rsi,r12
     3ad:	mov    rdi,r13
     3b0:	call   3b5 <botlish_fn_3+0x95>
			3b1: R_X86_64_PLT32	rt_int_cmp-0x4
     3b5:	mov    ecx,0x2
     3ba:	test   rax,rax
     3bd:	cmovl  rcx,QWORD PTR [rip+0x13b]        # 500 <botlish_fn_3+0x1e0>
     3c5:	mov    rax,r15
     3c8:	jmp    3e0 <botlish_fn_3+0xc0>
     3cd:	mov    ecx,0x2
     3d2:	mov    rax,r15
     3d5:	cmp    r12,rax
     3d8:	cmovl  rcx,QWORD PTR [rip+0x120]        # 500 <botlish_fn_3+0x1e0>
     3e0:	cmp    rcx,0x6
     3e4:	je     4a6 <botlish_fn_3+0x186>
     3ea:	mov    rsi,rax
     3ed:	mov    rdx,r12
     3f0:	mov    rdi,r13
     3f3:	call   3f8 <botlish_fn_3+0xd8>
			3f4: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     3f8:	test   rax,rax
     3fb:	jne    409 <botlish_fn_3+0xe9>
     401:	mov    rdi,r13
     404:	jmp    452 <botlish_fn_3+0x132>
     409:	mov    QWORD PTR [rbx+0x10],rax
     40d:	mov    rsi,rax
     410:	mov    rdi,r13
     413:	call   418 <botlish_fn_3+0xf8>
			414: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     418:	test   rax,rax
     41b:	mov    r15,rax
     41e:	jne    42c <botlish_fn_3+0x10c>
     424:	mov    rdi,r13
     427:	jmp    452 <botlish_fn_3+0x132>
     42c:	mov    r8d,0x1
     432:	mov    rcx,r14
     435:	mov    r9,r12
     438:	mov    rsi,r15
     43b:	mov    rdi,r13
     43e:	mov    rdx,r8
     441:	call   446 <botlish_fn_3+0x126>
			442: R_X86_64_PLT32	rt_mutarray_copy-0x4
     446:	test   rax,rax
     449:	jne    47c <botlish_fn_3+0x15c>
     44f:	mov    rdi,r13
     452:	mov    rdi,r13
     455:	mov    QWORD PTR [rdi],rbx
     458:	xor    rax,rax
     45b:	mov    rbx,QWORD PTR [rsp]
     45f:	mov    r12,QWORD PTR [rsp+0x8]
     464:	mov    r13,QWORD PTR [rsp+0x10]
     469:	mov    r14,QWORD PTR [rsp+0x18]
     46e:	mov    r15,QWORD PTR [rsp+0x20]
     473:	add    rsp,0x30
     477:	mov    rsp,rbp
     47a:	pop    rbp
     47b:	ret
     47c:	mov    rdi,r13
     47f:	mov    QWORD PTR [rdi],rbx
     482:	mov    rax,r15
     485:	mov    rbx,QWORD PTR [rsp]
     489:	mov    r12,QWORD PTR [rsp+0x8]
     48e:	mov    r13,QWORD PTR [rsp+0x10]
     493:	mov    r14,QWORD PTR [rsp+0x18]
     498:	mov    r15,QWORD PTR [rsp+0x20]
     49d:	add    rsp,0x30
     4a1:	mov    rsp,rbp
     4a4:	pop    rbp
     4a5:	ret
     4a6:	mov    rdi,r13
     4a9:	mov    QWORD PTR [rdi],rbx
     4ac:	mov    rax,r14
     4af:	mov    rbx,QWORD PTR [rsp]
     4b3:	mov    r12,QWORD PTR [rsp+0x8]
     4b8:	mov    r13,QWORD PTR [rsp+0x10]
     4bd:	mov    r14,QWORD PTR [rsp+0x18]
     4c2:	mov    r15,QWORD PTR [rsp+0x20]
     4c7:	add    rsp,0x30
     4cb:	mov    rsp,rbp
     4ce:	pop    rbp
     4cf:	ret
     4d0:	mov    r13,rdi
     4d3:	call   4d8 <botlish_fn_3+0x1b8>
			4d4: R_X86_64_PLT32	rt_stack_overflow-0x4
     4d8:	xor    rax,rax
     4db:	mov    rbx,QWORD PTR [rsp]
     4df:	mov    r12,QWORD PTR [rsp+0x8]
     4e4:	mov    r13,QWORD PTR [rsp+0x10]
     4e9:	mov    r14,QWORD PTR [rsp+0x18]
     4ee:	mov    r15,QWORD PTR [rsp+0x20]
     4f3:	add    rsp,0x30
     4f7:	mov    rsp,rbp
     4fa:	pop    rbp
     4fb:	ret
     4fc:	add    BYTE PTR [rax],al
     4fe:	add    BYTE PTR [rax],al
     500:	(bad)
     501:	add    BYTE PTR [rax],al
     503:	add    BYTE PTR [rax],al
     505:	add    BYTE PTR [rax],al
	...

0000000000000508 <botlish_entry_3: geo_grow<mutarray, int>>:
     508:	push   rbp
     509:	mov    rbp,rsp
     50c:	mov    rsi,QWORD PTR [rdx]
     50f:	mov    rdx,QWORD PTR [rdx+0x8]
     513:	call   518 <botlish_entry_3+0x10>
			514: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     518:	mov    rsp,rbp
     51b:	pop    rbp
     51c:	ret

000000000000051d <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     51d:	push   rbp
     51e:	mov    rbp,rsp
     521:	sub    rsp,0x30
     525:	mov    QWORD PTR [rsp],rbx
     529:	mov    QWORD PTR [rsp+0x8],r12
     52e:	mov    QWORD PTR [rsp+0x10],r13
     533:	mov    QWORD PTR [rsp+0x18],r14
     538:	mov    QWORD PTR [rsp+0x20],r15
     53d:	mov    r12,QWORD PTR [rdi]
     540:	mov    r8,QWORD PTR [rdi+0x8]
     544:	lea    rax,[r12+0x18]
     549:	cmp    rax,r8
     54c:	ja     679 <botlish_fn_4+0x15c>
     552:	lea    rax,[r12+0x18]
     557:	mov    QWORD PTR [rdi],rax
     55a:	mov    r13,rdi
     55d:	mov    QWORD PTR [r12],0x0
     565:	mov    QWORD PTR [r12+0x8],0x0
     56e:	mov    QWORD PTR [r12+0x10],0x0
     577:	mov    QWORD PTR [r12],rsi
     57b:	mov    QWORD PTR [r12+0x8],rdx
     580:	mov    rdi,rdx
     583:	mov    QWORD PTR [r12+0x10],rcx
     588:	mov    r15,rcx
     58b:	mov    rbx,rdi
     58e:	mov    rdx,rbx
     591:	mov    rdi,r13
     594:	call   599 <botlish_fn_4+0x7c>
			595: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     599:	test   rax,rax
     59c:	mov    r14,rax
     59f:	jne    5ad <botlish_fn_4+0x90>
     5a5:	mov    rdi,r13
     5a8:	jmp    5d1 <botlish_fn_4+0xb4>
     5ad:	mov    rax,r14
     5b0:	mov    QWORD PTR [r12],rax
     5b4:	mov    rcx,r15
     5b7:	mov    rdx,rbx
     5ba:	mov    rsi,r14
     5bd:	mov    rdi,r13
     5c0:	call   5c5 <botlish_fn_4+0xa8>
			5c1: R_X86_64_PLT32	rt_mutarray_set-0x4
     5c5:	test   rax,rax
     5c8:	jne    5fe <botlish_fn_4+0xe1>
     5ce:	mov    rdi,r13
     5d1:	mov    rdi,r13
     5d4:	mov    QWORD PTR [rdi],r12
     5d7:	xor    rdx,rdx
     5da:	mov    rax,rdx
     5dd:	mov    rbx,QWORD PTR [rsp]
     5e1:	mov    r12,QWORD PTR [rsp+0x8]
     5e6:	mov    r13,QWORD PTR [rsp+0x10]
     5eb:	mov    r14,QWORD PTR [rsp+0x18]
     5f0:	mov    r15,QWORD PTR [rsp+0x20]
     5f5:	add    rsp,0x30
     5f9:	mov    rsp,rbp
     5fc:	pop    rbp
     5fd:	ret
     5fe:	mov    QWORD PTR [r12+0x10],0x3
     607:	test   rbx,0x1
     60e:	jne    61c <botlish_fn_4+0xff>
     614:	mov    rdi,rbx
     617:	jmp    639 <botlish_fn_4+0x11c>
     61c:	mov    rdx,rbx
     61f:	add    rdx,0x2
     623:	mov    rdi,rbx
     626:	seto   al
     629:	test   al,al
     62b:	jne    639 <botlish_fn_4+0x11c>
     631:	mov    rdi,r13
     634:	jmp    64f <botlish_fn_4+0x132>
     639:	mov    edx,0x3
     63e:	mov    rsi,rdi
     641:	mov    rdi,r13
     644:	call   649 <botlish_fn_4+0x12c>
			645: R_X86_64_PLT32	rt_int_add-0x4
     649:	mov    rdx,rax
     64c:	mov    rdi,r13
     64f:	mov    rdi,r13
     652:	mov    QWORD PTR [rdi],r12
     655:	mov    rax,r14
     658:	mov    rbx,QWORD PTR [rsp]
     65c:	mov    r12,QWORD PTR [rsp+0x8]
     661:	mov    r13,QWORD PTR [rsp+0x10]
     666:	mov    r14,QWORD PTR [rsp+0x18]
     66b:	mov    r15,QWORD PTR [rsp+0x20]
     670:	add    rsp,0x30
     674:	mov    rsp,rbp
     677:	pop    rbp
     678:	ret
     679:	mov    r13,rdi
     67c:	call   681 <botlish_fn_4+0x164>
			67d: R_X86_64_PLT32	rt_stack_overflow-0x4
     681:	xor    rdx,rdx
     684:	mov    rax,rdx
     687:	mov    rbx,QWORD PTR [rsp]
     68b:	mov    r12,QWORD PTR [rsp+0x8]
     690:	mov    r13,QWORD PTR [rsp+0x10]
     695:	mov    r14,QWORD PTR [rsp+0x18]
     69a:	mov    r15,QWORD PTR [rsp+0x20]
     69f:	add    rsp,0x30
     6a3:	mov    rsp,rbp
     6a6:	pop    rbp
     6a7:	ret

00000000000006a8 <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     6a8:	push   rbp
     6a9:	mov    rbp,rsp
     6ac:	ud2

00000000000006ae <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     6ae:	push   rbp
     6af:	mov    rbp,rsp
     6b2:	sub    rsp,0x30
     6b6:	mov    QWORD PTR [rsp],rbx
     6ba:	mov    QWORD PTR [rsp+0x8],r12
     6bf:	mov    QWORD PTR [rsp+0x10],r13
     6c4:	mov    QWORD PTR [rsp+0x18],r14
     6c9:	mov    QWORD PTR [rsp+0x20],r15
     6ce:	mov    r12,QWORD PTR [rdi]
     6d1:	mov    r8,QWORD PTR [rdi+0x8]
     6d5:	lea    rax,[r12+0x18]
     6da:	cmp    rax,r8
     6dd:	ja     80a <botlish_fn_5+0x15c>
     6e3:	lea    rax,[r12+0x18]
     6e8:	mov    QWORD PTR [rdi],rax
     6eb:	mov    r13,rdi
     6ee:	mov    QWORD PTR [r12],0x0
     6f6:	mov    QWORD PTR [r12+0x8],0x0
     6ff:	mov    QWORD PTR [r12+0x10],0x0
     708:	mov    QWORD PTR [r12],rsi
     70c:	mov    QWORD PTR [r12+0x8],rdx
     711:	mov    rdi,rdx
     714:	mov    QWORD PTR [r12+0x10],rcx
     719:	mov    r15,rcx
     71c:	mov    rbx,rdi
     71f:	mov    rdx,rbx
     722:	mov    rdi,r13
     725:	call   72a <botlish_fn_5+0x7c>
			726: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     72a:	test   rax,rax
     72d:	mov    r14,rax
     730:	jne    73e <botlish_fn_5+0x90>
     736:	mov    rdi,r13
     739:	jmp    762 <botlish_fn_5+0xb4>
     73e:	mov    rax,r14
     741:	mov    QWORD PTR [r12],rax
     745:	mov    rcx,r15
     748:	mov    rdx,rbx
     74b:	mov    rsi,r14
     74e:	mov    rdi,r13
     751:	call   756 <botlish_fn_5+0xa8>
			752: R_X86_64_PLT32	rt_mutarray_set-0x4
     756:	test   rax,rax
     759:	jne    78f <botlish_fn_5+0xe1>
     75f:	mov    rdi,r13
     762:	mov    rdi,r13
     765:	mov    QWORD PTR [rdi],r12
     768:	xor    rdx,rdx
     76b:	mov    rax,rdx
     76e:	mov    rbx,QWORD PTR [rsp]
     772:	mov    r12,QWORD PTR [rsp+0x8]
     777:	mov    r13,QWORD PTR [rsp+0x10]
     77c:	mov    r14,QWORD PTR [rsp+0x18]
     781:	mov    r15,QWORD PTR [rsp+0x20]
     786:	add    rsp,0x30
     78a:	mov    rsp,rbp
     78d:	pop    rbp
     78e:	ret
     78f:	mov    QWORD PTR [r12+0x10],0x3
     798:	test   rbx,0x1
     79f:	jne    7ad <botlish_fn_5+0xff>
     7a5:	mov    rdi,rbx
     7a8:	jmp    7ca <botlish_fn_5+0x11c>
     7ad:	mov    rdx,rbx
     7b0:	add    rdx,0x2
     7b4:	mov    rdi,rbx
     7b7:	seto   al
     7ba:	test   al,al
     7bc:	jne    7ca <botlish_fn_5+0x11c>
     7c2:	mov    rdi,r13
     7c5:	jmp    7e0 <botlish_fn_5+0x132>
     7ca:	mov    edx,0x3
     7cf:	mov    rsi,rdi
     7d2:	mov    rdi,r13
     7d5:	call   7da <botlish_fn_5+0x12c>
			7d6: R_X86_64_PLT32	rt_int_add-0x4
     7da:	mov    rdx,rax
     7dd:	mov    rdi,r13
     7e0:	mov    rdi,r13
     7e3:	mov    QWORD PTR [rdi],r12
     7e6:	mov    rax,r14
     7e9:	mov    rbx,QWORD PTR [rsp]
     7ed:	mov    r12,QWORD PTR [rsp+0x8]
     7f2:	mov    r13,QWORD PTR [rsp+0x10]
     7f7:	mov    r14,QWORD PTR [rsp+0x18]
     7fc:	mov    r15,QWORD PTR [rsp+0x20]
     801:	add    rsp,0x30
     805:	mov    rsp,rbp
     808:	pop    rbp
     809:	ret
     80a:	mov    r13,rdi
     80d:	call   812 <botlish_fn_5+0x164>
			80e: R_X86_64_PLT32	rt_stack_overflow-0x4
     812:	xor    rdx,rdx
     815:	mov    rax,rdx
     818:	mov    rbx,QWORD PTR [rsp]
     81c:	mov    r12,QWORD PTR [rsp+0x8]
     821:	mov    r13,QWORD PTR [rsp+0x10]
     826:	mov    r14,QWORD PTR [rsp+0x18]
     82b:	mov    r15,QWORD PTR [rsp+0x20]
     830:	add    rsp,0x30
     834:	mov    rsp,rbp
     837:	pop    rbp
     838:	ret

0000000000000839 <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     839:	push   rbp
     83a:	mov    rbp,rsp
     83d:	ud2

000000000000083f <botlish_fn_6: geo_finish<list[mutarray, int]>>:
     83f:	push   rbp
     840:	mov    rbp,rsp
     843:	sub    rsp,0x10
     847:	mov    QWORD PTR [rsp],r13
     84b:	mov    QWORD PTR [rsp+0x8],r14
     850:	mov    r13,QWORD PTR [rdi]
     853:	mov    rax,QWORD PTR [rdi+0x8]
     857:	lea    rcx,[r13+0x10]
     85b:	cmp    rcx,rax
     85e:	ja     8ca <botlish_fn_6+0x8b>
     864:	lea    rax,[r13+0x10]
     868:	mov    QWORD PTR [rdi],rax
     86b:	mov    r14,rdi
     86e:	mov    QWORD PTR [r13+0x0],0x0
     876:	mov    QWORD PTR [r13+0x8],0x0
     87e:	mov    QWORD PTR [r13+0x0],rsi
     882:	mov    QWORD PTR [r13+0x8],rdx
     886:	mov    rdi,r14
     889:	call   88e <botlish_fn_6+0x4f>
			88a: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     88e:	test   rax,rax
     891:	jne    8b2 <botlish_fn_6+0x73>
     897:	mov    rdi,r14
     89a:	mov    QWORD PTR [rdi],r13
     89d:	xor    rax,rax
     8a0:	mov    r13,QWORD PTR [rsp]
     8a4:	mov    r14,QWORD PTR [rsp+0x8]
     8a9:	add    rsp,0x10
     8ad:	mov    rsp,rbp
     8b0:	pop    rbp
     8b1:	ret
     8b2:	mov    rdi,r14
     8b5:	mov    QWORD PTR [rdi],r13
     8b8:	mov    r13,QWORD PTR [rsp]
     8bc:	mov    r14,QWORD PTR [rsp+0x8]
     8c1:	add    rsp,0x10
     8c5:	mov    rsp,rbp
     8c8:	pop    rbp
     8c9:	ret
     8ca:	call   8cf <botlish_fn_6+0x90>
			8cb: R_X86_64_PLT32	rt_stack_overflow-0x4
     8cf:	xor    rax,rax
     8d2:	mov    r13,QWORD PTR [rsp]
     8d6:	mov    r14,QWORD PTR [rsp+0x8]
     8db:	add    rsp,0x10
     8df:	mov    rsp,rbp
     8e2:	pop    rbp
     8e3:	ret

00000000000008e4 <botlish_entry_6: geo_finish<list[mutarray, int]>>:
     8e4:	push   rbp
     8e5:	mov    rbp,rsp
     8e8:	mov    rsi,QWORD PTR [rdx]
     8eb:	mov    rdx,QWORD PTR [rdx+0x8]
     8ef:	call   8f4 <botlish_entry_6+0x10>
			8f0: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
     8f4:	mov    rsp,rbp
     8f7:	pop    rbp
     8f8:	ret
     8f9:	add    BYTE PTR [rax],al
     8fb:	add    BYTE PTR [rax],al
     8fd:	add    BYTE PTR [rax],al
	...

0000000000000900 <botlish_fn_7: peek<str, int>>:
     900:	push   rbp
     901:	mov    rbp,rsp
     904:	sub    rsp,0x20
     908:	mov    QWORD PTR [rsp],rbx
     90c:	mov    QWORD PTR [rsp+0x8],r12
     911:	mov    QWORD PTR [rsp+0x10],r13
     916:	mov    QWORD PTR [rsp+0x18],r14
     91b:	mov    r12,QWORD PTR [rdi]
     91e:	mov    rax,QWORD PTR [rdi+0x8]
     922:	lea    rcx,[r12+0x18]
     927:	cmp    rcx,rax
     92a:	ja     a87 <botlish_fn_7+0x187>
     930:	lea    rax,[r12+0x18]
     935:	mov    QWORD PTR [rdi],rax
     938:	mov    r13,rdi
     93b:	mov    QWORD PTR [r12],0x0
     943:	mov    QWORD PTR [r12+0x8],0x0
     94c:	mov    QWORD PTR [r12+0x10],0x0
     955:	mov    QWORD PTR [r12],rsi
     959:	mov    r14,rsi
     95c:	mov    QWORD PTR [r12+0x8],rdx
     961:	mov    rbx,rdx
     964:	mov    rsi,r14
     967:	mov    rdi,r13
     96a:	call   96f <botlish_fn_7+0x6f>
			96b: R_X86_64_PLT32	rt_str_len-0x4
     96f:	mov    rcx,rbx
     972:	and    rcx,rax
     975:	mov    rdx,rax
     978:	test   rcx,0x1
     97f:	jne    9a5 <botlish_fn_7+0xa5>
     985:	mov    rsi,rbx
     988:	mov    rdi,r13
     98b:	call   990 <botlish_fn_7+0x90>
			98c: R_X86_64_PLT32	rt_int_cmp-0x4
     990:	mov    ecx,0x2
     995:	test   rax,rax
     998:	cmovge rcx,QWORD PTR [rip+0x110]        # ab0 <botlish_fn_7+0x1b0>
     9a0:	jmp    9b5 <botlish_fn_7+0xb5>
     9a5:	mov    ecx,0x2
     9aa:	cmp    rbx,rdx
     9ad:	cmovge rcx,QWORD PTR [rip+0xfb]        # ab0 <botlish_fn_7+0x1b0>
     9b5:	cmp    rcx,0x6
     9b9:	je     a5d <botlish_fn_7+0x15d>
     9bf:	mov    QWORD PTR [r12+0x10],0x3
     9c8:	test   rbx,0x1
     9cf:	je     9e7 <botlish_fn_7+0xe7>
     9d5:	mov    rcx,rbx
     9d8:	add    rcx,0x2
     9dc:	seto   al
     9df:	test   al,al
     9e1:	je     9fa <botlish_fn_7+0xfa>
     9e7:	mov    edx,0x3
     9ec:	mov    rsi,rbx
     9ef:	mov    rdi,r13
     9f2:	call   9f7 <botlish_fn_7+0xf7>
			9f3: R_X86_64_PLT32	rt_int_add-0x4
     9f7:	mov    rcx,rax
     9fa:	mov    QWORD PTR [r12+0x10],rcx
     9ff:	mov    rdx,rbx
     a02:	mov    rsi,r14
     a05:	mov    rdi,r13
     a08:	call   a0d <botlish_fn_7+0x10d>
			a09: R_X86_64_PLT32	rt_substr-0x4
     a0d:	test   rax,rax
     a10:	jne    a3b <botlish_fn_7+0x13b>
     a16:	mov    rdi,r13
     a19:	mov    QWORD PTR [rdi],r12
     a1c:	xor    rax,rax
     a1f:	mov    rbx,QWORD PTR [rsp]
     a23:	mov    r12,QWORD PTR [rsp+0x8]
     a28:	mov    r13,QWORD PTR [rsp+0x10]
     a2d:	mov    r14,QWORD PTR [rsp+0x18]
     a32:	add    rsp,0x20
     a36:	mov    rsp,rbp
     a39:	pop    rbp
     a3a:	ret
     a3b:	mov    rdi,r13
     a3e:	mov    QWORD PTR [rdi],r12
     a41:	mov    rbx,QWORD PTR [rsp]
     a45:	mov    r12,QWORD PTR [rsp+0x8]
     a4a:	mov    r13,QWORD PTR [rsp+0x10]
     a4f:	mov    r14,QWORD PTR [rsp+0x18]
     a54:	add    rsp,0x20
     a58:	mov    rsp,rbp
     a5b:	pop    rbp
     a5c:	ret
     a5d:	mov    rdi,r13
     a60:	mov    rax,QWORD PTR [rdi+0x10]
     a64:	mov    rax,QWORD PTR [rax+0x8]
     a68:	mov    QWORD PTR [rdi],r12
     a6b:	mov    rbx,QWORD PTR [rsp]
     a6f:	mov    r12,QWORD PTR [rsp+0x8]
     a74:	mov    r13,QWORD PTR [rsp+0x10]
     a79:	mov    r14,QWORD PTR [rsp+0x18]
     a7e:	add    rsp,0x20
     a82:	mov    rsp,rbp
     a85:	pop    rbp
     a86:	ret
     a87:	mov    r13,rdi
     a8a:	call   a8f <botlish_fn_7+0x18f>
			a8b: R_X86_64_PLT32	rt_stack_overflow-0x4
     a8f:	xor    rax,rax
     a92:	mov    rbx,QWORD PTR [rsp]
     a96:	mov    r12,QWORD PTR [rsp+0x8]
     a9b:	mov    r13,QWORD PTR [rsp+0x10]
     aa0:	mov    r14,QWORD PTR [rsp+0x18]
     aa5:	add    rsp,0x20
     aa9:	mov    rsp,rbp
     aac:	pop    rbp
     aad:	ret
     aae:	add    BYTE PTR [rax],al
     ab0:	(bad)
     ab1:	add    BYTE PTR [rax],al
     ab3:	add    BYTE PTR [rax],al
     ab5:	add    BYTE PTR [rax],al
	...

0000000000000ab8 <botlish_entry_7: peek<str, int>>:
     ab8:	push   rbp
     ab9:	mov    rbp,rsp
     abc:	mov    rsi,QWORD PTR [rdx]
     abf:	mov    rdx,QWORD PTR [rdx+0x8]
     ac3:	call   ac8 <botlish_entry_7+0x10>
			ac4: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     ac8:	mov    rsp,rbp
     acb:	pop    rbp
     acc:	ret
     acd:	add    BYTE PTR [rax],al
	...

0000000000000ad0 <botlish_fn_8: peek<str, int>>:
     ad0:	push   rbp
     ad1:	mov    rbp,rsp
     ad4:	sub    rsp,0x40
     ad8:	mov    QWORD PTR [rsp+0x10],rbx
     add:	mov    QWORD PTR [rsp+0x18],r12
     ae2:	mov    QWORD PTR [rsp+0x20],r13
     ae7:	mov    QWORD PTR [rsp+0x28],r14
     aec:	mov    QWORD PTR [rsp+0x30],r15
     af1:	mov    r13,rcx
     af4:	mov    r12,QWORD PTR [rdi]
     af7:	mov    rax,QWORD PTR [rdi+0x8]
     afb:	lea    rcx,[r12+0x18]
     b00:	cmp    rcx,rax
     b03:	ja     c9e <botlish_fn_8+0x1ce>
     b09:	lea    rax,[r12+0x18]
     b0e:	mov    QWORD PTR [rdi],rax
     b11:	mov    r15,rdi
     b14:	mov    QWORD PTR [r12],0x0
     b1c:	mov    QWORD PTR [r12+0x8],0x0
     b25:	mov    QWORD PTR [r12+0x10],0x0
     b2e:	mov    QWORD PTR [r12],rsi
     b32:	mov    r14,rsi
     b35:	mov    QWORD PTR [r12+0x8],rdx
     b3a:	mov    rbx,rdx
     b3d:	mov    rsi,r14
     b40:	mov    rdi,r15
     b43:	call   b48 <botlish_fn_8+0x78>
			b44: R_X86_64_PLT32	rt_str_len-0x4
     b48:	mov    rcx,rbx
     b4b:	and    rcx,rax
     b4e:	mov    rdx,rax
     b51:	test   rcx,0x1
     b58:	jne    b7e <botlish_fn_8+0xae>
     b5e:	mov    rsi,rbx
     b61:	mov    rdi,r15
     b64:	call   b69 <botlish_fn_8+0x99>
			b65: R_X86_64_PLT32	rt_int_cmp-0x4
     b69:	mov    ecx,0x2
     b6e:	test   rax,rax
     b71:	cmovge rcx,QWORD PTR [rip+0x157]        # cd0 <botlish_fn_8+0x200>
     b79:	jmp    b8e <botlish_fn_8+0xbe>
     b7e:	mov    ecx,0x2
     b83:	cmp    rbx,rdx
     b86:	cmovge rcx,QWORD PTR [rip+0x142]        # cd0 <botlish_fn_8+0x200>
     b8e:	cmp    rcx,0x6
     b92:	je     c5c <botlish_fn_8+0x18c>
     b98:	mov    QWORD PTR [r12+0x10],0x3
     ba1:	test   rbx,0x1
     ba8:	je     bc9 <botlish_fn_8+0xf9>
     bae:	mov    rax,rbx
     bb1:	add    rax,0x2
     bb5:	seto   cl
     bb8:	test   cl,cl
     bba:	jne    bc9 <botlish_fn_8+0xf9>
     bc0:	mov    QWORD PTR [rsp],rax
     bc4:	jmp    bdd <botlish_fn_8+0x10d>
     bc9:	mov    edx,0x3
     bce:	mov    rsi,rbx
     bd1:	mov    rdi,r15
     bd4:	call   bd9 <botlish_fn_8+0x109>
			bd5: R_X86_64_PLT32	rt_int_add-0x4
     bd9:	mov    QWORD PTR [rsp],rax
     bdd:	mov    rcx,QWORD PTR [rsp]
     be1:	mov    rdx,rbx
     be4:	mov    rsi,r14
     be7:	mov    rdi,r15
     bea:	call   bef <botlish_fn_8+0x11f>
			beb: R_X86_64_PLT32	rt_str_region_check-0x4
     bef:	test   rax,rax
     bf2:	jne    c23 <botlish_fn_8+0x153>
     bf8:	mov    rdi,r15
     bfb:	mov    QWORD PTR [rdi],r12
     bfe:	xor    rax,rax
     c01:	mov    rbx,QWORD PTR [rsp+0x10]
     c06:	mov    r12,QWORD PTR [rsp+0x18]
     c0b:	mov    r13,QWORD PTR [rsp+0x20]
     c10:	mov    r14,QWORD PTR [rsp+0x28]
     c15:	mov    r15,QWORD PTR [rsp+0x30]
     c1a:	add    rsp,0x40
     c1e:	mov    rsp,rbp
     c21:	pop    rbp
     c22:	ret
     c23:	mov    rdi,r15
     c26:	mov    QWORD PTR [rdi],r12
     c29:	mov    rcx,r13
     c2c:	mov    QWORD PTR [rcx],rbx
     c2f:	mov    rax,QWORD PTR [rsp]
     c33:	mov    QWORD PTR [rcx+0x8],rax
     c37:	mov    rax,r14
     c3a:	mov    rbx,QWORD PTR [rsp+0x10]
     c3f:	mov    r12,QWORD PTR [rsp+0x18]
     c44:	mov    r13,QWORD PTR [rsp+0x20]
     c49:	mov    r14,QWORD PTR [rsp+0x28]
     c4e:	mov    r15,QWORD PTR [rsp+0x30]
     c53:	add    rsp,0x40
     c57:	mov    rsp,rbp
     c5a:	pop    rbp
     c5b:	ret
     c5c:	mov    rcx,r13
     c5f:	mov    rdi,r15
     c62:	mov    rdx,QWORD PTR [rdi+0x10]
     c66:	mov    rax,QWORD PTR [rdx+0x8]
     c6a:	mov    QWORD PTR [rdi],r12
     c6d:	mov    QWORD PTR [rcx],0x1
     c74:	mov    QWORD PTR [rcx+0x8],0x1
     c7c:	mov    rbx,QWORD PTR [rsp+0x10]
     c81:	mov    r12,QWORD PTR [rsp+0x18]
     c86:	mov    r13,QWORD PTR [rsp+0x20]
     c8b:	mov    r14,QWORD PTR [rsp+0x28]
     c90:	mov    r15,QWORD PTR [rsp+0x30]
     c95:	add    rsp,0x40
     c99:	mov    rsp,rbp
     c9c:	pop    rbp
     c9d:	ret
     c9e:	mov    r15,rdi
     ca1:	call   ca6 <botlish_fn_8+0x1d6>
			ca2: R_X86_64_PLT32	rt_stack_overflow-0x4
     ca6:	xor    rax,rax
     ca9:	mov    rbx,QWORD PTR [rsp+0x10]
     cae:	mov    r12,QWORD PTR [rsp+0x18]
     cb3:	mov    r13,QWORD PTR [rsp+0x20]
     cb8:	mov    r14,QWORD PTR [rsp+0x28]
     cbd:	mov    r15,QWORD PTR [rsp+0x30]
     cc2:	add    rsp,0x40
     cc6:	mov    rsp,rbp
     cc9:	pop    rbp
     cca:	ret
     ccb:	add    BYTE PTR [rax],al
     ccd:	add    BYTE PTR [rax],al
     ccf:	add    BYTE PTR [rsi],al
     cd1:	add    BYTE PTR [rax],al
     cd3:	add    BYTE PTR [rax],al
     cd5:	add    BYTE PTR [rax],al
	...

0000000000000cd8 <botlish_entry_8: peek<str, int>>:
     cd8:	push   rbp
     cd9:	mov    rbp,rsp
     cdc:	ud2

0000000000000cde <botlish_fn_9: scan_unquoted<str, int, int>>:
     cde:	push   rbp
     cdf:	mov    rbp,rsp
     ce2:	sub    rsp,0x60
     ce6:	mov    QWORD PTR [rsp+0x30],rbx
     ceb:	mov    QWORD PTR [rsp+0x38],r12
     cf0:	mov    QWORD PTR [rsp+0x40],r13
     cf5:	mov    QWORD PTR [rsp+0x48],r14
     cfa:	mov    QWORD PTR [rsp+0x50],r15
     cff:	mov    r14,QWORD PTR [rdi]
     d02:	mov    rax,QWORD PTR [rdi+0x8]
     d06:	lea    r8,[r14+0x20]
     d0a:	cmp    r8,rax
     d0d:	ja     f35 <botlish_fn_9+0x257>
     d13:	lea    rax,[r14+0x20]
     d17:	mov    QWORD PTR [rdi],rax
     d1a:	mov    r15,rdi
     d1d:	mov    QWORD PTR [r14],0x0
     d24:	mov    QWORD PTR [r14+0x8],0x0
     d2c:	mov    QWORD PTR [r14+0x10],0x0
     d34:	mov    QWORD PTR [r14+0x18],0x0
     d3c:	mov    QWORD PTR [r14],rsi
     d3f:	mov    QWORD PTR [rsp+0x10],rsi
     d44:	mov    QWORD PTR [r14+0x8],rdx
     d48:	mov    QWORD PTR [rsp+0x18],rdx
     d4d:	mov    QWORD PTR [r14+0x10],rcx
     d51:	lea    rbx,[rsp]
     d55:	mov    QWORD PTR [rsp+0x20],rcx
     d5a:	mov    rcx,rbx
     d5d:	mov    rdx,QWORD PTR [rsp+0x20]
     d62:	mov    rsi,QWORD PTR [rsp+0x10]
     d67:	mov    rdi,r15
     d6a:	call   d6f <botlish_fn_9+0x91>
			d6b: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     d6f:	mov    rcx,rax
     d72:	mov    QWORD PTR [rsp+0x28],rax
     d77:	test   rax,rcx
     d7a:	jne    d88 <botlish_fn_9+0xaa>
     d80:	mov    rdi,r15
     d83:	jmp    eda <botlish_fn_9+0x1fc>
     d88:	mov    r12,QWORD PTR [rsp]
     d8c:	mov    r13,QWORD PTR [rsp+0x8]
     d91:	mov    rdi,r15
     d94:	mov    rcx,QWORD PTR [rdi+0x10]
     d98:	mov    r8,QWORD PTR [rcx+0x8]
     d9c:	mov    rcx,r13
     d9f:	mov    rdx,r12
     da2:	mov    rsi,QWORD PTR [rsp+0x28]
     da7:	call   dac <botlish_fn_9+0xce>
			da8: R_X86_64_PLT32	rt_str_region_eq-0x4
     dac:	cmp    rax,0x6
     db0:	je     def <botlish_fn_9+0x111>
     db6:	mov    rdi,r15
     db9:	mov    rax,QWORD PTR [rdi+0x10]
     dbd:	mov    r8,QWORD PTR [rax+0x10]
     dc1:	mov    rcx,r13
     dc4:	mov    rdx,r12
     dc7:	mov    rsi,QWORD PTR [rsp+0x28]
     dcc:	call   dd1 <botlish_fn_9+0xf3>
			dcd: R_X86_64_PLT32	rt_str_region_eq-0x4
     dd1:	cmp    rax,0x6
     dd5:	je     de5 <botlish_fn_9+0x107>
     ddb:	mov    eax,0x2
     de0:	jmp    df4 <botlish_fn_9+0x116>
     de5:	mov    eax,0x6
     dea:	jmp    df4 <botlish_fn_9+0x116>
     def:	mov    eax,0x6
     df4:	cmp    rax,0x6
     df8:	je     e37 <botlish_fn_9+0x159>
     dfe:	mov    rdi,r15
     e01:	mov    rsi,QWORD PTR [rdi+0x10]
     e05:	mov    r8,QWORD PTR [rsi+0x18]
     e09:	mov    rcx,r13
     e0c:	mov    rdx,r12
     e0f:	mov    rsi,QWORD PTR [rsp+0x28]
     e14:	call   e19 <botlish_fn_9+0x13b>
			e15: R_X86_64_PLT32	rt_str_region_eq-0x4
     e19:	cmp    rax,0x6
     e1d:	je     e2d <botlish_fn_9+0x14f>
     e23:	mov    eax,0x2
     e28:	jmp    e3c <botlish_fn_9+0x15e>
     e2d:	mov    eax,0x6
     e32:	jmp    e3c <botlish_fn_9+0x15e>
     e37:	mov    eax,0x6
     e3c:	cmp    rax,0x6
     e40:	je     eb7 <botlish_fn_9+0x1d9>
     e46:	mov    QWORD PTR [r14+0x18],0x3
     e4e:	mov    rsi,QWORD PTR [rsp+0x20]
     e53:	test   rsi,0x1
     e5a:	je     e81 <botlish_fn_9+0x1a3>
     e60:	mov    rsi,QWORD PTR [rsp+0x20]
     e65:	mov    rax,rsi
     e68:	add    rax,0x2
     e6c:	seto   cl
     e6f:	test   cl,cl
     e71:	jne    e81 <botlish_fn_9+0x1a3>
     e77:	mov    rsi,QWORD PTR [rsp+0x10]
     e7c:	jmp    e98 <botlish_fn_9+0x1ba>
     e81:	mov    edx,0x3
     e86:	mov    rsi,QWORD PTR [rsp+0x20]
     e8b:	mov    rdi,r15
     e8e:	call   e93 <botlish_fn_9+0x1b5>
			e8f: R_X86_64_PLT32	rt_int_add-0x4
     e93:	mov    rsi,QWORD PTR [rsp+0x10]
     e98:	mov    QWORD PTR [r14],rsi
     e9b:	mov    rdx,QWORD PTR [rsp+0x18]
     ea0:	mov    QWORD PTR [r14+0x8],rdx
     ea4:	mov    QWORD PTR [r14+0x10],rax
     ea8:	mov    QWORD PTR [rsp+0x10],rsi
     ead:	mov    QWORD PTR [rsp+0x20],rax
     eb2:	jmp    d5a <botlish_fn_9+0x7c>
     eb7:	mov    rdx,QWORD PTR [rsp+0x18]
     ebc:	mov    rsi,QWORD PTR [rsp+0x10]
     ec1:	mov    rcx,QWORD PTR [rsp+0x20]
     ec6:	mov    rdi,r15
     ec9:	call   ece <botlish_fn_9+0x1f0>
			eca: R_X86_64_PLT32	rt_substr-0x4
     ece:	test   rax,rax
     ed1:	jne    f08 <botlish_fn_9+0x22a>
     ed7:	mov    rdi,r15
     eda:	mov    rdi,r15
     edd:	mov    QWORD PTR [rdi],r14
     ee0:	xor    rdx,rdx
     ee3:	mov    rax,rdx
     ee6:	mov    rbx,QWORD PTR [rsp+0x30]
     eeb:	mov    r12,QWORD PTR [rsp+0x38]
     ef0:	mov    r13,QWORD PTR [rsp+0x40]
     ef5:	mov    r14,QWORD PTR [rsp+0x48]
     efa:	mov    r15,QWORD PTR [rsp+0x50]
     eff:	add    rsp,0x60
     f03:	mov    rsp,rbp
     f06:	pop    rbp
     f07:	ret
     f08:	mov    rdi,r15
     f0b:	mov    QWORD PTR [rdi],r14
     f0e:	mov    rdx,QWORD PTR [rsp+0x20]
     f13:	mov    rbx,QWORD PTR [rsp+0x30]
     f18:	mov    r12,QWORD PTR [rsp+0x38]
     f1d:	mov    r13,QWORD PTR [rsp+0x40]
     f22:	mov    r14,QWORD PTR [rsp+0x48]
     f27:	mov    r15,QWORD PTR [rsp+0x50]
     f2c:	add    rsp,0x60
     f30:	mov    rsp,rbp
     f33:	pop    rbp
     f34:	ret
     f35:	mov    r15,rdi
     f38:	call   f3d <botlish_fn_9+0x25f>
			f39: R_X86_64_PLT32	rt_stack_overflow-0x4
     f3d:	xor    rdx,rdx
     f40:	mov    rax,rdx
     f43:	mov    rbx,QWORD PTR [rsp+0x30]
     f48:	mov    r12,QWORD PTR [rsp+0x38]
     f4d:	mov    r13,QWORD PTR [rsp+0x40]
     f52:	mov    r14,QWORD PTR [rsp+0x48]
     f57:	mov    r15,QWORD PTR [rsp+0x50]
     f5c:	add    rsp,0x60
     f60:	mov    rsp,rbp
     f63:	pop    rbp
     f64:	ret

0000000000000f65 <botlish_entry_9: scan_unquoted<str, int, int>>:
     f65:	push   rbp
     f66:	mov    rbp,rsp
     f69:	ud2

0000000000000f6b <botlish_fn_10: scan_quoted<str, int, str>>:
     f6b:	push   rbp
     f6c:	mov    rbp,rsp
     f6f:	sub    rsp,0x50
     f73:	mov    QWORD PTR [rsp+0x20],rbx
     f78:	mov    QWORD PTR [rsp+0x28],r12
     f7d:	mov    QWORD PTR [rsp+0x30],r13
     f82:	mov    QWORD PTR [rsp+0x38],r14
     f87:	mov    QWORD PTR [rsp+0x40],r15
     f8c:	mov    r13,QWORD PTR [rdi]
     f8f:	mov    rax,QWORD PTR [rdi+0x8]
     f93:	lea    r8,[r13+0x28]
     f97:	cmp    r8,rax
     f9a:	ja     1282 <botlish_fn_10+0x317>
     fa0:	lea    rax,[r13+0x28]
     fa4:	mov    QWORD PTR [rdi],rax
     fa7:	mov    r14,rdi
     faa:	mov    QWORD PTR [r13+0x0],0x0
     fb2:	mov    QWORD PTR [r13+0x8],0x0
     fba:	mov    QWORD PTR [r13+0x10],0x0
     fc2:	mov    QWORD PTR [r13+0x18],0x0
     fca:	mov    QWORD PTR [r13+0x20],0x0
     fd2:	mov    QWORD PTR [r13+0x0],rsi
     fd6:	mov    QWORD PTR [r13+0x8],rdx
     fda:	mov    QWORD PTR [r13+0x10],rcx
     fde:	lea    rbx,[rsp]
     fe2:	mov    r12,rsi
     fe5:	mov    r15,rdx
     fe8:	mov    QWORD PTR [rsp+0x10],rcx
     fed:	mov    rdx,r15
     ff0:	mov    rsi,r12
     ff3:	mov    rdi,r14
     ff6:	call   ffb <botlish_fn_10+0x90>
			ff7: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     ffb:	test   rax,rax
     ffe:	jne    100c <botlish_fn_10+0xa1>
    1004:	mov    rdi,r14
    1007:	jmp    123b <botlish_fn_10+0x2d0>
    100c:	mov    QWORD PTR [r13+0x18],rax
    1010:	mov    rdi,r14
    1013:	mov    QWORD PTR [rsp+0x18],rax
    1018:	mov    rsi,QWORD PTR [rdi+0x10]
    101c:	mov    rsi,QWORD PTR [rsi+0x20]
    1020:	mov    edx,0x1
    1025:	mov    ecx,0x3
    102a:	mov    r8,QWORD PTR [rsp+0x18]
    102f:	call   1034 <botlish_fn_10+0xc9>
			1030: R_X86_64_PLT32	rt_str_region_eq-0x4
    1034:	cmp    rax,0x6
    1038:	je     10c3 <botlish_fn_10+0x158>
    103e:	mov    QWORD PTR [r13+0x20],0x3
    1046:	mov    rsi,r15
    1049:	test   rsi,0x1
    1050:	je     1070 <botlish_fn_10+0x105>
    1056:	mov    r11,rsi
    1059:	add    r11,0x2
    105d:	seto   al
    1060:	test   al,al
    1062:	jne    1070 <botlish_fn_10+0x105>
    1068:	mov    rsi,r11
    106b:	jmp    1080 <botlish_fn_10+0x115>
    1070:	mov    edx,0x3
    1075:	mov    rdi,r14
    1078:	call   107d <botlish_fn_10+0x112>
			1079: R_X86_64_PLT32	rt_int_add-0x4
    107d:	mov    rsi,rax
    1080:	mov    QWORD PTR [r13+0x8],rsi
    1084:	mov    r15,rsi
    1087:	mov    rsi,QWORD PTR [rsp+0x10]
    108c:	mov    rdx,QWORD PTR [rsp+0x18]
    1091:	mov    rdi,r14
    1094:	call   1099 <botlish_fn_10+0x12e>
			1095: R_X86_64_PLT32	rt_str_cat-0x4
    1099:	test   rax,rax
    109c:	jne    10aa <botlish_fn_10+0x13f>
    10a2:	mov    rdi,r14
    10a5:	jmp    123b <botlish_fn_10+0x2d0>
    10aa:	mov    QWORD PTR [r13+0x0],r12
    10ae:	mov    rsi,r15
    10b1:	mov    QWORD PTR [r13+0x8],rsi
    10b5:	mov    QWORD PTR [r13+0x10],rax
    10b9:	mov    QWORD PTR [rsp+0x10],rax
    10be:	jmp    fed <botlish_fn_10+0x82>
    10c3:	mov    QWORD PTR [r13+0x18],0x3
    10cb:	mov    rsi,r15
    10ce:	test   rsi,0x1
    10d5:	je     10f0 <botlish_fn_10+0x185>
    10db:	mov    rsi,r15
    10de:	mov    rdx,rsi
    10e1:	add    rdx,0x2
    10e5:	seto   al
    10e8:	test   al,al
    10ea:	je     1103 <botlish_fn_10+0x198>
    10f0:	mov    edx,0x3
    10f5:	mov    rsi,r15
    10f8:	mov    rdi,r14
    10fb:	call   1100 <botlish_fn_10+0x195>
			10fc: R_X86_64_PLT32	rt_int_add-0x4
    1100:	mov    rdx,rax
    1103:	mov    QWORD PTR [r13+0x18],rdx
    1107:	mov    rcx,rbx
    110a:	mov    rsi,r12
    110d:	mov    rdi,r14
    1110:	call   1115 <botlish_fn_10+0x1aa>
			1111: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    1115:	test   rax,rax
    1118:	mov    rsi,rax
    111b:	jne    1129 <botlish_fn_10+0x1be>
    1121:	mov    rdi,r14
    1124:	jmp    123b <botlish_fn_10+0x2d0>
    1129:	mov    rdx,QWORD PTR [rsp]
    112d:	mov    rcx,QWORD PTR [rsp+0x8]
    1132:	mov    rdi,r14
    1135:	mov    rax,QWORD PTR [rdi+0x10]
    1139:	mov    r8,QWORD PTR [rax+0x20]
    113d:	call   1142 <botlish_fn_10+0x1d7>
			113e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1142:	cmp    rax,0x6
    1146:	je     11c4 <botlish_fn_10+0x259>
    114c:	mov    QWORD PTR [r13+0x0],0x3
    1154:	mov    rsi,r15
    1157:	test   rsi,0x1
    115e:	je     1181 <botlish_fn_10+0x216>
    1164:	mov    rsi,r15
    1167:	mov    rdx,rsi
    116a:	add    rdx,0x2
    116e:	seto   al
    1171:	test   al,al
    1173:	jne    1181 <botlish_fn_10+0x216>
    1179:	mov    rdi,r14
    117c:	jmp    1197 <botlish_fn_10+0x22c>
    1181:	mov    edx,0x3
    1186:	mov    rsi,r15
    1189:	mov    rdi,r14
    118c:	call   1191 <botlish_fn_10+0x226>
			118d: R_X86_64_PLT32	rt_int_add-0x4
    1191:	mov    rdx,rax
    1194:	mov    rdi,r14
    1197:	mov    rdi,r14
    119a:	mov    QWORD PTR [rdi],r13
    119d:	mov    rax,QWORD PTR [rsp+0x10]
    11a2:	mov    rbx,QWORD PTR [rsp+0x20]
    11a7:	mov    r12,QWORD PTR [rsp+0x28]
    11ac:	mov    r13,QWORD PTR [rsp+0x30]
    11b1:	mov    r14,QWORD PTR [rsp+0x38]
    11b6:	mov    r15,QWORD PTR [rsp+0x40]
    11bb:	add    rsp,0x50
    11bf:	mov    rsp,rbp
    11c2:	pop    rbp
    11c3:	ret
    11c4:	mov    QWORD PTR [r13+0x18],0x5
    11cc:	mov    rsi,r15
    11cf:	test   rsi,0x1
    11d6:	je     11fc <botlish_fn_10+0x291>
    11dc:	mov    rsi,r15
    11df:	mov    rax,rsi
    11e2:	add    rax,0x4
    11e6:	seto   cl
    11e9:	test   cl,cl
    11eb:	jne    11fc <botlish_fn_10+0x291>
    11f1:	mov    rsi,rax
    11f4:	mov    r15,rax
    11f7:	jmp    1212 <botlish_fn_10+0x2a7>
    11fc:	mov    edx,0x5
    1201:	mov    rsi,r15
    1204:	mov    rdi,r14
    1207:	call   120c <botlish_fn_10+0x2a1>
			1208: R_X86_64_PLT32	rt_int_add-0x4
    120c:	mov    rsi,rax
    120f:	mov    r15,rax
    1212:	mov    QWORD PTR [r13+0x8],rsi
    1216:	mov    rdi,r14
    1219:	mov    rax,QWORD PTR [rdi+0x10]
    121d:	mov    rdx,QWORD PTR [rax+0x20]
    1221:	mov    QWORD PTR [r13+0x18],rdx
    1225:	mov    rsi,QWORD PTR [rsp+0x10]
    122a:	call   122f <botlish_fn_10+0x2c4>
			122b: R_X86_64_PLT32	rt_str_cat-0x4
    122f:	test   rax,rax
    1232:	jne    1269 <botlish_fn_10+0x2fe>
    1238:	mov    rdi,r14
    123b:	mov    rdi,r14
    123e:	mov    QWORD PTR [rdi],r13
    1241:	xor    rdx,rdx
    1244:	mov    rax,rdx
    1247:	mov    rbx,QWORD PTR [rsp+0x20]
    124c:	mov    r12,QWORD PTR [rsp+0x28]
    1251:	mov    r13,QWORD PTR [rsp+0x30]
    1256:	mov    r14,QWORD PTR [rsp+0x38]
    125b:	mov    r15,QWORD PTR [rsp+0x40]
    1260:	add    rsp,0x50
    1264:	mov    rsp,rbp
    1267:	pop    rbp
    1268:	ret
    1269:	mov    QWORD PTR [r13+0x0],r12
    126d:	mov    rsi,r15
    1270:	mov    QWORD PTR [r13+0x8],rsi
    1274:	mov    QWORD PTR [r13+0x10],rax
    1278:	mov    QWORD PTR [rsp+0x10],rax
    127d:	jmp    fed <botlish_fn_10+0x82>
    1282:	mov    r14,rdi
    1285:	call   128a <botlish_fn_10+0x31f>
			1286: R_X86_64_PLT32	rt_stack_overflow-0x4
    128a:	xor    rdx,rdx
    128d:	mov    rax,rdx
    1290:	mov    rbx,QWORD PTR [rsp+0x20]
    1295:	mov    r12,QWORD PTR [rsp+0x28]
    129a:	mov    r13,QWORD PTR [rsp+0x30]
    129f:	mov    r14,QWORD PTR [rsp+0x38]
    12a4:	mov    r15,QWORD PTR [rsp+0x40]
    12a9:	add    rsp,0x50
    12ad:	mov    rsp,rbp
    12b0:	pop    rbp
    12b1:	ret

00000000000012b2 <botlish_entry_10: scan_quoted<str, int, str>>:
    12b2:	push   rbp
    12b3:	mov    rbp,rsp
    12b6:	ud2

00000000000012b8 <botlish_fn_11: scan_field<str, int>>:
    12b8:	push   rbp
    12b9:	mov    rbp,rsp
    12bc:	sub    rsp,0x30
    12c0:	mov    QWORD PTR [rsp+0x10],rbx
    12c5:	mov    QWORD PTR [rsp+0x18],r12
    12ca:	mov    QWORD PTR [rsp+0x20],r13
    12cf:	mov    QWORD PTR [rsp+0x28],r14
    12d4:	mov    rbx,QWORD PTR [rdi]
    12d7:	mov    rax,QWORD PTR [rdi+0x8]
    12db:	lea    rcx,[rbx+0x18]
    12df:	cmp    rcx,rax
    12e2:	ja     1454 <botlish_fn_11+0x19c>
    12e8:	lea    rax,[rbx+0x18]
    12ec:	mov    QWORD PTR [rdi],rax
    12ef:	mov    r12,rdi
    12f2:	mov    QWORD PTR [rbx],0x0
    12f9:	mov    QWORD PTR [rbx+0x8],0x0
    1301:	mov    QWORD PTR [rbx+0x10],0x0
    1309:	mov    QWORD PTR [rbx],rsi
    130c:	mov    r13,rsi
    130f:	mov    QWORD PTR [rbx+0x8],rdx
    1313:	mov    r14,rdx
    1316:	lea    rcx,[rsp]
    131a:	mov    rdx,r14
    131d:	mov    rsi,r13
    1320:	mov    rdi,r12
    1323:	call   1328 <botlish_fn_11+0x70>
			1324: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    1328:	test   rax,rax
    132b:	mov    rsi,rax
    132e:	jne    133c <botlish_fn_11+0x84>
    1334:	mov    rdi,r12
    1337:	jmp    1408 <botlish_fn_11+0x150>
    133c:	mov    rdx,QWORD PTR [rsp]
    1340:	mov    rcx,QWORD PTR [rsp+0x8]
    1345:	mov    rdi,r12
    1348:	mov    rax,QWORD PTR [rdi+0x10]
    134c:	mov    r8,QWORD PTR [rax+0x20]
    1350:	call   1355 <botlish_fn_11+0x9d>
			1351: R_X86_64_PLT32	rt_str_region_eq-0x4
    1355:	cmp    rax,0x6
    1359:	je     13a4 <botlish_fn_11+0xec>
    135f:	mov    rcx,r14
    1362:	mov    rsi,r13
    1365:	mov    rdi,r12
    1368:	mov    rdx,rcx
    136b:	call   1370 <botlish_fn_11+0xb8>
			136c: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_unquoted<str, int, int>
    1370:	test   rax,rax
    1373:	jne    1381 <botlish_fn_11+0xc9>
    1379:	mov    rdi,r12
    137c:	jmp    1408 <botlish_fn_11+0x150>
    1381:	mov    rdi,r12
    1384:	mov    QWORD PTR [rdi],rbx
    1387:	mov    rbx,QWORD PTR [rsp+0x10]
    138c:	mov    r12,QWORD PTR [rsp+0x18]
    1391:	mov    r13,QWORD PTR [rsp+0x20]
    1396:	mov    r14,QWORD PTR [rsp+0x28]
    139b:	add    rsp,0x30
    139f:	mov    rsp,rbp
    13a2:	pop    rbp
    13a3:	ret
    13a4:	mov    QWORD PTR [rbx+0x10],0x3
    13ac:	mov    rdx,r14
    13af:	test   rdx,0x1
    13b6:	je     13ce <botlish_fn_11+0x116>
    13bc:	mov    rdx,r14
    13bf:	add    rdx,0x2
    13c3:	seto   al
    13c6:	test   al,al
    13c8:	je     13e1 <botlish_fn_11+0x129>
    13ce:	mov    edx,0x3
    13d3:	mov    rsi,r14
    13d6:	mov    rdi,r12
    13d9:	call   13de <botlish_fn_11+0x126>
			13da: R_X86_64_PLT32	rt_int_add-0x4
    13de:	mov    rdx,rax
    13e1:	mov    QWORD PTR [rbx+0x8],rdx
    13e5:	mov    rdi,r12
    13e8:	mov    rax,QWORD PTR [rdi+0x10]
    13ec:	mov    rcx,QWORD PTR [rax+0x8]
    13f0:	mov    QWORD PTR [rbx+0x10],rcx
    13f4:	mov    rsi,r13
    13f7:	call   13fc <botlish_fn_11+0x144>
			13f8: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_quoted<str, int, str>
    13fc:	test   rax,rax
    13ff:	jne    1431 <botlish_fn_11+0x179>
    1405:	mov    rdi,r12
    1408:	mov    rdi,r12
    140b:	mov    QWORD PTR [rdi],rbx
    140e:	xor    rdx,rdx
    1411:	mov    rax,rdx
    1414:	mov    rbx,QWORD PTR [rsp+0x10]
    1419:	mov    r12,QWORD PTR [rsp+0x18]
    141e:	mov    r13,QWORD PTR [rsp+0x20]
    1423:	mov    r14,QWORD PTR [rsp+0x28]
    1428:	add    rsp,0x30
    142c:	mov    rsp,rbp
    142f:	pop    rbp
    1430:	ret
    1431:	mov    rdi,r12
    1434:	mov    QWORD PTR [rdi],rbx
    1437:	mov    rbx,QWORD PTR [rsp+0x10]
    143c:	mov    r12,QWORD PTR [rsp+0x18]
    1441:	mov    r13,QWORD PTR [rsp+0x20]
    1446:	mov    r14,QWORD PTR [rsp+0x28]
    144b:	add    rsp,0x30
    144f:	mov    rsp,rbp
    1452:	pop    rbp
    1453:	ret
    1454:	mov    r12,rdi
    1457:	call   145c <botlish_fn_11+0x1a4>
			1458: R_X86_64_PLT32	rt_stack_overflow-0x4
    145c:	xor    rdx,rdx
    145f:	mov    rax,rdx
    1462:	mov    rbx,QWORD PTR [rsp+0x10]
    1467:	mov    r12,QWORD PTR [rsp+0x18]
    146c:	mov    r13,QWORD PTR [rsp+0x20]
    1471:	mov    r14,QWORD PTR [rsp+0x28]
    1476:	add    rsp,0x30
    147a:	mov    rsp,rbp
    147d:	pop    rbp
    147e:	ret

000000000000147f <botlish_entry_11: scan_field<str, int>>:
    147f:	push   rbp
    1480:	mov    rbp,rsp
    1483:	ud2

0000000000001485 <botlish_fn_12: scan_record<str, int, list[mutarray, int]>>:
    1485:	push   rbp
    1486:	mov    rbp,rsp
    1489:	sub    rsp,0x70
    148d:	mov    QWORD PTR [rsp+0x40],rbx
    1492:	mov    QWORD PTR [rsp+0x48],r12
    1497:	mov    QWORD PTR [rsp+0x50],r13
    149c:	mov    QWORD PTR [rsp+0x58],r14
    14a1:	mov    QWORD PTR [rsp+0x60],r15
    14a6:	mov    r13,QWORD PTR [rdi]
    14a9:	mov    rax,QWORD PTR [rdi+0x8]
    14ad:	lea    r9,[r13+0x28]
    14b1:	cmp    r9,rax
    14b4:	ja     179a <botlish_fn_12+0x315>
    14ba:	lea    rax,[r13+0x28]
    14be:	mov    QWORD PTR [rdi],rax
    14c1:	mov    QWORD PTR [rsp+0x10],rdi
    14c6:	mov    QWORD PTR [r13+0x0],0x0
    14ce:	mov    QWORD PTR [r13+0x8],0x0
    14d6:	mov    QWORD PTR [r13+0x10],0x0
    14de:	mov    QWORD PTR [r13+0x18],0x0
    14e6:	mov    QWORD PTR [r13+0x20],0x0
    14ee:	mov    QWORD PTR [r13+0x0],rsi
    14f2:	mov    QWORD PTR [r13+0x8],rdx
    14f6:	mov    QWORD PTR [r13+0x10],rcx
    14fa:	mov    QWORD PTR [r13+0x18],r8
    14fe:	lea    rbx,[rsp]
    1502:	mov    r12,rsi
    1505:	mov    r14,r8
    1508:	mov    r15,rcx
    150b:	mov    rsi,r12
    150e:	mov    rdi,QWORD PTR [rsp+0x10]
    1513:	call   1518 <botlish_fn_12+0x93>
			1514: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_field<str, int>
    1518:	test   rax,rax
    151b:	jne    152b <botlish_fn_12+0xa6>
    1521:	mov    rdi,QWORD PTR [rsp+0x10]
    1526:	jmp    1671 <botlish_fn_12+0x1ec>
    152b:	mov    QWORD PTR [r13+0x8],rax
    152f:	mov    rcx,rax
    1532:	mov    QWORD PTR [r13+0x20],rdx
    1536:	mov    QWORD PTR [rsp+0x30],rdx
    153b:	mov    rsi,r15
    153e:	mov    rdx,r14
    1541:	mov    rdi,QWORD PTR [rsp+0x10]
    1546:	call   154b <botlish_fn_12+0xc6>
			1547: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    154b:	test   rax,rax
    154e:	jne    155e <botlish_fn_12+0xd9>
    1554:	mov    rdi,QWORD PTR [rsp+0x10]
    1559:	jmp    1671 <botlish_fn_12+0x1ec>
    155e:	mov    QWORD PTR [r13+0x8],rax
    1562:	mov    QWORD PTR [rsp+0x20],rax
    1567:	mov    QWORD PTR [r13+0x10],rdx
    156b:	mov    QWORD PTR [rsp+0x28],rdx
    1570:	mov    rcx,rbx
    1573:	mov    rdx,QWORD PTR [rsp+0x30]
    1578:	mov    rsi,r12
    157b:	mov    rdi,QWORD PTR [rsp+0x10]
    1580:	call   1585 <botlish_fn_12+0x100>
			1581: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    1585:	test   rax,rax
    1588:	mov    QWORD PTR [rsp+0x18],rax
    158d:	jne    159d <botlish_fn_12+0x118>
    1593:	mov    rdi,QWORD PTR [rsp+0x10]
    1598:	jmp    1671 <botlish_fn_12+0x1ec>
    159d:	mov    r15,QWORD PTR [rsp]
    15a1:	mov    r14,QWORD PTR [rsp+0x8]
    15a6:	mov    rdi,QWORD PTR [rsp+0x10]
    15ab:	mov    rsi,QWORD PTR [rdi+0x10]
    15af:	mov    r8,QWORD PTR [rsi+0x10]
    15b3:	mov    rcx,r14
    15b6:	mov    rdx,r15
    15b9:	mov    rsi,QWORD PTR [rsp+0x18]
    15be:	call   15c3 <botlish_fn_12+0x13e>
			15bf: R_X86_64_PLT32	rt_str_region_eq-0x4
    15c3:	cmp    rax,0x6
    15c7:	je     1729 <botlish_fn_12+0x2a4>
    15cd:	mov    rdi,QWORD PTR [rsp+0x10]
    15d2:	mov    rdi,QWORD PTR [rdi+0x10]
    15d6:	mov    r8,QWORD PTR [rdi+0x18]
    15da:	mov    rcx,r14
    15dd:	mov    rdx,r15
    15e0:	mov    rsi,QWORD PTR [rsp+0x18]
    15e5:	mov    rdi,QWORD PTR [rsp+0x10]
    15ea:	call   15ef <botlish_fn_12+0x16a>
			15eb: R_X86_64_PLT32	rt_str_region_eq-0x4
    15ef:	cmp    rax,0x6
    15f3:	je     164f <botlish_fn_12+0x1ca>
    15f9:	mov    rdx,QWORD PTR [rsp+0x28]
    15fe:	mov    rsi,QWORD PTR [rsp+0x20]
    1603:	mov    rdi,QWORD PTR [rsp+0x10]
    1608:	call   160d <botlish_fn_12+0x188>
			1609: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    160d:	test   rax,rax
    1610:	jne    1620 <botlish_fn_12+0x19b>
    1616:	mov    rdi,QWORD PTR [rsp+0x10]
    161b:	jmp    1671 <botlish_fn_12+0x1ec>
    1620:	mov    rdi,QWORD PTR [rsp+0x10]
    1625:	mov    QWORD PTR [rdi],r13
    1628:	mov    rdx,QWORD PTR [rsp+0x30]
    162d:	mov    rbx,QWORD PTR [rsp+0x40]
    1632:	mov    r12,QWORD PTR [rsp+0x48]
    1637:	mov    r13,QWORD PTR [rsp+0x50]
    163c:	mov    r14,QWORD PTR [rsp+0x58]
    1641:	mov    r15,QWORD PTR [rsp+0x60]
    1646:	add    rsp,0x70
    164a:	mov    rsp,rbp
    164d:	pop    rbp
    164e:	ret
    164f:	mov    rdx,QWORD PTR [rsp+0x28]
    1654:	mov    rsi,QWORD PTR [rsp+0x20]
    1659:	mov    rdi,QWORD PTR [rsp+0x10]
    165e:	call   1663 <botlish_fn_12+0x1de>
			165f: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    1663:	test   rax,rax
    1666:	jne    16a1 <botlish_fn_12+0x21c>
    166c:	mov    rdi,QWORD PTR [rsp+0x10]
    1671:	mov    rdi,QWORD PTR [rsp+0x10]
    1676:	mov    QWORD PTR [rdi],r13
    1679:	xor    rdx,rdx
    167c:	mov    rax,rdx
    167f:	mov    rbx,QWORD PTR [rsp+0x40]
    1684:	mov    r12,QWORD PTR [rsp+0x48]
    1689:	mov    r13,QWORD PTR [rsp+0x50]
    168e:	mov    r14,QWORD PTR [rsp+0x58]
    1693:	mov    r15,QWORD PTR [rsp+0x60]
    1698:	add    rsp,0x70
    169c:	mov    rsp,rbp
    169f:	pop    rbp
    16a0:	ret
    16a1:	mov    QWORD PTR [r13+0x0],rax
    16a5:	mov    rbx,rax
    16a8:	mov    QWORD PTR [r13+0x8],0x3
    16b0:	mov    rdx,QWORD PTR [rsp+0x30]
    16b5:	test   rdx,0x1
    16bc:	je     16e0 <botlish_fn_12+0x25b>
    16c2:	mov    rdx,QWORD PTR [rsp+0x30]
    16c7:	add    rdx,0x2
    16cb:	seto   al
    16ce:	test   al,al
    16d0:	jne    16e0 <botlish_fn_12+0x25b>
    16d6:	mov    rdi,QWORD PTR [rsp+0x10]
    16db:	jmp    16fc <botlish_fn_12+0x277>
    16e0:	mov    edx,0x3
    16e5:	mov    rsi,QWORD PTR [rsp+0x30]
    16ea:	mov    rdi,QWORD PTR [rsp+0x10]
    16ef:	call   16f4 <botlish_fn_12+0x26f>
			16f0: R_X86_64_PLT32	rt_int_add-0x4
    16f4:	mov    rdx,rax
    16f7:	mov    rdi,QWORD PTR [rsp+0x10]
    16fc:	mov    rdi,QWORD PTR [rsp+0x10]
    1701:	mov    QWORD PTR [rdi],r13
    1704:	mov    rax,rbx
    1707:	mov    rbx,QWORD PTR [rsp+0x40]
    170c:	mov    r12,QWORD PTR [rsp+0x48]
    1711:	mov    r13,QWORD PTR [rsp+0x50]
    1716:	mov    r14,QWORD PTR [rsp+0x58]
    171b:	mov    r15,QWORD PTR [rsp+0x60]
    1720:	add    rsp,0x70
    1724:	mov    rsp,rbp
    1727:	pop    rbp
    1728:	ret
    1729:	mov    rsi,QWORD PTR [rsp+0x30]
    172e:	mov    edx,0x3
    1733:	mov    r9,rdx
    1736:	mov    QWORD PTR [r13+0x18],0x3
    173e:	test   rsi,0x1
    1745:	jne    1753 <botlish_fn_12+0x2ce>
    174b:	mov    rdx,r9
    174e:	jmp    1768 <botlish_fn_12+0x2e3>
    1753:	mov    rdx,rsi
    1756:	add    rdx,0x2
    175a:	seto   al
    175d:	test   al,al
    175f:	je     1775 <botlish_fn_12+0x2f0>
    1765:	mov    rdx,r9
    1768:	mov    rdi,QWORD PTR [rsp+0x10]
    176d:	call   1772 <botlish_fn_12+0x2ed>
			176e: R_X86_64_PLT32	rt_int_add-0x4
    1772:	mov    rdx,rax
    1775:	mov    QWORD PTR [r13+0x0],r12
    1779:	mov    QWORD PTR [r13+0x8],rdx
    177d:	mov    rsi,QWORD PTR [rsp+0x20]
    1782:	mov    QWORD PTR [r13+0x10],rsi
    1786:	mov    rax,QWORD PTR [rsp+0x28]
    178b:	mov    QWORD PTR [r13+0x18],rax
    178f:	mov    r14,rax
    1792:	mov    r15,rsi
    1795:	jmp    150b <botlish_fn_12+0x86>
    179a:	mov    QWORD PTR [rsp+0x10],rdi
    179f:	call   17a4 <botlish_fn_12+0x31f>
			17a0: R_X86_64_PLT32	rt_stack_overflow-0x4
    17a4:	xor    rdx,rdx
    17a7:	mov    rax,rdx
    17aa:	mov    rbx,QWORD PTR [rsp+0x40]
    17af:	mov    r12,QWORD PTR [rsp+0x48]
    17b4:	mov    r13,QWORD PTR [rsp+0x50]
    17b9:	mov    r14,QWORD PTR [rsp+0x58]
    17be:	mov    r15,QWORD PTR [rsp+0x60]
    17c3:	add    rsp,0x70
    17c7:	mov    rsp,rbp
    17ca:	pop    rbp
    17cb:	ret

00000000000017cc <botlish_entry_12: scan_record<str, int, list[mutarray, int]>>:
    17cc:	push   rbp
    17cd:	mov    rbp,rsp
    17d0:	ud2
    17d2:	add    BYTE PTR [rax],al
    17d4:	add    BYTE PTR [rax],al
	...

00000000000017d8 <botlish_fn_13: scan_records<str, int, list[mutarray, int]>>:
    17d8:	push   rbp
    17d9:	mov    rbp,rsp
    17dc:	sub    rsp,0x40
    17e0:	mov    QWORD PTR [rsp+0x10],rbx
    17e5:	mov    QWORD PTR [rsp+0x18],r12
    17ea:	mov    QWORD PTR [rsp+0x20],r13
    17ef:	mov    QWORD PTR [rsp+0x28],r14
    17f4:	mov    QWORD PTR [rsp+0x30],r15
    17f9:	mov    r12,QWORD PTR [rdi]
    17fc:	mov    rax,QWORD PTR [rdi+0x8]
    1800:	lea    r9,[r12+0x30]
    1805:	cmp    r9,rax
    1808:	ja     19d4 <botlish_fn_13+0x1fc>
    180e:	lea    rax,[r12+0x30]
    1813:	mov    QWORD PTR [rdi],rax
    1816:	mov    r14,rdi
    1819:	mov    QWORD PTR [r12],0x0
    1821:	mov    QWORD PTR [r12+0x8],0x0
    182a:	mov    QWORD PTR [r12+0x10],0x0
    1833:	mov    QWORD PTR [r12+0x18],0x0
    183c:	mov    QWORD PTR [r12+0x20],0x0
    1845:	mov    QWORD PTR [r12+0x28],0x0
    184e:	mov    QWORD PTR [r12],rsi
    1852:	mov    QWORD PTR [r12+0x8],rdx
    1857:	mov    r13,rdx
    185a:	mov    QWORD PTR [r12+0x10],rcx
    185f:	mov    QWORD PTR [r12+0x18],r8
    1864:	mov    rbx,rsi
    1867:	mov    r15,r8
    186a:	mov    QWORD PTR [rsp],rcx
    186e:	mov    rsi,rbx
    1871:	mov    rdi,r14
    1874:	call   1879 <botlish_fn_13+0xa1>
			1875: R_X86_64_PLT32	rt_str_len-0x4
    1879:	mov    rcx,r13
    187c:	and    rcx,rax
    187f:	mov    rdx,rax
    1882:	test   rcx,0x1
    1889:	jne    18af <botlish_fn_13+0xd7>
    188f:	mov    rsi,r13
    1892:	mov    rdi,r14
    1895:	call   189a <botlish_fn_13+0xc2>
			1896: R_X86_64_PLT32	rt_int_cmp-0x4
    189a:	mov    ecx,0x2
    189f:	test   rax,rax
    18a2:	cmovge rcx,QWORD PTR [rip+0x15e]        # 1a08 <botlish_fn_13+0x230>
    18aa:	jmp    18c2 <botlish_fn_13+0xea>
    18af:	mov    ecx,0x2
    18b4:	mov    rax,r13
    18b7:	cmp    rax,rdx
    18ba:	cmovge rcx,QWORD PTR [rip+0x146]        # 1a08 <botlish_fn_13+0x230>
    18c2:	cmp    rcx,0x6
    18c6:	je     1966 <botlish_fn_13+0x18e>
    18cc:	mov    rdi,r14
    18cf:	call   18d4 <botlish_fn_13+0xfc>
			18d0: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    18d4:	test   rax,rax
    18d7:	jne    18e5 <botlish_fn_13+0x10d>
    18dd:	mov    rdi,r14
    18e0:	jmp    1981 <botlish_fn_13+0x1a9>
    18e5:	mov    QWORD PTR [r12+0x20],rax
    18ea:	mov    rcx,rax
    18ed:	mov    QWORD PTR [r12+0x28],rdx
    18f2:	mov    r8,rdx
    18f5:	mov    rdx,r13
    18f8:	mov    rsi,rbx
    18fb:	mov    rdi,r14
    18fe:	call   1903 <botlish_fn_13+0x12b>
			18ff: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_record<str, int, list[mutarray, int]>
    1903:	test   rax,rax
    1906:	jne    1914 <botlish_fn_13+0x13c>
    190c:	mov    rdi,r14
    190f:	jmp    1981 <botlish_fn_13+0x1a9>
    1914:	mov    QWORD PTR [r12+0x8],rax
    1919:	mov    rcx,rax
    191c:	mov    QWORD PTR [r12+0x20],rdx
    1921:	mov    r13,rdx
    1924:	mov    rsi,QWORD PTR [rsp]
    1928:	mov    rdx,r15
    192b:	mov    rdi,r14
    192e:	call   1933 <botlish_fn_13+0x15b>
			192f: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1933:	test   rax,rax
    1936:	jne    1944 <botlish_fn_13+0x16c>
    193c:	mov    rdi,r14
    193f:	jmp    1981 <botlish_fn_13+0x1a9>
    1944:	mov    QWORD PTR [r12],rbx
    1948:	mov    rcx,r13
    194b:	mov    QWORD PTR [r12+0x8],rcx
    1950:	mov    QWORD PTR [r12+0x10],rax
    1955:	mov    QWORD PTR [r12+0x18],rdx
    195a:	mov    r15,rdx
    195d:	mov    QWORD PTR [rsp],rax
    1961:	jmp    186e <botlish_fn_13+0x96>
    1966:	mov    rdx,r15
    1969:	mov    rsi,QWORD PTR [rsp]
    196d:	mov    rdi,r14
    1970:	call   1975 <botlish_fn_13+0x19d>
			1971: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    1975:	test   rax,rax
    1978:	jne    19ac <botlish_fn_13+0x1d4>
    197e:	mov    rdi,r14
    1981:	mov    rdi,r14
    1984:	mov    QWORD PTR [rdi],r12
    1987:	xor    rax,rax
    198a:	mov    rbx,QWORD PTR [rsp+0x10]
    198f:	mov    r12,QWORD PTR [rsp+0x18]
    1994:	mov    r13,QWORD PTR [rsp+0x20]
    1999:	mov    r14,QWORD PTR [rsp+0x28]
    199e:	mov    r15,QWORD PTR [rsp+0x30]
    19a3:	add    rsp,0x40
    19a7:	mov    rsp,rbp
    19aa:	pop    rbp
    19ab:	ret
    19ac:	mov    rdi,r14
    19af:	mov    QWORD PTR [rdi],r12
    19b2:	mov    rbx,QWORD PTR [rsp+0x10]
    19b7:	mov    r12,QWORD PTR [rsp+0x18]
    19bc:	mov    r13,QWORD PTR [rsp+0x20]
    19c1:	mov    r14,QWORD PTR [rsp+0x28]
    19c6:	mov    r15,QWORD PTR [rsp+0x30]
    19cb:	add    rsp,0x40
    19cf:	mov    rsp,rbp
    19d2:	pop    rbp
    19d3:	ret
    19d4:	mov    r14,rdi
    19d7:	call   19dc <botlish_fn_13+0x204>
			19d8: R_X86_64_PLT32	rt_stack_overflow-0x4
    19dc:	xor    rax,rax
    19df:	mov    rbx,QWORD PTR [rsp+0x10]
    19e4:	mov    r12,QWORD PTR [rsp+0x18]
    19e9:	mov    r13,QWORD PTR [rsp+0x20]
    19ee:	mov    r14,QWORD PTR [rsp+0x28]
    19f3:	mov    r15,QWORD PTR [rsp+0x30]
    19f8:	add    rsp,0x40
    19fc:	mov    rsp,rbp
    19ff:	pop    rbp
    1a00:	ret
    1a01:	add    BYTE PTR [rax],al
    1a03:	add    BYTE PTR [rax],al
    1a05:	add    BYTE PTR [rax],al
    1a07:	add    BYTE PTR [rsi],al
    1a09:	add    BYTE PTR [rax],al
    1a0b:	add    BYTE PTR [rax],al
    1a0d:	add    BYTE PTR [rax],al
	...

0000000000001a10 <botlish_entry_13: scan_records<str, int, list[mutarray, int]>>:
    1a10:	push   rbp
    1a11:	mov    rbp,rsp
    1a14:	mov    rsi,QWORD PTR [rdx]
    1a17:	mov    r9,QWORD PTR [rdx+0x8]
    1a1b:	mov    rcx,QWORD PTR [rdx+0x10]
    1a1f:	mov    r8,QWORD PTR [rdx+0x18]
    1a23:	mov    rdx,r9
    1a26:	call   1a2b <botlish_entry_13+0x1b>
			1a27: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    1a2b:	mov    rsp,rbp
    1a2e:	pop    rbp
    1a2f:	ret

0000000000001a30 <botlish_fn_14: csv_parse<str>>:
    1a30:	push   rbp
    1a31:	mov    rbp,rsp
    1a34:	sub    rsp,0x20
    1a38:	mov    QWORD PTR [rsp],rbx
    1a3c:	mov    QWORD PTR [rsp+0x8],r12
    1a41:	mov    QWORD PTR [rsp+0x10],r15
    1a46:	mov    r15,QWORD PTR [rdi]
    1a49:	mov    rax,QWORD PTR [rdi+0x8]
    1a4d:	lea    rcx,[r15+0x20]
    1a51:	cmp    rcx,rax
    1a54:	ja     1b11 <botlish_fn_14+0xe1>
    1a5a:	lea    rax,[r15+0x20]
    1a5e:	mov    QWORD PTR [rdi],rax
    1a61:	mov    rbx,rdi
    1a64:	mov    QWORD PTR [r15],0x0
    1a6b:	mov    QWORD PTR [r15+0x8],0x0
    1a73:	mov    QWORD PTR [r15+0x10],0x0
    1a7b:	mov    QWORD PTR [r15+0x18],0x0
    1a83:	mov    QWORD PTR [r15],rsi
    1a86:	mov    r12,rsi
    1a89:	mov    QWORD PTR [r15+0x8],0x1
    1a91:	mov    rdi,rbx
    1a94:	call   1a99 <botlish_fn_14+0x69>
			1a95: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1a99:	test   rax,rax
    1a9c:	jne    1aaa <botlish_fn_14+0x7a>
    1aa2:	mov    rdi,rbx
    1aa5:	jmp    1ad4 <botlish_fn_14+0xa4>
    1aaa:	mov    QWORD PTR [r15+0x10],rax
    1aae:	mov    rcx,rax
    1ab1:	mov    QWORD PTR [r15+0x18],rdx
    1ab5:	mov    r8,rdx
    1ab8:	mov    edx,0x1
    1abd:	mov    rsi,r12
    1ac0:	mov    rdi,rbx
    1ac3:	call   1ac8 <botlish_fn_14+0x98>
			1ac4: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    1ac8:	test   rax,rax
    1acb:	jne    1af4 <botlish_fn_14+0xc4>
    1ad1:	mov    rdi,rbx
    1ad4:	mov    rdi,rbx
    1ad7:	mov    QWORD PTR [rdi],r15
    1ada:	xor    rax,rax
    1add:	mov    rbx,QWORD PTR [rsp]
    1ae1:	mov    r12,QWORD PTR [rsp+0x8]
    1ae6:	mov    r15,QWORD PTR [rsp+0x10]
    1aeb:	add    rsp,0x20
    1aef:	mov    rsp,rbp
    1af2:	pop    rbp
    1af3:	ret
    1af4:	mov    rdi,rbx
    1af7:	mov    QWORD PTR [rdi],r15
    1afa:	mov    rbx,QWORD PTR [rsp]
    1afe:	mov    r12,QWORD PTR [rsp+0x8]
    1b03:	mov    r15,QWORD PTR [rsp+0x10]
    1b08:	add    rsp,0x20
    1b0c:	mov    rsp,rbp
    1b0f:	pop    rbp
    1b10:	ret
    1b11:	mov    rbx,rdi
    1b14:	call   1b19 <botlish_fn_14+0xe9>
			1b15: R_X86_64_PLT32	rt_stack_overflow-0x4
    1b19:	xor    rax,rax
    1b1c:	mov    rbx,QWORD PTR [rsp]
    1b20:	mov    r12,QWORD PTR [rsp+0x8]
    1b25:	mov    r15,QWORD PTR [rsp+0x10]
    1b2a:	add    rsp,0x20
    1b2e:	mov    rsp,rbp
    1b31:	pop    rbp
    1b32:	ret

0000000000001b33 <botlish_entry_14: csv_parse<str>>:
    1b33:	push   rbp
    1b34:	mov    rbp,rsp
    1b37:	mov    rsi,QWORD PTR [rdx]
    1b3a:	call   1b3f <botlish_entry_14+0xc>
			1b3b: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
    1b3f:	mov    rsp,rbp
    1b42:	pop    rbp
    1b43:	ret

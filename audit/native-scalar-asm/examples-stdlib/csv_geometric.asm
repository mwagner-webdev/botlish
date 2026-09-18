; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 7751  (per function: 176 271 485 541 571 571 332 501 558 698 913 482 828 556 268)
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
       8:	mov    QWORD PTR [rsp],r14
       c:	mov    QWORD PTR [rsp+0x8],r15
      11:	mov    r14,QWORD PTR [rdi]
      14:	mov    rax,QWORD PTR [rdi+0x8]
      18:	lea    rcx,[r14+0x8]
      1c:	cmp    rcx,rax
      1f:	ja     81 <botlish_fn_0+0x81>
      25:	lea    rax,[r14+0x8]
      29:	mov    QWORD PTR [rdi],rax
      2c:	mov    QWORD PTR [r14],0x0
      33:	mov    rax,QWORD PTR [rdi+0x10]
      37:	mov    r15,rdi
      3a:	mov    rsi,QWORD PTR [rax]
      3d:	mov    QWORD PTR [r14],rsi
      40:	call   45 <botlish_fn_0+0x45>
			41: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
      45:	test   rax,rax
      48:	jne    69 <botlish_fn_0+0x69>
      4e:	mov    rdi,r15
      51:	mov    QWORD PTR [rdi],r14
      54:	xor    rax,rax
      57:	mov    r14,QWORD PTR [rsp]
      5b:	mov    r15,QWORD PTR [rsp+0x8]
      60:	add    rsp,0x10
      64:	mov    rsp,rbp
      67:	pop    rbp
      68:	ret
      69:	mov    rdi,r15
      6c:	mov    QWORD PTR [rdi],r14
      6f:	mov    r14,QWORD PTR [rsp]
      73:	mov    r15,QWORD PTR [rsp+0x8]
      78:	add    rsp,0x10
      7c:	mov    rsp,rbp
      7f:	pop    rbp
      80:	ret
      81:	mov    rax,QWORD PTR [rip+0x0]        # 88 <botlish_fn_0+0x88>
			84: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
      88:	call   rax
      8a:	xor    rax,rax
      8d:	mov    r14,QWORD PTR [rsp]
      91:	mov    r15,QWORD PTR [rsp+0x8]
      96:	add    rsp,0x10
      9a:	mov    rsp,rbp
      9d:	pop    rbp
      9e:	ret

000000000000009f <botlish_entry_0: <program entry>>:
      9f:	push   rbp
      a0:	mov    rbp,rsp
      a3:	call   a8 <botlish_entry_0+0x9>
			a4: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      a8:	mov    rsp,rbp
      ab:	pop    rbp
      ac:	ret

00000000000000ad <botlish_fn_1: geo_new<generic>>:
      ad:	push   rbp
      ae:	mov    rbp,rsp
      b1:	sub    rsp,0x20
      b5:	mov    QWORD PTR [rsp+0x10],rbx
      ba:	mov    QWORD PTR [rsp+0x18],r12
      bf:	mov    rbx,QWORD PTR [rdi]
      c2:	mov    rax,QWORD PTR [rdi+0x8]
      c6:	lea    rcx,[rbx+0x10]
      ca:	cmp    rcx,rax
      cd:	ja     183 <botlish_fn_1+0xd6>
      d3:	lea    rax,[rbx+0x10]
      d7:	mov    QWORD PTR [rdi],rax
      da:	mov    r12,rdi
      dd:	mov    QWORD PTR [rbx],0x0
      e4:	mov    QWORD PTR [rbx+0x8],0x0
      ec:	mov    esi,0x1
      f1:	mov    QWORD PTR [rbx],0x1
      f8:	mov    rax,QWORD PTR [rip+0x0]        # ff <botlish_fn_1+0x52>
			fb: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
      ff:	mov    rdi,r12
     102:	call   rax
     104:	test   rax,rax
     107:	jne    115 <botlish_fn_1+0x68>
     10d:	mov    rdi,r12
     110:	jmp    14e <botlish_fn_1+0xa1>
     115:	mov    QWORD PTR [rbx],rax
     118:	mov    QWORD PTR [rbx+0x8],0x1
     120:	lea    rdx,[rsp]
     124:	mov    QWORD PTR [rsp],rax
     128:	mov    QWORD PTR [rsp+0x8],0x1
     131:	mov    esi,0x2
     136:	mov    rax,QWORD PTR [rip+0x0]        # 13d <botlish_fn_1+0x90>
			139: R_X86_64_GOTPCREL	rt_list_new-0x4
     13d:	mov    rdi,r12
     140:	call   rax
     142:	test   rax,rax
     145:	jne    16a <botlish_fn_1+0xbd>
     14b:	mov    rdi,r12
     14e:	mov    rdi,r12
     151:	mov    QWORD PTR [rdi],rbx
     154:	xor    rax,rax
     157:	mov    rbx,QWORD PTR [rsp+0x10]
     15c:	mov    r12,QWORD PTR [rsp+0x18]
     161:	add    rsp,0x20
     165:	mov    rsp,rbp
     168:	pop    rbp
     169:	ret
     16a:	mov    rdi,r12
     16d:	mov    QWORD PTR [rdi],rbx
     170:	mov    rbx,QWORD PTR [rsp+0x10]
     175:	mov    r12,QWORD PTR [rsp+0x18]
     17a:	add    rsp,0x20
     17e:	mov    rsp,rbp
     181:	pop    rbp
     182:	ret
     183:	mov    r12,rdi
     186:	mov    rax,QWORD PTR [rip+0x0]        # 18d <botlish_fn_1+0xe0>
			189: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     18d:	call   rax
     18f:	xor    rax,rax
     192:	mov    rbx,QWORD PTR [rsp+0x10]
     197:	mov    r12,QWORD PTR [rsp+0x18]
     19c:	add    rsp,0x20
     1a0:	mov    rsp,rbp
     1a3:	pop    rbp
     1a4:	ret

00000000000001a5 <botlish_entry_1: geo_new<generic>>:
     1a5:	push   rbp
     1a6:	mov    rbp,rsp
     1a9:	call   1ae <botlish_entry_1+0x9>
			1aa: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
     1ae:	mov    rsp,rbp
     1b1:	pop    rbp
     1b2:	ret
     1b3:	add    BYTE PTR [rax],al
     1b5:	add    BYTE PTR [rax],al
	...

00000000000001b8 <botlish_fn_2: geo_new_capacity<int, int>>:
     1b8:	push   rbp
     1b9:	mov    rbp,rsp
     1bc:	sub    rsp,0x20
     1c0:	mov    QWORD PTR [rsp],rbx
     1c4:	mov    QWORD PTR [rsp+0x8],r12
     1c9:	mov    QWORD PTR [rsp+0x10],r13
     1ce:	mov    QWORD PTR [rsp+0x18],r14
     1d3:	mov    rbx,QWORD PTR [rdi]
     1d6:	mov    rax,QWORD PTR [rdi+0x8]
     1da:	lea    rcx,[rbx+0x18]
     1de:	cmp    rcx,rax
     1e1:	ja     33d <botlish_fn_2+0x185>
     1e7:	lea    rax,[rbx+0x18]
     1eb:	mov    QWORD PTR [rdi],rax
     1ee:	mov    r13,rdi
     1f1:	mov    QWORD PTR [rbx],0x0
     1f8:	mov    QWORD PTR [rbx+0x8],0x0
     200:	mov    QWORD PTR [rbx+0x10],0x0
     208:	mov    QWORD PTR [rbx],rsi
     20b:	mov    QWORD PTR [rbx+0x8],rdx
     20f:	mov    r12,rdx
     212:	mov    QWORD PTR [rbx+0x10],0x5
     21a:	test   rsi,0x1
     221:	je     243 <botlish_fn_2+0x8b>
     227:	mov    rax,rsi
     22a:	sar    rax,1
     22d:	imul   QWORD PTR [rip+0x13c]        # 370 <botlish_fn_2+0x1b8>
     234:	seto   cl
     237:	or     rax,0x1
     23b:	test   cl,cl
     23d:	je     254 <botlish_fn_2+0x9c>
     243:	mov    edx,0x5
     248:	mov    rax,QWORD PTR [rip+0x0]        # 24f <botlish_fn_2+0x97>
			24b: R_X86_64_GOTPCREL	rt_int_mul-0x4
     24f:	mov    rdi,r13
     252:	call   rax
     254:	mov    rcx,rax
     257:	and    rcx,r12
     25a:	mov    r14,rax
     25d:	test   rcx,0x1
     264:	jne    294 <botlish_fn_2+0xdc>
     26a:	mov    rax,QWORD PTR [rip+0x0]        # 271 <botlish_fn_2+0xb9>
			26d: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     271:	mov    rdx,r12
     274:	mov    rsi,r14
     277:	mov    rdi,r13
     27a:	call   rax
     27c:	mov    ecx,0x2
     281:	test   rax,rax
     284:	cmovle rcx,QWORD PTR [rip+0xec]        # 378 <botlish_fn_2+0x1c0>
     28c:	mov    rax,r14
     28f:	jmp    2a7 <botlish_fn_2+0xef>
     294:	mov    ecx,0x2
     299:	mov    rax,r14
     29c:	cmp    rax,r12
     29f:	cmovle rcx,QWORD PTR [rip+0xd1]        # 378 <botlish_fn_2+0x1c0>
     2a7:	cmp    rcx,0x6
     2ab:	je     2d3 <botlish_fn_2+0x11b>
     2b1:	mov    rdi,r13
     2b4:	mov    QWORD PTR [rdi],rbx
     2b7:	mov    rbx,QWORD PTR [rsp]
     2bb:	mov    r12,QWORD PTR [rsp+0x8]
     2c0:	mov    r13,QWORD PTR [rsp+0x10]
     2c5:	mov    r14,QWORD PTR [rsp+0x18]
     2ca:	add    rsp,0x20
     2ce:	mov    rsp,rbp
     2d1:	pop    rbp
     2d2:	ret
     2d3:	mov    QWORD PTR [rbx],0x3
     2da:	test   r12,0x1
     2e1:	je     303 <botlish_fn_2+0x14b>
     2e7:	mov    rax,r12
     2ea:	add    rax,0x2
     2ee:	seto   sil
     2f2:	test   sil,sil
     2f5:	jne    303 <botlish_fn_2+0x14b>
     2fb:	mov    rdi,r13
     2fe:	jmp    31b <botlish_fn_2+0x163>
     303:	mov    edx,0x3
     308:	mov    r8,QWORD PTR [rip+0x0]        # 30f <botlish_fn_2+0x157>
			30b: R_X86_64_GOTPCREL	rt_int_add-0x4
     30f:	mov    rsi,r12
     312:	mov    rdi,r13
     315:	call   r8
     318:	mov    rdi,r13
     31b:	mov    rdi,r13
     31e:	mov    QWORD PTR [rdi],rbx
     321:	mov    rbx,QWORD PTR [rsp]
     325:	mov    r12,QWORD PTR [rsp+0x8]
     32a:	mov    r13,QWORD PTR [rsp+0x10]
     32f:	mov    r14,QWORD PTR [rsp+0x18]
     334:	add    rsp,0x20
     338:	mov    rsp,rbp
     33b:	pop    rbp
     33c:	ret
     33d:	mov    r13,rdi
     340:	mov    r10,QWORD PTR [rip+0x0]        # 347 <botlish_fn_2+0x18f>
			343: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     347:	call   r10
     34a:	xor    rax,rax
     34d:	mov    rbx,QWORD PTR [rsp]
     351:	mov    r12,QWORD PTR [rsp+0x8]
     356:	mov    r13,QWORD PTR [rsp+0x10]
     35b:	mov    r14,QWORD PTR [rsp+0x18]
     360:	add    rsp,0x20
     364:	mov    rsp,rbp
     367:	pop    rbp
     368:	ret
     369:	add    BYTE PTR [rax],al
     36b:	add    BYTE PTR [rax],al
     36d:	add    BYTE PTR [rax],al
     36f:	add    BYTE PTR [rax+rax*1],al
     372:	add    BYTE PTR [rax],al
     374:	add    BYTE PTR [rax],al
     376:	add    BYTE PTR [rax],al
     378:	(bad)
     379:	add    BYTE PTR [rax],al
     37b:	add    BYTE PTR [rax],al
     37d:	add    BYTE PTR [rax],al
	...

0000000000000380 <botlish_entry_2: geo_new_capacity<int, int>>:
     380:	push   rbp
     381:	mov    rbp,rsp
     384:	mov    rsi,QWORD PTR [rdx]
     387:	mov    rdx,QWORD PTR [rdx+0x8]
     38b:	call   390 <botlish_entry_2+0x10>
			38c: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     390:	mov    rsp,rbp
     393:	pop    rbp
     394:	ret
     395:	add    BYTE PTR [rax],al
	...

0000000000000398 <botlish_fn_3: geo_grow<mutarray, int>>:
     398:	push   rbp
     399:	mov    rbp,rsp
     39c:	sub    rsp,0x30
     3a0:	mov    QWORD PTR [rsp],rbx
     3a4:	mov    QWORD PTR [rsp+0x8],r12
     3a9:	mov    QWORD PTR [rsp+0x10],r13
     3ae:	mov    QWORD PTR [rsp+0x18],r14
     3b3:	mov    QWORD PTR [rsp+0x20],r15
     3b8:	mov    rbx,QWORD PTR [rdi]
     3bb:	mov    rax,QWORD PTR [rdi+0x8]
     3bf:	lea    rcx,[rbx+0x18]
     3c3:	cmp    rcx,rax
     3c6:	ja     558 <botlish_fn_3+0x1c0>
     3cc:	lea    rax,[rbx+0x18]
     3d0:	mov    QWORD PTR [rdi],rax
     3d3:	mov    r13,rdi
     3d6:	mov    QWORD PTR [rbx],0x0
     3dd:	mov    QWORD PTR [rbx+0x8],0x0
     3e5:	mov    QWORD PTR [rbx+0x10],0x0
     3ed:	mov    QWORD PTR [rbx],rsi
     3f0:	mov    r14,rsi
     3f3:	mov    QWORD PTR [rbx+0x8],rdx
     3f7:	mov    r12,rdx
     3fa:	mov    rax,QWORD PTR [rip+0x0]        # 401 <botlish_fn_3+0x69>
			3fd: R_X86_64_GOTPCREL	rt_mutarray_capacity-0x4
     401:	mov    rsi,r14
     404:	mov    rdi,r13
     407:	call   rax
     409:	mov    r15,rax
     40c:	mov    QWORD PTR [rbx+0x10],rax
     410:	mov    rcx,r12
     413:	and    rcx,rax
     416:	test   rcx,0x1
     41d:	jne    44d <botlish_fn_3+0xb5>
     423:	mov    rax,QWORD PTR [rip+0x0]        # 42a <botlish_fn_3+0x92>
			426: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     42a:	mov    rdx,r15
     42d:	mov    rsi,r12
     430:	mov    rdi,r13
     433:	call   rax
     435:	mov    ecx,0x2
     43a:	test   rax,rax
     43d:	cmovl  rcx,QWORD PTR [rip+0x143]        # 588 <botlish_fn_3+0x1f0>
     445:	mov    rax,r15
     448:	jmp    460 <botlish_fn_3+0xc8>
     44d:	mov    ecx,0x2
     452:	mov    rax,r15
     455:	cmp    r12,rax
     458:	cmovl  rcx,QWORD PTR [rip+0x128]        # 588 <botlish_fn_3+0x1f0>
     460:	cmp    rcx,0x6
     464:	je     52e <botlish_fn_3+0x196>
     46a:	mov    rsi,rax
     46d:	mov    rdx,r12
     470:	mov    rdi,r13
     473:	call   478 <botlish_fn_3+0xe0>
			474: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     478:	test   rax,rax
     47b:	jne    489 <botlish_fn_3+0xf1>
     481:	mov    rdi,r13
     484:	jmp    4da <botlish_fn_3+0x142>
     489:	mov    QWORD PTR [rbx+0x10],rax
     48d:	mov    rsi,rax
     490:	mov    rax,QWORD PTR [rip+0x0]        # 497 <botlish_fn_3+0xff>
			493: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     497:	mov    rdi,r13
     49a:	call   rax
     49c:	test   rax,rax
     49f:	mov    r15,rax
     4a2:	jne    4b0 <botlish_fn_3+0x118>
     4a8:	mov    rdi,r13
     4ab:	jmp    4da <botlish_fn_3+0x142>
     4b0:	mov    r8d,0x1
     4b6:	mov    rax,QWORD PTR [rip+0x0]        # 4bd <botlish_fn_3+0x125>
			4b9: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
     4bd:	mov    rcx,r14
     4c0:	mov    r9,r12
     4c3:	mov    rsi,r15
     4c6:	mov    rdi,r13
     4c9:	mov    rdx,r8
     4cc:	call   rax
     4ce:	test   rax,rax
     4d1:	jne    504 <botlish_fn_3+0x16c>
     4d7:	mov    rdi,r13
     4da:	mov    rdi,r13
     4dd:	mov    QWORD PTR [rdi],rbx
     4e0:	xor    rax,rax
     4e3:	mov    rbx,QWORD PTR [rsp]
     4e7:	mov    r12,QWORD PTR [rsp+0x8]
     4ec:	mov    r13,QWORD PTR [rsp+0x10]
     4f1:	mov    r14,QWORD PTR [rsp+0x18]
     4f6:	mov    r15,QWORD PTR [rsp+0x20]
     4fb:	add    rsp,0x30
     4ff:	mov    rsp,rbp
     502:	pop    rbp
     503:	ret
     504:	mov    rdi,r13
     507:	mov    QWORD PTR [rdi],rbx
     50a:	mov    rax,r15
     50d:	mov    rbx,QWORD PTR [rsp]
     511:	mov    r12,QWORD PTR [rsp+0x8]
     516:	mov    r13,QWORD PTR [rsp+0x10]
     51b:	mov    r14,QWORD PTR [rsp+0x18]
     520:	mov    r15,QWORD PTR [rsp+0x20]
     525:	add    rsp,0x30
     529:	mov    rsp,rbp
     52c:	pop    rbp
     52d:	ret
     52e:	mov    rdi,r13
     531:	mov    QWORD PTR [rdi],rbx
     534:	mov    rax,r14
     537:	mov    rbx,QWORD PTR [rsp]
     53b:	mov    r12,QWORD PTR [rsp+0x8]
     540:	mov    r13,QWORD PTR [rsp+0x10]
     545:	mov    r14,QWORD PTR [rsp+0x18]
     54a:	mov    r15,QWORD PTR [rsp+0x20]
     54f:	add    rsp,0x30
     553:	mov    rsp,rbp
     556:	pop    rbp
     557:	ret
     558:	mov    r13,rdi
     55b:	mov    rcx,QWORD PTR [rip+0x0]        # 562 <botlish_fn_3+0x1ca>
			55e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     562:	call   rcx
     564:	xor    rax,rax
     567:	mov    rbx,QWORD PTR [rsp]
     56b:	mov    r12,QWORD PTR [rsp+0x8]
     570:	mov    r13,QWORD PTR [rsp+0x10]
     575:	mov    r14,QWORD PTR [rsp+0x18]
     57a:	mov    r15,QWORD PTR [rsp+0x20]
     57f:	add    rsp,0x30
     583:	mov    rsp,rbp
     586:	pop    rbp
     587:	ret
     588:	(bad)
     589:	add    BYTE PTR [rax],al
     58b:	add    BYTE PTR [rax],al
     58d:	add    BYTE PTR [rax],al
	...

0000000000000590 <botlish_entry_3: geo_grow<mutarray, int>>:
     590:	push   rbp
     591:	mov    rbp,rsp
     594:	mov    rsi,QWORD PTR [rdx]
     597:	mov    rdx,QWORD PTR [rdx+0x8]
     59b:	call   5a0 <botlish_entry_3+0x10>
			59c: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     5a0:	mov    rsp,rbp
     5a3:	pop    rbp
     5a4:	ret

00000000000005a5 <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     5a5:	push   rbp
     5a6:	mov    rbp,rsp
     5a9:	sub    rsp,0x50
     5ad:	mov    QWORD PTR [rsp+0x20],rbx
     5b2:	mov    QWORD PTR [rsp+0x28],r12
     5b7:	mov    QWORD PTR [rsp+0x30],r13
     5bc:	mov    QWORD PTR [rsp+0x38],r14
     5c1:	mov    QWORD PTR [rsp+0x40],r15
     5c6:	mov    r12,rsi
     5c9:	mov    rbx,QWORD PTR [rdi]
     5cc:	mov    rax,QWORD PTR [rdi+0x8]
     5d0:	lea    rcx,[rbx+0x18]
     5d4:	cmp    rcx,rax
     5d7:	ja     787 <botlish_fn_4+0x1e2>
     5dd:	lea    rax,[rbx+0x18]
     5e1:	mov    QWORD PTR [rdi],rax
     5e4:	mov    r14,rdi
     5e7:	mov    QWORD PTR [rbx],0x0
     5ee:	mov    QWORD PTR [rbx+0x8],0x0
     5f6:	mov    QWORD PTR [rbx+0x10],0x0
     5fe:	mov    QWORD PTR [rbx],rdx
     601:	mov    r13,rdx
     604:	mov    edx,0x1
     609:	mov    rax,QWORD PTR [rip+0x0]        # 610 <botlish_fn_4+0x6b>
			60c: R_X86_64_GOTPCREL	rt_list_get-0x4
     610:	mov    rsi,r12
     613:	mov    rdi,r14
     616:	call   rax
     618:	test   rax,rax
     61b:	jne    629 <botlish_fn_4+0x84>
     621:	mov    rdi,r14
     624:	jmp    734 <botlish_fn_4+0x18f>
     629:	mov    QWORD PTR [rbx+0x8],rax
     62d:	mov    QWORD PTR [rsp+0x10],rax
     632:	mov    edx,0x3
     637:	mov    rax,QWORD PTR [rip+0x0]        # 63e <botlish_fn_4+0x99>
			63a: R_X86_64_GOTPCREL	rt_list_get-0x4
     63e:	mov    rsi,r12
     641:	mov    rdi,r14
     644:	call   rax
     646:	mov    rcx,rax
     649:	mov    r15,rax
     64c:	test   rax,rcx
     64f:	jne    65d <botlish_fn_4+0xb8>
     655:	mov    rdi,r14
     658:	jmp    734 <botlish_fn_4+0x18f>
     65d:	mov    rax,r15
     660:	mov    QWORD PTR [rbx+0x10],rax
     664:	mov    rsi,QWORD PTR [rsp+0x10]
     669:	mov    rdx,r15
     66c:	mov    rdi,r14
     66f:	call   674 <botlish_fn_4+0xcf>
			670: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     674:	mov    r12,rax
     677:	test   r12,r12
     67a:	jne    688 <botlish_fn_4+0xe3>
     680:	mov    rdi,r14
     683:	jmp    734 <botlish_fn_4+0x18f>
     688:	mov    QWORD PTR [rbx],r12
     68b:	mov    rax,QWORD PTR [rip+0x0]        # 692 <botlish_fn_4+0xed>
			68e: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     692:	mov    rcx,r13
     695:	mov    r13,r15
     698:	mov    rdx,r13
     69b:	mov    rsi,r12
     69e:	mov    rdi,r14
     6a1:	call   rax
     6a3:	test   rax,rax
     6a6:	jne    6b4 <botlish_fn_4+0x10f>
     6ac:	mov    rdi,r14
     6af:	jmp    734 <botlish_fn_4+0x18f>
     6b4:	mov    QWORD PTR [rbx+0x8],0x3
     6bc:	test   r13,0x1
     6c3:	jne    6d1 <botlish_fn_4+0x12c>
     6c9:	mov    r15,r13
     6cc:	jmp    6f1 <botlish_fn_4+0x14c>
     6d1:	mov    rax,r13
     6d4:	add    rax,0x2
     6d8:	mov    rcx,rax
     6db:	mov    r15,r13
     6de:	seto   al
     6e1:	test   al,al
     6e3:	jne    6f1 <botlish_fn_4+0x14c>
     6e9:	mov    rax,rcx
     6ec:	jmp    705 <botlish_fn_4+0x160>
     6f1:	mov    edx,0x3
     6f6:	mov    rax,QWORD PTR [rip+0x0]        # 6fd <botlish_fn_4+0x158>
			6f9: R_X86_64_GOTPCREL	rt_int_add-0x4
     6fd:	mov    rsi,r15
     700:	mov    rdi,r14
     703:	call   rax
     705:	mov    QWORD PTR [rbx+0x8],rax
     709:	lea    rdx,[rsp]
     70d:	mov    QWORD PTR [rsp],r12
     711:	mov    QWORD PTR [rsp+0x8],rax
     716:	mov    esi,0x2
     71b:	mov    r8,QWORD PTR [rip+0x0]        # 722 <botlish_fn_4+0x17d>
			71e: R_X86_64_GOTPCREL	rt_list_new-0x4
     722:	mov    rdi,r14
     725:	call   r8
     728:	test   rax,rax
     72b:	jne    75f <botlish_fn_4+0x1ba>
     731:	mov    rdi,r14
     734:	mov    rdi,r14
     737:	mov    QWORD PTR [rdi],rbx
     73a:	xor    rax,rax
     73d:	mov    rbx,QWORD PTR [rsp+0x20]
     742:	mov    r12,QWORD PTR [rsp+0x28]
     747:	mov    r13,QWORD PTR [rsp+0x30]
     74c:	mov    r14,QWORD PTR [rsp+0x38]
     751:	mov    r15,QWORD PTR [rsp+0x40]
     756:	add    rsp,0x50
     75a:	mov    rsp,rbp
     75d:	pop    rbp
     75e:	ret
     75f:	mov    rdi,r14
     762:	mov    QWORD PTR [rdi],rbx
     765:	mov    rbx,QWORD PTR [rsp+0x20]
     76a:	mov    r12,QWORD PTR [rsp+0x28]
     76f:	mov    r13,QWORD PTR [rsp+0x30]
     774:	mov    r14,QWORD PTR [rsp+0x38]
     779:	mov    r15,QWORD PTR [rsp+0x40]
     77e:	add    rsp,0x50
     782:	mov    rsp,rbp
     785:	pop    rbp
     786:	ret
     787:	mov    r14,rdi
     78a:	mov    r11,QWORD PTR [rip+0x0]        # 791 <botlish_fn_4+0x1ec>
			78d: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     791:	call   r11
     794:	xor    rax,rax
     797:	mov    rbx,QWORD PTR [rsp+0x20]
     79c:	mov    r12,QWORD PTR [rsp+0x28]
     7a1:	mov    r13,QWORD PTR [rsp+0x30]
     7a6:	mov    r14,QWORD PTR [rsp+0x38]
     7ab:	mov    r15,QWORD PTR [rsp+0x40]
     7b0:	add    rsp,0x50
     7b4:	mov    rsp,rbp
     7b7:	pop    rbp
     7b8:	ret

00000000000007b9 <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     7b9:	push   rbp
     7ba:	mov    rbp,rsp
     7bd:	mov    rsi,QWORD PTR [rdx]
     7c0:	mov    rdx,QWORD PTR [rdx+0x8]
     7c4:	call   7c9 <botlish_entry_4+0x10>
			7c5: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
     7c9:	mov    rsp,rbp
     7cc:	pop    rbp
     7cd:	ret

00000000000007ce <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     7ce:	push   rbp
     7cf:	mov    rbp,rsp
     7d2:	sub    rsp,0x50
     7d6:	mov    QWORD PTR [rsp+0x20],rbx
     7db:	mov    QWORD PTR [rsp+0x28],r12
     7e0:	mov    QWORD PTR [rsp+0x30],r13
     7e5:	mov    QWORD PTR [rsp+0x38],r14
     7ea:	mov    QWORD PTR [rsp+0x40],r15
     7ef:	mov    r12,rsi
     7f2:	mov    rbx,QWORD PTR [rdi]
     7f5:	mov    rax,QWORD PTR [rdi+0x8]
     7f9:	lea    rcx,[rbx+0x18]
     7fd:	cmp    rcx,rax
     800:	ja     9b0 <botlish_fn_5+0x1e2>
     806:	lea    rax,[rbx+0x18]
     80a:	mov    QWORD PTR [rdi],rax
     80d:	mov    r14,rdi
     810:	mov    QWORD PTR [rbx],0x0
     817:	mov    QWORD PTR [rbx+0x8],0x0
     81f:	mov    QWORD PTR [rbx+0x10],0x0
     827:	mov    QWORD PTR [rbx],rdx
     82a:	mov    r13,rdx
     82d:	mov    edx,0x1
     832:	mov    rax,QWORD PTR [rip+0x0]        # 839 <botlish_fn_5+0x6b>
			835: R_X86_64_GOTPCREL	rt_list_get-0x4
     839:	mov    rsi,r12
     83c:	mov    rdi,r14
     83f:	call   rax
     841:	test   rax,rax
     844:	jne    852 <botlish_fn_5+0x84>
     84a:	mov    rdi,r14
     84d:	jmp    95d <botlish_fn_5+0x18f>
     852:	mov    QWORD PTR [rbx+0x8],rax
     856:	mov    QWORD PTR [rsp+0x10],rax
     85b:	mov    edx,0x3
     860:	mov    rax,QWORD PTR [rip+0x0]        # 867 <botlish_fn_5+0x99>
			863: R_X86_64_GOTPCREL	rt_list_get-0x4
     867:	mov    rsi,r12
     86a:	mov    rdi,r14
     86d:	call   rax
     86f:	mov    rcx,rax
     872:	mov    r15,rax
     875:	test   rax,rcx
     878:	jne    886 <botlish_fn_5+0xb8>
     87e:	mov    rdi,r14
     881:	jmp    95d <botlish_fn_5+0x18f>
     886:	mov    rax,r15
     889:	mov    QWORD PTR [rbx+0x10],rax
     88d:	mov    rsi,QWORD PTR [rsp+0x10]
     892:	mov    rdx,r15
     895:	mov    rdi,r14
     898:	call   89d <botlish_fn_5+0xcf>
			899: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     89d:	mov    r12,rax
     8a0:	test   r12,r12
     8a3:	jne    8b1 <botlish_fn_5+0xe3>
     8a9:	mov    rdi,r14
     8ac:	jmp    95d <botlish_fn_5+0x18f>
     8b1:	mov    QWORD PTR [rbx],r12
     8b4:	mov    rax,QWORD PTR [rip+0x0]        # 8bb <botlish_fn_5+0xed>
			8b7: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     8bb:	mov    rcx,r13
     8be:	mov    r13,r15
     8c1:	mov    rdx,r13
     8c4:	mov    rsi,r12
     8c7:	mov    rdi,r14
     8ca:	call   rax
     8cc:	test   rax,rax
     8cf:	jne    8dd <botlish_fn_5+0x10f>
     8d5:	mov    rdi,r14
     8d8:	jmp    95d <botlish_fn_5+0x18f>
     8dd:	mov    QWORD PTR [rbx+0x8],0x3
     8e5:	test   r13,0x1
     8ec:	jne    8fa <botlish_fn_5+0x12c>
     8f2:	mov    r15,r13
     8f5:	jmp    91a <botlish_fn_5+0x14c>
     8fa:	mov    rax,r13
     8fd:	add    rax,0x2
     901:	mov    rcx,rax
     904:	mov    r15,r13
     907:	seto   al
     90a:	test   al,al
     90c:	jne    91a <botlish_fn_5+0x14c>
     912:	mov    rax,rcx
     915:	jmp    92e <botlish_fn_5+0x160>
     91a:	mov    edx,0x3
     91f:	mov    rax,QWORD PTR [rip+0x0]        # 926 <botlish_fn_5+0x158>
			922: R_X86_64_GOTPCREL	rt_int_add-0x4
     926:	mov    rsi,r15
     929:	mov    rdi,r14
     92c:	call   rax
     92e:	mov    QWORD PTR [rbx+0x8],rax
     932:	lea    rdx,[rsp]
     936:	mov    QWORD PTR [rsp],r12
     93a:	mov    QWORD PTR [rsp+0x8],rax
     93f:	mov    esi,0x2
     944:	mov    r8,QWORD PTR [rip+0x0]        # 94b <botlish_fn_5+0x17d>
			947: R_X86_64_GOTPCREL	rt_list_new-0x4
     94b:	mov    rdi,r14
     94e:	call   r8
     951:	test   rax,rax
     954:	jne    988 <botlish_fn_5+0x1ba>
     95a:	mov    rdi,r14
     95d:	mov    rdi,r14
     960:	mov    QWORD PTR [rdi],rbx
     963:	xor    rax,rax
     966:	mov    rbx,QWORD PTR [rsp+0x20]
     96b:	mov    r12,QWORD PTR [rsp+0x28]
     970:	mov    r13,QWORD PTR [rsp+0x30]
     975:	mov    r14,QWORD PTR [rsp+0x38]
     97a:	mov    r15,QWORD PTR [rsp+0x40]
     97f:	add    rsp,0x50
     983:	mov    rsp,rbp
     986:	pop    rbp
     987:	ret
     988:	mov    rdi,r14
     98b:	mov    QWORD PTR [rdi],rbx
     98e:	mov    rbx,QWORD PTR [rsp+0x20]
     993:	mov    r12,QWORD PTR [rsp+0x28]
     998:	mov    r13,QWORD PTR [rsp+0x30]
     99d:	mov    r14,QWORD PTR [rsp+0x38]
     9a2:	mov    r15,QWORD PTR [rsp+0x40]
     9a7:	add    rsp,0x50
     9ab:	mov    rsp,rbp
     9ae:	pop    rbp
     9af:	ret
     9b0:	mov    r14,rdi
     9b3:	mov    r11,QWORD PTR [rip+0x0]        # 9ba <botlish_fn_5+0x1ec>
			9b6: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     9ba:	call   r11
     9bd:	xor    rax,rax
     9c0:	mov    rbx,QWORD PTR [rsp+0x20]
     9c5:	mov    r12,QWORD PTR [rsp+0x28]
     9ca:	mov    r13,QWORD PTR [rsp+0x30]
     9cf:	mov    r14,QWORD PTR [rsp+0x38]
     9d4:	mov    r15,QWORD PTR [rsp+0x40]
     9d9:	add    rsp,0x50
     9dd:	mov    rsp,rbp
     9e0:	pop    rbp
     9e1:	ret

00000000000009e2 <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     9e2:	push   rbp
     9e3:	mov    rbp,rsp
     9e6:	mov    rsi,QWORD PTR [rdx]
     9e9:	mov    rdx,QWORD PTR [rdx+0x8]
     9ed:	call   9f2 <botlish_entry_5+0x10>
			9ee: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
     9f2:	mov    rsp,rbp
     9f5:	pop    rbp
     9f6:	ret

00000000000009f7 <botlish_fn_6: geo_finish<list[mutarray, int]>>:
     9f7:	push   rbp
     9f8:	mov    rbp,rsp
     9fb:	sub    rsp,0x20
     9ff:	mov    QWORD PTR [rsp],rbx
     a03:	mov    QWORD PTR [rsp+0x8],r12
     a08:	mov    QWORD PTR [rsp+0x10],r13
     a0d:	mov    QWORD PTR [rsp+0x18],r14
     a12:	mov    r13,rsi
     a15:	mov    rbx,QWORD PTR [rdi]
     a18:	mov    rax,QWORD PTR [rdi+0x8]
     a1c:	lea    rcx,[rbx+0x10]
     a20:	cmp    rcx,rax
     a23:	ja     afb <botlish_fn_6+0x104>
     a29:	lea    rax,[rbx+0x10]
     a2d:	mov    QWORD PTR [rdi],rax
     a30:	mov    r12,rdi
     a33:	mov    QWORD PTR [rbx],0x0
     a3a:	mov    QWORD PTR [rbx+0x8],0x0
     a42:	mov    edx,0x1
     a47:	mov    rax,QWORD PTR [rip+0x0]        # a4e <botlish_fn_6+0x57>
			a4a: R_X86_64_GOTPCREL	rt_list_get-0x4
     a4e:	mov    rsi,r13
     a51:	mov    rdi,r12
     a54:	call   rax
     a56:	test   rax,rax
     a59:	jne    a67 <botlish_fn_6+0x70>
     a5f:	mov    rdi,r12
     a62:	jmp    ab4 <botlish_fn_6+0xbd>
     a67:	mov    QWORD PTR [rbx],rax
     a6a:	mov    r14,rax
     a6d:	mov    edx,0x3
     a72:	mov    rax,QWORD PTR [rip+0x0]        # a79 <botlish_fn_6+0x82>
			a75: R_X86_64_GOTPCREL	rt_list_get-0x4
     a79:	mov    rsi,r13
     a7c:	mov    rdi,r12
     a7f:	call   rax
     a81:	test   rax,rax
     a84:	jne    a92 <botlish_fn_6+0x9b>
     a8a:	mov    rdi,r12
     a8d:	jmp    ab4 <botlish_fn_6+0xbd>
     a92:	mov    QWORD PTR [rbx+0x8],rax
     a96:	mov    rdx,rax
     a99:	mov    rax,QWORD PTR [rip+0x0]        # aa0 <botlish_fn_6+0xa9>
			a9c: R_X86_64_GOTPCREL	rt_mutarray_freeze-0x4
     aa0:	mov    rsi,r14
     aa3:	mov    rdi,r12
     aa6:	call   rax
     aa8:	test   rax,rax
     aab:	jne    ad9 <botlish_fn_6+0xe2>
     ab1:	mov    rdi,r12
     ab4:	mov    rdi,r12
     ab7:	mov    QWORD PTR [rdi],rbx
     aba:	xor    rax,rax
     abd:	mov    rbx,QWORD PTR [rsp]
     ac1:	mov    r12,QWORD PTR [rsp+0x8]
     ac6:	mov    r13,QWORD PTR [rsp+0x10]
     acb:	mov    r14,QWORD PTR [rsp+0x18]
     ad0:	add    rsp,0x20
     ad4:	mov    rsp,rbp
     ad7:	pop    rbp
     ad8:	ret
     ad9:	mov    rdi,r12
     adc:	mov    QWORD PTR [rdi],rbx
     adf:	mov    rbx,QWORD PTR [rsp]
     ae3:	mov    r12,QWORD PTR [rsp+0x8]
     ae8:	mov    r13,QWORD PTR [rsp+0x10]
     aed:	mov    r14,QWORD PTR [rsp+0x18]
     af2:	add    rsp,0x20
     af6:	mov    rsp,rbp
     af9:	pop    rbp
     afa:	ret
     afb:	mov    r12,rdi
     afe:	mov    rax,QWORD PTR [rip+0x0]        # b05 <botlish_fn_6+0x10e>
			b01: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     b05:	call   rax
     b07:	xor    rax,rax
     b0a:	mov    rbx,QWORD PTR [rsp]
     b0e:	mov    r12,QWORD PTR [rsp+0x8]
     b13:	mov    r13,QWORD PTR [rsp+0x10]
     b18:	mov    r14,QWORD PTR [rsp+0x18]
     b1d:	add    rsp,0x20
     b21:	mov    rsp,rbp
     b24:	pop    rbp
     b25:	ret

0000000000000b26 <botlish_entry_6: geo_finish<list[mutarray, int]>>:
     b26:	push   rbp
     b27:	mov    rbp,rsp
     b2a:	mov    rsi,QWORD PTR [rdx]
     b2d:	call   b32 <botlish_entry_6+0xc>
			b2e: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
     b32:	mov    rsp,rbp
     b35:	pop    rbp
     b36:	ret
	...

0000000000000b38 <botlish_fn_7: peek<str, int>>:
     b38:	push   rbp
     b39:	mov    rbp,rsp
     b3c:	sub    rsp,0x20
     b40:	mov    QWORD PTR [rsp],rbx
     b44:	mov    QWORD PTR [rsp+0x8],r12
     b49:	mov    QWORD PTR [rsp+0x10],r13
     b4e:	mov    QWORD PTR [rsp+0x18],r14
     b53:	mov    r12,QWORD PTR [rdi]
     b56:	mov    rax,QWORD PTR [rdi+0x8]
     b5a:	lea    rcx,[r12+0x18]
     b5f:	cmp    rcx,rax
     b62:	ja     ccf <botlish_fn_7+0x197>
     b68:	lea    rax,[r12+0x18]
     b6d:	mov    QWORD PTR [rdi],rax
     b70:	mov    r13,rdi
     b73:	mov    QWORD PTR [r12],0x0
     b7b:	mov    QWORD PTR [r12+0x8],0x0
     b84:	mov    QWORD PTR [r12+0x10],0x0
     b8d:	mov    QWORD PTR [r12],rsi
     b91:	mov    r14,rsi
     b94:	mov    QWORD PTR [r12+0x8],rdx
     b99:	mov    rbx,rdx
     b9c:	mov    rax,QWORD PTR [rip+0x0]        # ba3 <botlish_fn_7+0x6b>
			b9f: R_X86_64_GOTPCREL	rt_str_len-0x4
     ba3:	mov    rsi,r14
     ba6:	mov    rdi,r13
     ba9:	call   rax
     bab:	mov    rcx,rbx
     bae:	and    rcx,rax
     bb1:	mov    rdx,rax
     bb4:	test   rcx,0x1
     bbb:	jne    be5 <botlish_fn_7+0xad>
     bc1:	mov    rax,QWORD PTR [rip+0x0]        # bc8 <botlish_fn_7+0x90>
			bc4: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     bc8:	mov    rsi,rbx
     bcb:	mov    rdi,r13
     bce:	call   rax
     bd0:	mov    ecx,0x2
     bd5:	test   rax,rax
     bd8:	cmovge rcx,QWORD PTR [rip+0x120]        # d00 <botlish_fn_7+0x1c8>
     be0:	jmp    bf5 <botlish_fn_7+0xbd>
     be5:	mov    ecx,0x2
     bea:	cmp    rbx,rdx
     bed:	cmovge rcx,QWORD PTR [rip+0x10b]        # d00 <botlish_fn_7+0x1c8>
     bf5:	cmp    rcx,0x6
     bf9:	je     ca5 <botlish_fn_7+0x16d>
     bff:	mov    QWORD PTR [r12+0x10],0x3
     c08:	test   rbx,0x1
     c0f:	je     c27 <botlish_fn_7+0xef>
     c15:	mov    rcx,rbx
     c18:	add    rcx,0x2
     c1c:	seto   al
     c1f:	test   al,al
     c21:	je     c3e <botlish_fn_7+0x106>
     c27:	mov    edx,0x3
     c2c:	mov    rax,QWORD PTR [rip+0x0]        # c33 <botlish_fn_7+0xfb>
			c2f: R_X86_64_GOTPCREL	rt_int_add-0x4
     c33:	mov    rsi,rbx
     c36:	mov    rdi,r13
     c39:	call   rax
     c3b:	mov    rcx,rax
     c3e:	mov    QWORD PTR [r12+0x10],rcx
     c43:	mov    rax,QWORD PTR [rip+0x0]        # c4a <botlish_fn_7+0x112>
			c46: R_X86_64_GOTPCREL	rt_substr-0x4
     c4a:	mov    rdx,rbx
     c4d:	mov    rsi,r14
     c50:	mov    rdi,r13
     c53:	call   rax
     c55:	test   rax,rax
     c58:	jne    c83 <botlish_fn_7+0x14b>
     c5e:	mov    rdi,r13
     c61:	mov    QWORD PTR [rdi],r12
     c64:	xor    rax,rax
     c67:	mov    rbx,QWORD PTR [rsp]
     c6b:	mov    r12,QWORD PTR [rsp+0x8]
     c70:	mov    r13,QWORD PTR [rsp+0x10]
     c75:	mov    r14,QWORD PTR [rsp+0x18]
     c7a:	add    rsp,0x20
     c7e:	mov    rsp,rbp
     c81:	pop    rbp
     c82:	ret
     c83:	mov    rdi,r13
     c86:	mov    QWORD PTR [rdi],r12
     c89:	mov    rbx,QWORD PTR [rsp]
     c8d:	mov    r12,QWORD PTR [rsp+0x8]
     c92:	mov    r13,QWORD PTR [rsp+0x10]
     c97:	mov    r14,QWORD PTR [rsp+0x18]
     c9c:	add    rsp,0x20
     ca0:	mov    rsp,rbp
     ca3:	pop    rbp
     ca4:	ret
     ca5:	mov    rdi,r13
     ca8:	mov    rsi,QWORD PTR [rdi+0x10]
     cac:	mov    rax,QWORD PTR [rsi+0x8]
     cb0:	mov    QWORD PTR [rdi],r12
     cb3:	mov    rbx,QWORD PTR [rsp]
     cb7:	mov    r12,QWORD PTR [rsp+0x8]
     cbc:	mov    r13,QWORD PTR [rsp+0x10]
     cc1:	mov    r14,QWORD PTR [rsp+0x18]
     cc6:	add    rsp,0x20
     cca:	mov    rsp,rbp
     ccd:	pop    rbp
     cce:	ret
     ccf:	mov    r13,rdi
     cd2:	mov    rsi,QWORD PTR [rip+0x0]        # cd9 <botlish_fn_7+0x1a1>
			cd5: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     cd9:	call   rsi
     cdb:	xor    rax,rax
     cde:	mov    rbx,QWORD PTR [rsp]
     ce2:	mov    r12,QWORD PTR [rsp+0x8]
     ce7:	mov    r13,QWORD PTR [rsp+0x10]
     cec:	mov    r14,QWORD PTR [rsp+0x18]
     cf1:	add    rsp,0x20
     cf5:	mov    rsp,rbp
     cf8:	pop    rbp
     cf9:	ret
     cfa:	add    BYTE PTR [rax],al
     cfc:	add    BYTE PTR [rax],al
     cfe:	add    BYTE PTR [rax],al
     d00:	(bad)
     d01:	add    BYTE PTR [rax],al
     d03:	add    BYTE PTR [rax],al
     d05:	add    BYTE PTR [rax],al
	...

0000000000000d08 <botlish_entry_7: peek<str, int>>:
     d08:	push   rbp
     d09:	mov    rbp,rsp
     d0c:	mov    rsi,QWORD PTR [rdx]
     d0f:	mov    rdx,QWORD PTR [rdx+0x8]
     d13:	call   d18 <botlish_entry_7+0x10>
			d14: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     d18:	mov    rsp,rbp
     d1b:	pop    rbp
     d1c:	ret
     d1d:	add    BYTE PTR [rax],al
	...

0000000000000d20 <botlish_fn_8: peek<str, int>>:
     d20:	push   rbp
     d21:	mov    rbp,rsp
     d24:	sub    rsp,0x40
     d28:	mov    QWORD PTR [rsp+0x10],rbx
     d2d:	mov    QWORD PTR [rsp+0x18],r12
     d32:	mov    QWORD PTR [rsp+0x20],r13
     d37:	mov    QWORD PTR [rsp+0x28],r14
     d3c:	mov    QWORD PTR [rsp+0x30],r15
     d41:	mov    r13,rcx
     d44:	mov    r12,QWORD PTR [rdi]
     d47:	mov    rax,QWORD PTR [rdi+0x8]
     d4b:	lea    rcx,[r12+0x18]
     d50:	cmp    rcx,rax
     d53:	ja     eff <botlish_fn_8+0x1df>
     d59:	lea    rax,[r12+0x18]
     d5e:	mov    QWORD PTR [rdi],rax
     d61:	mov    r15,rdi
     d64:	mov    QWORD PTR [r12],0x0
     d6c:	mov    QWORD PTR [r12+0x8],0x0
     d75:	mov    QWORD PTR [r12+0x10],0x0
     d7e:	mov    QWORD PTR [r12],rsi
     d82:	mov    r14,rsi
     d85:	mov    QWORD PTR [r12+0x8],rdx
     d8a:	mov    rbx,rdx
     d8d:	mov    rax,QWORD PTR [rip+0x0]        # d94 <botlish_fn_8+0x74>
			d90: R_X86_64_GOTPCREL	rt_str_len-0x4
     d94:	mov    rsi,r14
     d97:	mov    rdi,r15
     d9a:	call   rax
     d9c:	mov    rcx,rbx
     d9f:	and    rcx,rax
     da2:	mov    rdx,rax
     da5:	test   rcx,0x1
     dac:	jne    dd6 <botlish_fn_8+0xb6>
     db2:	mov    rax,QWORD PTR [rip+0x0]        # db9 <botlish_fn_8+0x99>
			db5: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     db9:	mov    rsi,rbx
     dbc:	mov    rdi,r15
     dbf:	call   rax
     dc1:	mov    ecx,0x2
     dc6:	test   rax,rax
     dc9:	cmovge rcx,QWORD PTR [rip+0x167]        # f38 <botlish_fn_8+0x218>
     dd1:	jmp    de6 <botlish_fn_8+0xc6>
     dd6:	mov    ecx,0x2
     ddb:	cmp    rbx,rdx
     dde:	cmovge rcx,QWORD PTR [rip+0x152]        # f38 <botlish_fn_8+0x218>
     de6:	cmp    rcx,0x6
     dea:	je     ebd <botlish_fn_8+0x19d>
     df0:	mov    QWORD PTR [r12+0x10],0x3
     df9:	test   rbx,0x1
     e00:	je     e21 <botlish_fn_8+0x101>
     e06:	mov    rax,rbx
     e09:	add    rax,0x2
     e0d:	seto   cl
     e10:	test   cl,cl
     e12:	jne    e21 <botlish_fn_8+0x101>
     e18:	mov    QWORD PTR [rsp],rax
     e1c:	jmp    e39 <botlish_fn_8+0x119>
     e21:	mov    edx,0x3
     e26:	mov    rax,QWORD PTR [rip+0x0]        # e2d <botlish_fn_8+0x10d>
			e29: R_X86_64_GOTPCREL	rt_int_add-0x4
     e2d:	mov    rsi,rbx
     e30:	mov    rdi,r15
     e33:	call   rax
     e35:	mov    QWORD PTR [rsp],rax
     e39:	mov    r8,QWORD PTR [rip+0x0]        # e40 <botlish_fn_8+0x120>
			e3c: R_X86_64_GOTPCREL	rt_str_region_check-0x4
     e40:	mov    rcx,QWORD PTR [rsp]
     e44:	mov    rdx,rbx
     e47:	mov    rsi,r14
     e4a:	mov    rdi,r15
     e4d:	call   r8
     e50:	test   rax,rax
     e53:	jne    e84 <botlish_fn_8+0x164>
     e59:	mov    rdi,r15
     e5c:	mov    QWORD PTR [rdi],r12
     e5f:	xor    rax,rax
     e62:	mov    rbx,QWORD PTR [rsp+0x10]
     e67:	mov    r12,QWORD PTR [rsp+0x18]
     e6c:	mov    r13,QWORD PTR [rsp+0x20]
     e71:	mov    r14,QWORD PTR [rsp+0x28]
     e76:	mov    r15,QWORD PTR [rsp+0x30]
     e7b:	add    rsp,0x40
     e7f:	mov    rsp,rbp
     e82:	pop    rbp
     e83:	ret
     e84:	mov    rdi,r15
     e87:	mov    QWORD PTR [rdi],r12
     e8a:	mov    rcx,r13
     e8d:	mov    QWORD PTR [rcx],rbx
     e90:	mov    rax,QWORD PTR [rsp]
     e94:	mov    QWORD PTR [rcx+0x8],rax
     e98:	mov    rax,r14
     e9b:	mov    rbx,QWORD PTR [rsp+0x10]
     ea0:	mov    r12,QWORD PTR [rsp+0x18]
     ea5:	mov    r13,QWORD PTR [rsp+0x20]
     eaa:	mov    r14,QWORD PTR [rsp+0x28]
     eaf:	mov    r15,QWORD PTR [rsp+0x30]
     eb4:	add    rsp,0x40
     eb8:	mov    rsp,rbp
     ebb:	pop    rbp
     ebc:	ret
     ebd:	mov    rcx,r13
     ec0:	mov    rdi,r15
     ec3:	mov    rsi,QWORD PTR [rdi+0x10]
     ec7:	mov    rax,QWORD PTR [rsi+0x8]
     ecb:	mov    QWORD PTR [rdi],r12
     ece:	mov    QWORD PTR [rcx],0x1
     ed5:	mov    QWORD PTR [rcx+0x8],0x1
     edd:	mov    rbx,QWORD PTR [rsp+0x10]
     ee2:	mov    r12,QWORD PTR [rsp+0x18]
     ee7:	mov    r13,QWORD PTR [rsp+0x20]
     eec:	mov    r14,QWORD PTR [rsp+0x28]
     ef1:	mov    r15,QWORD PTR [rsp+0x30]
     ef6:	add    rsp,0x40
     efa:	mov    rsp,rbp
     efd:	pop    rbp
     efe:	ret
     eff:	mov    r15,rdi
     f02:	mov    r10,QWORD PTR [rip+0x0]        # f09 <botlish_fn_8+0x1e9>
			f05: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     f09:	call   r10
     f0c:	xor    rax,rax
     f0f:	mov    rbx,QWORD PTR [rsp+0x10]
     f14:	mov    r12,QWORD PTR [rsp+0x18]
     f19:	mov    r13,QWORD PTR [rsp+0x20]
     f1e:	mov    r14,QWORD PTR [rsp+0x28]
     f23:	mov    r15,QWORD PTR [rsp+0x30]
     f28:	add    rsp,0x40
     f2c:	mov    rsp,rbp
     f2f:	pop    rbp
     f30:	ret
     f31:	add    BYTE PTR [rax],al
     f33:	add    BYTE PTR [rax],al
     f35:	add    BYTE PTR [rax],al
     f37:	add    BYTE PTR [rsi],al
     f39:	add    BYTE PTR [rax],al
     f3b:	add    BYTE PTR [rax],al
     f3d:	add    BYTE PTR [rax],al
	...

0000000000000f40 <botlish_entry_8: peek<str, int>>:
     f40:	push   rbp
     f41:	mov    rbp,rsp
     f44:	ud2

0000000000000f46 <botlish_fn_9: scan_unquoted<str, int, int>>:
     f46:	push   rbp
     f47:	mov    rbp,rsp
     f4a:	sub    rsp,0x60
     f4e:	mov    QWORD PTR [rsp+0x30],rbx
     f53:	mov    QWORD PTR [rsp+0x38],r12
     f58:	mov    QWORD PTR [rsp+0x40],r13
     f5d:	mov    QWORD PTR [rsp+0x48],r14
     f62:	mov    QWORD PTR [rsp+0x50],r15
     f67:	mov    r14,QWORD PTR [rdi]
     f6a:	mov    rax,QWORD PTR [rdi+0x8]
     f6e:	lea    r8,[r14+0x20]
     f72:	cmp    r8,rax
     f75:	ja     11b4 <botlish_fn_9+0x26e>
     f7b:	lea    rax,[r14+0x20]
     f7f:	mov    QWORD PTR [rdi],rax
     f82:	mov    r15,rdi
     f85:	mov    QWORD PTR [r14],0x0
     f8c:	mov    QWORD PTR [r14+0x8],0x0
     f94:	mov    QWORD PTR [r14+0x10],0x0
     f9c:	mov    QWORD PTR [r14+0x18],0x0
     fa4:	mov    QWORD PTR [r14],rsi
     fa7:	mov    QWORD PTR [rsp+0x10],rsi
     fac:	mov    QWORD PTR [r14+0x8],rdx
     fb0:	mov    QWORD PTR [rsp+0x18],rdx
     fb5:	mov    QWORD PTR [r14+0x10],rcx
     fb9:	lea    rbx,[rsp]
     fbd:	mov    QWORD PTR [rsp+0x20],rcx
     fc2:	mov    rcx,rbx
     fc5:	mov    rdx,QWORD PTR [rsp+0x20]
     fca:	mov    rsi,QWORD PTR [rsp+0x10]
     fcf:	mov    rdi,r15
     fd2:	call   fd7 <botlish_fn_9+0x91>
			fd3: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     fd7:	mov    rcx,rax
     fda:	mov    QWORD PTR [rsp+0x28],rax
     fdf:	test   rax,rcx
     fe2:	jne    ff0 <botlish_fn_9+0xaa>
     fe8:	mov    rdi,r15
     feb:	jmp    1159 <botlish_fn_9+0x213>
     ff0:	mov    r12,QWORD PTR [rsp]
     ff4:	mov    r13,QWORD PTR [rsp+0x8]
     ff9:	mov    rdi,r15
     ffc:	mov    rcx,QWORD PTR [rdi+0x10]
    1000:	mov    r8,QWORD PTR [rcx+0x8]
    1004:	mov    r9,QWORD PTR [rip+0x0]        # 100b <botlish_fn_9+0xc5>
			1007: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    100b:	mov    rcx,r13
    100e:	mov    rdx,r12
    1011:	mov    rsi,QWORD PTR [rsp+0x28]
    1016:	call   r9
    1019:	cmp    rax,0x6
    101d:	je     1061 <botlish_fn_9+0x11b>
    1023:	mov    rdi,r15
    1026:	mov    rdx,QWORD PTR [rdi+0x10]
    102a:	mov    r8,QWORD PTR [rdx+0x10]
    102e:	mov    r9,QWORD PTR [rip+0x0]        # 1035 <botlish_fn_9+0xef>
			1031: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1035:	mov    rcx,r13
    1038:	mov    rdx,r12
    103b:	mov    rsi,QWORD PTR [rsp+0x28]
    1040:	call   r9
    1043:	cmp    rax,0x6
    1047:	je     1057 <botlish_fn_9+0x111>
    104d:	mov    eax,0x2
    1052:	jmp    1066 <botlish_fn_9+0x120>
    1057:	mov    eax,0x6
    105c:	jmp    1066 <botlish_fn_9+0x120>
    1061:	mov    eax,0x6
    1066:	cmp    rax,0x6
    106a:	je     10ae <botlish_fn_9+0x168>
    1070:	mov    rdi,r15
    1073:	mov    r10,QWORD PTR [rdi+0x10]
    1077:	mov    r8,QWORD PTR [r10+0x18]
    107b:	mov    r10,QWORD PTR [rip+0x0]        # 1082 <botlish_fn_9+0x13c>
			107e: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1082:	mov    rcx,r13
    1085:	mov    rdx,r12
    1088:	mov    rsi,QWORD PTR [rsp+0x28]
    108d:	call   r10
    1090:	cmp    rax,0x6
    1094:	je     10a4 <botlish_fn_9+0x15e>
    109a:	mov    eax,0x2
    109f:	jmp    10b3 <botlish_fn_9+0x16d>
    10a4:	mov    eax,0x6
    10a9:	jmp    10b3 <botlish_fn_9+0x16d>
    10ae:	mov    eax,0x6
    10b3:	cmp    rax,0x6
    10b7:	je     1132 <botlish_fn_9+0x1ec>
    10bd:	mov    QWORD PTR [r14+0x18],0x3
    10c5:	mov    rsi,QWORD PTR [rsp+0x20]
    10ca:	test   rsi,0x1
    10d1:	je     10f8 <botlish_fn_9+0x1b2>
    10d7:	mov    rsi,QWORD PTR [rsp+0x20]
    10dc:	mov    rax,rsi
    10df:	add    rax,0x2
    10e3:	seto   cl
    10e6:	test   cl,cl
    10e8:	jne    10f8 <botlish_fn_9+0x1b2>
    10ee:	mov    rsi,QWORD PTR [rsp+0x10]
    10f3:	jmp    1113 <botlish_fn_9+0x1cd>
    10f8:	mov    edx,0x3
    10fd:	mov    rax,QWORD PTR [rip+0x0]        # 1104 <botlish_fn_9+0x1be>
			1100: R_X86_64_GOTPCREL	rt_int_add-0x4
    1104:	mov    rsi,QWORD PTR [rsp+0x20]
    1109:	mov    rdi,r15
    110c:	call   rax
    110e:	mov    rsi,QWORD PTR [rsp+0x10]
    1113:	mov    QWORD PTR [r14],rsi
    1116:	mov    rdx,QWORD PTR [rsp+0x18]
    111b:	mov    QWORD PTR [r14+0x8],rdx
    111f:	mov    QWORD PTR [r14+0x10],rax
    1123:	mov    QWORD PTR [rsp+0x10],rsi
    1128:	mov    QWORD PTR [rsp+0x20],rax
    112d:	jmp    fc2 <botlish_fn_9+0x7c>
    1132:	mov    rdx,QWORD PTR [rsp+0x18]
    1137:	mov    rsi,QWORD PTR [rsp+0x10]
    113c:	mov    rax,QWORD PTR [rip+0x0]        # 1143 <botlish_fn_9+0x1fd>
			113f: R_X86_64_GOTPCREL	rt_substr-0x4
    1143:	mov    rcx,QWORD PTR [rsp+0x20]
    1148:	mov    rdi,r15
    114b:	call   rax
    114d:	test   rax,rax
    1150:	jne    1187 <botlish_fn_9+0x241>
    1156:	mov    rdi,r15
    1159:	mov    rdi,r15
    115c:	mov    QWORD PTR [rdi],r14
    115f:	xor    rdx,rdx
    1162:	mov    rax,rdx
    1165:	mov    rbx,QWORD PTR [rsp+0x30]
    116a:	mov    r12,QWORD PTR [rsp+0x38]
    116f:	mov    r13,QWORD PTR [rsp+0x40]
    1174:	mov    r14,QWORD PTR [rsp+0x48]
    1179:	mov    r15,QWORD PTR [rsp+0x50]
    117e:	add    rsp,0x60
    1182:	mov    rsp,rbp
    1185:	pop    rbp
    1186:	ret
    1187:	mov    rdi,r15
    118a:	mov    QWORD PTR [rdi],r14
    118d:	mov    rdx,QWORD PTR [rsp+0x20]
    1192:	mov    rbx,QWORD PTR [rsp+0x30]
    1197:	mov    r12,QWORD PTR [rsp+0x38]
    119c:	mov    r13,QWORD PTR [rsp+0x40]
    11a1:	mov    r14,QWORD PTR [rsp+0x48]
    11a6:	mov    r15,QWORD PTR [rsp+0x50]
    11ab:	add    rsp,0x60
    11af:	mov    rsp,rbp
    11b2:	pop    rbp
    11b3:	ret
    11b4:	mov    r15,rdi
    11b7:	mov    rax,QWORD PTR [rip+0x0]        # 11be <botlish_fn_9+0x278>
			11ba: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    11be:	call   rax
    11c0:	xor    rdx,rdx
    11c3:	mov    rax,rdx
    11c6:	mov    rbx,QWORD PTR [rsp+0x30]
    11cb:	mov    r12,QWORD PTR [rsp+0x38]
    11d0:	mov    r13,QWORD PTR [rsp+0x40]
    11d5:	mov    r14,QWORD PTR [rsp+0x48]
    11da:	mov    r15,QWORD PTR [rsp+0x50]
    11df:	add    rsp,0x60
    11e3:	mov    rsp,rbp
    11e6:	pop    rbp
    11e7:	ret

00000000000011e8 <botlish_entry_9: scan_unquoted<str, int, int>>:
    11e8:	push   rbp
    11e9:	mov    rbp,rsp
    11ec:	ud2

00000000000011ee <botlish_fn_10: scan_quoted<str, int, str>>:
    11ee:	push   rbp
    11ef:	mov    rbp,rsp
    11f2:	sub    rsp,0x50
    11f6:	mov    QWORD PTR [rsp+0x20],rbx
    11fb:	mov    QWORD PTR [rsp+0x28],r12
    1200:	mov    QWORD PTR [rsp+0x30],r13
    1205:	mov    QWORD PTR [rsp+0x38],r14
    120a:	mov    QWORD PTR [rsp+0x40],r15
    120f:	mov    r13,QWORD PTR [rdi]
    1212:	mov    rax,QWORD PTR [rdi+0x8]
    1216:	lea    r8,[r13+0x28]
    121a:	cmp    r8,rax
    121d:	ja     152a <botlish_fn_10+0x33c>
    1223:	lea    rax,[r13+0x28]
    1227:	mov    QWORD PTR [rdi],rax
    122a:	mov    r14,rdi
    122d:	mov    QWORD PTR [r13+0x0],0x0
    1235:	mov    QWORD PTR [r13+0x8],0x0
    123d:	mov    QWORD PTR [r13+0x10],0x0
    1245:	mov    QWORD PTR [r13+0x18],0x0
    124d:	mov    QWORD PTR [r13+0x20],0x0
    1255:	mov    QWORD PTR [r13+0x0],rsi
    1259:	mov    QWORD PTR [r13+0x8],rdx
    125d:	mov    QWORD PTR [r13+0x10],rcx
    1261:	lea    r12,[rsp]
    1265:	mov    rbx,rsi
    1268:	mov    r15,rdx
    126b:	mov    QWORD PTR [rsp+0x10],rcx
    1270:	mov    rdx,r15
    1273:	mov    rsi,rbx
    1276:	mov    rdi,r14
    1279:	call   127e <botlish_fn_10+0x90>
			127a: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
    127e:	test   rax,rax
    1281:	jne    128f <botlish_fn_10+0xa1>
    1287:	mov    rdi,r14
    128a:	jmp    14e3 <botlish_fn_10+0x2f5>
    128f:	mov    QWORD PTR [r13+0x18],rax
    1293:	mov    rdi,r14
    1296:	mov    QWORD PTR [rsp+0x18],rax
    129b:	mov    rcx,QWORD PTR [rdi+0x10]
    129f:	mov    rsi,QWORD PTR [rcx+0x20]
    12a3:	mov    edx,0x1
    12a8:	mov    ecx,0x3
    12ad:	mov    r9,QWORD PTR [rip+0x0]        # 12b4 <botlish_fn_10+0xc6>
			12b0: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    12b4:	mov    r8,QWORD PTR [rsp+0x18]
    12b9:	call   r9
    12bc:	cmp    rax,0x6
    12c0:	je     1353 <botlish_fn_10+0x165>
    12c6:	mov    QWORD PTR [r13+0x20],0x3
    12ce:	mov    rsi,r15
    12d1:	test   rsi,0x1
    12d8:	je     12f8 <botlish_fn_10+0x10a>
    12de:	mov    rax,rsi
    12e1:	add    rax,0x2
    12e5:	seto   cl
    12e8:	test   cl,cl
    12ea:	jne    12f8 <botlish_fn_10+0x10a>
    12f0:	mov    rsi,rax
    12f3:	jmp    130c <botlish_fn_10+0x11e>
    12f8:	mov    edx,0x3
    12fd:	mov    rax,QWORD PTR [rip+0x0]        # 1304 <botlish_fn_10+0x116>
			1300: R_X86_64_GOTPCREL	rt_int_add-0x4
    1304:	mov    rdi,r14
    1307:	call   rax
    1309:	mov    rsi,rax
    130c:	mov    QWORD PTR [r13+0x8],rsi
    1310:	mov    r15,rsi
    1313:	mov    rax,QWORD PTR [rip+0x0]        # 131a <botlish_fn_10+0x12c>
			1316: R_X86_64_GOTPCREL	rt_str_cat-0x4
    131a:	mov    rdx,QWORD PTR [rsp+0x18]
    131f:	mov    rsi,QWORD PTR [rsp+0x10]
    1324:	mov    rdi,r14
    1327:	call   rax
    1329:	test   rax,rax
    132c:	jne    133a <botlish_fn_10+0x14c>
    1332:	mov    rdi,r14
    1335:	jmp    14e3 <botlish_fn_10+0x2f5>
    133a:	mov    QWORD PTR [r13+0x0],rbx
    133e:	mov    rsi,r15
    1341:	mov    QWORD PTR [r13+0x8],rsi
    1345:	mov    QWORD PTR [r13+0x10],rax
    1349:	mov    QWORD PTR [rsp+0x10],rax
    134e:	jmp    1270 <botlish_fn_10+0x82>
    1353:	mov    QWORD PTR [r13+0x18],0x3
    135b:	mov    rsi,r15
    135e:	test   rsi,0x1
    1365:	je     1380 <botlish_fn_10+0x192>
    136b:	mov    rsi,r15
    136e:	mov    rdx,rsi
    1371:	add    rdx,0x2
    1375:	seto   al
    1378:	test   al,al
    137a:	je     1397 <botlish_fn_10+0x1a9>
    1380:	mov    edx,0x3
    1385:	mov    rax,QWORD PTR [rip+0x0]        # 138c <botlish_fn_10+0x19e>
			1388: R_X86_64_GOTPCREL	rt_int_add-0x4
    138c:	mov    rsi,r15
    138f:	mov    rdi,r14
    1392:	call   rax
    1394:	mov    rdx,rax
    1397:	mov    QWORD PTR [r13+0x18],rdx
    139b:	mov    rcx,r12
    139e:	mov    rsi,rbx
    13a1:	mov    rdi,r14
    13a4:	call   13a9 <botlish_fn_10+0x1bb>
			13a5: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    13a9:	test   rax,rax
    13ac:	mov    rsi,rax
    13af:	jne    13bd <botlish_fn_10+0x1cf>
    13b5:	mov    rdi,r14
    13b8:	jmp    14e3 <botlish_fn_10+0x2f5>
    13bd:	mov    rdx,QWORD PTR [rsp]
    13c1:	mov    rcx,QWORD PTR [rsp+0x8]
    13c6:	mov    rdi,r14
    13c9:	mov    rax,QWORD PTR [rdi+0x10]
    13cd:	mov    r8,QWORD PTR [rax+0x20]
    13d1:	mov    rax,QWORD PTR [rip+0x0]        # 13d8 <botlish_fn_10+0x1ea>
			13d4: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    13d8:	call   rax
    13da:	cmp    rax,0x6
    13de:	je     1460 <botlish_fn_10+0x272>
    13e4:	mov    QWORD PTR [r13+0x0],0x3
    13ec:	mov    rsi,r15
    13ef:	test   rsi,0x1
    13f6:	je     1419 <botlish_fn_10+0x22b>
    13fc:	mov    rsi,r15
    13ff:	mov    rdx,rsi
    1402:	add    rdx,0x2
    1406:	seto   al
    1409:	test   al,al
    140b:	jne    1419 <botlish_fn_10+0x22b>
    1411:	mov    rdi,r14
    1414:	jmp    1433 <botlish_fn_10+0x245>
    1419:	mov    edx,0x3
    141e:	mov    rax,QWORD PTR [rip+0x0]        # 1425 <botlish_fn_10+0x237>
			1421: R_X86_64_GOTPCREL	rt_int_add-0x4
    1425:	mov    rsi,r15
    1428:	mov    rdi,r14
    142b:	call   rax
    142d:	mov    rdx,rax
    1430:	mov    rdi,r14
    1433:	mov    rdi,r14
    1436:	mov    QWORD PTR [rdi],r13
    1439:	mov    rax,QWORD PTR [rsp+0x10]
    143e:	mov    rbx,QWORD PTR [rsp+0x20]
    1443:	mov    r12,QWORD PTR [rsp+0x28]
    1448:	mov    r13,QWORD PTR [rsp+0x30]
    144d:	mov    r14,QWORD PTR [rsp+0x38]
    1452:	mov    r15,QWORD PTR [rsp+0x40]
    1457:	add    rsp,0x50
    145b:	mov    rsp,rbp
    145e:	pop    rbp
    145f:	ret
    1460:	mov    QWORD PTR [r13+0x18],0x5
    1468:	mov    rsi,r15
    146b:	test   rsi,0x1
    1472:	je     149a <botlish_fn_10+0x2ac>
    1478:	mov    rsi,r15
    147b:	mov    rcx,rsi
    147e:	add    rcx,0x4
    1482:	seto   sil
    1486:	test   sil,sil
    1489:	jne    149a <botlish_fn_10+0x2ac>
    148f:	mov    rsi,rcx
    1492:	mov    r15,rcx
    1495:	jmp    14b5 <botlish_fn_10+0x2c7>
    149a:	mov    edx,0x5
    149f:	mov    r8,QWORD PTR [rip+0x0]        # 14a6 <botlish_fn_10+0x2b8>
			14a2: R_X86_64_GOTPCREL	rt_int_add-0x4
    14a6:	mov    rsi,r15
    14a9:	mov    rdi,r14
    14ac:	call   r8
    14af:	mov    rsi,rax
    14b2:	mov    r15,rax
    14b5:	mov    QWORD PTR [r13+0x8],rsi
    14b9:	mov    rdi,r14
    14bc:	mov    r8,QWORD PTR [rdi+0x10]
    14c0:	mov    rdx,QWORD PTR [r8+0x20]
    14c4:	mov    QWORD PTR [r13+0x18],rdx
    14c8:	mov    r9,QWORD PTR [rip+0x0]        # 14cf <botlish_fn_10+0x2e1>
			14cb: R_X86_64_GOTPCREL	rt_str_cat-0x4
    14cf:	mov    rsi,QWORD PTR [rsp+0x10]
    14d4:	call   r9
    14d7:	test   rax,rax
    14da:	jne    1511 <botlish_fn_10+0x323>
    14e0:	mov    rdi,r14
    14e3:	mov    rdi,r14
    14e6:	mov    QWORD PTR [rdi],r13
    14e9:	xor    rdx,rdx
    14ec:	mov    rax,rdx
    14ef:	mov    rbx,QWORD PTR [rsp+0x20]
    14f4:	mov    r12,QWORD PTR [rsp+0x28]
    14f9:	mov    r13,QWORD PTR [rsp+0x30]
    14fe:	mov    r14,QWORD PTR [rsp+0x38]
    1503:	mov    r15,QWORD PTR [rsp+0x40]
    1508:	add    rsp,0x50
    150c:	mov    rsp,rbp
    150f:	pop    rbp
    1510:	ret
    1511:	mov    QWORD PTR [r13+0x0],rbx
    1515:	mov    rsi,r15
    1518:	mov    QWORD PTR [r13+0x8],rsi
    151c:	mov    QWORD PTR [r13+0x10],rax
    1520:	mov    QWORD PTR [rsp+0x10],rax
    1525:	jmp    1270 <botlish_fn_10+0x82>
    152a:	mov    r14,rdi
    152d:	mov    rax,QWORD PTR [rip+0x0]        # 1534 <botlish_fn_10+0x346>
			1530: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1534:	call   rax
    1536:	xor    rdx,rdx
    1539:	mov    rax,rdx
    153c:	mov    rbx,QWORD PTR [rsp+0x20]
    1541:	mov    r12,QWORD PTR [rsp+0x28]
    1546:	mov    r13,QWORD PTR [rsp+0x30]
    154b:	mov    r14,QWORD PTR [rsp+0x38]
    1550:	mov    r15,QWORD PTR [rsp+0x40]
    1555:	add    rsp,0x50
    1559:	mov    rsp,rbp
    155c:	pop    rbp
    155d:	ret

000000000000155e <botlish_entry_10: scan_quoted<str, int, str>>:
    155e:	push   rbp
    155f:	mov    rbp,rsp
    1562:	ud2

0000000000001564 <botlish_fn_11: scan_field<str, int>>:
    1564:	push   rbp
    1565:	mov    rbp,rsp
    1568:	sub    rsp,0x30
    156c:	mov    QWORD PTR [rsp+0x10],rbx
    1571:	mov    QWORD PTR [rsp+0x18],r12
    1576:	mov    QWORD PTR [rsp+0x20],r13
    157b:	mov    QWORD PTR [rsp+0x28],r14
    1580:	mov    rbx,QWORD PTR [rdi]
    1583:	mov    rax,QWORD PTR [rdi+0x8]
    1587:	lea    rcx,[rbx+0x18]
    158b:	cmp    rcx,rax
    158e:	ja     1708 <botlish_fn_11+0x1a4>
    1594:	lea    rax,[rbx+0x18]
    1598:	mov    QWORD PTR [rdi],rax
    159b:	mov    r12,rdi
    159e:	mov    QWORD PTR [rbx],0x0
    15a5:	mov    QWORD PTR [rbx+0x8],0x0
    15ad:	mov    QWORD PTR [rbx+0x10],0x0
    15b5:	mov    QWORD PTR [rbx],rsi
    15b8:	mov    r13,rsi
    15bb:	mov    QWORD PTR [rbx+0x8],rdx
    15bf:	mov    r14,rdx
    15c2:	lea    rcx,[rsp]
    15c6:	mov    rdx,r14
    15c9:	mov    rsi,r13
    15cc:	mov    rdi,r12
    15cf:	call   15d4 <botlish_fn_11+0x70>
			15d0: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    15d4:	test   rax,rax
    15d7:	mov    rsi,rax
    15da:	jne    15e8 <botlish_fn_11+0x84>
    15e0:	mov    rdi,r12
    15e3:	jmp    16bc <botlish_fn_11+0x158>
    15e8:	mov    rdx,QWORD PTR [rsp]
    15ec:	mov    rcx,QWORD PTR [rsp+0x8]
    15f1:	mov    rdi,r12
    15f4:	mov    rax,QWORD PTR [rdi+0x10]
    15f8:	mov    r8,QWORD PTR [rax+0x20]
    15fc:	mov    rax,QWORD PTR [rip+0x0]        # 1603 <botlish_fn_11+0x9f>
			15ff: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1603:	call   rax
    1605:	cmp    rax,0x6
    1609:	je     1654 <botlish_fn_11+0xf0>
    160f:	mov    rcx,r14
    1612:	mov    rsi,r13
    1615:	mov    rdi,r12
    1618:	mov    rdx,rcx
    161b:	call   1620 <botlish_fn_11+0xbc>
			161c: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_unquoted<str, int, int>
    1620:	test   rax,rax
    1623:	jne    1631 <botlish_fn_11+0xcd>
    1629:	mov    rdi,r12
    162c:	jmp    16bc <botlish_fn_11+0x158>
    1631:	mov    rdi,r12
    1634:	mov    QWORD PTR [rdi],rbx
    1637:	mov    rbx,QWORD PTR [rsp+0x10]
    163c:	mov    r12,QWORD PTR [rsp+0x18]
    1641:	mov    r13,QWORD PTR [rsp+0x20]
    1646:	mov    r14,QWORD PTR [rsp+0x28]
    164b:	add    rsp,0x30
    164f:	mov    rsp,rbp
    1652:	pop    rbp
    1653:	ret
    1654:	mov    QWORD PTR [rbx+0x10],0x3
    165c:	mov    rdx,r14
    165f:	test   rdx,0x1
    1666:	je     167e <botlish_fn_11+0x11a>
    166c:	mov    rdx,r14
    166f:	add    rdx,0x2
    1673:	seto   al
    1676:	test   al,al
    1678:	je     1695 <botlish_fn_11+0x131>
    167e:	mov    edx,0x3
    1683:	mov    rax,QWORD PTR [rip+0x0]        # 168a <botlish_fn_11+0x126>
			1686: R_X86_64_GOTPCREL	rt_int_add-0x4
    168a:	mov    rsi,r14
    168d:	mov    rdi,r12
    1690:	call   rax
    1692:	mov    rdx,rax
    1695:	mov    QWORD PTR [rbx+0x8],rdx
    1699:	mov    rdi,r12
    169c:	mov    rax,QWORD PTR [rdi+0x10]
    16a0:	mov    rcx,QWORD PTR [rax+0x8]
    16a4:	mov    QWORD PTR [rbx+0x10],rcx
    16a8:	mov    rsi,r13
    16ab:	call   16b0 <botlish_fn_11+0x14c>
			16ac: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_quoted<str, int, str>
    16b0:	test   rax,rax
    16b3:	jne    16e5 <botlish_fn_11+0x181>
    16b9:	mov    rdi,r12
    16bc:	mov    rdi,r12
    16bf:	mov    QWORD PTR [rdi],rbx
    16c2:	xor    rdx,rdx
    16c5:	mov    rax,rdx
    16c8:	mov    rbx,QWORD PTR [rsp+0x10]
    16cd:	mov    r12,QWORD PTR [rsp+0x18]
    16d2:	mov    r13,QWORD PTR [rsp+0x20]
    16d7:	mov    r14,QWORD PTR [rsp+0x28]
    16dc:	add    rsp,0x30
    16e0:	mov    rsp,rbp
    16e3:	pop    rbp
    16e4:	ret
    16e5:	mov    rdi,r12
    16e8:	mov    QWORD PTR [rdi],rbx
    16eb:	mov    rbx,QWORD PTR [rsp+0x10]
    16f0:	mov    r12,QWORD PTR [rsp+0x18]
    16f5:	mov    r13,QWORD PTR [rsp+0x20]
    16fa:	mov    r14,QWORD PTR [rsp+0x28]
    16ff:	add    rsp,0x30
    1703:	mov    rsp,rbp
    1706:	pop    rbp
    1707:	ret
    1708:	mov    r12,rdi
    170b:	mov    rsi,QWORD PTR [rip+0x0]        # 1712 <botlish_fn_11+0x1ae>
			170e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1712:	call   rsi
    1714:	xor    rdx,rdx
    1717:	mov    rax,rdx
    171a:	mov    rbx,QWORD PTR [rsp+0x10]
    171f:	mov    r12,QWORD PTR [rsp+0x18]
    1724:	mov    r13,QWORD PTR [rsp+0x20]
    1729:	mov    r14,QWORD PTR [rsp+0x28]
    172e:	add    rsp,0x30
    1732:	mov    rsp,rbp
    1735:	pop    rbp
    1736:	ret

0000000000001737 <botlish_entry_11: scan_field<str, int>>:
    1737:	push   rbp
    1738:	mov    rbp,rsp
    173b:	ud2

000000000000173d <botlish_fn_12: scan_record<str, int, list[mutarray, int]>>:
    173d:	push   rbp
    173e:	mov    rbp,rsp
    1741:	sub    rsp,0x60
    1745:	mov    QWORD PTR [rsp+0x30],rbx
    174a:	mov    QWORD PTR [rsp+0x38],r12
    174f:	mov    QWORD PTR [rsp+0x40],r13
    1754:	mov    QWORD PTR [rsp+0x48],r14
    1759:	mov    QWORD PTR [rsp+0x50],r15
    175e:	mov    r13,QWORD PTR [rdi]
    1761:	mov    rax,QWORD PTR [rdi+0x8]
    1765:	lea    r8,[r13+0x20]
    1769:	cmp    r8,rax
    176c:	ja     1a2e <botlish_fn_12+0x2f1>
    1772:	lea    rax,[r13+0x20]
    1776:	mov    QWORD PTR [rdi],rax
    1779:	mov    QWORD PTR [rsp+0x10],rdi
    177e:	mov    QWORD PTR [r13+0x0],0x0
    1786:	mov    QWORD PTR [r13+0x8],0x0
    178e:	mov    QWORD PTR [r13+0x10],0x0
    1796:	mov    QWORD PTR [r13+0x18],0x0
    179e:	mov    QWORD PTR [r13+0x0],rsi
    17a2:	mov    QWORD PTR [r13+0x8],rdx
    17a6:	mov    QWORD PTR [r13+0x10],rcx
    17aa:	lea    rbx,[rsp]
    17ae:	mov    r12,rsi
    17b1:	mov    r14,rcx
    17b4:	mov    rsi,r12
    17b7:	mov    rdi,QWORD PTR [rsp+0x10]
    17bc:	call   17c1 <botlish_fn_12+0x84>
			17bd: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_field<str, int>
    17c1:	test   rax,rax
    17c4:	jne    17d4 <botlish_fn_12+0x97>
    17ca:	mov    rdi,QWORD PTR [rsp+0x10]
    17cf:	jmp    1911 <botlish_fn_12+0x1d4>
    17d4:	mov    QWORD PTR [r13+0x8],rax
    17d8:	mov    r11,rax
    17db:	mov    QWORD PTR [r13+0x18],rdx
    17df:	mov    QWORD PTR [rsp+0x28],rdx
    17e4:	mov    rsi,r14
    17e7:	mov    rdx,r11
    17ea:	mov    rdi,QWORD PTR [rsp+0x10]
    17ef:	call   17f4 <botlish_fn_12+0xb7>
			17f0: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    17f4:	test   rax,rax
    17f7:	jne    1807 <botlish_fn_12+0xca>
    17fd:	mov    rdi,QWORD PTR [rsp+0x10]
    1802:	jmp    1911 <botlish_fn_12+0x1d4>
    1807:	mov    QWORD PTR [r13+0x8],rax
    180b:	mov    QWORD PTR [rsp+0x20],rax
    1810:	mov    rcx,rbx
    1813:	mov    rdx,QWORD PTR [rsp+0x28]
    1818:	mov    rsi,r12
    181b:	mov    rdi,QWORD PTR [rsp+0x10]
    1820:	call   1825 <botlish_fn_12+0xe8>
			1821: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    1825:	test   rax,rax
    1828:	mov    QWORD PTR [rsp+0x18],rax
    182d:	jne    183d <botlish_fn_12+0x100>
    1833:	mov    rdi,QWORD PTR [rsp+0x10]
    1838:	jmp    1911 <botlish_fn_12+0x1d4>
    183d:	mov    r15,QWORD PTR [rsp]
    1841:	mov    r14,QWORD PTR [rsp+0x8]
    1846:	mov    rdi,QWORD PTR [rsp+0x10]
    184b:	mov    rsi,QWORD PTR [rdi+0x10]
    184f:	mov    r8,QWORD PTR [rsi+0x10]
    1853:	mov    r9,QWORD PTR [rip+0x0]        # 185a <botlish_fn_12+0x11d>
			1856: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    185a:	mov    rcx,r14
    185d:	mov    rdx,r15
    1860:	mov    rsi,QWORD PTR [rsp+0x18]
    1865:	call   r9
    1868:	cmp    rax,0x6
    186c:	je     19cd <botlish_fn_12+0x290>
    1872:	mov    rdi,QWORD PTR [rsp+0x10]
    1877:	mov    rdi,QWORD PTR [rdi+0x10]
    187b:	mov    r8,QWORD PTR [rdi+0x18]
    187f:	mov    r9,QWORD PTR [rip+0x0]        # 1886 <botlish_fn_12+0x149>
			1882: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1886:	mov    rcx,r14
    1889:	mov    rdx,r15
    188c:	mov    rsi,QWORD PTR [rsp+0x18]
    1891:	mov    rdi,QWORD PTR [rsp+0x10]
    1896:	call   r9
    1899:	cmp    rax,0x6
    189d:	je     18f4 <botlish_fn_12+0x1b7>
    18a3:	mov    rsi,QWORD PTR [rsp+0x20]
    18a8:	mov    rdi,QWORD PTR [rsp+0x10]
    18ad:	call   18b2 <botlish_fn_12+0x175>
			18ae: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    18b2:	test   rax,rax
    18b5:	jne    18c5 <botlish_fn_12+0x188>
    18bb:	mov    rdi,QWORD PTR [rsp+0x10]
    18c0:	jmp    1911 <botlish_fn_12+0x1d4>
    18c5:	mov    rdi,QWORD PTR [rsp+0x10]
    18ca:	mov    QWORD PTR [rdi],r13
    18cd:	mov    rdx,QWORD PTR [rsp+0x28]
    18d2:	mov    rbx,QWORD PTR [rsp+0x30]
    18d7:	mov    r12,QWORD PTR [rsp+0x38]
    18dc:	mov    r13,QWORD PTR [rsp+0x40]
    18e1:	mov    r14,QWORD PTR [rsp+0x48]
    18e6:	mov    r15,QWORD PTR [rsp+0x50]
    18eb:	add    rsp,0x60
    18ef:	mov    rsp,rbp
    18f2:	pop    rbp
    18f3:	ret
    18f4:	mov    rsi,QWORD PTR [rsp+0x20]
    18f9:	mov    rdi,QWORD PTR [rsp+0x10]
    18fe:	call   1903 <botlish_fn_12+0x1c6>
			18ff: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    1903:	test   rax,rax
    1906:	jne    1941 <botlish_fn_12+0x204>
    190c:	mov    rdi,QWORD PTR [rsp+0x10]
    1911:	mov    rdi,QWORD PTR [rsp+0x10]
    1916:	mov    QWORD PTR [rdi],r13
    1919:	xor    rdx,rdx
    191c:	mov    rax,rdx
    191f:	mov    rbx,QWORD PTR [rsp+0x30]
    1924:	mov    r12,QWORD PTR [rsp+0x38]
    1929:	mov    r13,QWORD PTR [rsp+0x40]
    192e:	mov    r14,QWORD PTR [rsp+0x48]
    1933:	mov    r15,QWORD PTR [rsp+0x50]
    1938:	add    rsp,0x60
    193c:	mov    rsp,rbp
    193f:	pop    rbp
    1940:	ret
    1941:	mov    QWORD PTR [r13+0x0],rax
    1945:	mov    r15,rax
    1948:	mov    QWORD PTR [r13+0x8],0x3
    1950:	mov    rdx,QWORD PTR [rsp+0x28]
    1955:	test   rdx,0x1
    195c:	je     1980 <botlish_fn_12+0x243>
    1962:	mov    rdx,QWORD PTR [rsp+0x28]
    1967:	add    rdx,0x2
    196b:	seto   al
    196e:	test   al,al
    1970:	jne    1980 <botlish_fn_12+0x243>
    1976:	mov    rdi,QWORD PTR [rsp+0x10]
    197b:	jmp    19a0 <botlish_fn_12+0x263>
    1980:	mov    edx,0x3
    1985:	mov    rax,QWORD PTR [rip+0x0]        # 198c <botlish_fn_12+0x24f>
			1988: R_X86_64_GOTPCREL	rt_int_add-0x4
    198c:	mov    rsi,QWORD PTR [rsp+0x28]
    1991:	mov    rdi,QWORD PTR [rsp+0x10]
    1996:	call   rax
    1998:	mov    rdx,rax
    199b:	mov    rdi,QWORD PTR [rsp+0x10]
    19a0:	mov    rdi,QWORD PTR [rsp+0x10]
    19a5:	mov    QWORD PTR [rdi],r13
    19a8:	mov    rax,r15
    19ab:	mov    rbx,QWORD PTR [rsp+0x30]
    19b0:	mov    r12,QWORD PTR [rsp+0x38]
    19b5:	mov    r13,QWORD PTR [rsp+0x40]
    19ba:	mov    r14,QWORD PTR [rsp+0x48]
    19bf:	mov    r15,QWORD PTR [rsp+0x50]
    19c4:	add    rsp,0x60
    19c8:	mov    rsp,rbp
    19cb:	pop    rbp
    19cc:	ret
    19cd:	mov    rsi,QWORD PTR [rsp+0x28]
    19d2:	mov    edx,0x3
    19d7:	mov    r9,rdx
    19da:	mov    QWORD PTR [r13+0x10],0x3
    19e2:	test   rsi,0x1
    19e9:	je     1a01 <botlish_fn_12+0x2c4>
    19ef:	mov    rdx,rsi
    19f2:	add    rdx,0x2
    19f6:	seto   al
    19f9:	test   al,al
    19fb:	je     1a15 <botlish_fn_12+0x2d8>
    1a01:	mov    rax,QWORD PTR [rip+0x0]        # 1a08 <botlish_fn_12+0x2cb>
			1a04: R_X86_64_GOTPCREL	rt_int_add-0x4
    1a08:	mov    rdx,r9
    1a0b:	mov    rdi,QWORD PTR [rsp+0x10]
    1a10:	call   rax
    1a12:	mov    rdx,rax
    1a15:	mov    QWORD PTR [r13+0x0],r12
    1a19:	mov    QWORD PTR [r13+0x8],rdx
    1a1d:	mov    rsi,QWORD PTR [rsp+0x20]
    1a22:	mov    QWORD PTR [r13+0x10],rsi
    1a26:	mov    r14,rsi
    1a29:	jmp    17b4 <botlish_fn_12+0x77>
    1a2e:	mov    QWORD PTR [rsp+0x10],rdi
    1a33:	mov    rax,QWORD PTR [rip+0x0]        # 1a3a <botlish_fn_12+0x2fd>
			1a36: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1a3a:	call   rax
    1a3c:	xor    rdx,rdx
    1a3f:	mov    rax,rdx
    1a42:	mov    rbx,QWORD PTR [rsp+0x30]
    1a47:	mov    r12,QWORD PTR [rsp+0x38]
    1a4c:	mov    r13,QWORD PTR [rsp+0x40]
    1a51:	mov    r14,QWORD PTR [rsp+0x48]
    1a56:	mov    r15,QWORD PTR [rsp+0x50]
    1a5b:	add    rsp,0x60
    1a5f:	mov    rsp,rbp
    1a62:	pop    rbp
    1a63:	ret

0000000000001a64 <botlish_entry_12: scan_record<str, int, list[mutarray, int]>>:
    1a64:	push   rbp
    1a65:	mov    rbp,rsp
    1a68:	ud2
    1a6a:	add    BYTE PTR [rax],al
    1a6c:	add    BYTE PTR [rax],al
	...

0000000000001a70 <botlish_fn_13: scan_records<str, int, list[mutarray, int]>>:
    1a70:	push   rbp
    1a71:	mov    rbp,rsp
    1a74:	sub    rsp,0x30
    1a78:	mov    QWORD PTR [rsp],rbx
    1a7c:	mov    QWORD PTR [rsp+0x8],r12
    1a81:	mov    QWORD PTR [rsp+0x10],r13
    1a86:	mov    QWORD PTR [rsp+0x18],r14
    1a8b:	mov    QWORD PTR [rsp+0x20],r15
    1a90:	mov    r12,QWORD PTR [rdi]
    1a93:	mov    rax,QWORD PTR [rdi+0x8]
    1a97:	lea    r8,[r12+0x20]
    1a9c:	cmp    r8,rax
    1a9f:	ja     1c3d <botlish_fn_13+0x1cd>
    1aa5:	lea    rax,[r12+0x20]
    1aaa:	mov    QWORD PTR [rdi],rax
    1aad:	mov    r14,rdi
    1ab0:	mov    QWORD PTR [r12],0x0
    1ab8:	mov    QWORD PTR [r12+0x8],0x0
    1ac1:	mov    QWORD PTR [r12+0x10],0x0
    1aca:	mov    QWORD PTR [r12+0x18],0x0
    1ad3:	mov    QWORD PTR [r12],rsi
    1ad7:	mov    QWORD PTR [r12+0x8],rdx
    1adc:	mov    r13,rdx
    1adf:	mov    QWORD PTR [r12+0x10],rcx
    1ae4:	mov    r15,rcx
    1ae7:	mov    rax,QWORD PTR [rip+0x0]        # 1aee <botlish_fn_13+0x7e>
			1aea: R_X86_64_GOTPCREL	rt_str_len-0x4
    1aee:	mov    rbx,rsi
    1af1:	mov    rdi,r14
    1af4:	call   rax
    1af6:	mov    rcx,r13
    1af9:	and    rcx,rax
    1afc:	mov    rdx,rax
    1aff:	test   rcx,0x1
    1b06:	jne    1b30 <botlish_fn_13+0xc0>
    1b0c:	mov    rax,QWORD PTR [rip+0x0]        # 1b13 <botlish_fn_13+0xa3>
			1b0f: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1b13:	mov    rsi,r13
    1b16:	mov    rdi,r14
    1b19:	call   rax
    1b1b:	mov    ecx,0x2
    1b20:	test   rax,rax
    1b23:	cmovge rcx,QWORD PTR [rip+0x145]        # 1c70 <botlish_fn_13+0x200>
    1b2b:	jmp    1b43 <botlish_fn_13+0xd3>
    1b30:	mov    ecx,0x2
    1b35:	mov    r11,r13
    1b38:	cmp    r11,rdx
    1b3b:	cmovge rcx,QWORD PTR [rip+0x12d]        # 1c70 <botlish_fn_13+0x200>
    1b43:	cmp    rcx,0x6
    1b47:	je     1bd5 <botlish_fn_13+0x165>
    1b4d:	mov    rdi,r14
    1b50:	call   1b55 <botlish_fn_13+0xe5>
			1b51: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1b55:	test   rax,rax
    1b58:	jne    1b66 <botlish_fn_13+0xf6>
    1b5e:	mov    rdi,r14
    1b61:	jmp    1bec <botlish_fn_13+0x17c>
    1b66:	mov    QWORD PTR [r12+0x18],rax
    1b6b:	mov    rcx,rax
    1b6e:	mov    rdx,r13
    1b71:	mov    rsi,rbx
    1b74:	mov    rdi,r14
    1b77:	call   1b7c <botlish_fn_13+0x10c>
			1b78: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_record<str, int, list[mutarray, int]>
    1b7c:	test   rax,rax
    1b7f:	jne    1b8d <botlish_fn_13+0x11d>
    1b85:	mov    rdi,r14
    1b88:	jmp    1bec <botlish_fn_13+0x17c>
    1b8d:	mov    QWORD PTR [r12+0x8],rax
    1b92:	mov    QWORD PTR [r12+0x18],rdx
    1b97:	mov    r13,rdx
    1b9a:	mov    rsi,r15
    1b9d:	mov    rdx,rax
    1ba0:	mov    rdi,r14
    1ba3:	call   1ba8 <botlish_fn_13+0x138>
			1ba4: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1ba8:	test   rax,rax
    1bab:	jne    1bb9 <botlish_fn_13+0x149>
    1bb1:	mov    rdi,r14
    1bb4:	jmp    1bec <botlish_fn_13+0x17c>
    1bb9:	mov    QWORD PTR [r12],rbx
    1bbd:	mov    rdx,r13
    1bc0:	mov    QWORD PTR [r12+0x8],rdx
    1bc5:	mov    QWORD PTR [r12+0x10],rax
    1bca:	mov    rsi,rbx
    1bcd:	mov    r15,rax
    1bd0:	jmp    1ae7 <botlish_fn_13+0x77>
    1bd5:	mov    rsi,r15
    1bd8:	mov    rdi,r14
    1bdb:	call   1be0 <botlish_fn_13+0x170>
			1bdc: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    1be0:	test   rax,rax
    1be3:	jne    1c16 <botlish_fn_13+0x1a6>
    1be9:	mov    rdi,r14
    1bec:	mov    rdi,r14
    1bef:	mov    QWORD PTR [rdi],r12
    1bf2:	xor    rax,rax
    1bf5:	mov    rbx,QWORD PTR [rsp]
    1bf9:	mov    r12,QWORD PTR [rsp+0x8]
    1bfe:	mov    r13,QWORD PTR [rsp+0x10]
    1c03:	mov    r14,QWORD PTR [rsp+0x18]
    1c08:	mov    r15,QWORD PTR [rsp+0x20]
    1c0d:	add    rsp,0x30
    1c11:	mov    rsp,rbp
    1c14:	pop    rbp
    1c15:	ret
    1c16:	mov    rdi,r14
    1c19:	mov    QWORD PTR [rdi],r12
    1c1c:	mov    rbx,QWORD PTR [rsp]
    1c20:	mov    r12,QWORD PTR [rsp+0x8]
    1c25:	mov    r13,QWORD PTR [rsp+0x10]
    1c2a:	mov    r14,QWORD PTR [rsp+0x18]
    1c2f:	mov    r15,QWORD PTR [rsp+0x20]
    1c34:	add    rsp,0x30
    1c38:	mov    rsp,rbp
    1c3b:	pop    rbp
    1c3c:	ret
    1c3d:	mov    r14,rdi
    1c40:	mov    r10,QWORD PTR [rip+0x0]        # 1c47 <botlish_fn_13+0x1d7>
			1c43: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1c47:	call   r10
    1c4a:	xor    rax,rax
    1c4d:	mov    rbx,QWORD PTR [rsp]
    1c51:	mov    r12,QWORD PTR [rsp+0x8]
    1c56:	mov    r13,QWORD PTR [rsp+0x10]
    1c5b:	mov    r14,QWORD PTR [rsp+0x18]
    1c60:	mov    r15,QWORD PTR [rsp+0x20]
    1c65:	add    rsp,0x30
    1c69:	mov    rsp,rbp
    1c6c:	pop    rbp
    1c6d:	ret
    1c6e:	add    BYTE PTR [rax],al
    1c70:	(bad)
    1c71:	add    BYTE PTR [rax],al
    1c73:	add    BYTE PTR [rax],al
    1c75:	add    BYTE PTR [rax],al
	...

0000000000001c78 <botlish_entry_13: scan_records<str, int, list[mutarray, int]>>:
    1c78:	push   rbp
    1c79:	mov    rbp,rsp
    1c7c:	mov    rsi,QWORD PTR [rdx]
    1c7f:	mov    r8,QWORD PTR [rdx+0x8]
    1c83:	mov    rcx,QWORD PTR [rdx+0x10]
    1c87:	mov    rdx,r8
    1c8a:	call   1c8f <botlish_entry_13+0x17>
			1c8b: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    1c8f:	mov    rsp,rbp
    1c92:	pop    rbp
    1c93:	ret

0000000000001c94 <botlish_fn_14: csv_parse<str>>:
    1c94:	push   rbp
    1c95:	mov    rbp,rsp
    1c98:	sub    rsp,0x20
    1c9c:	mov    QWORD PTR [rsp],rbx
    1ca0:	mov    QWORD PTR [rsp+0x8],r12
    1ca5:	mov    QWORD PTR [rsp+0x10],r15
    1caa:	mov    r15,QWORD PTR [rdi]
    1cad:	mov    rax,QWORD PTR [rdi+0x8]
    1cb1:	lea    rcx,[r15+0x18]
    1cb5:	cmp    rcx,rax
    1cb8:	ja     1d66 <botlish_fn_14+0xd2>
    1cbe:	lea    rax,[r15+0x18]
    1cc2:	mov    QWORD PTR [rdi],rax
    1cc5:	mov    rbx,rdi
    1cc8:	mov    QWORD PTR [r15],0x0
    1ccf:	mov    QWORD PTR [r15+0x8],0x0
    1cd7:	mov    QWORD PTR [r15+0x10],0x0
    1cdf:	mov    QWORD PTR [r15],rsi
    1ce2:	mov    r12,rsi
    1ce5:	mov    QWORD PTR [r15+0x8],0x1
    1ced:	mov    rdi,rbx
    1cf0:	call   1cf5 <botlish_fn_14+0x61>
			1cf1: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1cf5:	test   rax,rax
    1cf8:	jne    1d06 <botlish_fn_14+0x72>
    1cfe:	mov    rdi,rbx
    1d01:	jmp    1d29 <botlish_fn_14+0x95>
    1d06:	mov    QWORD PTR [r15+0x10],rax
    1d0a:	mov    rcx,rax
    1d0d:	mov    edx,0x1
    1d12:	mov    rsi,r12
    1d15:	mov    rdi,rbx
    1d18:	call   1d1d <botlish_fn_14+0x89>
			1d19: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    1d1d:	test   rax,rax
    1d20:	jne    1d49 <botlish_fn_14+0xb5>
    1d26:	mov    rdi,rbx
    1d29:	mov    rdi,rbx
    1d2c:	mov    QWORD PTR [rdi],r15
    1d2f:	xor    rax,rax
    1d32:	mov    rbx,QWORD PTR [rsp]
    1d36:	mov    r12,QWORD PTR [rsp+0x8]
    1d3b:	mov    r15,QWORD PTR [rsp+0x10]
    1d40:	add    rsp,0x20
    1d44:	mov    rsp,rbp
    1d47:	pop    rbp
    1d48:	ret
    1d49:	mov    rdi,rbx
    1d4c:	mov    QWORD PTR [rdi],r15
    1d4f:	mov    rbx,QWORD PTR [rsp]
    1d53:	mov    r12,QWORD PTR [rsp+0x8]
    1d58:	mov    r15,QWORD PTR [rsp+0x10]
    1d5d:	add    rsp,0x20
    1d61:	mov    rsp,rbp
    1d64:	pop    rbp
    1d65:	ret
    1d66:	mov    rbx,rdi
    1d69:	mov    rax,QWORD PTR [rip+0x0]        # 1d70 <botlish_fn_14+0xdc>
			1d6c: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1d70:	call   rax
    1d72:	xor    rax,rax
    1d75:	mov    rbx,QWORD PTR [rsp]
    1d79:	mov    r12,QWORD PTR [rsp+0x8]
    1d7e:	mov    r15,QWORD PTR [rsp+0x10]
    1d83:	add    rsp,0x20
    1d87:	mov    rsp,rbp
    1d8a:	pop    rbp
    1d8b:	ret

0000000000001d8c <botlish_entry_14: csv_parse<str>>:
    1d8c:	push   rbp
    1d8d:	mov    rbp,rsp
    1d90:	mov    rsi,QWORD PTR [rdx]
    1d93:	call   1d98 <botlish_entry_14+0xc>
			1d94: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
    1d98:	mov    rsp,rbp
    1d9b:	pop    rbp
    1d9c:	ret

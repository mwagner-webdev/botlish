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
      b1:	sub    rsp,0x10
      b5:	mov    QWORD PTR [rsp],rbx
      b9:	mov    QWORD PTR [rsp+0x8],r15
      be:	mov    r15,QWORD PTR [rdi]
      c1:	mov    rax,QWORD PTR [rdi+0x8]
      c5:	lea    rcx,[r15+0x8]
      c9:	cmp    rcx,rax
      cc:	ja     138 <botlish_fn_1+0x8b>
      d2:	lea    rax,[r15+0x8]
      d6:	mov    QWORD PTR [rdi],rax
      d9:	mov    rbx,rdi
      dc:	mov    esi,0x1
      e1:	mov    QWORD PTR [r15],0x1
      e8:	mov    rax,QWORD PTR [rip+0x0]        # ef <botlish_fn_1+0x42>
			eb: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
      ef:	mov    rdi,rbx
      f2:	call   rax
      f4:	test   rax,rax
      f7:	jne    11b <botlish_fn_1+0x6e>
      fd:	mov    rdi,rbx
     100:	mov    QWORD PTR [rdi],r15
     103:	xor    rdx,rdx
     106:	mov    rax,rdx
     109:	mov    rbx,QWORD PTR [rsp]
     10d:	mov    r15,QWORD PTR [rsp+0x8]
     112:	add    rsp,0x10
     116:	mov    rsp,rbp
     119:	pop    rbp
     11a:	ret
     11b:	mov    rdi,rbx
     11e:	mov    QWORD PTR [rdi],r15
     121:	mov    edx,0x1
     126:	mov    rbx,QWORD PTR [rsp]
     12a:	mov    r15,QWORD PTR [rsp+0x8]
     12f:	add    rsp,0x10
     133:	mov    rsp,rbp
     136:	pop    rbp
     137:	ret
     138:	mov    rax,QWORD PTR [rip+0x0]        # 13f <botlish_fn_1+0x92>
			13b: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     13f:	call   rax
     141:	xor    rdx,rdx
     144:	mov    rax,rdx
     147:	mov    rbx,QWORD PTR [rsp]
     14b:	mov    r15,QWORD PTR [rsp+0x8]
     150:	add    rsp,0x10
     154:	mov    rsp,rbp
     157:	pop    rbp
     158:	ret

0000000000000159 <botlish_entry_1: geo_new<generic>>:
     159:	push   rbp
     15a:	mov    rbp,rsp
     15d:	ud2
	...

0000000000000160 <botlish_fn_2: geo_new_capacity<int, int>>:
     160:	push   rbp
     161:	mov    rbp,rsp
     164:	sub    rsp,0x20
     168:	mov    QWORD PTR [rsp],rbx
     16c:	mov    QWORD PTR [rsp+0x8],r12
     171:	mov    QWORD PTR [rsp+0x10],r13
     176:	mov    QWORD PTR [rsp+0x18],r14
     17b:	mov    rbx,QWORD PTR [rdi]
     17e:	mov    rax,QWORD PTR [rdi+0x8]
     182:	lea    rcx,[rbx+0x18]
     186:	cmp    rcx,rax
     189:	ja     2e5 <botlish_fn_2+0x185>
     18f:	lea    rax,[rbx+0x18]
     193:	mov    QWORD PTR [rdi],rax
     196:	mov    r13,rdi
     199:	mov    QWORD PTR [rbx],0x0
     1a0:	mov    QWORD PTR [rbx+0x8],0x0
     1a8:	mov    QWORD PTR [rbx+0x10],0x0
     1b0:	mov    QWORD PTR [rbx],rsi
     1b3:	mov    QWORD PTR [rbx+0x8],rdx
     1b7:	mov    r12,rdx
     1ba:	mov    QWORD PTR [rbx+0x10],0x5
     1c2:	test   rsi,0x1
     1c9:	je     1eb <botlish_fn_2+0x8b>
     1cf:	mov    rax,rsi
     1d2:	sar    rax,1
     1d5:	imul   QWORD PTR [rip+0x13c]        # 318 <botlish_fn_2+0x1b8>
     1dc:	seto   cl
     1df:	or     rax,0x1
     1e3:	test   cl,cl
     1e5:	je     1fc <botlish_fn_2+0x9c>
     1eb:	mov    edx,0x5
     1f0:	mov    rax,QWORD PTR [rip+0x0]        # 1f7 <botlish_fn_2+0x97>
			1f3: R_X86_64_GOTPCREL	rt_int_mul-0x4
     1f7:	mov    rdi,r13
     1fa:	call   rax
     1fc:	mov    rcx,rax
     1ff:	and    rcx,r12
     202:	mov    r14,rax
     205:	test   rcx,0x1
     20c:	jne    23c <botlish_fn_2+0xdc>
     212:	mov    rax,QWORD PTR [rip+0x0]        # 219 <botlish_fn_2+0xb9>
			215: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     219:	mov    rdx,r12
     21c:	mov    rsi,r14
     21f:	mov    rdi,r13
     222:	call   rax
     224:	mov    ecx,0x2
     229:	test   rax,rax
     22c:	cmovle rcx,QWORD PTR [rip+0xec]        # 320 <botlish_fn_2+0x1c0>
     234:	mov    rax,r14
     237:	jmp    24f <botlish_fn_2+0xef>
     23c:	mov    ecx,0x2
     241:	mov    rax,r14
     244:	cmp    rax,r12
     247:	cmovle rcx,QWORD PTR [rip+0xd1]        # 320 <botlish_fn_2+0x1c0>
     24f:	cmp    rcx,0x6
     253:	je     27b <botlish_fn_2+0x11b>
     259:	mov    rdi,r13
     25c:	mov    QWORD PTR [rdi],rbx
     25f:	mov    rbx,QWORD PTR [rsp]
     263:	mov    r12,QWORD PTR [rsp+0x8]
     268:	mov    r13,QWORD PTR [rsp+0x10]
     26d:	mov    r14,QWORD PTR [rsp+0x18]
     272:	add    rsp,0x20
     276:	mov    rsp,rbp
     279:	pop    rbp
     27a:	ret
     27b:	mov    QWORD PTR [rbx],0x3
     282:	test   r12,0x1
     289:	je     2ab <botlish_fn_2+0x14b>
     28f:	mov    rax,r12
     292:	add    rax,0x2
     296:	seto   sil
     29a:	test   sil,sil
     29d:	jne    2ab <botlish_fn_2+0x14b>
     2a3:	mov    rdi,r13
     2a6:	jmp    2c3 <botlish_fn_2+0x163>
     2ab:	mov    edx,0x3
     2b0:	mov    r8,QWORD PTR [rip+0x0]        # 2b7 <botlish_fn_2+0x157>
			2b3: R_X86_64_GOTPCREL	rt_int_add-0x4
     2b7:	mov    rsi,r12
     2ba:	mov    rdi,r13
     2bd:	call   r8
     2c0:	mov    rdi,r13
     2c3:	mov    rdi,r13
     2c6:	mov    QWORD PTR [rdi],rbx
     2c9:	mov    rbx,QWORD PTR [rsp]
     2cd:	mov    r12,QWORD PTR [rsp+0x8]
     2d2:	mov    r13,QWORD PTR [rsp+0x10]
     2d7:	mov    r14,QWORD PTR [rsp+0x18]
     2dc:	add    rsp,0x20
     2e0:	mov    rsp,rbp
     2e3:	pop    rbp
     2e4:	ret
     2e5:	mov    r13,rdi
     2e8:	mov    r10,QWORD PTR [rip+0x0]        # 2ef <botlish_fn_2+0x18f>
			2eb: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     2ef:	call   r10
     2f2:	xor    rax,rax
     2f5:	mov    rbx,QWORD PTR [rsp]
     2f9:	mov    r12,QWORD PTR [rsp+0x8]
     2fe:	mov    r13,QWORD PTR [rsp+0x10]
     303:	mov    r14,QWORD PTR [rsp+0x18]
     308:	add    rsp,0x20
     30c:	mov    rsp,rbp
     30f:	pop    rbp
     310:	ret
     311:	add    BYTE PTR [rax],al
     313:	add    BYTE PTR [rax],al
     315:	add    BYTE PTR [rax],al
     317:	add    BYTE PTR [rax+rax*1],al
     31a:	add    BYTE PTR [rax],al
     31c:	add    BYTE PTR [rax],al
     31e:	add    BYTE PTR [rax],al
     320:	(bad)
     321:	add    BYTE PTR [rax],al
     323:	add    BYTE PTR [rax],al
     325:	add    BYTE PTR [rax],al
	...

0000000000000328 <botlish_entry_2: geo_new_capacity<int, int>>:
     328:	push   rbp
     329:	mov    rbp,rsp
     32c:	mov    rsi,QWORD PTR [rdx]
     32f:	mov    rdx,QWORD PTR [rdx+0x8]
     333:	call   338 <botlish_entry_2+0x10>
			334: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     338:	mov    rsp,rbp
     33b:	pop    rbp
     33c:	ret
     33d:	add    BYTE PTR [rax],al
	...

0000000000000340 <botlish_fn_3: geo_grow<mutarray, int>>:
     340:	push   rbp
     341:	mov    rbp,rsp
     344:	sub    rsp,0x30
     348:	mov    QWORD PTR [rsp],rbx
     34c:	mov    QWORD PTR [rsp+0x8],r12
     351:	mov    QWORD PTR [rsp+0x10],r13
     356:	mov    QWORD PTR [rsp+0x18],r14
     35b:	mov    QWORD PTR [rsp+0x20],r15
     360:	mov    rbx,QWORD PTR [rdi]
     363:	mov    rax,QWORD PTR [rdi+0x8]
     367:	lea    rcx,[rbx+0x18]
     36b:	cmp    rcx,rax
     36e:	ja     500 <botlish_fn_3+0x1c0>
     374:	lea    rax,[rbx+0x18]
     378:	mov    QWORD PTR [rdi],rax
     37b:	mov    r13,rdi
     37e:	mov    QWORD PTR [rbx],0x0
     385:	mov    QWORD PTR [rbx+0x8],0x0
     38d:	mov    QWORD PTR [rbx+0x10],0x0
     395:	mov    QWORD PTR [rbx],rsi
     398:	mov    r14,rsi
     39b:	mov    QWORD PTR [rbx+0x8],rdx
     39f:	mov    r12,rdx
     3a2:	mov    rax,QWORD PTR [rip+0x0]        # 3a9 <botlish_fn_3+0x69>
			3a5: R_X86_64_GOTPCREL	rt_mutarray_capacity-0x4
     3a9:	mov    rsi,r14
     3ac:	mov    rdi,r13
     3af:	call   rax
     3b1:	mov    r15,rax
     3b4:	mov    QWORD PTR [rbx+0x10],rax
     3b8:	mov    rcx,r12
     3bb:	and    rcx,rax
     3be:	test   rcx,0x1
     3c5:	jne    3f5 <botlish_fn_3+0xb5>
     3cb:	mov    rax,QWORD PTR [rip+0x0]        # 3d2 <botlish_fn_3+0x92>
			3ce: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     3d2:	mov    rdx,r15
     3d5:	mov    rsi,r12
     3d8:	mov    rdi,r13
     3db:	call   rax
     3dd:	mov    ecx,0x2
     3e2:	test   rax,rax
     3e5:	cmovl  rcx,QWORD PTR [rip+0x143]        # 530 <botlish_fn_3+0x1f0>
     3ed:	mov    rax,r15
     3f0:	jmp    408 <botlish_fn_3+0xc8>
     3f5:	mov    ecx,0x2
     3fa:	mov    rax,r15
     3fd:	cmp    r12,rax
     400:	cmovl  rcx,QWORD PTR [rip+0x128]        # 530 <botlish_fn_3+0x1f0>
     408:	cmp    rcx,0x6
     40c:	je     4d6 <botlish_fn_3+0x196>
     412:	mov    rsi,rax
     415:	mov    rdx,r12
     418:	mov    rdi,r13
     41b:	call   420 <botlish_fn_3+0xe0>
			41c: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     420:	test   rax,rax
     423:	jne    431 <botlish_fn_3+0xf1>
     429:	mov    rdi,r13
     42c:	jmp    482 <botlish_fn_3+0x142>
     431:	mov    QWORD PTR [rbx+0x10],rax
     435:	mov    rsi,rax
     438:	mov    rax,QWORD PTR [rip+0x0]        # 43f <botlish_fn_3+0xff>
			43b: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     43f:	mov    rdi,r13
     442:	call   rax
     444:	test   rax,rax
     447:	mov    r15,rax
     44a:	jne    458 <botlish_fn_3+0x118>
     450:	mov    rdi,r13
     453:	jmp    482 <botlish_fn_3+0x142>
     458:	mov    r8d,0x1
     45e:	mov    rax,QWORD PTR [rip+0x0]        # 465 <botlish_fn_3+0x125>
			461: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
     465:	mov    rcx,r14
     468:	mov    r9,r12
     46b:	mov    rsi,r15
     46e:	mov    rdi,r13
     471:	mov    rdx,r8
     474:	call   rax
     476:	test   rax,rax
     479:	jne    4ac <botlish_fn_3+0x16c>
     47f:	mov    rdi,r13
     482:	mov    rdi,r13
     485:	mov    QWORD PTR [rdi],rbx
     488:	xor    rax,rax
     48b:	mov    rbx,QWORD PTR [rsp]
     48f:	mov    r12,QWORD PTR [rsp+0x8]
     494:	mov    r13,QWORD PTR [rsp+0x10]
     499:	mov    r14,QWORD PTR [rsp+0x18]
     49e:	mov    r15,QWORD PTR [rsp+0x20]
     4a3:	add    rsp,0x30
     4a7:	mov    rsp,rbp
     4aa:	pop    rbp
     4ab:	ret
     4ac:	mov    rdi,r13
     4af:	mov    QWORD PTR [rdi],rbx
     4b2:	mov    rax,r15
     4b5:	mov    rbx,QWORD PTR [rsp]
     4b9:	mov    r12,QWORD PTR [rsp+0x8]
     4be:	mov    r13,QWORD PTR [rsp+0x10]
     4c3:	mov    r14,QWORD PTR [rsp+0x18]
     4c8:	mov    r15,QWORD PTR [rsp+0x20]
     4cd:	add    rsp,0x30
     4d1:	mov    rsp,rbp
     4d4:	pop    rbp
     4d5:	ret
     4d6:	mov    rdi,r13
     4d9:	mov    QWORD PTR [rdi],rbx
     4dc:	mov    rax,r14
     4df:	mov    rbx,QWORD PTR [rsp]
     4e3:	mov    r12,QWORD PTR [rsp+0x8]
     4e8:	mov    r13,QWORD PTR [rsp+0x10]
     4ed:	mov    r14,QWORD PTR [rsp+0x18]
     4f2:	mov    r15,QWORD PTR [rsp+0x20]
     4f7:	add    rsp,0x30
     4fb:	mov    rsp,rbp
     4fe:	pop    rbp
     4ff:	ret
     500:	mov    r13,rdi
     503:	mov    rcx,QWORD PTR [rip+0x0]        # 50a <botlish_fn_3+0x1ca>
			506: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     50a:	call   rcx
     50c:	xor    rax,rax
     50f:	mov    rbx,QWORD PTR [rsp]
     513:	mov    r12,QWORD PTR [rsp+0x8]
     518:	mov    r13,QWORD PTR [rsp+0x10]
     51d:	mov    r14,QWORD PTR [rsp+0x18]
     522:	mov    r15,QWORD PTR [rsp+0x20]
     527:	add    rsp,0x30
     52b:	mov    rsp,rbp
     52e:	pop    rbp
     52f:	ret
     530:	(bad)
     531:	add    BYTE PTR [rax],al
     533:	add    BYTE PTR [rax],al
     535:	add    BYTE PTR [rax],al
	...

0000000000000538 <botlish_entry_3: geo_grow<mutarray, int>>:
     538:	push   rbp
     539:	mov    rbp,rsp
     53c:	mov    rsi,QWORD PTR [rdx]
     53f:	mov    rdx,QWORD PTR [rdx+0x8]
     543:	call   548 <botlish_entry_3+0x10>
			544: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     548:	mov    rsp,rbp
     54b:	pop    rbp
     54c:	ret

000000000000054d <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     54d:	push   rbp
     54e:	mov    rbp,rsp
     551:	sub    rsp,0x30
     555:	mov    QWORD PTR [rsp],rbx
     559:	mov    QWORD PTR [rsp+0x8],r12
     55e:	mov    QWORD PTR [rsp+0x10],r13
     563:	mov    QWORD PTR [rsp+0x18],r14
     568:	mov    QWORD PTR [rsp+0x20],r15
     56d:	mov    r12,QWORD PTR [rdi]
     570:	mov    r8,QWORD PTR [rdi+0x8]
     574:	lea    rax,[r12+0x18]
     579:	cmp    rax,r8
     57c:	ja     6b1 <botlish_fn_4+0x164>
     582:	lea    rax,[r12+0x18]
     587:	mov    QWORD PTR [rdi],rax
     58a:	mov    r13,rdi
     58d:	mov    QWORD PTR [r12],0x0
     595:	mov    QWORD PTR [r12+0x8],0x0
     59e:	mov    QWORD PTR [r12+0x10],0x0
     5a7:	mov    QWORD PTR [r12],rsi
     5ab:	mov    QWORD PTR [r12+0x8],rdx
     5b0:	mov    rdi,rdx
     5b3:	mov    QWORD PTR [r12+0x10],rcx
     5b8:	mov    r15,rcx
     5bb:	mov    rbx,rdi
     5be:	mov    rdx,rbx
     5c1:	mov    rdi,r13
     5c4:	call   5c9 <botlish_fn_4+0x7c>
			5c5: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     5c9:	test   rax,rax
     5cc:	mov    r14,rax
     5cf:	jne    5dd <botlish_fn_4+0x90>
     5d5:	mov    rdi,r13
     5d8:	jmp    605 <botlish_fn_4+0xb8>
     5dd:	mov    rax,r14
     5e0:	mov    QWORD PTR [r12],rax
     5e4:	mov    rax,QWORD PTR [rip+0x0]        # 5eb <botlish_fn_4+0x9e>
			5e7: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     5eb:	mov    rcx,r15
     5ee:	mov    rdx,rbx
     5f1:	mov    rsi,r14
     5f4:	mov    rdi,r13
     5f7:	call   rax
     5f9:	test   rax,rax
     5fc:	jne    632 <botlish_fn_4+0xe5>
     602:	mov    rdi,r13
     605:	mov    rdi,r13
     608:	mov    QWORD PTR [rdi],r12
     60b:	xor    rdx,rdx
     60e:	mov    rax,rdx
     611:	mov    rbx,QWORD PTR [rsp]
     615:	mov    r12,QWORD PTR [rsp+0x8]
     61a:	mov    r13,QWORD PTR [rsp+0x10]
     61f:	mov    r14,QWORD PTR [rsp+0x18]
     624:	mov    r15,QWORD PTR [rsp+0x20]
     629:	add    rsp,0x30
     62d:	mov    rsp,rbp
     630:	pop    rbp
     631:	ret
     632:	mov    QWORD PTR [r12+0x10],0x3
     63b:	test   rbx,0x1
     642:	jne    650 <botlish_fn_4+0x103>
     648:	mov    rdi,rbx
     64b:	jmp    66d <botlish_fn_4+0x120>
     650:	mov    rdx,rbx
     653:	add    rdx,0x2
     657:	mov    rdi,rbx
     65a:	seto   al
     65d:	test   al,al
     65f:	jne    66d <botlish_fn_4+0x120>
     665:	mov    rdi,r13
     668:	jmp    687 <botlish_fn_4+0x13a>
     66d:	mov    edx,0x3
     672:	mov    rax,QWORD PTR [rip+0x0]        # 679 <botlish_fn_4+0x12c>
			675: R_X86_64_GOTPCREL	rt_int_add-0x4
     679:	mov    rsi,rdi
     67c:	mov    rdi,r13
     67f:	call   rax
     681:	mov    rdx,rax
     684:	mov    rdi,r13
     687:	mov    rdi,r13
     68a:	mov    QWORD PTR [rdi],r12
     68d:	mov    rax,r14
     690:	mov    rbx,QWORD PTR [rsp]
     694:	mov    r12,QWORD PTR [rsp+0x8]
     699:	mov    r13,QWORD PTR [rsp+0x10]
     69e:	mov    r14,QWORD PTR [rsp+0x18]
     6a3:	mov    r15,QWORD PTR [rsp+0x20]
     6a8:	add    rsp,0x30
     6ac:	mov    rsp,rbp
     6af:	pop    rbp
     6b0:	ret
     6b1:	mov    r13,rdi
     6b4:	mov    rax,QWORD PTR [rip+0x0]        # 6bb <botlish_fn_4+0x16e>
			6b7: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     6bb:	call   rax
     6bd:	xor    rdx,rdx
     6c0:	mov    rax,rdx
     6c3:	mov    rbx,QWORD PTR [rsp]
     6c7:	mov    r12,QWORD PTR [rsp+0x8]
     6cc:	mov    r13,QWORD PTR [rsp+0x10]
     6d1:	mov    r14,QWORD PTR [rsp+0x18]
     6d6:	mov    r15,QWORD PTR [rsp+0x20]
     6db:	add    rsp,0x30
     6df:	mov    rsp,rbp
     6e2:	pop    rbp
     6e3:	ret

00000000000006e4 <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     6e4:	push   rbp
     6e5:	mov    rbp,rsp
     6e8:	ud2

00000000000006ea <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     6ea:	push   rbp
     6eb:	mov    rbp,rsp
     6ee:	sub    rsp,0x30
     6f2:	mov    QWORD PTR [rsp],rbx
     6f6:	mov    QWORD PTR [rsp+0x8],r12
     6fb:	mov    QWORD PTR [rsp+0x10],r13
     700:	mov    QWORD PTR [rsp+0x18],r14
     705:	mov    QWORD PTR [rsp+0x20],r15
     70a:	mov    r12,QWORD PTR [rdi]
     70d:	mov    r8,QWORD PTR [rdi+0x8]
     711:	lea    rax,[r12+0x18]
     716:	cmp    rax,r8
     719:	ja     84e <botlish_fn_5+0x164>
     71f:	lea    rax,[r12+0x18]
     724:	mov    QWORD PTR [rdi],rax
     727:	mov    r13,rdi
     72a:	mov    QWORD PTR [r12],0x0
     732:	mov    QWORD PTR [r12+0x8],0x0
     73b:	mov    QWORD PTR [r12+0x10],0x0
     744:	mov    QWORD PTR [r12],rsi
     748:	mov    QWORD PTR [r12+0x8],rdx
     74d:	mov    rdi,rdx
     750:	mov    QWORD PTR [r12+0x10],rcx
     755:	mov    r15,rcx
     758:	mov    rbx,rdi
     75b:	mov    rdx,rbx
     75e:	mov    rdi,r13
     761:	call   766 <botlish_fn_5+0x7c>
			762: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     766:	test   rax,rax
     769:	mov    r14,rax
     76c:	jne    77a <botlish_fn_5+0x90>
     772:	mov    rdi,r13
     775:	jmp    7a2 <botlish_fn_5+0xb8>
     77a:	mov    rax,r14
     77d:	mov    QWORD PTR [r12],rax
     781:	mov    rax,QWORD PTR [rip+0x0]        # 788 <botlish_fn_5+0x9e>
			784: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     788:	mov    rcx,r15
     78b:	mov    rdx,rbx
     78e:	mov    rsi,r14
     791:	mov    rdi,r13
     794:	call   rax
     796:	test   rax,rax
     799:	jne    7cf <botlish_fn_5+0xe5>
     79f:	mov    rdi,r13
     7a2:	mov    rdi,r13
     7a5:	mov    QWORD PTR [rdi],r12
     7a8:	xor    rdx,rdx
     7ab:	mov    rax,rdx
     7ae:	mov    rbx,QWORD PTR [rsp]
     7b2:	mov    r12,QWORD PTR [rsp+0x8]
     7b7:	mov    r13,QWORD PTR [rsp+0x10]
     7bc:	mov    r14,QWORD PTR [rsp+0x18]
     7c1:	mov    r15,QWORD PTR [rsp+0x20]
     7c6:	add    rsp,0x30
     7ca:	mov    rsp,rbp
     7cd:	pop    rbp
     7ce:	ret
     7cf:	mov    QWORD PTR [r12+0x10],0x3
     7d8:	test   rbx,0x1
     7df:	jne    7ed <botlish_fn_5+0x103>
     7e5:	mov    rdi,rbx
     7e8:	jmp    80a <botlish_fn_5+0x120>
     7ed:	mov    rdx,rbx
     7f0:	add    rdx,0x2
     7f4:	mov    rdi,rbx
     7f7:	seto   al
     7fa:	test   al,al
     7fc:	jne    80a <botlish_fn_5+0x120>
     802:	mov    rdi,r13
     805:	jmp    824 <botlish_fn_5+0x13a>
     80a:	mov    edx,0x3
     80f:	mov    rax,QWORD PTR [rip+0x0]        # 816 <botlish_fn_5+0x12c>
			812: R_X86_64_GOTPCREL	rt_int_add-0x4
     816:	mov    rsi,rdi
     819:	mov    rdi,r13
     81c:	call   rax
     81e:	mov    rdx,rax
     821:	mov    rdi,r13
     824:	mov    rdi,r13
     827:	mov    QWORD PTR [rdi],r12
     82a:	mov    rax,r14
     82d:	mov    rbx,QWORD PTR [rsp]
     831:	mov    r12,QWORD PTR [rsp+0x8]
     836:	mov    r13,QWORD PTR [rsp+0x10]
     83b:	mov    r14,QWORD PTR [rsp+0x18]
     840:	mov    r15,QWORD PTR [rsp+0x20]
     845:	add    rsp,0x30
     849:	mov    rsp,rbp
     84c:	pop    rbp
     84d:	ret
     84e:	mov    r13,rdi
     851:	mov    rax,QWORD PTR [rip+0x0]        # 858 <botlish_fn_5+0x16e>
			854: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     858:	call   rax
     85a:	xor    rdx,rdx
     85d:	mov    rax,rdx
     860:	mov    rbx,QWORD PTR [rsp]
     864:	mov    r12,QWORD PTR [rsp+0x8]
     869:	mov    r13,QWORD PTR [rsp+0x10]
     86e:	mov    r14,QWORD PTR [rsp+0x18]
     873:	mov    r15,QWORD PTR [rsp+0x20]
     878:	add    rsp,0x30
     87c:	mov    rsp,rbp
     87f:	pop    rbp
     880:	ret

0000000000000881 <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     881:	push   rbp
     882:	mov    rbp,rsp
     885:	ud2

0000000000000887 <botlish_fn_6: geo_finish<list[mutarray, int]>>:
     887:	push   rbp
     888:	mov    rbp,rsp
     88b:	sub    rsp,0x10
     88f:	mov    QWORD PTR [rsp],rbx
     893:	mov    QWORD PTR [rsp+0x8],r15
     898:	mov    r15,QWORD PTR [rdi]
     89b:	mov    rax,QWORD PTR [rdi+0x8]
     89f:	lea    rcx,[r15+0x10]
     8a3:	cmp    rcx,rax
     8a6:	ja     914 <botlish_fn_6+0x8d>
     8ac:	lea    rax,[r15+0x10]
     8b0:	mov    QWORD PTR [rdi],rax
     8b3:	mov    rbx,rdi
     8b6:	mov    QWORD PTR [r15],0x0
     8bd:	mov    QWORD PTR [r15+0x8],0x0
     8c5:	mov    QWORD PTR [r15],rsi
     8c8:	mov    QWORD PTR [r15+0x8],rdx
     8cc:	mov    rax,QWORD PTR [rip+0x0]        # 8d3 <botlish_fn_6+0x4c>
			8cf: R_X86_64_GOTPCREL	rt_mutarray_freeze-0x4
     8d3:	mov    rdi,rbx
     8d6:	call   rax
     8d8:	test   rax,rax
     8db:	jne    8fc <botlish_fn_6+0x75>
     8e1:	mov    rdi,rbx
     8e4:	mov    QWORD PTR [rdi],r15
     8e7:	xor    rax,rax
     8ea:	mov    rbx,QWORD PTR [rsp]
     8ee:	mov    r15,QWORD PTR [rsp+0x8]
     8f3:	add    rsp,0x10
     8f7:	mov    rsp,rbp
     8fa:	pop    rbp
     8fb:	ret
     8fc:	mov    rdi,rbx
     8ff:	mov    QWORD PTR [rdi],r15
     902:	mov    rbx,QWORD PTR [rsp]
     906:	mov    r15,QWORD PTR [rsp+0x8]
     90b:	add    rsp,0x10
     90f:	mov    rsp,rbp
     912:	pop    rbp
     913:	ret
     914:	mov    rax,QWORD PTR [rip+0x0]        # 91b <botlish_fn_6+0x94>
			917: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     91b:	call   rax
     91d:	xor    rax,rax
     920:	mov    rbx,QWORD PTR [rsp]
     924:	mov    r15,QWORD PTR [rsp+0x8]
     929:	add    rsp,0x10
     92d:	mov    rsp,rbp
     930:	pop    rbp
     931:	ret

0000000000000932 <botlish_entry_6: geo_finish<list[mutarray, int]>>:
     932:	push   rbp
     933:	mov    rbp,rsp
     936:	mov    rsi,QWORD PTR [rdx]
     939:	mov    rdx,QWORD PTR [rdx+0x8]
     93d:	call   942 <botlish_entry_6+0x10>
			93e: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
     942:	mov    rsp,rbp
     945:	pop    rbp
     946:	ret
	...

0000000000000948 <botlish_fn_7: peek<str, int>>:
     948:	push   rbp
     949:	mov    rbp,rsp
     94c:	sub    rsp,0x20
     950:	mov    QWORD PTR [rsp],rbx
     954:	mov    QWORD PTR [rsp+0x8],r12
     959:	mov    QWORD PTR [rsp+0x10],r13
     95e:	mov    QWORD PTR [rsp+0x18],r14
     963:	mov    r12,QWORD PTR [rdi]
     966:	mov    rax,QWORD PTR [rdi+0x8]
     96a:	lea    rcx,[r12+0x18]
     96f:	cmp    rcx,rax
     972:	ja     adf <botlish_fn_7+0x197>
     978:	lea    rax,[r12+0x18]
     97d:	mov    QWORD PTR [rdi],rax
     980:	mov    r13,rdi
     983:	mov    QWORD PTR [r12],0x0
     98b:	mov    QWORD PTR [r12+0x8],0x0
     994:	mov    QWORD PTR [r12+0x10],0x0
     99d:	mov    QWORD PTR [r12],rsi
     9a1:	mov    r14,rsi
     9a4:	mov    QWORD PTR [r12+0x8],rdx
     9a9:	mov    rbx,rdx
     9ac:	mov    rax,QWORD PTR [rip+0x0]        # 9b3 <botlish_fn_7+0x6b>
			9af: R_X86_64_GOTPCREL	rt_str_len-0x4
     9b3:	mov    rsi,r14
     9b6:	mov    rdi,r13
     9b9:	call   rax
     9bb:	mov    rcx,rbx
     9be:	and    rcx,rax
     9c1:	mov    rdx,rax
     9c4:	test   rcx,0x1
     9cb:	jne    9f5 <botlish_fn_7+0xad>
     9d1:	mov    rax,QWORD PTR [rip+0x0]        # 9d8 <botlish_fn_7+0x90>
			9d4: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     9d8:	mov    rsi,rbx
     9db:	mov    rdi,r13
     9de:	call   rax
     9e0:	mov    ecx,0x2
     9e5:	test   rax,rax
     9e8:	cmovge rcx,QWORD PTR [rip+0x120]        # b10 <botlish_fn_7+0x1c8>
     9f0:	jmp    a05 <botlish_fn_7+0xbd>
     9f5:	mov    ecx,0x2
     9fa:	cmp    rbx,rdx
     9fd:	cmovge rcx,QWORD PTR [rip+0x10b]        # b10 <botlish_fn_7+0x1c8>
     a05:	cmp    rcx,0x6
     a09:	je     ab5 <botlish_fn_7+0x16d>
     a0f:	mov    QWORD PTR [r12+0x10],0x3
     a18:	test   rbx,0x1
     a1f:	je     a37 <botlish_fn_7+0xef>
     a25:	mov    rcx,rbx
     a28:	add    rcx,0x2
     a2c:	seto   al
     a2f:	test   al,al
     a31:	je     a4e <botlish_fn_7+0x106>
     a37:	mov    edx,0x3
     a3c:	mov    rax,QWORD PTR [rip+0x0]        # a43 <botlish_fn_7+0xfb>
			a3f: R_X86_64_GOTPCREL	rt_int_add-0x4
     a43:	mov    rsi,rbx
     a46:	mov    rdi,r13
     a49:	call   rax
     a4b:	mov    rcx,rax
     a4e:	mov    QWORD PTR [r12+0x10],rcx
     a53:	mov    rax,QWORD PTR [rip+0x0]        # a5a <botlish_fn_7+0x112>
			a56: R_X86_64_GOTPCREL	rt_substr-0x4
     a5a:	mov    rdx,rbx
     a5d:	mov    rsi,r14
     a60:	mov    rdi,r13
     a63:	call   rax
     a65:	test   rax,rax
     a68:	jne    a93 <botlish_fn_7+0x14b>
     a6e:	mov    rdi,r13
     a71:	mov    QWORD PTR [rdi],r12
     a74:	xor    rax,rax
     a77:	mov    rbx,QWORD PTR [rsp]
     a7b:	mov    r12,QWORD PTR [rsp+0x8]
     a80:	mov    r13,QWORD PTR [rsp+0x10]
     a85:	mov    r14,QWORD PTR [rsp+0x18]
     a8a:	add    rsp,0x20
     a8e:	mov    rsp,rbp
     a91:	pop    rbp
     a92:	ret
     a93:	mov    rdi,r13
     a96:	mov    QWORD PTR [rdi],r12
     a99:	mov    rbx,QWORD PTR [rsp]
     a9d:	mov    r12,QWORD PTR [rsp+0x8]
     aa2:	mov    r13,QWORD PTR [rsp+0x10]
     aa7:	mov    r14,QWORD PTR [rsp+0x18]
     aac:	add    rsp,0x20
     ab0:	mov    rsp,rbp
     ab3:	pop    rbp
     ab4:	ret
     ab5:	mov    rdi,r13
     ab8:	mov    rsi,QWORD PTR [rdi+0x10]
     abc:	mov    rax,QWORD PTR [rsi+0x8]
     ac0:	mov    QWORD PTR [rdi],r12
     ac3:	mov    rbx,QWORD PTR [rsp]
     ac7:	mov    r12,QWORD PTR [rsp+0x8]
     acc:	mov    r13,QWORD PTR [rsp+0x10]
     ad1:	mov    r14,QWORD PTR [rsp+0x18]
     ad6:	add    rsp,0x20
     ada:	mov    rsp,rbp
     add:	pop    rbp
     ade:	ret
     adf:	mov    r13,rdi
     ae2:	mov    rsi,QWORD PTR [rip+0x0]        # ae9 <botlish_fn_7+0x1a1>
			ae5: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     ae9:	call   rsi
     aeb:	xor    rax,rax
     aee:	mov    rbx,QWORD PTR [rsp]
     af2:	mov    r12,QWORD PTR [rsp+0x8]
     af7:	mov    r13,QWORD PTR [rsp+0x10]
     afc:	mov    r14,QWORD PTR [rsp+0x18]
     b01:	add    rsp,0x20
     b05:	mov    rsp,rbp
     b08:	pop    rbp
     b09:	ret
     b0a:	add    BYTE PTR [rax],al
     b0c:	add    BYTE PTR [rax],al
     b0e:	add    BYTE PTR [rax],al
     b10:	(bad)
     b11:	add    BYTE PTR [rax],al
     b13:	add    BYTE PTR [rax],al
     b15:	add    BYTE PTR [rax],al
	...

0000000000000b18 <botlish_entry_7: peek<str, int>>:
     b18:	push   rbp
     b19:	mov    rbp,rsp
     b1c:	mov    rsi,QWORD PTR [rdx]
     b1f:	mov    rdx,QWORD PTR [rdx+0x8]
     b23:	call   b28 <botlish_entry_7+0x10>
			b24: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     b28:	mov    rsp,rbp
     b2b:	pop    rbp
     b2c:	ret
     b2d:	add    BYTE PTR [rax],al
	...

0000000000000b30 <botlish_fn_8: peek<str, int>>:
     b30:	push   rbp
     b31:	mov    rbp,rsp
     b34:	sub    rsp,0x40
     b38:	mov    QWORD PTR [rsp+0x10],rbx
     b3d:	mov    QWORD PTR [rsp+0x18],r12
     b42:	mov    QWORD PTR [rsp+0x20],r13
     b47:	mov    QWORD PTR [rsp+0x28],r14
     b4c:	mov    QWORD PTR [rsp+0x30],r15
     b51:	mov    r13,rcx
     b54:	mov    r12,QWORD PTR [rdi]
     b57:	mov    rax,QWORD PTR [rdi+0x8]
     b5b:	lea    rcx,[r12+0x18]
     b60:	cmp    rcx,rax
     b63:	ja     d0f <botlish_fn_8+0x1df>
     b69:	lea    rax,[r12+0x18]
     b6e:	mov    QWORD PTR [rdi],rax
     b71:	mov    r15,rdi
     b74:	mov    QWORD PTR [r12],0x0
     b7c:	mov    QWORD PTR [r12+0x8],0x0
     b85:	mov    QWORD PTR [r12+0x10],0x0
     b8e:	mov    QWORD PTR [r12],rsi
     b92:	mov    r14,rsi
     b95:	mov    QWORD PTR [r12+0x8],rdx
     b9a:	mov    rbx,rdx
     b9d:	mov    rax,QWORD PTR [rip+0x0]        # ba4 <botlish_fn_8+0x74>
			ba0: R_X86_64_GOTPCREL	rt_str_len-0x4
     ba4:	mov    rsi,r14
     ba7:	mov    rdi,r15
     baa:	call   rax
     bac:	mov    rcx,rbx
     baf:	and    rcx,rax
     bb2:	mov    rdx,rax
     bb5:	test   rcx,0x1
     bbc:	jne    be6 <botlish_fn_8+0xb6>
     bc2:	mov    rax,QWORD PTR [rip+0x0]        # bc9 <botlish_fn_8+0x99>
			bc5: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     bc9:	mov    rsi,rbx
     bcc:	mov    rdi,r15
     bcf:	call   rax
     bd1:	mov    ecx,0x2
     bd6:	test   rax,rax
     bd9:	cmovge rcx,QWORD PTR [rip+0x167]        # d48 <botlish_fn_8+0x218>
     be1:	jmp    bf6 <botlish_fn_8+0xc6>
     be6:	mov    ecx,0x2
     beb:	cmp    rbx,rdx
     bee:	cmovge rcx,QWORD PTR [rip+0x152]        # d48 <botlish_fn_8+0x218>
     bf6:	cmp    rcx,0x6
     bfa:	je     ccd <botlish_fn_8+0x19d>
     c00:	mov    QWORD PTR [r12+0x10],0x3
     c09:	test   rbx,0x1
     c10:	je     c31 <botlish_fn_8+0x101>
     c16:	mov    rax,rbx
     c19:	add    rax,0x2
     c1d:	seto   cl
     c20:	test   cl,cl
     c22:	jne    c31 <botlish_fn_8+0x101>
     c28:	mov    QWORD PTR [rsp],rax
     c2c:	jmp    c49 <botlish_fn_8+0x119>
     c31:	mov    edx,0x3
     c36:	mov    rax,QWORD PTR [rip+0x0]        # c3d <botlish_fn_8+0x10d>
			c39: R_X86_64_GOTPCREL	rt_int_add-0x4
     c3d:	mov    rsi,rbx
     c40:	mov    rdi,r15
     c43:	call   rax
     c45:	mov    QWORD PTR [rsp],rax
     c49:	mov    r8,QWORD PTR [rip+0x0]        # c50 <botlish_fn_8+0x120>
			c4c: R_X86_64_GOTPCREL	rt_str_region_check-0x4
     c50:	mov    rcx,QWORD PTR [rsp]
     c54:	mov    rdx,rbx
     c57:	mov    rsi,r14
     c5a:	mov    rdi,r15
     c5d:	call   r8
     c60:	test   rax,rax
     c63:	jne    c94 <botlish_fn_8+0x164>
     c69:	mov    rdi,r15
     c6c:	mov    QWORD PTR [rdi],r12
     c6f:	xor    rax,rax
     c72:	mov    rbx,QWORD PTR [rsp+0x10]
     c77:	mov    r12,QWORD PTR [rsp+0x18]
     c7c:	mov    r13,QWORD PTR [rsp+0x20]
     c81:	mov    r14,QWORD PTR [rsp+0x28]
     c86:	mov    r15,QWORD PTR [rsp+0x30]
     c8b:	add    rsp,0x40
     c8f:	mov    rsp,rbp
     c92:	pop    rbp
     c93:	ret
     c94:	mov    rdi,r15
     c97:	mov    QWORD PTR [rdi],r12
     c9a:	mov    rcx,r13
     c9d:	mov    QWORD PTR [rcx],rbx
     ca0:	mov    rax,QWORD PTR [rsp]
     ca4:	mov    QWORD PTR [rcx+0x8],rax
     ca8:	mov    rax,r14
     cab:	mov    rbx,QWORD PTR [rsp+0x10]
     cb0:	mov    r12,QWORD PTR [rsp+0x18]
     cb5:	mov    r13,QWORD PTR [rsp+0x20]
     cba:	mov    r14,QWORD PTR [rsp+0x28]
     cbf:	mov    r15,QWORD PTR [rsp+0x30]
     cc4:	add    rsp,0x40
     cc8:	mov    rsp,rbp
     ccb:	pop    rbp
     ccc:	ret
     ccd:	mov    rcx,r13
     cd0:	mov    rdi,r15
     cd3:	mov    rsi,QWORD PTR [rdi+0x10]
     cd7:	mov    rax,QWORD PTR [rsi+0x8]
     cdb:	mov    QWORD PTR [rdi],r12
     cde:	mov    QWORD PTR [rcx],0x1
     ce5:	mov    QWORD PTR [rcx+0x8],0x1
     ced:	mov    rbx,QWORD PTR [rsp+0x10]
     cf2:	mov    r12,QWORD PTR [rsp+0x18]
     cf7:	mov    r13,QWORD PTR [rsp+0x20]
     cfc:	mov    r14,QWORD PTR [rsp+0x28]
     d01:	mov    r15,QWORD PTR [rsp+0x30]
     d06:	add    rsp,0x40
     d0a:	mov    rsp,rbp
     d0d:	pop    rbp
     d0e:	ret
     d0f:	mov    r15,rdi
     d12:	mov    r10,QWORD PTR [rip+0x0]        # d19 <botlish_fn_8+0x1e9>
			d15: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     d19:	call   r10
     d1c:	xor    rax,rax
     d1f:	mov    rbx,QWORD PTR [rsp+0x10]
     d24:	mov    r12,QWORD PTR [rsp+0x18]
     d29:	mov    r13,QWORD PTR [rsp+0x20]
     d2e:	mov    r14,QWORD PTR [rsp+0x28]
     d33:	mov    r15,QWORD PTR [rsp+0x30]
     d38:	add    rsp,0x40
     d3c:	mov    rsp,rbp
     d3f:	pop    rbp
     d40:	ret
     d41:	add    BYTE PTR [rax],al
     d43:	add    BYTE PTR [rax],al
     d45:	add    BYTE PTR [rax],al
     d47:	add    BYTE PTR [rsi],al
     d49:	add    BYTE PTR [rax],al
     d4b:	add    BYTE PTR [rax],al
     d4d:	add    BYTE PTR [rax],al
	...

0000000000000d50 <botlish_entry_8: peek<str, int>>:
     d50:	push   rbp
     d51:	mov    rbp,rsp
     d54:	ud2

0000000000000d56 <botlish_fn_9: scan_unquoted<str, int, int>>:
     d56:	push   rbp
     d57:	mov    rbp,rsp
     d5a:	sub    rsp,0x60
     d5e:	mov    QWORD PTR [rsp+0x30],rbx
     d63:	mov    QWORD PTR [rsp+0x38],r12
     d68:	mov    QWORD PTR [rsp+0x40],r13
     d6d:	mov    QWORD PTR [rsp+0x48],r14
     d72:	mov    QWORD PTR [rsp+0x50],r15
     d77:	mov    r14,QWORD PTR [rdi]
     d7a:	mov    rax,QWORD PTR [rdi+0x8]
     d7e:	lea    r8,[r14+0x20]
     d82:	cmp    r8,rax
     d85:	ja     fc4 <botlish_fn_9+0x26e>
     d8b:	lea    rax,[r14+0x20]
     d8f:	mov    QWORD PTR [rdi],rax
     d92:	mov    r15,rdi
     d95:	mov    QWORD PTR [r14],0x0
     d9c:	mov    QWORD PTR [r14+0x8],0x0
     da4:	mov    QWORD PTR [r14+0x10],0x0
     dac:	mov    QWORD PTR [r14+0x18],0x0
     db4:	mov    QWORD PTR [r14],rsi
     db7:	mov    QWORD PTR [rsp+0x10],rsi
     dbc:	mov    QWORD PTR [r14+0x8],rdx
     dc0:	mov    QWORD PTR [rsp+0x18],rdx
     dc5:	mov    QWORD PTR [r14+0x10],rcx
     dc9:	lea    rbx,[rsp]
     dcd:	mov    QWORD PTR [rsp+0x20],rcx
     dd2:	mov    rcx,rbx
     dd5:	mov    rdx,QWORD PTR [rsp+0x20]
     dda:	mov    rsi,QWORD PTR [rsp+0x10]
     ddf:	mov    rdi,r15
     de2:	call   de7 <botlish_fn_9+0x91>
			de3: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     de7:	mov    rcx,rax
     dea:	mov    QWORD PTR [rsp+0x28],rax
     def:	test   rax,rcx
     df2:	jne    e00 <botlish_fn_9+0xaa>
     df8:	mov    rdi,r15
     dfb:	jmp    f69 <botlish_fn_9+0x213>
     e00:	mov    r12,QWORD PTR [rsp]
     e04:	mov    r13,QWORD PTR [rsp+0x8]
     e09:	mov    rdi,r15
     e0c:	mov    rcx,QWORD PTR [rdi+0x10]
     e10:	mov    r8,QWORD PTR [rcx+0x8]
     e14:	mov    r9,QWORD PTR [rip+0x0]        # e1b <botlish_fn_9+0xc5>
			e17: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
     e1b:	mov    rcx,r13
     e1e:	mov    rdx,r12
     e21:	mov    rsi,QWORD PTR [rsp+0x28]
     e26:	call   r9
     e29:	cmp    rax,0x6
     e2d:	je     e71 <botlish_fn_9+0x11b>
     e33:	mov    rdi,r15
     e36:	mov    rdx,QWORD PTR [rdi+0x10]
     e3a:	mov    r8,QWORD PTR [rdx+0x10]
     e3e:	mov    r9,QWORD PTR [rip+0x0]        # e45 <botlish_fn_9+0xef>
			e41: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
     e45:	mov    rcx,r13
     e48:	mov    rdx,r12
     e4b:	mov    rsi,QWORD PTR [rsp+0x28]
     e50:	call   r9
     e53:	cmp    rax,0x6
     e57:	je     e67 <botlish_fn_9+0x111>
     e5d:	mov    eax,0x2
     e62:	jmp    e76 <botlish_fn_9+0x120>
     e67:	mov    eax,0x6
     e6c:	jmp    e76 <botlish_fn_9+0x120>
     e71:	mov    eax,0x6
     e76:	cmp    rax,0x6
     e7a:	je     ebe <botlish_fn_9+0x168>
     e80:	mov    rdi,r15
     e83:	mov    r10,QWORD PTR [rdi+0x10]
     e87:	mov    r8,QWORD PTR [r10+0x18]
     e8b:	mov    r10,QWORD PTR [rip+0x0]        # e92 <botlish_fn_9+0x13c>
			e8e: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
     e92:	mov    rcx,r13
     e95:	mov    rdx,r12
     e98:	mov    rsi,QWORD PTR [rsp+0x28]
     e9d:	call   r10
     ea0:	cmp    rax,0x6
     ea4:	je     eb4 <botlish_fn_9+0x15e>
     eaa:	mov    eax,0x2
     eaf:	jmp    ec3 <botlish_fn_9+0x16d>
     eb4:	mov    eax,0x6
     eb9:	jmp    ec3 <botlish_fn_9+0x16d>
     ebe:	mov    eax,0x6
     ec3:	cmp    rax,0x6
     ec7:	je     f42 <botlish_fn_9+0x1ec>
     ecd:	mov    QWORD PTR [r14+0x18],0x3
     ed5:	mov    rsi,QWORD PTR [rsp+0x20]
     eda:	test   rsi,0x1
     ee1:	je     f08 <botlish_fn_9+0x1b2>
     ee7:	mov    rsi,QWORD PTR [rsp+0x20]
     eec:	mov    rax,rsi
     eef:	add    rax,0x2
     ef3:	seto   cl
     ef6:	test   cl,cl
     ef8:	jne    f08 <botlish_fn_9+0x1b2>
     efe:	mov    rsi,QWORD PTR [rsp+0x10]
     f03:	jmp    f23 <botlish_fn_9+0x1cd>
     f08:	mov    edx,0x3
     f0d:	mov    rax,QWORD PTR [rip+0x0]        # f14 <botlish_fn_9+0x1be>
			f10: R_X86_64_GOTPCREL	rt_int_add-0x4
     f14:	mov    rsi,QWORD PTR [rsp+0x20]
     f19:	mov    rdi,r15
     f1c:	call   rax
     f1e:	mov    rsi,QWORD PTR [rsp+0x10]
     f23:	mov    QWORD PTR [r14],rsi
     f26:	mov    rdx,QWORD PTR [rsp+0x18]
     f2b:	mov    QWORD PTR [r14+0x8],rdx
     f2f:	mov    QWORD PTR [r14+0x10],rax
     f33:	mov    QWORD PTR [rsp+0x10],rsi
     f38:	mov    QWORD PTR [rsp+0x20],rax
     f3d:	jmp    dd2 <botlish_fn_9+0x7c>
     f42:	mov    rdx,QWORD PTR [rsp+0x18]
     f47:	mov    rsi,QWORD PTR [rsp+0x10]
     f4c:	mov    rax,QWORD PTR [rip+0x0]        # f53 <botlish_fn_9+0x1fd>
			f4f: R_X86_64_GOTPCREL	rt_substr-0x4
     f53:	mov    rcx,QWORD PTR [rsp+0x20]
     f58:	mov    rdi,r15
     f5b:	call   rax
     f5d:	test   rax,rax
     f60:	jne    f97 <botlish_fn_9+0x241>
     f66:	mov    rdi,r15
     f69:	mov    rdi,r15
     f6c:	mov    QWORD PTR [rdi],r14
     f6f:	xor    rdx,rdx
     f72:	mov    rax,rdx
     f75:	mov    rbx,QWORD PTR [rsp+0x30]
     f7a:	mov    r12,QWORD PTR [rsp+0x38]
     f7f:	mov    r13,QWORD PTR [rsp+0x40]
     f84:	mov    r14,QWORD PTR [rsp+0x48]
     f89:	mov    r15,QWORD PTR [rsp+0x50]
     f8e:	add    rsp,0x60
     f92:	mov    rsp,rbp
     f95:	pop    rbp
     f96:	ret
     f97:	mov    rdi,r15
     f9a:	mov    QWORD PTR [rdi],r14
     f9d:	mov    rdx,QWORD PTR [rsp+0x20]
     fa2:	mov    rbx,QWORD PTR [rsp+0x30]
     fa7:	mov    r12,QWORD PTR [rsp+0x38]
     fac:	mov    r13,QWORD PTR [rsp+0x40]
     fb1:	mov    r14,QWORD PTR [rsp+0x48]
     fb6:	mov    r15,QWORD PTR [rsp+0x50]
     fbb:	add    rsp,0x60
     fbf:	mov    rsp,rbp
     fc2:	pop    rbp
     fc3:	ret
     fc4:	mov    r15,rdi
     fc7:	mov    rax,QWORD PTR [rip+0x0]        # fce <botlish_fn_9+0x278>
			fca: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     fce:	call   rax
     fd0:	xor    rdx,rdx
     fd3:	mov    rax,rdx
     fd6:	mov    rbx,QWORD PTR [rsp+0x30]
     fdb:	mov    r12,QWORD PTR [rsp+0x38]
     fe0:	mov    r13,QWORD PTR [rsp+0x40]
     fe5:	mov    r14,QWORD PTR [rsp+0x48]
     fea:	mov    r15,QWORD PTR [rsp+0x50]
     fef:	add    rsp,0x60
     ff3:	mov    rsp,rbp
     ff6:	pop    rbp
     ff7:	ret

0000000000000ff8 <botlish_entry_9: scan_unquoted<str, int, int>>:
     ff8:	push   rbp
     ff9:	mov    rbp,rsp
     ffc:	ud2

0000000000000ffe <botlish_fn_10: scan_quoted<str, int, str>>:
     ffe:	push   rbp
     fff:	mov    rbp,rsp
    1002:	sub    rsp,0x50
    1006:	mov    QWORD PTR [rsp+0x20],rbx
    100b:	mov    QWORD PTR [rsp+0x28],r12
    1010:	mov    QWORD PTR [rsp+0x30],r13
    1015:	mov    QWORD PTR [rsp+0x38],r14
    101a:	mov    QWORD PTR [rsp+0x40],r15
    101f:	mov    r13,QWORD PTR [rdi]
    1022:	mov    rax,QWORD PTR [rdi+0x8]
    1026:	lea    r8,[r13+0x28]
    102a:	cmp    r8,rax
    102d:	ja     133a <botlish_fn_10+0x33c>
    1033:	lea    rax,[r13+0x28]
    1037:	mov    QWORD PTR [rdi],rax
    103a:	mov    r14,rdi
    103d:	mov    QWORD PTR [r13+0x0],0x0
    1045:	mov    QWORD PTR [r13+0x8],0x0
    104d:	mov    QWORD PTR [r13+0x10],0x0
    1055:	mov    QWORD PTR [r13+0x18],0x0
    105d:	mov    QWORD PTR [r13+0x20],0x0
    1065:	mov    QWORD PTR [r13+0x0],rsi
    1069:	mov    QWORD PTR [r13+0x8],rdx
    106d:	mov    QWORD PTR [r13+0x10],rcx
    1071:	lea    r12,[rsp]
    1075:	mov    rbx,rsi
    1078:	mov    r15,rdx
    107b:	mov    QWORD PTR [rsp+0x10],rcx
    1080:	mov    rdx,r15
    1083:	mov    rsi,rbx
    1086:	mov    rdi,r14
    1089:	call   108e <botlish_fn_10+0x90>
			108a: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
    108e:	test   rax,rax
    1091:	jne    109f <botlish_fn_10+0xa1>
    1097:	mov    rdi,r14
    109a:	jmp    12f3 <botlish_fn_10+0x2f5>
    109f:	mov    QWORD PTR [r13+0x18],rax
    10a3:	mov    rdi,r14
    10a6:	mov    QWORD PTR [rsp+0x18],rax
    10ab:	mov    rcx,QWORD PTR [rdi+0x10]
    10af:	mov    rsi,QWORD PTR [rcx+0x20]
    10b3:	mov    edx,0x1
    10b8:	mov    ecx,0x3
    10bd:	mov    r9,QWORD PTR [rip+0x0]        # 10c4 <botlish_fn_10+0xc6>
			10c0: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    10c4:	mov    r8,QWORD PTR [rsp+0x18]
    10c9:	call   r9
    10cc:	cmp    rax,0x6
    10d0:	je     1163 <botlish_fn_10+0x165>
    10d6:	mov    QWORD PTR [r13+0x20],0x3
    10de:	mov    rsi,r15
    10e1:	test   rsi,0x1
    10e8:	je     1108 <botlish_fn_10+0x10a>
    10ee:	mov    rax,rsi
    10f1:	add    rax,0x2
    10f5:	seto   cl
    10f8:	test   cl,cl
    10fa:	jne    1108 <botlish_fn_10+0x10a>
    1100:	mov    rsi,rax
    1103:	jmp    111c <botlish_fn_10+0x11e>
    1108:	mov    edx,0x3
    110d:	mov    rax,QWORD PTR [rip+0x0]        # 1114 <botlish_fn_10+0x116>
			1110: R_X86_64_GOTPCREL	rt_int_add-0x4
    1114:	mov    rdi,r14
    1117:	call   rax
    1119:	mov    rsi,rax
    111c:	mov    QWORD PTR [r13+0x8],rsi
    1120:	mov    r15,rsi
    1123:	mov    rax,QWORD PTR [rip+0x0]        # 112a <botlish_fn_10+0x12c>
			1126: R_X86_64_GOTPCREL	rt_str_cat-0x4
    112a:	mov    rdx,QWORD PTR [rsp+0x18]
    112f:	mov    rsi,QWORD PTR [rsp+0x10]
    1134:	mov    rdi,r14
    1137:	call   rax
    1139:	test   rax,rax
    113c:	jne    114a <botlish_fn_10+0x14c>
    1142:	mov    rdi,r14
    1145:	jmp    12f3 <botlish_fn_10+0x2f5>
    114a:	mov    QWORD PTR [r13+0x0],rbx
    114e:	mov    rsi,r15
    1151:	mov    QWORD PTR [r13+0x8],rsi
    1155:	mov    QWORD PTR [r13+0x10],rax
    1159:	mov    QWORD PTR [rsp+0x10],rax
    115e:	jmp    1080 <botlish_fn_10+0x82>
    1163:	mov    QWORD PTR [r13+0x18],0x3
    116b:	mov    rsi,r15
    116e:	test   rsi,0x1
    1175:	je     1190 <botlish_fn_10+0x192>
    117b:	mov    rsi,r15
    117e:	mov    rdx,rsi
    1181:	add    rdx,0x2
    1185:	seto   al
    1188:	test   al,al
    118a:	je     11a7 <botlish_fn_10+0x1a9>
    1190:	mov    edx,0x3
    1195:	mov    rax,QWORD PTR [rip+0x0]        # 119c <botlish_fn_10+0x19e>
			1198: R_X86_64_GOTPCREL	rt_int_add-0x4
    119c:	mov    rsi,r15
    119f:	mov    rdi,r14
    11a2:	call   rax
    11a4:	mov    rdx,rax
    11a7:	mov    QWORD PTR [r13+0x18],rdx
    11ab:	mov    rcx,r12
    11ae:	mov    rsi,rbx
    11b1:	mov    rdi,r14
    11b4:	call   11b9 <botlish_fn_10+0x1bb>
			11b5: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    11b9:	test   rax,rax
    11bc:	mov    rsi,rax
    11bf:	jne    11cd <botlish_fn_10+0x1cf>
    11c5:	mov    rdi,r14
    11c8:	jmp    12f3 <botlish_fn_10+0x2f5>
    11cd:	mov    rdx,QWORD PTR [rsp]
    11d1:	mov    rcx,QWORD PTR [rsp+0x8]
    11d6:	mov    rdi,r14
    11d9:	mov    rax,QWORD PTR [rdi+0x10]
    11dd:	mov    r8,QWORD PTR [rax+0x20]
    11e1:	mov    rax,QWORD PTR [rip+0x0]        # 11e8 <botlish_fn_10+0x1ea>
			11e4: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    11e8:	call   rax
    11ea:	cmp    rax,0x6
    11ee:	je     1270 <botlish_fn_10+0x272>
    11f4:	mov    QWORD PTR [r13+0x0],0x3
    11fc:	mov    rsi,r15
    11ff:	test   rsi,0x1
    1206:	je     1229 <botlish_fn_10+0x22b>
    120c:	mov    rsi,r15
    120f:	mov    rdx,rsi
    1212:	add    rdx,0x2
    1216:	seto   al
    1219:	test   al,al
    121b:	jne    1229 <botlish_fn_10+0x22b>
    1221:	mov    rdi,r14
    1224:	jmp    1243 <botlish_fn_10+0x245>
    1229:	mov    edx,0x3
    122e:	mov    rax,QWORD PTR [rip+0x0]        # 1235 <botlish_fn_10+0x237>
			1231: R_X86_64_GOTPCREL	rt_int_add-0x4
    1235:	mov    rsi,r15
    1238:	mov    rdi,r14
    123b:	call   rax
    123d:	mov    rdx,rax
    1240:	mov    rdi,r14
    1243:	mov    rdi,r14
    1246:	mov    QWORD PTR [rdi],r13
    1249:	mov    rax,QWORD PTR [rsp+0x10]
    124e:	mov    rbx,QWORD PTR [rsp+0x20]
    1253:	mov    r12,QWORD PTR [rsp+0x28]
    1258:	mov    r13,QWORD PTR [rsp+0x30]
    125d:	mov    r14,QWORD PTR [rsp+0x38]
    1262:	mov    r15,QWORD PTR [rsp+0x40]
    1267:	add    rsp,0x50
    126b:	mov    rsp,rbp
    126e:	pop    rbp
    126f:	ret
    1270:	mov    QWORD PTR [r13+0x18],0x5
    1278:	mov    rsi,r15
    127b:	test   rsi,0x1
    1282:	je     12aa <botlish_fn_10+0x2ac>
    1288:	mov    rsi,r15
    128b:	mov    rcx,rsi
    128e:	add    rcx,0x4
    1292:	seto   sil
    1296:	test   sil,sil
    1299:	jne    12aa <botlish_fn_10+0x2ac>
    129f:	mov    rsi,rcx
    12a2:	mov    r15,rcx
    12a5:	jmp    12c5 <botlish_fn_10+0x2c7>
    12aa:	mov    edx,0x5
    12af:	mov    r8,QWORD PTR [rip+0x0]        # 12b6 <botlish_fn_10+0x2b8>
			12b2: R_X86_64_GOTPCREL	rt_int_add-0x4
    12b6:	mov    rsi,r15
    12b9:	mov    rdi,r14
    12bc:	call   r8
    12bf:	mov    rsi,rax
    12c2:	mov    r15,rax
    12c5:	mov    QWORD PTR [r13+0x8],rsi
    12c9:	mov    rdi,r14
    12cc:	mov    r8,QWORD PTR [rdi+0x10]
    12d0:	mov    rdx,QWORD PTR [r8+0x20]
    12d4:	mov    QWORD PTR [r13+0x18],rdx
    12d8:	mov    r9,QWORD PTR [rip+0x0]        # 12df <botlish_fn_10+0x2e1>
			12db: R_X86_64_GOTPCREL	rt_str_cat-0x4
    12df:	mov    rsi,QWORD PTR [rsp+0x10]
    12e4:	call   r9
    12e7:	test   rax,rax
    12ea:	jne    1321 <botlish_fn_10+0x323>
    12f0:	mov    rdi,r14
    12f3:	mov    rdi,r14
    12f6:	mov    QWORD PTR [rdi],r13
    12f9:	xor    rdx,rdx
    12fc:	mov    rax,rdx
    12ff:	mov    rbx,QWORD PTR [rsp+0x20]
    1304:	mov    r12,QWORD PTR [rsp+0x28]
    1309:	mov    r13,QWORD PTR [rsp+0x30]
    130e:	mov    r14,QWORD PTR [rsp+0x38]
    1313:	mov    r15,QWORD PTR [rsp+0x40]
    1318:	add    rsp,0x50
    131c:	mov    rsp,rbp
    131f:	pop    rbp
    1320:	ret
    1321:	mov    QWORD PTR [r13+0x0],rbx
    1325:	mov    rsi,r15
    1328:	mov    QWORD PTR [r13+0x8],rsi
    132c:	mov    QWORD PTR [r13+0x10],rax
    1330:	mov    QWORD PTR [rsp+0x10],rax
    1335:	jmp    1080 <botlish_fn_10+0x82>
    133a:	mov    r14,rdi
    133d:	mov    rax,QWORD PTR [rip+0x0]        # 1344 <botlish_fn_10+0x346>
			1340: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1344:	call   rax
    1346:	xor    rdx,rdx
    1349:	mov    rax,rdx
    134c:	mov    rbx,QWORD PTR [rsp+0x20]
    1351:	mov    r12,QWORD PTR [rsp+0x28]
    1356:	mov    r13,QWORD PTR [rsp+0x30]
    135b:	mov    r14,QWORD PTR [rsp+0x38]
    1360:	mov    r15,QWORD PTR [rsp+0x40]
    1365:	add    rsp,0x50
    1369:	mov    rsp,rbp
    136c:	pop    rbp
    136d:	ret

000000000000136e <botlish_entry_10: scan_quoted<str, int, str>>:
    136e:	push   rbp
    136f:	mov    rbp,rsp
    1372:	ud2

0000000000001374 <botlish_fn_11: scan_field<str, int>>:
    1374:	push   rbp
    1375:	mov    rbp,rsp
    1378:	sub    rsp,0x30
    137c:	mov    QWORD PTR [rsp+0x10],rbx
    1381:	mov    QWORD PTR [rsp+0x18],r12
    1386:	mov    QWORD PTR [rsp+0x20],r13
    138b:	mov    QWORD PTR [rsp+0x28],r14
    1390:	mov    rbx,QWORD PTR [rdi]
    1393:	mov    rax,QWORD PTR [rdi+0x8]
    1397:	lea    rcx,[rbx+0x18]
    139b:	cmp    rcx,rax
    139e:	ja     1518 <botlish_fn_11+0x1a4>
    13a4:	lea    rax,[rbx+0x18]
    13a8:	mov    QWORD PTR [rdi],rax
    13ab:	mov    r12,rdi
    13ae:	mov    QWORD PTR [rbx],0x0
    13b5:	mov    QWORD PTR [rbx+0x8],0x0
    13bd:	mov    QWORD PTR [rbx+0x10],0x0
    13c5:	mov    QWORD PTR [rbx],rsi
    13c8:	mov    r13,rsi
    13cb:	mov    QWORD PTR [rbx+0x8],rdx
    13cf:	mov    r14,rdx
    13d2:	lea    rcx,[rsp]
    13d6:	mov    rdx,r14
    13d9:	mov    rsi,r13
    13dc:	mov    rdi,r12
    13df:	call   13e4 <botlish_fn_11+0x70>
			13e0: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    13e4:	test   rax,rax
    13e7:	mov    rsi,rax
    13ea:	jne    13f8 <botlish_fn_11+0x84>
    13f0:	mov    rdi,r12
    13f3:	jmp    14cc <botlish_fn_11+0x158>
    13f8:	mov    rdx,QWORD PTR [rsp]
    13fc:	mov    rcx,QWORD PTR [rsp+0x8]
    1401:	mov    rdi,r12
    1404:	mov    rax,QWORD PTR [rdi+0x10]
    1408:	mov    r8,QWORD PTR [rax+0x20]
    140c:	mov    rax,QWORD PTR [rip+0x0]        # 1413 <botlish_fn_11+0x9f>
			140f: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1413:	call   rax
    1415:	cmp    rax,0x6
    1419:	je     1464 <botlish_fn_11+0xf0>
    141f:	mov    rcx,r14
    1422:	mov    rsi,r13
    1425:	mov    rdi,r12
    1428:	mov    rdx,rcx
    142b:	call   1430 <botlish_fn_11+0xbc>
			142c: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_unquoted<str, int, int>
    1430:	test   rax,rax
    1433:	jne    1441 <botlish_fn_11+0xcd>
    1439:	mov    rdi,r12
    143c:	jmp    14cc <botlish_fn_11+0x158>
    1441:	mov    rdi,r12
    1444:	mov    QWORD PTR [rdi],rbx
    1447:	mov    rbx,QWORD PTR [rsp+0x10]
    144c:	mov    r12,QWORD PTR [rsp+0x18]
    1451:	mov    r13,QWORD PTR [rsp+0x20]
    1456:	mov    r14,QWORD PTR [rsp+0x28]
    145b:	add    rsp,0x30
    145f:	mov    rsp,rbp
    1462:	pop    rbp
    1463:	ret
    1464:	mov    QWORD PTR [rbx+0x10],0x3
    146c:	mov    rdx,r14
    146f:	test   rdx,0x1
    1476:	je     148e <botlish_fn_11+0x11a>
    147c:	mov    rdx,r14
    147f:	add    rdx,0x2
    1483:	seto   al
    1486:	test   al,al
    1488:	je     14a5 <botlish_fn_11+0x131>
    148e:	mov    edx,0x3
    1493:	mov    rax,QWORD PTR [rip+0x0]        # 149a <botlish_fn_11+0x126>
			1496: R_X86_64_GOTPCREL	rt_int_add-0x4
    149a:	mov    rsi,r14
    149d:	mov    rdi,r12
    14a0:	call   rax
    14a2:	mov    rdx,rax
    14a5:	mov    QWORD PTR [rbx+0x8],rdx
    14a9:	mov    rdi,r12
    14ac:	mov    rax,QWORD PTR [rdi+0x10]
    14b0:	mov    rcx,QWORD PTR [rax+0x8]
    14b4:	mov    QWORD PTR [rbx+0x10],rcx
    14b8:	mov    rsi,r13
    14bb:	call   14c0 <botlish_fn_11+0x14c>
			14bc: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_quoted<str, int, str>
    14c0:	test   rax,rax
    14c3:	jne    14f5 <botlish_fn_11+0x181>
    14c9:	mov    rdi,r12
    14cc:	mov    rdi,r12
    14cf:	mov    QWORD PTR [rdi],rbx
    14d2:	xor    rdx,rdx
    14d5:	mov    rax,rdx
    14d8:	mov    rbx,QWORD PTR [rsp+0x10]
    14dd:	mov    r12,QWORD PTR [rsp+0x18]
    14e2:	mov    r13,QWORD PTR [rsp+0x20]
    14e7:	mov    r14,QWORD PTR [rsp+0x28]
    14ec:	add    rsp,0x30
    14f0:	mov    rsp,rbp
    14f3:	pop    rbp
    14f4:	ret
    14f5:	mov    rdi,r12
    14f8:	mov    QWORD PTR [rdi],rbx
    14fb:	mov    rbx,QWORD PTR [rsp+0x10]
    1500:	mov    r12,QWORD PTR [rsp+0x18]
    1505:	mov    r13,QWORD PTR [rsp+0x20]
    150a:	mov    r14,QWORD PTR [rsp+0x28]
    150f:	add    rsp,0x30
    1513:	mov    rsp,rbp
    1516:	pop    rbp
    1517:	ret
    1518:	mov    r12,rdi
    151b:	mov    rsi,QWORD PTR [rip+0x0]        # 1522 <botlish_fn_11+0x1ae>
			151e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1522:	call   rsi
    1524:	xor    rdx,rdx
    1527:	mov    rax,rdx
    152a:	mov    rbx,QWORD PTR [rsp+0x10]
    152f:	mov    r12,QWORD PTR [rsp+0x18]
    1534:	mov    r13,QWORD PTR [rsp+0x20]
    1539:	mov    r14,QWORD PTR [rsp+0x28]
    153e:	add    rsp,0x30
    1542:	mov    rsp,rbp
    1545:	pop    rbp
    1546:	ret

0000000000001547 <botlish_entry_11: scan_field<str, int>>:
    1547:	push   rbp
    1548:	mov    rbp,rsp
    154b:	ud2

000000000000154d <botlish_fn_12: scan_record<str, int, list[mutarray, int]>>:
    154d:	push   rbp
    154e:	mov    rbp,rsp
    1551:	sub    rsp,0x70
    1555:	mov    QWORD PTR [rsp+0x40],rbx
    155a:	mov    QWORD PTR [rsp+0x48],r12
    155f:	mov    QWORD PTR [rsp+0x50],r13
    1564:	mov    QWORD PTR [rsp+0x58],r14
    1569:	mov    QWORD PTR [rsp+0x60],r15
    156e:	mov    r12,QWORD PTR [rdi]
    1571:	mov    rax,QWORD PTR [rdi+0x8]
    1575:	lea    r9,[r12+0x28]
    157a:	cmp    r9,rax
    157d:	ja     1878 <botlish_fn_12+0x32b>
    1583:	lea    rax,[r12+0x28]
    1588:	mov    QWORD PTR [rdi],rax
    158b:	mov    QWORD PTR [rsp+0x10],rdi
    1590:	mov    QWORD PTR [r12],0x0
    1598:	mov    QWORD PTR [r12+0x8],0x0
    15a1:	mov    QWORD PTR [r12+0x10],0x0
    15aa:	mov    QWORD PTR [r12+0x18],0x0
    15b3:	mov    QWORD PTR [r12+0x20],0x0
    15bc:	mov    QWORD PTR [r12],rsi
    15c0:	mov    QWORD PTR [r12+0x8],rdx
    15c5:	mov    QWORD PTR [r12+0x10],rcx
    15ca:	mov    QWORD PTR [r12+0x18],r8
    15cf:	lea    rbx,[rsp]
    15d3:	mov    r13,r8
    15d6:	mov    r14,rcx
    15d9:	mov    r15,rsi
    15dc:	mov    rsi,r15
    15df:	mov    rdi,QWORD PTR [rsp+0x10]
    15e4:	call   15e9 <botlish_fn_12+0x9c>
			15e5: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_field<str, int>
    15e9:	test   rax,rax
    15ec:	jne    15fc <botlish_fn_12+0xaf>
    15f2:	mov    rdi,QWORD PTR [rsp+0x10]
    15f7:	jmp    174a <botlish_fn_12+0x1fd>
    15fc:	mov    QWORD PTR [r12+0x8],rax
    1601:	mov    rcx,rax
    1604:	mov    QWORD PTR [r12+0x20],rdx
    1609:	mov    QWORD PTR [rsp+0x30],rdx
    160e:	mov    rsi,r14
    1611:	mov    rdx,r13
    1614:	mov    rdi,QWORD PTR [rsp+0x10]
    1619:	call   161e <botlish_fn_12+0xd1>
			161a: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    161e:	test   rax,rax
    1621:	jne    1631 <botlish_fn_12+0xe4>
    1627:	mov    rdi,QWORD PTR [rsp+0x10]
    162c:	jmp    174a <botlish_fn_12+0x1fd>
    1631:	mov    QWORD PTR [r12+0x8],rax
    1636:	mov    QWORD PTR [rsp+0x20],rax
    163b:	mov    QWORD PTR [r12+0x10],rdx
    1640:	mov    QWORD PTR [rsp+0x28],rdx
    1645:	mov    rcx,rbx
    1648:	mov    rdx,QWORD PTR [rsp+0x30]
    164d:	mov    rsi,r15
    1650:	mov    rdi,QWORD PTR [rsp+0x10]
    1655:	call   165a <botlish_fn_12+0x10d>
			1656: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    165a:	test   rax,rax
    165d:	mov    QWORD PTR [rsp+0x18],rax
    1662:	jne    1672 <botlish_fn_12+0x125>
    1668:	mov    rdi,QWORD PTR [rsp+0x10]
    166d:	jmp    174a <botlish_fn_12+0x1fd>
    1672:	mov    r14,QWORD PTR [rsp]
    1676:	mov    r13,QWORD PTR [rsp+0x8]
    167b:	mov    rdi,QWORD PTR [rsp+0x10]
    1680:	mov    r9,QWORD PTR [rdi+0x10]
    1684:	mov    r8,QWORD PTR [r9+0x10]
    1688:	mov    r9,QWORD PTR [rip+0x0]        # 168f <botlish_fn_12+0x142>
			168b: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    168f:	mov    rcx,r13
    1692:	mov    rdx,r14
    1695:	mov    rsi,QWORD PTR [rsp+0x18]
    169a:	call   r9
    169d:	cmp    rax,0x6
    16a1:	je     1807 <botlish_fn_12+0x2ba>
    16a7:	mov    rdi,QWORD PTR [rsp+0x10]
    16ac:	mov    rax,QWORD PTR [rdi+0x10]
    16b0:	mov    r8,QWORD PTR [rax+0x18]
    16b4:	mov    rax,QWORD PTR [rip+0x0]        # 16bb <botlish_fn_12+0x16e>
			16b7: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    16bb:	mov    rcx,r13
    16be:	mov    rdx,r14
    16c1:	mov    rsi,QWORD PTR [rsp+0x18]
    16c6:	call   rax
    16c8:	cmp    rax,0x6
    16cc:	je     1728 <botlish_fn_12+0x1db>
    16d2:	mov    rdx,QWORD PTR [rsp+0x28]
    16d7:	mov    rsi,QWORD PTR [rsp+0x20]
    16dc:	mov    rdi,QWORD PTR [rsp+0x10]
    16e1:	call   16e6 <botlish_fn_12+0x199>
			16e2: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    16e6:	test   rax,rax
    16e9:	jne    16f9 <botlish_fn_12+0x1ac>
    16ef:	mov    rdi,QWORD PTR [rsp+0x10]
    16f4:	jmp    174a <botlish_fn_12+0x1fd>
    16f9:	mov    rdi,QWORD PTR [rsp+0x10]
    16fe:	mov    QWORD PTR [rdi],r12
    1701:	mov    rdx,QWORD PTR [rsp+0x30]
    1706:	mov    rbx,QWORD PTR [rsp+0x40]
    170b:	mov    r12,QWORD PTR [rsp+0x48]
    1710:	mov    r13,QWORD PTR [rsp+0x50]
    1715:	mov    r14,QWORD PTR [rsp+0x58]
    171a:	mov    r15,QWORD PTR [rsp+0x60]
    171f:	add    rsp,0x70
    1723:	mov    rsp,rbp
    1726:	pop    rbp
    1727:	ret
    1728:	mov    rdx,QWORD PTR [rsp+0x28]
    172d:	mov    rsi,QWORD PTR [rsp+0x20]
    1732:	mov    rdi,QWORD PTR [rsp+0x10]
    1737:	call   173c <botlish_fn_12+0x1ef>
			1738: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    173c:	test   rax,rax
    173f:	jne    177a <botlish_fn_12+0x22d>
    1745:	mov    rdi,QWORD PTR [rsp+0x10]
    174a:	mov    rdi,QWORD PTR [rsp+0x10]
    174f:	mov    QWORD PTR [rdi],r12
    1752:	xor    rdx,rdx
    1755:	mov    rax,rdx
    1758:	mov    rbx,QWORD PTR [rsp+0x40]
    175d:	mov    r12,QWORD PTR [rsp+0x48]
    1762:	mov    r13,QWORD PTR [rsp+0x50]
    1767:	mov    r14,QWORD PTR [rsp+0x58]
    176c:	mov    r15,QWORD PTR [rsp+0x60]
    1771:	add    rsp,0x70
    1775:	mov    rsp,rbp
    1778:	pop    rbp
    1779:	ret
    177a:	mov    QWORD PTR [r12],rax
    177e:	mov    rbx,rax
    1781:	mov    QWORD PTR [r12+0x8],0x3
    178a:	mov    rdx,QWORD PTR [rsp+0x30]
    178f:	test   rdx,0x1
    1796:	je     17ba <botlish_fn_12+0x26d>
    179c:	mov    rdx,QWORD PTR [rsp+0x30]
    17a1:	add    rdx,0x2
    17a5:	seto   al
    17a8:	test   al,al
    17aa:	jne    17ba <botlish_fn_12+0x26d>
    17b0:	mov    rdi,QWORD PTR [rsp+0x10]
    17b5:	jmp    17da <botlish_fn_12+0x28d>
    17ba:	mov    edx,0x3
    17bf:	mov    rax,QWORD PTR [rip+0x0]        # 17c6 <botlish_fn_12+0x279>
			17c2: R_X86_64_GOTPCREL	rt_int_add-0x4
    17c6:	mov    rsi,QWORD PTR [rsp+0x30]
    17cb:	mov    rdi,QWORD PTR [rsp+0x10]
    17d0:	call   rax
    17d2:	mov    rdx,rax
    17d5:	mov    rdi,QWORD PTR [rsp+0x10]
    17da:	mov    rdi,QWORD PTR [rsp+0x10]
    17df:	mov    QWORD PTR [rdi],r12
    17e2:	mov    rax,rbx
    17e5:	mov    rbx,QWORD PTR [rsp+0x40]
    17ea:	mov    r12,QWORD PTR [rsp+0x48]
    17ef:	mov    r13,QWORD PTR [rsp+0x50]
    17f4:	mov    r14,QWORD PTR [rsp+0x58]
    17f9:	mov    r15,QWORD PTR [rsp+0x60]
    17fe:	add    rsp,0x70
    1802:	mov    rsp,rbp
    1805:	pop    rbp
    1806:	ret
    1807:	mov    rsi,QWORD PTR [rsp+0x30]
    180c:	mov    edx,0x3
    1811:	mov    rcx,rdx
    1814:	mov    QWORD PTR [r12+0x18],0x3
    181d:	test   rsi,0x1
    1824:	je     183c <botlish_fn_12+0x2ef>
    182a:	mov    rdx,rsi
    182d:	add    rdx,0x2
    1831:	seto   al
    1834:	test   al,al
    1836:	je     1850 <botlish_fn_12+0x303>
    183c:	mov    rax,QWORD PTR [rip+0x0]        # 1843 <botlish_fn_12+0x2f6>
			183f: R_X86_64_GOTPCREL	rt_int_add-0x4
    1843:	mov    rdx,rcx
    1846:	mov    rdi,QWORD PTR [rsp+0x10]
    184b:	call   rax
    184d:	mov    rdx,rax
    1850:	mov    QWORD PTR [r12],r15
    1854:	mov    QWORD PTR [r12+0x8],rdx
    1859:	mov    rsi,QWORD PTR [rsp+0x20]
    185e:	mov    QWORD PTR [r12+0x10],rsi
    1863:	mov    rax,QWORD PTR [rsp+0x28]
    1868:	mov    QWORD PTR [r12+0x18],rax
    186d:	mov    r13,rax
    1870:	mov    r14,rsi
    1873:	jmp    15dc <botlish_fn_12+0x8f>
    1878:	mov    QWORD PTR [rsp+0x10],rdi
    187d:	mov    rax,QWORD PTR [rip+0x0]        # 1884 <botlish_fn_12+0x337>
			1880: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1884:	call   rax
    1886:	xor    rdx,rdx
    1889:	mov    rax,rdx
    188c:	mov    rbx,QWORD PTR [rsp+0x40]
    1891:	mov    r12,QWORD PTR [rsp+0x48]
    1896:	mov    r13,QWORD PTR [rsp+0x50]
    189b:	mov    r14,QWORD PTR [rsp+0x58]
    18a0:	mov    r15,QWORD PTR [rsp+0x60]
    18a5:	add    rsp,0x70
    18a9:	mov    rsp,rbp
    18ac:	pop    rbp
    18ad:	ret

00000000000018ae <botlish_entry_12: scan_record<str, int, list[mutarray, int]>>:
    18ae:	push   rbp
    18af:	mov    rbp,rsp
    18b2:	ud2
    18b4:	add    BYTE PTR [rax],al
	...

00000000000018b8 <botlish_fn_13: scan_records<str, int, list[mutarray, int]>>:
    18b8:	push   rbp
    18b9:	mov    rbp,rsp
    18bc:	sub    rsp,0x40
    18c0:	mov    QWORD PTR [rsp+0x10],rbx
    18c5:	mov    QWORD PTR [rsp+0x18],r12
    18ca:	mov    QWORD PTR [rsp+0x20],r13
    18cf:	mov    QWORD PTR [rsp+0x28],r14
    18d4:	mov    QWORD PTR [rsp+0x30],r15
    18d9:	mov    r12,QWORD PTR [rdi]
    18dc:	mov    rax,QWORD PTR [rdi+0x8]
    18e0:	lea    r9,[r12+0x30]
    18e5:	cmp    r9,rax
    18e8:	ja     1abc <botlish_fn_13+0x204>
    18ee:	lea    rax,[r12+0x30]
    18f3:	mov    QWORD PTR [rdi],rax
    18f6:	mov    r14,rdi
    18f9:	mov    QWORD PTR [r12],0x0
    1901:	mov    QWORD PTR [r12+0x8],0x0
    190a:	mov    QWORD PTR [r12+0x10],0x0
    1913:	mov    QWORD PTR [r12+0x18],0x0
    191c:	mov    QWORD PTR [r12+0x20],0x0
    1925:	mov    QWORD PTR [r12+0x28],0x0
    192e:	mov    QWORD PTR [r12],rsi
    1932:	mov    QWORD PTR [r12+0x8],rdx
    1937:	mov    r13,rdx
    193a:	mov    QWORD PTR [r12+0x10],rcx
    193f:	mov    QWORD PTR [r12+0x18],r8
    1944:	mov    r15,r8
    1947:	mov    QWORD PTR [rsp],rcx
    194b:	mov    rax,QWORD PTR [rip+0x0]        # 1952 <botlish_fn_13+0x9a>
			194e: R_X86_64_GOTPCREL	rt_str_len-0x4
    1952:	mov    rbx,rsi
    1955:	mov    rdi,r14
    1958:	call   rax
    195a:	mov    rcx,r13
    195d:	and    rcx,rax
    1960:	mov    rdx,rax
    1963:	test   rcx,0x1
    196a:	jne    1994 <botlish_fn_13+0xdc>
    1970:	mov    rax,QWORD PTR [rip+0x0]        # 1977 <botlish_fn_13+0xbf>
			1973: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1977:	mov    rsi,r13
    197a:	mov    rdi,r14
    197d:	call   rax
    197f:	mov    ecx,0x2
    1984:	test   rax,rax
    1987:	cmovge rcx,QWORD PTR [rip+0x161]        # 1af0 <botlish_fn_13+0x238>
    198f:	jmp    19a7 <botlish_fn_13+0xef>
    1994:	mov    ecx,0x2
    1999:	mov    rax,r13
    199c:	cmp    rax,rdx
    199f:	cmovge rcx,QWORD PTR [rip+0x149]        # 1af0 <botlish_fn_13+0x238>
    19a7:	cmp    rcx,0x6
    19ab:	je     1a4e <botlish_fn_13+0x196>
    19b1:	mov    rdi,r14
    19b4:	call   19b9 <botlish_fn_13+0x101>
			19b5: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    19b9:	test   rax,rax
    19bc:	jne    19ca <botlish_fn_13+0x112>
    19c2:	mov    rdi,r14
    19c5:	jmp    1a69 <botlish_fn_13+0x1b1>
    19ca:	mov    QWORD PTR [r12+0x20],rax
    19cf:	mov    rcx,rax
    19d2:	mov    QWORD PTR [r12+0x28],rdx
    19d7:	mov    r8,rdx
    19da:	mov    rdx,r13
    19dd:	mov    rsi,rbx
    19e0:	mov    rdi,r14
    19e3:	call   19e8 <botlish_fn_13+0x130>
			19e4: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_record<str, int, list[mutarray, int]>
    19e8:	test   rax,rax
    19eb:	jne    19f9 <botlish_fn_13+0x141>
    19f1:	mov    rdi,r14
    19f4:	jmp    1a69 <botlish_fn_13+0x1b1>
    19f9:	mov    QWORD PTR [r12+0x8],rax
    19fe:	mov    rcx,rax
    1a01:	mov    QWORD PTR [r12+0x20],rdx
    1a06:	mov    r13,rdx
    1a09:	mov    rsi,QWORD PTR [rsp]
    1a0d:	mov    rdx,r15
    1a10:	mov    rdi,r14
    1a13:	call   1a18 <botlish_fn_13+0x160>
			1a14: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1a18:	test   rax,rax
    1a1b:	jne    1a29 <botlish_fn_13+0x171>
    1a21:	mov    rdi,r14
    1a24:	jmp    1a69 <botlish_fn_13+0x1b1>
    1a29:	mov    QWORD PTR [r12],rbx
    1a2d:	mov    rcx,r13
    1a30:	mov    QWORD PTR [r12+0x8],rcx
    1a35:	mov    QWORD PTR [r12+0x10],rax
    1a3a:	mov    QWORD PTR [r12+0x18],rdx
    1a3f:	mov    rsi,rbx
    1a42:	mov    r15,rdx
    1a45:	mov    QWORD PTR [rsp],rax
    1a49:	jmp    194b <botlish_fn_13+0x93>
    1a4e:	mov    rdx,r15
    1a51:	mov    rsi,QWORD PTR [rsp]
    1a55:	mov    rdi,r14
    1a58:	call   1a5d <botlish_fn_13+0x1a5>
			1a59: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    1a5d:	test   rax,rax
    1a60:	jne    1a94 <botlish_fn_13+0x1dc>
    1a66:	mov    rdi,r14
    1a69:	mov    rdi,r14
    1a6c:	mov    QWORD PTR [rdi],r12
    1a6f:	xor    rax,rax
    1a72:	mov    rbx,QWORD PTR [rsp+0x10]
    1a77:	mov    r12,QWORD PTR [rsp+0x18]
    1a7c:	mov    r13,QWORD PTR [rsp+0x20]
    1a81:	mov    r14,QWORD PTR [rsp+0x28]
    1a86:	mov    r15,QWORD PTR [rsp+0x30]
    1a8b:	add    rsp,0x40
    1a8f:	mov    rsp,rbp
    1a92:	pop    rbp
    1a93:	ret
    1a94:	mov    rdi,r14
    1a97:	mov    QWORD PTR [rdi],r12
    1a9a:	mov    rbx,QWORD PTR [rsp+0x10]
    1a9f:	mov    r12,QWORD PTR [rsp+0x18]
    1aa4:	mov    r13,QWORD PTR [rsp+0x20]
    1aa9:	mov    r14,QWORD PTR [rsp+0x28]
    1aae:	mov    r15,QWORD PTR [rsp+0x30]
    1ab3:	add    rsp,0x40
    1ab7:	mov    rsp,rbp
    1aba:	pop    rbp
    1abb:	ret
    1abc:	mov    r14,rdi
    1abf:	mov    rax,QWORD PTR [rip+0x0]        # 1ac6 <botlish_fn_13+0x20e>
			1ac2: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1ac6:	call   rax
    1ac8:	xor    rax,rax
    1acb:	mov    rbx,QWORD PTR [rsp+0x10]
    1ad0:	mov    r12,QWORD PTR [rsp+0x18]
    1ad5:	mov    r13,QWORD PTR [rsp+0x20]
    1ada:	mov    r14,QWORD PTR [rsp+0x28]
    1adf:	mov    r15,QWORD PTR [rsp+0x30]
    1ae4:	add    rsp,0x40
    1ae8:	mov    rsp,rbp
    1aeb:	pop    rbp
    1aec:	ret
    1aed:	add    BYTE PTR [rax],al
    1aef:	add    BYTE PTR [rsi],al
    1af1:	add    BYTE PTR [rax],al
    1af3:	add    BYTE PTR [rax],al
    1af5:	add    BYTE PTR [rax],al
	...

0000000000001af8 <botlish_entry_13: scan_records<str, int, list[mutarray, int]>>:
    1af8:	push   rbp
    1af9:	mov    rbp,rsp
    1afc:	mov    rsi,QWORD PTR [rdx]
    1aff:	mov    r9,QWORD PTR [rdx+0x8]
    1b03:	mov    rcx,QWORD PTR [rdx+0x10]
    1b07:	mov    r8,QWORD PTR [rdx+0x18]
    1b0b:	mov    rdx,r9
    1b0e:	call   1b13 <botlish_entry_13+0x1b>
			1b0f: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    1b13:	mov    rsp,rbp
    1b16:	pop    rbp
    1b17:	ret

0000000000001b18 <botlish_fn_14: csv_parse<str>>:
    1b18:	push   rbp
    1b19:	mov    rbp,rsp
    1b1c:	sub    rsp,0x20
    1b20:	mov    QWORD PTR [rsp],rbx
    1b24:	mov    QWORD PTR [rsp+0x8],r12
    1b29:	mov    QWORD PTR [rsp+0x10],r13
    1b2e:	mov    rbx,QWORD PTR [rdi]
    1b31:	mov    rax,QWORD PTR [rdi+0x8]
    1b35:	lea    rcx,[rbx+0x20]
    1b39:	cmp    rcx,rax
    1b3c:	ja     1bf9 <botlish_fn_14+0xe1>
    1b42:	lea    rax,[rbx+0x20]
    1b46:	mov    QWORD PTR [rdi],rax
    1b49:	mov    r12,rdi
    1b4c:	mov    QWORD PTR [rbx],0x0
    1b53:	mov    QWORD PTR [rbx+0x8],0x0
    1b5b:	mov    QWORD PTR [rbx+0x10],0x0
    1b63:	mov    QWORD PTR [rbx+0x18],0x0
    1b6b:	mov    QWORD PTR [rbx],rsi
    1b6e:	mov    r13,rsi
    1b71:	mov    QWORD PTR [rbx+0x8],0x1
    1b79:	mov    rdi,r12
    1b7c:	call   1b81 <botlish_fn_14+0x69>
			1b7d: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1b81:	test   rax,rax
    1b84:	jne    1b92 <botlish_fn_14+0x7a>
    1b8a:	mov    rdi,r12
    1b8d:	jmp    1bbc <botlish_fn_14+0xa4>
    1b92:	mov    QWORD PTR [rbx+0x10],rax
    1b96:	mov    rcx,rax
    1b99:	mov    QWORD PTR [rbx+0x18],rdx
    1b9d:	mov    r8,rdx
    1ba0:	mov    edx,0x1
    1ba5:	mov    rsi,r13
    1ba8:	mov    rdi,r12
    1bab:	call   1bb0 <botlish_fn_14+0x98>
			1bac: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    1bb0:	test   rax,rax
    1bb3:	jne    1bdc <botlish_fn_14+0xc4>
    1bb9:	mov    rdi,r12
    1bbc:	mov    rdi,r12
    1bbf:	mov    QWORD PTR [rdi],rbx
    1bc2:	xor    rax,rax
    1bc5:	mov    rbx,QWORD PTR [rsp]
    1bc9:	mov    r12,QWORD PTR [rsp+0x8]
    1bce:	mov    r13,QWORD PTR [rsp+0x10]
    1bd3:	add    rsp,0x20
    1bd7:	mov    rsp,rbp
    1bda:	pop    rbp
    1bdb:	ret
    1bdc:	mov    rdi,r12
    1bdf:	mov    QWORD PTR [rdi],rbx
    1be2:	mov    rbx,QWORD PTR [rsp]
    1be6:	mov    r12,QWORD PTR [rsp+0x8]
    1beb:	mov    r13,QWORD PTR [rsp+0x10]
    1bf0:	add    rsp,0x20
    1bf4:	mov    rsp,rbp
    1bf7:	pop    rbp
    1bf8:	ret
    1bf9:	mov    r12,rdi
    1bfc:	mov    rax,QWORD PTR [rip+0x0]        # 1c03 <botlish_fn_14+0xeb>
			1bff: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1c03:	call   rax
    1c05:	xor    rax,rax
    1c08:	mov    rbx,QWORD PTR [rsp]
    1c0c:	mov    r12,QWORD PTR [rsp+0x8]
    1c11:	mov    r13,QWORD PTR [rsp+0x10]
    1c16:	add    rsp,0x20
    1c1a:	mov    rsp,rbp
    1c1d:	pop    rbp
    1c1e:	ret

0000000000001c1f <botlish_entry_14: csv_parse<str>>:
    1c1f:	push   rbp
    1c20:	mov    rbp,rsp
    1c23:	mov    rsi,QWORD PTR [rdx]
    1c26:	call   1c2b <botlish_entry_14+0xc>
			1c27: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
    1c2b:	mov    rsp,rbp
    1c2e:	pop    rbp
    1c2f:	ret

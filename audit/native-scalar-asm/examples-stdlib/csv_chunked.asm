; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 14003  (per function: 176 85 372 997 997 997 997 808 728 852 852 501 558 698 913 482 821 828 517 556 268)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> chunk_size<generic>
;   botlish_fn_2 / botlish_entry_2 -> chunked_new<generic>
;   botlish_fn_3 / botlish_entry_3 -> chunked_append<list[list<never>, mutarray, int], str>
;   botlish_fn_4 / botlish_entry_4 -> chunked_append<list[list<mutarray>, mutarray, int], str>
;   botlish_fn_5 / botlish_entry_5 -> chunked_append<list[list<never>, mutarray, int], list>
;   botlish_fn_6 / botlish_entry_6 -> chunked_append<list[list<mutarray>, mutarray, int], list>
;   botlish_fn_7 / botlish_entry_7 -> chunked_copy_chunks<list<never>, int, mutarray, int>
;   botlish_fn_8 / botlish_entry_8 -> chunked_copy_chunks<list<mutarray>, int, mutarray, int>
;   botlish_fn_9 / botlish_entry_9 -> chunked_finish<list[list<never>, mutarray, int]>
;   botlish_fn_10 / botlish_entry_10 -> chunked_finish<list[list<mutarray>, mutarray, int]>
;   botlish_fn_11 / botlish_entry_11 -> peek<str, int>
;   botlish_fn_12 / botlish_entry_12 -> peek<str, int>
;   botlish_fn_13 / botlish_entry_13 -> scan_unquoted<str, int, int>
;   botlish_fn_14 / botlish_entry_14 -> scan_quoted<str, int, str>
;   botlish_fn_15 / botlish_entry_15 -> scan_field<str, int>
;   botlish_fn_16 / botlish_entry_16 -> scan_record<str, int, list[list<never>, mutarray, int]>
;   botlish_fn_17 / botlish_entry_17 -> scan_record<str, int, list[list<mutarray>, mutarray, int]>
;   botlish_fn_18 / botlish_entry_18 -> scan_records<str, int, list[list<never>, mutarray, int]>
;   botlish_fn_19 / botlish_entry_19 -> scan_records<str, int, list[list<mutarray>, mutarray, int]>
;   botlish_fn_20 / botlish_entry_20 -> csv_parse<str>


csv_chunked.asm.o:     file format elf64-x86-64


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
			41: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
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

00000000000000ad <botlish_fn_1: chunk_size<generic>>:
      ad:	push   rbp
      ae:	mov    rbp,rsp
      b1:	mov    r10,QWORD PTR [rdi]
      b4:	mov    r11,QWORD PTR [rdi+0x8]
      b8:	lea    rax,[r10+0x8]
      bc:	cmp    rax,r11
      bf:	ja     e0 <botlish_fn_1+0x33>
      c5:	lea    rax,[r10+0x8]
      c9:	mov    QWORD PTR [rdi],rax
      cc:	mov    QWORD PTR [r10],0x0
      d3:	mov    QWORD PTR [rdi],r10
      d6:	mov    eax,0x81
      db:	mov    rsp,rbp
      de:	pop    rbp
      df:	ret
      e0:	mov    rax,QWORD PTR [rip+0x0]        # e7 <botlish_fn_1+0x3a>
			e3: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
      e7:	call   rax
      e9:	xor    rax,rax
      ec:	mov    rsp,rbp
      ef:	pop    rbp
      f0:	ret

00000000000000f1 <botlish_entry_1: chunk_size<generic>>:
      f1:	push   rbp
      f2:	mov    rbp,rsp
      f5:	call   fa <botlish_entry_1+0x9>
			f6: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
      fa:	mov    rsp,rbp
      fd:	pop    rbp
      fe:	ret

00000000000000ff <botlish_fn_2: chunked_new<generic>>:
      ff:	push   rbp
     100:	mov    rbp,rsp
     103:	sub    rsp,0x40
     107:	mov    QWORD PTR [rsp+0x20],rbx
     10c:	mov    QWORD PTR [rsp+0x28],r12
     111:	mov    QWORD PTR [rsp+0x30],r13
     116:	mov    rbx,QWORD PTR [rdi]
     119:	mov    rax,QWORD PTR [rdi+0x8]
     11d:	lea    rcx,[rbx+0x18]
     121:	cmp    rcx,rax
     124:	ja     232 <botlish_fn_2+0x133>
     12a:	lea    rax,[rbx+0x18]
     12e:	mov    QWORD PTR [rdi],rax
     131:	mov    r12,rdi
     134:	mov    QWORD PTR [rbx],0x0
     13b:	mov    QWORD PTR [rbx+0x8],0x0
     143:	mov    QWORD PTR [rbx+0x10],0x0
     14b:	xor    rdx,rdx
     14e:	mov    rax,QWORD PTR [rip+0x0]        # 155 <botlish_fn_2+0x56>
			151: R_X86_64_GOTPCREL	rt_list_new-0x4
     155:	mov    rdi,r12
     158:	mov    rsi,rdx
     15b:	call   rax
     15d:	test   rax,rax
     160:	jne    16e <botlish_fn_2+0x6f>
     166:	mov    rdi,r12
     169:	jmp    1f3 <botlish_fn_2+0xf4>
     16e:	mov    QWORD PTR [rbx],rax
     171:	mov    r13,rax
     174:	mov    rdi,r12
     177:	call   17c <botlish_fn_2+0x7d>
			178: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     17c:	test   rax,rax
     17f:	jne    18d <botlish_fn_2+0x8e>
     185:	mov    rdi,r12
     188:	jmp    1f3 <botlish_fn_2+0xf4>
     18d:	mov    QWORD PTR [rbx+0x8],rax
     191:	mov    rsi,rax
     194:	mov    rax,QWORD PTR [rip+0x0]        # 19b <botlish_fn_2+0x9c>
			197: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     19b:	mov    rdi,r12
     19e:	call   rax
     1a0:	test   rax,rax
     1a3:	jne    1b1 <botlish_fn_2+0xb2>
     1a9:	mov    rdi,r12
     1ac:	jmp    1f3 <botlish_fn_2+0xf4>
     1b1:	mov    QWORD PTR [rbx+0x8],rax
     1b5:	mov    QWORD PTR [rbx+0x10],0x1
     1bd:	lea    rdx,[rsp]
     1c1:	mov    rcx,r13
     1c4:	mov    QWORD PTR [rsp],rcx
     1c8:	mov    QWORD PTR [rsp+0x8],rax
     1cd:	mov    QWORD PTR [rsp+0x10],0x1
     1d6:	mov    esi,0x3
     1db:	mov    rax,QWORD PTR [rip+0x0]        # 1e2 <botlish_fn_2+0xe3>
			1de: R_X86_64_GOTPCREL	rt_list_new-0x4
     1e2:	mov    rdi,r12
     1e5:	call   rax
     1e7:	test   rax,rax
     1ea:	jne    214 <botlish_fn_2+0x115>
     1f0:	mov    rdi,r12
     1f3:	mov    rdi,r12
     1f6:	mov    QWORD PTR [rdi],rbx
     1f9:	xor    rax,rax
     1fc:	mov    rbx,QWORD PTR [rsp+0x20]
     201:	mov    r12,QWORD PTR [rsp+0x28]
     206:	mov    r13,QWORD PTR [rsp+0x30]
     20b:	add    rsp,0x40
     20f:	mov    rsp,rbp
     212:	pop    rbp
     213:	ret
     214:	mov    rdi,r12
     217:	mov    QWORD PTR [rdi],rbx
     21a:	mov    rbx,QWORD PTR [rsp+0x20]
     21f:	mov    r12,QWORD PTR [rsp+0x28]
     224:	mov    r13,QWORD PTR [rsp+0x30]
     229:	add    rsp,0x40
     22d:	mov    rsp,rbp
     230:	pop    rbp
     231:	ret
     232:	mov    r12,rdi
     235:	mov    rax,QWORD PTR [rip+0x0]        # 23c <botlish_fn_2+0x13d>
			238: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     23c:	call   rax
     23e:	xor    rax,rax
     241:	mov    rbx,QWORD PTR [rsp+0x20]
     246:	mov    r12,QWORD PTR [rsp+0x28]
     24b:	mov    r13,QWORD PTR [rsp+0x30]
     250:	add    rsp,0x40
     254:	mov    rsp,rbp
     257:	pop    rbp
     258:	ret

0000000000000259 <botlish_entry_2: chunked_new<generic>>:
     259:	push   rbp
     25a:	mov    rbp,rsp
     25d:	call   262 <botlish_entry_2+0x9>
			25e: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
     262:	mov    rsp,rbp
     265:	pop    rbp
     266:	ret
	...

0000000000000268 <botlish_fn_3: chunked_append<list[list<never>, mutarray, int], str>>:
     268:	push   rbp
     269:	mov    rbp,rsp
     26c:	sub    rsp,0x70
     270:	mov    QWORD PTR [rsp+0x40],rbx
     275:	mov    QWORD PTR [rsp+0x48],r12
     27a:	mov    QWORD PTR [rsp+0x50],r13
     27f:	mov    QWORD PTR [rsp+0x58],r14
     284:	mov    QWORD PTR [rsp+0x60],r15
     289:	mov    QWORD PTR [rsp+0x30],rsi
     28e:	mov    r13,QWORD PTR [rdi]
     291:	mov    rax,QWORD PTR [rdi+0x8]
     295:	lea    rcx,[r13+0x20]
     299:	cmp    rcx,rax
     29c:	ja     5da <botlish_fn_3+0x372>
     2a2:	lea    rax,[r13+0x20]
     2a6:	mov    QWORD PTR [rdi],rax
     2a9:	mov    r14,rdi
     2ac:	mov    QWORD PTR [r13+0x0],0x0
     2b4:	mov    QWORD PTR [r13+0x8],0x0
     2bc:	mov    QWORD PTR [r13+0x10],0x0
     2c4:	mov    QWORD PTR [r13+0x18],0x0
     2cc:	mov    QWORD PTR [r13+0x0],rdx
     2d0:	mov    r15,rdx
     2d3:	mov    edx,0x1
     2d8:	mov    rcx,QWORD PTR [rip+0x0]        # 2df <botlish_fn_3+0x77>
			2db: R_X86_64_GOTPCREL	rt_list_get-0x4
     2df:	mov    rsi,QWORD PTR [rsp+0x30]
     2e4:	mov    rdi,r14
     2e7:	call   rcx
     2e9:	mov    rbx,rax
     2ec:	test   rbx,rbx
     2ef:	jne    2fd <botlish_fn_3+0x95>
     2f5:	mov    rdi,r14
     2f8:	jmp    587 <botlish_fn_3+0x31f>
     2fd:	mov    QWORD PTR [r13+0x8],rbx
     301:	mov    edx,0x3
     306:	mov    r8,QWORD PTR [rip+0x0]        # 30d <botlish_fn_3+0xa5>
			309: R_X86_64_GOTPCREL	rt_list_get-0x4
     30d:	mov    rsi,QWORD PTR [rsp+0x30]
     312:	mov    rdi,r14
     315:	call   r8
     318:	mov    r12,rax
     31b:	test   r12,r12
     31e:	jne    32c <botlish_fn_3+0xc4>
     324:	mov    rdi,r14
     327:	jmp    587 <botlish_fn_3+0x31f>
     32c:	mov    QWORD PTR [r13+0x10],r12
     330:	mov    edx,0x5
     335:	mov    r9,QWORD PTR [rip+0x0]        # 33c <botlish_fn_3+0xd4>
			338: R_X86_64_GOTPCREL	rt_list_get-0x4
     33c:	mov    rsi,QWORD PTR [rsp+0x30]
     341:	mov    rdi,r14
     344:	call   r9
     347:	mov    rcx,rax
     34a:	mov    QWORD PTR [rsp+0x30],rax
     34f:	test   rax,rcx
     352:	jne    360 <botlish_fn_3+0xf8>
     358:	mov    rdi,r14
     35b:	jmp    587 <botlish_fn_3+0x31f>
     360:	mov    rax,QWORD PTR [rsp+0x30]
     365:	mov    QWORD PTR [r13+0x18],rax
     369:	mov    rdi,r14
     36c:	call   371 <botlish_fn_3+0x109>
			36d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     371:	test   rax,rax
     374:	jne    382 <botlish_fn_3+0x11a>
     37a:	mov    rdi,r14
     37d:	jmp    587 <botlish_fn_3+0x31f>
     382:	mov    rcx,QWORD PTR [rsp+0x30]
     387:	and    rcx,rax
     38a:	mov    rdx,rax
     38d:	test   rcx,0x1
     394:	jne    3c0 <botlish_fn_3+0x158>
     39a:	mov    rax,QWORD PTR [rip+0x0]        # 3a1 <botlish_fn_3+0x139>
			39d: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     3a1:	mov    rsi,QWORD PTR [rsp+0x30]
     3a6:	mov    rdi,r14
     3a9:	call   rax
     3ab:	mov    ecx,0x2
     3b0:	test   rax,rax
     3b3:	cmove  rcx,QWORD PTR [rip+0x255]        # 610 <botlish_fn_3+0x3a8>
     3bb:	jmp    3d5 <botlish_fn_3+0x16d>
     3c0:	mov    ecx,0x2
     3c5:	mov    rax,QWORD PTR [rsp+0x30]
     3ca:	cmp    rax,rdx
     3cd:	cmove  rcx,QWORD PTR [rip+0x23b]        # 610 <botlish_fn_3+0x3a8>
     3d5:	cmp    rcx,0x6
     3d9:	je     4af <botlish_fn_3+0x247>
     3df:	mov    rax,QWORD PTR [rip+0x0]        # 3e6 <botlish_fn_3+0x17e>
			3e2: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     3e6:	mov    rcx,r15
     3e9:	mov    rdx,QWORD PTR [rsp+0x30]
     3ee:	mov    rsi,r12
     3f1:	mov    rdi,r14
     3f4:	call   rax
     3f6:	test   rax,rax
     3f9:	jne    407 <botlish_fn_3+0x19f>
     3ff:	mov    rdi,r14
     402:	jmp    587 <botlish_fn_3+0x31f>
     407:	mov    QWORD PTR [r13+0x0],0x3
     40f:	mov    rax,QWORD PTR [rsp+0x30]
     414:	test   rax,0x1
     41a:	je     437 <botlish_fn_3+0x1cf>
     420:	mov    rcx,QWORD PTR [rsp+0x30]
     425:	mov    rax,rcx
     428:	add    rax,0x2
     42c:	seto   cl
     42f:	test   cl,cl
     431:	je     44d <botlish_fn_3+0x1e5>
     437:	mov    edx,0x3
     43c:	mov    rax,QWORD PTR [rip+0x0]        # 443 <botlish_fn_3+0x1db>
			43f: R_X86_64_GOTPCREL	rt_int_add-0x4
     443:	mov    rsi,QWORD PTR [rsp+0x30]
     448:	mov    rdi,r14
     44b:	call   rax
     44d:	mov    QWORD PTR [r13+0x0],rax
     451:	lea    rdx,[rsp+0x18]
     456:	mov    QWORD PTR [rsp+0x18],rbx
     45b:	mov    QWORD PTR [rsp+0x20],r12
     460:	mov    QWORD PTR [rsp+0x28],rax
     465:	mov    esi,0x3
     46a:	mov    rax,QWORD PTR [rip+0x0]        # 471 <botlish_fn_3+0x209>
			46d: R_X86_64_GOTPCREL	rt_list_new-0x4
     471:	mov    rdi,r14
     474:	call   rax
     476:	test   rax,rax
     479:	jne    487 <botlish_fn_3+0x21f>
     47f:	mov    rdi,r14
     482:	jmp    587 <botlish_fn_3+0x31f>
     487:	mov    rdi,r14
     48a:	mov    QWORD PTR [rdi],r13
     48d:	mov    rbx,QWORD PTR [rsp+0x40]
     492:	mov    r12,QWORD PTR [rsp+0x48]
     497:	mov    r13,QWORD PTR [rsp+0x50]
     49c:	mov    r14,QWORD PTR [rsp+0x58]
     4a1:	mov    r15,QWORD PTR [rsp+0x60]
     4a6:	add    rsp,0x70
     4aa:	mov    rsp,rbp
     4ad:	pop    rbp
     4ae:	ret
     4af:	mov    rdx,r12
     4b2:	mov    rsi,rbx
     4b5:	mov    rax,QWORD PTR [rip+0x0]        # 4bc <botlish_fn_3+0x254>
			4b8: R_X86_64_GOTPCREL	rt_list_append-0x4
     4bc:	mov    rdi,r14
     4bf:	call   rax
     4c1:	test   rax,rax
     4c4:	jne    4d2 <botlish_fn_3+0x26a>
     4ca:	mov    rdi,r14
     4cd:	jmp    587 <botlish_fn_3+0x31f>
     4d2:	mov    QWORD PTR [r13+0x8],rax
     4d6:	mov    rbx,rax
     4d9:	mov    rdi,r14
     4dc:	call   4e1 <botlish_fn_3+0x279>
			4dd: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     4e1:	test   rax,rax
     4e4:	jne    4f2 <botlish_fn_3+0x28a>
     4ea:	mov    rdi,r14
     4ed:	jmp    587 <botlish_fn_3+0x31f>
     4f2:	mov    QWORD PTR [r13+0x10],rax
     4f6:	mov    rsi,rax
     4f9:	mov    rax,QWORD PTR [rip+0x0]        # 500 <botlish_fn_3+0x298>
			4fc: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     500:	mov    rdi,r14
     503:	call   rax
     505:	test   rax,rax
     508:	jne    516 <botlish_fn_3+0x2ae>
     50e:	mov    rdi,r14
     511:	jmp    587 <botlish_fn_3+0x31f>
     516:	mov    QWORD PTR [r13+0x0],rax
     51a:	mov    r12,rax
     51d:	mov    edx,0x1
     522:	mov    rax,QWORD PTR [rip+0x0]        # 529 <botlish_fn_3+0x2c1>
			525: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     529:	mov    rcx,r15
     52c:	mov    rsi,r12
     52f:	mov    rdi,r14
     532:	call   rax
     534:	test   rax,rax
     537:	jne    545 <botlish_fn_3+0x2dd>
     53d:	mov    rdi,r14
     540:	jmp    587 <botlish_fn_3+0x31f>
     545:	mov    esi,0x3
     54a:	mov    QWORD PTR [r13+0x10],0x3
     552:	lea    rdx,[rsp]
     556:	mov    rax,rbx
     559:	mov    QWORD PTR [rsp],rax
     55d:	mov    rax,r12
     560:	mov    QWORD PTR [rsp+0x8],rax
     565:	mov    QWORD PTR [rsp+0x10],0x3
     56e:	mov    r8,QWORD PTR [rip+0x0]        # 575 <botlish_fn_3+0x30d>
			571: R_X86_64_GOTPCREL	rt_list_new-0x4
     575:	mov    rdi,r14
     578:	call   r8
     57b:	test   rax,rax
     57e:	jne    5b2 <botlish_fn_3+0x34a>
     584:	mov    rdi,r14
     587:	mov    rdi,r14
     58a:	mov    QWORD PTR [rdi],r13
     58d:	xor    rax,rax
     590:	mov    rbx,QWORD PTR [rsp+0x40]
     595:	mov    r12,QWORD PTR [rsp+0x48]
     59a:	mov    r13,QWORD PTR [rsp+0x50]
     59f:	mov    r14,QWORD PTR [rsp+0x58]
     5a4:	mov    r15,QWORD PTR [rsp+0x60]
     5a9:	add    rsp,0x70
     5ad:	mov    rsp,rbp
     5b0:	pop    rbp
     5b1:	ret
     5b2:	mov    rdi,r14
     5b5:	mov    QWORD PTR [rdi],r13
     5b8:	mov    rbx,QWORD PTR [rsp+0x40]
     5bd:	mov    r12,QWORD PTR [rsp+0x48]
     5c2:	mov    r13,QWORD PTR [rsp+0x50]
     5c7:	mov    r14,QWORD PTR [rsp+0x58]
     5cc:	mov    r15,QWORD PTR [rsp+0x60]
     5d1:	add    rsp,0x70
     5d5:	mov    rsp,rbp
     5d8:	pop    rbp
     5d9:	ret
     5da:	mov    r14,rdi
     5dd:	mov    r9,QWORD PTR [rip+0x0]        # 5e4 <botlish_fn_3+0x37c>
			5e0: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     5e4:	call   r9
     5e7:	xor    rax,rax
     5ea:	mov    rbx,QWORD PTR [rsp+0x40]
     5ef:	mov    r12,QWORD PTR [rsp+0x48]
     5f4:	mov    r13,QWORD PTR [rsp+0x50]
     5f9:	mov    r14,QWORD PTR [rsp+0x58]
     5fe:	mov    r15,QWORD PTR [rsp+0x60]
     603:	add    rsp,0x70
     607:	mov    rsp,rbp
     60a:	pop    rbp
     60b:	ret
     60c:	add    BYTE PTR [rax],al
     60e:	add    BYTE PTR [rax],al
     610:	(bad)
     611:	add    BYTE PTR [rax],al
     613:	add    BYTE PTR [rax],al
     615:	add    BYTE PTR [rax],al
	...

0000000000000618 <botlish_entry_3: chunked_append<list[list<never>, mutarray, int], str>>:
     618:	push   rbp
     619:	mov    rbp,rsp
     61c:	mov    rsi,QWORD PTR [rdx]
     61f:	mov    rdx,QWORD PTR [rdx+0x8]
     623:	call   628 <botlish_entry_3+0x10>
			624: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[list<never>, mutarray, int], str>
     628:	mov    rsp,rbp
     62b:	pop    rbp
     62c:	ret
     62d:	add    BYTE PTR [rax],al
	...

0000000000000630 <botlish_fn_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     630:	push   rbp
     631:	mov    rbp,rsp
     634:	sub    rsp,0x70
     638:	mov    QWORD PTR [rsp+0x40],rbx
     63d:	mov    QWORD PTR [rsp+0x48],r12
     642:	mov    QWORD PTR [rsp+0x50],r13
     647:	mov    QWORD PTR [rsp+0x58],r14
     64c:	mov    QWORD PTR [rsp+0x60],r15
     651:	mov    QWORD PTR [rsp+0x30],rsi
     656:	mov    r13,QWORD PTR [rdi]
     659:	mov    rax,QWORD PTR [rdi+0x8]
     65d:	lea    rcx,[r13+0x20]
     661:	cmp    rcx,rax
     664:	ja     9a2 <botlish_fn_4+0x372>
     66a:	lea    rax,[r13+0x20]
     66e:	mov    QWORD PTR [rdi],rax
     671:	mov    r14,rdi
     674:	mov    QWORD PTR [r13+0x0],0x0
     67c:	mov    QWORD PTR [r13+0x8],0x0
     684:	mov    QWORD PTR [r13+0x10],0x0
     68c:	mov    QWORD PTR [r13+0x18],0x0
     694:	mov    QWORD PTR [r13+0x0],rdx
     698:	mov    r15,rdx
     69b:	mov    edx,0x1
     6a0:	mov    rcx,QWORD PTR [rip+0x0]        # 6a7 <botlish_fn_4+0x77>
			6a3: R_X86_64_GOTPCREL	rt_list_get-0x4
     6a7:	mov    rsi,QWORD PTR [rsp+0x30]
     6ac:	mov    rdi,r14
     6af:	call   rcx
     6b1:	mov    rbx,rax
     6b4:	test   rbx,rbx
     6b7:	jne    6c5 <botlish_fn_4+0x95>
     6bd:	mov    rdi,r14
     6c0:	jmp    94f <botlish_fn_4+0x31f>
     6c5:	mov    QWORD PTR [r13+0x8],rbx
     6c9:	mov    edx,0x3
     6ce:	mov    r8,QWORD PTR [rip+0x0]        # 6d5 <botlish_fn_4+0xa5>
			6d1: R_X86_64_GOTPCREL	rt_list_get-0x4
     6d5:	mov    rsi,QWORD PTR [rsp+0x30]
     6da:	mov    rdi,r14
     6dd:	call   r8
     6e0:	mov    r12,rax
     6e3:	test   r12,r12
     6e6:	jne    6f4 <botlish_fn_4+0xc4>
     6ec:	mov    rdi,r14
     6ef:	jmp    94f <botlish_fn_4+0x31f>
     6f4:	mov    QWORD PTR [r13+0x10],r12
     6f8:	mov    edx,0x5
     6fd:	mov    r9,QWORD PTR [rip+0x0]        # 704 <botlish_fn_4+0xd4>
			700: R_X86_64_GOTPCREL	rt_list_get-0x4
     704:	mov    rsi,QWORD PTR [rsp+0x30]
     709:	mov    rdi,r14
     70c:	call   r9
     70f:	mov    rcx,rax
     712:	mov    QWORD PTR [rsp+0x30],rax
     717:	test   rax,rcx
     71a:	jne    728 <botlish_fn_4+0xf8>
     720:	mov    rdi,r14
     723:	jmp    94f <botlish_fn_4+0x31f>
     728:	mov    rax,QWORD PTR [rsp+0x30]
     72d:	mov    QWORD PTR [r13+0x18],rax
     731:	mov    rdi,r14
     734:	call   739 <botlish_fn_4+0x109>
			735: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     739:	test   rax,rax
     73c:	jne    74a <botlish_fn_4+0x11a>
     742:	mov    rdi,r14
     745:	jmp    94f <botlish_fn_4+0x31f>
     74a:	mov    rcx,QWORD PTR [rsp+0x30]
     74f:	and    rcx,rax
     752:	mov    rdx,rax
     755:	test   rcx,0x1
     75c:	jne    788 <botlish_fn_4+0x158>
     762:	mov    rax,QWORD PTR [rip+0x0]        # 769 <botlish_fn_4+0x139>
			765: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     769:	mov    rsi,QWORD PTR [rsp+0x30]
     76e:	mov    rdi,r14
     771:	call   rax
     773:	mov    ecx,0x2
     778:	test   rax,rax
     77b:	cmove  rcx,QWORD PTR [rip+0x255]        # 9d8 <botlish_fn_4+0x3a8>
     783:	jmp    79d <botlish_fn_4+0x16d>
     788:	mov    ecx,0x2
     78d:	mov    rax,QWORD PTR [rsp+0x30]
     792:	cmp    rax,rdx
     795:	cmove  rcx,QWORD PTR [rip+0x23b]        # 9d8 <botlish_fn_4+0x3a8>
     79d:	cmp    rcx,0x6
     7a1:	je     877 <botlish_fn_4+0x247>
     7a7:	mov    rax,QWORD PTR [rip+0x0]        # 7ae <botlish_fn_4+0x17e>
			7aa: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     7ae:	mov    rcx,r15
     7b1:	mov    rdx,QWORD PTR [rsp+0x30]
     7b6:	mov    rsi,r12
     7b9:	mov    rdi,r14
     7bc:	call   rax
     7be:	test   rax,rax
     7c1:	jne    7cf <botlish_fn_4+0x19f>
     7c7:	mov    rdi,r14
     7ca:	jmp    94f <botlish_fn_4+0x31f>
     7cf:	mov    QWORD PTR [r13+0x0],0x3
     7d7:	mov    rax,QWORD PTR [rsp+0x30]
     7dc:	test   rax,0x1
     7e2:	je     7ff <botlish_fn_4+0x1cf>
     7e8:	mov    rcx,QWORD PTR [rsp+0x30]
     7ed:	mov    rax,rcx
     7f0:	add    rax,0x2
     7f4:	seto   cl
     7f7:	test   cl,cl
     7f9:	je     815 <botlish_fn_4+0x1e5>
     7ff:	mov    edx,0x3
     804:	mov    rax,QWORD PTR [rip+0x0]        # 80b <botlish_fn_4+0x1db>
			807: R_X86_64_GOTPCREL	rt_int_add-0x4
     80b:	mov    rsi,QWORD PTR [rsp+0x30]
     810:	mov    rdi,r14
     813:	call   rax
     815:	mov    QWORD PTR [r13+0x0],rax
     819:	lea    rdx,[rsp+0x18]
     81e:	mov    QWORD PTR [rsp+0x18],rbx
     823:	mov    QWORD PTR [rsp+0x20],r12
     828:	mov    QWORD PTR [rsp+0x28],rax
     82d:	mov    esi,0x3
     832:	mov    rax,QWORD PTR [rip+0x0]        # 839 <botlish_fn_4+0x209>
			835: R_X86_64_GOTPCREL	rt_list_new-0x4
     839:	mov    rdi,r14
     83c:	call   rax
     83e:	test   rax,rax
     841:	jne    84f <botlish_fn_4+0x21f>
     847:	mov    rdi,r14
     84a:	jmp    94f <botlish_fn_4+0x31f>
     84f:	mov    rdi,r14
     852:	mov    QWORD PTR [rdi],r13
     855:	mov    rbx,QWORD PTR [rsp+0x40]
     85a:	mov    r12,QWORD PTR [rsp+0x48]
     85f:	mov    r13,QWORD PTR [rsp+0x50]
     864:	mov    r14,QWORD PTR [rsp+0x58]
     869:	mov    r15,QWORD PTR [rsp+0x60]
     86e:	add    rsp,0x70
     872:	mov    rsp,rbp
     875:	pop    rbp
     876:	ret
     877:	mov    rdx,r12
     87a:	mov    rsi,rbx
     87d:	mov    rax,QWORD PTR [rip+0x0]        # 884 <botlish_fn_4+0x254>
			880: R_X86_64_GOTPCREL	rt_list_append-0x4
     884:	mov    rdi,r14
     887:	call   rax
     889:	test   rax,rax
     88c:	jne    89a <botlish_fn_4+0x26a>
     892:	mov    rdi,r14
     895:	jmp    94f <botlish_fn_4+0x31f>
     89a:	mov    QWORD PTR [r13+0x8],rax
     89e:	mov    rbx,rax
     8a1:	mov    rdi,r14
     8a4:	call   8a9 <botlish_fn_4+0x279>
			8a5: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     8a9:	test   rax,rax
     8ac:	jne    8ba <botlish_fn_4+0x28a>
     8b2:	mov    rdi,r14
     8b5:	jmp    94f <botlish_fn_4+0x31f>
     8ba:	mov    QWORD PTR [r13+0x10],rax
     8be:	mov    rsi,rax
     8c1:	mov    rax,QWORD PTR [rip+0x0]        # 8c8 <botlish_fn_4+0x298>
			8c4: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     8c8:	mov    rdi,r14
     8cb:	call   rax
     8cd:	test   rax,rax
     8d0:	jne    8de <botlish_fn_4+0x2ae>
     8d6:	mov    rdi,r14
     8d9:	jmp    94f <botlish_fn_4+0x31f>
     8de:	mov    QWORD PTR [r13+0x0],rax
     8e2:	mov    r12,rax
     8e5:	mov    edx,0x1
     8ea:	mov    rax,QWORD PTR [rip+0x0]        # 8f1 <botlish_fn_4+0x2c1>
			8ed: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     8f1:	mov    rcx,r15
     8f4:	mov    rsi,r12
     8f7:	mov    rdi,r14
     8fa:	call   rax
     8fc:	test   rax,rax
     8ff:	jne    90d <botlish_fn_4+0x2dd>
     905:	mov    rdi,r14
     908:	jmp    94f <botlish_fn_4+0x31f>
     90d:	mov    esi,0x3
     912:	mov    QWORD PTR [r13+0x10],0x3
     91a:	lea    rdx,[rsp]
     91e:	mov    rax,rbx
     921:	mov    QWORD PTR [rsp],rax
     925:	mov    rax,r12
     928:	mov    QWORD PTR [rsp+0x8],rax
     92d:	mov    QWORD PTR [rsp+0x10],0x3
     936:	mov    r8,QWORD PTR [rip+0x0]        # 93d <botlish_fn_4+0x30d>
			939: R_X86_64_GOTPCREL	rt_list_new-0x4
     93d:	mov    rdi,r14
     940:	call   r8
     943:	test   rax,rax
     946:	jne    97a <botlish_fn_4+0x34a>
     94c:	mov    rdi,r14
     94f:	mov    rdi,r14
     952:	mov    QWORD PTR [rdi],r13
     955:	xor    rax,rax
     958:	mov    rbx,QWORD PTR [rsp+0x40]
     95d:	mov    r12,QWORD PTR [rsp+0x48]
     962:	mov    r13,QWORD PTR [rsp+0x50]
     967:	mov    r14,QWORD PTR [rsp+0x58]
     96c:	mov    r15,QWORD PTR [rsp+0x60]
     971:	add    rsp,0x70
     975:	mov    rsp,rbp
     978:	pop    rbp
     979:	ret
     97a:	mov    rdi,r14
     97d:	mov    QWORD PTR [rdi],r13
     980:	mov    rbx,QWORD PTR [rsp+0x40]
     985:	mov    r12,QWORD PTR [rsp+0x48]
     98a:	mov    r13,QWORD PTR [rsp+0x50]
     98f:	mov    r14,QWORD PTR [rsp+0x58]
     994:	mov    r15,QWORD PTR [rsp+0x60]
     999:	add    rsp,0x70
     99d:	mov    rsp,rbp
     9a0:	pop    rbp
     9a1:	ret
     9a2:	mov    r14,rdi
     9a5:	mov    r9,QWORD PTR [rip+0x0]        # 9ac <botlish_fn_4+0x37c>
			9a8: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     9ac:	call   r9
     9af:	xor    rax,rax
     9b2:	mov    rbx,QWORD PTR [rsp+0x40]
     9b7:	mov    r12,QWORD PTR [rsp+0x48]
     9bc:	mov    r13,QWORD PTR [rsp+0x50]
     9c1:	mov    r14,QWORD PTR [rsp+0x58]
     9c6:	mov    r15,QWORD PTR [rsp+0x60]
     9cb:	add    rsp,0x70
     9cf:	mov    rsp,rbp
     9d2:	pop    rbp
     9d3:	ret
     9d4:	add    BYTE PTR [rax],al
     9d6:	add    BYTE PTR [rax],al
     9d8:	(bad)
     9d9:	add    BYTE PTR [rax],al
     9db:	add    BYTE PTR [rax],al
     9dd:	add    BYTE PTR [rax],al
	...

00000000000009e0 <botlish_entry_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     9e0:	push   rbp
     9e1:	mov    rbp,rsp
     9e4:	mov    rsi,QWORD PTR [rdx]
     9e7:	mov    rdx,QWORD PTR [rdx+0x8]
     9eb:	call   9f0 <botlish_entry_4+0x10>
			9ec: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], str>
     9f0:	mov    rsp,rbp
     9f3:	pop    rbp
     9f4:	ret
     9f5:	add    BYTE PTR [rax],al
	...

00000000000009f8 <botlish_fn_5: chunked_append<list[list<never>, mutarray, int], list>>:
     9f8:	push   rbp
     9f9:	mov    rbp,rsp
     9fc:	sub    rsp,0x70
     a00:	mov    QWORD PTR [rsp+0x40],rbx
     a05:	mov    QWORD PTR [rsp+0x48],r12
     a0a:	mov    QWORD PTR [rsp+0x50],r13
     a0f:	mov    QWORD PTR [rsp+0x58],r14
     a14:	mov    QWORD PTR [rsp+0x60],r15
     a19:	mov    QWORD PTR [rsp+0x30],rsi
     a1e:	mov    r13,QWORD PTR [rdi]
     a21:	mov    rax,QWORD PTR [rdi+0x8]
     a25:	lea    rcx,[r13+0x20]
     a29:	cmp    rcx,rax
     a2c:	ja     d6a <botlish_fn_5+0x372>
     a32:	lea    rax,[r13+0x20]
     a36:	mov    QWORD PTR [rdi],rax
     a39:	mov    r14,rdi
     a3c:	mov    QWORD PTR [r13+0x0],0x0
     a44:	mov    QWORD PTR [r13+0x8],0x0
     a4c:	mov    QWORD PTR [r13+0x10],0x0
     a54:	mov    QWORD PTR [r13+0x18],0x0
     a5c:	mov    QWORD PTR [r13+0x0],rdx
     a60:	mov    r15,rdx
     a63:	mov    edx,0x1
     a68:	mov    rcx,QWORD PTR [rip+0x0]        # a6f <botlish_fn_5+0x77>
			a6b: R_X86_64_GOTPCREL	rt_list_get-0x4
     a6f:	mov    rsi,QWORD PTR [rsp+0x30]
     a74:	mov    rdi,r14
     a77:	call   rcx
     a79:	mov    rbx,rax
     a7c:	test   rbx,rbx
     a7f:	jne    a8d <botlish_fn_5+0x95>
     a85:	mov    rdi,r14
     a88:	jmp    d17 <botlish_fn_5+0x31f>
     a8d:	mov    QWORD PTR [r13+0x8],rbx
     a91:	mov    edx,0x3
     a96:	mov    r8,QWORD PTR [rip+0x0]        # a9d <botlish_fn_5+0xa5>
			a99: R_X86_64_GOTPCREL	rt_list_get-0x4
     a9d:	mov    rsi,QWORD PTR [rsp+0x30]
     aa2:	mov    rdi,r14
     aa5:	call   r8
     aa8:	mov    r12,rax
     aab:	test   r12,r12
     aae:	jne    abc <botlish_fn_5+0xc4>
     ab4:	mov    rdi,r14
     ab7:	jmp    d17 <botlish_fn_5+0x31f>
     abc:	mov    QWORD PTR [r13+0x10],r12
     ac0:	mov    edx,0x5
     ac5:	mov    r9,QWORD PTR [rip+0x0]        # acc <botlish_fn_5+0xd4>
			ac8: R_X86_64_GOTPCREL	rt_list_get-0x4
     acc:	mov    rsi,QWORD PTR [rsp+0x30]
     ad1:	mov    rdi,r14
     ad4:	call   r9
     ad7:	mov    rcx,rax
     ada:	mov    QWORD PTR [rsp+0x30],rax
     adf:	test   rax,rcx
     ae2:	jne    af0 <botlish_fn_5+0xf8>
     ae8:	mov    rdi,r14
     aeb:	jmp    d17 <botlish_fn_5+0x31f>
     af0:	mov    rax,QWORD PTR [rsp+0x30]
     af5:	mov    QWORD PTR [r13+0x18],rax
     af9:	mov    rdi,r14
     afc:	call   b01 <botlish_fn_5+0x109>
			afd: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     b01:	test   rax,rax
     b04:	jne    b12 <botlish_fn_5+0x11a>
     b0a:	mov    rdi,r14
     b0d:	jmp    d17 <botlish_fn_5+0x31f>
     b12:	mov    rcx,QWORD PTR [rsp+0x30]
     b17:	and    rcx,rax
     b1a:	mov    rdx,rax
     b1d:	test   rcx,0x1
     b24:	jne    b50 <botlish_fn_5+0x158>
     b2a:	mov    rax,QWORD PTR [rip+0x0]        # b31 <botlish_fn_5+0x139>
			b2d: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     b31:	mov    rsi,QWORD PTR [rsp+0x30]
     b36:	mov    rdi,r14
     b39:	call   rax
     b3b:	mov    ecx,0x2
     b40:	test   rax,rax
     b43:	cmove  rcx,QWORD PTR [rip+0x255]        # da0 <botlish_fn_5+0x3a8>
     b4b:	jmp    b65 <botlish_fn_5+0x16d>
     b50:	mov    ecx,0x2
     b55:	mov    rax,QWORD PTR [rsp+0x30]
     b5a:	cmp    rax,rdx
     b5d:	cmove  rcx,QWORD PTR [rip+0x23b]        # da0 <botlish_fn_5+0x3a8>
     b65:	cmp    rcx,0x6
     b69:	je     c3f <botlish_fn_5+0x247>
     b6f:	mov    rax,QWORD PTR [rip+0x0]        # b76 <botlish_fn_5+0x17e>
			b72: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     b76:	mov    rcx,r15
     b79:	mov    rdx,QWORD PTR [rsp+0x30]
     b7e:	mov    rsi,r12
     b81:	mov    rdi,r14
     b84:	call   rax
     b86:	test   rax,rax
     b89:	jne    b97 <botlish_fn_5+0x19f>
     b8f:	mov    rdi,r14
     b92:	jmp    d17 <botlish_fn_5+0x31f>
     b97:	mov    QWORD PTR [r13+0x0],0x3
     b9f:	mov    rax,QWORD PTR [rsp+0x30]
     ba4:	test   rax,0x1
     baa:	je     bc7 <botlish_fn_5+0x1cf>
     bb0:	mov    rcx,QWORD PTR [rsp+0x30]
     bb5:	mov    rax,rcx
     bb8:	add    rax,0x2
     bbc:	seto   cl
     bbf:	test   cl,cl
     bc1:	je     bdd <botlish_fn_5+0x1e5>
     bc7:	mov    edx,0x3
     bcc:	mov    rax,QWORD PTR [rip+0x0]        # bd3 <botlish_fn_5+0x1db>
			bcf: R_X86_64_GOTPCREL	rt_int_add-0x4
     bd3:	mov    rsi,QWORD PTR [rsp+0x30]
     bd8:	mov    rdi,r14
     bdb:	call   rax
     bdd:	mov    QWORD PTR [r13+0x0],rax
     be1:	lea    rdx,[rsp+0x18]
     be6:	mov    QWORD PTR [rsp+0x18],rbx
     beb:	mov    QWORD PTR [rsp+0x20],r12
     bf0:	mov    QWORD PTR [rsp+0x28],rax
     bf5:	mov    esi,0x3
     bfa:	mov    rax,QWORD PTR [rip+0x0]        # c01 <botlish_fn_5+0x209>
			bfd: R_X86_64_GOTPCREL	rt_list_new-0x4
     c01:	mov    rdi,r14
     c04:	call   rax
     c06:	test   rax,rax
     c09:	jne    c17 <botlish_fn_5+0x21f>
     c0f:	mov    rdi,r14
     c12:	jmp    d17 <botlish_fn_5+0x31f>
     c17:	mov    rdi,r14
     c1a:	mov    QWORD PTR [rdi],r13
     c1d:	mov    rbx,QWORD PTR [rsp+0x40]
     c22:	mov    r12,QWORD PTR [rsp+0x48]
     c27:	mov    r13,QWORD PTR [rsp+0x50]
     c2c:	mov    r14,QWORD PTR [rsp+0x58]
     c31:	mov    r15,QWORD PTR [rsp+0x60]
     c36:	add    rsp,0x70
     c3a:	mov    rsp,rbp
     c3d:	pop    rbp
     c3e:	ret
     c3f:	mov    rdx,r12
     c42:	mov    rsi,rbx
     c45:	mov    rax,QWORD PTR [rip+0x0]        # c4c <botlish_fn_5+0x254>
			c48: R_X86_64_GOTPCREL	rt_list_append-0x4
     c4c:	mov    rdi,r14
     c4f:	call   rax
     c51:	test   rax,rax
     c54:	jne    c62 <botlish_fn_5+0x26a>
     c5a:	mov    rdi,r14
     c5d:	jmp    d17 <botlish_fn_5+0x31f>
     c62:	mov    QWORD PTR [r13+0x8],rax
     c66:	mov    rbx,rax
     c69:	mov    rdi,r14
     c6c:	call   c71 <botlish_fn_5+0x279>
			c6d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     c71:	test   rax,rax
     c74:	jne    c82 <botlish_fn_5+0x28a>
     c7a:	mov    rdi,r14
     c7d:	jmp    d17 <botlish_fn_5+0x31f>
     c82:	mov    QWORD PTR [r13+0x10],rax
     c86:	mov    rsi,rax
     c89:	mov    rax,QWORD PTR [rip+0x0]        # c90 <botlish_fn_5+0x298>
			c8c: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     c90:	mov    rdi,r14
     c93:	call   rax
     c95:	test   rax,rax
     c98:	jne    ca6 <botlish_fn_5+0x2ae>
     c9e:	mov    rdi,r14
     ca1:	jmp    d17 <botlish_fn_5+0x31f>
     ca6:	mov    QWORD PTR [r13+0x0],rax
     caa:	mov    r12,rax
     cad:	mov    edx,0x1
     cb2:	mov    rax,QWORD PTR [rip+0x0]        # cb9 <botlish_fn_5+0x2c1>
			cb5: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     cb9:	mov    rcx,r15
     cbc:	mov    rsi,r12
     cbf:	mov    rdi,r14
     cc2:	call   rax
     cc4:	test   rax,rax
     cc7:	jne    cd5 <botlish_fn_5+0x2dd>
     ccd:	mov    rdi,r14
     cd0:	jmp    d17 <botlish_fn_5+0x31f>
     cd5:	mov    esi,0x3
     cda:	mov    QWORD PTR [r13+0x10],0x3
     ce2:	lea    rdx,[rsp]
     ce6:	mov    rax,rbx
     ce9:	mov    QWORD PTR [rsp],rax
     ced:	mov    rax,r12
     cf0:	mov    QWORD PTR [rsp+0x8],rax
     cf5:	mov    QWORD PTR [rsp+0x10],0x3
     cfe:	mov    r8,QWORD PTR [rip+0x0]        # d05 <botlish_fn_5+0x30d>
			d01: R_X86_64_GOTPCREL	rt_list_new-0x4
     d05:	mov    rdi,r14
     d08:	call   r8
     d0b:	test   rax,rax
     d0e:	jne    d42 <botlish_fn_5+0x34a>
     d14:	mov    rdi,r14
     d17:	mov    rdi,r14
     d1a:	mov    QWORD PTR [rdi],r13
     d1d:	xor    rax,rax
     d20:	mov    rbx,QWORD PTR [rsp+0x40]
     d25:	mov    r12,QWORD PTR [rsp+0x48]
     d2a:	mov    r13,QWORD PTR [rsp+0x50]
     d2f:	mov    r14,QWORD PTR [rsp+0x58]
     d34:	mov    r15,QWORD PTR [rsp+0x60]
     d39:	add    rsp,0x70
     d3d:	mov    rsp,rbp
     d40:	pop    rbp
     d41:	ret
     d42:	mov    rdi,r14
     d45:	mov    QWORD PTR [rdi],r13
     d48:	mov    rbx,QWORD PTR [rsp+0x40]
     d4d:	mov    r12,QWORD PTR [rsp+0x48]
     d52:	mov    r13,QWORD PTR [rsp+0x50]
     d57:	mov    r14,QWORD PTR [rsp+0x58]
     d5c:	mov    r15,QWORD PTR [rsp+0x60]
     d61:	add    rsp,0x70
     d65:	mov    rsp,rbp
     d68:	pop    rbp
     d69:	ret
     d6a:	mov    r14,rdi
     d6d:	mov    r9,QWORD PTR [rip+0x0]        # d74 <botlish_fn_5+0x37c>
			d70: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     d74:	call   r9
     d77:	xor    rax,rax
     d7a:	mov    rbx,QWORD PTR [rsp+0x40]
     d7f:	mov    r12,QWORD PTR [rsp+0x48]
     d84:	mov    r13,QWORD PTR [rsp+0x50]
     d89:	mov    r14,QWORD PTR [rsp+0x58]
     d8e:	mov    r15,QWORD PTR [rsp+0x60]
     d93:	add    rsp,0x70
     d97:	mov    rsp,rbp
     d9a:	pop    rbp
     d9b:	ret
     d9c:	add    BYTE PTR [rax],al
     d9e:	add    BYTE PTR [rax],al
     da0:	(bad)
     da1:	add    BYTE PTR [rax],al
     da3:	add    BYTE PTR [rax],al
     da5:	add    BYTE PTR [rax],al
	...

0000000000000da8 <botlish_entry_5: chunked_append<list[list<never>, mutarray, int], list>>:
     da8:	push   rbp
     da9:	mov    rbp,rsp
     dac:	mov    rsi,QWORD PTR [rdx]
     daf:	mov    rdx,QWORD PTR [rdx+0x8]
     db3:	call   db8 <botlish_entry_5+0x10>
			db4: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[list<never>, mutarray, int], list>
     db8:	mov    rsp,rbp
     dbb:	pop    rbp
     dbc:	ret
     dbd:	add    BYTE PTR [rax],al
	...

0000000000000dc0 <botlish_fn_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     dc0:	push   rbp
     dc1:	mov    rbp,rsp
     dc4:	sub    rsp,0x70
     dc8:	mov    QWORD PTR [rsp+0x40],rbx
     dcd:	mov    QWORD PTR [rsp+0x48],r12
     dd2:	mov    QWORD PTR [rsp+0x50],r13
     dd7:	mov    QWORD PTR [rsp+0x58],r14
     ddc:	mov    QWORD PTR [rsp+0x60],r15
     de1:	mov    QWORD PTR [rsp+0x30],rsi
     de6:	mov    r13,QWORD PTR [rdi]
     de9:	mov    rax,QWORD PTR [rdi+0x8]
     ded:	lea    rcx,[r13+0x20]
     df1:	cmp    rcx,rax
     df4:	ja     1132 <botlish_fn_6+0x372>
     dfa:	lea    rax,[r13+0x20]
     dfe:	mov    QWORD PTR [rdi],rax
     e01:	mov    r14,rdi
     e04:	mov    QWORD PTR [r13+0x0],0x0
     e0c:	mov    QWORD PTR [r13+0x8],0x0
     e14:	mov    QWORD PTR [r13+0x10],0x0
     e1c:	mov    QWORD PTR [r13+0x18],0x0
     e24:	mov    QWORD PTR [r13+0x0],rdx
     e28:	mov    r15,rdx
     e2b:	mov    edx,0x1
     e30:	mov    rcx,QWORD PTR [rip+0x0]        # e37 <botlish_fn_6+0x77>
			e33: R_X86_64_GOTPCREL	rt_list_get-0x4
     e37:	mov    rsi,QWORD PTR [rsp+0x30]
     e3c:	mov    rdi,r14
     e3f:	call   rcx
     e41:	mov    rbx,rax
     e44:	test   rbx,rbx
     e47:	jne    e55 <botlish_fn_6+0x95>
     e4d:	mov    rdi,r14
     e50:	jmp    10df <botlish_fn_6+0x31f>
     e55:	mov    QWORD PTR [r13+0x8],rbx
     e59:	mov    edx,0x3
     e5e:	mov    r8,QWORD PTR [rip+0x0]        # e65 <botlish_fn_6+0xa5>
			e61: R_X86_64_GOTPCREL	rt_list_get-0x4
     e65:	mov    rsi,QWORD PTR [rsp+0x30]
     e6a:	mov    rdi,r14
     e6d:	call   r8
     e70:	mov    r12,rax
     e73:	test   r12,r12
     e76:	jne    e84 <botlish_fn_6+0xc4>
     e7c:	mov    rdi,r14
     e7f:	jmp    10df <botlish_fn_6+0x31f>
     e84:	mov    QWORD PTR [r13+0x10],r12
     e88:	mov    edx,0x5
     e8d:	mov    r9,QWORD PTR [rip+0x0]        # e94 <botlish_fn_6+0xd4>
			e90: R_X86_64_GOTPCREL	rt_list_get-0x4
     e94:	mov    rsi,QWORD PTR [rsp+0x30]
     e99:	mov    rdi,r14
     e9c:	call   r9
     e9f:	mov    rcx,rax
     ea2:	mov    QWORD PTR [rsp+0x30],rax
     ea7:	test   rax,rcx
     eaa:	jne    eb8 <botlish_fn_6+0xf8>
     eb0:	mov    rdi,r14
     eb3:	jmp    10df <botlish_fn_6+0x31f>
     eb8:	mov    rax,QWORD PTR [rsp+0x30]
     ebd:	mov    QWORD PTR [r13+0x18],rax
     ec1:	mov    rdi,r14
     ec4:	call   ec9 <botlish_fn_6+0x109>
			ec5: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     ec9:	test   rax,rax
     ecc:	jne    eda <botlish_fn_6+0x11a>
     ed2:	mov    rdi,r14
     ed5:	jmp    10df <botlish_fn_6+0x31f>
     eda:	mov    rcx,QWORD PTR [rsp+0x30]
     edf:	and    rcx,rax
     ee2:	mov    rdx,rax
     ee5:	test   rcx,0x1
     eec:	jne    f18 <botlish_fn_6+0x158>
     ef2:	mov    rax,QWORD PTR [rip+0x0]        # ef9 <botlish_fn_6+0x139>
			ef5: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     ef9:	mov    rsi,QWORD PTR [rsp+0x30]
     efe:	mov    rdi,r14
     f01:	call   rax
     f03:	mov    ecx,0x2
     f08:	test   rax,rax
     f0b:	cmove  rcx,QWORD PTR [rip+0x255]        # 1168 <botlish_fn_6+0x3a8>
     f13:	jmp    f2d <botlish_fn_6+0x16d>
     f18:	mov    ecx,0x2
     f1d:	mov    rax,QWORD PTR [rsp+0x30]
     f22:	cmp    rax,rdx
     f25:	cmove  rcx,QWORD PTR [rip+0x23b]        # 1168 <botlish_fn_6+0x3a8>
     f2d:	cmp    rcx,0x6
     f31:	je     1007 <botlish_fn_6+0x247>
     f37:	mov    rax,QWORD PTR [rip+0x0]        # f3e <botlish_fn_6+0x17e>
			f3a: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     f3e:	mov    rcx,r15
     f41:	mov    rdx,QWORD PTR [rsp+0x30]
     f46:	mov    rsi,r12
     f49:	mov    rdi,r14
     f4c:	call   rax
     f4e:	test   rax,rax
     f51:	jne    f5f <botlish_fn_6+0x19f>
     f57:	mov    rdi,r14
     f5a:	jmp    10df <botlish_fn_6+0x31f>
     f5f:	mov    QWORD PTR [r13+0x0],0x3
     f67:	mov    rax,QWORD PTR [rsp+0x30]
     f6c:	test   rax,0x1
     f72:	je     f8f <botlish_fn_6+0x1cf>
     f78:	mov    rcx,QWORD PTR [rsp+0x30]
     f7d:	mov    rax,rcx
     f80:	add    rax,0x2
     f84:	seto   cl
     f87:	test   cl,cl
     f89:	je     fa5 <botlish_fn_6+0x1e5>
     f8f:	mov    edx,0x3
     f94:	mov    rax,QWORD PTR [rip+0x0]        # f9b <botlish_fn_6+0x1db>
			f97: R_X86_64_GOTPCREL	rt_int_add-0x4
     f9b:	mov    rsi,QWORD PTR [rsp+0x30]
     fa0:	mov    rdi,r14
     fa3:	call   rax
     fa5:	mov    QWORD PTR [r13+0x0],rax
     fa9:	lea    rdx,[rsp+0x18]
     fae:	mov    QWORD PTR [rsp+0x18],rbx
     fb3:	mov    QWORD PTR [rsp+0x20],r12
     fb8:	mov    QWORD PTR [rsp+0x28],rax
     fbd:	mov    esi,0x3
     fc2:	mov    rax,QWORD PTR [rip+0x0]        # fc9 <botlish_fn_6+0x209>
			fc5: R_X86_64_GOTPCREL	rt_list_new-0x4
     fc9:	mov    rdi,r14
     fcc:	call   rax
     fce:	test   rax,rax
     fd1:	jne    fdf <botlish_fn_6+0x21f>
     fd7:	mov    rdi,r14
     fda:	jmp    10df <botlish_fn_6+0x31f>
     fdf:	mov    rdi,r14
     fe2:	mov    QWORD PTR [rdi],r13
     fe5:	mov    rbx,QWORD PTR [rsp+0x40]
     fea:	mov    r12,QWORD PTR [rsp+0x48]
     fef:	mov    r13,QWORD PTR [rsp+0x50]
     ff4:	mov    r14,QWORD PTR [rsp+0x58]
     ff9:	mov    r15,QWORD PTR [rsp+0x60]
     ffe:	add    rsp,0x70
    1002:	mov    rsp,rbp
    1005:	pop    rbp
    1006:	ret
    1007:	mov    rdx,r12
    100a:	mov    rsi,rbx
    100d:	mov    rax,QWORD PTR [rip+0x0]        # 1014 <botlish_fn_6+0x254>
			1010: R_X86_64_GOTPCREL	rt_list_append-0x4
    1014:	mov    rdi,r14
    1017:	call   rax
    1019:	test   rax,rax
    101c:	jne    102a <botlish_fn_6+0x26a>
    1022:	mov    rdi,r14
    1025:	jmp    10df <botlish_fn_6+0x31f>
    102a:	mov    QWORD PTR [r13+0x8],rax
    102e:	mov    rbx,rax
    1031:	mov    rdi,r14
    1034:	call   1039 <botlish_fn_6+0x279>
			1035: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1039:	test   rax,rax
    103c:	jne    104a <botlish_fn_6+0x28a>
    1042:	mov    rdi,r14
    1045:	jmp    10df <botlish_fn_6+0x31f>
    104a:	mov    QWORD PTR [r13+0x10],rax
    104e:	mov    rsi,rax
    1051:	mov    rax,QWORD PTR [rip+0x0]        # 1058 <botlish_fn_6+0x298>
			1054: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    1058:	mov    rdi,r14
    105b:	call   rax
    105d:	test   rax,rax
    1060:	jne    106e <botlish_fn_6+0x2ae>
    1066:	mov    rdi,r14
    1069:	jmp    10df <botlish_fn_6+0x31f>
    106e:	mov    QWORD PTR [r13+0x0],rax
    1072:	mov    r12,rax
    1075:	mov    edx,0x1
    107a:	mov    rax,QWORD PTR [rip+0x0]        # 1081 <botlish_fn_6+0x2c1>
			107d: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    1081:	mov    rcx,r15
    1084:	mov    rsi,r12
    1087:	mov    rdi,r14
    108a:	call   rax
    108c:	test   rax,rax
    108f:	jne    109d <botlish_fn_6+0x2dd>
    1095:	mov    rdi,r14
    1098:	jmp    10df <botlish_fn_6+0x31f>
    109d:	mov    esi,0x3
    10a2:	mov    QWORD PTR [r13+0x10],0x3
    10aa:	lea    rdx,[rsp]
    10ae:	mov    rax,rbx
    10b1:	mov    QWORD PTR [rsp],rax
    10b5:	mov    rax,r12
    10b8:	mov    QWORD PTR [rsp+0x8],rax
    10bd:	mov    QWORD PTR [rsp+0x10],0x3
    10c6:	mov    r8,QWORD PTR [rip+0x0]        # 10cd <botlish_fn_6+0x30d>
			10c9: R_X86_64_GOTPCREL	rt_list_new-0x4
    10cd:	mov    rdi,r14
    10d0:	call   r8
    10d3:	test   rax,rax
    10d6:	jne    110a <botlish_fn_6+0x34a>
    10dc:	mov    rdi,r14
    10df:	mov    rdi,r14
    10e2:	mov    QWORD PTR [rdi],r13
    10e5:	xor    rax,rax
    10e8:	mov    rbx,QWORD PTR [rsp+0x40]
    10ed:	mov    r12,QWORD PTR [rsp+0x48]
    10f2:	mov    r13,QWORD PTR [rsp+0x50]
    10f7:	mov    r14,QWORD PTR [rsp+0x58]
    10fc:	mov    r15,QWORD PTR [rsp+0x60]
    1101:	add    rsp,0x70
    1105:	mov    rsp,rbp
    1108:	pop    rbp
    1109:	ret
    110a:	mov    rdi,r14
    110d:	mov    QWORD PTR [rdi],r13
    1110:	mov    rbx,QWORD PTR [rsp+0x40]
    1115:	mov    r12,QWORD PTR [rsp+0x48]
    111a:	mov    r13,QWORD PTR [rsp+0x50]
    111f:	mov    r14,QWORD PTR [rsp+0x58]
    1124:	mov    r15,QWORD PTR [rsp+0x60]
    1129:	add    rsp,0x70
    112d:	mov    rsp,rbp
    1130:	pop    rbp
    1131:	ret
    1132:	mov    r14,rdi
    1135:	mov    r9,QWORD PTR [rip+0x0]        # 113c <botlish_fn_6+0x37c>
			1138: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    113c:	call   r9
    113f:	xor    rax,rax
    1142:	mov    rbx,QWORD PTR [rsp+0x40]
    1147:	mov    r12,QWORD PTR [rsp+0x48]
    114c:	mov    r13,QWORD PTR [rsp+0x50]
    1151:	mov    r14,QWORD PTR [rsp+0x58]
    1156:	mov    r15,QWORD PTR [rsp+0x60]
    115b:	add    rsp,0x70
    115f:	mov    rsp,rbp
    1162:	pop    rbp
    1163:	ret
    1164:	add    BYTE PTR [rax],al
    1166:	add    BYTE PTR [rax],al
    1168:	(bad)
    1169:	add    BYTE PTR [rax],al
    116b:	add    BYTE PTR [rax],al
    116d:	add    BYTE PTR [rax],al
	...

0000000000001170 <botlish_entry_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
    1170:	push   rbp
    1171:	mov    rbp,rsp
    1174:	mov    rsi,QWORD PTR [rdx]
    1177:	mov    rdx,QWORD PTR [rdx+0x8]
    117b:	call   1180 <botlish_entry_6+0x10>
			117c: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], list>
    1180:	mov    rsp,rbp
    1183:	pop    rbp
    1184:	ret
    1185:	add    BYTE PTR [rax],al
	...

0000000000001188 <botlish_fn_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
    1188:	push   rbp
    1189:	mov    rbp,rsp
    118c:	sub    rsp,0x40
    1190:	mov    QWORD PTR [rsp+0x10],rbx
    1195:	mov    QWORD PTR [rsp+0x18],r12
    119a:	mov    QWORD PTR [rsp+0x20],r13
    119f:	mov    QWORD PTR [rsp+0x28],r14
    11a4:	mov    QWORD PTR [rsp+0x30],r15
    11a9:	mov    r13,QWORD PTR [rdi]
    11ac:	mov    rax,QWORD PTR [rdi+0x8]
    11b0:	lea    r9,[r13+0x30]
    11b4:	cmp    r9,rax
    11b7:	ja     1441 <botlish_fn_7+0x2b9>
    11bd:	lea    rax,[r13+0x30]
    11c1:	mov    QWORD PTR [rdi],rax
    11c4:	mov    r14,rdi
    11c7:	mov    QWORD PTR [r13+0x0],0x0
    11cf:	mov    QWORD PTR [r13+0x8],0x0
    11d7:	mov    QWORD PTR [r13+0x10],0x0
    11df:	mov    QWORD PTR [r13+0x18],0x0
    11e7:	mov    QWORD PTR [r13+0x20],0x0
    11ef:	mov    QWORD PTR [r13+0x28],0x0
    11f7:	mov    QWORD PTR [r13+0x0],rsi
    11fb:	mov    QWORD PTR [r13+0x8],rdx
    11ff:	mov    r12,rdx
    1202:	mov    QWORD PTR [r13+0x10],rcx
    1206:	mov    QWORD PTR [rsp],rcx
    120a:	mov    QWORD PTR [r13+0x18],r8
    120e:	mov    QWORD PTR [rsp+0x8],r8
    1213:	mov    r8,QWORD PTR [rip+0x0]        # 121a <botlish_fn_7+0x92>
			1216: R_X86_64_GOTPCREL	rt_list_len-0x4
    121a:	mov    rbx,rsi
    121d:	mov    rdi,r14
    1220:	call   r8
    1223:	mov    r15,r12
    1226:	mov    rsi,r15
    1229:	and    rsi,rax
    122c:	mov    rdx,rax
    122f:	test   rsi,0x1
    1236:	jne    1261 <botlish_fn_7+0xd9>
    123c:	mov    r8,QWORD PTR [rip+0x0]        # 1243 <botlish_fn_7+0xbb>
			123f: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1243:	mov    rsi,r15
    1246:	mov    rdi,r14
    1249:	call   r8
    124c:	mov    ecx,0x2
    1251:	test   rax,rax
    1254:	cmovge rcx,QWORD PTR [rip+0x21c]        # 1478 <botlish_fn_7+0x2f0>
    125c:	jmp    1271 <botlish_fn_7+0xe9>
    1261:	mov    ecx,0x2
    1266:	cmp    r15,rdx
    1269:	cmovge rcx,QWORD PTR [rip+0x207]        # 1478 <botlish_fn_7+0x2f0>
    1271:	cmp    rcx,0x6
    1275:	je     1414 <botlish_fn_7+0x28c>
    127b:	mov    rax,QWORD PTR [rip+0x0]        # 1282 <botlish_fn_7+0xfa>
			127e: R_X86_64_GOTPCREL	rt_list_get-0x4
    1282:	mov    rdx,r15
    1285:	mov    rsi,rbx
    1288:	mov    rdi,r14
    128b:	call   rax
    128d:	mov    rcx,rax
    1290:	mov    r12,rax
    1293:	test   rax,rcx
    1296:	jne    12a4 <botlish_fn_7+0x11c>
    129c:	mov    rdi,r14
    129f:	jmp    1373 <botlish_fn_7+0x1eb>
    12a4:	mov    rax,r12
    12a7:	mov    QWORD PTR [r13+0x20],rax
    12ab:	mov    QWORD PTR [r13+0x28],0x1
    12b3:	mov    rdi,r14
    12b6:	call   12bb <botlish_fn_7+0x133>
			12b7: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    12bb:	test   rax,rax
    12be:	mov    r9,rax
    12c1:	jne    12cf <botlish_fn_7+0x147>
    12c7:	mov    rdi,r14
    12ca:	jmp    1373 <botlish_fn_7+0x1eb>
    12cf:	xor    ecx,ecx
    12d1:	mov    rax,r12
    12d4:	test   rax,0x7
    12da:	jne    12ec <botlish_fn_7+0x164>
    12e0:	mov    rax,r12
    12e3:	movzx  rax,BYTE PTR [rax]
    12e7:	cmp    al,0x8
    12e9:	sete   cl
    12ec:	test   cl,cl
    12ee:	jne    1318 <botlish_fn_7+0x190>
    12f4:	mov    rdi,r14
    12f7:	mov    rax,QWORD PTR [rdi+0x10]
    12fb:	mov    rcx,QWORD PTR [rax+0x8]
    12ff:	mov    edx,0x8
    1304:	mov    rax,QWORD PTR [rip+0x0]        # 130b <botlish_fn_7+0x183>
			1307: R_X86_64_GOTPCREL	rt_type_error-0x4
    130b:	mov    rsi,r12
    130e:	call   rax
    1310:	mov    rdi,r14
    1313:	jmp    1373 <botlish_fn_7+0x1eb>
    1318:	mov    r8d,0x1
    131e:	mov    rax,QWORD PTR [rip+0x0]        # 1325 <botlish_fn_7+0x19d>
			1321: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
    1325:	mov    rcx,r12
    1328:	mov    r12,QWORD PTR [rsp]
    132c:	mov    rdx,QWORD PTR [rsp+0x8]
    1331:	mov    rsi,r12
    1334:	mov    rdi,r14
    1337:	call   rax
    1339:	test   rax,rax
    133c:	jne    134a <botlish_fn_7+0x1c2>
    1342:	mov    rdi,r14
    1345:	jmp    1373 <botlish_fn_7+0x1eb>
    134a:	sar    r15,1
    134d:	add    r15,0x1
    1354:	shl    r15,1
    1357:	or     r15,0x1
    135b:	mov    QWORD PTR [r13+0x8],r15
    135f:	mov    rdi,r14
    1362:	call   1367 <botlish_fn_7+0x1df>
			1363: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1367:	test   rax,rax
    136a:	jne    139e <botlish_fn_7+0x216>
    1370:	mov    rdi,r14
    1373:	mov    rdi,r14
    1376:	mov    QWORD PTR [rdi],r13
    1379:	xor    rax,rax
    137c:	mov    rbx,QWORD PTR [rsp+0x10]
    1381:	mov    r12,QWORD PTR [rsp+0x18]
    1386:	mov    r13,QWORD PTR [rsp+0x20]
    138b:	mov    r14,QWORD PTR [rsp+0x28]
    1390:	mov    r15,QWORD PTR [rsp+0x30]
    1395:	add    rsp,0x40
    1399:	mov    rsp,rbp
    139c:	pop    rbp
    139d:	ret
    139e:	mov    QWORD PTR [r13+0x20],rax
    13a2:	mov    rsi,QWORD PTR [rsp+0x8]
    13a7:	mov    rcx,rsi
    13aa:	and    rcx,rax
    13ad:	test   rcx,0x1
    13b4:	jne    13c2 <botlish_fn_7+0x23a>
    13ba:	mov    rdx,rax
    13bd:	jmp    13df <botlish_fn_7+0x257>
    13c2:	lea    rcx,[rax-0x1]
    13c6:	mov    rdx,rax
    13c9:	mov    rsi,QWORD PTR [rsp+0x8]
    13ce:	mov    rax,rsi
    13d1:	add    rax,rcx
    13d4:	seto   cl
    13d7:	test   cl,cl
    13d9:	je     13f0 <botlish_fn_7+0x268>
    13df:	mov    rax,QWORD PTR [rip+0x0]        # 13e6 <botlish_fn_7+0x25e>
			13e2: R_X86_64_GOTPCREL	rt_int_add-0x4
    13e6:	mov    rsi,QWORD PTR [rsp+0x8]
    13eb:	mov    rdi,r14
    13ee:	call   rax
    13f0:	mov    QWORD PTR [r13+0x0],rbx
    13f4:	mov    QWORD PTR [r13+0x8],r15
    13f8:	mov    QWORD PTR [r13+0x10],r12
    13fc:	mov    QWORD PTR [r13+0x18],rax
    1400:	mov    QWORD PTR [rsp+0x8],rax
    1405:	mov    QWORD PTR [rsp],r12
    1409:	mov    r12,r15
    140c:	mov    rsi,rbx
    140f:	jmp    1213 <botlish_fn_7+0x8b>
    1414:	mov    rdi,r14
    1417:	mov    QWORD PTR [rdi],r13
    141a:	mov    rax,QWORD PTR [rsp+0x8]
    141f:	mov    rbx,QWORD PTR [rsp+0x10]
    1424:	mov    r12,QWORD PTR [rsp+0x18]
    1429:	mov    r13,QWORD PTR [rsp+0x20]
    142e:	mov    r14,QWORD PTR [rsp+0x28]
    1433:	mov    r15,QWORD PTR [rsp+0x30]
    1438:	add    rsp,0x40
    143c:	mov    rsp,rbp
    143f:	pop    rbp
    1440:	ret
    1441:	mov    r14,rdi
    1444:	mov    rax,QWORD PTR [rip+0x0]        # 144b <botlish_fn_7+0x2c3>
			1447: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    144b:	call   rax
    144d:	xor    rax,rax
    1450:	mov    rbx,QWORD PTR [rsp+0x10]
    1455:	mov    r12,QWORD PTR [rsp+0x18]
    145a:	mov    r13,QWORD PTR [rsp+0x20]
    145f:	mov    r14,QWORD PTR [rsp+0x28]
    1464:	mov    r15,QWORD PTR [rsp+0x30]
    1469:	add    rsp,0x40
    146d:	mov    rsp,rbp
    1470:	pop    rbp
    1471:	ret
    1472:	add    BYTE PTR [rax],al
    1474:	add    BYTE PTR [rax],al
    1476:	add    BYTE PTR [rax],al
    1478:	(bad)
    1479:	add    BYTE PTR [rax],al
    147b:	add    BYTE PTR [rax],al
    147d:	add    BYTE PTR [rax],al
	...

0000000000001480 <botlish_entry_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
    1480:	push   rbp
    1481:	mov    rbp,rsp
    1484:	mov    rsi,QWORD PTR [rdx]
    1487:	mov    r9,QWORD PTR [rdx+0x8]
    148b:	mov    rcx,QWORD PTR [rdx+0x10]
    148f:	mov    r8,QWORD PTR [rdx+0x18]
    1493:	mov    rdx,r9
    1496:	call   149b <botlish_entry_7+0x1b>
			1497: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
    149b:	mov    rsp,rbp
    149e:	pop    rbp
    149f:	ret

00000000000014a0 <botlish_fn_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
    14a0:	push   rbp
    14a1:	mov    rbp,rsp
    14a4:	sub    rsp,0x40
    14a8:	mov    QWORD PTR [rsp+0x10],rbx
    14ad:	mov    QWORD PTR [rsp+0x18],r12
    14b2:	mov    QWORD PTR [rsp+0x20],r13
    14b7:	mov    QWORD PTR [rsp+0x28],r14
    14bc:	mov    QWORD PTR [rsp+0x30],r15
    14c1:	mov    r14,QWORD PTR [rdi]
    14c4:	mov    rax,QWORD PTR [rdi+0x8]
    14c8:	lea    r9,[r14+0x30]
    14cc:	cmp    r9,rax
    14cf:	ja     1706 <botlish_fn_8+0x266>
    14d5:	lea    rax,[r14+0x30]
    14d9:	mov    QWORD PTR [rdi],rax
    14dc:	mov    r15,rdi
    14df:	mov    QWORD PTR [r14],0x0
    14e6:	mov    QWORD PTR [r14+0x8],0x0
    14ee:	mov    QWORD PTR [r14+0x10],0x0
    14f6:	mov    QWORD PTR [r14+0x18],0x0
    14fe:	mov    QWORD PTR [r14+0x20],0x0
    1506:	mov    QWORD PTR [r14+0x28],0x0
    150e:	mov    QWORD PTR [r14],rsi
    1511:	mov    QWORD PTR [r14+0x8],rdx
    1515:	mov    rbx,rdx
    1518:	mov    QWORD PTR [r14+0x10],rcx
    151c:	mov    QWORD PTR [rsp],rcx
    1520:	mov    QWORD PTR [r14+0x18],r8
    1524:	mov    QWORD PTR [rsp+0x8],r8
    1529:	mov    rax,QWORD PTR [rip+0x0]        # 1530 <botlish_fn_8+0x90>
			152c: R_X86_64_GOTPCREL	rt_list_len-0x4
    1530:	mov    r12,rsi
    1533:	mov    rdi,r15
    1536:	call   rax
    1538:	mov    r13,rbx
    153b:	mov    rcx,r13
    153e:	and    rcx,rax
    1541:	mov    rdx,rax
    1544:	test   rcx,0x1
    154b:	jne    1575 <botlish_fn_8+0xd5>
    1551:	mov    rax,QWORD PTR [rip+0x0]        # 1558 <botlish_fn_8+0xb8>
			1554: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1558:	mov    rsi,r13
    155b:	mov    rdi,r15
    155e:	call   rax
    1560:	mov    ecx,0x2
    1565:	test   rax,rax
    1568:	cmovge rcx,QWORD PTR [rip+0x1c8]        # 1738 <botlish_fn_8+0x298>
    1570:	jmp    1585 <botlish_fn_8+0xe5>
    1575:	mov    ecx,0x2
    157a:	cmp    r13,rdx
    157d:	cmovge rcx,QWORD PTR [rip+0x1b3]        # 1738 <botlish_fn_8+0x298>
    1585:	cmp    rcx,0x6
    1589:	je     16d9 <botlish_fn_8+0x239>
    158f:	mov    r8,QWORD PTR [rip+0x0]        # 1596 <botlish_fn_8+0xf6>
			1592: R_X86_64_GOTPCREL	rt_list_get-0x4
    1596:	mov    rdx,r13
    1599:	mov    rsi,r12
    159c:	mov    rdi,r15
    159f:	call   r8
    15a2:	test   rax,rax
    15a5:	jne    15b3 <botlish_fn_8+0x113>
    15ab:	mov    rdi,r15
    15ae:	jmp    1639 <botlish_fn_8+0x199>
    15b3:	mov    QWORD PTR [r14+0x20],rax
    15b7:	mov    rbx,rax
    15ba:	mov    QWORD PTR [r14+0x28],0x1
    15c2:	mov    rdi,r15
    15c5:	call   15ca <botlish_fn_8+0x12a>
			15c6: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    15ca:	test   rax,rax
    15cd:	mov    r9,rax
    15d0:	jne    15de <botlish_fn_8+0x13e>
    15d6:	mov    rdi,r15
    15d9:	jmp    1639 <botlish_fn_8+0x199>
    15de:	mov    r8d,0x1
    15e4:	mov    rax,QWORD PTR [rip+0x0]        # 15eb <botlish_fn_8+0x14b>
			15e7: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
    15eb:	mov    rcx,rbx
    15ee:	mov    rbx,QWORD PTR [rsp]
    15f2:	mov    rdx,QWORD PTR [rsp+0x8]
    15f7:	mov    rsi,rbx
    15fa:	mov    rdi,r15
    15fd:	call   rax
    15ff:	test   rax,rax
    1602:	jne    1610 <botlish_fn_8+0x170>
    1608:	mov    rdi,r15
    160b:	jmp    1639 <botlish_fn_8+0x199>
    1610:	sar    r13,1
    1613:	add    r13,0x1
    161a:	shl    r13,1
    161d:	or     r13,0x1
    1621:	mov    QWORD PTR [r14+0x8],r13
    1625:	mov    rdi,r15
    1628:	call   162d <botlish_fn_8+0x18d>
			1629: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    162d:	test   rax,rax
    1630:	jne    1664 <botlish_fn_8+0x1c4>
    1636:	mov    rdi,r15
    1639:	mov    rdi,r15
    163c:	mov    QWORD PTR [rdi],r14
    163f:	xor    rax,rax
    1642:	mov    rbx,QWORD PTR [rsp+0x10]
    1647:	mov    r12,QWORD PTR [rsp+0x18]
    164c:	mov    r13,QWORD PTR [rsp+0x20]
    1651:	mov    r14,QWORD PTR [rsp+0x28]
    1656:	mov    r15,QWORD PTR [rsp+0x30]
    165b:	add    rsp,0x40
    165f:	mov    rsp,rbp
    1662:	pop    rbp
    1663:	ret
    1664:	mov    QWORD PTR [r14+0x20],rax
    1668:	mov    rsi,QWORD PTR [rsp+0x8]
    166d:	mov    rcx,rsi
    1670:	and    rcx,rax
    1673:	test   rcx,0x1
    167a:	jne    1688 <botlish_fn_8+0x1e8>
    1680:	mov    rdx,rax
    1683:	jmp    16a5 <botlish_fn_8+0x205>
    1688:	lea    rcx,[rax-0x1]
    168c:	mov    rdx,rax
    168f:	mov    rsi,QWORD PTR [rsp+0x8]
    1694:	mov    rax,rsi
    1697:	add    rax,rcx
    169a:	seto   cl
    169d:	test   cl,cl
    169f:	je     16b6 <botlish_fn_8+0x216>
    16a5:	mov    rax,QWORD PTR [rip+0x0]        # 16ac <botlish_fn_8+0x20c>
			16a8: R_X86_64_GOTPCREL	rt_int_add-0x4
    16ac:	mov    rsi,QWORD PTR [rsp+0x8]
    16b1:	mov    rdi,r15
    16b4:	call   rax
    16b6:	mov    QWORD PTR [r14],r12
    16b9:	mov    QWORD PTR [r14+0x8],r13
    16bd:	mov    QWORD PTR [r14+0x10],rbx
    16c1:	mov    QWORD PTR [r14+0x18],rax
    16c5:	mov    QWORD PTR [rsp+0x8],rax
    16ca:	mov    QWORD PTR [rsp],rbx
    16ce:	mov    rsi,r12
    16d1:	mov    rbx,r13
    16d4:	jmp    1529 <botlish_fn_8+0x89>
    16d9:	mov    rdi,r15
    16dc:	mov    QWORD PTR [rdi],r14
    16df:	mov    rax,QWORD PTR [rsp+0x8]
    16e4:	mov    rbx,QWORD PTR [rsp+0x10]
    16e9:	mov    r12,QWORD PTR [rsp+0x18]
    16ee:	mov    r13,QWORD PTR [rsp+0x20]
    16f3:	mov    r14,QWORD PTR [rsp+0x28]
    16f8:	mov    r15,QWORD PTR [rsp+0x30]
    16fd:	add    rsp,0x40
    1701:	mov    rsp,rbp
    1704:	pop    rbp
    1705:	ret
    1706:	mov    r15,rdi
    1709:	mov    rax,QWORD PTR [rip+0x0]        # 1710 <botlish_fn_8+0x270>
			170c: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1710:	call   rax
    1712:	xor    rax,rax
    1715:	mov    rbx,QWORD PTR [rsp+0x10]
    171a:	mov    r12,QWORD PTR [rsp+0x18]
    171f:	mov    r13,QWORD PTR [rsp+0x20]
    1724:	mov    r14,QWORD PTR [rsp+0x28]
    1729:	mov    r15,QWORD PTR [rsp+0x30]
    172e:	add    rsp,0x40
    1732:	mov    rsp,rbp
    1735:	pop    rbp
    1736:	ret
    1737:	add    BYTE PTR [rsi],al
    1739:	add    BYTE PTR [rax],al
    173b:	add    BYTE PTR [rax],al
    173d:	add    BYTE PTR [rax],al
	...

0000000000001740 <botlish_entry_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
    1740:	push   rbp
    1741:	mov    rbp,rsp
    1744:	mov    rsi,QWORD PTR [rdx]
    1747:	mov    r9,QWORD PTR [rdx+0x8]
    174b:	mov    rcx,QWORD PTR [rdx+0x10]
    174f:	mov    r8,QWORD PTR [rdx+0x18]
    1753:	mov    rdx,r9
    1756:	call   175b <botlish_entry_8+0x1b>
			1757: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    175b:	mov    rsp,rbp
    175e:	pop    rbp
    175f:	ret

0000000000001760 <botlish_fn_9: chunked_finish<list[list<never>, mutarray, int]>>:
    1760:	push   rbp
    1761:	mov    rbp,rsp
    1764:	sub    rsp,0x40
    1768:	mov    QWORD PTR [rsp+0x10],rbx
    176d:	mov    QWORD PTR [rsp+0x18],r12
    1772:	mov    QWORD PTR [rsp+0x20],r13
    1777:	mov    QWORD PTR [rsp+0x28],r14
    177c:	mov    QWORD PTR [rsp+0x30],r15
    1781:	mov    rbx,rsi
    1784:	mov    r12,QWORD PTR [rdi]
    1787:	mov    rax,QWORD PTR [rdi+0x8]
    178b:	lea    rcx,[r12+0x38]
    1790:	cmp    rcx,rax
    1793:	ja     1a54 <botlish_fn_9+0x2f4>
    1799:	lea    rax,[r12+0x38]
    179e:	mov    QWORD PTR [rdi],rax
    17a1:	mov    r14,rdi
    17a4:	mov    QWORD PTR [r12],0x0
    17ac:	mov    QWORD PTR [r12+0x8],0x0
    17b5:	mov    QWORD PTR [r12+0x10],0x0
    17be:	mov    QWORD PTR [r12+0x18],0x0
    17c7:	mov    QWORD PTR [r12+0x20],0x0
    17d0:	mov    QWORD PTR [r12+0x28],0x0
    17d9:	mov    QWORD PTR [r12+0x30],0x0
    17e2:	mov    edx,0x1
    17e7:	mov    rax,QWORD PTR [rip+0x0]        # 17ee <botlish_fn_9+0x8e>
			17ea: R_X86_64_GOTPCREL	rt_list_get-0x4
    17ee:	mov    rsi,rbx
    17f1:	mov    rdi,r14
    17f4:	call   rax
    17f6:	test   rax,rax
    17f9:	jne    1807 <botlish_fn_9+0xa7>
    17ff:	mov    rdi,r14
    1802:	jmp    1a01 <botlish_fn_9+0x2a1>
    1807:	mov    QWORD PTR [r12],rax
    180b:	mov    r15,rax
    180e:	mov    edx,0x3
    1813:	mov    r8,QWORD PTR [rip+0x0]        # 181a <botlish_fn_9+0xba>
			1816: R_X86_64_GOTPCREL	rt_list_get-0x4
    181a:	mov    rsi,rbx
    181d:	mov    rdi,r14
    1820:	call   r8
    1823:	test   rax,rax
    1826:	jne    1834 <botlish_fn_9+0xd4>
    182c:	mov    rdi,r14
    182f:	jmp    1a01 <botlish_fn_9+0x2a1>
    1834:	mov    QWORD PTR [r12+0x8],rax
    1839:	mov    QWORD PTR [rsp+0x8],rax
    183e:	mov    edx,0x5
    1843:	mov    r8,QWORD PTR [rip+0x0]        # 184a <botlish_fn_9+0xea>
			1846: R_X86_64_GOTPCREL	rt_list_get-0x4
    184a:	mov    rsi,rbx
    184d:	mov    rdi,r14
    1850:	call   r8
    1853:	mov    rbx,rax
    1856:	test   rbx,rbx
    1859:	jne    1867 <botlish_fn_9+0x107>
    185f:	mov    rdi,r14
    1862:	jmp    1a01 <botlish_fn_9+0x2a1>
    1867:	mov    QWORD PTR [r12+0x10],rbx
    186c:	mov    r10,QWORD PTR [rip+0x0]        # 1873 <botlish_fn_9+0x113>
			186f: R_X86_64_GOTPCREL	rt_list_len-0x4
    1873:	mov    rsi,r15
    1876:	mov    rdi,r14
    1879:	call   r10
    187c:	mov    QWORD PTR [r12+0x18],rax
    1881:	mov    r13,rax
    1884:	mov    rdi,r14
    1887:	call   188c <botlish_fn_9+0x12c>
			1888: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    188c:	test   rax,rax
    188f:	jne    189d <botlish_fn_9+0x13d>
    1895:	mov    rdi,r14
    1898:	jmp    1a01 <botlish_fn_9+0x2a1>
    189d:	mov    QWORD PTR [r12+0x20],rax
    18a2:	mov    rcx,r13
    18a5:	mov    rdx,rcx
    18a8:	and    rdx,rax
    18ab:	mov    rdi,rax
    18ae:	test   rdx,0x1
    18b5:	jne    18c3 <botlish_fn_9+0x163>
    18bb:	mov    r13,rcx
    18be:	jmp    18ed <botlish_fn_9+0x18d>
    18c3:	mov    rax,rcx
    18c6:	sar    rax,1
    18c9:	mov    rsi,rdi
    18cc:	mov    r13,rcx
    18cf:	lea    rcx,[rsi-0x1]
    18d3:	imul   rcx
    18d6:	seto   cl
    18d9:	or     rax,0x1
    18dd:	test   cl,cl
    18df:	jne    18ed <botlish_fn_9+0x18d>
    18e5:	mov    rsi,rax
    18e8:	jmp    1902 <botlish_fn_9+0x1a2>
    18ed:	mov    rax,QWORD PTR [rip+0x0]        # 18f4 <botlish_fn_9+0x194>
			18f0: R_X86_64_GOTPCREL	rt_int_mul-0x4
    18f4:	mov    rdx,rdi
    18f7:	mov    rsi,r13
    18fa:	mov    rdi,r14
    18fd:	call   rax
    18ff:	mov    rsi,rax
    1902:	mov    QWORD PTR [r12+0x18],rsi
    1907:	mov    rax,rsi
    190a:	and    rax,rbx
    190d:	test   rax,0x1
    1913:	je     192e <botlish_fn_9+0x1ce>
    1919:	lea    rax,[rbx-0x1]
    191d:	mov    r13,rsi
    1920:	add    r13,rax
    1923:	seto   al
    1926:	test   al,al
    1928:	je     1940 <botlish_fn_9+0x1e0>
    192e:	mov    rax,QWORD PTR [rip+0x0]        # 1935 <botlish_fn_9+0x1d5>
			1931: R_X86_64_GOTPCREL	rt_int_add-0x4
    1935:	mov    rdx,rbx
    1938:	mov    rdi,r14
    193b:	call   rax
    193d:	mov    r13,rax
    1940:	mov    QWORD PTR [r12+0x18],r13
    1945:	mov    rax,QWORD PTR [rip+0x0]        # 194c <botlish_fn_9+0x1ec>
			1948: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    194c:	mov    rsi,r13
    194f:	mov    rdi,r14
    1952:	call   rax
    1954:	mov    rcx,rax
    1957:	mov    QWORD PTR [rsp],rax
    195b:	test   rax,rcx
    195e:	jne    196c <botlish_fn_9+0x20c>
    1964:	mov    rdi,r14
    1967:	jmp    1a01 <botlish_fn_9+0x2a1>
    196c:	mov    rax,QWORD PTR [rsp]
    1970:	mov    QWORD PTR [r12+0x20],rax
    1975:	mov    r8d,0x1
    197b:	mov    QWORD PTR [r12+0x28],0x1
    1984:	mov    QWORD PTR [r12+0x30],0x1
    198d:	mov    rsi,r15
    1990:	mov    rcx,QWORD PTR [rsp]
    1994:	mov    rdi,r14
    1997:	mov    rdx,r8
    199a:	call   199f <botlish_fn_9+0x23f>
			199b: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
    199f:	test   rax,rax
    19a2:	mov    rdx,rax
    19a5:	jne    19b3 <botlish_fn_9+0x253>
    19ab:	mov    rdi,r14
    19ae:	jmp    1a01 <botlish_fn_9+0x2a1>
    19b3:	mov    r8d,0x1
    19b9:	mov    rax,QWORD PTR [rip+0x0]        # 19c0 <botlish_fn_9+0x260>
			19bc: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
    19c0:	mov    rcx,QWORD PTR [rsp+0x8]
    19c5:	mov    r9,rbx
    19c8:	mov    rsi,QWORD PTR [rsp]
    19cc:	mov    rdi,r14
    19cf:	call   rax
    19d1:	test   rax,rax
    19d4:	jne    19e2 <botlish_fn_9+0x282>
    19da:	mov    rdi,r14
    19dd:	jmp    1a01 <botlish_fn_9+0x2a1>
    19e2:	mov    rax,QWORD PTR [rip+0x0]        # 19e9 <botlish_fn_9+0x289>
			19e5: R_X86_64_GOTPCREL	rt_mutarray_freeze-0x4
    19e9:	mov    rdx,r13
    19ec:	mov    rsi,QWORD PTR [rsp]
    19f0:	mov    rdi,r14
    19f3:	call   rax
    19f5:	test   rax,rax
    19f8:	jne    1a2c <botlish_fn_9+0x2cc>
    19fe:	mov    rdi,r14
    1a01:	mov    rdi,r14
    1a04:	mov    QWORD PTR [rdi],r12
    1a07:	xor    rax,rax
    1a0a:	mov    rbx,QWORD PTR [rsp+0x10]
    1a0f:	mov    r12,QWORD PTR [rsp+0x18]
    1a14:	mov    r13,QWORD PTR [rsp+0x20]
    1a19:	mov    r14,QWORD PTR [rsp+0x28]
    1a1e:	mov    r15,QWORD PTR [rsp+0x30]
    1a23:	add    rsp,0x40
    1a27:	mov    rsp,rbp
    1a2a:	pop    rbp
    1a2b:	ret
    1a2c:	mov    rdi,r14
    1a2f:	mov    QWORD PTR [rdi],r12
    1a32:	mov    rbx,QWORD PTR [rsp+0x10]
    1a37:	mov    r12,QWORD PTR [rsp+0x18]
    1a3c:	mov    r13,QWORD PTR [rsp+0x20]
    1a41:	mov    r14,QWORD PTR [rsp+0x28]
    1a46:	mov    r15,QWORD PTR [rsp+0x30]
    1a4b:	add    rsp,0x40
    1a4f:	mov    rsp,rbp
    1a52:	pop    rbp
    1a53:	ret
    1a54:	mov    r14,rdi
    1a57:	mov    rax,QWORD PTR [rip+0x0]        # 1a5e <botlish_fn_9+0x2fe>
			1a5a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1a5e:	call   rax
    1a60:	xor    rax,rax
    1a63:	mov    rbx,QWORD PTR [rsp+0x10]
    1a68:	mov    r12,QWORD PTR [rsp+0x18]
    1a6d:	mov    r13,QWORD PTR [rsp+0x20]
    1a72:	mov    r14,QWORD PTR [rsp+0x28]
    1a77:	mov    r15,QWORD PTR [rsp+0x30]
    1a7c:	add    rsp,0x40
    1a80:	mov    rsp,rbp
    1a83:	pop    rbp
    1a84:	ret

0000000000001a85 <botlish_entry_9: chunked_finish<list[list<never>, mutarray, int]>>:
    1a85:	push   rbp
    1a86:	mov    rbp,rsp
    1a89:	mov    rsi,QWORD PTR [rdx]
    1a8c:	call   1a91 <botlish_entry_9+0xc>
			1a8d: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    1a91:	mov    rsp,rbp
    1a94:	pop    rbp
    1a95:	ret

0000000000001a96 <botlish_fn_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1a96:	push   rbp
    1a97:	mov    rbp,rsp
    1a9a:	sub    rsp,0x40
    1a9e:	mov    QWORD PTR [rsp+0x10],rbx
    1aa3:	mov    QWORD PTR [rsp+0x18],r12
    1aa8:	mov    QWORD PTR [rsp+0x20],r13
    1aad:	mov    QWORD PTR [rsp+0x28],r14
    1ab2:	mov    QWORD PTR [rsp+0x30],r15
    1ab7:	mov    rbx,rsi
    1aba:	mov    r12,QWORD PTR [rdi]
    1abd:	mov    rax,QWORD PTR [rdi+0x8]
    1ac1:	lea    rcx,[r12+0x38]
    1ac6:	cmp    rcx,rax
    1ac9:	ja     1d8a <botlish_fn_10+0x2f4>
    1acf:	lea    rax,[r12+0x38]
    1ad4:	mov    QWORD PTR [rdi],rax
    1ad7:	mov    r14,rdi
    1ada:	mov    QWORD PTR [r12],0x0
    1ae2:	mov    QWORD PTR [r12+0x8],0x0
    1aeb:	mov    QWORD PTR [r12+0x10],0x0
    1af4:	mov    QWORD PTR [r12+0x18],0x0
    1afd:	mov    QWORD PTR [r12+0x20],0x0
    1b06:	mov    QWORD PTR [r12+0x28],0x0
    1b0f:	mov    QWORD PTR [r12+0x30],0x0
    1b18:	mov    edx,0x1
    1b1d:	mov    rax,QWORD PTR [rip+0x0]        # 1b24 <botlish_fn_10+0x8e>
			1b20: R_X86_64_GOTPCREL	rt_list_get-0x4
    1b24:	mov    rsi,rbx
    1b27:	mov    rdi,r14
    1b2a:	call   rax
    1b2c:	test   rax,rax
    1b2f:	jne    1b3d <botlish_fn_10+0xa7>
    1b35:	mov    rdi,r14
    1b38:	jmp    1d37 <botlish_fn_10+0x2a1>
    1b3d:	mov    QWORD PTR [r12],rax
    1b41:	mov    r15,rax
    1b44:	mov    edx,0x3
    1b49:	mov    r8,QWORD PTR [rip+0x0]        # 1b50 <botlish_fn_10+0xba>
			1b4c: R_X86_64_GOTPCREL	rt_list_get-0x4
    1b50:	mov    rsi,rbx
    1b53:	mov    rdi,r14
    1b56:	call   r8
    1b59:	test   rax,rax
    1b5c:	jne    1b6a <botlish_fn_10+0xd4>
    1b62:	mov    rdi,r14
    1b65:	jmp    1d37 <botlish_fn_10+0x2a1>
    1b6a:	mov    QWORD PTR [r12+0x8],rax
    1b6f:	mov    QWORD PTR [rsp+0x8],rax
    1b74:	mov    edx,0x5
    1b79:	mov    r8,QWORD PTR [rip+0x0]        # 1b80 <botlish_fn_10+0xea>
			1b7c: R_X86_64_GOTPCREL	rt_list_get-0x4
    1b80:	mov    rsi,rbx
    1b83:	mov    rdi,r14
    1b86:	call   r8
    1b89:	mov    rbx,rax
    1b8c:	test   rbx,rbx
    1b8f:	jne    1b9d <botlish_fn_10+0x107>
    1b95:	mov    rdi,r14
    1b98:	jmp    1d37 <botlish_fn_10+0x2a1>
    1b9d:	mov    QWORD PTR [r12+0x10],rbx
    1ba2:	mov    r10,QWORD PTR [rip+0x0]        # 1ba9 <botlish_fn_10+0x113>
			1ba5: R_X86_64_GOTPCREL	rt_list_len-0x4
    1ba9:	mov    rsi,r15
    1bac:	mov    rdi,r14
    1baf:	call   r10
    1bb2:	mov    QWORD PTR [r12+0x18],rax
    1bb7:	mov    r13,rax
    1bba:	mov    rdi,r14
    1bbd:	call   1bc2 <botlish_fn_10+0x12c>
			1bbe: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1bc2:	test   rax,rax
    1bc5:	jne    1bd3 <botlish_fn_10+0x13d>
    1bcb:	mov    rdi,r14
    1bce:	jmp    1d37 <botlish_fn_10+0x2a1>
    1bd3:	mov    QWORD PTR [r12+0x20],rax
    1bd8:	mov    rcx,r13
    1bdb:	mov    rdx,rcx
    1bde:	and    rdx,rax
    1be1:	mov    rdi,rax
    1be4:	test   rdx,0x1
    1beb:	jne    1bf9 <botlish_fn_10+0x163>
    1bf1:	mov    r13,rcx
    1bf4:	jmp    1c23 <botlish_fn_10+0x18d>
    1bf9:	mov    rax,rcx
    1bfc:	sar    rax,1
    1bff:	mov    rsi,rdi
    1c02:	mov    r13,rcx
    1c05:	lea    rcx,[rsi-0x1]
    1c09:	imul   rcx
    1c0c:	seto   cl
    1c0f:	or     rax,0x1
    1c13:	test   cl,cl
    1c15:	jne    1c23 <botlish_fn_10+0x18d>
    1c1b:	mov    rsi,rax
    1c1e:	jmp    1c38 <botlish_fn_10+0x1a2>
    1c23:	mov    rax,QWORD PTR [rip+0x0]        # 1c2a <botlish_fn_10+0x194>
			1c26: R_X86_64_GOTPCREL	rt_int_mul-0x4
    1c2a:	mov    rdx,rdi
    1c2d:	mov    rsi,r13
    1c30:	mov    rdi,r14
    1c33:	call   rax
    1c35:	mov    rsi,rax
    1c38:	mov    QWORD PTR [r12+0x18],rsi
    1c3d:	mov    rax,rsi
    1c40:	and    rax,rbx
    1c43:	test   rax,0x1
    1c49:	je     1c64 <botlish_fn_10+0x1ce>
    1c4f:	lea    rax,[rbx-0x1]
    1c53:	mov    r13,rsi
    1c56:	add    r13,rax
    1c59:	seto   al
    1c5c:	test   al,al
    1c5e:	je     1c76 <botlish_fn_10+0x1e0>
    1c64:	mov    rax,QWORD PTR [rip+0x0]        # 1c6b <botlish_fn_10+0x1d5>
			1c67: R_X86_64_GOTPCREL	rt_int_add-0x4
    1c6b:	mov    rdx,rbx
    1c6e:	mov    rdi,r14
    1c71:	call   rax
    1c73:	mov    r13,rax
    1c76:	mov    QWORD PTR [r12+0x18],r13
    1c7b:	mov    rax,QWORD PTR [rip+0x0]        # 1c82 <botlish_fn_10+0x1ec>
			1c7e: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    1c82:	mov    rsi,r13
    1c85:	mov    rdi,r14
    1c88:	call   rax
    1c8a:	mov    rcx,rax
    1c8d:	mov    QWORD PTR [rsp],rax
    1c91:	test   rax,rcx
    1c94:	jne    1ca2 <botlish_fn_10+0x20c>
    1c9a:	mov    rdi,r14
    1c9d:	jmp    1d37 <botlish_fn_10+0x2a1>
    1ca2:	mov    rax,QWORD PTR [rsp]
    1ca6:	mov    QWORD PTR [r12+0x20],rax
    1cab:	mov    r8d,0x1
    1cb1:	mov    QWORD PTR [r12+0x28],0x1
    1cba:	mov    QWORD PTR [r12+0x30],0x1
    1cc3:	mov    rsi,r15
    1cc6:	mov    rcx,QWORD PTR [rsp]
    1cca:	mov    rdi,r14
    1ccd:	mov    rdx,r8
    1cd0:	call   1cd5 <botlish_fn_10+0x23f>
			1cd1: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    1cd5:	test   rax,rax
    1cd8:	mov    rdx,rax
    1cdb:	jne    1ce9 <botlish_fn_10+0x253>
    1ce1:	mov    rdi,r14
    1ce4:	jmp    1d37 <botlish_fn_10+0x2a1>
    1ce9:	mov    r8d,0x1
    1cef:	mov    rax,QWORD PTR [rip+0x0]        # 1cf6 <botlish_fn_10+0x260>
			1cf2: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
    1cf6:	mov    rcx,QWORD PTR [rsp+0x8]
    1cfb:	mov    r9,rbx
    1cfe:	mov    rsi,QWORD PTR [rsp]
    1d02:	mov    rdi,r14
    1d05:	call   rax
    1d07:	test   rax,rax
    1d0a:	jne    1d18 <botlish_fn_10+0x282>
    1d10:	mov    rdi,r14
    1d13:	jmp    1d37 <botlish_fn_10+0x2a1>
    1d18:	mov    rax,QWORD PTR [rip+0x0]        # 1d1f <botlish_fn_10+0x289>
			1d1b: R_X86_64_GOTPCREL	rt_mutarray_freeze-0x4
    1d1f:	mov    rdx,r13
    1d22:	mov    rsi,QWORD PTR [rsp]
    1d26:	mov    rdi,r14
    1d29:	call   rax
    1d2b:	test   rax,rax
    1d2e:	jne    1d62 <botlish_fn_10+0x2cc>
    1d34:	mov    rdi,r14
    1d37:	mov    rdi,r14
    1d3a:	mov    QWORD PTR [rdi],r12
    1d3d:	xor    rax,rax
    1d40:	mov    rbx,QWORD PTR [rsp+0x10]
    1d45:	mov    r12,QWORD PTR [rsp+0x18]
    1d4a:	mov    r13,QWORD PTR [rsp+0x20]
    1d4f:	mov    r14,QWORD PTR [rsp+0x28]
    1d54:	mov    r15,QWORD PTR [rsp+0x30]
    1d59:	add    rsp,0x40
    1d5d:	mov    rsp,rbp
    1d60:	pop    rbp
    1d61:	ret
    1d62:	mov    rdi,r14
    1d65:	mov    QWORD PTR [rdi],r12
    1d68:	mov    rbx,QWORD PTR [rsp+0x10]
    1d6d:	mov    r12,QWORD PTR [rsp+0x18]
    1d72:	mov    r13,QWORD PTR [rsp+0x20]
    1d77:	mov    r14,QWORD PTR [rsp+0x28]
    1d7c:	mov    r15,QWORD PTR [rsp+0x30]
    1d81:	add    rsp,0x40
    1d85:	mov    rsp,rbp
    1d88:	pop    rbp
    1d89:	ret
    1d8a:	mov    r14,rdi
    1d8d:	mov    rax,QWORD PTR [rip+0x0]        # 1d94 <botlish_fn_10+0x2fe>
			1d90: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1d94:	call   rax
    1d96:	xor    rax,rax
    1d99:	mov    rbx,QWORD PTR [rsp+0x10]
    1d9e:	mov    r12,QWORD PTR [rsp+0x18]
    1da3:	mov    r13,QWORD PTR [rsp+0x20]
    1da8:	mov    r14,QWORD PTR [rsp+0x28]
    1dad:	mov    r15,QWORD PTR [rsp+0x30]
    1db2:	add    rsp,0x40
    1db6:	mov    rsp,rbp
    1db9:	pop    rbp
    1dba:	ret

0000000000001dbb <botlish_entry_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1dbb:	push   rbp
    1dbc:	mov    rbp,rsp
    1dbf:	mov    rsi,QWORD PTR [rdx]
    1dc2:	call   1dc7 <botlish_entry_10+0xc>
			1dc3: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1dc7:	mov    rsp,rbp
    1dca:	pop    rbp
    1dcb:	ret
    1dcc:	add    BYTE PTR [rax],al
	...

0000000000001dd0 <botlish_fn_11: peek<str, int>>:
    1dd0:	push   rbp
    1dd1:	mov    rbp,rsp
    1dd4:	sub    rsp,0x20
    1dd8:	mov    QWORD PTR [rsp],rbx
    1ddc:	mov    QWORD PTR [rsp+0x8],r12
    1de1:	mov    QWORD PTR [rsp+0x10],r13
    1de6:	mov    QWORD PTR [rsp+0x18],r14
    1deb:	mov    r12,QWORD PTR [rdi]
    1dee:	mov    rax,QWORD PTR [rdi+0x8]
    1df2:	lea    rcx,[r12+0x18]
    1df7:	cmp    rcx,rax
    1dfa:	ja     1f67 <botlish_fn_11+0x197>
    1e00:	lea    rax,[r12+0x18]
    1e05:	mov    QWORD PTR [rdi],rax
    1e08:	mov    r13,rdi
    1e0b:	mov    QWORD PTR [r12],0x0
    1e13:	mov    QWORD PTR [r12+0x8],0x0
    1e1c:	mov    QWORD PTR [r12+0x10],0x0
    1e25:	mov    QWORD PTR [r12],rsi
    1e29:	mov    r14,rsi
    1e2c:	mov    QWORD PTR [r12+0x8],rdx
    1e31:	mov    rbx,rdx
    1e34:	mov    rax,QWORD PTR [rip+0x0]        # 1e3b <botlish_fn_11+0x6b>
			1e37: R_X86_64_GOTPCREL	rt_str_len-0x4
    1e3b:	mov    rsi,r14
    1e3e:	mov    rdi,r13
    1e41:	call   rax
    1e43:	mov    rcx,rbx
    1e46:	and    rcx,rax
    1e49:	mov    rdx,rax
    1e4c:	test   rcx,0x1
    1e53:	jne    1e7d <botlish_fn_11+0xad>
    1e59:	mov    rax,QWORD PTR [rip+0x0]        # 1e60 <botlish_fn_11+0x90>
			1e5c: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1e60:	mov    rsi,rbx
    1e63:	mov    rdi,r13
    1e66:	call   rax
    1e68:	mov    ecx,0x2
    1e6d:	test   rax,rax
    1e70:	cmovge rcx,QWORD PTR [rip+0x120]        # 1f98 <botlish_fn_11+0x1c8>
    1e78:	jmp    1e8d <botlish_fn_11+0xbd>
    1e7d:	mov    ecx,0x2
    1e82:	cmp    rbx,rdx
    1e85:	cmovge rcx,QWORD PTR [rip+0x10b]        # 1f98 <botlish_fn_11+0x1c8>
    1e8d:	cmp    rcx,0x6
    1e91:	je     1f3d <botlish_fn_11+0x16d>
    1e97:	mov    QWORD PTR [r12+0x10],0x3
    1ea0:	test   rbx,0x1
    1ea7:	je     1ebf <botlish_fn_11+0xef>
    1ead:	mov    rcx,rbx
    1eb0:	add    rcx,0x2
    1eb4:	seto   al
    1eb7:	test   al,al
    1eb9:	je     1ed6 <botlish_fn_11+0x106>
    1ebf:	mov    edx,0x3
    1ec4:	mov    rax,QWORD PTR [rip+0x0]        # 1ecb <botlish_fn_11+0xfb>
			1ec7: R_X86_64_GOTPCREL	rt_int_add-0x4
    1ecb:	mov    rsi,rbx
    1ece:	mov    rdi,r13
    1ed1:	call   rax
    1ed3:	mov    rcx,rax
    1ed6:	mov    QWORD PTR [r12+0x10],rcx
    1edb:	mov    rax,QWORD PTR [rip+0x0]        # 1ee2 <botlish_fn_11+0x112>
			1ede: R_X86_64_GOTPCREL	rt_substr-0x4
    1ee2:	mov    rdx,rbx
    1ee5:	mov    rsi,r14
    1ee8:	mov    rdi,r13
    1eeb:	call   rax
    1eed:	test   rax,rax
    1ef0:	jne    1f1b <botlish_fn_11+0x14b>
    1ef6:	mov    rdi,r13
    1ef9:	mov    QWORD PTR [rdi],r12
    1efc:	xor    rax,rax
    1eff:	mov    rbx,QWORD PTR [rsp]
    1f03:	mov    r12,QWORD PTR [rsp+0x8]
    1f08:	mov    r13,QWORD PTR [rsp+0x10]
    1f0d:	mov    r14,QWORD PTR [rsp+0x18]
    1f12:	add    rsp,0x20
    1f16:	mov    rsp,rbp
    1f19:	pop    rbp
    1f1a:	ret
    1f1b:	mov    rdi,r13
    1f1e:	mov    QWORD PTR [rdi],r12
    1f21:	mov    rbx,QWORD PTR [rsp]
    1f25:	mov    r12,QWORD PTR [rsp+0x8]
    1f2a:	mov    r13,QWORD PTR [rsp+0x10]
    1f2f:	mov    r14,QWORD PTR [rsp+0x18]
    1f34:	add    rsp,0x20
    1f38:	mov    rsp,rbp
    1f3b:	pop    rbp
    1f3c:	ret
    1f3d:	mov    rdi,r13
    1f40:	mov    rsi,QWORD PTR [rdi+0x10]
    1f44:	mov    rax,QWORD PTR [rsi+0x10]
    1f48:	mov    QWORD PTR [rdi],r12
    1f4b:	mov    rbx,QWORD PTR [rsp]
    1f4f:	mov    r12,QWORD PTR [rsp+0x8]
    1f54:	mov    r13,QWORD PTR [rsp+0x10]
    1f59:	mov    r14,QWORD PTR [rsp+0x18]
    1f5e:	add    rsp,0x20
    1f62:	mov    rsp,rbp
    1f65:	pop    rbp
    1f66:	ret
    1f67:	mov    r13,rdi
    1f6a:	mov    rsi,QWORD PTR [rip+0x0]        # 1f71 <botlish_fn_11+0x1a1>
			1f6d: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1f71:	call   rsi
    1f73:	xor    rax,rax
    1f76:	mov    rbx,QWORD PTR [rsp]
    1f7a:	mov    r12,QWORD PTR [rsp+0x8]
    1f7f:	mov    r13,QWORD PTR [rsp+0x10]
    1f84:	mov    r14,QWORD PTR [rsp+0x18]
    1f89:	add    rsp,0x20
    1f8d:	mov    rsp,rbp
    1f90:	pop    rbp
    1f91:	ret
    1f92:	add    BYTE PTR [rax],al
    1f94:	add    BYTE PTR [rax],al
    1f96:	add    BYTE PTR [rax],al
    1f98:	(bad)
    1f99:	add    BYTE PTR [rax],al
    1f9b:	add    BYTE PTR [rax],al
    1f9d:	add    BYTE PTR [rax],al
	...

0000000000001fa0 <botlish_entry_11: peek<str, int>>:
    1fa0:	push   rbp
    1fa1:	mov    rbp,rsp
    1fa4:	mov    rsi,QWORD PTR [rdx]
    1fa7:	mov    rdx,QWORD PTR [rdx+0x8]
    1fab:	call   1fb0 <botlish_entry_11+0x10>
			1fac: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1fb0:	mov    rsp,rbp
    1fb3:	pop    rbp
    1fb4:	ret
    1fb5:	add    BYTE PTR [rax],al
	...

0000000000001fb8 <botlish_fn_12: peek<str, int>>:
    1fb8:	push   rbp
    1fb9:	mov    rbp,rsp
    1fbc:	sub    rsp,0x40
    1fc0:	mov    QWORD PTR [rsp+0x10],rbx
    1fc5:	mov    QWORD PTR [rsp+0x18],r12
    1fca:	mov    QWORD PTR [rsp+0x20],r13
    1fcf:	mov    QWORD PTR [rsp+0x28],r14
    1fd4:	mov    QWORD PTR [rsp+0x30],r15
    1fd9:	mov    r13,rcx
    1fdc:	mov    r12,QWORD PTR [rdi]
    1fdf:	mov    rax,QWORD PTR [rdi+0x8]
    1fe3:	lea    rcx,[r12+0x18]
    1fe8:	cmp    rcx,rax
    1feb:	ja     2197 <botlish_fn_12+0x1df>
    1ff1:	lea    rax,[r12+0x18]
    1ff6:	mov    QWORD PTR [rdi],rax
    1ff9:	mov    r15,rdi
    1ffc:	mov    QWORD PTR [r12],0x0
    2004:	mov    QWORD PTR [r12+0x8],0x0
    200d:	mov    QWORD PTR [r12+0x10],0x0
    2016:	mov    QWORD PTR [r12],rsi
    201a:	mov    r14,rsi
    201d:	mov    QWORD PTR [r12+0x8],rdx
    2022:	mov    rbx,rdx
    2025:	mov    rax,QWORD PTR [rip+0x0]        # 202c <botlish_fn_12+0x74>
			2028: R_X86_64_GOTPCREL	rt_str_len-0x4
    202c:	mov    rsi,r14
    202f:	mov    rdi,r15
    2032:	call   rax
    2034:	mov    rcx,rbx
    2037:	and    rcx,rax
    203a:	mov    rdx,rax
    203d:	test   rcx,0x1
    2044:	jne    206e <botlish_fn_12+0xb6>
    204a:	mov    rax,QWORD PTR [rip+0x0]        # 2051 <botlish_fn_12+0x99>
			204d: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    2051:	mov    rsi,rbx
    2054:	mov    rdi,r15
    2057:	call   rax
    2059:	mov    ecx,0x2
    205e:	test   rax,rax
    2061:	cmovge rcx,QWORD PTR [rip+0x167]        # 21d0 <botlish_fn_12+0x218>
    2069:	jmp    207e <botlish_fn_12+0xc6>
    206e:	mov    ecx,0x2
    2073:	cmp    rbx,rdx
    2076:	cmovge rcx,QWORD PTR [rip+0x152]        # 21d0 <botlish_fn_12+0x218>
    207e:	cmp    rcx,0x6
    2082:	je     2155 <botlish_fn_12+0x19d>
    2088:	mov    QWORD PTR [r12+0x10],0x3
    2091:	test   rbx,0x1
    2098:	je     20b9 <botlish_fn_12+0x101>
    209e:	mov    rax,rbx
    20a1:	add    rax,0x2
    20a5:	seto   cl
    20a8:	test   cl,cl
    20aa:	jne    20b9 <botlish_fn_12+0x101>
    20b0:	mov    QWORD PTR [rsp],rax
    20b4:	jmp    20d1 <botlish_fn_12+0x119>
    20b9:	mov    edx,0x3
    20be:	mov    rax,QWORD PTR [rip+0x0]        # 20c5 <botlish_fn_12+0x10d>
			20c1: R_X86_64_GOTPCREL	rt_int_add-0x4
    20c5:	mov    rsi,rbx
    20c8:	mov    rdi,r15
    20cb:	call   rax
    20cd:	mov    QWORD PTR [rsp],rax
    20d1:	mov    r8,QWORD PTR [rip+0x0]        # 20d8 <botlish_fn_12+0x120>
			20d4: R_X86_64_GOTPCREL	rt_str_region_check-0x4
    20d8:	mov    rcx,QWORD PTR [rsp]
    20dc:	mov    rdx,rbx
    20df:	mov    rsi,r14
    20e2:	mov    rdi,r15
    20e5:	call   r8
    20e8:	test   rax,rax
    20eb:	jne    211c <botlish_fn_12+0x164>
    20f1:	mov    rdi,r15
    20f4:	mov    QWORD PTR [rdi],r12
    20f7:	xor    rax,rax
    20fa:	mov    rbx,QWORD PTR [rsp+0x10]
    20ff:	mov    r12,QWORD PTR [rsp+0x18]
    2104:	mov    r13,QWORD PTR [rsp+0x20]
    2109:	mov    r14,QWORD PTR [rsp+0x28]
    210e:	mov    r15,QWORD PTR [rsp+0x30]
    2113:	add    rsp,0x40
    2117:	mov    rsp,rbp
    211a:	pop    rbp
    211b:	ret
    211c:	mov    rdi,r15
    211f:	mov    QWORD PTR [rdi],r12
    2122:	mov    rcx,r13
    2125:	mov    QWORD PTR [rcx],rbx
    2128:	mov    rax,QWORD PTR [rsp]
    212c:	mov    QWORD PTR [rcx+0x8],rax
    2130:	mov    rax,r14
    2133:	mov    rbx,QWORD PTR [rsp+0x10]
    2138:	mov    r12,QWORD PTR [rsp+0x18]
    213d:	mov    r13,QWORD PTR [rsp+0x20]
    2142:	mov    r14,QWORD PTR [rsp+0x28]
    2147:	mov    r15,QWORD PTR [rsp+0x30]
    214c:	add    rsp,0x40
    2150:	mov    rsp,rbp
    2153:	pop    rbp
    2154:	ret
    2155:	mov    rcx,r13
    2158:	mov    rdi,r15
    215b:	mov    rsi,QWORD PTR [rdi+0x10]
    215f:	mov    rax,QWORD PTR [rsi+0x10]
    2163:	mov    QWORD PTR [rdi],r12
    2166:	mov    QWORD PTR [rcx],0x1
    216d:	mov    QWORD PTR [rcx+0x8],0x1
    2175:	mov    rbx,QWORD PTR [rsp+0x10]
    217a:	mov    r12,QWORD PTR [rsp+0x18]
    217f:	mov    r13,QWORD PTR [rsp+0x20]
    2184:	mov    r14,QWORD PTR [rsp+0x28]
    2189:	mov    r15,QWORD PTR [rsp+0x30]
    218e:	add    rsp,0x40
    2192:	mov    rsp,rbp
    2195:	pop    rbp
    2196:	ret
    2197:	mov    r15,rdi
    219a:	mov    r10,QWORD PTR [rip+0x0]        # 21a1 <botlish_fn_12+0x1e9>
			219d: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    21a1:	call   r10
    21a4:	xor    rax,rax
    21a7:	mov    rbx,QWORD PTR [rsp+0x10]
    21ac:	mov    r12,QWORD PTR [rsp+0x18]
    21b1:	mov    r13,QWORD PTR [rsp+0x20]
    21b6:	mov    r14,QWORD PTR [rsp+0x28]
    21bb:	mov    r15,QWORD PTR [rsp+0x30]
    21c0:	add    rsp,0x40
    21c4:	mov    rsp,rbp
    21c7:	pop    rbp
    21c8:	ret
    21c9:	add    BYTE PTR [rax],al
    21cb:	add    BYTE PTR [rax],al
    21cd:	add    BYTE PTR [rax],al
    21cf:	add    BYTE PTR [rsi],al
    21d1:	add    BYTE PTR [rax],al
    21d3:	add    BYTE PTR [rax],al
    21d5:	add    BYTE PTR [rax],al
	...

00000000000021d8 <botlish_entry_12: peek<str, int>>:
    21d8:	push   rbp
    21d9:	mov    rbp,rsp
    21dc:	ud2

00000000000021de <botlish_fn_13: scan_unquoted<str, int, int>>:
    21de:	push   rbp
    21df:	mov    rbp,rsp
    21e2:	sub    rsp,0x60
    21e6:	mov    QWORD PTR [rsp+0x30],rbx
    21eb:	mov    QWORD PTR [rsp+0x38],r12
    21f0:	mov    QWORD PTR [rsp+0x40],r13
    21f5:	mov    QWORD PTR [rsp+0x48],r14
    21fa:	mov    QWORD PTR [rsp+0x50],r15
    21ff:	mov    r14,QWORD PTR [rdi]
    2202:	mov    rax,QWORD PTR [rdi+0x8]
    2206:	lea    r8,[r14+0x20]
    220a:	cmp    r8,rax
    220d:	ja     244c <botlish_fn_13+0x26e>
    2213:	lea    rax,[r14+0x20]
    2217:	mov    QWORD PTR [rdi],rax
    221a:	mov    r15,rdi
    221d:	mov    QWORD PTR [r14],0x0
    2224:	mov    QWORD PTR [r14+0x8],0x0
    222c:	mov    QWORD PTR [r14+0x10],0x0
    2234:	mov    QWORD PTR [r14+0x18],0x0
    223c:	mov    QWORD PTR [r14],rsi
    223f:	mov    QWORD PTR [rsp+0x10],rsi
    2244:	mov    QWORD PTR [r14+0x8],rdx
    2248:	mov    QWORD PTR [rsp+0x18],rdx
    224d:	mov    QWORD PTR [r14+0x10],rcx
    2251:	lea    rbx,[rsp]
    2255:	mov    QWORD PTR [rsp+0x20],rcx
    225a:	mov    rcx,rbx
    225d:	mov    rdx,QWORD PTR [rsp+0x20]
    2262:	mov    rsi,QWORD PTR [rsp+0x10]
    2267:	mov    rdi,r15
    226a:	call   226f <botlish_fn_13+0x91>
			226b: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    226f:	mov    rcx,rax
    2272:	mov    QWORD PTR [rsp+0x28],rax
    2277:	test   rax,rcx
    227a:	jne    2288 <botlish_fn_13+0xaa>
    2280:	mov    rdi,r15
    2283:	jmp    23f1 <botlish_fn_13+0x213>
    2288:	mov    r12,QWORD PTR [rsp]
    228c:	mov    r13,QWORD PTR [rsp+0x8]
    2291:	mov    rdi,r15
    2294:	mov    rcx,QWORD PTR [rdi+0x10]
    2298:	mov    r8,QWORD PTR [rcx+0x10]
    229c:	mov    r9,QWORD PTR [rip+0x0]        # 22a3 <botlish_fn_13+0xc5>
			229f: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    22a3:	mov    rcx,r13
    22a6:	mov    rdx,r12
    22a9:	mov    rsi,QWORD PTR [rsp+0x28]
    22ae:	call   r9
    22b1:	cmp    rax,0x6
    22b5:	je     22f9 <botlish_fn_13+0x11b>
    22bb:	mov    rdi,r15
    22be:	mov    rdx,QWORD PTR [rdi+0x10]
    22c2:	mov    r8,QWORD PTR [rdx+0x18]
    22c6:	mov    r9,QWORD PTR [rip+0x0]        # 22cd <botlish_fn_13+0xef>
			22c9: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    22cd:	mov    rcx,r13
    22d0:	mov    rdx,r12
    22d3:	mov    rsi,QWORD PTR [rsp+0x28]
    22d8:	call   r9
    22db:	cmp    rax,0x6
    22df:	je     22ef <botlish_fn_13+0x111>
    22e5:	mov    eax,0x2
    22ea:	jmp    22fe <botlish_fn_13+0x120>
    22ef:	mov    eax,0x6
    22f4:	jmp    22fe <botlish_fn_13+0x120>
    22f9:	mov    eax,0x6
    22fe:	cmp    rax,0x6
    2302:	je     2346 <botlish_fn_13+0x168>
    2308:	mov    rdi,r15
    230b:	mov    r10,QWORD PTR [rdi+0x10]
    230f:	mov    r8,QWORD PTR [r10+0x20]
    2313:	mov    r10,QWORD PTR [rip+0x0]        # 231a <botlish_fn_13+0x13c>
			2316: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    231a:	mov    rcx,r13
    231d:	mov    rdx,r12
    2320:	mov    rsi,QWORD PTR [rsp+0x28]
    2325:	call   r10
    2328:	cmp    rax,0x6
    232c:	je     233c <botlish_fn_13+0x15e>
    2332:	mov    eax,0x2
    2337:	jmp    234b <botlish_fn_13+0x16d>
    233c:	mov    eax,0x6
    2341:	jmp    234b <botlish_fn_13+0x16d>
    2346:	mov    eax,0x6
    234b:	cmp    rax,0x6
    234f:	je     23ca <botlish_fn_13+0x1ec>
    2355:	mov    QWORD PTR [r14+0x18],0x3
    235d:	mov    rsi,QWORD PTR [rsp+0x20]
    2362:	test   rsi,0x1
    2369:	je     2390 <botlish_fn_13+0x1b2>
    236f:	mov    rsi,QWORD PTR [rsp+0x20]
    2374:	mov    rax,rsi
    2377:	add    rax,0x2
    237b:	seto   cl
    237e:	test   cl,cl
    2380:	jne    2390 <botlish_fn_13+0x1b2>
    2386:	mov    rsi,QWORD PTR [rsp+0x10]
    238b:	jmp    23ab <botlish_fn_13+0x1cd>
    2390:	mov    edx,0x3
    2395:	mov    rax,QWORD PTR [rip+0x0]        # 239c <botlish_fn_13+0x1be>
			2398: R_X86_64_GOTPCREL	rt_int_add-0x4
    239c:	mov    rsi,QWORD PTR [rsp+0x20]
    23a1:	mov    rdi,r15
    23a4:	call   rax
    23a6:	mov    rsi,QWORD PTR [rsp+0x10]
    23ab:	mov    QWORD PTR [r14],rsi
    23ae:	mov    rdx,QWORD PTR [rsp+0x18]
    23b3:	mov    QWORD PTR [r14+0x8],rdx
    23b7:	mov    QWORD PTR [r14+0x10],rax
    23bb:	mov    QWORD PTR [rsp+0x10],rsi
    23c0:	mov    QWORD PTR [rsp+0x20],rax
    23c5:	jmp    225a <botlish_fn_13+0x7c>
    23ca:	mov    rdx,QWORD PTR [rsp+0x18]
    23cf:	mov    rsi,QWORD PTR [rsp+0x10]
    23d4:	mov    rax,QWORD PTR [rip+0x0]        # 23db <botlish_fn_13+0x1fd>
			23d7: R_X86_64_GOTPCREL	rt_substr-0x4
    23db:	mov    rcx,QWORD PTR [rsp+0x20]
    23e0:	mov    rdi,r15
    23e3:	call   rax
    23e5:	test   rax,rax
    23e8:	jne    241f <botlish_fn_13+0x241>
    23ee:	mov    rdi,r15
    23f1:	mov    rdi,r15
    23f4:	mov    QWORD PTR [rdi],r14
    23f7:	xor    rdx,rdx
    23fa:	mov    rax,rdx
    23fd:	mov    rbx,QWORD PTR [rsp+0x30]
    2402:	mov    r12,QWORD PTR [rsp+0x38]
    2407:	mov    r13,QWORD PTR [rsp+0x40]
    240c:	mov    r14,QWORD PTR [rsp+0x48]
    2411:	mov    r15,QWORD PTR [rsp+0x50]
    2416:	add    rsp,0x60
    241a:	mov    rsp,rbp
    241d:	pop    rbp
    241e:	ret
    241f:	mov    rdi,r15
    2422:	mov    QWORD PTR [rdi],r14
    2425:	mov    rdx,QWORD PTR [rsp+0x20]
    242a:	mov    rbx,QWORD PTR [rsp+0x30]
    242f:	mov    r12,QWORD PTR [rsp+0x38]
    2434:	mov    r13,QWORD PTR [rsp+0x40]
    2439:	mov    r14,QWORD PTR [rsp+0x48]
    243e:	mov    r15,QWORD PTR [rsp+0x50]
    2443:	add    rsp,0x60
    2447:	mov    rsp,rbp
    244a:	pop    rbp
    244b:	ret
    244c:	mov    r15,rdi
    244f:	mov    rax,QWORD PTR [rip+0x0]        # 2456 <botlish_fn_13+0x278>
			2452: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2456:	call   rax
    2458:	xor    rdx,rdx
    245b:	mov    rax,rdx
    245e:	mov    rbx,QWORD PTR [rsp+0x30]
    2463:	mov    r12,QWORD PTR [rsp+0x38]
    2468:	mov    r13,QWORD PTR [rsp+0x40]
    246d:	mov    r14,QWORD PTR [rsp+0x48]
    2472:	mov    r15,QWORD PTR [rsp+0x50]
    2477:	add    rsp,0x60
    247b:	mov    rsp,rbp
    247e:	pop    rbp
    247f:	ret

0000000000002480 <botlish_entry_13: scan_unquoted<str, int, int>>:
    2480:	push   rbp
    2481:	mov    rbp,rsp
    2484:	ud2

0000000000002486 <botlish_fn_14: scan_quoted<str, int, str>>:
    2486:	push   rbp
    2487:	mov    rbp,rsp
    248a:	sub    rsp,0x50
    248e:	mov    QWORD PTR [rsp+0x20],rbx
    2493:	mov    QWORD PTR [rsp+0x28],r12
    2498:	mov    QWORD PTR [rsp+0x30],r13
    249d:	mov    QWORD PTR [rsp+0x38],r14
    24a2:	mov    QWORD PTR [rsp+0x40],r15
    24a7:	mov    r13,QWORD PTR [rdi]
    24aa:	mov    rax,QWORD PTR [rdi+0x8]
    24ae:	lea    r8,[r13+0x28]
    24b2:	cmp    r8,rax
    24b5:	ja     27c2 <botlish_fn_14+0x33c>
    24bb:	lea    rax,[r13+0x28]
    24bf:	mov    QWORD PTR [rdi],rax
    24c2:	mov    r14,rdi
    24c5:	mov    QWORD PTR [r13+0x0],0x0
    24cd:	mov    QWORD PTR [r13+0x8],0x0
    24d5:	mov    QWORD PTR [r13+0x10],0x0
    24dd:	mov    QWORD PTR [r13+0x18],0x0
    24e5:	mov    QWORD PTR [r13+0x20],0x0
    24ed:	mov    QWORD PTR [r13+0x0],rsi
    24f1:	mov    QWORD PTR [r13+0x8],rdx
    24f5:	mov    QWORD PTR [r13+0x10],rcx
    24f9:	lea    r12,[rsp]
    24fd:	mov    rbx,rsi
    2500:	mov    r15,rdx
    2503:	mov    QWORD PTR [rsp+0x10],rcx
    2508:	mov    rdx,r15
    250b:	mov    rsi,rbx
    250e:	mov    rdi,r14
    2511:	call   2516 <botlish_fn_14+0x90>
			2512: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    2516:	test   rax,rax
    2519:	jne    2527 <botlish_fn_14+0xa1>
    251f:	mov    rdi,r14
    2522:	jmp    277b <botlish_fn_14+0x2f5>
    2527:	mov    QWORD PTR [r13+0x18],rax
    252b:	mov    rdi,r14
    252e:	mov    QWORD PTR [rsp+0x18],rax
    2533:	mov    rcx,QWORD PTR [rdi+0x10]
    2537:	mov    rsi,QWORD PTR [rcx+0x28]
    253b:	mov    edx,0x1
    2540:	mov    ecx,0x3
    2545:	mov    r9,QWORD PTR [rip+0x0]        # 254c <botlish_fn_14+0xc6>
			2548: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    254c:	mov    r8,QWORD PTR [rsp+0x18]
    2551:	call   r9
    2554:	cmp    rax,0x6
    2558:	je     25eb <botlish_fn_14+0x165>
    255e:	mov    QWORD PTR [r13+0x20],0x3
    2566:	mov    rsi,r15
    2569:	test   rsi,0x1
    2570:	je     2590 <botlish_fn_14+0x10a>
    2576:	mov    rax,rsi
    2579:	add    rax,0x2
    257d:	seto   cl
    2580:	test   cl,cl
    2582:	jne    2590 <botlish_fn_14+0x10a>
    2588:	mov    rsi,rax
    258b:	jmp    25a4 <botlish_fn_14+0x11e>
    2590:	mov    edx,0x3
    2595:	mov    rax,QWORD PTR [rip+0x0]        # 259c <botlish_fn_14+0x116>
			2598: R_X86_64_GOTPCREL	rt_int_add-0x4
    259c:	mov    rdi,r14
    259f:	call   rax
    25a1:	mov    rsi,rax
    25a4:	mov    QWORD PTR [r13+0x8],rsi
    25a8:	mov    r15,rsi
    25ab:	mov    rax,QWORD PTR [rip+0x0]        # 25b2 <botlish_fn_14+0x12c>
			25ae: R_X86_64_GOTPCREL	rt_str_cat-0x4
    25b2:	mov    rdx,QWORD PTR [rsp+0x18]
    25b7:	mov    rsi,QWORD PTR [rsp+0x10]
    25bc:	mov    rdi,r14
    25bf:	call   rax
    25c1:	test   rax,rax
    25c4:	jne    25d2 <botlish_fn_14+0x14c>
    25ca:	mov    rdi,r14
    25cd:	jmp    277b <botlish_fn_14+0x2f5>
    25d2:	mov    QWORD PTR [r13+0x0],rbx
    25d6:	mov    rsi,r15
    25d9:	mov    QWORD PTR [r13+0x8],rsi
    25dd:	mov    QWORD PTR [r13+0x10],rax
    25e1:	mov    QWORD PTR [rsp+0x10],rax
    25e6:	jmp    2508 <botlish_fn_14+0x82>
    25eb:	mov    QWORD PTR [r13+0x18],0x3
    25f3:	mov    rsi,r15
    25f6:	test   rsi,0x1
    25fd:	je     2618 <botlish_fn_14+0x192>
    2603:	mov    rsi,r15
    2606:	mov    rdx,rsi
    2609:	add    rdx,0x2
    260d:	seto   al
    2610:	test   al,al
    2612:	je     262f <botlish_fn_14+0x1a9>
    2618:	mov    edx,0x3
    261d:	mov    rax,QWORD PTR [rip+0x0]        # 2624 <botlish_fn_14+0x19e>
			2620: R_X86_64_GOTPCREL	rt_int_add-0x4
    2624:	mov    rsi,r15
    2627:	mov    rdi,r14
    262a:	call   rax
    262c:	mov    rdx,rax
    262f:	mov    QWORD PTR [r13+0x18],rdx
    2633:	mov    rcx,r12
    2636:	mov    rsi,rbx
    2639:	mov    rdi,r14
    263c:	call   2641 <botlish_fn_14+0x1bb>
			263d: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    2641:	test   rax,rax
    2644:	mov    rsi,rax
    2647:	jne    2655 <botlish_fn_14+0x1cf>
    264d:	mov    rdi,r14
    2650:	jmp    277b <botlish_fn_14+0x2f5>
    2655:	mov    rdx,QWORD PTR [rsp]
    2659:	mov    rcx,QWORD PTR [rsp+0x8]
    265e:	mov    rdi,r14
    2661:	mov    rax,QWORD PTR [rdi+0x10]
    2665:	mov    r8,QWORD PTR [rax+0x28]
    2669:	mov    rax,QWORD PTR [rip+0x0]        # 2670 <botlish_fn_14+0x1ea>
			266c: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    2670:	call   rax
    2672:	cmp    rax,0x6
    2676:	je     26f8 <botlish_fn_14+0x272>
    267c:	mov    QWORD PTR [r13+0x0],0x3
    2684:	mov    rsi,r15
    2687:	test   rsi,0x1
    268e:	je     26b1 <botlish_fn_14+0x22b>
    2694:	mov    rsi,r15
    2697:	mov    rdx,rsi
    269a:	add    rdx,0x2
    269e:	seto   al
    26a1:	test   al,al
    26a3:	jne    26b1 <botlish_fn_14+0x22b>
    26a9:	mov    rdi,r14
    26ac:	jmp    26cb <botlish_fn_14+0x245>
    26b1:	mov    edx,0x3
    26b6:	mov    rax,QWORD PTR [rip+0x0]        # 26bd <botlish_fn_14+0x237>
			26b9: R_X86_64_GOTPCREL	rt_int_add-0x4
    26bd:	mov    rsi,r15
    26c0:	mov    rdi,r14
    26c3:	call   rax
    26c5:	mov    rdx,rax
    26c8:	mov    rdi,r14
    26cb:	mov    rdi,r14
    26ce:	mov    QWORD PTR [rdi],r13
    26d1:	mov    rax,QWORD PTR [rsp+0x10]
    26d6:	mov    rbx,QWORD PTR [rsp+0x20]
    26db:	mov    r12,QWORD PTR [rsp+0x28]
    26e0:	mov    r13,QWORD PTR [rsp+0x30]
    26e5:	mov    r14,QWORD PTR [rsp+0x38]
    26ea:	mov    r15,QWORD PTR [rsp+0x40]
    26ef:	add    rsp,0x50
    26f3:	mov    rsp,rbp
    26f6:	pop    rbp
    26f7:	ret
    26f8:	mov    QWORD PTR [r13+0x18],0x5
    2700:	mov    rsi,r15
    2703:	test   rsi,0x1
    270a:	je     2732 <botlish_fn_14+0x2ac>
    2710:	mov    rsi,r15
    2713:	mov    rcx,rsi
    2716:	add    rcx,0x4
    271a:	seto   sil
    271e:	test   sil,sil
    2721:	jne    2732 <botlish_fn_14+0x2ac>
    2727:	mov    rsi,rcx
    272a:	mov    r15,rcx
    272d:	jmp    274d <botlish_fn_14+0x2c7>
    2732:	mov    edx,0x5
    2737:	mov    r8,QWORD PTR [rip+0x0]        # 273e <botlish_fn_14+0x2b8>
			273a: R_X86_64_GOTPCREL	rt_int_add-0x4
    273e:	mov    rsi,r15
    2741:	mov    rdi,r14
    2744:	call   r8
    2747:	mov    rsi,rax
    274a:	mov    r15,rax
    274d:	mov    QWORD PTR [r13+0x8],rsi
    2751:	mov    rdi,r14
    2754:	mov    r8,QWORD PTR [rdi+0x10]
    2758:	mov    rdx,QWORD PTR [r8+0x28]
    275c:	mov    QWORD PTR [r13+0x18],rdx
    2760:	mov    r9,QWORD PTR [rip+0x0]        # 2767 <botlish_fn_14+0x2e1>
			2763: R_X86_64_GOTPCREL	rt_str_cat-0x4
    2767:	mov    rsi,QWORD PTR [rsp+0x10]
    276c:	call   r9
    276f:	test   rax,rax
    2772:	jne    27a9 <botlish_fn_14+0x323>
    2778:	mov    rdi,r14
    277b:	mov    rdi,r14
    277e:	mov    QWORD PTR [rdi],r13
    2781:	xor    rdx,rdx
    2784:	mov    rax,rdx
    2787:	mov    rbx,QWORD PTR [rsp+0x20]
    278c:	mov    r12,QWORD PTR [rsp+0x28]
    2791:	mov    r13,QWORD PTR [rsp+0x30]
    2796:	mov    r14,QWORD PTR [rsp+0x38]
    279b:	mov    r15,QWORD PTR [rsp+0x40]
    27a0:	add    rsp,0x50
    27a4:	mov    rsp,rbp
    27a7:	pop    rbp
    27a8:	ret
    27a9:	mov    QWORD PTR [r13+0x0],rbx
    27ad:	mov    rsi,r15
    27b0:	mov    QWORD PTR [r13+0x8],rsi
    27b4:	mov    QWORD PTR [r13+0x10],rax
    27b8:	mov    QWORD PTR [rsp+0x10],rax
    27bd:	jmp    2508 <botlish_fn_14+0x82>
    27c2:	mov    r14,rdi
    27c5:	mov    rax,QWORD PTR [rip+0x0]        # 27cc <botlish_fn_14+0x346>
			27c8: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    27cc:	call   rax
    27ce:	xor    rdx,rdx
    27d1:	mov    rax,rdx
    27d4:	mov    rbx,QWORD PTR [rsp+0x20]
    27d9:	mov    r12,QWORD PTR [rsp+0x28]
    27de:	mov    r13,QWORD PTR [rsp+0x30]
    27e3:	mov    r14,QWORD PTR [rsp+0x38]
    27e8:	mov    r15,QWORD PTR [rsp+0x40]
    27ed:	add    rsp,0x50
    27f1:	mov    rsp,rbp
    27f4:	pop    rbp
    27f5:	ret

00000000000027f6 <botlish_entry_14: scan_quoted<str, int, str>>:
    27f6:	push   rbp
    27f7:	mov    rbp,rsp
    27fa:	ud2

00000000000027fc <botlish_fn_15: scan_field<str, int>>:
    27fc:	push   rbp
    27fd:	mov    rbp,rsp
    2800:	sub    rsp,0x30
    2804:	mov    QWORD PTR [rsp+0x10],rbx
    2809:	mov    QWORD PTR [rsp+0x18],r12
    280e:	mov    QWORD PTR [rsp+0x20],r13
    2813:	mov    QWORD PTR [rsp+0x28],r14
    2818:	mov    rbx,QWORD PTR [rdi]
    281b:	mov    rax,QWORD PTR [rdi+0x8]
    281f:	lea    rcx,[rbx+0x18]
    2823:	cmp    rcx,rax
    2826:	ja     29a0 <botlish_fn_15+0x1a4>
    282c:	lea    rax,[rbx+0x18]
    2830:	mov    QWORD PTR [rdi],rax
    2833:	mov    r12,rdi
    2836:	mov    QWORD PTR [rbx],0x0
    283d:	mov    QWORD PTR [rbx+0x8],0x0
    2845:	mov    QWORD PTR [rbx+0x10],0x0
    284d:	mov    QWORD PTR [rbx],rsi
    2850:	mov    r13,rsi
    2853:	mov    QWORD PTR [rbx+0x8],rdx
    2857:	mov    r14,rdx
    285a:	lea    rcx,[rsp]
    285e:	mov    rdx,r14
    2861:	mov    rsi,r13
    2864:	mov    rdi,r12
    2867:	call   286c <botlish_fn_15+0x70>
			2868: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    286c:	test   rax,rax
    286f:	mov    rsi,rax
    2872:	jne    2880 <botlish_fn_15+0x84>
    2878:	mov    rdi,r12
    287b:	jmp    2954 <botlish_fn_15+0x158>
    2880:	mov    rdx,QWORD PTR [rsp]
    2884:	mov    rcx,QWORD PTR [rsp+0x8]
    2889:	mov    rdi,r12
    288c:	mov    rax,QWORD PTR [rdi+0x10]
    2890:	mov    r8,QWORD PTR [rax+0x28]
    2894:	mov    rax,QWORD PTR [rip+0x0]        # 289b <botlish_fn_15+0x9f>
			2897: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    289b:	call   rax
    289d:	cmp    rax,0x6
    28a1:	je     28ec <botlish_fn_15+0xf0>
    28a7:	mov    rcx,r14
    28aa:	mov    rsi,r13
    28ad:	mov    rdi,r12
    28b0:	mov    rdx,rcx
    28b3:	call   28b8 <botlish_fn_15+0xbc>
			28b4: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    28b8:	test   rax,rax
    28bb:	jne    28c9 <botlish_fn_15+0xcd>
    28c1:	mov    rdi,r12
    28c4:	jmp    2954 <botlish_fn_15+0x158>
    28c9:	mov    rdi,r12
    28cc:	mov    QWORD PTR [rdi],rbx
    28cf:	mov    rbx,QWORD PTR [rsp+0x10]
    28d4:	mov    r12,QWORD PTR [rsp+0x18]
    28d9:	mov    r13,QWORD PTR [rsp+0x20]
    28de:	mov    r14,QWORD PTR [rsp+0x28]
    28e3:	add    rsp,0x30
    28e7:	mov    rsp,rbp
    28ea:	pop    rbp
    28eb:	ret
    28ec:	mov    QWORD PTR [rbx+0x10],0x3
    28f4:	mov    rdx,r14
    28f7:	test   rdx,0x1
    28fe:	je     2916 <botlish_fn_15+0x11a>
    2904:	mov    rdx,r14
    2907:	add    rdx,0x2
    290b:	seto   al
    290e:	test   al,al
    2910:	je     292d <botlish_fn_15+0x131>
    2916:	mov    edx,0x3
    291b:	mov    rax,QWORD PTR [rip+0x0]        # 2922 <botlish_fn_15+0x126>
			291e: R_X86_64_GOTPCREL	rt_int_add-0x4
    2922:	mov    rsi,r14
    2925:	mov    rdi,r12
    2928:	call   rax
    292a:	mov    rdx,rax
    292d:	mov    QWORD PTR [rbx+0x8],rdx
    2931:	mov    rdi,r12
    2934:	mov    rax,QWORD PTR [rdi+0x10]
    2938:	mov    rcx,QWORD PTR [rax+0x10]
    293c:	mov    QWORD PTR [rbx+0x10],rcx
    2940:	mov    rsi,r13
    2943:	call   2948 <botlish_fn_15+0x14c>
			2944: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    2948:	test   rax,rax
    294b:	jne    297d <botlish_fn_15+0x181>
    2951:	mov    rdi,r12
    2954:	mov    rdi,r12
    2957:	mov    QWORD PTR [rdi],rbx
    295a:	xor    rdx,rdx
    295d:	mov    rax,rdx
    2960:	mov    rbx,QWORD PTR [rsp+0x10]
    2965:	mov    r12,QWORD PTR [rsp+0x18]
    296a:	mov    r13,QWORD PTR [rsp+0x20]
    296f:	mov    r14,QWORD PTR [rsp+0x28]
    2974:	add    rsp,0x30
    2978:	mov    rsp,rbp
    297b:	pop    rbp
    297c:	ret
    297d:	mov    rdi,r12
    2980:	mov    QWORD PTR [rdi],rbx
    2983:	mov    rbx,QWORD PTR [rsp+0x10]
    2988:	mov    r12,QWORD PTR [rsp+0x18]
    298d:	mov    r13,QWORD PTR [rsp+0x20]
    2992:	mov    r14,QWORD PTR [rsp+0x28]
    2997:	add    rsp,0x30
    299b:	mov    rsp,rbp
    299e:	pop    rbp
    299f:	ret
    29a0:	mov    r12,rdi
    29a3:	mov    rsi,QWORD PTR [rip+0x0]        # 29aa <botlish_fn_15+0x1ae>
			29a6: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    29aa:	call   rsi
    29ac:	xor    rdx,rdx
    29af:	mov    rax,rdx
    29b2:	mov    rbx,QWORD PTR [rsp+0x10]
    29b7:	mov    r12,QWORD PTR [rsp+0x18]
    29bc:	mov    r13,QWORD PTR [rsp+0x20]
    29c1:	mov    r14,QWORD PTR [rsp+0x28]
    29c6:	add    rsp,0x30
    29ca:	mov    rsp,rbp
    29cd:	pop    rbp
    29ce:	ret

00000000000029cf <botlish_entry_15: scan_field<str, int>>:
    29cf:	push   rbp
    29d0:	mov    rbp,rsp
    29d3:	ud2

00000000000029d5 <botlish_fn_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    29d5:	push   rbp
    29d6:	mov    rbp,rsp
    29d9:	sub    rsp,0x60
    29dd:	mov    QWORD PTR [rsp+0x30],rbx
    29e2:	mov    QWORD PTR [rsp+0x38],r12
    29e7:	mov    QWORD PTR [rsp+0x40],r13
    29ec:	mov    QWORD PTR [rsp+0x48],r14
    29f1:	mov    QWORD PTR [rsp+0x50],r15
    29f6:	mov    rbx,QWORD PTR [rdi]
    29f9:	mov    rax,QWORD PTR [rdi+0x8]
    29fd:	lea    r8,[rbx+0x20]
    2a01:	cmp    r8,rax
    2a04:	ja     2cc1 <botlish_fn_16+0x2ec>
    2a0a:	lea    rax,[rbx+0x20]
    2a0e:	mov    QWORD PTR [rdi],rax
    2a11:	mov    r14,rdi
    2a14:	mov    QWORD PTR [rbx],0x0
    2a1b:	mov    QWORD PTR [rbx+0x8],0x0
    2a23:	mov    QWORD PTR [rbx+0x10],0x0
    2a2b:	mov    QWORD PTR [rbx+0x18],0x0
    2a33:	mov    QWORD PTR [rbx],rsi
    2a36:	mov    QWORD PTR [rsp+0x10],rsi
    2a3b:	mov    QWORD PTR [rbx+0x8],rdx
    2a3f:	mov    QWORD PTR [rbx+0x10],rcx
    2a43:	mov    r12,rcx
    2a46:	mov    rsi,QWORD PTR [rsp+0x10]
    2a4b:	mov    rdi,r14
    2a4e:	call   2a53 <botlish_fn_16+0x7e>
			2a4f: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    2a53:	test   rax,rax
    2a56:	jne    2a64 <botlish_fn_16+0x8f>
    2a5c:	mov    rdi,r14
    2a5f:	jmp    2c6b <botlish_fn_16+0x296>
    2a64:	mov    QWORD PTR [rbx+0x8],rax
    2a68:	mov    QWORD PTR [rbx+0x18],rdx
    2a6c:	mov    r15,rdx
    2a6f:	mov    rsi,r12
    2a72:	mov    rdx,rax
    2a75:	mov    rdi,r14
    2a78:	call   2a7d <botlish_fn_16+0xa8>
			2a79: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[list<never>, mutarray, int], str>
    2a7d:	test   rax,rax
    2a80:	jne    2a8e <botlish_fn_16+0xb9>
    2a86:	mov    rdi,r14
    2a89:	jmp    2c6b <botlish_fn_16+0x296>
    2a8e:	mov    QWORD PTR [rbx+0x8],rax
    2a92:	mov    QWORD PTR [rsp+0x20],rax
    2a97:	lea    rcx,[rsp]
    2a9b:	mov    rdx,r15
    2a9e:	mov    rsi,QWORD PTR [rsp+0x10]
    2aa3:	mov    rdi,r14
    2aa6:	call   2aab <botlish_fn_16+0xd6>
			2aa7: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    2aab:	test   rax,rax
    2aae:	mov    QWORD PTR [rsp+0x18],rax
    2ab3:	jne    2ac1 <botlish_fn_16+0xec>
    2ab9:	mov    rdi,r14
    2abc:	jmp    2c6b <botlish_fn_16+0x296>
    2ac1:	mov    r13,QWORD PTR [rsp]
    2ac5:	mov    r12,QWORD PTR [rsp+0x8]
    2aca:	mov    rdi,r14
    2acd:	mov    rsi,QWORD PTR [rdi+0x10]
    2ad1:	mov    r8,QWORD PTR [rsi+0x18]
    2ad5:	mov    r9,QWORD PTR [rip+0x0]        # 2adc <botlish_fn_16+0x107>
			2ad8: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    2adc:	mov    rcx,r12
    2adf:	mov    rdx,r13
    2ae2:	mov    rsi,QWORD PTR [rsp+0x18]
    2ae7:	call   r9
    2aea:	cmp    rax,0x6
    2aee:	je     2c05 <botlish_fn_16+0x230>
    2af4:	mov    rdi,r14
    2af7:	mov    rdi,QWORD PTR [rdi+0x10]
    2afb:	mov    r8,QWORD PTR [rdi+0x20]
    2aff:	mov    r9,QWORD PTR [rip+0x0]        # 2b06 <botlish_fn_16+0x131>
			2b02: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    2b06:	mov    rcx,r12
    2b09:	mov    rdx,r13
    2b0c:	mov    rsi,QWORD PTR [rsp+0x18]
    2b11:	mov    rdi,r14
    2b14:	call   r9
    2b17:	cmp    rax,0x6
    2b1b:	je     2b6a <botlish_fn_16+0x195>
    2b21:	mov    rsi,QWORD PTR [rsp+0x20]
    2b26:	mov    rdi,r14
    2b29:	call   2b2e <botlish_fn_16+0x159>
			2b2a: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2b2e:	test   rax,rax
    2b31:	jne    2b3f <botlish_fn_16+0x16a>
    2b37:	mov    rdi,r14
    2b3a:	jmp    2c6b <botlish_fn_16+0x296>
    2b3f:	mov    rdi,r14
    2b42:	mov    QWORD PTR [rdi],rbx
    2b45:	mov    rdx,r15
    2b48:	mov    rbx,QWORD PTR [rsp+0x30]
    2b4d:	mov    r12,QWORD PTR [rsp+0x38]
    2b52:	mov    r13,QWORD PTR [rsp+0x40]
    2b57:	mov    r14,QWORD PTR [rsp+0x48]
    2b5c:	mov    r15,QWORD PTR [rsp+0x50]
    2b61:	add    rsp,0x60
    2b65:	mov    rsp,rbp
    2b68:	pop    rbp
    2b69:	ret
    2b6a:	mov    rsi,QWORD PTR [rsp+0x20]
    2b6f:	mov    rdi,r14
    2b72:	call   2b77 <botlish_fn_16+0x1a2>
			2b73: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2b77:	test   rax,rax
    2b7a:	jne    2b88 <botlish_fn_16+0x1b3>
    2b80:	mov    rdi,r14
    2b83:	jmp    2c6b <botlish_fn_16+0x296>
    2b88:	mov    QWORD PTR [rbx],rax
    2b8b:	mov    r12,rax
    2b8e:	mov    QWORD PTR [rbx+0x8],0x3
    2b96:	mov    rdx,r15
    2b99:	test   rdx,0x1
    2ba0:	je     2bc0 <botlish_fn_16+0x1eb>
    2ba6:	mov    rdx,r15
    2ba9:	add    rdx,0x2
    2bad:	seto   al
    2bb0:	test   al,al
    2bb2:	jne    2bc0 <botlish_fn_16+0x1eb>
    2bb8:	mov    rdi,r14
    2bbb:	jmp    2bda <botlish_fn_16+0x205>
    2bc0:	mov    edx,0x3
    2bc5:	mov    rax,QWORD PTR [rip+0x0]        # 2bcc <botlish_fn_16+0x1f7>
			2bc8: R_X86_64_GOTPCREL	rt_int_add-0x4
    2bcc:	mov    rsi,r15
    2bcf:	mov    rdi,r14
    2bd2:	call   rax
    2bd4:	mov    rdx,rax
    2bd7:	mov    rdi,r14
    2bda:	mov    rdi,r14
    2bdd:	mov    QWORD PTR [rdi],rbx
    2be0:	mov    rax,r12
    2be3:	mov    rbx,QWORD PTR [rsp+0x30]
    2be8:	mov    r12,QWORD PTR [rsp+0x38]
    2bed:	mov    r13,QWORD PTR [rsp+0x40]
    2bf2:	mov    r14,QWORD PTR [rsp+0x48]
    2bf7:	mov    r15,QWORD PTR [rsp+0x50]
    2bfc:	add    rsp,0x60
    2c00:	mov    rsp,rbp
    2c03:	pop    rbp
    2c04:	ret
    2c05:	mov    rsi,r15
    2c08:	mov    edx,0x3
    2c0d:	mov    rcx,rdx
    2c10:	mov    QWORD PTR [rbx+0x10],0x3
    2c18:	test   rsi,0x1
    2c1f:	je     2c37 <botlish_fn_16+0x262>
    2c25:	mov    rdx,rsi
    2c28:	add    rdx,0x2
    2c2c:	seto   al
    2c2f:	test   al,al
    2c31:	je     2c49 <botlish_fn_16+0x274>
    2c37:	mov    rax,QWORD PTR [rip+0x0]        # 2c3e <botlish_fn_16+0x269>
			2c3a: R_X86_64_GOTPCREL	rt_int_add-0x4
    2c3e:	mov    rdx,rcx
    2c41:	mov    rdi,r14
    2c44:	call   rax
    2c46:	mov    rdx,rax
    2c49:	mov    QWORD PTR [rbx+0x10],rdx
    2c4d:	mov    rcx,QWORD PTR [rsp+0x20]
    2c52:	mov    rsi,QWORD PTR [rsp+0x10]
    2c57:	mov    rdi,r14
    2c5a:	call   2c5f <botlish_fn_16+0x28a>
			2c5b: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int, list[list<mutarray>, mutarray, int]>
    2c5f:	test   rax,rax
    2c62:	jne    2c99 <botlish_fn_16+0x2c4>
    2c68:	mov    rdi,r14
    2c6b:	mov    rdi,r14
    2c6e:	mov    QWORD PTR [rdi],rbx
    2c71:	xor    rdx,rdx
    2c74:	mov    rax,rdx
    2c77:	mov    rbx,QWORD PTR [rsp+0x30]
    2c7c:	mov    r12,QWORD PTR [rsp+0x38]
    2c81:	mov    r13,QWORD PTR [rsp+0x40]
    2c86:	mov    r14,QWORD PTR [rsp+0x48]
    2c8b:	mov    r15,QWORD PTR [rsp+0x50]
    2c90:	add    rsp,0x60
    2c94:	mov    rsp,rbp
    2c97:	pop    rbp
    2c98:	ret
    2c99:	mov    rdi,r14
    2c9c:	mov    QWORD PTR [rdi],rbx
    2c9f:	mov    rbx,QWORD PTR [rsp+0x30]
    2ca4:	mov    r12,QWORD PTR [rsp+0x38]
    2ca9:	mov    r13,QWORD PTR [rsp+0x40]
    2cae:	mov    r14,QWORD PTR [rsp+0x48]
    2cb3:	mov    r15,QWORD PTR [rsp+0x50]
    2cb8:	add    rsp,0x60
    2cbc:	mov    rsp,rbp
    2cbf:	pop    rbp
    2cc0:	ret
    2cc1:	mov    r14,rdi
    2cc4:	mov    rax,QWORD PTR [rip+0x0]        # 2ccb <botlish_fn_16+0x2f6>
			2cc7: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2ccb:	call   rax
    2ccd:	xor    rdx,rdx
    2cd0:	mov    rax,rdx
    2cd3:	mov    rbx,QWORD PTR [rsp+0x30]
    2cd8:	mov    r12,QWORD PTR [rsp+0x38]
    2cdd:	mov    r13,QWORD PTR [rsp+0x40]
    2ce2:	mov    r14,QWORD PTR [rsp+0x48]
    2ce7:	mov    r15,QWORD PTR [rsp+0x50]
    2cec:	add    rsp,0x60
    2cf0:	mov    rsp,rbp
    2cf3:	pop    rbp
    2cf4:	ret

0000000000002cf5 <botlish_entry_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    2cf5:	push   rbp
    2cf6:	mov    rbp,rsp
    2cf9:	ud2

0000000000002cfb <botlish_fn_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    2cfb:	push   rbp
    2cfc:	mov    rbp,rsp
    2cff:	sub    rsp,0x60
    2d03:	mov    QWORD PTR [rsp+0x30],rbx
    2d08:	mov    QWORD PTR [rsp+0x38],r12
    2d0d:	mov    QWORD PTR [rsp+0x40],r13
    2d12:	mov    QWORD PTR [rsp+0x48],r14
    2d17:	mov    QWORD PTR [rsp+0x50],r15
    2d1c:	mov    r13,QWORD PTR [rdi]
    2d1f:	mov    rax,QWORD PTR [rdi+0x8]
    2d23:	lea    r8,[r13+0x20]
    2d27:	cmp    r8,rax
    2d2a:	ja     2fec <botlish_fn_17+0x2f1>
    2d30:	lea    rax,[r13+0x20]
    2d34:	mov    QWORD PTR [rdi],rax
    2d37:	mov    QWORD PTR [rsp+0x10],rdi
    2d3c:	mov    QWORD PTR [r13+0x0],0x0
    2d44:	mov    QWORD PTR [r13+0x8],0x0
    2d4c:	mov    QWORD PTR [r13+0x10],0x0
    2d54:	mov    QWORD PTR [r13+0x18],0x0
    2d5c:	mov    QWORD PTR [r13+0x0],rsi
    2d60:	mov    QWORD PTR [r13+0x8],rdx
    2d64:	mov    QWORD PTR [r13+0x10],rcx
    2d68:	lea    rbx,[rsp]
    2d6c:	mov    r12,rsi
    2d6f:	mov    r14,rcx
    2d72:	mov    rsi,r12
    2d75:	mov    rdi,QWORD PTR [rsp+0x10]
    2d7a:	call   2d7f <botlish_fn_17+0x84>
			2d7b: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    2d7f:	test   rax,rax
    2d82:	jne    2d92 <botlish_fn_17+0x97>
    2d88:	mov    rdi,QWORD PTR [rsp+0x10]
    2d8d:	jmp    2ecf <botlish_fn_17+0x1d4>
    2d92:	mov    QWORD PTR [r13+0x8],rax
    2d96:	mov    r11,rax
    2d99:	mov    QWORD PTR [r13+0x18],rdx
    2d9d:	mov    QWORD PTR [rsp+0x28],rdx
    2da2:	mov    rsi,r14
    2da5:	mov    rdx,r11
    2da8:	mov    rdi,QWORD PTR [rsp+0x10]
    2dad:	call   2db2 <botlish_fn_17+0xb7>
			2dae: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], str>
    2db2:	test   rax,rax
    2db5:	jne    2dc5 <botlish_fn_17+0xca>
    2dbb:	mov    rdi,QWORD PTR [rsp+0x10]
    2dc0:	jmp    2ecf <botlish_fn_17+0x1d4>
    2dc5:	mov    QWORD PTR [r13+0x8],rax
    2dc9:	mov    QWORD PTR [rsp+0x20],rax
    2dce:	mov    rcx,rbx
    2dd1:	mov    rdx,QWORD PTR [rsp+0x28]
    2dd6:	mov    rsi,r12
    2dd9:	mov    rdi,QWORD PTR [rsp+0x10]
    2dde:	call   2de3 <botlish_fn_17+0xe8>
			2ddf: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    2de3:	test   rax,rax
    2de6:	mov    QWORD PTR [rsp+0x18],rax
    2deb:	jne    2dfb <botlish_fn_17+0x100>
    2df1:	mov    rdi,QWORD PTR [rsp+0x10]
    2df6:	jmp    2ecf <botlish_fn_17+0x1d4>
    2dfb:	mov    r15,QWORD PTR [rsp]
    2dff:	mov    r14,QWORD PTR [rsp+0x8]
    2e04:	mov    rdi,QWORD PTR [rsp+0x10]
    2e09:	mov    rsi,QWORD PTR [rdi+0x10]
    2e0d:	mov    r8,QWORD PTR [rsi+0x18]
    2e11:	mov    r9,QWORD PTR [rip+0x0]        # 2e18 <botlish_fn_17+0x11d>
			2e14: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    2e18:	mov    rcx,r14
    2e1b:	mov    rdx,r15
    2e1e:	mov    rsi,QWORD PTR [rsp+0x18]
    2e23:	call   r9
    2e26:	cmp    rax,0x6
    2e2a:	je     2f8b <botlish_fn_17+0x290>
    2e30:	mov    rdi,QWORD PTR [rsp+0x10]
    2e35:	mov    rdi,QWORD PTR [rdi+0x10]
    2e39:	mov    r8,QWORD PTR [rdi+0x20]
    2e3d:	mov    r9,QWORD PTR [rip+0x0]        # 2e44 <botlish_fn_17+0x149>
			2e40: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    2e44:	mov    rcx,r14
    2e47:	mov    rdx,r15
    2e4a:	mov    rsi,QWORD PTR [rsp+0x18]
    2e4f:	mov    rdi,QWORD PTR [rsp+0x10]
    2e54:	call   r9
    2e57:	cmp    rax,0x6
    2e5b:	je     2eb2 <botlish_fn_17+0x1b7>
    2e61:	mov    rsi,QWORD PTR [rsp+0x20]
    2e66:	mov    rdi,QWORD PTR [rsp+0x10]
    2e6b:	call   2e70 <botlish_fn_17+0x175>
			2e6c: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2e70:	test   rax,rax
    2e73:	jne    2e83 <botlish_fn_17+0x188>
    2e79:	mov    rdi,QWORD PTR [rsp+0x10]
    2e7e:	jmp    2ecf <botlish_fn_17+0x1d4>
    2e83:	mov    rdi,QWORD PTR [rsp+0x10]
    2e88:	mov    QWORD PTR [rdi],r13
    2e8b:	mov    rdx,QWORD PTR [rsp+0x28]
    2e90:	mov    rbx,QWORD PTR [rsp+0x30]
    2e95:	mov    r12,QWORD PTR [rsp+0x38]
    2e9a:	mov    r13,QWORD PTR [rsp+0x40]
    2e9f:	mov    r14,QWORD PTR [rsp+0x48]
    2ea4:	mov    r15,QWORD PTR [rsp+0x50]
    2ea9:	add    rsp,0x60
    2ead:	mov    rsp,rbp
    2eb0:	pop    rbp
    2eb1:	ret
    2eb2:	mov    rsi,QWORD PTR [rsp+0x20]
    2eb7:	mov    rdi,QWORD PTR [rsp+0x10]
    2ebc:	call   2ec1 <botlish_fn_17+0x1c6>
			2ebd: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2ec1:	test   rax,rax
    2ec4:	jne    2eff <botlish_fn_17+0x204>
    2eca:	mov    rdi,QWORD PTR [rsp+0x10]
    2ecf:	mov    rdi,QWORD PTR [rsp+0x10]
    2ed4:	mov    QWORD PTR [rdi],r13
    2ed7:	xor    rdx,rdx
    2eda:	mov    rax,rdx
    2edd:	mov    rbx,QWORD PTR [rsp+0x30]
    2ee2:	mov    r12,QWORD PTR [rsp+0x38]
    2ee7:	mov    r13,QWORD PTR [rsp+0x40]
    2eec:	mov    r14,QWORD PTR [rsp+0x48]
    2ef1:	mov    r15,QWORD PTR [rsp+0x50]
    2ef6:	add    rsp,0x60
    2efa:	mov    rsp,rbp
    2efd:	pop    rbp
    2efe:	ret
    2eff:	mov    QWORD PTR [r13+0x0],rax
    2f03:	mov    r15,rax
    2f06:	mov    QWORD PTR [r13+0x8],0x3
    2f0e:	mov    rdx,QWORD PTR [rsp+0x28]
    2f13:	test   rdx,0x1
    2f1a:	je     2f3e <botlish_fn_17+0x243>
    2f20:	mov    rdx,QWORD PTR [rsp+0x28]
    2f25:	add    rdx,0x2
    2f29:	seto   al
    2f2c:	test   al,al
    2f2e:	jne    2f3e <botlish_fn_17+0x243>
    2f34:	mov    rdi,QWORD PTR [rsp+0x10]
    2f39:	jmp    2f5e <botlish_fn_17+0x263>
    2f3e:	mov    edx,0x3
    2f43:	mov    rax,QWORD PTR [rip+0x0]        # 2f4a <botlish_fn_17+0x24f>
			2f46: R_X86_64_GOTPCREL	rt_int_add-0x4
    2f4a:	mov    rsi,QWORD PTR [rsp+0x28]
    2f4f:	mov    rdi,QWORD PTR [rsp+0x10]
    2f54:	call   rax
    2f56:	mov    rdx,rax
    2f59:	mov    rdi,QWORD PTR [rsp+0x10]
    2f5e:	mov    rdi,QWORD PTR [rsp+0x10]
    2f63:	mov    QWORD PTR [rdi],r13
    2f66:	mov    rax,r15
    2f69:	mov    rbx,QWORD PTR [rsp+0x30]
    2f6e:	mov    r12,QWORD PTR [rsp+0x38]
    2f73:	mov    r13,QWORD PTR [rsp+0x40]
    2f78:	mov    r14,QWORD PTR [rsp+0x48]
    2f7d:	mov    r15,QWORD PTR [rsp+0x50]
    2f82:	add    rsp,0x60
    2f86:	mov    rsp,rbp
    2f89:	pop    rbp
    2f8a:	ret
    2f8b:	mov    rsi,QWORD PTR [rsp+0x28]
    2f90:	mov    edx,0x3
    2f95:	mov    r9,rdx
    2f98:	mov    QWORD PTR [r13+0x10],0x3
    2fa0:	test   rsi,0x1
    2fa7:	je     2fbf <botlish_fn_17+0x2c4>
    2fad:	mov    rdx,rsi
    2fb0:	add    rdx,0x2
    2fb4:	seto   al
    2fb7:	test   al,al
    2fb9:	je     2fd3 <botlish_fn_17+0x2d8>
    2fbf:	mov    rax,QWORD PTR [rip+0x0]        # 2fc6 <botlish_fn_17+0x2cb>
			2fc2: R_X86_64_GOTPCREL	rt_int_add-0x4
    2fc6:	mov    rdx,r9
    2fc9:	mov    rdi,QWORD PTR [rsp+0x10]
    2fce:	call   rax
    2fd0:	mov    rdx,rax
    2fd3:	mov    QWORD PTR [r13+0x0],r12
    2fd7:	mov    QWORD PTR [r13+0x8],rdx
    2fdb:	mov    rsi,QWORD PTR [rsp+0x20]
    2fe0:	mov    QWORD PTR [r13+0x10],rsi
    2fe4:	mov    r14,rsi
    2fe7:	jmp    2d72 <botlish_fn_17+0x77>
    2fec:	mov    QWORD PTR [rsp+0x10],rdi
    2ff1:	mov    rax,QWORD PTR [rip+0x0]        # 2ff8 <botlish_fn_17+0x2fd>
			2ff4: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2ff8:	call   rax
    2ffa:	xor    rdx,rdx
    2ffd:	mov    rax,rdx
    3000:	mov    rbx,QWORD PTR [rsp+0x30]
    3005:	mov    r12,QWORD PTR [rsp+0x38]
    300a:	mov    r13,QWORD PTR [rsp+0x40]
    300f:	mov    r14,QWORD PTR [rsp+0x48]
    3014:	mov    r15,QWORD PTR [rsp+0x50]
    3019:	add    rsp,0x60
    301d:	mov    rsp,rbp
    3020:	pop    rbp
    3021:	ret

0000000000003022 <botlish_entry_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    3022:	push   rbp
    3023:	mov    rbp,rsp
    3026:	ud2

0000000000003028 <botlish_fn_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    3028:	push   rbp
    3029:	mov    rbp,rsp
    302c:	sub    rsp,0x30
    3030:	mov    QWORD PTR [rsp],rbx
    3034:	mov    QWORD PTR [rsp+0x8],r12
    3039:	mov    QWORD PTR [rsp+0x10],r13
    303e:	mov    QWORD PTR [rsp+0x18],r14
    3043:	mov    QWORD PTR [rsp+0x20],r15
    3048:	mov    rbx,QWORD PTR [rdi]
    304b:	mov    rax,QWORD PTR [rdi+0x8]
    304f:	lea    r8,[rbx+0x20]
    3053:	cmp    r8,rax
    3056:	ja     31db <botlish_fn_18+0x1b3>
    305c:	lea    rax,[rbx+0x20]
    3060:	mov    QWORD PTR [rdi],rax
    3063:	mov    r12,rdi
    3066:	mov    QWORD PTR [rbx],0x0
    306d:	mov    QWORD PTR [rbx+0x8],0x0
    3075:	mov    QWORD PTR [rbx+0x10],0x0
    307d:	mov    QWORD PTR [rbx+0x18],0x0
    3085:	mov    QWORD PTR [rbx],rsi
    3088:	mov    r13,rsi
    308b:	mov    QWORD PTR [rbx+0x8],rdx
    308f:	mov    r15,rdx
    3092:	mov    QWORD PTR [rbx+0x10],rcx
    3096:	mov    r14,rcx
    3099:	mov    rax,QWORD PTR [rip+0x0]        # 30a0 <botlish_fn_18+0x78>
			309c: R_X86_64_GOTPCREL	rt_str_len-0x4
    30a0:	mov    rsi,r13
    30a3:	mov    rdi,r12
    30a6:	call   rax
    30a8:	mov    rdx,r15
    30ab:	mov    rcx,rdx
    30ae:	sar    rcx,1
    30b1:	sar    rax,1
    30b4:	cmp    rcx,rax
    30b7:	jge    3173 <botlish_fn_18+0x14b>
    30bd:	mov    rdi,r12
    30c0:	call   30c5 <botlish_fn_18+0x9d>
			30c1: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    30c5:	test   rax,rax
    30c8:	jne    30d6 <botlish_fn_18+0xae>
    30ce:	mov    rdi,r12
    30d1:	jmp    318a <botlish_fn_18+0x162>
    30d6:	mov    QWORD PTR [rbx+0x18],rax
    30da:	mov    rcx,rax
    30dd:	mov    rdx,r15
    30e0:	mov    rsi,r13
    30e3:	mov    rdi,r12
    30e6:	call   30eb <botlish_fn_18+0xc3>
			30e7: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    30eb:	test   rax,rax
    30ee:	jne    30fc <botlish_fn_18+0xd4>
    30f4:	mov    rdi,r12
    30f7:	jmp    318a <botlish_fn_18+0x162>
    30fc:	mov    QWORD PTR [rbx+0x8],rax
    3100:	mov    QWORD PTR [rbx+0x18],rdx
    3104:	mov    rsi,r14
    3107:	mov    r14,rdx
    310a:	mov    rdx,rax
    310d:	mov    rdi,r12
    3110:	call   3115 <botlish_fn_18+0xed>
			3111: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[list<never>, mutarray, int], list>
    3115:	test   rax,rax
    3118:	jne    3126 <botlish_fn_18+0xfe>
    311e:	mov    rdi,r12
    3121:	jmp    318a <botlish_fn_18+0x162>
    3126:	mov    QWORD PTR [rbx+0x8],rax
    312a:	mov    rcx,rax
    312d:	mov    rdx,r14
    3130:	mov    rsi,r13
    3133:	mov    rdi,r12
    3136:	call   313b <botlish_fn_18+0x113>
			3137: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    313b:	test   rax,rax
    313e:	jne    314c <botlish_fn_18+0x124>
    3144:	mov    rdi,r12
    3147:	jmp    318a <botlish_fn_18+0x162>
    314c:	mov    rdi,r12
    314f:	mov    QWORD PTR [rdi],rbx
    3152:	mov    rbx,QWORD PTR [rsp]
    3156:	mov    r12,QWORD PTR [rsp+0x8]
    315b:	mov    r13,QWORD PTR [rsp+0x10]
    3160:	mov    r14,QWORD PTR [rsp+0x18]
    3165:	mov    r15,QWORD PTR [rsp+0x20]
    316a:	add    rsp,0x30
    316e:	mov    rsp,rbp
    3171:	pop    rbp
    3172:	ret
    3173:	mov    rsi,r14
    3176:	mov    rdi,r12
    3179:	call   317e <botlish_fn_18+0x156>
			317a: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    317e:	test   rax,rax
    3181:	jne    31b4 <botlish_fn_18+0x18c>
    3187:	mov    rdi,r12
    318a:	mov    rdi,r12
    318d:	mov    QWORD PTR [rdi],rbx
    3190:	xor    rax,rax
    3193:	mov    rbx,QWORD PTR [rsp]
    3197:	mov    r12,QWORD PTR [rsp+0x8]
    319c:	mov    r13,QWORD PTR [rsp+0x10]
    31a1:	mov    r14,QWORD PTR [rsp+0x18]
    31a6:	mov    r15,QWORD PTR [rsp+0x20]
    31ab:	add    rsp,0x30
    31af:	mov    rsp,rbp
    31b2:	pop    rbp
    31b3:	ret
    31b4:	mov    rdi,r12
    31b7:	mov    QWORD PTR [rdi],rbx
    31ba:	mov    rbx,QWORD PTR [rsp]
    31be:	mov    r12,QWORD PTR [rsp+0x8]
    31c3:	mov    r13,QWORD PTR [rsp+0x10]
    31c8:	mov    r14,QWORD PTR [rsp+0x18]
    31cd:	mov    r15,QWORD PTR [rsp+0x20]
    31d2:	add    rsp,0x30
    31d6:	mov    rsp,rbp
    31d9:	pop    rbp
    31da:	ret
    31db:	mov    r12,rdi
    31de:	mov    rax,QWORD PTR [rip+0x0]        # 31e5 <botlish_fn_18+0x1bd>
			31e1: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    31e5:	call   rax
    31e7:	xor    rax,rax
    31ea:	mov    rbx,QWORD PTR [rsp]
    31ee:	mov    r12,QWORD PTR [rsp+0x8]
    31f3:	mov    r13,QWORD PTR [rsp+0x10]
    31f8:	mov    r14,QWORD PTR [rsp+0x18]
    31fd:	mov    r15,QWORD PTR [rsp+0x20]
    3202:	add    rsp,0x30
    3206:	mov    rsp,rbp
    3209:	pop    rbp
    320a:	ret

000000000000320b <botlish_entry_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    320b:	push   rbp
    320c:	mov    rbp,rsp
    320f:	mov    rsi,QWORD PTR [rdx]
    3212:	mov    r8,QWORD PTR [rdx+0x8]
    3216:	mov    rcx,QWORD PTR [rdx+0x10]
    321a:	mov    rdx,r8
    321d:	call   3222 <botlish_entry_18+0x17>
			321e: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    3222:	mov    rsp,rbp
    3225:	pop    rbp
    3226:	ret
	...

0000000000003228 <botlish_fn_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    3228:	push   rbp
    3229:	mov    rbp,rsp
    322c:	sub    rsp,0x30
    3230:	mov    QWORD PTR [rsp],rbx
    3234:	mov    QWORD PTR [rsp+0x8],r12
    3239:	mov    QWORD PTR [rsp+0x10],r13
    323e:	mov    QWORD PTR [rsp+0x18],r14
    3243:	mov    QWORD PTR [rsp+0x20],r15
    3248:	mov    r12,QWORD PTR [rdi]
    324b:	mov    rax,QWORD PTR [rdi+0x8]
    324f:	lea    r8,[r12+0x20]
    3254:	cmp    r8,rax
    3257:	ja     33f5 <botlish_fn_19+0x1cd>
    325d:	lea    rax,[r12+0x20]
    3262:	mov    QWORD PTR [rdi],rax
    3265:	mov    r14,rdi
    3268:	mov    QWORD PTR [r12],0x0
    3270:	mov    QWORD PTR [r12+0x8],0x0
    3279:	mov    QWORD PTR [r12+0x10],0x0
    3282:	mov    QWORD PTR [r12+0x18],0x0
    328b:	mov    QWORD PTR [r12],rsi
    328f:	mov    QWORD PTR [r12+0x8],rdx
    3294:	mov    r13,rdx
    3297:	mov    QWORD PTR [r12+0x10],rcx
    329c:	mov    r15,rcx
    329f:	mov    rax,QWORD PTR [rip+0x0]        # 32a6 <botlish_fn_19+0x7e>
			32a2: R_X86_64_GOTPCREL	rt_str_len-0x4
    32a6:	mov    rbx,rsi
    32a9:	mov    rdi,r14
    32ac:	call   rax
    32ae:	mov    rcx,r13
    32b1:	and    rcx,rax
    32b4:	mov    rdx,rax
    32b7:	test   rcx,0x1
    32be:	jne    32e8 <botlish_fn_19+0xc0>
    32c4:	mov    rax,QWORD PTR [rip+0x0]        # 32cb <botlish_fn_19+0xa3>
			32c7: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    32cb:	mov    rsi,r13
    32ce:	mov    rdi,r14
    32d1:	call   rax
    32d3:	mov    ecx,0x2
    32d8:	test   rax,rax
    32db:	cmovge rcx,QWORD PTR [rip+0x145]        # 3428 <botlish_fn_19+0x200>
    32e3:	jmp    32fb <botlish_fn_19+0xd3>
    32e8:	mov    ecx,0x2
    32ed:	mov    r11,r13
    32f0:	cmp    r11,rdx
    32f3:	cmovge rcx,QWORD PTR [rip+0x12d]        # 3428 <botlish_fn_19+0x200>
    32fb:	cmp    rcx,0x6
    32ff:	je     338d <botlish_fn_19+0x165>
    3305:	mov    rdi,r14
    3308:	call   330d <botlish_fn_19+0xe5>
			3309: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    330d:	test   rax,rax
    3310:	jne    331e <botlish_fn_19+0xf6>
    3316:	mov    rdi,r14
    3319:	jmp    33a4 <botlish_fn_19+0x17c>
    331e:	mov    QWORD PTR [r12+0x18],rax
    3323:	mov    rcx,rax
    3326:	mov    rdx,r13
    3329:	mov    rsi,rbx
    332c:	mov    rdi,r14
    332f:	call   3334 <botlish_fn_19+0x10c>
			3330: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    3334:	test   rax,rax
    3337:	jne    3345 <botlish_fn_19+0x11d>
    333d:	mov    rdi,r14
    3340:	jmp    33a4 <botlish_fn_19+0x17c>
    3345:	mov    QWORD PTR [r12+0x8],rax
    334a:	mov    QWORD PTR [r12+0x18],rdx
    334f:	mov    r13,rdx
    3352:	mov    rsi,r15
    3355:	mov    rdx,rax
    3358:	mov    rdi,r14
    335b:	call   3360 <botlish_fn_19+0x138>
			335c: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], list>
    3360:	test   rax,rax
    3363:	jne    3371 <botlish_fn_19+0x149>
    3369:	mov    rdi,r14
    336c:	jmp    33a4 <botlish_fn_19+0x17c>
    3371:	mov    QWORD PTR [r12],rbx
    3375:	mov    rdx,r13
    3378:	mov    QWORD PTR [r12+0x8],rdx
    337d:	mov    QWORD PTR [r12+0x10],rax
    3382:	mov    rsi,rbx
    3385:	mov    r15,rax
    3388:	jmp    329f <botlish_fn_19+0x77>
    338d:	mov    rsi,r15
    3390:	mov    rdi,r14
    3393:	call   3398 <botlish_fn_19+0x170>
			3394: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    3398:	test   rax,rax
    339b:	jne    33ce <botlish_fn_19+0x1a6>
    33a1:	mov    rdi,r14
    33a4:	mov    rdi,r14
    33a7:	mov    QWORD PTR [rdi],r12
    33aa:	xor    rax,rax
    33ad:	mov    rbx,QWORD PTR [rsp]
    33b1:	mov    r12,QWORD PTR [rsp+0x8]
    33b6:	mov    r13,QWORD PTR [rsp+0x10]
    33bb:	mov    r14,QWORD PTR [rsp+0x18]
    33c0:	mov    r15,QWORD PTR [rsp+0x20]
    33c5:	add    rsp,0x30
    33c9:	mov    rsp,rbp
    33cc:	pop    rbp
    33cd:	ret
    33ce:	mov    rdi,r14
    33d1:	mov    QWORD PTR [rdi],r12
    33d4:	mov    rbx,QWORD PTR [rsp]
    33d8:	mov    r12,QWORD PTR [rsp+0x8]
    33dd:	mov    r13,QWORD PTR [rsp+0x10]
    33e2:	mov    r14,QWORD PTR [rsp+0x18]
    33e7:	mov    r15,QWORD PTR [rsp+0x20]
    33ec:	add    rsp,0x30
    33f0:	mov    rsp,rbp
    33f3:	pop    rbp
    33f4:	ret
    33f5:	mov    r14,rdi
    33f8:	mov    r10,QWORD PTR [rip+0x0]        # 33ff <botlish_fn_19+0x1d7>
			33fb: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    33ff:	call   r10
    3402:	xor    rax,rax
    3405:	mov    rbx,QWORD PTR [rsp]
    3409:	mov    r12,QWORD PTR [rsp+0x8]
    340e:	mov    r13,QWORD PTR [rsp+0x10]
    3413:	mov    r14,QWORD PTR [rsp+0x18]
    3418:	mov    r15,QWORD PTR [rsp+0x20]
    341d:	add    rsp,0x30
    3421:	mov    rsp,rbp
    3424:	pop    rbp
    3425:	ret
    3426:	add    BYTE PTR [rax],al
    3428:	(bad)
    3429:	add    BYTE PTR [rax],al
    342b:	add    BYTE PTR [rax],al
    342d:	add    BYTE PTR [rax],al
	...

0000000000003430 <botlish_entry_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    3430:	push   rbp
    3431:	mov    rbp,rsp
    3434:	mov    rsi,QWORD PTR [rdx]
    3437:	mov    r8,QWORD PTR [rdx+0x8]
    343b:	mov    rcx,QWORD PTR [rdx+0x10]
    343f:	mov    rdx,r8
    3442:	call   3447 <botlish_entry_19+0x17>
			3443: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    3447:	mov    rsp,rbp
    344a:	pop    rbp
    344b:	ret

000000000000344c <botlish_fn_20: csv_parse<str>>:
    344c:	push   rbp
    344d:	mov    rbp,rsp
    3450:	sub    rsp,0x20
    3454:	mov    QWORD PTR [rsp],rbx
    3458:	mov    QWORD PTR [rsp+0x8],r12
    345d:	mov    QWORD PTR [rsp+0x10],r15
    3462:	mov    r15,QWORD PTR [rdi]
    3465:	mov    rax,QWORD PTR [rdi+0x8]
    3469:	lea    rcx,[r15+0x18]
    346d:	cmp    rcx,rax
    3470:	ja     351e <botlish_fn_20+0xd2>
    3476:	lea    rax,[r15+0x18]
    347a:	mov    QWORD PTR [rdi],rax
    347d:	mov    rbx,rdi
    3480:	mov    QWORD PTR [r15],0x0
    3487:	mov    QWORD PTR [r15+0x8],0x0
    348f:	mov    QWORD PTR [r15+0x10],0x0
    3497:	mov    QWORD PTR [r15],rsi
    349a:	mov    r12,rsi
    349d:	mov    QWORD PTR [r15+0x8],0x1
    34a5:	mov    rdi,rbx
    34a8:	call   34ad <botlish_fn_20+0x61>
			34a9: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    34ad:	test   rax,rax
    34b0:	jne    34be <botlish_fn_20+0x72>
    34b6:	mov    rdi,rbx
    34b9:	jmp    34e1 <botlish_fn_20+0x95>
    34be:	mov    QWORD PTR [r15+0x10],rax
    34c2:	mov    rcx,rax
    34c5:	mov    edx,0x1
    34ca:	mov    rsi,r12
    34cd:	mov    rdi,rbx
    34d0:	call   34d5 <botlish_fn_20+0x89>
			34d1: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    34d5:	test   rax,rax
    34d8:	jne    3501 <botlish_fn_20+0xb5>
    34de:	mov    rdi,rbx
    34e1:	mov    rdi,rbx
    34e4:	mov    QWORD PTR [rdi],r15
    34e7:	xor    rax,rax
    34ea:	mov    rbx,QWORD PTR [rsp]
    34ee:	mov    r12,QWORD PTR [rsp+0x8]
    34f3:	mov    r15,QWORD PTR [rsp+0x10]
    34f8:	add    rsp,0x20
    34fc:	mov    rsp,rbp
    34ff:	pop    rbp
    3500:	ret
    3501:	mov    rdi,rbx
    3504:	mov    QWORD PTR [rdi],r15
    3507:	mov    rbx,QWORD PTR [rsp]
    350b:	mov    r12,QWORD PTR [rsp+0x8]
    3510:	mov    r15,QWORD PTR [rsp+0x10]
    3515:	add    rsp,0x20
    3519:	mov    rsp,rbp
    351c:	pop    rbp
    351d:	ret
    351e:	mov    rbx,rdi
    3521:	mov    rax,QWORD PTR [rip+0x0]        # 3528 <botlish_fn_20+0xdc>
			3524: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3528:	call   rax
    352a:	xor    rax,rax
    352d:	mov    rbx,QWORD PTR [rsp]
    3531:	mov    r12,QWORD PTR [rsp+0x8]
    3536:	mov    r15,QWORD PTR [rsp+0x10]
    353b:	add    rsp,0x20
    353f:	mov    rsp,rbp
    3542:	pop    rbp
    3543:	ret

0000000000003544 <botlish_entry_20: csv_parse<str>>:
    3544:	push   rbp
    3545:	mov    rbp,rsp
    3548:	mov    rsi,QWORD PTR [rdx]
    354b:	call   3550 <botlish_entry_20+0xc>
			354c: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    3550:	mov    rsp,rbp
    3553:	pop    rbp
    3554:	ret

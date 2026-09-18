; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 30423  (per function: 172 184 485 541 422 422 422 198 493 558 697 913 481 886 616 283 85 85 85 85 548 696 208 597 278 184 255 184 255 184 255 184 255 184 269 269 299 299 355 355 1036 1568 581 596 639 1433 945 961 833 1528 1132 243 908 474 845 701 196 196 1382)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> geo_new<generic>
;   botlish_fn_2 / botlish_entry_2 -> geo_new_capacity<int, int>
;   botlish_fn_3 / botlish_entry_3 -> geo_grow<mutarray, int>
;   botlish_fn_4 / botlish_entry_4 -> geo_append<list[mutarray, int], str>
;   botlish_fn_5 / botlish_entry_5 -> geo_append<list[mutarray, int], list>
;   botlish_fn_6 / botlish_entry_6 -> geo_append<list[mutarray, int], mutarray>
;   botlish_fn_7 / botlish_entry_7 -> geo_finish<list[mutarray, int]>
;   botlish_fn_8 / botlish_entry_8 -> peek<str, int>
;   botlish_fn_9 / botlish_entry_9 -> peek<str, int>
;   botlish_fn_10 / botlish_entry_10 -> scan_unquoted<str, int, int>
;   botlish_fn_11 / botlish_entry_11 -> scan_quoted<str, int, str>
;   botlish_fn_12 / botlish_entry_12 -> scan_field<str, int>
;   botlish_fn_13 / botlish_entry_13 -> scan_record<str, int, list[mutarray, int]>
;   botlish_fn_14 / botlish_entry_14 -> scan_records<str, int, list[mutarray, int]>
;   botlish_fn_15 / botlish_entry_15 -> csv_parse<str>
;   botlish_fn_16 / botlish_entry_16 -> ht_min_capacity<generic>
;   botlish_fn_17 / botlish_entry_17 -> ht_empty_state<generic>
;   botlish_fn_18 / botlish_entry_18 -> ht_occupied_state<generic>
;   botlish_fn_19 / botlish_entry_19 -> ht_tombstone_state<generic>
;   botlish_fn_20 / botlish_entry_20 -> ht_fill_empty<mutarray, int, int>
;   botlish_fn_21 / botlish_entry_21 -> ht_alloc<int>
;   botlish_fn_22 / botlish_entry_22 -> ht_new<generic>
;   botlish_fn_23 / botlish_entry_23 -> ht_capacity_for<int, int>
;   botlish_fn_24 / botlish_entry_24 -> ht_new_sized<int>
;   botlish_fn_25 / botlish_entry_25 -> ht_controls<mutarray>
;   botlish_fn_26 / botlish_entry_26 -> ht_controls<generic>
;   botlish_fn_27 / botlish_entry_27 -> ht_keys<mutarray>
;   botlish_fn_28 / botlish_entry_28 -> ht_keys<generic>
;   botlish_fn_29 / botlish_entry_29 -> ht_values<mutarray>
;   botlish_fn_30 / botlish_entry_30 -> ht_values<generic>
;   botlish_fn_31 / botlish_entry_31 -> ht_size<mutarray>
;   botlish_fn_32 / botlish_entry_32 -> ht_size<generic>
;   botlish_fn_33 / botlish_entry_33 -> ht_tombstones<mutarray>
;   botlish_fn_34 / botlish_entry_34 -> ht_capacity<mutarray>
;   botlish_fn_35 / botlish_entry_35 -> ht_capacity<generic>
;   botlish_fn_36 / botlish_entry_36 -> ht_probe_start<mutarray, any>
;   botlish_fn_37 / botlish_entry_37 -> ht_probe_start<any, str>
;   botlish_fn_38 / botlish_entry_38 -> ht_probe_next<mutarray, int>
;   botlish_fn_39 / botlish_entry_39 -> ht_probe_next<any, int>
;   botlish_fn_40 / botlish_entry_40 -> ht_find_get<any, str, int>
;   botlish_fn_41 / botlish_entry_41 -> ht_find_insert<mutarray, any, int, int>
;   botlish_fn_42 / botlish_entry_42 -> ht_get<any, str>
;   botlish_fn_43 / botlish_entry_43 -> ht_rehash_probe<mutarray, int, int>
;   botlish_fn_44 / botlish_entry_44 -> ht_rehash_insert<list<mutarray>, int, any, any>
;   botlish_fn_45 / botlish_entry_45 -> ht_rehash_scan<list, int, int, list<mutarray>, int>
;   botlish_fn_46 / botlish_entry_46 -> ht_rehash<mutarray, int>
;   botlish_fn_47 / botlish_entry_47 -> ht_should_grow<mutarray>
;   botlish_fn_48 / botlish_entry_48 -> ht_grow_or_clean<mutarray>
;   botlish_fn_49 / botlish_entry_49 -> ht_place<mutarray, int, any, any>
;   botlish_fn_50 / botlish_entry_50 -> ht_set<mutarray, any, any>
;   botlish_fn_51 / botlish_entry_51 -> row_new<bool, int>
;   botlish_fn_52 / botlish_entry_52 -> row_fill<mutarray, any, any, int, int>
;   botlish_fn_53 / botlish_entry_53 -> row_table<any, int, any, bool>
;   botlish_fn_54 / botlish_entry_54 -> build_rows<list, int, any, int, list[mutarray, int], bool>
;   botlish_fn_55 / botlish_entry_55 -> csv_records_generic<str, bool>
;   botlish_fn_56 / botlish_entry_56 -> csv_records<str>
;   botlish_fn_57 / botlish_entry_57 -> csv_records_presized<str>
;   botlish_fn_58 / botlish_entry_58 -> sample<generic>


csv_records.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x10
       8:	mov    QWORD PTR [rsp],r12
       c:	mov    QWORD PTR [rsp+0x8],r13
      11:	mov    r12,QWORD PTR [rdi]
      14:	mov    rax,QWORD PTR [rdi+0x8]
      18:	lea    rcx,[r12+0x8]
      1d:	cmp    rcx,rax
      20:	ja     7d <botlish_fn_0+0x7d>
      26:	lea    rax,[r12+0x8]
      2b:	mov    QWORD PTR [rdi],rax
      2e:	mov    r13,rdi
      31:	mov    QWORD PTR [r12],0x0
      39:	mov    rdi,r13
      3c:	call   41 <botlish_fn_0+0x41>
			3d: R_X86_64_PLT32	botlish_fn_58-0x4 ; sample<generic>
      41:	test   rax,rax
      44:	jne    65 <botlish_fn_0+0x65>
      4a:	mov    rdi,r13
      4d:	mov    QWORD PTR [rdi],r12
      50:	xor    rax,rax
      53:	mov    r12,QWORD PTR [rsp]
      57:	mov    r13,QWORD PTR [rsp+0x8]
      5c:	add    rsp,0x10
      60:	mov    rsp,rbp
      63:	pop    rbp
      64:	ret
      65:	mov    rdi,r13
      68:	mov    QWORD PTR [rdi],r12
      6b:	mov    r12,QWORD PTR [rsp]
      6f:	mov    r13,QWORD PTR [rsp+0x8]
      74:	add    rsp,0x10
      78:	mov    rsp,rbp
      7b:	pop    rbp
      7c:	ret
      7d:	mov    rax,QWORD PTR [rip+0x0]        # 84 <botlish_fn_0+0x84>
			80: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
      84:	call   rax
      86:	xor    rax,rax
      89:	mov    r12,QWORD PTR [rsp]
      8d:	mov    r13,QWORD PTR [rsp+0x8]
      92:	add    rsp,0x10
      96:	mov    rsp,rbp
      99:	pop    rbp
      9a:	ret

000000000000009b <botlish_entry_0: <program entry>>:
      9b:	push   rbp
      9c:	mov    rbp,rsp
      9f:	call   a4 <botlish_entry_0+0x9>
			a0: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      a4:	mov    rsp,rbp
      a7:	pop    rbp
      a8:	ret

00000000000000a9 <botlish_fn_1: geo_new<generic>>:
      a9:	push   rbp
      aa:	mov    rbp,rsp
      ad:	sub    rsp,0x10
      b1:	mov    QWORD PTR [rsp],rbx
      b5:	mov    QWORD PTR [rsp+0x8],r15
      ba:	mov    r15,QWORD PTR [rdi]
      bd:	mov    rax,QWORD PTR [rdi+0x8]
      c1:	lea    rcx,[r15+0x8]
      c5:	cmp    rcx,rax
      c8:	ja     134 <botlish_fn_1+0x8b>
      ce:	lea    rax,[r15+0x8]
      d2:	mov    QWORD PTR [rdi],rax
      d5:	mov    rbx,rdi
      d8:	mov    esi,0x1
      dd:	mov    QWORD PTR [r15],0x1
      e4:	mov    rax,QWORD PTR [rip+0x0]        # eb <botlish_fn_1+0x42>
			e7: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
      eb:	mov    rdi,rbx
      ee:	call   rax
      f0:	test   rax,rax
      f3:	jne    117 <botlish_fn_1+0x6e>
      f9:	mov    rdi,rbx
      fc:	mov    QWORD PTR [rdi],r15
      ff:	xor    rdx,rdx
     102:	mov    rax,rdx
     105:	mov    rbx,QWORD PTR [rsp]
     109:	mov    r15,QWORD PTR [rsp+0x8]
     10e:	add    rsp,0x10
     112:	mov    rsp,rbp
     115:	pop    rbp
     116:	ret
     117:	mov    rdi,rbx
     11a:	mov    QWORD PTR [rdi],r15
     11d:	mov    edx,0x1
     122:	mov    rbx,QWORD PTR [rsp]
     126:	mov    r15,QWORD PTR [rsp+0x8]
     12b:	add    rsp,0x10
     12f:	mov    rsp,rbp
     132:	pop    rbp
     133:	ret
     134:	mov    rax,QWORD PTR [rip+0x0]        # 13b <botlish_fn_1+0x92>
			137: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     13b:	call   rax
     13d:	xor    rdx,rdx
     140:	mov    rax,rdx
     143:	mov    rbx,QWORD PTR [rsp]
     147:	mov    r15,QWORD PTR [rsp+0x8]
     14c:	add    rsp,0x10
     150:	mov    rsp,rbp
     153:	pop    rbp
     154:	ret

0000000000000155 <botlish_entry_1: geo_new<generic>>:
     155:	push   rbp
     156:	mov    rbp,rsp
     159:	ud2
     15b:	add    BYTE PTR [rax],al
     15d:	add    BYTE PTR [rax],al
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

0000000000000887 <botlish_fn_6: geo_append<list[mutarray, int], mutarray>>:
     887:	push   rbp
     888:	mov    rbp,rsp
     88b:	sub    rsp,0x30
     88f:	mov    QWORD PTR [rsp],rbx
     893:	mov    QWORD PTR [rsp+0x8],r12
     898:	mov    QWORD PTR [rsp+0x10],r13
     89d:	mov    QWORD PTR [rsp+0x18],r14
     8a2:	mov    QWORD PTR [rsp+0x20],r15
     8a7:	mov    r12,QWORD PTR [rdi]
     8aa:	mov    r8,QWORD PTR [rdi+0x8]
     8ae:	lea    rax,[r12+0x18]
     8b3:	cmp    rax,r8
     8b6:	ja     9eb <botlish_fn_6+0x164>
     8bc:	lea    rax,[r12+0x18]
     8c1:	mov    QWORD PTR [rdi],rax
     8c4:	mov    r13,rdi
     8c7:	mov    QWORD PTR [r12],0x0
     8cf:	mov    QWORD PTR [r12+0x8],0x0
     8d8:	mov    QWORD PTR [r12+0x10],0x0
     8e1:	mov    QWORD PTR [r12],rsi
     8e5:	mov    QWORD PTR [r12+0x8],rdx
     8ea:	mov    rdi,rdx
     8ed:	mov    QWORD PTR [r12+0x10],rcx
     8f2:	mov    r15,rcx
     8f5:	mov    rbx,rdi
     8f8:	mov    rdx,rbx
     8fb:	mov    rdi,r13
     8fe:	call   903 <botlish_fn_6+0x7c>
			8ff: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     903:	test   rax,rax
     906:	mov    r14,rax
     909:	jne    917 <botlish_fn_6+0x90>
     90f:	mov    rdi,r13
     912:	jmp    93f <botlish_fn_6+0xb8>
     917:	mov    rax,r14
     91a:	mov    QWORD PTR [r12],rax
     91e:	mov    rax,QWORD PTR [rip+0x0]        # 925 <botlish_fn_6+0x9e>
			921: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     925:	mov    rcx,r15
     928:	mov    rdx,rbx
     92b:	mov    rsi,r14
     92e:	mov    rdi,r13
     931:	call   rax
     933:	test   rax,rax
     936:	jne    96c <botlish_fn_6+0xe5>
     93c:	mov    rdi,r13
     93f:	mov    rdi,r13
     942:	mov    QWORD PTR [rdi],r12
     945:	xor    rdx,rdx
     948:	mov    rax,rdx
     94b:	mov    rbx,QWORD PTR [rsp]
     94f:	mov    r12,QWORD PTR [rsp+0x8]
     954:	mov    r13,QWORD PTR [rsp+0x10]
     959:	mov    r14,QWORD PTR [rsp+0x18]
     95e:	mov    r15,QWORD PTR [rsp+0x20]
     963:	add    rsp,0x30
     967:	mov    rsp,rbp
     96a:	pop    rbp
     96b:	ret
     96c:	mov    QWORD PTR [r12+0x10],0x3
     975:	test   rbx,0x1
     97c:	jne    98a <botlish_fn_6+0x103>
     982:	mov    rdi,rbx
     985:	jmp    9a7 <botlish_fn_6+0x120>
     98a:	mov    rdx,rbx
     98d:	add    rdx,0x2
     991:	mov    rdi,rbx
     994:	seto   al
     997:	test   al,al
     999:	jne    9a7 <botlish_fn_6+0x120>
     99f:	mov    rdi,r13
     9a2:	jmp    9c1 <botlish_fn_6+0x13a>
     9a7:	mov    edx,0x3
     9ac:	mov    rax,QWORD PTR [rip+0x0]        # 9b3 <botlish_fn_6+0x12c>
			9af: R_X86_64_GOTPCREL	rt_int_add-0x4
     9b3:	mov    rsi,rdi
     9b6:	mov    rdi,r13
     9b9:	call   rax
     9bb:	mov    rdx,rax
     9be:	mov    rdi,r13
     9c1:	mov    rdi,r13
     9c4:	mov    QWORD PTR [rdi],r12
     9c7:	mov    rax,r14
     9ca:	mov    rbx,QWORD PTR [rsp]
     9ce:	mov    r12,QWORD PTR [rsp+0x8]
     9d3:	mov    r13,QWORD PTR [rsp+0x10]
     9d8:	mov    r14,QWORD PTR [rsp+0x18]
     9dd:	mov    r15,QWORD PTR [rsp+0x20]
     9e2:	add    rsp,0x30
     9e6:	mov    rsp,rbp
     9e9:	pop    rbp
     9ea:	ret
     9eb:	mov    r13,rdi
     9ee:	mov    rax,QWORD PTR [rip+0x0]        # 9f5 <botlish_fn_6+0x16e>
			9f1: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     9f5:	call   rax
     9f7:	xor    rdx,rdx
     9fa:	mov    rax,rdx
     9fd:	mov    rbx,QWORD PTR [rsp]
     a01:	mov    r12,QWORD PTR [rsp+0x8]
     a06:	mov    r13,QWORD PTR [rsp+0x10]
     a0b:	mov    r14,QWORD PTR [rsp+0x18]
     a10:	mov    r15,QWORD PTR [rsp+0x20]
     a15:	add    rsp,0x30
     a19:	mov    rsp,rbp
     a1c:	pop    rbp
     a1d:	ret

0000000000000a1e <botlish_entry_6: geo_append<list[mutarray, int], mutarray>>:
     a1e:	push   rbp
     a1f:	mov    rbp,rsp
     a22:	ud2

0000000000000a24 <botlish_fn_7: geo_finish<list[mutarray, int]>>:
     a24:	push   rbp
     a25:	mov    rbp,rsp
     a28:	sub    rsp,0x10
     a2c:	mov    QWORD PTR [rsp],rbx
     a30:	mov    QWORD PTR [rsp+0x8],r15
     a35:	mov    r15,QWORD PTR [rdi]
     a38:	mov    rax,QWORD PTR [rdi+0x8]
     a3c:	lea    rcx,[r15+0x10]
     a40:	cmp    rcx,rax
     a43:	ja     ab1 <botlish_fn_7+0x8d>
     a49:	lea    rax,[r15+0x10]
     a4d:	mov    QWORD PTR [rdi],rax
     a50:	mov    rbx,rdi
     a53:	mov    QWORD PTR [r15],0x0
     a5a:	mov    QWORD PTR [r15+0x8],0x0
     a62:	mov    QWORD PTR [r15],rsi
     a65:	mov    QWORD PTR [r15+0x8],rdx
     a69:	mov    rax,QWORD PTR [rip+0x0]        # a70 <botlish_fn_7+0x4c>
			a6c: R_X86_64_GOTPCREL	rt_mutarray_freeze-0x4
     a70:	mov    rdi,rbx
     a73:	call   rax
     a75:	test   rax,rax
     a78:	jne    a99 <botlish_fn_7+0x75>
     a7e:	mov    rdi,rbx
     a81:	mov    QWORD PTR [rdi],r15
     a84:	xor    rax,rax
     a87:	mov    rbx,QWORD PTR [rsp]
     a8b:	mov    r15,QWORD PTR [rsp+0x8]
     a90:	add    rsp,0x10
     a94:	mov    rsp,rbp
     a97:	pop    rbp
     a98:	ret
     a99:	mov    rdi,rbx
     a9c:	mov    QWORD PTR [rdi],r15
     a9f:	mov    rbx,QWORD PTR [rsp]
     aa3:	mov    r15,QWORD PTR [rsp+0x8]
     aa8:	add    rsp,0x10
     aac:	mov    rsp,rbp
     aaf:	pop    rbp
     ab0:	ret
     ab1:	mov    rax,QWORD PTR [rip+0x0]        # ab8 <botlish_fn_7+0x94>
			ab4: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     ab8:	call   rax
     aba:	xor    rax,rax
     abd:	mov    rbx,QWORD PTR [rsp]
     ac1:	mov    r15,QWORD PTR [rsp+0x8]
     ac6:	add    rsp,0x10
     aca:	mov    rsp,rbp
     acd:	pop    rbp
     ace:	ret

0000000000000acf <botlish_entry_7: geo_finish<list[mutarray, int]>>:
     acf:	push   rbp
     ad0:	mov    rbp,rsp
     ad3:	mov    rsi,QWORD PTR [rdx]
     ad6:	mov    rdx,QWORD PTR [rdx+0x8]
     ada:	call   adf <botlish_entry_7+0x10>
			adb: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
     adf:	mov    rsp,rbp
     ae2:	pop    rbp
     ae3:	ret
     ae4:	add    BYTE PTR [rax],al
	...

0000000000000ae8 <botlish_fn_8: peek<str, int>>:
     ae8:	push   rbp
     ae9:	mov    rbp,rsp
     aec:	sub    rsp,0x20
     af0:	mov    QWORD PTR [rsp],rbx
     af4:	mov    QWORD PTR [rsp+0x8],r12
     af9:	mov    QWORD PTR [rsp+0x10],r13
     afe:	mov    QWORD PTR [rsp+0x18],r14
     b03:	mov    r12,QWORD PTR [rdi]
     b06:	mov    rax,QWORD PTR [rdi+0x8]
     b0a:	lea    rcx,[r12+0x18]
     b0f:	cmp    rcx,rax
     b12:	ja     c7e <botlish_fn_8+0x196>
     b18:	lea    rax,[r12+0x18]
     b1d:	mov    QWORD PTR [rdi],rax
     b20:	mov    r13,rdi
     b23:	mov    QWORD PTR [r12],0x0
     b2b:	mov    QWORD PTR [r12+0x8],0x0
     b34:	mov    QWORD PTR [r12+0x10],0x0
     b3d:	mov    QWORD PTR [r12],rsi
     b41:	mov    r14,rsi
     b44:	mov    QWORD PTR [r12+0x8],rdx
     b49:	mov    rbx,rdx
     b4c:	mov    rax,QWORD PTR [rip+0x0]        # b53 <botlish_fn_8+0x6b>
			b4f: R_X86_64_GOTPCREL	rt_str_len-0x4
     b53:	mov    rsi,r14
     b56:	mov    rdi,r13
     b59:	call   rax
     b5b:	mov    rcx,rbx
     b5e:	and    rcx,rax
     b61:	mov    rdx,rax
     b64:	test   rcx,0x1
     b6b:	jne    b95 <botlish_fn_8+0xad>
     b71:	mov    rax,QWORD PTR [rip+0x0]        # b78 <botlish_fn_8+0x90>
			b74: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     b78:	mov    rsi,rbx
     b7b:	mov    rdi,r13
     b7e:	call   rax
     b80:	mov    ecx,0x2
     b85:	test   rax,rax
     b88:	cmovge rcx,QWORD PTR [rip+0x120]        # cb0 <botlish_fn_8+0x1c8>
     b90:	jmp    ba5 <botlish_fn_8+0xbd>
     b95:	mov    ecx,0x2
     b9a:	cmp    rbx,rdx
     b9d:	cmovge rcx,QWORD PTR [rip+0x10b]        # cb0 <botlish_fn_8+0x1c8>
     ba5:	cmp    rcx,0x6
     ba9:	je     c55 <botlish_fn_8+0x16d>
     baf:	mov    QWORD PTR [r12+0x10],0x3
     bb8:	test   rbx,0x1
     bbf:	je     bd7 <botlish_fn_8+0xef>
     bc5:	mov    rcx,rbx
     bc8:	add    rcx,0x2
     bcc:	seto   al
     bcf:	test   al,al
     bd1:	je     bee <botlish_fn_8+0x106>
     bd7:	mov    edx,0x3
     bdc:	mov    rax,QWORD PTR [rip+0x0]        # be3 <botlish_fn_8+0xfb>
			bdf: R_X86_64_GOTPCREL	rt_int_add-0x4
     be3:	mov    rsi,rbx
     be6:	mov    rdi,r13
     be9:	call   rax
     beb:	mov    rcx,rax
     bee:	mov    QWORD PTR [r12+0x10],rcx
     bf3:	mov    rax,QWORD PTR [rip+0x0]        # bfa <botlish_fn_8+0x112>
			bf6: R_X86_64_GOTPCREL	rt_substr-0x4
     bfa:	mov    rdx,rbx
     bfd:	mov    rsi,r14
     c00:	mov    rdi,r13
     c03:	call   rax
     c05:	test   rax,rax
     c08:	jne    c33 <botlish_fn_8+0x14b>
     c0e:	mov    rdi,r13
     c11:	mov    QWORD PTR [rdi],r12
     c14:	xor    rax,rax
     c17:	mov    rbx,QWORD PTR [rsp]
     c1b:	mov    r12,QWORD PTR [rsp+0x8]
     c20:	mov    r13,QWORD PTR [rsp+0x10]
     c25:	mov    r14,QWORD PTR [rsp+0x18]
     c2a:	add    rsp,0x20
     c2e:	mov    rsp,rbp
     c31:	pop    rbp
     c32:	ret
     c33:	mov    rdi,r13
     c36:	mov    QWORD PTR [rdi],r12
     c39:	mov    rbx,QWORD PTR [rsp]
     c3d:	mov    r12,QWORD PTR [rsp+0x8]
     c42:	mov    r13,QWORD PTR [rsp+0x10]
     c47:	mov    r14,QWORD PTR [rsp+0x18]
     c4c:	add    rsp,0x20
     c50:	mov    rsp,rbp
     c53:	pop    rbp
     c54:	ret
     c55:	mov    rdi,r13
     c58:	mov    rsi,QWORD PTR [rdi+0x10]
     c5c:	mov    rax,QWORD PTR [rsi]
     c5f:	mov    QWORD PTR [rdi],r12
     c62:	mov    rbx,QWORD PTR [rsp]
     c66:	mov    r12,QWORD PTR [rsp+0x8]
     c6b:	mov    r13,QWORD PTR [rsp+0x10]
     c70:	mov    r14,QWORD PTR [rsp+0x18]
     c75:	add    rsp,0x20
     c79:	mov    rsp,rbp
     c7c:	pop    rbp
     c7d:	ret
     c7e:	mov    r13,rdi
     c81:	mov    rsi,QWORD PTR [rip+0x0]        # c88 <botlish_fn_8+0x1a0>
			c84: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     c88:	call   rsi
     c8a:	xor    rax,rax
     c8d:	mov    rbx,QWORD PTR [rsp]
     c91:	mov    r12,QWORD PTR [rsp+0x8]
     c96:	mov    r13,QWORD PTR [rsp+0x10]
     c9b:	mov    r14,QWORD PTR [rsp+0x18]
     ca0:	add    rsp,0x20
     ca4:	mov    rsp,rbp
     ca7:	pop    rbp
     ca8:	ret
     ca9:	add    BYTE PTR [rax],al
     cab:	add    BYTE PTR [rax],al
     cad:	add    BYTE PTR [rax],al
     caf:	add    BYTE PTR [rsi],al
     cb1:	add    BYTE PTR [rax],al
     cb3:	add    BYTE PTR [rax],al
     cb5:	add    BYTE PTR [rax],al
	...

0000000000000cb8 <botlish_entry_8: peek<str, int>>:
     cb8:	push   rbp
     cb9:	mov    rbp,rsp
     cbc:	mov    rsi,QWORD PTR [rdx]
     cbf:	mov    rdx,QWORD PTR [rdx+0x8]
     cc3:	call   cc8 <botlish_entry_8+0x10>
			cc4: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     cc8:	mov    rsp,rbp
     ccb:	pop    rbp
     ccc:	ret
     ccd:	add    BYTE PTR [rax],al
	...

0000000000000cd0 <botlish_fn_9: peek<str, int>>:
     cd0:	push   rbp
     cd1:	mov    rbp,rsp
     cd4:	sub    rsp,0x40
     cd8:	mov    QWORD PTR [rsp+0x10],rbx
     cdd:	mov    QWORD PTR [rsp+0x18],r12
     ce2:	mov    QWORD PTR [rsp+0x20],r13
     ce7:	mov    QWORD PTR [rsp+0x28],r14
     cec:	mov    QWORD PTR [rsp+0x30],r15
     cf1:	mov    r13,rcx
     cf4:	mov    r12,QWORD PTR [rdi]
     cf7:	mov    rax,QWORD PTR [rdi+0x8]
     cfb:	lea    rcx,[r12+0x18]
     d00:	cmp    rcx,rax
     d03:	ja     eae <botlish_fn_9+0x1de>
     d09:	lea    rax,[r12+0x18]
     d0e:	mov    QWORD PTR [rdi],rax
     d11:	mov    r15,rdi
     d14:	mov    QWORD PTR [r12],0x0
     d1c:	mov    QWORD PTR [r12+0x8],0x0
     d25:	mov    QWORD PTR [r12+0x10],0x0
     d2e:	mov    QWORD PTR [r12],rsi
     d32:	mov    r14,rsi
     d35:	mov    QWORD PTR [r12+0x8],rdx
     d3a:	mov    rbx,rdx
     d3d:	mov    rax,QWORD PTR [rip+0x0]        # d44 <botlish_fn_9+0x74>
			d40: R_X86_64_GOTPCREL	rt_str_len-0x4
     d44:	mov    rsi,r14
     d47:	mov    rdi,r15
     d4a:	call   rax
     d4c:	mov    rcx,rbx
     d4f:	and    rcx,rax
     d52:	mov    rdx,rax
     d55:	test   rcx,0x1
     d5c:	jne    d86 <botlish_fn_9+0xb6>
     d62:	mov    rax,QWORD PTR [rip+0x0]        # d69 <botlish_fn_9+0x99>
			d65: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     d69:	mov    rsi,rbx
     d6c:	mov    rdi,r15
     d6f:	call   rax
     d71:	mov    ecx,0x2
     d76:	test   rax,rax
     d79:	cmovge rcx,QWORD PTR [rip+0x15f]        # ee0 <botlish_fn_9+0x210>
     d81:	jmp    d96 <botlish_fn_9+0xc6>
     d86:	mov    ecx,0x2
     d8b:	cmp    rbx,rdx
     d8e:	cmovge rcx,QWORD PTR [rip+0x14a]        # ee0 <botlish_fn_9+0x210>
     d96:	cmp    rcx,0x6
     d9a:	je     e6d <botlish_fn_9+0x19d>
     da0:	mov    QWORD PTR [r12+0x10],0x3
     da9:	test   rbx,0x1
     db0:	je     dd1 <botlish_fn_9+0x101>
     db6:	mov    rax,rbx
     db9:	add    rax,0x2
     dbd:	seto   cl
     dc0:	test   cl,cl
     dc2:	jne    dd1 <botlish_fn_9+0x101>
     dc8:	mov    QWORD PTR [rsp],rax
     dcc:	jmp    de9 <botlish_fn_9+0x119>
     dd1:	mov    edx,0x3
     dd6:	mov    rax,QWORD PTR [rip+0x0]        # ddd <botlish_fn_9+0x10d>
			dd9: R_X86_64_GOTPCREL	rt_int_add-0x4
     ddd:	mov    rsi,rbx
     de0:	mov    rdi,r15
     de3:	call   rax
     de5:	mov    QWORD PTR [rsp],rax
     de9:	mov    r8,QWORD PTR [rip+0x0]        # df0 <botlish_fn_9+0x120>
			dec: R_X86_64_GOTPCREL	rt_str_region_check-0x4
     df0:	mov    rcx,QWORD PTR [rsp]
     df4:	mov    rdx,rbx
     df7:	mov    rsi,r14
     dfa:	mov    rdi,r15
     dfd:	call   r8
     e00:	test   rax,rax
     e03:	jne    e34 <botlish_fn_9+0x164>
     e09:	mov    rdi,r15
     e0c:	mov    QWORD PTR [rdi],r12
     e0f:	xor    rax,rax
     e12:	mov    rbx,QWORD PTR [rsp+0x10]
     e17:	mov    r12,QWORD PTR [rsp+0x18]
     e1c:	mov    r13,QWORD PTR [rsp+0x20]
     e21:	mov    r14,QWORD PTR [rsp+0x28]
     e26:	mov    r15,QWORD PTR [rsp+0x30]
     e2b:	add    rsp,0x40
     e2f:	mov    rsp,rbp
     e32:	pop    rbp
     e33:	ret
     e34:	mov    rdi,r15
     e37:	mov    QWORD PTR [rdi],r12
     e3a:	mov    rcx,r13
     e3d:	mov    QWORD PTR [rcx],rbx
     e40:	mov    rax,QWORD PTR [rsp]
     e44:	mov    QWORD PTR [rcx+0x8],rax
     e48:	mov    rax,r14
     e4b:	mov    rbx,QWORD PTR [rsp+0x10]
     e50:	mov    r12,QWORD PTR [rsp+0x18]
     e55:	mov    r13,QWORD PTR [rsp+0x20]
     e5a:	mov    r14,QWORD PTR [rsp+0x28]
     e5f:	mov    r15,QWORD PTR [rsp+0x30]
     e64:	add    rsp,0x40
     e68:	mov    rsp,rbp
     e6b:	pop    rbp
     e6c:	ret
     e6d:	mov    rcx,r13
     e70:	mov    rdi,r15
     e73:	mov    rsi,QWORD PTR [rdi+0x10]
     e77:	mov    rax,QWORD PTR [rsi]
     e7a:	mov    QWORD PTR [rdi],r12
     e7d:	mov    QWORD PTR [rcx],0x1
     e84:	mov    QWORD PTR [rcx+0x8],0x1
     e8c:	mov    rbx,QWORD PTR [rsp+0x10]
     e91:	mov    r12,QWORD PTR [rsp+0x18]
     e96:	mov    r13,QWORD PTR [rsp+0x20]
     e9b:	mov    r14,QWORD PTR [rsp+0x28]
     ea0:	mov    r15,QWORD PTR [rsp+0x30]
     ea5:	add    rsp,0x40
     ea9:	mov    rsp,rbp
     eac:	pop    rbp
     ead:	ret
     eae:	mov    r15,rdi
     eb1:	mov    r10,QWORD PTR [rip+0x0]        # eb8 <botlish_fn_9+0x1e8>
			eb4: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     eb8:	call   r10
     ebb:	xor    rax,rax
     ebe:	mov    rbx,QWORD PTR [rsp+0x10]
     ec3:	mov    r12,QWORD PTR [rsp+0x18]
     ec8:	mov    r13,QWORD PTR [rsp+0x20]
     ecd:	mov    r14,QWORD PTR [rsp+0x28]
     ed2:	mov    r15,QWORD PTR [rsp+0x30]
     ed7:	add    rsp,0x40
     edb:	mov    rsp,rbp
     ede:	pop    rbp
     edf:	ret
     ee0:	(bad)
     ee1:	add    BYTE PTR [rax],al
     ee3:	add    BYTE PTR [rax],al
     ee5:	add    BYTE PTR [rax],al
	...

0000000000000ee8 <botlish_entry_9: peek<str, int>>:
     ee8:	push   rbp
     ee9:	mov    rbp,rsp
     eec:	ud2

0000000000000eee <botlish_fn_10: scan_unquoted<str, int, int>>:
     eee:	push   rbp
     eef:	mov    rbp,rsp
     ef2:	sub    rsp,0x60
     ef6:	mov    QWORD PTR [rsp+0x30],rbx
     efb:	mov    QWORD PTR [rsp+0x38],r12
     f00:	mov    QWORD PTR [rsp+0x40],r13
     f05:	mov    QWORD PTR [rsp+0x48],r14
     f0a:	mov    QWORD PTR [rsp+0x50],r15
     f0f:	mov    r14,QWORD PTR [rdi]
     f12:	mov    rax,QWORD PTR [rdi+0x8]
     f16:	lea    r8,[r14+0x20]
     f1a:	cmp    r8,rax
     f1d:	ja     115b <botlish_fn_10+0x26d>
     f23:	lea    rax,[r14+0x20]
     f27:	mov    QWORD PTR [rdi],rax
     f2a:	mov    r15,rdi
     f2d:	mov    QWORD PTR [r14],0x0
     f34:	mov    QWORD PTR [r14+0x8],0x0
     f3c:	mov    QWORD PTR [r14+0x10],0x0
     f44:	mov    QWORD PTR [r14+0x18],0x0
     f4c:	mov    QWORD PTR [r14],rsi
     f4f:	mov    QWORD PTR [rsp+0x10],rsi
     f54:	mov    QWORD PTR [r14+0x8],rdx
     f58:	mov    QWORD PTR [rsp+0x18],rdx
     f5d:	mov    QWORD PTR [r14+0x10],rcx
     f61:	lea    rbx,[rsp]
     f65:	mov    QWORD PTR [rsp+0x20],rcx
     f6a:	mov    rcx,rbx
     f6d:	mov    rdx,QWORD PTR [rsp+0x20]
     f72:	mov    rsi,QWORD PTR [rsp+0x10]
     f77:	mov    rdi,r15
     f7a:	call   f7f <botlish_fn_10+0x91>
			f7b: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     f7f:	mov    rcx,rax
     f82:	mov    QWORD PTR [rsp+0x28],rax
     f87:	test   rax,rcx
     f8a:	jne    f98 <botlish_fn_10+0xaa>
     f90:	mov    rdi,r15
     f93:	jmp    1100 <botlish_fn_10+0x212>
     f98:	mov    r12,QWORD PTR [rsp]
     f9c:	mov    r13,QWORD PTR [rsp+0x8]
     fa1:	mov    rdi,r15
     fa4:	mov    rcx,QWORD PTR [rdi+0x10]
     fa8:	mov    r8,QWORD PTR [rcx]
     fab:	mov    r9,QWORD PTR [rip+0x0]        # fb2 <botlish_fn_10+0xc4>
			fae: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
     fb2:	mov    rcx,r13
     fb5:	mov    rdx,r12
     fb8:	mov    rsi,QWORD PTR [rsp+0x28]
     fbd:	call   r9
     fc0:	cmp    rax,0x6
     fc4:	je     1008 <botlish_fn_10+0x11a>
     fca:	mov    rdi,r15
     fcd:	mov    rdx,QWORD PTR [rdi+0x10]
     fd1:	mov    r8,QWORD PTR [rdx+0x8]
     fd5:	mov    r9,QWORD PTR [rip+0x0]        # fdc <botlish_fn_10+0xee>
			fd8: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
     fdc:	mov    rcx,r13
     fdf:	mov    rdx,r12
     fe2:	mov    rsi,QWORD PTR [rsp+0x28]
     fe7:	call   r9
     fea:	cmp    rax,0x6
     fee:	je     ffe <botlish_fn_10+0x110>
     ff4:	mov    eax,0x2
     ff9:	jmp    100d <botlish_fn_10+0x11f>
     ffe:	mov    eax,0x6
    1003:	jmp    100d <botlish_fn_10+0x11f>
    1008:	mov    eax,0x6
    100d:	cmp    rax,0x6
    1011:	je     1055 <botlish_fn_10+0x167>
    1017:	mov    rdi,r15
    101a:	mov    r10,QWORD PTR [rdi+0x10]
    101e:	mov    r8,QWORD PTR [r10+0x10]
    1022:	mov    r10,QWORD PTR [rip+0x0]        # 1029 <botlish_fn_10+0x13b>
			1025: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1029:	mov    rcx,r13
    102c:	mov    rdx,r12
    102f:	mov    rsi,QWORD PTR [rsp+0x28]
    1034:	call   r10
    1037:	cmp    rax,0x6
    103b:	je     104b <botlish_fn_10+0x15d>
    1041:	mov    eax,0x2
    1046:	jmp    105a <botlish_fn_10+0x16c>
    104b:	mov    eax,0x6
    1050:	jmp    105a <botlish_fn_10+0x16c>
    1055:	mov    eax,0x6
    105a:	cmp    rax,0x6
    105e:	je     10d9 <botlish_fn_10+0x1eb>
    1064:	mov    QWORD PTR [r14+0x18],0x3
    106c:	mov    rsi,QWORD PTR [rsp+0x20]
    1071:	test   rsi,0x1
    1078:	je     109f <botlish_fn_10+0x1b1>
    107e:	mov    rsi,QWORD PTR [rsp+0x20]
    1083:	mov    rax,rsi
    1086:	add    rax,0x2
    108a:	seto   cl
    108d:	test   cl,cl
    108f:	jne    109f <botlish_fn_10+0x1b1>
    1095:	mov    rsi,QWORD PTR [rsp+0x10]
    109a:	jmp    10ba <botlish_fn_10+0x1cc>
    109f:	mov    edx,0x3
    10a4:	mov    rax,QWORD PTR [rip+0x0]        # 10ab <botlish_fn_10+0x1bd>
			10a7: R_X86_64_GOTPCREL	rt_int_add-0x4
    10ab:	mov    rsi,QWORD PTR [rsp+0x20]
    10b0:	mov    rdi,r15
    10b3:	call   rax
    10b5:	mov    rsi,QWORD PTR [rsp+0x10]
    10ba:	mov    QWORD PTR [r14],rsi
    10bd:	mov    rdx,QWORD PTR [rsp+0x18]
    10c2:	mov    QWORD PTR [r14+0x8],rdx
    10c6:	mov    QWORD PTR [r14+0x10],rax
    10ca:	mov    QWORD PTR [rsp+0x10],rsi
    10cf:	mov    QWORD PTR [rsp+0x20],rax
    10d4:	jmp    f6a <botlish_fn_10+0x7c>
    10d9:	mov    rdx,QWORD PTR [rsp+0x18]
    10de:	mov    rsi,QWORD PTR [rsp+0x10]
    10e3:	mov    rax,QWORD PTR [rip+0x0]        # 10ea <botlish_fn_10+0x1fc>
			10e6: R_X86_64_GOTPCREL	rt_substr-0x4
    10ea:	mov    rcx,QWORD PTR [rsp+0x20]
    10ef:	mov    rdi,r15
    10f2:	call   rax
    10f4:	test   rax,rax
    10f7:	jne    112e <botlish_fn_10+0x240>
    10fd:	mov    rdi,r15
    1100:	mov    rdi,r15
    1103:	mov    QWORD PTR [rdi],r14
    1106:	xor    rdx,rdx
    1109:	mov    rax,rdx
    110c:	mov    rbx,QWORD PTR [rsp+0x30]
    1111:	mov    r12,QWORD PTR [rsp+0x38]
    1116:	mov    r13,QWORD PTR [rsp+0x40]
    111b:	mov    r14,QWORD PTR [rsp+0x48]
    1120:	mov    r15,QWORD PTR [rsp+0x50]
    1125:	add    rsp,0x60
    1129:	mov    rsp,rbp
    112c:	pop    rbp
    112d:	ret
    112e:	mov    rdi,r15
    1131:	mov    QWORD PTR [rdi],r14
    1134:	mov    rdx,QWORD PTR [rsp+0x20]
    1139:	mov    rbx,QWORD PTR [rsp+0x30]
    113e:	mov    r12,QWORD PTR [rsp+0x38]
    1143:	mov    r13,QWORD PTR [rsp+0x40]
    1148:	mov    r14,QWORD PTR [rsp+0x48]
    114d:	mov    r15,QWORD PTR [rsp+0x50]
    1152:	add    rsp,0x60
    1156:	mov    rsp,rbp
    1159:	pop    rbp
    115a:	ret
    115b:	mov    r15,rdi
    115e:	mov    rax,QWORD PTR [rip+0x0]        # 1165 <botlish_fn_10+0x277>
			1161: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1165:	call   rax
    1167:	xor    rdx,rdx
    116a:	mov    rax,rdx
    116d:	mov    rbx,QWORD PTR [rsp+0x30]
    1172:	mov    r12,QWORD PTR [rsp+0x38]
    1177:	mov    r13,QWORD PTR [rsp+0x40]
    117c:	mov    r14,QWORD PTR [rsp+0x48]
    1181:	mov    r15,QWORD PTR [rsp+0x50]
    1186:	add    rsp,0x60
    118a:	mov    rsp,rbp
    118d:	pop    rbp
    118e:	ret

000000000000118f <botlish_entry_10: scan_unquoted<str, int, int>>:
    118f:	push   rbp
    1190:	mov    rbp,rsp
    1193:	ud2

0000000000001195 <botlish_fn_11: scan_quoted<str, int, str>>:
    1195:	push   rbp
    1196:	mov    rbp,rsp
    1199:	sub    rsp,0x50
    119d:	mov    QWORD PTR [rsp+0x20],rbx
    11a2:	mov    QWORD PTR [rsp+0x28],r12
    11a7:	mov    QWORD PTR [rsp+0x30],r13
    11ac:	mov    QWORD PTR [rsp+0x38],r14
    11b1:	mov    QWORD PTR [rsp+0x40],r15
    11b6:	mov    r13,QWORD PTR [rdi]
    11b9:	mov    rax,QWORD PTR [rdi+0x8]
    11bd:	lea    r8,[r13+0x28]
    11c1:	cmp    r8,rax
    11c4:	ja     14d1 <botlish_fn_11+0x33c>
    11ca:	lea    rax,[r13+0x28]
    11ce:	mov    QWORD PTR [rdi],rax
    11d1:	mov    r14,rdi
    11d4:	mov    QWORD PTR [r13+0x0],0x0
    11dc:	mov    QWORD PTR [r13+0x8],0x0
    11e4:	mov    QWORD PTR [r13+0x10],0x0
    11ec:	mov    QWORD PTR [r13+0x18],0x0
    11f4:	mov    QWORD PTR [r13+0x20],0x0
    11fc:	mov    QWORD PTR [r13+0x0],rsi
    1200:	mov    QWORD PTR [r13+0x8],rdx
    1204:	mov    QWORD PTR [r13+0x10],rcx
    1208:	lea    r12,[rsp]
    120c:	mov    rbx,rsi
    120f:	mov    r15,rdx
    1212:	mov    QWORD PTR [rsp+0x10],rcx
    1217:	mov    rdx,r15
    121a:	mov    rsi,rbx
    121d:	mov    rdi,r14
    1220:	call   1225 <botlish_fn_11+0x90>
			1221: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    1225:	test   rax,rax
    1228:	jne    1236 <botlish_fn_11+0xa1>
    122e:	mov    rdi,r14
    1231:	jmp    148a <botlish_fn_11+0x2f5>
    1236:	mov    QWORD PTR [r13+0x18],rax
    123a:	mov    rdi,r14
    123d:	mov    QWORD PTR [rsp+0x18],rax
    1242:	mov    rcx,QWORD PTR [rdi+0x10]
    1246:	mov    rsi,QWORD PTR [rcx+0x18]
    124a:	mov    edx,0x1
    124f:	mov    ecx,0x3
    1254:	mov    r9,QWORD PTR [rip+0x0]        # 125b <botlish_fn_11+0xc6>
			1257: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    125b:	mov    r8,QWORD PTR [rsp+0x18]
    1260:	call   r9
    1263:	cmp    rax,0x6
    1267:	je     12fa <botlish_fn_11+0x165>
    126d:	mov    QWORD PTR [r13+0x20],0x3
    1275:	mov    rsi,r15
    1278:	test   rsi,0x1
    127f:	je     129f <botlish_fn_11+0x10a>
    1285:	mov    rax,rsi
    1288:	add    rax,0x2
    128c:	seto   cl
    128f:	test   cl,cl
    1291:	jne    129f <botlish_fn_11+0x10a>
    1297:	mov    rsi,rax
    129a:	jmp    12b3 <botlish_fn_11+0x11e>
    129f:	mov    edx,0x3
    12a4:	mov    rax,QWORD PTR [rip+0x0]        # 12ab <botlish_fn_11+0x116>
			12a7: R_X86_64_GOTPCREL	rt_int_add-0x4
    12ab:	mov    rdi,r14
    12ae:	call   rax
    12b0:	mov    rsi,rax
    12b3:	mov    QWORD PTR [r13+0x8],rsi
    12b7:	mov    r15,rsi
    12ba:	mov    rax,QWORD PTR [rip+0x0]        # 12c1 <botlish_fn_11+0x12c>
			12bd: R_X86_64_GOTPCREL	rt_str_cat-0x4
    12c1:	mov    rdx,QWORD PTR [rsp+0x18]
    12c6:	mov    rsi,QWORD PTR [rsp+0x10]
    12cb:	mov    rdi,r14
    12ce:	call   rax
    12d0:	test   rax,rax
    12d3:	jne    12e1 <botlish_fn_11+0x14c>
    12d9:	mov    rdi,r14
    12dc:	jmp    148a <botlish_fn_11+0x2f5>
    12e1:	mov    QWORD PTR [r13+0x0],rbx
    12e5:	mov    rsi,r15
    12e8:	mov    QWORD PTR [r13+0x8],rsi
    12ec:	mov    QWORD PTR [r13+0x10],rax
    12f0:	mov    QWORD PTR [rsp+0x10],rax
    12f5:	jmp    1217 <botlish_fn_11+0x82>
    12fa:	mov    QWORD PTR [r13+0x18],0x3
    1302:	mov    rsi,r15
    1305:	test   rsi,0x1
    130c:	je     1327 <botlish_fn_11+0x192>
    1312:	mov    rsi,r15
    1315:	mov    rdx,rsi
    1318:	add    rdx,0x2
    131c:	seto   al
    131f:	test   al,al
    1321:	je     133e <botlish_fn_11+0x1a9>
    1327:	mov    edx,0x3
    132c:	mov    rax,QWORD PTR [rip+0x0]        # 1333 <botlish_fn_11+0x19e>
			132f: R_X86_64_GOTPCREL	rt_int_add-0x4
    1333:	mov    rsi,r15
    1336:	mov    rdi,r14
    1339:	call   rax
    133b:	mov    rdx,rax
    133e:	mov    QWORD PTR [r13+0x18],rdx
    1342:	mov    rcx,r12
    1345:	mov    rsi,rbx
    1348:	mov    rdi,r14
    134b:	call   1350 <botlish_fn_11+0x1bb>
			134c: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    1350:	test   rax,rax
    1353:	mov    rsi,rax
    1356:	jne    1364 <botlish_fn_11+0x1cf>
    135c:	mov    rdi,r14
    135f:	jmp    148a <botlish_fn_11+0x2f5>
    1364:	mov    rdx,QWORD PTR [rsp]
    1368:	mov    rcx,QWORD PTR [rsp+0x8]
    136d:	mov    rdi,r14
    1370:	mov    rax,QWORD PTR [rdi+0x10]
    1374:	mov    r8,QWORD PTR [rax+0x18]
    1378:	mov    rax,QWORD PTR [rip+0x0]        # 137f <botlish_fn_11+0x1ea>
			137b: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    137f:	call   rax
    1381:	cmp    rax,0x6
    1385:	je     1407 <botlish_fn_11+0x272>
    138b:	mov    QWORD PTR [r13+0x0],0x3
    1393:	mov    rsi,r15
    1396:	test   rsi,0x1
    139d:	je     13c0 <botlish_fn_11+0x22b>
    13a3:	mov    rsi,r15
    13a6:	mov    rdx,rsi
    13a9:	add    rdx,0x2
    13ad:	seto   al
    13b0:	test   al,al
    13b2:	jne    13c0 <botlish_fn_11+0x22b>
    13b8:	mov    rdi,r14
    13bb:	jmp    13da <botlish_fn_11+0x245>
    13c0:	mov    edx,0x3
    13c5:	mov    rax,QWORD PTR [rip+0x0]        # 13cc <botlish_fn_11+0x237>
			13c8: R_X86_64_GOTPCREL	rt_int_add-0x4
    13cc:	mov    rsi,r15
    13cf:	mov    rdi,r14
    13d2:	call   rax
    13d4:	mov    rdx,rax
    13d7:	mov    rdi,r14
    13da:	mov    rdi,r14
    13dd:	mov    QWORD PTR [rdi],r13
    13e0:	mov    rax,QWORD PTR [rsp+0x10]
    13e5:	mov    rbx,QWORD PTR [rsp+0x20]
    13ea:	mov    r12,QWORD PTR [rsp+0x28]
    13ef:	mov    r13,QWORD PTR [rsp+0x30]
    13f4:	mov    r14,QWORD PTR [rsp+0x38]
    13f9:	mov    r15,QWORD PTR [rsp+0x40]
    13fe:	add    rsp,0x50
    1402:	mov    rsp,rbp
    1405:	pop    rbp
    1406:	ret
    1407:	mov    QWORD PTR [r13+0x18],0x5
    140f:	mov    rsi,r15
    1412:	test   rsi,0x1
    1419:	je     1441 <botlish_fn_11+0x2ac>
    141f:	mov    rsi,r15
    1422:	mov    rcx,rsi
    1425:	add    rcx,0x4
    1429:	seto   sil
    142d:	test   sil,sil
    1430:	jne    1441 <botlish_fn_11+0x2ac>
    1436:	mov    rsi,rcx
    1439:	mov    r15,rcx
    143c:	jmp    145c <botlish_fn_11+0x2c7>
    1441:	mov    edx,0x5
    1446:	mov    r8,QWORD PTR [rip+0x0]        # 144d <botlish_fn_11+0x2b8>
			1449: R_X86_64_GOTPCREL	rt_int_add-0x4
    144d:	mov    rsi,r15
    1450:	mov    rdi,r14
    1453:	call   r8
    1456:	mov    rsi,rax
    1459:	mov    r15,rax
    145c:	mov    QWORD PTR [r13+0x8],rsi
    1460:	mov    rdi,r14
    1463:	mov    r8,QWORD PTR [rdi+0x10]
    1467:	mov    rdx,QWORD PTR [r8+0x18]
    146b:	mov    QWORD PTR [r13+0x18],rdx
    146f:	mov    r9,QWORD PTR [rip+0x0]        # 1476 <botlish_fn_11+0x2e1>
			1472: R_X86_64_GOTPCREL	rt_str_cat-0x4
    1476:	mov    rsi,QWORD PTR [rsp+0x10]
    147b:	call   r9
    147e:	test   rax,rax
    1481:	jne    14b8 <botlish_fn_11+0x323>
    1487:	mov    rdi,r14
    148a:	mov    rdi,r14
    148d:	mov    QWORD PTR [rdi],r13
    1490:	xor    rdx,rdx
    1493:	mov    rax,rdx
    1496:	mov    rbx,QWORD PTR [rsp+0x20]
    149b:	mov    r12,QWORD PTR [rsp+0x28]
    14a0:	mov    r13,QWORD PTR [rsp+0x30]
    14a5:	mov    r14,QWORD PTR [rsp+0x38]
    14aa:	mov    r15,QWORD PTR [rsp+0x40]
    14af:	add    rsp,0x50
    14b3:	mov    rsp,rbp
    14b6:	pop    rbp
    14b7:	ret
    14b8:	mov    QWORD PTR [r13+0x0],rbx
    14bc:	mov    rsi,r15
    14bf:	mov    QWORD PTR [r13+0x8],rsi
    14c3:	mov    QWORD PTR [r13+0x10],rax
    14c7:	mov    QWORD PTR [rsp+0x10],rax
    14cc:	jmp    1217 <botlish_fn_11+0x82>
    14d1:	mov    r14,rdi
    14d4:	mov    rax,QWORD PTR [rip+0x0]        # 14db <botlish_fn_11+0x346>
			14d7: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    14db:	call   rax
    14dd:	xor    rdx,rdx
    14e0:	mov    rax,rdx
    14e3:	mov    rbx,QWORD PTR [rsp+0x20]
    14e8:	mov    r12,QWORD PTR [rsp+0x28]
    14ed:	mov    r13,QWORD PTR [rsp+0x30]
    14f2:	mov    r14,QWORD PTR [rsp+0x38]
    14f7:	mov    r15,QWORD PTR [rsp+0x40]
    14fc:	add    rsp,0x50
    1500:	mov    rsp,rbp
    1503:	pop    rbp
    1504:	ret

0000000000001505 <botlish_entry_11: scan_quoted<str, int, str>>:
    1505:	push   rbp
    1506:	mov    rbp,rsp
    1509:	ud2

000000000000150b <botlish_fn_12: scan_field<str, int>>:
    150b:	push   rbp
    150c:	mov    rbp,rsp
    150f:	sub    rsp,0x30
    1513:	mov    QWORD PTR [rsp+0x10],rbx
    1518:	mov    QWORD PTR [rsp+0x18],r12
    151d:	mov    QWORD PTR [rsp+0x20],r13
    1522:	mov    QWORD PTR [rsp+0x28],r14
    1527:	mov    rbx,QWORD PTR [rdi]
    152a:	mov    rax,QWORD PTR [rdi+0x8]
    152e:	lea    rcx,[rbx+0x18]
    1532:	cmp    rcx,rax
    1535:	ja     16ae <botlish_fn_12+0x1a3>
    153b:	lea    rax,[rbx+0x18]
    153f:	mov    QWORD PTR [rdi],rax
    1542:	mov    r12,rdi
    1545:	mov    QWORD PTR [rbx],0x0
    154c:	mov    QWORD PTR [rbx+0x8],0x0
    1554:	mov    QWORD PTR [rbx+0x10],0x0
    155c:	mov    QWORD PTR [rbx],rsi
    155f:	mov    r13,rsi
    1562:	mov    QWORD PTR [rbx+0x8],rdx
    1566:	mov    r14,rdx
    1569:	lea    rcx,[rsp]
    156d:	mov    rdx,r14
    1570:	mov    rsi,r13
    1573:	mov    rdi,r12
    1576:	call   157b <botlish_fn_12+0x70>
			1577: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    157b:	test   rax,rax
    157e:	mov    rsi,rax
    1581:	jne    158f <botlish_fn_12+0x84>
    1587:	mov    rdi,r12
    158a:	jmp    1662 <botlish_fn_12+0x157>
    158f:	mov    rdx,QWORD PTR [rsp]
    1593:	mov    rcx,QWORD PTR [rsp+0x8]
    1598:	mov    rdi,r12
    159b:	mov    rax,QWORD PTR [rdi+0x10]
    159f:	mov    r8,QWORD PTR [rax+0x18]
    15a3:	mov    rax,QWORD PTR [rip+0x0]        # 15aa <botlish_fn_12+0x9f>
			15a6: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    15aa:	call   rax
    15ac:	cmp    rax,0x6
    15b0:	je     15fb <botlish_fn_12+0xf0>
    15b6:	mov    rcx,r14
    15b9:	mov    rsi,r13
    15bc:	mov    rdi,r12
    15bf:	mov    rdx,rcx
    15c2:	call   15c7 <botlish_fn_12+0xbc>
			15c3: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_unquoted<str, int, int>
    15c7:	test   rax,rax
    15ca:	jne    15d8 <botlish_fn_12+0xcd>
    15d0:	mov    rdi,r12
    15d3:	jmp    1662 <botlish_fn_12+0x157>
    15d8:	mov    rdi,r12
    15db:	mov    QWORD PTR [rdi],rbx
    15de:	mov    rbx,QWORD PTR [rsp+0x10]
    15e3:	mov    r12,QWORD PTR [rsp+0x18]
    15e8:	mov    r13,QWORD PTR [rsp+0x20]
    15ed:	mov    r14,QWORD PTR [rsp+0x28]
    15f2:	add    rsp,0x30
    15f6:	mov    rsp,rbp
    15f9:	pop    rbp
    15fa:	ret
    15fb:	mov    QWORD PTR [rbx+0x10],0x3
    1603:	mov    rdx,r14
    1606:	test   rdx,0x1
    160d:	je     1625 <botlish_fn_12+0x11a>
    1613:	mov    rdx,r14
    1616:	add    rdx,0x2
    161a:	seto   al
    161d:	test   al,al
    161f:	je     163c <botlish_fn_12+0x131>
    1625:	mov    edx,0x3
    162a:	mov    rax,QWORD PTR [rip+0x0]        # 1631 <botlish_fn_12+0x126>
			162d: R_X86_64_GOTPCREL	rt_int_add-0x4
    1631:	mov    rsi,r14
    1634:	mov    rdi,r12
    1637:	call   rax
    1639:	mov    rdx,rax
    163c:	mov    QWORD PTR [rbx+0x8],rdx
    1640:	mov    rdi,r12
    1643:	mov    rax,QWORD PTR [rdi+0x10]
    1647:	mov    rcx,QWORD PTR [rax]
    164a:	mov    QWORD PTR [rbx+0x10],rcx
    164e:	mov    rsi,r13
    1651:	call   1656 <botlish_fn_12+0x14b>
			1652: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_quoted<str, int, str>
    1656:	test   rax,rax
    1659:	jne    168b <botlish_fn_12+0x180>
    165f:	mov    rdi,r12
    1662:	mov    rdi,r12
    1665:	mov    QWORD PTR [rdi],rbx
    1668:	xor    rdx,rdx
    166b:	mov    rax,rdx
    166e:	mov    rbx,QWORD PTR [rsp+0x10]
    1673:	mov    r12,QWORD PTR [rsp+0x18]
    1678:	mov    r13,QWORD PTR [rsp+0x20]
    167d:	mov    r14,QWORD PTR [rsp+0x28]
    1682:	add    rsp,0x30
    1686:	mov    rsp,rbp
    1689:	pop    rbp
    168a:	ret
    168b:	mov    rdi,r12
    168e:	mov    QWORD PTR [rdi],rbx
    1691:	mov    rbx,QWORD PTR [rsp+0x10]
    1696:	mov    r12,QWORD PTR [rsp+0x18]
    169b:	mov    r13,QWORD PTR [rsp+0x20]
    16a0:	mov    r14,QWORD PTR [rsp+0x28]
    16a5:	add    rsp,0x30
    16a9:	mov    rsp,rbp
    16ac:	pop    rbp
    16ad:	ret
    16ae:	mov    r12,rdi
    16b1:	mov    rsi,QWORD PTR [rip+0x0]        # 16b8 <botlish_fn_12+0x1ad>
			16b4: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    16b8:	call   rsi
    16ba:	xor    rdx,rdx
    16bd:	mov    rax,rdx
    16c0:	mov    rbx,QWORD PTR [rsp+0x10]
    16c5:	mov    r12,QWORD PTR [rsp+0x18]
    16ca:	mov    r13,QWORD PTR [rsp+0x20]
    16cf:	mov    r14,QWORD PTR [rsp+0x28]
    16d4:	add    rsp,0x30
    16d8:	mov    rsp,rbp
    16db:	pop    rbp
    16dc:	ret

00000000000016dd <botlish_entry_12: scan_field<str, int>>:
    16dd:	push   rbp
    16de:	mov    rbp,rsp
    16e1:	ud2

00000000000016e3 <botlish_fn_13: scan_record<str, int, list[mutarray, int]>>:
    16e3:	push   rbp
    16e4:	mov    rbp,rsp
    16e7:	sub    rsp,0x70
    16eb:	mov    QWORD PTR [rsp+0x40],rbx
    16f0:	mov    QWORD PTR [rsp+0x48],r12
    16f5:	mov    QWORD PTR [rsp+0x50],r13
    16fa:	mov    QWORD PTR [rsp+0x58],r14
    16ff:	mov    QWORD PTR [rsp+0x60],r15
    1704:	mov    r12,QWORD PTR [rdi]
    1707:	mov    rax,QWORD PTR [rdi+0x8]
    170b:	lea    r9,[r12+0x28]
    1710:	cmp    r9,rax
    1713:	ja     1a0e <botlish_fn_13+0x32b>
    1719:	lea    rax,[r12+0x28]
    171e:	mov    QWORD PTR [rdi],rax
    1721:	mov    QWORD PTR [rsp+0x10],rdi
    1726:	mov    QWORD PTR [r12],0x0
    172e:	mov    QWORD PTR [r12+0x8],0x0
    1737:	mov    QWORD PTR [r12+0x10],0x0
    1740:	mov    QWORD PTR [r12+0x18],0x0
    1749:	mov    QWORD PTR [r12+0x20],0x0
    1752:	mov    QWORD PTR [r12],rsi
    1756:	mov    QWORD PTR [r12+0x8],rdx
    175b:	mov    QWORD PTR [r12+0x10],rcx
    1760:	mov    QWORD PTR [r12+0x18],r8
    1765:	lea    rbx,[rsp]
    1769:	mov    r13,r8
    176c:	mov    r14,rcx
    176f:	mov    r15,rsi
    1772:	mov    rsi,r15
    1775:	mov    rdi,QWORD PTR [rsp+0x10]
    177a:	call   177f <botlish_fn_13+0x9c>
			177b: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_field<str, int>
    177f:	test   rax,rax
    1782:	jne    1792 <botlish_fn_13+0xaf>
    1788:	mov    rdi,QWORD PTR [rsp+0x10]
    178d:	jmp    18e0 <botlish_fn_13+0x1fd>
    1792:	mov    QWORD PTR [r12+0x8],rax
    1797:	mov    rcx,rax
    179a:	mov    QWORD PTR [r12+0x20],rdx
    179f:	mov    QWORD PTR [rsp+0x30],rdx
    17a4:	mov    rsi,r14
    17a7:	mov    rdx,r13
    17aa:	mov    rdi,QWORD PTR [rsp+0x10]
    17af:	call   17b4 <botlish_fn_13+0xd1>
			17b0: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    17b4:	test   rax,rax
    17b7:	jne    17c7 <botlish_fn_13+0xe4>
    17bd:	mov    rdi,QWORD PTR [rsp+0x10]
    17c2:	jmp    18e0 <botlish_fn_13+0x1fd>
    17c7:	mov    QWORD PTR [r12+0x8],rax
    17cc:	mov    QWORD PTR [rsp+0x20],rax
    17d1:	mov    QWORD PTR [r12+0x10],rdx
    17d6:	mov    QWORD PTR [rsp+0x28],rdx
    17db:	mov    rcx,rbx
    17de:	mov    rdx,QWORD PTR [rsp+0x30]
    17e3:	mov    rsi,r15
    17e6:	mov    rdi,QWORD PTR [rsp+0x10]
    17eb:	call   17f0 <botlish_fn_13+0x10d>
			17ec: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    17f0:	test   rax,rax
    17f3:	mov    QWORD PTR [rsp+0x18],rax
    17f8:	jne    1808 <botlish_fn_13+0x125>
    17fe:	mov    rdi,QWORD PTR [rsp+0x10]
    1803:	jmp    18e0 <botlish_fn_13+0x1fd>
    1808:	mov    r14,QWORD PTR [rsp]
    180c:	mov    r13,QWORD PTR [rsp+0x8]
    1811:	mov    rdi,QWORD PTR [rsp+0x10]
    1816:	mov    r9,QWORD PTR [rdi+0x10]
    181a:	mov    r8,QWORD PTR [r9+0x8]
    181e:	mov    r9,QWORD PTR [rip+0x0]        # 1825 <botlish_fn_13+0x142>
			1821: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1825:	mov    rcx,r13
    1828:	mov    rdx,r14
    182b:	mov    rsi,QWORD PTR [rsp+0x18]
    1830:	call   r9
    1833:	cmp    rax,0x6
    1837:	je     199d <botlish_fn_13+0x2ba>
    183d:	mov    rdi,QWORD PTR [rsp+0x10]
    1842:	mov    rax,QWORD PTR [rdi+0x10]
    1846:	mov    r8,QWORD PTR [rax+0x10]
    184a:	mov    rax,QWORD PTR [rip+0x0]        # 1851 <botlish_fn_13+0x16e>
			184d: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1851:	mov    rcx,r13
    1854:	mov    rdx,r14
    1857:	mov    rsi,QWORD PTR [rsp+0x18]
    185c:	call   rax
    185e:	cmp    rax,0x6
    1862:	je     18be <botlish_fn_13+0x1db>
    1868:	mov    rdx,QWORD PTR [rsp+0x28]
    186d:	mov    rsi,QWORD PTR [rsp+0x20]
    1872:	mov    rdi,QWORD PTR [rsp+0x10]
    1877:	call   187c <botlish_fn_13+0x199>
			1878: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    187c:	test   rax,rax
    187f:	jne    188f <botlish_fn_13+0x1ac>
    1885:	mov    rdi,QWORD PTR [rsp+0x10]
    188a:	jmp    18e0 <botlish_fn_13+0x1fd>
    188f:	mov    rdi,QWORD PTR [rsp+0x10]
    1894:	mov    QWORD PTR [rdi],r12
    1897:	mov    rdx,QWORD PTR [rsp+0x30]
    189c:	mov    rbx,QWORD PTR [rsp+0x40]
    18a1:	mov    r12,QWORD PTR [rsp+0x48]
    18a6:	mov    r13,QWORD PTR [rsp+0x50]
    18ab:	mov    r14,QWORD PTR [rsp+0x58]
    18b0:	mov    r15,QWORD PTR [rsp+0x60]
    18b5:	add    rsp,0x70
    18b9:	mov    rsp,rbp
    18bc:	pop    rbp
    18bd:	ret
    18be:	mov    rdx,QWORD PTR [rsp+0x28]
    18c3:	mov    rsi,QWORD PTR [rsp+0x20]
    18c8:	mov    rdi,QWORD PTR [rsp+0x10]
    18cd:	call   18d2 <botlish_fn_13+0x1ef>
			18ce: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    18d2:	test   rax,rax
    18d5:	jne    1910 <botlish_fn_13+0x22d>
    18db:	mov    rdi,QWORD PTR [rsp+0x10]
    18e0:	mov    rdi,QWORD PTR [rsp+0x10]
    18e5:	mov    QWORD PTR [rdi],r12
    18e8:	xor    rdx,rdx
    18eb:	mov    rax,rdx
    18ee:	mov    rbx,QWORD PTR [rsp+0x40]
    18f3:	mov    r12,QWORD PTR [rsp+0x48]
    18f8:	mov    r13,QWORD PTR [rsp+0x50]
    18fd:	mov    r14,QWORD PTR [rsp+0x58]
    1902:	mov    r15,QWORD PTR [rsp+0x60]
    1907:	add    rsp,0x70
    190b:	mov    rsp,rbp
    190e:	pop    rbp
    190f:	ret
    1910:	mov    QWORD PTR [r12],rax
    1914:	mov    rbx,rax
    1917:	mov    QWORD PTR [r12+0x8],0x3
    1920:	mov    rdx,QWORD PTR [rsp+0x30]
    1925:	test   rdx,0x1
    192c:	je     1950 <botlish_fn_13+0x26d>
    1932:	mov    rdx,QWORD PTR [rsp+0x30]
    1937:	add    rdx,0x2
    193b:	seto   al
    193e:	test   al,al
    1940:	jne    1950 <botlish_fn_13+0x26d>
    1946:	mov    rdi,QWORD PTR [rsp+0x10]
    194b:	jmp    1970 <botlish_fn_13+0x28d>
    1950:	mov    edx,0x3
    1955:	mov    rax,QWORD PTR [rip+0x0]        # 195c <botlish_fn_13+0x279>
			1958: R_X86_64_GOTPCREL	rt_int_add-0x4
    195c:	mov    rsi,QWORD PTR [rsp+0x30]
    1961:	mov    rdi,QWORD PTR [rsp+0x10]
    1966:	call   rax
    1968:	mov    rdx,rax
    196b:	mov    rdi,QWORD PTR [rsp+0x10]
    1970:	mov    rdi,QWORD PTR [rsp+0x10]
    1975:	mov    QWORD PTR [rdi],r12
    1978:	mov    rax,rbx
    197b:	mov    rbx,QWORD PTR [rsp+0x40]
    1980:	mov    r12,QWORD PTR [rsp+0x48]
    1985:	mov    r13,QWORD PTR [rsp+0x50]
    198a:	mov    r14,QWORD PTR [rsp+0x58]
    198f:	mov    r15,QWORD PTR [rsp+0x60]
    1994:	add    rsp,0x70
    1998:	mov    rsp,rbp
    199b:	pop    rbp
    199c:	ret
    199d:	mov    rsi,QWORD PTR [rsp+0x30]
    19a2:	mov    edx,0x3
    19a7:	mov    rcx,rdx
    19aa:	mov    QWORD PTR [r12+0x18],0x3
    19b3:	test   rsi,0x1
    19ba:	je     19d2 <botlish_fn_13+0x2ef>
    19c0:	mov    rdx,rsi
    19c3:	add    rdx,0x2
    19c7:	seto   al
    19ca:	test   al,al
    19cc:	je     19e6 <botlish_fn_13+0x303>
    19d2:	mov    rax,QWORD PTR [rip+0x0]        # 19d9 <botlish_fn_13+0x2f6>
			19d5: R_X86_64_GOTPCREL	rt_int_add-0x4
    19d9:	mov    rdx,rcx
    19dc:	mov    rdi,QWORD PTR [rsp+0x10]
    19e1:	call   rax
    19e3:	mov    rdx,rax
    19e6:	mov    QWORD PTR [r12],r15
    19ea:	mov    QWORD PTR [r12+0x8],rdx
    19ef:	mov    rsi,QWORD PTR [rsp+0x20]
    19f4:	mov    QWORD PTR [r12+0x10],rsi
    19f9:	mov    rax,QWORD PTR [rsp+0x28]
    19fe:	mov    QWORD PTR [r12+0x18],rax
    1a03:	mov    r13,rax
    1a06:	mov    r14,rsi
    1a09:	jmp    1772 <botlish_fn_13+0x8f>
    1a0e:	mov    QWORD PTR [rsp+0x10],rdi
    1a13:	mov    rax,QWORD PTR [rip+0x0]        # 1a1a <botlish_fn_13+0x337>
			1a16: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1a1a:	call   rax
    1a1c:	xor    rdx,rdx
    1a1f:	mov    rax,rdx
    1a22:	mov    rbx,QWORD PTR [rsp+0x40]
    1a27:	mov    r12,QWORD PTR [rsp+0x48]
    1a2c:	mov    r13,QWORD PTR [rsp+0x50]
    1a31:	mov    r14,QWORD PTR [rsp+0x58]
    1a36:	mov    r15,QWORD PTR [rsp+0x60]
    1a3b:	add    rsp,0x70
    1a3f:	mov    rsp,rbp
    1a42:	pop    rbp
    1a43:	ret

0000000000001a44 <botlish_entry_13: scan_record<str, int, list[mutarray, int]>>:
    1a44:	push   rbp
    1a45:	mov    rbp,rsp
    1a48:	ud2
    1a4a:	add    BYTE PTR [rax],al
    1a4c:	add    BYTE PTR [rax],al
	...

0000000000001a50 <botlish_fn_14: scan_records<str, int, list[mutarray, int]>>:
    1a50:	push   rbp
    1a51:	mov    rbp,rsp
    1a54:	sub    rsp,0x40
    1a58:	mov    QWORD PTR [rsp+0x10],rbx
    1a5d:	mov    QWORD PTR [rsp+0x18],r12
    1a62:	mov    QWORD PTR [rsp+0x20],r13
    1a67:	mov    QWORD PTR [rsp+0x28],r14
    1a6c:	mov    QWORD PTR [rsp+0x30],r15
    1a71:	mov    r12,QWORD PTR [rdi]
    1a74:	mov    rax,QWORD PTR [rdi+0x8]
    1a78:	lea    r9,[r12+0x30]
    1a7d:	cmp    r9,rax
    1a80:	ja     1c54 <botlish_fn_14+0x204>
    1a86:	lea    rax,[r12+0x30]
    1a8b:	mov    QWORD PTR [rdi],rax
    1a8e:	mov    r14,rdi
    1a91:	mov    QWORD PTR [r12],0x0
    1a99:	mov    QWORD PTR [r12+0x8],0x0
    1aa2:	mov    QWORD PTR [r12+0x10],0x0
    1aab:	mov    QWORD PTR [r12+0x18],0x0
    1ab4:	mov    QWORD PTR [r12+0x20],0x0
    1abd:	mov    QWORD PTR [r12+0x28],0x0
    1ac6:	mov    QWORD PTR [r12],rsi
    1aca:	mov    QWORD PTR [r12+0x8],rdx
    1acf:	mov    r13,rdx
    1ad2:	mov    QWORD PTR [r12+0x10],rcx
    1ad7:	mov    QWORD PTR [r12+0x18],r8
    1adc:	mov    r15,r8
    1adf:	mov    QWORD PTR [rsp],rcx
    1ae3:	mov    rax,QWORD PTR [rip+0x0]        # 1aea <botlish_fn_14+0x9a>
			1ae6: R_X86_64_GOTPCREL	rt_str_len-0x4
    1aea:	mov    rbx,rsi
    1aed:	mov    rdi,r14
    1af0:	call   rax
    1af2:	mov    rcx,r13
    1af5:	and    rcx,rax
    1af8:	mov    rdx,rax
    1afb:	test   rcx,0x1
    1b02:	jne    1b2c <botlish_fn_14+0xdc>
    1b08:	mov    rax,QWORD PTR [rip+0x0]        # 1b0f <botlish_fn_14+0xbf>
			1b0b: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1b0f:	mov    rsi,r13
    1b12:	mov    rdi,r14
    1b15:	call   rax
    1b17:	mov    ecx,0x2
    1b1c:	test   rax,rax
    1b1f:	cmovge rcx,QWORD PTR [rip+0x161]        # 1c88 <botlish_fn_14+0x238>
    1b27:	jmp    1b3f <botlish_fn_14+0xef>
    1b2c:	mov    ecx,0x2
    1b31:	mov    rax,r13
    1b34:	cmp    rax,rdx
    1b37:	cmovge rcx,QWORD PTR [rip+0x149]        # 1c88 <botlish_fn_14+0x238>
    1b3f:	cmp    rcx,0x6
    1b43:	je     1be6 <botlish_fn_14+0x196>
    1b49:	mov    rdi,r14
    1b4c:	call   1b51 <botlish_fn_14+0x101>
			1b4d: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1b51:	test   rax,rax
    1b54:	jne    1b62 <botlish_fn_14+0x112>
    1b5a:	mov    rdi,r14
    1b5d:	jmp    1c01 <botlish_fn_14+0x1b1>
    1b62:	mov    QWORD PTR [r12+0x20],rax
    1b67:	mov    rcx,rax
    1b6a:	mov    QWORD PTR [r12+0x28],rdx
    1b6f:	mov    r8,rdx
    1b72:	mov    rdx,r13
    1b75:	mov    rsi,rbx
    1b78:	mov    rdi,r14
    1b7b:	call   1b80 <botlish_fn_14+0x130>
			1b7c: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_record<str, int, list[mutarray, int]>
    1b80:	test   rax,rax
    1b83:	jne    1b91 <botlish_fn_14+0x141>
    1b89:	mov    rdi,r14
    1b8c:	jmp    1c01 <botlish_fn_14+0x1b1>
    1b91:	mov    QWORD PTR [r12+0x8],rax
    1b96:	mov    rcx,rax
    1b99:	mov    QWORD PTR [r12+0x20],rdx
    1b9e:	mov    r13,rdx
    1ba1:	mov    rsi,QWORD PTR [rsp]
    1ba5:	mov    rdx,r15
    1ba8:	mov    rdi,r14
    1bab:	call   1bb0 <botlish_fn_14+0x160>
			1bac: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1bb0:	test   rax,rax
    1bb3:	jne    1bc1 <botlish_fn_14+0x171>
    1bb9:	mov    rdi,r14
    1bbc:	jmp    1c01 <botlish_fn_14+0x1b1>
    1bc1:	mov    QWORD PTR [r12],rbx
    1bc5:	mov    rcx,r13
    1bc8:	mov    QWORD PTR [r12+0x8],rcx
    1bcd:	mov    QWORD PTR [r12+0x10],rax
    1bd2:	mov    QWORD PTR [r12+0x18],rdx
    1bd7:	mov    rsi,rbx
    1bda:	mov    r15,rdx
    1bdd:	mov    QWORD PTR [rsp],rax
    1be1:	jmp    1ae3 <botlish_fn_14+0x93>
    1be6:	mov    rdx,r15
    1be9:	mov    rsi,QWORD PTR [rsp]
    1bed:	mov    rdi,r14
    1bf0:	call   1bf5 <botlish_fn_14+0x1a5>
			1bf1: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    1bf5:	test   rax,rax
    1bf8:	jne    1c2c <botlish_fn_14+0x1dc>
    1bfe:	mov    rdi,r14
    1c01:	mov    rdi,r14
    1c04:	mov    QWORD PTR [rdi],r12
    1c07:	xor    rax,rax
    1c0a:	mov    rbx,QWORD PTR [rsp+0x10]
    1c0f:	mov    r12,QWORD PTR [rsp+0x18]
    1c14:	mov    r13,QWORD PTR [rsp+0x20]
    1c19:	mov    r14,QWORD PTR [rsp+0x28]
    1c1e:	mov    r15,QWORD PTR [rsp+0x30]
    1c23:	add    rsp,0x40
    1c27:	mov    rsp,rbp
    1c2a:	pop    rbp
    1c2b:	ret
    1c2c:	mov    rdi,r14
    1c2f:	mov    QWORD PTR [rdi],r12
    1c32:	mov    rbx,QWORD PTR [rsp+0x10]
    1c37:	mov    r12,QWORD PTR [rsp+0x18]
    1c3c:	mov    r13,QWORD PTR [rsp+0x20]
    1c41:	mov    r14,QWORD PTR [rsp+0x28]
    1c46:	mov    r15,QWORD PTR [rsp+0x30]
    1c4b:	add    rsp,0x40
    1c4f:	mov    rsp,rbp
    1c52:	pop    rbp
    1c53:	ret
    1c54:	mov    r14,rdi
    1c57:	mov    rax,QWORD PTR [rip+0x0]        # 1c5e <botlish_fn_14+0x20e>
			1c5a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1c5e:	call   rax
    1c60:	xor    rax,rax
    1c63:	mov    rbx,QWORD PTR [rsp+0x10]
    1c68:	mov    r12,QWORD PTR [rsp+0x18]
    1c6d:	mov    r13,QWORD PTR [rsp+0x20]
    1c72:	mov    r14,QWORD PTR [rsp+0x28]
    1c77:	mov    r15,QWORD PTR [rsp+0x30]
    1c7c:	add    rsp,0x40
    1c80:	mov    rsp,rbp
    1c83:	pop    rbp
    1c84:	ret
    1c85:	add    BYTE PTR [rax],al
    1c87:	add    BYTE PTR [rsi],al
    1c89:	add    BYTE PTR [rax],al
    1c8b:	add    BYTE PTR [rax],al
    1c8d:	add    BYTE PTR [rax],al
	...

0000000000001c90 <botlish_entry_14: scan_records<str, int, list[mutarray, int]>>:
    1c90:	push   rbp
    1c91:	mov    rbp,rsp
    1c94:	mov    rsi,QWORD PTR [rdx]
    1c97:	mov    r9,QWORD PTR [rdx+0x8]
    1c9b:	mov    rcx,QWORD PTR [rdx+0x10]
    1c9f:	mov    r8,QWORD PTR [rdx+0x18]
    1ca3:	mov    rdx,r9
    1ca6:	call   1cab <botlish_entry_14+0x1b>
			1ca7: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1cab:	mov    rsp,rbp
    1cae:	pop    rbp
    1caf:	ret

0000000000001cb0 <botlish_fn_15: csv_parse<str>>:
    1cb0:	push   rbp
    1cb1:	mov    rbp,rsp
    1cb4:	sub    rsp,0x20
    1cb8:	mov    QWORD PTR [rsp],rbx
    1cbc:	mov    QWORD PTR [rsp+0x8],r12
    1cc1:	mov    QWORD PTR [rsp+0x10],r13
    1cc6:	mov    rbx,QWORD PTR [rdi]
    1cc9:	mov    rax,QWORD PTR [rdi+0x8]
    1ccd:	lea    rcx,[rbx+0x20]
    1cd1:	cmp    rcx,rax
    1cd4:	ja     1d91 <botlish_fn_15+0xe1>
    1cda:	lea    rax,[rbx+0x20]
    1cde:	mov    QWORD PTR [rdi],rax
    1ce1:	mov    r12,rdi
    1ce4:	mov    QWORD PTR [rbx],0x0
    1ceb:	mov    QWORD PTR [rbx+0x8],0x0
    1cf3:	mov    QWORD PTR [rbx+0x10],0x0
    1cfb:	mov    QWORD PTR [rbx+0x18],0x0
    1d03:	mov    QWORD PTR [rbx],rsi
    1d06:	mov    r13,rsi
    1d09:	mov    QWORD PTR [rbx+0x8],0x1
    1d11:	mov    rdi,r12
    1d14:	call   1d19 <botlish_fn_15+0x69>
			1d15: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1d19:	test   rax,rax
    1d1c:	jne    1d2a <botlish_fn_15+0x7a>
    1d22:	mov    rdi,r12
    1d25:	jmp    1d54 <botlish_fn_15+0xa4>
    1d2a:	mov    QWORD PTR [rbx+0x10],rax
    1d2e:	mov    rcx,rax
    1d31:	mov    QWORD PTR [rbx+0x18],rdx
    1d35:	mov    r8,rdx
    1d38:	mov    edx,0x1
    1d3d:	mov    rsi,r13
    1d40:	mov    rdi,r12
    1d43:	call   1d48 <botlish_fn_15+0x98>
			1d44: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1d48:	test   rax,rax
    1d4b:	jne    1d74 <botlish_fn_15+0xc4>
    1d51:	mov    rdi,r12
    1d54:	mov    rdi,r12
    1d57:	mov    QWORD PTR [rdi],rbx
    1d5a:	xor    rax,rax
    1d5d:	mov    rbx,QWORD PTR [rsp]
    1d61:	mov    r12,QWORD PTR [rsp+0x8]
    1d66:	mov    r13,QWORD PTR [rsp+0x10]
    1d6b:	add    rsp,0x20
    1d6f:	mov    rsp,rbp
    1d72:	pop    rbp
    1d73:	ret
    1d74:	mov    rdi,r12
    1d77:	mov    QWORD PTR [rdi],rbx
    1d7a:	mov    rbx,QWORD PTR [rsp]
    1d7e:	mov    r12,QWORD PTR [rsp+0x8]
    1d83:	mov    r13,QWORD PTR [rsp+0x10]
    1d88:	add    rsp,0x20
    1d8c:	mov    rsp,rbp
    1d8f:	pop    rbp
    1d90:	ret
    1d91:	mov    r12,rdi
    1d94:	mov    rax,QWORD PTR [rip+0x0]        # 1d9b <botlish_fn_15+0xeb>
			1d97: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1d9b:	call   rax
    1d9d:	xor    rax,rax
    1da0:	mov    rbx,QWORD PTR [rsp]
    1da4:	mov    r12,QWORD PTR [rsp+0x8]
    1da9:	mov    r13,QWORD PTR [rsp+0x10]
    1dae:	add    rsp,0x20
    1db2:	mov    rsp,rbp
    1db5:	pop    rbp
    1db6:	ret

0000000000001db7 <botlish_entry_15: csv_parse<str>>:
    1db7:	push   rbp
    1db8:	mov    rbp,rsp
    1dbb:	mov    rsi,QWORD PTR [rdx]
    1dbe:	call   1dc3 <botlish_entry_15+0xc>
			1dbf: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    1dc3:	mov    rsp,rbp
    1dc6:	pop    rbp
    1dc7:	ret

0000000000001dc8 <botlish_fn_16: ht_min_capacity<generic>>:
    1dc8:	push   rbp
    1dc9:	mov    rbp,rsp
    1dcc:	mov    r10,QWORD PTR [rdi]
    1dcf:	mov    r11,QWORD PTR [rdi+0x8]
    1dd3:	lea    rax,[r10+0x8]
    1dd7:	cmp    rax,r11
    1dda:	ja     1dfb <botlish_fn_16+0x33>
    1de0:	lea    rax,[r10+0x8]
    1de4:	mov    QWORD PTR [rdi],rax
    1de7:	mov    QWORD PTR [r10],0x0
    1dee:	mov    QWORD PTR [rdi],r10
    1df1:	mov    eax,0x11
    1df6:	mov    rsp,rbp
    1df9:	pop    rbp
    1dfa:	ret
    1dfb:	mov    rax,QWORD PTR [rip+0x0]        # 1e02 <botlish_fn_16+0x3a>
			1dfe: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1e02:	call   rax
    1e04:	xor    rax,rax
    1e07:	mov    rsp,rbp
    1e0a:	pop    rbp
    1e0b:	ret

0000000000001e0c <botlish_entry_16: ht_min_capacity<generic>>:
    1e0c:	push   rbp
    1e0d:	mov    rbp,rsp
    1e10:	call   1e15 <botlish_entry_16+0x9>
			1e11: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    1e15:	mov    rsp,rbp
    1e18:	pop    rbp
    1e19:	ret

0000000000001e1a <botlish_fn_17: ht_empty_state<generic>>:
    1e1a:	push   rbp
    1e1b:	mov    rbp,rsp
    1e1e:	mov    r10,QWORD PTR [rdi]
    1e21:	mov    r11,QWORD PTR [rdi+0x8]
    1e25:	lea    rax,[r10+0x8]
    1e29:	cmp    rax,r11
    1e2c:	ja     1e4d <botlish_fn_17+0x33>
    1e32:	lea    rax,[r10+0x8]
    1e36:	mov    QWORD PTR [rdi],rax
    1e39:	mov    QWORD PTR [r10],0x0
    1e40:	mov    QWORD PTR [rdi],r10
    1e43:	mov    eax,0x1
    1e48:	mov    rsp,rbp
    1e4b:	pop    rbp
    1e4c:	ret
    1e4d:	mov    rax,QWORD PTR [rip+0x0]        # 1e54 <botlish_fn_17+0x3a>
			1e50: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1e54:	call   rax
    1e56:	xor    rax,rax
    1e59:	mov    rsp,rbp
    1e5c:	pop    rbp
    1e5d:	ret

0000000000001e5e <botlish_entry_17: ht_empty_state<generic>>:
    1e5e:	push   rbp
    1e5f:	mov    rbp,rsp
    1e62:	call   1e67 <botlish_entry_17+0x9>
			1e63: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    1e67:	mov    rsp,rbp
    1e6a:	pop    rbp
    1e6b:	ret

0000000000001e6c <botlish_fn_18: ht_occupied_state<generic>>:
    1e6c:	push   rbp
    1e6d:	mov    rbp,rsp
    1e70:	mov    r10,QWORD PTR [rdi]
    1e73:	mov    r11,QWORD PTR [rdi+0x8]
    1e77:	lea    rax,[r10+0x8]
    1e7b:	cmp    rax,r11
    1e7e:	ja     1e9f <botlish_fn_18+0x33>
    1e84:	lea    rax,[r10+0x8]
    1e88:	mov    QWORD PTR [rdi],rax
    1e8b:	mov    QWORD PTR [r10],0x0
    1e92:	mov    QWORD PTR [rdi],r10
    1e95:	mov    eax,0x3
    1e9a:	mov    rsp,rbp
    1e9d:	pop    rbp
    1e9e:	ret
    1e9f:	mov    rax,QWORD PTR [rip+0x0]        # 1ea6 <botlish_fn_18+0x3a>
			1ea2: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1ea6:	call   rax
    1ea8:	xor    rax,rax
    1eab:	mov    rsp,rbp
    1eae:	pop    rbp
    1eaf:	ret

0000000000001eb0 <botlish_entry_18: ht_occupied_state<generic>>:
    1eb0:	push   rbp
    1eb1:	mov    rbp,rsp
    1eb4:	call   1eb9 <botlish_entry_18+0x9>
			1eb5: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    1eb9:	mov    rsp,rbp
    1ebc:	pop    rbp
    1ebd:	ret

0000000000001ebe <botlish_fn_19: ht_tombstone_state<generic>>:
    1ebe:	push   rbp
    1ebf:	mov    rbp,rsp
    1ec2:	mov    r10,QWORD PTR [rdi]
    1ec5:	mov    r11,QWORD PTR [rdi+0x8]
    1ec9:	lea    rax,[r10+0x8]
    1ecd:	cmp    rax,r11
    1ed0:	ja     1ef1 <botlish_fn_19+0x33>
    1ed6:	lea    rax,[r10+0x8]
    1eda:	mov    QWORD PTR [rdi],rax
    1edd:	mov    QWORD PTR [r10],0x0
    1ee4:	mov    QWORD PTR [rdi],r10
    1ee7:	mov    eax,0x5
    1eec:	mov    rsp,rbp
    1eef:	pop    rbp
    1ef0:	ret
    1ef1:	mov    rax,QWORD PTR [rip+0x0]        # 1ef8 <botlish_fn_19+0x3a>
			1ef4: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1ef8:	call   rax
    1efa:	xor    rax,rax
    1efd:	mov    rsp,rbp
    1f00:	pop    rbp
    1f01:	ret

0000000000001f02 <botlish_entry_19: ht_tombstone_state<generic>>:
    1f02:	push   rbp
    1f03:	mov    rbp,rsp
    1f06:	call   1f0b <botlish_entry_19+0x9>
			1f07: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    1f0b:	mov    rsp,rbp
    1f0e:	pop    rbp
    1f0f:	ret

0000000000001f10 <botlish_fn_20: ht_fill_empty<mutarray, int, int>>:
    1f10:	push   rbp
    1f11:	mov    rbp,rsp
    1f14:	sub    rsp,0x30
    1f18:	mov    QWORD PTR [rsp],rbx
    1f1c:	mov    QWORD PTR [rsp+0x8],r12
    1f21:	mov    QWORD PTR [rsp+0x10],r13
    1f26:	mov    QWORD PTR [rsp+0x18],r14
    1f2b:	mov    QWORD PTR [rsp+0x20],r15
    1f30:	mov    r13,QWORD PTR [rdi]
    1f33:	mov    r8,QWORD PTR [rdi+0x8]
    1f37:	lea    rax,[r13+0x20]
    1f3b:	cmp    rax,r8
    1f3e:	ja     20cf <botlish_fn_20+0x1bf>
    1f44:	lea    rax,[r13+0x20]
    1f48:	mov    QWORD PTR [rdi],rax
    1f4b:	mov    r14,rdi
    1f4e:	mov    QWORD PTR [r13+0x0],0x0
    1f56:	mov    QWORD PTR [r13+0x8],0x0
    1f5e:	mov    QWORD PTR [r13+0x10],0x0
    1f66:	mov    QWORD PTR [r13+0x18],0x0
    1f6e:	mov    QWORD PTR [r13+0x0],rsi
    1f72:	mov    r12,rsi
    1f75:	mov    QWORD PTR [r13+0x8],rdx
    1f79:	mov    QWORD PTR [r13+0x10],rcx
    1f7d:	mov    rbx,rcx
    1f80:	mov    rsi,rdx
    1f83:	mov    rax,rsi
    1f86:	and    rax,rbx
    1f89:	mov    r15,rsi
    1f8c:	test   rax,0x1
    1f92:	jne    1fbf <botlish_fn_20+0xaf>
    1f98:	mov    rax,QWORD PTR [rip+0x0]        # 1f9f <botlish_fn_20+0x8f>
			1f9b: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1f9f:	mov    rdx,rbx
    1fa2:	mov    rsi,r15
    1fa5:	mov    rdi,r14
    1fa8:	call   rax
    1faa:	mov    ecx,0x2
    1faf:	test   rax,rax
    1fb2:	cmovge rcx,QWORD PTR [rip+0x146]        # 2100 <botlish_fn_20+0x1f0>
    1fba:	jmp    1fd2 <botlish_fn_20+0xc2>
    1fbf:	mov    ecx,0x2
    1fc4:	mov    rsi,r15
    1fc7:	cmp    rsi,rbx
    1fca:	cmovge rcx,QWORD PTR [rip+0x12e]        # 2100 <botlish_fn_20+0x1f0>
    1fd2:	cmp    rcx,0x6
    1fd6:	je     20a3 <botlish_fn_20+0x193>
    1fdc:	mov    rdi,r14
    1fdf:	call   1fe4 <botlish_fn_20+0xd4>
			1fe0: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    1fe4:	test   rax,rax
    1fe7:	mov    rcx,rax
    1fea:	jne    1ff8 <botlish_fn_20+0xe8>
    1ff0:	mov    rdi,r14
    1ff3:	jmp    2016 <botlish_fn_20+0x106>
    1ff8:	mov    rax,QWORD PTR [rip+0x0]        # 1fff <botlish_fn_20+0xef>
			1ffb: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    1fff:	mov    rdx,r15
    2002:	mov    rsi,r12
    2005:	mov    rdi,r14
    2008:	call   rax
    200a:	test   rax,rax
    200d:	jne    2040 <botlish_fn_20+0x130>
    2013:	mov    rdi,r14
    2016:	mov    rdi,r14
    2019:	mov    QWORD PTR [rdi],r13
    201c:	xor    rax,rax
    201f:	mov    rbx,QWORD PTR [rsp]
    2023:	mov    r12,QWORD PTR [rsp+0x8]
    2028:	mov    r13,QWORD PTR [rsp+0x10]
    202d:	mov    r14,QWORD PTR [rsp+0x18]
    2032:	mov    r15,QWORD PTR [rsp+0x20]
    2037:	add    rsp,0x30
    203b:	mov    rsp,rbp
    203e:	pop    rbp
    203f:	ret
    2040:	mov    QWORD PTR [r13+0x18],0x3
    2048:	mov    rsi,r15
    204b:	test   rsi,0x1
    2052:	je     2077 <botlish_fn_20+0x167>
    2058:	mov    rsi,r15
    205b:	mov    rcx,rsi
    205e:	add    rcx,0x2
    2062:	seto   sil
    2066:	test   sil,sil
    2069:	jne    2077 <botlish_fn_20+0x167>
    206f:	mov    r15,rcx
    2072:	jmp    208f <botlish_fn_20+0x17f>
    2077:	mov    edx,0x3
    207c:	mov    r8,QWORD PTR [rip+0x0]        # 2083 <botlish_fn_20+0x173>
			207f: R_X86_64_GOTPCREL	rt_int_add-0x4
    2083:	mov    rsi,r15
    2086:	mov    rdi,r14
    2089:	call   r8
    208c:	mov    r15,rax
    208f:	mov    QWORD PTR [r13+0x0],r12
    2093:	mov    rsi,r15
    2096:	mov    QWORD PTR [r13+0x8],rsi
    209a:	mov    QWORD PTR [r13+0x10],rbx
    209e:	jmp    1f83 <botlish_fn_20+0x73>
    20a3:	mov    rdi,r14
    20a6:	mov    QWORD PTR [rdi],r13
    20a9:	mov    eax,0xa
    20ae:	mov    rbx,QWORD PTR [rsp]
    20b2:	mov    r12,QWORD PTR [rsp+0x8]
    20b7:	mov    r13,QWORD PTR [rsp+0x10]
    20bc:	mov    r14,QWORD PTR [rsp+0x18]
    20c1:	mov    r15,QWORD PTR [rsp+0x20]
    20c6:	add    rsp,0x30
    20ca:	mov    rsp,rbp
    20cd:	pop    rbp
    20ce:	ret
    20cf:	mov    r14,rdi
    20d2:	mov    rax,QWORD PTR [rip+0x0]        # 20d9 <botlish_fn_20+0x1c9>
			20d5: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    20d9:	call   rax
    20db:	xor    rax,rax
    20de:	mov    rbx,QWORD PTR [rsp]
    20e2:	mov    r12,QWORD PTR [rsp+0x8]
    20e7:	mov    r13,QWORD PTR [rsp+0x10]
    20ec:	mov    r14,QWORD PTR [rsp+0x18]
    20f1:	mov    r15,QWORD PTR [rsp+0x20]
    20f6:	add    rsp,0x30
    20fa:	mov    rsp,rbp
    20fd:	pop    rbp
    20fe:	ret
    20ff:	add    BYTE PTR [rsi],al
    2101:	add    BYTE PTR [rax],al
    2103:	add    BYTE PTR [rax],al
    2105:	add    BYTE PTR [rax],al
	...

0000000000002108 <botlish_entry_20: ht_fill_empty<mutarray, int, int>>:
    2108:	push   rbp
    2109:	mov    rbp,rsp
    210c:	mov    rsi,QWORD PTR [rdx]
    210f:	mov    r8,QWORD PTR [rdx+0x8]
    2113:	mov    rcx,QWORD PTR [rdx+0x10]
    2117:	mov    rdx,r8
    211a:	call   211f <botlish_entry_20+0x17>
			211b: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    211f:	mov    rsp,rbp
    2122:	pop    rbp
    2123:	ret

0000000000002124 <botlish_fn_21: ht_alloc<int>>:
    2124:	push   rbp
    2125:	mov    rbp,rsp
    2128:	sub    rsp,0x40
    212c:	mov    QWORD PTR [rsp+0x10],rbx
    2131:	mov    QWORD PTR [rsp+0x18],r12
    2136:	mov    QWORD PTR [rsp+0x20],r13
    213b:	mov    QWORD PTR [rsp+0x28],r14
    2140:	mov    QWORD PTR [rsp+0x30],r15
    2145:	mov    rbx,QWORD PTR [rdi]
    2148:	mov    rax,QWORD PTR [rdi+0x8]
    214c:	lea    rcx,[rbx+0x20]
    2150:	cmp    rcx,rax
    2153:	ja     237c <botlish_fn_21+0x258>
    2159:	lea    rax,[rbx+0x20]
    215d:	mov    QWORD PTR [rdi],rax
    2160:	mov    r12,rdi
    2163:	mov    QWORD PTR [rbx],0x0
    216a:	mov    QWORD PTR [rbx+0x8],0x0
    2172:	mov    QWORD PTR [rbx+0x10],0x0
    217a:	mov    QWORD PTR [rbx+0x18],0x0
    2182:	mov    QWORD PTR [rbx],rsi
    2185:	mov    r13,rsi
    2188:	mov    rax,QWORD PTR [rip+0x0]        # 218f <botlish_fn_21+0x6b>
			218b: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    218f:	mov    rsi,r13
    2192:	mov    rdi,r12
    2195:	call   rax
    2197:	test   rax,rax
    219a:	jne    21a8 <botlish_fn_21+0x84>
    21a0:	mov    rdi,r12
    21a3:	jmp    2325 <botlish_fn_21+0x201>
    21a8:	mov    QWORD PTR [rbx+0x8],rax
    21ac:	mov    r14,rax
    21af:	mov    edx,0x1
    21b4:	mov    QWORD PTR [rbx+0x10],0x1
    21bc:	mov    rcx,r13
    21bf:	mov    rsi,r14
    21c2:	mov    rdi,r12
    21c5:	call   21ca <botlish_fn_21+0xa6>
			21c6: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    21ca:	test   rax,rax
    21cd:	jne    21db <botlish_fn_21+0xb7>
    21d3:	mov    rdi,r12
    21d6:	jmp    2325 <botlish_fn_21+0x201>
    21db:	mov    rax,QWORD PTR [rip+0x0]        # 21e2 <botlish_fn_21+0xbe>
			21de: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    21e2:	mov    rsi,r13
    21e5:	mov    rdi,r12
    21e8:	call   rax
    21ea:	test   rax,rax
    21ed:	jne    21fb <botlish_fn_21+0xd7>
    21f3:	mov    rdi,r12
    21f6:	jmp    2325 <botlish_fn_21+0x201>
    21fb:	mov    QWORD PTR [rbx+0x10],rax
    21ff:	mov    r15,rax
    2202:	mov    rax,QWORD PTR [rip+0x0]        # 2209 <botlish_fn_21+0xe5>
			2205: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    2209:	mov    rsi,r13
    220c:	mov    rdi,r12
    220f:	call   rax
    2211:	test   rax,rax
    2214:	jne    2222 <botlish_fn_21+0xfe>
    221a:	mov    rdi,r12
    221d:	jmp    2325 <botlish_fn_21+0x201>
    2222:	mov    QWORD PTR [rbx],rax
    2225:	mov    r13,rax
    2228:	mov    esi,0xb
    222d:	mov    QWORD PTR [rbx+0x18],0xb
    2235:	mov    r8,QWORD PTR [rip+0x0]        # 223c <botlish_fn_21+0x118>
			2238: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    223c:	mov    rdi,r12
    223f:	call   r8
    2242:	test   rax,rax
    2245:	mov    QWORD PTR [rsp],rax
    2249:	jne    2257 <botlish_fn_21+0x133>
    224f:	mov    rdi,r12
    2252:	jmp    2325 <botlish_fn_21+0x201>
    2257:	mov    edx,0x1
    225c:	mov    r8,QWORD PTR [rip+0x0]        # 2263 <botlish_fn_21+0x13f>
			225f: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    2263:	mov    rcx,r14
    2266:	mov    rsi,QWORD PTR [rsp]
    226a:	mov    rdi,r12
    226d:	call   r8
    2270:	test   rax,rax
    2273:	jne    2281 <botlish_fn_21+0x15d>
    2279:	mov    rdi,r12
    227c:	jmp    2325 <botlish_fn_21+0x201>
    2281:	mov    edx,0x3
    2286:	mov    r9,QWORD PTR [rip+0x0]        # 228d <botlish_fn_21+0x169>
			2289: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    228d:	mov    rcx,r15
    2290:	mov    rsi,QWORD PTR [rsp]
    2294:	mov    rdi,r12
    2297:	call   r9
    229a:	test   rax,rax
    229d:	jne    22ab <botlish_fn_21+0x187>
    22a3:	mov    rdi,r12
    22a6:	jmp    2325 <botlish_fn_21+0x201>
    22ab:	mov    edx,0x5
    22b0:	mov    rax,QWORD PTR [rip+0x0]        # 22b7 <botlish_fn_21+0x193>
			22b3: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    22b7:	mov    rcx,r13
    22ba:	mov    rsi,QWORD PTR [rsp]
    22be:	mov    rdi,r12
    22c1:	call   rax
    22c3:	test   rax,rax
    22c6:	jne    22d4 <botlish_fn_21+0x1b0>
    22cc:	mov    rdi,r12
    22cf:	jmp    2325 <botlish_fn_21+0x201>
    22d4:	mov    edx,0x7
    22d9:	mov    ecx,0x1
    22de:	mov    rax,QWORD PTR [rip+0x0]        # 22e5 <botlish_fn_21+0x1c1>
			22e1: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    22e5:	mov    rsi,QWORD PTR [rsp]
    22e9:	mov    rdi,r12
    22ec:	call   rax
    22ee:	test   rax,rax
    22f1:	jne    22ff <botlish_fn_21+0x1db>
    22f7:	mov    rdi,r12
    22fa:	jmp    2325 <botlish_fn_21+0x201>
    22ff:	mov    edx,0x9
    2304:	mov    ecx,0x1
    2309:	mov    rax,QWORD PTR [rip+0x0]        # 2310 <botlish_fn_21+0x1ec>
			230c: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    2310:	mov    rsi,QWORD PTR [rsp]
    2314:	mov    rdi,r12
    2317:	call   rax
    2319:	test   rax,rax
    231c:	jne    2350 <botlish_fn_21+0x22c>
    2322:	mov    rdi,r12
    2325:	mov    rdi,r12
    2328:	mov    QWORD PTR [rdi],rbx
    232b:	xor    rax,rax
    232e:	mov    rbx,QWORD PTR [rsp+0x10]
    2333:	mov    r12,QWORD PTR [rsp+0x18]
    2338:	mov    r13,QWORD PTR [rsp+0x20]
    233d:	mov    r14,QWORD PTR [rsp+0x28]
    2342:	mov    r15,QWORD PTR [rsp+0x30]
    2347:	add    rsp,0x40
    234b:	mov    rsp,rbp
    234e:	pop    rbp
    234f:	ret
    2350:	mov    rdi,r12
    2353:	mov    QWORD PTR [rdi],rbx
    2356:	mov    rax,QWORD PTR [rsp]
    235a:	mov    rbx,QWORD PTR [rsp+0x10]
    235f:	mov    r12,QWORD PTR [rsp+0x18]
    2364:	mov    r13,QWORD PTR [rsp+0x20]
    2369:	mov    r14,QWORD PTR [rsp+0x28]
    236e:	mov    r15,QWORD PTR [rsp+0x30]
    2373:	add    rsp,0x40
    2377:	mov    rsp,rbp
    237a:	pop    rbp
    237b:	ret
    237c:	mov    r12,rdi
    237f:	mov    rax,QWORD PTR [rip+0x0]        # 2386 <botlish_fn_21+0x262>
			2382: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2386:	call   rax
    2388:	xor    rax,rax
    238b:	mov    rbx,QWORD PTR [rsp+0x10]
    2390:	mov    r12,QWORD PTR [rsp+0x18]
    2395:	mov    r13,QWORD PTR [rsp+0x20]
    239a:	mov    r14,QWORD PTR [rsp+0x28]
    239f:	mov    r15,QWORD PTR [rsp+0x30]
    23a4:	add    rsp,0x40
    23a8:	mov    rsp,rbp
    23ab:	pop    rbp
    23ac:	ret

00000000000023ad <botlish_entry_21: ht_alloc<int>>:
    23ad:	push   rbp
    23ae:	mov    rbp,rsp
    23b1:	mov    rsi,QWORD PTR [rdx]
    23b4:	call   23b9 <botlish_entry_21+0xc>
			23b5: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    23b9:	mov    rsp,rbp
    23bc:	pop    rbp
    23bd:	ret

00000000000023be <botlish_fn_22: ht_new<generic>>:
    23be:	push   rbp
    23bf:	mov    rbp,rsp
    23c2:	sub    rsp,0x10
    23c6:	mov    QWORD PTR [rsp],r13
    23ca:	mov    QWORD PTR [rsp+0x8],r14
    23cf:	mov    r13,QWORD PTR [rdi]
    23d2:	mov    rax,QWORD PTR [rdi+0x8]
    23d6:	lea    rcx,[r13+0x8]
    23da:	cmp    rcx,rax
    23dd:	ja     245c <botlish_fn_22+0x9e>
    23e3:	lea    rax,[r13+0x8]
    23e7:	mov    QWORD PTR [rdi],rax
    23ea:	mov    r14,rdi
    23ed:	mov    QWORD PTR [r13+0x0],0x0
    23f5:	mov    rdi,r14
    23f8:	call   23fd <botlish_fn_22+0x3f>
			23f9: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    23fd:	test   rax,rax
    2400:	jne    240e <botlish_fn_22+0x50>
    2406:	mov    rdi,r14
    2409:	jmp    2429 <botlish_fn_22+0x6b>
    240e:	mov    QWORD PTR [r13+0x0],rax
    2412:	mov    rsi,rax
    2415:	mov    rdi,r14
    2418:	call   241d <botlish_fn_22+0x5f>
			2419: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    241d:	test   rax,rax
    2420:	jne    2444 <botlish_fn_22+0x86>
    2426:	mov    rdi,r14
    2429:	mov    rdi,r14
    242c:	mov    QWORD PTR [rdi],r13
    242f:	xor    rax,rax
    2432:	mov    r13,QWORD PTR [rsp]
    2436:	mov    r14,QWORD PTR [rsp+0x8]
    243b:	add    rsp,0x10
    243f:	mov    rsp,rbp
    2442:	pop    rbp
    2443:	ret
    2444:	mov    rdi,r14
    2447:	mov    QWORD PTR [rdi],r13
    244a:	mov    r13,QWORD PTR [rsp]
    244e:	mov    r14,QWORD PTR [rsp+0x8]
    2453:	add    rsp,0x10
    2457:	mov    rsp,rbp
    245a:	pop    rbp
    245b:	ret
    245c:	mov    r14,rdi
    245f:	mov    rax,QWORD PTR [rip+0x0]        # 2466 <botlish_fn_22+0xa8>
			2462: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2466:	call   rax
    2468:	xor    rax,rax
    246b:	mov    r13,QWORD PTR [rsp]
    246f:	mov    r14,QWORD PTR [rsp+0x8]
    2474:	add    rsp,0x10
    2478:	mov    rsp,rbp
    247b:	pop    rbp
    247c:	ret

000000000000247d <botlish_entry_22: ht_new<generic>>:
    247d:	push   rbp
    247e:	mov    rbp,rsp
    2481:	call   2486 <botlish_entry_22+0x9>
			2482: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    2486:	mov    rsp,rbp
    2489:	pop    rbp
    248a:	ret
    248b:	add    BYTE PTR [rax],al
    248d:	add    BYTE PTR [rax],al
	...

0000000000002490 <botlish_fn_23: ht_capacity_for<int, int>>:
    2490:	push   rbp
    2491:	mov    rbp,rsp
    2494:	sub    rsp,0x40
    2498:	mov    QWORD PTR [rsp+0x10],rbx
    249d:	mov    QWORD PTR [rsp+0x18],r12
    24a2:	mov    QWORD PTR [rsp+0x20],r13
    24a7:	mov    QWORD PTR [rsp+0x28],r14
    24ac:	mov    QWORD PTR [rsp+0x30],r15
    24b1:	mov    rbx,QWORD PTR [rdi]
    24b4:	mov    rax,QWORD PTR [rdi+0x8]
    24b8:	lea    rcx,[rbx+0x18]
    24bc:	cmp    rcx,rax
    24bf:	ja     2680 <botlish_fn_23+0x1f0>
    24c5:	lea    rax,[rbx+0x18]
    24c9:	mov    QWORD PTR [rdi],rax
    24cc:	mov    r14,rdi
    24cf:	mov    QWORD PTR [rbx],0x0
    24d6:	mov    QWORD PTR [rbx+0x8],0x0
    24de:	mov    QWORD PTR [rbx+0x10],0x0
    24e6:	mov    QWORD PTR [rbx],rdx
    24e9:	mov    r12,rsi
    24ec:	or     r12,0x1
    24f0:	sar    r12,1
    24f3:	mov    r13,rsi
    24f6:	mov    r15,rdx
    24f9:	mov    rax,r13
    24fc:	or     rax,0x1
    2500:	mov    QWORD PTR [rbx+0x8],rax
    2504:	mov    QWORD PTR [rbx+0x10],0x7
    250c:	mov    rax,r12
    250f:	imul   QWORD PTR [rip+0x1a2]        # 26b8 <botlish_fn_23+0x228>
    2516:	seto   cl
    2519:	or     rax,0x1
    251d:	test   cl,cl
    251f:	jne    252d <botlish_fn_23+0x9d>
    2525:	mov    rsi,rax
    2528:	jmp    2548 <botlish_fn_23+0xb8>
    252d:	mov    rsi,r13
    2530:	or     rsi,0x1
    2534:	mov    edx,0x7
    2539:	mov    rax,QWORD PTR [rip+0x0]        # 2540 <botlish_fn_23+0xb0>
			253c: R_X86_64_GOTPCREL	rt_int_mul-0x4
    2540:	mov    rdi,r14
    2543:	call   rax
    2545:	mov    rsi,rax
    2548:	mov    QWORD PTR [rbx+0x8],rsi
    254c:	mov    QWORD PTR [rsp],rsi
    2550:	mov    QWORD PTR [rbx+0x10],0x5
    2558:	mov    rsi,r15
    255b:	test   rsi,0x1
    2562:	je     2595 <botlish_fn_23+0x105>
    2568:	mov    rsi,r15
    256b:	mov    rax,rsi
    256e:	sar    rax,1
    2571:	imul   QWORD PTR [rip+0x148]        # 26c0 <botlish_fn_23+0x230>
    2578:	seto   dil
    257c:	or     rax,0x1
    2580:	test   dil,dil
    2583:	jne    2595 <botlish_fn_23+0x105>
    2589:	mov    rdx,rax
    258c:	mov    rsi,QWORD PTR [rsp]
    2590:	jmp    25b1 <botlish_fn_23+0x121>
    2595:	mov    edx,0x5
    259a:	mov    r9,QWORD PTR [rip+0x0]        # 25a1 <botlish_fn_23+0x111>
			259d: R_X86_64_GOTPCREL	rt_int_mul-0x4
    25a1:	mov    rsi,r15
    25a4:	mov    rdi,r14
    25a7:	call   r9
    25aa:	mov    rdx,rax
    25ad:	mov    rsi,QWORD PTR [rsp]
    25b1:	mov    r10,rsi
    25b4:	and    r10,rdx
    25b7:	test   r10,0x1
    25be:	jne    25e5 <botlish_fn_23+0x155>
    25c4:	mov    rax,QWORD PTR [rip+0x0]        # 25cb <botlish_fn_23+0x13b>
			25c7: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    25cb:	mov    rdi,r14
    25ce:	call   rax
    25d0:	mov    ecx,0x2
    25d5:	test   rax,rax
    25d8:	cmovle rcx,QWORD PTR [rip+0xd8]        # 26b8 <botlish_fn_23+0x228>
    25e0:	jmp    25f5 <botlish_fn_23+0x165>
    25e5:	mov    ecx,0x2
    25ea:	cmp    rsi,rdx
    25ed:	cmovle rcx,QWORD PTR [rip+0xc3]        # 26b8 <botlish_fn_23+0x228>
    25f5:	cmp    rcx,0x6
    25f9:	je     2655 <botlish_fn_23+0x1c5>
    25ff:	mov    QWORD PTR [rbx+0x8],0x5
    2607:	mov    rsi,r15
    260a:	test   rsi,0x1
    2611:	je     2636 <botlish_fn_23+0x1a6>
    2617:	mov    rsi,r15
    261a:	mov    rax,rsi
    261d:	sar    rax,1
    2620:	imul   QWORD PTR [rip+0x99]        # 26c0 <botlish_fn_23+0x230>
    2627:	seto   cl
    262a:	or     rax,0x1
    262e:	test   cl,cl
    2630:	je     264a <botlish_fn_23+0x1ba>
    2636:	mov    edx,0x5
    263b:	mov    rax,QWORD PTR [rip+0x0]        # 2642 <botlish_fn_23+0x1b2>
			263e: R_X86_64_GOTPCREL	rt_int_mul-0x4
    2642:	mov    rsi,r15
    2645:	mov    rdi,r14
    2648:	call   rax
    264a:	mov    QWORD PTR [rbx],rax
    264d:	mov    r15,rax
    2650:	jmp    24f9 <botlish_fn_23+0x69>
    2655:	mov    rdi,r14
    2658:	mov    QWORD PTR [rdi],rbx
    265b:	mov    rax,r15
    265e:	mov    rbx,QWORD PTR [rsp+0x10]
    2663:	mov    r12,QWORD PTR [rsp+0x18]
    2668:	mov    r13,QWORD PTR [rsp+0x20]
    266d:	mov    r14,QWORD PTR [rsp+0x28]
    2672:	mov    r15,QWORD PTR [rsp+0x30]
    2677:	add    rsp,0x40
    267b:	mov    rsp,rbp
    267e:	pop    rbp
    267f:	ret
    2680:	mov    r14,rdi
    2683:	mov    rax,QWORD PTR [rip+0x0]        # 268a <botlish_fn_23+0x1fa>
			2686: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    268a:	call   rax
    268c:	xor    rax,rax
    268f:	mov    rbx,QWORD PTR [rsp+0x10]
    2694:	mov    r12,QWORD PTR [rsp+0x18]
    2699:	mov    r13,QWORD PTR [rsp+0x20]
    269e:	mov    r14,QWORD PTR [rsp+0x28]
    26a3:	mov    r15,QWORD PTR [rsp+0x30]
    26a8:	add    rsp,0x40
    26ac:	mov    rsp,rbp
    26af:	pop    rbp
    26b0:	ret
    26b1:	add    BYTE PTR [rax],al
    26b3:	add    BYTE PTR [rax],al
    26b5:	add    BYTE PTR [rax],al
    26b7:	add    BYTE PTR [rsi],al
    26b9:	add    BYTE PTR [rax],al
    26bb:	add    BYTE PTR [rax],al
    26bd:	add    BYTE PTR [rax],al
    26bf:	add    BYTE PTR [rax+rax*1],al
    26c2:	add    BYTE PTR [rax],al
    26c4:	add    BYTE PTR [rax],al
	...

00000000000026c8 <botlish_entry_23: ht_capacity_for<int, int>>:
    26c8:	push   rbp
    26c9:	mov    rbp,rsp
    26cc:	mov    rsi,QWORD PTR [rdx]
    26cf:	mov    rdx,QWORD PTR [rdx+0x8]
    26d3:	call   26d8 <botlish_entry_23+0x10>
			26d4: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    26d8:	mov    rsp,rbp
    26db:	pop    rbp
    26dc:	ret

00000000000026dd <botlish_fn_24: ht_new_sized<int>>:
    26dd:	push   rbp
    26de:	mov    rbp,rsp
    26e1:	sub    rsp,0x20
    26e5:	mov    QWORD PTR [rsp],rbx
    26e9:	mov    QWORD PTR [rsp+0x8],r12
    26ee:	mov    QWORD PTR [rsp+0x10],r15
    26f3:	mov    r15,QWORD PTR [rdi]
    26f6:	mov    rax,QWORD PTR [rdi+0x8]
    26fa:	lea    rcx,[r15+0x10]
    26fe:	cmp    rcx,rax
    2701:	ja     27b9 <botlish_fn_24+0xdc>
    2707:	lea    rax,[r15+0x10]
    270b:	mov    QWORD PTR [rdi],rax
    270e:	mov    rbx,rdi
    2711:	mov    QWORD PTR [r15],0x0
    2718:	mov    QWORD PTR [r15+0x8],0x0
    2720:	mov    QWORD PTR [r15],rsi
    2723:	mov    r12,rsi
    2726:	mov    rdi,rbx
    2729:	call   272e <botlish_fn_24+0x51>
			272a: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    272e:	test   rax,rax
    2731:	jne    273f <botlish_fn_24+0x62>
    2737:	mov    rdi,rbx
    273a:	jmp    277c <botlish_fn_24+0x9f>
    273f:	mov    QWORD PTR [r15+0x8],rax
    2743:	mov    rdx,rax
    2746:	mov    rsi,r12
    2749:	mov    rdi,rbx
    274c:	call   2751 <botlish_fn_24+0x74>
			274d: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    2751:	test   rax,rax
    2754:	jne    2762 <botlish_fn_24+0x85>
    275a:	mov    rdi,rbx
    275d:	jmp    277c <botlish_fn_24+0x9f>
    2762:	mov    QWORD PTR [r15],rax
    2765:	mov    rsi,rax
    2768:	mov    rdi,rbx
    276b:	call   2770 <botlish_fn_24+0x93>
			276c: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    2770:	test   rax,rax
    2773:	jne    279c <botlish_fn_24+0xbf>
    2779:	mov    rdi,rbx
    277c:	mov    rdi,rbx
    277f:	mov    QWORD PTR [rdi],r15
    2782:	xor    rax,rax
    2785:	mov    rbx,QWORD PTR [rsp]
    2789:	mov    r12,QWORD PTR [rsp+0x8]
    278e:	mov    r15,QWORD PTR [rsp+0x10]
    2793:	add    rsp,0x20
    2797:	mov    rsp,rbp
    279a:	pop    rbp
    279b:	ret
    279c:	mov    rdi,rbx
    279f:	mov    QWORD PTR [rdi],r15
    27a2:	mov    rbx,QWORD PTR [rsp]
    27a6:	mov    r12,QWORD PTR [rsp+0x8]
    27ab:	mov    r15,QWORD PTR [rsp+0x10]
    27b0:	add    rsp,0x20
    27b4:	mov    rsp,rbp
    27b7:	pop    rbp
    27b8:	ret
    27b9:	mov    rbx,rdi
    27bc:	mov    rax,QWORD PTR [rip+0x0]        # 27c3 <botlish_fn_24+0xe6>
			27bf: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    27c3:	call   rax
    27c5:	xor    rax,rax
    27c8:	mov    rbx,QWORD PTR [rsp]
    27cc:	mov    r12,QWORD PTR [rsp+0x8]
    27d1:	mov    r15,QWORD PTR [rsp+0x10]
    27d6:	add    rsp,0x20
    27da:	mov    rsp,rbp
    27dd:	pop    rbp
    27de:	ret

00000000000027df <botlish_entry_24: ht_new_sized<int>>:
    27df:	push   rbp
    27e0:	mov    rbp,rsp
    27e3:	mov    rsi,QWORD PTR [rdx]
    27e6:	call   27eb <botlish_entry_24+0xc>
			27e7: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    27eb:	mov    rsp,rbp
    27ee:	pop    rbp
    27ef:	ret

00000000000027f0 <botlish_fn_25: ht_controls<mutarray>>:
    27f0:	push   rbp
    27f1:	mov    rbp,rsp
    27f4:	sub    rsp,0x10
    27f8:	mov    QWORD PTR [rsp],rbx
    27fc:	mov    QWORD PTR [rsp+0x8],r15
    2801:	mov    r15,QWORD PTR [rdi]
    2804:	mov    rax,QWORD PTR [rdi+0x8]
    2808:	lea    rcx,[r15+0x8]
    280c:	cmp    rcx,rax
    280f:	ja     2873 <botlish_fn_25+0x83>
    2815:	lea    rax,[r15+0x8]
    2819:	mov    QWORD PTR [rdi],rax
    281c:	mov    rbx,rdi
    281f:	mov    QWORD PTR [r15],0x0
    2826:	mov    edx,0x1
    282b:	mov    rax,QWORD PTR [rip+0x0]        # 2832 <botlish_fn_25+0x42>
			282e: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2832:	mov    rdi,rbx
    2835:	call   rax
    2837:	test   rax,rax
    283a:	jne    285b <botlish_fn_25+0x6b>
    2840:	mov    rdi,rbx
    2843:	mov    QWORD PTR [rdi],r15
    2846:	xor    rax,rax
    2849:	mov    rbx,QWORD PTR [rsp]
    284d:	mov    r15,QWORD PTR [rsp+0x8]
    2852:	add    rsp,0x10
    2856:	mov    rsp,rbp
    2859:	pop    rbp
    285a:	ret
    285b:	mov    rdi,rbx
    285e:	mov    QWORD PTR [rdi],r15
    2861:	mov    rbx,QWORD PTR [rsp]
    2865:	mov    r15,QWORD PTR [rsp+0x8]
    286a:	add    rsp,0x10
    286e:	mov    rsp,rbp
    2871:	pop    rbp
    2872:	ret
    2873:	mov    rax,QWORD PTR [rip+0x0]        # 287a <botlish_fn_25+0x8a>
			2876: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    287a:	call   rax
    287c:	xor    rax,rax
    287f:	mov    rbx,QWORD PTR [rsp]
    2883:	mov    r15,QWORD PTR [rsp+0x8]
    2888:	add    rsp,0x10
    288c:	mov    rsp,rbp
    288f:	pop    rbp
    2890:	ret

0000000000002891 <botlish_entry_25: ht_controls<mutarray>>:
    2891:	push   rbp
    2892:	mov    rbp,rsp
    2895:	mov    rsi,QWORD PTR [rdx]
    2898:	call   289d <botlish_entry_25+0xc>
			2899: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    289d:	mov    rsp,rbp
    28a0:	pop    rbp
    28a1:	ret

00000000000028a2 <botlish_fn_26: ht_controls<generic>>:
    28a2:	push   rbp
    28a3:	mov    rbp,rsp
    28a6:	sub    rsp,0x10
    28aa:	mov    QWORD PTR [rsp],rbx
    28ae:	mov    QWORD PTR [rsp+0x8],r12
    28b3:	mov    rbx,QWORD PTR [rdi]
    28b6:	mov    rax,QWORD PTR [rdi+0x8]
    28ba:	lea    rcx,[rbx+0x8]
    28be:	cmp    rcx,rax
    28c1:	ja     2966 <botlish_fn_26+0xc4>
    28c7:	lea    rax,[rbx+0x8]
    28cb:	mov    QWORD PTR [rdi],rax
    28ce:	mov    QWORD PTR [rbx],0x0
    28d5:	xor    ecx,ecx
    28d7:	test   rsi,0x7
    28de:	jne    28ed <botlish_fn_26+0x4b>
    28e4:	movzx  rax,BYTE PTR [rsi]
    28e8:	cmp    al,0x8
    28ea:	sete   cl
    28ed:	test   cl,cl
    28ef:	jne    2916 <botlish_fn_26+0x74>
    28f5:	mov    rax,QWORD PTR [rdi+0x10]
    28f9:	mov    r12,rdi
    28fc:	mov    rcx,QWORD PTR [rax+0x20]
    2900:	mov    edx,0x8
    2905:	mov    rax,QWORD PTR [rip+0x0]        # 290c <botlish_fn_26+0x6a>
			2908: R_X86_64_GOTPCREL	rt_type_error-0x4
    290c:	call   rax
    290e:	mov    rdi,r12
    2911:	jmp    2933 <botlish_fn_26+0x91>
    2916:	mov    r12,rdi
    2919:	mov    edx,0x1
    291e:	mov    rax,QWORD PTR [rip+0x0]        # 2925 <botlish_fn_26+0x83>
			2921: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2925:	call   rax
    2927:	test   rax,rax
    292a:	jne    294e <botlish_fn_26+0xac>
    2930:	mov    rdi,r12
    2933:	mov    rdi,r12
    2936:	mov    QWORD PTR [rdi],rbx
    2939:	xor    rax,rax
    293c:	mov    rbx,QWORD PTR [rsp]
    2940:	mov    r12,QWORD PTR [rsp+0x8]
    2945:	add    rsp,0x10
    2949:	mov    rsp,rbp
    294c:	pop    rbp
    294d:	ret
    294e:	mov    rdi,r12
    2951:	mov    QWORD PTR [rdi],rbx
    2954:	mov    rbx,QWORD PTR [rsp]
    2958:	mov    r12,QWORD PTR [rsp+0x8]
    295d:	add    rsp,0x10
    2961:	mov    rsp,rbp
    2964:	pop    rbp
    2965:	ret
    2966:	mov    r12,rdi
    2969:	mov    rax,QWORD PTR [rip+0x0]        # 2970 <botlish_fn_26+0xce>
			296c: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2970:	call   rax
    2972:	xor    rax,rax
    2975:	mov    rbx,QWORD PTR [rsp]
    2979:	mov    r12,QWORD PTR [rsp+0x8]
    297e:	add    rsp,0x10
    2982:	mov    rsp,rbp
    2985:	pop    rbp
    2986:	ret

0000000000002987 <botlish_entry_26: ht_controls<generic>>:
    2987:	push   rbp
    2988:	mov    rbp,rsp
    298b:	mov    rsi,QWORD PTR [rdx]
    298e:	call   2993 <botlish_entry_26+0xc>
			298f: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    2993:	mov    rsp,rbp
    2996:	pop    rbp
    2997:	ret

0000000000002998 <botlish_fn_27: ht_keys<mutarray>>:
    2998:	push   rbp
    2999:	mov    rbp,rsp
    299c:	sub    rsp,0x10
    29a0:	mov    QWORD PTR [rsp],rbx
    29a4:	mov    QWORD PTR [rsp+0x8],r15
    29a9:	mov    r15,QWORD PTR [rdi]
    29ac:	mov    rax,QWORD PTR [rdi+0x8]
    29b0:	lea    rcx,[r15+0x8]
    29b4:	cmp    rcx,rax
    29b7:	ja     2a1b <botlish_fn_27+0x83>
    29bd:	lea    rax,[r15+0x8]
    29c1:	mov    QWORD PTR [rdi],rax
    29c4:	mov    rbx,rdi
    29c7:	mov    QWORD PTR [r15],0x0
    29ce:	mov    edx,0x3
    29d3:	mov    rax,QWORD PTR [rip+0x0]        # 29da <botlish_fn_27+0x42>
			29d6: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    29da:	mov    rdi,rbx
    29dd:	call   rax
    29df:	test   rax,rax
    29e2:	jne    2a03 <botlish_fn_27+0x6b>
    29e8:	mov    rdi,rbx
    29eb:	mov    QWORD PTR [rdi],r15
    29ee:	xor    rax,rax
    29f1:	mov    rbx,QWORD PTR [rsp]
    29f5:	mov    r15,QWORD PTR [rsp+0x8]
    29fa:	add    rsp,0x10
    29fe:	mov    rsp,rbp
    2a01:	pop    rbp
    2a02:	ret
    2a03:	mov    rdi,rbx
    2a06:	mov    QWORD PTR [rdi],r15
    2a09:	mov    rbx,QWORD PTR [rsp]
    2a0d:	mov    r15,QWORD PTR [rsp+0x8]
    2a12:	add    rsp,0x10
    2a16:	mov    rsp,rbp
    2a19:	pop    rbp
    2a1a:	ret
    2a1b:	mov    rax,QWORD PTR [rip+0x0]        # 2a22 <botlish_fn_27+0x8a>
			2a1e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2a22:	call   rax
    2a24:	xor    rax,rax
    2a27:	mov    rbx,QWORD PTR [rsp]
    2a2b:	mov    r15,QWORD PTR [rsp+0x8]
    2a30:	add    rsp,0x10
    2a34:	mov    rsp,rbp
    2a37:	pop    rbp
    2a38:	ret

0000000000002a39 <botlish_entry_27: ht_keys<mutarray>>:
    2a39:	push   rbp
    2a3a:	mov    rbp,rsp
    2a3d:	mov    rsi,QWORD PTR [rdx]
    2a40:	call   2a45 <botlish_entry_27+0xc>
			2a41: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    2a45:	mov    rsp,rbp
    2a48:	pop    rbp
    2a49:	ret

0000000000002a4a <botlish_fn_28: ht_keys<generic>>:
    2a4a:	push   rbp
    2a4b:	mov    rbp,rsp
    2a4e:	sub    rsp,0x10
    2a52:	mov    QWORD PTR [rsp],rbx
    2a56:	mov    QWORD PTR [rsp+0x8],r12
    2a5b:	mov    rbx,QWORD PTR [rdi]
    2a5e:	mov    rax,QWORD PTR [rdi+0x8]
    2a62:	lea    rcx,[rbx+0x8]
    2a66:	cmp    rcx,rax
    2a69:	ja     2b0e <botlish_fn_28+0xc4>
    2a6f:	lea    rax,[rbx+0x8]
    2a73:	mov    QWORD PTR [rdi],rax
    2a76:	mov    QWORD PTR [rbx],0x0
    2a7d:	xor    ecx,ecx
    2a7f:	test   rsi,0x7
    2a86:	jne    2a95 <botlish_fn_28+0x4b>
    2a8c:	movzx  rax,BYTE PTR [rsi]
    2a90:	cmp    al,0x8
    2a92:	sete   cl
    2a95:	test   cl,cl
    2a97:	jne    2abe <botlish_fn_28+0x74>
    2a9d:	mov    rax,QWORD PTR [rdi+0x10]
    2aa1:	mov    r12,rdi
    2aa4:	mov    rcx,QWORD PTR [rax+0x20]
    2aa8:	mov    edx,0x8
    2aad:	mov    rax,QWORD PTR [rip+0x0]        # 2ab4 <botlish_fn_28+0x6a>
			2ab0: R_X86_64_GOTPCREL	rt_type_error-0x4
    2ab4:	call   rax
    2ab6:	mov    rdi,r12
    2ab9:	jmp    2adb <botlish_fn_28+0x91>
    2abe:	mov    r12,rdi
    2ac1:	mov    edx,0x3
    2ac6:	mov    rax,QWORD PTR [rip+0x0]        # 2acd <botlish_fn_28+0x83>
			2ac9: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2acd:	call   rax
    2acf:	test   rax,rax
    2ad2:	jne    2af6 <botlish_fn_28+0xac>
    2ad8:	mov    rdi,r12
    2adb:	mov    rdi,r12
    2ade:	mov    QWORD PTR [rdi],rbx
    2ae1:	xor    rax,rax
    2ae4:	mov    rbx,QWORD PTR [rsp]
    2ae8:	mov    r12,QWORD PTR [rsp+0x8]
    2aed:	add    rsp,0x10
    2af1:	mov    rsp,rbp
    2af4:	pop    rbp
    2af5:	ret
    2af6:	mov    rdi,r12
    2af9:	mov    QWORD PTR [rdi],rbx
    2afc:	mov    rbx,QWORD PTR [rsp]
    2b00:	mov    r12,QWORD PTR [rsp+0x8]
    2b05:	add    rsp,0x10
    2b09:	mov    rsp,rbp
    2b0c:	pop    rbp
    2b0d:	ret
    2b0e:	mov    r12,rdi
    2b11:	mov    rax,QWORD PTR [rip+0x0]        # 2b18 <botlish_fn_28+0xce>
			2b14: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2b18:	call   rax
    2b1a:	xor    rax,rax
    2b1d:	mov    rbx,QWORD PTR [rsp]
    2b21:	mov    r12,QWORD PTR [rsp+0x8]
    2b26:	add    rsp,0x10
    2b2a:	mov    rsp,rbp
    2b2d:	pop    rbp
    2b2e:	ret

0000000000002b2f <botlish_entry_28: ht_keys<generic>>:
    2b2f:	push   rbp
    2b30:	mov    rbp,rsp
    2b33:	mov    rsi,QWORD PTR [rdx]
    2b36:	call   2b3b <botlish_entry_28+0xc>
			2b37: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    2b3b:	mov    rsp,rbp
    2b3e:	pop    rbp
    2b3f:	ret

0000000000002b40 <botlish_fn_29: ht_values<mutarray>>:
    2b40:	push   rbp
    2b41:	mov    rbp,rsp
    2b44:	sub    rsp,0x10
    2b48:	mov    QWORD PTR [rsp],rbx
    2b4c:	mov    QWORD PTR [rsp+0x8],r15
    2b51:	mov    r15,QWORD PTR [rdi]
    2b54:	mov    rax,QWORD PTR [rdi+0x8]
    2b58:	lea    rcx,[r15+0x8]
    2b5c:	cmp    rcx,rax
    2b5f:	ja     2bc3 <botlish_fn_29+0x83>
    2b65:	lea    rax,[r15+0x8]
    2b69:	mov    QWORD PTR [rdi],rax
    2b6c:	mov    rbx,rdi
    2b6f:	mov    QWORD PTR [r15],0x0
    2b76:	mov    edx,0x5
    2b7b:	mov    rax,QWORD PTR [rip+0x0]        # 2b82 <botlish_fn_29+0x42>
			2b7e: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2b82:	mov    rdi,rbx
    2b85:	call   rax
    2b87:	test   rax,rax
    2b8a:	jne    2bab <botlish_fn_29+0x6b>
    2b90:	mov    rdi,rbx
    2b93:	mov    QWORD PTR [rdi],r15
    2b96:	xor    rax,rax
    2b99:	mov    rbx,QWORD PTR [rsp]
    2b9d:	mov    r15,QWORD PTR [rsp+0x8]
    2ba2:	add    rsp,0x10
    2ba6:	mov    rsp,rbp
    2ba9:	pop    rbp
    2baa:	ret
    2bab:	mov    rdi,rbx
    2bae:	mov    QWORD PTR [rdi],r15
    2bb1:	mov    rbx,QWORD PTR [rsp]
    2bb5:	mov    r15,QWORD PTR [rsp+0x8]
    2bba:	add    rsp,0x10
    2bbe:	mov    rsp,rbp
    2bc1:	pop    rbp
    2bc2:	ret
    2bc3:	mov    rax,QWORD PTR [rip+0x0]        # 2bca <botlish_fn_29+0x8a>
			2bc6: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2bca:	call   rax
    2bcc:	xor    rax,rax
    2bcf:	mov    rbx,QWORD PTR [rsp]
    2bd3:	mov    r15,QWORD PTR [rsp+0x8]
    2bd8:	add    rsp,0x10
    2bdc:	mov    rsp,rbp
    2bdf:	pop    rbp
    2be0:	ret

0000000000002be1 <botlish_entry_29: ht_values<mutarray>>:
    2be1:	push   rbp
    2be2:	mov    rbp,rsp
    2be5:	mov    rsi,QWORD PTR [rdx]
    2be8:	call   2bed <botlish_entry_29+0xc>
			2be9: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    2bed:	mov    rsp,rbp
    2bf0:	pop    rbp
    2bf1:	ret

0000000000002bf2 <botlish_fn_30: ht_values<generic>>:
    2bf2:	push   rbp
    2bf3:	mov    rbp,rsp
    2bf6:	sub    rsp,0x10
    2bfa:	mov    QWORD PTR [rsp],rbx
    2bfe:	mov    QWORD PTR [rsp+0x8],r12
    2c03:	mov    rbx,QWORD PTR [rdi]
    2c06:	mov    rax,QWORD PTR [rdi+0x8]
    2c0a:	lea    rcx,[rbx+0x8]
    2c0e:	cmp    rcx,rax
    2c11:	ja     2cb6 <botlish_fn_30+0xc4>
    2c17:	lea    rax,[rbx+0x8]
    2c1b:	mov    QWORD PTR [rdi],rax
    2c1e:	mov    QWORD PTR [rbx],0x0
    2c25:	xor    ecx,ecx
    2c27:	test   rsi,0x7
    2c2e:	jne    2c3d <botlish_fn_30+0x4b>
    2c34:	movzx  rax,BYTE PTR [rsi]
    2c38:	cmp    al,0x8
    2c3a:	sete   cl
    2c3d:	test   cl,cl
    2c3f:	jne    2c66 <botlish_fn_30+0x74>
    2c45:	mov    rax,QWORD PTR [rdi+0x10]
    2c49:	mov    r12,rdi
    2c4c:	mov    rcx,QWORD PTR [rax+0x20]
    2c50:	mov    edx,0x8
    2c55:	mov    rax,QWORD PTR [rip+0x0]        # 2c5c <botlish_fn_30+0x6a>
			2c58: R_X86_64_GOTPCREL	rt_type_error-0x4
    2c5c:	call   rax
    2c5e:	mov    rdi,r12
    2c61:	jmp    2c83 <botlish_fn_30+0x91>
    2c66:	mov    r12,rdi
    2c69:	mov    edx,0x5
    2c6e:	mov    rax,QWORD PTR [rip+0x0]        # 2c75 <botlish_fn_30+0x83>
			2c71: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2c75:	call   rax
    2c77:	test   rax,rax
    2c7a:	jne    2c9e <botlish_fn_30+0xac>
    2c80:	mov    rdi,r12
    2c83:	mov    rdi,r12
    2c86:	mov    QWORD PTR [rdi],rbx
    2c89:	xor    rax,rax
    2c8c:	mov    rbx,QWORD PTR [rsp]
    2c90:	mov    r12,QWORD PTR [rsp+0x8]
    2c95:	add    rsp,0x10
    2c99:	mov    rsp,rbp
    2c9c:	pop    rbp
    2c9d:	ret
    2c9e:	mov    rdi,r12
    2ca1:	mov    QWORD PTR [rdi],rbx
    2ca4:	mov    rbx,QWORD PTR [rsp]
    2ca8:	mov    r12,QWORD PTR [rsp+0x8]
    2cad:	add    rsp,0x10
    2cb1:	mov    rsp,rbp
    2cb4:	pop    rbp
    2cb5:	ret
    2cb6:	mov    r12,rdi
    2cb9:	mov    rax,QWORD PTR [rip+0x0]        # 2cc0 <botlish_fn_30+0xce>
			2cbc: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2cc0:	call   rax
    2cc2:	xor    rax,rax
    2cc5:	mov    rbx,QWORD PTR [rsp]
    2cc9:	mov    r12,QWORD PTR [rsp+0x8]
    2cce:	add    rsp,0x10
    2cd2:	mov    rsp,rbp
    2cd5:	pop    rbp
    2cd6:	ret

0000000000002cd7 <botlish_entry_30: ht_values<generic>>:
    2cd7:	push   rbp
    2cd8:	mov    rbp,rsp
    2cdb:	mov    rsi,QWORD PTR [rdx]
    2cde:	call   2ce3 <botlish_entry_30+0xc>
			2cdf: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    2ce3:	mov    rsp,rbp
    2ce6:	pop    rbp
    2ce7:	ret

0000000000002ce8 <botlish_fn_31: ht_size<mutarray>>:
    2ce8:	push   rbp
    2ce9:	mov    rbp,rsp
    2cec:	sub    rsp,0x10
    2cf0:	mov    QWORD PTR [rsp],rbx
    2cf4:	mov    QWORD PTR [rsp+0x8],r15
    2cf9:	mov    r15,QWORD PTR [rdi]
    2cfc:	mov    rax,QWORD PTR [rdi+0x8]
    2d00:	lea    rcx,[r15+0x8]
    2d04:	cmp    rcx,rax
    2d07:	ja     2d6b <botlish_fn_31+0x83>
    2d0d:	lea    rax,[r15+0x8]
    2d11:	mov    QWORD PTR [rdi],rax
    2d14:	mov    rbx,rdi
    2d17:	mov    QWORD PTR [r15],0x0
    2d1e:	mov    edx,0x7
    2d23:	mov    rax,QWORD PTR [rip+0x0]        # 2d2a <botlish_fn_31+0x42>
			2d26: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2d2a:	mov    rdi,rbx
    2d2d:	call   rax
    2d2f:	test   rax,rax
    2d32:	jne    2d53 <botlish_fn_31+0x6b>
    2d38:	mov    rdi,rbx
    2d3b:	mov    QWORD PTR [rdi],r15
    2d3e:	xor    rax,rax
    2d41:	mov    rbx,QWORD PTR [rsp]
    2d45:	mov    r15,QWORD PTR [rsp+0x8]
    2d4a:	add    rsp,0x10
    2d4e:	mov    rsp,rbp
    2d51:	pop    rbp
    2d52:	ret
    2d53:	mov    rdi,rbx
    2d56:	mov    QWORD PTR [rdi],r15
    2d59:	mov    rbx,QWORD PTR [rsp]
    2d5d:	mov    r15,QWORD PTR [rsp+0x8]
    2d62:	add    rsp,0x10
    2d66:	mov    rsp,rbp
    2d69:	pop    rbp
    2d6a:	ret
    2d6b:	mov    rax,QWORD PTR [rip+0x0]        # 2d72 <botlish_fn_31+0x8a>
			2d6e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2d72:	call   rax
    2d74:	xor    rax,rax
    2d77:	mov    rbx,QWORD PTR [rsp]
    2d7b:	mov    r15,QWORD PTR [rsp+0x8]
    2d80:	add    rsp,0x10
    2d84:	mov    rsp,rbp
    2d87:	pop    rbp
    2d88:	ret

0000000000002d89 <botlish_entry_31: ht_size<mutarray>>:
    2d89:	push   rbp
    2d8a:	mov    rbp,rsp
    2d8d:	mov    rsi,QWORD PTR [rdx]
    2d90:	call   2d95 <botlish_entry_31+0xc>
			2d91: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    2d95:	mov    rsp,rbp
    2d98:	pop    rbp
    2d99:	ret

0000000000002d9a <botlish_fn_32: ht_size<generic>>:
    2d9a:	push   rbp
    2d9b:	mov    rbp,rsp
    2d9e:	sub    rsp,0x10
    2da2:	mov    QWORD PTR [rsp],rbx
    2da6:	mov    QWORD PTR [rsp+0x8],r12
    2dab:	mov    rbx,QWORD PTR [rdi]
    2dae:	mov    rax,QWORD PTR [rdi+0x8]
    2db2:	lea    rcx,[rbx+0x8]
    2db6:	cmp    rcx,rax
    2db9:	ja     2e5e <botlish_fn_32+0xc4>
    2dbf:	lea    rax,[rbx+0x8]
    2dc3:	mov    QWORD PTR [rdi],rax
    2dc6:	mov    QWORD PTR [rbx],0x0
    2dcd:	xor    ecx,ecx
    2dcf:	test   rsi,0x7
    2dd6:	jne    2de5 <botlish_fn_32+0x4b>
    2ddc:	movzx  rax,BYTE PTR [rsi]
    2de0:	cmp    al,0x8
    2de2:	sete   cl
    2de5:	test   cl,cl
    2de7:	jne    2e0e <botlish_fn_32+0x74>
    2ded:	mov    rax,QWORD PTR [rdi+0x10]
    2df1:	mov    r12,rdi
    2df4:	mov    rcx,QWORD PTR [rax+0x20]
    2df8:	mov    edx,0x8
    2dfd:	mov    rax,QWORD PTR [rip+0x0]        # 2e04 <botlish_fn_32+0x6a>
			2e00: R_X86_64_GOTPCREL	rt_type_error-0x4
    2e04:	call   rax
    2e06:	mov    rdi,r12
    2e09:	jmp    2e2b <botlish_fn_32+0x91>
    2e0e:	mov    r12,rdi
    2e11:	mov    edx,0x7
    2e16:	mov    rax,QWORD PTR [rip+0x0]        # 2e1d <botlish_fn_32+0x83>
			2e19: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2e1d:	call   rax
    2e1f:	test   rax,rax
    2e22:	jne    2e46 <botlish_fn_32+0xac>
    2e28:	mov    rdi,r12
    2e2b:	mov    rdi,r12
    2e2e:	mov    QWORD PTR [rdi],rbx
    2e31:	xor    rax,rax
    2e34:	mov    rbx,QWORD PTR [rsp]
    2e38:	mov    r12,QWORD PTR [rsp+0x8]
    2e3d:	add    rsp,0x10
    2e41:	mov    rsp,rbp
    2e44:	pop    rbp
    2e45:	ret
    2e46:	mov    rdi,r12
    2e49:	mov    QWORD PTR [rdi],rbx
    2e4c:	mov    rbx,QWORD PTR [rsp]
    2e50:	mov    r12,QWORD PTR [rsp+0x8]
    2e55:	add    rsp,0x10
    2e59:	mov    rsp,rbp
    2e5c:	pop    rbp
    2e5d:	ret
    2e5e:	mov    r12,rdi
    2e61:	mov    rax,QWORD PTR [rip+0x0]        # 2e68 <botlish_fn_32+0xce>
			2e64: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2e68:	call   rax
    2e6a:	xor    rax,rax
    2e6d:	mov    rbx,QWORD PTR [rsp]
    2e71:	mov    r12,QWORD PTR [rsp+0x8]
    2e76:	add    rsp,0x10
    2e7a:	mov    rsp,rbp
    2e7d:	pop    rbp
    2e7e:	ret

0000000000002e7f <botlish_entry_32: ht_size<generic>>:
    2e7f:	push   rbp
    2e80:	mov    rbp,rsp
    2e83:	mov    rsi,QWORD PTR [rdx]
    2e86:	call   2e8b <botlish_entry_32+0xc>
			2e87: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    2e8b:	mov    rsp,rbp
    2e8e:	pop    rbp
    2e8f:	ret

0000000000002e90 <botlish_fn_33: ht_tombstones<mutarray>>:
    2e90:	push   rbp
    2e91:	mov    rbp,rsp
    2e94:	sub    rsp,0x10
    2e98:	mov    QWORD PTR [rsp],rbx
    2e9c:	mov    QWORD PTR [rsp+0x8],r15
    2ea1:	mov    r15,QWORD PTR [rdi]
    2ea4:	mov    rax,QWORD PTR [rdi+0x8]
    2ea8:	lea    rcx,[r15+0x8]
    2eac:	cmp    rcx,rax
    2eaf:	ja     2f13 <botlish_fn_33+0x83>
    2eb5:	lea    rax,[r15+0x8]
    2eb9:	mov    QWORD PTR [rdi],rax
    2ebc:	mov    rbx,rdi
    2ebf:	mov    QWORD PTR [r15],0x0
    2ec6:	mov    edx,0x9
    2ecb:	mov    rax,QWORD PTR [rip+0x0]        # 2ed2 <botlish_fn_33+0x42>
			2ece: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2ed2:	mov    rdi,rbx
    2ed5:	call   rax
    2ed7:	test   rax,rax
    2eda:	jne    2efb <botlish_fn_33+0x6b>
    2ee0:	mov    rdi,rbx
    2ee3:	mov    QWORD PTR [rdi],r15
    2ee6:	xor    rax,rax
    2ee9:	mov    rbx,QWORD PTR [rsp]
    2eed:	mov    r15,QWORD PTR [rsp+0x8]
    2ef2:	add    rsp,0x10
    2ef6:	mov    rsp,rbp
    2ef9:	pop    rbp
    2efa:	ret
    2efb:	mov    rdi,rbx
    2efe:	mov    QWORD PTR [rdi],r15
    2f01:	mov    rbx,QWORD PTR [rsp]
    2f05:	mov    r15,QWORD PTR [rsp+0x8]
    2f0a:	add    rsp,0x10
    2f0e:	mov    rsp,rbp
    2f11:	pop    rbp
    2f12:	ret
    2f13:	mov    rax,QWORD PTR [rip+0x0]        # 2f1a <botlish_fn_33+0x8a>
			2f16: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2f1a:	call   rax
    2f1c:	xor    rax,rax
    2f1f:	mov    rbx,QWORD PTR [rsp]
    2f23:	mov    r15,QWORD PTR [rsp+0x8]
    2f28:	add    rsp,0x10
    2f2c:	mov    rsp,rbp
    2f2f:	pop    rbp
    2f30:	ret

0000000000002f31 <botlish_entry_33: ht_tombstones<mutarray>>:
    2f31:	push   rbp
    2f32:	mov    rbp,rsp
    2f35:	mov    rsi,QWORD PTR [rdx]
    2f38:	call   2f3d <botlish_entry_33+0xc>
			2f39: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    2f3d:	mov    rsp,rbp
    2f40:	pop    rbp
    2f41:	ret

0000000000002f42 <botlish_fn_34: ht_capacity<mutarray>>:
    2f42:	push   rbp
    2f43:	mov    rbp,rsp
    2f46:	sub    rsp,0x10
    2f4a:	mov    QWORD PTR [rsp],rbx
    2f4e:	mov    QWORD PTR [rsp+0x8],r12
    2f53:	mov    rbx,QWORD PTR [rdi]
    2f56:	mov    rax,QWORD PTR [rdi+0x8]
    2f5a:	lea    rcx,[rbx+0x8]
    2f5e:	cmp    rcx,rax
    2f61:	ja     3014 <botlish_fn_34+0xd2>
    2f67:	lea    rax,[rbx+0x8]
    2f6b:	mov    QWORD PTR [rdi],rax
    2f6e:	mov    r12,rdi
    2f71:	mov    QWORD PTR [rbx],rsi
    2f74:	mov    rdi,r12
    2f77:	call   2f7c <botlish_fn_34+0x3a>
			2f78: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    2f7c:	test   rax,rax
    2f7f:	jne    2f8d <botlish_fn_34+0x4b>
    2f85:	mov    rdi,r12
    2f88:	jmp    2fd5 <botlish_fn_34+0x93>
    2f8d:	xor    ecx,ecx
    2f8f:	test   rax,0x7
    2f95:	je     2fa3 <botlish_fn_34+0x61>
    2f9b:	mov    rsi,rax
    2f9e:	jmp    2fb1 <botlish_fn_34+0x6f>
    2fa3:	movzx  rcx,BYTE PTR [rax]
    2fa7:	mov    rsi,rax
    2faa:	rex cmp cl,0x8
    2fae:	sete   cl
    2fb1:	test   cl,cl
    2fb3:	jne    2ff0 <botlish_fn_34+0xae>
    2fb9:	mov    rdi,r12
    2fbc:	mov    rax,QWORD PTR [rdi+0x10]
    2fc0:	mov    rcx,QWORD PTR [rax+0x28]
    2fc4:	mov    edx,0x8
    2fc9:	mov    rax,QWORD PTR [rip+0x0]        # 2fd0 <botlish_fn_34+0x8e>
			2fcc: R_X86_64_GOTPCREL	rt_type_error-0x4
    2fd0:	call   rax
    2fd2:	mov    rdi,r12
    2fd5:	mov    rdi,r12
    2fd8:	mov    QWORD PTR [rdi],rbx
    2fdb:	xor    rax,rax
    2fde:	mov    rbx,QWORD PTR [rsp]
    2fe2:	mov    r12,QWORD PTR [rsp+0x8]
    2fe7:	add    rsp,0x10
    2feb:	mov    rsp,rbp
    2fee:	pop    rbp
    2fef:	ret
    2ff0:	mov    rax,QWORD PTR [rip+0x0]        # 2ff7 <botlish_fn_34+0xb5>
			2ff3: R_X86_64_GOTPCREL	rt_mutarray_capacity-0x4
    2ff7:	mov    rdi,r12
    2ffa:	call   rax
    2ffc:	mov    rdi,r12
    2fff:	mov    QWORD PTR [rdi],rbx
    3002:	mov    rbx,QWORD PTR [rsp]
    3006:	mov    r12,QWORD PTR [rsp+0x8]
    300b:	add    rsp,0x10
    300f:	mov    rsp,rbp
    3012:	pop    rbp
    3013:	ret
    3014:	mov    r12,rdi
    3017:	mov    rax,QWORD PTR [rip+0x0]        # 301e <botlish_fn_34+0xdc>
			301a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    301e:	call   rax
    3020:	xor    rax,rax
    3023:	mov    rbx,QWORD PTR [rsp]
    3027:	mov    r12,QWORD PTR [rsp+0x8]
    302c:	add    rsp,0x10
    3030:	mov    rsp,rbp
    3033:	pop    rbp
    3034:	ret

0000000000003035 <botlish_entry_34: ht_capacity<mutarray>>:
    3035:	push   rbp
    3036:	mov    rbp,rsp
    3039:	mov    rsi,QWORD PTR [rdx]
    303c:	call   3041 <botlish_entry_34+0xc>
			303d: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3041:	mov    rsp,rbp
    3044:	pop    rbp
    3045:	ret

0000000000003046 <botlish_fn_35: ht_capacity<generic>>:
    3046:	push   rbp
    3047:	mov    rbp,rsp
    304a:	sub    rsp,0x10
    304e:	mov    QWORD PTR [rsp],rbx
    3052:	mov    QWORD PTR [rsp+0x8],r12
    3057:	mov    rbx,QWORD PTR [rdi]
    305a:	mov    rax,QWORD PTR [rdi+0x8]
    305e:	lea    rcx,[rbx+0x8]
    3062:	cmp    rcx,rax
    3065:	ja     3118 <botlish_fn_35+0xd2>
    306b:	lea    rax,[rbx+0x8]
    306f:	mov    QWORD PTR [rdi],rax
    3072:	mov    r12,rdi
    3075:	mov    QWORD PTR [rbx],rsi
    3078:	mov    rdi,r12
    307b:	call   3080 <botlish_fn_35+0x3a>
			307c: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    3080:	test   rax,rax
    3083:	jne    3091 <botlish_fn_35+0x4b>
    3089:	mov    rdi,r12
    308c:	jmp    30d9 <botlish_fn_35+0x93>
    3091:	xor    ecx,ecx
    3093:	test   rax,0x7
    3099:	je     30a7 <botlish_fn_35+0x61>
    309f:	mov    rsi,rax
    30a2:	jmp    30b5 <botlish_fn_35+0x6f>
    30a7:	movzx  rcx,BYTE PTR [rax]
    30ab:	mov    rsi,rax
    30ae:	rex cmp cl,0x8
    30b2:	sete   cl
    30b5:	test   cl,cl
    30b7:	jne    30f4 <botlish_fn_35+0xae>
    30bd:	mov    rdi,r12
    30c0:	mov    rax,QWORD PTR [rdi+0x10]
    30c4:	mov    rcx,QWORD PTR [rax+0x28]
    30c8:	mov    edx,0x8
    30cd:	mov    rax,QWORD PTR [rip+0x0]        # 30d4 <botlish_fn_35+0x8e>
			30d0: R_X86_64_GOTPCREL	rt_type_error-0x4
    30d4:	call   rax
    30d6:	mov    rdi,r12
    30d9:	mov    rdi,r12
    30dc:	mov    QWORD PTR [rdi],rbx
    30df:	xor    rax,rax
    30e2:	mov    rbx,QWORD PTR [rsp]
    30e6:	mov    r12,QWORD PTR [rsp+0x8]
    30eb:	add    rsp,0x10
    30ef:	mov    rsp,rbp
    30f2:	pop    rbp
    30f3:	ret
    30f4:	mov    rax,QWORD PTR [rip+0x0]        # 30fb <botlish_fn_35+0xb5>
			30f7: R_X86_64_GOTPCREL	rt_mutarray_capacity-0x4
    30fb:	mov    rdi,r12
    30fe:	call   rax
    3100:	mov    rdi,r12
    3103:	mov    QWORD PTR [rdi],rbx
    3106:	mov    rbx,QWORD PTR [rsp]
    310a:	mov    r12,QWORD PTR [rsp+0x8]
    310f:	add    rsp,0x10
    3113:	mov    rsp,rbp
    3116:	pop    rbp
    3117:	ret
    3118:	mov    r12,rdi
    311b:	mov    rax,QWORD PTR [rip+0x0]        # 3122 <botlish_fn_35+0xdc>
			311e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3122:	call   rax
    3124:	xor    rax,rax
    3127:	mov    rbx,QWORD PTR [rsp]
    312b:	mov    r12,QWORD PTR [rsp+0x8]
    3130:	add    rsp,0x10
    3134:	mov    rsp,rbp
    3137:	pop    rbp
    3138:	ret

0000000000003139 <botlish_entry_35: ht_capacity<generic>>:
    3139:	push   rbp
    313a:	mov    rbp,rsp
    313d:	mov    rsi,QWORD PTR [rdx]
    3140:	call   3145 <botlish_entry_35+0xc>
			3141: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    3145:	mov    rsp,rbp
    3148:	pop    rbp
    3149:	ret

000000000000314a <botlish_fn_36: ht_probe_start<mutarray, any>>:
    314a:	push   rbp
    314b:	mov    rbp,rsp
    314e:	sub    rsp,0x20
    3152:	mov    QWORD PTR [rsp],rbx
    3156:	mov    QWORD PTR [rsp+0x8],r12
    315b:	mov    QWORD PTR [rsp+0x10],r13
    3160:	mov    rbx,QWORD PTR [rdi]
    3163:	mov    rax,QWORD PTR [rdi+0x8]
    3167:	lea    rcx,[rbx+0x10]
    316b:	cmp    rcx,rax
    316e:	ja     3231 <botlish_fn_36+0xe7>
    3174:	lea    rax,[rbx+0x10]
    3178:	mov    QWORD PTR [rdi],rax
    317b:	mov    r12,rdi
    317e:	mov    QWORD PTR [rbx],0x0
    3185:	mov    QWORD PTR [rbx+0x8],0x0
    318d:	mov    QWORD PTR [rbx],rsi
    3190:	mov    r13,rsi
    3193:	mov    rax,QWORD PTR [rip+0x0]        # 319a <botlish_fn_36+0x50>
			3196: R_X86_64_GOTPCREL	rt_hash-0x4
    319a:	mov    rsi,rdx
    319d:	mov    rdi,r12
    31a0:	call   rax
    31a2:	test   rax,rax
    31a5:	jne    31b3 <botlish_fn_36+0x69>
    31ab:	mov    rdi,r12
    31ae:	jmp    31f4 <botlish_fn_36+0xaa>
    31b3:	mov    QWORD PTR [rbx+0x8],rax
    31b7:	mov    rsi,r13
    31ba:	mov    r13,rax
    31bd:	mov    rdi,r12
    31c0:	call   31c5 <botlish_fn_36+0x7b>
			31c1: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    31c5:	test   rax,rax
    31c8:	mov    rdx,rax
    31cb:	jne    31d9 <botlish_fn_36+0x8f>
    31d1:	mov    rdi,r12
    31d4:	jmp    31f4 <botlish_fn_36+0xaa>
    31d9:	mov    rax,QWORD PTR [rip+0x0]        # 31e0 <botlish_fn_36+0x96>
			31dc: R_X86_64_GOTPCREL	rt_int_mod-0x4
    31e0:	mov    rsi,r13
    31e3:	mov    rdi,r12
    31e6:	call   rax
    31e8:	test   rax,rax
    31eb:	jne    3214 <botlish_fn_36+0xca>
    31f1:	mov    rdi,r12
    31f4:	mov    rdi,r12
    31f7:	mov    QWORD PTR [rdi],rbx
    31fa:	xor    rax,rax
    31fd:	mov    rbx,QWORD PTR [rsp]
    3201:	mov    r12,QWORD PTR [rsp+0x8]
    3206:	mov    r13,QWORD PTR [rsp+0x10]
    320b:	add    rsp,0x20
    320f:	mov    rsp,rbp
    3212:	pop    rbp
    3213:	ret
    3214:	mov    rdi,r12
    3217:	mov    QWORD PTR [rdi],rbx
    321a:	mov    rbx,QWORD PTR [rsp]
    321e:	mov    r12,QWORD PTR [rsp+0x8]
    3223:	mov    r13,QWORD PTR [rsp+0x10]
    3228:	add    rsp,0x20
    322c:	mov    rsp,rbp
    322f:	pop    rbp
    3230:	ret
    3231:	mov    r12,rdi
    3234:	mov    rax,QWORD PTR [rip+0x0]        # 323b <botlish_fn_36+0xf1>
			3237: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    323b:	call   rax
    323d:	xor    rax,rax
    3240:	mov    rbx,QWORD PTR [rsp]
    3244:	mov    r12,QWORD PTR [rsp+0x8]
    3249:	mov    r13,QWORD PTR [rsp+0x10]
    324e:	add    rsp,0x20
    3252:	mov    rsp,rbp
    3255:	pop    rbp
    3256:	ret

0000000000003257 <botlish_entry_36: ht_probe_start<mutarray, any>>:
    3257:	push   rbp
    3258:	mov    rbp,rsp
    325b:	mov    rsi,QWORD PTR [rdx]
    325e:	mov    rdx,QWORD PTR [rdx+0x8]
    3262:	call   3267 <botlish_entry_36+0x10>
			3263: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    3267:	mov    rsp,rbp
    326a:	pop    rbp
    326b:	ret

000000000000326c <botlish_fn_37: ht_probe_start<any, str>>:
    326c:	push   rbp
    326d:	mov    rbp,rsp
    3270:	sub    rsp,0x20
    3274:	mov    QWORD PTR [rsp],rbx
    3278:	mov    QWORD PTR [rsp+0x8],r12
    327d:	mov    QWORD PTR [rsp+0x10],r13
    3282:	mov    rbx,QWORD PTR [rdi]
    3285:	mov    rax,QWORD PTR [rdi+0x8]
    3289:	lea    rcx,[rbx+0x10]
    328d:	cmp    rcx,rax
    3290:	ja     3353 <botlish_fn_37+0xe7>
    3296:	lea    rax,[rbx+0x10]
    329a:	mov    QWORD PTR [rdi],rax
    329d:	mov    r12,rdi
    32a0:	mov    QWORD PTR [rbx],0x0
    32a7:	mov    QWORD PTR [rbx+0x8],0x0
    32af:	mov    QWORD PTR [rbx],rsi
    32b2:	mov    r13,rsi
    32b5:	mov    rax,QWORD PTR [rip+0x0]        # 32bc <botlish_fn_37+0x50>
			32b8: R_X86_64_GOTPCREL	rt_hash-0x4
    32bc:	mov    rsi,rdx
    32bf:	mov    rdi,r12
    32c2:	call   rax
    32c4:	test   rax,rax
    32c7:	jne    32d5 <botlish_fn_37+0x69>
    32cd:	mov    rdi,r12
    32d0:	jmp    3316 <botlish_fn_37+0xaa>
    32d5:	mov    QWORD PTR [rbx+0x8],rax
    32d9:	mov    rsi,r13
    32dc:	mov    r13,rax
    32df:	mov    rdi,r12
    32e2:	call   32e7 <botlish_fn_37+0x7b>
			32e3: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    32e7:	test   rax,rax
    32ea:	mov    rdx,rax
    32ed:	jne    32fb <botlish_fn_37+0x8f>
    32f3:	mov    rdi,r12
    32f6:	jmp    3316 <botlish_fn_37+0xaa>
    32fb:	mov    rax,QWORD PTR [rip+0x0]        # 3302 <botlish_fn_37+0x96>
			32fe: R_X86_64_GOTPCREL	rt_int_mod-0x4
    3302:	mov    rsi,r13
    3305:	mov    rdi,r12
    3308:	call   rax
    330a:	test   rax,rax
    330d:	jne    3336 <botlish_fn_37+0xca>
    3313:	mov    rdi,r12
    3316:	mov    rdi,r12
    3319:	mov    QWORD PTR [rdi],rbx
    331c:	xor    rax,rax
    331f:	mov    rbx,QWORD PTR [rsp]
    3323:	mov    r12,QWORD PTR [rsp+0x8]
    3328:	mov    r13,QWORD PTR [rsp+0x10]
    332d:	add    rsp,0x20
    3331:	mov    rsp,rbp
    3334:	pop    rbp
    3335:	ret
    3336:	mov    rdi,r12
    3339:	mov    QWORD PTR [rdi],rbx
    333c:	mov    rbx,QWORD PTR [rsp]
    3340:	mov    r12,QWORD PTR [rsp+0x8]
    3345:	mov    r13,QWORD PTR [rsp+0x10]
    334a:	add    rsp,0x20
    334e:	mov    rsp,rbp
    3351:	pop    rbp
    3352:	ret
    3353:	mov    r12,rdi
    3356:	mov    rax,QWORD PTR [rip+0x0]        # 335d <botlish_fn_37+0xf1>
			3359: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    335d:	call   rax
    335f:	xor    rax,rax
    3362:	mov    rbx,QWORD PTR [rsp]
    3366:	mov    r12,QWORD PTR [rsp+0x8]
    336b:	mov    r13,QWORD PTR [rsp+0x10]
    3370:	add    rsp,0x20
    3374:	mov    rsp,rbp
    3377:	pop    rbp
    3378:	ret

0000000000003379 <botlish_entry_37: ht_probe_start<any, str>>:
    3379:	push   rbp
    337a:	mov    rbp,rsp
    337d:	mov    rsi,QWORD PTR [rdx]
    3380:	mov    rdx,QWORD PTR [rdx+0x8]
    3384:	call   3389 <botlish_entry_37+0x10>
			3385: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    3389:	mov    rsp,rbp
    338c:	pop    rbp
    338d:	ret

000000000000338e <botlish_fn_38: ht_probe_next<mutarray, int>>:
    338e:	push   rbp
    338f:	mov    rbp,rsp
    3392:	sub    rsp,0x20
    3396:	mov    QWORD PTR [rsp],rbx
    339a:	mov    QWORD PTR [rsp+0x8],r12
    339f:	mov    QWORD PTR [rsp+0x10],r13
    33a4:	mov    rbx,QWORD PTR [rdi]
    33a7:	mov    rax,QWORD PTR [rdi+0x8]
    33ab:	lea    rcx,[rbx+0x18]
    33af:	cmp    rcx,rax
    33b2:	ja     34ad <botlish_fn_38+0x11f>
    33b8:	lea    rax,[rbx+0x18]
    33bc:	mov    QWORD PTR [rdi],rax
    33bf:	mov    r12,rdi
    33c2:	mov    QWORD PTR [rbx],0x0
    33c9:	mov    QWORD PTR [rbx+0x8],0x0
    33d1:	mov    QWORD PTR [rbx+0x10],0x0
    33d9:	mov    QWORD PTR [rbx],rsi
    33dc:	mov    r13,rsi
    33df:	mov    QWORD PTR [rbx+0x8],rdx
    33e3:	mov    QWORD PTR [rbx+0x10],0x3
    33eb:	test   rdx,0x1
    33f2:	jne    3400 <botlish_fn_38+0x72>
    33f8:	mov    rcx,rdx
    33fb:	jmp    3415 <botlish_fn_38+0x87>
    3400:	mov    rsi,rdx
    3403:	add    rsi,0x2
    3407:	mov    rcx,rdx
    340a:	seto   al
    340d:	test   al,al
    340f:	je     342c <botlish_fn_38+0x9e>
    3415:	mov    edx,0x3
    341a:	mov    rax,QWORD PTR [rip+0x0]        # 3421 <botlish_fn_38+0x93>
			341d: R_X86_64_GOTPCREL	rt_int_add-0x4
    3421:	mov    rsi,rcx
    3424:	mov    rdi,r12
    3427:	call   rax
    3429:	mov    rsi,rax
    342c:	mov    QWORD PTR [rbx+0x8],rsi
    3430:	mov    rax,rsi
    3433:	mov    rsi,r13
    3436:	mov    r13,rax
    3439:	mov    rdi,r12
    343c:	call   3441 <botlish_fn_38+0xb3>
			343d: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3441:	test   rax,rax
    3444:	mov    rdx,rax
    3447:	jne    3455 <botlish_fn_38+0xc7>
    344d:	mov    rdi,r12
    3450:	jmp    3470 <botlish_fn_38+0xe2>
    3455:	mov    rax,QWORD PTR [rip+0x0]        # 345c <botlish_fn_38+0xce>
			3458: R_X86_64_GOTPCREL	rt_int_mod-0x4
    345c:	mov    rsi,r13
    345f:	mov    rdi,r12
    3462:	call   rax
    3464:	test   rax,rax
    3467:	jne    3490 <botlish_fn_38+0x102>
    346d:	mov    rdi,r12
    3470:	mov    rdi,r12
    3473:	mov    QWORD PTR [rdi],rbx
    3476:	xor    rax,rax
    3479:	mov    rbx,QWORD PTR [rsp]
    347d:	mov    r12,QWORD PTR [rsp+0x8]
    3482:	mov    r13,QWORD PTR [rsp+0x10]
    3487:	add    rsp,0x20
    348b:	mov    rsp,rbp
    348e:	pop    rbp
    348f:	ret
    3490:	mov    rdi,r12
    3493:	mov    QWORD PTR [rdi],rbx
    3496:	mov    rbx,QWORD PTR [rsp]
    349a:	mov    r12,QWORD PTR [rsp+0x8]
    349f:	mov    r13,QWORD PTR [rsp+0x10]
    34a4:	add    rsp,0x20
    34a8:	mov    rsp,rbp
    34ab:	pop    rbp
    34ac:	ret
    34ad:	mov    r12,rdi
    34b0:	mov    rax,QWORD PTR [rip+0x0]        # 34b7 <botlish_fn_38+0x129>
			34b3: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    34b7:	call   rax
    34b9:	xor    rax,rax
    34bc:	mov    rbx,QWORD PTR [rsp]
    34c0:	mov    r12,QWORD PTR [rsp+0x8]
    34c5:	mov    r13,QWORD PTR [rsp+0x10]
    34ca:	add    rsp,0x20
    34ce:	mov    rsp,rbp
    34d1:	pop    rbp
    34d2:	ret

00000000000034d3 <botlish_entry_38: ht_probe_next<mutarray, int>>:
    34d3:	push   rbp
    34d4:	mov    rbp,rsp
    34d7:	mov    rsi,QWORD PTR [rdx]
    34da:	mov    rdx,QWORD PTR [rdx+0x8]
    34de:	call   34e3 <botlish_entry_38+0x10>
			34df: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    34e3:	mov    rsp,rbp
    34e6:	pop    rbp
    34e7:	ret

00000000000034e8 <botlish_fn_39: ht_probe_next<any, int>>:
    34e8:	push   rbp
    34e9:	mov    rbp,rsp
    34ec:	sub    rsp,0x20
    34f0:	mov    QWORD PTR [rsp],rbx
    34f4:	mov    QWORD PTR [rsp+0x8],r12
    34f9:	mov    QWORD PTR [rsp+0x10],r13
    34fe:	mov    rbx,QWORD PTR [rdi]
    3501:	mov    rax,QWORD PTR [rdi+0x8]
    3505:	lea    rcx,[rbx+0x18]
    3509:	cmp    rcx,rax
    350c:	ja     3607 <botlish_fn_39+0x11f>
    3512:	lea    rax,[rbx+0x18]
    3516:	mov    QWORD PTR [rdi],rax
    3519:	mov    r12,rdi
    351c:	mov    QWORD PTR [rbx],0x0
    3523:	mov    QWORD PTR [rbx+0x8],0x0
    352b:	mov    QWORD PTR [rbx+0x10],0x0
    3533:	mov    QWORD PTR [rbx],rsi
    3536:	mov    r13,rsi
    3539:	mov    QWORD PTR [rbx+0x8],rdx
    353d:	mov    QWORD PTR [rbx+0x10],0x3
    3545:	test   rdx,0x1
    354c:	jne    355a <botlish_fn_39+0x72>
    3552:	mov    rcx,rdx
    3555:	jmp    356f <botlish_fn_39+0x87>
    355a:	mov    rsi,rdx
    355d:	add    rsi,0x2
    3561:	mov    rcx,rdx
    3564:	seto   al
    3567:	test   al,al
    3569:	je     3586 <botlish_fn_39+0x9e>
    356f:	mov    edx,0x3
    3574:	mov    rax,QWORD PTR [rip+0x0]        # 357b <botlish_fn_39+0x93>
			3577: R_X86_64_GOTPCREL	rt_int_add-0x4
    357b:	mov    rsi,rcx
    357e:	mov    rdi,r12
    3581:	call   rax
    3583:	mov    rsi,rax
    3586:	mov    QWORD PTR [rbx+0x8],rsi
    358a:	mov    rax,rsi
    358d:	mov    rsi,r13
    3590:	mov    r13,rax
    3593:	mov    rdi,r12
    3596:	call   359b <botlish_fn_39+0xb3>
			3597: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    359b:	test   rax,rax
    359e:	mov    rdx,rax
    35a1:	jne    35af <botlish_fn_39+0xc7>
    35a7:	mov    rdi,r12
    35aa:	jmp    35ca <botlish_fn_39+0xe2>
    35af:	mov    rax,QWORD PTR [rip+0x0]        # 35b6 <botlish_fn_39+0xce>
			35b2: R_X86_64_GOTPCREL	rt_int_mod-0x4
    35b6:	mov    rsi,r13
    35b9:	mov    rdi,r12
    35bc:	call   rax
    35be:	test   rax,rax
    35c1:	jne    35ea <botlish_fn_39+0x102>
    35c7:	mov    rdi,r12
    35ca:	mov    rdi,r12
    35cd:	mov    QWORD PTR [rdi],rbx
    35d0:	xor    rax,rax
    35d3:	mov    rbx,QWORD PTR [rsp]
    35d7:	mov    r12,QWORD PTR [rsp+0x8]
    35dc:	mov    r13,QWORD PTR [rsp+0x10]
    35e1:	add    rsp,0x20
    35e5:	mov    rsp,rbp
    35e8:	pop    rbp
    35e9:	ret
    35ea:	mov    rdi,r12
    35ed:	mov    QWORD PTR [rdi],rbx
    35f0:	mov    rbx,QWORD PTR [rsp]
    35f4:	mov    r12,QWORD PTR [rsp+0x8]
    35f9:	mov    r13,QWORD PTR [rsp+0x10]
    35fe:	add    rsp,0x20
    3602:	mov    rsp,rbp
    3605:	pop    rbp
    3606:	ret
    3607:	mov    r12,rdi
    360a:	mov    rax,QWORD PTR [rip+0x0]        # 3611 <botlish_fn_39+0x129>
			360d: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3611:	call   rax
    3613:	xor    rax,rax
    3616:	mov    rbx,QWORD PTR [rsp]
    361a:	mov    r12,QWORD PTR [rsp+0x8]
    361f:	mov    r13,QWORD PTR [rsp+0x10]
    3624:	add    rsp,0x20
    3628:	mov    rsp,rbp
    362b:	pop    rbp
    362c:	ret

000000000000362d <botlish_entry_39: ht_probe_next<any, int>>:
    362d:	push   rbp
    362e:	mov    rbp,rsp
    3631:	mov    rsi,QWORD PTR [rdx]
    3634:	mov    rdx,QWORD PTR [rdx+0x8]
    3638:	call   363d <botlish_entry_39+0x10>
			3639: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    363d:	mov    rsp,rbp
    3640:	pop    rbp
    3641:	ret
    3642:	add    BYTE PTR [rax],al
    3644:	add    BYTE PTR [rax],al
	...

0000000000003648 <botlish_fn_40: ht_find_get<any, str, int>>:
    3648:	push   rbp
    3649:	mov    rbp,rsp
    364c:	sub    rsp,0x40
    3650:	mov    QWORD PTR [rsp+0x10],rbx
    3655:	mov    QWORD PTR [rsp+0x18],r12
    365a:	mov    QWORD PTR [rsp+0x20],r13
    365f:	mov    QWORD PTR [rsp+0x28],r14
    3664:	mov    QWORD PTR [rsp+0x30],r15
    3669:	mov    r14,QWORD PTR [rdi]
    366c:	mov    r8,QWORD PTR [rdi+0x8]
    3670:	lea    r9,[r14+0x20]
    3674:	cmp    r9,r8
    3677:	ja     39e7 <botlish_fn_40+0x39f>
    367d:	lea    r8,[r14+0x20]
    3681:	mov    QWORD PTR [rdi],r8
    3684:	mov    r15,rdi
    3687:	mov    QWORD PTR [r14],0x0
    368e:	mov    QWORD PTR [r14+0x8],0x0
    3696:	mov    QWORD PTR [r14+0x10],0x0
    369e:	mov    QWORD PTR [r14+0x18],0x0
    36a6:	mov    QWORD PTR [r14],rsi
    36a9:	mov    QWORD PTR [r14+0x8],rdx
    36ad:	mov    QWORD PTR [rsp],rdx
    36b1:	mov    QWORD PTR [r14+0x10],rcx
    36b5:	mov    rbx,rsi
    36b8:	mov    QWORD PTR [rsp+0x8],rcx
    36bd:	mov    rsi,rbx
    36c0:	mov    rdi,r15
    36c3:	call   36c8 <botlish_fn_40+0x80>
			36c4: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    36c8:	test   rax,rax
    36cb:	jne    36d9 <botlish_fn_40+0x91>
    36d1:	mov    rdi,r15
    36d4:	jmp    3947 <botlish_fn_40+0x2ff>
    36d9:	xor    ecx,ecx
    36db:	test   rax,0x7
    36e1:	je     36ef <botlish_fn_40+0xa7>
    36e7:	mov    rsi,rax
    36ea:	jmp    36fd <botlish_fn_40+0xb5>
    36ef:	movzx  rcx,BYTE PTR [rax]
    36f3:	mov    rsi,rax
    36f6:	rex cmp cl,0x8
    36fa:	sete   cl
    36fd:	test   cl,cl
    36ff:	jne    3726 <botlish_fn_40+0xde>
    3705:	mov    rdi,r15
    3708:	mov    rax,QWORD PTR [rdi+0x10]
    370c:	mov    rcx,QWORD PTR [rax+0x20]
    3710:	mov    edx,0x8
    3715:	mov    rax,QWORD PTR [rip+0x0]        # 371c <botlish_fn_40+0xd4>
			3718: R_X86_64_GOTPCREL	rt_type_error-0x4
    371c:	call   rax
    371e:	mov    rdi,r15
    3721:	jmp    3947 <botlish_fn_40+0x2ff>
    3726:	mov    rax,QWORD PTR [rip+0x0]        # 372d <botlish_fn_40+0xe5>
			3729: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    372d:	mov    rdx,QWORD PTR [rsp+0x8]
    3732:	mov    rdi,r15
    3735:	call   rax
    3737:	mov    rsi,rax
    373a:	mov    r13,rax
    373d:	test   rax,rsi
    3740:	jne    374e <botlish_fn_40+0x106>
    3746:	mov    rdi,r15
    3749:	jmp    3947 <botlish_fn_40+0x2ff>
    374e:	mov    rax,r13
    3751:	mov    QWORD PTR [r14+0x18],rax
    3755:	mov    rdi,r15
    3758:	call   375d <botlish_fn_40+0x115>
			3759: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    375d:	test   rax,rax
    3760:	jne    376e <botlish_fn_40+0x126>
    3766:	mov    rdi,r15
    3769:	jmp    3947 <botlish_fn_40+0x2ff>
    376e:	mov    rcx,r13
    3771:	and    rcx,rax
    3774:	mov    rdx,rax
    3777:	test   rcx,0x1
    377e:	jne    37a4 <botlish_fn_40+0x15c>
    3784:	mov    rax,QWORD PTR [rip+0x0]        # 378b <botlish_fn_40+0x143>
			3787: R_X86_64_GOTPCREL	rt_value_eq-0x4
    378b:	mov    rsi,r13
    378e:	mov    rdi,r15
    3791:	call   rax
    3793:	test   rax,rax
    3796:	jne    37b4 <botlish_fn_40+0x16c>
    379c:	mov    rdi,r15
    379f:	jmp    3947 <botlish_fn_40+0x2ff>
    37a4:	mov    eax,0x2
    37a9:	cmp    r13,rdx
    37ac:	cmove  rax,QWORD PTR [rip+0x264]        # 3a18 <botlish_fn_40+0x3d0>
    37b4:	mov    r12d,0x6
    37ba:	cmp    rax,0x6
    37be:	je     39b8 <botlish_fn_40+0x370>
    37c4:	mov    rdi,r15
    37c7:	call   37cc <botlish_fn_40+0x184>
			37c8: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    37cc:	test   rax,rax
    37cf:	jne    37dd <botlish_fn_40+0x195>
    37d5:	mov    rdi,r15
    37d8:	jmp    3947 <botlish_fn_40+0x2ff>
    37dd:	mov    rcx,r13
    37e0:	and    rcx,rax
    37e3:	mov    rdx,rax
    37e6:	test   rcx,0x1
    37ed:	jne    3813 <botlish_fn_40+0x1cb>
    37f3:	mov    rax,QWORD PTR [rip+0x0]        # 37fa <botlish_fn_40+0x1b2>
			37f6: R_X86_64_GOTPCREL	rt_value_eq-0x4
    37fa:	mov    rsi,r13
    37fd:	mov    rdi,r15
    3800:	call   rax
    3802:	test   rax,rax
    3805:	jne    3826 <botlish_fn_40+0x1de>
    380b:	mov    rdi,r15
    380e:	jmp    3947 <botlish_fn_40+0x2ff>
    3813:	mov    rsi,r13
    3816:	mov    eax,0x2
    381b:	cmp    rsi,rdx
    381e:	cmove  rax,QWORD PTR [rip+0x1f2]        # 3a18 <botlish_fn_40+0x3d0>
    3826:	cmp    rax,0x6
    382a:	je     383f <botlish_fn_40+0x1f7>
    3830:	mov    r12d,0x2
    3836:	mov    r13,QWORD PTR [rsp]
    383a:	jmp    3921 <botlish_fn_40+0x2d9>
    383f:	mov    rsi,rbx
    3842:	mov    rdi,r15
    3845:	call   384a <botlish_fn_40+0x202>
			3846: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    384a:	test   rax,rax
    384d:	jne    385b <botlish_fn_40+0x213>
    3853:	mov    rdi,r15
    3856:	jmp    3947 <botlish_fn_40+0x2ff>
    385b:	xor    ecx,ecx
    385d:	test   rax,0x7
    3863:	jne    3874 <botlish_fn_40+0x22c>
    3869:	movzx  rdx,BYTE PTR [rax]
    386d:	rex cmp dl,0x8
    3871:	sete   cl
    3874:	test   cl,cl
    3876:	jne    38a1 <botlish_fn_40+0x259>
    387c:	mov    rdi,r15
    387f:	mov    rsi,QWORD PTR [rdi+0x10]
    3883:	mov    rcx,QWORD PTR [rsi+0x20]
    3887:	mov    edx,0x8
    388c:	mov    r8,QWORD PTR [rip+0x0]        # 3893 <botlish_fn_40+0x24b>
			388f: R_X86_64_GOTPCREL	rt_type_error-0x4
    3893:	mov    rsi,rax
    3896:	call   r8
    3899:	mov    rdi,r15
    389c:	jmp    3947 <botlish_fn_40+0x2ff>
    38a1:	mov    rsi,rax
    38a4:	mov    r8,QWORD PTR [rip+0x0]        # 38ab <botlish_fn_40+0x263>
			38a7: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    38ab:	mov    rdx,QWORD PTR [rsp+0x8]
    38b0:	mov    rdi,r15
    38b3:	call   r8
    38b6:	test   rax,rax
    38b9:	jne    38c7 <botlish_fn_40+0x27f>
    38bf:	mov    rdi,r15
    38c2:	jmp    3947 <botlish_fn_40+0x2ff>
    38c7:	mov    r13,QWORD PTR [rsp]
    38cb:	mov    r10,rax
    38ce:	and    r10,r13
    38d1:	mov    rsi,rax
    38d4:	test   r10,0x1
    38db:	jne    3901 <botlish_fn_40+0x2b9>
    38e1:	mov    rax,QWORD PTR [rip+0x0]        # 38e8 <botlish_fn_40+0x2a0>
			38e4: R_X86_64_GOTPCREL	rt_value_eq-0x4
    38e8:	mov    rdx,r13
    38eb:	mov    rdi,r15
    38ee:	call   rax
    38f0:	test   rax,rax
    38f3:	jne    3911 <botlish_fn_40+0x2c9>
    38f9:	mov    rdi,r15
    38fc:	jmp    3947 <botlish_fn_40+0x2ff>
    3901:	mov    eax,0x2
    3906:	cmp    rsi,r13
    3909:	cmove  rax,QWORD PTR [rip+0x107]        # 3a18 <botlish_fn_40+0x3d0>
    3911:	cmp    rax,0x6
    3915:	je     3921 <botlish_fn_40+0x2d9>
    391b:	mov    r12d,0x2
    3921:	cmp    r12,0x6
    3925:	je     398b <botlish_fn_40+0x343>
    392b:	mov    rdx,QWORD PTR [rsp+0x8]
    3930:	mov    rsi,rbx
    3933:	mov    rdi,r15
    3936:	call   393b <botlish_fn_40+0x2f3>
			3937: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    393b:	test   rax,rax
    393e:	jne    3972 <botlish_fn_40+0x32a>
    3944:	mov    rdi,r15
    3947:	mov    rdi,r15
    394a:	mov    QWORD PTR [rdi],r14
    394d:	xor    rax,rax
    3950:	mov    rbx,QWORD PTR [rsp+0x10]
    3955:	mov    r12,QWORD PTR [rsp+0x18]
    395a:	mov    r13,QWORD PTR [rsp+0x20]
    395f:	mov    r14,QWORD PTR [rsp+0x28]
    3964:	mov    r15,QWORD PTR [rsp+0x30]
    3969:	add    rsp,0x40
    396d:	mov    rsp,rbp
    3970:	pop    rbp
    3971:	ret
    3972:	mov    QWORD PTR [r14],rbx
    3975:	mov    QWORD PTR [r14+0x8],r13
    3979:	mov    QWORD PTR [r14+0x10],rax
    397d:	mov    QWORD PTR [rsp],r13
    3981:	mov    QWORD PTR [rsp+0x8],rax
    3986:	jmp    36bd <botlish_fn_40+0x75>
    398b:	mov    rdi,r15
    398e:	mov    QWORD PTR [rdi],r14
    3991:	mov    rax,QWORD PTR [rsp+0x8]
    3996:	mov    rbx,QWORD PTR [rsp+0x10]
    399b:	mov    r12,QWORD PTR [rsp+0x18]
    39a0:	mov    r13,QWORD PTR [rsp+0x20]
    39a5:	mov    r14,QWORD PTR [rsp+0x28]
    39aa:	mov    r15,QWORD PTR [rsp+0x30]
    39af:	add    rsp,0x40
    39b3:	mov    rsp,rbp
    39b6:	pop    rbp
    39b7:	ret
    39b8:	mov    rdi,r15
    39bb:	mov    QWORD PTR [rdi],r14
    39be:	mov    rax,0xffffffffffffffff
    39c5:	mov    rbx,QWORD PTR [rsp+0x10]
    39ca:	mov    r12,QWORD PTR [rsp+0x18]
    39cf:	mov    r13,QWORD PTR [rsp+0x20]
    39d4:	mov    r14,QWORD PTR [rsp+0x28]
    39d9:	mov    r15,QWORD PTR [rsp+0x30]
    39de:	add    rsp,0x40
    39e2:	mov    rsp,rbp
    39e5:	pop    rbp
    39e6:	ret
    39e7:	mov    r15,rdi
    39ea:	mov    rax,QWORD PTR [rip+0x0]        # 39f1 <botlish_fn_40+0x3a9>
			39ed: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    39f1:	call   rax
    39f3:	xor    rax,rax
    39f6:	mov    rbx,QWORD PTR [rsp+0x10]
    39fb:	mov    r12,QWORD PTR [rsp+0x18]
    3a00:	mov    r13,QWORD PTR [rsp+0x20]
    3a05:	mov    r14,QWORD PTR [rsp+0x28]
    3a0a:	mov    r15,QWORD PTR [rsp+0x30]
    3a0f:	add    rsp,0x40
    3a13:	mov    rsp,rbp
    3a16:	pop    rbp
    3a17:	ret
    3a18:	(bad)
    3a19:	add    BYTE PTR [rax],al
    3a1b:	add    BYTE PTR [rax],al
    3a1d:	add    BYTE PTR [rax],al
	...

0000000000003a20 <botlish_entry_40: ht_find_get<any, str, int>>:
    3a20:	push   rbp
    3a21:	mov    rbp,rsp
    3a24:	mov    rsi,QWORD PTR [rdx]
    3a27:	mov    r8,QWORD PTR [rdx+0x8]
    3a2b:	mov    rcx,QWORD PTR [rdx+0x10]
    3a2f:	mov    rdx,r8
    3a32:	call   3a37 <botlish_entry_40+0x17>
			3a33: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    3a37:	mov    rsp,rbp
    3a3a:	pop    rbp
    3a3b:	ret
    3a3c:	add    BYTE PTR [rax],al
	...

0000000000003a40 <botlish_fn_41: ht_find_insert<mutarray, any, int, int>>:
    3a40:	push   rbp
    3a41:	mov    rbp,rsp
    3a44:	sub    rsp,0x50
    3a48:	mov    QWORD PTR [rsp+0x20],rbx
    3a4d:	mov    QWORD PTR [rsp+0x28],r12
    3a52:	mov    QWORD PTR [rsp+0x30],r13
    3a57:	mov    QWORD PTR [rsp+0x38],r14
    3a5c:	mov    QWORD PTR [rsp+0x40],r15
    3a61:	mov    r13,QWORD PTR [rdi]
    3a64:	mov    rax,QWORD PTR [rdi+0x8]
    3a68:	lea    r9,[r13+0x28]
    3a6c:	cmp    r9,rax
    3a6f:	ja     3fe3 <botlish_fn_41+0x5a3>
    3a75:	lea    rax,[r13+0x28]
    3a79:	mov    QWORD PTR [rdi],rax
    3a7c:	mov    QWORD PTR [rsp],rdi
    3a80:	mov    QWORD PTR [r13+0x0],0x0
    3a88:	mov    QWORD PTR [r13+0x8],0x0
    3a90:	mov    QWORD PTR [r13+0x10],0x0
    3a98:	mov    QWORD PTR [r13+0x18],0x0
    3aa0:	mov    QWORD PTR [r13+0x20],0x0
    3aa8:	mov    QWORD PTR [r13+0x0],rsi
    3aac:	mov    QWORD PTR [r13+0x8],rdx
    3ab0:	mov    r14,rdx
    3ab3:	mov    QWORD PTR [r13+0x10],rcx
    3ab7:	mov    QWORD PTR [r13+0x18],r8
    3abb:	mov    rbx,rsi
    3abe:	mov    r15,r8
    3ac1:	mov    QWORD PTR [rsp+0x8],rcx
    3ac6:	mov    rsi,rbx
    3ac9:	mov    rdi,QWORD PTR [rsp]
    3acd:	call   3ad2 <botlish_fn_41+0x92>
			3ace: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    3ad2:	test   rax,rax
    3ad5:	jne    3ae4 <botlish_fn_41+0xa4>
    3adb:	mov    rdi,QWORD PTR [rsp]
    3adf:	jmp    3eb2 <botlish_fn_41+0x472>
    3ae4:	xor    ecx,ecx
    3ae6:	test   rax,0x7
    3aec:	je     3afa <botlish_fn_41+0xba>
    3af2:	mov    rsi,rax
    3af5:	jmp    3b08 <botlish_fn_41+0xc8>
    3afa:	movzx  rcx,BYTE PTR [rax]
    3afe:	mov    rsi,rax
    3b01:	rex cmp cl,0x8
    3b05:	sete   cl
    3b08:	test   cl,cl
    3b0a:	jne    3b33 <botlish_fn_41+0xf3>
    3b10:	mov    rdi,QWORD PTR [rsp]
    3b14:	mov    rax,QWORD PTR [rdi+0x10]
    3b18:	mov    rcx,QWORD PTR [rax+0x20]
    3b1c:	mov    edx,0x8
    3b21:	mov    rax,QWORD PTR [rip+0x0]        # 3b28 <botlish_fn_41+0xe8>
			3b24: R_X86_64_GOTPCREL	rt_type_error-0x4
    3b28:	call   rax
    3b2a:	mov    rdi,QWORD PTR [rsp]
    3b2e:	jmp    3eb2 <botlish_fn_41+0x472>
    3b33:	mov    rax,QWORD PTR [rip+0x0]        # 3b3a <botlish_fn_41+0xfa>
			3b36: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    3b3a:	mov    rdx,QWORD PTR [rsp+0x8]
    3b3f:	mov    rdi,QWORD PTR [rsp]
    3b43:	call   rax
    3b45:	mov    rcx,rax
    3b48:	mov    QWORD PTR [rsp+0x10],rax
    3b4d:	test   rax,rcx
    3b50:	jne    3b5f <botlish_fn_41+0x11f>
    3b56:	mov    rdi,QWORD PTR [rsp]
    3b5a:	jmp    3eb2 <botlish_fn_41+0x472>
    3b5f:	mov    rax,QWORD PTR [rsp+0x10]
    3b64:	mov    QWORD PTR [r13+0x20],rax
    3b68:	mov    rdi,QWORD PTR [rsp]
    3b6c:	call   3b71 <botlish_fn_41+0x131>
			3b6d: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    3b71:	test   rax,rax
    3b74:	jne    3b83 <botlish_fn_41+0x143>
    3b7a:	mov    rdi,QWORD PTR [rsp]
    3b7e:	jmp    3eb2 <botlish_fn_41+0x472>
    3b83:	mov    rcx,QWORD PTR [rsp+0x10]
    3b88:	mov    rdx,rcx
    3b8b:	and    rdx,rax
    3b8e:	mov    r10,rax
    3b91:	test   rdx,0x1
    3b98:	jne    3bc6 <botlish_fn_41+0x186>
    3b9e:	mov    r8,QWORD PTR [rip+0x0]        # 3ba5 <botlish_fn_41+0x165>
			3ba1: R_X86_64_GOTPCREL	rt_value_eq-0x4
    3ba5:	mov    rdx,r10
    3ba8:	mov    rsi,QWORD PTR [rsp+0x10]
    3bad:	mov    rdi,QWORD PTR [rsp]
    3bb1:	call   r8
    3bb4:	test   rax,rax
    3bb7:	jne    3bde <botlish_fn_41+0x19e>
    3bbd:	mov    rdi,QWORD PTR [rsp]
    3bc1:	jmp    3eb2 <botlish_fn_41+0x472>
    3bc6:	mov    rdx,r10
    3bc9:	mov    eax,0x2
    3bce:	mov    rsi,QWORD PTR [rsp+0x10]
    3bd3:	cmp    rsi,rdx
    3bd6:	cmove  rax,QWORD PTR [rip+0x43a]        # 4018 <botlish_fn_41+0x5d8>
    3bde:	mov    r12d,0x6
    3be4:	cmp    rax,0x6
    3be8:	je     3f30 <botlish_fn_41+0x4f0>
    3bee:	mov    rdi,QWORD PTR [rsp]
    3bf2:	call   3bf7 <botlish_fn_41+0x1b7>
			3bf3: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    3bf7:	test   rax,rax
    3bfa:	jne    3c09 <botlish_fn_41+0x1c9>
    3c00:	mov    rdi,QWORD PTR [rsp]
    3c04:	jmp    3eb2 <botlish_fn_41+0x472>
    3c09:	mov    rcx,QWORD PTR [rsp+0x10]
    3c0e:	and    rcx,rax
    3c11:	mov    rdx,rax
    3c14:	test   rcx,0x1
    3c1b:	jne    3c45 <botlish_fn_41+0x205>
    3c21:	mov    rax,QWORD PTR [rip+0x0]        # 3c28 <botlish_fn_41+0x1e8>
			3c24: R_X86_64_GOTPCREL	rt_value_eq-0x4
    3c28:	mov    rsi,QWORD PTR [rsp+0x10]
    3c2d:	mov    rdi,QWORD PTR [rsp]
    3c31:	call   rax
    3c33:	test   rax,rax
    3c36:	jne    3c5a <botlish_fn_41+0x21a>
    3c3c:	mov    rdi,QWORD PTR [rsp]
    3c40:	jmp    3eb2 <botlish_fn_41+0x472>
    3c45:	mov    eax,0x2
    3c4a:	mov    rcx,QWORD PTR [rsp+0x10]
    3c4f:	cmp    rcx,rdx
    3c52:	cmove  rax,QWORD PTR [rip+0x3be]        # 4018 <botlish_fn_41+0x5d8>
    3c5a:	cmp    rax,0x6
    3c5e:	je     3c6e <botlish_fn_41+0x22e>
    3c64:	mov    eax,0x2
    3c69:	jmp    3d5e <botlish_fn_41+0x31e>
    3c6e:	mov    rsi,rbx
    3c71:	mov    rdi,QWORD PTR [rsp]
    3c75:	call   3c7a <botlish_fn_41+0x23a>
			3c76: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    3c7a:	test   rax,rax
    3c7d:	jne    3c8c <botlish_fn_41+0x24c>
    3c83:	mov    rdi,QWORD PTR [rsp]
    3c87:	jmp    3eb2 <botlish_fn_41+0x472>
    3c8c:	xor    ecx,ecx
    3c8e:	test   rax,0x7
    3c94:	je     3ca2 <botlish_fn_41+0x262>
    3c9a:	mov    rsi,rax
    3c9d:	jmp    3cb0 <botlish_fn_41+0x270>
    3ca2:	movzx  rcx,BYTE PTR [rax]
    3ca6:	mov    rsi,rax
    3ca9:	rex cmp cl,0x8
    3cad:	sete   cl
    3cb0:	test   cl,cl
    3cb2:	jne    3cdb <botlish_fn_41+0x29b>
    3cb8:	mov    rdi,QWORD PTR [rsp]
    3cbc:	mov    rax,QWORD PTR [rdi+0x10]
    3cc0:	mov    rcx,QWORD PTR [rax+0x20]
    3cc4:	mov    edx,0x8
    3cc9:	mov    rax,QWORD PTR [rip+0x0]        # 3cd0 <botlish_fn_41+0x290>
			3ccc: R_X86_64_GOTPCREL	rt_type_error-0x4
    3cd0:	call   rax
    3cd2:	mov    rdi,QWORD PTR [rsp]
    3cd6:	jmp    3eb2 <botlish_fn_41+0x472>
    3cdb:	mov    rax,QWORD PTR [rip+0x0]        # 3ce2 <botlish_fn_41+0x2a2>
			3cde: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    3ce2:	mov    rdx,QWORD PTR [rsp+0x8]
    3ce7:	mov    rdi,QWORD PTR [rsp]
    3ceb:	call   rax
    3ced:	test   rax,rax
    3cf0:	jne    3cff <botlish_fn_41+0x2bf>
    3cf6:	mov    rdi,QWORD PTR [rsp]
    3cfa:	jmp    3eb2 <botlish_fn_41+0x472>
    3cff:	mov    rcx,rax
    3d02:	and    rcx,r14
    3d05:	mov    rsi,rax
    3d08:	test   rcx,0x1
    3d0f:	jne    3d37 <botlish_fn_41+0x2f7>
    3d15:	mov    rax,QWORD PTR [rip+0x0]        # 3d1c <botlish_fn_41+0x2dc>
			3d18: R_X86_64_GOTPCREL	rt_value_eq-0x4
    3d1c:	mov    rdx,r14
    3d1f:	mov    rdi,QWORD PTR [rsp]
    3d23:	call   rax
    3d25:	test   rax,rax
    3d28:	jne    3d47 <botlish_fn_41+0x307>
    3d2e:	mov    rdi,QWORD PTR [rsp]
    3d32:	jmp    3eb2 <botlish_fn_41+0x472>
    3d37:	mov    eax,0x2
    3d3c:	cmp    rsi,r14
    3d3f:	cmove  rax,QWORD PTR [rip+0x2d1]        # 4018 <botlish_fn_41+0x5d8>
    3d47:	cmp    rax,0x6
    3d4b:	je     3d5b <botlish_fn_41+0x31b>
    3d51:	mov    eax,0x2
    3d56:	jmp    3d5e <botlish_fn_41+0x31e>
    3d5b:	mov    rax,r12
    3d5e:	cmp    rax,0x6
    3d62:	je     3f02 <botlish_fn_41+0x4c2>
    3d68:	mov    rdi,QWORD PTR [rsp]
    3d6c:	call   3d71 <botlish_fn_41+0x331>
			3d6d: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    3d71:	test   rax,rax
    3d74:	jne    3d83 <botlish_fn_41+0x343>
    3d7a:	mov    rdi,QWORD PTR [rsp]
    3d7e:	jmp    3eb2 <botlish_fn_41+0x472>
    3d83:	mov    rcx,QWORD PTR [rsp+0x10]
    3d88:	mov    rdx,rcx
    3d8b:	and    rdx,rax
    3d8e:	mov    rcx,rax
    3d91:	test   rdx,0x1
    3d98:	jne    3dc5 <botlish_fn_41+0x385>
    3d9e:	mov    rax,QWORD PTR [rip+0x0]        # 3da5 <botlish_fn_41+0x365>
			3da1: R_X86_64_GOTPCREL	rt_value_eq-0x4
    3da5:	mov    rdx,rcx
    3da8:	mov    rsi,QWORD PTR [rsp+0x10]
    3dad:	mov    rdi,QWORD PTR [rsp]
    3db1:	call   rax
    3db3:	test   rax,rax
    3db6:	jne    3ddd <botlish_fn_41+0x39d>
    3dbc:	mov    rdi,QWORD PTR [rsp]
    3dc0:	jmp    3eb2 <botlish_fn_41+0x472>
    3dc5:	mov    rdx,rcx
    3dc8:	mov    rsi,QWORD PTR [rsp+0x10]
    3dcd:	mov    eax,0x2
    3dd2:	cmp    rsi,rdx
    3dd5:	cmove  rax,QWORD PTR [rip+0x23b]        # 4018 <botlish_fn_41+0x5d8>
    3ddd:	cmp    rax,0x6
    3de1:	je     3df2 <botlish_fn_41+0x3b2>
    3de7:	mov    r12d,0x2
    3ded:	jmp    3e4a <botlish_fn_41+0x40a>
    3df2:	test   r15,0x1
    3df9:	jne    3e2a <botlish_fn_41+0x3ea>
    3dff:	mov    edx,0x1
    3e04:	mov    r10,QWORD PTR [rip+0x0]        # 3e0b <botlish_fn_41+0x3cb>
			3e07: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    3e0b:	mov    rsi,r15
    3e0e:	mov    rdi,QWORD PTR [rsp]
    3e12:	call   r10
    3e15:	mov    ecx,0x2
    3e1a:	test   rax,rax
    3e1d:	cmovl  rcx,QWORD PTR [rip+0x1f3]        # 4018 <botlish_fn_41+0x5d8>
    3e25:	jmp    3e3a <botlish_fn_41+0x3fa>
    3e2a:	mov    ecx,0x2
    3e2f:	test   r15,r15
    3e32:	cmovle rcx,QWORD PTR [rip+0x1de]        # 4018 <botlish_fn_41+0x5d8>
    3e3a:	cmp    rcx,0x6
    3e3e:	je     3e4a <botlish_fn_41+0x40a>
    3e44:	mov    r12d,0x2
    3e4a:	cmp    r12,0x6
    3e4e:	je     3e94 <botlish_fn_41+0x454>
    3e54:	mov    rdx,QWORD PTR [rsp+0x8]
    3e59:	mov    rsi,rbx
    3e5c:	mov    rdi,QWORD PTR [rsp]
    3e60:	call   3e65 <botlish_fn_41+0x425>
			3e61: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    3e65:	test   rax,rax
    3e68:	jne    3e77 <botlish_fn_41+0x437>
    3e6e:	mov    rdi,QWORD PTR [rsp]
    3e72:	jmp    3eb2 <botlish_fn_41+0x472>
    3e77:	mov    QWORD PTR [r13+0x0],rbx
    3e7b:	mov    QWORD PTR [r13+0x8],r14
    3e7f:	mov    QWORD PTR [r13+0x10],rax
    3e83:	mov    rcx,r15
    3e86:	mov    QWORD PTR [r13+0x18],rcx
    3e8a:	mov    QWORD PTR [rsp+0x8],rax
    3e8f:	jmp    3ac6 <botlish_fn_41+0x86>
    3e94:	mov    rdx,QWORD PTR [rsp+0x8]
    3e99:	mov    rsi,rbx
    3e9c:	mov    rdi,QWORD PTR [rsp]
    3ea0:	call   3ea5 <botlish_fn_41+0x465>
			3ea1: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    3ea5:	test   rax,rax
    3ea8:	jne    3ede <botlish_fn_41+0x49e>
    3eae:	mov    rdi,QWORD PTR [rsp]
    3eb2:	mov    rdi,QWORD PTR [rsp]
    3eb6:	mov    QWORD PTR [rdi],r13
    3eb9:	xor    rax,rax
    3ebc:	mov    rbx,QWORD PTR [rsp+0x20]
    3ec1:	mov    r12,QWORD PTR [rsp+0x28]
    3ec6:	mov    r13,QWORD PTR [rsp+0x30]
    3ecb:	mov    r14,QWORD PTR [rsp+0x38]
    3ed0:	mov    r15,QWORD PTR [rsp+0x40]
    3ed5:	add    rsp,0x50
    3ed9:	mov    rsp,rbp
    3edc:	pop    rbp
    3edd:	ret
    3ede:	mov    QWORD PTR [r13+0x0],rbx
    3ee2:	mov    QWORD PTR [r13+0x8],r14
    3ee6:	mov    QWORD PTR [r13+0x10],rax
    3eea:	mov    rdx,QWORD PTR [rsp+0x8]
    3eef:	mov    QWORD PTR [r13+0x18],rdx
    3ef3:	mov    r15,QWORD PTR [rsp+0x8]
    3ef8:	mov    QWORD PTR [rsp+0x8],rax
    3efd:	jmp    3ac6 <botlish_fn_41+0x86>
    3f02:	mov    rdi,QWORD PTR [rsp]
    3f06:	mov    QWORD PTR [rdi],r13
    3f09:	mov    rax,QWORD PTR [rsp+0x8]
    3f0e:	mov    rbx,QWORD PTR [rsp+0x20]
    3f13:	mov    r12,QWORD PTR [rsp+0x28]
    3f18:	mov    r13,QWORD PTR [rsp+0x30]
    3f1d:	mov    r14,QWORD PTR [rsp+0x38]
    3f22:	mov    r15,QWORD PTR [rsp+0x40]
    3f27:	add    rsp,0x50
    3f2b:	mov    rsp,rbp
    3f2e:	pop    rbp
    3f2f:	ret
    3f30:	mov    rax,r15
    3f33:	test   rax,0x1
    3f39:	jne    3f69 <botlish_fn_41+0x529>
    3f3f:	mov    edx,0x1
    3f44:	mov    rax,QWORD PTR [rip+0x0]        # 3f4b <botlish_fn_41+0x50b>
			3f47: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    3f4b:	mov    rsi,r15
    3f4e:	mov    rdi,QWORD PTR [rsp]
    3f52:	call   rax
    3f54:	mov    ecx,0x2
    3f59:	test   rax,rax
    3f5c:	cmovge rcx,QWORD PTR [rip+0xb4]        # 4018 <botlish_fn_41+0x5d8>
    3f64:	jmp    3f7f <botlish_fn_41+0x53f>
    3f69:	mov    ecx,0x2
    3f6e:	mov    rax,r15
    3f71:	mov    rdx,r15
    3f74:	test   rax,rdx
    3f77:	cmovg  rcx,QWORD PTR [rip+0x99]        # 4018 <botlish_fn_41+0x5d8>
    3f7f:	cmp    rcx,0x6
    3f83:	je     3fb7 <botlish_fn_41+0x577>
    3f89:	mov    rdi,QWORD PTR [rsp]
    3f8d:	mov    QWORD PTR [rdi],r13
    3f90:	mov    rax,QWORD PTR [rsp+0x8]
    3f95:	mov    rbx,QWORD PTR [rsp+0x20]
    3f9a:	mov    r12,QWORD PTR [rsp+0x28]
    3f9f:	mov    r13,QWORD PTR [rsp+0x30]
    3fa4:	mov    r14,QWORD PTR [rsp+0x38]
    3fa9:	mov    r15,QWORD PTR [rsp+0x40]
    3fae:	add    rsp,0x50
    3fb2:	mov    rsp,rbp
    3fb5:	pop    rbp
    3fb6:	ret
    3fb7:	mov    rdi,QWORD PTR [rsp]
    3fbb:	mov    QWORD PTR [rdi],r13
    3fbe:	mov    rax,r15
    3fc1:	mov    rbx,QWORD PTR [rsp+0x20]
    3fc6:	mov    r12,QWORD PTR [rsp+0x28]
    3fcb:	mov    r13,QWORD PTR [rsp+0x30]
    3fd0:	mov    r14,QWORD PTR [rsp+0x38]
    3fd5:	mov    r15,QWORD PTR [rsp+0x40]
    3fda:	add    rsp,0x50
    3fde:	mov    rsp,rbp
    3fe1:	pop    rbp
    3fe2:	ret
    3fe3:	mov    QWORD PTR [rsp],rdi
    3fe7:	mov    rax,QWORD PTR [rip+0x0]        # 3fee <botlish_fn_41+0x5ae>
			3fea: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3fee:	call   rax
    3ff0:	xor    rax,rax
    3ff3:	mov    rbx,QWORD PTR [rsp+0x20]
    3ff8:	mov    r12,QWORD PTR [rsp+0x28]
    3ffd:	mov    r13,QWORD PTR [rsp+0x30]
    4002:	mov    r14,QWORD PTR [rsp+0x38]
    4007:	mov    r15,QWORD PTR [rsp+0x40]
    400c:	add    rsp,0x50
    4010:	mov    rsp,rbp
    4013:	pop    rbp
    4014:	ret
    4015:	add    BYTE PTR [rax],al
    4017:	add    BYTE PTR [rsi],al
    4019:	add    BYTE PTR [rax],al
    401b:	add    BYTE PTR [rax],al
    401d:	add    BYTE PTR [rax],al
	...

0000000000004020 <botlish_entry_41: ht_find_insert<mutarray, any, int, int>>:
    4020:	push   rbp
    4021:	mov    rbp,rsp
    4024:	mov    rsi,QWORD PTR [rdx]
    4027:	mov    r9,QWORD PTR [rdx+0x8]
    402b:	mov    rcx,QWORD PTR [rdx+0x10]
    402f:	mov    r8,QWORD PTR [rdx+0x18]
    4033:	mov    rdx,r9
    4036:	call   403b <botlish_entry_41+0x1b>
			4037: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    403b:	mov    rsp,rbp
    403e:	pop    rbp
    403f:	ret

0000000000004040 <botlish_fn_42: ht_get<any, str>>:
    4040:	push   rbp
    4041:	mov    rbp,rsp
    4044:	sub    rsp,0x20
    4048:	mov    QWORD PTR [rsp],rbx
    404c:	mov    QWORD PTR [rsp+0x8],r12
    4051:	mov    QWORD PTR [rsp+0x10],r13
    4056:	mov    QWORD PTR [rsp+0x18],r14
    405b:	mov    rbx,QWORD PTR [rdi]
    405e:	mov    rax,QWORD PTR [rdi+0x8]
    4062:	lea    rcx,[rbx+0x18]
    4066:	cmp    rcx,rax
    4069:	ja     4230 <botlish_fn_42+0x1f0>
    406f:	lea    rax,[rbx+0x18]
    4073:	mov    QWORD PTR [rdi],rax
    4076:	mov    r12,rdi
    4079:	mov    QWORD PTR [rbx],0x0
    4080:	mov    QWORD PTR [rbx+0x8],0x0
    4088:	mov    QWORD PTR [rbx+0x10],0x0
    4090:	mov    QWORD PTR [rbx],rsi
    4093:	mov    r13,rsi
    4096:	mov    QWORD PTR [rbx+0x8],rdx
    409a:	mov    r14,rdx
    409d:	mov    rdx,r14
    40a0:	mov    rsi,r13
    40a3:	mov    rdi,r12
    40a6:	call   40ab <botlish_fn_42+0x6b>
			40a7: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    40ab:	test   rax,rax
    40ae:	jne    40bc <botlish_fn_42+0x7c>
    40b4:	mov    rdi,r12
    40b7:	jmp    41c2 <botlish_fn_42+0x182>
    40bc:	mov    QWORD PTR [rbx+0x10],rax
    40c0:	mov    rcx,rax
    40c3:	mov    rdx,r14
    40c6:	mov    rsi,r13
    40c9:	mov    rdi,r12
    40cc:	call   40d1 <botlish_fn_42+0x91>
			40cd: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    40d1:	mov    rcx,rax
    40d4:	mov    r14,rax
    40d7:	test   rax,rcx
    40da:	jne    40e8 <botlish_fn_42+0xa8>
    40e0:	mov    rdi,r12
    40e3:	jmp    41c2 <botlish_fn_42+0x182>
    40e8:	mov    rax,r14
    40eb:	mov    QWORD PTR [rbx+0x8],rax
    40ef:	test   rax,0x1
    40f5:	jne    4124 <botlish_fn_42+0xe4>
    40fb:	mov    edx,0x1
    4100:	mov    rax,QWORD PTR [rip+0x0]        # 4107 <botlish_fn_42+0xc7>
			4103: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    4107:	mov    rsi,r14
    410a:	mov    rdi,r12
    410d:	call   rax
    410f:	mov    ecx,0x2
    4114:	test   rax,rax
    4117:	cmovl  rcx,QWORD PTR [rip+0x141]        # 4260 <botlish_fn_42+0x220>
    411f:	jmp    4137 <botlish_fn_42+0xf7>
    4124:	mov    ecx,0x2
    4129:	mov    rax,r14
    412c:	test   rax,rax
    412f:	cmovle rcx,QWORD PTR [rip+0x129]        # 4260 <botlish_fn_42+0x220>
    4137:	cmp    rcx,0x6
    413b:	je     4209 <botlish_fn_42+0x1c9>
    4141:	mov    rsi,r13
    4144:	mov    rdi,r12
    4147:	call   414c <botlish_fn_42+0x10c>
			4148: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    414c:	test   rax,rax
    414f:	jne    415d <botlish_fn_42+0x11d>
    4155:	mov    rdi,r12
    4158:	jmp    41c2 <botlish_fn_42+0x182>
    415d:	xor    ecx,ecx
    415f:	test   rax,0x7
    4165:	jne    4176 <botlish_fn_42+0x136>
    416b:	movzx  rsi,BYTE PTR [rax]
    416f:	cmp    sil,0x8
    4173:	sete   cl
    4176:	test   cl,cl
    4178:	jne    41a3 <botlish_fn_42+0x163>
    417e:	mov    rdi,r12
    4181:	mov    r10,QWORD PTR [rdi+0x10]
    4185:	mov    rcx,QWORD PTR [r10+0x20]
    4189:	mov    edx,0x8
    418e:	mov    r10,QWORD PTR [rip+0x0]        # 4195 <botlish_fn_42+0x155>
			4191: R_X86_64_GOTPCREL	rt_type_error-0x4
    4195:	mov    rsi,rax
    4198:	call   r10
    419b:	mov    rdi,r12
    419e:	jmp    41c2 <botlish_fn_42+0x182>
    41a3:	mov    rsi,rax
    41a6:	mov    r11,QWORD PTR [rip+0x0]        # 41ad <botlish_fn_42+0x16d>
			41a9: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    41ad:	mov    rdx,r14
    41b0:	mov    rdi,r12
    41b3:	call   r11
    41b6:	test   rax,rax
    41b9:	jne    41e7 <botlish_fn_42+0x1a7>
    41bf:	mov    rdi,r12
    41c2:	mov    rdi,r12
    41c5:	mov    QWORD PTR [rdi],rbx
    41c8:	xor    rax,rax
    41cb:	mov    rbx,QWORD PTR [rsp]
    41cf:	mov    r12,QWORD PTR [rsp+0x8]
    41d4:	mov    r13,QWORD PTR [rsp+0x10]
    41d9:	mov    r14,QWORD PTR [rsp+0x18]
    41de:	add    rsp,0x20
    41e2:	mov    rsp,rbp
    41e5:	pop    rbp
    41e6:	ret
    41e7:	mov    rdi,r12
    41ea:	mov    QWORD PTR [rdi],rbx
    41ed:	mov    rbx,QWORD PTR [rsp]
    41f1:	mov    r12,QWORD PTR [rsp+0x8]
    41f6:	mov    r13,QWORD PTR [rsp+0x10]
    41fb:	mov    r14,QWORD PTR [rsp+0x18]
    4200:	add    rsp,0x20
    4204:	mov    rsp,rbp
    4207:	pop    rbp
    4208:	ret
    4209:	mov    rdi,r12
    420c:	mov    QWORD PTR [rdi],rbx
    420f:	mov    eax,0xa
    4214:	mov    rbx,QWORD PTR [rsp]
    4218:	mov    r12,QWORD PTR [rsp+0x8]
    421d:	mov    r13,QWORD PTR [rsp+0x10]
    4222:	mov    r14,QWORD PTR [rsp+0x18]
    4227:	add    rsp,0x20
    422b:	mov    rsp,rbp
    422e:	pop    rbp
    422f:	ret
    4230:	mov    r12,rdi
    4233:	mov    rax,QWORD PTR [rip+0x0]        # 423a <botlish_fn_42+0x1fa>
			4236: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    423a:	call   rax
    423c:	xor    rax,rax
    423f:	mov    rbx,QWORD PTR [rsp]
    4243:	mov    r12,QWORD PTR [rsp+0x8]
    4248:	mov    r13,QWORD PTR [rsp+0x10]
    424d:	mov    r14,QWORD PTR [rsp+0x18]
    4252:	add    rsp,0x20
    4256:	mov    rsp,rbp
    4259:	pop    rbp
    425a:	ret
    425b:	add    BYTE PTR [rax],al
    425d:	add    BYTE PTR [rax],al
    425f:	add    BYTE PTR [rsi],al
    4261:	add    BYTE PTR [rax],al
    4263:	add    BYTE PTR [rax],al
    4265:	add    BYTE PTR [rax],al
	...

0000000000004268 <botlish_entry_42: ht_get<any, str>>:
    4268:	push   rbp
    4269:	mov    rbp,rsp
    426c:	mov    rsi,QWORD PTR [rdx]
    426f:	mov    rdx,QWORD PTR [rdx+0x8]
    4273:	call   4278 <botlish_entry_42+0x10>
			4274: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    4278:	mov    rsp,rbp
    427b:	pop    rbp
    427c:	ret
    427d:	add    BYTE PTR [rax],al
	...

0000000000004280 <botlish_fn_43: ht_rehash_probe<mutarray, int, int>>:
    4280:	push   rbp
    4281:	mov    rbp,rsp
    4284:	sub    rsp,0x40
    4288:	mov    QWORD PTR [rsp+0x10],rbx
    428d:	mov    QWORD PTR [rsp+0x18],r12
    4292:	mov    QWORD PTR [rsp+0x20],r13
    4297:	mov    QWORD PTR [rsp+0x28],r14
    429c:	mov    QWORD PTR [rsp+0x30],r15
    42a1:	mov    r12,QWORD PTR [rdi]
    42a4:	mov    rax,QWORD PTR [rdi+0x8]
    42a8:	lea    r8,[r12+0x20]
    42ad:	cmp    r8,rax
    42b0:	ja     446c <botlish_fn_43+0x1ec>
    42b6:	lea    rax,[r12+0x20]
    42bb:	mov    QWORD PTR [rdi],rax
    42be:	mov    r14,rdi
    42c1:	mov    QWORD PTR [r12],0x0
    42c9:	mov    QWORD PTR [r12+0x8],0x0
    42d2:	mov    QWORD PTR [r12+0x10],0x0
    42db:	mov    QWORD PTR [r12+0x18],0x0
    42e4:	mov    QWORD PTR [r12],rsi
    42e8:	mov    QWORD PTR [r12+0x8],rdx
    42ed:	mov    QWORD PTR [r12+0x10],rcx
    42f2:	mov    r13,rcx
    42f5:	mov    r15,rdx
    42f8:	mov    rax,QWORD PTR [rip+0x0]        # 42ff <botlish_fn_43+0x7f>
			42fb: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    42ff:	mov    rbx,rsi
    4302:	mov    rdx,r15
    4305:	mov    rdi,r14
    4308:	call   rax
    430a:	test   rax,rax
    430d:	jne    431b <botlish_fn_43+0x9b>
    4313:	mov    rdi,r14
    4316:	jmp    43fd <botlish_fn_43+0x17d>
    431b:	mov    QWORD PTR [r12+0x18],rax
    4320:	mov    QWORD PTR [rsp],rax
    4324:	mov    rdi,r14
    4327:	call   432c <botlish_fn_43+0xac>
			4328: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    432c:	test   rax,rax
    432f:	jne    433d <botlish_fn_43+0xbd>
    4335:	mov    rdi,r14
    4338:	jmp    43fd <botlish_fn_43+0x17d>
    433d:	mov    rcx,QWORD PTR [rsp]
    4341:	mov    rdx,rcx
    4344:	and    rdx,rax
    4347:	mov    rcx,rax
    434a:	test   rdx,0x1
    4351:	jne    437b <botlish_fn_43+0xfb>
    4357:	mov    rax,QWORD PTR [rip+0x0]        # 435e <botlish_fn_43+0xde>
			435a: R_X86_64_GOTPCREL	rt_value_eq-0x4
    435e:	mov    rdx,rcx
    4361:	mov    rsi,QWORD PTR [rsp]
    4365:	mov    rdi,r14
    4368:	call   rax
    436a:	test   rax,rax
    436d:	jne    4392 <botlish_fn_43+0x112>
    4373:	mov    rdi,r14
    4376:	jmp    43fd <botlish_fn_43+0x17d>
    437b:	mov    rdx,rcx
    437e:	mov    rsi,QWORD PTR [rsp]
    4382:	mov    eax,0x2
    4387:	cmp    rsi,rdx
    438a:	cmove  rax,QWORD PTR [rip+0x10e]        # 44a0 <botlish_fn_43+0x220>
    4392:	cmp    rax,0x6
    4396:	je     4441 <botlish_fn_43+0x1c1>
    439c:	mov    QWORD PTR [r12+0x18],0x3
    43a5:	mov    rsi,r15
    43a8:	test   rsi,0x1
    43af:	je     43c9 <botlish_fn_43+0x149>
    43b5:	mov    rsi,r15
    43b8:	add    rsi,0x2
    43bc:	seto   dil
    43c0:	test   dil,dil
    43c3:	je     43e1 <botlish_fn_43+0x161>
    43c9:	mov    edx,0x3
    43ce:	mov    r8,QWORD PTR [rip+0x0]        # 43d5 <botlish_fn_43+0x155>
			43d1: R_X86_64_GOTPCREL	rt_int_add-0x4
    43d5:	mov    rsi,r15
    43d8:	mov    rdi,r14
    43db:	call   r8
    43de:	mov    rsi,rax
    43e1:	mov    r8,QWORD PTR [rip+0x0]        # 43e8 <botlish_fn_43+0x168>
			43e4: R_X86_64_GOTPCREL	rt_int_mod-0x4
    43e8:	mov    rdx,r13
    43eb:	mov    rdi,r14
    43ee:	call   r8
    43f1:	test   rax,rax
    43f4:	jne    4428 <botlish_fn_43+0x1a8>
    43fa:	mov    rdi,r14
    43fd:	mov    rdi,r14
    4400:	mov    QWORD PTR [rdi],r12
    4403:	xor    rax,rax
    4406:	mov    rbx,QWORD PTR [rsp+0x10]
    440b:	mov    r12,QWORD PTR [rsp+0x18]
    4410:	mov    r13,QWORD PTR [rsp+0x20]
    4415:	mov    r14,QWORD PTR [rsp+0x28]
    441a:	mov    r15,QWORD PTR [rsp+0x30]
    441f:	add    rsp,0x40
    4423:	mov    rsp,rbp
    4426:	pop    rbp
    4427:	ret
    4428:	mov    QWORD PTR [r12],rbx
    442c:	mov    QWORD PTR [r12+0x8],rax
    4431:	mov    QWORD PTR [r12+0x10],r13
    4436:	mov    rsi,rbx
    4439:	mov    r15,rax
    443c:	jmp    42f8 <botlish_fn_43+0x78>
    4441:	mov    rdi,r14
    4444:	mov    QWORD PTR [rdi],r12
    4447:	mov    rax,r15
    444a:	mov    rbx,QWORD PTR [rsp+0x10]
    444f:	mov    r12,QWORD PTR [rsp+0x18]
    4454:	mov    r13,QWORD PTR [rsp+0x20]
    4459:	mov    r14,QWORD PTR [rsp+0x28]
    445e:	mov    r15,QWORD PTR [rsp+0x30]
    4463:	add    rsp,0x40
    4467:	mov    rsp,rbp
    446a:	pop    rbp
    446b:	ret
    446c:	mov    r14,rdi
    446f:	mov    rax,QWORD PTR [rip+0x0]        # 4476 <botlish_fn_43+0x1f6>
			4472: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    4476:	call   rax
    4478:	xor    rax,rax
    447b:	mov    rbx,QWORD PTR [rsp+0x10]
    4480:	mov    r12,QWORD PTR [rsp+0x18]
    4485:	mov    r13,QWORD PTR [rsp+0x20]
    448a:	mov    r14,QWORD PTR [rsp+0x28]
    448f:	mov    r15,QWORD PTR [rsp+0x30]
    4494:	add    rsp,0x40
    4498:	mov    rsp,rbp
    449b:	pop    rbp
    449c:	ret
    449d:	add    BYTE PTR [rax],al
    449f:	add    BYTE PTR [rsi],al
    44a1:	add    BYTE PTR [rax],al
    44a3:	add    BYTE PTR [rax],al
    44a5:	add    BYTE PTR [rax],al
	...

00000000000044a8 <botlish_entry_43: ht_rehash_probe<mutarray, int, int>>:
    44a8:	push   rbp
    44a9:	mov    rbp,rsp
    44ac:	mov    rsi,QWORD PTR [rdx]
    44af:	mov    r8,QWORD PTR [rdx+0x8]
    44b3:	mov    rcx,QWORD PTR [rdx+0x10]
    44b7:	mov    rdx,r8
    44ba:	call   44bf <botlish_entry_43+0x17>
			44bb: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    44bf:	mov    rsp,rbp
    44c2:	pop    rbp
    44c3:	ret

00000000000044c4 <botlish_fn_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    44c4:	push   rbp
    44c5:	mov    rbp,rsp
    44c8:	sub    rsp,0x50
    44cc:	mov    QWORD PTR [rsp+0x20],rbx
    44d1:	mov    QWORD PTR [rsp+0x28],r12
    44d6:	mov    QWORD PTR [rsp+0x30],r13
    44db:	mov    QWORD PTR [rsp+0x38],r14
    44e0:	mov    QWORD PTR [rsp+0x40],r15
    44e5:	mov    r10,QWORD PTR [rbp+0x10]
    44e9:	mov    rbx,QWORD PTR [rdi]
    44ec:	mov    rax,QWORD PTR [rdi+0x8]
    44f0:	lea    r11,[rbx+0x38]
    44f4:	cmp    r11,rax
    44f7:	ja     46cc <botlish_fn_44+0x208>
    44fd:	lea    rax,[rbx+0x38]
    4501:	mov    QWORD PTR [rdi],rax
    4504:	mov    r12,rdi
    4507:	mov    QWORD PTR [rbx],0x0
    450e:	mov    QWORD PTR [rbx+0x8],0x0
    4516:	mov    QWORD PTR [rbx+0x10],0x0
    451e:	mov    QWORD PTR [rbx+0x18],0x0
    4526:	mov    QWORD PTR [rbx+0x20],0x0
    452e:	mov    QWORD PTR [rbx+0x28],0x0
    4536:	mov    QWORD PTR [rbx+0x30],0x0
    453e:	mov    QWORD PTR [rbx],rsi
    4541:	mov    QWORD PTR [rsp],rsi
    4545:	mov    QWORD PTR [rbx+0x8],rdx
    4549:	mov    QWORD PTR [rsp+0x8],rdx
    454e:	mov    QWORD PTR [rbx+0x10],rcx
    4552:	mov    r13,rcx
    4555:	mov    QWORD PTR [rbx+0x18],r8
    4559:	mov    QWORD PTR [rsp+0x10],r8
    455e:	mov    QWORD PTR [rbx+0x20],r9
    4562:	mov    r15,r9
    4565:	mov    QWORD PTR [rbx+0x28],r10
    4569:	mov    r14,r10
    456c:	mov    rax,QWORD PTR [rip+0x0]        # 4573 <botlish_fn_44+0xaf>
			456f: R_X86_64_GOTPCREL	rt_hash-0x4
    4573:	mov    rsi,r15
    4576:	mov    rdi,r12
    4579:	call   rax
    457b:	test   rax,rax
    457e:	mov    rsi,rax
    4581:	jne    458f <botlish_fn_44+0xcb>
    4587:	mov    rdi,r12
    458a:	jmp    4674 <botlish_fn_44+0x1b0>
    458f:	mov    rax,QWORD PTR [rip+0x0]        # 4596 <botlish_fn_44+0xd2>
			4592: R_X86_64_GOTPCREL	rt_int_mod-0x4
    4596:	mov    rdx,QWORD PTR [rsp+0x10]
    459b:	mov    rdi,r12
    459e:	call   rax
    45a0:	test   rax,rax
    45a3:	jne    45b1 <botlish_fn_44+0xed>
    45a9:	mov    rdi,r12
    45ac:	jmp    4674 <botlish_fn_44+0x1b0>
    45b1:	mov    QWORD PTR [rbx+0x30],rax
    45b5:	mov    rcx,QWORD PTR [rsp+0x10]
    45ba:	mov    rdx,rax
    45bd:	mov    rsi,QWORD PTR [rsp]
    45c1:	mov    rdi,r12
    45c4:	call   45c9 <botlish_fn_44+0x105>
			45c5: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    45c9:	test   rax,rax
    45cc:	jne    45da <botlish_fn_44+0x116>
    45d2:	mov    rdi,r12
    45d5:	jmp    4674 <botlish_fn_44+0x1b0>
    45da:	mov    QWORD PTR [rbx+0x18],rax
    45de:	mov    QWORD PTR [rsp+0x10],rax
    45e3:	mov    rdi,r12
    45e6:	call   45eb <botlish_fn_44+0x127>
			45e7: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    45eb:	test   rax,rax
    45ee:	mov    rcx,rax
    45f1:	jne    45ff <botlish_fn_44+0x13b>
    45f7:	mov    rdi,r12
    45fa:	jmp    4674 <botlish_fn_44+0x1b0>
    45ff:	mov    rax,QWORD PTR [rip+0x0]        # 4606 <botlish_fn_44+0x142>
			4602: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    4606:	mov    rsi,QWORD PTR [rsp]
    460a:	mov    rdx,QWORD PTR [rsp+0x10]
    460f:	mov    rdi,r12
    4612:	call   rax
    4614:	test   rax,rax
    4617:	jne    4625 <botlish_fn_44+0x161>
    461d:	mov    rdi,r12
    4620:	jmp    4674 <botlish_fn_44+0x1b0>
    4625:	mov    r8,QWORD PTR [rip+0x0]        # 462c <botlish_fn_44+0x168>
			4628: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    462c:	mov    rcx,r15
    462f:	mov    rsi,QWORD PTR [rsp+0x8]
    4634:	mov    rdx,QWORD PTR [rsp+0x10]
    4639:	mov    rdi,r12
    463c:	call   r8
    463f:	test   rax,rax
    4642:	jne    4650 <botlish_fn_44+0x18c>
    4648:	mov    rdi,r12
    464b:	jmp    4674 <botlish_fn_44+0x1b0>
    4650:	mov    r8,QWORD PTR [rip+0x0]        # 4657 <botlish_fn_44+0x193>
			4653: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    4657:	mov    rcx,r14
    465a:	mov    rdx,QWORD PTR [rsp+0x10]
    465f:	mov    rsi,r13
    4662:	mov    rdi,r12
    4665:	call   r8
    4668:	test   rax,rax
    466b:	jne    469f <botlish_fn_44+0x1db>
    4671:	mov    rdi,r12
    4674:	mov    rdi,r12
    4677:	mov    QWORD PTR [rdi],rbx
    467a:	xor    rax,rax
    467d:	mov    rbx,QWORD PTR [rsp+0x20]
    4682:	mov    r12,QWORD PTR [rsp+0x28]
    4687:	mov    r13,QWORD PTR [rsp+0x30]
    468c:	mov    r14,QWORD PTR [rsp+0x38]
    4691:	mov    r15,QWORD PTR [rsp+0x40]
    4696:	add    rsp,0x50
    469a:	mov    rsp,rbp
    469d:	pop    rbp
    469e:	ret
    469f:	mov    rdi,r12
    46a2:	mov    QWORD PTR [rdi],rbx
    46a5:	mov    eax,0xa
    46aa:	mov    rbx,QWORD PTR [rsp+0x20]
    46af:	mov    r12,QWORD PTR [rsp+0x28]
    46b4:	mov    r13,QWORD PTR [rsp+0x30]
    46b9:	mov    r14,QWORD PTR [rsp+0x38]
    46be:	mov    r15,QWORD PTR [rsp+0x40]
    46c3:	add    rsp,0x50
    46c7:	mov    rsp,rbp
    46ca:	pop    rbp
    46cb:	ret
    46cc:	mov    r12,rdi
    46cf:	mov    rax,QWORD PTR [rip+0x0]        # 46d6 <botlish_fn_44+0x212>
			46d2: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    46d6:	call   rax
    46d8:	xor    rax,rax
    46db:	mov    rbx,QWORD PTR [rsp+0x20]
    46e0:	mov    r12,QWORD PTR [rsp+0x28]
    46e5:	mov    r13,QWORD PTR [rsp+0x30]
    46ea:	mov    r14,QWORD PTR [rsp+0x38]
    46ef:	mov    r15,QWORD PTR [rsp+0x40]
    46f4:	add    rsp,0x50
    46f8:	mov    rsp,rbp
    46fb:	pop    rbp
    46fc:	ret

00000000000046fd <botlish_entry_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    46fd:	push   rbp
    46fe:	mov    rbp,rsp
    4701:	sub    rsp,0x10
    4705:	mov    rsi,QWORD PTR [rdx]
    4708:	mov    r10,QWORD PTR [rdx+0x8]
    470c:	mov    rcx,QWORD PTR [rdx+0x10]
    4710:	mov    r8,QWORD PTR [rdx+0x18]
    4714:	mov    r9,QWORD PTR [rdx+0x20]
    4718:	mov    r11,QWORD PTR [rdx+0x28]
    471c:	mov    QWORD PTR [rsp],r11
    4720:	mov    rdx,r10
    4723:	call   4728 <botlish_entry_44+0x2b>
			4724: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    4728:	add    rsp,0x10
    472c:	mov    rsp,rbp
    472f:	pop    rbp
    4730:	ret
    4731:	add    BYTE PTR [rax],al
    4733:	add    BYTE PTR [rax],al
    4735:	add    BYTE PTR [rax],al
	...

0000000000004738 <botlish_fn_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    4738:	push   rbp
    4739:	mov    rbp,rsp
    473c:	sub    rsp,0x80
    4743:	mov    QWORD PTR [rsp+0x50],rbx
    4748:	mov    QWORD PTR [rsp+0x58],r12
    474d:	mov    QWORD PTR [rsp+0x60],r13
    4752:	mov    QWORD PTR [rsp+0x68],r14
    4757:	mov    QWORD PTR [rsp+0x70],r15
    475c:	mov    r13,QWORD PTR [rbp+0x10]
    4760:	mov    r14,QWORD PTR [rbp+0x18]
    4764:	mov    r15,QWORD PTR [rbp+0x20]
    4768:	mov    r12,QWORD PTR [rbp+0x28]
    476c:	mov    QWORD PTR [rsp+0x38],r12
    4771:	mov    r12,QWORD PTR [rdi]
    4774:	mov    rax,QWORD PTR [rdi+0x8]
    4778:	lea    r10,[r12+0x58]
    477d:	cmp    r10,rax
    4780:	ja     4c1b <botlish_fn_45+0x4e3>
    4786:	lea    rax,[r12+0x58]
    478b:	mov    QWORD PTR [rdi],rax
    478e:	mov    QWORD PTR [rsp+0x10],rdi
    4793:	mov    QWORD PTR [r12],0x0
    479b:	mov    QWORD PTR [r12+0x8],0x0
    47a4:	mov    QWORD PTR [r12+0x10],0x0
    47ad:	mov    QWORD PTR [r12+0x18],0x0
    47b6:	mov    QWORD PTR [r12+0x20],0x0
    47bf:	mov    QWORD PTR [r12+0x28],0x0
    47c8:	mov    QWORD PTR [r12+0x30],0x0
    47d1:	mov    QWORD PTR [r12+0x38],0x0
    47da:	mov    QWORD PTR [r12+0x40],0x0
    47e3:	mov    QWORD PTR [r12+0x48],0x0
    47ec:	mov    QWORD PTR [r12+0x50],0x0
    47f5:	mov    QWORD PTR [r12],rsi
    47f9:	mov    QWORD PTR [rsp+0x18],rsi
    47fe:	mov    QWORD PTR [r12+0x8],rdx
    4803:	mov    QWORD PTR [rsp+0x20],rdx
    4808:	mov    QWORD PTR [r12+0x10],rcx
    480d:	mov    QWORD PTR [rsp+0x28],rcx
    4812:	mov    QWORD PTR [r12+0x18],r8
    4817:	mov    QWORD PTR [r12+0x20],r9
    481c:	mov    QWORD PTR [rsp+0x30],r9
    4821:	mov    QWORD PTR [r12+0x28],r13
    4826:	mov    QWORD PTR [r12+0x30],r14
    482b:	mov    QWORD PTR [r12+0x38],r15
    4830:	mov    rax,QWORD PTR [rsp+0x38]
    4835:	mov    QWORD PTR [r12+0x40],rax
    483a:	mov    rbx,QWORD PTR [rsp+0x30]
    483f:	mov    rsi,r8
    4842:	mov    rax,rsi
    4845:	and    rax,rbx
    4848:	mov    QWORD PTR [rsp+0x40],rsi
    484d:	test   rax,0x1
    4853:	jne    4889 <botlish_fn_45+0x151>
    4859:	mov    rax,QWORD PTR [rip+0x0]        # 4860 <botlish_fn_45+0x128>
			485c: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    4860:	mov    rdx,rbx
    4863:	mov    rsi,QWORD PTR [rsp+0x40]
    4868:	mov    rdi,QWORD PTR [rsp+0x10]
    486d:	call   rax
    486f:	mov    QWORD PTR [rsp+0x30],rbx
    4874:	mov    ecx,0x2
    4879:	test   rax,rax
    487c:	cmovge rcx,QWORD PTR [rip+0x3d4]        # 4c58 <botlish_fn_45+0x520>
    4884:	jmp    48a8 <botlish_fn_45+0x170>
    4889:	mov    QWORD PTR [rsp+0x30],rbx
    488e:	mov    ecx,0x2
    4893:	mov    rsi,QWORD PTR [rsp+0x40]
    4898:	mov    r9,QWORD PTR [rsp+0x30]
    489d:	cmp    rsi,r9
    48a0:	cmovge rcx,QWORD PTR [rip+0x3b0]        # 4c58 <botlish_fn_45+0x520>
    48a8:	cmp    rcx,0x6
    48ac:	je     4be9 <botlish_fn_45+0x4b1>
    48b2:	xor    eax,eax
    48b4:	mov    rsi,QWORD PTR [rsp+0x18]
    48b9:	test   rsi,0x7
    48c0:	jne    48cf <botlish_fn_45+0x197>
    48c6:	movzx  rax,BYTE PTR [rsi]
    48ca:	cmp    al,0x8
    48cc:	sete   al
    48cf:	test   al,al
    48d1:	jne    48fc <botlish_fn_45+0x1c4>
    48d7:	mov    rdi,QWORD PTR [rsp+0x10]
    48dc:	mov    rax,QWORD PTR [rdi+0x10]
    48e0:	mov    rcx,QWORD PTR [rax+0x20]
    48e4:	mov    edx,0x8
    48e9:	mov    rax,QWORD PTR [rip+0x0]        # 48f0 <botlish_fn_45+0x1b8>
			48ec: R_X86_64_GOTPCREL	rt_type_error-0x4
    48f0:	call   rax
    48f2:	mov    rdi,QWORD PTR [rsp+0x10]
    48f7:	jmp    4b02 <botlish_fn_45+0x3ca>
    48fc:	mov    QWORD PTR [rsp+0x18],rsi
    4901:	mov    rax,QWORD PTR [rip+0x0]        # 4908 <botlish_fn_45+0x1d0>
			4904: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    4908:	mov    rdx,QWORD PTR [rsp+0x40]
    490d:	mov    rdi,QWORD PTR [rsp+0x10]
    4912:	call   rax
    4914:	test   rax,rax
    4917:	jne    4927 <botlish_fn_45+0x1ef>
    491d:	mov    rdi,QWORD PTR [rsp+0x10]
    4922:	jmp    4b02 <botlish_fn_45+0x3ca>
    4927:	mov    QWORD PTR [r12+0x48],rax
    492c:	mov    rbx,rax
    492f:	mov    rdi,QWORD PTR [rsp+0x10]
    4934:	call   4939 <botlish_fn_45+0x201>
			4935: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    4939:	test   rax,rax
    493c:	jne    494c <botlish_fn_45+0x214>
    4942:	mov    rdi,QWORD PTR [rsp+0x10]
    4947:	jmp    4b02 <botlish_fn_45+0x3ca>
    494c:	mov    r9,rbx
    494f:	mov    rsi,r9
    4952:	and    rsi,rax
    4955:	mov    rdx,rax
    4958:	test   rsi,0x1
    495f:	jne    498a <botlish_fn_45+0x252>
    4965:	mov    r8,QWORD PTR [rip+0x0]        # 496c <botlish_fn_45+0x234>
			4968: R_X86_64_GOTPCREL	rt_value_eq-0x4
    496c:	mov    rsi,rbx
    496f:	mov    rdi,QWORD PTR [rsp+0x10]
    4974:	call   r8
    4977:	test   rax,rax
    497a:	jne    499d <botlish_fn_45+0x265>
    4980:	mov    rdi,QWORD PTR [rsp+0x10]
    4985:	jmp    4b02 <botlish_fn_45+0x3ca>
    498a:	mov    rsi,rbx
    498d:	mov    eax,0x2
    4992:	cmp    rsi,rdx
    4995:	cmove  rax,QWORD PTR [rip+0x2bb]        # 4c58 <botlish_fn_45+0x520>
    499d:	cmp    rax,0x6
    49a1:	je     49b1 <botlish_fn_45+0x279>
    49a7:	mov    rbx,QWORD PTR [rsp+0x38]
    49ac:	jmp    4b32 <botlish_fn_45+0x3fa>
    49b1:	xor    eax,eax
    49b3:	mov    rdx,QWORD PTR [rsp+0x20]
    49b8:	test   rdx,0x7
    49bf:	je     49cf <botlish_fn_45+0x297>
    49c5:	mov    QWORD PTR [rsp+0x20],rdx
    49ca:	jmp    49dd <botlish_fn_45+0x2a5>
    49cf:	movzx  rax,BYTE PTR [rdx]
    49d3:	mov    QWORD PTR [rsp+0x20],rdx
    49d8:	cmp    al,0x8
    49da:	sete   al
    49dd:	test   al,al
    49df:	jne    4a0f <botlish_fn_45+0x2d7>
    49e5:	mov    rdi,QWORD PTR [rsp+0x10]
    49ea:	mov    rax,QWORD PTR [rdi+0x10]
    49ee:	mov    rcx,QWORD PTR [rax+0x20]
    49f2:	mov    edx,0x8
    49f7:	mov    rax,QWORD PTR [rip+0x0]        # 49fe <botlish_fn_45+0x2c6>
			49fa: R_X86_64_GOTPCREL	rt_type_error-0x4
    49fe:	mov    rsi,QWORD PTR [rsp+0x20]
    4a03:	call   rax
    4a05:	mov    rdi,QWORD PTR [rsp+0x10]
    4a0a:	jmp    4b02 <botlish_fn_45+0x3ca>
    4a0f:	mov    rax,QWORD PTR [rip+0x0]        # 4a16 <botlish_fn_45+0x2de>
			4a12: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    4a16:	mov    rdx,QWORD PTR [rsp+0x40]
    4a1b:	mov    rsi,QWORD PTR [rsp+0x20]
    4a20:	mov    rdi,QWORD PTR [rsp+0x10]
    4a25:	call   rax
    4a27:	test   rax,rax
    4a2a:	jne    4a3a <botlish_fn_45+0x302>
    4a30:	mov    rdi,QWORD PTR [rsp+0x10]
    4a35:	jmp    4b02 <botlish_fn_45+0x3ca>
    4a3a:	mov    QWORD PTR [r12+0x48],rax
    4a3f:	mov    rbx,rax
    4a42:	xor    esi,esi
    4a44:	mov    rcx,QWORD PTR [rsp+0x28]
    4a49:	test   rcx,0x7
    4a50:	je     4a60 <botlish_fn_45+0x328>
    4a56:	mov    QWORD PTR [rsp+0x28],rcx
    4a5b:	jmp    4a6f <botlish_fn_45+0x337>
    4a60:	movzx  rax,BYTE PTR [rcx]
    4a64:	mov    QWORD PTR [rsp+0x28],rcx
    4a69:	cmp    al,0x8
    4a6b:	sete   sil
    4a6f:	test   sil,sil
    4a72:	jne    4aa2 <botlish_fn_45+0x36a>
    4a78:	mov    rdi,QWORD PTR [rsp+0x10]
    4a7d:	mov    rax,QWORD PTR [rdi+0x10]
    4a81:	mov    rcx,QWORD PTR [rax+0x20]
    4a85:	mov    edx,0x8
    4a8a:	mov    rax,QWORD PTR [rip+0x0]        # 4a91 <botlish_fn_45+0x359>
			4a8d: R_X86_64_GOTPCREL	rt_type_error-0x4
    4a91:	mov    rsi,QWORD PTR [rsp+0x28]
    4a96:	call   rax
    4a98:	mov    rdi,QWORD PTR [rsp+0x10]
    4a9d:	jmp    4b02 <botlish_fn_45+0x3ca>
    4aa2:	mov    rax,QWORD PTR [rip+0x0]        # 4aa9 <botlish_fn_45+0x371>
			4aa5: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    4aa9:	mov    rdx,QWORD PTR [rsp+0x40]
    4aae:	mov    rsi,QWORD PTR [rsp+0x28]
    4ab3:	mov    rdi,QWORD PTR [rsp+0x10]
    4ab8:	call   rax
    4aba:	test   rax,rax
    4abd:	jne    4acd <botlish_fn_45+0x395>
    4ac3:	mov    rdi,QWORD PTR [rsp+0x10]
    4ac8:	jmp    4b02 <botlish_fn_45+0x3ca>
    4acd:	mov    QWORD PTR [r12+0x50],rax
    4ad2:	mov    QWORD PTR [rsp],rax
    4ad6:	mov    r9,rbx
    4ad9:	mov    rbx,QWORD PTR [rsp+0x38]
    4ade:	mov    rcx,r15
    4ae1:	mov    rdx,r14
    4ae4:	mov    rsi,r13
    4ae7:	mov    rdi,QWORD PTR [rsp+0x10]
    4aec:	mov    r8,rbx
    4aef:	call   4af4 <botlish_fn_45+0x3bc>
			4af0: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    4af4:	test   rax,rax
    4af7:	jne    4b32 <botlish_fn_45+0x3fa>
    4afd:	mov    rdi,QWORD PTR [rsp+0x10]
    4b02:	mov    rdi,QWORD PTR [rsp+0x10]
    4b07:	mov    QWORD PTR [rdi],r12
    4b0a:	xor    rax,rax
    4b0d:	mov    rbx,QWORD PTR [rsp+0x50]
    4b12:	mov    r12,QWORD PTR [rsp+0x58]
    4b17:	mov    r13,QWORD PTR [rsp+0x60]
    4b1c:	mov    r14,QWORD PTR [rsp+0x68]
    4b21:	mov    r15,QWORD PTR [rsp+0x70]
    4b26:	add    rsp,0x80
    4b2d:	mov    rsp,rbp
    4b30:	pop    rbp
    4b31:	ret
    4b32:	mov    QWORD PTR [r12+0x48],0x3
    4b3b:	mov    rsi,QWORD PTR [rsp+0x40]
    4b40:	test   rsi,0x1
    4b47:	je     4b73 <botlish_fn_45+0x43b>
    4b4d:	mov    rsi,QWORD PTR [rsp+0x40]
    4b52:	mov    rcx,rsi
    4b55:	add    rcx,0x2
    4b59:	seto   al
    4b5c:	test   al,al
    4b5e:	jne    4b73 <botlish_fn_45+0x43b>
    4b64:	mov    rsi,QWORD PTR [rsp+0x18]
    4b69:	mov    QWORD PTR [rsp+0x40],rcx
    4b6e:	jmp    4b95 <botlish_fn_45+0x45d>
    4b73:	mov    edx,0x3
    4b78:	mov    rax,QWORD PTR [rip+0x0]        # 4b7f <botlish_fn_45+0x447>
			4b7b: R_X86_64_GOTPCREL	rt_int_add-0x4
    4b7f:	mov    rsi,QWORD PTR [rsp+0x40]
    4b84:	mov    rdi,QWORD PTR [rsp+0x10]
    4b89:	call   rax
    4b8b:	mov    rsi,QWORD PTR [rsp+0x18]
    4b90:	mov    QWORD PTR [rsp+0x40],rax
    4b95:	mov    rsi,QWORD PTR [rsp+0x18]
    4b9a:	mov    QWORD PTR [r12],rsi
    4b9e:	mov    rsi,QWORD PTR [rsp+0x20]
    4ba3:	mov    QWORD PTR [r12+0x8],rsi
    4ba8:	mov    rsi,QWORD PTR [rsp+0x28]
    4bad:	mov    QWORD PTR [r12+0x10],rsi
    4bb2:	mov    rsi,QWORD PTR [rsp+0x40]
    4bb7:	mov    QWORD PTR [r12+0x18],rsi
    4bbc:	mov    r9,QWORD PTR [rsp+0x30]
    4bc1:	mov    QWORD PTR [r12+0x20],r9
    4bc6:	mov    QWORD PTR [r12+0x28],r13
    4bcb:	mov    QWORD PTR [r12+0x30],r14
    4bd0:	mov    QWORD PTR [r12+0x38],r15
    4bd5:	mov    QWORD PTR [r12+0x40],rbx
    4bda:	mov    QWORD PTR [rsp+0x38],rbx
    4bdf:	mov    rbx,QWORD PTR [rsp+0x30]
    4be4:	jmp    4842 <botlish_fn_45+0x10a>
    4be9:	mov    rdi,QWORD PTR [rsp+0x10]
    4bee:	mov    QWORD PTR [rdi],r12
    4bf1:	mov    eax,0xa
    4bf6:	mov    rbx,QWORD PTR [rsp+0x50]
    4bfb:	mov    r12,QWORD PTR [rsp+0x58]
    4c00:	mov    r13,QWORD PTR [rsp+0x60]
    4c05:	mov    r14,QWORD PTR [rsp+0x68]
    4c0a:	mov    r15,QWORD PTR [rsp+0x70]
    4c0f:	add    rsp,0x80
    4c16:	mov    rsp,rbp
    4c19:	pop    rbp
    4c1a:	ret
    4c1b:	mov    QWORD PTR [rsp+0x10],rdi
    4c20:	mov    rsi,QWORD PTR [rip+0x0]        # 4c27 <botlish_fn_45+0x4ef>
			4c23: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    4c27:	call   rsi
    4c29:	xor    rax,rax
    4c2c:	mov    rbx,QWORD PTR [rsp+0x50]
    4c31:	mov    r12,QWORD PTR [rsp+0x58]
    4c36:	mov    r13,QWORD PTR [rsp+0x60]
    4c3b:	mov    r14,QWORD PTR [rsp+0x68]
    4c40:	mov    r15,QWORD PTR [rsp+0x70]
    4c45:	add    rsp,0x80
    4c4c:	mov    rsp,rbp
    4c4f:	pop    rbp
    4c50:	ret
    4c51:	add    BYTE PTR [rax],al
    4c53:	add    BYTE PTR [rax],al
    4c55:	add    BYTE PTR [rax],al
    4c57:	add    BYTE PTR [rsi],al
    4c59:	add    BYTE PTR [rax],al
    4c5b:	add    BYTE PTR [rax],al
    4c5d:	add    BYTE PTR [rax],al
	...

0000000000004c60 <botlish_entry_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    4c60:	push   rbp
    4c61:	mov    rbp,rsp
    4c64:	sub    rsp,0x30
    4c68:	mov    QWORD PTR [rsp+0x20],r12
    4c6d:	mov    rsi,QWORD PTR [rdx]
    4c70:	mov    rax,QWORD PTR [rdx+0x8]
    4c74:	mov    rcx,QWORD PTR [rdx+0x10]
    4c78:	mov    r8,QWORD PTR [rdx+0x18]
    4c7c:	mov    r9,QWORD PTR [rdx+0x20]
    4c80:	mov    r10,QWORD PTR [rdx+0x28]
    4c84:	mov    r11,QWORD PTR [rdx+0x30]
    4c88:	mov    r12,QWORD PTR [rdx+0x38]
    4c8c:	mov    rdx,QWORD PTR [rdx+0x40]
    4c90:	mov    QWORD PTR [rsp],r10
    4c94:	mov    QWORD PTR [rsp+0x8],r11
    4c99:	mov    QWORD PTR [rsp+0x10],r12
    4c9e:	mov    QWORD PTR [rsp+0x18],rdx
    4ca3:	mov    rdx,rax
    4ca6:	call   4cab <botlish_entry_45+0x4b>
			4ca7: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    4cab:	mov    r12,QWORD PTR [rsp+0x20]
    4cb0:	add    rsp,0x30
    4cb4:	mov    rsp,rbp
    4cb7:	pop    rbp
    4cb8:	ret

0000000000004cb9 <botlish_fn_46: ht_rehash<mutarray, int>>:
    4cb9:	push   rbp
    4cba:	mov    rbp,rsp
    4cbd:	sub    rsp,0x80
    4cc4:	mov    QWORD PTR [rsp+0x50],rbx
    4cc9:	mov    QWORD PTR [rsp+0x58],r12
    4cce:	mov    QWORD PTR [rsp+0x60],r13
    4cd3:	mov    QWORD PTR [rsp+0x68],r14
    4cd8:	mov    QWORD PTR [rsp+0x70],r15
    4cdd:	mov    r12,QWORD PTR [rdi]
    4ce0:	mov    rax,QWORD PTR [rdi+0x8]
    4ce4:	lea    rcx,[r12+0x50]
    4ce9:	cmp    rcx,rax
    4cec:	ja     5009 <botlish_fn_46+0x350>
    4cf2:	lea    rax,[r12+0x50]
    4cf7:	mov    QWORD PTR [rdi],rax
    4cfa:	mov    r13,rdi
    4cfd:	mov    QWORD PTR [r12],0x0
    4d05:	mov    QWORD PTR [r12+0x8],0x0
    4d0e:	mov    QWORD PTR [r12+0x10],0x0
    4d17:	mov    QWORD PTR [r12+0x18],0x0
    4d20:	mov    QWORD PTR [r12+0x20],0x0
    4d29:	mov    QWORD PTR [r12+0x28],0x0
    4d32:	mov    QWORD PTR [r12+0x30],0x0
    4d3b:	mov    QWORD PTR [r12+0x38],0x0
    4d44:	mov    QWORD PTR [r12+0x40],0x0
    4d4d:	mov    QWORD PTR [r12+0x48],0x0
    4d56:	mov    QWORD PTR [r12],rsi
    4d5a:	mov    r14,rsi
    4d5d:	mov    QWORD PTR [r12+0x8],rdx
    4d62:	mov    rbx,rdx
    4d65:	mov    rsi,r14
    4d68:	mov    rdi,r13
    4d6b:	call   4d70 <botlish_fn_46+0xb7>
			4d6c: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    4d70:	test   rax,rax
    4d73:	jne    4d81 <botlish_fn_46+0xc8>
    4d79:	mov    rdi,r13
    4d7c:	jmp    4fab <botlish_fn_46+0x2f2>
    4d81:	mov    QWORD PTR [r12+0x10],rax
    4d86:	mov    r15,rax
    4d89:	mov    rsi,r14
    4d8c:	mov    rdi,r13
    4d8f:	call   4d94 <botlish_fn_46+0xdb>
			4d90: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    4d94:	test   rax,rax
    4d97:	jne    4da5 <botlish_fn_46+0xec>
    4d9d:	mov    rdi,r13
    4da0:	jmp    4fab <botlish_fn_46+0x2f2>
    4da5:	mov    QWORD PTR [r12+0x18],rax
    4daa:	mov    QWORD PTR [rsp+0x48],rax
    4daf:	mov    rsi,r14
    4db2:	mov    rdi,r13
    4db5:	call   4dba <botlish_fn_46+0x101>
			4db6: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    4dba:	test   rax,rax
    4dbd:	jne    4dcb <botlish_fn_46+0x112>
    4dc3:	mov    rdi,r13
    4dc6:	jmp    4fab <botlish_fn_46+0x2f2>
    4dcb:	mov    QWORD PTR [r12+0x20],rax
    4dd0:	mov    QWORD PTR [rsp+0x40],rax
    4dd5:	mov    rsi,r14
    4dd8:	mov    rdi,r13
    4ddb:	call   4de0 <botlish_fn_46+0x127>
			4ddc: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4de0:	test   rax,rax
    4de3:	jne    4df1 <botlish_fn_46+0x138>
    4de9:	mov    rdi,r13
    4dec:	jmp    4fab <botlish_fn_46+0x2f2>
    4df1:	mov    QWORD PTR [r12+0x28],rax
    4df6:	mov    QWORD PTR [rsp+0x38],rax
    4dfb:	mov    r10,QWORD PTR [rip+0x0]        # 4e02 <botlish_fn_46+0x149>
			4dfe: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    4e02:	mov    rsi,rbx
    4e05:	mov    rdi,r13
    4e08:	call   r10
    4e0b:	mov    rcx,rax
    4e0e:	mov    QWORD PTR [rsp+0x30],rax
    4e13:	test   rax,rcx
    4e16:	jne    4e24 <botlish_fn_46+0x16b>
    4e1c:	mov    rdi,r13
    4e1f:	jmp    4fab <botlish_fn_46+0x2f2>
    4e24:	mov    rax,QWORD PTR [rsp+0x30]
    4e29:	mov    QWORD PTR [r12+0x30],rax
    4e2e:	mov    edx,0x1
    4e33:	mov    QWORD PTR [r12+0x38],0x1
    4e3c:	mov    rcx,rbx
    4e3f:	mov    rsi,QWORD PTR [rsp+0x30]
    4e44:	mov    rdi,r13
    4e47:	call   4e4c <botlish_fn_46+0x193>
			4e48: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    4e4c:	test   rax,rax
    4e4f:	jne    4e5d <botlish_fn_46+0x1a4>
    4e55:	mov    rdi,r13
    4e58:	jmp    4fab <botlish_fn_46+0x2f2>
    4e5d:	mov    rax,QWORD PTR [rip+0x0]        # 4e64 <botlish_fn_46+0x1ab>
			4e60: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    4e64:	mov    rsi,rbx
    4e67:	mov    rdi,r13
    4e6a:	call   rax
    4e6c:	test   rax,rax
    4e6f:	jne    4e7d <botlish_fn_46+0x1c4>
    4e75:	mov    rdi,r13
    4e78:	jmp    4fab <botlish_fn_46+0x2f2>
    4e7d:	mov    QWORD PTR [r12+0x38],rax
    4e82:	mov    QWORD PTR [rsp+0x28],rax
    4e87:	mov    rax,QWORD PTR [rip+0x0]        # 4e8e <botlish_fn_46+0x1d5>
			4e8a: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    4e8e:	mov    rsi,rbx
    4e91:	mov    rdi,r13
    4e94:	call   rax
    4e96:	test   rax,rax
    4e99:	jne    4ea7 <botlish_fn_46+0x1ee>
    4e9f:	mov    rdi,r13
    4ea2:	jmp    4fab <botlish_fn_46+0x2f2>
    4ea7:	mov    QWORD PTR [r12+0x40],rax
    4eac:	mov    r8d,0x1
    4eb2:	mov    QWORD PTR [r12+0x48],0x1
    4ebb:	mov    r9,QWORD PTR [rsp+0x30]
    4ec0:	mov    QWORD PTR [rsp],r9
    4ec4:	mov    r10,QWORD PTR [rsp+0x28]
    4ec9:	mov    QWORD PTR [rsp+0x8],r10
    4ece:	mov    QWORD PTR [rsp+0x10],rax
    4ed3:	mov    QWORD PTR [rsp+0x20],rax
    4ed8:	mov    QWORD PTR [rsp+0x18],rbx
    4edd:	mov    rcx,QWORD PTR [rsp+0x40]
    4ee2:	mov    rdx,QWORD PTR [rsp+0x48]
    4ee7:	mov    rsi,r15
    4eea:	mov    r9,QWORD PTR [rsp+0x38]
    4eef:	mov    rdi,r13
    4ef2:	call   4ef7 <botlish_fn_46+0x23e>
			4ef3: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    4ef7:	test   rax,rax
    4efa:	jne    4f08 <botlish_fn_46+0x24f>
    4f00:	mov    rdi,r13
    4f03:	jmp    4fab <botlish_fn_46+0x2f2>
    4f08:	mov    edx,0x1
    4f0d:	mov    rax,QWORD PTR [rip+0x0]        # 4f14 <botlish_fn_46+0x25b>
			4f10: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    4f14:	mov    rcx,QWORD PTR [rsp+0x30]
    4f19:	mov    rsi,r14
    4f1c:	mov    rdi,r13
    4f1f:	call   rax
    4f21:	test   rax,rax
    4f24:	jne    4f32 <botlish_fn_46+0x279>
    4f2a:	mov    rdi,r13
    4f2d:	jmp    4fab <botlish_fn_46+0x2f2>
    4f32:	mov    edx,0x3
    4f37:	mov    rax,QWORD PTR [rip+0x0]        # 4f3e <botlish_fn_46+0x285>
			4f3a: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    4f3e:	mov    rcx,QWORD PTR [rsp+0x28]
    4f43:	mov    rsi,r14
    4f46:	mov    rdi,r13
    4f49:	call   rax
    4f4b:	test   rax,rax
    4f4e:	jne    4f5c <botlish_fn_46+0x2a3>
    4f54:	mov    rdi,r13
    4f57:	jmp    4fab <botlish_fn_46+0x2f2>
    4f5c:	mov    edx,0x5
    4f61:	mov    rax,QWORD PTR [rip+0x0]        # 4f68 <botlish_fn_46+0x2af>
			4f64: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    4f68:	mov    rcx,QWORD PTR [rsp+0x20]
    4f6d:	mov    rsi,r14
    4f70:	mov    rdi,r13
    4f73:	call   rax
    4f75:	test   rax,rax
    4f78:	jne    4f86 <botlish_fn_46+0x2cd>
    4f7e:	mov    rdi,r13
    4f81:	jmp    4fab <botlish_fn_46+0x2f2>
    4f86:	mov    edx,0x9
    4f8b:	mov    ecx,0x1
    4f90:	mov    rax,QWORD PTR [rip+0x0]        # 4f97 <botlish_fn_46+0x2de>
			4f93: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    4f97:	mov    rsi,r14
    4f9a:	mov    rdi,r13
    4f9d:	call   rax
    4f9f:	test   rax,rax
    4fa2:	jne    4fd9 <botlish_fn_46+0x320>
    4fa8:	mov    rdi,r13
    4fab:	mov    rdi,r13
    4fae:	mov    QWORD PTR [rdi],r12
    4fb1:	xor    rax,rax
    4fb4:	mov    rbx,QWORD PTR [rsp+0x50]
    4fb9:	mov    r12,QWORD PTR [rsp+0x58]
    4fbe:	mov    r13,QWORD PTR [rsp+0x60]
    4fc3:	mov    r14,QWORD PTR [rsp+0x68]
    4fc8:	mov    r15,QWORD PTR [rsp+0x70]
    4fcd:	add    rsp,0x80
    4fd4:	mov    rsp,rbp
    4fd7:	pop    rbp
    4fd8:	ret
    4fd9:	mov    rdi,r13
    4fdc:	mov    QWORD PTR [rdi],r12
    4fdf:	mov    eax,0xa
    4fe4:	mov    rbx,QWORD PTR [rsp+0x50]
    4fe9:	mov    r12,QWORD PTR [rsp+0x58]
    4fee:	mov    r13,QWORD PTR [rsp+0x60]
    4ff3:	mov    r14,QWORD PTR [rsp+0x68]
    4ff8:	mov    r15,QWORD PTR [rsp+0x70]
    4ffd:	add    rsp,0x80
    5004:	mov    rsp,rbp
    5007:	pop    rbp
    5008:	ret
    5009:	mov    r13,rdi
    500c:	mov    rax,QWORD PTR [rip+0x0]        # 5013 <botlish_fn_46+0x35a>
			500f: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    5013:	call   rax
    5015:	xor    rax,rax
    5018:	mov    rbx,QWORD PTR [rsp+0x50]
    501d:	mov    r12,QWORD PTR [rsp+0x58]
    5022:	mov    r13,QWORD PTR [rsp+0x60]
    5027:	mov    r14,QWORD PTR [rsp+0x68]
    502c:	mov    r15,QWORD PTR [rsp+0x70]
    5031:	add    rsp,0x80
    5038:	mov    rsp,rbp
    503b:	pop    rbp
    503c:	ret

000000000000503d <botlish_entry_46: ht_rehash<mutarray, int>>:
    503d:	push   rbp
    503e:	mov    rbp,rsp
    5041:	mov    rsi,QWORD PTR [rdx]
    5044:	mov    rdx,QWORD PTR [rdx+0x8]
    5048:	call   504d <botlish_entry_46+0x10>
			5049: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    504d:	mov    rsp,rbp
    5050:	pop    rbp
    5051:	ret
    5052:	add    BYTE PTR [rax],al
    5054:	add    BYTE PTR [rax],al
	...

0000000000005058 <botlish_fn_47: ht_should_grow<mutarray>>:
    5058:	push   rbp
    5059:	mov    rbp,rsp
    505c:	sub    rsp,0x20
    5060:	mov    QWORD PTR [rsp],rbx
    5064:	mov    QWORD PTR [rsp+0x8],r12
    5069:	mov    QWORD PTR [rsp+0x10],r13
    506e:	mov    QWORD PTR [rsp+0x18],r15
    5073:	mov    r15,QWORD PTR [rdi]
    5076:	mov    rax,QWORD PTR [rdi+0x8]
    507a:	lea    rcx,[r15+0x18]
    507e:	cmp    rcx,rax
    5081:	ja     53ae <botlish_fn_47+0x356>
    5087:	lea    rax,[r15+0x18]
    508b:	mov    QWORD PTR [rdi],rax
    508e:	mov    rbx,rdi
    5091:	mov    QWORD PTR [r15],0x0
    5098:	mov    QWORD PTR [r15+0x8],0x0
    50a0:	mov    QWORD PTR [r15+0x10],0x0
    50a8:	mov    QWORD PTR [r15],rsi
    50ab:	mov    r12,rsi
    50ae:	mov    rsi,r12
    50b1:	mov    rdi,rbx
    50b4:	call   50b9 <botlish_fn_47+0x61>
			50b5: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    50b9:	mov    rcx,rax
    50bc:	mov    r13,rax
    50bf:	test   rax,rcx
    50c2:	jne    50d0 <botlish_fn_47+0x78>
    50c8:	mov    rdi,rbx
    50cb:	jmp    52c0 <botlish_fn_47+0x268>
    50d0:	mov    rax,r13
    50d3:	mov    QWORD PTR [r15+0x8],rax
    50d7:	mov    rsi,r12
    50da:	mov    rdi,rbx
    50dd:	call   50e2 <botlish_fn_47+0x8a>
			50de: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    50e2:	mov    rcx,rax
    50e5:	test   rcx,rcx
    50e8:	jne    50f6 <botlish_fn_47+0x9e>
    50ee:	mov    rdi,rbx
    50f1:	jmp    52c0 <botlish_fn_47+0x268>
    50f6:	mov    QWORD PTR [r15+0x10],rcx
    50fa:	mov    edx,0x1
    50ff:	mov    rax,r13
    5102:	test   rax,0x1
    5108:	jne    512b <botlish_fn_47+0xd3>
    510e:	xor    edx,edx
    5110:	mov    rax,r13
    5113:	test   rax,0x7
    5119:	jne    512b <botlish_fn_47+0xd3>
    511f:	mov    rax,r13
    5122:	movzx  rax,BYTE PTR [rax]
    5126:	cmp    al,0x1
    5128:	sete   dl
    512b:	test   dl,dl
    512d:	jne    5155 <botlish_fn_47+0xfd>
    5133:	mov    rdi,rbx
    5136:	mov    rax,QWORD PTR [rdi+0x10]
    513a:	mov    rcx,QWORD PTR [rax+0x30]
    513e:	xor    rdx,rdx
    5141:	mov    rax,QWORD PTR [rip+0x0]        # 5148 <botlish_fn_47+0xf0>
			5144: R_X86_64_GOTPCREL	rt_type_error-0x4
    5148:	mov    rsi,r13
    514b:	call   rax
    514d:	mov    rdi,rbx
    5150:	jmp    52c0 <botlish_fn_47+0x268>
    5155:	mov    eax,0x1
    515a:	test   rcx,0x1
    5161:	je     516f <botlish_fn_47+0x117>
    5167:	mov    r8,rcx
    516a:	jmp    5192 <botlish_fn_47+0x13a>
    516f:	xor    eax,eax
    5171:	test   rcx,0x7
    5178:	je     5186 <botlish_fn_47+0x12e>
    517e:	mov    r8,rcx
    5181:	jmp    5192 <botlish_fn_47+0x13a>
    5186:	movzx  rax,BYTE PTR [rcx]
    518a:	mov    r8,rcx
    518d:	cmp    al,0x1
    518f:	sete   al
    5192:	test   al,al
    5194:	jne    51bc <botlish_fn_47+0x164>
    519a:	mov    rdi,rbx
    519d:	mov    rax,QWORD PTR [rdi+0x10]
    51a1:	mov    rcx,QWORD PTR [rax+0x30]
    51a5:	xor    rdx,rdx
    51a8:	mov    rax,QWORD PTR [rip+0x0]        # 51af <botlish_fn_47+0x157>
			51ab: R_X86_64_GOTPCREL	rt_type_error-0x4
    51af:	mov    rsi,r8
    51b2:	call   rax
    51b4:	mov    rdi,rbx
    51b7:	jmp    52c0 <botlish_fn_47+0x268>
    51bc:	mov    rcx,r8
    51bf:	mov    rsi,r13
    51c2:	mov    rax,rsi
    51c5:	and    rax,rcx
    51c8:	test   rax,0x1
    51ce:	je     51ec <botlish_fn_47+0x194>
    51d4:	mov    rcx,r8
    51d7:	lea    rax,[rcx-0x1]
    51db:	mov    rsi,r13
    51de:	add    rsi,rax
    51e1:	seto   al
    51e4:	test   al,al
    51e6:	je     5201 <botlish_fn_47+0x1a9>
    51ec:	mov    rax,QWORD PTR [rip+0x0]        # 51f3 <botlish_fn_47+0x19b>
			51ef: R_X86_64_GOTPCREL	rt_int_add-0x4
    51f3:	mov    rdx,r8
    51f6:	mov    rsi,r13
    51f9:	mov    rdi,rbx
    51fc:	call   rax
    51fe:	mov    rsi,rax
    5201:	mov    QWORD PTR [r15+0x8],rsi
    5205:	mov    QWORD PTR [r15+0x10],0x3
    520d:	test   rsi,0x1
    5214:	je     5236 <botlish_fn_47+0x1de>
    521a:	mov    rax,rsi
    521d:	add    rax,0x2
    5221:	seto   dil
    5225:	test   dil,dil
    5228:	jne    5236 <botlish_fn_47+0x1de>
    522e:	mov    rsi,rax
    5231:	jmp    524b <botlish_fn_47+0x1f3>
    5236:	mov    edx,0x3
    523b:	mov    r8,QWORD PTR [rip+0x0]        # 5242 <botlish_fn_47+0x1ea>
			523e: R_X86_64_GOTPCREL	rt_int_add-0x4
    5242:	mov    rdi,rbx
    5245:	call   r8
    5248:	mov    rsi,rax
    524b:	mov    QWORD PTR [r15+0x8],rsi
    524f:	mov    edx,0x7
    5254:	mov    rdi,rdx
    5257:	mov    QWORD PTR [r15+0x10],0x7
    525f:	test   rsi,0x1
    5266:	je     5290 <botlish_fn_47+0x238>
    526c:	mov    rax,rsi
    526f:	sar    rax,1
    5272:	imul   QWORD PTR [rip+0x167]        # 53e0 <botlish_fn_47+0x388>
    5279:	seto   cl
    527c:	or     rax,0x1
    5280:	test   cl,cl
    5282:	jne    5290 <botlish_fn_47+0x238>
    5288:	mov    rsi,rax
    528b:	jmp    52a2 <botlish_fn_47+0x24a>
    5290:	mov    rax,QWORD PTR [rip+0x0]        # 5297 <botlish_fn_47+0x23f>
			5293: R_X86_64_GOTPCREL	rt_int_mul-0x4
    5297:	mov    rdx,rdi
    529a:	mov    rdi,rbx
    529d:	call   rax
    529f:	mov    rsi,rax
    52a2:	mov    QWORD PTR [r15+0x8],rsi
    52a6:	mov    r13,rsi
    52a9:	mov    rsi,r12
    52ac:	mov    rdi,rbx
    52af:	call   52b4 <botlish_fn_47+0x25c>
			52b0: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    52b4:	test   rax,rax
    52b7:	jne    52e5 <botlish_fn_47+0x28d>
    52bd:	mov    rdi,rbx
    52c0:	mov    rdi,rbx
    52c3:	mov    QWORD PTR [rdi],r15
    52c6:	xor    rax,rax
    52c9:	mov    rbx,QWORD PTR [rsp]
    52cd:	mov    r12,QWORD PTR [rsp+0x8]
    52d2:	mov    r13,QWORD PTR [rsp+0x10]
    52d7:	mov    r15,QWORD PTR [rsp+0x18]
    52dc:	add    rsp,0x20
    52e0:	mov    rsp,rbp
    52e3:	pop    rbp
    52e4:	ret
    52e5:	mov    QWORD PTR [r15],rax
    52e8:	mov    QWORD PTR [r15+0x10],0x5
    52f0:	test   rax,0x1
    52f6:	mov    rsi,rax
    52f9:	je     5329 <botlish_fn_47+0x2d1>
    52ff:	mov    rcx,rsi
    5302:	mov    rax,rcx
    5305:	sar    rax,1
    5308:	imul   QWORD PTR [rip+0xd9]        # 53e8 <botlish_fn_47+0x390>
    530f:	seto   cl
    5312:	or     rax,0x1
    5316:	test   cl,cl
    5318:	jne    5329 <botlish_fn_47+0x2d1>
    531e:	mov    rdx,rax
    5321:	mov    rsi,r13
    5324:	jmp    5340 <botlish_fn_47+0x2e8>
    5329:	mov    edx,0x5
    532e:	mov    rax,QWORD PTR [rip+0x0]        # 5335 <botlish_fn_47+0x2dd>
			5331: R_X86_64_GOTPCREL	rt_int_mul-0x4
    5335:	mov    rdi,rbx
    5338:	call   rax
    533a:	mov    rdx,rax
    533d:	mov    rsi,r13
    5340:	mov    rax,rsi
    5343:	and    rax,rdx
    5346:	test   rax,0x1
    534c:	jne    5379 <botlish_fn_47+0x321>
    5352:	mov    rax,QWORD PTR [rip+0x0]        # 5359 <botlish_fn_47+0x301>
			5355: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    5359:	mov    rdi,rbx
    535c:	call   rax
    535e:	mov    ecx,0x2
    5363:	test   rax,rax
    5366:	mov    rax,rcx
    5369:	cmovg  rax,QWORD PTR [rip+0x6f]        # 53e0 <botlish_fn_47+0x388>
    5371:	mov    rdi,rbx
    5374:	jmp    538c <botlish_fn_47+0x334>
    5379:	mov    eax,0x2
    537e:	cmp    rsi,rdx
    5381:	cmovg  rax,QWORD PTR [rip+0x57]        # 53e0 <botlish_fn_47+0x388>
    5389:	mov    rdi,rbx
    538c:	mov    rdi,rbx
    538f:	mov    QWORD PTR [rdi],r15
    5392:	mov    rbx,QWORD PTR [rsp]
    5396:	mov    r12,QWORD PTR [rsp+0x8]
    539b:	mov    r13,QWORD PTR [rsp+0x10]
    53a0:	mov    r15,QWORD PTR [rsp+0x18]
    53a5:	add    rsp,0x20
    53a9:	mov    rsp,rbp
    53ac:	pop    rbp
    53ad:	ret
    53ae:	mov    rbx,rdi
    53b1:	mov    rax,QWORD PTR [rip+0x0]        # 53b8 <botlish_fn_47+0x360>
			53b4: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    53b8:	call   rax
    53ba:	xor    rax,rax
    53bd:	mov    rbx,QWORD PTR [rsp]
    53c1:	mov    r12,QWORD PTR [rsp+0x8]
    53c6:	mov    r13,QWORD PTR [rsp+0x10]
    53cb:	mov    r15,QWORD PTR [rsp+0x18]
    53d0:	add    rsp,0x20
    53d4:	mov    rsp,rbp
    53d7:	pop    rbp
    53d8:	ret
    53d9:	add    BYTE PTR [rax],al
    53db:	add    BYTE PTR [rax],al
    53dd:	add    BYTE PTR [rax],al
    53df:	add    BYTE PTR [rsi],al
    53e1:	add    BYTE PTR [rax],al
    53e3:	add    BYTE PTR [rax],al
    53e5:	add    BYTE PTR [rax],al
    53e7:	add    BYTE PTR [rax+rax*1],al
    53ea:	add    BYTE PTR [rax],al
    53ec:	add    BYTE PTR [rax],al
	...

00000000000053f0 <botlish_entry_47: ht_should_grow<mutarray>>:
    53f0:	push   rbp
    53f1:	mov    rbp,rsp
    53f4:	mov    rsi,QWORD PTR [rdx]
    53f7:	call   53fc <botlish_entry_47+0xc>
			53f8: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    53fc:	mov    rsp,rbp
    53ff:	pop    rbp
    5400:	ret
    5401:	add    BYTE PTR [rax],al
    5403:	add    BYTE PTR [rax],al
    5405:	add    BYTE PTR [rax],al
	...

0000000000005408 <botlish_fn_48: ht_grow_or_clean<mutarray>>:
    5408:	push   rbp
    5409:	mov    rbp,rsp
    540c:	sub    rsp,0x20
    5410:	mov    QWORD PTR [rsp],rbx
    5414:	mov    QWORD PTR [rsp+0x8],r12
    5419:	mov    QWORD PTR [rsp+0x10],r13
    541e:	mov    QWORD PTR [rsp+0x18],r14
    5423:	mov    rbx,QWORD PTR [rdi]
    5426:	mov    rax,QWORD PTR [rdi+0x8]
    542a:	lea    rcx,[rbx+0x18]
    542e:	cmp    rcx,rax
    5431:	ja     56e8 <botlish_fn_48+0x2e0>
    5437:	lea    rax,[rbx+0x18]
    543b:	mov    QWORD PTR [rdi],rax
    543e:	mov    r12,rdi
    5441:	mov    QWORD PTR [rbx],0x0
    5448:	mov    QWORD PTR [rbx+0x8],0x0
    5450:	mov    QWORD PTR [rbx+0x10],0x0
    5458:	mov    QWORD PTR [rbx],rsi
    545b:	mov    r13,rsi
    545e:	mov    rsi,r13
    5461:	mov    rdi,r12
    5464:	call   5469 <botlish_fn_48+0x61>
			5465: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    5469:	test   rax,rax
    546c:	jne    547a <botlish_fn_48+0x72>
    5472:	mov    rdi,r12
    5475:	jmp    569e <botlish_fn_48+0x296>
    547a:	mov    QWORD PTR [rbx+0x8],rax
    547e:	mov    r14,rax
    5481:	mov    rsi,r13
    5484:	mov    rdi,r12
    5487:	call   548c <botlish_fn_48+0x84>
			5488: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    548c:	mov    rcx,rax
    548f:	test   rcx,rcx
    5492:	jne    54a0 <botlish_fn_48+0x98>
    5498:	mov    rdi,r12
    549b:	jmp    569e <botlish_fn_48+0x296>
    54a0:	mov    edx,0x1
    54a5:	mov    rax,r14
    54a8:	test   rax,0x1
    54ae:	je     54bc <botlish_fn_48+0xb4>
    54b4:	mov    r14,rax
    54b7:	jmp    54e0 <botlish_fn_48+0xd8>
    54bc:	xor    edx,edx
    54be:	test   rax,0x7
    54c4:	je     54d2 <botlish_fn_48+0xca>
    54ca:	mov    r14,rax
    54cd:	jmp    54e0 <botlish_fn_48+0xd8>
    54d2:	movzx  rdx,BYTE PTR [rax]
    54d6:	mov    r14,rax
    54d9:	rex cmp dl,0x1
    54dd:	sete   dl
    54e0:	test   dl,dl
    54e2:	jne    550a <botlish_fn_48+0x102>
    54e8:	mov    rdi,r12
    54eb:	mov    rax,QWORD PTR [rdi+0x10]
    54ef:	mov    rcx,QWORD PTR [rax+0x38]
    54f3:	xor    rdx,rdx
    54f6:	mov    rax,QWORD PTR [rip+0x0]        # 54fd <botlish_fn_48+0xf5>
			54f9: R_X86_64_GOTPCREL	rt_type_error-0x4
    54fd:	mov    rsi,r14
    5500:	call   rax
    5502:	mov    rdi,r12
    5505:	jmp    569e <botlish_fn_48+0x296>
    550a:	mov    rsi,r14
    550d:	mov    eax,0x1
    5512:	test   rcx,0x1
    5519:	je     5527 <botlish_fn_48+0x11f>
    551f:	mov    r8,rcx
    5522:	jmp    554a <botlish_fn_48+0x142>
    5527:	xor    eax,eax
    5529:	test   rcx,0x7
    5530:	je     553e <botlish_fn_48+0x136>
    5536:	mov    r8,rcx
    5539:	jmp    554a <botlish_fn_48+0x142>
    553e:	movzx  rax,BYTE PTR [rcx]
    5542:	mov    r8,rcx
    5545:	cmp    al,0x1
    5547:	sete   al
    554a:	test   al,al
    554c:	jne    5574 <botlish_fn_48+0x16c>
    5552:	mov    rdi,r12
    5555:	mov    rax,QWORD PTR [rdi+0x10]
    5559:	mov    rcx,QWORD PTR [rax+0x38]
    555d:	xor    rdx,rdx
    5560:	mov    rax,QWORD PTR [rip+0x0]        # 5567 <botlish_fn_48+0x15f>
			5563: R_X86_64_GOTPCREL	rt_type_error-0x4
    5567:	mov    rsi,r8
    556a:	call   rax
    556c:	mov    rdi,r12
    556f:	jmp    569e <botlish_fn_48+0x296>
    5574:	mov    rcx,r8
    5577:	mov    rax,rsi
    557a:	and    rax,rcx
    557d:	test   rax,0x1
    5583:	jne    55ad <botlish_fn_48+0x1a5>
    5589:	mov    rax,QWORD PTR [rip+0x0]        # 5590 <botlish_fn_48+0x188>
			558c: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    5590:	mov    rdx,r8
    5593:	mov    rdi,r12
    5596:	call   rax
    5598:	mov    ecx,0x2
    559d:	test   rax,rax
    55a0:	cmovg  rcx,QWORD PTR [rip+0x170]        # 5718 <botlish_fn_48+0x310>
    55a8:	jmp    55c0 <botlish_fn_48+0x1b8>
    55ad:	mov    ecx,0x2
    55b2:	mov    rax,r8
    55b5:	cmp    rsi,rax
    55b8:	cmovg  rcx,QWORD PTR [rip+0x158]        # 5718 <botlish_fn_48+0x310>
    55c0:	cmp    rcx,0x6
    55c4:	je     5664 <botlish_fn_48+0x25c>
    55ca:	mov    rsi,r13
    55cd:	mov    rdi,r12
    55d0:	call   55d5 <botlish_fn_48+0x1cd>
			55d1: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    55d5:	test   rax,rax
    55d8:	jne    55e6 <botlish_fn_48+0x1de>
    55de:	mov    rdi,r12
    55e1:	jmp    569e <botlish_fn_48+0x296>
    55e6:	mov    QWORD PTR [rbx+0x8],rax
    55ea:	mov    QWORD PTR [rbx+0x10],0x5
    55f2:	test   rax,0x1
    55f8:	mov    rsi,rax
    55fb:	je     5628 <botlish_fn_48+0x220>
    5601:	mov    rcx,rsi
    5604:	mov    rax,rcx
    5607:	sar    rax,1
    560a:	imul   QWORD PTR [rip+0x10f]        # 5720 <botlish_fn_48+0x318>
    5611:	seto   cl
    5614:	or     rax,0x1
    5618:	test   cl,cl
    561a:	jne    5628 <botlish_fn_48+0x220>
    5620:	mov    rdx,rax
    5623:	jmp    563c <botlish_fn_48+0x234>
    5628:	mov    edx,0x5
    562d:	mov    rax,QWORD PTR [rip+0x0]        # 5634 <botlish_fn_48+0x22c>
			5630: R_X86_64_GOTPCREL	rt_int_mul-0x4
    5634:	mov    rdi,r12
    5637:	call   rax
    5639:	mov    rdx,rax
    563c:	mov    QWORD PTR [rbx+0x8],rdx
    5640:	mov    rsi,r13
    5643:	mov    rdi,r12
    5646:	call   564b <botlish_fn_48+0x243>
			5647: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    564b:	test   rax,rax
    564e:	jne    565c <botlish_fn_48+0x254>
    5654:	mov    rdi,r12
    5657:	jmp    569e <botlish_fn_48+0x296>
    565c:	mov    rdi,r12
    565f:	jmp    56c6 <botlish_fn_48+0x2be>
    5664:	mov    rsi,r13
    5667:	mov    rdi,r12
    566a:	call   566f <botlish_fn_48+0x267>
			566b: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    566f:	test   rax,rax
    5672:	jne    5680 <botlish_fn_48+0x278>
    5678:	mov    rdi,r12
    567b:	jmp    569e <botlish_fn_48+0x296>
    5680:	mov    QWORD PTR [rbx+0x8],rax
    5684:	mov    rdx,rax
    5687:	mov    rsi,r13
    568a:	mov    rdi,r12
    568d:	call   5692 <botlish_fn_48+0x28a>
			568e: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    5692:	test   rax,rax
    5695:	jne    56c3 <botlish_fn_48+0x2bb>
    569b:	mov    rdi,r12
    569e:	mov    rdi,r12
    56a1:	mov    QWORD PTR [rdi],rbx
    56a4:	xor    rax,rax
    56a7:	mov    rbx,QWORD PTR [rsp]
    56ab:	mov    r12,QWORD PTR [rsp+0x8]
    56b0:	mov    r13,QWORD PTR [rsp+0x10]
    56b5:	mov    r14,QWORD PTR [rsp+0x18]
    56ba:	add    rsp,0x20
    56be:	mov    rsp,rbp
    56c1:	pop    rbp
    56c2:	ret
    56c3:	mov    rdi,r12
    56c6:	mov    rdi,r12
    56c9:	mov    QWORD PTR [rdi],rbx
    56cc:	mov    rbx,QWORD PTR [rsp]
    56d0:	mov    r12,QWORD PTR [rsp+0x8]
    56d5:	mov    r13,QWORD PTR [rsp+0x10]
    56da:	mov    r14,QWORD PTR [rsp+0x18]
    56df:	add    rsp,0x20
    56e3:	mov    rsp,rbp
    56e6:	pop    rbp
    56e7:	ret
    56e8:	mov    r12,rdi
    56eb:	mov    r8,QWORD PTR [rip+0x0]        # 56f2 <botlish_fn_48+0x2ea>
			56ee: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    56f2:	call   r8
    56f5:	xor    rax,rax
    56f8:	mov    rbx,QWORD PTR [rsp]
    56fc:	mov    r12,QWORD PTR [rsp+0x8]
    5701:	mov    r13,QWORD PTR [rsp+0x10]
    5706:	mov    r14,QWORD PTR [rsp+0x18]
    570b:	add    rsp,0x20
    570f:	mov    rsp,rbp
    5712:	pop    rbp
    5713:	ret
    5714:	add    BYTE PTR [rax],al
    5716:	add    BYTE PTR [rax],al
    5718:	(bad)
    5719:	add    BYTE PTR [rax],al
    571b:	add    BYTE PTR [rax],al
    571d:	add    BYTE PTR [rax],al
    571f:	add    BYTE PTR [rax+rax*1],al
    5722:	add    BYTE PTR [rax],al
    5724:	add    BYTE PTR [rax],al
	...

0000000000005728 <botlish_entry_48: ht_grow_or_clean<mutarray>>:
    5728:	push   rbp
    5729:	mov    rbp,rsp
    572c:	mov    rsi,QWORD PTR [rdx]
    572f:	call   5734 <botlish_entry_48+0xc>
			5730: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    5734:	mov    rsp,rbp
    5737:	pop    rbp
    5738:	ret
    5739:	add    BYTE PTR [rax],al
    573b:	add    BYTE PTR [rax],al
    573d:	add    BYTE PTR [rax],al
	...

0000000000005740 <botlish_fn_49: ht_place<mutarray, int, any, any>>:
    5740:	push   rbp
    5741:	mov    rbp,rsp
    5744:	sub    rsp,0x50
    5748:	mov    QWORD PTR [rsp+0x20],rbx
    574d:	mov    QWORD PTR [rsp+0x28],r12
    5752:	mov    QWORD PTR [rsp+0x30],r13
    5757:	mov    QWORD PTR [rsp+0x38],r14
    575c:	mov    QWORD PTR [rsp+0x40],r15
    5761:	mov    r12,QWORD PTR [rdi]
    5764:	mov    rax,QWORD PTR [rdi+0x8]
    5768:	lea    r9,[r12+0x30]
    576d:	cmp    r9,rax
    5770:	ja     5cb0 <botlish_fn_49+0x570>
    5776:	lea    rax,[r12+0x30]
    577b:	mov    QWORD PTR [rdi],rax
    577e:	mov    r13,rdi
    5781:	mov    QWORD PTR [r12],0x0
    5789:	mov    QWORD PTR [r12+0x8],0x0
    5792:	mov    QWORD PTR [r12+0x10],0x0
    579b:	mov    QWORD PTR [r12+0x18],0x0
    57a4:	mov    QWORD PTR [r12+0x20],0x0
    57ad:	mov    QWORD PTR [r12+0x28],0x0
    57b6:	mov    QWORD PTR [r12],rsi
    57ba:	mov    r14,rsi
    57bd:	mov    QWORD PTR [r12+0x8],rdx
    57c2:	mov    QWORD PTR [rsp],rdx
    57c6:	mov    QWORD PTR [r12+0x10],rcx
    57cb:	mov    QWORD PTR [rsp+0x8],rcx
    57d0:	mov    QWORD PTR [r12+0x18],r8
    57d5:	mov    r15,r8
    57d8:	mov    rsi,r14
    57db:	mov    rdi,r13
    57de:	call   57e3 <botlish_fn_49+0xa3>
			57df: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    57e3:	test   rax,rax
    57e6:	jne    57f4 <botlish_fn_49+0xb4>
    57ec:	mov    rdi,r13
    57ef:	jmp    5c55 <botlish_fn_49+0x515>
    57f4:	mov    QWORD PTR [r12+0x20],rax
    57f9:	xor    ecx,ecx
    57fb:	test   rax,0x7
    5801:	je     5811 <botlish_fn_49+0xd1>
    5807:	mov    QWORD PTR [rsp+0x10],rax
    580c:	jmp    5821 <botlish_fn_49+0xe1>
    5811:	movzx  rsi,BYTE PTR [rax]
    5815:	mov    QWORD PTR [rsp+0x10],rax
    581a:	cmp    sil,0x8
    581e:	sete   cl
    5821:	test   cl,cl
    5823:	jne    5850 <botlish_fn_49+0x110>
    5829:	mov    rdi,r13
    582c:	mov    r9,QWORD PTR [rdi+0x10]
    5830:	mov    rcx,QWORD PTR [r9+0x20]
    5834:	mov    edx,0x8
    5839:	mov    r9,QWORD PTR [rip+0x0]        # 5840 <botlish_fn_49+0x100>
			583c: R_X86_64_GOTPCREL	rt_type_error-0x4
    5840:	mov    rsi,QWORD PTR [rsp+0x10]
    5845:	call   r9
    5848:	mov    rdi,r13
    584b:	jmp    5c55 <botlish_fn_49+0x515>
    5850:	mov    r10,QWORD PTR [rip+0x0]        # 5857 <botlish_fn_49+0x117>
			5853: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    5857:	mov    rdx,QWORD PTR [rsp]
    585b:	mov    rsi,QWORD PTR [rsp+0x10]
    5860:	mov    rdi,r13
    5863:	call   r10
    5866:	mov    rbx,rax
    5869:	test   rbx,rbx
    586c:	jne    587a <botlish_fn_49+0x13a>
    5872:	mov    rdi,r13
    5875:	jmp    5c55 <botlish_fn_49+0x515>
    587a:	mov    QWORD PTR [r12+0x28],rbx
    587f:	mov    rdi,r13
    5882:	call   5887 <botlish_fn_49+0x147>
			5883: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    5887:	test   rax,rax
    588a:	mov    rcx,rax
    588d:	jne    589b <botlish_fn_49+0x15b>
    5893:	mov    rdi,r13
    5896:	jmp    5c55 <botlish_fn_49+0x515>
    589b:	mov    rax,QWORD PTR [rip+0x0]        # 58a2 <botlish_fn_49+0x162>
			589e: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    58a2:	mov    rsi,QWORD PTR [rsp+0x10]
    58a7:	mov    rdx,QWORD PTR [rsp]
    58ab:	mov    rdi,r13
    58ae:	call   rax
    58b0:	test   rax,rax
    58b3:	jne    58c1 <botlish_fn_49+0x181>
    58b9:	mov    rdi,r13
    58bc:	jmp    5c55 <botlish_fn_49+0x515>
    58c1:	mov    rsi,r14
    58c4:	mov    rdi,r13
    58c7:	call   58cc <botlish_fn_49+0x18c>
			58c8: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    58cc:	test   rax,rax
    58cf:	jne    58dd <botlish_fn_49+0x19d>
    58d5:	mov    rdi,r13
    58d8:	jmp    5c55 <botlish_fn_49+0x515>
    58dd:	xor    esi,esi
    58df:	test   rax,0x7
    58e5:	je     58f3 <botlish_fn_49+0x1b3>
    58eb:	mov    r8,rax
    58ee:	jmp    5902 <botlish_fn_49+0x1c2>
    58f3:	movzx  rcx,BYTE PTR [rax]
    58f7:	mov    r8,rax
    58fa:	rex cmp cl,0x8
    58fe:	sete   sil
    5902:	test   sil,sil
    5905:	jne    592f <botlish_fn_49+0x1ef>
    590b:	mov    rdi,r13
    590e:	mov    rax,QWORD PTR [rdi+0x10]
    5912:	mov    rcx,QWORD PTR [rax+0x40]
    5916:	mov    edx,0x8
    591b:	mov    rax,QWORD PTR [rip+0x0]        # 5922 <botlish_fn_49+0x1e2>
			591e: R_X86_64_GOTPCREL	rt_type_error-0x4
    5922:	mov    rsi,r8
    5925:	call   rax
    5927:	mov    rdi,r13
    592a:	jmp    5c55 <botlish_fn_49+0x515>
    592f:	mov    rsi,r8
    5932:	mov    rax,QWORD PTR [rip+0x0]        # 5939 <botlish_fn_49+0x1f9>
			5935: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    5939:	mov    rcx,QWORD PTR [rsp+0x8]
    593e:	mov    rdx,QWORD PTR [rsp]
    5942:	mov    rdi,r13
    5945:	call   rax
    5947:	test   rax,rax
    594a:	jne    5958 <botlish_fn_49+0x218>
    5950:	mov    rdi,r13
    5953:	jmp    5c55 <botlish_fn_49+0x515>
    5958:	mov    rsi,r14
    595b:	mov    rdi,r13
    595e:	call   5963 <botlish_fn_49+0x223>
			595f: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    5963:	test   rax,rax
    5966:	jne    5974 <botlish_fn_49+0x234>
    596c:	mov    rdi,r13
    596f:	jmp    5c55 <botlish_fn_49+0x515>
    5974:	xor    ecx,ecx
    5976:	test   rax,0x7
    597c:	je     598a <botlish_fn_49+0x24a>
    5982:	mov    rsi,rax
    5985:	jmp    5998 <botlish_fn_49+0x258>
    598a:	movzx  rcx,BYTE PTR [rax]
    598e:	mov    rsi,rax
    5991:	rex cmp cl,0x8
    5995:	sete   cl
    5998:	test   cl,cl
    599a:	jne    59c1 <botlish_fn_49+0x281>
    59a0:	mov    rdi,r13
    59a3:	mov    rax,QWORD PTR [rdi+0x10]
    59a7:	mov    rcx,QWORD PTR [rax+0x40]
    59ab:	mov    edx,0x8
    59b0:	mov    rax,QWORD PTR [rip+0x0]        # 59b7 <botlish_fn_49+0x277>
			59b3: R_X86_64_GOTPCREL	rt_type_error-0x4
    59b7:	call   rax
    59b9:	mov    rdi,r13
    59bc:	jmp    5c55 <botlish_fn_49+0x515>
    59c1:	mov    rax,QWORD PTR [rip+0x0]        # 59c8 <botlish_fn_49+0x288>
			59c4: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    59c8:	mov    rcx,r15
    59cb:	mov    rdx,QWORD PTR [rsp]
    59cf:	mov    rdi,r13
    59d2:	call   rax
    59d4:	test   rax,rax
    59d7:	jne    59e5 <botlish_fn_49+0x2a5>
    59dd:	mov    rdi,r13
    59e0:	jmp    5c55 <botlish_fn_49+0x515>
    59e5:	mov    QWORD PTR [r12+0x8],0x7
    59ee:	mov    rsi,r14
    59f1:	mov    rdi,r13
    59f4:	call   59f9 <botlish_fn_49+0x2b9>
			59f5: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    59f9:	test   rax,rax
    59fc:	jne    5a0a <botlish_fn_49+0x2ca>
    5a02:	mov    rdi,r13
    5a05:	jmp    5c55 <botlish_fn_49+0x515>
    5a0a:	mov    QWORD PTR [r12+0x10],rax
    5a0f:	mov    QWORD PTR [r12+0x18],0x3
    5a18:	mov    ecx,0x1
    5a1d:	test   rax,0x1
    5a23:	je     5a31 <botlish_fn_49+0x2f1>
    5a29:	mov    rsi,rax
    5a2c:	jmp    5a55 <botlish_fn_49+0x315>
    5a31:	xor    ecx,ecx
    5a33:	test   rax,0x7
    5a39:	je     5a47 <botlish_fn_49+0x307>
    5a3f:	mov    rsi,rax
    5a42:	jmp    5a55 <botlish_fn_49+0x315>
    5a47:	movzx  rcx,BYTE PTR [rax]
    5a4b:	mov    rsi,rax
    5a4e:	rex cmp cl,0x1
    5a52:	sete   cl
    5a55:	test   cl,cl
    5a57:	jne    5a7d <botlish_fn_49+0x33d>
    5a5d:	mov    rdi,r13
    5a60:	mov    rcx,QWORD PTR [rdi+0x10]
    5a64:	mov    rcx,QWORD PTR [rcx+0x30]
    5a68:	xor    rdx,rdx
    5a6b:	mov    r8,QWORD PTR [rip+0x0]        # 5a72 <botlish_fn_49+0x332>
			5a6e: R_X86_64_GOTPCREL	rt_type_error-0x4
    5a72:	call   r8
    5a75:	mov    rdi,r13
    5a78:	jmp    5c55 <botlish_fn_49+0x515>
    5a7d:	test   rsi,0x1
    5a84:	je     5a9e <botlish_fn_49+0x35e>
    5a8a:	mov    rcx,rsi
    5a8d:	add    rcx,0x2
    5a91:	seto   dil
    5a95:	test   dil,dil
    5a98:	je     5ab3 <botlish_fn_49+0x373>
    5a9e:	mov    edx,0x3
    5aa3:	mov    r9,QWORD PTR [rip+0x0]        # 5aaa <botlish_fn_49+0x36a>
			5aa6: R_X86_64_GOTPCREL	rt_int_add-0x4
    5aaa:	mov    rdi,r13
    5aad:	call   r9
    5ab0:	mov    rcx,rax
    5ab3:	mov    edx,0x7
    5ab8:	mov    r10,QWORD PTR [rip+0x0]        # 5abf <botlish_fn_49+0x37f>
			5abb: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    5abf:	mov    rsi,r14
    5ac2:	mov    rdi,r13
    5ac5:	call   r10
    5ac8:	test   rax,rax
    5acb:	jne    5ad9 <botlish_fn_49+0x399>
    5ad1:	mov    rdi,r13
    5ad4:	jmp    5c55 <botlish_fn_49+0x515>
    5ad9:	mov    rdi,r13
    5adc:	call   5ae1 <botlish_fn_49+0x3a1>
			5add: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    5ae1:	test   rax,rax
    5ae4:	jne    5af2 <botlish_fn_49+0x3b2>
    5aea:	mov    rdi,r13
    5aed:	jmp    5c55 <botlish_fn_49+0x515>
    5af2:	mov    rcx,rbx
    5af5:	and    rcx,rax
    5af8:	mov    rdx,rbx
    5afb:	mov    rsi,rax
    5afe:	test   rcx,0x1
    5b05:	jne    5b31 <botlish_fn_49+0x3f1>
    5b0b:	mov    rax,QWORD PTR [rip+0x0]        # 5b12 <botlish_fn_49+0x3d2>
			5b0e: R_X86_64_GOTPCREL	rt_value_eq-0x4
    5b12:	mov    rcx,rdx
    5b15:	mov    rdx,rsi
    5b18:	mov    rsi,rcx
    5b1b:	mov    rdi,r13
    5b1e:	call   rax
    5b20:	test   rax,rax
    5b23:	jne    5b4a <botlish_fn_49+0x40a>
    5b29:	mov    rdi,r13
    5b2c:	jmp    5c55 <botlish_fn_49+0x515>
    5b31:	mov    rax,rdx
    5b34:	mov    rdx,rsi
    5b37:	mov    rsi,rax
    5b3a:	mov    eax,0x2
    5b3f:	cmp    rsi,rdx
    5b42:	cmove  rax,QWORD PTR [rip+0x19e]        # 5ce8 <botlish_fn_49+0x5a8>
    5b4a:	cmp    rax,0x6
    5b4e:	je     5b5c <botlish_fn_49+0x41c>
    5b54:	mov    rdi,r13
    5b57:	jmp    5c83 <botlish_fn_49+0x543>
    5b5c:	mov    QWORD PTR [r12+0x8],0x9
    5b65:	mov    rsi,r14
    5b68:	mov    rdi,r13
    5b6b:	call   5b70 <botlish_fn_49+0x430>
			5b6c: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    5b70:	test   rax,rax
    5b73:	jne    5b81 <botlish_fn_49+0x441>
    5b79:	mov    rdi,r13
    5b7c:	jmp    5c55 <botlish_fn_49+0x515>
    5b81:	mov    QWORD PTR [r12+0x10],rax
    5b86:	mov    QWORD PTR [r12+0x18],0x3
    5b8f:	mov    esi,0x1
    5b94:	test   rax,0x1
    5b9a:	je     5ba8 <botlish_fn_49+0x468>
    5ba0:	mov    r11,rax
    5ba3:	jmp    5bcd <botlish_fn_49+0x48d>
    5ba8:	xor    esi,esi
    5baa:	test   rax,0x7
    5bb0:	je     5bbe <botlish_fn_49+0x47e>
    5bb6:	mov    r11,rax
    5bb9:	jmp    5bcd <botlish_fn_49+0x48d>
    5bbe:	movzx  rcx,BYTE PTR [rax]
    5bc2:	mov    r11,rax
    5bc5:	rex cmp cl,0x1
    5bc9:	sete   sil
    5bcd:	test   sil,sil
    5bd0:	jne    5bf8 <botlish_fn_49+0x4b8>
    5bd6:	mov    rdi,r13
    5bd9:	mov    rax,QWORD PTR [rdi+0x10]
    5bdd:	mov    rcx,QWORD PTR [rax+0x48]
    5be1:	xor    rdx,rdx
    5be4:	mov    rax,QWORD PTR [rip+0x0]        # 5beb <botlish_fn_49+0x4ab>
			5be7: R_X86_64_GOTPCREL	rt_type_error-0x4
    5beb:	mov    rsi,r11
    5bee:	call   rax
    5bf0:	mov    rdi,r13
    5bf3:	jmp    5c55 <botlish_fn_49+0x515>
    5bf8:	mov    rsi,r11
    5bfb:	test   rsi,0x1
    5c02:	je     5c21 <botlish_fn_49+0x4e1>
    5c08:	mov    rcx,rsi
    5c0b:	sub    rcx,0x3
    5c0f:	seto   al
    5c12:	add    rcx,0x1
    5c19:	test   al,al
    5c1b:	je     5c35 <botlish_fn_49+0x4f5>
    5c21:	mov    edx,0x3
    5c26:	mov    rax,QWORD PTR [rip+0x0]        # 5c2d <botlish_fn_49+0x4ed>
			5c29: R_X86_64_GOTPCREL	rt_int_sub-0x4
    5c2d:	mov    rdi,r13
    5c30:	call   rax
    5c32:	mov    rcx,rax
    5c35:	mov    edx,0x9
    5c3a:	mov    rax,QWORD PTR [rip+0x0]        # 5c41 <botlish_fn_49+0x501>
			5c3d: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    5c41:	mov    rsi,r14
    5c44:	mov    rdi,r13
    5c47:	call   rax
    5c49:	test   rax,rax
    5c4c:	jne    5c80 <botlish_fn_49+0x540>
    5c52:	mov    rdi,r13
    5c55:	mov    rdi,r13
    5c58:	mov    QWORD PTR [rdi],r12
    5c5b:	xor    rax,rax
    5c5e:	mov    rbx,QWORD PTR [rsp+0x20]
    5c63:	mov    r12,QWORD PTR [rsp+0x28]
    5c68:	mov    r13,QWORD PTR [rsp+0x30]
    5c6d:	mov    r14,QWORD PTR [rsp+0x38]
    5c72:	mov    r15,QWORD PTR [rsp+0x40]
    5c77:	add    rsp,0x50
    5c7b:	mov    rsp,rbp
    5c7e:	pop    rbp
    5c7f:	ret
    5c80:	mov    rdi,r13
    5c83:	mov    rdi,r13
    5c86:	mov    QWORD PTR [rdi],r12
    5c89:	mov    eax,0xa
    5c8e:	mov    rbx,QWORD PTR [rsp+0x20]
    5c93:	mov    r12,QWORD PTR [rsp+0x28]
    5c98:	mov    r13,QWORD PTR [rsp+0x30]
    5c9d:	mov    r14,QWORD PTR [rsp+0x38]
    5ca2:	mov    r15,QWORD PTR [rsp+0x40]
    5ca7:	add    rsp,0x50
    5cab:	mov    rsp,rbp
    5cae:	pop    rbp
    5caf:	ret
    5cb0:	mov    r13,rdi
    5cb3:	mov    rax,QWORD PTR [rip+0x0]        # 5cba <botlish_fn_49+0x57a>
			5cb6: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    5cba:	call   rax
    5cbc:	xor    rax,rax
    5cbf:	mov    rbx,QWORD PTR [rsp+0x20]
    5cc4:	mov    r12,QWORD PTR [rsp+0x28]
    5cc9:	mov    r13,QWORD PTR [rsp+0x30]
    5cce:	mov    r14,QWORD PTR [rsp+0x38]
    5cd3:	mov    r15,QWORD PTR [rsp+0x40]
    5cd8:	add    rsp,0x50
    5cdc:	mov    rsp,rbp
    5cdf:	pop    rbp
    5ce0:	ret
    5ce1:	add    BYTE PTR [rax],al
    5ce3:	add    BYTE PTR [rax],al
    5ce5:	add    BYTE PTR [rax],al
    5ce7:	add    BYTE PTR [rsi],al
    5ce9:	add    BYTE PTR [rax],al
    5ceb:	add    BYTE PTR [rax],al
    5ced:	add    BYTE PTR [rax],al
	...

0000000000005cf0 <botlish_entry_49: ht_place<mutarray, int, any, any>>:
    5cf0:	push   rbp
    5cf1:	mov    rbp,rsp
    5cf4:	mov    rsi,QWORD PTR [rdx]
    5cf7:	mov    r9,QWORD PTR [rdx+0x8]
    5cfb:	mov    rcx,QWORD PTR [rdx+0x10]
    5cff:	mov    r8,QWORD PTR [rdx+0x18]
    5d03:	mov    rdx,r9
    5d06:	call   5d0b <botlish_entry_49+0x1b>
			5d07: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    5d0b:	mov    rsp,rbp
    5d0e:	pop    rbp
    5d0f:	ret

0000000000005d10 <botlish_fn_50: ht_set<mutarray, any, any>>:
    5d10:	push   rbp
    5d11:	mov    rbp,rsp
    5d14:	sub    rsp,0x50
    5d18:	mov    QWORD PTR [rsp+0x20],rbx
    5d1d:	mov    QWORD PTR [rsp+0x28],r12
    5d22:	mov    QWORD PTR [rsp+0x30],r13
    5d27:	mov    QWORD PTR [rsp+0x38],r14
    5d2c:	mov    QWORD PTR [rsp+0x40],r15
    5d31:	mov    rbx,QWORD PTR [rdi]
    5d34:	mov    rax,QWORD PTR [rdi+0x8]
    5d38:	lea    r8,[rbx+0x28]
    5d3c:	cmp    r8,rax
    5d3f:	ja     6114 <botlish_fn_50+0x404>
    5d45:	lea    rax,[rbx+0x28]
    5d49:	mov    QWORD PTR [rdi],rax
    5d4c:	mov    r12,rdi
    5d4f:	mov    QWORD PTR [rbx],0x0
    5d56:	mov    QWORD PTR [rbx+0x8],0x0
    5d5e:	mov    QWORD PTR [rbx+0x10],0x0
    5d66:	mov    QWORD PTR [rbx+0x18],0x0
    5d6e:	mov    QWORD PTR [rbx+0x20],0x0
    5d76:	mov    QWORD PTR [rbx],rsi
    5d79:	mov    r15,rsi
    5d7c:	mov    QWORD PTR [rbx+0x8],rdx
    5d80:	mov    r14,rdx
    5d83:	mov    QWORD PTR [rbx+0x10],rcx
    5d87:	mov    r13,rcx
    5d8a:	mov    rdx,r14
    5d8d:	mov    rsi,r15
    5d90:	mov    rdi,r12
    5d93:	call   5d98 <botlish_fn_50+0x88>
			5d94: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    5d98:	test   rax,rax
    5d9b:	jne    5da9 <botlish_fn_50+0x99>
    5da1:	mov    rdi,r12
    5da4:	jmp    60bc <botlish_fn_50+0x3ac>
    5da9:	mov    QWORD PTR [rbx+0x18],rax
    5dad:	mov    rcx,rax
    5db0:	mov    r8,0xffffffffffffffff
    5db7:	mov    QWORD PTR [rsp+0x10],r8
    5dbc:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    5dc4:	mov    rdx,r14
    5dc7:	mov    rsi,r15
    5dca:	mov    rdi,r12
    5dcd:	call   5dd2 <botlish_fn_50+0xc2>
			5dce: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    5dd2:	mov    rcx,rax
    5dd5:	mov    QWORD PTR [rsp+0x8],rax
    5dda:	test   rax,rcx
    5ddd:	jne    5deb <botlish_fn_50+0xdb>
    5de3:	mov    rdi,r12
    5de6:	jmp    60bc <botlish_fn_50+0x3ac>
    5deb:	mov    rax,QWORD PTR [rsp+0x8]
    5df0:	mov    QWORD PTR [rbx+0x18],rax
    5df4:	mov    rsi,r15
    5df7:	mov    rdi,r12
    5dfa:	call   5dff <botlish_fn_50+0xef>
			5dfb: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    5dff:	test   rax,rax
    5e02:	jne    5e10 <botlish_fn_50+0x100>
    5e08:	mov    rdi,r12
    5e0b:	jmp    60bc <botlish_fn_50+0x3ac>
    5e10:	xor    ecx,ecx
    5e12:	test   rax,0x7
    5e18:	je     5e26 <botlish_fn_50+0x116>
    5e1e:	mov    rsi,rax
    5e21:	jmp    5e34 <botlish_fn_50+0x124>
    5e26:	movzx  rcx,BYTE PTR [rax]
    5e2a:	mov    rsi,rax
    5e2d:	rex cmp cl,0x8
    5e31:	sete   cl
    5e34:	test   cl,cl
    5e36:	jne    5e5d <botlish_fn_50+0x14d>
    5e3c:	mov    rdi,r12
    5e3f:	mov    rax,QWORD PTR [rdi+0x10]
    5e43:	mov    rcx,QWORD PTR [rax+0x20]
    5e47:	mov    edx,0x8
    5e4c:	mov    rax,QWORD PTR [rip+0x0]        # 5e53 <botlish_fn_50+0x143>
			5e4f: R_X86_64_GOTPCREL	rt_type_error-0x4
    5e53:	call   rax
    5e55:	mov    rdi,r12
    5e58:	jmp    60bc <botlish_fn_50+0x3ac>
    5e5d:	mov    rax,QWORD PTR [rip+0x0]        # 5e64 <botlish_fn_50+0x154>
			5e60: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    5e64:	mov    rdx,QWORD PTR [rsp+0x8]
    5e69:	mov    rdi,r12
    5e6c:	call   rax
    5e6e:	test   rax,rax
    5e71:	jne    5e7f <botlish_fn_50+0x16f>
    5e77:	mov    rdi,r12
    5e7a:	jmp    60bc <botlish_fn_50+0x3ac>
    5e7f:	mov    QWORD PTR [rbx+0x20],rax
    5e83:	mov    QWORD PTR [rsp],rax
    5e87:	mov    rdi,r12
    5e8a:	call   5e8f <botlish_fn_50+0x17f>
			5e8b: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    5e8f:	test   rax,rax
    5e92:	jne    5ea0 <botlish_fn_50+0x190>
    5e98:	mov    rdi,r12
    5e9b:	jmp    60bc <botlish_fn_50+0x3ac>
    5ea0:	mov    rcx,QWORD PTR [rsp]
    5ea4:	mov    rdx,rcx
    5ea7:	and    rdx,rax
    5eaa:	mov    rcx,rax
    5ead:	test   rdx,0x1
    5eb4:	jne    5ede <botlish_fn_50+0x1ce>
    5eba:	mov    rax,QWORD PTR [rip+0x0]        # 5ec1 <botlish_fn_50+0x1b1>
			5ebd: R_X86_64_GOTPCREL	rt_value_eq-0x4
    5ec1:	mov    rdx,rcx
    5ec4:	mov    rsi,QWORD PTR [rsp]
    5ec8:	mov    rdi,r12
    5ecb:	call   rax
    5ecd:	test   rax,rax
    5ed0:	jne    5ef5 <botlish_fn_50+0x1e5>
    5ed6:	mov    rdi,r12
    5ed9:	jmp    60bc <botlish_fn_50+0x3ac>
    5ede:	mov    rdx,rcx
    5ee1:	mov    rsi,QWORD PTR [rsp]
    5ee5:	mov    eax,0x2
    5eea:	cmp    rsi,rdx
    5eed:	cmove  rax,QWORD PTR [rip+0x253]        # 6148 <botlish_fn_50+0x438>
    5ef5:	cmp    rax,0x6
    5ef9:	je     6033 <botlish_fn_50+0x323>
    5eff:	mov    rsi,r15
    5f02:	mov    rdi,r12
    5f05:	call   5f0a <botlish_fn_50+0x1fa>
			5f06: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    5f0a:	test   rax,rax
    5f0d:	jne    5f1b <botlish_fn_50+0x20b>
    5f13:	mov    rdi,r12
    5f16:	jmp    60bc <botlish_fn_50+0x3ac>
    5f1b:	cmp    rax,0x6
    5f1f:	je     5f74 <botlish_fn_50+0x264>
    5f25:	mov    rcx,r14
    5f28:	mov    rdx,QWORD PTR [rsp+0x8]
    5f2d:	mov    rsi,r15
    5f30:	mov    r8,r13
    5f33:	mov    rdi,r12
    5f36:	call   5f3b <botlish_fn_50+0x22b>
			5f37: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    5f3b:	test   rax,rax
    5f3e:	jne    5f4c <botlish_fn_50+0x23c>
    5f44:	mov    rdi,r12
    5f47:	jmp    60bc <botlish_fn_50+0x3ac>
    5f4c:	mov    rdi,r12
    5f4f:	mov    QWORD PTR [rdi],rbx
    5f52:	mov    rbx,QWORD PTR [rsp+0x20]
    5f57:	mov    r12,QWORD PTR [rsp+0x28]
    5f5c:	mov    r13,QWORD PTR [rsp+0x30]
    5f61:	mov    r14,QWORD PTR [rsp+0x38]
    5f66:	mov    r15,QWORD PTR [rsp+0x40]
    5f6b:	add    rsp,0x50
    5f6f:	mov    rsp,rbp
    5f72:	pop    rbp
    5f73:	ret
    5f74:	mov    rsi,r15
    5f77:	mov    rdi,r12
    5f7a:	call   5f7f <botlish_fn_50+0x26f>
			5f7b: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    5f7f:	test   rax,rax
    5f82:	jne    5f90 <botlish_fn_50+0x280>
    5f88:	mov    rdi,r12
    5f8b:	jmp    60bc <botlish_fn_50+0x3ac>
    5f90:	mov    rdx,r14
    5f93:	mov    rsi,r15
    5f96:	mov    rdi,r12
    5f99:	call   5f9e <botlish_fn_50+0x28e>
			5f9a: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    5f9e:	test   rax,rax
    5fa1:	jne    5faf <botlish_fn_50+0x29f>
    5fa7:	mov    rdi,r12
    5faa:	jmp    60bc <botlish_fn_50+0x3ac>
    5faf:	mov    QWORD PTR [rbx+0x18],rax
    5fb3:	mov    rcx,rax
    5fb6:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    5fbe:	mov    r8,QWORD PTR [rsp+0x10]
    5fc3:	mov    rdx,r14
    5fc6:	mov    rsi,r15
    5fc9:	mov    rdi,r12
    5fcc:	call   5fd1 <botlish_fn_50+0x2c1>
			5fcd: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    5fd1:	test   rax,rax
    5fd4:	jne    5fe2 <botlish_fn_50+0x2d2>
    5fda:	mov    rdi,r12
    5fdd:	jmp    60bc <botlish_fn_50+0x3ac>
    5fe2:	mov    QWORD PTR [rbx+0x18],rax
    5fe6:	mov    rcx,r14
    5fe9:	mov    rdx,rax
    5fec:	mov    rsi,r15
    5fef:	mov    r8,r13
    5ff2:	mov    rdi,r12
    5ff5:	call   5ffa <botlish_fn_50+0x2ea>
			5ff6: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    5ffa:	test   rax,rax
    5ffd:	jne    600b <botlish_fn_50+0x2fb>
    6003:	mov    rdi,r12
    6006:	jmp    60bc <botlish_fn_50+0x3ac>
    600b:	mov    rdi,r12
    600e:	mov    QWORD PTR [rdi],rbx
    6011:	mov    rbx,QWORD PTR [rsp+0x20]
    6016:	mov    r12,QWORD PTR [rsp+0x28]
    601b:	mov    r13,QWORD PTR [rsp+0x30]
    6020:	mov    r14,QWORD PTR [rsp+0x38]
    6025:	mov    r15,QWORD PTR [rsp+0x40]
    602a:	add    rsp,0x50
    602e:	mov    rsp,rbp
    6031:	pop    rbp
    6032:	ret
    6033:	mov    rsi,r15
    6036:	mov    rdi,r12
    6039:	call   603e <botlish_fn_50+0x32e>
			603a: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    603e:	test   rax,rax
    6041:	jne    604f <botlish_fn_50+0x33f>
    6047:	mov    rdi,r12
    604a:	jmp    60bc <botlish_fn_50+0x3ac>
    604f:	xor    ecx,ecx
    6051:	test   rax,0x7
    6057:	je     6065 <botlish_fn_50+0x355>
    605d:	mov    rsi,rax
    6060:	jmp    6073 <botlish_fn_50+0x363>
    6065:	movzx  rcx,BYTE PTR [rax]
    6069:	mov    rsi,rax
    606c:	rex cmp cl,0x8
    6070:	sete   cl
    6073:	test   cl,cl
    6075:	jne    609c <botlish_fn_50+0x38c>
    607b:	mov    rdi,r12
    607e:	mov    rax,QWORD PTR [rdi+0x10]
    6082:	mov    rcx,QWORD PTR [rax+0x40]
    6086:	mov    edx,0x8
    608b:	mov    rax,QWORD PTR [rip+0x0]        # 6092 <botlish_fn_50+0x382>
			608e: R_X86_64_GOTPCREL	rt_type_error-0x4
    6092:	call   rax
    6094:	mov    rdi,r12
    6097:	jmp    60bc <botlish_fn_50+0x3ac>
    609c:	mov    rax,QWORD PTR [rip+0x0]        # 60a3 <botlish_fn_50+0x393>
			609f: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    60a3:	mov    rcx,r13
    60a6:	mov    rdx,QWORD PTR [rsp+0x8]
    60ab:	mov    rdi,r12
    60ae:	call   rax
    60b0:	test   rax,rax
    60b3:	jne    60e7 <botlish_fn_50+0x3d7>
    60b9:	mov    rdi,r12
    60bc:	mov    rdi,r12
    60bf:	mov    QWORD PTR [rdi],rbx
    60c2:	xor    rax,rax
    60c5:	mov    rbx,QWORD PTR [rsp+0x20]
    60ca:	mov    r12,QWORD PTR [rsp+0x28]
    60cf:	mov    r13,QWORD PTR [rsp+0x30]
    60d4:	mov    r14,QWORD PTR [rsp+0x38]
    60d9:	mov    r15,QWORD PTR [rsp+0x40]
    60de:	add    rsp,0x50
    60e2:	mov    rsp,rbp
    60e5:	pop    rbp
    60e6:	ret
    60e7:	mov    rdi,r12
    60ea:	mov    QWORD PTR [rdi],rbx
    60ed:	mov    eax,0xa
    60f2:	mov    rbx,QWORD PTR [rsp+0x20]
    60f7:	mov    r12,QWORD PTR [rsp+0x28]
    60fc:	mov    r13,QWORD PTR [rsp+0x30]
    6101:	mov    r14,QWORD PTR [rsp+0x38]
    6106:	mov    r15,QWORD PTR [rsp+0x40]
    610b:	add    rsp,0x50
    610f:	mov    rsp,rbp
    6112:	pop    rbp
    6113:	ret
    6114:	mov    r12,rdi
    6117:	mov    rax,QWORD PTR [rip+0x0]        # 611e <botlish_fn_50+0x40e>
			611a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    611e:	call   rax
    6120:	xor    rax,rax
    6123:	mov    rbx,QWORD PTR [rsp+0x20]
    6128:	mov    r12,QWORD PTR [rsp+0x28]
    612d:	mov    r13,QWORD PTR [rsp+0x30]
    6132:	mov    r14,QWORD PTR [rsp+0x38]
    6137:	mov    r15,QWORD PTR [rsp+0x40]
    613c:	add    rsp,0x50
    6140:	mov    rsp,rbp
    6143:	pop    rbp
    6144:	ret
    6145:	add    BYTE PTR [rax],al
    6147:	add    BYTE PTR [rsi],al
    6149:	add    BYTE PTR [rax],al
    614b:	add    BYTE PTR [rax],al
    614d:	add    BYTE PTR [rax],al
	...

0000000000006150 <botlish_entry_50: ht_set<mutarray, any, any>>:
    6150:	push   rbp
    6151:	mov    rbp,rsp
    6154:	mov    rsi,QWORD PTR [rdx]
    6157:	mov    r8,QWORD PTR [rdx+0x8]
    615b:	mov    rcx,QWORD PTR [rdx+0x10]
    615f:	mov    rdx,r8
    6162:	call   6167 <botlish_entry_50+0x17>
			6163: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    6167:	mov    rsp,rbp
    616a:	pop    rbp
    616b:	ret

000000000000616c <botlish_fn_51: row_new<bool, int>>:
    616c:	push   rbp
    616d:	mov    rbp,rsp
    6170:	sub    rsp,0x10
    6174:	mov    QWORD PTR [rsp],rbx
    6178:	mov    QWORD PTR [rsp+0x8],r15
    617d:	mov    r15,QWORD PTR [rdi]
    6180:	mov    rax,QWORD PTR [rdi+0x8]
    6184:	lea    rcx,[r15+0x8]
    6188:	cmp    rcx,rax
    618b:	ja     6226 <botlish_fn_51+0xba>
    6191:	lea    rax,[r15+0x8]
    6195:	mov    QWORD PTR [rdi],rax
    6198:	mov    rbx,rdi
    619b:	mov    QWORD PTR [r15],rdx
    619e:	mov    rax,rdx
    61a1:	cmp    rsi,0x6
    61a5:	je     61dc <botlish_fn_51+0x70>
    61ab:	mov    rdi,rbx
    61ae:	call   61b3 <botlish_fn_51+0x47>
			61af: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    61b3:	test   rax,rax
    61b6:	jne    61c4 <botlish_fn_51+0x58>
    61bc:	mov    rdi,rbx
    61bf:	jmp    61f3 <botlish_fn_51+0x87>
    61c4:	mov    rdi,rbx
    61c7:	mov    QWORD PTR [rdi],r15
    61ca:	mov    rbx,QWORD PTR [rsp]
    61ce:	mov    r15,QWORD PTR [rsp+0x8]
    61d3:	add    rsp,0x10
    61d7:	mov    rsp,rbp
    61da:	pop    rbp
    61db:	ret
    61dc:	mov    rsi,rax
    61df:	mov    rdi,rbx
    61e2:	call   61e7 <botlish_fn_51+0x7b>
			61e3: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    61e7:	test   rax,rax
    61ea:	jne    620e <botlish_fn_51+0xa2>
    61f0:	mov    rdi,rbx
    61f3:	mov    rdi,rbx
    61f6:	mov    QWORD PTR [rdi],r15
    61f9:	xor    rax,rax
    61fc:	mov    rbx,QWORD PTR [rsp]
    6200:	mov    r15,QWORD PTR [rsp+0x8]
    6205:	add    rsp,0x10
    6209:	mov    rsp,rbp
    620c:	pop    rbp
    620d:	ret
    620e:	mov    rdi,rbx
    6211:	mov    QWORD PTR [rdi],r15
    6214:	mov    rbx,QWORD PTR [rsp]
    6218:	mov    r15,QWORD PTR [rsp+0x8]
    621d:	add    rsp,0x10
    6221:	mov    rsp,rbp
    6224:	pop    rbp
    6225:	ret
    6226:	mov    rbx,rdi
    6229:	mov    rax,QWORD PTR [rip+0x0]        # 6230 <botlish_fn_51+0xc4>
			622c: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    6230:	call   rax
    6232:	xor    rax,rax
    6235:	mov    rbx,QWORD PTR [rsp]
    6239:	mov    r15,QWORD PTR [rsp+0x8]
    623e:	add    rsp,0x10
    6242:	mov    rsp,rbp
    6245:	pop    rbp
    6246:	ret

0000000000006247 <botlish_entry_51: row_new<bool, int>>:
    6247:	push   rbp
    6248:	mov    rbp,rsp
    624b:	mov    rsi,QWORD PTR [rdx]
    624e:	mov    rdx,QWORD PTR [rdx+0x8]
    6252:	call   6257 <botlish_entry_51+0x10>
			6253: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    6257:	mov    rsp,rbp
    625a:	pop    rbp
    625b:	ret
    625c:	add    BYTE PTR [rax],al
	...

0000000000006260 <botlish_fn_52: row_fill<mutarray, any, any, int, int>>:
    6260:	push   rbp
    6261:	mov    rbp,rsp
    6264:	sub    rsp,0x50
    6268:	mov    QWORD PTR [rsp+0x20],rbx
    626d:	mov    QWORD PTR [rsp+0x28],r12
    6272:	mov    QWORD PTR [rsp+0x30],r13
    6277:	mov    QWORD PTR [rsp+0x38],r14
    627c:	mov    QWORD PTR [rsp+0x40],r15
    6281:	mov    rax,r9
    6284:	mov    r13,rdx
    6287:	mov    r15,QWORD PTR [rdi]
    628a:	mov    r9,QWORD PTR [rdi+0x8]
    628e:	lea    r10,[r15+0x30]
    6292:	cmp    r10,r9
    6295:	ja     6578 <botlish_fn_52+0x318>
    629b:	lea    r9,[r15+0x30]
    629f:	mov    QWORD PTR [rdi],r9
    62a2:	mov    QWORD PTR [rsp],rdi
    62a6:	mov    QWORD PTR [r15],0x0
    62ad:	mov    QWORD PTR [r15+0x8],0x0
    62b5:	mov    QWORD PTR [r15+0x10],0x0
    62bd:	mov    QWORD PTR [r15+0x18],0x0
    62c5:	mov    QWORD PTR [r15+0x20],0x0
    62cd:	mov    QWORD PTR [r15+0x28],0x0
    62d5:	mov    QWORD PTR [r15],rsi
    62d8:	mov    rdx,r13
    62db:	mov    r14,rsi
    62de:	mov    QWORD PTR [r15+0x8],rdx
    62e2:	mov    QWORD PTR [r15+0x10],rcx
    62e6:	mov    QWORD PTR [rsp+0x8],rcx
    62eb:	mov    QWORD PTR [r15+0x18],r8
    62ef:	mov    rbx,rax
    62f2:	mov    rax,rbx
    62f5:	or     rax,0x1
    62f9:	mov    r12,r8
    62fc:	mov    rcx,r12
    62ff:	and    rcx,rax
    6302:	test   rcx,0x1
    6309:	jne    633b <botlish_fn_52+0xdb>
    630f:	mov    rdx,rbx
    6312:	or     rdx,0x1
    6316:	mov    rax,QWORD PTR [rip+0x0]        # 631d <botlish_fn_52+0xbd>
			6319: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    631d:	mov    rsi,r12
    6320:	mov    rdi,QWORD PTR [rsp]
    6324:	call   rax
    6326:	mov    ecx,0x2
    632b:	test   rax,rax
    632e:	cmovge rcx,QWORD PTR [rip+0x27a]        # 65b0 <botlish_fn_52+0x350>
    6336:	jmp    6352 <botlish_fn_52+0xf2>
    633b:	mov    rax,rbx
    633e:	or     rax,0x1
    6342:	mov    ecx,0x2
    6347:	cmp    r12,rax
    634a:	cmovge rcx,QWORD PTR [rip+0x25e]        # 65b0 <botlish_fn_52+0x350>
    6352:	cmp    rcx,0x6
    6356:	je     654c <botlish_fn_52+0x2ec>
    635c:	xor    ecx,ecx
    635e:	mov    rdx,r13
    6361:	test   rdx,0x7
    6368:	jne    637a <botlish_fn_52+0x11a>
    636e:	mov    rdx,r13
    6371:	movzx  rax,BYTE PTR [rdx]
    6375:	cmp    al,0x3
    6377:	sete   cl
    637a:	test   cl,cl
    637c:	jne    63a8 <botlish_fn_52+0x148>
    6382:	mov    rdi,QWORD PTR [rsp]
    6386:	mov    rax,QWORD PTR [rdi+0x10]
    638a:	mov    rcx,QWORD PTR [rax+0x50]
    638e:	mov    edx,0x4
    6393:	mov    rax,QWORD PTR [rip+0x0]        # 639a <botlish_fn_52+0x13a>
			6396: R_X86_64_GOTPCREL	rt_type_error-0x4
    639a:	mov    rsi,r13
    639d:	call   rax
    639f:	mov    rdi,QWORD PTR [rsp]
    63a3:	jmp    64f3 <botlish_fn_52+0x293>
    63a8:	mov    rsi,r13
    63ab:	test   r12,0x1
    63b2:	jne    63c0 <botlish_fn_52+0x160>
    63b8:	mov    r13,rsi
    63bb:	jmp    63d6 <botlish_fn_52+0x176>
    63c0:	mov    rax,QWORD PTR [rsi+0x8]
    63c4:	mov    r13,rsi
    63c7:	mov    rcx,r12
    63ca:	sar    rcx,1
    63cd:	cmp    rcx,rax
    63d0:	jb     6403 <botlish_fn_52+0x1a3>
    63d6:	mov    rax,QWORD PTR [rip+0x0]        # 63dd <botlish_fn_52+0x17d>
			63d9: R_X86_64_GOTPCREL	rt_list_get-0x4
    63dd:	mov    rdx,r12
    63e0:	mov    rsi,r13
    63e3:	mov    rdi,QWORD PTR [rsp]
    63e7:	call   rax
    63e9:	test   rax,rax
    63ec:	jne    63fb <botlish_fn_52+0x19b>
    63f2:	mov    rdi,QWORD PTR [rsp]
    63f6:	jmp    64f3 <botlish_fn_52+0x293>
    63fb:	mov    rdx,rax
    63fe:	jmp    640b <botlish_fn_52+0x1ab>
    6403:	mov    rax,QWORD PTR [r13+0x10]
    6407:	mov    rdx,QWORD PTR [rax+rcx*8]
    640b:	mov    QWORD PTR [r15+0x20],rdx
    640f:	mov    QWORD PTR [rsp+0x10],rdx
    6414:	xor    ecx,ecx
    6416:	mov    rdx,QWORD PTR [rsp+0x8]
    641b:	test   rdx,0x7
    6422:	je     6432 <botlish_fn_52+0x1d2>
    6428:	mov    QWORD PTR [rsp+0x8],rdx
    642d:	jmp    6440 <botlish_fn_52+0x1e0>
    6432:	movzx  rax,BYTE PTR [rdx]
    6436:	mov    QWORD PTR [rsp+0x8],rdx
    643b:	cmp    al,0x3
    643d:	sete   cl
    6440:	test   cl,cl
    6442:	jne    6470 <botlish_fn_52+0x210>
    6448:	mov    rdi,QWORD PTR [rsp]
    644c:	mov    rax,QWORD PTR [rdi+0x10]
    6450:	mov    rcx,QWORD PTR [rax+0x50]
    6454:	mov    edx,0x4
    6459:	mov    rax,QWORD PTR [rip+0x0]        # 6460 <botlish_fn_52+0x200>
			645c: R_X86_64_GOTPCREL	rt_type_error-0x4
    6460:	mov    rsi,QWORD PTR [rsp+0x8]
    6465:	call   rax
    6467:	mov    rdi,QWORD PTR [rsp]
    646b:	jmp    64f3 <botlish_fn_52+0x293>
    6470:	test   r12,0x1
    6477:	je     6495 <botlish_fn_52+0x235>
    647d:	mov    rsi,QWORD PTR [rsp+0x8]
    6482:	mov    rcx,QWORD PTR [rsi+0x8]
    6486:	mov    rax,r12
    6489:	sar    rax,1
    648c:	cmp    rax,rcx
    648f:	jb     64c4 <botlish_fn_52+0x264>
    6495:	mov    rax,QWORD PTR [rip+0x0]        # 649c <botlish_fn_52+0x23c>
			6498: R_X86_64_GOTPCREL	rt_list_get-0x4
    649c:	mov    rdx,r12
    649f:	mov    rsi,QWORD PTR [rsp+0x8]
    64a4:	mov    rdi,QWORD PTR [rsp]
    64a8:	call   rax
    64aa:	test   rax,rax
    64ad:	jne    64bc <botlish_fn_52+0x25c>
    64b3:	mov    rdi,QWORD PTR [rsp]
    64b7:	jmp    64f3 <botlish_fn_52+0x293>
    64bc:	mov    rcx,rax
    64bf:	jmp    64d1 <botlish_fn_52+0x271>
    64c4:	mov    rsi,QWORD PTR [rsp+0x8]
    64c9:	mov    rsi,QWORD PTR [rsi+0x10]
    64cd:	mov    rcx,QWORD PTR [rsi+rax*8]
    64d1:	mov    QWORD PTR [r15+0x28],rcx
    64d5:	mov    rdx,QWORD PTR [rsp+0x10]
    64da:	mov    rsi,r14
    64dd:	mov    rdi,QWORD PTR [rsp]
    64e1:	call   64e6 <botlish_fn_52+0x286>
			64e2: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    64e6:	test   rax,rax
    64e9:	jne    651f <botlish_fn_52+0x2bf>
    64ef:	mov    rdi,QWORD PTR [rsp]
    64f3:	mov    rdi,QWORD PTR [rsp]
    64f7:	mov    QWORD PTR [rdi],r15
    64fa:	xor    rax,rax
    64fd:	mov    rbx,QWORD PTR [rsp+0x20]
    6502:	mov    r12,QWORD PTR [rsp+0x28]
    6507:	mov    r13,QWORD PTR [rsp+0x30]
    650c:	mov    r14,QWORD PTR [rsp+0x38]
    6511:	mov    r15,QWORD PTR [rsp+0x40]
    6516:	add    rsp,0x50
    651a:	mov    rsp,rbp
    651d:	pop    rbp
    651e:	ret
    651f:	mov    QWORD PTR [r15],r14
    6522:	mov    QWORD PTR [r15+0x8],r13
    6526:	mov    rsi,QWORD PTR [rsp+0x8]
    652b:	mov    QWORD PTR [r15+0x10],rsi
    652f:	sar    r12,1
    6532:	add    r12,0x1
    6539:	shl    r12,1
    653c:	or     r12,0x1
    6540:	mov    QWORD PTR [r15+0x18],r12
    6544:	mov    r8,r12
    6547:	jmp    62f2 <botlish_fn_52+0x92>
    654c:	mov    rdi,QWORD PTR [rsp]
    6550:	mov    QWORD PTR [rdi],r15
    6553:	mov    rax,r14
    6556:	mov    rbx,QWORD PTR [rsp+0x20]
    655b:	mov    r12,QWORD PTR [rsp+0x28]
    6560:	mov    r13,QWORD PTR [rsp+0x30]
    6565:	mov    r14,QWORD PTR [rsp+0x38]
    656a:	mov    r15,QWORD PTR [rsp+0x40]
    656f:	add    rsp,0x50
    6573:	mov    rsp,rbp
    6576:	pop    rbp
    6577:	ret
    6578:	mov    QWORD PTR [rsp],rdi
    657c:	mov    rax,QWORD PTR [rip+0x0]        # 6583 <botlish_fn_52+0x323>
			657f: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    6583:	call   rax
    6585:	xor    rax,rax
    6588:	mov    rbx,QWORD PTR [rsp+0x20]
    658d:	mov    r12,QWORD PTR [rsp+0x28]
    6592:	mov    r13,QWORD PTR [rsp+0x30]
    6597:	mov    r14,QWORD PTR [rsp+0x38]
    659c:	mov    r15,QWORD PTR [rsp+0x40]
    65a1:	add    rsp,0x50
    65a5:	mov    rsp,rbp
    65a8:	pop    rbp
    65a9:	ret
    65aa:	add    BYTE PTR [rax],al
    65ac:	add    BYTE PTR [rax],al
    65ae:	add    BYTE PTR [rax],al
    65b0:	(bad)
    65b1:	add    BYTE PTR [rax],al
    65b3:	add    BYTE PTR [rax],al
    65b5:	add    BYTE PTR [rax],al
	...

00000000000065b8 <botlish_entry_52: row_fill<mutarray, any, any, int, int>>:
    65b8:	push   rbp
    65b9:	mov    rbp,rsp
    65bc:	mov    rsi,QWORD PTR [rdx]
    65bf:	mov    r10,QWORD PTR [rdx+0x8]
    65c3:	mov    rcx,QWORD PTR [rdx+0x10]
    65c7:	mov    r8,QWORD PTR [rdx+0x18]
    65cb:	mov    r9,QWORD PTR [rdx+0x20]
    65cf:	mov    rdx,r10
    65d2:	call   65d7 <botlish_entry_52+0x1f>
			65d3: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    65d7:	mov    rsp,rbp
    65da:	pop    rbp
    65db:	ret

00000000000065dc <botlish_fn_53: row_table<any, int, any, bool>>:
    65dc:	push   rbp
    65dd:	mov    rbp,rsp
    65e0:	sub    rsp,0x30
    65e4:	mov    QWORD PTR [rsp],rbx
    65e8:	mov    QWORD PTR [rsp+0x8],r12
    65ed:	mov    QWORD PTR [rsp+0x10],r13
    65f2:	mov    QWORD PTR [rsp+0x18],r14
    65f7:	mov    QWORD PTR [rsp+0x20],r15
    65fc:	mov    rbx,QWORD PTR [rdi]
    65ff:	mov    rax,QWORD PTR [rdi+0x8]
    6603:	lea    r9,[rbx+0x28]
    6607:	cmp    r9,rax
    660a:	ja     675d <botlish_fn_53+0x181>
    6610:	lea    rax,[rbx+0x28]
    6614:	mov    QWORD PTR [rdi],rax
    6617:	mov    r12,rdi
    661a:	mov    QWORD PTR [rbx],0x0
    6621:	mov    QWORD PTR [rbx+0x8],0x0
    6629:	mov    QWORD PTR [rbx+0x10],0x0
    6631:	mov    QWORD PTR [rbx+0x18],0x0
    6639:	mov    QWORD PTR [rbx+0x20],0x0
    6641:	mov    QWORD PTR [rbx],rsi
    6644:	mov    r14,rsi
    6647:	mov    QWORD PTR [rbx+0x8],rdx
    664b:	mov    QWORD PTR [rbx+0x10],rcx
    664f:	mov    r13,rcx
    6652:	mov    QWORD PTR [rbx+0x18],r8
    6656:	mov    rsi,r8
    6659:	mov    rdi,r12
    665c:	call   6661 <botlish_fn_53+0x85>
			665d: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    6661:	test   rax,rax
    6664:	jne    6672 <botlish_fn_53+0x96>
    666a:	mov    rdi,r12
    666d:	jmp    670c <botlish_fn_53+0x130>
    6672:	mov    QWORD PTR [rbx+0x8],rax
    6676:	mov    r15,rax
    6679:	mov    QWORD PTR [rbx+0x18],0x1
    6681:	xor    ecx,ecx
    6683:	mov    rdx,r13
    6686:	test   rdx,0x7
    668d:	je     669b <botlish_fn_53+0xbf>
    6693:	mov    r13,rdx
    6696:	jmp    66a7 <botlish_fn_53+0xcb>
    669b:	movzx  rax,BYTE PTR [rdx]
    669f:	mov    r13,rdx
    66a2:	cmp    al,0x3
    66a4:	sete   cl
    66a7:	test   cl,cl
    66a9:	jne    66d3 <botlish_fn_53+0xf7>
    66af:	mov    rdi,r12
    66b2:	mov    rax,QWORD PTR [rdi+0x10]
    66b6:	mov    rcx,QWORD PTR [rax+0x58]
    66ba:	mov    edx,0x4
    66bf:	mov    rax,QWORD PTR [rip+0x0]        # 66c6 <botlish_fn_53+0xea>
			66c2: R_X86_64_GOTPCREL	rt_type_error-0x4
    66c6:	mov    rsi,r13
    66c9:	call   rax
    66cb:	mov    rdi,r12
    66ce:	jmp    670c <botlish_fn_53+0x130>
    66d3:	mov    rax,QWORD PTR [rip+0x0]        # 66da <botlish_fn_53+0xfe>
			66d6: R_X86_64_GOTPCREL	rt_list_len-0x4
    66da:	mov    rsi,r13
    66dd:	mov    rdi,r12
    66e0:	call   rax
    66e2:	mov    QWORD PTR [rbx+0x20],rax
    66e6:	mov    r8d,0x1
    66ec:	mov    rcx,r13
    66ef:	mov    rdx,r14
    66f2:	mov    rsi,r15
    66f5:	mov    r9,rax
    66f8:	mov    rdi,r12
    66fb:	call   6700 <botlish_fn_53+0x124>
			66fc: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    6700:	test   rax,rax
    6703:	jne    6736 <botlish_fn_53+0x15a>
    6709:	mov    rdi,r12
    670c:	mov    rdi,r12
    670f:	mov    QWORD PTR [rdi],rbx
    6712:	xor    rax,rax
    6715:	mov    rbx,QWORD PTR [rsp]
    6719:	mov    r12,QWORD PTR [rsp+0x8]
    671e:	mov    r13,QWORD PTR [rsp+0x10]
    6723:	mov    r14,QWORD PTR [rsp+0x18]
    6728:	mov    r15,QWORD PTR [rsp+0x20]
    672d:	add    rsp,0x30
    6731:	mov    rsp,rbp
    6734:	pop    rbp
    6735:	ret
    6736:	mov    rdi,r12
    6739:	mov    QWORD PTR [rdi],rbx
    673c:	mov    rbx,QWORD PTR [rsp]
    6740:	mov    r12,QWORD PTR [rsp+0x8]
    6745:	mov    r13,QWORD PTR [rsp+0x10]
    674a:	mov    r14,QWORD PTR [rsp+0x18]
    674f:	mov    r15,QWORD PTR [rsp+0x20]
    6754:	add    rsp,0x30
    6758:	mov    rsp,rbp
    675b:	pop    rbp
    675c:	ret
    675d:	mov    r12,rdi
    6760:	mov    rcx,QWORD PTR [rip+0x0]        # 6767 <botlish_fn_53+0x18b>
			6763: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    6767:	call   rcx
    6769:	xor    rax,rax
    676c:	mov    rbx,QWORD PTR [rsp]
    6770:	mov    r12,QWORD PTR [rsp+0x8]
    6775:	mov    r13,QWORD PTR [rsp+0x10]
    677a:	mov    r14,QWORD PTR [rsp+0x18]
    677f:	mov    r15,QWORD PTR [rsp+0x20]
    6784:	add    rsp,0x30
    6788:	mov    rsp,rbp
    678b:	pop    rbp
    678c:	ret

000000000000678d <botlish_entry_53: row_table<any, int, any, bool>>:
    678d:	push   rbp
    678e:	mov    rbp,rsp
    6791:	mov    rsi,QWORD PTR [rdx]
    6794:	mov    r9,QWORD PTR [rdx+0x8]
    6798:	mov    rcx,QWORD PTR [rdx+0x10]
    679c:	mov    r8,QWORD PTR [rdx+0x18]
    67a0:	mov    rdx,r9
    67a3:	call   67a8 <botlish_entry_53+0x1b>
			67a4: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    67a8:	mov    rsp,rbp
    67ab:	pop    rbp
    67ac:	ret
    67ad:	add    BYTE PTR [rax],al
	...

00000000000067b0 <botlish_fn_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    67b0:	push   rbp
    67b1:	mov    rbp,rsp
    67b4:	sub    rsp,0x60
    67b8:	mov    QWORD PTR [rsp+0x30],rbx
    67bd:	mov    QWORD PTR [rsp+0x38],r12
    67c2:	mov    QWORD PTR [rsp+0x40],r13
    67c7:	mov    QWORD PTR [rsp+0x48],r14
    67cc:	mov    QWORD PTR [rsp+0x50],r15
    67d1:	mov    QWORD PTR [rsp+0x8],r8
    67d6:	mov    r11,QWORD PTR [rbp+0x10]
    67da:	mov    r12,QWORD PTR [rbp+0x18]
    67de:	mov    QWORD PTR [rsp+0x10],r12
    67e3:	mov    r12,QWORD PTR [rdi]
    67e6:	mov    rax,QWORD PTR [rdi+0x8]
    67ea:	lea    r8,[r12+0x40]
    67ef:	cmp    r8,rax
    67f2:	ja     6a73 <botlish_fn_54+0x2c3>
    67f8:	lea    rax,[r12+0x40]
    67fd:	mov    QWORD PTR [rdi],rax
    6800:	mov    QWORD PTR [rsp],rdi
    6804:	mov    QWORD PTR [r12],0x0
    680c:	mov    QWORD PTR [r12+0x8],0x0
    6815:	mov    QWORD PTR [r12+0x10],0x0
    681e:	mov    QWORD PTR [r12+0x18],0x0
    6827:	mov    QWORD PTR [r12+0x20],0x0
    6830:	mov    QWORD PTR [r12+0x28],0x0
    6839:	mov    QWORD PTR [r12+0x30],0x0
    6842:	mov    QWORD PTR [r12+0x38],0x0
    684b:	mov    QWORD PTR [r12],rsi
    684f:	mov    QWORD PTR [r12+0x8],rdx
    6854:	mov    r13,rdx
    6857:	mov    QWORD PTR [r12+0x10],rcx
    685c:	mov    r15,rcx
    685f:	mov    QWORD PTR [r12+0x18],r9
    6864:	mov    QWORD PTR [r12+0x20],r11
    6869:	mov    rax,QWORD PTR [rsp+0x10]
    686e:	mov    QWORD PTR [rsp+0x20],r11
    6873:	mov    QWORD PTR [r12+0x28],rax
    6878:	mov    QWORD PTR [rsp+0x18],r9
    687d:	mov    r8,QWORD PTR [rip+0x0]        # 6884 <botlish_fn_54+0xd4>
			6880: R_X86_64_GOTPCREL	rt_list_len-0x4
    6884:	mov    rbx,rsi
    6887:	mov    rdi,QWORD PTR [rsp]
    688b:	call   r8
    688e:	mov    r14,r13
    6891:	mov    rsi,r14
    6894:	and    rsi,rax
    6897:	mov    rdx,rax
    689a:	test   rsi,0x1
    68a1:	jne    68cd <botlish_fn_54+0x11d>
    68a7:	mov    r8,QWORD PTR [rip+0x0]        # 68ae <botlish_fn_54+0xfe>
			68aa: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    68ae:	mov    rsi,r14
    68b1:	mov    rdi,QWORD PTR [rsp]
    68b5:	call   r8
    68b8:	mov    ecx,0x2
    68bd:	test   rax,rax
    68c0:	cmovge rcx,QWORD PTR [rip+0x1e0]        # 6aa8 <botlish_fn_54+0x2f8>
    68c8:	jmp    68dd <botlish_fn_54+0x12d>
    68cd:	mov    ecx,0x2
    68d2:	cmp    r14,rdx
    68d5:	cmovge rcx,QWORD PTR [rip+0x1cb]        # 6aa8 <botlish_fn_54+0x2f8>
    68dd:	cmp    rcx,0x6
    68e1:	je     69fe <botlish_fn_54+0x24e>
    68e7:	mov    rcx,QWORD PTR [rsp+0x8]
    68ec:	mov    rax,rcx
    68ef:	or     rax,0x1
    68f3:	mov    QWORD PTR [r12+0x30],rax
    68f8:	test   r14,0x1
    68ff:	je     6918 <botlish_fn_54+0x168>
    6905:	mov    rcx,QWORD PTR [rbx+0x8]
    6909:	mov    rax,r14
    690c:	sar    rax,1
    690f:	cmp    rax,rcx
    6912:	jb     6945 <botlish_fn_54+0x195>
    6918:	mov    rax,QWORD PTR [rip+0x0]        # 691f <botlish_fn_54+0x16f>
			691b: R_X86_64_GOTPCREL	rt_list_get-0x4
    691f:	mov    rdx,r14
    6922:	mov    rsi,rbx
    6925:	mov    rdi,QWORD PTR [rsp]
    6929:	call   rax
    692b:	test   rax,rax
    692e:	jne    693d <botlish_fn_54+0x18d>
    6934:	mov    rdi,QWORD PTR [rsp]
    6938:	jmp    6a1e <botlish_fn_54+0x26e>
    693d:	mov    rcx,rax
    6940:	jmp    694d <botlish_fn_54+0x19d>
    6945:	mov    rcx,QWORD PTR [rbx+0x10]
    6949:	mov    rcx,QWORD PTR [rcx+rax*8]
    694d:	mov    QWORD PTR [r12+0x38],rcx
    6952:	mov    rdi,QWORD PTR [rsp+0x8]
    6957:	mov    rdx,rdi
    695a:	or     rdx,0x1
    695e:	mov    r13,QWORD PTR [rsp+0x10]
    6963:	mov    rsi,r15
    6966:	mov    rdi,QWORD PTR [rsp]
    696a:	mov    r8,r13
    696d:	call   6972 <botlish_fn_54+0x1c2>
			696e: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    6972:	test   rax,rax
    6975:	jne    6984 <botlish_fn_54+0x1d4>
    697b:	mov    rdi,QWORD PTR [rsp]
    697f:	jmp    6a1e <botlish_fn_54+0x26e>
    6984:	mov    QWORD PTR [r12+0x8],rax
    6989:	mov    rcx,rax
    698c:	sar    r14,1
    698f:	add    r14,0x1
    6996:	shl    r14,1
    6999:	or     r14,0x1
    699d:	mov    QWORD PTR [r12+0x30],r14
    69a2:	mov    rdx,QWORD PTR [rsp+0x20]
    69a7:	mov    rsi,QWORD PTR [rsp+0x18]
    69ac:	mov    rdi,QWORD PTR [rsp]
    69b0:	call   69b5 <botlish_fn_54+0x205>
			69b1: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<list[mutarray, int], mutarray>
    69b5:	test   rax,rax
    69b8:	jne    69c7 <botlish_fn_54+0x217>
    69be:	mov    rdi,QWORD PTR [rsp]
    69c2:	jmp    6a1e <botlish_fn_54+0x26e>
    69c7:	mov    QWORD PTR [r12],rbx
    69cb:	mov    QWORD PTR [r12+0x8],r14
    69d0:	mov    QWORD PTR [r12+0x10],r15
    69d5:	mov    QWORD PTR [r12+0x18],rax
    69da:	mov    QWORD PTR [r12+0x20],rdx
    69df:	mov    QWORD PTR [r12+0x28],r13
    69e4:	mov    QWORD PTR [rsp+0x20],rdx
    69e9:	mov    QWORD PTR [rsp+0x18],rax
    69ee:	mov    QWORD PTR [rsp+0x10],r13
    69f3:	mov    r13,r14
    69f6:	mov    rsi,rbx
    69f9:	jmp    687d <botlish_fn_54+0xcd>
    69fe:	mov    rdx,QWORD PTR [rsp+0x20]
    6a03:	mov    rsi,QWORD PTR [rsp+0x18]
    6a08:	mov    rdi,QWORD PTR [rsp]
    6a0c:	call   6a11 <botlish_fn_54+0x261>
			6a0d: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    6a11:	test   rax,rax
    6a14:	jne    6a4a <botlish_fn_54+0x29a>
    6a1a:	mov    rdi,QWORD PTR [rsp]
    6a1e:	mov    rdi,QWORD PTR [rsp]
    6a22:	mov    QWORD PTR [rdi],r12
    6a25:	xor    rax,rax
    6a28:	mov    rbx,QWORD PTR [rsp+0x30]
    6a2d:	mov    r12,QWORD PTR [rsp+0x38]
    6a32:	mov    r13,QWORD PTR [rsp+0x40]
    6a37:	mov    r14,QWORD PTR [rsp+0x48]
    6a3c:	mov    r15,QWORD PTR [rsp+0x50]
    6a41:	add    rsp,0x60
    6a45:	mov    rsp,rbp
    6a48:	pop    rbp
    6a49:	ret
    6a4a:	mov    rdi,QWORD PTR [rsp]
    6a4e:	mov    QWORD PTR [rdi],r12
    6a51:	mov    rbx,QWORD PTR [rsp+0x30]
    6a56:	mov    r12,QWORD PTR [rsp+0x38]
    6a5b:	mov    r13,QWORD PTR [rsp+0x40]
    6a60:	mov    r14,QWORD PTR [rsp+0x48]
    6a65:	mov    r15,QWORD PTR [rsp+0x50]
    6a6a:	add    rsp,0x60
    6a6e:	mov    rsp,rbp
    6a71:	pop    rbp
    6a72:	ret
    6a73:	mov    QWORD PTR [rsp],rdi
    6a77:	mov    rax,QWORD PTR [rip+0x0]        # 6a7e <botlish_fn_54+0x2ce>
			6a7a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    6a7e:	call   rax
    6a80:	xor    rax,rax
    6a83:	mov    rbx,QWORD PTR [rsp+0x30]
    6a88:	mov    r12,QWORD PTR [rsp+0x38]
    6a8d:	mov    r13,QWORD PTR [rsp+0x40]
    6a92:	mov    r14,QWORD PTR [rsp+0x48]
    6a97:	mov    r15,QWORD PTR [rsp+0x50]
    6a9c:	add    rsp,0x60
    6aa0:	mov    rsp,rbp
    6aa3:	pop    rbp
    6aa4:	ret
    6aa5:	add    BYTE PTR [rax],al
    6aa7:	add    BYTE PTR [rsi],al
    6aa9:	add    BYTE PTR [rax],al
    6aab:	add    BYTE PTR [rax],al
    6aad:	add    BYTE PTR [rax],al
	...

0000000000006ab0 <botlish_entry_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    6ab0:	push   rbp
    6ab1:	mov    rbp,rsp
    6ab4:	sub    rsp,0x10
    6ab8:	mov    rsi,QWORD PTR [rdx]
    6abb:	mov    r10,QWORD PTR [rdx+0x8]
    6abf:	mov    rcx,QWORD PTR [rdx+0x10]
    6ac3:	mov    r8,QWORD PTR [rdx+0x18]
    6ac7:	mov    r9,QWORD PTR [rdx+0x20]
    6acb:	mov    r11,QWORD PTR [rdx+0x28]
    6acf:	mov    rax,QWORD PTR [rdx+0x30]
    6ad3:	mov    QWORD PTR [rsp],r11
    6ad7:	mov    QWORD PTR [rsp+0x8],rax
    6adc:	mov    rdx,r10
    6adf:	call   6ae4 <botlish_entry_54+0x34>
			6ae0: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    6ae4:	add    rsp,0x10
    6ae8:	mov    rsp,rbp
    6aeb:	pop    rbp
    6aec:	ret

0000000000006aed <botlish_fn_55: csv_records_generic<str, bool>>:
    6aed:	push   rbp
    6aee:	mov    rbp,rsp
    6af1:	sub    rsp,0x50
    6af5:	mov    QWORD PTR [rsp+0x20],rbx
    6afa:	mov    QWORD PTR [rsp+0x28],r12
    6aff:	mov    QWORD PTR [rsp+0x30],r13
    6b04:	mov    QWORD PTR [rsp+0x38],r14
    6b09:	mov    QWORD PTR [rsp+0x40],r15
    6b0e:	mov    rbx,QWORD PTR [rdi]
    6b11:	mov    rax,QWORD PTR [rdi+0x8]
    6b15:	lea    rcx,[rbx+0x38]
    6b19:	cmp    rcx,rax
    6b1c:	ja     6d52 <botlish_fn_55+0x265>
    6b22:	lea    rax,[rbx+0x38]
    6b26:	mov    QWORD PTR [rdi],rax
    6b29:	mov    r12,rdi
    6b2c:	mov    QWORD PTR [rbx],0x0
    6b33:	mov    QWORD PTR [rbx+0x8],0x0
    6b3b:	mov    QWORD PTR [rbx+0x10],0x0
    6b43:	mov    QWORD PTR [rbx+0x18],0x0
    6b4b:	mov    QWORD PTR [rbx+0x20],0x0
    6b53:	mov    QWORD PTR [rbx+0x28],0x0
    6b5b:	mov    QWORD PTR [rbx+0x30],0x0
    6b63:	mov    QWORD PTR [rbx],rsi
    6b66:	mov    QWORD PTR [rbx+0x8],rdx
    6b6a:	mov    r13,rdx
    6b6d:	mov    rdi,r12
    6b70:	call   6b75 <botlish_fn_55+0x88>
			6b71: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    6b75:	mov    rcx,rax
    6b78:	mov    r14,rax
    6b7b:	test   rax,rcx
    6b7e:	jne    6b8c <botlish_fn_55+0x9f>
    6b84:	mov    rdi,r12
    6b87:	jmp    6cff <botlish_fn_55+0x212>
    6b8c:	mov    rax,r14
    6b8f:	mov    QWORD PTR [rbx],rax
    6b92:	mov    rax,QWORD PTR [rip+0x0]        # 6b99 <botlish_fn_55+0xac>
			6b95: R_X86_64_GOTPCREL	rt_list_len-0x4
    6b99:	mov    rsi,r14
    6b9c:	mov    rdi,r12
    6b9f:	call   rax
    6ba1:	sar    rax,1
    6ba4:	test   rax,rax
    6ba7:	je     6ce1 <botlish_fn_55+0x1f4>
    6bad:	mov    rax,r14
    6bb0:	mov    rdx,QWORD PTR [rax+0x8]
    6bb4:	test   rdx,rdx
    6bb7:	jne    6beb <botlish_fn_55+0xfe>
    6bbd:	mov    edx,0x1
    6bc2:	mov    r8,QWORD PTR [rip+0x0]        # 6bc9 <botlish_fn_55+0xdc>
			6bc5: R_X86_64_GOTPCREL	rt_list_get-0x4
    6bc9:	mov    rsi,r14
    6bcc:	mov    rdi,r12
    6bcf:	call   r8
    6bd2:	test   rax,rax
    6bd5:	jne    6be3 <botlish_fn_55+0xf6>
    6bdb:	mov    rdi,r12
    6bde:	jmp    6cff <botlish_fn_55+0x212>
    6be3:	mov    rsi,rax
    6be6:	jmp    6bf8 <botlish_fn_55+0x10b>
    6beb:	mov    rax,r14
    6bee:	mov    r8,QWORD PTR [rax+0x10]
    6bf2:	mov    r8,QWORD PTR [r8]
    6bf5:	mov    rsi,r8
    6bf8:	mov    QWORD PTR [rbx+0x10],rsi
    6bfc:	mov    QWORD PTR [rbx+0x18],0x3
    6c04:	xor    eax,eax
    6c06:	test   rsi,0x7
    6c0d:	jne    6c1c <botlish_fn_55+0x12f>
    6c13:	movzx  rax,BYTE PTR [rsi]
    6c17:	cmp    al,0x3
    6c19:	sete   al
    6c1c:	test   al,al
    6c1e:	jne    6c45 <botlish_fn_55+0x158>
    6c24:	mov    rdi,r12
    6c27:	mov    rax,QWORD PTR [rdi+0x10]
    6c2b:	mov    rcx,QWORD PTR [rax+0x58]
    6c2f:	mov    edx,0x4
    6c34:	mov    rax,QWORD PTR [rip+0x0]        # 6c3b <botlish_fn_55+0x14e>
			6c37: R_X86_64_GOTPCREL	rt_type_error-0x4
    6c3b:	call   rax
    6c3d:	mov    rdi,r12
    6c40:	jmp    6cff <botlish_fn_55+0x212>
    6c45:	mov    r15,rsi
    6c48:	mov    rax,QWORD PTR [rip+0x0]        # 6c4f <botlish_fn_55+0x162>
			6c4b: R_X86_64_GOTPCREL	rt_list_len-0x4
    6c4f:	mov    rdi,r12
    6c52:	call   rax
    6c54:	mov    QWORD PTR [rbx+0x20],rax
    6c58:	mov    QWORD PTR [rsp+0x10],rax
    6c5d:	mov    rdi,r12
    6c60:	call   6c65 <botlish_fn_55+0x178>
			6c61: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    6c65:	test   rax,rax
    6c68:	jne    6c76 <botlish_fn_55+0x189>
    6c6e:	mov    rdi,r12
    6c71:	jmp    6cff <botlish_fn_55+0x212>
    6c76:	mov    QWORD PTR [rbx+0x28],rax
    6c7a:	mov    r9,rax
    6c7d:	mov    QWORD PTR [rbx+0x30],rdx
    6c81:	mov    rax,rdx
    6c84:	mov    edx,0x3
    6c89:	mov    QWORD PTR [rsp],rax
    6c8d:	mov    rax,r13
    6c90:	mov    QWORD PTR [rsp+0x8],rax
    6c95:	mov    rcx,r15
    6c98:	mov    rsi,r14
    6c9b:	mov    r8,QWORD PTR [rsp+0x10]
    6ca0:	mov    rdi,r12
    6ca3:	call   6ca8 <botlish_fn_55+0x1bb>
			6ca4: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    6ca8:	test   rax,rax
    6cab:	jne    6cb9 <botlish_fn_55+0x1cc>
    6cb1:	mov    rdi,r12
    6cb4:	jmp    6cff <botlish_fn_55+0x212>
    6cb9:	mov    rdi,r12
    6cbc:	mov    QWORD PTR [rdi],rbx
    6cbf:	mov    rbx,QWORD PTR [rsp+0x20]
    6cc4:	mov    r12,QWORD PTR [rsp+0x28]
    6cc9:	mov    r13,QWORD PTR [rsp+0x30]
    6cce:	mov    r14,QWORD PTR [rsp+0x38]
    6cd3:	mov    r15,QWORD PTR [rsp+0x40]
    6cd8:	add    rsp,0x50
    6cdc:	mov    rsp,rbp
    6cdf:	pop    rbp
    6ce0:	ret
    6ce1:	xor    rdx,rdx
    6ce4:	mov    rax,QWORD PTR [rip+0x0]        # 6ceb <botlish_fn_55+0x1fe>
			6ce7: R_X86_64_GOTPCREL	rt_list_new-0x4
    6ceb:	mov    rdi,r12
    6cee:	mov    rsi,rdx
    6cf1:	call   rax
    6cf3:	test   rax,rax
    6cf6:	jne    6d2a <botlish_fn_55+0x23d>
    6cfc:	mov    rdi,r12
    6cff:	mov    rdi,r12
    6d02:	mov    QWORD PTR [rdi],rbx
    6d05:	xor    rax,rax
    6d08:	mov    rbx,QWORD PTR [rsp+0x20]
    6d0d:	mov    r12,QWORD PTR [rsp+0x28]
    6d12:	mov    r13,QWORD PTR [rsp+0x30]
    6d17:	mov    r14,QWORD PTR [rsp+0x38]
    6d1c:	mov    r15,QWORD PTR [rsp+0x40]
    6d21:	add    rsp,0x50
    6d25:	mov    rsp,rbp
    6d28:	pop    rbp
    6d29:	ret
    6d2a:	mov    rdi,r12
    6d2d:	mov    QWORD PTR [rdi],rbx
    6d30:	mov    rbx,QWORD PTR [rsp+0x20]
    6d35:	mov    r12,QWORD PTR [rsp+0x28]
    6d3a:	mov    r13,QWORD PTR [rsp+0x30]
    6d3f:	mov    r14,QWORD PTR [rsp+0x38]
    6d44:	mov    r15,QWORD PTR [rsp+0x40]
    6d49:	add    rsp,0x50
    6d4d:	mov    rsp,rbp
    6d50:	pop    rbp
    6d51:	ret
    6d52:	mov    r12,rdi
    6d55:	mov    rax,QWORD PTR [rip+0x0]        # 6d5c <botlish_fn_55+0x26f>
			6d58: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    6d5c:	call   rax
    6d5e:	xor    rax,rax
    6d61:	mov    rbx,QWORD PTR [rsp+0x20]
    6d66:	mov    r12,QWORD PTR [rsp+0x28]
    6d6b:	mov    r13,QWORD PTR [rsp+0x30]
    6d70:	mov    r14,QWORD PTR [rsp+0x38]
    6d75:	mov    r15,QWORD PTR [rsp+0x40]
    6d7a:	add    rsp,0x50
    6d7e:	mov    rsp,rbp
    6d81:	pop    rbp
    6d82:	ret

0000000000006d83 <botlish_entry_55: csv_records_generic<str, bool>>:
    6d83:	push   rbp
    6d84:	mov    rbp,rsp
    6d87:	mov    rsi,QWORD PTR [rdx]
    6d8a:	mov    rdx,QWORD PTR [rdx+0x8]
    6d8e:	call   6d93 <botlish_entry_55+0x10>
			6d8f: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    6d93:	mov    rsp,rbp
    6d96:	pop    rbp
    6d97:	ret

0000000000006d98 <botlish_fn_56: csv_records<str>>:
    6d98:	push   rbp
    6d99:	mov    rbp,rsp
    6d9c:	sub    rsp,0x10
    6da0:	mov    QWORD PTR [rsp],r14
    6da4:	mov    QWORD PTR [rsp+0x8],r15
    6da9:	mov    r14,QWORD PTR [rdi]
    6dac:	mov    rax,QWORD PTR [rdi+0x8]
    6db0:	lea    rcx,[r14+0x10]
    6db4:	cmp    rcx,rax
    6db7:	ja     6e2a <botlish_fn_56+0x92>
    6dbd:	lea    rax,[r14+0x10]
    6dc1:	mov    QWORD PTR [rdi],rax
    6dc4:	mov    r15,rdi
    6dc7:	mov    QWORD PTR [r14],0x0
    6dce:	mov    QWORD PTR [r14+0x8],0x0
    6dd6:	mov    QWORD PTR [r14],rsi
    6dd9:	mov    edx,0x2
    6dde:	mov    QWORD PTR [r14+0x8],0x2
    6de6:	mov    rdi,r15
    6de9:	call   6dee <botlish_fn_56+0x56>
			6dea: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    6dee:	test   rax,rax
    6df1:	jne    6e12 <botlish_fn_56+0x7a>
    6df7:	mov    rdi,r15
    6dfa:	mov    QWORD PTR [rdi],r14
    6dfd:	xor    rax,rax
    6e00:	mov    r14,QWORD PTR [rsp]
    6e04:	mov    r15,QWORD PTR [rsp+0x8]
    6e09:	add    rsp,0x10
    6e0d:	mov    rsp,rbp
    6e10:	pop    rbp
    6e11:	ret
    6e12:	mov    rdi,r15
    6e15:	mov    QWORD PTR [rdi],r14
    6e18:	mov    r14,QWORD PTR [rsp]
    6e1c:	mov    r15,QWORD PTR [rsp+0x8]
    6e21:	add    rsp,0x10
    6e25:	mov    rsp,rbp
    6e28:	pop    rbp
    6e29:	ret
    6e2a:	mov    rax,QWORD PTR [rip+0x0]        # 6e31 <botlish_fn_56+0x99>
			6e2d: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    6e31:	call   rax
    6e33:	xor    rax,rax
    6e36:	mov    r14,QWORD PTR [rsp]
    6e3a:	mov    r15,QWORD PTR [rsp+0x8]
    6e3f:	add    rsp,0x10
    6e43:	mov    rsp,rbp
    6e46:	pop    rbp
    6e47:	ret

0000000000006e48 <botlish_entry_56: csv_records<str>>:
    6e48:	push   rbp
    6e49:	mov    rbp,rsp
    6e4c:	mov    rsi,QWORD PTR [rdx]
    6e4f:	call   6e54 <botlish_entry_56+0xc>
			6e50: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    6e54:	mov    rsp,rbp
    6e57:	pop    rbp
    6e58:	ret

0000000000006e59 <botlish_fn_57: csv_records_presized<str>>:
    6e59:	push   rbp
    6e5a:	mov    rbp,rsp
    6e5d:	sub    rsp,0x10
    6e61:	mov    QWORD PTR [rsp],r14
    6e65:	mov    QWORD PTR [rsp+0x8],r15
    6e6a:	mov    r14,QWORD PTR [rdi]
    6e6d:	mov    rax,QWORD PTR [rdi+0x8]
    6e71:	lea    rcx,[r14+0x10]
    6e75:	cmp    rcx,rax
    6e78:	ja     6eeb <botlish_fn_57+0x92>
    6e7e:	lea    rax,[r14+0x10]
    6e82:	mov    QWORD PTR [rdi],rax
    6e85:	mov    r15,rdi
    6e88:	mov    QWORD PTR [r14],0x0
    6e8f:	mov    QWORD PTR [r14+0x8],0x0
    6e97:	mov    QWORD PTR [r14],rsi
    6e9a:	mov    edx,0x6
    6e9f:	mov    QWORD PTR [r14+0x8],0x6
    6ea7:	mov    rdi,r15
    6eaa:	call   6eaf <botlish_fn_57+0x56>
			6eab: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    6eaf:	test   rax,rax
    6eb2:	jne    6ed3 <botlish_fn_57+0x7a>
    6eb8:	mov    rdi,r15
    6ebb:	mov    QWORD PTR [rdi],r14
    6ebe:	xor    rax,rax
    6ec1:	mov    r14,QWORD PTR [rsp]
    6ec5:	mov    r15,QWORD PTR [rsp+0x8]
    6eca:	add    rsp,0x10
    6ece:	mov    rsp,rbp
    6ed1:	pop    rbp
    6ed2:	ret
    6ed3:	mov    rdi,r15
    6ed6:	mov    QWORD PTR [rdi],r14
    6ed9:	mov    r14,QWORD PTR [rsp]
    6edd:	mov    r15,QWORD PTR [rsp+0x8]
    6ee2:	add    rsp,0x10
    6ee6:	mov    rsp,rbp
    6ee9:	pop    rbp
    6eea:	ret
    6eeb:	mov    rax,QWORD PTR [rip+0x0]        # 6ef2 <botlish_fn_57+0x99>
			6eee: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    6ef2:	call   rax
    6ef4:	xor    rax,rax
    6ef7:	mov    r14,QWORD PTR [rsp]
    6efb:	mov    r15,QWORD PTR [rsp+0x8]
    6f00:	add    rsp,0x10
    6f04:	mov    rsp,rbp
    6f07:	pop    rbp
    6f08:	ret

0000000000006f09 <botlish_entry_57: csv_records_presized<str>>:
    6f09:	push   rbp
    6f0a:	mov    rbp,rsp
    6f0d:	mov    rsi,QWORD PTR [rdx]
    6f10:	call   6f15 <botlish_entry_57+0xc>
			6f11: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    6f15:	mov    rsp,rbp
    6f18:	pop    rbp
    6f19:	ret
    6f1a:	add    BYTE PTR [rax],al
    6f1c:	add    BYTE PTR [rax],al
	...

0000000000006f20 <botlish_fn_58: sample<generic>>:
    6f20:	push   rbp
    6f21:	mov    rbp,rsp
    6f24:	sub    rsp,0x90
    6f2b:	mov    QWORD PTR [rsp+0x60],rbx
    6f30:	mov    QWORD PTR [rsp+0x68],r12
    6f35:	mov    QWORD PTR [rsp+0x70],r13
    6f3a:	mov    QWORD PTR [rsp+0x78],r14
    6f3f:	mov    QWORD PTR [rsp+0x80],r15
    6f47:	mov    r13,QWORD PTR [rdi]
    6f4a:	mov    rax,QWORD PTR [rdi+0x8]
    6f4e:	lea    rcx,[r13+0x40]
    6f52:	cmp    rcx,rax
    6f55:	ja     741d <botlish_fn_58+0x4fd>
    6f5b:	lea    rax,[r13+0x40]
    6f5f:	mov    QWORD PTR [rdi],rax
    6f62:	mov    QWORD PTR [r13+0x0],0x0
    6f6a:	mov    QWORD PTR [r13+0x8],0x0
    6f72:	mov    QWORD PTR [r13+0x10],0x0
    6f7a:	mov    QWORD PTR [r13+0x18],0x0
    6f82:	mov    QWORD PTR [r13+0x20],0x0
    6f8a:	mov    QWORD PTR [r13+0x28],0x0
    6f92:	mov    QWORD PTR [r13+0x30],0x0
    6f9a:	mov    QWORD PTR [r13+0x38],0x0
    6fa2:	mov    rax,QWORD PTR [rdi+0x10]
    6fa6:	mov    r14,rdi
    6fa9:	mov    rsi,QWORD PTR [rax+0x60]
    6fad:	mov    QWORD PTR [r13+0x0],rsi
    6fb1:	call   6fb6 <botlish_fn_58+0x96>
			6fb2: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    6fb6:	mov    rcx,rax
    6fb9:	mov    r12,rax
    6fbc:	test   rax,rcx
    6fbf:	jne    6fcd <botlish_fn_58+0xad>
    6fc5:	mov    rdi,r14
    6fc8:	jmp    73be <botlish_fn_58+0x49e>
    6fcd:	mov    rax,r12
    6fd0:	mov    QWORD PTR [r13+0x0],rax
    6fd4:	mov    rdi,r14
    6fd7:	mov    rax,QWORD PTR [rdi+0x10]
    6fdb:	mov    rsi,QWORD PTR [rax+0x60]
    6fdf:	mov    QWORD PTR [r13+0x8],rsi
    6fe3:	call   6fe8 <botlish_fn_58+0xc8>
			6fe4: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    6fe8:	mov    r15,rax
    6feb:	test   r15,r15
    6fee:	jne    6ffc <botlish_fn_58+0xdc>
    6ff4:	mov    rdi,r14
    6ff7:	jmp    73be <botlish_fn_58+0x49e>
    6ffc:	mov    rax,r12
    6fff:	mov    rax,QWORD PTR [rax+0x8]
    7003:	test   rax,rax
    7006:	jne    703c <botlish_fn_58+0x11c>
    700c:	mov    edx,0x1
    7011:	mov    rax,QWORD PTR [rip+0x0]        # 7018 <botlish_fn_58+0xf8>
			7014: R_X86_64_GOTPCREL	rt_list_get-0x4
    7018:	mov    rsi,r12
    701b:	mov    rdi,r14
    701e:	call   rax
    7020:	test   rax,rax
    7023:	jne    7031 <botlish_fn_58+0x111>
    7029:	mov    rdi,r14
    702c:	jmp    73be <botlish_fn_58+0x49e>
    7031:	mov    rbx,r12
    7034:	mov    rsi,rax
    7037:	jmp    7046 <botlish_fn_58+0x126>
    703c:	mov    rbx,r12
    703f:	mov    rax,QWORD PTR [rbx+0x10]
    7043:	mov    rsi,QWORD PTR [rax]
    7046:	mov    QWORD PTR [r13+0x8],rsi
    704a:	mov    QWORD PTR [rsp+0x40],rsi
    704f:	mov    rax,QWORD PTR [rbx+0x8]
    7053:	cmp    rax,0x1
    7057:	ja     708d <botlish_fn_58+0x16d>
    705d:	mov    edx,0x3
    7062:	mov    rax,QWORD PTR [rip+0x0]        # 7069 <botlish_fn_58+0x149>
			7065: R_X86_64_GOTPCREL	rt_list_get-0x4
    7069:	mov    rsi,rbx
    706c:	mov    rdi,r14
    706f:	call   rax
    7071:	test   rax,rax
    7074:	jne    7082 <botlish_fn_58+0x162>
    707a:	mov    rdi,r14
    707d:	jmp    73be <botlish_fn_58+0x49e>
    7082:	mov    rsi,rax
    7085:	mov    r12,rbx
    7088:	jmp    7098 <botlish_fn_58+0x178>
    708d:	mov    rax,QWORD PTR [rbx+0x10]
    7091:	mov    r12,rbx
    7094:	mov    rsi,QWORD PTR [rax+0x8]
    7098:	mov    QWORD PTR [r13+0x10],rsi
    709c:	mov    QWORD PTR [rsp+0x38],rsi
    70a1:	mov    rax,QWORD PTR [r15+0x8]
    70a5:	mov    rsi,r15
    70a8:	test   rax,rax
    70ab:	jne    70db <botlish_fn_58+0x1bb>
    70b1:	mov    edx,0x1
    70b6:	mov    rcx,QWORD PTR [rip+0x0]        # 70bd <botlish_fn_58+0x19d>
			70b9: R_X86_64_GOTPCREL	rt_list_get-0x4
    70bd:	mov    rdi,r14
    70c0:	call   rcx
    70c2:	test   rax,rax
    70c5:	jne    70d3 <botlish_fn_58+0x1b3>
    70cb:	mov    rdi,r14
    70ce:	jmp    73be <botlish_fn_58+0x49e>
    70d3:	mov    rsi,rax
    70d6:	jmp    70e2 <botlish_fn_58+0x1c2>
    70db:	mov    rsi,QWORD PTR [rsi+0x10]
    70df:	mov    rsi,QWORD PTR [rsi]
    70e2:	mov    QWORD PTR [r13+0x18],rsi
    70e6:	mov    rdi,r14
    70e9:	mov    r15,rsi
    70ec:	mov    rdi,QWORD PTR [rdi+0x10]
    70f0:	mov    rdx,QWORD PTR [rdi+0x68]
    70f4:	mov    QWORD PTR [r13+0x20],rdx
    70f8:	mov    rsi,QWORD PTR [rsp+0x40]
    70fd:	mov    rdi,r14
    7100:	call   7105 <botlish_fn_58+0x1e5>
			7101: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    7105:	test   rax,rax
    7108:	jne    7116 <botlish_fn_58+0x1f6>
    710e:	mov    rdi,r14
    7111:	jmp    73be <botlish_fn_58+0x49e>
    7116:	mov    QWORD PTR [r13+0x20],rax
    711a:	mov    rbx,rax
    711d:	mov    rdi,r14
    7120:	mov    rax,QWORD PTR [rdi+0x10]
    7124:	mov    rdx,QWORD PTR [rax+0x68]
    7128:	mov    QWORD PTR [r13+0x28],rdx
    712c:	mov    rsi,r15
    712f:	call   7134 <botlish_fn_58+0x214>
			7130: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    7134:	test   rax,rax
    7137:	jne    7145 <botlish_fn_58+0x225>
    713d:	mov    rdi,r14
    7140:	jmp    73be <botlish_fn_58+0x49e>
    7145:	mov    rcx,rbx
    7148:	mov    rdx,rcx
    714b:	and    rdx,rax
    714e:	mov    rcx,rax
    7151:	test   rdx,0x1
    7158:	jne    7181 <botlish_fn_58+0x261>
    715e:	mov    rax,QWORD PTR [rip+0x0]        # 7165 <botlish_fn_58+0x245>
			7161: R_X86_64_GOTPCREL	rt_value_eq-0x4
    7165:	mov    rdx,rcx
    7168:	mov    rsi,rbx
    716b:	mov    rdi,r14
    716e:	call   rax
    7170:	test   rax,rax
    7173:	jne    7197 <botlish_fn_58+0x277>
    7179:	mov    rdi,r14
    717c:	jmp    73be <botlish_fn_58+0x49e>
    7181:	mov    rdx,rcx
    7184:	mov    rsi,rbx
    7187:	mov    eax,0x2
    718c:	cmp    rsi,rdx
    718f:	cmove  rax,QWORD PTR [rip+0x2c1]        # 7458 <botlish_fn_58+0x538>
    7197:	mov    ebx,0x6
    719c:	cmp    rax,0x6
    71a0:	je     71b8 <botlish_fn_58+0x298>
    71a6:	mov    ebx,0x2
    71ab:	mov    QWORD PTR [r13+0x0],0x2
    71b3:	jmp    7258 <botlish_fn_58+0x338>
    71b8:	mov    rsi,QWORD PTR [rsp+0x40]
    71bd:	mov    rdi,r14
    71c0:	call   71c5 <botlish_fn_58+0x2a5>
			71c1: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    71c5:	test   rax,rax
    71c8:	jne    71d6 <botlish_fn_58+0x2b6>
    71ce:	mov    rdi,r14
    71d1:	jmp    73be <botlish_fn_58+0x49e>
    71d6:	mov    QWORD PTR [r13+0x20],rax
    71da:	mov    rsi,r15
    71dd:	mov    r15,rax
    71e0:	mov    rdi,r14
    71e3:	call   71e8 <botlish_fn_58+0x2c8>
			71e4: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    71e8:	test   rax,rax
    71eb:	jne    71f9 <botlish_fn_58+0x2d9>
    71f1:	mov    rdi,r14
    71f4:	jmp    73be <botlish_fn_58+0x49e>
    71f9:	mov    rsi,r15
    71fc:	mov    rcx,rsi
    71ff:	and    rcx,rax
    7202:	mov    rdx,rax
    7205:	test   rcx,0x1
    720c:	jne    7232 <botlish_fn_58+0x312>
    7212:	mov    rax,QWORD PTR [rip+0x0]        # 7219 <botlish_fn_58+0x2f9>
			7215: R_X86_64_GOTPCREL	rt_value_eq-0x4
    7219:	mov    rsi,r15
    721c:	mov    rdi,r14
    721f:	call   rax
    7221:	test   rax,rax
    7224:	jne    7245 <botlish_fn_58+0x325>
    722a:	mov    rdi,r14
    722d:	jmp    73be <botlish_fn_58+0x49e>
    7232:	mov    rsi,r15
    7235:	mov    eax,0x2
    723a:	cmp    rsi,rdx
    723d:	cmove  rax,QWORD PTR [rip+0x213]        # 7458 <botlish_fn_58+0x538>
    7245:	cmp    rax,0x6
    7249:	je     7254 <botlish_fn_58+0x334>
    724f:	mov    ebx,0x2
    7254:	mov    QWORD PTR [r13+0x0],rbx
    7258:	mov    rax,QWORD PTR [rip+0x0]        # 725f <botlish_fn_58+0x33f>
			725b: R_X86_64_GOTPCREL	rt_list_len-0x4
    725f:	mov    rsi,r12
    7262:	mov    rdi,r14
    7265:	call   rax
    7267:	mov    r12,rax
    726a:	mov    QWORD PTR [r13+0x18],r12
    726e:	mov    rdi,r14
    7271:	mov    rax,QWORD PTR [rdi+0x10]
    7275:	mov    rdx,QWORD PTR [rax+0x68]
    7279:	mov    QWORD PTR [r13+0x20],rdx
    727d:	mov    rsi,QWORD PTR [rsp+0x40]
    7282:	call   7287 <botlish_fn_58+0x367>
			7283: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    7287:	test   rax,rax
    728a:	jne    7298 <botlish_fn_58+0x378>
    7290:	mov    rdi,r14
    7293:	jmp    73be <botlish_fn_58+0x49e>
    7298:	mov    QWORD PTR [r13+0x20],rax
    729c:	mov    rdi,r14
    729f:	mov    r15,rax
    72a2:	mov    rax,QWORD PTR [rdi+0x10]
    72a6:	mov    rdx,QWORD PTR [rax+0x70]
    72aa:	mov    QWORD PTR [r13+0x28],rdx
    72ae:	mov    rsi,QWORD PTR [rsp+0x40]
    72b3:	call   72b8 <botlish_fn_58+0x398>
			72b4: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    72b8:	test   rax,rax
    72bb:	jne    72c9 <botlish_fn_58+0x3a9>
    72c1:	mov    rdi,r14
    72c4:	jmp    73be <botlish_fn_58+0x49e>
    72c9:	mov    QWORD PTR [r13+0x28],rax
    72cd:	mov    rdi,r14
    72d0:	mov    QWORD PTR [rsp+0x50],rax
    72d5:	mov    rax,QWORD PTR [rdi+0x10]
    72d9:	mov    rdx,QWORD PTR [rax+0x78]
    72dd:	mov    QWORD PTR [r13+0x30],rdx
    72e1:	mov    rsi,QWORD PTR [rsp+0x40]
    72e6:	call   72eb <botlish_fn_58+0x3cb>
			72e7: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    72eb:	test   rax,rax
    72ee:	jne    72fc <botlish_fn_58+0x3dc>
    72f4:	mov    rdi,r14
    72f7:	jmp    73be <botlish_fn_58+0x49e>
    72fc:	mov    QWORD PTR [r13+0x8],rax
    7300:	mov    rdi,r14
    7303:	mov    QWORD PTR [rsp+0x48],rax
    7308:	mov    rdx,QWORD PTR [rdi+0x10]
    730c:	mov    rdx,QWORD PTR [rdx+0x68]
    7310:	mov    QWORD PTR [r13+0x30],rdx
    7314:	mov    rsi,QWORD PTR [rsp+0x38]
    7319:	call   731e <botlish_fn_58+0x3fe>
			731a: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    731e:	test   rax,rax
    7321:	jne    732f <botlish_fn_58+0x40f>
    7327:	mov    rdi,r14
    732a:	jmp    73be <botlish_fn_58+0x49e>
    732f:	mov    QWORD PTR [r13+0x30],rax
    7333:	mov    rdi,r14
    7336:	mov    QWORD PTR [rsp+0x40],rax
    733b:	mov    rdi,QWORD PTR [rdi+0x10]
    733f:	mov    rdx,QWORD PTR [rdi+0x78]
    7343:	mov    QWORD PTR [r13+0x38],rdx
    7347:	mov    rsi,QWORD PTR [rsp+0x38]
    734c:	mov    rdi,r14
    734f:	call   7354 <botlish_fn_58+0x434>
			7350: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    7354:	test   rax,rax
    7357:	jne    7365 <botlish_fn_58+0x445>
    735d:	mov    rdi,r14
    7360:	jmp    73be <botlish_fn_58+0x49e>
    7365:	mov    QWORD PTR [r13+0x10],rax
    7369:	lea    rdx,[rsp]
    736d:	mov    QWORD PTR [rsp],r12
    7371:	mov    rcx,r15
    7374:	mov    QWORD PTR [rsp+0x8],rcx
    7379:	mov    rcx,QWORD PTR [rsp+0x50]
    737e:	mov    QWORD PTR [rsp+0x10],rcx
    7383:	mov    rcx,QWORD PTR [rsp+0x48]
    7388:	mov    QWORD PTR [rsp+0x18],rcx
    738d:	mov    rcx,QWORD PTR [rsp+0x40]
    7392:	mov    QWORD PTR [rsp+0x20],rcx
    7397:	mov    QWORD PTR [rsp+0x28],rax
    739c:	mov    QWORD PTR [rsp+0x30],rbx
    73a1:	mov    esi,0x7
    73a6:	mov    rax,QWORD PTR [rip+0x0]        # 73ad <botlish_fn_58+0x48d>
			73a9: R_X86_64_GOTPCREL	rt_list_new-0x4
    73ad:	mov    rdi,r14
    73b0:	call   rax
    73b2:	test   rax,rax
    73b5:	jne    73ef <botlish_fn_58+0x4cf>
    73bb:	mov    rdi,r14
    73be:	mov    rdi,r14
    73c1:	mov    QWORD PTR [rdi],r13
    73c4:	xor    rax,rax
    73c7:	mov    rbx,QWORD PTR [rsp+0x60]
    73cc:	mov    r12,QWORD PTR [rsp+0x68]
    73d1:	mov    r13,QWORD PTR [rsp+0x70]
    73d6:	mov    r14,QWORD PTR [rsp+0x78]
    73db:	mov    r15,QWORD PTR [rsp+0x80]
    73e3:	add    rsp,0x90
    73ea:	mov    rsp,rbp
    73ed:	pop    rbp
    73ee:	ret
    73ef:	mov    rdi,r14
    73f2:	mov    QWORD PTR [rdi],r13
    73f5:	mov    rbx,QWORD PTR [rsp+0x60]
    73fa:	mov    r12,QWORD PTR [rsp+0x68]
    73ff:	mov    r13,QWORD PTR [rsp+0x70]
    7404:	mov    r14,QWORD PTR [rsp+0x78]
    7409:	mov    r15,QWORD PTR [rsp+0x80]
    7411:	add    rsp,0x90
    7418:	mov    rsp,rbp
    741b:	pop    rbp
    741c:	ret
    741d:	mov    r14,rdi
    7420:	mov    rax,QWORD PTR [rip+0x0]        # 7427 <botlish_fn_58+0x507>
			7423: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    7427:	call   rax
    7429:	xor    rax,rax
    742c:	mov    rbx,QWORD PTR [rsp+0x60]
    7431:	mov    r12,QWORD PTR [rsp+0x68]
    7436:	mov    r13,QWORD PTR [rsp+0x70]
    743b:	mov    r14,QWORD PTR [rsp+0x78]
    7440:	mov    r15,QWORD PTR [rsp+0x80]
    7448:	add    rsp,0x90
    744f:	mov    rsp,rbp
    7452:	pop    rbp
    7453:	ret
    7454:	add    BYTE PTR [rax],al
    7456:	add    BYTE PTR [rax],al
    7458:	(bad)
    7459:	add    BYTE PTR [rax],al
    745b:	add    BYTE PTR [rax],al
    745d:	add    BYTE PTR [rax],al
	...

0000000000007460 <botlish_entry_58: sample<generic>>:
    7460:	push   rbp
    7461:	mov    rbp,rsp
    7464:	call   7469 <botlish_entry_58+0x9>
			7465: R_X86_64_PLT32	botlish_fn_58-0x4 ; sample<generic>
    7469:	mov    rsp,rbp
    746c:	pop    rbp
    746d:	ret

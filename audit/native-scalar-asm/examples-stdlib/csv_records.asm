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
      14:	mov    r11,QWORD PTR [rdi+0x8]
      18:	lea    rax,[r12+0x8]
      1d:	cmp    rax,r11
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
      7d:	call   82 <botlish_fn_0+0x82>
			7e: R_X86_64_PLT32	rt_stack_overflow-0x4
      82:	xor    rax,rax
      85:	mov    r12,QWORD PTR [rsp]
      89:	mov    r13,QWORD PTR [rsp+0x8]
      8e:	add    rsp,0x10
      92:	mov    rsp,rbp
      95:	pop    rbp
      96:	ret

0000000000000097 <botlish_entry_0: <program entry>>:
      97:	push   rbp
      98:	mov    rbp,rsp
      9b:	call   a0 <botlish_entry_0+0x9>
			9c: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      a0:	mov    rsp,rbp
      a3:	pop    rbp
      a4:	ret

00000000000000a5 <botlish_fn_1: geo_new<generic>>:
      a5:	push   rbp
      a6:	mov    rbp,rsp
      a9:	sub    rsp,0x10
      ad:	mov    QWORD PTR [rsp],r13
      b1:	mov    QWORD PTR [rsp+0x8],r14
      b6:	mov    r13,QWORD PTR [rdi]
      b9:	mov    rax,QWORD PTR [rdi+0x8]
      bd:	lea    rcx,[r13+0x8]
      c1:	cmp    rcx,rax
      c4:	ja     12d <botlish_fn_1+0x88>
      ca:	lea    rax,[r13+0x8]
      ce:	mov    QWORD PTR [rdi],rax
      d1:	mov    r14,rdi
      d4:	mov    esi,0x1
      d9:	mov    QWORD PTR [r13+0x0],0x1
      e1:	mov    rdi,r14
      e4:	call   e9 <botlish_fn_1+0x44>
			e5: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      e9:	test   rax,rax
      ec:	jne    110 <botlish_fn_1+0x6b>
      f2:	mov    rdi,r14
      f5:	mov    QWORD PTR [rdi],r13
      f8:	xor    rdx,rdx
      fb:	mov    rax,rdx
      fe:	mov    r13,QWORD PTR [rsp]
     102:	mov    r14,QWORD PTR [rsp+0x8]
     107:	add    rsp,0x10
     10b:	mov    rsp,rbp
     10e:	pop    rbp
     10f:	ret
     110:	mov    rdi,r14
     113:	mov    QWORD PTR [rdi],r13
     116:	mov    edx,0x1
     11b:	mov    r13,QWORD PTR [rsp]
     11f:	mov    r14,QWORD PTR [rsp+0x8]
     124:	add    rsp,0x10
     128:	mov    rsp,rbp
     12b:	pop    rbp
     12c:	ret
     12d:	call   132 <botlish_fn_1+0x8d>
			12e: R_X86_64_PLT32	rt_stack_overflow-0x4
     132:	xor    rdx,rdx
     135:	mov    rax,rdx
     138:	mov    r13,QWORD PTR [rsp]
     13c:	mov    r14,QWORD PTR [rsp+0x8]
     141:	add    rsp,0x10
     145:	mov    rsp,rbp
     148:	pop    rbp
     149:	ret

000000000000014a <botlish_entry_1: geo_new<generic>>:
     14a:	push   rbp
     14b:	mov    rbp,rsp
     14e:	ud2

0000000000000150 <botlish_fn_2: geo_new_capacity<int, int>>:
     150:	push   rbp
     151:	mov    rbp,rsp
     154:	sub    rsp,0x20
     158:	mov    QWORD PTR [rsp],rbx
     15c:	mov    QWORD PTR [rsp+0x8],r12
     161:	mov    QWORD PTR [rsp+0x10],r13
     166:	mov    QWORD PTR [rsp+0x18],r14
     16b:	mov    rbx,QWORD PTR [rdi]
     16e:	mov    rax,QWORD PTR [rdi+0x8]
     172:	lea    rcx,[rbx+0x18]
     176:	cmp    rcx,rax
     179:	ja     2c6 <botlish_fn_2+0x176>
     17f:	lea    rax,[rbx+0x18]
     183:	mov    QWORD PTR [rdi],rax
     186:	mov    r13,rdi
     189:	mov    QWORD PTR [rbx],0x0
     190:	mov    QWORD PTR [rbx+0x8],0x0
     198:	mov    QWORD PTR [rbx+0x10],0x0
     1a0:	mov    QWORD PTR [rbx],rsi
     1a3:	mov    QWORD PTR [rbx+0x8],rdx
     1a7:	mov    r12,rdx
     1aa:	mov    QWORD PTR [rbx+0x10],0x5
     1b2:	test   rsi,0x1
     1b9:	je     1db <botlish_fn_2+0x8b>
     1bf:	mov    rax,rsi
     1c2:	sar    rax,1
     1c5:	imul   QWORD PTR [rip+0x124]        # 2f0 <botlish_fn_2+0x1a0>
     1cc:	seto   cl
     1cf:	or     rax,0x1
     1d3:	test   cl,cl
     1d5:	je     1e8 <botlish_fn_2+0x98>
     1db:	mov    edx,0x5
     1e0:	mov    rdi,r13
     1e3:	call   1e8 <botlish_fn_2+0x98>
			1e4: R_X86_64_PLT32	rt_int_mul-0x4
     1e8:	mov    rcx,rax
     1eb:	and    rcx,r12
     1ee:	mov    r14,rax
     1f1:	test   rcx,0x1
     1f8:	jne    224 <botlish_fn_2+0xd4>
     1fe:	mov    rdx,r12
     201:	mov    rsi,r14
     204:	mov    rdi,r13
     207:	call   20c <botlish_fn_2+0xbc>
			208: R_X86_64_PLT32	rt_int_cmp-0x4
     20c:	mov    ecx,0x2
     211:	test   rax,rax
     214:	cmovle rcx,QWORD PTR [rip+0xdc]        # 2f8 <botlish_fn_2+0x1a8>
     21c:	mov    rax,r14
     21f:	jmp    237 <botlish_fn_2+0xe7>
     224:	mov    ecx,0x2
     229:	mov    rax,r14
     22c:	cmp    rax,r12
     22f:	cmovle rcx,QWORD PTR [rip+0xc1]        # 2f8 <botlish_fn_2+0x1a8>
     237:	cmp    rcx,0x6
     23b:	je     263 <botlish_fn_2+0x113>
     241:	mov    rdi,r13
     244:	mov    QWORD PTR [rdi],rbx
     247:	mov    rbx,QWORD PTR [rsp]
     24b:	mov    r12,QWORD PTR [rsp+0x8]
     250:	mov    r13,QWORD PTR [rsp+0x10]
     255:	mov    r14,QWORD PTR [rsp+0x18]
     25a:	add    rsp,0x20
     25e:	mov    rsp,rbp
     261:	pop    rbp
     262:	ret
     263:	mov    QWORD PTR [rbx],0x3
     26a:	test   r12,0x1
     271:	je     291 <botlish_fn_2+0x141>
     277:	mov    rax,r12
     27a:	add    rax,0x2
     27e:	seto   cl
     281:	test   cl,cl
     283:	jne    291 <botlish_fn_2+0x141>
     289:	mov    rdi,r13
     28c:	jmp    2a4 <botlish_fn_2+0x154>
     291:	mov    edx,0x3
     296:	mov    rsi,r12
     299:	mov    rdi,r13
     29c:	call   2a1 <botlish_fn_2+0x151>
			29d: R_X86_64_PLT32	rt_int_add-0x4
     2a1:	mov    rdi,r13
     2a4:	mov    rdi,r13
     2a7:	mov    QWORD PTR [rdi],rbx
     2aa:	mov    rbx,QWORD PTR [rsp]
     2ae:	mov    r12,QWORD PTR [rsp+0x8]
     2b3:	mov    r13,QWORD PTR [rsp+0x10]
     2b8:	mov    r14,QWORD PTR [rsp+0x18]
     2bd:	add    rsp,0x20
     2c1:	mov    rsp,rbp
     2c4:	pop    rbp
     2c5:	ret
     2c6:	mov    r13,rdi
     2c9:	call   2ce <botlish_fn_2+0x17e>
			2ca: R_X86_64_PLT32	rt_stack_overflow-0x4
     2ce:	xor    rax,rax
     2d1:	mov    rbx,QWORD PTR [rsp]
     2d5:	mov    r12,QWORD PTR [rsp+0x8]
     2da:	mov    r13,QWORD PTR [rsp+0x10]
     2df:	mov    r14,QWORD PTR [rsp+0x18]
     2e4:	add    rsp,0x20
     2e8:	mov    rsp,rbp
     2eb:	pop    rbp
     2ec:	ret
     2ed:	add    BYTE PTR [rax],al
     2ef:	add    BYTE PTR [rax+rax*1],al
     2f2:	add    BYTE PTR [rax],al
     2f4:	add    BYTE PTR [rax],al
     2f6:	add    BYTE PTR [rax],al
     2f8:	(bad)
     2f9:	add    BYTE PTR [rax],al
     2fb:	add    BYTE PTR [rax],al
     2fd:	add    BYTE PTR [rax],al
	...

0000000000000300 <botlish_entry_2: geo_new_capacity<int, int>>:
     300:	push   rbp
     301:	mov    rbp,rsp
     304:	mov    rsi,QWORD PTR [rdx]
     307:	mov    rdx,QWORD PTR [rdx+0x8]
     30b:	call   310 <botlish_entry_2+0x10>
			30c: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     310:	mov    rsp,rbp
     313:	pop    rbp
     314:	ret
     315:	add    BYTE PTR [rax],al
	...

0000000000000318 <botlish_fn_3: geo_grow<mutarray, int>>:
     318:	push   rbp
     319:	mov    rbp,rsp
     31c:	sub    rsp,0x30
     320:	mov    QWORD PTR [rsp],rbx
     324:	mov    QWORD PTR [rsp+0x8],r12
     329:	mov    QWORD PTR [rsp+0x10],r13
     32e:	mov    QWORD PTR [rsp+0x18],r14
     333:	mov    QWORD PTR [rsp+0x20],r15
     338:	mov    rbx,QWORD PTR [rdi]
     33b:	mov    rax,QWORD PTR [rdi+0x8]
     33f:	lea    rcx,[rbx+0x18]
     343:	cmp    rcx,rax
     346:	ja     4c8 <botlish_fn_3+0x1b0>
     34c:	lea    rax,[rbx+0x18]
     350:	mov    QWORD PTR [rdi],rax
     353:	mov    r13,rdi
     356:	mov    QWORD PTR [rbx],0x0
     35d:	mov    QWORD PTR [rbx+0x8],0x0
     365:	mov    QWORD PTR [rbx+0x10],0x0
     36d:	mov    QWORD PTR [rbx],rsi
     370:	mov    r14,rsi
     373:	mov    QWORD PTR [rbx+0x8],rdx
     377:	mov    r12,rdx
     37a:	mov    rsi,r14
     37d:	mov    rdi,r13
     380:	call   385 <botlish_fn_3+0x6d>
			381: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     385:	mov    r15,rax
     388:	mov    QWORD PTR [rbx+0x10],rax
     38c:	mov    rcx,r12
     38f:	and    rcx,rax
     392:	test   rcx,0x1
     399:	jne    3c5 <botlish_fn_3+0xad>
     39f:	mov    rdx,r15
     3a2:	mov    rsi,r12
     3a5:	mov    rdi,r13
     3a8:	call   3ad <botlish_fn_3+0x95>
			3a9: R_X86_64_PLT32	rt_int_cmp-0x4
     3ad:	mov    ecx,0x2
     3b2:	test   rax,rax
     3b5:	cmovl  rcx,QWORD PTR [rip+0x13b]        # 4f8 <botlish_fn_3+0x1e0>
     3bd:	mov    rax,r15
     3c0:	jmp    3d8 <botlish_fn_3+0xc0>
     3c5:	mov    ecx,0x2
     3ca:	mov    rax,r15
     3cd:	cmp    r12,rax
     3d0:	cmovl  rcx,QWORD PTR [rip+0x120]        # 4f8 <botlish_fn_3+0x1e0>
     3d8:	cmp    rcx,0x6
     3dc:	je     49e <botlish_fn_3+0x186>
     3e2:	mov    rsi,rax
     3e5:	mov    rdx,r12
     3e8:	mov    rdi,r13
     3eb:	call   3f0 <botlish_fn_3+0xd8>
			3ec: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     3f0:	test   rax,rax
     3f3:	jne    401 <botlish_fn_3+0xe9>
     3f9:	mov    rdi,r13
     3fc:	jmp    44a <botlish_fn_3+0x132>
     401:	mov    QWORD PTR [rbx+0x10],rax
     405:	mov    rsi,rax
     408:	mov    rdi,r13
     40b:	call   410 <botlish_fn_3+0xf8>
			40c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     410:	test   rax,rax
     413:	mov    r15,rax
     416:	jne    424 <botlish_fn_3+0x10c>
     41c:	mov    rdi,r13
     41f:	jmp    44a <botlish_fn_3+0x132>
     424:	mov    r8d,0x1
     42a:	mov    rcx,r14
     42d:	mov    r9,r12
     430:	mov    rsi,r15
     433:	mov    rdi,r13
     436:	mov    rdx,r8
     439:	call   43e <botlish_fn_3+0x126>
			43a: R_X86_64_PLT32	rt_mutarray_copy-0x4
     43e:	test   rax,rax
     441:	jne    474 <botlish_fn_3+0x15c>
     447:	mov    rdi,r13
     44a:	mov    rdi,r13
     44d:	mov    QWORD PTR [rdi],rbx
     450:	xor    rax,rax
     453:	mov    rbx,QWORD PTR [rsp]
     457:	mov    r12,QWORD PTR [rsp+0x8]
     45c:	mov    r13,QWORD PTR [rsp+0x10]
     461:	mov    r14,QWORD PTR [rsp+0x18]
     466:	mov    r15,QWORD PTR [rsp+0x20]
     46b:	add    rsp,0x30
     46f:	mov    rsp,rbp
     472:	pop    rbp
     473:	ret
     474:	mov    rdi,r13
     477:	mov    QWORD PTR [rdi],rbx
     47a:	mov    rax,r15
     47d:	mov    rbx,QWORD PTR [rsp]
     481:	mov    r12,QWORD PTR [rsp+0x8]
     486:	mov    r13,QWORD PTR [rsp+0x10]
     48b:	mov    r14,QWORD PTR [rsp+0x18]
     490:	mov    r15,QWORD PTR [rsp+0x20]
     495:	add    rsp,0x30
     499:	mov    rsp,rbp
     49c:	pop    rbp
     49d:	ret
     49e:	mov    rdi,r13
     4a1:	mov    QWORD PTR [rdi],rbx
     4a4:	mov    rax,r14
     4a7:	mov    rbx,QWORD PTR [rsp]
     4ab:	mov    r12,QWORD PTR [rsp+0x8]
     4b0:	mov    r13,QWORD PTR [rsp+0x10]
     4b5:	mov    r14,QWORD PTR [rsp+0x18]
     4ba:	mov    r15,QWORD PTR [rsp+0x20]
     4bf:	add    rsp,0x30
     4c3:	mov    rsp,rbp
     4c6:	pop    rbp
     4c7:	ret
     4c8:	mov    r13,rdi
     4cb:	call   4d0 <botlish_fn_3+0x1b8>
			4cc: R_X86_64_PLT32	rt_stack_overflow-0x4
     4d0:	xor    rax,rax
     4d3:	mov    rbx,QWORD PTR [rsp]
     4d7:	mov    r12,QWORD PTR [rsp+0x8]
     4dc:	mov    r13,QWORD PTR [rsp+0x10]
     4e1:	mov    r14,QWORD PTR [rsp+0x18]
     4e6:	mov    r15,QWORD PTR [rsp+0x20]
     4eb:	add    rsp,0x30
     4ef:	mov    rsp,rbp
     4f2:	pop    rbp
     4f3:	ret
     4f4:	add    BYTE PTR [rax],al
     4f6:	add    BYTE PTR [rax],al
     4f8:	(bad)
     4f9:	add    BYTE PTR [rax],al
     4fb:	add    BYTE PTR [rax],al
     4fd:	add    BYTE PTR [rax],al
	...

0000000000000500 <botlish_entry_3: geo_grow<mutarray, int>>:
     500:	push   rbp
     501:	mov    rbp,rsp
     504:	mov    rsi,QWORD PTR [rdx]
     507:	mov    rdx,QWORD PTR [rdx+0x8]
     50b:	call   510 <botlish_entry_3+0x10>
			50c: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     510:	mov    rsp,rbp
     513:	pop    rbp
     514:	ret

0000000000000515 <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     515:	push   rbp
     516:	mov    rbp,rsp
     519:	sub    rsp,0x30
     51d:	mov    QWORD PTR [rsp],rbx
     521:	mov    QWORD PTR [rsp+0x8],r12
     526:	mov    QWORD PTR [rsp+0x10],r13
     52b:	mov    QWORD PTR [rsp+0x18],r14
     530:	mov    QWORD PTR [rsp+0x20],r15
     535:	mov    r12,QWORD PTR [rdi]
     538:	mov    r8,QWORD PTR [rdi+0x8]
     53c:	lea    rax,[r12+0x18]
     541:	cmp    rax,r8
     544:	ja     671 <botlish_fn_4+0x15c>
     54a:	lea    rax,[r12+0x18]
     54f:	mov    QWORD PTR [rdi],rax
     552:	mov    r13,rdi
     555:	mov    QWORD PTR [r12],0x0
     55d:	mov    QWORD PTR [r12+0x8],0x0
     566:	mov    QWORD PTR [r12+0x10],0x0
     56f:	mov    QWORD PTR [r12],rsi
     573:	mov    QWORD PTR [r12+0x8],rdx
     578:	mov    rdi,rdx
     57b:	mov    QWORD PTR [r12+0x10],rcx
     580:	mov    r15,rcx
     583:	mov    rbx,rdi
     586:	mov    rdx,rbx
     589:	mov    rdi,r13
     58c:	call   591 <botlish_fn_4+0x7c>
			58d: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     591:	test   rax,rax
     594:	mov    r14,rax
     597:	jne    5a5 <botlish_fn_4+0x90>
     59d:	mov    rdi,r13
     5a0:	jmp    5c9 <botlish_fn_4+0xb4>
     5a5:	mov    rax,r14
     5a8:	mov    QWORD PTR [r12],rax
     5ac:	mov    rcx,r15
     5af:	mov    rdx,rbx
     5b2:	mov    rsi,r14
     5b5:	mov    rdi,r13
     5b8:	call   5bd <botlish_fn_4+0xa8>
			5b9: R_X86_64_PLT32	rt_mutarray_set-0x4
     5bd:	test   rax,rax
     5c0:	jne    5f6 <botlish_fn_4+0xe1>
     5c6:	mov    rdi,r13
     5c9:	mov    rdi,r13
     5cc:	mov    QWORD PTR [rdi],r12
     5cf:	xor    rdx,rdx
     5d2:	mov    rax,rdx
     5d5:	mov    rbx,QWORD PTR [rsp]
     5d9:	mov    r12,QWORD PTR [rsp+0x8]
     5de:	mov    r13,QWORD PTR [rsp+0x10]
     5e3:	mov    r14,QWORD PTR [rsp+0x18]
     5e8:	mov    r15,QWORD PTR [rsp+0x20]
     5ed:	add    rsp,0x30
     5f1:	mov    rsp,rbp
     5f4:	pop    rbp
     5f5:	ret
     5f6:	mov    QWORD PTR [r12+0x10],0x3
     5ff:	test   rbx,0x1
     606:	jne    614 <botlish_fn_4+0xff>
     60c:	mov    rdi,rbx
     60f:	jmp    631 <botlish_fn_4+0x11c>
     614:	mov    rdx,rbx
     617:	add    rdx,0x2
     61b:	mov    rdi,rbx
     61e:	seto   al
     621:	test   al,al
     623:	jne    631 <botlish_fn_4+0x11c>
     629:	mov    rdi,r13
     62c:	jmp    647 <botlish_fn_4+0x132>
     631:	mov    edx,0x3
     636:	mov    rsi,rdi
     639:	mov    rdi,r13
     63c:	call   641 <botlish_fn_4+0x12c>
			63d: R_X86_64_PLT32	rt_int_add-0x4
     641:	mov    rdx,rax
     644:	mov    rdi,r13
     647:	mov    rdi,r13
     64a:	mov    QWORD PTR [rdi],r12
     64d:	mov    rax,r14
     650:	mov    rbx,QWORD PTR [rsp]
     654:	mov    r12,QWORD PTR [rsp+0x8]
     659:	mov    r13,QWORD PTR [rsp+0x10]
     65e:	mov    r14,QWORD PTR [rsp+0x18]
     663:	mov    r15,QWORD PTR [rsp+0x20]
     668:	add    rsp,0x30
     66c:	mov    rsp,rbp
     66f:	pop    rbp
     670:	ret
     671:	mov    r13,rdi
     674:	call   679 <botlish_fn_4+0x164>
			675: R_X86_64_PLT32	rt_stack_overflow-0x4
     679:	xor    rdx,rdx
     67c:	mov    rax,rdx
     67f:	mov    rbx,QWORD PTR [rsp]
     683:	mov    r12,QWORD PTR [rsp+0x8]
     688:	mov    r13,QWORD PTR [rsp+0x10]
     68d:	mov    r14,QWORD PTR [rsp+0x18]
     692:	mov    r15,QWORD PTR [rsp+0x20]
     697:	add    rsp,0x30
     69b:	mov    rsp,rbp
     69e:	pop    rbp
     69f:	ret

00000000000006a0 <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     6a0:	push   rbp
     6a1:	mov    rbp,rsp
     6a4:	ud2

00000000000006a6 <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     6a6:	push   rbp
     6a7:	mov    rbp,rsp
     6aa:	sub    rsp,0x30
     6ae:	mov    QWORD PTR [rsp],rbx
     6b2:	mov    QWORD PTR [rsp+0x8],r12
     6b7:	mov    QWORD PTR [rsp+0x10],r13
     6bc:	mov    QWORD PTR [rsp+0x18],r14
     6c1:	mov    QWORD PTR [rsp+0x20],r15
     6c6:	mov    r12,QWORD PTR [rdi]
     6c9:	mov    r8,QWORD PTR [rdi+0x8]
     6cd:	lea    rax,[r12+0x18]
     6d2:	cmp    rax,r8
     6d5:	ja     802 <botlish_fn_5+0x15c>
     6db:	lea    rax,[r12+0x18]
     6e0:	mov    QWORD PTR [rdi],rax
     6e3:	mov    r13,rdi
     6e6:	mov    QWORD PTR [r12],0x0
     6ee:	mov    QWORD PTR [r12+0x8],0x0
     6f7:	mov    QWORD PTR [r12+0x10],0x0
     700:	mov    QWORD PTR [r12],rsi
     704:	mov    QWORD PTR [r12+0x8],rdx
     709:	mov    rdi,rdx
     70c:	mov    QWORD PTR [r12+0x10],rcx
     711:	mov    r15,rcx
     714:	mov    rbx,rdi
     717:	mov    rdx,rbx
     71a:	mov    rdi,r13
     71d:	call   722 <botlish_fn_5+0x7c>
			71e: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     722:	test   rax,rax
     725:	mov    r14,rax
     728:	jne    736 <botlish_fn_5+0x90>
     72e:	mov    rdi,r13
     731:	jmp    75a <botlish_fn_5+0xb4>
     736:	mov    rax,r14
     739:	mov    QWORD PTR [r12],rax
     73d:	mov    rcx,r15
     740:	mov    rdx,rbx
     743:	mov    rsi,r14
     746:	mov    rdi,r13
     749:	call   74e <botlish_fn_5+0xa8>
			74a: R_X86_64_PLT32	rt_mutarray_set-0x4
     74e:	test   rax,rax
     751:	jne    787 <botlish_fn_5+0xe1>
     757:	mov    rdi,r13
     75a:	mov    rdi,r13
     75d:	mov    QWORD PTR [rdi],r12
     760:	xor    rdx,rdx
     763:	mov    rax,rdx
     766:	mov    rbx,QWORD PTR [rsp]
     76a:	mov    r12,QWORD PTR [rsp+0x8]
     76f:	mov    r13,QWORD PTR [rsp+0x10]
     774:	mov    r14,QWORD PTR [rsp+0x18]
     779:	mov    r15,QWORD PTR [rsp+0x20]
     77e:	add    rsp,0x30
     782:	mov    rsp,rbp
     785:	pop    rbp
     786:	ret
     787:	mov    QWORD PTR [r12+0x10],0x3
     790:	test   rbx,0x1
     797:	jne    7a5 <botlish_fn_5+0xff>
     79d:	mov    rdi,rbx
     7a0:	jmp    7c2 <botlish_fn_5+0x11c>
     7a5:	mov    rdx,rbx
     7a8:	add    rdx,0x2
     7ac:	mov    rdi,rbx
     7af:	seto   al
     7b2:	test   al,al
     7b4:	jne    7c2 <botlish_fn_5+0x11c>
     7ba:	mov    rdi,r13
     7bd:	jmp    7d8 <botlish_fn_5+0x132>
     7c2:	mov    edx,0x3
     7c7:	mov    rsi,rdi
     7ca:	mov    rdi,r13
     7cd:	call   7d2 <botlish_fn_5+0x12c>
			7ce: R_X86_64_PLT32	rt_int_add-0x4
     7d2:	mov    rdx,rax
     7d5:	mov    rdi,r13
     7d8:	mov    rdi,r13
     7db:	mov    QWORD PTR [rdi],r12
     7de:	mov    rax,r14
     7e1:	mov    rbx,QWORD PTR [rsp]
     7e5:	mov    r12,QWORD PTR [rsp+0x8]
     7ea:	mov    r13,QWORD PTR [rsp+0x10]
     7ef:	mov    r14,QWORD PTR [rsp+0x18]
     7f4:	mov    r15,QWORD PTR [rsp+0x20]
     7f9:	add    rsp,0x30
     7fd:	mov    rsp,rbp
     800:	pop    rbp
     801:	ret
     802:	mov    r13,rdi
     805:	call   80a <botlish_fn_5+0x164>
			806: R_X86_64_PLT32	rt_stack_overflow-0x4
     80a:	xor    rdx,rdx
     80d:	mov    rax,rdx
     810:	mov    rbx,QWORD PTR [rsp]
     814:	mov    r12,QWORD PTR [rsp+0x8]
     819:	mov    r13,QWORD PTR [rsp+0x10]
     81e:	mov    r14,QWORD PTR [rsp+0x18]
     823:	mov    r15,QWORD PTR [rsp+0x20]
     828:	add    rsp,0x30
     82c:	mov    rsp,rbp
     82f:	pop    rbp
     830:	ret

0000000000000831 <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     831:	push   rbp
     832:	mov    rbp,rsp
     835:	ud2

0000000000000837 <botlish_fn_6: geo_append<list[mutarray, int], mutarray>>:
     837:	push   rbp
     838:	mov    rbp,rsp
     83b:	sub    rsp,0x30
     83f:	mov    QWORD PTR [rsp],rbx
     843:	mov    QWORD PTR [rsp+0x8],r12
     848:	mov    QWORD PTR [rsp+0x10],r13
     84d:	mov    QWORD PTR [rsp+0x18],r14
     852:	mov    QWORD PTR [rsp+0x20],r15
     857:	mov    r12,QWORD PTR [rdi]
     85a:	mov    r8,QWORD PTR [rdi+0x8]
     85e:	lea    rax,[r12+0x18]
     863:	cmp    rax,r8
     866:	ja     993 <botlish_fn_6+0x15c>
     86c:	lea    rax,[r12+0x18]
     871:	mov    QWORD PTR [rdi],rax
     874:	mov    r13,rdi
     877:	mov    QWORD PTR [r12],0x0
     87f:	mov    QWORD PTR [r12+0x8],0x0
     888:	mov    QWORD PTR [r12+0x10],0x0
     891:	mov    QWORD PTR [r12],rsi
     895:	mov    QWORD PTR [r12+0x8],rdx
     89a:	mov    rdi,rdx
     89d:	mov    QWORD PTR [r12+0x10],rcx
     8a2:	mov    r15,rcx
     8a5:	mov    rbx,rdi
     8a8:	mov    rdx,rbx
     8ab:	mov    rdi,r13
     8ae:	call   8b3 <botlish_fn_6+0x7c>
			8af: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     8b3:	test   rax,rax
     8b6:	mov    r14,rax
     8b9:	jne    8c7 <botlish_fn_6+0x90>
     8bf:	mov    rdi,r13
     8c2:	jmp    8eb <botlish_fn_6+0xb4>
     8c7:	mov    rax,r14
     8ca:	mov    QWORD PTR [r12],rax
     8ce:	mov    rcx,r15
     8d1:	mov    rdx,rbx
     8d4:	mov    rsi,r14
     8d7:	mov    rdi,r13
     8da:	call   8df <botlish_fn_6+0xa8>
			8db: R_X86_64_PLT32	rt_mutarray_set-0x4
     8df:	test   rax,rax
     8e2:	jne    918 <botlish_fn_6+0xe1>
     8e8:	mov    rdi,r13
     8eb:	mov    rdi,r13
     8ee:	mov    QWORD PTR [rdi],r12
     8f1:	xor    rdx,rdx
     8f4:	mov    rax,rdx
     8f7:	mov    rbx,QWORD PTR [rsp]
     8fb:	mov    r12,QWORD PTR [rsp+0x8]
     900:	mov    r13,QWORD PTR [rsp+0x10]
     905:	mov    r14,QWORD PTR [rsp+0x18]
     90a:	mov    r15,QWORD PTR [rsp+0x20]
     90f:	add    rsp,0x30
     913:	mov    rsp,rbp
     916:	pop    rbp
     917:	ret
     918:	mov    QWORD PTR [r12+0x10],0x3
     921:	test   rbx,0x1
     928:	jne    936 <botlish_fn_6+0xff>
     92e:	mov    rdi,rbx
     931:	jmp    953 <botlish_fn_6+0x11c>
     936:	mov    rdx,rbx
     939:	add    rdx,0x2
     93d:	mov    rdi,rbx
     940:	seto   al
     943:	test   al,al
     945:	jne    953 <botlish_fn_6+0x11c>
     94b:	mov    rdi,r13
     94e:	jmp    969 <botlish_fn_6+0x132>
     953:	mov    edx,0x3
     958:	mov    rsi,rdi
     95b:	mov    rdi,r13
     95e:	call   963 <botlish_fn_6+0x12c>
			95f: R_X86_64_PLT32	rt_int_add-0x4
     963:	mov    rdx,rax
     966:	mov    rdi,r13
     969:	mov    rdi,r13
     96c:	mov    QWORD PTR [rdi],r12
     96f:	mov    rax,r14
     972:	mov    rbx,QWORD PTR [rsp]
     976:	mov    r12,QWORD PTR [rsp+0x8]
     97b:	mov    r13,QWORD PTR [rsp+0x10]
     980:	mov    r14,QWORD PTR [rsp+0x18]
     985:	mov    r15,QWORD PTR [rsp+0x20]
     98a:	add    rsp,0x30
     98e:	mov    rsp,rbp
     991:	pop    rbp
     992:	ret
     993:	mov    r13,rdi
     996:	call   99b <botlish_fn_6+0x164>
			997: R_X86_64_PLT32	rt_stack_overflow-0x4
     99b:	xor    rdx,rdx
     99e:	mov    rax,rdx
     9a1:	mov    rbx,QWORD PTR [rsp]
     9a5:	mov    r12,QWORD PTR [rsp+0x8]
     9aa:	mov    r13,QWORD PTR [rsp+0x10]
     9af:	mov    r14,QWORD PTR [rsp+0x18]
     9b4:	mov    r15,QWORD PTR [rsp+0x20]
     9b9:	add    rsp,0x30
     9bd:	mov    rsp,rbp
     9c0:	pop    rbp
     9c1:	ret

00000000000009c2 <botlish_entry_6: geo_append<list[mutarray, int], mutarray>>:
     9c2:	push   rbp
     9c3:	mov    rbp,rsp
     9c6:	ud2

00000000000009c8 <botlish_fn_7: geo_finish<list[mutarray, int]>>:
     9c8:	push   rbp
     9c9:	mov    rbp,rsp
     9cc:	sub    rsp,0x10
     9d0:	mov    QWORD PTR [rsp],r13
     9d4:	mov    QWORD PTR [rsp+0x8],r14
     9d9:	mov    r13,QWORD PTR [rdi]
     9dc:	mov    rax,QWORD PTR [rdi+0x8]
     9e0:	lea    rcx,[r13+0x10]
     9e4:	cmp    rcx,rax
     9e7:	ja     a53 <botlish_fn_7+0x8b>
     9ed:	lea    rax,[r13+0x10]
     9f1:	mov    QWORD PTR [rdi],rax
     9f4:	mov    r14,rdi
     9f7:	mov    QWORD PTR [r13+0x0],0x0
     9ff:	mov    QWORD PTR [r13+0x8],0x0
     a07:	mov    QWORD PTR [r13+0x0],rsi
     a0b:	mov    QWORD PTR [r13+0x8],rdx
     a0f:	mov    rdi,r14
     a12:	call   a17 <botlish_fn_7+0x4f>
			a13: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     a17:	test   rax,rax
     a1a:	jne    a3b <botlish_fn_7+0x73>
     a20:	mov    rdi,r14
     a23:	mov    QWORD PTR [rdi],r13
     a26:	xor    rax,rax
     a29:	mov    r13,QWORD PTR [rsp]
     a2d:	mov    r14,QWORD PTR [rsp+0x8]
     a32:	add    rsp,0x10
     a36:	mov    rsp,rbp
     a39:	pop    rbp
     a3a:	ret
     a3b:	mov    rdi,r14
     a3e:	mov    QWORD PTR [rdi],r13
     a41:	mov    r13,QWORD PTR [rsp]
     a45:	mov    r14,QWORD PTR [rsp+0x8]
     a4a:	add    rsp,0x10
     a4e:	mov    rsp,rbp
     a51:	pop    rbp
     a52:	ret
     a53:	call   a58 <botlish_fn_7+0x90>
			a54: R_X86_64_PLT32	rt_stack_overflow-0x4
     a58:	xor    rax,rax
     a5b:	mov    r13,QWORD PTR [rsp]
     a5f:	mov    r14,QWORD PTR [rsp+0x8]
     a64:	add    rsp,0x10
     a68:	mov    rsp,rbp
     a6b:	pop    rbp
     a6c:	ret

0000000000000a6d <botlish_entry_7: geo_finish<list[mutarray, int]>>:
     a6d:	push   rbp
     a6e:	mov    rbp,rsp
     a71:	mov    rsi,QWORD PTR [rdx]
     a74:	mov    rdx,QWORD PTR [rdx+0x8]
     a78:	call   a7d <botlish_entry_7+0x10>
			a79: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
     a7d:	mov    rsp,rbp
     a80:	pop    rbp
     a81:	ret
     a82:	add    BYTE PTR [rax],al
     a84:	add    BYTE PTR [rax],al
	...

0000000000000a88 <botlish_fn_8: peek<str, int>>:
     a88:	push   rbp
     a89:	mov    rbp,rsp
     a8c:	sub    rsp,0x20
     a90:	mov    QWORD PTR [rsp],rbx
     a94:	mov    QWORD PTR [rsp+0x8],r12
     a99:	mov    QWORD PTR [rsp+0x10],r13
     a9e:	mov    QWORD PTR [rsp+0x18],r14
     aa3:	mov    r12,QWORD PTR [rdi]
     aa6:	mov    rax,QWORD PTR [rdi+0x8]
     aaa:	lea    rcx,[r12+0x18]
     aaf:	cmp    rcx,rax
     ab2:	ja     c0e <botlish_fn_8+0x186>
     ab8:	lea    rax,[r12+0x18]
     abd:	mov    QWORD PTR [rdi],rax
     ac0:	mov    r13,rdi
     ac3:	mov    QWORD PTR [r12],0x0
     acb:	mov    QWORD PTR [r12+0x8],0x0
     ad4:	mov    QWORD PTR [r12+0x10],0x0
     add:	mov    QWORD PTR [r12],rsi
     ae1:	mov    r14,rsi
     ae4:	mov    QWORD PTR [r12+0x8],rdx
     ae9:	mov    rbx,rdx
     aec:	mov    rsi,r14
     aef:	mov    rdi,r13
     af2:	call   af7 <botlish_fn_8+0x6f>
			af3: R_X86_64_PLT32	rt_str_len-0x4
     af7:	mov    rcx,rbx
     afa:	and    rcx,rax
     afd:	mov    rdx,rax
     b00:	test   rcx,0x1
     b07:	jne    b2d <botlish_fn_8+0xa5>
     b0d:	mov    rsi,rbx
     b10:	mov    rdi,r13
     b13:	call   b18 <botlish_fn_8+0x90>
			b14: R_X86_64_PLT32	rt_int_cmp-0x4
     b18:	mov    ecx,0x2
     b1d:	test   rax,rax
     b20:	cmovge rcx,QWORD PTR [rip+0x110]        # c38 <botlish_fn_8+0x1b0>
     b28:	jmp    b3d <botlish_fn_8+0xb5>
     b2d:	mov    ecx,0x2
     b32:	cmp    rbx,rdx
     b35:	cmovge rcx,QWORD PTR [rip+0xfb]        # c38 <botlish_fn_8+0x1b0>
     b3d:	cmp    rcx,0x6
     b41:	je     be5 <botlish_fn_8+0x15d>
     b47:	mov    QWORD PTR [r12+0x10],0x3
     b50:	test   rbx,0x1
     b57:	je     b6f <botlish_fn_8+0xe7>
     b5d:	mov    rcx,rbx
     b60:	add    rcx,0x2
     b64:	seto   al
     b67:	test   al,al
     b69:	je     b82 <botlish_fn_8+0xfa>
     b6f:	mov    edx,0x3
     b74:	mov    rsi,rbx
     b77:	mov    rdi,r13
     b7a:	call   b7f <botlish_fn_8+0xf7>
			b7b: R_X86_64_PLT32	rt_int_add-0x4
     b7f:	mov    rcx,rax
     b82:	mov    QWORD PTR [r12+0x10],rcx
     b87:	mov    rdx,rbx
     b8a:	mov    rsi,r14
     b8d:	mov    rdi,r13
     b90:	call   b95 <botlish_fn_8+0x10d>
			b91: R_X86_64_PLT32	rt_substr-0x4
     b95:	test   rax,rax
     b98:	jne    bc3 <botlish_fn_8+0x13b>
     b9e:	mov    rdi,r13
     ba1:	mov    QWORD PTR [rdi],r12
     ba4:	xor    rax,rax
     ba7:	mov    rbx,QWORD PTR [rsp]
     bab:	mov    r12,QWORD PTR [rsp+0x8]
     bb0:	mov    r13,QWORD PTR [rsp+0x10]
     bb5:	mov    r14,QWORD PTR [rsp+0x18]
     bba:	add    rsp,0x20
     bbe:	mov    rsp,rbp
     bc1:	pop    rbp
     bc2:	ret
     bc3:	mov    rdi,r13
     bc6:	mov    QWORD PTR [rdi],r12
     bc9:	mov    rbx,QWORD PTR [rsp]
     bcd:	mov    r12,QWORD PTR [rsp+0x8]
     bd2:	mov    r13,QWORD PTR [rsp+0x10]
     bd7:	mov    r14,QWORD PTR [rsp+0x18]
     bdc:	add    rsp,0x20
     be0:	mov    rsp,rbp
     be3:	pop    rbp
     be4:	ret
     be5:	mov    rdi,r13
     be8:	mov    rax,QWORD PTR [rdi+0x10]
     bec:	mov    rax,QWORD PTR [rax]
     bef:	mov    QWORD PTR [rdi],r12
     bf2:	mov    rbx,QWORD PTR [rsp]
     bf6:	mov    r12,QWORD PTR [rsp+0x8]
     bfb:	mov    r13,QWORD PTR [rsp+0x10]
     c00:	mov    r14,QWORD PTR [rsp+0x18]
     c05:	add    rsp,0x20
     c09:	mov    rsp,rbp
     c0c:	pop    rbp
     c0d:	ret
     c0e:	mov    r13,rdi
     c11:	call   c16 <botlish_fn_8+0x18e>
			c12: R_X86_64_PLT32	rt_stack_overflow-0x4
     c16:	xor    rax,rax
     c19:	mov    rbx,QWORD PTR [rsp]
     c1d:	mov    r12,QWORD PTR [rsp+0x8]
     c22:	mov    r13,QWORD PTR [rsp+0x10]
     c27:	mov    r14,QWORD PTR [rsp+0x18]
     c2c:	add    rsp,0x20
     c30:	mov    rsp,rbp
     c33:	pop    rbp
     c34:	ret
     c35:	add    BYTE PTR [rax],al
     c37:	add    BYTE PTR [rsi],al
     c39:	add    BYTE PTR [rax],al
     c3b:	add    BYTE PTR [rax],al
     c3d:	add    BYTE PTR [rax],al
	...

0000000000000c40 <botlish_entry_8: peek<str, int>>:
     c40:	push   rbp
     c41:	mov    rbp,rsp
     c44:	mov    rsi,QWORD PTR [rdx]
     c47:	mov    rdx,QWORD PTR [rdx+0x8]
     c4b:	call   c50 <botlish_entry_8+0x10>
			c4c: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     c50:	mov    rsp,rbp
     c53:	pop    rbp
     c54:	ret
     c55:	add    BYTE PTR [rax],al
	...

0000000000000c58 <botlish_fn_9: peek<str, int>>:
     c58:	push   rbp
     c59:	mov    rbp,rsp
     c5c:	sub    rsp,0x40
     c60:	mov    QWORD PTR [rsp+0x10],rbx
     c65:	mov    QWORD PTR [rsp+0x18],r12
     c6a:	mov    QWORD PTR [rsp+0x20],r13
     c6f:	mov    QWORD PTR [rsp+0x28],r14
     c74:	mov    QWORD PTR [rsp+0x30],r15
     c79:	mov    r13,rcx
     c7c:	mov    r12,QWORD PTR [rdi]
     c7f:	mov    rax,QWORD PTR [rdi+0x8]
     c83:	lea    rcx,[r12+0x18]
     c88:	cmp    rcx,rax
     c8b:	ja     e25 <botlish_fn_9+0x1cd>
     c91:	lea    rax,[r12+0x18]
     c96:	mov    QWORD PTR [rdi],rax
     c99:	mov    r15,rdi
     c9c:	mov    QWORD PTR [r12],0x0
     ca4:	mov    QWORD PTR [r12+0x8],0x0
     cad:	mov    QWORD PTR [r12+0x10],0x0
     cb6:	mov    QWORD PTR [r12],rsi
     cba:	mov    r14,rsi
     cbd:	mov    QWORD PTR [r12+0x8],rdx
     cc2:	mov    rbx,rdx
     cc5:	mov    rsi,r14
     cc8:	mov    rdi,r15
     ccb:	call   cd0 <botlish_fn_9+0x78>
			ccc: R_X86_64_PLT32	rt_str_len-0x4
     cd0:	mov    rcx,rbx
     cd3:	and    rcx,rax
     cd6:	mov    rdx,rax
     cd9:	test   rcx,0x1
     ce0:	jne    d06 <botlish_fn_9+0xae>
     ce6:	mov    rsi,rbx
     ce9:	mov    rdi,r15
     cec:	call   cf1 <botlish_fn_9+0x99>
			ced: R_X86_64_PLT32	rt_int_cmp-0x4
     cf1:	mov    ecx,0x2
     cf6:	test   rax,rax
     cf9:	cmovge rcx,QWORD PTR [rip+0x157]        # e58 <botlish_fn_9+0x200>
     d01:	jmp    d16 <botlish_fn_9+0xbe>
     d06:	mov    ecx,0x2
     d0b:	cmp    rbx,rdx
     d0e:	cmovge rcx,QWORD PTR [rip+0x142]        # e58 <botlish_fn_9+0x200>
     d16:	cmp    rcx,0x6
     d1a:	je     de4 <botlish_fn_9+0x18c>
     d20:	mov    QWORD PTR [r12+0x10],0x3
     d29:	test   rbx,0x1
     d30:	je     d51 <botlish_fn_9+0xf9>
     d36:	mov    rax,rbx
     d39:	add    rax,0x2
     d3d:	seto   cl
     d40:	test   cl,cl
     d42:	jne    d51 <botlish_fn_9+0xf9>
     d48:	mov    QWORD PTR [rsp],rax
     d4c:	jmp    d65 <botlish_fn_9+0x10d>
     d51:	mov    edx,0x3
     d56:	mov    rsi,rbx
     d59:	mov    rdi,r15
     d5c:	call   d61 <botlish_fn_9+0x109>
			d5d: R_X86_64_PLT32	rt_int_add-0x4
     d61:	mov    QWORD PTR [rsp],rax
     d65:	mov    rcx,QWORD PTR [rsp]
     d69:	mov    rdx,rbx
     d6c:	mov    rsi,r14
     d6f:	mov    rdi,r15
     d72:	call   d77 <botlish_fn_9+0x11f>
			d73: R_X86_64_PLT32	rt_str_region_check-0x4
     d77:	test   rax,rax
     d7a:	jne    dab <botlish_fn_9+0x153>
     d80:	mov    rdi,r15
     d83:	mov    QWORD PTR [rdi],r12
     d86:	xor    rax,rax
     d89:	mov    rbx,QWORD PTR [rsp+0x10]
     d8e:	mov    r12,QWORD PTR [rsp+0x18]
     d93:	mov    r13,QWORD PTR [rsp+0x20]
     d98:	mov    r14,QWORD PTR [rsp+0x28]
     d9d:	mov    r15,QWORD PTR [rsp+0x30]
     da2:	add    rsp,0x40
     da6:	mov    rsp,rbp
     da9:	pop    rbp
     daa:	ret
     dab:	mov    rdi,r15
     dae:	mov    QWORD PTR [rdi],r12
     db1:	mov    rcx,r13
     db4:	mov    QWORD PTR [rcx],rbx
     db7:	mov    rax,QWORD PTR [rsp]
     dbb:	mov    QWORD PTR [rcx+0x8],rax
     dbf:	mov    rax,r14
     dc2:	mov    rbx,QWORD PTR [rsp+0x10]
     dc7:	mov    r12,QWORD PTR [rsp+0x18]
     dcc:	mov    r13,QWORD PTR [rsp+0x20]
     dd1:	mov    r14,QWORD PTR [rsp+0x28]
     dd6:	mov    r15,QWORD PTR [rsp+0x30]
     ddb:	add    rsp,0x40
     ddf:	mov    rsp,rbp
     de2:	pop    rbp
     de3:	ret
     de4:	mov    rcx,r13
     de7:	mov    rdi,r15
     dea:	mov    rdx,QWORD PTR [rdi+0x10]
     dee:	mov    rax,QWORD PTR [rdx]
     df1:	mov    QWORD PTR [rdi],r12
     df4:	mov    QWORD PTR [rcx],0x1
     dfb:	mov    QWORD PTR [rcx+0x8],0x1
     e03:	mov    rbx,QWORD PTR [rsp+0x10]
     e08:	mov    r12,QWORD PTR [rsp+0x18]
     e0d:	mov    r13,QWORD PTR [rsp+0x20]
     e12:	mov    r14,QWORD PTR [rsp+0x28]
     e17:	mov    r15,QWORD PTR [rsp+0x30]
     e1c:	add    rsp,0x40
     e20:	mov    rsp,rbp
     e23:	pop    rbp
     e24:	ret
     e25:	mov    r15,rdi
     e28:	call   e2d <botlish_fn_9+0x1d5>
			e29: R_X86_64_PLT32	rt_stack_overflow-0x4
     e2d:	xor    rax,rax
     e30:	mov    rbx,QWORD PTR [rsp+0x10]
     e35:	mov    r12,QWORD PTR [rsp+0x18]
     e3a:	mov    r13,QWORD PTR [rsp+0x20]
     e3f:	mov    r14,QWORD PTR [rsp+0x28]
     e44:	mov    r15,QWORD PTR [rsp+0x30]
     e49:	add    rsp,0x40
     e4d:	mov    rsp,rbp
     e50:	pop    rbp
     e51:	ret
     e52:	add    BYTE PTR [rax],al
     e54:	add    BYTE PTR [rax],al
     e56:	add    BYTE PTR [rax],al
     e58:	(bad)
     e59:	add    BYTE PTR [rax],al
     e5b:	add    BYTE PTR [rax],al
     e5d:	add    BYTE PTR [rax],al
	...

0000000000000e60 <botlish_entry_9: peek<str, int>>:
     e60:	push   rbp
     e61:	mov    rbp,rsp
     e64:	ud2

0000000000000e66 <botlish_fn_10: scan_unquoted<str, int, int>>:
     e66:	push   rbp
     e67:	mov    rbp,rsp
     e6a:	sub    rsp,0x60
     e6e:	mov    QWORD PTR [rsp+0x30],rbx
     e73:	mov    QWORD PTR [rsp+0x38],r12
     e78:	mov    QWORD PTR [rsp+0x40],r13
     e7d:	mov    QWORD PTR [rsp+0x48],r14
     e82:	mov    QWORD PTR [rsp+0x50],r15
     e87:	mov    r14,QWORD PTR [rdi]
     e8a:	mov    rax,QWORD PTR [rdi+0x8]
     e8e:	lea    r8,[r14+0x20]
     e92:	cmp    r8,rax
     e95:	ja     10bc <botlish_fn_10+0x256>
     e9b:	lea    rax,[r14+0x20]
     e9f:	mov    QWORD PTR [rdi],rax
     ea2:	mov    r15,rdi
     ea5:	mov    QWORD PTR [r14],0x0
     eac:	mov    QWORD PTR [r14+0x8],0x0
     eb4:	mov    QWORD PTR [r14+0x10],0x0
     ebc:	mov    QWORD PTR [r14+0x18],0x0
     ec4:	mov    QWORD PTR [r14],rsi
     ec7:	mov    QWORD PTR [rsp+0x10],rsi
     ecc:	mov    QWORD PTR [r14+0x8],rdx
     ed0:	mov    QWORD PTR [rsp+0x18],rdx
     ed5:	mov    QWORD PTR [r14+0x10],rcx
     ed9:	lea    rbx,[rsp]
     edd:	mov    QWORD PTR [rsp+0x20],rcx
     ee2:	mov    rcx,rbx
     ee5:	mov    rdx,QWORD PTR [rsp+0x20]
     eea:	mov    rsi,QWORD PTR [rsp+0x10]
     eef:	mov    rdi,r15
     ef2:	call   ef7 <botlish_fn_10+0x91>
			ef3: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     ef7:	mov    rcx,rax
     efa:	mov    QWORD PTR [rsp+0x28],rax
     eff:	test   rax,rcx
     f02:	jne    f10 <botlish_fn_10+0xaa>
     f08:	mov    rdi,r15
     f0b:	jmp    1061 <botlish_fn_10+0x1fb>
     f10:	mov    r12,QWORD PTR [rsp]
     f14:	mov    r13,QWORD PTR [rsp+0x8]
     f19:	mov    rdi,r15
     f1c:	mov    rcx,QWORD PTR [rdi+0x10]
     f20:	mov    r8,QWORD PTR [rcx]
     f23:	mov    rcx,r13
     f26:	mov    rdx,r12
     f29:	mov    rsi,QWORD PTR [rsp+0x28]
     f2e:	call   f33 <botlish_fn_10+0xcd>
			f2f: R_X86_64_PLT32	rt_str_region_eq-0x4
     f33:	cmp    rax,0x6
     f37:	je     f76 <botlish_fn_10+0x110>
     f3d:	mov    rdi,r15
     f40:	mov    rax,QWORD PTR [rdi+0x10]
     f44:	mov    r8,QWORD PTR [rax+0x8]
     f48:	mov    rcx,r13
     f4b:	mov    rdx,r12
     f4e:	mov    rsi,QWORD PTR [rsp+0x28]
     f53:	call   f58 <botlish_fn_10+0xf2>
			f54: R_X86_64_PLT32	rt_str_region_eq-0x4
     f58:	cmp    rax,0x6
     f5c:	je     f6c <botlish_fn_10+0x106>
     f62:	mov    eax,0x2
     f67:	jmp    f7b <botlish_fn_10+0x115>
     f6c:	mov    eax,0x6
     f71:	jmp    f7b <botlish_fn_10+0x115>
     f76:	mov    eax,0x6
     f7b:	cmp    rax,0x6
     f7f:	je     fbe <botlish_fn_10+0x158>
     f85:	mov    rdi,r15
     f88:	mov    rsi,QWORD PTR [rdi+0x10]
     f8c:	mov    r8,QWORD PTR [rsi+0x10]
     f90:	mov    rcx,r13
     f93:	mov    rdx,r12
     f96:	mov    rsi,QWORD PTR [rsp+0x28]
     f9b:	call   fa0 <botlish_fn_10+0x13a>
			f9c: R_X86_64_PLT32	rt_str_region_eq-0x4
     fa0:	cmp    rax,0x6
     fa4:	je     fb4 <botlish_fn_10+0x14e>
     faa:	mov    eax,0x2
     faf:	jmp    fc3 <botlish_fn_10+0x15d>
     fb4:	mov    eax,0x6
     fb9:	jmp    fc3 <botlish_fn_10+0x15d>
     fbe:	mov    eax,0x6
     fc3:	cmp    rax,0x6
     fc7:	je     103e <botlish_fn_10+0x1d8>
     fcd:	mov    QWORD PTR [r14+0x18],0x3
     fd5:	mov    rsi,QWORD PTR [rsp+0x20]
     fda:	test   rsi,0x1
     fe1:	je     1008 <botlish_fn_10+0x1a2>
     fe7:	mov    rsi,QWORD PTR [rsp+0x20]
     fec:	mov    rax,rsi
     fef:	add    rax,0x2
     ff3:	seto   cl
     ff6:	test   cl,cl
     ff8:	jne    1008 <botlish_fn_10+0x1a2>
     ffe:	mov    rsi,QWORD PTR [rsp+0x10]
    1003:	jmp    101f <botlish_fn_10+0x1b9>
    1008:	mov    edx,0x3
    100d:	mov    rsi,QWORD PTR [rsp+0x20]
    1012:	mov    rdi,r15
    1015:	call   101a <botlish_fn_10+0x1b4>
			1016: R_X86_64_PLT32	rt_int_add-0x4
    101a:	mov    rsi,QWORD PTR [rsp+0x10]
    101f:	mov    QWORD PTR [r14],rsi
    1022:	mov    rdx,QWORD PTR [rsp+0x18]
    1027:	mov    QWORD PTR [r14+0x8],rdx
    102b:	mov    QWORD PTR [r14+0x10],rax
    102f:	mov    QWORD PTR [rsp+0x10],rsi
    1034:	mov    QWORD PTR [rsp+0x20],rax
    1039:	jmp    ee2 <botlish_fn_10+0x7c>
    103e:	mov    rdx,QWORD PTR [rsp+0x18]
    1043:	mov    rsi,QWORD PTR [rsp+0x10]
    1048:	mov    rcx,QWORD PTR [rsp+0x20]
    104d:	mov    rdi,r15
    1050:	call   1055 <botlish_fn_10+0x1ef>
			1051: R_X86_64_PLT32	rt_substr-0x4
    1055:	test   rax,rax
    1058:	jne    108f <botlish_fn_10+0x229>
    105e:	mov    rdi,r15
    1061:	mov    rdi,r15
    1064:	mov    QWORD PTR [rdi],r14
    1067:	xor    rdx,rdx
    106a:	mov    rax,rdx
    106d:	mov    rbx,QWORD PTR [rsp+0x30]
    1072:	mov    r12,QWORD PTR [rsp+0x38]
    1077:	mov    r13,QWORD PTR [rsp+0x40]
    107c:	mov    r14,QWORD PTR [rsp+0x48]
    1081:	mov    r15,QWORD PTR [rsp+0x50]
    1086:	add    rsp,0x60
    108a:	mov    rsp,rbp
    108d:	pop    rbp
    108e:	ret
    108f:	mov    rdi,r15
    1092:	mov    QWORD PTR [rdi],r14
    1095:	mov    rdx,QWORD PTR [rsp+0x20]
    109a:	mov    rbx,QWORD PTR [rsp+0x30]
    109f:	mov    r12,QWORD PTR [rsp+0x38]
    10a4:	mov    r13,QWORD PTR [rsp+0x40]
    10a9:	mov    r14,QWORD PTR [rsp+0x48]
    10ae:	mov    r15,QWORD PTR [rsp+0x50]
    10b3:	add    rsp,0x60
    10b7:	mov    rsp,rbp
    10ba:	pop    rbp
    10bb:	ret
    10bc:	mov    r15,rdi
    10bf:	call   10c4 <botlish_fn_10+0x25e>
			10c0: R_X86_64_PLT32	rt_stack_overflow-0x4
    10c4:	xor    rdx,rdx
    10c7:	mov    rax,rdx
    10ca:	mov    rbx,QWORD PTR [rsp+0x30]
    10cf:	mov    r12,QWORD PTR [rsp+0x38]
    10d4:	mov    r13,QWORD PTR [rsp+0x40]
    10d9:	mov    r14,QWORD PTR [rsp+0x48]
    10de:	mov    r15,QWORD PTR [rsp+0x50]
    10e3:	add    rsp,0x60
    10e7:	mov    rsp,rbp
    10ea:	pop    rbp
    10eb:	ret

00000000000010ec <botlish_entry_10: scan_unquoted<str, int, int>>:
    10ec:	push   rbp
    10ed:	mov    rbp,rsp
    10f0:	ud2

00000000000010f2 <botlish_fn_11: scan_quoted<str, int, str>>:
    10f2:	push   rbp
    10f3:	mov    rbp,rsp
    10f6:	sub    rsp,0x50
    10fa:	mov    QWORD PTR [rsp+0x20],rbx
    10ff:	mov    QWORD PTR [rsp+0x28],r12
    1104:	mov    QWORD PTR [rsp+0x30],r13
    1109:	mov    QWORD PTR [rsp+0x38],r14
    110e:	mov    QWORD PTR [rsp+0x40],r15
    1113:	mov    r13,QWORD PTR [rdi]
    1116:	mov    rax,QWORD PTR [rdi+0x8]
    111a:	lea    r8,[r13+0x28]
    111e:	cmp    r8,rax
    1121:	ja     1409 <botlish_fn_11+0x317>
    1127:	lea    rax,[r13+0x28]
    112b:	mov    QWORD PTR [rdi],rax
    112e:	mov    r14,rdi
    1131:	mov    QWORD PTR [r13+0x0],0x0
    1139:	mov    QWORD PTR [r13+0x8],0x0
    1141:	mov    QWORD PTR [r13+0x10],0x0
    1149:	mov    QWORD PTR [r13+0x18],0x0
    1151:	mov    QWORD PTR [r13+0x20],0x0
    1159:	mov    QWORD PTR [r13+0x0],rsi
    115d:	mov    QWORD PTR [r13+0x8],rdx
    1161:	mov    QWORD PTR [r13+0x10],rcx
    1165:	lea    rbx,[rsp]
    1169:	mov    r12,rsi
    116c:	mov    r15,rdx
    116f:	mov    QWORD PTR [rsp+0x10],rcx
    1174:	mov    rdx,r15
    1177:	mov    rsi,r12
    117a:	mov    rdi,r14
    117d:	call   1182 <botlish_fn_11+0x90>
			117e: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    1182:	test   rax,rax
    1185:	jne    1193 <botlish_fn_11+0xa1>
    118b:	mov    rdi,r14
    118e:	jmp    13c2 <botlish_fn_11+0x2d0>
    1193:	mov    QWORD PTR [r13+0x18],rax
    1197:	mov    rdi,r14
    119a:	mov    QWORD PTR [rsp+0x18],rax
    119f:	mov    rsi,QWORD PTR [rdi+0x10]
    11a3:	mov    rsi,QWORD PTR [rsi+0x18]
    11a7:	mov    edx,0x1
    11ac:	mov    ecx,0x3
    11b1:	mov    r8,QWORD PTR [rsp+0x18]
    11b6:	call   11bb <botlish_fn_11+0xc9>
			11b7: R_X86_64_PLT32	rt_str_region_eq-0x4
    11bb:	cmp    rax,0x6
    11bf:	je     124a <botlish_fn_11+0x158>
    11c5:	mov    QWORD PTR [r13+0x20],0x3
    11cd:	mov    rsi,r15
    11d0:	test   rsi,0x1
    11d7:	je     11f7 <botlish_fn_11+0x105>
    11dd:	mov    r11,rsi
    11e0:	add    r11,0x2
    11e4:	seto   al
    11e7:	test   al,al
    11e9:	jne    11f7 <botlish_fn_11+0x105>
    11ef:	mov    rsi,r11
    11f2:	jmp    1207 <botlish_fn_11+0x115>
    11f7:	mov    edx,0x3
    11fc:	mov    rdi,r14
    11ff:	call   1204 <botlish_fn_11+0x112>
			1200: R_X86_64_PLT32	rt_int_add-0x4
    1204:	mov    rsi,rax
    1207:	mov    QWORD PTR [r13+0x8],rsi
    120b:	mov    r15,rsi
    120e:	mov    rsi,QWORD PTR [rsp+0x10]
    1213:	mov    rdx,QWORD PTR [rsp+0x18]
    1218:	mov    rdi,r14
    121b:	call   1220 <botlish_fn_11+0x12e>
			121c: R_X86_64_PLT32	rt_str_cat-0x4
    1220:	test   rax,rax
    1223:	jne    1231 <botlish_fn_11+0x13f>
    1229:	mov    rdi,r14
    122c:	jmp    13c2 <botlish_fn_11+0x2d0>
    1231:	mov    QWORD PTR [r13+0x0],r12
    1235:	mov    rsi,r15
    1238:	mov    QWORD PTR [r13+0x8],rsi
    123c:	mov    QWORD PTR [r13+0x10],rax
    1240:	mov    QWORD PTR [rsp+0x10],rax
    1245:	jmp    1174 <botlish_fn_11+0x82>
    124a:	mov    QWORD PTR [r13+0x18],0x3
    1252:	mov    rsi,r15
    1255:	test   rsi,0x1
    125c:	je     1277 <botlish_fn_11+0x185>
    1262:	mov    rsi,r15
    1265:	mov    rdx,rsi
    1268:	add    rdx,0x2
    126c:	seto   al
    126f:	test   al,al
    1271:	je     128a <botlish_fn_11+0x198>
    1277:	mov    edx,0x3
    127c:	mov    rsi,r15
    127f:	mov    rdi,r14
    1282:	call   1287 <botlish_fn_11+0x195>
			1283: R_X86_64_PLT32	rt_int_add-0x4
    1287:	mov    rdx,rax
    128a:	mov    QWORD PTR [r13+0x18],rdx
    128e:	mov    rcx,rbx
    1291:	mov    rsi,r12
    1294:	mov    rdi,r14
    1297:	call   129c <botlish_fn_11+0x1aa>
			1298: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    129c:	test   rax,rax
    129f:	mov    rsi,rax
    12a2:	jne    12b0 <botlish_fn_11+0x1be>
    12a8:	mov    rdi,r14
    12ab:	jmp    13c2 <botlish_fn_11+0x2d0>
    12b0:	mov    rdx,QWORD PTR [rsp]
    12b4:	mov    rcx,QWORD PTR [rsp+0x8]
    12b9:	mov    rdi,r14
    12bc:	mov    rax,QWORD PTR [rdi+0x10]
    12c0:	mov    r8,QWORD PTR [rax+0x18]
    12c4:	call   12c9 <botlish_fn_11+0x1d7>
			12c5: R_X86_64_PLT32	rt_str_region_eq-0x4
    12c9:	cmp    rax,0x6
    12cd:	je     134b <botlish_fn_11+0x259>
    12d3:	mov    QWORD PTR [r13+0x0],0x3
    12db:	mov    rsi,r15
    12de:	test   rsi,0x1
    12e5:	je     1308 <botlish_fn_11+0x216>
    12eb:	mov    rsi,r15
    12ee:	mov    rdx,rsi
    12f1:	add    rdx,0x2
    12f5:	seto   al
    12f8:	test   al,al
    12fa:	jne    1308 <botlish_fn_11+0x216>
    1300:	mov    rdi,r14
    1303:	jmp    131e <botlish_fn_11+0x22c>
    1308:	mov    edx,0x3
    130d:	mov    rsi,r15
    1310:	mov    rdi,r14
    1313:	call   1318 <botlish_fn_11+0x226>
			1314: R_X86_64_PLT32	rt_int_add-0x4
    1318:	mov    rdx,rax
    131b:	mov    rdi,r14
    131e:	mov    rdi,r14
    1321:	mov    QWORD PTR [rdi],r13
    1324:	mov    rax,QWORD PTR [rsp+0x10]
    1329:	mov    rbx,QWORD PTR [rsp+0x20]
    132e:	mov    r12,QWORD PTR [rsp+0x28]
    1333:	mov    r13,QWORD PTR [rsp+0x30]
    1338:	mov    r14,QWORD PTR [rsp+0x38]
    133d:	mov    r15,QWORD PTR [rsp+0x40]
    1342:	add    rsp,0x50
    1346:	mov    rsp,rbp
    1349:	pop    rbp
    134a:	ret
    134b:	mov    QWORD PTR [r13+0x18],0x5
    1353:	mov    rsi,r15
    1356:	test   rsi,0x1
    135d:	je     1383 <botlish_fn_11+0x291>
    1363:	mov    rsi,r15
    1366:	mov    rax,rsi
    1369:	add    rax,0x4
    136d:	seto   cl
    1370:	test   cl,cl
    1372:	jne    1383 <botlish_fn_11+0x291>
    1378:	mov    rsi,rax
    137b:	mov    r15,rax
    137e:	jmp    1399 <botlish_fn_11+0x2a7>
    1383:	mov    edx,0x5
    1388:	mov    rsi,r15
    138b:	mov    rdi,r14
    138e:	call   1393 <botlish_fn_11+0x2a1>
			138f: R_X86_64_PLT32	rt_int_add-0x4
    1393:	mov    rsi,rax
    1396:	mov    r15,rax
    1399:	mov    QWORD PTR [r13+0x8],rsi
    139d:	mov    rdi,r14
    13a0:	mov    rax,QWORD PTR [rdi+0x10]
    13a4:	mov    rdx,QWORD PTR [rax+0x18]
    13a8:	mov    QWORD PTR [r13+0x18],rdx
    13ac:	mov    rsi,QWORD PTR [rsp+0x10]
    13b1:	call   13b6 <botlish_fn_11+0x2c4>
			13b2: R_X86_64_PLT32	rt_str_cat-0x4
    13b6:	test   rax,rax
    13b9:	jne    13f0 <botlish_fn_11+0x2fe>
    13bf:	mov    rdi,r14
    13c2:	mov    rdi,r14
    13c5:	mov    QWORD PTR [rdi],r13
    13c8:	xor    rdx,rdx
    13cb:	mov    rax,rdx
    13ce:	mov    rbx,QWORD PTR [rsp+0x20]
    13d3:	mov    r12,QWORD PTR [rsp+0x28]
    13d8:	mov    r13,QWORD PTR [rsp+0x30]
    13dd:	mov    r14,QWORD PTR [rsp+0x38]
    13e2:	mov    r15,QWORD PTR [rsp+0x40]
    13e7:	add    rsp,0x50
    13eb:	mov    rsp,rbp
    13ee:	pop    rbp
    13ef:	ret
    13f0:	mov    QWORD PTR [r13+0x0],r12
    13f4:	mov    rsi,r15
    13f7:	mov    QWORD PTR [r13+0x8],rsi
    13fb:	mov    QWORD PTR [r13+0x10],rax
    13ff:	mov    QWORD PTR [rsp+0x10],rax
    1404:	jmp    1174 <botlish_fn_11+0x82>
    1409:	mov    r14,rdi
    140c:	call   1411 <botlish_fn_11+0x31f>
			140d: R_X86_64_PLT32	rt_stack_overflow-0x4
    1411:	xor    rdx,rdx
    1414:	mov    rax,rdx
    1417:	mov    rbx,QWORD PTR [rsp+0x20]
    141c:	mov    r12,QWORD PTR [rsp+0x28]
    1421:	mov    r13,QWORD PTR [rsp+0x30]
    1426:	mov    r14,QWORD PTR [rsp+0x38]
    142b:	mov    r15,QWORD PTR [rsp+0x40]
    1430:	add    rsp,0x50
    1434:	mov    rsp,rbp
    1437:	pop    rbp
    1438:	ret

0000000000001439 <botlish_entry_11: scan_quoted<str, int, str>>:
    1439:	push   rbp
    143a:	mov    rbp,rsp
    143d:	ud2

000000000000143f <botlish_fn_12: scan_field<str, int>>:
    143f:	push   rbp
    1440:	mov    rbp,rsp
    1443:	sub    rsp,0x30
    1447:	mov    QWORD PTR [rsp+0x10],rbx
    144c:	mov    QWORD PTR [rsp+0x18],r12
    1451:	mov    QWORD PTR [rsp+0x20],r13
    1456:	mov    QWORD PTR [rsp+0x28],r14
    145b:	mov    rbx,QWORD PTR [rdi]
    145e:	mov    rax,QWORD PTR [rdi+0x8]
    1462:	lea    rcx,[rbx+0x18]
    1466:	cmp    rcx,rax
    1469:	ja     15da <botlish_fn_12+0x19b>
    146f:	lea    rax,[rbx+0x18]
    1473:	mov    QWORD PTR [rdi],rax
    1476:	mov    r12,rdi
    1479:	mov    QWORD PTR [rbx],0x0
    1480:	mov    QWORD PTR [rbx+0x8],0x0
    1488:	mov    QWORD PTR [rbx+0x10],0x0
    1490:	mov    QWORD PTR [rbx],rsi
    1493:	mov    r13,rsi
    1496:	mov    QWORD PTR [rbx+0x8],rdx
    149a:	mov    r14,rdx
    149d:	lea    rcx,[rsp]
    14a1:	mov    rdx,r14
    14a4:	mov    rsi,r13
    14a7:	mov    rdi,r12
    14aa:	call   14af <botlish_fn_12+0x70>
			14ab: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    14af:	test   rax,rax
    14b2:	mov    rsi,rax
    14b5:	jne    14c3 <botlish_fn_12+0x84>
    14bb:	mov    rdi,r12
    14be:	jmp    158e <botlish_fn_12+0x14f>
    14c3:	mov    rdx,QWORD PTR [rsp]
    14c7:	mov    rcx,QWORD PTR [rsp+0x8]
    14cc:	mov    rdi,r12
    14cf:	mov    rax,QWORD PTR [rdi+0x10]
    14d3:	mov    r8,QWORD PTR [rax+0x18]
    14d7:	call   14dc <botlish_fn_12+0x9d>
			14d8: R_X86_64_PLT32	rt_str_region_eq-0x4
    14dc:	cmp    rax,0x6
    14e0:	je     152b <botlish_fn_12+0xec>
    14e6:	mov    rcx,r14
    14e9:	mov    rsi,r13
    14ec:	mov    rdi,r12
    14ef:	mov    rdx,rcx
    14f2:	call   14f7 <botlish_fn_12+0xb8>
			14f3: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_unquoted<str, int, int>
    14f7:	test   rax,rax
    14fa:	jne    1508 <botlish_fn_12+0xc9>
    1500:	mov    rdi,r12
    1503:	jmp    158e <botlish_fn_12+0x14f>
    1508:	mov    rdi,r12
    150b:	mov    QWORD PTR [rdi],rbx
    150e:	mov    rbx,QWORD PTR [rsp+0x10]
    1513:	mov    r12,QWORD PTR [rsp+0x18]
    1518:	mov    r13,QWORD PTR [rsp+0x20]
    151d:	mov    r14,QWORD PTR [rsp+0x28]
    1522:	add    rsp,0x30
    1526:	mov    rsp,rbp
    1529:	pop    rbp
    152a:	ret
    152b:	mov    QWORD PTR [rbx+0x10],0x3
    1533:	mov    rdx,r14
    1536:	test   rdx,0x1
    153d:	je     1555 <botlish_fn_12+0x116>
    1543:	mov    rdx,r14
    1546:	add    rdx,0x2
    154a:	seto   al
    154d:	test   al,al
    154f:	je     1568 <botlish_fn_12+0x129>
    1555:	mov    edx,0x3
    155a:	mov    rsi,r14
    155d:	mov    rdi,r12
    1560:	call   1565 <botlish_fn_12+0x126>
			1561: R_X86_64_PLT32	rt_int_add-0x4
    1565:	mov    rdx,rax
    1568:	mov    QWORD PTR [rbx+0x8],rdx
    156c:	mov    rdi,r12
    156f:	mov    rax,QWORD PTR [rdi+0x10]
    1573:	mov    rcx,QWORD PTR [rax]
    1576:	mov    QWORD PTR [rbx+0x10],rcx
    157a:	mov    rsi,r13
    157d:	call   1582 <botlish_fn_12+0x143>
			157e: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_quoted<str, int, str>
    1582:	test   rax,rax
    1585:	jne    15b7 <botlish_fn_12+0x178>
    158b:	mov    rdi,r12
    158e:	mov    rdi,r12
    1591:	mov    QWORD PTR [rdi],rbx
    1594:	xor    rdx,rdx
    1597:	mov    rax,rdx
    159a:	mov    rbx,QWORD PTR [rsp+0x10]
    159f:	mov    r12,QWORD PTR [rsp+0x18]
    15a4:	mov    r13,QWORD PTR [rsp+0x20]
    15a9:	mov    r14,QWORD PTR [rsp+0x28]
    15ae:	add    rsp,0x30
    15b2:	mov    rsp,rbp
    15b5:	pop    rbp
    15b6:	ret
    15b7:	mov    rdi,r12
    15ba:	mov    QWORD PTR [rdi],rbx
    15bd:	mov    rbx,QWORD PTR [rsp+0x10]
    15c2:	mov    r12,QWORD PTR [rsp+0x18]
    15c7:	mov    r13,QWORD PTR [rsp+0x20]
    15cc:	mov    r14,QWORD PTR [rsp+0x28]
    15d1:	add    rsp,0x30
    15d5:	mov    rsp,rbp
    15d8:	pop    rbp
    15d9:	ret
    15da:	mov    r12,rdi
    15dd:	call   15e2 <botlish_fn_12+0x1a3>
			15de: R_X86_64_PLT32	rt_stack_overflow-0x4
    15e2:	xor    rdx,rdx
    15e5:	mov    rax,rdx
    15e8:	mov    rbx,QWORD PTR [rsp+0x10]
    15ed:	mov    r12,QWORD PTR [rsp+0x18]
    15f2:	mov    r13,QWORD PTR [rsp+0x20]
    15f7:	mov    r14,QWORD PTR [rsp+0x28]
    15fc:	add    rsp,0x30
    1600:	mov    rsp,rbp
    1603:	pop    rbp
    1604:	ret

0000000000001605 <botlish_entry_12: scan_field<str, int>>:
    1605:	push   rbp
    1606:	mov    rbp,rsp
    1609:	ud2

000000000000160b <botlish_fn_13: scan_record<str, int, list[mutarray, int]>>:
    160b:	push   rbp
    160c:	mov    rbp,rsp
    160f:	sub    rsp,0x70
    1613:	mov    QWORD PTR [rsp+0x40],rbx
    1618:	mov    QWORD PTR [rsp+0x48],r12
    161d:	mov    QWORD PTR [rsp+0x50],r13
    1622:	mov    QWORD PTR [rsp+0x58],r14
    1627:	mov    QWORD PTR [rsp+0x60],r15
    162c:	mov    r13,QWORD PTR [rdi]
    162f:	mov    rax,QWORD PTR [rdi+0x8]
    1633:	lea    r9,[r13+0x28]
    1637:	cmp    r9,rax
    163a:	ja     1920 <botlish_fn_13+0x315>
    1640:	lea    rax,[r13+0x28]
    1644:	mov    QWORD PTR [rdi],rax
    1647:	mov    QWORD PTR [rsp+0x10],rdi
    164c:	mov    QWORD PTR [r13+0x0],0x0
    1654:	mov    QWORD PTR [r13+0x8],0x0
    165c:	mov    QWORD PTR [r13+0x10],0x0
    1664:	mov    QWORD PTR [r13+0x18],0x0
    166c:	mov    QWORD PTR [r13+0x20],0x0
    1674:	mov    QWORD PTR [r13+0x0],rsi
    1678:	mov    QWORD PTR [r13+0x8],rdx
    167c:	mov    QWORD PTR [r13+0x10],rcx
    1680:	mov    QWORD PTR [r13+0x18],r8
    1684:	lea    rbx,[rsp]
    1688:	mov    r12,rsi
    168b:	mov    r14,r8
    168e:	mov    r15,rcx
    1691:	mov    rsi,r12
    1694:	mov    rdi,QWORD PTR [rsp+0x10]
    1699:	call   169e <botlish_fn_13+0x93>
			169a: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_field<str, int>
    169e:	test   rax,rax
    16a1:	jne    16b1 <botlish_fn_13+0xa6>
    16a7:	mov    rdi,QWORD PTR [rsp+0x10]
    16ac:	jmp    17f7 <botlish_fn_13+0x1ec>
    16b1:	mov    QWORD PTR [r13+0x8],rax
    16b5:	mov    rcx,rax
    16b8:	mov    QWORD PTR [r13+0x20],rdx
    16bc:	mov    QWORD PTR [rsp+0x30],rdx
    16c1:	mov    rsi,r15
    16c4:	mov    rdx,r14
    16c7:	mov    rdi,QWORD PTR [rsp+0x10]
    16cc:	call   16d1 <botlish_fn_13+0xc6>
			16cd: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    16d1:	test   rax,rax
    16d4:	jne    16e4 <botlish_fn_13+0xd9>
    16da:	mov    rdi,QWORD PTR [rsp+0x10]
    16df:	jmp    17f7 <botlish_fn_13+0x1ec>
    16e4:	mov    QWORD PTR [r13+0x8],rax
    16e8:	mov    QWORD PTR [rsp+0x20],rax
    16ed:	mov    QWORD PTR [r13+0x10],rdx
    16f1:	mov    QWORD PTR [rsp+0x28],rdx
    16f6:	mov    rcx,rbx
    16f9:	mov    rdx,QWORD PTR [rsp+0x30]
    16fe:	mov    rsi,r12
    1701:	mov    rdi,QWORD PTR [rsp+0x10]
    1706:	call   170b <botlish_fn_13+0x100>
			1707: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    170b:	test   rax,rax
    170e:	mov    QWORD PTR [rsp+0x18],rax
    1713:	jne    1723 <botlish_fn_13+0x118>
    1719:	mov    rdi,QWORD PTR [rsp+0x10]
    171e:	jmp    17f7 <botlish_fn_13+0x1ec>
    1723:	mov    r15,QWORD PTR [rsp]
    1727:	mov    r14,QWORD PTR [rsp+0x8]
    172c:	mov    rdi,QWORD PTR [rsp+0x10]
    1731:	mov    rsi,QWORD PTR [rdi+0x10]
    1735:	mov    r8,QWORD PTR [rsi+0x8]
    1739:	mov    rcx,r14
    173c:	mov    rdx,r15
    173f:	mov    rsi,QWORD PTR [rsp+0x18]
    1744:	call   1749 <botlish_fn_13+0x13e>
			1745: R_X86_64_PLT32	rt_str_region_eq-0x4
    1749:	cmp    rax,0x6
    174d:	je     18af <botlish_fn_13+0x2a4>
    1753:	mov    rdi,QWORD PTR [rsp+0x10]
    1758:	mov    rdi,QWORD PTR [rdi+0x10]
    175c:	mov    r8,QWORD PTR [rdi+0x10]
    1760:	mov    rcx,r14
    1763:	mov    rdx,r15
    1766:	mov    rsi,QWORD PTR [rsp+0x18]
    176b:	mov    rdi,QWORD PTR [rsp+0x10]
    1770:	call   1775 <botlish_fn_13+0x16a>
			1771: R_X86_64_PLT32	rt_str_region_eq-0x4
    1775:	cmp    rax,0x6
    1779:	je     17d5 <botlish_fn_13+0x1ca>
    177f:	mov    rdx,QWORD PTR [rsp+0x28]
    1784:	mov    rsi,QWORD PTR [rsp+0x20]
    1789:	mov    rdi,QWORD PTR [rsp+0x10]
    178e:	call   1793 <botlish_fn_13+0x188>
			178f: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    1793:	test   rax,rax
    1796:	jne    17a6 <botlish_fn_13+0x19b>
    179c:	mov    rdi,QWORD PTR [rsp+0x10]
    17a1:	jmp    17f7 <botlish_fn_13+0x1ec>
    17a6:	mov    rdi,QWORD PTR [rsp+0x10]
    17ab:	mov    QWORD PTR [rdi],r13
    17ae:	mov    rdx,QWORD PTR [rsp+0x30]
    17b3:	mov    rbx,QWORD PTR [rsp+0x40]
    17b8:	mov    r12,QWORD PTR [rsp+0x48]
    17bd:	mov    r13,QWORD PTR [rsp+0x50]
    17c2:	mov    r14,QWORD PTR [rsp+0x58]
    17c7:	mov    r15,QWORD PTR [rsp+0x60]
    17cc:	add    rsp,0x70
    17d0:	mov    rsp,rbp
    17d3:	pop    rbp
    17d4:	ret
    17d5:	mov    rdx,QWORD PTR [rsp+0x28]
    17da:	mov    rsi,QWORD PTR [rsp+0x20]
    17df:	mov    rdi,QWORD PTR [rsp+0x10]
    17e4:	call   17e9 <botlish_fn_13+0x1de>
			17e5: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    17e9:	test   rax,rax
    17ec:	jne    1827 <botlish_fn_13+0x21c>
    17f2:	mov    rdi,QWORD PTR [rsp+0x10]
    17f7:	mov    rdi,QWORD PTR [rsp+0x10]
    17fc:	mov    QWORD PTR [rdi],r13
    17ff:	xor    rdx,rdx
    1802:	mov    rax,rdx
    1805:	mov    rbx,QWORD PTR [rsp+0x40]
    180a:	mov    r12,QWORD PTR [rsp+0x48]
    180f:	mov    r13,QWORD PTR [rsp+0x50]
    1814:	mov    r14,QWORD PTR [rsp+0x58]
    1819:	mov    r15,QWORD PTR [rsp+0x60]
    181e:	add    rsp,0x70
    1822:	mov    rsp,rbp
    1825:	pop    rbp
    1826:	ret
    1827:	mov    QWORD PTR [r13+0x0],rax
    182b:	mov    rbx,rax
    182e:	mov    QWORD PTR [r13+0x8],0x3
    1836:	mov    rdx,QWORD PTR [rsp+0x30]
    183b:	test   rdx,0x1
    1842:	je     1866 <botlish_fn_13+0x25b>
    1848:	mov    rdx,QWORD PTR [rsp+0x30]
    184d:	add    rdx,0x2
    1851:	seto   al
    1854:	test   al,al
    1856:	jne    1866 <botlish_fn_13+0x25b>
    185c:	mov    rdi,QWORD PTR [rsp+0x10]
    1861:	jmp    1882 <botlish_fn_13+0x277>
    1866:	mov    edx,0x3
    186b:	mov    rsi,QWORD PTR [rsp+0x30]
    1870:	mov    rdi,QWORD PTR [rsp+0x10]
    1875:	call   187a <botlish_fn_13+0x26f>
			1876: R_X86_64_PLT32	rt_int_add-0x4
    187a:	mov    rdx,rax
    187d:	mov    rdi,QWORD PTR [rsp+0x10]
    1882:	mov    rdi,QWORD PTR [rsp+0x10]
    1887:	mov    QWORD PTR [rdi],r13
    188a:	mov    rax,rbx
    188d:	mov    rbx,QWORD PTR [rsp+0x40]
    1892:	mov    r12,QWORD PTR [rsp+0x48]
    1897:	mov    r13,QWORD PTR [rsp+0x50]
    189c:	mov    r14,QWORD PTR [rsp+0x58]
    18a1:	mov    r15,QWORD PTR [rsp+0x60]
    18a6:	add    rsp,0x70
    18aa:	mov    rsp,rbp
    18ad:	pop    rbp
    18ae:	ret
    18af:	mov    rsi,QWORD PTR [rsp+0x30]
    18b4:	mov    edx,0x3
    18b9:	mov    r9,rdx
    18bc:	mov    QWORD PTR [r13+0x18],0x3
    18c4:	test   rsi,0x1
    18cb:	jne    18d9 <botlish_fn_13+0x2ce>
    18d1:	mov    rdx,r9
    18d4:	jmp    18ee <botlish_fn_13+0x2e3>
    18d9:	mov    rdx,rsi
    18dc:	add    rdx,0x2
    18e0:	seto   al
    18e3:	test   al,al
    18e5:	je     18fb <botlish_fn_13+0x2f0>
    18eb:	mov    rdx,r9
    18ee:	mov    rdi,QWORD PTR [rsp+0x10]
    18f3:	call   18f8 <botlish_fn_13+0x2ed>
			18f4: R_X86_64_PLT32	rt_int_add-0x4
    18f8:	mov    rdx,rax
    18fb:	mov    QWORD PTR [r13+0x0],r12
    18ff:	mov    QWORD PTR [r13+0x8],rdx
    1903:	mov    rsi,QWORD PTR [rsp+0x20]
    1908:	mov    QWORD PTR [r13+0x10],rsi
    190c:	mov    rax,QWORD PTR [rsp+0x28]
    1911:	mov    QWORD PTR [r13+0x18],rax
    1915:	mov    r14,rax
    1918:	mov    r15,rsi
    191b:	jmp    1691 <botlish_fn_13+0x86>
    1920:	mov    QWORD PTR [rsp+0x10],rdi
    1925:	call   192a <botlish_fn_13+0x31f>
			1926: R_X86_64_PLT32	rt_stack_overflow-0x4
    192a:	xor    rdx,rdx
    192d:	mov    rax,rdx
    1930:	mov    rbx,QWORD PTR [rsp+0x40]
    1935:	mov    r12,QWORD PTR [rsp+0x48]
    193a:	mov    r13,QWORD PTR [rsp+0x50]
    193f:	mov    r14,QWORD PTR [rsp+0x58]
    1944:	mov    r15,QWORD PTR [rsp+0x60]
    1949:	add    rsp,0x70
    194d:	mov    rsp,rbp
    1950:	pop    rbp
    1951:	ret

0000000000001952 <botlish_entry_13: scan_record<str, int, list[mutarray, int]>>:
    1952:	push   rbp
    1953:	mov    rbp,rsp
    1956:	ud2

0000000000001958 <botlish_fn_14: scan_records<str, int, list[mutarray, int]>>:
    1958:	push   rbp
    1959:	mov    rbp,rsp
    195c:	sub    rsp,0x40
    1960:	mov    QWORD PTR [rsp+0x10],rbx
    1965:	mov    QWORD PTR [rsp+0x18],r12
    196a:	mov    QWORD PTR [rsp+0x20],r13
    196f:	mov    QWORD PTR [rsp+0x28],r14
    1974:	mov    QWORD PTR [rsp+0x30],r15
    1979:	mov    r12,QWORD PTR [rdi]
    197c:	mov    rax,QWORD PTR [rdi+0x8]
    1980:	lea    r9,[r12+0x30]
    1985:	cmp    r9,rax
    1988:	ja     1b54 <botlish_fn_14+0x1fc>
    198e:	lea    rax,[r12+0x30]
    1993:	mov    QWORD PTR [rdi],rax
    1996:	mov    r14,rdi
    1999:	mov    QWORD PTR [r12],0x0
    19a1:	mov    QWORD PTR [r12+0x8],0x0
    19aa:	mov    QWORD PTR [r12+0x10],0x0
    19b3:	mov    QWORD PTR [r12+0x18],0x0
    19bc:	mov    QWORD PTR [r12+0x20],0x0
    19c5:	mov    QWORD PTR [r12+0x28],0x0
    19ce:	mov    QWORD PTR [r12],rsi
    19d2:	mov    QWORD PTR [r12+0x8],rdx
    19d7:	mov    r13,rdx
    19da:	mov    QWORD PTR [r12+0x10],rcx
    19df:	mov    QWORD PTR [r12+0x18],r8
    19e4:	mov    rbx,rsi
    19e7:	mov    r15,r8
    19ea:	mov    QWORD PTR [rsp],rcx
    19ee:	mov    rsi,rbx
    19f1:	mov    rdi,r14
    19f4:	call   19f9 <botlish_fn_14+0xa1>
			19f5: R_X86_64_PLT32	rt_str_len-0x4
    19f9:	mov    rcx,r13
    19fc:	and    rcx,rax
    19ff:	mov    rdx,rax
    1a02:	test   rcx,0x1
    1a09:	jne    1a2f <botlish_fn_14+0xd7>
    1a0f:	mov    rsi,r13
    1a12:	mov    rdi,r14
    1a15:	call   1a1a <botlish_fn_14+0xc2>
			1a16: R_X86_64_PLT32	rt_int_cmp-0x4
    1a1a:	mov    ecx,0x2
    1a1f:	test   rax,rax
    1a22:	cmovge rcx,QWORD PTR [rip+0x15e]        # 1b88 <botlish_fn_14+0x230>
    1a2a:	jmp    1a42 <botlish_fn_14+0xea>
    1a2f:	mov    ecx,0x2
    1a34:	mov    rax,r13
    1a37:	cmp    rax,rdx
    1a3a:	cmovge rcx,QWORD PTR [rip+0x146]        # 1b88 <botlish_fn_14+0x230>
    1a42:	cmp    rcx,0x6
    1a46:	je     1ae6 <botlish_fn_14+0x18e>
    1a4c:	mov    rdi,r14
    1a4f:	call   1a54 <botlish_fn_14+0xfc>
			1a50: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1a54:	test   rax,rax
    1a57:	jne    1a65 <botlish_fn_14+0x10d>
    1a5d:	mov    rdi,r14
    1a60:	jmp    1b01 <botlish_fn_14+0x1a9>
    1a65:	mov    QWORD PTR [r12+0x20],rax
    1a6a:	mov    rcx,rax
    1a6d:	mov    QWORD PTR [r12+0x28],rdx
    1a72:	mov    r8,rdx
    1a75:	mov    rdx,r13
    1a78:	mov    rsi,rbx
    1a7b:	mov    rdi,r14
    1a7e:	call   1a83 <botlish_fn_14+0x12b>
			1a7f: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_record<str, int, list[mutarray, int]>
    1a83:	test   rax,rax
    1a86:	jne    1a94 <botlish_fn_14+0x13c>
    1a8c:	mov    rdi,r14
    1a8f:	jmp    1b01 <botlish_fn_14+0x1a9>
    1a94:	mov    QWORD PTR [r12+0x8],rax
    1a99:	mov    rcx,rax
    1a9c:	mov    QWORD PTR [r12+0x20],rdx
    1aa1:	mov    r13,rdx
    1aa4:	mov    rsi,QWORD PTR [rsp]
    1aa8:	mov    rdx,r15
    1aab:	mov    rdi,r14
    1aae:	call   1ab3 <botlish_fn_14+0x15b>
			1aaf: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1ab3:	test   rax,rax
    1ab6:	jne    1ac4 <botlish_fn_14+0x16c>
    1abc:	mov    rdi,r14
    1abf:	jmp    1b01 <botlish_fn_14+0x1a9>
    1ac4:	mov    QWORD PTR [r12],rbx
    1ac8:	mov    rcx,r13
    1acb:	mov    QWORD PTR [r12+0x8],rcx
    1ad0:	mov    QWORD PTR [r12+0x10],rax
    1ad5:	mov    QWORD PTR [r12+0x18],rdx
    1ada:	mov    r15,rdx
    1add:	mov    QWORD PTR [rsp],rax
    1ae1:	jmp    19ee <botlish_fn_14+0x96>
    1ae6:	mov    rdx,r15
    1ae9:	mov    rsi,QWORD PTR [rsp]
    1aed:	mov    rdi,r14
    1af0:	call   1af5 <botlish_fn_14+0x19d>
			1af1: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    1af5:	test   rax,rax
    1af8:	jne    1b2c <botlish_fn_14+0x1d4>
    1afe:	mov    rdi,r14
    1b01:	mov    rdi,r14
    1b04:	mov    QWORD PTR [rdi],r12
    1b07:	xor    rax,rax
    1b0a:	mov    rbx,QWORD PTR [rsp+0x10]
    1b0f:	mov    r12,QWORD PTR [rsp+0x18]
    1b14:	mov    r13,QWORD PTR [rsp+0x20]
    1b19:	mov    r14,QWORD PTR [rsp+0x28]
    1b1e:	mov    r15,QWORD PTR [rsp+0x30]
    1b23:	add    rsp,0x40
    1b27:	mov    rsp,rbp
    1b2a:	pop    rbp
    1b2b:	ret
    1b2c:	mov    rdi,r14
    1b2f:	mov    QWORD PTR [rdi],r12
    1b32:	mov    rbx,QWORD PTR [rsp+0x10]
    1b37:	mov    r12,QWORD PTR [rsp+0x18]
    1b3c:	mov    r13,QWORD PTR [rsp+0x20]
    1b41:	mov    r14,QWORD PTR [rsp+0x28]
    1b46:	mov    r15,QWORD PTR [rsp+0x30]
    1b4b:	add    rsp,0x40
    1b4f:	mov    rsp,rbp
    1b52:	pop    rbp
    1b53:	ret
    1b54:	mov    r14,rdi
    1b57:	call   1b5c <botlish_fn_14+0x204>
			1b58: R_X86_64_PLT32	rt_stack_overflow-0x4
    1b5c:	xor    rax,rax
    1b5f:	mov    rbx,QWORD PTR [rsp+0x10]
    1b64:	mov    r12,QWORD PTR [rsp+0x18]
    1b69:	mov    r13,QWORD PTR [rsp+0x20]
    1b6e:	mov    r14,QWORD PTR [rsp+0x28]
    1b73:	mov    r15,QWORD PTR [rsp+0x30]
    1b78:	add    rsp,0x40
    1b7c:	mov    rsp,rbp
    1b7f:	pop    rbp
    1b80:	ret
    1b81:	add    BYTE PTR [rax],al
    1b83:	add    BYTE PTR [rax],al
    1b85:	add    BYTE PTR [rax],al
    1b87:	add    BYTE PTR [rsi],al
    1b89:	add    BYTE PTR [rax],al
    1b8b:	add    BYTE PTR [rax],al
    1b8d:	add    BYTE PTR [rax],al
	...

0000000000001b90 <botlish_entry_14: scan_records<str, int, list[mutarray, int]>>:
    1b90:	push   rbp
    1b91:	mov    rbp,rsp
    1b94:	mov    rsi,QWORD PTR [rdx]
    1b97:	mov    r9,QWORD PTR [rdx+0x8]
    1b9b:	mov    rcx,QWORD PTR [rdx+0x10]
    1b9f:	mov    r8,QWORD PTR [rdx+0x18]
    1ba3:	mov    rdx,r9
    1ba6:	call   1bab <botlish_entry_14+0x1b>
			1ba7: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1bab:	mov    rsp,rbp
    1bae:	pop    rbp
    1baf:	ret

0000000000001bb0 <botlish_fn_15: csv_parse<str>>:
    1bb0:	push   rbp
    1bb1:	mov    rbp,rsp
    1bb4:	sub    rsp,0x20
    1bb8:	mov    QWORD PTR [rsp],rbx
    1bbc:	mov    QWORD PTR [rsp+0x8],r12
    1bc1:	mov    QWORD PTR [rsp+0x10],r15
    1bc6:	mov    r15,QWORD PTR [rdi]
    1bc9:	mov    rax,QWORD PTR [rdi+0x8]
    1bcd:	lea    rcx,[r15+0x20]
    1bd1:	cmp    rcx,rax
    1bd4:	ja     1c91 <botlish_fn_15+0xe1>
    1bda:	lea    rax,[r15+0x20]
    1bde:	mov    QWORD PTR [rdi],rax
    1be1:	mov    rbx,rdi
    1be4:	mov    QWORD PTR [r15],0x0
    1beb:	mov    QWORD PTR [r15+0x8],0x0
    1bf3:	mov    QWORD PTR [r15+0x10],0x0
    1bfb:	mov    QWORD PTR [r15+0x18],0x0
    1c03:	mov    QWORD PTR [r15],rsi
    1c06:	mov    r12,rsi
    1c09:	mov    QWORD PTR [r15+0x8],0x1
    1c11:	mov    rdi,rbx
    1c14:	call   1c19 <botlish_fn_15+0x69>
			1c15: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1c19:	test   rax,rax
    1c1c:	jne    1c2a <botlish_fn_15+0x7a>
    1c22:	mov    rdi,rbx
    1c25:	jmp    1c54 <botlish_fn_15+0xa4>
    1c2a:	mov    QWORD PTR [r15+0x10],rax
    1c2e:	mov    rcx,rax
    1c31:	mov    QWORD PTR [r15+0x18],rdx
    1c35:	mov    r8,rdx
    1c38:	mov    edx,0x1
    1c3d:	mov    rsi,r12
    1c40:	mov    rdi,rbx
    1c43:	call   1c48 <botlish_fn_15+0x98>
			1c44: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1c48:	test   rax,rax
    1c4b:	jne    1c74 <botlish_fn_15+0xc4>
    1c51:	mov    rdi,rbx
    1c54:	mov    rdi,rbx
    1c57:	mov    QWORD PTR [rdi],r15
    1c5a:	xor    rax,rax
    1c5d:	mov    rbx,QWORD PTR [rsp]
    1c61:	mov    r12,QWORD PTR [rsp+0x8]
    1c66:	mov    r15,QWORD PTR [rsp+0x10]
    1c6b:	add    rsp,0x20
    1c6f:	mov    rsp,rbp
    1c72:	pop    rbp
    1c73:	ret
    1c74:	mov    rdi,rbx
    1c77:	mov    QWORD PTR [rdi],r15
    1c7a:	mov    rbx,QWORD PTR [rsp]
    1c7e:	mov    r12,QWORD PTR [rsp+0x8]
    1c83:	mov    r15,QWORD PTR [rsp+0x10]
    1c88:	add    rsp,0x20
    1c8c:	mov    rsp,rbp
    1c8f:	pop    rbp
    1c90:	ret
    1c91:	mov    rbx,rdi
    1c94:	call   1c99 <botlish_fn_15+0xe9>
			1c95: R_X86_64_PLT32	rt_stack_overflow-0x4
    1c99:	xor    rax,rax
    1c9c:	mov    rbx,QWORD PTR [rsp]
    1ca0:	mov    r12,QWORD PTR [rsp+0x8]
    1ca5:	mov    r15,QWORD PTR [rsp+0x10]
    1caa:	add    rsp,0x20
    1cae:	mov    rsp,rbp
    1cb1:	pop    rbp
    1cb2:	ret

0000000000001cb3 <botlish_entry_15: csv_parse<str>>:
    1cb3:	push   rbp
    1cb4:	mov    rbp,rsp
    1cb7:	mov    rsi,QWORD PTR [rdx]
    1cba:	call   1cbf <botlish_entry_15+0xc>
			1cbb: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    1cbf:	mov    rsp,rbp
    1cc2:	pop    rbp
    1cc3:	ret

0000000000001cc4 <botlish_fn_16: ht_min_capacity<generic>>:
    1cc4:	push   rbp
    1cc5:	mov    rbp,rsp
    1cc8:	mov    r9,QWORD PTR [rdi]
    1ccb:	mov    r10,QWORD PTR [rdi+0x8]
    1ccf:	lea    r11,[r9+0x8]
    1cd3:	cmp    r11,r10
    1cd6:	ja     1cf7 <botlish_fn_16+0x33>
    1cdc:	lea    r11,[r9+0x8]
    1ce0:	mov    QWORD PTR [rdi],r11
    1ce3:	mov    QWORD PTR [r9],0x0
    1cea:	mov    QWORD PTR [rdi],r9
    1ced:	mov    eax,0x11
    1cf2:	mov    rsp,rbp
    1cf5:	pop    rbp
    1cf6:	ret
    1cf7:	call   1cfc <botlish_fn_16+0x38>
			1cf8: R_X86_64_PLT32	rt_stack_overflow-0x4
    1cfc:	xor    rax,rax
    1cff:	mov    rsp,rbp
    1d02:	pop    rbp
    1d03:	ret

0000000000001d04 <botlish_entry_16: ht_min_capacity<generic>>:
    1d04:	push   rbp
    1d05:	mov    rbp,rsp
    1d08:	call   1d0d <botlish_entry_16+0x9>
			1d09: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    1d0d:	mov    rsp,rbp
    1d10:	pop    rbp
    1d11:	ret

0000000000001d12 <botlish_fn_17: ht_empty_state<generic>>:
    1d12:	push   rbp
    1d13:	mov    rbp,rsp
    1d16:	mov    r9,QWORD PTR [rdi]
    1d19:	mov    r10,QWORD PTR [rdi+0x8]
    1d1d:	lea    r11,[r9+0x8]
    1d21:	cmp    r11,r10
    1d24:	ja     1d45 <botlish_fn_17+0x33>
    1d2a:	lea    r11,[r9+0x8]
    1d2e:	mov    QWORD PTR [rdi],r11
    1d31:	mov    QWORD PTR [r9],0x0
    1d38:	mov    QWORD PTR [rdi],r9
    1d3b:	mov    eax,0x1
    1d40:	mov    rsp,rbp
    1d43:	pop    rbp
    1d44:	ret
    1d45:	call   1d4a <botlish_fn_17+0x38>
			1d46: R_X86_64_PLT32	rt_stack_overflow-0x4
    1d4a:	xor    rax,rax
    1d4d:	mov    rsp,rbp
    1d50:	pop    rbp
    1d51:	ret

0000000000001d52 <botlish_entry_17: ht_empty_state<generic>>:
    1d52:	push   rbp
    1d53:	mov    rbp,rsp
    1d56:	call   1d5b <botlish_entry_17+0x9>
			1d57: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    1d5b:	mov    rsp,rbp
    1d5e:	pop    rbp
    1d5f:	ret

0000000000001d60 <botlish_fn_18: ht_occupied_state<generic>>:
    1d60:	push   rbp
    1d61:	mov    rbp,rsp
    1d64:	mov    r9,QWORD PTR [rdi]
    1d67:	mov    r10,QWORD PTR [rdi+0x8]
    1d6b:	lea    r11,[r9+0x8]
    1d6f:	cmp    r11,r10
    1d72:	ja     1d93 <botlish_fn_18+0x33>
    1d78:	lea    r11,[r9+0x8]
    1d7c:	mov    QWORD PTR [rdi],r11
    1d7f:	mov    QWORD PTR [r9],0x0
    1d86:	mov    QWORD PTR [rdi],r9
    1d89:	mov    eax,0x3
    1d8e:	mov    rsp,rbp
    1d91:	pop    rbp
    1d92:	ret
    1d93:	call   1d98 <botlish_fn_18+0x38>
			1d94: R_X86_64_PLT32	rt_stack_overflow-0x4
    1d98:	xor    rax,rax
    1d9b:	mov    rsp,rbp
    1d9e:	pop    rbp
    1d9f:	ret

0000000000001da0 <botlish_entry_18: ht_occupied_state<generic>>:
    1da0:	push   rbp
    1da1:	mov    rbp,rsp
    1da4:	call   1da9 <botlish_entry_18+0x9>
			1da5: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    1da9:	mov    rsp,rbp
    1dac:	pop    rbp
    1dad:	ret

0000000000001dae <botlish_fn_19: ht_tombstone_state<generic>>:
    1dae:	push   rbp
    1daf:	mov    rbp,rsp
    1db2:	mov    r9,QWORD PTR [rdi]
    1db5:	mov    r10,QWORD PTR [rdi+0x8]
    1db9:	lea    r11,[r9+0x8]
    1dbd:	cmp    r11,r10
    1dc0:	ja     1de1 <botlish_fn_19+0x33>
    1dc6:	lea    r11,[r9+0x8]
    1dca:	mov    QWORD PTR [rdi],r11
    1dcd:	mov    QWORD PTR [r9],0x0
    1dd4:	mov    QWORD PTR [rdi],r9
    1dd7:	mov    eax,0x5
    1ddc:	mov    rsp,rbp
    1ddf:	pop    rbp
    1de0:	ret
    1de1:	call   1de6 <botlish_fn_19+0x38>
			1de2: R_X86_64_PLT32	rt_stack_overflow-0x4
    1de6:	xor    rax,rax
    1de9:	mov    rsp,rbp
    1dec:	pop    rbp
    1ded:	ret

0000000000001dee <botlish_entry_19: ht_tombstone_state<generic>>:
    1dee:	push   rbp
    1def:	mov    rbp,rsp
    1df2:	call   1df7 <botlish_entry_19+0x9>
			1df3: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    1df7:	mov    rsp,rbp
    1dfa:	pop    rbp
    1dfb:	ret
    1dfc:	add    BYTE PTR [rax],al
	...

0000000000001e00 <botlish_fn_20: ht_fill_empty<mutarray, int, int>>:
    1e00:	push   rbp
    1e01:	mov    rbp,rsp
    1e04:	sub    rsp,0x30
    1e08:	mov    QWORD PTR [rsp],rbx
    1e0c:	mov    QWORD PTR [rsp+0x8],r12
    1e11:	mov    QWORD PTR [rsp+0x10],r13
    1e16:	mov    QWORD PTR [rsp+0x18],r14
    1e1b:	mov    QWORD PTR [rsp+0x20],r15
    1e20:	mov    r13,QWORD PTR [rdi]
    1e23:	mov    r8,QWORD PTR [rdi+0x8]
    1e27:	lea    rax,[r13+0x20]
    1e2b:	cmp    rax,r8
    1e2e:	ja     1fb0 <botlish_fn_20+0x1b0>
    1e34:	lea    rax,[r13+0x20]
    1e38:	mov    QWORD PTR [rdi],rax
    1e3b:	mov    r14,rdi
    1e3e:	mov    QWORD PTR [r13+0x0],0x0
    1e46:	mov    QWORD PTR [r13+0x8],0x0
    1e4e:	mov    QWORD PTR [r13+0x10],0x0
    1e56:	mov    QWORD PTR [r13+0x18],0x0
    1e5e:	mov    QWORD PTR [r13+0x0],rsi
    1e62:	mov    r12,rsi
    1e65:	mov    QWORD PTR [r13+0x8],rdx
    1e69:	mov    QWORD PTR [r13+0x10],rcx
    1e6d:	mov    rbx,rcx
    1e70:	mov    rsi,rdx
    1e73:	mov    rax,rsi
    1e76:	and    rax,rbx
    1e79:	mov    r15,rsi
    1e7c:	test   rax,0x1
    1e82:	jne    1eab <botlish_fn_20+0xab>
    1e88:	mov    rdx,rbx
    1e8b:	mov    rsi,r15
    1e8e:	mov    rdi,r14
    1e91:	call   1e96 <botlish_fn_20+0x96>
			1e92: R_X86_64_PLT32	rt_int_cmp-0x4
    1e96:	mov    ecx,0x2
    1e9b:	test   rax,rax
    1e9e:	cmovge rcx,QWORD PTR [rip+0x13a]        # 1fe0 <botlish_fn_20+0x1e0>
    1ea6:	jmp    1ebe <botlish_fn_20+0xbe>
    1eab:	mov    ecx,0x2
    1eb0:	mov    rsi,r15
    1eb3:	cmp    rsi,rbx
    1eb6:	cmovge rcx,QWORD PTR [rip+0x122]        # 1fe0 <botlish_fn_20+0x1e0>
    1ebe:	cmp    rcx,0x6
    1ec2:	je     1f84 <botlish_fn_20+0x184>
    1ec8:	mov    rdi,r14
    1ecb:	call   1ed0 <botlish_fn_20+0xd0>
			1ecc: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    1ed0:	test   rax,rax
    1ed3:	mov    rcx,rax
    1ed6:	jne    1ee4 <botlish_fn_20+0xe4>
    1edc:	mov    rdi,r14
    1edf:	jmp    1efe <botlish_fn_20+0xfe>
    1ee4:	mov    rdx,r15
    1ee7:	mov    rsi,r12
    1eea:	mov    rdi,r14
    1eed:	call   1ef2 <botlish_fn_20+0xf2>
			1eee: R_X86_64_PLT32	rt_mutarray_set-0x4
    1ef2:	test   rax,rax
    1ef5:	jne    1f28 <botlish_fn_20+0x128>
    1efb:	mov    rdi,r14
    1efe:	mov    rdi,r14
    1f01:	mov    QWORD PTR [rdi],r13
    1f04:	xor    rax,rax
    1f07:	mov    rbx,QWORD PTR [rsp]
    1f0b:	mov    r12,QWORD PTR [rsp+0x8]
    1f10:	mov    r13,QWORD PTR [rsp+0x10]
    1f15:	mov    r14,QWORD PTR [rsp+0x18]
    1f1a:	mov    r15,QWORD PTR [rsp+0x20]
    1f1f:	add    rsp,0x30
    1f23:	mov    rsp,rbp
    1f26:	pop    rbp
    1f27:	ret
    1f28:	mov    QWORD PTR [r13+0x18],0x3
    1f30:	mov    rsi,r15
    1f33:	test   rsi,0x1
    1f3a:	je     1f5d <botlish_fn_20+0x15d>
    1f40:	mov    rsi,r15
    1f43:	mov    rcx,rsi
    1f46:	add    rcx,0x2
    1f4a:	seto   al
    1f4d:	test   al,al
    1f4f:	jne    1f5d <botlish_fn_20+0x15d>
    1f55:	mov    r15,rcx
    1f58:	jmp    1f70 <botlish_fn_20+0x170>
    1f5d:	mov    edx,0x3
    1f62:	mov    rsi,r15
    1f65:	mov    rdi,r14
    1f68:	call   1f6d <botlish_fn_20+0x16d>
			1f69: R_X86_64_PLT32	rt_int_add-0x4
    1f6d:	mov    r15,rax
    1f70:	mov    QWORD PTR [r13+0x0],r12
    1f74:	mov    rsi,r15
    1f77:	mov    QWORD PTR [r13+0x8],rsi
    1f7b:	mov    QWORD PTR [r13+0x10],rbx
    1f7f:	jmp    1e73 <botlish_fn_20+0x73>
    1f84:	mov    rdi,r14
    1f87:	mov    QWORD PTR [rdi],r13
    1f8a:	mov    eax,0xa
    1f8f:	mov    rbx,QWORD PTR [rsp]
    1f93:	mov    r12,QWORD PTR [rsp+0x8]
    1f98:	mov    r13,QWORD PTR [rsp+0x10]
    1f9d:	mov    r14,QWORD PTR [rsp+0x18]
    1fa2:	mov    r15,QWORD PTR [rsp+0x20]
    1fa7:	add    rsp,0x30
    1fab:	mov    rsp,rbp
    1fae:	pop    rbp
    1faf:	ret
    1fb0:	mov    r14,rdi
    1fb3:	call   1fb8 <botlish_fn_20+0x1b8>
			1fb4: R_X86_64_PLT32	rt_stack_overflow-0x4
    1fb8:	xor    rax,rax
    1fbb:	mov    rbx,QWORD PTR [rsp]
    1fbf:	mov    r12,QWORD PTR [rsp+0x8]
    1fc4:	mov    r13,QWORD PTR [rsp+0x10]
    1fc9:	mov    r14,QWORD PTR [rsp+0x18]
    1fce:	mov    r15,QWORD PTR [rsp+0x20]
    1fd3:	add    rsp,0x30
    1fd7:	mov    rsp,rbp
    1fda:	pop    rbp
    1fdb:	ret
    1fdc:	add    BYTE PTR [rax],al
    1fde:	add    BYTE PTR [rax],al
    1fe0:	(bad)
    1fe1:	add    BYTE PTR [rax],al
    1fe3:	add    BYTE PTR [rax],al
    1fe5:	add    BYTE PTR [rax],al
	...

0000000000001fe8 <botlish_entry_20: ht_fill_empty<mutarray, int, int>>:
    1fe8:	push   rbp
    1fe9:	mov    rbp,rsp
    1fec:	mov    rsi,QWORD PTR [rdx]
    1fef:	mov    r8,QWORD PTR [rdx+0x8]
    1ff3:	mov    rcx,QWORD PTR [rdx+0x10]
    1ff7:	mov    rdx,r8
    1ffa:	call   1fff <botlish_entry_20+0x17>
			1ffb: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    1fff:	mov    rsp,rbp
    2002:	pop    rbp
    2003:	ret

0000000000002004 <botlish_fn_21: ht_alloc<int>>:
    2004:	push   rbp
    2005:	mov    rbp,rsp
    2008:	sub    rsp,0x40
    200c:	mov    QWORD PTR [rsp+0x10],rbx
    2011:	mov    QWORD PTR [rsp+0x18],r12
    2016:	mov    QWORD PTR [rsp+0x20],r13
    201b:	mov    QWORD PTR [rsp+0x28],r14
    2020:	mov    QWORD PTR [rsp+0x30],r15
    2025:	mov    rbx,QWORD PTR [rdi]
    2028:	mov    rax,QWORD PTR [rdi+0x8]
    202c:	lea    rcx,[rbx+0x20]
    2030:	cmp    rcx,rax
    2033:	ja     2235 <botlish_fn_21+0x231>
    2039:	lea    rax,[rbx+0x20]
    203d:	mov    QWORD PTR [rdi],rax
    2040:	mov    r12,rdi
    2043:	mov    QWORD PTR [rbx],0x0
    204a:	mov    QWORD PTR [rbx+0x8],0x0
    2052:	mov    QWORD PTR [rbx+0x10],0x0
    205a:	mov    QWORD PTR [rbx+0x18],0x0
    2062:	mov    QWORD PTR [rbx],rsi
    2065:	mov    r13,rsi
    2068:	mov    rsi,r13
    206b:	mov    rdi,r12
    206e:	call   2073 <botlish_fn_21+0x6f>
			206f: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2073:	test   rax,rax
    2076:	jne    2084 <botlish_fn_21+0x80>
    207c:	mov    rdi,r12
    207f:	jmp    21de <botlish_fn_21+0x1da>
    2084:	mov    QWORD PTR [rbx+0x8],rax
    2088:	mov    r14,rax
    208b:	mov    edx,0x1
    2090:	mov    QWORD PTR [rbx+0x10],0x1
    2098:	mov    rcx,r13
    209b:	mov    rsi,r14
    209e:	mov    rdi,r12
    20a1:	call   20a6 <botlish_fn_21+0xa2>
			20a2: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    20a6:	test   rax,rax
    20a9:	jne    20b7 <botlish_fn_21+0xb3>
    20af:	mov    rdi,r12
    20b2:	jmp    21de <botlish_fn_21+0x1da>
    20b7:	mov    rsi,r13
    20ba:	mov    rdi,r12
    20bd:	call   20c2 <botlish_fn_21+0xbe>
			20be: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    20c2:	test   rax,rax
    20c5:	jne    20d3 <botlish_fn_21+0xcf>
    20cb:	mov    rdi,r12
    20ce:	jmp    21de <botlish_fn_21+0x1da>
    20d3:	mov    QWORD PTR [rbx+0x10],rax
    20d7:	mov    rsi,r13
    20da:	mov    r15,rax
    20dd:	mov    rdi,r12
    20e0:	call   20e5 <botlish_fn_21+0xe1>
			20e1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    20e5:	test   rax,rax
    20e8:	jne    20f6 <botlish_fn_21+0xf2>
    20ee:	mov    rdi,r12
    20f1:	jmp    21de <botlish_fn_21+0x1da>
    20f6:	mov    QWORD PTR [rbx],rax
    20f9:	mov    r13,rax
    20fc:	mov    esi,0xb
    2101:	mov    QWORD PTR [rbx+0x18],0xb
    2109:	mov    rdi,r12
    210c:	call   2111 <botlish_fn_21+0x10d>
			210d: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    2111:	test   rax,rax
    2114:	mov    QWORD PTR [rsp],rax
    2118:	jne    2126 <botlish_fn_21+0x122>
    211e:	mov    rdi,r12
    2121:	jmp    21de <botlish_fn_21+0x1da>
    2126:	mov    edx,0x1
    212b:	mov    rcx,r14
    212e:	mov    rsi,QWORD PTR [rsp]
    2132:	mov    rdi,r12
    2135:	call   213a <botlish_fn_21+0x136>
			2136: R_X86_64_PLT32	rt_mutarray_set-0x4
    213a:	test   rax,rax
    213d:	jne    214b <botlish_fn_21+0x147>
    2143:	mov    rdi,r12
    2146:	jmp    21de <botlish_fn_21+0x1da>
    214b:	mov    edx,0x3
    2150:	mov    rcx,r15
    2153:	mov    rsi,QWORD PTR [rsp]
    2157:	mov    rdi,r12
    215a:	call   215f <botlish_fn_21+0x15b>
			215b: R_X86_64_PLT32	rt_mutarray_set-0x4
    215f:	test   rax,rax
    2162:	jne    2170 <botlish_fn_21+0x16c>
    2168:	mov    rdi,r12
    216b:	jmp    21de <botlish_fn_21+0x1da>
    2170:	mov    edx,0x5
    2175:	mov    rcx,r13
    2178:	mov    rsi,QWORD PTR [rsp]
    217c:	mov    rdi,r12
    217f:	call   2184 <botlish_fn_21+0x180>
			2180: R_X86_64_PLT32	rt_mutarray_set-0x4
    2184:	test   rax,rax
    2187:	jne    2195 <botlish_fn_21+0x191>
    218d:	mov    rdi,r12
    2190:	jmp    21de <botlish_fn_21+0x1da>
    2195:	mov    edx,0x7
    219a:	mov    ecx,0x1
    219f:	mov    rsi,QWORD PTR [rsp]
    21a3:	mov    rdi,r12
    21a6:	call   21ab <botlish_fn_21+0x1a7>
			21a7: R_X86_64_PLT32	rt_mutarray_set-0x4
    21ab:	test   rax,rax
    21ae:	jne    21bc <botlish_fn_21+0x1b8>
    21b4:	mov    rdi,r12
    21b7:	jmp    21de <botlish_fn_21+0x1da>
    21bc:	mov    edx,0x9
    21c1:	mov    ecx,0x1
    21c6:	mov    rsi,QWORD PTR [rsp]
    21ca:	mov    rdi,r12
    21cd:	call   21d2 <botlish_fn_21+0x1ce>
			21ce: R_X86_64_PLT32	rt_mutarray_set-0x4
    21d2:	test   rax,rax
    21d5:	jne    2209 <botlish_fn_21+0x205>
    21db:	mov    rdi,r12
    21de:	mov    rdi,r12
    21e1:	mov    QWORD PTR [rdi],rbx
    21e4:	xor    rax,rax
    21e7:	mov    rbx,QWORD PTR [rsp+0x10]
    21ec:	mov    r12,QWORD PTR [rsp+0x18]
    21f1:	mov    r13,QWORD PTR [rsp+0x20]
    21f6:	mov    r14,QWORD PTR [rsp+0x28]
    21fb:	mov    r15,QWORD PTR [rsp+0x30]
    2200:	add    rsp,0x40
    2204:	mov    rsp,rbp
    2207:	pop    rbp
    2208:	ret
    2209:	mov    rdi,r12
    220c:	mov    QWORD PTR [rdi],rbx
    220f:	mov    rax,QWORD PTR [rsp]
    2213:	mov    rbx,QWORD PTR [rsp+0x10]
    2218:	mov    r12,QWORD PTR [rsp+0x18]
    221d:	mov    r13,QWORD PTR [rsp+0x20]
    2222:	mov    r14,QWORD PTR [rsp+0x28]
    2227:	mov    r15,QWORD PTR [rsp+0x30]
    222c:	add    rsp,0x40
    2230:	mov    rsp,rbp
    2233:	pop    rbp
    2234:	ret
    2235:	mov    r12,rdi
    2238:	call   223d <botlish_fn_21+0x239>
			2239: R_X86_64_PLT32	rt_stack_overflow-0x4
    223d:	xor    rax,rax
    2240:	mov    rbx,QWORD PTR [rsp+0x10]
    2245:	mov    r12,QWORD PTR [rsp+0x18]
    224a:	mov    r13,QWORD PTR [rsp+0x20]
    224f:	mov    r14,QWORD PTR [rsp+0x28]
    2254:	mov    r15,QWORD PTR [rsp+0x30]
    2259:	add    rsp,0x40
    225d:	mov    rsp,rbp
    2260:	pop    rbp
    2261:	ret

0000000000002262 <botlish_entry_21: ht_alloc<int>>:
    2262:	push   rbp
    2263:	mov    rbp,rsp
    2266:	mov    rsi,QWORD PTR [rdx]
    2269:	call   226e <botlish_entry_21+0xc>
			226a: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    226e:	mov    rsp,rbp
    2271:	pop    rbp
    2272:	ret

0000000000002273 <botlish_fn_22: ht_new<generic>>:
    2273:	push   rbp
    2274:	mov    rbp,rsp
    2277:	sub    rsp,0x10
    227b:	mov    QWORD PTR [rsp],r12
    227f:	mov    QWORD PTR [rsp+0x8],r13
    2284:	mov    r12,QWORD PTR [rdi]
    2287:	mov    rax,QWORD PTR [rdi+0x8]
    228b:	lea    rcx,[r12+0x8]
    2290:	cmp    rcx,rax
    2293:	ja     2313 <botlish_fn_22+0xa0>
    2299:	lea    rax,[r12+0x8]
    229e:	mov    QWORD PTR [rdi],rax
    22a1:	mov    r13,rdi
    22a4:	mov    QWORD PTR [r12],0x0
    22ac:	mov    rdi,r13
    22af:	call   22b4 <botlish_fn_22+0x41>
			22b0: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    22b4:	test   rax,rax
    22b7:	jne    22c5 <botlish_fn_22+0x52>
    22bd:	mov    rdi,r13
    22c0:	jmp    22e0 <botlish_fn_22+0x6d>
    22c5:	mov    QWORD PTR [r12],rax
    22c9:	mov    rsi,rax
    22cc:	mov    rdi,r13
    22cf:	call   22d4 <botlish_fn_22+0x61>
			22d0: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    22d4:	test   rax,rax
    22d7:	jne    22fb <botlish_fn_22+0x88>
    22dd:	mov    rdi,r13
    22e0:	mov    rdi,r13
    22e3:	mov    QWORD PTR [rdi],r12
    22e6:	xor    rax,rax
    22e9:	mov    r12,QWORD PTR [rsp]
    22ed:	mov    r13,QWORD PTR [rsp+0x8]
    22f2:	add    rsp,0x10
    22f6:	mov    rsp,rbp
    22f9:	pop    rbp
    22fa:	ret
    22fb:	mov    rdi,r13
    22fe:	mov    QWORD PTR [rdi],r12
    2301:	mov    r12,QWORD PTR [rsp]
    2305:	mov    r13,QWORD PTR [rsp+0x8]
    230a:	add    rsp,0x10
    230e:	mov    rsp,rbp
    2311:	pop    rbp
    2312:	ret
    2313:	mov    r13,rdi
    2316:	call   231b <botlish_fn_22+0xa8>
			2317: R_X86_64_PLT32	rt_stack_overflow-0x4
    231b:	xor    rax,rax
    231e:	mov    r12,QWORD PTR [rsp]
    2322:	mov    r13,QWORD PTR [rsp+0x8]
    2327:	add    rsp,0x10
    232b:	mov    rsp,rbp
    232e:	pop    rbp
    232f:	ret

0000000000002330 <botlish_entry_22: ht_new<generic>>:
    2330:	push   rbp
    2331:	mov    rbp,rsp
    2334:	call   2339 <botlish_entry_22+0x9>
			2335: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    2339:	mov    rsp,rbp
    233c:	pop    rbp
    233d:	ret
	...

0000000000002340 <botlish_fn_23: ht_capacity_for<int, int>>:
    2340:	push   rbp
    2341:	mov    rbp,rsp
    2344:	sub    rsp,0x40
    2348:	mov    QWORD PTR [rsp+0x10],rbx
    234d:	mov    QWORD PTR [rsp+0x18],r12
    2352:	mov    QWORD PTR [rsp+0x20],r13
    2357:	mov    QWORD PTR [rsp+0x28],r14
    235c:	mov    QWORD PTR [rsp+0x30],r15
    2361:	mov    rbx,QWORD PTR [rdi]
    2364:	mov    rax,QWORD PTR [rdi+0x8]
    2368:	lea    rcx,[rbx+0x18]
    236c:	cmp    rcx,rax
    236f:	ja     251d <botlish_fn_23+0x1dd>
    2375:	lea    rax,[rbx+0x18]
    2379:	mov    QWORD PTR [rdi],rax
    237c:	mov    r14,rdi
    237f:	mov    QWORD PTR [rbx],0x0
    2386:	mov    QWORD PTR [rbx+0x8],0x0
    238e:	mov    QWORD PTR [rbx+0x10],0x0
    2396:	mov    QWORD PTR [rbx],rdx
    2399:	mov    r12,rsi
    239c:	or     r12,0x1
    23a0:	sar    r12,1
    23a3:	mov    r13,rsi
    23a6:	mov    r15,rdx
    23a9:	mov    rax,r13
    23ac:	or     rax,0x1
    23b0:	mov    QWORD PTR [rbx+0x8],rax
    23b4:	mov    QWORD PTR [rbx+0x10],0x7
    23bc:	mov    rax,r12
    23bf:	imul   QWORD PTR [rip+0x18a]        # 2550 <botlish_fn_23+0x210>
    23c6:	seto   cl
    23c9:	or     rax,0x1
    23cd:	test   cl,cl
    23cf:	jne    23dd <botlish_fn_23+0x9d>
    23d5:	mov    rsi,rax
    23d8:	jmp    23f4 <botlish_fn_23+0xb4>
    23dd:	mov    rsi,r13
    23e0:	or     rsi,0x1
    23e4:	mov    edx,0x7
    23e9:	mov    rdi,r14
    23ec:	call   23f1 <botlish_fn_23+0xb1>
			23ed: R_X86_64_PLT32	rt_int_mul-0x4
    23f1:	mov    rsi,rax
    23f4:	mov    QWORD PTR [rbx+0x8],rsi
    23f8:	mov    QWORD PTR [rsp],rsi
    23fc:	mov    QWORD PTR [rbx+0x10],0x5
    2404:	mov    rsi,r15
    2407:	test   rsi,0x1
    240e:	je     243f <botlish_fn_23+0xff>
    2414:	mov    rsi,r15
    2417:	mov    rax,rsi
    241a:	sar    rax,1
    241d:	imul   QWORD PTR [rip+0x134]        # 2558 <botlish_fn_23+0x218>
    2424:	seto   dl
    2427:	or     rax,0x1
    242b:	test   dl,dl
    242d:	jne    243f <botlish_fn_23+0xff>
    2433:	mov    rdx,rax
    2436:	mov    rsi,QWORD PTR [rsp]
    243a:	jmp    2456 <botlish_fn_23+0x116>
    243f:	mov    edx,0x5
    2444:	mov    rsi,r15
    2447:	mov    rdi,r14
    244a:	call   244f <botlish_fn_23+0x10f>
			244b: R_X86_64_PLT32	rt_int_mul-0x4
    244f:	mov    rdx,rax
    2452:	mov    rsi,QWORD PTR [rsp]
    2456:	mov    rdi,rsi
    2459:	and    rdi,rdx
    245c:	test   rdi,0x1
    2463:	jne    2486 <botlish_fn_23+0x146>
    2469:	mov    rdi,r14
    246c:	call   2471 <botlish_fn_23+0x131>
			246d: R_X86_64_PLT32	rt_int_cmp-0x4
    2471:	mov    ecx,0x2
    2476:	test   rax,rax
    2479:	cmovle rcx,QWORD PTR [rip+0xcf]        # 2550 <botlish_fn_23+0x210>
    2481:	jmp    2496 <botlish_fn_23+0x156>
    2486:	mov    ecx,0x2
    248b:	cmp    rsi,rdx
    248e:	cmovle rcx,QWORD PTR [rip+0xba]        # 2550 <botlish_fn_23+0x210>
    2496:	cmp    rcx,0x6
    249a:	je     24f2 <botlish_fn_23+0x1b2>
    24a0:	mov    QWORD PTR [rbx+0x8],0x5
    24a8:	mov    rsi,r15
    24ab:	test   rsi,0x1
    24b2:	je     24d7 <botlish_fn_23+0x197>
    24b8:	mov    rsi,r15
    24bb:	mov    rax,rsi
    24be:	sar    rax,1
    24c1:	imul   QWORD PTR [rip+0x90]        # 2558 <botlish_fn_23+0x218>
    24c8:	seto   cl
    24cb:	or     rax,0x1
    24cf:	test   cl,cl
    24d1:	je     24e7 <botlish_fn_23+0x1a7>
    24d7:	mov    edx,0x5
    24dc:	mov    rsi,r15
    24df:	mov    rdi,r14
    24e2:	call   24e7 <botlish_fn_23+0x1a7>
			24e3: R_X86_64_PLT32	rt_int_mul-0x4
    24e7:	mov    QWORD PTR [rbx],rax
    24ea:	mov    r15,rax
    24ed:	jmp    23a9 <botlish_fn_23+0x69>
    24f2:	mov    rdi,r14
    24f5:	mov    QWORD PTR [rdi],rbx
    24f8:	mov    rax,r15
    24fb:	mov    rbx,QWORD PTR [rsp+0x10]
    2500:	mov    r12,QWORD PTR [rsp+0x18]
    2505:	mov    r13,QWORD PTR [rsp+0x20]
    250a:	mov    r14,QWORD PTR [rsp+0x28]
    250f:	mov    r15,QWORD PTR [rsp+0x30]
    2514:	add    rsp,0x40
    2518:	mov    rsp,rbp
    251b:	pop    rbp
    251c:	ret
    251d:	mov    r14,rdi
    2520:	call   2525 <botlish_fn_23+0x1e5>
			2521: R_X86_64_PLT32	rt_stack_overflow-0x4
    2525:	xor    rax,rax
    2528:	mov    rbx,QWORD PTR [rsp+0x10]
    252d:	mov    r12,QWORD PTR [rsp+0x18]
    2532:	mov    r13,QWORD PTR [rsp+0x20]
    2537:	mov    r14,QWORD PTR [rsp+0x28]
    253c:	mov    r15,QWORD PTR [rsp+0x30]
    2541:	add    rsp,0x40
    2545:	mov    rsp,rbp
    2548:	pop    rbp
    2549:	ret
    254a:	add    BYTE PTR [rax],al
    254c:	add    BYTE PTR [rax],al
    254e:	add    BYTE PTR [rax],al
    2550:	(bad)
    2551:	add    BYTE PTR [rax],al
    2553:	add    BYTE PTR [rax],al
    2555:	add    BYTE PTR [rax],al
    2557:	add    BYTE PTR [rax+rax*1],al
    255a:	add    BYTE PTR [rax],al
    255c:	add    BYTE PTR [rax],al
	...

0000000000002560 <botlish_entry_23: ht_capacity_for<int, int>>:
    2560:	push   rbp
    2561:	mov    rbp,rsp
    2564:	mov    rsi,QWORD PTR [rdx]
    2567:	mov    rdx,QWORD PTR [rdx+0x8]
    256b:	call   2570 <botlish_entry_23+0x10>
			256c: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    2570:	mov    rsp,rbp
    2573:	pop    rbp
    2574:	ret

0000000000002575 <botlish_fn_24: ht_new_sized<int>>:
    2575:	push   rbp
    2576:	mov    rbp,rsp
    2579:	sub    rsp,0x20
    257d:	mov    QWORD PTR [rsp],rbx
    2581:	mov    QWORD PTR [rsp+0x8],r14
    2586:	mov    QWORD PTR [rsp+0x10],r15
    258b:	mov    r14,QWORD PTR [rdi]
    258e:	mov    rax,QWORD PTR [rdi+0x8]
    2592:	lea    rcx,[r14+0x10]
    2596:	cmp    rcx,rax
    2599:	ja     2651 <botlish_fn_24+0xdc>
    259f:	lea    rax,[r14+0x10]
    25a3:	mov    QWORD PTR [rdi],rax
    25a6:	mov    r15,rdi
    25a9:	mov    QWORD PTR [r14],0x0
    25b0:	mov    QWORD PTR [r14+0x8],0x0
    25b8:	mov    QWORD PTR [r14],rsi
    25bb:	mov    rbx,rsi
    25be:	mov    rdi,r15
    25c1:	call   25c6 <botlish_fn_24+0x51>
			25c2: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    25c6:	test   rax,rax
    25c9:	jne    25d7 <botlish_fn_24+0x62>
    25cf:	mov    rdi,r15
    25d2:	jmp    2614 <botlish_fn_24+0x9f>
    25d7:	mov    QWORD PTR [r14+0x8],rax
    25db:	mov    rdx,rax
    25de:	mov    rsi,rbx
    25e1:	mov    rdi,r15
    25e4:	call   25e9 <botlish_fn_24+0x74>
			25e5: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    25e9:	test   rax,rax
    25ec:	jne    25fa <botlish_fn_24+0x85>
    25f2:	mov    rdi,r15
    25f5:	jmp    2614 <botlish_fn_24+0x9f>
    25fa:	mov    QWORD PTR [r14],rax
    25fd:	mov    rsi,rax
    2600:	mov    rdi,r15
    2603:	call   2608 <botlish_fn_24+0x93>
			2604: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    2608:	test   rax,rax
    260b:	jne    2634 <botlish_fn_24+0xbf>
    2611:	mov    rdi,r15
    2614:	mov    rdi,r15
    2617:	mov    QWORD PTR [rdi],r14
    261a:	xor    rax,rax
    261d:	mov    rbx,QWORD PTR [rsp]
    2621:	mov    r14,QWORD PTR [rsp+0x8]
    2626:	mov    r15,QWORD PTR [rsp+0x10]
    262b:	add    rsp,0x20
    262f:	mov    rsp,rbp
    2632:	pop    rbp
    2633:	ret
    2634:	mov    rdi,r15
    2637:	mov    QWORD PTR [rdi],r14
    263a:	mov    rbx,QWORD PTR [rsp]
    263e:	mov    r14,QWORD PTR [rsp+0x8]
    2643:	mov    r15,QWORD PTR [rsp+0x10]
    2648:	add    rsp,0x20
    264c:	mov    rsp,rbp
    264f:	pop    rbp
    2650:	ret
    2651:	mov    r15,rdi
    2654:	call   2659 <botlish_fn_24+0xe4>
			2655: R_X86_64_PLT32	rt_stack_overflow-0x4
    2659:	xor    rax,rax
    265c:	mov    rbx,QWORD PTR [rsp]
    2660:	mov    r14,QWORD PTR [rsp+0x8]
    2665:	mov    r15,QWORD PTR [rsp+0x10]
    266a:	add    rsp,0x20
    266e:	mov    rsp,rbp
    2671:	pop    rbp
    2672:	ret

0000000000002673 <botlish_entry_24: ht_new_sized<int>>:
    2673:	push   rbp
    2674:	mov    rbp,rsp
    2677:	mov    rsi,QWORD PTR [rdx]
    267a:	call   267f <botlish_entry_24+0xc>
			267b: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    267f:	mov    rsp,rbp
    2682:	pop    rbp
    2683:	ret

0000000000002684 <botlish_fn_25: ht_controls<mutarray>>:
    2684:	push   rbp
    2685:	mov    rbp,rsp
    2688:	sub    rsp,0x10
    268c:	mov    QWORD PTR [rsp],r13
    2690:	mov    QWORD PTR [rsp+0x8],r14
    2695:	mov    r13,QWORD PTR [rdi]
    2698:	mov    rax,QWORD PTR [rdi+0x8]
    269c:	lea    rcx,[r13+0x8]
    26a0:	cmp    rcx,rax
    26a3:	ja     2704 <botlish_fn_25+0x80>
    26a9:	lea    rax,[r13+0x8]
    26ad:	mov    QWORD PTR [rdi],rax
    26b0:	mov    r14,rdi
    26b3:	mov    QWORD PTR [r13+0x0],0x0
    26bb:	mov    edx,0x1
    26c0:	mov    rdi,r14
    26c3:	call   26c8 <botlish_fn_25+0x44>
			26c4: R_X86_64_PLT32	rt_mutarray_get-0x4
    26c8:	test   rax,rax
    26cb:	jne    26ec <botlish_fn_25+0x68>
    26d1:	mov    rdi,r14
    26d4:	mov    QWORD PTR [rdi],r13
    26d7:	xor    rax,rax
    26da:	mov    r13,QWORD PTR [rsp]
    26de:	mov    r14,QWORD PTR [rsp+0x8]
    26e3:	add    rsp,0x10
    26e7:	mov    rsp,rbp
    26ea:	pop    rbp
    26eb:	ret
    26ec:	mov    rdi,r14
    26ef:	mov    QWORD PTR [rdi],r13
    26f2:	mov    r13,QWORD PTR [rsp]
    26f6:	mov    r14,QWORD PTR [rsp+0x8]
    26fb:	add    rsp,0x10
    26ff:	mov    rsp,rbp
    2702:	pop    rbp
    2703:	ret
    2704:	call   2709 <botlish_fn_25+0x85>
			2705: R_X86_64_PLT32	rt_stack_overflow-0x4
    2709:	xor    rax,rax
    270c:	mov    r13,QWORD PTR [rsp]
    2710:	mov    r14,QWORD PTR [rsp+0x8]
    2715:	add    rsp,0x10
    2719:	mov    rsp,rbp
    271c:	pop    rbp
    271d:	ret

000000000000271e <botlish_entry_25: ht_controls<mutarray>>:
    271e:	push   rbp
    271f:	mov    rbp,rsp
    2722:	mov    rsi,QWORD PTR [rdx]
    2725:	call   272a <botlish_entry_25+0xc>
			2726: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    272a:	mov    rsp,rbp
    272d:	pop    rbp
    272e:	ret

000000000000272f <botlish_fn_26: ht_controls<generic>>:
    272f:	push   rbp
    2730:	mov    rbp,rsp
    2733:	sub    rsp,0x10
    2737:	mov    QWORD PTR [rsp],rbx
    273b:	mov    QWORD PTR [rsp+0x8],r12
    2740:	mov    rbx,QWORD PTR [rdi]
    2743:	mov    rax,QWORD PTR [rdi+0x8]
    2747:	lea    rcx,[rbx+0x8]
    274b:	cmp    rcx,rax
    274e:	ja     27eb <botlish_fn_26+0xbc>
    2754:	lea    rax,[rbx+0x8]
    2758:	mov    QWORD PTR [rdi],rax
    275b:	mov    QWORD PTR [rbx],0x0
    2762:	xor    ecx,ecx
    2764:	test   rsi,0x7
    276b:	jne    277a <botlish_fn_26+0x4b>
    2771:	movzx  rax,BYTE PTR [rsi]
    2775:	cmp    al,0x8
    2777:	sete   cl
    277a:	test   cl,cl
    277c:	jne    279f <botlish_fn_26+0x70>
    2782:	mov    rax,QWORD PTR [rdi+0x10]
    2786:	mov    r12,rdi
    2789:	mov    rcx,QWORD PTR [rax+0x20]
    278d:	mov    edx,0x8
    2792:	call   2797 <botlish_fn_26+0x68>
			2793: R_X86_64_PLT32	rt_type_error-0x4
    2797:	mov    rdi,r12
    279a:	jmp    27b8 <botlish_fn_26+0x89>
    279f:	mov    r12,rdi
    27a2:	mov    edx,0x1
    27a7:	call   27ac <botlish_fn_26+0x7d>
			27a8: R_X86_64_PLT32	rt_mutarray_get-0x4
    27ac:	test   rax,rax
    27af:	jne    27d3 <botlish_fn_26+0xa4>
    27b5:	mov    rdi,r12
    27b8:	mov    rdi,r12
    27bb:	mov    QWORD PTR [rdi],rbx
    27be:	xor    rax,rax
    27c1:	mov    rbx,QWORD PTR [rsp]
    27c5:	mov    r12,QWORD PTR [rsp+0x8]
    27ca:	add    rsp,0x10
    27ce:	mov    rsp,rbp
    27d1:	pop    rbp
    27d2:	ret
    27d3:	mov    rdi,r12
    27d6:	mov    QWORD PTR [rdi],rbx
    27d9:	mov    rbx,QWORD PTR [rsp]
    27dd:	mov    r12,QWORD PTR [rsp+0x8]
    27e2:	add    rsp,0x10
    27e6:	mov    rsp,rbp
    27e9:	pop    rbp
    27ea:	ret
    27eb:	mov    r12,rdi
    27ee:	call   27f3 <botlish_fn_26+0xc4>
			27ef: R_X86_64_PLT32	rt_stack_overflow-0x4
    27f3:	xor    rax,rax
    27f6:	mov    rbx,QWORD PTR [rsp]
    27fa:	mov    r12,QWORD PTR [rsp+0x8]
    27ff:	add    rsp,0x10
    2803:	mov    rsp,rbp
    2806:	pop    rbp
    2807:	ret

0000000000002808 <botlish_entry_26: ht_controls<generic>>:
    2808:	push   rbp
    2809:	mov    rbp,rsp
    280c:	mov    rsi,QWORD PTR [rdx]
    280f:	call   2814 <botlish_entry_26+0xc>
			2810: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    2814:	mov    rsp,rbp
    2817:	pop    rbp
    2818:	ret

0000000000002819 <botlish_fn_27: ht_keys<mutarray>>:
    2819:	push   rbp
    281a:	mov    rbp,rsp
    281d:	sub    rsp,0x10
    2821:	mov    QWORD PTR [rsp],r13
    2825:	mov    QWORD PTR [rsp+0x8],r14
    282a:	mov    r13,QWORD PTR [rdi]
    282d:	mov    rax,QWORD PTR [rdi+0x8]
    2831:	lea    rcx,[r13+0x8]
    2835:	cmp    rcx,rax
    2838:	ja     2899 <botlish_fn_27+0x80>
    283e:	lea    rax,[r13+0x8]
    2842:	mov    QWORD PTR [rdi],rax
    2845:	mov    r14,rdi
    2848:	mov    QWORD PTR [r13+0x0],0x0
    2850:	mov    edx,0x3
    2855:	mov    rdi,r14
    2858:	call   285d <botlish_fn_27+0x44>
			2859: R_X86_64_PLT32	rt_mutarray_get-0x4
    285d:	test   rax,rax
    2860:	jne    2881 <botlish_fn_27+0x68>
    2866:	mov    rdi,r14
    2869:	mov    QWORD PTR [rdi],r13
    286c:	xor    rax,rax
    286f:	mov    r13,QWORD PTR [rsp]
    2873:	mov    r14,QWORD PTR [rsp+0x8]
    2878:	add    rsp,0x10
    287c:	mov    rsp,rbp
    287f:	pop    rbp
    2880:	ret
    2881:	mov    rdi,r14
    2884:	mov    QWORD PTR [rdi],r13
    2887:	mov    r13,QWORD PTR [rsp]
    288b:	mov    r14,QWORD PTR [rsp+0x8]
    2890:	add    rsp,0x10
    2894:	mov    rsp,rbp
    2897:	pop    rbp
    2898:	ret
    2899:	call   289e <botlish_fn_27+0x85>
			289a: R_X86_64_PLT32	rt_stack_overflow-0x4
    289e:	xor    rax,rax
    28a1:	mov    r13,QWORD PTR [rsp]
    28a5:	mov    r14,QWORD PTR [rsp+0x8]
    28aa:	add    rsp,0x10
    28ae:	mov    rsp,rbp
    28b1:	pop    rbp
    28b2:	ret

00000000000028b3 <botlish_entry_27: ht_keys<mutarray>>:
    28b3:	push   rbp
    28b4:	mov    rbp,rsp
    28b7:	mov    rsi,QWORD PTR [rdx]
    28ba:	call   28bf <botlish_entry_27+0xc>
			28bb: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    28bf:	mov    rsp,rbp
    28c2:	pop    rbp
    28c3:	ret

00000000000028c4 <botlish_fn_28: ht_keys<generic>>:
    28c4:	push   rbp
    28c5:	mov    rbp,rsp
    28c8:	sub    rsp,0x10
    28cc:	mov    QWORD PTR [rsp],rbx
    28d0:	mov    QWORD PTR [rsp+0x8],r12
    28d5:	mov    rbx,QWORD PTR [rdi]
    28d8:	mov    rax,QWORD PTR [rdi+0x8]
    28dc:	lea    rcx,[rbx+0x8]
    28e0:	cmp    rcx,rax
    28e3:	ja     2980 <botlish_fn_28+0xbc>
    28e9:	lea    rax,[rbx+0x8]
    28ed:	mov    QWORD PTR [rdi],rax
    28f0:	mov    QWORD PTR [rbx],0x0
    28f7:	xor    ecx,ecx
    28f9:	test   rsi,0x7
    2900:	jne    290f <botlish_fn_28+0x4b>
    2906:	movzx  rax,BYTE PTR [rsi]
    290a:	cmp    al,0x8
    290c:	sete   cl
    290f:	test   cl,cl
    2911:	jne    2934 <botlish_fn_28+0x70>
    2917:	mov    rax,QWORD PTR [rdi+0x10]
    291b:	mov    r12,rdi
    291e:	mov    rcx,QWORD PTR [rax+0x20]
    2922:	mov    edx,0x8
    2927:	call   292c <botlish_fn_28+0x68>
			2928: R_X86_64_PLT32	rt_type_error-0x4
    292c:	mov    rdi,r12
    292f:	jmp    294d <botlish_fn_28+0x89>
    2934:	mov    r12,rdi
    2937:	mov    edx,0x3
    293c:	call   2941 <botlish_fn_28+0x7d>
			293d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2941:	test   rax,rax
    2944:	jne    2968 <botlish_fn_28+0xa4>
    294a:	mov    rdi,r12
    294d:	mov    rdi,r12
    2950:	mov    QWORD PTR [rdi],rbx
    2953:	xor    rax,rax
    2956:	mov    rbx,QWORD PTR [rsp]
    295a:	mov    r12,QWORD PTR [rsp+0x8]
    295f:	add    rsp,0x10
    2963:	mov    rsp,rbp
    2966:	pop    rbp
    2967:	ret
    2968:	mov    rdi,r12
    296b:	mov    QWORD PTR [rdi],rbx
    296e:	mov    rbx,QWORD PTR [rsp]
    2972:	mov    r12,QWORD PTR [rsp+0x8]
    2977:	add    rsp,0x10
    297b:	mov    rsp,rbp
    297e:	pop    rbp
    297f:	ret
    2980:	mov    r12,rdi
    2983:	call   2988 <botlish_fn_28+0xc4>
			2984: R_X86_64_PLT32	rt_stack_overflow-0x4
    2988:	xor    rax,rax
    298b:	mov    rbx,QWORD PTR [rsp]
    298f:	mov    r12,QWORD PTR [rsp+0x8]
    2994:	add    rsp,0x10
    2998:	mov    rsp,rbp
    299b:	pop    rbp
    299c:	ret

000000000000299d <botlish_entry_28: ht_keys<generic>>:
    299d:	push   rbp
    299e:	mov    rbp,rsp
    29a1:	mov    rsi,QWORD PTR [rdx]
    29a4:	call   29a9 <botlish_entry_28+0xc>
			29a5: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    29a9:	mov    rsp,rbp
    29ac:	pop    rbp
    29ad:	ret

00000000000029ae <botlish_fn_29: ht_values<mutarray>>:
    29ae:	push   rbp
    29af:	mov    rbp,rsp
    29b2:	sub    rsp,0x10
    29b6:	mov    QWORD PTR [rsp],r13
    29ba:	mov    QWORD PTR [rsp+0x8],r14
    29bf:	mov    r13,QWORD PTR [rdi]
    29c2:	mov    rax,QWORD PTR [rdi+0x8]
    29c6:	lea    rcx,[r13+0x8]
    29ca:	cmp    rcx,rax
    29cd:	ja     2a2e <botlish_fn_29+0x80>
    29d3:	lea    rax,[r13+0x8]
    29d7:	mov    QWORD PTR [rdi],rax
    29da:	mov    r14,rdi
    29dd:	mov    QWORD PTR [r13+0x0],0x0
    29e5:	mov    edx,0x5
    29ea:	mov    rdi,r14
    29ed:	call   29f2 <botlish_fn_29+0x44>
			29ee: R_X86_64_PLT32	rt_mutarray_get-0x4
    29f2:	test   rax,rax
    29f5:	jne    2a16 <botlish_fn_29+0x68>
    29fb:	mov    rdi,r14
    29fe:	mov    QWORD PTR [rdi],r13
    2a01:	xor    rax,rax
    2a04:	mov    r13,QWORD PTR [rsp]
    2a08:	mov    r14,QWORD PTR [rsp+0x8]
    2a0d:	add    rsp,0x10
    2a11:	mov    rsp,rbp
    2a14:	pop    rbp
    2a15:	ret
    2a16:	mov    rdi,r14
    2a19:	mov    QWORD PTR [rdi],r13
    2a1c:	mov    r13,QWORD PTR [rsp]
    2a20:	mov    r14,QWORD PTR [rsp+0x8]
    2a25:	add    rsp,0x10
    2a29:	mov    rsp,rbp
    2a2c:	pop    rbp
    2a2d:	ret
    2a2e:	call   2a33 <botlish_fn_29+0x85>
			2a2f: R_X86_64_PLT32	rt_stack_overflow-0x4
    2a33:	xor    rax,rax
    2a36:	mov    r13,QWORD PTR [rsp]
    2a3a:	mov    r14,QWORD PTR [rsp+0x8]
    2a3f:	add    rsp,0x10
    2a43:	mov    rsp,rbp
    2a46:	pop    rbp
    2a47:	ret

0000000000002a48 <botlish_entry_29: ht_values<mutarray>>:
    2a48:	push   rbp
    2a49:	mov    rbp,rsp
    2a4c:	mov    rsi,QWORD PTR [rdx]
    2a4f:	call   2a54 <botlish_entry_29+0xc>
			2a50: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    2a54:	mov    rsp,rbp
    2a57:	pop    rbp
    2a58:	ret

0000000000002a59 <botlish_fn_30: ht_values<generic>>:
    2a59:	push   rbp
    2a5a:	mov    rbp,rsp
    2a5d:	sub    rsp,0x10
    2a61:	mov    QWORD PTR [rsp],rbx
    2a65:	mov    QWORD PTR [rsp+0x8],r12
    2a6a:	mov    rbx,QWORD PTR [rdi]
    2a6d:	mov    rax,QWORD PTR [rdi+0x8]
    2a71:	lea    rcx,[rbx+0x8]
    2a75:	cmp    rcx,rax
    2a78:	ja     2b15 <botlish_fn_30+0xbc>
    2a7e:	lea    rax,[rbx+0x8]
    2a82:	mov    QWORD PTR [rdi],rax
    2a85:	mov    QWORD PTR [rbx],0x0
    2a8c:	xor    ecx,ecx
    2a8e:	test   rsi,0x7
    2a95:	jne    2aa4 <botlish_fn_30+0x4b>
    2a9b:	movzx  rax,BYTE PTR [rsi]
    2a9f:	cmp    al,0x8
    2aa1:	sete   cl
    2aa4:	test   cl,cl
    2aa6:	jne    2ac9 <botlish_fn_30+0x70>
    2aac:	mov    rax,QWORD PTR [rdi+0x10]
    2ab0:	mov    r12,rdi
    2ab3:	mov    rcx,QWORD PTR [rax+0x20]
    2ab7:	mov    edx,0x8
    2abc:	call   2ac1 <botlish_fn_30+0x68>
			2abd: R_X86_64_PLT32	rt_type_error-0x4
    2ac1:	mov    rdi,r12
    2ac4:	jmp    2ae2 <botlish_fn_30+0x89>
    2ac9:	mov    r12,rdi
    2acc:	mov    edx,0x5
    2ad1:	call   2ad6 <botlish_fn_30+0x7d>
			2ad2: R_X86_64_PLT32	rt_mutarray_get-0x4
    2ad6:	test   rax,rax
    2ad9:	jne    2afd <botlish_fn_30+0xa4>
    2adf:	mov    rdi,r12
    2ae2:	mov    rdi,r12
    2ae5:	mov    QWORD PTR [rdi],rbx
    2ae8:	xor    rax,rax
    2aeb:	mov    rbx,QWORD PTR [rsp]
    2aef:	mov    r12,QWORD PTR [rsp+0x8]
    2af4:	add    rsp,0x10
    2af8:	mov    rsp,rbp
    2afb:	pop    rbp
    2afc:	ret
    2afd:	mov    rdi,r12
    2b00:	mov    QWORD PTR [rdi],rbx
    2b03:	mov    rbx,QWORD PTR [rsp]
    2b07:	mov    r12,QWORD PTR [rsp+0x8]
    2b0c:	add    rsp,0x10
    2b10:	mov    rsp,rbp
    2b13:	pop    rbp
    2b14:	ret
    2b15:	mov    r12,rdi
    2b18:	call   2b1d <botlish_fn_30+0xc4>
			2b19: R_X86_64_PLT32	rt_stack_overflow-0x4
    2b1d:	xor    rax,rax
    2b20:	mov    rbx,QWORD PTR [rsp]
    2b24:	mov    r12,QWORD PTR [rsp+0x8]
    2b29:	add    rsp,0x10
    2b2d:	mov    rsp,rbp
    2b30:	pop    rbp
    2b31:	ret

0000000000002b32 <botlish_entry_30: ht_values<generic>>:
    2b32:	push   rbp
    2b33:	mov    rbp,rsp
    2b36:	mov    rsi,QWORD PTR [rdx]
    2b39:	call   2b3e <botlish_entry_30+0xc>
			2b3a: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    2b3e:	mov    rsp,rbp
    2b41:	pop    rbp
    2b42:	ret

0000000000002b43 <botlish_fn_31: ht_size<mutarray>>:
    2b43:	push   rbp
    2b44:	mov    rbp,rsp
    2b47:	sub    rsp,0x10
    2b4b:	mov    QWORD PTR [rsp],r13
    2b4f:	mov    QWORD PTR [rsp+0x8],r14
    2b54:	mov    r13,QWORD PTR [rdi]
    2b57:	mov    rax,QWORD PTR [rdi+0x8]
    2b5b:	lea    rcx,[r13+0x8]
    2b5f:	cmp    rcx,rax
    2b62:	ja     2bc3 <botlish_fn_31+0x80>
    2b68:	lea    rax,[r13+0x8]
    2b6c:	mov    QWORD PTR [rdi],rax
    2b6f:	mov    r14,rdi
    2b72:	mov    QWORD PTR [r13+0x0],0x0
    2b7a:	mov    edx,0x7
    2b7f:	mov    rdi,r14
    2b82:	call   2b87 <botlish_fn_31+0x44>
			2b83: R_X86_64_PLT32	rt_mutarray_get-0x4
    2b87:	test   rax,rax
    2b8a:	jne    2bab <botlish_fn_31+0x68>
    2b90:	mov    rdi,r14
    2b93:	mov    QWORD PTR [rdi],r13
    2b96:	xor    rax,rax
    2b99:	mov    r13,QWORD PTR [rsp]
    2b9d:	mov    r14,QWORD PTR [rsp+0x8]
    2ba2:	add    rsp,0x10
    2ba6:	mov    rsp,rbp
    2ba9:	pop    rbp
    2baa:	ret
    2bab:	mov    rdi,r14
    2bae:	mov    QWORD PTR [rdi],r13
    2bb1:	mov    r13,QWORD PTR [rsp]
    2bb5:	mov    r14,QWORD PTR [rsp+0x8]
    2bba:	add    rsp,0x10
    2bbe:	mov    rsp,rbp
    2bc1:	pop    rbp
    2bc2:	ret
    2bc3:	call   2bc8 <botlish_fn_31+0x85>
			2bc4: R_X86_64_PLT32	rt_stack_overflow-0x4
    2bc8:	xor    rax,rax
    2bcb:	mov    r13,QWORD PTR [rsp]
    2bcf:	mov    r14,QWORD PTR [rsp+0x8]
    2bd4:	add    rsp,0x10
    2bd8:	mov    rsp,rbp
    2bdb:	pop    rbp
    2bdc:	ret

0000000000002bdd <botlish_entry_31: ht_size<mutarray>>:
    2bdd:	push   rbp
    2bde:	mov    rbp,rsp
    2be1:	mov    rsi,QWORD PTR [rdx]
    2be4:	call   2be9 <botlish_entry_31+0xc>
			2be5: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    2be9:	mov    rsp,rbp
    2bec:	pop    rbp
    2bed:	ret

0000000000002bee <botlish_fn_32: ht_size<generic>>:
    2bee:	push   rbp
    2bef:	mov    rbp,rsp
    2bf2:	sub    rsp,0x10
    2bf6:	mov    QWORD PTR [rsp],rbx
    2bfa:	mov    QWORD PTR [rsp+0x8],r12
    2bff:	mov    rbx,QWORD PTR [rdi]
    2c02:	mov    rax,QWORD PTR [rdi+0x8]
    2c06:	lea    rcx,[rbx+0x8]
    2c0a:	cmp    rcx,rax
    2c0d:	ja     2caa <botlish_fn_32+0xbc>
    2c13:	lea    rax,[rbx+0x8]
    2c17:	mov    QWORD PTR [rdi],rax
    2c1a:	mov    QWORD PTR [rbx],0x0
    2c21:	xor    ecx,ecx
    2c23:	test   rsi,0x7
    2c2a:	jne    2c39 <botlish_fn_32+0x4b>
    2c30:	movzx  rax,BYTE PTR [rsi]
    2c34:	cmp    al,0x8
    2c36:	sete   cl
    2c39:	test   cl,cl
    2c3b:	jne    2c5e <botlish_fn_32+0x70>
    2c41:	mov    rax,QWORD PTR [rdi+0x10]
    2c45:	mov    r12,rdi
    2c48:	mov    rcx,QWORD PTR [rax+0x20]
    2c4c:	mov    edx,0x8
    2c51:	call   2c56 <botlish_fn_32+0x68>
			2c52: R_X86_64_PLT32	rt_type_error-0x4
    2c56:	mov    rdi,r12
    2c59:	jmp    2c77 <botlish_fn_32+0x89>
    2c5e:	mov    r12,rdi
    2c61:	mov    edx,0x7
    2c66:	call   2c6b <botlish_fn_32+0x7d>
			2c67: R_X86_64_PLT32	rt_mutarray_get-0x4
    2c6b:	test   rax,rax
    2c6e:	jne    2c92 <botlish_fn_32+0xa4>
    2c74:	mov    rdi,r12
    2c77:	mov    rdi,r12
    2c7a:	mov    QWORD PTR [rdi],rbx
    2c7d:	xor    rax,rax
    2c80:	mov    rbx,QWORD PTR [rsp]
    2c84:	mov    r12,QWORD PTR [rsp+0x8]
    2c89:	add    rsp,0x10
    2c8d:	mov    rsp,rbp
    2c90:	pop    rbp
    2c91:	ret
    2c92:	mov    rdi,r12
    2c95:	mov    QWORD PTR [rdi],rbx
    2c98:	mov    rbx,QWORD PTR [rsp]
    2c9c:	mov    r12,QWORD PTR [rsp+0x8]
    2ca1:	add    rsp,0x10
    2ca5:	mov    rsp,rbp
    2ca8:	pop    rbp
    2ca9:	ret
    2caa:	mov    r12,rdi
    2cad:	call   2cb2 <botlish_fn_32+0xc4>
			2cae: R_X86_64_PLT32	rt_stack_overflow-0x4
    2cb2:	xor    rax,rax
    2cb5:	mov    rbx,QWORD PTR [rsp]
    2cb9:	mov    r12,QWORD PTR [rsp+0x8]
    2cbe:	add    rsp,0x10
    2cc2:	mov    rsp,rbp
    2cc5:	pop    rbp
    2cc6:	ret

0000000000002cc7 <botlish_entry_32: ht_size<generic>>:
    2cc7:	push   rbp
    2cc8:	mov    rbp,rsp
    2ccb:	mov    rsi,QWORD PTR [rdx]
    2cce:	call   2cd3 <botlish_entry_32+0xc>
			2ccf: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    2cd3:	mov    rsp,rbp
    2cd6:	pop    rbp
    2cd7:	ret

0000000000002cd8 <botlish_fn_33: ht_tombstones<mutarray>>:
    2cd8:	push   rbp
    2cd9:	mov    rbp,rsp
    2cdc:	sub    rsp,0x10
    2ce0:	mov    QWORD PTR [rsp],r13
    2ce4:	mov    QWORD PTR [rsp+0x8],r14
    2ce9:	mov    r13,QWORD PTR [rdi]
    2cec:	mov    rax,QWORD PTR [rdi+0x8]
    2cf0:	lea    rcx,[r13+0x8]
    2cf4:	cmp    rcx,rax
    2cf7:	ja     2d58 <botlish_fn_33+0x80>
    2cfd:	lea    rax,[r13+0x8]
    2d01:	mov    QWORD PTR [rdi],rax
    2d04:	mov    r14,rdi
    2d07:	mov    QWORD PTR [r13+0x0],0x0
    2d0f:	mov    edx,0x9
    2d14:	mov    rdi,r14
    2d17:	call   2d1c <botlish_fn_33+0x44>
			2d18: R_X86_64_PLT32	rt_mutarray_get-0x4
    2d1c:	test   rax,rax
    2d1f:	jne    2d40 <botlish_fn_33+0x68>
    2d25:	mov    rdi,r14
    2d28:	mov    QWORD PTR [rdi],r13
    2d2b:	xor    rax,rax
    2d2e:	mov    r13,QWORD PTR [rsp]
    2d32:	mov    r14,QWORD PTR [rsp+0x8]
    2d37:	add    rsp,0x10
    2d3b:	mov    rsp,rbp
    2d3e:	pop    rbp
    2d3f:	ret
    2d40:	mov    rdi,r14
    2d43:	mov    QWORD PTR [rdi],r13
    2d46:	mov    r13,QWORD PTR [rsp]
    2d4a:	mov    r14,QWORD PTR [rsp+0x8]
    2d4f:	add    rsp,0x10
    2d53:	mov    rsp,rbp
    2d56:	pop    rbp
    2d57:	ret
    2d58:	call   2d5d <botlish_fn_33+0x85>
			2d59: R_X86_64_PLT32	rt_stack_overflow-0x4
    2d5d:	xor    rax,rax
    2d60:	mov    r13,QWORD PTR [rsp]
    2d64:	mov    r14,QWORD PTR [rsp+0x8]
    2d69:	add    rsp,0x10
    2d6d:	mov    rsp,rbp
    2d70:	pop    rbp
    2d71:	ret

0000000000002d72 <botlish_entry_33: ht_tombstones<mutarray>>:
    2d72:	push   rbp
    2d73:	mov    rbp,rsp
    2d76:	mov    rsi,QWORD PTR [rdx]
    2d79:	call   2d7e <botlish_entry_33+0xc>
			2d7a: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    2d7e:	mov    rsp,rbp
    2d81:	pop    rbp
    2d82:	ret

0000000000002d83 <botlish_fn_34: ht_capacity<mutarray>>:
    2d83:	push   rbp
    2d84:	mov    rbp,rsp
    2d87:	sub    rsp,0x10
    2d8b:	mov    QWORD PTR [rsp],rbx
    2d8f:	mov    QWORD PTR [rsp+0x8],r12
    2d94:	mov    rbx,QWORD PTR [rdi]
    2d97:	mov    rax,QWORD PTR [rdi+0x8]
    2d9b:	lea    rcx,[rbx+0x8]
    2d9f:	cmp    rcx,rax
    2da2:	ja     2e4d <botlish_fn_34+0xca>
    2da8:	lea    rax,[rbx+0x8]
    2dac:	mov    QWORD PTR [rdi],rax
    2daf:	mov    r12,rdi
    2db2:	mov    QWORD PTR [rbx],rsi
    2db5:	mov    rdi,r12
    2db8:	call   2dbd <botlish_fn_34+0x3a>
			2db9: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    2dbd:	test   rax,rax
    2dc0:	jne    2dce <botlish_fn_34+0x4b>
    2dc6:	mov    rdi,r12
    2dc9:	jmp    2e12 <botlish_fn_34+0x8f>
    2dce:	xor    ecx,ecx
    2dd0:	test   rax,0x7
    2dd6:	je     2de4 <botlish_fn_34+0x61>
    2ddc:	mov    rsi,rax
    2ddf:	jmp    2df2 <botlish_fn_34+0x6f>
    2de4:	movzx  rcx,BYTE PTR [rax]
    2de8:	mov    rsi,rax
    2deb:	rex cmp cl,0x8
    2def:	sete   cl
    2df2:	test   cl,cl
    2df4:	jne    2e2d <botlish_fn_34+0xaa>
    2dfa:	mov    rdi,r12
    2dfd:	mov    rax,QWORD PTR [rdi+0x10]
    2e01:	mov    rcx,QWORD PTR [rax+0x28]
    2e05:	mov    edx,0x8
    2e0a:	call   2e0f <botlish_fn_34+0x8c>
			2e0b: R_X86_64_PLT32	rt_type_error-0x4
    2e0f:	mov    rdi,r12
    2e12:	mov    rdi,r12
    2e15:	mov    QWORD PTR [rdi],rbx
    2e18:	xor    rax,rax
    2e1b:	mov    rbx,QWORD PTR [rsp]
    2e1f:	mov    r12,QWORD PTR [rsp+0x8]
    2e24:	add    rsp,0x10
    2e28:	mov    rsp,rbp
    2e2b:	pop    rbp
    2e2c:	ret
    2e2d:	mov    rdi,r12
    2e30:	call   2e35 <botlish_fn_34+0xb2>
			2e31: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    2e35:	mov    rdi,r12
    2e38:	mov    QWORD PTR [rdi],rbx
    2e3b:	mov    rbx,QWORD PTR [rsp]
    2e3f:	mov    r12,QWORD PTR [rsp+0x8]
    2e44:	add    rsp,0x10
    2e48:	mov    rsp,rbp
    2e4b:	pop    rbp
    2e4c:	ret
    2e4d:	mov    r12,rdi
    2e50:	call   2e55 <botlish_fn_34+0xd2>
			2e51: R_X86_64_PLT32	rt_stack_overflow-0x4
    2e55:	xor    rax,rax
    2e58:	mov    rbx,QWORD PTR [rsp]
    2e5c:	mov    r12,QWORD PTR [rsp+0x8]
    2e61:	add    rsp,0x10
    2e65:	mov    rsp,rbp
    2e68:	pop    rbp
    2e69:	ret

0000000000002e6a <botlish_entry_34: ht_capacity<mutarray>>:
    2e6a:	push   rbp
    2e6b:	mov    rbp,rsp
    2e6e:	mov    rsi,QWORD PTR [rdx]
    2e71:	call   2e76 <botlish_entry_34+0xc>
			2e72: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2e76:	mov    rsp,rbp
    2e79:	pop    rbp
    2e7a:	ret

0000000000002e7b <botlish_fn_35: ht_capacity<generic>>:
    2e7b:	push   rbp
    2e7c:	mov    rbp,rsp
    2e7f:	sub    rsp,0x10
    2e83:	mov    QWORD PTR [rsp],rbx
    2e87:	mov    QWORD PTR [rsp+0x8],r12
    2e8c:	mov    rbx,QWORD PTR [rdi]
    2e8f:	mov    rax,QWORD PTR [rdi+0x8]
    2e93:	lea    rcx,[rbx+0x8]
    2e97:	cmp    rcx,rax
    2e9a:	ja     2f45 <botlish_fn_35+0xca>
    2ea0:	lea    rax,[rbx+0x8]
    2ea4:	mov    QWORD PTR [rdi],rax
    2ea7:	mov    r12,rdi
    2eaa:	mov    QWORD PTR [rbx],rsi
    2ead:	mov    rdi,r12
    2eb0:	call   2eb5 <botlish_fn_35+0x3a>
			2eb1: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    2eb5:	test   rax,rax
    2eb8:	jne    2ec6 <botlish_fn_35+0x4b>
    2ebe:	mov    rdi,r12
    2ec1:	jmp    2f0a <botlish_fn_35+0x8f>
    2ec6:	xor    ecx,ecx
    2ec8:	test   rax,0x7
    2ece:	je     2edc <botlish_fn_35+0x61>
    2ed4:	mov    rsi,rax
    2ed7:	jmp    2eea <botlish_fn_35+0x6f>
    2edc:	movzx  rcx,BYTE PTR [rax]
    2ee0:	mov    rsi,rax
    2ee3:	rex cmp cl,0x8
    2ee7:	sete   cl
    2eea:	test   cl,cl
    2eec:	jne    2f25 <botlish_fn_35+0xaa>
    2ef2:	mov    rdi,r12
    2ef5:	mov    rax,QWORD PTR [rdi+0x10]
    2ef9:	mov    rcx,QWORD PTR [rax+0x28]
    2efd:	mov    edx,0x8
    2f02:	call   2f07 <botlish_fn_35+0x8c>
			2f03: R_X86_64_PLT32	rt_type_error-0x4
    2f07:	mov    rdi,r12
    2f0a:	mov    rdi,r12
    2f0d:	mov    QWORD PTR [rdi],rbx
    2f10:	xor    rax,rax
    2f13:	mov    rbx,QWORD PTR [rsp]
    2f17:	mov    r12,QWORD PTR [rsp+0x8]
    2f1c:	add    rsp,0x10
    2f20:	mov    rsp,rbp
    2f23:	pop    rbp
    2f24:	ret
    2f25:	mov    rdi,r12
    2f28:	call   2f2d <botlish_fn_35+0xb2>
			2f29: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    2f2d:	mov    rdi,r12
    2f30:	mov    QWORD PTR [rdi],rbx
    2f33:	mov    rbx,QWORD PTR [rsp]
    2f37:	mov    r12,QWORD PTR [rsp+0x8]
    2f3c:	add    rsp,0x10
    2f40:	mov    rsp,rbp
    2f43:	pop    rbp
    2f44:	ret
    2f45:	mov    r12,rdi
    2f48:	call   2f4d <botlish_fn_35+0xd2>
			2f49: R_X86_64_PLT32	rt_stack_overflow-0x4
    2f4d:	xor    rax,rax
    2f50:	mov    rbx,QWORD PTR [rsp]
    2f54:	mov    r12,QWORD PTR [rsp+0x8]
    2f59:	add    rsp,0x10
    2f5d:	mov    rsp,rbp
    2f60:	pop    rbp
    2f61:	ret

0000000000002f62 <botlish_entry_35: ht_capacity<generic>>:
    2f62:	push   rbp
    2f63:	mov    rbp,rsp
    2f66:	mov    rsi,QWORD PTR [rdx]
    2f69:	call   2f6e <botlish_entry_35+0xc>
			2f6a: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    2f6e:	mov    rsp,rbp
    2f71:	pop    rbp
    2f72:	ret

0000000000002f73 <botlish_fn_36: ht_probe_start<mutarray, any>>:
    2f73:	push   rbp
    2f74:	mov    rbp,rsp
    2f77:	sub    rsp,0x20
    2f7b:	mov    QWORD PTR [rsp],rbx
    2f7f:	mov    QWORD PTR [rsp+0x8],r12
    2f84:	mov    QWORD PTR [rsp+0x10],r15
    2f89:	mov    r15,QWORD PTR [rdi]
    2f8c:	mov    rax,QWORD PTR [rdi+0x8]
    2f90:	lea    rcx,[r15+0x10]
    2f94:	cmp    rcx,rax
    2f97:	ja     3052 <botlish_fn_36+0xdf>
    2f9d:	lea    rax,[r15+0x10]
    2fa1:	mov    QWORD PTR [rdi],rax
    2fa4:	mov    rbx,rdi
    2fa7:	mov    QWORD PTR [r15],0x0
    2fae:	mov    QWORD PTR [r15+0x8],0x0
    2fb6:	mov    QWORD PTR [r15],rsi
    2fb9:	mov    r12,rsi
    2fbc:	mov    rsi,rdx
    2fbf:	mov    rdi,rbx
    2fc2:	call   2fc7 <botlish_fn_36+0x54>
			2fc3: R_X86_64_PLT32	rt_hash-0x4
    2fc7:	test   rax,rax
    2fca:	jne    2fd8 <botlish_fn_36+0x65>
    2fd0:	mov    rdi,rbx
    2fd3:	jmp    3015 <botlish_fn_36+0xa2>
    2fd8:	mov    QWORD PTR [r15+0x8],rax
    2fdc:	mov    rsi,r12
    2fdf:	mov    r12,rax
    2fe2:	mov    rdi,rbx
    2fe5:	call   2fea <botlish_fn_36+0x77>
			2fe6: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    2fea:	test   rax,rax
    2fed:	mov    rdx,rax
    2ff0:	jne    2ffe <botlish_fn_36+0x8b>
    2ff6:	mov    rdi,rbx
    2ff9:	jmp    3015 <botlish_fn_36+0xa2>
    2ffe:	mov    rsi,r12
    3001:	mov    rdi,rbx
    3004:	call   3009 <botlish_fn_36+0x96>
			3005: R_X86_64_PLT32	rt_int_mod-0x4
    3009:	test   rax,rax
    300c:	jne    3035 <botlish_fn_36+0xc2>
    3012:	mov    rdi,rbx
    3015:	mov    rdi,rbx
    3018:	mov    QWORD PTR [rdi],r15
    301b:	xor    rax,rax
    301e:	mov    rbx,QWORD PTR [rsp]
    3022:	mov    r12,QWORD PTR [rsp+0x8]
    3027:	mov    r15,QWORD PTR [rsp+0x10]
    302c:	add    rsp,0x20
    3030:	mov    rsp,rbp
    3033:	pop    rbp
    3034:	ret
    3035:	mov    rdi,rbx
    3038:	mov    QWORD PTR [rdi],r15
    303b:	mov    rbx,QWORD PTR [rsp]
    303f:	mov    r12,QWORD PTR [rsp+0x8]
    3044:	mov    r15,QWORD PTR [rsp+0x10]
    3049:	add    rsp,0x20
    304d:	mov    rsp,rbp
    3050:	pop    rbp
    3051:	ret
    3052:	mov    rbx,rdi
    3055:	call   305a <botlish_fn_36+0xe7>
			3056: R_X86_64_PLT32	rt_stack_overflow-0x4
    305a:	xor    rax,rax
    305d:	mov    rbx,QWORD PTR [rsp]
    3061:	mov    r12,QWORD PTR [rsp+0x8]
    3066:	mov    r15,QWORD PTR [rsp+0x10]
    306b:	add    rsp,0x20
    306f:	mov    rsp,rbp
    3072:	pop    rbp
    3073:	ret

0000000000003074 <botlish_entry_36: ht_probe_start<mutarray, any>>:
    3074:	push   rbp
    3075:	mov    rbp,rsp
    3078:	mov    rsi,QWORD PTR [rdx]
    307b:	mov    rdx,QWORD PTR [rdx+0x8]
    307f:	call   3084 <botlish_entry_36+0x10>
			3080: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    3084:	mov    rsp,rbp
    3087:	pop    rbp
    3088:	ret

0000000000003089 <botlish_fn_37: ht_probe_start<any, str>>:
    3089:	push   rbp
    308a:	mov    rbp,rsp
    308d:	sub    rsp,0x20
    3091:	mov    QWORD PTR [rsp],rbx
    3095:	mov    QWORD PTR [rsp+0x8],r12
    309a:	mov    QWORD PTR [rsp+0x10],r15
    309f:	mov    r15,QWORD PTR [rdi]
    30a2:	mov    rax,QWORD PTR [rdi+0x8]
    30a6:	lea    rcx,[r15+0x10]
    30aa:	cmp    rcx,rax
    30ad:	ja     3168 <botlish_fn_37+0xdf>
    30b3:	lea    rax,[r15+0x10]
    30b7:	mov    QWORD PTR [rdi],rax
    30ba:	mov    rbx,rdi
    30bd:	mov    QWORD PTR [r15],0x0
    30c4:	mov    QWORD PTR [r15+0x8],0x0
    30cc:	mov    QWORD PTR [r15],rsi
    30cf:	mov    r12,rsi
    30d2:	mov    rsi,rdx
    30d5:	mov    rdi,rbx
    30d8:	call   30dd <botlish_fn_37+0x54>
			30d9: R_X86_64_PLT32	rt_hash-0x4
    30dd:	test   rax,rax
    30e0:	jne    30ee <botlish_fn_37+0x65>
    30e6:	mov    rdi,rbx
    30e9:	jmp    312b <botlish_fn_37+0xa2>
    30ee:	mov    QWORD PTR [r15+0x8],rax
    30f2:	mov    rsi,r12
    30f5:	mov    r12,rax
    30f8:	mov    rdi,rbx
    30fb:	call   3100 <botlish_fn_37+0x77>
			30fc: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    3100:	test   rax,rax
    3103:	mov    rdx,rax
    3106:	jne    3114 <botlish_fn_37+0x8b>
    310c:	mov    rdi,rbx
    310f:	jmp    312b <botlish_fn_37+0xa2>
    3114:	mov    rsi,r12
    3117:	mov    rdi,rbx
    311a:	call   311f <botlish_fn_37+0x96>
			311b: R_X86_64_PLT32	rt_int_mod-0x4
    311f:	test   rax,rax
    3122:	jne    314b <botlish_fn_37+0xc2>
    3128:	mov    rdi,rbx
    312b:	mov    rdi,rbx
    312e:	mov    QWORD PTR [rdi],r15
    3131:	xor    rax,rax
    3134:	mov    rbx,QWORD PTR [rsp]
    3138:	mov    r12,QWORD PTR [rsp+0x8]
    313d:	mov    r15,QWORD PTR [rsp+0x10]
    3142:	add    rsp,0x20
    3146:	mov    rsp,rbp
    3149:	pop    rbp
    314a:	ret
    314b:	mov    rdi,rbx
    314e:	mov    QWORD PTR [rdi],r15
    3151:	mov    rbx,QWORD PTR [rsp]
    3155:	mov    r12,QWORD PTR [rsp+0x8]
    315a:	mov    r15,QWORD PTR [rsp+0x10]
    315f:	add    rsp,0x20
    3163:	mov    rsp,rbp
    3166:	pop    rbp
    3167:	ret
    3168:	mov    rbx,rdi
    316b:	call   3170 <botlish_fn_37+0xe7>
			316c: R_X86_64_PLT32	rt_stack_overflow-0x4
    3170:	xor    rax,rax
    3173:	mov    rbx,QWORD PTR [rsp]
    3177:	mov    r12,QWORD PTR [rsp+0x8]
    317c:	mov    r15,QWORD PTR [rsp+0x10]
    3181:	add    rsp,0x20
    3185:	mov    rsp,rbp
    3188:	pop    rbp
    3189:	ret

000000000000318a <botlish_entry_37: ht_probe_start<any, str>>:
    318a:	push   rbp
    318b:	mov    rbp,rsp
    318e:	mov    rsi,QWORD PTR [rdx]
    3191:	mov    rdx,QWORD PTR [rdx+0x8]
    3195:	call   319a <botlish_entry_37+0x10>
			3196: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    319a:	mov    rsp,rbp
    319d:	pop    rbp
    319e:	ret

000000000000319f <botlish_fn_38: ht_probe_next<mutarray, int>>:
    319f:	push   rbp
    31a0:	mov    rbp,rsp
    31a3:	sub    rsp,0x20
    31a7:	mov    QWORD PTR [rsp],rbx
    31ab:	mov    QWORD PTR [rsp+0x8],r12
    31b0:	mov    QWORD PTR [rsp+0x10],r13
    31b5:	mov    rbx,QWORD PTR [rdi]
    31b8:	mov    rax,QWORD PTR [rdi+0x8]
    31bc:	lea    rcx,[rbx+0x18]
    31c0:	cmp    rcx,rax
    31c3:	ja     32b6 <botlish_fn_38+0x117>
    31c9:	lea    rax,[rbx+0x18]
    31cd:	mov    QWORD PTR [rdi],rax
    31d0:	mov    r12,rdi
    31d3:	mov    QWORD PTR [rbx],0x0
    31da:	mov    QWORD PTR [rbx+0x8],0x0
    31e2:	mov    QWORD PTR [rbx+0x10],0x0
    31ea:	mov    QWORD PTR [rbx],rsi
    31ed:	mov    r13,rsi
    31f0:	mov    QWORD PTR [rbx+0x8],rdx
    31f4:	mov    QWORD PTR [rbx+0x10],0x3
    31fc:	test   rdx,0x1
    3203:	jne    3211 <botlish_fn_38+0x72>
    3209:	mov    rcx,rdx
    320c:	jmp    3226 <botlish_fn_38+0x87>
    3211:	mov    rsi,rdx
    3214:	add    rsi,0x2
    3218:	mov    rcx,rdx
    321b:	seto   al
    321e:	test   al,al
    3220:	je     3239 <botlish_fn_38+0x9a>
    3226:	mov    edx,0x3
    322b:	mov    rsi,rcx
    322e:	mov    rdi,r12
    3231:	call   3236 <botlish_fn_38+0x97>
			3232: R_X86_64_PLT32	rt_int_add-0x4
    3236:	mov    rsi,rax
    3239:	mov    QWORD PTR [rbx+0x8],rsi
    323d:	mov    rax,rsi
    3240:	mov    rsi,r13
    3243:	mov    r13,rax
    3246:	mov    rdi,r12
    3249:	call   324e <botlish_fn_38+0xaf>
			324a: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    324e:	test   rax,rax
    3251:	mov    rdx,rax
    3254:	jne    3262 <botlish_fn_38+0xc3>
    325a:	mov    rdi,r12
    325d:	jmp    3279 <botlish_fn_38+0xda>
    3262:	mov    rsi,r13
    3265:	mov    rdi,r12
    3268:	call   326d <botlish_fn_38+0xce>
			3269: R_X86_64_PLT32	rt_int_mod-0x4
    326d:	test   rax,rax
    3270:	jne    3299 <botlish_fn_38+0xfa>
    3276:	mov    rdi,r12
    3279:	mov    rdi,r12
    327c:	mov    QWORD PTR [rdi],rbx
    327f:	xor    rax,rax
    3282:	mov    rbx,QWORD PTR [rsp]
    3286:	mov    r12,QWORD PTR [rsp+0x8]
    328b:	mov    r13,QWORD PTR [rsp+0x10]
    3290:	add    rsp,0x20
    3294:	mov    rsp,rbp
    3297:	pop    rbp
    3298:	ret
    3299:	mov    rdi,r12
    329c:	mov    QWORD PTR [rdi],rbx
    329f:	mov    rbx,QWORD PTR [rsp]
    32a3:	mov    r12,QWORD PTR [rsp+0x8]
    32a8:	mov    r13,QWORD PTR [rsp+0x10]
    32ad:	add    rsp,0x20
    32b1:	mov    rsp,rbp
    32b4:	pop    rbp
    32b5:	ret
    32b6:	mov    r12,rdi
    32b9:	call   32be <botlish_fn_38+0x11f>
			32ba: R_X86_64_PLT32	rt_stack_overflow-0x4
    32be:	xor    rax,rax
    32c1:	mov    rbx,QWORD PTR [rsp]
    32c5:	mov    r12,QWORD PTR [rsp+0x8]
    32ca:	mov    r13,QWORD PTR [rsp+0x10]
    32cf:	add    rsp,0x20
    32d3:	mov    rsp,rbp
    32d6:	pop    rbp
    32d7:	ret

00000000000032d8 <botlish_entry_38: ht_probe_next<mutarray, int>>:
    32d8:	push   rbp
    32d9:	mov    rbp,rsp
    32dc:	mov    rsi,QWORD PTR [rdx]
    32df:	mov    rdx,QWORD PTR [rdx+0x8]
    32e3:	call   32e8 <botlish_entry_38+0x10>
			32e4: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    32e8:	mov    rsp,rbp
    32eb:	pop    rbp
    32ec:	ret

00000000000032ed <botlish_fn_39: ht_probe_next<any, int>>:
    32ed:	push   rbp
    32ee:	mov    rbp,rsp
    32f1:	sub    rsp,0x20
    32f5:	mov    QWORD PTR [rsp],rbx
    32f9:	mov    QWORD PTR [rsp+0x8],r12
    32fe:	mov    QWORD PTR [rsp+0x10],r13
    3303:	mov    rbx,QWORD PTR [rdi]
    3306:	mov    rax,QWORD PTR [rdi+0x8]
    330a:	lea    rcx,[rbx+0x18]
    330e:	cmp    rcx,rax
    3311:	ja     3404 <botlish_fn_39+0x117>
    3317:	lea    rax,[rbx+0x18]
    331b:	mov    QWORD PTR [rdi],rax
    331e:	mov    r12,rdi
    3321:	mov    QWORD PTR [rbx],0x0
    3328:	mov    QWORD PTR [rbx+0x8],0x0
    3330:	mov    QWORD PTR [rbx+0x10],0x0
    3338:	mov    QWORD PTR [rbx],rsi
    333b:	mov    r13,rsi
    333e:	mov    QWORD PTR [rbx+0x8],rdx
    3342:	mov    QWORD PTR [rbx+0x10],0x3
    334a:	test   rdx,0x1
    3351:	jne    335f <botlish_fn_39+0x72>
    3357:	mov    rcx,rdx
    335a:	jmp    3374 <botlish_fn_39+0x87>
    335f:	mov    rsi,rdx
    3362:	add    rsi,0x2
    3366:	mov    rcx,rdx
    3369:	seto   al
    336c:	test   al,al
    336e:	je     3387 <botlish_fn_39+0x9a>
    3374:	mov    edx,0x3
    3379:	mov    rsi,rcx
    337c:	mov    rdi,r12
    337f:	call   3384 <botlish_fn_39+0x97>
			3380: R_X86_64_PLT32	rt_int_add-0x4
    3384:	mov    rsi,rax
    3387:	mov    QWORD PTR [rbx+0x8],rsi
    338b:	mov    rax,rsi
    338e:	mov    rsi,r13
    3391:	mov    r13,rax
    3394:	mov    rdi,r12
    3397:	call   339c <botlish_fn_39+0xaf>
			3398: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    339c:	test   rax,rax
    339f:	mov    rdx,rax
    33a2:	jne    33b0 <botlish_fn_39+0xc3>
    33a8:	mov    rdi,r12
    33ab:	jmp    33c7 <botlish_fn_39+0xda>
    33b0:	mov    rsi,r13
    33b3:	mov    rdi,r12
    33b6:	call   33bb <botlish_fn_39+0xce>
			33b7: R_X86_64_PLT32	rt_int_mod-0x4
    33bb:	test   rax,rax
    33be:	jne    33e7 <botlish_fn_39+0xfa>
    33c4:	mov    rdi,r12
    33c7:	mov    rdi,r12
    33ca:	mov    QWORD PTR [rdi],rbx
    33cd:	xor    rax,rax
    33d0:	mov    rbx,QWORD PTR [rsp]
    33d4:	mov    r12,QWORD PTR [rsp+0x8]
    33d9:	mov    r13,QWORD PTR [rsp+0x10]
    33de:	add    rsp,0x20
    33e2:	mov    rsp,rbp
    33e5:	pop    rbp
    33e6:	ret
    33e7:	mov    rdi,r12
    33ea:	mov    QWORD PTR [rdi],rbx
    33ed:	mov    rbx,QWORD PTR [rsp]
    33f1:	mov    r12,QWORD PTR [rsp+0x8]
    33f6:	mov    r13,QWORD PTR [rsp+0x10]
    33fb:	add    rsp,0x20
    33ff:	mov    rsp,rbp
    3402:	pop    rbp
    3403:	ret
    3404:	mov    r12,rdi
    3407:	call   340c <botlish_fn_39+0x11f>
			3408: R_X86_64_PLT32	rt_stack_overflow-0x4
    340c:	xor    rax,rax
    340f:	mov    rbx,QWORD PTR [rsp]
    3413:	mov    r12,QWORD PTR [rsp+0x8]
    3418:	mov    r13,QWORD PTR [rsp+0x10]
    341d:	add    rsp,0x20
    3421:	mov    rsp,rbp
    3424:	pop    rbp
    3425:	ret

0000000000003426 <botlish_entry_39: ht_probe_next<any, int>>:
    3426:	push   rbp
    3427:	mov    rbp,rsp
    342a:	mov    rsi,QWORD PTR [rdx]
    342d:	mov    rdx,QWORD PTR [rdx+0x8]
    3431:	call   3436 <botlish_entry_39+0x10>
			3432: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    3436:	mov    rsp,rbp
    3439:	pop    rbp
    343a:	ret
    343b:	add    BYTE PTR [rax],al
    343d:	add    BYTE PTR [rax],al
	...

0000000000003440 <botlish_fn_40: ht_find_get<any, str, int>>:
    3440:	push   rbp
    3441:	mov    rbp,rsp
    3444:	sub    rsp,0x40
    3448:	mov    QWORD PTR [rsp+0x10],rbx
    344d:	mov    QWORD PTR [rsp+0x18],r12
    3452:	mov    QWORD PTR [rsp+0x20],r13
    3457:	mov    QWORD PTR [rsp+0x28],r14
    345c:	mov    QWORD PTR [rsp+0x30],r15
    3461:	mov    r14,QWORD PTR [rdi]
    3464:	mov    rax,QWORD PTR [rdi+0x8]
    3468:	lea    r8,[r14+0x20]
    346c:	cmp    r8,rax
    346f:	ja     37c9 <botlish_fn_40+0x389>
    3475:	lea    rax,[r14+0x20]
    3479:	mov    QWORD PTR [rdi],rax
    347c:	mov    r15,rdi
    347f:	mov    QWORD PTR [r14],0x0
    3486:	mov    QWORD PTR [r14+0x8],0x0
    348e:	mov    QWORD PTR [r14+0x10],0x0
    3496:	mov    QWORD PTR [r14+0x18],0x0
    349e:	mov    QWORD PTR [r14],rsi
    34a1:	mov    QWORD PTR [r14+0x8],rdx
    34a5:	mov    QWORD PTR [rsp],rdx
    34a9:	mov    QWORD PTR [r14+0x10],rcx
    34ad:	mov    rbx,rsi
    34b0:	mov    QWORD PTR [rsp+0x8],rcx
    34b5:	mov    rsi,rbx
    34b8:	mov    rdi,r15
    34bb:	call   34c0 <botlish_fn_40+0x80>
			34bc: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    34c0:	test   rax,rax
    34c3:	jne    34d1 <botlish_fn_40+0x91>
    34c9:	mov    rdi,r15
    34cc:	jmp    3729 <botlish_fn_40+0x2e9>
    34d1:	xor    ecx,ecx
    34d3:	test   rax,0x7
    34d9:	je     34e7 <botlish_fn_40+0xa7>
    34df:	mov    rsi,rax
    34e2:	jmp    34f5 <botlish_fn_40+0xb5>
    34e7:	movzx  rcx,BYTE PTR [rax]
    34eb:	mov    rsi,rax
    34ee:	rex cmp cl,0x8
    34f2:	sete   cl
    34f5:	test   cl,cl
    34f7:	jne    351a <botlish_fn_40+0xda>
    34fd:	mov    rdi,r15
    3500:	mov    rax,QWORD PTR [rdi+0x10]
    3504:	mov    rcx,QWORD PTR [rax+0x20]
    3508:	mov    edx,0x8
    350d:	call   3512 <botlish_fn_40+0xd2>
			350e: R_X86_64_PLT32	rt_type_error-0x4
    3512:	mov    rdi,r15
    3515:	jmp    3729 <botlish_fn_40+0x2e9>
    351a:	mov    rdx,QWORD PTR [rsp+0x8]
    351f:	mov    rdi,r15
    3522:	call   3527 <botlish_fn_40+0xe7>
			3523: R_X86_64_PLT32	rt_mutarray_get-0x4
    3527:	mov    rcx,rax
    352a:	mov    r13,rax
    352d:	test   rax,rcx
    3530:	jne    353e <botlish_fn_40+0xfe>
    3536:	mov    rdi,r15
    3539:	jmp    3729 <botlish_fn_40+0x2e9>
    353e:	mov    rax,r13
    3541:	mov    QWORD PTR [r14+0x18],rax
    3545:	mov    rdi,r15
    3548:	call   354d <botlish_fn_40+0x10d>
			3549: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    354d:	test   rax,rax
    3550:	jne    355e <botlish_fn_40+0x11e>
    3556:	mov    rdi,r15
    3559:	jmp    3729 <botlish_fn_40+0x2e9>
    355e:	mov    rdi,r13
    3561:	mov    rcx,rdi
    3564:	and    rcx,rax
    3567:	mov    rdx,rax
    356a:	test   rcx,0x1
    3571:	jne    3593 <botlish_fn_40+0x153>
    3577:	mov    rsi,r13
    357a:	mov    rdi,r15
    357d:	call   3582 <botlish_fn_40+0x142>
			357e: R_X86_64_PLT32	rt_value_eq-0x4
    3582:	test   rax,rax
    3585:	jne    35a3 <botlish_fn_40+0x163>
    358b:	mov    rdi,r15
    358e:	jmp    3729 <botlish_fn_40+0x2e9>
    3593:	mov    eax,0x2
    3598:	cmp    r13,rdx
    359b:	cmove  rax,QWORD PTR [rip+0x255]        # 37f8 <botlish_fn_40+0x3b8>
    35a3:	mov    r12d,0x6
    35a9:	cmp    rax,0x6
    35ad:	je     379a <botlish_fn_40+0x35a>
    35b3:	mov    rdi,r15
    35b6:	call   35bb <botlish_fn_40+0x17b>
			35b7: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    35bb:	test   rax,rax
    35be:	jne    35cc <botlish_fn_40+0x18c>
    35c4:	mov    rdi,r15
    35c7:	jmp    3729 <botlish_fn_40+0x2e9>
    35cc:	mov    rcx,r13
    35cf:	and    rcx,rax
    35d2:	mov    rdx,rax
    35d5:	test   rcx,0x1
    35dc:	jne    35fe <botlish_fn_40+0x1be>
    35e2:	mov    rsi,r13
    35e5:	mov    rdi,r15
    35e8:	call   35ed <botlish_fn_40+0x1ad>
			35e9: R_X86_64_PLT32	rt_value_eq-0x4
    35ed:	test   rax,rax
    35f0:	jne    3611 <botlish_fn_40+0x1d1>
    35f6:	mov    rdi,r15
    35f9:	jmp    3729 <botlish_fn_40+0x2e9>
    35fe:	mov    rsi,r13
    3601:	mov    eax,0x2
    3606:	cmp    rsi,rdx
    3609:	cmove  rax,QWORD PTR [rip+0x1e7]        # 37f8 <botlish_fn_40+0x3b8>
    3611:	cmp    rax,0x6
    3615:	je     362a <botlish_fn_40+0x1ea>
    361b:	mov    r12d,0x2
    3621:	mov    r13,QWORD PTR [rsp]
    3625:	jmp    3703 <botlish_fn_40+0x2c3>
    362a:	mov    rsi,rbx
    362d:	mov    rdi,r15
    3630:	call   3635 <botlish_fn_40+0x1f5>
			3631: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    3635:	test   rax,rax
    3638:	jne    3646 <botlish_fn_40+0x206>
    363e:	mov    rdi,r15
    3641:	jmp    3729 <botlish_fn_40+0x2e9>
    3646:	xor    ecx,ecx
    3648:	test   rax,0x7
    364e:	je     365c <botlish_fn_40+0x21c>
    3654:	mov    rsi,rax
    3657:	jmp    366a <botlish_fn_40+0x22a>
    365c:	movzx  rcx,BYTE PTR [rax]
    3660:	mov    rsi,rax
    3663:	rex cmp cl,0x8
    3667:	sete   cl
    366a:	test   cl,cl
    366c:	jne    368f <botlish_fn_40+0x24f>
    3672:	mov    rdi,r15
    3675:	mov    rax,QWORD PTR [rdi+0x10]
    3679:	mov    rcx,QWORD PTR [rax+0x20]
    367d:	mov    edx,0x8
    3682:	call   3687 <botlish_fn_40+0x247>
			3683: R_X86_64_PLT32	rt_type_error-0x4
    3687:	mov    rdi,r15
    368a:	jmp    3729 <botlish_fn_40+0x2e9>
    368f:	mov    rdx,QWORD PTR [rsp+0x8]
    3694:	mov    rdi,r15
    3697:	call   369c <botlish_fn_40+0x25c>
			3698: R_X86_64_PLT32	rt_mutarray_get-0x4
    369c:	test   rax,rax
    369f:	jne    36ad <botlish_fn_40+0x26d>
    36a5:	mov    rdi,r15
    36a8:	jmp    3729 <botlish_fn_40+0x2e9>
    36ad:	mov    r13,QWORD PTR [rsp]
    36b1:	mov    rdx,rax
    36b4:	and    rdx,r13
    36b7:	mov    rsi,rax
    36ba:	test   rdx,0x1
    36c1:	jne    36e3 <botlish_fn_40+0x2a3>
    36c7:	mov    rdx,r13
    36ca:	mov    rdi,r15
    36cd:	call   36d2 <botlish_fn_40+0x292>
			36ce: R_X86_64_PLT32	rt_value_eq-0x4
    36d2:	test   rax,rax
    36d5:	jne    36f3 <botlish_fn_40+0x2b3>
    36db:	mov    rdi,r15
    36de:	jmp    3729 <botlish_fn_40+0x2e9>
    36e3:	mov    eax,0x2
    36e8:	cmp    rsi,r13
    36eb:	cmove  rax,QWORD PTR [rip+0x105]        # 37f8 <botlish_fn_40+0x3b8>
    36f3:	cmp    rax,0x6
    36f7:	je     3703 <botlish_fn_40+0x2c3>
    36fd:	mov    r12d,0x2
    3703:	cmp    r12,0x6
    3707:	je     376d <botlish_fn_40+0x32d>
    370d:	mov    rdx,QWORD PTR [rsp+0x8]
    3712:	mov    rsi,rbx
    3715:	mov    rdi,r15
    3718:	call   371d <botlish_fn_40+0x2dd>
			3719: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    371d:	test   rax,rax
    3720:	jne    3754 <botlish_fn_40+0x314>
    3726:	mov    rdi,r15
    3729:	mov    rdi,r15
    372c:	mov    QWORD PTR [rdi],r14
    372f:	xor    rax,rax
    3732:	mov    rbx,QWORD PTR [rsp+0x10]
    3737:	mov    r12,QWORD PTR [rsp+0x18]
    373c:	mov    r13,QWORD PTR [rsp+0x20]
    3741:	mov    r14,QWORD PTR [rsp+0x28]
    3746:	mov    r15,QWORD PTR [rsp+0x30]
    374b:	add    rsp,0x40
    374f:	mov    rsp,rbp
    3752:	pop    rbp
    3753:	ret
    3754:	mov    QWORD PTR [r14],rbx
    3757:	mov    QWORD PTR [r14+0x8],r13
    375b:	mov    QWORD PTR [r14+0x10],rax
    375f:	mov    QWORD PTR [rsp],r13
    3763:	mov    QWORD PTR [rsp+0x8],rax
    3768:	jmp    34b5 <botlish_fn_40+0x75>
    376d:	mov    rdi,r15
    3770:	mov    QWORD PTR [rdi],r14
    3773:	mov    rax,QWORD PTR [rsp+0x8]
    3778:	mov    rbx,QWORD PTR [rsp+0x10]
    377d:	mov    r12,QWORD PTR [rsp+0x18]
    3782:	mov    r13,QWORD PTR [rsp+0x20]
    3787:	mov    r14,QWORD PTR [rsp+0x28]
    378c:	mov    r15,QWORD PTR [rsp+0x30]
    3791:	add    rsp,0x40
    3795:	mov    rsp,rbp
    3798:	pop    rbp
    3799:	ret
    379a:	mov    rdi,r15
    379d:	mov    QWORD PTR [rdi],r14
    37a0:	mov    rax,0xffffffffffffffff
    37a7:	mov    rbx,QWORD PTR [rsp+0x10]
    37ac:	mov    r12,QWORD PTR [rsp+0x18]
    37b1:	mov    r13,QWORD PTR [rsp+0x20]
    37b6:	mov    r14,QWORD PTR [rsp+0x28]
    37bb:	mov    r15,QWORD PTR [rsp+0x30]
    37c0:	add    rsp,0x40
    37c4:	mov    rsp,rbp
    37c7:	pop    rbp
    37c8:	ret
    37c9:	mov    r15,rdi
    37cc:	call   37d1 <botlish_fn_40+0x391>
			37cd: R_X86_64_PLT32	rt_stack_overflow-0x4
    37d1:	xor    rax,rax
    37d4:	mov    rbx,QWORD PTR [rsp+0x10]
    37d9:	mov    r12,QWORD PTR [rsp+0x18]
    37de:	mov    r13,QWORD PTR [rsp+0x20]
    37e3:	mov    r14,QWORD PTR [rsp+0x28]
    37e8:	mov    r15,QWORD PTR [rsp+0x30]
    37ed:	add    rsp,0x40
    37f1:	mov    rsp,rbp
    37f4:	pop    rbp
    37f5:	ret
    37f6:	add    BYTE PTR [rax],al
    37f8:	(bad)
    37f9:	add    BYTE PTR [rax],al
    37fb:	add    BYTE PTR [rax],al
    37fd:	add    BYTE PTR [rax],al
	...

0000000000003800 <botlish_entry_40: ht_find_get<any, str, int>>:
    3800:	push   rbp
    3801:	mov    rbp,rsp
    3804:	mov    rsi,QWORD PTR [rdx]
    3807:	mov    r8,QWORD PTR [rdx+0x8]
    380b:	mov    rcx,QWORD PTR [rdx+0x10]
    380f:	mov    rdx,r8
    3812:	call   3817 <botlish_entry_40+0x17>
			3813: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    3817:	mov    rsp,rbp
    381a:	pop    rbp
    381b:	ret
    381c:	add    BYTE PTR [rax],al
	...

0000000000003820 <botlish_fn_41: ht_find_insert<mutarray, any, int, int>>:
    3820:	push   rbp
    3821:	mov    rbp,rsp
    3824:	sub    rsp,0x50
    3828:	mov    QWORD PTR [rsp+0x20],rbx
    382d:	mov    QWORD PTR [rsp+0x28],r12
    3832:	mov    QWORD PTR [rsp+0x30],r13
    3837:	mov    QWORD PTR [rsp+0x38],r14
    383c:	mov    QWORD PTR [rsp+0x40],r15
    3841:	mov    r12,QWORD PTR [rdi]
    3844:	mov    rax,QWORD PTR [rdi+0x8]
    3848:	lea    r9,[r12+0x28]
    384d:	cmp    r9,rax
    3850:	ja     3dd1 <botlish_fn_41+0x5b1>
    3856:	lea    rax,[r12+0x28]
    385b:	mov    QWORD PTR [rdi],rax
    385e:	mov    QWORD PTR [rsp],rdi
    3862:	mov    QWORD PTR [r12],0x0
    386a:	mov    QWORD PTR [r12+0x8],0x0
    3873:	mov    QWORD PTR [r12+0x10],0x0
    387c:	mov    QWORD PTR [r12+0x18],0x0
    3885:	mov    QWORD PTR [r12+0x20],0x0
    388e:	mov    QWORD PTR [r12],rsi
    3892:	mov    QWORD PTR [r12+0x8],rdx
    3897:	mov    r13,rdx
    389a:	mov    QWORD PTR [r12+0x10],rcx
    389f:	mov    QWORD PTR [r12+0x18],r8
    38a4:	mov    rbx,rsi
    38a7:	mov    QWORD PTR [rsp+0x8],rcx
    38ac:	mov    QWORD PTR [rsp+0x10],r8
    38b1:	mov    rsi,rbx
    38b4:	mov    rdi,QWORD PTR [rsp]
    38b8:	call   38bd <botlish_fn_41+0x9d>
			38b9: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    38bd:	test   rax,rax
    38c0:	jne    38cf <botlish_fn_41+0xaf>
    38c6:	mov    rdi,QWORD PTR [rsp]
    38ca:	jmp    3c8f <botlish_fn_41+0x46f>
    38cf:	xor    ecx,ecx
    38d1:	test   rax,0x7
    38d7:	je     38e5 <botlish_fn_41+0xc5>
    38dd:	mov    rsi,rax
    38e0:	jmp    38f3 <botlish_fn_41+0xd3>
    38e5:	movzx  rcx,BYTE PTR [rax]
    38e9:	mov    rsi,rax
    38ec:	rex cmp cl,0x8
    38f0:	sete   cl
    38f3:	test   cl,cl
    38f5:	jne    391a <botlish_fn_41+0xfa>
    38fb:	mov    rdi,QWORD PTR [rsp]
    38ff:	mov    rax,QWORD PTR [rdi+0x10]
    3903:	mov    rcx,QWORD PTR [rax+0x20]
    3907:	mov    edx,0x8
    390c:	call   3911 <botlish_fn_41+0xf1>
			390d: R_X86_64_PLT32	rt_type_error-0x4
    3911:	mov    rdi,QWORD PTR [rsp]
    3915:	jmp    3c8f <botlish_fn_41+0x46f>
    391a:	mov    rdx,QWORD PTR [rsp+0x8]
    391f:	mov    rdi,QWORD PTR [rsp]
    3923:	call   3928 <botlish_fn_41+0x108>
			3924: R_X86_64_PLT32	rt_mutarray_get-0x4
    3928:	mov    rcx,rax
    392b:	mov    QWORD PTR [rsp+0x18],rax
    3930:	test   rax,rcx
    3933:	jne    3942 <botlish_fn_41+0x122>
    3939:	mov    rdi,QWORD PTR [rsp]
    393d:	jmp    3c8f <botlish_fn_41+0x46f>
    3942:	mov    rax,QWORD PTR [rsp+0x18]
    3947:	mov    QWORD PTR [r12+0x20],rax
    394c:	mov    rdi,QWORD PTR [rsp]
    3950:	call   3955 <botlish_fn_41+0x135>
			3951: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    3955:	test   rax,rax
    3958:	jne    3967 <botlish_fn_41+0x147>
    395e:	mov    rdi,QWORD PTR [rsp]
    3962:	jmp    3c8f <botlish_fn_41+0x46f>
    3967:	mov    rcx,QWORD PTR [rsp+0x18]
    396c:	and    rcx,rax
    396f:	mov    rdx,rax
    3972:	test   rcx,0x1
    3979:	jne    399f <botlish_fn_41+0x17f>
    397f:	mov    rsi,QWORD PTR [rsp+0x18]
    3984:	mov    rdi,QWORD PTR [rsp]
    3988:	call   398d <botlish_fn_41+0x16d>
			3989: R_X86_64_PLT32	rt_value_eq-0x4
    398d:	test   rax,rax
    3990:	jne    39b4 <botlish_fn_41+0x194>
    3996:	mov    rdi,QWORD PTR [rsp]
    399a:	jmp    3c8f <botlish_fn_41+0x46f>
    399f:	mov    eax,0x2
    39a4:	mov    rcx,QWORD PTR [rsp+0x18]
    39a9:	cmp    rcx,rdx
    39ac:	cmove  rax,QWORD PTR [rip+0x44c]        # 3e00 <botlish_fn_41+0x5e0>
    39b4:	mov    r14d,0x6
    39ba:	cmp    rax,0x6
    39be:	je     3d18 <botlish_fn_41+0x4f8>
    39c4:	mov    rdi,QWORD PTR [rsp]
    39c8:	call   39cd <botlish_fn_41+0x1ad>
			39c9: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    39cd:	test   rax,rax
    39d0:	jne    39df <botlish_fn_41+0x1bf>
    39d6:	mov    rdi,QWORD PTR [rsp]
    39da:	jmp    3c8f <botlish_fn_41+0x46f>
    39df:	mov    rcx,QWORD PTR [rsp+0x18]
    39e4:	mov    rsi,rcx
    39e7:	and    rsi,rax
    39ea:	mov    rdx,rax
    39ed:	test   rsi,0x1
    39f4:	jne    3a1a <botlish_fn_41+0x1fa>
    39fa:	mov    rsi,QWORD PTR [rsp+0x18]
    39ff:	mov    rdi,QWORD PTR [rsp]
    3a03:	call   3a08 <botlish_fn_41+0x1e8>
			3a04: R_X86_64_PLT32	rt_value_eq-0x4
    3a08:	test   rax,rax
    3a0b:	jne    3a2f <botlish_fn_41+0x20f>
    3a11:	mov    rdi,QWORD PTR [rsp]
    3a15:	jmp    3c8f <botlish_fn_41+0x46f>
    3a1a:	mov    eax,0x2
    3a1f:	mov    r10,QWORD PTR [rsp+0x18]
    3a24:	cmp    r10,rdx
    3a27:	cmove  rax,QWORD PTR [rip+0x3d1]        # 3e00 <botlish_fn_41+0x5e0>
    3a2f:	cmp    rax,0x6
    3a33:	je     3a46 <botlish_fn_41+0x226>
    3a39:	mov    eax,0x2
    3a3e:	mov    r15,r13
    3a41:	jmp    3b2d <botlish_fn_41+0x30d>
    3a46:	mov    rsi,rbx
    3a49:	mov    rdi,QWORD PTR [rsp]
    3a4d:	call   3a52 <botlish_fn_41+0x232>
			3a4e: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    3a52:	test   rax,rax
    3a55:	jne    3a64 <botlish_fn_41+0x244>
    3a5b:	mov    rdi,QWORD PTR [rsp]
    3a5f:	jmp    3c8f <botlish_fn_41+0x46f>
    3a64:	xor    ecx,ecx
    3a66:	test   rax,0x7
    3a6c:	je     3a7a <botlish_fn_41+0x25a>
    3a72:	mov    rsi,rax
    3a75:	jmp    3a88 <botlish_fn_41+0x268>
    3a7a:	movzx  rcx,BYTE PTR [rax]
    3a7e:	mov    rsi,rax
    3a81:	rex cmp cl,0x8
    3a85:	sete   cl
    3a88:	test   cl,cl
    3a8a:	jne    3aaf <botlish_fn_41+0x28f>
    3a90:	mov    rdi,QWORD PTR [rsp]
    3a94:	mov    rax,QWORD PTR [rdi+0x10]
    3a98:	mov    rcx,QWORD PTR [rax+0x20]
    3a9c:	mov    edx,0x8
    3aa1:	call   3aa6 <botlish_fn_41+0x286>
			3aa2: R_X86_64_PLT32	rt_type_error-0x4
    3aa6:	mov    rdi,QWORD PTR [rsp]
    3aaa:	jmp    3c8f <botlish_fn_41+0x46f>
    3aaf:	mov    rdx,QWORD PTR [rsp+0x8]
    3ab4:	mov    rdi,QWORD PTR [rsp]
    3ab8:	call   3abd <botlish_fn_41+0x29d>
			3ab9: R_X86_64_PLT32	rt_mutarray_get-0x4
    3abd:	test   rax,rax
    3ac0:	jne    3acf <botlish_fn_41+0x2af>
    3ac6:	mov    rdi,QWORD PTR [rsp]
    3aca:	jmp    3c8f <botlish_fn_41+0x46f>
    3acf:	mov    r15,r13
    3ad2:	mov    rcx,rax
    3ad5:	and    rcx,r15
    3ad8:	mov    rsi,rax
    3adb:	test   rcx,0x1
    3ae2:	jne    3b06 <botlish_fn_41+0x2e6>
    3ae8:	mov    rdx,r15
    3aeb:	mov    rdi,QWORD PTR [rsp]
    3aef:	call   3af4 <botlish_fn_41+0x2d4>
			3af0: R_X86_64_PLT32	rt_value_eq-0x4
    3af4:	test   rax,rax
    3af7:	jne    3b16 <botlish_fn_41+0x2f6>
    3afd:	mov    rdi,QWORD PTR [rsp]
    3b01:	jmp    3c8f <botlish_fn_41+0x46f>
    3b06:	mov    eax,0x2
    3b0b:	cmp    rsi,r15
    3b0e:	cmove  rax,QWORD PTR [rip+0x2ea]        # 3e00 <botlish_fn_41+0x5e0>
    3b16:	cmp    rax,0x6
    3b1a:	je     3b2a <botlish_fn_41+0x30a>
    3b20:	mov    eax,0x2
    3b25:	jmp    3b2d <botlish_fn_41+0x30d>
    3b2a:	mov    rax,r14
    3b2d:	cmp    rax,0x6
    3b31:	je     3cea <botlish_fn_41+0x4ca>
    3b37:	mov    rdi,QWORD PTR [rsp]
    3b3b:	call   3b40 <botlish_fn_41+0x320>
			3b3c: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    3b40:	test   rax,rax
    3b43:	jne    3b52 <botlish_fn_41+0x332>
    3b49:	mov    rdi,QWORD PTR [rsp]
    3b4d:	jmp    3c8f <botlish_fn_41+0x46f>
    3b52:	mov    rcx,QWORD PTR [rsp+0x18]
    3b57:	mov    rdx,rcx
    3b5a:	and    rdx,rax
    3b5d:	mov    r11,rax
    3b60:	test   rdx,0x1
    3b67:	jne    3b90 <botlish_fn_41+0x370>
    3b6d:	mov    rdx,r11
    3b70:	mov    rsi,QWORD PTR [rsp+0x18]
    3b75:	mov    rdi,QWORD PTR [rsp]
    3b79:	call   3b7e <botlish_fn_41+0x35e>
			3b7a: R_X86_64_PLT32	rt_value_eq-0x4
    3b7e:	test   rax,rax
    3b81:	jne    3ba8 <botlish_fn_41+0x388>
    3b87:	mov    rdi,QWORD PTR [rsp]
    3b8b:	jmp    3c8f <botlish_fn_41+0x46f>
    3b90:	mov    rdx,r11
    3b93:	mov    rsi,QWORD PTR [rsp+0x18]
    3b98:	mov    eax,0x2
    3b9d:	cmp    rsi,rdx
    3ba0:	cmove  rax,QWORD PTR [rip+0x258]        # 3e00 <botlish_fn_41+0x5e0>
    3ba8:	cmp    rax,0x6
    3bac:	je     3bbd <botlish_fn_41+0x39d>
    3bb2:	mov    r14d,0x2
    3bb8:	jmp    3c1f <botlish_fn_41+0x3ff>
    3bbd:	mov    r13,QWORD PTR [rsp+0x10]
    3bc2:	test   r13,0x1
    3bc9:	jne    3bfa <botlish_fn_41+0x3da>
    3bcf:	mov    edx,0x1
    3bd4:	mov    rsi,r13
    3bd7:	mov    rdi,QWORD PTR [rsp]
    3bdb:	call   3be0 <botlish_fn_41+0x3c0>
			3bdc: R_X86_64_PLT32	rt_int_cmp-0x4
    3be0:	mov    ecx,0x2
    3be5:	test   rax,rax
    3be8:	cmovl  rcx,QWORD PTR [rip+0x210]        # 3e00 <botlish_fn_41+0x5e0>
    3bf0:	mov    QWORD PTR [rsp+0x10],r13
    3bf5:	jmp    3c0f <botlish_fn_41+0x3ef>
    3bfa:	mov    ecx,0x2
    3bff:	test   r13,r13
    3c02:	mov    QWORD PTR [rsp+0x10],r13
    3c07:	cmovle rcx,QWORD PTR [rip+0x1f1]        # 3e00 <botlish_fn_41+0x5e0>
    3c0f:	cmp    rcx,0x6
    3c13:	je     3c1f <botlish_fn_41+0x3ff>
    3c19:	mov    r14d,0x2
    3c1f:	cmp    r14,0x6
    3c23:	je     3c71 <botlish_fn_41+0x451>
    3c29:	mov    rdx,QWORD PTR [rsp+0x8]
    3c2e:	mov    rsi,rbx
    3c31:	mov    rdi,QWORD PTR [rsp]
    3c35:	call   3c3a <botlish_fn_41+0x41a>
			3c36: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    3c3a:	test   rax,rax
    3c3d:	jne    3c4c <botlish_fn_41+0x42c>
    3c43:	mov    rdi,QWORD PTR [rsp]
    3c47:	jmp    3c8f <botlish_fn_41+0x46f>
    3c4c:	mov    QWORD PTR [r12],rbx
    3c50:	mov    QWORD PTR [r12+0x8],r15
    3c55:	mov    QWORD PTR [r12+0x10],rax
    3c5a:	mov    rcx,QWORD PTR [rsp+0x10]
    3c5f:	mov    QWORD PTR [r12+0x18],rcx
    3c64:	mov    r13,r15
    3c67:	mov    QWORD PTR [rsp+0x8],rax
    3c6c:	jmp    38b1 <botlish_fn_41+0x91>
    3c71:	mov    rdx,QWORD PTR [rsp+0x8]
    3c76:	mov    rsi,rbx
    3c79:	mov    rdi,QWORD PTR [rsp]
    3c7d:	call   3c82 <botlish_fn_41+0x462>
			3c7e: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    3c82:	test   rax,rax
    3c85:	jne    3cbb <botlish_fn_41+0x49b>
    3c8b:	mov    rdi,QWORD PTR [rsp]
    3c8f:	mov    rdi,QWORD PTR [rsp]
    3c93:	mov    QWORD PTR [rdi],r12
    3c96:	xor    rax,rax
    3c99:	mov    rbx,QWORD PTR [rsp+0x20]
    3c9e:	mov    r12,QWORD PTR [rsp+0x28]
    3ca3:	mov    r13,QWORD PTR [rsp+0x30]
    3ca8:	mov    r14,QWORD PTR [rsp+0x38]
    3cad:	mov    r15,QWORD PTR [rsp+0x40]
    3cb2:	add    rsp,0x50
    3cb6:	mov    rsp,rbp
    3cb9:	pop    rbp
    3cba:	ret
    3cbb:	mov    QWORD PTR [r12],rbx
    3cbf:	mov    QWORD PTR [r12+0x8],r15
    3cc4:	mov    QWORD PTR [r12+0x10],rax
    3cc9:	mov    rdx,QWORD PTR [rsp+0x8]
    3cce:	mov    QWORD PTR [r12+0x18],rdx
    3cd3:	mov    rcx,QWORD PTR [rsp+0x8]
    3cd8:	mov    QWORD PTR [rsp+0x10],rcx
    3cdd:	mov    QWORD PTR [rsp+0x8],rax
    3ce2:	mov    r13,r15
    3ce5:	jmp    38b1 <botlish_fn_41+0x91>
    3cea:	mov    rdi,QWORD PTR [rsp]
    3cee:	mov    QWORD PTR [rdi],r12
    3cf1:	mov    rax,QWORD PTR [rsp+0x8]
    3cf6:	mov    rbx,QWORD PTR [rsp+0x20]
    3cfb:	mov    r12,QWORD PTR [rsp+0x28]
    3d00:	mov    r13,QWORD PTR [rsp+0x30]
    3d05:	mov    r14,QWORD PTR [rsp+0x38]
    3d0a:	mov    r15,QWORD PTR [rsp+0x40]
    3d0f:	add    rsp,0x50
    3d13:	mov    rsp,rbp
    3d16:	pop    rbp
    3d17:	ret
    3d18:	mov    rax,QWORD PTR [rsp+0x10]
    3d1d:	test   rax,0x1
    3d23:	jne    3d51 <botlish_fn_41+0x531>
    3d29:	mov    edx,0x1
    3d2e:	mov    rsi,QWORD PTR [rsp+0x10]
    3d33:	mov    rdi,QWORD PTR [rsp]
    3d37:	call   3d3c <botlish_fn_41+0x51c>
			3d38: R_X86_64_PLT32	rt_int_cmp-0x4
    3d3c:	mov    ecx,0x2
    3d41:	test   rax,rax
    3d44:	cmovge rcx,QWORD PTR [rip+0xb4]        # 3e00 <botlish_fn_41+0x5e0>
    3d4c:	jmp    3d6b <botlish_fn_41+0x54b>
    3d51:	mov    ecx,0x2
    3d56:	mov    rax,QWORD PTR [rsp+0x10]
    3d5b:	mov    rdx,QWORD PTR [rsp+0x10]
    3d60:	test   rax,rdx
    3d63:	cmovg  rcx,QWORD PTR [rip+0x95]        # 3e00 <botlish_fn_41+0x5e0>
    3d6b:	cmp    rcx,0x6
    3d6f:	je     3da3 <botlish_fn_41+0x583>
    3d75:	mov    rdi,QWORD PTR [rsp]
    3d79:	mov    QWORD PTR [rdi],r12
    3d7c:	mov    rax,QWORD PTR [rsp+0x8]
    3d81:	mov    rbx,QWORD PTR [rsp+0x20]
    3d86:	mov    r12,QWORD PTR [rsp+0x28]
    3d8b:	mov    r13,QWORD PTR [rsp+0x30]
    3d90:	mov    r14,QWORD PTR [rsp+0x38]
    3d95:	mov    r15,QWORD PTR [rsp+0x40]
    3d9a:	add    rsp,0x50
    3d9e:	mov    rsp,rbp
    3da1:	pop    rbp
    3da2:	ret
    3da3:	mov    rdi,QWORD PTR [rsp]
    3da7:	mov    QWORD PTR [rdi],r12
    3daa:	mov    rax,QWORD PTR [rsp+0x10]
    3daf:	mov    rbx,QWORD PTR [rsp+0x20]
    3db4:	mov    r12,QWORD PTR [rsp+0x28]
    3db9:	mov    r13,QWORD PTR [rsp+0x30]
    3dbe:	mov    r14,QWORD PTR [rsp+0x38]
    3dc3:	mov    r15,QWORD PTR [rsp+0x40]
    3dc8:	add    rsp,0x50
    3dcc:	mov    rsp,rbp
    3dcf:	pop    rbp
    3dd0:	ret
    3dd1:	mov    QWORD PTR [rsp],rdi
    3dd5:	call   3dda <botlish_fn_41+0x5ba>
			3dd6: R_X86_64_PLT32	rt_stack_overflow-0x4
    3dda:	xor    rax,rax
    3ddd:	mov    rbx,QWORD PTR [rsp+0x20]
    3de2:	mov    r12,QWORD PTR [rsp+0x28]
    3de7:	mov    r13,QWORD PTR [rsp+0x30]
    3dec:	mov    r14,QWORD PTR [rsp+0x38]
    3df1:	mov    r15,QWORD PTR [rsp+0x40]
    3df6:	add    rsp,0x50
    3dfa:	mov    rsp,rbp
    3dfd:	pop    rbp
    3dfe:	ret
    3dff:	add    BYTE PTR [rsi],al
    3e01:	add    BYTE PTR [rax],al
    3e03:	add    BYTE PTR [rax],al
    3e05:	add    BYTE PTR [rax],al
	...

0000000000003e08 <botlish_entry_41: ht_find_insert<mutarray, any, int, int>>:
    3e08:	push   rbp
    3e09:	mov    rbp,rsp
    3e0c:	mov    rsi,QWORD PTR [rdx]
    3e0f:	mov    r9,QWORD PTR [rdx+0x8]
    3e13:	mov    rcx,QWORD PTR [rdx+0x10]
    3e17:	mov    r8,QWORD PTR [rdx+0x18]
    3e1b:	mov    rdx,r9
    3e1e:	call   3e23 <botlish_entry_41+0x1b>
			3e1f: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    3e23:	mov    rsp,rbp
    3e26:	pop    rbp
    3e27:	ret

0000000000003e28 <botlish_fn_42: ht_get<any, str>>:
    3e28:	push   rbp
    3e29:	mov    rbp,rsp
    3e2c:	sub    rsp,0x20
    3e30:	mov    QWORD PTR [rsp],rbx
    3e34:	mov    QWORD PTR [rsp+0x8],r12
    3e39:	mov    QWORD PTR [rsp+0x10],r13
    3e3e:	mov    QWORD PTR [rsp+0x18],r14
    3e43:	mov    rbx,QWORD PTR [rdi]
    3e46:	mov    rax,QWORD PTR [rdi+0x8]
    3e4a:	lea    rcx,[rbx+0x18]
    3e4e:	cmp    rcx,rax
    3e51:	ja     400a <botlish_fn_42+0x1e2>
    3e57:	lea    rax,[rbx+0x18]
    3e5b:	mov    QWORD PTR [rdi],rax
    3e5e:	mov    r12,rdi
    3e61:	mov    QWORD PTR [rbx],0x0
    3e68:	mov    QWORD PTR [rbx+0x8],0x0
    3e70:	mov    QWORD PTR [rbx+0x10],0x0
    3e78:	mov    QWORD PTR [rbx],rsi
    3e7b:	mov    r13,rsi
    3e7e:	mov    QWORD PTR [rbx+0x8],rdx
    3e82:	mov    r14,rdx
    3e85:	mov    rdx,r14
    3e88:	mov    rsi,r13
    3e8b:	mov    rdi,r12
    3e8e:	call   3e93 <botlish_fn_42+0x6b>
			3e8f: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    3e93:	test   rax,rax
    3e96:	jne    3ea4 <botlish_fn_42+0x7c>
    3e9c:	mov    rdi,r12
    3e9f:	jmp    3f9c <botlish_fn_42+0x174>
    3ea4:	mov    QWORD PTR [rbx+0x10],rax
    3ea8:	mov    rcx,rax
    3eab:	mov    rdx,r14
    3eae:	mov    rsi,r13
    3eb1:	mov    rdi,r12
    3eb4:	call   3eb9 <botlish_fn_42+0x91>
			3eb5: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    3eb9:	mov    rcx,rax
    3ebc:	mov    r14,rax
    3ebf:	test   rax,rcx
    3ec2:	jne    3ed0 <botlish_fn_42+0xa8>
    3ec8:	mov    rdi,r12
    3ecb:	jmp    3f9c <botlish_fn_42+0x174>
    3ed0:	mov    rax,r14
    3ed3:	mov    QWORD PTR [rbx+0x8],rax
    3ed7:	test   rax,0x1
    3edd:	jne    3f08 <botlish_fn_42+0xe0>
    3ee3:	mov    edx,0x1
    3ee8:	mov    rsi,r14
    3eeb:	mov    rdi,r12
    3eee:	call   3ef3 <botlish_fn_42+0xcb>
			3eef: R_X86_64_PLT32	rt_int_cmp-0x4
    3ef3:	mov    ecx,0x2
    3ef8:	test   rax,rax
    3efb:	cmovl  rcx,QWORD PTR [rip+0x135]        # 4038 <botlish_fn_42+0x210>
    3f03:	jmp    3f1b <botlish_fn_42+0xf3>
    3f08:	mov    ecx,0x2
    3f0d:	mov    rax,r14
    3f10:	test   rax,rax
    3f13:	cmovle rcx,QWORD PTR [rip+0x11d]        # 4038 <botlish_fn_42+0x210>
    3f1b:	cmp    rcx,0x6
    3f1f:	je     3fe3 <botlish_fn_42+0x1bb>
    3f25:	mov    rsi,r13
    3f28:	mov    rdi,r12
    3f2b:	call   3f30 <botlish_fn_42+0x108>
			3f2c: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    3f30:	test   rax,rax
    3f33:	jne    3f41 <botlish_fn_42+0x119>
    3f39:	mov    rdi,r12
    3f3c:	jmp    3f9c <botlish_fn_42+0x174>
    3f41:	xor    ecx,ecx
    3f43:	test   rax,0x7
    3f49:	jne    3f5a <botlish_fn_42+0x132>
    3f4f:	movzx  rdx,BYTE PTR [rax]
    3f53:	rex cmp dl,0x8
    3f57:	sete   cl
    3f5a:	test   cl,cl
    3f5c:	jne    3f82 <botlish_fn_42+0x15a>
    3f62:	mov    rdi,r12
    3f65:	mov    rsi,QWORD PTR [rdi+0x10]
    3f69:	mov    rcx,QWORD PTR [rsi+0x20]
    3f6d:	mov    edx,0x8
    3f72:	mov    rsi,rax
    3f75:	call   3f7a <botlish_fn_42+0x152>
			3f76: R_X86_64_PLT32	rt_type_error-0x4
    3f7a:	mov    rdi,r12
    3f7d:	jmp    3f9c <botlish_fn_42+0x174>
    3f82:	mov    rdx,r14
    3f85:	mov    rsi,rax
    3f88:	mov    rdi,r12
    3f8b:	call   3f90 <botlish_fn_42+0x168>
			3f8c: R_X86_64_PLT32	rt_mutarray_get-0x4
    3f90:	test   rax,rax
    3f93:	jne    3fc1 <botlish_fn_42+0x199>
    3f99:	mov    rdi,r12
    3f9c:	mov    rdi,r12
    3f9f:	mov    QWORD PTR [rdi],rbx
    3fa2:	xor    rax,rax
    3fa5:	mov    rbx,QWORD PTR [rsp]
    3fa9:	mov    r12,QWORD PTR [rsp+0x8]
    3fae:	mov    r13,QWORD PTR [rsp+0x10]
    3fb3:	mov    r14,QWORD PTR [rsp+0x18]
    3fb8:	add    rsp,0x20
    3fbc:	mov    rsp,rbp
    3fbf:	pop    rbp
    3fc0:	ret
    3fc1:	mov    rdi,r12
    3fc4:	mov    QWORD PTR [rdi],rbx
    3fc7:	mov    rbx,QWORD PTR [rsp]
    3fcb:	mov    r12,QWORD PTR [rsp+0x8]
    3fd0:	mov    r13,QWORD PTR [rsp+0x10]
    3fd5:	mov    r14,QWORD PTR [rsp+0x18]
    3fda:	add    rsp,0x20
    3fde:	mov    rsp,rbp
    3fe1:	pop    rbp
    3fe2:	ret
    3fe3:	mov    rdi,r12
    3fe6:	mov    QWORD PTR [rdi],rbx
    3fe9:	mov    eax,0xa
    3fee:	mov    rbx,QWORD PTR [rsp]
    3ff2:	mov    r12,QWORD PTR [rsp+0x8]
    3ff7:	mov    r13,QWORD PTR [rsp+0x10]
    3ffc:	mov    r14,QWORD PTR [rsp+0x18]
    4001:	add    rsp,0x20
    4005:	mov    rsp,rbp
    4008:	pop    rbp
    4009:	ret
    400a:	mov    r12,rdi
    400d:	call   4012 <botlish_fn_42+0x1ea>
			400e: R_X86_64_PLT32	rt_stack_overflow-0x4
    4012:	xor    rax,rax
    4015:	mov    rbx,QWORD PTR [rsp]
    4019:	mov    r12,QWORD PTR [rsp+0x8]
    401e:	mov    r13,QWORD PTR [rsp+0x10]
    4023:	mov    r14,QWORD PTR [rsp+0x18]
    4028:	add    rsp,0x20
    402c:	mov    rsp,rbp
    402f:	pop    rbp
    4030:	ret
    4031:	add    BYTE PTR [rax],al
    4033:	add    BYTE PTR [rax],al
    4035:	add    BYTE PTR [rax],al
    4037:	add    BYTE PTR [rsi],al
    4039:	add    BYTE PTR [rax],al
    403b:	add    BYTE PTR [rax],al
    403d:	add    BYTE PTR [rax],al
	...

0000000000004040 <botlish_entry_42: ht_get<any, str>>:
    4040:	push   rbp
    4041:	mov    rbp,rsp
    4044:	mov    rsi,QWORD PTR [rdx]
    4047:	mov    rdx,QWORD PTR [rdx+0x8]
    404b:	call   4050 <botlish_entry_42+0x10>
			404c: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    4050:	mov    rsp,rbp
    4053:	pop    rbp
    4054:	ret
    4055:	add    BYTE PTR [rax],al
	...

0000000000004058 <botlish_fn_43: ht_rehash_probe<mutarray, int, int>>:
    4058:	push   rbp
    4059:	mov    rbp,rsp
    405c:	sub    rsp,0x40
    4060:	mov    QWORD PTR [rsp+0x10],rbx
    4065:	mov    QWORD PTR [rsp+0x18],r12
    406a:	mov    QWORD PTR [rsp+0x20],r13
    406f:	mov    QWORD PTR [rsp+0x28],r14
    4074:	mov    QWORD PTR [rsp+0x30],r15
    4079:	mov    r12,QWORD PTR [rdi]
    407c:	mov    rax,QWORD PTR [rdi+0x8]
    4080:	lea    r8,[r12+0x20]
    4085:	cmp    r8,rax
    4088:	ja     422a <botlish_fn_43+0x1d2>
    408e:	lea    rax,[r12+0x20]
    4093:	mov    QWORD PTR [rdi],rax
    4096:	mov    r14,rdi
    4099:	mov    QWORD PTR [r12],0x0
    40a1:	mov    QWORD PTR [r12+0x8],0x0
    40aa:	mov    QWORD PTR [r12+0x10],0x0
    40b3:	mov    QWORD PTR [r12+0x18],0x0
    40bc:	mov    QWORD PTR [r12],rsi
    40c0:	mov    QWORD PTR [r12+0x8],rdx
    40c5:	mov    QWORD PTR [r12+0x10],rcx
    40ca:	mov    r13,rcx
    40cd:	mov    rbx,rsi
    40d0:	mov    r15,rdx
    40d3:	mov    rdx,r15
    40d6:	mov    rsi,rbx
    40d9:	mov    rdi,r14
    40dc:	call   40e1 <botlish_fn_43+0x89>
			40dd: R_X86_64_PLT32	rt_mutarray_get-0x4
    40e1:	test   rax,rax
    40e4:	jne    40f2 <botlish_fn_43+0x9a>
    40ea:	mov    rdi,r14
    40ed:	jmp    41be <botlish_fn_43+0x166>
    40f2:	mov    QWORD PTR [r12+0x18],rax
    40f7:	mov    QWORD PTR [rsp],rax
    40fb:	mov    rdi,r14
    40fe:	call   4103 <botlish_fn_43+0xab>
			40ff: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    4103:	test   rax,rax
    4106:	jne    4114 <botlish_fn_43+0xbc>
    410c:	mov    rdi,r14
    410f:	jmp    41be <botlish_fn_43+0x166>
    4114:	mov    r9,QWORD PTR [rsp]
    4118:	mov    rcx,r9
    411b:	and    rcx,rax
    411e:	mov    rdx,rax
    4121:	test   rcx,0x1
    4128:	jne    414b <botlish_fn_43+0xf3>
    412e:	mov    rsi,QWORD PTR [rsp]
    4132:	mov    rdi,r14
    4135:	call   413a <botlish_fn_43+0xe2>
			4136: R_X86_64_PLT32	rt_value_eq-0x4
    413a:	test   rax,rax
    413d:	jne    415f <botlish_fn_43+0x107>
    4143:	mov    rdi,r14
    4146:	jmp    41be <botlish_fn_43+0x166>
    414b:	mov    rsi,QWORD PTR [rsp]
    414f:	mov    eax,0x2
    4154:	cmp    rsi,rdx
    4157:	cmove  rax,QWORD PTR [rip+0xf9]        # 4258 <botlish_fn_43+0x200>
    415f:	cmp    rax,0x6
    4163:	je     41ff <botlish_fn_43+0x1a7>
    4169:	mov    QWORD PTR [r12+0x18],0x3
    4172:	mov    rsi,r15
    4175:	test   rsi,0x1
    417c:	je     4194 <botlish_fn_43+0x13c>
    4182:	mov    rsi,r15
    4185:	add    rsi,0x2
    4189:	seto   al
    418c:	test   al,al
    418e:	je     41a7 <botlish_fn_43+0x14f>
    4194:	mov    edx,0x3
    4199:	mov    rsi,r15
    419c:	mov    rdi,r14
    419f:	call   41a4 <botlish_fn_43+0x14c>
			41a0: R_X86_64_PLT32	rt_int_add-0x4
    41a4:	mov    rsi,rax
    41a7:	mov    rdx,r13
    41aa:	mov    rdi,r14
    41ad:	call   41b2 <botlish_fn_43+0x15a>
			41ae: R_X86_64_PLT32	rt_int_mod-0x4
    41b2:	test   rax,rax
    41b5:	jne    41e9 <botlish_fn_43+0x191>
    41bb:	mov    rdi,r14
    41be:	mov    rdi,r14
    41c1:	mov    QWORD PTR [rdi],r12
    41c4:	xor    rax,rax
    41c7:	mov    rbx,QWORD PTR [rsp+0x10]
    41cc:	mov    r12,QWORD PTR [rsp+0x18]
    41d1:	mov    r13,QWORD PTR [rsp+0x20]
    41d6:	mov    r14,QWORD PTR [rsp+0x28]
    41db:	mov    r15,QWORD PTR [rsp+0x30]
    41e0:	add    rsp,0x40
    41e4:	mov    rsp,rbp
    41e7:	pop    rbp
    41e8:	ret
    41e9:	mov    QWORD PTR [r12],rbx
    41ed:	mov    QWORD PTR [r12+0x8],rax
    41f2:	mov    QWORD PTR [r12+0x10],r13
    41f7:	mov    r15,rax
    41fa:	jmp    40d3 <botlish_fn_43+0x7b>
    41ff:	mov    rdi,r14
    4202:	mov    QWORD PTR [rdi],r12
    4205:	mov    rax,r15
    4208:	mov    rbx,QWORD PTR [rsp+0x10]
    420d:	mov    r12,QWORD PTR [rsp+0x18]
    4212:	mov    r13,QWORD PTR [rsp+0x20]
    4217:	mov    r14,QWORD PTR [rsp+0x28]
    421c:	mov    r15,QWORD PTR [rsp+0x30]
    4221:	add    rsp,0x40
    4225:	mov    rsp,rbp
    4228:	pop    rbp
    4229:	ret
    422a:	mov    r14,rdi
    422d:	call   4232 <botlish_fn_43+0x1da>
			422e: R_X86_64_PLT32	rt_stack_overflow-0x4
    4232:	xor    rax,rax
    4235:	mov    rbx,QWORD PTR [rsp+0x10]
    423a:	mov    r12,QWORD PTR [rsp+0x18]
    423f:	mov    r13,QWORD PTR [rsp+0x20]
    4244:	mov    r14,QWORD PTR [rsp+0x28]
    4249:	mov    r15,QWORD PTR [rsp+0x30]
    424e:	add    rsp,0x40
    4252:	mov    rsp,rbp
    4255:	pop    rbp
    4256:	ret
    4257:	add    BYTE PTR [rsi],al
    4259:	add    BYTE PTR [rax],al
    425b:	add    BYTE PTR [rax],al
    425d:	add    BYTE PTR [rax],al
	...

0000000000004260 <botlish_entry_43: ht_rehash_probe<mutarray, int, int>>:
    4260:	push   rbp
    4261:	mov    rbp,rsp
    4264:	mov    rsi,QWORD PTR [rdx]
    4267:	mov    r8,QWORD PTR [rdx+0x8]
    426b:	mov    rcx,QWORD PTR [rdx+0x10]
    426f:	mov    rdx,r8
    4272:	call   4277 <botlish_entry_43+0x17>
			4273: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    4277:	mov    rsp,rbp
    427a:	pop    rbp
    427b:	ret

000000000000427c <botlish_fn_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    427c:	push   rbp
    427d:	mov    rbp,rsp
    4280:	sub    rsp,0x50
    4284:	mov    QWORD PTR [rsp+0x20],rbx
    4289:	mov    QWORD PTR [rsp+0x28],r12
    428e:	mov    QWORD PTR [rsp+0x30],r13
    4293:	mov    QWORD PTR [rsp+0x38],r14
    4298:	mov    QWORD PTR [rsp+0x40],r15
    429d:	mov    r10,QWORD PTR [rbp+0x10]
    42a1:	mov    rbx,QWORD PTR [rdi]
    42a4:	mov    rax,QWORD PTR [rdi+0x8]
    42a8:	lea    r11,[rbx+0x38]
    42ac:	cmp    r11,rax
    42af:	ja     446e <botlish_fn_44+0x1f2>
    42b5:	lea    rax,[rbx+0x38]
    42b9:	mov    QWORD PTR [rdi],rax
    42bc:	mov    r12,rdi
    42bf:	mov    QWORD PTR [rbx],0x0
    42c6:	mov    QWORD PTR [rbx+0x8],0x0
    42ce:	mov    QWORD PTR [rbx+0x10],0x0
    42d6:	mov    QWORD PTR [rbx+0x18],0x0
    42de:	mov    QWORD PTR [rbx+0x20],0x0
    42e6:	mov    QWORD PTR [rbx+0x28],0x0
    42ee:	mov    QWORD PTR [rbx+0x30],0x0
    42f6:	mov    QWORD PTR [rbx],rsi
    42f9:	mov    QWORD PTR [rsp],rsi
    42fd:	mov    QWORD PTR [rbx+0x8],rdx
    4301:	mov    QWORD PTR [rsp+0x8],rdx
    4306:	mov    QWORD PTR [rbx+0x10],rcx
    430a:	mov    r13,rcx
    430d:	mov    QWORD PTR [rbx+0x18],r8
    4311:	mov    QWORD PTR [rsp+0x10],r8
    4316:	mov    QWORD PTR [rbx+0x20],r9
    431a:	mov    r15,r9
    431d:	mov    QWORD PTR [rbx+0x28],r10
    4321:	mov    r14,r10
    4324:	mov    rsi,r15
    4327:	mov    rdi,r12
    432a:	call   432f <botlish_fn_44+0xb3>
			432b: R_X86_64_PLT32	rt_hash-0x4
    432f:	test   rax,rax
    4332:	mov    rsi,rax
    4335:	jne    4343 <botlish_fn_44+0xc7>
    433b:	mov    rdi,r12
    433e:	jmp    4416 <botlish_fn_44+0x19a>
    4343:	mov    rdx,QWORD PTR [rsp+0x10]
    4348:	mov    rdi,r12
    434b:	call   4350 <botlish_fn_44+0xd4>
			434c: R_X86_64_PLT32	rt_int_mod-0x4
    4350:	test   rax,rax
    4353:	jne    4361 <botlish_fn_44+0xe5>
    4359:	mov    rdi,r12
    435c:	jmp    4416 <botlish_fn_44+0x19a>
    4361:	mov    QWORD PTR [rbx+0x30],rax
    4365:	mov    rcx,QWORD PTR [rsp+0x10]
    436a:	mov    rdx,rax
    436d:	mov    rsi,QWORD PTR [rsp]
    4371:	mov    rdi,r12
    4374:	call   4379 <botlish_fn_44+0xfd>
			4375: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    4379:	test   rax,rax
    437c:	jne    438a <botlish_fn_44+0x10e>
    4382:	mov    rdi,r12
    4385:	jmp    4416 <botlish_fn_44+0x19a>
    438a:	mov    QWORD PTR [rbx+0x18],rax
    438e:	mov    QWORD PTR [rsp+0x10],rax
    4393:	mov    rdi,r12
    4396:	call   439b <botlish_fn_44+0x11f>
			4397: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    439b:	test   rax,rax
    439e:	mov    rcx,rax
    43a1:	jne    43af <botlish_fn_44+0x133>
    43a7:	mov    rdi,r12
    43aa:	jmp    4416 <botlish_fn_44+0x19a>
    43af:	mov    rsi,QWORD PTR [rsp]
    43b3:	mov    rdx,QWORD PTR [rsp+0x10]
    43b8:	mov    rdi,r12
    43bb:	call   43c0 <botlish_fn_44+0x144>
			43bc: R_X86_64_PLT32	rt_mutarray_set-0x4
    43c0:	test   rax,rax
    43c3:	jne    43d1 <botlish_fn_44+0x155>
    43c9:	mov    rdi,r12
    43cc:	jmp    4416 <botlish_fn_44+0x19a>
    43d1:	mov    rcx,r15
    43d4:	mov    rsi,QWORD PTR [rsp+0x8]
    43d9:	mov    rdx,QWORD PTR [rsp+0x10]
    43de:	mov    rdi,r12
    43e1:	call   43e6 <botlish_fn_44+0x16a>
			43e2: R_X86_64_PLT32	rt_mutarray_set-0x4
    43e6:	test   rax,rax
    43e9:	jne    43f7 <botlish_fn_44+0x17b>
    43ef:	mov    rdi,r12
    43f2:	jmp    4416 <botlish_fn_44+0x19a>
    43f7:	mov    rcx,r14
    43fa:	mov    rdx,QWORD PTR [rsp+0x10]
    43ff:	mov    rsi,r13
    4402:	mov    rdi,r12
    4405:	call   440a <botlish_fn_44+0x18e>
			4406: R_X86_64_PLT32	rt_mutarray_set-0x4
    440a:	test   rax,rax
    440d:	jne    4441 <botlish_fn_44+0x1c5>
    4413:	mov    rdi,r12
    4416:	mov    rdi,r12
    4419:	mov    QWORD PTR [rdi],rbx
    441c:	xor    rax,rax
    441f:	mov    rbx,QWORD PTR [rsp+0x20]
    4424:	mov    r12,QWORD PTR [rsp+0x28]
    4429:	mov    r13,QWORD PTR [rsp+0x30]
    442e:	mov    r14,QWORD PTR [rsp+0x38]
    4433:	mov    r15,QWORD PTR [rsp+0x40]
    4438:	add    rsp,0x50
    443c:	mov    rsp,rbp
    443f:	pop    rbp
    4440:	ret
    4441:	mov    rdi,r12
    4444:	mov    QWORD PTR [rdi],rbx
    4447:	mov    eax,0xa
    444c:	mov    rbx,QWORD PTR [rsp+0x20]
    4451:	mov    r12,QWORD PTR [rsp+0x28]
    4456:	mov    r13,QWORD PTR [rsp+0x30]
    445b:	mov    r14,QWORD PTR [rsp+0x38]
    4460:	mov    r15,QWORD PTR [rsp+0x40]
    4465:	add    rsp,0x50
    4469:	mov    rsp,rbp
    446c:	pop    rbp
    446d:	ret
    446e:	mov    r12,rdi
    4471:	call   4476 <botlish_fn_44+0x1fa>
			4472: R_X86_64_PLT32	rt_stack_overflow-0x4
    4476:	xor    rax,rax
    4479:	mov    rbx,QWORD PTR [rsp+0x20]
    447e:	mov    r12,QWORD PTR [rsp+0x28]
    4483:	mov    r13,QWORD PTR [rsp+0x30]
    4488:	mov    r14,QWORD PTR [rsp+0x38]
    448d:	mov    r15,QWORD PTR [rsp+0x40]
    4492:	add    rsp,0x50
    4496:	mov    rsp,rbp
    4499:	pop    rbp
    449a:	ret

000000000000449b <botlish_entry_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    449b:	push   rbp
    449c:	mov    rbp,rsp
    449f:	sub    rsp,0x10
    44a3:	mov    rsi,QWORD PTR [rdx]
    44a6:	mov    r10,QWORD PTR [rdx+0x8]
    44aa:	mov    rcx,QWORD PTR [rdx+0x10]
    44ae:	mov    r8,QWORD PTR [rdx+0x18]
    44b2:	mov    r9,QWORD PTR [rdx+0x20]
    44b6:	mov    r11,QWORD PTR [rdx+0x28]
    44ba:	mov    QWORD PTR [rsp],r11
    44be:	mov    rdx,r10
    44c1:	call   44c6 <botlish_entry_44+0x2b>
			44c2: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    44c6:	add    rsp,0x10
    44ca:	mov    rsp,rbp
    44cd:	pop    rbp
    44ce:	ret
	...

00000000000044d0 <botlish_fn_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    44d0:	push   rbp
    44d1:	mov    rbp,rsp
    44d4:	sub    rsp,0x80
    44db:	mov    QWORD PTR [rsp+0x50],rbx
    44e0:	mov    QWORD PTR [rsp+0x58],r12
    44e5:	mov    QWORD PTR [rsp+0x60],r13
    44ea:	mov    QWORD PTR [rsp+0x68],r14
    44ef:	mov    QWORD PTR [rsp+0x70],r15
    44f4:	mov    r13,QWORD PTR [rbp+0x10]
    44f8:	mov    r14,QWORD PTR [rbp+0x18]
    44fc:	mov    r12,r14
    44ff:	mov    r15,QWORD PTR [rbp+0x20]
    4503:	mov    r14,QWORD PTR [rbp+0x28]
    4507:	mov    QWORD PTR [rsp+0x38],r14
    450c:	mov    r14,QWORD PTR [rdi]
    450f:	mov    r11,QWORD PTR [rdi+0x8]
    4513:	lea    rax,[r14+0x58]
    4517:	cmp    rax,r11
    451a:	ja     4971 <botlish_fn_45+0x4a1>
    4520:	lea    rax,[r14+0x58]
    4524:	mov    QWORD PTR [rdi],rax
    4527:	mov    QWORD PTR [rsp+0x10],rdi
    452c:	mov    QWORD PTR [r14],0x0
    4533:	mov    QWORD PTR [r14+0x8],0x0
    453b:	mov    QWORD PTR [r14+0x10],0x0
    4543:	mov    QWORD PTR [r14+0x18],0x0
    454b:	mov    QWORD PTR [r14+0x20],0x0
    4553:	mov    QWORD PTR [r14+0x28],0x0
    455b:	mov    QWORD PTR [r14+0x30],0x0
    4563:	mov    QWORD PTR [r14+0x38],0x0
    456b:	mov    QWORD PTR [r14+0x40],0x0
    4573:	mov    QWORD PTR [r14+0x48],0x0
    457b:	mov    QWORD PTR [r14+0x50],0x0
    4583:	mov    QWORD PTR [r14],rsi
    4586:	mov    QWORD PTR [rsp+0x18],rsi
    458b:	mov    QWORD PTR [r14+0x8],rdx
    458f:	mov    QWORD PTR [rsp+0x20],rdx
    4594:	mov    QWORD PTR [r14+0x10],rcx
    4598:	mov    QWORD PTR [rsp+0x28],rcx
    459d:	mov    QWORD PTR [r14+0x18],r8
    45a1:	mov    QWORD PTR [r14+0x20],r9
    45a5:	mov    QWORD PTR [rsp+0x30],r9
    45aa:	mov    QWORD PTR [r14+0x28],r13
    45ae:	mov    r9,r12
    45b1:	mov    QWORD PTR [r14+0x30],r9
    45b5:	mov    QWORD PTR [r14+0x38],r15
    45b9:	mov    rax,QWORD PTR [rsp+0x38]
    45be:	mov    QWORD PTR [r14+0x40],rax
    45c2:	mov    rbx,QWORD PTR [rsp+0x30]
    45c7:	mov    rsi,r8
    45ca:	mov    rax,rsi
    45cd:	and    rax,rbx
    45d0:	mov    QWORD PTR [rsp+0x40],rsi
    45d5:	test   rax,0x1
    45db:	jne    460d <botlish_fn_45+0x13d>
    45e1:	mov    rdx,rbx
    45e4:	mov    rsi,QWORD PTR [rsp+0x40]
    45e9:	mov    rdi,QWORD PTR [rsp+0x10]
    45ee:	call   45f3 <botlish_fn_45+0x123>
			45ef: R_X86_64_PLT32	rt_int_cmp-0x4
    45f3:	mov    QWORD PTR [rsp+0x30],rbx
    45f8:	mov    ecx,0x2
    45fd:	test   rax,rax
    4600:	cmovge rcx,QWORD PTR [rip+0x3a0]        # 49a8 <botlish_fn_45+0x4d8>
    4608:	jmp    462c <botlish_fn_45+0x15c>
    460d:	mov    QWORD PTR [rsp+0x30],rbx
    4612:	mov    ecx,0x2
    4617:	mov    rsi,QWORD PTR [rsp+0x40]
    461c:	mov    r9,QWORD PTR [rsp+0x30]
    4621:	cmp    rsi,r9
    4624:	cmovge rcx,QWORD PTR [rip+0x37c]        # 49a8 <botlish_fn_45+0x4d8>
    462c:	cmp    rcx,0x6
    4630:	je     493f <botlish_fn_45+0x46f>
    4636:	xor    eax,eax
    4638:	mov    rsi,QWORD PTR [rsp+0x18]
    463d:	test   rsi,0x7
    4644:	jne    4653 <botlish_fn_45+0x183>
    464a:	movzx  rax,BYTE PTR [rsi]
    464e:	cmp    al,0x8
    4650:	sete   al
    4653:	test   al,al
    4655:	jne    467c <botlish_fn_45+0x1ac>
    465b:	mov    rdi,QWORD PTR [rsp+0x10]
    4660:	mov    rax,QWORD PTR [rdi+0x10]
    4664:	mov    rcx,QWORD PTR [rax+0x20]
    4668:	mov    edx,0x8
    466d:	call   4672 <botlish_fn_45+0x1a2>
			466e: R_X86_64_PLT32	rt_type_error-0x4
    4672:	mov    rdi,QWORD PTR [rsp+0x10]
    4677:	jmp    4866 <botlish_fn_45+0x396>
    467c:	mov    QWORD PTR [rsp+0x18],rsi
    4681:	mov    rdx,QWORD PTR [rsp+0x40]
    4686:	mov    rdi,QWORD PTR [rsp+0x10]
    468b:	call   4690 <botlish_fn_45+0x1c0>
			468c: R_X86_64_PLT32	rt_mutarray_get-0x4
    4690:	test   rax,rax
    4693:	jne    46a3 <botlish_fn_45+0x1d3>
    4699:	mov    rdi,QWORD PTR [rsp+0x10]
    469e:	jmp    4866 <botlish_fn_45+0x396>
    46a3:	mov    QWORD PTR [r14+0x48],rax
    46a7:	mov    rbx,rax
    46aa:	mov    rdi,QWORD PTR [rsp+0x10]
    46af:	call   46b4 <botlish_fn_45+0x1e4>
			46b0: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    46b4:	test   rax,rax
    46b7:	jne    46c7 <botlish_fn_45+0x1f7>
    46bd:	mov    rdi,QWORD PTR [rsp+0x10]
    46c2:	jmp    4866 <botlish_fn_45+0x396>
    46c7:	mov    rdx,rbx
    46ca:	mov    rcx,rdx
    46cd:	and    rcx,rax
    46d0:	mov    rdx,rax
    46d3:	test   rcx,0x1
    46da:	jne    4700 <botlish_fn_45+0x230>
    46e0:	mov    rsi,rbx
    46e3:	mov    rdi,QWORD PTR [rsp+0x10]
    46e8:	call   46ed <botlish_fn_45+0x21d>
			46e9: R_X86_64_PLT32	rt_value_eq-0x4
    46ed:	test   rax,rax
    46f0:	jne    4713 <botlish_fn_45+0x243>
    46f6:	mov    rdi,QWORD PTR [rsp+0x10]
    46fb:	jmp    4866 <botlish_fn_45+0x396>
    4700:	mov    rsi,rbx
    4703:	mov    eax,0x2
    4708:	cmp    rsi,rdx
    470b:	cmove  rax,QWORD PTR [rip+0x295]        # 49a8 <botlish_fn_45+0x4d8>
    4713:	cmp    rax,0x6
    4717:	je     4727 <botlish_fn_45+0x257>
    471d:	mov    rbx,QWORD PTR [rsp+0x38]
    4722:	jmp    4896 <botlish_fn_45+0x3c6>
    4727:	xor    eax,eax
    4729:	mov    rdx,QWORD PTR [rsp+0x20]
    472e:	test   rdx,0x7
    4735:	je     4745 <botlish_fn_45+0x275>
    473b:	mov    QWORD PTR [rsp+0x20],rdx
    4740:	jmp    4755 <botlish_fn_45+0x285>
    4745:	movzx  r10,BYTE PTR [rdx]
    4749:	mov    QWORD PTR [rsp+0x20],rdx
    474e:	cmp    r10b,0x8
    4752:	sete   al
    4755:	test   al,al
    4757:	jne    4783 <botlish_fn_45+0x2b3>
    475d:	mov    rdi,QWORD PTR [rsp+0x10]
    4762:	mov    rax,QWORD PTR [rdi+0x10]
    4766:	mov    rcx,QWORD PTR [rax+0x20]
    476a:	mov    edx,0x8
    476f:	mov    rsi,QWORD PTR [rsp+0x20]
    4774:	call   4779 <botlish_fn_45+0x2a9>
			4775: R_X86_64_PLT32	rt_type_error-0x4
    4779:	mov    rdi,QWORD PTR [rsp+0x10]
    477e:	jmp    4866 <botlish_fn_45+0x396>
    4783:	mov    rdx,QWORD PTR [rsp+0x40]
    4788:	mov    rsi,QWORD PTR [rsp+0x20]
    478d:	mov    rdi,QWORD PTR [rsp+0x10]
    4792:	call   4797 <botlish_fn_45+0x2c7>
			4793: R_X86_64_PLT32	rt_mutarray_get-0x4
    4797:	test   rax,rax
    479a:	jne    47aa <botlish_fn_45+0x2da>
    47a0:	mov    rdi,QWORD PTR [rsp+0x10]
    47a5:	jmp    4866 <botlish_fn_45+0x396>
    47aa:	mov    QWORD PTR [r14+0x48],rax
    47ae:	mov    rbx,rax
    47b1:	xor    eax,eax
    47b3:	mov    rcx,QWORD PTR [rsp+0x28]
    47b8:	test   rcx,0x7
    47bf:	je     47cf <botlish_fn_45+0x2ff>
    47c5:	mov    QWORD PTR [rsp+0x28],rcx
    47ca:	jmp    47dd <botlish_fn_45+0x30d>
    47cf:	movzx  rax,BYTE PTR [rcx]
    47d3:	mov    QWORD PTR [rsp+0x28],rcx
    47d8:	cmp    al,0x8
    47da:	sete   al
    47dd:	test   al,al
    47df:	jne    480b <botlish_fn_45+0x33b>
    47e5:	mov    rdi,QWORD PTR [rsp+0x10]
    47ea:	mov    rax,QWORD PTR [rdi+0x10]
    47ee:	mov    rcx,QWORD PTR [rax+0x20]
    47f2:	mov    edx,0x8
    47f7:	mov    rsi,QWORD PTR [rsp+0x28]
    47fc:	call   4801 <botlish_fn_45+0x331>
			47fd: R_X86_64_PLT32	rt_type_error-0x4
    4801:	mov    rdi,QWORD PTR [rsp+0x10]
    4806:	jmp    4866 <botlish_fn_45+0x396>
    480b:	mov    rdx,QWORD PTR [rsp+0x40]
    4810:	mov    rsi,QWORD PTR [rsp+0x28]
    4815:	mov    rdi,QWORD PTR [rsp+0x10]
    481a:	call   481f <botlish_fn_45+0x34f>
			481b: R_X86_64_PLT32	rt_mutarray_get-0x4
    481f:	test   rax,rax
    4822:	jne    4832 <botlish_fn_45+0x362>
    4828:	mov    rdi,QWORD PTR [rsp+0x10]
    482d:	jmp    4866 <botlish_fn_45+0x396>
    4832:	mov    QWORD PTR [r14+0x50],rax
    4836:	mov    QWORD PTR [rsp],rax
    483a:	mov    r9,rbx
    483d:	mov    rbx,QWORD PTR [rsp+0x38]
    4842:	mov    rcx,r15
    4845:	mov    rdx,r12
    4848:	mov    rsi,r13
    484b:	mov    rdi,QWORD PTR [rsp+0x10]
    4850:	mov    r8,rbx
    4853:	call   4858 <botlish_fn_45+0x388>
			4854: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    4858:	test   rax,rax
    485b:	jne    4896 <botlish_fn_45+0x3c6>
    4861:	mov    rdi,QWORD PTR [rsp+0x10]
    4866:	mov    rdi,QWORD PTR [rsp+0x10]
    486b:	mov    QWORD PTR [rdi],r14
    486e:	xor    rax,rax
    4871:	mov    rbx,QWORD PTR [rsp+0x50]
    4876:	mov    r12,QWORD PTR [rsp+0x58]
    487b:	mov    r13,QWORD PTR [rsp+0x60]
    4880:	mov    r14,QWORD PTR [rsp+0x68]
    4885:	mov    r15,QWORD PTR [rsp+0x70]
    488a:	add    rsp,0x80
    4891:	mov    rsp,rbp
    4894:	pop    rbp
    4895:	ret
    4896:	mov    QWORD PTR [r14+0x48],0x3
    489e:	mov    rsi,QWORD PTR [rsp+0x40]
    48a3:	test   rsi,0x1
    48aa:	je     48d6 <botlish_fn_45+0x406>
    48b0:	mov    rsi,QWORD PTR [rsp+0x40]
    48b5:	mov    rcx,rsi
    48b8:	add    rcx,0x2
    48bc:	seto   al
    48bf:	test   al,al
    48c1:	jne    48d6 <botlish_fn_45+0x406>
    48c7:	mov    QWORD PTR [rsp+0x40],rcx
    48cc:	mov    rcx,QWORD PTR [rsp+0x18]
    48d1:	jmp    48f4 <botlish_fn_45+0x424>
    48d6:	mov    edx,0x3
    48db:	mov    rsi,QWORD PTR [rsp+0x40]
    48e0:	mov    rdi,QWORD PTR [rsp+0x10]
    48e5:	call   48ea <botlish_fn_45+0x41a>
			48e6: R_X86_64_PLT32	rt_int_add-0x4
    48ea:	mov    rcx,QWORD PTR [rsp+0x18]
    48ef:	mov    QWORD PTR [rsp+0x40],rax
    48f4:	mov    rcx,QWORD PTR [rsp+0x18]
    48f9:	mov    QWORD PTR [r14],rcx
    48fc:	mov    rsi,QWORD PTR [rsp+0x20]
    4901:	mov    QWORD PTR [r14+0x8],rsi
    4905:	mov    rsi,QWORD PTR [rsp+0x28]
    490a:	mov    QWORD PTR [r14+0x10],rsi
    490e:	mov    rsi,QWORD PTR [rsp+0x40]
    4913:	mov    QWORD PTR [r14+0x18],rsi
    4917:	mov    r9,QWORD PTR [rsp+0x30]
    491c:	mov    QWORD PTR [r14+0x20],r9
    4920:	mov    QWORD PTR [r14+0x28],r13
    4924:	mov    QWORD PTR [r14+0x30],r12
    4928:	mov    QWORD PTR [r14+0x38],r15
    492c:	mov    QWORD PTR [r14+0x40],rbx
    4930:	mov    QWORD PTR [rsp+0x38],rbx
    4935:	mov    rbx,QWORD PTR [rsp+0x30]
    493a:	jmp    45ca <botlish_fn_45+0xfa>
    493f:	mov    rdi,QWORD PTR [rsp+0x10]
    4944:	mov    QWORD PTR [rdi],r14
    4947:	mov    eax,0xa
    494c:	mov    rbx,QWORD PTR [rsp+0x50]
    4951:	mov    r12,QWORD PTR [rsp+0x58]
    4956:	mov    r13,QWORD PTR [rsp+0x60]
    495b:	mov    r14,QWORD PTR [rsp+0x68]
    4960:	mov    r15,QWORD PTR [rsp+0x70]
    4965:	add    rsp,0x80
    496c:	mov    rsp,rbp
    496f:	pop    rbp
    4970:	ret
    4971:	mov    QWORD PTR [rsp+0x10],rdi
    4976:	call   497b <botlish_fn_45+0x4ab>
			4977: R_X86_64_PLT32	rt_stack_overflow-0x4
    497b:	xor    rax,rax
    497e:	mov    rbx,QWORD PTR [rsp+0x50]
    4983:	mov    r12,QWORD PTR [rsp+0x58]
    4988:	mov    r13,QWORD PTR [rsp+0x60]
    498d:	mov    r14,QWORD PTR [rsp+0x68]
    4992:	mov    r15,QWORD PTR [rsp+0x70]
    4997:	add    rsp,0x80
    499e:	mov    rsp,rbp
    49a1:	pop    rbp
    49a2:	ret
    49a3:	add    BYTE PTR [rax],al
    49a5:	add    BYTE PTR [rax],al
    49a7:	add    BYTE PTR [rsi],al
    49a9:	add    BYTE PTR [rax],al
    49ab:	add    BYTE PTR [rax],al
    49ad:	add    BYTE PTR [rax],al
	...

00000000000049b0 <botlish_entry_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    49b0:	push   rbp
    49b1:	mov    rbp,rsp
    49b4:	sub    rsp,0x30
    49b8:	mov    QWORD PTR [rsp+0x20],r12
    49bd:	mov    rsi,QWORD PTR [rdx]
    49c0:	mov    rax,QWORD PTR [rdx+0x8]
    49c4:	mov    rcx,QWORD PTR [rdx+0x10]
    49c8:	mov    r8,QWORD PTR [rdx+0x18]
    49cc:	mov    r9,QWORD PTR [rdx+0x20]
    49d0:	mov    r10,QWORD PTR [rdx+0x28]
    49d4:	mov    r11,QWORD PTR [rdx+0x30]
    49d8:	mov    r12,QWORD PTR [rdx+0x38]
    49dc:	mov    rdx,QWORD PTR [rdx+0x40]
    49e0:	mov    QWORD PTR [rsp],r10
    49e4:	mov    QWORD PTR [rsp+0x8],r11
    49e9:	mov    QWORD PTR [rsp+0x10],r12
    49ee:	mov    QWORD PTR [rsp+0x18],rdx
    49f3:	mov    rdx,rax
    49f6:	call   49fb <botlish_entry_45+0x4b>
			49f7: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    49fb:	mov    r12,QWORD PTR [rsp+0x20]
    4a00:	add    rsp,0x30
    4a04:	mov    rsp,rbp
    4a07:	pop    rbp
    4a08:	ret

0000000000004a09 <botlish_fn_46: ht_rehash<mutarray, int>>:
    4a09:	push   rbp
    4a0a:	mov    rbp,rsp
    4a0d:	sub    rsp,0x80
    4a14:	mov    QWORD PTR [rsp+0x50],rbx
    4a19:	mov    QWORD PTR [rsp+0x58],r12
    4a1e:	mov    QWORD PTR [rsp+0x60],r13
    4a23:	mov    QWORD PTR [rsp+0x68],r14
    4a28:	mov    QWORD PTR [rsp+0x70],r15
    4a2d:	mov    r12,QWORD PTR [rdi]
    4a30:	mov    rax,QWORD PTR [rdi+0x8]
    4a34:	lea    rcx,[r12+0x50]
    4a39:	cmp    rcx,rax
    4a3c:	ja     4d3c <botlish_fn_46+0x333>
    4a42:	lea    rax,[r12+0x50]
    4a47:	mov    QWORD PTR [rdi],rax
    4a4a:	mov    r13,rdi
    4a4d:	mov    QWORD PTR [r12],0x0
    4a55:	mov    QWORD PTR [r12+0x8],0x0
    4a5e:	mov    QWORD PTR [r12+0x10],0x0
    4a67:	mov    QWORD PTR [r12+0x18],0x0
    4a70:	mov    QWORD PTR [r12+0x20],0x0
    4a79:	mov    QWORD PTR [r12+0x28],0x0
    4a82:	mov    QWORD PTR [r12+0x30],0x0
    4a8b:	mov    QWORD PTR [r12+0x38],0x0
    4a94:	mov    QWORD PTR [r12+0x40],0x0
    4a9d:	mov    QWORD PTR [r12+0x48],0x0
    4aa6:	mov    QWORD PTR [r12],rsi
    4aaa:	mov    r14,rsi
    4aad:	mov    QWORD PTR [r12+0x8],rdx
    4ab2:	mov    rbx,rdx
    4ab5:	mov    rsi,r14
    4ab8:	mov    rdi,r13
    4abb:	call   4ac0 <botlish_fn_46+0xb7>
			4abc: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    4ac0:	test   rax,rax
    4ac3:	jne    4ad1 <botlish_fn_46+0xc8>
    4ac9:	mov    rdi,r13
    4acc:	jmp    4cde <botlish_fn_46+0x2d5>
    4ad1:	mov    QWORD PTR [r12+0x10],rax
    4ad6:	mov    r15,rax
    4ad9:	mov    rsi,r14
    4adc:	mov    rdi,r13
    4adf:	call   4ae4 <botlish_fn_46+0xdb>
			4ae0: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    4ae4:	test   rax,rax
    4ae7:	jne    4af5 <botlish_fn_46+0xec>
    4aed:	mov    rdi,r13
    4af0:	jmp    4cde <botlish_fn_46+0x2d5>
    4af5:	mov    QWORD PTR [r12+0x18],rax
    4afa:	mov    QWORD PTR [rsp+0x48],rax
    4aff:	mov    rsi,r14
    4b02:	mov    rdi,r13
    4b05:	call   4b0a <botlish_fn_46+0x101>
			4b06: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    4b0a:	test   rax,rax
    4b0d:	jne    4b1b <botlish_fn_46+0x112>
    4b13:	mov    rdi,r13
    4b16:	jmp    4cde <botlish_fn_46+0x2d5>
    4b1b:	mov    QWORD PTR [r12+0x20],rax
    4b20:	mov    QWORD PTR [rsp+0x40],rax
    4b25:	mov    rsi,r14
    4b28:	mov    rdi,r13
    4b2b:	call   4b30 <botlish_fn_46+0x127>
			4b2c: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4b30:	test   rax,rax
    4b33:	jne    4b41 <botlish_fn_46+0x138>
    4b39:	mov    rdi,r13
    4b3c:	jmp    4cde <botlish_fn_46+0x2d5>
    4b41:	mov    QWORD PTR [r12+0x28],rax
    4b46:	mov    QWORD PTR [rsp+0x38],rax
    4b4b:	mov    rsi,rbx
    4b4e:	mov    rdi,r13
    4b51:	call   4b56 <botlish_fn_46+0x14d>
			4b52: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    4b56:	mov    rcx,rax
    4b59:	mov    QWORD PTR [rsp+0x30],rax
    4b5e:	test   rax,rcx
    4b61:	jne    4b6f <botlish_fn_46+0x166>
    4b67:	mov    rdi,r13
    4b6a:	jmp    4cde <botlish_fn_46+0x2d5>
    4b6f:	mov    rax,QWORD PTR [rsp+0x30]
    4b74:	mov    QWORD PTR [r12+0x30],rax
    4b79:	mov    edx,0x1
    4b7e:	mov    QWORD PTR [r12+0x38],0x1
    4b87:	mov    rcx,rbx
    4b8a:	mov    rsi,QWORD PTR [rsp+0x30]
    4b8f:	mov    rdi,r13
    4b92:	call   4b97 <botlish_fn_46+0x18e>
			4b93: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    4b97:	test   rax,rax
    4b9a:	jne    4ba8 <botlish_fn_46+0x19f>
    4ba0:	mov    rdi,r13
    4ba3:	jmp    4cde <botlish_fn_46+0x2d5>
    4ba8:	mov    rsi,rbx
    4bab:	mov    rdi,r13
    4bae:	call   4bb3 <botlish_fn_46+0x1aa>
			4baf: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    4bb3:	test   rax,rax
    4bb6:	jne    4bc4 <botlish_fn_46+0x1bb>
    4bbc:	mov    rdi,r13
    4bbf:	jmp    4cde <botlish_fn_46+0x2d5>
    4bc4:	mov    QWORD PTR [r12+0x38],rax
    4bc9:	mov    QWORD PTR [rsp+0x28],rax
    4bce:	mov    rsi,rbx
    4bd1:	mov    rdi,r13
    4bd4:	call   4bd9 <botlish_fn_46+0x1d0>
			4bd5: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    4bd9:	test   rax,rax
    4bdc:	jne    4bea <botlish_fn_46+0x1e1>
    4be2:	mov    rdi,r13
    4be5:	jmp    4cde <botlish_fn_46+0x2d5>
    4bea:	mov    QWORD PTR [r12+0x40],rax
    4bef:	mov    r8d,0x1
    4bf5:	mov    QWORD PTR [r12+0x48],0x1
    4bfe:	mov    rcx,QWORD PTR [rsp+0x30]
    4c03:	mov    QWORD PTR [rsp],rcx
    4c07:	mov    rcx,QWORD PTR [rsp+0x28]
    4c0c:	mov    QWORD PTR [rsp+0x8],rcx
    4c11:	mov    QWORD PTR [rsp+0x10],rax
    4c16:	mov    QWORD PTR [rsp+0x20],rax
    4c1b:	mov    QWORD PTR [rsp+0x18],rbx
    4c20:	mov    rcx,QWORD PTR [rsp+0x40]
    4c25:	mov    rdx,QWORD PTR [rsp+0x48]
    4c2a:	mov    rsi,r15
    4c2d:	mov    r9,QWORD PTR [rsp+0x38]
    4c32:	mov    rdi,r13
    4c35:	call   4c3a <botlish_fn_46+0x231>
			4c36: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    4c3a:	test   rax,rax
    4c3d:	jne    4c4b <botlish_fn_46+0x242>
    4c43:	mov    rdi,r13
    4c46:	jmp    4cde <botlish_fn_46+0x2d5>
    4c4b:	mov    edx,0x1
    4c50:	mov    rcx,QWORD PTR [rsp+0x30]
    4c55:	mov    rsi,r14
    4c58:	mov    rdi,r13
    4c5b:	call   4c60 <botlish_fn_46+0x257>
			4c5c: R_X86_64_PLT32	rt_mutarray_set-0x4
    4c60:	test   rax,rax
    4c63:	jne    4c71 <botlish_fn_46+0x268>
    4c69:	mov    rdi,r13
    4c6c:	jmp    4cde <botlish_fn_46+0x2d5>
    4c71:	mov    edx,0x3
    4c76:	mov    rcx,QWORD PTR [rsp+0x28]
    4c7b:	mov    rsi,r14
    4c7e:	mov    rdi,r13
    4c81:	call   4c86 <botlish_fn_46+0x27d>
			4c82: R_X86_64_PLT32	rt_mutarray_set-0x4
    4c86:	test   rax,rax
    4c89:	jne    4c97 <botlish_fn_46+0x28e>
    4c8f:	mov    rdi,r13
    4c92:	jmp    4cde <botlish_fn_46+0x2d5>
    4c97:	mov    edx,0x5
    4c9c:	mov    rcx,QWORD PTR [rsp+0x20]
    4ca1:	mov    rsi,r14
    4ca4:	mov    rdi,r13
    4ca7:	call   4cac <botlish_fn_46+0x2a3>
			4ca8: R_X86_64_PLT32	rt_mutarray_set-0x4
    4cac:	test   rax,rax
    4caf:	jne    4cbd <botlish_fn_46+0x2b4>
    4cb5:	mov    rdi,r13
    4cb8:	jmp    4cde <botlish_fn_46+0x2d5>
    4cbd:	mov    edx,0x9
    4cc2:	mov    ecx,0x1
    4cc7:	mov    rsi,r14
    4cca:	mov    rdi,r13
    4ccd:	call   4cd2 <botlish_fn_46+0x2c9>
			4cce: R_X86_64_PLT32	rt_mutarray_set-0x4
    4cd2:	test   rax,rax
    4cd5:	jne    4d0c <botlish_fn_46+0x303>
    4cdb:	mov    rdi,r13
    4cde:	mov    rdi,r13
    4ce1:	mov    QWORD PTR [rdi],r12
    4ce4:	xor    rax,rax
    4ce7:	mov    rbx,QWORD PTR [rsp+0x50]
    4cec:	mov    r12,QWORD PTR [rsp+0x58]
    4cf1:	mov    r13,QWORD PTR [rsp+0x60]
    4cf6:	mov    r14,QWORD PTR [rsp+0x68]
    4cfb:	mov    r15,QWORD PTR [rsp+0x70]
    4d00:	add    rsp,0x80
    4d07:	mov    rsp,rbp
    4d0a:	pop    rbp
    4d0b:	ret
    4d0c:	mov    rdi,r13
    4d0f:	mov    QWORD PTR [rdi],r12
    4d12:	mov    eax,0xa
    4d17:	mov    rbx,QWORD PTR [rsp+0x50]
    4d1c:	mov    r12,QWORD PTR [rsp+0x58]
    4d21:	mov    r13,QWORD PTR [rsp+0x60]
    4d26:	mov    r14,QWORD PTR [rsp+0x68]
    4d2b:	mov    r15,QWORD PTR [rsp+0x70]
    4d30:	add    rsp,0x80
    4d37:	mov    rsp,rbp
    4d3a:	pop    rbp
    4d3b:	ret
    4d3c:	mov    r13,rdi
    4d3f:	call   4d44 <botlish_fn_46+0x33b>
			4d40: R_X86_64_PLT32	rt_stack_overflow-0x4
    4d44:	xor    rax,rax
    4d47:	mov    rbx,QWORD PTR [rsp+0x50]
    4d4c:	mov    r12,QWORD PTR [rsp+0x58]
    4d51:	mov    r13,QWORD PTR [rsp+0x60]
    4d56:	mov    r14,QWORD PTR [rsp+0x68]
    4d5b:	mov    r15,QWORD PTR [rsp+0x70]
    4d60:	add    rsp,0x80
    4d67:	mov    rsp,rbp
    4d6a:	pop    rbp
    4d6b:	ret

0000000000004d6c <botlish_entry_46: ht_rehash<mutarray, int>>:
    4d6c:	push   rbp
    4d6d:	mov    rbp,rsp
    4d70:	mov    rsi,QWORD PTR [rdx]
    4d73:	mov    rdx,QWORD PTR [rdx+0x8]
    4d77:	call   4d7c <botlish_entry_46+0x10>
			4d78: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    4d7c:	mov    rsp,rbp
    4d7f:	pop    rbp
    4d80:	ret
    4d81:	add    BYTE PTR [rax],al
    4d83:	add    BYTE PTR [rax],al
    4d85:	add    BYTE PTR [rax],al
	...

0000000000004d88 <botlish_fn_47: ht_should_grow<mutarray>>:
    4d88:	push   rbp
    4d89:	mov    rbp,rsp
    4d8c:	sub    rsp,0x20
    4d90:	mov    QWORD PTR [rsp],rbx
    4d94:	mov    QWORD PTR [rsp+0x8],r12
    4d99:	mov    QWORD PTR [rsp+0x10],r13
    4d9e:	mov    QWORD PTR [rsp+0x18],r14
    4da3:	mov    r12,QWORD PTR [rdi]
    4da6:	mov    r8,QWORD PTR [rdi+0x8]
    4daa:	lea    r9,[r12+0x18]
    4daf:	cmp    r9,r8
    4db2:	ja     50eb <botlish_fn_47+0x363>
    4db8:	lea    r9,[r12+0x18]
    4dbd:	mov    QWORD PTR [rdi],r9
    4dc0:	mov    r13,rdi
    4dc3:	mov    QWORD PTR [r12],0x0
    4dcb:	mov    QWORD PTR [r12+0x8],0x0
    4dd4:	mov    QWORD PTR [r12+0x10],0x0
    4ddd:	mov    QWORD PTR [r12],rsi
    4de1:	mov    rbx,rsi
    4de4:	mov    rsi,rbx
    4de7:	mov    rdi,r13
    4dea:	call   4def <botlish_fn_47+0x67>
			4deb: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    4def:	mov    rcx,rax
    4df2:	mov    r14,rax
    4df5:	test   rax,rcx
    4df8:	jne    4e06 <botlish_fn_47+0x7e>
    4dfe:	mov    rdi,r13
    4e01:	jmp    5003 <botlish_fn_47+0x27b>
    4e06:	mov    rax,r14
    4e09:	mov    QWORD PTR [r12+0x8],rax
    4e0e:	mov    rsi,rbx
    4e11:	mov    rdi,r13
    4e14:	call   4e19 <botlish_fn_47+0x91>
			4e15: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    4e19:	mov    rcx,rax
    4e1c:	test   rcx,rcx
    4e1f:	jne    4e2d <botlish_fn_47+0xa5>
    4e25:	mov    rdi,r13
    4e28:	jmp    5003 <botlish_fn_47+0x27b>
    4e2d:	mov    QWORD PTR [r12+0x10],rcx
    4e32:	mov    edx,0x1
    4e37:	mov    rax,r14
    4e3a:	test   rax,0x1
    4e40:	jne    4e63 <botlish_fn_47+0xdb>
    4e46:	xor    edx,edx
    4e48:	mov    rax,r14
    4e4b:	test   rax,0x7
    4e51:	jne    4e63 <botlish_fn_47+0xdb>
    4e57:	mov    rax,r14
    4e5a:	movzx  rax,BYTE PTR [rax]
    4e5e:	cmp    al,0x1
    4e60:	sete   dl
    4e63:	test   dl,dl
    4e65:	jne    4e89 <botlish_fn_47+0x101>
    4e6b:	mov    rdi,r13
    4e6e:	mov    rax,QWORD PTR [rdi+0x10]
    4e72:	mov    rcx,QWORD PTR [rax+0x30]
    4e76:	xor    rdx,rdx
    4e79:	mov    rsi,r14
    4e7c:	call   4e81 <botlish_fn_47+0xf9>
			4e7d: R_X86_64_PLT32	rt_type_error-0x4
    4e81:	mov    rdi,r13
    4e84:	jmp    5003 <botlish_fn_47+0x27b>
    4e89:	mov    eax,0x1
    4e8e:	test   rcx,0x1
    4e95:	je     4ea3 <botlish_fn_47+0x11b>
    4e9b:	mov    r8,rcx
    4e9e:	jmp    4ec6 <botlish_fn_47+0x13e>
    4ea3:	xor    eax,eax
    4ea5:	test   rcx,0x7
    4eac:	je     4eba <botlish_fn_47+0x132>
    4eb2:	mov    r8,rcx
    4eb5:	jmp    4ec6 <botlish_fn_47+0x13e>
    4eba:	movzx  rax,BYTE PTR [rcx]
    4ebe:	mov    r8,rcx
    4ec1:	cmp    al,0x1
    4ec3:	sete   al
    4ec6:	test   al,al
    4ec8:	jne    4eec <botlish_fn_47+0x164>
    4ece:	mov    rdi,r13
    4ed1:	mov    rax,QWORD PTR [rdi+0x10]
    4ed5:	mov    rcx,QWORD PTR [rax+0x30]
    4ed9:	xor    rdx,rdx
    4edc:	mov    rsi,r8
    4edf:	call   4ee4 <botlish_fn_47+0x15c>
			4ee0: R_X86_64_PLT32	rt_type_error-0x4
    4ee4:	mov    rdi,r13
    4ee7:	jmp    5003 <botlish_fn_47+0x27b>
    4eec:	mov    rcx,r8
    4eef:	mov    rsi,r14
    4ef2:	mov    rax,rsi
    4ef5:	and    rax,rcx
    4ef8:	test   rax,0x1
    4efe:	jne    4f0f <botlish_fn_47+0x187>
    4f04:	mov    rdx,r8
    4f07:	mov    rsi,r14
    4f0a:	jmp    4f2d <botlish_fn_47+0x1a5>
    4f0f:	mov    rcx,r8
    4f12:	lea    rax,[rcx-0x1]
    4f16:	mov    rsi,r14
    4f19:	add    rsi,rax
    4f1c:	seto   al
    4f1f:	test   al,al
    4f21:	je     4f38 <botlish_fn_47+0x1b0>
    4f27:	mov    rdx,r8
    4f2a:	mov    rsi,r14
    4f2d:	mov    rdi,r13
    4f30:	call   4f35 <botlish_fn_47+0x1ad>
			4f31: R_X86_64_PLT32	rt_int_add-0x4
    4f35:	mov    rsi,rax
    4f38:	mov    QWORD PTR [r12+0x8],rsi
    4f3d:	mov    QWORD PTR [r12+0x10],0x3
    4f46:	test   rsi,0x1
    4f4d:	je     4f70 <botlish_fn_47+0x1e8>
    4f53:	mov    rax,rsi
    4f56:	add    rax,0x2
    4f5a:	mov    rcx,rax
    4f5d:	seto   al
    4f60:	test   al,al
    4f62:	jne    4f70 <botlish_fn_47+0x1e8>
    4f68:	mov    rsi,rcx
    4f6b:	jmp    4f80 <botlish_fn_47+0x1f8>
    4f70:	mov    edx,0x3
    4f75:	mov    rdi,r13
    4f78:	call   4f7d <botlish_fn_47+0x1f5>
			4f79: R_X86_64_PLT32	rt_int_add-0x4
    4f7d:	mov    rsi,rax
    4f80:	mov    QWORD PTR [r12+0x8],rsi
    4f85:	mov    edx,0x7
    4f8a:	mov    rcx,rdx
    4f8d:	mov    QWORD PTR [r12+0x10],0x7
    4f96:	test   rsi,0x1
    4f9d:	jne    4fab <botlish_fn_47+0x223>
    4fa3:	mov    rdx,rcx
    4fa6:	jmp    4fd9 <botlish_fn_47+0x251>
    4fab:	mov    rax,rsi
    4fae:	sar    rax,1
    4fb1:	imul   QWORD PTR [rip+0x160]        # 5118 <botlish_fn_47+0x390>
    4fb8:	seto   dil
    4fbc:	or     rax,0x1
    4fc0:	test   dil,dil
    4fc3:	je     4fd1 <botlish_fn_47+0x249>
    4fc9:	mov    rdx,rcx
    4fcc:	jmp    4fd9 <botlish_fn_47+0x251>
    4fd1:	mov    rsi,rax
    4fd4:	jmp    4fe4 <botlish_fn_47+0x25c>
    4fd9:	mov    rdi,r13
    4fdc:	call   4fe1 <botlish_fn_47+0x259>
			4fdd: R_X86_64_PLT32	rt_int_mul-0x4
    4fe1:	mov    rsi,rax
    4fe4:	mov    QWORD PTR [r12+0x8],rsi
    4fe9:	mov    r14,rsi
    4fec:	mov    rsi,rbx
    4fef:	mov    rdi,r13
    4ff2:	call   4ff7 <botlish_fn_47+0x26f>
			4ff3: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4ff7:	test   rax,rax
    4ffa:	jne    5028 <botlish_fn_47+0x2a0>
    5000:	mov    rdi,r13
    5003:	mov    rdi,r13
    5006:	mov    QWORD PTR [rdi],r12
    5009:	xor    rax,rax
    500c:	mov    rbx,QWORD PTR [rsp]
    5010:	mov    r12,QWORD PTR [rsp+0x8]
    5015:	mov    r13,QWORD PTR [rsp+0x10]
    501a:	mov    r14,QWORD PTR [rsp+0x18]
    501f:	add    rsp,0x20
    5023:	mov    rsp,rbp
    5026:	pop    rbp
    5027:	ret
    5028:	mov    QWORD PTR [r12],rax
    502c:	mov    QWORD PTR [r12+0x10],0x5
    5035:	test   rax,0x1
    503b:	mov    rsi,rax
    503e:	je     506e <botlish_fn_47+0x2e6>
    5044:	mov    rcx,rsi
    5047:	mov    rax,rcx
    504a:	sar    rax,1
    504d:	imul   QWORD PTR [rip+0xcc]        # 5120 <botlish_fn_47+0x398>
    5054:	seto   cl
    5057:	or     rax,0x1
    505b:	test   cl,cl
    505d:	jne    506e <botlish_fn_47+0x2e6>
    5063:	mov    rdx,rax
    5066:	mov    rsi,r14
    5069:	jmp    5081 <botlish_fn_47+0x2f9>
    506e:	mov    edx,0x5
    5073:	mov    rdi,r13
    5076:	call   507b <botlish_fn_47+0x2f3>
			5077: R_X86_64_PLT32	rt_int_mul-0x4
    507b:	mov    rdx,rax
    507e:	mov    rsi,r14
    5081:	mov    rax,rsi
    5084:	and    rax,rdx
    5087:	test   rax,0x1
    508d:	jne    50b6 <botlish_fn_47+0x32e>
    5093:	mov    rdi,r13
    5096:	call   509b <botlish_fn_47+0x313>
			5097: R_X86_64_PLT32	rt_int_cmp-0x4
    509b:	mov    ecx,0x2
    50a0:	test   rax,rax
    50a3:	mov    rax,rcx
    50a6:	cmovg  rax,QWORD PTR [rip+0x6a]        # 5118 <botlish_fn_47+0x390>
    50ae:	mov    rdi,r13
    50b1:	jmp    50c9 <botlish_fn_47+0x341>
    50b6:	mov    eax,0x2
    50bb:	cmp    rsi,rdx
    50be:	cmovg  rax,QWORD PTR [rip+0x52]        # 5118 <botlish_fn_47+0x390>
    50c6:	mov    rdi,r13
    50c9:	mov    rdi,r13
    50cc:	mov    QWORD PTR [rdi],r12
    50cf:	mov    rbx,QWORD PTR [rsp]
    50d3:	mov    r12,QWORD PTR [rsp+0x8]
    50d8:	mov    r13,QWORD PTR [rsp+0x10]
    50dd:	mov    r14,QWORD PTR [rsp+0x18]
    50e2:	add    rsp,0x20
    50e6:	mov    rsp,rbp
    50e9:	pop    rbp
    50ea:	ret
    50eb:	mov    r13,rdi
    50ee:	call   50f3 <botlish_fn_47+0x36b>
			50ef: R_X86_64_PLT32	rt_stack_overflow-0x4
    50f3:	xor    rax,rax
    50f6:	mov    rbx,QWORD PTR [rsp]
    50fa:	mov    r12,QWORD PTR [rsp+0x8]
    50ff:	mov    r13,QWORD PTR [rsp+0x10]
    5104:	mov    r14,QWORD PTR [rsp+0x18]
    5109:	add    rsp,0x20
    510d:	mov    rsp,rbp
    5110:	pop    rbp
    5111:	ret
    5112:	add    BYTE PTR [rax],al
    5114:	add    BYTE PTR [rax],al
    5116:	add    BYTE PTR [rax],al
    5118:	(bad)
    5119:	add    BYTE PTR [rax],al
    511b:	add    BYTE PTR [rax],al
    511d:	add    BYTE PTR [rax],al
    511f:	add    BYTE PTR [rax+rax*1],al
    5122:	add    BYTE PTR [rax],al
    5124:	add    BYTE PTR [rax],al
	...

0000000000005128 <botlish_entry_47: ht_should_grow<mutarray>>:
    5128:	push   rbp
    5129:	mov    rbp,rsp
    512c:	mov    rsi,QWORD PTR [rdx]
    512f:	call   5134 <botlish_entry_47+0xc>
			5130: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    5134:	mov    rsp,rbp
    5137:	pop    rbp
    5138:	ret
    5139:	add    BYTE PTR [rax],al
    513b:	add    BYTE PTR [rax],al
    513d:	add    BYTE PTR [rax],al
	...

0000000000005140 <botlish_fn_48: ht_grow_or_clean<mutarray>>:
    5140:	push   rbp
    5141:	mov    rbp,rsp
    5144:	sub    rsp,0x20
    5148:	mov    QWORD PTR [rsp],rbx
    514c:	mov    QWORD PTR [rsp+0x8],r12
    5151:	mov    QWORD PTR [rsp+0x10],r13
    5156:	mov    QWORD PTR [rsp+0x18],r14
    515b:	mov    rbx,QWORD PTR [rdi]
    515e:	mov    rax,QWORD PTR [rdi+0x8]
    5162:	lea    rcx,[rbx+0x18]
    5166:	cmp    rcx,rax
    5169:	ja     5412 <botlish_fn_48+0x2d2>
    516f:	lea    rax,[rbx+0x18]
    5173:	mov    QWORD PTR [rdi],rax
    5176:	mov    r12,rdi
    5179:	mov    QWORD PTR [rbx],0x0
    5180:	mov    QWORD PTR [rbx+0x8],0x0
    5188:	mov    QWORD PTR [rbx+0x10],0x0
    5190:	mov    QWORD PTR [rbx],rsi
    5193:	mov    r13,rsi
    5196:	mov    rsi,r13
    5199:	mov    rdi,r12
    519c:	call   51a1 <botlish_fn_48+0x61>
			519d: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    51a1:	test   rax,rax
    51a4:	jne    51b2 <botlish_fn_48+0x72>
    51aa:	mov    rdi,r12
    51ad:	jmp    53c8 <botlish_fn_48+0x288>
    51b2:	mov    QWORD PTR [rbx+0x8],rax
    51b6:	mov    r14,rax
    51b9:	mov    rsi,r13
    51bc:	mov    rdi,r12
    51bf:	call   51c4 <botlish_fn_48+0x84>
			51c0: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    51c4:	mov    rcx,rax
    51c7:	test   rcx,rcx
    51ca:	jne    51d8 <botlish_fn_48+0x98>
    51d0:	mov    rdi,r12
    51d3:	jmp    53c8 <botlish_fn_48+0x288>
    51d8:	mov    edx,0x1
    51dd:	mov    rax,r14
    51e0:	test   rax,0x1
    51e6:	je     51f4 <botlish_fn_48+0xb4>
    51ec:	mov    r14,rax
    51ef:	jmp    5218 <botlish_fn_48+0xd8>
    51f4:	xor    edx,edx
    51f6:	test   rax,0x7
    51fc:	je     520a <botlish_fn_48+0xca>
    5202:	mov    r14,rax
    5205:	jmp    5218 <botlish_fn_48+0xd8>
    520a:	movzx  rdx,BYTE PTR [rax]
    520e:	mov    r14,rax
    5211:	rex cmp dl,0x1
    5215:	sete   dl
    5218:	test   dl,dl
    521a:	jne    523e <botlish_fn_48+0xfe>
    5220:	mov    rdi,r12
    5223:	mov    rax,QWORD PTR [rdi+0x10]
    5227:	mov    rcx,QWORD PTR [rax+0x38]
    522b:	xor    rdx,rdx
    522e:	mov    rsi,r14
    5231:	call   5236 <botlish_fn_48+0xf6>
			5232: R_X86_64_PLT32	rt_type_error-0x4
    5236:	mov    rdi,r12
    5239:	jmp    53c8 <botlish_fn_48+0x288>
    523e:	mov    rsi,r14
    5241:	mov    eax,0x1
    5246:	test   rcx,0x1
    524d:	je     525b <botlish_fn_48+0x11b>
    5253:	mov    r8,rcx
    5256:	jmp    527e <botlish_fn_48+0x13e>
    525b:	xor    eax,eax
    525d:	test   rcx,0x7
    5264:	je     5272 <botlish_fn_48+0x132>
    526a:	mov    r8,rcx
    526d:	jmp    527e <botlish_fn_48+0x13e>
    5272:	movzx  rax,BYTE PTR [rcx]
    5276:	mov    r8,rcx
    5279:	cmp    al,0x1
    527b:	sete   al
    527e:	test   al,al
    5280:	jne    52a4 <botlish_fn_48+0x164>
    5286:	mov    rdi,r12
    5289:	mov    rax,QWORD PTR [rdi+0x10]
    528d:	mov    rcx,QWORD PTR [rax+0x38]
    5291:	xor    rdx,rdx
    5294:	mov    rsi,r8
    5297:	call   529c <botlish_fn_48+0x15c>
			5298: R_X86_64_PLT32	rt_type_error-0x4
    529c:	mov    rdi,r12
    529f:	jmp    53c8 <botlish_fn_48+0x288>
    52a4:	mov    rcx,r8
    52a7:	mov    rax,rsi
    52aa:	and    rax,rcx
    52ad:	test   rax,0x1
    52b3:	jne    52da <botlish_fn_48+0x19a>
    52b9:	mov    rdx,r8
    52bc:	mov    rdi,r12
    52bf:	call   52c4 <botlish_fn_48+0x184>
			52c0: R_X86_64_PLT32	rt_int_cmp-0x4
    52c4:	mov    r9d,0x2
    52ca:	test   rax,rax
    52cd:	cmovg  r9,QWORD PTR [rip+0x16b]        # 5440 <botlish_fn_48+0x300>
    52d5:	jmp    52ee <botlish_fn_48+0x1ae>
    52da:	mov    r9d,0x2
    52e0:	mov    rcx,r8
    52e3:	cmp    rsi,rcx
    52e6:	cmovg  r9,QWORD PTR [rip+0x152]        # 5440 <botlish_fn_48+0x300>
    52ee:	cmp    r9,0x6
    52f2:	je     538e <botlish_fn_48+0x24e>
    52f8:	mov    rsi,r13
    52fb:	mov    rdi,r12
    52fe:	call   5303 <botlish_fn_48+0x1c3>
			52ff: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    5303:	test   rax,rax
    5306:	jne    5314 <botlish_fn_48+0x1d4>
    530c:	mov    rdi,r12
    530f:	jmp    53c8 <botlish_fn_48+0x288>
    5314:	mov    QWORD PTR [rbx+0x8],rax
    5318:	mov    QWORD PTR [rbx+0x10],0x5
    5320:	test   rax,0x1
    5326:	mov    rsi,rax
    5329:	je     5356 <botlish_fn_48+0x216>
    532f:	mov    rcx,rsi
    5332:	mov    rax,rcx
    5335:	sar    rax,1
    5338:	imul   QWORD PTR [rip+0x109]        # 5448 <botlish_fn_48+0x308>
    533f:	seto   cl
    5342:	or     rax,0x1
    5346:	test   cl,cl
    5348:	jne    5356 <botlish_fn_48+0x216>
    534e:	mov    rdx,rax
    5351:	jmp    5366 <botlish_fn_48+0x226>
    5356:	mov    edx,0x5
    535b:	mov    rdi,r12
    535e:	call   5363 <botlish_fn_48+0x223>
			535f: R_X86_64_PLT32	rt_int_mul-0x4
    5363:	mov    rdx,rax
    5366:	mov    QWORD PTR [rbx+0x8],rdx
    536a:	mov    rsi,r13
    536d:	mov    rdi,r12
    5370:	call   5375 <botlish_fn_48+0x235>
			5371: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    5375:	test   rax,rax
    5378:	jne    5386 <botlish_fn_48+0x246>
    537e:	mov    rdi,r12
    5381:	jmp    53c8 <botlish_fn_48+0x288>
    5386:	mov    rdi,r12
    5389:	jmp    53f0 <botlish_fn_48+0x2b0>
    538e:	mov    rsi,r13
    5391:	mov    rdi,r12
    5394:	call   5399 <botlish_fn_48+0x259>
			5395: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    5399:	test   rax,rax
    539c:	jne    53aa <botlish_fn_48+0x26a>
    53a2:	mov    rdi,r12
    53a5:	jmp    53c8 <botlish_fn_48+0x288>
    53aa:	mov    QWORD PTR [rbx+0x8],rax
    53ae:	mov    rdx,rax
    53b1:	mov    rsi,r13
    53b4:	mov    rdi,r12
    53b7:	call   53bc <botlish_fn_48+0x27c>
			53b8: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    53bc:	test   rax,rax
    53bf:	jne    53ed <botlish_fn_48+0x2ad>
    53c5:	mov    rdi,r12
    53c8:	mov    rdi,r12
    53cb:	mov    QWORD PTR [rdi],rbx
    53ce:	xor    rax,rax
    53d1:	mov    rbx,QWORD PTR [rsp]
    53d5:	mov    r12,QWORD PTR [rsp+0x8]
    53da:	mov    r13,QWORD PTR [rsp+0x10]
    53df:	mov    r14,QWORD PTR [rsp+0x18]
    53e4:	add    rsp,0x20
    53e8:	mov    rsp,rbp
    53eb:	pop    rbp
    53ec:	ret
    53ed:	mov    rdi,r12
    53f0:	mov    rdi,r12
    53f3:	mov    QWORD PTR [rdi],rbx
    53f6:	mov    rbx,QWORD PTR [rsp]
    53fa:	mov    r12,QWORD PTR [rsp+0x8]
    53ff:	mov    r13,QWORD PTR [rsp+0x10]
    5404:	mov    r14,QWORD PTR [rsp+0x18]
    5409:	add    rsp,0x20
    540d:	mov    rsp,rbp
    5410:	pop    rbp
    5411:	ret
    5412:	mov    r12,rdi
    5415:	call   541a <botlish_fn_48+0x2da>
			5416: R_X86_64_PLT32	rt_stack_overflow-0x4
    541a:	xor    rax,rax
    541d:	mov    rbx,QWORD PTR [rsp]
    5421:	mov    r12,QWORD PTR [rsp+0x8]
    5426:	mov    r13,QWORD PTR [rsp+0x10]
    542b:	mov    r14,QWORD PTR [rsp+0x18]
    5430:	add    rsp,0x20
    5434:	mov    rsp,rbp
    5437:	pop    rbp
    5438:	ret
    5439:	add    BYTE PTR [rax],al
    543b:	add    BYTE PTR [rax],al
    543d:	add    BYTE PTR [rax],al
    543f:	add    BYTE PTR [rsi],al
    5441:	add    BYTE PTR [rax],al
    5443:	add    BYTE PTR [rax],al
    5445:	add    BYTE PTR [rax],al
    5447:	add    BYTE PTR [rax+rax*1],al
    544a:	add    BYTE PTR [rax],al
    544c:	add    BYTE PTR [rax],al
	...

0000000000005450 <botlish_entry_48: ht_grow_or_clean<mutarray>>:
    5450:	push   rbp
    5451:	mov    rbp,rsp
    5454:	mov    rsi,QWORD PTR [rdx]
    5457:	call   545c <botlish_entry_48+0xc>
			5458: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    545c:	mov    rsp,rbp
    545f:	pop    rbp
    5460:	ret
    5461:	add    BYTE PTR [rax],al
    5463:	add    BYTE PTR [rax],al
    5465:	add    BYTE PTR [rax],al
	...

0000000000005468 <botlish_fn_49: ht_place<mutarray, int, any, any>>:
    5468:	push   rbp
    5469:	mov    rbp,rsp
    546c:	sub    rsp,0x50
    5470:	mov    QWORD PTR [rsp+0x20],rbx
    5475:	mov    QWORD PTR [rsp+0x28],r12
    547a:	mov    QWORD PTR [rsp+0x30],r13
    547f:	mov    QWORD PTR [rsp+0x38],r14
    5484:	mov    QWORD PTR [rsp+0x40],r15
    5489:	mov    r12,QWORD PTR [rdi]
    548c:	mov    rax,QWORD PTR [rdi+0x8]
    5490:	lea    r9,[r12+0x30]
    5495:	cmp    r9,rax
    5498:	ja     597d <botlish_fn_49+0x515>
    549e:	lea    rax,[r12+0x30]
    54a3:	mov    QWORD PTR [rdi],rax
    54a6:	mov    r13,rdi
    54a9:	mov    QWORD PTR [r12],0x0
    54b1:	mov    QWORD PTR [r12+0x8],0x0
    54ba:	mov    QWORD PTR [r12+0x10],0x0
    54c3:	mov    QWORD PTR [r12+0x18],0x0
    54cc:	mov    QWORD PTR [r12+0x20],0x0
    54d5:	mov    QWORD PTR [r12+0x28],0x0
    54de:	mov    QWORD PTR [r12],rsi
    54e2:	mov    r14,rsi
    54e5:	mov    QWORD PTR [r12+0x8],rdx
    54ea:	mov    QWORD PTR [rsp],rdx
    54ee:	mov    QWORD PTR [r12+0x10],rcx
    54f3:	mov    QWORD PTR [rsp+0x8],rcx
    54f8:	mov    QWORD PTR [r12+0x18],r8
    54fd:	mov    r15,r8
    5500:	mov    rsi,r14
    5503:	mov    rdi,r13
    5506:	call   550b <botlish_fn_49+0xa3>
			5507: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    550b:	test   rax,rax
    550e:	jne    551c <botlish_fn_49+0xb4>
    5514:	mov    rdi,r13
    5517:	jmp    5922 <botlish_fn_49+0x4ba>
    551c:	mov    QWORD PTR [r12+0x20],rax
    5521:	xor    ecx,ecx
    5523:	test   rax,0x7
    5529:	je     5539 <botlish_fn_49+0xd1>
    552f:	mov    QWORD PTR [rsp+0x10],rax
    5534:	jmp    5549 <botlish_fn_49+0xe1>
    5539:	movzx  rcx,BYTE PTR [rax]
    553d:	mov    QWORD PTR [rsp+0x10],rax
    5542:	rex cmp cl,0x8
    5546:	sete   cl
    5549:	test   cl,cl
    554b:	jne    5573 <botlish_fn_49+0x10b>
    5551:	mov    rdi,r13
    5554:	mov    rax,QWORD PTR [rdi+0x10]
    5558:	mov    rcx,QWORD PTR [rax+0x20]
    555c:	mov    edx,0x8
    5561:	mov    rsi,QWORD PTR [rsp+0x10]
    5566:	call   556b <botlish_fn_49+0x103>
			5567: R_X86_64_PLT32	rt_type_error-0x4
    556b:	mov    rdi,r13
    556e:	jmp    5922 <botlish_fn_49+0x4ba>
    5573:	mov    rdx,QWORD PTR [rsp]
    5577:	mov    rsi,QWORD PTR [rsp+0x10]
    557c:	mov    rdi,r13
    557f:	call   5584 <botlish_fn_49+0x11c>
			5580: R_X86_64_PLT32	rt_mutarray_get-0x4
    5584:	mov    rbx,rax
    5587:	test   rbx,rbx
    558a:	jne    5598 <botlish_fn_49+0x130>
    5590:	mov    rdi,r13
    5593:	jmp    5922 <botlish_fn_49+0x4ba>
    5598:	mov    QWORD PTR [r12+0x28],rbx
    559d:	mov    rdi,r13
    55a0:	call   55a5 <botlish_fn_49+0x13d>
			55a1: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    55a5:	test   rax,rax
    55a8:	mov    rcx,rax
    55ab:	jne    55b9 <botlish_fn_49+0x151>
    55b1:	mov    rdi,r13
    55b4:	jmp    5922 <botlish_fn_49+0x4ba>
    55b9:	mov    rsi,QWORD PTR [rsp+0x10]
    55be:	mov    rdx,QWORD PTR [rsp]
    55c2:	mov    rdi,r13
    55c5:	call   55ca <botlish_fn_49+0x162>
			55c6: R_X86_64_PLT32	rt_mutarray_set-0x4
    55ca:	test   rax,rax
    55cd:	jne    55db <botlish_fn_49+0x173>
    55d3:	mov    rdi,r13
    55d6:	jmp    5922 <botlish_fn_49+0x4ba>
    55db:	mov    rsi,r14
    55de:	mov    rdi,r13
    55e1:	call   55e6 <botlish_fn_49+0x17e>
			55e2: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    55e6:	test   rax,rax
    55e9:	jne    55f7 <botlish_fn_49+0x18f>
    55ef:	mov    rdi,r13
    55f2:	jmp    5922 <botlish_fn_49+0x4ba>
    55f7:	xor    ecx,ecx
    55f9:	test   rax,0x7
    55ff:	je     560d <botlish_fn_49+0x1a5>
    5605:	mov    rsi,rax
    5608:	jmp    561b <botlish_fn_49+0x1b3>
    560d:	movzx  r11,BYTE PTR [rax]
    5611:	mov    rsi,rax
    5614:	cmp    r11b,0x8
    5618:	sete   cl
    561b:	test   cl,cl
    561d:	jne    5640 <botlish_fn_49+0x1d8>
    5623:	mov    rdi,r13
    5626:	mov    rax,QWORD PTR [rdi+0x10]
    562a:	mov    rcx,QWORD PTR [rax+0x40]
    562e:	mov    edx,0x8
    5633:	call   5638 <botlish_fn_49+0x1d0>
			5634: R_X86_64_PLT32	rt_type_error-0x4
    5638:	mov    rdi,r13
    563b:	jmp    5922 <botlish_fn_49+0x4ba>
    5640:	mov    rcx,QWORD PTR [rsp+0x8]
    5645:	mov    rdx,QWORD PTR [rsp]
    5649:	mov    rdi,r13
    564c:	call   5651 <botlish_fn_49+0x1e9>
			564d: R_X86_64_PLT32	rt_mutarray_set-0x4
    5651:	test   rax,rax
    5654:	jne    5662 <botlish_fn_49+0x1fa>
    565a:	mov    rdi,r13
    565d:	jmp    5922 <botlish_fn_49+0x4ba>
    5662:	mov    rsi,r14
    5665:	mov    rdi,r13
    5668:	call   566d <botlish_fn_49+0x205>
			5669: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    566d:	test   rax,rax
    5670:	jne    567e <botlish_fn_49+0x216>
    5676:	mov    rdi,r13
    5679:	jmp    5922 <botlish_fn_49+0x4ba>
    567e:	xor    ecx,ecx
    5680:	test   rax,0x7
    5686:	je     5694 <botlish_fn_49+0x22c>
    568c:	mov    rsi,rax
    568f:	jmp    56a2 <botlish_fn_49+0x23a>
    5694:	movzx  rcx,BYTE PTR [rax]
    5698:	mov    rsi,rax
    569b:	rex cmp cl,0x8
    569f:	sete   cl
    56a2:	test   cl,cl
    56a4:	jne    56c7 <botlish_fn_49+0x25f>
    56aa:	mov    rdi,r13
    56ad:	mov    rax,QWORD PTR [rdi+0x10]
    56b1:	mov    rcx,QWORD PTR [rax+0x40]
    56b5:	mov    edx,0x8
    56ba:	call   56bf <botlish_fn_49+0x257>
			56bb: R_X86_64_PLT32	rt_type_error-0x4
    56bf:	mov    rdi,r13
    56c2:	jmp    5922 <botlish_fn_49+0x4ba>
    56c7:	mov    rcx,r15
    56ca:	mov    rdx,QWORD PTR [rsp]
    56ce:	mov    rdi,r13
    56d1:	call   56d6 <botlish_fn_49+0x26e>
			56d2: R_X86_64_PLT32	rt_mutarray_set-0x4
    56d6:	test   rax,rax
    56d9:	jne    56e7 <botlish_fn_49+0x27f>
    56df:	mov    rdi,r13
    56e2:	jmp    5922 <botlish_fn_49+0x4ba>
    56e7:	mov    QWORD PTR [r12+0x8],0x7
    56f0:	mov    rsi,r14
    56f3:	mov    rdi,r13
    56f6:	call   56fb <botlish_fn_49+0x293>
			56f7: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    56fb:	test   rax,rax
    56fe:	jne    570c <botlish_fn_49+0x2a4>
    5704:	mov    rdi,r13
    5707:	jmp    5922 <botlish_fn_49+0x4ba>
    570c:	mov    QWORD PTR [r12+0x10],rax
    5711:	mov    QWORD PTR [r12+0x18],0x3
    571a:	mov    ecx,0x1
    571f:	test   rax,0x1
    5725:	je     5733 <botlish_fn_49+0x2cb>
    572b:	mov    rsi,rax
    572e:	jmp    5757 <botlish_fn_49+0x2ef>
    5733:	xor    ecx,ecx
    5735:	test   rax,0x7
    573b:	je     5749 <botlish_fn_49+0x2e1>
    5741:	mov    rsi,rax
    5744:	jmp    5757 <botlish_fn_49+0x2ef>
    5749:	movzx  rcx,BYTE PTR [rax]
    574d:	mov    rsi,rax
    5750:	rex cmp cl,0x1
    5754:	sete   cl
    5757:	test   cl,cl
    5759:	jne    577a <botlish_fn_49+0x312>
    575f:	mov    rdi,r13
    5762:	mov    rax,QWORD PTR [rdi+0x10]
    5766:	mov    rcx,QWORD PTR [rax+0x30]
    576a:	xor    rdx,rdx
    576d:	call   5772 <botlish_fn_49+0x30a>
			576e: R_X86_64_PLT32	rt_type_error-0x4
    5772:	mov    rdi,r13
    5775:	jmp    5922 <botlish_fn_49+0x4ba>
    577a:	test   rsi,0x1
    5781:	je     5799 <botlish_fn_49+0x331>
    5787:	mov    rcx,rsi
    578a:	add    rcx,0x2
    578e:	seto   al
    5791:	test   al,al
    5793:	je     57a9 <botlish_fn_49+0x341>
    5799:	mov    edx,0x3
    579e:	mov    rdi,r13
    57a1:	call   57a6 <botlish_fn_49+0x33e>
			57a2: R_X86_64_PLT32	rt_int_add-0x4
    57a6:	mov    rcx,rax
    57a9:	mov    edx,0x7
    57ae:	mov    rsi,r14
    57b1:	mov    rdi,r13
    57b4:	call   57b9 <botlish_fn_49+0x351>
			57b5: R_X86_64_PLT32	rt_mutarray_set-0x4
    57b9:	test   rax,rax
    57bc:	jne    57ca <botlish_fn_49+0x362>
    57c2:	mov    rdi,r13
    57c5:	jmp    5922 <botlish_fn_49+0x4ba>
    57ca:	mov    rdi,r13
    57cd:	call   57d2 <botlish_fn_49+0x36a>
			57ce: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    57d2:	test   rax,rax
    57d5:	jne    57e3 <botlish_fn_49+0x37b>
    57db:	mov    rdi,r13
    57de:	jmp    5922 <botlish_fn_49+0x4ba>
    57e3:	mov    rcx,rbx
    57e6:	and    rcx,rax
    57e9:	mov    rdx,rax
    57ec:	mov    rax,rbx
    57ef:	test   rcx,0x1
    57f6:	jne    5818 <botlish_fn_49+0x3b0>
    57fc:	mov    rsi,rax
    57ff:	mov    rdi,r13
    5802:	call   5807 <botlish_fn_49+0x39f>
			5803: R_X86_64_PLT32	rt_value_eq-0x4
    5807:	test   rax,rax
    580a:	jne    582b <botlish_fn_49+0x3c3>
    5810:	mov    rdi,r13
    5813:	jmp    5922 <botlish_fn_49+0x4ba>
    5818:	mov    rsi,rax
    581b:	mov    eax,0x2
    5820:	cmp    rsi,rdx
    5823:	cmove  rax,QWORD PTR [rip+0x185]        # 59b0 <botlish_fn_49+0x548>
    582b:	cmp    rax,0x6
    582f:	je     583d <botlish_fn_49+0x3d5>
    5835:	mov    rdi,r13
    5838:	jmp    5950 <botlish_fn_49+0x4e8>
    583d:	mov    QWORD PTR [r12+0x8],0x9
    5846:	mov    rsi,r14
    5849:	mov    rdi,r13
    584c:	call   5851 <botlish_fn_49+0x3e9>
			584d: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    5851:	test   rax,rax
    5854:	jne    5862 <botlish_fn_49+0x3fa>
    585a:	mov    rdi,r13
    585d:	jmp    5922 <botlish_fn_49+0x4ba>
    5862:	mov    QWORD PTR [r12+0x10],rax
    5867:	mov    QWORD PTR [r12+0x18],0x3
    5870:	mov    ecx,0x1
    5875:	test   rax,0x1
    587b:	je     5889 <botlish_fn_49+0x421>
    5881:	mov    rsi,rax
    5884:	jmp    58ad <botlish_fn_49+0x445>
    5889:	xor    ecx,ecx
    588b:	test   rax,0x7
    5891:	je     589f <botlish_fn_49+0x437>
    5897:	mov    rsi,rax
    589a:	jmp    58ad <botlish_fn_49+0x445>
    589f:	movzx  rcx,BYTE PTR [rax]
    58a3:	mov    rsi,rax
    58a6:	rex cmp cl,0x1
    58aa:	sete   cl
    58ad:	test   cl,cl
    58af:	jne    58d0 <botlish_fn_49+0x468>
    58b5:	mov    rdi,r13
    58b8:	mov    rax,QWORD PTR [rdi+0x10]
    58bc:	mov    rcx,QWORD PTR [rax+0x48]
    58c0:	xor    rdx,rdx
    58c3:	call   58c8 <botlish_fn_49+0x460>
			58c4: R_X86_64_PLT32	rt_type_error-0x4
    58c8:	mov    rdi,r13
    58cb:	jmp    5922 <botlish_fn_49+0x4ba>
    58d0:	test   rsi,0x1
    58d7:	je     58f6 <botlish_fn_49+0x48e>
    58dd:	mov    rcx,rsi
    58e0:	sub    rcx,0x3
    58e4:	seto   al
    58e7:	add    rcx,0x1
    58ee:	test   al,al
    58f0:	je     5906 <botlish_fn_49+0x49e>
    58f6:	mov    edx,0x3
    58fb:	mov    rdi,r13
    58fe:	call   5903 <botlish_fn_49+0x49b>
			58ff: R_X86_64_PLT32	rt_int_sub-0x4
    5903:	mov    rcx,rax
    5906:	mov    edx,0x9
    590b:	mov    rsi,r14
    590e:	mov    rdi,r13
    5911:	call   5916 <botlish_fn_49+0x4ae>
			5912: R_X86_64_PLT32	rt_mutarray_set-0x4
    5916:	test   rax,rax
    5919:	jne    594d <botlish_fn_49+0x4e5>
    591f:	mov    rdi,r13
    5922:	mov    rdi,r13
    5925:	mov    QWORD PTR [rdi],r12
    5928:	xor    rax,rax
    592b:	mov    rbx,QWORD PTR [rsp+0x20]
    5930:	mov    r12,QWORD PTR [rsp+0x28]
    5935:	mov    r13,QWORD PTR [rsp+0x30]
    593a:	mov    r14,QWORD PTR [rsp+0x38]
    593f:	mov    r15,QWORD PTR [rsp+0x40]
    5944:	add    rsp,0x50
    5948:	mov    rsp,rbp
    594b:	pop    rbp
    594c:	ret
    594d:	mov    rdi,r13
    5950:	mov    rdi,r13
    5953:	mov    QWORD PTR [rdi],r12
    5956:	mov    eax,0xa
    595b:	mov    rbx,QWORD PTR [rsp+0x20]
    5960:	mov    r12,QWORD PTR [rsp+0x28]
    5965:	mov    r13,QWORD PTR [rsp+0x30]
    596a:	mov    r14,QWORD PTR [rsp+0x38]
    596f:	mov    r15,QWORD PTR [rsp+0x40]
    5974:	add    rsp,0x50
    5978:	mov    rsp,rbp
    597b:	pop    rbp
    597c:	ret
    597d:	mov    r13,rdi
    5980:	call   5985 <botlish_fn_49+0x51d>
			5981: R_X86_64_PLT32	rt_stack_overflow-0x4
    5985:	xor    rax,rax
    5988:	mov    rbx,QWORD PTR [rsp+0x20]
    598d:	mov    r12,QWORD PTR [rsp+0x28]
    5992:	mov    r13,QWORD PTR [rsp+0x30]
    5997:	mov    r14,QWORD PTR [rsp+0x38]
    599c:	mov    r15,QWORD PTR [rsp+0x40]
    59a1:	add    rsp,0x50
    59a5:	mov    rsp,rbp
    59a8:	pop    rbp
    59a9:	ret
    59aa:	add    BYTE PTR [rax],al
    59ac:	add    BYTE PTR [rax],al
    59ae:	add    BYTE PTR [rax],al
    59b0:	(bad)
    59b1:	add    BYTE PTR [rax],al
    59b3:	add    BYTE PTR [rax],al
    59b5:	add    BYTE PTR [rax],al
	...

00000000000059b8 <botlish_entry_49: ht_place<mutarray, int, any, any>>:
    59b8:	push   rbp
    59b9:	mov    rbp,rsp
    59bc:	mov    rsi,QWORD PTR [rdx]
    59bf:	mov    r9,QWORD PTR [rdx+0x8]
    59c3:	mov    rcx,QWORD PTR [rdx+0x10]
    59c7:	mov    r8,QWORD PTR [rdx+0x18]
    59cb:	mov    rdx,r9
    59ce:	call   59d3 <botlish_entry_49+0x1b>
			59cf: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    59d3:	mov    rsp,rbp
    59d6:	pop    rbp
    59d7:	ret

00000000000059d8 <botlish_fn_50: ht_set<mutarray, any, any>>:
    59d8:	push   rbp
    59d9:	mov    rbp,rsp
    59dc:	sub    rsp,0x50
    59e0:	mov    QWORD PTR [rsp+0x20],rbx
    59e5:	mov    QWORD PTR [rsp+0x28],r12
    59ea:	mov    QWORD PTR [rsp+0x30],r13
    59ef:	mov    QWORD PTR [rsp+0x38],r14
    59f4:	mov    QWORD PTR [rsp+0x40],r15
    59f9:	mov    rbx,QWORD PTR [rdi]
    59fc:	mov    rax,QWORD PTR [rdi+0x8]
    5a00:	lea    r8,[rbx+0x28]
    5a04:	cmp    r8,rax
    5a07:	ja     5dc5 <botlish_fn_50+0x3ed>
    5a0d:	lea    rax,[rbx+0x28]
    5a11:	mov    QWORD PTR [rdi],rax
    5a14:	mov    r12,rdi
    5a17:	mov    QWORD PTR [rbx],0x0
    5a1e:	mov    QWORD PTR [rbx+0x8],0x0
    5a26:	mov    QWORD PTR [rbx+0x10],0x0
    5a2e:	mov    QWORD PTR [rbx+0x18],0x0
    5a36:	mov    QWORD PTR [rbx+0x20],0x0
    5a3e:	mov    QWORD PTR [rbx],rsi
    5a41:	mov    r15,rsi
    5a44:	mov    QWORD PTR [rbx+0x8],rdx
    5a48:	mov    r14,rdx
    5a4b:	mov    QWORD PTR [rbx+0x10],rcx
    5a4f:	mov    r13,rcx
    5a52:	mov    rdx,r14
    5a55:	mov    rsi,r15
    5a58:	mov    rdi,r12
    5a5b:	call   5a60 <botlish_fn_50+0x88>
			5a5c: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    5a60:	test   rax,rax
    5a63:	jne    5a71 <botlish_fn_50+0x99>
    5a69:	mov    rdi,r12
    5a6c:	jmp    5d6d <botlish_fn_50+0x395>
    5a71:	mov    QWORD PTR [rbx+0x18],rax
    5a75:	mov    rcx,rax
    5a78:	mov    r8,0xffffffffffffffff
    5a7f:	mov    QWORD PTR [rsp+0x10],r8
    5a84:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    5a8c:	mov    rdx,r14
    5a8f:	mov    rsi,r15
    5a92:	mov    rdi,r12
    5a95:	call   5a9a <botlish_fn_50+0xc2>
			5a96: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    5a9a:	mov    rcx,rax
    5a9d:	mov    QWORD PTR [rsp+0x8],rax
    5aa2:	test   rax,rcx
    5aa5:	jne    5ab3 <botlish_fn_50+0xdb>
    5aab:	mov    rdi,r12
    5aae:	jmp    5d6d <botlish_fn_50+0x395>
    5ab3:	mov    rax,QWORD PTR [rsp+0x8]
    5ab8:	mov    QWORD PTR [rbx+0x18],rax
    5abc:	mov    rsi,r15
    5abf:	mov    rdi,r12
    5ac2:	call   5ac7 <botlish_fn_50+0xef>
			5ac3: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    5ac7:	test   rax,rax
    5aca:	jne    5ad8 <botlish_fn_50+0x100>
    5ad0:	mov    rdi,r12
    5ad3:	jmp    5d6d <botlish_fn_50+0x395>
    5ad8:	xor    ecx,ecx
    5ada:	test   rax,0x7
    5ae0:	je     5aee <botlish_fn_50+0x116>
    5ae6:	mov    rsi,rax
    5ae9:	jmp    5afc <botlish_fn_50+0x124>
    5aee:	movzx  rcx,BYTE PTR [rax]
    5af2:	mov    rsi,rax
    5af5:	rex cmp cl,0x8
    5af9:	sete   cl
    5afc:	test   cl,cl
    5afe:	jne    5b21 <botlish_fn_50+0x149>
    5b04:	mov    rdi,r12
    5b07:	mov    rax,QWORD PTR [rdi+0x10]
    5b0b:	mov    rcx,QWORD PTR [rax+0x20]
    5b0f:	mov    edx,0x8
    5b14:	call   5b19 <botlish_fn_50+0x141>
			5b15: R_X86_64_PLT32	rt_type_error-0x4
    5b19:	mov    rdi,r12
    5b1c:	jmp    5d6d <botlish_fn_50+0x395>
    5b21:	mov    rdx,QWORD PTR [rsp+0x8]
    5b26:	mov    rdi,r12
    5b29:	call   5b2e <botlish_fn_50+0x156>
			5b2a: R_X86_64_PLT32	rt_mutarray_get-0x4
    5b2e:	test   rax,rax
    5b31:	jne    5b3f <botlish_fn_50+0x167>
    5b37:	mov    rdi,r12
    5b3a:	jmp    5d6d <botlish_fn_50+0x395>
    5b3f:	mov    QWORD PTR [rbx+0x20],rax
    5b43:	mov    QWORD PTR [rsp],rax
    5b47:	mov    rdi,r12
    5b4a:	call   5b4f <botlish_fn_50+0x177>
			5b4b: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    5b4f:	test   rax,rax
    5b52:	jne    5b60 <botlish_fn_50+0x188>
    5b58:	mov    rdi,r12
    5b5b:	jmp    5d6d <botlish_fn_50+0x395>
    5b60:	mov    rcx,QWORD PTR [rsp]
    5b64:	mov    rdx,rcx
    5b67:	and    rdx,rax
    5b6a:	test   rdx,0x1
    5b71:	jne    5b97 <botlish_fn_50+0x1bf>
    5b77:	mov    rdx,rax
    5b7a:	mov    rsi,QWORD PTR [rsp]
    5b7e:	mov    rdi,r12
    5b81:	call   5b86 <botlish_fn_50+0x1ae>
			5b82: R_X86_64_PLT32	rt_value_eq-0x4
    5b86:	test   rax,rax
    5b89:	jne    5bae <botlish_fn_50+0x1d6>
    5b8f:	mov    rdi,r12
    5b92:	jmp    5d6d <botlish_fn_50+0x395>
    5b97:	mov    rdx,rax
    5b9a:	mov    rsi,QWORD PTR [rsp]
    5b9e:	mov    eax,0x2
    5ba3:	cmp    rsi,rdx
    5ba6:	cmove  rax,QWORD PTR [rip+0x24a]        # 5df8 <botlish_fn_50+0x420>
    5bae:	cmp    rax,0x6
    5bb2:	je     5cec <botlish_fn_50+0x314>
    5bb8:	mov    rsi,r15
    5bbb:	mov    rdi,r12
    5bbe:	call   5bc3 <botlish_fn_50+0x1eb>
			5bbf: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    5bc3:	test   rax,rax
    5bc6:	jne    5bd4 <botlish_fn_50+0x1fc>
    5bcc:	mov    rdi,r12
    5bcf:	jmp    5d6d <botlish_fn_50+0x395>
    5bd4:	cmp    rax,0x6
    5bd8:	je     5c2d <botlish_fn_50+0x255>
    5bde:	mov    rcx,r14
    5be1:	mov    rdx,QWORD PTR [rsp+0x8]
    5be6:	mov    rsi,r15
    5be9:	mov    r8,r13
    5bec:	mov    rdi,r12
    5bef:	call   5bf4 <botlish_fn_50+0x21c>
			5bf0: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    5bf4:	test   rax,rax
    5bf7:	jne    5c05 <botlish_fn_50+0x22d>
    5bfd:	mov    rdi,r12
    5c00:	jmp    5d6d <botlish_fn_50+0x395>
    5c05:	mov    rdi,r12
    5c08:	mov    QWORD PTR [rdi],rbx
    5c0b:	mov    rbx,QWORD PTR [rsp+0x20]
    5c10:	mov    r12,QWORD PTR [rsp+0x28]
    5c15:	mov    r13,QWORD PTR [rsp+0x30]
    5c1a:	mov    r14,QWORD PTR [rsp+0x38]
    5c1f:	mov    r15,QWORD PTR [rsp+0x40]
    5c24:	add    rsp,0x50
    5c28:	mov    rsp,rbp
    5c2b:	pop    rbp
    5c2c:	ret
    5c2d:	mov    rsi,r15
    5c30:	mov    rdi,r12
    5c33:	call   5c38 <botlish_fn_50+0x260>
			5c34: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    5c38:	test   rax,rax
    5c3b:	jne    5c49 <botlish_fn_50+0x271>
    5c41:	mov    rdi,r12
    5c44:	jmp    5d6d <botlish_fn_50+0x395>
    5c49:	mov    rdx,r14
    5c4c:	mov    rsi,r15
    5c4f:	mov    rdi,r12
    5c52:	call   5c57 <botlish_fn_50+0x27f>
			5c53: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    5c57:	test   rax,rax
    5c5a:	jne    5c68 <botlish_fn_50+0x290>
    5c60:	mov    rdi,r12
    5c63:	jmp    5d6d <botlish_fn_50+0x395>
    5c68:	mov    QWORD PTR [rbx+0x18],rax
    5c6c:	mov    rcx,rax
    5c6f:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    5c77:	mov    r8,QWORD PTR [rsp+0x10]
    5c7c:	mov    rdx,r14
    5c7f:	mov    rsi,r15
    5c82:	mov    rdi,r12
    5c85:	call   5c8a <botlish_fn_50+0x2b2>
			5c86: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    5c8a:	test   rax,rax
    5c8d:	jne    5c9b <botlish_fn_50+0x2c3>
    5c93:	mov    rdi,r12
    5c96:	jmp    5d6d <botlish_fn_50+0x395>
    5c9b:	mov    QWORD PTR [rbx+0x18],rax
    5c9f:	mov    rcx,r14
    5ca2:	mov    rdx,rax
    5ca5:	mov    rsi,r15
    5ca8:	mov    r8,r13
    5cab:	mov    rdi,r12
    5cae:	call   5cb3 <botlish_fn_50+0x2db>
			5caf: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    5cb3:	test   rax,rax
    5cb6:	jne    5cc4 <botlish_fn_50+0x2ec>
    5cbc:	mov    rdi,r12
    5cbf:	jmp    5d6d <botlish_fn_50+0x395>
    5cc4:	mov    rdi,r12
    5cc7:	mov    QWORD PTR [rdi],rbx
    5cca:	mov    rbx,QWORD PTR [rsp+0x20]
    5ccf:	mov    r12,QWORD PTR [rsp+0x28]
    5cd4:	mov    r13,QWORD PTR [rsp+0x30]
    5cd9:	mov    r14,QWORD PTR [rsp+0x38]
    5cde:	mov    r15,QWORD PTR [rsp+0x40]
    5ce3:	add    rsp,0x50
    5ce7:	mov    rsp,rbp
    5cea:	pop    rbp
    5ceb:	ret
    5cec:	mov    rsi,r15
    5cef:	mov    rdi,r12
    5cf2:	call   5cf7 <botlish_fn_50+0x31f>
			5cf3: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    5cf7:	test   rax,rax
    5cfa:	jne    5d08 <botlish_fn_50+0x330>
    5d00:	mov    rdi,r12
    5d03:	jmp    5d6d <botlish_fn_50+0x395>
    5d08:	xor    ecx,ecx
    5d0a:	test   rax,0x7
    5d10:	je     5d1e <botlish_fn_50+0x346>
    5d16:	mov    rsi,rax
    5d19:	jmp    5d2c <botlish_fn_50+0x354>
    5d1e:	movzx  r9,BYTE PTR [rax]
    5d22:	mov    rsi,rax
    5d25:	cmp    r9b,0x8
    5d29:	sete   cl
    5d2c:	test   cl,cl
    5d2e:	jne    5d51 <botlish_fn_50+0x379>
    5d34:	mov    rdi,r12
    5d37:	mov    rax,QWORD PTR [rdi+0x10]
    5d3b:	mov    rcx,QWORD PTR [rax+0x40]
    5d3f:	mov    edx,0x8
    5d44:	call   5d49 <botlish_fn_50+0x371>
			5d45: R_X86_64_PLT32	rt_type_error-0x4
    5d49:	mov    rdi,r12
    5d4c:	jmp    5d6d <botlish_fn_50+0x395>
    5d51:	mov    rcx,r13
    5d54:	mov    rdx,QWORD PTR [rsp+0x8]
    5d59:	mov    rdi,r12
    5d5c:	call   5d61 <botlish_fn_50+0x389>
			5d5d: R_X86_64_PLT32	rt_mutarray_set-0x4
    5d61:	test   rax,rax
    5d64:	jne    5d98 <botlish_fn_50+0x3c0>
    5d6a:	mov    rdi,r12
    5d6d:	mov    rdi,r12
    5d70:	mov    QWORD PTR [rdi],rbx
    5d73:	xor    rax,rax
    5d76:	mov    rbx,QWORD PTR [rsp+0x20]
    5d7b:	mov    r12,QWORD PTR [rsp+0x28]
    5d80:	mov    r13,QWORD PTR [rsp+0x30]
    5d85:	mov    r14,QWORD PTR [rsp+0x38]
    5d8a:	mov    r15,QWORD PTR [rsp+0x40]
    5d8f:	add    rsp,0x50
    5d93:	mov    rsp,rbp
    5d96:	pop    rbp
    5d97:	ret
    5d98:	mov    rdi,r12
    5d9b:	mov    QWORD PTR [rdi],rbx
    5d9e:	mov    eax,0xa
    5da3:	mov    rbx,QWORD PTR [rsp+0x20]
    5da8:	mov    r12,QWORD PTR [rsp+0x28]
    5dad:	mov    r13,QWORD PTR [rsp+0x30]
    5db2:	mov    r14,QWORD PTR [rsp+0x38]
    5db7:	mov    r15,QWORD PTR [rsp+0x40]
    5dbc:	add    rsp,0x50
    5dc0:	mov    rsp,rbp
    5dc3:	pop    rbp
    5dc4:	ret
    5dc5:	mov    r12,rdi
    5dc8:	call   5dcd <botlish_fn_50+0x3f5>
			5dc9: R_X86_64_PLT32	rt_stack_overflow-0x4
    5dcd:	xor    rax,rax
    5dd0:	mov    rbx,QWORD PTR [rsp+0x20]
    5dd5:	mov    r12,QWORD PTR [rsp+0x28]
    5dda:	mov    r13,QWORD PTR [rsp+0x30]
    5ddf:	mov    r14,QWORD PTR [rsp+0x38]
    5de4:	mov    r15,QWORD PTR [rsp+0x40]
    5de9:	add    rsp,0x50
    5ded:	mov    rsp,rbp
    5df0:	pop    rbp
    5df1:	ret
    5df2:	add    BYTE PTR [rax],al
    5df4:	add    BYTE PTR [rax],al
    5df6:	add    BYTE PTR [rax],al
    5df8:	(bad)
    5df9:	add    BYTE PTR [rax],al
    5dfb:	add    BYTE PTR [rax],al
    5dfd:	add    BYTE PTR [rax],al
	...

0000000000005e00 <botlish_entry_50: ht_set<mutarray, any, any>>:
    5e00:	push   rbp
    5e01:	mov    rbp,rsp
    5e04:	mov    rsi,QWORD PTR [rdx]
    5e07:	mov    r8,QWORD PTR [rdx+0x8]
    5e0b:	mov    rcx,QWORD PTR [rdx+0x10]
    5e0f:	mov    rdx,r8
    5e12:	call   5e17 <botlish_entry_50+0x17>
			5e13: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    5e17:	mov    rsp,rbp
    5e1a:	pop    rbp
    5e1b:	ret

0000000000005e1c <botlish_fn_51: row_new<bool, int>>:
    5e1c:	push   rbp
    5e1d:	mov    rbp,rsp
    5e20:	sub    rsp,0x10
    5e24:	mov    QWORD PTR [rsp],r14
    5e28:	mov    QWORD PTR [rsp+0x8],r15
    5e2d:	mov    r14,QWORD PTR [rdi]
    5e30:	mov    rax,QWORD PTR [rdi+0x8]
    5e34:	lea    rcx,[r14+0x8]
    5e38:	cmp    rcx,rax
    5e3b:	ja     5ed6 <botlish_fn_51+0xba>
    5e41:	lea    rax,[r14+0x8]
    5e45:	mov    QWORD PTR [rdi],rax
    5e48:	mov    r15,rdi
    5e4b:	mov    QWORD PTR [r14],rdx
    5e4e:	mov    rax,rdx
    5e51:	cmp    rsi,0x6
    5e55:	je     5e8c <botlish_fn_51+0x70>
    5e5b:	mov    rdi,r15
    5e5e:	call   5e63 <botlish_fn_51+0x47>
			5e5f: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    5e63:	test   rax,rax
    5e66:	jne    5e74 <botlish_fn_51+0x58>
    5e6c:	mov    rdi,r15
    5e6f:	jmp    5ea3 <botlish_fn_51+0x87>
    5e74:	mov    rdi,r15
    5e77:	mov    QWORD PTR [rdi],r14
    5e7a:	mov    r14,QWORD PTR [rsp]
    5e7e:	mov    r15,QWORD PTR [rsp+0x8]
    5e83:	add    rsp,0x10
    5e87:	mov    rsp,rbp
    5e8a:	pop    rbp
    5e8b:	ret
    5e8c:	mov    rsi,rax
    5e8f:	mov    rdi,r15
    5e92:	call   5e97 <botlish_fn_51+0x7b>
			5e93: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    5e97:	test   rax,rax
    5e9a:	jne    5ebe <botlish_fn_51+0xa2>
    5ea0:	mov    rdi,r15
    5ea3:	mov    rdi,r15
    5ea6:	mov    QWORD PTR [rdi],r14
    5ea9:	xor    rax,rax
    5eac:	mov    r14,QWORD PTR [rsp]
    5eb0:	mov    r15,QWORD PTR [rsp+0x8]
    5eb5:	add    rsp,0x10
    5eb9:	mov    rsp,rbp
    5ebc:	pop    rbp
    5ebd:	ret
    5ebe:	mov    rdi,r15
    5ec1:	mov    QWORD PTR [rdi],r14
    5ec4:	mov    r14,QWORD PTR [rsp]
    5ec8:	mov    r15,QWORD PTR [rsp+0x8]
    5ecd:	add    rsp,0x10
    5ed1:	mov    rsp,rbp
    5ed4:	pop    rbp
    5ed5:	ret
    5ed6:	mov    r15,rdi
    5ed9:	call   5ede <botlish_fn_51+0xc2>
			5eda: R_X86_64_PLT32	rt_stack_overflow-0x4
    5ede:	xor    rax,rax
    5ee1:	mov    r14,QWORD PTR [rsp]
    5ee5:	mov    r15,QWORD PTR [rsp+0x8]
    5eea:	add    rsp,0x10
    5eee:	mov    rsp,rbp
    5ef1:	pop    rbp
    5ef2:	ret

0000000000005ef3 <botlish_entry_51: row_new<bool, int>>:
    5ef3:	push   rbp
    5ef4:	mov    rbp,rsp
    5ef7:	mov    rsi,QWORD PTR [rdx]
    5efa:	mov    rdx,QWORD PTR [rdx+0x8]
    5efe:	call   5f03 <botlish_entry_51+0x10>
			5eff: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    5f03:	mov    rsp,rbp
    5f06:	pop    rbp
    5f07:	ret

0000000000005f08 <botlish_fn_52: row_fill<mutarray, any, any, int, int>>:
    5f08:	push   rbp
    5f09:	mov    rbp,rsp
    5f0c:	sub    rsp,0x50
    5f10:	mov    QWORD PTR [rsp+0x20],rbx
    5f15:	mov    QWORD PTR [rsp+0x28],r12
    5f1a:	mov    QWORD PTR [rsp+0x30],r13
    5f1f:	mov    QWORD PTR [rsp+0x38],r14
    5f24:	mov    QWORD PTR [rsp+0x40],r15
    5f29:	mov    r13,rdx
    5f2c:	mov    r15,QWORD PTR [rdi]
    5f2f:	mov    rax,QWORD PTR [rdi+0x8]
    5f33:	lea    rdx,[r15+0x30]
    5f37:	cmp    rdx,rax
    5f3a:	ja     6209 <botlish_fn_52+0x301>
    5f40:	lea    rdx,[r15+0x30]
    5f44:	mov    QWORD PTR [rdi],rdx
    5f47:	mov    QWORD PTR [rsp],rdi
    5f4b:	mov    QWORD PTR [r15],0x0
    5f52:	mov    QWORD PTR [r15+0x8],0x0
    5f5a:	mov    QWORD PTR [r15+0x10],0x0
    5f62:	mov    QWORD PTR [r15+0x18],0x0
    5f6a:	mov    QWORD PTR [r15+0x20],0x0
    5f72:	mov    QWORD PTR [r15+0x28],0x0
    5f7a:	mov    QWORD PTR [r15],rsi
    5f7d:	mov    rdx,r13
    5f80:	mov    r14,rsi
    5f83:	mov    QWORD PTR [r15+0x8],rdx
    5f87:	mov    QWORD PTR [r15+0x10],rcx
    5f8b:	mov    QWORD PTR [rsp+0x8],rcx
    5f90:	mov    QWORD PTR [r15+0x18],r8
    5f94:	mov    rbx,r9
    5f97:	mov    rax,rbx
    5f9a:	or     rax,0x1
    5f9e:	mov    r12,r8
    5fa1:	mov    rcx,r12
    5fa4:	and    rcx,rax
    5fa7:	test   rcx,0x1
    5fae:	jne    5fdc <botlish_fn_52+0xd4>
    5fb4:	mov    rdx,rbx
    5fb7:	or     rdx,0x1
    5fbb:	mov    rsi,r12
    5fbe:	mov    rdi,QWORD PTR [rsp]
    5fc2:	call   5fc7 <botlish_fn_52+0xbf>
			5fc3: R_X86_64_PLT32	rt_int_cmp-0x4
    5fc7:	mov    ecx,0x2
    5fcc:	test   rax,rax
    5fcf:	cmovge rcx,QWORD PTR [rip+0x261]        # 6238 <botlish_fn_52+0x330>
    5fd7:	jmp    5ff3 <botlish_fn_52+0xeb>
    5fdc:	mov    rax,rbx
    5fdf:	or     rax,0x1
    5fe3:	mov    ecx,0x2
    5fe8:	cmp    r12,rax
    5feb:	cmovge rcx,QWORD PTR [rip+0x245]        # 6238 <botlish_fn_52+0x330>
    5ff3:	cmp    rcx,0x6
    5ff7:	je     61dd <botlish_fn_52+0x2d5>
    5ffd:	xor    ecx,ecx
    5fff:	mov    rdx,r13
    6002:	test   rdx,0x7
    6009:	jne    601b <botlish_fn_52+0x113>
    600f:	mov    rdx,r13
    6012:	movzx  rax,BYTE PTR [rdx]
    6016:	cmp    al,0x3
    6018:	sete   cl
    601b:	test   cl,cl
    601d:	jne    6045 <botlish_fn_52+0x13d>
    6023:	mov    rdi,QWORD PTR [rsp]
    6027:	mov    rax,QWORD PTR [rdi+0x10]
    602b:	mov    rcx,QWORD PTR [rax+0x50]
    602f:	mov    edx,0x4
    6034:	mov    rsi,r13
    6037:	call   603c <botlish_fn_52+0x134>
			6038: R_X86_64_PLT32	rt_type_error-0x4
    603c:	mov    rdi,QWORD PTR [rsp]
    6040:	jmp    6184 <botlish_fn_52+0x27c>
    6045:	mov    rsi,r13
    6048:	test   r12,0x1
    604f:	jne    605d <botlish_fn_52+0x155>
    6055:	mov    r13,rsi
    6058:	jmp    6073 <botlish_fn_52+0x16b>
    605d:	mov    rax,QWORD PTR [rsi+0x8]
    6061:	mov    r13,rsi
    6064:	mov    rcx,r12
    6067:	sar    rcx,1
    606a:	cmp    rcx,rax
    606d:	jb     609c <botlish_fn_52+0x194>
    6073:	mov    rdx,r12
    6076:	mov    rsi,r13
    6079:	mov    rdi,QWORD PTR [rsp]
    607d:	call   6082 <botlish_fn_52+0x17a>
			607e: R_X86_64_PLT32	rt_list_get-0x4
    6082:	test   rax,rax
    6085:	jne    6094 <botlish_fn_52+0x18c>
    608b:	mov    rdi,QWORD PTR [rsp]
    608f:	jmp    6184 <botlish_fn_52+0x27c>
    6094:	mov    rdx,rax
    6097:	jmp    60a4 <botlish_fn_52+0x19c>
    609c:	mov    rax,QWORD PTR [r13+0x10]
    60a0:	mov    rdx,QWORD PTR [rax+rcx*8]
    60a4:	mov    QWORD PTR [r15+0x20],rdx
    60a8:	mov    QWORD PTR [rsp+0x10],rdx
    60ad:	xor    ecx,ecx
    60af:	mov    rdx,QWORD PTR [rsp+0x8]
    60b4:	test   rdx,0x7
    60bb:	je     60cb <botlish_fn_52+0x1c3>
    60c1:	mov    QWORD PTR [rsp+0x8],rdx
    60c6:	jmp    60d9 <botlish_fn_52+0x1d1>
    60cb:	movzx  rax,BYTE PTR [rdx]
    60cf:	mov    QWORD PTR [rsp+0x8],rdx
    60d4:	cmp    al,0x3
    60d6:	sete   cl
    60d9:	test   cl,cl
    60db:	jne    6105 <botlish_fn_52+0x1fd>
    60e1:	mov    rdi,QWORD PTR [rsp]
    60e5:	mov    rax,QWORD PTR [rdi+0x10]
    60e9:	mov    rcx,QWORD PTR [rax+0x50]
    60ed:	mov    edx,0x4
    60f2:	mov    rsi,QWORD PTR [rsp+0x8]
    60f7:	call   60fc <botlish_fn_52+0x1f4>
			60f8: R_X86_64_PLT32	rt_type_error-0x4
    60fc:	mov    rdi,QWORD PTR [rsp]
    6100:	jmp    6184 <botlish_fn_52+0x27c>
    6105:	test   r12,0x1
    610c:	je     612a <botlish_fn_52+0x222>
    6112:	mov    rsi,QWORD PTR [rsp+0x8]
    6117:	mov    rcx,QWORD PTR [rsi+0x8]
    611b:	mov    rax,r12
    611e:	sar    rax,1
    6121:	cmp    rax,rcx
    6124:	jb     6155 <botlish_fn_52+0x24d>
    612a:	mov    rdx,r12
    612d:	mov    rsi,QWORD PTR [rsp+0x8]
    6132:	mov    rdi,QWORD PTR [rsp]
    6136:	call   613b <botlish_fn_52+0x233>
			6137: R_X86_64_PLT32	rt_list_get-0x4
    613b:	test   rax,rax
    613e:	jne    614d <botlish_fn_52+0x245>
    6144:	mov    rdi,QWORD PTR [rsp]
    6148:	jmp    6184 <botlish_fn_52+0x27c>
    614d:	mov    rcx,rax
    6150:	jmp    6162 <botlish_fn_52+0x25a>
    6155:	mov    rsi,QWORD PTR [rsp+0x8]
    615a:	mov    rcx,QWORD PTR [rsi+0x10]
    615e:	mov    rcx,QWORD PTR [rcx+rax*8]
    6162:	mov    QWORD PTR [r15+0x28],rcx
    6166:	mov    rdx,QWORD PTR [rsp+0x10]
    616b:	mov    rsi,r14
    616e:	mov    rdi,QWORD PTR [rsp]
    6172:	call   6177 <botlish_fn_52+0x26f>
			6173: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    6177:	test   rax,rax
    617a:	jne    61b0 <botlish_fn_52+0x2a8>
    6180:	mov    rdi,QWORD PTR [rsp]
    6184:	mov    rdi,QWORD PTR [rsp]
    6188:	mov    QWORD PTR [rdi],r15
    618b:	xor    rax,rax
    618e:	mov    rbx,QWORD PTR [rsp+0x20]
    6193:	mov    r12,QWORD PTR [rsp+0x28]
    6198:	mov    r13,QWORD PTR [rsp+0x30]
    619d:	mov    r14,QWORD PTR [rsp+0x38]
    61a2:	mov    r15,QWORD PTR [rsp+0x40]
    61a7:	add    rsp,0x50
    61ab:	mov    rsp,rbp
    61ae:	pop    rbp
    61af:	ret
    61b0:	mov    QWORD PTR [r15],r14
    61b3:	mov    QWORD PTR [r15+0x8],r13
    61b7:	mov    rsi,QWORD PTR [rsp+0x8]
    61bc:	mov    QWORD PTR [r15+0x10],rsi
    61c0:	sar    r12,1
    61c3:	add    r12,0x1
    61ca:	shl    r12,1
    61cd:	or     r12,0x1
    61d1:	mov    QWORD PTR [r15+0x18],r12
    61d5:	mov    r8,r12
    61d8:	jmp    5f97 <botlish_fn_52+0x8f>
    61dd:	mov    rdi,QWORD PTR [rsp]
    61e1:	mov    QWORD PTR [rdi],r15
    61e4:	mov    rax,r14
    61e7:	mov    rbx,QWORD PTR [rsp+0x20]
    61ec:	mov    r12,QWORD PTR [rsp+0x28]
    61f1:	mov    r13,QWORD PTR [rsp+0x30]
    61f6:	mov    r14,QWORD PTR [rsp+0x38]
    61fb:	mov    r15,QWORD PTR [rsp+0x40]
    6200:	add    rsp,0x50
    6204:	mov    rsp,rbp
    6207:	pop    rbp
    6208:	ret
    6209:	mov    QWORD PTR [rsp],rdi
    620d:	call   6212 <botlish_fn_52+0x30a>
			620e: R_X86_64_PLT32	rt_stack_overflow-0x4
    6212:	xor    rax,rax
    6215:	mov    rbx,QWORD PTR [rsp+0x20]
    621a:	mov    r12,QWORD PTR [rsp+0x28]
    621f:	mov    r13,QWORD PTR [rsp+0x30]
    6224:	mov    r14,QWORD PTR [rsp+0x38]
    6229:	mov    r15,QWORD PTR [rsp+0x40]
    622e:	add    rsp,0x50
    6232:	mov    rsp,rbp
    6235:	pop    rbp
    6236:	ret
    6237:	add    BYTE PTR [rsi],al
    6239:	add    BYTE PTR [rax],al
    623b:	add    BYTE PTR [rax],al
    623d:	add    BYTE PTR [rax],al
	...

0000000000006240 <botlish_entry_52: row_fill<mutarray, any, any, int, int>>:
    6240:	push   rbp
    6241:	mov    rbp,rsp
    6244:	mov    rsi,QWORD PTR [rdx]
    6247:	mov    r10,QWORD PTR [rdx+0x8]
    624b:	mov    rcx,QWORD PTR [rdx+0x10]
    624f:	mov    r8,QWORD PTR [rdx+0x18]
    6253:	mov    r9,QWORD PTR [rdx+0x20]
    6257:	mov    rdx,r10
    625a:	call   625f <botlish_entry_52+0x1f>
			625b: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    625f:	mov    rsp,rbp
    6262:	pop    rbp
    6263:	ret

0000000000006264 <botlish_fn_53: row_table<any, int, any, bool>>:
    6264:	push   rbp
    6265:	mov    rbp,rsp
    6268:	sub    rsp,0x30
    626c:	mov    QWORD PTR [rsp],rbx
    6270:	mov    QWORD PTR [rsp+0x8],r12
    6275:	mov    QWORD PTR [rsp+0x10],r13
    627a:	mov    QWORD PTR [rsp+0x18],r14
    627f:	mov    QWORD PTR [rsp+0x20],r15
    6284:	mov    rbx,QWORD PTR [rdi]
    6287:	mov    rax,QWORD PTR [rdi+0x8]
    628b:	lea    r9,[rbx+0x28]
    628f:	cmp    r9,rax
    6292:	ja     63dd <botlish_fn_53+0x179>
    6298:	lea    rax,[rbx+0x28]
    629c:	mov    QWORD PTR [rdi],rax
    629f:	mov    r12,rdi
    62a2:	mov    QWORD PTR [rbx],0x0
    62a9:	mov    QWORD PTR [rbx+0x8],0x0
    62b1:	mov    QWORD PTR [rbx+0x10],0x0
    62b9:	mov    QWORD PTR [rbx+0x18],0x0
    62c1:	mov    QWORD PTR [rbx+0x20],0x0
    62c9:	mov    QWORD PTR [rbx],rsi
    62cc:	mov    r14,rsi
    62cf:	mov    QWORD PTR [rbx+0x8],rdx
    62d3:	mov    QWORD PTR [rbx+0x10],rcx
    62d7:	mov    r13,rcx
    62da:	mov    QWORD PTR [rbx+0x18],r8
    62de:	mov    rsi,r8
    62e1:	mov    rdi,r12
    62e4:	call   62e9 <botlish_fn_53+0x85>
			62e5: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    62e9:	test   rax,rax
    62ec:	jne    62fa <botlish_fn_53+0x96>
    62f2:	mov    rdi,r12
    62f5:	jmp    638c <botlish_fn_53+0x128>
    62fa:	mov    QWORD PTR [rbx+0x8],rax
    62fe:	mov    r15,rax
    6301:	mov    QWORD PTR [rbx+0x18],0x1
    6309:	xor    ecx,ecx
    630b:	mov    rdx,r13
    630e:	test   rdx,0x7
    6315:	je     6323 <botlish_fn_53+0xbf>
    631b:	mov    r13,rdx
    631e:	jmp    632f <botlish_fn_53+0xcb>
    6323:	movzx  rax,BYTE PTR [rdx]
    6327:	mov    r13,rdx
    632a:	cmp    al,0x3
    632c:	sete   cl
    632f:	test   cl,cl
    6331:	jne    6357 <botlish_fn_53+0xf3>
    6337:	mov    rdi,r12
    633a:	mov    rax,QWORD PTR [rdi+0x10]
    633e:	mov    rcx,QWORD PTR [rax+0x58]
    6342:	mov    edx,0x4
    6347:	mov    rsi,r13
    634a:	call   634f <botlish_fn_53+0xeb>
			634b: R_X86_64_PLT32	rt_type_error-0x4
    634f:	mov    rdi,r12
    6352:	jmp    638c <botlish_fn_53+0x128>
    6357:	mov    rsi,r13
    635a:	mov    rdi,r12
    635d:	call   6362 <botlish_fn_53+0xfe>
			635e: R_X86_64_PLT32	rt_list_len-0x4
    6362:	mov    QWORD PTR [rbx+0x20],rax
    6366:	mov    r8d,0x1
    636c:	mov    rcx,r13
    636f:	mov    rdx,r14
    6372:	mov    rsi,r15
    6375:	mov    r9,rax
    6378:	mov    rdi,r12
    637b:	call   6380 <botlish_fn_53+0x11c>
			637c: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    6380:	test   rax,rax
    6383:	jne    63b6 <botlish_fn_53+0x152>
    6389:	mov    rdi,r12
    638c:	mov    rdi,r12
    638f:	mov    QWORD PTR [rdi],rbx
    6392:	xor    rax,rax
    6395:	mov    rbx,QWORD PTR [rsp]
    6399:	mov    r12,QWORD PTR [rsp+0x8]
    639e:	mov    r13,QWORD PTR [rsp+0x10]
    63a3:	mov    r14,QWORD PTR [rsp+0x18]
    63a8:	mov    r15,QWORD PTR [rsp+0x20]
    63ad:	add    rsp,0x30
    63b1:	mov    rsp,rbp
    63b4:	pop    rbp
    63b5:	ret
    63b6:	mov    rdi,r12
    63b9:	mov    QWORD PTR [rdi],rbx
    63bc:	mov    rbx,QWORD PTR [rsp]
    63c0:	mov    r12,QWORD PTR [rsp+0x8]
    63c5:	mov    r13,QWORD PTR [rsp+0x10]
    63ca:	mov    r14,QWORD PTR [rsp+0x18]
    63cf:	mov    r15,QWORD PTR [rsp+0x20]
    63d4:	add    rsp,0x30
    63d8:	mov    rsp,rbp
    63db:	pop    rbp
    63dc:	ret
    63dd:	mov    r12,rdi
    63e0:	call   63e5 <botlish_fn_53+0x181>
			63e1: R_X86_64_PLT32	rt_stack_overflow-0x4
    63e5:	xor    rax,rax
    63e8:	mov    rbx,QWORD PTR [rsp]
    63ec:	mov    r12,QWORD PTR [rsp+0x8]
    63f1:	mov    r13,QWORD PTR [rsp+0x10]
    63f6:	mov    r14,QWORD PTR [rsp+0x18]
    63fb:	mov    r15,QWORD PTR [rsp+0x20]
    6400:	add    rsp,0x30
    6404:	mov    rsp,rbp
    6407:	pop    rbp
    6408:	ret

0000000000006409 <botlish_entry_53: row_table<any, int, any, bool>>:
    6409:	push   rbp
    640a:	mov    rbp,rsp
    640d:	mov    rsi,QWORD PTR [rdx]
    6410:	mov    r9,QWORD PTR [rdx+0x8]
    6414:	mov    rcx,QWORD PTR [rdx+0x10]
    6418:	mov    r8,QWORD PTR [rdx+0x18]
    641c:	mov    rdx,r9
    641f:	call   6424 <botlish_entry_53+0x1b>
			6420: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    6424:	mov    rsp,rbp
    6427:	pop    rbp
    6428:	ret
    6429:	add    BYTE PTR [rax],al
    642b:	add    BYTE PTR [rax],al
    642d:	add    BYTE PTR [rax],al
	...

0000000000006430 <botlish_fn_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    6430:	push   rbp
    6431:	mov    rbp,rsp
    6434:	sub    rsp,0x60
    6438:	mov    QWORD PTR [rsp+0x30],rbx
    643d:	mov    QWORD PTR [rsp+0x38],r12
    6442:	mov    QWORD PTR [rsp+0x40],r13
    6447:	mov    QWORD PTR [rsp+0x48],r14
    644c:	mov    QWORD PTR [rsp+0x50],r15
    6451:	mov    QWORD PTR [rsp+0x8],r8
    6456:	mov    r11,QWORD PTR [rbp+0x10]
    645a:	mov    r12,QWORD PTR [rbp+0x18]
    645e:	mov    QWORD PTR [rsp+0x10],r12
    6463:	mov    r12,QWORD PTR [rdi]
    6466:	mov    rax,QWORD PTR [rdi+0x8]
    646a:	lea    r8,[r12+0x40]
    646f:	cmp    r8,rax
    6472:	ja     66e5 <botlish_fn_54+0x2b5>
    6478:	lea    rax,[r12+0x40]
    647d:	mov    QWORD PTR [rdi],rax
    6480:	mov    QWORD PTR [rsp],rdi
    6484:	mov    QWORD PTR [r12],0x0
    648c:	mov    QWORD PTR [r12+0x8],0x0
    6495:	mov    QWORD PTR [r12+0x10],0x0
    649e:	mov    QWORD PTR [r12+0x18],0x0
    64a7:	mov    QWORD PTR [r12+0x20],0x0
    64b0:	mov    QWORD PTR [r12+0x28],0x0
    64b9:	mov    QWORD PTR [r12+0x30],0x0
    64c2:	mov    QWORD PTR [r12+0x38],0x0
    64cb:	mov    QWORD PTR [r12],rsi
    64cf:	mov    QWORD PTR [r12+0x8],rdx
    64d4:	mov    rbx,rdx
    64d7:	mov    QWORD PTR [r12+0x10],rcx
    64dc:	mov    r15,rcx
    64df:	mov    QWORD PTR [r12+0x18],r9
    64e4:	mov    QWORD PTR [r12+0x20],r11
    64e9:	mov    rax,QWORD PTR [rsp+0x10]
    64ee:	mov    QWORD PTR [rsp+0x20],r11
    64f3:	mov    QWORD PTR [r12+0x28],rax
    64f8:	mov    r14,rsi
    64fb:	mov    QWORD PTR [rsp+0x18],r9
    6500:	mov    rsi,r14
    6503:	mov    rdi,QWORD PTR [rsp]
    6507:	call   650c <botlish_fn_54+0xdc>
			6508: R_X86_64_PLT32	rt_list_len-0x4
    650c:	mov    r13,rbx
    650f:	mov    rcx,r13
    6512:	and    rcx,rax
    6515:	mov    rdx,rax
    6518:	test   rcx,0x1
    651f:	jne    6546 <botlish_fn_54+0x116>
    6525:	mov    rsi,r13
    6528:	mov    rdi,QWORD PTR [rsp]
    652c:	call   6531 <botlish_fn_54+0x101>
			652d: R_X86_64_PLT32	rt_int_cmp-0x4
    6531:	mov    ecx,0x2
    6536:	test   rax,rax
    6539:	cmovge rcx,QWORD PTR [rip+0x1d7]        # 6718 <botlish_fn_54+0x2e8>
    6541:	jmp    6556 <botlish_fn_54+0x126>
    6546:	mov    ecx,0x2
    654b:	cmp    r13,rdx
    654e:	cmovge rcx,QWORD PTR [rip+0x1c2]        # 6718 <botlish_fn_54+0x2e8>
    6556:	cmp    rcx,0x6
    655a:	je     6670 <botlish_fn_54+0x240>
    6560:	mov    rcx,QWORD PTR [rsp+0x8]
    6565:	mov    r10,rcx
    6568:	or     r10,0x1
    656c:	mov    QWORD PTR [r12+0x30],r10
    6571:	test   r13,0x1
    6578:	je     6591 <botlish_fn_54+0x161>
    657e:	mov    rcx,QWORD PTR [r14+0x8]
    6582:	mov    rax,r13
    6585:	sar    rax,1
    6588:	cmp    rax,rcx
    658b:	jb     65ba <botlish_fn_54+0x18a>
    6591:	mov    rdx,r13
    6594:	mov    rsi,r14
    6597:	mov    rdi,QWORD PTR [rsp]
    659b:	call   65a0 <botlish_fn_54+0x170>
			659c: R_X86_64_PLT32	rt_list_get-0x4
    65a0:	test   rax,rax
    65a3:	jne    65b2 <botlish_fn_54+0x182>
    65a9:	mov    rdi,QWORD PTR [rsp]
    65ad:	jmp    6690 <botlish_fn_54+0x260>
    65b2:	mov    rcx,rax
    65b5:	jmp    65c2 <botlish_fn_54+0x192>
    65ba:	mov    rcx,QWORD PTR [r14+0x10]
    65be:	mov    rcx,QWORD PTR [rcx+rax*8]
    65c2:	mov    QWORD PTR [r12+0x38],rcx
    65c7:	mov    rax,QWORD PTR [rsp+0x8]
    65cc:	mov    rdx,rax
    65cf:	or     rdx,0x1
    65d3:	mov    rbx,QWORD PTR [rsp+0x10]
    65d8:	mov    rsi,r15
    65db:	mov    rdi,QWORD PTR [rsp]
    65df:	mov    r8,rbx
    65e2:	call   65e7 <botlish_fn_54+0x1b7>
			65e3: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    65e7:	test   rax,rax
    65ea:	jne    65f9 <botlish_fn_54+0x1c9>
    65f0:	mov    rdi,QWORD PTR [rsp]
    65f4:	jmp    6690 <botlish_fn_54+0x260>
    65f9:	mov    QWORD PTR [r12+0x8],rax
    65fe:	mov    rcx,rax
    6601:	sar    r13,1
    6604:	add    r13,0x1
    660b:	shl    r13,1
    660e:	or     r13,0x1
    6612:	mov    QWORD PTR [r12+0x30],r13
    6617:	mov    rdx,QWORD PTR [rsp+0x20]
    661c:	mov    rsi,QWORD PTR [rsp+0x18]
    6621:	mov    rdi,QWORD PTR [rsp]
    6625:	call   662a <botlish_fn_54+0x1fa>
			6626: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<list[mutarray, int], mutarray>
    662a:	test   rax,rax
    662d:	jne    663c <botlish_fn_54+0x20c>
    6633:	mov    rdi,QWORD PTR [rsp]
    6637:	jmp    6690 <botlish_fn_54+0x260>
    663c:	mov    QWORD PTR [r12],r14
    6640:	mov    QWORD PTR [r12+0x8],r13
    6645:	mov    QWORD PTR [r12+0x10],r15
    664a:	mov    QWORD PTR [r12+0x18],rax
    664f:	mov    QWORD PTR [r12+0x20],rdx
    6654:	mov    QWORD PTR [r12+0x28],rbx
    6659:	mov    QWORD PTR [rsp+0x20],rdx
    665e:	mov    QWORD PTR [rsp+0x18],rax
    6663:	mov    QWORD PTR [rsp+0x10],rbx
    6668:	mov    rbx,r13
    666b:	jmp    6500 <botlish_fn_54+0xd0>
    6670:	mov    rdx,QWORD PTR [rsp+0x20]
    6675:	mov    rsi,QWORD PTR [rsp+0x18]
    667a:	mov    rdi,QWORD PTR [rsp]
    667e:	call   6683 <botlish_fn_54+0x253>
			667f: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    6683:	test   rax,rax
    6686:	jne    66bc <botlish_fn_54+0x28c>
    668c:	mov    rdi,QWORD PTR [rsp]
    6690:	mov    rdi,QWORD PTR [rsp]
    6694:	mov    QWORD PTR [rdi],r12
    6697:	xor    rax,rax
    669a:	mov    rbx,QWORD PTR [rsp+0x30]
    669f:	mov    r12,QWORD PTR [rsp+0x38]
    66a4:	mov    r13,QWORD PTR [rsp+0x40]
    66a9:	mov    r14,QWORD PTR [rsp+0x48]
    66ae:	mov    r15,QWORD PTR [rsp+0x50]
    66b3:	add    rsp,0x60
    66b7:	mov    rsp,rbp
    66ba:	pop    rbp
    66bb:	ret
    66bc:	mov    rdi,QWORD PTR [rsp]
    66c0:	mov    QWORD PTR [rdi],r12
    66c3:	mov    rbx,QWORD PTR [rsp+0x30]
    66c8:	mov    r12,QWORD PTR [rsp+0x38]
    66cd:	mov    r13,QWORD PTR [rsp+0x40]
    66d2:	mov    r14,QWORD PTR [rsp+0x48]
    66d7:	mov    r15,QWORD PTR [rsp+0x50]
    66dc:	add    rsp,0x60
    66e0:	mov    rsp,rbp
    66e3:	pop    rbp
    66e4:	ret
    66e5:	mov    QWORD PTR [rsp],rdi
    66e9:	call   66ee <botlish_fn_54+0x2be>
			66ea: R_X86_64_PLT32	rt_stack_overflow-0x4
    66ee:	xor    rax,rax
    66f1:	mov    rbx,QWORD PTR [rsp+0x30]
    66f6:	mov    r12,QWORD PTR [rsp+0x38]
    66fb:	mov    r13,QWORD PTR [rsp+0x40]
    6700:	mov    r14,QWORD PTR [rsp+0x48]
    6705:	mov    r15,QWORD PTR [rsp+0x50]
    670a:	add    rsp,0x60
    670e:	mov    rsp,rbp
    6711:	pop    rbp
    6712:	ret
    6713:	add    BYTE PTR [rax],al
    6715:	add    BYTE PTR [rax],al
    6717:	add    BYTE PTR [rsi],al
    6719:	add    BYTE PTR [rax],al
    671b:	add    BYTE PTR [rax],al
    671d:	add    BYTE PTR [rax],al
	...

0000000000006720 <botlish_entry_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    6720:	push   rbp
    6721:	mov    rbp,rsp
    6724:	sub    rsp,0x10
    6728:	mov    rsi,QWORD PTR [rdx]
    672b:	mov    r10,QWORD PTR [rdx+0x8]
    672f:	mov    rcx,QWORD PTR [rdx+0x10]
    6733:	mov    r8,QWORD PTR [rdx+0x18]
    6737:	mov    r9,QWORD PTR [rdx+0x20]
    673b:	mov    r11,QWORD PTR [rdx+0x28]
    673f:	mov    rax,QWORD PTR [rdx+0x30]
    6743:	mov    QWORD PTR [rsp],r11
    6747:	mov    QWORD PTR [rsp+0x8],rax
    674c:	mov    rdx,r10
    674f:	call   6754 <botlish_entry_54+0x34>
			6750: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    6754:	add    rsp,0x10
    6758:	mov    rsp,rbp
    675b:	pop    rbp
    675c:	ret

000000000000675d <botlish_fn_55: csv_records_generic<str, bool>>:
    675d:	push   rbp
    675e:	mov    rbp,rsp
    6761:	sub    rsp,0x50
    6765:	mov    QWORD PTR [rsp+0x20],rbx
    676a:	mov    QWORD PTR [rsp+0x28],r12
    676f:	mov    QWORD PTR [rsp+0x30],r13
    6774:	mov    QWORD PTR [rsp+0x38],r14
    6779:	mov    QWORD PTR [rsp+0x40],r15
    677e:	mov    rbx,QWORD PTR [rdi]
    6781:	mov    rax,QWORD PTR [rdi+0x8]
    6785:	lea    rcx,[rbx+0x38]
    6789:	cmp    rcx,rax
    678c:	ja     69af <botlish_fn_55+0x252>
    6792:	lea    rax,[rbx+0x38]
    6796:	mov    QWORD PTR [rdi],rax
    6799:	mov    r12,rdi
    679c:	mov    QWORD PTR [rbx],0x0
    67a3:	mov    QWORD PTR [rbx+0x8],0x0
    67ab:	mov    QWORD PTR [rbx+0x10],0x0
    67b3:	mov    QWORD PTR [rbx+0x18],0x0
    67bb:	mov    QWORD PTR [rbx+0x20],0x0
    67c3:	mov    QWORD PTR [rbx+0x28],0x0
    67cb:	mov    QWORD PTR [rbx+0x30],0x0
    67d3:	mov    QWORD PTR [rbx],rsi
    67d6:	mov    QWORD PTR [rbx+0x8],rdx
    67da:	mov    r13,rdx
    67dd:	mov    rdi,r12
    67e0:	call   67e5 <botlish_fn_55+0x88>
			67e1: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    67e5:	mov    rcx,rax
    67e8:	mov    r14,rax
    67eb:	test   rax,rcx
    67ee:	jne    67fc <botlish_fn_55+0x9f>
    67f4:	mov    rdi,r12
    67f7:	jmp    695c <botlish_fn_55+0x1ff>
    67fc:	mov    rax,r14
    67ff:	mov    QWORD PTR [rbx],rax
    6802:	mov    rsi,r14
    6805:	mov    rdi,r12
    6808:	call   680d <botlish_fn_55+0xb0>
			6809: R_X86_64_PLT32	rt_list_len-0x4
    680d:	sar    rax,1
    6810:	test   rax,rax
    6813:	je     6942 <botlish_fn_55+0x1e5>
    6819:	mov    rax,r14
    681c:	mov    rax,QWORD PTR [rax+0x8]
    6820:	test   rax,rax
    6823:	jne    6852 <botlish_fn_55+0xf5>
    6829:	mov    edx,0x1
    682e:	mov    rsi,r14
    6831:	mov    rdi,r12
    6834:	call   6839 <botlish_fn_55+0xdc>
			6835: R_X86_64_PLT32	rt_list_get-0x4
    6839:	test   rax,rax
    683c:	jne    684a <botlish_fn_55+0xed>
    6842:	mov    rdi,r12
    6845:	jmp    695c <botlish_fn_55+0x1ff>
    684a:	mov    rsi,rax
    684d:	jmp    685f <botlish_fn_55+0x102>
    6852:	mov    rax,r14
    6855:	mov    rdx,QWORD PTR [rax+0x10]
    6859:	mov    rdx,QWORD PTR [rdx]
    685c:	mov    rsi,rdx
    685f:	mov    QWORD PTR [rbx+0x10],rsi
    6863:	mov    QWORD PTR [rbx+0x18],0x3
    686b:	xor    eax,eax
    686d:	test   rsi,0x7
    6874:	jne    6885 <botlish_fn_55+0x128>
    687a:	movzx  r8,BYTE PTR [rsi]
    687e:	cmp    r8b,0x3
    6882:	sete   al
    6885:	test   al,al
    6887:	jne    68aa <botlish_fn_55+0x14d>
    688d:	mov    rdi,r12
    6890:	mov    rax,QWORD PTR [rdi+0x10]
    6894:	mov    rcx,QWORD PTR [rax+0x58]
    6898:	mov    edx,0x4
    689d:	call   68a2 <botlish_fn_55+0x145>
			689e: R_X86_64_PLT32	rt_type_error-0x4
    68a2:	mov    rdi,r12
    68a5:	jmp    695c <botlish_fn_55+0x1ff>
    68aa:	mov    r15,rsi
    68ad:	mov    rdi,r12
    68b0:	call   68b5 <botlish_fn_55+0x158>
			68b1: R_X86_64_PLT32	rt_list_len-0x4
    68b5:	mov    QWORD PTR [rbx+0x20],rax
    68b9:	mov    QWORD PTR [rsp+0x10],rax
    68be:	mov    rdi,r12
    68c1:	call   68c6 <botlish_fn_55+0x169>
			68c2: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    68c6:	test   rax,rax
    68c9:	jne    68d7 <botlish_fn_55+0x17a>
    68cf:	mov    rdi,r12
    68d2:	jmp    695c <botlish_fn_55+0x1ff>
    68d7:	mov    QWORD PTR [rbx+0x28],rax
    68db:	mov    r9,rax
    68de:	mov    QWORD PTR [rbx+0x30],rdx
    68e2:	mov    rsi,rdx
    68e5:	mov    edx,0x3
    68ea:	mov    QWORD PTR [rsp],rsi
    68ee:	mov    rax,r13
    68f1:	mov    QWORD PTR [rsp+0x8],rax
    68f6:	mov    rcx,r15
    68f9:	mov    rsi,r14
    68fc:	mov    r8,QWORD PTR [rsp+0x10]
    6901:	mov    rdi,r12
    6904:	call   6909 <botlish_fn_55+0x1ac>
			6905: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    6909:	test   rax,rax
    690c:	jne    691a <botlish_fn_55+0x1bd>
    6912:	mov    rdi,r12
    6915:	jmp    695c <botlish_fn_55+0x1ff>
    691a:	mov    rdi,r12
    691d:	mov    QWORD PTR [rdi],rbx
    6920:	mov    rbx,QWORD PTR [rsp+0x20]
    6925:	mov    r12,QWORD PTR [rsp+0x28]
    692a:	mov    r13,QWORD PTR [rsp+0x30]
    692f:	mov    r14,QWORD PTR [rsp+0x38]
    6934:	mov    r15,QWORD PTR [rsp+0x40]
    6939:	add    rsp,0x50
    693d:	mov    rsp,rbp
    6940:	pop    rbp
    6941:	ret
    6942:	xor    rdx,rdx
    6945:	mov    rdi,r12
    6948:	mov    rsi,rdx
    694b:	call   6950 <botlish_fn_55+0x1f3>
			694c: R_X86_64_PLT32	rt_list_new-0x4
    6950:	test   rax,rax
    6953:	jne    6987 <botlish_fn_55+0x22a>
    6959:	mov    rdi,r12
    695c:	mov    rdi,r12
    695f:	mov    QWORD PTR [rdi],rbx
    6962:	xor    rax,rax
    6965:	mov    rbx,QWORD PTR [rsp+0x20]
    696a:	mov    r12,QWORD PTR [rsp+0x28]
    696f:	mov    r13,QWORD PTR [rsp+0x30]
    6974:	mov    r14,QWORD PTR [rsp+0x38]
    6979:	mov    r15,QWORD PTR [rsp+0x40]
    697e:	add    rsp,0x50
    6982:	mov    rsp,rbp
    6985:	pop    rbp
    6986:	ret
    6987:	mov    rdi,r12
    698a:	mov    QWORD PTR [rdi],rbx
    698d:	mov    rbx,QWORD PTR [rsp+0x20]
    6992:	mov    r12,QWORD PTR [rsp+0x28]
    6997:	mov    r13,QWORD PTR [rsp+0x30]
    699c:	mov    r14,QWORD PTR [rsp+0x38]
    69a1:	mov    r15,QWORD PTR [rsp+0x40]
    69a6:	add    rsp,0x50
    69aa:	mov    rsp,rbp
    69ad:	pop    rbp
    69ae:	ret
    69af:	mov    r12,rdi
    69b2:	call   69b7 <botlish_fn_55+0x25a>
			69b3: R_X86_64_PLT32	rt_stack_overflow-0x4
    69b7:	xor    rax,rax
    69ba:	mov    rbx,QWORD PTR [rsp+0x20]
    69bf:	mov    r12,QWORD PTR [rsp+0x28]
    69c4:	mov    r13,QWORD PTR [rsp+0x30]
    69c9:	mov    r14,QWORD PTR [rsp+0x38]
    69ce:	mov    r15,QWORD PTR [rsp+0x40]
    69d3:	add    rsp,0x50
    69d7:	mov    rsp,rbp
    69da:	pop    rbp
    69db:	ret

00000000000069dc <botlish_entry_55: csv_records_generic<str, bool>>:
    69dc:	push   rbp
    69dd:	mov    rbp,rsp
    69e0:	mov    rsi,QWORD PTR [rdx]
    69e3:	mov    rdx,QWORD PTR [rdx+0x8]
    69e7:	call   69ec <botlish_entry_55+0x10>
			69e8: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    69ec:	mov    rsp,rbp
    69ef:	pop    rbp
    69f0:	ret

00000000000069f1 <botlish_fn_56: csv_records<str>>:
    69f1:	push   rbp
    69f2:	mov    rbp,rsp
    69f5:	sub    rsp,0x10
    69f9:	mov    QWORD PTR [rsp],r13
    69fd:	mov    QWORD PTR [rsp+0x8],r14
    6a02:	mov    r13,QWORD PTR [rdi]
    6a05:	mov    rax,QWORD PTR [rdi+0x8]
    6a09:	lea    rcx,[r13+0x10]
    6a0d:	cmp    rcx,rax
    6a10:	ja     6a85 <botlish_fn_56+0x94>
    6a16:	lea    rax,[r13+0x10]
    6a1a:	mov    QWORD PTR [rdi],rax
    6a1d:	mov    r14,rdi
    6a20:	mov    QWORD PTR [r13+0x0],0x0
    6a28:	mov    QWORD PTR [r13+0x8],0x0
    6a30:	mov    QWORD PTR [r13+0x0],rsi
    6a34:	mov    edx,0x2
    6a39:	mov    QWORD PTR [r13+0x8],0x2
    6a41:	mov    rdi,r14
    6a44:	call   6a49 <botlish_fn_56+0x58>
			6a45: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    6a49:	test   rax,rax
    6a4c:	jne    6a6d <botlish_fn_56+0x7c>
    6a52:	mov    rdi,r14
    6a55:	mov    QWORD PTR [rdi],r13
    6a58:	xor    rax,rax
    6a5b:	mov    r13,QWORD PTR [rsp]
    6a5f:	mov    r14,QWORD PTR [rsp+0x8]
    6a64:	add    rsp,0x10
    6a68:	mov    rsp,rbp
    6a6b:	pop    rbp
    6a6c:	ret
    6a6d:	mov    rdi,r14
    6a70:	mov    QWORD PTR [rdi],r13
    6a73:	mov    r13,QWORD PTR [rsp]
    6a77:	mov    r14,QWORD PTR [rsp+0x8]
    6a7c:	add    rsp,0x10
    6a80:	mov    rsp,rbp
    6a83:	pop    rbp
    6a84:	ret
    6a85:	call   6a8a <botlish_fn_56+0x99>
			6a86: R_X86_64_PLT32	rt_stack_overflow-0x4
    6a8a:	xor    rax,rax
    6a8d:	mov    r13,QWORD PTR [rsp]
    6a91:	mov    r14,QWORD PTR [rsp+0x8]
    6a96:	add    rsp,0x10
    6a9a:	mov    rsp,rbp
    6a9d:	pop    rbp
    6a9e:	ret

0000000000006a9f <botlish_entry_56: csv_records<str>>:
    6a9f:	push   rbp
    6aa0:	mov    rbp,rsp
    6aa3:	mov    rsi,QWORD PTR [rdx]
    6aa6:	call   6aab <botlish_entry_56+0xc>
			6aa7: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    6aab:	mov    rsp,rbp
    6aae:	pop    rbp
    6aaf:	ret

0000000000006ab0 <botlish_fn_57: csv_records_presized<str>>:
    6ab0:	push   rbp
    6ab1:	mov    rbp,rsp
    6ab4:	sub    rsp,0x10
    6ab8:	mov    QWORD PTR [rsp],r13
    6abc:	mov    QWORD PTR [rsp+0x8],r14
    6ac1:	mov    r13,QWORD PTR [rdi]
    6ac4:	mov    rax,QWORD PTR [rdi+0x8]
    6ac8:	lea    rcx,[r13+0x10]
    6acc:	cmp    rcx,rax
    6acf:	ja     6b44 <botlish_fn_57+0x94>
    6ad5:	lea    rax,[r13+0x10]
    6ad9:	mov    QWORD PTR [rdi],rax
    6adc:	mov    r14,rdi
    6adf:	mov    QWORD PTR [r13+0x0],0x0
    6ae7:	mov    QWORD PTR [r13+0x8],0x0
    6aef:	mov    QWORD PTR [r13+0x0],rsi
    6af3:	mov    edx,0x6
    6af8:	mov    QWORD PTR [r13+0x8],0x6
    6b00:	mov    rdi,r14
    6b03:	call   6b08 <botlish_fn_57+0x58>
			6b04: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    6b08:	test   rax,rax
    6b0b:	jne    6b2c <botlish_fn_57+0x7c>
    6b11:	mov    rdi,r14
    6b14:	mov    QWORD PTR [rdi],r13
    6b17:	xor    rax,rax
    6b1a:	mov    r13,QWORD PTR [rsp]
    6b1e:	mov    r14,QWORD PTR [rsp+0x8]
    6b23:	add    rsp,0x10
    6b27:	mov    rsp,rbp
    6b2a:	pop    rbp
    6b2b:	ret
    6b2c:	mov    rdi,r14
    6b2f:	mov    QWORD PTR [rdi],r13
    6b32:	mov    r13,QWORD PTR [rsp]
    6b36:	mov    r14,QWORD PTR [rsp+0x8]
    6b3b:	add    rsp,0x10
    6b3f:	mov    rsp,rbp
    6b42:	pop    rbp
    6b43:	ret
    6b44:	call   6b49 <botlish_fn_57+0x99>
			6b45: R_X86_64_PLT32	rt_stack_overflow-0x4
    6b49:	xor    rax,rax
    6b4c:	mov    r13,QWORD PTR [rsp]
    6b50:	mov    r14,QWORD PTR [rsp+0x8]
    6b55:	add    rsp,0x10
    6b59:	mov    rsp,rbp
    6b5c:	pop    rbp
    6b5d:	ret

0000000000006b5e <botlish_entry_57: csv_records_presized<str>>:
    6b5e:	push   rbp
    6b5f:	mov    rbp,rsp
    6b62:	mov    rsi,QWORD PTR [rdx]
    6b65:	call   6b6a <botlish_entry_57+0xc>
			6b66: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    6b6a:	mov    rsp,rbp
    6b6d:	pop    rbp
    6b6e:	ret
	...

0000000000006b70 <botlish_fn_58: sample<generic>>:
    6b70:	push   rbp
    6b71:	mov    rbp,rsp
    6b74:	sub    rsp,0x90
    6b7b:	mov    QWORD PTR [rsp+0x60],rbx
    6b80:	mov    QWORD PTR [rsp+0x68],r12
    6b85:	mov    QWORD PTR [rsp+0x70],r13
    6b8a:	mov    QWORD PTR [rsp+0x78],r14
    6b8f:	mov    QWORD PTR [rsp+0x80],r15
    6b97:	mov    r14,QWORD PTR [rdi]
    6b9a:	mov    rax,QWORD PTR [rdi+0x8]
    6b9e:	lea    rcx,[r14+0x40]
    6ba2:	cmp    rcx,rax
    6ba5:	ja     7044 <botlish_fn_58+0x4d4>
    6bab:	lea    rax,[r14+0x40]
    6baf:	mov    QWORD PTR [rdi],rax
    6bb2:	mov    QWORD PTR [r14],0x0
    6bb9:	mov    QWORD PTR [r14+0x8],0x0
    6bc1:	mov    QWORD PTR [r14+0x10],0x0
    6bc9:	mov    QWORD PTR [r14+0x18],0x0
    6bd1:	mov    QWORD PTR [r14+0x20],0x0
    6bd9:	mov    QWORD PTR [r14+0x28],0x0
    6be1:	mov    QWORD PTR [r14+0x30],0x0
    6be9:	mov    QWORD PTR [r14+0x38],0x0
    6bf1:	mov    rax,QWORD PTR [rdi+0x10]
    6bf5:	mov    r15,rdi
    6bf8:	mov    rsi,QWORD PTR [rax+0x60]
    6bfc:	mov    QWORD PTR [r14],rsi
    6bff:	call   6c04 <botlish_fn_58+0x94>
			6c00: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    6c04:	mov    rcx,rax
    6c07:	mov    r13,rax
    6c0a:	test   rax,rcx
    6c0d:	jne    6c1b <botlish_fn_58+0xab>
    6c13:	mov    rdi,r15
    6c16:	jmp    6fe5 <botlish_fn_58+0x475>
    6c1b:	mov    rax,r13
    6c1e:	mov    QWORD PTR [r14],rax
    6c21:	mov    rdi,r15
    6c24:	mov    rax,QWORD PTR [rdi+0x10]
    6c28:	mov    rsi,QWORD PTR [rax+0x60]
    6c2c:	mov    QWORD PTR [r14+0x8],rsi
    6c30:	call   6c35 <botlish_fn_58+0xc5>
			6c31: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    6c35:	mov    r12,rax
    6c38:	test   r12,r12
    6c3b:	jne    6c49 <botlish_fn_58+0xd9>
    6c41:	mov    rdi,r15
    6c44:	jmp    6fe5 <botlish_fn_58+0x475>
    6c49:	mov    rax,r13
    6c4c:	mov    rax,QWORD PTR [rax+0x8]
    6c50:	test   rax,rax
    6c53:	jne    6c85 <botlish_fn_58+0x115>
    6c59:	mov    edx,0x1
    6c5e:	mov    rsi,r13
    6c61:	mov    rdi,r15
    6c64:	call   6c69 <botlish_fn_58+0xf9>
			6c65: R_X86_64_PLT32	rt_list_get-0x4
    6c69:	test   rax,rax
    6c6c:	jne    6c7a <botlish_fn_58+0x10a>
    6c72:	mov    rdi,r15
    6c75:	jmp    6fe5 <botlish_fn_58+0x475>
    6c7a:	mov    rbx,r13
    6c7d:	mov    rsi,rax
    6c80:	jmp    6c8f <botlish_fn_58+0x11f>
    6c85:	mov    rbx,r13
    6c88:	mov    rax,QWORD PTR [rbx+0x10]
    6c8c:	mov    rsi,QWORD PTR [rax]
    6c8f:	mov    QWORD PTR [r14+0x8],rsi
    6c93:	mov    QWORD PTR [rsp+0x40],rsi
    6c98:	mov    rax,QWORD PTR [rbx+0x8]
    6c9c:	cmp    rax,0x1
    6ca0:	ja     6cd2 <botlish_fn_58+0x162>
    6ca6:	mov    edx,0x3
    6cab:	mov    rsi,rbx
    6cae:	mov    rdi,r15
    6cb1:	call   6cb6 <botlish_fn_58+0x146>
			6cb2: R_X86_64_PLT32	rt_list_get-0x4
    6cb6:	test   rax,rax
    6cb9:	jne    6cc7 <botlish_fn_58+0x157>
    6cbf:	mov    rdi,r15
    6cc2:	jmp    6fe5 <botlish_fn_58+0x475>
    6cc7:	mov    rsi,rax
    6cca:	mov    r13,rbx
    6ccd:	jmp    6cdd <botlish_fn_58+0x16d>
    6cd2:	mov    rax,QWORD PTR [rbx+0x10]
    6cd6:	mov    r13,rbx
    6cd9:	mov    rsi,QWORD PTR [rax+0x8]
    6cdd:	mov    QWORD PTR [r14+0x10],rsi
    6ce1:	mov    QWORD PTR [rsp+0x38],rsi
    6ce6:	mov    rax,QWORD PTR [r12+0x8]
    6ceb:	mov    rsi,r12
    6cee:	test   rax,rax
    6cf1:	jne    6d1d <botlish_fn_58+0x1ad>
    6cf7:	mov    edx,0x1
    6cfc:	mov    rdi,r15
    6cff:	call   6d04 <botlish_fn_58+0x194>
			6d00: R_X86_64_PLT32	rt_list_get-0x4
    6d04:	test   rax,rax
    6d07:	jne    6d15 <botlish_fn_58+0x1a5>
    6d0d:	mov    rdi,r15
    6d10:	jmp    6fe5 <botlish_fn_58+0x475>
    6d15:	mov    rsi,rax
    6d18:	jmp    6d24 <botlish_fn_58+0x1b4>
    6d1d:	mov    rax,QWORD PTR [rsi+0x10]
    6d21:	mov    rsi,QWORD PTR [rax]
    6d24:	mov    QWORD PTR [r14+0x18],rsi
    6d28:	mov    rdi,r15
    6d2b:	mov    r12,rsi
    6d2e:	mov    rax,QWORD PTR [rdi+0x10]
    6d32:	mov    rdx,QWORD PTR [rax+0x68]
    6d36:	mov    QWORD PTR [r14+0x20],rdx
    6d3a:	mov    rsi,QWORD PTR [rsp+0x40]
    6d3f:	call   6d44 <botlish_fn_58+0x1d4>
			6d40: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6d44:	test   rax,rax
    6d47:	jne    6d55 <botlish_fn_58+0x1e5>
    6d4d:	mov    rdi,r15
    6d50:	jmp    6fe5 <botlish_fn_58+0x475>
    6d55:	mov    QWORD PTR [r14+0x20],rax
    6d59:	mov    rbx,rax
    6d5c:	mov    rdi,r15
    6d5f:	mov    rsi,QWORD PTR [rdi+0x10]
    6d63:	mov    rdx,QWORD PTR [rsi+0x68]
    6d67:	mov    QWORD PTR [r14+0x28],rdx
    6d6b:	mov    rsi,r12
    6d6e:	call   6d73 <botlish_fn_58+0x203>
			6d6f: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6d73:	test   rax,rax
    6d76:	jne    6d84 <botlish_fn_58+0x214>
    6d7c:	mov    rdi,r15
    6d7f:	jmp    6fe5 <botlish_fn_58+0x475>
    6d84:	mov    rcx,rbx
    6d87:	mov    r8,rcx
    6d8a:	and    r8,rax
    6d8d:	mov    rdx,rax
    6d90:	test   r8,0x1
    6d97:	jne    6db9 <botlish_fn_58+0x249>
    6d9d:	mov    rsi,rbx
    6da0:	mov    rdi,r15
    6da3:	call   6da8 <botlish_fn_58+0x238>
			6da4: R_X86_64_PLT32	rt_value_eq-0x4
    6da8:	test   rax,rax
    6dab:	jne    6dcc <botlish_fn_58+0x25c>
    6db1:	mov    rdi,r15
    6db4:	jmp    6fe5 <botlish_fn_58+0x475>
    6db9:	mov    rsi,rbx
    6dbc:	mov    eax,0x2
    6dc1:	cmp    rsi,rdx
    6dc4:	cmove  rax,QWORD PTR [rip+0x2ac]        # 7078 <botlish_fn_58+0x508>
    6dcc:	mov    ebx,0x6
    6dd1:	cmp    rax,0x6
    6dd5:	je     6def <botlish_fn_58+0x27f>
    6ddb:	mov    ebx,0x2
    6de0:	mov    QWORD PTR [r14],0x2
    6de7:	mov    rsi,r13
    6dea:	jmp    6e90 <botlish_fn_58+0x320>
    6def:	mov    rsi,QWORD PTR [rsp+0x40]
    6df4:	mov    rdi,r15
    6df7:	call   6dfc <botlish_fn_58+0x28c>
			6df8: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    6dfc:	test   rax,rax
    6dff:	jne    6e0d <botlish_fn_58+0x29d>
    6e05:	mov    rdi,r15
    6e08:	jmp    6fe5 <botlish_fn_58+0x475>
    6e0d:	mov    QWORD PTR [r14+0x20],rax
    6e11:	mov    rsi,r12
    6e14:	mov    r12,rax
    6e17:	mov    rdi,r15
    6e1a:	call   6e1f <botlish_fn_58+0x2af>
			6e1b: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    6e1f:	test   rax,rax
    6e22:	jne    6e30 <botlish_fn_58+0x2c0>
    6e28:	mov    rdi,r15
    6e2b:	jmp    6fe5 <botlish_fn_58+0x475>
    6e30:	mov    rcx,r12
    6e33:	mov    rdx,rcx
    6e36:	and    rdx,rax
    6e39:	test   rdx,0x1
    6e40:	jne    6e65 <botlish_fn_58+0x2f5>
    6e46:	mov    rdx,rax
    6e49:	mov    rsi,r12
    6e4c:	mov    rdi,r15
    6e4f:	call   6e54 <botlish_fn_58+0x2e4>
			6e50: R_X86_64_PLT32	rt_value_eq-0x4
    6e54:	test   rax,rax
    6e57:	jne    6e7b <botlish_fn_58+0x30b>
    6e5d:	mov    rdi,r15
    6e60:	jmp    6fe5 <botlish_fn_58+0x475>
    6e65:	mov    rdx,rax
    6e68:	mov    rsi,r12
    6e6b:	mov    eax,0x2
    6e70:	cmp    rsi,rdx
    6e73:	cmove  rax,QWORD PTR [rip+0x1fd]        # 7078 <botlish_fn_58+0x508>
    6e7b:	cmp    rax,0x6
    6e7f:	je     6e8a <botlish_fn_58+0x31a>
    6e85:	mov    ebx,0x2
    6e8a:	mov    QWORD PTR [r14],rbx
    6e8d:	mov    rsi,r13
    6e90:	mov    rdi,r15
    6e93:	call   6e98 <botlish_fn_58+0x328>
			6e94: R_X86_64_PLT32	rt_list_len-0x4
    6e98:	mov    r12,rax
    6e9b:	mov    QWORD PTR [r14+0x18],r12
    6e9f:	mov    rdi,r15
    6ea2:	mov    rax,QWORD PTR [rdi+0x10]
    6ea6:	mov    rdx,QWORD PTR [rax+0x68]
    6eaa:	mov    QWORD PTR [r14+0x20],rdx
    6eae:	mov    rsi,QWORD PTR [rsp+0x40]
    6eb3:	call   6eb8 <botlish_fn_58+0x348>
			6eb4: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6eb8:	mov    r13,rax
    6ebb:	test   r13,r13
    6ebe:	jne    6ecc <botlish_fn_58+0x35c>
    6ec4:	mov    rdi,r15
    6ec7:	jmp    6fe5 <botlish_fn_58+0x475>
    6ecc:	mov    QWORD PTR [r14+0x20],r13
    6ed0:	mov    rdi,r15
    6ed3:	mov    rax,QWORD PTR [rdi+0x10]
    6ed7:	mov    rdx,QWORD PTR [rax+0x70]
    6edb:	mov    QWORD PTR [r14+0x28],rdx
    6edf:	mov    rsi,QWORD PTR [rsp+0x40]
    6ee4:	call   6ee9 <botlish_fn_58+0x379>
			6ee5: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6ee9:	test   rax,rax
    6eec:	jne    6efa <botlish_fn_58+0x38a>
    6ef2:	mov    rdi,r15
    6ef5:	jmp    6fe5 <botlish_fn_58+0x475>
    6efa:	mov    QWORD PTR [r14+0x28],rax
    6efe:	mov    rdi,r15
    6f01:	mov    QWORD PTR [rsp+0x50],rax
    6f06:	mov    rax,QWORD PTR [rdi+0x10]
    6f0a:	mov    rdx,QWORD PTR [rax+0x78]
    6f0e:	mov    QWORD PTR [r14+0x30],rdx
    6f12:	mov    rsi,QWORD PTR [rsp+0x40]
    6f17:	call   6f1c <botlish_fn_58+0x3ac>
			6f18: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6f1c:	test   rax,rax
    6f1f:	jne    6f2d <botlish_fn_58+0x3bd>
    6f25:	mov    rdi,r15
    6f28:	jmp    6fe5 <botlish_fn_58+0x475>
    6f2d:	mov    QWORD PTR [r14+0x8],rax
    6f31:	mov    rdi,r15
    6f34:	mov    QWORD PTR [rsp+0x48],rax
    6f39:	mov    rax,QWORD PTR [rdi+0x10]
    6f3d:	mov    rdx,QWORD PTR [rax+0x68]
    6f41:	mov    QWORD PTR [r14+0x30],rdx
    6f45:	mov    rsi,QWORD PTR [rsp+0x38]
    6f4a:	call   6f4f <botlish_fn_58+0x3df>
			6f4b: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6f4f:	test   rax,rax
    6f52:	jne    6f60 <botlish_fn_58+0x3f0>
    6f58:	mov    rdi,r15
    6f5b:	jmp    6fe5 <botlish_fn_58+0x475>
    6f60:	mov    QWORD PTR [r14+0x30],rax
    6f64:	mov    rdi,r15
    6f67:	mov    QWORD PTR [rsp+0x40],rax
    6f6c:	mov    rax,QWORD PTR [rdi+0x10]
    6f70:	mov    rdx,QWORD PTR [rax+0x78]
    6f74:	mov    QWORD PTR [r14+0x38],rdx
    6f78:	mov    rsi,QWORD PTR [rsp+0x38]
    6f7d:	call   6f82 <botlish_fn_58+0x412>
			6f7e: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    6f82:	test   rax,rax
    6f85:	jne    6f93 <botlish_fn_58+0x423>
    6f8b:	mov    rdi,r15
    6f8e:	jmp    6fe5 <botlish_fn_58+0x475>
    6f93:	mov    QWORD PTR [r14+0x10],rax
    6f97:	lea    rdx,[rsp]
    6f9b:	mov    QWORD PTR [rsp],r12
    6f9f:	mov    QWORD PTR [rsp+0x8],r13
    6fa4:	mov    rcx,QWORD PTR [rsp+0x50]
    6fa9:	mov    QWORD PTR [rsp+0x10],rcx
    6fae:	mov    rcx,QWORD PTR [rsp+0x48]
    6fb3:	mov    QWORD PTR [rsp+0x18],rcx
    6fb8:	mov    rcx,QWORD PTR [rsp+0x40]
    6fbd:	mov    QWORD PTR [rsp+0x20],rcx
    6fc2:	mov    QWORD PTR [rsp+0x28],rax
    6fc7:	mov    QWORD PTR [rsp+0x30],rbx
    6fcc:	mov    esi,0x7
    6fd1:	mov    rdi,r15
    6fd4:	call   6fd9 <botlish_fn_58+0x469>
			6fd5: R_X86_64_PLT32	rt_list_new-0x4
    6fd9:	test   rax,rax
    6fdc:	jne    7016 <botlish_fn_58+0x4a6>
    6fe2:	mov    rdi,r15
    6fe5:	mov    rdi,r15
    6fe8:	mov    QWORD PTR [rdi],r14
    6feb:	xor    rax,rax
    6fee:	mov    rbx,QWORD PTR [rsp+0x60]
    6ff3:	mov    r12,QWORD PTR [rsp+0x68]
    6ff8:	mov    r13,QWORD PTR [rsp+0x70]
    6ffd:	mov    r14,QWORD PTR [rsp+0x78]
    7002:	mov    r15,QWORD PTR [rsp+0x80]
    700a:	add    rsp,0x90
    7011:	mov    rsp,rbp
    7014:	pop    rbp
    7015:	ret
    7016:	mov    rdi,r15
    7019:	mov    QWORD PTR [rdi],r14
    701c:	mov    rbx,QWORD PTR [rsp+0x60]
    7021:	mov    r12,QWORD PTR [rsp+0x68]
    7026:	mov    r13,QWORD PTR [rsp+0x70]
    702b:	mov    r14,QWORD PTR [rsp+0x78]
    7030:	mov    r15,QWORD PTR [rsp+0x80]
    7038:	add    rsp,0x90
    703f:	mov    rsp,rbp
    7042:	pop    rbp
    7043:	ret
    7044:	mov    r15,rdi
    7047:	call   704c <botlish_fn_58+0x4dc>
			7048: R_X86_64_PLT32	rt_stack_overflow-0x4
    704c:	xor    rax,rax
    704f:	mov    rbx,QWORD PTR [rsp+0x60]
    7054:	mov    r12,QWORD PTR [rsp+0x68]
    7059:	mov    r13,QWORD PTR [rsp+0x70]
    705e:	mov    r14,QWORD PTR [rsp+0x78]
    7063:	mov    r15,QWORD PTR [rsp+0x80]
    706b:	add    rsp,0x90
    7072:	mov    rsp,rbp
    7075:	pop    rbp
    7076:	ret
    7077:	add    BYTE PTR [rsi],al
    7079:	add    BYTE PTR [rax],al
    707b:	add    BYTE PTR [rax],al
    707d:	add    BYTE PTR [rax],al
	...

0000000000007080 <botlish_entry_58: sample<generic>>:
    7080:	push   rbp
    7081:	mov    rbp,rsp
    7084:	call   7089 <botlish_entry_58+0x9>
			7085: R_X86_64_PLT32	botlish_fn_58-0x4 ; sample<generic>
    7089:	mov    rsp,rbp
    708c:	pop    rbp
    708d:	ret

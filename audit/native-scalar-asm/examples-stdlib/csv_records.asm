; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 30762  (per function: 172 271 485 541 571 571 571 332 493 558 697 913 481 828 556 268 85 85 85 85 548 696 208 597 278 184 255 184 255 184 255 184 255 184 269 269 299 299 355 355 1036 1568 581 596 708 1276 1124 961 833 1528 1132 243 796 474 724 663 196 196 1366)
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
      ad:	sub    rsp,0x20
      b1:	mov    QWORD PTR [rsp+0x10],rbx
      b6:	mov    QWORD PTR [rsp+0x18],r12
      bb:	mov    rbx,QWORD PTR [rdi]
      be:	mov    rax,QWORD PTR [rdi+0x8]
      c2:	lea    rcx,[rbx+0x10]
      c6:	cmp    rcx,rax
      c9:	ja     17f <botlish_fn_1+0xd6>
      cf:	lea    rax,[rbx+0x10]
      d3:	mov    QWORD PTR [rdi],rax
      d6:	mov    r12,rdi
      d9:	mov    QWORD PTR [rbx],0x0
      e0:	mov    QWORD PTR [rbx+0x8],0x0
      e8:	mov    esi,0x1
      ed:	mov    QWORD PTR [rbx],0x1
      f4:	mov    rax,QWORD PTR [rip+0x0]        # fb <botlish_fn_1+0x52>
			f7: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
      fb:	mov    rdi,r12
      fe:	call   rax
     100:	test   rax,rax
     103:	jne    111 <botlish_fn_1+0x68>
     109:	mov    rdi,r12
     10c:	jmp    14a <botlish_fn_1+0xa1>
     111:	mov    QWORD PTR [rbx],rax
     114:	mov    QWORD PTR [rbx+0x8],0x1
     11c:	lea    rdx,[rsp]
     120:	mov    QWORD PTR [rsp],rax
     124:	mov    QWORD PTR [rsp+0x8],0x1
     12d:	mov    esi,0x2
     132:	mov    rax,QWORD PTR [rip+0x0]        # 139 <botlish_fn_1+0x90>
			135: R_X86_64_GOTPCREL	rt_list_new-0x4
     139:	mov    rdi,r12
     13c:	call   rax
     13e:	test   rax,rax
     141:	jne    166 <botlish_fn_1+0xbd>
     147:	mov    rdi,r12
     14a:	mov    rdi,r12
     14d:	mov    QWORD PTR [rdi],rbx
     150:	xor    rax,rax
     153:	mov    rbx,QWORD PTR [rsp+0x10]
     158:	mov    r12,QWORD PTR [rsp+0x18]
     15d:	add    rsp,0x20
     161:	mov    rsp,rbp
     164:	pop    rbp
     165:	ret
     166:	mov    rdi,r12
     169:	mov    QWORD PTR [rdi],rbx
     16c:	mov    rbx,QWORD PTR [rsp+0x10]
     171:	mov    r12,QWORD PTR [rsp+0x18]
     176:	add    rsp,0x20
     17a:	mov    rsp,rbp
     17d:	pop    rbp
     17e:	ret
     17f:	mov    r12,rdi
     182:	mov    rax,QWORD PTR [rip+0x0]        # 189 <botlish_fn_1+0xe0>
			185: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     189:	call   rax
     18b:	xor    rax,rax
     18e:	mov    rbx,QWORD PTR [rsp+0x10]
     193:	mov    r12,QWORD PTR [rsp+0x18]
     198:	add    rsp,0x20
     19c:	mov    rsp,rbp
     19f:	pop    rbp
     1a0:	ret

00000000000001a1 <botlish_entry_1: geo_new<generic>>:
     1a1:	push   rbp
     1a2:	mov    rbp,rsp
     1a5:	call   1aa <botlish_entry_1+0x9>
			1a6: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
     1aa:	mov    rsp,rbp
     1ad:	pop    rbp
     1ae:	ret
	...

00000000000001b0 <botlish_fn_2: geo_new_capacity<int, int>>:
     1b0:	push   rbp
     1b1:	mov    rbp,rsp
     1b4:	sub    rsp,0x20
     1b8:	mov    QWORD PTR [rsp],rbx
     1bc:	mov    QWORD PTR [rsp+0x8],r12
     1c1:	mov    QWORD PTR [rsp+0x10],r13
     1c6:	mov    QWORD PTR [rsp+0x18],r14
     1cb:	mov    rbx,QWORD PTR [rdi]
     1ce:	mov    rax,QWORD PTR [rdi+0x8]
     1d2:	lea    rcx,[rbx+0x18]
     1d6:	cmp    rcx,rax
     1d9:	ja     335 <botlish_fn_2+0x185>
     1df:	lea    rax,[rbx+0x18]
     1e3:	mov    QWORD PTR [rdi],rax
     1e6:	mov    r13,rdi
     1e9:	mov    QWORD PTR [rbx],0x0
     1f0:	mov    QWORD PTR [rbx+0x8],0x0
     1f8:	mov    QWORD PTR [rbx+0x10],0x0
     200:	mov    QWORD PTR [rbx],rsi
     203:	mov    QWORD PTR [rbx+0x8],rdx
     207:	mov    r12,rdx
     20a:	mov    QWORD PTR [rbx+0x10],0x5
     212:	test   rsi,0x1
     219:	je     23b <botlish_fn_2+0x8b>
     21f:	mov    rax,rsi
     222:	sar    rax,1
     225:	imul   QWORD PTR [rip+0x13c]        # 368 <botlish_fn_2+0x1b8>
     22c:	seto   cl
     22f:	or     rax,0x1
     233:	test   cl,cl
     235:	je     24c <botlish_fn_2+0x9c>
     23b:	mov    edx,0x5
     240:	mov    rax,QWORD PTR [rip+0x0]        # 247 <botlish_fn_2+0x97>
			243: R_X86_64_GOTPCREL	rt_int_mul-0x4
     247:	mov    rdi,r13
     24a:	call   rax
     24c:	mov    rcx,rax
     24f:	and    rcx,r12
     252:	mov    r14,rax
     255:	test   rcx,0x1
     25c:	jne    28c <botlish_fn_2+0xdc>
     262:	mov    rax,QWORD PTR [rip+0x0]        # 269 <botlish_fn_2+0xb9>
			265: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     269:	mov    rdx,r12
     26c:	mov    rsi,r14
     26f:	mov    rdi,r13
     272:	call   rax
     274:	mov    ecx,0x2
     279:	test   rax,rax
     27c:	cmovle rcx,QWORD PTR [rip+0xec]        # 370 <botlish_fn_2+0x1c0>
     284:	mov    rax,r14
     287:	jmp    29f <botlish_fn_2+0xef>
     28c:	mov    ecx,0x2
     291:	mov    rax,r14
     294:	cmp    rax,r12
     297:	cmovle rcx,QWORD PTR [rip+0xd1]        # 370 <botlish_fn_2+0x1c0>
     29f:	cmp    rcx,0x6
     2a3:	je     2cb <botlish_fn_2+0x11b>
     2a9:	mov    rdi,r13
     2ac:	mov    QWORD PTR [rdi],rbx
     2af:	mov    rbx,QWORD PTR [rsp]
     2b3:	mov    r12,QWORD PTR [rsp+0x8]
     2b8:	mov    r13,QWORD PTR [rsp+0x10]
     2bd:	mov    r14,QWORD PTR [rsp+0x18]
     2c2:	add    rsp,0x20
     2c6:	mov    rsp,rbp
     2c9:	pop    rbp
     2ca:	ret
     2cb:	mov    QWORD PTR [rbx],0x3
     2d2:	test   r12,0x1
     2d9:	je     2fb <botlish_fn_2+0x14b>
     2df:	mov    rax,r12
     2e2:	add    rax,0x2
     2e6:	seto   sil
     2ea:	test   sil,sil
     2ed:	jne    2fb <botlish_fn_2+0x14b>
     2f3:	mov    rdi,r13
     2f6:	jmp    313 <botlish_fn_2+0x163>
     2fb:	mov    edx,0x3
     300:	mov    r8,QWORD PTR [rip+0x0]        # 307 <botlish_fn_2+0x157>
			303: R_X86_64_GOTPCREL	rt_int_add-0x4
     307:	mov    rsi,r12
     30a:	mov    rdi,r13
     30d:	call   r8
     310:	mov    rdi,r13
     313:	mov    rdi,r13
     316:	mov    QWORD PTR [rdi],rbx
     319:	mov    rbx,QWORD PTR [rsp]
     31d:	mov    r12,QWORD PTR [rsp+0x8]
     322:	mov    r13,QWORD PTR [rsp+0x10]
     327:	mov    r14,QWORD PTR [rsp+0x18]
     32c:	add    rsp,0x20
     330:	mov    rsp,rbp
     333:	pop    rbp
     334:	ret
     335:	mov    r13,rdi
     338:	mov    r10,QWORD PTR [rip+0x0]        # 33f <botlish_fn_2+0x18f>
			33b: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     33f:	call   r10
     342:	xor    rax,rax
     345:	mov    rbx,QWORD PTR [rsp]
     349:	mov    r12,QWORD PTR [rsp+0x8]
     34e:	mov    r13,QWORD PTR [rsp+0x10]
     353:	mov    r14,QWORD PTR [rsp+0x18]
     358:	add    rsp,0x20
     35c:	mov    rsp,rbp
     35f:	pop    rbp
     360:	ret
     361:	add    BYTE PTR [rax],al
     363:	add    BYTE PTR [rax],al
     365:	add    BYTE PTR [rax],al
     367:	add    BYTE PTR [rax+rax*1],al
     36a:	add    BYTE PTR [rax],al
     36c:	add    BYTE PTR [rax],al
     36e:	add    BYTE PTR [rax],al
     370:	(bad)
     371:	add    BYTE PTR [rax],al
     373:	add    BYTE PTR [rax],al
     375:	add    BYTE PTR [rax],al
	...

0000000000000378 <botlish_entry_2: geo_new_capacity<int, int>>:
     378:	push   rbp
     379:	mov    rbp,rsp
     37c:	mov    rsi,QWORD PTR [rdx]
     37f:	mov    rdx,QWORD PTR [rdx+0x8]
     383:	call   388 <botlish_entry_2+0x10>
			384: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     388:	mov    rsp,rbp
     38b:	pop    rbp
     38c:	ret
     38d:	add    BYTE PTR [rax],al
	...

0000000000000390 <botlish_fn_3: geo_grow<mutarray, int>>:
     390:	push   rbp
     391:	mov    rbp,rsp
     394:	sub    rsp,0x30
     398:	mov    QWORD PTR [rsp],rbx
     39c:	mov    QWORD PTR [rsp+0x8],r12
     3a1:	mov    QWORD PTR [rsp+0x10],r13
     3a6:	mov    QWORD PTR [rsp+0x18],r14
     3ab:	mov    QWORD PTR [rsp+0x20],r15
     3b0:	mov    rbx,QWORD PTR [rdi]
     3b3:	mov    rax,QWORD PTR [rdi+0x8]
     3b7:	lea    rcx,[rbx+0x18]
     3bb:	cmp    rcx,rax
     3be:	ja     550 <botlish_fn_3+0x1c0>
     3c4:	lea    rax,[rbx+0x18]
     3c8:	mov    QWORD PTR [rdi],rax
     3cb:	mov    r13,rdi
     3ce:	mov    QWORD PTR [rbx],0x0
     3d5:	mov    QWORD PTR [rbx+0x8],0x0
     3dd:	mov    QWORD PTR [rbx+0x10],0x0
     3e5:	mov    QWORD PTR [rbx],rsi
     3e8:	mov    r14,rsi
     3eb:	mov    QWORD PTR [rbx+0x8],rdx
     3ef:	mov    r12,rdx
     3f2:	mov    rax,QWORD PTR [rip+0x0]        # 3f9 <botlish_fn_3+0x69>
			3f5: R_X86_64_GOTPCREL	rt_mutarray_capacity-0x4
     3f9:	mov    rsi,r14
     3fc:	mov    rdi,r13
     3ff:	call   rax
     401:	mov    r15,rax
     404:	mov    QWORD PTR [rbx+0x10],rax
     408:	mov    rcx,r12
     40b:	and    rcx,rax
     40e:	test   rcx,0x1
     415:	jne    445 <botlish_fn_3+0xb5>
     41b:	mov    rax,QWORD PTR [rip+0x0]        # 422 <botlish_fn_3+0x92>
			41e: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     422:	mov    rdx,r15
     425:	mov    rsi,r12
     428:	mov    rdi,r13
     42b:	call   rax
     42d:	mov    ecx,0x2
     432:	test   rax,rax
     435:	cmovl  rcx,QWORD PTR [rip+0x143]        # 580 <botlish_fn_3+0x1f0>
     43d:	mov    rax,r15
     440:	jmp    458 <botlish_fn_3+0xc8>
     445:	mov    ecx,0x2
     44a:	mov    rax,r15
     44d:	cmp    r12,rax
     450:	cmovl  rcx,QWORD PTR [rip+0x128]        # 580 <botlish_fn_3+0x1f0>
     458:	cmp    rcx,0x6
     45c:	je     526 <botlish_fn_3+0x196>
     462:	mov    rsi,rax
     465:	mov    rdx,r12
     468:	mov    rdi,r13
     46b:	call   470 <botlish_fn_3+0xe0>
			46c: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     470:	test   rax,rax
     473:	jne    481 <botlish_fn_3+0xf1>
     479:	mov    rdi,r13
     47c:	jmp    4d2 <botlish_fn_3+0x142>
     481:	mov    QWORD PTR [rbx+0x10],rax
     485:	mov    rsi,rax
     488:	mov    rax,QWORD PTR [rip+0x0]        # 48f <botlish_fn_3+0xff>
			48b: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     48f:	mov    rdi,r13
     492:	call   rax
     494:	test   rax,rax
     497:	mov    r15,rax
     49a:	jne    4a8 <botlish_fn_3+0x118>
     4a0:	mov    rdi,r13
     4a3:	jmp    4d2 <botlish_fn_3+0x142>
     4a8:	mov    r8d,0x1
     4ae:	mov    rax,QWORD PTR [rip+0x0]        # 4b5 <botlish_fn_3+0x125>
			4b1: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
     4b5:	mov    rcx,r14
     4b8:	mov    r9,r12
     4bb:	mov    rsi,r15
     4be:	mov    rdi,r13
     4c1:	mov    rdx,r8
     4c4:	call   rax
     4c6:	test   rax,rax
     4c9:	jne    4fc <botlish_fn_3+0x16c>
     4cf:	mov    rdi,r13
     4d2:	mov    rdi,r13
     4d5:	mov    QWORD PTR [rdi],rbx
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
     4fc:	mov    rdi,r13
     4ff:	mov    QWORD PTR [rdi],rbx
     502:	mov    rax,r15
     505:	mov    rbx,QWORD PTR [rsp]
     509:	mov    r12,QWORD PTR [rsp+0x8]
     50e:	mov    r13,QWORD PTR [rsp+0x10]
     513:	mov    r14,QWORD PTR [rsp+0x18]
     518:	mov    r15,QWORD PTR [rsp+0x20]
     51d:	add    rsp,0x30
     521:	mov    rsp,rbp
     524:	pop    rbp
     525:	ret
     526:	mov    rdi,r13
     529:	mov    QWORD PTR [rdi],rbx
     52c:	mov    rax,r14
     52f:	mov    rbx,QWORD PTR [rsp]
     533:	mov    r12,QWORD PTR [rsp+0x8]
     538:	mov    r13,QWORD PTR [rsp+0x10]
     53d:	mov    r14,QWORD PTR [rsp+0x18]
     542:	mov    r15,QWORD PTR [rsp+0x20]
     547:	add    rsp,0x30
     54b:	mov    rsp,rbp
     54e:	pop    rbp
     54f:	ret
     550:	mov    r13,rdi
     553:	mov    rcx,QWORD PTR [rip+0x0]        # 55a <botlish_fn_3+0x1ca>
			556: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     55a:	call   rcx
     55c:	xor    rax,rax
     55f:	mov    rbx,QWORD PTR [rsp]
     563:	mov    r12,QWORD PTR [rsp+0x8]
     568:	mov    r13,QWORD PTR [rsp+0x10]
     56d:	mov    r14,QWORD PTR [rsp+0x18]
     572:	mov    r15,QWORD PTR [rsp+0x20]
     577:	add    rsp,0x30
     57b:	mov    rsp,rbp
     57e:	pop    rbp
     57f:	ret
     580:	(bad)
     581:	add    BYTE PTR [rax],al
     583:	add    BYTE PTR [rax],al
     585:	add    BYTE PTR [rax],al
	...

0000000000000588 <botlish_entry_3: geo_grow<mutarray, int>>:
     588:	push   rbp
     589:	mov    rbp,rsp
     58c:	mov    rsi,QWORD PTR [rdx]
     58f:	mov    rdx,QWORD PTR [rdx+0x8]
     593:	call   598 <botlish_entry_3+0x10>
			594: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     598:	mov    rsp,rbp
     59b:	pop    rbp
     59c:	ret

000000000000059d <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     59d:	push   rbp
     59e:	mov    rbp,rsp
     5a1:	sub    rsp,0x50
     5a5:	mov    QWORD PTR [rsp+0x20],rbx
     5aa:	mov    QWORD PTR [rsp+0x28],r12
     5af:	mov    QWORD PTR [rsp+0x30],r13
     5b4:	mov    QWORD PTR [rsp+0x38],r14
     5b9:	mov    QWORD PTR [rsp+0x40],r15
     5be:	mov    r12,rsi
     5c1:	mov    rbx,QWORD PTR [rdi]
     5c4:	mov    rax,QWORD PTR [rdi+0x8]
     5c8:	lea    rcx,[rbx+0x18]
     5cc:	cmp    rcx,rax
     5cf:	ja     77f <botlish_fn_4+0x1e2>
     5d5:	lea    rax,[rbx+0x18]
     5d9:	mov    QWORD PTR [rdi],rax
     5dc:	mov    r14,rdi
     5df:	mov    QWORD PTR [rbx],0x0
     5e6:	mov    QWORD PTR [rbx+0x8],0x0
     5ee:	mov    QWORD PTR [rbx+0x10],0x0
     5f6:	mov    QWORD PTR [rbx],rdx
     5f9:	mov    r13,rdx
     5fc:	mov    edx,0x1
     601:	mov    rax,QWORD PTR [rip+0x0]        # 608 <botlish_fn_4+0x6b>
			604: R_X86_64_GOTPCREL	rt_list_get-0x4
     608:	mov    rsi,r12
     60b:	mov    rdi,r14
     60e:	call   rax
     610:	test   rax,rax
     613:	jne    621 <botlish_fn_4+0x84>
     619:	mov    rdi,r14
     61c:	jmp    72c <botlish_fn_4+0x18f>
     621:	mov    QWORD PTR [rbx+0x8],rax
     625:	mov    QWORD PTR [rsp+0x10],rax
     62a:	mov    edx,0x3
     62f:	mov    rax,QWORD PTR [rip+0x0]        # 636 <botlish_fn_4+0x99>
			632: R_X86_64_GOTPCREL	rt_list_get-0x4
     636:	mov    rsi,r12
     639:	mov    rdi,r14
     63c:	call   rax
     63e:	mov    rcx,rax
     641:	mov    r15,rax
     644:	test   rax,rcx
     647:	jne    655 <botlish_fn_4+0xb8>
     64d:	mov    rdi,r14
     650:	jmp    72c <botlish_fn_4+0x18f>
     655:	mov    rax,r15
     658:	mov    QWORD PTR [rbx+0x10],rax
     65c:	mov    rsi,QWORD PTR [rsp+0x10]
     661:	mov    rdx,r15
     664:	mov    rdi,r14
     667:	call   66c <botlish_fn_4+0xcf>
			668: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     66c:	mov    r12,rax
     66f:	test   r12,r12
     672:	jne    680 <botlish_fn_4+0xe3>
     678:	mov    rdi,r14
     67b:	jmp    72c <botlish_fn_4+0x18f>
     680:	mov    QWORD PTR [rbx],r12
     683:	mov    rax,QWORD PTR [rip+0x0]        # 68a <botlish_fn_4+0xed>
			686: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     68a:	mov    rcx,r13
     68d:	mov    r13,r15
     690:	mov    rdx,r13
     693:	mov    rsi,r12
     696:	mov    rdi,r14
     699:	call   rax
     69b:	test   rax,rax
     69e:	jne    6ac <botlish_fn_4+0x10f>
     6a4:	mov    rdi,r14
     6a7:	jmp    72c <botlish_fn_4+0x18f>
     6ac:	mov    QWORD PTR [rbx+0x8],0x3
     6b4:	test   r13,0x1
     6bb:	jne    6c9 <botlish_fn_4+0x12c>
     6c1:	mov    r15,r13
     6c4:	jmp    6e9 <botlish_fn_4+0x14c>
     6c9:	mov    rax,r13
     6cc:	add    rax,0x2
     6d0:	mov    rcx,rax
     6d3:	mov    r15,r13
     6d6:	seto   al
     6d9:	test   al,al
     6db:	jne    6e9 <botlish_fn_4+0x14c>
     6e1:	mov    rax,rcx
     6e4:	jmp    6fd <botlish_fn_4+0x160>
     6e9:	mov    edx,0x3
     6ee:	mov    rax,QWORD PTR [rip+0x0]        # 6f5 <botlish_fn_4+0x158>
			6f1: R_X86_64_GOTPCREL	rt_int_add-0x4
     6f5:	mov    rsi,r15
     6f8:	mov    rdi,r14
     6fb:	call   rax
     6fd:	mov    QWORD PTR [rbx+0x8],rax
     701:	lea    rdx,[rsp]
     705:	mov    QWORD PTR [rsp],r12
     709:	mov    QWORD PTR [rsp+0x8],rax
     70e:	mov    esi,0x2
     713:	mov    r8,QWORD PTR [rip+0x0]        # 71a <botlish_fn_4+0x17d>
			716: R_X86_64_GOTPCREL	rt_list_new-0x4
     71a:	mov    rdi,r14
     71d:	call   r8
     720:	test   rax,rax
     723:	jne    757 <botlish_fn_4+0x1ba>
     729:	mov    rdi,r14
     72c:	mov    rdi,r14
     72f:	mov    QWORD PTR [rdi],rbx
     732:	xor    rax,rax
     735:	mov    rbx,QWORD PTR [rsp+0x20]
     73a:	mov    r12,QWORD PTR [rsp+0x28]
     73f:	mov    r13,QWORD PTR [rsp+0x30]
     744:	mov    r14,QWORD PTR [rsp+0x38]
     749:	mov    r15,QWORD PTR [rsp+0x40]
     74e:	add    rsp,0x50
     752:	mov    rsp,rbp
     755:	pop    rbp
     756:	ret
     757:	mov    rdi,r14
     75a:	mov    QWORD PTR [rdi],rbx
     75d:	mov    rbx,QWORD PTR [rsp+0x20]
     762:	mov    r12,QWORD PTR [rsp+0x28]
     767:	mov    r13,QWORD PTR [rsp+0x30]
     76c:	mov    r14,QWORD PTR [rsp+0x38]
     771:	mov    r15,QWORD PTR [rsp+0x40]
     776:	add    rsp,0x50
     77a:	mov    rsp,rbp
     77d:	pop    rbp
     77e:	ret
     77f:	mov    r14,rdi
     782:	mov    r11,QWORD PTR [rip+0x0]        # 789 <botlish_fn_4+0x1ec>
			785: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     789:	call   r11
     78c:	xor    rax,rax
     78f:	mov    rbx,QWORD PTR [rsp+0x20]
     794:	mov    r12,QWORD PTR [rsp+0x28]
     799:	mov    r13,QWORD PTR [rsp+0x30]
     79e:	mov    r14,QWORD PTR [rsp+0x38]
     7a3:	mov    r15,QWORD PTR [rsp+0x40]
     7a8:	add    rsp,0x50
     7ac:	mov    rsp,rbp
     7af:	pop    rbp
     7b0:	ret

00000000000007b1 <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     7b1:	push   rbp
     7b2:	mov    rbp,rsp
     7b5:	mov    rsi,QWORD PTR [rdx]
     7b8:	mov    rdx,QWORD PTR [rdx+0x8]
     7bc:	call   7c1 <botlish_entry_4+0x10>
			7bd: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
     7c1:	mov    rsp,rbp
     7c4:	pop    rbp
     7c5:	ret

00000000000007c6 <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     7c6:	push   rbp
     7c7:	mov    rbp,rsp
     7ca:	sub    rsp,0x50
     7ce:	mov    QWORD PTR [rsp+0x20],rbx
     7d3:	mov    QWORD PTR [rsp+0x28],r12
     7d8:	mov    QWORD PTR [rsp+0x30],r13
     7dd:	mov    QWORD PTR [rsp+0x38],r14
     7e2:	mov    QWORD PTR [rsp+0x40],r15
     7e7:	mov    r12,rsi
     7ea:	mov    rbx,QWORD PTR [rdi]
     7ed:	mov    rax,QWORD PTR [rdi+0x8]
     7f1:	lea    rcx,[rbx+0x18]
     7f5:	cmp    rcx,rax
     7f8:	ja     9a8 <botlish_fn_5+0x1e2>
     7fe:	lea    rax,[rbx+0x18]
     802:	mov    QWORD PTR [rdi],rax
     805:	mov    r14,rdi
     808:	mov    QWORD PTR [rbx],0x0
     80f:	mov    QWORD PTR [rbx+0x8],0x0
     817:	mov    QWORD PTR [rbx+0x10],0x0
     81f:	mov    QWORD PTR [rbx],rdx
     822:	mov    r13,rdx
     825:	mov    edx,0x1
     82a:	mov    rax,QWORD PTR [rip+0x0]        # 831 <botlish_fn_5+0x6b>
			82d: R_X86_64_GOTPCREL	rt_list_get-0x4
     831:	mov    rsi,r12
     834:	mov    rdi,r14
     837:	call   rax
     839:	test   rax,rax
     83c:	jne    84a <botlish_fn_5+0x84>
     842:	mov    rdi,r14
     845:	jmp    955 <botlish_fn_5+0x18f>
     84a:	mov    QWORD PTR [rbx+0x8],rax
     84e:	mov    QWORD PTR [rsp+0x10],rax
     853:	mov    edx,0x3
     858:	mov    rax,QWORD PTR [rip+0x0]        # 85f <botlish_fn_5+0x99>
			85b: R_X86_64_GOTPCREL	rt_list_get-0x4
     85f:	mov    rsi,r12
     862:	mov    rdi,r14
     865:	call   rax
     867:	mov    rcx,rax
     86a:	mov    r15,rax
     86d:	test   rax,rcx
     870:	jne    87e <botlish_fn_5+0xb8>
     876:	mov    rdi,r14
     879:	jmp    955 <botlish_fn_5+0x18f>
     87e:	mov    rax,r15
     881:	mov    QWORD PTR [rbx+0x10],rax
     885:	mov    rsi,QWORD PTR [rsp+0x10]
     88a:	mov    rdx,r15
     88d:	mov    rdi,r14
     890:	call   895 <botlish_fn_5+0xcf>
			891: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     895:	mov    r12,rax
     898:	test   r12,r12
     89b:	jne    8a9 <botlish_fn_5+0xe3>
     8a1:	mov    rdi,r14
     8a4:	jmp    955 <botlish_fn_5+0x18f>
     8a9:	mov    QWORD PTR [rbx],r12
     8ac:	mov    rax,QWORD PTR [rip+0x0]        # 8b3 <botlish_fn_5+0xed>
			8af: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     8b3:	mov    rcx,r13
     8b6:	mov    r13,r15
     8b9:	mov    rdx,r13
     8bc:	mov    rsi,r12
     8bf:	mov    rdi,r14
     8c2:	call   rax
     8c4:	test   rax,rax
     8c7:	jne    8d5 <botlish_fn_5+0x10f>
     8cd:	mov    rdi,r14
     8d0:	jmp    955 <botlish_fn_5+0x18f>
     8d5:	mov    QWORD PTR [rbx+0x8],0x3
     8dd:	test   r13,0x1
     8e4:	jne    8f2 <botlish_fn_5+0x12c>
     8ea:	mov    r15,r13
     8ed:	jmp    912 <botlish_fn_5+0x14c>
     8f2:	mov    rax,r13
     8f5:	add    rax,0x2
     8f9:	mov    rcx,rax
     8fc:	mov    r15,r13
     8ff:	seto   al
     902:	test   al,al
     904:	jne    912 <botlish_fn_5+0x14c>
     90a:	mov    rax,rcx
     90d:	jmp    926 <botlish_fn_5+0x160>
     912:	mov    edx,0x3
     917:	mov    rax,QWORD PTR [rip+0x0]        # 91e <botlish_fn_5+0x158>
			91a: R_X86_64_GOTPCREL	rt_int_add-0x4
     91e:	mov    rsi,r15
     921:	mov    rdi,r14
     924:	call   rax
     926:	mov    QWORD PTR [rbx+0x8],rax
     92a:	lea    rdx,[rsp]
     92e:	mov    QWORD PTR [rsp],r12
     932:	mov    QWORD PTR [rsp+0x8],rax
     937:	mov    esi,0x2
     93c:	mov    r8,QWORD PTR [rip+0x0]        # 943 <botlish_fn_5+0x17d>
			93f: R_X86_64_GOTPCREL	rt_list_new-0x4
     943:	mov    rdi,r14
     946:	call   r8
     949:	test   rax,rax
     94c:	jne    980 <botlish_fn_5+0x1ba>
     952:	mov    rdi,r14
     955:	mov    rdi,r14
     958:	mov    QWORD PTR [rdi],rbx
     95b:	xor    rax,rax
     95e:	mov    rbx,QWORD PTR [rsp+0x20]
     963:	mov    r12,QWORD PTR [rsp+0x28]
     968:	mov    r13,QWORD PTR [rsp+0x30]
     96d:	mov    r14,QWORD PTR [rsp+0x38]
     972:	mov    r15,QWORD PTR [rsp+0x40]
     977:	add    rsp,0x50
     97b:	mov    rsp,rbp
     97e:	pop    rbp
     97f:	ret
     980:	mov    rdi,r14
     983:	mov    QWORD PTR [rdi],rbx
     986:	mov    rbx,QWORD PTR [rsp+0x20]
     98b:	mov    r12,QWORD PTR [rsp+0x28]
     990:	mov    r13,QWORD PTR [rsp+0x30]
     995:	mov    r14,QWORD PTR [rsp+0x38]
     99a:	mov    r15,QWORD PTR [rsp+0x40]
     99f:	add    rsp,0x50
     9a3:	mov    rsp,rbp
     9a6:	pop    rbp
     9a7:	ret
     9a8:	mov    r14,rdi
     9ab:	mov    r11,QWORD PTR [rip+0x0]        # 9b2 <botlish_fn_5+0x1ec>
			9ae: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     9b2:	call   r11
     9b5:	xor    rax,rax
     9b8:	mov    rbx,QWORD PTR [rsp+0x20]
     9bd:	mov    r12,QWORD PTR [rsp+0x28]
     9c2:	mov    r13,QWORD PTR [rsp+0x30]
     9c7:	mov    r14,QWORD PTR [rsp+0x38]
     9cc:	mov    r15,QWORD PTR [rsp+0x40]
     9d1:	add    rsp,0x50
     9d5:	mov    rsp,rbp
     9d8:	pop    rbp
     9d9:	ret

00000000000009da <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     9da:	push   rbp
     9db:	mov    rbp,rsp
     9de:	mov    rsi,QWORD PTR [rdx]
     9e1:	mov    rdx,QWORD PTR [rdx+0x8]
     9e5:	call   9ea <botlish_entry_5+0x10>
			9e6: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
     9ea:	mov    rsp,rbp
     9ed:	pop    rbp
     9ee:	ret

00000000000009ef <botlish_fn_6: geo_append<list[mutarray, int], mutarray>>:
     9ef:	push   rbp
     9f0:	mov    rbp,rsp
     9f3:	sub    rsp,0x50
     9f7:	mov    QWORD PTR [rsp+0x20],rbx
     9fc:	mov    QWORD PTR [rsp+0x28],r12
     a01:	mov    QWORD PTR [rsp+0x30],r13
     a06:	mov    QWORD PTR [rsp+0x38],r14
     a0b:	mov    QWORD PTR [rsp+0x40],r15
     a10:	mov    r12,rsi
     a13:	mov    rbx,QWORD PTR [rdi]
     a16:	mov    rax,QWORD PTR [rdi+0x8]
     a1a:	lea    rcx,[rbx+0x18]
     a1e:	cmp    rcx,rax
     a21:	ja     bd1 <botlish_fn_6+0x1e2>
     a27:	lea    rax,[rbx+0x18]
     a2b:	mov    QWORD PTR [rdi],rax
     a2e:	mov    r14,rdi
     a31:	mov    QWORD PTR [rbx],0x0
     a38:	mov    QWORD PTR [rbx+0x8],0x0
     a40:	mov    QWORD PTR [rbx+0x10],0x0
     a48:	mov    QWORD PTR [rbx],rdx
     a4b:	mov    r13,rdx
     a4e:	mov    edx,0x1
     a53:	mov    rax,QWORD PTR [rip+0x0]        # a5a <botlish_fn_6+0x6b>
			a56: R_X86_64_GOTPCREL	rt_list_get-0x4
     a5a:	mov    rsi,r12
     a5d:	mov    rdi,r14
     a60:	call   rax
     a62:	test   rax,rax
     a65:	jne    a73 <botlish_fn_6+0x84>
     a6b:	mov    rdi,r14
     a6e:	jmp    b7e <botlish_fn_6+0x18f>
     a73:	mov    QWORD PTR [rbx+0x8],rax
     a77:	mov    QWORD PTR [rsp+0x10],rax
     a7c:	mov    edx,0x3
     a81:	mov    rax,QWORD PTR [rip+0x0]        # a88 <botlish_fn_6+0x99>
			a84: R_X86_64_GOTPCREL	rt_list_get-0x4
     a88:	mov    rsi,r12
     a8b:	mov    rdi,r14
     a8e:	call   rax
     a90:	mov    rcx,rax
     a93:	mov    r15,rax
     a96:	test   rax,rcx
     a99:	jne    aa7 <botlish_fn_6+0xb8>
     a9f:	mov    rdi,r14
     aa2:	jmp    b7e <botlish_fn_6+0x18f>
     aa7:	mov    rax,r15
     aaa:	mov    QWORD PTR [rbx+0x10],rax
     aae:	mov    rsi,QWORD PTR [rsp+0x10]
     ab3:	mov    rdx,r15
     ab6:	mov    rdi,r14
     ab9:	call   abe <botlish_fn_6+0xcf>
			aba: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     abe:	mov    r12,rax
     ac1:	test   r12,r12
     ac4:	jne    ad2 <botlish_fn_6+0xe3>
     aca:	mov    rdi,r14
     acd:	jmp    b7e <botlish_fn_6+0x18f>
     ad2:	mov    QWORD PTR [rbx],r12
     ad5:	mov    rax,QWORD PTR [rip+0x0]        # adc <botlish_fn_6+0xed>
			ad8: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     adc:	mov    rcx,r13
     adf:	mov    r13,r15
     ae2:	mov    rdx,r13
     ae5:	mov    rsi,r12
     ae8:	mov    rdi,r14
     aeb:	call   rax
     aed:	test   rax,rax
     af0:	jne    afe <botlish_fn_6+0x10f>
     af6:	mov    rdi,r14
     af9:	jmp    b7e <botlish_fn_6+0x18f>
     afe:	mov    QWORD PTR [rbx+0x8],0x3
     b06:	test   r13,0x1
     b0d:	jne    b1b <botlish_fn_6+0x12c>
     b13:	mov    r15,r13
     b16:	jmp    b3b <botlish_fn_6+0x14c>
     b1b:	mov    rax,r13
     b1e:	add    rax,0x2
     b22:	mov    rcx,rax
     b25:	mov    r15,r13
     b28:	seto   al
     b2b:	test   al,al
     b2d:	jne    b3b <botlish_fn_6+0x14c>
     b33:	mov    rax,rcx
     b36:	jmp    b4f <botlish_fn_6+0x160>
     b3b:	mov    edx,0x3
     b40:	mov    rax,QWORD PTR [rip+0x0]        # b47 <botlish_fn_6+0x158>
			b43: R_X86_64_GOTPCREL	rt_int_add-0x4
     b47:	mov    rsi,r15
     b4a:	mov    rdi,r14
     b4d:	call   rax
     b4f:	mov    QWORD PTR [rbx+0x8],rax
     b53:	lea    rdx,[rsp]
     b57:	mov    QWORD PTR [rsp],r12
     b5b:	mov    QWORD PTR [rsp+0x8],rax
     b60:	mov    esi,0x2
     b65:	mov    r8,QWORD PTR [rip+0x0]        # b6c <botlish_fn_6+0x17d>
			b68: R_X86_64_GOTPCREL	rt_list_new-0x4
     b6c:	mov    rdi,r14
     b6f:	call   r8
     b72:	test   rax,rax
     b75:	jne    ba9 <botlish_fn_6+0x1ba>
     b7b:	mov    rdi,r14
     b7e:	mov    rdi,r14
     b81:	mov    QWORD PTR [rdi],rbx
     b84:	xor    rax,rax
     b87:	mov    rbx,QWORD PTR [rsp+0x20]
     b8c:	mov    r12,QWORD PTR [rsp+0x28]
     b91:	mov    r13,QWORD PTR [rsp+0x30]
     b96:	mov    r14,QWORD PTR [rsp+0x38]
     b9b:	mov    r15,QWORD PTR [rsp+0x40]
     ba0:	add    rsp,0x50
     ba4:	mov    rsp,rbp
     ba7:	pop    rbp
     ba8:	ret
     ba9:	mov    rdi,r14
     bac:	mov    QWORD PTR [rdi],rbx
     baf:	mov    rbx,QWORD PTR [rsp+0x20]
     bb4:	mov    r12,QWORD PTR [rsp+0x28]
     bb9:	mov    r13,QWORD PTR [rsp+0x30]
     bbe:	mov    r14,QWORD PTR [rsp+0x38]
     bc3:	mov    r15,QWORD PTR [rsp+0x40]
     bc8:	add    rsp,0x50
     bcc:	mov    rsp,rbp
     bcf:	pop    rbp
     bd0:	ret
     bd1:	mov    r14,rdi
     bd4:	mov    r11,QWORD PTR [rip+0x0]        # bdb <botlish_fn_6+0x1ec>
			bd7: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     bdb:	call   r11
     bde:	xor    rax,rax
     be1:	mov    rbx,QWORD PTR [rsp+0x20]
     be6:	mov    r12,QWORD PTR [rsp+0x28]
     beb:	mov    r13,QWORD PTR [rsp+0x30]
     bf0:	mov    r14,QWORD PTR [rsp+0x38]
     bf5:	mov    r15,QWORD PTR [rsp+0x40]
     bfa:	add    rsp,0x50
     bfe:	mov    rsp,rbp
     c01:	pop    rbp
     c02:	ret

0000000000000c03 <botlish_entry_6: geo_append<list[mutarray, int], mutarray>>:
     c03:	push   rbp
     c04:	mov    rbp,rsp
     c07:	mov    rsi,QWORD PTR [rdx]
     c0a:	mov    rdx,QWORD PTR [rdx+0x8]
     c0e:	call   c13 <botlish_entry_6+0x10>
			c0f: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<list[mutarray, int], mutarray>
     c13:	mov    rsp,rbp
     c16:	pop    rbp
     c17:	ret

0000000000000c18 <botlish_fn_7: geo_finish<list[mutarray, int]>>:
     c18:	push   rbp
     c19:	mov    rbp,rsp
     c1c:	sub    rsp,0x20
     c20:	mov    QWORD PTR [rsp],rbx
     c24:	mov    QWORD PTR [rsp+0x8],r12
     c29:	mov    QWORD PTR [rsp+0x10],r13
     c2e:	mov    QWORD PTR [rsp+0x18],r14
     c33:	mov    r13,rsi
     c36:	mov    rbx,QWORD PTR [rdi]
     c39:	mov    rax,QWORD PTR [rdi+0x8]
     c3d:	lea    rcx,[rbx+0x10]
     c41:	cmp    rcx,rax
     c44:	ja     d1c <botlish_fn_7+0x104>
     c4a:	lea    rax,[rbx+0x10]
     c4e:	mov    QWORD PTR [rdi],rax
     c51:	mov    r12,rdi
     c54:	mov    QWORD PTR [rbx],0x0
     c5b:	mov    QWORD PTR [rbx+0x8],0x0
     c63:	mov    edx,0x1
     c68:	mov    rax,QWORD PTR [rip+0x0]        # c6f <botlish_fn_7+0x57>
			c6b: R_X86_64_GOTPCREL	rt_list_get-0x4
     c6f:	mov    rsi,r13
     c72:	mov    rdi,r12
     c75:	call   rax
     c77:	test   rax,rax
     c7a:	jne    c88 <botlish_fn_7+0x70>
     c80:	mov    rdi,r12
     c83:	jmp    cd5 <botlish_fn_7+0xbd>
     c88:	mov    QWORD PTR [rbx],rax
     c8b:	mov    r14,rax
     c8e:	mov    edx,0x3
     c93:	mov    rax,QWORD PTR [rip+0x0]        # c9a <botlish_fn_7+0x82>
			c96: R_X86_64_GOTPCREL	rt_list_get-0x4
     c9a:	mov    rsi,r13
     c9d:	mov    rdi,r12
     ca0:	call   rax
     ca2:	test   rax,rax
     ca5:	jne    cb3 <botlish_fn_7+0x9b>
     cab:	mov    rdi,r12
     cae:	jmp    cd5 <botlish_fn_7+0xbd>
     cb3:	mov    QWORD PTR [rbx+0x8],rax
     cb7:	mov    rdx,rax
     cba:	mov    rax,QWORD PTR [rip+0x0]        # cc1 <botlish_fn_7+0xa9>
			cbd: R_X86_64_GOTPCREL	rt_mutarray_freeze-0x4
     cc1:	mov    rsi,r14
     cc4:	mov    rdi,r12
     cc7:	call   rax
     cc9:	test   rax,rax
     ccc:	jne    cfa <botlish_fn_7+0xe2>
     cd2:	mov    rdi,r12
     cd5:	mov    rdi,r12
     cd8:	mov    QWORD PTR [rdi],rbx
     cdb:	xor    rax,rax
     cde:	mov    rbx,QWORD PTR [rsp]
     ce2:	mov    r12,QWORD PTR [rsp+0x8]
     ce7:	mov    r13,QWORD PTR [rsp+0x10]
     cec:	mov    r14,QWORD PTR [rsp+0x18]
     cf1:	add    rsp,0x20
     cf5:	mov    rsp,rbp
     cf8:	pop    rbp
     cf9:	ret
     cfa:	mov    rdi,r12
     cfd:	mov    QWORD PTR [rdi],rbx
     d00:	mov    rbx,QWORD PTR [rsp]
     d04:	mov    r12,QWORD PTR [rsp+0x8]
     d09:	mov    r13,QWORD PTR [rsp+0x10]
     d0e:	mov    r14,QWORD PTR [rsp+0x18]
     d13:	add    rsp,0x20
     d17:	mov    rsp,rbp
     d1a:	pop    rbp
     d1b:	ret
     d1c:	mov    r12,rdi
     d1f:	mov    rax,QWORD PTR [rip+0x0]        # d26 <botlish_fn_7+0x10e>
			d22: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     d26:	call   rax
     d28:	xor    rax,rax
     d2b:	mov    rbx,QWORD PTR [rsp]
     d2f:	mov    r12,QWORD PTR [rsp+0x8]
     d34:	mov    r13,QWORD PTR [rsp+0x10]
     d39:	mov    r14,QWORD PTR [rsp+0x18]
     d3e:	add    rsp,0x20
     d42:	mov    rsp,rbp
     d45:	pop    rbp
     d46:	ret

0000000000000d47 <botlish_entry_7: geo_finish<list[mutarray, int]>>:
     d47:	push   rbp
     d48:	mov    rbp,rsp
     d4b:	mov    rsi,QWORD PTR [rdx]
     d4e:	call   d53 <botlish_entry_7+0xc>
			d4f: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
     d53:	mov    rsp,rbp
     d56:	pop    rbp
     d57:	ret

0000000000000d58 <botlish_fn_8: peek<str, int>>:
     d58:	push   rbp
     d59:	mov    rbp,rsp
     d5c:	sub    rsp,0x20
     d60:	mov    QWORD PTR [rsp],rbx
     d64:	mov    QWORD PTR [rsp+0x8],r12
     d69:	mov    QWORD PTR [rsp+0x10],r13
     d6e:	mov    QWORD PTR [rsp+0x18],r14
     d73:	mov    r12,QWORD PTR [rdi]
     d76:	mov    rax,QWORD PTR [rdi+0x8]
     d7a:	lea    rcx,[r12+0x18]
     d7f:	cmp    rcx,rax
     d82:	ja     eee <botlish_fn_8+0x196>
     d88:	lea    rax,[r12+0x18]
     d8d:	mov    QWORD PTR [rdi],rax
     d90:	mov    r13,rdi
     d93:	mov    QWORD PTR [r12],0x0
     d9b:	mov    QWORD PTR [r12+0x8],0x0
     da4:	mov    QWORD PTR [r12+0x10],0x0
     dad:	mov    QWORD PTR [r12],rsi
     db1:	mov    r14,rsi
     db4:	mov    QWORD PTR [r12+0x8],rdx
     db9:	mov    rbx,rdx
     dbc:	mov    rax,QWORD PTR [rip+0x0]        # dc3 <botlish_fn_8+0x6b>
			dbf: R_X86_64_GOTPCREL	rt_str_len-0x4
     dc3:	mov    rsi,r14
     dc6:	mov    rdi,r13
     dc9:	call   rax
     dcb:	mov    rcx,rbx
     dce:	and    rcx,rax
     dd1:	mov    rdx,rax
     dd4:	test   rcx,0x1
     ddb:	jne    e05 <botlish_fn_8+0xad>
     de1:	mov    rax,QWORD PTR [rip+0x0]        # de8 <botlish_fn_8+0x90>
			de4: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     de8:	mov    rsi,rbx
     deb:	mov    rdi,r13
     dee:	call   rax
     df0:	mov    ecx,0x2
     df5:	test   rax,rax
     df8:	cmovge rcx,QWORD PTR [rip+0x120]        # f20 <botlish_fn_8+0x1c8>
     e00:	jmp    e15 <botlish_fn_8+0xbd>
     e05:	mov    ecx,0x2
     e0a:	cmp    rbx,rdx
     e0d:	cmovge rcx,QWORD PTR [rip+0x10b]        # f20 <botlish_fn_8+0x1c8>
     e15:	cmp    rcx,0x6
     e19:	je     ec5 <botlish_fn_8+0x16d>
     e1f:	mov    QWORD PTR [r12+0x10],0x3
     e28:	test   rbx,0x1
     e2f:	je     e47 <botlish_fn_8+0xef>
     e35:	mov    rcx,rbx
     e38:	add    rcx,0x2
     e3c:	seto   al
     e3f:	test   al,al
     e41:	je     e5e <botlish_fn_8+0x106>
     e47:	mov    edx,0x3
     e4c:	mov    rax,QWORD PTR [rip+0x0]        # e53 <botlish_fn_8+0xfb>
			e4f: R_X86_64_GOTPCREL	rt_int_add-0x4
     e53:	mov    rsi,rbx
     e56:	mov    rdi,r13
     e59:	call   rax
     e5b:	mov    rcx,rax
     e5e:	mov    QWORD PTR [r12+0x10],rcx
     e63:	mov    rax,QWORD PTR [rip+0x0]        # e6a <botlish_fn_8+0x112>
			e66: R_X86_64_GOTPCREL	rt_substr-0x4
     e6a:	mov    rdx,rbx
     e6d:	mov    rsi,r14
     e70:	mov    rdi,r13
     e73:	call   rax
     e75:	test   rax,rax
     e78:	jne    ea3 <botlish_fn_8+0x14b>
     e7e:	mov    rdi,r13
     e81:	mov    QWORD PTR [rdi],r12
     e84:	xor    rax,rax
     e87:	mov    rbx,QWORD PTR [rsp]
     e8b:	mov    r12,QWORD PTR [rsp+0x8]
     e90:	mov    r13,QWORD PTR [rsp+0x10]
     e95:	mov    r14,QWORD PTR [rsp+0x18]
     e9a:	add    rsp,0x20
     e9e:	mov    rsp,rbp
     ea1:	pop    rbp
     ea2:	ret
     ea3:	mov    rdi,r13
     ea6:	mov    QWORD PTR [rdi],r12
     ea9:	mov    rbx,QWORD PTR [rsp]
     ead:	mov    r12,QWORD PTR [rsp+0x8]
     eb2:	mov    r13,QWORD PTR [rsp+0x10]
     eb7:	mov    r14,QWORD PTR [rsp+0x18]
     ebc:	add    rsp,0x20
     ec0:	mov    rsp,rbp
     ec3:	pop    rbp
     ec4:	ret
     ec5:	mov    rdi,r13
     ec8:	mov    rsi,QWORD PTR [rdi+0x10]
     ecc:	mov    rax,QWORD PTR [rsi]
     ecf:	mov    QWORD PTR [rdi],r12
     ed2:	mov    rbx,QWORD PTR [rsp]
     ed6:	mov    r12,QWORD PTR [rsp+0x8]
     edb:	mov    r13,QWORD PTR [rsp+0x10]
     ee0:	mov    r14,QWORD PTR [rsp+0x18]
     ee5:	add    rsp,0x20
     ee9:	mov    rsp,rbp
     eec:	pop    rbp
     eed:	ret
     eee:	mov    r13,rdi
     ef1:	mov    rsi,QWORD PTR [rip+0x0]        # ef8 <botlish_fn_8+0x1a0>
			ef4: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     ef8:	call   rsi
     efa:	xor    rax,rax
     efd:	mov    rbx,QWORD PTR [rsp]
     f01:	mov    r12,QWORD PTR [rsp+0x8]
     f06:	mov    r13,QWORD PTR [rsp+0x10]
     f0b:	mov    r14,QWORD PTR [rsp+0x18]
     f10:	add    rsp,0x20
     f14:	mov    rsp,rbp
     f17:	pop    rbp
     f18:	ret
     f19:	add    BYTE PTR [rax],al
     f1b:	add    BYTE PTR [rax],al
     f1d:	add    BYTE PTR [rax],al
     f1f:	add    BYTE PTR [rsi],al
     f21:	add    BYTE PTR [rax],al
     f23:	add    BYTE PTR [rax],al
     f25:	add    BYTE PTR [rax],al
	...

0000000000000f28 <botlish_entry_8: peek<str, int>>:
     f28:	push   rbp
     f29:	mov    rbp,rsp
     f2c:	mov    rsi,QWORD PTR [rdx]
     f2f:	mov    rdx,QWORD PTR [rdx+0x8]
     f33:	call   f38 <botlish_entry_8+0x10>
			f34: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     f38:	mov    rsp,rbp
     f3b:	pop    rbp
     f3c:	ret
     f3d:	add    BYTE PTR [rax],al
	...

0000000000000f40 <botlish_fn_9: peek<str, int>>:
     f40:	push   rbp
     f41:	mov    rbp,rsp
     f44:	sub    rsp,0x40
     f48:	mov    QWORD PTR [rsp+0x10],rbx
     f4d:	mov    QWORD PTR [rsp+0x18],r12
     f52:	mov    QWORD PTR [rsp+0x20],r13
     f57:	mov    QWORD PTR [rsp+0x28],r14
     f5c:	mov    QWORD PTR [rsp+0x30],r15
     f61:	mov    r13,rcx
     f64:	mov    r12,QWORD PTR [rdi]
     f67:	mov    rax,QWORD PTR [rdi+0x8]
     f6b:	lea    rcx,[r12+0x18]
     f70:	cmp    rcx,rax
     f73:	ja     111e <botlish_fn_9+0x1de>
     f79:	lea    rax,[r12+0x18]
     f7e:	mov    QWORD PTR [rdi],rax
     f81:	mov    r15,rdi
     f84:	mov    QWORD PTR [r12],0x0
     f8c:	mov    QWORD PTR [r12+0x8],0x0
     f95:	mov    QWORD PTR [r12+0x10],0x0
     f9e:	mov    QWORD PTR [r12],rsi
     fa2:	mov    r14,rsi
     fa5:	mov    QWORD PTR [r12+0x8],rdx
     faa:	mov    rbx,rdx
     fad:	mov    rax,QWORD PTR [rip+0x0]        # fb4 <botlish_fn_9+0x74>
			fb0: R_X86_64_GOTPCREL	rt_str_len-0x4
     fb4:	mov    rsi,r14
     fb7:	mov    rdi,r15
     fba:	call   rax
     fbc:	mov    rcx,rbx
     fbf:	and    rcx,rax
     fc2:	mov    rdx,rax
     fc5:	test   rcx,0x1
     fcc:	jne    ff6 <botlish_fn_9+0xb6>
     fd2:	mov    rax,QWORD PTR [rip+0x0]        # fd9 <botlish_fn_9+0x99>
			fd5: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     fd9:	mov    rsi,rbx
     fdc:	mov    rdi,r15
     fdf:	call   rax
     fe1:	mov    ecx,0x2
     fe6:	test   rax,rax
     fe9:	cmovge rcx,QWORD PTR [rip+0x15f]        # 1150 <botlish_fn_9+0x210>
     ff1:	jmp    1006 <botlish_fn_9+0xc6>
     ff6:	mov    ecx,0x2
     ffb:	cmp    rbx,rdx
     ffe:	cmovge rcx,QWORD PTR [rip+0x14a]        # 1150 <botlish_fn_9+0x210>
    1006:	cmp    rcx,0x6
    100a:	je     10dd <botlish_fn_9+0x19d>
    1010:	mov    QWORD PTR [r12+0x10],0x3
    1019:	test   rbx,0x1
    1020:	je     1041 <botlish_fn_9+0x101>
    1026:	mov    rax,rbx
    1029:	add    rax,0x2
    102d:	seto   cl
    1030:	test   cl,cl
    1032:	jne    1041 <botlish_fn_9+0x101>
    1038:	mov    QWORD PTR [rsp],rax
    103c:	jmp    1059 <botlish_fn_9+0x119>
    1041:	mov    edx,0x3
    1046:	mov    rax,QWORD PTR [rip+0x0]        # 104d <botlish_fn_9+0x10d>
			1049: R_X86_64_GOTPCREL	rt_int_add-0x4
    104d:	mov    rsi,rbx
    1050:	mov    rdi,r15
    1053:	call   rax
    1055:	mov    QWORD PTR [rsp],rax
    1059:	mov    r8,QWORD PTR [rip+0x0]        # 1060 <botlish_fn_9+0x120>
			105c: R_X86_64_GOTPCREL	rt_str_region_check-0x4
    1060:	mov    rcx,QWORD PTR [rsp]
    1064:	mov    rdx,rbx
    1067:	mov    rsi,r14
    106a:	mov    rdi,r15
    106d:	call   r8
    1070:	test   rax,rax
    1073:	jne    10a4 <botlish_fn_9+0x164>
    1079:	mov    rdi,r15
    107c:	mov    QWORD PTR [rdi],r12
    107f:	xor    rax,rax
    1082:	mov    rbx,QWORD PTR [rsp+0x10]
    1087:	mov    r12,QWORD PTR [rsp+0x18]
    108c:	mov    r13,QWORD PTR [rsp+0x20]
    1091:	mov    r14,QWORD PTR [rsp+0x28]
    1096:	mov    r15,QWORD PTR [rsp+0x30]
    109b:	add    rsp,0x40
    109f:	mov    rsp,rbp
    10a2:	pop    rbp
    10a3:	ret
    10a4:	mov    rdi,r15
    10a7:	mov    QWORD PTR [rdi],r12
    10aa:	mov    rcx,r13
    10ad:	mov    QWORD PTR [rcx],rbx
    10b0:	mov    rax,QWORD PTR [rsp]
    10b4:	mov    QWORD PTR [rcx+0x8],rax
    10b8:	mov    rax,r14
    10bb:	mov    rbx,QWORD PTR [rsp+0x10]
    10c0:	mov    r12,QWORD PTR [rsp+0x18]
    10c5:	mov    r13,QWORD PTR [rsp+0x20]
    10ca:	mov    r14,QWORD PTR [rsp+0x28]
    10cf:	mov    r15,QWORD PTR [rsp+0x30]
    10d4:	add    rsp,0x40
    10d8:	mov    rsp,rbp
    10db:	pop    rbp
    10dc:	ret
    10dd:	mov    rcx,r13
    10e0:	mov    rdi,r15
    10e3:	mov    rsi,QWORD PTR [rdi+0x10]
    10e7:	mov    rax,QWORD PTR [rsi]
    10ea:	mov    QWORD PTR [rdi],r12
    10ed:	mov    QWORD PTR [rcx],0x1
    10f4:	mov    QWORD PTR [rcx+0x8],0x1
    10fc:	mov    rbx,QWORD PTR [rsp+0x10]
    1101:	mov    r12,QWORD PTR [rsp+0x18]
    1106:	mov    r13,QWORD PTR [rsp+0x20]
    110b:	mov    r14,QWORD PTR [rsp+0x28]
    1110:	mov    r15,QWORD PTR [rsp+0x30]
    1115:	add    rsp,0x40
    1119:	mov    rsp,rbp
    111c:	pop    rbp
    111d:	ret
    111e:	mov    r15,rdi
    1121:	mov    r10,QWORD PTR [rip+0x0]        # 1128 <botlish_fn_9+0x1e8>
			1124: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1128:	call   r10
    112b:	xor    rax,rax
    112e:	mov    rbx,QWORD PTR [rsp+0x10]
    1133:	mov    r12,QWORD PTR [rsp+0x18]
    1138:	mov    r13,QWORD PTR [rsp+0x20]
    113d:	mov    r14,QWORD PTR [rsp+0x28]
    1142:	mov    r15,QWORD PTR [rsp+0x30]
    1147:	add    rsp,0x40
    114b:	mov    rsp,rbp
    114e:	pop    rbp
    114f:	ret
    1150:	(bad)
    1151:	add    BYTE PTR [rax],al
    1153:	add    BYTE PTR [rax],al
    1155:	add    BYTE PTR [rax],al
	...

0000000000001158 <botlish_entry_9: peek<str, int>>:
    1158:	push   rbp
    1159:	mov    rbp,rsp
    115c:	ud2

000000000000115e <botlish_fn_10: scan_unquoted<str, int, int>>:
    115e:	push   rbp
    115f:	mov    rbp,rsp
    1162:	sub    rsp,0x60
    1166:	mov    QWORD PTR [rsp+0x30],rbx
    116b:	mov    QWORD PTR [rsp+0x38],r12
    1170:	mov    QWORD PTR [rsp+0x40],r13
    1175:	mov    QWORD PTR [rsp+0x48],r14
    117a:	mov    QWORD PTR [rsp+0x50],r15
    117f:	mov    r14,QWORD PTR [rdi]
    1182:	mov    rax,QWORD PTR [rdi+0x8]
    1186:	lea    r8,[r14+0x20]
    118a:	cmp    r8,rax
    118d:	ja     13cb <botlish_fn_10+0x26d>
    1193:	lea    rax,[r14+0x20]
    1197:	mov    QWORD PTR [rdi],rax
    119a:	mov    r15,rdi
    119d:	mov    QWORD PTR [r14],0x0
    11a4:	mov    QWORD PTR [r14+0x8],0x0
    11ac:	mov    QWORD PTR [r14+0x10],0x0
    11b4:	mov    QWORD PTR [r14+0x18],0x0
    11bc:	mov    QWORD PTR [r14],rsi
    11bf:	mov    QWORD PTR [rsp+0x10],rsi
    11c4:	mov    QWORD PTR [r14+0x8],rdx
    11c8:	mov    QWORD PTR [rsp+0x18],rdx
    11cd:	mov    QWORD PTR [r14+0x10],rcx
    11d1:	lea    rbx,[rsp]
    11d5:	mov    QWORD PTR [rsp+0x20],rcx
    11da:	mov    rcx,rbx
    11dd:	mov    rdx,QWORD PTR [rsp+0x20]
    11e2:	mov    rsi,QWORD PTR [rsp+0x10]
    11e7:	mov    rdi,r15
    11ea:	call   11ef <botlish_fn_10+0x91>
			11eb: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    11ef:	mov    rcx,rax
    11f2:	mov    QWORD PTR [rsp+0x28],rax
    11f7:	test   rax,rcx
    11fa:	jne    1208 <botlish_fn_10+0xaa>
    1200:	mov    rdi,r15
    1203:	jmp    1370 <botlish_fn_10+0x212>
    1208:	mov    r12,QWORD PTR [rsp]
    120c:	mov    r13,QWORD PTR [rsp+0x8]
    1211:	mov    rdi,r15
    1214:	mov    rcx,QWORD PTR [rdi+0x10]
    1218:	mov    r8,QWORD PTR [rcx]
    121b:	mov    r9,QWORD PTR [rip+0x0]        # 1222 <botlish_fn_10+0xc4>
			121e: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1222:	mov    rcx,r13
    1225:	mov    rdx,r12
    1228:	mov    rsi,QWORD PTR [rsp+0x28]
    122d:	call   r9
    1230:	cmp    rax,0x6
    1234:	je     1278 <botlish_fn_10+0x11a>
    123a:	mov    rdi,r15
    123d:	mov    rdx,QWORD PTR [rdi+0x10]
    1241:	mov    r8,QWORD PTR [rdx+0x8]
    1245:	mov    r9,QWORD PTR [rip+0x0]        # 124c <botlish_fn_10+0xee>
			1248: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    124c:	mov    rcx,r13
    124f:	mov    rdx,r12
    1252:	mov    rsi,QWORD PTR [rsp+0x28]
    1257:	call   r9
    125a:	cmp    rax,0x6
    125e:	je     126e <botlish_fn_10+0x110>
    1264:	mov    eax,0x2
    1269:	jmp    127d <botlish_fn_10+0x11f>
    126e:	mov    eax,0x6
    1273:	jmp    127d <botlish_fn_10+0x11f>
    1278:	mov    eax,0x6
    127d:	cmp    rax,0x6
    1281:	je     12c5 <botlish_fn_10+0x167>
    1287:	mov    rdi,r15
    128a:	mov    r10,QWORD PTR [rdi+0x10]
    128e:	mov    r8,QWORD PTR [r10+0x10]
    1292:	mov    r10,QWORD PTR [rip+0x0]        # 1299 <botlish_fn_10+0x13b>
			1295: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1299:	mov    rcx,r13
    129c:	mov    rdx,r12
    129f:	mov    rsi,QWORD PTR [rsp+0x28]
    12a4:	call   r10
    12a7:	cmp    rax,0x6
    12ab:	je     12bb <botlish_fn_10+0x15d>
    12b1:	mov    eax,0x2
    12b6:	jmp    12ca <botlish_fn_10+0x16c>
    12bb:	mov    eax,0x6
    12c0:	jmp    12ca <botlish_fn_10+0x16c>
    12c5:	mov    eax,0x6
    12ca:	cmp    rax,0x6
    12ce:	je     1349 <botlish_fn_10+0x1eb>
    12d4:	mov    QWORD PTR [r14+0x18],0x3
    12dc:	mov    rsi,QWORD PTR [rsp+0x20]
    12e1:	test   rsi,0x1
    12e8:	je     130f <botlish_fn_10+0x1b1>
    12ee:	mov    rsi,QWORD PTR [rsp+0x20]
    12f3:	mov    rax,rsi
    12f6:	add    rax,0x2
    12fa:	seto   cl
    12fd:	test   cl,cl
    12ff:	jne    130f <botlish_fn_10+0x1b1>
    1305:	mov    rsi,QWORD PTR [rsp+0x10]
    130a:	jmp    132a <botlish_fn_10+0x1cc>
    130f:	mov    edx,0x3
    1314:	mov    rax,QWORD PTR [rip+0x0]        # 131b <botlish_fn_10+0x1bd>
			1317: R_X86_64_GOTPCREL	rt_int_add-0x4
    131b:	mov    rsi,QWORD PTR [rsp+0x20]
    1320:	mov    rdi,r15
    1323:	call   rax
    1325:	mov    rsi,QWORD PTR [rsp+0x10]
    132a:	mov    QWORD PTR [r14],rsi
    132d:	mov    rdx,QWORD PTR [rsp+0x18]
    1332:	mov    QWORD PTR [r14+0x8],rdx
    1336:	mov    QWORD PTR [r14+0x10],rax
    133a:	mov    QWORD PTR [rsp+0x10],rsi
    133f:	mov    QWORD PTR [rsp+0x20],rax
    1344:	jmp    11da <botlish_fn_10+0x7c>
    1349:	mov    rdx,QWORD PTR [rsp+0x18]
    134e:	mov    rsi,QWORD PTR [rsp+0x10]
    1353:	mov    rax,QWORD PTR [rip+0x0]        # 135a <botlish_fn_10+0x1fc>
			1356: R_X86_64_GOTPCREL	rt_substr-0x4
    135a:	mov    rcx,QWORD PTR [rsp+0x20]
    135f:	mov    rdi,r15
    1362:	call   rax
    1364:	test   rax,rax
    1367:	jne    139e <botlish_fn_10+0x240>
    136d:	mov    rdi,r15
    1370:	mov    rdi,r15
    1373:	mov    QWORD PTR [rdi],r14
    1376:	xor    rdx,rdx
    1379:	mov    rax,rdx
    137c:	mov    rbx,QWORD PTR [rsp+0x30]
    1381:	mov    r12,QWORD PTR [rsp+0x38]
    1386:	mov    r13,QWORD PTR [rsp+0x40]
    138b:	mov    r14,QWORD PTR [rsp+0x48]
    1390:	mov    r15,QWORD PTR [rsp+0x50]
    1395:	add    rsp,0x60
    1399:	mov    rsp,rbp
    139c:	pop    rbp
    139d:	ret
    139e:	mov    rdi,r15
    13a1:	mov    QWORD PTR [rdi],r14
    13a4:	mov    rdx,QWORD PTR [rsp+0x20]
    13a9:	mov    rbx,QWORD PTR [rsp+0x30]
    13ae:	mov    r12,QWORD PTR [rsp+0x38]
    13b3:	mov    r13,QWORD PTR [rsp+0x40]
    13b8:	mov    r14,QWORD PTR [rsp+0x48]
    13bd:	mov    r15,QWORD PTR [rsp+0x50]
    13c2:	add    rsp,0x60
    13c6:	mov    rsp,rbp
    13c9:	pop    rbp
    13ca:	ret
    13cb:	mov    r15,rdi
    13ce:	mov    rax,QWORD PTR [rip+0x0]        # 13d5 <botlish_fn_10+0x277>
			13d1: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    13d5:	call   rax
    13d7:	xor    rdx,rdx
    13da:	mov    rax,rdx
    13dd:	mov    rbx,QWORD PTR [rsp+0x30]
    13e2:	mov    r12,QWORD PTR [rsp+0x38]
    13e7:	mov    r13,QWORD PTR [rsp+0x40]
    13ec:	mov    r14,QWORD PTR [rsp+0x48]
    13f1:	mov    r15,QWORD PTR [rsp+0x50]
    13f6:	add    rsp,0x60
    13fa:	mov    rsp,rbp
    13fd:	pop    rbp
    13fe:	ret

00000000000013ff <botlish_entry_10: scan_unquoted<str, int, int>>:
    13ff:	push   rbp
    1400:	mov    rbp,rsp
    1403:	ud2

0000000000001405 <botlish_fn_11: scan_quoted<str, int, str>>:
    1405:	push   rbp
    1406:	mov    rbp,rsp
    1409:	sub    rsp,0x50
    140d:	mov    QWORD PTR [rsp+0x20],rbx
    1412:	mov    QWORD PTR [rsp+0x28],r12
    1417:	mov    QWORD PTR [rsp+0x30],r13
    141c:	mov    QWORD PTR [rsp+0x38],r14
    1421:	mov    QWORD PTR [rsp+0x40],r15
    1426:	mov    r13,QWORD PTR [rdi]
    1429:	mov    rax,QWORD PTR [rdi+0x8]
    142d:	lea    r8,[r13+0x28]
    1431:	cmp    r8,rax
    1434:	ja     1741 <botlish_fn_11+0x33c>
    143a:	lea    rax,[r13+0x28]
    143e:	mov    QWORD PTR [rdi],rax
    1441:	mov    r14,rdi
    1444:	mov    QWORD PTR [r13+0x0],0x0
    144c:	mov    QWORD PTR [r13+0x8],0x0
    1454:	mov    QWORD PTR [r13+0x10],0x0
    145c:	mov    QWORD PTR [r13+0x18],0x0
    1464:	mov    QWORD PTR [r13+0x20],0x0
    146c:	mov    QWORD PTR [r13+0x0],rsi
    1470:	mov    QWORD PTR [r13+0x8],rdx
    1474:	mov    QWORD PTR [r13+0x10],rcx
    1478:	lea    r12,[rsp]
    147c:	mov    rbx,rsi
    147f:	mov    r15,rdx
    1482:	mov    QWORD PTR [rsp+0x10],rcx
    1487:	mov    rdx,r15
    148a:	mov    rsi,rbx
    148d:	mov    rdi,r14
    1490:	call   1495 <botlish_fn_11+0x90>
			1491: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    1495:	test   rax,rax
    1498:	jne    14a6 <botlish_fn_11+0xa1>
    149e:	mov    rdi,r14
    14a1:	jmp    16fa <botlish_fn_11+0x2f5>
    14a6:	mov    QWORD PTR [r13+0x18],rax
    14aa:	mov    rdi,r14
    14ad:	mov    QWORD PTR [rsp+0x18],rax
    14b2:	mov    rcx,QWORD PTR [rdi+0x10]
    14b6:	mov    rsi,QWORD PTR [rcx+0x18]
    14ba:	mov    edx,0x1
    14bf:	mov    ecx,0x3
    14c4:	mov    r9,QWORD PTR [rip+0x0]        # 14cb <botlish_fn_11+0xc6>
			14c7: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    14cb:	mov    r8,QWORD PTR [rsp+0x18]
    14d0:	call   r9
    14d3:	cmp    rax,0x6
    14d7:	je     156a <botlish_fn_11+0x165>
    14dd:	mov    QWORD PTR [r13+0x20],0x3
    14e5:	mov    rsi,r15
    14e8:	test   rsi,0x1
    14ef:	je     150f <botlish_fn_11+0x10a>
    14f5:	mov    rax,rsi
    14f8:	add    rax,0x2
    14fc:	seto   cl
    14ff:	test   cl,cl
    1501:	jne    150f <botlish_fn_11+0x10a>
    1507:	mov    rsi,rax
    150a:	jmp    1523 <botlish_fn_11+0x11e>
    150f:	mov    edx,0x3
    1514:	mov    rax,QWORD PTR [rip+0x0]        # 151b <botlish_fn_11+0x116>
			1517: R_X86_64_GOTPCREL	rt_int_add-0x4
    151b:	mov    rdi,r14
    151e:	call   rax
    1520:	mov    rsi,rax
    1523:	mov    QWORD PTR [r13+0x8],rsi
    1527:	mov    r15,rsi
    152a:	mov    rax,QWORD PTR [rip+0x0]        # 1531 <botlish_fn_11+0x12c>
			152d: R_X86_64_GOTPCREL	rt_str_cat-0x4
    1531:	mov    rdx,QWORD PTR [rsp+0x18]
    1536:	mov    rsi,QWORD PTR [rsp+0x10]
    153b:	mov    rdi,r14
    153e:	call   rax
    1540:	test   rax,rax
    1543:	jne    1551 <botlish_fn_11+0x14c>
    1549:	mov    rdi,r14
    154c:	jmp    16fa <botlish_fn_11+0x2f5>
    1551:	mov    QWORD PTR [r13+0x0],rbx
    1555:	mov    rsi,r15
    1558:	mov    QWORD PTR [r13+0x8],rsi
    155c:	mov    QWORD PTR [r13+0x10],rax
    1560:	mov    QWORD PTR [rsp+0x10],rax
    1565:	jmp    1487 <botlish_fn_11+0x82>
    156a:	mov    QWORD PTR [r13+0x18],0x3
    1572:	mov    rsi,r15
    1575:	test   rsi,0x1
    157c:	je     1597 <botlish_fn_11+0x192>
    1582:	mov    rsi,r15
    1585:	mov    rdx,rsi
    1588:	add    rdx,0x2
    158c:	seto   al
    158f:	test   al,al
    1591:	je     15ae <botlish_fn_11+0x1a9>
    1597:	mov    edx,0x3
    159c:	mov    rax,QWORD PTR [rip+0x0]        # 15a3 <botlish_fn_11+0x19e>
			159f: R_X86_64_GOTPCREL	rt_int_add-0x4
    15a3:	mov    rsi,r15
    15a6:	mov    rdi,r14
    15a9:	call   rax
    15ab:	mov    rdx,rax
    15ae:	mov    QWORD PTR [r13+0x18],rdx
    15b2:	mov    rcx,r12
    15b5:	mov    rsi,rbx
    15b8:	mov    rdi,r14
    15bb:	call   15c0 <botlish_fn_11+0x1bb>
			15bc: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    15c0:	test   rax,rax
    15c3:	mov    rsi,rax
    15c6:	jne    15d4 <botlish_fn_11+0x1cf>
    15cc:	mov    rdi,r14
    15cf:	jmp    16fa <botlish_fn_11+0x2f5>
    15d4:	mov    rdx,QWORD PTR [rsp]
    15d8:	mov    rcx,QWORD PTR [rsp+0x8]
    15dd:	mov    rdi,r14
    15e0:	mov    rax,QWORD PTR [rdi+0x10]
    15e4:	mov    r8,QWORD PTR [rax+0x18]
    15e8:	mov    rax,QWORD PTR [rip+0x0]        # 15ef <botlish_fn_11+0x1ea>
			15eb: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    15ef:	call   rax
    15f1:	cmp    rax,0x6
    15f5:	je     1677 <botlish_fn_11+0x272>
    15fb:	mov    QWORD PTR [r13+0x0],0x3
    1603:	mov    rsi,r15
    1606:	test   rsi,0x1
    160d:	je     1630 <botlish_fn_11+0x22b>
    1613:	mov    rsi,r15
    1616:	mov    rdx,rsi
    1619:	add    rdx,0x2
    161d:	seto   al
    1620:	test   al,al
    1622:	jne    1630 <botlish_fn_11+0x22b>
    1628:	mov    rdi,r14
    162b:	jmp    164a <botlish_fn_11+0x245>
    1630:	mov    edx,0x3
    1635:	mov    rax,QWORD PTR [rip+0x0]        # 163c <botlish_fn_11+0x237>
			1638: R_X86_64_GOTPCREL	rt_int_add-0x4
    163c:	mov    rsi,r15
    163f:	mov    rdi,r14
    1642:	call   rax
    1644:	mov    rdx,rax
    1647:	mov    rdi,r14
    164a:	mov    rdi,r14
    164d:	mov    QWORD PTR [rdi],r13
    1650:	mov    rax,QWORD PTR [rsp+0x10]
    1655:	mov    rbx,QWORD PTR [rsp+0x20]
    165a:	mov    r12,QWORD PTR [rsp+0x28]
    165f:	mov    r13,QWORD PTR [rsp+0x30]
    1664:	mov    r14,QWORD PTR [rsp+0x38]
    1669:	mov    r15,QWORD PTR [rsp+0x40]
    166e:	add    rsp,0x50
    1672:	mov    rsp,rbp
    1675:	pop    rbp
    1676:	ret
    1677:	mov    QWORD PTR [r13+0x18],0x5
    167f:	mov    rsi,r15
    1682:	test   rsi,0x1
    1689:	je     16b1 <botlish_fn_11+0x2ac>
    168f:	mov    rsi,r15
    1692:	mov    rcx,rsi
    1695:	add    rcx,0x4
    1699:	seto   sil
    169d:	test   sil,sil
    16a0:	jne    16b1 <botlish_fn_11+0x2ac>
    16a6:	mov    rsi,rcx
    16a9:	mov    r15,rcx
    16ac:	jmp    16cc <botlish_fn_11+0x2c7>
    16b1:	mov    edx,0x5
    16b6:	mov    r8,QWORD PTR [rip+0x0]        # 16bd <botlish_fn_11+0x2b8>
			16b9: R_X86_64_GOTPCREL	rt_int_add-0x4
    16bd:	mov    rsi,r15
    16c0:	mov    rdi,r14
    16c3:	call   r8
    16c6:	mov    rsi,rax
    16c9:	mov    r15,rax
    16cc:	mov    QWORD PTR [r13+0x8],rsi
    16d0:	mov    rdi,r14
    16d3:	mov    r8,QWORD PTR [rdi+0x10]
    16d7:	mov    rdx,QWORD PTR [r8+0x18]
    16db:	mov    QWORD PTR [r13+0x18],rdx
    16df:	mov    r9,QWORD PTR [rip+0x0]        # 16e6 <botlish_fn_11+0x2e1>
			16e2: R_X86_64_GOTPCREL	rt_str_cat-0x4
    16e6:	mov    rsi,QWORD PTR [rsp+0x10]
    16eb:	call   r9
    16ee:	test   rax,rax
    16f1:	jne    1728 <botlish_fn_11+0x323>
    16f7:	mov    rdi,r14
    16fa:	mov    rdi,r14
    16fd:	mov    QWORD PTR [rdi],r13
    1700:	xor    rdx,rdx
    1703:	mov    rax,rdx
    1706:	mov    rbx,QWORD PTR [rsp+0x20]
    170b:	mov    r12,QWORD PTR [rsp+0x28]
    1710:	mov    r13,QWORD PTR [rsp+0x30]
    1715:	mov    r14,QWORD PTR [rsp+0x38]
    171a:	mov    r15,QWORD PTR [rsp+0x40]
    171f:	add    rsp,0x50
    1723:	mov    rsp,rbp
    1726:	pop    rbp
    1727:	ret
    1728:	mov    QWORD PTR [r13+0x0],rbx
    172c:	mov    rsi,r15
    172f:	mov    QWORD PTR [r13+0x8],rsi
    1733:	mov    QWORD PTR [r13+0x10],rax
    1737:	mov    QWORD PTR [rsp+0x10],rax
    173c:	jmp    1487 <botlish_fn_11+0x82>
    1741:	mov    r14,rdi
    1744:	mov    rax,QWORD PTR [rip+0x0]        # 174b <botlish_fn_11+0x346>
			1747: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    174b:	call   rax
    174d:	xor    rdx,rdx
    1750:	mov    rax,rdx
    1753:	mov    rbx,QWORD PTR [rsp+0x20]
    1758:	mov    r12,QWORD PTR [rsp+0x28]
    175d:	mov    r13,QWORD PTR [rsp+0x30]
    1762:	mov    r14,QWORD PTR [rsp+0x38]
    1767:	mov    r15,QWORD PTR [rsp+0x40]
    176c:	add    rsp,0x50
    1770:	mov    rsp,rbp
    1773:	pop    rbp
    1774:	ret

0000000000001775 <botlish_entry_11: scan_quoted<str, int, str>>:
    1775:	push   rbp
    1776:	mov    rbp,rsp
    1779:	ud2

000000000000177b <botlish_fn_12: scan_field<str, int>>:
    177b:	push   rbp
    177c:	mov    rbp,rsp
    177f:	sub    rsp,0x30
    1783:	mov    QWORD PTR [rsp+0x10],rbx
    1788:	mov    QWORD PTR [rsp+0x18],r12
    178d:	mov    QWORD PTR [rsp+0x20],r13
    1792:	mov    QWORD PTR [rsp+0x28],r14
    1797:	mov    rbx,QWORD PTR [rdi]
    179a:	mov    rax,QWORD PTR [rdi+0x8]
    179e:	lea    rcx,[rbx+0x18]
    17a2:	cmp    rcx,rax
    17a5:	ja     191e <botlish_fn_12+0x1a3>
    17ab:	lea    rax,[rbx+0x18]
    17af:	mov    QWORD PTR [rdi],rax
    17b2:	mov    r12,rdi
    17b5:	mov    QWORD PTR [rbx],0x0
    17bc:	mov    QWORD PTR [rbx+0x8],0x0
    17c4:	mov    QWORD PTR [rbx+0x10],0x0
    17cc:	mov    QWORD PTR [rbx],rsi
    17cf:	mov    r13,rsi
    17d2:	mov    QWORD PTR [rbx+0x8],rdx
    17d6:	mov    r14,rdx
    17d9:	lea    rcx,[rsp]
    17dd:	mov    rdx,r14
    17e0:	mov    rsi,r13
    17e3:	mov    rdi,r12
    17e6:	call   17eb <botlish_fn_12+0x70>
			17e7: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    17eb:	test   rax,rax
    17ee:	mov    rsi,rax
    17f1:	jne    17ff <botlish_fn_12+0x84>
    17f7:	mov    rdi,r12
    17fa:	jmp    18d2 <botlish_fn_12+0x157>
    17ff:	mov    rdx,QWORD PTR [rsp]
    1803:	mov    rcx,QWORD PTR [rsp+0x8]
    1808:	mov    rdi,r12
    180b:	mov    rax,QWORD PTR [rdi+0x10]
    180f:	mov    r8,QWORD PTR [rax+0x18]
    1813:	mov    rax,QWORD PTR [rip+0x0]        # 181a <botlish_fn_12+0x9f>
			1816: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    181a:	call   rax
    181c:	cmp    rax,0x6
    1820:	je     186b <botlish_fn_12+0xf0>
    1826:	mov    rcx,r14
    1829:	mov    rsi,r13
    182c:	mov    rdi,r12
    182f:	mov    rdx,rcx
    1832:	call   1837 <botlish_fn_12+0xbc>
			1833: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_unquoted<str, int, int>
    1837:	test   rax,rax
    183a:	jne    1848 <botlish_fn_12+0xcd>
    1840:	mov    rdi,r12
    1843:	jmp    18d2 <botlish_fn_12+0x157>
    1848:	mov    rdi,r12
    184b:	mov    QWORD PTR [rdi],rbx
    184e:	mov    rbx,QWORD PTR [rsp+0x10]
    1853:	mov    r12,QWORD PTR [rsp+0x18]
    1858:	mov    r13,QWORD PTR [rsp+0x20]
    185d:	mov    r14,QWORD PTR [rsp+0x28]
    1862:	add    rsp,0x30
    1866:	mov    rsp,rbp
    1869:	pop    rbp
    186a:	ret
    186b:	mov    QWORD PTR [rbx+0x10],0x3
    1873:	mov    rdx,r14
    1876:	test   rdx,0x1
    187d:	je     1895 <botlish_fn_12+0x11a>
    1883:	mov    rdx,r14
    1886:	add    rdx,0x2
    188a:	seto   al
    188d:	test   al,al
    188f:	je     18ac <botlish_fn_12+0x131>
    1895:	mov    edx,0x3
    189a:	mov    rax,QWORD PTR [rip+0x0]        # 18a1 <botlish_fn_12+0x126>
			189d: R_X86_64_GOTPCREL	rt_int_add-0x4
    18a1:	mov    rsi,r14
    18a4:	mov    rdi,r12
    18a7:	call   rax
    18a9:	mov    rdx,rax
    18ac:	mov    QWORD PTR [rbx+0x8],rdx
    18b0:	mov    rdi,r12
    18b3:	mov    rax,QWORD PTR [rdi+0x10]
    18b7:	mov    rcx,QWORD PTR [rax]
    18ba:	mov    QWORD PTR [rbx+0x10],rcx
    18be:	mov    rsi,r13
    18c1:	call   18c6 <botlish_fn_12+0x14b>
			18c2: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_quoted<str, int, str>
    18c6:	test   rax,rax
    18c9:	jne    18fb <botlish_fn_12+0x180>
    18cf:	mov    rdi,r12
    18d2:	mov    rdi,r12
    18d5:	mov    QWORD PTR [rdi],rbx
    18d8:	xor    rdx,rdx
    18db:	mov    rax,rdx
    18de:	mov    rbx,QWORD PTR [rsp+0x10]
    18e3:	mov    r12,QWORD PTR [rsp+0x18]
    18e8:	mov    r13,QWORD PTR [rsp+0x20]
    18ed:	mov    r14,QWORD PTR [rsp+0x28]
    18f2:	add    rsp,0x30
    18f6:	mov    rsp,rbp
    18f9:	pop    rbp
    18fa:	ret
    18fb:	mov    rdi,r12
    18fe:	mov    QWORD PTR [rdi],rbx
    1901:	mov    rbx,QWORD PTR [rsp+0x10]
    1906:	mov    r12,QWORD PTR [rsp+0x18]
    190b:	mov    r13,QWORD PTR [rsp+0x20]
    1910:	mov    r14,QWORD PTR [rsp+0x28]
    1915:	add    rsp,0x30
    1919:	mov    rsp,rbp
    191c:	pop    rbp
    191d:	ret
    191e:	mov    r12,rdi
    1921:	mov    rsi,QWORD PTR [rip+0x0]        # 1928 <botlish_fn_12+0x1ad>
			1924: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1928:	call   rsi
    192a:	xor    rdx,rdx
    192d:	mov    rax,rdx
    1930:	mov    rbx,QWORD PTR [rsp+0x10]
    1935:	mov    r12,QWORD PTR [rsp+0x18]
    193a:	mov    r13,QWORD PTR [rsp+0x20]
    193f:	mov    r14,QWORD PTR [rsp+0x28]
    1944:	add    rsp,0x30
    1948:	mov    rsp,rbp
    194b:	pop    rbp
    194c:	ret

000000000000194d <botlish_entry_12: scan_field<str, int>>:
    194d:	push   rbp
    194e:	mov    rbp,rsp
    1951:	ud2

0000000000001953 <botlish_fn_13: scan_record<str, int, list[mutarray, int]>>:
    1953:	push   rbp
    1954:	mov    rbp,rsp
    1957:	sub    rsp,0x60
    195b:	mov    QWORD PTR [rsp+0x30],rbx
    1960:	mov    QWORD PTR [rsp+0x38],r12
    1965:	mov    QWORD PTR [rsp+0x40],r13
    196a:	mov    QWORD PTR [rsp+0x48],r14
    196f:	mov    QWORD PTR [rsp+0x50],r15
    1974:	mov    r13,QWORD PTR [rdi]
    1977:	mov    rax,QWORD PTR [rdi+0x8]
    197b:	lea    r8,[r13+0x20]
    197f:	cmp    r8,rax
    1982:	ja     1c44 <botlish_fn_13+0x2f1>
    1988:	lea    rax,[r13+0x20]
    198c:	mov    QWORD PTR [rdi],rax
    198f:	mov    QWORD PTR [rsp+0x10],rdi
    1994:	mov    QWORD PTR [r13+0x0],0x0
    199c:	mov    QWORD PTR [r13+0x8],0x0
    19a4:	mov    QWORD PTR [r13+0x10],0x0
    19ac:	mov    QWORD PTR [r13+0x18],0x0
    19b4:	mov    QWORD PTR [r13+0x0],rsi
    19b8:	mov    QWORD PTR [r13+0x8],rdx
    19bc:	mov    QWORD PTR [r13+0x10],rcx
    19c0:	lea    rbx,[rsp]
    19c4:	mov    r12,rsi
    19c7:	mov    r14,rcx
    19ca:	mov    rsi,r12
    19cd:	mov    rdi,QWORD PTR [rsp+0x10]
    19d2:	call   19d7 <botlish_fn_13+0x84>
			19d3: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_field<str, int>
    19d7:	test   rax,rax
    19da:	jne    19ea <botlish_fn_13+0x97>
    19e0:	mov    rdi,QWORD PTR [rsp+0x10]
    19e5:	jmp    1b27 <botlish_fn_13+0x1d4>
    19ea:	mov    QWORD PTR [r13+0x8],rax
    19ee:	mov    r11,rax
    19f1:	mov    QWORD PTR [r13+0x18],rdx
    19f5:	mov    QWORD PTR [rsp+0x28],rdx
    19fa:	mov    rsi,r14
    19fd:	mov    rdx,r11
    1a00:	mov    rdi,QWORD PTR [rsp+0x10]
    1a05:	call   1a0a <botlish_fn_13+0xb7>
			1a06: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    1a0a:	test   rax,rax
    1a0d:	jne    1a1d <botlish_fn_13+0xca>
    1a13:	mov    rdi,QWORD PTR [rsp+0x10]
    1a18:	jmp    1b27 <botlish_fn_13+0x1d4>
    1a1d:	mov    QWORD PTR [r13+0x8],rax
    1a21:	mov    QWORD PTR [rsp+0x20],rax
    1a26:	mov    rcx,rbx
    1a29:	mov    rdx,QWORD PTR [rsp+0x28]
    1a2e:	mov    rsi,r12
    1a31:	mov    rdi,QWORD PTR [rsp+0x10]
    1a36:	call   1a3b <botlish_fn_13+0xe8>
			1a37: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
    1a3b:	test   rax,rax
    1a3e:	mov    QWORD PTR [rsp+0x18],rax
    1a43:	jne    1a53 <botlish_fn_13+0x100>
    1a49:	mov    rdi,QWORD PTR [rsp+0x10]
    1a4e:	jmp    1b27 <botlish_fn_13+0x1d4>
    1a53:	mov    r15,QWORD PTR [rsp]
    1a57:	mov    r14,QWORD PTR [rsp+0x8]
    1a5c:	mov    rdi,QWORD PTR [rsp+0x10]
    1a61:	mov    rsi,QWORD PTR [rdi+0x10]
    1a65:	mov    r8,QWORD PTR [rsi+0x8]
    1a69:	mov    r9,QWORD PTR [rip+0x0]        # 1a70 <botlish_fn_13+0x11d>
			1a6c: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1a70:	mov    rcx,r14
    1a73:	mov    rdx,r15
    1a76:	mov    rsi,QWORD PTR [rsp+0x18]
    1a7b:	call   r9
    1a7e:	cmp    rax,0x6
    1a82:	je     1be3 <botlish_fn_13+0x290>
    1a88:	mov    rdi,QWORD PTR [rsp+0x10]
    1a8d:	mov    rdi,QWORD PTR [rdi+0x10]
    1a91:	mov    r8,QWORD PTR [rdi+0x10]
    1a95:	mov    r9,QWORD PTR [rip+0x0]        # 1a9c <botlish_fn_13+0x149>
			1a98: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1a9c:	mov    rcx,r14
    1a9f:	mov    rdx,r15
    1aa2:	mov    rsi,QWORD PTR [rsp+0x18]
    1aa7:	mov    rdi,QWORD PTR [rsp+0x10]
    1aac:	call   r9
    1aaf:	cmp    rax,0x6
    1ab3:	je     1b0a <botlish_fn_13+0x1b7>
    1ab9:	mov    rsi,QWORD PTR [rsp+0x20]
    1abe:	mov    rdi,QWORD PTR [rsp+0x10]
    1ac3:	call   1ac8 <botlish_fn_13+0x175>
			1ac4: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    1ac8:	test   rax,rax
    1acb:	jne    1adb <botlish_fn_13+0x188>
    1ad1:	mov    rdi,QWORD PTR [rsp+0x10]
    1ad6:	jmp    1b27 <botlish_fn_13+0x1d4>
    1adb:	mov    rdi,QWORD PTR [rsp+0x10]
    1ae0:	mov    QWORD PTR [rdi],r13
    1ae3:	mov    rdx,QWORD PTR [rsp+0x28]
    1ae8:	mov    rbx,QWORD PTR [rsp+0x30]
    1aed:	mov    r12,QWORD PTR [rsp+0x38]
    1af2:	mov    r13,QWORD PTR [rsp+0x40]
    1af7:	mov    r14,QWORD PTR [rsp+0x48]
    1afc:	mov    r15,QWORD PTR [rsp+0x50]
    1b01:	add    rsp,0x60
    1b05:	mov    rsp,rbp
    1b08:	pop    rbp
    1b09:	ret
    1b0a:	mov    rsi,QWORD PTR [rsp+0x20]
    1b0f:	mov    rdi,QWORD PTR [rsp+0x10]
    1b14:	call   1b19 <botlish_fn_13+0x1c6>
			1b15: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    1b19:	test   rax,rax
    1b1c:	jne    1b57 <botlish_fn_13+0x204>
    1b22:	mov    rdi,QWORD PTR [rsp+0x10]
    1b27:	mov    rdi,QWORD PTR [rsp+0x10]
    1b2c:	mov    QWORD PTR [rdi],r13
    1b2f:	xor    rdx,rdx
    1b32:	mov    rax,rdx
    1b35:	mov    rbx,QWORD PTR [rsp+0x30]
    1b3a:	mov    r12,QWORD PTR [rsp+0x38]
    1b3f:	mov    r13,QWORD PTR [rsp+0x40]
    1b44:	mov    r14,QWORD PTR [rsp+0x48]
    1b49:	mov    r15,QWORD PTR [rsp+0x50]
    1b4e:	add    rsp,0x60
    1b52:	mov    rsp,rbp
    1b55:	pop    rbp
    1b56:	ret
    1b57:	mov    QWORD PTR [r13+0x0],rax
    1b5b:	mov    r15,rax
    1b5e:	mov    QWORD PTR [r13+0x8],0x3
    1b66:	mov    rdx,QWORD PTR [rsp+0x28]
    1b6b:	test   rdx,0x1
    1b72:	je     1b96 <botlish_fn_13+0x243>
    1b78:	mov    rdx,QWORD PTR [rsp+0x28]
    1b7d:	add    rdx,0x2
    1b81:	seto   al
    1b84:	test   al,al
    1b86:	jne    1b96 <botlish_fn_13+0x243>
    1b8c:	mov    rdi,QWORD PTR [rsp+0x10]
    1b91:	jmp    1bb6 <botlish_fn_13+0x263>
    1b96:	mov    edx,0x3
    1b9b:	mov    rax,QWORD PTR [rip+0x0]        # 1ba2 <botlish_fn_13+0x24f>
			1b9e: R_X86_64_GOTPCREL	rt_int_add-0x4
    1ba2:	mov    rsi,QWORD PTR [rsp+0x28]
    1ba7:	mov    rdi,QWORD PTR [rsp+0x10]
    1bac:	call   rax
    1bae:	mov    rdx,rax
    1bb1:	mov    rdi,QWORD PTR [rsp+0x10]
    1bb6:	mov    rdi,QWORD PTR [rsp+0x10]
    1bbb:	mov    QWORD PTR [rdi],r13
    1bbe:	mov    rax,r15
    1bc1:	mov    rbx,QWORD PTR [rsp+0x30]
    1bc6:	mov    r12,QWORD PTR [rsp+0x38]
    1bcb:	mov    r13,QWORD PTR [rsp+0x40]
    1bd0:	mov    r14,QWORD PTR [rsp+0x48]
    1bd5:	mov    r15,QWORD PTR [rsp+0x50]
    1bda:	add    rsp,0x60
    1bde:	mov    rsp,rbp
    1be1:	pop    rbp
    1be2:	ret
    1be3:	mov    rsi,QWORD PTR [rsp+0x28]
    1be8:	mov    edx,0x3
    1bed:	mov    r9,rdx
    1bf0:	mov    QWORD PTR [r13+0x10],0x3
    1bf8:	test   rsi,0x1
    1bff:	je     1c17 <botlish_fn_13+0x2c4>
    1c05:	mov    rdx,rsi
    1c08:	add    rdx,0x2
    1c0c:	seto   al
    1c0f:	test   al,al
    1c11:	je     1c2b <botlish_fn_13+0x2d8>
    1c17:	mov    rax,QWORD PTR [rip+0x0]        # 1c1e <botlish_fn_13+0x2cb>
			1c1a: R_X86_64_GOTPCREL	rt_int_add-0x4
    1c1e:	mov    rdx,r9
    1c21:	mov    rdi,QWORD PTR [rsp+0x10]
    1c26:	call   rax
    1c28:	mov    rdx,rax
    1c2b:	mov    QWORD PTR [r13+0x0],r12
    1c2f:	mov    QWORD PTR [r13+0x8],rdx
    1c33:	mov    rsi,QWORD PTR [rsp+0x20]
    1c38:	mov    QWORD PTR [r13+0x10],rsi
    1c3c:	mov    r14,rsi
    1c3f:	jmp    19ca <botlish_fn_13+0x77>
    1c44:	mov    QWORD PTR [rsp+0x10],rdi
    1c49:	mov    rax,QWORD PTR [rip+0x0]        # 1c50 <botlish_fn_13+0x2fd>
			1c4c: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1c50:	call   rax
    1c52:	xor    rdx,rdx
    1c55:	mov    rax,rdx
    1c58:	mov    rbx,QWORD PTR [rsp+0x30]
    1c5d:	mov    r12,QWORD PTR [rsp+0x38]
    1c62:	mov    r13,QWORD PTR [rsp+0x40]
    1c67:	mov    r14,QWORD PTR [rsp+0x48]
    1c6c:	mov    r15,QWORD PTR [rsp+0x50]
    1c71:	add    rsp,0x60
    1c75:	mov    rsp,rbp
    1c78:	pop    rbp
    1c79:	ret

0000000000001c7a <botlish_entry_13: scan_record<str, int, list[mutarray, int]>>:
    1c7a:	push   rbp
    1c7b:	mov    rbp,rsp
    1c7e:	ud2

0000000000001c80 <botlish_fn_14: scan_records<str, int, list[mutarray, int]>>:
    1c80:	push   rbp
    1c81:	mov    rbp,rsp
    1c84:	sub    rsp,0x30
    1c88:	mov    QWORD PTR [rsp],rbx
    1c8c:	mov    QWORD PTR [rsp+0x8],r12
    1c91:	mov    QWORD PTR [rsp+0x10],r13
    1c96:	mov    QWORD PTR [rsp+0x18],r14
    1c9b:	mov    QWORD PTR [rsp+0x20],r15
    1ca0:	mov    r12,QWORD PTR [rdi]
    1ca3:	mov    rax,QWORD PTR [rdi+0x8]
    1ca7:	lea    r8,[r12+0x20]
    1cac:	cmp    r8,rax
    1caf:	ja     1e4d <botlish_fn_14+0x1cd>
    1cb5:	lea    rax,[r12+0x20]
    1cba:	mov    QWORD PTR [rdi],rax
    1cbd:	mov    r14,rdi
    1cc0:	mov    QWORD PTR [r12],0x0
    1cc8:	mov    QWORD PTR [r12+0x8],0x0
    1cd1:	mov    QWORD PTR [r12+0x10],0x0
    1cda:	mov    QWORD PTR [r12+0x18],0x0
    1ce3:	mov    QWORD PTR [r12],rsi
    1ce7:	mov    QWORD PTR [r12+0x8],rdx
    1cec:	mov    r13,rdx
    1cef:	mov    QWORD PTR [r12+0x10],rcx
    1cf4:	mov    r15,rcx
    1cf7:	mov    rax,QWORD PTR [rip+0x0]        # 1cfe <botlish_fn_14+0x7e>
			1cfa: R_X86_64_GOTPCREL	rt_str_len-0x4
    1cfe:	mov    rbx,rsi
    1d01:	mov    rdi,r14
    1d04:	call   rax
    1d06:	mov    rcx,r13
    1d09:	and    rcx,rax
    1d0c:	mov    rdx,rax
    1d0f:	test   rcx,0x1
    1d16:	jne    1d40 <botlish_fn_14+0xc0>
    1d1c:	mov    rax,QWORD PTR [rip+0x0]        # 1d23 <botlish_fn_14+0xa3>
			1d1f: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1d23:	mov    rsi,r13
    1d26:	mov    rdi,r14
    1d29:	call   rax
    1d2b:	mov    ecx,0x2
    1d30:	test   rax,rax
    1d33:	cmovge rcx,QWORD PTR [rip+0x145]        # 1e80 <botlish_fn_14+0x200>
    1d3b:	jmp    1d53 <botlish_fn_14+0xd3>
    1d40:	mov    ecx,0x2
    1d45:	mov    r11,r13
    1d48:	cmp    r11,rdx
    1d4b:	cmovge rcx,QWORD PTR [rip+0x12d]        # 1e80 <botlish_fn_14+0x200>
    1d53:	cmp    rcx,0x6
    1d57:	je     1de5 <botlish_fn_14+0x165>
    1d5d:	mov    rdi,r14
    1d60:	call   1d65 <botlish_fn_14+0xe5>
			1d61: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1d65:	test   rax,rax
    1d68:	jne    1d76 <botlish_fn_14+0xf6>
    1d6e:	mov    rdi,r14
    1d71:	jmp    1dfc <botlish_fn_14+0x17c>
    1d76:	mov    QWORD PTR [r12+0x18],rax
    1d7b:	mov    rcx,rax
    1d7e:	mov    rdx,r13
    1d81:	mov    rsi,rbx
    1d84:	mov    rdi,r14
    1d87:	call   1d8c <botlish_fn_14+0x10c>
			1d88: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_record<str, int, list[mutarray, int]>
    1d8c:	test   rax,rax
    1d8f:	jne    1d9d <botlish_fn_14+0x11d>
    1d95:	mov    rdi,r14
    1d98:	jmp    1dfc <botlish_fn_14+0x17c>
    1d9d:	mov    QWORD PTR [r12+0x8],rax
    1da2:	mov    QWORD PTR [r12+0x18],rdx
    1da7:	mov    r13,rdx
    1daa:	mov    rsi,r15
    1dad:	mov    rdx,rax
    1db0:	mov    rdi,r14
    1db3:	call   1db8 <botlish_fn_14+0x138>
			1db4: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1db8:	test   rax,rax
    1dbb:	jne    1dc9 <botlish_fn_14+0x149>
    1dc1:	mov    rdi,r14
    1dc4:	jmp    1dfc <botlish_fn_14+0x17c>
    1dc9:	mov    QWORD PTR [r12],rbx
    1dcd:	mov    rdx,r13
    1dd0:	mov    QWORD PTR [r12+0x8],rdx
    1dd5:	mov    QWORD PTR [r12+0x10],rax
    1dda:	mov    rsi,rbx
    1ddd:	mov    r15,rax
    1de0:	jmp    1cf7 <botlish_fn_14+0x77>
    1de5:	mov    rsi,r15
    1de8:	mov    rdi,r14
    1deb:	call   1df0 <botlish_fn_14+0x170>
			1dec: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    1df0:	test   rax,rax
    1df3:	jne    1e26 <botlish_fn_14+0x1a6>
    1df9:	mov    rdi,r14
    1dfc:	mov    rdi,r14
    1dff:	mov    QWORD PTR [rdi],r12
    1e02:	xor    rax,rax
    1e05:	mov    rbx,QWORD PTR [rsp]
    1e09:	mov    r12,QWORD PTR [rsp+0x8]
    1e0e:	mov    r13,QWORD PTR [rsp+0x10]
    1e13:	mov    r14,QWORD PTR [rsp+0x18]
    1e18:	mov    r15,QWORD PTR [rsp+0x20]
    1e1d:	add    rsp,0x30
    1e21:	mov    rsp,rbp
    1e24:	pop    rbp
    1e25:	ret
    1e26:	mov    rdi,r14
    1e29:	mov    QWORD PTR [rdi],r12
    1e2c:	mov    rbx,QWORD PTR [rsp]
    1e30:	mov    r12,QWORD PTR [rsp+0x8]
    1e35:	mov    r13,QWORD PTR [rsp+0x10]
    1e3a:	mov    r14,QWORD PTR [rsp+0x18]
    1e3f:	mov    r15,QWORD PTR [rsp+0x20]
    1e44:	add    rsp,0x30
    1e48:	mov    rsp,rbp
    1e4b:	pop    rbp
    1e4c:	ret
    1e4d:	mov    r14,rdi
    1e50:	mov    r10,QWORD PTR [rip+0x0]        # 1e57 <botlish_fn_14+0x1d7>
			1e53: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1e57:	call   r10
    1e5a:	xor    rax,rax
    1e5d:	mov    rbx,QWORD PTR [rsp]
    1e61:	mov    r12,QWORD PTR [rsp+0x8]
    1e66:	mov    r13,QWORD PTR [rsp+0x10]
    1e6b:	mov    r14,QWORD PTR [rsp+0x18]
    1e70:	mov    r15,QWORD PTR [rsp+0x20]
    1e75:	add    rsp,0x30
    1e79:	mov    rsp,rbp
    1e7c:	pop    rbp
    1e7d:	ret
    1e7e:	add    BYTE PTR [rax],al
    1e80:	(bad)
    1e81:	add    BYTE PTR [rax],al
    1e83:	add    BYTE PTR [rax],al
    1e85:	add    BYTE PTR [rax],al
	...

0000000000001e88 <botlish_entry_14: scan_records<str, int, list[mutarray, int]>>:
    1e88:	push   rbp
    1e89:	mov    rbp,rsp
    1e8c:	mov    rsi,QWORD PTR [rdx]
    1e8f:	mov    r8,QWORD PTR [rdx+0x8]
    1e93:	mov    rcx,QWORD PTR [rdx+0x10]
    1e97:	mov    rdx,r8
    1e9a:	call   1e9f <botlish_entry_14+0x17>
			1e9b: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1e9f:	mov    rsp,rbp
    1ea2:	pop    rbp
    1ea3:	ret

0000000000001ea4 <botlish_fn_15: csv_parse<str>>:
    1ea4:	push   rbp
    1ea5:	mov    rbp,rsp
    1ea8:	sub    rsp,0x20
    1eac:	mov    QWORD PTR [rsp],rbx
    1eb0:	mov    QWORD PTR [rsp+0x8],r12
    1eb5:	mov    QWORD PTR [rsp+0x10],r15
    1eba:	mov    r15,QWORD PTR [rdi]
    1ebd:	mov    rax,QWORD PTR [rdi+0x8]
    1ec1:	lea    rcx,[r15+0x18]
    1ec5:	cmp    rcx,rax
    1ec8:	ja     1f76 <botlish_fn_15+0xd2>
    1ece:	lea    rax,[r15+0x18]
    1ed2:	mov    QWORD PTR [rdi],rax
    1ed5:	mov    rbx,rdi
    1ed8:	mov    QWORD PTR [r15],0x0
    1edf:	mov    QWORD PTR [r15+0x8],0x0
    1ee7:	mov    QWORD PTR [r15+0x10],0x0
    1eef:	mov    QWORD PTR [r15],rsi
    1ef2:	mov    r12,rsi
    1ef5:	mov    QWORD PTR [r15+0x8],0x1
    1efd:	mov    rdi,rbx
    1f00:	call   1f05 <botlish_fn_15+0x61>
			1f01: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1f05:	test   rax,rax
    1f08:	jne    1f16 <botlish_fn_15+0x72>
    1f0e:	mov    rdi,rbx
    1f11:	jmp    1f39 <botlish_fn_15+0x95>
    1f16:	mov    QWORD PTR [r15+0x10],rax
    1f1a:	mov    rcx,rax
    1f1d:	mov    edx,0x1
    1f22:	mov    rsi,r12
    1f25:	mov    rdi,rbx
    1f28:	call   1f2d <botlish_fn_15+0x89>
			1f29: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_records<str, int, list[mutarray, int]>
    1f2d:	test   rax,rax
    1f30:	jne    1f59 <botlish_fn_15+0xb5>
    1f36:	mov    rdi,rbx
    1f39:	mov    rdi,rbx
    1f3c:	mov    QWORD PTR [rdi],r15
    1f3f:	xor    rax,rax
    1f42:	mov    rbx,QWORD PTR [rsp]
    1f46:	mov    r12,QWORD PTR [rsp+0x8]
    1f4b:	mov    r15,QWORD PTR [rsp+0x10]
    1f50:	add    rsp,0x20
    1f54:	mov    rsp,rbp
    1f57:	pop    rbp
    1f58:	ret
    1f59:	mov    rdi,rbx
    1f5c:	mov    QWORD PTR [rdi],r15
    1f5f:	mov    rbx,QWORD PTR [rsp]
    1f63:	mov    r12,QWORD PTR [rsp+0x8]
    1f68:	mov    r15,QWORD PTR [rsp+0x10]
    1f6d:	add    rsp,0x20
    1f71:	mov    rsp,rbp
    1f74:	pop    rbp
    1f75:	ret
    1f76:	mov    rbx,rdi
    1f79:	mov    rax,QWORD PTR [rip+0x0]        # 1f80 <botlish_fn_15+0xdc>
			1f7c: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1f80:	call   rax
    1f82:	xor    rax,rax
    1f85:	mov    rbx,QWORD PTR [rsp]
    1f89:	mov    r12,QWORD PTR [rsp+0x8]
    1f8e:	mov    r15,QWORD PTR [rsp+0x10]
    1f93:	add    rsp,0x20
    1f97:	mov    rsp,rbp
    1f9a:	pop    rbp
    1f9b:	ret

0000000000001f9c <botlish_entry_15: csv_parse<str>>:
    1f9c:	push   rbp
    1f9d:	mov    rbp,rsp
    1fa0:	mov    rsi,QWORD PTR [rdx]
    1fa3:	call   1fa8 <botlish_entry_15+0xc>
			1fa4: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    1fa8:	mov    rsp,rbp
    1fab:	pop    rbp
    1fac:	ret

0000000000001fad <botlish_fn_16: ht_min_capacity<generic>>:
    1fad:	push   rbp
    1fae:	mov    rbp,rsp
    1fb1:	mov    r10,QWORD PTR [rdi]
    1fb4:	mov    r11,QWORD PTR [rdi+0x8]
    1fb8:	lea    rax,[r10+0x8]
    1fbc:	cmp    rax,r11
    1fbf:	ja     1fe0 <botlish_fn_16+0x33>
    1fc5:	lea    rax,[r10+0x8]
    1fc9:	mov    QWORD PTR [rdi],rax
    1fcc:	mov    QWORD PTR [r10],0x0
    1fd3:	mov    QWORD PTR [rdi],r10
    1fd6:	mov    eax,0x11
    1fdb:	mov    rsp,rbp
    1fde:	pop    rbp
    1fdf:	ret
    1fe0:	mov    rax,QWORD PTR [rip+0x0]        # 1fe7 <botlish_fn_16+0x3a>
			1fe3: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1fe7:	call   rax
    1fe9:	xor    rax,rax
    1fec:	mov    rsp,rbp
    1fef:	pop    rbp
    1ff0:	ret

0000000000001ff1 <botlish_entry_16: ht_min_capacity<generic>>:
    1ff1:	push   rbp
    1ff2:	mov    rbp,rsp
    1ff5:	call   1ffa <botlish_entry_16+0x9>
			1ff6: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    1ffa:	mov    rsp,rbp
    1ffd:	pop    rbp
    1ffe:	ret

0000000000001fff <botlish_fn_17: ht_empty_state<generic>>:
    1fff:	push   rbp
    2000:	mov    rbp,rsp
    2003:	mov    r10,QWORD PTR [rdi]
    2006:	mov    r11,QWORD PTR [rdi+0x8]
    200a:	lea    rax,[r10+0x8]
    200e:	cmp    rax,r11
    2011:	ja     2032 <botlish_fn_17+0x33>
    2017:	lea    rax,[r10+0x8]
    201b:	mov    QWORD PTR [rdi],rax
    201e:	mov    QWORD PTR [r10],0x0
    2025:	mov    QWORD PTR [rdi],r10
    2028:	mov    eax,0x1
    202d:	mov    rsp,rbp
    2030:	pop    rbp
    2031:	ret
    2032:	mov    rax,QWORD PTR [rip+0x0]        # 2039 <botlish_fn_17+0x3a>
			2035: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2039:	call   rax
    203b:	xor    rax,rax
    203e:	mov    rsp,rbp
    2041:	pop    rbp
    2042:	ret

0000000000002043 <botlish_entry_17: ht_empty_state<generic>>:
    2043:	push   rbp
    2044:	mov    rbp,rsp
    2047:	call   204c <botlish_entry_17+0x9>
			2048: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    204c:	mov    rsp,rbp
    204f:	pop    rbp
    2050:	ret

0000000000002051 <botlish_fn_18: ht_occupied_state<generic>>:
    2051:	push   rbp
    2052:	mov    rbp,rsp
    2055:	mov    r10,QWORD PTR [rdi]
    2058:	mov    r11,QWORD PTR [rdi+0x8]
    205c:	lea    rax,[r10+0x8]
    2060:	cmp    rax,r11
    2063:	ja     2084 <botlish_fn_18+0x33>
    2069:	lea    rax,[r10+0x8]
    206d:	mov    QWORD PTR [rdi],rax
    2070:	mov    QWORD PTR [r10],0x0
    2077:	mov    QWORD PTR [rdi],r10
    207a:	mov    eax,0x3
    207f:	mov    rsp,rbp
    2082:	pop    rbp
    2083:	ret
    2084:	mov    rax,QWORD PTR [rip+0x0]        # 208b <botlish_fn_18+0x3a>
			2087: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    208b:	call   rax
    208d:	xor    rax,rax
    2090:	mov    rsp,rbp
    2093:	pop    rbp
    2094:	ret

0000000000002095 <botlish_entry_18: ht_occupied_state<generic>>:
    2095:	push   rbp
    2096:	mov    rbp,rsp
    2099:	call   209e <botlish_entry_18+0x9>
			209a: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    209e:	mov    rsp,rbp
    20a1:	pop    rbp
    20a2:	ret

00000000000020a3 <botlish_fn_19: ht_tombstone_state<generic>>:
    20a3:	push   rbp
    20a4:	mov    rbp,rsp
    20a7:	mov    r10,QWORD PTR [rdi]
    20aa:	mov    r11,QWORD PTR [rdi+0x8]
    20ae:	lea    rax,[r10+0x8]
    20b2:	cmp    rax,r11
    20b5:	ja     20d6 <botlish_fn_19+0x33>
    20bb:	lea    rax,[r10+0x8]
    20bf:	mov    QWORD PTR [rdi],rax
    20c2:	mov    QWORD PTR [r10],0x0
    20c9:	mov    QWORD PTR [rdi],r10
    20cc:	mov    eax,0x5
    20d1:	mov    rsp,rbp
    20d4:	pop    rbp
    20d5:	ret
    20d6:	mov    rax,QWORD PTR [rip+0x0]        # 20dd <botlish_fn_19+0x3a>
			20d9: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    20dd:	call   rax
    20df:	xor    rax,rax
    20e2:	mov    rsp,rbp
    20e5:	pop    rbp
    20e6:	ret

00000000000020e7 <botlish_entry_19: ht_tombstone_state<generic>>:
    20e7:	push   rbp
    20e8:	mov    rbp,rsp
    20eb:	call   20f0 <botlish_entry_19+0x9>
			20ec: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    20f0:	mov    rsp,rbp
    20f3:	pop    rbp
    20f4:	ret
    20f5:	add    BYTE PTR [rax],al
	...

00000000000020f8 <botlish_fn_20: ht_fill_empty<mutarray, int, int>>:
    20f8:	push   rbp
    20f9:	mov    rbp,rsp
    20fc:	sub    rsp,0x30
    2100:	mov    QWORD PTR [rsp],rbx
    2104:	mov    QWORD PTR [rsp+0x8],r12
    2109:	mov    QWORD PTR [rsp+0x10],r13
    210e:	mov    QWORD PTR [rsp+0x18],r14
    2113:	mov    QWORD PTR [rsp+0x20],r15
    2118:	mov    r13,QWORD PTR [rdi]
    211b:	mov    r8,QWORD PTR [rdi+0x8]
    211f:	lea    rax,[r13+0x20]
    2123:	cmp    rax,r8
    2126:	ja     22b7 <botlish_fn_20+0x1bf>
    212c:	lea    rax,[r13+0x20]
    2130:	mov    QWORD PTR [rdi],rax
    2133:	mov    r14,rdi
    2136:	mov    QWORD PTR [r13+0x0],0x0
    213e:	mov    QWORD PTR [r13+0x8],0x0
    2146:	mov    QWORD PTR [r13+0x10],0x0
    214e:	mov    QWORD PTR [r13+0x18],0x0
    2156:	mov    QWORD PTR [r13+0x0],rsi
    215a:	mov    r12,rsi
    215d:	mov    QWORD PTR [r13+0x8],rdx
    2161:	mov    QWORD PTR [r13+0x10],rcx
    2165:	mov    rbx,rcx
    2168:	mov    rsi,rdx
    216b:	mov    rax,rsi
    216e:	and    rax,rbx
    2171:	mov    r15,rsi
    2174:	test   rax,0x1
    217a:	jne    21a7 <botlish_fn_20+0xaf>
    2180:	mov    rax,QWORD PTR [rip+0x0]        # 2187 <botlish_fn_20+0x8f>
			2183: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    2187:	mov    rdx,rbx
    218a:	mov    rsi,r15
    218d:	mov    rdi,r14
    2190:	call   rax
    2192:	mov    ecx,0x2
    2197:	test   rax,rax
    219a:	cmovge rcx,QWORD PTR [rip+0x146]        # 22e8 <botlish_fn_20+0x1f0>
    21a2:	jmp    21ba <botlish_fn_20+0xc2>
    21a7:	mov    ecx,0x2
    21ac:	mov    rsi,r15
    21af:	cmp    rsi,rbx
    21b2:	cmovge rcx,QWORD PTR [rip+0x12e]        # 22e8 <botlish_fn_20+0x1f0>
    21ba:	cmp    rcx,0x6
    21be:	je     228b <botlish_fn_20+0x193>
    21c4:	mov    rdi,r14
    21c7:	call   21cc <botlish_fn_20+0xd4>
			21c8: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    21cc:	test   rax,rax
    21cf:	mov    rcx,rax
    21d2:	jne    21e0 <botlish_fn_20+0xe8>
    21d8:	mov    rdi,r14
    21db:	jmp    21fe <botlish_fn_20+0x106>
    21e0:	mov    rax,QWORD PTR [rip+0x0]        # 21e7 <botlish_fn_20+0xef>
			21e3: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    21e7:	mov    rdx,r15
    21ea:	mov    rsi,r12
    21ed:	mov    rdi,r14
    21f0:	call   rax
    21f2:	test   rax,rax
    21f5:	jne    2228 <botlish_fn_20+0x130>
    21fb:	mov    rdi,r14
    21fe:	mov    rdi,r14
    2201:	mov    QWORD PTR [rdi],r13
    2204:	xor    rax,rax
    2207:	mov    rbx,QWORD PTR [rsp]
    220b:	mov    r12,QWORD PTR [rsp+0x8]
    2210:	mov    r13,QWORD PTR [rsp+0x10]
    2215:	mov    r14,QWORD PTR [rsp+0x18]
    221a:	mov    r15,QWORD PTR [rsp+0x20]
    221f:	add    rsp,0x30
    2223:	mov    rsp,rbp
    2226:	pop    rbp
    2227:	ret
    2228:	mov    QWORD PTR [r13+0x18],0x3
    2230:	mov    rsi,r15
    2233:	test   rsi,0x1
    223a:	je     225f <botlish_fn_20+0x167>
    2240:	mov    rsi,r15
    2243:	mov    rcx,rsi
    2246:	add    rcx,0x2
    224a:	seto   sil
    224e:	test   sil,sil
    2251:	jne    225f <botlish_fn_20+0x167>
    2257:	mov    r15,rcx
    225a:	jmp    2277 <botlish_fn_20+0x17f>
    225f:	mov    edx,0x3
    2264:	mov    r8,QWORD PTR [rip+0x0]        # 226b <botlish_fn_20+0x173>
			2267: R_X86_64_GOTPCREL	rt_int_add-0x4
    226b:	mov    rsi,r15
    226e:	mov    rdi,r14
    2271:	call   r8
    2274:	mov    r15,rax
    2277:	mov    QWORD PTR [r13+0x0],r12
    227b:	mov    rsi,r15
    227e:	mov    QWORD PTR [r13+0x8],rsi
    2282:	mov    QWORD PTR [r13+0x10],rbx
    2286:	jmp    216b <botlish_fn_20+0x73>
    228b:	mov    rdi,r14
    228e:	mov    QWORD PTR [rdi],r13
    2291:	mov    eax,0xa
    2296:	mov    rbx,QWORD PTR [rsp]
    229a:	mov    r12,QWORD PTR [rsp+0x8]
    229f:	mov    r13,QWORD PTR [rsp+0x10]
    22a4:	mov    r14,QWORD PTR [rsp+0x18]
    22a9:	mov    r15,QWORD PTR [rsp+0x20]
    22ae:	add    rsp,0x30
    22b2:	mov    rsp,rbp
    22b5:	pop    rbp
    22b6:	ret
    22b7:	mov    r14,rdi
    22ba:	mov    rax,QWORD PTR [rip+0x0]        # 22c1 <botlish_fn_20+0x1c9>
			22bd: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    22c1:	call   rax
    22c3:	xor    rax,rax
    22c6:	mov    rbx,QWORD PTR [rsp]
    22ca:	mov    r12,QWORD PTR [rsp+0x8]
    22cf:	mov    r13,QWORD PTR [rsp+0x10]
    22d4:	mov    r14,QWORD PTR [rsp+0x18]
    22d9:	mov    r15,QWORD PTR [rsp+0x20]
    22de:	add    rsp,0x30
    22e2:	mov    rsp,rbp
    22e5:	pop    rbp
    22e6:	ret
    22e7:	add    BYTE PTR [rsi],al
    22e9:	add    BYTE PTR [rax],al
    22eb:	add    BYTE PTR [rax],al
    22ed:	add    BYTE PTR [rax],al
	...

00000000000022f0 <botlish_entry_20: ht_fill_empty<mutarray, int, int>>:
    22f0:	push   rbp
    22f1:	mov    rbp,rsp
    22f4:	mov    rsi,QWORD PTR [rdx]
    22f7:	mov    r8,QWORD PTR [rdx+0x8]
    22fb:	mov    rcx,QWORD PTR [rdx+0x10]
    22ff:	mov    rdx,r8
    2302:	call   2307 <botlish_entry_20+0x17>
			2303: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    2307:	mov    rsp,rbp
    230a:	pop    rbp
    230b:	ret

000000000000230c <botlish_fn_21: ht_alloc<int>>:
    230c:	push   rbp
    230d:	mov    rbp,rsp
    2310:	sub    rsp,0x40
    2314:	mov    QWORD PTR [rsp+0x10],rbx
    2319:	mov    QWORD PTR [rsp+0x18],r12
    231e:	mov    QWORD PTR [rsp+0x20],r13
    2323:	mov    QWORD PTR [rsp+0x28],r14
    2328:	mov    QWORD PTR [rsp+0x30],r15
    232d:	mov    rbx,QWORD PTR [rdi]
    2330:	mov    rax,QWORD PTR [rdi+0x8]
    2334:	lea    rcx,[rbx+0x20]
    2338:	cmp    rcx,rax
    233b:	ja     2564 <botlish_fn_21+0x258>
    2341:	lea    rax,[rbx+0x20]
    2345:	mov    QWORD PTR [rdi],rax
    2348:	mov    r12,rdi
    234b:	mov    QWORD PTR [rbx],0x0
    2352:	mov    QWORD PTR [rbx+0x8],0x0
    235a:	mov    QWORD PTR [rbx+0x10],0x0
    2362:	mov    QWORD PTR [rbx+0x18],0x0
    236a:	mov    QWORD PTR [rbx],rsi
    236d:	mov    r13,rsi
    2370:	mov    rax,QWORD PTR [rip+0x0]        # 2377 <botlish_fn_21+0x6b>
			2373: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    2377:	mov    rsi,r13
    237a:	mov    rdi,r12
    237d:	call   rax
    237f:	test   rax,rax
    2382:	jne    2390 <botlish_fn_21+0x84>
    2388:	mov    rdi,r12
    238b:	jmp    250d <botlish_fn_21+0x201>
    2390:	mov    QWORD PTR [rbx+0x8],rax
    2394:	mov    r14,rax
    2397:	mov    edx,0x1
    239c:	mov    QWORD PTR [rbx+0x10],0x1
    23a4:	mov    rcx,r13
    23a7:	mov    rsi,r14
    23aa:	mov    rdi,r12
    23ad:	call   23b2 <botlish_fn_21+0xa6>
			23ae: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    23b2:	test   rax,rax
    23b5:	jne    23c3 <botlish_fn_21+0xb7>
    23bb:	mov    rdi,r12
    23be:	jmp    250d <botlish_fn_21+0x201>
    23c3:	mov    rax,QWORD PTR [rip+0x0]        # 23ca <botlish_fn_21+0xbe>
			23c6: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    23ca:	mov    rsi,r13
    23cd:	mov    rdi,r12
    23d0:	call   rax
    23d2:	test   rax,rax
    23d5:	jne    23e3 <botlish_fn_21+0xd7>
    23db:	mov    rdi,r12
    23de:	jmp    250d <botlish_fn_21+0x201>
    23e3:	mov    QWORD PTR [rbx+0x10],rax
    23e7:	mov    r15,rax
    23ea:	mov    rax,QWORD PTR [rip+0x0]        # 23f1 <botlish_fn_21+0xe5>
			23ed: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    23f1:	mov    rsi,r13
    23f4:	mov    rdi,r12
    23f7:	call   rax
    23f9:	test   rax,rax
    23fc:	jne    240a <botlish_fn_21+0xfe>
    2402:	mov    rdi,r12
    2405:	jmp    250d <botlish_fn_21+0x201>
    240a:	mov    QWORD PTR [rbx],rax
    240d:	mov    r13,rax
    2410:	mov    esi,0xb
    2415:	mov    QWORD PTR [rbx+0x18],0xb
    241d:	mov    r8,QWORD PTR [rip+0x0]        # 2424 <botlish_fn_21+0x118>
			2420: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    2424:	mov    rdi,r12
    2427:	call   r8
    242a:	test   rax,rax
    242d:	mov    QWORD PTR [rsp],rax
    2431:	jne    243f <botlish_fn_21+0x133>
    2437:	mov    rdi,r12
    243a:	jmp    250d <botlish_fn_21+0x201>
    243f:	mov    edx,0x1
    2444:	mov    r8,QWORD PTR [rip+0x0]        # 244b <botlish_fn_21+0x13f>
			2447: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    244b:	mov    rcx,r14
    244e:	mov    rsi,QWORD PTR [rsp]
    2452:	mov    rdi,r12
    2455:	call   r8
    2458:	test   rax,rax
    245b:	jne    2469 <botlish_fn_21+0x15d>
    2461:	mov    rdi,r12
    2464:	jmp    250d <botlish_fn_21+0x201>
    2469:	mov    edx,0x3
    246e:	mov    r9,QWORD PTR [rip+0x0]        # 2475 <botlish_fn_21+0x169>
			2471: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    2475:	mov    rcx,r15
    2478:	mov    rsi,QWORD PTR [rsp]
    247c:	mov    rdi,r12
    247f:	call   r9
    2482:	test   rax,rax
    2485:	jne    2493 <botlish_fn_21+0x187>
    248b:	mov    rdi,r12
    248e:	jmp    250d <botlish_fn_21+0x201>
    2493:	mov    edx,0x5
    2498:	mov    rax,QWORD PTR [rip+0x0]        # 249f <botlish_fn_21+0x193>
			249b: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    249f:	mov    rcx,r13
    24a2:	mov    rsi,QWORD PTR [rsp]
    24a6:	mov    rdi,r12
    24a9:	call   rax
    24ab:	test   rax,rax
    24ae:	jne    24bc <botlish_fn_21+0x1b0>
    24b4:	mov    rdi,r12
    24b7:	jmp    250d <botlish_fn_21+0x201>
    24bc:	mov    edx,0x7
    24c1:	mov    ecx,0x1
    24c6:	mov    rax,QWORD PTR [rip+0x0]        # 24cd <botlish_fn_21+0x1c1>
			24c9: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    24cd:	mov    rsi,QWORD PTR [rsp]
    24d1:	mov    rdi,r12
    24d4:	call   rax
    24d6:	test   rax,rax
    24d9:	jne    24e7 <botlish_fn_21+0x1db>
    24df:	mov    rdi,r12
    24e2:	jmp    250d <botlish_fn_21+0x201>
    24e7:	mov    edx,0x9
    24ec:	mov    ecx,0x1
    24f1:	mov    rax,QWORD PTR [rip+0x0]        # 24f8 <botlish_fn_21+0x1ec>
			24f4: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    24f8:	mov    rsi,QWORD PTR [rsp]
    24fc:	mov    rdi,r12
    24ff:	call   rax
    2501:	test   rax,rax
    2504:	jne    2538 <botlish_fn_21+0x22c>
    250a:	mov    rdi,r12
    250d:	mov    rdi,r12
    2510:	mov    QWORD PTR [rdi],rbx
    2513:	xor    rax,rax
    2516:	mov    rbx,QWORD PTR [rsp+0x10]
    251b:	mov    r12,QWORD PTR [rsp+0x18]
    2520:	mov    r13,QWORD PTR [rsp+0x20]
    2525:	mov    r14,QWORD PTR [rsp+0x28]
    252a:	mov    r15,QWORD PTR [rsp+0x30]
    252f:	add    rsp,0x40
    2533:	mov    rsp,rbp
    2536:	pop    rbp
    2537:	ret
    2538:	mov    rdi,r12
    253b:	mov    QWORD PTR [rdi],rbx
    253e:	mov    rax,QWORD PTR [rsp]
    2542:	mov    rbx,QWORD PTR [rsp+0x10]
    2547:	mov    r12,QWORD PTR [rsp+0x18]
    254c:	mov    r13,QWORD PTR [rsp+0x20]
    2551:	mov    r14,QWORD PTR [rsp+0x28]
    2556:	mov    r15,QWORD PTR [rsp+0x30]
    255b:	add    rsp,0x40
    255f:	mov    rsp,rbp
    2562:	pop    rbp
    2563:	ret
    2564:	mov    r12,rdi
    2567:	mov    rax,QWORD PTR [rip+0x0]        # 256e <botlish_fn_21+0x262>
			256a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    256e:	call   rax
    2570:	xor    rax,rax
    2573:	mov    rbx,QWORD PTR [rsp+0x10]
    2578:	mov    r12,QWORD PTR [rsp+0x18]
    257d:	mov    r13,QWORD PTR [rsp+0x20]
    2582:	mov    r14,QWORD PTR [rsp+0x28]
    2587:	mov    r15,QWORD PTR [rsp+0x30]
    258c:	add    rsp,0x40
    2590:	mov    rsp,rbp
    2593:	pop    rbp
    2594:	ret

0000000000002595 <botlish_entry_21: ht_alloc<int>>:
    2595:	push   rbp
    2596:	mov    rbp,rsp
    2599:	mov    rsi,QWORD PTR [rdx]
    259c:	call   25a1 <botlish_entry_21+0xc>
			259d: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    25a1:	mov    rsp,rbp
    25a4:	pop    rbp
    25a5:	ret

00000000000025a6 <botlish_fn_22: ht_new<generic>>:
    25a6:	push   rbp
    25a7:	mov    rbp,rsp
    25aa:	sub    rsp,0x10
    25ae:	mov    QWORD PTR [rsp],r13
    25b2:	mov    QWORD PTR [rsp+0x8],r14
    25b7:	mov    r13,QWORD PTR [rdi]
    25ba:	mov    rax,QWORD PTR [rdi+0x8]
    25be:	lea    rcx,[r13+0x8]
    25c2:	cmp    rcx,rax
    25c5:	ja     2644 <botlish_fn_22+0x9e>
    25cb:	lea    rax,[r13+0x8]
    25cf:	mov    QWORD PTR [rdi],rax
    25d2:	mov    r14,rdi
    25d5:	mov    QWORD PTR [r13+0x0],0x0
    25dd:	mov    rdi,r14
    25e0:	call   25e5 <botlish_fn_22+0x3f>
			25e1: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    25e5:	test   rax,rax
    25e8:	jne    25f6 <botlish_fn_22+0x50>
    25ee:	mov    rdi,r14
    25f1:	jmp    2611 <botlish_fn_22+0x6b>
    25f6:	mov    QWORD PTR [r13+0x0],rax
    25fa:	mov    rsi,rax
    25fd:	mov    rdi,r14
    2600:	call   2605 <botlish_fn_22+0x5f>
			2601: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    2605:	test   rax,rax
    2608:	jne    262c <botlish_fn_22+0x86>
    260e:	mov    rdi,r14
    2611:	mov    rdi,r14
    2614:	mov    QWORD PTR [rdi],r13
    2617:	xor    rax,rax
    261a:	mov    r13,QWORD PTR [rsp]
    261e:	mov    r14,QWORD PTR [rsp+0x8]
    2623:	add    rsp,0x10
    2627:	mov    rsp,rbp
    262a:	pop    rbp
    262b:	ret
    262c:	mov    rdi,r14
    262f:	mov    QWORD PTR [rdi],r13
    2632:	mov    r13,QWORD PTR [rsp]
    2636:	mov    r14,QWORD PTR [rsp+0x8]
    263b:	add    rsp,0x10
    263f:	mov    rsp,rbp
    2642:	pop    rbp
    2643:	ret
    2644:	mov    r14,rdi
    2647:	mov    rax,QWORD PTR [rip+0x0]        # 264e <botlish_fn_22+0xa8>
			264a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    264e:	call   rax
    2650:	xor    rax,rax
    2653:	mov    r13,QWORD PTR [rsp]
    2657:	mov    r14,QWORD PTR [rsp+0x8]
    265c:	add    rsp,0x10
    2660:	mov    rsp,rbp
    2663:	pop    rbp
    2664:	ret

0000000000002665 <botlish_entry_22: ht_new<generic>>:
    2665:	push   rbp
    2666:	mov    rbp,rsp
    2669:	call   266e <botlish_entry_22+0x9>
			266a: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    266e:	mov    rsp,rbp
    2671:	pop    rbp
    2672:	ret
    2673:	add    BYTE PTR [rax],al
    2675:	add    BYTE PTR [rax],al
	...

0000000000002678 <botlish_fn_23: ht_capacity_for<int, int>>:
    2678:	push   rbp
    2679:	mov    rbp,rsp
    267c:	sub    rsp,0x40
    2680:	mov    QWORD PTR [rsp+0x10],rbx
    2685:	mov    QWORD PTR [rsp+0x18],r12
    268a:	mov    QWORD PTR [rsp+0x20],r13
    268f:	mov    QWORD PTR [rsp+0x28],r14
    2694:	mov    QWORD PTR [rsp+0x30],r15
    2699:	mov    rbx,QWORD PTR [rdi]
    269c:	mov    rax,QWORD PTR [rdi+0x8]
    26a0:	lea    rcx,[rbx+0x18]
    26a4:	cmp    rcx,rax
    26a7:	ja     2868 <botlish_fn_23+0x1f0>
    26ad:	lea    rax,[rbx+0x18]
    26b1:	mov    QWORD PTR [rdi],rax
    26b4:	mov    r14,rdi
    26b7:	mov    QWORD PTR [rbx],0x0
    26be:	mov    QWORD PTR [rbx+0x8],0x0
    26c6:	mov    QWORD PTR [rbx+0x10],0x0
    26ce:	mov    QWORD PTR [rbx],rdx
    26d1:	mov    r12,rsi
    26d4:	or     r12,0x1
    26d8:	sar    r12,1
    26db:	mov    r13,rsi
    26de:	mov    r15,rdx
    26e1:	mov    rax,r13
    26e4:	or     rax,0x1
    26e8:	mov    QWORD PTR [rbx+0x8],rax
    26ec:	mov    QWORD PTR [rbx+0x10],0x7
    26f4:	mov    rax,r12
    26f7:	imul   QWORD PTR [rip+0x1a2]        # 28a0 <botlish_fn_23+0x228>
    26fe:	seto   cl
    2701:	or     rax,0x1
    2705:	test   cl,cl
    2707:	jne    2715 <botlish_fn_23+0x9d>
    270d:	mov    rsi,rax
    2710:	jmp    2730 <botlish_fn_23+0xb8>
    2715:	mov    rsi,r13
    2718:	or     rsi,0x1
    271c:	mov    edx,0x7
    2721:	mov    rax,QWORD PTR [rip+0x0]        # 2728 <botlish_fn_23+0xb0>
			2724: R_X86_64_GOTPCREL	rt_int_mul-0x4
    2728:	mov    rdi,r14
    272b:	call   rax
    272d:	mov    rsi,rax
    2730:	mov    QWORD PTR [rbx+0x8],rsi
    2734:	mov    QWORD PTR [rsp],rsi
    2738:	mov    QWORD PTR [rbx+0x10],0x5
    2740:	mov    rsi,r15
    2743:	test   rsi,0x1
    274a:	je     277d <botlish_fn_23+0x105>
    2750:	mov    rsi,r15
    2753:	mov    rax,rsi
    2756:	sar    rax,1
    2759:	imul   QWORD PTR [rip+0x148]        # 28a8 <botlish_fn_23+0x230>
    2760:	seto   dil
    2764:	or     rax,0x1
    2768:	test   dil,dil
    276b:	jne    277d <botlish_fn_23+0x105>
    2771:	mov    rdx,rax
    2774:	mov    rsi,QWORD PTR [rsp]
    2778:	jmp    2799 <botlish_fn_23+0x121>
    277d:	mov    edx,0x5
    2782:	mov    r9,QWORD PTR [rip+0x0]        # 2789 <botlish_fn_23+0x111>
			2785: R_X86_64_GOTPCREL	rt_int_mul-0x4
    2789:	mov    rsi,r15
    278c:	mov    rdi,r14
    278f:	call   r9
    2792:	mov    rdx,rax
    2795:	mov    rsi,QWORD PTR [rsp]
    2799:	mov    r10,rsi
    279c:	and    r10,rdx
    279f:	test   r10,0x1
    27a6:	jne    27cd <botlish_fn_23+0x155>
    27ac:	mov    rax,QWORD PTR [rip+0x0]        # 27b3 <botlish_fn_23+0x13b>
			27af: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    27b3:	mov    rdi,r14
    27b6:	call   rax
    27b8:	mov    ecx,0x2
    27bd:	test   rax,rax
    27c0:	cmovle rcx,QWORD PTR [rip+0xd8]        # 28a0 <botlish_fn_23+0x228>
    27c8:	jmp    27dd <botlish_fn_23+0x165>
    27cd:	mov    ecx,0x2
    27d2:	cmp    rsi,rdx
    27d5:	cmovle rcx,QWORD PTR [rip+0xc3]        # 28a0 <botlish_fn_23+0x228>
    27dd:	cmp    rcx,0x6
    27e1:	je     283d <botlish_fn_23+0x1c5>
    27e7:	mov    QWORD PTR [rbx+0x8],0x5
    27ef:	mov    rsi,r15
    27f2:	test   rsi,0x1
    27f9:	je     281e <botlish_fn_23+0x1a6>
    27ff:	mov    rsi,r15
    2802:	mov    rax,rsi
    2805:	sar    rax,1
    2808:	imul   QWORD PTR [rip+0x99]        # 28a8 <botlish_fn_23+0x230>
    280f:	seto   cl
    2812:	or     rax,0x1
    2816:	test   cl,cl
    2818:	je     2832 <botlish_fn_23+0x1ba>
    281e:	mov    edx,0x5
    2823:	mov    rax,QWORD PTR [rip+0x0]        # 282a <botlish_fn_23+0x1b2>
			2826: R_X86_64_GOTPCREL	rt_int_mul-0x4
    282a:	mov    rsi,r15
    282d:	mov    rdi,r14
    2830:	call   rax
    2832:	mov    QWORD PTR [rbx],rax
    2835:	mov    r15,rax
    2838:	jmp    26e1 <botlish_fn_23+0x69>
    283d:	mov    rdi,r14
    2840:	mov    QWORD PTR [rdi],rbx
    2843:	mov    rax,r15
    2846:	mov    rbx,QWORD PTR [rsp+0x10]
    284b:	mov    r12,QWORD PTR [rsp+0x18]
    2850:	mov    r13,QWORD PTR [rsp+0x20]
    2855:	mov    r14,QWORD PTR [rsp+0x28]
    285a:	mov    r15,QWORD PTR [rsp+0x30]
    285f:	add    rsp,0x40
    2863:	mov    rsp,rbp
    2866:	pop    rbp
    2867:	ret
    2868:	mov    r14,rdi
    286b:	mov    rax,QWORD PTR [rip+0x0]        # 2872 <botlish_fn_23+0x1fa>
			286e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2872:	call   rax
    2874:	xor    rax,rax
    2877:	mov    rbx,QWORD PTR [rsp+0x10]
    287c:	mov    r12,QWORD PTR [rsp+0x18]
    2881:	mov    r13,QWORD PTR [rsp+0x20]
    2886:	mov    r14,QWORD PTR [rsp+0x28]
    288b:	mov    r15,QWORD PTR [rsp+0x30]
    2890:	add    rsp,0x40
    2894:	mov    rsp,rbp
    2897:	pop    rbp
    2898:	ret
    2899:	add    BYTE PTR [rax],al
    289b:	add    BYTE PTR [rax],al
    289d:	add    BYTE PTR [rax],al
    289f:	add    BYTE PTR [rsi],al
    28a1:	add    BYTE PTR [rax],al
    28a3:	add    BYTE PTR [rax],al
    28a5:	add    BYTE PTR [rax],al
    28a7:	add    BYTE PTR [rax+rax*1],al
    28aa:	add    BYTE PTR [rax],al
    28ac:	add    BYTE PTR [rax],al
	...

00000000000028b0 <botlish_entry_23: ht_capacity_for<int, int>>:
    28b0:	push   rbp
    28b1:	mov    rbp,rsp
    28b4:	mov    rsi,QWORD PTR [rdx]
    28b7:	mov    rdx,QWORD PTR [rdx+0x8]
    28bb:	call   28c0 <botlish_entry_23+0x10>
			28bc: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    28c0:	mov    rsp,rbp
    28c3:	pop    rbp
    28c4:	ret

00000000000028c5 <botlish_fn_24: ht_new_sized<int>>:
    28c5:	push   rbp
    28c6:	mov    rbp,rsp
    28c9:	sub    rsp,0x20
    28cd:	mov    QWORD PTR [rsp],rbx
    28d1:	mov    QWORD PTR [rsp+0x8],r12
    28d6:	mov    QWORD PTR [rsp+0x10],r15
    28db:	mov    r15,QWORD PTR [rdi]
    28de:	mov    rax,QWORD PTR [rdi+0x8]
    28e2:	lea    rcx,[r15+0x10]
    28e6:	cmp    rcx,rax
    28e9:	ja     29a1 <botlish_fn_24+0xdc>
    28ef:	lea    rax,[r15+0x10]
    28f3:	mov    QWORD PTR [rdi],rax
    28f6:	mov    rbx,rdi
    28f9:	mov    QWORD PTR [r15],0x0
    2900:	mov    QWORD PTR [r15+0x8],0x0
    2908:	mov    QWORD PTR [r15],rsi
    290b:	mov    r12,rsi
    290e:	mov    rdi,rbx
    2911:	call   2916 <botlish_fn_24+0x51>
			2912: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_min_capacity<generic>
    2916:	test   rax,rax
    2919:	jne    2927 <botlish_fn_24+0x62>
    291f:	mov    rdi,rbx
    2922:	jmp    2964 <botlish_fn_24+0x9f>
    2927:	mov    QWORD PTR [r15+0x8],rax
    292b:	mov    rdx,rax
    292e:	mov    rsi,r12
    2931:	mov    rdi,rbx
    2934:	call   2939 <botlish_fn_24+0x74>
			2935: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_capacity_for<int, int>
    2939:	test   rax,rax
    293c:	jne    294a <botlish_fn_24+0x85>
    2942:	mov    rdi,rbx
    2945:	jmp    2964 <botlish_fn_24+0x9f>
    294a:	mov    QWORD PTR [r15],rax
    294d:	mov    rsi,rax
    2950:	mov    rdi,rbx
    2953:	call   2958 <botlish_fn_24+0x93>
			2954: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    2958:	test   rax,rax
    295b:	jne    2984 <botlish_fn_24+0xbf>
    2961:	mov    rdi,rbx
    2964:	mov    rdi,rbx
    2967:	mov    QWORD PTR [rdi],r15
    296a:	xor    rax,rax
    296d:	mov    rbx,QWORD PTR [rsp]
    2971:	mov    r12,QWORD PTR [rsp+0x8]
    2976:	mov    r15,QWORD PTR [rsp+0x10]
    297b:	add    rsp,0x20
    297f:	mov    rsp,rbp
    2982:	pop    rbp
    2983:	ret
    2984:	mov    rdi,rbx
    2987:	mov    QWORD PTR [rdi],r15
    298a:	mov    rbx,QWORD PTR [rsp]
    298e:	mov    r12,QWORD PTR [rsp+0x8]
    2993:	mov    r15,QWORD PTR [rsp+0x10]
    2998:	add    rsp,0x20
    299c:	mov    rsp,rbp
    299f:	pop    rbp
    29a0:	ret
    29a1:	mov    rbx,rdi
    29a4:	mov    rax,QWORD PTR [rip+0x0]        # 29ab <botlish_fn_24+0xe6>
			29a7: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    29ab:	call   rax
    29ad:	xor    rax,rax
    29b0:	mov    rbx,QWORD PTR [rsp]
    29b4:	mov    r12,QWORD PTR [rsp+0x8]
    29b9:	mov    r15,QWORD PTR [rsp+0x10]
    29be:	add    rsp,0x20
    29c2:	mov    rsp,rbp
    29c5:	pop    rbp
    29c6:	ret

00000000000029c7 <botlish_entry_24: ht_new_sized<int>>:
    29c7:	push   rbp
    29c8:	mov    rbp,rsp
    29cb:	mov    rsi,QWORD PTR [rdx]
    29ce:	call   29d3 <botlish_entry_24+0xc>
			29cf: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    29d3:	mov    rsp,rbp
    29d6:	pop    rbp
    29d7:	ret

00000000000029d8 <botlish_fn_25: ht_controls<mutarray>>:
    29d8:	push   rbp
    29d9:	mov    rbp,rsp
    29dc:	sub    rsp,0x10
    29e0:	mov    QWORD PTR [rsp],rbx
    29e4:	mov    QWORD PTR [rsp+0x8],r15
    29e9:	mov    r15,QWORD PTR [rdi]
    29ec:	mov    rax,QWORD PTR [rdi+0x8]
    29f0:	lea    rcx,[r15+0x8]
    29f4:	cmp    rcx,rax
    29f7:	ja     2a5b <botlish_fn_25+0x83>
    29fd:	lea    rax,[r15+0x8]
    2a01:	mov    QWORD PTR [rdi],rax
    2a04:	mov    rbx,rdi
    2a07:	mov    QWORD PTR [r15],0x0
    2a0e:	mov    edx,0x1
    2a13:	mov    rax,QWORD PTR [rip+0x0]        # 2a1a <botlish_fn_25+0x42>
			2a16: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2a1a:	mov    rdi,rbx
    2a1d:	call   rax
    2a1f:	test   rax,rax
    2a22:	jne    2a43 <botlish_fn_25+0x6b>
    2a28:	mov    rdi,rbx
    2a2b:	mov    QWORD PTR [rdi],r15
    2a2e:	xor    rax,rax
    2a31:	mov    rbx,QWORD PTR [rsp]
    2a35:	mov    r15,QWORD PTR [rsp+0x8]
    2a3a:	add    rsp,0x10
    2a3e:	mov    rsp,rbp
    2a41:	pop    rbp
    2a42:	ret
    2a43:	mov    rdi,rbx
    2a46:	mov    QWORD PTR [rdi],r15
    2a49:	mov    rbx,QWORD PTR [rsp]
    2a4d:	mov    r15,QWORD PTR [rsp+0x8]
    2a52:	add    rsp,0x10
    2a56:	mov    rsp,rbp
    2a59:	pop    rbp
    2a5a:	ret
    2a5b:	mov    rax,QWORD PTR [rip+0x0]        # 2a62 <botlish_fn_25+0x8a>
			2a5e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2a62:	call   rax
    2a64:	xor    rax,rax
    2a67:	mov    rbx,QWORD PTR [rsp]
    2a6b:	mov    r15,QWORD PTR [rsp+0x8]
    2a70:	add    rsp,0x10
    2a74:	mov    rsp,rbp
    2a77:	pop    rbp
    2a78:	ret

0000000000002a79 <botlish_entry_25: ht_controls<mutarray>>:
    2a79:	push   rbp
    2a7a:	mov    rbp,rsp
    2a7d:	mov    rsi,QWORD PTR [rdx]
    2a80:	call   2a85 <botlish_entry_25+0xc>
			2a81: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    2a85:	mov    rsp,rbp
    2a88:	pop    rbp
    2a89:	ret

0000000000002a8a <botlish_fn_26: ht_controls<generic>>:
    2a8a:	push   rbp
    2a8b:	mov    rbp,rsp
    2a8e:	sub    rsp,0x10
    2a92:	mov    QWORD PTR [rsp],rbx
    2a96:	mov    QWORD PTR [rsp+0x8],r12
    2a9b:	mov    rbx,QWORD PTR [rdi]
    2a9e:	mov    rax,QWORD PTR [rdi+0x8]
    2aa2:	lea    rcx,[rbx+0x8]
    2aa6:	cmp    rcx,rax
    2aa9:	ja     2b4e <botlish_fn_26+0xc4>
    2aaf:	lea    rax,[rbx+0x8]
    2ab3:	mov    QWORD PTR [rdi],rax
    2ab6:	mov    QWORD PTR [rbx],0x0
    2abd:	xor    ecx,ecx
    2abf:	test   rsi,0x7
    2ac6:	jne    2ad5 <botlish_fn_26+0x4b>
    2acc:	movzx  rax,BYTE PTR [rsi]
    2ad0:	cmp    al,0x8
    2ad2:	sete   cl
    2ad5:	test   cl,cl
    2ad7:	jne    2afe <botlish_fn_26+0x74>
    2add:	mov    rax,QWORD PTR [rdi+0x10]
    2ae1:	mov    r12,rdi
    2ae4:	mov    rcx,QWORD PTR [rax+0x20]
    2ae8:	mov    edx,0x8
    2aed:	mov    rax,QWORD PTR [rip+0x0]        # 2af4 <botlish_fn_26+0x6a>
			2af0: R_X86_64_GOTPCREL	rt_type_error-0x4
    2af4:	call   rax
    2af6:	mov    rdi,r12
    2af9:	jmp    2b1b <botlish_fn_26+0x91>
    2afe:	mov    r12,rdi
    2b01:	mov    edx,0x1
    2b06:	mov    rax,QWORD PTR [rip+0x0]        # 2b0d <botlish_fn_26+0x83>
			2b09: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2b0d:	call   rax
    2b0f:	test   rax,rax
    2b12:	jne    2b36 <botlish_fn_26+0xac>
    2b18:	mov    rdi,r12
    2b1b:	mov    rdi,r12
    2b1e:	mov    QWORD PTR [rdi],rbx
    2b21:	xor    rax,rax
    2b24:	mov    rbx,QWORD PTR [rsp]
    2b28:	mov    r12,QWORD PTR [rsp+0x8]
    2b2d:	add    rsp,0x10
    2b31:	mov    rsp,rbp
    2b34:	pop    rbp
    2b35:	ret
    2b36:	mov    rdi,r12
    2b39:	mov    QWORD PTR [rdi],rbx
    2b3c:	mov    rbx,QWORD PTR [rsp]
    2b40:	mov    r12,QWORD PTR [rsp+0x8]
    2b45:	add    rsp,0x10
    2b49:	mov    rsp,rbp
    2b4c:	pop    rbp
    2b4d:	ret
    2b4e:	mov    r12,rdi
    2b51:	mov    rax,QWORD PTR [rip+0x0]        # 2b58 <botlish_fn_26+0xce>
			2b54: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2b58:	call   rax
    2b5a:	xor    rax,rax
    2b5d:	mov    rbx,QWORD PTR [rsp]
    2b61:	mov    r12,QWORD PTR [rsp+0x8]
    2b66:	add    rsp,0x10
    2b6a:	mov    rsp,rbp
    2b6d:	pop    rbp
    2b6e:	ret

0000000000002b6f <botlish_entry_26: ht_controls<generic>>:
    2b6f:	push   rbp
    2b70:	mov    rbp,rsp
    2b73:	mov    rsi,QWORD PTR [rdx]
    2b76:	call   2b7b <botlish_entry_26+0xc>
			2b77: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    2b7b:	mov    rsp,rbp
    2b7e:	pop    rbp
    2b7f:	ret

0000000000002b80 <botlish_fn_27: ht_keys<mutarray>>:
    2b80:	push   rbp
    2b81:	mov    rbp,rsp
    2b84:	sub    rsp,0x10
    2b88:	mov    QWORD PTR [rsp],rbx
    2b8c:	mov    QWORD PTR [rsp+0x8],r15
    2b91:	mov    r15,QWORD PTR [rdi]
    2b94:	mov    rax,QWORD PTR [rdi+0x8]
    2b98:	lea    rcx,[r15+0x8]
    2b9c:	cmp    rcx,rax
    2b9f:	ja     2c03 <botlish_fn_27+0x83>
    2ba5:	lea    rax,[r15+0x8]
    2ba9:	mov    QWORD PTR [rdi],rax
    2bac:	mov    rbx,rdi
    2baf:	mov    QWORD PTR [r15],0x0
    2bb6:	mov    edx,0x3
    2bbb:	mov    rax,QWORD PTR [rip+0x0]        # 2bc2 <botlish_fn_27+0x42>
			2bbe: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2bc2:	mov    rdi,rbx
    2bc5:	call   rax
    2bc7:	test   rax,rax
    2bca:	jne    2beb <botlish_fn_27+0x6b>
    2bd0:	mov    rdi,rbx
    2bd3:	mov    QWORD PTR [rdi],r15
    2bd6:	xor    rax,rax
    2bd9:	mov    rbx,QWORD PTR [rsp]
    2bdd:	mov    r15,QWORD PTR [rsp+0x8]
    2be2:	add    rsp,0x10
    2be6:	mov    rsp,rbp
    2be9:	pop    rbp
    2bea:	ret
    2beb:	mov    rdi,rbx
    2bee:	mov    QWORD PTR [rdi],r15
    2bf1:	mov    rbx,QWORD PTR [rsp]
    2bf5:	mov    r15,QWORD PTR [rsp+0x8]
    2bfa:	add    rsp,0x10
    2bfe:	mov    rsp,rbp
    2c01:	pop    rbp
    2c02:	ret
    2c03:	mov    rax,QWORD PTR [rip+0x0]        # 2c0a <botlish_fn_27+0x8a>
			2c06: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2c0a:	call   rax
    2c0c:	xor    rax,rax
    2c0f:	mov    rbx,QWORD PTR [rsp]
    2c13:	mov    r15,QWORD PTR [rsp+0x8]
    2c18:	add    rsp,0x10
    2c1c:	mov    rsp,rbp
    2c1f:	pop    rbp
    2c20:	ret

0000000000002c21 <botlish_entry_27: ht_keys<mutarray>>:
    2c21:	push   rbp
    2c22:	mov    rbp,rsp
    2c25:	mov    rsi,QWORD PTR [rdx]
    2c28:	call   2c2d <botlish_entry_27+0xc>
			2c29: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    2c2d:	mov    rsp,rbp
    2c30:	pop    rbp
    2c31:	ret

0000000000002c32 <botlish_fn_28: ht_keys<generic>>:
    2c32:	push   rbp
    2c33:	mov    rbp,rsp
    2c36:	sub    rsp,0x10
    2c3a:	mov    QWORD PTR [rsp],rbx
    2c3e:	mov    QWORD PTR [rsp+0x8],r12
    2c43:	mov    rbx,QWORD PTR [rdi]
    2c46:	mov    rax,QWORD PTR [rdi+0x8]
    2c4a:	lea    rcx,[rbx+0x8]
    2c4e:	cmp    rcx,rax
    2c51:	ja     2cf6 <botlish_fn_28+0xc4>
    2c57:	lea    rax,[rbx+0x8]
    2c5b:	mov    QWORD PTR [rdi],rax
    2c5e:	mov    QWORD PTR [rbx],0x0
    2c65:	xor    ecx,ecx
    2c67:	test   rsi,0x7
    2c6e:	jne    2c7d <botlish_fn_28+0x4b>
    2c74:	movzx  rax,BYTE PTR [rsi]
    2c78:	cmp    al,0x8
    2c7a:	sete   cl
    2c7d:	test   cl,cl
    2c7f:	jne    2ca6 <botlish_fn_28+0x74>
    2c85:	mov    rax,QWORD PTR [rdi+0x10]
    2c89:	mov    r12,rdi
    2c8c:	mov    rcx,QWORD PTR [rax+0x20]
    2c90:	mov    edx,0x8
    2c95:	mov    rax,QWORD PTR [rip+0x0]        # 2c9c <botlish_fn_28+0x6a>
			2c98: R_X86_64_GOTPCREL	rt_type_error-0x4
    2c9c:	call   rax
    2c9e:	mov    rdi,r12
    2ca1:	jmp    2cc3 <botlish_fn_28+0x91>
    2ca6:	mov    r12,rdi
    2ca9:	mov    edx,0x3
    2cae:	mov    rax,QWORD PTR [rip+0x0]        # 2cb5 <botlish_fn_28+0x83>
			2cb1: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2cb5:	call   rax
    2cb7:	test   rax,rax
    2cba:	jne    2cde <botlish_fn_28+0xac>
    2cc0:	mov    rdi,r12
    2cc3:	mov    rdi,r12
    2cc6:	mov    QWORD PTR [rdi],rbx
    2cc9:	xor    rax,rax
    2ccc:	mov    rbx,QWORD PTR [rsp]
    2cd0:	mov    r12,QWORD PTR [rsp+0x8]
    2cd5:	add    rsp,0x10
    2cd9:	mov    rsp,rbp
    2cdc:	pop    rbp
    2cdd:	ret
    2cde:	mov    rdi,r12
    2ce1:	mov    QWORD PTR [rdi],rbx
    2ce4:	mov    rbx,QWORD PTR [rsp]
    2ce8:	mov    r12,QWORD PTR [rsp+0x8]
    2ced:	add    rsp,0x10
    2cf1:	mov    rsp,rbp
    2cf4:	pop    rbp
    2cf5:	ret
    2cf6:	mov    r12,rdi
    2cf9:	mov    rax,QWORD PTR [rip+0x0]        # 2d00 <botlish_fn_28+0xce>
			2cfc: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2d00:	call   rax
    2d02:	xor    rax,rax
    2d05:	mov    rbx,QWORD PTR [rsp]
    2d09:	mov    r12,QWORD PTR [rsp+0x8]
    2d0e:	add    rsp,0x10
    2d12:	mov    rsp,rbp
    2d15:	pop    rbp
    2d16:	ret

0000000000002d17 <botlish_entry_28: ht_keys<generic>>:
    2d17:	push   rbp
    2d18:	mov    rbp,rsp
    2d1b:	mov    rsi,QWORD PTR [rdx]
    2d1e:	call   2d23 <botlish_entry_28+0xc>
			2d1f: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    2d23:	mov    rsp,rbp
    2d26:	pop    rbp
    2d27:	ret

0000000000002d28 <botlish_fn_29: ht_values<mutarray>>:
    2d28:	push   rbp
    2d29:	mov    rbp,rsp
    2d2c:	sub    rsp,0x10
    2d30:	mov    QWORD PTR [rsp],rbx
    2d34:	mov    QWORD PTR [rsp+0x8],r15
    2d39:	mov    r15,QWORD PTR [rdi]
    2d3c:	mov    rax,QWORD PTR [rdi+0x8]
    2d40:	lea    rcx,[r15+0x8]
    2d44:	cmp    rcx,rax
    2d47:	ja     2dab <botlish_fn_29+0x83>
    2d4d:	lea    rax,[r15+0x8]
    2d51:	mov    QWORD PTR [rdi],rax
    2d54:	mov    rbx,rdi
    2d57:	mov    QWORD PTR [r15],0x0
    2d5e:	mov    edx,0x5
    2d63:	mov    rax,QWORD PTR [rip+0x0]        # 2d6a <botlish_fn_29+0x42>
			2d66: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2d6a:	mov    rdi,rbx
    2d6d:	call   rax
    2d6f:	test   rax,rax
    2d72:	jne    2d93 <botlish_fn_29+0x6b>
    2d78:	mov    rdi,rbx
    2d7b:	mov    QWORD PTR [rdi],r15
    2d7e:	xor    rax,rax
    2d81:	mov    rbx,QWORD PTR [rsp]
    2d85:	mov    r15,QWORD PTR [rsp+0x8]
    2d8a:	add    rsp,0x10
    2d8e:	mov    rsp,rbp
    2d91:	pop    rbp
    2d92:	ret
    2d93:	mov    rdi,rbx
    2d96:	mov    QWORD PTR [rdi],r15
    2d99:	mov    rbx,QWORD PTR [rsp]
    2d9d:	mov    r15,QWORD PTR [rsp+0x8]
    2da2:	add    rsp,0x10
    2da6:	mov    rsp,rbp
    2da9:	pop    rbp
    2daa:	ret
    2dab:	mov    rax,QWORD PTR [rip+0x0]        # 2db2 <botlish_fn_29+0x8a>
			2dae: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2db2:	call   rax
    2db4:	xor    rax,rax
    2db7:	mov    rbx,QWORD PTR [rsp]
    2dbb:	mov    r15,QWORD PTR [rsp+0x8]
    2dc0:	add    rsp,0x10
    2dc4:	mov    rsp,rbp
    2dc7:	pop    rbp
    2dc8:	ret

0000000000002dc9 <botlish_entry_29: ht_values<mutarray>>:
    2dc9:	push   rbp
    2dca:	mov    rbp,rsp
    2dcd:	mov    rsi,QWORD PTR [rdx]
    2dd0:	call   2dd5 <botlish_entry_29+0xc>
			2dd1: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    2dd5:	mov    rsp,rbp
    2dd8:	pop    rbp
    2dd9:	ret

0000000000002dda <botlish_fn_30: ht_values<generic>>:
    2dda:	push   rbp
    2ddb:	mov    rbp,rsp
    2dde:	sub    rsp,0x10
    2de2:	mov    QWORD PTR [rsp],rbx
    2de6:	mov    QWORD PTR [rsp+0x8],r12
    2deb:	mov    rbx,QWORD PTR [rdi]
    2dee:	mov    rax,QWORD PTR [rdi+0x8]
    2df2:	lea    rcx,[rbx+0x8]
    2df6:	cmp    rcx,rax
    2df9:	ja     2e9e <botlish_fn_30+0xc4>
    2dff:	lea    rax,[rbx+0x8]
    2e03:	mov    QWORD PTR [rdi],rax
    2e06:	mov    QWORD PTR [rbx],0x0
    2e0d:	xor    ecx,ecx
    2e0f:	test   rsi,0x7
    2e16:	jne    2e25 <botlish_fn_30+0x4b>
    2e1c:	movzx  rax,BYTE PTR [rsi]
    2e20:	cmp    al,0x8
    2e22:	sete   cl
    2e25:	test   cl,cl
    2e27:	jne    2e4e <botlish_fn_30+0x74>
    2e2d:	mov    rax,QWORD PTR [rdi+0x10]
    2e31:	mov    r12,rdi
    2e34:	mov    rcx,QWORD PTR [rax+0x20]
    2e38:	mov    edx,0x8
    2e3d:	mov    rax,QWORD PTR [rip+0x0]        # 2e44 <botlish_fn_30+0x6a>
			2e40: R_X86_64_GOTPCREL	rt_type_error-0x4
    2e44:	call   rax
    2e46:	mov    rdi,r12
    2e49:	jmp    2e6b <botlish_fn_30+0x91>
    2e4e:	mov    r12,rdi
    2e51:	mov    edx,0x5
    2e56:	mov    rax,QWORD PTR [rip+0x0]        # 2e5d <botlish_fn_30+0x83>
			2e59: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2e5d:	call   rax
    2e5f:	test   rax,rax
    2e62:	jne    2e86 <botlish_fn_30+0xac>
    2e68:	mov    rdi,r12
    2e6b:	mov    rdi,r12
    2e6e:	mov    QWORD PTR [rdi],rbx
    2e71:	xor    rax,rax
    2e74:	mov    rbx,QWORD PTR [rsp]
    2e78:	mov    r12,QWORD PTR [rsp+0x8]
    2e7d:	add    rsp,0x10
    2e81:	mov    rsp,rbp
    2e84:	pop    rbp
    2e85:	ret
    2e86:	mov    rdi,r12
    2e89:	mov    QWORD PTR [rdi],rbx
    2e8c:	mov    rbx,QWORD PTR [rsp]
    2e90:	mov    r12,QWORD PTR [rsp+0x8]
    2e95:	add    rsp,0x10
    2e99:	mov    rsp,rbp
    2e9c:	pop    rbp
    2e9d:	ret
    2e9e:	mov    r12,rdi
    2ea1:	mov    rax,QWORD PTR [rip+0x0]        # 2ea8 <botlish_fn_30+0xce>
			2ea4: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2ea8:	call   rax
    2eaa:	xor    rax,rax
    2ead:	mov    rbx,QWORD PTR [rsp]
    2eb1:	mov    r12,QWORD PTR [rsp+0x8]
    2eb6:	add    rsp,0x10
    2eba:	mov    rsp,rbp
    2ebd:	pop    rbp
    2ebe:	ret

0000000000002ebf <botlish_entry_30: ht_values<generic>>:
    2ebf:	push   rbp
    2ec0:	mov    rbp,rsp
    2ec3:	mov    rsi,QWORD PTR [rdx]
    2ec6:	call   2ecb <botlish_entry_30+0xc>
			2ec7: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    2ecb:	mov    rsp,rbp
    2ece:	pop    rbp
    2ecf:	ret

0000000000002ed0 <botlish_fn_31: ht_size<mutarray>>:
    2ed0:	push   rbp
    2ed1:	mov    rbp,rsp
    2ed4:	sub    rsp,0x10
    2ed8:	mov    QWORD PTR [rsp],rbx
    2edc:	mov    QWORD PTR [rsp+0x8],r15
    2ee1:	mov    r15,QWORD PTR [rdi]
    2ee4:	mov    rax,QWORD PTR [rdi+0x8]
    2ee8:	lea    rcx,[r15+0x8]
    2eec:	cmp    rcx,rax
    2eef:	ja     2f53 <botlish_fn_31+0x83>
    2ef5:	lea    rax,[r15+0x8]
    2ef9:	mov    QWORD PTR [rdi],rax
    2efc:	mov    rbx,rdi
    2eff:	mov    QWORD PTR [r15],0x0
    2f06:	mov    edx,0x7
    2f0b:	mov    rax,QWORD PTR [rip+0x0]        # 2f12 <botlish_fn_31+0x42>
			2f0e: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    2f12:	mov    rdi,rbx
    2f15:	call   rax
    2f17:	test   rax,rax
    2f1a:	jne    2f3b <botlish_fn_31+0x6b>
    2f20:	mov    rdi,rbx
    2f23:	mov    QWORD PTR [rdi],r15
    2f26:	xor    rax,rax
    2f29:	mov    rbx,QWORD PTR [rsp]
    2f2d:	mov    r15,QWORD PTR [rsp+0x8]
    2f32:	add    rsp,0x10
    2f36:	mov    rsp,rbp
    2f39:	pop    rbp
    2f3a:	ret
    2f3b:	mov    rdi,rbx
    2f3e:	mov    QWORD PTR [rdi],r15
    2f41:	mov    rbx,QWORD PTR [rsp]
    2f45:	mov    r15,QWORD PTR [rsp+0x8]
    2f4a:	add    rsp,0x10
    2f4e:	mov    rsp,rbp
    2f51:	pop    rbp
    2f52:	ret
    2f53:	mov    rax,QWORD PTR [rip+0x0]        # 2f5a <botlish_fn_31+0x8a>
			2f56: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2f5a:	call   rax
    2f5c:	xor    rax,rax
    2f5f:	mov    rbx,QWORD PTR [rsp]
    2f63:	mov    r15,QWORD PTR [rsp+0x8]
    2f68:	add    rsp,0x10
    2f6c:	mov    rsp,rbp
    2f6f:	pop    rbp
    2f70:	ret

0000000000002f71 <botlish_entry_31: ht_size<mutarray>>:
    2f71:	push   rbp
    2f72:	mov    rbp,rsp
    2f75:	mov    rsi,QWORD PTR [rdx]
    2f78:	call   2f7d <botlish_entry_31+0xc>
			2f79: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    2f7d:	mov    rsp,rbp
    2f80:	pop    rbp
    2f81:	ret

0000000000002f82 <botlish_fn_32: ht_size<generic>>:
    2f82:	push   rbp
    2f83:	mov    rbp,rsp
    2f86:	sub    rsp,0x10
    2f8a:	mov    QWORD PTR [rsp],rbx
    2f8e:	mov    QWORD PTR [rsp+0x8],r12
    2f93:	mov    rbx,QWORD PTR [rdi]
    2f96:	mov    rax,QWORD PTR [rdi+0x8]
    2f9a:	lea    rcx,[rbx+0x8]
    2f9e:	cmp    rcx,rax
    2fa1:	ja     3046 <botlish_fn_32+0xc4>
    2fa7:	lea    rax,[rbx+0x8]
    2fab:	mov    QWORD PTR [rdi],rax
    2fae:	mov    QWORD PTR [rbx],0x0
    2fb5:	xor    ecx,ecx
    2fb7:	test   rsi,0x7
    2fbe:	jne    2fcd <botlish_fn_32+0x4b>
    2fc4:	movzx  rax,BYTE PTR [rsi]
    2fc8:	cmp    al,0x8
    2fca:	sete   cl
    2fcd:	test   cl,cl
    2fcf:	jne    2ff6 <botlish_fn_32+0x74>
    2fd5:	mov    rax,QWORD PTR [rdi+0x10]
    2fd9:	mov    r12,rdi
    2fdc:	mov    rcx,QWORD PTR [rax+0x20]
    2fe0:	mov    edx,0x8
    2fe5:	mov    rax,QWORD PTR [rip+0x0]        # 2fec <botlish_fn_32+0x6a>
			2fe8: R_X86_64_GOTPCREL	rt_type_error-0x4
    2fec:	call   rax
    2fee:	mov    rdi,r12
    2ff1:	jmp    3013 <botlish_fn_32+0x91>
    2ff6:	mov    r12,rdi
    2ff9:	mov    edx,0x7
    2ffe:	mov    rax,QWORD PTR [rip+0x0]        # 3005 <botlish_fn_32+0x83>
			3001: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    3005:	call   rax
    3007:	test   rax,rax
    300a:	jne    302e <botlish_fn_32+0xac>
    3010:	mov    rdi,r12
    3013:	mov    rdi,r12
    3016:	mov    QWORD PTR [rdi],rbx
    3019:	xor    rax,rax
    301c:	mov    rbx,QWORD PTR [rsp]
    3020:	mov    r12,QWORD PTR [rsp+0x8]
    3025:	add    rsp,0x10
    3029:	mov    rsp,rbp
    302c:	pop    rbp
    302d:	ret
    302e:	mov    rdi,r12
    3031:	mov    QWORD PTR [rdi],rbx
    3034:	mov    rbx,QWORD PTR [rsp]
    3038:	mov    r12,QWORD PTR [rsp+0x8]
    303d:	add    rsp,0x10
    3041:	mov    rsp,rbp
    3044:	pop    rbp
    3045:	ret
    3046:	mov    r12,rdi
    3049:	mov    rax,QWORD PTR [rip+0x0]        # 3050 <botlish_fn_32+0xce>
			304c: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3050:	call   rax
    3052:	xor    rax,rax
    3055:	mov    rbx,QWORD PTR [rsp]
    3059:	mov    r12,QWORD PTR [rsp+0x8]
    305e:	add    rsp,0x10
    3062:	mov    rsp,rbp
    3065:	pop    rbp
    3066:	ret

0000000000003067 <botlish_entry_32: ht_size<generic>>:
    3067:	push   rbp
    3068:	mov    rbp,rsp
    306b:	mov    rsi,QWORD PTR [rdx]
    306e:	call   3073 <botlish_entry_32+0xc>
			306f: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    3073:	mov    rsp,rbp
    3076:	pop    rbp
    3077:	ret

0000000000003078 <botlish_fn_33: ht_tombstones<mutarray>>:
    3078:	push   rbp
    3079:	mov    rbp,rsp
    307c:	sub    rsp,0x10
    3080:	mov    QWORD PTR [rsp],rbx
    3084:	mov    QWORD PTR [rsp+0x8],r15
    3089:	mov    r15,QWORD PTR [rdi]
    308c:	mov    rax,QWORD PTR [rdi+0x8]
    3090:	lea    rcx,[r15+0x8]
    3094:	cmp    rcx,rax
    3097:	ja     30fb <botlish_fn_33+0x83>
    309d:	lea    rax,[r15+0x8]
    30a1:	mov    QWORD PTR [rdi],rax
    30a4:	mov    rbx,rdi
    30a7:	mov    QWORD PTR [r15],0x0
    30ae:	mov    edx,0x9
    30b3:	mov    rax,QWORD PTR [rip+0x0]        # 30ba <botlish_fn_33+0x42>
			30b6: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    30ba:	mov    rdi,rbx
    30bd:	call   rax
    30bf:	test   rax,rax
    30c2:	jne    30e3 <botlish_fn_33+0x6b>
    30c8:	mov    rdi,rbx
    30cb:	mov    QWORD PTR [rdi],r15
    30ce:	xor    rax,rax
    30d1:	mov    rbx,QWORD PTR [rsp]
    30d5:	mov    r15,QWORD PTR [rsp+0x8]
    30da:	add    rsp,0x10
    30de:	mov    rsp,rbp
    30e1:	pop    rbp
    30e2:	ret
    30e3:	mov    rdi,rbx
    30e6:	mov    QWORD PTR [rdi],r15
    30e9:	mov    rbx,QWORD PTR [rsp]
    30ed:	mov    r15,QWORD PTR [rsp+0x8]
    30f2:	add    rsp,0x10
    30f6:	mov    rsp,rbp
    30f9:	pop    rbp
    30fa:	ret
    30fb:	mov    rax,QWORD PTR [rip+0x0]        # 3102 <botlish_fn_33+0x8a>
			30fe: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3102:	call   rax
    3104:	xor    rax,rax
    3107:	mov    rbx,QWORD PTR [rsp]
    310b:	mov    r15,QWORD PTR [rsp+0x8]
    3110:	add    rsp,0x10
    3114:	mov    rsp,rbp
    3117:	pop    rbp
    3118:	ret

0000000000003119 <botlish_entry_33: ht_tombstones<mutarray>>:
    3119:	push   rbp
    311a:	mov    rbp,rsp
    311d:	mov    rsi,QWORD PTR [rdx]
    3120:	call   3125 <botlish_entry_33+0xc>
			3121: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    3125:	mov    rsp,rbp
    3128:	pop    rbp
    3129:	ret

000000000000312a <botlish_fn_34: ht_capacity<mutarray>>:
    312a:	push   rbp
    312b:	mov    rbp,rsp
    312e:	sub    rsp,0x10
    3132:	mov    QWORD PTR [rsp],rbx
    3136:	mov    QWORD PTR [rsp+0x8],r12
    313b:	mov    rbx,QWORD PTR [rdi]
    313e:	mov    rax,QWORD PTR [rdi+0x8]
    3142:	lea    rcx,[rbx+0x8]
    3146:	cmp    rcx,rax
    3149:	ja     31fc <botlish_fn_34+0xd2>
    314f:	lea    rax,[rbx+0x8]
    3153:	mov    QWORD PTR [rdi],rax
    3156:	mov    r12,rdi
    3159:	mov    QWORD PTR [rbx],rsi
    315c:	mov    rdi,r12
    315f:	call   3164 <botlish_fn_34+0x3a>
			3160: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    3164:	test   rax,rax
    3167:	jne    3175 <botlish_fn_34+0x4b>
    316d:	mov    rdi,r12
    3170:	jmp    31bd <botlish_fn_34+0x93>
    3175:	xor    ecx,ecx
    3177:	test   rax,0x7
    317d:	je     318b <botlish_fn_34+0x61>
    3183:	mov    rsi,rax
    3186:	jmp    3199 <botlish_fn_34+0x6f>
    318b:	movzx  rcx,BYTE PTR [rax]
    318f:	mov    rsi,rax
    3192:	rex cmp cl,0x8
    3196:	sete   cl
    3199:	test   cl,cl
    319b:	jne    31d8 <botlish_fn_34+0xae>
    31a1:	mov    rdi,r12
    31a4:	mov    rax,QWORD PTR [rdi+0x10]
    31a8:	mov    rcx,QWORD PTR [rax+0x28]
    31ac:	mov    edx,0x8
    31b1:	mov    rax,QWORD PTR [rip+0x0]        # 31b8 <botlish_fn_34+0x8e>
			31b4: R_X86_64_GOTPCREL	rt_type_error-0x4
    31b8:	call   rax
    31ba:	mov    rdi,r12
    31bd:	mov    rdi,r12
    31c0:	mov    QWORD PTR [rdi],rbx
    31c3:	xor    rax,rax
    31c6:	mov    rbx,QWORD PTR [rsp]
    31ca:	mov    r12,QWORD PTR [rsp+0x8]
    31cf:	add    rsp,0x10
    31d3:	mov    rsp,rbp
    31d6:	pop    rbp
    31d7:	ret
    31d8:	mov    rax,QWORD PTR [rip+0x0]        # 31df <botlish_fn_34+0xb5>
			31db: R_X86_64_GOTPCREL	rt_mutarray_capacity-0x4
    31df:	mov    rdi,r12
    31e2:	call   rax
    31e4:	mov    rdi,r12
    31e7:	mov    QWORD PTR [rdi],rbx
    31ea:	mov    rbx,QWORD PTR [rsp]
    31ee:	mov    r12,QWORD PTR [rsp+0x8]
    31f3:	add    rsp,0x10
    31f7:	mov    rsp,rbp
    31fa:	pop    rbp
    31fb:	ret
    31fc:	mov    r12,rdi
    31ff:	mov    rax,QWORD PTR [rip+0x0]        # 3206 <botlish_fn_34+0xdc>
			3202: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3206:	call   rax
    3208:	xor    rax,rax
    320b:	mov    rbx,QWORD PTR [rsp]
    320f:	mov    r12,QWORD PTR [rsp+0x8]
    3214:	add    rsp,0x10
    3218:	mov    rsp,rbp
    321b:	pop    rbp
    321c:	ret

000000000000321d <botlish_entry_34: ht_capacity<mutarray>>:
    321d:	push   rbp
    321e:	mov    rbp,rsp
    3221:	mov    rsi,QWORD PTR [rdx]
    3224:	call   3229 <botlish_entry_34+0xc>
			3225: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3229:	mov    rsp,rbp
    322c:	pop    rbp
    322d:	ret

000000000000322e <botlish_fn_35: ht_capacity<generic>>:
    322e:	push   rbp
    322f:	mov    rbp,rsp
    3232:	sub    rsp,0x10
    3236:	mov    QWORD PTR [rsp],rbx
    323a:	mov    QWORD PTR [rsp+0x8],r12
    323f:	mov    rbx,QWORD PTR [rdi]
    3242:	mov    rax,QWORD PTR [rdi+0x8]
    3246:	lea    rcx,[rbx+0x8]
    324a:	cmp    rcx,rax
    324d:	ja     3300 <botlish_fn_35+0xd2>
    3253:	lea    rax,[rbx+0x8]
    3257:	mov    QWORD PTR [rdi],rax
    325a:	mov    r12,rdi
    325d:	mov    QWORD PTR [rbx],rsi
    3260:	mov    rdi,r12
    3263:	call   3268 <botlish_fn_35+0x3a>
			3264: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    3268:	test   rax,rax
    326b:	jne    3279 <botlish_fn_35+0x4b>
    3271:	mov    rdi,r12
    3274:	jmp    32c1 <botlish_fn_35+0x93>
    3279:	xor    ecx,ecx
    327b:	test   rax,0x7
    3281:	je     328f <botlish_fn_35+0x61>
    3287:	mov    rsi,rax
    328a:	jmp    329d <botlish_fn_35+0x6f>
    328f:	movzx  rcx,BYTE PTR [rax]
    3293:	mov    rsi,rax
    3296:	rex cmp cl,0x8
    329a:	sete   cl
    329d:	test   cl,cl
    329f:	jne    32dc <botlish_fn_35+0xae>
    32a5:	mov    rdi,r12
    32a8:	mov    rax,QWORD PTR [rdi+0x10]
    32ac:	mov    rcx,QWORD PTR [rax+0x28]
    32b0:	mov    edx,0x8
    32b5:	mov    rax,QWORD PTR [rip+0x0]        # 32bc <botlish_fn_35+0x8e>
			32b8: R_X86_64_GOTPCREL	rt_type_error-0x4
    32bc:	call   rax
    32be:	mov    rdi,r12
    32c1:	mov    rdi,r12
    32c4:	mov    QWORD PTR [rdi],rbx
    32c7:	xor    rax,rax
    32ca:	mov    rbx,QWORD PTR [rsp]
    32ce:	mov    r12,QWORD PTR [rsp+0x8]
    32d3:	add    rsp,0x10
    32d7:	mov    rsp,rbp
    32da:	pop    rbp
    32db:	ret
    32dc:	mov    rax,QWORD PTR [rip+0x0]        # 32e3 <botlish_fn_35+0xb5>
			32df: R_X86_64_GOTPCREL	rt_mutarray_capacity-0x4
    32e3:	mov    rdi,r12
    32e6:	call   rax
    32e8:	mov    rdi,r12
    32eb:	mov    QWORD PTR [rdi],rbx
    32ee:	mov    rbx,QWORD PTR [rsp]
    32f2:	mov    r12,QWORD PTR [rsp+0x8]
    32f7:	add    rsp,0x10
    32fb:	mov    rsp,rbp
    32fe:	pop    rbp
    32ff:	ret
    3300:	mov    r12,rdi
    3303:	mov    rax,QWORD PTR [rip+0x0]        # 330a <botlish_fn_35+0xdc>
			3306: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    330a:	call   rax
    330c:	xor    rax,rax
    330f:	mov    rbx,QWORD PTR [rsp]
    3313:	mov    r12,QWORD PTR [rsp+0x8]
    3318:	add    rsp,0x10
    331c:	mov    rsp,rbp
    331f:	pop    rbp
    3320:	ret

0000000000003321 <botlish_entry_35: ht_capacity<generic>>:
    3321:	push   rbp
    3322:	mov    rbp,rsp
    3325:	mov    rsi,QWORD PTR [rdx]
    3328:	call   332d <botlish_entry_35+0xc>
			3329: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    332d:	mov    rsp,rbp
    3330:	pop    rbp
    3331:	ret

0000000000003332 <botlish_fn_36: ht_probe_start<mutarray, any>>:
    3332:	push   rbp
    3333:	mov    rbp,rsp
    3336:	sub    rsp,0x20
    333a:	mov    QWORD PTR [rsp],rbx
    333e:	mov    QWORD PTR [rsp+0x8],r12
    3343:	mov    QWORD PTR [rsp+0x10],r13
    3348:	mov    rbx,QWORD PTR [rdi]
    334b:	mov    rax,QWORD PTR [rdi+0x8]
    334f:	lea    rcx,[rbx+0x10]
    3353:	cmp    rcx,rax
    3356:	ja     3419 <botlish_fn_36+0xe7>
    335c:	lea    rax,[rbx+0x10]
    3360:	mov    QWORD PTR [rdi],rax
    3363:	mov    r12,rdi
    3366:	mov    QWORD PTR [rbx],0x0
    336d:	mov    QWORD PTR [rbx+0x8],0x0
    3375:	mov    QWORD PTR [rbx],rsi
    3378:	mov    r13,rsi
    337b:	mov    rax,QWORD PTR [rip+0x0]        # 3382 <botlish_fn_36+0x50>
			337e: R_X86_64_GOTPCREL	rt_hash-0x4
    3382:	mov    rsi,rdx
    3385:	mov    rdi,r12
    3388:	call   rax
    338a:	test   rax,rax
    338d:	jne    339b <botlish_fn_36+0x69>
    3393:	mov    rdi,r12
    3396:	jmp    33dc <botlish_fn_36+0xaa>
    339b:	mov    QWORD PTR [rbx+0x8],rax
    339f:	mov    rsi,r13
    33a2:	mov    r13,rax
    33a5:	mov    rdi,r12
    33a8:	call   33ad <botlish_fn_36+0x7b>
			33a9: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    33ad:	test   rax,rax
    33b0:	mov    rdx,rax
    33b3:	jne    33c1 <botlish_fn_36+0x8f>
    33b9:	mov    rdi,r12
    33bc:	jmp    33dc <botlish_fn_36+0xaa>
    33c1:	mov    rax,QWORD PTR [rip+0x0]        # 33c8 <botlish_fn_36+0x96>
			33c4: R_X86_64_GOTPCREL	rt_int_mod-0x4
    33c8:	mov    rsi,r13
    33cb:	mov    rdi,r12
    33ce:	call   rax
    33d0:	test   rax,rax
    33d3:	jne    33fc <botlish_fn_36+0xca>
    33d9:	mov    rdi,r12
    33dc:	mov    rdi,r12
    33df:	mov    QWORD PTR [rdi],rbx
    33e2:	xor    rax,rax
    33e5:	mov    rbx,QWORD PTR [rsp]
    33e9:	mov    r12,QWORD PTR [rsp+0x8]
    33ee:	mov    r13,QWORD PTR [rsp+0x10]
    33f3:	add    rsp,0x20
    33f7:	mov    rsp,rbp
    33fa:	pop    rbp
    33fb:	ret
    33fc:	mov    rdi,r12
    33ff:	mov    QWORD PTR [rdi],rbx
    3402:	mov    rbx,QWORD PTR [rsp]
    3406:	mov    r12,QWORD PTR [rsp+0x8]
    340b:	mov    r13,QWORD PTR [rsp+0x10]
    3410:	add    rsp,0x20
    3414:	mov    rsp,rbp
    3417:	pop    rbp
    3418:	ret
    3419:	mov    r12,rdi
    341c:	mov    rax,QWORD PTR [rip+0x0]        # 3423 <botlish_fn_36+0xf1>
			341f: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3423:	call   rax
    3425:	xor    rax,rax
    3428:	mov    rbx,QWORD PTR [rsp]
    342c:	mov    r12,QWORD PTR [rsp+0x8]
    3431:	mov    r13,QWORD PTR [rsp+0x10]
    3436:	add    rsp,0x20
    343a:	mov    rsp,rbp
    343d:	pop    rbp
    343e:	ret

000000000000343f <botlish_entry_36: ht_probe_start<mutarray, any>>:
    343f:	push   rbp
    3440:	mov    rbp,rsp
    3443:	mov    rsi,QWORD PTR [rdx]
    3446:	mov    rdx,QWORD PTR [rdx+0x8]
    344a:	call   344f <botlish_entry_36+0x10>
			344b: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    344f:	mov    rsp,rbp
    3452:	pop    rbp
    3453:	ret

0000000000003454 <botlish_fn_37: ht_probe_start<any, str>>:
    3454:	push   rbp
    3455:	mov    rbp,rsp
    3458:	sub    rsp,0x20
    345c:	mov    QWORD PTR [rsp],rbx
    3460:	mov    QWORD PTR [rsp+0x8],r12
    3465:	mov    QWORD PTR [rsp+0x10],r13
    346a:	mov    rbx,QWORD PTR [rdi]
    346d:	mov    rax,QWORD PTR [rdi+0x8]
    3471:	lea    rcx,[rbx+0x10]
    3475:	cmp    rcx,rax
    3478:	ja     353b <botlish_fn_37+0xe7>
    347e:	lea    rax,[rbx+0x10]
    3482:	mov    QWORD PTR [rdi],rax
    3485:	mov    r12,rdi
    3488:	mov    QWORD PTR [rbx],0x0
    348f:	mov    QWORD PTR [rbx+0x8],0x0
    3497:	mov    QWORD PTR [rbx],rsi
    349a:	mov    r13,rsi
    349d:	mov    rax,QWORD PTR [rip+0x0]        # 34a4 <botlish_fn_37+0x50>
			34a0: R_X86_64_GOTPCREL	rt_hash-0x4
    34a4:	mov    rsi,rdx
    34a7:	mov    rdi,r12
    34aa:	call   rax
    34ac:	test   rax,rax
    34af:	jne    34bd <botlish_fn_37+0x69>
    34b5:	mov    rdi,r12
    34b8:	jmp    34fe <botlish_fn_37+0xaa>
    34bd:	mov    QWORD PTR [rbx+0x8],rax
    34c1:	mov    rsi,r13
    34c4:	mov    r13,rax
    34c7:	mov    rdi,r12
    34ca:	call   34cf <botlish_fn_37+0x7b>
			34cb: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    34cf:	test   rax,rax
    34d2:	mov    rdx,rax
    34d5:	jne    34e3 <botlish_fn_37+0x8f>
    34db:	mov    rdi,r12
    34de:	jmp    34fe <botlish_fn_37+0xaa>
    34e3:	mov    rax,QWORD PTR [rip+0x0]        # 34ea <botlish_fn_37+0x96>
			34e6: R_X86_64_GOTPCREL	rt_int_mod-0x4
    34ea:	mov    rsi,r13
    34ed:	mov    rdi,r12
    34f0:	call   rax
    34f2:	test   rax,rax
    34f5:	jne    351e <botlish_fn_37+0xca>
    34fb:	mov    rdi,r12
    34fe:	mov    rdi,r12
    3501:	mov    QWORD PTR [rdi],rbx
    3504:	xor    rax,rax
    3507:	mov    rbx,QWORD PTR [rsp]
    350b:	mov    r12,QWORD PTR [rsp+0x8]
    3510:	mov    r13,QWORD PTR [rsp+0x10]
    3515:	add    rsp,0x20
    3519:	mov    rsp,rbp
    351c:	pop    rbp
    351d:	ret
    351e:	mov    rdi,r12
    3521:	mov    QWORD PTR [rdi],rbx
    3524:	mov    rbx,QWORD PTR [rsp]
    3528:	mov    r12,QWORD PTR [rsp+0x8]
    352d:	mov    r13,QWORD PTR [rsp+0x10]
    3532:	add    rsp,0x20
    3536:	mov    rsp,rbp
    3539:	pop    rbp
    353a:	ret
    353b:	mov    r12,rdi
    353e:	mov    rax,QWORD PTR [rip+0x0]        # 3545 <botlish_fn_37+0xf1>
			3541: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3545:	call   rax
    3547:	xor    rax,rax
    354a:	mov    rbx,QWORD PTR [rsp]
    354e:	mov    r12,QWORD PTR [rsp+0x8]
    3553:	mov    r13,QWORD PTR [rsp+0x10]
    3558:	add    rsp,0x20
    355c:	mov    rsp,rbp
    355f:	pop    rbp
    3560:	ret

0000000000003561 <botlish_entry_37: ht_probe_start<any, str>>:
    3561:	push   rbp
    3562:	mov    rbp,rsp
    3565:	mov    rsi,QWORD PTR [rdx]
    3568:	mov    rdx,QWORD PTR [rdx+0x8]
    356c:	call   3571 <botlish_entry_37+0x10>
			356d: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    3571:	mov    rsp,rbp
    3574:	pop    rbp
    3575:	ret

0000000000003576 <botlish_fn_38: ht_probe_next<mutarray, int>>:
    3576:	push   rbp
    3577:	mov    rbp,rsp
    357a:	sub    rsp,0x20
    357e:	mov    QWORD PTR [rsp],rbx
    3582:	mov    QWORD PTR [rsp+0x8],r12
    3587:	mov    QWORD PTR [rsp+0x10],r13
    358c:	mov    rbx,QWORD PTR [rdi]
    358f:	mov    rax,QWORD PTR [rdi+0x8]
    3593:	lea    rcx,[rbx+0x18]
    3597:	cmp    rcx,rax
    359a:	ja     3695 <botlish_fn_38+0x11f>
    35a0:	lea    rax,[rbx+0x18]
    35a4:	mov    QWORD PTR [rdi],rax
    35a7:	mov    r12,rdi
    35aa:	mov    QWORD PTR [rbx],0x0
    35b1:	mov    QWORD PTR [rbx+0x8],0x0
    35b9:	mov    QWORD PTR [rbx+0x10],0x0
    35c1:	mov    QWORD PTR [rbx],rsi
    35c4:	mov    r13,rsi
    35c7:	mov    QWORD PTR [rbx+0x8],rdx
    35cb:	mov    QWORD PTR [rbx+0x10],0x3
    35d3:	test   rdx,0x1
    35da:	jne    35e8 <botlish_fn_38+0x72>
    35e0:	mov    rcx,rdx
    35e3:	jmp    35fd <botlish_fn_38+0x87>
    35e8:	mov    rsi,rdx
    35eb:	add    rsi,0x2
    35ef:	mov    rcx,rdx
    35f2:	seto   al
    35f5:	test   al,al
    35f7:	je     3614 <botlish_fn_38+0x9e>
    35fd:	mov    edx,0x3
    3602:	mov    rax,QWORD PTR [rip+0x0]        # 3609 <botlish_fn_38+0x93>
			3605: R_X86_64_GOTPCREL	rt_int_add-0x4
    3609:	mov    rsi,rcx
    360c:	mov    rdi,r12
    360f:	call   rax
    3611:	mov    rsi,rax
    3614:	mov    QWORD PTR [rbx+0x8],rsi
    3618:	mov    rax,rsi
    361b:	mov    rsi,r13
    361e:	mov    r13,rax
    3621:	mov    rdi,r12
    3624:	call   3629 <botlish_fn_38+0xb3>
			3625: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    3629:	test   rax,rax
    362c:	mov    rdx,rax
    362f:	jne    363d <botlish_fn_38+0xc7>
    3635:	mov    rdi,r12
    3638:	jmp    3658 <botlish_fn_38+0xe2>
    363d:	mov    rax,QWORD PTR [rip+0x0]        # 3644 <botlish_fn_38+0xce>
			3640: R_X86_64_GOTPCREL	rt_int_mod-0x4
    3644:	mov    rsi,r13
    3647:	mov    rdi,r12
    364a:	call   rax
    364c:	test   rax,rax
    364f:	jne    3678 <botlish_fn_38+0x102>
    3655:	mov    rdi,r12
    3658:	mov    rdi,r12
    365b:	mov    QWORD PTR [rdi],rbx
    365e:	xor    rax,rax
    3661:	mov    rbx,QWORD PTR [rsp]
    3665:	mov    r12,QWORD PTR [rsp+0x8]
    366a:	mov    r13,QWORD PTR [rsp+0x10]
    366f:	add    rsp,0x20
    3673:	mov    rsp,rbp
    3676:	pop    rbp
    3677:	ret
    3678:	mov    rdi,r12
    367b:	mov    QWORD PTR [rdi],rbx
    367e:	mov    rbx,QWORD PTR [rsp]
    3682:	mov    r12,QWORD PTR [rsp+0x8]
    3687:	mov    r13,QWORD PTR [rsp+0x10]
    368c:	add    rsp,0x20
    3690:	mov    rsp,rbp
    3693:	pop    rbp
    3694:	ret
    3695:	mov    r12,rdi
    3698:	mov    rax,QWORD PTR [rip+0x0]        # 369f <botlish_fn_38+0x129>
			369b: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    369f:	call   rax
    36a1:	xor    rax,rax
    36a4:	mov    rbx,QWORD PTR [rsp]
    36a8:	mov    r12,QWORD PTR [rsp+0x8]
    36ad:	mov    r13,QWORD PTR [rsp+0x10]
    36b2:	add    rsp,0x20
    36b6:	mov    rsp,rbp
    36b9:	pop    rbp
    36ba:	ret

00000000000036bb <botlish_entry_38: ht_probe_next<mutarray, int>>:
    36bb:	push   rbp
    36bc:	mov    rbp,rsp
    36bf:	mov    rsi,QWORD PTR [rdx]
    36c2:	mov    rdx,QWORD PTR [rdx+0x8]
    36c6:	call   36cb <botlish_entry_38+0x10>
			36c7: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    36cb:	mov    rsp,rbp
    36ce:	pop    rbp
    36cf:	ret

00000000000036d0 <botlish_fn_39: ht_probe_next<any, int>>:
    36d0:	push   rbp
    36d1:	mov    rbp,rsp
    36d4:	sub    rsp,0x20
    36d8:	mov    QWORD PTR [rsp],rbx
    36dc:	mov    QWORD PTR [rsp+0x8],r12
    36e1:	mov    QWORD PTR [rsp+0x10],r13
    36e6:	mov    rbx,QWORD PTR [rdi]
    36e9:	mov    rax,QWORD PTR [rdi+0x8]
    36ed:	lea    rcx,[rbx+0x18]
    36f1:	cmp    rcx,rax
    36f4:	ja     37ef <botlish_fn_39+0x11f>
    36fa:	lea    rax,[rbx+0x18]
    36fe:	mov    QWORD PTR [rdi],rax
    3701:	mov    r12,rdi
    3704:	mov    QWORD PTR [rbx],0x0
    370b:	mov    QWORD PTR [rbx+0x8],0x0
    3713:	mov    QWORD PTR [rbx+0x10],0x0
    371b:	mov    QWORD PTR [rbx],rsi
    371e:	mov    r13,rsi
    3721:	mov    QWORD PTR [rbx+0x8],rdx
    3725:	mov    QWORD PTR [rbx+0x10],0x3
    372d:	test   rdx,0x1
    3734:	jne    3742 <botlish_fn_39+0x72>
    373a:	mov    rcx,rdx
    373d:	jmp    3757 <botlish_fn_39+0x87>
    3742:	mov    rsi,rdx
    3745:	add    rsi,0x2
    3749:	mov    rcx,rdx
    374c:	seto   al
    374f:	test   al,al
    3751:	je     376e <botlish_fn_39+0x9e>
    3757:	mov    edx,0x3
    375c:	mov    rax,QWORD PTR [rip+0x0]        # 3763 <botlish_fn_39+0x93>
			375f: R_X86_64_GOTPCREL	rt_int_add-0x4
    3763:	mov    rsi,rcx
    3766:	mov    rdi,r12
    3769:	call   rax
    376b:	mov    rsi,rax
    376e:	mov    QWORD PTR [rbx+0x8],rsi
    3772:	mov    rax,rsi
    3775:	mov    rsi,r13
    3778:	mov    r13,rax
    377b:	mov    rdi,r12
    377e:	call   3783 <botlish_fn_39+0xb3>
			377f: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_capacity<generic>
    3783:	test   rax,rax
    3786:	mov    rdx,rax
    3789:	jne    3797 <botlish_fn_39+0xc7>
    378f:	mov    rdi,r12
    3792:	jmp    37b2 <botlish_fn_39+0xe2>
    3797:	mov    rax,QWORD PTR [rip+0x0]        # 379e <botlish_fn_39+0xce>
			379a: R_X86_64_GOTPCREL	rt_int_mod-0x4
    379e:	mov    rsi,r13
    37a1:	mov    rdi,r12
    37a4:	call   rax
    37a6:	test   rax,rax
    37a9:	jne    37d2 <botlish_fn_39+0x102>
    37af:	mov    rdi,r12
    37b2:	mov    rdi,r12
    37b5:	mov    QWORD PTR [rdi],rbx
    37b8:	xor    rax,rax
    37bb:	mov    rbx,QWORD PTR [rsp]
    37bf:	mov    r12,QWORD PTR [rsp+0x8]
    37c4:	mov    r13,QWORD PTR [rsp+0x10]
    37c9:	add    rsp,0x20
    37cd:	mov    rsp,rbp
    37d0:	pop    rbp
    37d1:	ret
    37d2:	mov    rdi,r12
    37d5:	mov    QWORD PTR [rdi],rbx
    37d8:	mov    rbx,QWORD PTR [rsp]
    37dc:	mov    r12,QWORD PTR [rsp+0x8]
    37e1:	mov    r13,QWORD PTR [rsp+0x10]
    37e6:	add    rsp,0x20
    37ea:	mov    rsp,rbp
    37ed:	pop    rbp
    37ee:	ret
    37ef:	mov    r12,rdi
    37f2:	mov    rax,QWORD PTR [rip+0x0]        # 37f9 <botlish_fn_39+0x129>
			37f5: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    37f9:	call   rax
    37fb:	xor    rax,rax
    37fe:	mov    rbx,QWORD PTR [rsp]
    3802:	mov    r12,QWORD PTR [rsp+0x8]
    3807:	mov    r13,QWORD PTR [rsp+0x10]
    380c:	add    rsp,0x20
    3810:	mov    rsp,rbp
    3813:	pop    rbp
    3814:	ret

0000000000003815 <botlish_entry_39: ht_probe_next<any, int>>:
    3815:	push   rbp
    3816:	mov    rbp,rsp
    3819:	mov    rsi,QWORD PTR [rdx]
    381c:	mov    rdx,QWORD PTR [rdx+0x8]
    3820:	call   3825 <botlish_entry_39+0x10>
			3821: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    3825:	mov    rsp,rbp
    3828:	pop    rbp
    3829:	ret
    382a:	add    BYTE PTR [rax],al
    382c:	add    BYTE PTR [rax],al
	...

0000000000003830 <botlish_fn_40: ht_find_get<any, str, int>>:
    3830:	push   rbp
    3831:	mov    rbp,rsp
    3834:	sub    rsp,0x40
    3838:	mov    QWORD PTR [rsp+0x10],rbx
    383d:	mov    QWORD PTR [rsp+0x18],r12
    3842:	mov    QWORD PTR [rsp+0x20],r13
    3847:	mov    QWORD PTR [rsp+0x28],r14
    384c:	mov    QWORD PTR [rsp+0x30],r15
    3851:	mov    r14,QWORD PTR [rdi]
    3854:	mov    r8,QWORD PTR [rdi+0x8]
    3858:	lea    r9,[r14+0x20]
    385c:	cmp    r9,r8
    385f:	ja     3bcf <botlish_fn_40+0x39f>
    3865:	lea    r8,[r14+0x20]
    3869:	mov    QWORD PTR [rdi],r8
    386c:	mov    r15,rdi
    386f:	mov    QWORD PTR [r14],0x0
    3876:	mov    QWORD PTR [r14+0x8],0x0
    387e:	mov    QWORD PTR [r14+0x10],0x0
    3886:	mov    QWORD PTR [r14+0x18],0x0
    388e:	mov    QWORD PTR [r14],rsi
    3891:	mov    QWORD PTR [r14+0x8],rdx
    3895:	mov    QWORD PTR [rsp],rdx
    3899:	mov    QWORD PTR [r14+0x10],rcx
    389d:	mov    rbx,rsi
    38a0:	mov    QWORD PTR [rsp+0x8],rcx
    38a5:	mov    rsi,rbx
    38a8:	mov    rdi,r15
    38ab:	call   38b0 <botlish_fn_40+0x80>
			38ac: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_controls<generic>
    38b0:	test   rax,rax
    38b3:	jne    38c1 <botlish_fn_40+0x91>
    38b9:	mov    rdi,r15
    38bc:	jmp    3b2f <botlish_fn_40+0x2ff>
    38c1:	xor    ecx,ecx
    38c3:	test   rax,0x7
    38c9:	je     38d7 <botlish_fn_40+0xa7>
    38cf:	mov    rsi,rax
    38d2:	jmp    38e5 <botlish_fn_40+0xb5>
    38d7:	movzx  rcx,BYTE PTR [rax]
    38db:	mov    rsi,rax
    38de:	rex cmp cl,0x8
    38e2:	sete   cl
    38e5:	test   cl,cl
    38e7:	jne    390e <botlish_fn_40+0xde>
    38ed:	mov    rdi,r15
    38f0:	mov    rax,QWORD PTR [rdi+0x10]
    38f4:	mov    rcx,QWORD PTR [rax+0x20]
    38f8:	mov    edx,0x8
    38fd:	mov    rax,QWORD PTR [rip+0x0]        # 3904 <botlish_fn_40+0xd4>
			3900: R_X86_64_GOTPCREL	rt_type_error-0x4
    3904:	call   rax
    3906:	mov    rdi,r15
    3909:	jmp    3b2f <botlish_fn_40+0x2ff>
    390e:	mov    rax,QWORD PTR [rip+0x0]        # 3915 <botlish_fn_40+0xe5>
			3911: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    3915:	mov    rdx,QWORD PTR [rsp+0x8]
    391a:	mov    rdi,r15
    391d:	call   rax
    391f:	mov    rsi,rax
    3922:	mov    r13,rax
    3925:	test   rax,rsi
    3928:	jne    3936 <botlish_fn_40+0x106>
    392e:	mov    rdi,r15
    3931:	jmp    3b2f <botlish_fn_40+0x2ff>
    3936:	mov    rax,r13
    3939:	mov    QWORD PTR [r14+0x18],rax
    393d:	mov    rdi,r15
    3940:	call   3945 <botlish_fn_40+0x115>
			3941: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    3945:	test   rax,rax
    3948:	jne    3956 <botlish_fn_40+0x126>
    394e:	mov    rdi,r15
    3951:	jmp    3b2f <botlish_fn_40+0x2ff>
    3956:	mov    rcx,r13
    3959:	and    rcx,rax
    395c:	mov    rdx,rax
    395f:	test   rcx,0x1
    3966:	jne    398c <botlish_fn_40+0x15c>
    396c:	mov    rax,QWORD PTR [rip+0x0]        # 3973 <botlish_fn_40+0x143>
			396f: R_X86_64_GOTPCREL	rt_value_eq-0x4
    3973:	mov    rsi,r13
    3976:	mov    rdi,r15
    3979:	call   rax
    397b:	test   rax,rax
    397e:	jne    399c <botlish_fn_40+0x16c>
    3984:	mov    rdi,r15
    3987:	jmp    3b2f <botlish_fn_40+0x2ff>
    398c:	mov    eax,0x2
    3991:	cmp    r13,rdx
    3994:	cmove  rax,QWORD PTR [rip+0x264]        # 3c00 <botlish_fn_40+0x3d0>
    399c:	mov    r12d,0x6
    39a2:	cmp    rax,0x6
    39a6:	je     3ba0 <botlish_fn_40+0x370>
    39ac:	mov    rdi,r15
    39af:	call   39b4 <botlish_fn_40+0x184>
			39b0: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    39b4:	test   rax,rax
    39b7:	jne    39c5 <botlish_fn_40+0x195>
    39bd:	mov    rdi,r15
    39c0:	jmp    3b2f <botlish_fn_40+0x2ff>
    39c5:	mov    rcx,r13
    39c8:	and    rcx,rax
    39cb:	mov    rdx,rax
    39ce:	test   rcx,0x1
    39d5:	jne    39fb <botlish_fn_40+0x1cb>
    39db:	mov    rax,QWORD PTR [rip+0x0]        # 39e2 <botlish_fn_40+0x1b2>
			39de: R_X86_64_GOTPCREL	rt_value_eq-0x4
    39e2:	mov    rsi,r13
    39e5:	mov    rdi,r15
    39e8:	call   rax
    39ea:	test   rax,rax
    39ed:	jne    3a0e <botlish_fn_40+0x1de>
    39f3:	mov    rdi,r15
    39f6:	jmp    3b2f <botlish_fn_40+0x2ff>
    39fb:	mov    rsi,r13
    39fe:	mov    eax,0x2
    3a03:	cmp    rsi,rdx
    3a06:	cmove  rax,QWORD PTR [rip+0x1f2]        # 3c00 <botlish_fn_40+0x3d0>
    3a0e:	cmp    rax,0x6
    3a12:	je     3a27 <botlish_fn_40+0x1f7>
    3a18:	mov    r12d,0x2
    3a1e:	mov    r13,QWORD PTR [rsp]
    3a22:	jmp    3b09 <botlish_fn_40+0x2d9>
    3a27:	mov    rsi,rbx
    3a2a:	mov    rdi,r15
    3a2d:	call   3a32 <botlish_fn_40+0x202>
			3a2e: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_keys<generic>
    3a32:	test   rax,rax
    3a35:	jne    3a43 <botlish_fn_40+0x213>
    3a3b:	mov    rdi,r15
    3a3e:	jmp    3b2f <botlish_fn_40+0x2ff>
    3a43:	xor    ecx,ecx
    3a45:	test   rax,0x7
    3a4b:	jne    3a5c <botlish_fn_40+0x22c>
    3a51:	movzx  rdx,BYTE PTR [rax]
    3a55:	rex cmp dl,0x8
    3a59:	sete   cl
    3a5c:	test   cl,cl
    3a5e:	jne    3a89 <botlish_fn_40+0x259>
    3a64:	mov    rdi,r15
    3a67:	mov    rsi,QWORD PTR [rdi+0x10]
    3a6b:	mov    rcx,QWORD PTR [rsi+0x20]
    3a6f:	mov    edx,0x8
    3a74:	mov    r8,QWORD PTR [rip+0x0]        # 3a7b <botlish_fn_40+0x24b>
			3a77: R_X86_64_GOTPCREL	rt_type_error-0x4
    3a7b:	mov    rsi,rax
    3a7e:	call   r8
    3a81:	mov    rdi,r15
    3a84:	jmp    3b2f <botlish_fn_40+0x2ff>
    3a89:	mov    rsi,rax
    3a8c:	mov    r8,QWORD PTR [rip+0x0]        # 3a93 <botlish_fn_40+0x263>
			3a8f: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    3a93:	mov    rdx,QWORD PTR [rsp+0x8]
    3a98:	mov    rdi,r15
    3a9b:	call   r8
    3a9e:	test   rax,rax
    3aa1:	jne    3aaf <botlish_fn_40+0x27f>
    3aa7:	mov    rdi,r15
    3aaa:	jmp    3b2f <botlish_fn_40+0x2ff>
    3aaf:	mov    r13,QWORD PTR [rsp]
    3ab3:	mov    r10,rax
    3ab6:	and    r10,r13
    3ab9:	mov    rsi,rax
    3abc:	test   r10,0x1
    3ac3:	jne    3ae9 <botlish_fn_40+0x2b9>
    3ac9:	mov    rax,QWORD PTR [rip+0x0]        # 3ad0 <botlish_fn_40+0x2a0>
			3acc: R_X86_64_GOTPCREL	rt_value_eq-0x4
    3ad0:	mov    rdx,r13
    3ad3:	mov    rdi,r15
    3ad6:	call   rax
    3ad8:	test   rax,rax
    3adb:	jne    3af9 <botlish_fn_40+0x2c9>
    3ae1:	mov    rdi,r15
    3ae4:	jmp    3b2f <botlish_fn_40+0x2ff>
    3ae9:	mov    eax,0x2
    3aee:	cmp    rsi,r13
    3af1:	cmove  rax,QWORD PTR [rip+0x107]        # 3c00 <botlish_fn_40+0x3d0>
    3af9:	cmp    rax,0x6
    3afd:	je     3b09 <botlish_fn_40+0x2d9>
    3b03:	mov    r12d,0x2
    3b09:	cmp    r12,0x6
    3b0d:	je     3b73 <botlish_fn_40+0x343>
    3b13:	mov    rdx,QWORD PTR [rsp+0x8]
    3b18:	mov    rsi,rbx
    3b1b:	mov    rdi,r15
    3b1e:	call   3b23 <botlish_fn_40+0x2f3>
			3b1f: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_probe_next<any, int>
    3b23:	test   rax,rax
    3b26:	jne    3b5a <botlish_fn_40+0x32a>
    3b2c:	mov    rdi,r15
    3b2f:	mov    rdi,r15
    3b32:	mov    QWORD PTR [rdi],r14
    3b35:	xor    rax,rax
    3b38:	mov    rbx,QWORD PTR [rsp+0x10]
    3b3d:	mov    r12,QWORD PTR [rsp+0x18]
    3b42:	mov    r13,QWORD PTR [rsp+0x20]
    3b47:	mov    r14,QWORD PTR [rsp+0x28]
    3b4c:	mov    r15,QWORD PTR [rsp+0x30]
    3b51:	add    rsp,0x40
    3b55:	mov    rsp,rbp
    3b58:	pop    rbp
    3b59:	ret
    3b5a:	mov    QWORD PTR [r14],rbx
    3b5d:	mov    QWORD PTR [r14+0x8],r13
    3b61:	mov    QWORD PTR [r14+0x10],rax
    3b65:	mov    QWORD PTR [rsp],r13
    3b69:	mov    QWORD PTR [rsp+0x8],rax
    3b6e:	jmp    38a5 <botlish_fn_40+0x75>
    3b73:	mov    rdi,r15
    3b76:	mov    QWORD PTR [rdi],r14
    3b79:	mov    rax,QWORD PTR [rsp+0x8]
    3b7e:	mov    rbx,QWORD PTR [rsp+0x10]
    3b83:	mov    r12,QWORD PTR [rsp+0x18]
    3b88:	mov    r13,QWORD PTR [rsp+0x20]
    3b8d:	mov    r14,QWORD PTR [rsp+0x28]
    3b92:	mov    r15,QWORD PTR [rsp+0x30]
    3b97:	add    rsp,0x40
    3b9b:	mov    rsp,rbp
    3b9e:	pop    rbp
    3b9f:	ret
    3ba0:	mov    rdi,r15
    3ba3:	mov    QWORD PTR [rdi],r14
    3ba6:	mov    rax,0xffffffffffffffff
    3bad:	mov    rbx,QWORD PTR [rsp+0x10]
    3bb2:	mov    r12,QWORD PTR [rsp+0x18]
    3bb7:	mov    r13,QWORD PTR [rsp+0x20]
    3bbc:	mov    r14,QWORD PTR [rsp+0x28]
    3bc1:	mov    r15,QWORD PTR [rsp+0x30]
    3bc6:	add    rsp,0x40
    3bca:	mov    rsp,rbp
    3bcd:	pop    rbp
    3bce:	ret
    3bcf:	mov    r15,rdi
    3bd2:	mov    rax,QWORD PTR [rip+0x0]        # 3bd9 <botlish_fn_40+0x3a9>
			3bd5: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3bd9:	call   rax
    3bdb:	xor    rax,rax
    3bde:	mov    rbx,QWORD PTR [rsp+0x10]
    3be3:	mov    r12,QWORD PTR [rsp+0x18]
    3be8:	mov    r13,QWORD PTR [rsp+0x20]
    3bed:	mov    r14,QWORD PTR [rsp+0x28]
    3bf2:	mov    r15,QWORD PTR [rsp+0x30]
    3bf7:	add    rsp,0x40
    3bfb:	mov    rsp,rbp
    3bfe:	pop    rbp
    3bff:	ret
    3c00:	(bad)
    3c01:	add    BYTE PTR [rax],al
    3c03:	add    BYTE PTR [rax],al
    3c05:	add    BYTE PTR [rax],al
	...

0000000000003c08 <botlish_entry_40: ht_find_get<any, str, int>>:
    3c08:	push   rbp
    3c09:	mov    rbp,rsp
    3c0c:	mov    rsi,QWORD PTR [rdx]
    3c0f:	mov    r8,QWORD PTR [rdx+0x8]
    3c13:	mov    rcx,QWORD PTR [rdx+0x10]
    3c17:	mov    rdx,r8
    3c1a:	call   3c1f <botlish_entry_40+0x17>
			3c1b: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    3c1f:	mov    rsp,rbp
    3c22:	pop    rbp
    3c23:	ret
    3c24:	add    BYTE PTR [rax],al
	...

0000000000003c28 <botlish_fn_41: ht_find_insert<mutarray, any, int, int>>:
    3c28:	push   rbp
    3c29:	mov    rbp,rsp
    3c2c:	sub    rsp,0x50
    3c30:	mov    QWORD PTR [rsp+0x20],rbx
    3c35:	mov    QWORD PTR [rsp+0x28],r12
    3c3a:	mov    QWORD PTR [rsp+0x30],r13
    3c3f:	mov    QWORD PTR [rsp+0x38],r14
    3c44:	mov    QWORD PTR [rsp+0x40],r15
    3c49:	mov    r13,QWORD PTR [rdi]
    3c4c:	mov    rax,QWORD PTR [rdi+0x8]
    3c50:	lea    r9,[r13+0x28]
    3c54:	cmp    r9,rax
    3c57:	ja     41cb <botlish_fn_41+0x5a3>
    3c5d:	lea    rax,[r13+0x28]
    3c61:	mov    QWORD PTR [rdi],rax
    3c64:	mov    QWORD PTR [rsp],rdi
    3c68:	mov    QWORD PTR [r13+0x0],0x0
    3c70:	mov    QWORD PTR [r13+0x8],0x0
    3c78:	mov    QWORD PTR [r13+0x10],0x0
    3c80:	mov    QWORD PTR [r13+0x18],0x0
    3c88:	mov    QWORD PTR [r13+0x20],0x0
    3c90:	mov    QWORD PTR [r13+0x0],rsi
    3c94:	mov    QWORD PTR [r13+0x8],rdx
    3c98:	mov    r14,rdx
    3c9b:	mov    QWORD PTR [r13+0x10],rcx
    3c9f:	mov    QWORD PTR [r13+0x18],r8
    3ca3:	mov    rbx,rsi
    3ca6:	mov    r15,r8
    3ca9:	mov    QWORD PTR [rsp+0x8],rcx
    3cae:	mov    rsi,rbx
    3cb1:	mov    rdi,QWORD PTR [rsp]
    3cb5:	call   3cba <botlish_fn_41+0x92>
			3cb6: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    3cba:	test   rax,rax
    3cbd:	jne    3ccc <botlish_fn_41+0xa4>
    3cc3:	mov    rdi,QWORD PTR [rsp]
    3cc7:	jmp    409a <botlish_fn_41+0x472>
    3ccc:	xor    ecx,ecx
    3cce:	test   rax,0x7
    3cd4:	je     3ce2 <botlish_fn_41+0xba>
    3cda:	mov    rsi,rax
    3cdd:	jmp    3cf0 <botlish_fn_41+0xc8>
    3ce2:	movzx  rcx,BYTE PTR [rax]
    3ce6:	mov    rsi,rax
    3ce9:	rex cmp cl,0x8
    3ced:	sete   cl
    3cf0:	test   cl,cl
    3cf2:	jne    3d1b <botlish_fn_41+0xf3>
    3cf8:	mov    rdi,QWORD PTR [rsp]
    3cfc:	mov    rax,QWORD PTR [rdi+0x10]
    3d00:	mov    rcx,QWORD PTR [rax+0x20]
    3d04:	mov    edx,0x8
    3d09:	mov    rax,QWORD PTR [rip+0x0]        # 3d10 <botlish_fn_41+0xe8>
			3d0c: R_X86_64_GOTPCREL	rt_type_error-0x4
    3d10:	call   rax
    3d12:	mov    rdi,QWORD PTR [rsp]
    3d16:	jmp    409a <botlish_fn_41+0x472>
    3d1b:	mov    rax,QWORD PTR [rip+0x0]        # 3d22 <botlish_fn_41+0xfa>
			3d1e: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    3d22:	mov    rdx,QWORD PTR [rsp+0x8]
    3d27:	mov    rdi,QWORD PTR [rsp]
    3d2b:	call   rax
    3d2d:	mov    rcx,rax
    3d30:	mov    QWORD PTR [rsp+0x10],rax
    3d35:	test   rax,rcx
    3d38:	jne    3d47 <botlish_fn_41+0x11f>
    3d3e:	mov    rdi,QWORD PTR [rsp]
    3d42:	jmp    409a <botlish_fn_41+0x472>
    3d47:	mov    rax,QWORD PTR [rsp+0x10]
    3d4c:	mov    QWORD PTR [r13+0x20],rax
    3d50:	mov    rdi,QWORD PTR [rsp]
    3d54:	call   3d59 <botlish_fn_41+0x131>
			3d55: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    3d59:	test   rax,rax
    3d5c:	jne    3d6b <botlish_fn_41+0x143>
    3d62:	mov    rdi,QWORD PTR [rsp]
    3d66:	jmp    409a <botlish_fn_41+0x472>
    3d6b:	mov    rcx,QWORD PTR [rsp+0x10]
    3d70:	mov    rdx,rcx
    3d73:	and    rdx,rax
    3d76:	mov    r10,rax
    3d79:	test   rdx,0x1
    3d80:	jne    3dae <botlish_fn_41+0x186>
    3d86:	mov    r8,QWORD PTR [rip+0x0]        # 3d8d <botlish_fn_41+0x165>
			3d89: R_X86_64_GOTPCREL	rt_value_eq-0x4
    3d8d:	mov    rdx,r10
    3d90:	mov    rsi,QWORD PTR [rsp+0x10]
    3d95:	mov    rdi,QWORD PTR [rsp]
    3d99:	call   r8
    3d9c:	test   rax,rax
    3d9f:	jne    3dc6 <botlish_fn_41+0x19e>
    3da5:	mov    rdi,QWORD PTR [rsp]
    3da9:	jmp    409a <botlish_fn_41+0x472>
    3dae:	mov    rdx,r10
    3db1:	mov    eax,0x2
    3db6:	mov    rsi,QWORD PTR [rsp+0x10]
    3dbb:	cmp    rsi,rdx
    3dbe:	cmove  rax,QWORD PTR [rip+0x43a]        # 4200 <botlish_fn_41+0x5d8>
    3dc6:	mov    r12d,0x6
    3dcc:	cmp    rax,0x6
    3dd0:	je     4118 <botlish_fn_41+0x4f0>
    3dd6:	mov    rdi,QWORD PTR [rsp]
    3dda:	call   3ddf <botlish_fn_41+0x1b7>
			3ddb: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    3ddf:	test   rax,rax
    3de2:	jne    3df1 <botlish_fn_41+0x1c9>
    3de8:	mov    rdi,QWORD PTR [rsp]
    3dec:	jmp    409a <botlish_fn_41+0x472>
    3df1:	mov    rcx,QWORD PTR [rsp+0x10]
    3df6:	and    rcx,rax
    3df9:	mov    rdx,rax
    3dfc:	test   rcx,0x1
    3e03:	jne    3e2d <botlish_fn_41+0x205>
    3e09:	mov    rax,QWORD PTR [rip+0x0]        # 3e10 <botlish_fn_41+0x1e8>
			3e0c: R_X86_64_GOTPCREL	rt_value_eq-0x4
    3e10:	mov    rsi,QWORD PTR [rsp+0x10]
    3e15:	mov    rdi,QWORD PTR [rsp]
    3e19:	call   rax
    3e1b:	test   rax,rax
    3e1e:	jne    3e42 <botlish_fn_41+0x21a>
    3e24:	mov    rdi,QWORD PTR [rsp]
    3e28:	jmp    409a <botlish_fn_41+0x472>
    3e2d:	mov    eax,0x2
    3e32:	mov    rcx,QWORD PTR [rsp+0x10]
    3e37:	cmp    rcx,rdx
    3e3a:	cmove  rax,QWORD PTR [rip+0x3be]        # 4200 <botlish_fn_41+0x5d8>
    3e42:	cmp    rax,0x6
    3e46:	je     3e56 <botlish_fn_41+0x22e>
    3e4c:	mov    eax,0x2
    3e51:	jmp    3f46 <botlish_fn_41+0x31e>
    3e56:	mov    rsi,rbx
    3e59:	mov    rdi,QWORD PTR [rsp]
    3e5d:	call   3e62 <botlish_fn_41+0x23a>
			3e5e: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    3e62:	test   rax,rax
    3e65:	jne    3e74 <botlish_fn_41+0x24c>
    3e6b:	mov    rdi,QWORD PTR [rsp]
    3e6f:	jmp    409a <botlish_fn_41+0x472>
    3e74:	xor    ecx,ecx
    3e76:	test   rax,0x7
    3e7c:	je     3e8a <botlish_fn_41+0x262>
    3e82:	mov    rsi,rax
    3e85:	jmp    3e98 <botlish_fn_41+0x270>
    3e8a:	movzx  rcx,BYTE PTR [rax]
    3e8e:	mov    rsi,rax
    3e91:	rex cmp cl,0x8
    3e95:	sete   cl
    3e98:	test   cl,cl
    3e9a:	jne    3ec3 <botlish_fn_41+0x29b>
    3ea0:	mov    rdi,QWORD PTR [rsp]
    3ea4:	mov    rax,QWORD PTR [rdi+0x10]
    3ea8:	mov    rcx,QWORD PTR [rax+0x20]
    3eac:	mov    edx,0x8
    3eb1:	mov    rax,QWORD PTR [rip+0x0]        # 3eb8 <botlish_fn_41+0x290>
			3eb4: R_X86_64_GOTPCREL	rt_type_error-0x4
    3eb8:	call   rax
    3eba:	mov    rdi,QWORD PTR [rsp]
    3ebe:	jmp    409a <botlish_fn_41+0x472>
    3ec3:	mov    rax,QWORD PTR [rip+0x0]        # 3eca <botlish_fn_41+0x2a2>
			3ec6: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    3eca:	mov    rdx,QWORD PTR [rsp+0x8]
    3ecf:	mov    rdi,QWORD PTR [rsp]
    3ed3:	call   rax
    3ed5:	test   rax,rax
    3ed8:	jne    3ee7 <botlish_fn_41+0x2bf>
    3ede:	mov    rdi,QWORD PTR [rsp]
    3ee2:	jmp    409a <botlish_fn_41+0x472>
    3ee7:	mov    rcx,rax
    3eea:	and    rcx,r14
    3eed:	mov    rsi,rax
    3ef0:	test   rcx,0x1
    3ef7:	jne    3f1f <botlish_fn_41+0x2f7>
    3efd:	mov    rax,QWORD PTR [rip+0x0]        # 3f04 <botlish_fn_41+0x2dc>
			3f00: R_X86_64_GOTPCREL	rt_value_eq-0x4
    3f04:	mov    rdx,r14
    3f07:	mov    rdi,QWORD PTR [rsp]
    3f0b:	call   rax
    3f0d:	test   rax,rax
    3f10:	jne    3f2f <botlish_fn_41+0x307>
    3f16:	mov    rdi,QWORD PTR [rsp]
    3f1a:	jmp    409a <botlish_fn_41+0x472>
    3f1f:	mov    eax,0x2
    3f24:	cmp    rsi,r14
    3f27:	cmove  rax,QWORD PTR [rip+0x2d1]        # 4200 <botlish_fn_41+0x5d8>
    3f2f:	cmp    rax,0x6
    3f33:	je     3f43 <botlish_fn_41+0x31b>
    3f39:	mov    eax,0x2
    3f3e:	jmp    3f46 <botlish_fn_41+0x31e>
    3f43:	mov    rax,r12
    3f46:	cmp    rax,0x6
    3f4a:	je     40ea <botlish_fn_41+0x4c2>
    3f50:	mov    rdi,QWORD PTR [rsp]
    3f54:	call   3f59 <botlish_fn_41+0x331>
			3f55: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    3f59:	test   rax,rax
    3f5c:	jne    3f6b <botlish_fn_41+0x343>
    3f62:	mov    rdi,QWORD PTR [rsp]
    3f66:	jmp    409a <botlish_fn_41+0x472>
    3f6b:	mov    rcx,QWORD PTR [rsp+0x10]
    3f70:	mov    rdx,rcx
    3f73:	and    rdx,rax
    3f76:	mov    rcx,rax
    3f79:	test   rdx,0x1
    3f80:	jne    3fad <botlish_fn_41+0x385>
    3f86:	mov    rax,QWORD PTR [rip+0x0]        # 3f8d <botlish_fn_41+0x365>
			3f89: R_X86_64_GOTPCREL	rt_value_eq-0x4
    3f8d:	mov    rdx,rcx
    3f90:	mov    rsi,QWORD PTR [rsp+0x10]
    3f95:	mov    rdi,QWORD PTR [rsp]
    3f99:	call   rax
    3f9b:	test   rax,rax
    3f9e:	jne    3fc5 <botlish_fn_41+0x39d>
    3fa4:	mov    rdi,QWORD PTR [rsp]
    3fa8:	jmp    409a <botlish_fn_41+0x472>
    3fad:	mov    rdx,rcx
    3fb0:	mov    rsi,QWORD PTR [rsp+0x10]
    3fb5:	mov    eax,0x2
    3fba:	cmp    rsi,rdx
    3fbd:	cmove  rax,QWORD PTR [rip+0x23b]        # 4200 <botlish_fn_41+0x5d8>
    3fc5:	cmp    rax,0x6
    3fc9:	je     3fda <botlish_fn_41+0x3b2>
    3fcf:	mov    r12d,0x2
    3fd5:	jmp    4032 <botlish_fn_41+0x40a>
    3fda:	test   r15,0x1
    3fe1:	jne    4012 <botlish_fn_41+0x3ea>
    3fe7:	mov    edx,0x1
    3fec:	mov    r10,QWORD PTR [rip+0x0]        # 3ff3 <botlish_fn_41+0x3cb>
			3fef: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    3ff3:	mov    rsi,r15
    3ff6:	mov    rdi,QWORD PTR [rsp]
    3ffa:	call   r10
    3ffd:	mov    ecx,0x2
    4002:	test   rax,rax
    4005:	cmovl  rcx,QWORD PTR [rip+0x1f3]        # 4200 <botlish_fn_41+0x5d8>
    400d:	jmp    4022 <botlish_fn_41+0x3fa>
    4012:	mov    ecx,0x2
    4017:	test   r15,r15
    401a:	cmovle rcx,QWORD PTR [rip+0x1de]        # 4200 <botlish_fn_41+0x5d8>
    4022:	cmp    rcx,0x6
    4026:	je     4032 <botlish_fn_41+0x40a>
    402c:	mov    r12d,0x2
    4032:	cmp    r12,0x6
    4036:	je     407c <botlish_fn_41+0x454>
    403c:	mov    rdx,QWORD PTR [rsp+0x8]
    4041:	mov    rsi,rbx
    4044:	mov    rdi,QWORD PTR [rsp]
    4048:	call   404d <botlish_fn_41+0x425>
			4049: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    404d:	test   rax,rax
    4050:	jne    405f <botlish_fn_41+0x437>
    4056:	mov    rdi,QWORD PTR [rsp]
    405a:	jmp    409a <botlish_fn_41+0x472>
    405f:	mov    QWORD PTR [r13+0x0],rbx
    4063:	mov    QWORD PTR [r13+0x8],r14
    4067:	mov    QWORD PTR [r13+0x10],rax
    406b:	mov    rcx,r15
    406e:	mov    QWORD PTR [r13+0x18],rcx
    4072:	mov    QWORD PTR [rsp+0x8],rax
    4077:	jmp    3cae <botlish_fn_41+0x86>
    407c:	mov    rdx,QWORD PTR [rsp+0x8]
    4081:	mov    rsi,rbx
    4084:	mov    rdi,QWORD PTR [rsp]
    4088:	call   408d <botlish_fn_41+0x465>
			4089: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_probe_next<mutarray, int>
    408d:	test   rax,rax
    4090:	jne    40c6 <botlish_fn_41+0x49e>
    4096:	mov    rdi,QWORD PTR [rsp]
    409a:	mov    rdi,QWORD PTR [rsp]
    409e:	mov    QWORD PTR [rdi],r13
    40a1:	xor    rax,rax
    40a4:	mov    rbx,QWORD PTR [rsp+0x20]
    40a9:	mov    r12,QWORD PTR [rsp+0x28]
    40ae:	mov    r13,QWORD PTR [rsp+0x30]
    40b3:	mov    r14,QWORD PTR [rsp+0x38]
    40b8:	mov    r15,QWORD PTR [rsp+0x40]
    40bd:	add    rsp,0x50
    40c1:	mov    rsp,rbp
    40c4:	pop    rbp
    40c5:	ret
    40c6:	mov    QWORD PTR [r13+0x0],rbx
    40ca:	mov    QWORD PTR [r13+0x8],r14
    40ce:	mov    QWORD PTR [r13+0x10],rax
    40d2:	mov    rdx,QWORD PTR [rsp+0x8]
    40d7:	mov    QWORD PTR [r13+0x18],rdx
    40db:	mov    r15,QWORD PTR [rsp+0x8]
    40e0:	mov    QWORD PTR [rsp+0x8],rax
    40e5:	jmp    3cae <botlish_fn_41+0x86>
    40ea:	mov    rdi,QWORD PTR [rsp]
    40ee:	mov    QWORD PTR [rdi],r13
    40f1:	mov    rax,QWORD PTR [rsp+0x8]
    40f6:	mov    rbx,QWORD PTR [rsp+0x20]
    40fb:	mov    r12,QWORD PTR [rsp+0x28]
    4100:	mov    r13,QWORD PTR [rsp+0x30]
    4105:	mov    r14,QWORD PTR [rsp+0x38]
    410a:	mov    r15,QWORD PTR [rsp+0x40]
    410f:	add    rsp,0x50
    4113:	mov    rsp,rbp
    4116:	pop    rbp
    4117:	ret
    4118:	mov    rax,r15
    411b:	test   rax,0x1
    4121:	jne    4151 <botlish_fn_41+0x529>
    4127:	mov    edx,0x1
    412c:	mov    rax,QWORD PTR [rip+0x0]        # 4133 <botlish_fn_41+0x50b>
			412f: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    4133:	mov    rsi,r15
    4136:	mov    rdi,QWORD PTR [rsp]
    413a:	call   rax
    413c:	mov    ecx,0x2
    4141:	test   rax,rax
    4144:	cmovge rcx,QWORD PTR [rip+0xb4]        # 4200 <botlish_fn_41+0x5d8>
    414c:	jmp    4167 <botlish_fn_41+0x53f>
    4151:	mov    ecx,0x2
    4156:	mov    rax,r15
    4159:	mov    rdx,r15
    415c:	test   rax,rdx
    415f:	cmovg  rcx,QWORD PTR [rip+0x99]        # 4200 <botlish_fn_41+0x5d8>
    4167:	cmp    rcx,0x6
    416b:	je     419f <botlish_fn_41+0x577>
    4171:	mov    rdi,QWORD PTR [rsp]
    4175:	mov    QWORD PTR [rdi],r13
    4178:	mov    rax,QWORD PTR [rsp+0x8]
    417d:	mov    rbx,QWORD PTR [rsp+0x20]
    4182:	mov    r12,QWORD PTR [rsp+0x28]
    4187:	mov    r13,QWORD PTR [rsp+0x30]
    418c:	mov    r14,QWORD PTR [rsp+0x38]
    4191:	mov    r15,QWORD PTR [rsp+0x40]
    4196:	add    rsp,0x50
    419a:	mov    rsp,rbp
    419d:	pop    rbp
    419e:	ret
    419f:	mov    rdi,QWORD PTR [rsp]
    41a3:	mov    QWORD PTR [rdi],r13
    41a6:	mov    rax,r15
    41a9:	mov    rbx,QWORD PTR [rsp+0x20]
    41ae:	mov    r12,QWORD PTR [rsp+0x28]
    41b3:	mov    r13,QWORD PTR [rsp+0x30]
    41b8:	mov    r14,QWORD PTR [rsp+0x38]
    41bd:	mov    r15,QWORD PTR [rsp+0x40]
    41c2:	add    rsp,0x50
    41c6:	mov    rsp,rbp
    41c9:	pop    rbp
    41ca:	ret
    41cb:	mov    QWORD PTR [rsp],rdi
    41cf:	mov    rax,QWORD PTR [rip+0x0]        # 41d6 <botlish_fn_41+0x5ae>
			41d2: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    41d6:	call   rax
    41d8:	xor    rax,rax
    41db:	mov    rbx,QWORD PTR [rsp+0x20]
    41e0:	mov    r12,QWORD PTR [rsp+0x28]
    41e5:	mov    r13,QWORD PTR [rsp+0x30]
    41ea:	mov    r14,QWORD PTR [rsp+0x38]
    41ef:	mov    r15,QWORD PTR [rsp+0x40]
    41f4:	add    rsp,0x50
    41f8:	mov    rsp,rbp
    41fb:	pop    rbp
    41fc:	ret
    41fd:	add    BYTE PTR [rax],al
    41ff:	add    BYTE PTR [rsi],al
    4201:	add    BYTE PTR [rax],al
    4203:	add    BYTE PTR [rax],al
    4205:	add    BYTE PTR [rax],al
	...

0000000000004208 <botlish_entry_41: ht_find_insert<mutarray, any, int, int>>:
    4208:	push   rbp
    4209:	mov    rbp,rsp
    420c:	mov    rsi,QWORD PTR [rdx]
    420f:	mov    r9,QWORD PTR [rdx+0x8]
    4213:	mov    rcx,QWORD PTR [rdx+0x10]
    4217:	mov    r8,QWORD PTR [rdx+0x18]
    421b:	mov    rdx,r9
    421e:	call   4223 <botlish_entry_41+0x1b>
			421f: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    4223:	mov    rsp,rbp
    4226:	pop    rbp
    4227:	ret

0000000000004228 <botlish_fn_42: ht_get<any, str>>:
    4228:	push   rbp
    4229:	mov    rbp,rsp
    422c:	sub    rsp,0x20
    4230:	mov    QWORD PTR [rsp],rbx
    4234:	mov    QWORD PTR [rsp+0x8],r12
    4239:	mov    QWORD PTR [rsp+0x10],r13
    423e:	mov    QWORD PTR [rsp+0x18],r14
    4243:	mov    rbx,QWORD PTR [rdi]
    4246:	mov    rax,QWORD PTR [rdi+0x8]
    424a:	lea    rcx,[rbx+0x18]
    424e:	cmp    rcx,rax
    4251:	ja     4418 <botlish_fn_42+0x1f0>
    4257:	lea    rax,[rbx+0x18]
    425b:	mov    QWORD PTR [rdi],rax
    425e:	mov    r12,rdi
    4261:	mov    QWORD PTR [rbx],0x0
    4268:	mov    QWORD PTR [rbx+0x8],0x0
    4270:	mov    QWORD PTR [rbx+0x10],0x0
    4278:	mov    QWORD PTR [rbx],rsi
    427b:	mov    r13,rsi
    427e:	mov    QWORD PTR [rbx+0x8],rdx
    4282:	mov    r14,rdx
    4285:	mov    rdx,r14
    4288:	mov    rsi,r13
    428b:	mov    rdi,r12
    428e:	call   4293 <botlish_fn_42+0x6b>
			428f: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_probe_start<any, str>
    4293:	test   rax,rax
    4296:	jne    42a4 <botlish_fn_42+0x7c>
    429c:	mov    rdi,r12
    429f:	jmp    43aa <botlish_fn_42+0x182>
    42a4:	mov    QWORD PTR [rbx+0x10],rax
    42a8:	mov    rcx,rax
    42ab:	mov    rdx,r14
    42ae:	mov    rsi,r13
    42b1:	mov    rdi,r12
    42b4:	call   42b9 <botlish_fn_42+0x91>
			42b5: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_find_get<any, str, int>
    42b9:	mov    rcx,rax
    42bc:	mov    r14,rax
    42bf:	test   rax,rcx
    42c2:	jne    42d0 <botlish_fn_42+0xa8>
    42c8:	mov    rdi,r12
    42cb:	jmp    43aa <botlish_fn_42+0x182>
    42d0:	mov    rax,r14
    42d3:	mov    QWORD PTR [rbx+0x8],rax
    42d7:	test   rax,0x1
    42dd:	jne    430c <botlish_fn_42+0xe4>
    42e3:	mov    edx,0x1
    42e8:	mov    rax,QWORD PTR [rip+0x0]        # 42ef <botlish_fn_42+0xc7>
			42eb: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    42ef:	mov    rsi,r14
    42f2:	mov    rdi,r12
    42f5:	call   rax
    42f7:	mov    ecx,0x2
    42fc:	test   rax,rax
    42ff:	cmovl  rcx,QWORD PTR [rip+0x141]        # 4448 <botlish_fn_42+0x220>
    4307:	jmp    431f <botlish_fn_42+0xf7>
    430c:	mov    ecx,0x2
    4311:	mov    rax,r14
    4314:	test   rax,rax
    4317:	cmovle rcx,QWORD PTR [rip+0x129]        # 4448 <botlish_fn_42+0x220>
    431f:	cmp    rcx,0x6
    4323:	je     43f1 <botlish_fn_42+0x1c9>
    4329:	mov    rsi,r13
    432c:	mov    rdi,r12
    432f:	call   4334 <botlish_fn_42+0x10c>
			4330: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_values<generic>
    4334:	test   rax,rax
    4337:	jne    4345 <botlish_fn_42+0x11d>
    433d:	mov    rdi,r12
    4340:	jmp    43aa <botlish_fn_42+0x182>
    4345:	xor    ecx,ecx
    4347:	test   rax,0x7
    434d:	jne    435e <botlish_fn_42+0x136>
    4353:	movzx  rsi,BYTE PTR [rax]
    4357:	cmp    sil,0x8
    435b:	sete   cl
    435e:	test   cl,cl
    4360:	jne    438b <botlish_fn_42+0x163>
    4366:	mov    rdi,r12
    4369:	mov    r10,QWORD PTR [rdi+0x10]
    436d:	mov    rcx,QWORD PTR [r10+0x20]
    4371:	mov    edx,0x8
    4376:	mov    r10,QWORD PTR [rip+0x0]        # 437d <botlish_fn_42+0x155>
			4379: R_X86_64_GOTPCREL	rt_type_error-0x4
    437d:	mov    rsi,rax
    4380:	call   r10
    4383:	mov    rdi,r12
    4386:	jmp    43aa <botlish_fn_42+0x182>
    438b:	mov    rsi,rax
    438e:	mov    r11,QWORD PTR [rip+0x0]        # 4395 <botlish_fn_42+0x16d>
			4391: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    4395:	mov    rdx,r14
    4398:	mov    rdi,r12
    439b:	call   r11
    439e:	test   rax,rax
    43a1:	jne    43cf <botlish_fn_42+0x1a7>
    43a7:	mov    rdi,r12
    43aa:	mov    rdi,r12
    43ad:	mov    QWORD PTR [rdi],rbx
    43b0:	xor    rax,rax
    43b3:	mov    rbx,QWORD PTR [rsp]
    43b7:	mov    r12,QWORD PTR [rsp+0x8]
    43bc:	mov    r13,QWORD PTR [rsp+0x10]
    43c1:	mov    r14,QWORD PTR [rsp+0x18]
    43c6:	add    rsp,0x20
    43ca:	mov    rsp,rbp
    43cd:	pop    rbp
    43ce:	ret
    43cf:	mov    rdi,r12
    43d2:	mov    QWORD PTR [rdi],rbx
    43d5:	mov    rbx,QWORD PTR [rsp]
    43d9:	mov    r12,QWORD PTR [rsp+0x8]
    43de:	mov    r13,QWORD PTR [rsp+0x10]
    43e3:	mov    r14,QWORD PTR [rsp+0x18]
    43e8:	add    rsp,0x20
    43ec:	mov    rsp,rbp
    43ef:	pop    rbp
    43f0:	ret
    43f1:	mov    rdi,r12
    43f4:	mov    QWORD PTR [rdi],rbx
    43f7:	mov    eax,0xa
    43fc:	mov    rbx,QWORD PTR [rsp]
    4400:	mov    r12,QWORD PTR [rsp+0x8]
    4405:	mov    r13,QWORD PTR [rsp+0x10]
    440a:	mov    r14,QWORD PTR [rsp+0x18]
    440f:	add    rsp,0x20
    4413:	mov    rsp,rbp
    4416:	pop    rbp
    4417:	ret
    4418:	mov    r12,rdi
    441b:	mov    rax,QWORD PTR [rip+0x0]        # 4422 <botlish_fn_42+0x1fa>
			441e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    4422:	call   rax
    4424:	xor    rax,rax
    4427:	mov    rbx,QWORD PTR [rsp]
    442b:	mov    r12,QWORD PTR [rsp+0x8]
    4430:	mov    r13,QWORD PTR [rsp+0x10]
    4435:	mov    r14,QWORD PTR [rsp+0x18]
    443a:	add    rsp,0x20
    443e:	mov    rsp,rbp
    4441:	pop    rbp
    4442:	ret
    4443:	add    BYTE PTR [rax],al
    4445:	add    BYTE PTR [rax],al
    4447:	add    BYTE PTR [rsi],al
    4449:	add    BYTE PTR [rax],al
    444b:	add    BYTE PTR [rax],al
    444d:	add    BYTE PTR [rax],al
	...

0000000000004450 <botlish_entry_42: ht_get<any, str>>:
    4450:	push   rbp
    4451:	mov    rbp,rsp
    4454:	mov    rsi,QWORD PTR [rdx]
    4457:	mov    rdx,QWORD PTR [rdx+0x8]
    445b:	call   4460 <botlish_entry_42+0x10>
			445c: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    4460:	mov    rsp,rbp
    4463:	pop    rbp
    4464:	ret
    4465:	add    BYTE PTR [rax],al
	...

0000000000004468 <botlish_fn_43: ht_rehash_probe<mutarray, int, int>>:
    4468:	push   rbp
    4469:	mov    rbp,rsp
    446c:	sub    rsp,0x40
    4470:	mov    QWORD PTR [rsp+0x10],rbx
    4475:	mov    QWORD PTR [rsp+0x18],r12
    447a:	mov    QWORD PTR [rsp+0x20],r13
    447f:	mov    QWORD PTR [rsp+0x28],r14
    4484:	mov    QWORD PTR [rsp+0x30],r15
    4489:	mov    r12,QWORD PTR [rdi]
    448c:	mov    rax,QWORD PTR [rdi+0x8]
    4490:	lea    r8,[r12+0x20]
    4495:	cmp    r8,rax
    4498:	ja     4654 <botlish_fn_43+0x1ec>
    449e:	lea    rax,[r12+0x20]
    44a3:	mov    QWORD PTR [rdi],rax
    44a6:	mov    r14,rdi
    44a9:	mov    QWORD PTR [r12],0x0
    44b1:	mov    QWORD PTR [r12+0x8],0x0
    44ba:	mov    QWORD PTR [r12+0x10],0x0
    44c3:	mov    QWORD PTR [r12+0x18],0x0
    44cc:	mov    QWORD PTR [r12],rsi
    44d0:	mov    QWORD PTR [r12+0x8],rdx
    44d5:	mov    QWORD PTR [r12+0x10],rcx
    44da:	mov    r13,rcx
    44dd:	mov    r15,rdx
    44e0:	mov    rax,QWORD PTR [rip+0x0]        # 44e7 <botlish_fn_43+0x7f>
			44e3: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    44e7:	mov    rbx,rsi
    44ea:	mov    rdx,r15
    44ed:	mov    rdi,r14
    44f0:	call   rax
    44f2:	test   rax,rax
    44f5:	jne    4503 <botlish_fn_43+0x9b>
    44fb:	mov    rdi,r14
    44fe:	jmp    45e5 <botlish_fn_43+0x17d>
    4503:	mov    QWORD PTR [r12+0x18],rax
    4508:	mov    QWORD PTR [rsp],rax
    450c:	mov    rdi,r14
    450f:	call   4514 <botlish_fn_43+0xac>
			4510: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_empty_state<generic>
    4514:	test   rax,rax
    4517:	jne    4525 <botlish_fn_43+0xbd>
    451d:	mov    rdi,r14
    4520:	jmp    45e5 <botlish_fn_43+0x17d>
    4525:	mov    rcx,QWORD PTR [rsp]
    4529:	mov    rdx,rcx
    452c:	and    rdx,rax
    452f:	mov    rcx,rax
    4532:	test   rdx,0x1
    4539:	jne    4563 <botlish_fn_43+0xfb>
    453f:	mov    rax,QWORD PTR [rip+0x0]        # 4546 <botlish_fn_43+0xde>
			4542: R_X86_64_GOTPCREL	rt_value_eq-0x4
    4546:	mov    rdx,rcx
    4549:	mov    rsi,QWORD PTR [rsp]
    454d:	mov    rdi,r14
    4550:	call   rax
    4552:	test   rax,rax
    4555:	jne    457a <botlish_fn_43+0x112>
    455b:	mov    rdi,r14
    455e:	jmp    45e5 <botlish_fn_43+0x17d>
    4563:	mov    rdx,rcx
    4566:	mov    rsi,QWORD PTR [rsp]
    456a:	mov    eax,0x2
    456f:	cmp    rsi,rdx
    4572:	cmove  rax,QWORD PTR [rip+0x10e]        # 4688 <botlish_fn_43+0x220>
    457a:	cmp    rax,0x6
    457e:	je     4629 <botlish_fn_43+0x1c1>
    4584:	mov    QWORD PTR [r12+0x18],0x3
    458d:	mov    rsi,r15
    4590:	test   rsi,0x1
    4597:	je     45b1 <botlish_fn_43+0x149>
    459d:	mov    rsi,r15
    45a0:	add    rsi,0x2
    45a4:	seto   dil
    45a8:	test   dil,dil
    45ab:	je     45c9 <botlish_fn_43+0x161>
    45b1:	mov    edx,0x3
    45b6:	mov    r8,QWORD PTR [rip+0x0]        # 45bd <botlish_fn_43+0x155>
			45b9: R_X86_64_GOTPCREL	rt_int_add-0x4
    45bd:	mov    rsi,r15
    45c0:	mov    rdi,r14
    45c3:	call   r8
    45c6:	mov    rsi,rax
    45c9:	mov    r8,QWORD PTR [rip+0x0]        # 45d0 <botlish_fn_43+0x168>
			45cc: R_X86_64_GOTPCREL	rt_int_mod-0x4
    45d0:	mov    rdx,r13
    45d3:	mov    rdi,r14
    45d6:	call   r8
    45d9:	test   rax,rax
    45dc:	jne    4610 <botlish_fn_43+0x1a8>
    45e2:	mov    rdi,r14
    45e5:	mov    rdi,r14
    45e8:	mov    QWORD PTR [rdi],r12
    45eb:	xor    rax,rax
    45ee:	mov    rbx,QWORD PTR [rsp+0x10]
    45f3:	mov    r12,QWORD PTR [rsp+0x18]
    45f8:	mov    r13,QWORD PTR [rsp+0x20]
    45fd:	mov    r14,QWORD PTR [rsp+0x28]
    4602:	mov    r15,QWORD PTR [rsp+0x30]
    4607:	add    rsp,0x40
    460b:	mov    rsp,rbp
    460e:	pop    rbp
    460f:	ret
    4610:	mov    QWORD PTR [r12],rbx
    4614:	mov    QWORD PTR [r12+0x8],rax
    4619:	mov    QWORD PTR [r12+0x10],r13
    461e:	mov    rsi,rbx
    4621:	mov    r15,rax
    4624:	jmp    44e0 <botlish_fn_43+0x78>
    4629:	mov    rdi,r14
    462c:	mov    QWORD PTR [rdi],r12
    462f:	mov    rax,r15
    4632:	mov    rbx,QWORD PTR [rsp+0x10]
    4637:	mov    r12,QWORD PTR [rsp+0x18]
    463c:	mov    r13,QWORD PTR [rsp+0x20]
    4641:	mov    r14,QWORD PTR [rsp+0x28]
    4646:	mov    r15,QWORD PTR [rsp+0x30]
    464b:	add    rsp,0x40
    464f:	mov    rsp,rbp
    4652:	pop    rbp
    4653:	ret
    4654:	mov    r14,rdi
    4657:	mov    rax,QWORD PTR [rip+0x0]        # 465e <botlish_fn_43+0x1f6>
			465a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    465e:	call   rax
    4660:	xor    rax,rax
    4663:	mov    rbx,QWORD PTR [rsp+0x10]
    4668:	mov    r12,QWORD PTR [rsp+0x18]
    466d:	mov    r13,QWORD PTR [rsp+0x20]
    4672:	mov    r14,QWORD PTR [rsp+0x28]
    4677:	mov    r15,QWORD PTR [rsp+0x30]
    467c:	add    rsp,0x40
    4680:	mov    rsp,rbp
    4683:	pop    rbp
    4684:	ret
    4685:	add    BYTE PTR [rax],al
    4687:	add    BYTE PTR [rsi],al
    4689:	add    BYTE PTR [rax],al
    468b:	add    BYTE PTR [rax],al
    468d:	add    BYTE PTR [rax],al
	...

0000000000004690 <botlish_entry_43: ht_rehash_probe<mutarray, int, int>>:
    4690:	push   rbp
    4691:	mov    rbp,rsp
    4694:	mov    rsi,QWORD PTR [rdx]
    4697:	mov    r8,QWORD PTR [rdx+0x8]
    469b:	mov    rcx,QWORD PTR [rdx+0x10]
    469f:	mov    rdx,r8
    46a2:	call   46a7 <botlish_entry_43+0x17>
			46a3: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    46a7:	mov    rsp,rbp
    46aa:	pop    rbp
    46ab:	ret

00000000000046ac <botlish_fn_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    46ac:	push   rbp
    46ad:	mov    rbp,rsp
    46b0:	sub    rsp,0x40
    46b4:	mov    QWORD PTR [rsp+0x10],rbx
    46b9:	mov    QWORD PTR [rsp+0x18],r12
    46be:	mov    QWORD PTR [rsp+0x20],r13
    46c3:	mov    QWORD PTR [rsp+0x28],r14
    46c8:	mov    QWORD PTR [rsp+0x30],r15
    46cd:	mov    rbx,QWORD PTR [rdi]
    46d0:	mov    rax,QWORD PTR [rdi+0x8]
    46d4:	lea    r9,[rbx+0x30]
    46d8:	cmp    r9,rax
    46db:	ja     4904 <botlish_fn_44+0x258>
    46e1:	lea    rax,[rbx+0x30]
    46e5:	mov    QWORD PTR [rdi],rax
    46e8:	mov    r13,rdi
    46eb:	mov    QWORD PTR [rbx],0x0
    46f2:	mov    QWORD PTR [rbx+0x8],0x0
    46fa:	mov    QWORD PTR [rbx+0x10],0x0
    4702:	mov    QWORD PTR [rbx+0x18],0x0
    470a:	mov    QWORD PTR [rbx+0x20],0x0
    4712:	mov    QWORD PTR [rbx+0x28],0x0
    471a:	mov    QWORD PTR [rbx],rsi
    471d:	mov    r15,rsi
    4720:	mov    QWORD PTR [rbx+0x8],rdx
    4724:	mov    r12,rdx
    4727:	mov    QWORD PTR [rbx+0x10],rcx
    472b:	mov    QWORD PTR [rsp],rcx
    472f:	mov    QWORD PTR [rbx+0x18],r8
    4733:	mov    r14,r8
    4736:	mov    edx,0x1
    473b:	mov    rax,QWORD PTR [rip+0x0]        # 4742 <botlish_fn_44+0x96>
			473e: R_X86_64_GOTPCREL	rt_list_get-0x4
    4742:	mov    rsi,r15
    4745:	mov    rdi,r13
    4748:	call   rax
    474a:	test   rax,rax
    474d:	jne    475b <botlish_fn_44+0xaf>
    4753:	mov    rdi,r13
    4756:	jmp    48ac <botlish_fn_44+0x200>
    475b:	mov    QWORD PTR [rbx+0x20],rax
    475f:	mov    QWORD PTR [rsp+0x8],rax
    4764:	mov    rax,QWORD PTR [rip+0x0]        # 476b <botlish_fn_44+0xbf>
			4767: R_X86_64_GOTPCREL	rt_hash-0x4
    476b:	mov    rsi,QWORD PTR [rsp]
    476f:	mov    rdi,r13
    4772:	call   rax
    4774:	test   rax,rax
    4777:	mov    rsi,rax
    477a:	jne    4788 <botlish_fn_44+0xdc>
    4780:	mov    rdi,r13
    4783:	jmp    48ac <botlish_fn_44+0x200>
    4788:	mov    rax,QWORD PTR [rip+0x0]        # 478f <botlish_fn_44+0xe3>
			478b: R_X86_64_GOTPCREL	rt_int_mod-0x4
    478f:	mov    rdx,r12
    4792:	mov    rdi,r13
    4795:	call   rax
    4797:	test   rax,rax
    479a:	jne    47a8 <botlish_fn_44+0xfc>
    47a0:	mov    rdi,r13
    47a3:	jmp    48ac <botlish_fn_44+0x200>
    47a8:	mov    QWORD PTR [rbx+0x28],rax
    47ac:	mov    rcx,r12
    47af:	mov    rdx,rax
    47b2:	mov    rsi,QWORD PTR [rsp+0x8]
    47b7:	mov    rdi,r13
    47ba:	call   47bf <botlish_fn_44+0x113>
			47bb: R_X86_64_PLT32	botlish_fn_43-0x4 ; ht_rehash_probe<mutarray, int, int>
    47bf:	mov    r12,rax
    47c2:	test   r12,r12
    47c5:	jne    47d3 <botlish_fn_44+0x127>
    47cb:	mov    rdi,r13
    47ce:	jmp    48ac <botlish_fn_44+0x200>
    47d3:	mov    QWORD PTR [rbx+0x8],r12
    47d7:	mov    rdi,r13
    47da:	call   47df <botlish_fn_44+0x133>
			47db: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    47df:	test   rax,rax
    47e2:	mov    rcx,rax
    47e5:	jne    47f3 <botlish_fn_44+0x147>
    47eb:	mov    rdi,r13
    47ee:	jmp    48ac <botlish_fn_44+0x200>
    47f3:	mov    r8,QWORD PTR [rip+0x0]        # 47fa <botlish_fn_44+0x14e>
			47f6: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    47fa:	mov    rsi,QWORD PTR [rsp+0x8]
    47ff:	mov    rdx,r12
    4802:	mov    rdi,r13
    4805:	call   r8
    4808:	test   rax,rax
    480b:	jne    4819 <botlish_fn_44+0x16d>
    4811:	mov    rdi,r13
    4814:	jmp    48ac <botlish_fn_44+0x200>
    4819:	mov    edx,0x3
    481e:	mov    r9,QWORD PTR [rip+0x0]        # 4825 <botlish_fn_44+0x179>
			4821: R_X86_64_GOTPCREL	rt_list_get-0x4
    4825:	mov    rsi,r15
    4828:	mov    rdi,r13
    482b:	call   r9
    482e:	test   rax,rax
    4831:	mov    rsi,rax
    4834:	jne    4842 <botlish_fn_44+0x196>
    483a:	mov    rdi,r13
    483d:	jmp    48ac <botlish_fn_44+0x200>
    4842:	mov    rax,QWORD PTR [rip+0x0]        # 4849 <botlish_fn_44+0x19d>
			4845: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    4849:	mov    rcx,QWORD PTR [rsp]
    484d:	mov    rdx,r12
    4850:	mov    rdi,r13
    4853:	call   rax
    4855:	test   rax,rax
    4858:	jne    4866 <botlish_fn_44+0x1ba>
    485e:	mov    rdi,r13
    4861:	jmp    48ac <botlish_fn_44+0x200>
    4866:	mov    edx,0x5
    486b:	mov    rax,QWORD PTR [rip+0x0]        # 4872 <botlish_fn_44+0x1c6>
			486e: R_X86_64_GOTPCREL	rt_list_get-0x4
    4872:	mov    rsi,r15
    4875:	mov    rdi,r13
    4878:	call   rax
    487a:	test   rax,rax
    487d:	mov    rsi,rax
    4880:	jne    488e <botlish_fn_44+0x1e2>
    4886:	mov    rdi,r13
    4889:	jmp    48ac <botlish_fn_44+0x200>
    488e:	mov    rax,QWORD PTR [rip+0x0]        # 4895 <botlish_fn_44+0x1e9>
			4891: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    4895:	mov    rcx,r14
    4898:	mov    rdx,r12
    489b:	mov    rdi,r13
    489e:	call   rax
    48a0:	test   rax,rax
    48a3:	jne    48d7 <botlish_fn_44+0x22b>
    48a9:	mov    rdi,r13
    48ac:	mov    rdi,r13
    48af:	mov    QWORD PTR [rdi],rbx
    48b2:	xor    rax,rax
    48b5:	mov    rbx,QWORD PTR [rsp+0x10]
    48ba:	mov    r12,QWORD PTR [rsp+0x18]
    48bf:	mov    r13,QWORD PTR [rsp+0x20]
    48c4:	mov    r14,QWORD PTR [rsp+0x28]
    48c9:	mov    r15,QWORD PTR [rsp+0x30]
    48ce:	add    rsp,0x40
    48d2:	mov    rsp,rbp
    48d5:	pop    rbp
    48d6:	ret
    48d7:	mov    rdi,r13
    48da:	mov    QWORD PTR [rdi],rbx
    48dd:	mov    eax,0xa
    48e2:	mov    rbx,QWORD PTR [rsp+0x10]
    48e7:	mov    r12,QWORD PTR [rsp+0x18]
    48ec:	mov    r13,QWORD PTR [rsp+0x20]
    48f1:	mov    r14,QWORD PTR [rsp+0x28]
    48f6:	mov    r15,QWORD PTR [rsp+0x30]
    48fb:	add    rsp,0x40
    48ff:	mov    rsp,rbp
    4902:	pop    rbp
    4903:	ret
    4904:	mov    r13,rdi
    4907:	mov    rax,QWORD PTR [rip+0x0]        # 490e <botlish_fn_44+0x262>
			490a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    490e:	call   rax
    4910:	xor    rax,rax
    4913:	mov    rbx,QWORD PTR [rsp+0x10]
    4918:	mov    r12,QWORD PTR [rsp+0x18]
    491d:	mov    r13,QWORD PTR [rsp+0x20]
    4922:	mov    r14,QWORD PTR [rsp+0x28]
    4927:	mov    r15,QWORD PTR [rsp+0x30]
    492c:	add    rsp,0x40
    4930:	mov    rsp,rbp
    4933:	pop    rbp
    4934:	ret

0000000000004935 <botlish_entry_44: ht_rehash_insert<list<mutarray>, int, any, any>>:
    4935:	push   rbp
    4936:	mov    rbp,rsp
    4939:	mov    rsi,QWORD PTR [rdx]
    493c:	mov    r9,QWORD PTR [rdx+0x8]
    4940:	mov    rcx,QWORD PTR [rdx+0x10]
    4944:	mov    r8,QWORD PTR [rdx+0x18]
    4948:	mov    rdx,r9
    494b:	call   4950 <botlish_entry_44+0x1b>
			494c: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    4950:	mov    rsp,rbp
    4953:	pop    rbp
    4954:	ret
    4955:	add    BYTE PTR [rax],al
	...

0000000000004958 <botlish_fn_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    4958:	push   rbp
    4959:	mov    rbp,rsp
    495c:	sub    rsp,0x50
    4960:	mov    QWORD PTR [rsp+0x20],rbx
    4965:	mov    QWORD PTR [rsp+0x28],r12
    496a:	mov    QWORD PTR [rsp+0x30],r13
    496f:	mov    QWORD PTR [rsp+0x38],r14
    4974:	mov    QWORD PTR [rsp+0x40],r15
    4979:	mov    r15,QWORD PTR [rdi]
    497c:	mov    rax,QWORD PTR [rdi+0x8]
    4980:	lea    r10,[r15+0x38]
    4984:	cmp    r10,rax
    4987:	ja     4dcc <botlish_fn_45+0x474>
    498d:	lea    rax,[r15+0x38]
    4991:	mov    QWORD PTR [rdi],rax
    4994:	mov    QWORD PTR [rsp],rdi
    4998:	mov    QWORD PTR [r15],0x0
    499f:	mov    QWORD PTR [r15+0x8],0x0
    49a7:	mov    QWORD PTR [r15+0x10],0x0
    49af:	mov    QWORD PTR [r15+0x18],0x0
    49b7:	mov    QWORD PTR [r15+0x20],0x0
    49bf:	mov    QWORD PTR [r15+0x28],0x0
    49c7:	mov    QWORD PTR [r15+0x30],0x0
    49cf:	mov    QWORD PTR [r15],rsi
    49d2:	mov    r12,rsi
    49d5:	mov    QWORD PTR [r15+0x8],rdx
    49d9:	mov    QWORD PTR [r15+0x10],rcx
    49dd:	mov    QWORD PTR [r15+0x18],r8
    49e1:	mov    r14,r8
    49e4:	mov    QWORD PTR [r15+0x20],r9
    49e8:	mov    r13,r9
    49eb:	mov    rbx,rcx
    49ee:	mov    rsi,rdx
    49f1:	mov    rax,rsi
    49f4:	and    rax,rbx
    49f7:	mov    QWORD PTR [rsp+0x8],rsi
    49fc:	test   rax,0x1
    4a02:	jne    4a32 <botlish_fn_45+0xda>
    4a08:	mov    rax,QWORD PTR [rip+0x0]        # 4a0f <botlish_fn_45+0xb7>
			4a0b: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    4a0f:	mov    rdx,rbx
    4a12:	mov    rsi,QWORD PTR [rsp+0x8]
    4a17:	mov    rdi,QWORD PTR [rsp]
    4a1b:	call   rax
    4a1d:	mov    ecx,0x2
    4a22:	test   rax,rax
    4a25:	cmovge rcx,QWORD PTR [rip+0x3d3]        # 4e00 <botlish_fn_45+0x4a8>
    4a2d:	jmp    4a47 <botlish_fn_45+0xef>
    4a32:	mov    ecx,0x2
    4a37:	mov    rsi,QWORD PTR [rsp+0x8]
    4a3c:	cmp    rsi,rbx
    4a3f:	cmovge rcx,QWORD PTR [rip+0x3b9]        # 4e00 <botlish_fn_45+0x4a8>
    4a47:	cmp    rcx,0x6
    4a4b:	je     4d9e <botlish_fn_45+0x446>
    4a51:	mov    edx,0x1
    4a56:	mov    rax,QWORD PTR [rip+0x0]        # 4a5d <botlish_fn_45+0x105>
			4a59: R_X86_64_GOTPCREL	rt_list_get-0x4
    4a5d:	mov    rsi,r12
    4a60:	mov    rdi,QWORD PTR [rsp]
    4a64:	call   rax
    4a66:	test   rax,rax
    4a69:	jne    4a78 <botlish_fn_45+0x120>
    4a6f:	mov    rdi,QWORD PTR [rsp]
    4a73:	jmp    4cf5 <botlish_fn_45+0x39d>
    4a78:	xor    ecx,ecx
    4a7a:	test   rax,0x7
    4a80:	je     4a8e <botlish_fn_45+0x136>
    4a86:	mov    rsi,rax
    4a89:	jmp    4a9c <botlish_fn_45+0x144>
    4a8e:	movzx  rcx,BYTE PTR [rax]
    4a92:	mov    rsi,rax
    4a95:	rex cmp cl,0x8
    4a99:	sete   cl
    4a9c:	test   cl,cl
    4a9e:	jne    4ac7 <botlish_fn_45+0x16f>
    4aa4:	mov    rdi,QWORD PTR [rsp]
    4aa8:	mov    rax,QWORD PTR [rdi+0x10]
    4aac:	mov    rcx,QWORD PTR [rax+0x20]
    4ab0:	mov    edx,0x8
    4ab5:	mov    rax,QWORD PTR [rip+0x0]        # 4abc <botlish_fn_45+0x164>
			4ab8: R_X86_64_GOTPCREL	rt_type_error-0x4
    4abc:	call   rax
    4abe:	mov    rdi,QWORD PTR [rsp]
    4ac2:	jmp    4cf5 <botlish_fn_45+0x39d>
    4ac7:	mov    rax,QWORD PTR [rip+0x0]        # 4ace <botlish_fn_45+0x176>
			4aca: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    4ace:	mov    rdx,QWORD PTR [rsp+0x8]
    4ad3:	mov    rdi,QWORD PTR [rsp]
    4ad7:	call   rax
    4ad9:	test   rax,rax
    4adc:	jne    4aeb <botlish_fn_45+0x193>
    4ae2:	mov    rdi,QWORD PTR [rsp]
    4ae6:	jmp    4cf5 <botlish_fn_45+0x39d>
    4aeb:	mov    QWORD PTR [r15+0x28],rax
    4aef:	mov    QWORD PTR [rsp+0x10],rax
    4af4:	mov    rdi,QWORD PTR [rsp]
    4af8:	call   4afd <botlish_fn_45+0x1a5>
			4af9: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    4afd:	test   rax,rax
    4b00:	jne    4b0f <botlish_fn_45+0x1b7>
    4b06:	mov    rdi,QWORD PTR [rsp]
    4b0a:	jmp    4cf5 <botlish_fn_45+0x39d>
    4b0f:	mov    rsi,QWORD PTR [rsp+0x10]
    4b14:	mov    rdx,rsi
    4b17:	and    rdx,rax
    4b1a:	test   rdx,0x1
    4b21:	jne    4b4f <botlish_fn_45+0x1f7>
    4b27:	mov    r8,QWORD PTR [rip+0x0]        # 4b2e <botlish_fn_45+0x1d6>
			4b2a: R_X86_64_GOTPCREL	rt_value_eq-0x4
    4b2e:	mov    rdx,rax
    4b31:	mov    rsi,QWORD PTR [rsp+0x10]
    4b36:	mov    rdi,QWORD PTR [rsp]
    4b3a:	call   r8
    4b3d:	test   rax,rax
    4b40:	jne    4b67 <botlish_fn_45+0x20f>
    4b46:	mov    rdi,QWORD PTR [rsp]
    4b4a:	jmp    4cf5 <botlish_fn_45+0x39d>
    4b4f:	mov    rdx,rax
    4b52:	mov    rsi,QWORD PTR [rsp+0x10]
    4b57:	mov    eax,0x2
    4b5c:	cmp    rsi,rdx
    4b5f:	cmove  rax,QWORD PTR [rip+0x299]        # 4e00 <botlish_fn_45+0x4a8>
    4b67:	cmp    rax,0x6
    4b6b:	je     4b7f <botlish_fn_45+0x227>
    4b71:	mov    rax,r13
    4b74:	mov    r13,r14
    4b77:	mov    r14,rax
    4b7a:	jmp    4d21 <botlish_fn_45+0x3c9>
    4b7f:	mov    edx,0x3
    4b84:	mov    rax,QWORD PTR [rip+0x0]        # 4b8b <botlish_fn_45+0x233>
			4b87: R_X86_64_GOTPCREL	rt_list_get-0x4
    4b8b:	mov    rsi,r12
    4b8e:	mov    rdi,QWORD PTR [rsp]
    4b92:	call   rax
    4b94:	test   rax,rax
    4b97:	jne    4ba6 <botlish_fn_45+0x24e>
    4b9d:	mov    rdi,QWORD PTR [rsp]
    4ba1:	jmp    4cf5 <botlish_fn_45+0x39d>
    4ba6:	xor    ecx,ecx
    4ba8:	test   rax,0x7
    4bae:	je     4bbc <botlish_fn_45+0x264>
    4bb4:	mov    rsi,rax
    4bb7:	jmp    4bca <botlish_fn_45+0x272>
    4bbc:	movzx  rcx,BYTE PTR [rax]
    4bc0:	mov    rsi,rax
    4bc3:	rex cmp cl,0x8
    4bc7:	sete   cl
    4bca:	test   cl,cl
    4bcc:	jne    4bf5 <botlish_fn_45+0x29d>
    4bd2:	mov    rdi,QWORD PTR [rsp]
    4bd6:	mov    rax,QWORD PTR [rdi+0x10]
    4bda:	mov    rcx,QWORD PTR [rax+0x20]
    4bde:	mov    edx,0x8
    4be3:	mov    rax,QWORD PTR [rip+0x0]        # 4bea <botlish_fn_45+0x292>
			4be6: R_X86_64_GOTPCREL	rt_type_error-0x4
    4bea:	call   rax
    4bec:	mov    rdi,QWORD PTR [rsp]
    4bf0:	jmp    4cf5 <botlish_fn_45+0x39d>
    4bf5:	mov    rax,QWORD PTR [rip+0x0]        # 4bfc <botlish_fn_45+0x2a4>
			4bf8: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    4bfc:	mov    rdx,QWORD PTR [rsp+0x8]
    4c01:	mov    rdi,QWORD PTR [rsp]
    4c05:	call   rax
    4c07:	test   rax,rax
    4c0a:	jne    4c19 <botlish_fn_45+0x2c1>
    4c10:	mov    rdi,QWORD PTR [rsp]
    4c14:	jmp    4cf5 <botlish_fn_45+0x39d>
    4c19:	mov    QWORD PTR [r15+0x28],rax
    4c1d:	mov    QWORD PTR [rsp+0x10],rax
    4c22:	mov    edx,0x5
    4c27:	mov    rax,QWORD PTR [rip+0x0]        # 4c2e <botlish_fn_45+0x2d6>
			4c2a: R_X86_64_GOTPCREL	rt_list_get-0x4
    4c2e:	mov    rsi,r12
    4c31:	mov    rdi,QWORD PTR [rsp]
    4c35:	call   rax
    4c37:	test   rax,rax
    4c3a:	jne    4c49 <botlish_fn_45+0x2f1>
    4c40:	mov    rdi,QWORD PTR [rsp]
    4c44:	jmp    4cf5 <botlish_fn_45+0x39d>
    4c49:	xor    esi,esi
    4c4b:	test   rax,0x7
    4c51:	je     4c5f <botlish_fn_45+0x307>
    4c57:	mov    r8,rax
    4c5a:	jmp    4c6e <botlish_fn_45+0x316>
    4c5f:	movzx  rcx,BYTE PTR [rax]
    4c63:	mov    r8,rax
    4c66:	rex cmp cl,0x8
    4c6a:	sete   sil
    4c6e:	test   sil,sil
    4c71:	jne    4c9d <botlish_fn_45+0x345>
    4c77:	mov    rdi,QWORD PTR [rsp]
    4c7b:	mov    rax,QWORD PTR [rdi+0x10]
    4c7f:	mov    rcx,QWORD PTR [rax+0x20]
    4c83:	mov    edx,0x8
    4c88:	mov    rax,QWORD PTR [rip+0x0]        # 4c8f <botlish_fn_45+0x337>
			4c8b: R_X86_64_GOTPCREL	rt_type_error-0x4
    4c8f:	mov    rsi,r8
    4c92:	call   rax
    4c94:	mov    rdi,QWORD PTR [rsp]
    4c98:	jmp    4cf5 <botlish_fn_45+0x39d>
    4c9d:	mov    rsi,r8
    4ca0:	mov    rax,QWORD PTR [rip+0x0]        # 4ca7 <botlish_fn_45+0x34f>
			4ca3: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    4ca7:	mov    rdx,QWORD PTR [rsp+0x8]
    4cac:	mov    rdi,QWORD PTR [rsp]
    4cb0:	call   rax
    4cb2:	test   rax,rax
    4cb5:	jne    4cc4 <botlish_fn_45+0x36c>
    4cbb:	mov    rdi,QWORD PTR [rsp]
    4cbf:	jmp    4cf5 <botlish_fn_45+0x39d>
    4cc4:	mov    QWORD PTR [r15+0x30],rax
    4cc8:	mov    r9,r13
    4ccb:	mov    r13,r14
    4cce:	mov    r14,r9
    4cd1:	mov    r8,rax
    4cd4:	mov    rcx,QWORD PTR [rsp+0x10]
    4cd9:	mov    rdx,r14
    4cdc:	mov    rsi,r13
    4cdf:	mov    rdi,QWORD PTR [rsp]
    4ce3:	call   4ce8 <botlish_fn_45+0x390>
			4ce4: R_X86_64_PLT32	botlish_fn_44-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    4ce8:	test   rax,rax
    4ceb:	jne    4d21 <botlish_fn_45+0x3c9>
    4cf1:	mov    rdi,QWORD PTR [rsp]
    4cf5:	mov    rdi,QWORD PTR [rsp]
    4cf9:	mov    QWORD PTR [rdi],r15
    4cfc:	xor    rax,rax
    4cff:	mov    rbx,QWORD PTR [rsp+0x20]
    4d04:	mov    r12,QWORD PTR [rsp+0x28]
    4d09:	mov    r13,QWORD PTR [rsp+0x30]
    4d0e:	mov    r14,QWORD PTR [rsp+0x38]
    4d13:	mov    r15,QWORD PTR [rsp+0x40]
    4d18:	add    rsp,0x50
    4d1c:	mov    rsp,rbp
    4d1f:	pop    rbp
    4d20:	ret
    4d21:	mov    edx,0x3
    4d26:	mov    QWORD PTR [r15+0x28],0x3
    4d2e:	mov    rsi,QWORD PTR [rsp+0x8]
    4d33:	test   rsi,0x1
    4d3a:	je     4d61 <botlish_fn_45+0x409>
    4d40:	mov    rsi,QWORD PTR [rsp+0x8]
    4d45:	mov    rax,rsi
    4d48:	add    rax,0x2
    4d4c:	seto   cl
    4d4f:	test   cl,cl
    4d51:	jne    4d61 <botlish_fn_45+0x409>
    4d57:	mov    QWORD PTR [rsp+0x8],rax
    4d5c:	jmp    4d78 <botlish_fn_45+0x420>
    4d61:	mov    rax,QWORD PTR [rip+0x0]        # 4d68 <botlish_fn_45+0x410>
			4d64: R_X86_64_GOTPCREL	rt_int_add-0x4
    4d68:	mov    rsi,QWORD PTR [rsp+0x8]
    4d6d:	mov    rdi,QWORD PTR [rsp]
    4d71:	call   rax
    4d73:	mov    QWORD PTR [rsp+0x8],rax
    4d78:	mov    QWORD PTR [r15],r12
    4d7b:	mov    rsi,QWORD PTR [rsp+0x8]
    4d80:	mov    QWORD PTR [r15+0x8],rsi
    4d84:	mov    QWORD PTR [r15+0x10],rbx
    4d88:	mov    QWORD PTR [r15+0x18],r13
    4d8c:	mov    QWORD PTR [r15+0x20],r14
    4d90:	mov    rax,r13
    4d93:	mov    r13,r14
    4d96:	mov    r14,rax
    4d99:	jmp    49f1 <botlish_fn_45+0x99>
    4d9e:	mov    rdi,QWORD PTR [rsp]
    4da2:	mov    QWORD PTR [rdi],r15
    4da5:	mov    eax,0xa
    4daa:	mov    rbx,QWORD PTR [rsp+0x20]
    4daf:	mov    r12,QWORD PTR [rsp+0x28]
    4db4:	mov    r13,QWORD PTR [rsp+0x30]
    4db9:	mov    r14,QWORD PTR [rsp+0x38]
    4dbe:	mov    r15,QWORD PTR [rsp+0x40]
    4dc3:	add    rsp,0x50
    4dc7:	mov    rsp,rbp
    4dca:	pop    rbp
    4dcb:	ret
    4dcc:	mov    QWORD PTR [rsp],rdi
    4dd0:	mov    rsi,QWORD PTR [rip+0x0]        # 4dd7 <botlish_fn_45+0x47f>
			4dd3: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    4dd7:	call   rsi
    4dd9:	xor    rax,rax
    4ddc:	mov    rbx,QWORD PTR [rsp+0x20]
    4de1:	mov    r12,QWORD PTR [rsp+0x28]
    4de6:	mov    r13,QWORD PTR [rsp+0x30]
    4deb:	mov    r14,QWORD PTR [rsp+0x38]
    4df0:	mov    r15,QWORD PTR [rsp+0x40]
    4df5:	add    rsp,0x50
    4df9:	mov    rsp,rbp
    4dfc:	pop    rbp
    4dfd:	ret
    4dfe:	add    BYTE PTR [rax],al
    4e00:	(bad)
    4e01:	add    BYTE PTR [rax],al
    4e03:	add    BYTE PTR [rax],al
    4e05:	add    BYTE PTR [rax],al
	...

0000000000004e08 <botlish_entry_45: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    4e08:	push   rbp
    4e09:	mov    rbp,rsp
    4e0c:	mov    rsi,QWORD PTR [rdx]
    4e0f:	mov    r10,QWORD PTR [rdx+0x8]
    4e13:	mov    rcx,QWORD PTR [rdx+0x10]
    4e17:	mov    r8,QWORD PTR [rdx+0x18]
    4e1b:	mov    r9,QWORD PTR [rdx+0x20]
    4e1f:	mov    rdx,r10
    4e22:	call   4e27 <botlish_entry_45+0x1f>
			4e23: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    4e27:	mov    rsp,rbp
    4e2a:	pop    rbp
    4e2b:	ret

0000000000004e2c <botlish_fn_46: ht_rehash<mutarray, int>>:
    4e2c:	push   rbp
    4e2d:	mov    rbp,rsp
    4e30:	sub    rsp,0x80
    4e37:	mov    QWORD PTR [rsp+0x50],rbx
    4e3c:	mov    QWORD PTR [rsp+0x58],r12
    4e41:	mov    QWORD PTR [rsp+0x60],r13
    4e46:	mov    QWORD PTR [rsp+0x68],r14
    4e4b:	mov    QWORD PTR [rsp+0x70],r15
    4e50:	mov    rbx,QWORD PTR [rdi]
    4e53:	mov    rax,QWORD PTR [rdi+0x8]
    4e57:	lea    rcx,[rbx+0x38]
    4e5b:	cmp    rcx,rax
    4e5e:	ja     5220 <botlish_fn_46+0x3f4>
    4e64:	lea    rax,[rbx+0x38]
    4e68:	mov    QWORD PTR [rdi],rax
    4e6b:	mov    r12,rdi
    4e6e:	mov    QWORD PTR [rbx],0x0
    4e75:	mov    QWORD PTR [rbx+0x8],0x0
    4e7d:	mov    QWORD PTR [rbx+0x10],0x0
    4e85:	mov    QWORD PTR [rbx+0x18],0x0
    4e8d:	mov    QWORD PTR [rbx+0x20],0x0
    4e95:	mov    QWORD PTR [rbx+0x28],0x0
    4e9d:	mov    QWORD PTR [rbx+0x30],0x0
    4ea5:	mov    QWORD PTR [rbx],rsi
    4ea8:	mov    r13,rsi
    4eab:	mov    QWORD PTR [rbx+0x8],rdx
    4eaf:	mov    r14,rdx
    4eb2:	mov    rsi,r13
    4eb5:	mov    rdi,r12
    4eb8:	call   4ebd <botlish_fn_46+0x91>
			4eb9: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    4ebd:	test   rax,rax
    4ec0:	jne    4ece <botlish_fn_46+0xa2>
    4ec6:	mov    rdi,r12
    4ec9:	jmp    51c2 <botlish_fn_46+0x396>
    4ece:	mov    QWORD PTR [rbx+0x10],rax
    4ed2:	mov    r15,rax
    4ed5:	mov    rsi,r13
    4ed8:	mov    rdi,r12
    4edb:	call   4ee0 <botlish_fn_46+0xb4>
			4edc: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    4ee0:	test   rax,rax
    4ee3:	jne    4ef1 <botlish_fn_46+0xc5>
    4ee9:	mov    rdi,r12
    4eec:	jmp    51c2 <botlish_fn_46+0x396>
    4ef1:	mov    QWORD PTR [rbx+0x18],rax
    4ef5:	mov    QWORD PTR [rsp+0x40],rax
    4efa:	mov    rsi,r13
    4efd:	mov    rdi,r12
    4f00:	call   4f05 <botlish_fn_46+0xd9>
			4f01: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    4f05:	test   rax,rax
    4f08:	jne    4f16 <botlish_fn_46+0xea>
    4f0e:	mov    rdi,r12
    4f11:	jmp    51c2 <botlish_fn_46+0x396>
    4f16:	mov    QWORD PTR [rbx+0x20],rax
    4f1a:	lea    rdx,[rsp]
    4f1e:	mov    rcx,r15
    4f21:	mov    QWORD PTR [rsp],rcx
    4f25:	mov    rcx,QWORD PTR [rsp+0x40]
    4f2a:	mov    QWORD PTR [rsp+0x8],rcx
    4f2f:	mov    QWORD PTR [rsp+0x10],rax
    4f34:	mov    esi,0x3
    4f39:	mov    rax,QWORD PTR [rip+0x0]        # 4f40 <botlish_fn_46+0x114>
			4f3c: R_X86_64_GOTPCREL	rt_list_new-0x4
    4f40:	mov    rdi,r12
    4f43:	call   rax
    4f45:	test   rax,rax
    4f48:	jne    4f56 <botlish_fn_46+0x12a>
    4f4e:	mov    rdi,r12
    4f51:	jmp    51c2 <botlish_fn_46+0x396>
    4f56:	mov    QWORD PTR [rbx+0x10],rax
    4f5a:	mov    r15,rax
    4f5d:	mov    rsi,r13
    4f60:	mov    rdi,r12
    4f63:	call   4f68 <botlish_fn_46+0x13c>
			4f64: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    4f68:	test   rax,rax
    4f6b:	jne    4f79 <botlish_fn_46+0x14d>
    4f71:	mov    rdi,r12
    4f74:	jmp    51c2 <botlish_fn_46+0x396>
    4f79:	mov    QWORD PTR [rbx+0x18],rax
    4f7d:	mov    QWORD PTR [rsp+0x40],rax
    4f82:	mov    rax,QWORD PTR [rip+0x0]        # 4f89 <botlish_fn_46+0x15d>
			4f85: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    4f89:	mov    rsi,r14
    4f8c:	mov    rdi,r12
    4f8f:	call   rax
    4f91:	test   rax,rax
    4f94:	jne    4fa2 <botlish_fn_46+0x176>
    4f9a:	mov    rdi,r12
    4f9d:	jmp    51c2 <botlish_fn_46+0x396>
    4fa2:	mov    QWORD PTR [rbx+0x20],rax
    4fa6:	mov    QWORD PTR [rsp+0x38],rax
    4fab:	mov    edx,0x1
    4fb0:	mov    QWORD PTR [rbx+0x28],0x1
    4fb8:	mov    rcx,r14
    4fbb:	mov    rsi,QWORD PTR [rsp+0x38]
    4fc0:	mov    rdi,r12
    4fc3:	call   4fc8 <botlish_fn_46+0x19c>
			4fc4: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_fill_empty<mutarray, int, int>
    4fc8:	test   rax,rax
    4fcb:	jne    4fd9 <botlish_fn_46+0x1ad>
    4fd1:	mov    rdi,r12
    4fd4:	jmp    51c2 <botlish_fn_46+0x396>
    4fd9:	mov    rax,QWORD PTR [rip+0x0]        # 4fe0 <botlish_fn_46+0x1b4>
			4fdc: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    4fe0:	mov    rsi,r14
    4fe3:	mov    rdi,r12
    4fe6:	call   rax
    4fe8:	test   rax,rax
    4feb:	jne    4ff9 <botlish_fn_46+0x1cd>
    4ff1:	mov    rdi,r12
    4ff4:	jmp    51c2 <botlish_fn_46+0x396>
    4ff9:	mov    QWORD PTR [rbx+0x28],rax
    4ffd:	mov    QWORD PTR [rsp+0x30],rax
    5002:	mov    rax,QWORD PTR [rip+0x0]        # 5009 <botlish_fn_46+0x1dd>
			5005: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    5009:	mov    rsi,r14
    500c:	mov    rdi,r12
    500f:	call   rax
    5011:	test   rax,rax
    5014:	jne    5022 <botlish_fn_46+0x1f6>
    501a:	mov    rdi,r12
    501d:	jmp    51c2 <botlish_fn_46+0x396>
    5022:	mov    QWORD PTR [rbx+0x30],rax
    5026:	lea    rdx,[rsp+0x18]
    502b:	mov    rcx,QWORD PTR [rsp+0x38]
    5030:	mov    QWORD PTR [rsp+0x18],rcx
    5035:	mov    rcx,QWORD PTR [rsp+0x30]
    503a:	mov    QWORD PTR [rsp+0x20],rcx
    503f:	mov    QWORD PTR [rsp+0x28],rax
    5044:	mov    esi,0x3
    5049:	mov    rax,QWORD PTR [rip+0x0]        # 5050 <botlish_fn_46+0x224>
			504c: R_X86_64_GOTPCREL	rt_list_new-0x4
    5050:	mov    rdi,r12
    5053:	call   rax
    5055:	mov    rcx,rax
    5058:	mov    QWORD PTR [rsp+0x30],rax
    505d:	test   rax,rcx
    5060:	jne    506e <botlish_fn_46+0x242>
    5066:	mov    rdi,r12
    5069:	jmp    51c2 <botlish_fn_46+0x396>
    506e:	mov    rax,QWORD PTR [rsp+0x30]
    5073:	mov    QWORD PTR [rbx+0x20],rax
    5077:	mov    edx,0x1
    507c:	mov    QWORD PTR [rbx+0x28],0x1
    5084:	mov    rcx,QWORD PTR [rsp+0x40]
    5089:	mov    rsi,r15
    508c:	mov    r9,r14
    508f:	mov    rdi,r12
    5092:	mov    r8,QWORD PTR [rsp+0x30]
    5097:	call   509c <botlish_fn_46+0x270>
			5098: R_X86_64_PLT32	botlish_fn_45-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    509c:	test   rax,rax
    509f:	jne    50ad <botlish_fn_46+0x281>
    50a5:	mov    rdi,r12
    50a8:	jmp    51c2 <botlish_fn_46+0x396>
    50ad:	mov    edx,0x1
    50b2:	mov    rax,QWORD PTR [rip+0x0]        # 50b9 <botlish_fn_46+0x28d>
			50b5: R_X86_64_GOTPCREL	rt_list_get-0x4
    50b9:	mov    rsi,QWORD PTR [rsp+0x30]
    50be:	mov    rdi,r12
    50c1:	call   rax
    50c3:	test   rax,rax
    50c6:	mov    rcx,rax
    50c9:	jne    50d7 <botlish_fn_46+0x2ab>
    50cf:	mov    rdi,r12
    50d2:	jmp    51c2 <botlish_fn_46+0x396>
    50d7:	mov    edx,0x1
    50dc:	mov    rax,QWORD PTR [rip+0x0]        # 50e3 <botlish_fn_46+0x2b7>
			50df: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    50e3:	mov    rsi,r13
    50e6:	mov    rdi,r12
    50e9:	call   rax
    50eb:	test   rax,rax
    50ee:	jne    50fc <botlish_fn_46+0x2d0>
    50f4:	mov    rdi,r12
    50f7:	jmp    51c2 <botlish_fn_46+0x396>
    50fc:	mov    edx,0x3
    5101:	mov    rcx,QWORD PTR [rip+0x0]        # 5108 <botlish_fn_46+0x2dc>
			5104: R_X86_64_GOTPCREL	rt_list_get-0x4
    5108:	mov    rsi,QWORD PTR [rsp+0x30]
    510d:	mov    rdi,r12
    5110:	call   rcx
    5112:	test   rax,rax
    5115:	mov    rcx,rax
    5118:	jne    5126 <botlish_fn_46+0x2fa>
    511e:	mov    rdi,r12
    5121:	jmp    51c2 <botlish_fn_46+0x396>
    5126:	mov    edx,0x3
    512b:	mov    r8,QWORD PTR [rip+0x0]        # 5132 <botlish_fn_46+0x306>
			512e: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    5132:	mov    rsi,r13
    5135:	mov    rdi,r12
    5138:	call   r8
    513b:	test   rax,rax
    513e:	jne    514c <botlish_fn_46+0x320>
    5144:	mov    rdi,r12
    5147:	jmp    51c2 <botlish_fn_46+0x396>
    514c:	mov    edx,0x5
    5151:	mov    r8,QWORD PTR [rip+0x0]        # 5158 <botlish_fn_46+0x32c>
			5154: R_X86_64_GOTPCREL	rt_list_get-0x4
    5158:	mov    rsi,QWORD PTR [rsp+0x30]
    515d:	mov    rdi,r12
    5160:	call   r8
    5163:	test   rax,rax
    5166:	mov    rcx,rax
    5169:	jne    5177 <botlish_fn_46+0x34b>
    516f:	mov    rdi,r12
    5172:	jmp    51c2 <botlish_fn_46+0x396>
    5177:	mov    edx,0x5
    517c:	mov    r10,QWORD PTR [rip+0x0]        # 5183 <botlish_fn_46+0x357>
			517f: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    5183:	mov    rsi,r13
    5186:	mov    rdi,r12
    5189:	call   r10
    518c:	test   rax,rax
    518f:	jne    519d <botlish_fn_46+0x371>
    5195:	mov    rdi,r12
    5198:	jmp    51c2 <botlish_fn_46+0x396>
    519d:	mov    edx,0x9
    51a2:	mov    ecx,0x1
    51a7:	mov    rax,QWORD PTR [rip+0x0]        # 51ae <botlish_fn_46+0x382>
			51aa: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    51ae:	mov    rsi,r13
    51b1:	mov    rdi,r12
    51b4:	call   rax
    51b6:	test   rax,rax
    51b9:	jne    51f0 <botlish_fn_46+0x3c4>
    51bf:	mov    rdi,r12
    51c2:	mov    rdi,r12
    51c5:	mov    QWORD PTR [rdi],rbx
    51c8:	xor    rax,rax
    51cb:	mov    rbx,QWORD PTR [rsp+0x50]
    51d0:	mov    r12,QWORD PTR [rsp+0x58]
    51d5:	mov    r13,QWORD PTR [rsp+0x60]
    51da:	mov    r14,QWORD PTR [rsp+0x68]
    51df:	mov    r15,QWORD PTR [rsp+0x70]
    51e4:	add    rsp,0x80
    51eb:	mov    rsp,rbp
    51ee:	pop    rbp
    51ef:	ret
    51f0:	mov    rdi,r12
    51f3:	mov    QWORD PTR [rdi],rbx
    51f6:	mov    eax,0xa
    51fb:	mov    rbx,QWORD PTR [rsp+0x50]
    5200:	mov    r12,QWORD PTR [rsp+0x58]
    5205:	mov    r13,QWORD PTR [rsp+0x60]
    520a:	mov    r14,QWORD PTR [rsp+0x68]
    520f:	mov    r15,QWORD PTR [rsp+0x70]
    5214:	add    rsp,0x80
    521b:	mov    rsp,rbp
    521e:	pop    rbp
    521f:	ret
    5220:	mov    r12,rdi
    5223:	mov    rax,QWORD PTR [rip+0x0]        # 522a <botlish_fn_46+0x3fe>
			5226: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    522a:	call   rax
    522c:	xor    rax,rax
    522f:	mov    rbx,QWORD PTR [rsp+0x50]
    5234:	mov    r12,QWORD PTR [rsp+0x58]
    5239:	mov    r13,QWORD PTR [rsp+0x60]
    523e:	mov    r14,QWORD PTR [rsp+0x68]
    5243:	mov    r15,QWORD PTR [rsp+0x70]
    5248:	add    rsp,0x80
    524f:	mov    rsp,rbp
    5252:	pop    rbp
    5253:	ret

0000000000005254 <botlish_entry_46: ht_rehash<mutarray, int>>:
    5254:	push   rbp
    5255:	mov    rbp,rsp
    5258:	mov    rsi,QWORD PTR [rdx]
    525b:	mov    rdx,QWORD PTR [rdx+0x8]
    525f:	call   5264 <botlish_entry_46+0x10>
			5260: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    5264:	mov    rsp,rbp
    5267:	pop    rbp
    5268:	ret
    5269:	add    BYTE PTR [rax],al
    526b:	add    BYTE PTR [rax],al
    526d:	add    BYTE PTR [rax],al
	...

0000000000005270 <botlish_fn_47: ht_should_grow<mutarray>>:
    5270:	push   rbp
    5271:	mov    rbp,rsp
    5274:	sub    rsp,0x20
    5278:	mov    QWORD PTR [rsp],rbx
    527c:	mov    QWORD PTR [rsp+0x8],r12
    5281:	mov    QWORD PTR [rsp+0x10],r13
    5286:	mov    QWORD PTR [rsp+0x18],r15
    528b:	mov    r15,QWORD PTR [rdi]
    528e:	mov    rax,QWORD PTR [rdi+0x8]
    5292:	lea    rcx,[r15+0x18]
    5296:	cmp    rcx,rax
    5299:	ja     55c6 <botlish_fn_47+0x356>
    529f:	lea    rax,[r15+0x18]
    52a3:	mov    QWORD PTR [rdi],rax
    52a6:	mov    rbx,rdi
    52a9:	mov    QWORD PTR [r15],0x0
    52b0:	mov    QWORD PTR [r15+0x8],0x0
    52b8:	mov    QWORD PTR [r15+0x10],0x0
    52c0:	mov    QWORD PTR [r15],rsi
    52c3:	mov    r12,rsi
    52c6:	mov    rsi,r12
    52c9:	mov    rdi,rbx
    52cc:	call   52d1 <botlish_fn_47+0x61>
			52cd: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    52d1:	mov    rcx,rax
    52d4:	mov    r13,rax
    52d7:	test   rax,rcx
    52da:	jne    52e8 <botlish_fn_47+0x78>
    52e0:	mov    rdi,rbx
    52e3:	jmp    54d8 <botlish_fn_47+0x268>
    52e8:	mov    rax,r13
    52eb:	mov    QWORD PTR [r15+0x8],rax
    52ef:	mov    rsi,r12
    52f2:	mov    rdi,rbx
    52f5:	call   52fa <botlish_fn_47+0x8a>
			52f6: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    52fa:	mov    rcx,rax
    52fd:	test   rcx,rcx
    5300:	jne    530e <botlish_fn_47+0x9e>
    5306:	mov    rdi,rbx
    5309:	jmp    54d8 <botlish_fn_47+0x268>
    530e:	mov    QWORD PTR [r15+0x10],rcx
    5312:	mov    edx,0x1
    5317:	mov    rax,r13
    531a:	test   rax,0x1
    5320:	jne    5343 <botlish_fn_47+0xd3>
    5326:	xor    edx,edx
    5328:	mov    rax,r13
    532b:	test   rax,0x7
    5331:	jne    5343 <botlish_fn_47+0xd3>
    5337:	mov    rax,r13
    533a:	movzx  rax,BYTE PTR [rax]
    533e:	cmp    al,0x1
    5340:	sete   dl
    5343:	test   dl,dl
    5345:	jne    536d <botlish_fn_47+0xfd>
    534b:	mov    rdi,rbx
    534e:	mov    rax,QWORD PTR [rdi+0x10]
    5352:	mov    rcx,QWORD PTR [rax+0x30]
    5356:	xor    rdx,rdx
    5359:	mov    rax,QWORD PTR [rip+0x0]        # 5360 <botlish_fn_47+0xf0>
			535c: R_X86_64_GOTPCREL	rt_type_error-0x4
    5360:	mov    rsi,r13
    5363:	call   rax
    5365:	mov    rdi,rbx
    5368:	jmp    54d8 <botlish_fn_47+0x268>
    536d:	mov    eax,0x1
    5372:	test   rcx,0x1
    5379:	je     5387 <botlish_fn_47+0x117>
    537f:	mov    r8,rcx
    5382:	jmp    53aa <botlish_fn_47+0x13a>
    5387:	xor    eax,eax
    5389:	test   rcx,0x7
    5390:	je     539e <botlish_fn_47+0x12e>
    5396:	mov    r8,rcx
    5399:	jmp    53aa <botlish_fn_47+0x13a>
    539e:	movzx  rax,BYTE PTR [rcx]
    53a2:	mov    r8,rcx
    53a5:	cmp    al,0x1
    53a7:	sete   al
    53aa:	test   al,al
    53ac:	jne    53d4 <botlish_fn_47+0x164>
    53b2:	mov    rdi,rbx
    53b5:	mov    rax,QWORD PTR [rdi+0x10]
    53b9:	mov    rcx,QWORD PTR [rax+0x30]
    53bd:	xor    rdx,rdx
    53c0:	mov    rax,QWORD PTR [rip+0x0]        # 53c7 <botlish_fn_47+0x157>
			53c3: R_X86_64_GOTPCREL	rt_type_error-0x4
    53c7:	mov    rsi,r8
    53ca:	call   rax
    53cc:	mov    rdi,rbx
    53cf:	jmp    54d8 <botlish_fn_47+0x268>
    53d4:	mov    rcx,r8
    53d7:	mov    rsi,r13
    53da:	mov    rax,rsi
    53dd:	and    rax,rcx
    53e0:	test   rax,0x1
    53e6:	je     5404 <botlish_fn_47+0x194>
    53ec:	mov    rcx,r8
    53ef:	lea    rax,[rcx-0x1]
    53f3:	mov    rsi,r13
    53f6:	add    rsi,rax
    53f9:	seto   al
    53fc:	test   al,al
    53fe:	je     5419 <botlish_fn_47+0x1a9>
    5404:	mov    rax,QWORD PTR [rip+0x0]        # 540b <botlish_fn_47+0x19b>
			5407: R_X86_64_GOTPCREL	rt_int_add-0x4
    540b:	mov    rdx,r8
    540e:	mov    rsi,r13
    5411:	mov    rdi,rbx
    5414:	call   rax
    5416:	mov    rsi,rax
    5419:	mov    QWORD PTR [r15+0x8],rsi
    541d:	mov    QWORD PTR [r15+0x10],0x3
    5425:	test   rsi,0x1
    542c:	je     544e <botlish_fn_47+0x1de>
    5432:	mov    rax,rsi
    5435:	add    rax,0x2
    5439:	seto   dil
    543d:	test   dil,dil
    5440:	jne    544e <botlish_fn_47+0x1de>
    5446:	mov    rsi,rax
    5449:	jmp    5463 <botlish_fn_47+0x1f3>
    544e:	mov    edx,0x3
    5453:	mov    r8,QWORD PTR [rip+0x0]        # 545a <botlish_fn_47+0x1ea>
			5456: R_X86_64_GOTPCREL	rt_int_add-0x4
    545a:	mov    rdi,rbx
    545d:	call   r8
    5460:	mov    rsi,rax
    5463:	mov    QWORD PTR [r15+0x8],rsi
    5467:	mov    edx,0x7
    546c:	mov    rdi,rdx
    546f:	mov    QWORD PTR [r15+0x10],0x7
    5477:	test   rsi,0x1
    547e:	je     54a8 <botlish_fn_47+0x238>
    5484:	mov    rax,rsi
    5487:	sar    rax,1
    548a:	imul   QWORD PTR [rip+0x167]        # 55f8 <botlish_fn_47+0x388>
    5491:	seto   cl
    5494:	or     rax,0x1
    5498:	test   cl,cl
    549a:	jne    54a8 <botlish_fn_47+0x238>
    54a0:	mov    rsi,rax
    54a3:	jmp    54ba <botlish_fn_47+0x24a>
    54a8:	mov    rax,QWORD PTR [rip+0x0]        # 54af <botlish_fn_47+0x23f>
			54ab: R_X86_64_GOTPCREL	rt_int_mul-0x4
    54af:	mov    rdx,rdi
    54b2:	mov    rdi,rbx
    54b5:	call   rax
    54b7:	mov    rsi,rax
    54ba:	mov    QWORD PTR [r15+0x8],rsi
    54be:	mov    r13,rsi
    54c1:	mov    rsi,r12
    54c4:	mov    rdi,rbx
    54c7:	call   54cc <botlish_fn_47+0x25c>
			54c8: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    54cc:	test   rax,rax
    54cf:	jne    54fd <botlish_fn_47+0x28d>
    54d5:	mov    rdi,rbx
    54d8:	mov    rdi,rbx
    54db:	mov    QWORD PTR [rdi],r15
    54de:	xor    rax,rax
    54e1:	mov    rbx,QWORD PTR [rsp]
    54e5:	mov    r12,QWORD PTR [rsp+0x8]
    54ea:	mov    r13,QWORD PTR [rsp+0x10]
    54ef:	mov    r15,QWORD PTR [rsp+0x18]
    54f4:	add    rsp,0x20
    54f8:	mov    rsp,rbp
    54fb:	pop    rbp
    54fc:	ret
    54fd:	mov    QWORD PTR [r15],rax
    5500:	mov    QWORD PTR [r15+0x10],0x5
    5508:	test   rax,0x1
    550e:	mov    rsi,rax
    5511:	je     5541 <botlish_fn_47+0x2d1>
    5517:	mov    rcx,rsi
    551a:	mov    rax,rcx
    551d:	sar    rax,1
    5520:	imul   QWORD PTR [rip+0xd9]        # 5600 <botlish_fn_47+0x390>
    5527:	seto   cl
    552a:	or     rax,0x1
    552e:	test   cl,cl
    5530:	jne    5541 <botlish_fn_47+0x2d1>
    5536:	mov    rdx,rax
    5539:	mov    rsi,r13
    553c:	jmp    5558 <botlish_fn_47+0x2e8>
    5541:	mov    edx,0x5
    5546:	mov    rax,QWORD PTR [rip+0x0]        # 554d <botlish_fn_47+0x2dd>
			5549: R_X86_64_GOTPCREL	rt_int_mul-0x4
    554d:	mov    rdi,rbx
    5550:	call   rax
    5552:	mov    rdx,rax
    5555:	mov    rsi,r13
    5558:	mov    rax,rsi
    555b:	and    rax,rdx
    555e:	test   rax,0x1
    5564:	jne    5591 <botlish_fn_47+0x321>
    556a:	mov    rax,QWORD PTR [rip+0x0]        # 5571 <botlish_fn_47+0x301>
			556d: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    5571:	mov    rdi,rbx
    5574:	call   rax
    5576:	mov    ecx,0x2
    557b:	test   rax,rax
    557e:	mov    rax,rcx
    5581:	cmovg  rax,QWORD PTR [rip+0x6f]        # 55f8 <botlish_fn_47+0x388>
    5589:	mov    rdi,rbx
    558c:	jmp    55a4 <botlish_fn_47+0x334>
    5591:	mov    eax,0x2
    5596:	cmp    rsi,rdx
    5599:	cmovg  rax,QWORD PTR [rip+0x57]        # 55f8 <botlish_fn_47+0x388>
    55a1:	mov    rdi,rbx
    55a4:	mov    rdi,rbx
    55a7:	mov    QWORD PTR [rdi],r15
    55aa:	mov    rbx,QWORD PTR [rsp]
    55ae:	mov    r12,QWORD PTR [rsp+0x8]
    55b3:	mov    r13,QWORD PTR [rsp+0x10]
    55b8:	mov    r15,QWORD PTR [rsp+0x18]
    55bd:	add    rsp,0x20
    55c1:	mov    rsp,rbp
    55c4:	pop    rbp
    55c5:	ret
    55c6:	mov    rbx,rdi
    55c9:	mov    rax,QWORD PTR [rip+0x0]        # 55d0 <botlish_fn_47+0x360>
			55cc: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    55d0:	call   rax
    55d2:	xor    rax,rax
    55d5:	mov    rbx,QWORD PTR [rsp]
    55d9:	mov    r12,QWORD PTR [rsp+0x8]
    55de:	mov    r13,QWORD PTR [rsp+0x10]
    55e3:	mov    r15,QWORD PTR [rsp+0x18]
    55e8:	add    rsp,0x20
    55ec:	mov    rsp,rbp
    55ef:	pop    rbp
    55f0:	ret
    55f1:	add    BYTE PTR [rax],al
    55f3:	add    BYTE PTR [rax],al
    55f5:	add    BYTE PTR [rax],al
    55f7:	add    BYTE PTR [rsi],al
    55f9:	add    BYTE PTR [rax],al
    55fb:	add    BYTE PTR [rax],al
    55fd:	add    BYTE PTR [rax],al
    55ff:	add    BYTE PTR [rax+rax*1],al
    5602:	add    BYTE PTR [rax],al
    5604:	add    BYTE PTR [rax],al
	...

0000000000005608 <botlish_entry_47: ht_should_grow<mutarray>>:
    5608:	push   rbp
    5609:	mov    rbp,rsp
    560c:	mov    rsi,QWORD PTR [rdx]
    560f:	call   5614 <botlish_entry_47+0xc>
			5610: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    5614:	mov    rsp,rbp
    5617:	pop    rbp
    5618:	ret
    5619:	add    BYTE PTR [rax],al
    561b:	add    BYTE PTR [rax],al
    561d:	add    BYTE PTR [rax],al
	...

0000000000005620 <botlish_fn_48: ht_grow_or_clean<mutarray>>:
    5620:	push   rbp
    5621:	mov    rbp,rsp
    5624:	sub    rsp,0x20
    5628:	mov    QWORD PTR [rsp],rbx
    562c:	mov    QWORD PTR [rsp+0x8],r12
    5631:	mov    QWORD PTR [rsp+0x10],r13
    5636:	mov    QWORD PTR [rsp+0x18],r14
    563b:	mov    rbx,QWORD PTR [rdi]
    563e:	mov    rax,QWORD PTR [rdi+0x8]
    5642:	lea    rcx,[rbx+0x18]
    5646:	cmp    rcx,rax
    5649:	ja     5900 <botlish_fn_48+0x2e0>
    564f:	lea    rax,[rbx+0x18]
    5653:	mov    QWORD PTR [rdi],rax
    5656:	mov    r12,rdi
    5659:	mov    QWORD PTR [rbx],0x0
    5660:	mov    QWORD PTR [rbx+0x8],0x0
    5668:	mov    QWORD PTR [rbx+0x10],0x0
    5670:	mov    QWORD PTR [rbx],rsi
    5673:	mov    r13,rsi
    5676:	mov    rsi,r13
    5679:	mov    rdi,r12
    567c:	call   5681 <botlish_fn_48+0x61>
			567d: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    5681:	test   rax,rax
    5684:	jne    5692 <botlish_fn_48+0x72>
    568a:	mov    rdi,r12
    568d:	jmp    58b6 <botlish_fn_48+0x296>
    5692:	mov    QWORD PTR [rbx+0x8],rax
    5696:	mov    r14,rax
    5699:	mov    rsi,r13
    569c:	mov    rdi,r12
    569f:	call   56a4 <botlish_fn_48+0x84>
			56a0: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    56a4:	mov    rcx,rax
    56a7:	test   rcx,rcx
    56aa:	jne    56b8 <botlish_fn_48+0x98>
    56b0:	mov    rdi,r12
    56b3:	jmp    58b6 <botlish_fn_48+0x296>
    56b8:	mov    edx,0x1
    56bd:	mov    rax,r14
    56c0:	test   rax,0x1
    56c6:	je     56d4 <botlish_fn_48+0xb4>
    56cc:	mov    r14,rax
    56cf:	jmp    56f8 <botlish_fn_48+0xd8>
    56d4:	xor    edx,edx
    56d6:	test   rax,0x7
    56dc:	je     56ea <botlish_fn_48+0xca>
    56e2:	mov    r14,rax
    56e5:	jmp    56f8 <botlish_fn_48+0xd8>
    56ea:	movzx  rdx,BYTE PTR [rax]
    56ee:	mov    r14,rax
    56f1:	rex cmp dl,0x1
    56f5:	sete   dl
    56f8:	test   dl,dl
    56fa:	jne    5722 <botlish_fn_48+0x102>
    5700:	mov    rdi,r12
    5703:	mov    rax,QWORD PTR [rdi+0x10]
    5707:	mov    rcx,QWORD PTR [rax+0x38]
    570b:	xor    rdx,rdx
    570e:	mov    rax,QWORD PTR [rip+0x0]        # 5715 <botlish_fn_48+0xf5>
			5711: R_X86_64_GOTPCREL	rt_type_error-0x4
    5715:	mov    rsi,r14
    5718:	call   rax
    571a:	mov    rdi,r12
    571d:	jmp    58b6 <botlish_fn_48+0x296>
    5722:	mov    rsi,r14
    5725:	mov    eax,0x1
    572a:	test   rcx,0x1
    5731:	je     573f <botlish_fn_48+0x11f>
    5737:	mov    r8,rcx
    573a:	jmp    5762 <botlish_fn_48+0x142>
    573f:	xor    eax,eax
    5741:	test   rcx,0x7
    5748:	je     5756 <botlish_fn_48+0x136>
    574e:	mov    r8,rcx
    5751:	jmp    5762 <botlish_fn_48+0x142>
    5756:	movzx  rax,BYTE PTR [rcx]
    575a:	mov    r8,rcx
    575d:	cmp    al,0x1
    575f:	sete   al
    5762:	test   al,al
    5764:	jne    578c <botlish_fn_48+0x16c>
    576a:	mov    rdi,r12
    576d:	mov    rax,QWORD PTR [rdi+0x10]
    5771:	mov    rcx,QWORD PTR [rax+0x38]
    5775:	xor    rdx,rdx
    5778:	mov    rax,QWORD PTR [rip+0x0]        # 577f <botlish_fn_48+0x15f>
			577b: R_X86_64_GOTPCREL	rt_type_error-0x4
    577f:	mov    rsi,r8
    5782:	call   rax
    5784:	mov    rdi,r12
    5787:	jmp    58b6 <botlish_fn_48+0x296>
    578c:	mov    rcx,r8
    578f:	mov    rax,rsi
    5792:	and    rax,rcx
    5795:	test   rax,0x1
    579b:	jne    57c5 <botlish_fn_48+0x1a5>
    57a1:	mov    rax,QWORD PTR [rip+0x0]        # 57a8 <botlish_fn_48+0x188>
			57a4: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    57a8:	mov    rdx,r8
    57ab:	mov    rdi,r12
    57ae:	call   rax
    57b0:	mov    ecx,0x2
    57b5:	test   rax,rax
    57b8:	cmovg  rcx,QWORD PTR [rip+0x170]        # 5930 <botlish_fn_48+0x310>
    57c0:	jmp    57d8 <botlish_fn_48+0x1b8>
    57c5:	mov    ecx,0x2
    57ca:	mov    rax,r8
    57cd:	cmp    rsi,rax
    57d0:	cmovg  rcx,QWORD PTR [rip+0x158]        # 5930 <botlish_fn_48+0x310>
    57d8:	cmp    rcx,0x6
    57dc:	je     587c <botlish_fn_48+0x25c>
    57e2:	mov    rsi,r13
    57e5:	mov    rdi,r12
    57e8:	call   57ed <botlish_fn_48+0x1cd>
			57e9: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    57ed:	test   rax,rax
    57f0:	jne    57fe <botlish_fn_48+0x1de>
    57f6:	mov    rdi,r12
    57f9:	jmp    58b6 <botlish_fn_48+0x296>
    57fe:	mov    QWORD PTR [rbx+0x8],rax
    5802:	mov    QWORD PTR [rbx+0x10],0x5
    580a:	test   rax,0x1
    5810:	mov    rsi,rax
    5813:	je     5840 <botlish_fn_48+0x220>
    5819:	mov    rcx,rsi
    581c:	mov    rax,rcx
    581f:	sar    rax,1
    5822:	imul   QWORD PTR [rip+0x10f]        # 5938 <botlish_fn_48+0x318>
    5829:	seto   cl
    582c:	or     rax,0x1
    5830:	test   cl,cl
    5832:	jne    5840 <botlish_fn_48+0x220>
    5838:	mov    rdx,rax
    583b:	jmp    5854 <botlish_fn_48+0x234>
    5840:	mov    edx,0x5
    5845:	mov    rax,QWORD PTR [rip+0x0]        # 584c <botlish_fn_48+0x22c>
			5848: R_X86_64_GOTPCREL	rt_int_mul-0x4
    584c:	mov    rdi,r12
    584f:	call   rax
    5851:	mov    rdx,rax
    5854:	mov    QWORD PTR [rbx+0x8],rdx
    5858:	mov    rsi,r13
    585b:	mov    rdi,r12
    585e:	call   5863 <botlish_fn_48+0x243>
			585f: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    5863:	test   rax,rax
    5866:	jne    5874 <botlish_fn_48+0x254>
    586c:	mov    rdi,r12
    586f:	jmp    58b6 <botlish_fn_48+0x296>
    5874:	mov    rdi,r12
    5877:	jmp    58de <botlish_fn_48+0x2be>
    587c:	mov    rsi,r13
    587f:	mov    rdi,r12
    5882:	call   5887 <botlish_fn_48+0x267>
			5883: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_capacity<mutarray>
    5887:	test   rax,rax
    588a:	jne    5898 <botlish_fn_48+0x278>
    5890:	mov    rdi,r12
    5893:	jmp    58b6 <botlish_fn_48+0x296>
    5898:	mov    QWORD PTR [rbx+0x8],rax
    589c:	mov    rdx,rax
    589f:	mov    rsi,r13
    58a2:	mov    rdi,r12
    58a5:	call   58aa <botlish_fn_48+0x28a>
			58a6: R_X86_64_PLT32	botlish_fn_46-0x4 ; ht_rehash<mutarray, int>
    58aa:	test   rax,rax
    58ad:	jne    58db <botlish_fn_48+0x2bb>
    58b3:	mov    rdi,r12
    58b6:	mov    rdi,r12
    58b9:	mov    QWORD PTR [rdi],rbx
    58bc:	xor    rax,rax
    58bf:	mov    rbx,QWORD PTR [rsp]
    58c3:	mov    r12,QWORD PTR [rsp+0x8]
    58c8:	mov    r13,QWORD PTR [rsp+0x10]
    58cd:	mov    r14,QWORD PTR [rsp+0x18]
    58d2:	add    rsp,0x20
    58d6:	mov    rsp,rbp
    58d9:	pop    rbp
    58da:	ret
    58db:	mov    rdi,r12
    58de:	mov    rdi,r12
    58e1:	mov    QWORD PTR [rdi],rbx
    58e4:	mov    rbx,QWORD PTR [rsp]
    58e8:	mov    r12,QWORD PTR [rsp+0x8]
    58ed:	mov    r13,QWORD PTR [rsp+0x10]
    58f2:	mov    r14,QWORD PTR [rsp+0x18]
    58f7:	add    rsp,0x20
    58fb:	mov    rsp,rbp
    58fe:	pop    rbp
    58ff:	ret
    5900:	mov    r12,rdi
    5903:	mov    r8,QWORD PTR [rip+0x0]        # 590a <botlish_fn_48+0x2ea>
			5906: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    590a:	call   r8
    590d:	xor    rax,rax
    5910:	mov    rbx,QWORD PTR [rsp]
    5914:	mov    r12,QWORD PTR [rsp+0x8]
    5919:	mov    r13,QWORD PTR [rsp+0x10]
    591e:	mov    r14,QWORD PTR [rsp+0x18]
    5923:	add    rsp,0x20
    5927:	mov    rsp,rbp
    592a:	pop    rbp
    592b:	ret
    592c:	add    BYTE PTR [rax],al
    592e:	add    BYTE PTR [rax],al
    5930:	(bad)
    5931:	add    BYTE PTR [rax],al
    5933:	add    BYTE PTR [rax],al
    5935:	add    BYTE PTR [rax],al
    5937:	add    BYTE PTR [rax+rax*1],al
    593a:	add    BYTE PTR [rax],al
    593c:	add    BYTE PTR [rax],al
	...

0000000000005940 <botlish_entry_48: ht_grow_or_clean<mutarray>>:
    5940:	push   rbp
    5941:	mov    rbp,rsp
    5944:	mov    rsi,QWORD PTR [rdx]
    5947:	call   594c <botlish_entry_48+0xc>
			5948: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    594c:	mov    rsp,rbp
    594f:	pop    rbp
    5950:	ret
    5951:	add    BYTE PTR [rax],al
    5953:	add    BYTE PTR [rax],al
    5955:	add    BYTE PTR [rax],al
	...

0000000000005958 <botlish_fn_49: ht_place<mutarray, int, any, any>>:
    5958:	push   rbp
    5959:	mov    rbp,rsp
    595c:	sub    rsp,0x50
    5960:	mov    QWORD PTR [rsp+0x20],rbx
    5965:	mov    QWORD PTR [rsp+0x28],r12
    596a:	mov    QWORD PTR [rsp+0x30],r13
    596f:	mov    QWORD PTR [rsp+0x38],r14
    5974:	mov    QWORD PTR [rsp+0x40],r15
    5979:	mov    r12,QWORD PTR [rdi]
    597c:	mov    rax,QWORD PTR [rdi+0x8]
    5980:	lea    r9,[r12+0x30]
    5985:	cmp    r9,rax
    5988:	ja     5ec8 <botlish_fn_49+0x570>
    598e:	lea    rax,[r12+0x30]
    5993:	mov    QWORD PTR [rdi],rax
    5996:	mov    r13,rdi
    5999:	mov    QWORD PTR [r12],0x0
    59a1:	mov    QWORD PTR [r12+0x8],0x0
    59aa:	mov    QWORD PTR [r12+0x10],0x0
    59b3:	mov    QWORD PTR [r12+0x18],0x0
    59bc:	mov    QWORD PTR [r12+0x20],0x0
    59c5:	mov    QWORD PTR [r12+0x28],0x0
    59ce:	mov    QWORD PTR [r12],rsi
    59d2:	mov    r14,rsi
    59d5:	mov    QWORD PTR [r12+0x8],rdx
    59da:	mov    QWORD PTR [rsp],rdx
    59de:	mov    QWORD PTR [r12+0x10],rcx
    59e3:	mov    QWORD PTR [rsp+0x8],rcx
    59e8:	mov    QWORD PTR [r12+0x18],r8
    59ed:	mov    r15,r8
    59f0:	mov    rsi,r14
    59f3:	mov    rdi,r13
    59f6:	call   59fb <botlish_fn_49+0xa3>
			59f7: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    59fb:	test   rax,rax
    59fe:	jne    5a0c <botlish_fn_49+0xb4>
    5a04:	mov    rdi,r13
    5a07:	jmp    5e6d <botlish_fn_49+0x515>
    5a0c:	mov    QWORD PTR [r12+0x20],rax
    5a11:	xor    ecx,ecx
    5a13:	test   rax,0x7
    5a19:	je     5a29 <botlish_fn_49+0xd1>
    5a1f:	mov    QWORD PTR [rsp+0x10],rax
    5a24:	jmp    5a39 <botlish_fn_49+0xe1>
    5a29:	movzx  rsi,BYTE PTR [rax]
    5a2d:	mov    QWORD PTR [rsp+0x10],rax
    5a32:	cmp    sil,0x8
    5a36:	sete   cl
    5a39:	test   cl,cl
    5a3b:	jne    5a68 <botlish_fn_49+0x110>
    5a41:	mov    rdi,r13
    5a44:	mov    r9,QWORD PTR [rdi+0x10]
    5a48:	mov    rcx,QWORD PTR [r9+0x20]
    5a4c:	mov    edx,0x8
    5a51:	mov    r9,QWORD PTR [rip+0x0]        # 5a58 <botlish_fn_49+0x100>
			5a54: R_X86_64_GOTPCREL	rt_type_error-0x4
    5a58:	mov    rsi,QWORD PTR [rsp+0x10]
    5a5d:	call   r9
    5a60:	mov    rdi,r13
    5a63:	jmp    5e6d <botlish_fn_49+0x515>
    5a68:	mov    r10,QWORD PTR [rip+0x0]        # 5a6f <botlish_fn_49+0x117>
			5a6b: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    5a6f:	mov    rdx,QWORD PTR [rsp]
    5a73:	mov    rsi,QWORD PTR [rsp+0x10]
    5a78:	mov    rdi,r13
    5a7b:	call   r10
    5a7e:	mov    rbx,rax
    5a81:	test   rbx,rbx
    5a84:	jne    5a92 <botlish_fn_49+0x13a>
    5a8a:	mov    rdi,r13
    5a8d:	jmp    5e6d <botlish_fn_49+0x515>
    5a92:	mov    QWORD PTR [r12+0x28],rbx
    5a97:	mov    rdi,r13
    5a9a:	call   5a9f <botlish_fn_49+0x147>
			5a9b: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    5a9f:	test   rax,rax
    5aa2:	mov    rcx,rax
    5aa5:	jne    5ab3 <botlish_fn_49+0x15b>
    5aab:	mov    rdi,r13
    5aae:	jmp    5e6d <botlish_fn_49+0x515>
    5ab3:	mov    rax,QWORD PTR [rip+0x0]        # 5aba <botlish_fn_49+0x162>
			5ab6: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    5aba:	mov    rsi,QWORD PTR [rsp+0x10]
    5abf:	mov    rdx,QWORD PTR [rsp]
    5ac3:	mov    rdi,r13
    5ac6:	call   rax
    5ac8:	test   rax,rax
    5acb:	jne    5ad9 <botlish_fn_49+0x181>
    5ad1:	mov    rdi,r13
    5ad4:	jmp    5e6d <botlish_fn_49+0x515>
    5ad9:	mov    rsi,r14
    5adc:	mov    rdi,r13
    5adf:	call   5ae4 <botlish_fn_49+0x18c>
			5ae0: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_keys<mutarray>
    5ae4:	test   rax,rax
    5ae7:	jne    5af5 <botlish_fn_49+0x19d>
    5aed:	mov    rdi,r13
    5af0:	jmp    5e6d <botlish_fn_49+0x515>
    5af5:	xor    esi,esi
    5af7:	test   rax,0x7
    5afd:	je     5b0b <botlish_fn_49+0x1b3>
    5b03:	mov    r8,rax
    5b06:	jmp    5b1a <botlish_fn_49+0x1c2>
    5b0b:	movzx  rcx,BYTE PTR [rax]
    5b0f:	mov    r8,rax
    5b12:	rex cmp cl,0x8
    5b16:	sete   sil
    5b1a:	test   sil,sil
    5b1d:	jne    5b47 <botlish_fn_49+0x1ef>
    5b23:	mov    rdi,r13
    5b26:	mov    rax,QWORD PTR [rdi+0x10]
    5b2a:	mov    rcx,QWORD PTR [rax+0x40]
    5b2e:	mov    edx,0x8
    5b33:	mov    rax,QWORD PTR [rip+0x0]        # 5b3a <botlish_fn_49+0x1e2>
			5b36: R_X86_64_GOTPCREL	rt_type_error-0x4
    5b3a:	mov    rsi,r8
    5b3d:	call   rax
    5b3f:	mov    rdi,r13
    5b42:	jmp    5e6d <botlish_fn_49+0x515>
    5b47:	mov    rsi,r8
    5b4a:	mov    rax,QWORD PTR [rip+0x0]        # 5b51 <botlish_fn_49+0x1f9>
			5b4d: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    5b51:	mov    rcx,QWORD PTR [rsp+0x8]
    5b56:	mov    rdx,QWORD PTR [rsp]
    5b5a:	mov    rdi,r13
    5b5d:	call   rax
    5b5f:	test   rax,rax
    5b62:	jne    5b70 <botlish_fn_49+0x218>
    5b68:	mov    rdi,r13
    5b6b:	jmp    5e6d <botlish_fn_49+0x515>
    5b70:	mov    rsi,r14
    5b73:	mov    rdi,r13
    5b76:	call   5b7b <botlish_fn_49+0x223>
			5b77: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    5b7b:	test   rax,rax
    5b7e:	jne    5b8c <botlish_fn_49+0x234>
    5b84:	mov    rdi,r13
    5b87:	jmp    5e6d <botlish_fn_49+0x515>
    5b8c:	xor    ecx,ecx
    5b8e:	test   rax,0x7
    5b94:	je     5ba2 <botlish_fn_49+0x24a>
    5b9a:	mov    rsi,rax
    5b9d:	jmp    5bb0 <botlish_fn_49+0x258>
    5ba2:	movzx  rcx,BYTE PTR [rax]
    5ba6:	mov    rsi,rax
    5ba9:	rex cmp cl,0x8
    5bad:	sete   cl
    5bb0:	test   cl,cl
    5bb2:	jne    5bd9 <botlish_fn_49+0x281>
    5bb8:	mov    rdi,r13
    5bbb:	mov    rax,QWORD PTR [rdi+0x10]
    5bbf:	mov    rcx,QWORD PTR [rax+0x40]
    5bc3:	mov    edx,0x8
    5bc8:	mov    rax,QWORD PTR [rip+0x0]        # 5bcf <botlish_fn_49+0x277>
			5bcb: R_X86_64_GOTPCREL	rt_type_error-0x4
    5bcf:	call   rax
    5bd1:	mov    rdi,r13
    5bd4:	jmp    5e6d <botlish_fn_49+0x515>
    5bd9:	mov    rax,QWORD PTR [rip+0x0]        # 5be0 <botlish_fn_49+0x288>
			5bdc: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    5be0:	mov    rcx,r15
    5be3:	mov    rdx,QWORD PTR [rsp]
    5be7:	mov    rdi,r13
    5bea:	call   rax
    5bec:	test   rax,rax
    5bef:	jne    5bfd <botlish_fn_49+0x2a5>
    5bf5:	mov    rdi,r13
    5bf8:	jmp    5e6d <botlish_fn_49+0x515>
    5bfd:	mov    QWORD PTR [r12+0x8],0x7
    5c06:	mov    rsi,r14
    5c09:	mov    rdi,r13
    5c0c:	call   5c11 <botlish_fn_49+0x2b9>
			5c0d: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_size<mutarray>
    5c11:	test   rax,rax
    5c14:	jne    5c22 <botlish_fn_49+0x2ca>
    5c1a:	mov    rdi,r13
    5c1d:	jmp    5e6d <botlish_fn_49+0x515>
    5c22:	mov    QWORD PTR [r12+0x10],rax
    5c27:	mov    QWORD PTR [r12+0x18],0x3
    5c30:	mov    ecx,0x1
    5c35:	test   rax,0x1
    5c3b:	je     5c49 <botlish_fn_49+0x2f1>
    5c41:	mov    rsi,rax
    5c44:	jmp    5c6d <botlish_fn_49+0x315>
    5c49:	xor    ecx,ecx
    5c4b:	test   rax,0x7
    5c51:	je     5c5f <botlish_fn_49+0x307>
    5c57:	mov    rsi,rax
    5c5a:	jmp    5c6d <botlish_fn_49+0x315>
    5c5f:	movzx  rcx,BYTE PTR [rax]
    5c63:	mov    rsi,rax
    5c66:	rex cmp cl,0x1
    5c6a:	sete   cl
    5c6d:	test   cl,cl
    5c6f:	jne    5c95 <botlish_fn_49+0x33d>
    5c75:	mov    rdi,r13
    5c78:	mov    rcx,QWORD PTR [rdi+0x10]
    5c7c:	mov    rcx,QWORD PTR [rcx+0x30]
    5c80:	xor    rdx,rdx
    5c83:	mov    r8,QWORD PTR [rip+0x0]        # 5c8a <botlish_fn_49+0x332>
			5c86: R_X86_64_GOTPCREL	rt_type_error-0x4
    5c8a:	call   r8
    5c8d:	mov    rdi,r13
    5c90:	jmp    5e6d <botlish_fn_49+0x515>
    5c95:	test   rsi,0x1
    5c9c:	je     5cb6 <botlish_fn_49+0x35e>
    5ca2:	mov    rcx,rsi
    5ca5:	add    rcx,0x2
    5ca9:	seto   dil
    5cad:	test   dil,dil
    5cb0:	je     5ccb <botlish_fn_49+0x373>
    5cb6:	mov    edx,0x3
    5cbb:	mov    r9,QWORD PTR [rip+0x0]        # 5cc2 <botlish_fn_49+0x36a>
			5cbe: R_X86_64_GOTPCREL	rt_int_add-0x4
    5cc2:	mov    rdi,r13
    5cc5:	call   r9
    5cc8:	mov    rcx,rax
    5ccb:	mov    edx,0x7
    5cd0:	mov    r10,QWORD PTR [rip+0x0]        # 5cd7 <botlish_fn_49+0x37f>
			5cd3: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    5cd7:	mov    rsi,r14
    5cda:	mov    rdi,r13
    5cdd:	call   r10
    5ce0:	test   rax,rax
    5ce3:	jne    5cf1 <botlish_fn_49+0x399>
    5ce9:	mov    rdi,r13
    5cec:	jmp    5e6d <botlish_fn_49+0x515>
    5cf1:	mov    rdi,r13
    5cf4:	call   5cf9 <botlish_fn_49+0x3a1>
			5cf5: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_tombstone_state<generic>
    5cf9:	test   rax,rax
    5cfc:	jne    5d0a <botlish_fn_49+0x3b2>
    5d02:	mov    rdi,r13
    5d05:	jmp    5e6d <botlish_fn_49+0x515>
    5d0a:	mov    rcx,rbx
    5d0d:	and    rcx,rax
    5d10:	mov    rdx,rbx
    5d13:	mov    rsi,rax
    5d16:	test   rcx,0x1
    5d1d:	jne    5d49 <botlish_fn_49+0x3f1>
    5d23:	mov    rax,QWORD PTR [rip+0x0]        # 5d2a <botlish_fn_49+0x3d2>
			5d26: R_X86_64_GOTPCREL	rt_value_eq-0x4
    5d2a:	mov    rcx,rdx
    5d2d:	mov    rdx,rsi
    5d30:	mov    rsi,rcx
    5d33:	mov    rdi,r13
    5d36:	call   rax
    5d38:	test   rax,rax
    5d3b:	jne    5d62 <botlish_fn_49+0x40a>
    5d41:	mov    rdi,r13
    5d44:	jmp    5e6d <botlish_fn_49+0x515>
    5d49:	mov    rax,rdx
    5d4c:	mov    rdx,rsi
    5d4f:	mov    rsi,rax
    5d52:	mov    eax,0x2
    5d57:	cmp    rsi,rdx
    5d5a:	cmove  rax,QWORD PTR [rip+0x19e]        # 5f00 <botlish_fn_49+0x5a8>
    5d62:	cmp    rax,0x6
    5d66:	je     5d74 <botlish_fn_49+0x41c>
    5d6c:	mov    rdi,r13
    5d6f:	jmp    5e9b <botlish_fn_49+0x543>
    5d74:	mov    QWORD PTR [r12+0x8],0x9
    5d7d:	mov    rsi,r14
    5d80:	mov    rdi,r13
    5d83:	call   5d88 <botlish_fn_49+0x430>
			5d84: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_tombstones<mutarray>
    5d88:	test   rax,rax
    5d8b:	jne    5d99 <botlish_fn_49+0x441>
    5d91:	mov    rdi,r13
    5d94:	jmp    5e6d <botlish_fn_49+0x515>
    5d99:	mov    QWORD PTR [r12+0x10],rax
    5d9e:	mov    QWORD PTR [r12+0x18],0x3
    5da7:	mov    esi,0x1
    5dac:	test   rax,0x1
    5db2:	je     5dc0 <botlish_fn_49+0x468>
    5db8:	mov    r11,rax
    5dbb:	jmp    5de5 <botlish_fn_49+0x48d>
    5dc0:	xor    esi,esi
    5dc2:	test   rax,0x7
    5dc8:	je     5dd6 <botlish_fn_49+0x47e>
    5dce:	mov    r11,rax
    5dd1:	jmp    5de5 <botlish_fn_49+0x48d>
    5dd6:	movzx  rcx,BYTE PTR [rax]
    5dda:	mov    r11,rax
    5ddd:	rex cmp cl,0x1
    5de1:	sete   sil
    5de5:	test   sil,sil
    5de8:	jne    5e10 <botlish_fn_49+0x4b8>
    5dee:	mov    rdi,r13
    5df1:	mov    rax,QWORD PTR [rdi+0x10]
    5df5:	mov    rcx,QWORD PTR [rax+0x48]
    5df9:	xor    rdx,rdx
    5dfc:	mov    rax,QWORD PTR [rip+0x0]        # 5e03 <botlish_fn_49+0x4ab>
			5dff: R_X86_64_GOTPCREL	rt_type_error-0x4
    5e03:	mov    rsi,r11
    5e06:	call   rax
    5e08:	mov    rdi,r13
    5e0b:	jmp    5e6d <botlish_fn_49+0x515>
    5e10:	mov    rsi,r11
    5e13:	test   rsi,0x1
    5e1a:	je     5e39 <botlish_fn_49+0x4e1>
    5e20:	mov    rcx,rsi
    5e23:	sub    rcx,0x3
    5e27:	seto   al
    5e2a:	add    rcx,0x1
    5e31:	test   al,al
    5e33:	je     5e4d <botlish_fn_49+0x4f5>
    5e39:	mov    edx,0x3
    5e3e:	mov    rax,QWORD PTR [rip+0x0]        # 5e45 <botlish_fn_49+0x4ed>
			5e41: R_X86_64_GOTPCREL	rt_int_sub-0x4
    5e45:	mov    rdi,r13
    5e48:	call   rax
    5e4a:	mov    rcx,rax
    5e4d:	mov    edx,0x9
    5e52:	mov    rax,QWORD PTR [rip+0x0]        # 5e59 <botlish_fn_49+0x501>
			5e55: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    5e59:	mov    rsi,r14
    5e5c:	mov    rdi,r13
    5e5f:	call   rax
    5e61:	test   rax,rax
    5e64:	jne    5e98 <botlish_fn_49+0x540>
    5e6a:	mov    rdi,r13
    5e6d:	mov    rdi,r13
    5e70:	mov    QWORD PTR [rdi],r12
    5e73:	xor    rax,rax
    5e76:	mov    rbx,QWORD PTR [rsp+0x20]
    5e7b:	mov    r12,QWORD PTR [rsp+0x28]
    5e80:	mov    r13,QWORD PTR [rsp+0x30]
    5e85:	mov    r14,QWORD PTR [rsp+0x38]
    5e8a:	mov    r15,QWORD PTR [rsp+0x40]
    5e8f:	add    rsp,0x50
    5e93:	mov    rsp,rbp
    5e96:	pop    rbp
    5e97:	ret
    5e98:	mov    rdi,r13
    5e9b:	mov    rdi,r13
    5e9e:	mov    QWORD PTR [rdi],r12
    5ea1:	mov    eax,0xa
    5ea6:	mov    rbx,QWORD PTR [rsp+0x20]
    5eab:	mov    r12,QWORD PTR [rsp+0x28]
    5eb0:	mov    r13,QWORD PTR [rsp+0x30]
    5eb5:	mov    r14,QWORD PTR [rsp+0x38]
    5eba:	mov    r15,QWORD PTR [rsp+0x40]
    5ebf:	add    rsp,0x50
    5ec3:	mov    rsp,rbp
    5ec6:	pop    rbp
    5ec7:	ret
    5ec8:	mov    r13,rdi
    5ecb:	mov    rax,QWORD PTR [rip+0x0]        # 5ed2 <botlish_fn_49+0x57a>
			5ece: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    5ed2:	call   rax
    5ed4:	xor    rax,rax
    5ed7:	mov    rbx,QWORD PTR [rsp+0x20]
    5edc:	mov    r12,QWORD PTR [rsp+0x28]
    5ee1:	mov    r13,QWORD PTR [rsp+0x30]
    5ee6:	mov    r14,QWORD PTR [rsp+0x38]
    5eeb:	mov    r15,QWORD PTR [rsp+0x40]
    5ef0:	add    rsp,0x50
    5ef4:	mov    rsp,rbp
    5ef7:	pop    rbp
    5ef8:	ret
    5ef9:	add    BYTE PTR [rax],al
    5efb:	add    BYTE PTR [rax],al
    5efd:	add    BYTE PTR [rax],al
    5eff:	add    BYTE PTR [rsi],al
    5f01:	add    BYTE PTR [rax],al
    5f03:	add    BYTE PTR [rax],al
    5f05:	add    BYTE PTR [rax],al
	...

0000000000005f08 <botlish_entry_49: ht_place<mutarray, int, any, any>>:
    5f08:	push   rbp
    5f09:	mov    rbp,rsp
    5f0c:	mov    rsi,QWORD PTR [rdx]
    5f0f:	mov    r9,QWORD PTR [rdx+0x8]
    5f13:	mov    rcx,QWORD PTR [rdx+0x10]
    5f17:	mov    r8,QWORD PTR [rdx+0x18]
    5f1b:	mov    rdx,r9
    5f1e:	call   5f23 <botlish_entry_49+0x1b>
			5f1f: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    5f23:	mov    rsp,rbp
    5f26:	pop    rbp
    5f27:	ret

0000000000005f28 <botlish_fn_50: ht_set<mutarray, any, any>>:
    5f28:	push   rbp
    5f29:	mov    rbp,rsp
    5f2c:	sub    rsp,0x50
    5f30:	mov    QWORD PTR [rsp+0x20],rbx
    5f35:	mov    QWORD PTR [rsp+0x28],r12
    5f3a:	mov    QWORD PTR [rsp+0x30],r13
    5f3f:	mov    QWORD PTR [rsp+0x38],r14
    5f44:	mov    QWORD PTR [rsp+0x40],r15
    5f49:	mov    rbx,QWORD PTR [rdi]
    5f4c:	mov    rax,QWORD PTR [rdi+0x8]
    5f50:	lea    r8,[rbx+0x28]
    5f54:	cmp    r8,rax
    5f57:	ja     632c <botlish_fn_50+0x404>
    5f5d:	lea    rax,[rbx+0x28]
    5f61:	mov    QWORD PTR [rdi],rax
    5f64:	mov    r12,rdi
    5f67:	mov    QWORD PTR [rbx],0x0
    5f6e:	mov    QWORD PTR [rbx+0x8],0x0
    5f76:	mov    QWORD PTR [rbx+0x10],0x0
    5f7e:	mov    QWORD PTR [rbx+0x18],0x0
    5f86:	mov    QWORD PTR [rbx+0x20],0x0
    5f8e:	mov    QWORD PTR [rbx],rsi
    5f91:	mov    r15,rsi
    5f94:	mov    QWORD PTR [rbx+0x8],rdx
    5f98:	mov    r14,rdx
    5f9b:	mov    QWORD PTR [rbx+0x10],rcx
    5f9f:	mov    r13,rcx
    5fa2:	mov    rdx,r14
    5fa5:	mov    rsi,r15
    5fa8:	mov    rdi,r12
    5fab:	call   5fb0 <botlish_fn_50+0x88>
			5fac: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    5fb0:	test   rax,rax
    5fb3:	jne    5fc1 <botlish_fn_50+0x99>
    5fb9:	mov    rdi,r12
    5fbc:	jmp    62d4 <botlish_fn_50+0x3ac>
    5fc1:	mov    QWORD PTR [rbx+0x18],rax
    5fc5:	mov    rcx,rax
    5fc8:	mov    r8,0xffffffffffffffff
    5fcf:	mov    QWORD PTR [rsp+0x10],r8
    5fd4:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    5fdc:	mov    rdx,r14
    5fdf:	mov    rsi,r15
    5fe2:	mov    rdi,r12
    5fe5:	call   5fea <botlish_fn_50+0xc2>
			5fe6: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    5fea:	mov    rcx,rax
    5fed:	mov    QWORD PTR [rsp+0x8],rax
    5ff2:	test   rax,rcx
    5ff5:	jne    6003 <botlish_fn_50+0xdb>
    5ffb:	mov    rdi,r12
    5ffe:	jmp    62d4 <botlish_fn_50+0x3ac>
    6003:	mov    rax,QWORD PTR [rsp+0x8]
    6008:	mov    QWORD PTR [rbx+0x18],rax
    600c:	mov    rsi,r15
    600f:	mov    rdi,r12
    6012:	call   6017 <botlish_fn_50+0xef>
			6013: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_controls<mutarray>
    6017:	test   rax,rax
    601a:	jne    6028 <botlish_fn_50+0x100>
    6020:	mov    rdi,r12
    6023:	jmp    62d4 <botlish_fn_50+0x3ac>
    6028:	xor    ecx,ecx
    602a:	test   rax,0x7
    6030:	je     603e <botlish_fn_50+0x116>
    6036:	mov    rsi,rax
    6039:	jmp    604c <botlish_fn_50+0x124>
    603e:	movzx  rcx,BYTE PTR [rax]
    6042:	mov    rsi,rax
    6045:	rex cmp cl,0x8
    6049:	sete   cl
    604c:	test   cl,cl
    604e:	jne    6075 <botlish_fn_50+0x14d>
    6054:	mov    rdi,r12
    6057:	mov    rax,QWORD PTR [rdi+0x10]
    605b:	mov    rcx,QWORD PTR [rax+0x20]
    605f:	mov    edx,0x8
    6064:	mov    rax,QWORD PTR [rip+0x0]        # 606b <botlish_fn_50+0x143>
			6067: R_X86_64_GOTPCREL	rt_type_error-0x4
    606b:	call   rax
    606d:	mov    rdi,r12
    6070:	jmp    62d4 <botlish_fn_50+0x3ac>
    6075:	mov    rax,QWORD PTR [rip+0x0]        # 607c <botlish_fn_50+0x154>
			6078: R_X86_64_GOTPCREL	rt_mutarray_get-0x4
    607c:	mov    rdx,QWORD PTR [rsp+0x8]
    6081:	mov    rdi,r12
    6084:	call   rax
    6086:	test   rax,rax
    6089:	jne    6097 <botlish_fn_50+0x16f>
    608f:	mov    rdi,r12
    6092:	jmp    62d4 <botlish_fn_50+0x3ac>
    6097:	mov    QWORD PTR [rbx+0x20],rax
    609b:	mov    QWORD PTR [rsp],rax
    609f:	mov    rdi,r12
    60a2:	call   60a7 <botlish_fn_50+0x17f>
			60a3: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_occupied_state<generic>
    60a7:	test   rax,rax
    60aa:	jne    60b8 <botlish_fn_50+0x190>
    60b0:	mov    rdi,r12
    60b3:	jmp    62d4 <botlish_fn_50+0x3ac>
    60b8:	mov    rcx,QWORD PTR [rsp]
    60bc:	mov    rdx,rcx
    60bf:	and    rdx,rax
    60c2:	mov    rcx,rax
    60c5:	test   rdx,0x1
    60cc:	jne    60f6 <botlish_fn_50+0x1ce>
    60d2:	mov    rax,QWORD PTR [rip+0x0]        # 60d9 <botlish_fn_50+0x1b1>
			60d5: R_X86_64_GOTPCREL	rt_value_eq-0x4
    60d9:	mov    rdx,rcx
    60dc:	mov    rsi,QWORD PTR [rsp]
    60e0:	mov    rdi,r12
    60e3:	call   rax
    60e5:	test   rax,rax
    60e8:	jne    610d <botlish_fn_50+0x1e5>
    60ee:	mov    rdi,r12
    60f1:	jmp    62d4 <botlish_fn_50+0x3ac>
    60f6:	mov    rdx,rcx
    60f9:	mov    rsi,QWORD PTR [rsp]
    60fd:	mov    eax,0x2
    6102:	cmp    rsi,rdx
    6105:	cmove  rax,QWORD PTR [rip+0x253]        # 6360 <botlish_fn_50+0x438>
    610d:	cmp    rax,0x6
    6111:	je     624b <botlish_fn_50+0x323>
    6117:	mov    rsi,r15
    611a:	mov    rdi,r12
    611d:	call   6122 <botlish_fn_50+0x1fa>
			611e: R_X86_64_PLT32	botlish_fn_47-0x4 ; ht_should_grow<mutarray>
    6122:	test   rax,rax
    6125:	jne    6133 <botlish_fn_50+0x20b>
    612b:	mov    rdi,r12
    612e:	jmp    62d4 <botlish_fn_50+0x3ac>
    6133:	cmp    rax,0x6
    6137:	je     618c <botlish_fn_50+0x264>
    613d:	mov    rcx,r14
    6140:	mov    rdx,QWORD PTR [rsp+0x8]
    6145:	mov    rsi,r15
    6148:	mov    r8,r13
    614b:	mov    rdi,r12
    614e:	call   6153 <botlish_fn_50+0x22b>
			614f: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    6153:	test   rax,rax
    6156:	jne    6164 <botlish_fn_50+0x23c>
    615c:	mov    rdi,r12
    615f:	jmp    62d4 <botlish_fn_50+0x3ac>
    6164:	mov    rdi,r12
    6167:	mov    QWORD PTR [rdi],rbx
    616a:	mov    rbx,QWORD PTR [rsp+0x20]
    616f:	mov    r12,QWORD PTR [rsp+0x28]
    6174:	mov    r13,QWORD PTR [rsp+0x30]
    6179:	mov    r14,QWORD PTR [rsp+0x38]
    617e:	mov    r15,QWORD PTR [rsp+0x40]
    6183:	add    rsp,0x50
    6187:	mov    rsp,rbp
    618a:	pop    rbp
    618b:	ret
    618c:	mov    rsi,r15
    618f:	mov    rdi,r12
    6192:	call   6197 <botlish_fn_50+0x26f>
			6193: R_X86_64_PLT32	botlish_fn_48-0x4 ; ht_grow_or_clean<mutarray>
    6197:	test   rax,rax
    619a:	jne    61a8 <botlish_fn_50+0x280>
    61a0:	mov    rdi,r12
    61a3:	jmp    62d4 <botlish_fn_50+0x3ac>
    61a8:	mov    rdx,r14
    61ab:	mov    rsi,r15
    61ae:	mov    rdi,r12
    61b1:	call   61b6 <botlish_fn_50+0x28e>
			61b2: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_probe_start<mutarray, any>
    61b6:	test   rax,rax
    61b9:	jne    61c7 <botlish_fn_50+0x29f>
    61bf:	mov    rdi,r12
    61c2:	jmp    62d4 <botlish_fn_50+0x3ac>
    61c7:	mov    QWORD PTR [rbx+0x18],rax
    61cb:	mov    rcx,rax
    61ce:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    61d6:	mov    r8,QWORD PTR [rsp+0x10]
    61db:	mov    rdx,r14
    61de:	mov    rsi,r15
    61e1:	mov    rdi,r12
    61e4:	call   61e9 <botlish_fn_50+0x2c1>
			61e5: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_find_insert<mutarray, any, int, int>
    61e9:	test   rax,rax
    61ec:	jne    61fa <botlish_fn_50+0x2d2>
    61f2:	mov    rdi,r12
    61f5:	jmp    62d4 <botlish_fn_50+0x3ac>
    61fa:	mov    QWORD PTR [rbx+0x18],rax
    61fe:	mov    rcx,r14
    6201:	mov    rdx,rax
    6204:	mov    rsi,r15
    6207:	mov    r8,r13
    620a:	mov    rdi,r12
    620d:	call   6212 <botlish_fn_50+0x2ea>
			620e: R_X86_64_PLT32	botlish_fn_49-0x4 ; ht_place<mutarray, int, any, any>
    6212:	test   rax,rax
    6215:	jne    6223 <botlish_fn_50+0x2fb>
    621b:	mov    rdi,r12
    621e:	jmp    62d4 <botlish_fn_50+0x3ac>
    6223:	mov    rdi,r12
    6226:	mov    QWORD PTR [rdi],rbx
    6229:	mov    rbx,QWORD PTR [rsp+0x20]
    622e:	mov    r12,QWORD PTR [rsp+0x28]
    6233:	mov    r13,QWORD PTR [rsp+0x30]
    6238:	mov    r14,QWORD PTR [rsp+0x38]
    623d:	mov    r15,QWORD PTR [rsp+0x40]
    6242:	add    rsp,0x50
    6246:	mov    rsp,rbp
    6249:	pop    rbp
    624a:	ret
    624b:	mov    rsi,r15
    624e:	mov    rdi,r12
    6251:	call   6256 <botlish_fn_50+0x32e>
			6252: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_values<mutarray>
    6256:	test   rax,rax
    6259:	jne    6267 <botlish_fn_50+0x33f>
    625f:	mov    rdi,r12
    6262:	jmp    62d4 <botlish_fn_50+0x3ac>
    6267:	xor    ecx,ecx
    6269:	test   rax,0x7
    626f:	je     627d <botlish_fn_50+0x355>
    6275:	mov    rsi,rax
    6278:	jmp    628b <botlish_fn_50+0x363>
    627d:	movzx  rcx,BYTE PTR [rax]
    6281:	mov    rsi,rax
    6284:	rex cmp cl,0x8
    6288:	sete   cl
    628b:	test   cl,cl
    628d:	jne    62b4 <botlish_fn_50+0x38c>
    6293:	mov    rdi,r12
    6296:	mov    rax,QWORD PTR [rdi+0x10]
    629a:	mov    rcx,QWORD PTR [rax+0x40]
    629e:	mov    edx,0x8
    62a3:	mov    rax,QWORD PTR [rip+0x0]        # 62aa <botlish_fn_50+0x382>
			62a6: R_X86_64_GOTPCREL	rt_type_error-0x4
    62aa:	call   rax
    62ac:	mov    rdi,r12
    62af:	jmp    62d4 <botlish_fn_50+0x3ac>
    62b4:	mov    rax,QWORD PTR [rip+0x0]        # 62bb <botlish_fn_50+0x393>
			62b7: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
    62bb:	mov    rcx,r13
    62be:	mov    rdx,QWORD PTR [rsp+0x8]
    62c3:	mov    rdi,r12
    62c6:	call   rax
    62c8:	test   rax,rax
    62cb:	jne    62ff <botlish_fn_50+0x3d7>
    62d1:	mov    rdi,r12
    62d4:	mov    rdi,r12
    62d7:	mov    QWORD PTR [rdi],rbx
    62da:	xor    rax,rax
    62dd:	mov    rbx,QWORD PTR [rsp+0x20]
    62e2:	mov    r12,QWORD PTR [rsp+0x28]
    62e7:	mov    r13,QWORD PTR [rsp+0x30]
    62ec:	mov    r14,QWORD PTR [rsp+0x38]
    62f1:	mov    r15,QWORD PTR [rsp+0x40]
    62f6:	add    rsp,0x50
    62fa:	mov    rsp,rbp
    62fd:	pop    rbp
    62fe:	ret
    62ff:	mov    rdi,r12
    6302:	mov    QWORD PTR [rdi],rbx
    6305:	mov    eax,0xa
    630a:	mov    rbx,QWORD PTR [rsp+0x20]
    630f:	mov    r12,QWORD PTR [rsp+0x28]
    6314:	mov    r13,QWORD PTR [rsp+0x30]
    6319:	mov    r14,QWORD PTR [rsp+0x38]
    631e:	mov    r15,QWORD PTR [rsp+0x40]
    6323:	add    rsp,0x50
    6327:	mov    rsp,rbp
    632a:	pop    rbp
    632b:	ret
    632c:	mov    r12,rdi
    632f:	mov    rax,QWORD PTR [rip+0x0]        # 6336 <botlish_fn_50+0x40e>
			6332: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    6336:	call   rax
    6338:	xor    rax,rax
    633b:	mov    rbx,QWORD PTR [rsp+0x20]
    6340:	mov    r12,QWORD PTR [rsp+0x28]
    6345:	mov    r13,QWORD PTR [rsp+0x30]
    634a:	mov    r14,QWORD PTR [rsp+0x38]
    634f:	mov    r15,QWORD PTR [rsp+0x40]
    6354:	add    rsp,0x50
    6358:	mov    rsp,rbp
    635b:	pop    rbp
    635c:	ret
    635d:	add    BYTE PTR [rax],al
    635f:	add    BYTE PTR [rsi],al
    6361:	add    BYTE PTR [rax],al
    6363:	add    BYTE PTR [rax],al
    6365:	add    BYTE PTR [rax],al
	...

0000000000006368 <botlish_entry_50: ht_set<mutarray, any, any>>:
    6368:	push   rbp
    6369:	mov    rbp,rsp
    636c:	mov    rsi,QWORD PTR [rdx]
    636f:	mov    r8,QWORD PTR [rdx+0x8]
    6373:	mov    rcx,QWORD PTR [rdx+0x10]
    6377:	mov    rdx,r8
    637a:	call   637f <botlish_entry_50+0x17>
			637b: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    637f:	mov    rsp,rbp
    6382:	pop    rbp
    6383:	ret

0000000000006384 <botlish_fn_51: row_new<bool, int>>:
    6384:	push   rbp
    6385:	mov    rbp,rsp
    6388:	sub    rsp,0x10
    638c:	mov    QWORD PTR [rsp],rbx
    6390:	mov    QWORD PTR [rsp+0x8],r15
    6395:	mov    r15,QWORD PTR [rdi]
    6398:	mov    rax,QWORD PTR [rdi+0x8]
    639c:	lea    rcx,[r15+0x8]
    63a0:	cmp    rcx,rax
    63a3:	ja     643e <botlish_fn_51+0xba>
    63a9:	lea    rax,[r15+0x8]
    63ad:	mov    QWORD PTR [rdi],rax
    63b0:	mov    rbx,rdi
    63b3:	mov    QWORD PTR [r15],rdx
    63b6:	mov    rax,rdx
    63b9:	cmp    rsi,0x6
    63bd:	je     63f4 <botlish_fn_51+0x70>
    63c3:	mov    rdi,rbx
    63c6:	call   63cb <botlish_fn_51+0x47>
			63c7: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_new<generic>
    63cb:	test   rax,rax
    63ce:	jne    63dc <botlish_fn_51+0x58>
    63d4:	mov    rdi,rbx
    63d7:	jmp    640b <botlish_fn_51+0x87>
    63dc:	mov    rdi,rbx
    63df:	mov    QWORD PTR [rdi],r15
    63e2:	mov    rbx,QWORD PTR [rsp]
    63e6:	mov    r15,QWORD PTR [rsp+0x8]
    63eb:	add    rsp,0x10
    63ef:	mov    rsp,rbp
    63f2:	pop    rbp
    63f3:	ret
    63f4:	mov    rsi,rax
    63f7:	mov    rdi,rbx
    63fa:	call   63ff <botlish_fn_51+0x7b>
			63fb: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_new_sized<int>
    63ff:	test   rax,rax
    6402:	jne    6426 <botlish_fn_51+0xa2>
    6408:	mov    rdi,rbx
    640b:	mov    rdi,rbx
    640e:	mov    QWORD PTR [rdi],r15
    6411:	xor    rax,rax
    6414:	mov    rbx,QWORD PTR [rsp]
    6418:	mov    r15,QWORD PTR [rsp+0x8]
    641d:	add    rsp,0x10
    6421:	mov    rsp,rbp
    6424:	pop    rbp
    6425:	ret
    6426:	mov    rdi,rbx
    6429:	mov    QWORD PTR [rdi],r15
    642c:	mov    rbx,QWORD PTR [rsp]
    6430:	mov    r15,QWORD PTR [rsp+0x8]
    6435:	add    rsp,0x10
    6439:	mov    rsp,rbp
    643c:	pop    rbp
    643d:	ret
    643e:	mov    rbx,rdi
    6441:	mov    rax,QWORD PTR [rip+0x0]        # 6448 <botlish_fn_51+0xc4>
			6444: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    6448:	call   rax
    644a:	xor    rax,rax
    644d:	mov    rbx,QWORD PTR [rsp]
    6451:	mov    r15,QWORD PTR [rsp+0x8]
    6456:	add    rsp,0x10
    645a:	mov    rsp,rbp
    645d:	pop    rbp
    645e:	ret

000000000000645f <botlish_entry_51: row_new<bool, int>>:
    645f:	push   rbp
    6460:	mov    rbp,rsp
    6463:	mov    rsi,QWORD PTR [rdx]
    6466:	mov    rdx,QWORD PTR [rdx+0x8]
    646a:	call   646f <botlish_entry_51+0x10>
			646b: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    646f:	mov    rsp,rbp
    6472:	pop    rbp
    6473:	ret
    6474:	add    BYTE PTR [rax],al
	...

0000000000006478 <botlish_fn_52: row_fill<mutarray, any, any, int, int>>:
    6478:	push   rbp
    6479:	mov    rbp,rsp
    647c:	sub    rsp,0x50
    6480:	mov    QWORD PTR [rsp+0x20],rbx
    6485:	mov    QWORD PTR [rsp+0x28],r12
    648a:	mov    QWORD PTR [rsp+0x30],r13
    648f:	mov    QWORD PTR [rsp+0x38],r14
    6494:	mov    QWORD PTR [rsp+0x40],r15
    6499:	mov    r10,r9
    649c:	mov    r14,QWORD PTR [rdi]
    649f:	mov    rax,QWORD PTR [rdi+0x8]
    64a3:	lea    r9,[r14+0x30]
    64a7:	cmp    r9,rax
    64aa:	ja     6722 <botlish_fn_52+0x2aa>
    64b0:	lea    rax,[r14+0x30]
    64b4:	mov    QWORD PTR [rdi],rax
    64b7:	mov    r15,rdi
    64ba:	mov    QWORD PTR [r14],0x0
    64c1:	mov    QWORD PTR [r14+0x8],0x0
    64c9:	mov    QWORD PTR [r14+0x10],0x0
    64d1:	mov    QWORD PTR [r14+0x18],0x0
    64d9:	mov    QWORD PTR [r14+0x20],0x0
    64e1:	mov    QWORD PTR [r14+0x28],0x0
    64e9:	mov    QWORD PTR [r14],rsi
    64ec:	mov    r13,rsi
    64ef:	mov    QWORD PTR [r14+0x8],rdx
    64f3:	mov    QWORD PTR [rsp],rdx
    64f7:	mov    QWORD PTR [r14+0x10],rcx
    64fb:	mov    QWORD PTR [rsp+0x8],rcx
    6500:	mov    QWORD PTR [r14+0x18],r8
    6504:	mov    rsi,r8
    6507:	mov    rbx,r10
    650a:	mov    r8,rbx
    650d:	or     r8,0x1
    6511:	mov    r12,rsi
    6514:	mov    r9,r12
    6517:	and    r9,r8
    651a:	test   r9,0x1
    6521:	jne    6553 <botlish_fn_52+0xdb>
    6527:	mov    rdx,rbx
    652a:	or     rdx,0x1
    652e:	mov    r10,QWORD PTR [rip+0x0]        # 6535 <botlish_fn_52+0xbd>
			6531: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    6535:	mov    rsi,r12
    6538:	mov    rdi,r15
    653b:	call   r10
    653e:	mov    ecx,0x2
    6543:	test   rax,rax
    6546:	cmovge rcx,QWORD PTR [rip+0x20a]        # 6758 <botlish_fn_52+0x2e0>
    654e:	jmp    656a <botlish_fn_52+0xf2>
    6553:	mov    rax,rbx
    6556:	or     rax,0x1
    655a:	mov    ecx,0x2
    655f:	cmp    r12,rax
    6562:	cmovge rcx,QWORD PTR [rip+0x1ee]        # 6758 <botlish_fn_52+0x2e0>
    656a:	cmp    rcx,0x6
    656e:	je     66f7 <botlish_fn_52+0x27f>
    6574:	xor    ecx,ecx
    6576:	mov    rdx,QWORD PTR [rsp]
    657a:	test   rdx,0x7
    6581:	je     6590 <botlish_fn_52+0x118>
    6587:	mov    QWORD PTR [rsp],rdx
    658b:	jmp    659d <botlish_fn_52+0x125>
    6590:	movzx  rax,BYTE PTR [rdx]
    6594:	mov    QWORD PTR [rsp],rdx
    6598:	cmp    al,0x3
    659a:	sete   cl
    659d:	test   cl,cl
    659f:	jne    65ca <botlish_fn_52+0x152>
    65a5:	mov    rdi,r15
    65a8:	mov    rax,QWORD PTR [rdi+0x10]
    65ac:	mov    rcx,QWORD PTR [rax+0x50]
    65b0:	mov    edx,0x4
    65b5:	mov    rax,QWORD PTR [rip+0x0]        # 65bc <botlish_fn_52+0x144>
			65b8: R_X86_64_GOTPCREL	rt_type_error-0x4
    65bc:	mov    rsi,QWORD PTR [rsp]
    65c0:	call   rax
    65c2:	mov    rdi,r15
    65c5:	jmp    669b <botlish_fn_52+0x223>
    65ca:	mov    rax,QWORD PTR [rip+0x0]        # 65d1 <botlish_fn_52+0x159>
			65cd: R_X86_64_GOTPCREL	rt_list_get-0x4
    65d1:	mov    rdx,r12
    65d4:	mov    rsi,QWORD PTR [rsp]
    65d8:	mov    rdi,r15
    65db:	call   rax
    65dd:	test   rax,rax
    65e0:	jne    65ee <botlish_fn_52+0x176>
    65e6:	mov    rdi,r15
    65e9:	jmp    669b <botlish_fn_52+0x223>
    65ee:	mov    QWORD PTR [r14+0x20],rax
    65f2:	mov    QWORD PTR [rsp+0x10],rax
    65f7:	xor    edi,edi
    65f9:	mov    rcx,QWORD PTR [rsp+0x8]
    65fe:	test   rcx,0x7
    6605:	je     6615 <botlish_fn_52+0x19d>
    660b:	mov    QWORD PTR [rsp+0x8],rcx
    6610:	jmp    6624 <botlish_fn_52+0x1ac>
    6615:	movzx  rax,BYTE PTR [rcx]
    6619:	mov    QWORD PTR [rsp+0x8],rcx
    661e:	cmp    al,0x3
    6620:	sete   dil
    6624:	test   dil,dil
    6627:	jne    6653 <botlish_fn_52+0x1db>
    662d:	mov    rdi,r15
    6630:	mov    rax,QWORD PTR [rdi+0x10]
    6634:	mov    rcx,QWORD PTR [rax+0x50]
    6638:	mov    edx,0x4
    663d:	mov    rax,QWORD PTR [rip+0x0]        # 6644 <botlish_fn_52+0x1cc>
			6640: R_X86_64_GOTPCREL	rt_type_error-0x4
    6644:	mov    rsi,QWORD PTR [rsp+0x8]
    6649:	call   rax
    664b:	mov    rdi,r15
    664e:	jmp    669b <botlish_fn_52+0x223>
    6653:	mov    rax,QWORD PTR [rip+0x0]        # 665a <botlish_fn_52+0x1e2>
			6656: R_X86_64_GOTPCREL	rt_list_get-0x4
    665a:	mov    rdx,r12
    665d:	mov    rsi,QWORD PTR [rsp+0x8]
    6662:	mov    rdi,r15
    6665:	call   rax
    6667:	test   rax,rax
    666a:	jne    6678 <botlish_fn_52+0x200>
    6670:	mov    rdi,r15
    6673:	jmp    669b <botlish_fn_52+0x223>
    6678:	mov    QWORD PTR [r14+0x28],rax
    667c:	mov    rcx,rax
    667f:	mov    rdx,QWORD PTR [rsp+0x10]
    6684:	mov    rsi,r13
    6687:	mov    rdi,r15
    668a:	call   668f <botlish_fn_52+0x217>
			668b: R_X86_64_PLT32	botlish_fn_50-0x4 ; ht_set<mutarray, any, any>
    668f:	test   rax,rax
    6692:	jne    66c6 <botlish_fn_52+0x24e>
    6698:	mov    rdi,r15
    669b:	mov    rdi,r15
    669e:	mov    QWORD PTR [rdi],r14
    66a1:	xor    rax,rax
    66a4:	mov    rbx,QWORD PTR [rsp+0x20]
    66a9:	mov    r12,QWORD PTR [rsp+0x28]
    66ae:	mov    r13,QWORD PTR [rsp+0x30]
    66b3:	mov    r14,QWORD PTR [rsp+0x38]
    66b8:	mov    r15,QWORD PTR [rsp+0x40]
    66bd:	add    rsp,0x50
    66c1:	mov    rsp,rbp
    66c4:	pop    rbp
    66c5:	ret
    66c6:	mov    QWORD PTR [r14],r13
    66c9:	mov    rsi,QWORD PTR [rsp]
    66cd:	mov    QWORD PTR [r14+0x8],rsi
    66d1:	mov    rsi,QWORD PTR [rsp+0x8]
    66d6:	mov    QWORD PTR [r14+0x10],rsi
    66da:	sar    r12,1
    66dd:	add    r12,0x1
    66e4:	shl    r12,1
    66e7:	or     r12,0x1
    66eb:	mov    QWORD PTR [r14+0x18],r12
    66ef:	mov    rsi,r12
    66f2:	jmp    650a <botlish_fn_52+0x92>
    66f7:	mov    rdi,r15
    66fa:	mov    QWORD PTR [rdi],r14
    66fd:	mov    rax,r13
    6700:	mov    rbx,QWORD PTR [rsp+0x20]
    6705:	mov    r12,QWORD PTR [rsp+0x28]
    670a:	mov    r13,QWORD PTR [rsp+0x30]
    670f:	mov    r14,QWORD PTR [rsp+0x38]
    6714:	mov    r15,QWORD PTR [rsp+0x40]
    6719:	add    rsp,0x50
    671d:	mov    rsp,rbp
    6720:	pop    rbp
    6721:	ret
    6722:	mov    r15,rdi
    6725:	mov    rax,QWORD PTR [rip+0x0]        # 672c <botlish_fn_52+0x2b4>
			6728: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    672c:	call   rax
    672e:	xor    rax,rax
    6731:	mov    rbx,QWORD PTR [rsp+0x20]
    6736:	mov    r12,QWORD PTR [rsp+0x28]
    673b:	mov    r13,QWORD PTR [rsp+0x30]
    6740:	mov    r14,QWORD PTR [rsp+0x38]
    6745:	mov    r15,QWORD PTR [rsp+0x40]
    674a:	add    rsp,0x50
    674e:	mov    rsp,rbp
    6751:	pop    rbp
    6752:	ret
    6753:	add    BYTE PTR [rax],al
    6755:	add    BYTE PTR [rax],al
    6757:	add    BYTE PTR [rsi],al
    6759:	add    BYTE PTR [rax],al
    675b:	add    BYTE PTR [rax],al
    675d:	add    BYTE PTR [rax],al
	...

0000000000006760 <botlish_entry_52: row_fill<mutarray, any, any, int, int>>:
    6760:	push   rbp
    6761:	mov    rbp,rsp
    6764:	mov    rsi,QWORD PTR [rdx]
    6767:	mov    r10,QWORD PTR [rdx+0x8]
    676b:	mov    rcx,QWORD PTR [rdx+0x10]
    676f:	mov    r8,QWORD PTR [rdx+0x18]
    6773:	mov    r9,QWORD PTR [rdx+0x20]
    6777:	mov    rdx,r10
    677a:	call   677f <botlish_entry_52+0x1f>
			677b: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    677f:	mov    rsp,rbp
    6782:	pop    rbp
    6783:	ret

0000000000006784 <botlish_fn_53: row_table<any, int, any, bool>>:
    6784:	push   rbp
    6785:	mov    rbp,rsp
    6788:	sub    rsp,0x30
    678c:	mov    QWORD PTR [rsp],rbx
    6790:	mov    QWORD PTR [rsp+0x8],r12
    6795:	mov    QWORD PTR [rsp+0x10],r13
    679a:	mov    QWORD PTR [rsp+0x18],r14
    679f:	mov    QWORD PTR [rsp+0x20],r15
    67a4:	mov    rbx,QWORD PTR [rdi]
    67a7:	mov    rax,QWORD PTR [rdi+0x8]
    67ab:	lea    r9,[rbx+0x28]
    67af:	cmp    r9,rax
    67b2:	ja     6905 <botlish_fn_53+0x181>
    67b8:	lea    rax,[rbx+0x28]
    67bc:	mov    QWORD PTR [rdi],rax
    67bf:	mov    r12,rdi
    67c2:	mov    QWORD PTR [rbx],0x0
    67c9:	mov    QWORD PTR [rbx+0x8],0x0
    67d1:	mov    QWORD PTR [rbx+0x10],0x0
    67d9:	mov    QWORD PTR [rbx+0x18],0x0
    67e1:	mov    QWORD PTR [rbx+0x20],0x0
    67e9:	mov    QWORD PTR [rbx],rsi
    67ec:	mov    r14,rsi
    67ef:	mov    QWORD PTR [rbx+0x8],rdx
    67f3:	mov    QWORD PTR [rbx+0x10],rcx
    67f7:	mov    r13,rcx
    67fa:	mov    QWORD PTR [rbx+0x18],r8
    67fe:	mov    rsi,r8
    6801:	mov    rdi,r12
    6804:	call   6809 <botlish_fn_53+0x85>
			6805: R_X86_64_PLT32	botlish_fn_51-0x4 ; row_new<bool, int>
    6809:	test   rax,rax
    680c:	jne    681a <botlish_fn_53+0x96>
    6812:	mov    rdi,r12
    6815:	jmp    68b4 <botlish_fn_53+0x130>
    681a:	mov    QWORD PTR [rbx+0x8],rax
    681e:	mov    r15,rax
    6821:	mov    QWORD PTR [rbx+0x18],0x1
    6829:	xor    ecx,ecx
    682b:	mov    rdx,r13
    682e:	test   rdx,0x7
    6835:	je     6843 <botlish_fn_53+0xbf>
    683b:	mov    r13,rdx
    683e:	jmp    684f <botlish_fn_53+0xcb>
    6843:	movzx  rax,BYTE PTR [rdx]
    6847:	mov    r13,rdx
    684a:	cmp    al,0x3
    684c:	sete   cl
    684f:	test   cl,cl
    6851:	jne    687b <botlish_fn_53+0xf7>
    6857:	mov    rdi,r12
    685a:	mov    rax,QWORD PTR [rdi+0x10]
    685e:	mov    rcx,QWORD PTR [rax+0x58]
    6862:	mov    edx,0x4
    6867:	mov    rax,QWORD PTR [rip+0x0]        # 686e <botlish_fn_53+0xea>
			686a: R_X86_64_GOTPCREL	rt_type_error-0x4
    686e:	mov    rsi,r13
    6871:	call   rax
    6873:	mov    rdi,r12
    6876:	jmp    68b4 <botlish_fn_53+0x130>
    687b:	mov    rax,QWORD PTR [rip+0x0]        # 6882 <botlish_fn_53+0xfe>
			687e: R_X86_64_GOTPCREL	rt_list_len-0x4
    6882:	mov    rsi,r13
    6885:	mov    rdi,r12
    6888:	call   rax
    688a:	mov    QWORD PTR [rbx+0x20],rax
    688e:	mov    r8d,0x1
    6894:	mov    rcx,r13
    6897:	mov    rdx,r14
    689a:	mov    rsi,r15
    689d:	mov    r9,rax
    68a0:	mov    rdi,r12
    68a3:	call   68a8 <botlish_fn_53+0x124>
			68a4: R_X86_64_PLT32	botlish_fn_52-0x4 ; row_fill<mutarray, any, any, int, int>
    68a8:	test   rax,rax
    68ab:	jne    68de <botlish_fn_53+0x15a>
    68b1:	mov    rdi,r12
    68b4:	mov    rdi,r12
    68b7:	mov    QWORD PTR [rdi],rbx
    68ba:	xor    rax,rax
    68bd:	mov    rbx,QWORD PTR [rsp]
    68c1:	mov    r12,QWORD PTR [rsp+0x8]
    68c6:	mov    r13,QWORD PTR [rsp+0x10]
    68cb:	mov    r14,QWORD PTR [rsp+0x18]
    68d0:	mov    r15,QWORD PTR [rsp+0x20]
    68d5:	add    rsp,0x30
    68d9:	mov    rsp,rbp
    68dc:	pop    rbp
    68dd:	ret
    68de:	mov    rdi,r12
    68e1:	mov    QWORD PTR [rdi],rbx
    68e4:	mov    rbx,QWORD PTR [rsp]
    68e8:	mov    r12,QWORD PTR [rsp+0x8]
    68ed:	mov    r13,QWORD PTR [rsp+0x10]
    68f2:	mov    r14,QWORD PTR [rsp+0x18]
    68f7:	mov    r15,QWORD PTR [rsp+0x20]
    68fc:	add    rsp,0x30
    6900:	mov    rsp,rbp
    6903:	pop    rbp
    6904:	ret
    6905:	mov    r12,rdi
    6908:	mov    rcx,QWORD PTR [rip+0x0]        # 690f <botlish_fn_53+0x18b>
			690b: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    690f:	call   rcx
    6911:	xor    rax,rax
    6914:	mov    rbx,QWORD PTR [rsp]
    6918:	mov    r12,QWORD PTR [rsp+0x8]
    691d:	mov    r13,QWORD PTR [rsp+0x10]
    6922:	mov    r14,QWORD PTR [rsp+0x18]
    6927:	mov    r15,QWORD PTR [rsp+0x20]
    692c:	add    rsp,0x30
    6930:	mov    rsp,rbp
    6933:	pop    rbp
    6934:	ret

0000000000006935 <botlish_entry_53: row_table<any, int, any, bool>>:
    6935:	push   rbp
    6936:	mov    rbp,rsp
    6939:	mov    rsi,QWORD PTR [rdx]
    693c:	mov    r9,QWORD PTR [rdx+0x8]
    6940:	mov    rcx,QWORD PTR [rdx+0x10]
    6944:	mov    r8,QWORD PTR [rdx+0x18]
    6948:	mov    rdx,r9
    694b:	call   6950 <botlish_entry_53+0x1b>
			694c: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    6950:	mov    rsp,rbp
    6953:	pop    rbp
    6954:	ret
    6955:	add    BYTE PTR [rax],al
	...

0000000000006958 <botlish_fn_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    6958:	push   rbp
    6959:	mov    rbp,rsp
    695c:	sub    rsp,0x50
    6960:	mov    QWORD PTR [rsp+0x20],rbx
    6965:	mov    QWORD PTR [rsp+0x28],r12
    696a:	mov    QWORD PTR [rsp+0x30],r13
    696f:	mov    QWORD PTR [rsp+0x38],r14
    6974:	mov    QWORD PTR [rsp+0x40],r15
    6979:	mov    QWORD PTR [rsp+0x8],r8
    697e:	mov    r12,QWORD PTR [rbp+0x10]
    6982:	mov    r13,r12
    6985:	mov    r12,QWORD PTR [rdi]
    6988:	mov    rax,QWORD PTR [rdi+0x8]
    698c:	lea    r8,[r12+0x38]
    6991:	cmp    r8,rax
    6994:	ja     6bb1 <botlish_fn_54+0x259>
    699a:	lea    rax,[r12+0x38]
    699f:	mov    QWORD PTR [rdi],rax
    69a2:	mov    QWORD PTR [rsp],rdi
    69a6:	mov    QWORD PTR [r12],0x0
    69ae:	mov    QWORD PTR [r12+0x8],0x0
    69b7:	mov    QWORD PTR [r12+0x10],0x0
    69c0:	mov    QWORD PTR [r12+0x18],0x0
    69c9:	mov    QWORD PTR [r12+0x20],0x0
    69d2:	mov    QWORD PTR [r12+0x28],0x0
    69db:	mov    QWORD PTR [r12+0x30],0x0
    69e4:	mov    QWORD PTR [r12],rsi
    69e8:	mov    r14,rsi
    69eb:	mov    QWORD PTR [r12+0x8],rdx
    69f0:	mov    rbx,rdx
    69f3:	mov    QWORD PTR [r12+0x10],rcx
    69f8:	mov    r15,rcx
    69fb:	mov    QWORD PTR [r12+0x18],r9
    6a00:	mov    rax,r13
    6a03:	mov    QWORD PTR [r12+0x20],rax
    6a08:	mov    QWORD PTR [rsp+0x10],r9
    6a0d:	mov    rax,QWORD PTR [rip+0x0]        # 6a14 <botlish_fn_54+0xbc>
			6a10: R_X86_64_GOTPCREL	rt_list_len-0x4
    6a14:	mov    rsi,r14
    6a17:	mov    rdi,QWORD PTR [rsp]
    6a1b:	call   rax
    6a1d:	mov    rcx,rbx
    6a20:	and    rcx,rax
    6a23:	mov    rdx,rax
    6a26:	test   rcx,0x1
    6a2d:	jne    6a58 <botlish_fn_54+0x100>
    6a33:	mov    rax,QWORD PTR [rip+0x0]        # 6a3a <botlish_fn_54+0xe2>
			6a36: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    6a3a:	mov    rsi,rbx
    6a3d:	mov    rdi,QWORD PTR [rsp]
    6a41:	call   rax
    6a43:	mov    ecx,0x2
    6a48:	test   rax,rax
    6a4b:	cmovge rcx,QWORD PTR [rip+0x195]        # 6be8 <botlish_fn_54+0x290>
    6a53:	jmp    6a68 <botlish_fn_54+0x110>
    6a58:	mov    ecx,0x2
    6a5d:	cmp    rbx,rdx
    6a60:	cmovge rcx,QWORD PTR [rip+0x180]        # 6be8 <botlish_fn_54+0x290>
    6a68:	cmp    rcx,0x6
    6a6c:	je     6b41 <botlish_fn_54+0x1e9>
    6a72:	mov    rcx,QWORD PTR [rsp+0x8]
    6a77:	mov    rsi,rcx
    6a7a:	or     rsi,0x1
    6a7e:	mov    QWORD PTR [r12+0x28],rsi
    6a83:	mov    r8,QWORD PTR [rip+0x0]        # 6a8a <botlish_fn_54+0x132>
			6a86: R_X86_64_GOTPCREL	rt_list_get-0x4
    6a8a:	mov    rdx,rbx
    6a8d:	mov    rsi,r14
    6a90:	mov    rdi,QWORD PTR [rsp]
    6a94:	call   r8
    6a97:	test   rax,rax
    6a9a:	jne    6aa9 <botlish_fn_54+0x151>
    6aa0:	mov    rdi,QWORD PTR [rsp]
    6aa4:	jmp    6b5c <botlish_fn_54+0x204>
    6aa9:	mov    QWORD PTR [r12+0x30],rax
    6aae:	mov    rcx,QWORD PTR [rsp+0x8]
    6ab3:	mov    rsi,rax
    6ab6:	mov    rdx,rcx
    6ab9:	or     rdx,0x1
    6abd:	mov    rcx,rsi
    6ac0:	mov    rsi,r15
    6ac3:	mov    rdi,QWORD PTR [rsp]
    6ac7:	mov    r8,r13
    6aca:	call   6acf <botlish_fn_54+0x177>
			6acb: R_X86_64_PLT32	botlish_fn_53-0x4 ; row_table<any, int, any, bool>
    6acf:	test   rax,rax
    6ad2:	jne    6ae1 <botlish_fn_54+0x189>
    6ad8:	mov    rdi,QWORD PTR [rsp]
    6adc:	jmp    6b5c <botlish_fn_54+0x204>
    6ae1:	mov    QWORD PTR [r12+0x8],rax
    6ae6:	mov    rdx,rax
    6ae9:	sar    rbx,1
    6aec:	add    rbx,0x1
    6af3:	shl    rbx,1
    6af6:	or     rbx,0x1
    6afa:	mov    QWORD PTR [r12+0x28],rbx
    6aff:	mov    rsi,QWORD PTR [rsp+0x10]
    6b04:	mov    rdi,QWORD PTR [rsp]
    6b08:	call   6b0d <botlish_fn_54+0x1b5>
			6b09: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<list[mutarray, int], mutarray>
    6b0d:	test   rax,rax
    6b10:	jne    6b1f <botlish_fn_54+0x1c7>
    6b16:	mov    rdi,QWORD PTR [rsp]
    6b1a:	jmp    6b5c <botlish_fn_54+0x204>
    6b1f:	mov    QWORD PTR [r12],r14
    6b23:	mov    QWORD PTR [r12+0x8],rbx
    6b28:	mov    QWORD PTR [r12+0x10],r15
    6b2d:	mov    QWORD PTR [r12+0x18],rax
    6b32:	mov    QWORD PTR [r12+0x20],r13
    6b37:	mov    QWORD PTR [rsp+0x10],rax
    6b3c:	jmp    6a0d <botlish_fn_54+0xb5>
    6b41:	mov    rsi,QWORD PTR [rsp+0x10]
    6b46:	mov    rdi,QWORD PTR [rsp]
    6b4a:	call   6b4f <botlish_fn_54+0x1f7>
			6b4b: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_finish<list[mutarray, int]>
    6b4f:	test   rax,rax
    6b52:	jne    6b88 <botlish_fn_54+0x230>
    6b58:	mov    rdi,QWORD PTR [rsp]
    6b5c:	mov    rdi,QWORD PTR [rsp]
    6b60:	mov    QWORD PTR [rdi],r12
    6b63:	xor    rax,rax
    6b66:	mov    rbx,QWORD PTR [rsp+0x20]
    6b6b:	mov    r12,QWORD PTR [rsp+0x28]
    6b70:	mov    r13,QWORD PTR [rsp+0x30]
    6b75:	mov    r14,QWORD PTR [rsp+0x38]
    6b7a:	mov    r15,QWORD PTR [rsp+0x40]
    6b7f:	add    rsp,0x50
    6b83:	mov    rsp,rbp
    6b86:	pop    rbp
    6b87:	ret
    6b88:	mov    rdi,QWORD PTR [rsp]
    6b8c:	mov    QWORD PTR [rdi],r12
    6b8f:	mov    rbx,QWORD PTR [rsp+0x20]
    6b94:	mov    r12,QWORD PTR [rsp+0x28]
    6b99:	mov    r13,QWORD PTR [rsp+0x30]
    6b9e:	mov    r14,QWORD PTR [rsp+0x38]
    6ba3:	mov    r15,QWORD PTR [rsp+0x40]
    6ba8:	add    rsp,0x50
    6bac:	mov    rsp,rbp
    6baf:	pop    rbp
    6bb0:	ret
    6bb1:	mov    QWORD PTR [rsp],rdi
    6bb5:	mov    rax,QWORD PTR [rip+0x0]        # 6bbc <botlish_fn_54+0x264>
			6bb8: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    6bbc:	call   rax
    6bbe:	xor    rax,rax
    6bc1:	mov    rbx,QWORD PTR [rsp+0x20]
    6bc6:	mov    r12,QWORD PTR [rsp+0x28]
    6bcb:	mov    r13,QWORD PTR [rsp+0x30]
    6bd0:	mov    r14,QWORD PTR [rsp+0x38]
    6bd5:	mov    r15,QWORD PTR [rsp+0x40]
    6bda:	add    rsp,0x50
    6bde:	mov    rsp,rbp
    6be1:	pop    rbp
    6be2:	ret
    6be3:	add    BYTE PTR [rax],al
    6be5:	add    BYTE PTR [rax],al
    6be7:	add    BYTE PTR [rsi],al
    6be9:	add    BYTE PTR [rax],al
    6beb:	add    BYTE PTR [rax],al
    6bed:	add    BYTE PTR [rax],al
	...

0000000000006bf0 <botlish_entry_54: build_rows<list, int, any, int, list[mutarray, int], bool>>:
    6bf0:	push   rbp
    6bf1:	mov    rbp,rsp
    6bf4:	sub    rsp,0x10
    6bf8:	mov    rsi,QWORD PTR [rdx]
    6bfb:	mov    r10,QWORD PTR [rdx+0x8]
    6bff:	mov    rcx,QWORD PTR [rdx+0x10]
    6c03:	mov    r8,QWORD PTR [rdx+0x18]
    6c07:	mov    r9,QWORD PTR [rdx+0x20]
    6c0b:	mov    r11,QWORD PTR [rdx+0x28]
    6c0f:	mov    QWORD PTR [rsp],r11
    6c13:	mov    rdx,r10
    6c16:	call   6c1b <botlish_entry_54+0x2b>
			6c17: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    6c1b:	add    rsp,0x10
    6c1f:	mov    rsp,rbp
    6c22:	pop    rbp
    6c23:	ret

0000000000006c24 <botlish_fn_55: csv_records_generic<str, bool>>:
    6c24:	push   rbp
    6c25:	mov    rbp,rsp
    6c28:	sub    rsp,0x50
    6c2c:	mov    QWORD PTR [rsp+0x20],rbx
    6c31:	mov    QWORD PTR [rsp+0x28],r12
    6c36:	mov    QWORD PTR [rsp+0x30],r13
    6c3b:	mov    QWORD PTR [rsp+0x38],r14
    6c40:	mov    QWORD PTR [rsp+0x40],r15
    6c45:	mov    rbx,QWORD PTR [rdi]
    6c48:	mov    rax,QWORD PTR [rdi+0x8]
    6c4c:	lea    rcx,[rbx+0x30]
    6c50:	cmp    rcx,rax
    6c53:	ja     6e63 <botlish_fn_55+0x23f>
    6c59:	lea    rax,[rbx+0x30]
    6c5d:	mov    QWORD PTR [rdi],rax
    6c60:	mov    r12,rdi
    6c63:	mov    QWORD PTR [rbx],0x0
    6c6a:	mov    QWORD PTR [rbx+0x8],0x0
    6c72:	mov    QWORD PTR [rbx+0x10],0x0
    6c7a:	mov    QWORD PTR [rbx+0x18],0x0
    6c82:	mov    QWORD PTR [rbx+0x20],0x0
    6c8a:	mov    QWORD PTR [rbx+0x28],0x0
    6c92:	mov    QWORD PTR [rbx],rsi
    6c95:	mov    QWORD PTR [rbx+0x8],rdx
    6c99:	mov    r13,rdx
    6c9c:	mov    rdi,r12
    6c9f:	call   6ca4 <botlish_fn_55+0x80>
			6ca0: R_X86_64_PLT32	botlish_fn_15-0x4 ; csv_parse<str>
    6ca4:	mov    rcx,rax
    6ca7:	mov    r14,rax
    6caa:	test   rax,rcx
    6cad:	jne    6cbb <botlish_fn_55+0x97>
    6cb3:	mov    rdi,r12
    6cb6:	jmp    6e10 <botlish_fn_55+0x1ec>
    6cbb:	mov    rax,r14
    6cbe:	mov    QWORD PTR [rbx],rax
    6cc1:	mov    rax,QWORD PTR [rip+0x0]        # 6cc8 <botlish_fn_55+0xa4>
			6cc4: R_X86_64_GOTPCREL	rt_list_len-0x4
    6cc8:	mov    rsi,r14
    6ccb:	mov    rdi,r12
    6cce:	call   rax
    6cd0:	sar    rax,1
    6cd3:	test   rax,rax
    6cd6:	je     6df2 <botlish_fn_55+0x1ce>
    6cdc:	mov    edx,0x1
    6ce1:	mov    rax,QWORD PTR [rip+0x0]        # 6ce8 <botlish_fn_55+0xc4>
			6ce4: R_X86_64_GOTPCREL	rt_list_get-0x4
    6ce8:	mov    rsi,r14
    6ceb:	mov    rdi,r12
    6cee:	call   rax
    6cf0:	test   rax,rax
    6cf3:	jne    6d01 <botlish_fn_55+0xdd>
    6cf9:	mov    rdi,r12
    6cfc:	jmp    6e10 <botlish_fn_55+0x1ec>
    6d01:	mov    QWORD PTR [rbx+0x10],rax
    6d05:	mov    QWORD PTR [rbx+0x18],0x3
    6d0d:	xor    ecx,ecx
    6d0f:	test   rax,0x7
    6d15:	je     6d23 <botlish_fn_55+0xff>
    6d1b:	mov    r15,rax
    6d1e:	jmp    6d31 <botlish_fn_55+0x10d>
    6d23:	movzx  rsi,BYTE PTR [rax]
    6d27:	mov    r15,rax
    6d2a:	cmp    sil,0x3
    6d2e:	sete   cl
    6d31:	test   cl,cl
    6d33:	jne    6d61 <botlish_fn_55+0x13d>
    6d39:	mov    rdi,r12
    6d3c:	mov    rdi,QWORD PTR [rdi+0x10]
    6d40:	mov    rcx,QWORD PTR [rdi+0x58]
    6d44:	mov    edx,0x4
    6d49:	mov    r8,QWORD PTR [rip+0x0]        # 6d50 <botlish_fn_55+0x12c>
			6d4c: R_X86_64_GOTPCREL	rt_type_error-0x4
    6d50:	mov    rsi,r15
    6d53:	mov    rdi,r12
    6d56:	call   r8
    6d59:	mov    rdi,r12
    6d5c:	jmp    6e10 <botlish_fn_55+0x1ec>
    6d61:	mov    r8,QWORD PTR [rip+0x0]        # 6d68 <botlish_fn_55+0x144>
			6d64: R_X86_64_GOTPCREL	rt_list_len-0x4
    6d68:	mov    rsi,r15
    6d6b:	mov    rdi,r12
    6d6e:	call   r8
    6d71:	mov    QWORD PTR [rbx+0x20],rax
    6d75:	mov    QWORD PTR [rsp+0x10],rax
    6d7a:	mov    rdi,r12
    6d7d:	call   6d82 <botlish_fn_55+0x15e>
			6d7e: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    6d82:	test   rax,rax
    6d85:	jne    6d93 <botlish_fn_55+0x16f>
    6d8b:	mov    rdi,r12
    6d8e:	jmp    6e10 <botlish_fn_55+0x1ec>
    6d93:	mov    QWORD PTR [rbx+0x28],rax
    6d97:	mov    r9,rax
    6d9a:	mov    edx,0x3
    6d9f:	mov    rax,r13
    6da2:	mov    QWORD PTR [rsp],rax
    6da6:	mov    rcx,r15
    6da9:	mov    rsi,r14
    6dac:	mov    r8,QWORD PTR [rsp+0x10]
    6db1:	mov    rdi,r12
    6db4:	call   6db9 <botlish_fn_55+0x195>
			6db5: R_X86_64_PLT32	botlish_fn_54-0x4 ; build_rows<list, int, any, int, list[mutarray, int], bool>
    6db9:	test   rax,rax
    6dbc:	jne    6dca <botlish_fn_55+0x1a6>
    6dc2:	mov    rdi,r12
    6dc5:	jmp    6e10 <botlish_fn_55+0x1ec>
    6dca:	mov    rdi,r12
    6dcd:	mov    QWORD PTR [rdi],rbx
    6dd0:	mov    rbx,QWORD PTR [rsp+0x20]
    6dd5:	mov    r12,QWORD PTR [rsp+0x28]
    6dda:	mov    r13,QWORD PTR [rsp+0x30]
    6ddf:	mov    r14,QWORD PTR [rsp+0x38]
    6de4:	mov    r15,QWORD PTR [rsp+0x40]
    6de9:	add    rsp,0x50
    6ded:	mov    rsp,rbp
    6df0:	pop    rbp
    6df1:	ret
    6df2:	xor    rdx,rdx
    6df5:	mov    rax,QWORD PTR [rip+0x0]        # 6dfc <botlish_fn_55+0x1d8>
			6df8: R_X86_64_GOTPCREL	rt_list_new-0x4
    6dfc:	mov    rdi,r12
    6dff:	mov    rsi,rdx
    6e02:	call   rax
    6e04:	test   rax,rax
    6e07:	jne    6e3b <botlish_fn_55+0x217>
    6e0d:	mov    rdi,r12
    6e10:	mov    rdi,r12
    6e13:	mov    QWORD PTR [rdi],rbx
    6e16:	xor    rax,rax
    6e19:	mov    rbx,QWORD PTR [rsp+0x20]
    6e1e:	mov    r12,QWORD PTR [rsp+0x28]
    6e23:	mov    r13,QWORD PTR [rsp+0x30]
    6e28:	mov    r14,QWORD PTR [rsp+0x38]
    6e2d:	mov    r15,QWORD PTR [rsp+0x40]
    6e32:	add    rsp,0x50
    6e36:	mov    rsp,rbp
    6e39:	pop    rbp
    6e3a:	ret
    6e3b:	mov    rdi,r12
    6e3e:	mov    QWORD PTR [rdi],rbx
    6e41:	mov    rbx,QWORD PTR [rsp+0x20]
    6e46:	mov    r12,QWORD PTR [rsp+0x28]
    6e4b:	mov    r13,QWORD PTR [rsp+0x30]
    6e50:	mov    r14,QWORD PTR [rsp+0x38]
    6e55:	mov    r15,QWORD PTR [rsp+0x40]
    6e5a:	add    rsp,0x50
    6e5e:	mov    rsp,rbp
    6e61:	pop    rbp
    6e62:	ret
    6e63:	mov    r12,rdi
    6e66:	mov    rax,QWORD PTR [rip+0x0]        # 6e6d <botlish_fn_55+0x249>
			6e69: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    6e6d:	call   rax
    6e6f:	xor    rax,rax
    6e72:	mov    rbx,QWORD PTR [rsp+0x20]
    6e77:	mov    r12,QWORD PTR [rsp+0x28]
    6e7c:	mov    r13,QWORD PTR [rsp+0x30]
    6e81:	mov    r14,QWORD PTR [rsp+0x38]
    6e86:	mov    r15,QWORD PTR [rsp+0x40]
    6e8b:	add    rsp,0x50
    6e8f:	mov    rsp,rbp
    6e92:	pop    rbp
    6e93:	ret

0000000000006e94 <botlish_entry_55: csv_records_generic<str, bool>>:
    6e94:	push   rbp
    6e95:	mov    rbp,rsp
    6e98:	mov    rsi,QWORD PTR [rdx]
    6e9b:	mov    rdx,QWORD PTR [rdx+0x8]
    6e9f:	call   6ea4 <botlish_entry_55+0x10>
			6ea0: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    6ea4:	mov    rsp,rbp
    6ea7:	pop    rbp
    6ea8:	ret

0000000000006ea9 <botlish_fn_56: csv_records<str>>:
    6ea9:	push   rbp
    6eaa:	mov    rbp,rsp
    6ead:	sub    rsp,0x10
    6eb1:	mov    QWORD PTR [rsp],r14
    6eb5:	mov    QWORD PTR [rsp+0x8],r15
    6eba:	mov    r14,QWORD PTR [rdi]
    6ebd:	mov    rax,QWORD PTR [rdi+0x8]
    6ec1:	lea    rcx,[r14+0x10]
    6ec5:	cmp    rcx,rax
    6ec8:	ja     6f3b <botlish_fn_56+0x92>
    6ece:	lea    rax,[r14+0x10]
    6ed2:	mov    QWORD PTR [rdi],rax
    6ed5:	mov    r15,rdi
    6ed8:	mov    QWORD PTR [r14],0x0
    6edf:	mov    QWORD PTR [r14+0x8],0x0
    6ee7:	mov    QWORD PTR [r14],rsi
    6eea:	mov    edx,0x2
    6eef:	mov    QWORD PTR [r14+0x8],0x2
    6ef7:	mov    rdi,r15
    6efa:	call   6eff <botlish_fn_56+0x56>
			6efb: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    6eff:	test   rax,rax
    6f02:	jne    6f23 <botlish_fn_56+0x7a>
    6f08:	mov    rdi,r15
    6f0b:	mov    QWORD PTR [rdi],r14
    6f0e:	xor    rax,rax
    6f11:	mov    r14,QWORD PTR [rsp]
    6f15:	mov    r15,QWORD PTR [rsp+0x8]
    6f1a:	add    rsp,0x10
    6f1e:	mov    rsp,rbp
    6f21:	pop    rbp
    6f22:	ret
    6f23:	mov    rdi,r15
    6f26:	mov    QWORD PTR [rdi],r14
    6f29:	mov    r14,QWORD PTR [rsp]
    6f2d:	mov    r15,QWORD PTR [rsp+0x8]
    6f32:	add    rsp,0x10
    6f36:	mov    rsp,rbp
    6f39:	pop    rbp
    6f3a:	ret
    6f3b:	mov    rax,QWORD PTR [rip+0x0]        # 6f42 <botlish_fn_56+0x99>
			6f3e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    6f42:	call   rax
    6f44:	xor    rax,rax
    6f47:	mov    r14,QWORD PTR [rsp]
    6f4b:	mov    r15,QWORD PTR [rsp+0x8]
    6f50:	add    rsp,0x10
    6f54:	mov    rsp,rbp
    6f57:	pop    rbp
    6f58:	ret

0000000000006f59 <botlish_entry_56: csv_records<str>>:
    6f59:	push   rbp
    6f5a:	mov    rbp,rsp
    6f5d:	mov    rsi,QWORD PTR [rdx]
    6f60:	call   6f65 <botlish_entry_56+0xc>
			6f61: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    6f65:	mov    rsp,rbp
    6f68:	pop    rbp
    6f69:	ret

0000000000006f6a <botlish_fn_57: csv_records_presized<str>>:
    6f6a:	push   rbp
    6f6b:	mov    rbp,rsp
    6f6e:	sub    rsp,0x10
    6f72:	mov    QWORD PTR [rsp],r14
    6f76:	mov    QWORD PTR [rsp+0x8],r15
    6f7b:	mov    r14,QWORD PTR [rdi]
    6f7e:	mov    rax,QWORD PTR [rdi+0x8]
    6f82:	lea    rcx,[r14+0x10]
    6f86:	cmp    rcx,rax
    6f89:	ja     6ffc <botlish_fn_57+0x92>
    6f8f:	lea    rax,[r14+0x10]
    6f93:	mov    QWORD PTR [rdi],rax
    6f96:	mov    r15,rdi
    6f99:	mov    QWORD PTR [r14],0x0
    6fa0:	mov    QWORD PTR [r14+0x8],0x0
    6fa8:	mov    QWORD PTR [r14],rsi
    6fab:	mov    edx,0x6
    6fb0:	mov    QWORD PTR [r14+0x8],0x6
    6fb8:	mov    rdi,r15
    6fbb:	call   6fc0 <botlish_fn_57+0x56>
			6fbc: R_X86_64_PLT32	botlish_fn_55-0x4 ; csv_records_generic<str, bool>
    6fc0:	test   rax,rax
    6fc3:	jne    6fe4 <botlish_fn_57+0x7a>
    6fc9:	mov    rdi,r15
    6fcc:	mov    QWORD PTR [rdi],r14
    6fcf:	xor    rax,rax
    6fd2:	mov    r14,QWORD PTR [rsp]
    6fd6:	mov    r15,QWORD PTR [rsp+0x8]
    6fdb:	add    rsp,0x10
    6fdf:	mov    rsp,rbp
    6fe2:	pop    rbp
    6fe3:	ret
    6fe4:	mov    rdi,r15
    6fe7:	mov    QWORD PTR [rdi],r14
    6fea:	mov    r14,QWORD PTR [rsp]
    6fee:	mov    r15,QWORD PTR [rsp+0x8]
    6ff3:	add    rsp,0x10
    6ff7:	mov    rsp,rbp
    6ffa:	pop    rbp
    6ffb:	ret
    6ffc:	mov    rax,QWORD PTR [rip+0x0]        # 7003 <botlish_fn_57+0x99>
			6fff: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    7003:	call   rax
    7005:	xor    rax,rax
    7008:	mov    r14,QWORD PTR [rsp]
    700c:	mov    r15,QWORD PTR [rsp+0x8]
    7011:	add    rsp,0x10
    7015:	mov    rsp,rbp
    7018:	pop    rbp
    7019:	ret

000000000000701a <botlish_entry_57: csv_records_presized<str>>:
    701a:	push   rbp
    701b:	mov    rbp,rsp
    701e:	mov    rsi,QWORD PTR [rdx]
    7021:	call   7026 <botlish_entry_57+0xc>
			7022: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    7026:	mov    rsp,rbp
    7029:	pop    rbp
    702a:	ret
    702b:	add    BYTE PTR [rax],al
    702d:	add    BYTE PTR [rax],al
	...

0000000000007030 <botlish_fn_58: sample<generic>>:
    7030:	push   rbp
    7031:	mov    rbp,rsp
    7034:	sub    rsp,0x90
    703b:	mov    QWORD PTR [rsp+0x60],rbx
    7040:	mov    QWORD PTR [rsp+0x68],r12
    7045:	mov    QWORD PTR [rsp+0x70],r13
    704a:	mov    QWORD PTR [rsp+0x78],r14
    704f:	mov    QWORD PTR [rsp+0x80],r15
    7057:	mov    r12,QWORD PTR [rdi]
    705a:	mov    r9,QWORD PTR [rdi+0x8]
    705e:	lea    r10,[r12+0x40]
    7063:	cmp    r10,r9
    7066:	ja     7518 <botlish_fn_58+0x4e8>
    706c:	lea    r11,[r12+0x40]
    7071:	mov    QWORD PTR [rdi],r11
    7074:	mov    QWORD PTR [r12],0x0
    707c:	mov    QWORD PTR [r12+0x8],0x0
    7085:	mov    QWORD PTR [r12+0x10],0x0
    708e:	mov    QWORD PTR [r12+0x18],0x0
    7097:	mov    QWORD PTR [r12+0x20],0x0
    70a0:	mov    QWORD PTR [r12+0x28],0x0
    70a9:	mov    QWORD PTR [r12+0x30],0x0
    70b2:	mov    QWORD PTR [r12+0x38],0x0
    70bb:	mov    rax,QWORD PTR [rdi+0x10]
    70bf:	mov    QWORD PTR [rsp+0x38],rdi
    70c4:	mov    rsi,QWORD PTR [rax+0x60]
    70c8:	mov    QWORD PTR [r12],rsi
    70cc:	call   70d1 <botlish_fn_58+0xa1>
			70cd: R_X86_64_PLT32	botlish_fn_56-0x4 ; csv_records<str>
    70d1:	test   rax,rax
    70d4:	jne    70e4 <botlish_fn_58+0xb4>
    70da:	mov    rdi,QWORD PTR [rsp+0x38]
    70df:	jmp    74b5 <botlish_fn_58+0x485>
    70e4:	mov    QWORD PTR [r12],rax
    70e8:	mov    rdi,QWORD PTR [rsp+0x38]
    70ed:	mov    r14,rax
    70f0:	mov    rax,QWORD PTR [rdi+0x10]
    70f4:	mov    rsi,QWORD PTR [rax+0x60]
    70f8:	mov    QWORD PTR [r12+0x8],rsi
    70fd:	call   7102 <botlish_fn_58+0xd2>
			70fe: R_X86_64_PLT32	botlish_fn_57-0x4 ; csv_records_presized<str>
    7102:	test   rax,rax
    7105:	mov    r13,rax
    7108:	jne    7118 <botlish_fn_58+0xe8>
    710e:	mov    rdi,QWORD PTR [rsp+0x38]
    7113:	jmp    74b5 <botlish_fn_58+0x485>
    7118:	mov    edx,0x1
    711d:	mov    rax,QWORD PTR [rip+0x0]        # 7124 <botlish_fn_58+0xf4>
			7120: R_X86_64_GOTPCREL	rt_list_get-0x4
    7124:	mov    rsi,r14
    7127:	mov    rdi,QWORD PTR [rsp+0x38]
    712c:	call   rax
    712e:	mov    rbx,rax
    7131:	test   rbx,rbx
    7134:	jne    7144 <botlish_fn_58+0x114>
    713a:	mov    rdi,QWORD PTR [rsp+0x38]
    713f:	jmp    74b5 <botlish_fn_58+0x485>
    7144:	mov    QWORD PTR [r12+0x8],rbx
    7149:	mov    edx,0x3
    714e:	mov    rax,QWORD PTR [rip+0x0]        # 7155 <botlish_fn_58+0x125>
			7151: R_X86_64_GOTPCREL	rt_list_get-0x4
    7155:	mov    rsi,r14
    7158:	mov    rdi,QWORD PTR [rsp+0x38]
    715d:	call   rax
    715f:	mov    rsi,rax
    7162:	mov    QWORD PTR [rsp+0x50],rax
    7167:	test   rsi,rax
    716a:	jne    717a <botlish_fn_58+0x14a>
    7170:	mov    rdi,QWORD PTR [rsp+0x38]
    7175:	jmp    74b5 <botlish_fn_58+0x485>
    717a:	mov    rsi,QWORD PTR [rsp+0x50]
    717f:	mov    QWORD PTR [r12+0x10],rsi
    7184:	mov    edx,0x1
    7189:	mov    rax,QWORD PTR [rip+0x0]        # 7190 <botlish_fn_58+0x160>
			718c: R_X86_64_GOTPCREL	rt_list_get-0x4
    7190:	mov    rsi,r13
    7193:	mov    rdi,QWORD PTR [rsp+0x38]
    7198:	call   rax
    719a:	test   rax,rax
    719d:	jne    71ad <botlish_fn_58+0x17d>
    71a3:	mov    rdi,QWORD PTR [rsp+0x38]
    71a8:	jmp    74b5 <botlish_fn_58+0x485>
    71ad:	mov    QWORD PTR [r12+0x18],rax
    71b2:	mov    rdi,QWORD PTR [rsp+0x38]
    71b7:	mov    r15,rax
    71ba:	mov    rax,QWORD PTR [rdi+0x10]
    71be:	mov    rdx,QWORD PTR [rax+0x68]
    71c2:	mov    QWORD PTR [r12+0x20],rdx
    71c7:	mov    rsi,rbx
    71ca:	call   71cf <botlish_fn_58+0x19f>
			71cb: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    71cf:	test   rax,rax
    71d2:	jne    71e2 <botlish_fn_58+0x1b2>
    71d8:	mov    rdi,QWORD PTR [rsp+0x38]
    71dd:	jmp    74b5 <botlish_fn_58+0x485>
    71e2:	mov    QWORD PTR [r12+0x20],rax
    71e7:	mov    rdi,QWORD PTR [rsp+0x38]
    71ec:	mov    r13,rax
    71ef:	mov    rax,QWORD PTR [rdi+0x10]
    71f3:	mov    rdx,QWORD PTR [rax+0x68]
    71f7:	mov    QWORD PTR [r12+0x28],rdx
    71fc:	mov    rsi,r15
    71ff:	call   7204 <botlish_fn_58+0x1d4>
			7200: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    7204:	test   rax,rax
    7207:	jne    7217 <botlish_fn_58+0x1e7>
    720d:	mov    rdi,QWORD PTR [rsp+0x38]
    7212:	jmp    74b5 <botlish_fn_58+0x485>
    7217:	mov    rcx,r13
    721a:	mov    rdx,rcx
    721d:	and    rdx,rax
    7220:	mov    rcx,rax
    7223:	test   rdx,0x1
    722a:	jne    7257 <botlish_fn_58+0x227>
    7230:	mov    rax,QWORD PTR [rip+0x0]        # 7237 <botlish_fn_58+0x207>
			7233: R_X86_64_GOTPCREL	rt_value_eq-0x4
    7237:	mov    rdx,rcx
    723a:	mov    rsi,r13
    723d:	mov    rdi,QWORD PTR [rsp+0x38]
    7242:	call   rax
    7244:	test   rax,rax
    7247:	jne    726d <botlish_fn_58+0x23d>
    724d:	mov    rdi,QWORD PTR [rsp+0x38]
    7252:	jmp    74b5 <botlish_fn_58+0x485>
    7257:	mov    rdx,rcx
    725a:	mov    rsi,r13
    725d:	mov    eax,0x2
    7262:	cmp    rsi,rdx
    7265:	cmove  rax,QWORD PTR [rip+0x2eb]        # 7558 <botlish_fn_58+0x528>
    726d:	mov    r13d,0x6
    7273:	cmp    rax,0x6
    7277:	je     7290 <botlish_fn_58+0x260>
    727d:	mov    r13d,0x2
    7283:	mov    QWORD PTR [r12],0x2
    728b:	jmp    733d <botlish_fn_58+0x30d>
    7290:	mov    rsi,rbx
    7293:	mov    rdi,QWORD PTR [rsp+0x38]
    7298:	call   729d <botlish_fn_58+0x26d>
			7299: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    729d:	test   rax,rax
    72a0:	jne    72b0 <botlish_fn_58+0x280>
    72a6:	mov    rdi,QWORD PTR [rsp+0x38]
    72ab:	jmp    74b5 <botlish_fn_58+0x485>
    72b0:	mov    QWORD PTR [r12+0x20],rax
    72b5:	mov    rsi,r15
    72b8:	mov    r15,rax
    72bb:	mov    rdi,QWORD PTR [rsp+0x38]
    72c0:	call   72c5 <botlish_fn_58+0x295>
			72c1: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_size<generic>
    72c5:	test   rax,rax
    72c8:	jne    72d8 <botlish_fn_58+0x2a8>
    72ce:	mov    rdi,QWORD PTR [rsp+0x38]
    72d3:	jmp    74b5 <botlish_fn_58+0x485>
    72d8:	mov    rcx,r15
    72db:	mov    rdi,rcx
    72de:	and    rdi,rax
    72e1:	mov    rdx,rax
    72e4:	test   rdi,0x1
    72eb:	jne    7316 <botlish_fn_58+0x2e6>
    72f1:	mov    r9,QWORD PTR [rip+0x0]        # 72f8 <botlish_fn_58+0x2c8>
			72f4: R_X86_64_GOTPCREL	rt_value_eq-0x4
    72f8:	mov    rsi,r15
    72fb:	mov    rdi,QWORD PTR [rsp+0x38]
    7300:	call   r9
    7303:	test   rax,rax
    7306:	jne    7329 <botlish_fn_58+0x2f9>
    730c:	mov    rdi,QWORD PTR [rsp+0x38]
    7311:	jmp    74b5 <botlish_fn_58+0x485>
    7316:	mov    rsi,r15
    7319:	mov    eax,0x2
    731e:	cmp    rsi,rdx
    7321:	cmove  rax,QWORD PTR [rip+0x22f]        # 7558 <botlish_fn_58+0x528>
    7329:	cmp    rax,0x6
    732d:	je     7339 <botlish_fn_58+0x309>
    7333:	mov    r13d,0x2
    7339:	mov    QWORD PTR [r12],r13
    733d:	mov    rax,QWORD PTR [rip+0x0]        # 7344 <botlish_fn_58+0x314>
			7340: R_X86_64_GOTPCREL	rt_list_len-0x4
    7344:	mov    rsi,r14
    7347:	mov    rdi,QWORD PTR [rsp+0x38]
    734c:	call   rax
    734e:	mov    r14,rax
    7351:	mov    QWORD PTR [r12+0x18],r14
    7356:	mov    rdi,QWORD PTR [rsp+0x38]
    735b:	mov    rax,QWORD PTR [rdi+0x10]
    735f:	mov    rdx,QWORD PTR [rax+0x68]
    7363:	mov    QWORD PTR [r12+0x20],rdx
    7368:	mov    rsi,rbx
    736b:	call   7370 <botlish_fn_58+0x340>
			736c: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    7370:	mov    r15,rax
    7373:	test   r15,r15
    7376:	jne    7386 <botlish_fn_58+0x356>
    737c:	mov    rdi,QWORD PTR [rsp+0x38]
    7381:	jmp    74b5 <botlish_fn_58+0x485>
    7386:	mov    QWORD PTR [r12+0x20],r15
    738b:	mov    rdi,QWORD PTR [rsp+0x38]
    7390:	mov    rax,QWORD PTR [rdi+0x10]
    7394:	mov    rdx,QWORD PTR [rax+0x70]
    7398:	mov    QWORD PTR [r12+0x28],rdx
    739d:	mov    rsi,rbx
    73a0:	call   73a5 <botlish_fn_58+0x375>
			73a1: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    73a5:	mov    rsi,rbx
    73a8:	mov    rbx,rax
    73ab:	test   rbx,rbx
    73ae:	jne    73be <botlish_fn_58+0x38e>
    73b4:	mov    rdi,QWORD PTR [rsp+0x38]
    73b9:	jmp    74b5 <botlish_fn_58+0x485>
    73be:	mov    QWORD PTR [r12+0x28],rbx
    73c3:	mov    rdi,QWORD PTR [rsp+0x38]
    73c8:	mov    rax,QWORD PTR [rdi+0x10]
    73cc:	mov    rdx,QWORD PTR [rax+0x78]
    73d0:	mov    QWORD PTR [r12+0x30],rdx
    73d5:	call   73da <botlish_fn_58+0x3aa>
			73d6: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    73da:	test   rax,rax
    73dd:	jne    73ed <botlish_fn_58+0x3bd>
    73e3:	mov    rdi,QWORD PTR [rsp+0x38]
    73e8:	jmp    74b5 <botlish_fn_58+0x485>
    73ed:	mov    QWORD PTR [r12+0x8],rax
    73f2:	mov    rdi,QWORD PTR [rsp+0x38]
    73f7:	mov    QWORD PTR [rsp+0x48],rax
    73fc:	mov    rax,QWORD PTR [rdi+0x10]
    7400:	mov    rdx,QWORD PTR [rax+0x68]
    7404:	mov    QWORD PTR [r12+0x30],rdx
    7409:	mov    rsi,QWORD PTR [rsp+0x50]
    740e:	call   7413 <botlish_fn_58+0x3e3>
			740f: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    7413:	test   rax,rax
    7416:	jne    7426 <botlish_fn_58+0x3f6>
    741c:	mov    rdi,QWORD PTR [rsp+0x38]
    7421:	jmp    74b5 <botlish_fn_58+0x485>
    7426:	mov    QWORD PTR [r12+0x30],rax
    742b:	mov    rdi,QWORD PTR [rsp+0x38]
    7430:	mov    QWORD PTR [rsp+0x40],rax
    7435:	mov    rax,QWORD PTR [rdi+0x10]
    7439:	mov    rdx,QWORD PTR [rax+0x78]
    743d:	mov    QWORD PTR [r12+0x38],rdx
    7442:	mov    rsi,QWORD PTR [rsp+0x50]
    7447:	call   744c <botlish_fn_58+0x41c>
			7448: R_X86_64_PLT32	botlish_fn_42-0x4 ; ht_get<any, str>
    744c:	test   rax,rax
    744f:	jne    745f <botlish_fn_58+0x42f>
    7455:	mov    rdi,QWORD PTR [rsp+0x38]
    745a:	jmp    74b5 <botlish_fn_58+0x485>
    745f:	mov    QWORD PTR [r12+0x10],rax
    7464:	lea    rdx,[rsp]
    7468:	mov    QWORD PTR [rsp],r14
    746c:	mov    QWORD PTR [rsp+0x8],r15
    7471:	mov    QWORD PTR [rsp+0x10],rbx
    7476:	mov    rcx,QWORD PTR [rsp+0x48]
    747b:	mov    QWORD PTR [rsp+0x18],rcx
    7480:	mov    rcx,QWORD PTR [rsp+0x40]
    7485:	mov    QWORD PTR [rsp+0x20],rcx
    748a:	mov    QWORD PTR [rsp+0x28],rax
    748f:	mov    QWORD PTR [rsp+0x30],r13
    7494:	mov    esi,0x7
    7499:	mov    rax,QWORD PTR [rip+0x0]        # 74a0 <botlish_fn_58+0x470>
			749c: R_X86_64_GOTPCREL	rt_list_new-0x4
    74a0:	mov    rdi,QWORD PTR [rsp+0x38]
    74a5:	call   rax
    74a7:	test   rax,rax
    74aa:	jne    74e8 <botlish_fn_58+0x4b8>
    74b0:	mov    rdi,QWORD PTR [rsp+0x38]
    74b5:	mov    rdi,QWORD PTR [rsp+0x38]
    74ba:	mov    QWORD PTR [rdi],r12
    74bd:	xor    rax,rax
    74c0:	mov    rbx,QWORD PTR [rsp+0x60]
    74c5:	mov    r12,QWORD PTR [rsp+0x68]
    74ca:	mov    r13,QWORD PTR [rsp+0x70]
    74cf:	mov    r14,QWORD PTR [rsp+0x78]
    74d4:	mov    r15,QWORD PTR [rsp+0x80]
    74dc:	add    rsp,0x90
    74e3:	mov    rsp,rbp
    74e6:	pop    rbp
    74e7:	ret
    74e8:	mov    rdi,QWORD PTR [rsp+0x38]
    74ed:	mov    QWORD PTR [rdi],r12
    74f0:	mov    rbx,QWORD PTR [rsp+0x60]
    74f5:	mov    r12,QWORD PTR [rsp+0x68]
    74fa:	mov    r13,QWORD PTR [rsp+0x70]
    74ff:	mov    r14,QWORD PTR [rsp+0x78]
    7504:	mov    r15,QWORD PTR [rsp+0x80]
    750c:	add    rsp,0x90
    7513:	mov    rsp,rbp
    7516:	pop    rbp
    7517:	ret
    7518:	mov    QWORD PTR [rsp+0x38],rdi
    751d:	mov    rax,QWORD PTR [rip+0x0]        # 7524 <botlish_fn_58+0x4f4>
			7520: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    7524:	call   rax
    7526:	xor    rax,rax
    7529:	mov    rbx,QWORD PTR [rsp+0x60]
    752e:	mov    r12,QWORD PTR [rsp+0x68]
    7533:	mov    r13,QWORD PTR [rsp+0x70]
    7538:	mov    r14,QWORD PTR [rsp+0x78]
    753d:	mov    r15,QWORD PTR [rsp+0x80]
    7545:	add    rsp,0x90
    754c:	mov    rsp,rbp
    754f:	pop    rbp
    7550:	ret
    7551:	add    BYTE PTR [rax],al
    7553:	add    BYTE PTR [rax],al
    7555:	add    BYTE PTR [rax],al
    7557:	add    BYTE PTR [rsi],al
    7559:	add    BYTE PTR [rax],al
    755b:	add    BYTE PTR [rax],al
    755d:	add    BYTE PTR [rax],al
	...

0000000000007560 <botlish_entry_58: sample<generic>>:
    7560:	push   rbp
    7561:	mov    rbp,rsp
    7564:	call   7569 <botlish_entry_58+0x9>
			7565: R_X86_64_PLT32	botlish_fn_58-0x4 ; sample<generic>
    7569:	mov    rsp,rbp
    756c:	pop    rbp
    756d:	ret

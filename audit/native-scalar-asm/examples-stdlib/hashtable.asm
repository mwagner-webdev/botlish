; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 17970  (per function: 172 85 85 85 85 548 696 208 184 184 184 184 184 268 299 355 1036 1568 581 389 596 639 1433 945 961 833 1528 1132 1469 1054)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> ht_min_capacity<generic>
;   botlish_fn_2 / botlish_entry_2 -> ht_empty_state<generic>
;   botlish_fn_3 / botlish_entry_3 -> ht_occupied_state<generic>
;   botlish_fn_4 / botlish_entry_4 -> ht_tombstone_state<generic>
;   botlish_fn_5 / botlish_entry_5 -> ht_fill_empty<mutarray, int, int>
;   botlish_fn_6 / botlish_entry_6 -> ht_alloc<int>
;   botlish_fn_7 / botlish_entry_7 -> ht_new<generic>
;   botlish_fn_8 / botlish_entry_8 -> ht_controls<mutarray>
;   botlish_fn_9 / botlish_entry_9 -> ht_keys<mutarray>
;   botlish_fn_10 / botlish_entry_10 -> ht_values<mutarray>
;   botlish_fn_11 / botlish_entry_11 -> ht_size<mutarray>
;   botlish_fn_12 / botlish_entry_12 -> ht_tombstones<mutarray>
;   botlish_fn_13 / botlish_entry_13 -> ht_capacity<mutarray>
;   botlish_fn_14 / botlish_entry_14 -> ht_probe_start<mutarray, str>
;   botlish_fn_15 / botlish_entry_15 -> ht_probe_next<mutarray, int>
;   botlish_fn_16 / botlish_entry_16 -> ht_find_get<mutarray, str, int>
;   botlish_fn_17 / botlish_entry_17 -> ht_find_insert<mutarray, str, int, int>
;   botlish_fn_18 / botlish_entry_18 -> ht_get<mutarray, str>
;   botlish_fn_19 / botlish_entry_19 -> ht_contains<mutarray, str>
;   botlish_fn_20 / botlish_entry_20 -> ht_rehash_probe<mutarray, int, int>
;   botlish_fn_21 / botlish_entry_21 -> ht_rehash_insert<list<mutarray>, int, any, any>
;   botlish_fn_22 / botlish_entry_22 -> ht_rehash_scan<list, int, int, list<mutarray>, int>
;   botlish_fn_23 / botlish_entry_23 -> ht_rehash<mutarray, int>
;   botlish_fn_24 / botlish_entry_24 -> ht_should_grow<mutarray>
;   botlish_fn_25 / botlish_entry_25 -> ht_grow_or_clean<mutarray>
;   botlish_fn_26 / botlish_entry_26 -> ht_place<mutarray, int, str, str>
;   botlish_fn_27 / botlish_entry_27 -> ht_set<mutarray, str, str>
;   botlish_fn_28 / botlish_entry_28 -> ht_delete<mutarray, str>
;   botlish_fn_29 / botlish_entry_29 -> sample<generic>


hashtable.asm.o:     file format elf64-x86-64


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
			3d: R_X86_64_PLT32	botlish_fn_29-0x4 ; sample<generic>
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

00000000000000a5 <botlish_fn_1: ht_min_capacity<generic>>:
      a5:	push   rbp
      a6:	mov    rbp,rsp
      a9:	mov    r9,QWORD PTR [rdi]
      ac:	mov    r10,QWORD PTR [rdi+0x8]
      b0:	lea    r11,[r9+0x8]
      b4:	cmp    r11,r10
      b7:	ja     d8 <botlish_fn_1+0x33>
      bd:	lea    r11,[r9+0x8]
      c1:	mov    QWORD PTR [rdi],r11
      c4:	mov    QWORD PTR [r9],0x0
      cb:	mov    QWORD PTR [rdi],r9
      ce:	mov    eax,0x11
      d3:	mov    rsp,rbp
      d6:	pop    rbp
      d7:	ret
      d8:	call   dd <botlish_fn_1+0x38>
			d9: R_X86_64_PLT32	rt_stack_overflow-0x4
      dd:	xor    rax,rax
      e0:	mov    rsp,rbp
      e3:	pop    rbp
      e4:	ret

00000000000000e5 <botlish_entry_1: ht_min_capacity<generic>>:
      e5:	push   rbp
      e6:	mov    rbp,rsp
      e9:	call   ee <botlish_entry_1+0x9>
			ea: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_min_capacity<generic>
      ee:	mov    rsp,rbp
      f1:	pop    rbp
      f2:	ret

00000000000000f3 <botlish_fn_2: ht_empty_state<generic>>:
      f3:	push   rbp
      f4:	mov    rbp,rsp
      f7:	mov    r9,QWORD PTR [rdi]
      fa:	mov    r10,QWORD PTR [rdi+0x8]
      fe:	lea    r11,[r9+0x8]
     102:	cmp    r11,r10
     105:	ja     126 <botlish_fn_2+0x33>
     10b:	lea    r11,[r9+0x8]
     10f:	mov    QWORD PTR [rdi],r11
     112:	mov    QWORD PTR [r9],0x0
     119:	mov    QWORD PTR [rdi],r9
     11c:	mov    eax,0x1
     121:	mov    rsp,rbp
     124:	pop    rbp
     125:	ret
     126:	call   12b <botlish_fn_2+0x38>
			127: R_X86_64_PLT32	rt_stack_overflow-0x4
     12b:	xor    rax,rax
     12e:	mov    rsp,rbp
     131:	pop    rbp
     132:	ret

0000000000000133 <botlish_entry_2: ht_empty_state<generic>>:
     133:	push   rbp
     134:	mov    rbp,rsp
     137:	call   13c <botlish_entry_2+0x9>
			138: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     13c:	mov    rsp,rbp
     13f:	pop    rbp
     140:	ret

0000000000000141 <botlish_fn_3: ht_occupied_state<generic>>:
     141:	push   rbp
     142:	mov    rbp,rsp
     145:	mov    r9,QWORD PTR [rdi]
     148:	mov    r10,QWORD PTR [rdi+0x8]
     14c:	lea    r11,[r9+0x8]
     150:	cmp    r11,r10
     153:	ja     174 <botlish_fn_3+0x33>
     159:	lea    r11,[r9+0x8]
     15d:	mov    QWORD PTR [rdi],r11
     160:	mov    QWORD PTR [r9],0x0
     167:	mov    QWORD PTR [rdi],r9
     16a:	mov    eax,0x3
     16f:	mov    rsp,rbp
     172:	pop    rbp
     173:	ret
     174:	call   179 <botlish_fn_3+0x38>
			175: R_X86_64_PLT32	rt_stack_overflow-0x4
     179:	xor    rax,rax
     17c:	mov    rsp,rbp
     17f:	pop    rbp
     180:	ret

0000000000000181 <botlish_entry_3: ht_occupied_state<generic>>:
     181:	push   rbp
     182:	mov    rbp,rsp
     185:	call   18a <botlish_entry_3+0x9>
			186: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     18a:	mov    rsp,rbp
     18d:	pop    rbp
     18e:	ret

000000000000018f <botlish_fn_4: ht_tombstone_state<generic>>:
     18f:	push   rbp
     190:	mov    rbp,rsp
     193:	mov    r9,QWORD PTR [rdi]
     196:	mov    r10,QWORD PTR [rdi+0x8]
     19a:	lea    r11,[r9+0x8]
     19e:	cmp    r11,r10
     1a1:	ja     1c2 <botlish_fn_4+0x33>
     1a7:	lea    r11,[r9+0x8]
     1ab:	mov    QWORD PTR [rdi],r11
     1ae:	mov    QWORD PTR [r9],0x0
     1b5:	mov    QWORD PTR [rdi],r9
     1b8:	mov    eax,0x5
     1bd:	mov    rsp,rbp
     1c0:	pop    rbp
     1c1:	ret
     1c2:	call   1c7 <botlish_fn_4+0x38>
			1c3: R_X86_64_PLT32	rt_stack_overflow-0x4
     1c7:	xor    rax,rax
     1ca:	mov    rsp,rbp
     1cd:	pop    rbp
     1ce:	ret

00000000000001cf <botlish_entry_4: ht_tombstone_state<generic>>:
     1cf:	push   rbp
     1d0:	mov    rbp,rsp
     1d3:	call   1d8 <botlish_entry_4+0x9>
			1d4: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
     1d8:	mov    rsp,rbp
     1db:	pop    rbp
     1dc:	ret
     1dd:	add    BYTE PTR [rax],al
	...

00000000000001e0 <botlish_fn_5: ht_fill_empty<mutarray, int, int>>:
     1e0:	push   rbp
     1e1:	mov    rbp,rsp
     1e4:	sub    rsp,0x30
     1e8:	mov    QWORD PTR [rsp],rbx
     1ec:	mov    QWORD PTR [rsp+0x8],r12
     1f1:	mov    QWORD PTR [rsp+0x10],r13
     1f6:	mov    QWORD PTR [rsp+0x18],r14
     1fb:	mov    QWORD PTR [rsp+0x20],r15
     200:	mov    r13,QWORD PTR [rdi]
     203:	mov    r8,QWORD PTR [rdi+0x8]
     207:	lea    rax,[r13+0x20]
     20b:	cmp    rax,r8
     20e:	ja     390 <botlish_fn_5+0x1b0>
     214:	lea    rax,[r13+0x20]
     218:	mov    QWORD PTR [rdi],rax
     21b:	mov    r14,rdi
     21e:	mov    QWORD PTR [r13+0x0],0x0
     226:	mov    QWORD PTR [r13+0x8],0x0
     22e:	mov    QWORD PTR [r13+0x10],0x0
     236:	mov    QWORD PTR [r13+0x18],0x0
     23e:	mov    QWORD PTR [r13+0x0],rsi
     242:	mov    r12,rsi
     245:	mov    QWORD PTR [r13+0x8],rdx
     249:	mov    QWORD PTR [r13+0x10],rcx
     24d:	mov    rbx,rcx
     250:	mov    rsi,rdx
     253:	mov    rax,rsi
     256:	and    rax,rbx
     259:	mov    r15,rsi
     25c:	test   rax,0x1
     262:	jne    28b <botlish_fn_5+0xab>
     268:	mov    rdx,rbx
     26b:	mov    rsi,r15
     26e:	mov    rdi,r14
     271:	call   276 <botlish_fn_5+0x96>
			272: R_X86_64_PLT32	rt_int_cmp-0x4
     276:	mov    ecx,0x2
     27b:	test   rax,rax
     27e:	cmovge rcx,QWORD PTR [rip+0x13a]        # 3c0 <botlish_fn_5+0x1e0>
     286:	jmp    29e <botlish_fn_5+0xbe>
     28b:	mov    ecx,0x2
     290:	mov    rsi,r15
     293:	cmp    rsi,rbx
     296:	cmovge rcx,QWORD PTR [rip+0x122]        # 3c0 <botlish_fn_5+0x1e0>
     29e:	cmp    rcx,0x6
     2a2:	je     364 <botlish_fn_5+0x184>
     2a8:	mov    rdi,r14
     2ab:	call   2b0 <botlish_fn_5+0xd0>
			2ac: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     2b0:	test   rax,rax
     2b3:	mov    rcx,rax
     2b6:	jne    2c4 <botlish_fn_5+0xe4>
     2bc:	mov    rdi,r14
     2bf:	jmp    2de <botlish_fn_5+0xfe>
     2c4:	mov    rdx,r15
     2c7:	mov    rsi,r12
     2ca:	mov    rdi,r14
     2cd:	call   2d2 <botlish_fn_5+0xf2>
			2ce: R_X86_64_PLT32	rt_mutarray_set-0x4
     2d2:	test   rax,rax
     2d5:	jne    308 <botlish_fn_5+0x128>
     2db:	mov    rdi,r14
     2de:	mov    rdi,r14
     2e1:	mov    QWORD PTR [rdi],r13
     2e4:	xor    rax,rax
     2e7:	mov    rbx,QWORD PTR [rsp]
     2eb:	mov    r12,QWORD PTR [rsp+0x8]
     2f0:	mov    r13,QWORD PTR [rsp+0x10]
     2f5:	mov    r14,QWORD PTR [rsp+0x18]
     2fa:	mov    r15,QWORD PTR [rsp+0x20]
     2ff:	add    rsp,0x30
     303:	mov    rsp,rbp
     306:	pop    rbp
     307:	ret
     308:	mov    QWORD PTR [r13+0x18],0x3
     310:	mov    rsi,r15
     313:	test   rsi,0x1
     31a:	je     33d <botlish_fn_5+0x15d>
     320:	mov    rsi,r15
     323:	mov    rcx,rsi
     326:	add    rcx,0x2
     32a:	seto   al
     32d:	test   al,al
     32f:	jne    33d <botlish_fn_5+0x15d>
     335:	mov    r15,rcx
     338:	jmp    350 <botlish_fn_5+0x170>
     33d:	mov    edx,0x3
     342:	mov    rsi,r15
     345:	mov    rdi,r14
     348:	call   34d <botlish_fn_5+0x16d>
			349: R_X86_64_PLT32	rt_int_add-0x4
     34d:	mov    r15,rax
     350:	mov    QWORD PTR [r13+0x0],r12
     354:	mov    rsi,r15
     357:	mov    QWORD PTR [r13+0x8],rsi
     35b:	mov    QWORD PTR [r13+0x10],rbx
     35f:	jmp    253 <botlish_fn_5+0x73>
     364:	mov    rdi,r14
     367:	mov    QWORD PTR [rdi],r13
     36a:	mov    eax,0xa
     36f:	mov    rbx,QWORD PTR [rsp]
     373:	mov    r12,QWORD PTR [rsp+0x8]
     378:	mov    r13,QWORD PTR [rsp+0x10]
     37d:	mov    r14,QWORD PTR [rsp+0x18]
     382:	mov    r15,QWORD PTR [rsp+0x20]
     387:	add    rsp,0x30
     38b:	mov    rsp,rbp
     38e:	pop    rbp
     38f:	ret
     390:	mov    r14,rdi
     393:	call   398 <botlish_fn_5+0x1b8>
			394: R_X86_64_PLT32	rt_stack_overflow-0x4
     398:	xor    rax,rax
     39b:	mov    rbx,QWORD PTR [rsp]
     39f:	mov    r12,QWORD PTR [rsp+0x8]
     3a4:	mov    r13,QWORD PTR [rsp+0x10]
     3a9:	mov    r14,QWORD PTR [rsp+0x18]
     3ae:	mov    r15,QWORD PTR [rsp+0x20]
     3b3:	add    rsp,0x30
     3b7:	mov    rsp,rbp
     3ba:	pop    rbp
     3bb:	ret
     3bc:	add    BYTE PTR [rax],al
     3be:	add    BYTE PTR [rax],al
     3c0:	(bad)
     3c1:	add    BYTE PTR [rax],al
     3c3:	add    BYTE PTR [rax],al
     3c5:	add    BYTE PTR [rax],al
	...

00000000000003c8 <botlish_entry_5: ht_fill_empty<mutarray, int, int>>:
     3c8:	push   rbp
     3c9:	mov    rbp,rsp
     3cc:	mov    rsi,QWORD PTR [rdx]
     3cf:	mov    r8,QWORD PTR [rdx+0x8]
     3d3:	mov    rcx,QWORD PTR [rdx+0x10]
     3d7:	mov    rdx,r8
     3da:	call   3df <botlish_entry_5+0x17>
			3db: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     3df:	mov    rsp,rbp
     3e2:	pop    rbp
     3e3:	ret

00000000000003e4 <botlish_fn_6: ht_alloc<int>>:
     3e4:	push   rbp
     3e5:	mov    rbp,rsp
     3e8:	sub    rsp,0x40
     3ec:	mov    QWORD PTR [rsp+0x10],rbx
     3f1:	mov    QWORD PTR [rsp+0x18],r12
     3f6:	mov    QWORD PTR [rsp+0x20],r13
     3fb:	mov    QWORD PTR [rsp+0x28],r14
     400:	mov    QWORD PTR [rsp+0x30],r15
     405:	mov    rbx,QWORD PTR [rdi]
     408:	mov    rax,QWORD PTR [rdi+0x8]
     40c:	lea    rcx,[rbx+0x20]
     410:	cmp    rcx,rax
     413:	ja     615 <botlish_fn_6+0x231>
     419:	lea    rax,[rbx+0x20]
     41d:	mov    QWORD PTR [rdi],rax
     420:	mov    r12,rdi
     423:	mov    QWORD PTR [rbx],0x0
     42a:	mov    QWORD PTR [rbx+0x8],0x0
     432:	mov    QWORD PTR [rbx+0x10],0x0
     43a:	mov    QWORD PTR [rbx+0x18],0x0
     442:	mov    QWORD PTR [rbx],rsi
     445:	mov    r13,rsi
     448:	mov    rsi,r13
     44b:	mov    rdi,r12
     44e:	call   453 <botlish_fn_6+0x6f>
			44f: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     453:	test   rax,rax
     456:	jne    464 <botlish_fn_6+0x80>
     45c:	mov    rdi,r12
     45f:	jmp    5be <botlish_fn_6+0x1da>
     464:	mov    QWORD PTR [rbx+0x8],rax
     468:	mov    r14,rax
     46b:	mov    edx,0x1
     470:	mov    QWORD PTR [rbx+0x10],0x1
     478:	mov    rcx,r13
     47b:	mov    rsi,r14
     47e:	mov    rdi,r12
     481:	call   486 <botlish_fn_6+0xa2>
			482: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
     486:	test   rax,rax
     489:	jne    497 <botlish_fn_6+0xb3>
     48f:	mov    rdi,r12
     492:	jmp    5be <botlish_fn_6+0x1da>
     497:	mov    rsi,r13
     49a:	mov    rdi,r12
     49d:	call   4a2 <botlish_fn_6+0xbe>
			49e: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     4a2:	test   rax,rax
     4a5:	jne    4b3 <botlish_fn_6+0xcf>
     4ab:	mov    rdi,r12
     4ae:	jmp    5be <botlish_fn_6+0x1da>
     4b3:	mov    QWORD PTR [rbx+0x10],rax
     4b7:	mov    rsi,r13
     4ba:	mov    r15,rax
     4bd:	mov    rdi,r12
     4c0:	call   4c5 <botlish_fn_6+0xe1>
			4c1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     4c5:	test   rax,rax
     4c8:	jne    4d6 <botlish_fn_6+0xf2>
     4ce:	mov    rdi,r12
     4d1:	jmp    5be <botlish_fn_6+0x1da>
     4d6:	mov    QWORD PTR [rbx],rax
     4d9:	mov    r13,rax
     4dc:	mov    esi,0xb
     4e1:	mov    QWORD PTR [rbx+0x18],0xb
     4e9:	mov    rdi,r12
     4ec:	call   4f1 <botlish_fn_6+0x10d>
			4ed: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     4f1:	test   rax,rax
     4f4:	mov    QWORD PTR [rsp],rax
     4f8:	jne    506 <botlish_fn_6+0x122>
     4fe:	mov    rdi,r12
     501:	jmp    5be <botlish_fn_6+0x1da>
     506:	mov    edx,0x1
     50b:	mov    rcx,r14
     50e:	mov    rsi,QWORD PTR [rsp]
     512:	mov    rdi,r12
     515:	call   51a <botlish_fn_6+0x136>
			516: R_X86_64_PLT32	rt_mutarray_set-0x4
     51a:	test   rax,rax
     51d:	jne    52b <botlish_fn_6+0x147>
     523:	mov    rdi,r12
     526:	jmp    5be <botlish_fn_6+0x1da>
     52b:	mov    edx,0x3
     530:	mov    rcx,r15
     533:	mov    rsi,QWORD PTR [rsp]
     537:	mov    rdi,r12
     53a:	call   53f <botlish_fn_6+0x15b>
			53b: R_X86_64_PLT32	rt_mutarray_set-0x4
     53f:	test   rax,rax
     542:	jne    550 <botlish_fn_6+0x16c>
     548:	mov    rdi,r12
     54b:	jmp    5be <botlish_fn_6+0x1da>
     550:	mov    edx,0x5
     555:	mov    rcx,r13
     558:	mov    rsi,QWORD PTR [rsp]
     55c:	mov    rdi,r12
     55f:	call   564 <botlish_fn_6+0x180>
			560: R_X86_64_PLT32	rt_mutarray_set-0x4
     564:	test   rax,rax
     567:	jne    575 <botlish_fn_6+0x191>
     56d:	mov    rdi,r12
     570:	jmp    5be <botlish_fn_6+0x1da>
     575:	mov    edx,0x7
     57a:	mov    ecx,0x1
     57f:	mov    rsi,QWORD PTR [rsp]
     583:	mov    rdi,r12
     586:	call   58b <botlish_fn_6+0x1a7>
			587: R_X86_64_PLT32	rt_mutarray_set-0x4
     58b:	test   rax,rax
     58e:	jne    59c <botlish_fn_6+0x1b8>
     594:	mov    rdi,r12
     597:	jmp    5be <botlish_fn_6+0x1da>
     59c:	mov    edx,0x9
     5a1:	mov    ecx,0x1
     5a6:	mov    rsi,QWORD PTR [rsp]
     5aa:	mov    rdi,r12
     5ad:	call   5b2 <botlish_fn_6+0x1ce>
			5ae: R_X86_64_PLT32	rt_mutarray_set-0x4
     5b2:	test   rax,rax
     5b5:	jne    5e9 <botlish_fn_6+0x205>
     5bb:	mov    rdi,r12
     5be:	mov    rdi,r12
     5c1:	mov    QWORD PTR [rdi],rbx
     5c4:	xor    rax,rax
     5c7:	mov    rbx,QWORD PTR [rsp+0x10]
     5cc:	mov    r12,QWORD PTR [rsp+0x18]
     5d1:	mov    r13,QWORD PTR [rsp+0x20]
     5d6:	mov    r14,QWORD PTR [rsp+0x28]
     5db:	mov    r15,QWORD PTR [rsp+0x30]
     5e0:	add    rsp,0x40
     5e4:	mov    rsp,rbp
     5e7:	pop    rbp
     5e8:	ret
     5e9:	mov    rdi,r12
     5ec:	mov    QWORD PTR [rdi],rbx
     5ef:	mov    rax,QWORD PTR [rsp]
     5f3:	mov    rbx,QWORD PTR [rsp+0x10]
     5f8:	mov    r12,QWORD PTR [rsp+0x18]
     5fd:	mov    r13,QWORD PTR [rsp+0x20]
     602:	mov    r14,QWORD PTR [rsp+0x28]
     607:	mov    r15,QWORD PTR [rsp+0x30]
     60c:	add    rsp,0x40
     610:	mov    rsp,rbp
     613:	pop    rbp
     614:	ret
     615:	mov    r12,rdi
     618:	call   61d <botlish_fn_6+0x239>
			619: R_X86_64_PLT32	rt_stack_overflow-0x4
     61d:	xor    rax,rax
     620:	mov    rbx,QWORD PTR [rsp+0x10]
     625:	mov    r12,QWORD PTR [rsp+0x18]
     62a:	mov    r13,QWORD PTR [rsp+0x20]
     62f:	mov    r14,QWORD PTR [rsp+0x28]
     634:	mov    r15,QWORD PTR [rsp+0x30]
     639:	add    rsp,0x40
     63d:	mov    rsp,rbp
     640:	pop    rbp
     641:	ret

0000000000000642 <botlish_entry_6: ht_alloc<int>>:
     642:	push   rbp
     643:	mov    rbp,rsp
     646:	mov    rsi,QWORD PTR [rdx]
     649:	call   64e <botlish_entry_6+0xc>
			64a: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     64e:	mov    rsp,rbp
     651:	pop    rbp
     652:	ret

0000000000000653 <botlish_fn_7: ht_new<generic>>:
     653:	push   rbp
     654:	mov    rbp,rsp
     657:	sub    rsp,0x10
     65b:	mov    QWORD PTR [rsp],r12
     65f:	mov    QWORD PTR [rsp+0x8],r13
     664:	mov    r12,QWORD PTR [rdi]
     667:	mov    rax,QWORD PTR [rdi+0x8]
     66b:	lea    rcx,[r12+0x8]
     670:	cmp    rcx,rax
     673:	ja     6f3 <botlish_fn_7+0xa0>
     679:	lea    rax,[r12+0x8]
     67e:	mov    QWORD PTR [rdi],rax
     681:	mov    r13,rdi
     684:	mov    QWORD PTR [r12],0x0
     68c:	mov    rdi,r13
     68f:	call   694 <botlish_fn_7+0x41>
			690: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_min_capacity<generic>
     694:	test   rax,rax
     697:	jne    6a5 <botlish_fn_7+0x52>
     69d:	mov    rdi,r13
     6a0:	jmp    6c0 <botlish_fn_7+0x6d>
     6a5:	mov    QWORD PTR [r12],rax
     6a9:	mov    rsi,rax
     6ac:	mov    rdi,r13
     6af:	call   6b4 <botlish_fn_7+0x61>
			6b0: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_alloc<int>
     6b4:	test   rax,rax
     6b7:	jne    6db <botlish_fn_7+0x88>
     6bd:	mov    rdi,r13
     6c0:	mov    rdi,r13
     6c3:	mov    QWORD PTR [rdi],r12
     6c6:	xor    rax,rax
     6c9:	mov    r12,QWORD PTR [rsp]
     6cd:	mov    r13,QWORD PTR [rsp+0x8]
     6d2:	add    rsp,0x10
     6d6:	mov    rsp,rbp
     6d9:	pop    rbp
     6da:	ret
     6db:	mov    rdi,r13
     6de:	mov    QWORD PTR [rdi],r12
     6e1:	mov    r12,QWORD PTR [rsp]
     6e5:	mov    r13,QWORD PTR [rsp+0x8]
     6ea:	add    rsp,0x10
     6ee:	mov    rsp,rbp
     6f1:	pop    rbp
     6f2:	ret
     6f3:	mov    r13,rdi
     6f6:	call   6fb <botlish_fn_7+0xa8>
			6f7: R_X86_64_PLT32	rt_stack_overflow-0x4
     6fb:	xor    rax,rax
     6fe:	mov    r12,QWORD PTR [rsp]
     702:	mov    r13,QWORD PTR [rsp+0x8]
     707:	add    rsp,0x10
     70b:	mov    rsp,rbp
     70e:	pop    rbp
     70f:	ret

0000000000000710 <botlish_entry_7: ht_new<generic>>:
     710:	push   rbp
     711:	mov    rbp,rsp
     714:	call   719 <botlish_entry_7+0x9>
			715: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
     719:	mov    rsp,rbp
     71c:	pop    rbp
     71d:	ret

000000000000071e <botlish_fn_8: ht_controls<mutarray>>:
     71e:	push   rbp
     71f:	mov    rbp,rsp
     722:	sub    rsp,0x10
     726:	mov    QWORD PTR [rsp],r13
     72a:	mov    QWORD PTR [rsp+0x8],r14
     72f:	mov    r13,QWORD PTR [rdi]
     732:	mov    rax,QWORD PTR [rdi+0x8]
     736:	lea    rcx,[r13+0x8]
     73a:	cmp    rcx,rax
     73d:	ja     79e <botlish_fn_8+0x80>
     743:	lea    rax,[r13+0x8]
     747:	mov    QWORD PTR [rdi],rax
     74a:	mov    r14,rdi
     74d:	mov    QWORD PTR [r13+0x0],0x0
     755:	mov    edx,0x1
     75a:	mov    rdi,r14
     75d:	call   762 <botlish_fn_8+0x44>
			75e: R_X86_64_PLT32	rt_mutarray_get-0x4
     762:	test   rax,rax
     765:	jne    786 <botlish_fn_8+0x68>
     76b:	mov    rdi,r14
     76e:	mov    QWORD PTR [rdi],r13
     771:	xor    rax,rax
     774:	mov    r13,QWORD PTR [rsp]
     778:	mov    r14,QWORD PTR [rsp+0x8]
     77d:	add    rsp,0x10
     781:	mov    rsp,rbp
     784:	pop    rbp
     785:	ret
     786:	mov    rdi,r14
     789:	mov    QWORD PTR [rdi],r13
     78c:	mov    r13,QWORD PTR [rsp]
     790:	mov    r14,QWORD PTR [rsp+0x8]
     795:	add    rsp,0x10
     799:	mov    rsp,rbp
     79c:	pop    rbp
     79d:	ret
     79e:	call   7a3 <botlish_fn_8+0x85>
			79f: R_X86_64_PLT32	rt_stack_overflow-0x4
     7a3:	xor    rax,rax
     7a6:	mov    r13,QWORD PTR [rsp]
     7aa:	mov    r14,QWORD PTR [rsp+0x8]
     7af:	add    rsp,0x10
     7b3:	mov    rsp,rbp
     7b6:	pop    rbp
     7b7:	ret

00000000000007b8 <botlish_entry_8: ht_controls<mutarray>>:
     7b8:	push   rbp
     7b9:	mov    rbp,rsp
     7bc:	mov    rsi,QWORD PTR [rdx]
     7bf:	call   7c4 <botlish_entry_8+0xc>
			7c0: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     7c4:	mov    rsp,rbp
     7c7:	pop    rbp
     7c8:	ret

00000000000007c9 <botlish_fn_9: ht_keys<mutarray>>:
     7c9:	push   rbp
     7ca:	mov    rbp,rsp
     7cd:	sub    rsp,0x10
     7d1:	mov    QWORD PTR [rsp],r13
     7d5:	mov    QWORD PTR [rsp+0x8],r14
     7da:	mov    r13,QWORD PTR [rdi]
     7dd:	mov    rax,QWORD PTR [rdi+0x8]
     7e1:	lea    rcx,[r13+0x8]
     7e5:	cmp    rcx,rax
     7e8:	ja     849 <botlish_fn_9+0x80>
     7ee:	lea    rax,[r13+0x8]
     7f2:	mov    QWORD PTR [rdi],rax
     7f5:	mov    r14,rdi
     7f8:	mov    QWORD PTR [r13+0x0],0x0
     800:	mov    edx,0x3
     805:	mov    rdi,r14
     808:	call   80d <botlish_fn_9+0x44>
			809: R_X86_64_PLT32	rt_mutarray_get-0x4
     80d:	test   rax,rax
     810:	jne    831 <botlish_fn_9+0x68>
     816:	mov    rdi,r14
     819:	mov    QWORD PTR [rdi],r13
     81c:	xor    rax,rax
     81f:	mov    r13,QWORD PTR [rsp]
     823:	mov    r14,QWORD PTR [rsp+0x8]
     828:	add    rsp,0x10
     82c:	mov    rsp,rbp
     82f:	pop    rbp
     830:	ret
     831:	mov    rdi,r14
     834:	mov    QWORD PTR [rdi],r13
     837:	mov    r13,QWORD PTR [rsp]
     83b:	mov    r14,QWORD PTR [rsp+0x8]
     840:	add    rsp,0x10
     844:	mov    rsp,rbp
     847:	pop    rbp
     848:	ret
     849:	call   84e <botlish_fn_9+0x85>
			84a: R_X86_64_PLT32	rt_stack_overflow-0x4
     84e:	xor    rax,rax
     851:	mov    r13,QWORD PTR [rsp]
     855:	mov    r14,QWORD PTR [rsp+0x8]
     85a:	add    rsp,0x10
     85e:	mov    rsp,rbp
     861:	pop    rbp
     862:	ret

0000000000000863 <botlish_entry_9: ht_keys<mutarray>>:
     863:	push   rbp
     864:	mov    rbp,rsp
     867:	mov    rsi,QWORD PTR [rdx]
     86a:	call   86f <botlish_entry_9+0xc>
			86b: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     86f:	mov    rsp,rbp
     872:	pop    rbp
     873:	ret

0000000000000874 <botlish_fn_10: ht_values<mutarray>>:
     874:	push   rbp
     875:	mov    rbp,rsp
     878:	sub    rsp,0x10
     87c:	mov    QWORD PTR [rsp],r13
     880:	mov    QWORD PTR [rsp+0x8],r14
     885:	mov    r13,QWORD PTR [rdi]
     888:	mov    rax,QWORD PTR [rdi+0x8]
     88c:	lea    rcx,[r13+0x8]
     890:	cmp    rcx,rax
     893:	ja     8f4 <botlish_fn_10+0x80>
     899:	lea    rax,[r13+0x8]
     89d:	mov    QWORD PTR [rdi],rax
     8a0:	mov    r14,rdi
     8a3:	mov    QWORD PTR [r13+0x0],0x0
     8ab:	mov    edx,0x5
     8b0:	mov    rdi,r14
     8b3:	call   8b8 <botlish_fn_10+0x44>
			8b4: R_X86_64_PLT32	rt_mutarray_get-0x4
     8b8:	test   rax,rax
     8bb:	jne    8dc <botlish_fn_10+0x68>
     8c1:	mov    rdi,r14
     8c4:	mov    QWORD PTR [rdi],r13
     8c7:	xor    rax,rax
     8ca:	mov    r13,QWORD PTR [rsp]
     8ce:	mov    r14,QWORD PTR [rsp+0x8]
     8d3:	add    rsp,0x10
     8d7:	mov    rsp,rbp
     8da:	pop    rbp
     8db:	ret
     8dc:	mov    rdi,r14
     8df:	mov    QWORD PTR [rdi],r13
     8e2:	mov    r13,QWORD PTR [rsp]
     8e6:	mov    r14,QWORD PTR [rsp+0x8]
     8eb:	add    rsp,0x10
     8ef:	mov    rsp,rbp
     8f2:	pop    rbp
     8f3:	ret
     8f4:	call   8f9 <botlish_fn_10+0x85>
			8f5: R_X86_64_PLT32	rt_stack_overflow-0x4
     8f9:	xor    rax,rax
     8fc:	mov    r13,QWORD PTR [rsp]
     900:	mov    r14,QWORD PTR [rsp+0x8]
     905:	add    rsp,0x10
     909:	mov    rsp,rbp
     90c:	pop    rbp
     90d:	ret

000000000000090e <botlish_entry_10: ht_values<mutarray>>:
     90e:	push   rbp
     90f:	mov    rbp,rsp
     912:	mov    rsi,QWORD PTR [rdx]
     915:	call   91a <botlish_entry_10+0xc>
			916: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
     91a:	mov    rsp,rbp
     91d:	pop    rbp
     91e:	ret

000000000000091f <botlish_fn_11: ht_size<mutarray>>:
     91f:	push   rbp
     920:	mov    rbp,rsp
     923:	sub    rsp,0x10
     927:	mov    QWORD PTR [rsp],r13
     92b:	mov    QWORD PTR [rsp+0x8],r14
     930:	mov    r13,QWORD PTR [rdi]
     933:	mov    rax,QWORD PTR [rdi+0x8]
     937:	lea    rcx,[r13+0x8]
     93b:	cmp    rcx,rax
     93e:	ja     99f <botlish_fn_11+0x80>
     944:	lea    rax,[r13+0x8]
     948:	mov    QWORD PTR [rdi],rax
     94b:	mov    r14,rdi
     94e:	mov    QWORD PTR [r13+0x0],0x0
     956:	mov    edx,0x7
     95b:	mov    rdi,r14
     95e:	call   963 <botlish_fn_11+0x44>
			95f: R_X86_64_PLT32	rt_mutarray_get-0x4
     963:	test   rax,rax
     966:	jne    987 <botlish_fn_11+0x68>
     96c:	mov    rdi,r14
     96f:	mov    QWORD PTR [rdi],r13
     972:	xor    rax,rax
     975:	mov    r13,QWORD PTR [rsp]
     979:	mov    r14,QWORD PTR [rsp+0x8]
     97e:	add    rsp,0x10
     982:	mov    rsp,rbp
     985:	pop    rbp
     986:	ret
     987:	mov    rdi,r14
     98a:	mov    QWORD PTR [rdi],r13
     98d:	mov    r13,QWORD PTR [rsp]
     991:	mov    r14,QWORD PTR [rsp+0x8]
     996:	add    rsp,0x10
     99a:	mov    rsp,rbp
     99d:	pop    rbp
     99e:	ret
     99f:	call   9a4 <botlish_fn_11+0x85>
			9a0: R_X86_64_PLT32	rt_stack_overflow-0x4
     9a4:	xor    rax,rax
     9a7:	mov    r13,QWORD PTR [rsp]
     9ab:	mov    r14,QWORD PTR [rsp+0x8]
     9b0:	add    rsp,0x10
     9b4:	mov    rsp,rbp
     9b7:	pop    rbp
     9b8:	ret

00000000000009b9 <botlish_entry_11: ht_size<mutarray>>:
     9b9:	push   rbp
     9ba:	mov    rbp,rsp
     9bd:	mov    rsi,QWORD PTR [rdx]
     9c0:	call   9c5 <botlish_entry_11+0xc>
			9c1: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
     9c5:	mov    rsp,rbp
     9c8:	pop    rbp
     9c9:	ret

00000000000009ca <botlish_fn_12: ht_tombstones<mutarray>>:
     9ca:	push   rbp
     9cb:	mov    rbp,rsp
     9ce:	sub    rsp,0x10
     9d2:	mov    QWORD PTR [rsp],r13
     9d6:	mov    QWORD PTR [rsp+0x8],r14
     9db:	mov    r13,QWORD PTR [rdi]
     9de:	mov    rax,QWORD PTR [rdi+0x8]
     9e2:	lea    rcx,[r13+0x8]
     9e6:	cmp    rcx,rax
     9e9:	ja     a4a <botlish_fn_12+0x80>
     9ef:	lea    rax,[r13+0x8]
     9f3:	mov    QWORD PTR [rdi],rax
     9f6:	mov    r14,rdi
     9f9:	mov    QWORD PTR [r13+0x0],0x0
     a01:	mov    edx,0x9
     a06:	mov    rdi,r14
     a09:	call   a0e <botlish_fn_12+0x44>
			a0a: R_X86_64_PLT32	rt_mutarray_get-0x4
     a0e:	test   rax,rax
     a11:	jne    a32 <botlish_fn_12+0x68>
     a17:	mov    rdi,r14
     a1a:	mov    QWORD PTR [rdi],r13
     a1d:	xor    rax,rax
     a20:	mov    r13,QWORD PTR [rsp]
     a24:	mov    r14,QWORD PTR [rsp+0x8]
     a29:	add    rsp,0x10
     a2d:	mov    rsp,rbp
     a30:	pop    rbp
     a31:	ret
     a32:	mov    rdi,r14
     a35:	mov    QWORD PTR [rdi],r13
     a38:	mov    r13,QWORD PTR [rsp]
     a3c:	mov    r14,QWORD PTR [rsp+0x8]
     a41:	add    rsp,0x10
     a45:	mov    rsp,rbp
     a48:	pop    rbp
     a49:	ret
     a4a:	call   a4f <botlish_fn_12+0x85>
			a4b: R_X86_64_PLT32	rt_stack_overflow-0x4
     a4f:	xor    rax,rax
     a52:	mov    r13,QWORD PTR [rsp]
     a56:	mov    r14,QWORD PTR [rsp+0x8]
     a5b:	add    rsp,0x10
     a5f:	mov    rsp,rbp
     a62:	pop    rbp
     a63:	ret

0000000000000a64 <botlish_entry_12: ht_tombstones<mutarray>>:
     a64:	push   rbp
     a65:	mov    rbp,rsp
     a68:	mov    rsi,QWORD PTR [rdx]
     a6b:	call   a70 <botlish_entry_12+0xc>
			a6c: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
     a70:	mov    rsp,rbp
     a73:	pop    rbp
     a74:	ret

0000000000000a75 <botlish_fn_13: ht_capacity<mutarray>>:
     a75:	push   rbp
     a76:	mov    rbp,rsp
     a79:	sub    rsp,0x10
     a7d:	mov    QWORD PTR [rsp],rbx
     a81:	mov    QWORD PTR [rsp+0x8],r12
     a86:	mov    rbx,QWORD PTR [rdi]
     a89:	mov    rax,QWORD PTR [rdi+0x8]
     a8d:	lea    rcx,[rbx+0x8]
     a91:	cmp    rcx,rax
     a94:	ja     b3e <botlish_fn_13+0xc9>
     a9a:	lea    rax,[rbx+0x8]
     a9e:	mov    QWORD PTR [rdi],rax
     aa1:	mov    r12,rdi
     aa4:	mov    QWORD PTR [rbx],rsi
     aa7:	mov    rdi,r12
     aaa:	call   aaf <botlish_fn_13+0x3a>
			aab: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     aaf:	test   rax,rax
     ab2:	jne    ac0 <botlish_fn_13+0x4b>
     ab8:	mov    rdi,r12
     abb:	jmp    b03 <botlish_fn_13+0x8e>
     ac0:	xor    ecx,ecx
     ac2:	test   rax,0x7
     ac8:	je     ad6 <botlish_fn_13+0x61>
     ace:	mov    rsi,rax
     ad1:	jmp    ae4 <botlish_fn_13+0x6f>
     ad6:	movzx  rcx,BYTE PTR [rax]
     ada:	mov    rsi,rax
     add:	rex cmp cl,0x8
     ae1:	sete   cl
     ae4:	test   cl,cl
     ae6:	jne    b1e <botlish_fn_13+0xa9>
     aec:	mov    rdi,r12
     aef:	mov    rax,QWORD PTR [rdi+0x10]
     af3:	mov    rcx,QWORD PTR [rax]
     af6:	mov    edx,0x8
     afb:	call   b00 <botlish_fn_13+0x8b>
			afc: R_X86_64_PLT32	rt_type_error-0x4
     b00:	mov    rdi,r12
     b03:	mov    rdi,r12
     b06:	mov    QWORD PTR [rdi],rbx
     b09:	xor    rax,rax
     b0c:	mov    rbx,QWORD PTR [rsp]
     b10:	mov    r12,QWORD PTR [rsp+0x8]
     b15:	add    rsp,0x10
     b19:	mov    rsp,rbp
     b1c:	pop    rbp
     b1d:	ret
     b1e:	mov    rdi,r12
     b21:	call   b26 <botlish_fn_13+0xb1>
			b22: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     b26:	mov    rdi,r12
     b29:	mov    QWORD PTR [rdi],rbx
     b2c:	mov    rbx,QWORD PTR [rsp]
     b30:	mov    r12,QWORD PTR [rsp+0x8]
     b35:	add    rsp,0x10
     b39:	mov    rsp,rbp
     b3c:	pop    rbp
     b3d:	ret
     b3e:	mov    r12,rdi
     b41:	call   b46 <botlish_fn_13+0xd1>
			b42: R_X86_64_PLT32	rt_stack_overflow-0x4
     b46:	xor    rax,rax
     b49:	mov    rbx,QWORD PTR [rsp]
     b4d:	mov    r12,QWORD PTR [rsp+0x8]
     b52:	add    rsp,0x10
     b56:	mov    rsp,rbp
     b59:	pop    rbp
     b5a:	ret

0000000000000b5b <botlish_entry_13: ht_capacity<mutarray>>:
     b5b:	push   rbp
     b5c:	mov    rbp,rsp
     b5f:	mov    rsi,QWORD PTR [rdx]
     b62:	call   b67 <botlish_entry_13+0xc>
			b63: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     b67:	mov    rsp,rbp
     b6a:	pop    rbp
     b6b:	ret

0000000000000b6c <botlish_fn_14: ht_probe_start<mutarray, str>>:
     b6c:	push   rbp
     b6d:	mov    rbp,rsp
     b70:	sub    rsp,0x20
     b74:	mov    QWORD PTR [rsp],rbx
     b78:	mov    QWORD PTR [rsp+0x8],r12
     b7d:	mov    QWORD PTR [rsp+0x10],r15
     b82:	mov    r15,QWORD PTR [rdi]
     b85:	mov    rax,QWORD PTR [rdi+0x8]
     b89:	lea    rcx,[r15+0x10]
     b8d:	cmp    rcx,rax
     b90:	ja     c4b <botlish_fn_14+0xdf>
     b96:	lea    rax,[r15+0x10]
     b9a:	mov    QWORD PTR [rdi],rax
     b9d:	mov    rbx,rdi
     ba0:	mov    QWORD PTR [r15],0x0
     ba7:	mov    QWORD PTR [r15+0x8],0x0
     baf:	mov    QWORD PTR [r15],rsi
     bb2:	mov    r12,rsi
     bb5:	mov    rsi,rdx
     bb8:	mov    rdi,rbx
     bbb:	call   bc0 <botlish_fn_14+0x54>
			bbc: R_X86_64_PLT32	rt_hash-0x4
     bc0:	test   rax,rax
     bc3:	jne    bd1 <botlish_fn_14+0x65>
     bc9:	mov    rdi,rbx
     bcc:	jmp    c0e <botlish_fn_14+0xa2>
     bd1:	mov    QWORD PTR [r15+0x8],rax
     bd5:	mov    rsi,r12
     bd8:	mov    r12,rax
     bdb:	mov    rdi,rbx
     bde:	call   be3 <botlish_fn_14+0x77>
			bdf: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     be3:	test   rax,rax
     be6:	mov    rdx,rax
     be9:	jne    bf7 <botlish_fn_14+0x8b>
     bef:	mov    rdi,rbx
     bf2:	jmp    c0e <botlish_fn_14+0xa2>
     bf7:	mov    rsi,r12
     bfa:	mov    rdi,rbx
     bfd:	call   c02 <botlish_fn_14+0x96>
			bfe: R_X86_64_PLT32	rt_int_mod-0x4
     c02:	test   rax,rax
     c05:	jne    c2e <botlish_fn_14+0xc2>
     c0b:	mov    rdi,rbx
     c0e:	mov    rdi,rbx
     c11:	mov    QWORD PTR [rdi],r15
     c14:	xor    rax,rax
     c17:	mov    rbx,QWORD PTR [rsp]
     c1b:	mov    r12,QWORD PTR [rsp+0x8]
     c20:	mov    r15,QWORD PTR [rsp+0x10]
     c25:	add    rsp,0x20
     c29:	mov    rsp,rbp
     c2c:	pop    rbp
     c2d:	ret
     c2e:	mov    rdi,rbx
     c31:	mov    QWORD PTR [rdi],r15
     c34:	mov    rbx,QWORD PTR [rsp]
     c38:	mov    r12,QWORD PTR [rsp+0x8]
     c3d:	mov    r15,QWORD PTR [rsp+0x10]
     c42:	add    rsp,0x20
     c46:	mov    rsp,rbp
     c49:	pop    rbp
     c4a:	ret
     c4b:	mov    rbx,rdi
     c4e:	call   c53 <botlish_fn_14+0xe7>
			c4f: R_X86_64_PLT32	rt_stack_overflow-0x4
     c53:	xor    rax,rax
     c56:	mov    rbx,QWORD PTR [rsp]
     c5a:	mov    r12,QWORD PTR [rsp+0x8]
     c5f:	mov    r15,QWORD PTR [rsp+0x10]
     c64:	add    rsp,0x20
     c68:	mov    rsp,rbp
     c6b:	pop    rbp
     c6c:	ret

0000000000000c6d <botlish_entry_14: ht_probe_start<mutarray, str>>:
     c6d:	push   rbp
     c6e:	mov    rbp,rsp
     c71:	mov    rsi,QWORD PTR [rdx]
     c74:	mov    rdx,QWORD PTR [rdx+0x8]
     c78:	call   c7d <botlish_entry_14+0x10>
			c79: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
     c7d:	mov    rsp,rbp
     c80:	pop    rbp
     c81:	ret

0000000000000c82 <botlish_fn_15: ht_probe_next<mutarray, int>>:
     c82:	push   rbp
     c83:	mov    rbp,rsp
     c86:	sub    rsp,0x20
     c8a:	mov    QWORD PTR [rsp],rbx
     c8e:	mov    QWORD PTR [rsp+0x8],r12
     c93:	mov    QWORD PTR [rsp+0x10],r13
     c98:	mov    rbx,QWORD PTR [rdi]
     c9b:	mov    rax,QWORD PTR [rdi+0x8]
     c9f:	lea    rcx,[rbx+0x18]
     ca3:	cmp    rcx,rax
     ca6:	ja     d99 <botlish_fn_15+0x117>
     cac:	lea    rax,[rbx+0x18]
     cb0:	mov    QWORD PTR [rdi],rax
     cb3:	mov    r12,rdi
     cb6:	mov    QWORD PTR [rbx],0x0
     cbd:	mov    QWORD PTR [rbx+0x8],0x0
     cc5:	mov    QWORD PTR [rbx+0x10],0x0
     ccd:	mov    QWORD PTR [rbx],rsi
     cd0:	mov    r13,rsi
     cd3:	mov    QWORD PTR [rbx+0x8],rdx
     cd7:	mov    QWORD PTR [rbx+0x10],0x3
     cdf:	test   rdx,0x1
     ce6:	jne    cf4 <botlish_fn_15+0x72>
     cec:	mov    rcx,rdx
     cef:	jmp    d09 <botlish_fn_15+0x87>
     cf4:	mov    rsi,rdx
     cf7:	add    rsi,0x2
     cfb:	mov    rcx,rdx
     cfe:	seto   al
     d01:	test   al,al
     d03:	je     d1c <botlish_fn_15+0x9a>
     d09:	mov    edx,0x3
     d0e:	mov    rsi,rcx
     d11:	mov    rdi,r12
     d14:	call   d19 <botlish_fn_15+0x97>
			d15: R_X86_64_PLT32	rt_int_add-0x4
     d19:	mov    rsi,rax
     d1c:	mov    QWORD PTR [rbx+0x8],rsi
     d20:	mov    rax,rsi
     d23:	mov    rsi,r13
     d26:	mov    r13,rax
     d29:	mov    rdi,r12
     d2c:	call   d31 <botlish_fn_15+0xaf>
			d2d: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
     d31:	test   rax,rax
     d34:	mov    rdx,rax
     d37:	jne    d45 <botlish_fn_15+0xc3>
     d3d:	mov    rdi,r12
     d40:	jmp    d5c <botlish_fn_15+0xda>
     d45:	mov    rsi,r13
     d48:	mov    rdi,r12
     d4b:	call   d50 <botlish_fn_15+0xce>
			d4c: R_X86_64_PLT32	rt_int_mod-0x4
     d50:	test   rax,rax
     d53:	jne    d7c <botlish_fn_15+0xfa>
     d59:	mov    rdi,r12
     d5c:	mov    rdi,r12
     d5f:	mov    QWORD PTR [rdi],rbx
     d62:	xor    rax,rax
     d65:	mov    rbx,QWORD PTR [rsp]
     d69:	mov    r12,QWORD PTR [rsp+0x8]
     d6e:	mov    r13,QWORD PTR [rsp+0x10]
     d73:	add    rsp,0x20
     d77:	mov    rsp,rbp
     d7a:	pop    rbp
     d7b:	ret
     d7c:	mov    rdi,r12
     d7f:	mov    QWORD PTR [rdi],rbx
     d82:	mov    rbx,QWORD PTR [rsp]
     d86:	mov    r12,QWORD PTR [rsp+0x8]
     d8b:	mov    r13,QWORD PTR [rsp+0x10]
     d90:	add    rsp,0x20
     d94:	mov    rsp,rbp
     d97:	pop    rbp
     d98:	ret
     d99:	mov    r12,rdi
     d9c:	call   da1 <botlish_fn_15+0x11f>
			d9d: R_X86_64_PLT32	rt_stack_overflow-0x4
     da1:	xor    rax,rax
     da4:	mov    rbx,QWORD PTR [rsp]
     da8:	mov    r12,QWORD PTR [rsp+0x8]
     dad:	mov    r13,QWORD PTR [rsp+0x10]
     db2:	add    rsp,0x20
     db6:	mov    rsp,rbp
     db9:	pop    rbp
     dba:	ret

0000000000000dbb <botlish_entry_15: ht_probe_next<mutarray, int>>:
     dbb:	push   rbp
     dbc:	mov    rbp,rsp
     dbf:	mov    rsi,QWORD PTR [rdx]
     dc2:	mov    rdx,QWORD PTR [rdx+0x8]
     dc6:	call   dcb <botlish_entry_15+0x10>
			dc7: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
     dcb:	mov    rsp,rbp
     dce:	pop    rbp
     dcf:	ret

0000000000000dd0 <botlish_fn_16: ht_find_get<mutarray, str, int>>:
     dd0:	push   rbp
     dd1:	mov    rbp,rsp
     dd4:	sub    rsp,0x40
     dd8:	mov    QWORD PTR [rsp+0x10],rbx
     ddd:	mov    QWORD PTR [rsp+0x18],r12
     de2:	mov    QWORD PTR [rsp+0x20],r13
     de7:	mov    QWORD PTR [rsp+0x28],r14
     dec:	mov    QWORD PTR [rsp+0x30],r15
     df1:	mov    r14,QWORD PTR [rdi]
     df4:	mov    rax,QWORD PTR [rdi+0x8]
     df8:	lea    r8,[r14+0x20]
     dfc:	cmp    r8,rax
     dff:	ja     1159 <botlish_fn_16+0x389>
     e05:	lea    rax,[r14+0x20]
     e09:	mov    QWORD PTR [rdi],rax
     e0c:	mov    r15,rdi
     e0f:	mov    QWORD PTR [r14],0x0
     e16:	mov    QWORD PTR [r14+0x8],0x0
     e1e:	mov    QWORD PTR [r14+0x10],0x0
     e26:	mov    QWORD PTR [r14+0x18],0x0
     e2e:	mov    QWORD PTR [r14],rsi
     e31:	mov    QWORD PTR [r14+0x8],rdx
     e35:	mov    QWORD PTR [rsp],rdx
     e39:	mov    QWORD PTR [r14+0x10],rcx
     e3d:	mov    rbx,rsi
     e40:	mov    QWORD PTR [rsp+0x8],rcx
     e45:	mov    rsi,rbx
     e48:	mov    rdi,r15
     e4b:	call   e50 <botlish_fn_16+0x80>
			e4c: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
     e50:	test   rax,rax
     e53:	jne    e61 <botlish_fn_16+0x91>
     e59:	mov    rdi,r15
     e5c:	jmp    10b9 <botlish_fn_16+0x2e9>
     e61:	xor    ecx,ecx
     e63:	test   rax,0x7
     e69:	je     e77 <botlish_fn_16+0xa7>
     e6f:	mov    rsi,rax
     e72:	jmp    e85 <botlish_fn_16+0xb5>
     e77:	movzx  rcx,BYTE PTR [rax]
     e7b:	mov    rsi,rax
     e7e:	rex cmp cl,0x8
     e82:	sete   cl
     e85:	test   cl,cl
     e87:	jne    eaa <botlish_fn_16+0xda>
     e8d:	mov    rdi,r15
     e90:	mov    rax,QWORD PTR [rdi+0x10]
     e94:	mov    rcx,QWORD PTR [rax+0x8]
     e98:	mov    edx,0x8
     e9d:	call   ea2 <botlish_fn_16+0xd2>
			e9e: R_X86_64_PLT32	rt_type_error-0x4
     ea2:	mov    rdi,r15
     ea5:	jmp    10b9 <botlish_fn_16+0x2e9>
     eaa:	mov    rdx,QWORD PTR [rsp+0x8]
     eaf:	mov    rdi,r15
     eb2:	call   eb7 <botlish_fn_16+0xe7>
			eb3: R_X86_64_PLT32	rt_mutarray_get-0x4
     eb7:	mov    rcx,rax
     eba:	mov    r13,rax
     ebd:	test   rax,rcx
     ec0:	jne    ece <botlish_fn_16+0xfe>
     ec6:	mov    rdi,r15
     ec9:	jmp    10b9 <botlish_fn_16+0x2e9>
     ece:	mov    rax,r13
     ed1:	mov    QWORD PTR [r14+0x18],rax
     ed5:	mov    rdi,r15
     ed8:	call   edd <botlish_fn_16+0x10d>
			ed9: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
     edd:	test   rax,rax
     ee0:	jne    eee <botlish_fn_16+0x11e>
     ee6:	mov    rdi,r15
     ee9:	jmp    10b9 <botlish_fn_16+0x2e9>
     eee:	mov    rdi,r13
     ef1:	mov    rcx,rdi
     ef4:	and    rcx,rax
     ef7:	mov    rdx,rax
     efa:	test   rcx,0x1
     f01:	jne    f23 <botlish_fn_16+0x153>
     f07:	mov    rsi,r13
     f0a:	mov    rdi,r15
     f0d:	call   f12 <botlish_fn_16+0x142>
			f0e: R_X86_64_PLT32	rt_value_eq-0x4
     f12:	test   rax,rax
     f15:	jne    f33 <botlish_fn_16+0x163>
     f1b:	mov    rdi,r15
     f1e:	jmp    10b9 <botlish_fn_16+0x2e9>
     f23:	mov    eax,0x2
     f28:	cmp    r13,rdx
     f2b:	cmove  rax,QWORD PTR [rip+0x255]        # 1188 <botlish_fn_16+0x3b8>
     f33:	mov    r12d,0x6
     f39:	cmp    rax,0x6
     f3d:	je     112a <botlish_fn_16+0x35a>
     f43:	mov    rdi,r15
     f46:	call   f4b <botlish_fn_16+0x17b>
			f47: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
     f4b:	test   rax,rax
     f4e:	jne    f5c <botlish_fn_16+0x18c>
     f54:	mov    rdi,r15
     f57:	jmp    10b9 <botlish_fn_16+0x2e9>
     f5c:	mov    rcx,r13
     f5f:	and    rcx,rax
     f62:	mov    rdx,rax
     f65:	test   rcx,0x1
     f6c:	jne    f8e <botlish_fn_16+0x1be>
     f72:	mov    rsi,r13
     f75:	mov    rdi,r15
     f78:	call   f7d <botlish_fn_16+0x1ad>
			f79: R_X86_64_PLT32	rt_value_eq-0x4
     f7d:	test   rax,rax
     f80:	jne    fa1 <botlish_fn_16+0x1d1>
     f86:	mov    rdi,r15
     f89:	jmp    10b9 <botlish_fn_16+0x2e9>
     f8e:	mov    rsi,r13
     f91:	mov    eax,0x2
     f96:	cmp    rsi,rdx
     f99:	cmove  rax,QWORD PTR [rip+0x1e7]        # 1188 <botlish_fn_16+0x3b8>
     fa1:	cmp    rax,0x6
     fa5:	je     fba <botlish_fn_16+0x1ea>
     fab:	mov    r12d,0x2
     fb1:	mov    r13,QWORD PTR [rsp]
     fb5:	jmp    1093 <botlish_fn_16+0x2c3>
     fba:	mov    rsi,rbx
     fbd:	mov    rdi,r15
     fc0:	call   fc5 <botlish_fn_16+0x1f5>
			fc1: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
     fc5:	test   rax,rax
     fc8:	jne    fd6 <botlish_fn_16+0x206>
     fce:	mov    rdi,r15
     fd1:	jmp    10b9 <botlish_fn_16+0x2e9>
     fd6:	xor    ecx,ecx
     fd8:	test   rax,0x7
     fde:	je     fec <botlish_fn_16+0x21c>
     fe4:	mov    rsi,rax
     fe7:	jmp    ffa <botlish_fn_16+0x22a>
     fec:	movzx  rcx,BYTE PTR [rax]
     ff0:	mov    rsi,rax
     ff3:	rex cmp cl,0x8
     ff7:	sete   cl
     ffa:	test   cl,cl
     ffc:	jne    101f <botlish_fn_16+0x24f>
    1002:	mov    rdi,r15
    1005:	mov    rax,QWORD PTR [rdi+0x10]
    1009:	mov    rcx,QWORD PTR [rax+0x8]
    100d:	mov    edx,0x8
    1012:	call   1017 <botlish_fn_16+0x247>
			1013: R_X86_64_PLT32	rt_type_error-0x4
    1017:	mov    rdi,r15
    101a:	jmp    10b9 <botlish_fn_16+0x2e9>
    101f:	mov    rdx,QWORD PTR [rsp+0x8]
    1024:	mov    rdi,r15
    1027:	call   102c <botlish_fn_16+0x25c>
			1028: R_X86_64_PLT32	rt_mutarray_get-0x4
    102c:	test   rax,rax
    102f:	jne    103d <botlish_fn_16+0x26d>
    1035:	mov    rdi,r15
    1038:	jmp    10b9 <botlish_fn_16+0x2e9>
    103d:	mov    r13,QWORD PTR [rsp]
    1041:	mov    rdx,rax
    1044:	and    rdx,r13
    1047:	mov    rsi,rax
    104a:	test   rdx,0x1
    1051:	jne    1073 <botlish_fn_16+0x2a3>
    1057:	mov    rdx,r13
    105a:	mov    rdi,r15
    105d:	call   1062 <botlish_fn_16+0x292>
			105e: R_X86_64_PLT32	rt_value_eq-0x4
    1062:	test   rax,rax
    1065:	jne    1083 <botlish_fn_16+0x2b3>
    106b:	mov    rdi,r15
    106e:	jmp    10b9 <botlish_fn_16+0x2e9>
    1073:	mov    eax,0x2
    1078:	cmp    rsi,r13
    107b:	cmove  rax,QWORD PTR [rip+0x105]        # 1188 <botlish_fn_16+0x3b8>
    1083:	cmp    rax,0x6
    1087:	je     1093 <botlish_fn_16+0x2c3>
    108d:	mov    r12d,0x2
    1093:	cmp    r12,0x6
    1097:	je     10fd <botlish_fn_16+0x32d>
    109d:	mov    rdx,QWORD PTR [rsp+0x8]
    10a2:	mov    rsi,rbx
    10a5:	mov    rdi,r15
    10a8:	call   10ad <botlish_fn_16+0x2dd>
			10a9: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
    10ad:	test   rax,rax
    10b0:	jne    10e4 <botlish_fn_16+0x314>
    10b6:	mov    rdi,r15
    10b9:	mov    rdi,r15
    10bc:	mov    QWORD PTR [rdi],r14
    10bf:	xor    rax,rax
    10c2:	mov    rbx,QWORD PTR [rsp+0x10]
    10c7:	mov    r12,QWORD PTR [rsp+0x18]
    10cc:	mov    r13,QWORD PTR [rsp+0x20]
    10d1:	mov    r14,QWORD PTR [rsp+0x28]
    10d6:	mov    r15,QWORD PTR [rsp+0x30]
    10db:	add    rsp,0x40
    10df:	mov    rsp,rbp
    10e2:	pop    rbp
    10e3:	ret
    10e4:	mov    QWORD PTR [r14],rbx
    10e7:	mov    QWORD PTR [r14+0x8],r13
    10eb:	mov    QWORD PTR [r14+0x10],rax
    10ef:	mov    QWORD PTR [rsp],r13
    10f3:	mov    QWORD PTR [rsp+0x8],rax
    10f8:	jmp    e45 <botlish_fn_16+0x75>
    10fd:	mov    rdi,r15
    1100:	mov    QWORD PTR [rdi],r14
    1103:	mov    rax,QWORD PTR [rsp+0x8]
    1108:	mov    rbx,QWORD PTR [rsp+0x10]
    110d:	mov    r12,QWORD PTR [rsp+0x18]
    1112:	mov    r13,QWORD PTR [rsp+0x20]
    1117:	mov    r14,QWORD PTR [rsp+0x28]
    111c:	mov    r15,QWORD PTR [rsp+0x30]
    1121:	add    rsp,0x40
    1125:	mov    rsp,rbp
    1128:	pop    rbp
    1129:	ret
    112a:	mov    rdi,r15
    112d:	mov    QWORD PTR [rdi],r14
    1130:	mov    rax,0xffffffffffffffff
    1137:	mov    rbx,QWORD PTR [rsp+0x10]
    113c:	mov    r12,QWORD PTR [rsp+0x18]
    1141:	mov    r13,QWORD PTR [rsp+0x20]
    1146:	mov    r14,QWORD PTR [rsp+0x28]
    114b:	mov    r15,QWORD PTR [rsp+0x30]
    1150:	add    rsp,0x40
    1154:	mov    rsp,rbp
    1157:	pop    rbp
    1158:	ret
    1159:	mov    r15,rdi
    115c:	call   1161 <botlish_fn_16+0x391>
			115d: R_X86_64_PLT32	rt_stack_overflow-0x4
    1161:	xor    rax,rax
    1164:	mov    rbx,QWORD PTR [rsp+0x10]
    1169:	mov    r12,QWORD PTR [rsp+0x18]
    116e:	mov    r13,QWORD PTR [rsp+0x20]
    1173:	mov    r14,QWORD PTR [rsp+0x28]
    1178:	mov    r15,QWORD PTR [rsp+0x30]
    117d:	add    rsp,0x40
    1181:	mov    rsp,rbp
    1184:	pop    rbp
    1185:	ret
    1186:	add    BYTE PTR [rax],al
    1188:	(bad)
    1189:	add    BYTE PTR [rax],al
    118b:	add    BYTE PTR [rax],al
    118d:	add    BYTE PTR [rax],al
	...

0000000000001190 <botlish_entry_16: ht_find_get<mutarray, str, int>>:
    1190:	push   rbp
    1191:	mov    rbp,rsp
    1194:	mov    rsi,QWORD PTR [rdx]
    1197:	mov    r8,QWORD PTR [rdx+0x8]
    119b:	mov    rcx,QWORD PTR [rdx+0x10]
    119f:	mov    rdx,r8
    11a2:	call   11a7 <botlish_entry_16+0x17>
			11a3: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    11a7:	mov    rsp,rbp
    11aa:	pop    rbp
    11ab:	ret
    11ac:	add    BYTE PTR [rax],al
	...

00000000000011b0 <botlish_fn_17: ht_find_insert<mutarray, str, int, int>>:
    11b0:	push   rbp
    11b1:	mov    rbp,rsp
    11b4:	sub    rsp,0x50
    11b8:	mov    QWORD PTR [rsp+0x20],rbx
    11bd:	mov    QWORD PTR [rsp+0x28],r12
    11c2:	mov    QWORD PTR [rsp+0x30],r13
    11c7:	mov    QWORD PTR [rsp+0x38],r14
    11cc:	mov    QWORD PTR [rsp+0x40],r15
    11d1:	mov    r12,QWORD PTR [rdi]
    11d4:	mov    rax,QWORD PTR [rdi+0x8]
    11d8:	lea    r9,[r12+0x28]
    11dd:	cmp    r9,rax
    11e0:	ja     1761 <botlish_fn_17+0x5b1>
    11e6:	lea    rax,[r12+0x28]
    11eb:	mov    QWORD PTR [rdi],rax
    11ee:	mov    QWORD PTR [rsp],rdi
    11f2:	mov    QWORD PTR [r12],0x0
    11fa:	mov    QWORD PTR [r12+0x8],0x0
    1203:	mov    QWORD PTR [r12+0x10],0x0
    120c:	mov    QWORD PTR [r12+0x18],0x0
    1215:	mov    QWORD PTR [r12+0x20],0x0
    121e:	mov    QWORD PTR [r12],rsi
    1222:	mov    QWORD PTR [r12+0x8],rdx
    1227:	mov    r13,rdx
    122a:	mov    QWORD PTR [r12+0x10],rcx
    122f:	mov    QWORD PTR [r12+0x18],r8
    1234:	mov    rbx,rsi
    1237:	mov    QWORD PTR [rsp+0x8],rcx
    123c:	mov    QWORD PTR [rsp+0x10],r8
    1241:	mov    rsi,rbx
    1244:	mov    rdi,QWORD PTR [rsp]
    1248:	call   124d <botlish_fn_17+0x9d>
			1249: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    124d:	test   rax,rax
    1250:	jne    125f <botlish_fn_17+0xaf>
    1256:	mov    rdi,QWORD PTR [rsp]
    125a:	jmp    161f <botlish_fn_17+0x46f>
    125f:	xor    ecx,ecx
    1261:	test   rax,0x7
    1267:	je     1275 <botlish_fn_17+0xc5>
    126d:	mov    rsi,rax
    1270:	jmp    1283 <botlish_fn_17+0xd3>
    1275:	movzx  rcx,BYTE PTR [rax]
    1279:	mov    rsi,rax
    127c:	rex cmp cl,0x8
    1280:	sete   cl
    1283:	test   cl,cl
    1285:	jne    12aa <botlish_fn_17+0xfa>
    128b:	mov    rdi,QWORD PTR [rsp]
    128f:	mov    rax,QWORD PTR [rdi+0x10]
    1293:	mov    rcx,QWORD PTR [rax+0x8]
    1297:	mov    edx,0x8
    129c:	call   12a1 <botlish_fn_17+0xf1>
			129d: R_X86_64_PLT32	rt_type_error-0x4
    12a1:	mov    rdi,QWORD PTR [rsp]
    12a5:	jmp    161f <botlish_fn_17+0x46f>
    12aa:	mov    rdx,QWORD PTR [rsp+0x8]
    12af:	mov    rdi,QWORD PTR [rsp]
    12b3:	call   12b8 <botlish_fn_17+0x108>
			12b4: R_X86_64_PLT32	rt_mutarray_get-0x4
    12b8:	mov    rcx,rax
    12bb:	mov    QWORD PTR [rsp+0x18],rax
    12c0:	test   rax,rcx
    12c3:	jne    12d2 <botlish_fn_17+0x122>
    12c9:	mov    rdi,QWORD PTR [rsp]
    12cd:	jmp    161f <botlish_fn_17+0x46f>
    12d2:	mov    rax,QWORD PTR [rsp+0x18]
    12d7:	mov    QWORD PTR [r12+0x20],rax
    12dc:	mov    rdi,QWORD PTR [rsp]
    12e0:	call   12e5 <botlish_fn_17+0x135>
			12e1: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
    12e5:	test   rax,rax
    12e8:	jne    12f7 <botlish_fn_17+0x147>
    12ee:	mov    rdi,QWORD PTR [rsp]
    12f2:	jmp    161f <botlish_fn_17+0x46f>
    12f7:	mov    rcx,QWORD PTR [rsp+0x18]
    12fc:	and    rcx,rax
    12ff:	mov    rdx,rax
    1302:	test   rcx,0x1
    1309:	jne    132f <botlish_fn_17+0x17f>
    130f:	mov    rsi,QWORD PTR [rsp+0x18]
    1314:	mov    rdi,QWORD PTR [rsp]
    1318:	call   131d <botlish_fn_17+0x16d>
			1319: R_X86_64_PLT32	rt_value_eq-0x4
    131d:	test   rax,rax
    1320:	jne    1344 <botlish_fn_17+0x194>
    1326:	mov    rdi,QWORD PTR [rsp]
    132a:	jmp    161f <botlish_fn_17+0x46f>
    132f:	mov    eax,0x2
    1334:	mov    rcx,QWORD PTR [rsp+0x18]
    1339:	cmp    rcx,rdx
    133c:	cmove  rax,QWORD PTR [rip+0x44c]        # 1790 <botlish_fn_17+0x5e0>
    1344:	mov    r14d,0x6
    134a:	cmp    rax,0x6
    134e:	je     16a8 <botlish_fn_17+0x4f8>
    1354:	mov    rdi,QWORD PTR [rsp]
    1358:	call   135d <botlish_fn_17+0x1ad>
			1359: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    135d:	test   rax,rax
    1360:	jne    136f <botlish_fn_17+0x1bf>
    1366:	mov    rdi,QWORD PTR [rsp]
    136a:	jmp    161f <botlish_fn_17+0x46f>
    136f:	mov    rcx,QWORD PTR [rsp+0x18]
    1374:	mov    rsi,rcx
    1377:	and    rsi,rax
    137a:	mov    rdx,rax
    137d:	test   rsi,0x1
    1384:	jne    13aa <botlish_fn_17+0x1fa>
    138a:	mov    rsi,QWORD PTR [rsp+0x18]
    138f:	mov    rdi,QWORD PTR [rsp]
    1393:	call   1398 <botlish_fn_17+0x1e8>
			1394: R_X86_64_PLT32	rt_value_eq-0x4
    1398:	test   rax,rax
    139b:	jne    13bf <botlish_fn_17+0x20f>
    13a1:	mov    rdi,QWORD PTR [rsp]
    13a5:	jmp    161f <botlish_fn_17+0x46f>
    13aa:	mov    eax,0x2
    13af:	mov    r10,QWORD PTR [rsp+0x18]
    13b4:	cmp    r10,rdx
    13b7:	cmove  rax,QWORD PTR [rip+0x3d1]        # 1790 <botlish_fn_17+0x5e0>
    13bf:	cmp    rax,0x6
    13c3:	je     13d6 <botlish_fn_17+0x226>
    13c9:	mov    eax,0x2
    13ce:	mov    r15,r13
    13d1:	jmp    14bd <botlish_fn_17+0x30d>
    13d6:	mov    rsi,rbx
    13d9:	mov    rdi,QWORD PTR [rsp]
    13dd:	call   13e2 <botlish_fn_17+0x232>
			13de: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    13e2:	test   rax,rax
    13e5:	jne    13f4 <botlish_fn_17+0x244>
    13eb:	mov    rdi,QWORD PTR [rsp]
    13ef:	jmp    161f <botlish_fn_17+0x46f>
    13f4:	xor    ecx,ecx
    13f6:	test   rax,0x7
    13fc:	je     140a <botlish_fn_17+0x25a>
    1402:	mov    rsi,rax
    1405:	jmp    1418 <botlish_fn_17+0x268>
    140a:	movzx  rcx,BYTE PTR [rax]
    140e:	mov    rsi,rax
    1411:	rex cmp cl,0x8
    1415:	sete   cl
    1418:	test   cl,cl
    141a:	jne    143f <botlish_fn_17+0x28f>
    1420:	mov    rdi,QWORD PTR [rsp]
    1424:	mov    rax,QWORD PTR [rdi+0x10]
    1428:	mov    rcx,QWORD PTR [rax+0x8]
    142c:	mov    edx,0x8
    1431:	call   1436 <botlish_fn_17+0x286>
			1432: R_X86_64_PLT32	rt_type_error-0x4
    1436:	mov    rdi,QWORD PTR [rsp]
    143a:	jmp    161f <botlish_fn_17+0x46f>
    143f:	mov    rdx,QWORD PTR [rsp+0x8]
    1444:	mov    rdi,QWORD PTR [rsp]
    1448:	call   144d <botlish_fn_17+0x29d>
			1449: R_X86_64_PLT32	rt_mutarray_get-0x4
    144d:	test   rax,rax
    1450:	jne    145f <botlish_fn_17+0x2af>
    1456:	mov    rdi,QWORD PTR [rsp]
    145a:	jmp    161f <botlish_fn_17+0x46f>
    145f:	mov    r15,r13
    1462:	mov    rcx,rax
    1465:	and    rcx,r15
    1468:	mov    rsi,rax
    146b:	test   rcx,0x1
    1472:	jne    1496 <botlish_fn_17+0x2e6>
    1478:	mov    rdx,r15
    147b:	mov    rdi,QWORD PTR [rsp]
    147f:	call   1484 <botlish_fn_17+0x2d4>
			1480: R_X86_64_PLT32	rt_value_eq-0x4
    1484:	test   rax,rax
    1487:	jne    14a6 <botlish_fn_17+0x2f6>
    148d:	mov    rdi,QWORD PTR [rsp]
    1491:	jmp    161f <botlish_fn_17+0x46f>
    1496:	mov    eax,0x2
    149b:	cmp    rsi,r15
    149e:	cmove  rax,QWORD PTR [rip+0x2ea]        # 1790 <botlish_fn_17+0x5e0>
    14a6:	cmp    rax,0x6
    14aa:	je     14ba <botlish_fn_17+0x30a>
    14b0:	mov    eax,0x2
    14b5:	jmp    14bd <botlish_fn_17+0x30d>
    14ba:	mov    rax,r14
    14bd:	cmp    rax,0x6
    14c1:	je     167a <botlish_fn_17+0x4ca>
    14c7:	mov    rdi,QWORD PTR [rsp]
    14cb:	call   14d0 <botlish_fn_17+0x320>
			14cc: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    14d0:	test   rax,rax
    14d3:	jne    14e2 <botlish_fn_17+0x332>
    14d9:	mov    rdi,QWORD PTR [rsp]
    14dd:	jmp    161f <botlish_fn_17+0x46f>
    14e2:	mov    rcx,QWORD PTR [rsp+0x18]
    14e7:	mov    rdx,rcx
    14ea:	and    rdx,rax
    14ed:	mov    r11,rax
    14f0:	test   rdx,0x1
    14f7:	jne    1520 <botlish_fn_17+0x370>
    14fd:	mov    rdx,r11
    1500:	mov    rsi,QWORD PTR [rsp+0x18]
    1505:	mov    rdi,QWORD PTR [rsp]
    1509:	call   150e <botlish_fn_17+0x35e>
			150a: R_X86_64_PLT32	rt_value_eq-0x4
    150e:	test   rax,rax
    1511:	jne    1538 <botlish_fn_17+0x388>
    1517:	mov    rdi,QWORD PTR [rsp]
    151b:	jmp    161f <botlish_fn_17+0x46f>
    1520:	mov    rdx,r11
    1523:	mov    rsi,QWORD PTR [rsp+0x18]
    1528:	mov    eax,0x2
    152d:	cmp    rsi,rdx
    1530:	cmove  rax,QWORD PTR [rip+0x258]        # 1790 <botlish_fn_17+0x5e0>
    1538:	cmp    rax,0x6
    153c:	je     154d <botlish_fn_17+0x39d>
    1542:	mov    r14d,0x2
    1548:	jmp    15af <botlish_fn_17+0x3ff>
    154d:	mov    r13,QWORD PTR [rsp+0x10]
    1552:	test   r13,0x1
    1559:	jne    158a <botlish_fn_17+0x3da>
    155f:	mov    edx,0x1
    1564:	mov    rsi,r13
    1567:	mov    rdi,QWORD PTR [rsp]
    156b:	call   1570 <botlish_fn_17+0x3c0>
			156c: R_X86_64_PLT32	rt_int_cmp-0x4
    1570:	mov    ecx,0x2
    1575:	test   rax,rax
    1578:	cmovl  rcx,QWORD PTR [rip+0x210]        # 1790 <botlish_fn_17+0x5e0>
    1580:	mov    QWORD PTR [rsp+0x10],r13
    1585:	jmp    159f <botlish_fn_17+0x3ef>
    158a:	mov    ecx,0x2
    158f:	test   r13,r13
    1592:	mov    QWORD PTR [rsp+0x10],r13
    1597:	cmovle rcx,QWORD PTR [rip+0x1f1]        # 1790 <botlish_fn_17+0x5e0>
    159f:	cmp    rcx,0x6
    15a3:	je     15af <botlish_fn_17+0x3ff>
    15a9:	mov    r14d,0x2
    15af:	cmp    r14,0x6
    15b3:	je     1601 <botlish_fn_17+0x451>
    15b9:	mov    rdx,QWORD PTR [rsp+0x8]
    15be:	mov    rsi,rbx
    15c1:	mov    rdi,QWORD PTR [rsp]
    15c5:	call   15ca <botlish_fn_17+0x41a>
			15c6: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
    15ca:	test   rax,rax
    15cd:	jne    15dc <botlish_fn_17+0x42c>
    15d3:	mov    rdi,QWORD PTR [rsp]
    15d7:	jmp    161f <botlish_fn_17+0x46f>
    15dc:	mov    QWORD PTR [r12],rbx
    15e0:	mov    QWORD PTR [r12+0x8],r15
    15e5:	mov    QWORD PTR [r12+0x10],rax
    15ea:	mov    rcx,QWORD PTR [rsp+0x10]
    15ef:	mov    QWORD PTR [r12+0x18],rcx
    15f4:	mov    r13,r15
    15f7:	mov    QWORD PTR [rsp+0x8],rax
    15fc:	jmp    1241 <botlish_fn_17+0x91>
    1601:	mov    rdx,QWORD PTR [rsp+0x8]
    1606:	mov    rsi,rbx
    1609:	mov    rdi,QWORD PTR [rsp]
    160d:	call   1612 <botlish_fn_17+0x462>
			160e: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_probe_next<mutarray, int>
    1612:	test   rax,rax
    1615:	jne    164b <botlish_fn_17+0x49b>
    161b:	mov    rdi,QWORD PTR [rsp]
    161f:	mov    rdi,QWORD PTR [rsp]
    1623:	mov    QWORD PTR [rdi],r12
    1626:	xor    rax,rax
    1629:	mov    rbx,QWORD PTR [rsp+0x20]
    162e:	mov    r12,QWORD PTR [rsp+0x28]
    1633:	mov    r13,QWORD PTR [rsp+0x30]
    1638:	mov    r14,QWORD PTR [rsp+0x38]
    163d:	mov    r15,QWORD PTR [rsp+0x40]
    1642:	add    rsp,0x50
    1646:	mov    rsp,rbp
    1649:	pop    rbp
    164a:	ret
    164b:	mov    QWORD PTR [r12],rbx
    164f:	mov    QWORD PTR [r12+0x8],r15
    1654:	mov    QWORD PTR [r12+0x10],rax
    1659:	mov    rdx,QWORD PTR [rsp+0x8]
    165e:	mov    QWORD PTR [r12+0x18],rdx
    1663:	mov    rcx,QWORD PTR [rsp+0x8]
    1668:	mov    QWORD PTR [rsp+0x10],rcx
    166d:	mov    QWORD PTR [rsp+0x8],rax
    1672:	mov    r13,r15
    1675:	jmp    1241 <botlish_fn_17+0x91>
    167a:	mov    rdi,QWORD PTR [rsp]
    167e:	mov    QWORD PTR [rdi],r12
    1681:	mov    rax,QWORD PTR [rsp+0x8]
    1686:	mov    rbx,QWORD PTR [rsp+0x20]
    168b:	mov    r12,QWORD PTR [rsp+0x28]
    1690:	mov    r13,QWORD PTR [rsp+0x30]
    1695:	mov    r14,QWORD PTR [rsp+0x38]
    169a:	mov    r15,QWORD PTR [rsp+0x40]
    169f:	add    rsp,0x50
    16a3:	mov    rsp,rbp
    16a6:	pop    rbp
    16a7:	ret
    16a8:	mov    rax,QWORD PTR [rsp+0x10]
    16ad:	test   rax,0x1
    16b3:	jne    16e1 <botlish_fn_17+0x531>
    16b9:	mov    edx,0x1
    16be:	mov    rsi,QWORD PTR [rsp+0x10]
    16c3:	mov    rdi,QWORD PTR [rsp]
    16c7:	call   16cc <botlish_fn_17+0x51c>
			16c8: R_X86_64_PLT32	rt_int_cmp-0x4
    16cc:	mov    ecx,0x2
    16d1:	test   rax,rax
    16d4:	cmovge rcx,QWORD PTR [rip+0xb4]        # 1790 <botlish_fn_17+0x5e0>
    16dc:	jmp    16fb <botlish_fn_17+0x54b>
    16e1:	mov    ecx,0x2
    16e6:	mov    rax,QWORD PTR [rsp+0x10]
    16eb:	mov    rdx,QWORD PTR [rsp+0x10]
    16f0:	test   rax,rdx
    16f3:	cmovg  rcx,QWORD PTR [rip+0x95]        # 1790 <botlish_fn_17+0x5e0>
    16fb:	cmp    rcx,0x6
    16ff:	je     1733 <botlish_fn_17+0x583>
    1705:	mov    rdi,QWORD PTR [rsp]
    1709:	mov    QWORD PTR [rdi],r12
    170c:	mov    rax,QWORD PTR [rsp+0x8]
    1711:	mov    rbx,QWORD PTR [rsp+0x20]
    1716:	mov    r12,QWORD PTR [rsp+0x28]
    171b:	mov    r13,QWORD PTR [rsp+0x30]
    1720:	mov    r14,QWORD PTR [rsp+0x38]
    1725:	mov    r15,QWORD PTR [rsp+0x40]
    172a:	add    rsp,0x50
    172e:	mov    rsp,rbp
    1731:	pop    rbp
    1732:	ret
    1733:	mov    rdi,QWORD PTR [rsp]
    1737:	mov    QWORD PTR [rdi],r12
    173a:	mov    rax,QWORD PTR [rsp+0x10]
    173f:	mov    rbx,QWORD PTR [rsp+0x20]
    1744:	mov    r12,QWORD PTR [rsp+0x28]
    1749:	mov    r13,QWORD PTR [rsp+0x30]
    174e:	mov    r14,QWORD PTR [rsp+0x38]
    1753:	mov    r15,QWORD PTR [rsp+0x40]
    1758:	add    rsp,0x50
    175c:	mov    rsp,rbp
    175f:	pop    rbp
    1760:	ret
    1761:	mov    QWORD PTR [rsp],rdi
    1765:	call   176a <botlish_fn_17+0x5ba>
			1766: R_X86_64_PLT32	rt_stack_overflow-0x4
    176a:	xor    rax,rax
    176d:	mov    rbx,QWORD PTR [rsp+0x20]
    1772:	mov    r12,QWORD PTR [rsp+0x28]
    1777:	mov    r13,QWORD PTR [rsp+0x30]
    177c:	mov    r14,QWORD PTR [rsp+0x38]
    1781:	mov    r15,QWORD PTR [rsp+0x40]
    1786:	add    rsp,0x50
    178a:	mov    rsp,rbp
    178d:	pop    rbp
    178e:	ret
    178f:	add    BYTE PTR [rsi],al
    1791:	add    BYTE PTR [rax],al
    1793:	add    BYTE PTR [rax],al
    1795:	add    BYTE PTR [rax],al
	...

0000000000001798 <botlish_entry_17: ht_find_insert<mutarray, str, int, int>>:
    1798:	push   rbp
    1799:	mov    rbp,rsp
    179c:	mov    rsi,QWORD PTR [rdx]
    179f:	mov    r9,QWORD PTR [rdx+0x8]
    17a3:	mov    rcx,QWORD PTR [rdx+0x10]
    17a7:	mov    r8,QWORD PTR [rdx+0x18]
    17ab:	mov    rdx,r9
    17ae:	call   17b3 <botlish_entry_17+0x1b>
			17af: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    17b3:	mov    rsp,rbp
    17b6:	pop    rbp
    17b7:	ret

00000000000017b8 <botlish_fn_18: ht_get<mutarray, str>>:
    17b8:	push   rbp
    17b9:	mov    rbp,rsp
    17bc:	sub    rsp,0x20
    17c0:	mov    QWORD PTR [rsp],rbx
    17c4:	mov    QWORD PTR [rsp+0x8],r12
    17c9:	mov    QWORD PTR [rsp+0x10],r13
    17ce:	mov    QWORD PTR [rsp+0x18],r14
    17d3:	mov    rbx,QWORD PTR [rdi]
    17d6:	mov    rax,QWORD PTR [rdi+0x8]
    17da:	lea    rcx,[rbx+0x18]
    17de:	cmp    rcx,rax
    17e1:	ja     199a <botlish_fn_18+0x1e2>
    17e7:	lea    rax,[rbx+0x18]
    17eb:	mov    QWORD PTR [rdi],rax
    17ee:	mov    r12,rdi
    17f1:	mov    QWORD PTR [rbx],0x0
    17f8:	mov    QWORD PTR [rbx+0x8],0x0
    1800:	mov    QWORD PTR [rbx+0x10],0x0
    1808:	mov    QWORD PTR [rbx],rsi
    180b:	mov    r13,rsi
    180e:	mov    QWORD PTR [rbx+0x8],rdx
    1812:	mov    r14,rdx
    1815:	mov    rdx,r14
    1818:	mov    rsi,r13
    181b:	mov    rdi,r12
    181e:	call   1823 <botlish_fn_18+0x6b>
			181f: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    1823:	test   rax,rax
    1826:	jne    1834 <botlish_fn_18+0x7c>
    182c:	mov    rdi,r12
    182f:	jmp    192c <botlish_fn_18+0x174>
    1834:	mov    QWORD PTR [rbx+0x10],rax
    1838:	mov    rcx,rax
    183b:	mov    rdx,r14
    183e:	mov    rsi,r13
    1841:	mov    rdi,r12
    1844:	call   1849 <botlish_fn_18+0x91>
			1845: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    1849:	mov    rcx,rax
    184c:	mov    r14,rax
    184f:	test   rax,rcx
    1852:	jne    1860 <botlish_fn_18+0xa8>
    1858:	mov    rdi,r12
    185b:	jmp    192c <botlish_fn_18+0x174>
    1860:	mov    rax,r14
    1863:	mov    QWORD PTR [rbx+0x8],rax
    1867:	test   rax,0x1
    186d:	jne    1898 <botlish_fn_18+0xe0>
    1873:	mov    edx,0x1
    1878:	mov    rsi,r14
    187b:	mov    rdi,r12
    187e:	call   1883 <botlish_fn_18+0xcb>
			187f: R_X86_64_PLT32	rt_int_cmp-0x4
    1883:	mov    ecx,0x2
    1888:	test   rax,rax
    188b:	cmovl  rcx,QWORD PTR [rip+0x135]        # 19c8 <botlish_fn_18+0x210>
    1893:	jmp    18ab <botlish_fn_18+0xf3>
    1898:	mov    ecx,0x2
    189d:	mov    rax,r14
    18a0:	test   rax,rax
    18a3:	cmovle rcx,QWORD PTR [rip+0x11d]        # 19c8 <botlish_fn_18+0x210>
    18ab:	cmp    rcx,0x6
    18af:	je     1973 <botlish_fn_18+0x1bb>
    18b5:	mov    rsi,r13
    18b8:	mov    rdi,r12
    18bb:	call   18c0 <botlish_fn_18+0x108>
			18bc: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    18c0:	test   rax,rax
    18c3:	jne    18d1 <botlish_fn_18+0x119>
    18c9:	mov    rdi,r12
    18cc:	jmp    192c <botlish_fn_18+0x174>
    18d1:	xor    ecx,ecx
    18d3:	test   rax,0x7
    18d9:	jne    18ea <botlish_fn_18+0x132>
    18df:	movzx  rdx,BYTE PTR [rax]
    18e3:	rex cmp dl,0x8
    18e7:	sete   cl
    18ea:	test   cl,cl
    18ec:	jne    1912 <botlish_fn_18+0x15a>
    18f2:	mov    rdi,r12
    18f5:	mov    rsi,QWORD PTR [rdi+0x10]
    18f9:	mov    rcx,QWORD PTR [rsi+0x8]
    18fd:	mov    edx,0x8
    1902:	mov    rsi,rax
    1905:	call   190a <botlish_fn_18+0x152>
			1906: R_X86_64_PLT32	rt_type_error-0x4
    190a:	mov    rdi,r12
    190d:	jmp    192c <botlish_fn_18+0x174>
    1912:	mov    rdx,r14
    1915:	mov    rsi,rax
    1918:	mov    rdi,r12
    191b:	call   1920 <botlish_fn_18+0x168>
			191c: R_X86_64_PLT32	rt_mutarray_get-0x4
    1920:	test   rax,rax
    1923:	jne    1951 <botlish_fn_18+0x199>
    1929:	mov    rdi,r12
    192c:	mov    rdi,r12
    192f:	mov    QWORD PTR [rdi],rbx
    1932:	xor    rax,rax
    1935:	mov    rbx,QWORD PTR [rsp]
    1939:	mov    r12,QWORD PTR [rsp+0x8]
    193e:	mov    r13,QWORD PTR [rsp+0x10]
    1943:	mov    r14,QWORD PTR [rsp+0x18]
    1948:	add    rsp,0x20
    194c:	mov    rsp,rbp
    194f:	pop    rbp
    1950:	ret
    1951:	mov    rdi,r12
    1954:	mov    QWORD PTR [rdi],rbx
    1957:	mov    rbx,QWORD PTR [rsp]
    195b:	mov    r12,QWORD PTR [rsp+0x8]
    1960:	mov    r13,QWORD PTR [rsp+0x10]
    1965:	mov    r14,QWORD PTR [rsp+0x18]
    196a:	add    rsp,0x20
    196e:	mov    rsp,rbp
    1971:	pop    rbp
    1972:	ret
    1973:	mov    rdi,r12
    1976:	mov    QWORD PTR [rdi],rbx
    1979:	mov    eax,0xa
    197e:	mov    rbx,QWORD PTR [rsp]
    1982:	mov    r12,QWORD PTR [rsp+0x8]
    1987:	mov    r13,QWORD PTR [rsp+0x10]
    198c:	mov    r14,QWORD PTR [rsp+0x18]
    1991:	add    rsp,0x20
    1995:	mov    rsp,rbp
    1998:	pop    rbp
    1999:	ret
    199a:	mov    r12,rdi
    199d:	call   19a2 <botlish_fn_18+0x1ea>
			199e: R_X86_64_PLT32	rt_stack_overflow-0x4
    19a2:	xor    rax,rax
    19a5:	mov    rbx,QWORD PTR [rsp]
    19a9:	mov    r12,QWORD PTR [rsp+0x8]
    19ae:	mov    r13,QWORD PTR [rsp+0x10]
    19b3:	mov    r14,QWORD PTR [rsp+0x18]
    19b8:	add    rsp,0x20
    19bc:	mov    rsp,rbp
    19bf:	pop    rbp
    19c0:	ret
    19c1:	add    BYTE PTR [rax],al
    19c3:	add    BYTE PTR [rax],al
    19c5:	add    BYTE PTR [rax],al
    19c7:	add    BYTE PTR [rsi],al
    19c9:	add    BYTE PTR [rax],al
    19cb:	add    BYTE PTR [rax],al
    19cd:	add    BYTE PTR [rax],al
	...

00000000000019d0 <botlish_entry_18: ht_get<mutarray, str>>:
    19d0:	push   rbp
    19d1:	mov    rbp,rsp
    19d4:	mov    rsi,QWORD PTR [rdx]
    19d7:	mov    rdx,QWORD PTR [rdx+0x8]
    19db:	call   19e0 <botlish_entry_18+0x10>
			19dc: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    19e0:	mov    rsp,rbp
    19e3:	pop    rbp
    19e4:	ret
    19e5:	add    BYTE PTR [rax],al
	...

00000000000019e8 <botlish_fn_19: ht_contains<mutarray, str>>:
    19e8:	push   rbp
    19e9:	mov    rbp,rsp
    19ec:	sub    rsp,0x20
    19f0:	mov    QWORD PTR [rsp],rbx
    19f4:	mov    QWORD PTR [rsp+0x8],r12
    19f9:	mov    QWORD PTR [rsp+0x10],r13
    19fe:	mov    QWORD PTR [rsp+0x18],r14
    1a03:	mov    rbx,QWORD PTR [rdi]
    1a06:	mov    rax,QWORD PTR [rdi+0x8]
    1a0a:	lea    rcx,[rbx+0x18]
    1a0e:	cmp    rcx,rax
    1a11:	ja     1b16 <botlish_fn_19+0x12e>
    1a17:	lea    rax,[rbx+0x18]
    1a1b:	mov    QWORD PTR [rdi],rax
    1a1e:	mov    r12,rdi
    1a21:	mov    QWORD PTR [rbx],0x0
    1a28:	mov    QWORD PTR [rbx+0x8],0x0
    1a30:	mov    QWORD PTR [rbx+0x10],0x0
    1a38:	mov    QWORD PTR [rbx],rsi
    1a3b:	mov    r14,rsi
    1a3e:	mov    QWORD PTR [rbx+0x8],rdx
    1a42:	mov    r13,rdx
    1a45:	mov    rdx,r13
    1a48:	mov    rsi,r14
    1a4b:	mov    rdi,r12
    1a4e:	call   1a53 <botlish_fn_19+0x6b>
			1a4f: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    1a53:	test   rax,rax
    1a56:	jne    1a64 <botlish_fn_19+0x7c>
    1a5c:	mov    rdi,r12
    1a5f:	jmp    1a85 <botlish_fn_19+0x9d>
    1a64:	mov    QWORD PTR [rbx+0x10],rax
    1a68:	mov    rcx,rax
    1a6b:	mov    rdx,r13
    1a6e:	mov    rsi,r14
    1a71:	mov    rdi,r12
    1a74:	call   1a79 <botlish_fn_19+0x91>
			1a75: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    1a79:	test   rax,rax
    1a7c:	jne    1aaa <botlish_fn_19+0xc2>
    1a82:	mov    rdi,r12
    1a85:	mov    rdi,r12
    1a88:	mov    QWORD PTR [rdi],rbx
    1a8b:	xor    rax,rax
    1a8e:	mov    rbx,QWORD PTR [rsp]
    1a92:	mov    r12,QWORD PTR [rsp+0x8]
    1a97:	mov    r13,QWORD PTR [rsp+0x10]
    1a9c:	mov    r14,QWORD PTR [rsp+0x18]
    1aa1:	add    rsp,0x20
    1aa5:	mov    rsp,rbp
    1aa8:	pop    rbp
    1aa9:	ret
    1aaa:	test   rax,0x1
    1ab0:	mov    rsi,rax
    1ab3:	jne    1ae1 <botlish_fn_19+0xf9>
    1ab9:	mov    edx,0x1
    1abe:	mov    rdi,r12
    1ac1:	call   1ac6 <botlish_fn_19+0xde>
			1ac2: R_X86_64_PLT32	rt_int_cmp-0x4
    1ac6:	mov    ecx,0x2
    1acb:	test   rax,rax
    1ace:	mov    rax,rcx
    1ad1:	cmovge rax,QWORD PTR [rip+0x67]        # 1b40 <botlish_fn_19+0x158>
    1ad9:	mov    rdi,r12
    1adc:	jmp    1af4 <botlish_fn_19+0x10c>
    1ae1:	mov    eax,0x2
    1ae6:	test   rsi,rsi
    1ae9:	cmovg  rax,QWORD PTR [rip+0x4f]        # 1b40 <botlish_fn_19+0x158>
    1af1:	mov    rdi,r12
    1af4:	mov    rdi,r12
    1af7:	mov    QWORD PTR [rdi],rbx
    1afa:	mov    rbx,QWORD PTR [rsp]
    1afe:	mov    r12,QWORD PTR [rsp+0x8]
    1b03:	mov    r13,QWORD PTR [rsp+0x10]
    1b08:	mov    r14,QWORD PTR [rsp+0x18]
    1b0d:	add    rsp,0x20
    1b11:	mov    rsp,rbp
    1b14:	pop    rbp
    1b15:	ret
    1b16:	mov    r12,rdi
    1b19:	call   1b1e <botlish_fn_19+0x136>
			1b1a: R_X86_64_PLT32	rt_stack_overflow-0x4
    1b1e:	xor    rax,rax
    1b21:	mov    rbx,QWORD PTR [rsp]
    1b25:	mov    r12,QWORD PTR [rsp+0x8]
    1b2a:	mov    r13,QWORD PTR [rsp+0x10]
    1b2f:	mov    r14,QWORD PTR [rsp+0x18]
    1b34:	add    rsp,0x20
    1b38:	mov    rsp,rbp
    1b3b:	pop    rbp
    1b3c:	ret
    1b3d:	add    BYTE PTR [rax],al
    1b3f:	add    BYTE PTR [rsi],al
    1b41:	add    BYTE PTR [rax],al
    1b43:	add    BYTE PTR [rax],al
    1b45:	add    BYTE PTR [rax],al
	...

0000000000001b48 <botlish_entry_19: ht_contains<mutarray, str>>:
    1b48:	push   rbp
    1b49:	mov    rbp,rsp
    1b4c:	mov    rsi,QWORD PTR [rdx]
    1b4f:	mov    rdx,QWORD PTR [rdx+0x8]
    1b53:	call   1b58 <botlish_entry_19+0x10>
			1b54: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    1b58:	mov    rsp,rbp
    1b5b:	pop    rbp
    1b5c:	ret
    1b5d:	add    BYTE PTR [rax],al
	...

0000000000001b60 <botlish_fn_20: ht_rehash_probe<mutarray, int, int>>:
    1b60:	push   rbp
    1b61:	mov    rbp,rsp
    1b64:	sub    rsp,0x40
    1b68:	mov    QWORD PTR [rsp+0x10],rbx
    1b6d:	mov    QWORD PTR [rsp+0x18],r12
    1b72:	mov    QWORD PTR [rsp+0x20],r13
    1b77:	mov    QWORD PTR [rsp+0x28],r14
    1b7c:	mov    QWORD PTR [rsp+0x30],r15
    1b81:	mov    r12,QWORD PTR [rdi]
    1b84:	mov    rax,QWORD PTR [rdi+0x8]
    1b88:	lea    r8,[r12+0x20]
    1b8d:	cmp    r8,rax
    1b90:	ja     1d32 <botlish_fn_20+0x1d2>
    1b96:	lea    rax,[r12+0x20]
    1b9b:	mov    QWORD PTR [rdi],rax
    1b9e:	mov    r14,rdi
    1ba1:	mov    QWORD PTR [r12],0x0
    1ba9:	mov    QWORD PTR [r12+0x8],0x0
    1bb2:	mov    QWORD PTR [r12+0x10],0x0
    1bbb:	mov    QWORD PTR [r12+0x18],0x0
    1bc4:	mov    QWORD PTR [r12],rsi
    1bc8:	mov    QWORD PTR [r12+0x8],rdx
    1bcd:	mov    QWORD PTR [r12+0x10],rcx
    1bd2:	mov    r13,rcx
    1bd5:	mov    rbx,rsi
    1bd8:	mov    r15,rdx
    1bdb:	mov    rdx,r15
    1bde:	mov    rsi,rbx
    1be1:	mov    rdi,r14
    1be4:	call   1be9 <botlish_fn_20+0x89>
			1be5: R_X86_64_PLT32	rt_mutarray_get-0x4
    1be9:	test   rax,rax
    1bec:	jne    1bfa <botlish_fn_20+0x9a>
    1bf2:	mov    rdi,r14
    1bf5:	jmp    1cc6 <botlish_fn_20+0x166>
    1bfa:	mov    QWORD PTR [r12+0x18],rax
    1bff:	mov    QWORD PTR [rsp],rax
    1c03:	mov    rdi,r14
    1c06:	call   1c0b <botlish_fn_20+0xab>
			1c07: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_empty_state<generic>
    1c0b:	test   rax,rax
    1c0e:	jne    1c1c <botlish_fn_20+0xbc>
    1c14:	mov    rdi,r14
    1c17:	jmp    1cc6 <botlish_fn_20+0x166>
    1c1c:	mov    r9,QWORD PTR [rsp]
    1c20:	mov    rcx,r9
    1c23:	and    rcx,rax
    1c26:	mov    rdx,rax
    1c29:	test   rcx,0x1
    1c30:	jne    1c53 <botlish_fn_20+0xf3>
    1c36:	mov    rsi,QWORD PTR [rsp]
    1c3a:	mov    rdi,r14
    1c3d:	call   1c42 <botlish_fn_20+0xe2>
			1c3e: R_X86_64_PLT32	rt_value_eq-0x4
    1c42:	test   rax,rax
    1c45:	jne    1c67 <botlish_fn_20+0x107>
    1c4b:	mov    rdi,r14
    1c4e:	jmp    1cc6 <botlish_fn_20+0x166>
    1c53:	mov    rsi,QWORD PTR [rsp]
    1c57:	mov    eax,0x2
    1c5c:	cmp    rsi,rdx
    1c5f:	cmove  rax,QWORD PTR [rip+0xf9]        # 1d60 <botlish_fn_20+0x200>
    1c67:	cmp    rax,0x6
    1c6b:	je     1d07 <botlish_fn_20+0x1a7>
    1c71:	mov    QWORD PTR [r12+0x18],0x3
    1c7a:	mov    rsi,r15
    1c7d:	test   rsi,0x1
    1c84:	je     1c9c <botlish_fn_20+0x13c>
    1c8a:	mov    rsi,r15
    1c8d:	add    rsi,0x2
    1c91:	seto   al
    1c94:	test   al,al
    1c96:	je     1caf <botlish_fn_20+0x14f>
    1c9c:	mov    edx,0x3
    1ca1:	mov    rsi,r15
    1ca4:	mov    rdi,r14
    1ca7:	call   1cac <botlish_fn_20+0x14c>
			1ca8: R_X86_64_PLT32	rt_int_add-0x4
    1cac:	mov    rsi,rax
    1caf:	mov    rdx,r13
    1cb2:	mov    rdi,r14
    1cb5:	call   1cba <botlish_fn_20+0x15a>
			1cb6: R_X86_64_PLT32	rt_int_mod-0x4
    1cba:	test   rax,rax
    1cbd:	jne    1cf1 <botlish_fn_20+0x191>
    1cc3:	mov    rdi,r14
    1cc6:	mov    rdi,r14
    1cc9:	mov    QWORD PTR [rdi],r12
    1ccc:	xor    rax,rax
    1ccf:	mov    rbx,QWORD PTR [rsp+0x10]
    1cd4:	mov    r12,QWORD PTR [rsp+0x18]
    1cd9:	mov    r13,QWORD PTR [rsp+0x20]
    1cde:	mov    r14,QWORD PTR [rsp+0x28]
    1ce3:	mov    r15,QWORD PTR [rsp+0x30]
    1ce8:	add    rsp,0x40
    1cec:	mov    rsp,rbp
    1cef:	pop    rbp
    1cf0:	ret
    1cf1:	mov    QWORD PTR [r12],rbx
    1cf5:	mov    QWORD PTR [r12+0x8],rax
    1cfa:	mov    QWORD PTR [r12+0x10],r13
    1cff:	mov    r15,rax
    1d02:	jmp    1bdb <botlish_fn_20+0x7b>
    1d07:	mov    rdi,r14
    1d0a:	mov    QWORD PTR [rdi],r12
    1d0d:	mov    rax,r15
    1d10:	mov    rbx,QWORD PTR [rsp+0x10]
    1d15:	mov    r12,QWORD PTR [rsp+0x18]
    1d1a:	mov    r13,QWORD PTR [rsp+0x20]
    1d1f:	mov    r14,QWORD PTR [rsp+0x28]
    1d24:	mov    r15,QWORD PTR [rsp+0x30]
    1d29:	add    rsp,0x40
    1d2d:	mov    rsp,rbp
    1d30:	pop    rbp
    1d31:	ret
    1d32:	mov    r14,rdi
    1d35:	call   1d3a <botlish_fn_20+0x1da>
			1d36: R_X86_64_PLT32	rt_stack_overflow-0x4
    1d3a:	xor    rax,rax
    1d3d:	mov    rbx,QWORD PTR [rsp+0x10]
    1d42:	mov    r12,QWORD PTR [rsp+0x18]
    1d47:	mov    r13,QWORD PTR [rsp+0x20]
    1d4c:	mov    r14,QWORD PTR [rsp+0x28]
    1d51:	mov    r15,QWORD PTR [rsp+0x30]
    1d56:	add    rsp,0x40
    1d5a:	mov    rsp,rbp
    1d5d:	pop    rbp
    1d5e:	ret
    1d5f:	add    BYTE PTR [rsi],al
    1d61:	add    BYTE PTR [rax],al
    1d63:	add    BYTE PTR [rax],al
    1d65:	add    BYTE PTR [rax],al
	...

0000000000001d68 <botlish_entry_20: ht_rehash_probe<mutarray, int, int>>:
    1d68:	push   rbp
    1d69:	mov    rbp,rsp
    1d6c:	mov    rsi,QWORD PTR [rdx]
    1d6f:	mov    r8,QWORD PTR [rdx+0x8]
    1d73:	mov    rcx,QWORD PTR [rdx+0x10]
    1d77:	mov    rdx,r8
    1d7a:	call   1d7f <botlish_entry_20+0x17>
			1d7b: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    1d7f:	mov    rsp,rbp
    1d82:	pop    rbp
    1d83:	ret

0000000000001d84 <botlish_fn_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    1d84:	push   rbp
    1d85:	mov    rbp,rsp
    1d88:	sub    rsp,0x50
    1d8c:	mov    QWORD PTR [rsp+0x20],rbx
    1d91:	mov    QWORD PTR [rsp+0x28],r12
    1d96:	mov    QWORD PTR [rsp+0x30],r13
    1d9b:	mov    QWORD PTR [rsp+0x38],r14
    1da0:	mov    QWORD PTR [rsp+0x40],r15
    1da5:	mov    r10,QWORD PTR [rbp+0x10]
    1da9:	mov    rbx,QWORD PTR [rdi]
    1dac:	mov    rax,QWORD PTR [rdi+0x8]
    1db0:	lea    r11,[rbx+0x38]
    1db4:	cmp    r11,rax
    1db7:	ja     1f76 <botlish_fn_21+0x1f2>
    1dbd:	lea    rax,[rbx+0x38]
    1dc1:	mov    QWORD PTR [rdi],rax
    1dc4:	mov    r12,rdi
    1dc7:	mov    QWORD PTR [rbx],0x0
    1dce:	mov    QWORD PTR [rbx+0x8],0x0
    1dd6:	mov    QWORD PTR [rbx+0x10],0x0
    1dde:	mov    QWORD PTR [rbx+0x18],0x0
    1de6:	mov    QWORD PTR [rbx+0x20],0x0
    1dee:	mov    QWORD PTR [rbx+0x28],0x0
    1df6:	mov    QWORD PTR [rbx+0x30],0x0
    1dfe:	mov    QWORD PTR [rbx],rsi
    1e01:	mov    QWORD PTR [rsp],rsi
    1e05:	mov    QWORD PTR [rbx+0x8],rdx
    1e09:	mov    QWORD PTR [rsp+0x8],rdx
    1e0e:	mov    QWORD PTR [rbx+0x10],rcx
    1e12:	mov    r13,rcx
    1e15:	mov    QWORD PTR [rbx+0x18],r8
    1e19:	mov    QWORD PTR [rsp+0x10],r8
    1e1e:	mov    QWORD PTR [rbx+0x20],r9
    1e22:	mov    r15,r9
    1e25:	mov    QWORD PTR [rbx+0x28],r10
    1e29:	mov    r14,r10
    1e2c:	mov    rsi,r15
    1e2f:	mov    rdi,r12
    1e32:	call   1e37 <botlish_fn_21+0xb3>
			1e33: R_X86_64_PLT32	rt_hash-0x4
    1e37:	test   rax,rax
    1e3a:	mov    rsi,rax
    1e3d:	jne    1e4b <botlish_fn_21+0xc7>
    1e43:	mov    rdi,r12
    1e46:	jmp    1f1e <botlish_fn_21+0x19a>
    1e4b:	mov    rdx,QWORD PTR [rsp+0x10]
    1e50:	mov    rdi,r12
    1e53:	call   1e58 <botlish_fn_21+0xd4>
			1e54: R_X86_64_PLT32	rt_int_mod-0x4
    1e58:	test   rax,rax
    1e5b:	jne    1e69 <botlish_fn_21+0xe5>
    1e61:	mov    rdi,r12
    1e64:	jmp    1f1e <botlish_fn_21+0x19a>
    1e69:	mov    QWORD PTR [rbx+0x30],rax
    1e6d:	mov    rcx,QWORD PTR [rsp+0x10]
    1e72:	mov    rdx,rax
    1e75:	mov    rsi,QWORD PTR [rsp]
    1e79:	mov    rdi,r12
    1e7c:	call   1e81 <botlish_fn_21+0xfd>
			1e7d: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_rehash_probe<mutarray, int, int>
    1e81:	test   rax,rax
    1e84:	jne    1e92 <botlish_fn_21+0x10e>
    1e8a:	mov    rdi,r12
    1e8d:	jmp    1f1e <botlish_fn_21+0x19a>
    1e92:	mov    QWORD PTR [rbx+0x18],rax
    1e96:	mov    QWORD PTR [rsp+0x10],rax
    1e9b:	mov    rdi,r12
    1e9e:	call   1ea3 <botlish_fn_21+0x11f>
			1e9f: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    1ea3:	test   rax,rax
    1ea6:	mov    rcx,rax
    1ea9:	jne    1eb7 <botlish_fn_21+0x133>
    1eaf:	mov    rdi,r12
    1eb2:	jmp    1f1e <botlish_fn_21+0x19a>
    1eb7:	mov    rsi,QWORD PTR [rsp]
    1ebb:	mov    rdx,QWORD PTR [rsp+0x10]
    1ec0:	mov    rdi,r12
    1ec3:	call   1ec8 <botlish_fn_21+0x144>
			1ec4: R_X86_64_PLT32	rt_mutarray_set-0x4
    1ec8:	test   rax,rax
    1ecb:	jne    1ed9 <botlish_fn_21+0x155>
    1ed1:	mov    rdi,r12
    1ed4:	jmp    1f1e <botlish_fn_21+0x19a>
    1ed9:	mov    rcx,r15
    1edc:	mov    rsi,QWORD PTR [rsp+0x8]
    1ee1:	mov    rdx,QWORD PTR [rsp+0x10]
    1ee6:	mov    rdi,r12
    1ee9:	call   1eee <botlish_fn_21+0x16a>
			1eea: R_X86_64_PLT32	rt_mutarray_set-0x4
    1eee:	test   rax,rax
    1ef1:	jne    1eff <botlish_fn_21+0x17b>
    1ef7:	mov    rdi,r12
    1efa:	jmp    1f1e <botlish_fn_21+0x19a>
    1eff:	mov    rcx,r14
    1f02:	mov    rdx,QWORD PTR [rsp+0x10]
    1f07:	mov    rsi,r13
    1f0a:	mov    rdi,r12
    1f0d:	call   1f12 <botlish_fn_21+0x18e>
			1f0e: R_X86_64_PLT32	rt_mutarray_set-0x4
    1f12:	test   rax,rax
    1f15:	jne    1f49 <botlish_fn_21+0x1c5>
    1f1b:	mov    rdi,r12
    1f1e:	mov    rdi,r12
    1f21:	mov    QWORD PTR [rdi],rbx
    1f24:	xor    rax,rax
    1f27:	mov    rbx,QWORD PTR [rsp+0x20]
    1f2c:	mov    r12,QWORD PTR [rsp+0x28]
    1f31:	mov    r13,QWORD PTR [rsp+0x30]
    1f36:	mov    r14,QWORD PTR [rsp+0x38]
    1f3b:	mov    r15,QWORD PTR [rsp+0x40]
    1f40:	add    rsp,0x50
    1f44:	mov    rsp,rbp
    1f47:	pop    rbp
    1f48:	ret
    1f49:	mov    rdi,r12
    1f4c:	mov    QWORD PTR [rdi],rbx
    1f4f:	mov    eax,0xa
    1f54:	mov    rbx,QWORD PTR [rsp+0x20]
    1f59:	mov    r12,QWORD PTR [rsp+0x28]
    1f5e:	mov    r13,QWORD PTR [rsp+0x30]
    1f63:	mov    r14,QWORD PTR [rsp+0x38]
    1f68:	mov    r15,QWORD PTR [rsp+0x40]
    1f6d:	add    rsp,0x50
    1f71:	mov    rsp,rbp
    1f74:	pop    rbp
    1f75:	ret
    1f76:	mov    r12,rdi
    1f79:	call   1f7e <botlish_fn_21+0x1fa>
			1f7a: R_X86_64_PLT32	rt_stack_overflow-0x4
    1f7e:	xor    rax,rax
    1f81:	mov    rbx,QWORD PTR [rsp+0x20]
    1f86:	mov    r12,QWORD PTR [rsp+0x28]
    1f8b:	mov    r13,QWORD PTR [rsp+0x30]
    1f90:	mov    r14,QWORD PTR [rsp+0x38]
    1f95:	mov    r15,QWORD PTR [rsp+0x40]
    1f9a:	add    rsp,0x50
    1f9e:	mov    rsp,rbp
    1fa1:	pop    rbp
    1fa2:	ret

0000000000001fa3 <botlish_entry_21: ht_rehash_insert<list<mutarray>, int, any, any>>:
    1fa3:	push   rbp
    1fa4:	mov    rbp,rsp
    1fa7:	sub    rsp,0x10
    1fab:	mov    rsi,QWORD PTR [rdx]
    1fae:	mov    r10,QWORD PTR [rdx+0x8]
    1fb2:	mov    rcx,QWORD PTR [rdx+0x10]
    1fb6:	mov    r8,QWORD PTR [rdx+0x18]
    1fba:	mov    r9,QWORD PTR [rdx+0x20]
    1fbe:	mov    r11,QWORD PTR [rdx+0x28]
    1fc2:	mov    QWORD PTR [rsp],r11
    1fc6:	mov    rdx,r10
    1fc9:	call   1fce <botlish_entry_21+0x2b>
			1fca: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    1fce:	add    rsp,0x10
    1fd2:	mov    rsp,rbp
    1fd5:	pop    rbp
    1fd6:	ret
	...

0000000000001fd8 <botlish_fn_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    1fd8:	push   rbp
    1fd9:	mov    rbp,rsp
    1fdc:	sub    rsp,0x80
    1fe3:	mov    QWORD PTR [rsp+0x50],rbx
    1fe8:	mov    QWORD PTR [rsp+0x58],r12
    1fed:	mov    QWORD PTR [rsp+0x60],r13
    1ff2:	mov    QWORD PTR [rsp+0x68],r14
    1ff7:	mov    QWORD PTR [rsp+0x70],r15
    1ffc:	mov    r13,QWORD PTR [rbp+0x10]
    2000:	mov    r14,QWORD PTR [rbp+0x18]
    2004:	mov    r12,r14
    2007:	mov    r15,QWORD PTR [rbp+0x20]
    200b:	mov    r14,QWORD PTR [rbp+0x28]
    200f:	mov    QWORD PTR [rsp+0x38],r14
    2014:	mov    r14,QWORD PTR [rdi]
    2017:	mov    r11,QWORD PTR [rdi+0x8]
    201b:	lea    rax,[r14+0x58]
    201f:	cmp    rax,r11
    2022:	ja     2479 <botlish_fn_22+0x4a1>
    2028:	lea    rax,[r14+0x58]
    202c:	mov    QWORD PTR [rdi],rax
    202f:	mov    QWORD PTR [rsp+0x10],rdi
    2034:	mov    QWORD PTR [r14],0x0
    203b:	mov    QWORD PTR [r14+0x8],0x0
    2043:	mov    QWORD PTR [r14+0x10],0x0
    204b:	mov    QWORD PTR [r14+0x18],0x0
    2053:	mov    QWORD PTR [r14+0x20],0x0
    205b:	mov    QWORD PTR [r14+0x28],0x0
    2063:	mov    QWORD PTR [r14+0x30],0x0
    206b:	mov    QWORD PTR [r14+0x38],0x0
    2073:	mov    QWORD PTR [r14+0x40],0x0
    207b:	mov    QWORD PTR [r14+0x48],0x0
    2083:	mov    QWORD PTR [r14+0x50],0x0
    208b:	mov    QWORD PTR [r14],rsi
    208e:	mov    QWORD PTR [rsp+0x18],rsi
    2093:	mov    QWORD PTR [r14+0x8],rdx
    2097:	mov    QWORD PTR [rsp+0x20],rdx
    209c:	mov    QWORD PTR [r14+0x10],rcx
    20a0:	mov    QWORD PTR [rsp+0x28],rcx
    20a5:	mov    QWORD PTR [r14+0x18],r8
    20a9:	mov    QWORD PTR [r14+0x20],r9
    20ad:	mov    QWORD PTR [rsp+0x30],r9
    20b2:	mov    QWORD PTR [r14+0x28],r13
    20b6:	mov    r9,r12
    20b9:	mov    QWORD PTR [r14+0x30],r9
    20bd:	mov    QWORD PTR [r14+0x38],r15
    20c1:	mov    rax,QWORD PTR [rsp+0x38]
    20c6:	mov    QWORD PTR [r14+0x40],rax
    20ca:	mov    rbx,QWORD PTR [rsp+0x30]
    20cf:	mov    rsi,r8
    20d2:	mov    rax,rsi
    20d5:	and    rax,rbx
    20d8:	mov    QWORD PTR [rsp+0x40],rsi
    20dd:	test   rax,0x1
    20e3:	jne    2115 <botlish_fn_22+0x13d>
    20e9:	mov    rdx,rbx
    20ec:	mov    rsi,QWORD PTR [rsp+0x40]
    20f1:	mov    rdi,QWORD PTR [rsp+0x10]
    20f6:	call   20fb <botlish_fn_22+0x123>
			20f7: R_X86_64_PLT32	rt_int_cmp-0x4
    20fb:	mov    QWORD PTR [rsp+0x30],rbx
    2100:	mov    ecx,0x2
    2105:	test   rax,rax
    2108:	cmovge rcx,QWORD PTR [rip+0x3a0]        # 24b0 <botlish_fn_22+0x4d8>
    2110:	jmp    2134 <botlish_fn_22+0x15c>
    2115:	mov    QWORD PTR [rsp+0x30],rbx
    211a:	mov    ecx,0x2
    211f:	mov    rsi,QWORD PTR [rsp+0x40]
    2124:	mov    r9,QWORD PTR [rsp+0x30]
    2129:	cmp    rsi,r9
    212c:	cmovge rcx,QWORD PTR [rip+0x37c]        # 24b0 <botlish_fn_22+0x4d8>
    2134:	cmp    rcx,0x6
    2138:	je     2447 <botlish_fn_22+0x46f>
    213e:	xor    eax,eax
    2140:	mov    rsi,QWORD PTR [rsp+0x18]
    2145:	test   rsi,0x7
    214c:	jne    215b <botlish_fn_22+0x183>
    2152:	movzx  rax,BYTE PTR [rsi]
    2156:	cmp    al,0x8
    2158:	sete   al
    215b:	test   al,al
    215d:	jne    2184 <botlish_fn_22+0x1ac>
    2163:	mov    rdi,QWORD PTR [rsp+0x10]
    2168:	mov    rax,QWORD PTR [rdi+0x10]
    216c:	mov    rcx,QWORD PTR [rax+0x8]
    2170:	mov    edx,0x8
    2175:	call   217a <botlish_fn_22+0x1a2>
			2176: R_X86_64_PLT32	rt_type_error-0x4
    217a:	mov    rdi,QWORD PTR [rsp+0x10]
    217f:	jmp    236e <botlish_fn_22+0x396>
    2184:	mov    QWORD PTR [rsp+0x18],rsi
    2189:	mov    rdx,QWORD PTR [rsp+0x40]
    218e:	mov    rdi,QWORD PTR [rsp+0x10]
    2193:	call   2198 <botlish_fn_22+0x1c0>
			2194: R_X86_64_PLT32	rt_mutarray_get-0x4
    2198:	test   rax,rax
    219b:	jne    21ab <botlish_fn_22+0x1d3>
    21a1:	mov    rdi,QWORD PTR [rsp+0x10]
    21a6:	jmp    236e <botlish_fn_22+0x396>
    21ab:	mov    QWORD PTR [r14+0x48],rax
    21af:	mov    rbx,rax
    21b2:	mov    rdi,QWORD PTR [rsp+0x10]
    21b7:	call   21bc <botlish_fn_22+0x1e4>
			21b8: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    21bc:	test   rax,rax
    21bf:	jne    21cf <botlish_fn_22+0x1f7>
    21c5:	mov    rdi,QWORD PTR [rsp+0x10]
    21ca:	jmp    236e <botlish_fn_22+0x396>
    21cf:	mov    rdx,rbx
    21d2:	mov    rcx,rdx
    21d5:	and    rcx,rax
    21d8:	mov    rdx,rax
    21db:	test   rcx,0x1
    21e2:	jne    2208 <botlish_fn_22+0x230>
    21e8:	mov    rsi,rbx
    21eb:	mov    rdi,QWORD PTR [rsp+0x10]
    21f0:	call   21f5 <botlish_fn_22+0x21d>
			21f1: R_X86_64_PLT32	rt_value_eq-0x4
    21f5:	test   rax,rax
    21f8:	jne    221b <botlish_fn_22+0x243>
    21fe:	mov    rdi,QWORD PTR [rsp+0x10]
    2203:	jmp    236e <botlish_fn_22+0x396>
    2208:	mov    rsi,rbx
    220b:	mov    eax,0x2
    2210:	cmp    rsi,rdx
    2213:	cmove  rax,QWORD PTR [rip+0x295]        # 24b0 <botlish_fn_22+0x4d8>
    221b:	cmp    rax,0x6
    221f:	je     222f <botlish_fn_22+0x257>
    2225:	mov    rbx,QWORD PTR [rsp+0x38]
    222a:	jmp    239e <botlish_fn_22+0x3c6>
    222f:	xor    eax,eax
    2231:	mov    rdx,QWORD PTR [rsp+0x20]
    2236:	test   rdx,0x7
    223d:	je     224d <botlish_fn_22+0x275>
    2243:	mov    QWORD PTR [rsp+0x20],rdx
    2248:	jmp    225d <botlish_fn_22+0x285>
    224d:	movzx  r10,BYTE PTR [rdx]
    2251:	mov    QWORD PTR [rsp+0x20],rdx
    2256:	cmp    r10b,0x8
    225a:	sete   al
    225d:	test   al,al
    225f:	jne    228b <botlish_fn_22+0x2b3>
    2265:	mov    rdi,QWORD PTR [rsp+0x10]
    226a:	mov    rax,QWORD PTR [rdi+0x10]
    226e:	mov    rcx,QWORD PTR [rax+0x8]
    2272:	mov    edx,0x8
    2277:	mov    rsi,QWORD PTR [rsp+0x20]
    227c:	call   2281 <botlish_fn_22+0x2a9>
			227d: R_X86_64_PLT32	rt_type_error-0x4
    2281:	mov    rdi,QWORD PTR [rsp+0x10]
    2286:	jmp    236e <botlish_fn_22+0x396>
    228b:	mov    rdx,QWORD PTR [rsp+0x40]
    2290:	mov    rsi,QWORD PTR [rsp+0x20]
    2295:	mov    rdi,QWORD PTR [rsp+0x10]
    229a:	call   229f <botlish_fn_22+0x2c7>
			229b: R_X86_64_PLT32	rt_mutarray_get-0x4
    229f:	test   rax,rax
    22a2:	jne    22b2 <botlish_fn_22+0x2da>
    22a8:	mov    rdi,QWORD PTR [rsp+0x10]
    22ad:	jmp    236e <botlish_fn_22+0x396>
    22b2:	mov    QWORD PTR [r14+0x48],rax
    22b6:	mov    rbx,rax
    22b9:	xor    eax,eax
    22bb:	mov    rcx,QWORD PTR [rsp+0x28]
    22c0:	test   rcx,0x7
    22c7:	je     22d7 <botlish_fn_22+0x2ff>
    22cd:	mov    QWORD PTR [rsp+0x28],rcx
    22d2:	jmp    22e5 <botlish_fn_22+0x30d>
    22d7:	movzx  rax,BYTE PTR [rcx]
    22db:	mov    QWORD PTR [rsp+0x28],rcx
    22e0:	cmp    al,0x8
    22e2:	sete   al
    22e5:	test   al,al
    22e7:	jne    2313 <botlish_fn_22+0x33b>
    22ed:	mov    rdi,QWORD PTR [rsp+0x10]
    22f2:	mov    rax,QWORD PTR [rdi+0x10]
    22f6:	mov    rcx,QWORD PTR [rax+0x8]
    22fa:	mov    edx,0x8
    22ff:	mov    rsi,QWORD PTR [rsp+0x28]
    2304:	call   2309 <botlish_fn_22+0x331>
			2305: R_X86_64_PLT32	rt_type_error-0x4
    2309:	mov    rdi,QWORD PTR [rsp+0x10]
    230e:	jmp    236e <botlish_fn_22+0x396>
    2313:	mov    rdx,QWORD PTR [rsp+0x40]
    2318:	mov    rsi,QWORD PTR [rsp+0x28]
    231d:	mov    rdi,QWORD PTR [rsp+0x10]
    2322:	call   2327 <botlish_fn_22+0x34f>
			2323: R_X86_64_PLT32	rt_mutarray_get-0x4
    2327:	test   rax,rax
    232a:	jne    233a <botlish_fn_22+0x362>
    2330:	mov    rdi,QWORD PTR [rsp+0x10]
    2335:	jmp    236e <botlish_fn_22+0x396>
    233a:	mov    QWORD PTR [r14+0x50],rax
    233e:	mov    QWORD PTR [rsp],rax
    2342:	mov    r9,rbx
    2345:	mov    rbx,QWORD PTR [rsp+0x38]
    234a:	mov    rcx,r15
    234d:	mov    rdx,r12
    2350:	mov    rsi,r13
    2353:	mov    rdi,QWORD PTR [rsp+0x10]
    2358:	mov    r8,rbx
    235b:	call   2360 <botlish_fn_22+0x388>
			235c: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_rehash_insert<list<mutarray>, int, any, any>
    2360:	test   rax,rax
    2363:	jne    239e <botlish_fn_22+0x3c6>
    2369:	mov    rdi,QWORD PTR [rsp+0x10]
    236e:	mov    rdi,QWORD PTR [rsp+0x10]
    2373:	mov    QWORD PTR [rdi],r14
    2376:	xor    rax,rax
    2379:	mov    rbx,QWORD PTR [rsp+0x50]
    237e:	mov    r12,QWORD PTR [rsp+0x58]
    2383:	mov    r13,QWORD PTR [rsp+0x60]
    2388:	mov    r14,QWORD PTR [rsp+0x68]
    238d:	mov    r15,QWORD PTR [rsp+0x70]
    2392:	add    rsp,0x80
    2399:	mov    rsp,rbp
    239c:	pop    rbp
    239d:	ret
    239e:	mov    QWORD PTR [r14+0x48],0x3
    23a6:	mov    rsi,QWORD PTR [rsp+0x40]
    23ab:	test   rsi,0x1
    23b2:	je     23de <botlish_fn_22+0x406>
    23b8:	mov    rsi,QWORD PTR [rsp+0x40]
    23bd:	mov    rcx,rsi
    23c0:	add    rcx,0x2
    23c4:	seto   al
    23c7:	test   al,al
    23c9:	jne    23de <botlish_fn_22+0x406>
    23cf:	mov    QWORD PTR [rsp+0x40],rcx
    23d4:	mov    rcx,QWORD PTR [rsp+0x18]
    23d9:	jmp    23fc <botlish_fn_22+0x424>
    23de:	mov    edx,0x3
    23e3:	mov    rsi,QWORD PTR [rsp+0x40]
    23e8:	mov    rdi,QWORD PTR [rsp+0x10]
    23ed:	call   23f2 <botlish_fn_22+0x41a>
			23ee: R_X86_64_PLT32	rt_int_add-0x4
    23f2:	mov    rcx,QWORD PTR [rsp+0x18]
    23f7:	mov    QWORD PTR [rsp+0x40],rax
    23fc:	mov    rcx,QWORD PTR [rsp+0x18]
    2401:	mov    QWORD PTR [r14],rcx
    2404:	mov    rsi,QWORD PTR [rsp+0x20]
    2409:	mov    QWORD PTR [r14+0x8],rsi
    240d:	mov    rsi,QWORD PTR [rsp+0x28]
    2412:	mov    QWORD PTR [r14+0x10],rsi
    2416:	mov    rsi,QWORD PTR [rsp+0x40]
    241b:	mov    QWORD PTR [r14+0x18],rsi
    241f:	mov    r9,QWORD PTR [rsp+0x30]
    2424:	mov    QWORD PTR [r14+0x20],r9
    2428:	mov    QWORD PTR [r14+0x28],r13
    242c:	mov    QWORD PTR [r14+0x30],r12
    2430:	mov    QWORD PTR [r14+0x38],r15
    2434:	mov    QWORD PTR [r14+0x40],rbx
    2438:	mov    QWORD PTR [rsp+0x38],rbx
    243d:	mov    rbx,QWORD PTR [rsp+0x30]
    2442:	jmp    20d2 <botlish_fn_22+0xfa>
    2447:	mov    rdi,QWORD PTR [rsp+0x10]
    244c:	mov    QWORD PTR [rdi],r14
    244f:	mov    eax,0xa
    2454:	mov    rbx,QWORD PTR [rsp+0x50]
    2459:	mov    r12,QWORD PTR [rsp+0x58]
    245e:	mov    r13,QWORD PTR [rsp+0x60]
    2463:	mov    r14,QWORD PTR [rsp+0x68]
    2468:	mov    r15,QWORD PTR [rsp+0x70]
    246d:	add    rsp,0x80
    2474:	mov    rsp,rbp
    2477:	pop    rbp
    2478:	ret
    2479:	mov    QWORD PTR [rsp+0x10],rdi
    247e:	call   2483 <botlish_fn_22+0x4ab>
			247f: R_X86_64_PLT32	rt_stack_overflow-0x4
    2483:	xor    rax,rax
    2486:	mov    rbx,QWORD PTR [rsp+0x50]
    248b:	mov    r12,QWORD PTR [rsp+0x58]
    2490:	mov    r13,QWORD PTR [rsp+0x60]
    2495:	mov    r14,QWORD PTR [rsp+0x68]
    249a:	mov    r15,QWORD PTR [rsp+0x70]
    249f:	add    rsp,0x80
    24a6:	mov    rsp,rbp
    24a9:	pop    rbp
    24aa:	ret
    24ab:	add    BYTE PTR [rax],al
    24ad:	add    BYTE PTR [rax],al
    24af:	add    BYTE PTR [rsi],al
    24b1:	add    BYTE PTR [rax],al
    24b3:	add    BYTE PTR [rax],al
    24b5:	add    BYTE PTR [rax],al
	...

00000000000024b8 <botlish_entry_22: ht_rehash_scan<list, int, int, list<mutarray>, int>>:
    24b8:	push   rbp
    24b9:	mov    rbp,rsp
    24bc:	sub    rsp,0x30
    24c0:	mov    QWORD PTR [rsp+0x20],r12
    24c5:	mov    rsi,QWORD PTR [rdx]
    24c8:	mov    rax,QWORD PTR [rdx+0x8]
    24cc:	mov    rcx,QWORD PTR [rdx+0x10]
    24d0:	mov    r8,QWORD PTR [rdx+0x18]
    24d4:	mov    r9,QWORD PTR [rdx+0x20]
    24d8:	mov    r10,QWORD PTR [rdx+0x28]
    24dc:	mov    r11,QWORD PTR [rdx+0x30]
    24e0:	mov    r12,QWORD PTR [rdx+0x38]
    24e4:	mov    rdx,QWORD PTR [rdx+0x40]
    24e8:	mov    QWORD PTR [rsp],r10
    24ec:	mov    QWORD PTR [rsp+0x8],r11
    24f1:	mov    QWORD PTR [rsp+0x10],r12
    24f6:	mov    QWORD PTR [rsp+0x18],rdx
    24fb:	mov    rdx,rax
    24fe:	call   2503 <botlish_entry_22+0x4b>
			24ff: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    2503:	mov    r12,QWORD PTR [rsp+0x20]
    2508:	add    rsp,0x30
    250c:	mov    rsp,rbp
    250f:	pop    rbp
    2510:	ret

0000000000002511 <botlish_fn_23: ht_rehash<mutarray, int>>:
    2511:	push   rbp
    2512:	mov    rbp,rsp
    2515:	sub    rsp,0x80
    251c:	mov    QWORD PTR [rsp+0x50],rbx
    2521:	mov    QWORD PTR [rsp+0x58],r12
    2526:	mov    QWORD PTR [rsp+0x60],r13
    252b:	mov    QWORD PTR [rsp+0x68],r14
    2530:	mov    QWORD PTR [rsp+0x70],r15
    2535:	mov    r12,QWORD PTR [rdi]
    2538:	mov    rax,QWORD PTR [rdi+0x8]
    253c:	lea    rcx,[r12+0x50]
    2541:	cmp    rcx,rax
    2544:	ja     2844 <botlish_fn_23+0x333>
    254a:	lea    rax,[r12+0x50]
    254f:	mov    QWORD PTR [rdi],rax
    2552:	mov    r13,rdi
    2555:	mov    QWORD PTR [r12],0x0
    255d:	mov    QWORD PTR [r12+0x8],0x0
    2566:	mov    QWORD PTR [r12+0x10],0x0
    256f:	mov    QWORD PTR [r12+0x18],0x0
    2578:	mov    QWORD PTR [r12+0x20],0x0
    2581:	mov    QWORD PTR [r12+0x28],0x0
    258a:	mov    QWORD PTR [r12+0x30],0x0
    2593:	mov    QWORD PTR [r12+0x38],0x0
    259c:	mov    QWORD PTR [r12+0x40],0x0
    25a5:	mov    QWORD PTR [r12+0x48],0x0
    25ae:	mov    QWORD PTR [r12],rsi
    25b2:	mov    r14,rsi
    25b5:	mov    QWORD PTR [r12+0x8],rdx
    25ba:	mov    rbx,rdx
    25bd:	mov    rsi,r14
    25c0:	mov    rdi,r13
    25c3:	call   25c8 <botlish_fn_23+0xb7>
			25c4: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    25c8:	test   rax,rax
    25cb:	jne    25d9 <botlish_fn_23+0xc8>
    25d1:	mov    rdi,r13
    25d4:	jmp    27e6 <botlish_fn_23+0x2d5>
    25d9:	mov    QWORD PTR [r12+0x10],rax
    25de:	mov    r15,rax
    25e1:	mov    rsi,r14
    25e4:	mov    rdi,r13
    25e7:	call   25ec <botlish_fn_23+0xdb>
			25e8: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    25ec:	test   rax,rax
    25ef:	jne    25fd <botlish_fn_23+0xec>
    25f5:	mov    rdi,r13
    25f8:	jmp    27e6 <botlish_fn_23+0x2d5>
    25fd:	mov    QWORD PTR [r12+0x18],rax
    2602:	mov    QWORD PTR [rsp+0x48],rax
    2607:	mov    rsi,r14
    260a:	mov    rdi,r13
    260d:	call   2612 <botlish_fn_23+0x101>
			260e: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    2612:	test   rax,rax
    2615:	jne    2623 <botlish_fn_23+0x112>
    261b:	mov    rdi,r13
    261e:	jmp    27e6 <botlish_fn_23+0x2d5>
    2623:	mov    QWORD PTR [r12+0x20],rax
    2628:	mov    QWORD PTR [rsp+0x40],rax
    262d:	mov    rsi,r14
    2630:	mov    rdi,r13
    2633:	call   2638 <botlish_fn_23+0x127>
			2634: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2638:	test   rax,rax
    263b:	jne    2649 <botlish_fn_23+0x138>
    2641:	mov    rdi,r13
    2644:	jmp    27e6 <botlish_fn_23+0x2d5>
    2649:	mov    QWORD PTR [r12+0x28],rax
    264e:	mov    QWORD PTR [rsp+0x38],rax
    2653:	mov    rsi,rbx
    2656:	mov    rdi,r13
    2659:	call   265e <botlish_fn_23+0x14d>
			265a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    265e:	mov    rcx,rax
    2661:	mov    QWORD PTR [rsp+0x30],rax
    2666:	test   rax,rcx
    2669:	jne    2677 <botlish_fn_23+0x166>
    266f:	mov    rdi,r13
    2672:	jmp    27e6 <botlish_fn_23+0x2d5>
    2677:	mov    rax,QWORD PTR [rsp+0x30]
    267c:	mov    QWORD PTR [r12+0x30],rax
    2681:	mov    edx,0x1
    2686:	mov    QWORD PTR [r12+0x38],0x1
    268f:	mov    rcx,rbx
    2692:	mov    rsi,QWORD PTR [rsp+0x30]
    2697:	mov    rdi,r13
    269a:	call   269f <botlish_fn_23+0x18e>
			269b: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_fill_empty<mutarray, int, int>
    269f:	test   rax,rax
    26a2:	jne    26b0 <botlish_fn_23+0x19f>
    26a8:	mov    rdi,r13
    26ab:	jmp    27e6 <botlish_fn_23+0x2d5>
    26b0:	mov    rsi,rbx
    26b3:	mov    rdi,r13
    26b6:	call   26bb <botlish_fn_23+0x1aa>
			26b7: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    26bb:	test   rax,rax
    26be:	jne    26cc <botlish_fn_23+0x1bb>
    26c4:	mov    rdi,r13
    26c7:	jmp    27e6 <botlish_fn_23+0x2d5>
    26cc:	mov    QWORD PTR [r12+0x38],rax
    26d1:	mov    QWORD PTR [rsp+0x28],rax
    26d6:	mov    rsi,rbx
    26d9:	mov    rdi,r13
    26dc:	call   26e1 <botlish_fn_23+0x1d0>
			26dd: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    26e1:	test   rax,rax
    26e4:	jne    26f2 <botlish_fn_23+0x1e1>
    26ea:	mov    rdi,r13
    26ed:	jmp    27e6 <botlish_fn_23+0x2d5>
    26f2:	mov    QWORD PTR [r12+0x40],rax
    26f7:	mov    r8d,0x1
    26fd:	mov    QWORD PTR [r12+0x48],0x1
    2706:	mov    rcx,QWORD PTR [rsp+0x30]
    270b:	mov    QWORD PTR [rsp],rcx
    270f:	mov    rcx,QWORD PTR [rsp+0x28]
    2714:	mov    QWORD PTR [rsp+0x8],rcx
    2719:	mov    QWORD PTR [rsp+0x10],rax
    271e:	mov    QWORD PTR [rsp+0x20],rax
    2723:	mov    QWORD PTR [rsp+0x18],rbx
    2728:	mov    rcx,QWORD PTR [rsp+0x40]
    272d:	mov    rdx,QWORD PTR [rsp+0x48]
    2732:	mov    rsi,r15
    2735:	mov    r9,QWORD PTR [rsp+0x38]
    273a:	mov    rdi,r13
    273d:	call   2742 <botlish_fn_23+0x231>
			273e: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_rehash_scan<list, int, int, list<mutarray>, int>
    2742:	test   rax,rax
    2745:	jne    2753 <botlish_fn_23+0x242>
    274b:	mov    rdi,r13
    274e:	jmp    27e6 <botlish_fn_23+0x2d5>
    2753:	mov    edx,0x1
    2758:	mov    rcx,QWORD PTR [rsp+0x30]
    275d:	mov    rsi,r14
    2760:	mov    rdi,r13
    2763:	call   2768 <botlish_fn_23+0x257>
			2764: R_X86_64_PLT32	rt_mutarray_set-0x4
    2768:	test   rax,rax
    276b:	jne    2779 <botlish_fn_23+0x268>
    2771:	mov    rdi,r13
    2774:	jmp    27e6 <botlish_fn_23+0x2d5>
    2779:	mov    edx,0x3
    277e:	mov    rcx,QWORD PTR [rsp+0x28]
    2783:	mov    rsi,r14
    2786:	mov    rdi,r13
    2789:	call   278e <botlish_fn_23+0x27d>
			278a: R_X86_64_PLT32	rt_mutarray_set-0x4
    278e:	test   rax,rax
    2791:	jne    279f <botlish_fn_23+0x28e>
    2797:	mov    rdi,r13
    279a:	jmp    27e6 <botlish_fn_23+0x2d5>
    279f:	mov    edx,0x5
    27a4:	mov    rcx,QWORD PTR [rsp+0x20]
    27a9:	mov    rsi,r14
    27ac:	mov    rdi,r13
    27af:	call   27b4 <botlish_fn_23+0x2a3>
			27b0: R_X86_64_PLT32	rt_mutarray_set-0x4
    27b4:	test   rax,rax
    27b7:	jne    27c5 <botlish_fn_23+0x2b4>
    27bd:	mov    rdi,r13
    27c0:	jmp    27e6 <botlish_fn_23+0x2d5>
    27c5:	mov    edx,0x9
    27ca:	mov    ecx,0x1
    27cf:	mov    rsi,r14
    27d2:	mov    rdi,r13
    27d5:	call   27da <botlish_fn_23+0x2c9>
			27d6: R_X86_64_PLT32	rt_mutarray_set-0x4
    27da:	test   rax,rax
    27dd:	jne    2814 <botlish_fn_23+0x303>
    27e3:	mov    rdi,r13
    27e6:	mov    rdi,r13
    27e9:	mov    QWORD PTR [rdi],r12
    27ec:	xor    rax,rax
    27ef:	mov    rbx,QWORD PTR [rsp+0x50]
    27f4:	mov    r12,QWORD PTR [rsp+0x58]
    27f9:	mov    r13,QWORD PTR [rsp+0x60]
    27fe:	mov    r14,QWORD PTR [rsp+0x68]
    2803:	mov    r15,QWORD PTR [rsp+0x70]
    2808:	add    rsp,0x80
    280f:	mov    rsp,rbp
    2812:	pop    rbp
    2813:	ret
    2814:	mov    rdi,r13
    2817:	mov    QWORD PTR [rdi],r12
    281a:	mov    eax,0xa
    281f:	mov    rbx,QWORD PTR [rsp+0x50]
    2824:	mov    r12,QWORD PTR [rsp+0x58]
    2829:	mov    r13,QWORD PTR [rsp+0x60]
    282e:	mov    r14,QWORD PTR [rsp+0x68]
    2833:	mov    r15,QWORD PTR [rsp+0x70]
    2838:	add    rsp,0x80
    283f:	mov    rsp,rbp
    2842:	pop    rbp
    2843:	ret
    2844:	mov    r13,rdi
    2847:	call   284c <botlish_fn_23+0x33b>
			2848: R_X86_64_PLT32	rt_stack_overflow-0x4
    284c:	xor    rax,rax
    284f:	mov    rbx,QWORD PTR [rsp+0x50]
    2854:	mov    r12,QWORD PTR [rsp+0x58]
    2859:	mov    r13,QWORD PTR [rsp+0x60]
    285e:	mov    r14,QWORD PTR [rsp+0x68]
    2863:	mov    r15,QWORD PTR [rsp+0x70]
    2868:	add    rsp,0x80
    286f:	mov    rsp,rbp
    2872:	pop    rbp
    2873:	ret

0000000000002874 <botlish_entry_23: ht_rehash<mutarray, int>>:
    2874:	push   rbp
    2875:	mov    rbp,rsp
    2878:	mov    rsi,QWORD PTR [rdx]
    287b:	mov    rdx,QWORD PTR [rdx+0x8]
    287f:	call   2884 <botlish_entry_23+0x10>
			2880: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    2884:	mov    rsp,rbp
    2887:	pop    rbp
    2888:	ret
    2889:	add    BYTE PTR [rax],al
    288b:	add    BYTE PTR [rax],al
    288d:	add    BYTE PTR [rax],al
	...

0000000000002890 <botlish_fn_24: ht_should_grow<mutarray>>:
    2890:	push   rbp
    2891:	mov    rbp,rsp
    2894:	sub    rsp,0x20
    2898:	mov    QWORD PTR [rsp],rbx
    289c:	mov    QWORD PTR [rsp+0x8],r12
    28a1:	mov    QWORD PTR [rsp+0x10],r13
    28a6:	mov    QWORD PTR [rsp+0x18],r14
    28ab:	mov    r12,QWORD PTR [rdi]
    28ae:	mov    r8,QWORD PTR [rdi+0x8]
    28b2:	lea    r9,[r12+0x18]
    28b7:	cmp    r9,r8
    28ba:	ja     2bf3 <botlish_fn_24+0x363>
    28c0:	lea    r9,[r12+0x18]
    28c5:	mov    QWORD PTR [rdi],r9
    28c8:	mov    r13,rdi
    28cb:	mov    QWORD PTR [r12],0x0
    28d3:	mov    QWORD PTR [r12+0x8],0x0
    28dc:	mov    QWORD PTR [r12+0x10],0x0
    28e5:	mov    QWORD PTR [r12],rsi
    28e9:	mov    rbx,rsi
    28ec:	mov    rsi,rbx
    28ef:	mov    rdi,r13
    28f2:	call   28f7 <botlish_fn_24+0x67>
			28f3: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    28f7:	mov    rcx,rax
    28fa:	mov    r14,rax
    28fd:	test   rax,rcx
    2900:	jne    290e <botlish_fn_24+0x7e>
    2906:	mov    rdi,r13
    2909:	jmp    2b0b <botlish_fn_24+0x27b>
    290e:	mov    rax,r14
    2911:	mov    QWORD PTR [r12+0x8],rax
    2916:	mov    rsi,rbx
    2919:	mov    rdi,r13
    291c:	call   2921 <botlish_fn_24+0x91>
			291d: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2921:	mov    rcx,rax
    2924:	test   rcx,rcx
    2927:	jne    2935 <botlish_fn_24+0xa5>
    292d:	mov    rdi,r13
    2930:	jmp    2b0b <botlish_fn_24+0x27b>
    2935:	mov    QWORD PTR [r12+0x10],rcx
    293a:	mov    edx,0x1
    293f:	mov    rax,r14
    2942:	test   rax,0x1
    2948:	jne    296b <botlish_fn_24+0xdb>
    294e:	xor    edx,edx
    2950:	mov    rax,r14
    2953:	test   rax,0x7
    2959:	jne    296b <botlish_fn_24+0xdb>
    295f:	mov    rax,r14
    2962:	movzx  rax,BYTE PTR [rax]
    2966:	cmp    al,0x1
    2968:	sete   dl
    296b:	test   dl,dl
    296d:	jne    2991 <botlish_fn_24+0x101>
    2973:	mov    rdi,r13
    2976:	mov    rax,QWORD PTR [rdi+0x10]
    297a:	mov    rcx,QWORD PTR [rax+0x10]
    297e:	xor    rdx,rdx
    2981:	mov    rsi,r14
    2984:	call   2989 <botlish_fn_24+0xf9>
			2985: R_X86_64_PLT32	rt_type_error-0x4
    2989:	mov    rdi,r13
    298c:	jmp    2b0b <botlish_fn_24+0x27b>
    2991:	mov    eax,0x1
    2996:	test   rcx,0x1
    299d:	je     29ab <botlish_fn_24+0x11b>
    29a3:	mov    r8,rcx
    29a6:	jmp    29ce <botlish_fn_24+0x13e>
    29ab:	xor    eax,eax
    29ad:	test   rcx,0x7
    29b4:	je     29c2 <botlish_fn_24+0x132>
    29ba:	mov    r8,rcx
    29bd:	jmp    29ce <botlish_fn_24+0x13e>
    29c2:	movzx  rax,BYTE PTR [rcx]
    29c6:	mov    r8,rcx
    29c9:	cmp    al,0x1
    29cb:	sete   al
    29ce:	test   al,al
    29d0:	jne    29f4 <botlish_fn_24+0x164>
    29d6:	mov    rdi,r13
    29d9:	mov    rax,QWORD PTR [rdi+0x10]
    29dd:	mov    rcx,QWORD PTR [rax+0x10]
    29e1:	xor    rdx,rdx
    29e4:	mov    rsi,r8
    29e7:	call   29ec <botlish_fn_24+0x15c>
			29e8: R_X86_64_PLT32	rt_type_error-0x4
    29ec:	mov    rdi,r13
    29ef:	jmp    2b0b <botlish_fn_24+0x27b>
    29f4:	mov    rcx,r8
    29f7:	mov    rsi,r14
    29fa:	mov    rax,rsi
    29fd:	and    rax,rcx
    2a00:	test   rax,0x1
    2a06:	jne    2a17 <botlish_fn_24+0x187>
    2a0c:	mov    rdx,r8
    2a0f:	mov    rsi,r14
    2a12:	jmp    2a35 <botlish_fn_24+0x1a5>
    2a17:	mov    rcx,r8
    2a1a:	lea    rax,[rcx-0x1]
    2a1e:	mov    rsi,r14
    2a21:	add    rsi,rax
    2a24:	seto   al
    2a27:	test   al,al
    2a29:	je     2a40 <botlish_fn_24+0x1b0>
    2a2f:	mov    rdx,r8
    2a32:	mov    rsi,r14
    2a35:	mov    rdi,r13
    2a38:	call   2a3d <botlish_fn_24+0x1ad>
			2a39: R_X86_64_PLT32	rt_int_add-0x4
    2a3d:	mov    rsi,rax
    2a40:	mov    QWORD PTR [r12+0x8],rsi
    2a45:	mov    QWORD PTR [r12+0x10],0x3
    2a4e:	test   rsi,0x1
    2a55:	je     2a78 <botlish_fn_24+0x1e8>
    2a5b:	mov    rax,rsi
    2a5e:	add    rax,0x2
    2a62:	mov    rcx,rax
    2a65:	seto   al
    2a68:	test   al,al
    2a6a:	jne    2a78 <botlish_fn_24+0x1e8>
    2a70:	mov    rsi,rcx
    2a73:	jmp    2a88 <botlish_fn_24+0x1f8>
    2a78:	mov    edx,0x3
    2a7d:	mov    rdi,r13
    2a80:	call   2a85 <botlish_fn_24+0x1f5>
			2a81: R_X86_64_PLT32	rt_int_add-0x4
    2a85:	mov    rsi,rax
    2a88:	mov    QWORD PTR [r12+0x8],rsi
    2a8d:	mov    edx,0x7
    2a92:	mov    rcx,rdx
    2a95:	mov    QWORD PTR [r12+0x10],0x7
    2a9e:	test   rsi,0x1
    2aa5:	jne    2ab3 <botlish_fn_24+0x223>
    2aab:	mov    rdx,rcx
    2aae:	jmp    2ae1 <botlish_fn_24+0x251>
    2ab3:	mov    rax,rsi
    2ab6:	sar    rax,1
    2ab9:	imul   QWORD PTR [rip+0x160]        # 2c20 <botlish_fn_24+0x390>
    2ac0:	seto   dil
    2ac4:	or     rax,0x1
    2ac8:	test   dil,dil
    2acb:	je     2ad9 <botlish_fn_24+0x249>
    2ad1:	mov    rdx,rcx
    2ad4:	jmp    2ae1 <botlish_fn_24+0x251>
    2ad9:	mov    rsi,rax
    2adc:	jmp    2aec <botlish_fn_24+0x25c>
    2ae1:	mov    rdi,r13
    2ae4:	call   2ae9 <botlish_fn_24+0x259>
			2ae5: R_X86_64_PLT32	rt_int_mul-0x4
    2ae9:	mov    rsi,rax
    2aec:	mov    QWORD PTR [r12+0x8],rsi
    2af1:	mov    r14,rsi
    2af4:	mov    rsi,rbx
    2af7:	mov    rdi,r13
    2afa:	call   2aff <botlish_fn_24+0x26f>
			2afb: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2aff:	test   rax,rax
    2b02:	jne    2b30 <botlish_fn_24+0x2a0>
    2b08:	mov    rdi,r13
    2b0b:	mov    rdi,r13
    2b0e:	mov    QWORD PTR [rdi],r12
    2b11:	xor    rax,rax
    2b14:	mov    rbx,QWORD PTR [rsp]
    2b18:	mov    r12,QWORD PTR [rsp+0x8]
    2b1d:	mov    r13,QWORD PTR [rsp+0x10]
    2b22:	mov    r14,QWORD PTR [rsp+0x18]
    2b27:	add    rsp,0x20
    2b2b:	mov    rsp,rbp
    2b2e:	pop    rbp
    2b2f:	ret
    2b30:	mov    QWORD PTR [r12],rax
    2b34:	mov    QWORD PTR [r12+0x10],0x5
    2b3d:	test   rax,0x1
    2b43:	mov    rsi,rax
    2b46:	je     2b76 <botlish_fn_24+0x2e6>
    2b4c:	mov    rcx,rsi
    2b4f:	mov    rax,rcx
    2b52:	sar    rax,1
    2b55:	imul   QWORD PTR [rip+0xcc]        # 2c28 <botlish_fn_24+0x398>
    2b5c:	seto   cl
    2b5f:	or     rax,0x1
    2b63:	test   cl,cl
    2b65:	jne    2b76 <botlish_fn_24+0x2e6>
    2b6b:	mov    rdx,rax
    2b6e:	mov    rsi,r14
    2b71:	jmp    2b89 <botlish_fn_24+0x2f9>
    2b76:	mov    edx,0x5
    2b7b:	mov    rdi,r13
    2b7e:	call   2b83 <botlish_fn_24+0x2f3>
			2b7f: R_X86_64_PLT32	rt_int_mul-0x4
    2b83:	mov    rdx,rax
    2b86:	mov    rsi,r14
    2b89:	mov    rax,rsi
    2b8c:	and    rax,rdx
    2b8f:	test   rax,0x1
    2b95:	jne    2bbe <botlish_fn_24+0x32e>
    2b9b:	mov    rdi,r13
    2b9e:	call   2ba3 <botlish_fn_24+0x313>
			2b9f: R_X86_64_PLT32	rt_int_cmp-0x4
    2ba3:	mov    ecx,0x2
    2ba8:	test   rax,rax
    2bab:	mov    rax,rcx
    2bae:	cmovg  rax,QWORD PTR [rip+0x6a]        # 2c20 <botlish_fn_24+0x390>
    2bb6:	mov    rdi,r13
    2bb9:	jmp    2bd1 <botlish_fn_24+0x341>
    2bbe:	mov    eax,0x2
    2bc3:	cmp    rsi,rdx
    2bc6:	cmovg  rax,QWORD PTR [rip+0x52]        # 2c20 <botlish_fn_24+0x390>
    2bce:	mov    rdi,r13
    2bd1:	mov    rdi,r13
    2bd4:	mov    QWORD PTR [rdi],r12
    2bd7:	mov    rbx,QWORD PTR [rsp]
    2bdb:	mov    r12,QWORD PTR [rsp+0x8]
    2be0:	mov    r13,QWORD PTR [rsp+0x10]
    2be5:	mov    r14,QWORD PTR [rsp+0x18]
    2bea:	add    rsp,0x20
    2bee:	mov    rsp,rbp
    2bf1:	pop    rbp
    2bf2:	ret
    2bf3:	mov    r13,rdi
    2bf6:	call   2bfb <botlish_fn_24+0x36b>
			2bf7: R_X86_64_PLT32	rt_stack_overflow-0x4
    2bfb:	xor    rax,rax
    2bfe:	mov    rbx,QWORD PTR [rsp]
    2c02:	mov    r12,QWORD PTR [rsp+0x8]
    2c07:	mov    r13,QWORD PTR [rsp+0x10]
    2c0c:	mov    r14,QWORD PTR [rsp+0x18]
    2c11:	add    rsp,0x20
    2c15:	mov    rsp,rbp
    2c18:	pop    rbp
    2c19:	ret
    2c1a:	add    BYTE PTR [rax],al
    2c1c:	add    BYTE PTR [rax],al
    2c1e:	add    BYTE PTR [rax],al
    2c20:	(bad)
    2c21:	add    BYTE PTR [rax],al
    2c23:	add    BYTE PTR [rax],al
    2c25:	add    BYTE PTR [rax],al
    2c27:	add    BYTE PTR [rax+rax*1],al
    2c2a:	add    BYTE PTR [rax],al
    2c2c:	add    BYTE PTR [rax],al
	...

0000000000002c30 <botlish_entry_24: ht_should_grow<mutarray>>:
    2c30:	push   rbp
    2c31:	mov    rbp,rsp
    2c34:	mov    rsi,QWORD PTR [rdx]
    2c37:	call   2c3c <botlish_entry_24+0xc>
			2c38: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    2c3c:	mov    rsp,rbp
    2c3f:	pop    rbp
    2c40:	ret
    2c41:	add    BYTE PTR [rax],al
    2c43:	add    BYTE PTR [rax],al
    2c45:	add    BYTE PTR [rax],al
	...

0000000000002c48 <botlish_fn_25: ht_grow_or_clean<mutarray>>:
    2c48:	push   rbp
    2c49:	mov    rbp,rsp
    2c4c:	sub    rsp,0x20
    2c50:	mov    QWORD PTR [rsp],rbx
    2c54:	mov    QWORD PTR [rsp+0x8],r12
    2c59:	mov    QWORD PTR [rsp+0x10],r13
    2c5e:	mov    QWORD PTR [rsp+0x18],r14
    2c63:	mov    rbx,QWORD PTR [rdi]
    2c66:	mov    rax,QWORD PTR [rdi+0x8]
    2c6a:	lea    rcx,[rbx+0x18]
    2c6e:	cmp    rcx,rax
    2c71:	ja     2f1a <botlish_fn_25+0x2d2>
    2c77:	lea    rax,[rbx+0x18]
    2c7b:	mov    QWORD PTR [rdi],rax
    2c7e:	mov    r12,rdi
    2c81:	mov    QWORD PTR [rbx],0x0
    2c88:	mov    QWORD PTR [rbx+0x8],0x0
    2c90:	mov    QWORD PTR [rbx+0x10],0x0
    2c98:	mov    QWORD PTR [rbx],rsi
    2c9b:	mov    r13,rsi
    2c9e:	mov    rsi,r13
    2ca1:	mov    rdi,r12
    2ca4:	call   2ca9 <botlish_fn_25+0x61>
			2ca5: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    2ca9:	test   rax,rax
    2cac:	jne    2cba <botlish_fn_25+0x72>
    2cb2:	mov    rdi,r12
    2cb5:	jmp    2ed0 <botlish_fn_25+0x288>
    2cba:	mov    QWORD PTR [rbx+0x8],rax
    2cbe:	mov    r14,rax
    2cc1:	mov    rsi,r13
    2cc4:	mov    rdi,r12
    2cc7:	call   2ccc <botlish_fn_25+0x84>
			2cc8: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    2ccc:	mov    rcx,rax
    2ccf:	test   rcx,rcx
    2cd2:	jne    2ce0 <botlish_fn_25+0x98>
    2cd8:	mov    rdi,r12
    2cdb:	jmp    2ed0 <botlish_fn_25+0x288>
    2ce0:	mov    edx,0x1
    2ce5:	mov    rax,r14
    2ce8:	test   rax,0x1
    2cee:	je     2cfc <botlish_fn_25+0xb4>
    2cf4:	mov    r14,rax
    2cf7:	jmp    2d20 <botlish_fn_25+0xd8>
    2cfc:	xor    edx,edx
    2cfe:	test   rax,0x7
    2d04:	je     2d12 <botlish_fn_25+0xca>
    2d0a:	mov    r14,rax
    2d0d:	jmp    2d20 <botlish_fn_25+0xd8>
    2d12:	movzx  rdx,BYTE PTR [rax]
    2d16:	mov    r14,rax
    2d19:	rex cmp dl,0x1
    2d1d:	sete   dl
    2d20:	test   dl,dl
    2d22:	jne    2d46 <botlish_fn_25+0xfe>
    2d28:	mov    rdi,r12
    2d2b:	mov    rax,QWORD PTR [rdi+0x10]
    2d2f:	mov    rcx,QWORD PTR [rax+0x18]
    2d33:	xor    rdx,rdx
    2d36:	mov    rsi,r14
    2d39:	call   2d3e <botlish_fn_25+0xf6>
			2d3a: R_X86_64_PLT32	rt_type_error-0x4
    2d3e:	mov    rdi,r12
    2d41:	jmp    2ed0 <botlish_fn_25+0x288>
    2d46:	mov    rsi,r14
    2d49:	mov    eax,0x1
    2d4e:	test   rcx,0x1
    2d55:	je     2d63 <botlish_fn_25+0x11b>
    2d5b:	mov    r8,rcx
    2d5e:	jmp    2d86 <botlish_fn_25+0x13e>
    2d63:	xor    eax,eax
    2d65:	test   rcx,0x7
    2d6c:	je     2d7a <botlish_fn_25+0x132>
    2d72:	mov    r8,rcx
    2d75:	jmp    2d86 <botlish_fn_25+0x13e>
    2d7a:	movzx  rax,BYTE PTR [rcx]
    2d7e:	mov    r8,rcx
    2d81:	cmp    al,0x1
    2d83:	sete   al
    2d86:	test   al,al
    2d88:	jne    2dac <botlish_fn_25+0x164>
    2d8e:	mov    rdi,r12
    2d91:	mov    rax,QWORD PTR [rdi+0x10]
    2d95:	mov    rcx,QWORD PTR [rax+0x18]
    2d99:	xor    rdx,rdx
    2d9c:	mov    rsi,r8
    2d9f:	call   2da4 <botlish_fn_25+0x15c>
			2da0: R_X86_64_PLT32	rt_type_error-0x4
    2da4:	mov    rdi,r12
    2da7:	jmp    2ed0 <botlish_fn_25+0x288>
    2dac:	mov    rcx,r8
    2daf:	mov    rax,rsi
    2db2:	and    rax,rcx
    2db5:	test   rax,0x1
    2dbb:	jne    2de2 <botlish_fn_25+0x19a>
    2dc1:	mov    rdx,r8
    2dc4:	mov    rdi,r12
    2dc7:	call   2dcc <botlish_fn_25+0x184>
			2dc8: R_X86_64_PLT32	rt_int_cmp-0x4
    2dcc:	mov    r9d,0x2
    2dd2:	test   rax,rax
    2dd5:	cmovg  r9,QWORD PTR [rip+0x16b]        # 2f48 <botlish_fn_25+0x300>
    2ddd:	jmp    2df6 <botlish_fn_25+0x1ae>
    2de2:	mov    r9d,0x2
    2de8:	mov    rcx,r8
    2deb:	cmp    rsi,rcx
    2dee:	cmovg  r9,QWORD PTR [rip+0x152]        # 2f48 <botlish_fn_25+0x300>
    2df6:	cmp    r9,0x6
    2dfa:	je     2e96 <botlish_fn_25+0x24e>
    2e00:	mov    rsi,r13
    2e03:	mov    rdi,r12
    2e06:	call   2e0b <botlish_fn_25+0x1c3>
			2e07: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2e0b:	test   rax,rax
    2e0e:	jne    2e1c <botlish_fn_25+0x1d4>
    2e14:	mov    rdi,r12
    2e17:	jmp    2ed0 <botlish_fn_25+0x288>
    2e1c:	mov    QWORD PTR [rbx+0x8],rax
    2e20:	mov    QWORD PTR [rbx+0x10],0x5
    2e28:	test   rax,0x1
    2e2e:	mov    rsi,rax
    2e31:	je     2e5e <botlish_fn_25+0x216>
    2e37:	mov    rcx,rsi
    2e3a:	mov    rax,rcx
    2e3d:	sar    rax,1
    2e40:	imul   QWORD PTR [rip+0x109]        # 2f50 <botlish_fn_25+0x308>
    2e47:	seto   cl
    2e4a:	or     rax,0x1
    2e4e:	test   cl,cl
    2e50:	jne    2e5e <botlish_fn_25+0x216>
    2e56:	mov    rdx,rax
    2e59:	jmp    2e6e <botlish_fn_25+0x226>
    2e5e:	mov    edx,0x5
    2e63:	mov    rdi,r12
    2e66:	call   2e6b <botlish_fn_25+0x223>
			2e67: R_X86_64_PLT32	rt_int_mul-0x4
    2e6b:	mov    rdx,rax
    2e6e:	mov    QWORD PTR [rbx+0x8],rdx
    2e72:	mov    rsi,r13
    2e75:	mov    rdi,r12
    2e78:	call   2e7d <botlish_fn_25+0x235>
			2e79: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    2e7d:	test   rax,rax
    2e80:	jne    2e8e <botlish_fn_25+0x246>
    2e86:	mov    rdi,r12
    2e89:	jmp    2ed0 <botlish_fn_25+0x288>
    2e8e:	mov    rdi,r12
    2e91:	jmp    2ef8 <botlish_fn_25+0x2b0>
    2e96:	mov    rsi,r13
    2e99:	mov    rdi,r12
    2e9c:	call   2ea1 <botlish_fn_25+0x259>
			2e9d: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_capacity<mutarray>
    2ea1:	test   rax,rax
    2ea4:	jne    2eb2 <botlish_fn_25+0x26a>
    2eaa:	mov    rdi,r12
    2ead:	jmp    2ed0 <botlish_fn_25+0x288>
    2eb2:	mov    QWORD PTR [rbx+0x8],rax
    2eb6:	mov    rdx,rax
    2eb9:	mov    rsi,r13
    2ebc:	mov    rdi,r12
    2ebf:	call   2ec4 <botlish_fn_25+0x27c>
			2ec0: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_rehash<mutarray, int>
    2ec4:	test   rax,rax
    2ec7:	jne    2ef5 <botlish_fn_25+0x2ad>
    2ecd:	mov    rdi,r12
    2ed0:	mov    rdi,r12
    2ed3:	mov    QWORD PTR [rdi],rbx
    2ed6:	xor    rax,rax
    2ed9:	mov    rbx,QWORD PTR [rsp]
    2edd:	mov    r12,QWORD PTR [rsp+0x8]
    2ee2:	mov    r13,QWORD PTR [rsp+0x10]
    2ee7:	mov    r14,QWORD PTR [rsp+0x18]
    2eec:	add    rsp,0x20
    2ef0:	mov    rsp,rbp
    2ef3:	pop    rbp
    2ef4:	ret
    2ef5:	mov    rdi,r12
    2ef8:	mov    rdi,r12
    2efb:	mov    QWORD PTR [rdi],rbx
    2efe:	mov    rbx,QWORD PTR [rsp]
    2f02:	mov    r12,QWORD PTR [rsp+0x8]
    2f07:	mov    r13,QWORD PTR [rsp+0x10]
    2f0c:	mov    r14,QWORD PTR [rsp+0x18]
    2f11:	add    rsp,0x20
    2f15:	mov    rsp,rbp
    2f18:	pop    rbp
    2f19:	ret
    2f1a:	mov    r12,rdi
    2f1d:	call   2f22 <botlish_fn_25+0x2da>
			2f1e: R_X86_64_PLT32	rt_stack_overflow-0x4
    2f22:	xor    rax,rax
    2f25:	mov    rbx,QWORD PTR [rsp]
    2f29:	mov    r12,QWORD PTR [rsp+0x8]
    2f2e:	mov    r13,QWORD PTR [rsp+0x10]
    2f33:	mov    r14,QWORD PTR [rsp+0x18]
    2f38:	add    rsp,0x20
    2f3c:	mov    rsp,rbp
    2f3f:	pop    rbp
    2f40:	ret
    2f41:	add    BYTE PTR [rax],al
    2f43:	add    BYTE PTR [rax],al
    2f45:	add    BYTE PTR [rax],al
    2f47:	add    BYTE PTR [rsi],al
    2f49:	add    BYTE PTR [rax],al
    2f4b:	add    BYTE PTR [rax],al
    2f4d:	add    BYTE PTR [rax],al
    2f4f:	add    BYTE PTR [rax+rax*1],al
    2f52:	add    BYTE PTR [rax],al
    2f54:	add    BYTE PTR [rax],al
	...

0000000000002f58 <botlish_entry_25: ht_grow_or_clean<mutarray>>:
    2f58:	push   rbp
    2f59:	mov    rbp,rsp
    2f5c:	mov    rsi,QWORD PTR [rdx]
    2f5f:	call   2f64 <botlish_entry_25+0xc>
			2f60: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    2f64:	mov    rsp,rbp
    2f67:	pop    rbp
    2f68:	ret
    2f69:	add    BYTE PTR [rax],al
    2f6b:	add    BYTE PTR [rax],al
    2f6d:	add    BYTE PTR [rax],al
	...

0000000000002f70 <botlish_fn_26: ht_place<mutarray, int, str, str>>:
    2f70:	push   rbp
    2f71:	mov    rbp,rsp
    2f74:	sub    rsp,0x50
    2f78:	mov    QWORD PTR [rsp+0x20],rbx
    2f7d:	mov    QWORD PTR [rsp+0x28],r12
    2f82:	mov    QWORD PTR [rsp+0x30],r13
    2f87:	mov    QWORD PTR [rsp+0x38],r14
    2f8c:	mov    QWORD PTR [rsp+0x40],r15
    2f91:	mov    r12,QWORD PTR [rdi]
    2f94:	mov    rax,QWORD PTR [rdi+0x8]
    2f98:	lea    r9,[r12+0x30]
    2f9d:	cmp    r9,rax
    2fa0:	ja     3485 <botlish_fn_26+0x515>
    2fa6:	lea    rax,[r12+0x30]
    2fab:	mov    QWORD PTR [rdi],rax
    2fae:	mov    r13,rdi
    2fb1:	mov    QWORD PTR [r12],0x0
    2fb9:	mov    QWORD PTR [r12+0x8],0x0
    2fc2:	mov    QWORD PTR [r12+0x10],0x0
    2fcb:	mov    QWORD PTR [r12+0x18],0x0
    2fd4:	mov    QWORD PTR [r12+0x20],0x0
    2fdd:	mov    QWORD PTR [r12+0x28],0x0
    2fe6:	mov    QWORD PTR [r12],rsi
    2fea:	mov    r14,rsi
    2fed:	mov    QWORD PTR [r12+0x8],rdx
    2ff2:	mov    QWORD PTR [rsp],rdx
    2ff6:	mov    QWORD PTR [r12+0x10],rcx
    2ffb:	mov    QWORD PTR [rsp+0x8],rcx
    3000:	mov    QWORD PTR [r12+0x18],r8
    3005:	mov    r15,r8
    3008:	mov    rsi,r14
    300b:	mov    rdi,r13
    300e:	call   3013 <botlish_fn_26+0xa3>
			300f: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    3013:	test   rax,rax
    3016:	jne    3024 <botlish_fn_26+0xb4>
    301c:	mov    rdi,r13
    301f:	jmp    342a <botlish_fn_26+0x4ba>
    3024:	mov    QWORD PTR [r12+0x20],rax
    3029:	xor    ecx,ecx
    302b:	test   rax,0x7
    3031:	je     3041 <botlish_fn_26+0xd1>
    3037:	mov    QWORD PTR [rsp+0x10],rax
    303c:	jmp    3051 <botlish_fn_26+0xe1>
    3041:	movzx  rcx,BYTE PTR [rax]
    3045:	mov    QWORD PTR [rsp+0x10],rax
    304a:	rex cmp cl,0x8
    304e:	sete   cl
    3051:	test   cl,cl
    3053:	jne    307b <botlish_fn_26+0x10b>
    3059:	mov    rdi,r13
    305c:	mov    rax,QWORD PTR [rdi+0x10]
    3060:	mov    rcx,QWORD PTR [rax+0x8]
    3064:	mov    edx,0x8
    3069:	mov    rsi,QWORD PTR [rsp+0x10]
    306e:	call   3073 <botlish_fn_26+0x103>
			306f: R_X86_64_PLT32	rt_type_error-0x4
    3073:	mov    rdi,r13
    3076:	jmp    342a <botlish_fn_26+0x4ba>
    307b:	mov    rdx,QWORD PTR [rsp]
    307f:	mov    rsi,QWORD PTR [rsp+0x10]
    3084:	mov    rdi,r13
    3087:	call   308c <botlish_fn_26+0x11c>
			3088: R_X86_64_PLT32	rt_mutarray_get-0x4
    308c:	mov    rbx,rax
    308f:	test   rbx,rbx
    3092:	jne    30a0 <botlish_fn_26+0x130>
    3098:	mov    rdi,r13
    309b:	jmp    342a <botlish_fn_26+0x4ba>
    30a0:	mov    QWORD PTR [r12+0x28],rbx
    30a5:	mov    rdi,r13
    30a8:	call   30ad <botlish_fn_26+0x13d>
			30a9: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    30ad:	test   rax,rax
    30b0:	mov    rcx,rax
    30b3:	jne    30c1 <botlish_fn_26+0x151>
    30b9:	mov    rdi,r13
    30bc:	jmp    342a <botlish_fn_26+0x4ba>
    30c1:	mov    rsi,QWORD PTR [rsp+0x10]
    30c6:	mov    rdx,QWORD PTR [rsp]
    30ca:	mov    rdi,r13
    30cd:	call   30d2 <botlish_fn_26+0x162>
			30ce: R_X86_64_PLT32	rt_mutarray_set-0x4
    30d2:	test   rax,rax
    30d5:	jne    30e3 <botlish_fn_26+0x173>
    30db:	mov    rdi,r13
    30de:	jmp    342a <botlish_fn_26+0x4ba>
    30e3:	mov    rsi,r14
    30e6:	mov    rdi,r13
    30e9:	call   30ee <botlish_fn_26+0x17e>
			30ea: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    30ee:	test   rax,rax
    30f1:	jne    30ff <botlish_fn_26+0x18f>
    30f7:	mov    rdi,r13
    30fa:	jmp    342a <botlish_fn_26+0x4ba>
    30ff:	xor    ecx,ecx
    3101:	test   rax,0x7
    3107:	je     3115 <botlish_fn_26+0x1a5>
    310d:	mov    rsi,rax
    3110:	jmp    3123 <botlish_fn_26+0x1b3>
    3115:	movzx  r11,BYTE PTR [rax]
    3119:	mov    rsi,rax
    311c:	cmp    r11b,0x8
    3120:	sete   cl
    3123:	test   cl,cl
    3125:	jne    3148 <botlish_fn_26+0x1d8>
    312b:	mov    rdi,r13
    312e:	mov    rax,QWORD PTR [rdi+0x10]
    3132:	mov    rcx,QWORD PTR [rax+0x20]
    3136:	mov    edx,0x8
    313b:	call   3140 <botlish_fn_26+0x1d0>
			313c: R_X86_64_PLT32	rt_type_error-0x4
    3140:	mov    rdi,r13
    3143:	jmp    342a <botlish_fn_26+0x4ba>
    3148:	mov    rcx,QWORD PTR [rsp+0x8]
    314d:	mov    rdx,QWORD PTR [rsp]
    3151:	mov    rdi,r13
    3154:	call   3159 <botlish_fn_26+0x1e9>
			3155: R_X86_64_PLT32	rt_mutarray_set-0x4
    3159:	test   rax,rax
    315c:	jne    316a <botlish_fn_26+0x1fa>
    3162:	mov    rdi,r13
    3165:	jmp    342a <botlish_fn_26+0x4ba>
    316a:	mov    rsi,r14
    316d:	mov    rdi,r13
    3170:	call   3175 <botlish_fn_26+0x205>
			3171: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    3175:	test   rax,rax
    3178:	jne    3186 <botlish_fn_26+0x216>
    317e:	mov    rdi,r13
    3181:	jmp    342a <botlish_fn_26+0x4ba>
    3186:	xor    ecx,ecx
    3188:	test   rax,0x7
    318e:	je     319c <botlish_fn_26+0x22c>
    3194:	mov    rsi,rax
    3197:	jmp    31aa <botlish_fn_26+0x23a>
    319c:	movzx  rcx,BYTE PTR [rax]
    31a0:	mov    rsi,rax
    31a3:	rex cmp cl,0x8
    31a7:	sete   cl
    31aa:	test   cl,cl
    31ac:	jne    31cf <botlish_fn_26+0x25f>
    31b2:	mov    rdi,r13
    31b5:	mov    rax,QWORD PTR [rdi+0x10]
    31b9:	mov    rcx,QWORD PTR [rax+0x20]
    31bd:	mov    edx,0x8
    31c2:	call   31c7 <botlish_fn_26+0x257>
			31c3: R_X86_64_PLT32	rt_type_error-0x4
    31c7:	mov    rdi,r13
    31ca:	jmp    342a <botlish_fn_26+0x4ba>
    31cf:	mov    rcx,r15
    31d2:	mov    rdx,QWORD PTR [rsp]
    31d6:	mov    rdi,r13
    31d9:	call   31de <botlish_fn_26+0x26e>
			31da: R_X86_64_PLT32	rt_mutarray_set-0x4
    31de:	test   rax,rax
    31e1:	jne    31ef <botlish_fn_26+0x27f>
    31e7:	mov    rdi,r13
    31ea:	jmp    342a <botlish_fn_26+0x4ba>
    31ef:	mov    QWORD PTR [r12+0x8],0x7
    31f8:	mov    rsi,r14
    31fb:	mov    rdi,r13
    31fe:	call   3203 <botlish_fn_26+0x293>
			31ff: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    3203:	test   rax,rax
    3206:	jne    3214 <botlish_fn_26+0x2a4>
    320c:	mov    rdi,r13
    320f:	jmp    342a <botlish_fn_26+0x4ba>
    3214:	mov    QWORD PTR [r12+0x10],rax
    3219:	mov    QWORD PTR [r12+0x18],0x3
    3222:	mov    ecx,0x1
    3227:	test   rax,0x1
    322d:	je     323b <botlish_fn_26+0x2cb>
    3233:	mov    rsi,rax
    3236:	jmp    325f <botlish_fn_26+0x2ef>
    323b:	xor    ecx,ecx
    323d:	test   rax,0x7
    3243:	je     3251 <botlish_fn_26+0x2e1>
    3249:	mov    rsi,rax
    324c:	jmp    325f <botlish_fn_26+0x2ef>
    3251:	movzx  rcx,BYTE PTR [rax]
    3255:	mov    rsi,rax
    3258:	rex cmp cl,0x1
    325c:	sete   cl
    325f:	test   cl,cl
    3261:	jne    3282 <botlish_fn_26+0x312>
    3267:	mov    rdi,r13
    326a:	mov    rax,QWORD PTR [rdi+0x10]
    326e:	mov    rcx,QWORD PTR [rax+0x10]
    3272:	xor    rdx,rdx
    3275:	call   327a <botlish_fn_26+0x30a>
			3276: R_X86_64_PLT32	rt_type_error-0x4
    327a:	mov    rdi,r13
    327d:	jmp    342a <botlish_fn_26+0x4ba>
    3282:	test   rsi,0x1
    3289:	je     32a1 <botlish_fn_26+0x331>
    328f:	mov    rcx,rsi
    3292:	add    rcx,0x2
    3296:	seto   al
    3299:	test   al,al
    329b:	je     32b1 <botlish_fn_26+0x341>
    32a1:	mov    edx,0x3
    32a6:	mov    rdi,r13
    32a9:	call   32ae <botlish_fn_26+0x33e>
			32aa: R_X86_64_PLT32	rt_int_add-0x4
    32ae:	mov    rcx,rax
    32b1:	mov    edx,0x7
    32b6:	mov    rsi,r14
    32b9:	mov    rdi,r13
    32bc:	call   32c1 <botlish_fn_26+0x351>
			32bd: R_X86_64_PLT32	rt_mutarray_set-0x4
    32c1:	test   rax,rax
    32c4:	jne    32d2 <botlish_fn_26+0x362>
    32ca:	mov    rdi,r13
    32cd:	jmp    342a <botlish_fn_26+0x4ba>
    32d2:	mov    rdi,r13
    32d5:	call   32da <botlish_fn_26+0x36a>
			32d6: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    32da:	test   rax,rax
    32dd:	jne    32eb <botlish_fn_26+0x37b>
    32e3:	mov    rdi,r13
    32e6:	jmp    342a <botlish_fn_26+0x4ba>
    32eb:	mov    rcx,rbx
    32ee:	and    rcx,rax
    32f1:	mov    rdx,rax
    32f4:	mov    rax,rbx
    32f7:	test   rcx,0x1
    32fe:	jne    3320 <botlish_fn_26+0x3b0>
    3304:	mov    rsi,rax
    3307:	mov    rdi,r13
    330a:	call   330f <botlish_fn_26+0x39f>
			330b: R_X86_64_PLT32	rt_value_eq-0x4
    330f:	test   rax,rax
    3312:	jne    3333 <botlish_fn_26+0x3c3>
    3318:	mov    rdi,r13
    331b:	jmp    342a <botlish_fn_26+0x4ba>
    3320:	mov    rsi,rax
    3323:	mov    eax,0x2
    3328:	cmp    rsi,rdx
    332b:	cmove  rax,QWORD PTR [rip+0x185]        # 34b8 <botlish_fn_26+0x548>
    3333:	cmp    rax,0x6
    3337:	je     3345 <botlish_fn_26+0x3d5>
    333d:	mov    rdi,r13
    3340:	jmp    3458 <botlish_fn_26+0x4e8>
    3345:	mov    QWORD PTR [r12+0x8],0x9
    334e:	mov    rsi,r14
    3351:	mov    rdi,r13
    3354:	call   3359 <botlish_fn_26+0x3e9>
			3355: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    3359:	test   rax,rax
    335c:	jne    336a <botlish_fn_26+0x3fa>
    3362:	mov    rdi,r13
    3365:	jmp    342a <botlish_fn_26+0x4ba>
    336a:	mov    QWORD PTR [r12+0x10],rax
    336f:	mov    QWORD PTR [r12+0x18],0x3
    3378:	mov    ecx,0x1
    337d:	test   rax,0x1
    3383:	je     3391 <botlish_fn_26+0x421>
    3389:	mov    rsi,rax
    338c:	jmp    33b5 <botlish_fn_26+0x445>
    3391:	xor    ecx,ecx
    3393:	test   rax,0x7
    3399:	je     33a7 <botlish_fn_26+0x437>
    339f:	mov    rsi,rax
    33a2:	jmp    33b5 <botlish_fn_26+0x445>
    33a7:	movzx  rcx,BYTE PTR [rax]
    33ab:	mov    rsi,rax
    33ae:	rex cmp cl,0x1
    33b2:	sete   cl
    33b5:	test   cl,cl
    33b7:	jne    33d8 <botlish_fn_26+0x468>
    33bd:	mov    rdi,r13
    33c0:	mov    rax,QWORD PTR [rdi+0x10]
    33c4:	mov    rcx,QWORD PTR [rax+0x28]
    33c8:	xor    rdx,rdx
    33cb:	call   33d0 <botlish_fn_26+0x460>
			33cc: R_X86_64_PLT32	rt_type_error-0x4
    33d0:	mov    rdi,r13
    33d3:	jmp    342a <botlish_fn_26+0x4ba>
    33d8:	test   rsi,0x1
    33df:	je     33fe <botlish_fn_26+0x48e>
    33e5:	mov    rcx,rsi
    33e8:	sub    rcx,0x3
    33ec:	seto   al
    33ef:	add    rcx,0x1
    33f6:	test   al,al
    33f8:	je     340e <botlish_fn_26+0x49e>
    33fe:	mov    edx,0x3
    3403:	mov    rdi,r13
    3406:	call   340b <botlish_fn_26+0x49b>
			3407: R_X86_64_PLT32	rt_int_sub-0x4
    340b:	mov    rcx,rax
    340e:	mov    edx,0x9
    3413:	mov    rsi,r14
    3416:	mov    rdi,r13
    3419:	call   341e <botlish_fn_26+0x4ae>
			341a: R_X86_64_PLT32	rt_mutarray_set-0x4
    341e:	test   rax,rax
    3421:	jne    3455 <botlish_fn_26+0x4e5>
    3427:	mov    rdi,r13
    342a:	mov    rdi,r13
    342d:	mov    QWORD PTR [rdi],r12
    3430:	xor    rax,rax
    3433:	mov    rbx,QWORD PTR [rsp+0x20]
    3438:	mov    r12,QWORD PTR [rsp+0x28]
    343d:	mov    r13,QWORD PTR [rsp+0x30]
    3442:	mov    r14,QWORD PTR [rsp+0x38]
    3447:	mov    r15,QWORD PTR [rsp+0x40]
    344c:	add    rsp,0x50
    3450:	mov    rsp,rbp
    3453:	pop    rbp
    3454:	ret
    3455:	mov    rdi,r13
    3458:	mov    rdi,r13
    345b:	mov    QWORD PTR [rdi],r12
    345e:	mov    eax,0xa
    3463:	mov    rbx,QWORD PTR [rsp+0x20]
    3468:	mov    r12,QWORD PTR [rsp+0x28]
    346d:	mov    r13,QWORD PTR [rsp+0x30]
    3472:	mov    r14,QWORD PTR [rsp+0x38]
    3477:	mov    r15,QWORD PTR [rsp+0x40]
    347c:	add    rsp,0x50
    3480:	mov    rsp,rbp
    3483:	pop    rbp
    3484:	ret
    3485:	mov    r13,rdi
    3488:	call   348d <botlish_fn_26+0x51d>
			3489: R_X86_64_PLT32	rt_stack_overflow-0x4
    348d:	xor    rax,rax
    3490:	mov    rbx,QWORD PTR [rsp+0x20]
    3495:	mov    r12,QWORD PTR [rsp+0x28]
    349a:	mov    r13,QWORD PTR [rsp+0x30]
    349f:	mov    r14,QWORD PTR [rsp+0x38]
    34a4:	mov    r15,QWORD PTR [rsp+0x40]
    34a9:	add    rsp,0x50
    34ad:	mov    rsp,rbp
    34b0:	pop    rbp
    34b1:	ret
    34b2:	add    BYTE PTR [rax],al
    34b4:	add    BYTE PTR [rax],al
    34b6:	add    BYTE PTR [rax],al
    34b8:	(bad)
    34b9:	add    BYTE PTR [rax],al
    34bb:	add    BYTE PTR [rax],al
    34bd:	add    BYTE PTR [rax],al
	...

00000000000034c0 <botlish_entry_26: ht_place<mutarray, int, str, str>>:
    34c0:	push   rbp
    34c1:	mov    rbp,rsp
    34c4:	mov    rsi,QWORD PTR [rdx]
    34c7:	mov    r9,QWORD PTR [rdx+0x8]
    34cb:	mov    rcx,QWORD PTR [rdx+0x10]
    34cf:	mov    r8,QWORD PTR [rdx+0x18]
    34d3:	mov    rdx,r9
    34d6:	call   34db <botlish_entry_26+0x1b>
			34d7: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    34db:	mov    rsp,rbp
    34de:	pop    rbp
    34df:	ret

00000000000034e0 <botlish_fn_27: ht_set<mutarray, str, str>>:
    34e0:	push   rbp
    34e1:	mov    rbp,rsp
    34e4:	sub    rsp,0x50
    34e8:	mov    QWORD PTR [rsp+0x20],rbx
    34ed:	mov    QWORD PTR [rsp+0x28],r12
    34f2:	mov    QWORD PTR [rsp+0x30],r13
    34f7:	mov    QWORD PTR [rsp+0x38],r14
    34fc:	mov    QWORD PTR [rsp+0x40],r15
    3501:	mov    rbx,QWORD PTR [rdi]
    3504:	mov    rax,QWORD PTR [rdi+0x8]
    3508:	lea    r8,[rbx+0x28]
    350c:	cmp    r8,rax
    350f:	ja     38cd <botlish_fn_27+0x3ed>
    3515:	lea    rax,[rbx+0x28]
    3519:	mov    QWORD PTR [rdi],rax
    351c:	mov    r12,rdi
    351f:	mov    QWORD PTR [rbx],0x0
    3526:	mov    QWORD PTR [rbx+0x8],0x0
    352e:	mov    QWORD PTR [rbx+0x10],0x0
    3536:	mov    QWORD PTR [rbx+0x18],0x0
    353e:	mov    QWORD PTR [rbx+0x20],0x0
    3546:	mov    QWORD PTR [rbx],rsi
    3549:	mov    r15,rsi
    354c:	mov    QWORD PTR [rbx+0x8],rdx
    3550:	mov    r14,rdx
    3553:	mov    QWORD PTR [rbx+0x10],rcx
    3557:	mov    r13,rcx
    355a:	mov    rdx,r14
    355d:	mov    rsi,r15
    3560:	mov    rdi,r12
    3563:	call   3568 <botlish_fn_27+0x88>
			3564: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    3568:	test   rax,rax
    356b:	jne    3579 <botlish_fn_27+0x99>
    3571:	mov    rdi,r12
    3574:	jmp    3875 <botlish_fn_27+0x395>
    3579:	mov    QWORD PTR [rbx+0x18],rax
    357d:	mov    rcx,rax
    3580:	mov    r8,0xffffffffffffffff
    3587:	mov    QWORD PTR [rsp+0x10],r8
    358c:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    3594:	mov    rdx,r14
    3597:	mov    rsi,r15
    359a:	mov    rdi,r12
    359d:	call   35a2 <botlish_fn_27+0xc2>
			359e: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    35a2:	mov    rcx,rax
    35a5:	mov    QWORD PTR [rsp+0x8],rax
    35aa:	test   rax,rcx
    35ad:	jne    35bb <botlish_fn_27+0xdb>
    35b3:	mov    rdi,r12
    35b6:	jmp    3875 <botlish_fn_27+0x395>
    35bb:	mov    rax,QWORD PTR [rsp+0x8]
    35c0:	mov    QWORD PTR [rbx+0x18],rax
    35c4:	mov    rsi,r15
    35c7:	mov    rdi,r12
    35ca:	call   35cf <botlish_fn_27+0xef>
			35cb: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    35cf:	test   rax,rax
    35d2:	jne    35e0 <botlish_fn_27+0x100>
    35d8:	mov    rdi,r12
    35db:	jmp    3875 <botlish_fn_27+0x395>
    35e0:	xor    ecx,ecx
    35e2:	test   rax,0x7
    35e8:	je     35f6 <botlish_fn_27+0x116>
    35ee:	mov    rsi,rax
    35f1:	jmp    3604 <botlish_fn_27+0x124>
    35f6:	movzx  rcx,BYTE PTR [rax]
    35fa:	mov    rsi,rax
    35fd:	rex cmp cl,0x8
    3601:	sete   cl
    3604:	test   cl,cl
    3606:	jne    3629 <botlish_fn_27+0x149>
    360c:	mov    rdi,r12
    360f:	mov    rax,QWORD PTR [rdi+0x10]
    3613:	mov    rcx,QWORD PTR [rax+0x8]
    3617:	mov    edx,0x8
    361c:	call   3621 <botlish_fn_27+0x141>
			361d: R_X86_64_PLT32	rt_type_error-0x4
    3621:	mov    rdi,r12
    3624:	jmp    3875 <botlish_fn_27+0x395>
    3629:	mov    rdx,QWORD PTR [rsp+0x8]
    362e:	mov    rdi,r12
    3631:	call   3636 <botlish_fn_27+0x156>
			3632: R_X86_64_PLT32	rt_mutarray_get-0x4
    3636:	test   rax,rax
    3639:	jne    3647 <botlish_fn_27+0x167>
    363f:	mov    rdi,r12
    3642:	jmp    3875 <botlish_fn_27+0x395>
    3647:	mov    QWORD PTR [rbx+0x20],rax
    364b:	mov    QWORD PTR [rsp],rax
    364f:	mov    rdi,r12
    3652:	call   3657 <botlish_fn_27+0x177>
			3653: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_occupied_state<generic>
    3657:	test   rax,rax
    365a:	jne    3668 <botlish_fn_27+0x188>
    3660:	mov    rdi,r12
    3663:	jmp    3875 <botlish_fn_27+0x395>
    3668:	mov    rcx,QWORD PTR [rsp]
    366c:	mov    rdx,rcx
    366f:	and    rdx,rax
    3672:	test   rdx,0x1
    3679:	jne    369f <botlish_fn_27+0x1bf>
    367f:	mov    rdx,rax
    3682:	mov    rsi,QWORD PTR [rsp]
    3686:	mov    rdi,r12
    3689:	call   368e <botlish_fn_27+0x1ae>
			368a: R_X86_64_PLT32	rt_value_eq-0x4
    368e:	test   rax,rax
    3691:	jne    36b6 <botlish_fn_27+0x1d6>
    3697:	mov    rdi,r12
    369a:	jmp    3875 <botlish_fn_27+0x395>
    369f:	mov    rdx,rax
    36a2:	mov    rsi,QWORD PTR [rsp]
    36a6:	mov    eax,0x2
    36ab:	cmp    rsi,rdx
    36ae:	cmove  rax,QWORD PTR [rip+0x24a]        # 3900 <botlish_fn_27+0x420>
    36b6:	cmp    rax,0x6
    36ba:	je     37f4 <botlish_fn_27+0x314>
    36c0:	mov    rsi,r15
    36c3:	mov    rdi,r12
    36c6:	call   36cb <botlish_fn_27+0x1eb>
			36c7: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_should_grow<mutarray>
    36cb:	test   rax,rax
    36ce:	jne    36dc <botlish_fn_27+0x1fc>
    36d4:	mov    rdi,r12
    36d7:	jmp    3875 <botlish_fn_27+0x395>
    36dc:	cmp    rax,0x6
    36e0:	je     3735 <botlish_fn_27+0x255>
    36e6:	mov    rcx,r14
    36e9:	mov    rdx,QWORD PTR [rsp+0x8]
    36ee:	mov    rsi,r15
    36f1:	mov    r8,r13
    36f4:	mov    rdi,r12
    36f7:	call   36fc <botlish_fn_27+0x21c>
			36f8: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    36fc:	test   rax,rax
    36ff:	jne    370d <botlish_fn_27+0x22d>
    3705:	mov    rdi,r12
    3708:	jmp    3875 <botlish_fn_27+0x395>
    370d:	mov    rdi,r12
    3710:	mov    QWORD PTR [rdi],rbx
    3713:	mov    rbx,QWORD PTR [rsp+0x20]
    3718:	mov    r12,QWORD PTR [rsp+0x28]
    371d:	mov    r13,QWORD PTR [rsp+0x30]
    3722:	mov    r14,QWORD PTR [rsp+0x38]
    3727:	mov    r15,QWORD PTR [rsp+0x40]
    372c:	add    rsp,0x50
    3730:	mov    rsp,rbp
    3733:	pop    rbp
    3734:	ret
    3735:	mov    rsi,r15
    3738:	mov    rdi,r12
    373b:	call   3740 <botlish_fn_27+0x260>
			373c: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_grow_or_clean<mutarray>
    3740:	test   rax,rax
    3743:	jne    3751 <botlish_fn_27+0x271>
    3749:	mov    rdi,r12
    374c:	jmp    3875 <botlish_fn_27+0x395>
    3751:	mov    rdx,r14
    3754:	mov    rsi,r15
    3757:	mov    rdi,r12
    375a:	call   375f <botlish_fn_27+0x27f>
			375b: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    375f:	test   rax,rax
    3762:	jne    3770 <botlish_fn_27+0x290>
    3768:	mov    rdi,r12
    376b:	jmp    3875 <botlish_fn_27+0x395>
    3770:	mov    QWORD PTR [rbx+0x18],rax
    3774:	mov    rcx,rax
    3777:	mov    QWORD PTR [rbx+0x20],0xffffffffffffffff
    377f:	mov    r8,QWORD PTR [rsp+0x10]
    3784:	mov    rdx,r14
    3787:	mov    rsi,r15
    378a:	mov    rdi,r12
    378d:	call   3792 <botlish_fn_27+0x2b2>
			378e: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_find_insert<mutarray, str, int, int>
    3792:	test   rax,rax
    3795:	jne    37a3 <botlish_fn_27+0x2c3>
    379b:	mov    rdi,r12
    379e:	jmp    3875 <botlish_fn_27+0x395>
    37a3:	mov    QWORD PTR [rbx+0x18],rax
    37a7:	mov    rcx,r14
    37aa:	mov    rdx,rax
    37ad:	mov    rsi,r15
    37b0:	mov    r8,r13
    37b3:	mov    rdi,r12
    37b6:	call   37bb <botlish_fn_27+0x2db>
			37b7: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_place<mutarray, int, str, str>
    37bb:	test   rax,rax
    37be:	jne    37cc <botlish_fn_27+0x2ec>
    37c4:	mov    rdi,r12
    37c7:	jmp    3875 <botlish_fn_27+0x395>
    37cc:	mov    rdi,r12
    37cf:	mov    QWORD PTR [rdi],rbx
    37d2:	mov    rbx,QWORD PTR [rsp+0x20]
    37d7:	mov    r12,QWORD PTR [rsp+0x28]
    37dc:	mov    r13,QWORD PTR [rsp+0x30]
    37e1:	mov    r14,QWORD PTR [rsp+0x38]
    37e6:	mov    r15,QWORD PTR [rsp+0x40]
    37eb:	add    rsp,0x50
    37ef:	mov    rsp,rbp
    37f2:	pop    rbp
    37f3:	ret
    37f4:	mov    rsi,r15
    37f7:	mov    rdi,r12
    37fa:	call   37ff <botlish_fn_27+0x31f>
			37fb: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    37ff:	test   rax,rax
    3802:	jne    3810 <botlish_fn_27+0x330>
    3808:	mov    rdi,r12
    380b:	jmp    3875 <botlish_fn_27+0x395>
    3810:	xor    ecx,ecx
    3812:	test   rax,0x7
    3818:	je     3826 <botlish_fn_27+0x346>
    381e:	mov    rsi,rax
    3821:	jmp    3834 <botlish_fn_27+0x354>
    3826:	movzx  r9,BYTE PTR [rax]
    382a:	mov    rsi,rax
    382d:	cmp    r9b,0x8
    3831:	sete   cl
    3834:	test   cl,cl
    3836:	jne    3859 <botlish_fn_27+0x379>
    383c:	mov    rdi,r12
    383f:	mov    rax,QWORD PTR [rdi+0x10]
    3843:	mov    rcx,QWORD PTR [rax+0x20]
    3847:	mov    edx,0x8
    384c:	call   3851 <botlish_fn_27+0x371>
			384d: R_X86_64_PLT32	rt_type_error-0x4
    3851:	mov    rdi,r12
    3854:	jmp    3875 <botlish_fn_27+0x395>
    3859:	mov    rcx,r13
    385c:	mov    rdx,QWORD PTR [rsp+0x8]
    3861:	mov    rdi,r12
    3864:	call   3869 <botlish_fn_27+0x389>
			3865: R_X86_64_PLT32	rt_mutarray_set-0x4
    3869:	test   rax,rax
    386c:	jne    38a0 <botlish_fn_27+0x3c0>
    3872:	mov    rdi,r12
    3875:	mov    rdi,r12
    3878:	mov    QWORD PTR [rdi],rbx
    387b:	xor    rax,rax
    387e:	mov    rbx,QWORD PTR [rsp+0x20]
    3883:	mov    r12,QWORD PTR [rsp+0x28]
    3888:	mov    r13,QWORD PTR [rsp+0x30]
    388d:	mov    r14,QWORD PTR [rsp+0x38]
    3892:	mov    r15,QWORD PTR [rsp+0x40]
    3897:	add    rsp,0x50
    389b:	mov    rsp,rbp
    389e:	pop    rbp
    389f:	ret
    38a0:	mov    rdi,r12
    38a3:	mov    QWORD PTR [rdi],rbx
    38a6:	mov    eax,0xa
    38ab:	mov    rbx,QWORD PTR [rsp+0x20]
    38b0:	mov    r12,QWORD PTR [rsp+0x28]
    38b5:	mov    r13,QWORD PTR [rsp+0x30]
    38ba:	mov    r14,QWORD PTR [rsp+0x38]
    38bf:	mov    r15,QWORD PTR [rsp+0x40]
    38c4:	add    rsp,0x50
    38c8:	mov    rsp,rbp
    38cb:	pop    rbp
    38cc:	ret
    38cd:	mov    r12,rdi
    38d0:	call   38d5 <botlish_fn_27+0x3f5>
			38d1: R_X86_64_PLT32	rt_stack_overflow-0x4
    38d5:	xor    rax,rax
    38d8:	mov    rbx,QWORD PTR [rsp+0x20]
    38dd:	mov    r12,QWORD PTR [rsp+0x28]
    38e2:	mov    r13,QWORD PTR [rsp+0x30]
    38e7:	mov    r14,QWORD PTR [rsp+0x38]
    38ec:	mov    r15,QWORD PTR [rsp+0x40]
    38f1:	add    rsp,0x50
    38f5:	mov    rsp,rbp
    38f8:	pop    rbp
    38f9:	ret
    38fa:	add    BYTE PTR [rax],al
    38fc:	add    BYTE PTR [rax],al
    38fe:	add    BYTE PTR [rax],al
    3900:	(bad)
    3901:	add    BYTE PTR [rax],al
    3903:	add    BYTE PTR [rax],al
    3905:	add    BYTE PTR [rax],al
	...

0000000000003908 <botlish_entry_27: ht_set<mutarray, str, str>>:
    3908:	push   rbp
    3909:	mov    rbp,rsp
    390c:	mov    rsi,QWORD PTR [rdx]
    390f:	mov    r8,QWORD PTR [rdx+0x8]
    3913:	mov    rcx,QWORD PTR [rdx+0x10]
    3917:	mov    rdx,r8
    391a:	call   391f <botlish_entry_27+0x17>
			391b: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    391f:	mov    rsp,rbp
    3922:	pop    rbp
    3923:	ret
    3924:	add    BYTE PTR [rax],al
	...

0000000000003928 <botlish_fn_28: ht_delete<mutarray, str>>:
    3928:	push   rbp
    3929:	mov    rbp,rsp
    392c:	sub    rsp,0x30
    3930:	mov    QWORD PTR [rsp],rbx
    3934:	mov    QWORD PTR [rsp+0x8],r12
    3939:	mov    QWORD PTR [rsp+0x10],r13
    393e:	mov    QWORD PTR [rsp+0x18],r14
    3943:	mov    QWORD PTR [rsp+0x20],r15
    3948:	mov    rbx,QWORD PTR [rdi]
    394b:	mov    rax,QWORD PTR [rdi+0x8]
    394f:	lea    rcx,[rbx+0x20]
    3953:	cmp    rcx,rax
    3956:	ja     3e39 <botlish_fn_28+0x511>
    395c:	lea    rax,[rbx+0x20]
    3960:	mov    QWORD PTR [rdi],rax
    3963:	mov    r12,rdi
    3966:	mov    QWORD PTR [rbx],0x0
    396d:	mov    QWORD PTR [rbx+0x8],0x0
    3975:	mov    QWORD PTR [rbx+0x10],0x0
    397d:	mov    QWORD PTR [rbx+0x18],0x0
    3985:	mov    QWORD PTR [rbx],rsi
    3988:	mov    r13,rsi
    398b:	mov    QWORD PTR [rbx+0x8],rdx
    398f:	mov    r14,rdx
    3992:	mov    rdx,r14
    3995:	mov    rsi,r13
    3998:	mov    rdi,r12
    399b:	call   39a0 <botlish_fn_28+0x78>
			399c: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_probe_start<mutarray, str>
    39a0:	test   rax,rax
    39a3:	jne    39b1 <botlish_fn_28+0x89>
    39a9:	mov    rdi,r12
    39ac:	jmp    3db7 <botlish_fn_28+0x48f>
    39b1:	mov    QWORD PTR [rbx+0x10],rax
    39b5:	mov    rcx,rax
    39b8:	mov    rdx,r14
    39bb:	mov    rsi,r13
    39be:	mov    rdi,r12
    39c1:	call   39c6 <botlish_fn_28+0x9e>
			39c2: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_find_get<mutarray, str, int>
    39c6:	mov    rcx,rax
    39c9:	mov    r14,rax
    39cc:	test   rax,rcx
    39cf:	jne    39dd <botlish_fn_28+0xb5>
    39d5:	mov    rdi,r12
    39d8:	jmp    3db7 <botlish_fn_28+0x48f>
    39dd:	mov    rax,r14
    39e0:	mov    QWORD PTR [rbx+0x8],rax
    39e4:	test   rax,0x1
    39ea:	jne    3a15 <botlish_fn_28+0xed>
    39f0:	mov    edx,0x1
    39f5:	mov    rsi,r14
    39f8:	mov    rdi,r12
    39fb:	call   3a00 <botlish_fn_28+0xd8>
			39fc: R_X86_64_PLT32	rt_int_cmp-0x4
    3a00:	mov    ecx,0x2
    3a05:	test   rax,rax
    3a08:	cmovl  rcx,QWORD PTR [rip+0x458]        # 3e68 <botlish_fn_28+0x540>
    3a10:	jmp    3a2b <botlish_fn_28+0x103>
    3a15:	mov    ecx,0x2
    3a1a:	mov    rax,r14
    3a1d:	mov    rdx,r14
    3a20:	test   rax,rdx
    3a23:	cmovle rcx,QWORD PTR [rip+0x43d]        # 3e68 <botlish_fn_28+0x540>
    3a2b:	cmp    rcx,0x6
    3a2f:	je     3e0d <botlish_fn_28+0x4e5>
    3a35:	mov    rsi,r13
    3a38:	mov    rdi,r12
    3a3b:	call   3a40 <botlish_fn_28+0x118>
			3a3c: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_controls<mutarray>
    3a40:	test   rax,rax
    3a43:	jne    3a51 <botlish_fn_28+0x129>
    3a49:	mov    rdi,r12
    3a4c:	jmp    3db7 <botlish_fn_28+0x48f>
    3a51:	mov    QWORD PTR [rbx+0x10],rax
    3a55:	mov    r15,rax
    3a58:	mov    rdi,r12
    3a5b:	call   3a60 <botlish_fn_28+0x138>
			3a5c: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_tombstone_state<generic>
    3a60:	test   rax,rax
    3a63:	mov    rsi,rax
    3a66:	jne    3a74 <botlish_fn_28+0x14c>
    3a6c:	mov    rdi,r12
    3a6f:	jmp    3db7 <botlish_fn_28+0x48f>
    3a74:	xor    ecx,ecx
    3a76:	mov    rax,r15
    3a79:	test   rax,0x7
    3a7f:	je     3a8d <botlish_fn_28+0x165>
    3a85:	mov    r15,rax
    3a88:	jmp    3a9b <botlish_fn_28+0x173>
    3a8d:	movzx  r9,BYTE PTR [rax]
    3a91:	mov    r15,rax
    3a94:	cmp    r9b,0x8
    3a98:	sete   cl
    3a9b:	test   cl,cl
    3a9d:	jne    3ac3 <botlish_fn_28+0x19b>
    3aa3:	mov    rdi,r12
    3aa6:	mov    rax,QWORD PTR [rdi+0x10]
    3aaa:	mov    rcx,QWORD PTR [rax+0x20]
    3aae:	mov    edx,0x8
    3ab3:	mov    rsi,r15
    3ab6:	call   3abb <botlish_fn_28+0x193>
			3ab7: R_X86_64_PLT32	rt_type_error-0x4
    3abb:	mov    rdi,r12
    3abe:	jmp    3db7 <botlish_fn_28+0x48f>
    3ac3:	mov    rcx,rsi
    3ac6:	mov    rsi,r15
    3ac9:	mov    rdx,r14
    3acc:	mov    rdi,r12
    3acf:	call   3ad4 <botlish_fn_28+0x1ac>
			3ad0: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ad4:	test   rax,rax
    3ad7:	jne    3ae5 <botlish_fn_28+0x1bd>
    3add:	mov    rdi,r12
    3ae0:	jmp    3db7 <botlish_fn_28+0x48f>
    3ae5:	mov    rsi,r13
    3ae8:	mov    rdi,r12
    3aeb:	call   3af0 <botlish_fn_28+0x1c8>
			3aec: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_keys<mutarray>
    3af0:	test   rax,rax
    3af3:	jne    3b01 <botlish_fn_28+0x1d9>
    3af9:	mov    rdi,r12
    3afc:	jmp    3db7 <botlish_fn_28+0x48f>
    3b01:	xor    ecx,ecx
    3b03:	test   rax,0x7
    3b09:	je     3b17 <botlish_fn_28+0x1ef>
    3b0f:	mov    rsi,rax
    3b12:	jmp    3b25 <botlish_fn_28+0x1fd>
    3b17:	movzx  rcx,BYTE PTR [rax]
    3b1b:	mov    rsi,rax
    3b1e:	rex cmp cl,0x8
    3b22:	sete   cl
    3b25:	test   cl,cl
    3b27:	jne    3b4a <botlish_fn_28+0x222>
    3b2d:	mov    rdi,r12
    3b30:	mov    rax,QWORD PTR [rdi+0x10]
    3b34:	mov    rcx,QWORD PTR [rax+0x20]
    3b38:	mov    edx,0x8
    3b3d:	call   3b42 <botlish_fn_28+0x21a>
			3b3e: R_X86_64_PLT32	rt_type_error-0x4
    3b42:	mov    rdi,r12
    3b45:	jmp    3db7 <botlish_fn_28+0x48f>
    3b4a:	mov    ecx,0xa
    3b4f:	mov    rdx,r14
    3b52:	mov    rdi,r12
    3b55:	call   3b5a <botlish_fn_28+0x232>
			3b56: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b5a:	test   rax,rax
    3b5d:	jne    3b6b <botlish_fn_28+0x243>
    3b63:	mov    rdi,r12
    3b66:	jmp    3db7 <botlish_fn_28+0x48f>
    3b6b:	mov    rsi,r13
    3b6e:	mov    rdi,r12
    3b71:	call   3b76 <botlish_fn_28+0x24e>
			3b72: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_values<mutarray>
    3b76:	test   rax,rax
    3b79:	jne    3b87 <botlish_fn_28+0x25f>
    3b7f:	mov    rdi,r12
    3b82:	jmp    3db7 <botlish_fn_28+0x48f>
    3b87:	xor    ecx,ecx
    3b89:	test   rax,0x7
    3b8f:	je     3b9d <botlish_fn_28+0x275>
    3b95:	mov    rsi,rax
    3b98:	jmp    3bab <botlish_fn_28+0x283>
    3b9d:	movzx  rcx,BYTE PTR [rax]
    3ba1:	mov    rsi,rax
    3ba4:	rex cmp cl,0x8
    3ba8:	sete   cl
    3bab:	test   cl,cl
    3bad:	jne    3bd0 <botlish_fn_28+0x2a8>
    3bb3:	mov    rdi,r12
    3bb6:	mov    rax,QWORD PTR [rdi+0x10]
    3bba:	mov    rcx,QWORD PTR [rax+0x20]
    3bbe:	mov    edx,0x8
    3bc3:	call   3bc8 <botlish_fn_28+0x2a0>
			3bc4: R_X86_64_PLT32	rt_type_error-0x4
    3bc8:	mov    rdi,r12
    3bcb:	jmp    3db7 <botlish_fn_28+0x48f>
    3bd0:	mov    ecx,0xa
    3bd5:	mov    rdx,r14
    3bd8:	mov    rdi,r12
    3bdb:	call   3be0 <botlish_fn_28+0x2b8>
			3bdc: R_X86_64_PLT32	rt_mutarray_set-0x4
    3be0:	test   rax,rax
    3be3:	jne    3bf1 <botlish_fn_28+0x2c9>
    3be9:	mov    rdi,r12
    3bec:	jmp    3db7 <botlish_fn_28+0x48f>
    3bf1:	mov    QWORD PTR [rbx+0x8],0x7
    3bf9:	mov    rsi,r13
    3bfc:	mov    rdi,r12
    3bff:	call   3c04 <botlish_fn_28+0x2dc>
			3c00: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    3c04:	test   rax,rax
    3c07:	jne    3c15 <botlish_fn_28+0x2ed>
    3c0d:	mov    rdi,r12
    3c10:	jmp    3db7 <botlish_fn_28+0x48f>
    3c15:	mov    QWORD PTR [rbx+0x10],rax
    3c19:	mov    QWORD PTR [rbx+0x18],0x3
    3c21:	mov    edi,0x1
    3c26:	test   rax,0x1
    3c2c:	je     3c3a <botlish_fn_28+0x312>
    3c32:	mov    rsi,rax
    3c35:	jmp    3c5f <botlish_fn_28+0x337>
    3c3a:	xor    edi,edi
    3c3c:	test   rax,0x7
    3c42:	je     3c50 <botlish_fn_28+0x328>
    3c48:	mov    rsi,rax
    3c4b:	jmp    3c5f <botlish_fn_28+0x337>
    3c50:	movzx  rcx,BYTE PTR [rax]
    3c54:	mov    rsi,rax
    3c57:	rex cmp cl,0x1
    3c5b:	sete   dil
    3c5f:	test   dil,dil
    3c62:	jne    3c83 <botlish_fn_28+0x35b>
    3c68:	mov    rdi,r12
    3c6b:	mov    rax,QWORD PTR [rdi+0x10]
    3c6f:	mov    rcx,QWORD PTR [rax+0x28]
    3c73:	xor    rdx,rdx
    3c76:	call   3c7b <botlish_fn_28+0x353>
			3c77: R_X86_64_PLT32	rt_type_error-0x4
    3c7b:	mov    rdi,r12
    3c7e:	jmp    3db7 <botlish_fn_28+0x48f>
    3c83:	test   rsi,0x1
    3c8a:	je     3cab <botlish_fn_28+0x383>
    3c90:	mov    rcx,rsi
    3c93:	sub    rcx,0x3
    3c97:	seto   dil
    3c9b:	add    rcx,0x1
    3ca2:	test   dil,dil
    3ca5:	je     3cbb <botlish_fn_28+0x393>
    3cab:	mov    edx,0x3
    3cb0:	mov    rdi,r12
    3cb3:	call   3cb8 <botlish_fn_28+0x390>
			3cb4: R_X86_64_PLT32	rt_int_sub-0x4
    3cb8:	mov    rcx,rax
    3cbb:	mov    edx,0x7
    3cc0:	mov    rsi,r13
    3cc3:	mov    rdi,r12
    3cc6:	call   3ccb <botlish_fn_28+0x3a3>
			3cc7: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ccb:	test   rax,rax
    3cce:	jne    3cdc <botlish_fn_28+0x3b4>
    3cd4:	mov    rdi,r12
    3cd7:	jmp    3db7 <botlish_fn_28+0x48f>
    3cdc:	mov    QWORD PTR [rbx+0x8],0x9
    3ce4:	mov    rsi,r13
    3ce7:	mov    rdi,r12
    3cea:	call   3cef <botlish_fn_28+0x3c7>
			3ceb: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_tombstones<mutarray>
    3cef:	test   rax,rax
    3cf2:	jne    3d00 <botlish_fn_28+0x3d8>
    3cf8:	mov    rdi,r12
    3cfb:	jmp    3db7 <botlish_fn_28+0x48f>
    3d00:	mov    QWORD PTR [rbx+0x10],rax
    3d04:	mov    QWORD PTR [rbx+0x18],0x3
    3d0c:	mov    ecx,0x1
    3d11:	test   rax,0x1
    3d17:	je     3d25 <botlish_fn_28+0x3fd>
    3d1d:	mov    rsi,rax
    3d20:	jmp    3d49 <botlish_fn_28+0x421>
    3d25:	xor    ecx,ecx
    3d27:	test   rax,0x7
    3d2d:	je     3d3b <botlish_fn_28+0x413>
    3d33:	mov    rsi,rax
    3d36:	jmp    3d49 <botlish_fn_28+0x421>
    3d3b:	movzx  rcx,BYTE PTR [rax]
    3d3f:	mov    rsi,rax
    3d42:	rex cmp cl,0x1
    3d46:	sete   cl
    3d49:	test   cl,cl
    3d4b:	jne    3d6c <botlish_fn_28+0x444>
    3d51:	mov    rdi,r12
    3d54:	mov    rax,QWORD PTR [rdi+0x10]
    3d58:	mov    rcx,QWORD PTR [rax+0x10]
    3d5c:	xor    rdx,rdx
    3d5f:	call   3d64 <botlish_fn_28+0x43c>
			3d60: R_X86_64_PLT32	rt_type_error-0x4
    3d64:	mov    rdi,r12
    3d67:	jmp    3db7 <botlish_fn_28+0x48f>
    3d6c:	test   rsi,0x1
    3d73:	je     3d8b <botlish_fn_28+0x463>
    3d79:	mov    rcx,rsi
    3d7c:	add    rcx,0x2
    3d80:	seto   al
    3d83:	test   al,al
    3d85:	je     3d9b <botlish_fn_28+0x473>
    3d8b:	mov    edx,0x3
    3d90:	mov    rdi,r12
    3d93:	call   3d98 <botlish_fn_28+0x470>
			3d94: R_X86_64_PLT32	rt_int_add-0x4
    3d98:	mov    rcx,rax
    3d9b:	mov    edx,0x9
    3da0:	mov    rsi,r13
    3da3:	mov    rdi,r12
    3da6:	call   3dab <botlish_fn_28+0x483>
			3da7: R_X86_64_PLT32	rt_mutarray_set-0x4
    3dab:	test   rax,rax
    3dae:	jne    3de1 <botlish_fn_28+0x4b9>
    3db4:	mov    rdi,r12
    3db7:	mov    rdi,r12
    3dba:	mov    QWORD PTR [rdi],rbx
    3dbd:	xor    rax,rax
    3dc0:	mov    rbx,QWORD PTR [rsp]
    3dc4:	mov    r12,QWORD PTR [rsp+0x8]
    3dc9:	mov    r13,QWORD PTR [rsp+0x10]
    3dce:	mov    r14,QWORD PTR [rsp+0x18]
    3dd3:	mov    r15,QWORD PTR [rsp+0x20]
    3dd8:	add    rsp,0x30
    3ddc:	mov    rsp,rbp
    3ddf:	pop    rbp
    3de0:	ret
    3de1:	mov    rdi,r12
    3de4:	mov    QWORD PTR [rdi],rbx
    3de7:	mov    eax,0xa
    3dec:	mov    rbx,QWORD PTR [rsp]
    3df0:	mov    r12,QWORD PTR [rsp+0x8]
    3df5:	mov    r13,QWORD PTR [rsp+0x10]
    3dfa:	mov    r14,QWORD PTR [rsp+0x18]
    3dff:	mov    r15,QWORD PTR [rsp+0x20]
    3e04:	add    rsp,0x30
    3e08:	mov    rsp,rbp
    3e0b:	pop    rbp
    3e0c:	ret
    3e0d:	mov    rdi,r12
    3e10:	mov    QWORD PTR [rdi],rbx
    3e13:	mov    eax,0xa
    3e18:	mov    rbx,QWORD PTR [rsp]
    3e1c:	mov    r12,QWORD PTR [rsp+0x8]
    3e21:	mov    r13,QWORD PTR [rsp+0x10]
    3e26:	mov    r14,QWORD PTR [rsp+0x18]
    3e2b:	mov    r15,QWORD PTR [rsp+0x20]
    3e30:	add    rsp,0x30
    3e34:	mov    rsp,rbp
    3e37:	pop    rbp
    3e38:	ret
    3e39:	mov    r12,rdi
    3e3c:	call   3e41 <botlish_fn_28+0x519>
			3e3d: R_X86_64_PLT32	rt_stack_overflow-0x4
    3e41:	xor    rax,rax
    3e44:	mov    rbx,QWORD PTR [rsp]
    3e48:	mov    r12,QWORD PTR [rsp+0x8]
    3e4d:	mov    r13,QWORD PTR [rsp+0x10]
    3e52:	mov    r14,QWORD PTR [rsp+0x18]
    3e57:	mov    r15,QWORD PTR [rsp+0x20]
    3e5c:	add    rsp,0x30
    3e60:	mov    rsp,rbp
    3e63:	pop    rbp
    3e64:	ret
    3e65:	add    BYTE PTR [rax],al
    3e67:	add    BYTE PTR [rsi],al
    3e69:	add    BYTE PTR [rax],al
    3e6b:	add    BYTE PTR [rax],al
    3e6d:	add    BYTE PTR [rax],al
	...

0000000000003e70 <botlish_entry_28: ht_delete<mutarray, str>>:
    3e70:	push   rbp
    3e71:	mov    rbp,rsp
    3e74:	mov    rsi,QWORD PTR [rdx]
    3e77:	mov    rdx,QWORD PTR [rdx+0x8]
    3e7b:	call   3e80 <botlish_entry_28+0x10>
			3e7c: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    3e80:	mov    rsp,rbp
    3e83:	pop    rbp
    3e84:	ret
    3e85:	add    BYTE PTR [rax],al
	...

0000000000003e88 <botlish_fn_29: sample<generic>>:
    3e88:	push   rbp
    3e89:	mov    rbp,rsp
    3e8c:	sub    rsp,0x70
    3e90:	mov    QWORD PTR [rsp+0x40],rbx
    3e95:	mov    QWORD PTR [rsp+0x48],r12
    3e9a:	mov    QWORD PTR [rsp+0x50],r13
    3e9f:	mov    QWORD PTR [rsp+0x58],r14
    3ea4:	mov    QWORD PTR [rsp+0x60],r15
    3ea9:	mov    r12,QWORD PTR [rdi]
    3eac:	mov    rax,QWORD PTR [rdi+0x8]
    3eb0:	lea    rcx,[r12+0x30]
    3eb5:	cmp    rcx,rax
    3eb8:	ja     4244 <botlish_fn_29+0x3bc>
    3ebe:	lea    rax,[r12+0x30]
    3ec3:	mov    QWORD PTR [rdi],rax
    3ec6:	mov    QWORD PTR [rsp+0x30],rdi
    3ecb:	mov    QWORD PTR [r12],0x0
    3ed3:	mov    QWORD PTR [r12+0x8],0x0
    3edc:	mov    QWORD PTR [r12+0x10],0x0
    3ee5:	mov    QWORD PTR [r12+0x18],0x0
    3eee:	mov    QWORD PTR [r12+0x20],0x0
    3ef7:	mov    QWORD PTR [r12+0x28],0x0
    3f00:	mov    rdi,QWORD PTR [rsp+0x30]
    3f05:	call   3f0a <botlish_fn_29+0x82>
			3f06: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_new<generic>
    3f0a:	mov    rbx,rax
    3f0d:	test   rbx,rbx
    3f10:	jne    3f20 <botlish_fn_29+0x98>
    3f16:	mov    rdi,QWORD PTR [rsp+0x30]
    3f1b:	jmp    41ed <botlish_fn_29+0x365>
    3f20:	mov    QWORD PTR [r12],rbx
    3f24:	mov    rdi,QWORD PTR [rsp+0x30]
    3f29:	mov    r9,QWORD PTR [rdi+0x10]
    3f2d:	mov    rdx,QWORD PTR [r9+0x30]
    3f31:	mov    QWORD PTR [r12+0x8],rdx
    3f36:	mov    r10,QWORD PTR [rdi+0x10]
    3f3a:	mov    rcx,QWORD PTR [r10+0x38]
    3f3e:	mov    QWORD PTR [r12+0x10],rcx
    3f43:	mov    rsi,rbx
    3f46:	call   3f4b <botlish_fn_29+0xc3>
			3f47: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3f4b:	test   rax,rax
    3f4e:	jne    3f5e <botlish_fn_29+0xd6>
    3f54:	mov    rdi,QWORD PTR [rsp+0x30]
    3f59:	jmp    41ed <botlish_fn_29+0x365>
    3f5e:	mov    rdi,QWORD PTR [rsp+0x30]
    3f63:	mov    rax,QWORD PTR [rdi+0x10]
    3f67:	mov    rdx,QWORD PTR [rax+0x40]
    3f6b:	mov    QWORD PTR [r12+0x8],rdx
    3f70:	mov    rax,QWORD PTR [rdi+0x10]
    3f74:	mov    rcx,QWORD PTR [rax+0x48]
    3f78:	mov    QWORD PTR [r12+0x10],rcx
    3f7d:	mov    rsi,rbx
    3f80:	call   3f85 <botlish_fn_29+0xfd>
			3f81: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3f85:	test   rax,rax
    3f88:	jne    3f98 <botlish_fn_29+0x110>
    3f8e:	mov    rdi,QWORD PTR [rsp+0x30]
    3f93:	jmp    41ed <botlish_fn_29+0x365>
    3f98:	mov    rdi,QWORD PTR [rsp+0x30]
    3f9d:	mov    rax,QWORD PTR [rdi+0x10]
    3fa1:	mov    rdx,QWORD PTR [rax+0x30]
    3fa5:	mov    QWORD PTR [r12+0x8],rdx
    3faa:	mov    rax,QWORD PTR [rdi+0x10]
    3fae:	mov    rcx,QWORD PTR [rax+0x50]
    3fb2:	mov    QWORD PTR [r12+0x10],rcx
    3fb7:	mov    rsi,rbx
    3fba:	call   3fbf <botlish_fn_29+0x137>
			3fbb: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_set<mutarray, str, str>
    3fbf:	test   rax,rax
    3fc2:	jne    3fd2 <botlish_fn_29+0x14a>
    3fc8:	mov    rdi,QWORD PTR [rsp+0x30]
    3fcd:	jmp    41ed <botlish_fn_29+0x365>
    3fd2:	mov    rdi,QWORD PTR [rsp+0x30]
    3fd7:	mov    rax,QWORD PTR [rdi+0x10]
    3fdb:	mov    rdx,QWORD PTR [rax+0x40]
    3fdf:	mov    QWORD PTR [r12+0x8],rdx
    3fe4:	mov    rsi,rbx
    3fe7:	call   3fec <botlish_fn_29+0x164>
			3fe8: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    3fec:	mov    r8,rax
    3fef:	test   r8,r8
    3ff2:	jne    4002 <botlish_fn_29+0x17a>
    3ff8:	mov    rdi,QWORD PTR [rsp+0x30]
    3ffd:	jmp    41ed <botlish_fn_29+0x365>
    4002:	mov    QWORD PTR [r12+0x8],r8
    4007:	mov    rdi,QWORD PTR [rsp+0x30]
    400c:	mov    QWORD PTR [rsp+0x38],r8
    4011:	mov    rax,QWORD PTR [rdi+0x10]
    4015:	mov    rdx,QWORD PTR [rax+0x40]
    4019:	mov    QWORD PTR [r12+0x10],rdx
    401e:	mov    rsi,rbx
    4021:	call   4026 <botlish_fn_29+0x19e>
			4022: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_delete<mutarray, str>
    4026:	test   rax,rax
    4029:	jne    4039 <botlish_fn_29+0x1b1>
    402f:	mov    rdi,QWORD PTR [rsp+0x30]
    4034:	jmp    41ed <botlish_fn_29+0x365>
    4039:	mov    rdi,QWORD PTR [rsp+0x30]
    403e:	mov    rax,QWORD PTR [rdi+0x10]
    4042:	mov    rdx,QWORD PTR [rax+0x30]
    4046:	mov    QWORD PTR [r12+0x10],rdx
    404b:	mov    rsi,rbx
    404e:	call   4053 <botlish_fn_29+0x1cb>
			404f: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    4053:	test   rax,rax
    4056:	jne    4066 <botlish_fn_29+0x1de>
    405c:	mov    rdi,QWORD PTR [rsp+0x30]
    4061:	jmp    41ed <botlish_fn_29+0x365>
    4066:	mov    rdi,QWORD PTR [rsp+0x30]
    406b:	mov    rcx,QWORD PTR [rdi+0x10]
    406f:	mov    rdx,QWORD PTR [rcx+0x50]
    4073:	mov    rcx,rax
    4076:	and    rcx,rdx
    4079:	mov    rsi,rax
    407c:	test   rcx,0x1
    4083:	jne    40a9 <botlish_fn_29+0x221>
    4089:	mov    rdi,QWORD PTR [rsp+0x30]
    408e:	call   4093 <botlish_fn_29+0x20b>
			408f: R_X86_64_PLT32	rt_value_eq-0x4
    4093:	mov    r13,rax
    4096:	test   r13,r13
    4099:	jne    40ba <botlish_fn_29+0x232>
    409f:	mov    rdi,QWORD PTR [rsp+0x30]
    40a4:	jmp    41ed <botlish_fn_29+0x365>
    40a9:	mov    r13d,0x2
    40af:	cmp    rsi,rdx
    40b2:	cmove  r13,QWORD PTR [rip+0x1be]        # 4278 <botlish_fn_29+0x3f0>
    40ba:	mov    QWORD PTR [r12+0x10],r13
    40bf:	mov    rdi,QWORD PTR [rsp+0x30]
    40c4:	mov    rax,QWORD PTR [rdi+0x10]
    40c8:	mov    rdx,QWORD PTR [rax+0x40]
    40cc:	mov    QWORD PTR [r12+0x18],rdx
    40d1:	mov    rsi,rbx
    40d4:	call   40d9 <botlish_fn_29+0x251>
			40d5: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    40d9:	mov    r14,rax
    40dc:	test   r14,r14
    40df:	jne    40ef <botlish_fn_29+0x267>
    40e5:	mov    rdi,QWORD PTR [rsp+0x30]
    40ea:	jmp    41ed <botlish_fn_29+0x365>
    40ef:	mov    QWORD PTR [r12+0x18],r14
    40f4:	mov    rdi,QWORD PTR [rsp+0x30]
    40f9:	mov    rax,QWORD PTR [rdi+0x10]
    40fd:	mov    rdx,QWORD PTR [rax+0x58]
    4101:	mov    QWORD PTR [r12+0x20],rdx
    4106:	mov    rsi,rbx
    4109:	call   410e <botlish_fn_29+0x286>
			410a: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_contains<mutarray, str>
    410e:	mov    r15,rax
    4111:	test   r15,r15
    4114:	jne    4124 <botlish_fn_29+0x29c>
    411a:	mov    rdi,QWORD PTR [rsp+0x30]
    411f:	jmp    41ed <botlish_fn_29+0x365>
    4124:	mov    QWORD PTR [r12+0x20],r15
    4129:	mov    rdi,QWORD PTR [rsp+0x30]
    412e:	mov    rax,QWORD PTR [rdi+0x10]
    4132:	mov    rdx,QWORD PTR [rax+0x58]
    4136:	mov    QWORD PTR [r12+0x28],rdx
    413b:	mov    rsi,rbx
    413e:	call   4143 <botlish_fn_29+0x2bb>
			413f: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_get<mutarray, str>
    4143:	test   rax,rax
    4146:	mov    rsi,rax
    4149:	jne    4159 <botlish_fn_29+0x2d1>
    414f:	mov    rdi,QWORD PTR [rsp+0x30]
    4154:	jmp    41ed <botlish_fn_29+0x365>
    4159:	mov    edx,0xa
    415e:	mov    rdi,QWORD PTR [rsp+0x30]
    4163:	call   4168 <botlish_fn_29+0x2e0>
			4164: R_X86_64_PLT32	rt_value_eq-0x4
    4168:	test   rax,rax
    416b:	jne    417b <botlish_fn_29+0x2f3>
    4171:	mov    rdi,QWORD PTR [rsp+0x30]
    4176:	jmp    41ed <botlish_fn_29+0x365>
    417b:	mov    QWORD PTR [r12+0x28],rax
    4180:	mov    rsi,rbx
    4183:	mov    rbx,rax
    4186:	mov    rdi,QWORD PTR [rsp+0x30]
    418b:	call   4190 <botlish_fn_29+0x308>
			418c: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_size<mutarray>
    4190:	test   rax,rax
    4193:	jne    41a3 <botlish_fn_29+0x31b>
    4199:	mov    rdi,QWORD PTR [rsp+0x30]
    419e:	jmp    41ed <botlish_fn_29+0x365>
    41a3:	mov    QWORD PTR [r12],rax
    41a7:	lea    rdx,[rsp]
    41ab:	mov    QWORD PTR [rsp],r13
    41af:	mov    r8,QWORD PTR [rsp+0x38]
    41b4:	mov    QWORD PTR [rsp+0x8],r8
    41b9:	mov    QWORD PTR [rsp+0x10],r14
    41be:	mov    QWORD PTR [rsp+0x18],r15
    41c3:	mov    rcx,rbx
    41c6:	mov    QWORD PTR [rsp+0x20],rcx
    41cb:	mov    QWORD PTR [rsp+0x28],rax
    41d0:	mov    esi,0x6
    41d5:	mov    rdi,QWORD PTR [rsp+0x30]
    41da:	call   41df <botlish_fn_29+0x357>
			41db: R_X86_64_PLT32	rt_list_new-0x4
    41df:	test   rax,rax
    41e2:	jne    421a <botlish_fn_29+0x392>
    41e8:	mov    rdi,QWORD PTR [rsp+0x30]
    41ed:	mov    rdi,QWORD PTR [rsp+0x30]
    41f2:	mov    QWORD PTR [rdi],r12
    41f5:	xor    rax,rax
    41f8:	mov    rbx,QWORD PTR [rsp+0x40]
    41fd:	mov    r12,QWORD PTR [rsp+0x48]
    4202:	mov    r13,QWORD PTR [rsp+0x50]
    4207:	mov    r14,QWORD PTR [rsp+0x58]
    420c:	mov    r15,QWORD PTR [rsp+0x60]
    4211:	add    rsp,0x70
    4215:	mov    rsp,rbp
    4218:	pop    rbp
    4219:	ret
    421a:	mov    rdi,QWORD PTR [rsp+0x30]
    421f:	mov    QWORD PTR [rdi],r12
    4222:	mov    rbx,QWORD PTR [rsp+0x40]
    4227:	mov    r12,QWORD PTR [rsp+0x48]
    422c:	mov    r13,QWORD PTR [rsp+0x50]
    4231:	mov    r14,QWORD PTR [rsp+0x58]
    4236:	mov    r15,QWORD PTR [rsp+0x60]
    423b:	add    rsp,0x70
    423f:	mov    rsp,rbp
    4242:	pop    rbp
    4243:	ret
    4244:	mov    QWORD PTR [rsp+0x30],rdi
    4249:	call   424e <botlish_fn_29+0x3c6>
			424a: R_X86_64_PLT32	rt_stack_overflow-0x4
    424e:	xor    rax,rax
    4251:	mov    rbx,QWORD PTR [rsp+0x40]
    4256:	mov    r12,QWORD PTR [rsp+0x48]
    425b:	mov    r13,QWORD PTR [rsp+0x50]
    4260:	mov    r14,QWORD PTR [rsp+0x58]
    4265:	mov    r15,QWORD PTR [rsp+0x60]
    426a:	add    rsp,0x70
    426e:	mov    rsp,rbp
    4271:	pop    rbp
    4272:	ret
    4273:	add    BYTE PTR [rax],al
    4275:	add    BYTE PTR [rax],al
    4277:	add    BYTE PTR [rsi],al
    4279:	add    BYTE PTR [rax],al
    427b:	add    BYTE PTR [rax],al
    427d:	add    BYTE PTR [rax],al
	...

0000000000004280 <botlish_entry_29: sample<generic>>:
    4280:	push   rbp
    4281:	mov    rbp,rsp
    4284:	call   4289 <botlish_entry_29+0x9>
			4285: R_X86_64_PLT32	botlish_fn_29-0x4 ; sample<generic>
    4289:	mov    rsp,rbp
    428c:	pop    rbp
    428d:	ret

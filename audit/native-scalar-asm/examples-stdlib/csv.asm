; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5860  (per function: 68 496 430 585 1069 352 795 976 398 524 167)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> peek<str, int>
;   botlish_fn_2 / botlish_entry_2 -> peek<str, int>
;   botlish_fn_3 / botlish_entry_3 -> scan_unquoted<str, int, int>
;   botlish_fn_4 / botlish_entry_4 -> scan_quoted<str, int, str>
;   botlish_fn_5 / botlish_entry_5 -> scan_field<str, int>
;   botlish_fn_6 / botlish_entry_6 -> scan_record<str, int, List[never]>
;   botlish_fn_7 / botlish_entry_7 -> scan_record<str, int, List[str]>
;   botlish_fn_8 / botlish_entry_8 -> scan_records<str, int, List[never]>
;   botlish_fn_9 / botlish_entry_9 -> scan_records<str, int, List[List[str]]>
;   botlish_fn_10 / botlish_entry_10 -> csv_parse<str>


csv.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x10
       8:	mov    r8,QWORD PTR [rdi+0x10]
       c:	mov    rsi,QWORD PTR [r8]
       f:	mov    QWORD PTR [rsp],rsi
      13:	call   18 <botlish_fn_0+0x18>
			14: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
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

0000000000000048 <botlish_fn_1: peek<str, int>>:
      48:	push   rbp
      49:	mov    rbp,rsp
      4c:	sub    rsp,0x40
      50:	mov    QWORD PTR [rsp+0x20],rbx
      55:	mov    QWORD PTR [rsp+0x28],r12
      5a:	mov    QWORD PTR [rsp+0x30],r13
      5f:	mov    QWORD PTR [rsp+0x38],r14
      64:	mov    r13,rdi
      67:	mov    QWORD PTR [rsp],rsi
      6b:	mov    r12,rsi
      6e:	mov    QWORD PTR [rsp+0x8],rdx
      73:	mov    rbx,rdx
      76:	mov    rsi,r12
      79:	mov    rdi,r13
      7c:	call   81 <botlish_fn_1+0x39>
			7d: R_X86_64_PLT32	rt_str_len-0x4
      81:	mov    rcx,rbx
      84:	and    rcx,rax
      87:	mov    rdx,rax
      8a:	test   rcx,0x1
      91:	jne    b7 <botlish_fn_1+0x6f>
      97:	mov    rsi,rbx
      9a:	mov    rdi,r13
      9d:	call   a2 <botlish_fn_1+0x5a>
			9e: R_X86_64_PLT32	rt_int_cmp-0x4
      a2:	mov    ecx,0x2
      a7:	test   rax,rax
      aa:	cmovge rcx,QWORD PTR [rip+0x106]        # 1b8 <botlish_fn_1+0x170>
      b2:	jmp    ca <botlish_fn_1+0x82>
      b7:	mov    ecx,0x2
      bc:	mov    rax,rbx
      bf:	cmp    rax,rdx
      c2:	cmovge rcx,QWORD PTR [rip+0xee]        # 1b8 <botlish_fn_1+0x170>
      ca:	cmp    rcx,0x6
      ce:	je     188 <botlish_fn_1+0x140>
      d4:	mov    QWORD PTR [rsp+0x10],0x3
      dd:	mov    rdx,rbx
      e0:	test   rdx,0x1
      e7:	je     105 <botlish_fn_1+0xbd>
      ed:	mov    rdx,rbx
      f0:	mov    rcx,rdx
      f3:	add    rcx,0x2
      f7:	mov    r14,rcx
      fa:	seto   al
      fd:	test   al,al
      ff:	je     118 <botlish_fn_1+0xd0>
     105:	mov    edx,0x3
     10a:	mov    rsi,rbx
     10d:	mov    rdi,r13
     110:	call   115 <botlish_fn_1+0xcd>
			111: R_X86_64_PLT32	rt_int_add-0x4
     115:	mov    r14,rax
     118:	mov    rcx,r14
     11b:	mov    rdx,rbx
     11e:	mov    rsi,r12
     121:	mov    rdi,r13
     124:	call   129 <botlish_fn_1+0xe1>
			125: R_X86_64_PLT32	rt_str_region_check-0x4
     129:	test   rax,rax
     12c:	jne    155 <botlish_fn_1+0x10d>
     132:	xor    rdx,rdx
     135:	mov    rax,rdx
     138:	mov    rbx,QWORD PTR [rsp+0x20]
     13d:	mov    r12,QWORD PTR [rsp+0x28]
     142:	mov    r13,QWORD PTR [rsp+0x30]
     147:	mov    r14,QWORD PTR [rsp+0x38]
     14c:	add    rsp,0x40
     150:	mov    rsp,rbp
     153:	pop    rbp
     154:	ret
     155:	mov    rcx,r14
     158:	mov    rdx,rbx
     15b:	mov    rsi,r12
     15e:	mov    rdi,r13
     161:	call   166 <botlish_fn_1+0x11e>
			162: R_X86_64_PLT32	rt_str_slice_short-0x4
     166:	mov    edx,0x1
     16b:	mov    rbx,QWORD PTR [rsp+0x20]
     170:	mov    r12,QWORD PTR [rsp+0x28]
     175:	mov    r13,QWORD PTR [rsp+0x30]
     17a:	mov    r14,QWORD PTR [rsp+0x38]
     17f:	add    rsp,0x40
     183:	mov    rsp,rbp
     186:	pop    rbp
     187:	ret
     188:	mov    rax,0xffffffffffffffff
     18f:	mov    edx,0x1
     194:	mov    rbx,QWORD PTR [rsp+0x20]
     199:	mov    r12,QWORD PTR [rsp+0x28]
     19e:	mov    r13,QWORD PTR [rsp+0x30]
     1a3:	mov    r14,QWORD PTR [rsp+0x38]
     1a8:	add    rsp,0x40
     1ac:	mov    rsp,rbp
     1af:	pop    rbp
     1b0:	ret
     1b1:	add    BYTE PTR [rax],al
     1b3:	add    BYTE PTR [rax],al
     1b5:	add    BYTE PTR [rax],al
     1b7:	add    BYTE PTR [rsi],al
     1b9:	add    BYTE PTR [rax],al
     1bb:	add    BYTE PTR [rax],al
     1bd:	add    BYTE PTR [rax],al
	...

00000000000001c0 <botlish_entry_1: peek<str, int>>:
     1c0:	push   rbp
     1c1:	mov    rbp,rsp
     1c4:	sub    rsp,0x10
     1c8:	mov    QWORD PTR [rsp],r12
     1cc:	mov    QWORD PTR [rsp+0x8],r15
     1d1:	mov    r15,rdi
     1d4:	mov    rsi,QWORD PTR [rdx]
     1d7:	mov    rdx,QWORD PTR [rdx+0x8]
     1db:	call   1e0 <botlish_entry_1+0x20>
			1dc: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     1e0:	mov    r12,rdx
     1e3:	mov    r10,QWORD PTR [rip+0x0]        # 1ea <botlish_entry_1+0x2a>
			1e6: R_X86_64_GOTPCREL	rt_short_to_str-0x4
     1ea:	mov    rsi,rax
     1ed:	mov    rdi,r15
     1f0:	call   r10
     1f3:	mov    rcx,rax
     1f6:	xor    rax,rax
     1f9:	mov    rdx,r12
     1fc:	test   rdx,rdx
     1ff:	cmovne rax,rcx
     203:	mov    r12,QWORD PTR [rsp]
     207:	mov    r15,QWORD PTR [rsp+0x8]
     20c:	add    rsp,0x10
     210:	mov    rsp,rbp
     213:	pop    rbp
     214:	ret
     215:	add    BYTE PTR [rax],al
	...

0000000000000218 <botlish_fn_2: peek<str, int>>:
     218:	push   rbp
     219:	mov    rbp,rsp
     21c:	sub    rsp,0x50
     220:	mov    QWORD PTR [rsp+0x20],rbx
     225:	mov    QWORD PTR [rsp+0x28],r12
     22a:	mov    QWORD PTR [rsp+0x30],r13
     22f:	mov    QWORD PTR [rsp+0x38],r14
     234:	mov    QWORD PTR [rsp+0x40],r15
     239:	mov    r12,rcx
     23c:	mov    r14,rdi
     23f:	mov    QWORD PTR [rsp],rsi
     243:	mov    r13,rsi
     246:	mov    QWORD PTR [rsp+0x8],rdx
     24b:	mov    rbx,rdx
     24e:	mov    rsi,r13
     251:	mov    rdi,r14
     254:	call   259 <botlish_fn_2+0x41>
			255: R_X86_64_PLT32	rt_str_len-0x4
     259:	mov    rcx,rbx
     25c:	and    rcx,rax
     25f:	mov    rdx,rax
     262:	test   rcx,0x1
     269:	jne    28f <botlish_fn_2+0x77>
     26f:	mov    rsi,rbx
     272:	mov    rdi,r14
     275:	call   27a <botlish_fn_2+0x62>
			276: R_X86_64_PLT32	rt_int_cmp-0x4
     27a:	mov    ecx,0x2
     27f:	test   rax,rax
     282:	cmovge rcx,QWORD PTR [rip+0x11e]        # 3a8 <botlish_fn_2+0x190>
     28a:	jmp    29f <botlish_fn_2+0x87>
     28f:	mov    ecx,0x2
     294:	cmp    rbx,rdx
     297:	cmovge rcx,QWORD PTR [rip+0x109]        # 3a8 <botlish_fn_2+0x190>
     29f:	cmp    rcx,0x6
     2a3:	je     363 <botlish_fn_2+0x14b>
     2a9:	mov    QWORD PTR [rsp+0x10],0x3
     2b2:	test   rbx,0x1
     2b9:	je     2dc <botlish_fn_2+0xc4>
     2bf:	mov    rax,rbx
     2c2:	add    rax,0x2
     2c6:	seto   cl
     2c9:	test   cl,cl
     2cb:	jne    2dc <botlish_fn_2+0xc4>
     2d1:	mov    rdi,r14
     2d4:	mov    r15,rax
     2d7:	jmp    2f2 <botlish_fn_2+0xda>
     2dc:	mov    edx,0x3
     2e1:	mov    rsi,rbx
     2e4:	mov    rdi,r14
     2e7:	call   2ec <botlish_fn_2+0xd4>
			2e8: R_X86_64_PLT32	rt_int_add-0x4
     2ec:	mov    r15,rax
     2ef:	mov    rdi,r14
     2f2:	mov    rdi,r14
     2f5:	mov    rcx,r15
     2f8:	mov    rdx,rbx
     2fb:	mov    rsi,r13
     2fe:	call   303 <botlish_fn_2+0xeb>
			2ff: R_X86_64_PLT32	rt_str_region_check-0x4
     303:	test   rax,rax
     306:	jne    331 <botlish_fn_2+0x119>
     30c:	xor    rax,rax
     30f:	mov    rbx,QWORD PTR [rsp+0x20]
     314:	mov    r12,QWORD PTR [rsp+0x28]
     319:	mov    r13,QWORD PTR [rsp+0x30]
     31e:	mov    r14,QWORD PTR [rsp+0x38]
     323:	mov    r15,QWORD PTR [rsp+0x40]
     328:	add    rsp,0x50
     32c:	mov    rsp,rbp
     32f:	pop    rbp
     330:	ret
     331:	mov    rcx,r12
     334:	mov    QWORD PTR [rcx],rbx
     337:	mov    rax,r15
     33a:	mov    QWORD PTR [rcx+0x8],rax
     33e:	mov    rax,r13
     341:	mov    rbx,QWORD PTR [rsp+0x20]
     346:	mov    r12,QWORD PTR [rsp+0x28]
     34b:	mov    r13,QWORD PTR [rsp+0x30]
     350:	mov    r14,QWORD PTR [rsp+0x38]
     355:	mov    r15,QWORD PTR [rsp+0x40]
     35a:	add    rsp,0x50
     35e:	mov    rsp,rbp
     361:	pop    rbp
     362:	ret
     363:	mov    rcx,r12
     366:	mov    rdi,r14
     369:	mov    rax,QWORD PTR [rdi+0x10]
     36d:	mov    rax,QWORD PTR [rax+0x8]
     371:	mov    QWORD PTR [rcx],0x1
     378:	mov    QWORD PTR [rcx+0x8],0x1
     380:	mov    rbx,QWORD PTR [rsp+0x20]
     385:	mov    r12,QWORD PTR [rsp+0x28]
     38a:	mov    r13,QWORD PTR [rsp+0x30]
     38f:	mov    r14,QWORD PTR [rsp+0x38]
     394:	mov    r15,QWORD PTR [rsp+0x40]
     399:	add    rsp,0x50
     39d:	mov    rsp,rbp
     3a0:	pop    rbp
     3a1:	ret
     3a2:	add    BYTE PTR [rax],al
     3a4:	add    BYTE PTR [rax],al
     3a6:	add    BYTE PTR [rax],al
     3a8:	(bad)
     3a9:	add    BYTE PTR [rax],al
     3ab:	add    BYTE PTR [rax],al
     3ad:	add    BYTE PTR [rax],al
	...

00000000000003b0 <botlish_entry_2: peek<str, int>>:
     3b0:	push   rbp
     3b1:	mov    rbp,rsp
     3b4:	ud2

00000000000003b6 <botlish_fn_3: scan_unquoted<str, int, int>>:
     3b6:	push   rbp
     3b7:	mov    rbp,rsp
     3ba:	sub    rsp,0x80
     3c1:	mov    QWORD PTR [rsp+0x50],rbx
     3c6:	mov    QWORD PTR [rsp+0x58],r12
     3cb:	mov    QWORD PTR [rsp+0x60],r13
     3d0:	mov    QWORD PTR [rsp+0x68],r14
     3d5:	mov    QWORD PTR [rsp+0x70],r15
     3da:	mov    QWORD PTR [rsp+0x30],rdi
     3df:	mov    QWORD PTR [rsp+0x18],0x0
     3e8:	mov    QWORD PTR [rsp],rsi
     3ec:	mov    r15,rsi
     3ef:	mov    QWORD PTR [rsp+0x8],rdx
     3f4:	mov    r14,rdx
     3f7:	mov    QWORD PTR [rsp+0x10],rcx
     3fc:	lea    r13,[rsp+0x20]
     401:	mov    QWORD PTR [rsp+0x38],rcx
     406:	mov    rcx,r13
     409:	mov    rdx,QWORD PTR [rsp+0x38]
     40e:	mov    rsi,r15
     411:	mov    rdi,QWORD PTR [rsp+0x30]
     416:	call   41b <botlish_fn_3+0x65>
			417: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     41b:	mov    rsi,rax
     41e:	mov    QWORD PTR [rsp+0x40],rax
     423:	test   rax,rsi
     426:	je     580 <botlish_fn_3+0x1ca>
     42c:	mov    rbx,QWORD PTR [rsp+0x20]
     431:	mov    r12,QWORD PTR [rsp+0x28]
     436:	mov    rdi,QWORD PTR [rsp+0x30]
     43b:	mov    rcx,QWORD PTR [rdi+0x10]
     43f:	mov    r8,QWORD PTR [rcx+0x8]
     443:	mov    rcx,r12
     446:	mov    rdx,rbx
     449:	mov    rsi,QWORD PTR [rsp+0x40]
     44e:	call   453 <botlish_fn_3+0x9d>
			44f: R_X86_64_PLT32	rt_str_region_eq-0x4
     453:	cmp    rax,0x6
     457:	je     498 <botlish_fn_3+0xe2>
     45d:	mov    rdi,QWORD PTR [rsp+0x30]
     462:	mov    rax,QWORD PTR [rdi+0x10]
     466:	mov    r8,QWORD PTR [rax+0x10]
     46a:	mov    rcx,r12
     46d:	mov    rdx,rbx
     470:	mov    rsi,QWORD PTR [rsp+0x40]
     475:	call   47a <botlish_fn_3+0xc4>
			476: R_X86_64_PLT32	rt_str_region_eq-0x4
     47a:	cmp    rax,0x6
     47e:	je     48e <botlish_fn_3+0xd8>
     484:	mov    eax,0x2
     489:	jmp    49d <botlish_fn_3+0xe7>
     48e:	mov    eax,0x6
     493:	jmp    49d <botlish_fn_3+0xe7>
     498:	mov    eax,0x6
     49d:	cmp    rax,0x6
     4a1:	je     4e2 <botlish_fn_3+0x12c>
     4a7:	mov    rdi,QWORD PTR [rsp+0x30]
     4ac:	mov    rax,QWORD PTR [rdi+0x10]
     4b0:	mov    r8,QWORD PTR [rax+0x18]
     4b4:	mov    rcx,r12
     4b7:	mov    rdx,rbx
     4ba:	mov    rsi,QWORD PTR [rsp+0x40]
     4bf:	call   4c4 <botlish_fn_3+0x10e>
			4c0: R_X86_64_PLT32	rt_str_region_eq-0x4
     4c4:	cmp    rax,0x6
     4c8:	je     4d8 <botlish_fn_3+0x122>
     4ce:	mov    eax,0x2
     4d3:	jmp    4e7 <botlish_fn_3+0x131>
     4d8:	mov    eax,0x6
     4dd:	jmp    4e7 <botlish_fn_3+0x131>
     4e2:	mov    eax,0x6
     4e7:	cmp    rax,0x6
     4eb:	je     562 <botlish_fn_3+0x1ac>
     4f1:	mov    QWORD PTR [rsp+0x18],0x3
     4fa:	mov    rsi,QWORD PTR [rsp+0x38]
     4ff:	test   rsi,0x1
     506:	je     52d <botlish_fn_3+0x177>
     50c:	mov    rsi,QWORD PTR [rsp+0x38]
     511:	mov    rax,rsi
     514:	add    rax,0x2
     518:	seto   sil
     51c:	test   sil,sil
     51f:	jne    52d <botlish_fn_3+0x177>
     525:	mov    rsi,r15
     528:	jmp    544 <botlish_fn_3+0x18e>
     52d:	mov    edx,0x3
     532:	mov    rsi,QWORD PTR [rsp+0x38]
     537:	mov    rdi,QWORD PTR [rsp+0x30]
     53c:	call   541 <botlish_fn_3+0x18b>
			53d: R_X86_64_PLT32	rt_int_add-0x4
     541:	mov    rsi,r15
     544:	mov    QWORD PTR [rsp],rsi
     548:	mov    rdx,r14
     54b:	mov    QWORD PTR [rsp+0x8],rdx
     550:	mov    QWORD PTR [rsp+0x10],rax
     555:	mov    r15,rsi
     558:	mov    QWORD PTR [rsp+0x38],rax
     55d:	jmp    406 <botlish_fn_3+0x50>
     562:	mov    rdx,r14
     565:	mov    rsi,r15
     568:	mov    rdi,QWORD PTR [rsp+0x30]
     56d:	mov    rcx,QWORD PTR [rsp+0x38]
     572:	call   577 <botlish_fn_3+0x1c1>
			573: R_X86_64_PLT32	rt_substr-0x4
     577:	test   rax,rax
     57a:	jne    5ab <botlish_fn_3+0x1f5>
     580:	xor    rdx,rdx
     583:	mov    rax,rdx
     586:	mov    rbx,QWORD PTR [rsp+0x50]
     58b:	mov    r12,QWORD PTR [rsp+0x58]
     590:	mov    r13,QWORD PTR [rsp+0x60]
     595:	mov    r14,QWORD PTR [rsp+0x68]
     59a:	mov    r15,QWORD PTR [rsp+0x70]
     59f:	add    rsp,0x80
     5a6:	mov    rsp,rbp
     5a9:	pop    rbp
     5aa:	ret
     5ab:	mov    rdx,QWORD PTR [rsp+0x38]
     5b0:	mov    rbx,QWORD PTR [rsp+0x50]
     5b5:	mov    r12,QWORD PTR [rsp+0x58]
     5ba:	mov    r13,QWORD PTR [rsp+0x60]
     5bf:	mov    r14,QWORD PTR [rsp+0x68]
     5c4:	mov    r15,QWORD PTR [rsp+0x70]
     5c9:	add    rsp,0x80
     5d0:	mov    rsp,rbp
     5d3:	pop    rbp
     5d4:	ret

00000000000005d5 <botlish_entry_3: scan_unquoted<str, int, int>>:
     5d5:	push   rbp
     5d6:	mov    rbp,rsp
     5d9:	ud2

00000000000005db <botlish_fn_4: scan_quoted<str, int, str>>:
     5db:	push   rbp
     5dc:	mov    rbp,rsp
     5df:	sub    rsp,0xc0
     5e6:	mov    QWORD PTR [rsp+0x90],rbx
     5ee:	mov    QWORD PTR [rsp+0x98],r12
     5f6:	mov    QWORD PTR [rsp+0xa0],r13
     5fe:	mov    QWORD PTR [rsp+0xa8],r14
     606:	mov    QWORD PTR [rsp+0xb0],r15
     60e:	mov    r15,rdi
     611:	mov    QWORD PTR [rsp+0x18],0x0
     61a:	mov    QWORD PTR [rsp],rsi
     61e:	mov    QWORD PTR [rsp+0x8],rdx
     623:	mov    QWORD PTR [rsp+0x10],rcx
     628:	mov    r13,rcx
     62b:	lea    r14,[rsp+0x60]
     630:	lea    rbx,[rsp+0x20]
     635:	mov    r12,rsi
     638:	mov    QWORD PTR [rsp+0x80],rdx
     640:	mov    rdx,QWORD PTR [rsp+0x80]
     648:	mov    rsi,r12
     64b:	mov    rdi,r15
     64e:	call   653 <botlish_fn_4+0x78>
			64f: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     653:	test   rdx,rdx
     656:	je     973 <botlish_fn_4+0x398>
     65c:	cmp    rax,0x22
     660:	mov    QWORD PTR [rsp+0x88],rax
     668:	je     76c <botlish_fn_4+0x191>
     66e:	mov    QWORD PTR [rsp+0x18],0x3
     677:	mov    rsi,QWORD PTR [rsp+0x80]
     67f:	test   rsi,0x1
     686:	je     6a8 <botlish_fn_4+0xcd>
     68c:	mov    rdi,rsi
     68f:	add    rdi,0x2
     693:	seto   r8b
     697:	test   r8b,r8b
     69a:	jne    6a8 <botlish_fn_4+0xcd>
     6a0:	mov    rsi,rdi
     6a3:	jmp    6b8 <botlish_fn_4+0xdd>
     6a8:	mov    edx,0x3
     6ad:	mov    rdi,r15
     6b0:	call   6b5 <botlish_fn_4+0xda>
			6b1: R_X86_64_PLT32	rt_int_add-0x4
     6b5:	mov    rsi,rax
     6b8:	mov    QWORD PTR [rsp+0x8],rsi
     6bd:	mov    rax,QWORD PTR [rsp+0x88]
     6c5:	mov    QWORD PTR [rsp+0x80],rsi
     6cd:	lea    rcx,[rax+0x1]
     6d1:	cmp    rcx,0x101
     6d8:	jb     6eb <botlish_fn_4+0x110>
     6de:	mov    rsi,QWORD PTR [rsp+0x88]
     6e6:	jmp    707 <botlish_fn_4+0x12c>
     6eb:	mov    rdi,r15
     6ee:	mov    rax,QWORD PTR [rdi+rcx*8+0x648]
     6f6:	test   rax,rax
     6f9:	jne    70f <botlish_fn_4+0x134>
     6ff:	mov    rsi,QWORD PTR [rsp+0x88]
     707:	mov    rdi,r15
     70a:	call   70f <botlish_fn_4+0x134>
			70b: R_X86_64_PLT32	rt_short_to_str-0x4
     70f:	mov    QWORD PTR [rsp+0x18],rax
     714:	mov    QWORD PTR [rsp+0x60],0x0
     71d:	mov    QWORD PTR [rsp+0x68],r13
     722:	mov    QWORD PTR [rsp+0x70],0x0
     72b:	mov    QWORD PTR [rsp+0x78],rax
     730:	mov    esi,0x2
     735:	mov    edx,0x4
     73a:	mov    rcx,r14
     73d:	mov    rdi,r15
     740:	call   745 <botlish_fn_4+0x16a>
			741: R_X86_64_PLT32	rt_construct-0x4
     745:	test   rax,rax
     748:	je     973 <botlish_fn_4+0x398>
     74e:	mov    QWORD PTR [rsp],r12
     752:	mov    rsi,QWORD PTR [rsp+0x80]
     75a:	mov    QWORD PTR [rsp+0x8],rsi
     75f:	mov    QWORD PTR [rsp+0x10],rax
     764:	mov    r13,rax
     767:	jmp    640 <botlish_fn_4+0x65>
     76c:	mov    QWORD PTR [rsp+0x18],0x3
     775:	mov    rsi,QWORD PTR [rsp+0x80]
     77d:	test   rsi,0x1
     784:	je     7a4 <botlish_fn_4+0x1c9>
     78a:	mov    rsi,QWORD PTR [rsp+0x80]
     792:	mov    rdx,rsi
     795:	add    rdx,0x2
     799:	seto   al
     79c:	test   al,al
     79e:	je     7bc <botlish_fn_4+0x1e1>
     7a4:	mov    edx,0x3
     7a9:	mov    rsi,QWORD PTR [rsp+0x80]
     7b1:	mov    rdi,r15
     7b4:	call   7b9 <botlish_fn_4+0x1de>
			7b5: R_X86_64_PLT32	rt_int_add-0x4
     7b9:	mov    rdx,rax
     7bc:	mov    QWORD PTR [rsp+0x18],rdx
     7c1:	mov    rcx,rbx
     7c4:	mov    rsi,r12
     7c7:	mov    rdi,r15
     7ca:	call   7cf <botlish_fn_4+0x1f4>
			7cb: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     7cf:	test   rax,rax
     7d2:	mov    rsi,rax
     7d5:	je     973 <botlish_fn_4+0x398>
     7db:	mov    rdx,QWORD PTR [rsp+0x20]
     7e0:	mov    rcx,QWORD PTR [rsp+0x28]
     7e5:	mov    rdi,r15
     7e8:	mov    rax,QWORD PTR [rdi+0x10]
     7ec:	mov    r8,QWORD PTR [rax+0x20]
     7f0:	call   7f5 <botlish_fn_4+0x21a>
			7f1: R_X86_64_PLT32	rt_str_region_eq-0x4
     7f5:	cmp    rax,0x6
     7f9:	je     8c1 <botlish_fn_4+0x2e6>
     7ff:	xor    rsi,rsi
     802:	lea    rcx,[rsp+0x50]
     807:	mov    QWORD PTR [rsp+0x50],0x0
     810:	mov    QWORD PTR [rsp+0x58],r13
     815:	mov    edx,0x2
     81a:	mov    rdi,r15
     81d:	call   822 <botlish_fn_4+0x247>
			81e: R_X86_64_PLT32	rt_construct-0x4
     822:	test   rax,rax
     825:	je     973 <botlish_fn_4+0x398>
     82b:	mov    QWORD PTR [rsp],rax
     82f:	mov    rbx,rax
     832:	mov    QWORD PTR [rsp+0x10],0x3
     83b:	mov    rsi,QWORD PTR [rsp+0x80]
     843:	test   rsi,0x1
     84a:	je     872 <botlish_fn_4+0x297>
     850:	mov    rsi,QWORD PTR [rsp+0x80]
     858:	mov    rdx,rsi
     85b:	add    rdx,0x2
     85f:	seto   al
     862:	test   al,al
     864:	jne    872 <botlish_fn_4+0x297>
     86a:	mov    rax,rbx
     86d:	jmp    88d <botlish_fn_4+0x2b2>
     872:	mov    edx,0x3
     877:	mov    rsi,QWORD PTR [rsp+0x80]
     87f:	mov    rdi,r15
     882:	call   887 <botlish_fn_4+0x2ac>
			883: R_X86_64_PLT32	rt_int_add-0x4
     887:	mov    rdx,rax
     88a:	mov    rax,rbx
     88d:	mov    rbx,QWORD PTR [rsp+0x90]
     895:	mov    r12,QWORD PTR [rsp+0x98]
     89d:	mov    r13,QWORD PTR [rsp+0xa0]
     8a5:	mov    r14,QWORD PTR [rsp+0xa8]
     8ad:	mov    r15,QWORD PTR [rsp+0xb0]
     8b5:	add    rsp,0xc0
     8bc:	mov    rsp,rbp
     8bf:	pop    rbp
     8c0:	ret
     8c1:	mov    QWORD PTR [rsp+0x18],0x5
     8ca:	mov    rsi,QWORD PTR [rsp+0x80]
     8d2:	test   rsi,0x1
     8d9:	je     905 <botlish_fn_4+0x32a>
     8df:	mov    rsi,QWORD PTR [rsp+0x80]
     8e7:	add    rsi,0x4
     8eb:	seto   dil
     8ef:	test   dil,dil
     8f2:	jne    905 <botlish_fn_4+0x32a>
     8f8:	mov    QWORD PTR [rsp+0x80],rsi
     900:	jmp    925 <botlish_fn_4+0x34a>
     905:	mov    edx,0x5
     90a:	mov    rsi,QWORD PTR [rsp+0x80]
     912:	mov    rdi,r15
     915:	call   91a <botlish_fn_4+0x33f>
			916: R_X86_64_PLT32	rt_int_add-0x4
     91a:	mov    rsi,rax
     91d:	mov    QWORD PTR [rsp+0x80],rax
     925:	mov    QWORD PTR [rsp+0x8],rsi
     92a:	mov    rdi,r15
     92d:	mov    rax,QWORD PTR [rdi+0x10]
     931:	mov    rax,QWORD PTR [rax+0x20]
     935:	mov    QWORD PTR [rsp+0x18],rax
     93a:	lea    rcx,[rsp+0x30]
     93f:	mov    QWORD PTR [rsp+0x30],0x0
     948:	mov    QWORD PTR [rsp+0x38],r13
     94d:	mov    QWORD PTR [rsp+0x40],0x0
     956:	mov    QWORD PTR [rsp+0x48],rax
     95b:	mov    esi,0x2
     960:	mov    edx,0x4
     965:	call   96a <botlish_fn_4+0x38f>
			966: R_X86_64_PLT32	rt_construct-0x4
     96a:	test   rax,rax
     96d:	jne    9ad <botlish_fn_4+0x3d2>
     973:	xor    rdx,rdx
     976:	mov    rax,rdx
     979:	mov    rbx,QWORD PTR [rsp+0x90]
     981:	mov    r12,QWORD PTR [rsp+0x98]
     989:	mov    r13,QWORD PTR [rsp+0xa0]
     991:	mov    r14,QWORD PTR [rsp+0xa8]
     999:	mov    r15,QWORD PTR [rsp+0xb0]
     9a1:	add    rsp,0xc0
     9a8:	mov    rsp,rbp
     9ab:	pop    rbp
     9ac:	ret
     9ad:	mov    QWORD PTR [rsp],r12
     9b1:	mov    rsi,QWORD PTR [rsp+0x80]
     9b9:	mov    QWORD PTR [rsp+0x8],rsi
     9be:	mov    QWORD PTR [rsp+0x10],rax
     9c3:	mov    r13,rax
     9c6:	jmp    640 <botlish_fn_4+0x65>

00000000000009cb <botlish_entry_4: scan_quoted<str, int, str>>:
     9cb:	push   rbp
     9cc:	mov    rbp,rsp
     9cf:	ud2

00000000000009d1 <botlish_fn_5: scan_field<str, int>>:
     9d1:	push   rbp
     9d2:	mov    rbp,rsp
     9d5:	sub    rsp,0x50
     9d9:	mov    QWORD PTR [rsp+0x30],rbx
     9de:	mov    QWORD PTR [rsp+0x38],r12
     9e3:	mov    QWORD PTR [rsp+0x40],r13
     9e8:	mov    r12,rdi
     9eb:	mov    r13,rdx
     9ee:	mov    QWORD PTR [rsp+0x10],0x0
     9f7:	mov    QWORD PTR [rsp],rsi
     9fb:	mov    rbx,rsi
     9fe:	mov    QWORD PTR [rsp+0x8],rdx
     a03:	lea    rcx,[rsp+0x18]
     a08:	mov    rdx,r13
     a0b:	mov    rsi,rbx
     a0e:	mov    rdi,r12
     a11:	call   a16 <botlish_fn_5+0x45>
			a12: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     a16:	test   rax,rax
     a19:	mov    rsi,rax
     a1c:	je     ae7 <botlish_fn_5+0x116>
     a22:	mov    rdx,QWORD PTR [rsp+0x18]
     a27:	mov    rcx,QWORD PTR [rsp+0x20]
     a2c:	mov    rdi,r12
     a2f:	mov    rax,QWORD PTR [rdi+0x10]
     a33:	mov    r8,QWORD PTR [rax+0x20]
     a37:	call   a3c <botlish_fn_5+0x6b>
			a38: R_X86_64_PLT32	rt_str_region_eq-0x4
     a3c:	cmp    rax,0x6
     a40:	je     a78 <botlish_fn_5+0xa7>
     a46:	mov    rcx,r13
     a49:	mov    rsi,rbx
     a4c:	mov    rdi,r12
     a4f:	mov    rdx,rcx
     a52:	call   a57 <botlish_fn_5+0x86>
			a53: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     a57:	test   rax,rax
     a5a:	je     ae7 <botlish_fn_5+0x116>
     a60:	mov    rbx,QWORD PTR [rsp+0x30]
     a65:	mov    r12,QWORD PTR [rsp+0x38]
     a6a:	mov    r13,QWORD PTR [rsp+0x40]
     a6f:	add    rsp,0x50
     a73:	mov    rsp,rbp
     a76:	pop    rbp
     a77:	ret
     a78:	mov    rcx,r13
     a7b:	mov    QWORD PTR [rsp+0x10],0x3
     a84:	test   rcx,0x1
     a8b:	jne    a99 <botlish_fn_5+0xc8>
     a91:	mov    r13,rcx
     a94:	jmp    aae <botlish_fn_5+0xdd>
     a99:	mov    rdx,rcx
     a9c:	add    rdx,0x2
     aa0:	mov    r13,rcx
     aa3:	seto   al
     aa6:	test   al,al
     aa8:	je     ac1 <botlish_fn_5+0xf0>
     aae:	mov    edx,0x3
     ab3:	mov    rsi,r13
     ab6:	mov    rdi,r12
     ab9:	call   abe <botlish_fn_5+0xed>
			aba: R_X86_64_PLT32	rt_int_add-0x4
     abe:	mov    rdx,rax
     ac1:	mov    QWORD PTR [rsp+0x8],rdx
     ac6:	mov    rdi,r12
     ac9:	mov    rax,QWORD PTR [rdi+0x10]
     acd:	mov    rcx,QWORD PTR [rax+0x8]
     ad1:	mov    QWORD PTR [rsp+0x10],rcx
     ad6:	mov    rsi,rbx
     ad9:	call   ade <botlish_fn_5+0x10d>
			ada: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     ade:	test   rax,rax
     ae1:	jne    b05 <botlish_fn_5+0x134>
     ae7:	xor    rdx,rdx
     aea:	mov    rax,rdx
     aed:	mov    rbx,QWORD PTR [rsp+0x30]
     af2:	mov    r12,QWORD PTR [rsp+0x38]
     af7:	mov    r13,QWORD PTR [rsp+0x40]
     afc:	add    rsp,0x50
     b00:	mov    rsp,rbp
     b03:	pop    rbp
     b04:	ret
     b05:	mov    rbx,QWORD PTR [rsp+0x30]
     b0a:	mov    r12,QWORD PTR [rsp+0x38]
     b0f:	mov    r13,QWORD PTR [rsp+0x40]
     b14:	add    rsp,0x50
     b18:	mov    rsp,rbp
     b1b:	pop    rbp
     b1c:	ret

0000000000000b1d <botlish_entry_5: scan_field<str, int>>:
     b1d:	push   rbp
     b1e:	mov    rbp,rsp
     b21:	ud2

0000000000000b23 <botlish_fn_6: scan_record<str, int, List[never]>>:
     b23:	push   rbp
     b24:	mov    rbp,rsp
     b27:	sub    rsp,0xa0
     b2e:	mov    QWORD PTR [rsp+0x70],rbx
     b33:	mov    QWORD PTR [rsp+0x78],r12
     b38:	mov    QWORD PTR [rsp+0x80],r13
     b40:	mov    QWORD PTR [rsp+0x88],r14
     b48:	mov    QWORD PTR [rsp+0x90],r15
     b50:	mov    r13,rdi
     b53:	mov    QWORD PTR [rsp+0x18],0x0
     b5c:	mov    QWORD PTR [rsp+0x20],0x0
     b65:	mov    QWORD PTR [rsp],rsi
     b69:	mov    r15,rsi
     b6c:	mov    QWORD PTR [rsp+0x8],rdx
     b71:	mov    QWORD PTR [rsp+0x10],rcx
     b76:	mov    QWORD PTR [rsp+0x58],rcx
     b7b:	mov    rsi,r15
     b7e:	mov    rdi,r13
     b81:	call   b86 <botlish_fn_6+0x63>
			b82: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     b86:	test   rax,rax
     b89:	je     da4 <botlish_fn_6+0x281>
     b8f:	mov    QWORD PTR [rsp+0x8],rax
     b94:	mov    QWORD PTR [rsp+0x68],rax
     b99:	mov    QWORD PTR [rsp+0x18],rdx
     b9e:	mov    r14,rdx
     ba1:	lea    rcx,[rsp+0x28]
     ba6:	mov    rsi,r15
     ba9:	mov    rdi,r13
     bac:	call   bb1 <botlish_fn_6+0x8e>
			bad: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     bb1:	test   rax,rax
     bb4:	mov    QWORD PTR [rsp+0x60],rax
     bb9:	je     da4 <botlish_fn_6+0x281>
     bbf:	mov    r12,QWORD PTR [rsp+0x28]
     bc4:	mov    rbx,QWORD PTR [rsp+0x30]
     bc9:	mov    rdi,r13
     bcc:	mov    rcx,QWORD PTR [rdi+0x10]
     bd0:	mov    r8,QWORD PTR [rcx+0x10]
     bd4:	mov    rcx,rbx
     bd7:	mov    rdx,r12
     bda:	mov    rsi,QWORD PTR [rsp+0x60]
     bdf:	call   be4 <botlish_fn_6+0xc1>
			be0: R_X86_64_PLT32	rt_str_region_eq-0x4
     be4:	cmp    rax,0x6
     be8:	je     cfa <botlish_fn_6+0x1d7>
     bee:	mov    rdi,r13
     bf1:	mov    rax,QWORD PTR [rdi+0x10]
     bf5:	mov    r8,QWORD PTR [rax+0x18]
     bf9:	mov    rcx,rbx
     bfc:	mov    rdx,r12
     bff:	mov    rsi,QWORD PTR [rsp+0x60]
     c04:	call   c09 <botlish_fn_6+0xe6>
			c05: R_X86_64_PLT32	rt_str_region_eq-0x4
     c09:	cmp    rax,0x6
     c0d:	je     c5f <botlish_fn_6+0x13c>
     c13:	mov    rdx,QWORD PTR [rsp+0x68]
     c18:	mov    rsi,QWORD PTR [rsp+0x58]
     c1d:	mov    rdi,r13
     c20:	call   c25 <botlish_fn_6+0x102>
			c21: R_X86_64_PLT32	rt_list_append-0x4
     c25:	test   rax,rax
     c28:	je     da4 <botlish_fn_6+0x281>
     c2e:	mov    rdx,r14
     c31:	mov    rbx,QWORD PTR [rsp+0x70]
     c36:	mov    r12,QWORD PTR [rsp+0x78]
     c3b:	mov    r13,QWORD PTR [rsp+0x80]
     c43:	mov    r14,QWORD PTR [rsp+0x88]
     c4b:	mov    r15,QWORD PTR [rsp+0x90]
     c53:	add    rsp,0xa0
     c5a:	mov    rsp,rbp
     c5d:	pop    rbp
     c5e:	ret
     c5f:	mov    rdx,QWORD PTR [rsp+0x68]
     c64:	mov    rsi,QWORD PTR [rsp+0x58]
     c69:	mov    rdi,r13
     c6c:	call   c71 <botlish_fn_6+0x14e>
			c6d: R_X86_64_PLT32	rt_list_append-0x4
     c71:	test   rax,rax
     c74:	je     da4 <botlish_fn_6+0x281>
     c7a:	mov    QWORD PTR [rsp],rax
     c7e:	mov    r12,rax
     c81:	mov    QWORD PTR [rsp+0x8],0x3
     c8a:	mov    rdx,r14
     c8d:	test   rdx,0x1
     c94:	je     cb6 <botlish_fn_6+0x193>
     c9a:	mov    rdx,r14
     c9d:	add    rdx,0x2
     ca1:	seto   sil
     ca5:	test   sil,sil
     ca8:	jne    cb6 <botlish_fn_6+0x193>
     cae:	mov    rax,r12
     cb1:	jmp    ccc <botlish_fn_6+0x1a9>
     cb6:	mov    edx,0x3
     cbb:	mov    rsi,r14
     cbe:	mov    rdi,r13
     cc1:	call   cc6 <botlish_fn_6+0x1a3>
			cc2: R_X86_64_PLT32	rt_int_add-0x4
     cc6:	mov    rdx,rax
     cc9:	mov    rax,r12
     ccc:	mov    rbx,QWORD PTR [rsp+0x70]
     cd1:	mov    r12,QWORD PTR [rsp+0x78]
     cd6:	mov    r13,QWORD PTR [rsp+0x80]
     cde:	mov    r14,QWORD PTR [rsp+0x88]
     ce6:	mov    r15,QWORD PTR [rsp+0x90]
     cee:	add    rsp,0xa0
     cf5:	mov    rsp,rbp
     cf8:	pop    rbp
     cf9:	ret
     cfa:	mov    rsi,r14
     cfd:	mov    r12d,0x3
     d03:	mov    QWORD PTR [rsp+0x20],0x3
     d0c:	test   rsi,0x1
     d13:	je     d2b <botlish_fn_6+0x208>
     d19:	mov    rdx,rsi
     d1c:	add    rdx,0x2
     d20:	seto   al
     d23:	test   al,al
     d25:	je     d39 <botlish_fn_6+0x216>
     d2b:	mov    rdx,r12
     d2e:	mov    rdi,r13
     d31:	call   d36 <botlish_fn_6+0x213>
			d32: R_X86_64_PLT32	rt_int_add-0x4
     d36:	mov    rdx,rax
     d39:	mov    QWORD PTR [rsp+0x18],rdx
     d3e:	mov    rbx,rdx
     d41:	lea    rcx,[rsp+0x38]
     d46:	mov    QWORD PTR [rsp+0x38],0x0
     d4f:	mov    rsi,QWORD PTR [rsp+0x58]
     d54:	mov    QWORD PTR [rsp+0x40],rsi
     d59:	mov    QWORD PTR [rsp+0x48],0x2
     d62:	mov    rdx,QWORD PTR [rsp+0x68]
     d67:	mov    QWORD PTR [rsp+0x50],rdx
     d6c:	mov    edx,0x4
     d71:	mov    rsi,r12
     d74:	mov    rdi,r13
     d77:	call   d7c <botlish_fn_6+0x259>
			d78: R_X86_64_PLT32	rt_construct-0x4
     d7c:	test   rax,rax
     d7f:	je     da4 <botlish_fn_6+0x281>
     d85:	mov    QWORD PTR [rsp+0x8],rax
     d8a:	mov    rcx,rax
     d8d:	mov    rdx,rbx
     d90:	mov    rsi,r15
     d93:	mov    rdi,r13
     d96:	call   d9b <botlish_fn_6+0x278>
			d97: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, List[str]>
     d9b:	test   rax,rax
     d9e:	jne    dd8 <botlish_fn_6+0x2b5>
     da4:	xor    rdx,rdx
     da7:	mov    rax,rdx
     daa:	mov    rbx,QWORD PTR [rsp+0x70]
     daf:	mov    r12,QWORD PTR [rsp+0x78]
     db4:	mov    r13,QWORD PTR [rsp+0x80]
     dbc:	mov    r14,QWORD PTR [rsp+0x88]
     dc4:	mov    r15,QWORD PTR [rsp+0x90]
     dcc:	add    rsp,0xa0
     dd3:	mov    rsp,rbp
     dd6:	pop    rbp
     dd7:	ret
     dd8:	mov    rbx,QWORD PTR [rsp+0x70]
     ddd:	mov    r12,QWORD PTR [rsp+0x78]
     de2:	mov    r13,QWORD PTR [rsp+0x80]
     dea:	mov    r14,QWORD PTR [rsp+0x88]
     df2:	mov    r15,QWORD PTR [rsp+0x90]
     dfa:	add    rsp,0xa0
     e01:	mov    rsp,rbp
     e04:	pop    rbp
     e05:	ret

0000000000000e06 <botlish_entry_6: scan_record<str, int, List[never]>>:
     e06:	push   rbp
     e07:	mov    rbp,rsp
     e0a:	ud2

0000000000000e0c <botlish_fn_7: scan_record<str, int, List[str]>>:
     e0c:	push   rbp
     e0d:	mov    rbp,rsp
     e10:	sub    rsp,0xf0
     e17:	mov    QWORD PTR [rsp+0xc0],rbx
     e1f:	mov    QWORD PTR [rsp+0xc8],r12
     e27:	mov    QWORD PTR [rsp+0xd0],r13
     e2f:	mov    QWORD PTR [rsp+0xd8],r14
     e37:	mov    QWORD PTR [rsp+0xe0],r15
     e3f:	mov    QWORD PTR [rsp+0x98],rdi
     e47:	mov    QWORD PTR [rsp+0x18],0x0
     e50:	mov    QWORD PTR [rsp+0x20],0x0
     e59:	mov    QWORD PTR [rsp],rsi
     e5d:	mov    QWORD PTR [rsp+0x8],rdx
     e62:	mov    QWORD PTR [rsp+0xa0],rdx
     e6a:	mov    QWORD PTR [rsp+0x10],rcx
     e6f:	mov    r15,rcx
     e72:	lea    rbx,[rsp+0x28]
     e77:	mov    r12,rsi
     e7a:	mov    rsi,r12
     e7d:	mov    rdi,QWORD PTR [rsp+0x98]
     e85:	call   e8a <botlish_fn_7+0x7e>
			e86: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     e8a:	test   rax,rax
     e8d:	je     114a <botlish_fn_7+0x33e>
     e93:	mov    QWORD PTR [rsp+0x8],rax
     e98:	mov    QWORD PTR [rsp+0xb0],rax
     ea0:	mov    QWORD PTR [rsp+0x18],rdx
     ea5:	mov    QWORD PTR [rsp+0xb8],rdx
     ead:	mov    rcx,rbx
     eb0:	mov    rsi,r12
     eb3:	mov    rdi,QWORD PTR [rsp+0x98]
     ebb:	call   ec0 <botlish_fn_7+0xb4>
			ebc: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     ec0:	test   rax,rax
     ec3:	mov    QWORD PTR [rsp+0xa8],rax
     ecb:	je     114a <botlish_fn_7+0x33e>
     ed1:	mov    r13,QWORD PTR [rsp+0x28]
     ed6:	mov    r14,QWORD PTR [rsp+0x30]
     edb:	mov    rdi,QWORD PTR [rsp+0x98]
     ee3:	mov    rcx,QWORD PTR [rdi+0x10]
     ee7:	mov    r8,QWORD PTR [rcx+0x10]
     eeb:	mov    rcx,r14
     eee:	mov    rdx,r13
     ef1:	mov    rsi,QWORD PTR [rsp+0xa8]
     ef9:	call   efe <botlish_fn_7+0xf2>
			efa: R_X86_64_PLT32	rt_str_region_eq-0x4
     efe:	cmp    rax,0x6
     f02:	je     10aa <botlish_fn_7+0x29e>
     f08:	mov    rdi,QWORD PTR [rsp+0x98]
     f10:	mov    rax,QWORD PTR [rdi+0x10]
     f14:	mov    r8,QWORD PTR [rax+0x18]
     f18:	mov    rcx,r14
     f1b:	mov    rdx,r13
     f1e:	mov    rsi,QWORD PTR [rsp+0xa8]
     f26:	call   f2b <botlish_fn_7+0x11f>
			f27: R_X86_64_PLT32	rt_str_region_eq-0x4
     f2b:	cmp    rax,0x6
     f2f:	je     fc6 <botlish_fn_7+0x1ba>
     f35:	lea    rcx,[rsp+0x78]
     f3a:	mov    QWORD PTR [rsp+0x78],0x0
     f43:	mov    r14,r15
     f46:	mov    QWORD PTR [rsp+0x80],r14
     f4e:	mov    QWORD PTR [rsp+0x88],0x2
     f5a:	mov    r15,QWORD PTR [rsp+0xb0]
     f62:	mov    QWORD PTR [rsp+0x90],r15
     f6a:	mov    esi,0x1
     f6f:	mov    edx,0x4
     f74:	mov    rdi,QWORD PTR [rsp+0x98]
     f7c:	call   f81 <botlish_fn_7+0x175>
			f7d: R_X86_64_PLT32	rt_construct-0x4
     f81:	test   rax,rax
     f84:	je     114a <botlish_fn_7+0x33e>
     f8a:	mov    rdx,QWORD PTR [rsp+0xb8]
     f92:	mov    rbx,QWORD PTR [rsp+0xc0]
     f9a:	mov    r12,QWORD PTR [rsp+0xc8]
     fa2:	mov    r13,QWORD PTR [rsp+0xd0]
     faa:	mov    r14,QWORD PTR [rsp+0xd8]
     fb2:	mov    r15,QWORD PTR [rsp+0xe0]
     fba:	add    rsp,0xf0
     fc1:	mov    rsp,rbp
     fc4:	pop    rbp
     fc5:	ret
     fc6:	mov    r14,r15
     fc9:	mov    r15,QWORD PTR [rsp+0xb0]
     fd1:	lea    rcx,[rsp+0x58]
     fd6:	mov    QWORD PTR [rsp+0x58],0x0
     fdf:	mov    QWORD PTR [rsp+0x60],r14
     fe4:	mov    QWORD PTR [rsp+0x68],0x2
     fed:	mov    QWORD PTR [rsp+0x70],r15
     ff2:	mov    esi,0x1
     ff7:	mov    edx,0x4
     ffc:	mov    rdi,QWORD PTR [rsp+0x98]
    1004:	call   1009 <botlish_fn_7+0x1fd>
			1005: R_X86_64_PLT32	rt_construct-0x4
    1009:	test   rax,rax
    100c:	je     114a <botlish_fn_7+0x33e>
    1012:	mov    QWORD PTR [rsp],rax
    1016:	mov    r12,rax
    1019:	mov    QWORD PTR [rsp+0x8],0x3
    1022:	mov    rdx,QWORD PTR [rsp+0xb8]
    102a:	test   rdx,0x1
    1031:	je     1056 <botlish_fn_7+0x24a>
    1037:	mov    rdx,QWORD PTR [rsp+0xb8]
    103f:	add    rdx,0x2
    1043:	seto   al
    1046:	test   al,al
    1048:	jne    1056 <botlish_fn_7+0x24a>
    104e:	mov    rax,r12
    1051:	jmp    1076 <botlish_fn_7+0x26a>
    1056:	mov    edx,0x3
    105b:	mov    rsi,QWORD PTR [rsp+0xb8]
    1063:	mov    rdi,QWORD PTR [rsp+0x98]
    106b:	call   1070 <botlish_fn_7+0x264>
			106c: R_X86_64_PLT32	rt_int_add-0x4
    1070:	mov    rdx,rax
    1073:	mov    rax,r12
    1076:	mov    rbx,QWORD PTR [rsp+0xc0]
    107e:	mov    r12,QWORD PTR [rsp+0xc8]
    1086:	mov    r13,QWORD PTR [rsp+0xd0]
    108e:	mov    r14,QWORD PTR [rsp+0xd8]
    1096:	mov    r15,QWORD PTR [rsp+0xe0]
    109e:	add    rsp,0xf0
    10a5:	mov    rsp,rbp
    10a8:	pop    rbp
    10a9:	ret
    10aa:	mov    r14,r15
    10ad:	mov    r15,QWORD PTR [rsp+0xb0]
    10b5:	mov    rsi,QWORD PTR [rsp+0xb8]
    10bd:	mov    r13d,0x3
    10c3:	mov    QWORD PTR [rsp+0x20],0x3
    10cc:	test   rsi,0x1
    10d3:	je     10eb <botlish_fn_7+0x2df>
    10d9:	mov    rdx,rsi
    10dc:	add    rdx,0x2
    10e0:	seto   al
    10e3:	test   al,al
    10e5:	je     10fe <botlish_fn_7+0x2f2>
    10eb:	mov    rdx,r13
    10ee:	mov    rdi,QWORD PTR [rsp+0x98]
    10f6:	call   10fb <botlish_fn_7+0x2ef>
			10f7: R_X86_64_PLT32	rt_int_add-0x4
    10fb:	mov    rdx,rax
    10fe:	mov    QWORD PTR [rsp+0x18],rdx
    1103:	mov    QWORD PTR [rsp+0xa0],rdx
    110b:	lea    rcx,[rsp+0x38]
    1110:	mov    QWORD PTR [rsp+0x38],0x0
    1119:	mov    QWORD PTR [rsp+0x40],r14
    111e:	mov    QWORD PTR [rsp+0x48],0x2
    1127:	mov    QWORD PTR [rsp+0x50],r15
    112c:	mov    edx,0x4
    1131:	mov    rsi,r13
    1134:	mov    rdi,QWORD PTR [rsp+0x98]
    113c:	call   1141 <botlish_fn_7+0x335>
			113d: R_X86_64_PLT32	rt_construct-0x4
    1141:	test   rax,rax
    1144:	jne    1184 <botlish_fn_7+0x378>
    114a:	xor    rdx,rdx
    114d:	mov    rax,rdx
    1150:	mov    rbx,QWORD PTR [rsp+0xc0]
    1158:	mov    r12,QWORD PTR [rsp+0xc8]
    1160:	mov    r13,QWORD PTR [rsp+0xd0]
    1168:	mov    r14,QWORD PTR [rsp+0xd8]
    1170:	mov    r15,QWORD PTR [rsp+0xe0]
    1178:	add    rsp,0xf0
    117f:	mov    rsp,rbp
    1182:	pop    rbp
    1183:	ret
    1184:	mov    QWORD PTR [rsp],r12
    1188:	mov    rdx,QWORD PTR [rsp+0xa0]
    1190:	mov    QWORD PTR [rsp+0x8],rdx
    1195:	mov    QWORD PTR [rsp+0x10],rax
    119a:	mov    r15,rax
    119d:	jmp    e7a <botlish_fn_7+0x6e>

00000000000011a2 <botlish_entry_7: scan_record<str, int, List[str]>>:
    11a2:	push   rbp
    11a3:	mov    rbp,rsp
    11a6:	ud2

00000000000011a8 <botlish_fn_8: scan_records<str, int, List[never]>>:
    11a8:	push   rbp
    11a9:	mov    rbp,rsp
    11ac:	sub    rsp,0x60
    11b0:	mov    QWORD PTR [rsp+0x40],rbx
    11b5:	mov    QWORD PTR [rsp+0x48],r12
    11ba:	mov    QWORD PTR [rsp+0x50],r13
    11bf:	mov    QWORD PTR [rsp+0x58],r14
    11c4:	mov    r12,rdi
    11c7:	mov    QWORD PTR [rsp+0x18],0x0
    11d0:	mov    QWORD PTR [rsp],rsi
    11d4:	mov    rbx,rsi
    11d7:	mov    QWORD PTR [rsp+0x8],rdx
    11dc:	mov    r14,rdx
    11df:	mov    QWORD PTR [rsp+0x10],rcx
    11e4:	mov    r13,rcx
    11e7:	mov    rsi,rbx
    11ea:	mov    rdi,r12
    11ed:	call   11f2 <botlish_fn_8+0x4a>
			11ee: R_X86_64_PLT32	rt_str_len-0x4
    11f2:	mov    rdx,r14
    11f5:	mov    rcx,rdx
    11f8:	sar    rcx,1
    11fb:	sar    rax,1
    11fe:	cmp    rcx,rax
    1201:	jge    12e5 <botlish_fn_8+0x13d>
    1207:	xor    rdx,rdx
    120a:	mov    rdi,r12
    120d:	mov    rsi,rdx
    1210:	call   1215 <botlish_fn_8+0x6d>
			1211: R_X86_64_PLT32	rt_list_new-0x4
    1215:	test   rax,rax
    1218:	je     12a8 <botlish_fn_8+0x100>
    121e:	mov    QWORD PTR [rsp+0x18],rax
    1223:	mov    rcx,rax
    1226:	mov    rdx,r14
    1229:	mov    rsi,rbx
    122c:	mov    rdi,r12
    122f:	call   1234 <botlish_fn_8+0x8c>
			1230: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    1234:	test   rax,rax
    1237:	je     12a8 <botlish_fn_8+0x100>
    123d:	mov    QWORD PTR [rsp+0x8],rax
    1242:	mov    QWORD PTR [rsp+0x18],rdx
    1247:	mov    r14,rdx
    124a:	lea    rcx,[rsp+0x20]
    124f:	mov    QWORD PTR [rsp+0x20],0x0
    1258:	mov    rdx,r13
    125b:	mov    QWORD PTR [rsp+0x28],rdx
    1260:	mov    QWORD PTR [rsp+0x30],0x2
    1269:	mov    QWORD PTR [rsp+0x38],rax
    126e:	mov    esi,0x3
    1273:	mov    edx,0x4
    1278:	mov    rdi,r12
    127b:	call   1280 <botlish_fn_8+0xd8>
			127c: R_X86_64_PLT32	rt_construct-0x4
    1280:	test   rax,rax
    1283:	je     12a8 <botlish_fn_8+0x100>
    1289:	mov    QWORD PTR [rsp+0x8],rax
    128e:	mov    rcx,rax
    1291:	mov    rdx,r14
    1294:	mov    rsi,rbx
    1297:	mov    rdi,r12
    129a:	call   129f <botlish_fn_8+0xf7>
			129b: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    129f:	test   rax,rax
    12a2:	jne    12c8 <botlish_fn_8+0x120>
    12a8:	xor    rax,rax
    12ab:	mov    rbx,QWORD PTR [rsp+0x40]
    12b0:	mov    r12,QWORD PTR [rsp+0x48]
    12b5:	mov    r13,QWORD PTR [rsp+0x50]
    12ba:	mov    r14,QWORD PTR [rsp+0x58]
    12bf:	add    rsp,0x60
    12c3:	mov    rsp,rbp
    12c6:	pop    rbp
    12c7:	ret
    12c8:	mov    rbx,QWORD PTR [rsp+0x40]
    12cd:	mov    r12,QWORD PTR [rsp+0x48]
    12d2:	mov    r13,QWORD PTR [rsp+0x50]
    12d7:	mov    r14,QWORD PTR [rsp+0x58]
    12dc:	add    rsp,0x60
    12e0:	mov    rsp,rbp
    12e3:	pop    rbp
    12e4:	ret
    12e5:	mov    rax,r13
    12e8:	mov    rbx,QWORD PTR [rsp+0x40]
    12ed:	mov    r12,QWORD PTR [rsp+0x48]
    12f2:	mov    r13,QWORD PTR [rsp+0x50]
    12f7:	mov    r14,QWORD PTR [rsp+0x58]
    12fc:	add    rsp,0x60
    1300:	mov    rsp,rbp
    1303:	pop    rbp
    1304:	ret

0000000000001305 <botlish_entry_8: scan_records<str, int, List[never]>>:
    1305:	push   rbp
    1306:	mov    rbp,rsp
    1309:	mov    rsi,QWORD PTR [rdx]
    130c:	mov    r8,QWORD PTR [rdx+0x8]
    1310:	mov    rcx,QWORD PTR [rdx+0x10]
    1314:	mov    rdx,r8
    1317:	call   131c <botlish_entry_8+0x17>
			1318: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    131c:	mov    rsp,rbp
    131f:	pop    rbp
    1320:	ret
    1321:	add    BYTE PTR [rax],al
    1323:	add    BYTE PTR [rax],al
    1325:	add    BYTE PTR [rax],al
	...

0000000000001328 <botlish_fn_9: scan_records<str, int, List[List[str]]>>:
    1328:	push   rbp
    1329:	mov    rbp,rsp
    132c:	sub    rsp,0x80
    1333:	mov    QWORD PTR [rsp+0x50],rbx
    1338:	mov    QWORD PTR [rsp+0x58],r12
    133d:	mov    QWORD PTR [rsp+0x60],r13
    1342:	mov    QWORD PTR [rsp+0x68],r14
    1347:	mov    QWORD PTR [rsp+0x70],r15
    134c:	mov    r14,rdi
    134f:	mov    QWORD PTR [rsp+0x18],0x0
    1358:	mov    QWORD PTR [rsp],rsi
    135c:	mov    QWORD PTR [rsp+0x8],rdx
    1361:	mov    r13,rdx
    1364:	mov    QWORD PTR [rsp+0x10],rcx
    1369:	mov    r15,rcx
    136c:	lea    r12,[rsp+0x30]
    1371:	mov    rbx,rsi
    1374:	mov    rsi,rbx
    1377:	mov    rdi,r14
    137a:	call   137f <botlish_fn_9+0x57>
			137b: R_X86_64_PLT32	rt_str_len-0x4
    137f:	mov    rcx,r13
    1382:	and    rcx,rax
    1385:	mov    rdx,rax
    1388:	test   rcx,0x1
    138f:	jne    13b5 <botlish_fn_9+0x8d>
    1395:	mov    rsi,r13
    1398:	mov    rdi,r14
    139b:	call   13a0 <botlish_fn_9+0x78>
			139c: R_X86_64_PLT32	rt_int_cmp-0x4
    13a0:	mov    ecx,0x2
    13a5:	test   rax,rax
    13a8:	cmovge rcx,QWORD PTR [rip+0x140]        # 14f0 <botlish_fn_9+0x1c8>
    13b0:	jmp    13c8 <botlish_fn_9+0xa0>
    13b5:	mov    ecx,0x2
    13ba:	mov    rax,r13
    13bd:	cmp    rax,rdx
    13c0:	cmovge rcx,QWORD PTR [rip+0x128]        # 14f0 <botlish_fn_9+0x1c8>
    13c8:	cmp    rcx,0x6
    13cc:	je     146b <botlish_fn_9+0x143>
    13d2:	xor    rdx,rdx
    13d5:	mov    rdi,r14
    13d8:	mov    rsi,rdx
    13db:	call   13e0 <botlish_fn_9+0xb8>
			13dc: R_X86_64_PLT32	rt_list_new-0x4
    13e0:	test   rax,rax
    13e3:	je     149c <botlish_fn_9+0x174>
    13e9:	mov    QWORD PTR [rsp+0x18],rax
    13ee:	mov    rcx,rax
    13f1:	mov    rdx,r13
    13f4:	mov    rsi,rbx
    13f7:	mov    rdi,r14
    13fa:	call   13ff <botlish_fn_9+0xd7>
			13fb: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    13ff:	test   rax,rax
    1402:	je     149c <botlish_fn_9+0x174>
    1408:	mov    QWORD PTR [rsp+0x8],rax
    140d:	mov    QWORD PTR [rsp+0x18],rdx
    1412:	mov    r13,rdx
    1415:	mov    QWORD PTR [rsp+0x30],0x0
    141e:	mov    r9,r15
    1421:	mov    QWORD PTR [rsp+0x38],r9
    1426:	mov    QWORD PTR [rsp+0x40],0x2
    142f:	mov    QWORD PTR [rsp+0x48],rax
    1434:	mov    esi,0x3
    1439:	mov    edx,0x4
    143e:	mov    rcx,r12
    1441:	mov    rdi,r14
    1444:	call   1449 <botlish_fn_9+0x121>
			1445: R_X86_64_PLT32	rt_construct-0x4
    1449:	test   rax,rax
    144c:	je     149c <botlish_fn_9+0x174>
    1452:	mov    QWORD PTR [rsp],rbx
    1456:	mov    rdx,r13
    1459:	mov    QWORD PTR [rsp+0x8],rdx
    145e:	mov    QWORD PTR [rsp+0x10],rax
    1463:	mov    r15,rax
    1466:	jmp    1374 <botlish_fn_9+0x4c>
    146b:	mov    r9,r15
    146e:	lea    rcx,[rsp+0x20]
    1473:	mov    QWORD PTR [rsp+0x20],0x0
    147c:	mov    QWORD PTR [rsp+0x28],r9
    1481:	mov    esi,0x1
    1486:	mov    edx,0x2
    148b:	mov    rdi,r14
    148e:	call   1493 <botlish_fn_9+0x16b>
			148f: R_X86_64_PLT32	rt_construct-0x4
    1493:	test   rax,rax
    1496:	jne    14c4 <botlish_fn_9+0x19c>
    149c:	xor    rax,rax
    149f:	mov    rbx,QWORD PTR [rsp+0x50]
    14a4:	mov    r12,QWORD PTR [rsp+0x58]
    14a9:	mov    r13,QWORD PTR [rsp+0x60]
    14ae:	mov    r14,QWORD PTR [rsp+0x68]
    14b3:	mov    r15,QWORD PTR [rsp+0x70]
    14b8:	add    rsp,0x80
    14bf:	mov    rsp,rbp
    14c2:	pop    rbp
    14c3:	ret
    14c4:	mov    rbx,QWORD PTR [rsp+0x50]
    14c9:	mov    r12,QWORD PTR [rsp+0x58]
    14ce:	mov    r13,QWORD PTR [rsp+0x60]
    14d3:	mov    r14,QWORD PTR [rsp+0x68]
    14d8:	mov    r15,QWORD PTR [rsp+0x70]
    14dd:	add    rsp,0x80
    14e4:	mov    rsp,rbp
    14e7:	pop    rbp
    14e8:	ret
    14e9:	add    BYTE PTR [rax],al
    14eb:	add    BYTE PTR [rax],al
    14ed:	add    BYTE PTR [rax],al
    14ef:	add    BYTE PTR [rsi],al
    14f1:	add    BYTE PTR [rax],al
    14f3:	add    BYTE PTR [rax],al
    14f5:	add    BYTE PTR [rax],al
	...

00000000000014f8 <botlish_entry_9: scan_records<str, int, List[List[str]]>>:
    14f8:	push   rbp
    14f9:	mov    rbp,rsp
    14fc:	mov    rsi,QWORD PTR [rdx]
    14ff:	mov    r8,QWORD PTR [rdx+0x8]
    1503:	mov    rcx,QWORD PTR [rdx+0x10]
    1507:	mov    rdx,r8
    150a:	call   150f <botlish_entry_9+0x17>
			150b: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    150f:	mov    rsp,rbp
    1512:	pop    rbp
    1513:	ret

0000000000001514 <botlish_fn_10: csv_parse<str>>:
    1514:	push   rbp
    1515:	mov    rbp,rsp
    1518:	sub    rsp,0x30
    151c:	mov    QWORD PTR [rsp+0x20],r12
    1521:	mov    QWORD PTR [rsp+0x28],r13
    1526:	mov    r13,rdi
    1529:	mov    QWORD PTR [rsp+0x10],0x0
    1532:	mov    QWORD PTR [rsp],rsi
    1536:	mov    r12,rsi
    1539:	mov    QWORD PTR [rsp+0x8],0x1
    1542:	xor    rdx,rdx
    1545:	mov    rdi,r13
    1548:	mov    rsi,rdx
    154b:	call   1550 <botlish_fn_10+0x3c>
			154c: R_X86_64_PLT32	rt_list_new-0x4
    1550:	test   rax,rax
    1553:	je     157a <botlish_fn_10+0x66>
    1559:	mov    QWORD PTR [rsp+0x10],rax
    155e:	mov    rcx,rax
    1561:	mov    edx,0x1
    1566:	mov    rsi,r12
    1569:	mov    rdi,r13
    156c:	call   1571 <botlish_fn_10+0x5d>
			156d: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    1571:	test   rax,rax
    1574:	jne    1590 <botlish_fn_10+0x7c>
    157a:	xor    rax,rax
    157d:	mov    r12,QWORD PTR [rsp+0x20]
    1582:	mov    r13,QWORD PTR [rsp+0x28]
    1587:	add    rsp,0x30
    158b:	mov    rsp,rbp
    158e:	pop    rbp
    158f:	ret
    1590:	mov    r12,QWORD PTR [rsp+0x20]
    1595:	mov    r13,QWORD PTR [rsp+0x28]
    159a:	add    rsp,0x30
    159e:	mov    rsp,rbp
    15a1:	pop    rbp
    15a2:	ret

00000000000015a3 <botlish_entry_10: csv_parse<str>>:
    15a3:	push   rbp
    15a4:	mov    rbp,rsp
    15a7:	mov    rsi,QWORD PTR [rdx]
    15aa:	call   15af <botlish_entry_10+0xc>
			15ab: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    15af:	mov    rsp,rbp
    15b2:	pop    rbp
    15b3:	ret

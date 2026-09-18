; source:  examples/stdlib/string_replace.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2943  (per function: 696 612 1196 439)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> matches_at<str, str, int>
;   botlish_fn_2 / botlish_entry_2 -> replace_from<str, str, str, int, int, str>
;   botlish_fn_3 / botlish_entry_3 -> replace<str, str, str>


string_replace.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x60
   8:	mov    QWORD PTR [rsp+0x30],rbx
   d:	mov    QWORD PTR [rsp+0x38],r12
  12:	mov    QWORD PTR [rsp+0x40],r13
  17:	mov    QWORD PTR [rsp+0x48],r14
  1c:	mov    QWORD PTR [rsp+0x50],r15
  21:	mov    r15,QWORD PTR [rdi]
  24:	mov    rax,QWORD PTR [rdi+0x8]
  28:	lea    rcx,[r15+0x38]
  2c:	cmp    rcx,rax
  2f:	ja     26d <botlish_fn_0+0x26d>
  35:	lea    rax,[r15+0x38]
  39:	mov    QWORD PTR [rdi],rax
  3c:	mov    QWORD PTR [r15],0x0
  43:	mov    QWORD PTR [r15+0x8],0x0
  4b:	mov    QWORD PTR [r15+0x10],0x0
  53:	mov    QWORD PTR [r15+0x18],0x0
  5b:	mov    QWORD PTR [r15+0x20],0x0
  63:	mov    QWORD PTR [r15+0x28],0x0
  6b:	mov    QWORD PTR [r15+0x30],0x0
  73:	mov    rax,QWORD PTR [rdi+0x10]
  77:	mov    rsi,QWORD PTR [rax]
  7a:	mov    QWORD PTR [r15],rsi
  7d:	mov    rax,QWORD PTR [rdi+0x10]
  81:	mov    rdx,QWORD PTR [rax+0x8]
  85:	mov    QWORD PTR [r15+0x8],rdx
  89:	mov    rax,QWORD PTR [rdi+0x10]
  8d:	mov    QWORD PTR [rsp+0x28],rdi
  92:	mov    rcx,QWORD PTR [rax+0x10]
  96:	mov    QWORD PTR [r15+0x10],rcx
  9a:	call   9f <botlish_fn_0+0x9f>
			9b: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  9f:	mov    rbx,rax
  a2:	test   rbx,rbx
  a5:	jne    b5 <botlish_fn_0+0xb5>
  ab:	mov    rdi,QWORD PTR [rsp+0x28]
  b0:	jmp    216 <botlish_fn_0+0x216>
  b5:	mov    QWORD PTR [r15],rbx
  b8:	mov    rdi,QWORD PTR [rsp+0x28]
  bd:	mov    rsi,QWORD PTR [rdi+0x10]
  c1:	mov    rsi,QWORD PTR [rsi]
  c4:	mov    QWORD PTR [r15+0x8],rsi
  c8:	mov    rdi,QWORD PTR [rdi+0x10]
  cc:	mov    rdx,QWORD PTR [rdi+0x18]
  d0:	mov    QWORD PTR [r15+0x10],rdx
  d4:	mov    rdi,QWORD PTR [rsp+0x28]
  d9:	mov    rdi,QWORD PTR [rdi+0x10]
  dd:	mov    rcx,QWORD PTR [rdi+0x20]
  e1:	mov    QWORD PTR [r15+0x18],rcx
  e5:	mov    rdi,QWORD PTR [rsp+0x28]
  ea:	call   ef <botlish_fn_0+0xef>
			eb: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
  ef:	mov    r12,rax
  f2:	test   r12,r12
  f5:	jne    105 <botlish_fn_0+0x105>
  fb:	mov    rdi,QWORD PTR [rsp+0x28]
 100:	jmp    216 <botlish_fn_0+0x216>
 105:	mov    QWORD PTR [r15+0x8],r12
 109:	mov    rdi,QWORD PTR [rsp+0x28]
 10e:	mov    r10,QWORD PTR [rdi+0x10]
 112:	mov    rsi,QWORD PTR [r10+0x28]
 116:	mov    QWORD PTR [r15+0x10],rsi
 11a:	mov    r11,QWORD PTR [rdi+0x10]
 11e:	mov    rdx,QWORD PTR [r11+0x30]
 122:	mov    QWORD PTR [r15+0x18],rdx
 126:	mov    rax,QWORD PTR [rdi+0x10]
 12a:	mov    rcx,QWORD PTR [rax+0x18]
 12e:	mov    QWORD PTR [r15+0x20],rcx
 132:	call   137 <botlish_fn_0+0x137>
			133: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 137:	mov    r13,rax
 13a:	test   r13,r13
 13d:	jne    14d <botlish_fn_0+0x14d>
 143:	mov    rdi,QWORD PTR [rsp+0x28]
 148:	jmp    216 <botlish_fn_0+0x216>
 14d:	mov    QWORD PTR [r15+0x10],r13
 151:	mov    rdi,QWORD PTR [rsp+0x28]
 156:	mov    rax,QWORD PTR [rdi+0x10]
 15a:	mov    rsi,QWORD PTR [rax+0x38]
 15e:	mov    QWORD PTR [r15+0x18],rsi
 162:	mov    rax,QWORD PTR [rdi+0x10]
 166:	mov    rdx,QWORD PTR [rax]
 169:	mov    QWORD PTR [r15+0x20],rdx
 16d:	mov    rax,QWORD PTR [rdi+0x10]
 171:	mov    rcx,QWORD PTR [rax+0x40]
 175:	mov    QWORD PTR [r15+0x28],rcx
 179:	call   17e <botlish_fn_0+0x17e>
			17a: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 17e:	mov    r14,rax
 181:	test   r14,r14
 184:	jne    194 <botlish_fn_0+0x194>
 18a:	mov    rdi,QWORD PTR [rsp+0x28]
 18f:	jmp    216 <botlish_fn_0+0x216>
 194:	mov    QWORD PTR [r15+0x18],r14
 198:	mov    rdi,QWORD PTR [rsp+0x28]
 19d:	mov    rax,QWORD PTR [rdi+0x10]
 1a1:	mov    rsi,QWORD PTR [rax+0x40]
 1a5:	mov    QWORD PTR [r15+0x20],rsi
 1a9:	mov    rax,QWORD PTR [rdi+0x10]
 1ad:	mov    rdx,QWORD PTR [rax+0x8]
 1b1:	mov    QWORD PTR [r15+0x28],rdx
 1b5:	mov    rax,QWORD PTR [rdi+0x10]
 1b9:	mov    rcx,QWORD PTR [rax+0x10]
 1bd:	mov    QWORD PTR [r15+0x30],rcx
 1c1:	call   1c6 <botlish_fn_0+0x1c6>
			1c2: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 1c6:	test   rax,rax
 1c9:	jne    1d9 <botlish_fn_0+0x1d9>
 1cf:	mov    rdi,QWORD PTR [rsp+0x28]
 1d4:	jmp    216 <botlish_fn_0+0x216>
 1d9:	mov    QWORD PTR [r15+0x20],rax
 1dd:	lea    rdx,[rsp]
 1e1:	mov    QWORD PTR [rsp],rbx
 1e5:	mov    QWORD PTR [rsp+0x8],r12
 1ea:	mov    QWORD PTR [rsp+0x10],r13
 1ef:	mov    QWORD PTR [rsp+0x18],r14
 1f4:	mov    QWORD PTR [rsp+0x20],rax
 1f9:	mov    esi,0x5
 1fe:	mov    rdi,QWORD PTR [rsp+0x28]
 203:	call   208 <botlish_fn_0+0x208>
			204: R_X86_64_PLT32	rt_list_new-0x4
 208:	test   rax,rax
 20b:	jne    243 <botlish_fn_0+0x243>
 211:	mov    rdi,QWORD PTR [rsp+0x28]
 216:	mov    rdi,QWORD PTR [rsp+0x28]
 21b:	mov    QWORD PTR [rdi],r15
 21e:	xor    rax,rax
 221:	mov    rbx,QWORD PTR [rsp+0x30]
 226:	mov    r12,QWORD PTR [rsp+0x38]
 22b:	mov    r13,QWORD PTR [rsp+0x40]
 230:	mov    r14,QWORD PTR [rsp+0x48]
 235:	mov    r15,QWORD PTR [rsp+0x50]
 23a:	add    rsp,0x60
 23e:	mov    rsp,rbp
 241:	pop    rbp
 242:	ret
 243:	mov    rdi,QWORD PTR [rsp+0x28]
 248:	mov    QWORD PTR [rdi],r15
 24b:	mov    rbx,QWORD PTR [rsp+0x30]
 250:	mov    r12,QWORD PTR [rsp+0x38]
 255:	mov    r13,QWORD PTR [rsp+0x40]
 25a:	mov    r14,QWORD PTR [rsp+0x48]
 25f:	mov    r15,QWORD PTR [rsp+0x50]
 264:	add    rsp,0x60
 268:	mov    rsp,rbp
 26b:	pop    rbp
 26c:	ret
 26d:	mov    QWORD PTR [rsp+0x28],rdi
 272:	call   277 <botlish_fn_0+0x277>
			273: R_X86_64_PLT32	rt_stack_overflow-0x4
 277:	xor    rax,rax
 27a:	mov    rbx,QWORD PTR [rsp+0x30]
 27f:	mov    r12,QWORD PTR [rsp+0x38]
 284:	mov    r13,QWORD PTR [rsp+0x40]
 289:	mov    r14,QWORD PTR [rsp+0x48]
 28e:	mov    r15,QWORD PTR [rsp+0x50]
 293:	add    rsp,0x60
 297:	mov    rsp,rbp
 29a:	pop    rbp
 29b:	ret

000000000000029c <botlish_entry_0: <program entry>>:
 29c:	push   rbp
 29d:	mov    rbp,rsp
 2a0:	call   2a5 <botlish_entry_0+0x9>
			2a1: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
 2a5:	mov    rsp,rbp
 2a8:	pop    rbp
 2a9:	ret
 2aa:	add    BYTE PTR [rax],al
 2ac:	add    BYTE PTR [rax],al
	...

00000000000002b0 <botlish_fn_1: matches_at<str, str, int>>:
 2b0:	push   rbp
 2b1:	mov    rbp,rsp
 2b4:	sub    rsp,0x40
 2b8:	mov    QWORD PTR [rsp+0x10],rbx
 2bd:	mov    QWORD PTR [rsp+0x18],r12
 2c2:	mov    QWORD PTR [rsp+0x20],r13
 2c7:	mov    QWORD PTR [rsp+0x28],r14
 2cc:	mov    QWORD PTR [rsp+0x30],r15
 2d1:	mov    r12,QWORD PTR [rdi]
 2d4:	mov    rax,QWORD PTR [rdi+0x8]
 2d8:	lea    r8,[r12+0x20]
 2dd:	cmp    r8,rax
 2e0:	ja     48f <botlish_fn_1+0x1df>
 2e6:	lea    rax,[r12+0x20]
 2eb:	mov    QWORD PTR [rdi],rax
 2ee:	mov    r14,rdi
 2f1:	mov    QWORD PTR [r12],0x0
 2f9:	mov    QWORD PTR [r12+0x8],0x0
 302:	mov    QWORD PTR [r12+0x10],0x0
 30b:	mov    QWORD PTR [r12+0x18],0x0
 314:	mov    QWORD PTR [r12],rsi
 318:	mov    QWORD PTR [rsp],rsi
 31c:	mov    QWORD PTR [r12+0x8],rdx
 321:	mov    r15,rdx
 324:	mov    QWORD PTR [r12+0x10],rcx
 329:	mov    rbx,rcx
 32c:	mov    rsi,r15
 32f:	mov    rdi,r14
 332:	call   337 <botlish_fn_1+0x87>
			333: R_X86_64_PLT32	rt_str_len-0x4
 337:	mov    QWORD PTR [r12+0x18],rax
 33c:	mov    rcx,rbx
 33f:	and    rcx,rax
 342:	test   rcx,0x1
 349:	jne    357 <botlish_fn_1+0xa7>
 34f:	mov    rdx,rax
 352:	jmp    372 <botlish_fn_1+0xc2>
 357:	lea    rcx,[rax-0x1]
 35b:	mov    rdx,rax
 35e:	mov    rax,rbx
 361:	add    rax,rcx
 364:	mov    r13,rax
 367:	seto   al
 36a:	test   al,al
 36c:	je     380 <botlish_fn_1+0xd0>
 372:	mov    rsi,rbx
 375:	mov    rdi,r14
 378:	call   37d <botlish_fn_1+0xcd>
			379: R_X86_64_PLT32	rt_int_add-0x4
 37d:	mov    r13,rax
 380:	mov    rsi,QWORD PTR [rsp]
 384:	mov    rdi,r14
 387:	call   38c <botlish_fn_1+0xdc>
			388: R_X86_64_PLT32	rt_str_len-0x4
 38c:	mov    rcx,r13
 38f:	and    rcx,rax
 392:	mov    rdx,rax
 395:	test   rcx,0x1
 39c:	jne    3c2 <botlish_fn_1+0x112>
 3a2:	mov    rsi,r13
 3a5:	mov    rdi,r14
 3a8:	call   3ad <botlish_fn_1+0xfd>
			3a9: R_X86_64_PLT32	rt_int_cmp-0x4
 3ad:	mov    ecx,0x2
 3b2:	test   rax,rax
 3b5:	cmovg  rcx,QWORD PTR [rip+0x103]        # 4c0 <botlish_fn_1+0x210>
 3bd:	jmp    3d5 <botlish_fn_1+0x125>
 3c2:	mov    ecx,0x2
 3c7:	mov    rax,r13
 3ca:	cmp    rax,rdx
 3cd:	cmovg  rcx,QWORD PTR [rip+0xeb]        # 4c0 <botlish_fn_1+0x210>
 3d5:	cmp    rcx,0x6
 3d9:	je     462 <botlish_fn_1+0x1b2>
 3df:	mov    rcx,r13
 3e2:	mov    rdx,rbx
 3e5:	mov    rsi,QWORD PTR [rsp]
 3e9:	mov    rdi,r14
 3ec:	call   3f1 <botlish_fn_1+0x141>
			3ed: R_X86_64_PLT32	rt_str_region_check-0x4
 3f1:	test   rax,rax
 3f4:	jne    425 <botlish_fn_1+0x175>
 3fa:	mov    rdi,r14
 3fd:	mov    QWORD PTR [rdi],r12
 400:	xor    rax,rax
 403:	mov    rbx,QWORD PTR [rsp+0x10]
 408:	mov    r12,QWORD PTR [rsp+0x18]
 40d:	mov    r13,QWORD PTR [rsp+0x20]
 412:	mov    r14,QWORD PTR [rsp+0x28]
 417:	mov    r15,QWORD PTR [rsp+0x30]
 41c:	add    rsp,0x40
 420:	mov    rsp,rbp
 423:	pop    rbp
 424:	ret
 425:	mov    rcx,r13
 428:	mov    rdx,rbx
 42b:	mov    rsi,QWORD PTR [rsp]
 42f:	mov    r8,r15
 432:	mov    rdi,r14
 435:	call   43a <botlish_fn_1+0x18a>
			436: R_X86_64_PLT32	rt_str_region_eq-0x4
 43a:	mov    rdi,r14
 43d:	mov    QWORD PTR [rdi],r12
 440:	mov    rbx,QWORD PTR [rsp+0x10]
 445:	mov    r12,QWORD PTR [rsp+0x18]
 44a:	mov    r13,QWORD PTR [rsp+0x20]
 44f:	mov    r14,QWORD PTR [rsp+0x28]
 454:	mov    r15,QWORD PTR [rsp+0x30]
 459:	add    rsp,0x40
 45d:	mov    rsp,rbp
 460:	pop    rbp
 461:	ret
 462:	mov    rdi,r14
 465:	mov    QWORD PTR [rdi],r12
 468:	mov    eax,0x2
 46d:	mov    rbx,QWORD PTR [rsp+0x10]
 472:	mov    r12,QWORD PTR [rsp+0x18]
 477:	mov    r13,QWORD PTR [rsp+0x20]
 47c:	mov    r14,QWORD PTR [rsp+0x28]
 481:	mov    r15,QWORD PTR [rsp+0x30]
 486:	add    rsp,0x40
 48a:	mov    rsp,rbp
 48d:	pop    rbp
 48e:	ret
 48f:	mov    r14,rdi
 492:	call   497 <botlish_fn_1+0x1e7>
			493: R_X86_64_PLT32	rt_stack_overflow-0x4
 497:	xor    rax,rax
 49a:	mov    rbx,QWORD PTR [rsp+0x10]
 49f:	mov    r12,QWORD PTR [rsp+0x18]
 4a4:	mov    r13,QWORD PTR [rsp+0x20]
 4a9:	mov    r14,QWORD PTR [rsp+0x28]
 4ae:	mov    r15,QWORD PTR [rsp+0x30]
 4b3:	add    rsp,0x40
 4b7:	mov    rsp,rbp
 4ba:	pop    rbp
 4bb:	ret
 4bc:	add    BYTE PTR [rax],al
 4be:	add    BYTE PTR [rax],al
 4c0:	(bad)
 4c1:	add    BYTE PTR [rax],al
 4c3:	add    BYTE PTR [rax],al
 4c5:	add    BYTE PTR [rax],al
	...

00000000000004c8 <botlish_entry_1: matches_at<str, str, int>>:
 4c8:	push   rbp
 4c9:	mov    rbp,rsp
 4cc:	mov    rsi,QWORD PTR [rdx]
 4cf:	mov    r8,QWORD PTR [rdx+0x8]
 4d3:	mov    rcx,QWORD PTR [rdx+0x10]
 4d7:	mov    rdx,r8
 4da:	call   4df <botlish_entry_1+0x17>
			4db: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 4df:	mov    rsp,rbp
 4e2:	pop    rbp
 4e3:	ret
 4e4:	add    BYTE PTR [rax],al
	...

00000000000004e8 <botlish_fn_2: replace_from<str, str, str, int, int, str>>:
 4e8:	push   rbp
 4e9:	mov    rbp,rsp
 4ec:	sub    rsp,0x50
 4f0:	mov    QWORD PTR [rsp+0x20],rbx
 4f5:	mov    QWORD PTR [rsp+0x28],r12
 4fa:	mov    QWORD PTR [rsp+0x30],r13
 4ff:	mov    QWORD PTR [rsp+0x38],r14
 504:	mov    QWORD PTR [rsp+0x40],r15
 509:	mov    r10,QWORD PTR [rbp+0x10]
 50d:	mov    r13,QWORD PTR [rdi]
 510:	mov    rax,QWORD PTR [rdi+0x8]
 514:	lea    r11,[r13+0x38]
 518:	cmp    r11,rax
 51b:	ja     8c3 <botlish_fn_2+0x3db>
 521:	lea    rax,[r13+0x38]
 525:	mov    QWORD PTR [rdi],rax
 528:	mov    r14,rdi
 52b:	mov    QWORD PTR [r13+0x0],0x0
 533:	mov    QWORD PTR [r13+0x8],0x0
 53b:	mov    QWORD PTR [r13+0x10],0x0
 543:	mov    QWORD PTR [r13+0x18],0x0
 54b:	mov    QWORD PTR [r13+0x20],0x0
 553:	mov    QWORD PTR [r13+0x28],0x0
 55b:	mov    QWORD PTR [r13+0x30],0x0
 563:	mov    QWORD PTR [r13+0x0],rsi
 567:	mov    r15,rsi
 56a:	mov    QWORD PTR [r13+0x8],rdx
 56e:	mov    QWORD PTR [r13+0x10],rcx
 572:	mov    r12,rcx
 575:	mov    QWORD PTR [r13+0x18],r8
 579:	mov    QWORD PTR [r13+0x20],r9
 57d:	mov    QWORD PTR [r13+0x28],r10
 581:	mov    QWORD PTR [rsp+0x10],r10
 586:	mov    rbx,rdx
 589:	mov    QWORD PTR [rsp],r8
 58d:	mov    QWORD PTR [rsp+0x8],r9
 592:	mov    rsi,rbx
 595:	mov    rdi,r14
 598:	call   59d <botlish_fn_2+0xb5>
			599: R_X86_64_PLT32	rt_str_len-0x4
 59d:	mov    QWORD PTR [r13+0x30],rax
 5a1:	mov    rsi,QWORD PTR [rsp]
 5a5:	mov    r9,rsi
 5a8:	and    r9,rax
 5ab:	test   r9,0x1
 5b2:	jne    5c4 <botlish_fn_2+0xdc>
 5b8:	mov    rdx,rax
 5bb:	mov    QWORD PTR [rsp],rsi
 5bf:	jmp    5e5 <botlish_fn_2+0xfd>
 5c4:	lea    rcx,[rax-0x1]
 5c8:	mov    rdx,rax
 5cb:	mov    rax,rsi
 5ce:	add    rax,rcx
 5d1:	mov    QWORD PTR [rsp],rsi
 5d5:	mov    QWORD PTR [rsp+0x18],rax
 5da:	seto   al
 5dd:	test   al,al
 5df:	je     5f6 <botlish_fn_2+0x10e>
 5e5:	mov    rsi,QWORD PTR [rsp]
 5e9:	mov    rdi,r14
 5ec:	call   5f1 <botlish_fn_2+0x109>
			5ed: R_X86_64_PLT32	rt_int_add-0x4
 5f1:	mov    QWORD PTR [rsp+0x18],rax
 5f6:	mov    rsi,r15
 5f9:	mov    rdi,r14
 5fc:	call   601 <botlish_fn_2+0x119>
			5fd: R_X86_64_PLT32	rt_str_len-0x4
 601:	mov    rsi,QWORD PTR [rsp+0x18]
 606:	mov    rcx,rsi
 609:	and    rcx,rax
 60c:	mov    rdx,rax
 60f:	test   rcx,0x1
 616:	jne    639 <botlish_fn_2+0x151>
 61c:	mov    rdi,r14
 61f:	call   624 <botlish_fn_2+0x13c>
			620: R_X86_64_PLT32	rt_int_cmp-0x4
 624:	mov    ecx,0x2
 629:	test   rax,rax
 62c:	cmovg  rcx,QWORD PTR [rip+0x2bc]        # 8f0 <botlish_fn_2+0x408>
 634:	jmp    649 <botlish_fn_2+0x161>
 639:	mov    ecx,0x2
 63e:	cmp    rsi,rdx
 641:	cmovg  rcx,QWORD PTR [rip+0x2a7]        # 8f0 <botlish_fn_2+0x408>
 649:	cmp    rcx,0x6
 64d:	je     81d <botlish_fn_2+0x335>
 653:	mov    rcx,QWORD PTR [rsp]
 657:	mov    rdx,rbx
 65a:	mov    rsi,r15
 65d:	mov    rdi,r14
 660:	call   665 <botlish_fn_2+0x17d>
			661: R_X86_64_PLT32	botlish_fn_1-0x4 ; matches_at<str, str, int>
 665:	test   rax,rax
 668:	jne    676 <botlish_fn_2+0x18e>
 66e:	mov    rdi,r14
 671:	jmp    870 <botlish_fn_2+0x388>
 676:	cmp    rax,0x6
 67a:	je     701 <botlish_fn_2+0x219>
 680:	mov    QWORD PTR [r13+0x30],0x3
 688:	mov    rsi,QWORD PTR [rsp]
 68c:	test   rsi,0x1
 693:	je     6bb <botlish_fn_2+0x1d3>
 699:	mov    rsi,QWORD PTR [rsp]
 69d:	mov    rax,rsi
 6a0:	add    rax,0x2
 6a4:	seto   cl
 6a7:	test   cl,cl
 6a9:	jne    6bb <botlish_fn_2+0x1d3>
 6af:	mov    rsi,r15
 6b2:	mov    QWORD PTR [rsp],rax
 6b6:	jmp    6d3 <botlish_fn_2+0x1eb>
 6bb:	mov    edx,0x3
 6c0:	mov    rsi,QWORD PTR [rsp]
 6c4:	mov    rdi,r14
 6c7:	call   6cc <botlish_fn_2+0x1e4>
			6c8: R_X86_64_PLT32	rt_int_add-0x4
 6cc:	mov    rsi,r15
 6cf:	mov    QWORD PTR [rsp],rax
 6d3:	mov    rsi,r15
 6d6:	mov    QWORD PTR [r13+0x0],rsi
 6da:	mov    QWORD PTR [r13+0x8],rbx
 6de:	mov    QWORD PTR [r13+0x10],r12
 6e2:	mov    rsi,QWORD PTR [rsp]
 6e6:	mov    QWORD PTR [r13+0x18],rsi
 6ea:	mov    rdx,QWORD PTR [rsp+0x8]
 6ef:	mov    QWORD PTR [r13+0x20],rdx
 6f3:	mov    rsi,QWORD PTR [rsp+0x10]
 6f8:	mov    QWORD PTR [r13+0x28],rsi
 6fc:	jmp    592 <botlish_fn_2+0xaa>
 701:	mov    rdx,QWORD PTR [rsp+0x8]
 706:	mov    rcx,QWORD PTR [rsp]
 70a:	mov    rsi,r15
 70d:	mov    rdi,r14
 710:	call   715 <botlish_fn_2+0x22d>
			711: R_X86_64_PLT32	rt_substr-0x4
 715:	test   rax,rax
 718:	jne    726 <botlish_fn_2+0x23e>
 71e:	mov    rdi,r14
 721:	jmp    870 <botlish_fn_2+0x388>
 726:	mov    QWORD PTR [r13+0x20],rax
 72a:	mov    rdx,rax
 72d:	mov    rsi,QWORD PTR [rsp+0x10]
 732:	mov    rdi,r14
 735:	call   73a <botlish_fn_2+0x252>
			736: R_X86_64_PLT32	rt_str_cat-0x4
 73a:	test   rax,rax
 73d:	jne    74b <botlish_fn_2+0x263>
 743:	mov    rdi,r14
 746:	jmp    870 <botlish_fn_2+0x388>
 74b:	mov    QWORD PTR [r13+0x20],rax
 74f:	mov    QWORD PTR [rsp+0x18],rax
 754:	mov    rsi,rbx
 757:	mov    rdi,r14
 75a:	call   75f <botlish_fn_2+0x277>
			75b: R_X86_64_PLT32	rt_str_len-0x4
 75f:	mov    QWORD PTR [r13+0x28],rax
 763:	mov    rsi,QWORD PTR [rsp]
 767:	mov    rcx,rsi
 76a:	and    rcx,rax
 76d:	test   rcx,0x1
 774:	jne    786 <botlish_fn_2+0x29e>
 77a:	mov    rdx,rax
 77d:	mov    rsi,QWORD PTR [rsp]
 781:	jmp    7b7 <botlish_fn_2+0x2cf>
 786:	lea    rcx,[rax-0x1]
 78a:	mov    rdx,rax
 78d:	mov    rsi,QWORD PTR [rsp]
 791:	mov    rax,rsi
 794:	add    rax,rcx
 797:	seto   cl
 79a:	test   cl,cl
 79c:	je     7ab <botlish_fn_2+0x2c3>
 7a2:	mov    rsi,QWORD PTR [rsp]
 7a6:	jmp    7b7 <botlish_fn_2+0x2cf>
 7ab:	mov    rsi,rax
 7ae:	mov    QWORD PTR [rsp],rax
 7b2:	jmp    7c6 <botlish_fn_2+0x2de>
 7b7:	mov    rdi,r14
 7ba:	call   7bf <botlish_fn_2+0x2d7>
			7bb: R_X86_64_PLT32	rt_int_add-0x4
 7bf:	mov    rsi,rax
 7c2:	mov    QWORD PTR [rsp],rax
 7c6:	mov    QWORD PTR [r13+0x18],rsi
 7ca:	mov    rsi,QWORD PTR [rsp+0x18]
 7cf:	mov    rdx,r12
 7d2:	mov    rdi,r14
 7d5:	call   7da <botlish_fn_2+0x2f2>
			7d6: R_X86_64_PLT32	rt_str_cat-0x4
 7da:	test   rax,rax
 7dd:	jne    7eb <botlish_fn_2+0x303>
 7e3:	mov    rdi,r14
 7e6:	jmp    870 <botlish_fn_2+0x388>
 7eb:	mov    rsi,r15
 7ee:	mov    QWORD PTR [r13+0x0],rsi
 7f2:	mov    QWORD PTR [r13+0x8],rbx
 7f6:	mov    QWORD PTR [r13+0x10],r12
 7fa:	mov    rsi,QWORD PTR [rsp]
 7fe:	mov    QWORD PTR [r13+0x18],rsi
 802:	mov    QWORD PTR [r13+0x20],rsi
 806:	mov    QWORD PTR [r13+0x28],rax
 80a:	mov    rcx,QWORD PTR [rsp]
 80e:	mov    QWORD PTR [rsp+0x8],rcx
 813:	mov    QWORD PTR [rsp+0x10],rax
 818:	jmp    592 <botlish_fn_2+0xaa>
 81d:	mov    rsi,r15
 820:	mov    rdi,r14
 823:	call   828 <botlish_fn_2+0x340>
			824: R_X86_64_PLT32	rt_str_len-0x4
 828:	mov    QWORD PTR [r13+0x8],rax
 82c:	mov    rcx,rax
 82f:	mov    rdx,QWORD PTR [rsp+0x8]
 834:	mov    rsi,r15
 837:	mov    rdi,r14
 83a:	call   83f <botlish_fn_2+0x357>
			83b: R_X86_64_PLT32	rt_substr-0x4
 83f:	test   rax,rax
 842:	jne    850 <botlish_fn_2+0x368>
 848:	mov    rdi,r14
 84b:	jmp    870 <botlish_fn_2+0x388>
 850:	mov    QWORD PTR [r13+0x0],rax
 854:	mov    rdx,rax
 857:	mov    rsi,QWORD PTR [rsp+0x10]
 85c:	mov    rdi,r14
 85f:	call   864 <botlish_fn_2+0x37c>
			860: R_X86_64_PLT32	rt_str_cat-0x4
 864:	test   rax,rax
 867:	jne    89b <botlish_fn_2+0x3b3>
 86d:	mov    rdi,r14
 870:	mov    rdi,r14
 873:	mov    QWORD PTR [rdi],r13
 876:	xor    rax,rax
 879:	mov    rbx,QWORD PTR [rsp+0x20]
 87e:	mov    r12,QWORD PTR [rsp+0x28]
 883:	mov    r13,QWORD PTR [rsp+0x30]
 888:	mov    r14,QWORD PTR [rsp+0x38]
 88d:	mov    r15,QWORD PTR [rsp+0x40]
 892:	add    rsp,0x50
 896:	mov    rsp,rbp
 899:	pop    rbp
 89a:	ret
 89b:	mov    rdi,r14
 89e:	mov    QWORD PTR [rdi],r13
 8a1:	mov    rbx,QWORD PTR [rsp+0x20]
 8a6:	mov    r12,QWORD PTR [rsp+0x28]
 8ab:	mov    r13,QWORD PTR [rsp+0x30]
 8b0:	mov    r14,QWORD PTR [rsp+0x38]
 8b5:	mov    r15,QWORD PTR [rsp+0x40]
 8ba:	add    rsp,0x50
 8be:	mov    rsp,rbp
 8c1:	pop    rbp
 8c2:	ret
 8c3:	mov    r14,rdi
 8c6:	call   8cb <botlish_fn_2+0x3e3>
			8c7: R_X86_64_PLT32	rt_stack_overflow-0x4
 8cb:	xor    rax,rax
 8ce:	mov    rbx,QWORD PTR [rsp+0x20]
 8d3:	mov    r12,QWORD PTR [rsp+0x28]
 8d8:	mov    r13,QWORD PTR [rsp+0x30]
 8dd:	mov    r14,QWORD PTR [rsp+0x38]
 8e2:	mov    r15,QWORD PTR [rsp+0x40]
 8e7:	add    rsp,0x50
 8eb:	mov    rsp,rbp
 8ee:	pop    rbp
 8ef:	ret
 8f0:	(bad)
 8f1:	add    BYTE PTR [rax],al
 8f3:	add    BYTE PTR [rax],al
 8f5:	add    BYTE PTR [rax],al
	...

00000000000008f8 <botlish_entry_2: replace_from<str, str, str, int, int, str>>:
 8f8:	push   rbp
 8f9:	mov    rbp,rsp
 8fc:	sub    rsp,0x10
 900:	mov    rsi,QWORD PTR [rdx]
 903:	mov    r10,QWORD PTR [rdx+0x8]
 907:	mov    rcx,QWORD PTR [rdx+0x10]
 90b:	mov    r8,QWORD PTR [rdx+0x18]
 90f:	mov    r9,QWORD PTR [rdx+0x20]
 913:	mov    r11,QWORD PTR [rdx+0x28]
 917:	mov    QWORD PTR [rsp],r11
 91b:	mov    rdx,r10
 91e:	call   923 <botlish_entry_2+0x2b>
			91f: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 923:	add    rsp,0x10
 927:	mov    rsp,rbp
 92a:	pop    rbp
 92b:	ret

000000000000092c <botlish_fn_3: replace<str, str, str>>:
 92c:	push   rbp
 92d:	mov    rbp,rsp
 930:	sub    rsp,0x40
 934:	mov    QWORD PTR [rsp+0x10],rbx
 939:	mov    QWORD PTR [rsp+0x18],r12
 93e:	mov    QWORD PTR [rsp+0x20],r13
 943:	mov    QWORD PTR [rsp+0x28],r14
 948:	mov    QWORD PTR [rsp+0x30],r15
 94d:	mov    r13,rsi
 950:	mov    r15,rdx
 953:	mov    rbx,QWORD PTR [rdi]
 956:	mov    rax,QWORD PTR [rdi+0x8]
 95a:	lea    rdx,[rbx+0x30]
 95e:	cmp    rdx,rax
 961:	ja     a8c <botlish_fn_3+0x160>
 967:	lea    rax,[rbx+0x30]
 96b:	mov    QWORD PTR [rdi],rax
 96e:	mov    r12,rdi
 971:	mov    QWORD PTR [rbx],0x0
 978:	mov    QWORD PTR [rbx+0x8],0x0
 980:	mov    QWORD PTR [rbx+0x10],0x0
 988:	mov    QWORD PTR [rbx+0x18],0x0
 990:	mov    QWORD PTR [rbx+0x20],0x0
 998:	mov    QWORD PTR [rbx+0x28],0x0
 9a0:	mov    rsi,r13
 9a3:	mov    QWORD PTR [rbx],rsi
 9a6:	mov    rdx,r15
 9a9:	mov    QWORD PTR [rbx+0x8],rdx
 9ad:	mov    QWORD PTR [rbx+0x10],rcx
 9b1:	mov    r14,rcx
 9b4:	mov    rsi,r15
 9b7:	mov    rdi,r12
 9ba:	call   9bf <botlish_fn_3+0x93>
			9bb: R_X86_64_PLT32	rt_str_len-0x4
 9bf:	sar    rax,1
 9c2:	test   rax,rax
 9c5:	je     a61 <botlish_fn_3+0x135>
 9cb:	mov    r9d,0x1
 9d1:	mov    QWORD PTR [rbx+0x18],0x1
 9d9:	mov    QWORD PTR [rbx+0x20],0x1
 9e1:	mov    rdi,r12
 9e4:	mov    rax,QWORD PTR [rdi+0x10]
 9e8:	mov    rax,QWORD PTR [rax+0x40]
 9ec:	mov    QWORD PTR [rbx+0x28],rax
 9f0:	mov    QWORD PTR [rsp],rax
 9f4:	mov    rcx,r14
 9f7:	mov    rdx,r15
 9fa:	mov    rsi,r13
 9fd:	mov    r8,r9
 a00:	call   a05 <botlish_fn_3+0xd9>
			a01: R_X86_64_PLT32	botlish_fn_2-0x4 ; replace_from<str, str, str, int, int, str>
 a05:	test   rax,rax
 a08:	jne    a39 <botlish_fn_3+0x10d>
 a0e:	mov    rdi,r12
 a11:	mov    QWORD PTR [rdi],rbx
 a14:	xor    rax,rax
 a17:	mov    rbx,QWORD PTR [rsp+0x10]
 a1c:	mov    r12,QWORD PTR [rsp+0x18]
 a21:	mov    r13,QWORD PTR [rsp+0x20]
 a26:	mov    r14,QWORD PTR [rsp+0x28]
 a2b:	mov    r15,QWORD PTR [rsp+0x30]
 a30:	add    rsp,0x40
 a34:	mov    rsp,rbp
 a37:	pop    rbp
 a38:	ret
 a39:	mov    rdi,r12
 a3c:	mov    QWORD PTR [rdi],rbx
 a3f:	mov    rbx,QWORD PTR [rsp+0x10]
 a44:	mov    r12,QWORD PTR [rsp+0x18]
 a49:	mov    r13,QWORD PTR [rsp+0x20]
 a4e:	mov    r14,QWORD PTR [rsp+0x28]
 a53:	mov    r15,QWORD PTR [rsp+0x30]
 a58:	add    rsp,0x40
 a5c:	mov    rsp,rbp
 a5f:	pop    rbp
 a60:	ret
 a61:	mov    rdi,r12
 a64:	mov    QWORD PTR [rdi],rbx
 a67:	mov    rax,r13
 a6a:	mov    rbx,QWORD PTR [rsp+0x10]
 a6f:	mov    r12,QWORD PTR [rsp+0x18]
 a74:	mov    r13,QWORD PTR [rsp+0x20]
 a79:	mov    r14,QWORD PTR [rsp+0x28]
 a7e:	mov    r15,QWORD PTR [rsp+0x30]
 a83:	add    rsp,0x40
 a87:	mov    rsp,rbp
 a8a:	pop    rbp
 a8b:	ret
 a8c:	mov    r12,rdi
 a8f:	call   a94 <botlish_fn_3+0x168>
			a90: R_X86_64_PLT32	rt_stack_overflow-0x4
 a94:	xor    rax,rax
 a97:	mov    rbx,QWORD PTR [rsp+0x10]
 a9c:	mov    r12,QWORD PTR [rsp+0x18]
 aa1:	mov    r13,QWORD PTR [rsp+0x20]
 aa6:	mov    r14,QWORD PTR [rsp+0x28]
 aab:	mov    r15,QWORD PTR [rsp+0x30]
 ab0:	add    rsp,0x40
 ab4:	mov    rsp,rbp
 ab7:	pop    rbp
 ab8:	ret

0000000000000ab9 <botlish_entry_3: replace<str, str, str>>:
 ab9:	push   rbp
 aba:	mov    rbp,rsp
 abd:	mov    rsi,QWORD PTR [rdx]
 ac0:	mov    r8,QWORD PTR [rdx+0x8]
 ac4:	mov    rcx,QWORD PTR [rdx+0x10]
 ac8:	mov    rdx,r8
 acb:	call   ad0 <botlish_entry_3+0x17>
			acc: R_X86_64_PLT32	botlish_fn_3-0x4 ; replace<str, str, str>
 ad0:	mov    rsp,rbp
 ad3:	pop    rbp
 ad4:	ret

<botlish_fn_4>:
  e0:	push   %rbp
  e1:	mov    %rsp,%rbp
  e4:	sub    $0xb0,%rsp
  eb:	mov    %rbx,0x80(%rsp)
  f3:	mov    %r12,0x88(%rsp)
  fb:	mov    %r13,0x90(%rsp)
 103:	mov    %r14,0x98(%rsp)
 10b:	mov    %r15,0xa0(%rsp)
 113:	mov    %rdi,0x30(%rsp)
 118:	movq   $0x0,(%rsp)
 120:	movq   $0x0,0x8(%rsp)
 129:	movq   $0x0,0x10(%rsp)
 132:	movq   $0x0,0x18(%rsp)
 13b:	movq   $0xa,0x20(%rsp)
 144:	movq   $0xa,0x28(%rsp)
 14d:	xor    %r12,%r12
 150:	mov    %rdx,%rax
 153:	shl    $1,%rax
 156:	mov    %rdx,0x40(%rsp)
 15b:	or     $0x1,%rax
 15f:	sar    $1,%rax
 162:	mov    %r12,%r13
 165:	mov    %r12,%r14
 168:	mov    %r12,0x58(%rsp)
 16d:	cmp    %rax,%r12
 170:	mov    %rax,0x70(%rsp)
 175:	jl     19a <botlish_fn_4+0xba>
 17b:	mov    $0xffffffffffffffff,%r8
 182:	movq   $0xffffffffffffffff,0x20(%rsp)
 18b:	mov    %rsi,0x38(%rsp)
 190:	mov    %r8,0x50(%rsp)
 195:	jmp    23d <botlish_fn_4+0x15d>
 19a:	mov    %r12,%rcx
 19d:	mov    %rsi,%r13
 1a0:	shl    $1,%r13
 1a3:	mov    %rsi,0x38(%rsp)
 1a8:	or     $0x1,%r13
 1ac:	sar    $1,%r13
 1af:	test   %r13,%r13
 1b2:	jg     1d9 <botlish_fn_4+0xf9>
 1b8:	add    $0x1,%rcx
 1bf:	xor    %r14,%r14
 1c2:	mov    %r12,0x58(%rsp)
 1c7:	mov    %rcx,%r12
 1ca:	mov    0x38(%rsp),%rsi
 1cf:	mov    0x70(%rsp),%rax
 1d4:	jmp    16d <botlish_fn_4+0x8d>
 1d9:	imul   $0x11,%r12,%r8
 1dd:	mov    %r8,%rax
 1e0:	imulq  0x501(%rip)        # 6e8 <botlish_fn_4+0x608>
 1e7:	lea    (%rdx,%r8,1),%rsi
 1eb:	sar    $0x6,%rsi
 1ef:	mov    %rsi,%rdx
 1f2:	shr    $0x3f,%rdx
 1f6:	lea    (%rsi,%rdx,1),%rdi
 1fa:	mov    $0x65,%esi
 1ff:	imul   $0x65,%rdi,%rdi
 203:	sub    %rdi,%r8
 206:	xor    %r14,%r14
 209:	mov    %rsi,%rdi
 20c:	neg    %rdi
 20f:	cmovs  %rsi,%rdi
 213:	lea    (%r8,%rdi,1),%rsi
 217:	test   %r8,%r8
 21a:	cmovl  %rsi,%r8
 21e:	mov    $0x1,%r9d
 224:	mov    %r9,0x50(%rsp)
 229:	shl    $1,%r8
 22c:	or     $0x1,%r8
 230:	mov    %r8,0x20(%rsp)
 235:	mov    %r12,0x58(%rsp)
 23a:	mov    %rcx,%r12
 23d:	mov    %r8,(%rsp)
 241:	mov    %r8,0x48(%rsp)
 246:	mov    $0x3,%esi
 24b:	movq   $0x3,0x8(%rsp)
 254:	mov    0x48(%rsp),%rdx
 259:	mov    0x30(%rsp),%rdi
 25e:	call   263 <botlish_fn_4+0x183>
			25f: R_X86_64_PLT32	rt_mutarray_create-0x4
 263:	test   %rax,%rax
 266:	je     523 <botlish_fn_4+0x443>
 26c:	mov    %rax,(%rsp)
 270:	mov    %rax,%rbx
 273:	mov    $0x1,%r15d
 279:	mov    %r15,0x60(%rsp)
 27e:	mov    0x38(%rsp),%r15
 283:	mov    0x40(%rsp),%rdx
 288:	mov    %r15,%r11
 28b:	imul   %rdx,%r11
 28f:	mov    %r11,0x68(%rsp)
 294:	mov    0x68(%rsp),%rax
 299:	mov    0x60(%rsp),%rcx
 29e:	cmp    %rax,%rcx
 2a1:	mov    %rcx,0x60(%rsp)
 2a6:	mov    %rax,0x68(%rsp)
 2ab:	jl     480 <botlish_fn_4+0x3a0>
 2b1:	mov    %rbx,%rsi
 2b4:	mov    0x10(%rsi),%rax
 2b8:	mov    (%rax),%rsi
 2bb:	mov    %rsi,(%rsp)
 2bf:	mov    0x50(%rsp),%r15
 2c4:	cmp    $0x1,%r15
 2c8:	je     314 <botlish_fn_4+0x234>
 2ce:	cmp    $0xffffffffffffffff,%r15
 2d2:	jne    2e2 <botlish_fn_4+0x202>
 2d8:	mov    0x48(%rsp),%rdx
 2dd:	jmp    3f8 <botlish_fn_4+0x318>
 2e2:	mov    $0xa,%esi
 2e7:	mov    0x30(%rsp),%rdi
 2ec:	call   2f1 <botlish_fn_4+0x211>
			2ed: R_X86_64_PLT32	rt_co_resume0-0x4
 2f1:	test   %rax,%rax
 2f4:	je     523 <botlish_fn_4+0x443>
 2fa:	mov    0x30(%rsp),%rdi
 2ff:	mov    0x10(%rdi),%rax
 303:	mov    (%rax),%rsi
 306:	mov    0x20(%rax),%rdx
 30a:	call   30f <botlish_fn_4+0x22f>
			30b: R_X86_64_PLT32	rt_raise-0x4
 30f:	jmp    523 <botlish_fn_4+0x443>
 314:	lea    0x1(%r14),%r10
 318:	cmp    %r13,%r10
 31b:	jl     375 <botlish_fn_4+0x295>
 321:	lea    0x1(%r12),%rdi
 326:	mov    0x70(%rsp),%rcx
 32b:	cmp    %rcx,%rdi
 32e:	jl     34e <botlish_fn_4+0x26e>
 334:	mov    $0xffffffffffffffff,%rdx
 33b:	mov    %rdx,0x48(%rsp)
 340:	movq   $0xffffffffffffffff,0x20(%rsp)
 349:	jmp    3f8 <botlish_fn_4+0x318>
 34e:	xor    %r10,%r10
 351:	mov    0x38(%rsp),%rdx
 356:	mov    %rdx,%r13
 359:	shl    $1,%r13
 35c:	or     $0x1,%r13
 360:	sar    $1,%r13
 363:	mov    %rdi,%r12
 366:	mov    %rdi,0x58(%rsp)
 36b:	mov    %rcx,0x70(%rsp)
 370:	jmp    318 <botlish_fn_4+0x238>
 375:	mov    0x58(%rsp),%rdi
 37a:	imul   $0x1f,%r10,%rax
 37e:	imul   $0x11,%rdi,%rcx
 382:	lea    (%rax,%rcx,1),%rdx
 386:	mov    %rdx,0x48(%rsp)
 38b:	mov    0x48(%rsp),%rax
 390:	imulq  0x351(%rip)        # 6e8 <botlish_fn_4+0x608>
 397:	mov    0x48(%rsp),%rax
 39c:	add    %rdx,%rax
 39f:	sar    $0x6,%rax
 3a3:	mov    %rax,%rcx
 3a6:	shr    $0x3f,%rcx
 3aa:	add    %rax,%rcx
 3ad:	mov    $0x65,%eax
 3b2:	imul   $0x65,%rcx,%rcx
 3b6:	mov    0x48(%rsp),%rdx
 3bb:	sub    %rcx,%rdx
 3be:	mov    %rdx,0x48(%rsp)
 3c3:	mov    %rax,%rcx
 3c6:	neg    %rcx
 3c9:	cmovs  %rax,%rcx
 3cd:	lea    (%rdx,%rcx,1),%rax
 3d1:	mov    0x48(%rsp),%r9
 3d6:	test   %r9,%rdx
 3d9:	cmovl  %rax,%rdx
 3dd:	mov    %rdx,0x48(%rsp)
 3e2:	shl    $1,%rdx
 3e5:	mov    %rdx,0x48(%rsp)
 3ea:	or     $0x1,%rdx
 3ee:	mov    %rdx,0x48(%rsp)
 3f3:	mov    %rdx,0x20(%rsp)
 3f8:	mov    %rdx,0x8(%rsp)
 3fd:	mov    0x48(%rsp),%rdx
 402:	mov    %rsi,%rax
 405:	and    %rdx,%rax
 408:	test   $0x1,%rax
 40e:	jne    423 <botlish_fn_4+0x343>
 414:	mov    0x48(%rsp),%rdx
 419:	mov    0x30(%rsp),%rdi
 41e:	jmp    447 <botlish_fn_4+0x367>
 423:	mov    0x48(%rsp),%rdx
 428:	lea    -0x1(%rdx),%rcx
 42c:	mov    %rsi,%rax
 42f:	add    %rcx,%rax
 432:	seto   %cl
 435:	test   %cl,%cl
 437:	je     44c <botlish_fn_4+0x36c>
 43d:	mov    0x48(%rsp),%rdx
 442:	mov    0x30(%rsp),%rdi
 447:	call   44c <botlish_fn_4+0x36c>
			448: R_X86_64_PLT32	rt_int_add-0x4
 44c:	mov    0x80(%rsp),%rbx
 454:	mov    0x88(%rsp),%r12
 45c:	mov    0x90(%rsp),%r13
 464:	mov    0x98(%rsp),%r14
 46c:	mov    0xa0(%rsp),%r15
 474:	add    $0xb0,%rsp
 47b:	mov    %rbp,%rsp
 47e:	pop    %rbp
 47f:	ret
 480:	mov    0x70(%rsp),%rcx
 485:	mov    %rbx,%rsi
 488:	mov    0x58(%rsp),%rdi
 48d:	mov    0x50(%rsp),%r15
 492:	movq   $0x1,0x8(%rsp)
 49b:	mov    0x10(%rsi),%rax
 49f:	mov    (%rax),%rsi
 4a2:	mov    %rsi,0x10(%rsp)
 4a7:	cmp    $0x1,%r15
 4ab:	je     55a <botlish_fn_4+0x47a>
 4b1:	cmp    $0xffffffffffffffff,%r15
 4b5:	jne    4cf <botlish_fn_4+0x3ef>
 4bb:	mov    0x48(%rsp),%rdx
 4c0:	mov    %rdi,0x58(%rsp)
 4c5:	mov    %rcx,0x70(%rsp)
 4ca:	jmp    653 <botlish_fn_4+0x573>
 4cf:	mov    $0xa,%esi
 4d4:	mov    0x30(%rsp),%rdi
 4d9:	call   4de <botlish_fn_4+0x3fe>
			4da: R_X86_64_PLT32	rt_co_resume0-0x4
 4de:	test   %rax,%rax
 4e1:	jne    4f1 <botlish_fn_4+0x411>
 4e7:	mov    0x30(%rsp),%rdi
 4ec:	jmp    513 <botlish_fn_4+0x433>
 4f1:	mov    0x30(%rsp),%rdi
 4f6:	mov    0x10(%rdi),%rsi
 4fa:	mov    (%rsi),%rdi
 4fd:	mov    0x20(%rsi),%rdx
 501:	mov    %rdi,%rsi
 504:	mov    0x30(%rsp),%rdi
 509:	call   50e <botlish_fn_4+0x42e>
			50a: R_X86_64_PLT32	rt_raise-0x4
 50e:	mov    0x30(%rsp),%rdi
 513:	mov    0x30(%rsp),%rdi
 518:	call   51d <botlish_fn_4+0x43d>
			519: R_X86_64_PLT32	rt_declared_error-0x4
 51d:	cmp    $0x40000001,%rax
 523:	xor    %rax,%rax
 526:	mov    0x80(%rsp),%rbx
 52e:	mov    0x88(%rsp),%r12
 536:	mov    0x90(%rsp),%r13
 53e:	mov    0x98(%rsp),%r14
 546:	mov    0xa0(%rsp),%r15
 54e:	add    $0xb0,%rsp
 555:	mov    %rbp,%rsp
 558:	pop    %rbp
 559:	ret
 55a:	add    $0x1,%r14
 561:	cmp    %r13,%r14
 564:	jl     5c5 <botlish_fn_4+0x4e5>
 56a:	add    $0x1,%r12
 571:	cmp    %rcx,%r12
 574:	mov    %rcx,0x70(%rsp)
 579:	jl     5a3 <botlish_fn_4+0x4c3>
 57f:	mov    $0xffffffffffffffff,%rdx
 586:	mov    %rdx,0x48(%rsp)
 58b:	movq   $0xffffffffffffffff,0x20(%rsp)
 594:	mov    0x48(%rsp),%r15
 599:	mov    %rdi,0x58(%rsp)
 59e:	jmp    653 <botlish_fn_4+0x573>
 5a3:	xor    %r14,%r14
 5a6:	mov    0x38(%rsp),%rdx
 5ab:	mov    %rdx,%r13
 5ae:	shl    $1,%r13
 5b1:	or     $0x1,%r13
 5b5:	sar    $1,%r13
 5b8:	mov    0x70(%rsp),%rcx
 5bd:	mov    %r12,%rdi
 5c0:	jmp    561 <botlish_fn_4+0x481>
 5c5:	mov    %rcx,0x70(%rsp)
 5ca:	imul   $0x1f,%r14,%rax
 5ce:	imul   $0x11,%rdi,%rcx
 5d2:	mov    %rdi,0x58(%rsp)
 5d7:	lea    (%rax,%rcx,1),%rdx
 5db:	mov    %rdx,0x48(%rsp)
 5e0:	mov    0x48(%rsp),%rax
 5e5:	imulq  0xfc(%rip)        # 6e8 <botlish_fn_4+0x608>
 5ec:	mov    0x48(%rsp),%rax
 5f1:	add    %rdx,%rax
 5f4:	sar    $0x6,%rax
 5f8:	mov    %rax,%rcx
 5fb:	shr    $0x3f,%rcx
 5ff:	add    %rax,%rcx
 602:	mov    $0x65,%eax
 607:	imul   $0x65,%rcx,%rcx
 60b:	mov    0x48(%rsp),%rdx
 610:	sub    %rcx,%rdx
 613:	mov    %rdx,0x48(%rsp)
 618:	mov    %rax,%rcx
 61b:	neg    %rcx
 61e:	cmovs  %rax,%rcx
 622:	lea    (%rdx,%rcx,1),%rax
 626:	mov    0x48(%rsp),%rcx
 62b:	test   %rcx,%rdx
 62e:	cmovl  %rax,%rdx
 632:	mov    %rdx,0x48(%rsp)
 637:	mov    $0x1,%r15d
 63d:	shl    $1,%rdx
 640:	mov    %rdx,0x48(%rsp)
 645:	or     $0x1,%rdx
 649:	mov    %rdx,0x48(%rsp)
 64e:	mov    %rdx,0x20(%rsp)
 653:	mov    %rdx,0x18(%rsp)
 658:	mov    0x48(%rsp),%rdx
 65d:	mov    %rsi,%rax
 660:	and    %rdx,%rax
 663:	test   $0x1,%rax
 669:	je     68c <botlish_fn_4+0x5ac>
 66f:	mov    0x48(%rsp),%rdx
 674:	add    $0xffffffffffffffff,%rdx
 67b:	mov    %rsi,%rcx
 67e:	add    %rdx,%rcx
 681:	seto   %al
 684:	test   %al,%al
 686:	je     69e <botlish_fn_4+0x5be>
 68c:	mov    0x48(%rsp),%rdx
 691:	mov    0x30(%rsp),%rdi
 696:	call   69b <botlish_fn_4+0x5bb>
			697: R_X86_64_PLT32	rt_int_add-0x4
 69b:	mov    %rax,%rcx
 69e:	mov    0x18(%rbx),%rax
 6a2:	test   %rax,%rax
 6a5:	je     6cd <botlish_fn_4+0x5ed>
 6ab:	mov    0x10(%rbx),%rax
 6af:	mov    %rcx,(%rax)
 6b2:	mov    0x60(%rsp),%rcx
 6b7:	add    $0x1,%rcx
 6be:	mov    0x68(%rsp),%rax
 6c3:	mov    %r15,0x50(%rsp)
 6c8:	jmp    29e <botlish_fn_4+0x1be>
 6cd:	mov    $0x1,%edx
 6d2:	mov    %rbx,%rsi
 6d5:	mov    0x30(%rsp),%rdi
 6da:	call   6df <botlish_fn_4+0x5ff>
			6db: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 6df:	jmp    6b2 <botlish_fn_4+0x5d2>
 6e4:	add    %al,(%rax)
 6e6:	add    %al,(%rax)
 6e8:	jae    6c1 <botlish_fn_4+0x5e1>
 6ea:	iret
 6eb:	(bad)
 6ec:	sub    %ebx,%eax
 6ee:	(bad)
 6ef:	.byte 0xa2

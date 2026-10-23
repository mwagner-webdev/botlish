<botlish_fn_2>:
 298:	push   %rbp
 299:	mov    %rsp,%rbp
 29c:	sub    $0x70,%rsp
 2a0:	mov    %rbx,0x40(%rsp)
 2a5:	mov    %r12,0x48(%rsp)
 2aa:	mov    %r13,0x50(%rsp)
 2af:	mov    %r14,0x58(%rsp)
 2b4:	mov    %r15,0x60(%rsp)
 2b9:	mov    %rdi,%r14
 2bc:	movq   $0x0,0x8(%rsp)
 2c5:	movq   $0x0,0x10(%rsp)
 2ce:	movq   $0x0,0x18(%rsp)
 2d7:	movq   $0x0,0x20(%rsp)
 2e0:	mov    $0x1,%ecx
 2e5:	mov    %rsi,%rax
 2e8:	shl    $1,%rax
 2eb:	mov    %rsi,%r12
 2ee:	or     $0x1,%rax
 2f2:	mov    %rax,(%rsp)
 2f6:	lea    0x28(%rsp),%r8
 2fb:	mov    %rax,0x28(%rsp)
 300:	mov    $0x3,%esi
 305:	mov    0x0(%rip),%rdx        # 30c <botlish_fn_2+0x74>
			308: R_X86_64_GOTPCREL	botlish_entry_3-0x4
 30c:	mov    %r14,%rdi
 30f:	call   314 <botlish_fn_2+0x7c>
			310: R_X86_64_PLT32	rt_closure_new-0x4
 314:	mov    %rax,(%rsp)
 318:	mov    %rax,%rsi
 31b:	mov    %r14,%rdi
 31e:	call   323 <botlish_fn_2+0x8b>
			31f: R_X86_64_PLT32	rt_co_create-0x4
 323:	mov    %rax,%r15
 326:	mov    %rax,(%rsp)
 32a:	mov    %r15,%rsi
 32d:	mov    %r14,%rdi
 330:	call   335 <botlish_fn_2+0x9d>
			331: R_X86_64_PLT32	rt_co_start-0x4
 335:	test   %rax,%rax
 338:	je     475 <botlish_fn_2+0x1dd>
 33e:	mov    %rax,0x8(%rsp)
 343:	mov    %rax,%rdx
 346:	mov    $0x3,%esi
 34b:	movq   $0x3,0x10(%rsp)
 354:	mov    %r14,%rdi
 357:	call   35c <botlish_fn_2+0xc4>
			358: R_X86_64_PLT32	rt_mutarray_create-0x4
 35c:	test   %rax,%rax
 35f:	je     475 <botlish_fn_2+0x1dd>
 365:	mov    %rax,0x8(%rsp)
 36a:	mov    $0x1,%ebx
 36f:	cmp    %r12,%rbx
 372:	jl     425 <botlish_fn_2+0x18d>
 378:	mov    %rax,%r13
 37b:	mov    0x10(%r13),%rdx
 37f:	mov    (%rdx),%rsi
 382:	mov    %rsi,0x8(%rsp)
 387:	mov    %rsi,%rbx
 38a:	mov    %r15,%rsi
 38d:	mov    %r14,%rdi
 390:	call   395 <botlish_fn_2+0xfd>
			391: R_X86_64_PLT32	rt_co_resume0-0x4
 395:	test   %rax,%rax
 398:	je     475 <botlish_fn_2+0x1dd>
 39e:	mov    %rax,0x10(%rsp)
 3a3:	mov    %rbx,%rsi
 3a6:	mov    %rsi,%r8
 3a9:	and    %rax,%r8
 3ac:	test   $0x1,%r8
 3b3:	jne    3c1 <botlish_fn_2+0x129>
 3b9:	mov    %rax,%rdx
 3bc:	jmp    3e7 <botlish_fn_2+0x14f>
 3c1:	lea    -0x1(%rax),%r11
 3c5:	mov    %rax,%rdx
 3c8:	mov    %rsi,%rax
 3cb:	add    %r11,%rax
 3ce:	seto   %cl
 3d1:	test   %cl,%cl
 3d3:	jne    3e7 <botlish_fn_2+0x14f>
 3d9:	mov    %r15,%rsi
 3dc:	mov    %r14,%rdi
 3df:	mov    %rax,%r12
 3e2:	jmp    3f8 <botlish_fn_2+0x160>
 3e7:	mov    %r14,%rdi
 3ea:	call   3ef <botlish_fn_2+0x157>
			3eb: R_X86_64_PLT32	rt_int_add-0x4
 3ef:	mov    %rax,%r12
 3f2:	mov    %r15,%rsi
 3f5:	mov    %r14,%rdi
 3f8:	mov    %r14,%rdi
 3fb:	call   400 <botlish_fn_2+0x168>
			3fc: R_X86_64_PLT32	rt_co_release-0x4
 400:	mov    %r12,%rax
 403:	mov    0x40(%rsp),%rbx
 408:	mov    0x48(%rsp),%r12
 40d:	mov    0x50(%rsp),%r13
 412:	mov    0x58(%rsp),%r14
 417:	mov    0x60(%rsp),%r15
 41c:	add    $0x70,%rsp
 420:	mov    %rbp,%rsp
 423:	pop    %rbp
 424:	ret
 425:	mov    %rax,%r13
 428:	movq   $0x1,0x10(%rsp)
 431:	mov    0x10(%r13),%rax
 435:	mov    (%rax),%rsi
 438:	mov    %rsi,0x18(%rsp)
 43d:	mov    %rsi,0x30(%rsp)
 442:	mov    %r15,%rsi
 445:	mov    %r14,%rdi
 448:	call   44d <botlish_fn_2+0x1b5>
			449: R_X86_64_PLT32	rt_co_resume0-0x4
 44d:	test   %rax,%rax
 450:	jne    49a <botlish_fn_2+0x202>
 456:	mov    %r14,%rdi
 459:	call   45e <botlish_fn_2+0x1c6>
			45a: R_X86_64_PLT32	rt_declared_error-0x4
 45e:	cmp    $0x40000001,%rax
 464:	jne    475 <botlish_fn_2+0x1dd>
 46a:	mov    %r15,%rsi
 46d:	mov    %r14,%rdi
 470:	call   475 <botlish_fn_2+0x1dd>
			471: R_X86_64_PLT32	rt_co_release-0x4
 475:	xor    %rax,%rax
 478:	mov    0x40(%rsp),%rbx
 47d:	mov    0x48(%rsp),%r12
 482:	mov    0x50(%rsp),%r13
 487:	mov    0x58(%rsp),%r14
 48c:	mov    0x60(%rsp),%r15
 491:	add    $0x70,%rsp
 495:	mov    %rbp,%rsp
 498:	pop    %rbp
 499:	ret
 49a:	mov    %rax,0x20(%rsp)
 49f:	mov    0x30(%rsp),%rsi
 4a4:	mov    %rsi,%rcx
 4a7:	and    %rax,%rcx
 4aa:	test   $0x1,%rcx
 4b1:	jne    4bf <botlish_fn_2+0x227>
 4b7:	mov    %rax,%rdx
 4ba:	jmp    4da <botlish_fn_2+0x242>
 4bf:	lea    -0x1(%rax),%rdx
 4c3:	mov    %rax,%rdi
 4c6:	mov    %rsi,%rcx
 4c9:	add    %rdx,%rcx
 4cc:	seto   %al
 4cf:	test   %al,%al
 4d1:	je     4e5 <botlish_fn_2+0x24d>
 4d7:	mov    %rdi,%rdx
 4da:	mov    %r14,%rdi
 4dd:	call   4e2 <botlish_fn_2+0x24a>
			4de: R_X86_64_PLT32	rt_int_add-0x4
 4e2:	mov    %rax,%rcx
 4e5:	mov    0x18(%r13),%rax
 4e9:	test   %rax,%rax
 4ec:	je     508 <botlish_fn_2+0x270>
 4f2:	mov    0x10(%r13),%rax
 4f6:	mov    %rcx,(%rax)
 4f9:	add    $0x1,%rbx
 500:	mov    %r13,%rax
 503:	jmp    36f <botlish_fn_2+0xd7>
 508:	mov    $0x1,%edx
 50d:	mov    %r13,%rsi
 510:	mov    %r14,%rdi
 513:	call   518 <botlish_fn_2+0x280>
			514: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 518:	jmp    4f9 <botlish_fn_2+0x261>

<botlish_fn_2>:
 2e8:	push   %rbp
 2e9:	mov    %rsp,%rbp
 2ec:	sub    $0x70,%rsp
 2f0:	mov    %rbx,0x40(%rsp)
 2f5:	mov    %r12,0x48(%rsp)
 2fa:	mov    %r13,0x50(%rsp)
 2ff:	mov    %r14,0x58(%rsp)
 304:	mov    %r15,0x60(%rsp)
 309:	mov    %rdi,%r14
 30c:	movq   $0x0,0x8(%rsp)
 315:	movq   $0x0,0x10(%rsp)
 31e:	movq   $0x0,0x18(%rsp)
 327:	movq   $0x0,0x20(%rsp)
 330:	mov    $0x1,%ecx
 335:	mov    %rsi,%rax
 338:	shl    $1,%rax
 33b:	mov    %rsi,%r12
 33e:	or     $0x1,%rax
 342:	mov    %rax,(%rsp)
 346:	lea    0x28(%rsp),%r8
 34b:	mov    %rax,0x28(%rsp)
 350:	mov    $0x3,%esi
 355:	mov    0x0(%rip),%rdx        # 35c <botlish_fn_2+0x74>
			358: R_X86_64_GOTPCREL	botlish_entry_3-0x4
 35c:	mov    %r14,%rdi
 35f:	call   364 <botlish_fn_2+0x7c>
			360: R_X86_64_PLT32	rt_closure_new-0x4
 364:	mov    %rax,(%rsp)
 368:	mov    %rax,%rsi
 36b:	mov    %r14,%rdi
 36e:	call   373 <botlish_fn_2+0x8b>
			36f: R_X86_64_PLT32	rt_co_create-0x4
 373:	mov    %rax,%r15
 376:	mov    %rax,(%rsp)
 37a:	mov    %r15,%rsi
 37d:	mov    %r14,%rdi
 380:	call   385 <botlish_fn_2+0x9d>
			381: R_X86_64_PLT32	rt_co_start-0x4
 385:	test   %rax,%rax
 388:	je     4c4 <botlish_fn_2+0x1dc>
 38e:	mov    $0x3,%esi
 393:	movq   $0x3,0x8(%rsp)
 39c:	mov    0x18(%rax),%rax
 3a0:	mov    (%rax),%rdx
 3a3:	mov    %rdx,0x10(%rsp)
 3a8:	mov    %r14,%rdi
 3ab:	call   3b0 <botlish_fn_2+0xc8>
			3ac: R_X86_64_PLT32	rt_mutarray_create-0x4
 3b0:	test   %rax,%rax
 3b3:	je     4c4 <botlish_fn_2+0x1dc>
 3b9:	mov    %rax,0x8(%rsp)
 3be:	mov    $0x1,%ebx
 3c3:	cmp    %r12,%rbx
 3c6:	jl     474 <botlish_fn_2+0x18c>
 3cc:	mov    %rax,%r13
 3cf:	mov    0x10(%r13),%r8
 3d3:	mov    (%r8),%rsi
 3d6:	mov    %rsi,0x8(%rsp)
 3db:	mov    %rsi,%rbx
 3de:	mov    %r15,%rsi
 3e1:	mov    %r14,%rdi
 3e4:	call   3e9 <botlish_fn_2+0x101>
			3e5: R_X86_64_PLT32	rt_co_resume0-0x4
 3e9:	test   %rax,%rax
 3ec:	je     4c4 <botlish_fn_2+0x1dc>
 3f2:	mov    0x18(%rax),%rax
 3f6:	mov    (%rax),%rdx
 3f9:	mov    %rdx,0x10(%rsp)
 3fe:	mov    %rbx,%rsi
 401:	mov    %rsi,%rax
 404:	and    %rdx,%rax
 407:	test   $0x1,%rax
 40d:	je     436 <botlish_fn_2+0x14e>
 413:	lea    -0x1(%rdx),%rcx
 417:	mov    %rsi,%rax
 41a:	add    %rcx,%rax
 41d:	seto   %cl
 420:	test   %cl,%cl
 422:	jne    436 <botlish_fn_2+0x14e>
 428:	mov    %r15,%rsi
 42b:	mov    %r14,%rdi
 42e:	mov    %rax,%r12
 431:	jmp    447 <botlish_fn_2+0x15f>
 436:	mov    %r14,%rdi
 439:	call   43e <botlish_fn_2+0x156>
			43a: R_X86_64_PLT32	rt_int_add-0x4
 43e:	mov    %rax,%r12
 441:	mov    %r15,%rsi
 444:	mov    %r14,%rdi
 447:	mov    %r14,%rdi
 44a:	call   44f <botlish_fn_2+0x167>
			44b: R_X86_64_PLT32	rt_co_release-0x4
 44f:	mov    %r12,%rax
 452:	mov    0x40(%rsp),%rbx
 457:	mov    0x48(%rsp),%r12
 45c:	mov    0x50(%rsp),%r13
 461:	mov    0x58(%rsp),%r14
 466:	mov    0x60(%rsp),%r15
 46b:	add    $0x70,%rsp
 46f:	mov    %rbp,%rsp
 472:	pop    %rbp
 473:	ret
 474:	mov    %rax,%r13
 477:	movq   $0x1,0x10(%rsp)
 480:	mov    0x10(%r13),%rax
 484:	mov    (%rax),%rsi
 487:	mov    %rsi,0x18(%rsp)
 48c:	mov    %rsi,0x30(%rsp)
 491:	mov    %r15,%rsi
 494:	mov    %r14,%rdi
 497:	call   49c <botlish_fn_2+0x1b4>
			498: R_X86_64_PLT32	rt_co_resume0-0x4
 49c:	test   %rax,%rax
 49f:	jne    4e9 <botlish_fn_2+0x201>
 4a5:	mov    %r14,%rdi
 4a8:	call   4ad <botlish_fn_2+0x1c5>
			4a9: R_X86_64_PLT32	rt_declared_error-0x4
 4ad:	cmp    $0x40000001,%rax
 4b3:	jne    4c4 <botlish_fn_2+0x1dc>
 4b9:	mov    %r15,%rsi
 4bc:	mov    %r14,%rdi
 4bf:	call   4c4 <botlish_fn_2+0x1dc>
			4c0: R_X86_64_PLT32	rt_co_release-0x4
 4c4:	xor    %rax,%rax
 4c7:	mov    0x40(%rsp),%rbx
 4cc:	mov    0x48(%rsp),%r12
 4d1:	mov    0x50(%rsp),%r13
 4d6:	mov    0x58(%rsp),%r14
 4db:	mov    0x60(%rsp),%r15
 4e0:	add    $0x70,%rsp
 4e4:	mov    %rbp,%rsp
 4e7:	pop    %rbp
 4e8:	ret
 4e9:	mov    0x18(%rax),%rax
 4ed:	mov    (%rax),%rdx
 4f0:	mov    %rdx,0x20(%rsp)
 4f5:	mov    0x30(%rsp),%rsi
 4fa:	mov    %rsi,%rax
 4fd:	and    %rdx,%rax
 500:	test   $0x1,%rax
 506:	je     521 <botlish_fn_2+0x239>
 50c:	lea    -0x1(%rdx),%rax
 510:	mov    %rsi,%rcx
 513:	add    %rax,%rcx
 516:	seto   %al
 519:	test   %al,%al
 51b:	je     52c <botlish_fn_2+0x244>
 521:	mov    %r14,%rdi
 524:	call   529 <botlish_fn_2+0x241>
			525: R_X86_64_PLT32	rt_int_add-0x4
 529:	mov    %rax,%rcx
 52c:	mov    0x18(%r13),%rax
 530:	test   %rax,%rax
 533:	je     54f <botlish_fn_2+0x267>
 539:	mov    0x10(%r13),%rax
 53d:	mov    %rcx,(%rax)
 540:	add    $0x1,%rbx
 547:	mov    %r13,%rax
 54a:	jmp    3c3 <botlish_fn_2+0xdb>
 54f:	mov    $0x1,%edx
 554:	mov    %r13,%rsi
 557:	mov    %r14,%rdi
 55a:	call   55f <botlish_fn_2+0x277>
			55b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 55f:	jmp    540 <botlish_fn_2+0x258>

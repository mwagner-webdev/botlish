<botlish_fn_4>:
 241:	push   %rbp
 242:	mov    %rsp,%rbp
 245:	sub    $0x70,%rsp
 249:	mov    %rbx,0x40(%rsp)
 24e:	mov    %r12,0x48(%rsp)
 253:	mov    %r13,0x50(%rsp)
 258:	mov    %r14,0x58(%rsp)
 25d:	mov    %r15,0x60(%rsp)
 262:	mov    %rdi,%r14
 265:	movq   $0x0,0x10(%rsp)
 26e:	movq   $0x0,0x18(%rsp)
 277:	movq   $0x0,0x20(%rsp)
 280:	mov    %rsi,%rax
 283:	shl    $1,%rax
 286:	mov    %rsi,%r12
 289:	or     $0x1,%rax
 28d:	mov    %rax,(%rsp)
 291:	mov    %rdx,%rcx
 294:	shl    $1,%rcx
 297:	mov    %rdx,%r13
 29a:	or     $0x1,%rcx
 29e:	mov    %rcx,0x8(%rsp)
 2a3:	lea    0x28(%rsp),%r8
 2a8:	mov    %rax,0x28(%rsp)
 2ad:	mov    %rcx,0x30(%rsp)
 2b2:	mov    $0x5,%esi
 2b7:	mov    0x0(%rip),%rdx        # 2be <botlish_fn_4+0x7d>
			2ba: R_X86_64_GOTPCREL	botlish_entry_5-0x4
 2be:	mov    $0x2,%ecx
 2c3:	mov    %r14,%rdi
 2c6:	call   2cb <botlish_fn_4+0x8a>
			2c7: R_X86_64_PLT32	rt_closure_new-0x4
 2cb:	mov    %rax,(%rsp)
 2cf:	mov    %rax,%rsi
 2d2:	mov    %r14,%rdi
 2d5:	call   2da <botlish_fn_4+0x99>
			2d6: R_X86_64_PLT32	rt_co_create-0x4
 2da:	mov    %rax,%r15
 2dd:	mov    %rax,(%rsp)
 2e1:	mov    %r15,%rsi
 2e4:	mov    %r14,%rdi
 2e7:	call   2ec <botlish_fn_4+0xab>
			2e8: R_X86_64_PLT32	rt_co_start-0x4
 2ec:	test   %rax,%rax
 2ef:	je     433 <botlish_fn_4+0x1f2>
 2f5:	mov    %rax,0x8(%rsp)
 2fa:	mov    %rax,%rdx
 2fd:	mov    $0x3,%esi
 302:	movq   $0x3,0x10(%rsp)
 30b:	mov    %r14,%rdi
 30e:	call   313 <botlish_fn_4+0xd2>
			30f: R_X86_64_PLT32	rt_mutarray_create-0x4
 313:	test   %rax,%rax
 316:	je     433 <botlish_fn_4+0x1f2>
 31c:	mov    %rax,0x8(%rsp)
 321:	mov    $0x1,%ebx
 326:	mov    %r13,%rdx
 329:	imul   %rdx,%r12
 32d:	cmp    %r12,%rbx
 330:	jl     3e3 <botlish_fn_4+0x1a2>
 336:	mov    %rax,%r13
 339:	mov    0x10(%r13),%rdi
 33d:	mov    (%rdi),%rsi
 340:	mov    %rsi,0x8(%rsp)
 345:	mov    %rsi,%rbx
 348:	mov    %r15,%rsi
 34b:	mov    %r14,%rdi
 34e:	call   353 <botlish_fn_4+0x112>
			34f: R_X86_64_PLT32	rt_co_resume0-0x4
 353:	test   %rax,%rax
 356:	je     433 <botlish_fn_4+0x1f2>
 35c:	mov    %rax,0x10(%rsp)
 361:	mov    %rbx,%rsi
 364:	mov    %rsi,%rcx
 367:	and    %rax,%rcx
 36a:	test   $0x1,%rcx
 371:	jne    37f <botlish_fn_4+0x13e>
 377:	mov    %rax,%rdx
 37a:	jmp    3a5 <botlish_fn_4+0x164>
 37f:	lea    -0x1(%rax),%rcx
 383:	mov    %rax,%rdx
 386:	mov    %rsi,%rax
 389:	add    %rcx,%rax
 38c:	seto   %cl
 38f:	test   %cl,%cl
 391:	jne    3a5 <botlish_fn_4+0x164>
 397:	mov    %r15,%rsi
 39a:	mov    %r14,%rdi
 39d:	mov    %rax,%r13
 3a0:	jmp    3b6 <botlish_fn_4+0x175>
 3a5:	mov    %r14,%rdi
 3a8:	call   3ad <botlish_fn_4+0x16c>
			3a9: R_X86_64_PLT32	rt_int_add-0x4
 3ad:	mov    %rax,%r13
 3b0:	mov    %r15,%rsi
 3b3:	mov    %r14,%rdi
 3b6:	mov    %r14,%rdi
 3b9:	call   3be <botlish_fn_4+0x17d>
			3ba: R_X86_64_PLT32	rt_co_release-0x4
 3be:	mov    %r13,%rax
 3c1:	mov    0x40(%rsp),%rbx
 3c6:	mov    0x48(%rsp),%r12
 3cb:	mov    0x50(%rsp),%r13
 3d0:	mov    0x58(%rsp),%r14
 3d5:	mov    0x60(%rsp),%r15
 3da:	add    $0x70,%rsp
 3de:	mov    %rbp,%rsp
 3e1:	pop    %rbp
 3e2:	ret
 3e3:	mov    %rax,%r13
 3e6:	movq   $0x1,0x10(%rsp)
 3ef:	mov    0x10(%r13),%rax
 3f3:	mov    (%rax),%rsi
 3f6:	mov    %rsi,0x18(%rsp)
 3fb:	mov    %rsi,0x38(%rsp)
 400:	mov    %r15,%rsi
 403:	mov    %r14,%rdi
 406:	call   40b <botlish_fn_4+0x1ca>
			407: R_X86_64_PLT32	rt_co_resume0-0x4
 40b:	test   %rax,%rax
 40e:	jne    458 <botlish_fn_4+0x217>
 414:	mov    %r14,%rdi
 417:	call   41c <botlish_fn_4+0x1db>
			418: R_X86_64_PLT32	rt_declared_error-0x4
 41c:	cmp    $0x40000001,%rax
 422:	jne    433 <botlish_fn_4+0x1f2>
 428:	mov    %r15,%rsi
 42b:	mov    %r14,%rdi
 42e:	call   433 <botlish_fn_4+0x1f2>
			42f: R_X86_64_PLT32	rt_co_release-0x4
 433:	xor    %rax,%rax
 436:	mov    0x40(%rsp),%rbx
 43b:	mov    0x48(%rsp),%r12
 440:	mov    0x50(%rsp),%r13
 445:	mov    0x58(%rsp),%r14
 44a:	mov    0x60(%rsp),%r15
 44f:	add    $0x70,%rsp
 453:	mov    %rbp,%rsp
 456:	pop    %rbp
 457:	ret
 458:	mov    %rax,0x20(%rsp)
 45d:	mov    0x38(%rsp),%rsi
 462:	mov    %rsi,%rcx
 465:	and    %rax,%rcx
 468:	test   $0x1,%rcx
 46f:	jne    47d <botlish_fn_4+0x23c>
 475:	mov    %rax,%rdx
 478:	jmp    498 <botlish_fn_4+0x257>
 47d:	lea    -0x1(%rax),%rdx
 481:	mov    %rax,%rdi
 484:	mov    %rsi,%rcx
 487:	add    %rdx,%rcx
 48a:	seto   %al
 48d:	test   %al,%al
 48f:	je     4a3 <botlish_fn_4+0x262>
 495:	mov    %rdi,%rdx
 498:	mov    %r14,%rdi
 49b:	call   4a0 <botlish_fn_4+0x25f>
			49c: R_X86_64_PLT32	rt_int_add-0x4
 4a0:	mov    %rax,%rcx
 4a3:	mov    0x18(%r13),%rax
 4a7:	test   %rax,%rax
 4aa:	je     4c6 <botlish_fn_4+0x285>
 4b0:	mov    0x10(%r13),%rax
 4b4:	mov    %rcx,(%rax)
 4b7:	add    $0x1,%rbx
 4be:	mov    %r13,%rax
 4c1:	jmp    32d <botlish_fn_4+0xec>
 4c6:	mov    $0x1,%edx
 4cb:	mov    %r13,%rsi
 4ce:	mov    %r14,%rdi
 4d1:	call   4d6 <botlish_fn_4+0x295>
			4d2: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 4d6:	jmp    4b7 <botlish_fn_4+0x276>

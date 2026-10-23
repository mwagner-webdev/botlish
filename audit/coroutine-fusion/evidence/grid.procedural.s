<botlish_fn_2>:
 203:	push   %rbp
 204:	mov    %rsp,%rbp
 207:	sub    $0x60,%rsp
 20b:	mov    %rbx,0x30(%rsp)
 210:	mov    %r12,0x38(%rsp)
 215:	mov    %r13,0x40(%rsp)
 21a:	mov    %r14,0x48(%rsp)
 21f:	mov    %r15,0x50(%rsp)
 224:	mov    %rdx,%r12
 227:	mov    %rdi,%r14
 22a:	mov    %rsi,%r15
 22d:	movq   $0x0,0x10(%rsp)
 236:	movq   $0x0,0x18(%rsp)
 23f:	mov    $0x3,%esi
 244:	movq   $0x3,(%rsp)
 24c:	mov    $0x1,%edx
 251:	movq   $0x1,0x8(%rsp)
 25a:	mov    %r14,%rdi
 25d:	call   262 <botlish_fn_2+0x5f>
			25e: R_X86_64_PLT32	rt_mutarray_create-0x4
 262:	test   %rax,%rax
 265:	je     31e <botlish_fn_2+0x11b>
 26b:	mov    %rax,(%rsp)
 26f:	xor    %rbx,%rbx
 272:	cmp    %r12,%rbx
 275:	jl     2ea <botlish_fn_2+0xe7>
 27b:	mov    %rax,%r13
 27e:	mov    0x10(%r13),%rax
 282:	mov    (%rax),%rsi
 285:	mov    %rsi,(%rsp)
 289:	mov    $0xffffffffffffffff,%rdx
 290:	movq   $0xffffffffffffffff,0x8(%rsp)
 299:	test   $0x1,%rsi
 2a0:	jne    2ae <botlish_fn_2+0xab>
 2a6:	mov    %r14,%rdi
 2a9:	jmp    2c3 <botlish_fn_2+0xc0>
 2ae:	mov    %rsi,%rax
 2b1:	add    $0xfffffffffffffffe,%rax
 2b5:	seto   %cl
 2b8:	test   %cl,%cl
 2ba:	je     2c8 <botlish_fn_2+0xc5>
 2c0:	mov    %r14,%rdi
 2c3:	call   2c8 <botlish_fn_2+0xc5>
			2c4: R_X86_64_PLT32	rt_int_add-0x4
 2c8:	mov    0x30(%rsp),%rbx
 2cd:	mov    0x38(%rsp),%r12
 2d2:	mov    0x40(%rsp),%r13
 2d7:	mov    0x48(%rsp),%r14
 2dc:	mov    0x50(%rsp),%r15
 2e1:	add    $0x60,%rsp
 2e5:	mov    %rbp,%rsp
 2e8:	pop    %rbp
 2e9:	ret
 2ea:	mov    %rax,%r13
 2ed:	movq   $0x1,0x8(%rsp)
 2f6:	mov    0x10(%r13),%rax
 2fa:	mov    (%rax),%rsi
 2fd:	mov    %rsi,0x10(%rsp)
 302:	mov    %rsi,0x20(%rsp)
 307:	mov    %r15,%rdx
 30a:	mov    %rbx,%rsi
 30d:	mov    %r14,%rdi
 310:	call   315 <botlish_fn_2+0x112>
			311: R_X86_64_PLT32	botlish_fn_1-0x4
 315:	test   %rax,%rax
 318:	jne    343 <botlish_fn_2+0x140>
 31e:	xor    %rax,%rax
 321:	mov    0x30(%rsp),%rbx
 326:	mov    0x38(%rsp),%r12
 32b:	mov    0x40(%rsp),%r13
 330:	mov    0x48(%rsp),%r14
 335:	mov    0x50(%rsp),%r15
 33a:	add    $0x60,%rsp
 33e:	mov    %rbp,%rsp
 341:	pop    %rbp
 342:	ret
 343:	mov    %rax,0x18(%rsp)
 348:	mov    0x20(%rsp),%rsi
 34d:	mov    %rsi,%rcx
 350:	and    %rax,%rcx
 353:	test   $0x1,%rcx
 35a:	jne    368 <botlish_fn_2+0x165>
 360:	mov    %rax,%rdx
 363:	jmp    382 <botlish_fn_2+0x17f>
 368:	lea    -0x1(%rax),%rdi
 36c:	mov    %rax,%rdx
 36f:	mov    %rsi,%rcx
 372:	add    %rdi,%rcx
 375:	seto   %dil
 379:	test   %dil,%dil
 37c:	je     38d <botlish_fn_2+0x18a>
 382:	mov    %r14,%rdi
 385:	call   38a <botlish_fn_2+0x187>
			386: R_X86_64_PLT32	rt_int_add-0x4
 38a:	mov    %rax,%rcx
 38d:	mov    0x18(%r13),%r8
 391:	test   %r8,%r8
 394:	je     3b0 <botlish_fn_2+0x1ad>
 39a:	mov    0x10(%r13),%r11
 39e:	mov    %rcx,(%r11)
 3a1:	add    $0x1,%rbx
 3a8:	mov    %r13,%rax
 3ab:	jmp    272 <botlish_fn_2+0x6f>
 3b0:	mov    $0x1,%edx
 3b5:	mov    %r13,%rsi
 3b8:	mov    %r14,%rdi
 3bb:	call   3c0 <botlish_fn_2+0x1bd>
			3bc: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 3c0:	jmp    3a1 <botlish_fn_2+0x19e>

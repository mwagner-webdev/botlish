<botlish_fn_1>:
  38:	push   %rbp
  39:	mov    %rsp,%rbp
  3c:	sub    $0x60,%rsp
  40:	mov    %rbx,0x30(%rsp)
  45:	mov    %r12,0x38(%rsp)
  4a:	mov    %r13,0x40(%rsp)
  4f:	mov    %r14,0x48(%rsp)
  54:	mov    %r15,0x50(%rsp)
  59:	mov    %rsi,%r15
  5c:	mov    %rdi,0x28(%rsp)
  61:	movq   $0x0,0x10(%rsp)
  6a:	movq   $0x0,0x18(%rsp)
  73:	movq   $0x0,0x20(%rsp)
  7c:	mov    $0x3,%esi
  81:	movq   $0x3,(%rsp)
  89:	mov    $0x55,%edx
  8e:	movq   $0x55,0x8(%rsp)
  97:	mov    0x28(%rsp),%rdi
  9c:	call   a1 <botlish_fn_1+0x69>
			9d: R_X86_64_PLT32	rt_mutarray_create-0x4
  a1:	test   %rax,%rax
  a4:	je     e0 <botlish_fn_1+0xa8>
  aa:	mov    %rax,(%rsp)
  ae:	mov    %rax,%r13
  b1:	mov    $0x3,%esi
  b6:	movq   $0x3,0x8(%rsp)
  bf:	mov    $0x1,%edx
  c4:	movq   $0x1,0x10(%rsp)
  cd:	mov    0x28(%rsp),%rdi
  d2:	call   d7 <botlish_fn_1+0x9f>
			d3: R_X86_64_PLT32	rt_mutarray_create-0x4
  d7:	test   %rax,%rax
  da:	jne    105 <botlish_fn_1+0xcd>
  e0:	xor    %rax,%rax
  e3:	mov    0x30(%rsp),%rbx
  e8:	mov    0x38(%rsp),%r12
  ed:	mov    0x40(%rsp),%r13
  f2:	mov    0x48(%rsp),%r14
  f7:	mov    0x50(%rsp),%r15
  fc:	add    $0x60,%rsp
 100:	mov    %rbp,%rsp
 103:	pop    %rbp
 104:	ret
 105:	mov    %rax,0x8(%rsp)
 10a:	xor    %rbx,%rbx
 10d:	mov    %r15,%r12
 110:	cmp    %r12,%rbx
 113:	jl     18c <botlish_fn_1+0x154>
 119:	mov    %rax,%r13
 11c:	mov    0x10(%r13),%rax
 120:	mov    (%rax),%rsi
 123:	mov    %rsi,(%rsp)
 127:	mov    $0xffffffffffffffff,%rdx
 12e:	movq   $0xffffffffffffffff,0x8(%rsp)
 137:	test   $0x1,%rsi
 13e:	jne    14e <botlish_fn_1+0x116>
 144:	mov    0x28(%rsp),%rdi
 149:	jmp    165 <botlish_fn_1+0x12d>
 14e:	mov    %rsi,%rax
 151:	add    $0xfffffffffffffffe,%rax
 155:	seto   %cl
 158:	test   %cl,%cl
 15a:	je     16a <botlish_fn_1+0x132>
 160:	mov    0x28(%rsp),%rdi
 165:	call   16a <botlish_fn_1+0x132>
			166: R_X86_64_PLT32	rt_int_add-0x4
 16a:	mov    0x30(%rsp),%rbx
 16f:	mov    0x38(%rsp),%r12
 174:	mov    0x40(%rsp),%r13
 179:	mov    0x48(%rsp),%r14
 17e:	mov    0x50(%rsp),%r15
 183:	add    $0x60,%rsp
 187:	mov    %rbp,%rsp
 18a:	pop    %rbp
 18b:	ret
 18c:	mov    %r13,%r14
 18f:	mov    %rax,%r13
 192:	mov    0x10(%r14),%rax
 196:	mov    (%rax),%rsi
 199:	mov    %rsi,0x10(%rsp)
 19e:	mov    $0x838c9cdb,%eax
 1a3:	mov    %rax,0x18(%rsp)
 1a8:	test   $0x1,%rsi
 1af:	je     1d9 <botlish_fn_1+0x1a1>
 1b5:	mov    %rsi,%rax
 1b8:	sar    $1,%rax
 1bb:	imulq  0x1be(%rip)        # 380 <botlish_fn_1+0x348>
 1c2:	seto   %cl
 1c5:	or     $0x1,%rax
 1c9:	test   %cl,%cl
 1cb:	jne    1d9 <botlish_fn_1+0x1a1>
 1d1:	mov    %rax,%r8
 1d4:	jmp    1eb <botlish_fn_1+0x1b3>
 1d9:	mov    $0x838c9cdb,%edx
 1de:	mov    0x28(%rsp),%rdi
 1e3:	call   1e8 <botlish_fn_1+0x1b0>
			1e4: R_X86_64_PLT32	rt_int_mul-0x4
 1e8:	mov    %rax,%r8
 1eb:	mov    %r8,0x10(%rsp)
 1f0:	movq   $0x6073,0x18(%rsp)
 1f9:	test   $0x1,%r8
 200:	jne    20e <botlish_fn_1+0x1d6>
 206:	mov    %r8,%rcx
 209:	jmp    226 <botlish_fn_1+0x1ee>
 20e:	mov    %r8,%rsi
 211:	add    $0x6072,%rsi
 218:	mov    %r8,%rcx
 21b:	seto   %al
 21e:	test   %al,%al
 220:	je     23b <botlish_fn_1+0x203>
 226:	mov    $0x6073,%edx
 22b:	mov    %rcx,%rsi
 22e:	mov    0x28(%rsp),%rdi
 233:	call   238 <botlish_fn_1+0x200>
			234: R_X86_64_PLT32	rt_int_add-0x4
 238:	mov    %rax,%rsi
 23b:	mov    %rsi,0x10(%rsp)
 240:	mov    $0xffffffff,%eax
 245:	mov    %rax,0x18(%rsp)
 24a:	test   $0x1,%rsi
 251:	jne    26b <botlish_fn_1+0x233>
 257:	mov    $0xffffffff,%edx
 25c:	mov    0x28(%rsp),%rdi
 261:	call   266 <botlish_fn_1+0x22e>
			262: R_X86_64_PLT32	rt_int_and-0x4
 266:	jmp    275 <botlish_fn_1+0x23d>
 26b:	and    0x116(%rip),%rsi        # 388 <botlish_fn_1+0x350>
 272:	mov    %rsi,%rax
 275:	mov    0x18(%r14),%rsi
 279:	test   %rsi,%rsi
 27c:	je     34b <botlish_fn_1+0x313>
 282:	mov    %rax,%r15
 285:	mov    0x10(%r14),%r8
 289:	mov    %r15,(%r8)
 28c:	movq   $0x1,0x10(%rsp)
 295:	mov    0x10(%r13),%r11
 299:	mov    (%r11),%rsi
 29c:	mov    %rsi,0x18(%rsp)
 2a1:	sar    $1,%r15
 2a4:	mov    %r15,%rax
 2a7:	imulq  0xe2(%rip)        # 390 <botlish_fn_1+0x358>
 2ae:	sar    $0x7,%rdx
 2b2:	mov    %rdx,%r11
 2b5:	shr    $0x3f,%r11
 2b9:	lea    (%rdx,%r11,1),%rax
 2bd:	mov    $0x3e8,%r11d
 2c3:	imul   $0x3e8,%rax,%rax
 2ca:	sub    %rax,%r15
 2cd:	mov    %r11,%rax
 2d0:	neg    %rax
 2d3:	cmovs  %r11,%rax
 2d7:	lea    (%r15,%rax,1),%r11
 2db:	test   %r15,%r15
 2de:	cmovl  %r11,%r15
 2e2:	shl    $1,%r15
 2e5:	mov    %r15,%rdx
 2e8:	or     $0x1,%rdx
 2ec:	mov    %rdx,0x20(%rsp)
 2f1:	mov    %rsi,%rax
 2f4:	and    %rdx,%rax
 2f7:	test   $0x1,%rax
 2fd:	je     318 <botlish_fn_1+0x2e0>
 303:	and    $0xfffffffffffffffe,%r15
 307:	mov    %rsi,%rcx
 30a:	add    %r15,%rcx
 30d:	seto   %al
 310:	test   %al,%al
 312:	je     325 <botlish_fn_1+0x2ed>
 318:	mov    0x28(%rsp),%rdi
 31d:	call   322 <botlish_fn_1+0x2ea>
			31e: R_X86_64_PLT32	rt_int_add-0x4
 322:	mov    %rax,%rcx
 325:	mov    0x18(%r13),%rax
 329:	test   %rax,%rax
 32c:	je     368 <botlish_fn_1+0x330>
 332:	mov    0x10(%r13),%rax
 336:	mov    %rcx,(%rax)
 339:	add    $0x1,%rbx
 340:	mov    %r13,%rax
 343:	mov    %r14,%r13
 346:	jmp    110 <botlish_fn_1+0xd8>
 34b:	mov    $0x1,%edx
 350:	mov    %rax,%r15
 353:	mov    %r15,%rcx
 356:	mov    %r14,%rsi
 359:	mov    0x28(%rsp),%rdi
 35e:	call   363 <botlish_fn_1+0x32b>
			35f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 363:	jmp    28c <botlish_fn_1+0x254>
 368:	mov    $0x1,%edx
 36d:	mov    %r13,%rsi
 370:	mov    0x28(%rsp),%rdi
 375:	call   37a <botlish_fn_1+0x342>
			376: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
 37a:	jmp    339 <botlish_fn_1+0x301>
 37f:	add    %bl,%dl
 381:	pushf
 382:	mov    %es,0x0(%rbx)
 388:	(bad)
 389:	(bad)
 38a:	(bad)
 38b:	incl   (%rax)
 38d:	add    %al,(%rax)
 38f:	add    %cl,%bh
 391:	notl   -0x1d(%rbx)
 394:	movsl  %ds:(%rsi),%es:(%rdi)
 395:	fwait
 396:	.byte 0xc4
 397:	.byte 0x20

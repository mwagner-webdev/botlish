<botlish_fn_6>:
     248:	push   %rbp
     249:	mov    %rsp,%rbp
     24c:	sub    $0x100,%rsp
     253:	mov    %rbx,0xd0(%rsp)
     25b:	mov    %r12,0xd8(%rsp)
     263:	mov    %r13,0xe0(%rsp)
     26b:	mov    %r14,0xe8(%rsp)
     273:	mov    %r15,0xf0(%rsp)
     27b:	mov    %rdi,0x80(%rsp)
     283:	movq   $0x0,(%rsp)
     28b:	movq   $0x0,0x8(%rsp)
     294:	movq   $0x0,0x10(%rsp)
     29d:	movq   $0x0,0x18(%rsp)
     2a6:	movq   $0x0,0x20(%rsp)
     2af:	movq   $0x0,0x40(%rsp)
     2b8:	movq   $0x0,0x48(%rsp)
     2c1:	movq   $0x0,0x50(%rsp)
     2ca:	movq   $0x0,0x58(%rsp)
     2d3:	movq   $0xa,0x38(%rsp)
     2dc:	movq   $0xa,0x28(%rsp)
     2e5:	movq   $0xa,0x30(%rsp)
     2ee:	mov    %rsi,0x38(%rsp)
     2f3:	mov    0x8(%rsi),%r8
     2f7:	shl    $1,%r8
     2fa:	or     $0x1,%r8
     2fe:	sar    $1,%r8
     301:	test   %r8,%r8
     304:	mov    %r8,0xc8(%rsp)
     30c:	jg     337 <botlish_fn_6+0xef>
     312:	mov    $0xffffffffffffffff,%rax
     319:	movq   $0xffffffffffffffff,0x28(%rsp)
     322:	mov    %rsi,0x88(%rsp)
     32a:	mov    %rax,0x90(%rsp)
     332:	jmp    39e <botlish_fn_6+0x156>
     337:	movzbq 0x18(%rsi),%rax
     33c:	mov    %rsi,0x88(%rsp)
     344:	test   %rax,%rax
     347:	jne    36c <botlish_fn_6+0x124>
     34d:	mov    $0x1,%edx
     352:	mov    0x88(%rsp),%rsi
     35a:	mov    0x80(%rsp),%rdi
     362:	call   367 <botlish_fn_6+0x11f>
			363: R_X86_64_PLT32	rt_str_char_at_proven-0x4
     367:	jmp    381 <botlish_fn_6+0x139>
     36c:	mov    0x88(%rsp),%rcx
     374:	movzbq 0x19(%rcx),%rax
     379:	shl    $0x3,%rax
     37d:	or     $0x4,%rax
     381:	shr    $0x3,%rax
     385:	mov    $0x1,%ecx
     38a:	mov    %rcx,0x90(%rsp)
     392:	shl    $1,%rax
     395:	or     $0x1,%rax
     399:	mov    %rax,0x28(%rsp)
     39e:	mov    %rax,(%rsp)
     3a2:	mov    %rax,0x98(%rsp)
     3aa:	mov    $0x3,%ebx
     3af:	movq   $0x3,0x8(%rsp)
     3b8:	mov    0x98(%rsp),%rdx
     3c0:	mov    %rbx,%rsi
     3c3:	mov    0x80(%rsp),%rdi
     3cb:	call   3d0 <botlish_fn_6+0x188>
			3cc: R_X86_64_PLT32	rt_mutarray_create-0x4
     3d0:	mov    %rbx,0xc0(%rsp)
     3d8:	test   %rax,%rax
     3db:	je     1691 <botlish_fn_6+0x1449>
     3e1:	mov    %rax,(%rsp)
     3e5:	mov    %rax,0xb8(%rsp)
     3ed:	mov    $0x9,%esi
     3f2:	movq   $0x9,0x8(%rsp)
     3fb:	mov    $0x1,%edx
     400:	movq   $0x1,0x10(%rsp)
     409:	mov    0x80(%rsp),%rdi
     411:	call   416 <botlish_fn_6+0x1ce>
			412: R_X86_64_PLT32	rt_mutarray_create-0x4
     416:	mov    %rax,%r14
     419:	test   %r14,%r14
     41c:	je     1691 <botlish_fn_6+0x1449>
     422:	mov    %r14,0x8(%rsp)
     427:	mov    %r14,0xb0(%rsp)
     42f:	xor    %rax,%rax
     432:	mov    %rax,%r13
     435:	mov    $0xffffffffffffffff,%r12
     43c:	mov    %r12,0xa8(%rsp)
     444:	mov    0xb8(%rsp),%rcx
     44c:	mov    0x10(%rcx),%rax
     450:	mov    %rcx,0xb8(%rsp)
     458:	mov    (%rax),%rsi
     45b:	test   $0x1,%rsi
     462:	mov    %rsi,%rbx
     465:	jne    498 <botlish_fn_6+0x250>
     46b:	mov    0xa8(%rsp),%rdx
     473:	mov    %rbx,%rsi
     476:	mov    0x80(%rsp),%rdi
     47e:	call   483 <botlish_fn_6+0x23b>
			47f: R_X86_64_PLT32	rt_int_cmp-0x4
     483:	mov    $0x2,%ecx
     488:	test   %rax,%rax
     48b:	cmove  0x137d(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     493:	jmp    4ac <botlish_fn_6+0x264>
     498:	mov    $0x2,%ecx
     49d:	mov    %rbx,%rsi
     4a0:	cmp    $0xffffffffffffffff,%rsi
     4a4:	cmove  0x1364(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     4ac:	cmp    $0x6,%rcx
     4b0:	je     1610 <botlish_fn_6+0x13c8>
     4b6:	mov    %rbx,%rsi
     4b9:	test   $0x1,%rsi
     4c0:	jne    4f0 <botlish_fn_6+0x2a8>
     4c6:	mov    $0x5b,%edx
     4cb:	mov    %rbx,%rsi
     4ce:	mov    0x80(%rsp),%rdi
     4d6:	call   4db <botlish_fn_6+0x293>
			4d7: R_X86_64_PLT32	rt_int_cmp-0x4
     4db:	mov    $0x2,%ecx
     4e0:	test   %rax,%rax
     4e3:	cmove  0x1325(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     4eb:	jmp    504 <botlish_fn_6+0x2bc>
     4f0:	mov    $0x2,%ecx
     4f5:	mov    %rbx,%rsi
     4f8:	cmp    $0x5b,%rsi
     4fc:	cmove  0x130c(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     504:	cmp    $0x6,%rcx
     508:	jne    516 <botlish_fn_6+0x2ce>
     50e:	mov    %r13,%r15
     511:	jmp    ff1 <botlish_fn_6+0xda9>
     516:	mov    %rbx,%rsi
     519:	mov    0x80(%rsp),%rdi
     521:	call   526 <botlish_fn_6+0x2de>
			522: R_X86_64_PLT32	botlish_fn_1-0x4
     526:	cmp    $0x6,%rax
     52a:	jne    538 <botlish_fn_6+0x2f0>
     530:	mov    %r13,%r15
     533:	jmp    ff1 <botlish_fn_6+0xda9>
     538:	mov    %rbx,%rsi
     53b:	test   $0x1,%rsi
     542:	jne    572 <botlish_fn_6+0x32a>
     548:	mov    $0x45,%edx
     54d:	mov    %rbx,%rsi
     550:	mov    0x80(%rsp),%rdi
     558:	call   55d <botlish_fn_6+0x315>
			559: R_X86_64_PLT32	rt_int_cmp-0x4
     55d:	mov    $0x2,%ecx
     562:	test   %rax,%rax
     565:	cmove  0x12a3(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     56d:	jmp    586 <botlish_fn_6+0x33e>
     572:	mov    $0x2,%ecx
     577:	mov    %rbx,%rsi
     57a:	cmp    $0x45,%rsi
     57e:	cmove  0x128a(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     586:	cmp    $0x6,%rcx
     58a:	je     a1a <botlish_fn_6+0x7d2>
     590:	mov    %rbx,%rsi
     593:	test   $0x1,%rsi
     59a:	jne    5ca <botlish_fn_6+0x382>
     5a0:	mov    $0xf7,%edx
     5a5:	mov    %rbx,%rsi
     5a8:	mov    0x80(%rsp),%rdi
     5b0:	call   5b5 <botlish_fn_6+0x36d>
			5b1: R_X86_64_PLT32	rt_int_cmp-0x4
     5b5:	mov    $0x2,%esi
     5ba:	test   %rax,%rax
     5bd:	cmove  0x124b(%rip),%rsi        # 1810 <botlish_fn_6+0x15c8>
     5c5:	jmp    5e0 <botlish_fn_6+0x398>
     5ca:	mov    $0x2,%esi
     5cf:	mov    %rbx,%rax
     5d2:	cmp    $0xf7,%rax
     5d8:	cmove  0x1230(%rip),%rsi        # 1810 <botlish_fn_6+0x15c8>
     5e0:	cmp    $0x6,%rsi
     5e4:	je     7ab <botlish_fn_6+0x563>
     5ea:	mov    %rbx,%rsi
     5ed:	test   $0x1,%rsi
     5f4:	jne    624 <botlish_fn_6+0x3dc>
     5fa:	mov    $0xfb,%edx
     5ff:	mov    %rbx,%rsi
     602:	mov    0x80(%rsp),%rdi
     60a:	call   60f <botlish_fn_6+0x3c7>
			60b: R_X86_64_PLT32	rt_int_cmp-0x4
     60f:	mov    $0x2,%ecx
     614:	test   %rax,%rax
     617:	cmove  0x11f1(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     61f:	jmp    63b <botlish_fn_6+0x3f3>
     624:	mov    $0x2,%ecx
     629:	mov    %rbx,%rsi
     62c:	cmp    $0xfb,%rsi
     633:	cmove  0x11d5(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     63b:	cmp    $0x6,%rcx
     63f:	je     7ab <botlish_fn_6+0x563>
     645:	mov    %rbx,%rsi
     648:	test   $0x1,%rsi
     64f:	jne    67f <botlish_fn_6+0x437>
     655:	mov    $0xb7,%edx
     65a:	mov    %rbx,%rsi
     65d:	mov    0x80(%rsp),%rdi
     665:	call   66a <botlish_fn_6+0x422>
			666: R_X86_64_PLT32	rt_int_cmp-0x4
     66a:	mov    $0x2,%ecx
     66f:	test   %rax,%rax
     672:	cmove  0x1196(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     67a:	jmp    696 <botlish_fn_6+0x44e>
     67f:	mov    $0x2,%ecx
     684:	mov    %rbx,%rsi
     687:	cmp    $0xb7,%rsi
     68e:	cmove  0x117a(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     696:	cmp    $0x6,%rcx
     69a:	je     7ab <botlish_fn_6+0x563>
     6a0:	mov    %rbx,%rsi
     6a3:	test   $0x1,%rsi
     6aa:	jne    6da <botlish_fn_6+0x492>
     6b0:	mov    $0xbb,%edx
     6b5:	mov    %rbx,%rsi
     6b8:	mov    0x80(%rsp),%rdi
     6c0:	call   6c5 <botlish_fn_6+0x47d>
			6c1: R_X86_64_PLT32	rt_int_cmp-0x4
     6c5:	mov    $0x2,%ecx
     6ca:	test   %rax,%rax
     6cd:	cmove  0x113b(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     6d5:	jmp    6f1 <botlish_fn_6+0x4a9>
     6da:	mov    $0x2,%ecx
     6df:	mov    %rbx,%rsi
     6e2:	cmp    $0xbb,%rsi
     6e9:	cmove  0x111f(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     6f1:	cmp    $0x6,%rcx
     6f5:	je     7ab <botlish_fn_6+0x563>
     6fb:	mov    %rbx,%rsi
     6fe:	test   $0x1,%rsi
     705:	jne    735 <botlish_fn_6+0x4ed>
     70b:	mov    $0x75,%edx
     710:	mov    %rbx,%rsi
     713:	mov    0x80(%rsp),%rdi
     71b:	call   720 <botlish_fn_6+0x4d8>
			71c: R_X86_64_PLT32	rt_int_cmp-0x4
     720:	mov    $0x2,%esi
     725:	test   %rax,%rax
     728:	cmove  0x10e0(%rip),%rsi        # 1810 <botlish_fn_6+0x15c8>
     730:	jmp    749 <botlish_fn_6+0x501>
     735:	mov    $0x2,%esi
     73a:	mov    %rbx,%rcx
     73d:	cmp    $0x75,%rcx
     741:	cmove  0x10c7(%rip),%rsi        # 1810 <botlish_fn_6+0x15c8>
     749:	cmp    $0x6,%rsi
     74d:	je     7ab <botlish_fn_6+0x563>
     753:	mov    %rbx,%rsi
     756:	test   $0x1,%rsi
     75d:	jne    78d <botlish_fn_6+0x545>
     763:	mov    $0x59,%edx
     768:	mov    %rbx,%rsi
     76b:	mov    0x80(%rsp),%rdi
     773:	call   778 <botlish_fn_6+0x530>
			774: R_X86_64_PLT32	rt_int_cmp-0x4
     778:	mov    $0x2,%ecx
     77d:	test   %rax,%rax
     780:	cmove  0x1088(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     788:	jmp    7a1 <botlish_fn_6+0x559>
     78d:	mov    $0x2,%ecx
     792:	mov    %rbx,%rsi
     795:	cmp    $0x59,%rsi
     799:	cmove  0x106f(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     7a1:	cmp    $0x6,%rcx
     7a5:	jne    845 <botlish_fn_6+0x5fd>
     7ab:	movq   $0x5,0x10(%rsp)
     7b4:	mov    0xb0(%rsp),%rcx
     7bc:	mov    0x10(%rcx),%rax
     7c0:	mov    0x10(%rax),%rsi
     7c4:	mov    %rsi,0x18(%rsp)
     7c9:	movq   $0x3,0x20(%rsp)
     7d2:	test   $0x1,%rsi
     7d9:	je     800 <botlish_fn_6+0x5b8>
     7df:	mov    %rsi,%rcx
     7e2:	add    $0x2,%rcx
     7e6:	seto   %dil
     7ea:	test   %dil,%dil
     7ed:	jne    800 <botlish_fn_6+0x5b8>
     7f3:	mov    0xb0(%rsp),%rax
     7fb:	jmp    820 <botlish_fn_6+0x5d8>
     800:	mov    0xc0(%rsp),%rdx
     808:	mov    0x80(%rsp),%rdi
     810:	call   815 <botlish_fn_6+0x5cd>
			811: R_X86_64_PLT32	rt_int_add-0x4
     815:	mov    %rax,%rcx
     818:	mov    0xb0(%rsp),%rax
     820:	mov    0xb0(%rsp),%rax
     828:	mov    0x18(%rax),%r9
     82c:	test   %r9,%r9
     82f:	je     16fc <botlish_fn_6+0x14b4>
     835:	mov    0xb0(%rsp),%rax
     83d:	mov    0x10(%rax),%rax
     841:	mov    %rcx,0x10(%rax)
     845:	mov    0x90(%rsp),%rcx
     84d:	cmp    $0x1,%rcx
     851:	je     8f1 <botlish_fn_6+0x6a9>
     857:	cmp    $0xffffffffffffffff,%rcx
     85b:	jne    871 <botlish_fn_6+0x629>
     861:	mov    %r13,%r15
     864:	mov    %rcx,0x90(%rsp)
     86c:	jmp    9e4 <botlish_fn_6+0x79c>
     871:	mov    $0xa,%esi
     876:	mov    0x80(%rsp),%rdi
     87e:	call   883 <botlish_fn_6+0x63b>
			87f: R_X86_64_PLT32	rt_co_resume0-0x4
     883:	test   %rax,%rax
     886:	je     8a5 <botlish_fn_6+0x65d>
     88c:	mov    0x80(%rsp),%rdi
     894:	mov    0x10(%rdi),%rax
     898:	mov    0x8(%rax),%rsi
     89c:	mov    0x30(%rax),%rdx
     8a0:	call   8a5 <botlish_fn_6+0x65d>
			8a1: R_X86_64_PLT32	rt_raise-0x4
     8a5:	mov    0x80(%rsp),%rdi
     8ad:	call   8b2 <botlish_fn_6+0x66a>
			8ae: R_X86_64_PLT32	rt_declared_error-0x4
     8b2:	cmp    $0x40000001,%rax
     8b8:	je     8cb <botlish_fn_6+0x683>
     8be:	mov    0x80(%rsp),%rdi
     8c6:	jmp    8d3 <botlish_fn_6+0x68b>
     8cb:	mov    0x80(%rsp),%rdi
     8d3:	mov    0x80(%rsp),%rdi
     8db:	call   8e0 <botlish_fn_6+0x698>
			8dc: R_X86_64_PLT32	rt_declared_error-0x4
     8e0:	cmp    $0x40000001,%rax
     8e6:	jne    1691 <botlish_fn_6+0x1449>
     8ec:	jmp    1691 <botlish_fn_6+0x1449>
     8f1:	mov    %r13,%r15
     8f4:	add    $0x1,%r15
     8fb:	mov    0xc8(%rsp),%r8
     903:	cmp    %r8,%r15
     906:	jl     932 <botlish_fn_6+0x6ea>
     90c:	movq   $0xffffffffffffffff,0x28(%rsp)
     915:	mov    0xa8(%rsp),%rax
     91d:	mov    %rax,0x90(%rsp)
     925:	mov    %rax,0x98(%rsp)
     92d:	jmp    9e4 <botlish_fn_6+0x79c>
     932:	mov    0x88(%rsp),%rcx
     93a:	movzbq 0x18(%rcx),%rax
     93f:	test   %rax,%rax
     942:	jne    974 <botlish_fn_6+0x72c>
     948:	mov    %r15,%rdx
     94b:	shl    $1,%rdx
     94e:	or     $0x1,%rdx
     952:	mov    0x88(%rsp),%rsi
     95a:	mov    0x80(%rsp),%rdi
     962:	call   967 <botlish_fn_6+0x71f>
			963: R_X86_64_PLT32	rt_str_char_at_proven-0x4
     967:	mov    %rax,0x98(%rsp)
     96f:	jmp    9af <botlish_fn_6+0x767>
     974:	mov    %r15,%rax
     977:	shl    $1,%rax
     97a:	or     $0x1,%rax
     97e:	sar    $1,%rax
     981:	mov    0x88(%rsp),%rcx
     989:	movzbq 0x19(%rcx,%rax,1),%rax
     98f:	mov    %rax,0x98(%rsp)
     997:	shl    $0x3,%rax
     99b:	mov    %rax,0x98(%rsp)
     9a3:	or     $0x4,%rax
     9a7:	mov    %rax,0x98(%rsp)
     9af:	shr    $0x3,%rax
     9b3:	mov    %rax,0x98(%rsp)
     9bb:	mov    $0x1,%ecx
     9c0:	mov    %rcx,0x90(%rsp)
     9c8:	shl    $1,%rax
     9cb:	mov    %rax,0x98(%rsp)
     9d3:	or     $0x1,%rax
     9d7:	mov    %rax,0x98(%rsp)
     9df:	mov    %rax,0x28(%rsp)
     9e4:	mov    0xb8(%rsp),%rcx
     9ec:	mov    0x18(%rcx),%rax
     9f0:	test   %rax,%rax
     9f3:	je     171b <botlish_fn_6+0x14d3>
     9f9:	mov    0xb8(%rsp),%rcx
     a01:	mov    0x10(%rcx),%rax
     a05:	mov    0x98(%rsp),%rcx
     a0d:	mov    %rcx,(%rax)
     a10:	mov    $0xa,%esi
     a15:	jmp    1600 <botlish_fn_6+0x13b8>
     a1a:	mov    %r13,%r15
     a1d:	movq   $0xa,0x50(%rsp)
     a26:	movq   $0xa,0x58(%rsp)
     a2f:	movq   $0xa,0x40(%rsp)
     a38:	movq   $0x2,0x50(%rsp)
     a41:	movq   $0x2,0x58(%rsp)
     a4a:	mov    $0x1,%r14d
     a50:	mov    $0x2,%ebx
     a55:	mov    0xb8(%rsp),%rcx
     a5d:	mov    %rbx,%r13
     a60:	mov    0xb8(%rsp),%rcx
     a68:	mov    0x10(%rcx),%rdx
     a6c:	mov    (%rdx),%rsi
     a6f:	cmp    $0x1,%r14
     a73:	je     c9b <botlish_fn_6+0xa53>
     a79:	cmp    $0x2,%r14
     a7d:	je     b32 <botlish_fn_6+0x8ea>
     a83:	cmp    $0x3,%r14
     a87:	je     ad0 <botlish_fn_6+0x888>
     a8d:	cmp    $0xffffffffffffffff,%r14
     a91:	je     cbb <botlish_fn_6+0xa73>
     a97:	mov    $0xa,%esi
     a9c:	mov    0x80(%rsp),%rdi
     aa4:	call   aa9 <botlish_fn_6+0x861>
			aa5: R_X86_64_PLT32	rt_co_resume0-0x4
     aa9:	test   %rax,%rax
     aac:	je     1691 <botlish_fn_6+0x1449>
     ab2:	mov    0x80(%rsp),%rdi
     aba:	mov    0x10(%rdi),%rax
     abe:	mov    0x8(%rax),%rsi
     ac2:	mov    0x30(%rax),%rdx
     ac6:	call   acb <botlish_fn_6+0x883>
			ac7: R_X86_64_PLT32	rt_raise-0x4
     acb:	jmp    1691 <botlish_fn_6+0x1449>
     ad0:	test   $0x1,%rsi
     ad7:	jne    b07 <botlish_fn_6+0x8bf>
     add:	mov    0xa8(%rsp),%rdx
     ae5:	mov    0x80(%rsp),%rdi
     aed:	call   af2 <botlish_fn_6+0x8aa>
			aee: R_X86_64_PLT32	rt_int_cmp-0x4
     af2:	mov    $0x2,%ecx
     af7:	test   %rax,%rax
     afa:	cmove  0xd0e(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     b02:	jmp    b18 <botlish_fn_6+0x8d0>
     b07:	mov    $0x2,%ecx
     b0c:	cmp    $0xffffffffffffffff,%rsi
     b10:	cmove  0xcf8(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     b18:	cmp    $0x6,%rcx
     b1c:	jne    c9b <botlish_fn_6+0xa53>
     b22:	mov    $0x2,%ebx
     b27:	mov    $0x6,%r13d
     b2d:	jmp    c84 <botlish_fn_6+0xa3c>
     b32:	test   $0x1,%rsi
     b39:	mov    %rsi,%rbx
     b3c:	jne    b6c <botlish_fn_6+0x924>
     b42:	mov    $0x45,%edx
     b47:	mov    %rbx,%rsi
     b4a:	mov    0x80(%rsp),%rdi
     b52:	call   b57 <botlish_fn_6+0x90f>
			b53: R_X86_64_PLT32	rt_int_cmp-0x4
     b57:	mov    $0x2,%ecx
     b5c:	test   %rax,%rax
     b5f:	cmove  0xca9(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     b67:	jmp    b80 <botlish_fn_6+0x938>
     b6c:	mov    $0x2,%ecx
     b71:	mov    %rbx,%rsi
     b74:	cmp    $0x45,%rsi
     b78:	cmove  0xc90(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     b80:	cmp    $0x6,%rcx
     b84:	je     c7c <botlish_fn_6+0xa34>
     b8a:	mov    %rbx,%rsi
     b8d:	test   $0x1,%rsi
     b94:	jne    bc7 <botlish_fn_6+0x97f>
     b9a:	mov    0xa8(%rsp),%rdx
     ba2:	mov    %rbx,%rsi
     ba5:	mov    0x80(%rsp),%rdi
     bad:	call   bb2 <botlish_fn_6+0x96a>
			bae: R_X86_64_PLT32	rt_int_cmp-0x4
     bb2:	mov    $0x2,%ecx
     bb7:	test   %rax,%rax
     bba:	cmove  0xc4e(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     bc2:	jmp    bdb <botlish_fn_6+0x993>
     bc7:	mov    $0x2,%ecx
     bcc:	mov    %rbx,%rsi
     bcf:	cmp    $0xffffffffffffffff,%rsi
     bd3:	cmove  0xc35(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
     bdb:	cmp    $0x6,%rcx
     bdf:	je     c6c <botlish_fn_6+0xa24>
     be5:	mov    %rbx,%rsi
     be8:	test   $0x1,%rsi
     bef:	jne    c20 <botlish_fn_6+0x9d8>
     bf5:	mov    $0xb9,%edx
     bfa:	mov    %rbx,%rsi
     bfd:	mov    0x80(%rsp),%rdi
     c05:	call   c0a <botlish_fn_6+0x9c2>
			c06: R_X86_64_PLT32	rt_int_cmp-0x4
     c0a:	mov    $0x2,%r10d
     c10:	test   %rax,%rax
     c13:	cmove  0xbf5(%rip),%r10        # 1810 <botlish_fn_6+0x15c8>
     c1b:	jmp    c38 <botlish_fn_6+0x9f0>
     c20:	mov    $0x2,%r10d
     c26:	mov    %rbx,%rsi
     c29:	cmp    $0xb9,%rsi
     c30:	cmove  0xbd8(%rip),%r10        # 1810 <botlish_fn_6+0x15c8>
     c38:	cmp    $0x6,%r10
     c3c:	jne    c9b <botlish_fn_6+0xa53>
     c42:	mov    $0x6,%ebx
     c47:	movq   $0x6,0x50(%rsp)
     c50:	mov    $0x2,%r13d
     c56:	movq   $0x2,0x58(%rsp)
     c5f:	mov    0xc0(%rsp),%r14
     c67:	jmp    cbb <botlish_fn_6+0xa73>
     c6c:	mov    $0x2,%ebx
     c71:	mov    $0x6,%r13d
     c77:	jmp    c84 <botlish_fn_6+0xa3c>
     c7c:	mov    $0x6,%ebx
     c81:	mov    %rbx,%r13
     c84:	mov    %rbx,0x50(%rsp)
     c89:	mov    %r13,0x58(%rsp)
     c8e:	mov    0xa8(%rsp),%r14
     c96:	jmp    cbb <botlish_fn_6+0xa73>
     c9b:	mov    $0x6,%ebx
     ca0:	movq   $0x6,0x50(%rsp)
     ca9:	mov    $0x2,%r13d
     caf:	movq   $0x2,0x58(%rsp)
     cb8:	mov    %r13,%r14
     cbb:	mov    %r13,0x48(%rsp)
     cc0:	cmp    $0x6,%rbx
     cc4:	je     cd2 <botlish_fn_6+0xa8a>
     cca:	mov    %r13,%r12
     ccd:	jmp    f35 <botlish_fn_6+0xced>
     cd2:	movq   $0x7,0x10(%rsp)
     cdb:	mov    0xb0(%rsp),%rcx
     ce3:	mov    0x10(%rcx),%r10
     ce7:	mov    0x18(%r10),%rsi
     ceb:	mov    %rsi,0x18(%rsp)
     cf0:	movq   $0x3,0x20(%rsp)
     cf9:	test   $0x1,%rsi
     d00:	je     d25 <botlish_fn_6+0xadd>
     d06:	mov    %rsi,%rcx
     d09:	add    $0x2,%rcx
     d0d:	seto   %al
     d10:	test   %al,%al
     d12:	jne    d25 <botlish_fn_6+0xadd>
     d18:	mov    0xb0(%rsp),%rax
     d20:	jmp    d45 <botlish_fn_6+0xafd>
     d25:	mov    0xc0(%rsp),%rdx
     d2d:	mov    0x80(%rsp),%rdi
     d35:	call   d3a <botlish_fn_6+0xaf2>
			d36: R_X86_64_PLT32	rt_int_add-0x4
     d3a:	mov    %rax,%rcx
     d3d:	mov    0xb0(%rsp),%rax
     d45:	mov    0xb0(%rsp),%rax
     d4d:	mov    0x18(%rax),%rax
     d51:	test   %rax,%rax
     d54:	je     1742 <botlish_fn_6+0x14fa>
     d5a:	mov    0xb0(%rsp),%rax
     d62:	mov    0x10(%rax),%rax
     d66:	mov    %rcx,0x18(%rax)
     d6a:	mov    0x90(%rsp),%rcx
     d72:	cmp    $0x1,%rcx
     d76:	je     e16 <botlish_fn_6+0xbce>
     d7c:	mov    0x90(%rsp),%rcx
     d84:	cmp    $0xffffffffffffffff,%rcx
     d88:	jne    d96 <botlish_fn_6+0xb4e>
     d8e:	mov    %r13,%r12
     d91:	jmp    f09 <botlish_fn_6+0xcc1>
     d96:	mov    $0xa,%esi
     d9b:	mov    0x80(%rsp),%rdi
     da3:	call   da8 <botlish_fn_6+0xb60>
			da4: R_X86_64_PLT32	rt_co_resume0-0x4
     da8:	test   %rax,%rax
     dab:	je     dca <botlish_fn_6+0xb82>
     db1:	mov    0x80(%rsp),%rdi
     db9:	mov    0x10(%rdi),%rax
     dbd:	mov    0x8(%rax),%rsi
     dc1:	mov    0x30(%rax),%rdx
     dc5:	call   dca <botlish_fn_6+0xb82>
			dc6: R_X86_64_PLT32	rt_raise-0x4
     dca:	mov    0x80(%rsp),%rdi
     dd2:	call   dd7 <botlish_fn_6+0xb8f>
			dd3: R_X86_64_PLT32	rt_declared_error-0x4
     dd7:	cmp    $0x40000001,%rax
     ddd:	je     df0 <botlish_fn_6+0xba8>
     de3:	mov    0x80(%rsp),%rdi
     deb:	jmp    df8 <botlish_fn_6+0xbb0>
     df0:	mov    0x80(%rsp),%rdi
     df8:	mov    0x80(%rsp),%rdi
     e00:	call   e05 <botlish_fn_6+0xbbd>
			e01: R_X86_64_PLT32	rt_declared_error-0x4
     e05:	cmp    $0x40000001,%rax
     e0b:	jne    1691 <botlish_fn_6+0x1449>
     e11:	jmp    1691 <botlish_fn_6+0x1449>
     e16:	mov    %r13,%r12
     e19:	add    $0x1,%r15
     e20:	mov    0xc8(%rsp),%r8
     e28:	cmp    %r8,%r15
     e2b:	jl     e57 <botlish_fn_6+0xc0f>
     e31:	movq   $0xffffffffffffffff,0x28(%rsp)
     e3a:	mov    0xa8(%rsp),%rax
     e42:	mov    %rax,0x90(%rsp)
     e4a:	mov    %rax,0x98(%rsp)
     e52:	jmp    f09 <botlish_fn_6+0xcc1>
     e57:	mov    0x88(%rsp),%rcx
     e5f:	movzbq 0x18(%rcx),%rax
     e64:	test   %rax,%rax
     e67:	jne    e99 <botlish_fn_6+0xc51>
     e6d:	mov    %r15,%rdx
     e70:	shl    $1,%rdx
     e73:	or     $0x1,%rdx
     e77:	mov    0x88(%rsp),%rsi
     e7f:	mov    0x80(%rsp),%rdi
     e87:	call   e8c <botlish_fn_6+0xc44>
			e88: R_X86_64_PLT32	rt_str_char_at_proven-0x4
     e8c:	mov    %rax,0x98(%rsp)
     e94:	jmp    ed4 <botlish_fn_6+0xc8c>
     e99:	mov    %r15,%rax
     e9c:	shl    $1,%rax
     e9f:	or     $0x1,%rax
     ea3:	sar    $1,%rax
     ea6:	mov    0x88(%rsp),%rcx
     eae:	movzbq 0x19(%rcx,%rax,1),%rax
     eb4:	mov    %rax,0x98(%rsp)
     ebc:	shl    $0x3,%rax
     ec0:	mov    %rax,0x98(%rsp)
     ec8:	or     $0x4,%rax
     ecc:	mov    %rax,0x98(%rsp)
     ed4:	shr    $0x3,%rax
     ed8:	mov    %rax,0x98(%rsp)
     ee0:	mov    $0x1,%ecx
     ee5:	mov    %rcx,0x90(%rsp)
     eed:	shl    $1,%rax
     ef0:	mov    %rax,0x98(%rsp)
     ef8:	or     $0x1,%rax
     efc:	mov    %rax,0x98(%rsp)
     f04:	mov    %rax,0x28(%rsp)
     f09:	mov    0xb8(%rsp),%rcx
     f11:	mov    0x18(%rcx),%rax
     f15:	test   %rax,%rax
     f18:	je     1761 <botlish_fn_6+0x1519>
     f1e:	mov    0xb8(%rsp),%rcx
     f26:	mov    0x10(%rcx),%rax
     f2a:	mov    0x98(%rsp),%rcx
     f32:	mov    %rcx,(%rax)
     f35:	cmp    $0x6,%r13
     f39:	je     f4f <botlish_fn_6+0xd07>
     f3f:	mov    0xb8(%rsp),%rcx
     f47:	mov    %r12,%r13
     f4a:	jmp    a60 <botlish_fn_6+0x818>
     f4f:	movq   $0x3,0x10(%rsp)
     f58:	mov    0xb0(%rsp),%rcx
     f60:	mov    0x10(%rcx),%r10
     f64:	mov    0x8(%r10),%rsi
     f68:	mov    %rsi,0x18(%rsp)
     f6d:	movq   $0x3,0x20(%rsp)
     f76:	test   $0x1,%rsi
     f7d:	je     fa2 <botlish_fn_6+0xd5a>
     f83:	mov    %rsi,%rcx
     f86:	add    $0x2,%rcx
     f8a:	seto   %al
     f8d:	test   %al,%al
     f8f:	jne    fa2 <botlish_fn_6+0xd5a>
     f95:	mov    0xb0(%rsp),%rax
     f9d:	jmp    fc2 <botlish_fn_6+0xd7a>
     fa2:	mov    0xc0(%rsp),%rdx
     faa:	mov    0x80(%rsp),%rdi
     fb2:	call   fb7 <botlish_fn_6+0xd6f>
			fb3: R_X86_64_PLT32	rt_int_add-0x4
     fb7:	mov    %rax,%rcx
     fba:	mov    0xb0(%rsp),%rax
     fc2:	mov    0xb0(%rsp),%rax
     fca:	mov    0x18(%rax),%rax
     fce:	test   %rax,%rax
     fd1:	je     1788 <botlish_fn_6+0x1540>
     fd7:	mov    0xb0(%rsp),%rax
     fdf:	mov    0x10(%rax),%rax
     fe3:	mov    %rcx,0x8(%rax)
     fe7:	mov    $0xa,%esi
     fec:	jmp    1600 <botlish_fn_6+0x13b8>
     ff1:	movq   $0xa,0x50(%rsp)
     ffa:	movq   $0xa,0x58(%rsp)
    1003:	movq   $0xa,0x40(%rsp)
    100c:	movq   $0x2,0x50(%rsp)
    1015:	movq   $0x2,0x58(%rsp)
    101e:	mov    $0x1,%r14d
    1024:	mov    $0x2,%ebx
    1029:	mov    $0x4,%eax
    102e:	mov    %rax,0xa0(%rsp)
    1036:	mov    0xb8(%rsp),%rcx
    103e:	mov    %rbx,%r13
    1041:	mov    0xb8(%rsp),%rcx
    1049:	mov    0x10(%rcx),%rax
    104d:	mov    (%rax),%rsi
    1050:	cmp    $0x1,%r14
    1054:	je     11ef <botlish_fn_6+0xfa7>
    105a:	cmp    $0x2,%r14
    105e:	je     11e7 <botlish_fn_6+0xf9f>
    1064:	cmp    $0x3,%r14
    1068:	je     113b <botlish_fn_6+0xef3>
    106e:	cmp    $0x4,%r14
    1072:	je     10ec <botlish_fn_6+0xea4>
    1078:	cmp    $0x5,%r14
    107c:	je     10c5 <botlish_fn_6+0xe7d>
    1082:	cmp    $0xffffffffffffffff,%r14
    1086:	je     12d0 <botlish_fn_6+0x1088>
    108c:	mov    $0xa,%esi
    1091:	mov    0x80(%rsp),%rdi
    1099:	call   109e <botlish_fn_6+0xe56>
			109a: R_X86_64_PLT32	rt_co_resume0-0x4
    109e:	test   %rax,%rax
    10a1:	je     1691 <botlish_fn_6+0x1449>
    10a7:	mov    0x80(%rsp),%rdi
    10af:	mov    0x10(%rdi),%rax
    10b3:	mov    0x8(%rax),%rsi
    10b7:	mov    0x30(%rax),%rdx
    10bb:	call   10c0 <botlish_fn_6+0xe78>
			10bc: R_X86_64_PLT32	rt_raise-0x4
    10c0:	jmp    1691 <botlish_fn_6+0x1449>
    10c5:	mov    0x80(%rsp),%rdi
    10cd:	call   10d2 <botlish_fn_6+0xe8a>
			10ce: R_X86_64_PLT32	botlish_fn_1-0x4
    10d2:	cmp    $0x6,%rax
    10d6:	je     1113 <botlish_fn_6+0xecb>
    10dc:	mov    $0x2,%ebx
    10e1:	mov    $0x6,%r13d
    10e7:	jmp    126f <botlish_fn_6+0x1027>
    10ec:	mov    0x80(%rsp),%rdi
    10f4:	call   10f9 <botlish_fn_6+0xeb1>
			10f5: R_X86_64_PLT32	botlish_fn_1-0x4
    10f9:	cmp    $0x6,%rax
    10fd:	je     1113 <botlish_fn_6+0xecb>
    1103:	mov    $0x2,%ebx
    1108:	mov    $0x6,%r13d
    110e:	jmp    126f <botlish_fn_6+0x1027>
    1113:	mov    $0x6,%ebx
    1118:	movq   $0x6,0x50(%rsp)
    1121:	mov    $0x2,%r13d
    1127:	movq   $0x2,0x58(%rsp)
    1130:	mov    $0x5,%r14d
    1136:	jmp    12d0 <botlish_fn_6+0x1088>
    113b:	mov    %rsi,%rbx
    113e:	mov    0x80(%rsp),%rdi
    1146:	call   114b <botlish_fn_6+0xf03>
			1147: R_X86_64_PLT32	botlish_fn_1-0x4
    114b:	cmp    $0x6,%rax
    114f:	je     1286 <botlish_fn_6+0x103e>
    1155:	mov    %rbx,%rsi
    1158:	test   $0x1,%rsi
    115f:	jne    118f <botlish_fn_6+0xf47>
    1165:	mov    $0x5d,%edx
    116a:	mov    %rbx,%rsi
    116d:	mov    0x80(%rsp),%rdi
    1175:	call   117a <botlish_fn_6+0xf32>
			1176: R_X86_64_PLT32	rt_int_cmp-0x4
    117a:	mov    $0x2,%ecx
    117f:	test   %rax,%rax
    1182:	cmove  0x686(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
    118a:	jmp    11a3 <botlish_fn_6+0xf5b>
    118f:	mov    $0x2,%ecx
    1194:	mov    %rbx,%rsi
    1197:	cmp    $0x5d,%rsi
    119b:	cmove  0x66d(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
    11a3:	cmp    $0x6,%rcx
    11a7:	je     11bd <botlish_fn_6+0xf75>
    11ad:	mov    $0x2,%ebx
    11b2:	mov    $0x6,%r13d
    11b8:	jmp    126f <botlish_fn_6+0x1027>
    11bd:	mov    $0x6,%ebx
    11c2:	movq   $0x6,0x50(%rsp)
    11cb:	mov    $0x2,%r13d
    11d1:	movq   $0x2,0x58(%rsp)
    11da:	mov    0xa0(%rsp),%r14
    11e2:	jmp    12d0 <botlish_fn_6+0x1088>
    11e7:	mov    %rsi,%rbx
    11ea:	jmp    124a <botlish_fn_6+0x1002>
    11ef:	mov    %rsi,%rbx
    11f2:	test   $0x1,%rsi
    11f9:	jne    1229 <botlish_fn_6+0xfe1>
    11ff:	mov    $0x5b,%edx
    1204:	mov    %rbx,%rsi
    1207:	mov    0x80(%rsp),%rdi
    120f:	call   1214 <botlish_fn_6+0xfcc>
			1210: R_X86_64_PLT32	rt_int_cmp-0x4
    1214:	mov    $0x2,%ecx
    1219:	test   %rax,%rax
    121c:	cmove  0x5ec(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
    1224:	jmp    123d <botlish_fn_6+0xff5>
    1229:	mov    $0x2,%ecx
    122e:	mov    %rbx,%rsi
    1231:	cmp    $0x5b,%rsi
    1235:	cmove  0x5d3(%rip),%rcx        # 1810 <botlish_fn_6+0x15c8>
    123d:	cmp    $0x6,%rcx
    1241:	je     12b0 <botlish_fn_6+0x1068>
    1247:	mov    %rbx,%rsi
    124a:	mov    %rbx,%rsi
    124d:	mov    0x80(%rsp),%rdi
    1255:	call   125a <botlish_fn_6+0x1012>
			1256: R_X86_64_PLT32	botlish_fn_1-0x4
    125a:	cmp    $0x6,%rax
    125e:	je     1286 <botlish_fn_6+0x103e>
    1264:	mov    $0x2,%ebx
    1269:	mov    $0x6,%r13d
    126f:	mov    %rbx,0x50(%rsp)
    1274:	mov    %r13,0x58(%rsp)
    1279:	mov    0xa8(%rsp),%r14
    1281:	jmp    12d0 <botlish_fn_6+0x1088>
    1286:	mov    $0x6,%ebx
    128b:	movq   $0x6,0x50(%rsp)
    1294:	mov    $0x2,%r13d
    129a:	movq   $0x2,0x58(%rsp)
    12a3:	mov    0xc0(%rsp),%r14
    12ab:	jmp    12d0 <botlish_fn_6+0x1088>
    12b0:	mov    $0x6,%ebx
    12b5:	movq   $0x6,0x50(%rsp)
    12be:	mov    $0x2,%r13d
    12c4:	movq   $0x2,0x58(%rsp)
    12cd:	mov    %r13,%r14
    12d0:	mov    %r13,0x48(%rsp)
    12d5:	cmp    $0x6,%rbx
    12d9:	je     12e7 <botlish_fn_6+0x109f>
    12df:	mov    %r13,%r12
    12e2:	jmp    1550 <botlish_fn_6+0x1308>
    12e7:	mov    $0x7,%r12d
    12ed:	movq   $0x7,0x10(%rsp)
    12f6:	mov    0xb0(%rsp),%rcx
    12fe:	mov    0x10(%rcx),%rax
    1302:	mov    0x18(%rax),%rsi
    1306:	mov    %rsi,0x18(%rsp)
    130b:	movq   $0x3,0x20(%rsp)
    1314:	test   $0x1,%rsi
    131b:	je     1340 <botlish_fn_6+0x10f8>
    1321:	mov    %rsi,%rcx
    1324:	add    $0x2,%rcx
    1328:	seto   %dl
    132b:	test   %dl,%dl
    132d:	jne    1340 <botlish_fn_6+0x10f8>
    1333:	mov    0xb0(%rsp),%rax
    133b:	jmp    1360 <botlish_fn_6+0x1118>
    1340:	mov    0xc0(%rsp),%rdx
    1348:	mov    0x80(%rsp),%rdi
    1350:	call   1355 <botlish_fn_6+0x110d>
			1351: R_X86_64_PLT32	rt_int_add-0x4
    1355:	mov    %rax,%rcx
    1358:	mov    0xb0(%rsp),%rax
    1360:	mov    0xb0(%rsp),%rax
    1368:	mov    0x18(%rax),%rsi
    136c:	test   %rsi,%rsi
    136f:	je     17aa <botlish_fn_6+0x1562>
    1375:	mov    0xb0(%rsp),%rax
    137d:	mov    0x10(%rax),%r8
    1381:	mov    %rcx,0x18(%r8)
    1385:	mov    0x90(%rsp),%rcx
    138d:	cmp    $0x1,%rcx
    1391:	je     1431 <botlish_fn_6+0x11e9>
    1397:	mov    0x90(%rsp),%rcx
    139f:	cmp    $0xffffffffffffffff,%rcx
    13a3:	jne    13b1 <botlish_fn_6+0x1169>
    13a9:	mov    %r13,%r12
    13ac:	jmp    1524 <botlish_fn_6+0x12dc>
    13b1:	mov    $0xa,%esi
    13b6:	mov    0x80(%rsp),%rdi
    13be:	call   13c3 <botlish_fn_6+0x117b>
			13bf: R_X86_64_PLT32	rt_co_resume0-0x4
    13c3:	test   %rax,%rax
    13c6:	je     13e5 <botlish_fn_6+0x119d>
    13cc:	mov    0x80(%rsp),%rdi
    13d4:	mov    0x10(%rdi),%rax
    13d8:	mov    0x8(%rax),%rsi
    13dc:	mov    0x30(%rax),%rdx
    13e0:	call   13e5 <botlish_fn_6+0x119d>
			13e1: R_X86_64_PLT32	rt_raise-0x4
    13e5:	mov    0x80(%rsp),%rdi
    13ed:	call   13f2 <botlish_fn_6+0x11aa>
			13ee: R_X86_64_PLT32	rt_declared_error-0x4
    13f2:	cmp    $0x40000001,%rax
    13f8:	je     140b <botlish_fn_6+0x11c3>
    13fe:	mov    0x80(%rsp),%rdi
    1406:	jmp    1413 <botlish_fn_6+0x11cb>
    140b:	mov    0x80(%rsp),%rdi
    1413:	mov    0x80(%rsp),%rdi
    141b:	call   1420 <botlish_fn_6+0x11d8>
			141c: R_X86_64_PLT32	rt_declared_error-0x4
    1420:	cmp    $0x40000001,%rax
    1426:	jne    1691 <botlish_fn_6+0x1449>
    142c:	jmp    1691 <botlish_fn_6+0x1449>
    1431:	mov    %r13,%r12
    1434:	add    $0x1,%r15
    143b:	mov    0xc8(%rsp),%r8
    1443:	cmp    %r8,%r15
    1446:	jl     1472 <botlish_fn_6+0x122a>
    144c:	movq   $0xffffffffffffffff,0x28(%rsp)
    1455:	mov    0xa8(%rsp),%rax
    145d:	mov    %rax,0x90(%rsp)
    1465:	mov    %rax,0x98(%rsp)
    146d:	jmp    1524 <botlish_fn_6+0x12dc>
    1472:	mov    0x88(%rsp),%rcx
    147a:	movzbq 0x18(%rcx),%rax
    147f:	test   %rax,%rax
    1482:	jne    14b4 <botlish_fn_6+0x126c>
    1488:	mov    %r15,%rdx
    148b:	shl    $1,%rdx
    148e:	or     $0x1,%rdx
    1492:	mov    0x88(%rsp),%rsi
    149a:	mov    0x80(%rsp),%rdi
    14a2:	call   14a7 <botlish_fn_6+0x125f>
			14a3: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    14a7:	mov    %rax,0x98(%rsp)
    14af:	jmp    14ef <botlish_fn_6+0x12a7>
    14b4:	mov    %r15,%rax
    14b7:	shl    $1,%rax
    14ba:	or     $0x1,%rax
    14be:	sar    $1,%rax
    14c1:	mov    0x88(%rsp),%rcx
    14c9:	movzbq 0x19(%rcx,%rax,1),%rax
    14cf:	mov    %rax,0x98(%rsp)
    14d7:	shl    $0x3,%rax
    14db:	mov    %rax,0x98(%rsp)
    14e3:	or     $0x4,%rax
    14e7:	mov    %rax,0x98(%rsp)
    14ef:	shr    $0x3,%rax
    14f3:	mov    %rax,0x98(%rsp)
    14fb:	mov    $0x1,%ecx
    1500:	mov    %rcx,0x90(%rsp)
    1508:	shl    $1,%rax
    150b:	mov    %rax,0x98(%rsp)
    1513:	or     $0x1,%rax
    1517:	mov    %rax,0x98(%rsp)
    151f:	mov    %rax,0x28(%rsp)
    1524:	mov    0xb8(%rsp),%rcx
    152c:	mov    0x18(%rcx),%rax
    1530:	test   %rax,%rax
    1533:	je     17c7 <botlish_fn_6+0x157f>
    1539:	mov    0xb8(%rsp),%rcx
    1541:	mov    0x10(%rcx),%rax
    1545:	mov    0x98(%rsp),%rcx
    154d:	mov    %rcx,(%rax)
    1550:	cmp    $0x6,%r13
    1554:	je     156a <botlish_fn_6+0x1322>
    155a:	mov    0xb8(%rsp),%rcx
    1562:	mov    %r12,%r13
    1565:	jmp    1041 <botlish_fn_6+0xdf9>
    156a:	movq   $0x1,0x10(%rsp)
    1573:	mov    0xb0(%rsp),%rcx
    157b:	mov    0x10(%rcx),%rax
    157f:	mov    (%rax),%rsi
    1582:	mov    %rsi,0x18(%rsp)
    1587:	movq   $0x3,0x20(%rsp)
    1590:	test   $0x1,%rsi
    1597:	je     15bc <botlish_fn_6+0x1374>
    159d:	mov    %rsi,%rcx
    15a0:	add    $0x2,%rcx
    15a4:	seto   %dl
    15a7:	test   %dl,%dl
    15a9:	jne    15bc <botlish_fn_6+0x1374>
    15af:	mov    0xb0(%rsp),%rsi
    15b7:	jmp    15dc <botlish_fn_6+0x1394>
    15bc:	mov    0xc0(%rsp),%rdx
    15c4:	mov    0x80(%rsp),%rdi
    15cc:	call   15d1 <botlish_fn_6+0x1389>
			15cd: R_X86_64_PLT32	rt_int_add-0x4
    15d1:	mov    %rax,%rcx
    15d4:	mov    0xb0(%rsp),%rsi
    15dc:	mov    0xb0(%rsp),%rsi
    15e4:	mov    0x18(%rsi),%rsi
    15e8:	test   %rsi,%rsi
    15eb:	je     17ee <botlish_fn_6+0x15a6>
    15f1:	mov    0xb0(%rsp),%r11
    15f9:	mov    0x10(%r11),%r8
    15fd:	mov    %rcx,(%r8)
    1600:	mov    0xb8(%rsp),%rcx
    1608:	mov    %r15,%r13
    160b:	jmp    44c <botlish_fn_6+0x204>
    1610:	mov    0xb0(%rsp),%rcx
    1618:	mov    0x10(%rcx),%rax
    161c:	mov    (%rax),%rax
    161f:	mov    %rax,(%rsp)
    1623:	mov    0x10(%rcx),%rcx
    1627:	mov    0x8(%rcx),%rcx
    162b:	mov    %rcx,0x10(%rsp)
    1630:	mov    0xb0(%rsp),%rdx
    1638:	mov    0x10(%rdx),%rdx
    163c:	mov    0x10(%rdx),%rdx
    1640:	mov    %rdx,0x18(%rsp)
    1645:	mov    0xb0(%rsp),%rsi
    164d:	mov    0x10(%rsi),%rsi
    1651:	mov    0x18(%rsi),%rsi
    1655:	mov    %rsi,0x8(%rsp)
    165a:	lea    0x60(%rsp),%rdi
    165f:	mov    %rax,0x60(%rsp)
    1664:	mov    %rcx,0x68(%rsp)
    1669:	mov    %rdx,0x70(%rsp)
    166e:	mov    %rsi,0x78(%rsp)
    1673:	mov    $0x4,%esi
    1678:	mov    %rdi,%rdx
    167b:	mov    0x80(%rsp),%rdi
    1683:	call   1688 <botlish_fn_6+0x1440>
			1684: R_X86_64_PLT32	rt_list_new-0x4
    1688:	test   %rax,%rax
    168b:	jne    16c8 <botlish_fn_6+0x1480>
    1691:	xor    %rax,%rax
    1694:	mov    0xd0(%rsp),%rbx
    169c:	mov    0xd8(%rsp),%r12
    16a4:	mov    0xe0(%rsp),%r13
    16ac:	mov    0xe8(%rsp),%r14
    16b4:	mov    0xf0(%rsp),%r15
    16bc:	add    $0x100,%rsp
    16c3:	mov    %rbp,%rsp
    16c6:	pop    %rbp
    16c7:	ret
    16c8:	mov    0xd0(%rsp),%rbx
    16d0:	mov    0xd8(%rsp),%r12
    16d8:	mov    0xe0(%rsp),%r13
    16e0:	mov    0xe8(%rsp),%r14
    16e8:	mov    0xf0(%rsp),%r15
    16f0:	add    $0x100,%rsp
    16f7:	mov    %rbp,%rsp
    16fa:	pop    %rbp
    16fb:	ret
    16fc:	mov    $0x5,%edx
    1701:	mov    0xb0(%rsp),%rsi
    1709:	mov    0x80(%rsp),%rdi
    1711:	call   1716 <botlish_fn_6+0x14ce>
			1712: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1716:	jmp    845 <botlish_fn_6+0x5fd>
    171b:	mov    $0x1,%edx
    1720:	mov    0x98(%rsp),%rcx
    1728:	mov    0xb8(%rsp),%rsi
    1730:	mov    0x80(%rsp),%rdi
    1738:	call   173d <botlish_fn_6+0x14f5>
			1739: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    173d:	jmp    a10 <botlish_fn_6+0x7c8>
    1742:	mov    $0x7,%edx
    1747:	mov    0xb0(%rsp),%rsi
    174f:	mov    0x80(%rsp),%rdi
    1757:	call   175c <botlish_fn_6+0x1514>
			1758: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    175c:	jmp    d6a <botlish_fn_6+0xb22>
    1761:	mov    $0x1,%edx
    1766:	mov    0x98(%rsp),%rcx
    176e:	mov    0xb8(%rsp),%rsi
    1776:	mov    0x80(%rsp),%rdi
    177e:	call   1783 <botlish_fn_6+0x153b>
			177f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1783:	jmp    f35 <botlish_fn_6+0xced>
    1788:	mov    0xc0(%rsp),%rdx
    1790:	mov    0xb0(%rsp),%rsi
    1798:	mov    0x80(%rsp),%rdi
    17a0:	call   17a5 <botlish_fn_6+0x155d>
			17a1: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    17a5:	jmp    fe7 <botlish_fn_6+0xd9f>
    17aa:	mov    %r12,%rdx
    17ad:	mov    0xb0(%rsp),%rsi
    17b5:	mov    0x80(%rsp),%rdi
    17bd:	call   17c2 <botlish_fn_6+0x157a>
			17be: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    17c2:	jmp    1385 <botlish_fn_6+0x113d>
    17c7:	mov    $0x1,%edx
    17cc:	mov    0x98(%rsp),%rcx
    17d4:	mov    0xb8(%rsp),%rsi
    17dc:	mov    0x80(%rsp),%rdi
    17e4:	call   17e9 <botlish_fn_6+0x15a1>
			17e5: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    17e9:	jmp    1550 <botlish_fn_6+0x1308>
    17ee:	mov    $0x1,%edx
    17f3:	mov    0xb0(%rsp),%rsi
    17fb:	mov    0x80(%rsp),%rdi
    1803:	call   1808 <botlish_fn_6+0x15c0>
			1804: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1808:	jmp    1600 <botlish_fn_6+0x13b8>
    180d:	add    %al,(%rax)
    180f:	add    %al,(%rsi)
    1811:	add    %al,(%rax)
    1813:	add    %al,(%rax)
    1815:	add    %al,(%rax)
	...

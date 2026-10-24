<botlish_fn_24>:
    3270:	push   %rbp
    3271:	mov    %rsp,%rbp
    3274:	sub    $0x80,%rsp
    327b:	mov    %rbx,0x50(%rsp)
    3280:	mov    %r12,0x58(%rsp)
    3285:	mov    %r13,0x60(%rsp)
    328a:	mov    %r14,0x68(%rsp)
    328f:	mov    %r15,0x70(%rsp)
    3294:	mov    %rdi,%r13
    3297:	movq   $0x0,(%rsp)
    329f:	movq   $0x0,0x8(%rsp)
    32a8:	movq   $0x0,0x10(%rsp)
    32b1:	movq   $0x0,0x18(%rsp)
    32ba:	movq   $0x0,0x20(%rsp)
    32c3:	movq   $0x0,0x28(%rsp)
    32cc:	mov    %r13,%rdi
    32cf:	call   32d4 <botlish_fn_24+0x64>
			32d0: R_X86_64_PLT32	botlish_fn_23-0x4
    32d4:	test   %rax,%rax
    32d7:	je     36a0 <botlish_fn_24+0x430>
    32dd:	mov    %rax,(%rsp)
    32e1:	mov    %rax,%rbx
    32e4:	mov    $0x7,%esi
    32e9:	movq   $0x7,0x8(%rsp)
    32f2:	mov    $0x1,%edx
    32f7:	movq   $0x1,0x10(%rsp)
    3300:	mov    %r13,%rdi
    3303:	call   3308 <botlish_fn_24+0x98>
			3304: R_X86_64_PLT32	rt_mutarray_create-0x4
    3308:	mov    %rax,%r12
    330b:	test   %r12,%r12
    330e:	je     36a0 <botlish_fn_24+0x430>
    3314:	mov    %r12,0x8(%rsp)
    3319:	lea    0x30(%rsp),%r8
    331e:	mov    %rbx,%rax
    3321:	mov    %rax,0x30(%rsp)
    3326:	mov    $0x19,%esi
    332b:	mov    0x0(%rip),%rdx        # 3332 <botlish_fn_24+0xc2>
			332e: R_X86_64_GOTPCREL	botlish_entry_25-0x4
    3332:	mov    $0x1,%ecx
    3337:	mov    %r13,%rdi
    333a:	call   333f <botlish_fn_24+0xcf>
			333b: R_X86_64_PLT32	rt_closure_new-0x4
    333f:	mov    %rax,(%rsp)
    3343:	mov    %rax,%rsi
    3346:	mov    %r13,%rdi
    3349:	call   334e <botlish_fn_24+0xde>
			334a: R_X86_64_PLT32	rt_co_create-0x4
    334e:	mov    %rax,%r14
    3351:	mov    %rax,(%rsp)
    3355:	mov    %r14,%rsi
    3358:	mov    %r13,%rdi
    335b:	call   3360 <botlish_fn_24+0xf0>
			335c: R_X86_64_PLT32	rt_co_start-0x4
    3360:	test   %rax,%rax
    3363:	mov    %rax,%rcx
    3366:	jne    3390 <botlish_fn_24+0x120>
    336c:	mov    %r13,%rdi
    336f:	call   3374 <botlish_fn_24+0x104>
			3370: R_X86_64_PLT32	rt_declared_error-0x4
    3374:	cmp    $0x40000001,%rax
    337a:	jne    36a0 <botlish_fn_24+0x430>
    3380:	mov    %r14,%rsi
    3383:	mov    %r13,%rdi
    3386:	call   338b <botlish_fn_24+0x11b>
			3387: R_X86_64_PLT32	rt_co_release-0x4
    338b:	jmp    36a0 <botlish_fn_24+0x430>
    3390:	mov    0x18(%r12),%rax
    3395:	test   %rax,%rax
    3398:	je     36ed <botlish_fn_24+0x47d>
    339e:	mov    0x10(%r12),%rsi
    33a3:	mov    %r12,%rbx
    33a6:	mov    %rcx,0x10(%rsi)
    33aa:	mov    $0x7fffffff,%esi
    33af:	mov    %rsi,%r12
    33b2:	neg    %r12
    33b5:	cmovs  %rsi,%r12
    33b9:	mov    %r14,%rsi
    33bc:	mov    %r13,%rdi
    33bf:	call   33c4 <botlish_fn_24+0x154>
			33c0: R_X86_64_PLT32	rt_co_done-0x4
    33c4:	cmp    $0x6,%rax
    33c8:	je     3658 <botlish_fn_24+0x3e8>
    33ce:	movq   $0x1,0x10(%rsp)
    33d7:	mov    0x10(%rbx),%r11
    33db:	mov    (%r11),%rsi
    33de:	mov    %rsi,0x18(%rsp)
    33e3:	mov    0x10(%rbx),%rax
    33e7:	mov    0x10(%rax),%rdx
    33eb:	mov    %rdx,0x20(%rsp)
    33f0:	mov    %rdx,%r15
    33f3:	movq   $0x3f,0x28(%rsp)
    33fc:	test   $0x1,%rsi
    3403:	je     342d <botlish_fn_24+0x1bd>
    3409:	mov    %rsi,%rax
    340c:	sar    $1,%rax
    340f:	imulq  0x332(%rip)        # 3748 <botlish_fn_24+0x4d8>
    3416:	seto   %cl
    3419:	or     $0x1,%rax
    341d:	test   %cl,%cl
    341f:	jne    342d <botlish_fn_24+0x1bd>
    3425:	mov    %rax,%rsi
    3428:	jmp    343d <botlish_fn_24+0x1cd>
    342d:	mov    $0x3f,%edx
    3432:	mov    %r13,%rdi
    3435:	call   343a <botlish_fn_24+0x1ca>
			3436: R_X86_64_PLT32	rt_int_mul-0x4
    343a:	mov    %rax,%rsi
    343d:	mov    %rsi,0x18(%rsp)
    3442:	mov    %r15,%rdx
    3445:	mov    %rsi,%rax
    3448:	and    %rdx,%rax
    344b:	test   $0x1,%rax
    3451:	je     346c <botlish_fn_24+0x1fc>
    3457:	lea    -0x1(%rdx),%rcx
    345b:	mov    %rsi,%rax
    345e:	add    %rcx,%rax
    3461:	seto   %cl
    3464:	test   %cl,%cl
    3466:	je     3474 <botlish_fn_24+0x204>
    346c:	mov    %r13,%rdi
    346f:	call   3474 <botlish_fn_24+0x204>
			3470: R_X86_64_PLT32	rt_int_add-0x4
    3474:	mov    %rax,0x18(%rsp)
    3479:	movq   $0x3,0x20(%rsp)
    3482:	test   $0x1,%rax
    3488:	jne    3496 <botlish_fn_24+0x226>
    348e:	mov    %rax,%rcx
    3491:	jmp    34ab <botlish_fn_24+0x23b>
    3496:	mov    %rax,%rsi
    3499:	add    $0x2,%rsi
    349d:	mov    %rax,%rcx
    34a0:	seto   %al
    34a3:	test   %al,%al
    34a5:	je     34be <botlish_fn_24+0x24e>
    34ab:	mov    $0x3,%edx
    34b0:	mov    %rcx,%rsi
    34b3:	mov    %r13,%rdi
    34b6:	call   34bb <botlish_fn_24+0x24b>
			34b7: R_X86_64_PLT32	rt_int_add-0x4
    34bb:	mov    %rax,%rsi
    34be:	mov    %rsi,0x18(%rsp)
    34c3:	mov    $0xffffffff,%eax
    34c8:	mov    %rax,0x20(%rsp)
    34cd:	test   $0x1,%rsi
    34d4:	jne    351c <botlish_fn_24+0x2ac>
    34da:	mov    $0xffffffff,%edx
    34df:	mov    %r13,%rdi
    34e2:	call   34e7 <botlish_fn_24+0x277>
			34e3: R_X86_64_PLT32	rt_int_mod-0x4
    34e7:	test   %rax,%rax
    34ea:	jne    3514 <botlish_fn_24+0x2a4>
    34f0:	mov    %r13,%rdi
    34f3:	call   34f8 <botlish_fn_24+0x288>
			34f4: R_X86_64_PLT32	rt_declared_error-0x4
    34f8:	cmp    $0x40000001,%rax
    34fe:	jne    36a0 <botlish_fn_24+0x430>
    3504:	mov    %r14,%rsi
    3507:	mov    %r13,%rdi
    350a:	call   350f <botlish_fn_24+0x29f>
			350b: R_X86_64_PLT32	rt_co_release-0x4
    350f:	jmp    36a0 <botlish_fn_24+0x430>
    3514:	mov    %rax,%rcx
    3517:	jmp    355a <botlish_fn_24+0x2ea>
    351c:	sar    $1,%rsi
    351f:	mov    %rsi,%rax
    3522:	imulq  0x227(%rip)        # 3750 <botlish_fn_24+0x4e0>
    3529:	lea    (%rdx,%rsi,1),%rax
    352d:	sar    $0x1e,%rax
    3531:	mov    %rax,%rcx
    3534:	shr    $0x3f,%rcx
    3538:	add    %rcx,%rax
    353b:	imul   $0x7fffffff,%rax,%rax
    3542:	sub    %rax,%rsi
    3545:	lea    (%rsi,%r12,1),%rax
    3549:	test   %rsi,%rsi
    354c:	cmovl  %rax,%rsi
    3550:	shl    $1,%rsi
    3553:	or     $0x1,%rsi
    3557:	mov    %rsi,%rcx
    355a:	mov    0x18(%rbx),%rax
    355e:	test   %rax,%rax
    3561:	je     3705 <botlish_fn_24+0x495>
    3567:	mov    0x10(%rbx),%rax
    356b:	mov    %rcx,(%rax)
    356e:	movq   $0x3,0x10(%rsp)
    3577:	mov    0x10(%rbx),%rax
    357b:	mov    0x8(%rax),%rsi
    357f:	mov    %rsi,0x18(%rsp)
    3584:	movq   $0x3,0x20(%rsp)
    358d:	test   $0x1,%rsi
    3594:	je     35ae <botlish_fn_24+0x33e>
    359a:	mov    %rsi,%rcx
    359d:	add    $0x2,%rcx
    35a1:	seto   %dil
    35a5:	test   %dil,%dil
    35a8:	je     35be <botlish_fn_24+0x34e>
    35ae:	mov    $0x3,%edx
    35b3:	mov    %r13,%rdi
    35b6:	call   35bb <botlish_fn_24+0x34b>
			35b7: R_X86_64_PLT32	rt_int_add-0x4
    35bb:	mov    %rax,%rcx
    35be:	mov    0x18(%rbx),%r10
    35c2:	test   %r10,%r10
    35c5:	je     371a <botlish_fn_24+0x4aa>
    35cb:	mov    0x10(%rbx),%rax
    35cf:	mov    %rcx,0x8(%rax)
    35d3:	mov    $0x5,%edx
    35d8:	mov    %rdx,%r15
    35db:	movq   $0x5,0x10(%rsp)
    35e4:	mov    %r14,%rsi
    35e7:	mov    %r13,%rdi
    35ea:	call   35ef <botlish_fn_24+0x37f>
			35eb: R_X86_64_PLT32	rt_co_resume0-0x4
    35ef:	test   %rax,%rax
    35f2:	mov    %rax,%rcx
    35f5:	jne    363e <botlish_fn_24+0x3ce>
    35fb:	mov    %r13,%rdi
    35fe:	call   3603 <botlish_fn_24+0x393>
			35ff: R_X86_64_PLT32	rt_declared_error-0x4
    3603:	cmp    $0x40000001,%rax
    3609:	jne    361a <botlish_fn_24+0x3aa>
    360f:	mov    %r14,%rsi
    3612:	mov    %r13,%rdi
    3615:	call   361a <botlish_fn_24+0x3aa>
			3616: R_X86_64_PLT32	rt_co_release-0x4
    361a:	mov    %r13,%rdi
    361d:	call   3622 <botlish_fn_24+0x3b2>
			361e: R_X86_64_PLT32	rt_declared_error-0x4
    3622:	cmp    $0x40000001,%rax
    3628:	jne    36a0 <botlish_fn_24+0x430>
    362e:	mov    %r14,%rsi
    3631:	mov    %r13,%rdi
    3634:	call   3639 <botlish_fn_24+0x3c9>
			3635: R_X86_64_PLT32	rt_co_release-0x4
    3639:	jmp    36a0 <botlish_fn_24+0x430>
    363e:	mov    0x18(%rbx),%rax
    3642:	test   %rax,%rax
    3645:	je     372f <botlish_fn_24+0x4bf>
    364b:	mov    0x10(%rbx),%rax
    364f:	mov    %rcx,0x10(%rax)
    3653:	jmp    33b9 <botlish_fn_24+0x149>
    3658:	mov    %r14,%rsi
    365b:	mov    %r13,%rdi
    365e:	call   3663 <botlish_fn_24+0x3f3>
			365f: R_X86_64_PLT32	rt_co_release-0x4
    3663:	mov    0x10(%rbx),%rax
    3667:	mov    0x8(%rax),%rax
    366b:	mov    %rax,(%rsp)
    366f:	mov    0x10(%rbx),%rcx
    3673:	mov    (%rcx),%rcx
    3676:	mov    %rcx,0x8(%rsp)
    367b:	lea    0x38(%rsp),%rdx
    3680:	mov    %rax,0x38(%rsp)
    3685:	mov    %rcx,0x40(%rsp)
    368a:	mov    $0x2,%esi
    368f:	mov    %r13,%rdi
    3692:	call   3697 <botlish_fn_24+0x427>
			3693: R_X86_64_PLT32	rt_list_new-0x4
    3697:	test   %rax,%rax
    369a:	jne    36c8 <botlish_fn_24+0x458>
    36a0:	xor    %rax,%rax
    36a3:	mov    0x50(%rsp),%rbx
    36a8:	mov    0x58(%rsp),%r12
    36ad:	mov    0x60(%rsp),%r13
    36b2:	mov    0x68(%rsp),%r14
    36b7:	mov    0x70(%rsp),%r15
    36bc:	add    $0x80,%rsp
    36c3:	mov    %rbp,%rsp
    36c6:	pop    %rbp
    36c7:	ret
    36c8:	mov    0x50(%rsp),%rbx
    36cd:	mov    0x58(%rsp),%r12
    36d2:	mov    0x60(%rsp),%r13
    36d7:	mov    0x68(%rsp),%r14
    36dc:	mov    0x70(%rsp),%r15
    36e1:	add    $0x80,%rsp
    36e8:	mov    %rbp,%rsp
    36eb:	pop    %rbp
    36ec:	ret
    36ed:	mov    $0x5,%edx
    36f2:	mov    %r12,%rsi
    36f5:	mov    %r13,%rdi
    36f8:	call   36fd <botlish_fn_24+0x48d>
			36f9: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    36fd:	mov    %r12,%rbx
    3700:	jmp    33aa <botlish_fn_24+0x13a>
    3705:	mov    $0x1,%edx
    370a:	mov    %rbx,%rsi
    370d:	mov    %r13,%rdi
    3710:	call   3715 <botlish_fn_24+0x4a5>
			3711: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    3715:	jmp    356e <botlish_fn_24+0x2fe>
    371a:	mov    $0x3,%edx
    371f:	mov    %rbx,%rsi
    3722:	mov    %r13,%rdi
    3725:	call   372a <botlish_fn_24+0x4ba>
			3726: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    372a:	jmp    35d3 <botlish_fn_24+0x363>
    372f:	mov    %r15,%rdx
    3732:	mov    %rbx,%rsi
    3735:	mov    %r13,%rdi
    3738:	call   373d <botlish_fn_24+0x4cd>
			3739: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    373d:	jmp    33b9 <botlish_fn_24+0x149>
    3742:	add    %al,(%rax)
    3744:	add    %al,(%rax)
    3746:	add    %al,(%rax)
    3748:	ds add %al,(%rax)
    374b:	add    %al,(%rax)
    374d:	add    %al,(%rax)
    374f:	add    %al,(%rbx)
    3751:	add    %al,(%rax)
    3753:	add    %al,(%rcx)
    3755:	add    %al,(%rax)
    3757:	.byte 0x80

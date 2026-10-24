<botlish_fn_18>:
    4338:	push   %rbp
    4339:	mov    %rsp,%rbp
    433c:	sub    $0x1a0,%rsp
    4343:	mov    %rbx,0x170(%rsp)
    434b:	mov    %r12,0x178(%rsp)
    4353:	mov    %r13,0x180(%rsp)
    435b:	mov    %r14,0x188(%rsp)
    4363:	mov    %r15,0x190(%rsp)
    436b:	mov    %rdi,0x130(%rsp)
    4373:	movq   $0x0,0x10(%rsp)
    437c:	movq   $0x0,0x18(%rsp)
    4385:	movq   $0x0,0x20(%rsp)
    438e:	movq   $0x0,0x28(%rsp)
    4397:	movq   $0x0,0x30(%rsp)
    43a0:	movq   $0x0,0x38(%rsp)
    43a9:	movq   $0x0,0x40(%rsp)
    43b2:	movq   $0x0,0x48(%rsp)
    43bb:	movq   $0x0,0x50(%rsp)
    43c4:	movq   $0x0,0x58(%rsp)
    43cd:	mov    %rsi,(%rsp)
    43d1:	mov    %rdx,0x8(%rsp)
    43d6:	mov    %rdx,%r15
    43d9:	lea    0x60(%rsp),%r8
    43de:	mov    %rsi,0x60(%rsp)
    43e3:	mov    $0x13,%esi
    43e8:	mov    0x0(%rip),%rdx        # 43ef <botlish_fn_18+0xb7>
			43eb: R_X86_64_GOTPCREL	botlish_entry_19-0x4
    43ef:	mov    $0x1,%ecx
    43f4:	mov    0x130(%rsp),%rdi
    43fc:	call   4401 <botlish_fn_18+0xc9>
			43fd: R_X86_64_PLT32	rt_closure_new-0x4
    4401:	mov    %rax,(%rsp)
    4405:	mov    %rax,%rsi
    4408:	mov    0x130(%rsp),%rdi
    4410:	call   4415 <botlish_fn_18+0xdd>
			4411: R_X86_64_PLT32	rt_co_create-0x4
    4415:	mov    %rax,0x168(%rsp)
    441d:	mov    %rax,(%rsp)
    4421:	mov    0x168(%rsp),%rsi
    4429:	mov    0x130(%rsp),%rdi
    4431:	call   4436 <botlish_fn_18+0xfe>
			4432: R_X86_64_PLT32	rt_co_start-0x4
    4436:	mov    %rax,%rcx
    4439:	mov    %rax,%r12
    443c:	test   %rcx,%rax
    443f:	jne    4478 <botlish_fn_18+0x140>
    4445:	mov    0x130(%rsp),%rdi
    444d:	call   4452 <botlish_fn_18+0x11a>
			444e: R_X86_64_PLT32	rt_declared_error-0x4
    4452:	cmp    $0x40000001,%rax
    4458:	jne    5901 <botlish_fn_18+0x15c9>
    445e:	mov    0x168(%rsp),%rsi
    4466:	mov    0x130(%rsp),%rdi
    446e:	call   4473 <botlish_fn_18+0x13b>
			446f: R_X86_64_PLT32	rt_co_release-0x4
    4473:	jmp    5901 <botlish_fn_18+0x15c9>
    4478:	mov    %r12,%rax
    447b:	mov    %rax,0x10(%rsp)
    4480:	mov    0x130(%rsp),%rdi
    4488:	mov    0x10(%rdi),%rax
    448c:	mov    0x150(%rax),%rax
    4493:	mov    %rax,0x18(%rsp)
    4498:	lea    0x68(%rsp),%rdx
    449d:	mov    %rax,0x68(%rsp)
    44a2:	mov    $0x1,%esi
    44a7:	call   44ac <botlish_fn_18+0x174>
			44a8: R_X86_64_PLT32	rt_list_new-0x4
    44ac:	test   %rax,%rax
    44af:	je     5901 <botlish_fn_18+0x15c9>
    44b5:	mov    %rax,0x18(%rsp)
    44ba:	mov    %rax,%rsi
    44bd:	mov    0x130(%rsp),%rdi
    44c5:	call   44ca <botlish_fn_18+0x192>
			44c6: R_X86_64_PLT32	rt_mv_from_list-0x4
    44ca:	mov    %rax,0x160(%rsp)
    44d2:	mov    %rax,0x18(%rsp)
    44d7:	mov    0x160(%rsp),%rsi
    44df:	mov    0x130(%rsp),%rdi
    44e7:	call   44ec <botlish_fn_18+0x1b4>
			44e8: R_X86_64_PLT32	rt_mv_pop-0x4
    44ec:	test   %rax,%rax
    44ef:	jne    4528 <botlish_fn_18+0x1f0>
    44f5:	mov    0x130(%rsp),%rdi
    44fd:	call   4502 <botlish_fn_18+0x1ca>
			44fe: R_X86_64_PLT32	rt_declared_error-0x4
    4502:	cmp    $0x40000001,%rax
    4508:	jne    5901 <botlish_fn_18+0x15c9>
    450e:	mov    0x168(%rsp),%rsi
    4516:	mov    0x130(%rsp),%rdi
    451e:	call   4523 <botlish_fn_18+0x1eb>
			451f: R_X86_64_PLT32	rt_co_release-0x4
    4523:	jmp    5901 <botlish_fn_18+0x15c9>
    4528:	mov    $0x5,%esi
    452d:	movq   $0x5,0x20(%rsp)
    4536:	mov    %r12,%rdx
    4539:	mov    0x130(%rsp),%rdi
    4541:	call   4546 <botlish_fn_18+0x20e>
			4542: R_X86_64_PLT32	rt_mutarray_create-0x4
    4546:	test   %rax,%rax
    4549:	je     5901 <botlish_fn_18+0x15c9>
    454f:	mov    %rax,0x20(%rsp)
    4554:	mov    %rax,%r13
    4557:	mov    $0x9,%esi
    455c:	movq   $0x9,0x28(%rsp)
    4565:	mov    $0x1,%edx
    456a:	movq   $0x1,0x30(%rsp)
    4573:	mov    0x130(%rsp),%rdi
    457b:	call   4580 <botlish_fn_18+0x248>
			457c: R_X86_64_PLT32	rt_mutarray_create-0x4
    4580:	test   %rax,%rax
    4583:	je     5901 <botlish_fn_18+0x15c9>
    4589:	mov    %rax,0x28(%rsp)
    458e:	mov    %rax,%rbx
    4591:	mov    %r12,%rax
    4594:	test   $0x1,%rax
    459a:	jne    45cc <botlish_fn_18+0x294>
    45a0:	mov    $0xffffffffffffffff,%rdx
    45a7:	mov    %r12,%rsi
    45aa:	mov    0x130(%rsp),%rdi
    45b2:	call   45b7 <botlish_fn_18+0x27f>
			45b3: R_X86_64_PLT32	rt_int_cmp-0x4
    45b7:	mov    $0x2,%ecx
    45bc:	test   %rax,%rax
    45bf:	cmove  0x1531(%rip),%rcx        # 5af8 <botlish_fn_18+0x17c0>
    45c7:	jmp    45e0 <botlish_fn_18+0x2a8>
    45cc:	mov    %r12,%rsi
    45cf:	mov    $0x2,%ecx
    45d4:	cmp    $0xffffffffffffffff,%rsi
    45d8:	cmove  0x1518(%rip),%rcx        # 5af8 <botlish_fn_18+0x17c0>
    45e0:	cmp    $0x6,%rcx
    45e4:	je     4603 <botlish_fn_18+0x2cb>
    45ea:	mov    0x18(%rbx),%rcx
    45ee:	test   %rcx,%rcx
    45f1:	je     59a9 <botlish_fn_18+0x1671>
    45f7:	mov    0x10(%rbx),%rax
    45fb:	movq   $0x3,0x8(%rax)
    4603:	mov    $0x2,%esi
    4608:	mov    %rsi,0x158(%rsp)
    4610:	mov    %rbx,%r14
    4613:	mov    0x10(%r14),%rax
    4617:	mov    (%rax),%rbx
    461a:	mov    %rbx,0x10(%rsp)
    461f:	mov    0x10(%r14),%rcx
    4623:	mov    0x8(%rcx),%rdx
    4627:	mov    %rbx,%rcx
    462a:	and    %rdx,%rcx
    462d:	test   $0x1,%rcx
    4634:	jne    466d <botlish_fn_18+0x335>
    463a:	mov    %rbx,%rsi
    463d:	mov    0x130(%rsp),%rdi
    4645:	call   464a <botlish_fn_18+0x312>
			4646: R_X86_64_PLT32	rt_int_cmp-0x4
    464a:	mov    %rbx,0x150(%rsp)
    4652:	test   %rax,%rax
    4655:	mov    0x158(%rsp),%rsi
    465d:	mov    %rsi,%rax
    4660:	cmovl  0x1490(%rip),%rax        # 5af8 <botlish_fn_18+0x17c0>
    4668:	jmp    468e <botlish_fn_18+0x356>
    466d:	mov    %rbx,%rax
    4670:	cmp    %rdx,%rax
    4673:	mov    0x158(%rsp),%rsi
    467b:	mov    %rax,0x150(%rsp)
    4683:	mov    %rsi,%rax
    4686:	cmovl  0x146a(%rip),%rax        # 5af8 <botlish_fn_18+0x17c0>
    468e:	cmp    $0x6,%rax
    4692:	je     487b <botlish_fn_18+0x543>
    4698:	mov    0x168(%rsp),%rsi
    46a0:	mov    0x130(%rsp),%rdi
    46a8:	call   46ad <botlish_fn_18+0x375>
			46a9: R_X86_64_PLT32	rt_co_resume0-0x4
    46ad:	mov    %rax,%rcx
    46b0:	mov    %rax,0x148(%rsp)
    46b8:	test   %rcx,%rax
    46bb:	jne    46f4 <botlish_fn_18+0x3bc>
    46c1:	mov    0x130(%rsp),%rdi
    46c9:	call   46ce <botlish_fn_18+0x396>
			46ca: R_X86_64_PLT32	rt_declared_error-0x4
    46ce:	cmp    $0x40000001,%rax
    46d4:	jne    5901 <botlish_fn_18+0x15c9>
    46da:	mov    0x168(%rsp),%rsi
    46e2:	mov    0x130(%rsp),%rdi
    46ea:	call   46ef <botlish_fn_18+0x3b7>
			46eb: R_X86_64_PLT32	rt_co_release-0x4
    46ef:	jmp    5901 <botlish_fn_18+0x15c9>
    46f4:	mov    0x148(%rsp),%rax
    46fc:	mov    %rax,0x30(%rsp)
    4701:	mov    0x148(%rsp),%rax
    4709:	test   $0x1,%rax
    470f:	jne    474c <botlish_fn_18+0x414>
    4715:	mov    $0xffffffffffffffff,%rdx
    471c:	mov    0x148(%rsp),%rsi
    4724:	mov    0x130(%rsp),%rdi
    472c:	call   4731 <botlish_fn_18+0x3f9>
			472d: R_X86_64_PLT32	rt_int_cmp-0x4
    4731:	test   %rax,%rax
    4734:	mov    0x158(%rsp),%rsi
    473c:	mov    %rsi,%rcx
    473f:	cmove  0x13b1(%rip),%rcx        # 5af8 <botlish_fn_18+0x17c0>
    4747:	jmp    476b <botlish_fn_18+0x433>
    474c:	mov    0x148(%rsp),%rax
    4754:	cmp    $0xffffffffffffffff,%rax
    4758:	mov    0x158(%rsp),%rsi
    4760:	mov    %rsi,%rcx
    4763:	cmove  0x138d(%rip),%rcx        # 5af8 <botlish_fn_18+0x17c0>
    476b:	cmp    $0x6,%rcx
    476f:	je     4863 <botlish_fn_18+0x52b>
    4775:	mov    $0x3,%r12d
    477b:	movq   $0x3,0x38(%rsp)
    4784:	mov    0x150(%rsp),%rdx
    478c:	test   $0x1,%rdx
    4793:	jne    47bc <botlish_fn_18+0x484>
    4799:	mov    %r12,%rdx
    479c:	mov    0x150(%rsp),%rsi
    47a4:	mov    0x130(%rsp),%rdi
    47ac:	call   47b1 <botlish_fn_18+0x479>
			47ad: R_X86_64_PLT32	rt_int_and-0x4
    47b1:	mov    %rax,%rdx
    47b4:	mov    %r13,%rbx
    47b7:	jmp    47cb <botlish_fn_18+0x493>
    47bc:	mov    0x150(%rsp),%rdx
    47c4:	and    $0x3,%rdx
    47c8:	mov    %r13,%rbx
    47cb:	mov    0x18(%rbx),%rax
    47cf:	test   %rax,%rax
    47d2:	je     59c6 <botlish_fn_18+0x168e>
    47d8:	mov    0x148(%rsp),%r13
    47e0:	mov    0x10(%rbx),%rcx
    47e4:	sar    $1,%rdx
    47e7:	mov    %r13,(%rcx,%rdx,8)
    47eb:	movq   $0x3,0x38(%rsp)
    47f4:	movq   $0x3,0x40(%rsp)
    47fd:	mov    0x150(%rsp),%rdx
    4805:	test   $0x1,%rdx
    480c:	je     482e <botlish_fn_18+0x4f6>
    4812:	mov    0x150(%rsp),%rdx
    481a:	mov    %rdx,%rcx
    481d:	add    $0x2,%rcx
    4821:	seto   %r8b
    4825:	test   %r8b,%r8b
    4828:	je     4849 <botlish_fn_18+0x511>
    482e:	mov    %r12,%rdx
    4831:	mov    0x150(%rsp),%rsi
    4839:	mov    0x130(%rsp),%rdi
    4841:	call   4846 <botlish_fn_18+0x50e>
			4842: R_X86_64_PLT32	rt_int_add-0x4
    4846:	mov    %rax,%rcx
    4849:	mov    0x18(%r14),%rax
    484d:	test   %rax,%rax
    4850:	je     59e6 <botlish_fn_18+0x16ae>
    4856:	mov    0x10(%r14),%rax
    485a:	mov    %rcx,0x8(%rax)
    485e:	jmp    486e <botlish_fn_18+0x536>
    4863:	mov    %r13,%rbx
    4866:	mov    0x148(%rsp),%r13
    486e:	mov    %r13,0x30(%rsp)
    4873:	mov    %r13,%rsi
    4876:	jmp    48da <botlish_fn_18+0x5a2>
    487b:	mov    %r13,%rbx
    487e:	mov    $0x3,%edx
    4883:	movq   $0x3,0x30(%rsp)
    488c:	mov    0x150(%rsp),%r9
    4894:	test   $0x1,%r9
    489b:	jne    48bb <botlish_fn_18+0x583>
    48a1:	mov    0x150(%rsp),%rsi
    48a9:	mov    0x130(%rsp),%rdi
    48b1:	call   48b6 <botlish_fn_18+0x57e>
			48b2: R_X86_64_PLT32	rt_int_and-0x4
    48b6:	jmp    48ca <botlish_fn_18+0x592>
    48bb:	mov    0x150(%rsp),%rdx
    48c3:	mov    %rdx,%rax
    48c6:	and    $0x3,%rax
    48ca:	mov    0x10(%rbx),%rcx
    48ce:	sar    $1,%rax
    48d1:	mov    (%rcx,%rax,8),%rsi
    48d5:	mov    %rsi,0x30(%rsp)
    48da:	test   $0x1,%rsi
    48e1:	mov    %rsi,0x138(%rsp)
    48e9:	jne    4926 <botlish_fn_18+0x5ee>
    48ef:	mov    $0xffffffffffffffff,%rdx
    48f6:	mov    0x138(%rsp),%rsi
    48fe:	mov    0x130(%rsp),%rdi
    4906:	call   490b <botlish_fn_18+0x5d3>
			4907: R_X86_64_PLT32	rt_int_cmp-0x4
    490b:	test   %rax,%rax
    490e:	mov    0x158(%rsp),%rsi
    4916:	mov    %rsi,%rax
    4919:	cmove  0x11d7(%rip),%rax        # 5af8 <botlish_fn_18+0x17c0>
    4921:	jmp    4945 <botlish_fn_18+0x60d>
    4926:	mov    0x138(%rsp),%rsi
    492e:	cmp    $0xffffffffffffffff,%rsi
    4932:	mov    0x158(%rsp),%rsi
    493a:	mov    %rsi,%rax
    493d:	cmove  0x11b3(%rip),%rax        # 5af8 <botlish_fn_18+0x17c0>
    4945:	cmp    $0x6,%rax
    4949:	je     56f7 <botlish_fn_18+0x13bf>
    494f:	movq   $0x1,0x38(%rsp)
    4958:	mov    $0x3,%r8d
    495e:	mov    %r8,0x148(%rsp)
    4966:	movq   $0x3,0x40(%rsp)
    496f:	mov    0x150(%rsp),%rdx
    4977:	test   $0x1,%rdx
    497e:	je     499e <botlish_fn_18+0x666>
    4984:	mov    0x150(%rsp),%rdx
    498c:	mov    %rdx,%rcx
    498f:	add    $0x2,%rcx
    4993:	seto   %al
    4996:	test   %al,%al
    4998:	je     49be <botlish_fn_18+0x686>
    499e:	mov    0x148(%rsp),%rdx
    49a6:	mov    0x150(%rsp),%rsi
    49ae:	mov    0x130(%rsp),%rdi
    49b6:	call   49bb <botlish_fn_18+0x683>
			49b7: R_X86_64_PLT32	rt_int_add-0x4
    49bb:	mov    %rax,%rcx
    49be:	mov    0x18(%r14),%rax
    49c2:	test   %rax,%rax
    49c5:	je     59fe <botlish_fn_18+0x16c6>
    49cb:	mov    0x10(%r14),%rax
    49cf:	mov    %rcx,(%rax)
    49d2:	mov    0x138(%rsp),%rsi
    49da:	mov    0x130(%rsp),%rdi
    49e2:	call   49e7 <botlish_fn_18+0x6af>
			49e3: R_X86_64_PLT32	botlish_fn_14-0x4
    49e7:	cmp    $0x6,%rax
    49eb:	je     56ec <botlish_fn_18+0x13b4>
    49f1:	mov    0x138(%rsp),%rsi
    49f9:	test   $0x1,%rsi
    4a00:	jne    4a3b <botlish_fn_18+0x703>
    4a06:	mov    $0x75,%edx
    4a0b:	mov    0x138(%rsp),%rsi
    4a13:	mov    0x130(%rsp),%rdi
    4a1b:	call   4a20 <botlish_fn_18+0x6e8>
			4a1c: R_X86_64_PLT32	rt_int_cmp-0x4
    4a20:	test   %rax,%rax
    4a23:	mov    0x158(%rsp),%rsi
    4a2b:	mov    %rsi,%rdi
    4a2e:	cmove  0x10c2(%rip),%rdi        # 5af8 <botlish_fn_18+0x17c0>
    4a36:	jmp    4a5a <botlish_fn_18+0x722>
    4a3b:	mov    0x138(%rsp),%rsi
    4a43:	cmp    $0x75,%rsi
    4a47:	mov    0x158(%rsp),%rsi
    4a4f:	mov    %rsi,%rdi
    4a52:	cmove  0x109e(%rip),%rdi        # 5af8 <botlish_fn_18+0x17c0>
    4a5a:	cmp    $0x6,%rdi
    4a5e:	jne    4aca <botlish_fn_18+0x792>
    4a64:	mov    0x10(%r14),%rsi
    4a68:	mov    0x10(%rsi),%rsi
    4a6c:	test   $0x1,%rsi
    4a73:	jne    4aa9 <botlish_fn_18+0x771>
    4a79:	mov    0x148(%rsp),%rdx
    4a81:	mov    0x130(%rsp),%rdi
    4a89:	call   4a8e <botlish_fn_18+0x756>
			4a8a: R_X86_64_PLT32	rt_int_cmp-0x4
    4a8e:	test   %rax,%rax
    4a91:	mov    0x158(%rsp),%rsi
    4a99:	mov    %rsi,%rax
    4a9c:	cmove  0x1054(%rip),%rax        # 5af8 <botlish_fn_18+0x17c0>
    4aa4:	jmp    4ac0 <botlish_fn_18+0x788>
    4aa9:	cmp    $0x3,%rsi
    4aad:	mov    0x158(%rsp),%rsi
    4ab5:	mov    %rsi,%rax
    4ab8:	cmove  0x1038(%rip),%rax        # 5af8 <botlish_fn_18+0x17c0>
    4ac0:	cmp    $0x6,%rax
    4ac4:	je     560a <botlish_fn_18+0x12d2>
    4aca:	lea    0x70(%rsp),%r8
    4acf:	mov    0x138(%rsp),%rsi
    4ad7:	mov    %rsi,0x70(%rsp)
    4adc:	mov    $0x14,%esi
    4ae1:	mov    0x0(%rip),%rdx        # 4ae8 <botlish_fn_18+0x7b0>
			4ae4: R_X86_64_GOTPCREL	botlish_entry_20-0x4
    4ae8:	mov    $0x1,%ecx
    4aed:	mov    0x130(%rsp),%rdi
    4af5:	call   4afa <botlish_fn_18+0x7c2>
			4af6: R_X86_64_PLT32	rt_closure_new-0x4
    4afa:	mov    %rax,0x38(%rsp)
    4aff:	mov    %rax,%rsi
    4b02:	mov    0x130(%rsp),%rdi
    4b0a:	call   4b0f <botlish_fn_18+0x7d7>
			4b0b: R_X86_64_PLT32	rt_co_create-0x4
    4b0f:	mov    %rax,0x140(%rsp)
    4b17:	mov    %rax,0x38(%rsp)
    4b1c:	mov    0x140(%rsp),%rsi
    4b24:	mov    0x130(%rsp),%rdi
    4b2c:	call   4b31 <botlish_fn_18+0x7f9>
			4b2d: R_X86_64_PLT32	rt_co_start-0x4
    4b31:	test   %rax,%rax
    4b34:	mov    %rax,%rcx
    4b37:	jne    4d03 <botlish_fn_18+0x9cb>
    4b3d:	mov    0x130(%rsp),%rdi
    4b45:	call   4b4a <botlish_fn_18+0x812>
			4b46: R_X86_64_PLT32	rt_declared_error-0x4
    4b4a:	cmp    $0x1,%rax
    4b4e:	je     4c28 <botlish_fn_18+0x8f0>
    4b54:	mov    0x130(%rsp),%rdi
    4b5c:	call   4b61 <botlish_fn_18+0x829>
			4b5d: R_X86_64_PLT32	rt_declared_error-0x4
    4b61:	cmp    $0x2,%rax
    4b65:	jne    5901 <botlish_fn_18+0x15c9>
    4b6b:	xor    %rsi,%rsi
    4b6e:	mov    0x130(%rsp),%rdi
    4b76:	call   4b7b <botlish_fn_18+0x843>
			4b77: R_X86_64_PLT32	rt_declared_payload-0x4
    4b7b:	mov    %rax,%r12
    4b7e:	mov    $0x1,%ebx
    4b83:	mov    %rbx,%rsi
    4b86:	mov    0x130(%rsp),%rdi
    4b8e:	call   4b93 <botlish_fn_18+0x85b>
			4b8f: R_X86_64_PLT32	rt_declared_payload-0x4
    4b93:	mov    %rax,%r13
    4b96:	mov    0x130(%rsp),%rdi
    4b9e:	call   4ba3 <botlish_fn_18+0x86b>
			4b9f: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4ba3:	mov    0x168(%rsp),%rsi
    4bab:	mov    0x130(%rsp),%rdi
    4bb3:	call   4bb8 <botlish_fn_18+0x880>
			4bb4: R_X86_64_PLT32	rt_co_release-0x4
    4bb8:	mov    0x140(%rsp),%rsi
    4bc0:	mov    0x130(%rsp),%rdi
    4bc8:	call   4bcd <botlish_fn_18+0x895>
			4bc9: R_X86_64_PLT32	rt_co_release-0x4
    4bcd:	mov    0x130(%rsp),%rdi
    4bd5:	mov    0x10(%rdi),%rax
    4bd9:	mov    0x160(%rax),%rdx
    4be0:	lea    0x98(%rsp),%r9
    4be8:	mov    0x150(%rsp),%rax
    4bf0:	mov    %rax,0x98(%rsp)
    4bf8:	mov    %r12,%rax
    4bfb:	mov    %rax,0xa0(%rsp)
    4c03:	mov    %r13,%rax
    4c06:	mov    %rax,0xa8(%rsp)
    4c0e:	mov    $0x4,%esi
    4c13:	mov    %rbx,%rcx
    4c16:	mov    0x148(%rsp),%r8
    4c1e:	call   4c23 <botlish_fn_18+0x8eb>
			4c1f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4c23:	jmp    5901 <botlish_fn_18+0x15c9>
    4c28:	xor    %rbx,%rbx
    4c2b:	mov    %rbx,%rsi
    4c2e:	mov    0x130(%rsp),%rdi
    4c36:	call   4c3b <botlish_fn_18+0x903>
			4c37: R_X86_64_PLT32	rt_declared_payload-0x4
    4c3b:	mov    %rax,%r12
    4c3e:	mov    $0x1,%esi
    4c43:	mov    0x130(%rsp),%rdi
    4c4b:	call   4c50 <botlish_fn_18+0x918>
			4c4c: R_X86_64_PLT32	rt_declared_payload-0x4
    4c50:	mov    0x158(%rsp),%rsi
    4c58:	mov    %rax,%r14
    4c5b:	mov    0x130(%rsp),%rdi
    4c63:	call   4c68 <botlish_fn_18+0x930>
			4c64: R_X86_64_PLT32	rt_declared_payload-0x4
    4c68:	mov    %rax,%r13
    4c6b:	mov    0x130(%rsp),%rdi
    4c73:	call   4c78 <botlish_fn_18+0x940>
			4c74: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4c78:	mov    0x168(%rsp),%rsi
    4c80:	mov    0x130(%rsp),%rdi
    4c88:	call   4c8d <botlish_fn_18+0x955>
			4c89: R_X86_64_PLT32	rt_co_release-0x4
    4c8d:	mov    0x140(%rsp),%rsi
    4c95:	mov    0x130(%rsp),%rdi
    4c9d:	call   4ca2 <botlish_fn_18+0x96a>
			4c9e: R_X86_64_PLT32	rt_co_release-0x4
    4ca2:	mov    0x130(%rsp),%rdi
    4caa:	mov    0x10(%rdi),%rax
    4cae:	mov    0x158(%rax),%rdx
    4cb5:	lea    0x78(%rsp),%r9
    4cba:	mov    0x150(%rsp),%rax
    4cc2:	mov    %rax,0x78(%rsp)
    4cc7:	mov    %r12,%rax
    4cca:	mov    %rax,0x80(%rsp)
    4cd2:	mov    %r14,%rax
    4cd5:	mov    %rax,0x88(%rsp)
    4cdd:	mov    %r13,%rax
    4ce0:	mov    %rax,0x90(%rsp)
    4ce8:	mov    $0x4,%r8d
    4cee:	mov    %rbx,%rcx
    4cf1:	mov    0x148(%rsp),%rsi
    4cf9:	call   4cfe <botlish_fn_18+0x9c6>
			4cfa: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4cfe:	jmp    5901 <botlish_fn_18+0x15c9>
    4d03:	mov    0x18(%r14),%rax
    4d07:	test   %rax,%rax
    4d0a:	je     5a18 <botlish_fn_18+0x16e0>
    4d10:	mov    0x10(%r14),%rax
    4d14:	mov    %rcx,0x18(%rax)
    4d18:	mov    0x140(%rsp),%rsi
    4d20:	mov    0x130(%rsp),%rdi
    4d28:	call   4d2d <botlish_fn_18+0x9f5>
			4d29: R_X86_64_PLT32	rt_co_done-0x4
    4d2d:	cmp    $0x6,%rax
    4d31:	je     53a9 <botlish_fn_18+0x1071>
    4d37:	mov    0x10(%r14),%rax
    4d3b:	mov    (%rax),%r13
    4d3e:	mov    %r13,0x40(%rsp)
    4d43:	mov    0x150(%rsp),%rdx
    4d4b:	mov    %r13,%rax
    4d4e:	and    %rdx,%rax
    4d51:	test   $0x1,%rax
    4d57:	je     4d82 <botlish_fn_18+0xa4a>
    4d5d:	mov    0x150(%rsp),%rdx
    4d65:	mov    %r13,%rcx
    4d68:	sub    %rdx,%rcx
    4d6b:	seto   %al
    4d6e:	lea    0x1(%rcx),%rsi
    4d72:	test   %al,%al
    4d74:	jne    4d82 <botlish_fn_18+0xa4a>
    4d7a:	mov    %r15,%r12
    4d7d:	jmp    4da0 <botlish_fn_18+0xa68>
    4d82:	mov    0x150(%rsp),%rdx
    4d8a:	mov    %r13,%rsi
    4d8d:	mov    0x130(%rsp),%rdi
    4d95:	call   4d9a <botlish_fn_18+0xa62>
			4d96: R_X86_64_PLT32	rt_int_sub-0x4
    4d9a:	mov    %rax,%rsi
    4d9d:	mov    %r15,%r12
    4da0:	mov    %rsi,%rax
    4da3:	and    %r12,%rax
    4da6:	test   $0x1,%rax
    4dac:	jne    4ddd <botlish_fn_18+0xaa5>
    4db2:	mov    %r12,%rdx
    4db5:	mov    0x130(%rsp),%rdi
    4dbd:	call   4dc2 <botlish_fn_18+0xa8a>
			4dbe: R_X86_64_PLT32	rt_int_cmp-0x4
    4dc2:	test   %rax,%rax
    4dc5:	mov    0x158(%rsp),%rsi
    4dcd:	mov    %rsi,%rdx
    4dd0:	cmovge 0xd20(%rip),%rdx        # 5af8 <botlish_fn_18+0x17c0>
    4dd8:	jmp    4df3 <botlish_fn_18+0xabb>
    4ddd:	cmp    %r12,%rsi
    4de0:	mov    0x158(%rsp),%rsi
    4de8:	mov    %rsi,%rdx
    4deb:	cmovge 0xd05(%rip),%rdx        # 5af8 <botlish_fn_18+0x17c0>
    4df3:	cmp    $0x6,%rdx
    4df7:	je     5332 <botlish_fn_18+0xffa>
    4dfd:	mov    0x10(%r14),%rcx
    4e01:	mov    0x8(%rcx),%rdx
    4e05:	mov    %r13,%rsi
    4e08:	and    %rdx,%rsi
    4e0b:	test   $0x1,%rsi
    4e12:	jne    4e43 <botlish_fn_18+0xb0b>
    4e18:	mov    %r13,%rsi
    4e1b:	mov    0x130(%rsp),%rdi
    4e23:	call   4e28 <botlish_fn_18+0xaf0>
			4e24: R_X86_64_PLT32	rt_int_cmp-0x4
    4e28:	test   %rax,%rax
    4e2b:	mov    0x158(%rsp),%rsi
    4e33:	mov    %rsi,%rax
    4e36:	cmovl  0xcba(%rip),%rax        # 5af8 <botlish_fn_18+0x17c0>
    4e3e:	jmp    4e59 <botlish_fn_18+0xb21>
    4e43:	cmp    %rdx,%r13
    4e46:	mov    0x158(%rsp),%rsi
    4e4e:	mov    %rsi,%rax
    4e51:	cmovl  0xc9f(%rip),%rax        # 5af8 <botlish_fn_18+0x17c0>
    4e59:	cmp    $0x6,%rax
    4e5d:	je     4ffc <botlish_fn_18+0xcc4>
    4e63:	mov    0x168(%rsp),%rsi
    4e6b:	mov    0x130(%rsp),%rdi
    4e73:	call   4e78 <botlish_fn_18+0xb40>
			4e74: R_X86_64_PLT32	rt_co_resume0-0x4
    4e78:	mov    %rax,%rcx
    4e7b:	mov    %rax,%r15
    4e7e:	test   %rcx,%rax
    4e81:	jne    4ecf <botlish_fn_18+0xb97>
    4e87:	mov    0x130(%rsp),%rdi
    4e8f:	call   4e94 <botlish_fn_18+0xb5c>
			4e90: R_X86_64_PLT32	rt_declared_error-0x4
    4e94:	cmp    $0x40000001,%rax
    4e9a:	jne    5901 <botlish_fn_18+0x15c9>
    4ea0:	mov    0x168(%rsp),%rsi
    4ea8:	mov    0x130(%rsp),%rdi
    4eb0:	call   4eb5 <botlish_fn_18+0xb7d>
			4eb1: R_X86_64_PLT32	rt_co_release-0x4
    4eb5:	mov    0x140(%rsp),%rsi
    4ebd:	mov    0x130(%rsp),%rdi
    4ec5:	call   4eca <botlish_fn_18+0xb92>
			4ec6: R_X86_64_PLT32	rt_co_release-0x4
    4eca:	jmp    5901 <botlish_fn_18+0x15c9>
    4ecf:	mov    %r15,%rax
    4ed2:	mov    %rax,0x48(%rsp)
    4ed7:	mov    %r15,%rax
    4eda:	test   $0x1,%rax
    4ee0:	jne    4f18 <botlish_fn_18+0xbe0>
    4ee6:	mov    $0xffffffffffffffff,%rdx
    4eed:	mov    %r15,%rsi
    4ef0:	mov    0x130(%rsp),%rdi
    4ef8:	call   4efd <botlish_fn_18+0xbc5>
			4ef9: R_X86_64_PLT32	rt_int_cmp-0x4
    4efd:	test   %rax,%rax
    4f00:	mov    0x158(%rsp),%rsi
    4f08:	mov    %rsi,%rcx
    4f0b:	cmove  0xbe5(%rip),%rcx        # 5af8 <botlish_fn_18+0x17c0>
    4f13:	jmp    4f32 <botlish_fn_18+0xbfa>
    4f18:	mov    %r15,%rax
    4f1b:	cmp    $0xffffffffffffffff,%rax
    4f1f:	mov    0x158(%rsp),%rsi
    4f27:	mov    %rsi,%rcx
    4f2a:	cmove  0xbc6(%rip),%rcx        # 5af8 <botlish_fn_18+0x17c0>
    4f32:	cmp    $0x6,%rcx
    4f36:	je     4ff2 <botlish_fn_18+0xcba>
    4f3c:	movq   $0x3,0x50(%rsp)
    4f45:	test   $0x1,%r13
    4f4c:	jne    4f72 <botlish_fn_18+0xc3a>
    4f52:	mov    0x148(%rsp),%rdx
    4f5a:	mov    %r13,%rsi
    4f5d:	mov    0x130(%rsp),%rdi
    4f65:	call   4f6a <botlish_fn_18+0xc32>
			4f66: R_X86_64_PLT32	rt_int_and-0x4
    4f6a:	mov    %rax,%rdx
    4f6d:	jmp    4f79 <botlish_fn_18+0xc41>
    4f72:	mov    %r13,%rdx
    4f75:	and    $0x3,%rdx
    4f79:	mov    0x18(%rbx),%rax
    4f7d:	test   %rax,%rax
    4f80:	je     5a32 <botlish_fn_18+0x16fa>
    4f86:	mov    0x10(%rbx),%rcx
    4f8a:	sar    $1,%rdx
    4f8d:	mov    %r15,(%rcx,%rdx,8)
    4f91:	movq   $0x3,0x50(%rsp)
    4f9a:	movq   $0x3,0x58(%rsp)
    4fa3:	test   $0x1,%r13
    4faa:	je     4fc2 <botlish_fn_18+0xc8a>
    4fb0:	mov    %r13,%rcx
    4fb3:	add    $0x2,%rcx
    4fb7:	seto   %al
    4fba:	test   %al,%al
    4fbc:	je     4fdd <botlish_fn_18+0xca5>
    4fc2:	mov    0x148(%rsp),%rdx
    4fca:	mov    %r13,%rsi
    4fcd:	mov    0x130(%rsp),%rdi
    4fd5:	call   4fda <botlish_fn_18+0xca2>
			4fd6: R_X86_64_PLT32	rt_int_add-0x4
    4fda:	mov    %rax,%rcx
    4fdd:	mov    0x18(%r14),%rax
    4fe1:	test   %rax,%rax
    4fe4:	je     5a4a <botlish_fn_18+0x1712>
    4fea:	mov    0x10(%r14),%rax
    4fee:	mov    %rcx,0x8(%rax)
    4ff2:	mov    %r15,0x48(%rsp)
    4ff7:	jmp    5046 <botlish_fn_18+0xd0e>
    4ffc:	movq   $0x3,0x48(%rsp)
    5005:	test   $0x1,%r13
    500c:	jne    502f <botlish_fn_18+0xcf7>
    5012:	mov    0x148(%rsp),%rdx
    501a:	mov    %r13,%rsi
    501d:	mov    0x130(%rsp),%rdi
    5025:	call   502a <botlish_fn_18+0xcf2>
			5026: R_X86_64_PLT32	rt_int_and-0x4
    502a:	jmp    5036 <botlish_fn_18+0xcfe>
    502f:	mov    %r13,%rax
    5032:	and    $0x3,%rax
    5036:	mov    0x10(%rbx),%rcx
    503a:	sar    $1,%rax
    503d:	mov    (%rcx,%rax,8),%r15
    5041:	mov    %r15,0x48(%rsp)
    5046:	test   $0x1,%r15
    504d:	jne    5085 <botlish_fn_18+0xd4d>
    5053:	mov    $0xffffffffffffffff,%rdx
    505a:	mov    %r15,%rsi
    505d:	mov    0x130(%rsp),%rdi
    5065:	call   506a <botlish_fn_18+0xd32>
			5066: R_X86_64_PLT32	rt_int_cmp-0x4
    506a:	test   %rax,%rax
    506d:	mov    0x158(%rsp),%rsi
    5075:	mov    %rsi,%rcx
    5078:	cmove  0xa78(%rip),%rcx        # 5af8 <botlish_fn_18+0x17c0>
    5080:	jmp    509c <botlish_fn_18+0xd64>
    5085:	cmp    $0xffffffffffffffff,%r15
    5089:	mov    0x158(%rsp),%rsi
    5091:	mov    %rsi,%rcx
    5094:	cmove  0xa5c(%rip),%rcx        # 5af8 <botlish_fn_18+0x17c0>
    509c:	cmp    $0x6,%rcx
    50a0:	je     5106 <botlish_fn_18+0xdce>
    50a6:	movq   $0x1,0x50(%rsp)
    50af:	movq   $0x3,0x58(%rsp)
    50b8:	test   $0x1,%r13
    50bf:	je     50d7 <botlish_fn_18+0xd9f>
    50c5:	mov    %r13,%rcx
    50c8:	add    $0x2,%rcx
    50cc:	seto   %al
    50cf:	test   %al,%al
    50d1:	je     50f2 <botlish_fn_18+0xdba>
    50d7:	mov    0x148(%rsp),%rdx
    50df:	mov    %r13,%rsi
    50e2:	mov    0x130(%rsp),%rdi
    50ea:	call   50ef <botlish_fn_18+0xdb7>
			50eb: R_X86_64_PLT32	rt_int_add-0x4
    50ef:	mov    %rax,%rcx
    50f2:	mov    0x18(%r14),%rax
    50f6:	test   %rax,%rax
    50f9:	je     5a67 <botlish_fn_18+0x172f>
    50ff:	mov    0x10(%r14),%rax
    5103:	mov    %rcx,(%rax)
    5106:	lea    0xc0(%rsp),%rcx
    510e:	mov    %r15,0xc0(%rsp)
    5116:	mov    $0x1,%edx
    511b:	mov    0x148(%rsp),%rsi
    5123:	mov    0x130(%rsp),%rdi
    512b:	call   5130 <botlish_fn_18+0xdf8>
			512c: R_X86_64_PLT32	rt_struct_new-0x4
    5130:	mov    %rax,0x48(%rsp)
    5135:	mov    %rax,%rdx
    5138:	mov    0x140(%rsp),%rsi
    5140:	mov    0x130(%rsp),%rdi
    5148:	call   514d <botlish_fn_18+0xe15>
			5149: R_X86_64_PLT32	rt_co_resume-0x4
    514d:	test   %rax,%rax
    5150:	mov    %rax,%rcx
    5153:	jne    5315 <botlish_fn_18+0xfdd>
    5159:	mov    0x130(%rsp),%rdi
    5161:	call   5166 <botlish_fn_18+0xe2e>
			5162: R_X86_64_PLT32	rt_declared_error-0x4
    5166:	cmp    $0x1,%rax
    516a:	je     523c <botlish_fn_18+0xf04>
    5170:	mov    0x130(%rsp),%rdi
    5178:	call   517d <botlish_fn_18+0xe45>
			5179: R_X86_64_PLT32	rt_declared_error-0x4
    517d:	cmp    $0x2,%rax
    5181:	jne    5901 <botlish_fn_18+0x15c9>
    5187:	xor    %rsi,%rsi
    518a:	mov    0x130(%rsp),%rdi
    5192:	call   5197 <botlish_fn_18+0xe5f>
			5193: R_X86_64_PLT32	rt_declared_payload-0x4
    5197:	mov    %rax,%r12
    519a:	mov    $0x1,%ebx
    519f:	mov    %rbx,%rsi
    51a2:	mov    0x130(%rsp),%rdi
    51aa:	call   51af <botlish_fn_18+0xe77>
			51ab: R_X86_64_PLT32	rt_declared_payload-0x4
    51af:	mov    %rax,%r14
    51b2:	mov    0x130(%rsp),%rdi
    51ba:	call   51bf <botlish_fn_18+0xe87>
			51bb: R_X86_64_PLT32	rt_clear_declared_error-0x4
    51bf:	mov    0x168(%rsp),%rsi
    51c7:	mov    0x130(%rsp),%rdi
    51cf:	call   51d4 <botlish_fn_18+0xe9c>
			51d0: R_X86_64_PLT32	rt_co_release-0x4
    51d4:	mov    0x140(%rsp),%rsi
    51dc:	mov    0x130(%rsp),%rdi
    51e4:	call   51e9 <botlish_fn_18+0xeb1>
			51e5: R_X86_64_PLT32	rt_co_release-0x4
    51e9:	mov    0x130(%rsp),%rdi
    51f1:	mov    0x10(%rdi),%rax
    51f5:	mov    0x160(%rax),%rdx
    51fc:	lea    0xe8(%rsp),%r9
    5204:	mov    %r13,0xe8(%rsp)
    520c:	mov    %r12,%rax
    520f:	mov    %rax,0xf0(%rsp)
    5217:	mov    %r14,%rax
    521a:	mov    %rax,0xf8(%rsp)
    5222:	mov    $0x4,%esi
    5227:	mov    %rbx,%rcx
    522a:	mov    0x148(%rsp),%r8
    5232:	call   5237 <botlish_fn_18+0xeff>
			5233: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5237:	jmp    5901 <botlish_fn_18+0x15c9>
    523c:	xor    %rbx,%rbx
    523f:	mov    %rbx,%rsi
    5242:	mov    0x130(%rsp),%rdi
    524a:	call   524f <botlish_fn_18+0xf17>
			524b: R_X86_64_PLT32	rt_declared_payload-0x4
    524f:	mov    %rax,%r12
    5252:	mov    $0x1,%esi
    5257:	mov    0x130(%rsp),%rdi
    525f:	call   5264 <botlish_fn_18+0xf2c>
			5260: R_X86_64_PLT32	rt_declared_payload-0x4
    5264:	mov    0x158(%rsp),%rsi
    526c:	mov    %rax,%r15
    526f:	mov    0x130(%rsp),%rdi
    5277:	call   527c <botlish_fn_18+0xf44>
			5278: R_X86_64_PLT32	rt_declared_payload-0x4
    527c:	mov    %rax,%r14
    527f:	mov    0x130(%rsp),%rdi
    5287:	call   528c <botlish_fn_18+0xf54>
			5288: R_X86_64_PLT32	rt_clear_declared_error-0x4
    528c:	mov    0x168(%rsp),%rsi
    5294:	mov    0x130(%rsp),%rdi
    529c:	call   52a1 <botlish_fn_18+0xf69>
			529d: R_X86_64_PLT32	rt_co_release-0x4
    52a1:	mov    0x140(%rsp),%rsi
    52a9:	mov    0x130(%rsp),%rdi
    52b1:	call   52b6 <botlish_fn_18+0xf7e>
			52b2: R_X86_64_PLT32	rt_co_release-0x4
    52b6:	mov    0x130(%rsp),%rdi
    52be:	mov    0x10(%rdi),%rax
    52c2:	mov    0x158(%rax),%rdx
    52c9:	lea    0xc8(%rsp),%r9
    52d1:	mov    %r13,0xc8(%rsp)
    52d9:	mov    %r12,%rax
    52dc:	mov    %rax,0xd0(%rsp)
    52e4:	mov    %r15,%rax
    52e7:	mov    %rax,0xd8(%rsp)
    52ef:	mov    %r14,%rax
    52f2:	mov    %rax,0xe0(%rsp)
    52fa:	mov    $0x4,%r8d
    5300:	mov    %rbx,%rcx
    5303:	mov    0x148(%rsp),%rsi
    530b:	call   5310 <botlish_fn_18+0xfd8>
			530c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5310:	jmp    5901 <botlish_fn_18+0x15c9>
    5315:	mov    0x18(%r14),%rax
    5319:	test   %rax,%rax
    531c:	je     5a81 <botlish_fn_18+0x1749>
    5322:	mov    0x10(%r14),%rax
    5326:	mov    %rcx,0x18(%rax)
    532a:	mov    %r12,%r15
    532d:	jmp    4d18 <botlish_fn_18+0x9e0>
    5332:	mov    0x168(%rsp),%rsi
    533a:	mov    0x130(%rsp),%rdi
    5342:	call   5347 <botlish_fn_18+0x100f>
			5343: R_X86_64_PLT32	rt_co_release-0x4
    5347:	mov    0x140(%rsp),%rsi
    534f:	mov    0x130(%rsp),%rdi
    5357:	call   535c <botlish_fn_18+0x1024>
			5358: R_X86_64_PLT32	rt_co_release-0x4
    535c:	mov    0x130(%rsp),%rdi
    5364:	mov    0x10(%rdi),%rax
    5368:	mov    0x168(%rax),%rdx
    536f:	lea    0xb0(%rsp),%r9
    5377:	mov    0x150(%rsp),%rax
    537f:	mov    %rax,0xb0(%rsp)
    5387:	mov    %r12,0xb8(%rsp)
    538f:	mov    $0x5,%esi
    5394:	mov    0x158(%rsp),%r8
    539c:	mov    %r8,%rcx
    539f:	call   53a4 <botlish_fn_18+0x106c>
			53a0: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    53a4:	jmp    5901 <botlish_fn_18+0x15c9>
    53a9:	mov    %r15,%r12
    53ac:	mov    0x140(%rsp),%rsi
    53b4:	mov    0x130(%rsp),%rdi
    53bc:	call   53c1 <botlish_fn_18+0x1089>
			53bd: R_X86_64_PLT32	rt_co_release-0x4
    53c1:	mov    0x10(%r14),%rax
    53c5:	mov    (%rax),%rsi
    53c8:	mov    %rsi,0x38(%rsp)
    53cd:	mov    0x10(%r14),%rax
    53d1:	mov    0x18(%rax),%rdx
    53d5:	mov    %rdx,0x40(%rsp)
    53da:	mov    %rsi,%rax
    53dd:	and    %rdx,%rax
    53e0:	test   $0x1,%rax
    53e6:	je     5406 <botlish_fn_18+0x10ce>
    53ec:	mov    %rsi,%rcx
    53ef:	sub    %rdx,%rcx
    53f2:	seto   %dil
    53f6:	add    $0x1,%rcx
    53fd:	test   %dil,%dil
    5400:	je     5416 <botlish_fn_18+0x10de>
    5406:	mov    0x130(%rsp),%rdi
    540e:	call   5413 <botlish_fn_18+0x10db>
			540f: R_X86_64_PLT32	rt_int_sub-0x4
    5413:	mov    %rax,%rcx
    5416:	mov    %rcx,0x38(%rsp)
    541b:	mov    0x18(%r14),%r8
    541f:	test   %r8,%r8
    5422:	je     5a9b <botlish_fn_18+0x1763>
    5428:	mov    %rcx,%r13
    542b:	mov    0x10(%r14),%r11
    542f:	mov    %r13,(%r11)
    5432:	mov    0x138(%rsp),%rsi
    543a:	test   $0x1,%rsi
    5441:	jne    547c <botlish_fn_18+0x1144>
    5447:	mov    $0x45,%edx
    544c:	mov    0x138(%rsp),%rsi
    5454:	mov    0x130(%rsp),%rdi
    545c:	call   5461 <botlish_fn_18+0x1129>
			545d: R_X86_64_PLT32	rt_int_cmp-0x4
    5461:	test   %rax,%rax
    5464:	mov    0x158(%rsp),%rdx
    546c:	mov    %rdx,%rcx
    546f:	cmove  0x681(%rip),%rcx        # 5af8 <botlish_fn_18+0x17c0>
    5477:	jmp    549b <botlish_fn_18+0x1163>
    547c:	mov    0x138(%rsp),%rsi
    5484:	cmp    $0x45,%rsi
    5488:	mov    0x158(%rsp),%rdx
    5490:	mov    %rdx,%rcx
    5493:	cmove  0x65d(%rip),%rcx        # 5af8 <botlish_fn_18+0x17c0>
    549b:	cmp    $0x6,%rcx
    549f:	je     5522 <botlish_fn_18+0x11ea>
    54a5:	mov    0x138(%rsp),%rsi
    54ad:	test   $0x1,%rsi
    54b4:	jne    54ef <botlish_fn_18+0x11b7>
    54ba:	mov    $0x4f,%edx
    54bf:	mov    0x138(%rsp),%rsi
    54c7:	mov    0x130(%rsp),%rdi
    54cf:	call   54d4 <botlish_fn_18+0x119c>
			54d0: R_X86_64_PLT32	rt_int_cmp-0x4
    54d4:	test   %rax,%rax
    54d7:	mov    0x158(%rsp),%rdx
    54df:	mov    %rdx,%rcx
    54e2:	cmove  0x60e(%rip),%rcx        # 5af8 <botlish_fn_18+0x17c0>
    54ea:	jmp    550e <botlish_fn_18+0x11d6>
    54ef:	mov    0x138(%rsp),%rsi
    54f7:	cmp    $0x4f,%rsi
    54fb:	mov    0x158(%rsp),%rdx
    5503:	mov    %rdx,%rcx
    5506:	cmove  0x5ea(%rip),%rcx        # 5af8 <botlish_fn_18+0x17c0>
    550e:	cmp    $0x6,%rcx
    5512:	je     5522 <botlish_fn_18+0x11ea>
    5518:	mov    $0x1,%ecx
    551d:	jmp    552a <botlish_fn_18+0x11f2>
    5522:	mov    0x148(%rsp),%rcx
    552a:	mov    0x18(%r14),%rax
    552e:	test   %rax,%rax
    5531:	je     5ab8 <botlish_fn_18+0x1780>
    5537:	mov    0x10(%r14),%rax
    553b:	mov    %rcx,0x10(%rax)
    553f:	mov    0x150(%rsp),%rdx
    5547:	mov    %r13,%rax
    554a:	and    %rdx,%rax
    554d:	test   $0x1,%rax
    5553:	je     5586 <botlish_fn_18+0x124e>
    5559:	mov    0x150(%rsp),%rax
    5561:	mov    %r13,%rdx
    5564:	sub    %rax,%rdx
    5567:	seto   %cl
    556a:	add    $0x1,%rdx
    5571:	test   %cl,%cl
    5573:	jne    5586 <botlish_fn_18+0x124e>
    5579:	mov    0x138(%rsp),%rsi
    5581:	jmp    55a9 <botlish_fn_18+0x1271>
    5586:	mov    0x150(%rsp),%rdx
    558e:	mov    %r13,%rsi
    5591:	mov    0x130(%rsp),%rdi
    5599:	call   559e <botlish_fn_18+0x1266>
			559a: R_X86_64_PLT32	rt_int_sub-0x4
    559e:	mov    %rax,%rdx
    55a1:	mov    0x138(%rsp),%rsi
    55a9:	mov    0x138(%rsp),%rsi
    55b1:	mov    0x130(%rsp),%rdi
    55b9:	call   55be <botlish_fn_18+0x1286>
			55ba: R_X86_64_PLT32	botlish_fn_15-0x4
    55be:	mov    %rax,0x30(%rsp)
    55c3:	mov    %r13,%rcx
    55c6:	mov    0x150(%rsp),%rdx
    55ce:	mov    %rax,%rsi
    55d1:	mov    0x130(%rsp),%rdi
    55d9:	call   55de <botlish_fn_18+0x12a6>
			55da: R_X86_64_PLT32	botlish_fn_17-0x4
    55de:	test   %rax,%rax
    55e1:	mov    %rax,%rdx
    55e4:	je     5901 <botlish_fn_18+0x15c9>
    55ea:	mov    0x160(%rsp),%rsi
    55f2:	mov    0x130(%rsp),%rdi
    55fa:	call   55ff <botlish_fn_18+0x12c7>
			55fb: R_X86_64_PLT32	rt_mv_push-0x4
    55ff:	mov    %rbx,%r13
    5602:	mov    %r12,%r15
    5605:	jmp    4613 <botlish_fn_18+0x2db>
    560a:	mov    %r15,%r12
    560d:	mov    0x18(%r14),%rax
    5611:	test   %rax,%rax
    5614:	je     5ad2 <botlish_fn_18+0x179a>
    561a:	mov    0x10(%r14),%rax
    561e:	movq   $0x1,0x10(%rax)
    5626:	mov    0x130(%rsp),%rdi
    562e:	mov    0x10(%rdi),%rax
    5632:	mov    0x128(%rax),%r13
    5639:	mov    %r13,0x30(%rsp)
    563e:	movq   $0x3,0x38(%rsp)
    5647:	mov    0x150(%rsp),%rdx
    564f:	test   $0x1,%rdx
    5656:	jne    5669 <botlish_fn_18+0x1331>
    565c:	mov    0x148(%rsp),%rdx
    5664:	jmp    568b <botlish_fn_18+0x1353>
    5669:	mov    0x150(%rsp),%rdx
    5671:	mov    %rdx,%rcx
    5674:	add    $0x2,%rcx
    5678:	seto   %dl
    567b:	test   %dl,%dl
    567d:	je     56a3 <botlish_fn_18+0x136b>
    5683:	mov    0x148(%rsp),%rdx
    568b:	mov    0x150(%rsp),%rsi
    5693:	mov    0x130(%rsp),%rdi
    569b:	call   56a0 <botlish_fn_18+0x1368>
			569c: R_X86_64_PLT32	rt_int_add-0x4
    56a0:	mov    %rax,%rcx
    56a3:	mov    %rcx,0x38(%rsp)
    56a8:	mov    0x150(%rsp),%rdx
    56b0:	mov    %r13,%rsi
    56b3:	mov    0x130(%rsp),%rdi
    56bb:	call   56c0 <botlish_fn_18+0x1388>
			56bc: R_X86_64_PLT32	botlish_fn_17-0x4
    56c0:	test   %rax,%rax
    56c3:	mov    %rax,%rdx
    56c6:	je     5901 <botlish_fn_18+0x15c9>
    56cc:	mov    0x160(%rsp),%rsi
    56d4:	mov    0x130(%rsp),%rdi
    56dc:	call   56e1 <botlish_fn_18+0x13a9>
			56dd: R_X86_64_PLT32	rt_mv_push-0x4
    56e1:	mov    %rbx,%r13
    56e4:	mov    %r12,%r15
    56e7:	jmp    4613 <botlish_fn_18+0x2db>
    56ec:	mov    %r15,%r12
    56ef:	mov    %rbx,%r13
    56f2:	jmp    4613 <botlish_fn_18+0x2db>
    56f7:	mov    0x168(%rsp),%rsi
    56ff:	mov    0x130(%rsp),%rdi
    5707:	call   570c <botlish_fn_18+0x13d4>
			5708: R_X86_64_PLT32	rt_co_release-0x4
    570c:	mov    0x160(%rsp),%rsi
    5714:	mov    0x130(%rsp),%rdi
    571c:	call   5721 <botlish_fn_18+0x13e9>
			571d: R_X86_64_PLT32	rt_mv_to_list-0x4
    5721:	mov    %rax,(%rsp)
    5725:	mov    %rax,%r12
    5728:	mov    %r12,%rsi
    572b:	mov    0x130(%rsp),%rdi
    5733:	call   5738 <botlish_fn_18+0x1400>
			5734: R_X86_64_PLT32	rt_list_len-0x4
    5738:	mov    %rax,%rbx
    573b:	mov    %rbx,0x8(%rsp)
    5740:	movq   $0x1,0x10(%rsp)
    5749:	xor    %rdx,%rdx
    574c:	mov    0x130(%rsp),%rdi
    5754:	mov    %rdx,%rsi
    5757:	call   575c <botlish_fn_18+0x1424>
			5758: R_X86_64_PLT32	rt_list_new-0x4
    575c:	test   %rax,%rax
    575f:	je     5901 <botlish_fn_18+0x15c9>
    5765:	mov    %rax,0x18(%rsp)
    576a:	mov    %rax,%r13
    576d:	mov    $0x1,%esi
    5772:	mov    %rsi,%r14
    5775:	mov    %rsi,%rax
    5778:	and    %rbx,%rax
    577b:	mov    %rsi,%r14
    577e:	test   $0x1,%rax
    5784:	jne    57b5 <botlish_fn_18+0x147d>
    578a:	mov    %rbx,%rdx
    578d:	mov    %r14,%rsi
    5790:	mov    0x130(%rsp),%rdi
    5798:	call   579d <botlish_fn_18+0x1465>
			5799: R_X86_64_PLT32	rt_int_cmp-0x4
    579d:	test   %rax,%rax
    57a0:	mov    0x158(%rsp),%rdx
    57a8:	cmovl  0x348(%rip),%rdx        # 5af8 <botlish_fn_18+0x17c0>
    57b0:	jmp    57cb <botlish_fn_18+0x1493>
    57b5:	mov    %r14,%rsi
    57b8:	cmp    %rbx,%rsi
    57bb:	mov    0x158(%rsp),%rdx
    57c3:	cmovl  0x32d(%rip),%rdx        # 5af8 <botlish_fn_18+0x17c0>
    57cb:	cmp    $0x6,%rdx
    57cf:	je     584b <botlish_fn_18+0x1513>
    57d5:	lea    0x120(%rsp),%rcx
    57dd:	movq   $0x0,0x120(%rsp)
    57e9:	mov    %r13,%rax
    57ec:	mov    %rax,0x128(%rsp)
    57f4:	mov    $0x1,%esi
    57f9:	mov    0x158(%rsp),%rdx
    5801:	mov    0x130(%rsp),%rdi
    5809:	call   580e <botlish_fn_18+0x14d6>
			580a: R_X86_64_PLT32	rt_construct-0x4
    580e:	test   %rax,%rax
    5811:	je     5901 <botlish_fn_18+0x15c9>
    5817:	mov    0x170(%rsp),%rbx
    581f:	mov    0x178(%rsp),%r12
    5827:	mov    0x180(%rsp),%r13
    582f:	mov    0x188(%rsp),%r14
    5837:	mov    0x190(%rsp),%r15
    583f:	add    $0x1a0,%rsp
    5846:	mov    %rbp,%rsp
    5849:	pop    %rbp
    584a:	ret
    584b:	mov    %r14,%rsi
    584e:	test   $0x1,%rsi
    5855:	je     5872 <botlish_fn_18+0x153a>
    585b:	mov    0x8(%r12),%rcx
    5860:	mov    %r14,%rsi
    5863:	mov    %rsi,%rax
    5866:	sar    $1,%rax
    5869:	cmp    %rcx,%rax
    586c:	jb     5893 <botlish_fn_18+0x155b>
    5872:	mov    %r14,%rdx
    5875:	mov    %r12,%rsi
    5878:	mov    0x130(%rsp),%rdi
    5880:	call   5885 <botlish_fn_18+0x154d>
			5881: R_X86_64_PLT32	rt_list_get-0x4
    5885:	test   %rax,%rax
    5888:	je     5901 <botlish_fn_18+0x15c9>
    588e:	jmp    589c <botlish_fn_18+0x1564>
    5893:	mov    0x10(%r12),%rcx
    5898:	mov    (%rcx,%rax,8),%rax
    589c:	mov    %rax,0x20(%rsp)
    58a1:	lea    0x100(%rsp),%rcx
    58a9:	movq   $0x0,0x100(%rsp)
    58b5:	mov    %r13,%rdx
    58b8:	mov    %rdx,0x108(%rsp)
    58c0:	movq   $0x2,0x110(%rsp)
    58cc:	mov    %rax,0x118(%rsp)
    58d4:	mov    $0x3,%r13d
    58da:	mov    $0x4,%edx
    58df:	mov    %r13,%rsi
    58e2:	mov    0x130(%rsp),%rdi
    58ea:	call   58ef <botlish_fn_18+0x15b7>
			58eb: R_X86_64_PLT32	rt_construct-0x4
    58ef:	mov    %rax,%rsi
    58f2:	mov    %r13,%rdx
    58f5:	mov    %rax,%r13
    58f8:	test   %rsi,%rax
    58fb:	jne    5938 <botlish_fn_18+0x1600>
    5901:	xor    %rax,%rax
    5904:	mov    0x170(%rsp),%rbx
    590c:	mov    0x178(%rsp),%r12
    5914:	mov    0x180(%rsp),%r13
    591c:	mov    0x188(%rsp),%r14
    5924:	mov    0x190(%rsp),%r15
    592c:	add    $0x1a0,%rsp
    5933:	mov    %rbp,%rsp
    5936:	pop    %rbp
    5937:	ret
    5938:	mov    %r13,%rax
    593b:	mov    %rax,0x18(%rsp)
    5940:	movq   $0x3,0x20(%rsp)
    5949:	mov    %r14,%rsi
    594c:	test   $0x1,%rsi
    5953:	jne    5961 <botlish_fn_18+0x1629>
    5959:	mov    %r14,%rsi
    595c:	jmp    5989 <botlish_fn_18+0x1651>
    5961:	mov    %r14,%rsi
    5964:	mov    %rsi,%rax
    5967:	add    $0x2,%rax
    596b:	seto   %cl
    596e:	test   %cl,%cl
    5970:	je     597e <botlish_fn_18+0x1646>
    5976:	mov    %r14,%rsi
    5979:	jmp    5989 <botlish_fn_18+0x1651>
    597e:	mov    %rax,%rsi
    5981:	mov    %rax,%r14
    5984:	jmp    599c <botlish_fn_18+0x1664>
    5989:	mov    0x130(%rsp),%rdi
    5991:	call   5996 <botlish_fn_18+0x165e>
			5992: R_X86_64_PLT32	rt_int_add-0x4
    5996:	mov    %rax,%rsi
    5999:	mov    %rax,%r14
    599c:	mov    %rsi,0x10(%rsp)
    59a1:	mov    %r14,%rsi
    59a4:	jmp    5775 <botlish_fn_18+0x143d>
    59a9:	mov    $0x3,%ecx
    59ae:	mov    %rbx,%rsi
    59b1:	mov    0x130(%rsp),%rdi
    59b9:	mov    %rcx,%rdx
    59bc:	call   59c1 <botlish_fn_18+0x1689>
			59bd: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    59c1:	jmp    4603 <botlish_fn_18+0x2cb>
    59c6:	mov    0x148(%rsp),%r13
    59ce:	mov    %r13,%rcx
    59d1:	mov    %rbx,%rsi
    59d4:	mov    0x130(%rsp),%rdi
    59dc:	call   59e1 <botlish_fn_18+0x16a9>
			59dd: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    59e1:	jmp    47eb <botlish_fn_18+0x4b3>
    59e6:	mov    %r12,%rdx
    59e9:	mov    %r14,%rsi
    59ec:	mov    0x130(%rsp),%rdi
    59f4:	call   59f9 <botlish_fn_18+0x16c1>
			59f5: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    59f9:	jmp    486e <botlish_fn_18+0x536>
    59fe:	mov    $0x1,%edx
    5a03:	mov    %r14,%rsi
    5a06:	mov    0x130(%rsp),%rdi
    5a0e:	call   5a13 <botlish_fn_18+0x16db>
			5a0f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5a13:	jmp    49d2 <botlish_fn_18+0x69a>
    5a18:	mov    $0x7,%edx
    5a1d:	mov    %r14,%rsi
    5a20:	mov    0x130(%rsp),%rdi
    5a28:	call   5a2d <botlish_fn_18+0x16f5>
			5a29: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5a2d:	jmp    4d18 <botlish_fn_18+0x9e0>
    5a32:	mov    %r15,%rcx
    5a35:	mov    %rbx,%rsi
    5a38:	mov    0x130(%rsp),%rdi
    5a40:	call   5a45 <botlish_fn_18+0x170d>
			5a41: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5a45:	jmp    4f91 <botlish_fn_18+0xc59>
    5a4a:	mov    0x148(%rsp),%rdx
    5a52:	mov    %r14,%rsi
    5a55:	mov    0x130(%rsp),%rdi
    5a5d:	call   5a62 <botlish_fn_18+0x172a>
			5a5e: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5a62:	jmp    4ff2 <botlish_fn_18+0xcba>
    5a67:	mov    $0x1,%edx
    5a6c:	mov    %r14,%rsi
    5a6f:	mov    0x130(%rsp),%rdi
    5a77:	call   5a7c <botlish_fn_18+0x1744>
			5a78: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5a7c:	jmp    5106 <botlish_fn_18+0xdce>
    5a81:	mov    $0x7,%edx
    5a86:	mov    %r14,%rsi
    5a89:	mov    0x130(%rsp),%rdi
    5a91:	call   5a96 <botlish_fn_18+0x175e>
			5a92: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5a96:	jmp    532a <botlish_fn_18+0xff2>
    5a9b:	mov    $0x1,%edx
    5aa0:	mov    %rcx,%r13
    5aa3:	mov    %r14,%rsi
    5aa6:	mov    0x130(%rsp),%rdi
    5aae:	call   5ab3 <botlish_fn_18+0x177b>
			5aaf: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5ab3:	jmp    5432 <botlish_fn_18+0x10fa>
    5ab8:	mov    $0x5,%edx
    5abd:	mov    %r14,%rsi
    5ac0:	mov    0x130(%rsp),%rdi
    5ac8:	call   5acd <botlish_fn_18+0x1795>
			5ac9: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5acd:	jmp    553f <botlish_fn_18+0x1207>
    5ad2:	mov    $0x5,%edx
    5ad7:	mov    $0x1,%ecx
    5adc:	mov    %r14,%rsi
    5adf:	mov    0x130(%rsp),%rdi
    5ae7:	call   5aec <botlish_fn_18+0x17b4>
			5ae8: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    5aec:	jmp    5626 <botlish_fn_18+0x12ee>
    5af1:	add    %al,(%rax)
    5af3:	add    %al,(%rax)
    5af5:	add    %al,(%rax)
    5af7:	add    %al,(%rsi)
    5af9:	add    %al,(%rax)
    5afb:	add    %al,(%rax)
    5afd:	add    %al,(%rax)
	...

<botlish_fn_19>:
    1388:	push   %rbp
    1389:	mov    %rsp,%rbp
    138c:	sub    $0x570,%rsp
    1393:	mov    %rbx,0x540(%rsp)
    139b:	mov    %r12,0x548(%rsp)
    13a3:	mov    %r13,0x550(%rsp)
    13ab:	mov    %r14,0x558(%rsp)
    13b3:	mov    %r15,0x560(%rsp)
    13bb:	mov    %rdi,0x458(%rsp)
    13c3:	movq   $0x0,0x10(%rsp)
    13cc:	movq   $0x0,0x18(%rsp)
    13d5:	movq   $0x0,0x20(%rsp)
    13de:	movq   $0x0,0x28(%rsp)
    13e7:	movq   $0x0,0x30(%rsp)
    13f0:	movq   $0x0,0x38(%rsp)
    13f9:	movq   $0x0,0x40(%rsp)
    1402:	movq   $0x0,0x48(%rsp)
    140b:	movq   $0x0,0x98(%rsp)
    1417:	movq   $0x0,0xa0(%rsp)
    1423:	movq   $0x0,0xa8(%rsp)
    142f:	movq   $0x0,0xb0(%rsp)
    143b:	movq   $0x0,0xb8(%rsp)
    1447:	movq   $0x0,0xc0(%rsp)
    1453:	movq   $0x0,0xc8(%rsp)
    145f:	movq   $0x0,0xd0(%rsp)
    146b:	movq   $0x0,0xd8(%rsp)
    1477:	movq   $0x0,0xe0(%rsp)
    1483:	movq   $0x0,0xe8(%rsp)
    148f:	mov    %rdx,(%rsp)
    1493:	mov    %rdx,0x468(%rsp)
    149b:	mov    %rcx,0x8(%rsp)
    14a0:	mov    %rcx,0x470(%rsp)
    14a8:	movq   $0xa,0x60(%rsp)
    14b1:	movq   $0xa,0x68(%rsp)
    14ba:	movq   $0xa,0x70(%rsp)
    14c3:	movq   $0xa,0x78(%rsp)
    14cc:	movq   $0xa,0x80(%rsp)
    14d8:	movq   $0xa,0x88(%rsp)
    14e4:	movq   $0xa,0x90(%rsp)
    14f0:	movq   $0xa,0x50(%rsp)
    14f9:	movq   $0xa,0x58(%rsp)
    1502:	mov    %rsi,0x60(%rsp)
    1507:	mov    %rsi,0x460(%rsp)
    150f:	mov    0x460(%rsp),%rsi
    1517:	mov    0x458(%rsp),%rdi
    151f:	call   1524 <botlish_fn_19+0x19c>
			1520: R_X86_64_PLT32	rt_list_len-0x4
    1524:	mov    %rax,0x68(%rsp)
    1529:	mov    %rax,0x538(%rsp)
    1531:	mov    $0x1,%esi
    1536:	mov    %rsi,0x4c0(%rsp)
    153e:	movq   $0x1,0x70(%rsp)
    1547:	mov    $0xa,%esi
    154c:	mov    %rsi,0x4a8(%rsp)
    1554:	mov    0x4c0(%rsp),%rax
    155c:	mov    0x538(%rsp),%rsi
    1564:	mov    0x4a8(%rsp),%rcx
    156c:	mov    %rcx,0x4b0(%rsp)
    1574:	mov    %rcx,0x4b8(%rsp)
    157c:	mov    %rax,%rcx
    157f:	and    %rsi,%rcx
    1582:	mov    %rax,0x4c0(%rsp)
    158a:	mov    %rsi,0x538(%rsp)
    1592:	test   $0x1,%rcx
    1599:	jne    15d1 <botlish_fn_19+0x249>
    159f:	mov    0x538(%rsp),%rdx
    15a7:	mov    0x4c0(%rsp),%rsi
    15af:	mov    0x458(%rsp),%rdi
    15b7:	call   15bc <botlish_fn_19+0x234>
			15b8: R_X86_64_PLT32	rt_int_cmp-0x4
    15bc:	mov    $0x2,%ecx
    15c1:	test   %rax,%rax
    15c4:	cmovl  0x920c(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    15cc:	jmp    15f1 <botlish_fn_19+0x269>
    15d1:	mov    $0x2,%ecx
    15d6:	mov    0x4c0(%rsp),%rax
    15de:	mov    0x538(%rsp),%rsi
    15e6:	cmp    %rsi,%rax
    15e9:	cmovl  0x91e7(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    15f1:	cmp    $0x6,%rcx
    15f5:	je     1631 <botlish_fn_19+0x2a9>
    15fb:	mov    $0xffffffffffffffff,%rdx
    1602:	movq   $0xffffffffffffffff,0x50(%rsp)
    160b:	mov    $0xa,%eax
    1610:	mov    %rax,0x498(%rsp)
    1618:	movq   $0xa,0x90(%rsp)
    1624:	mov    %rdx,0x488(%rsp)
    162c:	jmp    1947 <botlish_fn_19+0x5bf>
    1631:	mov    0x4c0(%rsp),%rsi
    1639:	test   $0x1,%rsi
    1640:	je     1669 <botlish_fn_19+0x2e1>
    1646:	mov    0x460(%rsp),%rcx
    164e:	mov    0x8(%rcx),%rcx
    1652:	mov    0x4c0(%rsp),%rsi
    165a:	mov    %rsi,%rax
    165d:	sar    $1,%rax
    1660:	cmp    %rcx,%rax
    1663:	jb     16a7 <botlish_fn_19+0x31f>
    1669:	mov    0x4c0(%rsp),%rdx
    1671:	mov    0x460(%rsp),%rsi
    1679:	mov    0x458(%rsp),%rdi
    1681:	call   1686 <botlish_fn_19+0x2fe>
			1682: R_X86_64_PLT32	rt_list_get-0x4
    1686:	mov    %rax,%r8
    1689:	mov    %rax,0x4b8(%rsp)
    1691:	test   %r8,%rax
    1694:	je     18b6 <botlish_fn_19+0x52e>
    169a:	mov    0x4b8(%rsp),%rax
    16a2:	jmp    16bf <botlish_fn_19+0x337>
    16a7:	mov    0x460(%rsp),%rcx
    16af:	mov    0x10(%rcx),%rcx
    16b3:	mov    (%rcx,%rax,8),%rax
    16b7:	mov    %rax,0x4b8(%rsp)
    16bf:	mov    %rax,0x78(%rsp)
    16c4:	mov    0x4b8(%rsp),%rsi
    16cc:	mov    0x458(%rsp),%rdi
    16d4:	call   16d9 <botlish_fn_19+0x351>
			16d5: R_X86_64_PLT32	rt_list_len-0x4
    16d9:	mov    %rax,0x4b0(%rsp)
    16e1:	mov    %rax,0x80(%rsp)
    16e9:	movq   $0x1,0x88(%rsp)
    16f5:	xor    %rdx,%rdx
    16f8:	mov    0x458(%rsp),%rdi
    1700:	mov    %rdx,%rsi
    1703:	call   1708 <botlish_fn_19+0x380>
			1704: R_X86_64_PLT32	rt_list_new-0x4
    1708:	mov    %rax,%rcx
    170b:	mov    %rax,0x498(%rsp)
    1713:	test   %rcx,%rax
    1716:	je     18b6 <botlish_fn_19+0x52e>
    171c:	mov    0x498(%rsp),%rax
    1724:	mov    %rax,0x90(%rsp)
    172c:	mov    0x4b0(%rsp),%rax
    1734:	test   $0x1,%rax
    173a:	jne    176f <botlish_fn_19+0x3e7>
    1740:	mov    $0x1,%esi
    1745:	mov    0x4b0(%rsp),%rdx
    174d:	mov    0x458(%rsp),%rdi
    1755:	call   175a <botlish_fn_19+0x3d2>
			1756: R_X86_64_PLT32	rt_int_cmp-0x4
    175a:	mov    $0x2,%ecx
    175f:	test   %rax,%rax
    1762:	cmovl  0x906e(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    176a:	jmp    1788 <botlish_fn_19+0x400>
    176f:	mov    $0x2,%ecx
    1774:	mov    0x4b0(%rsp),%rax
    177c:	cmp    $0x1,%rax
    1780:	cmovg  0x9050(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    1788:	cmp    $0x6,%rcx
    178c:	je     187e <botlish_fn_19+0x4f6>
    1792:	lea    0x160(%rsp),%rcx
    179a:	movq   $0x0,0x160(%rsp)
    17a6:	mov    0x498(%rsp),%rax
    17ae:	mov    %rax,0x168(%rsp)
    17b6:	mov    $0x1,%esi
    17bb:	mov    $0x2,%edx
    17c0:	mov    0x458(%rsp),%rdi
    17c8:	call   17cd <botlish_fn_19+0x445>
			17c9: R_X86_64_PLT32	rt_construct-0x4
    17cd:	test   %rax,%rax
    17d0:	je     18b6 <botlish_fn_19+0x52e>
    17d6:	mov    $0x3,%edx
    17db:	movq   $0x3,0x40(%rsp)
    17e4:	mov    0x4c0(%rsp),%rsi
    17ec:	test   $0x1,%rsi
    17f3:	jne    1806 <botlish_fn_19+0x47e>
    17f9:	mov    0x4c0(%rsp),%rsi
    1801:	jmp    183f <botlish_fn_19+0x4b7>
    1806:	mov    0x4c0(%rsp),%rsi
    180e:	mov    %rsi,%rdi
    1811:	add    $0x2,%rdi
    1815:	seto   %r9b
    1819:	test   %r9b,%r9b
    181c:	je     182f <botlish_fn_19+0x4a7>
    1822:	mov    0x4c0(%rsp),%rsi
    182a:	jmp    183f <botlish_fn_19+0x4b7>
    182f:	mov    %rdi,%rsi
    1832:	mov    %rdi,0x4c0(%rsp)
    183a:	jmp    1857 <botlish_fn_19+0x4cf>
    183f:	mov    0x458(%rsp),%rdi
    1847:	call   184c <botlish_fn_19+0x4c4>
			1848: R_X86_64_PLT32	rt_int_add-0x4
    184c:	mov    %rax,%rsi
    184f:	mov    %rax,0x4c0(%rsp)
    1857:	mov    %rsi,0x70(%rsp)
    185c:	mov    $0x1,%esi
    1861:	mov    %rsi,0x4a8(%rsp)
    1869:	mov    0x4c0(%rsp),%rax
    1871:	mov    0x538(%rsp),%rsi
    1879:	jmp    157c <botlish_fn_19+0x1f4>
    187e:	mov    0x4b8(%rsp),%rax
    1886:	mov    0x8(%rax),%rax
    188a:	test   %rax,%rax
    188d:	jne    1916 <botlish_fn_19+0x58e>
    1893:	mov    $0x1,%edx
    1898:	mov    0x4b8(%rsp),%rsi
    18a0:	mov    0x458(%rsp),%rdi
    18a8:	call   18ad <botlish_fn_19+0x525>
			18a9: R_X86_64_PLT32	rt_list_get-0x4
    18ad:	test   %rax,%rax
    18b0:	jne    190e <botlish_fn_19+0x586>
    18b6:	mov    0x458(%rsp),%rdi
    18be:	call   18c3 <botlish_fn_19+0x53b>
			18bf: R_X86_64_PLT32	rt_co_failed-0x4
    18c3:	mov    %rax,0x58(%rsp)
    18c8:	movq   $0xa,0x90(%rsp)
    18d4:	mov    %rax,%rsi
    18d7:	mov    0x458(%rsp),%rdi
    18df:	call   18e4 <botlish_fn_19+0x55c>
			18e0: R_X86_64_PLT32	rt_co_resume0-0x4
    18e4:	test   %rax,%rax
    18e7:	je     a61c <botlish_fn_19+0x9294>
    18ed:	mov    0x458(%rsp),%rdi
    18f5:	mov    0x10(%rdi),%rax
    18f9:	mov    0x48(%rax),%rsi
    18fd:	mov    0x1b8(%rax),%rdx
    1904:	call   1909 <botlish_fn_19+0x581>
			1905: R_X86_64_PLT32	rt_raise-0x4
    1909:	jmp    a61c <botlish_fn_19+0x9294>
    190e:	mov    %rax,%rdx
    1911:	jmp    1925 <botlish_fn_19+0x59d>
    1916:	mov    0x4b8(%rsp),%rax
    191e:	mov    0x10(%rax),%rax
    1922:	mov    (%rax),%rdx
    1925:	mov    %rdx,0x50(%rsp)
    192a:	mov    $0x1,%ecx
    192f:	mov    %rcx,0x488(%rsp)
    1937:	mov    0x488(%rsp),%rax
    193f:	mov    %rax,0x4a8(%rsp)
    1947:	mov    %rdx,0x10(%rsp)
    194c:	mov    %rdx,%rbx
    194f:	movq   $0xa,0xa8(%rsp)
    195b:	movq   $0xa,0xb0(%rsp)
    1967:	movq   $0xa,0x98(%rsp)
    1973:	movq   $0xa,0xa0(%rsp)
    197f:	mov    0x468(%rsp),%rcx
    1987:	mov    %rbx,0x4a0(%rsp)
    198f:	mov    %rcx,0xa8(%rsp)
    1997:	movq   $0x1,0x28(%rsp)
    19a0:	mov    $0x3,%ecx
    19a5:	mov    %rcx,0x530(%rsp)
    19ad:	movq   $0x3,0x30(%rsp)
    19b6:	lea    0x1d0(%rsp),%rdx
    19be:	movq   $0x1,0x1d0(%rsp)
    19ca:	movq   $0x3,0x1d8(%rsp)
    19d6:	mov    $0x2,%esi
    19db:	mov    0x458(%rsp),%rdi
    19e3:	call   19e8 <botlish_fn_19+0x660>
			19e4: R_X86_64_PLT32	rt_list_new-0x4
    19e8:	test   %rax,%rax
    19eb:	jne    1a6e <botlish_fn_19+0x6e6>
    19f1:	mov    0x458(%rsp),%rdi
    19f9:	call   19fe <botlish_fn_19+0x676>
			19fa: R_X86_64_PLT32	rt_co_failed-0x4
    19fe:	mov    %rax,0xa0(%rsp)
    1a06:	mov    %rax,%rsi
    1a09:	mov    0x458(%rsp),%rdi
    1a11:	call   1a16 <botlish_fn_19+0x68e>
			1a12: R_X86_64_PLT32	rt_co_resume0-0x4
    1a16:	test   %rax,%rax
    1a19:	je     1a3b <botlish_fn_19+0x6b3>
    1a1f:	mov    0x458(%rsp),%rdi
    1a27:	mov    0x10(%rdi),%rax
    1a2b:	mov    0x48(%rax),%rsi
    1a2f:	mov    0x1b8(%rax),%rdx
    1a36:	call   1a3b <botlish_fn_19+0x6b3>
			1a37: R_X86_64_PLT32	rt_raise-0x4
    1a3b:	mov    0x458(%rsp),%rdi
    1a43:	call   1a48 <botlish_fn_19+0x6c0>
			1a44: R_X86_64_PLT32	rt_declared_error-0x4
    1a48:	cmp    $0x6,%rax
    1a4c:	je     a61c <botlish_fn_19+0x9294>
    1a52:	mov    0x458(%rsp),%rdi
    1a5a:	call   1a5f <botlish_fn_19+0x6d7>
			1a5b: R_X86_64_PLT32	rt_declared_error-0x4
    1a5f:	cmp    $0x7,%rax
    1a63:	jne    a61c <botlish_fn_19+0x9294>
    1a69:	jmp    a61c <botlish_fn_19+0x9294>
    1a6e:	mov    %rax,0x28(%rsp)
    1a73:	mov    %rax,%rsi
    1a76:	mov    0x458(%rsp),%rdi
    1a7e:	call   1a83 <botlish_fn_19+0x6fb>
			1a7f: R_X86_64_PLT32	rt_mv_from_list-0x4
    1a83:	mov    %rax,%rcx
    1a86:	mov    %rax,0x528(%rsp)
    1a8e:	mov    %rcx,0xb0(%rsp)
    1a96:	movq   $0x6,0x98(%rsp)
    1aa2:	movq   $0x3,(%rsp)
    1aaa:	mov    %rbx,%rdx
    1aad:	mov    0x530(%rsp),%rsi
    1ab5:	mov    0x458(%rsp),%rdi
    1abd:	call   1ac2 <botlish_fn_19+0x73a>
			1abe: R_X86_64_PLT32	rt_mutarray_create-0x4
    1ac2:	mov    %rax,%rcx
    1ac5:	test   %rcx,%rcx
    1ac8:	je     a61c <botlish_fn_19+0x9294>
    1ace:	mov    %rcx,(%rsp)
    1ad2:	mov    %rcx,0x520(%rsp)
    1ada:	movq   $0x3,0x10(%rsp)
    1ae3:	mov    $0x1,%edx
    1ae8:	movq   $0x1,0x18(%rsp)
    1af1:	mov    0x530(%rsp),%rsi
    1af9:	mov    0x458(%rsp),%rdi
    1b01:	call   1b06 <botlish_fn_19+0x77e>
			1b02: R_X86_64_PLT32	rt_mutarray_create-0x4
    1b06:	mov    %rax,%rcx
    1b09:	test   %rcx,%rcx
    1b0c:	je     a61c <botlish_fn_19+0x9294>
    1b12:	mov    %rcx,0x10(%rsp)
    1b17:	mov    %rcx,0x518(%rsp)
    1b1f:	movq   $0x3,0x18(%rsp)
    1b28:	mov    $0x1,%edx
    1b2d:	movq   $0x1,0x20(%rsp)
    1b36:	mov    0x530(%rsp),%rsi
    1b3e:	mov    0x458(%rsp),%rdi
    1b46:	call   1b4b <botlish_fn_19+0x7c3>
			1b47: R_X86_64_PLT32	rt_mutarray_create-0x4
    1b4b:	mov    %rax,%rcx
    1b4e:	test   %rcx,%rcx
    1b51:	je     a61c <botlish_fn_19+0x9294>
    1b57:	mov    %rcx,0x18(%rsp)
    1b5c:	mov    %rcx,0x510(%rsp)
    1b64:	movq   $0x3,0x20(%rsp)
    1b6d:	mov    $0x2,%edx
    1b72:	movq   $0x2,0x28(%rsp)
    1b7b:	mov    0x530(%rsp),%rsi
    1b83:	mov    0x458(%rsp),%rdi
    1b8b:	call   1b90 <botlish_fn_19+0x808>
			1b8c: R_X86_64_PLT32	rt_mutarray_create-0x4
    1b90:	mov    %rax,%r12
    1b93:	test   %r12,%r12
    1b96:	mov    %r12,0x508(%rsp)
    1b9e:	je     a61c <botlish_fn_19+0x9294>
    1ba4:	mov    0x508(%rsp),%r12
    1bac:	mov    %r12,0x20(%rsp)
    1bb1:	mov    $0x1,%r12d
    1bb7:	mov    %r12,0x490(%rsp)
    1bbf:	mov    $0x6,%r12d
    1bc5:	mov    %r12,0x4c8(%rsp)
    1bcd:	mov    $0xffffffffffffffff,%rdx
    1bd4:	mov    %rdx,0x500(%rsp)
    1bdc:	mov    $0x7,%ecx
    1be1:	mov    %rcx,0x4f8(%rsp)
    1be9:	mov    0x520(%rsp),%rcx
    1bf1:	mov    0x10(%rcx),%rax
    1bf5:	mov    (%rax),%rsi
    1bf8:	mov    %rsi,0x28(%rsp)
    1bfd:	mov    %rsi,0x4f0(%rsp)
    1c05:	mov    0x4f0(%rsp),%rsi
    1c0d:	mov    0x458(%rsp),%rdi
    1c15:	call   1c1a <botlish_fn_19+0x892>
			1c16: R_X86_64_PLT32	botlish_fn_13-0x4
    1c1a:	cmp    $0x6,%rax
    1c1e:	je     a015 <botlish_fn_19+0x8c8d>
    1c24:	mov    0x518(%rsp),%rcx
    1c2c:	mov    0x10(%rcx),%rax
    1c30:	mov    (%rax),%rcx
    1c33:	mov    %rcx,0x30(%rsp)
    1c38:	mov    %rcx,0x4e8(%rsp)
    1c40:	mov    0x4f0(%rsp),%rsi
    1c48:	test   $0x1,%rsi
    1c4f:	jne    1c87 <botlish_fn_19+0x8ff>
    1c55:	mov    0x500(%rsp),%rdx
    1c5d:	mov    0x4f0(%rsp),%rsi
    1c65:	mov    0x458(%rsp),%rdi
    1c6d:	call   1c72 <botlish_fn_19+0x8ea>
			1c6e: R_X86_64_PLT32	rt_int_cmp-0x4
    1c72:	mov    $0x2,%ecx
    1c77:	test   %rax,%rax
    1c7a:	cmove  0x8b56(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    1c82:	jmp    1ca0 <botlish_fn_19+0x918>
    1c87:	mov    $0x2,%ecx
    1c8c:	mov    0x4f0(%rsp),%rsi
    1c94:	cmp    $0xffffffffffffffff,%rsi
    1c98:	cmove  0x8b38(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    1ca0:	cmp    $0x6,%rcx
    1ca4:	je     98ff <botlish_fn_19+0x8577>
    1caa:	movq   $0xa,0xc8(%rsp)
    1cb6:	movq   $0xa,0xd0(%rsp)
    1cc2:	movq   $0xa,0xd8(%rsp)
    1cce:	movq   $0xa,0xe0(%rsp)
    1cda:	movq   $0xa,0xe8(%rsp)
    1ce6:	movq   $0xa,0xb8(%rsp)
    1cf2:	movq   $0xa,0xc0(%rsp)
    1cfe:	mov    0x4f0(%rsp),%rsi
    1d06:	test   $0x1,%rsi
    1d0d:	jne    1d42 <botlish_fn_19+0x9ba>
    1d13:	mov    $0xbb,%edx
    1d18:	mov    0x4f0(%rsp),%rsi
    1d20:	mov    0x458(%rsp),%rdi
    1d28:	call   1d2d <botlish_fn_19+0x9a5>
			1d29: R_X86_64_PLT32	rt_int_cmp-0x4
    1d2d:	mov    $0x2,%ecx
    1d32:	test   %rax,%rax
    1d35:	cmovl  0x8a9b(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    1d3d:	jmp    1d5e <botlish_fn_19+0x9d6>
    1d42:	mov    $0x2,%ecx
    1d47:	mov    0x4f0(%rsp),%rsi
    1d4f:	cmp    $0xbb,%rsi
    1d56:	cmovl  0x8a7a(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    1d5e:	cmp    $0x6,%rcx
    1d62:	je     1ff3 <botlish_fn_19+0xc6b>
    1d68:	mov    0x4f0(%rsp),%rsi
    1d70:	test   $0x1,%rsi
    1d77:	jne    1dac <botlish_fn_19+0xa24>
    1d7d:	mov    $0xe9,%edx
    1d82:	mov    0x4f0(%rsp),%rsi
    1d8a:	mov    0x458(%rsp),%rdi
    1d92:	call   1d97 <botlish_fn_19+0xa0f>
			1d93: R_X86_64_PLT32	rt_int_cmp-0x4
    1d97:	mov    $0x2,%ecx
    1d9c:	test   %rax,%rax
    1d9f:	cmovl  0x8a31(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    1da7:	jmp    1dc8 <botlish_fn_19+0xa40>
    1dac:	mov    $0x2,%ecx
    1db1:	mov    0x4f0(%rsp),%rsi
    1db9:	cmp    $0xe9,%rsi
    1dc0:	cmovl  0x8a10(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    1dc8:	cmp    $0x6,%rcx
    1dcc:	je     1f74 <botlish_fn_19+0xbec>
    1dd2:	mov    0x4f0(%rsp),%rsi
    1dda:	test   $0x1,%rsi
    1de1:	jne    1e16 <botlish_fn_19+0xa8e>
    1de7:	mov    $0xf9,%edx
    1dec:	mov    0x4f0(%rsp),%rsi
    1df4:	mov    0x458(%rsp),%rdi
    1dfc:	call   1e01 <botlish_fn_19+0xa79>
			1dfd: R_X86_64_PLT32	rt_int_cmp-0x4
    1e01:	mov    $0x2,%ecx
    1e06:	test   %rax,%rax
    1e09:	cmovl  0x89c7(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    1e11:	jmp    1e32 <botlish_fn_19+0xaaa>
    1e16:	mov    $0x2,%ecx
    1e1b:	mov    0x4f0(%rsp),%rsi
    1e23:	cmp    $0xf9,%rsi
    1e2a:	cmovl  0x89a6(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    1e32:	cmp    $0x6,%rcx
    1e36:	je     1f31 <botlish_fn_19+0xba9>
    1e3c:	mov    0x4f0(%rsp),%rsi
    1e44:	test   $0x1,%rsi
    1e4b:	jne    1e80 <botlish_fn_19+0xaf8>
    1e51:	mov    $0xfb,%edx
    1e56:	mov    0x4f0(%rsp),%rsi
    1e5e:	mov    0x458(%rsp),%rdi
    1e66:	call   1e6b <botlish_fn_19+0xae3>
			1e67: R_X86_64_PLT32	rt_int_cmp-0x4
    1e6b:	mov    $0x2,%ecx
    1e70:	test   %rax,%rax
    1e73:	cmovl  0x895d(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    1e7b:	jmp    1e9c <botlish_fn_19+0xb14>
    1e80:	mov    $0x2,%ecx
    1e85:	mov    0x4f0(%rsp),%rsi
    1e8d:	cmp    $0xfb,%rsi
    1e94:	cmovl  0x893c(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    1e9c:	cmp    $0x6,%rcx
    1ea0:	je     1f27 <botlish_fn_19+0xb9f>
    1ea6:	mov    0x4f0(%rsp),%rsi
    1eae:	test   $0x1,%rsi
    1eb5:	jne    1eea <botlish_fn_19+0xb62>
    1ebb:	mov    $0xfd,%edx
    1ec0:	mov    0x4f0(%rsp),%rsi
    1ec8:	mov    0x458(%rsp),%rdi
    1ed0:	call   1ed5 <botlish_fn_19+0xb4d>
			1ed1: R_X86_64_PLT32	rt_int_cmp-0x4
    1ed5:	mov    $0x2,%ecx
    1eda:	test   %rax,%rax
    1edd:	cmovl  0x88f3(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    1ee5:	jmp    1f06 <botlish_fn_19+0xb7e>
    1eea:	mov    $0x2,%ecx
    1eef:	mov    0x4f0(%rsp),%rsi
    1ef7:	cmp    $0xfd,%rsi
    1efe:	cmovl  0x88d2(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    1f06:	cmp    $0x6,%rcx
    1f0a:	je     1f1a <botlish_fn_19+0xb92>
    1f10:	mov    $0xd,%ecx
    1f15:	jmp    21ff <botlish_fn_19+0xe77>
    1f1a:	mov    0x530(%rsp),%rcx
    1f22:	jmp    21ff <botlish_fn_19+0xe77>
    1f27:	mov    $0xd,%ecx
    1f2c:	jmp    21ff <botlish_fn_19+0xe77>
    1f31:	mov    0x4f0(%rsp),%rsi
    1f39:	mov    %rsi,%rax
    1f3c:	sar    $1,%rax
    1f3f:	cmp    $0x75,%rax
    1f43:	jl     1f6a <botlish_fn_19+0xbe2>
    1f49:	cmp    $0x7b,%rax
    1f4d:	jl     1f60 <botlish_fn_19+0xbd8>
    1f53:	mov    0x530(%rsp),%rcx
    1f5b:	jmp    21ff <botlish_fn_19+0xe77>
    1f60:	mov    $0xd,%ecx
    1f65:	jmp    21ff <botlish_fn_19+0xe77>
    1f6a:	mov    $0xb,%ecx
    1f6f:	jmp    21ff <botlish_fn_19+0xe77>
    1f74:	mov    0x4f0(%rsp),%rsi
    1f7c:	mov    %rsi,%rcx
    1f7f:	sar    $1,%rcx
    1f82:	cmp    $0x67,%rcx
    1f86:	jl     1fbe <botlish_fn_19+0xc36>
    1f8c:	cmp    $0x6e,%rcx
    1f90:	jl     1fb4 <botlish_fn_19+0xc2c>
    1f96:	cmp    $0x6f,%rcx
    1f9a:	jl     1faa <botlish_fn_19+0xc22>
    1fa0:	mov    $0xd,%ecx
    1fa5:	jmp    21ff <botlish_fn_19+0xe77>
    1faa:	mov    $0xb,%ecx
    1faf:	jmp    21ff <botlish_fn_19+0xe77>
    1fb4:	mov    $0xd,%ecx
    1fb9:	jmp    21ff <botlish_fn_19+0xe77>
    1fbe:	cmp    $0x5e,%rcx
    1fc2:	jl     1fe6 <botlish_fn_19+0xc5e>
    1fc8:	cmp    $0x66,%rcx
    1fcc:	jl     1fdc <botlish_fn_19+0xc54>
    1fd2:	mov    $0xb,%ecx
    1fd7:	jmp    21ff <botlish_fn_19+0xe77>
    1fdc:	mov    $0xd,%ecx
    1fe1:	jmp    21ff <botlish_fn_19+0xe77>
    1fe6:	mov    0x530(%rsp),%rcx
    1fee:	jmp    21ff <botlish_fn_19+0xe77>
    1ff3:	mov    0x4f0(%rsp),%rsi
    1ffb:	test   $0x1,%rsi
    2002:	jne    2037 <botlish_fn_19+0xcaf>
    2008:	mov    $0x5d,%edx
    200d:	mov    0x4f0(%rsp),%rsi
    2015:	mov    0x458(%rsp),%rdi
    201d:	call   2022 <botlish_fn_19+0xc9a>
			201e: R_X86_64_PLT32	rt_int_cmp-0x4
    2022:	mov    $0x2,%ecx
    2027:	test   %rax,%rax
    202a:	cmovl  0x87a6(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2032:	jmp    2050 <botlish_fn_19+0xcc8>
    2037:	mov    $0x2,%ecx
    203c:	mov    0x4f0(%rsp),%rsi
    2044:	cmp    $0x5d,%rsi
    2048:	cmovl  0x8788(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2050:	cmp    $0x6,%rcx
    2054:	je     20dc <botlish_fn_19+0xd54>
    205a:	mov    0x4f0(%rsp),%rsi
    2062:	mov    %rsi,%r11
    2065:	sar    $1,%r11
    2068:	cmp    $0x3b,%r11
    206c:	jl     20a7 <botlish_fn_19+0xd1f>
    2072:	cmp    $0x5b,%r11
    2076:	jl     209d <botlish_fn_19+0xd15>
    207c:	cmp    $0x5c,%r11
    2080:	jl     2090 <botlish_fn_19+0xd08>
    2086:	mov    $0xd,%ecx
    208b:	jmp    21ff <botlish_fn_19+0xe77>
    2090:	mov    0x530(%rsp),%rcx
    2098:	jmp    21ff <botlish_fn_19+0xe77>
    209d:	mov    $0xd,%ecx
    20a2:	jmp    21ff <botlish_fn_19+0xe77>
    20a7:	cmp    $0x30,%r11
    20ab:	jl     20d2 <botlish_fn_19+0xd4a>
    20b1:	cmp    $0x3a,%r11
    20b5:	jl     20c8 <botlish_fn_19+0xd40>
    20bb:	mov    0x530(%rsp),%rcx
    20c3:	jmp    21ff <botlish_fn_19+0xe77>
    20c8:	mov    $0x9,%ecx
    20cd:	jmp    21ff <botlish_fn_19+0xe77>
    20d2:	mov    $0xd,%ecx
    20d7:	jmp    21ff <botlish_fn_19+0xe77>
    20dc:	mov    0x4f0(%rsp),%rsi
    20e4:	test   $0x1,%rsi
    20eb:	jne    2120 <botlish_fn_19+0xd98>
    20f1:	mov    $0x47,%edx
    20f6:	mov    0x4f0(%rsp),%rsi
    20fe:	mov    0x458(%rsp),%rdi
    2106:	call   210b <botlish_fn_19+0xd83>
			2107: R_X86_64_PLT32	rt_int_cmp-0x4
    210b:	mov    $0x2,%esi
    2110:	test   %rax,%rax
    2113:	cmovl  0x86bd(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    211b:	jmp    2139 <botlish_fn_19+0xdb1>
    2120:	mov    $0x2,%esi
    2125:	mov    0x4f0(%rsp),%rax
    212d:	cmp    $0x47,%rax
    2131:	cmovl  0x869f(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    2139:	cmp    $0x6,%rsi
    213d:	je     2186 <botlish_fn_19+0xdfe>
    2143:	mov    0x4f0(%rsp),%rsi
    214b:	mov    %rsi,%rax
    214e:	sar    $1,%rax
    2151:	cmp    $0x2c,%rax
    2155:	jl     217c <botlish_fn_19+0xdf4>
    215b:	cmp    $0x2d,%rax
    215f:	jl     216f <botlish_fn_19+0xde7>
    2165:	mov    $0x9,%ecx
    216a:	jmp    21ff <botlish_fn_19+0xe77>
    216f:	mov    0x530(%rsp),%rcx
    2177:	jmp    21ff <botlish_fn_19+0xe77>
    217c:	mov    $0xd,%ecx
    2181:	jmp    21ff <botlish_fn_19+0xe77>
    2186:	mov    0x4f0(%rsp),%rsi
    218e:	test   $0x1,%rsi
    2195:	jne    21ca <botlish_fn_19+0xe42>
    219b:	mov    $0x45,%edx
    21a0:	mov    0x4f0(%rsp),%rsi
    21a8:	mov    0x458(%rsp),%rdi
    21b0:	call   21b5 <botlish_fn_19+0xe2d>
			21b1: R_X86_64_PLT32	rt_int_cmp-0x4
    21b5:	mov    $0x2,%ecx
    21ba:	test   %rax,%rax
    21bd:	cmovl  0x8613(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    21c5:	jmp    21e3 <botlish_fn_19+0xe5b>
    21ca:	mov    $0x2,%ecx
    21cf:	mov    0x4f0(%rsp),%rsi
    21d7:	cmp    $0x45,%rsi
    21db:	cmovl  0x85f5(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    21e3:	cmp    $0x6,%rcx
    21e7:	je     21fa <botlish_fn_19+0xe72>
    21ed:	mov    0x4f8(%rsp),%rcx
    21f5:	jmp    21ff <botlish_fn_19+0xe77>
    21fa:	mov    $0xd,%ecx
    21ff:	sar    $1,%rcx
    2202:	cmp    $0x1,%rcx
    2206:	je     3557 <botlish_fn_19+0x21cf>
    220c:	cmp    $0x3,%rcx
    2210:	je     2a42 <botlish_fn_19+0x16ba>
    2216:	cmp    $0x4,%rcx
    221a:	je     26c8 <botlish_fn_19+0x1340>
    2220:	cmp    $0x5,%rcx
    2224:	je     232f <botlish_fn_19+0xfa7>
    222a:	mov    0x4f0(%rsp),%rsi
    2232:	test   $0x1,%rsi
    2239:	jne    2271 <botlish_fn_19+0xee9>
    223f:	mov    0x500(%rsp),%rdx
    2247:	mov    0x4f0(%rsp),%rsi
    224f:	mov    0x458(%rsp),%rdi
    2257:	call   225c <botlish_fn_19+0xed4>
			2258: R_X86_64_PLT32	rt_int_cmp-0x4
    225c:	mov    $0x2,%ecx
    2261:	test   %rax,%rax
    2264:	cmove  0x856c(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    226c:	jmp    228a <botlish_fn_19+0xf02>
    2271:	mov    $0x2,%ecx
    2276:	mov    0x4f0(%rsp),%rsi
    227e:	cmp    $0xffffffffffffffff,%rsi
    2282:	cmove  0x854e(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    228a:	cmp    $0x6,%rcx
    228e:	je     22e8 <botlish_fn_19+0xf60>
    2294:	mov    0x458(%rsp),%rdi
    229c:	mov    0x10(%rdi),%rcx
    22a0:	mov    0x200(%rcx),%rax
    22a7:	mov    0x1f8(%rcx),%rdx
    22ae:	lea    0x3b8(%rsp),%r9
    22b6:	mov    %rax,0x3b8(%rsp)
    22be:	mov    0x4f0(%rsp),%rsi
    22c6:	mov    %rsi,0x3c0(%rsp)
    22ce:	mov    $0x1,%esi
    22d3:	mov    $0x8,%ecx
    22d8:	mov    $0x2,%r8d
    22de:	call   22e3 <botlish_fn_19+0xf5b>
			22df: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    22e3:	jmp    3342 <botlish_fn_19+0x1fba>
    22e8:	mov    0x458(%rsp),%rdi
    22f0:	mov    0x10(%rdi),%rcx
    22f4:	mov    0x200(%rcx),%rax
    22fb:	mov    0x1f0(%rcx),%rdx
    2302:	lea    0x3b0(%rsp),%r9
    230a:	mov    %rax,0x3b0(%rsp)
    2312:	mov    $0x2,%esi
    2317:	mov    $0x1,%r8d
    231d:	mov    0x530(%rsp),%rcx
    2325:	call   232a <botlish_fn_19+0xfa2>
			2326: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    232a:	jmp    3342 <botlish_fn_19+0x1fba>
    232f:	mov    0x4f0(%rsp),%rsi
    2337:	test   $0x1,%rsi
    233e:	jne    2373 <botlish_fn_19+0xfeb>
    2344:	mov    $0xdd,%edx
    2349:	mov    0x4f0(%rsp),%rsi
    2351:	mov    0x458(%rsp),%rdi
    2359:	call   235e <botlish_fn_19+0xfd6>
			235a: R_X86_64_PLT32	rt_int_cmp-0x4
    235e:	mov    $0x2,%ecx
    2363:	test   %rax,%rax
    2366:	cmovl  0x846a(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    236e:	jmp    238f <botlish_fn_19+0x1007>
    2373:	mov    $0x2,%ecx
    2378:	mov    0x4f0(%rsp),%rsi
    2380:	cmp    $0xdd,%rsi
    2387:	cmovl  0x8449(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    238f:	cmp    $0x6,%rcx
    2393:	je     24b5 <botlish_fn_19+0x112d>
    2399:	mov    0x4f0(%rsp),%rsi
    23a1:	test   $0x1,%rsi
    23a8:	jne    23dd <botlish_fn_19+0x1055>
    23ae:	mov    $0xe9,%edx
    23b3:	mov    0x4f0(%rsp),%rsi
    23bb:	mov    0x458(%rsp),%rdi
    23c3:	call   23c8 <botlish_fn_19+0x1040>
			23c4: R_X86_64_PLT32	rt_int_cmp-0x4
    23c8:	mov    $0x2,%ecx
    23cd:	test   %rax,%rax
    23d0:	cmovl  0x8400(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    23d8:	jmp    23f9 <botlish_fn_19+0x1071>
    23dd:	mov    $0x2,%ecx
    23e2:	mov    0x4f0(%rsp),%rsi
    23ea:	cmp    $0xe9,%rsi
    23f1:	cmovl  0x83df(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    23f9:	cmp    $0x6,%rcx
    23fd:	je     2485 <botlish_fn_19+0x10fd>
    2403:	mov    0x4f0(%rsp),%rsi
    240b:	test   $0x1,%rsi
    2412:	jne    2447 <botlish_fn_19+0x10bf>
    2418:	mov    $0xeb,%edx
    241d:	mov    0x4f0(%rsp),%rsi
    2425:	mov    0x458(%rsp),%rdi
    242d:	call   2432 <botlish_fn_19+0x10aa>
			242e: R_X86_64_PLT32	rt_int_cmp-0x4
    2432:	mov    $0x2,%ecx
    2437:	test   %rax,%rax
    243a:	cmovl  0x8396(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2442:	jmp    2463 <botlish_fn_19+0x10db>
    2447:	mov    $0x2,%ecx
    244c:	mov    0x4f0(%rsp),%rsi
    2454:	cmp    $0xeb,%rsi
    245b:	cmovl  0x8375(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2463:	cmp    $0x6,%rcx
    2467:	je     2478 <botlish_fn_19+0x10f0>
    246d:	mov    $0x1d,%r15d
    2473:	jmp    2550 <botlish_fn_19+0x11c8>
    2478:	mov    0x530(%rsp),%r15
    2480:	jmp    2550 <botlish_fn_19+0x11c8>
    2485:	mov    0x4f0(%rsp),%rsi
    248d:	mov    %rsi,%rax
    2490:	sar    $1,%rax
    2493:	cmp    $0x6f,%rax
    2497:	jl     24a8 <botlish_fn_19+0x1120>
    249d:	mov    $0x1d,%r15d
    24a3:	jmp    2550 <botlish_fn_19+0x11c8>
    24a8:	mov    0x4f8(%rsp),%r15
    24b0:	jmp    2550 <botlish_fn_19+0x11c8>
    24b5:	mov    0x4f0(%rsp),%rsi
    24bd:	test   $0x1,%rsi
    24c4:	jne    24f9 <botlish_fn_19+0x1171>
    24ca:	mov    $0xcd,%edx
    24cf:	mov    0x4f0(%rsp),%rsi
    24d7:	mov    0x458(%rsp),%rdi
    24df:	call   24e4 <botlish_fn_19+0x115c>
			24e0: R_X86_64_PLT32	rt_int_cmp-0x4
    24e4:	mov    $0x2,%ecx
    24e9:	test   %rax,%rax
    24ec:	cmovl  0x82e4(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    24f4:	jmp    2515 <botlish_fn_19+0x118d>
    24f9:	mov    $0x2,%ecx
    24fe:	mov    0x4f0(%rsp),%rsi
    2506:	cmp    $0xcd,%rsi
    250d:	cmovl  0x82c3(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2515:	cmp    $0x6,%rcx
    2519:	je     254a <botlish_fn_19+0x11c2>
    251f:	mov    0x4f0(%rsp),%rsi
    2527:	sar    $1,%rsi
    252a:	cmp    $0x67,%rsi
    252e:	jl     253f <botlish_fn_19+0x11b7>
    2534:	mov    $0x1d,%r15d
    253a:	jmp    2550 <botlish_fn_19+0x11c8>
    253f:	mov    $0x5,%r15d
    2545:	jmp    2550 <botlish_fn_19+0x11c8>
    254a:	mov    $0x1d,%r15d
    2550:	mov    %r15,%rsi
    2553:	sar    $1,%rsi
    2556:	cmp    $0xc,%rsi
    255a:	jl     2684 <botlish_fn_19+0x12fc>
    2560:	cmp    $0xd,%rsi
    2564:	mov    %rsi,%r12
    2567:	je     29f1 <botlish_fn_19+0x1669>
    256d:	mov    0x4f0(%rsp),%rsi
    2575:	test   $0x1,%rsi
    257c:	jne    25b4 <botlish_fn_19+0x122c>
    2582:	mov    0x500(%rsp),%rdx
    258a:	mov    0x4f0(%rsp),%rsi
    2592:	mov    0x458(%rsp),%rdi
    259a:	call   259f <botlish_fn_19+0x1217>
			259b: R_X86_64_PLT32	rt_int_cmp-0x4
    259f:	mov    $0x2,%ecx
    25a4:	test   %rax,%rax
    25a7:	cmove  0x8229(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    25af:	jmp    25cd <botlish_fn_19+0x1245>
    25b4:	mov    $0x2,%ecx
    25b9:	mov    0x4f0(%rsp),%rsi
    25c1:	cmp    $0xffffffffffffffff,%rsi
    25c5:	cmove  0x820b(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    25cd:	cmp    $0x6,%rcx
    25d1:	je     2634 <botlish_fn_19+0x12ac>
    25d7:	mov    %r12,%rsi
    25da:	mov    0x458(%rsp),%rdi
    25e2:	call   25e7 <botlish_fn_19+0x125f>
			25e3: R_X86_64_PLT32	botlish_fn_3-0x4
    25e7:	mov    0x458(%rsp),%rdi
    25ef:	mov    0x10(%rdi),%rcx
    25f3:	mov    0x1f8(%rcx),%rdx
    25fa:	lea    0x3a0(%rsp),%r9
    2602:	mov    %rax,0x3a0(%rsp)
    260a:	mov    0x4f0(%rsp),%rsi
    2612:	mov    %rsi,0x3a8(%rsp)
    261a:	mov    $0x1,%esi
    261f:	mov    $0x8,%ecx
    2624:	mov    $0x2,%r8d
    262a:	call   262f <botlish_fn_19+0x12a7>
			262b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    262f:	jmp    3342 <botlish_fn_19+0x1fba>
    2634:	mov    %r12,%rsi
    2637:	mov    0x458(%rsp),%rdi
    263f:	call   2644 <botlish_fn_19+0x12bc>
			2640: R_X86_64_PLT32	botlish_fn_3-0x4
    2644:	mov    0x458(%rsp),%rdi
    264c:	mov    0x10(%rdi),%rcx
    2650:	mov    0x1f0(%rcx),%rdx
    2657:	lea    0x398(%rsp),%r9
    265f:	mov    %rax,0x398(%rsp)
    2667:	mov    $0x2,%esi
    266c:	mov    $0x1,%r8d
    2672:	mov    0x530(%rsp),%rcx
    267a:	call   267f <botlish_fn_19+0x12f7>
			267b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    267f:	jmp    3342 <botlish_fn_19+0x1fba>
    2684:	mov    %r15,0xe8(%rsp)
    268c:	mov    $0x6,%r13d
    2692:	movq   $0x6,0xb8(%rsp)
    269e:	mov    $0x5,%ebx
    26a3:	mov    $0xa,%edx
    26a8:	mov    %rdx,%r14
    26ab:	mov    %rdx,0x478(%rsp)
    26b3:	mov    %rdx,0x4d0(%rsp)
    26bb:	mov    %rdx,0x4d8(%rsp)
    26c3:	jmp    35ec <botlish_fn_19+0x2264>
    26c8:	mov    0x4f0(%rsp),%rsi
    26d0:	test   $0x1,%rsi
    26d7:	jne    270c <botlish_fn_19+0x1384>
    26dd:	mov    $0x61,%edx
    26e2:	mov    0x4f0(%rsp),%rsi
    26ea:	mov    0x458(%rsp),%rdi
    26f2:	call   26f7 <botlish_fn_19+0x136f>
			26f3: R_X86_64_PLT32	rt_int_cmp-0x4
    26f7:	mov    $0x2,%ecx
    26fc:	test   %rax,%rax
    26ff:	cmovl  0x80d1(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2707:	jmp    2725 <botlish_fn_19+0x139d>
    270c:	mov    $0x2,%ecx
    2711:	mov    0x4f0(%rsp),%rsi
    2719:	cmp    $0x61,%rsi
    271d:	cmovl  0x80b3(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2725:	cmp    $0x6,%rcx
    2729:	je     2820 <botlish_fn_19+0x1498>
    272f:	mov    0x4f0(%rsp),%rsi
    2737:	test   $0x1,%rsi
    273e:	jne    2773 <botlish_fn_19+0x13eb>
    2744:	mov    $0x63,%edx
    2749:	mov    0x4f0(%rsp),%rsi
    2751:	mov    0x458(%rsp),%rdi
    2759:	call   275e <botlish_fn_19+0x13d6>
			275a: R_X86_64_PLT32	rt_int_cmp-0x4
    275e:	mov    $0x2,%ecx
    2763:	test   %rax,%rax
    2766:	cmovl  0x806a(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    276e:	jmp    278c <botlish_fn_19+0x1404>
    2773:	mov    $0x2,%ecx
    2778:	mov    0x4f0(%rsp),%rsi
    2780:	cmp    $0x63,%rsi
    2784:	cmovl  0x804c(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    278c:	cmp    $0x6,%rcx
    2790:	je     2815 <botlish_fn_19+0x148d>
    2796:	mov    0x4f0(%rsp),%rsi
    279e:	test   $0x1,%rsi
    27a5:	jne    27da <botlish_fn_19+0x1452>
    27ab:	mov    $0x75,%edx
    27b0:	mov    0x4f0(%rsp),%rsi
    27b8:	mov    0x458(%rsp),%rdi
    27c0:	call   27c5 <botlish_fn_19+0x143d>
			27c1: R_X86_64_PLT32	rt_int_cmp-0x4
    27c5:	mov    $0x2,%edx
    27ca:	test   %rax,%rax
    27cd:	cmovl  0x8003(%rip),%rdx        # a7d8 <botlish_fn_19+0x9450>
    27d5:	jmp    27f3 <botlish_fn_19+0x146b>
    27da:	mov    $0x2,%edx
    27df:	mov    0x4f0(%rsp),%rsi
    27e7:	cmp    $0x75,%rsi
    27eb:	cmovl  0x7fe5(%rip),%rdx        # a7d8 <botlish_fn_19+0x9450>
    27f3:	cmp    $0x6,%rdx
    27f7:	je     2808 <botlish_fn_19+0x1480>
    27fd:	mov    $0x17,%r14d
    2803:	jmp    28bd <botlish_fn_19+0x1535>
    2808:	mov    0x4f8(%rsp),%r14
    2810:	jmp    28bd <botlish_fn_19+0x1535>
    2815:	mov    $0x5,%r14d
    281b:	jmp    28bd <botlish_fn_19+0x1535>
    2820:	mov    0x4f0(%rsp),%rsi
    2828:	test   $0x1,%rsi
    282f:	jne    2864 <botlish_fn_19+0x14dc>
    2835:	mov    $0x5b,%edx
    283a:	mov    0x4f0(%rsp),%rsi
    2842:	mov    0x458(%rsp),%rdi
    284a:	call   284f <botlish_fn_19+0x14c7>
			284b: R_X86_64_PLT32	rt_int_cmp-0x4
    284f:	mov    $0x2,%ecx
    2854:	test   %rax,%rax
    2857:	cmovl  0x7f79(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    285f:	jmp    287d <botlish_fn_19+0x14f5>
    2864:	mov    $0x2,%ecx
    2869:	mov    0x4f0(%rsp),%rsi
    2871:	cmp    $0x5b,%rsi
    2875:	cmovl  0x7f5b(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    287d:	cmp    $0x6,%rcx
    2881:	je     28b7 <botlish_fn_19+0x152f>
    2887:	mov    0x4f0(%rsp),%rsi
    288f:	mov    %rsi,%rax
    2892:	sar    $1,%rax
    2895:	cmp    $0x2e,%rax
    2899:	jl     28aa <botlish_fn_19+0x1522>
    289f:	mov    $0x17,%r14d
    28a5:	jmp    28bd <botlish_fn_19+0x1535>
    28aa:	mov    0x530(%rsp),%r14
    28b2:	jmp    28bd <botlish_fn_19+0x1535>
    28b7:	mov    $0x17,%r14d
    28bd:	mov    %r14,%rsi
    28c0:	sar    $1,%rsi
    28c3:	cmp    $0x9,%rsi
    28c7:	jl     29fe <botlish_fn_19+0x1676>
    28cd:	cmp    $0xa,%rsi
    28d1:	mov    %rsi,%r12
    28d4:	je     29f1 <botlish_fn_19+0x1669>
    28da:	mov    0x4f0(%rsp),%rsi
    28e2:	test   $0x1,%rsi
    28e9:	jne    2921 <botlish_fn_19+0x1599>
    28ef:	mov    0x500(%rsp),%rdx
    28f7:	mov    0x4f0(%rsp),%rsi
    28ff:	mov    0x458(%rsp),%rdi
    2907:	call   290c <botlish_fn_19+0x1584>
			2908: R_X86_64_PLT32	rt_int_cmp-0x4
    290c:	mov    $0x2,%ecx
    2911:	test   %rax,%rax
    2914:	cmove  0x7ebc(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    291c:	jmp    293a <botlish_fn_19+0x15b2>
    2921:	mov    $0x2,%ecx
    2926:	mov    0x4f0(%rsp),%rsi
    292e:	cmp    $0xffffffffffffffff,%rsi
    2932:	cmove  0x7e9e(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    293a:	cmp    $0x6,%rcx
    293e:	je     29a1 <botlish_fn_19+0x1619>
    2944:	mov    %r12,%rsi
    2947:	mov    0x458(%rsp),%rdi
    294f:	call   2954 <botlish_fn_19+0x15cc>
			2950: R_X86_64_PLT32	botlish_fn_1-0x4
    2954:	mov    0x458(%rsp),%rdi
    295c:	mov    0x10(%rdi),%rcx
    2960:	mov    0x1f8(%rcx),%rdx
    2967:	lea    0x388(%rsp),%r9
    296f:	mov    %rax,0x388(%rsp)
    2977:	mov    0x4f0(%rsp),%rsi
    297f:	mov    %rsi,0x390(%rsp)
    2987:	mov    $0x1,%esi
    298c:	mov    $0x8,%ecx
    2991:	mov    $0x2,%r8d
    2997:	call   299c <botlish_fn_19+0x1614>
			2998: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    299c:	jmp    3342 <botlish_fn_19+0x1fba>
    29a1:	mov    %r12,%rsi
    29a4:	mov    0x458(%rsp),%rdi
    29ac:	call   29b1 <botlish_fn_19+0x1629>
			29ad: R_X86_64_PLT32	botlish_fn_1-0x4
    29b1:	mov    0x458(%rsp),%rdi
    29b9:	mov    0x10(%rdi),%rcx
    29bd:	mov    0x1f0(%rcx),%rdx
    29c4:	lea    0x380(%rsp),%r9
    29cc:	mov    %rax,0x380(%rsp)
    29d4:	mov    $0x2,%esi
    29d9:	mov    $0x1,%r8d
    29df:	mov    0x530(%rsp),%rcx
    29e7:	call   29ec <botlish_fn_19+0x1664>
			29e8: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    29ec:	jmp    3342 <botlish_fn_19+0x1fba>
    29f1:	mov    0x4f0(%rsp),%rsi
    29f9:	jmp    355e <botlish_fn_19+0x21d6>
    29fe:	mov    %r14,0xe0(%rsp)
    2a06:	mov    $0x6,%r13d
    2a0c:	movq   $0x6,0xb8(%rsp)
    2a18:	mov    $0x4,%ebx
    2a1d:	mov    $0xa,%edx
    2a22:	mov    %rdx,%r15
    2a25:	mov    %rdx,0x478(%rsp)
    2a2d:	mov    %rdx,0x4d0(%rsp)
    2a35:	mov    %rdx,0x4d8(%rsp)
    2a3d:	jmp    35ec <botlish_fn_19+0x2264>
    2a42:	mov    0x4f0(%rsp),%rsi
    2a4a:	test   $0x1,%rsi
    2a51:	jne    2a86 <botlish_fn_19+0x16fe>
    2a57:	mov    $0x45,%edx
    2a5c:	mov    0x4f0(%rsp),%rsi
    2a64:	mov    0x458(%rsp),%rdi
    2a6c:	call   2a71 <botlish_fn_19+0x16e9>
			2a6d: R_X86_64_PLT32	rt_int_cmp-0x4
    2a71:	mov    $0x2,%ecx
    2a76:	test   %rax,%rax
    2a79:	cmovl  0x7d57(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2a81:	jmp    2a9f <botlish_fn_19+0x1717>
    2a86:	mov    $0x2,%ecx
    2a8b:	mov    0x4f0(%rsp),%rsi
    2a93:	cmp    $0x45,%rsi
    2a97:	cmovl  0x7d39(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2a9f:	cmp    $0x6,%rcx
    2aa3:	je     2b27 <botlish_fn_19+0x179f>
    2aa9:	mov    0x4f0(%rsp),%rsi
    2ab1:	test   $0x1,%rsi
    2ab8:	jne    2aed <botlish_fn_19+0x1765>
    2abe:	mov    $0x47,%edx
    2ac3:	mov    0x4f0(%rsp),%rsi
    2acb:	mov    0x458(%rsp),%rdi
    2ad3:	call   2ad8 <botlish_fn_19+0x1750>
			2ad4: R_X86_64_PLT32	rt_int_cmp-0x4
    2ad8:	mov    $0x2,%ecx
    2add:	test   %rax,%rax
    2ae0:	cmovl  0x7cf0(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2ae8:	jmp    2b06 <botlish_fn_19+0x177e>
    2aed:	mov    $0x2,%ecx
    2af2:	mov    0x4f0(%rsp),%rsi
    2afa:	cmp    $0x47,%rsi
    2afe:	cmovl  0x7cd2(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2b06:	cmp    $0x6,%rcx
    2b0a:	je     2b1a <botlish_fn_19+0x1792>
    2b10:	mov    $0xd,%ecx
    2b15:	jmp    2b2c <botlish_fn_19+0x17a4>
    2b1a:	mov    0x530(%rsp),%rcx
    2b22:	jmp    2b2c <botlish_fn_19+0x17a4>
    2b27:	mov    $0xd,%ecx
    2b2c:	mov    %rcx,%rsi
    2b2f:	sar    $1,%rsi
    2b32:	cmp    $0x2,%rsi
    2b36:	jl     350d <botlish_fn_19+0x2185>
    2b3c:	cmp    $0x2,%rsi
    2b40:	je     3501 <botlish_fn_19+0x2179>
    2b46:	cmp    $0x4,%rsi
    2b4a:	je     3123 <botlish_fn_19+0x1d9b>
    2b50:	cmp    $0x5,%rsi
    2b54:	mov    %rsi,%rbx
    2b57:	je     2c74 <botlish_fn_19+0x18ec>
    2b5d:	mov    0x4f0(%rsp),%rsi
    2b65:	test   $0x1,%rsi
    2b6c:	jne    2ba4 <botlish_fn_19+0x181c>
    2b72:	mov    0x500(%rsp),%rdx
    2b7a:	mov    0x4f0(%rsp),%rsi
    2b82:	mov    0x458(%rsp),%rdi
    2b8a:	call   2b8f <botlish_fn_19+0x1807>
			2b8b: R_X86_64_PLT32	rt_int_cmp-0x4
    2b8f:	mov    $0x2,%ecx
    2b94:	test   %rax,%rax
    2b97:	cmove  0x7c39(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2b9f:	jmp    2bbd <botlish_fn_19+0x1835>
    2ba4:	mov    $0x2,%ecx
    2ba9:	mov    0x4f0(%rsp),%rsi
    2bb1:	cmp    $0xffffffffffffffff,%rsi
    2bb5:	cmove  0x7c1b(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2bbd:	cmp    $0x6,%rcx
    2bc1:	je     2c24 <botlish_fn_19+0x189c>
    2bc7:	mov    %rbx,%rsi
    2bca:	mov    0x458(%rsp),%rdi
    2bd2:	call   2bd7 <botlish_fn_19+0x184f>
			2bd3: R_X86_64_PLT32	botlish_fn_9-0x4
    2bd7:	mov    0x458(%rsp),%rdi
    2bdf:	mov    0x10(%rdi),%rcx
    2be3:	mov    0x1f8(%rcx),%rdx
    2bea:	lea    0x370(%rsp),%r9
    2bf2:	mov    %rax,0x370(%rsp)
    2bfa:	mov    0x4f0(%rsp),%rsi
    2c02:	mov    %rsi,0x378(%rsp)
    2c0a:	mov    $0x1,%esi
    2c0f:	mov    $0x8,%ecx
    2c14:	mov    $0x2,%r8d
    2c1a:	call   2c1f <botlish_fn_19+0x1897>
			2c1b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2c1f:	jmp    3342 <botlish_fn_19+0x1fba>
    2c24:	mov    %rbx,%rsi
    2c27:	mov    0x458(%rsp),%rdi
    2c2f:	call   2c34 <botlish_fn_19+0x18ac>
			2c30: R_X86_64_PLT32	botlish_fn_9-0x4
    2c34:	mov    0x458(%rsp),%rdi
    2c3c:	mov    0x10(%rdi),%rcx
    2c40:	mov    0x1f0(%rcx),%rdx
    2c47:	lea    0x368(%rsp),%r9
    2c4f:	mov    %rax,0x368(%rsp)
    2c57:	mov    $0x2,%esi
    2c5c:	mov    $0x1,%r8d
    2c62:	mov    0x530(%rsp),%rcx
    2c6a:	call   2c6f <botlish_fn_19+0x18e7>
			2c6b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2c6f:	jmp    3342 <botlish_fn_19+0x1fba>
    2c74:	mov    0x4f0(%rsp),%rsi
    2c7c:	test   $0x1,%rsi
    2c83:	jne    2cb8 <botlish_fn_19+0x1930>
    2c89:	mov    $0x1dd,%edx
    2c8e:	mov    0x4f0(%rsp),%rsi
    2c96:	mov    0x458(%rsp),%rdi
    2c9e:	call   2ca3 <botlish_fn_19+0x191b>
			2c9f: R_X86_64_PLT32	rt_int_cmp-0x4
    2ca3:	mov    $0x2,%esi
    2ca8:	test   %rax,%rax
    2cab:	cmovl  0x7b25(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    2cb3:	jmp    2cd3 <botlish_fn_19+0x194b>
    2cb8:	mov    $0x2,%esi
    2cbd:	mov    0x4f0(%rsp),%rax
    2cc5:	cmp    $0x1dd,%rax
    2ccb:	cmovl  0x7b05(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    2cd3:	cmp    $0x6,%rsi
    2cd7:	je     2e6b <botlish_fn_19+0x1ae3>
    2cdd:	mov    0x4f0(%rsp),%rsi
    2ce5:	test   $0x1,%rsi
    2cec:	jne    2d21 <botlish_fn_19+0x1999>
    2cf2:	mov    $0x1e3,%edx
    2cf7:	mov    0x4f0(%rsp),%rsi
    2cff:	mov    0x458(%rsp),%rdi
    2d07:	call   2d0c <botlish_fn_19+0x1984>
			2d08: R_X86_64_PLT32	rt_int_cmp-0x4
    2d0c:	mov    $0x2,%ecx
    2d11:	test   %rax,%rax
    2d14:	cmovl  0x7abc(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2d1c:	jmp    2d3d <botlish_fn_19+0x19b5>
    2d21:	mov    $0x2,%ecx
    2d26:	mov    0x4f0(%rsp),%rsi
    2d2e:	cmp    $0x1e3,%rsi
    2d35:	cmovl  0x7a9b(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2d3d:	cmp    $0x6,%rcx
    2d41:	je     2e39 <botlish_fn_19+0x1ab1>
    2d47:	mov    0x4f0(%rsp),%rsi
    2d4f:	test   $0x1,%rsi
    2d56:	jne    2d8b <botlish_fn_19+0x1a03>
    2d5c:	mov    $0x1e9,%edx
    2d61:	mov    0x4f0(%rsp),%rsi
    2d69:	mov    0x458(%rsp),%rdi
    2d71:	call   2d76 <botlish_fn_19+0x19ee>
			2d72: R_X86_64_PLT32	rt_int_cmp-0x4
    2d76:	mov    $0x2,%ecx
    2d7b:	test   %rax,%rax
    2d7e:	cmovl  0x7a52(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2d86:	jmp    2da7 <botlish_fn_19+0x1a1f>
    2d8b:	mov    $0x2,%ecx
    2d90:	mov    0x4f0(%rsp),%rsi
    2d98:	cmp    $0x1e9,%rsi
    2d9f:	cmovl  0x7a31(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2da7:	cmp    $0x6,%rcx
    2dab:	je     2e2f <botlish_fn_19+0x1aa7>
    2db1:	mov    0x4f0(%rsp),%rsi
    2db9:	test   $0x1,%rsi
    2dc0:	jne    2df5 <botlish_fn_19+0x1a6d>
    2dc6:	mov    $0x1eb,%edx
    2dcb:	mov    0x4f0(%rsp),%rsi
    2dd3:	mov    0x458(%rsp),%rdi
    2ddb:	call   2de0 <botlish_fn_19+0x1a58>
			2ddc: R_X86_64_PLT32	rt_int_cmp-0x4
    2de0:	mov    $0x2,%ecx
    2de5:	test   %rax,%rax
    2de8:	cmovl  0x79e8(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2df0:	jmp    2e11 <botlish_fn_19+0x1a89>
    2df5:	mov    $0x2,%ecx
    2dfa:	mov    0x4f0(%rsp),%rsi
    2e02:	cmp    $0x1eb,%rsi
    2e09:	cmovl  0x79c7(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2e11:	cmp    $0x6,%rcx
    2e15:	je     2e25 <botlish_fn_19+0x1a9d>
    2e1b:	mov    $0x15,%ecx
    2e20:	jmp    2f98 <botlish_fn_19+0x1c10>
    2e25:	mov    $0xf,%ecx
    2e2a:	jmp    2f98 <botlish_fn_19+0x1c10>
    2e2f:	mov    $0xd,%ecx
    2e34:	jmp    2f98 <botlish_fn_19+0x1c10>
    2e39:	mov    0x4f0(%rsp),%rsi
    2e41:	mov    %rsi,%r11
    2e44:	sar    $1,%r11
    2e47:	cmp    $0xf0,%r11
    2e4e:	jl     2e5e <botlish_fn_19+0x1ad6>
    2e54:	mov    $0xb,%ecx
    2e59:	jmp    2f98 <botlish_fn_19+0x1c10>
    2e5e:	mov    0x4f8(%rsp),%rcx
    2e66:	jmp    2f98 <botlish_fn_19+0x1c10>
    2e6b:	mov    0x4f0(%rsp),%rsi
    2e73:	test   $0x1,%rsi
    2e7a:	jne    2eaf <botlish_fn_19+0x1b27>
    2e80:	mov    $0x1c1,%edx
    2e85:	mov    0x4f0(%rsp),%rsi
    2e8d:	mov    0x458(%rsp),%rdi
    2e95:	call   2e9a <botlish_fn_19+0x1b12>
			2e96: R_X86_64_PLT32	rt_int_cmp-0x4
    2e9a:	mov    $0x2,%ecx
    2e9f:	test   %rax,%rax
    2ea2:	cmovl  0x792e(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2eaa:	jmp    2ecb <botlish_fn_19+0x1b43>
    2eaf:	mov    $0x2,%ecx
    2eb4:	mov    0x4f0(%rsp),%rsi
    2ebc:	cmp    $0x1c1,%rsi
    2ec3:	cmovl  0x790d(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2ecb:	cmp    $0x6,%rcx
    2ecf:	je     2f1c <botlish_fn_19+0x1b94>
    2ed5:	mov    0x4f0(%rsp),%rsi
    2edd:	mov    %rsi,%rax
    2ee0:	sar    $1,%rax
    2ee3:	cmp    $0xe1,%rax
    2ee9:	jl     2f12 <botlish_fn_19+0x1b8a>
    2eef:	cmp    $0xed,%rax
    2ef5:	jl     2f05 <botlish_fn_19+0x1b7d>
    2efb:	mov    $0x9,%ecx
    2f00:	jmp    2f98 <botlish_fn_19+0x1c10>
    2f05:	mov    0x4f8(%rsp),%rcx
    2f0d:	jmp    2f98 <botlish_fn_19+0x1c10>
    2f12:	mov    $0x5,%ecx
    2f17:	jmp    2f98 <botlish_fn_19+0x1c10>
    2f1c:	mov    0x4f0(%rsp),%rsi
    2f24:	test   $0x1,%rsi
    2f2b:	jne    2f60 <botlish_fn_19+0x1bd8>
    2f31:	mov    $0x185,%edx
    2f36:	mov    0x4f0(%rsp),%rsi
    2f3e:	mov    0x458(%rsp),%rdi
    2f46:	call   2f4b <botlish_fn_19+0x1bc3>
			2f47: R_X86_64_PLT32	rt_int_cmp-0x4
    2f4b:	mov    $0x2,%ecx
    2f50:	test   %rax,%rax
    2f53:	cmovl  0x787d(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2f5b:	jmp    2f7c <botlish_fn_19+0x1bf4>
    2f60:	mov    $0x2,%ecx
    2f65:	mov    0x4f0(%rsp),%rsi
    2f6d:	cmp    $0x185,%rsi
    2f74:	cmovl  0x785c(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2f7c:	cmp    $0x6,%rcx
    2f80:	je     2f93 <botlish_fn_19+0x1c0b>
    2f86:	mov    0x530(%rsp),%rcx
    2f8e:	jmp    2f98 <botlish_fn_19+0x1c10>
    2f93:	mov    $0x15,%ecx
    2f98:	mov    %rcx,%rsi
    2f9b:	sar    $1,%rsi
    2f9e:	mov    $0x8,%ebx
    2fa3:	cmp    $0x8,%rsi
    2fa7:	jl     30dc <botlish_fn_19+0x1d54>
    2fad:	cmp    $0x8,%rsi
    2fb1:	mov    %rsi,%r12
    2fb4:	je     30cf <botlish_fn_19+0x1d47>
    2fba:	mov    0x4f0(%rsp),%rsi
    2fc2:	test   $0x1,%rsi
    2fc9:	jne    3001 <botlish_fn_19+0x1c79>
    2fcf:	mov    0x500(%rsp),%rdx
    2fd7:	mov    0x4f0(%rsp),%rsi
    2fdf:	mov    0x458(%rsp),%rdi
    2fe7:	call   2fec <botlish_fn_19+0x1c64>
			2fe8: R_X86_64_PLT32	rt_int_cmp-0x4
    2fec:	mov    $0x2,%ecx
    2ff1:	test   %rax,%rax
    2ff4:	cmove  0x77dc(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    2ffc:	jmp    301a <botlish_fn_19+0x1c92>
    3001:	mov    $0x2,%ecx
    3006:	mov    0x4f0(%rsp),%rsi
    300e:	cmp    $0xffffffffffffffff,%rsi
    3012:	cmove  0x77be(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    301a:	cmp    $0x6,%rcx
    301e:	je     307f <botlish_fn_19+0x1cf7>
    3024:	mov    %r12,%rsi
    3027:	mov    0x458(%rsp),%rdi
    302f:	call   3034 <botlish_fn_19+0x1cac>
			3030: R_X86_64_PLT32	botlish_fn_7-0x4
    3034:	mov    0x458(%rsp),%rdi
    303c:	mov    0x10(%rdi),%rcx
    3040:	mov    0x1f8(%rcx),%rdx
    3047:	lea    0x358(%rsp),%r9
    304f:	mov    %rax,0x358(%rsp)
    3057:	mov    0x4f0(%rsp),%rsi
    305f:	mov    %rsi,0x360(%rsp)
    3067:	mov    $0x1,%esi
    306c:	mov    $0x2,%r8d
    3072:	mov    %rbx,%rcx
    3075:	call   307a <botlish_fn_19+0x1cf2>
			3076: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    307a:	jmp    3342 <botlish_fn_19+0x1fba>
    307f:	mov    %r12,%rsi
    3082:	mov    0x458(%rsp),%rdi
    308a:	call   308f <botlish_fn_19+0x1d07>
			308b: R_X86_64_PLT32	botlish_fn_7-0x4
    308f:	mov    0x458(%rsp),%rdi
    3097:	mov    0x10(%rdi),%rdx
    309b:	mov    0x1f0(%rdx),%rdx
    30a2:	lea    0x350(%rsp),%r9
    30aa:	mov    %rax,0x350(%rsp)
    30b2:	mov    $0x2,%esi
    30b7:	mov    $0x1,%r8d
    30bd:	mov    0x530(%rsp),%rcx
    30c5:	call   30ca <botlish_fn_19+0x1d42>
			30c6: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    30ca:	jmp    3342 <botlish_fn_19+0x1fba>
    30cf:	mov    0x530(%rsp),%rcx
    30d7:	jmp    3493 <botlish_fn_19+0x210b>
    30dc:	mov    %rcx,0xd8(%rsp)
    30e4:	mov    $0x6,%r13d
    30ea:	movq   $0x6,0xb8(%rsp)
    30f6:	mov    $0x2,%ebx
    30fb:	mov    $0xa,%edx
    3100:	mov    %rdx,%r14
    3103:	mov    %rdx,%r15
    3106:	mov    %rdx,0x478(%rsp)
    310e:	mov    %rdx,0x4d0(%rsp)
    3116:	mov    %rcx,0x4d8(%rsp)
    311e:	jmp    35ec <botlish_fn_19+0x2264>
    3123:	mov    0x4f0(%rsp),%rsi
    312b:	test   $0x1,%rsi
    3132:	jne    3167 <botlish_fn_19+0x1ddf>
    3138:	mov    $0xb9,%edx
    313d:	mov    0x4f0(%rsp),%rsi
    3145:	mov    0x458(%rsp),%rdi
    314d:	call   3152 <botlish_fn_19+0x1dca>
			314e: R_X86_64_PLT32	rt_int_cmp-0x4
    3152:	mov    $0x2,%ecx
    3157:	test   %rax,%rax
    315a:	cmovl  0x7676(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    3162:	jmp    3183 <botlish_fn_19+0x1dfb>
    3167:	mov    $0x2,%ecx
    316c:	mov    0x4f0(%rsp),%rsi
    3174:	cmp    $0xb9,%rsi
    317b:	cmovl  0x7655(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    3183:	cmp    $0x6,%rcx
    3187:	je     320e <botlish_fn_19+0x1e86>
    318d:	mov    0x4f0(%rsp),%rsi
    3195:	test   $0x1,%rsi
    319c:	jne    31d1 <botlish_fn_19+0x1e49>
    31a2:	mov    $0xbb,%edx
    31a7:	mov    0x4f0(%rsp),%rsi
    31af:	mov    0x458(%rsp),%rdi
    31b7:	call   31bc <botlish_fn_19+0x1e34>
			31b8: R_X86_64_PLT32	rt_int_cmp-0x4
    31bc:	mov    $0x2,%ecx
    31c1:	test   %rax,%rax
    31c4:	cmovl  0x760c(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    31cc:	jmp    31ed <botlish_fn_19+0x1e65>
    31d1:	mov    $0x2,%ecx
    31d6:	mov    0x4f0(%rsp),%rsi
    31de:	cmp    $0xbb,%rsi
    31e5:	cmovl  0x75eb(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    31ed:	cmp    $0x6,%rcx
    31f1:	je     3201 <botlish_fn_19+0x1e79>
    31f7:	mov    $0x11,%edx
    31fc:	jmp    3213 <botlish_fn_19+0x1e8b>
    3201:	mov    0x530(%rsp),%rdx
    3209:	jmp    3213 <botlish_fn_19+0x1e8b>
    320e:	mov    $0x11,%edx
    3213:	mov    %rdx,%rsi
    3216:	sar    $1,%rsi
    3219:	cmp    $0x6,%rsi
    321d:	jl     34a8 <botlish_fn_19+0x2120>
    3223:	cmp    $0x6,%rsi
    3227:	mov    %rsi,%r12
    322a:	je     348b <botlish_fn_19+0x2103>
    3230:	mov    0x4f0(%rsp),%rsi
    3238:	test   $0x1,%rsi
    323f:	jne    3277 <botlish_fn_19+0x1eef>
    3245:	mov    0x500(%rsp),%rdx
    324d:	mov    0x4f0(%rsp),%rsi
    3255:	mov    0x458(%rsp),%rdi
    325d:	call   3262 <botlish_fn_19+0x1eda>
			325e: R_X86_64_PLT32	rt_int_cmp-0x4
    3262:	mov    $0x2,%ecx
    3267:	test   %rax,%rax
    326a:	cmove  0x7566(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    3272:	jmp    3290 <botlish_fn_19+0x1f08>
    3277:	mov    $0x2,%ecx
    327c:	mov    0x4f0(%rsp),%rsi
    3284:	cmp    $0xffffffffffffffff,%rsi
    3288:	cmove  0x7548(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    3290:	cmp    $0x6,%rcx
    3294:	je     32f7 <botlish_fn_19+0x1f6f>
    329a:	mov    %r12,%rsi
    329d:	mov    0x458(%rsp),%rdi
    32a5:	call   32aa <botlish_fn_19+0x1f22>
			32a6: R_X86_64_PLT32	botlish_fn_5-0x4
    32aa:	mov    0x458(%rsp),%rdi
    32b2:	mov    0x10(%rdi),%rcx
    32b6:	mov    0x1f8(%rcx),%rdx
    32bd:	lea    0x340(%rsp),%r9
    32c5:	mov    %rax,0x340(%rsp)
    32cd:	mov    0x4f0(%rsp),%rsi
    32d5:	mov    %rsi,0x348(%rsp)
    32dd:	mov    $0x1,%esi
    32e2:	mov    $0x8,%ecx
    32e7:	mov    $0x2,%r8d
    32ed:	call   32f2 <botlish_fn_19+0x1f6a>
			32ee: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    32f2:	jmp    3342 <botlish_fn_19+0x1fba>
    32f7:	mov    %r12,%rsi
    32fa:	mov    0x458(%rsp),%rdi
    3302:	call   3307 <botlish_fn_19+0x1f7f>
			3303: R_X86_64_PLT32	botlish_fn_5-0x4
    3307:	mov    0x458(%rsp),%rdi
    330f:	mov    0x10(%rdi),%rcx
    3313:	mov    0x1f0(%rcx),%rdx
    331a:	lea    0x338(%rsp),%r9
    3322:	mov    %rax,0x338(%rsp)
    332a:	mov    $0x2,%esi
    332f:	mov    $0x1,%r8d
    3335:	mov    0x530(%rsp),%rcx
    333d:	call   3342 <botlish_fn_19+0x1fba>
			333e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3342:	mov    0x458(%rsp),%rdi
    334a:	call   334f <botlish_fn_19+0x1fc7>
			334b: R_X86_64_PLT32	rt_co_failed-0x4
    334f:	mov    %rax,0xc0(%rsp)
    3357:	mov    %rax,%rsi
    335a:	mov    0x458(%rsp),%rdi
    3362:	call   3367 <botlish_fn_19+0x1fdf>
			3363: R_X86_64_PLT32	rt_co_resume0-0x4
    3367:	test   %rax,%rax
    336a:	je     338c <botlish_fn_19+0x2004>
    3370:	mov    0x458(%rsp),%rdi
    3378:	mov    0x10(%rdi),%rax
    337c:	mov    0x48(%rax),%rsi
    3380:	mov    0x1b8(%rax),%rdx
    3387:	call   338c <botlish_fn_19+0x2004>
			3388: R_X86_64_PLT32	rt_raise-0x4
    338c:	mov    0x458(%rsp),%rdi
    3394:	call   3399 <botlish_fn_19+0x2011>
			3395: R_X86_64_PLT32	rt_declared_error-0x4
    3399:	cmp    $0x1,%rax
    339d:	je     341d <botlish_fn_19+0x2095>
    33a3:	mov    0x458(%rsp),%rdi
    33ab:	call   33b0 <botlish_fn_19+0x2028>
			33ac: R_X86_64_PLT32	rt_declared_error-0x4
    33b0:	cmp    $0x2,%rax
    33b4:	jne    a61c <botlish_fn_19+0x9294>
    33ba:	xor    %rsi,%rsi
    33bd:	mov    0x458(%rsp),%rdi
    33c5:	call   33ca <botlish_fn_19+0x2042>
			33c6: R_X86_64_PLT32	rt_declared_payload-0x4
    33ca:	mov    %rax,%r12
    33cd:	mov    0x458(%rsp),%rdi
    33d5:	call   33da <botlish_fn_19+0x2052>
			33d6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    33da:	mov    0x458(%rsp),%rdi
    33e2:	mov    0x10(%rdi),%rdx
    33e6:	mov    0x1c8(%rdx),%rdx
    33ed:	lea    0x100(%rsp),%r9
    33f5:	mov    %r12,%rax
    33f8:	mov    %rax,0x100(%rsp)
    3400:	mov    $0x5,%esi
    3405:	mov    $0x1,%r8d
    340b:	mov    0x530(%rsp),%rcx
    3413:	call   3418 <botlish_fn_19+0x2090>
			3414: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3418:	jmp    a61c <botlish_fn_19+0x9294>
    341d:	xor    %rsi,%rsi
    3420:	mov    0x458(%rsp),%rdi
    3428:	call   342d <botlish_fn_19+0x20a5>
			3429: R_X86_64_PLT32	rt_declared_payload-0x4
    342d:	mov    %rax,%r12
    3430:	mov    0x458(%rsp),%rdi
    3438:	call   343d <botlish_fn_19+0x20b5>
			3439: R_X86_64_PLT32	rt_clear_declared_error-0x4
    343d:	mov    0x458(%rsp),%rdi
    3445:	mov    0x10(%rdi),%rsi
    3449:	mov    0x1c0(%rsi),%rdx
    3450:	lea    0xf0(%rsp),%r9
    3458:	mov    0x4e8(%rsp),%rcx
    3460:	mov    %rcx,0xf0(%rsp)
    3468:	mov    %r12,%rax
    346b:	mov    %rax,0xf8(%rsp)
    3473:	mov    $0x4,%esi
    3478:	mov    $0x2,%r8d
    347e:	mov    %r8,%rcx
    3481:	call   3486 <botlish_fn_19+0x20fe>
			3482: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3486:	jmp    a61c <botlish_fn_19+0x9294>
    348b:	mov    0x530(%rsp),%rcx
    3493:	mov    %rcx,0xc8(%rsp)
    349b:	mov    %rcx,0x478(%rsp)
    34a3:	jmp    351d <botlish_fn_19+0x2195>
    34a8:	mov    %rdx,0xd0(%rsp)
    34b0:	mov    $0x6,%r13d
    34b6:	movq   $0x6,0xb8(%rsp)
    34c2:	mov    $0x1,%ebx
    34c7:	mov    $0xa,%ecx
    34cc:	mov    %rcx,0x4d8(%rsp)
    34d4:	mov    0x4d8(%rsp),%r14
    34dc:	mov    0x4d8(%rsp),%r15
    34e4:	mov    0x4d8(%rsp),%rax
    34ec:	mov    %rax,0x478(%rsp)
    34f4:	mov    %rdx,0x4d0(%rsp)
    34fc:	jmp    35ec <botlish_fn_19+0x2264>
    3501:	mov    $0xfffffffffffffffd,%rsi
    3508:	jmp    355e <botlish_fn_19+0x21d6>
    350d:	mov    %rcx,0xc8(%rsp)
    3515:	mov    %rcx,0x478(%rsp)
    351d:	mov    $0x6,%r13d
    3523:	movq   $0x6,0xb8(%rsp)
    352f:	mov    $0xa,%edx
    3534:	mov    0x530(%rsp),%rbx
    353c:	mov    %rdx,%r14
    353f:	mov    %rdx,%r15
    3542:	mov    %rdx,0x4d0(%rsp)
    354a:	mov    %rdx,0x4d8(%rsp)
    3552:	jmp    35ec <botlish_fn_19+0x2264>
    3557:	mov    $0xfffffffffffffffd,%rsi
    355e:	test   $0x1,%rsi
    3565:	jne    3595 <botlish_fn_19+0x220d>
    356b:	mov    $0xfffffffffffffffd,%rdx
    3572:	mov    0x458(%rsp),%rdi
    357a:	call   357f <botlish_fn_19+0x21f7>
			357b: R_X86_64_PLT32	rt_int_cmp-0x4
    357f:	mov    $0x2,%r13d
    3585:	test   %rax,%rax
    3588:	cmove  0x7248(%rip),%r13        # a7d8 <botlish_fn_19+0x9450>
    3590:	jmp    35a7 <botlish_fn_19+0x221f>
    3595:	mov    $0x2,%r13d
    359b:	cmp    $0xfffffffffffffffd,%rsi
    359f:	cmove  0x7231(%rip),%r13        # a7d8 <botlish_fn_19+0x9450>
    35a7:	mov    %r13,0xb8(%rsp)
    35af:	mov    $0xa,%edx
    35b4:	mov    %rdx,0x4d0(%rsp)
    35bc:	mov    0x500(%rsp),%rbx
    35c4:	mov    0x4d0(%rsp),%r14
    35cc:	mov    0x4d0(%rsp),%r15
    35d4:	mov    0x4d0(%rsp),%rax
    35dc:	mov    %rax,0x478(%rsp)
    35e4:	mov    %rax,0x4d8(%rsp)
    35ec:	mov    0x508(%rsp),%r12
    35f4:	mov    0x18(%r12),%rax
    35f9:	test   %rax,%rax
    35fc:	je     a6ec <botlish_fn_19+0x9364>
    3602:	mov    0x508(%rsp),%r12
    360a:	mov    0x10(%r12),%rax
    360f:	mov    %r13,(%rax)
    3612:	lea    0x1a0(%rsp),%r12
    361a:	mov    %r12,0x4e0(%rsp)
    3622:	mov    0x508(%rsp),%r12
    362a:	mov    0x508(%rsp),%r12
    3632:	mov    0x10(%r12),%rax
    3637:	mov    (%rax),%rax
    363a:	cmp    $0x6,%rax
    363e:	jne    3ca4 <botlish_fn_19+0x291c>
    3644:	movq   $0x1,0x38(%rsp)
    364d:	mov    0x518(%rsp),%rcx
    3655:	mov    0x10(%rcx),%rax
    3659:	mov    (%rax),%rsi
    365c:	mov    %rsi,0x40(%rsp)
    3661:	movq   $0x3,0x48(%rsp)
    366a:	test   $0x1,%rsi
    3671:	je     3696 <botlish_fn_19+0x230e>
    3677:	mov    %rsi,%rcx
    367a:	add    $0x2,%rcx
    367e:	seto   %al
    3681:	test   %al,%al
    3683:	jne    3696 <botlish_fn_19+0x230e>
    3689:	mov    0x518(%rsp),%rax
    3691:	jmp    36b6 <botlish_fn_19+0x232e>
    3696:	mov    0x530(%rsp),%rdx
    369e:	mov    0x458(%rsp),%rdi
    36a6:	call   36ab <botlish_fn_19+0x2323>
			36a7: R_X86_64_PLT32	rt_int_add-0x4
    36ab:	mov    %rax,%rcx
    36ae:	mov    0x518(%rsp),%rax
    36b6:	mov    0x518(%rsp),%rax
    36be:	mov    0x18(%rax),%rax
    36c2:	test   %rax,%rax
    36c5:	je     a70e <botlish_fn_19+0x9386>
    36cb:	mov    0x518(%rsp),%rax
    36d3:	mov    0x10(%rax),%rax
    36d7:	mov    %rcx,(%rax)
    36da:	movq   $0x1,0x38(%rsp)
    36e3:	mov    0x488(%rsp),%rcx
    36eb:	cmp    $0x1,%rcx
    36ef:	je     3719 <botlish_fn_19+0x2391>
    36f5:	mov    $0xa,%esi
    36fa:	cmp    $0xffffffffffffffff,%rcx
    36fe:	jne    3bd4 <botlish_fn_19+0x284c>
    3704:	mov    %rcx,0x488(%rsp)
    370c:	mov    0x520(%rsp),%rcx
    3714:	jmp    3c78 <botlish_fn_19+0x28f0>
    3719:	movq   $0xa,0x40(%rsp)
    3722:	movq   $0x0,0x1a0(%rsp)
    372e:	mov    0x498(%rsp),%rax
    3736:	mov    %rax,0x1a8(%rsp)
    373e:	movq   $0x2,0x1b0(%rsp)
    374a:	movq   $0xa,0x1b8(%rsp)
    3756:	mov    $0x4,%edx
    375b:	mov    0x4e0(%rsp),%rcx
    3763:	mov    0x530(%rsp),%rsi
    376b:	mov    0x458(%rsp),%rdi
    3773:	call   3778 <botlish_fn_19+0x23f0>
			3774: R_X86_64_PLT32	rt_construct-0x4
    3778:	mov    %rax,%rcx
    377b:	mov    %rax,0x498(%rsp)
    3783:	test   %rcx,%rax
    3786:	je     3bb3 <botlish_fn_19+0x282b>
    378c:	mov    0x498(%rsp),%rax
    3794:	mov    %rax,0x90(%rsp)
    379c:	movq   $0x3,0x40(%rsp)
    37a5:	mov    0x4a8(%rsp),%rsi
    37ad:	test   $0x1,%rsi
    37b4:	jne    37c7 <botlish_fn_19+0x243f>
    37ba:	mov    0x4a8(%rsp),%rsi
    37c2:	jmp    37fe <botlish_fn_19+0x2476>
    37c7:	mov    0x4a8(%rsp),%rsi
    37cf:	mov    %rsi,%rcx
    37d2:	add    $0x2,%rcx
    37d6:	seto   %al
    37d9:	test   %al,%al
    37db:	je     37ee <botlish_fn_19+0x2466>
    37e1:	mov    0x4a8(%rsp),%rsi
    37e9:	jmp    37fe <botlish_fn_19+0x2476>
    37ee:	mov    %rcx,%rsi
    37f1:	mov    %rcx,0x4a8(%rsp)
    37f9:	jmp    381e <botlish_fn_19+0x2496>
    37fe:	mov    0x530(%rsp),%rdx
    3806:	mov    0x458(%rsp),%rdi
    380e:	call   3813 <botlish_fn_19+0x248b>
			380f: R_X86_64_PLT32	rt_int_add-0x4
    3813:	mov    %rax,%rsi
    3816:	mov    %rax,0x4a8(%rsp)
    381e:	mov    %rsi,0x88(%rsp)
    3826:	lea    0x1c0(%rsp),%r12
    382e:	mov    0x4b0(%rsp),%rax
    3836:	mov    0x4a8(%rsp),%rsi
    383e:	mov    %rsi,%rcx
    3841:	and    %rax,%rcx
    3844:	test   $0x1,%rcx
    384b:	jne    3883 <botlish_fn_19+0x24fb>
    3851:	mov    0x4b0(%rsp),%rdx
    3859:	mov    0x4a8(%rsp),%rsi
    3861:	mov    0x458(%rsp),%rdi
    3869:	call   386e <botlish_fn_19+0x24e6>
			386a: R_X86_64_PLT32	rt_int_cmp-0x4
    386e:	mov    $0x2,%ecx
    3873:	test   %rax,%rax
    3876:	cmovl  0x6f5a(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    387e:	jmp    38a3 <botlish_fn_19+0x251b>
    3883:	mov    $0x2,%ecx
    3888:	mov    0x4b0(%rsp),%rax
    3890:	mov    0x4a8(%rsp),%rsi
    3898:	cmp    %rax,%rsi
    389b:	cmovl  0x6f35(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    38a3:	cmp    $0x6,%rcx
    38a7:	je     3b4a <botlish_fn_19+0x27c2>
    38ad:	movq   $0x0,0x1c0(%rsp)
    38b9:	mov    0x498(%rsp),%rax
    38c1:	mov    %rax,0x1c8(%rsp)
    38c9:	mov    $0x1,%esi
    38ce:	mov    $0x2,%edx
    38d3:	mov    %r12,%rcx
    38d6:	mov    0x458(%rsp),%rdi
    38de:	call   38e3 <botlish_fn_19+0x255b>
			38df: R_X86_64_PLT32	rt_construct-0x4
    38e3:	test   %rax,%rax
    38e6:	je     3bb3 <botlish_fn_19+0x282b>
    38ec:	movq   $0x3,0x40(%rsp)
    38f5:	mov    0x4c0(%rsp),%rsi
    38fd:	test   $0x1,%rsi
    3904:	jne    3917 <botlish_fn_19+0x258f>
    390a:	mov    0x4c0(%rsp),%rsi
    3912:	jmp    394e <botlish_fn_19+0x25c6>
    3917:	mov    0x4c0(%rsp),%rsi
    391f:	mov    %rsi,%rax
    3922:	add    $0x2,%rax
    3926:	seto   %cl
    3929:	test   %cl,%cl
    392b:	je     393e <botlish_fn_19+0x25b6>
    3931:	mov    0x4c0(%rsp),%rsi
    3939:	jmp    394e <botlish_fn_19+0x25c6>
    393e:	mov    %rax,%rsi
    3941:	mov    %rax,0x4c0(%rsp)
    3949:	jmp    396e <botlish_fn_19+0x25e6>
    394e:	mov    0x530(%rsp),%rdx
    3956:	mov    0x458(%rsp),%rdi
    395e:	call   3963 <botlish_fn_19+0x25db>
			395f: R_X86_64_PLT32	rt_int_add-0x4
    3963:	mov    %rax,%rsi
    3966:	mov    %rax,0x4c0(%rsp)
    396e:	mov    %rsi,0x70(%rsp)
    3973:	mov    0x4c0(%rsp),%rax
    397b:	mov    0x538(%rsp),%rsi
    3983:	and    %rsi,%rax
    3986:	test   $0x1,%rax
    398c:	jne    39c4 <botlish_fn_19+0x263c>
    3992:	mov    0x538(%rsp),%rdx
    399a:	mov    0x4c0(%rsp),%rsi
    39a2:	mov    0x458(%rsp),%rdi
    39aa:	call   39af <botlish_fn_19+0x2627>
			39ab: R_X86_64_PLT32	rt_int_cmp-0x4
    39af:	mov    $0x2,%ecx
    39b4:	test   %rax,%rax
    39b7:	cmovl  0x6e19(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    39bf:	jmp    39e4 <botlish_fn_19+0x265c>
    39c4:	mov    $0x2,%ecx
    39c9:	mov    0x4c0(%rsp),%rax
    39d1:	mov    0x538(%rsp),%rsi
    39d9:	cmp    %rsi,%rax
    39dc:	cmovl  0x6df4(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    39e4:	cmp    $0x6,%rcx
    39e8:	je     3a35 <botlish_fn_19+0x26ad>
    39ee:	movq   $0xffffffffffffffff,0x50(%rsp)
    39f7:	mov    $0xa,%eax
    39fc:	mov    %rax,0x498(%rsp)
    3a04:	movq   $0xa,0x90(%rsp)
    3a10:	mov    0x520(%rsp),%rcx
    3a18:	mov    0x500(%rsp),%rax
    3a20:	mov    %rax,0x488(%rsp)
    3a28:	mov    %rax,0x4a0(%rsp)
    3a30:	jmp    3c78 <botlish_fn_19+0x28f0>
    3a35:	mov    0x4c0(%rsp),%rsi
    3a3d:	test   $0x1,%rsi
    3a44:	je     3a6d <botlish_fn_19+0x26e5>
    3a4a:	mov    0x460(%rsp),%rcx
    3a52:	mov    0x8(%rcx),%r10
    3a56:	mov    0x4c0(%rsp),%rsi
    3a5e:	mov    %rsi,%r9
    3a61:	sar    $1,%r9
    3a64:	cmp    %r10,%r9
    3a67:	jb     3aab <botlish_fn_19+0x2723>
    3a6d:	mov    0x4c0(%rsp),%rdx
    3a75:	mov    0x460(%rsp),%rsi
    3a7d:	mov    0x458(%rsp),%rdi
    3a85:	call   3a8a <botlish_fn_19+0x2702>
			3a86: R_X86_64_PLT32	rt_list_get-0x4
    3a8a:	mov    %rax,%rcx
    3a8d:	mov    %rax,0x4b8(%rsp)
    3a95:	test   %rcx,%rax
    3a98:	je     3bb3 <botlish_fn_19+0x282b>
    3a9e:	mov    0x4b8(%rsp),%rax
    3aa6:	jmp    3ac3 <botlish_fn_19+0x273b>
    3aab:	mov    0x460(%rsp),%rcx
    3ab3:	mov    0x10(%rcx),%rax
    3ab7:	mov    (%rax,%r9,8),%rax
    3abb:	mov    %rax,0x4b8(%rsp)
    3ac3:	mov    %rax,0x78(%rsp)
    3ac8:	mov    0x4b8(%rsp),%rsi
    3ad0:	mov    0x458(%rsp),%rdi
    3ad8:	call   3add <botlish_fn_19+0x2755>
			3ad9: R_X86_64_PLT32	rt_list_len-0x4
    3add:	mov    %rax,0x4b0(%rsp)
    3ae5:	mov    %rax,0x80(%rsp)
    3aed:	movq   $0x1,0x88(%rsp)
    3af9:	xor    %rdx,%rdx
    3afc:	mov    0x458(%rsp),%rdi
    3b04:	mov    %rdx,%rsi
    3b07:	call   3b0c <botlish_fn_19+0x2784>
			3b08: R_X86_64_PLT32	rt_list_new-0x4
    3b0c:	mov    %rax,%rcx
    3b0f:	mov    %rax,0x498(%rsp)
    3b17:	test   %rcx,%rax
    3b1a:	je     3bb3 <botlish_fn_19+0x282b>
    3b20:	mov    0x498(%rsp),%rax
    3b28:	mov    %rax,0x90(%rsp)
    3b30:	mov    $0x1,%esi
    3b35:	mov    %rsi,0x4a8(%rsp)
    3b3d:	mov    0x4b0(%rsp),%rax
    3b45:	jmp    383e <botlish_fn_19+0x24b6>
    3b4a:	mov    0x4a8(%rsp),%rsi
    3b52:	test   $0x1,%rsi
    3b59:	je     3b82 <botlish_fn_19+0x27fa>
    3b5f:	mov    0x4b8(%rsp),%rax
    3b67:	mov    0x8(%rax),%rcx
    3b6b:	mov    0x4a8(%rsp),%rsi
    3b73:	mov    %rsi,%rax
    3b76:	sar    $1,%rax
    3b79:	cmp    %rcx,%rax
    3b7c:	jb     3c46 <botlish_fn_19+0x28be>
    3b82:	mov    0x4a8(%rsp),%rdx
    3b8a:	mov    0x4b8(%rsp),%rsi
    3b92:	mov    0x458(%rsp),%rdi
    3b9a:	call   3b9f <botlish_fn_19+0x2817>
			3b9b: R_X86_64_PLT32	rt_list_get-0x4
    3b9f:	mov    %rax,%rcx
    3ba2:	mov    %rax,0x4a0(%rsp)
    3baa:	test   %rcx,%rax
    3bad:	jne    3c39 <botlish_fn_19+0x28b1>
    3bb3:	mov    0x458(%rsp),%rdi
    3bbb:	call   3bc0 <botlish_fn_19+0x2838>
			3bbc: R_X86_64_PLT32	rt_co_failed-0x4
    3bc0:	mov    %rax,0x58(%rsp)
    3bc5:	movq   $0xa,0x90(%rsp)
    3bd1:	mov    %rax,%rsi
    3bd4:	mov    0x458(%rsp),%rdi
    3bdc:	call   3be1 <botlish_fn_19+0x2859>
			3bdd: R_X86_64_PLT32	rt_co_resume0-0x4
    3be1:	test   %rax,%rax
    3be4:	jne    3bf7 <botlish_fn_19+0x286f>
    3bea:	mov    0x458(%rsp),%rdi
    3bf2:	jmp    3c1b <botlish_fn_19+0x2893>
    3bf7:	mov    0x458(%rsp),%rdi
    3bff:	mov    0x10(%rdi),%rax
    3c03:	mov    0x48(%rax),%rsi
    3c07:	mov    0x1b8(%rax),%rdx
    3c0e:	call   3c13 <botlish_fn_19+0x288b>
			3c0f: R_X86_64_PLT32	rt_raise-0x4
    3c13:	mov    0x458(%rsp),%rdi
    3c1b:	mov    0x458(%rsp),%rdi
    3c23:	call   3c28 <botlish_fn_19+0x28a0>
			3c24: R_X86_64_PLT32	rt_declared_error-0x4
    3c28:	cmp    $0x40000001,%rax
    3c2e:	jne    a61c <botlish_fn_19+0x9294>
    3c34:	jmp    a61c <botlish_fn_19+0x9294>
    3c39:	mov    0x4a0(%rsp),%rax
    3c41:	jmp    3c5e <botlish_fn_19+0x28d6>
    3c46:	mov    0x4b8(%rsp),%rcx
    3c4e:	mov    0x10(%rcx),%rcx
    3c52:	mov    (%rcx,%rax,8),%rax
    3c56:	mov    %rax,0x4a0(%rsp)
    3c5e:	mov    %rax,0x50(%rsp)
    3c63:	mov    $0x1,%ecx
    3c68:	mov    %rcx,0x488(%rsp)
    3c70:	mov    0x520(%rsp),%rcx
    3c78:	mov    0x520(%rsp),%rcx
    3c80:	mov    0x18(%rcx),%rax
    3c84:	test   %rax,%rax
    3c87:	je     a72d <botlish_fn_19+0x93a5>
    3c8d:	mov    0x520(%rsp),%rcx
    3c95:	mov    0x10(%rcx),%rax
    3c99:	mov    0x4a0(%rsp),%rcx
    3ca1:	mov    %rcx,(%rax)
    3ca4:	test   %rbx,%rbx
    3ca7:	jl     8f23 <botlish_fn_19+0x7b9b>
    3cad:	mov    0x518(%rsp),%rcx
    3cb5:	mov    0x10(%rcx),%rax
    3cb9:	mov    (%rax),%rsi
    3cbc:	mov    %rsi,0x38(%rsp)
    3cc1:	mov    0x4e8(%rsp),%rcx
    3cc9:	mov    %rsi,%rax
    3ccc:	and    %rcx,%rax
    3ccf:	test   $0x1,%rax
    3cd5:	je     3d10 <botlish_fn_19+0x2988>
    3cdb:	mov    0x4e8(%rsp),%rcx
    3ce3:	mov    %rsi,%rax
    3ce6:	sub    %rcx,%rax
    3ce9:	mov    %rsi,%rcx
    3cec:	seto   %dl
    3cef:	lea    0x1(%rax),%rsi
    3cf3:	test   %dl,%dl
    3cf5:	je     3d03 <botlish_fn_19+0x297b>
    3cfb:	mov    %rcx,%rsi
    3cfe:	jmp    3d10 <botlish_fn_19+0x2988>
    3d03:	mov    0x470(%rsp),%r12
    3d0b:	jmp    3d30 <botlish_fn_19+0x29a8>
    3d10:	mov    0x4e8(%rsp),%rdx
    3d18:	mov    0x458(%rsp),%rdi
    3d20:	call   3d25 <botlish_fn_19+0x299d>
			3d21: R_X86_64_PLT32	rt_int_sub-0x4
    3d25:	mov    %rax,%rsi
    3d28:	mov    0x470(%rsp),%r12
    3d30:	mov    %rsi,%rdi
    3d33:	and    %r12,%rdi
    3d36:	test   $0x1,%rdi
    3d3d:	jne    3d70 <botlish_fn_19+0x29e8>
    3d43:	mov    %r12,%rdx
    3d46:	mov    0x458(%rsp),%rdi
    3d4e:	call   3d53 <botlish_fn_19+0x29cb>
			3d4f: R_X86_64_PLT32	rt_int_cmp-0x4
    3d53:	mov    %r12,0x470(%rsp)
    3d5b:	mov    $0x2,%ecx
    3d60:	test   %rax,%rax
    3d63:	cmovge 0x6a6d(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    3d6b:	jmp    3d90 <botlish_fn_19+0x2a08>
    3d70:	mov    %r12,0x470(%rsp)
    3d78:	mov    $0x2,%ecx
    3d7d:	mov    0x470(%rsp),%rax
    3d85:	cmp    %rax,%rsi
    3d88:	cmovge 0x6a48(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    3d90:	cmp    $0x6,%rcx
    3d94:	je     8ece <botlish_fn_19+0x7b46>
    3d9a:	mov    0x520(%rsp),%rcx
    3da2:	mov    0x10(%rcx),%rax
    3da6:	mov    (%rax),%rsi
    3da9:	cmp    $0x1,%rbx
    3dad:	je     7d81 <botlish_fn_19+0x69f9>
    3db3:	cmp    $0x2,%rbx
    3db7:	je     71d9 <botlish_fn_19+0x5e51>
    3dbd:	cmp    $0x3,%rbx
    3dc1:	je     6bc5 <botlish_fn_19+0x583d>
    3dc7:	cmp    $0x4,%rbx
    3dcb:	je     4f3d <botlish_fn_19+0x3bb5>
    3dd1:	cmp    $0x5,%rbx
    3dd5:	je     3df7 <botlish_fn_19+0x2a6f>
    3ddb:	mov    $0xa,%esi
    3de0:	cmp    $0xffffffffffffffff,%rbx
    3de4:	jne    8d07 <botlish_fn_19+0x797f>
    3dea:	mov    0x478(%rsp),%r12
    3df2:	jmp    8e95 <botlish_fn_19+0x7b0d>
    3df7:	mov    %r15,%rbx
    3dfa:	sar    $1,%r15
    3dfd:	cmp    $0x6,%r15
    3e01:	jl     46ab <botlish_fn_19+0x3323>
    3e07:	cmp    $0x9,%r15
    3e0b:	jl     43b0 <botlish_fn_19+0x3028>
    3e11:	cmp    $0xa,%r15
    3e15:	jl     42bb <botlish_fn_19+0x2f33>
    3e1b:	cmp    $0xb,%r15
    3e1f:	jl     3f19 <botlish_fn_19+0x2b91>
    3e25:	test   $0x1,%rsi
    3e2c:	mov    %rsi,0x480(%rsp)
    3e34:	jne    3e69 <botlish_fn_19+0x2ae1>
    3e3a:	mov    $0xcb,%edx
    3e3f:	mov    0x480(%rsp),%rsi
    3e47:	mov    0x458(%rsp),%rdi
    3e4f:	call   3e54 <botlish_fn_19+0x2acc>
			3e50: R_X86_64_PLT32	rt_int_cmp-0x4
    3e54:	mov    $0x2,%esi
    3e59:	test   %rax,%rax
    3e5c:	cmovl  0x6974(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    3e64:	jmp    3e84 <botlish_fn_19+0x2afc>
    3e69:	mov    $0x2,%esi
    3e6e:	mov    0x480(%rsp),%rax
    3e76:	cmp    $0xcb,%rax
    3e7c:	cmovl  0x6954(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    3e84:	cmp    $0x6,%rsi
    3e88:	je     3f0e <botlish_fn_19+0x2b86>
    3e8e:	mov    0x480(%rsp),%rsi
    3e96:	test   $0x1,%rsi
    3e9d:	jne    3ed2 <botlish_fn_19+0x2b4a>
    3ea3:	mov    $0xcd,%edx
    3ea8:	mov    0x480(%rsp),%rsi
    3eb0:	mov    0x458(%rsp),%rdi
    3eb8:	call   3ebd <botlish_fn_19+0x2b35>
			3eb9: R_X86_64_PLT32	rt_int_cmp-0x4
    3ebd:	mov    $0x2,%ecx
    3ec2:	test   %rax,%rax
    3ec5:	cmovl  0x690b(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    3ecd:	jmp    3eee <botlish_fn_19+0x2b66>
    3ed2:	mov    $0x2,%ecx
    3ed7:	mov    0x480(%rsp),%rsi
    3edf:	cmp    $0xcd,%rsi
    3ee6:	cmovl  0x68ea(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    3eee:	cmp    $0x6,%rcx
    3ef2:	je     3f03 <botlish_fn_19+0x2b7b>
    3ef8:	mov    $0x33,%r15d
    3efe:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    3f03:	mov    $0x15,%r15d
    3f09:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    3f0e:	mov    $0x33,%r15d
    3f14:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    3f19:	mov    %rsi,0x480(%rsp)
    3f21:	test   $0x1,%rsi
    3f28:	jne    3f5d <botlish_fn_19+0x2bd5>
    3f2e:	mov    $0x41,%edx
    3f33:	mov    0x480(%rsp),%rsi
    3f3b:	mov    0x458(%rsp),%rdi
    3f43:	call   3f48 <botlish_fn_19+0x2bc0>
			3f44: R_X86_64_PLT32	rt_int_cmp-0x4
    3f48:	mov    $0x2,%ecx
    3f4d:	test   %rax,%rax
    3f50:	cmovl  0x6880(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    3f58:	jmp    3f76 <botlish_fn_19+0x2bee>
    3f5d:	mov    $0x2,%ecx
    3f62:	mov    0x480(%rsp),%rsi
    3f6a:	cmp    $0x41,%rsi
    3f6e:	cmovl  0x6862(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    3f76:	cmp    $0x6,%rcx
    3f7a:	je     415a <botlish_fn_19+0x2dd2>
    3f80:	mov    0x480(%rsp),%rsi
    3f88:	test   $0x1,%rsi
    3f8f:	jne    3fc4 <botlish_fn_19+0x2c3c>
    3f95:	mov    $0xbb,%edx
    3f9a:	mov    0x480(%rsp),%rsi
    3fa2:	mov    0x458(%rsp),%rdi
    3faa:	call   3faf <botlish_fn_19+0x2c27>
			3fab: R_X86_64_PLT32	rt_int_cmp-0x4
    3faf:	mov    $0x2,%ecx
    3fb4:	test   %rax,%rax
    3fb7:	cmovl  0x6819(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    3fbf:	jmp    3fe0 <botlish_fn_19+0x2c58>
    3fc4:	mov    $0x2,%ecx
    3fc9:	mov    0x480(%rsp),%rsi
    3fd1:	cmp    $0xbb,%rsi
    3fd8:	cmovl  0x67f8(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    3fe0:	cmp    $0x6,%rcx
    3fe4:	je     4102 <botlish_fn_19+0x2d7a>
    3fea:	mov    0x480(%rsp),%rsi
    3ff2:	test   $0x1,%rsi
    3ff9:	jne    402e <botlish_fn_19+0x2ca6>
    3fff:	mov    $0xfb,%edx
    4004:	mov    0x480(%rsp),%rsi
    400c:	mov    0x458(%rsp),%rdi
    4014:	call   4019 <botlish_fn_19+0x2c91>
			4015: R_X86_64_PLT32	rt_int_cmp-0x4
    4019:	mov    $0x2,%ecx
    401e:	test   %rax,%rax
    4021:	cmovl  0x67af(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4029:	jmp    404a <botlish_fn_19+0x2cc2>
    402e:	mov    $0x2,%ecx
    4033:	mov    0x480(%rsp),%rsi
    403b:	cmp    $0xfb,%rsi
    4042:	cmovl  0x678e(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    404a:	cmp    $0x6,%rcx
    404e:	je     40d4 <botlish_fn_19+0x2d4c>
    4054:	mov    0x480(%rsp),%rsi
    405c:	test   $0x1,%rsi
    4063:	jne    4098 <botlish_fn_19+0x2d10>
    4069:	mov    $0xfd,%edx
    406e:	mov    0x480(%rsp),%rsi
    4076:	mov    0x458(%rsp),%rdi
    407e:	call   4083 <botlish_fn_19+0x2cfb>
			407f: R_X86_64_PLT32	rt_int_cmp-0x4
    4083:	mov    $0x2,%ecx
    4088:	test   %rax,%rax
    408b:	cmovl  0x6745(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4093:	jmp    40b4 <botlish_fn_19+0x2d2c>
    4098:	mov    $0x2,%ecx
    409d:	mov    0x480(%rsp),%rsi
    40a5:	cmp    $0xfd,%rsi
    40ac:	cmovl  0x6724(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    40b4:	cmp    $0x6,%rcx
    40b8:	je     40c9 <botlish_fn_19+0x2d41>
    40be:	mov    $0x31,%r15d
    40c4:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    40c9:	mov    $0x1b,%r15d
    40cf:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    40d4:	mov    0x480(%rsp),%rsi
    40dc:	mov    %rsi,%rax
    40df:	sar    $1,%rax
    40e2:	cmp    $0x5e,%rax
    40e6:	jl     40f7 <botlish_fn_19+0x2d6f>
    40ec:	mov    $0x31,%r15d
    40f2:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    40f7:	mov    $0x1b,%r15d
    40fd:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4102:	mov    0x480(%rsp),%rsi
    410a:	mov    %rsi,%rax
    410d:	sar    $1,%rax
    4110:	cmp    $0x2c,%rax
    4114:	jl     413a <botlish_fn_19+0x2db2>
    411a:	cmp    $0x2d,%rax
    411e:	jl     412f <botlish_fn_19+0x2da7>
    4124:	mov    $0x31,%r15d
    412a:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    412f:	mov    $0x1b,%r15d
    4135:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    413a:	cmp    $0x21,%rax
    413e:	jl     414f <botlish_fn_19+0x2dc7>
    4144:	mov    $0x31,%r15d
    414a:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    414f:	mov    $0x1b,%r15d
    4155:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    415a:	mov    0x480(%rsp),%rsi
    4162:	test   $0x1,%rsi
    4169:	jne    419e <botlish_fn_19+0x2e16>
    416f:	mov    $0x13,%edx
    4174:	mov    0x480(%rsp),%rsi
    417c:	mov    0x458(%rsp),%rdi
    4184:	call   4189 <botlish_fn_19+0x2e01>
			4185: R_X86_64_PLT32	rt_int_cmp-0x4
    4189:	mov    $0x2,%ecx
    418e:	test   %rax,%rax
    4191:	cmovl  0x663f(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4199:	jmp    41b7 <botlish_fn_19+0x2e2f>
    419e:	mov    $0x2,%ecx
    41a3:	mov    0x480(%rsp),%rsi
    41ab:	cmp    $0x13,%rsi
    41af:	cmovl  0x6621(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    41b7:	cmp    $0x6,%rcx
    41bb:	je     4219 <botlish_fn_19+0x2e91>
    41c1:	mov    0x480(%rsp),%rsi
    41c9:	mov    %rsi,%rax
    41cc:	sar    $1,%rax
    41cf:	cmp    $0xd,%rax
    41d3:	jl     41f9 <botlish_fn_19+0x2e71>
    41d9:	cmp    $0xe,%rax
    41dd:	jl     41ee <botlish_fn_19+0x2e66>
    41e3:	mov    $0x31,%r15d
    41e9:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    41ee:	mov    $0x1b,%r15d
    41f4:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    41f9:	cmp    $0xb,%rax
    41fd:	jl     420e <botlish_fn_19+0x2e86>
    4203:	mov    $0x31,%r15d
    4209:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    420e:	mov    $0x1b,%r15d
    4214:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4219:	mov    0x480(%rsp),%rsi
    4221:	test   $0x1,%rsi
    4228:	jne    4260 <botlish_fn_19+0x2ed8>
    422e:	mov    0x500(%rsp),%rdx
    4236:	mov    0x480(%rsp),%rsi
    423e:	mov    0x458(%rsp),%rdi
    4246:	call   424b <botlish_fn_19+0x2ec3>
			4247: R_X86_64_PLT32	rt_int_cmp-0x4
    424b:	mov    $0x2,%ecx
    4250:	test   %rax,%rax
    4253:	cmovl  0x657d(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    425b:	jmp    4279 <botlish_fn_19+0x2ef1>
    4260:	mov    $0x2,%ecx
    4265:	mov    0x480(%rsp),%rsi
    426d:	cmp    $0xffffffffffffffff,%rsi
    4271:	cmovl  0x655f(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4279:	cmp    $0x6,%rcx
    427d:	je     42b0 <botlish_fn_19+0x2f28>
    4283:	mov    0x480(%rsp),%rsi
    428b:	mov    %rsi,%rax
    428e:	sar    $1,%rax
    4291:	test   %rax,%rax
    4294:	jl     42a5 <botlish_fn_19+0x2f1d>
    429a:	mov    $0x31,%r15d
    42a0:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    42a5:	mov    $0x1b,%r15d
    42ab:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    42b0:	mov    $0x31,%r15d
    42b6:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    42bb:	mov    %rsi,0x480(%rsp)
    42c3:	test   $0x1,%rsi
    42ca:	jne    42ff <botlish_fn_19+0x2f77>
    42d0:	mov    $0xd9,%edx
    42d5:	mov    0x480(%rsp),%rsi
    42dd:	mov    0x458(%rsp),%rdi
    42e5:	call   42ea <botlish_fn_19+0x2f62>
			42e6: R_X86_64_PLT32	rt_int_cmp-0x4
    42ea:	mov    $0x2,%ecx
    42ef:	test   %rax,%rax
    42f2:	cmovl  0x64de(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    42fa:	jmp    431b <botlish_fn_19+0x2f93>
    42ff:	mov    $0x2,%ecx
    4304:	mov    0x480(%rsp),%rsi
    430c:	cmp    $0xd9,%rsi
    4313:	cmovl  0x64bd(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    431b:	cmp    $0x6,%rcx
    431f:	je     43a5 <botlish_fn_19+0x301d>
    4325:	mov    0x480(%rsp),%rsi
    432d:	test   $0x1,%rsi
    4334:	jne    4369 <botlish_fn_19+0x2fe1>
    433a:	mov    $0xdb,%edx
    433f:	mov    0x480(%rsp),%rsi
    4347:	mov    0x458(%rsp),%rdi
    434f:	call   4354 <botlish_fn_19+0x2fcc>
			4350: R_X86_64_PLT32	rt_int_cmp-0x4
    4354:	mov    $0x2,%ecx
    4359:	test   %rax,%rax
    435c:	cmovl  0x6474(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4364:	jmp    4385 <botlish_fn_19+0x2ffd>
    4369:	mov    $0x2,%ecx
    436e:	mov    0x480(%rsp),%rsi
    4376:	cmp    $0xdb,%rsi
    437d:	cmovl  0x6453(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4385:	cmp    $0x6,%rcx
    4389:	je     439a <botlish_fn_19+0x3012>
    438f:	mov    $0x2f,%r15d
    4395:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    439a:	mov    $0x15,%r15d
    43a0:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    43a5:	mov    $0x2f,%r15d
    43ab:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    43b0:	mov    %rsi,0x480(%rsp)
    43b8:	cmp    $0x7,%r15
    43bc:	jl     45b6 <botlish_fn_19+0x322e>
    43c2:	cmp    $0x8,%r15
    43c6:	jl     44c1 <botlish_fn_19+0x3139>
    43cc:	mov    0x480(%rsp),%rsi
    43d4:	test   $0x1,%rsi
    43db:	jne    4410 <botlish_fn_19+0x3088>
    43e1:	mov    $0xe7,%edx
    43e6:	mov    0x480(%rsp),%rsi
    43ee:	mov    0x458(%rsp),%rdi
    43f6:	call   43fb <botlish_fn_19+0x3073>
			43f7: R_X86_64_PLT32	rt_int_cmp-0x4
    43fb:	mov    $0x2,%ecx
    4400:	test   %rax,%rax
    4403:	cmovl  0x63cd(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    440b:	jmp    442c <botlish_fn_19+0x30a4>
    4410:	mov    $0x2,%ecx
    4415:	mov    0x480(%rsp),%rsi
    441d:	cmp    $0xe7,%rsi
    4424:	cmovl  0x63ac(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    442c:	cmp    $0x6,%rcx
    4430:	je     44b6 <botlish_fn_19+0x312e>
    4436:	mov    0x480(%rsp),%rsi
    443e:	test   $0x1,%rsi
    4445:	jne    447a <botlish_fn_19+0x30f2>
    444b:	mov    $0xe9,%edx
    4450:	mov    0x480(%rsp),%rsi
    4458:	mov    0x458(%rsp),%rdi
    4460:	call   4465 <botlish_fn_19+0x30dd>
			4461: R_X86_64_PLT32	rt_int_cmp-0x4
    4465:	mov    $0x2,%ecx
    446a:	test   %rax,%rax
    446d:	cmovl  0x6363(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4475:	jmp    4496 <botlish_fn_19+0x310e>
    447a:	mov    $0x2,%ecx
    447f:	mov    0x480(%rsp),%rsi
    4487:	cmp    $0xe9,%rsi
    448e:	cmovl  0x6342(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4496:	cmp    $0x6,%rcx
    449a:	je     44ab <botlish_fn_19+0x3123>
    44a0:	mov    $0x2d,%r15d
    44a6:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    44ab:	mov    $0x17,%r15d
    44b1:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    44b6:	mov    $0x2d,%r15d
    44bc:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    44c1:	mov    0x480(%rsp),%rsi
    44c9:	test   $0x1,%rsi
    44d0:	jne    4505 <botlish_fn_19+0x317d>
    44d6:	mov    $0xcb,%edx
    44db:	mov    0x480(%rsp),%rsi
    44e3:	mov    0x458(%rsp),%rdi
    44eb:	call   44f0 <botlish_fn_19+0x3168>
			44ec: R_X86_64_PLT32	rt_int_cmp-0x4
    44f0:	mov    $0x2,%ecx
    44f5:	test   %rax,%rax
    44f8:	cmovl  0x62d8(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4500:	jmp    4521 <botlish_fn_19+0x3199>
    4505:	mov    $0x2,%ecx
    450a:	mov    0x480(%rsp),%rsi
    4512:	cmp    $0xcb,%rsi
    4519:	cmovl  0x62b7(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4521:	cmp    $0x6,%rcx
    4525:	je     45ab <botlish_fn_19+0x3223>
    452b:	mov    0x480(%rsp),%rsi
    4533:	test   $0x1,%rsi
    453a:	jne    456f <botlish_fn_19+0x31e7>
    4540:	mov    $0xcd,%edx
    4545:	mov    0x480(%rsp),%rsi
    454d:	mov    0x458(%rsp),%rdi
    4555:	call   455a <botlish_fn_19+0x31d2>
			4556: R_X86_64_PLT32	rt_int_cmp-0x4
    455a:	mov    $0x2,%ecx
    455f:	test   %rax,%rax
    4562:	cmovl  0x626e(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    456a:	jmp    458b <botlish_fn_19+0x3203>
    456f:	mov    $0x2,%ecx
    4574:	mov    0x480(%rsp),%rsi
    457c:	cmp    $0xcd,%rsi
    4583:	cmovl  0x624d(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    458b:	cmp    $0x6,%rcx
    458f:	je     45a0 <botlish_fn_19+0x3218>
    4595:	mov    $0x2b,%r15d
    459b:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    45a0:	mov    $0x15,%r15d
    45a6:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    45ab:	mov    $0x2b,%r15d
    45b1:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    45b6:	mov    0x480(%rsp),%rsi
    45be:	test   $0x1,%rsi
    45c5:	jne    45fa <botlish_fn_19+0x3272>
    45cb:	mov    $0xd9,%edx
    45d0:	mov    0x480(%rsp),%rsi
    45d8:	mov    0x458(%rsp),%rdi
    45e0:	call   45e5 <botlish_fn_19+0x325d>
			45e1: R_X86_64_PLT32	rt_int_cmp-0x4
    45e5:	mov    $0x2,%ecx
    45ea:	test   %rax,%rax
    45ed:	cmovl  0x61e3(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    45f5:	jmp    4616 <botlish_fn_19+0x328e>
    45fa:	mov    $0x2,%ecx
    45ff:	mov    0x480(%rsp),%rsi
    4607:	cmp    $0xd9,%rsi
    460e:	cmovl  0x61c2(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4616:	cmp    $0x6,%rcx
    461a:	je     46a0 <botlish_fn_19+0x3318>
    4620:	mov    0x480(%rsp),%rsi
    4628:	test   $0x1,%rsi
    462f:	jne    4664 <botlish_fn_19+0x32dc>
    4635:	mov    $0xdb,%edx
    463a:	mov    0x480(%rsp),%rsi
    4642:	mov    0x458(%rsp),%rdi
    464a:	call   464f <botlish_fn_19+0x32c7>
			464b: R_X86_64_PLT32	rt_int_cmp-0x4
    464f:	mov    $0x2,%ecx
    4654:	test   %rax,%rax
    4657:	cmovl  0x6179(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    465f:	jmp    4680 <botlish_fn_19+0x32f8>
    4664:	mov    $0x2,%ecx
    4669:	mov    0x480(%rsp),%rsi
    4671:	cmp    $0xdb,%rsi
    4678:	cmovl  0x6158(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4680:	cmp    $0x6,%rcx
    4684:	je     4695 <botlish_fn_19+0x330d>
    468a:	mov    $0x29,%r15d
    4690:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4695:	mov    $0x13,%r15d
    469b:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    46a0:	mov    $0x29,%r15d
    46a6:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    46ab:	mov    %rsi,0x480(%rsp)
    46b3:	cmp    $0x3,%r15
    46b7:	jl     49af <botlish_fn_19+0x3627>
    46bd:	cmp    $0x4,%r15
    46c1:	jl     48ba <botlish_fn_19+0x3532>
    46c7:	cmp    $0x5,%r15
    46cb:	jl     47c5 <botlish_fn_19+0x343d>
    46d1:	mov    0x480(%rsp),%rsi
    46d9:	test   $0x1,%rsi
    46e0:	jne    4715 <botlish_fn_19+0x338d>
    46e6:	mov    $0xd9,%edx
    46eb:	mov    0x480(%rsp),%rsi
    46f3:	mov    0x458(%rsp),%rdi
    46fb:	call   4700 <botlish_fn_19+0x3378>
			46fc: R_X86_64_PLT32	rt_int_cmp-0x4
    4700:	mov    $0x2,%ecx
    4705:	test   %rax,%rax
    4708:	cmovl  0x60c8(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4710:	jmp    4731 <botlish_fn_19+0x33a9>
    4715:	mov    $0x2,%ecx
    471a:	mov    0x480(%rsp),%rsi
    4722:	cmp    $0xd9,%rsi
    4729:	cmovl  0x60a7(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4731:	cmp    $0x6,%rcx
    4735:	je     47ba <botlish_fn_19+0x3432>
    473b:	mov    0x480(%rsp),%rsi
    4743:	test   $0x1,%rsi
    474a:	jne    477f <botlish_fn_19+0x33f7>
    4750:	mov    $0xdb,%edx
    4755:	mov    0x480(%rsp),%rsi
    475d:	mov    0x458(%rsp),%rdi
    4765:	call   476a <botlish_fn_19+0x33e2>
			4766: R_X86_64_PLT32	rt_int_cmp-0x4
    476a:	mov    $0x2,%esi
    476f:	test   %rax,%rax
    4772:	cmovl  0x605e(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    477a:	jmp    479a <botlish_fn_19+0x3412>
    477f:	mov    $0x2,%esi
    4784:	mov    0x480(%rsp),%rax
    478c:	cmp    $0xdb,%rax
    4792:	cmovl  0x603e(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    479a:	cmp    $0x6,%rsi
    479e:	je     47af <botlish_fn_19+0x3427>
    47a4:	mov    $0x27,%r15d
    47aa:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    47af:	mov    $0x11,%r15d
    47b5:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    47ba:	mov    $0x27,%r15d
    47c0:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    47c5:	mov    0x480(%rsp),%rsi
    47cd:	test   $0x1,%rsi
    47d4:	jne    4809 <botlish_fn_19+0x3481>
    47da:	mov    $0xeb,%edx
    47df:	mov    0x480(%rsp),%rsi
    47e7:	mov    0x458(%rsp),%rdi
    47ef:	call   47f4 <botlish_fn_19+0x346c>
			47f0: R_X86_64_PLT32	rt_int_cmp-0x4
    47f4:	mov    $0x2,%ecx
    47f9:	test   %rax,%rax
    47fc:	cmovl  0x5fd4(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4804:	jmp    4825 <botlish_fn_19+0x349d>
    4809:	mov    $0x2,%ecx
    480e:	mov    0x480(%rsp),%rsi
    4816:	cmp    $0xeb,%rsi
    481d:	cmovl  0x5fb3(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4825:	cmp    $0x6,%rcx
    4829:	je     48af <botlish_fn_19+0x3527>
    482f:	mov    0x480(%rsp),%rsi
    4837:	test   $0x1,%rsi
    483e:	jne    4873 <botlish_fn_19+0x34eb>
    4844:	mov    $0xed,%edx
    4849:	mov    0x480(%rsp),%rsi
    4851:	mov    0x458(%rsp),%rdi
    4859:	call   485e <botlish_fn_19+0x34d6>
			485a: R_X86_64_PLT32	rt_int_cmp-0x4
    485e:	mov    $0x2,%ecx
    4863:	test   %rax,%rax
    4866:	cmovl  0x5f6a(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    486e:	jmp    488f <botlish_fn_19+0x3507>
    4873:	mov    $0x2,%ecx
    4878:	mov    0x480(%rsp),%rsi
    4880:	cmp    $0xed,%rsi
    4887:	cmovl  0x5f49(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    488f:	cmp    $0x6,%rcx
    4893:	je     48a4 <botlish_fn_19+0x351c>
    4899:	mov    $0x25,%r15d
    489f:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    48a4:	mov    $0xf,%r15d
    48aa:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    48af:	mov    $0x25,%r15d
    48b5:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    48ba:	mov    0x480(%rsp),%rsi
    48c2:	test   $0x1,%rsi
    48c9:	jne    48fe <botlish_fn_19+0x3576>
    48cf:	mov    $0xeb,%edx
    48d4:	mov    0x480(%rsp),%rsi
    48dc:	mov    0x458(%rsp),%rdi
    48e4:	call   48e9 <botlish_fn_19+0x3561>
			48e5: R_X86_64_PLT32	rt_int_cmp-0x4
    48e9:	mov    $0x2,%ecx
    48ee:	test   %rax,%rax
    48f1:	cmovl  0x5edf(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    48f9:	jmp    491a <botlish_fn_19+0x3592>
    48fe:	mov    $0x2,%ecx
    4903:	mov    0x480(%rsp),%rsi
    490b:	cmp    $0xeb,%rsi
    4912:	cmovl  0x5ebe(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    491a:	cmp    $0x6,%rcx
    491e:	je     49a4 <botlish_fn_19+0x361c>
    4924:	mov    0x480(%rsp),%rsi
    492c:	test   $0x1,%rsi
    4933:	jne    4968 <botlish_fn_19+0x35e0>
    4939:	mov    $0xed,%edx
    493e:	mov    0x480(%rsp),%rsi
    4946:	mov    0x458(%rsp),%rdi
    494e:	call   4953 <botlish_fn_19+0x35cb>
			494f: R_X86_64_PLT32	rt_int_cmp-0x4
    4953:	mov    $0x2,%esi
    4958:	test   %rax,%rax
    495b:	cmovl  0x5e75(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    4963:	jmp    4984 <botlish_fn_19+0x35fc>
    4968:	mov    $0x2,%esi
    496d:	mov    0x480(%rsp),%rcx
    4975:	cmp    $0xed,%rcx
    497c:	cmovl  0x5e54(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    4984:	cmp    $0x6,%rsi
    4988:	je     4999 <botlish_fn_19+0x3611>
    498e:	mov    $0x23,%r15d
    4994:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4999:	mov    $0xd,%r15d
    499f:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    49a4:	mov    $0x23,%r15d
    49aa:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    49af:	test   %r15,%r15
    49b2:	jle    4bae <botlish_fn_19+0x3826>
    49b8:	cmp    $0x2,%r15
    49bc:	jl     4ab7 <botlish_fn_19+0x372f>
    49c2:	mov    0x480(%rsp),%rsi
    49ca:	test   $0x1,%rsi
    49d1:	jne    4a06 <botlish_fn_19+0x367e>
    49d7:	mov    $0xc3,%edx
    49dc:	mov    0x480(%rsp),%rsi
    49e4:	mov    0x458(%rsp),%rdi
    49ec:	call   49f1 <botlish_fn_19+0x3669>
			49ed: R_X86_64_PLT32	rt_int_cmp-0x4
    49f1:	mov    $0x2,%ecx
    49f6:	test   %rax,%rax
    49f9:	cmovl  0x5dd7(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4a01:	jmp    4a22 <botlish_fn_19+0x369a>
    4a06:	mov    $0x2,%ecx
    4a0b:	mov    0x480(%rsp),%rsi
    4a13:	cmp    $0xc3,%rsi
    4a1a:	cmovl  0x5db6(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4a22:	cmp    $0x6,%rcx
    4a26:	je     4aac <botlish_fn_19+0x3724>
    4a2c:	mov    0x480(%rsp),%rsi
    4a34:	test   $0x1,%rsi
    4a3b:	jne    4a70 <botlish_fn_19+0x36e8>
    4a41:	mov    $0xc5,%edx
    4a46:	mov    0x480(%rsp),%rsi
    4a4e:	mov    0x458(%rsp),%rdi
    4a56:	call   4a5b <botlish_fn_19+0x36d3>
			4a57: R_X86_64_PLT32	rt_int_cmp-0x4
    4a5b:	mov    $0x2,%ecx
    4a60:	test   %rax,%rax
    4a63:	cmovl  0x5d6d(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4a6b:	jmp    4a8c <botlish_fn_19+0x3704>
    4a70:	mov    $0x2,%ecx
    4a75:	mov    0x480(%rsp),%rsi
    4a7d:	cmp    $0xc5,%rsi
    4a84:	cmovl  0x5d4c(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4a8c:	cmp    $0x6,%rcx
    4a90:	je     4aa1 <botlish_fn_19+0x3719>
    4a96:	mov    $0x21,%r15d
    4a9c:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4aa1:	mov    $0xb,%r15d
    4aa7:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4aac:	mov    $0x21,%r15d
    4ab2:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4ab7:	mov    0x480(%rsp),%rsi
    4abf:	test   $0x1,%rsi
    4ac6:	jne    4afb <botlish_fn_19+0x3773>
    4acc:	mov    $0xe5,%edx
    4ad1:	mov    0x480(%rsp),%rsi
    4ad9:	mov    0x458(%rsp),%rdi
    4ae1:	call   4ae6 <botlish_fn_19+0x375e>
			4ae2: R_X86_64_PLT32	rt_int_cmp-0x4
    4ae6:	mov    $0x2,%ecx
    4aeb:	test   %rax,%rax
    4aee:	cmovl  0x5ce2(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4af6:	jmp    4b17 <botlish_fn_19+0x378f>
    4afb:	mov    $0x2,%ecx
    4b00:	mov    0x480(%rsp),%rsi
    4b08:	cmp    $0xe5,%rsi
    4b0f:	cmovl  0x5cc1(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4b17:	cmp    $0x6,%rcx
    4b1b:	je     4ba3 <botlish_fn_19+0x381b>
    4b21:	mov    0x480(%rsp),%rsi
    4b29:	test   $0x1,%rsi
    4b30:	jne    4b66 <botlish_fn_19+0x37de>
    4b36:	mov    $0xe7,%edx
    4b3b:	mov    0x480(%rsp),%rsi
    4b43:	mov    0x458(%rsp),%rdi
    4b4b:	call   4b50 <botlish_fn_19+0x37c8>
			4b4c: R_X86_64_PLT32	rt_int_cmp-0x4
    4b50:	mov    $0x2,%r9d
    4b56:	test   %rax,%rax
    4b59:	cmovl  0x5c77(%rip),%r9        # a7d8 <botlish_fn_19+0x9450>
    4b61:	jmp    4b83 <botlish_fn_19+0x37fb>
    4b66:	mov    $0x2,%r9d
    4b6c:	mov    0x480(%rsp),%rsi
    4b74:	cmp    $0xe7,%rsi
    4b7b:	cmovl  0x5c55(%rip),%r9        # a7d8 <botlish_fn_19+0x9450>
    4b83:	cmp    $0x6,%r9
    4b87:	je     4b98 <botlish_fn_19+0x3810>
    4b8d:	mov    $0x1f,%r15d
    4b93:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4b98:	mov    $0x9,%r15d
    4b9e:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4ba3:	mov    $0x1f,%r15d
    4ba9:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4bae:	mov    0x480(%rsp),%rsi
    4bb6:	test   $0x1,%rsi
    4bbd:	jne    4bf2 <botlish_fn_19+0x386a>
    4bc3:	mov    $0xdd,%edx
    4bc8:	mov    0x480(%rsp),%rsi
    4bd0:	mov    0x458(%rsp),%rdi
    4bd8:	call   4bdd <botlish_fn_19+0x3855>
			4bd9: R_X86_64_PLT32	rt_int_cmp-0x4
    4bdd:	mov    $0x2,%ecx
    4be2:	test   %rax,%rax
    4be5:	cmovl  0x5beb(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4bed:	jmp    4c0e <botlish_fn_19+0x3886>
    4bf2:	mov    $0x2,%ecx
    4bf7:	mov    0x480(%rsp),%rsi
    4bff:	cmp    $0xdd,%rsi
    4c06:	cmovl  0x5bca(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4c0e:	cmp    $0x6,%rcx
    4c12:	je     4d34 <botlish_fn_19+0x39ac>
    4c18:	mov    0x480(%rsp),%rsi
    4c20:	test   $0x1,%rsi
    4c27:	jne    4c5c <botlish_fn_19+0x38d4>
    4c2d:	mov    $0xe9,%edx
    4c32:	mov    0x480(%rsp),%rsi
    4c3a:	mov    0x458(%rsp),%rdi
    4c42:	call   4c47 <botlish_fn_19+0x38bf>
			4c43: R_X86_64_PLT32	rt_int_cmp-0x4
    4c47:	mov    $0x2,%ecx
    4c4c:	test   %rax,%rax
    4c4f:	cmovl  0x5b81(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4c57:	jmp    4c78 <botlish_fn_19+0x38f0>
    4c5c:	mov    $0x2,%ecx
    4c61:	mov    0x480(%rsp),%rsi
    4c69:	cmp    $0xe9,%rsi
    4c70:	cmovl  0x5b60(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4c78:	cmp    $0x6,%rcx
    4c7c:	je     4d04 <botlish_fn_19+0x397c>
    4c82:	mov    0x480(%rsp),%rsi
    4c8a:	test   $0x1,%rsi
    4c91:	jne    4cc6 <botlish_fn_19+0x393e>
    4c97:	mov    $0xeb,%edx
    4c9c:	mov    0x480(%rsp),%rsi
    4ca4:	mov    0x458(%rsp),%rdi
    4cac:	call   4cb1 <botlish_fn_19+0x3929>
			4cad: R_X86_64_PLT32	rt_int_cmp-0x4
    4cb1:	mov    $0x2,%ecx
    4cb6:	test   %rax,%rax
    4cb9:	cmovl  0x5b17(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4cc1:	jmp    4ce2 <botlish_fn_19+0x395a>
    4cc6:	mov    $0x2,%ecx
    4ccb:	mov    0x480(%rsp),%rsi
    4cd3:	cmp    $0xeb,%rsi
    4cda:	cmovl  0x5af6(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4ce2:	cmp    $0x6,%rcx
    4ce6:	je     4cf7 <botlish_fn_19+0x396f>
    4cec:	mov    $0x1d,%r15d
    4cf2:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4cf7:	mov    0x530(%rsp),%r15
    4cff:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4d04:	mov    0x480(%rsp),%rsi
    4d0c:	mov    %rsi,%rax
    4d0f:	sar    $1,%rax
    4d12:	cmp    $0x6f,%rax
    4d16:	jl     4d27 <botlish_fn_19+0x399f>
    4d1c:	mov    $0x1d,%r15d
    4d22:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4d27:	mov    0x4f8(%rsp),%r15
    4d2f:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4d34:	mov    0x480(%rsp),%rsi
    4d3c:	test   $0x1,%rsi
    4d43:	jne    4d78 <botlish_fn_19+0x39f0>
    4d49:	mov    $0xcd,%edx
    4d4e:	mov    0x480(%rsp),%rsi
    4d56:	mov    0x458(%rsp),%rdi
    4d5e:	call   4d63 <botlish_fn_19+0x39db>
			4d5f: R_X86_64_PLT32	rt_int_cmp-0x4
    4d63:	mov    $0x2,%ecx
    4d68:	test   %rax,%rax
    4d6b:	cmovl  0x5a65(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4d73:	jmp    4d94 <botlish_fn_19+0x3a0c>
    4d78:	mov    $0x2,%ecx
    4d7d:	mov    0x480(%rsp),%rsi
    4d85:	cmp    $0xcd,%rsi
    4d8c:	cmovl  0x5a44(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4d94:	cmp    $0x6,%rcx
    4d98:	je     4dcc <botlish_fn_19+0x3a44>
    4d9e:	mov    0x480(%rsp),%rsi
    4da6:	mov    %rsi,%rax
    4da9:	sar    $1,%rax
    4dac:	cmp    $0x67,%rax
    4db0:	jl     4dc1 <botlish_fn_19+0x3a39>
    4db6:	mov    $0x1d,%r15d
    4dbc:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4dc1:	mov    $0x5,%r15d
    4dc7:	jmp    4dd2 <botlish_fn_19+0x3a4a>
    4dcc:	mov    $0x1d,%r15d
    4dd2:	mov    %r15,%rsi
    4dd5:	sar    $1,%rsi
    4dd8:	cmp    $0xc,%rsi
    4ddc:	jl     4f11 <botlish_fn_19+0x3b89>
    4de2:	cmp    $0xd,%rsi
    4de6:	mov    %rsi,%r12
    4de9:	je     4f06 <botlish_fn_19+0x3b7e>
    4def:	mov    0x480(%rsp),%rsi
    4df7:	test   $0x1,%rsi
    4dfe:	jne    4e36 <botlish_fn_19+0x3aae>
    4e04:	mov    0x500(%rsp),%rdx
    4e0c:	mov    0x480(%rsp),%rsi
    4e14:	mov    0x458(%rsp),%rdi
    4e1c:	call   4e21 <botlish_fn_19+0x3a99>
			4e1d: R_X86_64_PLT32	rt_int_cmp-0x4
    4e21:	mov    $0x2,%ecx
    4e26:	test   %rax,%rax
    4e29:	cmove  0x59a7(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4e31:	jmp    4e4f <botlish_fn_19+0x3ac7>
    4e36:	mov    $0x2,%ecx
    4e3b:	mov    0x480(%rsp),%rsi
    4e43:	cmp    $0xffffffffffffffff,%rsi
    4e47:	cmove  0x5989(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4e4f:	cmp    $0x6,%rcx
    4e53:	je     4eb6 <botlish_fn_19+0x3b2e>
    4e59:	mov    %r12,%rsi
    4e5c:	mov    0x458(%rsp),%rdi
    4e64:	call   4e69 <botlish_fn_19+0x3ae1>
			4e65: R_X86_64_PLT32	botlish_fn_3-0x4
    4e69:	mov    0x458(%rsp),%rdi
    4e71:	mov    0x10(%rdi),%rcx
    4e75:	mov    0x1f8(%rcx),%rdx
    4e7c:	lea    0x430(%rsp),%r9
    4e84:	mov    %rax,0x430(%rsp)
    4e8c:	mov    0x480(%rsp),%rsi
    4e94:	mov    %rsi,0x438(%rsp)
    4e9c:	mov    $0x1,%esi
    4ea1:	mov    $0x8,%ecx
    4ea6:	mov    $0x2,%r8d
    4eac:	call   4eb1 <botlish_fn_19+0x3b29>
			4ead: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4eb1:	jmp    8cef <botlish_fn_19+0x7967>
    4eb6:	mov    %r12,%rsi
    4eb9:	mov    0x458(%rsp),%rdi
    4ec1:	call   4ec6 <botlish_fn_19+0x3b3e>
			4ec2: R_X86_64_PLT32	botlish_fn_3-0x4
    4ec6:	mov    0x458(%rsp),%rdi
    4ece:	mov    0x10(%rdi),%rcx
    4ed2:	mov    0x1f0(%rcx),%rdx
    4ed9:	lea    0x428(%rsp),%r9
    4ee1:	mov    %rax,0x428(%rsp)
    4ee9:	mov    $0x2,%esi
    4eee:	mov    $0x1,%r8d
    4ef4:	mov    0x530(%rsp),%rcx
    4efc:	call   4f01 <botlish_fn_19+0x3b79>
			4efd: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4f01:	jmp    8cef <botlish_fn_19+0x7967>
    4f06:	mov    %rbx,%r15
    4f09:	mov    %r14,%rbx
    4f0c:	jmp    6b89 <botlish_fn_19+0x5801>
    4f11:	mov    %r15,0xe8(%rsp)
    4f19:	mov    $0x6,%r13d
    4f1f:	movq   $0x6,0xb8(%rsp)
    4f2b:	mov    $0x5,%ebx
    4f30:	mov    0x478(%rsp),%r12
    4f38:	jmp    8e95 <botlish_fn_19+0x7b0d>
    4f3d:	mov    %rsi,0x480(%rsp)
    4f45:	mov    %r14,%rbx
    4f48:	sar    $1,%r14
    4f4b:	cmp    $0x4,%r14
    4f4f:	jl     5cea <botlish_fn_19+0x4962>
    4f55:	cmp    $0x6,%r14
    4f59:	jl     59d4 <botlish_fn_19+0x464c>
    4f5f:	cmp    $0x7,%r14
    4f63:	jl     54ef <botlish_fn_19+0x4167>
    4f69:	cmp    $0x8,%r14
    4f6d:	jl     5400 <botlish_fn_19+0x4078>
    4f73:	mov    0x480(%rsp),%rsi
    4f7b:	test   $0x1,%rsi
    4f82:	jne    4fb7 <botlish_fn_19+0x3c2f>
    4f88:	mov    $0x43,%edx
    4f8d:	mov    0x480(%rsp),%rsi
    4f95:	mov    0x458(%rsp),%rdi
    4f9d:	call   4fa2 <botlish_fn_19+0x3c1a>
			4f9e: R_X86_64_PLT32	rt_int_cmp-0x4
    4fa2:	mov    $0x2,%ecx
    4fa7:	test   %rax,%rax
    4faa:	cmovl  0x5826(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4fb2:	jmp    4fd0 <botlish_fn_19+0x3c48>
    4fb7:	mov    $0x2,%ecx
    4fbc:	mov    0x480(%rsp),%rsi
    4fc4:	cmp    $0x43,%rsi
    4fc8:	cmovl  0x5808(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    4fd0:	cmp    $0x6,%rcx
    4fd4:	je     5225 <botlish_fn_19+0x3e9d>
    4fda:	mov    0x480(%rsp),%rsi
    4fe2:	test   $0x1,%rsi
    4fe9:	jne    501e <botlish_fn_19+0x3c96>
    4fef:	mov    $0x75,%edx
    4ff4:	mov    0x480(%rsp),%rsi
    4ffc:	mov    0x458(%rsp),%rdi
    5004:	call   5009 <botlish_fn_19+0x3c81>
			5005: R_X86_64_PLT32	rt_int_cmp-0x4
    5009:	mov    $0x2,%ecx
    500e:	test   %rax,%rax
    5011:	cmovl  0x57bf(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5019:	jmp    5037 <botlish_fn_19+0x3caf>
    501e:	mov    $0x2,%ecx
    5023:	mov    0x480(%rsp),%rsi
    502b:	cmp    $0x75,%rsi
    502f:	cmovl  0x57a1(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5037:	cmp    $0x6,%rcx
    503b:	je     51cd <botlish_fn_19+0x3e45>
    5041:	mov    0x480(%rsp),%rsi
    5049:	test   $0x1,%rsi
    5050:	jne    5085 <botlish_fn_19+0x3cfd>
    5056:	mov    $0xbd,%edx
    505b:	mov    0x480(%rsp),%rsi
    5063:	mov    0x458(%rsp),%rdi
    506b:	call   5070 <botlish_fn_19+0x3ce8>
			506c: R_X86_64_PLT32	rt_int_cmp-0x4
    5070:	mov    $0x2,%ecx
    5075:	test   %rax,%rax
    5078:	cmovl  0x5758(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5080:	jmp    50a1 <botlish_fn_19+0x3d19>
    5085:	mov    $0x2,%ecx
    508a:	mov    0x480(%rsp),%rsi
    5092:	cmp    $0xbd,%rsi
    5099:	cmovl  0x5737(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    50a1:	cmp    $0x6,%rcx
    50a5:	je     519f <botlish_fn_19+0x3e17>
    50ab:	mov    0x480(%rsp),%rsi
    50b3:	test   $0x1,%rsi
    50ba:	jne    50ef <botlish_fn_19+0x3d67>
    50c0:	mov    $0xfb,%edx
    50c5:	mov    0x480(%rsp),%rsi
    50cd:	mov    0x458(%rsp),%rdi
    50d5:	call   50da <botlish_fn_19+0x3d52>
			50d6: R_X86_64_PLT32	rt_int_cmp-0x4
    50da:	mov    $0x2,%ecx
    50df:	test   %rax,%rax
    50e2:	cmovl  0x56ee(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    50ea:	jmp    510b <botlish_fn_19+0x3d83>
    50ef:	mov    $0x2,%ecx
    50f4:	mov    0x480(%rsp),%rsi
    50fc:	cmp    $0xfb,%rsi
    5103:	cmovl  0x56cd(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    510b:	cmp    $0x6,%rcx
    510f:	je     5194 <botlish_fn_19+0x3e0c>
    5115:	mov    0x480(%rsp),%rsi
    511d:	test   $0x1,%rsi
    5124:	jne    5159 <botlish_fn_19+0x3dd1>
    512a:	mov    $0xfd,%edx
    512f:	mov    0x480(%rsp),%rsi
    5137:	mov    0x458(%rsp),%rdi
    513f:	call   5144 <botlish_fn_19+0x3dbc>
			5140: R_X86_64_PLT32	rt_int_cmp-0x4
    5144:	mov    $0x2,%esi
    5149:	test   %rax,%rax
    514c:	cmovl  0x5684(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    5154:	jmp    5174 <botlish_fn_19+0x3dec>
    5159:	mov    $0x2,%esi
    515e:	mov    0x480(%rsp),%rax
    5166:	cmp    $0xfd,%rax
    516c:	cmovl  0x5664(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    5174:	cmp    $0x6,%rsi
    5178:	je     5189 <botlish_fn_19+0x3e01>
    517e:	mov    $0x27,%r14d
    5184:	jmp    6a55 <botlish_fn_19+0x56cd>
    5189:	mov    $0x15,%r14d
    518f:	jmp    6a55 <botlish_fn_19+0x56cd>
    5194:	mov    $0x27,%r14d
    519a:	jmp    6a55 <botlish_fn_19+0x56cd>
    519f:	mov    0x480(%rsp),%rsi
    51a7:	mov    %rsi,%rax
    51aa:	sar    $1,%rax
    51ad:	cmp    $0x5d,%rax
    51b1:	jl     51c2 <botlish_fn_19+0x3e3a>
    51b7:	mov    $0x15,%r14d
    51bd:	jmp    6a55 <botlish_fn_19+0x56cd>
    51c2:	mov    $0x27,%r14d
    51c8:	jmp    6a55 <botlish_fn_19+0x56cd>
    51cd:	mov    0x480(%rsp),%rsi
    51d5:	mov    %rsi,%rax
    51d8:	sar    $1,%rax
    51db:	cmp    $0x2d,%rax
    51df:	jl     5205 <botlish_fn_19+0x3e7d>
    51e5:	cmp    $0x30,%rax
    51e9:	jl     51fa <botlish_fn_19+0x3e72>
    51ef:	mov    $0x11,%r14d
    51f5:	jmp    6a55 <botlish_fn_19+0x56cd>
    51fa:	mov    $0x27,%r14d
    5200:	jmp    6a55 <botlish_fn_19+0x56cd>
    5205:	cmp    $0x2c,%rax
    5209:	jl     521a <botlish_fn_19+0x3e92>
    520f:	mov    $0x15,%r14d
    5215:	jmp    6a55 <botlish_fn_19+0x56cd>
    521a:	mov    $0x27,%r14d
    5220:	jmp    6a55 <botlish_fn_19+0x56cd>
    5225:	mov    0x480(%rsp),%rsi
    522d:	test   $0x1,%rsi
    5234:	jne    5269 <botlish_fn_19+0x3ee1>
    523a:	mov    $0x17,%edx
    523f:	mov    0x480(%rsp),%rsi
    5247:	mov    0x458(%rsp),%rdi
    524f:	call   5254 <botlish_fn_19+0x3ecc>
			5250: R_X86_64_PLT32	rt_int_cmp-0x4
    5254:	mov    $0x2,%ecx
    5259:	test   %rax,%rax
    525c:	cmovl  0x5574(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5264:	jmp    5282 <botlish_fn_19+0x3efa>
    5269:	mov    $0x2,%ecx
    526e:	mov    0x480(%rsp),%rsi
    5276:	cmp    $0x17,%rsi
    527a:	cmovl  0x5556(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5282:	cmp    $0x6,%rcx
    5286:	je     52e4 <botlish_fn_19+0x3f5c>
    528c:	mov    0x480(%rsp),%rsi
    5294:	mov    %rsi,%rax
    5297:	sar    $1,%rax
    529a:	cmp    $0xe,%rax
    529e:	jl     52c4 <botlish_fn_19+0x3f3c>
    52a4:	cmp    $0x20,%rax
    52a8:	jl     52b9 <botlish_fn_19+0x3f31>
    52ae:	mov    $0x15,%r14d
    52b4:	jmp    6a55 <botlish_fn_19+0x56cd>
    52b9:	mov    $0x27,%r14d
    52bf:	jmp    6a55 <botlish_fn_19+0x56cd>
    52c4:	cmp    $0xd,%rax
    52c8:	jl     52d9 <botlish_fn_19+0x3f51>
    52ce:	mov    $0x15,%r14d
    52d4:	jmp    6a55 <botlish_fn_19+0x56cd>
    52d9:	mov    $0x27,%r14d
    52df:	jmp    6a55 <botlish_fn_19+0x56cd>
    52e4:	mov    0x480(%rsp),%rsi
    52ec:	test   $0x1,%rsi
    52f3:	jne    5328 <botlish_fn_19+0x3fa0>
    52f9:	mov    $0x1,%edx
    52fe:	mov    0x480(%rsp),%rsi
    5306:	mov    0x458(%rsp),%rdi
    530e:	call   5313 <botlish_fn_19+0x3f8b>
			530f: R_X86_64_PLT32	rt_int_cmp-0x4
    5313:	mov    $0x2,%esi
    5318:	test   %rax,%rax
    531b:	cmovl  0x54b5(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    5323:	jmp    5348 <botlish_fn_19+0x3fc0>
    5328:	mov    $0x2,%esi
    532d:	mov    0x480(%rsp),%rax
    5335:	mov    0x480(%rsp),%rcx
    533d:	test   %rcx,%rax
    5340:	cmovle 0x5490(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    5348:	cmp    $0x6,%rsi
    534c:	je     5380 <botlish_fn_19+0x3ff8>
    5352:	mov    0x480(%rsp),%rsi
    535a:	mov    %rsi,%rax
    535d:	sar    $1,%rax
    5360:	cmp    $0x9,%rax
    5364:	jl     5375 <botlish_fn_19+0x3fed>
    536a:	mov    $0x15,%r14d
    5370:	jmp    6a55 <botlish_fn_19+0x56cd>
    5375:	mov    $0x27,%r14d
    537b:	jmp    6a55 <botlish_fn_19+0x56cd>
    5380:	mov    0x480(%rsp),%rsi
    5388:	test   $0x1,%rsi
    538f:	jne    53c7 <botlish_fn_19+0x403f>
    5395:	mov    0x500(%rsp),%rdx
    539d:	mov    0x480(%rsp),%rsi
    53a5:	mov    0x458(%rsp),%rdi
    53ad:	call   53b2 <botlish_fn_19+0x402a>
			53ae: R_X86_64_PLT32	rt_int_cmp-0x4
    53b2:	mov    $0x2,%ecx
    53b7:	test   %rax,%rax
    53ba:	cmovl  0x5416(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    53c2:	jmp    53e0 <botlish_fn_19+0x4058>
    53c7:	mov    $0x2,%ecx
    53cc:	mov    0x480(%rsp),%rsi
    53d4:	cmp    $0xffffffffffffffff,%rsi
    53d8:	cmovl  0x53f8(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    53e0:	cmp    $0x6,%rcx
    53e4:	je     53f5 <botlish_fn_19+0x406d>
    53ea:	mov    $0x15,%r14d
    53f0:	jmp    6a55 <botlish_fn_19+0x56cd>
    53f5:	mov    $0x27,%r14d
    53fb:	jmp    6a55 <botlish_fn_19+0x56cd>
    5400:	mov    0x480(%rsp),%rsi
    5408:	test   $0x1,%rsi
    540f:	jne    5444 <botlish_fn_19+0x40bc>
    5415:	mov    $0x61,%edx
    541a:	mov    0x480(%rsp),%rsi
    5422:	mov    0x458(%rsp),%rdi
    542a:	call   542f <botlish_fn_19+0x40a7>
			542b: R_X86_64_PLT32	rt_int_cmp-0x4
    542f:	mov    $0x2,%ecx
    5434:	test   %rax,%rax
    5437:	cmovl  0x5399(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    543f:	jmp    545d <botlish_fn_19+0x40d5>
    5444:	mov    $0x2,%ecx
    5449:	mov    0x480(%rsp),%rsi
    5451:	cmp    $0x61,%rsi
    5455:	cmovl  0x537b(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    545d:	cmp    $0x6,%rcx
    5461:	je     54e4 <botlish_fn_19+0x415c>
    5467:	mov    0x480(%rsp),%rsi
    546f:	test   $0x1,%rsi
    5476:	jne    54ab <botlish_fn_19+0x4123>
    547c:	mov    $0x75,%edx
    5481:	mov    0x480(%rsp),%rsi
    5489:	mov    0x458(%rsp),%rdi
    5491:	call   5496 <botlish_fn_19+0x410e>
			5492: R_X86_64_PLT32	rt_int_cmp-0x4
    5496:	mov    $0x2,%ecx
    549b:	test   %rax,%rax
    549e:	cmovl  0x5332(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    54a6:	jmp    54c4 <botlish_fn_19+0x413c>
    54ab:	mov    $0x2,%ecx
    54b0:	mov    0x480(%rsp),%rsi
    54b8:	cmp    $0x75,%rsi
    54bc:	cmovl  0x5314(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    54c4:	cmp    $0x6,%rcx
    54c8:	je     54d9 <botlish_fn_19+0x4151>
    54ce:	mov    $0x25,%r14d
    54d4:	jmp    6a55 <botlish_fn_19+0x56cd>
    54d9:	mov    $0x11,%r14d
    54df:	jmp    6a55 <botlish_fn_19+0x56cd>
    54e4:	mov    $0x25,%r14d
    54ea:	jmp    6a55 <botlish_fn_19+0x56cd>
    54ef:	mov    0x480(%rsp),%rsi
    54f7:	test   $0x1,%rsi
    54fe:	jne    5533 <botlish_fn_19+0x41ab>
    5504:	mov    $0x5b,%edx
    5509:	mov    0x480(%rsp),%rsi
    5511:	mov    0x458(%rsp),%rdi
    5519:	call   551e <botlish_fn_19+0x4196>
			551a: R_X86_64_PLT32	rt_int_cmp-0x4
    551e:	mov    $0x2,%ecx
    5523:	test   %rax,%rax
    5526:	cmovl  0x52aa(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    552e:	jmp    554c <botlish_fn_19+0x41c4>
    5533:	mov    $0x2,%ecx
    5538:	mov    0x480(%rsp),%rsi
    5540:	cmp    $0x5b,%rsi
    5544:	cmovl  0x528c(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    554c:	cmp    $0x6,%rcx
    5550:	je     57cf <botlish_fn_19+0x4447>
    5556:	mov    0x480(%rsp),%rsi
    555e:	test   $0x1,%rsi
    5565:	jne    559a <botlish_fn_19+0x4212>
    556b:	mov    $0xbb,%edx
    5570:	mov    0x480(%rsp),%rsi
    5578:	mov    0x458(%rsp),%rdi
    5580:	call   5585 <botlish_fn_19+0x41fd>
			5581: R_X86_64_PLT32	rt_int_cmp-0x4
    5585:	mov    $0x2,%ecx
    558a:	test   %rax,%rax
    558d:	cmovl  0x5243(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5595:	jmp    55b6 <botlish_fn_19+0x422e>
    559a:	mov    $0x2,%ecx
    559f:	mov    0x480(%rsp),%rsi
    55a7:	cmp    $0xbb,%rsi
    55ae:	cmovl  0x5222(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    55b6:	cmp    $0x6,%rcx
    55ba:	je     5762 <botlish_fn_19+0x43da>
    55c0:	mov    0x480(%rsp),%rsi
    55c8:	test   $0x1,%rsi
    55cf:	jne    5604 <botlish_fn_19+0x427c>
    55d5:	mov    $0xcd,%edx
    55da:	mov    0x480(%rsp),%rsi
    55e2:	mov    0x458(%rsp),%rdi
    55ea:	call   55ef <botlish_fn_19+0x4267>
			55eb: R_X86_64_PLT32	rt_int_cmp-0x4
    55ef:	mov    $0x2,%ecx
    55f4:	test   %rax,%rax
    55f7:	cmovl  0x51d9(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    55ff:	jmp    5620 <botlish_fn_19+0x4298>
    5604:	mov    $0x2,%ecx
    5609:	mov    0x480(%rsp),%rsi
    5611:	cmp    $0xcd,%rsi
    5618:	cmovl  0x51b8(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5620:	cmp    $0x6,%rcx
    5624:	je     571f <botlish_fn_19+0x4397>
    562a:	mov    0x480(%rsp),%rsi
    5632:	test   $0x1,%rsi
    5639:	jne    566e <botlish_fn_19+0x42e6>
    563f:	mov    $0xfb,%edx
    5644:	mov    0x480(%rsp),%rsi
    564c:	mov    0x458(%rsp),%rdi
    5654:	call   5659 <botlish_fn_19+0x42d1>
			5655: R_X86_64_PLT32	rt_int_cmp-0x4
    5659:	mov    $0x2,%ecx
    565e:	test   %rax,%rax
    5661:	cmovl  0x516f(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5669:	jmp    568a <botlish_fn_19+0x4302>
    566e:	mov    $0x2,%ecx
    5673:	mov    0x480(%rsp),%rsi
    567b:	cmp    $0xfb,%rsi
    5682:	cmovl  0x514e(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    568a:	cmp    $0x6,%rcx
    568e:	je     5714 <botlish_fn_19+0x438c>
    5694:	mov    0x480(%rsp),%rsi
    569c:	test   $0x1,%rsi
    56a3:	jne    56d8 <botlish_fn_19+0x4350>
    56a9:	mov    $0xfd,%edx
    56ae:	mov    0x480(%rsp),%rsi
    56b6:	mov    0x458(%rsp),%rdi
    56be:	call   56c3 <botlish_fn_19+0x433b>
			56bf: R_X86_64_PLT32	rt_int_cmp-0x4
    56c3:	mov    $0x2,%esi
    56c8:	test   %rax,%rax
    56cb:	cmovl  0x5105(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    56d3:	jmp    56f4 <botlish_fn_19+0x436c>
    56d8:	mov    $0x2,%esi
    56dd:	mov    0x480(%rsp),%rdi
    56e5:	cmp    $0xfd,%rdi
    56ec:	cmovl  0x50e4(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    56f4:	cmp    $0x6,%rsi
    56f8:	je     5709 <botlish_fn_19+0x4381>
    56fe:	mov    $0x23,%r14d
    5704:	jmp    6a55 <botlish_fn_19+0x56cd>
    5709:	mov    $0x15,%r14d
    570f:	jmp    6a55 <botlish_fn_19+0x56cd>
    5714:	mov    $0x23,%r14d
    571a:	jmp    6a55 <botlish_fn_19+0x56cd>
    571f:	mov    0x480(%rsp),%rsi
    5727:	mov    %rsi,%rax
    572a:	sar    $1,%rax
    572d:	cmp    $0x5e,%rax
    5731:	jl     5757 <botlish_fn_19+0x43cf>
    5737:	cmp    $0x65,%rax
    573b:	jl     574c <botlish_fn_19+0x43c4>
    5741:	mov    $0xb,%r14d
    5747:	jmp    6a55 <botlish_fn_19+0x56cd>
    574c:	mov    $0x23,%r14d
    5752:	jmp    6a55 <botlish_fn_19+0x56cd>
    5757:	mov    $0x15,%r14d
    575d:	jmp    6a55 <botlish_fn_19+0x56cd>
    5762:	mov    0x480(%rsp),%rsi
    576a:	mov    %rsi,%r10
    576d:	sar    $1,%r10
    5770:	cmp    $0x3a,%r10
    5774:	jl     57af <botlish_fn_19+0x4427>
    577a:	cmp    $0x45,%r10
    577e:	jl     57a4 <botlish_fn_19+0x441c>
    5784:	cmp    $0x46,%r10
    5788:	jl     5799 <botlish_fn_19+0x4411>
    578e:	mov    $0x23,%r14d
    5794:	jmp    6a55 <botlish_fn_19+0x56cd>
    5799:	mov    $0xb,%r14d
    579f:	jmp    6a55 <botlish_fn_19+0x56cd>
    57a4:	mov    $0x23,%r14d
    57aa:	jmp    6a55 <botlish_fn_19+0x56cd>
    57af:	cmp    $0x30,%r10
    57b3:	jl     57c4 <botlish_fn_19+0x443c>
    57b9:	mov    $0xd,%r14d
    57bf:	jmp    6a55 <botlish_fn_19+0x56cd>
    57c4:	mov    $0x23,%r14d
    57ca:	jmp    6a55 <botlish_fn_19+0x56cd>
    57cf:	mov    0x480(%rsp),%rsi
    57d7:	test   $0x1,%rsi
    57de:	jne    5813 <botlish_fn_19+0x448b>
    57e4:	mov    $0x1b,%edx
    57e9:	mov    0x480(%rsp),%rsi
    57f1:	mov    0x458(%rsp),%rdi
    57f9:	call   57fe <botlish_fn_19+0x4476>
			57fa: R_X86_64_PLT32	rt_int_cmp-0x4
    57fe:	mov    $0x2,%ecx
    5803:	test   %rax,%rax
    5806:	cmovl  0x4fca(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    580e:	jmp    582c <botlish_fn_19+0x44a4>
    5813:	mov    $0x2,%ecx
    5818:	mov    0x480(%rsp),%rsi
    5820:	cmp    $0x1b,%rsi
    5824:	cmovl  0x4fac(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    582c:	cmp    $0x6,%rcx
    5830:	je     58a3 <botlish_fn_19+0x451b>
    5836:	mov    0x480(%rsp),%rsi
    583e:	mov    %rsi,%rax
    5841:	sar    $1,%rax
    5844:	cmp    $0x20,%rax
    5848:	jl     5883 <botlish_fn_19+0x44fb>
    584e:	cmp    $0x21,%rax
    5852:	jl     5878 <botlish_fn_19+0x44f0>
    5858:	cmp    $0x2c,%rax
    585c:	jl     586d <botlish_fn_19+0x44e5>
    5862:	mov    $0x15,%r14d
    5868:	jmp    6a55 <botlish_fn_19+0x56cd>
    586d:	mov    $0x23,%r14d
    5873:	jmp    6a55 <botlish_fn_19+0x56cd>
    5878:	mov    $0x15,%r14d
    587e:	jmp    6a55 <botlish_fn_19+0x56cd>
    5883:	cmp    $0xe,%rax
    5887:	jl     5898 <botlish_fn_19+0x4510>
    588d:	mov    $0x23,%r14d
    5893:	jmp    6a55 <botlish_fn_19+0x56cd>
    5898:	mov    $0x15,%r14d
    589e:	jmp    6a55 <botlish_fn_19+0x56cd>
    58a3:	mov    0x480(%rsp),%rsi
    58ab:	test   $0x1,%rsi
    58b2:	jne    58e7 <botlish_fn_19+0x455f>
    58b8:	mov    $0x1,%edx
    58bd:	mov    0x480(%rsp),%rsi
    58c5:	mov    0x458(%rsp),%rdi
    58cd:	call   58d2 <botlish_fn_19+0x454a>
			58ce: R_X86_64_PLT32	rt_int_cmp-0x4
    58d2:	mov    $0x2,%ecx
    58d7:	test   %rax,%rax
    58da:	cmovl  0x4ef6(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    58e2:	jmp    5907 <botlish_fn_19+0x457f>
    58e7:	mov    $0x2,%ecx
    58ec:	mov    0x480(%rsp),%rax
    58f4:	mov    0x480(%rsp),%rsi
    58fc:	test   %rax,%rsi
    58ff:	cmovle 0x4ed1(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5907:	cmp    $0x6,%rcx
    590b:	je     5954 <botlish_fn_19+0x45cc>
    5911:	mov    0x480(%rsp),%rsi
    5919:	mov    %rsi,%rax
    591c:	sar    $1,%rax
    591f:	cmp    $0x9,%rax
    5923:	jl     5949 <botlish_fn_19+0x45c1>
    5929:	cmp    $0xb,%rax
    592d:	jl     593e <botlish_fn_19+0x45b6>
    5933:	mov    $0x23,%r14d
    5939:	jmp    6a55 <botlish_fn_19+0x56cd>
    593e:	mov    $0x15,%r14d
    5944:	jmp    6a55 <botlish_fn_19+0x56cd>
    5949:	mov    $0x23,%r14d
    594f:	jmp    6a55 <botlish_fn_19+0x56cd>
    5954:	mov    0x480(%rsp),%rsi
    595c:	test   $0x1,%rsi
    5963:	jne    599b <botlish_fn_19+0x4613>
    5969:	mov    0x500(%rsp),%rdx
    5971:	mov    0x480(%rsp),%rsi
    5979:	mov    0x458(%rsp),%rdi
    5981:	call   5986 <botlish_fn_19+0x45fe>
			5982: R_X86_64_PLT32	rt_int_cmp-0x4
    5986:	mov    $0x2,%ecx
    598b:	test   %rax,%rax
    598e:	cmovl  0x4e42(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5996:	jmp    59b4 <botlish_fn_19+0x462c>
    599b:	mov    $0x2,%ecx
    59a0:	mov    0x480(%rsp),%rsi
    59a8:	cmp    $0xffffffffffffffff,%rsi
    59ac:	cmovl  0x4e24(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    59b4:	cmp    $0x6,%rcx
    59b8:	je     59c9 <botlish_fn_19+0x4641>
    59be:	mov    $0x15,%r14d
    59c4:	jmp    6a55 <botlish_fn_19+0x56cd>
    59c9:	mov    $0x23,%r14d
    59cf:	jmp    6a55 <botlish_fn_19+0x56cd>
    59d4:	cmp    $0x5,%r14
    59d8:	jl     5bf9 <botlish_fn_19+0x4871>
    59de:	mov    0x480(%rsp),%rsi
    59e6:	test   $0x1,%rsi
    59ed:	jne    5a22 <botlish_fn_19+0x469a>
    59f3:	mov    $0x5b,%edx
    59f8:	mov    0x480(%rsp),%rsi
    5a00:	mov    0x458(%rsp),%rdi
    5a08:	call   5a0d <botlish_fn_19+0x4685>
			5a09: R_X86_64_PLT32	rt_int_cmp-0x4
    5a0d:	mov    $0x2,%ecx
    5a12:	test   %rax,%rax
    5a15:	cmovl  0x4dbb(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5a1d:	jmp    5a3b <botlish_fn_19+0x46b3>
    5a22:	mov    $0x2,%ecx
    5a27:	mov    0x480(%rsp),%rsi
    5a2f:	cmp    $0x5b,%rsi
    5a33:	cmovl  0x4d9d(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5a3b:	cmp    $0x6,%rcx
    5a3f:	je     5b59 <botlish_fn_19+0x47d1>
    5a45:	mov    0x480(%rsp),%rsi
    5a4d:	test   $0x1,%rsi
    5a54:	jne    5a8a <botlish_fn_19+0x4702>
    5a5a:	mov    $0x61,%edx
    5a5f:	mov    0x480(%rsp),%rsi
    5a67:	mov    0x458(%rsp),%rdi
    5a6f:	call   5a74 <botlish_fn_19+0x46ec>
			5a70: R_X86_64_PLT32	rt_int_cmp-0x4
    5a74:	mov    $0x2,%r11d
    5a7a:	test   %rax,%rax
    5a7d:	cmovl  0x4d53(%rip),%r11        # a7d8 <botlish_fn_19+0x9450>
    5a85:	jmp    5aa4 <botlish_fn_19+0x471c>
    5a8a:	mov    $0x2,%r11d
    5a90:	mov    0x480(%rsp),%rsi
    5a98:	cmp    $0x61,%rsi
    5a9c:	cmovl  0x4d34(%rip),%r11        # a7d8 <botlish_fn_19+0x9450>
    5aa4:	cmp    $0x6,%r11
    5aa8:	je     5b2b <botlish_fn_19+0x47a3>
    5aae:	mov    0x480(%rsp),%rsi
    5ab6:	test   $0x1,%rsi
    5abd:	jne    5af2 <botlish_fn_19+0x476a>
    5ac3:	mov    $0x75,%edx
    5ac8:	mov    0x480(%rsp),%rsi
    5ad0:	mov    0x458(%rsp),%rdi
    5ad8:	call   5add <botlish_fn_19+0x4755>
			5ad9: R_X86_64_PLT32	rt_int_cmp-0x4
    5add:	mov    $0x2,%ecx
    5ae2:	test   %rax,%rax
    5ae5:	cmovl  0x4ceb(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5aed:	jmp    5b0b <botlish_fn_19+0x4783>
    5af2:	mov    $0x2,%ecx
    5af7:	mov    0x480(%rsp),%rsi
    5aff:	cmp    $0x75,%rsi
    5b03:	cmovl  0x4ccd(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5b0b:	cmp    $0x6,%rcx
    5b0f:	je     5b20 <botlish_fn_19+0x4798>
    5b15:	mov    $0x21,%r14d
    5b1b:	jmp    6a55 <botlish_fn_19+0x56cd>
    5b20:	mov    $0x11,%r14d
    5b26:	jmp    6a55 <botlish_fn_19+0x56cd>
    5b2b:	mov    0x480(%rsp),%rsi
    5b33:	mov    %rsi,%rax
    5b36:	sar    $1,%rax
    5b39:	cmp    $0x2e,%rax
    5b3d:	jl     5b4e <botlish_fn_19+0x47c6>
    5b43:	mov    $0x21,%r14d
    5b49:	jmp    6a55 <botlish_fn_19+0x56cd>
    5b4e:	mov    $0xf,%r14d
    5b54:	jmp    6a55 <botlish_fn_19+0x56cd>
    5b59:	mov    0x480(%rsp),%rsi
    5b61:	test   $0x1,%rsi
    5b68:	jne    5b9d <botlish_fn_19+0x4815>
    5b6e:	mov    $0x57,%edx
    5b73:	mov    0x480(%rsp),%rsi
    5b7b:	mov    0x458(%rsp),%rdi
    5b83:	call   5b88 <botlish_fn_19+0x4800>
			5b84: R_X86_64_PLT32	rt_int_cmp-0x4
    5b88:	mov    $0x2,%ecx
    5b8d:	test   %rax,%rax
    5b90:	cmovl  0x4c40(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5b98:	jmp    5bb6 <botlish_fn_19+0x482e>
    5b9d:	mov    $0x2,%ecx
    5ba2:	mov    0x480(%rsp),%rsi
    5baa:	cmp    $0x57,%rsi
    5bae:	cmovl  0x4c22(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5bb6:	cmp    $0x6,%rcx
    5bba:	je     5bee <botlish_fn_19+0x4866>
    5bc0:	mov    0x480(%rsp),%rsi
    5bc8:	mov    %rsi,%rdx
    5bcb:	sar    $1,%rdx
    5bce:	cmp    $0x2c,%rdx
    5bd2:	jl     5be3 <botlish_fn_19+0x485b>
    5bd8:	mov    $0x21,%r14d
    5bde:	jmp    6a55 <botlish_fn_19+0x56cd>
    5be3:	mov    $0xf,%r14d
    5be9:	jmp    6a55 <botlish_fn_19+0x56cd>
    5bee:	mov    $0x21,%r14d
    5bf4:	jmp    6a55 <botlish_fn_19+0x56cd>
    5bf9:	mov    0x480(%rsp),%rsi
    5c01:	test   $0x1,%rsi
    5c08:	jne    5c3e <botlish_fn_19+0x48b6>
    5c0e:	mov    $0x61,%edx
    5c13:	mov    0x480(%rsp),%rsi
    5c1b:	mov    0x458(%rsp),%rdi
    5c23:	call   5c28 <botlish_fn_19+0x48a0>
			5c24: R_X86_64_PLT32	rt_int_cmp-0x4
    5c28:	mov    $0x2,%r8d
    5c2e:	test   %rax,%rax
    5c31:	cmovl  0x4b9f(%rip),%r8        # a7d8 <botlish_fn_19+0x9450>
    5c39:	jmp    5c58 <botlish_fn_19+0x48d0>
    5c3e:	mov    $0x2,%r8d
    5c44:	mov    0x480(%rsp),%rsi
    5c4c:	cmp    $0x61,%rsi
    5c50:	cmovl  0x4b80(%rip),%r8        # a7d8 <botlish_fn_19+0x9450>
    5c58:	cmp    $0x6,%r8
    5c5c:	je     5cdf <botlish_fn_19+0x4957>
    5c62:	mov    0x480(%rsp),%rsi
    5c6a:	test   $0x1,%rsi
    5c71:	jne    5ca6 <botlish_fn_19+0x491e>
    5c77:	mov    $0x75,%edx
    5c7c:	mov    0x480(%rsp),%rsi
    5c84:	mov    0x458(%rsp),%rdi
    5c8c:	call   5c91 <botlish_fn_19+0x4909>
			5c8d: R_X86_64_PLT32	rt_int_cmp-0x4
    5c91:	mov    $0x2,%ecx
    5c96:	test   %rax,%rax
    5c99:	cmovl  0x4b37(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5ca1:	jmp    5cbf <botlish_fn_19+0x4937>
    5ca6:	mov    $0x2,%ecx
    5cab:	mov    0x480(%rsp),%rsi
    5cb3:	cmp    $0x75,%rsi
    5cb7:	cmovl  0x4b19(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5cbf:	cmp    $0x6,%rcx
    5cc3:	je     5cd4 <botlish_fn_19+0x494c>
    5cc9:	mov    $0x1f,%r14d
    5ccf:	jmp    6a55 <botlish_fn_19+0x56cd>
    5cd4:	mov    $0xd,%r14d
    5cda:	jmp    6a55 <botlish_fn_19+0x56cd>
    5cdf:	mov    $0x1f,%r14d
    5ce5:	jmp    6a55 <botlish_fn_19+0x56cd>
    5cea:	cmp    $0x2,%r14
    5cee:	jl     66f4 <botlish_fn_19+0x536c>
    5cf4:	cmp    $0x3,%r14
    5cf8:	jl     620e <botlish_fn_19+0x4e86>
    5cfe:	mov    0x480(%rsp),%rsi
    5d06:	test   $0x1,%rsi
    5d0d:	jne    5d42 <botlish_fn_19+0x49ba>
    5d13:	mov    $0x5d,%edx
    5d18:	mov    0x480(%rsp),%rsi
    5d20:	mov    0x458(%rsp),%rdi
    5d28:	call   5d2d <botlish_fn_19+0x49a5>
			5d29: R_X86_64_PLT32	rt_int_cmp-0x4
    5d2d:	mov    $0x2,%ecx
    5d32:	test   %rax,%rax
    5d35:	cmovl  0x4a9b(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5d3d:	jmp    5d5b <botlish_fn_19+0x49d3>
    5d42:	mov    $0x2,%ecx
    5d47:	mov    0x480(%rsp),%rsi
    5d4f:	cmp    $0x5d,%rsi
    5d53:	cmovl  0x4a7d(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5d5b:	cmp    $0x6,%rcx
    5d5f:	je     5ff4 <botlish_fn_19+0x4c6c>
    5d65:	mov    0x480(%rsp),%rsi
    5d6d:	test   $0x1,%rsi
    5d74:	jne    5da9 <botlish_fn_19+0x4a21>
    5d7a:	mov    $0xbb,%edx
    5d7f:	mov    0x480(%rsp),%rsi
    5d87:	mov    0x458(%rsp),%rdi
    5d8f:	call   5d94 <botlish_fn_19+0x4a0c>
			5d90: R_X86_64_PLT32	rt_int_cmp-0x4
    5d94:	mov    $0x2,%ecx
    5d99:	test   %rax,%rax
    5d9c:	cmovl  0x4a34(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5da4:	jmp    5dc5 <botlish_fn_19+0x4a3d>
    5da9:	mov    $0x2,%ecx
    5dae:	mov    0x480(%rsp),%rsi
    5db6:	cmp    $0xbb,%rsi
    5dbd:	cmovl  0x4a13(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5dc5:	cmp    $0x6,%rcx
    5dc9:	je     5f70 <botlish_fn_19+0x4be8>
    5dcf:	mov    0x480(%rsp),%rsi
    5dd7:	test   $0x1,%rsi
    5dde:	jne    5e13 <botlish_fn_19+0x4a8b>
    5de4:	mov    $0xcd,%edx
    5de9:	mov    0x480(%rsp),%rsi
    5df1:	mov    0x458(%rsp),%rdi
    5df9:	call   5dfe <botlish_fn_19+0x4a76>
			5dfa: R_X86_64_PLT32	rt_int_cmp-0x4
    5dfe:	mov    $0x2,%esi
    5e03:	test   %rax,%rax
    5e06:	cmovl  0x49ca(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    5e0e:	jmp    5e2e <botlish_fn_19+0x4aa6>
    5e13:	mov    $0x2,%esi
    5e18:	mov    0x480(%rsp),%rax
    5e20:	cmp    $0xcd,%rax
    5e26:	cmovl  0x49aa(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    5e2e:	cmp    $0x6,%rsi
    5e32:	je     5f2d <botlish_fn_19+0x4ba5>
    5e38:	mov    0x480(%rsp),%rsi
    5e40:	test   $0x1,%rsi
    5e47:	jne    5e7c <botlish_fn_19+0x4af4>
    5e4d:	mov    $0xfb,%edx
    5e52:	mov    0x480(%rsp),%rsi
    5e5a:	mov    0x458(%rsp),%rdi
    5e62:	call   5e67 <botlish_fn_19+0x4adf>
			5e63: R_X86_64_PLT32	rt_int_cmp-0x4
    5e67:	mov    $0x2,%ecx
    5e6c:	test   %rax,%rax
    5e6f:	cmovl  0x4961(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5e77:	jmp    5e98 <botlish_fn_19+0x4b10>
    5e7c:	mov    $0x2,%ecx
    5e81:	mov    0x480(%rsp),%rsi
    5e89:	cmp    $0xfb,%rsi
    5e90:	cmovl  0x4940(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5e98:	cmp    $0x6,%rcx
    5e9c:	je     5f22 <botlish_fn_19+0x4b9a>
    5ea2:	mov    0x480(%rsp),%rsi
    5eaa:	test   $0x1,%rsi
    5eb1:	jne    5ee6 <botlish_fn_19+0x4b5e>
    5eb7:	mov    $0xfd,%edx
    5ebc:	mov    0x480(%rsp),%rsi
    5ec4:	mov    0x458(%rsp),%rdi
    5ecc:	call   5ed1 <botlish_fn_19+0x4b49>
			5ecd: R_X86_64_PLT32	rt_int_cmp-0x4
    5ed1:	mov    $0x2,%ecx
    5ed6:	test   %rax,%rax
    5ed9:	cmovl  0x48f7(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5ee1:	jmp    5f02 <botlish_fn_19+0x4b7a>
    5ee6:	mov    $0x2,%ecx
    5eeb:	mov    0x480(%rsp),%rsi
    5ef3:	cmp    $0xfd,%rsi
    5efa:	cmovl  0x48d6(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    5f02:	cmp    $0x6,%rcx
    5f06:	je     5f17 <botlish_fn_19+0x4b8f>
    5f0c:	mov    $0x1d,%r14d
    5f12:	jmp    6a55 <botlish_fn_19+0x56cd>
    5f17:	mov    $0x15,%r14d
    5f1d:	jmp    6a55 <botlish_fn_19+0x56cd>
    5f22:	mov    $0x1d,%r14d
    5f28:	jmp    6a55 <botlish_fn_19+0x56cd>
    5f2d:	mov    0x480(%rsp),%rsi
    5f35:	mov    %rsi,%rax
    5f38:	sar    $1,%rax
    5f3b:	cmp    $0x5e,%rax
    5f3f:	jl     5f65 <botlish_fn_19+0x4bdd>
    5f45:	cmp    $0x65,%rax
    5f49:	jl     5f5a <botlish_fn_19+0x4bd2>
    5f4f:	mov    $0xb,%r14d
    5f55:	jmp    6a55 <botlish_fn_19+0x56cd>
    5f5a:	mov    $0x1d,%r14d
    5f60:	jmp    6a55 <botlish_fn_19+0x56cd>
    5f65:	mov    $0x15,%r14d
    5f6b:	jmp    6a55 <botlish_fn_19+0x56cd>
    5f70:	mov    0x480(%rsp),%rsi
    5f78:	mov    %rsi,%rax
    5f7b:	sar    $1,%rax
    5f7e:	cmp    $0x3a,%rax
    5f82:	jl     5fbd <botlish_fn_19+0x4c35>
    5f88:	cmp    $0x45,%rax
    5f8c:	jl     5fb2 <botlish_fn_19+0x4c2a>
    5f92:	cmp    $0x46,%rax
    5f96:	jl     5fa7 <botlish_fn_19+0x4c1f>
    5f9c:	mov    $0x1d,%r14d
    5fa2:	jmp    6a55 <botlish_fn_19+0x56cd>
    5fa7:	mov    $0xb,%r14d
    5fad:	jmp    6a55 <botlish_fn_19+0x56cd>
    5fb2:	mov    $0x1d,%r14d
    5fb8:	jmp    6a55 <botlish_fn_19+0x56cd>
    5fbd:	cmp    $0x2f,%rax
    5fc1:	jl     5fe9 <botlish_fn_19+0x4c61>
    5fc7:	cmp    $0x30,%rax
    5fcb:	jl     5fde <botlish_fn_19+0x4c56>
    5fd1:	mov    0x4f8(%rsp),%r14
    5fd9:	jmp    6a55 <botlish_fn_19+0x56cd>
    5fde:	mov    $0x1d,%r14d
    5fe4:	jmp    6a55 <botlish_fn_19+0x56cd>
    5fe9:	mov    $0x9,%r14d
    5fef:	jmp    6a55 <botlish_fn_19+0x56cd>
    5ff4:	mov    0x480(%rsp),%rsi
    5ffc:	test   $0x1,%rsi
    6003:	jne    6038 <botlish_fn_19+0x4cb0>
    6009:	mov    $0x1b,%edx
    600e:	mov    0x480(%rsp),%rsi
    6016:	mov    0x458(%rsp),%rdi
    601e:	call   6023 <botlish_fn_19+0x4c9b>
			601f: R_X86_64_PLT32	rt_int_cmp-0x4
    6023:	mov    $0x2,%ecx
    6028:	test   %rax,%rax
    602b:	cmovl  0x47a5(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6033:	jmp    6051 <botlish_fn_19+0x4cc9>
    6038:	mov    $0x2,%ecx
    603d:	mov    0x480(%rsp),%rsi
    6045:	cmp    $0x1b,%rsi
    6049:	cmovl  0x4787(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6051:	cmp    $0x6,%rcx
    6055:	je     60dd <botlish_fn_19+0x4d55>
    605b:	mov    0x480(%rsp),%rsi
    6063:	mov    %rsi,%rax
    6066:	sar    $1,%rax
    6069:	cmp    $0x21,%rax
    606d:	jl     60a8 <botlish_fn_19+0x4d20>
    6073:	cmp    $0x2c,%rax
    6077:	jl     609d <botlish_fn_19+0x4d15>
    607d:	cmp    $0x2d,%rax
    6081:	jl     6092 <botlish_fn_19+0x4d0a>
    6087:	mov    $0x1d,%r14d
    608d:	jmp    6a55 <botlish_fn_19+0x56cd>
    6092:	mov    $0x15,%r14d
    6098:	jmp    6a55 <botlish_fn_19+0x56cd>
    609d:	mov    $0x1d,%r14d
    60a3:	jmp    6a55 <botlish_fn_19+0x56cd>
    60a8:	cmp    $0xe,%rax
    60ac:	jl     60d2 <botlish_fn_19+0x4d4a>
    60b2:	cmp    $0x20,%rax
    60b6:	jl     60c7 <botlish_fn_19+0x4d3f>
    60bc:	mov    $0x15,%r14d
    60c2:	jmp    6a55 <botlish_fn_19+0x56cd>
    60c7:	mov    $0x1d,%r14d
    60cd:	jmp    6a55 <botlish_fn_19+0x56cd>
    60d2:	mov    $0x15,%r14d
    60d8:	jmp    6a55 <botlish_fn_19+0x56cd>
    60dd:	mov    0x480(%rsp),%rsi
    60e5:	test   $0x1,%rsi
    60ec:	jne    6121 <botlish_fn_19+0x4d99>
    60f2:	mov    $0x1,%edx
    60f7:	mov    0x480(%rsp),%rsi
    60ff:	mov    0x458(%rsp),%rdi
    6107:	call   610c <botlish_fn_19+0x4d84>
			6108: R_X86_64_PLT32	rt_int_cmp-0x4
    610c:	mov    $0x2,%ecx
    6111:	test   %rax,%rax
    6114:	cmovl  0x46bc(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    611c:	jmp    6141 <botlish_fn_19+0x4db9>
    6121:	mov    $0x2,%ecx
    6126:	mov    0x480(%rsp),%rax
    612e:	mov    0x480(%rsp),%rsi
    6136:	test   %rax,%rsi
    6139:	cmovle 0x4697(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6141:	cmp    $0x6,%rcx
    6145:	je     618e <botlish_fn_19+0x4e06>
    614b:	mov    0x480(%rsp),%rsi
    6153:	mov    %rsi,%rax
    6156:	sar    $1,%rax
    6159:	cmp    $0x9,%rax
    615d:	jl     6183 <botlish_fn_19+0x4dfb>
    6163:	cmp    $0xb,%rax
    6167:	jl     6178 <botlish_fn_19+0x4df0>
    616d:	mov    $0x1d,%r14d
    6173:	jmp    6a55 <botlish_fn_19+0x56cd>
    6178:	mov    $0x15,%r14d
    617e:	jmp    6a55 <botlish_fn_19+0x56cd>
    6183:	mov    $0x1d,%r14d
    6189:	jmp    6a55 <botlish_fn_19+0x56cd>
    618e:	mov    0x480(%rsp),%rsi
    6196:	test   $0x1,%rsi
    619d:	jne    61d5 <botlish_fn_19+0x4e4d>
    61a3:	mov    0x500(%rsp),%rdx
    61ab:	mov    0x480(%rsp),%rsi
    61b3:	mov    0x458(%rsp),%rdi
    61bb:	call   61c0 <botlish_fn_19+0x4e38>
			61bc: R_X86_64_PLT32	rt_int_cmp-0x4
    61c0:	mov    $0x2,%ecx
    61c5:	test   %rax,%rax
    61c8:	cmovl  0x4608(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    61d0:	jmp    61ee <botlish_fn_19+0x4e66>
    61d5:	mov    $0x2,%ecx
    61da:	mov    0x480(%rsp),%rsi
    61e2:	cmp    $0xffffffffffffffff,%rsi
    61e6:	cmovl  0x45ea(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    61ee:	cmp    $0x6,%rcx
    61f2:	je     6203 <botlish_fn_19+0x4e7b>
    61f8:	mov    $0x15,%r14d
    61fe:	jmp    6a55 <botlish_fn_19+0x56cd>
    6203:	mov    $0x1d,%r14d
    6209:	jmp    6a55 <botlish_fn_19+0x56cd>
    620e:	mov    0x480(%rsp),%rsi
    6216:	test   $0x1,%rsi
    621d:	jne    6253 <botlish_fn_19+0x4ecb>
    6223:	mov    $0x5b,%edx
    6228:	mov    0x480(%rsp),%rsi
    6230:	mov    0x458(%rsp),%rdi
    6238:	call   623d <botlish_fn_19+0x4eb5>
			6239: R_X86_64_PLT32	rt_int_cmp-0x4
    623d:	mov    $0x2,%r11d
    6243:	test   %rax,%rax
    6246:	cmovl  0x458a(%rip),%r11        # a7d8 <botlish_fn_19+0x9450>
    624e:	jmp    626d <botlish_fn_19+0x4ee5>
    6253:	mov    $0x2,%r11d
    6259:	mov    0x480(%rsp),%rsi
    6261:	cmp    $0x5b,%rsi
    6265:	cmovl  0x456b(%rip),%r11        # a7d8 <botlish_fn_19+0x9450>
    626d:	cmp    $0x6,%r11
    6271:	je     64f2 <botlish_fn_19+0x516a>
    6277:	mov    0x480(%rsp),%rsi
    627f:	test   $0x1,%rsi
    6286:	jne    62bb <botlish_fn_19+0x4f33>
    628c:	mov    $0xbb,%edx
    6291:	mov    0x480(%rsp),%rsi
    6299:	mov    0x458(%rsp),%rdi
    62a1:	call   62a6 <botlish_fn_19+0x4f1e>
			62a2: R_X86_64_PLT32	rt_int_cmp-0x4
    62a6:	mov    $0x2,%ecx
    62ab:	test   %rax,%rax
    62ae:	cmovl  0x4522(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    62b6:	jmp    62d7 <botlish_fn_19+0x4f4f>
    62bb:	mov    $0x2,%ecx
    62c0:	mov    0x480(%rsp),%rsi
    62c8:	cmp    $0xbb,%rsi
    62cf:	cmovl  0x4501(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    62d7:	cmp    $0x6,%rcx
    62db:	je     6485 <botlish_fn_19+0x50fd>
    62e1:	mov    0x480(%rsp),%rsi
    62e9:	test   $0x1,%rsi
    62f0:	jne    6325 <botlish_fn_19+0x4f9d>
    62f6:	mov    $0xcd,%edx
    62fb:	mov    0x480(%rsp),%rsi
    6303:	mov    0x458(%rsp),%rdi
    630b:	call   6310 <botlish_fn_19+0x4f88>
			630c: R_X86_64_PLT32	rt_int_cmp-0x4
    6310:	mov    $0x2,%ecx
    6315:	test   %rax,%rax
    6318:	cmovl  0x44b8(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6320:	jmp    6341 <botlish_fn_19+0x4fb9>
    6325:	mov    $0x2,%ecx
    632a:	mov    0x480(%rsp),%rsi
    6332:	cmp    $0xcd,%rsi
    6339:	cmovl  0x4497(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6341:	cmp    $0x6,%rcx
    6345:	je     6442 <botlish_fn_19+0x50ba>
    634b:	mov    0x480(%rsp),%rsi
    6353:	test   $0x1,%rsi
    635a:	jne    6390 <botlish_fn_19+0x5008>
    6360:	mov    $0xfb,%edx
    6365:	mov    0x480(%rsp),%rsi
    636d:	mov    0x458(%rsp),%rdi
    6375:	call   637a <botlish_fn_19+0x4ff2>
			6376: R_X86_64_PLT32	rt_int_cmp-0x4
    637a:	mov    $0x2,%r11d
    6380:	test   %rax,%rax
    6383:	cmovl  0x444d(%rip),%r11        # a7d8 <botlish_fn_19+0x9450>
    638b:	jmp    63ad <botlish_fn_19+0x5025>
    6390:	mov    $0x2,%r11d
    6396:	mov    0x480(%rsp),%rsi
    639e:	cmp    $0xfb,%rsi
    63a5:	cmovl  0x442b(%rip),%r11        # a7d8 <botlish_fn_19+0x9450>
    63ad:	cmp    $0x6,%r11
    63b1:	je     6437 <botlish_fn_19+0x50af>
    63b7:	mov    0x480(%rsp),%rsi
    63bf:	test   $0x1,%rsi
    63c6:	jne    63fb <botlish_fn_19+0x5073>
    63cc:	mov    $0xfd,%edx
    63d1:	mov    0x480(%rsp),%rsi
    63d9:	mov    0x458(%rsp),%rdi
    63e1:	call   63e6 <botlish_fn_19+0x505e>
			63e2: R_X86_64_PLT32	rt_int_cmp-0x4
    63e6:	mov    $0x2,%ecx
    63eb:	test   %rax,%rax
    63ee:	cmovl  0x43e2(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    63f6:	jmp    6417 <botlish_fn_19+0x508f>
    63fb:	mov    $0x2,%ecx
    6400:	mov    0x480(%rsp),%rsi
    6408:	cmp    $0xfd,%rsi
    640f:	cmovl  0x43c1(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6417:	cmp    $0x6,%rcx
    641b:	je     642c <botlish_fn_19+0x50a4>
    6421:	mov    $0x1b,%r14d
    6427:	jmp    6a55 <botlish_fn_19+0x56cd>
    642c:	mov    $0x15,%r14d
    6432:	jmp    6a55 <botlish_fn_19+0x56cd>
    6437:	mov    $0x1b,%r14d
    643d:	jmp    6a55 <botlish_fn_19+0x56cd>
    6442:	mov    0x480(%rsp),%rsi
    644a:	mov    %rsi,%rax
    644d:	sar    $1,%rax
    6450:	cmp    $0x5e,%rax
    6454:	jl     647a <botlish_fn_19+0x50f2>
    645a:	cmp    $0x65,%rax
    645e:	jl     646f <botlish_fn_19+0x50e7>
    6464:	mov    $0xb,%r14d
    646a:	jmp    6a55 <botlish_fn_19+0x56cd>
    646f:	mov    $0x1b,%r14d
    6475:	jmp    6a55 <botlish_fn_19+0x56cd>
    647a:	mov    $0x15,%r14d
    6480:	jmp    6a55 <botlish_fn_19+0x56cd>
    6485:	mov    0x480(%rsp),%rsi
    648d:	mov    %rsi,%rax
    6490:	sar    $1,%rax
    6493:	cmp    $0x2f,%rax
    6497:	jl     64d2 <botlish_fn_19+0x514a>
    649d:	cmp    $0x45,%rax
    64a1:	jl     64c7 <botlish_fn_19+0x513f>
    64a7:	cmp    $0x46,%rax
    64ab:	jl     64bc <botlish_fn_19+0x5134>
    64b1:	mov    $0x1b,%r14d
    64b7:	jmp    6a55 <botlish_fn_19+0x56cd>
    64bc:	mov    $0xb,%r14d
    64c2:	jmp    6a55 <botlish_fn_19+0x56cd>
    64c7:	mov    $0x1b,%r14d
    64cd:	jmp    6a55 <botlish_fn_19+0x56cd>
    64d2:	cmp    $0x2e,%rax
    64d6:	jl     64e7 <botlish_fn_19+0x515f>
    64dc:	mov    $0x9,%r14d
    64e2:	jmp    6a55 <botlish_fn_19+0x56cd>
    64e7:	mov    $0x1b,%r14d
    64ed:	jmp    6a55 <botlish_fn_19+0x56cd>
    64f2:	mov    0x480(%rsp),%rsi
    64fa:	test   $0x1,%rsi
    6501:	jne    6536 <botlish_fn_19+0x51ae>
    6507:	mov    $0x1b,%edx
    650c:	mov    0x480(%rsp),%rsi
    6514:	mov    0x458(%rsp),%rdi
    651c:	call   6521 <botlish_fn_19+0x5199>
			651d: R_X86_64_PLT32	rt_int_cmp-0x4
    6521:	mov    $0x2,%edx
    6526:	test   %rax,%rax
    6529:	cmovl  0x42a7(%rip),%rdx        # a7d8 <botlish_fn_19+0x9450>
    6531:	jmp    654f <botlish_fn_19+0x51c7>
    6536:	mov    $0x2,%edx
    653b:	mov    0x480(%rsp),%rsi
    6543:	cmp    $0x1b,%rsi
    6547:	cmovl  0x4289(%rip),%rdx        # a7d8 <botlish_fn_19+0x9450>
    654f:	cmp    $0x6,%rdx
    6553:	je     65c3 <botlish_fn_19+0x523b>
    6559:	mov    0x480(%rsp),%rsi
    6561:	sar    $1,%rsi
    6564:	cmp    $0x20,%rsi
    6568:	jl     65a3 <botlish_fn_19+0x521b>
    656e:	cmp    $0x21,%rsi
    6572:	jl     6598 <botlish_fn_19+0x5210>
    6578:	cmp    $0x2c,%rsi
    657c:	jl     658d <botlish_fn_19+0x5205>
    6582:	mov    $0x15,%r14d
    6588:	jmp    6a55 <botlish_fn_19+0x56cd>
    658d:	mov    $0x1b,%r14d
    6593:	jmp    6a55 <botlish_fn_19+0x56cd>
    6598:	mov    $0x15,%r14d
    659e:	jmp    6a55 <botlish_fn_19+0x56cd>
    65a3:	cmp    $0xe,%rsi
    65a7:	jl     65b8 <botlish_fn_19+0x5230>
    65ad:	mov    $0x1b,%r14d
    65b3:	jmp    6a55 <botlish_fn_19+0x56cd>
    65b8:	mov    $0x15,%r14d
    65be:	jmp    6a55 <botlish_fn_19+0x56cd>
    65c3:	mov    0x480(%rsp),%rsi
    65cb:	test   $0x1,%rsi
    65d2:	jne    6607 <botlish_fn_19+0x527f>
    65d8:	mov    $0x1,%edx
    65dd:	mov    0x480(%rsp),%rsi
    65e5:	mov    0x458(%rsp),%rdi
    65ed:	call   65f2 <botlish_fn_19+0x526a>
			65ee: R_X86_64_PLT32	rt_int_cmp-0x4
    65f2:	mov    $0x2,%ecx
    65f7:	test   %rax,%rax
    65fa:	cmovl  0x41d6(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6602:	jmp    6627 <botlish_fn_19+0x529f>
    6607:	mov    $0x2,%ecx
    660c:	mov    0x480(%rsp),%rsi
    6614:	mov    0x480(%rsp),%r9
    661c:	test   %r9,%rsi
    661f:	cmovle 0x41b1(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6627:	cmp    $0x6,%rcx
    662b:	je     6674 <botlish_fn_19+0x52ec>
    6631:	mov    0x480(%rsp),%rsi
    6639:	mov    %rsi,%rax
    663c:	sar    $1,%rax
    663f:	cmp    $0x9,%rax
    6643:	jl     6669 <botlish_fn_19+0x52e1>
    6649:	cmp    $0xb,%rax
    664d:	jl     665e <botlish_fn_19+0x52d6>
    6653:	mov    $0x1b,%r14d
    6659:	jmp    6a55 <botlish_fn_19+0x56cd>
    665e:	mov    $0x15,%r14d
    6664:	jmp    6a55 <botlish_fn_19+0x56cd>
    6669:	mov    $0x1b,%r14d
    666f:	jmp    6a55 <botlish_fn_19+0x56cd>
    6674:	mov    0x480(%rsp),%rsi
    667c:	test   $0x1,%rsi
    6683:	jne    66bb <botlish_fn_19+0x5333>
    6689:	mov    0x500(%rsp),%rdx
    6691:	mov    0x480(%rsp),%rsi
    6699:	mov    0x458(%rsp),%rdi
    66a1:	call   66a6 <botlish_fn_19+0x531e>
			66a2: R_X86_64_PLT32	rt_int_cmp-0x4
    66a6:	mov    $0x2,%esi
    66ab:	test   %rax,%rax
    66ae:	cmovl  0x4122(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    66b6:	jmp    66d4 <botlish_fn_19+0x534c>
    66bb:	mov    $0x2,%esi
    66c0:	mov    0x480(%rsp),%rax
    66c8:	cmp    $0xffffffffffffffff,%rax
    66cc:	cmovl  0x4104(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    66d4:	cmp    $0x6,%rsi
    66d8:	je     66e9 <botlish_fn_19+0x5361>
    66de:	mov    $0x15,%r14d
    66e4:	jmp    6a55 <botlish_fn_19+0x56cd>
    66e9:	mov    $0x1b,%r14d
    66ef:	jmp    6a55 <botlish_fn_19+0x56cd>
    66f4:	test   %r14,%r14
    66f7:	jle    6860 <botlish_fn_19+0x54d8>
    66fd:	mov    0x480(%rsp),%rsi
    6705:	test   $0x1,%rsi
    670c:	jne    6741 <botlish_fn_19+0x53b9>
    6712:	mov    $0x63,%edx
    6717:	mov    0x480(%rsp),%rsi
    671f:	mov    0x458(%rsp),%rdi
    6727:	call   672c <botlish_fn_19+0x53a4>
			6728: R_X86_64_PLT32	rt_int_cmp-0x4
    672c:	mov    $0x2,%ecx
    6731:	test   %rax,%rax
    6734:	cmovl  0x409c(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    673c:	jmp    675a <botlish_fn_19+0x53d2>
    6741:	mov    $0x2,%ecx
    6746:	mov    0x480(%rsp),%rsi
    674e:	cmp    $0x63,%rsi
    6752:	cmovl  0x407e(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    675a:	cmp    $0x6,%rcx
    675e:	je     67e3 <botlish_fn_19+0x545b>
    6764:	mov    0x480(%rsp),%rsi
    676c:	test   $0x1,%rsi
    6773:	jne    67a8 <botlish_fn_19+0x5420>
    6779:	mov    $0x75,%edx
    677e:	mov    0x480(%rsp),%rsi
    6786:	mov    0x458(%rsp),%rdi
    678e:	call   6793 <botlish_fn_19+0x540b>
			678f: R_X86_64_PLT32	rt_int_cmp-0x4
    6793:	mov    $0x2,%ecx
    6798:	test   %rax,%rax
    679b:	cmovl  0x4035(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    67a3:	jmp    67c1 <botlish_fn_19+0x5439>
    67a8:	mov    $0x2,%ecx
    67ad:	mov    0x480(%rsp),%rsi
    67b5:	cmp    $0x75,%rsi
    67b9:	cmovl  0x4017(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    67c1:	cmp    $0x6,%rcx
    67c5:	je     67d6 <botlish_fn_19+0x544e>
    67cb:	mov    $0x19,%r14d
    67d1:	jmp    6a55 <botlish_fn_19+0x56cd>
    67d6:	mov    0x4f8(%rsp),%r14
    67de:	jmp    6a55 <botlish_fn_19+0x56cd>
    67e3:	mov    0x480(%rsp),%rsi
    67eb:	test   $0x1,%rsi
    67f2:	jne    6827 <botlish_fn_19+0x549f>
    67f8:	mov    $0x61,%edx
    67fd:	mov    0x480(%rsp),%rsi
    6805:	mov    0x458(%rsp),%rdi
    680d:	call   6812 <botlish_fn_19+0x548a>
			680e: R_X86_64_PLT32	rt_int_cmp-0x4
    6812:	mov    $0x2,%ecx
    6817:	test   %rax,%rax
    681a:	cmovl  0x3fb6(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6822:	jmp    6840 <botlish_fn_19+0x54b8>
    6827:	mov    $0x2,%ecx
    682c:	mov    0x480(%rsp),%rsi
    6834:	cmp    $0x61,%rsi
    6838:	cmovl  0x3f98(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6840:	cmp    $0x6,%rcx
    6844:	je     6855 <botlish_fn_19+0x54cd>
    684a:	mov    $0x5,%r14d
    6850:	jmp    6a55 <botlish_fn_19+0x56cd>
    6855:	mov    $0x19,%r14d
    685b:	jmp    6a55 <botlish_fn_19+0x56cd>
    6860:	mov    0x480(%rsp),%rsi
    6868:	test   $0x1,%rsi
    686f:	jne    68a4 <botlish_fn_19+0x551c>
    6875:	mov    $0x61,%edx
    687a:	mov    0x480(%rsp),%rsi
    6882:	mov    0x458(%rsp),%rdi
    688a:	call   688f <botlish_fn_19+0x5507>
			688b: R_X86_64_PLT32	rt_int_cmp-0x4
    688f:	mov    $0x2,%ecx
    6894:	test   %rax,%rax
    6897:	cmovl  0x3f39(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    689f:	jmp    68bd <botlish_fn_19+0x5535>
    68a4:	mov    $0x2,%ecx
    68a9:	mov    0x480(%rsp),%rsi
    68b1:	cmp    $0x61,%rsi
    68b5:	cmovl  0x3f1b(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    68bd:	cmp    $0x6,%rcx
    68c1:	je     69b8 <botlish_fn_19+0x5630>
    68c7:	mov    0x480(%rsp),%rsi
    68cf:	test   $0x1,%rsi
    68d6:	jne    690b <botlish_fn_19+0x5583>
    68dc:	mov    $0x63,%edx
    68e1:	mov    0x480(%rsp),%rsi
    68e9:	mov    0x458(%rsp),%rdi
    68f1:	call   68f6 <botlish_fn_19+0x556e>
			68f2: R_X86_64_PLT32	rt_int_cmp-0x4
    68f6:	mov    $0x2,%ecx
    68fb:	test   %rax,%rax
    68fe:	cmovl  0x3ed2(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6906:	jmp    6924 <botlish_fn_19+0x559c>
    690b:	mov    $0x2,%ecx
    6910:	mov    0x480(%rsp),%rsi
    6918:	cmp    $0x63,%rsi
    691c:	cmovl  0x3eb4(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6924:	cmp    $0x6,%rcx
    6928:	je     69ad <botlish_fn_19+0x5625>
    692e:	mov    0x480(%rsp),%rsi
    6936:	test   $0x1,%rsi
    693d:	jne    6972 <botlish_fn_19+0x55ea>
    6943:	mov    $0x75,%edx
    6948:	mov    0x480(%rsp),%rsi
    6950:	mov    0x458(%rsp),%rdi
    6958:	call   695d <botlish_fn_19+0x55d5>
			6959: R_X86_64_PLT32	rt_int_cmp-0x4
    695d:	mov    $0x2,%ecx
    6962:	test   %rax,%rax
    6965:	cmovl  0x3e6b(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    696d:	jmp    698b <botlish_fn_19+0x5603>
    6972:	mov    $0x2,%ecx
    6977:	mov    0x480(%rsp),%rsi
    697f:	cmp    $0x75,%rsi
    6983:	cmovl  0x3e4d(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    698b:	cmp    $0x6,%rcx
    698f:	je     69a0 <botlish_fn_19+0x5618>
    6995:	mov    $0x17,%r14d
    699b:	jmp    6a55 <botlish_fn_19+0x56cd>
    69a0:	mov    0x4f8(%rsp),%r14
    69a8:	jmp    6a55 <botlish_fn_19+0x56cd>
    69ad:	mov    $0x5,%r14d
    69b3:	jmp    6a55 <botlish_fn_19+0x56cd>
    69b8:	mov    0x480(%rsp),%rsi
    69c0:	test   $0x1,%rsi
    69c7:	jne    69fc <botlish_fn_19+0x5674>
    69cd:	mov    $0x5b,%edx
    69d2:	mov    0x480(%rsp),%rsi
    69da:	mov    0x458(%rsp),%rdi
    69e2:	call   69e7 <botlish_fn_19+0x565f>
			69e3: R_X86_64_PLT32	rt_int_cmp-0x4
    69e7:	mov    $0x2,%ecx
    69ec:	test   %rax,%rax
    69ef:	cmovl  0x3de1(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    69f7:	jmp    6a15 <botlish_fn_19+0x568d>
    69fc:	mov    $0x2,%ecx
    6a01:	mov    0x480(%rsp),%rsi
    6a09:	cmp    $0x5b,%rsi
    6a0d:	cmovl  0x3dc3(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6a15:	cmp    $0x6,%rcx
    6a19:	je     6a4f <botlish_fn_19+0x56c7>
    6a1f:	mov    0x480(%rsp),%rsi
    6a27:	mov    %rsi,%rax
    6a2a:	sar    $1,%rax
    6a2d:	cmp    $0x2e,%rax
    6a31:	jl     6a42 <botlish_fn_19+0x56ba>
    6a37:	mov    $0x17,%r14d
    6a3d:	jmp    6a55 <botlish_fn_19+0x56cd>
    6a42:	mov    0x530(%rsp),%r14
    6a4a:	jmp    6a55 <botlish_fn_19+0x56cd>
    6a4f:	mov    $0x17,%r14d
    6a55:	mov    %r14,%rsi
    6a58:	sar    $1,%rsi
    6a5b:	cmp    $0x9,%rsi
    6a5f:	jl     6b99 <botlish_fn_19+0x5811>
    6a65:	cmp    $0xa,%rsi
    6a69:	mov    %rsi,%r12
    6a6c:	je     6b89 <botlish_fn_19+0x5801>
    6a72:	mov    0x480(%rsp),%rsi
    6a7a:	test   $0x1,%rsi
    6a81:	jne    6ab9 <botlish_fn_19+0x5731>
    6a87:	mov    0x500(%rsp),%rdx
    6a8f:	mov    0x480(%rsp),%rsi
    6a97:	mov    0x458(%rsp),%rdi
    6a9f:	call   6aa4 <botlish_fn_19+0x571c>
			6aa0: R_X86_64_PLT32	rt_int_cmp-0x4
    6aa4:	mov    $0x2,%ecx
    6aa9:	test   %rax,%rax
    6aac:	cmove  0x3d24(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6ab4:	jmp    6ad2 <botlish_fn_19+0x574a>
    6ab9:	mov    $0x2,%ecx
    6abe:	mov    0x480(%rsp),%rsi
    6ac6:	cmp    $0xffffffffffffffff,%rsi
    6aca:	cmove  0x3d06(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6ad2:	cmp    $0x6,%rcx
    6ad6:	je     6b39 <botlish_fn_19+0x57b1>
    6adc:	mov    %r12,%rsi
    6adf:	mov    0x458(%rsp),%rdi
    6ae7:	call   6aec <botlish_fn_19+0x5764>
			6ae8: R_X86_64_PLT32	botlish_fn_1-0x4
    6aec:	mov    0x458(%rsp),%rdi
    6af4:	mov    0x10(%rdi),%rcx
    6af8:	mov    0x1f8(%rcx),%rdx
    6aff:	lea    0x418(%rsp),%r9
    6b07:	mov    %rax,0x418(%rsp)
    6b0f:	mov    0x480(%rsp),%rsi
    6b17:	mov    %rsi,0x420(%rsp)
    6b1f:	mov    $0x1,%esi
    6b24:	mov    $0x8,%ecx
    6b29:	mov    $0x2,%r8d
    6b2f:	call   6b34 <botlish_fn_19+0x57ac>
			6b30: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6b34:	jmp    8cef <botlish_fn_19+0x7967>
    6b39:	mov    %r12,%rsi
    6b3c:	mov    0x458(%rsp),%rdi
    6b44:	call   6b49 <botlish_fn_19+0x57c1>
			6b45: R_X86_64_PLT32	botlish_fn_1-0x4
    6b49:	mov    0x458(%rsp),%rdi
    6b51:	mov    0x10(%rdi),%rcx
    6b55:	mov    0x1f0(%rcx),%rdx
    6b5c:	lea    0x410(%rsp),%r9
    6b64:	mov    %rax,0x410(%rsp)
    6b6c:	mov    $0x2,%esi
    6b71:	mov    $0x1,%r8d
    6b77:	mov    0x530(%rsp),%rcx
    6b7f:	call   6b84 <botlish_fn_19+0x57fc>
			6b80: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6b84:	jmp    8cef <botlish_fn_19+0x7967>
    6b89:	mov    %rbx,%r14
    6b8c:	mov    0x478(%rsp),%rbx
    6b94:	jmp    7153 <botlish_fn_19+0x5dcb>
    6b99:	mov    %r14,0xe0(%rsp)
    6ba1:	mov    $0x6,%r13d
    6ba7:	movq   $0x6,0xb8(%rsp)
    6bb3:	mov    $0x4,%ebx
    6bb8:	mov    0x478(%rsp),%r12
    6bc0:	jmp    8e95 <botlish_fn_19+0x7b0d>
    6bc5:	mov    %rsi,0x480(%rsp)
    6bcd:	mov    0x478(%rsp),%rbx
    6bd5:	mov    0x478(%rsp),%r12
    6bdd:	sar    $1,%r12
    6be0:	test   %r12,%r12
    6be3:	jle    6efa <botlish_fn_19+0x5b72>
    6be9:	mov    0x480(%rsp),%rsi
    6bf1:	test   $0x1,%rsi
    6bf8:	jne    6c2d <botlish_fn_19+0x58a5>
    6bfe:	mov    $0xb9,%edx
    6c03:	mov    0x480(%rsp),%rsi
    6c0b:	mov    0x458(%rsp),%rdi
    6c13:	call   6c18 <botlish_fn_19+0x5890>
			6c14: R_X86_64_PLT32	rt_int_cmp-0x4
    6c18:	mov    $0x2,%ecx
    6c1d:	test   %rax,%rax
    6c20:	cmovl  0x3bb0(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6c28:	jmp    6c49 <botlish_fn_19+0x58c1>
    6c2d:	mov    $0x2,%ecx
    6c32:	mov    0x480(%rsp),%rsi
    6c3a:	cmp    $0xb9,%rsi
    6c41:	cmovl  0x3b8f(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6c49:	cmp    $0x6,%rcx
    6c4d:	je     6de2 <botlish_fn_19+0x5a5a>
    6c53:	mov    0x480(%rsp),%rsi
    6c5b:	test   $0x1,%rsi
    6c62:	jne    6c97 <botlish_fn_19+0x590f>
    6c68:	mov    $0x101,%edx
    6c6d:	mov    0x480(%rsp),%rsi
    6c75:	mov    0x458(%rsp),%rdi
    6c7d:	call   6c82 <botlish_fn_19+0x58fa>
			6c7e: R_X86_64_PLT32	rt_int_cmp-0x4
    6c82:	mov    $0x2,%ecx
    6c87:	test   %rax,%rax
    6c8a:	cmovl  0x3b46(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6c92:	jmp    6cb3 <botlish_fn_19+0x592b>
    6c97:	mov    $0x2,%ecx
    6c9c:	mov    0x480(%rsp),%rsi
    6ca4:	cmp    $0x101,%rsi
    6cab:	cmovl  0x3b25(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6cb3:	cmp    $0x6,%rcx
    6cb7:	je     6db2 <botlish_fn_19+0x5a2a>
    6cbd:	mov    0x480(%rsp),%rsi
    6cc5:	test   $0x1,%rsi
    6ccc:	jne    6d01 <botlish_fn_19+0x5979>
    6cd2:	mov    $0x185,%edx
    6cd7:	mov    0x480(%rsp),%rsi
    6cdf:	mov    0x458(%rsp),%rdi
    6ce7:	call   6cec <botlish_fn_19+0x5964>
			6ce8: R_X86_64_PLT32	rt_int_cmp-0x4
    6cec:	mov    $0x2,%ecx
    6cf1:	test   %rax,%rax
    6cf4:	cmovl  0x3adc(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6cfc:	jmp    6d1d <botlish_fn_19+0x5995>
    6d01:	mov    $0x2,%ecx
    6d06:	mov    0x480(%rsp),%rsi
    6d0e:	cmp    $0x185,%rsi
    6d15:	cmovl  0x3abb(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6d1d:	cmp    $0x6,%rcx
    6d21:	je     6da7 <botlish_fn_19+0x5a1f>
    6d27:	mov    0x480(%rsp),%rsi
    6d2f:	test   $0x1,%rsi
    6d36:	jne    6d6b <botlish_fn_19+0x59e3>
    6d3c:	mov    $0x1eb,%edx
    6d41:	mov    0x480(%rsp),%rsi
    6d49:	mov    0x458(%rsp),%rdi
    6d51:	call   6d56 <botlish_fn_19+0x59ce>
			6d52: R_X86_64_PLT32	rt_int_cmp-0x4
    6d56:	mov    $0x2,%ecx
    6d5b:	test   %rax,%rax
    6d5e:	cmovl  0x3a72(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6d66:	jmp    6d87 <botlish_fn_19+0x59ff>
    6d6b:	mov    $0x2,%ecx
    6d70:	mov    0x480(%rsp),%rsi
    6d78:	cmp    $0x1eb,%rsi
    6d7f:	cmovl  0x3a51(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6d87:	cmp    $0x6,%rcx
    6d8b:	je     6d9c <botlish_fn_19+0x5a14>
    6d91:	mov    $0xf,%r12d
    6d97:	jmp    6fe6 <botlish_fn_19+0x5c5e>
    6d9c:	mov    $0xb,%r12d
    6da2:	jmp    6fe6 <botlish_fn_19+0x5c5e>
    6da7:	mov    $0xf,%r12d
    6dad:	jmp    6fe6 <botlish_fn_19+0x5c5e>
    6db2:	mov    0x480(%rsp),%rsi
    6dba:	mov    %rsi,%r8
    6dbd:	sar    $1,%r8
    6dc0:	cmp    $0x5d,%r8
    6dc4:	jl     6dd7 <botlish_fn_19+0x5a4f>
    6dca:	mov    0x530(%rsp),%r12
    6dd2:	jmp    6fe6 <botlish_fn_19+0x5c5e>
    6dd7:	mov    $0x9,%r12d
    6ddd:	jmp    6fe6 <botlish_fn_19+0x5c5e>
    6de2:	mov    0x480(%rsp),%rsi
    6dea:	test   $0x1,%rsi
    6df1:	jne    6e26 <botlish_fn_19+0x5a9e>
    6df7:	mov    $0x45,%edx
    6dfc:	mov    0x480(%rsp),%rsi
    6e04:	mov    0x458(%rsp),%rdi
    6e0c:	call   6e11 <botlish_fn_19+0x5a89>
			6e0d: R_X86_64_PLT32	rt_int_cmp-0x4
    6e11:	mov    $0x2,%ecx
    6e16:	test   %rax,%rax
    6e19:	cmovl  0x39b7(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6e21:	jmp    6e3f <botlish_fn_19+0x5ab7>
    6e26:	mov    $0x2,%ecx
    6e2b:	mov    0x480(%rsp),%rsi
    6e33:	cmp    $0x45,%rsi
    6e37:	cmovl  0x3999(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6e3f:	cmp    $0x6,%rcx
    6e43:	je     6e79 <botlish_fn_19+0x5af1>
    6e49:	mov    0x480(%rsp),%rsi
    6e51:	mov    %rsi,%rax
    6e54:	sar    $1,%rax
    6e57:	cmp    $0x23,%rax
    6e5b:	jl     6e6e <botlish_fn_19+0x5ae6>
    6e61:	mov    0x530(%rsp),%r12
    6e69:	jmp    6fe6 <botlish_fn_19+0x5c5e>
    6e6e:	mov    $0x5,%r12d
    6e74:	jmp    6fe6 <botlish_fn_19+0x5c5e>
    6e79:	mov    0x480(%rsp),%rsi
    6e81:	test   $0x1,%rsi
    6e88:	jne    6ebe <botlish_fn_19+0x5b36>
    6e8e:	mov    $0x41,%edx
    6e93:	mov    0x480(%rsp),%rsi
    6e9b:	mov    0x458(%rsp),%rdi
    6ea3:	call   6ea8 <botlish_fn_19+0x5b20>
			6ea4: R_X86_64_PLT32	rt_int_cmp-0x4
    6ea8:	mov    $0x2,%r8d
    6eae:	test   %rax,%rax
    6eb1:	cmovl  0x391f(%rip),%r8        # a7d8 <botlish_fn_19+0x9450>
    6eb9:	jmp    6ed8 <botlish_fn_19+0x5b50>
    6ebe:	mov    $0x2,%r8d
    6ec4:	mov    0x480(%rsp),%rsi
    6ecc:	cmp    $0x41,%rsi
    6ed0:	cmovl  0x3900(%rip),%r8        # a7d8 <botlish_fn_19+0x9450>
    6ed8:	cmp    $0x6,%r8
    6edc:	je     6eef <botlish_fn_19+0x5b67>
    6ee2:	mov    0x530(%rsp),%r12
    6eea:	jmp    6fe6 <botlish_fn_19+0x5c5e>
    6eef:	mov    $0xf,%r12d
    6ef5:	jmp    6fe6 <botlish_fn_19+0x5c5e>
    6efa:	mov    0x480(%rsp),%rsi
    6f02:	test   $0x1,%rsi
    6f09:	jne    6f3e <botlish_fn_19+0x5bb6>
    6f0f:	mov    $0x45,%edx
    6f14:	mov    0x480(%rsp),%rsi
    6f1c:	mov    0x458(%rsp),%rdi
    6f24:	call   6f29 <botlish_fn_19+0x5ba1>
			6f25: R_X86_64_PLT32	rt_int_cmp-0x4
    6f29:	mov    $0x2,%ecx
    6f2e:	test   %rax,%rax
    6f31:	cmovl  0x389f(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6f39:	jmp    6f57 <botlish_fn_19+0x5bcf>
    6f3e:	mov    $0x2,%ecx
    6f43:	mov    0x480(%rsp),%rsi
    6f4b:	cmp    $0x45,%rsi
    6f4f:	cmovl  0x3881(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6f57:	cmp    $0x6,%rcx
    6f5b:	je     6fe0 <botlish_fn_19+0x5c58>
    6f61:	mov    0x480(%rsp),%rsi
    6f69:	test   $0x1,%rsi
    6f70:	jne    6fa5 <botlish_fn_19+0x5c1d>
    6f76:	mov    $0x47,%edx
    6f7b:	mov    0x480(%rsp),%rsi
    6f83:	mov    0x458(%rsp),%rdi
    6f8b:	call   6f90 <botlish_fn_19+0x5c08>
			6f8c: R_X86_64_PLT32	rt_int_cmp-0x4
    6f90:	mov    $0x2,%ecx
    6f95:	test   %rax,%rax
    6f98:	cmovl  0x3838(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6fa0:	jmp    6fbe <botlish_fn_19+0x5c36>
    6fa5:	mov    $0x2,%ecx
    6faa:	mov    0x480(%rsp),%rsi
    6fb2:	cmp    $0x47,%rsi
    6fb6:	cmovl  0x381a(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    6fbe:	cmp    $0x6,%rcx
    6fc2:	je     6fd3 <botlish_fn_19+0x5c4b>
    6fc8:	mov    $0xd,%r12d
    6fce:	jmp    6fe6 <botlish_fn_19+0x5c5e>
    6fd3:	mov    0x530(%rsp),%r12
    6fdb:	jmp    6fe6 <botlish_fn_19+0x5c5e>
    6fe0:	mov    $0xd,%r12d
    6fe6:	mov    %r12,%rsi
    6fe9:	sar    $1,%rsi
    6fec:	cmp    $0x2,%rsi
    6ff0:	jl     71cc <botlish_fn_19+0x5e44>
    6ff6:	cmp    $0x2,%rsi
    6ffa:	je     7144 <botlish_fn_19+0x5dbc>
    7000:	cmp    $0x4,%rsi
    7004:	je     7139 <botlish_fn_19+0x5db1>
    700a:	cmp    $0x5,%rsi
    700e:	mov    %rsi,%r12
    7011:	je     712e <botlish_fn_19+0x5da6>
    7017:	mov    0x480(%rsp),%rsi
    701f:	test   $0x1,%rsi
    7026:	jne    705e <botlish_fn_19+0x5cd6>
    702c:	mov    0x500(%rsp),%rdx
    7034:	mov    0x480(%rsp),%rsi
    703c:	mov    0x458(%rsp),%rdi
    7044:	call   7049 <botlish_fn_19+0x5cc1>
			7045: R_X86_64_PLT32	rt_int_cmp-0x4
    7049:	mov    $0x2,%ecx
    704e:	test   %rax,%rax
    7051:	cmove  0x377f(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7059:	jmp    7077 <botlish_fn_19+0x5cef>
    705e:	mov    $0x2,%ecx
    7063:	mov    0x480(%rsp),%rsi
    706b:	cmp    $0xffffffffffffffff,%rsi
    706f:	cmove  0x3761(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7077:	cmp    $0x6,%rcx
    707b:	je     70de <botlish_fn_19+0x5d56>
    7081:	mov    %r12,%rsi
    7084:	mov    0x458(%rsp),%rdi
    708c:	call   7091 <botlish_fn_19+0x5d09>
			708d: R_X86_64_PLT32	botlish_fn_9-0x4
    7091:	mov    0x458(%rsp),%rdi
    7099:	mov    0x10(%rdi),%rcx
    709d:	mov    0x1f8(%rcx),%rdx
    70a4:	lea    0x400(%rsp),%r9
    70ac:	mov    %rax,0x400(%rsp)
    70b4:	mov    0x480(%rsp),%rsi
    70bc:	mov    %rsi,0x408(%rsp)
    70c4:	mov    $0x1,%esi
    70c9:	mov    $0x8,%ecx
    70ce:	mov    $0x2,%r8d
    70d4:	call   70d9 <botlish_fn_19+0x5d51>
			70d5: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    70d9:	jmp    8cef <botlish_fn_19+0x7967>
    70de:	mov    %r12,%rsi
    70e1:	mov    0x458(%rsp),%rdi
    70e9:	call   70ee <botlish_fn_19+0x5d66>
			70ea: R_X86_64_PLT32	botlish_fn_9-0x4
    70ee:	mov    0x458(%rsp),%rdi
    70f6:	mov    0x10(%rdi),%rcx
    70fa:	mov    0x1f0(%rcx),%rdx
    7101:	lea    0x3f8(%rsp),%r9
    7109:	mov    %rax,0x3f8(%rsp)
    7111:	mov    $0x2,%esi
    7116:	mov    $0x1,%r8d
    711c:	mov    0x530(%rsp),%rcx
    7124:	call   7129 <botlish_fn_19+0x5da1>
			7125: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    7129:	jmp    8cef <botlish_fn_19+0x7967>
    712e:	xor    %rax,%rax
    7131:	mov    %rbx,%r12
    7134:	jmp    71f7 <botlish_fn_19+0x5e6f>
    7139:	xor    %rax,%rax
    713c:	mov    %rbx,%r12
    713f:	jmp    7d9f <botlish_fn_19+0x6a17>
    7144:	mov    $0xfffffffffffffffd,%rsi
    714b:	mov    %rsi,0x480(%rsp)
    7153:	mov    0x480(%rsp),%rsi
    715b:	test   $0x1,%rsi
    7162:	jne    719a <botlish_fn_19+0x5e12>
    7168:	mov    $0xfffffffffffffffd,%rdx
    716f:	mov    0x480(%rsp),%rsi
    7177:	mov    0x458(%rsp),%rdi
    717f:	call   7184 <botlish_fn_19+0x5dfc>
			7180: R_X86_64_PLT32	rt_int_cmp-0x4
    7184:	mov    $0x2,%r13d
    718a:	test   %rax,%rax
    718d:	cmove  0x3643(%rip),%r13        # a7d8 <botlish_fn_19+0x9450>
    7195:	jmp    71b4 <botlish_fn_19+0x5e2c>
    719a:	mov    $0x2,%r13d
    71a0:	mov    0x480(%rsp),%rsi
    71a8:	cmp    $0xfffffffffffffffd,%rsi
    71ac:	cmove  0x3624(%rip),%r13        # a7d8 <botlish_fn_19+0x9450>
    71b4:	mov    %r13,0xb8(%rsp)
    71bc:	mov    %rbx,%r12
    71bf:	mov    0x500(%rsp),%rbx
    71c7:	jmp    8e95 <botlish_fn_19+0x7b0d>
    71cc:	mov    %r12,0xc8(%rsp)
    71d4:	jmp    8e4f <botlish_fn_19+0x7ac7>
    71d9:	mov    0x4d8(%rsp),%rcx
    71e1:	mov    0x478(%rsp),%r12
    71e9:	mov    %rsi,0x480(%rsp)
    71f1:	mov    %rcx,%rax
    71f4:	sar    $1,%rax
    71f7:	cmp    $0x4,%rax
    71fb:	jl     75f1 <botlish_fn_19+0x6269>
    7201:	cmp    $0x6,%rax
    7205:	jl     73fe <botlish_fn_19+0x6076>
    720b:	cmp    $0x7,%rax
    720f:	jl     7309 <botlish_fn_19+0x5f81>
    7215:	mov    0x480(%rsp),%rsi
    721d:	test   $0x1,%rsi
    7224:	jne    7259 <botlish_fn_19+0x5ed1>
    722a:	mov    $0x101,%edx
    722f:	mov    0x480(%rsp),%rsi
    7237:	mov    0x458(%rsp),%rdi
    723f:	call   7244 <botlish_fn_19+0x5ebc>
			7240: R_X86_64_PLT32	rt_int_cmp-0x4
    7244:	mov    $0x2,%ecx
    7249:	test   %rax,%rax
    724c:	cmovl  0x3584(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7254:	jmp    7275 <botlish_fn_19+0x5eed>
    7259:	mov    $0x2,%ecx
    725e:	mov    0x480(%rsp),%rsi
    7266:	cmp    $0x101,%rsi
    726d:	cmovl  0x3563(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7275:	cmp    $0x6,%rcx
    7279:	je     72ff <botlish_fn_19+0x5f77>
    727f:	mov    0x480(%rsp),%rsi
    7287:	test   $0x1,%rsi
    728e:	jne    72c3 <botlish_fn_19+0x5f3b>
    7294:	mov    $0x121,%edx
    7299:	mov    0x480(%rsp),%rsi
    72a1:	mov    0x458(%rsp),%rdi
    72a9:	call   72ae <botlish_fn_19+0x5f26>
			72aa: R_X86_64_PLT32	rt_int_cmp-0x4
    72ae:	mov    $0x2,%esi
    72b3:	test   %rax,%rax
    72b6:	cmovl  0x351a(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    72be:	jmp    72de <botlish_fn_19+0x5f56>
    72c3:	mov    $0x2,%esi
    72c8:	mov    0x480(%rsp),%rax
    72d0:	cmp    $0x121,%rax
    72d6:	cmovl  0x34fa(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    72de:	cmp    $0x6,%rsi
    72e2:	je     72f2 <botlish_fn_19+0x5f6a>
    72e8:	mov    $0x23,%eax
    72ed:	jmp    7c11 <botlish_fn_19+0x6889>
    72f2:	mov    0x4f8(%rsp),%rax
    72fa:	jmp    7c11 <botlish_fn_19+0x6889>
    72ff:	mov    $0x23,%eax
    7304:	jmp    7c11 <botlish_fn_19+0x6889>
    7309:	mov    0x480(%rsp),%rsi
    7311:	test   $0x1,%rsi
    7318:	jne    734d <botlish_fn_19+0x5fc5>
    731e:	mov    $0x101,%edx
    7323:	mov    0x480(%rsp),%rsi
    732b:	mov    0x458(%rsp),%rdi
    7333:	call   7338 <botlish_fn_19+0x5fb0>
			7334: R_X86_64_PLT32	rt_int_cmp-0x4
    7338:	mov    $0x2,%ecx
    733d:	test   %rax,%rax
    7340:	cmovl  0x3490(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7348:	jmp    7369 <botlish_fn_19+0x5fe1>
    734d:	mov    $0x2,%ecx
    7352:	mov    0x480(%rsp),%rsi
    735a:	cmp    $0x101,%rsi
    7361:	cmovl  0x346f(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7369:	cmp    $0x6,%rcx
    736d:	je     73f4 <botlish_fn_19+0x606c>
    7373:	mov    0x480(%rsp),%rsi
    737b:	test   $0x1,%rsi
    7382:	jne    73b7 <botlish_fn_19+0x602f>
    7388:	mov    $0x181,%edx
    738d:	mov    0x480(%rsp),%rsi
    7395:	mov    0x458(%rsp),%rdi
    739d:	call   73a2 <botlish_fn_19+0x601a>
			739e: R_X86_64_PLT32	rt_int_cmp-0x4
    73a2:	mov    $0x2,%ecx
    73a7:	test   %rax,%rax
    73aa:	cmovl  0x3426(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    73b2:	jmp    73d3 <botlish_fn_19+0x604b>
    73b7:	mov    $0x2,%ecx
    73bc:	mov    0x480(%rsp),%rsi
    73c4:	cmp    $0x181,%rsi
    73cb:	cmovl  0x3405(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    73d3:	cmp    $0x6,%rcx
    73d7:	je     73e7 <botlish_fn_19+0x605f>
    73dd:	mov    $0x21,%eax
    73e2:	jmp    7c11 <botlish_fn_19+0x6889>
    73e7:	mov    0x4f8(%rsp),%rax
    73ef:	jmp    7c11 <botlish_fn_19+0x6889>
    73f4:	mov    $0x21,%eax
    73f9:	jmp    7c11 <botlish_fn_19+0x6889>
    73fe:	cmp    $0x5,%rax
    7402:	jl     74fc <botlish_fn_19+0x6174>
    7408:	mov    0x480(%rsp),%rsi
    7410:	test   $0x1,%rsi
    7417:	jne    744c <botlish_fn_19+0x60c4>
    741d:	mov    $0x121,%edx
    7422:	mov    0x480(%rsp),%rsi
    742a:	mov    0x458(%rsp),%rdi
    7432:	call   7437 <botlish_fn_19+0x60af>
			7433: R_X86_64_PLT32	rt_int_cmp-0x4
    7437:	mov    $0x2,%ecx
    743c:	test   %rax,%rax
    743f:	cmovl  0x3391(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7447:	jmp    7468 <botlish_fn_19+0x60e0>
    744c:	mov    $0x2,%ecx
    7451:	mov    0x480(%rsp),%rsi
    7459:	cmp    $0x121,%rsi
    7460:	cmovl  0x3370(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7468:	cmp    $0x6,%rcx
    746c:	je     74f2 <botlish_fn_19+0x616a>
    7472:	mov    0x480(%rsp),%rsi
    747a:	test   $0x1,%rsi
    7481:	jne    74b6 <botlish_fn_19+0x612e>
    7487:	mov    $0x181,%edx
    748c:	mov    0x480(%rsp),%rsi
    7494:	mov    0x458(%rsp),%rdi
    749c:	call   74a1 <botlish_fn_19+0x6119>
			749d: R_X86_64_PLT32	rt_int_cmp-0x4
    74a1:	mov    $0x2,%esi
    74a6:	test   %rax,%rax
    74a9:	cmovl  0x3327(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    74b1:	jmp    74d1 <botlish_fn_19+0x6149>
    74b6:	mov    $0x2,%esi
    74bb:	mov    0x480(%rsp),%rax
    74c3:	cmp    $0x181,%rax
    74c9:	cmovl  0x3307(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    74d1:	cmp    $0x6,%rsi
    74d5:	je     74e5 <botlish_fn_19+0x615d>
    74db:	mov    $0x1f,%eax
    74e0:	jmp    7c11 <botlish_fn_19+0x6889>
    74e5:	mov    0x4f8(%rsp),%rax
    74ed:	jmp    7c11 <botlish_fn_19+0x6889>
    74f2:	mov    $0x1f,%eax
    74f7:	jmp    7c11 <botlish_fn_19+0x6889>
    74fc:	mov    0x480(%rsp),%rsi
    7504:	test   $0x1,%rsi
    750b:	jne    7540 <botlish_fn_19+0x61b8>
    7511:	mov    $0x101,%edx
    7516:	mov    0x480(%rsp),%rsi
    751e:	mov    0x458(%rsp),%rdi
    7526:	call   752b <botlish_fn_19+0x61a3>
			7527: R_X86_64_PLT32	rt_int_cmp-0x4
    752b:	mov    $0x2,%ecx
    7530:	test   %rax,%rax
    7533:	cmovl  0x329d(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    753b:	jmp    755c <botlish_fn_19+0x61d4>
    7540:	mov    $0x2,%ecx
    7545:	mov    0x480(%rsp),%rsi
    754d:	cmp    $0x101,%rsi
    7554:	cmovl  0x327c(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    755c:	cmp    $0x6,%rcx
    7560:	je     75e7 <botlish_fn_19+0x625f>
    7566:	mov    0x480(%rsp),%rsi
    756e:	test   $0x1,%rsi
    7575:	jne    75aa <botlish_fn_19+0x6222>
    757b:	mov    $0x141,%edx
    7580:	mov    0x480(%rsp),%rsi
    7588:	mov    0x458(%rsp),%rdi
    7590:	call   7595 <botlish_fn_19+0x620d>
			7591: R_X86_64_PLT32	rt_int_cmp-0x4
    7595:	mov    $0x2,%ecx
    759a:	test   %rax,%rax
    759d:	cmovl  0x3233(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    75a5:	jmp    75c6 <botlish_fn_19+0x623e>
    75aa:	mov    $0x2,%ecx
    75af:	mov    0x480(%rsp),%rsi
    75b7:	cmp    $0x141,%rsi
    75be:	cmovl  0x3212(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    75c6:	cmp    $0x6,%rcx
    75ca:	je     75da <botlish_fn_19+0x6252>
    75d0:	mov    $0x1d,%eax
    75d5:	jmp    7c11 <botlish_fn_19+0x6889>
    75da:	mov    0x530(%rsp),%rax
    75e2:	jmp    7c11 <botlish_fn_19+0x6889>
    75e7:	mov    $0x1d,%eax
    75ec:	jmp    7c11 <botlish_fn_19+0x6889>
    75f1:	cmp    $0x2,%rax
    75f5:	jl     77ef <botlish_fn_19+0x6467>
    75fb:	cmp    $0x3,%rax
    75ff:	jl     76fa <botlish_fn_19+0x6372>
    7605:	mov    0x480(%rsp),%rsi
    760d:	test   $0x1,%rsi
    7614:	jne    7649 <botlish_fn_19+0x62c1>
    761a:	mov    $0x101,%edx
    761f:	mov    0x480(%rsp),%rsi
    7627:	mov    0x458(%rsp),%rdi
    762f:	call   7634 <botlish_fn_19+0x62ac>
			7630: R_X86_64_PLT32	rt_int_cmp-0x4
    7634:	mov    $0x2,%ecx
    7639:	test   %rax,%rax
    763c:	cmovl  0x3194(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7644:	jmp    7665 <botlish_fn_19+0x62dd>
    7649:	mov    $0x2,%ecx
    764e:	mov    0x480(%rsp),%rsi
    7656:	cmp    $0x101,%rsi
    765d:	cmovl  0x3173(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7665:	cmp    $0x6,%rcx
    7669:	je     76f0 <botlish_fn_19+0x6368>
    766f:	mov    0x480(%rsp),%rsi
    7677:	test   $0x1,%rsi
    767e:	jne    76b3 <botlish_fn_19+0x632b>
    7684:	mov    $0x181,%edx
    7689:	mov    0x480(%rsp),%rsi
    7691:	mov    0x458(%rsp),%rdi
    7699:	call   769e <botlish_fn_19+0x6316>
			769a: R_X86_64_PLT32	rt_int_cmp-0x4
    769e:	mov    $0x2,%edi
    76a3:	test   %rax,%rax
    76a6:	cmovl  0x312a(%rip),%rdi        # a7d8 <botlish_fn_19+0x9450>
    76ae:	jmp    76cf <botlish_fn_19+0x6347>
    76b3:	mov    $0x2,%edi
    76b8:	mov    0x480(%rsp),%rsi
    76c0:	cmp    $0x181,%rsi
    76c7:	cmovl  0x3109(%rip),%rdi        # a7d8 <botlish_fn_19+0x9450>
    76cf:	cmp    $0x6,%rdi
    76d3:	je     76e3 <botlish_fn_19+0x635b>
    76d9:	mov    $0x1b,%eax
    76de:	jmp    7c11 <botlish_fn_19+0x6889>
    76e3:	mov    0x530(%rsp),%rax
    76eb:	jmp    7c11 <botlish_fn_19+0x6889>
    76f0:	mov    $0x1b,%eax
    76f5:	jmp    7c11 <botlish_fn_19+0x6889>
    76fa:	mov    0x480(%rsp),%rsi
    7702:	test   $0x1,%rsi
    7709:	jne    773e <botlish_fn_19+0x63b6>
    770f:	mov    $0x141,%edx
    7714:	mov    0x480(%rsp),%rsi
    771c:	mov    0x458(%rsp),%rdi
    7724:	call   7729 <botlish_fn_19+0x63a1>
			7725: R_X86_64_PLT32	rt_int_cmp-0x4
    7729:	mov    $0x2,%ecx
    772e:	test   %rax,%rax
    7731:	cmovl  0x309f(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7739:	jmp    775a <botlish_fn_19+0x63d2>
    773e:	mov    $0x2,%ecx
    7743:	mov    0x480(%rsp),%rsi
    774b:	cmp    $0x141,%rsi
    7752:	cmovl  0x307e(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    775a:	cmp    $0x6,%rcx
    775e:	je     77e5 <botlish_fn_19+0x645d>
    7764:	mov    0x480(%rsp),%rsi
    776c:	test   $0x1,%rsi
    7773:	jne    77a8 <botlish_fn_19+0x6420>
    7779:	mov    $0x181,%edx
    777e:	mov    0x480(%rsp),%rsi
    7786:	mov    0x458(%rsp),%rdi
    778e:	call   7793 <botlish_fn_19+0x640b>
			778f: R_X86_64_PLT32	rt_int_cmp-0x4
    7793:	mov    $0x2,%ecx
    7798:	test   %rax,%rax
    779b:	cmovl  0x3035(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    77a3:	jmp    77c4 <botlish_fn_19+0x643c>
    77a8:	mov    $0x2,%ecx
    77ad:	mov    0x480(%rsp),%rsi
    77b5:	cmp    $0x181,%rsi
    77bc:	cmovl  0x3014(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    77c4:	cmp    $0x6,%rcx
    77c8:	je     77d8 <botlish_fn_19+0x6450>
    77ce:	mov    $0x19,%eax
    77d3:	jmp    7c11 <botlish_fn_19+0x6889>
    77d8:	mov    0x530(%rsp),%rax
    77e0:	jmp    7c11 <botlish_fn_19+0x6889>
    77e5:	mov    $0x19,%eax
    77ea:	jmp    7c11 <botlish_fn_19+0x6889>
    77ef:	test   %rax,%rax
    77f2:	jle    78ec <botlish_fn_19+0x6564>
    77f8:	mov    0x480(%rsp),%rsi
    7800:	test   $0x1,%rsi
    7807:	jne    783c <botlish_fn_19+0x64b4>
    780d:	mov    $0x101,%edx
    7812:	mov    0x480(%rsp),%rsi
    781a:	mov    0x458(%rsp),%rdi
    7822:	call   7827 <botlish_fn_19+0x649f>
			7823: R_X86_64_PLT32	rt_int_cmp-0x4
    7827:	mov    $0x2,%ecx
    782c:	test   %rax,%rax
    782f:	cmovl  0x2fa1(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7837:	jmp    7858 <botlish_fn_19+0x64d0>
    783c:	mov    $0x2,%ecx
    7841:	mov    0x480(%rsp),%rsi
    7849:	cmp    $0x101,%rsi
    7850:	cmovl  0x2f80(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7858:	cmp    $0x6,%rcx
    785c:	je     78e2 <botlish_fn_19+0x655a>
    7862:	mov    0x480(%rsp),%rsi
    786a:	test   $0x1,%rsi
    7871:	jne    78a7 <botlish_fn_19+0x651f>
    7877:	mov    $0x181,%edx
    787c:	mov    0x480(%rsp),%rsi
    7884:	mov    0x458(%rsp),%rdi
    788c:	call   7891 <botlish_fn_19+0x6509>
			788d: R_X86_64_PLT32	rt_int_cmp-0x4
    7891:	mov    $0x2,%r8d
    7897:	test   %rax,%rax
    789a:	cmovl  0x2f36(%rip),%r8        # a7d8 <botlish_fn_19+0x9450>
    78a2:	jmp    78c4 <botlish_fn_19+0x653c>
    78a7:	mov    $0x2,%r8d
    78ad:	mov    0x480(%rsp),%rsi
    78b5:	cmp    $0x181,%rsi
    78bc:	cmovl  0x2f14(%rip),%r8        # a7d8 <botlish_fn_19+0x9450>
    78c4:	cmp    $0x6,%r8
    78c8:	je     78d8 <botlish_fn_19+0x6550>
    78ce:	mov    $0x17,%eax
    78d3:	jmp    7c11 <botlish_fn_19+0x6889>
    78d8:	mov    $0x11,%eax
    78dd:	jmp    7c11 <botlish_fn_19+0x6889>
    78e2:	mov    $0x17,%eax
    78e7:	jmp    7c11 <botlish_fn_19+0x6889>
    78ec:	mov    0x480(%rsp),%rsi
    78f4:	test   $0x1,%rsi
    78fb:	jne    7930 <botlish_fn_19+0x65a8>
    7901:	mov    $0x1dd,%edx
    7906:	mov    0x480(%rsp),%rsi
    790e:	mov    0x458(%rsp),%rdi
    7916:	call   791b <botlish_fn_19+0x6593>
			7917: R_X86_64_PLT32	rt_int_cmp-0x4
    791b:	mov    $0x2,%ecx
    7920:	test   %rax,%rax
    7923:	cmovl  0x2ead(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    792b:	jmp    794c <botlish_fn_19+0x65c4>
    7930:	mov    $0x2,%ecx
    7935:	mov    0x480(%rsp),%rsi
    793d:	cmp    $0x1dd,%rsi
    7944:	cmovl  0x2e8c(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    794c:	cmp    $0x6,%rcx
    7950:	je     7ae2 <botlish_fn_19+0x675a>
    7956:	mov    0x480(%rsp),%rsi
    795e:	test   $0x1,%rsi
    7965:	jne    799a <botlish_fn_19+0x6612>
    796b:	mov    $0x1e3,%edx
    7970:	mov    0x480(%rsp),%rsi
    7978:	mov    0x458(%rsp),%rdi
    7980:	call   7985 <botlish_fn_19+0x65fd>
			7981: R_X86_64_PLT32	rt_int_cmp-0x4
    7985:	mov    $0x2,%ecx
    798a:	test   %rax,%rax
    798d:	cmovl  0x2e43(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7995:	jmp    79b6 <botlish_fn_19+0x662e>
    799a:	mov    $0x2,%ecx
    799f:	mov    0x480(%rsp),%rsi
    79a7:	cmp    $0x1e3,%rsi
    79ae:	cmovl  0x2e22(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    79b6:	cmp    $0x6,%rcx
    79ba:	je     7ab1 <botlish_fn_19+0x6729>
    79c0:	mov    0x480(%rsp),%rsi
    79c8:	test   $0x1,%rsi
    79cf:	jne    7a04 <botlish_fn_19+0x667c>
    79d5:	mov    $0x1e9,%edx
    79da:	mov    0x480(%rsp),%rsi
    79e2:	mov    0x458(%rsp),%rdi
    79ea:	call   79ef <botlish_fn_19+0x6667>
			79eb: R_X86_64_PLT32	rt_int_cmp-0x4
    79ef:	mov    $0x2,%ecx
    79f4:	test   %rax,%rax
    79f7:	cmovl  0x2dd9(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    79ff:	jmp    7a20 <botlish_fn_19+0x6698>
    7a04:	mov    $0x2,%ecx
    7a09:	mov    0x480(%rsp),%rsi
    7a11:	cmp    $0x1e9,%rsi
    7a18:	cmovl  0x2db8(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7a20:	cmp    $0x6,%rcx
    7a24:	je     7aa7 <botlish_fn_19+0x671f>
    7a2a:	mov    0x480(%rsp),%rsi
    7a32:	test   $0x1,%rsi
    7a39:	jne    7a6e <botlish_fn_19+0x66e6>
    7a3f:	mov    $0x1eb,%edx
    7a44:	mov    0x480(%rsp),%rsi
    7a4c:	mov    0x458(%rsp),%rdi
    7a54:	call   7a59 <botlish_fn_19+0x66d1>
			7a55: R_X86_64_PLT32	rt_int_cmp-0x4
    7a59:	mov    $0x2,%esi
    7a5e:	test   %rax,%rax
    7a61:	cmovl  0x2d6f(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    7a69:	jmp    7a89 <botlish_fn_19+0x6701>
    7a6e:	mov    $0x2,%esi
    7a73:	mov    0x480(%rsp),%rax
    7a7b:	cmp    $0x1eb,%rax
    7a81:	cmovl  0x2d4f(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    7a89:	cmp    $0x6,%rsi
    7a8d:	je     7a9d <botlish_fn_19+0x6715>
    7a93:	mov    $0x15,%eax
    7a98:	jmp    7c11 <botlish_fn_19+0x6889>
    7a9d:	mov    $0xf,%eax
    7aa2:	jmp    7c11 <botlish_fn_19+0x6889>
    7aa7:	mov    $0xd,%eax
    7aac:	jmp    7c11 <botlish_fn_19+0x6889>
    7ab1:	mov    0x480(%rsp),%rsi
    7ab9:	mov    %rsi,%rax
    7abc:	sar    $1,%rax
    7abf:	cmp    $0xf0,%rax
    7ac5:	jl     7ad5 <botlish_fn_19+0x674d>
    7acb:	mov    $0xb,%eax
    7ad0:	jmp    7c11 <botlish_fn_19+0x6889>
    7ad5:	mov    0x4f8(%rsp),%rax
    7add:	jmp    7c11 <botlish_fn_19+0x6889>
    7ae2:	mov    0x480(%rsp),%rsi
    7aea:	test   $0x1,%rsi
    7af1:	jne    7b26 <botlish_fn_19+0x679e>
    7af7:	mov    $0x1c1,%edx
    7afc:	mov    0x480(%rsp),%rsi
    7b04:	mov    0x458(%rsp),%rdi
    7b0c:	call   7b11 <botlish_fn_19+0x6789>
			7b0d: R_X86_64_PLT32	rt_int_cmp-0x4
    7b11:	mov    $0x2,%ecx
    7b16:	test   %rax,%rax
    7b19:	cmovl  0x2cb7(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7b21:	jmp    7b42 <botlish_fn_19+0x67ba>
    7b26:	mov    $0x2,%ecx
    7b2b:	mov    0x480(%rsp),%rsi
    7b33:	cmp    $0x1c1,%rsi
    7b3a:	cmovl  0x2c96(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7b42:	cmp    $0x6,%rcx
    7b46:	je     7b95 <botlish_fn_19+0x680d>
    7b4c:	mov    0x480(%rsp),%rsi
    7b54:	mov    %rsi,%rdx
    7b57:	sar    $1,%rdx
    7b5a:	cmp    $0xe1,%rdx
    7b61:	jl     7b8b <botlish_fn_19+0x6803>
    7b67:	cmp    $0xed,%rdx
    7b6e:	jl     7b7e <botlish_fn_19+0x67f6>
    7b74:	mov    $0x9,%eax
    7b79:	jmp    7c11 <botlish_fn_19+0x6889>
    7b7e:	mov    0x4f8(%rsp),%rax
    7b86:	jmp    7c11 <botlish_fn_19+0x6889>
    7b8b:	mov    $0x5,%eax
    7b90:	jmp    7c11 <botlish_fn_19+0x6889>
    7b95:	mov    0x480(%rsp),%rsi
    7b9d:	test   $0x1,%rsi
    7ba4:	jne    7bd9 <botlish_fn_19+0x6851>
    7baa:	mov    $0x185,%edx
    7baf:	mov    0x480(%rsp),%rsi
    7bb7:	mov    0x458(%rsp),%rdi
    7bbf:	call   7bc4 <botlish_fn_19+0x683c>
			7bc0: R_X86_64_PLT32	rt_int_cmp-0x4
    7bc4:	mov    $0x2,%ecx
    7bc9:	test   %rax,%rax
    7bcc:	cmovl  0x2c04(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7bd4:	jmp    7bf5 <botlish_fn_19+0x686d>
    7bd9:	mov    $0x2,%ecx
    7bde:	mov    0x480(%rsp),%rsi
    7be6:	cmp    $0x185,%rsi
    7bed:	cmovl  0x2be3(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7bf5:	cmp    $0x6,%rcx
    7bf9:	je     7c0c <botlish_fn_19+0x6884>
    7bff:	mov    0x530(%rsp),%rax
    7c07:	jmp    7c11 <botlish_fn_19+0x6889>
    7c0c:	mov    $0x15,%eax
    7c11:	mov    %rax,%rsi
    7c14:	sar    $1,%rsi
    7c17:	mov    $0x8,%ebx
    7c1c:	cmp    $0x8,%rsi
    7c20:	jl     7d55 <botlish_fn_19+0x69cd>
    7c26:	cmp    $0x8,%rsi
    7c2a:	mov    %rsi,%r12
    7c2d:	je     7d48 <botlish_fn_19+0x69c0>
    7c33:	mov    0x480(%rsp),%rsi
    7c3b:	test   $0x1,%rsi
    7c42:	jne    7c7a <botlish_fn_19+0x68f2>
    7c48:	mov    0x500(%rsp),%rdx
    7c50:	mov    0x480(%rsp),%rsi
    7c58:	mov    0x458(%rsp),%rdi
    7c60:	call   7c65 <botlish_fn_19+0x68dd>
			7c61: R_X86_64_PLT32	rt_int_cmp-0x4
    7c65:	mov    $0x2,%ecx
    7c6a:	test   %rax,%rax
    7c6d:	cmove  0x2b63(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7c75:	jmp    7c93 <botlish_fn_19+0x690b>
    7c7a:	mov    $0x2,%ecx
    7c7f:	mov    0x480(%rsp),%rsi
    7c87:	cmp    $0xffffffffffffffff,%rsi
    7c8b:	cmove  0x2b45(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7c93:	cmp    $0x6,%rcx
    7c97:	je     7cf8 <botlish_fn_19+0x6970>
    7c9d:	mov    %r12,%rsi
    7ca0:	mov    0x458(%rsp),%rdi
    7ca8:	call   7cad <botlish_fn_19+0x6925>
			7ca9: R_X86_64_PLT32	botlish_fn_7-0x4
    7cad:	mov    0x458(%rsp),%rdi
    7cb5:	mov    0x10(%rdi),%rcx
    7cb9:	mov    0x1f8(%rcx),%rdx
    7cc0:	lea    0x3e8(%rsp),%r9
    7cc8:	mov    %rax,0x3e8(%rsp)
    7cd0:	mov    0x480(%rsp),%rsi
    7cd8:	mov    %rsi,0x3f0(%rsp)
    7ce0:	mov    $0x1,%esi
    7ce5:	mov    $0x2,%r8d
    7ceb:	mov    %rbx,%rcx
    7cee:	call   7cf3 <botlish_fn_19+0x696b>
			7cef: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    7cf3:	jmp    8cef <botlish_fn_19+0x7967>
    7cf8:	mov    %r12,%rsi
    7cfb:	mov    0x458(%rsp),%rdi
    7d03:	call   7d08 <botlish_fn_19+0x6980>
			7d04: R_X86_64_PLT32	botlish_fn_7-0x4
    7d08:	mov    0x458(%rsp),%rdi
    7d10:	mov    0x10(%rdi),%rcx
    7d14:	mov    0x1f0(%rcx),%rdx
    7d1b:	lea    0x3e0(%rsp),%r9
    7d23:	mov    %rax,0x3e0(%rsp)
    7d2b:	mov    $0x2,%esi
    7d30:	mov    $0x1,%r8d
    7d36:	mov    0x530(%rsp),%rcx
    7d3e:	call   7d43 <botlish_fn_19+0x69bb>
			7d3f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    7d43:	jmp    8cef <botlish_fn_19+0x7967>
    7d48:	mov    0x530(%rsp),%r12
    7d50:	jmp    8e47 <botlish_fn_19+0x7abf>
    7d55:	mov    %rax,0xd8(%rsp)
    7d5d:	mov    $0x6,%r13d
    7d63:	movq   $0x6,0xb8(%rsp)
    7d6f:	mov    $0x2,%ebx
    7d74:	mov    %rax,0x4d8(%rsp)
    7d7c:	jmp    8e95 <botlish_fn_19+0x7b0d>
    7d81:	mov    0x4d0(%rsp),%rcx
    7d89:	mov    0x478(%rsp),%r12
    7d91:	mov    %rsi,0x480(%rsp)
    7d99:	mov    %rcx,%rax
    7d9c:	sar    $1,%rax
    7d9f:	cmp    $0x3,%rax
    7da3:	jl     840f <botlish_fn_19+0x7087>
    7da9:	cmp    $0x4,%rax
    7dad:	jl     81f2 <botlish_fn_19+0x6e6a>
    7db3:	cmp    $0x5,%rax
    7db7:	jl     7fd7 <botlish_fn_19+0x6c4f>
    7dbd:	mov    0x480(%rsp),%rsi
    7dc5:	test   $0x1,%rsi
    7dcc:	jne    7e01 <botlish_fn_19+0x6a79>
    7dd2:	mov    $0x83,%edx
    7dd7:	mov    0x480(%rsp),%rsi
    7ddf:	mov    0x458(%rsp),%rdi
    7de7:	call   7dec <botlish_fn_19+0x6a64>
			7de8: R_X86_64_PLT32	rt_int_cmp-0x4
    7dec:	mov    $0x2,%ecx
    7df1:	test   %rax,%rax
    7df4:	cmovl  0x29dc(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7dfc:	jmp    7e1d <botlish_fn_19+0x6a95>
    7e01:	mov    $0x2,%ecx
    7e06:	mov    0x480(%rsp),%rsi
    7e0e:	cmp    $0x83,%rsi
    7e15:	cmovl  0x29bb(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7e1d:	cmp    $0x6,%rcx
    7e21:	je     7f3a <botlish_fn_19+0x6bb2>
    7e27:	mov    0x480(%rsp),%rsi
    7e2f:	test   $0x1,%rsi
    7e36:	jne    7e6b <botlish_fn_19+0x6ae3>
    7e3c:	mov    $0xc3,%edx
    7e41:	mov    0x480(%rsp),%rsi
    7e49:	mov    0x458(%rsp),%rdi
    7e51:	call   7e56 <botlish_fn_19+0x6ace>
			7e52: R_X86_64_PLT32	rt_int_cmp-0x4
    7e56:	mov    $0x2,%ecx
    7e5b:	test   %rax,%rax
    7e5e:	cmovl  0x2972(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7e66:	jmp    7e87 <botlish_fn_19+0x6aff>
    7e6b:	mov    $0x2,%ecx
    7e70:	mov    0x480(%rsp),%rsi
    7e78:	cmp    $0xc3,%rsi
    7e7f:	cmovl  0x2951(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7e87:	cmp    $0x6,%rcx
    7e8b:	je     7f0e <botlish_fn_19+0x6b86>
    7e91:	mov    0x480(%rsp),%rsi
    7e99:	test   $0x1,%rsi
    7ea0:	jne    7ed5 <botlish_fn_19+0x6b4d>
    7ea6:	mov    $0xcf,%edx
    7eab:	mov    0x480(%rsp),%rsi
    7eb3:	mov    0x458(%rsp),%rdi
    7ebb:	call   7ec0 <botlish_fn_19+0x6b38>
			7ebc: R_X86_64_PLT32	rt_int_cmp-0x4
    7ec0:	mov    $0x2,%esi
    7ec5:	test   %rax,%rax
    7ec8:	cmovl  0x2908(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    7ed0:	jmp    7ef0 <botlish_fn_19+0x6b68>
    7ed5:	mov    $0x2,%esi
    7eda:	mov    0x480(%rsp),%rax
    7ee2:	cmp    $0xcf,%rax
    7ee8:	cmovl  0x28e8(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    7ef0:	cmp    $0x6,%rsi
    7ef4:	je     7f04 <botlish_fn_19+0x6b7c>
    7efa:	mov    $0x1b,%eax
    7eff:	jmp    8bc0 <botlish_fn_19+0x7838>
    7f04:	mov    $0xd,%eax
    7f09:	jmp    8bc0 <botlish_fn_19+0x7838>
    7f0e:	mov    0x480(%rsp),%rsi
    7f16:	mov    %rsi,%rax
    7f19:	sar    $1,%rax
    7f1c:	cmp    $0x47,%rax
    7f20:	jl     7f30 <botlish_fn_19+0x6ba8>
    7f26:	mov    $0x1b,%eax
    7f2b:	jmp    8bc0 <botlish_fn_19+0x7838>
    7f30:	mov    $0xd,%eax
    7f35:	jmp    8bc0 <botlish_fn_19+0x7838>
    7f3a:	mov    0x480(%rsp),%rsi
    7f42:	test   $0x1,%rsi
    7f49:	jne    7f7e <botlish_fn_19+0x6bf6>
    7f4f:	mov    $0x61,%edx
    7f54:	mov    0x480(%rsp),%rsi
    7f5c:	mov    0x458(%rsp),%rdi
    7f64:	call   7f69 <botlish_fn_19+0x6be1>
			7f65: R_X86_64_PLT32	rt_int_cmp-0x4
    7f69:	mov    $0x2,%ecx
    7f6e:	test   %rax,%rax
    7f71:	cmovl  0x285f(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7f79:	jmp    7f97 <botlish_fn_19+0x6c0f>
    7f7e:	mov    $0x2,%ecx
    7f83:	mov    0x480(%rsp),%rsi
    7f8b:	cmp    $0x61,%rsi
    7f8f:	cmovl  0x2841(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    7f97:	cmp    $0x6,%rcx
    7f9b:	je     7fcd <botlish_fn_19+0x6c45>
    7fa1:	mov    0x480(%rsp),%rsi
    7fa9:	mov    %rsi,%rax
    7fac:	sar    $1,%rax
    7faf:	cmp    $0x3a,%rax
    7fb3:	jl     7fc3 <botlish_fn_19+0x6c3b>
    7fb9:	mov    $0x1b,%eax
    7fbe:	jmp    8bc0 <botlish_fn_19+0x7838>
    7fc3:	mov    $0xd,%eax
    7fc8:	jmp    8bc0 <botlish_fn_19+0x7838>
    7fcd:	mov    $0x1b,%eax
    7fd2:	jmp    8bc0 <botlish_fn_19+0x7838>
    7fd7:	mov    0x480(%rsp),%rsi
    7fdf:	test   $0x1,%rsi
    7fe6:	jne    801b <botlish_fn_19+0x6c93>
    7fec:	mov    $0x83,%edx
    7ff1:	mov    0x480(%rsp),%rsi
    7ff9:	mov    0x458(%rsp),%rdi
    8001:	call   8006 <botlish_fn_19+0x6c7e>
			8002: R_X86_64_PLT32	rt_int_cmp-0x4
    8006:	mov    $0x2,%ecx
    800b:	test   %rax,%rax
    800e:	cmovl  0x27c2(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8016:	jmp    8037 <botlish_fn_19+0x6caf>
    801b:	mov    $0x2,%ecx
    8020:	mov    0x480(%rsp),%rsi
    8028:	cmp    $0x83,%rsi
    802f:	cmovl  0x27a1(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8037:	cmp    $0x6,%rcx
    803b:	je     8155 <botlish_fn_19+0x6dcd>
    8041:	mov    0x480(%rsp),%rsi
    8049:	test   $0x1,%rsi
    8050:	jne    8085 <botlish_fn_19+0x6cfd>
    8056:	mov    $0xc3,%edx
    805b:	mov    0x480(%rsp),%rsi
    8063:	mov    0x458(%rsp),%rdi
    806b:	call   8070 <botlish_fn_19+0x6ce8>
			806c: R_X86_64_PLT32	rt_int_cmp-0x4
    8070:	mov    $0x2,%ecx
    8075:	test   %rax,%rax
    8078:	cmovl  0x2758(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8080:	jmp    80a1 <botlish_fn_19+0x6d19>
    8085:	mov    $0x2,%ecx
    808a:	mov    0x480(%rsp),%rsi
    8092:	cmp    $0xc3,%rsi
    8099:	cmovl  0x2737(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    80a1:	cmp    $0x6,%rcx
    80a5:	je     8129 <botlish_fn_19+0x6da1>
    80ab:	mov    0x480(%rsp),%rsi
    80b3:	test   $0x1,%rsi
    80ba:	jne    80ef <botlish_fn_19+0x6d67>
    80c0:	mov    $0xcf,%edx
    80c5:	mov    0x480(%rsp),%rsi
    80cd:	mov    0x458(%rsp),%rdi
    80d5:	call   80da <botlish_fn_19+0x6d52>
			80d6: R_X86_64_PLT32	rt_int_cmp-0x4
    80da:	mov    $0x2,%ecx
    80df:	test   %rax,%rax
    80e2:	cmovl  0x26ee(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    80ea:	jmp    810b <botlish_fn_19+0x6d83>
    80ef:	mov    $0x2,%ecx
    80f4:	mov    0x480(%rsp),%rsi
    80fc:	cmp    $0xcf,%rsi
    8103:	cmovl  0x26cd(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    810b:	cmp    $0x6,%rcx
    810f:	je     811f <botlish_fn_19+0x6d97>
    8115:	mov    $0x19,%eax
    811a:	jmp    8bc0 <botlish_fn_19+0x7838>
    811f:	mov    $0xb,%eax
    8124:	jmp    8bc0 <botlish_fn_19+0x7838>
    8129:	mov    0x480(%rsp),%rsi
    8131:	mov    %rsi,%r8
    8134:	sar    $1,%r8
    8137:	cmp    $0x47,%r8
    813b:	jl     814b <botlish_fn_19+0x6dc3>
    8141:	mov    $0x19,%eax
    8146:	jmp    8bc0 <botlish_fn_19+0x7838>
    814b:	mov    $0xb,%eax
    8150:	jmp    8bc0 <botlish_fn_19+0x7838>
    8155:	mov    0x480(%rsp),%rsi
    815d:	test   $0x1,%rsi
    8164:	jne    8199 <botlish_fn_19+0x6e11>
    816a:	mov    $0x61,%edx
    816f:	mov    0x480(%rsp),%rsi
    8177:	mov    0x458(%rsp),%rdi
    817f:	call   8184 <botlish_fn_19+0x6dfc>
			8180: R_X86_64_PLT32	rt_int_cmp-0x4
    8184:	mov    $0x2,%ecx
    8189:	test   %rax,%rax
    818c:	cmovl  0x2644(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8194:	jmp    81b2 <botlish_fn_19+0x6e2a>
    8199:	mov    $0x2,%ecx
    819e:	mov    0x480(%rsp),%rsi
    81a6:	cmp    $0x61,%rsi
    81aa:	cmovl  0x2626(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    81b2:	cmp    $0x6,%rcx
    81b6:	je     81e8 <botlish_fn_19+0x6e60>
    81bc:	mov    0x480(%rsp),%rsi
    81c4:	mov    %rsi,%rax
    81c7:	sar    $1,%rax
    81ca:	cmp    $0x3a,%rax
    81ce:	jl     81de <botlish_fn_19+0x6e56>
    81d4:	mov    $0x19,%eax
    81d9:	jmp    8bc0 <botlish_fn_19+0x7838>
    81de:	mov    $0xb,%eax
    81e3:	jmp    8bc0 <botlish_fn_19+0x7838>
    81e8:	mov    $0x19,%eax
    81ed:	jmp    8bc0 <botlish_fn_19+0x7838>
    81f2:	mov    0x480(%rsp),%rsi
    81fa:	test   $0x1,%rsi
    8201:	jne    8236 <botlish_fn_19+0x6eae>
    8207:	mov    $0x83,%edx
    820c:	mov    0x480(%rsp),%rsi
    8214:	mov    0x458(%rsp),%rdi
    821c:	call   8221 <botlish_fn_19+0x6e99>
			821d: R_X86_64_PLT32	rt_int_cmp-0x4
    8221:	mov    $0x2,%ecx
    8226:	test   %rax,%rax
    8229:	cmovl  0x25a7(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8231:	jmp    8252 <botlish_fn_19+0x6eca>
    8236:	mov    $0x2,%ecx
    823b:	mov    0x480(%rsp),%rsi
    8243:	cmp    $0x83,%rsi
    824a:	cmovl  0x2586(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8252:	cmp    $0x6,%rcx
    8256:	je     8372 <botlish_fn_19+0x6fea>
    825c:	mov    0x480(%rsp),%rsi
    8264:	test   $0x1,%rsi
    826b:	jne    82a1 <botlish_fn_19+0x6f19>
    8271:	mov    $0xc3,%edx
    8276:	mov    0x480(%rsp),%rsi
    827e:	mov    0x458(%rsp),%rdi
    8286:	call   828b <botlish_fn_19+0x6f03>
			8287: R_X86_64_PLT32	rt_int_cmp-0x4
    828b:	mov    $0x2,%r9d
    8291:	test   %rax,%rax
    8294:	cmovl  0x253c(%rip),%r9        # a7d8 <botlish_fn_19+0x9450>
    829c:	jmp    82be <botlish_fn_19+0x6f36>
    82a1:	mov    $0x2,%r9d
    82a7:	mov    0x480(%rsp),%rsi
    82af:	cmp    $0xc3,%rsi
    82b6:	cmovl  0x251a(%rip),%r9        # a7d8 <botlish_fn_19+0x9450>
    82be:	cmp    $0x6,%r9
    82c2:	je     8346 <botlish_fn_19+0x6fbe>
    82c8:	mov    0x480(%rsp),%rsi
    82d0:	test   $0x1,%rsi
    82d7:	jne    830c <botlish_fn_19+0x6f84>
    82dd:	mov    $0xcf,%edx
    82e2:	mov    0x480(%rsp),%rsi
    82ea:	mov    0x458(%rsp),%rdi
    82f2:	call   82f7 <botlish_fn_19+0x6f6f>
			82f3: R_X86_64_PLT32	rt_int_cmp-0x4
    82f7:	mov    $0x2,%ecx
    82fc:	test   %rax,%rax
    82ff:	cmovl  0x24d1(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8307:	jmp    8328 <botlish_fn_19+0x6fa0>
    830c:	mov    $0x2,%ecx
    8311:	mov    0x480(%rsp),%rsi
    8319:	cmp    $0xcf,%rsi
    8320:	cmovl  0x24b0(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8328:	cmp    $0x6,%rcx
    832c:	je     833c <botlish_fn_19+0x6fb4>
    8332:	mov    $0x17,%eax
    8337:	jmp    8bc0 <botlish_fn_19+0x7838>
    833c:	mov    $0x9,%eax
    8341:	jmp    8bc0 <botlish_fn_19+0x7838>
    8346:	mov    0x480(%rsp),%rsi
    834e:	mov    %rsi,%rax
    8351:	sar    $1,%rax
    8354:	cmp    $0x47,%rax
    8358:	jl     8368 <botlish_fn_19+0x6fe0>
    835e:	mov    $0x17,%eax
    8363:	jmp    8bc0 <botlish_fn_19+0x7838>
    8368:	mov    $0x9,%eax
    836d:	jmp    8bc0 <botlish_fn_19+0x7838>
    8372:	mov    0x480(%rsp),%rsi
    837a:	test   $0x1,%rsi
    8381:	jne    83b6 <botlish_fn_19+0x702e>
    8387:	mov    $0x61,%edx
    838c:	mov    0x480(%rsp),%rsi
    8394:	mov    0x458(%rsp),%rdi
    839c:	call   83a1 <botlish_fn_19+0x7019>
			839d: R_X86_64_PLT32	rt_int_cmp-0x4
    83a1:	mov    $0x2,%ecx
    83a6:	test   %rax,%rax
    83a9:	cmovl  0x2427(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    83b1:	jmp    83cf <botlish_fn_19+0x7047>
    83b6:	mov    $0x2,%ecx
    83bb:	mov    0x480(%rsp),%rsi
    83c3:	cmp    $0x61,%rsi
    83c7:	cmovl  0x2409(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    83cf:	cmp    $0x6,%rcx
    83d3:	je     8405 <botlish_fn_19+0x707d>
    83d9:	mov    0x480(%rsp),%rsi
    83e1:	mov    %rsi,%r9
    83e4:	sar    $1,%r9
    83e7:	cmp    $0x3a,%r9
    83eb:	jl     83fb <botlish_fn_19+0x7073>
    83f1:	mov    $0x17,%eax
    83f6:	jmp    8bc0 <botlish_fn_19+0x7838>
    83fb:	mov    $0x9,%eax
    8400:	jmp    8bc0 <botlish_fn_19+0x7838>
    8405:	mov    $0x17,%eax
    840a:	jmp    8bc0 <botlish_fn_19+0x7838>
    840f:	test   %rax,%rax
    8412:	jle    8ad1 <botlish_fn_19+0x7749>
    8418:	cmp    $0x2,%rax
    841c:	jl     8645 <botlish_fn_19+0x72bd>
    8422:	mov    0x480(%rsp),%rsi
    842a:	test   $0x1,%rsi
    8431:	jne    8466 <botlish_fn_19+0x70de>
    8437:	mov    $0x83,%edx
    843c:	mov    0x480(%rsp),%rsi
    8444:	mov    0x458(%rsp),%rdi
    844c:	call   8451 <botlish_fn_19+0x70c9>
			844d: R_X86_64_PLT32	rt_int_cmp-0x4
    8451:	mov    $0x2,%esi
    8456:	test   %rax,%rax
    8459:	cmovl  0x2377(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    8461:	jmp    8481 <botlish_fn_19+0x70f9>
    8466:	mov    $0x2,%esi
    846b:	mov    0x480(%rsp),%rax
    8473:	cmp    $0x83,%rax
    8479:	cmovl  0x2357(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    8481:	cmp    $0x6,%rsi
    8485:	je     85a5 <botlish_fn_19+0x721d>
    848b:	mov    0x480(%rsp),%rsi
    8493:	test   $0x1,%rsi
    849a:	jne    84cf <botlish_fn_19+0x7147>
    84a0:	mov    $0xc3,%edx
    84a5:	mov    0x480(%rsp),%rsi
    84ad:	mov    0x458(%rsp),%rdi
    84b5:	call   84ba <botlish_fn_19+0x7132>
			84b6: R_X86_64_PLT32	rt_int_cmp-0x4
    84ba:	mov    $0x2,%ecx
    84bf:	test   %rax,%rax
    84c2:	cmovl  0x230e(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    84ca:	jmp    84eb <botlish_fn_19+0x7163>
    84cf:	mov    $0x2,%ecx
    84d4:	mov    0x480(%rsp),%rsi
    84dc:	cmp    $0xc3,%rsi
    84e3:	cmovl  0x22ed(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    84eb:	cmp    $0x6,%rcx
    84ef:	je     8576 <botlish_fn_19+0x71ee>
    84f5:	mov    0x480(%rsp),%rsi
    84fd:	test   $0x1,%rsi
    8504:	jne    8539 <botlish_fn_19+0x71b1>
    850a:	mov    $0xcf,%edx
    850f:	mov    0x480(%rsp),%rsi
    8517:	mov    0x458(%rsp),%rdi
    851f:	call   8524 <botlish_fn_19+0x719c>
			8520: R_X86_64_PLT32	rt_int_cmp-0x4
    8524:	mov    $0x2,%ecx
    8529:	test   %rax,%rax
    852c:	cmovl  0x22a4(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8534:	jmp    8555 <botlish_fn_19+0x71cd>
    8539:	mov    $0x2,%ecx
    853e:	mov    0x480(%rsp),%rsi
    8546:	cmp    $0xcf,%rsi
    854d:	cmovl  0x2283(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8555:	cmp    $0x6,%rcx
    8559:	je     8569 <botlish_fn_19+0x71e1>
    855f:	mov    $0x15,%eax
    8564:	jmp    8bc0 <botlish_fn_19+0x7838>
    8569:	mov    0x4f8(%rsp),%rax
    8571:	jmp    8bc0 <botlish_fn_19+0x7838>
    8576:	mov    0x480(%rsp),%rsi
    857e:	mov    %rsi,%rax
    8581:	sar    $1,%rax
    8584:	cmp    $0x47,%rax
    8588:	jl     8598 <botlish_fn_19+0x7210>
    858e:	mov    $0x15,%eax
    8593:	jmp    8bc0 <botlish_fn_19+0x7838>
    8598:	mov    0x4f8(%rsp),%rax
    85a0:	jmp    8bc0 <botlish_fn_19+0x7838>
    85a5:	mov    0x480(%rsp),%rsi
    85ad:	test   $0x1,%rsi
    85b4:	jne    85e9 <botlish_fn_19+0x7261>
    85ba:	mov    $0x61,%edx
    85bf:	mov    0x480(%rsp),%rsi
    85c7:	mov    0x458(%rsp),%rdi
    85cf:	call   85d4 <botlish_fn_19+0x724c>
			85d0: R_X86_64_PLT32	rt_int_cmp-0x4
    85d4:	mov    $0x2,%ecx
    85d9:	test   %rax,%rax
    85dc:	cmovl  0x21f4(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    85e4:	jmp    8602 <botlish_fn_19+0x727a>
    85e9:	mov    $0x2,%ecx
    85ee:	mov    0x480(%rsp),%rsi
    85f6:	cmp    $0x61,%rsi
    85fa:	cmovl  0x21d6(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8602:	cmp    $0x6,%rcx
    8606:	je     863b <botlish_fn_19+0x72b3>
    860c:	mov    0x480(%rsp),%rsi
    8614:	mov    %rsi,%rax
    8617:	sar    $1,%rax
    861a:	cmp    $0x3a,%rax
    861e:	jl     862e <botlish_fn_19+0x72a6>
    8624:	mov    $0x15,%eax
    8629:	jmp    8bc0 <botlish_fn_19+0x7838>
    862e:	mov    0x4f8(%rsp),%rax
    8636:	jmp    8bc0 <botlish_fn_19+0x7838>
    863b:	mov    $0x15,%eax
    8640:	jmp    8bc0 <botlish_fn_19+0x7838>
    8645:	mov    0x480(%rsp),%rsi
    864d:	test   $0x1,%rsi
    8654:	jne    8689 <botlish_fn_19+0x7301>
    865a:	mov    $0xcd,%edx
    865f:	mov    0x480(%rsp),%rsi
    8667:	mov    0x458(%rsp),%rdi
    866f:	call   8674 <botlish_fn_19+0x72ec>
			8670: R_X86_64_PLT32	rt_int_cmp-0x4
    8674:	mov    $0x2,%ecx
    8679:	test   %rax,%rax
    867c:	cmovl  0x2154(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8684:	jmp    86a5 <botlish_fn_19+0x731d>
    8689:	mov    $0x2,%ecx
    868e:	mov    0x480(%rsp),%rsi
    8696:	cmp    $0xcd,%rsi
    869d:	cmovl  0x2133(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    86a5:	cmp    $0x6,%rcx
    86a9:	je     88f4 <botlish_fn_19+0x756c>
    86af:	mov    0x480(%rsp),%rsi
    86b7:	test   $0x1,%rsi
    86be:	jne    86f3 <botlish_fn_19+0x736b>
    86c4:	mov    $0xe5,%edx
    86c9:	mov    0x480(%rsp),%rsi
    86d1:	mov    0x458(%rsp),%rdi
    86d9:	call   86de <botlish_fn_19+0x7356>
			86da: R_X86_64_PLT32	rt_int_cmp-0x4
    86de:	mov    $0x2,%ecx
    86e3:	test   %rax,%rax
    86e6:	cmovl  0x20ea(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    86ee:	jmp    870f <botlish_fn_19+0x7387>
    86f3:	mov    $0x2,%ecx
    86f8:	mov    0x480(%rsp),%rsi
    8700:	cmp    $0xe5,%rsi
    8707:	cmovl  0x20c9(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    870f:	cmp    $0x6,%rcx
    8713:	je     88a0 <botlish_fn_19+0x7518>
    8719:	mov    0x480(%rsp),%rsi
    8721:	test   $0x1,%rsi
    8728:	jne    875d <botlish_fn_19+0x73d5>
    872e:	mov    $0xe9,%edx
    8733:	mov    0x480(%rsp),%rsi
    873b:	mov    0x458(%rsp),%rdi
    8743:	call   8748 <botlish_fn_19+0x73c0>
			8744: R_X86_64_PLT32	rt_int_cmp-0x4
    8748:	mov    $0x2,%ecx
    874d:	test   %rax,%rax
    8750:	cmovl  0x2080(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8758:	jmp    8779 <botlish_fn_19+0x73f1>
    875d:	mov    $0x2,%ecx
    8762:	mov    0x480(%rsp),%rsi
    876a:	cmp    $0xe9,%rsi
    8771:	cmovl  0x205f(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8779:	cmp    $0x6,%rcx
    877d:	je     8874 <botlish_fn_19+0x74ec>
    8783:	mov    0x480(%rsp),%rsi
    878b:	test   $0x1,%rsi
    8792:	jne    87c7 <botlish_fn_19+0x743f>
    8798:	mov    $0xeb,%edx
    879d:	mov    0x480(%rsp),%rsi
    87a5:	mov    0x458(%rsp),%rdi
    87ad:	call   87b2 <botlish_fn_19+0x742a>
			87ae: R_X86_64_PLT32	rt_int_cmp-0x4
    87b2:	mov    $0x2,%ecx
    87b7:	test   %rax,%rax
    87ba:	cmovl  0x2016(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    87c2:	jmp    87e3 <botlish_fn_19+0x745b>
    87c7:	mov    $0x2,%ecx
    87cc:	mov    0x480(%rsp),%rsi
    87d4:	cmp    $0xeb,%rsi
    87db:	cmovl  0x1ff5(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    87e3:	cmp    $0x6,%rcx
    87e7:	je     886a <botlish_fn_19+0x74e2>
    87ed:	mov    0x480(%rsp),%rsi
    87f5:	test   $0x1,%rsi
    87fc:	jne    8831 <botlish_fn_19+0x74a9>
    8802:	mov    $0xed,%edx
    8807:	mov    0x480(%rsp),%rsi
    880f:	mov    0x458(%rsp),%rdi
    8817:	call   881c <botlish_fn_19+0x7494>
			8818: R_X86_64_PLT32	rt_int_cmp-0x4
    881c:	mov    $0x2,%esi
    8821:	test   %rax,%rax
    8824:	cmovl  0x1fac(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    882c:	jmp    884c <botlish_fn_19+0x74c4>
    8831:	mov    $0x2,%esi
    8836:	mov    0x480(%rsp),%rax
    883e:	cmp    $0xed,%rax
    8844:	cmovl  0x1f8c(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    884c:	cmp    $0x6,%rsi
    8850:	je     8860 <botlish_fn_19+0x74d8>
    8856:	mov    $0x13,%eax
    885b:	jmp    8bc0 <botlish_fn_19+0x7838>
    8860:	mov    $0x5,%eax
    8865:	jmp    8bc0 <botlish_fn_19+0x7838>
    886a:	mov    $0xd,%eax
    886f:	jmp    8bc0 <botlish_fn_19+0x7838>
    8874:	mov    0x480(%rsp),%rsi
    887c:	mov    %rsi,%rax
    887f:	sar    $1,%rax
    8882:	cmp    $0x73,%rax
    8886:	jl     8896 <botlish_fn_19+0x750e>
    888c:	mov    $0x13,%eax
    8891:	jmp    8bc0 <botlish_fn_19+0x7838>
    8896:	mov    $0xd,%eax
    889b:	jmp    8bc0 <botlish_fn_19+0x7838>
    88a0:	mov    0x480(%rsp),%rsi
    88a8:	mov    %rsi,%rax
    88ab:	sar    $1,%rax
    88ae:	cmp    $0x6e,%rax
    88b2:	jl     88d6 <botlish_fn_19+0x754e>
    88b8:	cmp    $0x6f,%rax
    88bc:	jl     88cc <botlish_fn_19+0x7544>
    88c2:	mov    $0x13,%eax
    88c7:	jmp    8bc0 <botlish_fn_19+0x7838>
    88cc:	mov    $0xd,%eax
    88d1:	jmp    8bc0 <botlish_fn_19+0x7838>
    88d6:	cmp    $0x67,%rax
    88da:	jl     88ea <botlish_fn_19+0x7562>
    88e0:	mov    $0x13,%eax
    88e5:	jmp    8bc0 <botlish_fn_19+0x7838>
    88ea:	mov    $0xd,%eax
    88ef:	jmp    8bc0 <botlish_fn_19+0x7838>
    88f4:	mov    0x480(%rsp),%rsi
    88fc:	test   $0x1,%rsi
    8903:	jne    8938 <botlish_fn_19+0x75b0>
    8909:	mov    $0x61,%edx
    890e:	mov    0x480(%rsp),%rsi
    8916:	mov    0x458(%rsp),%rdi
    891e:	call   8923 <botlish_fn_19+0x759b>
			891f: R_X86_64_PLT32	rt_int_cmp-0x4
    8923:	mov    $0x2,%ecx
    8928:	test   %rax,%rax
    892b:	cmovl  0x1ea5(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8933:	jmp    8951 <botlish_fn_19+0x75c9>
    8938:	mov    $0x2,%ecx
    893d:	mov    0x480(%rsp),%rsi
    8945:	cmp    $0x61,%rsi
    8949:	cmovl  0x1e87(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8951:	cmp    $0x6,%rcx
    8955:	je     89c3 <botlish_fn_19+0x763b>
    895b:	mov    0x480(%rsp),%rsi
    8963:	mov    %rsi,%rax
    8966:	sar    $1,%rax
    8969:	cmp    $0x5d,%rax
    896d:	jl     89a5 <botlish_fn_19+0x761d>
    8973:	cmp    $0x62,%rax
    8977:	jl     899b <botlish_fn_19+0x7613>
    897d:	cmp    $0x63,%rax
    8981:	jl     8991 <botlish_fn_19+0x7609>
    8987:	mov    $0x13,%eax
    898c:	jmp    8bc0 <botlish_fn_19+0x7838>
    8991:	mov    $0xd,%eax
    8996:	jmp    8bc0 <botlish_fn_19+0x7838>
    899b:	mov    $0x13,%eax
    89a0:	jmp    8bc0 <botlish_fn_19+0x7838>
    89a5:	cmp    $0x5c,%rax
    89a9:	jl     89b9 <botlish_fn_19+0x7631>
    89af:	mov    $0xd,%eax
    89b4:	jmp    8bc0 <botlish_fn_19+0x7838>
    89b9:	mov    $0x13,%eax
    89be:	jmp    8bc0 <botlish_fn_19+0x7838>
    89c3:	mov    0x480(%rsp),%rsi
    89cb:	test   $0x1,%rsi
    89d2:	jne    8a07 <botlish_fn_19+0x767f>
    89d8:	mov    $0x47,%edx
    89dd:	mov    0x480(%rsp),%rsi
    89e5:	mov    0x458(%rsp),%rdi
    89ed:	call   89f2 <botlish_fn_19+0x766a>
			89ee: R_X86_64_PLT32	rt_int_cmp-0x4
    89f2:	mov    $0x2,%ecx
    89f7:	test   %rax,%rax
    89fa:	cmovl  0x1dd6(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8a02:	jmp    8a20 <botlish_fn_19+0x7698>
    8a07:	mov    $0x2,%ecx
    8a0c:	mov    0x480(%rsp),%rsi
    8a14:	cmp    $0x47,%rsi
    8a18:	cmovl  0x1db8(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8a20:	cmp    $0x6,%rcx
    8a24:	je     8a56 <botlish_fn_19+0x76ce>
    8a2a:	mov    0x480(%rsp),%rsi
    8a32:	mov    %rsi,%rax
    8a35:	sar    $1,%rax
    8a38:	cmp    $0x2f,%rax
    8a3c:	jl     8a4c <botlish_fn_19+0x76c4>
    8a42:	mov    $0xd,%eax
    8a47:	jmp    8bc0 <botlish_fn_19+0x7838>
    8a4c:	mov    $0x13,%eax
    8a51:	jmp    8bc0 <botlish_fn_19+0x7838>
    8a56:	mov    0x480(%rsp),%rsi
    8a5e:	test   $0x1,%rsi
    8a65:	jne    8a9a <botlish_fn_19+0x7712>
    8a6b:	mov    $0x45,%edx
    8a70:	mov    0x480(%rsp),%rsi
    8a78:	mov    0x458(%rsp),%rdi
    8a80:	call   8a85 <botlish_fn_19+0x76fd>
			8a81: R_X86_64_PLT32	rt_int_cmp-0x4
    8a85:	mov    $0x2,%ecx
    8a8a:	test   %rax,%rax
    8a8d:	cmovl  0x1d43(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8a95:	jmp    8ab3 <botlish_fn_19+0x772b>
    8a9a:	mov    $0x2,%ecx
    8a9f:	mov    0x480(%rsp),%rsi
    8aa7:	cmp    $0x45,%rsi
    8aab:	cmovl  0x1d25(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8ab3:	cmp    $0x6,%rcx
    8ab7:	je     8ac7 <botlish_fn_19+0x773f>
    8abd:	mov    $0xd,%eax
    8ac2:	jmp    8bc0 <botlish_fn_19+0x7838>
    8ac7:	mov    $0x13,%eax
    8acc:	jmp    8bc0 <botlish_fn_19+0x7838>
    8ad1:	mov    0x480(%rsp),%rsi
    8ad9:	test   $0x1,%rsi
    8ae0:	jne    8b15 <botlish_fn_19+0x778d>
    8ae6:	mov    $0xb9,%edx
    8aeb:	mov    0x480(%rsp),%rsi
    8af3:	mov    0x458(%rsp),%rdi
    8afb:	call   8b00 <botlish_fn_19+0x7778>
			8afc: R_X86_64_PLT32	rt_int_cmp-0x4
    8b00:	mov    $0x2,%ecx
    8b05:	test   %rax,%rax
    8b08:	cmovl  0x1cc8(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8b10:	jmp    8b31 <botlish_fn_19+0x77a9>
    8b15:	mov    $0x2,%ecx
    8b1a:	mov    0x480(%rsp),%rsi
    8b22:	cmp    $0xb9,%rsi
    8b29:	cmovl  0x1ca7(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8b31:	cmp    $0x6,%rcx
    8b35:	je     8bbb <botlish_fn_19+0x7833>
    8b3b:	mov    0x480(%rsp),%rsi
    8b43:	test   $0x1,%rsi
    8b4a:	jne    8b7f <botlish_fn_19+0x77f7>
    8b50:	mov    $0xbb,%edx
    8b55:	mov    0x480(%rsp),%rsi
    8b5d:	mov    0x458(%rsp),%rdi
    8b65:	call   8b6a <botlish_fn_19+0x77e2>
			8b66: R_X86_64_PLT32	rt_int_cmp-0x4
    8b6a:	mov    $0x2,%esi
    8b6f:	test   %rax,%rax
    8b72:	cmovl  0x1c5e(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    8b7a:	jmp    8b9a <botlish_fn_19+0x7812>
    8b7f:	mov    $0x2,%esi
    8b84:	mov    0x480(%rsp),%rax
    8b8c:	cmp    $0xbb,%rax
    8b92:	cmovl  0x1c3e(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    8b9a:	cmp    $0x6,%rsi
    8b9e:	je     8bae <botlish_fn_19+0x7826>
    8ba4:	mov    $0x11,%eax
    8ba9:	jmp    8bc0 <botlish_fn_19+0x7838>
    8bae:	mov    0x530(%rsp),%rax
    8bb6:	jmp    8bc0 <botlish_fn_19+0x7838>
    8bbb:	mov    $0x11,%eax
    8bc0:	mov    %rax,%rsi
    8bc3:	sar    $1,%rsi
    8bc6:	cmp    $0x6,%rsi
    8bca:	jl     8e6e <botlish_fn_19+0x7ae6>
    8bd0:	cmp    $0x6,%rsi
    8bd4:	mov    %rsi,%rbx
    8bd7:	je     8e3f <botlish_fn_19+0x7ab7>
    8bdd:	mov    0x480(%rsp),%rsi
    8be5:	test   $0x1,%rsi
    8bec:	jne    8c24 <botlish_fn_19+0x789c>
    8bf2:	mov    0x500(%rsp),%rdx
    8bfa:	mov    0x480(%rsp),%rsi
    8c02:	mov    0x458(%rsp),%rdi
    8c0a:	call   8c0f <botlish_fn_19+0x7887>
			8c0b: R_X86_64_PLT32	rt_int_cmp-0x4
    8c0f:	mov    $0x2,%ecx
    8c14:	test   %rax,%rax
    8c17:	cmove  0x1bb9(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8c1f:	jmp    8c3d <botlish_fn_19+0x78b5>
    8c24:	mov    $0x2,%ecx
    8c29:	mov    0x480(%rsp),%rsi
    8c31:	cmp    $0xffffffffffffffff,%rsi
    8c35:	cmove  0x1b9b(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    8c3d:	cmp    $0x6,%rcx
    8c41:	je     8ca4 <botlish_fn_19+0x791c>
    8c47:	mov    %rbx,%rsi
    8c4a:	mov    0x458(%rsp),%rdi
    8c52:	call   8c57 <botlish_fn_19+0x78cf>
			8c53: R_X86_64_PLT32	botlish_fn_5-0x4
    8c57:	mov    0x458(%rsp),%rdi
    8c5f:	mov    0x10(%rdi),%rcx
    8c63:	mov    0x1f8(%rcx),%rdx
    8c6a:	lea    0x3d0(%rsp),%r9
    8c72:	mov    %rax,0x3d0(%rsp)
    8c7a:	mov    0x480(%rsp),%rsi
    8c82:	mov    %rsi,0x3d8(%rsp)
    8c8a:	mov    $0x1,%esi
    8c8f:	mov    $0x8,%ecx
    8c94:	mov    $0x2,%r8d
    8c9a:	call   8c9f <botlish_fn_19+0x7917>
			8c9b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8c9f:	jmp    8cef <botlish_fn_19+0x7967>
    8ca4:	mov    %rbx,%rsi
    8ca7:	mov    0x458(%rsp),%rdi
    8caf:	call   8cb4 <botlish_fn_19+0x792c>
			8cb0: R_X86_64_PLT32	botlish_fn_5-0x4
    8cb4:	mov    0x458(%rsp),%rdi
    8cbc:	mov    0x10(%rdi),%rcx
    8cc0:	mov    0x1f0(%rcx),%rdx
    8cc7:	lea    0x3c8(%rsp),%r9
    8ccf:	mov    %rax,0x3c8(%rsp)
    8cd7:	mov    $0x2,%esi
    8cdc:	mov    $0x1,%r8d
    8ce2:	mov    0x530(%rsp),%rcx
    8cea:	call   8cef <botlish_fn_19+0x7967>
			8ceb: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8cef:	mov    0x458(%rsp),%rdi
    8cf7:	call   8cfc <botlish_fn_19+0x7974>
			8cf8: R_X86_64_PLT32	rt_co_failed-0x4
    8cfc:	mov    %rax,0xc0(%rsp)
    8d04:	mov    %rax,%rsi
    8d07:	mov    0x458(%rsp),%rdi
    8d0f:	call   8d14 <botlish_fn_19+0x798c>
			8d10: R_X86_64_PLT32	rt_co_resume0-0x4
    8d14:	test   %rax,%rax
    8d17:	je     8d39 <botlish_fn_19+0x79b1>
    8d1d:	mov    0x458(%rsp),%rdi
    8d25:	mov    0x10(%rdi),%rax
    8d29:	mov    0x48(%rax),%rsi
    8d2d:	mov    0x1b8(%rax),%rdx
    8d34:	call   8d39 <botlish_fn_19+0x79b1>
			8d35: R_X86_64_PLT32	rt_raise-0x4
    8d39:	mov    0x458(%rsp),%rdi
    8d41:	call   8d46 <botlish_fn_19+0x79be>
			8d42: R_X86_64_PLT32	rt_declared_error-0x4
    8d46:	cmp    $0x1,%rax
    8d4a:	je     8dca <botlish_fn_19+0x7a42>
    8d50:	mov    0x458(%rsp),%rdi
    8d58:	call   8d5d <botlish_fn_19+0x79d5>
			8d59: R_X86_64_PLT32	rt_declared_error-0x4
    8d5d:	cmp    $0x2,%rax
    8d61:	jne    a61c <botlish_fn_19+0x9294>
    8d67:	xor    %rsi,%rsi
    8d6a:	mov    0x458(%rsp),%rdi
    8d72:	call   8d77 <botlish_fn_19+0x79ef>
			8d73: R_X86_64_PLT32	rt_declared_payload-0x4
    8d77:	mov    %rax,%r12
    8d7a:	mov    0x458(%rsp),%rdi
    8d82:	call   8d87 <botlish_fn_19+0x79ff>
			8d83: R_X86_64_PLT32	rt_clear_declared_error-0x4
    8d87:	mov    0x458(%rsp),%rdi
    8d8f:	mov    0x10(%rdi),%rax
    8d93:	mov    0x1c8(%rax),%rdx
    8d9a:	lea    0x128(%rsp),%r9
    8da2:	mov    %r12,%rax
    8da5:	mov    %rax,0x128(%rsp)
    8dad:	mov    $0x5,%esi
    8db2:	mov    $0x1,%r8d
    8db8:	mov    0x530(%rsp),%rcx
    8dc0:	call   8dc5 <botlish_fn_19+0x7a3d>
			8dc1: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8dc5:	jmp    a61c <botlish_fn_19+0x9294>
    8dca:	xor    %rsi,%rsi
    8dcd:	mov    0x458(%rsp),%rdi
    8dd5:	call   8dda <botlish_fn_19+0x7a52>
			8dd6: R_X86_64_PLT32	rt_declared_payload-0x4
    8dda:	mov    %rax,%r12
    8ddd:	mov    0x458(%rsp),%rdi
    8de5:	call   8dea <botlish_fn_19+0x7a62>
			8de6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    8dea:	mov    0x518(%rsp),%rcx
    8df2:	mov    0x10(%rcx),%rax
    8df6:	mov    (%rax),%rcx
    8df9:	mov    0x458(%rsp),%rdi
    8e01:	mov    0x10(%rdi),%rax
    8e05:	mov    0x1c0(%rax),%rdx
    8e0c:	lea    0x118(%rsp),%r9
    8e14:	mov    %rcx,0x118(%rsp)
    8e1c:	mov    %r12,%rax
    8e1f:	mov    %rax,0x120(%rsp)
    8e27:	mov    $0x4,%esi
    8e2c:	mov    $0x2,%r8d
    8e32:	mov    %r8,%rcx
    8e35:	call   8e3a <botlish_fn_19+0x7ab2>
			8e36: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8e3a:	jmp    a61c <botlish_fn_19+0x9294>
    8e3f:	mov    0x530(%rsp),%r12
    8e47:	mov    %r12,0xc8(%rsp)
    8e4f:	mov    $0x6,%r13d
    8e55:	movq   $0x6,0xb8(%rsp)
    8e61:	mov    0x530(%rsp),%rbx
    8e69:	jmp    8e95 <botlish_fn_19+0x7b0d>
    8e6e:	mov    %rax,0xd0(%rsp)
    8e76:	mov    $0x6,%r13d
    8e7c:	movq   $0x6,0xb8(%rsp)
    8e88:	mov    $0x1,%ebx
    8e8d:	mov    %rax,0x4d0(%rsp)
    8e95:	mov    0x508(%rsp),%r8
    8e9d:	mov    0x18(%r8),%rsi
    8ea1:	test   %rsi,%rsi
    8ea4:	je     a754 <botlish_fn_19+0x93cc>
    8eaa:	mov    0x508(%rsp),%rax
    8eb2:	mov    0x10(%rax),%r8
    8eb6:	mov    %r13,(%r8)
    8eb9:	mov    %r12,0x478(%rsp)
    8ec1:	mov    0x508(%rsp),%r12
    8ec9:	jmp    362a <botlish_fn_19+0x22a2>
    8ece:	mov    0x458(%rsp),%rdi
    8ed6:	mov    0x10(%rdi),%rax
    8eda:	mov    0x1d0(%rax),%rdx
    8ee1:	lea    0x108(%rsp),%r9
    8ee9:	mov    0x4e8(%rsp),%rcx
    8ef1:	mov    %rcx,0x108(%rsp)
    8ef9:	mov    0x470(%rsp),%rcx
    8f01:	mov    %rcx,0x110(%rsp)
    8f09:	mov    $0x8,%esi
    8f0e:	mov    $0x4,%ecx
    8f13:	mov    $0x2,%r8d
    8f19:	call   8f1e <botlish_fn_19+0x7b96>
			8f1a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8f1e:	jmp    a61c <botlish_fn_19+0x9294>
    8f23:	mov    0x4f0(%rsp),%rsi
    8f2b:	mov    0x458(%rsp),%rdi
    8f33:	call   8f38 <botlish_fn_19+0x7bb0>
			8f34: R_X86_64_PLT32	botlish_fn_14-0x4
    8f38:	mov    0x518(%rsp),%rcx
    8f40:	mov    %rax,%rbx
    8f43:	mov    0x10(%rcx),%rax
    8f47:	mov    (%rax),%rax
    8f4a:	mov    0x490(%rsp),%r13
    8f52:	cmp    $0x1,%r13
    8f56:	je     8f80 <botlish_fn_19+0x7bf8>
    8f5c:	mov    $0xa,%esi
    8f61:	cmp    $0xffffffffffffffff,%r13
    8f65:	jne    97e0 <botlish_fn_19+0x8458>
    8f6b:	mov    0x4c8(%rsp),%rbx
    8f73:	mov    0x468(%rsp),%r14
    8f7b:	jmp    985e <botlish_fn_19+0x84d6>
    8f80:	mov    0x528(%rsp),%rsi
    8f88:	mov    0x458(%rsp),%rdi
    8f90:	call   8f95 <botlish_fn_19+0x7c0d>
			8f91: R_X86_64_PLT32	rt_mv_pop-0x4
    8f95:	mov    %rax,%rcx
    8f98:	mov    %rax,%r12
    8f9b:	test   %rcx,%rax
    8f9e:	jne    901c <botlish_fn_19+0x7c94>
    8fa4:	mov    0x458(%rsp),%rdi
    8fac:	call   8fb1 <botlish_fn_19+0x7c29>
			8fad: R_X86_64_PLT32	rt_declared_error-0x4
    8fb1:	cmp    $0x40000001,%rax
    8fb7:	jne    97c8 <botlish_fn_19+0x8440>
    8fbd:	mov    0x458(%rsp),%rdi
    8fc5:	call   8fca <botlish_fn_19+0x7c42>
			8fc6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    8fca:	mov    0x458(%rsp),%rdi
    8fd2:	mov    0x10(%rdi),%rcx
    8fd6:	mov    0x1d8(%rcx),%rax
    8fdd:	mov    0x1e0(%rcx),%rdx
    8fe4:	lea    0x2d0(%rsp),%r9
    8fec:	mov    0x4e8(%rsp),%rcx
    8ff4:	mov    %rcx,0x2d0(%rsp)
    8ffc:	mov    %rax,0x2d8(%rsp)
    9004:	mov    $0x6,%ecx
    9009:	mov    $0x2,%r8d
    900f:	mov    %rcx,%rsi
    9012:	call   9017 <botlish_fn_19+0x7c8f>
			9013: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9017:	jmp    97c8 <botlish_fn_19+0x8440>
    901c:	mov    %r12,%rax
    901f:	test   $0x1,%rax
    9025:	jne    9055 <botlish_fn_19+0x7ccd>
    902b:	mov    $0x1,%edx
    9030:	mov    %r12,%rsi
    9033:	mov    0x458(%rsp),%rdi
    903b:	call   9040 <botlish_fn_19+0x7cb8>
			903c: R_X86_64_PLT32	rt_int_cmp-0x4
    9040:	mov    $0x2,%ecx
    9045:	test   %rax,%rax
    9048:	cmove  0x1788(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9050:	jmp    9066 <botlish_fn_19+0x7cde>
    9055:	mov    $0x2,%ecx
    905a:	cmp    $0x1,%r12
    905e:	cmove  0x1772(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9066:	cmp    $0x6,%rcx
    906a:	je     975d <botlish_fn_19+0x83d5>
    9070:	test   $0x1,%r12
    9077:	jne    90a7 <botlish_fn_19+0x7d1f>
    907d:	mov    $0x5,%edx
    9082:	mov    %r12,%rsi
    9085:	mov    0x458(%rsp),%rdi
    908d:	call   9092 <botlish_fn_19+0x7d0a>
			908e: R_X86_64_PLT32	rt_int_cmp-0x4
    9092:	mov    $0x2,%esi
    9097:	test   %rax,%rax
    909a:	cmove  0x1736(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    90a2:	jmp    90b8 <botlish_fn_19+0x7d30>
    90a7:	mov    $0x2,%esi
    90ac:	cmp    $0x5,%r12
    90b0:	cmove  0x1720(%rip),%rsi        # a7d8 <botlish_fn_19+0x9450>
    90b8:	cmp    $0x6,%rsi
    90bc:	jne    90cc <botlish_fn_19+0x7d44>
    90c2:	cmp    $0x72,%rbx
    90c6:	je     9739 <botlish_fn_19+0x83b1>
    90cc:	test   $0x1,%r12
    90d3:	jne    9103 <botlish_fn_19+0x7d7b>
    90d9:	mov    $0x9,%edx
    90de:	mov    %r12,%rsi
    90e1:	mov    0x458(%rsp),%rdi
    90e9:	call   90ee <botlish_fn_19+0x7d66>
			90ea: R_X86_64_PLT32	rt_int_cmp-0x4
    90ee:	mov    $0x2,%ecx
    90f3:	test   %rax,%rax
    90f6:	cmove  0x16da(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    90fe:	jmp    9114 <botlish_fn_19+0x7d8c>
    9103:	mov    $0x2,%ecx
    9108:	cmp    $0x9,%r12
    910c:	cmove  0x16c4(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9114:	cmp    $0x6,%rcx
    9118:	jne    9128 <botlish_fn_19+0x7da0>
    911e:	cmp    $0x32,%rbx
    9122:	je     972c <botlish_fn_19+0x83a4>
    9128:	test   $0x1,%r12
    912f:	jne    9162 <botlish_fn_19+0x7dda>
    9135:	mov    0x4f8(%rsp),%rdx
    913d:	mov    %r12,%rsi
    9140:	mov    0x458(%rsp),%rdi
    9148:	call   914d <botlish_fn_19+0x7dc5>
			9149: R_X86_64_PLT32	rt_int_cmp-0x4
    914d:	mov    $0x2,%ecx
    9152:	test   %rax,%rax
    9155:	cmove  0x167b(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    915d:	jmp    9173 <botlish_fn_19+0x7deb>
    9162:	mov    $0x2,%ecx
    9167:	cmp    $0x7,%r12
    916b:	cmove  0x1665(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9173:	cmp    $0x6,%rcx
    9177:	jne    918d <botlish_fn_19+0x7e05>
    917d:	mov    %r12,%rsi
    9180:	mov    0x468(%rsp),%r14
    9188:	jmp    95e0 <botlish_fn_19+0x8258>
    918d:	test   $0x1,%r12
    9194:	jne    91c4 <botlish_fn_19+0x7e3c>
    919a:	mov    $0xb,%edx
    919f:	mov    %r12,%rsi
    91a2:	mov    0x458(%rsp),%rdi
    91aa:	call   91af <botlish_fn_19+0x7e27>
			91ab: R_X86_64_PLT32	rt_int_cmp-0x4
    91af:	mov    $0x2,%ecx
    91b4:	test   %rax,%rax
    91b7:	cmove  0x1619(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    91bf:	jmp    91d5 <botlish_fn_19+0x7e4d>
    91c4:	mov    $0x2,%ecx
    91c9:	cmp    $0xb,%r12
    91cd:	cmove  0x1603(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    91d5:	cmp    $0x6,%rcx
    91d9:	jne    91ef <botlish_fn_19+0x7e67>
    91df:	mov    %r12,%rsi
    91e2:	mov    0x468(%rsp),%r14
    91ea:	jmp    95e0 <botlish_fn_19+0x8258>
    91ef:	test   $0x1,%r12
    91f6:	jne    9226 <botlish_fn_19+0x7e9e>
    91fc:	mov    $0xf,%edx
    9201:	mov    %r12,%rsi
    9204:	mov    0x458(%rsp),%rdi
    920c:	call   9211 <botlish_fn_19+0x7e89>
			920d: R_X86_64_PLT32	rt_int_cmp-0x4
    9211:	mov    $0x2,%ecx
    9216:	test   %rax,%rax
    9219:	cmove  0x15b7(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9221:	jmp    9237 <botlish_fn_19+0x7eaf>
    9226:	mov    $0x2,%ecx
    922b:	cmp    $0xf,%r12
    922f:	cmove  0x15a1(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9237:	cmp    $0x6,%rcx
    923b:	je     9570 <botlish_fn_19+0x81e8>
    9241:	test   $0x1,%r12
    9248:	jne    9278 <botlish_fn_19+0x7ef0>
    924e:	mov    $0xd,%edx
    9253:	mov    %r12,%rsi
    9256:	mov    0x458(%rsp),%rdi
    925e:	call   9263 <botlish_fn_19+0x7edb>
			925f: R_X86_64_PLT32	rt_int_cmp-0x4
    9263:	mov    $0x2,%ecx
    9268:	test   %rax,%rax
    926b:	cmove  0x1565(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9273:	jmp    9289 <botlish_fn_19+0x7f01>
    9278:	mov    $0x2,%ecx
    927d:	cmp    $0xd,%r12
    9281:	cmove  0x154f(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9289:	cmp    $0x6,%rcx
    928d:	jne    92a3 <botlish_fn_19+0x7f1b>
    9293:	mov    %r12,%rsi
    9296:	mov    0x468(%rsp),%r14
    929e:	jmp    94a5 <botlish_fn_19+0x811d>
    92a3:	test   $0x1,%r12
    92aa:	jne    92da <botlish_fn_19+0x7f52>
    92b0:	mov    $0x9,%edx
    92b5:	mov    %r12,%rsi
    92b8:	mov    0x458(%rsp),%rdi
    92c0:	call   92c5 <botlish_fn_19+0x7f3d>
			92c1: R_X86_64_PLT32	rt_int_cmp-0x4
    92c5:	mov    $0x2,%ecx
    92ca:	test   %rax,%rax
    92cd:	cmove  0x1503(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    92d5:	jmp    92eb <botlish_fn_19+0x7f63>
    92da:	mov    $0x2,%ecx
    92df:	cmp    $0x9,%r12
    92e3:	cmove  0x14ed(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    92eb:	cmp    $0x6,%rcx
    92ef:	jne    9305 <botlish_fn_19+0x7f7d>
    92f5:	mov    %r12,%rsi
    92f8:	mov    0x468(%rsp),%r14
    9300:	jmp    94a5 <botlish_fn_19+0x811d>
    9305:	mov    %rbx,%rsi
    9308:	mov    0x458(%rsp),%rdi
    9310:	call   9315 <botlish_fn_19+0x7f8d>
			9311: R_X86_64_PLT32	botlish_fn_15-0x4
    9315:	cmp    $0x6,%rax
    9319:	je     937a <botlish_fn_19+0x7ff2>
    931f:	mov    %r12,%rsi
    9322:	mov    0x458(%rsp),%rdi
    932a:	call   932f <botlish_fn_19+0x7fa7>
			932b: R_X86_64_PLT32	botlish_fn_16-0x4
    932f:	mov    0x458(%rsp),%rdi
    9337:	mov    0x10(%rdi),%rcx
    933b:	mov    0x1e0(%rcx),%rdx
    9342:	lea    0x320(%rsp),%r9
    934a:	mov    0x4e8(%rsp),%rcx
    9352:	mov    %rcx,0x320(%rsp)
    935a:	mov    %rax,0x328(%rsp)
    9362:	mov    $0x6,%ecx
    9367:	mov    $0x2,%r8d
    936d:	mov    %rcx,%rsi
    9370:	call   9375 <botlish_fn_19+0x7fed>
			9371: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9375:	jmp    97c8 <botlish_fn_19+0x8440>
    937a:	mov    %r12,%rsi
    937d:	test   $0x1,%rsi
    9384:	jne    93b1 <botlish_fn_19+0x8029>
    938a:	mov    $0x5,%edx
    938f:	mov    0x458(%rsp),%rdi
    9397:	call   939c <botlish_fn_19+0x8014>
			9398: R_X86_64_PLT32	rt_int_cmp-0x4
    939c:	mov    $0x2,%ecx
    93a1:	test   %rax,%rax
    93a4:	cmove  0x142c(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    93ac:	jmp    93c2 <botlish_fn_19+0x803a>
    93b1:	mov    $0x2,%ecx
    93b6:	cmp    $0x5,%rsi
    93ba:	cmove  0x1416(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    93c2:	cmp    $0x6,%rcx
    93c6:	jne    93e9 <botlish_fn_19+0x8061>
    93cc:	mov    0x4f8(%rsp),%rdx
    93d4:	mov    0x528(%rsp),%rsi
    93dc:	mov    0x458(%rsp),%rdi
    93e4:	call   93e9 <botlish_fn_19+0x8061>
			93e5: R_X86_64_PLT32	rt_mv_push-0x4
    93e9:	cmp    $0x52,%rbx
    93ed:	jne    940d <botlish_fn_19+0x8085>
    93f3:	mov    $0x5,%edx
    93f8:	mov    0x528(%rsp),%rsi
    9400:	mov    0x458(%rsp),%rdi
    9408:	call   940d <botlish_fn_19+0x8085>
			9409: R_X86_64_PLT32	rt_mv_push-0x4
    940d:	cmp    $0x12,%rbx
    9411:	jne    9431 <botlish_fn_19+0x80a9>
    9417:	mov    $0x9,%edx
    941c:	mov    0x528(%rsp),%rsi
    9424:	mov    0x458(%rsp),%rdi
    942c:	call   9431 <botlish_fn_19+0x80a9>
			942d: R_X86_64_PLT32	rt_mv_push-0x4
    9431:	mov    0x528(%rsp),%rsi
    9439:	mov    0x458(%rsp),%rdi
    9441:	call   9446 <botlish_fn_19+0x80be>
			9442: R_X86_64_PLT32	rt_mv_len-0x4
    9446:	sar    $1,%rax
    9449:	mov    0x468(%rsp),%r14
    9451:	mov    %r14,%rcx
    9454:	sar    $1,%rcx
    9457:	add    $0x1,%rcx
    945e:	cmp    %rcx,%rax
    9461:	jle    9741 <botlish_fn_19+0x83b9>
    9467:	mov    0x458(%rsp),%rdi
    946f:	mov    0x10(%rdi),%rax
    9473:	mov    0x1e8(%rax),%rdx
    947a:	lea    0x330(%rsp),%r9
    9482:	mov    %r14,0x330(%rsp)
    948a:	mov    $0x1,%r8d
    9490:	mov    0x4f8(%rsp),%rcx
    9498:	mov    %rcx,%rsi
    949b:	call   94a0 <botlish_fn_19+0x8118>
			949c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    94a0:	jmp    97c8 <botlish_fn_19+0x8440>
    94a5:	cmp    $0xd2,%rbx
    94ac:	je     950a <botlish_fn_19+0x8182>
    94b2:	mov    0x458(%rsp),%rdi
    94ba:	call   94bf <botlish_fn_19+0x8137>
			94bb: R_X86_64_PLT32	botlish_fn_16-0x4
    94bf:	mov    0x458(%rsp),%rdi
    94c7:	mov    0x10(%rdi),%rcx
    94cb:	mov    0x1e0(%rcx),%rdx
    94d2:	lea    0x310(%rsp),%r9
    94da:	mov    0x4e8(%rsp),%rcx
    94e2:	mov    %rcx,0x310(%rsp)
    94ea:	mov    %rax,0x318(%rsp)
    94f2:	mov    $0x6,%ecx
    94f7:	mov    $0x2,%r8d
    94fd:	mov    %rcx,%rsi
    9500:	call   9505 <botlish_fn_19+0x817d>
			9501: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9505:	jmp    97c8 <botlish_fn_19+0x8440>
    950a:	mov    %rsi,%rax
    950d:	sar    $1,%rax
    9510:	cmp    $0x4,%rax
    9514:	jne    9741 <botlish_fn_19+0x83b9>
    951a:	mov    $0xb,%edx
    951f:	mov    0x528(%rsp),%rsi
    9527:	mov    0x458(%rsp),%rdi
    952f:	call   9534 <botlish_fn_19+0x81ac>
			9530: R_X86_64_PLT32	rt_mv_push-0x4
    9534:	mov    0x530(%rsp),%rdx
    953c:	mov    0x528(%rsp),%rsi
    9544:	mov    0x458(%rsp),%rdi
    954c:	call   9551 <botlish_fn_19+0x81c9>
			954d: R_X86_64_PLT32	rt_mv_push-0x4
    9551:	mov    $0xf,%edx
    9556:	mov    0x528(%rsp),%rsi
    955e:	mov    0x458(%rsp),%rdi
    9566:	call   956b <botlish_fn_19+0x81e3>
			9567: R_X86_64_PLT32	rt_mv_push-0x4
    956b:	jmp    9741 <botlish_fn_19+0x83b9>
    9570:	mov    %r12,%rsi
    9573:	mov    0x468(%rsp),%r14
    957b:	cmp    $0x92,%rbx
    9582:	je     9741 <botlish_fn_19+0x83b9>
    9588:	mov    0x458(%rsp),%rdi
    9590:	call   9595 <botlish_fn_19+0x820d>
			9591: R_X86_64_PLT32	botlish_fn_16-0x4
    9595:	mov    0x458(%rsp),%rdi
    959d:	mov    0x10(%rdi),%rcx
    95a1:	mov    0x1e0(%rcx),%rdx
    95a8:	lea    0x300(%rsp),%r9
    95b0:	mov    0x4e8(%rsp),%rcx
    95b8:	mov    %rcx,0x300(%rsp)
    95c0:	mov    %rax,0x308(%rsp)
    95c8:	mov    $0x6,%ecx
    95cd:	mov    $0x2,%r8d
    95d3:	mov    %rcx,%rsi
    95d6:	call   95db <botlish_fn_19+0x8253>
			95d7: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    95db:	jmp    97c8 <botlish_fn_19+0x8440>
    95e0:	mov    %rsi,%rax
    95e3:	sar    $1,%rax
    95e6:	cmp    $0x3,%rax
    95ea:	jne    95fa <botlish_fn_19+0x8272>
    95f0:	cmp    $0x72,%rbx
    95f4:	je     9741 <botlish_fn_19+0x83b9>
    95fa:	cmp    $0x5,%rax
    95fe:	jne    960e <botlish_fn_19+0x8286>
    9604:	cmp    $0x32,%rbx
    9608:	je     9741 <botlish_fn_19+0x83b9>
    960e:	cmp    $0xb2,%rbx
    9615:	je     9673 <botlish_fn_19+0x82eb>
    961b:	mov    0x458(%rsp),%rdi
    9623:	call   9628 <botlish_fn_19+0x82a0>
			9624: R_X86_64_PLT32	botlish_fn_16-0x4
    9628:	mov    0x458(%rsp),%rdi
    9630:	mov    0x10(%rdi),%rcx
    9634:	mov    0x1e0(%rcx),%rdx
    963b:	lea    0x2f0(%rsp),%r9
    9643:	mov    0x4e8(%rsp),%rcx
    964b:	mov    %rcx,0x2f0(%rsp)
    9653:	mov    %rax,0x2f8(%rsp)
    965b:	mov    $0x6,%ecx
    9660:	mov    $0x2,%r8d
    9666:	mov    %rcx,%rsi
    9669:	call   966e <botlish_fn_19+0x82e6>
			966a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    966e:	jmp    97c8 <botlish_fn_19+0x8440>
    9673:	cmp    $0x3,%rax
    9677:	je     96ed <botlish_fn_19+0x8365>
    967d:	mov    $0xb,%edx
    9682:	mov    0x528(%rsp),%rsi
    968a:	mov    0x458(%rsp),%rdi
    9692:	call   9697 <botlish_fn_19+0x830f>
			9693: R_X86_64_PLT32	rt_mv_push-0x4
    9697:	mov    0x530(%rsp),%rdx
    969f:	mov    0x528(%rsp),%rsi
    96a7:	mov    0x458(%rsp),%rdi
    96af:	call   96b4 <botlish_fn_19+0x832c>
			96b0: R_X86_64_PLT32	rt_mv_push-0x4
    96b4:	mov    $0xf,%edx
    96b9:	mov    0x528(%rsp),%rsi
    96c1:	mov    0x458(%rsp),%rdi
    96c9:	call   96ce <botlish_fn_19+0x8346>
			96ca: R_X86_64_PLT32	rt_mv_push-0x4
    96ce:	mov    $0xd,%edx
    96d3:	mov    0x528(%rsp),%rsi
    96db:	mov    0x458(%rsp),%rdi
    96e3:	call   96e8 <botlish_fn_19+0x8360>
			96e4: R_X86_64_PLT32	rt_mv_push-0x4
    96e8:	jmp    9741 <botlish_fn_19+0x83b9>
    96ed:	mov    0x4f8(%rsp),%rdx
    96f5:	mov    0x528(%rsp),%rsi
    96fd:	mov    0x458(%rsp),%rdi
    9705:	call   970a <botlish_fn_19+0x8382>
			9706: R_X86_64_PLT32	rt_mv_push-0x4
    970a:	mov    0x530(%rsp),%rdx
    9712:	mov    0x528(%rsp),%rsi
    971a:	mov    0x458(%rsp),%rdi
    9722:	call   9727 <botlish_fn_19+0x839f>
			9723: R_X86_64_PLT32	rt_mv_push-0x4
    9727:	jmp    9741 <botlish_fn_19+0x83b9>
    972c:	mov    0x468(%rsp),%r14
    9734:	jmp    9741 <botlish_fn_19+0x83b9>
    9739:	mov    0x468(%rsp),%r14
    9741:	mov    $0x6,%ebx
    9746:	movq   $0x6,0x98(%rsp)
    9752:	mov    $0x1,%r13d
    9758:	jmp    985e <botlish_fn_19+0x84d6>
    975d:	mov    %r12,%rsi
    9760:	mov    0x468(%rsp),%r14
    9768:	cmp    $0x132,%rbx
    976f:	je     9845 <botlish_fn_19+0x84bd>
    9775:	mov    0x458(%rsp),%rdi
    977d:	call   9782 <botlish_fn_19+0x83fa>
			977e: R_X86_64_PLT32	botlish_fn_16-0x4
    9782:	mov    0x458(%rsp),%rdi
    978a:	mov    0x10(%rdi),%r8
    978e:	mov    0x1e0(%r8),%rdx
    9795:	lea    0x2e0(%rsp),%r9
    979d:	mov    0x4e8(%rsp),%rcx
    97a5:	mov    %rcx,0x2e0(%rsp)
    97ad:	mov    %rax,0x2e8(%rsp)
    97b5:	mov    $0x6,%ecx
    97ba:	mov    $0x2,%r8d
    97c0:	mov    %rcx,%rsi
    97c3:	call   97c8 <botlish_fn_19+0x8440>
			97c4: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    97c8:	mov    0x458(%rsp),%rdi
    97d0:	call   97d5 <botlish_fn_19+0x844d>
			97d1: R_X86_64_PLT32	rt_co_failed-0x4
    97d5:	mov    %rax,0xa0(%rsp)
    97dd:	mov    %rax,%rsi
    97e0:	mov    0x458(%rsp),%rdi
    97e8:	call   97ed <botlish_fn_19+0x8465>
			97e9: R_X86_64_PLT32	rt_co_resume0-0x4
    97ed:	test   %rax,%rax
    97f0:	je     9812 <botlish_fn_19+0x848a>
    97f6:	mov    0x458(%rsp),%rdi
    97fe:	mov    0x10(%rdi),%rax
    9802:	mov    0x48(%rax),%rsi
    9806:	mov    0x1b8(%rax),%rdx
    980d:	call   9812 <botlish_fn_19+0x848a>
			980e: R_X86_64_PLT32	rt_raise-0x4
    9812:	mov    0x458(%rsp),%rdi
    981a:	call   981f <botlish_fn_19+0x8497>
			981b: R_X86_64_PLT32	rt_declared_error-0x4
    981f:	cmp    $0x6,%rax
    9823:	je     a61c <botlish_fn_19+0x9294>
    9829:	mov    0x458(%rsp),%rdi
    9831:	call   9836 <botlish_fn_19+0x84ae>
			9832: R_X86_64_PLT32	rt_declared_error-0x4
    9836:	cmp    $0x7,%rax
    983a:	jne    a61c <botlish_fn_19+0x9294>
    9840:	jmp    a61c <botlish_fn_19+0x9294>
    9845:	mov    $0x6,%ebx
    984a:	movq   $0x6,0x98(%rsp)
    9856:	mov    0x500(%rsp),%r13
    985e:	movq   $0x1,0x28(%rsp)
    9867:	mov    0x510(%rsp),%r12
    986f:	mov    0x10(%r12),%rax
    9874:	mov    (%rax),%rsi
    9877:	mov    %rsi,0x30(%rsp)
    987c:	movq   $0x3,0x38(%rsp)
    9885:	test   $0x1,%rsi
    988c:	je     98a4 <botlish_fn_19+0x851c>
    9892:	mov    %rsi,%rcx
    9895:	add    $0x2,%rcx
    9899:	seto   %al
    989c:	test   %al,%al
    989e:	je     98bc <botlish_fn_19+0x8534>
    98a4:	mov    0x530(%rsp),%rdx
    98ac:	mov    0x458(%rsp),%rdi
    98b4:	call   98b9 <botlish_fn_19+0x8531>
			98b5: R_X86_64_PLT32	rt_int_add-0x4
    98b9:	mov    %rax,%rcx
    98bc:	mov    0x18(%r12),%rax
    98c1:	test   %rax,%rax
    98c4:	je     a776 <botlish_fn_19+0x93ee>
    98ca:	mov    0x10(%r12),%rax
    98cf:	mov    %rcx,(%rax)
    98d2:	mov    0x520(%rsp),%rcx
    98da:	mov    %r14,0x468(%rsp)
    98e2:	mov    %r13,0x490(%rsp)
    98ea:	mov    %rbx,0x4c8(%rsp)
    98f2:	mov    %r12,0x510(%rsp)
    98fa:	jmp    1bf1 <botlish_fn_19+0x869>
    98ff:	mov    0x4c8(%rsp),%rbx
    9907:	mov    0x510(%rsp),%r12
    990f:	mov    0x490(%rsp),%r13
    9917:	mov    0x468(%rsp),%r14
    991f:	cmp    $0x1,%r13
    9923:	je     993d <botlish_fn_19+0x85b5>
    9929:	mov    $0xa,%esi
    992e:	cmp    $0xffffffffffffffff,%r13
    9932:	je     9f94 <botlish_fn_19+0x8c0c>
    9938:	jmp    9f16 <botlish_fn_19+0x8b8e>
    993d:	mov    0x528(%rsp),%rsi
    9945:	mov    0x458(%rsp),%rdi
    994d:	call   9952 <botlish_fn_19+0x85ca>
			994e: R_X86_64_PLT32	rt_mv_pop-0x4
    9952:	mov    %rax,%rcx
    9955:	mov    %rax,%rbx
    9958:	test   %rcx,%rax
    995b:	jne    99d9 <botlish_fn_19+0x8651>
    9961:	mov    0x458(%rsp),%rdi
    9969:	call   996e <botlish_fn_19+0x85e6>
			996a: R_X86_64_PLT32	rt_declared_error-0x4
    996e:	cmp    $0x40000001,%rax
    9974:	jne    9efe <botlish_fn_19+0x8b76>
    997a:	mov    0x458(%rsp),%rdi
    9982:	call   9987 <botlish_fn_19+0x85ff>
			9983: R_X86_64_PLT32	rt_clear_declared_error-0x4
    9987:	mov    0x458(%rsp),%rdi
    998f:	mov    0x10(%rdi),%rcx
    9993:	mov    0x1d8(%rcx),%rax
    999a:	mov    0x1e0(%rcx),%rdx
    99a1:	lea    0x258(%rsp),%r9
    99a9:	mov    0x4e8(%rsp),%rcx
    99b1:	mov    %rcx,0x258(%rsp)
    99b9:	mov    %rax,0x260(%rsp)
    99c1:	mov    $0x6,%ecx
    99c6:	mov    $0x2,%r8d
    99cc:	mov    %rcx,%rsi
    99cf:	call   99d4 <botlish_fn_19+0x864c>
			99d0: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    99d4:	jmp    9efe <botlish_fn_19+0x8b76>
    99d9:	mov    %rbx,%rax
    99dc:	test   $0x1,%rax
    99e2:	jne    9a12 <botlish_fn_19+0x868a>
    99e8:	mov    $0x1,%edx
    99ed:	mov    %rbx,%rsi
    99f0:	mov    0x458(%rsp),%rdi
    99f8:	call   99fd <botlish_fn_19+0x8675>
			99f9: R_X86_64_PLT32	rt_int_cmp-0x4
    99fd:	mov    $0x2,%ecx
    9a02:	test   %rax,%rax
    9a05:	cmove  0xdcb(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9a0d:	jmp    9a23 <botlish_fn_19+0x869b>
    9a12:	mov    $0x2,%ecx
    9a17:	cmp    $0x1,%rbx
    9a1b:	cmove  0xdb5(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9a23:	cmp    $0x6,%rcx
    9a27:	je     9f83 <botlish_fn_19+0x8bfb>
    9a2d:	test   $0x1,%rbx
    9a34:	jne    9a64 <botlish_fn_19+0x86dc>
    9a3a:	mov    $0x5,%edx
    9a3f:	mov    %rbx,%rsi
    9a42:	mov    0x458(%rsp),%rdi
    9a4a:	call   9a4f <botlish_fn_19+0x86c7>
			9a4b: R_X86_64_PLT32	rt_int_cmp-0x4
    9a4f:	mov    $0x2,%ecx
    9a54:	test   %rax,%rax
    9a57:	cmove  0xd79(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9a5f:	jmp    9a75 <botlish_fn_19+0x86ed>
    9a64:	mov    $0x2,%ecx
    9a69:	cmp    $0x5,%rbx
    9a6d:	cmove  0xd63(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9a75:	cmp    $0x6,%rcx
    9a79:	test   $0x1,%rbx
    9a80:	jne    9ab0 <botlish_fn_19+0x8728>
    9a86:	mov    $0x9,%edx
    9a8b:	mov    %rbx,%rsi
    9a8e:	mov    0x458(%rsp),%rdi
    9a96:	call   9a9b <botlish_fn_19+0x8713>
			9a97: R_X86_64_PLT32	rt_int_cmp-0x4
    9a9b:	mov    $0x2,%ecx
    9aa0:	test   %rax,%rax
    9aa3:	cmove  0xd2d(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9aab:	jmp    9ac1 <botlish_fn_19+0x8739>
    9ab0:	mov    $0x2,%ecx
    9ab5:	cmp    $0x9,%rbx
    9ab9:	cmove  0xd17(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9ac1:	cmp    $0x6,%rcx
    9ac5:	test   $0x1,%rbx
    9acc:	jne    9aff <botlish_fn_19+0x8777>
    9ad2:	mov    0x4f8(%rsp),%rdx
    9ada:	mov    %rbx,%rsi
    9add:	mov    0x458(%rsp),%rdi
    9ae5:	call   9aea <botlish_fn_19+0x8762>
			9ae6: R_X86_64_PLT32	rt_int_cmp-0x4
    9aea:	mov    $0x2,%ecx
    9aef:	test   %rax,%rax
    9af2:	cmove  0xcde(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9afa:	jmp    9b10 <botlish_fn_19+0x8788>
    9aff:	mov    $0x2,%ecx
    9b04:	cmp    $0x7,%rbx
    9b08:	cmove  0xcc8(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9b10:	cmp    $0x6,%rcx
    9b14:	jne    9b22 <botlish_fn_19+0x879a>
    9b1a:	mov    %rbx,%rsi
    9b1d:	jmp    9e9d <botlish_fn_19+0x8b15>
    9b22:	test   $0x1,%rbx
    9b29:	jne    9b59 <botlish_fn_19+0x87d1>
    9b2f:	mov    $0xb,%edx
    9b34:	mov    %rbx,%rsi
    9b37:	mov    0x458(%rsp),%rdi
    9b3f:	call   9b44 <botlish_fn_19+0x87bc>
			9b40: R_X86_64_PLT32	rt_int_cmp-0x4
    9b44:	mov    $0x2,%ecx
    9b49:	test   %rax,%rax
    9b4c:	cmove  0xc84(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9b54:	jmp    9b6a <botlish_fn_19+0x87e2>
    9b59:	mov    $0x2,%ecx
    9b5e:	cmp    $0xb,%rbx
    9b62:	cmove  0xc6e(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9b6a:	cmp    $0x6,%rcx
    9b6e:	jne    9b7c <botlish_fn_19+0x87f4>
    9b74:	mov    %rbx,%rsi
    9b77:	jmp    9e9d <botlish_fn_19+0x8b15>
    9b7c:	test   $0x1,%rbx
    9b83:	jne    9bb3 <botlish_fn_19+0x882b>
    9b89:	mov    $0xf,%edx
    9b8e:	mov    %rbx,%rsi
    9b91:	mov    0x458(%rsp),%rdi
    9b99:	call   9b9e <botlish_fn_19+0x8816>
			9b9a: R_X86_64_PLT32	rt_int_cmp-0x4
    9b9e:	mov    $0x2,%ecx
    9ba3:	test   %rax,%rax
    9ba6:	cmove  0xc2a(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9bae:	jmp    9bc4 <botlish_fn_19+0x883c>
    9bb3:	mov    $0x2,%ecx
    9bb8:	cmp    $0xf,%rbx
    9bbc:	cmove  0xc14(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9bc4:	cmp    $0x6,%rcx
    9bc8:	je     9e42 <botlish_fn_19+0x8aba>
    9bce:	test   $0x1,%rbx
    9bd5:	jne    9c05 <botlish_fn_19+0x887d>
    9bdb:	mov    $0xd,%edx
    9be0:	mov    %rbx,%rsi
    9be3:	mov    0x458(%rsp),%rdi
    9beb:	call   9bf0 <botlish_fn_19+0x8868>
			9bec: R_X86_64_PLT32	rt_int_cmp-0x4
    9bf0:	mov    $0x2,%edx
    9bf5:	test   %rax,%rax
    9bf8:	cmove  0xbd8(%rip),%rdx        # a7d8 <botlish_fn_19+0x9450>
    9c00:	jmp    9c16 <botlish_fn_19+0x888e>
    9c05:	mov    $0x2,%edx
    9c0a:	cmp    $0xd,%rbx
    9c0e:	cmove  0xbc2(%rip),%rdx        # a7d8 <botlish_fn_19+0x9450>
    9c16:	cmp    $0x6,%rdx
    9c1a:	jne    9c28 <botlish_fn_19+0x88a0>
    9c20:	mov    %rbx,%rsi
    9c23:	jmp    9dea <botlish_fn_19+0x8a62>
    9c28:	test   $0x1,%rbx
    9c2f:	jne    9c5f <botlish_fn_19+0x88d7>
    9c35:	mov    $0x9,%edx
    9c3a:	mov    %rbx,%rsi
    9c3d:	mov    0x458(%rsp),%rdi
    9c45:	call   9c4a <botlish_fn_19+0x88c2>
			9c46: R_X86_64_PLT32	rt_int_cmp-0x4
    9c4a:	mov    $0x2,%ecx
    9c4f:	test   %rax,%rax
    9c52:	cmove  0xb7e(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9c5a:	jmp    9c70 <botlish_fn_19+0x88e8>
    9c5f:	mov    $0x2,%ecx
    9c64:	cmp    $0x9,%rbx
    9c68:	cmove  0xb68(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9c70:	cmp    $0x6,%rcx
    9c74:	jne    9c82 <botlish_fn_19+0x88fa>
    9c7a:	mov    %rbx,%rsi
    9c7d:	jmp    9dea <botlish_fn_19+0x8a62>
    9c82:	mov    $0x132,%esi
    9c87:	mov    0x458(%rsp),%rdi
    9c8f:	call   9c94 <botlish_fn_19+0x890c>
			9c90: R_X86_64_PLT32	botlish_fn_15-0x4
    9c94:	cmp    $0x6,%rax
    9c98:	je     9cf9 <botlish_fn_19+0x8971>
    9c9e:	mov    %rbx,%rsi
    9ca1:	mov    0x458(%rsp),%rdi
    9ca9:	call   9cae <botlish_fn_19+0x8926>
			9caa: R_X86_64_PLT32	botlish_fn_16-0x4
    9cae:	mov    0x458(%rsp),%rdi
    9cb6:	mov    0x10(%rdi),%rcx
    9cba:	mov    0x1e0(%rcx),%rdx
    9cc1:	lea    0x2a8(%rsp),%r9
    9cc9:	mov    0x4e8(%rsp),%rcx
    9cd1:	mov    %rcx,0x2a8(%rsp)
    9cd9:	mov    %rax,0x2b0(%rsp)
    9ce1:	mov    $0x6,%ecx
    9ce6:	mov    $0x2,%r8d
    9cec:	mov    %rcx,%rsi
    9cef:	call   9cf4 <botlish_fn_19+0x896c>
			9cf0: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9cf4:	jmp    9efe <botlish_fn_19+0x8b76>
    9cf9:	mov    %rbx,%rsi
    9cfc:	test   $0x1,%rsi
    9d03:	jne    9d30 <botlish_fn_19+0x89a8>
    9d09:	mov    $0x5,%edx
    9d0e:	mov    0x458(%rsp),%rdi
    9d16:	call   9d1b <botlish_fn_19+0x8993>
			9d17: R_X86_64_PLT32	rt_int_cmp-0x4
    9d1b:	mov    $0x2,%ecx
    9d20:	test   %rax,%rax
    9d23:	cmove  0xaad(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9d2b:	jmp    9d41 <botlish_fn_19+0x89b9>
    9d30:	mov    $0x2,%ecx
    9d35:	cmp    $0x5,%rsi
    9d39:	cmove  0xa97(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    9d41:	cmp    $0x6,%rcx
    9d45:	jne    9d68 <botlish_fn_19+0x89e0>
    9d4b:	mov    0x4f8(%rsp),%rdx
    9d53:	mov    0x528(%rsp),%rsi
    9d5b:	mov    0x458(%rsp),%rdi
    9d63:	call   9d68 <botlish_fn_19+0x89e0>
			9d64: R_X86_64_PLT32	rt_mv_push-0x4
    9d68:	mov    0x528(%rsp),%rsi
    9d70:	mov    0x458(%rsp),%rdi
    9d78:	call   9d7d <botlish_fn_19+0x89f5>
			9d79: R_X86_64_PLT32	rt_mv_len-0x4
    9d7d:	sar    $1,%rax
    9d80:	mov    %r14,%rcx
    9d83:	sar    $1,%rcx
    9d86:	add    $0x1,%rcx
    9d8d:	cmp    %rcx,%rax
    9d90:	jg     9dac <botlish_fn_19+0x8a24>
    9d96:	mov    $0x6,%ebx
    9d9b:	movq   $0x6,0x98(%rsp)
    9da7:	jmp    9f94 <botlish_fn_19+0x8c0c>
    9dac:	mov    0x458(%rsp),%rdi
    9db4:	mov    0x10(%rdi),%rax
    9db8:	mov    0x1e8(%rax),%rdx
    9dbf:	lea    0x2b8(%rsp),%r9
    9dc7:	mov    %r14,0x2b8(%rsp)
    9dcf:	mov    $0x1,%r8d
    9dd5:	mov    0x4f8(%rsp),%rcx
    9ddd:	mov    %rcx,%rsi
    9de0:	call   9de5 <botlish_fn_19+0x8a5d>
			9de1: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9de5:	jmp    9efe <botlish_fn_19+0x8b76>
    9dea:	mov    0x458(%rsp),%rdi
    9df2:	call   9df7 <botlish_fn_19+0x8a6f>
			9df3: R_X86_64_PLT32	botlish_fn_16-0x4
    9df7:	mov    0x458(%rsp),%rdi
    9dff:	mov    0x10(%rdi),%rcx
    9e03:	mov    0x1e0(%rcx),%rdx
    9e0a:	lea    0x298(%rsp),%r9
    9e12:	mov    0x4e8(%rsp),%rcx
    9e1a:	mov    %rcx,0x298(%rsp)
    9e22:	mov    %rax,0x2a0(%rsp)
    9e2a:	mov    $0x6,%ecx
    9e2f:	mov    $0x2,%r8d
    9e35:	mov    %rcx,%rsi
    9e38:	call   9e3d <botlish_fn_19+0x8ab5>
			9e39: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9e3d:	jmp    9efe <botlish_fn_19+0x8b76>
    9e42:	mov    %rbx,%rsi
    9e45:	mov    0x458(%rsp),%rdi
    9e4d:	call   9e52 <botlish_fn_19+0x8aca>
			9e4e: R_X86_64_PLT32	botlish_fn_16-0x4
    9e52:	mov    0x458(%rsp),%rdi
    9e5a:	mov    0x10(%rdi),%rcx
    9e5e:	mov    0x1e0(%rcx),%rdx
    9e65:	lea    0x288(%rsp),%r9
    9e6d:	mov    0x4e8(%rsp),%rcx
    9e75:	mov    %rcx,0x288(%rsp)
    9e7d:	mov    %rax,0x290(%rsp)
    9e85:	mov    $0x6,%ecx
    9e8a:	mov    $0x2,%r8d
    9e90:	mov    %rcx,%rsi
    9e93:	call   9e98 <botlish_fn_19+0x8b10>
			9e94: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9e98:	jmp    9efe <botlish_fn_19+0x8b76>
    9e9d:	mov    %rsi,%rax
    9ea0:	sar    $1,%rax
    9ea3:	cmp    $0x3,%rax
    9ea7:	cmp    $0x5,%rax
    9eab:	mov    0x458(%rsp),%rdi
    9eb3:	call   9eb8 <botlish_fn_19+0x8b30>
			9eb4: R_X86_64_PLT32	botlish_fn_16-0x4
    9eb8:	mov    0x458(%rsp),%rdi
    9ec0:	mov    0x10(%rdi),%rcx
    9ec4:	mov    0x1e0(%rcx),%rdx
    9ecb:	lea    0x278(%rsp),%r9
    9ed3:	mov    0x4e8(%rsp),%rcx
    9edb:	mov    %rcx,0x278(%rsp)
    9ee3:	mov    %rax,0x280(%rsp)
    9eeb:	mov    $0x6,%ecx
    9ef0:	mov    $0x2,%r8d
    9ef6:	mov    %rcx,%rsi
    9ef9:	call   9efe <botlish_fn_19+0x8b76>
			9efa: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9efe:	mov    0x458(%rsp),%rdi
    9f06:	call   9f0b <botlish_fn_19+0x8b83>
			9f07: R_X86_64_PLT32	rt_co_failed-0x4
    9f0b:	mov    %rax,0xa0(%rsp)
    9f13:	mov    %rax,%rsi
    9f16:	mov    0x458(%rsp),%rdi
    9f1e:	call   9f23 <botlish_fn_19+0x8b9b>
			9f1f: R_X86_64_PLT32	rt_co_resume0-0x4
    9f23:	test   %rax,%rax
    9f26:	je     9f50 <botlish_fn_19+0x8bc8>
    9f2c:	mov    0x458(%rsp),%rdi
    9f34:	mov    0x10(%rdi),%rdi
    9f38:	mov    0x48(%rdi),%rsi
    9f3c:	mov    0x1b8(%rdi),%rdx
    9f43:	mov    0x458(%rsp),%rdi
    9f4b:	call   9f50 <botlish_fn_19+0x8bc8>
			9f4c: R_X86_64_PLT32	rt_raise-0x4
    9f50:	mov    0x458(%rsp),%rdi
    9f58:	call   9f5d <botlish_fn_19+0x8bd5>
			9f59: R_X86_64_PLT32	rt_declared_error-0x4
    9f5d:	cmp    $0x6,%rax
    9f61:	je     a61c <botlish_fn_19+0x9294>
    9f67:	mov    0x458(%rsp),%rdi
    9f6f:	call   9f74 <botlish_fn_19+0x8bec>
			9f70: R_X86_64_PLT32	rt_declared_error-0x4
    9f74:	cmp    $0x7,%rax
    9f78:	jne    a61c <botlish_fn_19+0x9294>
    9f7e:	jmp    a61c <botlish_fn_19+0x9294>
    9f83:	mov    $0x6,%ebx
    9f88:	movq   $0x6,0x98(%rsp)
    9f94:	mov    0x10(%r12),%rax
    9f99:	mov    (%rax),%rax
    9f9c:	mov    %rax,(%rsp)
    9fa0:	mov    0x518(%rsp),%rcx
    9fa8:	mov    0x10(%rcx),%rcx
    9fac:	mov    (%rcx),%rdx
    9faf:	mov    %rdx,0x8(%rsp)
    9fb4:	lea    0x130(%rsp),%rcx
    9fbc:	mov    %rax,0x130(%rsp)
    9fc4:	mov    %rdx,0x138(%rsp)
    9fcc:	xor    %rsi,%rsi
    9fcf:	mov    $0x2,%edx
    9fd4:	mov    0x458(%rsp),%rdi
    9fdc:	call   9fe1 <botlish_fn_19+0x8c59>
			9fdd: R_X86_64_PLT32	rt_struct_new-0x4
    9fe1:	mov    0x540(%rsp),%rbx
    9fe9:	mov    0x548(%rsp),%r12
    9ff1:	mov    0x550(%rsp),%r13
    9ff9:	mov    0x558(%rsp),%r14
    a001:	mov    0x560(%rsp),%r15
    a009:	add    $0x570,%rsp
    a010:	mov    %rbp,%rsp
    a013:	pop    %rbp
    a014:	ret
    a015:	mov    0x4c8(%rsp),%rbx
    a01d:	mov    0x510(%rsp),%r12
    a025:	mov    0x490(%rsp),%r13
    a02d:	mov    0x468(%rsp),%r14
    a035:	movq   $0x1,0x28(%rsp)
    a03e:	mov    0x518(%rsp),%rcx
    a046:	mov    0x10(%rcx),%rax
    a04a:	mov    (%rax),%rsi
    a04d:	mov    %rsi,0x30(%rsp)
    a052:	movq   $0x3,0x38(%rsp)
    a05b:	test   $0x1,%rsi
    a062:	je     a087 <botlish_fn_19+0x8cff>
    a068:	mov    %rsi,%rcx
    a06b:	add    $0x2,%rcx
    a06f:	seto   %al
    a072:	test   %al,%al
    a074:	jne    a087 <botlish_fn_19+0x8cff>
    a07a:	mov    0x518(%rsp),%rax
    a082:	jmp    a0a7 <botlish_fn_19+0x8d1f>
    a087:	mov    0x530(%rsp),%rdx
    a08f:	mov    0x458(%rsp),%rdi
    a097:	call   a09c <botlish_fn_19+0x8d14>
			a098: R_X86_64_PLT32	rt_int_add-0x4
    a09c:	mov    %rax,%rcx
    a09f:	mov    0x518(%rsp),%rax
    a0a7:	mov    0x518(%rsp),%rax
    a0af:	mov    0x18(%rax),%rax
    a0b3:	test   %rax,%rax
    a0b6:	je     a790 <botlish_fn_19+0x9408>
    a0bc:	mov    0x518(%rsp),%rax
    a0c4:	mov    0x10(%rax),%rax
    a0c8:	mov    %rcx,(%rax)
    a0cb:	movq   $0x1,0x28(%rsp)
    a0d4:	mov    0x488(%rsp),%r15
    a0dc:	cmp    $0x1,%r15
    a0e0:	je     a102 <botlish_fn_19+0x8d7a>
    a0e6:	mov    $0xa,%esi
    a0eb:	cmp    $0xffffffffffffffff,%r15
    a0ef:	jne    a5c2 <botlish_fn_19+0x923a>
    a0f5:	mov    0x520(%rsp),%rcx
    a0fd:	jmp    a68b <botlish_fn_19+0x9303>
    a102:	movq   $0xa,0x40(%rsp)
    a10b:	lea    0x170(%rsp),%rcx
    a113:	movq   $0x0,0x170(%rsp)
    a11f:	mov    0x498(%rsp),%rax
    a127:	mov    %rax,0x178(%rsp)
    a12f:	movq   $0x2,0x180(%rsp)
    a13b:	movq   $0xa,0x188(%rsp)
    a147:	mov    $0x4,%edx
    a14c:	mov    0x530(%rsp),%rsi
    a154:	mov    0x458(%rsp),%rdi
    a15c:	call   a161 <botlish_fn_19+0x8dd9>
			a15d: R_X86_64_PLT32	rt_construct-0x4
    a161:	mov    %rax,%rcx
    a164:	mov    %rax,0x498(%rsp)
    a16c:	test   %rcx,%rax
    a16f:	je     a5a1 <botlish_fn_19+0x9219>
    a175:	mov    0x498(%rsp),%rax
    a17d:	mov    %rax,0x90(%rsp)
    a185:	movq   $0x3,0x40(%rsp)
    a18e:	mov    0x4a8(%rsp),%rsi
    a196:	test   $0x1,%rsi
    a19d:	jne    a1b0 <botlish_fn_19+0x8e28>
    a1a3:	mov    0x4a8(%rsp),%rsi
    a1ab:	jmp    a1e9 <botlish_fn_19+0x8e61>
    a1b0:	mov    0x4a8(%rsp),%rsi
    a1b8:	mov    %rsi,%rdx
    a1bb:	add    $0x2,%rdx
    a1bf:	seto   %sil
    a1c3:	test   %sil,%sil
    a1c6:	je     a1d9 <botlish_fn_19+0x8e51>
    a1cc:	mov    0x4a8(%rsp),%rsi
    a1d4:	jmp    a1e9 <botlish_fn_19+0x8e61>
    a1d9:	mov    %rdx,%rsi
    a1dc:	mov    %rdx,0x4a8(%rsp)
    a1e4:	jmp    a209 <botlish_fn_19+0x8e81>
    a1e9:	mov    0x530(%rsp),%rdx
    a1f1:	mov    0x458(%rsp),%rdi
    a1f9:	call   a1fe <botlish_fn_19+0x8e76>
			a1fa: R_X86_64_PLT32	rt_int_add-0x4
    a1fe:	mov    %rax,%rsi
    a201:	mov    %rax,0x4a8(%rsp)
    a209:	mov    %rsi,0x88(%rsp)
    a211:	lea    0x190(%rsp),%r15
    a219:	mov    0x4b0(%rsp),%rax
    a221:	mov    0x4a8(%rsp),%rsi
    a229:	mov    %rsi,%r10
    a22c:	and    %rax,%r10
    a22f:	test   $0x1,%r10
    a236:	jne    a26e <botlish_fn_19+0x8ee6>
    a23c:	mov    0x4b0(%rsp),%rdx
    a244:	mov    0x4a8(%rsp),%rsi
    a24c:	mov    0x458(%rsp),%rdi
    a254:	call   a259 <botlish_fn_19+0x8ed1>
			a255: R_X86_64_PLT32	rt_int_cmp-0x4
    a259:	mov    $0x2,%ecx
    a25e:	test   %rax,%rax
    a261:	cmovl  0x56f(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    a269:	jmp    a28e <botlish_fn_19+0x8f06>
    a26e:	mov    $0x2,%ecx
    a273:	mov    0x4b0(%rsp),%rax
    a27b:	mov    0x4a8(%rsp),%rsi
    a283:	cmp    %rax,%rsi
    a286:	cmovl  0x54a(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    a28e:	cmp    $0x6,%rcx
    a292:	je     a538 <botlish_fn_19+0x91b0>
    a298:	movq   $0x0,0x190(%rsp)
    a2a4:	mov    0x498(%rsp),%rax
    a2ac:	mov    %rax,0x198(%rsp)
    a2b4:	mov    $0x1,%esi
    a2b9:	mov    $0x2,%edx
    a2be:	mov    %r15,%rcx
    a2c1:	mov    0x458(%rsp),%rdi
    a2c9:	call   a2ce <botlish_fn_19+0x8f46>
			a2ca: R_X86_64_PLT32	rt_construct-0x4
    a2ce:	test   %rax,%rax
    a2d1:	je     a5a1 <botlish_fn_19+0x9219>
    a2d7:	movq   $0x3,0x40(%rsp)
    a2e0:	mov    0x4c0(%rsp),%rsi
    a2e8:	test   $0x1,%rsi
    a2ef:	jne    a302 <botlish_fn_19+0x8f7a>
    a2f5:	mov    0x4c0(%rsp),%rsi
    a2fd:	jmp    a339 <botlish_fn_19+0x8fb1>
    a302:	mov    0x4c0(%rsp),%rsi
    a30a:	mov    %rsi,%rax
    a30d:	add    $0x2,%rax
    a311:	seto   %cl
    a314:	test   %cl,%cl
    a316:	je     a329 <botlish_fn_19+0x8fa1>
    a31c:	mov    0x4c0(%rsp),%rsi
    a324:	jmp    a339 <botlish_fn_19+0x8fb1>
    a329:	mov    %rax,%rsi
    a32c:	mov    %rax,0x4c0(%rsp)
    a334:	jmp    a359 <botlish_fn_19+0x8fd1>
    a339:	mov    0x530(%rsp),%rdx
    a341:	mov    0x458(%rsp),%rdi
    a349:	call   a34e <botlish_fn_19+0x8fc6>
			a34a: R_X86_64_PLT32	rt_int_add-0x4
    a34e:	mov    %rax,%rsi
    a351:	mov    %rax,0x4c0(%rsp)
    a359:	mov    %rsi,0x70(%rsp)
    a35e:	mov    0x538(%rsp),%rsi
    a366:	mov    0x4c0(%rsp),%rdi
    a36e:	mov    %rdi,%rax
    a371:	and    %rsi,%rax
    a374:	test   $0x1,%rax
    a37a:	jne    a3b2 <botlish_fn_19+0x902a>
    a380:	mov    0x538(%rsp),%rdx
    a388:	mov    0x4c0(%rsp),%rsi
    a390:	mov    0x458(%rsp),%rdi
    a398:	call   a39d <botlish_fn_19+0x9015>
			a399: R_X86_64_PLT32	rt_int_cmp-0x4
    a39d:	mov    $0x2,%ecx
    a3a2:	test   %rax,%rax
    a3a5:	cmovl  0x42b(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    a3ad:	jmp    a3d2 <botlish_fn_19+0x904a>
    a3b2:	mov    $0x2,%ecx
    a3b7:	mov    0x4c0(%rsp),%rax
    a3bf:	mov    0x538(%rsp),%rsi
    a3c7:	cmp    %rsi,%rax
    a3ca:	cmovl  0x406(%rip),%rcx        # a7d8 <botlish_fn_19+0x9450>
    a3d2:	cmp    $0x6,%rcx
    a3d6:	je     a423 <botlish_fn_19+0x909b>
    a3dc:	movq   $0xffffffffffffffff,0x50(%rsp)
    a3e5:	mov    $0xa,%eax
    a3ea:	mov    %rax,0x498(%rsp)
    a3f2:	movq   $0xa,0x90(%rsp)
    a3fe:	mov    0x520(%rsp),%rcx
    a406:	mov    0x500(%rsp),%r15
    a40e:	mov    0x500(%rsp),%rax
    a416:	mov    %rax,0x4a0(%rsp)
    a41e:	jmp    a68b <botlish_fn_19+0x9303>
    a423:	mov    0x4c0(%rsp),%rsi
    a42b:	test   $0x1,%rsi
    a432:	je     a45b <botlish_fn_19+0x90d3>
    a438:	mov    0x460(%rsp),%rcx
    a440:	mov    0x8(%rcx),%rcx
    a444:	mov    0x4c0(%rsp),%rsi
    a44c:	mov    %rsi,%rax
    a44f:	sar    $1,%rax
    a452:	cmp    %rcx,%rax
    a455:	jb     a499 <botlish_fn_19+0x9111>
    a45b:	mov    0x4c0(%rsp),%rdx
    a463:	mov    0x460(%rsp),%rsi
    a46b:	mov    0x458(%rsp),%rdi
    a473:	call   a478 <botlish_fn_19+0x90f0>
			a474: R_X86_64_PLT32	rt_list_get-0x4
    a478:	mov    %rax,%rcx
    a47b:	mov    %rax,0x4b8(%rsp)
    a483:	test   %rcx,%rax
    a486:	je     a5a1 <botlish_fn_19+0x9219>
    a48c:	mov    0x4b8(%rsp),%rax
    a494:	jmp    a4b1 <botlish_fn_19+0x9129>
    a499:	mov    0x460(%rsp),%rcx
    a4a1:	mov    0x10(%rcx),%rcx
    a4a5:	mov    (%rcx,%rax,8),%rax
    a4a9:	mov    %rax,0x4b8(%rsp)
    a4b1:	mov    %rax,0x78(%rsp)
    a4b6:	mov    0x4b8(%rsp),%rsi
    a4be:	mov    0x458(%rsp),%rdi
    a4c6:	call   a4cb <botlish_fn_19+0x9143>
			a4c7: R_X86_64_PLT32	rt_list_len-0x4
    a4cb:	mov    %rax,0x4b0(%rsp)
    a4d3:	mov    %rax,0x80(%rsp)
    a4db:	movq   $0x1,0x88(%rsp)
    a4e7:	xor    %rdx,%rdx
    a4ea:	mov    0x458(%rsp),%rdi
    a4f2:	mov    %rdx,%rsi
    a4f5:	call   a4fa <botlish_fn_19+0x9172>
			a4f6: R_X86_64_PLT32	rt_list_new-0x4
    a4fa:	mov    %rax,%rcx
    a4fd:	mov    %rax,0x498(%rsp)
    a505:	test   %rcx,%rax
    a508:	je     a5a1 <botlish_fn_19+0x9219>
    a50e:	mov    0x498(%rsp),%rax
    a516:	mov    %rax,0x90(%rsp)
    a51e:	mov    $0x1,%esi
    a523:	mov    %rsi,0x4a8(%rsp)
    a52b:	mov    0x4b0(%rsp),%rax
    a533:	jmp    a229 <botlish_fn_19+0x8ea1>
    a538:	mov    0x4a8(%rsp),%rsi
    a540:	test   $0x1,%rsi
    a547:	je     a570 <botlish_fn_19+0x91e8>
    a54d:	mov    0x4b8(%rsp),%rax
    a555:	mov    0x8(%rax),%r9
    a559:	mov    0x4a8(%rsp),%rsi
    a561:	mov    %rsi,%r8
    a564:	sar    $1,%r8
    a567:	cmp    %r9,%r8
    a56a:	jb     a660 <botlish_fn_19+0x92d8>
    a570:	mov    0x4a8(%rsp),%rdx
    a578:	mov    0x4b8(%rsp),%rsi
    a580:	mov    0x458(%rsp),%rdi
    a588:	call   a58d <botlish_fn_19+0x9205>
			a589: R_X86_64_PLT32	rt_list_get-0x4
    a58d:	mov    %rax,%rcx
    a590:	mov    %rax,0x4a0(%rsp)
    a598:	test   %rcx,%rax
    a59b:	jne    a653 <botlish_fn_19+0x92cb>
    a5a1:	mov    0x458(%rsp),%rdi
    a5a9:	call   a5ae <botlish_fn_19+0x9226>
			a5aa: R_X86_64_PLT32	rt_co_failed-0x4
    a5ae:	mov    %rax,0x58(%rsp)
    a5b3:	movq   $0xa,0x90(%rsp)
    a5bf:	mov    %rax,%rsi
    a5c2:	mov    0x458(%rsp),%rdi
    a5ca:	call   a5cf <botlish_fn_19+0x9247>
			a5cb: R_X86_64_PLT32	rt_co_resume0-0x4
    a5cf:	test   %rax,%rax
    a5d2:	jne    a5e5 <botlish_fn_19+0x925d>
    a5d8:	mov    0x458(%rsp),%rdi
    a5e0:	jmp    a609 <botlish_fn_19+0x9281>
    a5e5:	mov    0x458(%rsp),%rdi
    a5ed:	mov    0x10(%rdi),%rax
    a5f1:	mov    0x48(%rax),%rsi
    a5f5:	mov    0x1b8(%rax),%rdx
    a5fc:	call   a601 <botlish_fn_19+0x9279>
			a5fd: R_X86_64_PLT32	rt_raise-0x4
    a601:	mov    0x458(%rsp),%rdi
    a609:	mov    0x458(%rsp),%rdi
    a611:	call   a616 <botlish_fn_19+0x928e>
			a612: R_X86_64_PLT32	rt_declared_error-0x4
    a616:	cmp    $0x40000001,%rax
    a61c:	xor    %rax,%rax
    a61f:	mov    0x540(%rsp),%rbx
    a627:	mov    0x548(%rsp),%r12
    a62f:	mov    0x550(%rsp),%r13
    a637:	mov    0x558(%rsp),%r14
    a63f:	mov    0x560(%rsp),%r15
    a647:	add    $0x570,%rsp
    a64e:	mov    %rbp,%rsp
    a651:	pop    %rbp
    a652:	ret
    a653:	mov    0x4a0(%rsp),%rax
    a65b:	jmp    a678 <botlish_fn_19+0x92f0>
    a660:	mov    0x4b8(%rsp),%rax
    a668:	mov    0x10(%rax),%rax
    a66c:	mov    (%rax,%r8,8),%rax
    a670:	mov    %rax,0x4a0(%rsp)
    a678:	mov    %rax,0x50(%rsp)
    a67d:	mov    $0x1,%r15d
    a683:	mov    0x520(%rsp),%rcx
    a68b:	mov    0x520(%rsp),%rcx
    a693:	mov    0x18(%rcx),%rax
    a697:	test   %rax,%rax
    a69a:	je     a7af <botlish_fn_19+0x9427>
    a6a0:	mov    0x520(%rsp),%rcx
    a6a8:	mov    0x10(%rcx),%rax
    a6ac:	mov    0x4a0(%rsp),%rcx
    a6b4:	mov    %rcx,(%rax)
    a6b7:	mov    0x520(%rsp),%rcx
    a6bf:	mov    %r14,0x468(%rsp)
    a6c7:	mov    %r15,0x488(%rsp)
    a6cf:	mov    %r13,0x490(%rsp)
    a6d7:	mov    %rbx,0x4c8(%rsp)
    a6df:	mov    %r12,0x510(%rsp)
    a6e7:	jmp    1bf1 <botlish_fn_19+0x869>
    a6ec:	mov    $0x1,%edx
    a6f1:	mov    %r13,%rcx
    a6f4:	mov    0x508(%rsp),%rsi
    a6fc:	mov    0x458(%rsp),%rdi
    a704:	call   a709 <botlish_fn_19+0x9381>
			a705: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a709:	jmp    3612 <botlish_fn_19+0x228a>
    a70e:	mov    $0x1,%edx
    a713:	mov    0x518(%rsp),%rsi
    a71b:	mov    0x458(%rsp),%rdi
    a723:	call   a728 <botlish_fn_19+0x93a0>
			a724: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a728:	jmp    36da <botlish_fn_19+0x2352>
    a72d:	mov    $0x1,%edx
    a732:	mov    0x4a0(%rsp),%rcx
    a73a:	mov    0x520(%rsp),%rsi
    a742:	mov    0x458(%rsp),%rdi
    a74a:	call   a74f <botlish_fn_19+0x93c7>
			a74b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a74f:	jmp    3ca4 <botlish_fn_19+0x291c>
    a754:	mov    $0x1,%edx
    a759:	mov    %r13,%rcx
    a75c:	mov    0x508(%rsp),%rsi
    a764:	mov    0x458(%rsp),%rdi
    a76c:	call   a771 <botlish_fn_19+0x93e9>
			a76d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a771:	jmp    8eb9 <botlish_fn_19+0x7b31>
    a776:	mov    $0x1,%edx
    a77b:	mov    %r12,%rsi
    a77e:	mov    0x458(%rsp),%rdi
    a786:	call   a78b <botlish_fn_19+0x9403>
			a787: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a78b:	jmp    98d2 <botlish_fn_19+0x854a>
    a790:	mov    $0x1,%edx
    a795:	mov    0x518(%rsp),%rsi
    a79d:	mov    0x458(%rsp),%rdi
    a7a5:	call   a7aa <botlish_fn_19+0x9422>
			a7a6: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a7aa:	jmp    a0cb <botlish_fn_19+0x8d43>
    a7af:	mov    $0x1,%edx
    a7b4:	mov    0x4a0(%rsp),%rcx
    a7bc:	mov    0x520(%rsp),%rsi
    a7c4:	mov    0x458(%rsp),%rdi
    a7cc:	call   a7d1 <botlish_fn_19+0x9449>
			a7cd: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a7d1:	jmp    a6b7 <botlish_fn_19+0x932f>
    a7d6:	add    %al,(%rax)
    a7d8:	(bad)
    a7d9:	add    %al,(%rax)
    a7db:	add    %al,(%rax)
    a7dd:	add    %al,(%rax)
	...

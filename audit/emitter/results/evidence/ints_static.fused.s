<botlish_fn_7>:
    12e0:	push   %rbp
    12e1:	mov    %rsp,%rbp
    12e4:	sub    $0x1e0,%rsp
    12eb:	mov    %rbx,0x1b0(%rsp)
    12f3:	mov    %r12,0x1b8(%rsp)
    12fb:	mov    %r13,0x1c0(%rsp)
    1303:	mov    %r14,0x1c8(%rsp)
    130b:	mov    %r15,0x1d0(%rsp)
    1313:	mov    %rdi,0xf0(%rsp)
    131b:	mov    %rsi,0xf8(%rsp)
    1323:	movq   $0x0,0x10(%rsp)
    132c:	movq   $0x0,0x18(%rsp)
    1335:	movq   $0x0,0x20(%rsp)
    133e:	movq   $0x0,0x28(%rsp)
    1347:	movq   $0x0,0x30(%rsp)
    1350:	movq   $0x0,0x38(%rsp)
    1359:	movq   $0x0,0x40(%rsp)
    1362:	movq   $0x0,0x48(%rsp)
    136b:	movq   $0x0,0x50(%rsp)
    1374:	movq   $0x0,0x58(%rsp)
    137d:	movq   $0x0,0x60(%rsp)
    1386:	movq   $0x0,0x68(%rsp)
    138f:	movq   $0x0,0x70(%rsp)
    1398:	movq   $0x0,0x78(%rsp)
    13a1:	movq   $0x0,0x80(%rsp)
    13ad:	movq   $0x0,0x88(%rsp)
    13b9:	movq   $0x0,0x90(%rsp)
    13c5:	movq   $0x0,0x98(%rsp)
    13d1:	movq   $0x0,0xa0(%rsp)
    13dd:	movq   $0x0,0xa8(%rsp)
    13e9:	movq   $0x0,0xb0(%rsp)
    13f5:	movq   $0x0,0xb8(%rsp)
    1401:	mov    $0x7,%esi
    1406:	movq   $0x7,(%rsp)
    140e:	mov    $0x1,%edx
    1413:	movq   $0x1,0x8(%rsp)
    141c:	mov    0xf0(%rsp),%rdi
    1424:	call   1429 <botlish_fn_7+0x149>
			1425: R_X86_64_PLT32	rt_mutarray_create-0x4
    1429:	test   %rax,%rax
    142c:	je     2735 <botlish_fn_7+0x1455>
    1432:	mov    %rax,(%rsp)
    1436:	mov    %rax,0x1a8(%rsp)
    143e:	xor    %rcx,%rcx
    1441:	mov    %rcx,0x108(%rsp)
    1449:	mov    0xf8(%rsp),%rax
    1451:	cmp    %rax,%rcx
    1454:	mov    %rax,0xf8(%rsp)
    145c:	jl     14e9 <botlish_fn_7+0x209>
    1462:	mov    0x1a8(%rsp),%rcx
    146a:	mov    0x10(%rcx),%rax
    146e:	mov    0x8(%rax),%rax
    1472:	mov    %rax,0x8(%rsp)
    1477:	mov    0x10(%rcx),%rcx
    147b:	mov    (%rcx),%rcx
    147e:	mov    %rcx,(%rsp)
    1482:	lea    0xc0(%rsp),%rdx
    148a:	mov    %rax,0xc0(%rsp)
    1492:	mov    %rcx,0xc8(%rsp)
    149a:	mov    $0x2,%esi
    149f:	mov    0xf0(%rsp),%rdi
    14a7:	call   14ac <botlish_fn_7+0x1cc>
			14a8: R_X86_64_PLT32	rt_list_new-0x4
    14ac:	test   %rax,%rax
    14af:	je     2735 <botlish_fn_7+0x1455>
    14b5:	mov    0x1b0(%rsp),%rbx
    14bd:	mov    0x1b8(%rsp),%r12
    14c5:	mov    0x1c0(%rsp),%r13
    14cd:	mov    0x1c8(%rsp),%r14
    14d5:	mov    0x1d0(%rsp),%r15
    14dd:	add    $0x1e0,%rsp
    14e4:	mov    %rbp,%rsp
    14e7:	pop    %rbp
    14e8:	ret
    14e9:	mov    %rcx,%rsi
    14ec:	shl    $1,%rsi
    14ef:	mov    %rcx,0x108(%rsp)
    14f7:	or     $0x1,%rsi
    14fb:	mov    %rsi,0x8(%rsp)
    1500:	mov    0xf0(%rsp),%rdi
    1508:	call   150d <botlish_fn_7+0x22d>
			1509: R_X86_64_PLT32	botlish_fn_6-0x4
    150d:	mov    %rax,%rcx
    1510:	mov    %rax,0x1a0(%rsp)
    1518:	test   %rcx,%rax
    151b:	je     2735 <botlish_fn_7+0x1455>
    1521:	movq   $0xa,0x38(%rsp)
    152a:	movq   $0xa,0x40(%rsp)
    1533:	movq   $0xa,0x48(%rsp)
    153c:	movq   $0xa,0x50(%rsp)
    1545:	movq   $0xa,0x58(%rsp)
    154e:	movq   $0xa,0x60(%rsp)
    1557:	movq   $0xa,0x68(%rsp)
    1560:	movq   $0xa,0x70(%rsp)
    1569:	movq   $0xa,0x78(%rsp)
    1572:	movq   $0xa,0x80(%rsp)
    157e:	movq   $0xa,0x88(%rsp)
    158a:	movq   $0xa,0x90(%rsp)
    1596:	movq   $0xa,0x98(%rsp)
    15a2:	movq   $0xa,0xa0(%rsp)
    15ae:	movq   $0xa,0xa8(%rsp)
    15ba:	movq   $0xa,0xb0(%rsp)
    15c6:	movq   $0xa,0xb8(%rsp)
    15d2:	movq   $0xa,0x28(%rsp)
    15db:	movq   $0xa,0x30(%rsp)
    15e4:	mov    0x1a0(%rsp),%rax
    15ec:	mov    %rax,0x38(%rsp)
    15f1:	mov    0x1a0(%rsp),%rax
    15f9:	test   $0x1,%rax
    15ff:	jne    1634 <botlish_fn_7+0x354>
    1605:	mov    $0x1,%edx
    160a:	mov    0x1a0(%rsp),%rsi
    1612:	mov    0xf0(%rsp),%rdi
    161a:	call   161f <botlish_fn_7+0x33f>
			161b: R_X86_64_PLT32	rt_int_cmp-0x4
    161f:	mov    $0x2,%ecx
    1624:	test   %rax,%rax
    1627:	cmove  0x12c9(%rip),%rcx        # 28f8 <botlish_fn_7+0x1618>
    162f:	jmp    164d <botlish_fn_7+0x36d>
    1634:	mov    $0x2,%ecx
    1639:	mov    0x1a0(%rsp),%rax
    1641:	cmp    $0x1,%rax
    1645:	cmove  0x12ab(%rip),%rcx        # 28f8 <botlish_fn_7+0x1618>
    164d:	mov    $0x6,%eax
    1652:	mov    %rax,0x198(%rsp)
    165a:	cmp    $0x6,%rcx
    165e:	je     1a12 <botlish_fn_7+0x732>
    1664:	mov    0x1a0(%rsp),%rax
    166c:	test   $0x1,%rax
    1672:	jne    16a7 <botlish_fn_7+0x3c7>
    1678:	mov    $0x1,%edx
    167d:	mov    0x1a0(%rsp),%rsi
    1685:	mov    0xf0(%rsp),%rdi
    168d:	call   1692 <botlish_fn_7+0x3b2>
			168e: R_X86_64_PLT32	rt_int_cmp-0x4
    1692:	mov    $0x2,%ecx
    1697:	test   %rax,%rax
    169a:	cmovl  0x1256(%rip),%rcx        # 28f8 <botlish_fn_7+0x1618>
    16a2:	jmp    16c7 <botlish_fn_7+0x3e7>
    16a7:	mov    $0x2,%ecx
    16ac:	mov    0x1a0(%rsp),%rax
    16b4:	mov    0x1a0(%rsp),%rdx
    16bc:	test   %rdx,%rax
    16bf:	cmovle 0x1231(%rip),%rcx        # 28f8 <botlish_fn_7+0x1618>
    16c7:	cmp    $0x6,%rcx
    16cb:	je     19d1 <botlish_fn_7+0x6f1>
    16d1:	mov    0x1a0(%rsp),%rax
    16d9:	mov    %rax,0x80(%rsp)
    16e1:	movq   $0x3,0x10(%rsp)
    16ea:	lea    0xd8(%rsp),%rdx
    16f2:	movq   $0x3,0xd8(%rsp)
    16fe:	mov    $0x1,%esi
    1703:	mov    0xf0(%rsp),%rdi
    170b:	call   1710 <botlish_fn_7+0x430>
			170c: R_X86_64_PLT32	rt_list_new-0x4
    1710:	test   %rax,%rax
    1713:	je     18eb <botlish_fn_7+0x60b>
    1719:	mov    %rax,0x10(%rsp)
    171e:	mov    %rax,%rsi
    1721:	mov    0xf0(%rsp),%rdi
    1729:	call   172e <botlish_fn_7+0x44e>
			172a: R_X86_64_PLT32	rt_mv_from_list-0x4
    172e:	mov    %rax,0x88(%rsp)
    1736:	mov    %rax,0x168(%rsp)
    173e:	mov    $0x2,%ebx
    1743:	mov    0x168(%rsp),%rsi
    174b:	mov    0xf0(%rsp),%rdi
    1753:	call   1758 <botlish_fn_7+0x478>
			1754: R_X86_64_PLT32	rt_mv_len-0x4
    1758:	sar    $1,%rax
    175b:	sub    $0x1,%rax
    175f:	shl    $1,%rax
    1762:	mov    %rax,%rdx
    1765:	or     $0x1,%rdx
    1769:	mov    0x168(%rsp),%rsi
    1771:	mov    0xf0(%rsp),%rdi
    1779:	call   177e <botlish_fn_7+0x49e>
			177a: R_X86_64_PLT32	rt_mv_at-0x4
    177e:	mov    %rax,%rcx
    1781:	mov    %rax,%rsi
    1784:	test   %rcx,%rax
    1787:	je     18eb <botlish_fn_7+0x60b>
    178d:	mov    %rsi,%rax
    1790:	mov    %rax,0x10(%rsp)
    1795:	movq   $0x15,0x18(%rsp)
    179e:	test   $0x1,%rax
    17a4:	je     17d9 <botlish_fn_7+0x4f9>
    17aa:	mov    %rsi,%rax
    17ad:	sar    $1,%rax
    17b0:	imulq  0x1149(%rip)        # 2900 <botlish_fn_7+0x1620>
    17b7:	seto   %cl
    17ba:	or     $0x1,%rax
    17be:	test   %cl,%cl
    17c0:	jne    17d9 <botlish_fn_7+0x4f9>
    17c6:	mov    %rsi,%r13
    17c9:	mov    0x1a0(%rsp),%r12
    17d1:	mov    %rax,%rsi
    17d4:	jmp    17f9 <botlish_fn_7+0x519>
    17d9:	mov    $0x15,%edx
    17de:	mov    %rsi,%r13
    17e1:	mov    0xf0(%rsp),%rdi
    17e9:	call   17ee <botlish_fn_7+0x50e>
			17ea: R_X86_64_PLT32	rt_int_mul-0x4
    17ee:	mov    %rax,%rsi
    17f1:	mov    0x1a0(%rsp),%r12
    17f9:	mov    %rsi,%rax
    17fc:	and    %r12,%rax
    17ff:	test   $0x1,%rax
    1805:	jne    182e <botlish_fn_7+0x54e>
    180b:	mov    %r12,%rdx
    180e:	mov    0xf0(%rsp),%rdi
    1816:	call   181b <botlish_fn_7+0x53b>
			1817: R_X86_64_PLT32	rt_int_cmp-0x4
    181b:	test   %rax,%rax
    181e:	mov    %rbx,%rcx
    1821:	cmovg  0x10cf(%rip),%rcx        # 28f8 <botlish_fn_7+0x1618>
    1829:	jmp    183c <botlish_fn_7+0x55c>
    182e:	cmp    %r12,%rsi
    1831:	mov    %rbx,%rcx
    1834:	cmovg  0x10bc(%rip),%rcx        # 28f8 <botlish_fn_7+0x1618>
    183c:	cmp    $0x6,%rcx
    1840:	je     18c2 <botlish_fn_7+0x5e2>
    1846:	movq   $0x15,0x18(%rsp)
    184f:	test   $0x1,%r13
    1856:	jne    1864 <botlish_fn_7+0x584>
    185c:	mov    %r13,%rsi
    185f:	jmp    188b <botlish_fn_7+0x5ab>
    1864:	mov    %r13,%rax
    1867:	sar    $1,%rax
    186a:	mov    %r13,%rsi
    186d:	imulq  0x108c(%rip)        # 2900 <botlish_fn_7+0x1620>
    1874:	seto   %cl
    1877:	or     $0x1,%rax
    187b:	test   %cl,%cl
    187d:	jne    188b <botlish_fn_7+0x5ab>
    1883:	mov    %rax,%rdx
    1886:	jmp    18a0 <botlish_fn_7+0x5c0>
    188b:	mov    $0x15,%edx
    1890:	mov    0xf0(%rsp),%rdi
    1898:	call   189d <botlish_fn_7+0x5bd>
			1899: R_X86_64_PLT32	rt_int_mul-0x4
    189d:	mov    %rax,%rdx
    18a0:	mov    0x168(%rsp),%rsi
    18a8:	mov    0xf0(%rsp),%rdi
    18b0:	call   18b5 <botlish_fn_7+0x5d5>
			18b1: R_X86_64_PLT32	rt_mv_push-0x4
    18b5:	mov    %r12,0x1a0(%rsp)
    18bd:	jmp    1743 <botlish_fn_7+0x463>
    18c2:	mov    0x168(%rsp),%rsi
    18ca:	mov    0xf0(%rsp),%rdi
    18d2:	call   18d7 <botlish_fn_7+0x5f7>
			18d3: R_X86_64_PLT32	rt_mv_pop-0x4
    18d7:	mov    %rax,%rcx
    18da:	mov    %rax,0x120(%rsp)
    18e2:	test   %rcx,%rax
    18e5:	jne    1961 <botlish_fn_7+0x681>
    18eb:	mov    0xf0(%rsp),%rdi
    18f3:	call   18f8 <botlish_fn_7+0x618>
			18f4: R_X86_64_PLT32	rt_co_failed-0x4
    18f8:	mov    %rax,0x30(%rsp)
    18fd:	mov    %rax,%rsi
    1900:	mov    0xf0(%rsp),%rdi
    1908:	call   190d <botlish_fn_7+0x62d>
			1909: R_X86_64_PLT32	rt_co_resume0-0x4
    190d:	test   %rax,%rax
    1910:	jne    1923 <botlish_fn_7+0x643>
    1916:	mov    0xf0(%rsp),%rdi
    191e:	jmp    1943 <botlish_fn_7+0x663>
    1923:	mov    0xf0(%rsp),%rdi
    192b:	mov    0x10(%rdi),%r11
    192f:	mov    (%r11),%rsi
    1932:	mov    0x30(%r11),%rdx
    1936:	call   193b <botlish_fn_7+0x65b>
			1937: R_X86_64_PLT32	rt_raise-0x4
    193b:	mov    0xf0(%rsp),%rdi
    1943:	mov    0xf0(%rsp),%rdi
    194b:	call   1950 <botlish_fn_7+0x670>
			194c: R_X86_64_PLT32	rt_declared_error-0x4
    1950:	cmp    $0x40000001,%rax
    1956:	jne    2735 <botlish_fn_7+0x1455>
    195c:	jmp    2735 <botlish_fn_7+0x1455>
    1961:	mov    0x120(%rsp),%rax
    1969:	mov    %rax,0x90(%rsp)
    1971:	mov    0x120(%rsp),%rdx
    1979:	mov    %r12,%rsi
    197c:	mov    0xf0(%rsp),%rdi
    1984:	call   1989 <botlish_fn_7+0x6a9>
			1985: R_X86_64_PLT32	botlish_fn_2-0x4
    1989:	mov    %rax,0x118(%rsp)
    1991:	mov    %r12,0x1a0(%rsp)
    1999:	mov    %rax,0x98(%rsp)
    19a1:	sar    $1,%rax
    19a4:	lea    0x30(%rax),%r14
    19a8:	shl    $1,%r14
    19ab:	or     $0x1,%r14
    19af:	mov    %r14,0x28(%rsp)
    19b4:	mov    $0x5,%ecx
    19b9:	mov    %rcx,%rbx
    19bc:	mov    0x1a0(%rsp),%rax
    19c4:	mov    %rax,0x160(%rsp)
    19cc:	jmp    1a4e <botlish_fn_7+0x76e>
    19d1:	mov    $0x5b,%r14d
    19d7:	movq   $0x5b,0x28(%rsp)
    19e0:	mov    $0x2,%ecx
    19e5:	mov    $0xa,%eax
    19ea:	mov    %rax,0x118(%rsp)
    19f2:	mov    %rcx,%rbx
    19f5:	mov    %rax,0x120(%rsp)
    19fd:	mov    %rax,0x160(%rsp)
    1a05:	mov    %rax,0x168(%rsp)
    1a0d:	jmp    1a4e <botlish_fn_7+0x76e>
    1a12:	mov    $0x61,%r14d
    1a18:	movq   $0x61,0x28(%rsp)
    1a21:	mov    $0x1,%ecx
    1a26:	mov    %rcx,%rbx
    1a29:	mov    $0xa,%eax
    1a2e:	mov    %rax,0x118(%rsp)
    1a36:	mov    %rax,0x120(%rsp)
    1a3e:	mov    %rax,0x160(%rsp)
    1a46:	mov    %rax,0x168(%rsp)
    1a4e:	mov    0x1a8(%rsp),%r8
    1a56:	mov    0x18(%r8),%rax
    1a5a:	test   %rax,%rax
    1a5d:	je     2830 <botlish_fn_7+0x1550>
    1a63:	mov    0x1a8(%rsp),%r8
    1a6b:	mov    0x10(%r8),%rax
    1a6f:	mov    %r14,0x10(%rax)
    1a73:	mov    $0xa,%eax
    1a78:	mov    %rax,0x110(%rsp)
    1a80:	mov    $0x3,%eax
    1a85:	mov    %rax,0x190(%rsp)
    1a8d:	mov    $0x2,%r12d
    1a93:	mov    %r12,0x188(%rsp)
    1a9b:	mov    $0x7fffffff,%eax
    1aa0:	mov    %rax,%r13
    1aa3:	neg    %r13
    1aa6:	cmovs  %rax,%r13
    1aaa:	mov    %r13,0x180(%rsp)
    1ab2:	mov    %rbx,%rdi
    1ab5:	mov    0x110(%rsp),%r12
    1abd:	mov    0x110(%rsp),%r13
    1ac5:	mov    0x110(%rsp),%rax
    1acd:	mov    %rax,0x100(%rsp)
    1ad5:	mov    %rax,0x128(%rsp)
    1add:	mov    %rax,0x130(%rsp)
    1ae5:	mov    %rax,0x138(%rsp)
    1aed:	mov    %rax,0x140(%rsp)
    1af5:	mov    %rax,0x148(%rsp)
    1afd:	mov    %rax,0x150(%rsp)
    1b05:	mov    %rax,0x158(%rsp)
    1b0d:	mov    %rax,0x170(%rsp)
    1b15:	test   %rdi,%rdi
    1b18:	mov    %rdi,%rbx
    1b1b:	jl     2814 <botlish_fn_7+0x1534>
    1b21:	movq   $0x1,0x8(%rsp)
    1b2a:	mov    0x1a8(%rsp),%r8
    1b32:	mov    0x10(%r8),%rax
    1b36:	mov    (%rax),%rsi
    1b39:	mov    %rsi,0x10(%rsp)
    1b3e:	mov    0x1a8(%rsp),%r8
    1b46:	mov    0x10(%r8),%rax
    1b4a:	mov    0x10(%rax),%rdx
    1b4e:	mov    %rdx,0x18(%rsp)
    1b53:	mov    %rdx,%r15
    1b56:	movq   $0x3f,0x20(%rsp)
    1b5f:	test   $0x1,%rsi
    1b66:	je     1b90 <botlish_fn_7+0x8b0>
    1b6c:	mov    %rsi,%rax
    1b6f:	sar    $1,%rax
    1b72:	imulq  0xd8f(%rip)        # 2908 <botlish_fn_7+0x1628>
    1b79:	seto   %cl
    1b7c:	or     $0x1,%rax
    1b80:	test   %cl,%cl
    1b82:	jne    1b90 <botlish_fn_7+0x8b0>
    1b88:	mov    %rax,%rsi
    1b8b:	jmp    1ba5 <botlish_fn_7+0x8c5>
    1b90:	mov    $0x3f,%edx
    1b95:	mov    0xf0(%rsp),%rdi
    1b9d:	call   1ba2 <botlish_fn_7+0x8c2>
			1b9e: R_X86_64_PLT32	rt_int_mul-0x4
    1ba2:	mov    %rax,%rsi
    1ba5:	mov    %rsi,0x10(%rsp)
    1baa:	mov    %r15,%rdx
    1bad:	mov    %rsi,%rax
    1bb0:	and    %rdx,%rax
    1bb3:	test   $0x1,%rax
    1bb9:	je     1bd4 <botlish_fn_7+0x8f4>
    1bbf:	lea    -0x1(%rdx),%rcx
    1bc3:	mov    %rsi,%rax
    1bc6:	add    %rcx,%rax
    1bc9:	seto   %cl
    1bcc:	test   %cl,%cl
    1bce:	je     1be1 <botlish_fn_7+0x901>
    1bd4:	mov    0xf0(%rsp),%rdi
    1bdc:	call   1be1 <botlish_fn_7+0x901>
			1bdd: R_X86_64_PLT32	rt_int_add-0x4
    1be1:	mov    %rax,0x10(%rsp)
    1be6:	movq   $0x3,0x18(%rsp)
    1bef:	test   $0x1,%rax
    1bf5:	jne    1c03 <botlish_fn_7+0x923>
    1bfb:	mov    %rax,%rsi
    1bfe:	jmp    1c1b <botlish_fn_7+0x93b>
    1c03:	mov    %rax,%rsi
    1c06:	add    $0x2,%rsi
    1c0a:	mov    %rax,%rcx
    1c0d:	seto   %al
    1c10:	test   %al,%al
    1c12:	je     1c33 <botlish_fn_7+0x953>
    1c18:	mov    %rcx,%rsi
    1c1b:	mov    0x190(%rsp),%rdx
    1c23:	mov    0xf0(%rsp),%rdi
    1c2b:	call   1c30 <botlish_fn_7+0x950>
			1c2c: R_X86_64_PLT32	rt_int_add-0x4
    1c30:	mov    %rax,%rsi
    1c33:	mov    %rsi,0x10(%rsp)
    1c38:	mov    $0xffffffff,%edi
    1c3d:	mov    %rdi,0x18(%rsp)
    1c42:	test   $0x1,%rsi
    1c49:	jne    1c98 <botlish_fn_7+0x9b8>
    1c4f:	mov    $0xffffffff,%edx
    1c54:	mov    0xf0(%rsp),%rdi
    1c5c:	call   1c61 <botlish_fn_7+0x981>
			1c5d: R_X86_64_PLT32	rt_int_mod-0x4
    1c61:	test   %rax,%rax
    1c64:	jne    1c88 <botlish_fn_7+0x9a8>
    1c6a:	mov    0xf0(%rsp),%rdi
    1c72:	call   1c77 <botlish_fn_7+0x997>
			1c73: R_X86_64_PLT32	rt_declared_error-0x4
    1c77:	cmp    $0x40000001,%rax
    1c7d:	jne    2735 <botlish_fn_7+0x1455>
    1c83:	jmp    2735 <botlish_fn_7+0x1455>
    1c88:	mov    %rax,%rcx
    1c8b:	mov    0x1a8(%rsp),%r8
    1c93:	jmp    1ce6 <botlish_fn_7+0xa06>
    1c98:	sar    $1,%rsi
    1c9b:	mov    %rsi,%rax
    1c9e:	imulq  0xc6b(%rip)        # 2910 <botlish_fn_7+0x1630>
    1ca5:	lea    (%rdx,%rsi,1),%rax
    1ca9:	sar    $0x1e,%rax
    1cad:	mov    %rax,%rcx
    1cb0:	shr    $0x3f,%rcx
    1cb4:	add    %rcx,%rax
    1cb7:	imul   $0x7fffffff,%rax,%rax
    1cbe:	sub    %rax,%rsi
    1cc1:	mov    0x180(%rsp),%rcx
    1cc9:	lea    (%rsi,%rcx,1),%rax
    1ccd:	test   %rsi,%rsi
    1cd0:	cmovl  %rax,%rsi
    1cd4:	shl    $1,%rsi
    1cd7:	or     $0x1,%rsi
    1cdb:	mov    %rsi,%rcx
    1cde:	mov    0x1a8(%rsp),%r8
    1ce6:	mov    0x1a8(%rsp),%r8
    1cee:	mov    0x18(%r8),%rax
    1cf2:	test   %rax,%rax
    1cf5:	je     2852 <botlish_fn_7+0x1572>
    1cfb:	mov    0x1a8(%rsp),%r8
    1d03:	mov    0x10(%r8),%rax
    1d07:	mov    %rcx,(%rax)
    1d0a:	movq   $0x3,0x8(%rsp)
    1d13:	mov    0x1a8(%rsp),%r8
    1d1b:	mov    0x10(%r8),%rax
    1d1f:	mov    0x8(%rax),%rsi
    1d23:	mov    %rsi,0x10(%rsp)
    1d28:	movq   $0x3,0x18(%rsp)
    1d31:	test   $0x1,%rsi
    1d38:	je     1d5d <botlish_fn_7+0xa7d>
    1d3e:	mov    %rsi,%rcx
    1d41:	add    $0x2,%rcx
    1d45:	seto   %al
    1d48:	test   %al,%al
    1d4a:	jne    1d5d <botlish_fn_7+0xa7d>
    1d50:	mov    0x1a8(%rsp),%r8
    1d58:	jmp    1d7d <botlish_fn_7+0xa9d>
    1d5d:	mov    0x190(%rsp),%rdx
    1d65:	mov    0xf0(%rsp),%rdi
    1d6d:	call   1d72 <botlish_fn_7+0xa92>
			1d6e: R_X86_64_PLT32	rt_int_add-0x4
    1d72:	mov    %rax,%rcx
    1d75:	mov    0x1a8(%rsp),%r8
    1d7d:	mov    0x1a8(%rsp),%r8
    1d85:	mov    0x18(%r8),%rax
    1d89:	test   %rax,%rax
    1d8c:	je     2871 <botlish_fn_7+0x1591>
    1d92:	mov    0x1a8(%rsp),%r8
    1d9a:	mov    0x10(%r8),%rax
    1d9e:	mov    %rcx,0x8(%rax)
    1da2:	mov    $0x5,%edx
    1da7:	mov    %rdx,0x178(%rsp)
    1daf:	movq   $0x5,0x8(%rsp)
    1db8:	mov    %rbx,%r15
    1dbb:	cmp    $0x1,%r15
    1dbf:	je     27c4 <botlish_fn_7+0x14e4>
    1dc5:	cmp    $0x2,%r15
    1dc9:	je     241b <botlish_fn_7+0x113b>
    1dcf:	cmp    $0x3,%r15
    1dd3:	je     2242 <botlish_fn_7+0xf62>
    1dd9:	cmp    $0x4,%r15
    1ddd:	je     2132 <botlish_fn_7+0xe52>
    1de3:	cmp    $0x5,%r15
    1de7:	je     1f23 <botlish_fn_7+0xc43>
    1ded:	cmp    $0x6,%r15
    1df1:	je     1e13 <botlish_fn_7+0xb33>
    1df7:	mov    $0xa,%esi
    1dfc:	cmp    $0xffffffffffffffff,%r15
    1e00:	jne    26c6 <botlish_fn_7+0x13e6>
    1e06:	mov    0x188(%rsp),%rbx
    1e0e:	jmp    27df <botlish_fn_7+0x14ff>
    1e13:	movq   $0x1,0x10(%rsp)
    1e1c:	mov    0x148(%rsp),%rax
    1e24:	mov    0x150(%rsp),%rbx
    1e2c:	mov    %rax,%rcx
    1e2f:	and    %rbx,%rcx
    1e32:	test   $0x1,%rcx
    1e39:	je     1e70 <botlish_fn_7+0xb90>
    1e3f:	mov    0x148(%rsp),%rax
    1e47:	sar    $1,%rax
    1e4a:	lea    -0x1(%rbx),%rcx
    1e4e:	imul   %rcx
    1e51:	seto   %cl
    1e54:	or     $0x1,%rax
    1e58:	test   %cl,%cl
    1e5a:	jne    1e70 <botlish_fn_7+0xb90>
    1e60:	mov    %rax,%rdx
    1e63:	mov    %rbx,0x150(%rsp)
    1e6b:	jmp    1e93 <botlish_fn_7+0xbb3>
    1e70:	mov    %rbx,%rdx
    1e73:	mov    0x148(%rsp),%rsi
    1e7b:	mov    0xf0(%rsp),%rdi
    1e83:	call   1e88 <botlish_fn_7+0xba8>
			1e84: R_X86_64_PLT32	rt_int_mul-0x4
    1e88:	mov    %rbx,0x150(%rsp)
    1e90:	mov    %rax,%rdx
    1e93:	mov    %rdx,0x18(%rsp)
    1e98:	mov    0x100(%rsp),%rbx
    1ea0:	mov    %rbx,%rsi
    1ea3:	and    %rdx,%rsi
    1ea6:	test   $0x1,%rsi
    1ead:	je     1edf <botlish_fn_7+0xbff>
    1eb3:	mov    %rbx,%rdi
    1eb6:	sub    %rdx,%rdi
    1eb9:	seto   %r9b
    1ebd:	lea    0x1(%rdi),%rcx
    1ec1:	test   %r9b,%r9b
    1ec4:	jne    1edf <botlish_fn_7+0xbff>
    1eca:	mov    0x170(%rsp),%rax
    1ed2:	mov    %rbx,0x100(%rsp)
    1eda:	jmp    1f02 <botlish_fn_7+0xc22>
    1edf:	mov    %rbx,%rsi
    1ee2:	mov    0xf0(%rsp),%rdi
    1eea:	call   1eef <botlish_fn_7+0xc0f>
			1eeb: R_X86_64_PLT32	rt_int_sub-0x4
    1eef:	mov    %rbx,0x100(%rsp)
    1ef7:	mov    %rax,%rcx
    1efa:	mov    0x170(%rsp),%rax
    1f02:	mov    0x18(%rax),%rax
    1f06:	test   %rax,%rax
    1f09:	je     2893 <botlish_fn_7+0x15b3>
    1f0f:	mov    0x170(%rsp),%rax
    1f17:	mov    0x10(%rax),%rax
    1f1b:	mov    %rcx,(%rax)
    1f1e:	jmp    205c <botlish_fn_7+0xd7c>
    1f23:	movq   $0x3,0x10(%rsp)
    1f2c:	mov    0x120(%rsp),%rsi
    1f34:	mov    0x118(%rsp),%rdi
    1f3c:	mov    %rdi,%rax
    1f3f:	and    %rsi,%rax
    1f42:	test   $0x1,%rax
    1f48:	jne    1f63 <botlish_fn_7+0xc83>
    1f4e:	mov    %rdi,0x118(%rsp)
    1f56:	mov    %rsi,0x120(%rsp)
    1f5e:	jmp    1f97 <botlish_fn_7+0xcb7>
    1f63:	mov    %rdi,%rax
    1f66:	sar    $1,%rax
    1f69:	mov    %rdi,0x118(%rsp)
    1f71:	lea    -0x1(%rsi),%rcx
    1f75:	mov    %rsi,0x120(%rsp)
    1f7d:	imul   %rcx
    1f80:	seto   %cl
    1f83:	or     $0x1,%rax
    1f87:	test   %cl,%cl
    1f89:	jne    1f97 <botlish_fn_7+0xcb7>
    1f8f:	mov    %rax,%rdx
    1f92:	jmp    1fb7 <botlish_fn_7+0xcd7>
    1f97:	mov    0x120(%rsp),%rdx
    1f9f:	mov    0x118(%rsp),%rsi
    1fa7:	mov    0xf0(%rsp),%rdi
    1faf:	call   1fb4 <botlish_fn_7+0xcd4>
			1fb0: R_X86_64_PLT32	rt_int_mul-0x4
    1fb4:	mov    %rax,%rdx
    1fb7:	mov    %rdx,0x18(%rsp)
    1fbc:	mov    0x160(%rsp),%rbx
    1fc4:	mov    %rbx,%rax
    1fc7:	and    %rdx,%rax
    1fca:	test   $0x1,%rax
    1fd0:	je     2003 <botlish_fn_7+0xd23>
    1fd6:	mov    %rbx,%rsi
    1fd9:	sub    %rdx,%rsi
    1fdc:	mov    %rdx,%rax
    1fdf:	seto   %cl
    1fe2:	lea    0x1(%rsi),%rdx
    1fe6:	test   %cl,%cl
    1fe8:	je     1ff6 <botlish_fn_7+0xd16>
    1fee:	mov    %rax,%rdx
    1ff1:	jmp    2003 <botlish_fn_7+0xd23>
    1ff6:	mov    %rbx,0x160(%rsp)
    1ffe:	jmp    201e <botlish_fn_7+0xd3e>
    2003:	mov    %rbx,%rsi
    2006:	mov    0xf0(%rsp),%rdi
    200e:	call   2013 <botlish_fn_7+0xd33>
			200f: R_X86_64_PLT32	rt_int_sub-0x4
    2013:	mov    %rbx,0x160(%rsp)
    201b:	mov    %rax,%rdx
    201e:	mov    %rdx,0x18(%rsp)
    2023:	mov    0x190(%rsp),%rsi
    202b:	mov    0xf0(%rsp),%rdi
    2033:	call   2038 <botlish_fn_7+0xd58>
			2034: R_X86_64_PLT32	rt_mutarray_create-0x4
    2038:	mov    %rax,%rcx
    203b:	mov    %rax,0x170(%rsp)
    2043:	test   %rcx,%rax
    2046:	je     26b1 <botlish_fn_7+0x13d1>
    204c:	mov    0x170(%rsp),%rax
    2054:	mov    %rax,0xa0(%rsp)
    205c:	mov    0x168(%rsp),%rsi
    2064:	mov    0xf0(%rsp),%rdi
    206c:	call   2071 <botlish_fn_7+0xd91>
			206d: R_X86_64_PLT32	rt_mv_empty-0x4
    2071:	cmp    $0x6,%rax
    2075:	je     2128 <botlish_fn_7+0xe48>
    207b:	mov    0x168(%rsp),%rsi
    2083:	mov    0xf0(%rsp),%rdi
    208b:	call   2090 <botlish_fn_7+0xdb0>
			208c: R_X86_64_PLT32	rt_mv_pop-0x4
    2090:	mov    %rax,%rcx
    2093:	mov    %rax,0x150(%rsp)
    209b:	test   %rcx,%rax
    209e:	je     26b1 <botlish_fn_7+0x13d1>
    20a4:	mov    0x150(%rsp),%rax
    20ac:	mov    %rax,0xa8(%rsp)
    20b4:	mov    0x170(%rsp),%rax
    20bc:	mov    0x10(%rax),%rax
    20c0:	mov    (%rax),%rcx
    20c3:	mov    %rcx,0x100(%rsp)
    20cb:	mov    %rcx,0xb0(%rsp)
    20d3:	mov    0x150(%rsp),%rdx
    20db:	mov    0x100(%rsp),%rsi
    20e3:	mov    0xf0(%rsp),%rdi
    20eb:	call   20f0 <botlish_fn_7+0xe10>
			20ec: R_X86_64_PLT32	botlish_fn_1-0x4
    20f0:	mov    %rax,0x148(%rsp)
    20f8:	mov    %rax,0xb8(%rsp)
    2100:	sar    $1,%rax
    2103:	lea    0x30(%rax),%r14
    2107:	shl    $1,%r14
    210a:	or     $0x1,%r14
    210e:	mov    %r14,0x28(%rsp)
    2113:	mov    0x188(%rsp),%rbx
    211b:	mov    0x198(%rsp),%r15
    2123:	jmp    27df <botlish_fn_7+0x14ff>
    2128:	mov    $0xa,%ecx
    212d:	jmp    240e <botlish_fn_7+0x112e>
    2132:	movq   $0x1,0x10(%rsp)
    213b:	mov    0x138(%rsp),%rax
    2143:	mov    0x140(%rsp),%rbx
    214b:	mov    %rax,%rcx
    214e:	and    %rbx,%rcx
    2151:	test   $0x1,%rcx
    2158:	je     218f <botlish_fn_7+0xeaf>
    215e:	mov    0x138(%rsp),%rax
    2166:	sar    $1,%rax
    2169:	lea    -0x1(%rbx),%rcx
    216d:	imul   %rcx
    2170:	seto   %cl
    2173:	or     $0x1,%rax
    2177:	test   %cl,%cl
    2179:	jne    218f <botlish_fn_7+0xeaf>
    217f:	mov    %rax,%rdx
    2182:	mov    %rbx,0x140(%rsp)
    218a:	jmp    21b2 <botlish_fn_7+0xed2>
    218f:	mov    %rbx,%rdx
    2192:	mov    0x138(%rsp),%rsi
    219a:	mov    0xf0(%rsp),%rdi
    21a2:	call   21a7 <botlish_fn_7+0xec7>
			21a3: R_X86_64_PLT32	rt_int_mul-0x4
    21a7:	mov    %rbx,0x140(%rsp)
    21af:	mov    %rax,%rdx
    21b2:	mov    %rdx,0x18(%rsp)
    21b7:	mov    0x158(%rsp),%r15
    21bf:	mov    %r15,%rsi
    21c2:	and    %rdx,%rsi
    21c5:	test   $0x1,%rsi
    21cc:	je     21fe <botlish_fn_7+0xf1e>
    21d2:	mov    %r15,%rdi
    21d5:	sub    %rdx,%rdi
    21d8:	seto   %sil
    21dc:	lea    0x1(%rdi),%rcx
    21e0:	test   %sil,%sil
    21e3:	jne    21fe <botlish_fn_7+0xf1e>
    21e9:	mov    0x130(%rsp),%rax
    21f1:	mov    %r15,0x158(%rsp)
    21f9:	jmp    2221 <botlish_fn_7+0xf41>
    21fe:	mov    %r15,%rsi
    2201:	mov    0xf0(%rsp),%rdi
    2209:	call   220e <botlish_fn_7+0xf2e>
			220a: R_X86_64_PLT32	rt_int_sub-0x4
    220e:	mov    %r15,0x158(%rsp)
    2216:	mov    %rax,%rcx
    2219:	mov    0x130(%rsp),%rax
    2221:	mov    0x18(%rax),%r10
    2225:	test   %r10,%r10
    2228:	je     28b2 <botlish_fn_7+0x15d2>
    222e:	mov    0x130(%rsp),%rax
    2236:	mov    0x10(%rax),%rax
    223a:	mov    %rcx,(%rax)
    223d:	jmp    2352 <botlish_fn_7+0x1072>
    2242:	movq   $0x3,0x10(%rsp)
    224b:	mov    %r13,%rax
    224e:	mov    0x110(%rsp),%rcx
    2256:	and    %rax,%rcx
    2259:	test   $0x1,%rcx
    2260:	je     2295 <botlish_fn_7+0xfb5>
    2266:	mov    0x110(%rsp),%rax
    226e:	sar    $1,%rax
    2271:	mov    %r13,%rcx
    2274:	add    $0xffffffffffffffff,%rcx
    227b:	imul   %rcx
    227e:	seto   %cl
    2281:	or     $0x1,%rax
    2285:	test   %cl,%cl
    2287:	jne    2295 <botlish_fn_7+0xfb5>
    228d:	mov    %rax,%rdx
    2290:	jmp    22b0 <botlish_fn_7+0xfd0>
    2295:	mov    %r13,%rdx
    2298:	mov    0x110(%rsp),%rsi
    22a0:	mov    0xf0(%rsp),%rdi
    22a8:	call   22ad <botlish_fn_7+0xfcd>
			22a9: R_X86_64_PLT32	rt_int_mul-0x4
    22ad:	mov    %rax,%rdx
    22b0:	mov    %rdx,0x18(%rsp)
    22b5:	mov    0x128(%rsp),%rbx
    22bd:	mov    %rbx,%rax
    22c0:	and    %rdx,%rax
    22c3:	test   $0x1,%rax
    22c9:	je     22fc <botlish_fn_7+0x101c>
    22cf:	mov    %rbx,%rsi
    22d2:	sub    %rdx,%rsi
    22d5:	mov    %rdx,%rax
    22d8:	seto   %cl
    22db:	lea    0x1(%rsi),%rdx
    22df:	test   %cl,%cl
    22e1:	je     22ef <botlish_fn_7+0x100f>
    22e7:	mov    %rax,%rdx
    22ea:	jmp    22fc <botlish_fn_7+0x101c>
    22ef:	mov    %rbx,0x128(%rsp)
    22f7:	jmp    2317 <botlish_fn_7+0x1037>
    22fc:	mov    %rbx,%rsi
    22ff:	mov    0xf0(%rsp),%rdi
    2307:	call   230c <botlish_fn_7+0x102c>
			2308: R_X86_64_PLT32	rt_int_sub-0x4
    230c:	mov    %rbx,0x128(%rsp)
    2314:	mov    %rax,%rdx
    2317:	mov    %rdx,0x18(%rsp)
    231c:	mov    0x190(%rsp),%rsi
    2324:	mov    0xf0(%rsp),%rdi
    232c:	call   2331 <botlish_fn_7+0x1051>
			232d: R_X86_64_PLT32	rt_mutarray_create-0x4
    2331:	mov    %rax,%rcx
    2334:	mov    %rax,0x130(%rsp)
    233c:	test   %rax,%rcx
    233f:	je     26b1 <botlish_fn_7+0x13d1>
    2345:	mov    0x130(%rsp),%rcx
    234d:	mov    %rcx,0x60(%rsp)
    2352:	mov    %r12,%rsi
    2355:	mov    0xf0(%rsp),%rdi
    235d:	call   2362 <botlish_fn_7+0x1082>
			235e: R_X86_64_PLT32	rt_mv_empty-0x4
    2362:	cmp    $0x6,%rax
    2366:	je     2409 <botlish_fn_7+0x1129>
    236c:	mov    %r12,%rsi
    236f:	mov    0xf0(%rsp),%rdi
    2377:	call   237c <botlish_fn_7+0x109c>
			2378: R_X86_64_PLT32	rt_mv_pop-0x4
    237c:	mov    %rax,%rcx
    237f:	mov    %rax,0x140(%rsp)
    2387:	test   %rcx,%rax
    238a:	je     26b1 <botlish_fn_7+0x13d1>
    2390:	mov    0x140(%rsp),%rax
    2398:	mov    %rax,0x68(%rsp)
    239d:	mov    0x130(%rsp),%rcx
    23a5:	mov    0x10(%rcx),%rax
    23a9:	mov    (%rax),%rcx
    23ac:	mov    %rcx,0x158(%rsp)
    23b4:	mov    %rcx,0x70(%rsp)
    23b9:	mov    0x140(%rsp),%rdx
    23c1:	mov    0x158(%rsp),%rsi
    23c9:	mov    0xf0(%rsp),%rdi
    23d1:	call   23d6 <botlish_fn_7+0x10f6>
			23d2: R_X86_64_PLT32	botlish_fn_1-0x4
    23d6:	mov    %rax,0x138(%rsp)
    23de:	mov    %rax,0x78(%rsp)
    23e3:	sar    $1,%rax
    23e6:	lea    0x30(%rax),%r14
    23ea:	shl    $1,%r14
    23ed:	or     $0x1,%r14
    23f1:	mov    %r14,0x28(%rsp)
    23f6:	mov    $0x4,%r15d
    23fc:	mov    0x188(%rsp),%rbx
    2404:	jmp    27df <botlish_fn_7+0x14ff>
    2409:	mov    $0xa,%ecx
    240e:	mov    0x188(%rsp),%rbx
    2416:	jmp    27cc <botlish_fn_7+0x14ec>
    241b:	mov    $0x1,%eax
    2420:	movq   $0x1,0x10(%rsp)
    2429:	mov    0x1a0(%rsp),%rcx
    2431:	test   %rax,%rcx
    2434:	je     2471 <botlish_fn_7+0x1191>
    243a:	mov    $0x1,%eax
    243f:	mov    0x1a0(%rsp),%rcx
    2447:	sub    %rcx,%rax
    244a:	seto   %cl
    244d:	add    $0x1,%rax
    2454:	mov    %rax,0x128(%rsp)
    245c:	test   %cl,%cl
    245e:	jne    2471 <botlish_fn_7+0x1191>
    2464:	mov    0x128(%rsp),%rax
    246c:	jmp    2493 <botlish_fn_7+0x11b3>
    2471:	mov    $0x1,%esi
    2476:	mov    0x1a0(%rsp),%rdx
    247e:	mov    0xf0(%rsp),%rdi
    2486:	call   248b <botlish_fn_7+0x11ab>
			2487: R_X86_64_PLT32	rt_int_sub-0x4
    248b:	mov    %rax,0x128(%rsp)
    2493:	mov    %rax,0x40(%rsp)
    2498:	movq   $0x3,0x10(%rsp)
    24a1:	lea    0xe0(%rsp),%rdx
    24a9:	movq   $0x3,0xe0(%rsp)
    24b5:	mov    $0x1,%esi
    24ba:	mov    0xf0(%rsp),%rdi
    24c2:	call   24c7 <botlish_fn_7+0x11e7>
			24c3: R_X86_64_PLT32	rt_list_new-0x4
    24c7:	test   %rax,%rax
    24ca:	je     26b1 <botlish_fn_7+0x13d1>
    24d0:	mov    %rax,0x10(%rsp)
    24d5:	mov    %rax,%rsi
    24d8:	mov    0xf0(%rsp),%rdi
    24e0:	call   24e5 <botlish_fn_7+0x1205>
			24e1: R_X86_64_PLT32	rt_mv_from_list-0x4
    24e5:	mov    %rax,%r12
    24e8:	mov    %r12,0x48(%rsp)
    24ed:	mov    $0x15,%r13d
    24f3:	mov    %r12,%rsi
    24f6:	mov    0xf0(%rsp),%rdi
    24fe:	call   2503 <botlish_fn_7+0x1223>
			24ff: R_X86_64_PLT32	rt_mv_len-0x4
    2503:	sar    $1,%rax
    2506:	sub    $0x1,%rax
    250a:	shl    $1,%rax
    250d:	mov    %rax,%rdx
    2510:	or     $0x1,%rdx
    2514:	mov    %r12,%rsi
    2517:	mov    0xf0(%rsp),%rdi
    251f:	call   2524 <botlish_fn_7+0x1244>
			2520: R_X86_64_PLT32	rt_mv_at-0x4
    2524:	mov    %rax,%rcx
    2527:	mov    %rax,%rsi
    252a:	test   %rcx,%rax
    252d:	je     26b1 <botlish_fn_7+0x13d1>
    2533:	mov    %rsi,%rax
    2536:	mov    %rax,0x10(%rsp)
    253b:	movq   $0x15,0x18(%rsp)
    2544:	test   $0x1,%rax
    254a:	jne    2558 <botlish_fn_7+0x1278>
    2550:	mov    %rsi,%r14
    2553:	jmp    258f <botlish_fn_7+0x12af>
    2558:	mov    %rsi,%rax
    255b:	sar    $1,%rax
    255e:	imulq  0x39b(%rip)        # 2900 <botlish_fn_7+0x1620>
    2565:	seto   %cl
    2568:	or     $0x1,%rax
    256c:	test   %cl,%cl
    256e:	je     257c <botlish_fn_7+0x129c>
    2574:	mov    %rsi,%r14
    2577:	jmp    258f <botlish_fn_7+0x12af>
    257c:	mov    %rsi,%r14
    257f:	mov    %rax,%rsi
    2582:	mov    0x128(%rsp),%rax
    258a:	jmp    25ad <botlish_fn_7+0x12cd>
    258f:	mov    %r13,%rdx
    2592:	mov    %r14,%rsi
    2595:	mov    0xf0(%rsp),%rdi
    259d:	call   25a2 <botlish_fn_7+0x12c2>
			259e: R_X86_64_PLT32	rt_int_mul-0x4
    25a2:	mov    %rax,%rsi
    25a5:	mov    0x128(%rsp),%rax
    25ad:	mov    0x128(%rsp),%rax
    25b5:	mov    %rsi,%rcx
    25b8:	and    %rax,%rcx
    25bb:	test   $0x1,%rcx
    25c2:	jne    25f8 <botlish_fn_7+0x1318>
    25c8:	mov    0x128(%rsp),%rdx
    25d0:	mov    0xf0(%rsp),%rdi
    25d8:	call   25dd <botlish_fn_7+0x12fd>
			25d9: R_X86_64_PLT32	rt_int_cmp-0x4
    25dd:	test   %rax,%rax
    25e0:	mov    0x188(%rsp),%rbx
    25e8:	mov    %rbx,%rcx
    25eb:	cmovg  0x305(%rip),%rcx        # 28f8 <botlish_fn_7+0x1618>
    25f3:	jmp    2616 <botlish_fn_7+0x1336>
    25f8:	mov    0x128(%rsp),%rax
    2600:	mov    0x188(%rsp),%rbx
    2608:	cmp    %rax,%rsi
    260b:	mov    %rbx,%rcx
    260e:	cmovg  0x2e2(%rip),%rcx        # 28f8 <botlish_fn_7+0x1618>
    2616:	cmp    $0x6,%rcx
    261a:	je     2695 <botlish_fn_7+0x13b5>
    2620:	movq   $0x15,0x18(%rsp)
    2629:	test   $0x1,%r14
    2630:	jne    263e <botlish_fn_7+0x135e>
    2636:	mov    %r14,%rsi
    2639:	jmp    2665 <botlish_fn_7+0x1385>
    263e:	mov    %r14,%rax
    2641:	sar    $1,%rax
    2644:	mov    %r14,%rsi
    2647:	imulq  0x2b2(%rip)        # 2900 <botlish_fn_7+0x1620>
    264e:	seto   %cl
    2651:	or     $0x1,%rax
    2655:	test   %cl,%cl
    2657:	jne    2665 <botlish_fn_7+0x1385>
    265d:	mov    %rax,%rdx
    2660:	jmp    2678 <botlish_fn_7+0x1398>
    2665:	mov    %r13,%rdx
    2668:	mov    0xf0(%rsp),%rdi
    2670:	call   2675 <botlish_fn_7+0x1395>
			2671: R_X86_64_PLT32	rt_int_mul-0x4
    2675:	mov    %rax,%rdx
    2678:	mov    %r12,%rsi
    267b:	mov    0xf0(%rsp),%rdi
    2683:	call   2688 <botlish_fn_7+0x13a8>
			2684: R_X86_64_PLT32	rt_mv_push-0x4
    2688:	mov    %rbx,0x188(%rsp)
    2690:	jmp    24f3 <botlish_fn_7+0x1213>
    2695:	mov    %r12,%rsi
    2698:	mov    0xf0(%rsp),%rdi
    26a0:	call   26a5 <botlish_fn_7+0x13c5>
			26a1: R_X86_64_PLT32	rt_mv_pop-0x4
    26a5:	mov    %rax,%r13
    26a8:	test   %r13,%r13
    26ab:	jne    276c <botlish_fn_7+0x148c>
    26b1:	mov    0xf0(%rsp),%rdi
    26b9:	call   26be <botlish_fn_7+0x13de>
			26ba: R_X86_64_PLT32	rt_co_failed-0x4
    26be:	mov    %rax,0x30(%rsp)
    26c3:	mov    %rax,%rsi
    26c6:	mov    0xf0(%rsp),%rdi
    26ce:	call   26d3 <botlish_fn_7+0x13f3>
			26cf: R_X86_64_PLT32	rt_co_resume0-0x4
    26d3:	test   %rax,%rax
    26d6:	je     26f4 <botlish_fn_7+0x1414>
    26dc:	mov    0xf0(%rsp),%rdi
    26e4:	mov    0x10(%rdi),%rax
    26e8:	mov    (%rax),%rsi
    26eb:	mov    0x30(%rax),%rdx
    26ef:	call   26f4 <botlish_fn_7+0x1414>
			26f0: R_X86_64_PLT32	rt_raise-0x4
    26f4:	mov    0xf0(%rsp),%rdi
    26fc:	call   2701 <botlish_fn_7+0x1421>
			26fd: R_X86_64_PLT32	rt_declared_error-0x4
    2701:	cmp    $0x40000001,%rax
    2707:	je     271a <botlish_fn_7+0x143a>
    270d:	mov    0xf0(%rsp),%rdi
    2715:	jmp    2722 <botlish_fn_7+0x1442>
    271a:	mov    0xf0(%rsp),%rdi
    2722:	mov    0xf0(%rsp),%rdi
    272a:	call   272f <botlish_fn_7+0x144f>
			272b: R_X86_64_PLT32	rt_declared_error-0x4
    272f:	cmp    $0x40000001,%rax
    2735:	xor    %rax,%rax
    2738:	mov    0x1b0(%rsp),%rbx
    2740:	mov    0x1b8(%rsp),%r12
    2748:	mov    0x1c0(%rsp),%r13
    2750:	mov    0x1c8(%rsp),%r14
    2758:	mov    0x1d0(%rsp),%r15
    2760:	add    $0x1e0,%rsp
    2767:	mov    %rbp,%rsp
    276a:	pop    %rbp
    276b:	ret
    276c:	mov    %r13,0x50(%rsp)
    2771:	mov    %r13,%rdx
    2774:	mov    0x128(%rsp),%rsi
    277c:	mov    0xf0(%rsp),%rdi
    2784:	call   2789 <botlish_fn_7+0x14a9>
			2785: R_X86_64_PLT32	botlish_fn_2-0x4
    2789:	mov    %rax,%rdx
    278c:	mov    %rax,0x110(%rsp)
    2794:	mov    %rdx,0x58(%rsp)
    2799:	mov    0x110(%rsp),%rdx
    27a1:	mov    %rdx,%rcx
    27a4:	sar    $1,%rcx
    27a7:	lea    0x30(%rcx),%r14
    27ab:	shl    $1,%r14
    27ae:	or     $0x1,%r14
    27b2:	mov    %r14,0x28(%rsp)
    27b7:	mov    0x190(%rsp),%r15
    27bf:	jmp    27df <botlish_fn_7+0x14ff>
    27c4:	mov    0x188(%rsp),%rbx
    27cc:	mov    $0xffffffffffffffff,%r14
    27d3:	movq   $0xffffffffffffffff,0x28(%rsp)
    27dc:	mov    %r14,%r15
    27df:	mov    0x1a8(%rsp),%r8
    27e7:	mov    0x18(%r8),%rsi
    27eb:	test   %rsi,%rsi
    27ee:	je     28d1 <botlish_fn_7+0x15f1>
    27f4:	mov    0x1a8(%rsp),%r8
    27fc:	mov    0x10(%r8),%r9
    2800:	mov    %r14,0x10(%r9)
    2804:	mov    %r15,%rdi
    2807:	mov    %rbx,0x188(%rsp)
    280f:	jmp    1b15 <botlish_fn_7+0x835>
    2814:	mov    0x108(%rsp),%rcx
    281c:	add    $0x1,%rcx
    2823:	mov    0xf8(%rsp),%rax
    282b:	jmp    1451 <botlish_fn_7+0x171>
    2830:	mov    $0x5,%edx
    2835:	mov    %r14,%rcx
    2838:	mov    0x1a8(%rsp),%rsi
    2840:	mov    0xf0(%rsp),%rdi
    2848:	call   284d <botlish_fn_7+0x156d>
			2849: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    284d:	jmp    1a73 <botlish_fn_7+0x793>
    2852:	mov    $0x1,%edx
    2857:	mov    0x1a8(%rsp),%rsi
    285f:	mov    0xf0(%rsp),%rdi
    2867:	call   286c <botlish_fn_7+0x158c>
			2868: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    286c:	jmp    1d0a <botlish_fn_7+0xa2a>
    2871:	mov    0x190(%rsp),%rdx
    2879:	mov    0x1a8(%rsp),%rsi
    2881:	mov    0xf0(%rsp),%rdi
    2889:	call   288e <botlish_fn_7+0x15ae>
			288a: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    288e:	jmp    1da2 <botlish_fn_7+0xac2>
    2893:	mov    $0x1,%edx
    2898:	mov    0x170(%rsp),%rsi
    28a0:	mov    0xf0(%rsp),%rdi
    28a8:	call   28ad <botlish_fn_7+0x15cd>
			28a9: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    28ad:	jmp    205c <botlish_fn_7+0xd7c>
    28b2:	mov    $0x1,%edx
    28b7:	mov    0x130(%rsp),%rsi
    28bf:	mov    0xf0(%rsp),%rdi
    28c7:	call   28cc <botlish_fn_7+0x15ec>
			28c8: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    28cc:	jmp    2352 <botlish_fn_7+0x1072>
    28d1:	mov    0x178(%rsp),%rdx
    28d9:	mov    %r14,%rcx
    28dc:	mov    0x1a8(%rsp),%rsi
    28e4:	mov    0xf0(%rsp),%rdi
    28ec:	call   28f1 <botlish_fn_7+0x1611>
			28ed: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    28f1:	jmp    2804 <botlish_fn_7+0x1524>
    28f6:	add    %al,(%rax)
    28f8:	(bad)
    28f9:	add    %al,(%rax)
    28fb:	add    %al,(%rax)
    28fd:	add    %al,(%rax)
    28ff:	add    %dl,(%rax,%rax,1)
    2902:	add    %al,(%rax)
    2904:	add    %al,(%rax)
    2906:	add    %al,(%rax)
    2908:	ds add %al,(%rax)
    290b:	add    %al,(%rax)
    290d:	add    %al,(%rax)
    290f:	add    %al,(%rbx)
    2911:	add    %al,(%rax)
    2913:	add    %al,(%rcx)
    2915:	add    %al,(%rax)
    2917:	.byte 0x80

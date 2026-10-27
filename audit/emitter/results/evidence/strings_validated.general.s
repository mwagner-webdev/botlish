<botlish_fn_12>:
    11f0:	push   %rbp
    11f1:	mov    %rsp,%rbp
    11f4:	sub    $0x150,%rsp
    11fb:	mov    %rbx,0x120(%rsp)
    1203:	mov    %r12,0x128(%rsp)
    120b:	mov    %r13,0x130(%rsp)
    1213:	mov    %r14,0x138(%rsp)
    121b:	mov    %r15,0x140(%rsp)
    1223:	mov    %rsi,%r12
    1226:	mov    %rdi,0xf8(%rsp)
    122e:	movq   $0x0,(%rsp)
    1236:	movq   $0x0,0x8(%rsp)
    123f:	movq   $0x0,0x10(%rsp)
    1248:	movq   $0x0,0x18(%rsp)
    1251:	movq   $0x0,0x20(%rsp)
    125a:	movq   $0x0,0x28(%rsp)
    1263:	movq   $0x0,0x30(%rsp)
    126c:	movq   $0x0,0x38(%rsp)
    1275:	mov    0xf8(%rsp),%rdi
    127d:	call   1282 <botlish_fn_12+0x92>
			127e: R_X86_64_PLT32	botlish_fn_11-0x4
    1282:	test   %rax,%rax
    1285:	je     1cc5 <botlish_fn_12+0xad5>
    128b:	mov    %rax,(%rsp)
    128f:	mov    %rax,%r14
    1292:	mov    $0x7,%esi
    1297:	movq   $0x7,0x8(%rsp)
    12a0:	mov    $0x1,%edx
    12a5:	movq   $0x1,0x10(%rsp)
    12ae:	mov    0xf8(%rsp),%rdi
    12b6:	call   12bb <botlish_fn_12+0xcb>
			12b7: R_X86_64_PLT32	rt_mutarray_create-0x4
    12bb:	test   %rax,%rax
    12be:	je     1cc5 <botlish_fn_12+0xad5>
    12c4:	mov    %rax,0x8(%rsp)
    12c9:	xor    %rbx,%rbx
    12cc:	mov    %r12,%r13
    12cf:	cmp    %r13,%rbx
    12d2:	jl     135c <botlish_fn_12+0x16c>
    12d8:	mov    %rax,%r12
    12db:	mov    0x10(%r12),%rax
    12e0:	mov    0x8(%rax),%rax
    12e4:	mov    %rax,(%rsp)
    12e8:	mov    0x10(%r12),%rcx
    12ed:	mov    (%rcx),%rcx
    12f0:	mov    %rcx,0x8(%rsp)
    12f5:	lea    0xe8(%rsp),%rdx
    12fd:	mov    %rax,0xe8(%rsp)
    1305:	mov    %rcx,0xf0(%rsp)
    130d:	mov    $0x2,%esi
    1312:	mov    0xf8(%rsp),%rdi
    131a:	call   131f <botlish_fn_12+0x12f>
			131b: R_X86_64_PLT32	rt_list_new-0x4
    131f:	test   %rax,%rax
    1322:	je     1cc5 <botlish_fn_12+0xad5>
    1328:	mov    0x120(%rsp),%rbx
    1330:	mov    0x128(%rsp),%r12
    1338:	mov    0x130(%rsp),%r13
    1340:	mov    0x138(%rsp),%r14
    1348:	mov    0x140(%rsp),%r15
    1350:	add    $0x150,%rsp
    1357:	mov    %rbp,%rsp
    135a:	pop    %rbp
    135b:	ret
    135c:	mov    %rax,%r12
    135f:	mov    0x8(%r14),%rcx
    1363:	mov    %rbx,%rax
    1366:	and    $0x7,%rax
    136a:	shl    $1,%rax
    136d:	or     $0x1,%rax
    1371:	sar    $1,%rax
    1374:	cmp    %rcx,%rax
    1377:	jb     13a9 <botlish_fn_12+0x1b9>
    137d:	mov    %rbx,%rdx
    1380:	and    $0x7,%rdx
    1384:	shl    $1,%rdx
    1387:	or     $0x1,%rdx
    138b:	mov    %r14,%rsi
    138e:	mov    0xf8(%rsp),%rdi
    1396:	call   139b <botlish_fn_12+0x1ab>
			1397: R_X86_64_PLT32	rt_list_get-0x4
    139b:	test   %rax,%rax
    139e:	je     1cc5 <botlish_fn_12+0xad5>
    13a4:	jmp    13b1 <botlish_fn_12+0x1c1>
    13a9:	mov    0x10(%r14),%rcx
    13ad:	mov    (%rcx,%rax,8),%rax
    13b1:	mov    %rax,0x10(%rsp)
    13b6:	lea    0x40(%rsp),%r8
    13bb:	mov    %rax,0x40(%rsp)
    13c0:	mov    $0xd,%esi
    13c5:	mov    0x0(%rip),%rdx        # 13cc <botlish_fn_12+0x1dc>
			13c8: R_X86_64_GOTPCREL	botlish_entry_13-0x4
    13cc:	mov    $0x1,%ecx
    13d1:	mov    0xf8(%rsp),%rdi
    13d9:	call   13de <botlish_fn_12+0x1ee>
			13da: R_X86_64_PLT32	rt_closure_new-0x4
    13de:	mov    %rax,0x10(%rsp)
    13e3:	mov    %rax,%rsi
    13e6:	mov    0xf8(%rsp),%rdi
    13ee:	call   13f3 <botlish_fn_12+0x203>
			13ef: R_X86_64_PLT32	rt_co_create-0x4
    13f3:	mov    %rax,0x118(%rsp)
    13fb:	mov    %rax,0x10(%rsp)
    1400:	mov    0x118(%rsp),%rsi
    1408:	mov    0xf8(%rsp),%rdi
    1410:	call   1415 <botlish_fn_12+0x225>
			1411: R_X86_64_PLT32	rt_co_start-0x4
    1415:	test   %rax,%rax
    1418:	jne    1451 <botlish_fn_12+0x261>
    141e:	mov    0xf8(%rsp),%rdi
    1426:	call   142b <botlish_fn_12+0x23b>
			1427: R_X86_64_PLT32	rt_declared_error-0x4
    142b:	cmp    $0x40000001,%rax
    1431:	jne    1cc5 <botlish_fn_12+0xad5>
    1437:	mov    0x118(%rsp),%rsi
    143f:	mov    0xf8(%rsp),%rdi
    1447:	call   144c <botlish_fn_12+0x25c>
			1448: R_X86_64_PLT32	rt_co_release-0x4
    144c:	jmp    1cc5 <botlish_fn_12+0xad5>
    1451:	mov    %rax,0x18(%rsp)
    1456:	lea    0x48(%rsp),%r8
    145b:	mov    %rax,0x48(%rsp)
    1460:	mov    %rax,%r15
    1463:	mov    $0xe,%esi
    1468:	mov    0x0(%rip),%rdx        # 146f <botlish_fn_12+0x27f>
			146b: R_X86_64_GOTPCREL	botlish_entry_14-0x4
    146f:	mov    $0x1,%ecx
    1474:	mov    0xf8(%rsp),%rdi
    147c:	call   1481 <botlish_fn_12+0x291>
			147d: R_X86_64_PLT32	rt_closure_new-0x4
    1481:	mov    %rax,0x20(%rsp)
    1486:	mov    %rax,%rsi
    1489:	mov    0xf8(%rsp),%rdi
    1491:	call   1496 <botlish_fn_12+0x2a6>
			1492: R_X86_64_PLT32	rt_co_create-0x4
    1496:	mov    %rax,0x110(%rsp)
    149e:	mov    %rax,0x20(%rsp)
    14a3:	mov    0x110(%rsp),%rsi
    14ab:	mov    0xf8(%rsp),%rdi
    14b3:	call   14b8 <botlish_fn_12+0x2c8>
			14b4: R_X86_64_PLT32	rt_co_start-0x4
    14b8:	test   %rax,%rax
    14bb:	jne    1645 <botlish_fn_12+0x455>
    14c1:	mov    0xf8(%rsp),%rdi
    14c9:	call   14ce <botlish_fn_12+0x2de>
			14ca: R_X86_64_PLT32	rt_declared_error-0x4
    14ce:	cmp    $0x1,%rax
    14d2:	je     159a <botlish_fn_12+0x3aa>
    14d8:	mov    0xf8(%rsp),%rdi
    14e0:	call   14e5 <botlish_fn_12+0x2f5>
			14e1: R_X86_64_PLT32	rt_declared_error-0x4
    14e5:	cmp    $0x2,%rax
    14e9:	jne    1cc5 <botlish_fn_12+0xad5>
    14ef:	xor    %rbx,%rbx
    14f2:	mov    %rbx,%rsi
    14f5:	mov    0xf8(%rsp),%rdi
    14fd:	call   1502 <botlish_fn_12+0x312>
			14fe: R_X86_64_PLT32	rt_declared_payload-0x4
    1502:	mov    %rax,%r12
    1505:	mov    $0x1,%esi
    150a:	mov    0xf8(%rsp),%rdi
    1512:	call   1517 <botlish_fn_12+0x327>
			1513: R_X86_64_PLT32	rt_declared_payload-0x4
    1517:	mov    %rax,%r13
    151a:	mov    0xf8(%rsp),%rdi
    1522:	call   1527 <botlish_fn_12+0x337>
			1523: R_X86_64_PLT32	rt_clear_declared_error-0x4
    1527:	mov    0x118(%rsp),%rsi
    152f:	mov    0xf8(%rsp),%rdi
    1537:	call   153c <botlish_fn_12+0x34c>
			1538: R_X86_64_PLT32	rt_co_release-0x4
    153c:	mov    0x110(%rsp),%rsi
    1544:	mov    0xf8(%rsp),%rdi
    154c:	call   1551 <botlish_fn_12+0x361>
			154d: R_X86_64_PLT32	rt_co_release-0x4
    1551:	mov    0xf8(%rsp),%rdi
    1559:	mov    0x10(%rdi),%rax
    155d:	mov    0xb8(%rax),%rdx
    1564:	lea    0x68(%rsp),%r9
    1569:	movq   $0x1,0x68(%rsp)
    1572:	mov    %r12,%rax
    1575:	mov    %rax,0x70(%rsp)
    157a:	mov    %r13,%rax
    157d:	mov    %rax,0x78(%rsp)
    1582:	mov    $0xc,%esi
    1587:	mov    $0x3,%r8d
    158d:	mov    %rbx,%rcx
    1590:	call   1595 <botlish_fn_12+0x3a5>
			1591: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1595:	jmp    1cc5 <botlish_fn_12+0xad5>
    159a:	xor    %rbx,%rbx
    159d:	mov    %rbx,%rsi
    15a0:	mov    0xf8(%rsp),%rdi
    15a8:	call   15ad <botlish_fn_12+0x3bd>
			15a9: R_X86_64_PLT32	rt_declared_payload-0x4
    15ad:	mov    %rax,%r12
    15b0:	mov    $0x1,%esi
    15b5:	mov    0xf8(%rsp),%rdi
    15bd:	call   15c2 <botlish_fn_12+0x3d2>
			15be: R_X86_64_PLT32	rt_declared_payload-0x4
    15c2:	mov    %rax,%r13
    15c5:	mov    0xf8(%rsp),%rdi
    15cd:	call   15d2 <botlish_fn_12+0x3e2>
			15ce: R_X86_64_PLT32	rt_clear_declared_error-0x4
    15d2:	mov    0x118(%rsp),%rsi
    15da:	mov    0xf8(%rsp),%rdi
    15e2:	call   15e7 <botlish_fn_12+0x3f7>
			15e3: R_X86_64_PLT32	rt_co_release-0x4
    15e7:	mov    0x110(%rsp),%rsi
    15ef:	mov    0xf8(%rsp),%rdi
    15f7:	call   15fc <botlish_fn_12+0x40c>
			15f8: R_X86_64_PLT32	rt_co_release-0x4
    15fc:	mov    0xf8(%rsp),%rdi
    1604:	mov    0x10(%rdi),%rax
    1608:	mov    0xb8(%rax),%rdx
    160f:	lea    0x50(%rsp),%r9
    1614:	movq   $0x1,0x50(%rsp)
    161d:	mov    %r12,%rax
    1620:	mov    %rax,0x58(%rsp)
    1625:	mov    %r13,%rax
    1628:	mov    %rax,0x60(%rsp)
    162d:	mov    $0xc,%esi
    1632:	mov    $0x3,%r8d
    1638:	mov    %rbx,%rcx
    163b:	call   1640 <botlish_fn_12+0x450>
			163c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1640:	jmp    1cc5 <botlish_fn_12+0xad5>
    1645:	mov    0x18(%r12),%rax
    164a:	test   %rax,%rax
    164d:	je     1d20 <botlish_fn_12+0xb30>
    1653:	mov    %r15,%rcx
    1656:	mov    0x10(%r12),%rax
    165b:	mov    %rcx,0x10(%rax)
    165f:	mov    $0x3,%r8d
    1665:	mov    %r8,0x108(%rsp)
    166d:	mov    $0x7fffffff,%eax
    1672:	mov    %rax,%r15
    1675:	neg    %r15
    1678:	cmovs  %rax,%r15
    167c:	movq   $0x1,0x18(%rsp)
    1685:	mov    0x10(%r12),%rax
    168a:	mov    (%rax),%rsi
    168d:	mov    %rsi,0x28(%rsp)
    1692:	mov    0x10(%r12),%rax
    1697:	mov    0x10(%rax),%rdx
    169b:	mov    %rdx,0x30(%rsp)
    16a0:	mov    %rdx,0x100(%rsp)
    16a8:	movq   $0x3f,0x38(%rsp)
    16b1:	test   $0x1,%rsi
    16b8:	je     16e2 <botlish_fn_12+0x4f2>
    16be:	mov    %rsi,%rax
    16c1:	sar    $1,%rax
    16c4:	imulq  0x6cd(%rip)        # 1d98 <botlish_fn_12+0xba8>
    16cb:	seto   %cl
    16ce:	or     $0x1,%rax
    16d2:	test   %cl,%cl
    16d4:	jne    16e2 <botlish_fn_12+0x4f2>
    16da:	mov    %rax,%rsi
    16dd:	jmp    16f7 <botlish_fn_12+0x507>
    16e2:	mov    $0x3f,%edx
    16e7:	mov    0xf8(%rsp),%rdi
    16ef:	call   16f4 <botlish_fn_12+0x504>
			16f0: R_X86_64_PLT32	rt_int_mul-0x4
    16f4:	mov    %rax,%rsi
    16f7:	mov    %rsi,0x28(%rsp)
    16fc:	mov    0x100(%rsp),%rdx
    1704:	mov    %rsi,%rax
    1707:	and    %rdx,%rax
    170a:	test   $0x1,%rax
    1710:	je     172b <botlish_fn_12+0x53b>
    1716:	lea    -0x1(%rdx),%rax
    171a:	mov    %rsi,%rdi
    171d:	add    %rax,%rdi
    1720:	seto   %al
    1723:	test   %al,%al
    1725:	je     173b <botlish_fn_12+0x54b>
    172b:	mov    0xf8(%rsp),%rdi
    1733:	call   1738 <botlish_fn_12+0x548>
			1734: R_X86_64_PLT32	rt_int_add-0x4
    1738:	mov    %rax,%rdi
    173b:	mov    %rdi,0x28(%rsp)
    1740:	movq   $0x3,0x30(%rsp)
    1749:	test   $0x1,%rdi
    1750:	jne    175e <botlish_fn_12+0x56e>
    1756:	mov    %rdi,%rsi
    1759:	jmp    1776 <botlish_fn_12+0x586>
    175e:	mov    %rdi,%rsi
    1761:	add    $0x2,%rsi
    1765:	mov    %rdi,%rcx
    1768:	seto   %al
    176b:	test   %al,%al
    176d:	je     178e <botlish_fn_12+0x59e>
    1773:	mov    %rcx,%rsi
    1776:	mov    0x108(%rsp),%rdx
    177e:	mov    0xf8(%rsp),%rdi
    1786:	call   178b <botlish_fn_12+0x59b>
			1787: R_X86_64_PLT32	rt_int_add-0x4
    178b:	mov    %rax,%rsi
    178e:	mov    %rsi,0x28(%rsp)
    1793:	mov    $0xffffffff,%edx
    1798:	mov    %rdx,0x30(%rsp)
    179d:	test   $0x1,%rsi
    17a4:	jne    1815 <botlish_fn_12+0x625>
    17aa:	mov    $0xffffffff,%edx
    17af:	mov    0xf8(%rsp),%rdi
    17b7:	call   17bc <botlish_fn_12+0x5cc>
			17b8: R_X86_64_PLT32	rt_int_mod-0x4
    17bc:	test   %rax,%rax
    17bf:	jne    180d <botlish_fn_12+0x61d>
    17c5:	mov    0xf8(%rsp),%rdi
    17cd:	call   17d2 <botlish_fn_12+0x5e2>
			17ce: R_X86_64_PLT32	rt_declared_error-0x4
    17d2:	cmp    $0x40000001,%rax
    17d8:	jne    1cc5 <botlish_fn_12+0xad5>
    17de:	mov    0x118(%rsp),%rsi
    17e6:	mov    0xf8(%rsp),%rdi
    17ee:	call   17f3 <botlish_fn_12+0x603>
			17ef: R_X86_64_PLT32	rt_co_release-0x4
    17f3:	mov    0x110(%rsp),%rsi
    17fb:	mov    0xf8(%rsp),%rdi
    1803:	call   1808 <botlish_fn_12+0x618>
			1804: R_X86_64_PLT32	rt_co_release-0x4
    1808:	jmp    1cc5 <botlish_fn_12+0xad5>
    180d:	mov    %rax,%rcx
    1810:	jmp    1853 <botlish_fn_12+0x663>
    1815:	sar    $1,%rsi
    1818:	mov    %rsi,%rax
    181b:	imulq  0x57e(%rip)        # 1da0 <botlish_fn_12+0xbb0>
    1822:	lea    (%rdx,%rsi,1),%r11
    1826:	sar    $0x1e,%r11
    182a:	mov    %r11,%rax
    182d:	shr    $0x3f,%rax
    1831:	add    %r11,%rax
    1834:	imul   $0x7fffffff,%rax,%rax
    183b:	sub    %rax,%rsi
    183e:	lea    (%rsi,%r15,1),%rax
    1842:	test   %rsi,%rsi
    1845:	cmovl  %rax,%rsi
    1849:	shl    $1,%rsi
    184c:	or     $0x1,%rsi
    1850:	mov    %rsi,%rcx
    1853:	mov    0x18(%r12),%rax
    1858:	test   %rax,%rax
    185b:	je     1d3d <botlish_fn_12+0xb4d>
    1861:	mov    0x10(%r12),%rax
    1866:	mov    %rcx,(%rax)
    1869:	movq   $0x3,0x18(%rsp)
    1872:	mov    0x10(%r12),%rax
    1877:	mov    0x8(%rax),%rsi
    187b:	mov    %rsi,0x28(%rsp)
    1880:	movq   $0x3,0x30(%rsp)
    1889:	test   $0x1,%rsi
    1890:	je     18a8 <botlish_fn_12+0x6b8>
    1896:	mov    %rsi,%rcx
    1899:	add    $0x2,%rcx
    189d:	seto   %al
    18a0:	test   %al,%al
    18a2:	je     18c0 <botlish_fn_12+0x6d0>
    18a8:	mov    0x108(%rsp),%rdx
    18b0:	mov    0xf8(%rsp),%rdi
    18b8:	call   18bd <botlish_fn_12+0x6cd>
			18b9: R_X86_64_PLT32	rt_int_add-0x4
    18bd:	mov    %rax,%rcx
    18c0:	mov    0x18(%r12),%rax
    18c5:	test   %rax,%rax
    18c8:	je     1d57 <botlish_fn_12+0xb67>
    18ce:	mov    0x10(%r12),%rax
    18d3:	mov    %rcx,0x8(%rax)
    18d7:	mov    0x118(%rsp),%rsi
    18df:	mov    0xf8(%rsp),%rdi
    18e7:	call   18ec <botlish_fn_12+0x6fc>
			18e8: R_X86_64_PLT32	rt_co_resume0-0x4
    18ec:	test   %rax,%rax
    18ef:	jne    193d <botlish_fn_12+0x74d>
    18f5:	mov    0xf8(%rsp),%rdi
    18fd:	call   1902 <botlish_fn_12+0x712>
			18fe: R_X86_64_PLT32	rt_declared_error-0x4
    1902:	cmp    $0x40000001,%rax
    1908:	jne    1cc5 <botlish_fn_12+0xad5>
    190e:	mov    0x118(%rsp),%rsi
    1916:	mov    0xf8(%rsp),%rdi
    191e:	call   1923 <botlish_fn_12+0x733>
			191f: R_X86_64_PLT32	rt_co_release-0x4
    1923:	mov    0x110(%rsp),%rsi
    192b:	mov    0xf8(%rsp),%rdi
    1933:	call   1938 <botlish_fn_12+0x748>
			1934: R_X86_64_PLT32	rt_co_release-0x4
    1938:	jmp    1cc5 <botlish_fn_12+0xad5>
    193d:	mov    %rax,0x18(%rsp)
    1942:	mov    %rax,0x100(%rsp)
    194a:	mov    0x118(%rsp),%rsi
    1952:	mov    0xf8(%rsp),%rdi
    195a:	call   195f <botlish_fn_12+0x76f>
			195b: R_X86_64_PLT32	rt_co_done-0x4
    195f:	cmp    $0x6,%rax
    1963:	je     1c25 <botlish_fn_12+0xa35>
    1969:	mov    0x110(%rsp),%rsi
    1971:	mov    0xf8(%rsp),%rdi
    1979:	call   197e <botlish_fn_12+0x78e>
			197a: R_X86_64_PLT32	rt_co_done-0x4
    197e:	cmp    $0x6,%rax
    1982:	je     1b9f <botlish_fn_12+0x9af>
    1988:	lea    0x98(%rsp),%rcx
    1990:	mov    0x100(%rsp),%rax
    1998:	mov    %rax,0x98(%rsp)
    19a0:	mov    $0x1,%edx
    19a5:	mov    0xf8(%rsp),%rdi
    19ad:	mov    %rdx,%rsi
    19b0:	call   19b5 <botlish_fn_12+0x7c5>
			19b1: R_X86_64_PLT32	rt_struct_new-0x4
    19b5:	mov    %rax,0x28(%rsp)
    19ba:	mov    %rax,%rdx
    19bd:	mov    0x110(%rsp),%rsi
    19c5:	mov    0xf8(%rsp),%rdi
    19cd:	call   19d2 <botlish_fn_12+0x7e2>
			19ce: R_X86_64_PLT32	rt_co_resume-0x4
    19d2:	test   %rax,%rax
    19d5:	jne    1b7b <botlish_fn_12+0x98b>
    19db:	mov    0xf8(%rsp),%rdi
    19e3:	call   19e8 <botlish_fn_12+0x7f8>
			19e4: R_X86_64_PLT32	rt_declared_error-0x4
    19e8:	cmp    $0x1,%rax
    19ec:	je     1ac2 <botlish_fn_12+0x8d2>
    19f2:	mov    0xf8(%rsp),%rdi
    19fa:	call   19ff <botlish_fn_12+0x80f>
			19fb: R_X86_64_PLT32	rt_declared_error-0x4
    19ff:	cmp    $0x2,%rax
    1a03:	jne    1cc5 <botlish_fn_12+0xad5>
    1a09:	xor    %rbx,%rbx
    1a0c:	mov    %rbx,%rsi
    1a0f:	mov    0xf8(%rsp),%rdi
    1a17:	call   1a1c <botlish_fn_12+0x82c>
			1a18: R_X86_64_PLT32	rt_declared_payload-0x4
    1a1c:	mov    %rax,%r12
    1a1f:	mov    $0x1,%esi
    1a24:	mov    0xf8(%rsp),%rdi
    1a2c:	call   1a31 <botlish_fn_12+0x841>
			1a2d: R_X86_64_PLT32	rt_declared_payload-0x4
    1a31:	mov    %rax,%r13
    1a34:	mov    0xf8(%rsp),%rdi
    1a3c:	call   1a41 <botlish_fn_12+0x851>
			1a3d: R_X86_64_PLT32	rt_clear_declared_error-0x4
    1a41:	mov    0x118(%rsp),%rsi
    1a49:	mov    0xf8(%rsp),%rdi
    1a51:	call   1a56 <botlish_fn_12+0x866>
			1a52: R_X86_64_PLT32	rt_co_release-0x4
    1a56:	mov    0x110(%rsp),%rsi
    1a5e:	mov    0xf8(%rsp),%rdi
    1a66:	call   1a6b <botlish_fn_12+0x87b>
			1a67: R_X86_64_PLT32	rt_co_release-0x4
    1a6b:	mov    0xf8(%rsp),%rdi
    1a73:	mov    0x10(%rdi),%rax
    1a77:	mov    0xb8(%rax),%rdx
    1a7e:	lea    0xb8(%rsp),%r9
    1a86:	movq   $0x1,0xb8(%rsp)
    1a92:	mov    %r12,%rax
    1a95:	mov    %rax,0xc0(%rsp)
    1a9d:	mov    %r13,%rax
    1aa0:	mov    %rax,0xc8(%rsp)
    1aa8:	mov    $0xc,%esi
    1aad:	mov    %rbx,%rcx
    1ab0:	mov    0x108(%rsp),%r8
    1ab8:	call   1abd <botlish_fn_12+0x8cd>
			1ab9: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1abd:	jmp    1cc5 <botlish_fn_12+0xad5>
    1ac2:	xor    %rbx,%rbx
    1ac5:	mov    %rbx,%rsi
    1ac8:	mov    0xf8(%rsp),%rdi
    1ad0:	call   1ad5 <botlish_fn_12+0x8e5>
			1ad1: R_X86_64_PLT32	rt_declared_payload-0x4
    1ad5:	mov    %rax,%r12
    1ad8:	mov    $0x1,%esi
    1add:	mov    0xf8(%rsp),%rdi
    1ae5:	call   1aea <botlish_fn_12+0x8fa>
			1ae6: R_X86_64_PLT32	rt_declared_payload-0x4
    1aea:	mov    %rax,%r13
    1aed:	mov    0xf8(%rsp),%rdi
    1af5:	call   1afa <botlish_fn_12+0x90a>
			1af6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    1afa:	mov    0x118(%rsp),%rsi
    1b02:	mov    0xf8(%rsp),%rdi
    1b0a:	call   1b0f <botlish_fn_12+0x91f>
			1b0b: R_X86_64_PLT32	rt_co_release-0x4
    1b0f:	mov    0x110(%rsp),%rsi
    1b17:	mov    0xf8(%rsp),%rdi
    1b1f:	call   1b24 <botlish_fn_12+0x934>
			1b20: R_X86_64_PLT32	rt_co_release-0x4
    1b24:	mov    0xf8(%rsp),%rdi
    1b2c:	mov    0x10(%rdi),%rdx
    1b30:	mov    0xb8(%rdx),%rdx
    1b37:	lea    0xa0(%rsp),%r9
    1b3f:	movq   $0x1,0xa0(%rsp)
    1b4b:	mov    %r12,%rax
    1b4e:	mov    %rax,0xa8(%rsp)
    1b56:	mov    %r13,%rax
    1b59:	mov    %rax,0xb0(%rsp)
    1b61:	mov    $0xc,%esi
    1b66:	mov    %rbx,%rcx
    1b69:	mov    0x108(%rsp),%r8
    1b71:	call   1b76 <botlish_fn_12+0x986>
			1b72: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1b76:	jmp    1cc5 <botlish_fn_12+0xad5>
    1b7b:	mov    0x18(%r12),%rdi
    1b80:	test   %rdi,%rdi
    1b83:	je     1d74 <botlish_fn_12+0xb84>
    1b89:	mov    0x100(%rsp),%rcx
    1b91:	mov    0x10(%r12),%r10
    1b96:	mov    %rcx,0x10(%r10)
    1b9a:	jmp    167c <botlish_fn_12+0x48c>
    1b9f:	mov    0x118(%rsp),%rsi
    1ba7:	mov    0xf8(%rsp),%rdi
    1baf:	call   1bb4 <botlish_fn_12+0x9c4>
			1bb0: R_X86_64_PLT32	rt_co_release-0x4
    1bb4:	mov    0x110(%rsp),%rsi
    1bbc:	mov    0xf8(%rsp),%rdi
    1bc4:	call   1bc9 <botlish_fn_12+0x9d9>
			1bc5: R_X86_64_PLT32	rt_co_release-0x4
    1bc9:	mov    0xf8(%rsp),%rdi
    1bd1:	mov    0x10(%rdi),%rdx
    1bd5:	mov    0x70(%rdx),%rax
    1bd9:	mov    0xc0(%rdx),%rcx
    1be0:	mov    0xb8(%rdx),%rdx
    1be7:	lea    0x80(%rsp),%r9
    1bef:	movq   $0x1,0x80(%rsp)
    1bfb:	mov    %rax,0x88(%rsp)
    1c03:	mov    %rcx,0x90(%rsp)
    1c0b:	mov    $0xc,%esi
    1c10:	xor    %rcx,%rcx
    1c13:	mov    0x108(%rsp),%r8
    1c1b:	call   1c20 <botlish_fn_12+0xa30>
			1c1c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1c20:	jmp    1cc5 <botlish_fn_12+0xad5>
    1c25:	mov    0x118(%rsp),%rsi
    1c2d:	mov    0xf8(%rsp),%rdi
    1c35:	call   1c3a <botlish_fn_12+0xa4a>
			1c36: R_X86_64_PLT32	rt_co_release-0x4
    1c3a:	mov    0x110(%rsp),%rsi
    1c42:	mov    0xf8(%rsp),%rdi
    1c4a:	call   1c4f <botlish_fn_12+0xa5f>
			1c4b: R_X86_64_PLT32	rt_co_done-0x4
    1c4f:	cmp    $0x6,%rax
    1c53:	je     1cfc <botlish_fn_12+0xb0c>
    1c59:	mov    0x110(%rsp),%rsi
    1c61:	mov    0xf8(%rsp),%rdi
    1c69:	call   1c6e <botlish_fn_12+0xa7e>
			1c6a: R_X86_64_PLT32	rt_co_release-0x4
    1c6e:	mov    0xf8(%rsp),%rdi
    1c76:	mov    0x10(%rdi),%rdx
    1c7a:	mov    0x70(%rdx),%rax
    1c7e:	mov    0xc8(%rdx),%rcx
    1c85:	mov    0xb8(%rdx),%rdx
    1c8c:	lea    0xd0(%rsp),%r9
    1c94:	movq   $0x1,0xd0(%rsp)
    1ca0:	mov    %rax,0xd8(%rsp)
    1ca8:	mov    %rcx,0xe0(%rsp)
    1cb0:	mov    $0xc,%esi
    1cb5:	xor    %rcx,%rcx
    1cb8:	mov    0x108(%rsp),%r8
    1cc0:	call   1cc5 <botlish_fn_12+0xad5>
			1cc1: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1cc5:	xor    %rax,%rax
    1cc8:	mov    0x120(%rsp),%rbx
    1cd0:	mov    0x128(%rsp),%r12
    1cd8:	mov    0x130(%rsp),%r13
    1ce0:	mov    0x138(%rsp),%r14
    1ce8:	mov    0x140(%rsp),%r15
    1cf0:	add    $0x150,%rsp
    1cf7:	mov    %rbp,%rsp
    1cfa:	pop    %rbp
    1cfb:	ret
    1cfc:	mov    0x110(%rsp),%rsi
    1d04:	mov    0xf8(%rsp),%rdi
    1d0c:	call   1d11 <botlish_fn_12+0xb21>
			1d0d: R_X86_64_PLT32	rt_co_release-0x4
    1d11:	add    $0x1,%rbx
    1d18:	mov    %r12,%rax
    1d1b:	jmp    12cf <botlish_fn_12+0xdf>
    1d20:	mov    $0x5,%edx
    1d25:	mov    %r15,%rcx
    1d28:	mov    %r12,%rsi
    1d2b:	mov    0xf8(%rsp),%rdi
    1d33:	call   1d38 <botlish_fn_12+0xb48>
			1d34: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1d38:	jmp    165f <botlish_fn_12+0x46f>
    1d3d:	mov    $0x1,%edx
    1d42:	mov    %r12,%rsi
    1d45:	mov    0xf8(%rsp),%rdi
    1d4d:	call   1d52 <botlish_fn_12+0xb62>
			1d4e: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1d52:	jmp    1869 <botlish_fn_12+0x679>
    1d57:	mov    0x108(%rsp),%rdx
    1d5f:	mov    %r12,%rsi
    1d62:	mov    0xf8(%rsp),%rdi
    1d6a:	call   1d6f <botlish_fn_12+0xb7f>
			1d6b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1d6f:	jmp    18d7 <botlish_fn_12+0x6e7>
    1d74:	mov    $0x5,%edx
    1d79:	mov    0x100(%rsp),%rcx
    1d81:	mov    %r12,%rsi
    1d84:	mov    0xf8(%rsp),%rdi
    1d8c:	call   1d91 <botlish_fn_12+0xba1>
			1d8d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1d91:	jmp    167c <botlish_fn_12+0x48c>
    1d96:	add    %al,(%rax)
    1d98:	ds add %al,(%rax)
    1d9b:	add    %al,(%rax)
    1d9d:	add    %al,(%rax)
    1d9f:	add    %al,(%rbx)
    1da1:	add    %al,(%rax)
    1da3:	add    %al,(%rcx)
    1da5:	add    %al,(%rax)
    1da7:	.byte 0x80

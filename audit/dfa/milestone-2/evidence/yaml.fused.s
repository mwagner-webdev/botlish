<botlish_fn_18>:
    1218:	push   %rbp
    1219:	mov    %rsp,%rbp
    121c:	sub    $0x450,%rsp
    1223:	mov    %rbx,0x420(%rsp)
    122b:	mov    %r12,0x428(%rsp)
    1233:	mov    %r13,0x430(%rsp)
    123b:	mov    %r14,0x438(%rsp)
    1243:	mov    %r15,0x440(%rsp)
    124b:	mov    %rdi,0x358(%rsp)
    1253:	movq   $0x0,0x8(%rsp)
    125c:	movq   $0x0,0x10(%rsp)
    1265:	movq   $0x0,0x18(%rsp)
    126e:	movq   $0x0,0x20(%rsp)
    1277:	movq   $0x0,0x28(%rsp)
    1280:	movq   $0x0,0x30(%rsp)
    1289:	movq   $0x0,0x38(%rsp)
    1292:	movq   $0x0,0x40(%rsp)
    129b:	movq   $0x0,0x48(%rsp)
    12a4:	movq   $0x0,0x80(%rsp)
    12b0:	movq   $0x0,0x88(%rsp)
    12bc:	movq   $0x0,0x90(%rsp)
    12c8:	movq   $0x0,0x98(%rsp)
    12d4:	movq   $0x0,0xa0(%rsp)
    12e0:	movq   $0x0,0xa8(%rsp)
    12ec:	movq   $0x0,0xb0(%rsp)
    12f8:	movq   $0x0,0xb8(%rsp)
    1304:	mov    %rdx,(%rsp)
    1308:	mov    %rdx,0x368(%rsp)
    1310:	movq   $0xa,0x60(%rsp)
    1319:	movq   $0xa,0x68(%rsp)
    1322:	movq   $0xa,0x70(%rsp)
    132b:	movq   $0xa,0x78(%rsp)
    1334:	movq   $0xa,0x50(%rsp)
    133d:	movq   $0xa,0x58(%rsp)
    1346:	mov    %rsi,0x60(%rsp)
    134b:	mov    %rsi,0x360(%rsp)
    1353:	mov    0x360(%rsp),%rsi
    135b:	mov    0x358(%rsp),%rdi
    1363:	call   1368 <botlish_fn_18+0x150>
			1364: R_X86_64_PLT32	rt_list_len-0x4
    1368:	mov    %rax,0x68(%rsp)
    136d:	mov    %rax,0x418(%rsp)
    1375:	mov    $0x1,%esi
    137a:	mov    %rsi,0x3a0(%rsp)
    1382:	movq   $0x1,0x70(%rsp)
    138b:	xor    %r14,%r14
    138e:	mov    $0xa,%eax
    1393:	mov    %rax,0x398(%rsp)
    139b:	mov    %r14,%r13
    139e:	mov    0x418(%rsp),%r15
    13a6:	mov    %rsi,%r10
    13a9:	and    %r15,%r10
    13ac:	mov    %rsi,0x3a0(%rsp)
    13b4:	test   $0x1,%r10
    13bb:	jne    13f6 <botlish_fn_18+0x1de>
    13c1:	mov    %r15,%rdx
    13c4:	mov    0x3a0(%rsp),%rsi
    13cc:	mov    0x358(%rsp),%rdi
    13d4:	call   13d9 <botlish_fn_18+0x1c1>
			13d5: R_X86_64_PLT32	rt_int_cmp-0x4
    13d9:	mov    $0x2,%ecx
    13de:	test   %rax,%rax
    13e1:	cmovl  0x6da7(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    13e9:	mov    %r15,0x418(%rsp)
    13f1:	jmp    1416 <botlish_fn_18+0x1fe>
    13f6:	mov    $0x2,%ecx
    13fb:	mov    0x3a0(%rsp),%rsi
    1403:	cmp    %r15,%rsi
    1406:	mov    %r15,0x418(%rsp)
    140e:	cmovl  0x6d7a(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    1416:	cmp    $0x6,%rcx
    141a:	je     144d <botlish_fn_18+0x235>
    1420:	mov    $0xffffffffffffffff,%rax
    1427:	mov    %rax,0x390(%rsp)
    142f:	movq   $0xffffffffffffffff,0x50(%rsp)
    1438:	mov    0x390(%rsp),%rcx
    1440:	mov    %rcx,0x380(%rsp)
    1448:	jmp    16b8 <botlish_fn_18+0x4a0>
    144d:	mov    0x3a0(%rsp),%rsi
    1455:	test   $0x1,%rsi
    145c:	je     1485 <botlish_fn_18+0x26d>
    1462:	mov    0x360(%rsp),%r15
    146a:	mov    0x8(%r15),%rcx
    146e:	mov    0x3a0(%rsp),%rsi
    1476:	mov    %rsi,%rax
    1479:	sar    $1,%rax
    147c:	cmp    %rcx,%rax
    147f:	jb     153d <botlish_fn_18+0x325>
    1485:	mov    0x3a0(%rsp),%rdx
    148d:	mov    0x360(%rsp),%rsi
    1495:	mov    0x358(%rsp),%rdi
    149d:	call   14a2 <botlish_fn_18+0x28a>
			149e: R_X86_64_PLT32	rt_list_get-0x4
    14a2:	mov    %rax,%rcx
    14a5:	mov    %rax,0x398(%rsp)
    14ad:	test   %rcx,%rax
    14b0:	jne    1530 <botlish_fn_18+0x318>
    14b6:	mov    0x358(%rsp),%rdi
    14be:	call   14c3 <botlish_fn_18+0x2ab>
			14bf: R_X86_64_PLT32	rt_co_failed-0x4
    14c3:	mov    %rax,0x58(%rsp)
    14c8:	mov    %rax,%rsi
    14cb:	mov    0x358(%rsp),%rdi
    14d3:	call   14d8 <botlish_fn_18+0x2c0>
			14d4: R_X86_64_PLT32	rt_co_resume0-0x4
    14d8:	test   %rax,%rax
    14db:	jne    14ee <botlish_fn_18+0x2d6>
    14e1:	mov    0x358(%rsp),%rdi
    14e9:	jmp    1512 <botlish_fn_18+0x2fa>
    14ee:	mov    0x358(%rsp),%rdi
    14f6:	mov    0x10(%rdi),%rax
    14fa:	mov    0x68(%rax),%rsi
    14fe:	mov    0x140(%rax),%rdx
    1505:	call   150a <botlish_fn_18+0x2f2>
			1506: R_X86_64_PLT32	rt_raise-0x4
    150a:	mov    0x358(%rsp),%rdi
    1512:	mov    0x358(%rsp),%rdi
    151a:	call   151f <botlish_fn_18+0x307>
			151b: R_X86_64_PLT32	rt_declared_error-0x4
    151f:	cmp    $0x40000001,%rax
    1525:	jne    7f4e <botlish_fn_18+0x6d36>
    152b:	jmp    7f4e <botlish_fn_18+0x6d36>
    1530:	mov    0x398(%rsp),%rax
    1538:	jmp    1555 <botlish_fn_18+0x33d>
    153d:	mov    0x360(%rsp),%r15
    1545:	mov    0x10(%r15),%rcx
    1549:	mov    (%rcx,%rax,8),%rax
    154d:	mov    %rax,0x398(%rsp)
    1555:	mov    %rax,0x78(%rsp)
    155a:	mov    0x398(%rsp),%rax
    1562:	mov    0x8(%rax),%r13
    1566:	shl    $1,%r13
    1569:	or     $0x1,%r13
    156d:	sar    $1,%r13
    1570:	test   %r13,%r13
    1573:	jg     1615 <botlish_fn_18+0x3fd>
    1579:	mov    $0x3,%edx
    157e:	movq   $0x3,0x38(%rsp)
    1587:	mov    0x3a0(%rsp),%rsi
    158f:	test   $0x1,%rsi
    1596:	jne    15a9 <botlish_fn_18+0x391>
    159c:	mov    0x3a0(%rsp),%rsi
    15a4:	jmp    15e0 <botlish_fn_18+0x3c8>
    15a9:	mov    0x3a0(%rsp),%rsi
    15b1:	mov    %rsi,%rcx
    15b4:	add    $0x2,%rcx
    15b8:	seto   %al
    15bb:	test   %al,%al
    15bd:	je     15d0 <botlish_fn_18+0x3b8>
    15c3:	mov    0x3a0(%rsp),%rsi
    15cb:	jmp    15e0 <botlish_fn_18+0x3c8>
    15d0:	mov    %rcx,%rsi
    15d3:	mov    %rcx,0x3a0(%rsp)
    15db:	jmp    15f8 <botlish_fn_18+0x3e0>
    15e0:	mov    0x358(%rsp),%rdi
    15e8:	call   15ed <botlish_fn_18+0x3d5>
			15e9: R_X86_64_PLT32	rt_int_add-0x4
    15ed:	mov    %rax,%rsi
    15f0:	mov    %rax,0x3a0(%rsp)
    15f8:	mov    %rsi,0x70(%rsp)
    15fd:	xor    %r14,%r14
    1600:	mov    0x3a0(%rsp),%rsi
    1608:	mov    0x418(%rsp),%r15
    1610:	jmp    13a6 <botlish_fn_18+0x18e>
    1615:	mov    0x398(%rsp),%rax
    161d:	movzbq 0x18(%rax),%rax
    1622:	test   %rax,%rax
    1625:	jne    1652 <botlish_fn_18+0x43a>
    162b:	mov    $0x1,%edx
    1630:	mov    0x398(%rsp),%rsi
    1638:	mov    0x358(%rsp),%rdi
    1640:	call   1645 <botlish_fn_18+0x42d>
			1641: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    1645:	mov    %rax,0x390(%rsp)
    164d:	jmp    167f <botlish_fn_18+0x467>
    1652:	mov    0x398(%rsp),%rax
    165a:	movzbq 0x19(%rax),%rax
    165f:	mov    %rax,0x390(%rsp)
    1667:	shl    $0x3,%rax
    166b:	mov    %rax,0x390(%rsp)
    1673:	or     $0x4,%rax
    1677:	mov    %rax,0x390(%rsp)
    167f:	shr    $0x3,%rax
    1683:	mov    %rax,0x390(%rsp)
    168b:	mov    $0x1,%r10d
    1691:	mov    %r10,0x380(%rsp)
    1699:	shl    $1,%rax
    169c:	mov    %rax,0x390(%rsp)
    16a4:	or     $0x1,%rax
    16a8:	mov    %rax,0x390(%rsp)
    16b0:	mov    %rax,0x50(%rsp)
    16b5:	xor    %r14,%r14
    16b8:	mov    %rax,0x8(%rsp)
    16bd:	mov    0x358(%rsp),%rdi
    16c5:	mov    0x10(%rdi),%rsi
    16c9:	mov    0x148(%rsi),%rsi
    16d0:	mov    %rsi,0x10(%rsp)
    16d5:	lea    0xc0(%rsp),%rdx
    16dd:	mov    %rsi,0xc0(%rsp)
    16e5:	mov    $0x1,%esi
    16ea:	call   16ef <botlish_fn_18+0x4d7>
			16eb: R_X86_64_PLT32	rt_list_new-0x4
    16ef:	test   %rax,%rax
    16f2:	je     7f4e <botlish_fn_18+0x6d36>
    16f8:	mov    %rax,0x10(%rsp)
    16fd:	mov    %rax,%rsi
    1700:	mov    0x358(%rsp),%rdi
    1708:	call   170d <botlish_fn_18+0x4f5>
			1709: R_X86_64_PLT32	rt_mv_from_list-0x4
    170d:	mov    %rax,%rcx
    1710:	mov    %rax,0x410(%rsp)
    1718:	mov    %rcx,0x10(%rsp)
    171d:	mov    0x410(%rsp),%rsi
    1725:	mov    0x358(%rsp),%rdi
    172d:	call   1732 <botlish_fn_18+0x51a>
			172e: R_X86_64_PLT32	rt_mv_pop-0x4
    1732:	test   %rax,%rax
    1735:	jne    1759 <botlish_fn_18+0x541>
    173b:	mov    0x358(%rsp),%rdi
    1743:	call   1748 <botlish_fn_18+0x530>
			1744: R_X86_64_PLT32	rt_declared_error-0x4
    1748:	cmp    $0x40000001,%rax
    174e:	jne    7f4e <botlish_fn_18+0x6d36>
    1754:	jmp    7f4e <botlish_fn_18+0x6d36>
    1759:	mov    $0x5,%esi
    175e:	movq   $0x5,0x18(%rsp)
    1767:	mov    0x390(%rsp),%rdx
    176f:	mov    0x358(%rsp),%rdi
    1777:	call   177c <botlish_fn_18+0x564>
			1778: R_X86_64_PLT32	rt_mutarray_create-0x4
    177c:	mov    %rax,%rcx
    177f:	test   %rcx,%rcx
    1782:	je     7f4e <botlish_fn_18+0x6d36>
    1788:	mov    %rcx,0x18(%rsp)
    178d:	mov    %rcx,0x408(%rsp)
    1795:	mov    $0x9,%esi
    179a:	movq   $0x9,0x20(%rsp)
    17a3:	mov    $0x1,%edx
    17a8:	movq   $0x1,0x28(%rsp)
    17b1:	mov    0x358(%rsp),%rdi
    17b9:	call   17be <botlish_fn_18+0x5a6>
			17ba: R_X86_64_PLT32	rt_mutarray_create-0x4
    17be:	mov    %rax,%rcx
    17c1:	test   %rcx,%rcx
    17c4:	je     7f4e <botlish_fn_18+0x6d36>
    17ca:	mov    %rcx,0x20(%rsp)
    17cf:	mov    0x390(%rsp),%rax
    17d7:	mov    %rcx,0x400(%rsp)
    17df:	test   $0x1,%rax
    17e5:	jne    181c <botlish_fn_18+0x604>
    17eb:	mov    $0xffffffffffffffff,%rdx
    17f2:	mov    0x390(%rsp),%rsi
    17fa:	mov    0x358(%rsp),%rdi
    1802:	call   1807 <botlish_fn_18+0x5ef>
			1803: R_X86_64_PLT32	rt_int_cmp-0x4
    1807:	mov    $0x2,%ecx
    180c:	test   %rax,%rax
    180f:	cmove  0x6979(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    1817:	jmp    1835 <botlish_fn_18+0x61d>
    181c:	mov    $0x2,%ecx
    1821:	mov    0x390(%rsp),%rax
    1829:	cmp    $0xffffffffffffffff,%rax
    182d:	cmove  0x695b(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    1835:	cmp    $0x6,%rcx
    1839:	je     1868 <botlish_fn_18+0x650>
    183f:	mov    0x400(%rsp),%rcx
    1847:	mov    0x18(%rcx),%rax
    184b:	test   %rax,%rax
    184e:	je     7ff6 <botlish_fn_18+0x6dde>
    1854:	mov    0x400(%rsp),%rcx
    185c:	mov    0x10(%rcx),%rax
    1860:	movq   $0x3,0x8(%rax)
    1868:	mov    $0x8,%ebx
    186d:	mov    %rbx,0x3f8(%rsp)
    1875:	mov    $0xffffffffffffffff,%rdx
    187c:	mov    %rdx,0x3f0(%rsp)
    1884:	mov    0x400(%rsp),%rcx
    188c:	mov    0x400(%rsp),%rcx
    1894:	mov    0x10(%rcx),%rax
    1898:	mov    (%rax),%rbx
    189b:	mov    %rbx,0x8(%rsp)
    18a0:	mov    0x400(%rsp),%rcx
    18a8:	mov    0x10(%rcx),%rax
    18ac:	mov    0x8(%rax),%rdx
    18b0:	mov    %rbx,%rax
    18b3:	and    %rdx,%rax
    18b6:	test   $0x1,%rax
    18bc:	jne    18ef <botlish_fn_18+0x6d7>
    18c2:	mov    %rbx,%rsi
    18c5:	mov    0x358(%rsp),%rdi
    18cd:	call   18d2 <botlish_fn_18+0x6ba>
			18ce: R_X86_64_PLT32	rt_int_cmp-0x4
    18d2:	mov    %rbx,0x3e8(%rsp)
    18da:	mov    $0x2,%ecx
    18df:	test   %rax,%rax
    18e2:	cmovl  0x68a6(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    18ea:	jmp    190f <botlish_fn_18+0x6f7>
    18ef:	mov    %rbx,0x3e8(%rsp)
    18f7:	mov    $0x2,%ecx
    18fc:	mov    0x3e8(%rsp),%rax
    1904:	cmp    %rdx,%rax
    1907:	cmovl  0x6881(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    190f:	cmp    $0x6,%rcx
    1913:	je     1e2b <botlish_fn_18+0xc13>
    1919:	mov    0x380(%rsp),%r10
    1921:	cmp    $0x1,%r10
    1925:	je     194f <botlish_fn_18+0x737>
    192b:	mov    $0xa,%esi
    1930:	cmp    $0xffffffffffffffff,%r10
    1934:	jne    1b10 <botlish_fn_18+0x8f8>
    193a:	mov    0x390(%rsp),%rax
    1942:	mov    %r10,0x380(%rsp)
    194a:	jmp    1c70 <botlish_fn_18+0xa58>
    194f:	add    $0x1,%r14
    1956:	mov    $0x3,%ebx
    195b:	cmp    %r13,%r14
    195e:	jl     1bbd <botlish_fn_18+0x9a5>
    1964:	movq   $0x3,0x38(%rsp)
    196d:	mov    0x3a0(%rsp),%rsi
    1975:	test   $0x1,%rsi
    197c:	jne    198f <botlish_fn_18+0x777>
    1982:	mov    0x3a0(%rsp),%rsi
    198a:	jmp    19c6 <botlish_fn_18+0x7ae>
    198f:	mov    0x3a0(%rsp),%rsi
    1997:	mov    %rsi,%r10
    199a:	add    $0x2,%r10
    199e:	seto   %al
    19a1:	test   %al,%al
    19a3:	je     19b6 <botlish_fn_18+0x79e>
    19a9:	mov    0x3a0(%rsp),%rsi
    19b1:	jmp    19c6 <botlish_fn_18+0x7ae>
    19b6:	mov    %r10,%rsi
    19b9:	mov    %r10,0x3a0(%rsp)
    19c1:	jmp    19e1 <botlish_fn_18+0x7c9>
    19c6:	mov    %rbx,%rdx
    19c9:	mov    0x358(%rsp),%rdi
    19d1:	call   19d6 <botlish_fn_18+0x7be>
			19d2: R_X86_64_PLT32	rt_int_add-0x4
    19d6:	mov    %rax,%rsi
    19d9:	mov    %rax,0x3a0(%rsp)
    19e1:	mov    %rsi,0x70(%rsp)
    19e6:	mov    0x418(%rsp),%rcx
    19ee:	mov    0x3a0(%rsp),%rsi
    19f6:	mov    %rsi,%rax
    19f9:	and    %rcx,%rax
    19fc:	test   $0x1,%rax
    1a02:	jne    1a3a <botlish_fn_18+0x822>
    1a08:	mov    0x418(%rsp),%rdx
    1a10:	mov    0x3a0(%rsp),%rsi
    1a18:	mov    0x358(%rsp),%rdi
    1a20:	call   1a25 <botlish_fn_18+0x80d>
			1a21: R_X86_64_PLT32	rt_int_cmp-0x4
    1a25:	mov    $0x2,%ecx
    1a2a:	test   %rax,%rax
    1a2d:	cmovl  0x675b(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    1a35:	jmp    1a5a <botlish_fn_18+0x842>
    1a3a:	mov    $0x2,%ecx
    1a3f:	mov    0x418(%rsp),%rax
    1a47:	mov    0x3a0(%rsp),%rsi
    1a4f:	cmp    %rax,%rsi
    1a52:	cmovl  0x6736(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    1a5a:	cmp    $0x6,%rcx
    1a5e:	je     1a92 <botlish_fn_18+0x87a>
    1a64:	movq   $0xffffffffffffffff,0x50(%rsp)
    1a6d:	mov    0x3f0(%rsp),%rax
    1a75:	mov    0x3f0(%rsp),%rcx
    1a7d:	mov    %rcx,0x380(%rsp)
    1a85:	mov    %rcx,0x390(%rsp)
    1a8d:	jmp    1c70 <botlish_fn_18+0xa58>
    1a92:	mov    0x3a0(%rsp),%rsi
    1a9a:	test   $0x1,%rsi
    1aa1:	je     1aca <botlish_fn_18+0x8b2>
    1aa7:	mov    0x360(%rsp),%r15
    1aaf:	mov    0x8(%r15),%rcx
    1ab3:	mov    0x3a0(%rsp),%rsi
    1abb:	mov    %rsi,%rax
    1abe:	sar    $1,%rax
    1ac1:	cmp    %rcx,%rax
    1ac4:	jb     1b82 <botlish_fn_18+0x96a>
    1aca:	mov    0x3a0(%rsp),%rdx
    1ad2:	mov    0x360(%rsp),%rsi
    1ada:	mov    0x358(%rsp),%rdi
    1ae2:	call   1ae7 <botlish_fn_18+0x8cf>
			1ae3: R_X86_64_PLT32	rt_list_get-0x4
    1ae7:	mov    %rax,%rcx
    1aea:	mov    %rax,0x398(%rsp)
    1af2:	test   %rcx,%rax
    1af5:	jne    1b75 <botlish_fn_18+0x95d>
    1afb:	mov    0x358(%rsp),%rdi
    1b03:	call   1b08 <botlish_fn_18+0x8f0>
			1b04: R_X86_64_PLT32	rt_co_failed-0x4
    1b08:	mov    %rax,0x58(%rsp)
    1b0d:	mov    %rax,%rsi
    1b10:	mov    0x358(%rsp),%rdi
    1b18:	call   1b1d <botlish_fn_18+0x905>
			1b19: R_X86_64_PLT32	rt_co_resume0-0x4
    1b1d:	test   %rax,%rax
    1b20:	jne    1b33 <botlish_fn_18+0x91b>
    1b26:	mov    0x358(%rsp),%rdi
    1b2e:	jmp    1b57 <botlish_fn_18+0x93f>
    1b33:	mov    0x358(%rsp),%rdi
    1b3b:	mov    0x10(%rdi),%rax
    1b3f:	mov    0x68(%rax),%rsi
    1b43:	mov    0x140(%rax),%rdx
    1b4a:	call   1b4f <botlish_fn_18+0x937>
			1b4b: R_X86_64_PLT32	rt_raise-0x4
    1b4f:	mov    0x358(%rsp),%rdi
    1b57:	mov    0x358(%rsp),%rdi
    1b5f:	call   1b64 <botlish_fn_18+0x94c>
			1b60: R_X86_64_PLT32	rt_declared_error-0x4
    1b64:	cmp    $0x40000001,%rax
    1b6a:	jne    7f4e <botlish_fn_18+0x6d36>
    1b70:	jmp    7f4e <botlish_fn_18+0x6d36>
    1b75:	mov    0x398(%rsp),%rax
    1b7d:	jmp    1b9a <botlish_fn_18+0x982>
    1b82:	mov    0x360(%rsp),%r15
    1b8a:	mov    0x10(%r15),%rcx
    1b8e:	mov    (%rcx,%rax,8),%rax
    1b92:	mov    %rax,0x398(%rsp)
    1b9a:	mov    %rax,0x78(%rsp)
    1b9f:	mov    0x398(%rsp),%rax
    1ba7:	mov    0x8(%rax),%r13
    1bab:	xor    %r14,%r14
    1bae:	shl    $1,%r13
    1bb1:	or     $0x1,%r13
    1bb5:	sar    $1,%r13
    1bb8:	jmp    195b <botlish_fn_18+0x743>
    1bbd:	mov    0x398(%rsp),%rax
    1bc5:	movzbq 0x18(%rax),%rax
    1bca:	test   %rax,%rax
    1bcd:	jne    1bff <botlish_fn_18+0x9e7>
    1bd3:	mov    %r14,%rdx
    1bd6:	shl    $1,%rdx
    1bd9:	or     $0x1,%rdx
    1bdd:	mov    0x398(%rsp),%rsi
    1be5:	mov    0x358(%rsp),%rdi
    1bed:	call   1bf2 <botlish_fn_18+0x9da>
			1bee: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    1bf2:	mov    %rax,0x390(%rsp)
    1bfa:	jmp    1c3a <botlish_fn_18+0xa22>
    1bff:	mov    %r14,%rax
    1c02:	shl    $1,%rax
    1c05:	or     $0x1,%rax
    1c09:	sar    $1,%rax
    1c0c:	mov    0x398(%rsp),%rcx
    1c14:	movzbq 0x19(%rcx,%rax,1),%rax
    1c1a:	mov    %rax,0x390(%rsp)
    1c22:	shl    $0x3,%rax
    1c26:	mov    %rax,0x390(%rsp)
    1c2e:	or     $0x4,%rax
    1c32:	mov    %rax,0x390(%rsp)
    1c3a:	shr    $0x3,%rax
    1c3e:	mov    %rax,0x390(%rsp)
    1c46:	mov    $0x1,%r10d
    1c4c:	mov    %r10,0x380(%rsp)
    1c54:	shl    $1,%rax
    1c57:	mov    %rax,0x390(%rsp)
    1c5f:	or     $0x1,%rax
    1c63:	mov    %rax,0x390(%rsp)
    1c6b:	mov    %rax,0x50(%rsp)
    1c70:	mov    %rax,0x28(%rsp)
    1c75:	mov    0x390(%rsp),%rax
    1c7d:	test   $0x1,%rax
    1c83:	jne    1cbb <botlish_fn_18+0xaa3>
    1c89:	mov    0x3f0(%rsp),%rdx
    1c91:	mov    0x390(%rsp),%rsi
    1c99:	mov    0x358(%rsp),%rdi
    1ca1:	call   1ca6 <botlish_fn_18+0xa8e>
			1ca2: R_X86_64_PLT32	rt_int_cmp-0x4
    1ca6:	mov    $0x2,%ecx
    1cab:	test   %rax,%rax
    1cae:	cmove  0x64da(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    1cb6:	jmp    1cd4 <botlish_fn_18+0xabc>
    1cbb:	mov    $0x2,%ecx
    1cc0:	mov    0x390(%rsp),%rax
    1cc8:	cmp    $0xffffffffffffffff,%rax
    1ccc:	cmove  0x64bc(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    1cd4:	cmp    $0x6,%rcx
    1cd8:	je     1e09 <botlish_fn_18+0xbf1>
    1cde:	mov    $0x3,%r12d
    1ce4:	movq   $0x3,0x30(%rsp)
    1ced:	mov    0x3e8(%rsp),%rdx
    1cf5:	test   $0x1,%rdx
    1cfc:	jne    1d2a <botlish_fn_18+0xb12>
    1d02:	mov    %r12,%rdx
    1d05:	mov    0x3e8(%rsp),%rsi
    1d0d:	mov    0x358(%rsp),%rdi
    1d15:	call   1d1a <botlish_fn_18+0xb02>
			1d16: R_X86_64_PLT32	rt_int_and-0x4
    1d1a:	mov    0x408(%rsp),%rcx
    1d22:	mov    %rax,%rdx
    1d25:	jmp    1d3e <botlish_fn_18+0xb26>
    1d2a:	mov    0x3e8(%rsp),%rdx
    1d32:	and    $0x3,%rdx
    1d36:	mov    0x408(%rsp),%rcx
    1d3e:	mov    0x18(%rcx),%r10
    1d42:	test   %r10,%r10
    1d45:	je     8018 <botlish_fn_18+0x6e00>
    1d4b:	mov    0x408(%rsp),%rcx
    1d53:	mov    0x10(%rcx),%rax
    1d57:	sar    $1,%rdx
    1d5a:	mov    0x390(%rsp),%rcx
    1d62:	mov    %rcx,(%rax,%rdx,8)
    1d66:	movq   $0x3,0x30(%rsp)
    1d6f:	movq   $0x3,0x38(%rsp)
    1d78:	mov    0x3e8(%rsp),%rdx
    1d80:	test   $0x1,%rdx
    1d87:	je     1db4 <botlish_fn_18+0xb9c>
    1d8d:	mov    0x3e8(%rsp),%rdx
    1d95:	mov    %rdx,%rcx
    1d98:	add    $0x2,%rcx
    1d9c:	seto   %al
    1d9f:	test   %al,%al
    1da1:	jne    1db4 <botlish_fn_18+0xb9c>
    1da7:	mov    0x400(%rsp),%rsi
    1daf:	jmp    1dd7 <botlish_fn_18+0xbbf>
    1db4:	mov    %r12,%rdx
    1db7:	mov    0x3e8(%rsp),%rsi
    1dbf:	mov    0x358(%rsp),%rdi
    1dc7:	call   1dcc <botlish_fn_18+0xbb4>
			1dc8: R_X86_64_PLT32	rt_int_add-0x4
    1dcc:	mov    %rax,%rcx
    1dcf:	mov    0x400(%rsp),%rsi
    1dd7:	mov    0x400(%rsp),%rsi
    1ddf:	mov    0x18(%rsi),%rax
    1de3:	test   %rax,%rax
    1de6:	je     803a <botlish_fn_18+0x6e22>
    1dec:	mov    0x400(%rsp),%r9
    1df4:	mov    0x10(%r9),%rax
    1df8:	mov    %rcx,0x8(%rax)
    1dfc:	mov    0x390(%rsp),%rax
    1e04:	jmp    1e11 <botlish_fn_18+0xbf9>
    1e09:	mov    0x390(%rsp),%rax
    1e11:	mov    0x390(%rsp),%rax
    1e19:	mov    %rax,0x28(%rsp)
    1e1e:	mov    0x390(%rsp),%rdx
    1e26:	jmp    1e9e <botlish_fn_18+0xc86>
    1e2b:	mov    $0x3,%edx
    1e30:	movq   $0x3,0x28(%rsp)
    1e39:	mov    0x3e8(%rsp),%rax
    1e41:	test   $0x1,%rax
    1e47:	jne    1e6f <botlish_fn_18+0xc57>
    1e4d:	mov    0x3e8(%rsp),%rsi
    1e55:	mov    0x358(%rsp),%rdi
    1e5d:	call   1e62 <botlish_fn_18+0xc4a>
			1e5e: R_X86_64_PLT32	rt_int_and-0x4
    1e62:	mov    0x408(%rsp),%rcx
    1e6a:	jmp    1e86 <botlish_fn_18+0xc6e>
    1e6f:	mov    0x3e8(%rsp),%rdx
    1e77:	mov    %rdx,%rax
    1e7a:	and    $0x3,%rax
    1e7e:	mov    0x408(%rsp),%rcx
    1e86:	mov    0x408(%rsp),%rcx
    1e8e:	mov    0x10(%rcx),%rcx
    1e92:	sar    $1,%rax
    1e95:	mov    (%rcx,%rax,8),%rdx
    1e99:	mov    %rdx,0x28(%rsp)
    1e9e:	test   $0x1,%rdx
    1ea5:	mov    %rdx,0x378(%rsp)
    1ead:	jne    1ee5 <botlish_fn_18+0xccd>
    1eb3:	mov    0x3f0(%rsp),%rdx
    1ebb:	mov    0x378(%rsp),%rsi
    1ec3:	mov    0x358(%rsp),%rdi
    1ecb:	call   1ed0 <botlish_fn_18+0xcb8>
			1ecc: R_X86_64_PLT32	rt_int_cmp-0x4
    1ed0:	mov    $0x2,%ecx
    1ed5:	test   %rax,%rax
    1ed8:	cmove  0x62b0(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    1ee0:	jmp    1efe <botlish_fn_18+0xce6>
    1ee5:	mov    $0x2,%ecx
    1eea:	mov    0x378(%rsp),%rdx
    1ef2:	cmp    $0xffffffffffffffff,%rdx
    1ef6:	cmove  0x6292(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    1efe:	cmp    $0x6,%rcx
    1f02:	je     7d62 <botlish_fn_18+0x6b4a>
    1f08:	movq   $0x1,0x30(%rsp)
    1f11:	mov    $0x3,%r8d
    1f17:	mov    %r8,0x3e0(%rsp)
    1f1f:	movq   $0x3,0x38(%rsp)
    1f28:	mov    0x3e8(%rsp),%rdx
    1f30:	test   $0x1,%rdx
    1f37:	je     1f64 <botlish_fn_18+0xd4c>
    1f3d:	mov    0x3e8(%rsp),%rdx
    1f45:	mov    %rdx,%rcx
    1f48:	add    $0x2,%rcx
    1f4c:	seto   %al
    1f4f:	test   %al,%al
    1f51:	jne    1f64 <botlish_fn_18+0xd4c>
    1f57:	mov    0x400(%rsp),%rax
    1f5f:	jmp    1f8c <botlish_fn_18+0xd74>
    1f64:	mov    0x3e0(%rsp),%rdx
    1f6c:	mov    0x3e8(%rsp),%rsi
    1f74:	mov    0x358(%rsp),%rdi
    1f7c:	call   1f81 <botlish_fn_18+0xd69>
			1f7d: R_X86_64_PLT32	rt_int_add-0x4
    1f81:	mov    %rax,%rcx
    1f84:	mov    0x400(%rsp),%rax
    1f8c:	mov    0x400(%rsp),%rax
    1f94:	mov    0x18(%rax),%rax
    1f98:	test   %rax,%rax
    1f9b:	je     8057 <botlish_fn_18+0x6e3f>
    1fa1:	mov    0x400(%rsp),%rsi
    1fa9:	mov    0x10(%rsi),%rsi
    1fad:	mov    %rcx,(%rsi)
    1fb0:	mov    0x378(%rsp),%rsi
    1fb8:	mov    0x358(%rsp),%rdi
    1fc0:	call   1fc5 <botlish_fn_18+0xdad>
			1fc1: R_X86_64_PLT32	botlish_fn_14-0x4
    1fc5:	cmp    $0x6,%rax
    1fc9:	je     7d55 <botlish_fn_18+0x6b3d>
    1fcf:	mov    0x378(%rsp),%rdx
    1fd7:	test   $0x1,%rdx
    1fde:	jne    2013 <botlish_fn_18+0xdfb>
    1fe4:	mov    $0x75,%edx
    1fe9:	mov    0x378(%rsp),%rsi
    1ff1:	mov    0x358(%rsp),%rdi
    1ff9:	call   1ffe <botlish_fn_18+0xde6>
			1ffa: R_X86_64_PLT32	rt_int_cmp-0x4
    1ffe:	mov    $0x2,%ecx
    2003:	test   %rax,%rax
    2006:	cmove  0x6182(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    200e:	jmp    202c <botlish_fn_18+0xe14>
    2013:	mov    $0x2,%ecx
    2018:	mov    0x378(%rsp),%rdx
    2020:	cmp    $0x75,%rdx
    2024:	cmove  0x6164(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    202c:	cmp    $0x6,%rcx
    2030:	jne    2098 <botlish_fn_18+0xe80>
    2036:	mov    0x400(%rsp),%rcx
    203e:	mov    0x10(%rcx),%rax
    2042:	mov    0x10(%rax),%rsi
    2046:	test   $0x1,%rsi
    204d:	jne    207d <botlish_fn_18+0xe65>
    2053:	mov    0x3e0(%rsp),%rdx
    205b:	mov    0x358(%rsp),%rdi
    2063:	call   2068 <botlish_fn_18+0xe50>
			2064: R_X86_64_PLT32	rt_int_cmp-0x4
    2068:	mov    $0x2,%ecx
    206d:	test   %rax,%rax
    2070:	cmove  0x6118(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    2078:	jmp    208e <botlish_fn_18+0xe76>
    207d:	mov    $0x2,%ecx
    2082:	cmp    $0x3,%rsi
    2086:	cmove  0x6102(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    208e:	cmp    $0x6,%rcx
    2092:	je     7c64 <botlish_fn_18+0x6a4c>
    2098:	movq   $0xa,0x90(%rsp)
    20a4:	movq   $0xa,0x98(%rsp)
    20b0:	movq   $0xa,0xa0(%rsp)
    20bc:	movq   $0xa,0xa8(%rsp)
    20c8:	movq   $0xa,0xb0(%rsp)
    20d4:	movq   $0xa,0xb8(%rsp)
    20e0:	movq   $0xa,0x80(%rsp)
    20ec:	movq   $0xa,0x88(%rsp)
    20f8:	mov    0x378(%rsp),%rax
    2100:	mov    %rax,0x388(%rsp)
    2108:	mov    0x378(%rsp),%rdx
    2110:	test   $0x1,%rdx
    2117:	jne    214d <botlish_fn_18+0xf35>
    211d:	mov    $0x45,%edx
    2122:	mov    0x378(%rsp),%rsi
    212a:	mov    0x358(%rsp),%rdi
    2132:	call   2137 <botlish_fn_18+0xf1f>
			2133: R_X86_64_PLT32	rt_int_cmp-0x4
    2137:	mov    $0x2,%r9d
    213d:	test   %rax,%rax
    2140:	cmovl  0x6048(%rip),%r9        # 8190 <botlish_fn_18+0x6f78>
    2148:	jmp    2167 <botlish_fn_18+0xf4f>
    214d:	mov    $0x2,%r9d
    2153:	mov    0x378(%rsp),%rdx
    215b:	cmp    $0x45,%rdx
    215f:	cmovl  0x6029(%rip),%r9        # 8190 <botlish_fn_18+0x6f78>
    2167:	cmp    $0x6,%r9
    216b:	je     23ea <botlish_fn_18+0x11d2>
    2171:	mov    0x378(%rsp),%rdx
    2179:	test   $0x1,%rdx
    2180:	jne    21b5 <botlish_fn_18+0xf9d>
    2186:	mov    $0x21ffff,%edx
    218b:	mov    0x378(%rsp),%rsi
    2193:	mov    0x358(%rsp),%rdi
    219b:	call   21a0 <botlish_fn_18+0xf88>
			219c: R_X86_64_PLT32	rt_int_cmp-0x4
    21a0:	mov    $0x2,%ecx
    21a5:	test   %rax,%rax
    21a8:	cmovg  0x5fe0(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    21b0:	jmp    21d1 <botlish_fn_18+0xfb9>
    21b5:	mov    $0x2,%ecx
    21ba:	mov    0x378(%rsp),%rdx
    21c2:	cmp    $0x21ffff,%rdx
    21c9:	cmovg  0x5fbf(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    21d1:	cmp    $0x6,%rcx
    21d5:	je     23ea <botlish_fn_18+0x11d2>
    21db:	mov    0x378(%rsp),%rdx
    21e3:	mov    %rdx,%rax
    21e6:	sar    $1,%rax
    21e9:	cmp    $0x5d,%rax
    21ed:	jl     22e3 <botlish_fn_18+0x10cb>
    21f3:	cmp    $0x85,%rax
    21f9:	jl     227f <botlish_fn_18+0x1067>
    21ff:	cmp    $0xfeff,%rax
    2205:	jl     2245 <botlish_fn_18+0x102d>
    220b:	cmp    $0xfffe,%rax
    2211:	jl     2234 <botlish_fn_18+0x101c>
    2217:	cmp    $0x10000,%rax
    221d:	jl     23ea <botlish_fn_18+0x11d2>
    2223:	cmp    $0x110000,%rax
    2229:	jge    23ea <botlish_fn_18+0x11d2>
    222f:	jmp    23bf <botlish_fn_18+0x11a7>
    2234:	cmp    $0xff00,%rax
    223a:	jge    23bf <botlish_fn_18+0x11a7>
    2240:	jmp    23ea <botlish_fn_18+0x11d2>
    2245:	cmp    $0xa0,%rax
    224b:	jl     226e <botlish_fn_18+0x1056>
    2251:	cmp    $0xd800,%rax
    2257:	jl     23bf <botlish_fn_18+0x11a7>
    225d:	cmp    $0xe000,%rax
    2263:	jge    23bf <botlish_fn_18+0x11a7>
    2269:	jmp    23ea <botlish_fn_18+0x11d2>
    226e:	cmp    $0x86,%rax
    2274:	jge    23ea <botlish_fn_18+0x11d2>
    227a:	jmp    23bf <botlish_fn_18+0x11a7>
    227f:	cmp    $0x7b,%rax
    2283:	jl     22bb <botlish_fn_18+0x10a3>
    2289:	cmp    $0x7d,%rax
    228d:	jl     22ac <botlish_fn_18+0x1094>
    2293:	cmp    $0x7e,%rax
    2297:	jl     2360 <botlish_fn_18+0x1148>
    229d:	cmp    $0x7f,%rax
    22a1:	jge    23ea <botlish_fn_18+0x11d2>
    22a7:	jmp    23bf <botlish_fn_18+0x11a7>
    22ac:	cmp    $0x7c,%rax
    22b0:	jge    23ea <botlish_fn_18+0x11d2>
    22b6:	jmp    2360 <botlish_fn_18+0x1148>
    22bb:	cmp    $0x60,%rax
    22bf:	jl     22d4 <botlish_fn_18+0x10bc>
    22c5:	cmp    $0x61,%rax
    22c9:	jge    23bf <botlish_fn_18+0x11a7>
    22cf:	jmp    23ea <botlish_fn_18+0x11d2>
    22d4:	cmp    $0x5e,%rax
    22d8:	jge    23bf <botlish_fn_18+0x11a7>
    22de:	jmp    2360 <botlish_fn_18+0x1148>
    22e3:	cmp    $0x2c,%rax
    22e7:	jl     236a <botlish_fn_18+0x1152>
    22ed:	cmp    $0x3f,%rax
    22f1:	jl     2329 <botlish_fn_18+0x1111>
    22f7:	cmp    $0x41,%rax
    22fb:	jl     231a <botlish_fn_18+0x1102>
    2301:	cmp    $0x5b,%rax
    2305:	jl     23bf <botlish_fn_18+0x11a7>
    230b:	cmp    $0x5c,%rax
    230f:	jge    23bf <botlish_fn_18+0x11a7>
    2315:	jmp    2360 <botlish_fn_18+0x1148>
    231a:	cmp    $0x40,%rax
    231e:	jge    23ea <botlish_fn_18+0x11d2>
    2324:	jmp    23bf <botlish_fn_18+0x11a7>
    2329:	cmp    $0x3a,%rax
    232d:	jl     2356 <botlish_fn_18+0x113e>
    2333:	cmp    $0x3b,%rax
    2337:	jl     234c <botlish_fn_18+0x1134>
    233d:	cmp    $0x3e,%rax
    2341:	jge    23ea <botlish_fn_18+0x11d2>
    2347:	jmp    23bf <botlish_fn_18+0x11a7>
    234c:	mov    $0x1,%esi
    2351:	jmp    23ef <botlish_fn_18+0x11d7>
    2356:	cmp    $0x2d,%rax
    235a:	jge    23bf <botlish_fn_18+0x11a7>
    2360:	mov    $0x4,%esi
    2365:	jmp    23ef <botlish_fn_18+0x11d7>
    236a:	cmp    $0x25,%rax
    236e:	jl     23ab <botlish_fn_18+0x1193>
    2374:	cmp    $0x28,%rax
    2378:	jl     2397 <botlish_fn_18+0x117f>
    237e:	cmp    $0x2a,%rax
    2382:	jl     23bf <botlish_fn_18+0x11a7>
    2388:	cmp    $0x2b,%rax
    238c:	jge    23bf <botlish_fn_18+0x11a7>
    2392:	jmp    23ea <botlish_fn_18+0x11d2>
    2397:	cmp    $0x27,%rax
    239b:	jl     23ea <botlish_fn_18+0x11d2>
    23a1:	mov    $0xb,%esi
    23a6:	jmp    23ef <botlish_fn_18+0x11d7>
    23ab:	cmp    $0x23,%rax
    23af:	jl     23d3 <botlish_fn_18+0x11bb>
    23b5:	cmp    $0x24,%rax
    23b9:	jl     23c9 <botlish_fn_18+0x11b1>
    23bf:	mov    $0xa,%esi
    23c4:	jmp    23ef <botlish_fn_18+0x11d7>
    23c9:	mov    $0x9,%esi
    23ce:	jmp    23ef <botlish_fn_18+0x11d7>
    23d3:	cmp    $0x22,%rax
    23d7:	jl     23ea <botlish_fn_18+0x11d2>
    23dd:	mov    0x3f8(%rsp),%rsi
    23e5:	jmp    23ef <botlish_fn_18+0x11d7>
    23ea:	mov    $0xc,%esi
    23ef:	mov    %rsi,%rcx
    23f2:	shl    $1,%rcx
    23f5:	or     $0x1,%rcx
    23f9:	mov    $0x2,%eax
    23fe:	cmp    $0x9,%rcx
    2402:	cmovl  0x5d86(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    240a:	cmp    $0x6,%rax
    240e:	je     3cd2 <botlish_fn_18+0x2aba>
    2414:	mov    %rsi,%rcx
    2417:	shl    $1,%rcx
    241a:	or     $0x1,%rcx
    241e:	mov    $0x2,%eax
    2423:	cmp    $0x9,%rcx
    2427:	cmove  0x5d61(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    242f:	cmp    $0x6,%rax
    2433:	je     3af3 <botlish_fn_18+0x28db>
    2439:	mov    %rsi,%rcx
    243c:	shl    $1,%rcx
    243f:	or     $0x1,%rcx
    2443:	mov    $0x2,%eax
    2448:	cmp    $0xb,%rcx
    244c:	cmove  0x5d3c(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    2454:	cmp    $0x6,%rax
    2458:	je     3ae1 <botlish_fn_18+0x28c9>
    245e:	mov    %rsi,%rdi
    2461:	shl    $1,%rdi
    2464:	or     $0x1,%rdi
    2468:	mov    $0x2,%r8d
    246e:	cmp    $0xd,%rdi
    2472:	cmove  0x5d16(%rip),%r8        # 8190 <botlish_fn_18+0x6f78>
    247a:	cmp    $0x6,%r8
    247e:	je     3ac4 <botlish_fn_18+0x28ac>
    2484:	mov    %rsi,%r10
    2487:	shl    $1,%r10
    248a:	or     $0x1,%r10
    248e:	mov    $0x2,%eax
    2493:	cmp    $0xf,%r10
    2497:	cmove  0x5cf1(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    249f:	cmp    $0x6,%rax
    24a3:	je     3aa7 <botlish_fn_18+0x288f>
    24a9:	mov    %rsi,%rcx
    24ac:	shl    $1,%rcx
    24af:	or     $0x1,%rcx
    24b3:	mov    $0x2,%eax
    24b8:	cmp    $0x11,%rcx
    24bc:	cmove  0x5ccc(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    24c4:	cmp    $0x6,%rax
    24c8:	je     3228 <botlish_fn_18+0x2010>
    24ce:	mov    %rsi,%rcx
    24d1:	shl    $1,%rcx
    24d4:	or     $0x1,%rcx
    24d8:	mov    $0x2,%eax
    24dd:	cmp    $0x13,%rcx
    24e1:	cmove  0x5ca7(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    24e9:	cmp    $0x6,%rax
    24ed:	je     2efe <botlish_fn_18+0x1ce6>
    24f3:	mov    %rsi,%rcx
    24f6:	shl    $1,%rcx
    24f9:	or     $0x1,%rcx
    24fd:	mov    $0x2,%eax
    2502:	cmp    $0x15,%rcx
    2506:	cmove  0x5c82(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    250e:	cmp    $0x6,%rax
    2512:	je     29bc <botlish_fn_18+0x17a4>
    2518:	mov    %rsi,%rcx
    251b:	shl    $1,%rcx
    251e:	mov    %rsi,0x3c8(%rsp)
    2526:	or     $0x1,%rcx
    252a:	mov    $0x2,%eax
    252f:	cmp    $0x17,%rcx
    2533:	cmove  0x5c55(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    253b:	cmp    $0x6,%rax
    253f:	je     269b <botlish_fn_18+0x1483>
    2545:	mov    0x378(%rsp),%rdx
    254d:	test   $0x1,%rdx
    2554:	jne    258c <botlish_fn_18+0x1374>
    255a:	mov    0x3f0(%rsp),%rdx
    2562:	mov    0x378(%rsp),%rsi
    256a:	mov    0x358(%rsp),%rdi
    2572:	call   2577 <botlish_fn_18+0x135f>
			2573: R_X86_64_PLT32	rt_int_cmp-0x4
    2577:	mov    $0x2,%ecx
    257c:	test   %rax,%rax
    257f:	cmove  0x5c09(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    2587:	jmp    25a5 <botlish_fn_18+0x138d>
    258c:	mov    $0x2,%ecx
    2591:	mov    0x378(%rsp),%rdx
    2599:	cmp    $0xffffffffffffffff,%rdx
    259d:	cmove  0x5beb(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    25a5:	cmp    $0x6,%rcx
    25a9:	je     2631 <botlish_fn_18+0x1419>
    25af:	mov    0x358(%rsp),%rdi
    25b7:	mov    0x10(%rdi),%rax
    25bb:	mov    0x1b8(%rax),%rbx
    25c2:	mov    $0x1,%r12d
    25c8:	mov    0x3c8(%rsp),%rsi
    25d0:	shl    $1,%rsi
    25d3:	or     $0x1,%rsi
    25d7:	call   25dc <botlish_fn_18+0x13c4>
			25d8: R_X86_64_PLT32	botlish_fn_11-0x4
    25dc:	mov    0x358(%rsp),%rdi
    25e4:	mov    0x10(%rdi),%rcx
    25e8:	mov    0x190(%rcx),%rdx
    25ef:	lea    0x250(%rsp),%r9
    25f7:	mov    %rbx,0x250(%rsp)
    25ff:	mov    %rax,0x258(%rsp)
    2607:	mov    0x378(%rsp),%rax
    260f:	mov    %rax,0x260(%rsp)
    2617:	mov    $0x5,%ecx
    261c:	mov    %r12,%rsi
    261f:	mov    0x3e0(%rsp),%r8
    2627:	call   262c <botlish_fn_18+0x1414>
			2628: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    262c:	jmp    37c0 <botlish_fn_18+0x25a8>
    2631:	mov    0x3c8(%rsp),%rsi
    2639:	mov    0x358(%rsp),%rdi
    2641:	mov    0x10(%rdi),%rax
    2645:	mov    0x1b8(%rax),%rbx
    264c:	shl    $1,%rsi
    264f:	or     $0x1,%rsi
    2653:	call   2658 <botlish_fn_18+0x1440>
			2654: R_X86_64_PLT32	botlish_fn_11-0x4
    2658:	mov    0x358(%rsp),%rdi
    2660:	mov    0x10(%rdi),%rcx
    2664:	mov    0x188(%rcx),%rdx
    266b:	lea    0x240(%rsp),%r9
    2673:	mov    %rbx,0x240(%rsp)
    267b:	mov    %rax,0x248(%rsp)
    2683:	mov    $0x2,%r8d
    2689:	mov    $0x4,%ecx
    268e:	mov    %r8,%rsi
    2691:	call   2696 <botlish_fn_18+0x147e>
			2692: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2696:	jmp    37c0 <botlish_fn_18+0x25a8>
    269b:	mov    0x378(%rsp),%rdx
    26a3:	test   $0x1,%rdx
    26aa:	jne    26df <botlish_fn_18+0x14c7>
    26b0:	mov    $0x4f,%edx
    26b5:	mov    0x378(%rsp),%rsi
    26bd:	mov    0x358(%rsp),%rdi
    26c5:	call   26ca <botlish_fn_18+0x14b2>
			26c6: R_X86_64_PLT32	rt_int_cmp-0x4
    26ca:	mov    $0x2,%edx
    26cf:	test   %rax,%rax
    26d2:	cmovl  0x5ab6(%rip),%rdx        # 8190 <botlish_fn_18+0x6f78>
    26da:	jmp    26f8 <botlish_fn_18+0x14e0>
    26df:	mov    $0x2,%edx
    26e4:	mov    0x378(%rsp),%rdi
    26ec:	cmp    $0x4f,%rdi
    26f0:	cmovl  0x5a98(%rip),%rdx        # 8190 <botlish_fn_18+0x6f78>
    26f8:	cmp    $0x6,%rdx
    26fc:	je     2795 <botlish_fn_18+0x157d>
    2702:	mov    0x378(%rsp),%rdx
    270a:	test   $0x1,%rdx
    2711:	jne    2746 <botlish_fn_18+0x152e>
    2717:	mov    $0x4f,%edx
    271c:	mov    0x378(%rsp),%rsi
    2724:	mov    0x358(%rsp),%rdi
    272c:	call   2731 <botlish_fn_18+0x1519>
			272d: R_X86_64_PLT32	rt_int_cmp-0x4
    2731:	mov    $0x2,%ecx
    2736:	test   %rax,%rax
    2739:	cmovg  0x5a4f(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    2741:	jmp    275f <botlish_fn_18+0x1547>
    2746:	mov    $0x2,%ecx
    274b:	mov    0x378(%rsp),%rdx
    2753:	cmp    $0x4f,%rdx
    2757:	cmovg  0x5a31(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    275f:	cmp    $0x6,%rcx
    2763:	je     2795 <botlish_fn_18+0x157d>
    2769:	mov    0x378(%rsp),%rdx
    2771:	mov    %rdx,%r9
    2774:	sar    $1,%r9
    2777:	cmp    $0x27,%r9
    277b:	jl     2795 <botlish_fn_18+0x157d>
    2781:	cmp    $0x28,%r9
    2785:	jge    2795 <botlish_fn_18+0x157d>
    278b:	mov    $0x1,%esi
    2790:	jmp    279a <botlish_fn_18+0x1582>
    2795:	mov    $0x4,%esi
    279a:	mov    %rsi,%rcx
    279d:	shl    $1,%rcx
    27a0:	or     $0x1,%rcx
    27a4:	mov    $0x2,%eax
    27a9:	cmp    $0x7,%rcx
    27ad:	cmovl  0x59db(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    27b5:	cmp    $0x6,%rax
    27b9:	je     2954 <botlish_fn_18+0x173c>
    27bf:	mov    %rsi,%rcx
    27c2:	shl    $1,%rcx
    27c5:	mov    %rsi,0x3c0(%rsp)
    27cd:	or     $0x1,%rcx
    27d1:	mov    $0x2,%eax
    27d6:	cmp    $0x7,%rcx
    27da:	cmove  0x59ae(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    27e2:	cmp    $0x6,%rax
    27e6:	je     2942 <botlish_fn_18+0x172a>
    27ec:	mov    0x378(%rsp),%rdx
    27f4:	test   $0x1,%rdx
    27fb:	jne    2833 <botlish_fn_18+0x161b>
    2801:	mov    0x3f0(%rsp),%rdx
    2809:	mov    0x378(%rsp),%rsi
    2811:	mov    0x358(%rsp),%rdi
    2819:	call   281e <botlish_fn_18+0x1606>
			281a: R_X86_64_PLT32	rt_int_cmp-0x4
    281e:	mov    $0x2,%esi
    2823:	test   %rax,%rax
    2826:	cmove  0x5962(%rip),%rsi        # 8190 <botlish_fn_18+0x6f78>
    282e:	jmp    284c <botlish_fn_18+0x1634>
    2833:	mov    $0x2,%esi
    2838:	mov    0x378(%rsp),%rdx
    2840:	cmp    $0xffffffffffffffff,%rdx
    2844:	cmove  0x5944(%rip),%rsi        # 8190 <botlish_fn_18+0x6f78>
    284c:	cmp    $0x6,%rsi
    2850:	je     28d8 <botlish_fn_18+0x16c0>
    2856:	mov    0x358(%rsp),%rdi
    285e:	mov    0x10(%rdi),%rax
    2862:	mov    0x1b0(%rax),%rbx
    2869:	mov    $0x1,%r12d
    286f:	mov    0x3c0(%rsp),%rsi
    2877:	shl    $1,%rsi
    287a:	or     $0x1,%rsi
    287e:	call   2883 <botlish_fn_18+0x166b>
			287f: R_X86_64_PLT32	botlish_fn_5-0x4
    2883:	mov    0x358(%rsp),%rdi
    288b:	mov    0x10(%rdi),%rcx
    288f:	mov    0x190(%rcx),%rdx
    2896:	lea    0x228(%rsp),%r9
    289e:	mov    %rbx,0x228(%rsp)
    28a6:	mov    %rax,0x230(%rsp)
    28ae:	mov    0x378(%rsp),%rax
    28b6:	mov    %rax,0x238(%rsp)
    28be:	mov    $0x5,%ecx
    28c3:	mov    %r12,%rsi
    28c6:	mov    0x3e0(%rsp),%r8
    28ce:	call   28d3 <botlish_fn_18+0x16bb>
			28cf: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    28d3:	jmp    37c0 <botlish_fn_18+0x25a8>
    28d8:	mov    0x3c0(%rsp),%rsi
    28e0:	mov    0x358(%rsp),%rdi
    28e8:	mov    0x10(%rdi),%rax
    28ec:	mov    0x1b0(%rax),%rbx
    28f3:	shl    $1,%rsi
    28f6:	or     $0x1,%rsi
    28fa:	call   28ff <botlish_fn_18+0x16e7>
			28fb: R_X86_64_PLT32	botlish_fn_5-0x4
    28ff:	mov    0x358(%rsp),%rdi
    2907:	mov    0x10(%rdi),%rcx
    290b:	mov    0x188(%rcx),%rdx
    2912:	lea    0x218(%rsp),%r9
    291a:	mov    %rbx,0x218(%rsp)
    2922:	mov    %rax,0x220(%rsp)
    292a:	mov    $0x2,%r8d
    2930:	mov    $0x4,%ecx
    2935:	mov    %r8,%rsi
    2938:	call   293d <botlish_fn_18+0x1725>
			2939: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    293d:	jmp    37c0 <botlish_fn_18+0x25a8>
    2942:	mov    0x378(%rsp),%rdx
    294a:	mov    %rdx,0x38(%rsp)
    294f:	jmp    3b0b <botlish_fn_18+0x28f3>
    2954:	shl    $1,%rsi
    2957:	or     $0x1,%rsi
    295b:	mov    %rsi,0xb8(%rsp)
    2963:	mov    %rsi,0x3c0(%rsp)
    296b:	mov    $0x1,%eax
    2970:	mov    %rax,0x370(%rsp)
    2978:	movq   $0x1,0x80(%rsp)
    2984:	mov    $0x5,%r12d
    298a:	mov    $0xa,%esi
    298f:	mov    %rsi,0x3a8(%rsp)
    2997:	mov    %rsi,0x3b0(%rsp)
    299f:	mov    %rsi,0x3b8(%rsp)
    29a7:	mov    %rsi,0x3c8(%rsp)
    29af:	mov    %rsi,0x3d0(%rsp)
    29b7:	jmp    3d3d <botlish_fn_18+0x2b25>
    29bc:	mov    0x378(%rsp),%rdx
    29c4:	test   $0x1,%rdx
    29cb:	jne    2a00 <botlish_fn_18+0x17e8>
    29d1:	mov    $0x49,%edx
    29d6:	mov    0x378(%rsp),%rsi
    29de:	mov    0x358(%rsp),%rdi
    29e6:	call   29eb <botlish_fn_18+0x17d3>
			29e7: R_X86_64_PLT32	rt_int_cmp-0x4
    29eb:	mov    $0x2,%ecx
    29f0:	test   %rax,%rax
    29f3:	cmovl  0x5795(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    29fb:	jmp    2a19 <botlish_fn_18+0x1801>
    2a00:	mov    $0x2,%ecx
    2a05:	mov    0x378(%rsp),%rdx
    2a0d:	cmp    $0x49,%rdx
    2a11:	cmovl  0x5777(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    2a19:	cmp    $0x6,%rcx
    2a1d:	je     2c5d <botlish_fn_18+0x1a45>
    2a23:	mov    0x378(%rsp),%rdx
    2a2b:	test   $0x1,%rdx
    2a32:	jne    2a67 <botlish_fn_18+0x184f>
    2a38:	mov    $0x21ffff,%edx
    2a3d:	mov    0x378(%rsp),%rsi
    2a45:	mov    0x358(%rsp),%rdi
    2a4d:	call   2a52 <botlish_fn_18+0x183a>
			2a4e: R_X86_64_PLT32	rt_int_cmp-0x4
    2a52:	mov    $0x2,%ecx
    2a57:	test   %rax,%rax
    2a5a:	cmovg  0x572e(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    2a62:	jmp    2a83 <botlish_fn_18+0x186b>
    2a67:	mov    $0x2,%ecx
    2a6c:	mov    0x378(%rsp),%rdx
    2a74:	cmp    $0x21ffff,%rdx
    2a7b:	cmovg  0x570d(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    2a83:	cmp    $0x6,%rcx
    2a87:	je     2c5d <botlish_fn_18+0x1a45>
    2a8d:	mov    0x378(%rsp),%rdx
    2a95:	mov    %rdx,%r9
    2a98:	sar    $1,%r9
    2a9b:	cmp    $0x5d,%r9
    2a9f:	jl     2b8b <botlish_fn_18+0x1973>
    2aa5:	cmp    $0x86,%r9
    2aac:	jl     2b2e <botlish_fn_18+0x1916>
    2ab2:	cmp    $0xfeff,%r9
    2ab9:	jl     2afd <botlish_fn_18+0x18e5>
    2abf:	cmp    $0xfffe,%r9
    2ac6:	jl     2aeb <botlish_fn_18+0x18d3>
    2acc:	cmp    $0x10000,%r9
    2ad3:	jl     2c5d <botlish_fn_18+0x1a45>
    2ad9:	cmp    $0x110000,%r9
    2ae0:	jge    2c5d <botlish_fn_18+0x1a45>
    2ae6:	jmp    2c53 <botlish_fn_18+0x1a3b>
    2aeb:	cmp    $0xff00,%r9
    2af2:	jge    2c53 <botlish_fn_18+0x1a3b>
    2af8:	jmp    2c5d <botlish_fn_18+0x1a45>
    2afd:	cmp    $0xd800,%r9
    2b04:	jl     2b1c <botlish_fn_18+0x1904>
    2b0a:	cmp    $0xe000,%r9
    2b11:	jge    2c53 <botlish_fn_18+0x1a3b>
    2b17:	jmp    2c5d <botlish_fn_18+0x1a45>
    2b1c:	cmp    $0xa0,%r9
    2b23:	jge    2c53 <botlish_fn_18+0x1a3b>
    2b29:	jmp    2c5d <botlish_fn_18+0x1a45>
    2b2e:	cmp    $0x7b,%r9
    2b32:	jl     2b63 <botlish_fn_18+0x194b>
    2b38:	cmp    $0x7f,%r9
    2b3c:	jl     2b54 <botlish_fn_18+0x193c>
    2b42:	cmp    $0x85,%r9
    2b49:	jge    2c53 <botlish_fn_18+0x1a3b>
    2b4f:	jmp    2c5d <botlish_fn_18+0x1a45>
    2b54:	cmp    $0x7e,%r9
    2b58:	jge    2c53 <botlish_fn_18+0x1a3b>
    2b5e:	jmp    2c5d <botlish_fn_18+0x1a45>
    2b63:	cmp    $0x60,%r9
    2b67:	jl     2b7c <botlish_fn_18+0x1964>
    2b6d:	cmp    $0x61,%r9
    2b71:	jge    2c53 <botlish_fn_18+0x1a3b>
    2b77:	jmp    2c5d <botlish_fn_18+0x1a45>
    2b7c:	cmp    $0x5e,%r9
    2b80:	jge    2c53 <botlish_fn_18+0x1a3b>
    2b86:	jmp    2c5d <botlish_fn_18+0x1a45>
    2b8b:	cmp    $0x2e,%r9
    2b8f:	jl     2bf9 <botlish_fn_18+0x19e1>
    2b95:	cmp    $0x3f,%r9
    2b99:	jl     2bd1 <botlish_fn_18+0x19b9>
    2b9f:	cmp    $0x41,%r9
    2ba3:	jl     2bc2 <botlish_fn_18+0x19aa>
    2ba9:	cmp    $0x5b,%r9
    2bad:	jl     2c53 <botlish_fn_18+0x1a3b>
    2bb3:	cmp    $0x5c,%r9
    2bb7:	jge    2c53 <botlish_fn_18+0x1a3b>
    2bbd:	jmp    2c5d <botlish_fn_18+0x1a45>
    2bc2:	cmp    $0x40,%r9
    2bc6:	jge    2c5d <botlish_fn_18+0x1a45>
    2bcc:	jmp    2c17 <botlish_fn_18+0x19ff>
    2bd1:	cmp    $0x3b,%r9
    2bd5:	jl     2bea <botlish_fn_18+0x19d2>
    2bdb:	cmp    $0x3e,%r9
    2bdf:	jge    2c5d <botlish_fn_18+0x1a45>
    2be5:	jmp    2c53 <botlish_fn_18+0x1a3b>
    2bea:	cmp    $0x3a,%r9
    2bee:	jge    2c17 <botlish_fn_18+0x19ff>
    2bf4:	jmp    2c53 <botlish_fn_18+0x1a3b>
    2bf9:	cmp    $0x2a,%r9
    2bfd:	jl     2c30 <botlish_fn_18+0x1a18>
    2c03:	cmp    $0x2c,%r9
    2c07:	jl     2c21 <botlish_fn_18+0x1a09>
    2c0d:	cmp    $0x2d,%r9
    2c11:	jl     2c5d <botlish_fn_18+0x1a45>
    2c17:	mov    $0x2,%esi
    2c1c:	jmp    2c62 <botlish_fn_18+0x1a4a>
    2c21:	cmp    $0x2b,%r9
    2c25:	jge    2c53 <botlish_fn_18+0x1a3b>
    2c2b:	jmp    2c5d <botlish_fn_18+0x1a45>
    2c30:	cmp    $0x25,%r9
    2c34:	jl     2c49 <botlish_fn_18+0x1a31>
    2c3a:	cmp    $0x28,%r9
    2c3e:	jge    2c53 <botlish_fn_18+0x1a3b>
    2c44:	jmp    2c5d <botlish_fn_18+0x1a45>
    2c49:	cmp    $0x24,%r9
    2c4d:	jl     2c5d <botlish_fn_18+0x1a45>
    2c53:	mov    $0x1,%esi
    2c58:	jmp    2c62 <botlish_fn_18+0x1a4a>
    2c5d:	mov    $0x7,%esi
    2c62:	mov    %rsi,%rcx
    2c65:	shl    $1,%rcx
    2c68:	or     $0x1,%rcx
    2c6c:	mov    $0x2,%eax
    2c71:	cmp    $0x9,%rcx
    2c75:	cmovl  0x5513(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    2c7d:	cmp    $0x6,%rax
    2c81:	je     2e96 <botlish_fn_18+0x1c7e>
    2c87:	mov    %rsi,%rcx
    2c8a:	shl    $1,%rcx
    2c8d:	or     $0x1,%rcx
    2c91:	mov    $0x2,%eax
    2c96:	cmp    $0x9,%rcx
    2c9a:	cmove  0x54ee(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    2ca2:	cmp    $0x6,%rax
    2ca6:	je     2e7c <botlish_fn_18+0x1c64>
    2cac:	mov    %rsi,%rax
    2caf:	shl    $1,%rax
    2cb2:	or     $0x1,%rax
    2cb6:	mov    $0x2,%r9d
    2cbc:	cmp    $0xb,%rax
    2cc0:	cmove  0x54c8(%rip),%r9        # 8190 <botlish_fn_18+0x6f78>
    2cc8:	cmp    $0x6,%r9
    2ccc:	je     2e68 <botlish_fn_18+0x1c50>
    2cd2:	mov    %rsi,%rcx
    2cd5:	shl    $1,%rcx
    2cd8:	mov    %rsi,0x3b8(%rsp)
    2ce0:	or     $0x1,%rcx
    2ce4:	mov    $0x2,%eax
    2ce9:	cmp    $0xd,%rcx
    2ced:	cmove  0x549b(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    2cf5:	cmp    $0x6,%rax
    2cf9:	je     2e54 <botlish_fn_18+0x1c3c>
    2cff:	mov    0x378(%rsp),%rdx
    2d07:	test   $0x1,%rdx
    2d0e:	jne    2d46 <botlish_fn_18+0x1b2e>
    2d14:	mov    0x3f0(%rsp),%rdx
    2d1c:	mov    0x378(%rsp),%rsi
    2d24:	mov    0x358(%rsp),%rdi
    2d2c:	call   2d31 <botlish_fn_18+0x1b19>
			2d2d: R_X86_64_PLT32	rt_int_cmp-0x4
    2d31:	mov    $0x2,%ecx
    2d36:	test   %rax,%rax
    2d39:	cmove  0x544f(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    2d41:	jmp    2d5f <botlish_fn_18+0x1b47>
    2d46:	mov    $0x2,%ecx
    2d4b:	mov    0x378(%rsp),%rdx
    2d53:	cmp    $0xffffffffffffffff,%rdx
    2d57:	cmove  0x5431(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    2d5f:	cmp    $0x6,%rcx
    2d63:	je     2dea <botlish_fn_18+0x1bd2>
    2d69:	mov    0x358(%rsp),%rdi
    2d71:	mov    0x10(%rdi),%rax
    2d75:	mov    0x1a8(%rax),%r15
    2d7c:	mov    $0x1,%ebx
    2d81:	mov    0x3b8(%rsp),%rsi
    2d89:	shl    $1,%rsi
    2d8c:	or     $0x1,%rsi
    2d90:	call   2d95 <botlish_fn_18+0x1b7d>
			2d91: R_X86_64_PLT32	botlish_fn_9-0x4
    2d95:	mov    0x358(%rsp),%rdi
    2d9d:	mov    0x10(%rdi),%rcx
    2da1:	mov    0x190(%rcx),%rdx
    2da8:	lea    0x200(%rsp),%r9
    2db0:	mov    %r15,0x200(%rsp)
    2db8:	mov    %rax,0x208(%rsp)
    2dc0:	mov    0x378(%rsp),%rax
    2dc8:	mov    %rax,0x210(%rsp)
    2dd0:	mov    $0x5,%ecx
    2dd5:	mov    %rbx,%rsi
    2dd8:	mov    0x3e0(%rsp),%r8
    2de0:	call   2de5 <botlish_fn_18+0x1bcd>
			2de1: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2de5:	jmp    37c0 <botlish_fn_18+0x25a8>
    2dea:	mov    0x3b8(%rsp),%rsi
    2df2:	mov    0x358(%rsp),%rdi
    2dfa:	mov    0x10(%rdi),%rax
    2dfe:	mov    0x1a8(%rax),%rbx
    2e05:	shl    $1,%rsi
    2e08:	or     $0x1,%rsi
    2e0c:	call   2e11 <botlish_fn_18+0x1bf9>
			2e0d: R_X86_64_PLT32	botlish_fn_9-0x4
    2e11:	mov    0x358(%rsp),%rdi
    2e19:	mov    0x10(%rdi),%rcx
    2e1d:	mov    0x188(%rcx),%rdx
    2e24:	lea    0x1f0(%rsp),%r9
    2e2c:	mov    %rbx,0x1f0(%rsp)
    2e34:	mov    %rax,0x1f8(%rsp)
    2e3c:	mov    $0x2,%r8d
    2e42:	mov    $0x4,%ecx
    2e47:	mov    %r8,%rsi
    2e4a:	call   2e4f <botlish_fn_18+0x1c37>
			2e4b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2e4f:	jmp    37c0 <botlish_fn_18+0x25a8>
    2e54:	mov    $0xfffffffffffffff9,%rdx
    2e5b:	mov    %rdx,0x378(%rsp)
    2e63:	jmp    2e84 <botlish_fn_18+0x1c6c>
    2e68:	mov    $0xfffffffffffffffb,%rdx
    2e6f:	mov    %rdx,0x378(%rsp)
    2e77:	jmp    2e84 <botlish_fn_18+0x1c6c>
    2e7c:	mov    0x378(%rsp),%rdx
    2e84:	mov    %rdx,0x38(%rsp)
    2e89:	mov    0x378(%rsp),%rdx
    2e91:	jmp    3b0b <botlish_fn_18+0x28f3>
    2e96:	shl    $1,%rsi
    2e99:	or     $0x1,%rsi
    2e9d:	mov    %rsi,0xb0(%rsp)
    2ea5:	mov    %rsi,0x3b8(%rsp)
    2ead:	mov    $0x1,%eax
    2eb2:	mov    %rax,0x370(%rsp)
    2eba:	movq   $0x1,0x80(%rsp)
    2ec6:	mov    $0x4,%r12d
    2ecc:	mov    $0xa,%esi
    2ed1:	mov    %rsi,0x3a8(%rsp)
    2ed9:	mov    %rsi,0x3b0(%rsp)
    2ee1:	mov    %rsi,0x3c0(%rsp)
    2ee9:	mov    %rsi,0x3c8(%rsp)
    2ef1:	mov    %rsi,0x3d0(%rsp)
    2ef9:	jmp    3d3d <botlish_fn_18+0x2b25>
    2efe:	mov    0x378(%rsp),%rdx
    2f06:	test   $0x1,%rdx
    2f0d:	jne    2f43 <botlish_fn_18+0x1d2b>
    2f13:	mov    $0x47,%edx
    2f18:	mov    0x378(%rsp),%rsi
    2f20:	mov    0x358(%rsp),%rdi
    2f28:	call   2f2d <botlish_fn_18+0x1d15>
			2f29: R_X86_64_PLT32	rt_int_cmp-0x4
    2f2d:	mov    $0x2,%r8d
    2f33:	test   %rax,%rax
    2f36:	cmovl  0x5252(%rip),%r8        # 8190 <botlish_fn_18+0x6f78>
    2f3e:	jmp    2f5d <botlish_fn_18+0x1d45>
    2f43:	mov    $0x2,%r8d
    2f49:	mov    0x378(%rsp),%rdx
    2f51:	cmp    $0x47,%rdx
    2f55:	cmovl  0x5233(%rip),%r8        # 8190 <botlish_fn_18+0x6f78>
    2f5d:	cmp    $0x6,%r8
    2f61:	je     2ffa <botlish_fn_18+0x1de2>
    2f67:	mov    0x378(%rsp),%rdx
    2f6f:	test   $0x1,%rdx
    2f76:	jne    2fab <botlish_fn_18+0x1d93>
    2f7c:	mov    $0x47,%edx
    2f81:	mov    0x378(%rsp),%rsi
    2f89:	mov    0x358(%rsp),%rdi
    2f91:	call   2f96 <botlish_fn_18+0x1d7e>
			2f92: R_X86_64_PLT32	rt_int_cmp-0x4
    2f96:	mov    $0x2,%ecx
    2f9b:	test   %rax,%rax
    2f9e:	cmovg  0x51ea(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    2fa6:	jmp    2fc4 <botlish_fn_18+0x1dac>
    2fab:	mov    $0x2,%ecx
    2fb0:	mov    0x378(%rsp),%rdx
    2fb8:	cmp    $0x47,%rdx
    2fbc:	cmovg  0x51cc(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    2fc4:	cmp    $0x6,%rcx
    2fc8:	je     2ffa <botlish_fn_18+0x1de2>
    2fce:	mov    0x378(%rsp),%rdx
    2fd6:	mov    %rdx,%rax
    2fd9:	sar    $1,%rax
    2fdc:	cmp    $0x23,%rax
    2fe0:	jl     2ffa <botlish_fn_18+0x1de2>
    2fe6:	cmp    $0x24,%rax
    2fea:	jge    2ffa <botlish_fn_18+0x1de2>
    2ff0:	mov    $0x1,%esi
    2ff5:	jmp    3002 <botlish_fn_18+0x1dea>
    2ffa:	mov    0x3e0(%rsp),%rsi
    3002:	mov    %rsi,%rcx
    3005:	shl    $1,%rcx
    3008:	or     $0x1,%rcx
    300c:	mov    $0x2,%eax
    3011:	cmp    $0x5,%rcx
    3015:	cmovl  0x5173(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    301d:	cmp    $0x6,%rax
    3021:	je     31be <botlish_fn_18+0x1fa6>
    3027:	mov    %rsi,%rdi
    302a:	shl    $1,%rdi
    302d:	mov    %rsi,0x3b0(%rsp)
    3035:	or     $0x1,%rdi
    3039:	mov    $0x2,%eax
    303e:	cmp    $0x5,%rdi
    3042:	cmove  0x5146(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    304a:	cmp    $0x6,%rax
    304e:	je     31ac <botlish_fn_18+0x1f94>
    3054:	mov    0x378(%rsp),%rdx
    305c:	test   $0x1,%rdx
    3063:	jne    309c <botlish_fn_18+0x1e84>
    3069:	mov    0x3f0(%rsp),%rdx
    3071:	mov    0x378(%rsp),%rsi
    3079:	mov    0x358(%rsp),%rdi
    3081:	call   3086 <botlish_fn_18+0x1e6e>
			3082: R_X86_64_PLT32	rt_int_cmp-0x4
    3086:	mov    $0x2,%r8d
    308c:	test   %rax,%rax
    308f:	cmove  0x50f9(%rip),%r8        # 8190 <botlish_fn_18+0x6f78>
    3097:	jmp    30b6 <botlish_fn_18+0x1e9e>
    309c:	mov    $0x2,%r8d
    30a2:	mov    0x378(%rsp),%rdx
    30aa:	cmp    $0xffffffffffffffff,%rdx
    30ae:	cmove  0x50da(%rip),%r8        # 8190 <botlish_fn_18+0x6f78>
    30b6:	cmp    $0x6,%r8
    30ba:	je     3142 <botlish_fn_18+0x1f2a>
    30c0:	mov    0x358(%rsp),%rdi
    30c8:	mov    0x10(%rdi),%rax
    30cc:	mov    0x1a0(%rax),%rbx
    30d3:	mov    $0x1,%r12d
    30d9:	mov    0x3b0(%rsp),%rsi
    30e1:	shl    $1,%rsi
    30e4:	or     $0x1,%rsi
    30e8:	call   30ed <botlish_fn_18+0x1ed5>
			30e9: R_X86_64_PLT32	botlish_fn_7-0x4
    30ed:	mov    0x358(%rsp),%rdi
    30f5:	mov    0x10(%rdi),%rcx
    30f9:	mov    0x190(%rcx),%rdx
    3100:	lea    0x1d8(%rsp),%r9
    3108:	mov    %rbx,0x1d8(%rsp)
    3110:	mov    %rax,0x1e0(%rsp)
    3118:	mov    0x378(%rsp),%rax
    3120:	mov    %rax,0x1e8(%rsp)
    3128:	mov    $0x5,%ecx
    312d:	mov    %r12,%rsi
    3130:	mov    0x3e0(%rsp),%r8
    3138:	call   313d <botlish_fn_18+0x1f25>
			3139: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    313d:	jmp    37c0 <botlish_fn_18+0x25a8>
    3142:	mov    0x3b0(%rsp),%rsi
    314a:	mov    0x358(%rsp),%rdi
    3152:	mov    0x10(%rdi),%rax
    3156:	mov    0x1a0(%rax),%rbx
    315d:	shl    $1,%rsi
    3160:	or     $0x1,%rsi
    3164:	call   3169 <botlish_fn_18+0x1f51>
			3165: R_X86_64_PLT32	botlish_fn_7-0x4
    3169:	mov    0x358(%rsp),%rdi
    3171:	mov    0x10(%rdi),%rcx
    3175:	mov    0x188(%rcx),%rdx
    317c:	lea    0x1c8(%rsp),%r9
    3184:	mov    %rbx,0x1c8(%rsp)
    318c:	mov    %rax,0x1d0(%rsp)
    3194:	mov    $0x2,%r8d
    319a:	mov    $0x4,%ecx
    319f:	mov    %r8,%rsi
    31a2:	call   31a7 <botlish_fn_18+0x1f8f>
			31a3: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    31a7:	jmp    37c0 <botlish_fn_18+0x25a8>
    31ac:	mov    0x378(%rsp),%rdx
    31b4:	mov    %rdx,0x38(%rsp)
    31b9:	jmp    3b0b <botlish_fn_18+0x28f3>
    31be:	shl    $1,%rsi
    31c1:	or     $0x1,%rsi
    31c5:	mov    %rsi,0xa8(%rsp)
    31cd:	mov    %rsi,0x3b0(%rsp)
    31d5:	mov    $0x1,%eax
    31da:	mov    %rax,0x370(%rsp)
    31e2:	movq   $0x1,0x80(%rsp)
    31ee:	mov    $0xa,%esi
    31f3:	mov    0x3e0(%rsp),%r12
    31fb:	mov    %rsi,0x3a8(%rsp)
    3203:	mov    %rsi,0x3b8(%rsp)
    320b:	mov    %rsi,0x3c0(%rsp)
    3213:	mov    %rsi,0x3c8(%rsp)
    321b:	mov    %rsi,0x3d0(%rsp)
    3223:	jmp    3d3d <botlish_fn_18+0x2b25>
    3228:	mov    0x378(%rsp),%rdx
    3230:	test   $0x1,%rdx
    3237:	jne    326c <botlish_fn_18+0x2054>
    323d:	mov    $0x45,%edx
    3242:	mov    0x378(%rsp),%rsi
    324a:	mov    0x358(%rsp),%rdi
    3252:	call   3257 <botlish_fn_18+0x203f>
			3253: R_X86_64_PLT32	rt_int_cmp-0x4
    3257:	mov    $0x2,%ecx
    325c:	test   %rax,%rax
    325f:	cmovl  0x4f29(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    3267:	jmp    3285 <botlish_fn_18+0x206d>
    326c:	mov    $0x2,%ecx
    3271:	mov    0x378(%rsp),%rdx
    3279:	cmp    $0x45,%rdx
    327d:	cmovl  0x4f0b(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    3285:	cmp    $0x6,%rcx
    3289:	je     3322 <botlish_fn_18+0x210a>
    328f:	mov    0x378(%rsp),%rdx
    3297:	test   $0x1,%rdx
    329e:	jne    32d3 <botlish_fn_18+0x20bb>
    32a4:	mov    $0x45,%edx
    32a9:	mov    0x378(%rsp),%rsi
    32b1:	mov    0x358(%rsp),%rdi
    32b9:	call   32be <botlish_fn_18+0x20a6>
			32ba: R_X86_64_PLT32	rt_int_cmp-0x4
    32be:	mov    $0x2,%ecx
    32c3:	test   %rax,%rax
    32c6:	cmovg  0x4ec2(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    32ce:	jmp    32ec <botlish_fn_18+0x20d4>
    32d3:	mov    $0x2,%ecx
    32d8:	mov    0x378(%rsp),%rdx
    32e0:	cmp    $0x45,%rdx
    32e4:	cmovg  0x4ea4(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    32ec:	cmp    $0x6,%rcx
    32f0:	je     3322 <botlish_fn_18+0x210a>
    32f6:	mov    0x378(%rsp),%rdx
    32fe:	mov    %rdx,%rax
    3301:	sar    $1,%rax
    3304:	cmp    $0x22,%rax
    3308:	jl     3322 <botlish_fn_18+0x210a>
    330e:	cmp    $0x23,%rax
    3312:	jge    3322 <botlish_fn_18+0x210a>
    3318:	mov    $0x1,%esi
    331d:	jmp    3327 <botlish_fn_18+0x210f>
    3322:	mov    $0x4,%esi
    3327:	mov    %rsi,%rax
    332a:	shl    $1,%rax
    332d:	or     $0x1,%rax
    3331:	mov    $0x2,%edi
    3336:	cmp    $0x5,%rax
    333a:	cmovl  0x4e4e(%rip),%rdi        # 8190 <botlish_fn_18+0x6f78>
    3342:	cmp    $0x6,%rdi
    3346:	je     3a37 <botlish_fn_18+0x281f>
    334c:	mov    %rsi,%rdi
    334f:	shl    $1,%rdi
    3352:	or     $0x1,%rdi
    3356:	mov    $0x2,%eax
    335b:	cmp    $0x5,%rdi
    335f:	cmove  0x4e29(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    3367:	cmp    $0x6,%rax
    336b:	je     3a1a <botlish_fn_18+0x2802>
    3371:	mov    %rsi,%r10
    3374:	shl    $1,%r10
    3377:	mov    %rsi,0x3d0(%rsp)
    337f:	or     $0x1,%r10
    3383:	mov    $0x2,%eax
    3388:	cmp    $0x7,%r10
    338c:	cmove  0x4dfc(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    3394:	cmp    $0x6,%rax
    3398:	je     34f4 <botlish_fn_18+0x22dc>
    339e:	mov    0x378(%rsp),%rdx
    33a6:	test   $0x1,%rdx
    33ad:	jne    33e5 <botlish_fn_18+0x21cd>
    33b3:	mov    0x3f0(%rsp),%rdx
    33bb:	mov    0x378(%rsp),%rsi
    33c3:	mov    0x358(%rsp),%rdi
    33cb:	call   33d0 <botlish_fn_18+0x21b8>
			33cc: R_X86_64_PLT32	rt_int_cmp-0x4
    33d0:	mov    $0x2,%ecx
    33d5:	test   %rax,%rax
    33d8:	cmove  0x4db0(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    33e0:	jmp    33fe <botlish_fn_18+0x21e6>
    33e5:	mov    $0x2,%ecx
    33ea:	mov    0x378(%rsp),%rdx
    33f2:	cmp    $0xffffffffffffffff,%rdx
    33f6:	cmove  0x4d92(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    33fe:	cmp    $0x6,%rcx
    3402:	je     348a <botlish_fn_18+0x2272>
    3408:	mov    0x358(%rsp),%rdi
    3410:	mov    0x10(%rdi),%rax
    3414:	mov    0x198(%rax),%rbx
    341b:	mov    $0x1,%r12d
    3421:	mov    0x3d0(%rsp),%rsi
    3429:	shl    $1,%rsi
    342c:	or     $0x1,%rsi
    3430:	call   3435 <botlish_fn_18+0x221d>
			3431: R_X86_64_PLT32	botlish_fn_3-0x4
    3435:	mov    0x358(%rsp),%rdi
    343d:	mov    0x10(%rdi),%rcx
    3441:	mov    0x190(%rcx),%rdx
    3448:	lea    0x1b0(%rsp),%r9
    3450:	mov    %rbx,0x1b0(%rsp)
    3458:	mov    %rax,0x1b8(%rsp)
    3460:	mov    0x378(%rsp),%rax
    3468:	mov    %rax,0x1c0(%rsp)
    3470:	mov    $0x5,%ecx
    3475:	mov    %r12,%rsi
    3478:	mov    0x3e0(%rsp),%r8
    3480:	call   3485 <botlish_fn_18+0x226d>
			3481: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3485:	jmp    37c0 <botlish_fn_18+0x25a8>
    348a:	mov    0x3d0(%rsp),%rsi
    3492:	mov    0x358(%rsp),%rdi
    349a:	mov    0x10(%rdi),%rax
    349e:	mov    0x198(%rax),%rbx
    34a5:	shl    $1,%rsi
    34a8:	or     $0x1,%rsi
    34ac:	call   34b1 <botlish_fn_18+0x2299>
			34ad: R_X86_64_PLT32	botlish_fn_3-0x4
    34b1:	mov    0x358(%rsp),%rdi
    34b9:	mov    0x10(%rdi),%rcx
    34bd:	mov    0x188(%rcx),%rdx
    34c4:	lea    0x1a0(%rsp),%r9
    34cc:	mov    %rbx,0x1a0(%rsp)
    34d4:	mov    %rax,0x1a8(%rsp)
    34dc:	mov    $0x2,%r8d
    34e2:	mov    $0x4,%ecx
    34e7:	mov    %r8,%rsi
    34ea:	call   34ef <botlish_fn_18+0x22d7>
			34eb: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    34ef:	jmp    37c0 <botlish_fn_18+0x25a8>
    34f4:	mov    0x358(%rsp),%rdi
    34fc:	mov    0x10(%rdi),%rax
    3500:	mov    0x178(%rax),%rbx
    3507:	mov    0x378(%rsp),%rdx
    350f:	test   $0x1,%rdx
    3516:	jne    354e <botlish_fn_18+0x2336>
    351c:	mov    0x3f0(%rsp),%rdx
    3524:	mov    0x378(%rsp),%rsi
    352c:	mov    0x358(%rsp),%rdi
    3534:	call   3539 <botlish_fn_18+0x2321>
			3535: R_X86_64_PLT32	rt_int_cmp-0x4
    3539:	mov    $0x2,%ecx
    353e:	test   %rax,%rax
    3541:	cmovl  0x4c47(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    3549:	jmp    3567 <botlish_fn_18+0x234f>
    354e:	mov    $0x2,%ecx
    3553:	mov    0x378(%rsp),%rdx
    355b:	cmp    $0xffffffffffffffff,%rdx
    355f:	cmovl  0x4c29(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    3567:	cmp    $0x6,%rcx
    356b:	je     35f4 <botlish_fn_18+0x23dc>
    3571:	mov    0x378(%rsp),%rdx
    3579:	test   $0x1,%rdx
    3580:	jne    35b5 <botlish_fn_18+0x239d>
    3586:	mov    $0x1ff,%edx
    358b:	mov    0x378(%rsp),%rsi
    3593:	mov    0x358(%rsp),%rdi
    359b:	call   35a0 <botlish_fn_18+0x2388>
			359c: R_X86_64_PLT32	rt_int_cmp-0x4
    35a0:	mov    $0x2,%ecx
    35a5:	test   %rax,%rax
    35a8:	cmovg  0x4be0(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    35b0:	jmp    35d1 <botlish_fn_18+0x23b9>
    35b5:	mov    $0x2,%ecx
    35ba:	mov    0x378(%rsp),%rdx
    35c2:	cmp    $0x1ff,%rdx
    35c9:	cmovg  0x4bbf(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    35d1:	cmp    $0x6,%rcx
    35d5:	je     35f4 <botlish_fn_18+0x23dc>
    35db:	mov    0x378(%rsp),%rdx
    35e3:	mov    %rdx,%rax
    35e6:	sar    $1,%rax
    35e9:	movzbq 0x11(%rbx,%rax,1),%rsi
    35ef:	jmp    35fc <botlish_fn_18+0x23e4>
    35f4:	movzbq 0xc1c(%rbx),%rsi
    35fc:	mov    %rsi,%rcx
    35ff:	shl    $1,%rcx
    3602:	or     $0x1,%rcx
    3606:	mov    $0x2,%eax
    360b:	cmp    $0x19,%rcx
    360f:	cmovl  0x4b79(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    3617:	cmp    $0x6,%rax
    361b:	je     39a0 <botlish_fn_18+0x2788>
    3621:	mov    %rsi,%rax
    3624:	shl    $1,%rax
    3627:	mov    %rsi,0x3a8(%rsp)
    362f:	or     $0x1,%rax
    3633:	mov    $0x2,%r10d
    3639:	cmp    $0x19,%rax
    363d:	cmove  0x4b4b(%rip),%r10        # 8190 <botlish_fn_18+0x6f78>
    3645:	cmp    $0x6,%r10
    3649:	je     397f <botlish_fn_18+0x2767>
    364f:	mov    0x378(%rsp),%rdx
    3657:	test   $0x1,%rdx
    365e:	jne    3696 <botlish_fn_18+0x247e>
    3664:	mov    0x3f0(%rsp),%rdx
    366c:	mov    0x378(%rsp),%rsi
    3674:	mov    0x358(%rsp),%rdi
    367c:	call   3681 <botlish_fn_18+0x2469>
			367d: R_X86_64_PLT32	rt_int_cmp-0x4
    3681:	mov    $0x2,%ecx
    3686:	test   %rax,%rax
    3689:	cmove  0x4aff(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    3691:	jmp    36af <botlish_fn_18+0x2497>
    3696:	mov    $0x2,%ecx
    369b:	mov    0x378(%rsp),%rdx
    36a3:	cmp    $0xffffffffffffffff,%rdx
    36a7:	cmove  0x4ae1(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    36af:	cmp    $0x6,%rcx
    36b3:	je     374b <botlish_fn_18+0x2533>
    36b9:	mov    0x358(%rsp),%rdi
    36c1:	mov    0x10(%rdi),%r8
    36c5:	mov    0x180(%r8),%r12
    36cc:	mov    $0x1,%r13d
    36d2:	mov    0x3a8(%rsp),%rsi
    36da:	shl    $1,%rsi
    36dd:	mov    %rsi,0x3a8(%rsp)
    36e5:	or     $0x1,%rsi
    36e9:	mov    %rsi,0x3a8(%rsp)
    36f1:	call   36f6 <botlish_fn_18+0x24de>
			36f2: R_X86_64_PLT32	botlish_fn_1-0x4
    36f6:	mov    0x358(%rsp),%rdi
    36fe:	mov    0x10(%rdi),%r8
    3702:	mov    0x190(%r8),%rdx
    3709:	lea    0x188(%rsp),%r9
    3711:	mov    %r12,0x188(%rsp)
    3719:	mov    %rax,0x190(%rsp)
    3721:	mov    0x378(%rsp),%r11
    3729:	mov    %r11,0x198(%rsp)
    3731:	mov    $0x5,%ecx
    3736:	mov    %r13,%rsi
    3739:	mov    0x3e0(%rsp),%r8
    3741:	call   3746 <botlish_fn_18+0x252e>
			3742: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3746:	jmp    37c0 <botlish_fn_18+0x25a8>
    374b:	mov    0x358(%rsp),%rdi
    3753:	mov    0x10(%rdi),%rax
    3757:	mov    0x180(%rax),%r12
    375e:	mov    0x3a8(%rsp),%rsi
    3766:	shl    $1,%rsi
    3769:	mov    %rsi,0x3a8(%rsp)
    3771:	or     $0x1,%rsi
    3775:	mov    %rsi,0x3a8(%rsp)
    377d:	call   3782 <botlish_fn_18+0x256a>
			377e: R_X86_64_PLT32	botlish_fn_1-0x4
    3782:	mov    0x358(%rsp),%rdi
    378a:	mov    0x10(%rdi),%rcx
    378e:	mov    0x188(%rcx),%rdx
    3795:	lea    0x178(%rsp),%r9
    379d:	mov    %r12,0x178(%rsp)
    37a5:	mov    %rax,0x180(%rsp)
    37ad:	mov    $0x2,%r8d
    37b3:	mov    $0x4,%ecx
    37b8:	mov    %r8,%rsi
    37bb:	call   37c0 <botlish_fn_18+0x25a8>
			37bc: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    37c0:	mov    0x358(%rsp),%rdi
    37c8:	call   37cd <botlish_fn_18+0x25b5>
			37c9: R_X86_64_PLT32	rt_co_failed-0x4
    37cd:	mov    %rax,0x88(%rsp)
    37d5:	mov    %rax,%rsi
    37d8:	mov    0x358(%rsp),%rdi
    37e0:	call   37e5 <botlish_fn_18+0x25cd>
			37e1: R_X86_64_PLT32	rt_co_resume0-0x4
    37e5:	test   %rax,%rax
    37e8:	je     380a <botlish_fn_18+0x25f2>
    37ee:	mov    0x358(%rsp),%rdi
    37f6:	mov    0x10(%rdi),%rax
    37fa:	mov    0x68(%rax),%rsi
    37fe:	mov    0x140(%rax),%rdx
    3805:	call   380a <botlish_fn_18+0x25f2>
			3806: R_X86_64_PLT32	rt_raise-0x4
    380a:	mov    0x358(%rsp),%rdi
    3812:	call   3817 <botlish_fn_18+0x25ff>
			3813: R_X86_64_PLT32	rt_declared_error-0x4
    3817:	cmp    $0x1,%rax
    381b:	je     38cb <botlish_fn_18+0x26b3>
    3821:	mov    0x358(%rsp),%rdi
    3829:	call   382e <botlish_fn_18+0x2616>
			382a: R_X86_64_PLT32	rt_declared_error-0x4
    382e:	cmp    $0x2,%rax
    3832:	jne    7f4e <botlish_fn_18+0x6d36>
    3838:	xor    %rsi,%rsi
    383b:	mov    0x358(%rsp),%rdi
    3843:	call   3848 <botlish_fn_18+0x2630>
			3844: R_X86_64_PLT32	rt_declared_payload-0x4
    3848:	mov    %rax,%r12
    384b:	mov    $0x1,%ebx
    3850:	mov    %rbx,%rsi
    3853:	mov    0x358(%rsp),%rdi
    385b:	call   3860 <botlish_fn_18+0x2648>
			385c: R_X86_64_PLT32	rt_declared_payload-0x4
    3860:	mov    %rax,%r13
    3863:	mov    0x358(%rsp),%rdi
    386b:	call   3870 <botlish_fn_18+0x2658>
			386c: R_X86_64_PLT32	rt_clear_declared_error-0x4
    3870:	mov    0x358(%rsp),%rdi
    3878:	mov    0x10(%rdi),%rax
    387c:	mov    0x158(%rax),%rdx
    3883:	lea    0xe8(%rsp),%r9
    388b:	mov    0x3e8(%rsp),%rax
    3893:	mov    %rax,0xe8(%rsp)
    389b:	mov    %r12,%rax
    389e:	mov    %rax,0xf0(%rsp)
    38a6:	mov    %r13,%rax
    38a9:	mov    %rax,0xf8(%rsp)
    38b1:	mov    $0x4,%esi
    38b6:	mov    %rbx,%rcx
    38b9:	mov    0x3e0(%rsp),%r8
    38c1:	call   38c6 <botlish_fn_18+0x26ae>
			38c2: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    38c6:	jmp    7f4e <botlish_fn_18+0x6d36>
    38cb:	xor    %rbx,%rbx
    38ce:	mov    %rbx,%rsi
    38d1:	mov    0x358(%rsp),%rdi
    38d9:	call   38de <botlish_fn_18+0x26c6>
			38da: R_X86_64_PLT32	rt_declared_payload-0x4
    38de:	mov    %rax,%r12
    38e1:	mov    $0x1,%esi
    38e6:	mov    0x358(%rsp),%rdi
    38ee:	call   38f3 <botlish_fn_18+0x26db>
			38ef: R_X86_64_PLT32	rt_declared_payload-0x4
    38f3:	mov    %rax,%r13
    38f6:	mov    $0x2,%esi
    38fb:	mov    0x358(%rsp),%rdi
    3903:	call   3908 <botlish_fn_18+0x26f0>
			3904: R_X86_64_PLT32	rt_declared_payload-0x4
    3908:	mov    %rax,%r14
    390b:	mov    0x358(%rsp),%rdi
    3913:	call   3918 <botlish_fn_18+0x2700>
			3914: R_X86_64_PLT32	rt_clear_declared_error-0x4
    3918:	mov    0x358(%rsp),%rdi
    3920:	mov    0x10(%rdi),%rax
    3924:	mov    0x150(%rax),%rdx
    392b:	lea    0xc8(%rsp),%r9
    3933:	mov    0x3e8(%rsp),%rsi
    393b:	mov    %rsi,0xc8(%rsp)
    3943:	mov    %r12,%rax
    3946:	mov    %rax,0xd0(%rsp)
    394e:	mov    %r13,%rax
    3951:	mov    %rax,0xd8(%rsp)
    3959:	mov    %r14,%rax
    395c:	mov    %rax,0xe0(%rsp)
    3964:	mov    $0x4,%r8d
    396a:	mov    %rbx,%rcx
    396d:	mov    0x3e0(%rsp),%rsi
    3975:	call   397a <botlish_fn_18+0x2762>
			3976: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    397a:	jmp    7f4e <botlish_fn_18+0x6d36>
    397f:	movq   $0x3,0x98(%rsp)
    398b:	mov    0x3e0(%rsp),%rax
    3993:	mov    %rax,0x3d0(%rsp)
    399b:	jmp    3a4e <botlish_fn_18+0x2836>
    39a0:	mov    %rsi,0x3a8(%rsp)
    39a8:	shl    $1,%rsi
    39ab:	mov    %rsi,0x3a8(%rsp)
    39b3:	or     $0x1,%rsi
    39b7:	mov    %rsi,0x3a8(%rsp)
    39bf:	mov    %rsi,0xa0(%rsp)
    39c7:	mov    $0x1,%eax
    39cc:	mov    %rax,0x370(%rsp)
    39d4:	movq   $0x1,0x80(%rsp)
    39e0:	mov    $0xa,%esi
    39e5:	mov    0x370(%rsp),%r12
    39ed:	mov    %rsi,0x3b0(%rsp)
    39f5:	mov    %rsi,0x3b8(%rsp)
    39fd:	mov    %rsi,0x3c0(%rsp)
    3a05:	mov    %rsi,0x3c8(%rsp)
    3a0d:	mov    %rsi,0x3d0(%rsp)
    3a15:	jmp    3d3d <botlish_fn_18+0x2b25>
    3a1a:	mov    $0xfffffffffffffffd,%rdx
    3a21:	mov    %rdx,0x378(%rsp)
    3a29:	movq   $0xfffffffffffffffd,0x38(%rsp)
    3a32:	jmp    3b0b <botlish_fn_18+0x28f3>
    3a37:	shl    $1,%rsi
    3a3a:	or     $0x1,%rsi
    3a3e:	mov    %rsi,0x98(%rsp)
    3a46:	mov    %rsi,0x3d0(%rsp)
    3a4e:	mov    $0x1,%eax
    3a53:	mov    %rax,0x370(%rsp)
    3a5b:	movq   $0x1,0x80(%rsp)
    3a67:	mov    $0x2,%r12d
    3a6d:	mov    $0xa,%esi
    3a72:	mov    %rsi,0x3a8(%rsp)
    3a7a:	mov    0x3a8(%rsp),%rax
    3a82:	mov    %rax,0x3b0(%rsp)
    3a8a:	mov    %rax,0x3b8(%rsp)
    3a92:	mov    %rax,0x3c0(%rsp)
    3a9a:	mov    %rax,0x3c8(%rsp)
    3aa2:	jmp    3d3d <botlish_fn_18+0x2b25>
    3aa7:	mov    $0xfffffffffffffff9,%rdx
    3aae:	mov    %rdx,0x378(%rsp)
    3ab6:	movq   $0xfffffffffffffff9,0x38(%rsp)
    3abf:	jmp    3b0b <botlish_fn_18+0x28f3>
    3ac4:	mov    $0xfffffffffffffffb,%rdx
    3acb:	mov    %rdx,0x378(%rsp)
    3ad3:	movq   $0xfffffffffffffffb,0x38(%rsp)
    3adc:	jmp    3b0b <botlish_fn_18+0x28f3>
    3ae1:	mov    0x378(%rsp),%rdx
    3ae9:	mov    %rdx,0x38(%rsp)
    3aee:	jmp    3b0b <botlish_fn_18+0x28f3>
    3af3:	mov    $0xfffffffffffffffd,%rdx
    3afa:	mov    %rdx,0x378(%rsp)
    3b02:	movq   $0xfffffffffffffffd,0x38(%rsp)
    3b0b:	test   $0x1,%rdx
    3b12:	jne    3b47 <botlish_fn_18+0x292f>
    3b18:	mov    $0x1,%edx
    3b1d:	mov    0x378(%rsp),%rsi
    3b25:	mov    0x358(%rsp),%rdi
    3b2d:	call   3b32 <botlish_fn_18+0x291a>
			3b2e: R_X86_64_PLT32	rt_int_cmp-0x4
    3b32:	mov    $0x2,%ecx
    3b37:	test   %rax,%rax
    3b3a:	cmovge 0x464e(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    3b42:	jmp    3b67 <botlish_fn_18+0x294f>
    3b47:	mov    $0x2,%ecx
    3b4c:	mov    0x378(%rsp),%rdx
    3b54:	mov    0x378(%rsp),%r8
    3b5c:	test   %r8,%rdx
    3b5f:	cmovg  0x4629(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    3b67:	cmp    $0x6,%rcx
    3b6b:	je     3c68 <botlish_fn_18+0x2a50>
    3b71:	mov    0x378(%rsp),%rdx
    3b79:	test   $0x1,%rdx
    3b80:	jne    3bb7 <botlish_fn_18+0x299f>
    3b86:	mov    $0xfffffffffffffffd,%rdx
    3b8d:	mov    0x378(%rsp),%rsi
    3b95:	mov    0x358(%rsp),%rdi
    3b9d:	call   3ba2 <botlish_fn_18+0x298a>
			3b9e: R_X86_64_PLT32	rt_int_cmp-0x4
    3ba2:	mov    $0x2,%ecx
    3ba7:	test   %rax,%rax
    3baa:	cmovl  0x45de(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    3bb2:	jmp    3bd0 <botlish_fn_18+0x29b8>
    3bb7:	mov    $0x2,%ecx
    3bbc:	mov    0x378(%rsp),%rdx
    3bc4:	cmp    $0xfffffffffffffffd,%rdx
    3bc8:	cmovl  0x45c0(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    3bd0:	cmp    $0x6,%rcx
    3bd4:	je     3bec <botlish_fn_18+0x29d4>
    3bda:	mov    $0x1,%eax
    3bdf:	mov    %rax,0x370(%rsp)
    3be7:	jmp    3c78 <botlish_fn_18+0x2a60>
    3bec:	mov    $0xfffffffffffffffd,%rsi
    3bf3:	movq   $0xfffffffffffffffd,0x40(%rsp)
    3bfc:	mov    0x378(%rsp),%rdx
    3c04:	test   $0x1,%rdx
    3c0b:	jne    3c1e <botlish_fn_18+0x2a06>
    3c11:	mov    0x378(%rsp),%rdx
    3c19:	jmp    3c4e <botlish_fn_18+0x2a36>
    3c1e:	mov    0x378(%rsp),%rdx
    3c26:	mov    %rsi,%rax
    3c29:	sub    %rdx,%rax
    3c2c:	seto   %cl
    3c2f:	add    $0x1,%rax
    3c36:	mov    %rax,0x370(%rsp)
    3c3e:	test   %cl,%cl
    3c40:	je     3c78 <botlish_fn_18+0x2a60>
    3c46:	mov    0x378(%rsp),%rdx
    3c4e:	mov    0x358(%rsp),%rdi
    3c56:	call   3c5b <botlish_fn_18+0x2a43>
			3c57: R_X86_64_PLT32	rt_int_sub-0x4
    3c5b:	mov    %rax,0x370(%rsp)
    3c63:	jmp    3c78 <botlish_fn_18+0x2a60>
    3c68:	mov    0x3e0(%rsp),%rax
    3c70:	mov    %rax,0x370(%rsp)
    3c78:	mov    0x370(%rsp),%rax
    3c80:	mov    %rax,0x80(%rsp)
    3c88:	mov    $0xa,%esi
    3c8d:	mov    %rsi,0x3a8(%rsp)
    3c95:	mov    0x3f0(%rsp),%r12
    3c9d:	mov    0x3a8(%rsp),%rax
    3ca5:	mov    %rax,0x3b0(%rsp)
    3cad:	mov    %rax,0x3b8(%rsp)
    3cb5:	mov    %rax,0x3c0(%rsp)
    3cbd:	mov    %rax,0x3c8(%rsp)
    3cc5:	mov    %rax,0x3d0(%rsp)
    3ccd:	jmp    3d3d <botlish_fn_18+0x2b25>
    3cd2:	shl    $1,%rsi
    3cd5:	or     $0x1,%rsi
    3cd9:	mov    %rsi,0x90(%rsp)
    3ce1:	mov    %rsi,0x3c8(%rsp)
    3ce9:	mov    $0x1,%eax
    3cee:	mov    %rax,0x370(%rsp)
    3cf6:	movq   $0x1,0x80(%rsp)
    3d02:	mov    $0x6,%r12d
    3d08:	mov    $0xa,%esi
    3d0d:	mov    %rsi,0x3a8(%rsp)
    3d15:	mov    0x3a8(%rsp),%rax
    3d1d:	mov    %rax,0x3b0(%rsp)
    3d25:	mov    %rax,0x3b8(%rsp)
    3d2d:	mov    %rax,0x3c0(%rsp)
    3d35:	mov    %rax,0x3d0(%rsp)
    3d3d:	mov    0x400(%rsp),%rcx
    3d45:	mov    0x18(%rcx),%rcx
    3d49:	test   %rcx,%rcx
    3d4c:	je     8076 <botlish_fn_18+0x6e5e>
    3d52:	mov    0x400(%rsp),%rcx
    3d5a:	mov    0x10(%rcx),%rcx
    3d5e:	mov    0x370(%rsp),%rax
    3d66:	mov    %rax,0x18(%rcx)
    3d6a:	test   %r12,%r12
    3d6d:	jl     7a24 <botlish_fn_18+0x680c>
    3d73:	mov    0x400(%rsp),%rcx
    3d7b:	mov    0x10(%rcx),%rax
    3d7f:	mov    (%rax),%rdx
    3d82:	mov    %rdx,0x30(%rsp)
    3d87:	mov    0x3e8(%rsp),%rcx
    3d8f:	mov    %rdx,%rax
    3d92:	and    %rcx,%rax
    3d95:	test   $0x1,%rax
    3d9b:	jne    3dae <botlish_fn_18+0x2b96>
    3da1:	mov    %rdx,0x3d8(%rsp)
    3da9:	jmp    3de0 <botlish_fn_18+0x2bc8>
    3dae:	mov    0x3e8(%rsp),%rsi
    3db6:	mov    %rdx,%rcx
    3db9:	sub    %rsi,%rcx
    3dbc:	mov    %rdx,0x3d8(%rsp)
    3dc4:	seto   %al
    3dc7:	lea    0x1(%rcx),%rsi
    3dcb:	test   %al,%al
    3dcd:	jne    3de0 <botlish_fn_18+0x2bc8>
    3dd3:	mov    0x368(%rsp),%rdx
    3ddb:	jmp    3e08 <botlish_fn_18+0x2bf0>
    3de0:	mov    0x3e8(%rsp),%rdx
    3de8:	mov    0x3d8(%rsp),%rsi
    3df0:	mov    0x358(%rsp),%rdi
    3df8:	call   3dfd <botlish_fn_18+0x2be5>
			3df9: R_X86_64_PLT32	rt_int_sub-0x4
    3dfd:	mov    0x368(%rsp),%rdx
    3e05:	mov    %rax,%rsi
    3e08:	mov    %rsi,%rax
    3e0b:	and    %rdx,%rax
    3e0e:	mov    %rdx,0x368(%rsp)
    3e16:	test   $0x1,%rax
    3e1c:	jne    3e4d <botlish_fn_18+0x2c35>
    3e22:	mov    0x368(%rsp),%rdx
    3e2a:	mov    0x358(%rsp),%rdi
    3e32:	call   3e37 <botlish_fn_18+0x2c1f>
			3e33: R_X86_64_PLT32	rt_int_cmp-0x4
    3e37:	mov    $0x2,%r11d
    3e3d:	test   %rax,%rax
    3e40:	cmovge 0x4348(%rip),%r11        # 8190 <botlish_fn_18+0x6f78>
    3e48:	jmp    3e66 <botlish_fn_18+0x2c4e>
    3e4d:	mov    $0x2,%r11d
    3e53:	mov    0x368(%rsp),%rdx
    3e5b:	cmp    %rdx,%rsi
    3e5e:	cmovge 0x432a(%rip),%r11        # 8190 <botlish_fn_18+0x6f78>
    3e66:	cmp    $0x6,%r11
    3e6a:	je     79d1 <botlish_fn_18+0x67b9>
    3e70:	mov    0x400(%rsp),%rcx
    3e78:	mov    0x10(%rcx),%rax
    3e7c:	mov    0x8(%rax),%rdx
    3e80:	mov    0x3d8(%rsp),%rcx
    3e88:	mov    %rcx,%rax
    3e8b:	and    %rdx,%rax
    3e8e:	test   $0x1,%rax
    3e94:	jne    3ec4 <botlish_fn_18+0x2cac>
    3e9a:	mov    0x3d8(%rsp),%rsi
    3ea2:	mov    0x358(%rsp),%rdi
    3eaa:	call   3eaf <botlish_fn_18+0x2c97>
			3eab: R_X86_64_PLT32	rt_int_cmp-0x4
    3eaf:	mov    $0x2,%ecx
    3eb4:	test   %rax,%rax
    3eb7:	cmovl  0x42d1(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    3ebf:	jmp    3edc <botlish_fn_18+0x2cc4>
    3ec4:	mov    $0x2,%ecx
    3ec9:	mov    0x3d8(%rsp),%rax
    3ed1:	cmp    %rdx,%rax
    3ed4:	cmovl  0x42b4(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    3edc:	cmp    $0x6,%rcx
    3ee0:	je     4404 <botlish_fn_18+0x31ec>
    3ee6:	mov    0x380(%rsp),%r10
    3eee:	cmp    $0x1,%r10
    3ef2:	je     3f1c <botlish_fn_18+0x2d04>
    3ef8:	mov    $0xa,%esi
    3efd:	mov    0x380(%rsp),%r10
    3f05:	cmp    $0xffffffffffffffff,%r10
    3f09:	jne    40dd <botlish_fn_18+0x2ec5>
    3f0f:	mov    0x390(%rsp),%rax
    3f17:	jmp    423d <botlish_fn_18+0x3025>
    3f1c:	add    $0x1,%r14
    3f23:	cmp    %r13,%r14
    3f26:	jl     418a <botlish_fn_18+0x2f72>
    3f2c:	movq   $0x3,0x38(%rsp)
    3f35:	mov    0x3a0(%rsp),%rsi
    3f3d:	test   $0x1,%rsi
    3f44:	jne    3f57 <botlish_fn_18+0x2d3f>
    3f4a:	mov    0x3a0(%rsp),%rsi
    3f52:	jmp    3f8e <botlish_fn_18+0x2d76>
    3f57:	mov    0x3a0(%rsp),%rsi
    3f5f:	mov    %rsi,%rax
    3f62:	add    $0x2,%rax
    3f66:	seto   %cl
    3f69:	test   %cl,%cl
    3f6b:	je     3f7e <botlish_fn_18+0x2d66>
    3f71:	mov    0x3a0(%rsp),%rsi
    3f79:	jmp    3f8e <botlish_fn_18+0x2d76>
    3f7e:	mov    %rax,%rsi
    3f81:	mov    %rax,0x3a0(%rsp)
    3f89:	jmp    3fae <botlish_fn_18+0x2d96>
    3f8e:	mov    0x3e0(%rsp),%rdx
    3f96:	mov    0x358(%rsp),%rdi
    3f9e:	call   3fa3 <botlish_fn_18+0x2d8b>
			3f9f: R_X86_64_PLT32	rt_int_add-0x4
    3fa3:	mov    %rax,%rsi
    3fa6:	mov    %rax,0x3a0(%rsp)
    3fae:	mov    %rsi,0x70(%rsp)
    3fb3:	mov    0x418(%rsp),%rcx
    3fbb:	mov    0x3a0(%rsp),%rsi
    3fc3:	mov    %rsi,%rax
    3fc6:	and    %rcx,%rax
    3fc9:	test   $0x1,%rax
    3fcf:	jne    4007 <botlish_fn_18+0x2def>
    3fd5:	mov    0x418(%rsp),%rdx
    3fdd:	mov    0x3a0(%rsp),%rsi
    3fe5:	mov    0x358(%rsp),%rdi
    3fed:	call   3ff2 <botlish_fn_18+0x2dda>
			3fee: R_X86_64_PLT32	rt_int_cmp-0x4
    3ff2:	mov    $0x2,%ecx
    3ff7:	test   %rax,%rax
    3ffa:	cmovl  0x418e(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    4002:	jmp    4027 <botlish_fn_18+0x2e0f>
    4007:	mov    $0x2,%ecx
    400c:	mov    0x418(%rsp),%rax
    4014:	mov    0x3a0(%rsp),%rsi
    401c:	cmp    %rax,%rsi
    401f:	cmovl  0x4169(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    4027:	cmp    $0x6,%rcx
    402b:	je     405f <botlish_fn_18+0x2e47>
    4031:	movq   $0xffffffffffffffff,0x50(%rsp)
    403a:	mov    0x3f0(%rsp),%rax
    4042:	mov    0x3f0(%rsp),%rcx
    404a:	mov    %rcx,0x380(%rsp)
    4052:	mov    %rcx,0x390(%rsp)
    405a:	jmp    423d <botlish_fn_18+0x3025>
    405f:	mov    0x3a0(%rsp),%rsi
    4067:	test   $0x1,%rsi
    406e:	je     4097 <botlish_fn_18+0x2e7f>
    4074:	mov    0x360(%rsp),%r15
    407c:	mov    0x8(%r15),%rcx
    4080:	mov    0x3a0(%rsp),%rsi
    4088:	mov    %rsi,%rax
    408b:	sar    $1,%rax
    408e:	cmp    %rcx,%rax
    4091:	jb     414f <botlish_fn_18+0x2f37>
    4097:	mov    0x3a0(%rsp),%rdx
    409f:	mov    0x360(%rsp),%rsi
    40a7:	mov    0x358(%rsp),%rdi
    40af:	call   40b4 <botlish_fn_18+0x2e9c>
			40b0: R_X86_64_PLT32	rt_list_get-0x4
    40b4:	mov    %rax,%rsi
    40b7:	mov    %rax,0x398(%rsp)
    40bf:	test   %rsi,%rax
    40c2:	jne    4142 <botlish_fn_18+0x2f2a>
    40c8:	mov    0x358(%rsp),%rdi
    40d0:	call   40d5 <botlish_fn_18+0x2ebd>
			40d1: R_X86_64_PLT32	rt_co_failed-0x4
    40d5:	mov    %rax,0x58(%rsp)
    40da:	mov    %rax,%rsi
    40dd:	mov    0x358(%rsp),%rdi
    40e5:	call   40ea <botlish_fn_18+0x2ed2>
			40e6: R_X86_64_PLT32	rt_co_resume0-0x4
    40ea:	test   %rax,%rax
    40ed:	jne    4100 <botlish_fn_18+0x2ee8>
    40f3:	mov    0x358(%rsp),%rdi
    40fb:	jmp    4124 <botlish_fn_18+0x2f0c>
    4100:	mov    0x358(%rsp),%rdi
    4108:	mov    0x10(%rdi),%rax
    410c:	mov    0x68(%rax),%rsi
    4110:	mov    0x140(%rax),%rdx
    4117:	call   411c <botlish_fn_18+0x2f04>
			4118: R_X86_64_PLT32	rt_raise-0x4
    411c:	mov    0x358(%rsp),%rdi
    4124:	mov    0x358(%rsp),%rdi
    412c:	call   4131 <botlish_fn_18+0x2f19>
			412d: R_X86_64_PLT32	rt_declared_error-0x4
    4131:	cmp    $0x40000001,%rax
    4137:	jne    7f4e <botlish_fn_18+0x6d36>
    413d:	jmp    7f4e <botlish_fn_18+0x6d36>
    4142:	mov    0x398(%rsp),%rax
    414a:	jmp    4167 <botlish_fn_18+0x2f4f>
    414f:	mov    0x360(%rsp),%r15
    4157:	mov    0x10(%r15),%rcx
    415b:	mov    (%rcx,%rax,8),%rax
    415f:	mov    %rax,0x398(%rsp)
    4167:	mov    %rax,0x78(%rsp)
    416c:	mov    0x398(%rsp),%rax
    4174:	mov    0x8(%rax),%r13
    4178:	xor    %r14,%r14
    417b:	shl    $1,%r13
    417e:	or     $0x1,%r13
    4182:	sar    $1,%r13
    4185:	jmp    3f23 <botlish_fn_18+0x2d0b>
    418a:	mov    0x398(%rsp),%rax
    4192:	movzbq 0x18(%rax),%rsi
    4197:	test   %rsi,%rsi
    419a:	jne    41cc <botlish_fn_18+0x2fb4>
    41a0:	mov    %r14,%rdx
    41a3:	shl    $1,%rdx
    41a6:	or     $0x1,%rdx
    41aa:	mov    0x398(%rsp),%rsi
    41b2:	mov    0x358(%rsp),%rdi
    41ba:	call   41bf <botlish_fn_18+0x2fa7>
			41bb: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    41bf:	mov    %rax,0x390(%rsp)
    41c7:	jmp    4207 <botlish_fn_18+0x2fef>
    41cc:	mov    %r14,%rsi
    41cf:	shl    $1,%rsi
    41d2:	or     $0x1,%rsi
    41d6:	sar    $1,%rsi
    41d9:	mov    0x398(%rsp),%rax
    41e1:	movzbq 0x19(%rax,%rsi,1),%rax
    41e7:	mov    %rax,0x390(%rsp)
    41ef:	shl    $0x3,%rax
    41f3:	mov    %rax,0x390(%rsp)
    41fb:	or     $0x4,%rax
    41ff:	mov    %rax,0x390(%rsp)
    4207:	shr    $0x3,%rax
    420b:	mov    %rax,0x390(%rsp)
    4213:	mov    $0x1,%r10d
    4219:	mov    %r10,0x380(%rsp)
    4221:	shl    $1,%rax
    4224:	mov    %rax,0x390(%rsp)
    422c:	or     $0x1,%rax
    4230:	mov    %rax,0x390(%rsp)
    4238:	mov    %rax,0x50(%rsp)
    423d:	mov    %rax,0x38(%rsp)
    4242:	mov    0x390(%rsp),%rax
    424a:	test   $0x1,%rax
    4250:	jne    4288 <botlish_fn_18+0x3070>
    4256:	mov    0x3f0(%rsp),%rdx
    425e:	mov    0x390(%rsp),%rsi
    4266:	mov    0x358(%rsp),%rdi
    426e:	call   4273 <botlish_fn_18+0x305b>
			426f: R_X86_64_PLT32	rt_int_cmp-0x4
    4273:	mov    $0x2,%ecx
    4278:	test   %rax,%rax
    427b:	cmove  0x3f0d(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    4283:	jmp    42a1 <botlish_fn_18+0x3089>
    4288:	mov    $0x2,%ecx
    428d:	mov    0x390(%rsp),%rax
    4295:	cmp    $0xffffffffffffffff,%rax
    4299:	cmove  0x3eef(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    42a1:	cmp    $0x6,%rcx
    42a5:	je     43e2 <botlish_fn_18+0x31ca>
    42ab:	movq   $0x3,0x40(%rsp)
    42b4:	mov    0x3d8(%rsp),%rcx
    42bc:	test   $0x1,%rcx
    42c3:	jne    42f6 <botlish_fn_18+0x30de>
    42c9:	mov    0x3e0(%rsp),%rdx
    42d1:	mov    0x3d8(%rsp),%rsi
    42d9:	mov    0x358(%rsp),%rdi
    42e1:	call   42e6 <botlish_fn_18+0x30ce>
			42e2: R_X86_64_PLT32	rt_int_and-0x4
    42e6:	mov    0x408(%rsp),%rcx
    42ee:	mov    %rax,%rdx
    42f1:	jmp    430d <botlish_fn_18+0x30f5>
    42f6:	mov    0x3d8(%rsp),%rcx
    42fe:	mov    %rcx,%rdx
    4301:	and    $0x3,%rdx
    4305:	mov    0x408(%rsp),%rcx
    430d:	mov    0x408(%rsp),%rcx
    4315:	mov    0x18(%rcx),%rax
    4319:	test   %rax,%rax
    431c:	je     809d <botlish_fn_18+0x6e85>
    4322:	mov    0x408(%rsp),%rcx
    432a:	mov    0x10(%rcx),%rax
    432e:	sar    $1,%rdx
    4331:	mov    0x390(%rsp),%rcx
    4339:	mov    %rcx,(%rax,%rdx,8)
    433d:	movq   $0x3,0x40(%rsp)
    4346:	movq   $0x3,0x48(%rsp)
    434f:	mov    0x3d8(%rsp),%rcx
    4357:	test   $0x1,%rcx
    435e:	je     4388 <botlish_fn_18+0x3170>
    4364:	mov    0x3d8(%rsp),%rcx
    436c:	add    $0x2,%rcx
    4370:	seto   %al
    4373:	test   %al,%al
    4375:	jne    4388 <botlish_fn_18+0x3170>
    437b:	mov    0x400(%rsp),%rdi
    4383:	jmp    43b0 <botlish_fn_18+0x3198>
    4388:	mov    0x3e0(%rsp),%rdx
    4390:	mov    0x3d8(%rsp),%rsi
    4398:	mov    0x358(%rsp),%rdi
    43a0:	call   43a5 <botlish_fn_18+0x318d>
			43a1: R_X86_64_PLT32	rt_int_add-0x4
    43a5:	mov    %rax,%rcx
    43a8:	mov    0x400(%rsp),%rdi
    43b0:	mov    0x400(%rsp),%rdi
    43b8:	mov    0x18(%rdi),%rax
    43bc:	test   %rax,%rax
    43bf:	je     80bf <botlish_fn_18+0x6ea7>
    43c5:	mov    0x400(%rsp),%rax
    43cd:	mov    0x10(%rax),%rax
    43d1:	mov    %rcx,0x8(%rax)
    43d5:	mov    0x390(%rsp),%rax
    43dd:	jmp    43ea <botlish_fn_18+0x31d2>
    43e2:	mov    0x390(%rsp),%rax
    43ea:	mov    0x390(%rsp),%rax
    43f2:	mov    %rax,0x38(%rsp)
    43f7:	mov    0x390(%rsp),%rdx
    43ff:	jmp    447b <botlish_fn_18+0x3263>
    4404:	movq   $0x3,0x38(%rsp)
    440d:	mov    0x3d8(%rsp),%rcx
    4415:	test   $0x1,%rcx
    441c:	jne    444c <botlish_fn_18+0x3234>
    4422:	mov    0x3e0(%rsp),%rdx
    442a:	mov    0x3d8(%rsp),%rsi
    4432:	mov    0x358(%rsp),%rdi
    443a:	call   443f <botlish_fn_18+0x3227>
			443b: R_X86_64_PLT32	rt_int_and-0x4
    443f:	mov    0x408(%rsp),%rcx
    4447:	jmp    4463 <botlish_fn_18+0x324b>
    444c:	mov    0x3d8(%rsp),%rcx
    4454:	mov    %rcx,%rax
    4457:	and    $0x3,%rax
    445b:	mov    0x408(%rsp),%rcx
    4463:	mov    0x408(%rsp),%rcx
    446b:	mov    0x10(%rcx),%rcx
    446f:	sar    $1,%rax
    4472:	mov    (%rcx,%rax,8),%rdx
    4476:	mov    %rdx,0x38(%rsp)
    447b:	test   $0x1,%rdx
    4482:	mov    %rdx,0x378(%rsp)
    448a:	jne    44c2 <botlish_fn_18+0x32aa>
    4490:	mov    0x3f0(%rsp),%rdx
    4498:	mov    0x378(%rsp),%rsi
    44a0:	mov    0x358(%rsp),%rdi
    44a8:	call   44ad <botlish_fn_18+0x3295>
			44a9: R_X86_64_PLT32	rt_int_cmp-0x4
    44ad:	mov    $0x2,%esi
    44b2:	test   %rax,%rax
    44b5:	cmove  0x3cd3(%rip),%rsi        # 8190 <botlish_fn_18+0x6f78>
    44bd:	jmp    44db <botlish_fn_18+0x32c3>
    44c2:	mov    $0x2,%esi
    44c7:	mov    0x378(%rsp),%rdx
    44cf:	cmp    $0xffffffffffffffff,%rdx
    44d3:	cmove  0x3cb5(%rip),%rsi        # 8190 <botlish_fn_18+0x6f78>
    44db:	cmp    $0x6,%rsi
    44df:	je     457e <botlish_fn_18+0x3366>
    44e5:	movq   $0x1,0x40(%rsp)
    44ee:	movq   $0x3,0x48(%rsp)
    44f7:	mov    0x3d8(%rsp),%rcx
    44ff:	test   $0x1,%rcx
    4506:	je     4532 <botlish_fn_18+0x331a>
    450c:	mov    0x3d8(%rsp),%rcx
    4514:	add    $0x2,%rcx
    4518:	seto   %r9b
    451c:	test   %r9b,%r9b
    451f:	jne    4532 <botlish_fn_18+0x331a>
    4525:	mov    0x400(%rsp),%rax
    452d:	jmp    455a <botlish_fn_18+0x3342>
    4532:	mov    0x3e0(%rsp),%rdx
    453a:	mov    0x3d8(%rsp),%rsi
    4542:	mov    0x358(%rsp),%rdi
    454a:	call   454f <botlish_fn_18+0x3337>
			454b: R_X86_64_PLT32	rt_int_add-0x4
    454f:	mov    %rax,%rcx
    4552:	mov    0x400(%rsp),%rax
    455a:	mov    0x400(%rsp),%rax
    4562:	mov    0x18(%rax),%rax
    4566:	test   %rax,%rax
    4569:	je     80e1 <botlish_fn_18+0x6ec9>
    456f:	mov    0x400(%rsp),%rsi
    4577:	mov    0x10(%rsi),%rax
    457b:	mov    %rcx,(%rax)
    457e:	cmp    $0x1,%r12
    4582:	je     748d <botlish_fn_18+0x6275>
    4588:	cmp    $0x2,%r12
    458c:	je     6dde <botlish_fn_18+0x5bc6>
    4592:	cmp    $0x3,%r12
    4596:	je     6885 <botlish_fn_18+0x566d>
    459c:	mov    $0x4,%ecx
    45a1:	mov    %rcx,%rbx
    45a4:	cmp    $0x4,%r12
    45a8:	je     5bb3 <botlish_fn_18+0x499b>
    45ae:	cmp    $0x5,%r12
    45b2:	je     5588 <botlish_fn_18+0x4370>
    45b8:	cmp    $0x6,%r12
    45bc:	je     45de <botlish_fn_18+0x33c6>
    45c2:	mov    $0xa,%esi
    45c7:	cmp    $0xffffffffffffffff,%r12
    45cb:	jne    777c <botlish_fn_18+0x6564>
    45d1:	mov    0x3a8(%rsp),%r15
    45d9:	jmp    7997 <botlish_fn_18+0x677f>
    45de:	mov    0x3c8(%rsp),%rsi
    45e6:	mov    0x3c8(%rsp),%r12
    45ee:	or     $0x1,%rsi
    45f2:	mov    %rsi,0x3c8(%rsp)
    45fa:	sar    $1,%rsi
    45fd:	mov    %rsi,0x3c8(%rsp)
    4605:	cmp    $0x4,%rsi
    4609:	jb     461c <botlish_fn_18+0x3404>
    460f:	mov    0x358(%rsp),%rdi
    4617:	jmp    5564 <botlish_fn_18+0x434c>
    461c:	mov    $0x4,%eax
    4621:	mov    0x3c8(%rsp),%rsi
    4629:	mov    %esi,%ecx
    462b:	cmp    %eax,%ecx
    462d:	cmovb  %ecx,%eax
    4630:	lea    0x9(%rip),%rcx        # 4640 <botlish_fn_18+0x3428>
    4637:	movslq (%rcx,%rax,4),%rax
    463b:	add    %rax,%rcx
    463e:	jmp    *%rcx
    4640:	(bad)
    4641:	or     %al,(%rax)
    4643:	add    %dl,0x5(%rax)
    4646:	add    %al,(%rax)
    4648:	enter  $0x2,$0x0
    464c:	and    %eax,(%rax)
    464e:	add    %al,(%rax)
    4650:	adc    $0x0,%al
    4652:	add    %al,(%rax)
    4654:	mov    0x358(%rsp),%rdi
    465c:	jmp    5564 <botlish_fn_18+0x434c>
    4661:	mov    0x378(%rsp),%rdx
    4669:	test   $0x1,%rdx
    4670:	jne    46a8 <botlish_fn_18+0x3490>
    4676:	mov    0x3f0(%rsp),%rdx
    467e:	mov    0x378(%rsp),%rsi
    4686:	mov    0x358(%rsp),%rdi
    468e:	call   4693 <botlish_fn_18+0x347b>
			468f: R_X86_64_PLT32	rt_int_cmp-0x4
    4693:	mov    $0x2,%ecx
    4698:	test   %rax,%rax
    469b:	cmovl  0x3aed(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    46a3:	jmp    46c1 <botlish_fn_18+0x34a9>
    46a8:	mov    $0x2,%ecx
    46ad:	mov    0x378(%rsp),%rdx
    46b5:	cmp    $0xffffffffffffffff,%rdx
    46b9:	cmovl  0x3acf(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    46c1:	cmp    $0x6,%rcx
    46c5:	je     48f6 <botlish_fn_18+0x36de>
    46cb:	mov    0x378(%rsp),%rdx
    46d3:	test   $0x1,%rdx
    46da:	jne    470f <botlish_fn_18+0x34f7>
    46e0:	mov    $0x21ffff,%edx
    46e5:	mov    0x378(%rsp),%rsi
    46ed:	mov    0x358(%rsp),%rdi
    46f5:	call   46fa <botlish_fn_18+0x34e2>
			46f6: R_X86_64_PLT32	rt_int_cmp-0x4
    46fa:	mov    $0x2,%ecx
    46ff:	test   %rax,%rax
    4702:	cmovg  0x3a86(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    470a:	jmp    472b <botlish_fn_18+0x3513>
    470f:	mov    $0x2,%ecx
    4714:	mov    0x378(%rsp),%rdx
    471c:	cmp    $0x21ffff,%rdx
    4723:	cmovg  0x3a65(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    472b:	cmp    $0x6,%rcx
    472f:	je     48f6 <botlish_fn_18+0x36de>
    4735:	mov    0x378(%rsp),%rdx
    473d:	mov    %rdx,%rax
    4740:	sar    $1,%rax
    4743:	cmp    $0x5e,%rax
    4747:	jl     481f <botlish_fn_18+0x3607>
    474d:	cmp    $0xa0,%rax
    4753:	jl     47c1 <botlish_fn_18+0x35a9>
    4759:	cmp    $0xff00,%rax
    475f:	jl     4793 <botlish_fn_18+0x357b>
    4765:	cmp    $0x10000,%rax
    476b:	jl     4782 <botlish_fn_18+0x356a>
    4771:	cmp    $0x110000,%rax
    4777:	jge    48f6 <botlish_fn_18+0x36de>
    477d:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4782:	cmp    $0xfffe,%rax
    4788:	jge    48f6 <botlish_fn_18+0x36de>
    478e:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4793:	cmp    $0xe000,%rax
    4799:	jl     47b0 <botlish_fn_18+0x3598>
    479f:	cmp    $0xfeff,%rax
    47a5:	jge    48f6 <botlish_fn_18+0x36de>
    47ab:	jmp    4dbd <botlish_fn_18+0x3ba5>
    47b0:	cmp    $0xd800,%rax
    47b6:	jge    48f6 <botlish_fn_18+0x36de>
    47bc:	jmp    4dbd <botlish_fn_18+0x3ba5>
    47c1:	cmp    $0x7e,%rax
    47c5:	jl     47f7 <botlish_fn_18+0x35df>
    47cb:	cmp    $0x85,%rax
    47d1:	jl     47e8 <botlish_fn_18+0x35d0>
    47d7:	cmp    $0x86,%rax
    47dd:	jge    48f6 <botlish_fn_18+0x36de>
    47e3:	jmp    4dbd <botlish_fn_18+0x3ba5>
    47e8:	cmp    $0x7f,%rax
    47ec:	jge    48f6 <botlish_fn_18+0x36de>
    47f2:	jmp    4dbd <botlish_fn_18+0x3ba5>
    47f7:	cmp    $0x7c,%rax
    47fb:	jl     4810 <botlish_fn_18+0x35f8>
    4801:	cmp    $0x7d,%rax
    4805:	jge    48c8 <botlish_fn_18+0x36b0>
    480b:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4810:	cmp    $0x7b,%rax
    4814:	jge    48c8 <botlish_fn_18+0x36b0>
    481a:	jmp    4dbd <botlish_fn_18+0x3ba5>
    481f:	cmp    $0x21,%rax
    4823:	jl     4883 <botlish_fn_18+0x366b>
    4829:	cmp    $0x3b,%rax
    482d:	jl     485b <botlish_fn_18+0x3643>
    4833:	cmp    $0x5c,%rax
    4837:	jl     484c <botlish_fn_18+0x3634>
    483d:	cmp    $0x5d,%rax
    4841:	jge    48c8 <botlish_fn_18+0x36b0>
    4847:	jmp    4dbd <botlish_fn_18+0x3ba5>
    484c:	cmp    $0x5b,%rax
    4850:	jge    48c8 <botlish_fn_18+0x36b0>
    4856:	jmp    4dbd <botlish_fn_18+0x3ba5>
    485b:	cmp    $0x2d,%rax
    485f:	jl     4874 <botlish_fn_18+0x365c>
    4865:	cmp    $0x3a,%rax
    4869:	jge    4d9e <botlish_fn_18+0x3b86>
    486f:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4874:	cmp    $0x2c,%rax
    4878:	jge    48c8 <botlish_fn_18+0x36b0>
    487e:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4883:	cmp    $0xb,%rax
    4887:	jl     48b5 <botlish_fn_18+0x369d>
    488d:	cmp    $0xe,%rax
    4891:	jl     48a6 <botlish_fn_18+0x368e>
    4897:	cmp    $0x20,%rax
    489b:	jge    48c8 <botlish_fn_18+0x36b0>
    48a1:	jmp    48f6 <botlish_fn_18+0x36de>
    48a6:	cmp    $0xd,%rax
    48aa:	jge    48c8 <botlish_fn_18+0x36b0>
    48b0:	jmp    48f6 <botlish_fn_18+0x36de>
    48b5:	test   %rax,%rax
    48b8:	jl     48da <botlish_fn_18+0x36c2>
    48be:	cmp    $0x9,%rax
    48c2:	jl     48f6 <botlish_fn_18+0x36de>
    48c8:	mov    $0x7,%esi
    48cd:	mov    %rsi,0x3c8(%rsp)
    48d5:	jmp    515f <botlish_fn_18+0x3f47>
    48da:	cmp    $0xffffffffffffffff,%rax
    48de:	jl     48f6 <botlish_fn_18+0x36de>
    48e4:	mov    $0x6,%esi
    48e9:	mov    %rsi,0x3c8(%rsp)
    48f1:	jmp    515f <botlish_fn_18+0x3f47>
    48f6:	mov    $0xf,%esi
    48fb:	mov    %rsi,0x3c8(%rsp)
    4903:	jmp    515f <botlish_fn_18+0x3f47>
    4908:	mov    0x378(%rsp),%rdx
    4910:	test   $0x1,%rdx
    4917:	jne    494f <botlish_fn_18+0x3737>
    491d:	mov    0x3f0(%rsp),%rdx
    4925:	mov    0x378(%rsp),%rsi
    492d:	mov    0x358(%rsp),%rdi
    4935:	call   493a <botlish_fn_18+0x3722>
			4936: R_X86_64_PLT32	rt_int_cmp-0x4
    493a:	mov    $0x2,%ecx
    493f:	test   %rax,%rax
    4942:	cmovl  0x3846(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    494a:	jmp    4968 <botlish_fn_18+0x3750>
    494f:	mov    $0x2,%ecx
    4954:	mov    0x378(%rsp),%rdx
    495c:	cmp    $0xffffffffffffffff,%rdx
    4960:	cmovl  0x3828(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    4968:	cmp    $0x6,%rcx
    496c:	je     4b7e <botlish_fn_18+0x3966>
    4972:	mov    0x378(%rsp),%rdx
    497a:	test   $0x1,%rdx
    4981:	jne    49b6 <botlish_fn_18+0x379e>
    4987:	mov    $0x21ffff,%edx
    498c:	mov    0x378(%rsp),%rsi
    4994:	mov    0x358(%rsp),%rdi
    499c:	call   49a1 <botlish_fn_18+0x3789>
			499d: R_X86_64_PLT32	rt_int_cmp-0x4
    49a1:	mov    $0x2,%esi
    49a6:	test   %rax,%rax
    49a9:	cmovg  0x37df(%rip),%rsi        # 8190 <botlish_fn_18+0x6f78>
    49b1:	jmp    49d2 <botlish_fn_18+0x37ba>
    49b6:	mov    $0x2,%esi
    49bb:	mov    0x378(%rsp),%rdx
    49c3:	cmp    $0x21ffff,%rdx
    49ca:	cmovg  0x37be(%rip),%rsi        # 8190 <botlish_fn_18+0x6f78>
    49d2:	cmp    $0x6,%rsi
    49d6:	je     4b7e <botlish_fn_18+0x3966>
    49dc:	mov    0x378(%rsp),%rdx
    49e4:	mov    %rdx,%rax
    49e7:	sar    $1,%rax
    49ea:	cmp    $0x5e,%rax
    49ee:	jl     4ac6 <botlish_fn_18+0x38ae>
    49f4:	cmp    $0xa0,%rax
    49fa:	jl     4a68 <botlish_fn_18+0x3850>
    4a00:	cmp    $0xff00,%rax
    4a06:	jl     4a3a <botlish_fn_18+0x3822>
    4a0c:	cmp    $0x10000,%rax
    4a12:	jl     4a29 <botlish_fn_18+0x3811>
    4a18:	cmp    $0x110000,%rax
    4a1e:	jge    4b7e <botlish_fn_18+0x3966>
    4a24:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4a29:	cmp    $0xfffe,%rax
    4a2f:	jge    4b7e <botlish_fn_18+0x3966>
    4a35:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4a3a:	cmp    $0xe000,%rax
    4a40:	jl     4a57 <botlish_fn_18+0x383f>
    4a46:	cmp    $0xfeff,%rax
    4a4c:	jge    4b7e <botlish_fn_18+0x3966>
    4a52:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4a57:	cmp    $0xd800,%rax
    4a5d:	jge    4b7e <botlish_fn_18+0x3966>
    4a63:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4a68:	cmp    $0x7e,%rax
    4a6c:	jl     4a9e <botlish_fn_18+0x3886>
    4a72:	cmp    $0x85,%rax
    4a78:	jl     4a8f <botlish_fn_18+0x3877>
    4a7e:	cmp    $0x86,%rax
    4a84:	jge    4b7e <botlish_fn_18+0x3966>
    4a8a:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4a8f:	cmp    $0x7f,%rax
    4a93:	jge    4b7e <botlish_fn_18+0x3966>
    4a99:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4a9e:	cmp    $0x7c,%rax
    4aa2:	jl     4ab7 <botlish_fn_18+0x389f>
    4aa8:	cmp    $0x7d,%rax
    4aac:	jge    4e23 <botlish_fn_18+0x3c0b>
    4ab2:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4ab7:	cmp    $0x7b,%rax
    4abb:	jge    4e23 <botlish_fn_18+0x3c0b>
    4ac1:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4ac6:	cmp    $0x21,%rax
    4aca:	jl     4b2a <botlish_fn_18+0x3912>
    4ad0:	cmp    $0x3b,%rax
    4ad4:	jl     4b02 <botlish_fn_18+0x38ea>
    4ada:	cmp    $0x5c,%rax
    4ade:	jl     4af3 <botlish_fn_18+0x38db>
    4ae4:	cmp    $0x5d,%rax
    4ae8:	jge    4e23 <botlish_fn_18+0x3c0b>
    4aee:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4af3:	cmp    $0x5b,%rax
    4af7:	jge    4e23 <botlish_fn_18+0x3c0b>
    4afd:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4b02:	cmp    $0x2d,%rax
    4b06:	jl     4b1b <botlish_fn_18+0x3903>
    4b0c:	cmp    $0x3a,%rax
    4b10:	jge    4d9e <botlish_fn_18+0x3b86>
    4b16:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4b1b:	cmp    $0x2c,%rax
    4b1f:	jge    4e23 <botlish_fn_18+0x3c0b>
    4b25:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4b2a:	cmp    $0xb,%rax
    4b2e:	jl     4b5c <botlish_fn_18+0x3944>
    4b34:	cmp    $0xe,%rax
    4b38:	jl     4b4d <botlish_fn_18+0x3935>
    4b3e:	cmp    $0x20,%rax
    4b42:	jge    4e23 <botlish_fn_18+0x3c0b>
    4b48:	jmp    4b7e <botlish_fn_18+0x3966>
    4b4d:	cmp    $0xd,%rax
    4b51:	jge    4e23 <botlish_fn_18+0x3c0b>
    4b57:	jmp    4b7e <botlish_fn_18+0x3966>
    4b5c:	test   %rax,%rax
    4b5f:	jl     4b74 <botlish_fn_18+0x395c>
    4b65:	cmp    $0x9,%rax
    4b69:	jge    4e23 <botlish_fn_18+0x3c0b>
    4b6f:	jmp    4b7e <botlish_fn_18+0x3966>
    4b74:	cmp    $0xffffffffffffffff,%rax
    4b78:	jge    4e23 <botlish_fn_18+0x3c0b>
    4b7e:	mov    $0xe,%esi
    4b83:	mov    %rsi,0x3c8(%rsp)
    4b8b:	jmp    515f <botlish_fn_18+0x3f47>
    4b90:	mov    0x378(%rsp),%rdx
    4b98:	test   $0x1,%rdx
    4b9f:	jne    4bd7 <botlish_fn_18+0x39bf>
    4ba5:	mov    0x3f0(%rsp),%rdx
    4bad:	mov    0x378(%rsp),%rsi
    4bb5:	mov    0x358(%rsp),%rdi
    4bbd:	call   4bc2 <botlish_fn_18+0x39aa>
			4bbe: R_X86_64_PLT32	rt_int_cmp-0x4
    4bc2:	mov    $0x2,%ecx
    4bc7:	test   %rax,%rax
    4bca:	cmovl  0x35be(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    4bd2:	jmp    4bf0 <botlish_fn_18+0x39d8>
    4bd7:	mov    $0x2,%ecx
    4bdc:	mov    0x378(%rsp),%rdx
    4be4:	cmp    $0xffffffffffffffff,%rdx
    4be8:	cmovl  0x35a0(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    4bf0:	cmp    $0x6,%rcx
    4bf4:	je     4e35 <botlish_fn_18+0x3c1d>
    4bfa:	mov    0x378(%rsp),%rdx
    4c02:	test   $0x1,%rdx
    4c09:	jne    4c3e <botlish_fn_18+0x3a26>
    4c0f:	mov    $0x21ffff,%edx
    4c14:	mov    0x378(%rsp),%rsi
    4c1c:	mov    0x358(%rsp),%rdi
    4c24:	call   4c29 <botlish_fn_18+0x3a11>
			4c25: R_X86_64_PLT32	rt_int_cmp-0x4
    4c29:	mov    $0x2,%ecx
    4c2e:	test   %rax,%rax
    4c31:	cmovg  0x3557(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    4c39:	jmp    4c5a <botlish_fn_18+0x3a42>
    4c3e:	mov    $0x2,%ecx
    4c43:	mov    0x378(%rsp),%rdx
    4c4b:	cmp    $0x21ffff,%rdx
    4c52:	cmovg  0x3536(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    4c5a:	cmp    $0x6,%rcx
    4c5e:	je     4e35 <botlish_fn_18+0x3c1d>
    4c64:	mov    0x378(%rsp),%rdx
    4c6c:	mov    %rdx,%rax
    4c6f:	sar    $1,%rax
    4c72:	cmp    $0x5e,%rax
    4c76:	jl     4d4e <botlish_fn_18+0x3b36>
    4c7c:	cmp    $0xa0,%rax
    4c82:	jl     4cf0 <botlish_fn_18+0x3ad8>
    4c88:	cmp    $0xff00,%rax
    4c8e:	jl     4cc2 <botlish_fn_18+0x3aaa>
    4c94:	cmp    $0x10000,%rax
    4c9a:	jl     4cb1 <botlish_fn_18+0x3a99>
    4ca0:	cmp    $0x110000,%rax
    4ca6:	jge    4e35 <botlish_fn_18+0x3c1d>
    4cac:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4cb1:	cmp    $0xfffe,%rax
    4cb7:	jge    4e35 <botlish_fn_18+0x3c1d>
    4cbd:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4cc2:	cmp    $0xe000,%rax
    4cc8:	jl     4cdf <botlish_fn_18+0x3ac7>
    4cce:	cmp    $0xfeff,%rax
    4cd4:	jge    4e35 <botlish_fn_18+0x3c1d>
    4cda:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4cdf:	cmp    $0xd800,%rax
    4ce5:	jge    4e35 <botlish_fn_18+0x3c1d>
    4ceb:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4cf0:	cmp    $0x7e,%rax
    4cf4:	jl     4d26 <botlish_fn_18+0x3b0e>
    4cfa:	cmp    $0x85,%rax
    4d00:	jl     4d17 <botlish_fn_18+0x3aff>
    4d06:	cmp    $0x86,%rax
    4d0c:	jge    4e35 <botlish_fn_18+0x3c1d>
    4d12:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4d17:	cmp    $0x7f,%rax
    4d1b:	jge    4e35 <botlish_fn_18+0x3c1d>
    4d21:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4d26:	cmp    $0x7c,%rax
    4d2a:	jl     4d3f <botlish_fn_18+0x3b27>
    4d30:	cmp    $0x7d,%rax
    4d34:	jge    4e23 <botlish_fn_18+0x3c0b>
    4d3a:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4d3f:	cmp    $0x7b,%rax
    4d43:	jge    4e23 <botlish_fn_18+0x3c0b>
    4d49:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4d4e:	cmp    $0x21,%rax
    4d52:	jl     4dcf <botlish_fn_18+0x3bb7>
    4d58:	cmp    $0x3b,%rax
    4d5c:	jl     4d8a <botlish_fn_18+0x3b72>
    4d62:	cmp    $0x5c,%rax
    4d66:	jl     4d7b <botlish_fn_18+0x3b63>
    4d6c:	cmp    $0x5d,%rax
    4d70:	jge    4e23 <botlish_fn_18+0x3c0b>
    4d76:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4d7b:	cmp    $0x5b,%rax
    4d7f:	jge    4e23 <botlish_fn_18+0x3c0b>
    4d85:	jmp    4dbd <botlish_fn_18+0x3ba5>
    4d8a:	cmp    $0x2d,%rax
    4d8e:	jl     4db3 <botlish_fn_18+0x3b9b>
    4d94:	cmp    $0x3a,%rax
    4d98:	jl     4dbd <botlish_fn_18+0x3ba5>
    4d9e:	mov    0x3e0(%rsp),%rax
    4da6:	mov    %rax,0x3c8(%rsp)
    4dae:	jmp    515f <botlish_fn_18+0x3f47>
    4db3:	cmp    $0x2c,%rax
    4db7:	jge    4e23 <botlish_fn_18+0x3c0b>
    4dbd:	mov    $0x2,%esi
    4dc2:	mov    %rsi,0x3c8(%rsp)
    4dca:	jmp    515f <botlish_fn_18+0x3f47>
    4dcf:	cmp    $0xb,%rax
    4dd3:	jl     4e01 <botlish_fn_18+0x3be9>
    4dd9:	cmp    $0xe,%rax
    4ddd:	jl     4df2 <botlish_fn_18+0x3bda>
    4de3:	cmp    $0x20,%rax
    4de7:	jge    4e23 <botlish_fn_18+0x3c0b>
    4ded:	jmp    4e35 <botlish_fn_18+0x3c1d>
    4df2:	cmp    $0xd,%rax
    4df6:	jge    4e23 <botlish_fn_18+0x3c0b>
    4dfc:	jmp    4e35 <botlish_fn_18+0x3c1d>
    4e01:	test   %rax,%rax
    4e04:	jl     4e19 <botlish_fn_18+0x3c01>
    4e0a:	cmp    $0x9,%rax
    4e0e:	jge    4e23 <botlish_fn_18+0x3c0b>
    4e14:	jmp    4e35 <botlish_fn_18+0x3c1d>
    4e19:	cmp    $0xffffffffffffffff,%rax
    4e1d:	jl     4e35 <botlish_fn_18+0x3c1d>
    4e23:	mov    $0x5,%esi
    4e28:	mov    %rsi,0x3c8(%rsp)
    4e30:	jmp    515f <botlish_fn_18+0x3f47>
    4e35:	mov    $0xd,%esi
    4e3a:	mov    %rsi,0x3c8(%rsp)
    4e42:	jmp    515f <botlish_fn_18+0x3f47>
    4e47:	mov    0x378(%rsp),%rdx
    4e4f:	test   $0x1,%rdx
    4e56:	jne    4e8b <botlish_fn_18+0x3c73>
    4e5c:	mov    $0x45,%edx
    4e61:	mov    0x378(%rsp),%rsi
    4e69:	mov    0x358(%rsp),%rdi
    4e71:	call   4e76 <botlish_fn_18+0x3c5e>
			4e72: R_X86_64_PLT32	rt_int_cmp-0x4
    4e76:	mov    $0x2,%ecx
    4e7b:	test   %rax,%rax
    4e7e:	cmovl  0x330a(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    4e86:	jmp    4ea4 <botlish_fn_18+0x3c8c>
    4e8b:	mov    $0x2,%ecx
    4e90:	mov    0x378(%rsp),%rdx
    4e98:	cmp    $0x45,%rdx
    4e9c:	cmovl  0x32ec(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    4ea4:	cmp    $0x6,%rcx
    4ea8:	je     5152 <botlish_fn_18+0x3f3a>
    4eae:	mov    0x378(%rsp),%rdx
    4eb6:	test   $0x1,%rdx
    4ebd:	jne    4ef2 <botlish_fn_18+0x3cda>
    4ec3:	mov    $0x21ffff,%edx
    4ec8:	mov    0x378(%rsp),%rsi
    4ed0:	mov    0x358(%rsp),%rdi
    4ed8:	call   4edd <botlish_fn_18+0x3cc5>
			4ed9: R_X86_64_PLT32	rt_int_cmp-0x4
    4edd:	mov    $0x2,%esi
    4ee2:	test   %rax,%rax
    4ee5:	cmovg  0x32a3(%rip),%rsi        # 8190 <botlish_fn_18+0x6f78>
    4eed:	jmp    4f0e <botlish_fn_18+0x3cf6>
    4ef2:	mov    $0x2,%esi
    4ef7:	mov    0x378(%rsp),%rdx
    4eff:	cmp    $0x21ffff,%rdx
    4f06:	cmovg  0x3282(%rip),%rsi        # 8190 <botlish_fn_18+0x6f78>
    4f0e:	cmp    $0x6,%rsi
    4f12:	je     5152 <botlish_fn_18+0x3f3a>
    4f18:	mov    0x378(%rsp),%rdx
    4f20:	mov    %rdx,%rax
    4f23:	sar    $1,%rax
    4f26:	cmp    $0x5d,%rax
    4f2a:	jl     5020 <botlish_fn_18+0x3e08>
    4f30:	cmp    $0x85,%rax
    4f36:	jl     4fbc <botlish_fn_18+0x3da4>
    4f3c:	cmp    $0xfeff,%rax
    4f42:	jl     4f82 <botlish_fn_18+0x3d6a>
    4f48:	cmp    $0xfffe,%rax
    4f4e:	jl     4f71 <botlish_fn_18+0x3d59>
    4f54:	cmp    $0x10000,%rax
    4f5a:	jl     5152 <botlish_fn_18+0x3f3a>
    4f60:	cmp    $0x110000,%rax
    4f66:	jge    5152 <botlish_fn_18+0x3f3a>
    4f6c:	jmp    510f <botlish_fn_18+0x3ef7>
    4f71:	cmp    $0xff00,%rax
    4f77:	jge    510f <botlish_fn_18+0x3ef7>
    4f7d:	jmp    5152 <botlish_fn_18+0x3f3a>
    4f82:	cmp    $0xa0,%rax
    4f88:	jl     4fab <botlish_fn_18+0x3d93>
    4f8e:	cmp    $0xd800,%rax
    4f94:	jl     510f <botlish_fn_18+0x3ef7>
    4f9a:	cmp    $0xe000,%rax
    4fa0:	jge    510f <botlish_fn_18+0x3ef7>
    4fa6:	jmp    5152 <botlish_fn_18+0x3f3a>
    4fab:	cmp    $0x86,%rax
    4fb1:	jge    5152 <botlish_fn_18+0x3f3a>
    4fb7:	jmp    510f <botlish_fn_18+0x3ef7>
    4fbc:	cmp    $0x7b,%rax
    4fc0:	jl     4ff8 <botlish_fn_18+0x3de0>
    4fc6:	cmp    $0x7d,%rax
    4fca:	jl     4fe9 <botlish_fn_18+0x3dd1>
    4fd0:	cmp    $0x7e,%rax
    4fd4:	jl     50a5 <botlish_fn_18+0x3e8d>
    4fda:	cmp    $0x7f,%rax
    4fde:	jge    5152 <botlish_fn_18+0x3f3a>
    4fe4:	jmp    510f <botlish_fn_18+0x3ef7>
    4fe9:	cmp    $0x7c,%rax
    4fed:	jge    5152 <botlish_fn_18+0x3f3a>
    4ff3:	jmp    50a5 <botlish_fn_18+0x3e8d>
    4ff8:	cmp    $0x60,%rax
    4ffc:	jl     5011 <botlish_fn_18+0x3df9>
    5002:	cmp    $0x61,%rax
    5006:	jge    510f <botlish_fn_18+0x3ef7>
    500c:	jmp    5152 <botlish_fn_18+0x3f3a>
    5011:	cmp    $0x5e,%rax
    5015:	jge    510f <botlish_fn_18+0x3ef7>
    501b:	jmp    50a5 <botlish_fn_18+0x3e8d>
    5020:	cmp    $0x2c,%rax
    5024:	jl     50b2 <botlish_fn_18+0x3e9a>
    502a:	cmp    $0x3f,%rax
    502e:	jl     5066 <botlish_fn_18+0x3e4e>
    5034:	cmp    $0x41,%rax
    5038:	jl     5057 <botlish_fn_18+0x3e3f>
    503e:	cmp    $0x5b,%rax
    5042:	jl     510f <botlish_fn_18+0x3ef7>
    5048:	cmp    $0x5c,%rax
    504c:	jge    510f <botlish_fn_18+0x3ef7>
    5052:	jmp    50a5 <botlish_fn_18+0x3e8d>
    5057:	cmp    $0x40,%rax
    505b:	jge    5152 <botlish_fn_18+0x3f3a>
    5061:	jmp    510f <botlish_fn_18+0x3ef7>
    5066:	cmp    $0x3a,%rax
    506a:	jl     509b <botlish_fn_18+0x3e83>
    5070:	cmp    $0x3b,%rax
    5074:	jl     5089 <botlish_fn_18+0x3e71>
    507a:	cmp    $0x3e,%rax
    507e:	jge    5152 <botlish_fn_18+0x3f3a>
    5084:	jmp    510f <botlish_fn_18+0x3ef7>
    5089:	mov    $0x1,%esi
    508e:	mov    %rsi,0x3c8(%rsp)
    5096:	jmp    515f <botlish_fn_18+0x3f47>
    509b:	cmp    $0x2d,%rax
    509f:	jge    510f <botlish_fn_18+0x3ef7>
    50a5:	mov    %rbx,0x3c8(%rsp)
    50ad:	jmp    515f <botlish_fn_18+0x3f47>
    50b2:	cmp    $0x25,%rax
    50b6:	jl     50fb <botlish_fn_18+0x3ee3>
    50bc:	cmp    $0x28,%rax
    50c0:	jl     50df <botlish_fn_18+0x3ec7>
    50c6:	cmp    $0x2a,%rax
    50ca:	jl     510f <botlish_fn_18+0x3ef7>
    50d0:	cmp    $0x2b,%rax
    50d4:	jge    510f <botlish_fn_18+0x3ef7>
    50da:	jmp    5152 <botlish_fn_18+0x3f3a>
    50df:	cmp    $0x27,%rax
    50e3:	jl     5152 <botlish_fn_18+0x3f3a>
    50e9:	mov    $0xb,%esi
    50ee:	mov    %rsi,0x3c8(%rsp)
    50f6:	jmp    515f <botlish_fn_18+0x3f47>
    50fb:	cmp    $0x23,%rax
    50ff:	jl     5133 <botlish_fn_18+0x3f1b>
    5105:	cmp    $0x24,%rax
    5109:	jl     5121 <botlish_fn_18+0x3f09>
    510f:	mov    $0xa,%esi
    5114:	mov    %rsi,0x3c8(%rsp)
    511c:	jmp    515f <botlish_fn_18+0x3f47>
    5121:	mov    $0x9,%esi
    5126:	mov    %rsi,0x3c8(%rsp)
    512e:	jmp    515f <botlish_fn_18+0x3f47>
    5133:	cmp    $0x22,%rax
    5137:	jl     5152 <botlish_fn_18+0x3f3a>
    513d:	mov    0x3f8(%rsp),%rax
    5145:	mov    %rax,0x3c8(%rsp)
    514d:	jmp    515f <botlish_fn_18+0x3f47>
    5152:	mov    $0xc,%esi
    5157:	mov    %rsi,0x3c8(%rsp)
    515f:	mov    0x3c8(%rsp),%rsi
    5167:	mov    %rsi,%rcx
    516a:	shl    $1,%rcx
    516d:	or     $0x1,%rcx
    5171:	mov    $0x2,%eax
    5176:	cmp    $0x9,%rcx
    517a:	cmovl  0x300e(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    5182:	cmp    $0x6,%rax
    5186:	je     5511 <botlish_fn_18+0x42f9>
    518c:	mov    0x3c8(%rsp),%rsi
    5194:	mov    %rsi,%rcx
    5197:	shl    $1,%rcx
    519a:	or     $0x1,%rcx
    519e:	mov    $0x2,%eax
    51a3:	cmp    $0x9,%rcx
    51a7:	cmove  0x2fe1(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    51af:	cmp    $0x6,%rax
    51b3:	je     54f4 <botlish_fn_18+0x42dc>
    51b9:	mov    0x3c8(%rsp),%rsi
    51c1:	mov    %rsi,%rcx
    51c4:	shl    $1,%rcx
    51c7:	or     $0x1,%rcx
    51cb:	mov    $0x2,%eax
    51d0:	cmp    $0xb,%rcx
    51d4:	cmove  0x2fb4(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    51dc:	cmp    $0x6,%rax
    51e0:	je     54e2 <botlish_fn_18+0x42ca>
    51e6:	mov    0x3c8(%rsp),%rsi
    51ee:	mov    %rsi,%rcx
    51f1:	shl    $1,%rcx
    51f4:	or     $0x1,%rcx
    51f8:	mov    $0x2,%eax
    51fd:	cmp    $0xd,%rcx
    5201:	cmove  0x2f87(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    5209:	cmp    $0x6,%rax
    520d:	je     54c5 <botlish_fn_18+0x42ad>
    5213:	mov    0x3c8(%rsp),%rsi
    521b:	mov    %rsi,%rax
    521e:	shl    $1,%rax
    5221:	or     $0x1,%rax
    5225:	mov    $0x2,%esi
    522a:	cmp    $0xf,%rax
    522e:	cmove  0x2f5a(%rip),%rsi        # 8190 <botlish_fn_18+0x6f78>
    5236:	cmp    $0x6,%rsi
    523a:	je     54a8 <botlish_fn_18+0x4290>
    5240:	mov    0x3c8(%rsp),%rsi
    5248:	mov    %rsi,%rcx
    524b:	shl    $1,%rcx
    524e:	or     $0x1,%rcx
    5252:	mov    $0x2,%eax
    5257:	cmp    $0x11,%rcx
    525b:	cmove  0x2f2d(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    5263:	cmp    $0x6,%rax
    5267:	je     5498 <botlish_fn_18+0x4280>
    526d:	mov    0x3c8(%rsp),%rsi
    5275:	mov    %rsi,%rcx
    5278:	shl    $1,%rcx
    527b:	or     $0x1,%rcx
    527f:	mov    $0x2,%eax
    5284:	cmp    $0x13,%rcx
    5288:	cmove  0x2f00(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    5290:	cmp    $0x6,%rax
    5294:	je     5488 <botlish_fn_18+0x4270>
    529a:	mov    0x3c8(%rsp),%rsi
    52a2:	mov    %rsi,%rcx
    52a5:	shl    $1,%rcx
    52a8:	or     $0x1,%rcx
    52ac:	mov    $0x2,%eax
    52b1:	cmp    $0x15,%rcx
    52b5:	cmove  0x2ed3(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    52bd:	cmp    $0x6,%rax
    52c1:	je     5478 <botlish_fn_18+0x4260>
    52c7:	mov    0x3c8(%rsp),%rsi
    52cf:	mov    %rsi,%rcx
    52d2:	shl    $1,%rcx
    52d5:	or     $0x1,%rcx
    52d9:	mov    $0x2,%eax
    52de:	cmp    $0x17,%rcx
    52e2:	cmove  0x2ea6(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    52ea:	cmp    $0x6,%rax
    52ee:	je     5468 <botlish_fn_18+0x4250>
    52f4:	mov    0x378(%rsp),%rdx
    52fc:	test   $0x1,%rdx
    5303:	jne    533b <botlish_fn_18+0x4123>
    5309:	mov    0x3f0(%rsp),%rdx
    5311:	mov    0x378(%rsp),%rsi
    5319:	mov    0x358(%rsp),%rdi
    5321:	call   5326 <botlish_fn_18+0x410e>
			5322: R_X86_64_PLT32	rt_int_cmp-0x4
    5326:	mov    $0x2,%ecx
    532b:	test   %rax,%rax
    532e:	cmove  0x2e5a(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    5336:	jmp    5354 <botlish_fn_18+0x413c>
    533b:	mov    $0x2,%ecx
    5340:	mov    0x378(%rsp),%rdx
    5348:	cmp    $0xffffffffffffffff,%rdx
    534c:	cmove  0x2e3c(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    5354:	cmp    $0x6,%rcx
    5358:	je     53f0 <botlish_fn_18+0x41d8>
    535e:	mov    0x358(%rsp),%rdi
    5366:	mov    0x10(%rdi),%r11
    536a:	mov    0x1b8(%r11),%r12
    5371:	mov    $0x1,%r13d
    5377:	mov    0x3c8(%rsp),%rsi
    537f:	shl    $1,%rsi
    5382:	mov    %rsi,0x3c8(%rsp)
    538a:	or     $0x1,%rsi
    538e:	mov    %rsi,0x3c8(%rsp)
    5396:	call   539b <botlish_fn_18+0x4183>
			5397: R_X86_64_PLT32	botlish_fn_11-0x4
    539b:	mov    0x358(%rsp),%rdi
    53a3:	mov    0x10(%rdi),%r11
    53a7:	mov    0x190(%r11),%rdx
    53ae:	lea    0x340(%rsp),%r9
    53b6:	mov    %r12,0x340(%rsp)
    53be:	mov    %rax,0x348(%rsp)
    53c6:	mov    0x378(%rsp),%rax
    53ce:	mov    %rax,0x350(%rsp)
    53d6:	mov    $0x5,%ecx
    53db:	mov    %r13,%rsi
    53de:	mov    0x3e0(%rsp),%r8
    53e6:	call   53eb <botlish_fn_18+0x41d3>
			53e7: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    53eb:	jmp    7764 <botlish_fn_18+0x654c>
    53f0:	mov    0x358(%rsp),%rdi
    53f8:	mov    0x10(%rdi),%rax
    53fc:	mov    0x1b8(%rax),%r15
    5403:	mov    0x3c8(%rsp),%rsi
    540b:	shl    $1,%rsi
    540e:	mov    %rsi,0x3c8(%rsp)
    5416:	or     $0x1,%rsi
    541a:	mov    %rsi,0x3c8(%rsp)
    5422:	call   5427 <botlish_fn_18+0x420f>
			5423: R_X86_64_PLT32	botlish_fn_11-0x4
    5427:	mov    0x358(%rsp),%rdi
    542f:	mov    0x10(%rdi),%rcx
    5433:	mov    0x188(%rcx),%rdx
    543a:	lea    0x330(%rsp),%r9
    5442:	mov    %r15,0x330(%rsp)
    544a:	mov    %rax,0x338(%rsp)
    5452:	mov    $0x2,%r8d
    5458:	mov    %rbx,%rcx
    545b:	mov    %r8,%rsi
    545e:	call   5463 <botlish_fn_18+0x424b>
			545f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5463:	jmp    7764 <botlish_fn_18+0x654c>
    5468:	xor    %rax,%rax
    546b:	mov    %r12,0x3c8(%rsp)
    5473:	jmp    5596 <botlish_fn_18+0x437e>
    5478:	xor    %rax,%rax
    547b:	mov    %r12,0x3c8(%rsp)
    5483:	jmp    5bc1 <botlish_fn_18+0x49a9>
    5488:	xor    %rax,%rax
    548b:	mov    %r12,0x3c8(%rsp)
    5493:	jmp    6893 <botlish_fn_18+0x567b>
    5498:	xor    %rax,%rax
    549b:	mov    %r12,0x3c8(%rsp)
    54a3:	jmp    6dec <botlish_fn_18+0x5bd4>
    54a8:	mov    $0xfffffffffffffff9,%rdx
    54af:	mov    %rdx,0x378(%rsp)
    54b7:	movq   $0xfffffffffffffff9,0x38(%rsp)
    54c0:	jmp    72a3 <botlish_fn_18+0x608b>
    54c5:	mov    $0xfffffffffffffffb,%rdx
    54cc:	mov    %rdx,0x378(%rsp)
    54d4:	movq   $0xfffffffffffffffb,0x38(%rsp)
    54dd:	jmp    72a3 <botlish_fn_18+0x608b>
    54e2:	mov    0x378(%rsp),%rdx
    54ea:	mov    %rdx,0x38(%rsp)
    54ef:	jmp    72a3 <botlish_fn_18+0x608b>
    54f4:	mov    $0xfffffffffffffffd,%rdx
    54fb:	mov    %rdx,0x378(%rsp)
    5503:	movq   $0xfffffffffffffffd,0x38(%rsp)
    550c:	jmp    72a3 <botlish_fn_18+0x608b>
    5511:	mov    0x3c8(%rsp),%rsi
    5519:	shl    $1,%rsi
    551c:	mov    %rsi,0x3c8(%rsp)
    5524:	or     $0x1,%rsi
    5528:	mov    %rsi,0x3c8(%rsp)
    5530:	mov    %rsi,0x90(%rsp)
    5538:	mov    $0x1,%eax
    553d:	mov    %rax,0x370(%rsp)
    5545:	movq   $0x1,0x80(%rsp)
    5551:	mov    $0x6,%r12d
    5557:	mov    0x3a8(%rsp),%r15
    555f:	jmp    7997 <botlish_fn_18+0x677f>
    5564:	mov    0x358(%rsp),%rdi
    556c:	mov    0x10(%rdi),%rax
    5570:	mov    0x168(%rax),%rsi
    5577:	mov    0x170(%rax),%rdx
    557e:	call   5583 <botlish_fn_18+0x436b>
			557f: R_X86_64_PLT32	rt_raise-0x4
    5583:	jmp    7764 <botlish_fn_18+0x654c>
    5588:	mov    0x3c0(%rsp),%rsi
    5590:	mov    %rsi,%rax
    5593:	sar    $1,%rax
    5596:	shl    $1,%rax
    5599:	or     $0x1,%rax
    559d:	sar    $1,%rax
    55a0:	cmp    $0x3,%rax
    55a4:	jb     55b7 <botlish_fn_18+0x439f>
    55aa:	mov    0x358(%rsp),%rdi
    55b2:	jmp    5b8f <botlish_fn_18+0x4977>
    55b7:	mov    $0x3,%ecx
    55bc:	mov    %eax,%eax
    55be:	cmp    %ecx,%eax
    55c0:	cmovb  %eax,%ecx
    55c3:	lea    0x9(%rip),%rdx        # 55d3 <botlish_fn_18+0x43bb>
    55ca:	movslq (%rdx,%rcx,4),%rax
    55ce:	add    %rax,%rdx
    55d1:	jmp    *%rdx
    55d3:	lret
    55d4:	add    (%rax),%al
    55d6:	add    %ah,0x1(%rdx)
    55d9:	add    %al,(%rax)
    55db:	sbb    $0x10000000,%eax
    55e0:	add    %al,(%rax)
    55e2:	add    %cl,-0x75(%rax)
    55e5:	mov    $0x35824,%esp
    55ea:	add    %ch,%cl
    55ec:	lahf
    55ed:	add    $0x8b480000,%eax
    55f2:	xchg   %eax,%esp
    55f3:	and    $0x78,%al
    55f5:	add    (%rax),%eax
    55f7:	add    %cl,-0x9(%rax)
    55fa:	ret    $0x1
    55fd:	add    %al,(%rax)
    55ff:	jne    5637 <botlish_fn_18+0x441f>
    5605:	mov    0x3f0(%rsp),%rdx
    560d:	mov    0x378(%rsp),%rsi
    5615:	mov    0x358(%rsp),%rdi
    561d:	call   5622 <botlish_fn_18+0x440a>
			561e: R_X86_64_PLT32	rt_int_cmp-0x4
    5622:	mov    $0x2,%ecx
    5627:	test   %rax,%rax
    562a:	cmovl  0x2b5e(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    5632:	jmp    5650 <botlish_fn_18+0x4438>
    5637:	mov    $0x2,%ecx
    563c:	mov    0x378(%rsp),%rdx
    5644:	cmp    $0xffffffffffffffff,%rdx
    5648:	cmovl  0x2b40(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    5650:	cmp    $0x6,%rcx
    5654:	je     572b <botlish_fn_18+0x4513>
    565a:	mov    0x378(%rsp),%rdx
    5662:	test   $0x1,%rdx
    5669:	jne    569e <botlish_fn_18+0x4486>
    566f:	mov    $0x21ffff,%edx
    5674:	mov    0x378(%rsp),%rsi
    567c:	mov    0x358(%rsp),%rdi
    5684:	call   5689 <botlish_fn_18+0x4471>
			5685: R_X86_64_PLT32	rt_int_cmp-0x4
    5689:	mov    $0x2,%ecx
    568e:	test   %rax,%rax
    5691:	cmovg  0x2af7(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    5699:	jmp    56ba <botlish_fn_18+0x44a2>
    569e:	mov    $0x2,%ecx
    56a3:	mov    0x378(%rsp),%rdx
    56ab:	cmp    $0x21ffff,%rdx
    56b2:	cmovg  0x2ad6(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    56ba:	cmp    $0x6,%rcx
    56be:	je     572b <botlish_fn_18+0x4513>
    56c4:	mov    0x378(%rsp),%rdx
    56cc:	mov    %rdx,%rax
    56cf:	sar    $1,%rax
    56d2:	cmp    $0x28,%rax
    56d6:	jl     570a <botlish_fn_18+0x44f2>
    56dc:	cmp    $0xe000,%rax
    56e2:	jl     56f9 <botlish_fn_18+0x44e1>
    56e8:	cmp    $0x110000,%rax
    56ee:	jge    572b <botlish_fn_18+0x4513>
    56f4:	jmp    571e <botlish_fn_18+0x4506>
    56f9:	cmp    $0xd800,%rax
    56ff:	jge    572b <botlish_fn_18+0x4513>
    5705:	jmp    571e <botlish_fn_18+0x4506>
    570a:	cmp    $0xffffffffffffffff,%rax
    570e:	jl     572b <botlish_fn_18+0x4513>
    5714:	cmp    $0x27,%rax
    5718:	jge    598e <botlish_fn_18+0x4776>
    571e:	mov    0x3e0(%rsp),%rsi
    5726:	jmp    599b <botlish_fn_18+0x4783>
    572b:	mov    $0x6,%esi
    5730:	jmp    599b <botlish_fn_18+0x4783>
    5735:	mov    0x378(%rsp),%rdx
    573d:	test   $0x1,%rdx
    5744:	jne    577a <botlish_fn_18+0x4562>
    574a:	mov    $0x13,%edx
    574f:	mov    0x378(%rsp),%rsi
    5757:	mov    0x358(%rsp),%rdi
    575f:	call   5764 <botlish_fn_18+0x454c>
			5760: R_X86_64_PLT32	rt_int_cmp-0x4
    5764:	mov    $0x2,%r11d
    576a:	test   %rax,%rax
    576d:	cmovl  0x2a1b(%rip),%r11        # 8190 <botlish_fn_18+0x6f78>
    5775:	jmp    5794 <botlish_fn_18+0x457c>
    577a:	mov    $0x2,%r11d
    5780:	mov    0x378(%rsp),%rdx
    5788:	cmp    $0x13,%rdx
    578c:	cmovl  0x29fc(%rip),%r11        # 8190 <botlish_fn_18+0x6f78>
    5794:	cmp    $0x6,%r11
    5798:	je     5894 <botlish_fn_18+0x467c>
    579e:	mov    0x378(%rsp),%rdx
    57a6:	test   $0x1,%rdx
    57ad:	jne    57e2 <botlish_fn_18+0x45ca>
    57b3:	mov    $0x21ffff,%edx
    57b8:	mov    0x378(%rsp),%rsi
    57c0:	mov    0x358(%rsp),%rdi
    57c8:	call   57cd <botlish_fn_18+0x45b5>
			57c9: R_X86_64_PLT32	rt_int_cmp-0x4
    57cd:	mov    $0x2,%ecx
    57d2:	test   %rax,%rax
    57d5:	cmovg  0x29b3(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    57dd:	jmp    57fe <botlish_fn_18+0x45e6>
    57e2:	mov    $0x2,%ecx
    57e7:	mov    0x378(%rsp),%rdx
    57ef:	cmp    $0x21ffff,%rdx
    57f6:	cmovg  0x2992(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    57fe:	cmp    $0x6,%rcx
    5802:	je     5894 <botlish_fn_18+0x467c>
    5808:	mov    0x378(%rsp),%rdx
    5810:	mov    %rdx,%rax
    5813:	sar    $1,%rax
    5816:	cmp    $0x20,%rax
    581a:	jl     5867 <botlish_fn_18+0x464f>
    5820:	cmp    $0xd800,%rax
    5826:	jl     5849 <botlish_fn_18+0x4631>
    582c:	cmp    $0xe000,%rax
    5832:	jl     5894 <botlish_fn_18+0x467c>
    5838:	cmp    $0x110000,%rax
    583e:	jge    5894 <botlish_fn_18+0x467c>
    5844:	jmp    598e <botlish_fn_18+0x4776>
    5849:	cmp    $0x27,%rax
    584d:	jl     598e <botlish_fn_18+0x4776>
    5853:	cmp    $0x28,%rax
    5857:	jge    598e <botlish_fn_18+0x4776>
    585d:	mov    $0x2,%esi
    5862:	jmp    599b <botlish_fn_18+0x4783>
    5867:	cmp    $0xb,%rax
    586b:	jl     588a <botlish_fn_18+0x4672>
    5871:	cmp    $0xd,%rax
    5875:	jl     5894 <botlish_fn_18+0x467c>
    587b:	cmp    $0xe,%rax
    587f:	jge    5894 <botlish_fn_18+0x467c>
    5885:	jmp    598e <botlish_fn_18+0x4776>
    588a:	cmp    $0x9,%rax
    588e:	jge    598e <botlish_fn_18+0x4776>
    5894:	mov    $0x5,%esi
    5899:	jmp    599b <botlish_fn_18+0x4783>
    589e:	mov    0x378(%rsp),%rdx
    58a6:	test   $0x1,%rdx
    58ad:	jne    58e2 <botlish_fn_18+0x46ca>
    58b3:	mov    $0x4f,%edx
    58b8:	mov    0x378(%rsp),%rsi
    58c0:	mov    0x358(%rsp),%rdi
    58c8:	call   58cd <botlish_fn_18+0x46b5>
			58c9: R_X86_64_PLT32	rt_int_cmp-0x4
    58cd:	mov    $0x2,%ecx
    58d2:	test   %rax,%rax
    58d5:	cmovl  0x28b3(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    58dd:	jmp    58fb <botlish_fn_18+0x46e3>
    58e2:	mov    $0x2,%ecx
    58e7:	mov    0x378(%rsp),%rdx
    58ef:	cmp    $0x4f,%rdx
    58f3:	cmovl  0x2895(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    58fb:	cmp    $0x6,%rcx
    58ff:	je     5998 <botlish_fn_18+0x4780>
    5905:	mov    0x378(%rsp),%rdx
    590d:	test   $0x1,%rdx
    5914:	jne    5949 <botlish_fn_18+0x4731>
    591a:	mov    $0x4f,%edx
    591f:	mov    0x378(%rsp),%rsi
    5927:	mov    0x358(%rsp),%rdi
    592f:	call   5934 <botlish_fn_18+0x471c>
			5930: R_X86_64_PLT32	rt_int_cmp-0x4
    5934:	mov    $0x2,%ecx
    5939:	test   %rax,%rax
    593c:	cmovg  0x284c(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    5944:	jmp    5962 <botlish_fn_18+0x474a>
    5949:	mov    $0x2,%ecx
    594e:	mov    0x378(%rsp),%rdx
    5956:	cmp    $0x4f,%rdx
    595a:	cmovg  0x282e(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    5962:	cmp    $0x6,%rcx
    5966:	je     5998 <botlish_fn_18+0x4780>
    596c:	mov    0x378(%rsp),%rdx
    5974:	mov    %rdx,%rax
    5977:	sar    $1,%rax
    597a:	cmp    $0x27,%rax
    597e:	jl     5998 <botlish_fn_18+0x4780>
    5984:	cmp    $0x28,%rax
    5988:	jge    5998 <botlish_fn_18+0x4780>
    598e:	mov    $0x1,%esi
    5993:	jmp    599b <botlish_fn_18+0x4783>
    5998:	mov    %rbx,%rsi
    599b:	mov    %rsi,%rcx
    599e:	shl    $1,%rcx
    59a1:	or     $0x1,%rcx
    59a5:	mov    $0x2,%eax
    59aa:	cmp    $0x7,%rcx
    59ae:	cmovl  0x27da(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    59b6:	cmp    $0x6,%rax
    59ba:	je     5b4c <botlish_fn_18+0x4934>
    59c0:	mov    %rsi,%rax
    59c3:	shl    $1,%rax
    59c6:	mov    %rsi,%r15
    59c9:	or     $0x1,%rax
    59cd:	mov    $0x2,%esi
    59d2:	cmp    $0x7,%rax
    59d6:	cmove  0x27b2(%rip),%rsi        # 8190 <botlish_fn_18+0x6f78>
    59de:	cmp    $0x6,%rsi
    59e2:	je     5b32 <botlish_fn_18+0x491a>
    59e8:	mov    0x378(%rsp),%rdx
    59f0:	test   $0x1,%rdx
    59f7:	jne    5a2f <botlish_fn_18+0x4817>
    59fd:	mov    0x3f0(%rsp),%rdx
    5a05:	mov    0x378(%rsp),%rsi
    5a0d:	mov    0x358(%rsp),%rdi
    5a15:	call   5a1a <botlish_fn_18+0x4802>
			5a16: R_X86_64_PLT32	rt_int_cmp-0x4
    5a1a:	mov    $0x2,%ecx
    5a1f:	test   %rax,%rax
    5a22:	cmove  0x2766(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    5a2a:	jmp    5a48 <botlish_fn_18+0x4830>
    5a2f:	mov    $0x2,%ecx
    5a34:	mov    0x378(%rsp),%rdx
    5a3c:	cmp    $0xffffffffffffffff,%rdx
    5a40:	cmove  0x2748(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    5a48:	cmp    $0x6,%rcx
    5a4c:	je     5acf <botlish_fn_18+0x48b7>
    5a52:	mov    0x358(%rsp),%rdi
    5a5a:	mov    0x10(%rdi),%rax
    5a5e:	mov    0x1b0(%rax),%r12
    5a65:	mov    $0x1,%r13d
    5a6b:	mov    %r15,%rsi
    5a6e:	shl    $1,%rsi
    5a71:	or     $0x1,%rsi
    5a75:	call   5a7a <botlish_fn_18+0x4862>
			5a76: R_X86_64_PLT32	botlish_fn_5-0x4
    5a7a:	mov    0x358(%rsp),%rdi
    5a82:	mov    0x10(%rdi),%rcx
    5a86:	mov    0x190(%rcx),%rdx
    5a8d:	lea    0x318(%rsp),%r9
    5a95:	mov    %r12,0x318(%rsp)
    5a9d:	mov    %rax,0x320(%rsp)
    5aa5:	mov    0x378(%rsp),%rax
    5aad:	mov    %rax,0x328(%rsp)
    5ab5:	mov    $0x5,%ecx
    5aba:	mov    %r13,%rsi
    5abd:	mov    0x3e0(%rsp),%r8
    5ac5:	call   5aca <botlish_fn_18+0x48b2>
			5ac6: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5aca:	jmp    7764 <botlish_fn_18+0x654c>
    5acf:	mov    %r15,%rsi
    5ad2:	mov    0x358(%rsp),%rdi
    5ada:	mov    0x10(%rdi),%rax
    5ade:	mov    0x1b0(%rax),%r12
    5ae5:	shl    $1,%rsi
    5ae8:	or     $0x1,%rsi
    5aec:	call   5af1 <botlish_fn_18+0x48d9>
			5aed: R_X86_64_PLT32	botlish_fn_5-0x4
    5af1:	mov    0x358(%rsp),%rdi
    5af9:	mov    0x10(%rdi),%rcx
    5afd:	mov    0x188(%rcx),%rdx
    5b04:	lea    0x308(%rsp),%r9
    5b0c:	mov    %r12,0x308(%rsp)
    5b14:	mov    %rax,0x310(%rsp)
    5b1c:	mov    $0x2,%r8d
    5b22:	mov    %rbx,%rcx
    5b25:	mov    %r8,%rsi
    5b28:	call   5b2d <botlish_fn_18+0x4915>
			5b29: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5b2d:	jmp    7764 <botlish_fn_18+0x654c>
    5b32:	mov    0x378(%rsp),%rdx
    5b3a:	mov    %rdx,0x38(%rsp)
    5b3f:	mov    0x3c8(%rsp),%r12
    5b47:	jmp    72a3 <botlish_fn_18+0x608b>
    5b4c:	shl    $1,%rsi
    5b4f:	or     $0x1,%rsi
    5b53:	mov    %rsi,0xb8(%rsp)
    5b5b:	mov    $0x1,%eax
    5b60:	mov    %rax,0x370(%rsp)
    5b68:	movq   $0x1,0x80(%rsp)
    5b74:	mov    $0x5,%r12d
    5b7a:	mov    0x3a8(%rsp),%r15
    5b82:	mov    %rsi,0x3c0(%rsp)
    5b8a:	jmp    7997 <botlish_fn_18+0x677f>
    5b8f:	mov    0x358(%rsp),%rdi
    5b97:	mov    0x10(%rdi),%rcx
    5b9b:	mov    0x168(%rcx),%rsi
    5ba2:	mov    0x170(%rcx),%rdx
    5ba9:	call   5bae <botlish_fn_18+0x4996>
			5baa: R_X86_64_PLT32	rt_raise-0x4
    5bae:	jmp    7764 <botlish_fn_18+0x654c>
    5bb3:	mov    0x3b8(%rsp),%rsi
    5bbb:	mov    %rsi,%rax
    5bbe:	sar    $1,%rax
    5bc1:	shl    $1,%rax
    5bc4:	or     $0x1,%rax
    5bc8:	sar    $1,%rax
    5bcb:	cmp    $0x4,%rax
    5bcf:	jb     5be2 <botlish_fn_18+0x49ca>
    5bd5:	mov    0x358(%rsp),%rdi
    5bdd:	jmp    6861 <botlish_fn_18+0x5649>
    5be2:	mov    $0x4,%esi
    5be7:	mov    %eax,%edi
    5be9:	cmp    %esi,%edi
    5beb:	cmovb  %edi,%esi
    5bee:	lea    0xa(%rip),%r9        # 5bff <botlish_fn_18+0x49e7>
    5bf5:	movslq (%r9,%rsi,4),%r10
    5bf9:	add    %r10,%r9
    5bfc:	jmp    *%r9
    5bff:	pop    %rdx
    5c00:	(bad)
    5c01:	add    %al,(%rax)
    5c03:	movl   $0x2b000,(%rax,%rax,1)
    5c0a:	add    %ah,(%rcx)
    5c0c:	add    %al,(%rax)
    5c0e:	add    %dl,(%rax,%rax,1)
    5c11:	add    %al,(%rax)
    5c13:	mov    0x358(%rsp),%rdi
    5c1b:	jmp    6861 <botlish_fn_18+0x5649>
    5c20:	mov    0x378(%rsp),%rdx
    5c28:	test   $0x1,%rdx
    5c2f:	jne    5c67 <botlish_fn_18+0x4a4f>
    5c35:	mov    0x3f0(%rsp),%rdx
    5c3d:	mov    0x378(%rsp),%rsi
    5c45:	mov    0x358(%rsp),%rdi
    5c4d:	call   5c52 <botlish_fn_18+0x4a3a>
			5c4e: R_X86_64_PLT32	rt_int_cmp-0x4
    5c52:	mov    $0x2,%ecx
    5c57:	test   %rax,%rax
    5c5a:	cmovl  0x252e(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    5c62:	jmp    5c80 <botlish_fn_18+0x4a68>
    5c67:	mov    $0x2,%ecx
    5c6c:	mov    0x378(%rsp),%rdx
    5c74:	cmp    $0xffffffffffffffff,%rdx
    5c78:	cmovl  0x2510(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    5c80:	cmp    $0x6,%rcx
    5c84:	je     5ea5 <botlish_fn_18+0x4c8d>
    5c8a:	mov    0x378(%rsp),%rdx
    5c92:	test   $0x1,%rdx
    5c99:	jne    5cce <botlish_fn_18+0x4ab6>
    5c9f:	mov    $0x21ffff,%edx
    5ca4:	mov    0x378(%rsp),%rsi
    5cac:	mov    0x358(%rsp),%rdi
    5cb4:	call   5cb9 <botlish_fn_18+0x4aa1>
			5cb5: R_X86_64_PLT32	rt_int_cmp-0x4
    5cb9:	mov    $0x2,%edi
    5cbe:	test   %rax,%rax
    5cc1:	cmovg  0x24c7(%rip),%rdi        # 8190 <botlish_fn_18+0x6f78>
    5cc9:	jmp    5cea <botlish_fn_18+0x4ad2>
    5cce:	mov    $0x2,%edi
    5cd3:	mov    0x378(%rsp),%rdx
    5cdb:	cmp    $0x21ffff,%rdx
    5ce2:	cmovg  0x24a6(%rip),%rdi        # 8190 <botlish_fn_18+0x6f78>
    5cea:	cmp    $0x6,%rdi
    5cee:	je     5ea5 <botlish_fn_18+0x4c8d>
    5cf4:	mov    0x378(%rsp),%rdx
    5cfc:	mov    %rdx,%rax
    5cff:	sar    $1,%rax
    5d02:	cmp    $0x5e,%rax
    5d06:	jl     5dde <botlish_fn_18+0x4bc6>
    5d0c:	cmp    $0xa0,%rax
    5d12:	jl     5d80 <botlish_fn_18+0x4b68>
    5d18:	cmp    $0xff00,%rax
    5d1e:	jl     5d52 <botlish_fn_18+0x4b3a>
    5d24:	cmp    $0x10000,%rax
    5d2a:	jl     5d41 <botlish_fn_18+0x4b29>
    5d30:	cmp    $0x110000,%rax
    5d36:	jge    5ea5 <botlish_fn_18+0x4c8d>
    5d3c:	jmp    65e6 <botlish_fn_18+0x53ce>
    5d41:	cmp    $0xfffe,%rax
    5d47:	jge    5ea5 <botlish_fn_18+0x4c8d>
    5d4d:	jmp    65e6 <botlish_fn_18+0x53ce>
    5d52:	cmp    $0xe000,%rax
    5d58:	jl     5d6f <botlish_fn_18+0x4b57>
    5d5e:	cmp    $0xfeff,%rax
    5d64:	jge    5ea5 <botlish_fn_18+0x4c8d>
    5d6a:	jmp    65e6 <botlish_fn_18+0x53ce>
    5d6f:	cmp    $0xd800,%rax
    5d75:	jge    5ea5 <botlish_fn_18+0x4c8d>
    5d7b:	jmp    65e6 <botlish_fn_18+0x53ce>
    5d80:	cmp    $0x7e,%rax
    5d84:	jl     5db6 <botlish_fn_18+0x4b9e>
    5d8a:	cmp    $0x85,%rax
    5d90:	jl     5da7 <botlish_fn_18+0x4b8f>
    5d96:	cmp    $0x86,%rax
    5d9c:	jge    5ea5 <botlish_fn_18+0x4c8d>
    5da2:	jmp    65e6 <botlish_fn_18+0x53ce>
    5da7:	cmp    $0x7f,%rax
    5dab:	jge    5ea5 <botlish_fn_18+0x4c8d>
    5db1:	jmp    65e6 <botlish_fn_18+0x53ce>
    5db6:	cmp    $0x7c,%rax
    5dba:	jl     5dcf <botlish_fn_18+0x4bb7>
    5dc0:	cmp    $0x7d,%rax
    5dc4:	jge    5e87 <botlish_fn_18+0x4c6f>
    5dca:	jmp    65e6 <botlish_fn_18+0x53ce>
    5dcf:	cmp    $0x7b,%rax
    5dd3:	jge    5e87 <botlish_fn_18+0x4c6f>
    5dd9:	jmp    65e6 <botlish_fn_18+0x53ce>
    5dde:	cmp    $0x21,%rax
    5de2:	jl     5e42 <botlish_fn_18+0x4c2a>
    5de8:	cmp    $0x3b,%rax
    5dec:	jl     5e1a <botlish_fn_18+0x4c02>
    5df2:	cmp    $0x5c,%rax
    5df6:	jl     5e0b <botlish_fn_18+0x4bf3>
    5dfc:	cmp    $0x5d,%rax
    5e00:	jge    5e87 <botlish_fn_18+0x4c6f>
    5e06:	jmp    65e6 <botlish_fn_18+0x53ce>
    5e0b:	cmp    $0x5b,%rax
    5e0f:	jge    5e87 <botlish_fn_18+0x4c6f>
    5e15:	jmp    65e6 <botlish_fn_18+0x53ce>
    5e1a:	cmp    $0x2d,%rax
    5e1e:	jl     5e33 <botlish_fn_18+0x4c1b>
    5e24:	cmp    $0x3a,%rax
    5e28:	jge    62d4 <botlish_fn_18+0x50bc>
    5e2e:	jmp    65e6 <botlish_fn_18+0x53ce>
    5e33:	cmp    $0x2c,%rax
    5e37:	jge    5e87 <botlish_fn_18+0x4c6f>
    5e3d:	jmp    65e6 <botlish_fn_18+0x53ce>
    5e42:	cmp    $0xb,%rax
    5e46:	jl     5e74 <botlish_fn_18+0x4c5c>
    5e4c:	cmp    $0xe,%rax
    5e50:	jl     5e65 <botlish_fn_18+0x4c4d>
    5e56:	cmp    $0x20,%rax
    5e5a:	jge    5e87 <botlish_fn_18+0x4c6f>
    5e60:	jmp    5ea5 <botlish_fn_18+0x4c8d>
    5e65:	cmp    $0xd,%rax
    5e69:	jge    5e87 <botlish_fn_18+0x4c6f>
    5e6f:	jmp    5ea5 <botlish_fn_18+0x4c8d>
    5e74:	test   %rax,%rax
    5e77:	jl     5e91 <botlish_fn_18+0x4c79>
    5e7d:	cmp    $0x9,%rax
    5e81:	jl     5ea5 <botlish_fn_18+0x4c8d>
    5e87:	mov    $0x6,%esi
    5e8c:	jmp    65f5 <botlish_fn_18+0x53dd>
    5e91:	cmp    $0xffffffffffffffff,%rax
    5e95:	jl     5ea5 <botlish_fn_18+0x4c8d>
    5e9b:	mov    $0x5,%esi
    5ea0:	jmp    65f5 <botlish_fn_18+0x53dd>
    5ea5:	mov    $0xa,%esi
    5eaa:	jmp    65f5 <botlish_fn_18+0x53dd>
    5eaf:	mov    0x378(%rsp),%rdx
    5eb7:	test   $0x1,%rdx
    5ebe:	jne    5ef3 <botlish_fn_18+0x4cdb>
    5ec4:	mov    $0x43,%edx
    5ec9:	mov    0x378(%rsp),%rsi
    5ed1:	mov    0x358(%rsp),%rdi
    5ed9:	call   5ede <botlish_fn_18+0x4cc6>
			5eda: R_X86_64_PLT32	rt_int_cmp-0x4
    5ede:	mov    $0x2,%ecx
    5ee3:	test   %rax,%rax
    5ee6:	cmovl  0x22a2(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    5eee:	jmp    5f0c <botlish_fn_18+0x4cf4>
    5ef3:	mov    $0x2,%ecx
    5ef8:	mov    0x378(%rsp),%rdx
    5f00:	cmp    $0x43,%rdx
    5f04:	cmovl  0x2284(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    5f0c:	cmp    $0x6,%rcx
    5f10:	je     60bc <botlish_fn_18+0x4ea4>
    5f16:	mov    0x378(%rsp),%rdx
    5f1e:	test   $0x1,%rdx
    5f25:	jne    5f5b <botlish_fn_18+0x4d43>
    5f2b:	mov    $0x21ffff,%edx
    5f30:	mov    0x378(%rsp),%rsi
    5f38:	mov    0x358(%rsp),%rdi
    5f40:	call   5f45 <botlish_fn_18+0x4d2d>
			5f41: R_X86_64_PLT32	rt_int_cmp-0x4
    5f45:	mov    $0x2,%r10d
    5f4b:	test   %rax,%rax
    5f4e:	cmovg  0x223a(%rip),%r10        # 8190 <botlish_fn_18+0x6f78>
    5f56:	jmp    5f78 <botlish_fn_18+0x4d60>
    5f5b:	mov    $0x2,%r10d
    5f61:	mov    0x378(%rsp),%rdx
    5f69:	cmp    $0x21ffff,%rdx
    5f70:	cmovg  0x2218(%rip),%r10        # 8190 <botlish_fn_18+0x6f78>
    5f78:	cmp    $0x6,%r10
    5f7c:	je     60bc <botlish_fn_18+0x4ea4>
    5f82:	mov    0x378(%rsp),%rdx
    5f8a:	mov    %rdx,%rax
    5f8d:	sar    $1,%rax
    5f90:	cmp    $0x7d,%rax
    5f94:	jl     603f <botlish_fn_18+0x4e27>
    5f9a:	cmp    $0xd800,%rax
    5fa0:	jl     5ffd <botlish_fn_18+0x4de5>
    5fa6:	cmp    $0xff00,%rax
    5fac:	jl     5fe0 <botlish_fn_18+0x4dc8>
    5fb2:	cmp    $0x10000,%rax
    5fb8:	jl     5fcf <botlish_fn_18+0x4db7>
    5fbe:	cmp    $0x110000,%rax
    5fc4:	jge    60bc <botlish_fn_18+0x4ea4>
    5fca:	jmp    65e6 <botlish_fn_18+0x53ce>
    5fcf:	cmp    $0xfffe,%rax
    5fd5:	jge    60bc <botlish_fn_18+0x4ea4>
    5fdb:	jmp    65e6 <botlish_fn_18+0x53ce>
    5fe0:	cmp    $0xe000,%rax
    5fe6:	jl     60bc <botlish_fn_18+0x4ea4>
    5fec:	cmp    $0xfeff,%rax
    5ff2:	jge    60bc <botlish_fn_18+0x4ea4>
    5ff8:	jmp    65e6 <botlish_fn_18+0x53ce>
    5ffd:	cmp    $0x85,%rax
    6003:	jl     6026 <botlish_fn_18+0x4e0e>
    6009:	cmp    $0x86,%rax
    600f:	jl     65e6 <botlish_fn_18+0x53ce>
    6015:	cmp    $0xa0,%rax
    601b:	jge    65e6 <botlish_fn_18+0x53ce>
    6021:	jmp    60bc <botlish_fn_18+0x4ea4>
    6026:	cmp    $0x7e,%rax
    602a:	jl     60bc <botlish_fn_18+0x4ea4>
    6030:	cmp    $0x7f,%rax
    6034:	jge    60bc <botlish_fn_18+0x4ea4>
    603a:	jmp    65e6 <botlish_fn_18+0x53ce>
    603f:	cmp    $0x5b,%rax
    6043:	jl     6085 <botlish_fn_18+0x4e6d>
    6049:	cmp    $0x5e,%rax
    604d:	jl     606c <botlish_fn_18+0x4e54>
    6053:	cmp    $0x7b,%rax
    6057:	jl     65e6 <botlish_fn_18+0x53ce>
    605d:	cmp    $0x7c,%rax
    6061:	jge    65e6 <botlish_fn_18+0x53ce>
    6067:	jmp    60bc <botlish_fn_18+0x4ea4>
    606c:	cmp    $0x5c,%rax
    6070:	jl     60bc <botlish_fn_18+0x4ea4>
    6076:	cmp    $0x5d,%rax
    607a:	jge    60bc <botlish_fn_18+0x4ea4>
    6080:	jmp    65e6 <botlish_fn_18+0x53ce>
    6085:	cmp    $0x2d,%rax
    6089:	jl     60a8 <botlish_fn_18+0x4e90>
    608f:	cmp    $0x3a,%rax
    6093:	jl     65e6 <botlish_fn_18+0x53ce>
    6099:	cmp    $0x3b,%rax
    609d:	jge    65e6 <botlish_fn_18+0x53ce>
    60a3:	jmp    62d4 <botlish_fn_18+0x50bc>
    60a8:	cmp    $0x21,%rax
    60ac:	jl     60bc <botlish_fn_18+0x4ea4>
    60b2:	cmp    $0x2c,%rax
    60b6:	jl     65e6 <botlish_fn_18+0x53ce>
    60bc:	mov    $0x9,%esi
    60c1:	jmp    65f5 <botlish_fn_18+0x53dd>
    60c6:	mov    0x378(%rsp),%rdx
    60ce:	test   $0x1,%rdx
    60d5:	jne    610d <botlish_fn_18+0x4ef5>
    60db:	mov    0x3f0(%rsp),%rdx
    60e3:	mov    0x378(%rsp),%rsi
    60eb:	mov    0x358(%rsp),%rdi
    60f3:	call   60f8 <botlish_fn_18+0x4ee0>
			60f4: R_X86_64_PLT32	rt_int_cmp-0x4
    60f8:	mov    $0x2,%ecx
    60fd:	test   %rax,%rax
    6100:	cmovl  0x2088(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6108:	jmp    6126 <botlish_fn_18+0x4f0e>
    610d:	mov    $0x2,%ecx
    6112:	mov    0x378(%rsp),%rdx
    611a:	cmp    $0xffffffffffffffff,%rdx
    611e:	cmovl  0x206a(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6126:	cmp    $0x6,%rcx
    612a:	je     634c <botlish_fn_18+0x5134>
    6130:	mov    0x378(%rsp),%rdx
    6138:	test   $0x1,%rdx
    613f:	jne    6174 <botlish_fn_18+0x4f5c>
    6145:	mov    $0x21ffff,%edx
    614a:	mov    0x378(%rsp),%rsi
    6152:	mov    0x358(%rsp),%rdi
    615a:	call   615f <botlish_fn_18+0x4f47>
			615b: R_X86_64_PLT32	rt_int_cmp-0x4
    615f:	mov    $0x2,%ecx
    6164:	test   %rax,%rax
    6167:	cmovg  0x2021(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    616f:	jmp    6190 <botlish_fn_18+0x4f78>
    6174:	mov    $0x2,%ecx
    6179:	mov    0x378(%rsp),%rdx
    6181:	cmp    $0x21ffff,%rdx
    6188:	cmovg  0x2000(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6190:	cmp    $0x6,%rcx
    6194:	je     634c <botlish_fn_18+0x5134>
    619a:	mov    0x378(%rsp),%rdx
    61a2:	mov    %rdx,%rax
    61a5:	sar    $1,%rax
    61a8:	cmp    $0x5e,%rax
    61ac:	jl     6284 <botlish_fn_18+0x506c>
    61b2:	cmp    $0xa0,%rax
    61b8:	jl     6226 <botlish_fn_18+0x500e>
    61be:	cmp    $0xff00,%rax
    61c4:	jl     61f8 <botlish_fn_18+0x4fe0>
    61ca:	cmp    $0x10000,%rax
    61d0:	jl     61e7 <botlish_fn_18+0x4fcf>
    61d6:	cmp    $0x110000,%rax
    61dc:	jge    634c <botlish_fn_18+0x5134>
    61e2:	jmp    65e6 <botlish_fn_18+0x53ce>
    61e7:	cmp    $0xfffe,%rax
    61ed:	jge    634c <botlish_fn_18+0x5134>
    61f3:	jmp    65e6 <botlish_fn_18+0x53ce>
    61f8:	cmp    $0xe000,%rax
    61fe:	jl     6215 <botlish_fn_18+0x4ffd>
    6204:	cmp    $0xfeff,%rax
    620a:	jge    634c <botlish_fn_18+0x5134>
    6210:	jmp    65e6 <botlish_fn_18+0x53ce>
    6215:	cmp    $0xd800,%rax
    621b:	jge    634c <botlish_fn_18+0x5134>
    6221:	jmp    65e6 <botlish_fn_18+0x53ce>
    6226:	cmp    $0x7e,%rax
    622a:	jl     625c <botlish_fn_18+0x5044>
    6230:	cmp    $0x85,%rax
    6236:	jl     624d <botlish_fn_18+0x5035>
    623c:	cmp    $0x86,%rax
    6242:	jge    634c <botlish_fn_18+0x5134>
    6248:	jmp    65e6 <botlish_fn_18+0x53ce>
    624d:	cmp    $0x7f,%rax
    6251:	jge    634c <botlish_fn_18+0x5134>
    6257:	jmp    65e6 <botlish_fn_18+0x53ce>
    625c:	cmp    $0x7c,%rax
    6260:	jl     6275 <botlish_fn_18+0x505d>
    6266:	cmp    $0x7d,%rax
    626a:	jge    6344 <botlish_fn_18+0x512c>
    6270:	jmp    65e6 <botlish_fn_18+0x53ce>
    6275:	cmp    $0x7b,%rax
    6279:	jge    6344 <botlish_fn_18+0x512c>
    627f:	jmp    65e6 <botlish_fn_18+0x53ce>
    6284:	cmp    $0x21,%rax
    6288:	jl     62f0 <botlish_fn_18+0x50d8>
    628e:	cmp    $0x3b,%rax
    6292:	jl     62c0 <botlish_fn_18+0x50a8>
    6298:	cmp    $0x5c,%rax
    629c:	jl     62b1 <botlish_fn_18+0x5099>
    62a2:	cmp    $0x5d,%rax
    62a6:	jge    6344 <botlish_fn_18+0x512c>
    62ac:	jmp    65e6 <botlish_fn_18+0x53ce>
    62b1:	cmp    $0x5b,%rax
    62b5:	jge    6344 <botlish_fn_18+0x512c>
    62bb:	jmp    65e6 <botlish_fn_18+0x53ce>
    62c0:	cmp    $0x2d,%rax
    62c4:	jl     62e1 <botlish_fn_18+0x50c9>
    62ca:	cmp    $0x3a,%rax
    62ce:	jl     65e6 <botlish_fn_18+0x53ce>
    62d4:	mov    0x3e0(%rsp),%rsi
    62dc:	jmp    65f5 <botlish_fn_18+0x53dd>
    62e1:	cmp    $0x2c,%rax
    62e5:	jge    6344 <botlish_fn_18+0x512c>
    62eb:	jmp    65e6 <botlish_fn_18+0x53ce>
    62f0:	cmp    $0xb,%rax
    62f4:	jl     6322 <botlish_fn_18+0x510a>
    62fa:	cmp    $0xe,%rax
    62fe:	jl     6313 <botlish_fn_18+0x50fb>
    6304:	cmp    $0x20,%rax
    6308:	jge    6344 <botlish_fn_18+0x512c>
    630e:	jmp    634c <botlish_fn_18+0x5134>
    6313:	cmp    $0xd,%rax
    6317:	jge    6344 <botlish_fn_18+0x512c>
    631d:	jmp    634c <botlish_fn_18+0x5134>
    6322:	test   %rax,%rax
    6325:	jl     633a <botlish_fn_18+0x5122>
    632b:	cmp    $0x9,%rax
    632f:	jge    6344 <botlish_fn_18+0x512c>
    6335:	jmp    634c <botlish_fn_18+0x5134>
    633a:	cmp    $0xffffffffffffffff,%rax
    633e:	jl     634c <botlish_fn_18+0x5134>
    6344:	mov    %rbx,%rsi
    6347:	jmp    65f5 <botlish_fn_18+0x53dd>
    634c:	mov    0x3f8(%rsp),%rsi
    6354:	jmp    65f5 <botlish_fn_18+0x53dd>
    6359:	mov    0x378(%rsp),%rdx
    6361:	test   $0x1,%rdx
    6368:	jne    639d <botlish_fn_18+0x5185>
    636e:	mov    $0x49,%edx
    6373:	mov    0x378(%rsp),%rsi
    637b:	mov    0x358(%rsp),%rdi
    6383:	call   6388 <botlish_fn_18+0x5170>
			6384: R_X86_64_PLT32	rt_int_cmp-0x4
    6388:	mov    $0x2,%ecx
    638d:	test   %rax,%rax
    6390:	cmovl  0x1df8(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6398:	jmp    63b6 <botlish_fn_18+0x519e>
    639d:	mov    $0x2,%ecx
    63a2:	mov    0x378(%rsp),%rdx
    63aa:	cmp    $0x49,%rdx
    63ae:	cmovl  0x1dda(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    63b6:	cmp    $0x6,%rcx
    63ba:	je     65f0 <botlish_fn_18+0x53d8>
    63c0:	mov    0x378(%rsp),%rdx
    63c8:	test   $0x1,%rdx
    63cf:	jne    6404 <botlish_fn_18+0x51ec>
    63d5:	mov    $0x21ffff,%edx
    63da:	mov    0x378(%rsp),%rsi
    63e2:	mov    0x358(%rsp),%rdi
    63ea:	call   63ef <botlish_fn_18+0x51d7>
			63eb: R_X86_64_PLT32	rt_int_cmp-0x4
    63ef:	mov    $0x2,%ecx
    63f4:	test   %rax,%rax
    63f7:	cmovg  0x1d91(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    63ff:	jmp    6420 <botlish_fn_18+0x5208>
    6404:	mov    $0x2,%ecx
    6409:	mov    0x378(%rsp),%rdx
    6411:	cmp    $0x21ffff,%rdx
    6418:	cmovg  0x1d70(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6420:	cmp    $0x6,%rcx
    6424:	je     65f0 <botlish_fn_18+0x53d8>
    642a:	mov    0x378(%rsp),%rdx
    6432:	mov    %rdx,%rax
    6435:	sar    $1,%rax
    6438:	cmp    $0x5d,%rax
    643c:	jl     651e <botlish_fn_18+0x5306>
    6442:	cmp    $0x86,%rax
    6448:	jl     64c2 <botlish_fn_18+0x52aa>
    644e:	cmp    $0xfeff,%rax
    6454:	jl     6494 <botlish_fn_18+0x527c>
    645a:	cmp    $0xfffe,%rax
    6460:	jl     6483 <botlish_fn_18+0x526b>
    6466:	cmp    $0x10000,%rax
    646c:	jl     65f0 <botlish_fn_18+0x53d8>
    6472:	cmp    $0x110000,%rax
    6478:	jge    65f0 <botlish_fn_18+0x53d8>
    647e:	jmp    65e6 <botlish_fn_18+0x53ce>
    6483:	cmp    $0xff00,%rax
    6489:	jge    65e6 <botlish_fn_18+0x53ce>
    648f:	jmp    65f0 <botlish_fn_18+0x53d8>
    6494:	cmp    $0xd800,%rax
    649a:	jl     64b1 <botlish_fn_18+0x5299>
    64a0:	cmp    $0xe000,%rax
    64a6:	jge    65e6 <botlish_fn_18+0x53ce>
    64ac:	jmp    65f0 <botlish_fn_18+0x53d8>
    64b1:	cmp    $0xa0,%rax
    64b7:	jge    65e6 <botlish_fn_18+0x53ce>
    64bd:	jmp    65f0 <botlish_fn_18+0x53d8>
    64c2:	cmp    $0x7b,%rax
    64c6:	jl     64f6 <botlish_fn_18+0x52de>
    64cc:	cmp    $0x7f,%rax
    64d0:	jl     64e7 <botlish_fn_18+0x52cf>
    64d6:	cmp    $0x85,%rax
    64dc:	jge    65e6 <botlish_fn_18+0x53ce>
    64e2:	jmp    65f0 <botlish_fn_18+0x53d8>
    64e7:	cmp    $0x7e,%rax
    64eb:	jge    65e6 <botlish_fn_18+0x53ce>
    64f1:	jmp    65f0 <botlish_fn_18+0x53d8>
    64f6:	cmp    $0x60,%rax
    64fa:	jl     650f <botlish_fn_18+0x52f7>
    6500:	cmp    $0x61,%rax
    6504:	jge    65e6 <botlish_fn_18+0x53ce>
    650a:	jmp    65f0 <botlish_fn_18+0x53d8>
    650f:	cmp    $0x5e,%rax
    6513:	jge    65e6 <botlish_fn_18+0x53ce>
    6519:	jmp    65f0 <botlish_fn_18+0x53d8>
    651e:	cmp    $0x2e,%rax
    6522:	jl     658c <botlish_fn_18+0x5374>
    6528:	cmp    $0x3f,%rax
    652c:	jl     6564 <botlish_fn_18+0x534c>
    6532:	cmp    $0x41,%rax
    6536:	jl     6555 <botlish_fn_18+0x533d>
    653c:	cmp    $0x5b,%rax
    6540:	jl     65e6 <botlish_fn_18+0x53ce>
    6546:	cmp    $0x5c,%rax
    654a:	jge    65e6 <botlish_fn_18+0x53ce>
    6550:	jmp    65f0 <botlish_fn_18+0x53d8>
    6555:	cmp    $0x40,%rax
    6559:	jge    65f0 <botlish_fn_18+0x53d8>
    655f:	jmp    65aa <botlish_fn_18+0x5392>
    6564:	cmp    $0x3b,%rax
    6568:	jl     657d <botlish_fn_18+0x5365>
    656e:	cmp    $0x3e,%rax
    6572:	jge    65f0 <botlish_fn_18+0x53d8>
    6578:	jmp    65e6 <botlish_fn_18+0x53ce>
    657d:	cmp    $0x3a,%rax
    6581:	jge    65aa <botlish_fn_18+0x5392>
    6587:	jmp    65e6 <botlish_fn_18+0x53ce>
    658c:	cmp    $0x2a,%rax
    6590:	jl     65c3 <botlish_fn_18+0x53ab>
    6596:	cmp    $0x2c,%rax
    659a:	jl     65b4 <botlish_fn_18+0x539c>
    65a0:	cmp    $0x2d,%rax
    65a4:	jl     65f0 <botlish_fn_18+0x53d8>
    65aa:	mov    $0x2,%esi
    65af:	jmp    65f5 <botlish_fn_18+0x53dd>
    65b4:	cmp    $0x2b,%rax
    65b8:	jge    65e6 <botlish_fn_18+0x53ce>
    65be:	jmp    65f0 <botlish_fn_18+0x53d8>
    65c3:	cmp    $0x25,%rax
    65c7:	jl     65dc <botlish_fn_18+0x53c4>
    65cd:	cmp    $0x28,%rax
    65d1:	jge    65e6 <botlish_fn_18+0x53ce>
    65d7:	jmp    65f0 <botlish_fn_18+0x53d8>
    65dc:	cmp    $0x24,%rax
    65e0:	jl     65f0 <botlish_fn_18+0x53d8>
    65e6:	mov    $0x1,%esi
    65eb:	jmp    65f5 <botlish_fn_18+0x53dd>
    65f0:	mov    $0x7,%esi
    65f5:	mov    %rsi,%r9
    65f8:	shl    $1,%r9
    65fb:	or     $0x1,%r9
    65ff:	mov    $0x2,%eax
    6604:	cmp    $0x9,%r9
    6608:	cmovl  0x1b80(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    6610:	cmp    $0x6,%rax
    6614:	je     6821 <botlish_fn_18+0x5609>
    661a:	mov    %rsi,%rcx
    661d:	shl    $1,%rcx
    6620:	or     $0x1,%rcx
    6624:	mov    $0x2,%eax
    6629:	cmp    $0x9,%rcx
    662d:	cmove  0x1b5b(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    6635:	cmp    $0x6,%rax
    6639:	je     67ff <botlish_fn_18+0x55e7>
    663f:	mov    %rsi,%rax
    6642:	shl    $1,%rax
    6645:	or     $0x1,%rax
    6649:	mov    $0x2,%r10d
    664f:	cmp    $0xb,%rax
    6653:	cmove  0x1b35(%rip),%r10        # 8190 <botlish_fn_18+0x6f78>
    665b:	cmp    $0x6,%r10
    665f:	je     67eb <botlish_fn_18+0x55d3>
    6665:	mov    %rsi,%rcx
    6668:	shl    $1,%rcx
    666b:	mov    %rsi,%r15
    666e:	or     $0x1,%rcx
    6672:	mov    $0x2,%eax
    6677:	cmp    $0xd,%rcx
    667b:	cmove  0x1b0d(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    6683:	cmp    $0x6,%rax
    6687:	je     67d7 <botlish_fn_18+0x55bf>
    668d:	mov    0x378(%rsp),%rdx
    6695:	test   $0x1,%rdx
    669c:	jne    66d4 <botlish_fn_18+0x54bc>
    66a2:	mov    0x3f0(%rsp),%rdx
    66aa:	mov    0x378(%rsp),%rsi
    66b2:	mov    0x358(%rsp),%rdi
    66ba:	call   66bf <botlish_fn_18+0x54a7>
			66bb: R_X86_64_PLT32	rt_int_cmp-0x4
    66bf:	mov    $0x2,%ecx
    66c4:	test   %rax,%rax
    66c7:	cmove  0x1ac1(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    66cf:	jmp    66ed <botlish_fn_18+0x54d5>
    66d4:	mov    $0x2,%ecx
    66d9:	mov    0x378(%rsp),%rdx
    66e1:	cmp    $0xffffffffffffffff,%rdx
    66e5:	cmove  0x1aa3(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    66ed:	cmp    $0x6,%rcx
    66f1:	je     6774 <botlish_fn_18+0x555c>
    66f7:	mov    0x358(%rsp),%rdi
    66ff:	mov    0x10(%rdi),%rax
    6703:	mov    0x1a8(%rax),%r12
    670a:	mov    $0x1,%r13d
    6710:	mov    %r15,%rsi
    6713:	shl    $1,%rsi
    6716:	or     $0x1,%rsi
    671a:	call   671f <botlish_fn_18+0x5507>
			671b: R_X86_64_PLT32	botlish_fn_9-0x4
    671f:	mov    0x358(%rsp),%rdi
    6727:	mov    0x10(%rdi),%rcx
    672b:	mov    0x190(%rcx),%rdx
    6732:	lea    0x2f0(%rsp),%r9
    673a:	mov    %r12,0x2f0(%rsp)
    6742:	mov    %rax,0x2f8(%rsp)
    674a:	mov    0x378(%rsp),%rax
    6752:	mov    %rax,0x300(%rsp)
    675a:	mov    $0x5,%ecx
    675f:	mov    %r13,%rsi
    6762:	mov    0x3e0(%rsp),%r8
    676a:	call   676f <botlish_fn_18+0x5557>
			676b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    676f:	jmp    7764 <botlish_fn_18+0x654c>
    6774:	mov    %r15,%rsi
    6777:	mov    0x358(%rsp),%rdi
    677f:	mov    0x10(%rdi),%rax
    6783:	mov    0x1a8(%rax),%r12
    678a:	shl    $1,%rsi
    678d:	or     $0x1,%rsi
    6791:	call   6796 <botlish_fn_18+0x557e>
			6792: R_X86_64_PLT32	botlish_fn_9-0x4
    6796:	mov    0x358(%rsp),%rdi
    679e:	mov    0x10(%rdi),%rcx
    67a2:	mov    0x188(%rcx),%rdx
    67a9:	lea    0x2e0(%rsp),%r9
    67b1:	mov    %r12,0x2e0(%rsp)
    67b9:	mov    %rax,0x2e8(%rsp)
    67c1:	mov    $0x2,%r8d
    67c7:	mov    %rbx,%rcx
    67ca:	mov    %r8,%rsi
    67cd:	call   67d2 <botlish_fn_18+0x55ba>
			67ce: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    67d2:	jmp    7764 <botlish_fn_18+0x654c>
    67d7:	mov    $0xfffffffffffffff9,%rdx
    67de:	mov    %rdx,0x378(%rsp)
    67e6:	jmp    6807 <botlish_fn_18+0x55ef>
    67eb:	mov    $0xfffffffffffffffb,%rdx
    67f2:	mov    %rdx,0x378(%rsp)
    67fa:	jmp    6807 <botlish_fn_18+0x55ef>
    67ff:	mov    0x378(%rsp),%rdx
    6807:	mov    %rdx,0x38(%rsp)
    680c:	mov    0x378(%rsp),%rdx
    6814:	mov    0x3c8(%rsp),%r12
    681c:	jmp    72a3 <botlish_fn_18+0x608b>
    6821:	shl    $1,%rsi
    6824:	or     $0x1,%rsi
    6828:	mov    %rsi,0xb0(%rsp)
    6830:	mov    $0x1,%eax
    6835:	mov    %rax,0x370(%rsp)
    683d:	movq   $0x1,0x80(%rsp)
    6849:	mov    %rbx,%r12
    684c:	mov    0x3a8(%rsp),%r15
    6854:	mov    %rsi,0x3b8(%rsp)
    685c:	jmp    7997 <botlish_fn_18+0x677f>
    6861:	mov    0x358(%rsp),%rdi
    6869:	mov    0x10(%rdi),%rax
    686d:	mov    0x168(%rax),%rsi
    6874:	mov    0x170(%rax),%rdx
    687b:	call   6880 <botlish_fn_18+0x5668>
			687c: R_X86_64_PLT32	rt_raise-0x4
    6880:	jmp    7764 <botlish_fn_18+0x654c>
    6885:	mov    0x3b0(%rsp),%rsi
    688d:	mov    %rsi,%rax
    6890:	sar    $1,%rax
    6893:	shl    $1,%rax
    6896:	or     $0x1,%rax
    689a:	sar    $1,%rax
    689d:	test   %rax,%rax
    68a0:	jle    6aa7 <botlish_fn_18+0x588f>
    68a6:	cmp    $0x2,%rax
    68aa:	jl     68bd <botlish_fn_18+0x56a5>
    68b0:	mov    0x358(%rsp),%rdi
    68b8:	jmp    6dba <botlish_fn_18+0x5ba2>
    68bd:	mov    0x378(%rsp),%rdx
    68c5:	test   $0x1,%rdx
    68cc:	jne    6904 <botlish_fn_18+0x56ec>
    68d2:	mov    0x3f0(%rsp),%rdx
    68da:	mov    0x378(%rsp),%rsi
    68e2:	mov    0x358(%rsp),%rdi
    68ea:	call   68ef <botlish_fn_18+0x56d7>
			68eb: R_X86_64_PLT32	rt_int_cmp-0x4
    68ef:	mov    $0x2,%esi
    68f4:	test   %rax,%rax
    68f7:	cmovl  0x1891(%rip),%rsi        # 8190 <botlish_fn_18+0x6f78>
    68ff:	jmp    691d <botlish_fn_18+0x5705>
    6904:	mov    $0x2,%esi
    6909:	mov    0x378(%rsp),%rdx
    6911:	cmp    $0xffffffffffffffff,%rdx
    6915:	cmovl  0x1873(%rip),%rsi        # 8190 <botlish_fn_18+0x6f78>
    691d:	cmp    $0x6,%rsi
    6921:	je     6a9d <botlish_fn_18+0x5885>
    6927:	mov    0x378(%rsp),%rdx
    692f:	test   $0x1,%rdx
    6936:	jne    696b <botlish_fn_18+0x5753>
    693c:	mov    $0x21ffff,%edx
    6941:	mov    0x378(%rsp),%rsi
    6949:	mov    0x358(%rsp),%rdi
    6951:	call   6956 <botlish_fn_18+0x573e>
			6952: R_X86_64_PLT32	rt_int_cmp-0x4
    6956:	mov    $0x2,%ecx
    695b:	test   %rax,%rax
    695e:	cmovg  0x182a(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6966:	jmp    6987 <botlish_fn_18+0x576f>
    696b:	mov    $0x2,%ecx
    6970:	mov    0x378(%rsp),%rdx
    6978:	cmp    $0x21ffff,%rdx
    697f:	cmovg  0x1809(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6987:	cmp    $0x6,%rcx
    698b:	je     6a9d <botlish_fn_18+0x5885>
    6991:	mov    0x378(%rsp),%rdx
    6999:	mov    %rdx,%rax
    699c:	sar    $1,%rax
    699f:	cmp    $0x85,%rax
    69a5:	jl     6a2b <botlish_fn_18+0x5813>
    69ab:	cmp    $0xfeff,%rax
    69b1:	jl     69f1 <botlish_fn_18+0x57d9>
    69b7:	cmp    $0xfffe,%rax
    69bd:	jl     69e0 <botlish_fn_18+0x57c8>
    69c3:	cmp    $0x10000,%rax
    69c9:	jl     6a9d <botlish_fn_18+0x5885>
    69cf:	cmp    $0x110000,%rax
    69d5:	jge    6a9d <botlish_fn_18+0x5885>
    69db:	jmp    6ba0 <botlish_fn_18+0x5988>
    69e0:	cmp    $0xff00,%rax
    69e6:	jge    6ba0 <botlish_fn_18+0x5988>
    69ec:	jmp    6a9d <botlish_fn_18+0x5885>
    69f1:	cmp    $0xa0,%rax
    69f7:	jl     6a1a <botlish_fn_18+0x5802>
    69fd:	cmp    $0xd800,%rax
    6a03:	jl     6ba0 <botlish_fn_18+0x5988>
    6a09:	cmp    $0xe000,%rax
    6a0f:	jge    6ba0 <botlish_fn_18+0x5988>
    6a15:	jmp    6a9d <botlish_fn_18+0x5885>
    6a1a:	cmp    $0x86,%rax
    6a20:	jge    6a9d <botlish_fn_18+0x5885>
    6a26:	jmp    6ba0 <botlish_fn_18+0x5988>
    6a2b:	cmp    $0xb,%rax
    6a2f:	jl     6a67 <botlish_fn_18+0x584f>
    6a35:	cmp    $0xe,%rax
    6a39:	jl     6a58 <botlish_fn_18+0x5840>
    6a3f:	cmp    $0x20,%rax
    6a43:	jl     6a9d <botlish_fn_18+0x5885>
    6a49:	cmp    $0x7f,%rax
    6a4d:	jge    6a9d <botlish_fn_18+0x5885>
    6a53:	jmp    6ba0 <botlish_fn_18+0x5988>
    6a58:	cmp    $0xd,%rax
    6a5c:	jge    6a93 <botlish_fn_18+0x587b>
    6a62:	jmp    6a9d <botlish_fn_18+0x5885>
    6a67:	test   %rax,%rax
    6a6a:	jl     6a89 <botlish_fn_18+0x5871>
    6a70:	cmp    $0x9,%rax
    6a74:	jl     6a9d <botlish_fn_18+0x5885>
    6a7a:	cmp    $0xa,%rax
    6a7e:	jge    6a93 <botlish_fn_18+0x587b>
    6a84:	jmp    6ba0 <botlish_fn_18+0x5988>
    6a89:	cmp    $0xffffffffffffffff,%rax
    6a8d:	jl     6a9d <botlish_fn_18+0x5885>
    6a93:	mov    $0x2,%esi
    6a98:	jmp    6bb2 <botlish_fn_18+0x599a>
    6a9d:	mov    $0x4,%esi
    6aa2:	jmp    6bb2 <botlish_fn_18+0x599a>
    6aa7:	test   %rax,%rax
    6aaa:	jl     6db2 <botlish_fn_18+0x5b9a>
    6ab0:	mov    0x378(%rsp),%rdx
    6ab8:	test   $0x1,%rdx
    6abf:	jne    6af4 <botlish_fn_18+0x58dc>
    6ac5:	mov    $0x47,%edx
    6aca:	mov    0x378(%rsp),%rsi
    6ad2:	mov    0x358(%rsp),%rdi
    6ada:	call   6adf <botlish_fn_18+0x58c7>
			6adb: R_X86_64_PLT32	rt_int_cmp-0x4
    6adf:	mov    $0x2,%ecx
    6ae4:	test   %rax,%rax
    6ae7:	cmovl  0x16a1(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6aef:	jmp    6b0d <botlish_fn_18+0x58f5>
    6af4:	mov    $0x2,%ecx
    6af9:	mov    0x378(%rsp),%rdx
    6b01:	cmp    $0x47,%rdx
    6b05:	cmovl  0x1683(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6b0d:	cmp    $0x6,%rcx
    6b11:	je     6baa <botlish_fn_18+0x5992>
    6b17:	mov    0x378(%rsp),%rdx
    6b1f:	test   $0x1,%rdx
    6b26:	jne    6b5b <botlish_fn_18+0x5943>
    6b2c:	mov    $0x47,%edx
    6b31:	mov    0x378(%rsp),%rsi
    6b39:	mov    0x358(%rsp),%rdi
    6b41:	call   6b46 <botlish_fn_18+0x592e>
			6b42: R_X86_64_PLT32	rt_int_cmp-0x4
    6b46:	mov    $0x2,%ecx
    6b4b:	test   %rax,%rax
    6b4e:	cmovg  0x163a(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6b56:	jmp    6b74 <botlish_fn_18+0x595c>
    6b5b:	mov    $0x2,%ecx
    6b60:	mov    0x378(%rsp),%rdx
    6b68:	cmp    $0x47,%rdx
    6b6c:	cmovg  0x161c(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6b74:	cmp    $0x6,%rcx
    6b78:	je     6baa <botlish_fn_18+0x5992>
    6b7e:	mov    0x378(%rsp),%rdx
    6b86:	mov    %rdx,%rax
    6b89:	sar    $1,%rax
    6b8c:	cmp    $0x23,%rax
    6b90:	jl     6baa <botlish_fn_18+0x5992>
    6b96:	cmp    $0x24,%rax
    6b9a:	jge    6baa <botlish_fn_18+0x5992>
    6ba0:	mov    $0x1,%esi
    6ba5:	jmp    6bb2 <botlish_fn_18+0x599a>
    6baa:	mov    0x3e0(%rsp),%rsi
    6bb2:	mov    %rsi,%rcx
    6bb5:	shl    $1,%rcx
    6bb8:	or     $0x1,%rcx
    6bbc:	mov    $0x2,%eax
    6bc1:	cmp    $0x5,%rcx
    6bc5:	cmovl  0x15c3(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    6bcd:	cmp    $0x6,%rax
    6bd1:	je     6d6d <botlish_fn_18+0x5b55>
    6bd7:	mov    %rsi,%rcx
    6bda:	shl    $1,%rcx
    6bdd:	mov    %rsi,%rbx
    6be0:	or     $0x1,%rcx
    6be4:	mov    $0x2,%eax
    6be9:	cmp    $0x5,%rcx
    6bed:	cmove  0x159b(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    6bf5:	cmp    $0x6,%rax
    6bf9:	je     6d53 <botlish_fn_18+0x5b3b>
    6bff:	mov    0x378(%rsp),%rdx
    6c07:	test   $0x1,%rdx
    6c0e:	jne    6c46 <botlish_fn_18+0x5a2e>
    6c14:	mov    0x3f0(%rsp),%rdx
    6c1c:	mov    0x378(%rsp),%rsi
    6c24:	mov    0x358(%rsp),%rdi
    6c2c:	call   6c31 <botlish_fn_18+0x5a19>
			6c2d: R_X86_64_PLT32	rt_int_cmp-0x4
    6c31:	mov    $0x2,%ecx
    6c36:	test   %rax,%rax
    6c39:	cmove  0x154f(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6c41:	jmp    6c5f <botlish_fn_18+0x5a47>
    6c46:	mov    $0x2,%ecx
    6c4b:	mov    0x378(%rsp),%rdx
    6c53:	cmp    $0xffffffffffffffff,%rdx
    6c57:	cmove  0x1531(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6c5f:	cmp    $0x6,%rcx
    6c63:	je     6ce6 <botlish_fn_18+0x5ace>
    6c69:	mov    0x358(%rsp),%rdi
    6c71:	mov    0x10(%rdi),%rax
    6c75:	mov    0x1a0(%rax),%r12
    6c7c:	mov    $0x1,%r13d
    6c82:	mov    %rbx,%rsi
    6c85:	shl    $1,%rsi
    6c88:	or     $0x1,%rsi
    6c8c:	call   6c91 <botlish_fn_18+0x5a79>
			6c8d: R_X86_64_PLT32	botlish_fn_7-0x4
    6c91:	mov    0x358(%rsp),%rdi
    6c99:	mov    0x10(%rdi),%rcx
    6c9d:	mov    0x190(%rcx),%rdx
    6ca4:	lea    0x2c8(%rsp),%r9
    6cac:	mov    %r12,0x2c8(%rsp)
    6cb4:	mov    %rax,0x2d0(%rsp)
    6cbc:	mov    0x378(%rsp),%rax
    6cc4:	mov    %rax,0x2d8(%rsp)
    6ccc:	mov    $0x5,%ecx
    6cd1:	mov    %r13,%rsi
    6cd4:	mov    0x3e0(%rsp),%r8
    6cdc:	call   6ce1 <botlish_fn_18+0x5ac9>
			6cdd: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6ce1:	jmp    7764 <botlish_fn_18+0x654c>
    6ce6:	mov    %rbx,%rsi
    6ce9:	mov    0x358(%rsp),%rdi
    6cf1:	mov    0x10(%rdi),%rdi
    6cf5:	mov    0x1a0(%rdi),%r12
    6cfc:	shl    $1,%rsi
    6cff:	or     $0x1,%rsi
    6d03:	mov    0x358(%rsp),%rdi
    6d0b:	call   6d10 <botlish_fn_18+0x5af8>
			6d0c: R_X86_64_PLT32	botlish_fn_7-0x4
    6d10:	mov    0x358(%rsp),%rdi
    6d18:	mov    0x10(%rdi),%rsi
    6d1c:	mov    0x188(%rsi),%rdx
    6d23:	lea    0x2b8(%rsp),%r9
    6d2b:	mov    %r12,0x2b8(%rsp)
    6d33:	mov    %rax,0x2c0(%rsp)
    6d3b:	mov    $0x2,%r8d
    6d41:	mov    $0x4,%ecx
    6d46:	mov    %r8,%rsi
    6d49:	call   6d4e <botlish_fn_18+0x5b36>
			6d4a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6d4e:	jmp    7764 <botlish_fn_18+0x654c>
    6d53:	mov    0x378(%rsp),%rdx
    6d5b:	mov    %rdx,0x38(%rsp)
    6d60:	mov    0x3c8(%rsp),%r12
    6d68:	jmp    72a3 <botlish_fn_18+0x608b>
    6d6d:	shl    $1,%rsi
    6d70:	or     $0x1,%rsi
    6d74:	mov    %rsi,0xa8(%rsp)
    6d7c:	mov    $0x1,%eax
    6d81:	mov    %rax,0x370(%rsp)
    6d89:	movq   $0x1,0x80(%rsp)
    6d95:	mov    0x3e0(%rsp),%r12
    6d9d:	mov    0x3a8(%rsp),%r15
    6da5:	mov    %rsi,0x3b0(%rsp)
    6dad:	jmp    7997 <botlish_fn_18+0x677f>
    6db2:	mov    0x358(%rsp),%rdi
    6dba:	mov    0x358(%rsp),%rdi
    6dc2:	mov    0x10(%rdi),%rax
    6dc6:	mov    0x168(%rax),%rsi
    6dcd:	mov    0x170(%rax),%rdx
    6dd4:	call   6dd9 <botlish_fn_18+0x5bc1>
			6dd5: R_X86_64_PLT32	rt_raise-0x4
    6dd9:	jmp    7764 <botlish_fn_18+0x654c>
    6dde:	mov    0x3d0(%rsp),%rsi
    6de6:	mov    %rsi,%rax
    6de9:	sar    $1,%rax
    6dec:	shl    $1,%rax
    6def:	or     $0x1,%rax
    6df3:	sar    $1,%rax
    6df6:	test   %rax,%rax
    6df9:	jle    6fa3 <botlish_fn_18+0x5d8b>
    6dff:	cmp    $0x2,%rax
    6e03:	jl     6e16 <botlish_fn_18+0x5bfe>
    6e09:	mov    0x358(%rsp),%rdi
    6e11:	jmp    7469 <botlish_fn_18+0x6251>
    6e16:	mov    0x378(%rsp),%rdx
    6e1e:	test   $0x1,%rdx
    6e25:	jne    6e5a <botlish_fn_18+0x5c42>
    6e2b:	mov    $0x13,%edx
    6e30:	mov    0x378(%rsp),%rsi
    6e38:	mov    0x358(%rsp),%rdi
    6e40:	call   6e45 <botlish_fn_18+0x5c2d>
			6e41: R_X86_64_PLT32	rt_int_cmp-0x4
    6e45:	mov    $0x2,%ecx
    6e4a:	test   %rax,%rax
    6e4d:	cmovl  0x133b(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6e55:	jmp    6e73 <botlish_fn_18+0x5c5b>
    6e5a:	mov    $0x2,%ecx
    6e5f:	mov    0x378(%rsp),%rdx
    6e67:	cmp    $0x13,%rdx
    6e6b:	cmovl  0x131d(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6e73:	cmp    $0x6,%rcx
    6e77:	je     6f99 <botlish_fn_18+0x5d81>
    6e7d:	mov    0x378(%rsp),%rdx
    6e85:	test   $0x1,%rdx
    6e8c:	jne    6ec1 <botlish_fn_18+0x5ca9>
    6e92:	mov    $0x21ffff,%edx
    6e97:	mov    0x378(%rsp),%rsi
    6e9f:	mov    0x358(%rsp),%rdi
    6ea7:	call   6eac <botlish_fn_18+0x5c94>
			6ea8: R_X86_64_PLT32	rt_int_cmp-0x4
    6eac:	mov    $0x2,%ecx
    6eb1:	test   %rax,%rax
    6eb4:	cmovg  0x12d4(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6ebc:	jmp    6edd <botlish_fn_18+0x5cc5>
    6ec1:	mov    $0x2,%ecx
    6ec6:	mov    0x378(%rsp),%rdx
    6ece:	cmp    $0x21ffff,%rdx
    6ed5:	cmovg  0x12b3(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6edd:	cmp    $0x6,%rcx
    6ee1:	je     6f99 <botlish_fn_18+0x5d81>
    6ee7:	mov    0x378(%rsp),%rdx
    6eef:	mov    %rdx,%rax
    6ef2:	sar    $1,%rax
    6ef5:	cmp    $0x22,%rax
    6ef9:	jl     6f62 <botlish_fn_18+0x5d4a>
    6eff:	cmp    $0x5d,%rax
    6f03:	jl     6f37 <botlish_fn_18+0x5d1f>
    6f09:	cmp    $0xe000,%rax
    6f0f:	jl     6f26 <botlish_fn_18+0x5d0e>
    6f15:	cmp    $0x110000,%rax
    6f1b:	jge    6f99 <botlish_fn_18+0x5d81>
    6f21:	jmp    709e <botlish_fn_18+0x5e86>
    6f26:	cmp    $0xd800,%rax
    6f2c:	jge    6f99 <botlish_fn_18+0x5d81>
    6f32:	jmp    709e <botlish_fn_18+0x5e86>
    6f37:	cmp    $0x23,%rax
    6f3b:	jl     6f58 <botlish_fn_18+0x5d40>
    6f41:	cmp    $0x5c,%rax
    6f45:	jl     709e <botlish_fn_18+0x5e86>
    6f4b:	mov    0x3e0(%rsp),%rsi
    6f53:	jmp    70ad <botlish_fn_18+0x5e95>
    6f58:	mov    $0x2,%esi
    6f5d:	jmp    70ad <botlish_fn_18+0x5e95>
    6f62:	cmp    $0xd,%rax
    6f66:	jl     6f85 <botlish_fn_18+0x5d6d>
    6f6c:	cmp    $0xe,%rax
    6f70:	jl     709e <botlish_fn_18+0x5e86>
    6f76:	cmp    $0x20,%rax
    6f7a:	jge    709e <botlish_fn_18+0x5e86>
    6f80:	jmp    6f99 <botlish_fn_18+0x5d81>
    6f85:	cmp    $0x9,%rax
    6f89:	jl     6f99 <botlish_fn_18+0x5d81>
    6f8f:	cmp    $0xb,%rax
    6f93:	jl     709e <botlish_fn_18+0x5e86>
    6f99:	mov    $0x5,%esi
    6f9e:	jmp    70ad <botlish_fn_18+0x5e95>
    6fa3:	test   %rax,%rax
    6fa6:	jl     7461 <botlish_fn_18+0x6249>
    6fac:	mov    0x378(%rsp),%rdx
    6fb4:	test   $0x1,%rdx
    6fbb:	jne    6ff0 <botlish_fn_18+0x5dd8>
    6fc1:	mov    $0x45,%edx
    6fc6:	mov    0x378(%rsp),%rsi
    6fce:	mov    0x358(%rsp),%rdi
    6fd6:	call   6fdb <botlish_fn_18+0x5dc3>
			6fd7: R_X86_64_PLT32	rt_int_cmp-0x4
    6fdb:	mov    $0x2,%ecx
    6fe0:	test   %rax,%rax
    6fe3:	cmovl  0x11a5(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    6feb:	jmp    7009 <botlish_fn_18+0x5df1>
    6ff0:	mov    $0x2,%ecx
    6ff5:	mov    0x378(%rsp),%rdx
    6ffd:	cmp    $0x45,%rdx
    7001:	cmovl  0x1187(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    7009:	cmp    $0x6,%rcx
    700d:	je     70a8 <botlish_fn_18+0x5e90>
    7013:	mov    0x378(%rsp),%rdx
    701b:	test   $0x1,%rdx
    7022:	jne    7058 <botlish_fn_18+0x5e40>
    7028:	mov    $0x45,%edx
    702d:	mov    0x378(%rsp),%rsi
    7035:	mov    0x358(%rsp),%rdi
    703d:	call   7042 <botlish_fn_18+0x5e2a>
			703e: R_X86_64_PLT32	rt_int_cmp-0x4
    7042:	mov    $0x2,%r8d
    7048:	test   %rax,%rax
    704b:	cmovg  0x113d(%rip),%r8        # 8190 <botlish_fn_18+0x6f78>
    7053:	jmp    7072 <botlish_fn_18+0x5e5a>
    7058:	mov    $0x2,%r8d
    705e:	mov    0x378(%rsp),%rdx
    7066:	cmp    $0x45,%rdx
    706a:	cmovg  0x111e(%rip),%r8        # 8190 <botlish_fn_18+0x6f78>
    7072:	cmp    $0x6,%r8
    7076:	je     70a8 <botlish_fn_18+0x5e90>
    707c:	mov    0x378(%rsp),%rdx
    7084:	mov    %rdx,%rax
    7087:	sar    $1,%rax
    708a:	cmp    $0x22,%rax
    708e:	jl     70a8 <botlish_fn_18+0x5e90>
    7094:	cmp    $0x23,%rax
    7098:	jge    70a8 <botlish_fn_18+0x5e90>
    709e:	mov    $0x1,%esi
    70a3:	jmp    70ad <botlish_fn_18+0x5e95>
    70a8:	mov    $0x4,%esi
    70ad:	mov    %rsi,%rcx
    70b0:	shl    $1,%rcx
    70b3:	or     $0x1,%rcx
    70b7:	mov    $0x2,%eax
    70bc:	cmp    $0x5,%rcx
    70c0:	cmovl  0x10c8(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    70c8:	cmp    $0x6,%rax
    70cc:	je     743d <botlish_fn_18+0x6225>
    70d2:	mov    %rsi,%rcx
    70d5:	shl    $1,%rcx
    70d8:	or     $0x1,%rcx
    70dc:	mov    $0x2,%eax
    70e1:	cmp    $0x5,%rcx
    70e5:	cmove  0x10a3(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    70ed:	cmp    $0x6,%rax
    70f1:	je     7283 <botlish_fn_18+0x606b>
    70f7:	mov    %rsi,%rcx
    70fa:	shl    $1,%rcx
    70fd:	mov    %rsi,%rbx
    7100:	or     $0x1,%rcx
    7104:	mov    $0x2,%eax
    7109:	cmp    $0x7,%rcx
    710d:	cmove  0x107b(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    7115:	cmp    $0x6,%rax
    7119:	je     726b <botlish_fn_18+0x6053>
    711f:	mov    0x378(%rsp),%rdx
    7127:	test   $0x1,%rdx
    712e:	jne    7166 <botlish_fn_18+0x5f4e>
    7134:	mov    0x3f0(%rsp),%rdx
    713c:	mov    0x378(%rsp),%rsi
    7144:	mov    0x358(%rsp),%rdi
    714c:	call   7151 <botlish_fn_18+0x5f39>
			714d: R_X86_64_PLT32	rt_int_cmp-0x4
    7151:	mov    $0x2,%ecx
    7156:	test   %rax,%rax
    7159:	cmove  0x102f(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    7161:	jmp    717f <botlish_fn_18+0x5f67>
    7166:	mov    $0x2,%ecx
    716b:	mov    0x378(%rsp),%rdx
    7173:	cmp    $0xffffffffffffffff,%rdx
    7177:	cmove  0x1011(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    717f:	cmp    $0x6,%rcx
    7183:	je     7206 <botlish_fn_18+0x5fee>
    7189:	mov    0x358(%rsp),%rdi
    7191:	mov    0x10(%rdi),%r9
    7195:	mov    0x198(%r9),%r12
    719c:	mov    $0x1,%r13d
    71a2:	mov    %rbx,%rsi
    71a5:	shl    $1,%rsi
    71a8:	or     $0x1,%rsi
    71ac:	call   71b1 <botlish_fn_18+0x5f99>
			71ad: R_X86_64_PLT32	botlish_fn_3-0x4
    71b1:	mov    0x358(%rsp),%rdi
    71b9:	mov    0x10(%rdi),%r9
    71bd:	mov    0x190(%r9),%rdx
    71c4:	lea    0x2a0(%rsp),%r9
    71cc:	mov    %r12,0x2a0(%rsp)
    71d4:	mov    %rax,0x2a8(%rsp)
    71dc:	mov    0x378(%rsp),%rax
    71e4:	mov    %rax,0x2b0(%rsp)
    71ec:	mov    $0x5,%ecx
    71f1:	mov    %r13,%rsi
    71f4:	mov    0x3e0(%rsp),%r8
    71fc:	call   7201 <botlish_fn_18+0x5fe9>
			71fd: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    7201:	jmp    7764 <botlish_fn_18+0x654c>
    7206:	mov    %rbx,%rsi
    7209:	mov    0x358(%rsp),%rdi
    7211:	mov    0x10(%rdi),%rax
    7215:	mov    0x198(%rax),%r13
    721c:	shl    $1,%rsi
    721f:	or     $0x1,%rsi
    7223:	call   7228 <botlish_fn_18+0x6010>
			7224: R_X86_64_PLT32	botlish_fn_3-0x4
    7228:	mov    0x358(%rsp),%rdi
    7230:	mov    0x10(%rdi),%rcx
    7234:	mov    0x188(%rcx),%rdx
    723b:	lea    0x290(%rsp),%r9
    7243:	mov    %r13,0x290(%rsp)
    724b:	mov    %rax,0x298(%rsp)
    7253:	mov    $0x2,%r8d
    7259:	mov    $0x4,%ecx
    725e:	mov    %r8,%rsi
    7261:	call   7266 <botlish_fn_18+0x604e>
			7262: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    7266:	jmp    7764 <botlish_fn_18+0x654c>
    726b:	xor    %rbx,%rbx
    726e:	mov    0x358(%rsp),%rdi
    7276:	mov    0x3a8(%rsp),%r15
    727e:	jmp    74a3 <botlish_fn_18+0x628b>
    7283:	mov    $0xfffffffffffffffd,%rdx
    728a:	mov    %rdx,0x378(%rsp)
    7292:	movq   $0xfffffffffffffffd,0x38(%rsp)
    729b:	mov    0x3c8(%rsp),%r12
    72a3:	test   $0x1,%rdx
    72aa:	jne    72df <botlish_fn_18+0x60c7>
    72b0:	mov    $0x1,%edx
    72b5:	mov    0x378(%rsp),%rsi
    72bd:	mov    0x358(%rsp),%rdi
    72c5:	call   72ca <botlish_fn_18+0x60b2>
			72c6: R_X86_64_PLT32	rt_int_cmp-0x4
    72ca:	mov    $0x2,%ecx
    72cf:	test   %rax,%rax
    72d2:	cmovge 0xeb6(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    72da:	jmp    72ff <botlish_fn_18+0x60e7>
    72df:	mov    $0x2,%ecx
    72e4:	mov    0x378(%rsp),%rax
    72ec:	mov    0x378(%rsp),%rdx
    72f4:	test   %rax,%rdx
    72f7:	cmovg  0xe91(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    72ff:	cmp    $0x6,%rcx
    7303:	je     7400 <botlish_fn_18+0x61e8>
    7309:	mov    0x378(%rsp),%rdx
    7311:	test   $0x1,%rdx
    7318:	jne    734f <botlish_fn_18+0x6137>
    731e:	mov    $0xfffffffffffffffd,%rdx
    7325:	mov    0x378(%rsp),%rsi
    732d:	mov    0x358(%rsp),%rdi
    7335:	call   733a <botlish_fn_18+0x6122>
			7336: R_X86_64_PLT32	rt_int_cmp-0x4
    733a:	mov    $0x2,%ecx
    733f:	test   %rax,%rax
    7342:	cmovl  0xe46(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    734a:	jmp    7368 <botlish_fn_18+0x6150>
    734f:	mov    $0x2,%ecx
    7354:	mov    0x378(%rsp),%rdx
    735c:	cmp    $0xfffffffffffffffd,%rdx
    7360:	cmovl  0xe28(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    7368:	cmp    $0x6,%rcx
    736c:	je     7384 <botlish_fn_18+0x616c>
    7372:	mov    $0x1,%eax
    7377:	mov    %rax,0x370(%rsp)
    737f:	jmp    7410 <botlish_fn_18+0x61f8>
    7384:	mov    $0xfffffffffffffffd,%rsi
    738b:	movq   $0xfffffffffffffffd,0x40(%rsp)
    7394:	mov    0x378(%rsp),%rdx
    739c:	test   $0x1,%rdx
    73a3:	jne    73b6 <botlish_fn_18+0x619e>
    73a9:	mov    0x378(%rsp),%rdx
    73b1:	jmp    73e6 <botlish_fn_18+0x61ce>
    73b6:	mov    0x378(%rsp),%rdx
    73be:	mov    %rsi,%rax
    73c1:	sub    %rdx,%rax
    73c4:	seto   %cl
    73c7:	add    $0x1,%rax
    73ce:	mov    %rax,0x370(%rsp)
    73d6:	test   %cl,%cl
    73d8:	je     7410 <botlish_fn_18+0x61f8>
    73de:	mov    0x378(%rsp),%rdx
    73e6:	mov    0x358(%rsp),%rdi
    73ee:	call   73f3 <botlish_fn_18+0x61db>
			73ef: R_X86_64_PLT32	rt_int_sub-0x4
    73f3:	mov    %rax,0x370(%rsp)
    73fb:	jmp    7410 <botlish_fn_18+0x61f8>
    7400:	mov    0x3e0(%rsp),%rax
    7408:	mov    %rax,0x370(%rsp)
    7410:	mov    0x370(%rsp),%rax
    7418:	mov    %rax,0x80(%rsp)
    7420:	mov    %r12,0x3c8(%rsp)
    7428:	mov    0x3a8(%rsp),%r15
    7430:	mov    0x3f0(%rsp),%r12
    7438:	jmp    7997 <botlish_fn_18+0x677f>
    743d:	shl    $1,%rsi
    7440:	or     $0x1,%rsi
    7444:	mov    %rsi,0x98(%rsp)
    744c:	mov    0x3a8(%rsp),%r15
    7454:	mov    %rsi,0x3d0(%rsp)
    745c:	jmp    7940 <botlish_fn_18+0x6728>
    7461:	mov    0x358(%rsp),%rdi
    7469:	mov    0x358(%rsp),%rdi
    7471:	mov    0x10(%rdi),%rax
    7475:	mov    0x168(%rax),%rsi
    747c:	mov    0x170(%rax),%rdx
    7483:	call   7488 <botlish_fn_18+0x6270>
			7484: R_X86_64_PLT32	rt_raise-0x4
    7488:	jmp    7764 <botlish_fn_18+0x654c>
    748d:	mov    0x3a8(%rsp),%r15
    7495:	mov    %r15,%rbx
    7498:	sar    $1,%rbx
    749b:	mov    0x358(%rsp),%rdi
    74a3:	mov    0x358(%rsp),%rdi
    74ab:	mov    0x10(%rdi),%rax
    74af:	mov    0x178(%rax),%r12
    74b6:	mov    0x378(%rsp),%rdx
    74be:	test   $0x1,%rdx
    74c5:	jne    74fe <botlish_fn_18+0x62e6>
    74cb:	mov    0x3f0(%rsp),%rdx
    74d3:	mov    0x378(%rsp),%rsi
    74db:	mov    0x358(%rsp),%rdi
    74e3:	call   74e8 <botlish_fn_18+0x62d0>
			74e4: R_X86_64_PLT32	rt_int_cmp-0x4
    74e8:	mov    $0x2,%r8d
    74ee:	test   %rax,%rax
    74f1:	cmovl  0xc97(%rip),%r8        # 8190 <botlish_fn_18+0x6f78>
    74f9:	jmp    7518 <botlish_fn_18+0x6300>
    74fe:	mov    $0x2,%r8d
    7504:	mov    0x378(%rsp),%rdx
    750c:	cmp    $0xffffffffffffffff,%rdx
    7510:	cmovl  0xc78(%rip),%r8        # 8190 <botlish_fn_18+0x6f78>
    7518:	cmp    $0x6,%r8
    751c:	je     75bb <botlish_fn_18+0x63a3>
    7522:	mov    0x378(%rsp),%rdx
    752a:	test   $0x1,%rdx
    7531:	jne    7566 <botlish_fn_18+0x634e>
    7537:	mov    $0x1ff,%edx
    753c:	mov    0x378(%rsp),%rsi
    7544:	mov    0x358(%rsp),%rdi
    754c:	call   7551 <botlish_fn_18+0x6339>
			754d: R_X86_64_PLT32	rt_int_cmp-0x4
    7551:	mov    $0x2,%ecx
    7556:	test   %rax,%rax
    7559:	cmovg  0xc2f(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    7561:	jmp    7582 <botlish_fn_18+0x636a>
    7566:	mov    $0x2,%ecx
    756b:	mov    0x378(%rsp),%rdx
    7573:	cmp    $0x1ff,%rdx
    757a:	cmovg  0xc0e(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    7582:	cmp    $0x6,%rcx
    7586:	je     75bb <botlish_fn_18+0x63a3>
    758c:	shl    $1,%rbx
    758f:	or     $0x1,%rbx
    7593:	sar    $1,%rbx
    7596:	imul   $0x101,%rbx,%rax
    759d:	mov    0x378(%rsp),%rdx
    75a5:	mov    %rdx,%rcx
    75a8:	sar    $1,%rcx
    75ab:	lea    0x1(%rax,%rcx,1),%rax
    75b0:	movzbq 0x10(%r12,%rax,1),%rsi
    75b6:	jmp    75ce <botlish_fn_18+0x63b6>
    75bb:	shl    $1,%rbx
    75be:	or     $0x1,%rbx
    75c2:	sar    $1,%rbx
    75c5:	movzbq 0xc1c(%r12,%rbx,1),%rsi
    75ce:	mov    %rsi,%rcx
    75d1:	shl    $1,%rcx
    75d4:	or     $0x1,%rcx
    75d8:	mov    $0x2,%eax
    75dd:	cmp    $0x19,%rcx
    75e1:	cmovl  0xba7(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    75e9:	cmp    $0x6,%rax
    75ed:	je     7964 <botlish_fn_18+0x674c>
    75f3:	mov    %rsi,%rcx
    75f6:	shl    $1,%rcx
    75f9:	mov    %rsi,%rbx
    75fc:	or     $0x1,%rcx
    7600:	mov    $0x2,%eax
    7605:	cmp    $0x19,%rcx
    7609:	cmove  0xb7f(%rip),%rax        # 8190 <botlish_fn_18+0x6f78>
    7611:	cmp    $0x6,%rax
    7615:	je     7924 <botlish_fn_18+0x670c>
    761b:	mov    0x378(%rsp),%rdx
    7623:	test   $0x1,%rdx
    762a:	jne    7663 <botlish_fn_18+0x644b>
    7630:	mov    0x3f0(%rsp),%rdx
    7638:	mov    0x378(%rsp),%rsi
    7640:	mov    0x358(%rsp),%rdi
    7648:	call   764d <botlish_fn_18+0x6435>
			7649: R_X86_64_PLT32	rt_int_cmp-0x4
    764d:	mov    $0x2,%r10d
    7653:	test   %rax,%rax
    7656:	cmove  0xb32(%rip),%r10        # 8190 <botlish_fn_18+0x6f78>
    765e:	jmp    767d <botlish_fn_18+0x6465>
    7663:	mov    $0x2,%r10d
    7669:	mov    0x378(%rsp),%rdx
    7671:	cmp    $0xffffffffffffffff,%rdx
    7675:	cmove  0xb13(%rip),%r10        # 8190 <botlish_fn_18+0x6f78>
    767d:	cmp    $0x6,%r10
    7681:	je     7704 <botlish_fn_18+0x64ec>
    7687:	mov    0x358(%rsp),%rdi
    768f:	mov    0x10(%rdi),%rax
    7693:	mov    0x180(%rax),%r12
    769a:	mov    $0x1,%r13d
    76a0:	mov    %rbx,%rsi
    76a3:	shl    $1,%rsi
    76a6:	or     $0x1,%rsi
    76aa:	call   76af <botlish_fn_18+0x6497>
			76ab: R_X86_64_PLT32	botlish_fn_1-0x4
    76af:	mov    0x358(%rsp),%rdi
    76b7:	mov    0x10(%rdi),%rcx
    76bb:	mov    0x190(%rcx),%rdx
    76c2:	lea    0x278(%rsp),%r9
    76ca:	mov    %r12,0x278(%rsp)
    76d2:	mov    %rax,0x280(%rsp)
    76da:	mov    0x378(%rsp),%rax
    76e2:	mov    %rax,0x288(%rsp)
    76ea:	mov    $0x5,%ecx
    76ef:	mov    %r13,%rsi
    76f2:	mov    0x3e0(%rsp),%r8
    76fa:	call   76ff <botlish_fn_18+0x64e7>
			76fb: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    76ff:	jmp    7764 <botlish_fn_18+0x654c>
    7704:	mov    %rbx,%rsi
    7707:	mov    0x358(%rsp),%rdi
    770f:	mov    0x10(%rdi),%rax
    7713:	mov    0x180(%rax),%r12
    771a:	shl    $1,%rsi
    771d:	or     $0x1,%rsi
    7721:	call   7726 <botlish_fn_18+0x650e>
			7722: R_X86_64_PLT32	botlish_fn_1-0x4
    7726:	mov    0x358(%rsp),%rdi
    772e:	mov    0x10(%rdi),%rcx
    7732:	mov    0x188(%rcx),%rdx
    7739:	lea    0x268(%rsp),%r9
    7741:	mov    %r12,0x268(%rsp)
    7749:	mov    %rax,0x270(%rsp)
    7751:	mov    $0x2,%r8d
    7757:	mov    $0x4,%ecx
    775c:	mov    %r8,%rsi
    775f:	call   7764 <botlish_fn_18+0x654c>
			7760: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    7764:	mov    0x358(%rsp),%rdi
    776c:	call   7771 <botlish_fn_18+0x6559>
			776d: R_X86_64_PLT32	rt_co_failed-0x4
    7771:	mov    %rax,0x88(%rsp)
    7779:	mov    %rax,%rsi
    777c:	mov    0x358(%rsp),%rdi
    7784:	call   7789 <botlish_fn_18+0x6571>
			7785: R_X86_64_PLT32	rt_co_resume0-0x4
    7789:	test   %rax,%rax
    778c:	je     77ae <botlish_fn_18+0x6596>
    7792:	mov    0x358(%rsp),%rdi
    779a:	mov    0x10(%rdi),%rax
    779e:	mov    0x68(%rax),%rsi
    77a2:	mov    0x140(%rax),%rdx
    77a9:	call   77ae <botlish_fn_18+0x6596>
			77aa: R_X86_64_PLT32	rt_raise-0x4
    77ae:	mov    0x358(%rsp),%rdi
    77b6:	call   77bb <botlish_fn_18+0x65a3>
			77b7: R_X86_64_PLT32	rt_declared_error-0x4
    77bb:	cmp    $0x1,%rax
    77bf:	je     7870 <botlish_fn_18+0x6658>
    77c5:	mov    0x358(%rsp),%rdi
    77cd:	call   77d2 <botlish_fn_18+0x65ba>
			77ce: R_X86_64_PLT32	rt_declared_error-0x4
    77d2:	cmp    $0x2,%rax
    77d6:	jne    7f4e <botlish_fn_18+0x6d36>
    77dc:	xor    %rsi,%rsi
    77df:	mov    0x358(%rsp),%rdi
    77e7:	call   77ec <botlish_fn_18+0x65d4>
			77e8: R_X86_64_PLT32	rt_declared_payload-0x4
    77ec:	mov    %rax,%rbx
    77ef:	mov    $0x1,%r12d
    77f5:	mov    %r12,%rsi
    77f8:	mov    0x358(%rsp),%rdi
    7800:	call   7805 <botlish_fn_18+0x65ed>
			7801: R_X86_64_PLT32	rt_declared_payload-0x4
    7805:	mov    %rax,%r13
    7808:	mov    0x358(%rsp),%rdi
    7810:	call   7815 <botlish_fn_18+0x65fd>
			7811: R_X86_64_PLT32	rt_clear_declared_error-0x4
    7815:	mov    0x358(%rsp),%rdi
    781d:	mov    0x10(%rdi),%rax
    7821:	mov    0x158(%rax),%rdx
    7828:	lea    0x130(%rsp),%r9
    7830:	mov    0x3d8(%rsp),%rcx
    7838:	mov    %rcx,0x130(%rsp)
    7840:	mov    %rbx,%rax
    7843:	mov    %rax,0x138(%rsp)
    784b:	mov    %r13,%rax
    784e:	mov    %rax,0x140(%rsp)
    7856:	mov    $0x4,%esi
    785b:	mov    %r12,%rcx
    785e:	mov    0x3e0(%rsp),%r8
    7866:	call   786b <botlish_fn_18+0x6653>
			7867: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    786b:	jmp    7f4e <botlish_fn_18+0x6d36>
    7870:	xor    %rbx,%rbx
    7873:	mov    %rbx,%rsi
    7876:	mov    0x358(%rsp),%rdi
    787e:	call   7883 <botlish_fn_18+0x666b>
			787f: R_X86_64_PLT32	rt_declared_payload-0x4
    7883:	mov    %rax,%r12
    7886:	mov    $0x1,%esi
    788b:	mov    0x358(%rsp),%rdi
    7893:	call   7898 <botlish_fn_18+0x6680>
			7894: R_X86_64_PLT32	rt_declared_payload-0x4
    7898:	mov    %rax,%r13
    789b:	mov    $0x2,%esi
    78a0:	mov    0x358(%rsp),%rdi
    78a8:	call   78ad <botlish_fn_18+0x6695>
			78a9: R_X86_64_PLT32	rt_declared_payload-0x4
    78ad:	mov    %rax,%r14
    78b0:	mov    0x358(%rsp),%rdi
    78b8:	call   78bd <botlish_fn_18+0x66a5>
			78b9: R_X86_64_PLT32	rt_clear_declared_error-0x4
    78bd:	mov    0x358(%rsp),%rdi
    78c5:	mov    0x10(%rdi),%rax
    78c9:	mov    0x150(%rax),%rdx
    78d0:	lea    0x110(%rsp),%r9
    78d8:	mov    0x3d8(%rsp),%rcx
    78e0:	mov    %rcx,0x110(%rsp)
    78e8:	mov    %r12,%rax
    78eb:	mov    %rax,0x118(%rsp)
    78f3:	mov    %r13,%rax
    78f6:	mov    %rax,0x120(%rsp)
    78fe:	mov    %r14,%rax
    7901:	mov    %rax,0x128(%rsp)
    7909:	mov    $0x4,%r8d
    790f:	mov    %rbx,%rcx
    7912:	mov    0x3e0(%rsp),%rsi
    791a:	call   791f <botlish_fn_18+0x6707>
			791b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    791f:	jmp    7f4e <botlish_fn_18+0x6d36>
    7924:	movq   $0x3,0x98(%rsp)
    7930:	mov    0x3e0(%rsp),%rax
    7938:	mov    %rax,0x3d0(%rsp)
    7940:	mov    $0x1,%eax
    7945:	mov    %rax,0x370(%rsp)
    794d:	movq   $0x1,0x80(%rsp)
    7959:	mov    $0x2,%r12d
    795f:	jmp    7997 <botlish_fn_18+0x677f>
    7964:	shl    $1,%rsi
    7967:	or     $0x1,%rsi
    796b:	mov    %rsi,0xa0(%rsp)
    7973:	mov    $0x1,%eax
    7978:	mov    %rax,0x370(%rsp)
    7980:	movq   $0x1,0x80(%rsp)
    798c:	mov    0x370(%rsp),%r12
    7994:	mov    %rsi,%r15
    7997:	mov    0x400(%rsp),%rcx
    799f:	mov    0x18(%rcx),%r9
    79a3:	test   %r9,%r9
    79a6:	je     8100 <botlish_fn_18+0x6ee8>
    79ac:	mov    0x400(%rsp),%rcx
    79b4:	mov    0x10(%rcx),%rax
    79b8:	mov    0x370(%rsp),%rcx
    79c0:	mov    %rcx,0x18(%rax)
    79c4:	mov    %r15,0x3a8(%rsp)
    79cc:	jmp    3d6a <botlish_fn_18+0x2b52>
    79d1:	mov    0x358(%rsp),%rdi
    79d9:	mov    0x10(%rdi),%rax
    79dd:	mov    0x160(%rax),%rdx
    79e4:	lea    0x100(%rsp),%r9
    79ec:	mov    0x3e8(%rsp),%rax
    79f4:	mov    %rax,0x100(%rsp)
    79fc:	mov    0x368(%rsp),%rax
    7a04:	mov    %rax,0x108(%rsp)
    7a0c:	mov    $0x5,%esi
    7a11:	mov    $0x2,%r8d
    7a17:	mov    %r8,%rcx
    7a1a:	call   7a1f <botlish_fn_18+0x6807>
			7a1b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    7a1f:	jmp    7f4e <botlish_fn_18+0x6d36>
    7a24:	mov    0x400(%rsp),%rcx
    7a2c:	mov    0x10(%rcx),%rax
    7a30:	mov    (%rax),%rsi
    7a33:	mov    %rsi,0x30(%rsp)
    7a38:	mov    0x400(%rsp),%rcx
    7a40:	mov    0x10(%rcx),%rax
    7a44:	mov    0x18(%rax),%rdx
    7a48:	mov    %rdx,0x38(%rsp)
    7a4d:	mov    %rsi,%rax
    7a50:	and    %rdx,%rax
    7a53:	test   $0x1,%rax
    7a59:	je     7a77 <botlish_fn_18+0x685f>
    7a5f:	mov    %rsi,%rcx
    7a62:	sub    %rdx,%rcx
    7a65:	seto   %al
    7a68:	add    $0x1,%rcx
    7a6f:	test   %al,%al
    7a71:	je     7a87 <botlish_fn_18+0x686f>
    7a77:	mov    0x358(%rsp),%rdi
    7a7f:	call   7a84 <botlish_fn_18+0x686c>
			7a80: R_X86_64_PLT32	rt_int_sub-0x4
    7a84:	mov    %rax,%rcx
    7a87:	mov    %rcx,0x30(%rsp)
    7a8c:	mov    %rcx,%rsi
    7a8f:	mov    0x400(%rsp),%rcx
    7a97:	mov    0x18(%rcx),%rax
    7a9b:	test   %rax,%rax
    7a9e:	je     8127 <botlish_fn_18+0x6f0f>
    7aa4:	mov    0x400(%rsp),%rcx
    7aac:	mov    %rsi,%r12
    7aaf:	mov    0x10(%rcx),%rax
    7ab3:	mov    %r12,(%rax)
    7ab6:	mov    0x388(%rsp),%rbx
    7abe:	test   $0x1,%rbx
    7ac5:	jne    7af5 <botlish_fn_18+0x68dd>
    7acb:	mov    $0x45,%edx
    7ad0:	mov    %rbx,%rsi
    7ad3:	mov    0x358(%rsp),%rdi
    7adb:	call   7ae0 <botlish_fn_18+0x68c8>
			7adc: R_X86_64_PLT32	rt_int_cmp-0x4
    7ae0:	mov    $0x2,%ecx
    7ae5:	test   %rax,%rax
    7ae8:	cmove  0x6a0(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    7af0:	jmp    7b06 <botlish_fn_18+0x68ee>
    7af5:	mov    $0x2,%ecx
    7afa:	cmp    $0x45,%rbx
    7afe:	cmove  0x68a(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    7b06:	cmp    $0x6,%rcx
    7b0a:	je     7b74 <botlish_fn_18+0x695c>
    7b10:	test   $0x1,%rbx
    7b17:	jne    7b47 <botlish_fn_18+0x692f>
    7b1d:	mov    $0x4f,%edx
    7b22:	mov    %rbx,%rsi
    7b25:	mov    0x358(%rsp),%rdi
    7b2d:	call   7b32 <botlish_fn_18+0x691a>
			7b2e: R_X86_64_PLT32	rt_int_cmp-0x4
    7b32:	mov    $0x2,%ecx
    7b37:	test   %rax,%rax
    7b3a:	cmove  0x64e(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    7b42:	jmp    7b58 <botlish_fn_18+0x6940>
    7b47:	mov    $0x2,%ecx
    7b4c:	cmp    $0x4f,%rbx
    7b50:	cmove  0x638(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    7b58:	cmp    $0x6,%rcx
    7b5c:	je     7b74 <botlish_fn_18+0x695c>
    7b62:	mov    $0x1,%ecx
    7b67:	mov    0x400(%rsp),%rax
    7b6f:	jmp    7b84 <botlish_fn_18+0x696c>
    7b74:	mov    0x400(%rsp),%rax
    7b7c:	mov    0x3e0(%rsp),%rcx
    7b84:	mov    0x400(%rsp),%rax
    7b8c:	mov    0x18(%rax),%rax
    7b90:	test   %rax,%rax
    7b93:	je     814c <botlish_fn_18+0x6f34>
    7b99:	mov    0x400(%rsp),%rax
    7ba1:	mov    0x10(%rax),%rax
    7ba5:	mov    %rcx,0x10(%rax)
    7ba9:	mov    0x3e8(%rsp),%rdx
    7bb1:	mov    %r12,%rsi
    7bb4:	and    %rdx,%rsi
    7bb7:	test   $0x1,%rsi
    7bbe:	je     7beb <botlish_fn_18+0x69d3>
    7bc4:	mov    0x3e8(%rsp),%rdx
    7bcc:	mov    %r12,%rdi
    7bcf:	sub    %rdx,%rdi
    7bd2:	seto   %sil
    7bd6:	lea    0x1(%rdi),%rdx
    7bda:	test   %sil,%sil
    7bdd:	jne    7beb <botlish_fn_18+0x69d3>
    7be3:	mov    %rbx,%rsi
    7be6:	jmp    7c09 <botlish_fn_18+0x69f1>
    7beb:	mov    0x3e8(%rsp),%rdx
    7bf3:	mov    %r12,%rsi
    7bf6:	mov    0x358(%rsp),%rdi
    7bfe:	call   7c03 <botlish_fn_18+0x69eb>
			7bff: R_X86_64_PLT32	rt_int_sub-0x4
    7c03:	mov    %rax,%rdx
    7c06:	mov    %rbx,%rsi
    7c09:	mov    0x358(%rsp),%rdi
    7c11:	call   7c16 <botlish_fn_18+0x69fe>
			7c12: R_X86_64_PLT32	botlish_fn_15-0x4
    7c16:	mov    %rax,0x28(%rsp)
    7c1b:	mov    %r12,%rcx
    7c1e:	mov    0x3e8(%rsp),%rdx
    7c26:	mov    %rax,%rsi
    7c29:	mov    0x358(%rsp),%rdi
    7c31:	call   7c36 <botlish_fn_18+0x6a1e>
			7c32: R_X86_64_PLT32	botlish_fn_17-0x4
    7c36:	test   %rax,%rax
    7c39:	mov    %rax,%rdx
    7c3c:	je     7f4e <botlish_fn_18+0x6d36>
    7c42:	mov    0x410(%rsp),%rsi
    7c4a:	mov    0x358(%rsp),%rdi
    7c52:	call   7c57 <botlish_fn_18+0x6a3f>
			7c53: R_X86_64_PLT32	rt_mv_push-0x4
    7c57:	mov    0x400(%rsp),%rcx
    7c5f:	jmp    188c <botlish_fn_18+0x674>
    7c64:	mov    0x400(%rsp),%rcx
    7c6c:	mov    0x18(%rcx),%rax
    7c70:	test   %rax,%rax
    7c73:	je     816b <botlish_fn_18+0x6f53>
    7c79:	mov    0x400(%rsp),%rcx
    7c81:	mov    0x10(%rcx),%rax
    7c85:	movq   $0x1,0x10(%rax)
    7c8d:	mov    0x358(%rsp),%rdi
    7c95:	mov    0x10(%rdi),%rax
    7c99:	mov    0x110(%rax),%rbx
    7ca0:	mov    %rbx,0x28(%rsp)
    7ca5:	movq   $0x3,0x30(%rsp)
    7cae:	mov    0x3e8(%rsp),%rdx
    7cb6:	test   $0x1,%rdx
    7cbd:	jne    7cd0 <botlish_fn_18+0x6ab8>
    7cc3:	mov    0x3e0(%rsp),%rdx
    7ccb:	jmp    7cf2 <botlish_fn_18+0x6ada>
    7cd0:	mov    0x3e8(%rsp),%rdx
    7cd8:	mov    %rdx,%rcx
    7cdb:	add    $0x2,%rcx
    7cdf:	seto   %al
    7ce2:	test   %al,%al
    7ce4:	je     7d0a <botlish_fn_18+0x6af2>
    7cea:	mov    0x3e0(%rsp),%rdx
    7cf2:	mov    0x3e8(%rsp),%rsi
    7cfa:	mov    0x358(%rsp),%rdi
    7d02:	call   7d07 <botlish_fn_18+0x6aef>
			7d03: R_X86_64_PLT32	rt_int_add-0x4
    7d07:	mov    %rax,%rcx
    7d0a:	mov    %rcx,0x30(%rsp)
    7d0f:	mov    0x3e8(%rsp),%rdx
    7d17:	mov    %rbx,%rsi
    7d1a:	mov    0x358(%rsp),%rdi
    7d22:	call   7d27 <botlish_fn_18+0x6b0f>
			7d23: R_X86_64_PLT32	botlish_fn_17-0x4
    7d27:	test   %rax,%rax
    7d2a:	mov    %rax,%rdx
    7d2d:	je     7f4e <botlish_fn_18+0x6d36>
    7d33:	mov    0x410(%rsp),%rsi
    7d3b:	mov    0x358(%rsp),%rdi
    7d43:	call   7d48 <botlish_fn_18+0x6b30>
			7d44: R_X86_64_PLT32	rt_mv_push-0x4
    7d48:	mov    0x400(%rsp),%rcx
    7d50:	jmp    188c <botlish_fn_18+0x674>
    7d55:	mov    0x400(%rsp),%rcx
    7d5d:	jmp    188c <botlish_fn_18+0x674>
    7d62:	mov    0x410(%rsp),%rsi
    7d6a:	mov    0x358(%rsp),%rdi
    7d72:	call   7d77 <botlish_fn_18+0x6b5f>
			7d73: R_X86_64_PLT32	rt_mv_to_list-0x4
    7d77:	mov    %rax,(%rsp)
    7d7b:	mov    %rax,%r12
    7d7e:	mov    %r12,%rsi
    7d81:	mov    0x358(%rsp),%rdi
    7d89:	call   7d8e <botlish_fn_18+0x6b76>
			7d8a: R_X86_64_PLT32	rt_list_len-0x4
    7d8e:	mov    %rax,%rbx
    7d91:	mov    %rbx,0x8(%rsp)
    7d96:	movq   $0x1,0x10(%rsp)
    7d9f:	xor    %rdx,%rdx
    7da2:	mov    0x358(%rsp),%rdi
    7daa:	mov    %rdx,%rsi
    7dad:	call   7db2 <botlish_fn_18+0x6b9a>
			7dae: R_X86_64_PLT32	rt_list_new-0x4
    7db2:	test   %rax,%rax
    7db5:	je     7f4e <botlish_fn_18+0x6d36>
    7dbb:	mov    %rax,0x18(%rsp)
    7dc0:	mov    %rax,%r14
    7dc3:	mov    $0x1,%esi
    7dc8:	mov    %rsi,%r13
    7dcb:	mov    %rsi,%rax
    7dce:	and    %rbx,%rax
    7dd1:	mov    %rsi,%r13
    7dd4:	test   $0x1,%rax
    7dda:	jne    7e08 <botlish_fn_18+0x6bf0>
    7de0:	mov    %rbx,%rdx
    7de3:	mov    %r13,%rsi
    7de6:	mov    0x358(%rsp),%rdi
    7dee:	call   7df3 <botlish_fn_18+0x6bdb>
			7def: R_X86_64_PLT32	rt_int_cmp-0x4
    7df3:	mov    $0x2,%ecx
    7df8:	test   %rax,%rax
    7dfb:	cmovl  0x38d(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    7e03:	jmp    7e1b <botlish_fn_18+0x6c03>
    7e08:	mov    $0x2,%ecx
    7e0d:	mov    %r13,%rsi
    7e10:	cmp    %rbx,%rsi
    7e13:	cmovl  0x375(%rip),%rcx        # 8190 <botlish_fn_18+0x6f78>
    7e1b:	cmp    $0x6,%rcx
    7e1f:	je     7e98 <botlish_fn_18+0x6c80>
    7e25:	lea    0x168(%rsp),%rcx
    7e2d:	movq   $0x0,0x168(%rsp)
    7e39:	mov    %r14,%rax
    7e3c:	mov    %rax,0x170(%rsp)
    7e44:	mov    $0x1,%esi
    7e49:	mov    $0x2,%edx
    7e4e:	mov    0x358(%rsp),%rdi
    7e56:	call   7e5b <botlish_fn_18+0x6c43>
			7e57: R_X86_64_PLT32	rt_construct-0x4
    7e5b:	test   %rax,%rax
    7e5e:	je     7f4e <botlish_fn_18+0x6d36>
    7e64:	mov    0x420(%rsp),%rbx
    7e6c:	mov    0x428(%rsp),%r12
    7e74:	mov    0x430(%rsp),%r13
    7e7c:	mov    0x438(%rsp),%r14
    7e84:	mov    0x440(%rsp),%r15
    7e8c:	add    $0x450,%rsp
    7e93:	mov    %rbp,%rsp
    7e96:	pop    %rbp
    7e97:	ret
    7e98:	mov    %r13,%rsi
    7e9b:	test   $0x1,%rsi
    7ea2:	je     7ebf <botlish_fn_18+0x6ca7>
    7ea8:	mov    0x8(%r12),%rdx
    7ead:	mov    %r13,%rsi
    7eb0:	mov    %rsi,%rcx
    7eb3:	sar    $1,%rcx
    7eb6:	cmp    %rdx,%rcx
    7eb9:	jb     7ee0 <botlish_fn_18+0x6cc8>
    7ebf:	mov    %r13,%rdx
    7ec2:	mov    %r12,%rsi
    7ec5:	mov    0x358(%rsp),%rdi
    7ecd:	call   7ed2 <botlish_fn_18+0x6cba>
			7ece: R_X86_64_PLT32	rt_list_get-0x4
    7ed2:	test   %rax,%rax
    7ed5:	je     7f4e <botlish_fn_18+0x6d36>
    7edb:	jmp    7ee9 <botlish_fn_18+0x6cd1>
    7ee0:	mov    0x10(%r12),%r8
    7ee5:	mov    (%r8,%rcx,8),%rax
    7ee9:	mov    %rax,0x20(%rsp)
    7eee:	lea    0x148(%rsp),%rcx
    7ef6:	movq   $0x0,0x148(%rsp)
    7f02:	mov    %r14,%rdx
    7f05:	mov    %rdx,0x150(%rsp)
    7f0d:	movq   $0x2,0x158(%rsp)
    7f19:	mov    %rax,0x160(%rsp)
    7f21:	mov    $0x3,%r14d
    7f27:	mov    $0x4,%edx
    7f2c:	mov    %r14,%rsi
    7f2f:	mov    0x358(%rsp),%rdi
    7f37:	call   7f3c <botlish_fn_18+0x6d24>
			7f38: R_X86_64_PLT32	rt_construct-0x4
    7f3c:	mov    %r14,%rdx
    7f3f:	mov    %rax,%r14
    7f42:	mov    %rax,%rcx
    7f45:	test   %rcx,%rax
    7f48:	jne    7f85 <botlish_fn_18+0x6d6d>
    7f4e:	xor    %rax,%rax
    7f51:	mov    0x420(%rsp),%rbx
    7f59:	mov    0x428(%rsp),%r12
    7f61:	mov    0x430(%rsp),%r13
    7f69:	mov    0x438(%rsp),%r14
    7f71:	mov    0x440(%rsp),%r15
    7f79:	add    $0x450,%rsp
    7f80:	mov    %rbp,%rsp
    7f83:	pop    %rbp
    7f84:	ret
    7f85:	mov    %r14,%rax
    7f88:	mov    %rax,0x18(%rsp)
    7f8d:	movq   $0x3,0x20(%rsp)
    7f96:	mov    %r13,%rsi
    7f99:	test   $0x1,%rsi
    7fa0:	jne    7fae <botlish_fn_18+0x6d96>
    7fa6:	mov    %r13,%rsi
    7fa9:	jmp    7fd6 <botlish_fn_18+0x6dbe>
    7fae:	mov    %r13,%rsi
    7fb1:	mov    %rsi,%rax
    7fb4:	add    $0x2,%rax
    7fb8:	seto   %cl
    7fbb:	test   %cl,%cl
    7fbd:	je     7fcb <botlish_fn_18+0x6db3>
    7fc3:	mov    %r13,%rsi
    7fc6:	jmp    7fd6 <botlish_fn_18+0x6dbe>
    7fcb:	mov    %rax,%rsi
    7fce:	mov    %rax,%r13
    7fd1:	jmp    7fe9 <botlish_fn_18+0x6dd1>
    7fd6:	mov    0x358(%rsp),%rdi
    7fde:	call   7fe3 <botlish_fn_18+0x6dcb>
			7fdf: R_X86_64_PLT32	rt_int_add-0x4
    7fe3:	mov    %rax,%rsi
    7fe6:	mov    %rax,%r13
    7fe9:	mov    %rsi,0x10(%rsp)
    7fee:	mov    %r13,%rsi
    7ff1:	jmp    7dcb <botlish_fn_18+0x6bb3>
    7ff6:	mov    $0x3,%ecx
    7ffb:	mov    0x400(%rsp),%rsi
    8003:	mov    0x358(%rsp),%rdi
    800b:	mov    %rcx,%rdx
    800e:	call   8013 <botlish_fn_18+0x6dfb>
			800f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    8013:	jmp    1868 <botlish_fn_18+0x650>
    8018:	mov    0x390(%rsp),%rcx
    8020:	mov    0x408(%rsp),%rsi
    8028:	mov    0x358(%rsp),%rdi
    8030:	call   8035 <botlish_fn_18+0x6e1d>
			8031: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    8035:	jmp    1d66 <botlish_fn_18+0xb4e>
    803a:	mov    %r12,%rdx
    803d:	mov    0x400(%rsp),%rsi
    8045:	mov    0x358(%rsp),%rdi
    804d:	call   8052 <botlish_fn_18+0x6e3a>
			804e: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    8052:	jmp    1dfc <botlish_fn_18+0xbe4>
    8057:	mov    $0x1,%edx
    805c:	mov    0x400(%rsp),%rsi
    8064:	mov    0x358(%rsp),%rdi
    806c:	call   8071 <botlish_fn_18+0x6e59>
			806d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    8071:	jmp    1fb0 <botlish_fn_18+0xd98>
    8076:	mov    $0x7,%edx
    807b:	mov    0x370(%rsp),%rcx
    8083:	mov    0x400(%rsp),%rsi
    808b:	mov    0x358(%rsp),%rdi
    8093:	call   8098 <botlish_fn_18+0x6e80>
			8094: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    8098:	jmp    3d6a <botlish_fn_18+0x2b52>
    809d:	mov    0x390(%rsp),%rcx
    80a5:	mov    0x408(%rsp),%rsi
    80ad:	mov    0x358(%rsp),%rdi
    80b5:	call   80ba <botlish_fn_18+0x6ea2>
			80b6: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    80ba:	jmp    433d <botlish_fn_18+0x3125>
    80bf:	mov    0x3e0(%rsp),%rdx
    80c7:	mov    0x400(%rsp),%rsi
    80cf:	mov    0x358(%rsp),%rdi
    80d7:	call   80dc <botlish_fn_18+0x6ec4>
			80d8: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    80dc:	jmp    43d5 <botlish_fn_18+0x31bd>
    80e1:	mov    $0x1,%edx
    80e6:	mov    0x400(%rsp),%rsi
    80ee:	mov    0x358(%rsp),%rdi
    80f6:	call   80fb <botlish_fn_18+0x6ee3>
			80f7: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    80fb:	jmp    457e <botlish_fn_18+0x3366>
    8100:	mov    $0x7,%edx
    8105:	mov    0x370(%rsp),%rcx
    810d:	mov    0x400(%rsp),%rsi
    8115:	mov    0x358(%rsp),%rdi
    811d:	call   8122 <botlish_fn_18+0x6f0a>
			811e: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    8122:	jmp    79c4 <botlish_fn_18+0x67ac>
    8127:	mov    $0x1,%edx
    812c:	mov    %rsi,%r12
    812f:	mov    %r12,%rcx
    8132:	mov    0x400(%rsp),%rsi
    813a:	mov    0x358(%rsp),%rdi
    8142:	call   8147 <botlish_fn_18+0x6f2f>
			8143: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    8147:	jmp    7ab6 <botlish_fn_18+0x689e>
    814c:	mov    $0x5,%edx
    8151:	mov    0x400(%rsp),%rsi
    8159:	mov    0x358(%rsp),%rdi
    8161:	call   8166 <botlish_fn_18+0x6f4e>
			8162: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    8166:	jmp    7ba9 <botlish_fn_18+0x6991>
    816b:	mov    $0x5,%edx
    8170:	mov    $0x1,%ecx
    8175:	mov    0x400(%rsp),%rsi
    817d:	mov    0x358(%rsp),%rdi
    8185:	call   818a <botlish_fn_18+0x6f72>
			8186: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    818a:	jmp    7c8d <botlish_fn_18+0x6a75>
    818f:	add    %al,(%rsi)
    8191:	add    %al,(%rax)
    8193:	add    %al,(%rax)
    8195:	add    %al,(%rax)
	...

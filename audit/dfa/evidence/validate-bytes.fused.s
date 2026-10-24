<botlish_fn_19>:
    1388:	push   %rbp
    1389:	mov    %rsp,%rbp
    138c:	sub    $0x4d0,%rsp
    1393:	mov    %rbx,0x4a0(%rsp)
    139b:	mov    %r12,0x4a8(%rsp)
    13a3:	mov    %r13,0x4b0(%rsp)
    13ab:	mov    %r14,0x4b8(%rsp)
    13b3:	mov    %r15,0x4c0(%rsp)
    13bb:	mov    %rdi,0x3c0(%rsp)
    13c3:	movq   $0x0,0x10(%rsp)
    13cc:	movq   $0x0,0x18(%rsp)
    13d5:	movq   $0x0,0x20(%rsp)
    13de:	movq   $0x0,0x28(%rsp)
    13e7:	movq   $0x0,0x30(%rsp)
    13f0:	movq   $0x0,0x38(%rsp)
    13f9:	movq   $0x0,0x40(%rsp)
    1402:	movq   $0x0,0x48(%rsp)
    140b:	movq   $0x0,0x90(%rsp)
    1417:	movq   $0x0,0x98(%rsp)
    1423:	movq   $0x0,0xa0(%rsp)
    142f:	movq   $0x0,0xa8(%rsp)
    143b:	movq   $0x0,0xb0(%rsp)
    1447:	movq   $0x0,0xb8(%rsp)
    1453:	movq   $0x0,0xc0(%rsp)
    145f:	movq   $0x0,0xc8(%rsp)
    146b:	movq   $0x0,0xd0(%rsp)
    1477:	movq   $0x0,0xd8(%rsp)
    1483:	movq   $0x0,0xe0(%rsp)
    148f:	mov    %rdx,(%rsp)
    1493:	mov    %rdx,0x3d0(%rsp)
    149b:	mov    %rcx,0x8(%rsp)
    14a0:	mov    %rcx,0x3d8(%rsp)
    14a8:	movq   $0xa,0x60(%rsp)
    14b1:	movq   $0xa,0x68(%rsp)
    14ba:	movq   $0xa,0x70(%rsp)
    14c3:	movq   $0xa,0x78(%rsp)
    14cc:	movq   $0xa,0x80(%rsp)
    14d8:	movq   $0xa,0x88(%rsp)
    14e4:	movq   $0xa,0x50(%rsp)
    14ed:	movq   $0xa,0x58(%rsp)
    14f6:	mov    %rsi,0x60(%rsp)
    14fb:	mov    %rsi,0x3c8(%rsp)
    1503:	mov    0x3c8(%rsp),%rsi
    150b:	mov    0x3c0(%rsp),%rdi
    1513:	call   1518 <botlish_fn_19+0x190>
			1514: R_X86_64_PLT32	rt_list_len-0x4
    1518:	mov    %rax,0x68(%rsp)
    151d:	mov    %rax,0x490(%rsp)
    1525:	mov    $0x1,%esi
    152a:	mov    %rsi,0x418(%rsp)
    1532:	movq   $0x1,0x70(%rsp)
    153b:	mov    $0xa,%esi
    1540:	mov    %rsi,0x400(%rsp)
    1548:	mov    0x490(%rsp),%rbx
    1550:	mov    0x418(%rsp),%rsi
    1558:	mov    0x400(%rsp),%rax
    1560:	mov    %rax,0x408(%rsp)
    1568:	mov    %rax,0x410(%rsp)
    1570:	mov    %rsi,%rax
    1573:	and    %rbx,%rax
    1576:	mov    %rsi,0x418(%rsp)
    157e:	test   $0x1,%rax
    1584:	jne    15bf <botlish_fn_19+0x237>
    158a:	mov    %rbx,%rdx
    158d:	mov    0x418(%rsp),%rsi
    1595:	mov    0x3c0(%rsp),%rdi
    159d:	call   15a2 <botlish_fn_19+0x21a>
			159e: R_X86_64_PLT32	rt_int_cmp-0x4
    15a2:	mov    %rbx,0x490(%rsp)
    15aa:	mov    $0x2,%ecx
    15af:	test   %rax,%rax
    15b2:	cmovl  0x860e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    15ba:	jmp    15e7 <botlish_fn_19+0x25f>
    15bf:	mov    %rbx,0x490(%rsp)
    15c7:	mov    $0x2,%ecx
    15cc:	mov    0x490(%rsp),%rax
    15d4:	mov    0x418(%rsp),%rsi
    15dc:	cmp    %rax,%rsi
    15df:	cmovl  0x85e1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    15e7:	cmp    $0x6,%rcx
    15eb:	je     160e <botlish_fn_19+0x286>
    15f1:	mov    $0xffffffffffffffff,%rdx
    15f8:	movq   $0xffffffffffffffff,0x50(%rsp)
    1601:	mov    %rdx,0x3e8(%rsp)
    1609:	jmp    189b <botlish_fn_19+0x513>
    160e:	mov    0x418(%rsp),%rsi
    1616:	test   $0x1,%rsi
    161d:	je     1646 <botlish_fn_19+0x2be>
    1623:	mov    0x3c8(%rsp),%rcx
    162b:	mov    0x8(%rcx),%rcx
    162f:	mov    0x418(%rsp),%rsi
    1637:	mov    %rsi,%rax
    163a:	sar    $1,%rax
    163d:	cmp    %rcx,%rax
    1640:	jb     1684 <botlish_fn_19+0x2fc>
    1646:	mov    0x418(%rsp),%rdx
    164e:	mov    0x3c8(%rsp),%rsi
    1656:	mov    0x3c0(%rsp),%rdi
    165e:	call   1663 <botlish_fn_19+0x2db>
			165f: R_X86_64_PLT32	rt_list_get-0x4
    1663:	mov    %rax,%rcx
    1666:	mov    %rax,0x410(%rsp)
    166e:	test   %rcx,%rax
    1671:	je     1816 <botlish_fn_19+0x48e>
    1677:	mov    0x410(%rsp),%rax
    167f:	jmp    169c <botlish_fn_19+0x314>
    1684:	mov    0x3c8(%rsp),%rcx
    168c:	mov    0x10(%rcx),%rcx
    1690:	mov    (%rcx,%rax,8),%rax
    1694:	mov    %rax,0x410(%rsp)
    169c:	mov    %rax,0x78(%rsp)
    16a1:	mov    0x410(%rsp),%rsi
    16a9:	mov    0x3c0(%rsp),%rdi
    16b1:	call   16b6 <botlish_fn_19+0x32e>
			16b2: R_X86_64_PLT32	rt_list_len-0x4
    16b6:	mov    %rax,0x408(%rsp)
    16be:	mov    %rax,0x80(%rsp)
    16c6:	movq   $0x1,0x88(%rsp)
    16d2:	mov    0x408(%rsp),%rax
    16da:	test   $0x1,%rax
    16e0:	jne    1715 <botlish_fn_19+0x38d>
    16e6:	mov    $0x1,%esi
    16eb:	mov    0x408(%rsp),%rdx
    16f3:	mov    0x3c0(%rsp),%rdi
    16fb:	call   1700 <botlish_fn_19+0x378>
			16fc: R_X86_64_PLT32	rt_int_cmp-0x4
    1700:	mov    $0x2,%ecx
    1705:	test   %rax,%rax
    1708:	cmovl  0x84b8(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1710:	jmp    172e <botlish_fn_19+0x3a6>
    1715:	mov    $0x2,%ecx
    171a:	mov    0x408(%rsp),%rax
    1722:	cmp    $0x1,%rax
    1726:	cmovg  0x849a(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    172e:	cmp    $0x6,%rcx
    1732:	je     17de <botlish_fn_19+0x456>
    1738:	mov    $0x3,%edx
    173d:	movq   $0x3,0x40(%rsp)
    1746:	mov    0x418(%rsp),%rsi
    174e:	test   $0x1,%rsi
    1755:	jne    1768 <botlish_fn_19+0x3e0>
    175b:	mov    0x418(%rsp),%rsi
    1763:	jmp    179f <botlish_fn_19+0x417>
    1768:	mov    0x418(%rsp),%rsi
    1770:	mov    %rsi,%rcx
    1773:	add    $0x2,%rcx
    1777:	seto   %al
    177a:	test   %al,%al
    177c:	je     178f <botlish_fn_19+0x407>
    1782:	mov    0x418(%rsp),%rsi
    178a:	jmp    179f <botlish_fn_19+0x417>
    178f:	mov    %rcx,%rsi
    1792:	mov    %rcx,0x418(%rsp)
    179a:	jmp    17b7 <botlish_fn_19+0x42f>
    179f:	mov    0x3c0(%rsp),%rdi
    17a7:	call   17ac <botlish_fn_19+0x424>
			17a8: R_X86_64_PLT32	rt_int_add-0x4
    17ac:	mov    %rax,%rsi
    17af:	mov    %rax,0x418(%rsp)
    17b7:	mov    %rsi,0x70(%rsp)
    17bc:	mov    $0x1,%esi
    17c1:	mov    %rsi,0x400(%rsp)
    17c9:	mov    0x490(%rsp),%rbx
    17d1:	mov    0x418(%rsp),%rsi
    17d9:	jmp    1570 <botlish_fn_19+0x1e8>
    17de:	mov    0x410(%rsp),%rax
    17e6:	mov    0x8(%rax),%rcx
    17ea:	test   %rcx,%rcx
    17ed:	jne    186a <botlish_fn_19+0x4e2>
    17f3:	mov    $0x1,%edx
    17f8:	mov    0x410(%rsp),%rsi
    1800:	mov    0x3c0(%rsp),%rdi
    1808:	call   180d <botlish_fn_19+0x485>
			1809: R_X86_64_PLT32	rt_list_get-0x4
    180d:	test   %rax,%rax
    1810:	jne    1862 <botlish_fn_19+0x4da>
    1816:	mov    0x3c0(%rsp),%rdi
    181e:	call   1823 <botlish_fn_19+0x49b>
			181f: R_X86_64_PLT32	rt_co_failed-0x4
    1823:	mov    %rax,0x58(%rsp)
    1828:	mov    %rax,%rsi
    182b:	mov    0x3c0(%rsp),%rdi
    1833:	call   1838 <botlish_fn_19+0x4b0>
			1834: R_X86_64_PLT32	rt_co_resume0-0x4
    1838:	test   %rax,%rax
    183b:	je     9a02 <botlish_fn_19+0x867a>
    1841:	mov    0x3c0(%rsp),%rdi
    1849:	mov    0x10(%rdi),%r11
    184d:	mov    0x48(%r11),%rsi
    1851:	mov    0x1b8(%r11),%rdx
    1858:	call   185d <botlish_fn_19+0x4d5>
			1859: R_X86_64_PLT32	rt_raise-0x4
    185d:	jmp    9a02 <botlish_fn_19+0x867a>
    1862:	mov    %rax,%rdx
    1865:	jmp    1879 <botlish_fn_19+0x4f1>
    186a:	mov    0x410(%rsp),%rax
    1872:	mov    0x10(%rax),%rax
    1876:	mov    (%rax),%rdx
    1879:	mov    %rdx,0x50(%rsp)
    187e:	mov    $0x1,%ecx
    1883:	mov    %rcx,0x3e8(%rsp)
    188b:	mov    0x3e8(%rsp),%rax
    1893:	mov    %rax,0x400(%rsp)
    189b:	mov    %rdx,0x10(%rsp)
    18a0:	mov    %rdx,%rbx
    18a3:	movq   $0xa,0xa0(%rsp)
    18af:	movq   $0xa,0xa8(%rsp)
    18bb:	movq   $0xa,0x90(%rsp)
    18c7:	movq   $0xa,0x98(%rsp)
    18d3:	mov    0x3d0(%rsp),%rsi
    18db:	mov    %rbx,0x3f8(%rsp)
    18e3:	mov    %rsi,0xa0(%rsp)
    18eb:	movq   $0x1,0x28(%rsp)
    18f4:	mov    $0x3,%ecx
    18f9:	mov    %rcx,0x488(%rsp)
    1901:	movq   $0x3,0x30(%rsp)
    190a:	lea    0x138(%rsp),%rdx
    1912:	movq   $0x1,0x138(%rsp)
    191e:	movq   $0x3,0x140(%rsp)
    192a:	mov    $0x2,%esi
    192f:	mov    0x3c0(%rsp),%rdi
    1937:	call   193c <botlish_fn_19+0x5b4>
			1938: R_X86_64_PLT32	rt_list_new-0x4
    193c:	test   %rax,%rax
    193f:	jne    19c2 <botlish_fn_19+0x63a>
    1945:	mov    0x3c0(%rsp),%rdi
    194d:	call   1952 <botlish_fn_19+0x5ca>
			194e: R_X86_64_PLT32	rt_co_failed-0x4
    1952:	mov    %rax,0x98(%rsp)
    195a:	mov    %rax,%rsi
    195d:	mov    0x3c0(%rsp),%rdi
    1965:	call   196a <botlish_fn_19+0x5e2>
			1966: R_X86_64_PLT32	rt_co_resume0-0x4
    196a:	test   %rax,%rax
    196d:	je     198f <botlish_fn_19+0x607>
    1973:	mov    0x3c0(%rsp),%rdi
    197b:	mov    0x10(%rdi),%rax
    197f:	mov    0x48(%rax),%rsi
    1983:	mov    0x1b8(%rax),%rdx
    198a:	call   198f <botlish_fn_19+0x607>
			198b: R_X86_64_PLT32	rt_raise-0x4
    198f:	mov    0x3c0(%rsp),%rdi
    1997:	call   199c <botlish_fn_19+0x614>
			1998: R_X86_64_PLT32	rt_declared_error-0x4
    199c:	cmp    $0x6,%rax
    19a0:	je     9a02 <botlish_fn_19+0x867a>
    19a6:	mov    0x3c0(%rsp),%rdi
    19ae:	call   19b3 <botlish_fn_19+0x62b>
			19af: R_X86_64_PLT32	rt_declared_error-0x4
    19b3:	cmp    $0x7,%rax
    19b7:	jne    9a02 <botlish_fn_19+0x867a>
    19bd:	jmp    9a02 <botlish_fn_19+0x867a>
    19c2:	mov    %rax,0x28(%rsp)
    19c7:	mov    %rax,%rsi
    19ca:	mov    0x3c0(%rsp),%rdi
    19d2:	call   19d7 <botlish_fn_19+0x64f>
			19d3: R_X86_64_PLT32	rt_mv_from_list-0x4
    19d7:	mov    %rax,%rcx
    19da:	mov    %rax,0x480(%rsp)
    19e2:	mov    %rcx,0xa8(%rsp)
    19ea:	movq   $0x6,0x90(%rsp)
    19f6:	movq   $0x3,(%rsp)
    19fe:	mov    %rbx,%rdx
    1a01:	mov    0x488(%rsp),%rsi
    1a09:	mov    0x3c0(%rsp),%rdi
    1a11:	call   1a16 <botlish_fn_19+0x68e>
			1a12: R_X86_64_PLT32	rt_mutarray_create-0x4
    1a16:	mov    %rax,%rcx
    1a19:	test   %rcx,%rcx
    1a1c:	je     9a02 <botlish_fn_19+0x867a>
    1a22:	mov    %rcx,(%rsp)
    1a26:	mov    %rcx,0x478(%rsp)
    1a2e:	movq   $0x3,0x10(%rsp)
    1a37:	mov    $0x1,%edx
    1a3c:	movq   $0x1,0x18(%rsp)
    1a45:	mov    0x488(%rsp),%rsi
    1a4d:	mov    0x3c0(%rsp),%rdi
    1a55:	call   1a5a <botlish_fn_19+0x6d2>
			1a56: R_X86_64_PLT32	rt_mutarray_create-0x4
    1a5a:	mov    %rax,%rdx
    1a5d:	test   %rdx,%rdx
    1a60:	je     9a02 <botlish_fn_19+0x867a>
    1a66:	mov    %rdx,0x10(%rsp)
    1a6b:	mov    %rdx,0x470(%rsp)
    1a73:	movq   $0x3,0x18(%rsp)
    1a7c:	mov    $0x1,%edx
    1a81:	movq   $0x1,0x20(%rsp)
    1a8a:	mov    0x488(%rsp),%rsi
    1a92:	mov    0x3c0(%rsp),%rdi
    1a9a:	call   1a9f <botlish_fn_19+0x717>
			1a9b: R_X86_64_PLT32	rt_mutarray_create-0x4
    1a9f:	mov    %rax,%rcx
    1aa2:	test   %rcx,%rcx
    1aa5:	je     9a02 <botlish_fn_19+0x867a>
    1aab:	mov    %rcx,0x18(%rsp)
    1ab0:	mov    %rcx,0x468(%rsp)
    1ab8:	movq   $0x3,0x20(%rsp)
    1ac1:	mov    $0x2,%edx
    1ac6:	movq   $0x2,0x28(%rsp)
    1acf:	mov    0x488(%rsp),%rsi
    1ad7:	mov    0x3c0(%rsp),%rdi
    1adf:	call   1ae4 <botlish_fn_19+0x75c>
			1ae0: R_X86_64_PLT32	rt_mutarray_create-0x4
    1ae4:	mov    %rax,%rbx
    1ae7:	test   %rbx,%rbx
    1aea:	mov    %rbx,0x460(%rsp)
    1af2:	je     9a02 <botlish_fn_19+0x867a>
    1af8:	mov    0x460(%rsp),%rbx
    1b00:	mov    %rbx,0x20(%rsp)
    1b05:	mov    $0x1,%ebx
    1b0a:	mov    %rbx,0x3f0(%rsp)
    1b12:	mov    $0x6,%ebx
    1b17:	mov    %rbx,0x420(%rsp)
    1b1f:	mov    $0xffffffffffffffff,%rdx
    1b26:	mov    %rdx,0x458(%rsp)
    1b2e:	mov    $0x7,%ecx
    1b33:	mov    %rcx,0x450(%rsp)
    1b3b:	mov    0x478(%rsp),%rcx
    1b43:	mov    0x10(%rcx),%r10
    1b47:	mov    (%r10),%rsi
    1b4a:	mov    %rsi,0x28(%rsp)
    1b4f:	mov    %rsi,0x448(%rsp)
    1b57:	mov    0x448(%rsp),%rsi
    1b5f:	mov    0x3c0(%rsp),%rdi
    1b67:	call   1b6c <botlish_fn_19+0x7e4>
			1b68: R_X86_64_PLT32	botlish_fn_13-0x4
    1b6c:	cmp    $0x6,%rax
    1b70:	je     952b <botlish_fn_19+0x81a3>
    1b76:	mov    0x470(%rsp),%rdx
    1b7e:	mov    0x10(%rdx),%rax
    1b82:	mov    (%rax),%rcx
    1b85:	mov    %rcx,0x30(%rsp)
    1b8a:	mov    %rcx,0x440(%rsp)
    1b92:	mov    0x448(%rsp),%rsi
    1b9a:	test   $0x1,%rsi
    1ba1:	jne    1bd9 <botlish_fn_19+0x851>
    1ba7:	mov    0x458(%rsp),%rdx
    1baf:	mov    0x448(%rsp),%rsi
    1bb7:	mov    0x3c0(%rsp),%rdi
    1bbf:	call   1bc4 <botlish_fn_19+0x83c>
			1bc0: R_X86_64_PLT32	rt_int_cmp-0x4
    1bc4:	mov    $0x2,%ecx
    1bc9:	test   %rax,%rax
    1bcc:	cmove  0x7ff4(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1bd4:	jmp    1bf2 <botlish_fn_19+0x86a>
    1bd9:	mov    $0x2,%ecx
    1bde:	mov    0x448(%rsp),%rsi
    1be6:	cmp    $0xffffffffffffffff,%rsi
    1bea:	cmove  0x7fd6(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1bf2:	cmp    $0x6,%rcx
    1bf6:	je     8e1c <botlish_fn_19+0x7a94>
    1bfc:	movq   $0xa,0xc0(%rsp)
    1c08:	movq   $0xa,0xc8(%rsp)
    1c14:	movq   $0xa,0xd0(%rsp)
    1c20:	movq   $0xa,0xd8(%rsp)
    1c2c:	movq   $0xa,0xe0(%rsp)
    1c38:	movq   $0xa,0xb0(%rsp)
    1c44:	movq   $0xa,0xb8(%rsp)
    1c50:	mov    0x448(%rsp),%rsi
    1c58:	test   $0x1,%rsi
    1c5f:	jne    1c94 <botlish_fn_19+0x90c>
    1c65:	mov    $0xbb,%edx
    1c6a:	mov    0x448(%rsp),%rsi
    1c72:	mov    0x3c0(%rsp),%rdi
    1c7a:	call   1c7f <botlish_fn_19+0x8f7>
			1c7b: R_X86_64_PLT32	rt_int_cmp-0x4
    1c7f:	mov    $0x2,%ecx
    1c84:	test   %rax,%rax
    1c87:	cmovl  0x7f39(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1c8f:	jmp    1cb0 <botlish_fn_19+0x928>
    1c94:	mov    $0x2,%ecx
    1c99:	mov    0x448(%rsp),%rsi
    1ca1:	cmp    $0xbb,%rsi
    1ca8:	cmovl  0x7f18(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1cb0:	cmp    $0x6,%rcx
    1cb4:	je     1f45 <botlish_fn_19+0xbbd>
    1cba:	mov    0x448(%rsp),%rsi
    1cc2:	test   $0x1,%rsi
    1cc9:	jne    1cfe <botlish_fn_19+0x976>
    1ccf:	mov    $0xe9,%edx
    1cd4:	mov    0x448(%rsp),%rsi
    1cdc:	mov    0x3c0(%rsp),%rdi
    1ce4:	call   1ce9 <botlish_fn_19+0x961>
			1ce5: R_X86_64_PLT32	rt_int_cmp-0x4
    1ce9:	mov    $0x2,%ecx
    1cee:	test   %rax,%rax
    1cf1:	cmovl  0x7ecf(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1cf9:	jmp    1d1a <botlish_fn_19+0x992>
    1cfe:	mov    $0x2,%ecx
    1d03:	mov    0x448(%rsp),%rsi
    1d0b:	cmp    $0xe9,%rsi
    1d12:	cmovl  0x7eae(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1d1a:	cmp    $0x6,%rcx
    1d1e:	je     1ec6 <botlish_fn_19+0xb3e>
    1d24:	mov    0x448(%rsp),%rsi
    1d2c:	test   $0x1,%rsi
    1d33:	jne    1d68 <botlish_fn_19+0x9e0>
    1d39:	mov    $0xf9,%edx
    1d3e:	mov    0x448(%rsp),%rsi
    1d46:	mov    0x3c0(%rsp),%rdi
    1d4e:	call   1d53 <botlish_fn_19+0x9cb>
			1d4f: R_X86_64_PLT32	rt_int_cmp-0x4
    1d53:	mov    $0x2,%ecx
    1d58:	test   %rax,%rax
    1d5b:	cmovl  0x7e65(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1d63:	jmp    1d84 <botlish_fn_19+0x9fc>
    1d68:	mov    $0x2,%ecx
    1d6d:	mov    0x448(%rsp),%rsi
    1d75:	cmp    $0xf9,%rsi
    1d7c:	cmovl  0x7e44(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1d84:	cmp    $0x6,%rcx
    1d88:	je     1e83 <botlish_fn_19+0xafb>
    1d8e:	mov    0x448(%rsp),%rsi
    1d96:	test   $0x1,%rsi
    1d9d:	jne    1dd2 <botlish_fn_19+0xa4a>
    1da3:	mov    $0xfb,%edx
    1da8:	mov    0x448(%rsp),%rsi
    1db0:	mov    0x3c0(%rsp),%rdi
    1db8:	call   1dbd <botlish_fn_19+0xa35>
			1db9: R_X86_64_PLT32	rt_int_cmp-0x4
    1dbd:	mov    $0x2,%ecx
    1dc2:	test   %rax,%rax
    1dc5:	cmovl  0x7dfb(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1dcd:	jmp    1dee <botlish_fn_19+0xa66>
    1dd2:	mov    $0x2,%ecx
    1dd7:	mov    0x448(%rsp),%rsi
    1ddf:	cmp    $0xfb,%rsi
    1de6:	cmovl  0x7dda(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1dee:	cmp    $0x6,%rcx
    1df2:	je     1e79 <botlish_fn_19+0xaf1>
    1df8:	mov    0x448(%rsp),%rsi
    1e00:	test   $0x1,%rsi
    1e07:	jne    1e3c <botlish_fn_19+0xab4>
    1e0d:	mov    $0xfd,%edx
    1e12:	mov    0x448(%rsp),%rsi
    1e1a:	mov    0x3c0(%rsp),%rdi
    1e22:	call   1e27 <botlish_fn_19+0xa9f>
			1e23: R_X86_64_PLT32	rt_int_cmp-0x4
    1e27:	mov    $0x2,%ecx
    1e2c:	test   %rax,%rax
    1e2f:	cmovl  0x7d91(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1e37:	jmp    1e58 <botlish_fn_19+0xad0>
    1e3c:	mov    $0x2,%ecx
    1e41:	mov    0x448(%rsp),%rsi
    1e49:	cmp    $0xfd,%rsi
    1e50:	cmovl  0x7d70(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1e58:	cmp    $0x6,%rcx
    1e5c:	je     1e6c <botlish_fn_19+0xae4>
    1e62:	mov    $0xd,%ecx
    1e67:	jmp    2151 <botlish_fn_19+0xdc9>
    1e6c:	mov    0x488(%rsp),%rcx
    1e74:	jmp    2151 <botlish_fn_19+0xdc9>
    1e79:	mov    $0xd,%ecx
    1e7e:	jmp    2151 <botlish_fn_19+0xdc9>
    1e83:	mov    0x448(%rsp),%rsi
    1e8b:	mov    %rsi,%rax
    1e8e:	sar    $1,%rax
    1e91:	cmp    $0x75,%rax
    1e95:	jl     1ebc <botlish_fn_19+0xb34>
    1e9b:	cmp    $0x7b,%rax
    1e9f:	jl     1eb2 <botlish_fn_19+0xb2a>
    1ea5:	mov    0x488(%rsp),%rcx
    1ead:	jmp    2151 <botlish_fn_19+0xdc9>
    1eb2:	mov    $0xd,%ecx
    1eb7:	jmp    2151 <botlish_fn_19+0xdc9>
    1ebc:	mov    $0xb,%ecx
    1ec1:	jmp    2151 <botlish_fn_19+0xdc9>
    1ec6:	mov    0x448(%rsp),%rsi
    1ece:	mov    %rsi,%rcx
    1ed1:	sar    $1,%rcx
    1ed4:	cmp    $0x67,%rcx
    1ed8:	jl     1f10 <botlish_fn_19+0xb88>
    1ede:	cmp    $0x6e,%rcx
    1ee2:	jl     1f06 <botlish_fn_19+0xb7e>
    1ee8:	cmp    $0x6f,%rcx
    1eec:	jl     1efc <botlish_fn_19+0xb74>
    1ef2:	mov    $0xd,%ecx
    1ef7:	jmp    2151 <botlish_fn_19+0xdc9>
    1efc:	mov    $0xb,%ecx
    1f01:	jmp    2151 <botlish_fn_19+0xdc9>
    1f06:	mov    $0xd,%ecx
    1f0b:	jmp    2151 <botlish_fn_19+0xdc9>
    1f10:	cmp    $0x5e,%rcx
    1f14:	jl     1f38 <botlish_fn_19+0xbb0>
    1f1a:	cmp    $0x66,%rcx
    1f1e:	jl     1f2e <botlish_fn_19+0xba6>
    1f24:	mov    $0xb,%ecx
    1f29:	jmp    2151 <botlish_fn_19+0xdc9>
    1f2e:	mov    $0xd,%ecx
    1f33:	jmp    2151 <botlish_fn_19+0xdc9>
    1f38:	mov    0x488(%rsp),%rcx
    1f40:	jmp    2151 <botlish_fn_19+0xdc9>
    1f45:	mov    0x448(%rsp),%rsi
    1f4d:	test   $0x1,%rsi
    1f54:	jne    1f89 <botlish_fn_19+0xc01>
    1f5a:	mov    $0x5d,%edx
    1f5f:	mov    0x448(%rsp),%rsi
    1f67:	mov    0x3c0(%rsp),%rdi
    1f6f:	call   1f74 <botlish_fn_19+0xbec>
			1f70: R_X86_64_PLT32	rt_int_cmp-0x4
    1f74:	mov    $0x2,%ecx
    1f79:	test   %rax,%rax
    1f7c:	cmovl  0x7c44(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1f84:	jmp    1fa2 <botlish_fn_19+0xc1a>
    1f89:	mov    $0x2,%ecx
    1f8e:	mov    0x448(%rsp),%rsi
    1f96:	cmp    $0x5d,%rsi
    1f9a:	cmovl  0x7c26(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    1fa2:	cmp    $0x6,%rcx
    1fa6:	je     202e <botlish_fn_19+0xca6>
    1fac:	mov    0x448(%rsp),%rsi
    1fb4:	mov    %rsi,%rcx
    1fb7:	sar    $1,%rcx
    1fba:	cmp    $0x3b,%rcx
    1fbe:	jl     1ff9 <botlish_fn_19+0xc71>
    1fc4:	cmp    $0x5b,%rcx
    1fc8:	jl     1fef <botlish_fn_19+0xc67>
    1fce:	cmp    $0x5c,%rcx
    1fd2:	jl     1fe2 <botlish_fn_19+0xc5a>
    1fd8:	mov    $0xd,%ecx
    1fdd:	jmp    2151 <botlish_fn_19+0xdc9>
    1fe2:	mov    0x488(%rsp),%rcx
    1fea:	jmp    2151 <botlish_fn_19+0xdc9>
    1fef:	mov    $0xd,%ecx
    1ff4:	jmp    2151 <botlish_fn_19+0xdc9>
    1ff9:	cmp    $0x30,%rcx
    1ffd:	jl     2024 <botlish_fn_19+0xc9c>
    2003:	cmp    $0x3a,%rcx
    2007:	jl     201a <botlish_fn_19+0xc92>
    200d:	mov    0x488(%rsp),%rcx
    2015:	jmp    2151 <botlish_fn_19+0xdc9>
    201a:	mov    $0x9,%ecx
    201f:	jmp    2151 <botlish_fn_19+0xdc9>
    2024:	mov    $0xd,%ecx
    2029:	jmp    2151 <botlish_fn_19+0xdc9>
    202e:	mov    0x448(%rsp),%rsi
    2036:	test   $0x1,%rsi
    203d:	jne    2072 <botlish_fn_19+0xcea>
    2043:	mov    $0x47,%edx
    2048:	mov    0x448(%rsp),%rsi
    2050:	mov    0x3c0(%rsp),%rdi
    2058:	call   205d <botlish_fn_19+0xcd5>
			2059: R_X86_64_PLT32	rt_int_cmp-0x4
    205d:	mov    $0x2,%ecx
    2062:	test   %rax,%rax
    2065:	cmovl  0x7b5b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    206d:	jmp    208b <botlish_fn_19+0xd03>
    2072:	mov    $0x2,%ecx
    2077:	mov    0x448(%rsp),%rsi
    207f:	cmp    $0x47,%rsi
    2083:	cmovl  0x7b3d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    208b:	cmp    $0x6,%rcx
    208f:	je     20d8 <botlish_fn_19+0xd50>
    2095:	mov    0x448(%rsp),%rsi
    209d:	mov    %rsi,%rax
    20a0:	sar    $1,%rax
    20a3:	cmp    $0x2c,%rax
    20a7:	jl     20ce <botlish_fn_19+0xd46>
    20ad:	cmp    $0x2d,%rax
    20b1:	jl     20c1 <botlish_fn_19+0xd39>
    20b7:	mov    $0x9,%ecx
    20bc:	jmp    2151 <botlish_fn_19+0xdc9>
    20c1:	mov    0x488(%rsp),%rcx
    20c9:	jmp    2151 <botlish_fn_19+0xdc9>
    20ce:	mov    $0xd,%ecx
    20d3:	jmp    2151 <botlish_fn_19+0xdc9>
    20d8:	mov    0x448(%rsp),%rsi
    20e0:	test   $0x1,%rsi
    20e7:	jne    211c <botlish_fn_19+0xd94>
    20ed:	mov    $0x45,%edx
    20f2:	mov    0x448(%rsp),%rsi
    20fa:	mov    0x3c0(%rsp),%rdi
    2102:	call   2107 <botlish_fn_19+0xd7f>
			2103: R_X86_64_PLT32	rt_int_cmp-0x4
    2107:	mov    $0x2,%ecx
    210c:	test   %rax,%rax
    210f:	cmovl  0x7ab1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2117:	jmp    2135 <botlish_fn_19+0xdad>
    211c:	mov    $0x2,%ecx
    2121:	mov    0x448(%rsp),%rsi
    2129:	cmp    $0x45,%rsi
    212d:	cmovl  0x7a93(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2135:	cmp    $0x6,%rcx
    2139:	je     214c <botlish_fn_19+0xdc4>
    213f:	mov    0x450(%rsp),%rcx
    2147:	jmp    2151 <botlish_fn_19+0xdc9>
    214c:	mov    $0xd,%ecx
    2151:	sar    $1,%rcx
    2154:	cmp    $0x1,%rcx
    2158:	je     34bc <botlish_fn_19+0x2134>
    215e:	cmp    $0x3,%rcx
    2162:	je     29a1 <botlish_fn_19+0x1619>
    2168:	cmp    $0x4,%rcx
    216c:	je     2626 <botlish_fn_19+0x129e>
    2172:	cmp    $0x5,%rcx
    2176:	je     2289 <botlish_fn_19+0xf01>
    217c:	mov    0x448(%rsp),%rsi
    2184:	test   $0x1,%rsi
    218b:	jne    21c3 <botlish_fn_19+0xe3b>
    2191:	mov    0x458(%rsp),%rdx
    2199:	mov    0x448(%rsp),%rsi
    21a1:	mov    0x3c0(%rsp),%rdi
    21a9:	call   21ae <botlish_fn_19+0xe26>
			21aa: R_X86_64_PLT32	rt_int_cmp-0x4
    21ae:	mov    $0x2,%ecx
    21b3:	test   %rax,%rax
    21b6:	cmove  0x7a0a(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    21be:	jmp    21dc <botlish_fn_19+0xe54>
    21c3:	mov    $0x2,%ecx
    21c8:	mov    0x448(%rsp),%rsi
    21d0:	cmp    $0xffffffffffffffff,%rsi
    21d4:	cmove  0x79ec(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    21dc:	cmp    $0x6,%rcx
    21e0:	je     223a <botlish_fn_19+0xeb2>
    21e6:	mov    0x3c0(%rsp),%rdi
    21ee:	mov    0x10(%rdi),%rcx
    21f2:	mov    0x200(%rcx),%rax
    21f9:	mov    0x1f8(%rcx),%rdx
    2200:	lea    0x320(%rsp),%r9
    2208:	mov    %rax,0x320(%rsp)
    2210:	mov    0x448(%rsp),%rsi
    2218:	mov    %rsi,0x328(%rsp)
    2220:	mov    $0x1,%esi
    2225:	mov    $0x8,%ecx
    222a:	mov    $0x2,%r8d
    2230:	call   2235 <botlish_fn_19+0xead>
			2231: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2235:	jmp    32a6 <botlish_fn_19+0x1f1e>
    223a:	mov    0x3c0(%rsp),%rdi
    2242:	mov    0x10(%rdi),%rdi
    2246:	mov    0x200(%rdi),%rsi
    224d:	mov    0x1f0(%rdi),%rdx
    2254:	lea    0x318(%rsp),%r9
    225c:	mov    %rsi,0x318(%rsp)
    2264:	mov    $0x2,%esi
    2269:	mov    $0x1,%r8d
    226f:	mov    0x488(%rsp),%rcx
    2277:	mov    0x3c0(%rsp),%rdi
    227f:	call   2284 <botlish_fn_19+0xefc>
			2280: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2284:	jmp    32a6 <botlish_fn_19+0x1f1e>
    2289:	mov    0x448(%rsp),%rsi
    2291:	test   $0x1,%rsi
    2298:	jne    22cd <botlish_fn_19+0xf45>
    229e:	mov    $0xdd,%edx
    22a3:	mov    0x448(%rsp),%rsi
    22ab:	mov    0x3c0(%rsp),%rdi
    22b3:	call   22b8 <botlish_fn_19+0xf30>
			22b4: R_X86_64_PLT32	rt_int_cmp-0x4
    22b8:	mov    $0x2,%ecx
    22bd:	test   %rax,%rax
    22c0:	cmovl  0x7900(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    22c8:	jmp    22e9 <botlish_fn_19+0xf61>
    22cd:	mov    $0x2,%ecx
    22d2:	mov    0x448(%rsp),%rsi
    22da:	cmp    $0xdd,%rsi
    22e1:	cmovl  0x78df(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    22e9:	cmp    $0x6,%rcx
    22ed:	je     240f <botlish_fn_19+0x1087>
    22f3:	mov    0x448(%rsp),%rsi
    22fb:	test   $0x1,%rsi
    2302:	jne    2337 <botlish_fn_19+0xfaf>
    2308:	mov    $0xe9,%edx
    230d:	mov    0x448(%rsp),%rsi
    2315:	mov    0x3c0(%rsp),%rdi
    231d:	call   2322 <botlish_fn_19+0xf9a>
			231e: R_X86_64_PLT32	rt_int_cmp-0x4
    2322:	mov    $0x2,%ecx
    2327:	test   %rax,%rax
    232a:	cmovl  0x7896(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2332:	jmp    2353 <botlish_fn_19+0xfcb>
    2337:	mov    $0x2,%ecx
    233c:	mov    0x448(%rsp),%rsi
    2344:	cmp    $0xe9,%rsi
    234b:	cmovl  0x7875(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2353:	cmp    $0x6,%rcx
    2357:	je     23df <botlish_fn_19+0x1057>
    235d:	mov    0x448(%rsp),%rsi
    2365:	test   $0x1,%rsi
    236c:	jne    23a1 <botlish_fn_19+0x1019>
    2372:	mov    $0xeb,%edx
    2377:	mov    0x448(%rsp),%rsi
    237f:	mov    0x3c0(%rsp),%rdi
    2387:	call   238c <botlish_fn_19+0x1004>
			2388: R_X86_64_PLT32	rt_int_cmp-0x4
    238c:	mov    $0x2,%ecx
    2391:	test   %rax,%rax
    2394:	cmovl  0x782c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    239c:	jmp    23bd <botlish_fn_19+0x1035>
    23a1:	mov    $0x2,%ecx
    23a6:	mov    0x448(%rsp),%rsi
    23ae:	cmp    $0xeb,%rsi
    23b5:	cmovl  0x780b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    23bd:	cmp    $0x6,%rcx
    23c1:	je     23d2 <botlish_fn_19+0x104a>
    23c7:	mov    $0x1d,%r15d
    23cd:	jmp    24ad <botlish_fn_19+0x1125>
    23d2:	mov    0x488(%rsp),%r15
    23da:	jmp    24ad <botlish_fn_19+0x1125>
    23df:	mov    0x448(%rsp),%rsi
    23e7:	mov    %rsi,%rax
    23ea:	sar    $1,%rax
    23ed:	cmp    $0x6f,%rax
    23f1:	jl     2402 <botlish_fn_19+0x107a>
    23f7:	mov    $0x1d,%r15d
    23fd:	jmp    24ad <botlish_fn_19+0x1125>
    2402:	mov    0x450(%rsp),%r15
    240a:	jmp    24ad <botlish_fn_19+0x1125>
    240f:	mov    0x448(%rsp),%rsi
    2417:	test   $0x1,%rsi
    241e:	jne    2453 <botlish_fn_19+0x10cb>
    2424:	mov    $0xcd,%edx
    2429:	mov    0x448(%rsp),%rsi
    2431:	mov    0x3c0(%rsp),%rdi
    2439:	call   243e <botlish_fn_19+0x10b6>
			243a: R_X86_64_PLT32	rt_int_cmp-0x4
    243e:	mov    $0x2,%ecx
    2443:	test   %rax,%rax
    2446:	cmovl  0x777a(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    244e:	jmp    246f <botlish_fn_19+0x10e7>
    2453:	mov    $0x2,%ecx
    2458:	mov    0x448(%rsp),%rsi
    2460:	cmp    $0xcd,%rsi
    2467:	cmovl  0x7759(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    246f:	cmp    $0x6,%rcx
    2473:	je     24a7 <botlish_fn_19+0x111f>
    2479:	mov    0x448(%rsp),%rsi
    2481:	mov    %rsi,%rax
    2484:	sar    $1,%rax
    2487:	cmp    $0x67,%rax
    248b:	jl     249c <botlish_fn_19+0x1114>
    2491:	mov    $0x1d,%r15d
    2497:	jmp    24ad <botlish_fn_19+0x1125>
    249c:	mov    $0x5,%r15d
    24a2:	jmp    24ad <botlish_fn_19+0x1125>
    24a7:	mov    $0x1d,%r15d
    24ad:	mov    %r15,%rsi
    24b0:	sar    $1,%rsi
    24b3:	cmp    $0xc,%rsi
    24b7:	jl     25e1 <botlish_fn_19+0x1259>
    24bd:	cmp    $0xd,%rsi
    24c1:	mov    %rsi,%rbx
    24c4:	je     294f <botlish_fn_19+0x15c7>
    24ca:	mov    0x448(%rsp),%rsi
    24d2:	test   $0x1,%rsi
    24d9:	jne    2511 <botlish_fn_19+0x1189>
    24df:	mov    0x458(%rsp),%rdx
    24e7:	mov    0x448(%rsp),%rsi
    24ef:	mov    0x3c0(%rsp),%rdi
    24f7:	call   24fc <botlish_fn_19+0x1174>
			24f8: R_X86_64_PLT32	rt_int_cmp-0x4
    24fc:	mov    $0x2,%ecx
    2501:	test   %rax,%rax
    2504:	cmove  0x76bc(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    250c:	jmp    252a <botlish_fn_19+0x11a2>
    2511:	mov    $0x2,%ecx
    2516:	mov    0x448(%rsp),%rsi
    251e:	cmp    $0xffffffffffffffff,%rsi
    2522:	cmove  0x769e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    252a:	cmp    $0x6,%rcx
    252e:	je     2591 <botlish_fn_19+0x1209>
    2534:	mov    %rbx,%rsi
    2537:	mov    0x3c0(%rsp),%rdi
    253f:	call   2544 <botlish_fn_19+0x11bc>
			2540: R_X86_64_PLT32	botlish_fn_3-0x4
    2544:	mov    0x3c0(%rsp),%rdi
    254c:	mov    0x10(%rdi),%r10
    2550:	mov    0x1f8(%r10),%rdx
    2557:	lea    0x308(%rsp),%r9
    255f:	mov    %rax,0x308(%rsp)
    2567:	mov    0x448(%rsp),%rsi
    256f:	mov    %rsi,0x310(%rsp)
    2577:	mov    $0x1,%esi
    257c:	mov    $0x8,%ecx
    2581:	mov    $0x2,%r8d
    2587:	call   258c <botlish_fn_19+0x1204>
			2588: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    258c:	jmp    32a6 <botlish_fn_19+0x1f1e>
    2591:	mov    %rbx,%rsi
    2594:	mov    0x3c0(%rsp),%rdi
    259c:	call   25a1 <botlish_fn_19+0x1219>
			259d: R_X86_64_PLT32	botlish_fn_3-0x4
    25a1:	mov    0x3c0(%rsp),%rdi
    25a9:	mov    0x10(%rdi),%rcx
    25ad:	mov    0x1f0(%rcx),%rdx
    25b4:	lea    0x300(%rsp),%r9
    25bc:	mov    %rax,0x300(%rsp)
    25c4:	mov    $0x2,%esi
    25c9:	mov    $0x1,%r8d
    25cf:	mov    0x488(%rsp),%rcx
    25d7:	call   25dc <botlish_fn_19+0x1254>
			25d8: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    25dc:	jmp    32a6 <botlish_fn_19+0x1f1e>
    25e1:	mov    %r15,0xe0(%rsp)
    25e9:	mov    $0x6,%r12d
    25ef:	movq   $0x6,0xb0(%rsp)
    25fb:	mov    $0x5,%r13d
    2601:	mov    $0xa,%ecx
    2606:	mov    %rcx,%r14
    2609:	mov    %rcx,0x3e0(%rsp)
    2611:	mov    %rcx,0x428(%rsp)
    2619:	mov    %rcx,0x430(%rsp)
    2621:	jmp    3551 <botlish_fn_19+0x21c9>
    2626:	mov    0x448(%rsp),%rsi
    262e:	test   $0x1,%rsi
    2635:	jne    266a <botlish_fn_19+0x12e2>
    263b:	mov    $0x61,%edx
    2640:	mov    0x448(%rsp),%rsi
    2648:	mov    0x3c0(%rsp),%rdi
    2650:	call   2655 <botlish_fn_19+0x12cd>
			2651: R_X86_64_PLT32	rt_int_cmp-0x4
    2655:	mov    $0x2,%ecx
    265a:	test   %rax,%rax
    265d:	cmovl  0x7563(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2665:	jmp    2683 <botlish_fn_19+0x12fb>
    266a:	mov    $0x2,%ecx
    266f:	mov    0x448(%rsp),%rsi
    2677:	cmp    $0x61,%rsi
    267b:	cmovl  0x7545(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2683:	cmp    $0x6,%rcx
    2687:	je     277e <botlish_fn_19+0x13f6>
    268d:	mov    0x448(%rsp),%rsi
    2695:	test   $0x1,%rsi
    269c:	jne    26d1 <botlish_fn_19+0x1349>
    26a2:	mov    $0x63,%edx
    26a7:	mov    0x448(%rsp),%rsi
    26af:	mov    0x3c0(%rsp),%rdi
    26b7:	call   26bc <botlish_fn_19+0x1334>
			26b8: R_X86_64_PLT32	rt_int_cmp-0x4
    26bc:	mov    $0x2,%edi
    26c1:	test   %rax,%rax
    26c4:	cmovl  0x74fc(%rip),%rdi        # 9bc8 <botlish_fn_19+0x8840>
    26cc:	jmp    26ea <botlish_fn_19+0x1362>
    26d1:	mov    $0x2,%edi
    26d6:	mov    0x448(%rsp),%rsi
    26de:	cmp    $0x63,%rsi
    26e2:	cmovl  0x74de(%rip),%rdi        # 9bc8 <botlish_fn_19+0x8840>
    26ea:	cmp    $0x6,%rdi
    26ee:	je     2773 <botlish_fn_19+0x13eb>
    26f4:	mov    0x448(%rsp),%rsi
    26fc:	test   $0x1,%rsi
    2703:	jne    2738 <botlish_fn_19+0x13b0>
    2709:	mov    $0x75,%edx
    270e:	mov    0x448(%rsp),%rsi
    2716:	mov    0x3c0(%rsp),%rdi
    271e:	call   2723 <botlish_fn_19+0x139b>
			271f: R_X86_64_PLT32	rt_int_cmp-0x4
    2723:	mov    $0x2,%ecx
    2728:	test   %rax,%rax
    272b:	cmovl  0x7495(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2733:	jmp    2751 <botlish_fn_19+0x13c9>
    2738:	mov    $0x2,%ecx
    273d:	mov    0x448(%rsp),%rsi
    2745:	cmp    $0x75,%rsi
    2749:	cmovl  0x7477(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2751:	cmp    $0x6,%rcx
    2755:	je     2766 <botlish_fn_19+0x13de>
    275b:	mov    $0x17,%r14d
    2761:	jmp    281b <botlish_fn_19+0x1493>
    2766:	mov    0x450(%rsp),%r14
    276e:	jmp    281b <botlish_fn_19+0x1493>
    2773:	mov    $0x5,%r14d
    2779:	jmp    281b <botlish_fn_19+0x1493>
    277e:	mov    0x448(%rsp),%rsi
    2786:	test   $0x1,%rsi
    278d:	jne    27c2 <botlish_fn_19+0x143a>
    2793:	mov    $0x5b,%edx
    2798:	mov    0x448(%rsp),%rsi
    27a0:	mov    0x3c0(%rsp),%rdi
    27a8:	call   27ad <botlish_fn_19+0x1425>
			27a9: R_X86_64_PLT32	rt_int_cmp-0x4
    27ad:	mov    $0x2,%ecx
    27b2:	test   %rax,%rax
    27b5:	cmovl  0x740b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    27bd:	jmp    27db <botlish_fn_19+0x1453>
    27c2:	mov    $0x2,%ecx
    27c7:	mov    0x448(%rsp),%rsi
    27cf:	cmp    $0x5b,%rsi
    27d3:	cmovl  0x73ed(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    27db:	cmp    $0x6,%rcx
    27df:	je     2815 <botlish_fn_19+0x148d>
    27e5:	mov    0x448(%rsp),%rsi
    27ed:	mov    %rsi,%rax
    27f0:	sar    $1,%rax
    27f3:	cmp    $0x2e,%rax
    27f7:	jl     2808 <botlish_fn_19+0x1480>
    27fd:	mov    $0x17,%r14d
    2803:	jmp    281b <botlish_fn_19+0x1493>
    2808:	mov    0x488(%rsp),%r14
    2810:	jmp    281b <botlish_fn_19+0x1493>
    2815:	mov    $0x17,%r14d
    281b:	mov    %r14,%rsi
    281e:	sar    $1,%rsi
    2821:	cmp    $0x9,%rsi
    2825:	jl     295c <botlish_fn_19+0x15d4>
    282b:	cmp    $0xa,%rsi
    282f:	mov    %rsi,%rbx
    2832:	je     294f <botlish_fn_19+0x15c7>
    2838:	mov    0x448(%rsp),%rsi
    2840:	test   $0x1,%rsi
    2847:	jne    287f <botlish_fn_19+0x14f7>
    284d:	mov    0x458(%rsp),%rdx
    2855:	mov    0x448(%rsp),%rsi
    285d:	mov    0x3c0(%rsp),%rdi
    2865:	call   286a <botlish_fn_19+0x14e2>
			2866: R_X86_64_PLT32	rt_int_cmp-0x4
    286a:	mov    $0x2,%ecx
    286f:	test   %rax,%rax
    2872:	cmove  0x734e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    287a:	jmp    2898 <botlish_fn_19+0x1510>
    287f:	mov    $0x2,%ecx
    2884:	mov    0x448(%rsp),%rsi
    288c:	cmp    $0xffffffffffffffff,%rsi
    2890:	cmove  0x7330(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2898:	cmp    $0x6,%rcx
    289c:	je     28ff <botlish_fn_19+0x1577>
    28a2:	mov    %rbx,%rsi
    28a5:	mov    0x3c0(%rsp),%rdi
    28ad:	call   28b2 <botlish_fn_19+0x152a>
			28ae: R_X86_64_PLT32	botlish_fn_1-0x4
    28b2:	mov    0x3c0(%rsp),%rdi
    28ba:	mov    0x10(%rdi),%rcx
    28be:	mov    0x1f8(%rcx),%rdx
    28c5:	lea    0x2f0(%rsp),%r9
    28cd:	mov    %rax,0x2f0(%rsp)
    28d5:	mov    0x448(%rsp),%rsi
    28dd:	mov    %rsi,0x2f8(%rsp)
    28e5:	mov    $0x1,%esi
    28ea:	mov    $0x8,%ecx
    28ef:	mov    $0x2,%r8d
    28f5:	call   28fa <botlish_fn_19+0x1572>
			28f6: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    28fa:	jmp    32a6 <botlish_fn_19+0x1f1e>
    28ff:	mov    %rbx,%rsi
    2902:	mov    0x3c0(%rsp),%rdi
    290a:	call   290f <botlish_fn_19+0x1587>
			290b: R_X86_64_PLT32	botlish_fn_1-0x4
    290f:	mov    0x3c0(%rsp),%rdi
    2917:	mov    0x10(%rdi),%rcx
    291b:	mov    0x1f0(%rcx),%rdx
    2922:	lea    0x2e8(%rsp),%r9
    292a:	mov    %rax,0x2e8(%rsp)
    2932:	mov    $0x2,%esi
    2937:	mov    $0x1,%r8d
    293d:	mov    0x488(%rsp),%rcx
    2945:	call   294a <botlish_fn_19+0x15c2>
			2946: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    294a:	jmp    32a6 <botlish_fn_19+0x1f1e>
    294f:	mov    0x448(%rsp),%rsi
    2957:	jmp    34c3 <botlish_fn_19+0x213b>
    295c:	mov    %r14,0xd8(%rsp)
    2964:	mov    $0x6,%r12d
    296a:	movq   $0x6,0xb0(%rsp)
    2976:	mov    $0x4,%r13d
    297c:	mov    $0xa,%ecx
    2981:	mov    %rcx,%r15
    2984:	mov    %rcx,0x3e0(%rsp)
    298c:	mov    %rcx,0x428(%rsp)
    2994:	mov    %rcx,0x430(%rsp)
    299c:	jmp    3551 <botlish_fn_19+0x21c9>
    29a1:	mov    0x448(%rsp),%rsi
    29a9:	test   $0x1,%rsi
    29b0:	jne    29e5 <botlish_fn_19+0x165d>
    29b6:	mov    $0x45,%edx
    29bb:	mov    0x448(%rsp),%rsi
    29c3:	mov    0x3c0(%rsp),%rdi
    29cb:	call   29d0 <botlish_fn_19+0x1648>
			29cc: R_X86_64_PLT32	rt_int_cmp-0x4
    29d0:	mov    $0x2,%ecx
    29d5:	test   %rax,%rax
    29d8:	cmovl  0x71e8(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    29e0:	jmp    29fe <botlish_fn_19+0x1676>
    29e5:	mov    $0x2,%ecx
    29ea:	mov    0x448(%rsp),%rsi
    29f2:	cmp    $0x45,%rsi
    29f6:	cmovl  0x71ca(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    29fe:	cmp    $0x6,%rcx
    2a02:	je     2a86 <botlish_fn_19+0x16fe>
    2a08:	mov    0x448(%rsp),%rsi
    2a10:	test   $0x1,%rsi
    2a17:	jne    2a4c <botlish_fn_19+0x16c4>
    2a1d:	mov    $0x47,%edx
    2a22:	mov    0x448(%rsp),%rsi
    2a2a:	mov    0x3c0(%rsp),%rdi
    2a32:	call   2a37 <botlish_fn_19+0x16af>
			2a33: R_X86_64_PLT32	rt_int_cmp-0x4
    2a37:	mov    $0x2,%ecx
    2a3c:	test   %rax,%rax
    2a3f:	cmovl  0x7181(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2a47:	jmp    2a65 <botlish_fn_19+0x16dd>
    2a4c:	mov    $0x2,%ecx
    2a51:	mov    0x448(%rsp),%rsi
    2a59:	cmp    $0x47,%rsi
    2a5d:	cmovl  0x7163(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2a65:	cmp    $0x6,%rcx
    2a69:	je     2a79 <botlish_fn_19+0x16f1>
    2a6f:	mov    $0xd,%edx
    2a74:	jmp    2a8b <botlish_fn_19+0x1703>
    2a79:	mov    0x488(%rsp),%rdx
    2a81:	jmp    2a8b <botlish_fn_19+0x1703>
    2a86:	mov    $0xd,%edx
    2a8b:	mov    %rdx,%rsi
    2a8e:	sar    $1,%rsi
    2a91:	cmp    $0x2,%rsi
    2a95:	jl     3472 <botlish_fn_19+0x20ea>
    2a9b:	cmp    $0x2,%rsi
    2a9f:	je     3466 <botlish_fn_19+0x20de>
    2aa5:	cmp    $0x4,%rsi
    2aa9:	je     3085 <botlish_fn_19+0x1cfd>
    2aaf:	cmp    $0x5,%rsi
    2ab3:	mov    %rsi,%rbx
    2ab6:	je     2bd3 <botlish_fn_19+0x184b>
    2abc:	mov    0x448(%rsp),%rsi
    2ac4:	test   $0x1,%rsi
    2acb:	jne    2b03 <botlish_fn_19+0x177b>
    2ad1:	mov    0x458(%rsp),%rdx
    2ad9:	mov    0x448(%rsp),%rsi
    2ae1:	mov    0x3c0(%rsp),%rdi
    2ae9:	call   2aee <botlish_fn_19+0x1766>
			2aea: R_X86_64_PLT32	rt_int_cmp-0x4
    2aee:	mov    $0x2,%esi
    2af3:	test   %rax,%rax
    2af6:	cmove  0x70ca(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    2afe:	jmp    2b1c <botlish_fn_19+0x1794>
    2b03:	mov    $0x2,%esi
    2b08:	mov    0x448(%rsp),%rax
    2b10:	cmp    $0xffffffffffffffff,%rax
    2b14:	cmove  0x70ac(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    2b1c:	cmp    $0x6,%rsi
    2b20:	je     2b83 <botlish_fn_19+0x17fb>
    2b26:	mov    %rbx,%rsi
    2b29:	mov    0x3c0(%rsp),%rdi
    2b31:	call   2b36 <botlish_fn_19+0x17ae>
			2b32: R_X86_64_PLT32	botlish_fn_9-0x4
    2b36:	mov    0x3c0(%rsp),%rdi
    2b3e:	mov    0x10(%rdi),%rcx
    2b42:	mov    0x1f8(%rcx),%rdx
    2b49:	lea    0x2d8(%rsp),%r9
    2b51:	mov    %rax,0x2d8(%rsp)
    2b59:	mov    0x448(%rsp),%rsi
    2b61:	mov    %rsi,0x2e0(%rsp)
    2b69:	mov    $0x1,%esi
    2b6e:	mov    $0x8,%ecx
    2b73:	mov    $0x2,%r8d
    2b79:	call   2b7e <botlish_fn_19+0x17f6>
			2b7a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2b7e:	jmp    32a6 <botlish_fn_19+0x1f1e>
    2b83:	mov    %rbx,%rsi
    2b86:	mov    0x3c0(%rsp),%rdi
    2b8e:	call   2b93 <botlish_fn_19+0x180b>
			2b8f: R_X86_64_PLT32	botlish_fn_9-0x4
    2b93:	mov    0x3c0(%rsp),%rdi
    2b9b:	mov    0x10(%rdi),%rcx
    2b9f:	mov    0x1f0(%rcx),%rdx
    2ba6:	lea    0x2d0(%rsp),%r9
    2bae:	mov    %rax,0x2d0(%rsp)
    2bb6:	mov    $0x2,%esi
    2bbb:	mov    $0x1,%r8d
    2bc1:	mov    0x488(%rsp),%rcx
    2bc9:	call   2bce <botlish_fn_19+0x1846>
			2bca: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2bce:	jmp    32a6 <botlish_fn_19+0x1f1e>
    2bd3:	mov    0x448(%rsp),%rsi
    2bdb:	test   $0x1,%rsi
    2be2:	jne    2c17 <botlish_fn_19+0x188f>
    2be8:	mov    $0x1dd,%edx
    2bed:	mov    0x448(%rsp),%rsi
    2bf5:	mov    0x3c0(%rsp),%rdi
    2bfd:	call   2c02 <botlish_fn_19+0x187a>
			2bfe: R_X86_64_PLT32	rt_int_cmp-0x4
    2c02:	mov    $0x2,%ecx
    2c07:	test   %rax,%rax
    2c0a:	cmovl  0x6fb6(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2c12:	jmp    2c33 <botlish_fn_19+0x18ab>
    2c17:	mov    $0x2,%ecx
    2c1c:	mov    0x448(%rsp),%rsi
    2c24:	cmp    $0x1dd,%rsi
    2c2b:	cmovl  0x6f95(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2c33:	cmp    $0x6,%rcx
    2c37:	je     2dca <botlish_fn_19+0x1a42>
    2c3d:	mov    0x448(%rsp),%rsi
    2c45:	test   $0x1,%rsi
    2c4c:	jne    2c81 <botlish_fn_19+0x18f9>
    2c52:	mov    $0x1e3,%edx
    2c57:	mov    0x448(%rsp),%rsi
    2c5f:	mov    0x3c0(%rsp),%rdi
    2c67:	call   2c6c <botlish_fn_19+0x18e4>
			2c68: R_X86_64_PLT32	rt_int_cmp-0x4
    2c6c:	mov    $0x2,%ecx
    2c71:	test   %rax,%rax
    2c74:	cmovl  0x6f4c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2c7c:	jmp    2c9d <botlish_fn_19+0x1915>
    2c81:	mov    $0x2,%ecx
    2c86:	mov    0x448(%rsp),%rsi
    2c8e:	cmp    $0x1e3,%rsi
    2c95:	cmovl  0x6f2b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2c9d:	cmp    $0x6,%rcx
    2ca1:	je     2d99 <botlish_fn_19+0x1a11>
    2ca7:	mov    0x448(%rsp),%rsi
    2caf:	test   $0x1,%rsi
    2cb6:	jne    2ceb <botlish_fn_19+0x1963>
    2cbc:	mov    $0x1e9,%edx
    2cc1:	mov    0x448(%rsp),%rsi
    2cc9:	mov    0x3c0(%rsp),%rdi
    2cd1:	call   2cd6 <botlish_fn_19+0x194e>
			2cd2: R_X86_64_PLT32	rt_int_cmp-0x4
    2cd6:	mov    $0x2,%ecx
    2cdb:	test   %rax,%rax
    2cde:	cmovl  0x6ee2(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2ce6:	jmp    2d07 <botlish_fn_19+0x197f>
    2ceb:	mov    $0x2,%ecx
    2cf0:	mov    0x448(%rsp),%rsi
    2cf8:	cmp    $0x1e9,%rsi
    2cff:	cmovl  0x6ec1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2d07:	cmp    $0x6,%rcx
    2d0b:	je     2d8f <botlish_fn_19+0x1a07>
    2d11:	mov    0x448(%rsp),%rsi
    2d19:	test   $0x1,%rsi
    2d20:	jne    2d55 <botlish_fn_19+0x19cd>
    2d26:	mov    $0x1eb,%edx
    2d2b:	mov    0x448(%rsp),%rsi
    2d33:	mov    0x3c0(%rsp),%rdi
    2d3b:	call   2d40 <botlish_fn_19+0x19b8>
			2d3c: R_X86_64_PLT32	rt_int_cmp-0x4
    2d40:	mov    $0x2,%ecx
    2d45:	test   %rax,%rax
    2d48:	cmovl  0x6e78(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2d50:	jmp    2d71 <botlish_fn_19+0x19e9>
    2d55:	mov    $0x2,%ecx
    2d5a:	mov    0x448(%rsp),%rsi
    2d62:	cmp    $0x1eb,%rsi
    2d69:	cmovl  0x6e57(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2d71:	cmp    $0x6,%rcx
    2d75:	je     2d85 <botlish_fn_19+0x19fd>
    2d7b:	mov    $0x15,%esi
    2d80:	jmp    2ef9 <botlish_fn_19+0x1b71>
    2d85:	mov    $0xf,%esi
    2d8a:	jmp    2ef9 <botlish_fn_19+0x1b71>
    2d8f:	mov    $0xd,%esi
    2d94:	jmp    2ef9 <botlish_fn_19+0x1b71>
    2d99:	mov    0x448(%rsp),%rsi
    2da1:	mov    %rsi,%rax
    2da4:	sar    $1,%rax
    2da7:	cmp    $0xf0,%rax
    2dad:	jl     2dbd <botlish_fn_19+0x1a35>
    2db3:	mov    $0xb,%esi
    2db8:	jmp    2ef9 <botlish_fn_19+0x1b71>
    2dbd:	mov    0x450(%rsp),%rsi
    2dc5:	jmp    2ef9 <botlish_fn_19+0x1b71>
    2dca:	mov    0x448(%rsp),%rsi
    2dd2:	test   $0x1,%rsi
    2dd9:	jne    2e0e <botlish_fn_19+0x1a86>
    2ddf:	mov    $0x1c1,%edx
    2de4:	mov    0x448(%rsp),%rsi
    2dec:	mov    0x3c0(%rsp),%rdi
    2df4:	call   2df9 <botlish_fn_19+0x1a71>
			2df5: R_X86_64_PLT32	rt_int_cmp-0x4
    2df9:	mov    $0x2,%ecx
    2dfe:	test   %rax,%rax
    2e01:	cmovl  0x6dbf(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2e09:	jmp    2e2a <botlish_fn_19+0x1aa2>
    2e0e:	mov    $0x2,%ecx
    2e13:	mov    0x448(%rsp),%rsi
    2e1b:	cmp    $0x1c1,%rsi
    2e22:	cmovl  0x6d9e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2e2a:	cmp    $0x6,%rcx
    2e2e:	je     2e7d <botlish_fn_19+0x1af5>
    2e34:	mov    0x448(%rsp),%rsi
    2e3c:	mov    %rsi,%r9
    2e3f:	sar    $1,%r9
    2e42:	cmp    $0xe1,%r9
    2e49:	jl     2e73 <botlish_fn_19+0x1aeb>
    2e4f:	cmp    $0xed,%r9
    2e56:	jl     2e66 <botlish_fn_19+0x1ade>
    2e5c:	mov    $0x9,%esi
    2e61:	jmp    2ef9 <botlish_fn_19+0x1b71>
    2e66:	mov    0x450(%rsp),%rsi
    2e6e:	jmp    2ef9 <botlish_fn_19+0x1b71>
    2e73:	mov    $0x5,%esi
    2e78:	jmp    2ef9 <botlish_fn_19+0x1b71>
    2e7d:	mov    0x448(%rsp),%rsi
    2e85:	test   $0x1,%rsi
    2e8c:	jne    2ec1 <botlish_fn_19+0x1b39>
    2e92:	mov    $0x185,%edx
    2e97:	mov    0x448(%rsp),%rsi
    2e9f:	mov    0x3c0(%rsp),%rdi
    2ea7:	call   2eac <botlish_fn_19+0x1b24>
			2ea8: R_X86_64_PLT32	rt_int_cmp-0x4
    2eac:	mov    $0x2,%ecx
    2eb1:	test   %rax,%rax
    2eb4:	cmovl  0x6d0c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2ebc:	jmp    2edd <botlish_fn_19+0x1b55>
    2ec1:	mov    $0x2,%ecx
    2ec6:	mov    0x448(%rsp),%rsi
    2ece:	cmp    $0x185,%rsi
    2ed5:	cmovl  0x6ceb(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2edd:	cmp    $0x6,%rcx
    2ee1:	je     2ef4 <botlish_fn_19+0x1b6c>
    2ee7:	mov    0x488(%rsp),%rsi
    2eef:	jmp    2ef9 <botlish_fn_19+0x1b71>
    2ef4:	mov    $0x15,%esi
    2ef9:	mov    %rsi,%rcx
    2efc:	sar    $1,%rcx
    2eff:	mov    $0x8,%ebx
    2f04:	cmp    $0x8,%rcx
    2f08:	jl     303d <botlish_fn_19+0x1cb5>
    2f0e:	cmp    $0x8,%rcx
    2f12:	mov    %rcx,%r12
    2f15:	je     3030 <botlish_fn_19+0x1ca8>
    2f1b:	mov    0x448(%rsp),%rsi
    2f23:	test   $0x1,%rsi
    2f2a:	jne    2f62 <botlish_fn_19+0x1bda>
    2f30:	mov    0x458(%rsp),%rdx
    2f38:	mov    0x448(%rsp),%rsi
    2f40:	mov    0x3c0(%rsp),%rdi
    2f48:	call   2f4d <botlish_fn_19+0x1bc5>
			2f49: R_X86_64_PLT32	rt_int_cmp-0x4
    2f4d:	mov    $0x2,%ecx
    2f52:	test   %rax,%rax
    2f55:	cmove  0x6c6b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2f5d:	jmp    2f7b <botlish_fn_19+0x1bf3>
    2f62:	mov    $0x2,%ecx
    2f67:	mov    0x448(%rsp),%rsi
    2f6f:	cmp    $0xffffffffffffffff,%rsi
    2f73:	cmove  0x6c4d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    2f7b:	cmp    $0x6,%rcx
    2f7f:	je     2fe0 <botlish_fn_19+0x1c58>
    2f85:	mov    %r12,%rsi
    2f88:	mov    0x3c0(%rsp),%rdi
    2f90:	call   2f95 <botlish_fn_19+0x1c0d>
			2f91: R_X86_64_PLT32	botlish_fn_7-0x4
    2f95:	mov    0x3c0(%rsp),%rdi
    2f9d:	mov    0x10(%rdi),%rcx
    2fa1:	mov    0x1f8(%rcx),%rdx
    2fa8:	lea    0x2c0(%rsp),%r9
    2fb0:	mov    %rax,0x2c0(%rsp)
    2fb8:	mov    0x448(%rsp),%rsi
    2fc0:	mov    %rsi,0x2c8(%rsp)
    2fc8:	mov    $0x1,%esi
    2fcd:	mov    $0x2,%r8d
    2fd3:	mov    %rbx,%rcx
    2fd6:	call   2fdb <botlish_fn_19+0x1c53>
			2fd7: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2fdb:	jmp    32a6 <botlish_fn_19+0x1f1e>
    2fe0:	mov    %r12,%rsi
    2fe3:	mov    0x3c0(%rsp),%rdi
    2feb:	call   2ff0 <botlish_fn_19+0x1c68>
			2fec: R_X86_64_PLT32	botlish_fn_7-0x4
    2ff0:	mov    0x3c0(%rsp),%rdi
    2ff8:	mov    0x10(%rdi),%rcx
    2ffc:	mov    0x1f0(%rcx),%rdx
    3003:	lea    0x2b8(%rsp),%r9
    300b:	mov    %rax,0x2b8(%rsp)
    3013:	mov    $0x2,%esi
    3018:	mov    $0x1,%r8d
    301e:	mov    0x488(%rsp),%rcx
    3026:	call   302b <botlish_fn_19+0x1ca3>
			3027: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    302b:	jmp    32a6 <botlish_fn_19+0x1f1e>
    3030:	mov    0x488(%rsp),%rdx
    3038:	jmp    33f7 <botlish_fn_19+0x206f>
    303d:	mov    %rsi,0xd0(%rsp)
    3045:	mov    $0x6,%r12d
    304b:	movq   $0x6,0xb0(%rsp)
    3057:	mov    $0x2,%r13d
    305d:	mov    $0xa,%ecx
    3062:	mov    %rcx,%r14
    3065:	mov    %rcx,%r15
    3068:	mov    %rcx,0x3e0(%rsp)
    3070:	mov    %rcx,0x428(%rsp)
    3078:	mov    %rsi,0x430(%rsp)
    3080:	jmp    3551 <botlish_fn_19+0x21c9>
    3085:	mov    0x448(%rsp),%rsi
    308d:	test   $0x1,%rsi
    3094:	jne    30c9 <botlish_fn_19+0x1d41>
    309a:	mov    $0xb9,%edx
    309f:	mov    0x448(%rsp),%rsi
    30a7:	mov    0x3c0(%rsp),%rdi
    30af:	call   30b4 <botlish_fn_19+0x1d2c>
			30b0: R_X86_64_PLT32	rt_int_cmp-0x4
    30b4:	mov    $0x2,%ecx
    30b9:	test   %rax,%rax
    30bc:	cmovl  0x6b04(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    30c4:	jmp    30e5 <botlish_fn_19+0x1d5d>
    30c9:	mov    $0x2,%ecx
    30ce:	mov    0x448(%rsp),%rsi
    30d6:	cmp    $0xb9,%rsi
    30dd:	cmovl  0x6ae3(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    30e5:	cmp    $0x6,%rcx
    30e9:	je     3172 <botlish_fn_19+0x1dea>
    30ef:	mov    0x448(%rsp),%rsi
    30f7:	test   $0x1,%rsi
    30fe:	jne    3134 <botlish_fn_19+0x1dac>
    3104:	mov    $0xbb,%edx
    3109:	mov    0x448(%rsp),%rsi
    3111:	mov    0x3c0(%rsp),%rdi
    3119:	call   311e <botlish_fn_19+0x1d96>
			311a: R_X86_64_PLT32	rt_int_cmp-0x4
    311e:	mov    $0x2,%r9d
    3124:	test   %rax,%rax
    3127:	cmovl  0x6a99(%rip),%r9        # 9bc8 <botlish_fn_19+0x8840>
    312f:	jmp    3151 <botlish_fn_19+0x1dc9>
    3134:	mov    $0x2,%r9d
    313a:	mov    0x448(%rsp),%rsi
    3142:	cmp    $0xbb,%rsi
    3149:	cmovl  0x6a77(%rip),%r9        # 9bc8 <botlish_fn_19+0x8840>
    3151:	cmp    $0x6,%r9
    3155:	je     3165 <botlish_fn_19+0x1ddd>
    315b:	mov    $0x11,%ecx
    3160:	jmp    3177 <botlish_fn_19+0x1def>
    3165:	mov    0x488(%rsp),%rcx
    316d:	jmp    3177 <botlish_fn_19+0x1def>
    3172:	mov    $0x11,%ecx
    3177:	mov    %rcx,%rsi
    317a:	sar    $1,%rsi
    317d:	cmp    $0x6,%rsi
    3181:	jl     340c <botlish_fn_19+0x2084>
    3187:	cmp    $0x6,%rsi
    318b:	mov    %rsi,%rbx
    318e:	je     33ef <botlish_fn_19+0x2067>
    3194:	mov    0x448(%rsp),%rsi
    319c:	test   $0x1,%rsi
    31a3:	jne    31db <botlish_fn_19+0x1e53>
    31a9:	mov    0x458(%rsp),%rdx
    31b1:	mov    0x448(%rsp),%rsi
    31b9:	mov    0x3c0(%rsp),%rdi
    31c1:	call   31c6 <botlish_fn_19+0x1e3e>
			31c2: R_X86_64_PLT32	rt_int_cmp-0x4
    31c6:	mov    $0x2,%ecx
    31cb:	test   %rax,%rax
    31ce:	cmove  0x69f2(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    31d6:	jmp    31f4 <botlish_fn_19+0x1e6c>
    31db:	mov    $0x2,%ecx
    31e0:	mov    0x448(%rsp),%rsi
    31e8:	cmp    $0xffffffffffffffff,%rsi
    31ec:	cmove  0x69d4(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    31f4:	cmp    $0x6,%rcx
    31f8:	je     325b <botlish_fn_19+0x1ed3>
    31fe:	mov    %rbx,%rsi
    3201:	mov    0x3c0(%rsp),%rdi
    3209:	call   320e <botlish_fn_19+0x1e86>
			320a: R_X86_64_PLT32	botlish_fn_5-0x4
    320e:	mov    0x3c0(%rsp),%rdi
    3216:	mov    0x10(%rdi),%rcx
    321a:	mov    0x1f8(%rcx),%rdx
    3221:	lea    0x2a8(%rsp),%r9
    3229:	mov    %rax,0x2a8(%rsp)
    3231:	mov    0x448(%rsp),%rsi
    3239:	mov    %rsi,0x2b0(%rsp)
    3241:	mov    $0x1,%esi
    3246:	mov    $0x8,%ecx
    324b:	mov    $0x2,%r8d
    3251:	call   3256 <botlish_fn_19+0x1ece>
			3252: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3256:	jmp    32a6 <botlish_fn_19+0x1f1e>
    325b:	mov    %rbx,%rsi
    325e:	mov    0x3c0(%rsp),%rdi
    3266:	call   326b <botlish_fn_19+0x1ee3>
			3267: R_X86_64_PLT32	botlish_fn_5-0x4
    326b:	mov    0x3c0(%rsp),%rdi
    3273:	mov    0x10(%rdi),%rcx
    3277:	mov    0x1f0(%rcx),%rdx
    327e:	lea    0x2a0(%rsp),%r9
    3286:	mov    %rax,0x2a0(%rsp)
    328e:	mov    $0x2,%esi
    3293:	mov    $0x1,%r8d
    3299:	mov    0x488(%rsp),%rcx
    32a1:	call   32a6 <botlish_fn_19+0x1f1e>
			32a2: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    32a6:	mov    0x3c0(%rsp),%rdi
    32ae:	call   32b3 <botlish_fn_19+0x1f2b>
			32af: R_X86_64_PLT32	rt_co_failed-0x4
    32b3:	mov    %rax,0xb8(%rsp)
    32bb:	mov    %rax,%rsi
    32be:	mov    0x3c0(%rsp),%rdi
    32c6:	call   32cb <botlish_fn_19+0x1f43>
			32c7: R_X86_64_PLT32	rt_co_resume0-0x4
    32cb:	test   %rax,%rax
    32ce:	je     32f0 <botlish_fn_19+0x1f68>
    32d4:	mov    0x3c0(%rsp),%rdi
    32dc:	mov    0x10(%rdi),%rax
    32e0:	mov    0x48(%rax),%rsi
    32e4:	mov    0x1b8(%rax),%rdx
    32eb:	call   32f0 <botlish_fn_19+0x1f68>
			32ec: R_X86_64_PLT32	rt_raise-0x4
    32f0:	mov    0x3c0(%rsp),%rdi
    32f8:	call   32fd <botlish_fn_19+0x1f75>
			32f9: R_X86_64_PLT32	rt_declared_error-0x4
    32fd:	cmp    $0x1,%rax
    3301:	je     3381 <botlish_fn_19+0x1ff9>
    3307:	mov    0x3c0(%rsp),%rdi
    330f:	call   3314 <botlish_fn_19+0x1f8c>
			3310: R_X86_64_PLT32	rt_declared_error-0x4
    3314:	cmp    $0x2,%rax
    3318:	jne    9a02 <botlish_fn_19+0x867a>
    331e:	xor    %rsi,%rsi
    3321:	mov    0x3c0(%rsp),%rdi
    3329:	call   332e <botlish_fn_19+0x1fa6>
			332a: R_X86_64_PLT32	rt_declared_payload-0x4
    332e:	mov    %rax,%rbx
    3331:	mov    0x3c0(%rsp),%rdi
    3339:	call   333e <botlish_fn_19+0x1fb6>
			333a: R_X86_64_PLT32	rt_clear_declared_error-0x4
    333e:	mov    0x3c0(%rsp),%rdi
    3346:	mov    0x10(%rdi),%rax
    334a:	mov    0x1c8(%rax),%rdx
    3351:	lea    0xf8(%rsp),%r9
    3359:	mov    %rbx,%rax
    335c:	mov    %rax,0xf8(%rsp)
    3364:	mov    $0x5,%esi
    3369:	mov    $0x1,%r8d
    336f:	mov    0x488(%rsp),%rcx
    3377:	call   337c <botlish_fn_19+0x1ff4>
			3378: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    337c:	jmp    9a02 <botlish_fn_19+0x867a>
    3381:	xor    %rsi,%rsi
    3384:	mov    0x3c0(%rsp),%rdi
    338c:	call   3391 <botlish_fn_19+0x2009>
			338d: R_X86_64_PLT32	rt_declared_payload-0x4
    3391:	mov    %rax,%rbx
    3394:	mov    0x3c0(%rsp),%rdi
    339c:	call   33a1 <botlish_fn_19+0x2019>
			339d: R_X86_64_PLT32	rt_clear_declared_error-0x4
    33a1:	mov    0x3c0(%rsp),%rdi
    33a9:	mov    0x10(%rdi),%rax
    33ad:	mov    0x1c0(%rax),%rdx
    33b4:	lea    0xe8(%rsp),%r9
    33bc:	mov    0x440(%rsp),%rcx
    33c4:	mov    %rcx,0xe8(%rsp)
    33cc:	mov    %rbx,%rax
    33cf:	mov    %rax,0xf0(%rsp)
    33d7:	mov    $0x4,%esi
    33dc:	mov    $0x2,%r8d
    33e2:	mov    %r8,%rcx
    33e5:	call   33ea <botlish_fn_19+0x2062>
			33e6: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    33ea:	jmp    9a02 <botlish_fn_19+0x867a>
    33ef:	mov    0x488(%rsp),%rdx
    33f7:	mov    %rdx,0xc0(%rsp)
    33ff:	mov    %rdx,0x3e0(%rsp)
    3407:	jmp    3482 <botlish_fn_19+0x20fa>
    340c:	mov    %rcx,0xc8(%rsp)
    3414:	mov    $0x6,%r12d
    341a:	movq   $0x6,0xb0(%rsp)
    3426:	mov    $0x1,%r13d
    342c:	mov    $0xa,%esi
    3431:	mov    %rsi,0x430(%rsp)
    3439:	mov    0x430(%rsp),%r14
    3441:	mov    0x430(%rsp),%r15
    3449:	mov    0x430(%rsp),%rax
    3451:	mov    %rax,0x3e0(%rsp)
    3459:	mov    %rcx,0x428(%rsp)
    3461:	jmp    3551 <botlish_fn_19+0x21c9>
    3466:	mov    $0xfffffffffffffffd,%rsi
    346d:	jmp    34c3 <botlish_fn_19+0x213b>
    3472:	mov    %rdx,0xc0(%rsp)
    347a:	mov    %rdx,0x3e0(%rsp)
    3482:	mov    $0x6,%r12d
    3488:	movq   $0x6,0xb0(%rsp)
    3494:	mov    $0xa,%ecx
    3499:	mov    0x488(%rsp),%r13
    34a1:	mov    %rcx,%r14
    34a4:	mov    %rcx,%r15
    34a7:	mov    %rcx,0x428(%rsp)
    34af:	mov    %rcx,0x430(%rsp)
    34b7:	jmp    3551 <botlish_fn_19+0x21c9>
    34bc:	mov    $0xfffffffffffffffd,%rsi
    34c3:	test   $0x1,%rsi
    34ca:	jne    34fa <botlish_fn_19+0x2172>
    34d0:	mov    $0xfffffffffffffffd,%rdx
    34d7:	mov    0x3c0(%rsp),%rdi
    34df:	call   34e4 <botlish_fn_19+0x215c>
			34e0: R_X86_64_PLT32	rt_int_cmp-0x4
    34e4:	mov    $0x2,%r12d
    34ea:	test   %rax,%rax
    34ed:	cmove  0x66d3(%rip),%r12        # 9bc8 <botlish_fn_19+0x8840>
    34f5:	jmp    350c <botlish_fn_19+0x2184>
    34fa:	mov    $0x2,%r12d
    3500:	cmp    $0xfffffffffffffffd,%rsi
    3504:	cmove  0x66bc(%rip),%r12        # 9bc8 <botlish_fn_19+0x8840>
    350c:	mov    %r12,0xb0(%rsp)
    3514:	mov    $0xa,%ecx
    3519:	mov    %rcx,0x428(%rsp)
    3521:	mov    0x458(%rsp),%r13
    3529:	mov    0x428(%rsp),%r14
    3531:	mov    0x428(%rsp),%r15
    3539:	mov    0x428(%rsp),%rax
    3541:	mov    %rax,0x3e0(%rsp)
    3549:	mov    %rax,0x430(%rsp)
    3551:	mov    0x460(%rsp),%rbx
    3559:	mov    0x18(%rbx),%rax
    355d:	test   %rax,%rax
    3560:	je     9ada <botlish_fn_19+0x8752>
    3566:	mov    0x460(%rsp),%rbx
    356e:	mov    0x10(%rbx),%rax
    3572:	mov    %r12,(%rax)
    3575:	mov    0x460(%rsp),%rbx
    357d:	mov    0x460(%rsp),%rbx
    3585:	mov    0x10(%rbx),%rax
    3589:	mov    (%rax),%rax
    358c:	cmp    $0x6,%rax
    3590:	jne    3ad5 <botlish_fn_19+0x274d>
    3596:	movq   $0x1,0x38(%rsp)
    359f:	mov    0x470(%rsp),%rdx
    35a7:	mov    0x10(%rdx),%rax
    35ab:	mov    (%rax),%rsi
    35ae:	mov    %rsi,0x40(%rsp)
    35b3:	movq   $0x3,0x48(%rsp)
    35bc:	test   $0x1,%rsi
    35c3:	je     35e8 <botlish_fn_19+0x2260>
    35c9:	mov    %rsi,%rcx
    35cc:	add    $0x2,%rcx
    35d0:	seto   %al
    35d3:	test   %al,%al
    35d5:	jne    35e8 <botlish_fn_19+0x2260>
    35db:	mov    0x470(%rsp),%rdx
    35e3:	jmp    3608 <botlish_fn_19+0x2280>
    35e8:	mov    0x488(%rsp),%rdx
    35f0:	mov    0x3c0(%rsp),%rdi
    35f8:	call   35fd <botlish_fn_19+0x2275>
			35f9: R_X86_64_PLT32	rt_int_add-0x4
    35fd:	mov    %rax,%rcx
    3600:	mov    0x470(%rsp),%rdx
    3608:	mov    0x470(%rsp),%rdx
    3610:	mov    0x18(%rdx),%rax
    3614:	test   %rax,%rax
    3617:	je     9afc <botlish_fn_19+0x8774>
    361d:	mov    0x470(%rsp),%rdx
    3625:	mov    0x10(%rdx),%rax
    3629:	mov    %rcx,(%rax)
    362c:	movq   $0x1,0x38(%rsp)
    3635:	mov    0x3e8(%rsp),%rcx
    363d:	cmp    $0x1,%rcx
    3641:	je     366b <botlish_fn_19+0x22e3>
    3647:	mov    $0xa,%esi
    364c:	cmp    $0xffffffffffffffff,%rcx
    3650:	jne    39fa <botlish_fn_19+0x2672>
    3656:	mov    %rcx,0x3e8(%rsp)
    365e:	mov    0x478(%rsp),%rcx
    3666:	jmp    3aa9 <botlish_fn_19+0x2721>
    366b:	movq   $0x3,0x40(%rsp)
    3674:	mov    0x400(%rsp),%rsi
    367c:	test   $0x1,%rsi
    3683:	jne    3696 <botlish_fn_19+0x230e>
    3689:	mov    0x400(%rsp),%rsi
    3691:	jmp    36cd <botlish_fn_19+0x2345>
    3696:	mov    0x400(%rsp),%rsi
    369e:	mov    %rsi,%rcx
    36a1:	add    $0x2,%rcx
    36a5:	seto   %al
    36a8:	test   %al,%al
    36aa:	je     36bd <botlish_fn_19+0x2335>
    36b0:	mov    0x400(%rsp),%rsi
    36b8:	jmp    36cd <botlish_fn_19+0x2345>
    36bd:	mov    %rcx,%rsi
    36c0:	mov    %rcx,0x400(%rsp)
    36c8:	jmp    36ed <botlish_fn_19+0x2365>
    36cd:	mov    0x488(%rsp),%rdx
    36d5:	mov    0x3c0(%rsp),%rdi
    36dd:	call   36e2 <botlish_fn_19+0x235a>
			36de: R_X86_64_PLT32	rt_int_add-0x4
    36e2:	mov    %rax,%rsi
    36e5:	mov    %rax,0x400(%rsp)
    36ed:	mov    %rsi,0x88(%rsp)
    36f5:	mov    0x408(%rsp),%rax
    36fd:	mov    0x400(%rsp),%rsi
    3705:	and    %rax,%rsi
    3708:	test   $0x1,%rsi
    370f:	jne    3747 <botlish_fn_19+0x23bf>
    3715:	mov    0x408(%rsp),%rdx
    371d:	mov    0x400(%rsp),%rsi
    3725:	mov    0x3c0(%rsp),%rdi
    372d:	call   3732 <botlish_fn_19+0x23aa>
			372e: R_X86_64_PLT32	rt_int_cmp-0x4
    3732:	mov    $0x2,%ecx
    3737:	test   %rax,%rax
    373a:	cmovl  0x6486(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3742:	jmp    3767 <botlish_fn_19+0x23df>
    3747:	mov    $0x2,%ecx
    374c:	mov    0x408(%rsp),%rax
    3754:	mov    0x400(%rsp),%rsi
    375c:	cmp    %rax,%rsi
    375f:	cmovl  0x6461(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3767:	cmp    $0x6,%rcx
    376b:	je     397c <botlish_fn_19+0x25f4>
    3771:	movq   $0x3,0x40(%rsp)
    377a:	mov    0x418(%rsp),%rsi
    3782:	test   $0x1,%rsi
    3789:	jne    379c <botlish_fn_19+0x2414>
    378f:	mov    0x418(%rsp),%rsi
    3797:	jmp    37d3 <botlish_fn_19+0x244b>
    379c:	mov    0x418(%rsp),%rsi
    37a4:	mov    %rsi,%rcx
    37a7:	add    $0x2,%rcx
    37ab:	seto   %al
    37ae:	test   %al,%al
    37b0:	je     37c3 <botlish_fn_19+0x243b>
    37b6:	mov    0x418(%rsp),%rsi
    37be:	jmp    37d3 <botlish_fn_19+0x244b>
    37c3:	mov    %rcx,%rsi
    37c6:	mov    %rcx,0x418(%rsp)
    37ce:	jmp    37f3 <botlish_fn_19+0x246b>
    37d3:	mov    0x488(%rsp),%rdx
    37db:	mov    0x3c0(%rsp),%rdi
    37e3:	call   37e8 <botlish_fn_19+0x2460>
			37e4: R_X86_64_PLT32	rt_int_add-0x4
    37e8:	mov    %rax,%rsi
    37eb:	mov    %rax,0x418(%rsp)
    37f3:	mov    %rsi,0x70(%rsp)
    37f8:	mov    0x490(%rsp),%rcx
    3800:	mov    0x418(%rsp),%rsi
    3808:	mov    %rsi,%rax
    380b:	and    %rcx,%rax
    380e:	test   $0x1,%rax
    3814:	jne    384d <botlish_fn_19+0x24c5>
    381a:	mov    0x490(%rsp),%rdx
    3822:	mov    0x418(%rsp),%rsi
    382a:	mov    0x3c0(%rsp),%rdi
    3832:	call   3837 <botlish_fn_19+0x24af>
			3833: R_X86_64_PLT32	rt_int_cmp-0x4
    3837:	mov    $0x2,%r9d
    383d:	test   %rax,%rax
    3840:	cmovl  0x6380(%rip),%r9        # 9bc8 <botlish_fn_19+0x8840>
    3848:	jmp    386e <botlish_fn_19+0x24e6>
    384d:	mov    $0x2,%r9d
    3853:	mov    0x490(%rsp),%rcx
    385b:	mov    0x418(%rsp),%rsi
    3863:	cmp    %rcx,%rsi
    3866:	cmovl  0x635a(%rip),%r9        # 9bc8 <botlish_fn_19+0x8840>
    386e:	cmp    $0x6,%r9
    3872:	je     38a6 <botlish_fn_19+0x251e>
    3878:	movq   $0xffffffffffffffff,0x50(%rsp)
    3881:	mov    0x478(%rsp),%rcx
    3889:	mov    0x458(%rsp),%rax
    3891:	mov    %rax,0x3e8(%rsp)
    3899:	mov    %rax,0x3f8(%rsp)
    38a1:	jmp    3aa9 <botlish_fn_19+0x2721>
    38a6:	mov    0x418(%rsp),%rsi
    38ae:	test   $0x1,%rsi
    38b5:	je     38de <botlish_fn_19+0x2556>
    38bb:	mov    0x3c8(%rsp),%rcx
    38c3:	mov    0x8(%rcx),%rcx
    38c7:	mov    0x418(%rsp),%rsi
    38cf:	mov    %rsi,%rax
    38d2:	sar    $1,%rax
    38d5:	cmp    %rcx,%rax
    38d8:	jb     391c <botlish_fn_19+0x2594>
    38de:	mov    0x418(%rsp),%rdx
    38e6:	mov    0x3c8(%rsp),%rsi
    38ee:	mov    0x3c0(%rsp),%rdi
    38f6:	call   38fb <botlish_fn_19+0x2573>
			38f7: R_X86_64_PLT32	rt_list_get-0x4
    38fb:	mov    %rax,%rcx
    38fe:	mov    %rax,0x410(%rsp)
    3906:	test   %rcx,%rax
    3909:	je     39e5 <botlish_fn_19+0x265d>
    390f:	mov    0x410(%rsp),%rax
    3917:	jmp    3934 <botlish_fn_19+0x25ac>
    391c:	mov    0x3c8(%rsp),%rcx
    3924:	mov    0x10(%rcx),%rcx
    3928:	mov    (%rcx,%rax,8),%rax
    392c:	mov    %rax,0x410(%rsp)
    3934:	mov    %rax,0x78(%rsp)
    3939:	mov    0x410(%rsp),%rsi
    3941:	mov    0x3c0(%rsp),%rdi
    3949:	call   394e <botlish_fn_19+0x25c6>
			394a: R_X86_64_PLT32	rt_list_len-0x4
    394e:	mov    %rax,0x408(%rsp)
    3956:	mov    %rax,0x80(%rsp)
    395e:	mov    $0x1,%esi
    3963:	mov    %rsi,0x400(%rsp)
    396b:	movq   $0x1,0x88(%rsp)
    3977:	jmp    3705 <botlish_fn_19+0x237d>
    397c:	mov    0x400(%rsp),%rsi
    3984:	test   $0x1,%rsi
    398b:	je     39b4 <botlish_fn_19+0x262c>
    3991:	mov    0x410(%rsp),%rax
    3999:	mov    0x8(%rax),%rcx
    399d:	mov    0x400(%rsp),%rsi
    39a5:	mov    %rsi,%rax
    39a8:	sar    $1,%rax
    39ab:	cmp    %rcx,%rax
    39ae:	jb     3a77 <botlish_fn_19+0x26ef>
    39b4:	mov    0x400(%rsp),%rdx
    39bc:	mov    0x410(%rsp),%rsi
    39c4:	mov    0x3c0(%rsp),%rdi
    39cc:	call   39d1 <botlish_fn_19+0x2649>
			39cd: R_X86_64_PLT32	rt_list_get-0x4
    39d1:	mov    %rax,%rsi
    39d4:	mov    %rax,0x3f8(%rsp)
    39dc:	test   %rsi,%rax
    39df:	jne    3a6a <botlish_fn_19+0x26e2>
    39e5:	mov    0x3c0(%rsp),%rdi
    39ed:	call   39f2 <botlish_fn_19+0x266a>
			39ee: R_X86_64_PLT32	rt_co_failed-0x4
    39f2:	mov    %rax,0x58(%rsp)
    39f7:	mov    %rax,%rsi
    39fa:	mov    0x3c0(%rsp),%rdi
    3a02:	call   3a07 <botlish_fn_19+0x267f>
			3a03: R_X86_64_PLT32	rt_co_resume0-0x4
    3a07:	test   %rax,%rax
    3a0a:	jne    3a1d <botlish_fn_19+0x2695>
    3a10:	mov    0x3c0(%rsp),%rdi
    3a18:	jmp    3a4c <botlish_fn_19+0x26c4>
    3a1d:	mov    0x3c0(%rsp),%rdi
    3a25:	mov    0x10(%rdi),%rsi
    3a29:	mov    0x48(%rsi),%rdi
    3a2d:	mov    0x1b8(%rsi),%rdx
    3a34:	mov    %rdi,%rsi
    3a37:	mov    0x3c0(%rsp),%rdi
    3a3f:	call   3a44 <botlish_fn_19+0x26bc>
			3a40: R_X86_64_PLT32	rt_raise-0x4
    3a44:	mov    0x3c0(%rsp),%rdi
    3a4c:	mov    0x3c0(%rsp),%rdi
    3a54:	call   3a59 <botlish_fn_19+0x26d1>
			3a55: R_X86_64_PLT32	rt_declared_error-0x4
    3a59:	cmp    $0x40000001,%rax
    3a5f:	jne    9a02 <botlish_fn_19+0x867a>
    3a65:	jmp    9a02 <botlish_fn_19+0x867a>
    3a6a:	mov    0x3f8(%rsp),%rax
    3a72:	jmp    3a8f <botlish_fn_19+0x2707>
    3a77:	mov    0x410(%rsp),%rcx
    3a7f:	mov    0x10(%rcx),%r10
    3a83:	mov    (%r10,%rax,8),%rax
    3a87:	mov    %rax,0x3f8(%rsp)
    3a8f:	mov    %rax,0x50(%rsp)
    3a94:	mov    $0x1,%ecx
    3a99:	mov    %rcx,0x3e8(%rsp)
    3aa1:	mov    0x478(%rsp),%rcx
    3aa9:	mov    0x478(%rsp),%rcx
    3ab1:	mov    0x18(%rcx),%rax
    3ab5:	test   %rax,%rax
    3ab8:	je     9b1b <botlish_fn_19+0x8793>
    3abe:	mov    0x478(%rsp),%rcx
    3ac6:	mov    0x10(%rcx),%rax
    3aca:	mov    0x3f8(%rsp),%rcx
    3ad2:	mov    %rcx,(%rax)
    3ad5:	test   %r13,%r13
    3ad8:	jl     843d <botlish_fn_19+0x70b5>
    3ade:	mov    0x470(%rsp),%rdx
    3ae6:	mov    0x10(%rdx),%rax
    3aea:	mov    (%rax),%rsi
    3aed:	mov    %rsi,0x38(%rsp)
    3af2:	mov    0x440(%rsp),%rcx
    3afa:	mov    %rsi,%rax
    3afd:	and    %rcx,%rax
    3b00:	test   $0x1,%rax
    3b06:	je     3b41 <botlish_fn_19+0x27b9>
    3b0c:	mov    0x440(%rsp),%rax
    3b14:	mov    %rsi,%rcx
    3b17:	sub    %rax,%rcx
    3b1a:	mov    %rsi,%rdx
    3b1d:	seto   %al
    3b20:	lea    0x1(%rcx),%rsi
    3b24:	test   %al,%al
    3b26:	je     3b34 <botlish_fn_19+0x27ac>
    3b2c:	mov    %rdx,%rsi
    3b2f:	jmp    3b41 <botlish_fn_19+0x27b9>
    3b34:	mov    0x3d8(%rsp),%rbx
    3b3c:	jmp    3b61 <botlish_fn_19+0x27d9>
    3b41:	mov    0x440(%rsp),%rdx
    3b49:	mov    0x3c0(%rsp),%rdi
    3b51:	call   3b56 <botlish_fn_19+0x27ce>
			3b52: R_X86_64_PLT32	rt_int_sub-0x4
    3b56:	mov    0x3d8(%rsp),%rbx
    3b5e:	mov    %rax,%rsi
    3b61:	mov    %rsi,%rax
    3b64:	and    %rbx,%rax
    3b67:	test   $0x1,%rax
    3b6d:	jne    3ba0 <botlish_fn_19+0x2818>
    3b73:	mov    %rbx,%rdx
    3b76:	mov    0x3c0(%rsp),%rdi
    3b7e:	call   3b83 <botlish_fn_19+0x27fb>
			3b7f: R_X86_64_PLT32	rt_int_cmp-0x4
    3b83:	mov    %rbx,0x3d8(%rsp)
    3b8b:	mov    $0x2,%ecx
    3b90:	test   %rax,%rax
    3b93:	cmovge 0x602d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3b9b:	jmp    3bc0 <botlish_fn_19+0x2838>
    3ba0:	mov    %rbx,0x3d8(%rsp)
    3ba8:	mov    $0x2,%ecx
    3bad:	mov    0x3d8(%rsp),%rdi
    3bb5:	cmp    %rdi,%rsi
    3bb8:	cmovge 0x6008(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3bc0:	cmp    $0x6,%rcx
    3bc4:	je     83e8 <botlish_fn_19+0x7060>
    3bca:	mov    0x478(%rsp),%rcx
    3bd2:	mov    0x10(%rcx),%rax
    3bd6:	mov    (%rax),%rsi
    3bd9:	cmp    $0x1,%r13
    3bdd:	je     7473 <botlish_fn_19+0x60eb>
    3be3:	cmp    $0x2,%r13
    3be7:	je     6a1b <botlish_fn_19+0x5693>
    3bed:	cmp    $0x3,%r13
    3bf1:	je     64a7 <botlish_fn_19+0x511f>
    3bf7:	cmp    $0x4,%r13
    3bfb:	je     4b6b <botlish_fn_19+0x37e3>
    3c01:	cmp    $0x5,%r13
    3c05:	je     3c27 <botlish_fn_19+0x289f>
    3c0b:	mov    $0xa,%esi
    3c10:	cmp    $0xffffffffffffffff,%r13
    3c14:	jne    8220 <botlish_fn_19+0x6e98>
    3c1a:	mov    0x3e0(%rsp),%rbx
    3c22:	jmp    83af <botlish_fn_19+0x7027>
    3c27:	mov    %r15,%rbx
    3c2a:	sar    $1,%r15
    3c2d:	cmp    $0x6,%r15
    3c31:	jl     43cf <botlish_fn_19+0x3047>
    3c37:	cmp    $0x9,%r15
    3c3b:	jl     4134 <botlish_fn_19+0x2dac>
    3c41:	cmp    $0xa,%r15
    3c45:	jl     405d <botlish_fn_19+0x2cd5>
    3c4b:	cmp    $0xb,%r15
    3c4f:	jl     3d2c <botlish_fn_19+0x29a4>
    3c55:	test   $0x1,%rsi
    3c5c:	mov    %rsi,%r13
    3c5f:	jne    3c8f <botlish_fn_19+0x2907>
    3c65:	mov    $0xcb,%edx
    3c6a:	mov    %r13,%rsi
    3c6d:	mov    0x3c0(%rsp),%rdi
    3c75:	call   3c7a <botlish_fn_19+0x28f2>
			3c76: R_X86_64_PLT32	rt_int_cmp-0x4
    3c7a:	mov    $0x2,%ecx
    3c7f:	test   %rax,%rax
    3c82:	cmovl  0x5f3e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3c8a:	jmp    3ca6 <botlish_fn_19+0x291e>
    3c8f:	mov    $0x2,%ecx
    3c94:	mov    %r13,%rsi
    3c97:	cmp    $0xcb,%rsi
    3c9e:	cmovl  0x5f22(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3ca6:	cmp    $0x6,%rcx
    3caa:	je     3d21 <botlish_fn_19+0x2999>
    3cb0:	mov    %r13,%rsi
    3cb3:	test   $0x1,%rsi
    3cba:	jne    3cea <botlish_fn_19+0x2962>
    3cc0:	mov    $0xcd,%edx
    3cc5:	mov    %r13,%rsi
    3cc8:	mov    0x3c0(%rsp),%rdi
    3cd0:	call   3cd5 <botlish_fn_19+0x294d>
			3cd1: R_X86_64_PLT32	rt_int_cmp-0x4
    3cd5:	mov    $0x2,%ecx
    3cda:	test   %rax,%rax
    3cdd:	cmovl  0x5ee3(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3ce5:	jmp    3d01 <botlish_fn_19+0x2979>
    3cea:	mov    $0x2,%ecx
    3cef:	mov    %r13,%rsi
    3cf2:	cmp    $0xcd,%rsi
    3cf9:	cmovl  0x5ec7(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3d01:	cmp    $0x6,%rcx
    3d05:	je     3d16 <botlish_fn_19+0x298e>
    3d0b:	mov    $0x33,%r15d
    3d11:	jmp    4a13 <botlish_fn_19+0x368b>
    3d16:	mov    $0x15,%r15d
    3d1c:	jmp    4a13 <botlish_fn_19+0x368b>
    3d21:	mov    $0x33,%r15d
    3d27:	jmp    4a13 <botlish_fn_19+0x368b>
    3d2c:	mov    %rsi,%r13
    3d2f:	test   $0x1,%rsi
    3d36:	jne    3d66 <botlish_fn_19+0x29de>
    3d3c:	mov    $0x41,%edx
    3d41:	mov    %r13,%rsi
    3d44:	mov    0x3c0(%rsp),%rdi
    3d4c:	call   3d51 <botlish_fn_19+0x29c9>
			3d4d: R_X86_64_PLT32	rt_int_cmp-0x4
    3d51:	mov    $0x2,%ecx
    3d56:	test   %rax,%rax
    3d59:	cmovl  0x5e67(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3d61:	jmp    3d7a <botlish_fn_19+0x29f2>
    3d66:	mov    $0x2,%ecx
    3d6b:	mov    %r13,%rsi
    3d6e:	cmp    $0x41,%rsi
    3d72:	cmovl  0x5e4e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3d7a:	cmp    $0x6,%rcx
    3d7e:	je     3f24 <botlish_fn_19+0x2b9c>
    3d84:	mov    %r13,%rsi
    3d87:	test   $0x1,%rsi
    3d8e:	jne    3dbe <botlish_fn_19+0x2a36>
    3d94:	mov    $0xbb,%edx
    3d99:	mov    %r13,%rsi
    3d9c:	mov    0x3c0(%rsp),%rdi
    3da4:	call   3da9 <botlish_fn_19+0x2a21>
			3da5: R_X86_64_PLT32	rt_int_cmp-0x4
    3da9:	mov    $0x2,%ecx
    3dae:	test   %rax,%rax
    3db1:	cmovl  0x5e0f(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3db9:	jmp    3dd5 <botlish_fn_19+0x2a4d>
    3dbe:	mov    $0x2,%ecx
    3dc3:	mov    %r13,%rsi
    3dc6:	cmp    $0xbb,%rsi
    3dcd:	cmovl  0x5df3(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3dd5:	cmp    $0x6,%rcx
    3dd9:	je     3ed4 <botlish_fn_19+0x2b4c>
    3ddf:	mov    %r13,%rsi
    3de2:	test   $0x1,%rsi
    3de9:	jne    3e19 <botlish_fn_19+0x2a91>
    3def:	mov    $0xfb,%edx
    3df4:	mov    %r13,%rsi
    3df7:	mov    0x3c0(%rsp),%rdi
    3dff:	call   3e04 <botlish_fn_19+0x2a7c>
			3e00: R_X86_64_PLT32	rt_int_cmp-0x4
    3e04:	mov    $0x2,%ecx
    3e09:	test   %rax,%rax
    3e0c:	cmovl  0x5db4(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3e14:	jmp    3e30 <botlish_fn_19+0x2aa8>
    3e19:	mov    $0x2,%ecx
    3e1e:	mov    %r13,%rsi
    3e21:	cmp    $0xfb,%rsi
    3e28:	cmovl  0x5d98(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3e30:	cmp    $0x6,%rcx
    3e34:	je     3eab <botlish_fn_19+0x2b23>
    3e3a:	mov    %r13,%rsi
    3e3d:	test   $0x1,%rsi
    3e44:	jne    3e74 <botlish_fn_19+0x2aec>
    3e4a:	mov    $0xfd,%edx
    3e4f:	mov    %r13,%rsi
    3e52:	mov    0x3c0(%rsp),%rdi
    3e5a:	call   3e5f <botlish_fn_19+0x2ad7>
			3e5b: R_X86_64_PLT32	rt_int_cmp-0x4
    3e5f:	mov    $0x2,%ecx
    3e64:	test   %rax,%rax
    3e67:	cmovl  0x5d59(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3e6f:	jmp    3e8b <botlish_fn_19+0x2b03>
    3e74:	mov    $0x2,%ecx
    3e79:	mov    %r13,%rsi
    3e7c:	cmp    $0xfd,%rsi
    3e83:	cmovl  0x5d3d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3e8b:	cmp    $0x6,%rcx
    3e8f:	je     3ea0 <botlish_fn_19+0x2b18>
    3e95:	mov    $0x31,%r15d
    3e9b:	jmp    4a13 <botlish_fn_19+0x368b>
    3ea0:	mov    $0x1b,%r15d
    3ea6:	jmp    4a13 <botlish_fn_19+0x368b>
    3eab:	mov    %r13,%rsi
    3eae:	mov    %rsi,%rax
    3eb1:	sar    $1,%rax
    3eb4:	cmp    $0x5e,%rax
    3eb8:	jl     3ec9 <botlish_fn_19+0x2b41>
    3ebe:	mov    $0x31,%r15d
    3ec4:	jmp    4a13 <botlish_fn_19+0x368b>
    3ec9:	mov    $0x1b,%r15d
    3ecf:	jmp    4a13 <botlish_fn_19+0x368b>
    3ed4:	mov    %r13,%rsi
    3ed7:	sar    $1,%rsi
    3eda:	cmp    $0x2c,%rsi
    3ede:	jl     3f04 <botlish_fn_19+0x2b7c>
    3ee4:	cmp    $0x2d,%rsi
    3ee8:	jl     3ef9 <botlish_fn_19+0x2b71>
    3eee:	mov    $0x31,%r15d
    3ef4:	jmp    4a13 <botlish_fn_19+0x368b>
    3ef9:	mov    $0x1b,%r15d
    3eff:	jmp    4a13 <botlish_fn_19+0x368b>
    3f04:	cmp    $0x21,%rsi
    3f08:	jl     3f19 <botlish_fn_19+0x2b91>
    3f0e:	mov    $0x31,%r15d
    3f14:	jmp    4a13 <botlish_fn_19+0x368b>
    3f19:	mov    $0x1b,%r15d
    3f1f:	jmp    4a13 <botlish_fn_19+0x368b>
    3f24:	mov    %r13,%rsi
    3f27:	test   $0x1,%rsi
    3f2e:	jne    3f5e <botlish_fn_19+0x2bd6>
    3f34:	mov    $0x13,%edx
    3f39:	mov    %r13,%rsi
    3f3c:	mov    0x3c0(%rsp),%rdi
    3f44:	call   3f49 <botlish_fn_19+0x2bc1>
			3f45: R_X86_64_PLT32	rt_int_cmp-0x4
    3f49:	mov    $0x2,%ecx
    3f4e:	test   %rax,%rax
    3f51:	cmovl  0x5c6f(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3f59:	jmp    3f72 <botlish_fn_19+0x2bea>
    3f5e:	mov    $0x2,%ecx
    3f63:	mov    %r13,%rsi
    3f66:	cmp    $0x13,%rsi
    3f6a:	cmovl  0x5c56(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    3f72:	cmp    $0x6,%rcx
    3f76:	je     3fcf <botlish_fn_19+0x2c47>
    3f7c:	mov    %r13,%rsi
    3f7f:	mov    %rsi,%rax
    3f82:	sar    $1,%rax
    3f85:	cmp    $0xd,%rax
    3f89:	jl     3faf <botlish_fn_19+0x2c27>
    3f8f:	cmp    $0xe,%rax
    3f93:	jl     3fa4 <botlish_fn_19+0x2c1c>
    3f99:	mov    $0x31,%r15d
    3f9f:	jmp    4a13 <botlish_fn_19+0x368b>
    3fa4:	mov    $0x1b,%r15d
    3faa:	jmp    4a13 <botlish_fn_19+0x368b>
    3faf:	cmp    $0xb,%rax
    3fb3:	jl     3fc4 <botlish_fn_19+0x2c3c>
    3fb9:	mov    $0x31,%r15d
    3fbf:	jmp    4a13 <botlish_fn_19+0x368b>
    3fc4:	mov    $0x1b,%r15d
    3fca:	jmp    4a13 <botlish_fn_19+0x368b>
    3fcf:	mov    %r13,%rsi
    3fd2:	test   $0x1,%rsi
    3fd9:	jne    400c <botlish_fn_19+0x2c84>
    3fdf:	mov    0x458(%rsp),%rdx
    3fe7:	mov    %r13,%rsi
    3fea:	mov    0x3c0(%rsp),%rdi
    3ff2:	call   3ff7 <botlish_fn_19+0x2c6f>
			3ff3: R_X86_64_PLT32	rt_int_cmp-0x4
    3ff7:	mov    $0x2,%ecx
    3ffc:	test   %rax,%rax
    3fff:	cmovl  0x5bc1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4007:	jmp    4020 <botlish_fn_19+0x2c98>
    400c:	mov    $0x2,%ecx
    4011:	mov    %r13,%rsi
    4014:	cmp    $0xffffffffffffffff,%rsi
    4018:	cmovl  0x5ba8(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4020:	cmp    $0x6,%rcx
    4024:	je     4052 <botlish_fn_19+0x2cca>
    402a:	mov    %r13,%rsi
    402d:	mov    %rsi,%rax
    4030:	sar    $1,%rax
    4033:	test   %rax,%rax
    4036:	jl     4047 <botlish_fn_19+0x2cbf>
    403c:	mov    $0x31,%r15d
    4042:	jmp    4a13 <botlish_fn_19+0x368b>
    4047:	mov    $0x1b,%r15d
    404d:	jmp    4a13 <botlish_fn_19+0x368b>
    4052:	mov    $0x31,%r15d
    4058:	jmp    4a13 <botlish_fn_19+0x368b>
    405d:	mov    %rsi,%r13
    4060:	test   $0x1,%rsi
    4067:	jne    4097 <botlish_fn_19+0x2d0f>
    406d:	mov    $0xd9,%edx
    4072:	mov    %r13,%rsi
    4075:	mov    0x3c0(%rsp),%rdi
    407d:	call   4082 <botlish_fn_19+0x2cfa>
			407e: R_X86_64_PLT32	rt_int_cmp-0x4
    4082:	mov    $0x2,%ecx
    4087:	test   %rax,%rax
    408a:	cmovl  0x5b36(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4092:	jmp    40ae <botlish_fn_19+0x2d26>
    4097:	mov    $0x2,%ecx
    409c:	mov    %r13,%rsi
    409f:	cmp    $0xd9,%rsi
    40a6:	cmovl  0x5b1a(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    40ae:	cmp    $0x6,%rcx
    40b2:	je     4129 <botlish_fn_19+0x2da1>
    40b8:	mov    %r13,%rsi
    40bb:	test   $0x1,%rsi
    40c2:	jne    40f2 <botlish_fn_19+0x2d6a>
    40c8:	mov    $0xdb,%edx
    40cd:	mov    %r13,%rsi
    40d0:	mov    0x3c0(%rsp),%rdi
    40d8:	call   40dd <botlish_fn_19+0x2d55>
			40d9: R_X86_64_PLT32	rt_int_cmp-0x4
    40dd:	mov    $0x2,%ecx
    40e2:	test   %rax,%rax
    40e5:	cmovl  0x5adb(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    40ed:	jmp    4109 <botlish_fn_19+0x2d81>
    40f2:	mov    $0x2,%ecx
    40f7:	mov    %r13,%rsi
    40fa:	cmp    $0xdb,%rsi
    4101:	cmovl  0x5abf(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4109:	cmp    $0x6,%rcx
    410d:	je     411e <botlish_fn_19+0x2d96>
    4113:	mov    $0x2f,%r15d
    4119:	jmp    4a13 <botlish_fn_19+0x368b>
    411e:	mov    $0x15,%r15d
    4124:	jmp    4a13 <botlish_fn_19+0x368b>
    4129:	mov    $0x2f,%r15d
    412f:	jmp    4a13 <botlish_fn_19+0x368b>
    4134:	mov    %rsi,%r13
    4137:	cmp    $0x7,%r15
    413b:	jl     42f8 <botlish_fn_19+0x2f70>
    4141:	cmp    $0x8,%r15
    4145:	jl     4221 <botlish_fn_19+0x2e99>
    414b:	mov    %r13,%rsi
    414e:	test   $0x1,%rsi
    4155:	jne    4185 <botlish_fn_19+0x2dfd>
    415b:	mov    $0xe7,%edx
    4160:	mov    %r13,%rsi
    4163:	mov    0x3c0(%rsp),%rdi
    416b:	call   4170 <botlish_fn_19+0x2de8>
			416c: R_X86_64_PLT32	rt_int_cmp-0x4
    4170:	mov    $0x2,%ecx
    4175:	test   %rax,%rax
    4178:	cmovl  0x5a48(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4180:	jmp    419c <botlish_fn_19+0x2e14>
    4185:	mov    $0x2,%ecx
    418a:	mov    %r13,%rsi
    418d:	cmp    $0xe7,%rsi
    4194:	cmovl  0x5a2c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    419c:	cmp    $0x6,%rcx
    41a0:	je     4216 <botlish_fn_19+0x2e8e>
    41a6:	mov    %r13,%rsi
    41a9:	test   $0x1,%rsi
    41b0:	jne    41e0 <botlish_fn_19+0x2e58>
    41b6:	mov    $0xe9,%edx
    41bb:	mov    %r13,%rsi
    41be:	mov    0x3c0(%rsp),%rdi
    41c6:	call   41cb <botlish_fn_19+0x2e43>
			41c7: R_X86_64_PLT32	rt_int_cmp-0x4
    41cb:	mov    $0x2,%esi
    41d0:	test   %rax,%rax
    41d3:	cmovl  0x59ed(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    41db:	jmp    41f6 <botlish_fn_19+0x2e6e>
    41e0:	mov    $0x2,%esi
    41e5:	mov    %r13,%rax
    41e8:	cmp    $0xe9,%rax
    41ee:	cmovl  0x59d2(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    41f6:	cmp    $0x6,%rsi
    41fa:	je     420b <botlish_fn_19+0x2e83>
    4200:	mov    $0x2d,%r15d
    4206:	jmp    4a13 <botlish_fn_19+0x368b>
    420b:	mov    $0x17,%r15d
    4211:	jmp    4a13 <botlish_fn_19+0x368b>
    4216:	mov    $0x2d,%r15d
    421c:	jmp    4a13 <botlish_fn_19+0x368b>
    4221:	mov    %r13,%rsi
    4224:	test   $0x1,%rsi
    422b:	jne    425b <botlish_fn_19+0x2ed3>
    4231:	mov    $0xcb,%edx
    4236:	mov    %r13,%rsi
    4239:	mov    0x3c0(%rsp),%rdi
    4241:	call   4246 <botlish_fn_19+0x2ebe>
			4242: R_X86_64_PLT32	rt_int_cmp-0x4
    4246:	mov    $0x2,%ecx
    424b:	test   %rax,%rax
    424e:	cmovl  0x5972(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4256:	jmp    4272 <botlish_fn_19+0x2eea>
    425b:	mov    $0x2,%ecx
    4260:	mov    %r13,%rsi
    4263:	cmp    $0xcb,%rsi
    426a:	cmovl  0x5956(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4272:	cmp    $0x6,%rcx
    4276:	je     42ed <botlish_fn_19+0x2f65>
    427c:	mov    %r13,%rsi
    427f:	test   $0x1,%rsi
    4286:	jne    42b6 <botlish_fn_19+0x2f2e>
    428c:	mov    $0xcd,%edx
    4291:	mov    %r13,%rsi
    4294:	mov    0x3c0(%rsp),%rdi
    429c:	call   42a1 <botlish_fn_19+0x2f19>
			429d: R_X86_64_PLT32	rt_int_cmp-0x4
    42a1:	mov    $0x2,%ecx
    42a6:	test   %rax,%rax
    42a9:	cmovl  0x5917(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    42b1:	jmp    42cd <botlish_fn_19+0x2f45>
    42b6:	mov    $0x2,%ecx
    42bb:	mov    %r13,%rsi
    42be:	cmp    $0xcd,%rsi
    42c5:	cmovl  0x58fb(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    42cd:	cmp    $0x6,%rcx
    42d1:	je     42e2 <botlish_fn_19+0x2f5a>
    42d7:	mov    $0x2b,%r15d
    42dd:	jmp    4a13 <botlish_fn_19+0x368b>
    42e2:	mov    $0x15,%r15d
    42e8:	jmp    4a13 <botlish_fn_19+0x368b>
    42ed:	mov    $0x2b,%r15d
    42f3:	jmp    4a13 <botlish_fn_19+0x368b>
    42f8:	mov    %r13,%rsi
    42fb:	test   $0x1,%rsi
    4302:	jne    4332 <botlish_fn_19+0x2faa>
    4308:	mov    $0xd9,%edx
    430d:	mov    %r13,%rsi
    4310:	mov    0x3c0(%rsp),%rdi
    4318:	call   431d <botlish_fn_19+0x2f95>
			4319: R_X86_64_PLT32	rt_int_cmp-0x4
    431d:	mov    $0x2,%ecx
    4322:	test   %rax,%rax
    4325:	cmovl  0x589b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    432d:	jmp    4349 <botlish_fn_19+0x2fc1>
    4332:	mov    $0x2,%ecx
    4337:	mov    %r13,%rsi
    433a:	cmp    $0xd9,%rsi
    4341:	cmovl  0x587f(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4349:	cmp    $0x6,%rcx
    434d:	je     43c4 <botlish_fn_19+0x303c>
    4353:	mov    %r13,%rsi
    4356:	test   $0x1,%rsi
    435d:	jne    438d <botlish_fn_19+0x3005>
    4363:	mov    $0xdb,%edx
    4368:	mov    %r13,%rsi
    436b:	mov    0x3c0(%rsp),%rdi
    4373:	call   4378 <botlish_fn_19+0x2ff0>
			4374: R_X86_64_PLT32	rt_int_cmp-0x4
    4378:	mov    $0x2,%edi
    437d:	test   %rax,%rax
    4380:	cmovl  0x5840(%rip),%rdi        # 9bc8 <botlish_fn_19+0x8840>
    4388:	jmp    43a4 <botlish_fn_19+0x301c>
    438d:	mov    $0x2,%edi
    4392:	mov    %r13,%rsi
    4395:	cmp    $0xdb,%rsi
    439c:	cmovl  0x5824(%rip),%rdi        # 9bc8 <botlish_fn_19+0x8840>
    43a4:	cmp    $0x6,%rdi
    43a8:	je     43b9 <botlish_fn_19+0x3031>
    43ae:	mov    $0x29,%r15d
    43b4:	jmp    4a13 <botlish_fn_19+0x368b>
    43b9:	mov    $0x13,%r15d
    43bf:	jmp    4a13 <botlish_fn_19+0x368b>
    43c4:	mov    $0x29,%r15d
    43ca:	jmp    4a13 <botlish_fn_19+0x368b>
    43cf:	mov    %rsi,%r13
    43d2:	cmp    $0x3,%r15
    43d6:	jl     4675 <botlish_fn_19+0x32ed>
    43dc:	cmp    $0x4,%r15
    43e0:	jl     459e <botlish_fn_19+0x3216>
    43e6:	cmp    $0x5,%r15
    43ea:	jl     44c7 <botlish_fn_19+0x313f>
    43f0:	mov    %r13,%rsi
    43f3:	test   $0x1,%rsi
    43fa:	jne    442a <botlish_fn_19+0x30a2>
    4400:	mov    $0xd9,%edx
    4405:	mov    %r13,%rsi
    4408:	mov    0x3c0(%rsp),%rdi
    4410:	call   4415 <botlish_fn_19+0x308d>
			4411: R_X86_64_PLT32	rt_int_cmp-0x4
    4415:	mov    $0x2,%ecx
    441a:	test   %rax,%rax
    441d:	cmovl  0x57a3(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4425:	jmp    4441 <botlish_fn_19+0x30b9>
    442a:	mov    $0x2,%ecx
    442f:	mov    %r13,%rsi
    4432:	cmp    $0xd9,%rsi
    4439:	cmovl  0x5787(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4441:	cmp    $0x6,%rcx
    4445:	je     44bc <botlish_fn_19+0x3134>
    444b:	mov    %r13,%rsi
    444e:	test   $0x1,%rsi
    4455:	jne    4485 <botlish_fn_19+0x30fd>
    445b:	mov    $0xdb,%edx
    4460:	mov    %r13,%rsi
    4463:	mov    0x3c0(%rsp),%rdi
    446b:	call   4470 <botlish_fn_19+0x30e8>
			446c: R_X86_64_PLT32	rt_int_cmp-0x4
    4470:	mov    $0x2,%ecx
    4475:	test   %rax,%rax
    4478:	cmovl  0x5748(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4480:	jmp    449c <botlish_fn_19+0x3114>
    4485:	mov    $0x2,%ecx
    448a:	mov    %r13,%rsi
    448d:	cmp    $0xdb,%rsi
    4494:	cmovl  0x572c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    449c:	cmp    $0x6,%rcx
    44a0:	je     44b1 <botlish_fn_19+0x3129>
    44a6:	mov    $0x27,%r15d
    44ac:	jmp    4a13 <botlish_fn_19+0x368b>
    44b1:	mov    $0x11,%r15d
    44b7:	jmp    4a13 <botlish_fn_19+0x368b>
    44bc:	mov    $0x27,%r15d
    44c2:	jmp    4a13 <botlish_fn_19+0x368b>
    44c7:	mov    %r13,%rsi
    44ca:	test   $0x1,%rsi
    44d1:	jne    4501 <botlish_fn_19+0x3179>
    44d7:	mov    $0xeb,%edx
    44dc:	mov    %r13,%rsi
    44df:	mov    0x3c0(%rsp),%rdi
    44e7:	call   44ec <botlish_fn_19+0x3164>
			44e8: R_X86_64_PLT32	rt_int_cmp-0x4
    44ec:	mov    $0x2,%ecx
    44f1:	test   %rax,%rax
    44f4:	cmovl  0x56cc(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    44fc:	jmp    4518 <botlish_fn_19+0x3190>
    4501:	mov    $0x2,%ecx
    4506:	mov    %r13,%rsi
    4509:	cmp    $0xeb,%rsi
    4510:	cmovl  0x56b0(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4518:	cmp    $0x6,%rcx
    451c:	je     4593 <botlish_fn_19+0x320b>
    4522:	mov    %r13,%rsi
    4525:	test   $0x1,%rsi
    452c:	jne    455c <botlish_fn_19+0x31d4>
    4532:	mov    $0xed,%edx
    4537:	mov    %r13,%rsi
    453a:	mov    0x3c0(%rsp),%rdi
    4542:	call   4547 <botlish_fn_19+0x31bf>
			4543: R_X86_64_PLT32	rt_int_cmp-0x4
    4547:	mov    $0x2,%ecx
    454c:	test   %rax,%rax
    454f:	cmovl  0x5671(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4557:	jmp    4573 <botlish_fn_19+0x31eb>
    455c:	mov    $0x2,%ecx
    4561:	mov    %r13,%rsi
    4564:	cmp    $0xed,%rsi
    456b:	cmovl  0x5655(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4573:	cmp    $0x6,%rcx
    4577:	je     4588 <botlish_fn_19+0x3200>
    457d:	mov    $0x25,%r15d
    4583:	jmp    4a13 <botlish_fn_19+0x368b>
    4588:	mov    $0xf,%r15d
    458e:	jmp    4a13 <botlish_fn_19+0x368b>
    4593:	mov    $0x25,%r15d
    4599:	jmp    4a13 <botlish_fn_19+0x368b>
    459e:	mov    %r13,%rsi
    45a1:	test   $0x1,%rsi
    45a8:	jne    45d8 <botlish_fn_19+0x3250>
    45ae:	mov    $0xeb,%edx
    45b3:	mov    %r13,%rsi
    45b6:	mov    0x3c0(%rsp),%rdi
    45be:	call   45c3 <botlish_fn_19+0x323b>
			45bf: R_X86_64_PLT32	rt_int_cmp-0x4
    45c3:	mov    $0x2,%ecx
    45c8:	test   %rax,%rax
    45cb:	cmovl  0x55f5(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    45d3:	jmp    45ef <botlish_fn_19+0x3267>
    45d8:	mov    $0x2,%ecx
    45dd:	mov    %r13,%rsi
    45e0:	cmp    $0xeb,%rsi
    45e7:	cmovl  0x55d9(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    45ef:	cmp    $0x6,%rcx
    45f3:	je     466a <botlish_fn_19+0x32e2>
    45f9:	mov    %r13,%rsi
    45fc:	test   $0x1,%rsi
    4603:	jne    4633 <botlish_fn_19+0x32ab>
    4609:	mov    $0xed,%edx
    460e:	mov    %r13,%rsi
    4611:	mov    0x3c0(%rsp),%rdi
    4619:	call   461e <botlish_fn_19+0x3296>
			461a: R_X86_64_PLT32	rt_int_cmp-0x4
    461e:	mov    $0x2,%ecx
    4623:	test   %rax,%rax
    4626:	cmovl  0x559a(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    462e:	jmp    464a <botlish_fn_19+0x32c2>
    4633:	mov    $0x2,%ecx
    4638:	mov    %r13,%rsi
    463b:	cmp    $0xed,%rsi
    4642:	cmovl  0x557e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    464a:	cmp    $0x6,%rcx
    464e:	je     465f <botlish_fn_19+0x32d7>
    4654:	mov    $0x23,%r15d
    465a:	jmp    4a13 <botlish_fn_19+0x368b>
    465f:	mov    $0xd,%r15d
    4665:	jmp    4a13 <botlish_fn_19+0x368b>
    466a:	mov    $0x23,%r15d
    4670:	jmp    4a13 <botlish_fn_19+0x368b>
    4675:	test   %r15,%r15
    4678:	jle    4835 <botlish_fn_19+0x34ad>
    467e:	cmp    $0x2,%r15
    4682:	jl     475e <botlish_fn_19+0x33d6>
    4688:	mov    %r13,%rsi
    468b:	test   $0x1,%rsi
    4692:	jne    46c2 <botlish_fn_19+0x333a>
    4698:	mov    $0xc3,%edx
    469d:	mov    %r13,%rsi
    46a0:	mov    0x3c0(%rsp),%rdi
    46a8:	call   46ad <botlish_fn_19+0x3325>
			46a9: R_X86_64_PLT32	rt_int_cmp-0x4
    46ad:	mov    $0x2,%esi
    46b2:	test   %rax,%rax
    46b5:	cmovl  0x550b(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    46bd:	jmp    46d8 <botlish_fn_19+0x3350>
    46c2:	mov    $0x2,%esi
    46c7:	mov    %r13,%rax
    46ca:	cmp    $0xc3,%rax
    46d0:	cmovl  0x54f0(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    46d8:	cmp    $0x6,%rsi
    46dc:	je     4753 <botlish_fn_19+0x33cb>
    46e2:	mov    %r13,%rsi
    46e5:	test   $0x1,%rsi
    46ec:	jne    471c <botlish_fn_19+0x3394>
    46f2:	mov    $0xc5,%edx
    46f7:	mov    %r13,%rsi
    46fa:	mov    0x3c0(%rsp),%rdi
    4702:	call   4707 <botlish_fn_19+0x337f>
			4703: R_X86_64_PLT32	rt_int_cmp-0x4
    4707:	mov    $0x2,%ecx
    470c:	test   %rax,%rax
    470f:	cmovl  0x54b1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4717:	jmp    4733 <botlish_fn_19+0x33ab>
    471c:	mov    $0x2,%ecx
    4721:	mov    %r13,%rsi
    4724:	cmp    $0xc5,%rsi
    472b:	cmovl  0x5495(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4733:	cmp    $0x6,%rcx
    4737:	je     4748 <botlish_fn_19+0x33c0>
    473d:	mov    $0x21,%r15d
    4743:	jmp    4a13 <botlish_fn_19+0x368b>
    4748:	mov    $0xb,%r15d
    474e:	jmp    4a13 <botlish_fn_19+0x368b>
    4753:	mov    $0x21,%r15d
    4759:	jmp    4a13 <botlish_fn_19+0x368b>
    475e:	mov    %r13,%rsi
    4761:	test   $0x1,%rsi
    4768:	jne    4798 <botlish_fn_19+0x3410>
    476e:	mov    $0xe5,%edx
    4773:	mov    %r13,%rsi
    4776:	mov    0x3c0(%rsp),%rdi
    477e:	call   4783 <botlish_fn_19+0x33fb>
			477f: R_X86_64_PLT32	rt_int_cmp-0x4
    4783:	mov    $0x2,%ecx
    4788:	test   %rax,%rax
    478b:	cmovl  0x5435(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4793:	jmp    47af <botlish_fn_19+0x3427>
    4798:	mov    $0x2,%ecx
    479d:	mov    %r13,%rsi
    47a0:	cmp    $0xe5,%rsi
    47a7:	cmovl  0x5419(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    47af:	cmp    $0x6,%rcx
    47b3:	je     482a <botlish_fn_19+0x34a2>
    47b9:	mov    %r13,%rsi
    47bc:	test   $0x1,%rsi
    47c3:	jne    47f3 <botlish_fn_19+0x346b>
    47c9:	mov    $0xe7,%edx
    47ce:	mov    %r13,%rsi
    47d1:	mov    0x3c0(%rsp),%rdi
    47d9:	call   47de <botlish_fn_19+0x3456>
			47da: R_X86_64_PLT32	rt_int_cmp-0x4
    47de:	mov    $0x2,%ecx
    47e3:	test   %rax,%rax
    47e6:	cmovl  0x53da(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    47ee:	jmp    480a <botlish_fn_19+0x3482>
    47f3:	mov    $0x2,%ecx
    47f8:	mov    %r13,%rsi
    47fb:	cmp    $0xe7,%rsi
    4802:	cmovl  0x53be(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    480a:	cmp    $0x6,%rcx
    480e:	je     481f <botlish_fn_19+0x3497>
    4814:	mov    $0x1f,%r15d
    481a:	jmp    4a13 <botlish_fn_19+0x368b>
    481f:	mov    $0x9,%r15d
    4825:	jmp    4a13 <botlish_fn_19+0x368b>
    482a:	mov    $0x1f,%r15d
    4830:	jmp    4a13 <botlish_fn_19+0x368b>
    4835:	mov    %r13,%rsi
    4838:	test   $0x1,%rsi
    483f:	jne    486f <botlish_fn_19+0x34e7>
    4845:	mov    $0xdd,%edx
    484a:	mov    %r13,%rsi
    484d:	mov    0x3c0(%rsp),%rdi
    4855:	call   485a <botlish_fn_19+0x34d2>
			4856: R_X86_64_PLT32	rt_int_cmp-0x4
    485a:	mov    $0x2,%ecx
    485f:	test   %rax,%rax
    4862:	cmovl  0x535e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    486a:	jmp    4886 <botlish_fn_19+0x34fe>
    486f:	mov    $0x2,%ecx
    4874:	mov    %r13,%rsi
    4877:	cmp    $0xdd,%rsi
    487e:	cmovl  0x5342(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4886:	cmp    $0x6,%rcx
    488a:	je     4989 <botlish_fn_19+0x3601>
    4890:	mov    %r13,%rsi
    4893:	test   $0x1,%rsi
    489a:	jne    48ca <botlish_fn_19+0x3542>
    48a0:	mov    $0xe9,%edx
    48a5:	mov    %r13,%rsi
    48a8:	mov    0x3c0(%rsp),%rdi
    48b0:	call   48b5 <botlish_fn_19+0x352d>
			48b1: R_X86_64_PLT32	rt_int_cmp-0x4
    48b5:	mov    $0x2,%ecx
    48ba:	test   %rax,%rax
    48bd:	cmovl  0x5303(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    48c5:	jmp    48e1 <botlish_fn_19+0x3559>
    48ca:	mov    $0x2,%ecx
    48cf:	mov    %r13,%rsi
    48d2:	cmp    $0xe9,%rsi
    48d9:	cmovl  0x52e7(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    48e1:	cmp    $0x6,%rcx
    48e5:	je     495e <botlish_fn_19+0x35d6>
    48eb:	mov    %r13,%rsi
    48ee:	test   $0x1,%rsi
    48f5:	jne    4925 <botlish_fn_19+0x359d>
    48fb:	mov    $0xeb,%edx
    4900:	mov    %r13,%rsi
    4903:	mov    0x3c0(%rsp),%rdi
    490b:	call   4910 <botlish_fn_19+0x3588>
			490c: R_X86_64_PLT32	rt_int_cmp-0x4
    4910:	mov    $0x2,%ecx
    4915:	test   %rax,%rax
    4918:	cmovl  0x52a8(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4920:	jmp    493c <botlish_fn_19+0x35b4>
    4925:	mov    $0x2,%ecx
    492a:	mov    %r13,%rsi
    492d:	cmp    $0xeb,%rsi
    4934:	cmovl  0x528c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    493c:	cmp    $0x6,%rcx
    4940:	je     4951 <botlish_fn_19+0x35c9>
    4946:	mov    $0x1d,%r15d
    494c:	jmp    4a13 <botlish_fn_19+0x368b>
    4951:	mov    0x488(%rsp),%r15
    4959:	jmp    4a13 <botlish_fn_19+0x368b>
    495e:	mov    %r13,%rsi
    4961:	mov    %rsi,%rax
    4964:	sar    $1,%rax
    4967:	cmp    $0x6f,%rax
    496b:	jl     497c <botlish_fn_19+0x35f4>
    4971:	mov    $0x1d,%r15d
    4977:	jmp    4a13 <botlish_fn_19+0x368b>
    497c:	mov    0x450(%rsp),%r15
    4984:	jmp    4a13 <botlish_fn_19+0x368b>
    4989:	mov    %r13,%rsi
    498c:	test   $0x1,%rsi
    4993:	jne    49c3 <botlish_fn_19+0x363b>
    4999:	mov    $0xcd,%edx
    499e:	mov    %r13,%rsi
    49a1:	mov    0x3c0(%rsp),%rdi
    49a9:	call   49ae <botlish_fn_19+0x3626>
			49aa: R_X86_64_PLT32	rt_int_cmp-0x4
    49ae:	mov    $0x2,%ecx
    49b3:	test   %rax,%rax
    49b6:	cmovl  0x520a(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    49be:	jmp    49da <botlish_fn_19+0x3652>
    49c3:	mov    $0x2,%ecx
    49c8:	mov    %r13,%rsi
    49cb:	cmp    $0xcd,%rsi
    49d2:	cmovl  0x51ee(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    49da:	cmp    $0x6,%rcx
    49de:	je     4a0d <botlish_fn_19+0x3685>
    49e4:	mov    %r13,%rsi
    49e7:	mov    %rsi,%rax
    49ea:	sar    $1,%rax
    49ed:	cmp    $0x67,%rax
    49f1:	jl     4a02 <botlish_fn_19+0x367a>
    49f7:	mov    $0x1d,%r15d
    49fd:	jmp    4a13 <botlish_fn_19+0x368b>
    4a02:	mov    $0x5,%r15d
    4a08:	jmp    4a13 <botlish_fn_19+0x368b>
    4a0d:	mov    $0x1d,%r15d
    4a13:	mov    %r15,%rsi
    4a16:	sar    $1,%rsi
    4a19:	cmp    $0xc,%rsi
    4a1d:	jl     4b3e <botlish_fn_19+0x37b6>
    4a23:	cmp    $0xd,%rsi
    4a27:	mov    %rsi,%r12
    4a2a:	je     4b33 <botlish_fn_19+0x37ab>
    4a30:	mov    %r13,%rsi
    4a33:	test   $0x1,%rsi
    4a3a:	jne    4a6d <botlish_fn_19+0x36e5>
    4a40:	mov    0x458(%rsp),%rdx
    4a48:	mov    %r13,%rsi
    4a4b:	mov    0x3c0(%rsp),%rdi
    4a53:	call   4a58 <botlish_fn_19+0x36d0>
			4a54: R_X86_64_PLT32	rt_int_cmp-0x4
    4a58:	mov    $0x2,%ecx
    4a5d:	test   %rax,%rax
    4a60:	cmove  0x5160(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4a68:	jmp    4a81 <botlish_fn_19+0x36f9>
    4a6d:	mov    $0x2,%ecx
    4a72:	mov    %r13,%rsi
    4a75:	cmp    $0xffffffffffffffff,%rsi
    4a79:	cmove  0x5147(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4a81:	cmp    $0x6,%rcx
    4a85:	je     4ae3 <botlish_fn_19+0x375b>
    4a8b:	mov    %r12,%rsi
    4a8e:	mov    0x3c0(%rsp),%rdi
    4a96:	call   4a9b <botlish_fn_19+0x3713>
			4a97: R_X86_64_PLT32	botlish_fn_3-0x4
    4a9b:	mov    0x3c0(%rsp),%rdi
    4aa3:	mov    0x10(%rdi),%rcx
    4aa7:	mov    0x1f8(%rcx),%rdx
    4aae:	lea    0x398(%rsp),%r9
    4ab6:	mov    %rax,0x398(%rsp)
    4abe:	mov    %r13,%rsi
    4ac1:	mov    %rsi,0x3a0(%rsp)
    4ac9:	mov    $0x1,%esi
    4ace:	mov    $0x8,%ecx
    4ad3:	mov    $0x2,%r8d
    4ad9:	call   4ade <botlish_fn_19+0x3756>
			4ada: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4ade:	jmp    8208 <botlish_fn_19+0x6e80>
    4ae3:	mov    %r12,%rsi
    4ae6:	mov    0x3c0(%rsp),%rdi
    4aee:	call   4af3 <botlish_fn_19+0x376b>
			4aef: R_X86_64_PLT32	botlish_fn_3-0x4
    4af3:	mov    0x3c0(%rsp),%rdi
    4afb:	mov    0x10(%rdi),%rcx
    4aff:	mov    0x1f0(%rcx),%rdx
    4b06:	lea    0x390(%rsp),%r9
    4b0e:	mov    %rax,0x390(%rsp)
    4b16:	mov    $0x2,%esi
    4b1b:	mov    $0x1,%r8d
    4b21:	mov    0x488(%rsp),%rcx
    4b29:	call   4b2e <botlish_fn_19+0x37a6>
			4b2a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4b2e:	jmp    8208 <botlish_fn_19+0x6e80>
    4b33:	mov    %rbx,%r15
    4b36:	mov    %r14,%rbx
    4b39:	jmp    6462 <botlish_fn_19+0x50da>
    4b3e:	mov    %r15,0xe0(%rsp)
    4b46:	mov    $0x6,%r12d
    4b4c:	movq   $0x6,0xb0(%rsp)
    4b58:	mov    $0x5,%r13d
    4b5e:	mov    0x3e0(%rsp),%rbx
    4b66:	jmp    83af <botlish_fn_19+0x7027>
    4b6b:	mov    %rsi,%r13
    4b6e:	mov    %r14,%rbx
    4b71:	sar    $1,%r14
    4b74:	cmp    $0x4,%r14
    4b78:	jl     5769 <botlish_fn_19+0x43e1>
    4b7e:	cmp    $0x6,%r14
    4b82:	jl     54bb <botlish_fn_19+0x4133>
    4b88:	cmp    $0x7,%r14
    4b8c:	jl     5067 <botlish_fn_19+0x3cdf>
    4b92:	cmp    $0x8,%r14
    4b96:	jl     4f96 <botlish_fn_19+0x3c0e>
    4b9c:	mov    %r13,%rsi
    4b9f:	test   $0x1,%rsi
    4ba6:	jne    4bd6 <botlish_fn_19+0x384e>
    4bac:	mov    $0x43,%edx
    4bb1:	mov    %r13,%rsi
    4bb4:	mov    0x3c0(%rsp),%rdi
    4bbc:	call   4bc1 <botlish_fn_19+0x3839>
			4bbd: R_X86_64_PLT32	rt_int_cmp-0x4
    4bc1:	mov    $0x2,%ecx
    4bc6:	test   %rax,%rax
    4bc9:	cmovl  0x4ff7(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4bd1:	jmp    4bea <botlish_fn_19+0x3862>
    4bd6:	mov    $0x2,%ecx
    4bdb:	mov    %r13,%rsi
    4bde:	cmp    $0x43,%rsi
    4be2:	cmovl  0x4fde(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4bea:	cmp    $0x6,%rcx
    4bee:	je     4dfa <botlish_fn_19+0x3a72>
    4bf4:	mov    %r13,%rsi
    4bf7:	test   $0x1,%rsi
    4bfe:	jne    4c2e <botlish_fn_19+0x38a6>
    4c04:	mov    $0x75,%edx
    4c09:	mov    %r13,%rsi
    4c0c:	mov    0x3c0(%rsp),%rdi
    4c14:	call   4c19 <botlish_fn_19+0x3891>
			4c15: R_X86_64_PLT32	rt_int_cmp-0x4
    4c19:	mov    $0x2,%ecx
    4c1e:	test   %rax,%rax
    4c21:	cmovl  0x4f9f(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4c29:	jmp    4c42 <botlish_fn_19+0x38ba>
    4c2e:	mov    $0x2,%ecx
    4c33:	mov    %r13,%rsi
    4c36:	cmp    $0x75,%rsi
    4c3a:	cmovl  0x4f86(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4c42:	cmp    $0x6,%rcx
    4c46:	je     4da7 <botlish_fn_19+0x3a1f>
    4c4c:	mov    %r13,%rsi
    4c4f:	test   $0x1,%rsi
    4c56:	jne    4c86 <botlish_fn_19+0x38fe>
    4c5c:	mov    $0xbd,%edx
    4c61:	mov    %r13,%rsi
    4c64:	mov    0x3c0(%rsp),%rdi
    4c6c:	call   4c71 <botlish_fn_19+0x38e9>
			4c6d: R_X86_64_PLT32	rt_int_cmp-0x4
    4c71:	mov    $0x2,%ecx
    4c76:	test   %rax,%rax
    4c79:	cmovl  0x4f47(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4c81:	jmp    4c9d <botlish_fn_19+0x3915>
    4c86:	mov    $0x2,%ecx
    4c8b:	mov    %r13,%rsi
    4c8e:	cmp    $0xbd,%rsi
    4c95:	cmovl  0x4f2b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4c9d:	cmp    $0x6,%rcx
    4ca1:	je     4d7e <botlish_fn_19+0x39f6>
    4ca7:	mov    %r13,%rsi
    4caa:	test   $0x1,%rsi
    4cb1:	jne    4ce1 <botlish_fn_19+0x3959>
    4cb7:	mov    $0xfb,%edx
    4cbc:	mov    %r13,%rsi
    4cbf:	mov    0x3c0(%rsp),%rdi
    4cc7:	call   4ccc <botlish_fn_19+0x3944>
			4cc8: R_X86_64_PLT32	rt_int_cmp-0x4
    4ccc:	mov    $0x2,%ecx
    4cd1:	test   %rax,%rax
    4cd4:	cmovl  0x4eec(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4cdc:	jmp    4cf8 <botlish_fn_19+0x3970>
    4ce1:	mov    $0x2,%ecx
    4ce6:	mov    %r13,%rsi
    4ce9:	cmp    $0xfb,%rsi
    4cf0:	cmovl  0x4ed0(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4cf8:	cmp    $0x6,%rcx
    4cfc:	je     4d73 <botlish_fn_19+0x39eb>
    4d02:	mov    %r13,%rsi
    4d05:	test   $0x1,%rsi
    4d0c:	jne    4d3c <botlish_fn_19+0x39b4>
    4d12:	mov    $0xfd,%edx
    4d17:	mov    %r13,%rsi
    4d1a:	mov    0x3c0(%rsp),%rdi
    4d22:	call   4d27 <botlish_fn_19+0x399f>
			4d23: R_X86_64_PLT32	rt_int_cmp-0x4
    4d27:	mov    $0x2,%ecx
    4d2c:	test   %rax,%rax
    4d2f:	cmovl  0x4e91(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4d37:	jmp    4d53 <botlish_fn_19+0x39cb>
    4d3c:	mov    $0x2,%ecx
    4d41:	mov    %r13,%rsi
    4d44:	cmp    $0xfd,%rsi
    4d4b:	cmovl  0x4e75(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4d53:	cmp    $0x6,%rcx
    4d57:	je     4d68 <botlish_fn_19+0x39e0>
    4d5d:	mov    $0x27,%r14d
    4d63:	jmp    6342 <botlish_fn_19+0x4fba>
    4d68:	mov    $0x15,%r14d
    4d6e:	jmp    6342 <botlish_fn_19+0x4fba>
    4d73:	mov    $0x27,%r14d
    4d79:	jmp    6342 <botlish_fn_19+0x4fba>
    4d7e:	mov    %r13,%rsi
    4d81:	mov    %rsi,%rax
    4d84:	sar    $1,%rax
    4d87:	cmp    $0x5d,%rax
    4d8b:	jl     4d9c <botlish_fn_19+0x3a14>
    4d91:	mov    $0x15,%r14d
    4d97:	jmp    6342 <botlish_fn_19+0x4fba>
    4d9c:	mov    $0x27,%r14d
    4da2:	jmp    6342 <botlish_fn_19+0x4fba>
    4da7:	mov    %r13,%rsi
    4daa:	mov    %rsi,%rax
    4dad:	sar    $1,%rax
    4db0:	cmp    $0x2d,%rax
    4db4:	jl     4dda <botlish_fn_19+0x3a52>
    4dba:	cmp    $0x30,%rax
    4dbe:	jl     4dcf <botlish_fn_19+0x3a47>
    4dc4:	mov    $0x11,%r14d
    4dca:	jmp    6342 <botlish_fn_19+0x4fba>
    4dcf:	mov    $0x27,%r14d
    4dd5:	jmp    6342 <botlish_fn_19+0x4fba>
    4dda:	cmp    $0x2c,%rax
    4dde:	jl     4def <botlish_fn_19+0x3a67>
    4de4:	mov    $0x15,%r14d
    4dea:	jmp    6342 <botlish_fn_19+0x4fba>
    4def:	mov    $0x27,%r14d
    4df5:	jmp    6342 <botlish_fn_19+0x4fba>
    4dfa:	mov    %r13,%rsi
    4dfd:	test   $0x1,%rsi
    4e04:	jne    4e34 <botlish_fn_19+0x3aac>
    4e0a:	mov    $0x17,%edx
    4e0f:	mov    %r13,%rsi
    4e12:	mov    0x3c0(%rsp),%rdi
    4e1a:	call   4e1f <botlish_fn_19+0x3a97>
			4e1b: R_X86_64_PLT32	rt_int_cmp-0x4
    4e1f:	mov    $0x2,%ecx
    4e24:	test   %rax,%rax
    4e27:	cmovl  0x4d99(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4e2f:	jmp    4e48 <botlish_fn_19+0x3ac0>
    4e34:	mov    $0x2,%ecx
    4e39:	mov    %r13,%rsi
    4e3c:	cmp    $0x17,%rsi
    4e40:	cmovl  0x4d80(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4e48:	cmp    $0x6,%rcx
    4e4c:	je     4ea5 <botlish_fn_19+0x3b1d>
    4e52:	mov    %r13,%rsi
    4e55:	mov    %rsi,%rax
    4e58:	sar    $1,%rax
    4e5b:	cmp    $0xe,%rax
    4e5f:	jl     4e85 <botlish_fn_19+0x3afd>
    4e65:	cmp    $0x20,%rax
    4e69:	jl     4e7a <botlish_fn_19+0x3af2>
    4e6f:	mov    $0x15,%r14d
    4e75:	jmp    6342 <botlish_fn_19+0x4fba>
    4e7a:	mov    $0x27,%r14d
    4e80:	jmp    6342 <botlish_fn_19+0x4fba>
    4e85:	cmp    $0xd,%rax
    4e89:	jl     4e9a <botlish_fn_19+0x3b12>
    4e8f:	mov    $0x15,%r14d
    4e95:	jmp    6342 <botlish_fn_19+0x4fba>
    4e9a:	mov    $0x27,%r14d
    4ea0:	jmp    6342 <botlish_fn_19+0x4fba>
    4ea5:	mov    %r13,%rsi
    4ea8:	test   $0x1,%rsi
    4eaf:	jne    4edf <botlish_fn_19+0x3b57>
    4eb5:	mov    $0x1,%edx
    4eba:	mov    %r13,%rsi
    4ebd:	mov    0x3c0(%rsp),%rdi
    4ec5:	call   4eca <botlish_fn_19+0x3b42>
			4ec6: R_X86_64_PLT32	rt_int_cmp-0x4
    4eca:	mov    $0x2,%ecx
    4ecf:	test   %rax,%rax
    4ed2:	cmovl  0x4cee(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4eda:	jmp    4ef5 <botlish_fn_19+0x3b6d>
    4edf:	mov    $0x2,%ecx
    4ee4:	mov    %r13,%rax
    4ee7:	mov    %r13,%rsi
    4eea:	test   %rax,%rsi
    4eed:	cmovle 0x4cd3(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4ef5:	cmp    $0x6,%rcx
    4ef9:	je     4f25 <botlish_fn_19+0x3b9d>
    4eff:	mov    %r13,%rsi
    4f02:	sar    $1,%rsi
    4f05:	cmp    $0x9,%rsi
    4f09:	jl     4f1a <botlish_fn_19+0x3b92>
    4f0f:	mov    $0x15,%r14d
    4f15:	jmp    6342 <botlish_fn_19+0x4fba>
    4f1a:	mov    $0x27,%r14d
    4f20:	jmp    6342 <botlish_fn_19+0x4fba>
    4f25:	mov    %r13,%rsi
    4f28:	test   $0x1,%rsi
    4f2f:	jne    4f62 <botlish_fn_19+0x3bda>
    4f35:	mov    0x458(%rsp),%rdx
    4f3d:	mov    %r13,%rsi
    4f40:	mov    0x3c0(%rsp),%rdi
    4f48:	call   4f4d <botlish_fn_19+0x3bc5>
			4f49: R_X86_64_PLT32	rt_int_cmp-0x4
    4f4d:	mov    $0x2,%edi
    4f52:	test   %rax,%rax
    4f55:	cmovl  0x4c6b(%rip),%rdi        # 9bc8 <botlish_fn_19+0x8840>
    4f5d:	jmp    4f76 <botlish_fn_19+0x3bee>
    4f62:	mov    $0x2,%edi
    4f67:	mov    %r13,%rsi
    4f6a:	cmp    $0xffffffffffffffff,%rsi
    4f6e:	cmovl  0x4c52(%rip),%rdi        # 9bc8 <botlish_fn_19+0x8840>
    4f76:	cmp    $0x6,%rdi
    4f7a:	je     4f8b <botlish_fn_19+0x3c03>
    4f80:	mov    $0x15,%r14d
    4f86:	jmp    6342 <botlish_fn_19+0x4fba>
    4f8b:	mov    $0x27,%r14d
    4f91:	jmp    6342 <botlish_fn_19+0x4fba>
    4f96:	mov    %r13,%rsi
    4f99:	test   $0x1,%rsi
    4fa0:	jne    4fd0 <botlish_fn_19+0x3c48>
    4fa6:	mov    $0x61,%edx
    4fab:	mov    %r13,%rsi
    4fae:	mov    0x3c0(%rsp),%rdi
    4fb6:	call   4fbb <botlish_fn_19+0x3c33>
			4fb7: R_X86_64_PLT32	rt_int_cmp-0x4
    4fbb:	mov    $0x2,%ecx
    4fc0:	test   %rax,%rax
    4fc3:	cmovl  0x4bfd(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4fcb:	jmp    4fe4 <botlish_fn_19+0x3c5c>
    4fd0:	mov    $0x2,%ecx
    4fd5:	mov    %r13,%rsi
    4fd8:	cmp    $0x61,%rsi
    4fdc:	cmovl  0x4be4(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    4fe4:	cmp    $0x6,%rcx
    4fe8:	je     505c <botlish_fn_19+0x3cd4>
    4fee:	mov    %r13,%rsi
    4ff1:	test   $0x1,%rsi
    4ff8:	jne    5028 <botlish_fn_19+0x3ca0>
    4ffe:	mov    $0x75,%edx
    5003:	mov    %r13,%rsi
    5006:	mov    0x3c0(%rsp),%rdi
    500e:	call   5013 <botlish_fn_19+0x3c8b>
			500f: R_X86_64_PLT32	rt_int_cmp-0x4
    5013:	mov    $0x2,%ecx
    5018:	test   %rax,%rax
    501b:	cmovl  0x4ba5(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5023:	jmp    503c <botlish_fn_19+0x3cb4>
    5028:	mov    $0x2,%ecx
    502d:	mov    %r13,%rsi
    5030:	cmp    $0x75,%rsi
    5034:	cmovl  0x4b8c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    503c:	cmp    $0x6,%rcx
    5040:	je     5051 <botlish_fn_19+0x3cc9>
    5046:	mov    $0x25,%r14d
    504c:	jmp    6342 <botlish_fn_19+0x4fba>
    5051:	mov    $0x11,%r14d
    5057:	jmp    6342 <botlish_fn_19+0x4fba>
    505c:	mov    $0x25,%r14d
    5062:	jmp    6342 <botlish_fn_19+0x4fba>
    5067:	mov    %r13,%rsi
    506a:	test   $0x1,%rsi
    5071:	jne    50a1 <botlish_fn_19+0x3d19>
    5077:	mov    $0x5b,%edx
    507c:	mov    %r13,%rsi
    507f:	mov    0x3c0(%rsp),%rdi
    5087:	call   508c <botlish_fn_19+0x3d04>
			5088: R_X86_64_PLT32	rt_int_cmp-0x4
    508c:	mov    $0x2,%ecx
    5091:	test   %rax,%rax
    5094:	cmovl  0x4b2c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    509c:	jmp    50b5 <botlish_fn_19+0x3d2d>
    50a1:	mov    $0x2,%ecx
    50a6:	mov    %r13,%rsi
    50a9:	cmp    $0x5b,%rsi
    50ad:	cmovl  0x4b13(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    50b5:	cmp    $0x6,%rcx
    50b9:	je     52f2 <botlish_fn_19+0x3f6a>
    50bf:	mov    %r13,%rsi
    50c2:	test   $0x1,%rsi
    50c9:	jne    50f9 <botlish_fn_19+0x3d71>
    50cf:	mov    $0xbb,%edx
    50d4:	mov    %r13,%rsi
    50d7:	mov    0x3c0(%rsp),%rdi
    50df:	call   50e4 <botlish_fn_19+0x3d5c>
			50e0: R_X86_64_PLT32	rt_int_cmp-0x4
    50e4:	mov    $0x2,%ecx
    50e9:	test   %rax,%rax
    50ec:	cmovl  0x4ad4(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    50f4:	jmp    5110 <botlish_fn_19+0x3d88>
    50f9:	mov    $0x2,%ecx
    50fe:	mov    %r13,%rsi
    5101:	cmp    $0xbb,%rsi
    5108:	cmovl  0x4ab8(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5110:	cmp    $0x6,%rcx
    5114:	je     528a <botlish_fn_19+0x3f02>
    511a:	mov    %r13,%rsi
    511d:	test   $0x1,%rsi
    5124:	jne    5154 <botlish_fn_19+0x3dcc>
    512a:	mov    $0xcd,%edx
    512f:	mov    %r13,%rsi
    5132:	mov    0x3c0(%rsp),%rdi
    513a:	call   513f <botlish_fn_19+0x3db7>
			513b: R_X86_64_PLT32	rt_int_cmp-0x4
    513f:	mov    $0x2,%ecx
    5144:	test   %rax,%rax
    5147:	cmovl  0x4a79(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    514f:	jmp    516b <botlish_fn_19+0x3de3>
    5154:	mov    $0x2,%ecx
    5159:	mov    %r13,%rsi
    515c:	cmp    $0xcd,%rsi
    5163:	cmovl  0x4a5d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    516b:	cmp    $0x6,%rcx
    516f:	je     524c <botlish_fn_19+0x3ec4>
    5175:	mov    %r13,%rsi
    5178:	test   $0x1,%rsi
    517f:	jne    51af <botlish_fn_19+0x3e27>
    5185:	mov    $0xfb,%edx
    518a:	mov    %r13,%rsi
    518d:	mov    0x3c0(%rsp),%rdi
    5195:	call   519a <botlish_fn_19+0x3e12>
			5196: R_X86_64_PLT32	rt_int_cmp-0x4
    519a:	mov    $0x2,%ecx
    519f:	test   %rax,%rax
    51a2:	cmovl  0x4a1e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    51aa:	jmp    51c6 <botlish_fn_19+0x3e3e>
    51af:	mov    $0x2,%ecx
    51b4:	mov    %r13,%rsi
    51b7:	cmp    $0xfb,%rsi
    51be:	cmovl  0x4a02(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    51c6:	cmp    $0x6,%rcx
    51ca:	je     5241 <botlish_fn_19+0x3eb9>
    51d0:	mov    %r13,%rsi
    51d3:	test   $0x1,%rsi
    51da:	jne    520a <botlish_fn_19+0x3e82>
    51e0:	mov    $0xfd,%edx
    51e5:	mov    %r13,%rsi
    51e8:	mov    0x3c0(%rsp),%rdi
    51f0:	call   51f5 <botlish_fn_19+0x3e6d>
			51f1: R_X86_64_PLT32	rt_int_cmp-0x4
    51f5:	mov    $0x2,%ecx
    51fa:	test   %rax,%rax
    51fd:	cmovl  0x49c3(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5205:	jmp    5221 <botlish_fn_19+0x3e99>
    520a:	mov    $0x2,%ecx
    520f:	mov    %r13,%rsi
    5212:	cmp    $0xfd,%rsi
    5219:	cmovl  0x49a7(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5221:	cmp    $0x6,%rcx
    5225:	je     5236 <botlish_fn_19+0x3eae>
    522b:	mov    $0x23,%r14d
    5231:	jmp    6342 <botlish_fn_19+0x4fba>
    5236:	mov    $0x15,%r14d
    523c:	jmp    6342 <botlish_fn_19+0x4fba>
    5241:	mov    $0x23,%r14d
    5247:	jmp    6342 <botlish_fn_19+0x4fba>
    524c:	mov    %r13,%rsi
    524f:	mov    %rsi,%rax
    5252:	sar    $1,%rax
    5255:	cmp    $0x5e,%rax
    5259:	jl     527f <botlish_fn_19+0x3ef7>
    525f:	cmp    $0x65,%rax
    5263:	jl     5274 <botlish_fn_19+0x3eec>
    5269:	mov    $0xb,%r14d
    526f:	jmp    6342 <botlish_fn_19+0x4fba>
    5274:	mov    $0x23,%r14d
    527a:	jmp    6342 <botlish_fn_19+0x4fba>
    527f:	mov    $0x15,%r14d
    5285:	jmp    6342 <botlish_fn_19+0x4fba>
    528a:	mov    %r13,%rsi
    528d:	mov    %rsi,%rax
    5290:	sar    $1,%rax
    5293:	cmp    $0x3a,%rax
    5297:	jl     52d2 <botlish_fn_19+0x3f4a>
    529d:	cmp    $0x45,%rax
    52a1:	jl     52c7 <botlish_fn_19+0x3f3f>
    52a7:	cmp    $0x46,%rax
    52ab:	jl     52bc <botlish_fn_19+0x3f34>
    52b1:	mov    $0x23,%r14d
    52b7:	jmp    6342 <botlish_fn_19+0x4fba>
    52bc:	mov    $0xb,%r14d
    52c2:	jmp    6342 <botlish_fn_19+0x4fba>
    52c7:	mov    $0x23,%r14d
    52cd:	jmp    6342 <botlish_fn_19+0x4fba>
    52d2:	cmp    $0x30,%rax
    52d6:	jl     52e7 <botlish_fn_19+0x3f5f>
    52dc:	mov    $0xd,%r14d
    52e2:	jmp    6342 <botlish_fn_19+0x4fba>
    52e7:	mov    $0x23,%r14d
    52ed:	jmp    6342 <botlish_fn_19+0x4fba>
    52f2:	mov    %r13,%rsi
    52f5:	test   $0x1,%rsi
    52fc:	jne    532c <botlish_fn_19+0x3fa4>
    5302:	mov    $0x1b,%edx
    5307:	mov    %r13,%rsi
    530a:	mov    0x3c0(%rsp),%rdi
    5312:	call   5317 <botlish_fn_19+0x3f8f>
			5313: R_X86_64_PLT32	rt_int_cmp-0x4
    5317:	mov    $0x2,%ecx
    531c:	test   %rax,%rax
    531f:	cmovl  0x48a1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5327:	jmp    5340 <botlish_fn_19+0x3fb8>
    532c:	mov    $0x2,%ecx
    5331:	mov    %r13,%rsi
    5334:	cmp    $0x1b,%rsi
    5338:	cmovl  0x4888(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5340:	cmp    $0x6,%rcx
    5344:	je     53b2 <botlish_fn_19+0x402a>
    534a:	mov    %r13,%rsi
    534d:	mov    %rsi,%rax
    5350:	sar    $1,%rax
    5353:	cmp    $0x20,%rax
    5357:	jl     5392 <botlish_fn_19+0x400a>
    535d:	cmp    $0x21,%rax
    5361:	jl     5387 <botlish_fn_19+0x3fff>
    5367:	cmp    $0x2c,%rax
    536b:	jl     537c <botlish_fn_19+0x3ff4>
    5371:	mov    $0x15,%r14d
    5377:	jmp    6342 <botlish_fn_19+0x4fba>
    537c:	mov    $0x23,%r14d
    5382:	jmp    6342 <botlish_fn_19+0x4fba>
    5387:	mov    $0x15,%r14d
    538d:	jmp    6342 <botlish_fn_19+0x4fba>
    5392:	cmp    $0xe,%rax
    5396:	jl     53a7 <botlish_fn_19+0x401f>
    539c:	mov    $0x23,%r14d
    53a2:	jmp    6342 <botlish_fn_19+0x4fba>
    53a7:	mov    $0x15,%r14d
    53ad:	jmp    6342 <botlish_fn_19+0x4fba>
    53b2:	mov    %r13,%rsi
    53b5:	test   $0x1,%rsi
    53bc:	jne    53ec <botlish_fn_19+0x4064>
    53c2:	mov    $0x1,%edx
    53c7:	mov    %r13,%rsi
    53ca:	mov    0x3c0(%rsp),%rdi
    53d2:	call   53d7 <botlish_fn_19+0x404f>
			53d3: R_X86_64_PLT32	rt_int_cmp-0x4
    53d7:	mov    $0x2,%ecx
    53dc:	test   %rax,%rax
    53df:	cmovl  0x47e1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    53e7:	jmp    5402 <botlish_fn_19+0x407a>
    53ec:	mov    $0x2,%ecx
    53f1:	mov    %r13,%rax
    53f4:	mov    %r13,%rsi
    53f7:	test   %rax,%rsi
    53fa:	cmovle 0x47c6(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5402:	cmp    $0x6,%rcx
    5406:	je     544a <botlish_fn_19+0x40c2>
    540c:	mov    %r13,%rsi
    540f:	mov    %rsi,%rax
    5412:	sar    $1,%rax
    5415:	cmp    $0x9,%rax
    5419:	jl     543f <botlish_fn_19+0x40b7>
    541f:	cmp    $0xb,%rax
    5423:	jl     5434 <botlish_fn_19+0x40ac>
    5429:	mov    $0x23,%r14d
    542f:	jmp    6342 <botlish_fn_19+0x4fba>
    5434:	mov    $0x15,%r14d
    543a:	jmp    6342 <botlish_fn_19+0x4fba>
    543f:	mov    $0x23,%r14d
    5445:	jmp    6342 <botlish_fn_19+0x4fba>
    544a:	mov    %r13,%rsi
    544d:	test   $0x1,%rsi
    5454:	jne    5487 <botlish_fn_19+0x40ff>
    545a:	mov    0x458(%rsp),%rdx
    5462:	mov    %r13,%rsi
    5465:	mov    0x3c0(%rsp),%rdi
    546d:	call   5472 <botlish_fn_19+0x40ea>
			546e: R_X86_64_PLT32	rt_int_cmp-0x4
    5472:	mov    $0x2,%ecx
    5477:	test   %rax,%rax
    547a:	cmovl  0x4746(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5482:	jmp    549b <botlish_fn_19+0x4113>
    5487:	mov    $0x2,%ecx
    548c:	mov    %r13,%rsi
    548f:	cmp    $0xffffffffffffffff,%rsi
    5493:	cmovl  0x472d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    549b:	cmp    $0x6,%rcx
    549f:	je     54b0 <botlish_fn_19+0x4128>
    54a5:	mov    $0x15,%r14d
    54ab:	jmp    6342 <botlish_fn_19+0x4fba>
    54b0:	mov    $0x23,%r14d
    54b6:	jmp    6342 <botlish_fn_19+0x4fba>
    54bb:	cmp    $0x5,%r14
    54bf:	jl     5698 <botlish_fn_19+0x4310>
    54c5:	mov    %r13,%rsi
    54c8:	test   $0x1,%rsi
    54cf:	jne    54ff <botlish_fn_19+0x4177>
    54d5:	mov    $0x5b,%edx
    54da:	mov    %r13,%rsi
    54dd:	mov    0x3c0(%rsp),%rdi
    54e5:	call   54ea <botlish_fn_19+0x4162>
			54e6: R_X86_64_PLT32	rt_int_cmp-0x4
    54ea:	mov    $0x2,%ecx
    54ef:	test   %rax,%rax
    54f2:	cmovl  0x46ce(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    54fa:	jmp    5513 <botlish_fn_19+0x418b>
    54ff:	mov    $0x2,%ecx
    5504:	mov    %r13,%rsi
    5507:	cmp    $0x5b,%rsi
    550b:	cmovl  0x46b5(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5513:	cmp    $0x6,%rcx
    5517:	je     560c <botlish_fn_19+0x4284>
    551d:	mov    %r13,%rsi
    5520:	test   $0x1,%rsi
    5527:	jne    5557 <botlish_fn_19+0x41cf>
    552d:	mov    $0x61,%edx
    5532:	mov    %r13,%rsi
    5535:	mov    0x3c0(%rsp),%rdi
    553d:	call   5542 <botlish_fn_19+0x41ba>
			553e: R_X86_64_PLT32	rt_int_cmp-0x4
    5542:	mov    $0x2,%ecx
    5547:	test   %rax,%rax
    554a:	cmovl  0x4676(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5552:	jmp    556b <botlish_fn_19+0x41e3>
    5557:	mov    $0x2,%ecx
    555c:	mov    %r13,%rsi
    555f:	cmp    $0x61,%rsi
    5563:	cmovl  0x465d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    556b:	cmp    $0x6,%rcx
    556f:	je     55e3 <botlish_fn_19+0x425b>
    5575:	mov    %r13,%rsi
    5578:	test   $0x1,%rsi
    557f:	jne    55af <botlish_fn_19+0x4227>
    5585:	mov    $0x75,%edx
    558a:	mov    %r13,%rsi
    558d:	mov    0x3c0(%rsp),%rdi
    5595:	call   559a <botlish_fn_19+0x4212>
			5596: R_X86_64_PLT32	rt_int_cmp-0x4
    559a:	mov    $0x2,%esi
    559f:	test   %rax,%rax
    55a2:	cmovl  0x461e(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    55aa:	jmp    55c3 <botlish_fn_19+0x423b>
    55af:	mov    $0x2,%esi
    55b4:	mov    %r13,%rax
    55b7:	cmp    $0x75,%rax
    55bb:	cmovl  0x4605(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    55c3:	cmp    $0x6,%rsi
    55c7:	je     55d8 <botlish_fn_19+0x4250>
    55cd:	mov    $0x21,%r14d
    55d3:	jmp    6342 <botlish_fn_19+0x4fba>
    55d8:	mov    $0x11,%r14d
    55de:	jmp    6342 <botlish_fn_19+0x4fba>
    55e3:	mov    %r13,%rsi
    55e6:	mov    %rsi,%rax
    55e9:	sar    $1,%rax
    55ec:	cmp    $0x2e,%rax
    55f0:	jl     5601 <botlish_fn_19+0x4279>
    55f6:	mov    $0x21,%r14d
    55fc:	jmp    6342 <botlish_fn_19+0x4fba>
    5601:	mov    $0xf,%r14d
    5607:	jmp    6342 <botlish_fn_19+0x4fba>
    560c:	mov    %r13,%rsi
    560f:	test   $0x1,%rsi
    5616:	jne    5646 <botlish_fn_19+0x42be>
    561c:	mov    $0x57,%edx
    5621:	mov    %r13,%rsi
    5624:	mov    0x3c0(%rsp),%rdi
    562c:	call   5631 <botlish_fn_19+0x42a9>
			562d: R_X86_64_PLT32	rt_int_cmp-0x4
    5631:	mov    $0x2,%ecx
    5636:	test   %rax,%rax
    5639:	cmovl  0x4587(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5641:	jmp    565a <botlish_fn_19+0x42d2>
    5646:	mov    $0x2,%ecx
    564b:	mov    %r13,%rsi
    564e:	cmp    $0x57,%rsi
    5652:	cmovl  0x456e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    565a:	cmp    $0x6,%rcx
    565e:	je     568d <botlish_fn_19+0x4305>
    5664:	mov    %r13,%rsi
    5667:	mov    %rsi,%rax
    566a:	sar    $1,%rax
    566d:	cmp    $0x2c,%rax
    5671:	jl     5682 <botlish_fn_19+0x42fa>
    5677:	mov    $0x21,%r14d
    567d:	jmp    6342 <botlish_fn_19+0x4fba>
    5682:	mov    $0xf,%r14d
    5688:	jmp    6342 <botlish_fn_19+0x4fba>
    568d:	mov    $0x21,%r14d
    5693:	jmp    6342 <botlish_fn_19+0x4fba>
    5698:	mov    %r13,%rsi
    569b:	test   $0x1,%rsi
    56a2:	jne    56d2 <botlish_fn_19+0x434a>
    56a8:	mov    $0x61,%edx
    56ad:	mov    %r13,%rsi
    56b0:	mov    0x3c0(%rsp),%rdi
    56b8:	call   56bd <botlish_fn_19+0x4335>
			56b9: R_X86_64_PLT32	rt_int_cmp-0x4
    56bd:	mov    $0x2,%ecx
    56c2:	test   %rax,%rax
    56c5:	cmovl  0x44fb(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    56cd:	jmp    56e6 <botlish_fn_19+0x435e>
    56d2:	mov    $0x2,%ecx
    56d7:	mov    %r13,%rsi
    56da:	cmp    $0x61,%rsi
    56de:	cmovl  0x44e2(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    56e6:	cmp    $0x6,%rcx
    56ea:	je     575e <botlish_fn_19+0x43d6>
    56f0:	mov    %r13,%rsi
    56f3:	test   $0x1,%rsi
    56fa:	jne    572a <botlish_fn_19+0x43a2>
    5700:	mov    $0x75,%edx
    5705:	mov    %r13,%rsi
    5708:	mov    0x3c0(%rsp),%rdi
    5710:	call   5715 <botlish_fn_19+0x438d>
			5711: R_X86_64_PLT32	rt_int_cmp-0x4
    5715:	mov    $0x2,%edx
    571a:	test   %rax,%rax
    571d:	cmovl  0x44a3(%rip),%rdx        # 9bc8 <botlish_fn_19+0x8840>
    5725:	jmp    573e <botlish_fn_19+0x43b6>
    572a:	mov    $0x2,%edx
    572f:	mov    %r13,%rsi
    5732:	cmp    $0x75,%rsi
    5736:	cmovl  0x448a(%rip),%rdx        # 9bc8 <botlish_fn_19+0x8840>
    573e:	cmp    $0x6,%rdx
    5742:	je     5753 <botlish_fn_19+0x43cb>
    5748:	mov    $0x1f,%r14d
    574e:	jmp    6342 <botlish_fn_19+0x4fba>
    5753:	mov    $0xd,%r14d
    5759:	jmp    6342 <botlish_fn_19+0x4fba>
    575e:	mov    $0x1f,%r14d
    5764:	jmp    6342 <botlish_fn_19+0x4fba>
    5769:	cmp    $0x2,%r14
    576d:	jl     604d <botlish_fn_19+0x4cc5>
    5773:	cmp    $0x3,%r14
    5777:	jl     5bfd <botlish_fn_19+0x4875>
    577d:	mov    %r13,%rsi
    5780:	test   $0x1,%rsi
    5787:	jne    57b7 <botlish_fn_19+0x442f>
    578d:	mov    $0x5d,%edx
    5792:	mov    %r13,%rsi
    5795:	mov    0x3c0(%rsp),%rdi
    579d:	call   57a2 <botlish_fn_19+0x441a>
			579e: R_X86_64_PLT32	rt_int_cmp-0x4
    57a2:	mov    $0x2,%ecx
    57a7:	test   %rax,%rax
    57aa:	cmovl  0x4416(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    57b2:	jmp    57cb <botlish_fn_19+0x4443>
    57b7:	mov    $0x2,%ecx
    57bc:	mov    %r13,%rsi
    57bf:	cmp    $0x5d,%rsi
    57c3:	cmovl  0x43fd(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    57cb:	cmp    $0x6,%rcx
    57cf:	je     5a1f <botlish_fn_19+0x4697>
    57d5:	mov    %r13,%rsi
    57d8:	test   $0x1,%rsi
    57df:	jne    580f <botlish_fn_19+0x4487>
    57e5:	mov    $0xbb,%edx
    57ea:	mov    %r13,%rsi
    57ed:	mov    0x3c0(%rsp),%rdi
    57f5:	call   57fa <botlish_fn_19+0x4472>
			57f6: R_X86_64_PLT32	rt_int_cmp-0x4
    57fa:	mov    $0x2,%ecx
    57ff:	test   %rax,%rax
    5802:	cmovl  0x43be(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    580a:	jmp    5826 <botlish_fn_19+0x449e>
    580f:	mov    $0x2,%ecx
    5814:	mov    %r13,%rsi
    5817:	cmp    $0xbb,%rsi
    581e:	cmovl  0x43a2(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5826:	cmp    $0x6,%rcx
    582a:	je     59a0 <botlish_fn_19+0x4618>
    5830:	mov    %r13,%rsi
    5833:	test   $0x1,%rsi
    583a:	jne    586a <botlish_fn_19+0x44e2>
    5840:	mov    $0xcd,%edx
    5845:	mov    %r13,%rsi
    5848:	mov    0x3c0(%rsp),%rdi
    5850:	call   5855 <botlish_fn_19+0x44cd>
			5851: R_X86_64_PLT32	rt_int_cmp-0x4
    5855:	mov    $0x2,%ecx
    585a:	test   %rax,%rax
    585d:	cmovl  0x4363(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5865:	jmp    5881 <botlish_fn_19+0x44f9>
    586a:	mov    $0x2,%ecx
    586f:	mov    %r13,%rsi
    5872:	cmp    $0xcd,%rsi
    5879:	cmovl  0x4347(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5881:	cmp    $0x6,%rcx
    5885:	je     5962 <botlish_fn_19+0x45da>
    588b:	mov    %r13,%rsi
    588e:	test   $0x1,%rsi
    5895:	jne    58c5 <botlish_fn_19+0x453d>
    589b:	mov    $0xfb,%edx
    58a0:	mov    %r13,%rsi
    58a3:	mov    0x3c0(%rsp),%rdi
    58ab:	call   58b0 <botlish_fn_19+0x4528>
			58ac: R_X86_64_PLT32	rt_int_cmp-0x4
    58b0:	mov    $0x2,%ecx
    58b5:	test   %rax,%rax
    58b8:	cmovl  0x4308(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    58c0:	jmp    58dc <botlish_fn_19+0x4554>
    58c5:	mov    $0x2,%ecx
    58ca:	mov    %r13,%rsi
    58cd:	cmp    $0xfb,%rsi
    58d4:	cmovl  0x42ec(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    58dc:	cmp    $0x6,%rcx
    58e0:	je     5957 <botlish_fn_19+0x45cf>
    58e6:	mov    %r13,%rsi
    58e9:	test   $0x1,%rsi
    58f0:	jne    5920 <botlish_fn_19+0x4598>
    58f6:	mov    $0xfd,%edx
    58fb:	mov    %r13,%rsi
    58fe:	mov    0x3c0(%rsp),%rdi
    5906:	call   590b <botlish_fn_19+0x4583>
			5907: R_X86_64_PLT32	rt_int_cmp-0x4
    590b:	mov    $0x2,%ecx
    5910:	test   %rax,%rax
    5913:	cmovl  0x42ad(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    591b:	jmp    5937 <botlish_fn_19+0x45af>
    5920:	mov    $0x2,%ecx
    5925:	mov    %r13,%rsi
    5928:	cmp    $0xfd,%rsi
    592f:	cmovl  0x4291(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5937:	cmp    $0x6,%rcx
    593b:	je     594c <botlish_fn_19+0x45c4>
    5941:	mov    $0x1d,%r14d
    5947:	jmp    6342 <botlish_fn_19+0x4fba>
    594c:	mov    $0x15,%r14d
    5952:	jmp    6342 <botlish_fn_19+0x4fba>
    5957:	mov    $0x1d,%r14d
    595d:	jmp    6342 <botlish_fn_19+0x4fba>
    5962:	mov    %r13,%rsi
    5965:	mov    %rsi,%rax
    5968:	sar    $1,%rax
    596b:	cmp    $0x5e,%rax
    596f:	jl     5995 <botlish_fn_19+0x460d>
    5975:	cmp    $0x65,%rax
    5979:	jl     598a <botlish_fn_19+0x4602>
    597f:	mov    $0xb,%r14d
    5985:	jmp    6342 <botlish_fn_19+0x4fba>
    598a:	mov    $0x1d,%r14d
    5990:	jmp    6342 <botlish_fn_19+0x4fba>
    5995:	mov    $0x15,%r14d
    599b:	jmp    6342 <botlish_fn_19+0x4fba>
    59a0:	mov    %r13,%rsi
    59a3:	mov    %rsi,%rax
    59a6:	sar    $1,%rax
    59a9:	cmp    $0x3a,%rax
    59ad:	jl     59e8 <botlish_fn_19+0x4660>
    59b3:	cmp    $0x45,%rax
    59b7:	jl     59dd <botlish_fn_19+0x4655>
    59bd:	cmp    $0x46,%rax
    59c1:	jl     59d2 <botlish_fn_19+0x464a>
    59c7:	mov    $0x1d,%r14d
    59cd:	jmp    6342 <botlish_fn_19+0x4fba>
    59d2:	mov    $0xb,%r14d
    59d8:	jmp    6342 <botlish_fn_19+0x4fba>
    59dd:	mov    $0x1d,%r14d
    59e3:	jmp    6342 <botlish_fn_19+0x4fba>
    59e8:	cmp    $0x2f,%rax
    59ec:	jl     5a14 <botlish_fn_19+0x468c>
    59f2:	cmp    $0x30,%rax
    59f6:	jl     5a09 <botlish_fn_19+0x4681>
    59fc:	mov    0x450(%rsp),%r14
    5a04:	jmp    6342 <botlish_fn_19+0x4fba>
    5a09:	mov    $0x1d,%r14d
    5a0f:	jmp    6342 <botlish_fn_19+0x4fba>
    5a14:	mov    $0x9,%r14d
    5a1a:	jmp    6342 <botlish_fn_19+0x4fba>
    5a1f:	mov    %r13,%rsi
    5a22:	test   $0x1,%rsi
    5a29:	jne    5a59 <botlish_fn_19+0x46d1>
    5a2f:	mov    $0x1b,%edx
    5a34:	mov    %r13,%rsi
    5a37:	mov    0x3c0(%rsp),%rdi
    5a3f:	call   5a44 <botlish_fn_19+0x46bc>
			5a40: R_X86_64_PLT32	rt_int_cmp-0x4
    5a44:	mov    $0x2,%ecx
    5a49:	test   %rax,%rax
    5a4c:	cmovl  0x4174(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5a54:	jmp    5a6d <botlish_fn_19+0x46e5>
    5a59:	mov    $0x2,%ecx
    5a5e:	mov    %r13,%rsi
    5a61:	cmp    $0x1b,%rsi
    5a65:	cmovl  0x415b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5a6d:	cmp    $0x6,%rcx
    5a71:	je     5af4 <botlish_fn_19+0x476c>
    5a77:	mov    %r13,%rsi
    5a7a:	mov    %rsi,%rax
    5a7d:	sar    $1,%rax
    5a80:	cmp    $0x21,%rax
    5a84:	jl     5abf <botlish_fn_19+0x4737>
    5a8a:	cmp    $0x2c,%rax
    5a8e:	jl     5ab4 <botlish_fn_19+0x472c>
    5a94:	cmp    $0x2d,%rax
    5a98:	jl     5aa9 <botlish_fn_19+0x4721>
    5a9e:	mov    $0x1d,%r14d
    5aa4:	jmp    6342 <botlish_fn_19+0x4fba>
    5aa9:	mov    $0x15,%r14d
    5aaf:	jmp    6342 <botlish_fn_19+0x4fba>
    5ab4:	mov    $0x1d,%r14d
    5aba:	jmp    6342 <botlish_fn_19+0x4fba>
    5abf:	cmp    $0xe,%rax
    5ac3:	jl     5ae9 <botlish_fn_19+0x4761>
    5ac9:	cmp    $0x20,%rax
    5acd:	jl     5ade <botlish_fn_19+0x4756>
    5ad3:	mov    $0x15,%r14d
    5ad9:	jmp    6342 <botlish_fn_19+0x4fba>
    5ade:	mov    $0x1d,%r14d
    5ae4:	jmp    6342 <botlish_fn_19+0x4fba>
    5ae9:	mov    $0x15,%r14d
    5aef:	jmp    6342 <botlish_fn_19+0x4fba>
    5af4:	mov    %r13,%rsi
    5af7:	test   $0x1,%rsi
    5afe:	jne    5b2e <botlish_fn_19+0x47a6>
    5b04:	mov    $0x1,%edx
    5b09:	mov    %r13,%rsi
    5b0c:	mov    0x3c0(%rsp),%rdi
    5b14:	call   5b19 <botlish_fn_19+0x4791>
			5b15: R_X86_64_PLT32	rt_int_cmp-0x4
    5b19:	mov    $0x2,%ecx
    5b1e:	test   %rax,%rax
    5b21:	cmovl  0x409f(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5b29:	jmp    5b44 <botlish_fn_19+0x47bc>
    5b2e:	mov    $0x2,%ecx
    5b33:	mov    %r13,%rax
    5b36:	mov    %r13,%rsi
    5b39:	test   %rax,%rsi
    5b3c:	cmovle 0x4084(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5b44:	cmp    $0x6,%rcx
    5b48:	je     5b8c <botlish_fn_19+0x4804>
    5b4e:	mov    %r13,%rsi
    5b51:	mov    %rsi,%rax
    5b54:	sar    $1,%rax
    5b57:	cmp    $0x9,%rax
    5b5b:	jl     5b81 <botlish_fn_19+0x47f9>
    5b61:	cmp    $0xb,%rax
    5b65:	jl     5b76 <botlish_fn_19+0x47ee>
    5b6b:	mov    $0x1d,%r14d
    5b71:	jmp    6342 <botlish_fn_19+0x4fba>
    5b76:	mov    $0x15,%r14d
    5b7c:	jmp    6342 <botlish_fn_19+0x4fba>
    5b81:	mov    $0x1d,%r14d
    5b87:	jmp    6342 <botlish_fn_19+0x4fba>
    5b8c:	mov    %r13,%rsi
    5b8f:	test   $0x1,%rsi
    5b96:	jne    5bc9 <botlish_fn_19+0x4841>
    5b9c:	mov    0x458(%rsp),%rdx
    5ba4:	mov    %r13,%rsi
    5ba7:	mov    0x3c0(%rsp),%rdi
    5baf:	call   5bb4 <botlish_fn_19+0x482c>
			5bb0: R_X86_64_PLT32	rt_int_cmp-0x4
    5bb4:	mov    $0x2,%ecx
    5bb9:	test   %rax,%rax
    5bbc:	cmovl  0x4004(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5bc4:	jmp    5bdd <botlish_fn_19+0x4855>
    5bc9:	mov    $0x2,%ecx
    5bce:	mov    %r13,%rsi
    5bd1:	cmp    $0xffffffffffffffff,%rsi
    5bd5:	cmovl  0x3feb(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5bdd:	cmp    $0x6,%rcx
    5be1:	je     5bf2 <botlish_fn_19+0x486a>
    5be7:	mov    $0x15,%r14d
    5bed:	jmp    6342 <botlish_fn_19+0x4fba>
    5bf2:	mov    $0x1d,%r14d
    5bf8:	jmp    6342 <botlish_fn_19+0x4fba>
    5bfd:	mov    %r13,%rsi
    5c00:	test   $0x1,%rsi
    5c07:	jne    5c37 <botlish_fn_19+0x48af>
    5c0d:	mov    $0x5b,%edx
    5c12:	mov    %r13,%rsi
    5c15:	mov    0x3c0(%rsp),%rdi
    5c1d:	call   5c22 <botlish_fn_19+0x489a>
			5c1e: R_X86_64_PLT32	rt_int_cmp-0x4
    5c22:	mov    $0x2,%ecx
    5c27:	test   %rax,%rax
    5c2a:	cmovl  0x3f96(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5c32:	jmp    5c4b <botlish_fn_19+0x48c3>
    5c37:	mov    $0x2,%ecx
    5c3c:	mov    %r13,%rsi
    5c3f:	cmp    $0x5b,%rsi
    5c43:	cmovl  0x3f7d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5c4b:	cmp    $0x6,%rcx
    5c4f:	je     5e84 <botlish_fn_19+0x4afc>
    5c55:	mov    %r13,%rsi
    5c58:	test   $0x1,%rsi
    5c5f:	jne    5c8f <botlish_fn_19+0x4907>
    5c65:	mov    $0xbb,%edx
    5c6a:	mov    %r13,%rsi
    5c6d:	mov    0x3c0(%rsp),%rdi
    5c75:	call   5c7a <botlish_fn_19+0x48f2>
			5c76: R_X86_64_PLT32	rt_int_cmp-0x4
    5c7a:	mov    $0x2,%ecx
    5c7f:	test   %rax,%rax
    5c82:	cmovl  0x3f3e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5c8a:	jmp    5ca6 <botlish_fn_19+0x491e>
    5c8f:	mov    $0x2,%ecx
    5c94:	mov    %r13,%rsi
    5c97:	cmp    $0xbb,%rsi
    5c9e:	cmovl  0x3f22(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5ca6:	cmp    $0x6,%rcx
    5caa:	je     5e1f <botlish_fn_19+0x4a97>
    5cb0:	mov    %r13,%rsi
    5cb3:	test   $0x1,%rsi
    5cba:	jne    5cea <botlish_fn_19+0x4962>
    5cc0:	mov    $0xcd,%edx
    5cc5:	mov    %r13,%rsi
    5cc8:	mov    0x3c0(%rsp),%rdi
    5cd0:	call   5cd5 <botlish_fn_19+0x494d>
			5cd1: R_X86_64_PLT32	rt_int_cmp-0x4
    5cd5:	mov    $0x2,%ecx
    5cda:	test   %rax,%rax
    5cdd:	cmovl  0x3ee3(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5ce5:	jmp    5d01 <botlish_fn_19+0x4979>
    5cea:	mov    $0x2,%ecx
    5cef:	mov    %r13,%rsi
    5cf2:	cmp    $0xcd,%rsi
    5cf9:	cmovl  0x3ec7(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5d01:	cmp    $0x6,%rcx
    5d05:	je     5de1 <botlish_fn_19+0x4a59>
    5d0b:	mov    %r13,%rsi
    5d0e:	test   $0x1,%rsi
    5d15:	jne    5d45 <botlish_fn_19+0x49bd>
    5d1b:	mov    $0xfb,%edx
    5d20:	mov    %r13,%rsi
    5d23:	mov    0x3c0(%rsp),%rdi
    5d2b:	call   5d30 <botlish_fn_19+0x49a8>
			5d2c: R_X86_64_PLT32	rt_int_cmp-0x4
    5d30:	mov    $0x2,%ecx
    5d35:	test   %rax,%rax
    5d38:	cmovl  0x3e88(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5d40:	jmp    5d5c <botlish_fn_19+0x49d4>
    5d45:	mov    $0x2,%ecx
    5d4a:	mov    %r13,%rsi
    5d4d:	cmp    $0xfb,%rsi
    5d54:	cmovl  0x3e6c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5d5c:	cmp    $0x6,%rcx
    5d60:	je     5dd6 <botlish_fn_19+0x4a4e>
    5d66:	mov    %r13,%rsi
    5d69:	test   $0x1,%rsi
    5d70:	jne    5da0 <botlish_fn_19+0x4a18>
    5d76:	mov    $0xfd,%edx
    5d7b:	mov    %r13,%rsi
    5d7e:	mov    0x3c0(%rsp),%rdi
    5d86:	call   5d8b <botlish_fn_19+0x4a03>
			5d87: R_X86_64_PLT32	rt_int_cmp-0x4
    5d8b:	mov    $0x2,%esi
    5d90:	test   %rax,%rax
    5d93:	cmovl  0x3e2d(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    5d9b:	jmp    5db6 <botlish_fn_19+0x4a2e>
    5da0:	mov    $0x2,%esi
    5da5:	mov    %r13,%rax
    5da8:	cmp    $0xfd,%rax
    5dae:	cmovl  0x3e12(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    5db6:	cmp    $0x6,%rsi
    5dba:	je     5dcb <botlish_fn_19+0x4a43>
    5dc0:	mov    $0x1b,%r14d
    5dc6:	jmp    6342 <botlish_fn_19+0x4fba>
    5dcb:	mov    $0x15,%r14d
    5dd1:	jmp    6342 <botlish_fn_19+0x4fba>
    5dd6:	mov    $0x1b,%r14d
    5ddc:	jmp    6342 <botlish_fn_19+0x4fba>
    5de1:	mov    %r13,%rsi
    5de4:	mov    %rsi,%rax
    5de7:	sar    $1,%rax
    5dea:	cmp    $0x5e,%rax
    5dee:	jl     5e14 <botlish_fn_19+0x4a8c>
    5df4:	cmp    $0x65,%rax
    5df8:	jl     5e09 <botlish_fn_19+0x4a81>
    5dfe:	mov    $0xb,%r14d
    5e04:	jmp    6342 <botlish_fn_19+0x4fba>
    5e09:	mov    $0x1b,%r14d
    5e0f:	jmp    6342 <botlish_fn_19+0x4fba>
    5e14:	mov    $0x15,%r14d
    5e1a:	jmp    6342 <botlish_fn_19+0x4fba>
    5e1f:	mov    %r13,%rsi
    5e22:	sar    $1,%rsi
    5e25:	cmp    $0x2f,%rsi
    5e29:	jl     5e64 <botlish_fn_19+0x4adc>
    5e2f:	cmp    $0x45,%rsi
    5e33:	jl     5e59 <botlish_fn_19+0x4ad1>
    5e39:	cmp    $0x46,%rsi
    5e3d:	jl     5e4e <botlish_fn_19+0x4ac6>
    5e43:	mov    $0x1b,%r14d
    5e49:	jmp    6342 <botlish_fn_19+0x4fba>
    5e4e:	mov    $0xb,%r14d
    5e54:	jmp    6342 <botlish_fn_19+0x4fba>
    5e59:	mov    $0x1b,%r14d
    5e5f:	jmp    6342 <botlish_fn_19+0x4fba>
    5e64:	cmp    $0x2e,%rsi
    5e68:	jl     5e79 <botlish_fn_19+0x4af1>
    5e6e:	mov    $0x9,%r14d
    5e74:	jmp    6342 <botlish_fn_19+0x4fba>
    5e79:	mov    $0x1b,%r14d
    5e7f:	jmp    6342 <botlish_fn_19+0x4fba>
    5e84:	mov    %r13,%rsi
    5e87:	test   $0x1,%rsi
    5e8e:	jne    5ebe <botlish_fn_19+0x4b36>
    5e94:	mov    $0x1b,%edx
    5e99:	mov    %r13,%rsi
    5e9c:	mov    0x3c0(%rsp),%rdi
    5ea4:	call   5ea9 <botlish_fn_19+0x4b21>
			5ea5: R_X86_64_PLT32	rt_int_cmp-0x4
    5ea9:	mov    $0x2,%ecx
    5eae:	test   %rax,%rax
    5eb1:	cmovl  0x3d0f(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5eb9:	jmp    5ed2 <botlish_fn_19+0x4b4a>
    5ebe:	mov    $0x2,%ecx
    5ec3:	mov    %r13,%rsi
    5ec6:	cmp    $0x1b,%rsi
    5eca:	cmovl  0x3cf6(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5ed2:	cmp    $0x6,%rcx
    5ed6:	je     5f44 <botlish_fn_19+0x4bbc>
    5edc:	mov    %r13,%rsi
    5edf:	mov    %rsi,%rax
    5ee2:	sar    $1,%rax
    5ee5:	cmp    $0x20,%rax
    5ee9:	jl     5f24 <botlish_fn_19+0x4b9c>
    5eef:	cmp    $0x21,%rax
    5ef3:	jl     5f19 <botlish_fn_19+0x4b91>
    5ef9:	cmp    $0x2c,%rax
    5efd:	jl     5f0e <botlish_fn_19+0x4b86>
    5f03:	mov    $0x15,%r14d
    5f09:	jmp    6342 <botlish_fn_19+0x4fba>
    5f0e:	mov    $0x1b,%r14d
    5f14:	jmp    6342 <botlish_fn_19+0x4fba>
    5f19:	mov    $0x15,%r14d
    5f1f:	jmp    6342 <botlish_fn_19+0x4fba>
    5f24:	cmp    $0xe,%rax
    5f28:	jl     5f39 <botlish_fn_19+0x4bb1>
    5f2e:	mov    $0x1b,%r14d
    5f34:	jmp    6342 <botlish_fn_19+0x4fba>
    5f39:	mov    $0x15,%r14d
    5f3f:	jmp    6342 <botlish_fn_19+0x4fba>
    5f44:	mov    %r13,%rsi
    5f47:	test   $0x1,%rsi
    5f4e:	jne    5f7e <botlish_fn_19+0x4bf6>
    5f54:	mov    $0x1,%edx
    5f59:	mov    %r13,%rsi
    5f5c:	mov    0x3c0(%rsp),%rdi
    5f64:	call   5f69 <botlish_fn_19+0x4be1>
			5f65: R_X86_64_PLT32	rt_int_cmp-0x4
    5f69:	mov    $0x2,%ecx
    5f6e:	test   %rax,%rax
    5f71:	cmovl  0x3c4f(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5f79:	jmp    5f94 <botlish_fn_19+0x4c0c>
    5f7e:	mov    $0x2,%ecx
    5f83:	mov    %r13,%rax
    5f86:	mov    %r13,%rsi
    5f89:	test   %rax,%rsi
    5f8c:	cmovle 0x3c34(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    5f94:	cmp    $0x6,%rcx
    5f98:	je     5fdc <botlish_fn_19+0x4c54>
    5f9e:	mov    %r13,%rsi
    5fa1:	mov    %rsi,%rax
    5fa4:	sar    $1,%rax
    5fa7:	cmp    $0x9,%rax
    5fab:	jl     5fd1 <botlish_fn_19+0x4c49>
    5fb1:	cmp    $0xb,%rax
    5fb5:	jl     5fc6 <botlish_fn_19+0x4c3e>
    5fbb:	mov    $0x1b,%r14d
    5fc1:	jmp    6342 <botlish_fn_19+0x4fba>
    5fc6:	mov    $0x15,%r14d
    5fcc:	jmp    6342 <botlish_fn_19+0x4fba>
    5fd1:	mov    $0x1b,%r14d
    5fd7:	jmp    6342 <botlish_fn_19+0x4fba>
    5fdc:	mov    %r13,%rsi
    5fdf:	test   $0x1,%rsi
    5fe6:	jne    6019 <botlish_fn_19+0x4c91>
    5fec:	mov    0x458(%rsp),%rdx
    5ff4:	mov    %r13,%rsi
    5ff7:	mov    0x3c0(%rsp),%rdi
    5fff:	call   6004 <botlish_fn_19+0x4c7c>
			6000: R_X86_64_PLT32	rt_int_cmp-0x4
    6004:	mov    $0x2,%ecx
    6009:	test   %rax,%rax
    600c:	cmovl  0x3bb4(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6014:	jmp    602d <botlish_fn_19+0x4ca5>
    6019:	mov    $0x2,%ecx
    601e:	mov    %r13,%rsi
    6021:	cmp    $0xffffffffffffffff,%rsi
    6025:	cmovl  0x3b9b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    602d:	cmp    $0x6,%rcx
    6031:	je     6042 <botlish_fn_19+0x4cba>
    6037:	mov    $0x15,%r14d
    603d:	jmp    6342 <botlish_fn_19+0x4fba>
    6042:	mov    $0x1b,%r14d
    6048:	jmp    6342 <botlish_fn_19+0x4fba>
    604d:	test   %r14,%r14
    6050:	jle    618c <botlish_fn_19+0x4e04>
    6056:	mov    %r13,%rsi
    6059:	test   $0x1,%rsi
    6060:	jne    6090 <botlish_fn_19+0x4d08>
    6066:	mov    $0x63,%edx
    606b:	mov    %r13,%rsi
    606e:	mov    0x3c0(%rsp),%rdi
    6076:	call   607b <botlish_fn_19+0x4cf3>
			6077: R_X86_64_PLT32	rt_int_cmp-0x4
    607b:	mov    $0x2,%ecx
    6080:	test   %rax,%rax
    6083:	cmovl  0x3b3d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    608b:	jmp    60a4 <botlish_fn_19+0x4d1c>
    6090:	mov    $0x2,%ecx
    6095:	mov    %r13,%rsi
    6098:	cmp    $0x63,%rsi
    609c:	cmovl  0x3b24(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    60a4:	cmp    $0x6,%rcx
    60a8:	je     611e <botlish_fn_19+0x4d96>
    60ae:	mov    %r13,%rsi
    60b1:	test   $0x1,%rsi
    60b8:	jne    60e8 <botlish_fn_19+0x4d60>
    60be:	mov    $0x75,%edx
    60c3:	mov    %r13,%rsi
    60c6:	mov    0x3c0(%rsp),%rdi
    60ce:	call   60d3 <botlish_fn_19+0x4d4b>
			60cf: R_X86_64_PLT32	rt_int_cmp-0x4
    60d3:	mov    $0x2,%ecx
    60d8:	test   %rax,%rax
    60db:	cmovl  0x3ae5(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    60e3:	jmp    60fc <botlish_fn_19+0x4d74>
    60e8:	mov    $0x2,%ecx
    60ed:	mov    %r13,%rsi
    60f0:	cmp    $0x75,%rsi
    60f4:	cmovl  0x3acc(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    60fc:	cmp    $0x6,%rcx
    6100:	je     6111 <botlish_fn_19+0x4d89>
    6106:	mov    $0x19,%r14d
    610c:	jmp    6342 <botlish_fn_19+0x4fba>
    6111:	mov    0x450(%rsp),%r14
    6119:	jmp    6342 <botlish_fn_19+0x4fba>
    611e:	mov    %r13,%rsi
    6121:	test   $0x1,%rsi
    6128:	jne    6158 <botlish_fn_19+0x4dd0>
    612e:	mov    $0x61,%edx
    6133:	mov    %r13,%rsi
    6136:	mov    0x3c0(%rsp),%rdi
    613e:	call   6143 <botlish_fn_19+0x4dbb>
			613f: R_X86_64_PLT32	rt_int_cmp-0x4
    6143:	mov    $0x2,%ecx
    6148:	test   %rax,%rax
    614b:	cmovl  0x3a75(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6153:	jmp    616c <botlish_fn_19+0x4de4>
    6158:	mov    $0x2,%ecx
    615d:	mov    %r13,%rsi
    6160:	cmp    $0x61,%rsi
    6164:	cmovl  0x3a5c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    616c:	cmp    $0x6,%rcx
    6170:	je     6181 <botlish_fn_19+0x4df9>
    6176:	mov    $0x5,%r14d
    617c:	jmp    6342 <botlish_fn_19+0x4fba>
    6181:	mov    $0x19,%r14d
    6187:	jmp    6342 <botlish_fn_19+0x4fba>
    618c:	mov    %r13,%rsi
    618f:	test   $0x1,%rsi
    6196:	jne    61c6 <botlish_fn_19+0x4e3e>
    619c:	mov    $0x61,%edx
    61a1:	mov    %r13,%rsi
    61a4:	mov    0x3c0(%rsp),%rdi
    61ac:	call   61b1 <botlish_fn_19+0x4e29>
			61ad: R_X86_64_PLT32	rt_int_cmp-0x4
    61b1:	mov    $0x2,%ecx
    61b6:	test   %rax,%rax
    61b9:	cmovl  0x3a07(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    61c1:	jmp    61da <botlish_fn_19+0x4e52>
    61c6:	mov    $0x2,%ecx
    61cb:	mov    %r13,%rsi
    61ce:	cmp    $0x61,%rsi
    61d2:	cmovl  0x39ee(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    61da:	cmp    $0x6,%rcx
    61de:	je     62b9 <botlish_fn_19+0x4f31>
    61e4:	mov    %r13,%rsi
    61e7:	test   $0x1,%rsi
    61ee:	jne    621e <botlish_fn_19+0x4e96>
    61f4:	mov    $0x63,%edx
    61f9:	mov    %r13,%rsi
    61fc:	mov    0x3c0(%rsp),%rdi
    6204:	call   6209 <botlish_fn_19+0x4e81>
			6205: R_X86_64_PLT32	rt_int_cmp-0x4
    6209:	mov    $0x2,%ecx
    620e:	test   %rax,%rax
    6211:	cmovl  0x39af(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6219:	jmp    6232 <botlish_fn_19+0x4eaa>
    621e:	mov    $0x2,%ecx
    6223:	mov    %r13,%rsi
    6226:	cmp    $0x63,%rsi
    622a:	cmovl  0x3996(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6232:	cmp    $0x6,%rcx
    6236:	je     62ae <botlish_fn_19+0x4f26>
    623c:	mov    %r13,%rsi
    623f:	test   $0x1,%rsi
    6246:	jne    6277 <botlish_fn_19+0x4eef>
    624c:	mov    $0x75,%edx
    6251:	mov    %r13,%rsi
    6254:	mov    0x3c0(%rsp),%rdi
    625c:	call   6261 <botlish_fn_19+0x4ed9>
			625d: R_X86_64_PLT32	rt_int_cmp-0x4
    6261:	mov    $0x2,%r11d
    6267:	test   %rax,%rax
    626a:	cmovl  0x3956(%rip),%r11        # 9bc8 <botlish_fn_19+0x8840>
    6272:	jmp    628c <botlish_fn_19+0x4f04>
    6277:	mov    $0x2,%r11d
    627d:	mov    %r13,%rsi
    6280:	cmp    $0x75,%rsi
    6284:	cmovl  0x393c(%rip),%r11        # 9bc8 <botlish_fn_19+0x8840>
    628c:	cmp    $0x6,%r11
    6290:	je     62a1 <botlish_fn_19+0x4f19>
    6296:	mov    $0x17,%r14d
    629c:	jmp    6342 <botlish_fn_19+0x4fba>
    62a1:	mov    0x450(%rsp),%r14
    62a9:	jmp    6342 <botlish_fn_19+0x4fba>
    62ae:	mov    $0x5,%r14d
    62b4:	jmp    6342 <botlish_fn_19+0x4fba>
    62b9:	mov    %r13,%rsi
    62bc:	test   $0x1,%rsi
    62c3:	jne    62f3 <botlish_fn_19+0x4f6b>
    62c9:	mov    $0x5b,%edx
    62ce:	mov    %r13,%rsi
    62d1:	mov    0x3c0(%rsp),%rdi
    62d9:	call   62de <botlish_fn_19+0x4f56>
			62da: R_X86_64_PLT32	rt_int_cmp-0x4
    62de:	mov    $0x2,%ecx
    62e3:	test   %rax,%rax
    62e6:	cmovl  0x38da(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    62ee:	jmp    6307 <botlish_fn_19+0x4f7f>
    62f3:	mov    $0x2,%ecx
    62f8:	mov    %r13,%rsi
    62fb:	cmp    $0x5b,%rsi
    62ff:	cmovl  0x38c1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6307:	cmp    $0x6,%rcx
    630b:	je     633c <botlish_fn_19+0x4fb4>
    6311:	mov    %r13,%rsi
    6314:	mov    %rsi,%rax
    6317:	sar    $1,%rax
    631a:	cmp    $0x2e,%rax
    631e:	jl     632f <botlish_fn_19+0x4fa7>
    6324:	mov    $0x17,%r14d
    632a:	jmp    6342 <botlish_fn_19+0x4fba>
    632f:	mov    0x488(%rsp),%r14
    6337:	jmp    6342 <botlish_fn_19+0x4fba>
    633c:	mov    $0x17,%r14d
    6342:	mov    %r14,%rsi
    6345:	sar    $1,%rsi
    6348:	cmp    $0x9,%rsi
    634c:	jl     647a <botlish_fn_19+0x50f2>
    6352:	cmp    $0xa,%rsi
    6356:	mov    %rsi,%r12
    6359:	je     6462 <botlish_fn_19+0x50da>
    635f:	mov    %r13,%rsi
    6362:	test   $0x1,%rsi
    6369:	jne    639c <botlish_fn_19+0x5014>
    636f:	mov    0x458(%rsp),%rdx
    6377:	mov    %r13,%rsi
    637a:	mov    0x3c0(%rsp),%rdi
    6382:	call   6387 <botlish_fn_19+0x4fff>
			6383: R_X86_64_PLT32	rt_int_cmp-0x4
    6387:	mov    $0x2,%ecx
    638c:	test   %rax,%rax
    638f:	cmove  0x3831(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6397:	jmp    63b0 <botlish_fn_19+0x5028>
    639c:	mov    $0x2,%ecx
    63a1:	mov    %r13,%rsi
    63a4:	cmp    $0xffffffffffffffff,%rsi
    63a8:	cmove  0x3818(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    63b0:	cmp    $0x6,%rcx
    63b4:	je     6412 <botlish_fn_19+0x508a>
    63ba:	mov    %r12,%rsi
    63bd:	mov    0x3c0(%rsp),%rdi
    63c5:	call   63ca <botlish_fn_19+0x5042>
			63c6: R_X86_64_PLT32	botlish_fn_1-0x4
    63ca:	mov    0x3c0(%rsp),%rdi
    63d2:	mov    0x10(%rdi),%rcx
    63d6:	mov    0x1f8(%rcx),%rdx
    63dd:	lea    0x380(%rsp),%r9
    63e5:	mov    %rax,0x380(%rsp)
    63ed:	mov    %r13,%rsi
    63f0:	mov    %rsi,0x388(%rsp)
    63f8:	mov    $0x1,%esi
    63fd:	mov    $0x8,%ecx
    6402:	mov    $0x2,%r8d
    6408:	call   640d <botlish_fn_19+0x5085>
			6409: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    640d:	jmp    8208 <botlish_fn_19+0x6e80>
    6412:	mov    %r12,%rsi
    6415:	mov    0x3c0(%rsp),%rdi
    641d:	call   6422 <botlish_fn_19+0x509a>
			641e: R_X86_64_PLT32	botlish_fn_1-0x4
    6422:	mov    0x3c0(%rsp),%rdi
    642a:	mov    0x10(%rdi),%rcx
    642e:	mov    0x1f0(%rcx),%rdx
    6435:	lea    0x378(%rsp),%r9
    643d:	mov    %rax,0x378(%rsp)
    6445:	mov    $0x2,%esi
    644a:	mov    $0x1,%r8d
    6450:	mov    0x488(%rsp),%rcx
    6458:	call   645d <botlish_fn_19+0x50d5>
			6459: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    645d:	jmp    8208 <botlish_fn_19+0x6e80>
    6462:	mov    %rbx,%r14
    6465:	mov    0x3e0(%rsp),%rax
    646d:	mov    %rax,0x438(%rsp)
    6475:	jmp    699f <botlish_fn_19+0x5617>
    647a:	mov    %r14,0xd8(%rsp)
    6482:	mov    $0x6,%r12d
    6488:	movq   $0x6,0xb0(%rsp)
    6494:	mov    $0x4,%r13d
    649a:	mov    0x3e0(%rsp),%rbx
    64a2:	jmp    83af <botlish_fn_19+0x7027>
    64a7:	mov    %rsi,%r13
    64aa:	mov    0x3e0(%rsp),%rbx
    64b2:	mov    0x3e0(%rsp),%rax
    64ba:	mov    %rax,0x438(%rsp)
    64c2:	sar    $1,%rbx
    64c5:	test   %rbx,%rbx
    64c8:	jle    6775 <botlish_fn_19+0x53ed>
    64ce:	mov    %r13,%rsi
    64d1:	test   $0x1,%rsi
    64d8:	jne    6508 <botlish_fn_19+0x5180>
    64de:	mov    $0xb9,%edx
    64e3:	mov    %r13,%rsi
    64e6:	mov    0x3c0(%rsp),%rdi
    64ee:	call   64f3 <botlish_fn_19+0x516b>
			64ef: R_X86_64_PLT32	rt_int_cmp-0x4
    64f3:	mov    $0x2,%ecx
    64f8:	test   %rax,%rax
    64fb:	cmovl  0x36c5(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6503:	jmp    651f <botlish_fn_19+0x5197>
    6508:	mov    $0x2,%ecx
    650d:	mov    %r13,%rsi
    6510:	cmp    $0xb9,%rsi
    6517:	cmovl  0x36a9(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    651f:	cmp    $0x6,%rcx
    6523:	je     6684 <botlish_fn_19+0x52fc>
    6529:	mov    %r13,%rsi
    652c:	test   $0x1,%rsi
    6533:	jne    6563 <botlish_fn_19+0x51db>
    6539:	mov    $0x101,%edx
    653e:	mov    %r13,%rsi
    6541:	mov    0x3c0(%rsp),%rdi
    6549:	call   654e <botlish_fn_19+0x51c6>
			654a: R_X86_64_PLT32	rt_int_cmp-0x4
    654e:	mov    $0x2,%ecx
    6553:	test   %rax,%rax
    6556:	cmovl  0x366a(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    655e:	jmp    657a <botlish_fn_19+0x51f2>
    6563:	mov    $0x2,%ecx
    6568:	mov    %r13,%rsi
    656b:	cmp    $0x101,%rsi
    6572:	cmovl  0x364e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    657a:	cmp    $0x6,%rcx
    657e:	je     665a <botlish_fn_19+0x52d2>
    6584:	mov    %r13,%rsi
    6587:	test   $0x1,%rsi
    658e:	jne    65be <botlish_fn_19+0x5236>
    6594:	mov    $0x185,%edx
    6599:	mov    %r13,%rsi
    659c:	mov    0x3c0(%rsp),%rdi
    65a4:	call   65a9 <botlish_fn_19+0x5221>
			65a5: R_X86_64_PLT32	rt_int_cmp-0x4
    65a9:	mov    $0x2,%ecx
    65ae:	test   %rax,%rax
    65b1:	cmovl  0x360f(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    65b9:	jmp    65d5 <botlish_fn_19+0x524d>
    65be:	mov    $0x2,%ecx
    65c3:	mov    %r13,%rsi
    65c6:	cmp    $0x185,%rsi
    65cd:	cmovl  0x35f3(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    65d5:	cmp    $0x6,%rcx
    65d9:	je     6650 <botlish_fn_19+0x52c8>
    65df:	mov    %r13,%rsi
    65e2:	test   $0x1,%rsi
    65e9:	jne    661a <botlish_fn_19+0x5292>
    65ef:	mov    $0x1eb,%edx
    65f4:	mov    %r13,%rsi
    65f7:	mov    0x3c0(%rsp),%rdi
    65ff:	call   6604 <botlish_fn_19+0x527c>
			6600: R_X86_64_PLT32	rt_int_cmp-0x4
    6604:	mov    $0x2,%r11d
    660a:	test   %rax,%rax
    660d:	cmovl  0x35b3(%rip),%r11        # 9bc8 <botlish_fn_19+0x8840>
    6615:	jmp    6632 <botlish_fn_19+0x52aa>
    661a:	mov    $0x2,%r11d
    6620:	mov    %r13,%rsi
    6623:	cmp    $0x1eb,%rsi
    662a:	cmovl  0x3596(%rip),%r11        # 9bc8 <botlish_fn_19+0x8840>
    6632:	cmp    $0x6,%r11
    6636:	je     6646 <botlish_fn_19+0x52be>
    663c:	mov    $0xf,%ebx
    6641:	jmp    6841 <botlish_fn_19+0x54b9>
    6646:	mov    $0xb,%ebx
    664b:	jmp    6841 <botlish_fn_19+0x54b9>
    6650:	mov    $0xf,%ebx
    6655:	jmp    6841 <botlish_fn_19+0x54b9>
    665a:	mov    %r13,%rsi
    665d:	mov    %rsi,%rax
    6660:	sar    $1,%rax
    6663:	cmp    $0x5d,%rax
    6667:	jl     667a <botlish_fn_19+0x52f2>
    666d:	mov    0x488(%rsp),%rbx
    6675:	jmp    6841 <botlish_fn_19+0x54b9>
    667a:	mov    $0x9,%ebx
    667f:	jmp    6841 <botlish_fn_19+0x54b9>
    6684:	mov    %r13,%rsi
    6687:	test   $0x1,%rsi
    668e:	jne    66be <botlish_fn_19+0x5336>
    6694:	mov    $0x45,%edx
    6699:	mov    %r13,%rsi
    669c:	mov    0x3c0(%rsp),%rdi
    66a4:	call   66a9 <botlish_fn_19+0x5321>
			66a5: R_X86_64_PLT32	rt_int_cmp-0x4
    66a9:	mov    $0x2,%ecx
    66ae:	test   %rax,%rax
    66b1:	cmovl  0x350f(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    66b9:	jmp    66d2 <botlish_fn_19+0x534a>
    66be:	mov    $0x2,%ecx
    66c3:	mov    %r13,%rsi
    66c6:	cmp    $0x45,%rsi
    66ca:	cmovl  0x34f6(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    66d2:	cmp    $0x6,%rcx
    66d6:	je     6706 <botlish_fn_19+0x537e>
    66dc:	mov    %r13,%rsi
    66df:	mov    %rsi,%rax
    66e2:	sar    $1,%rax
    66e5:	cmp    $0x23,%rax
    66e9:	jl     66fc <botlish_fn_19+0x5374>
    66ef:	mov    0x488(%rsp),%rbx
    66f7:	jmp    6841 <botlish_fn_19+0x54b9>
    66fc:	mov    $0x5,%ebx
    6701:	jmp    6841 <botlish_fn_19+0x54b9>
    6706:	mov    %r13,%rsi
    6709:	test   $0x1,%rsi
    6710:	jne    6740 <botlish_fn_19+0x53b8>
    6716:	mov    $0x41,%edx
    671b:	mov    %r13,%rsi
    671e:	mov    0x3c0(%rsp),%rdi
    6726:	call   672b <botlish_fn_19+0x53a3>
			6727: R_X86_64_PLT32	rt_int_cmp-0x4
    672b:	mov    $0x2,%ecx
    6730:	test   %rax,%rax
    6733:	cmovl  0x348d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    673b:	jmp    6754 <botlish_fn_19+0x53cc>
    6740:	mov    $0x2,%ecx
    6745:	mov    %r13,%rsi
    6748:	cmp    $0x41,%rsi
    674c:	cmovl  0x3474(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6754:	cmp    $0x6,%rcx
    6758:	je     676b <botlish_fn_19+0x53e3>
    675e:	mov    0x488(%rsp),%rbx
    6766:	jmp    6841 <botlish_fn_19+0x54b9>
    676b:	mov    $0xf,%ebx
    6770:	jmp    6841 <botlish_fn_19+0x54b9>
    6775:	mov    %r13,%rsi
    6778:	test   $0x1,%rsi
    677f:	jne    67af <botlish_fn_19+0x5427>
    6785:	mov    $0x45,%edx
    678a:	mov    %r13,%rsi
    678d:	mov    0x3c0(%rsp),%rdi
    6795:	call   679a <botlish_fn_19+0x5412>
			6796: R_X86_64_PLT32	rt_int_cmp-0x4
    679a:	mov    $0x2,%esi
    679f:	test   %rax,%rax
    67a2:	cmovl  0x341e(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    67aa:	jmp    67c3 <botlish_fn_19+0x543b>
    67af:	mov    $0x2,%esi
    67b4:	mov    %r13,%rax
    67b7:	cmp    $0x45,%rax
    67bb:	cmovl  0x3405(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    67c3:	cmp    $0x6,%rsi
    67c7:	je     683c <botlish_fn_19+0x54b4>
    67cd:	mov    %r13,%rsi
    67d0:	test   $0x1,%rsi
    67d7:	jne    6807 <botlish_fn_19+0x547f>
    67dd:	mov    $0x47,%edx
    67e2:	mov    %r13,%rsi
    67e5:	mov    0x3c0(%rsp),%rdi
    67ed:	call   67f2 <botlish_fn_19+0x546a>
			67ee: R_X86_64_PLT32	rt_int_cmp-0x4
    67f2:	mov    $0x2,%ecx
    67f7:	test   %rax,%rax
    67fa:	cmovl  0x33c6(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6802:	jmp    681b <botlish_fn_19+0x5493>
    6807:	mov    $0x2,%ecx
    680c:	mov    %r13,%rsi
    680f:	cmp    $0x47,%rsi
    6813:	cmovl  0x33ad(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    681b:	cmp    $0x6,%rcx
    681f:	je     682f <botlish_fn_19+0x54a7>
    6825:	mov    $0xd,%ebx
    682a:	jmp    6841 <botlish_fn_19+0x54b9>
    682f:	mov    0x488(%rsp),%rbx
    6837:	jmp    6841 <botlish_fn_19+0x54b9>
    683c:	mov    $0xd,%ebx
    6841:	mov    %rbx,%rsi
    6844:	sar    $1,%rsi
    6847:	cmp    $0x2,%rsi
    684b:	jl     6a0e <botlish_fn_19+0x5686>
    6851:	cmp    $0x2,%rsi
    6855:	je     6995 <botlish_fn_19+0x560d>
    685b:	cmp    $0x4,%rsi
    685f:	je     6985 <botlish_fn_19+0x55fd>
    6865:	cmp    $0x5,%rsi
    6869:	mov    %rsi,%rbx
    686c:	je     6975 <botlish_fn_19+0x55ed>
    6872:	mov    %r13,%rsi
    6875:	test   $0x1,%rsi
    687c:	jne    68af <botlish_fn_19+0x5527>
    6882:	mov    0x458(%rsp),%rdx
    688a:	mov    %r13,%rsi
    688d:	mov    0x3c0(%rsp),%rdi
    6895:	call   689a <botlish_fn_19+0x5512>
			6896: R_X86_64_PLT32	rt_int_cmp-0x4
    689a:	mov    $0x2,%ecx
    689f:	test   %rax,%rax
    68a2:	cmove  0x331e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    68aa:	jmp    68c3 <botlish_fn_19+0x553b>
    68af:	mov    $0x2,%ecx
    68b4:	mov    %r13,%rsi
    68b7:	cmp    $0xffffffffffffffff,%rsi
    68bb:	cmove  0x3305(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    68c3:	cmp    $0x6,%rcx
    68c7:	je     6925 <botlish_fn_19+0x559d>
    68cd:	mov    %rbx,%rsi
    68d0:	mov    0x3c0(%rsp),%rdi
    68d8:	call   68dd <botlish_fn_19+0x5555>
			68d9: R_X86_64_PLT32	botlish_fn_9-0x4
    68dd:	mov    0x3c0(%rsp),%rdi
    68e5:	mov    0x10(%rdi),%rcx
    68e9:	mov    0x1f8(%rcx),%rdx
    68f0:	lea    0x368(%rsp),%r9
    68f8:	mov    %rax,0x368(%rsp)
    6900:	mov    %r13,%rsi
    6903:	mov    %rsi,0x370(%rsp)
    690b:	mov    $0x1,%esi
    6910:	mov    $0x8,%ecx
    6915:	mov    $0x2,%r8d
    691b:	call   6920 <botlish_fn_19+0x5598>
			691c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6920:	jmp    8208 <botlish_fn_19+0x6e80>
    6925:	mov    %rbx,%rsi
    6928:	mov    0x3c0(%rsp),%rdi
    6930:	call   6935 <botlish_fn_19+0x55ad>
			6931: R_X86_64_PLT32	botlish_fn_9-0x4
    6935:	mov    0x3c0(%rsp),%rdi
    693d:	mov    0x10(%rdi),%rcx
    6941:	mov    0x1f0(%rcx),%rdx
    6948:	lea    0x360(%rsp),%r9
    6950:	mov    %rax,0x360(%rsp)
    6958:	mov    $0x2,%esi
    695d:	mov    $0x1,%r8d
    6963:	mov    0x488(%rsp),%rcx
    696b:	call   6970 <botlish_fn_19+0x55e8>
			696c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6970:	jmp    8208 <botlish_fn_19+0x6e80>
    6975:	xor    %rax,%rax
    6978:	mov    0x438(%rsp),%rbx
    6980:	jmp    6a34 <botlish_fn_19+0x56ac>
    6985:	xor    %rax,%rax
    6988:	mov    0x438(%rsp),%rbx
    6990:	jmp    748c <botlish_fn_19+0x6104>
    6995:	mov    $0xfffffffffffffffd,%rsi
    699c:	mov    %rsi,%r13
    699f:	mov    %r13,%rsi
    69a2:	test   $0x1,%rsi
    69a9:	jne    69dc <botlish_fn_19+0x5654>
    69af:	mov    $0xfffffffffffffffd,%rdx
    69b6:	mov    %r13,%rsi
    69b9:	mov    0x3c0(%rsp),%rdi
    69c1:	call   69c6 <botlish_fn_19+0x563e>
			69c2: R_X86_64_PLT32	rt_int_cmp-0x4
    69c6:	mov    $0x2,%r12d
    69cc:	test   %rax,%rax
    69cf:	cmove  0x31f1(%rip),%r12        # 9bc8 <botlish_fn_19+0x8840>
    69d7:	jmp    69f1 <botlish_fn_19+0x5669>
    69dc:	mov    $0x2,%r12d
    69e2:	mov    %r13,%rsi
    69e5:	cmp    $0xfffffffffffffffd,%rsi
    69e9:	cmove  0x31d7(%rip),%r12        # 9bc8 <botlish_fn_19+0x8840>
    69f1:	mov    %r12,0xb0(%rsp)
    69f9:	mov    0x438(%rsp),%rbx
    6a01:	mov    0x458(%rsp),%r13
    6a09:	jmp    83af <botlish_fn_19+0x7027>
    6a0e:	mov    %rbx,0xc0(%rsp)
    6a16:	jmp    8368 <botlish_fn_19+0x6fe0>
    6a1b:	mov    %rsi,%r13
    6a1e:	mov    0x430(%rsp),%rsi
    6a26:	mov    0x3e0(%rsp),%rbx
    6a2e:	mov    %rsi,%rax
    6a31:	sar    $1,%rax
    6a34:	cmp    $0x4,%rax
    6a38:	jl     6db8 <botlish_fn_19+0x5a30>
    6a3e:	cmp    $0x6,%rax
    6a42:	jl     6c00 <botlish_fn_19+0x5878>
    6a48:	cmp    $0x7,%rax
    6a4c:	jl     6b29 <botlish_fn_19+0x57a1>
    6a52:	mov    %r13,%rsi
    6a55:	test   $0x1,%rsi
    6a5c:	jne    6a8c <botlish_fn_19+0x5704>
    6a62:	mov    $0x101,%edx
    6a67:	mov    %r13,%rsi
    6a6a:	mov    0x3c0(%rsp),%rdi
    6a72:	call   6a77 <botlish_fn_19+0x56ef>
			6a73: R_X86_64_PLT32	rt_int_cmp-0x4
    6a77:	mov    $0x2,%ecx
    6a7c:	test   %rax,%rax
    6a7f:	cmovl  0x3141(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6a87:	jmp    6aa3 <botlish_fn_19+0x571b>
    6a8c:	mov    $0x2,%ecx
    6a91:	mov    %r13,%rsi
    6a94:	cmp    $0x101,%rsi
    6a9b:	cmovl  0x3125(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6aa3:	cmp    $0x6,%rcx
    6aa7:	je     6b1f <botlish_fn_19+0x5797>
    6aad:	mov    %r13,%rsi
    6ab0:	test   $0x1,%rsi
    6ab7:	jne    6ae7 <botlish_fn_19+0x575f>
    6abd:	mov    $0x121,%edx
    6ac2:	mov    %r13,%rsi
    6ac5:	mov    0x3c0(%rsp),%rdi
    6acd:	call   6ad2 <botlish_fn_19+0x574a>
			6ace: R_X86_64_PLT32	rt_int_cmp-0x4
    6ad2:	mov    $0x2,%ecx
    6ad7:	test   %rax,%rax
    6ada:	cmovl  0x30e6(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6ae2:	jmp    6afe <botlish_fn_19+0x5776>
    6ae7:	mov    $0x2,%ecx
    6aec:	mov    %r13,%rsi
    6aef:	cmp    $0x121,%rsi
    6af6:	cmovl  0x30ca(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6afe:	cmp    $0x6,%rcx
    6b02:	je     6b12 <botlish_fn_19+0x578a>
    6b08:	mov    $0x23,%eax
    6b0d:	jmp    7315 <botlish_fn_19+0x5f8d>
    6b12:	mov    0x450(%rsp),%rax
    6b1a:	jmp    7315 <botlish_fn_19+0x5f8d>
    6b1f:	mov    $0x23,%eax
    6b24:	jmp    7315 <botlish_fn_19+0x5f8d>
    6b29:	mov    %r13,%rsi
    6b2c:	test   $0x1,%rsi
    6b33:	jne    6b63 <botlish_fn_19+0x57db>
    6b39:	mov    $0x101,%edx
    6b3e:	mov    %r13,%rsi
    6b41:	mov    0x3c0(%rsp),%rdi
    6b49:	call   6b4e <botlish_fn_19+0x57c6>
			6b4a: R_X86_64_PLT32	rt_int_cmp-0x4
    6b4e:	mov    $0x2,%ecx
    6b53:	test   %rax,%rax
    6b56:	cmovl  0x306a(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6b5e:	jmp    6b7a <botlish_fn_19+0x57f2>
    6b63:	mov    $0x2,%ecx
    6b68:	mov    %r13,%rsi
    6b6b:	cmp    $0x101,%rsi
    6b72:	cmovl  0x304e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6b7a:	cmp    $0x6,%rcx
    6b7e:	je     6bf6 <botlish_fn_19+0x586e>
    6b84:	mov    %r13,%rsi
    6b87:	test   $0x1,%rsi
    6b8e:	jne    6bbe <botlish_fn_19+0x5836>
    6b94:	mov    $0x181,%edx
    6b99:	mov    %r13,%rsi
    6b9c:	mov    0x3c0(%rsp),%rdi
    6ba4:	call   6ba9 <botlish_fn_19+0x5821>
			6ba5: R_X86_64_PLT32	rt_int_cmp-0x4
    6ba9:	mov    $0x2,%ecx
    6bae:	test   %rax,%rax
    6bb1:	cmovl  0x300f(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6bb9:	jmp    6bd5 <botlish_fn_19+0x584d>
    6bbe:	mov    $0x2,%ecx
    6bc3:	mov    %r13,%rsi
    6bc6:	cmp    $0x181,%rsi
    6bcd:	cmovl  0x2ff3(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6bd5:	cmp    $0x6,%rcx
    6bd9:	je     6be9 <botlish_fn_19+0x5861>
    6bdf:	mov    $0x21,%eax
    6be4:	jmp    7315 <botlish_fn_19+0x5f8d>
    6be9:	mov    0x450(%rsp),%rax
    6bf1:	jmp    7315 <botlish_fn_19+0x5f8d>
    6bf6:	mov    $0x21,%eax
    6bfb:	jmp    7315 <botlish_fn_19+0x5f8d>
    6c00:	cmp    $0x5,%rax
    6c04:	jl     6ce1 <botlish_fn_19+0x5959>
    6c0a:	mov    %r13,%rsi
    6c0d:	test   $0x1,%rsi
    6c14:	jne    6c44 <botlish_fn_19+0x58bc>
    6c1a:	mov    $0x121,%edx
    6c1f:	mov    %r13,%rsi
    6c22:	mov    0x3c0(%rsp),%rdi
    6c2a:	call   6c2f <botlish_fn_19+0x58a7>
			6c2b: R_X86_64_PLT32	rt_int_cmp-0x4
    6c2f:	mov    $0x2,%ecx
    6c34:	test   %rax,%rax
    6c37:	cmovl  0x2f89(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6c3f:	jmp    6c5b <botlish_fn_19+0x58d3>
    6c44:	mov    $0x2,%ecx
    6c49:	mov    %r13,%rsi
    6c4c:	cmp    $0x121,%rsi
    6c53:	cmovl  0x2f6d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6c5b:	cmp    $0x6,%rcx
    6c5f:	je     6cd7 <botlish_fn_19+0x594f>
    6c65:	mov    %r13,%rsi
    6c68:	test   $0x1,%rsi
    6c6f:	jne    6c9f <botlish_fn_19+0x5917>
    6c75:	mov    $0x181,%edx
    6c7a:	mov    %r13,%rsi
    6c7d:	mov    0x3c0(%rsp),%rdi
    6c85:	call   6c8a <botlish_fn_19+0x5902>
			6c86: R_X86_64_PLT32	rt_int_cmp-0x4
    6c8a:	mov    $0x2,%ecx
    6c8f:	test   %rax,%rax
    6c92:	cmovl  0x2f2e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6c9a:	jmp    6cb6 <botlish_fn_19+0x592e>
    6c9f:	mov    $0x2,%ecx
    6ca4:	mov    %r13,%rsi
    6ca7:	cmp    $0x181,%rsi
    6cae:	cmovl  0x2f12(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6cb6:	cmp    $0x6,%rcx
    6cba:	je     6cca <botlish_fn_19+0x5942>
    6cc0:	mov    $0x1f,%eax
    6cc5:	jmp    7315 <botlish_fn_19+0x5f8d>
    6cca:	mov    0x450(%rsp),%rax
    6cd2:	jmp    7315 <botlish_fn_19+0x5f8d>
    6cd7:	mov    $0x1f,%eax
    6cdc:	jmp    7315 <botlish_fn_19+0x5f8d>
    6ce1:	mov    %r13,%rsi
    6ce4:	test   $0x1,%rsi
    6ceb:	jne    6d1b <botlish_fn_19+0x5993>
    6cf1:	mov    $0x101,%edx
    6cf6:	mov    %r13,%rsi
    6cf9:	mov    0x3c0(%rsp),%rdi
    6d01:	call   6d06 <botlish_fn_19+0x597e>
			6d02: R_X86_64_PLT32	rt_int_cmp-0x4
    6d06:	mov    $0x2,%edx
    6d0b:	test   %rax,%rax
    6d0e:	cmovl  0x2eb2(%rip),%rdx        # 9bc8 <botlish_fn_19+0x8840>
    6d16:	jmp    6d32 <botlish_fn_19+0x59aa>
    6d1b:	mov    $0x2,%edx
    6d20:	mov    %r13,%rsi
    6d23:	cmp    $0x101,%rsi
    6d2a:	cmovl  0x2e96(%rip),%rdx        # 9bc8 <botlish_fn_19+0x8840>
    6d32:	cmp    $0x6,%rdx
    6d36:	je     6dae <botlish_fn_19+0x5a26>
    6d3c:	mov    %r13,%rsi
    6d3f:	test   $0x1,%rsi
    6d46:	jne    6d76 <botlish_fn_19+0x59ee>
    6d4c:	mov    $0x141,%edx
    6d51:	mov    %r13,%rsi
    6d54:	mov    0x3c0(%rsp),%rdi
    6d5c:	call   6d61 <botlish_fn_19+0x59d9>
			6d5d: R_X86_64_PLT32	rt_int_cmp-0x4
    6d61:	mov    $0x2,%ecx
    6d66:	test   %rax,%rax
    6d69:	cmovl  0x2e57(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6d71:	jmp    6d8d <botlish_fn_19+0x5a05>
    6d76:	mov    $0x2,%ecx
    6d7b:	mov    %r13,%rsi
    6d7e:	cmp    $0x141,%rsi
    6d85:	cmovl  0x2e3b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6d8d:	cmp    $0x6,%rcx
    6d91:	je     6da1 <botlish_fn_19+0x5a19>
    6d97:	mov    $0x1d,%eax
    6d9c:	jmp    7315 <botlish_fn_19+0x5f8d>
    6da1:	mov    0x488(%rsp),%rax
    6da9:	jmp    7315 <botlish_fn_19+0x5f8d>
    6dae:	mov    $0x1d,%eax
    6db3:	jmp    7315 <botlish_fn_19+0x5f8d>
    6db8:	cmp    $0x2,%rax
    6dbc:	jl     6f79 <botlish_fn_19+0x5bf1>
    6dc2:	cmp    $0x3,%rax
    6dc6:	jl     6ea3 <botlish_fn_19+0x5b1b>
    6dcc:	mov    %r13,%rsi
    6dcf:	test   $0x1,%rsi
    6dd6:	jne    6e06 <botlish_fn_19+0x5a7e>
    6ddc:	mov    $0x101,%edx
    6de1:	mov    %r13,%rsi
    6de4:	mov    0x3c0(%rsp),%rdi
    6dec:	call   6df1 <botlish_fn_19+0x5a69>
			6ded: R_X86_64_PLT32	rt_int_cmp-0x4
    6df1:	mov    $0x2,%ecx
    6df6:	test   %rax,%rax
    6df9:	cmovl  0x2dc7(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6e01:	jmp    6e1d <botlish_fn_19+0x5a95>
    6e06:	mov    $0x2,%ecx
    6e0b:	mov    %r13,%rsi
    6e0e:	cmp    $0x101,%rsi
    6e15:	cmovl  0x2dab(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6e1d:	cmp    $0x6,%rcx
    6e21:	je     6e99 <botlish_fn_19+0x5b11>
    6e27:	mov    %r13,%rsi
    6e2a:	test   $0x1,%rsi
    6e31:	jne    6e61 <botlish_fn_19+0x5ad9>
    6e37:	mov    $0x181,%edx
    6e3c:	mov    %r13,%rsi
    6e3f:	mov    0x3c0(%rsp),%rdi
    6e47:	call   6e4c <botlish_fn_19+0x5ac4>
			6e48: R_X86_64_PLT32	rt_int_cmp-0x4
    6e4c:	mov    $0x2,%ecx
    6e51:	test   %rax,%rax
    6e54:	cmovl  0x2d6c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6e5c:	jmp    6e78 <botlish_fn_19+0x5af0>
    6e61:	mov    $0x2,%ecx
    6e66:	mov    %r13,%rsi
    6e69:	cmp    $0x181,%rsi
    6e70:	cmovl  0x2d50(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6e78:	cmp    $0x6,%rcx
    6e7c:	je     6e8c <botlish_fn_19+0x5b04>
    6e82:	mov    $0x1b,%eax
    6e87:	jmp    7315 <botlish_fn_19+0x5f8d>
    6e8c:	mov    0x488(%rsp),%rax
    6e94:	jmp    7315 <botlish_fn_19+0x5f8d>
    6e99:	mov    $0x1b,%eax
    6e9e:	jmp    7315 <botlish_fn_19+0x5f8d>
    6ea3:	mov    %r13,%rsi
    6ea6:	test   $0x1,%rsi
    6ead:	jne    6edd <botlish_fn_19+0x5b55>
    6eb3:	mov    $0x141,%edx
    6eb8:	mov    %r13,%rsi
    6ebb:	mov    0x3c0(%rsp),%rdi
    6ec3:	call   6ec8 <botlish_fn_19+0x5b40>
			6ec4: R_X86_64_PLT32	rt_int_cmp-0x4
    6ec8:	mov    $0x2,%esi
    6ecd:	test   %rax,%rax
    6ed0:	cmovl  0x2cf0(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    6ed8:	jmp    6ef3 <botlish_fn_19+0x5b6b>
    6edd:	mov    $0x2,%esi
    6ee2:	mov    %r13,%rax
    6ee5:	cmp    $0x141,%rax
    6eeb:	cmovl  0x2cd5(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    6ef3:	cmp    $0x6,%rsi
    6ef7:	je     6f6f <botlish_fn_19+0x5be7>
    6efd:	mov    %r13,%rsi
    6f00:	test   $0x1,%rsi
    6f07:	jne    6f37 <botlish_fn_19+0x5baf>
    6f0d:	mov    $0x181,%edx
    6f12:	mov    %r13,%rsi
    6f15:	mov    0x3c0(%rsp),%rdi
    6f1d:	call   6f22 <botlish_fn_19+0x5b9a>
			6f1e: R_X86_64_PLT32	rt_int_cmp-0x4
    6f22:	mov    $0x2,%ecx
    6f27:	test   %rax,%rax
    6f2a:	cmovl  0x2c96(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6f32:	jmp    6f4e <botlish_fn_19+0x5bc6>
    6f37:	mov    $0x2,%ecx
    6f3c:	mov    %r13,%rsi
    6f3f:	cmp    $0x181,%rsi
    6f46:	cmovl  0x2c7a(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6f4e:	cmp    $0x6,%rcx
    6f52:	je     6f62 <botlish_fn_19+0x5bda>
    6f58:	mov    $0x19,%eax
    6f5d:	jmp    7315 <botlish_fn_19+0x5f8d>
    6f62:	mov    0x488(%rsp),%rax
    6f6a:	jmp    7315 <botlish_fn_19+0x5f8d>
    6f6f:	mov    $0x19,%eax
    6f74:	jmp    7315 <botlish_fn_19+0x5f8d>
    6f79:	test   %rax,%rax
    6f7c:	jle    7056 <botlish_fn_19+0x5cce>
    6f82:	mov    %r13,%rsi
    6f85:	test   $0x1,%rsi
    6f8c:	jne    6fbc <botlish_fn_19+0x5c34>
    6f92:	mov    $0x101,%edx
    6f97:	mov    %r13,%rsi
    6f9a:	mov    0x3c0(%rsp),%rdi
    6fa2:	call   6fa7 <botlish_fn_19+0x5c1f>
			6fa3: R_X86_64_PLT32	rt_int_cmp-0x4
    6fa7:	mov    $0x2,%ecx
    6fac:	test   %rax,%rax
    6faf:	cmovl  0x2c11(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6fb7:	jmp    6fd3 <botlish_fn_19+0x5c4b>
    6fbc:	mov    $0x2,%ecx
    6fc1:	mov    %r13,%rsi
    6fc4:	cmp    $0x101,%rsi
    6fcb:	cmovl  0x2bf5(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    6fd3:	cmp    $0x6,%rcx
    6fd7:	je     704c <botlish_fn_19+0x5cc4>
    6fdd:	mov    %r13,%rsi
    6fe0:	test   $0x1,%rsi
    6fe7:	jne    7017 <botlish_fn_19+0x5c8f>
    6fed:	mov    $0x181,%edx
    6ff2:	mov    %r13,%rsi
    6ff5:	mov    0x3c0(%rsp),%rdi
    6ffd:	call   7002 <botlish_fn_19+0x5c7a>
			6ffe: R_X86_64_PLT32	rt_int_cmp-0x4
    7002:	mov    $0x2,%ecx
    7007:	test   %rax,%rax
    700a:	cmovl  0x2bb6(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7012:	jmp    702e <botlish_fn_19+0x5ca6>
    7017:	mov    $0x2,%ecx
    701c:	mov    %r13,%rsi
    701f:	cmp    $0x181,%rsi
    7026:	cmovl  0x2b9a(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    702e:	cmp    $0x6,%rcx
    7032:	je     7042 <botlish_fn_19+0x5cba>
    7038:	mov    $0x17,%eax
    703d:	jmp    7315 <botlish_fn_19+0x5f8d>
    7042:	mov    $0x11,%eax
    7047:	jmp    7315 <botlish_fn_19+0x5f8d>
    704c:	mov    $0x17,%eax
    7051:	jmp    7315 <botlish_fn_19+0x5f8d>
    7056:	mov    %r13,%rsi
    7059:	test   $0x1,%rsi
    7060:	jne    7090 <botlish_fn_19+0x5d08>
    7066:	mov    $0x1dd,%edx
    706b:	mov    %r13,%rsi
    706e:	mov    0x3c0(%rsp),%rdi
    7076:	call   707b <botlish_fn_19+0x5cf3>
			7077: R_X86_64_PLT32	rt_int_cmp-0x4
    707b:	mov    $0x2,%ecx
    7080:	test   %rax,%rax
    7083:	cmovl  0x2b3d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    708b:	jmp    70a7 <botlish_fn_19+0x5d1f>
    7090:	mov    $0x2,%ecx
    7095:	mov    %r13,%rsi
    7098:	cmp    $0x1dd,%rsi
    709f:	cmovl  0x2b21(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    70a7:	cmp    $0x6,%rcx
    70ab:	je     720c <botlish_fn_19+0x5e84>
    70b1:	mov    %r13,%rsi
    70b4:	test   $0x1,%rsi
    70bb:	jne    70eb <botlish_fn_19+0x5d63>
    70c1:	mov    $0x1e3,%edx
    70c6:	mov    %r13,%rsi
    70c9:	mov    0x3c0(%rsp),%rdi
    70d1:	call   70d6 <botlish_fn_19+0x5d4e>
			70d2: R_X86_64_PLT32	rt_int_cmp-0x4
    70d6:	mov    $0x2,%ecx
    70db:	test   %rax,%rax
    70de:	cmovl  0x2ae2(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    70e6:	jmp    7102 <botlish_fn_19+0x5d7a>
    70eb:	mov    $0x2,%ecx
    70f0:	mov    %r13,%rsi
    70f3:	cmp    $0x1e3,%rsi
    70fa:	cmovl  0x2ac6(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7102:	cmp    $0x6,%rcx
    7106:	je     71e0 <botlish_fn_19+0x5e58>
    710c:	mov    %r13,%rsi
    710f:	test   $0x1,%rsi
    7116:	jne    7146 <botlish_fn_19+0x5dbe>
    711c:	mov    $0x1e9,%edx
    7121:	mov    %r13,%rsi
    7124:	mov    0x3c0(%rsp),%rdi
    712c:	call   7131 <botlish_fn_19+0x5da9>
			712d: R_X86_64_PLT32	rt_int_cmp-0x4
    7131:	mov    $0x2,%ecx
    7136:	test   %rax,%rax
    7139:	cmovl  0x2a87(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7141:	jmp    715d <botlish_fn_19+0x5dd5>
    7146:	mov    $0x2,%ecx
    714b:	mov    %r13,%rsi
    714e:	cmp    $0x1e9,%rsi
    7155:	cmovl  0x2a6b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    715d:	cmp    $0x6,%rcx
    7161:	je     71d6 <botlish_fn_19+0x5e4e>
    7167:	mov    %r13,%rsi
    716a:	test   $0x1,%rsi
    7171:	jne    71a1 <botlish_fn_19+0x5e19>
    7177:	mov    $0x1eb,%edx
    717c:	mov    %r13,%rsi
    717f:	mov    0x3c0(%rsp),%rdi
    7187:	call   718c <botlish_fn_19+0x5e04>
			7188: R_X86_64_PLT32	rt_int_cmp-0x4
    718c:	mov    $0x2,%ecx
    7191:	test   %rax,%rax
    7194:	cmovl  0x2a2c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    719c:	jmp    71b8 <botlish_fn_19+0x5e30>
    71a1:	mov    $0x2,%ecx
    71a6:	mov    %r13,%rsi
    71a9:	cmp    $0x1eb,%rsi
    71b0:	cmovl  0x2a10(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    71b8:	cmp    $0x6,%rcx
    71bc:	je     71cc <botlish_fn_19+0x5e44>
    71c2:	mov    $0x15,%eax
    71c7:	jmp    7315 <botlish_fn_19+0x5f8d>
    71cc:	mov    $0xf,%eax
    71d1:	jmp    7315 <botlish_fn_19+0x5f8d>
    71d6:	mov    $0xd,%eax
    71db:	jmp    7315 <botlish_fn_19+0x5f8d>
    71e0:	mov    %r13,%rsi
    71e3:	mov    %rsi,%rax
    71e6:	sar    $1,%rax
    71e9:	cmp    $0xf0,%rax
    71ef:	jl     71ff <botlish_fn_19+0x5e77>
    71f5:	mov    $0xb,%eax
    71fa:	jmp    7315 <botlish_fn_19+0x5f8d>
    71ff:	mov    0x450(%rsp),%rax
    7207:	jmp    7315 <botlish_fn_19+0x5f8d>
    720c:	mov    %r13,%rsi
    720f:	test   $0x1,%rsi
    7216:	jne    7246 <botlish_fn_19+0x5ebe>
    721c:	mov    $0x1c1,%edx
    7221:	mov    %r13,%rsi
    7224:	mov    0x3c0(%rsp),%rdi
    722c:	call   7231 <botlish_fn_19+0x5ea9>
			722d: R_X86_64_PLT32	rt_int_cmp-0x4
    7231:	mov    $0x2,%esi
    7236:	test   %rax,%rax
    7239:	cmovl  0x2987(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    7241:	jmp    725c <botlish_fn_19+0x5ed4>
    7246:	mov    $0x2,%esi
    724b:	mov    %r13,%rax
    724e:	cmp    $0x1c1,%rax
    7254:	cmovl  0x296c(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    725c:	cmp    $0x6,%rsi
    7260:	je     72a8 <botlish_fn_19+0x5f20>
    7266:	mov    %r13,%rsi
    7269:	mov    %rsi,%rax
    726c:	sar    $1,%rax
    726f:	cmp    $0xe1,%rax
    7275:	jl     729e <botlish_fn_19+0x5f16>
    727b:	cmp    $0xed,%rax
    7281:	jl     7291 <botlish_fn_19+0x5f09>
    7287:	mov    $0x9,%eax
    728c:	jmp    7315 <botlish_fn_19+0x5f8d>
    7291:	mov    0x450(%rsp),%rax
    7299:	jmp    7315 <botlish_fn_19+0x5f8d>
    729e:	mov    $0x5,%eax
    72a3:	jmp    7315 <botlish_fn_19+0x5f8d>
    72a8:	mov    %r13,%rsi
    72ab:	test   $0x1,%rsi
    72b2:	jne    72e2 <botlish_fn_19+0x5f5a>
    72b8:	mov    $0x185,%edx
    72bd:	mov    %r13,%rsi
    72c0:	mov    0x3c0(%rsp),%rdi
    72c8:	call   72cd <botlish_fn_19+0x5f45>
			72c9: R_X86_64_PLT32	rt_int_cmp-0x4
    72cd:	mov    $0x2,%ecx
    72d2:	test   %rax,%rax
    72d5:	cmovl  0x28eb(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    72dd:	jmp    72f9 <botlish_fn_19+0x5f71>
    72e2:	mov    $0x2,%ecx
    72e7:	mov    %r13,%rsi
    72ea:	cmp    $0x185,%rsi
    72f1:	cmovl  0x28cf(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    72f9:	cmp    $0x6,%rcx
    72fd:	je     7310 <botlish_fn_19+0x5f88>
    7303:	mov    0x488(%rsp),%rax
    730b:	jmp    7315 <botlish_fn_19+0x5f8d>
    7310:	mov    $0x15,%eax
    7315:	mov    %rax,%rsi
    7318:	sar    $1,%rsi
    731b:	mov    $0x8,%r12d
    7321:	cmp    $0x8,%rsi
    7325:	jl     7446 <botlish_fn_19+0x60be>
    732b:	cmp    $0x8,%rsi
    732f:	mov    %rsi,%rbx
    7332:	je     7439 <botlish_fn_19+0x60b1>
    7338:	mov    %r13,%rsi
    733b:	test   $0x1,%rsi
    7342:	jne    7375 <botlish_fn_19+0x5fed>
    7348:	mov    0x458(%rsp),%rdx
    7350:	mov    %r13,%rsi
    7353:	mov    0x3c0(%rsp),%rdi
    735b:	call   7360 <botlish_fn_19+0x5fd8>
			735c: R_X86_64_PLT32	rt_int_cmp-0x4
    7360:	mov    $0x2,%ecx
    7365:	test   %rax,%rax
    7368:	cmove  0x2858(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7370:	jmp    7389 <botlish_fn_19+0x6001>
    7375:	mov    $0x2,%ecx
    737a:	mov    %r13,%rsi
    737d:	cmp    $0xffffffffffffffff,%rsi
    7381:	cmove  0x283f(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7389:	cmp    $0x6,%rcx
    738d:	je     73e9 <botlish_fn_19+0x6061>
    7393:	mov    %rbx,%rsi
    7396:	mov    0x3c0(%rsp),%rdi
    739e:	call   73a3 <botlish_fn_19+0x601b>
			739f: R_X86_64_PLT32	botlish_fn_7-0x4
    73a3:	mov    0x3c0(%rsp),%rdi
    73ab:	mov    0x10(%rdi),%rsi
    73af:	mov    0x1f8(%rsi),%rdx
    73b6:	lea    0x350(%rsp),%r9
    73be:	mov    %rax,0x350(%rsp)
    73c6:	mov    %r13,%rsi
    73c9:	mov    %rsi,0x358(%rsp)
    73d1:	mov    $0x1,%esi
    73d6:	mov    $0x2,%r8d
    73dc:	mov    %r12,%rcx
    73df:	call   73e4 <botlish_fn_19+0x605c>
			73e0: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    73e4:	jmp    8208 <botlish_fn_19+0x6e80>
    73e9:	mov    %rbx,%rsi
    73ec:	mov    0x3c0(%rsp),%rdi
    73f4:	call   73f9 <botlish_fn_19+0x6071>
			73f5: R_X86_64_PLT32	botlish_fn_7-0x4
    73f9:	mov    0x3c0(%rsp),%rdi
    7401:	mov    0x10(%rdi),%rsi
    7405:	mov    0x1f0(%rsi),%rdx
    740c:	lea    0x348(%rsp),%r9
    7414:	mov    %rax,0x348(%rsp)
    741c:	mov    $0x2,%esi
    7421:	mov    $0x1,%r8d
    7427:	mov    0x488(%rsp),%rcx
    742f:	call   7434 <botlish_fn_19+0x60ac>
			7430: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    7434:	jmp    8208 <botlish_fn_19+0x6e80>
    7439:	mov    0x488(%rsp),%rbx
    7441:	jmp    8360 <botlish_fn_19+0x6fd8>
    7446:	mov    %rax,0xd0(%rsp)
    744e:	mov    $0x6,%r12d
    7454:	movq   $0x6,0xb0(%rsp)
    7460:	mov    $0x2,%r13d
    7466:	mov    %rax,0x430(%rsp)
    746e:	jmp    83af <botlish_fn_19+0x7027>
    7473:	mov    0x428(%rsp),%rcx
    747b:	mov    0x3e0(%rsp),%rbx
    7483:	mov    %rsi,%r13
    7486:	mov    %rcx,%rax
    7489:	sar    $1,%rax
    748c:	cmp    $0x3,%rax
    7490:	jl     7a2b <botlish_fn_19+0x66a3>
    7496:	cmp    $0x4,%rax
    749a:	jl     7854 <botlish_fn_19+0x64cc>
    74a0:	cmp    $0x5,%rax
    74a4:	jl     767f <botlish_fn_19+0x62f7>
    74aa:	mov    %r13,%rsi
    74ad:	test   $0x1,%rsi
    74b4:	jne    74e4 <botlish_fn_19+0x615c>
    74ba:	mov    $0x83,%edx
    74bf:	mov    %r13,%rsi
    74c2:	mov    0x3c0(%rsp),%rdi
    74ca:	call   74cf <botlish_fn_19+0x6147>
			74cb: R_X86_64_PLT32	rt_int_cmp-0x4
    74cf:	mov    $0x2,%ecx
    74d4:	test   %rax,%rax
    74d7:	cmovl  0x26e9(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    74df:	jmp    74fb <botlish_fn_19+0x6173>
    74e4:	mov    $0x2,%ecx
    74e9:	mov    %r13,%rsi
    74ec:	cmp    $0x83,%rsi
    74f3:	cmovl  0x26cd(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    74fb:	cmp    $0x6,%rcx
    74ff:	je     75f6 <botlish_fn_19+0x626e>
    7505:	mov    %r13,%rsi
    7508:	test   $0x1,%rsi
    750f:	jne    753f <botlish_fn_19+0x61b7>
    7515:	mov    $0xc3,%edx
    751a:	mov    %r13,%rsi
    751d:	mov    0x3c0(%rsp),%rdi
    7525:	call   752a <botlish_fn_19+0x61a2>
			7526: R_X86_64_PLT32	rt_int_cmp-0x4
    752a:	mov    $0x2,%ecx
    752f:	test   %rax,%rax
    7532:	cmovl  0x268e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    753a:	jmp    7556 <botlish_fn_19+0x61ce>
    753f:	mov    $0x2,%ecx
    7544:	mov    %r13,%rsi
    7547:	cmp    $0xc3,%rsi
    754e:	cmovl  0x2672(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7556:	cmp    $0x6,%rcx
    755a:	je     75cf <botlish_fn_19+0x6247>
    7560:	mov    %r13,%rsi
    7563:	test   $0x1,%rsi
    756a:	jne    759a <botlish_fn_19+0x6212>
    7570:	mov    $0xcf,%edx
    7575:	mov    %r13,%rsi
    7578:	mov    0x3c0(%rsp),%rdi
    7580:	call   7585 <botlish_fn_19+0x61fd>
			7581: R_X86_64_PLT32	rt_int_cmp-0x4
    7585:	mov    $0x2,%ecx
    758a:	test   %rax,%rax
    758d:	cmovl  0x2633(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7595:	jmp    75b1 <botlish_fn_19+0x6229>
    759a:	mov    $0x2,%ecx
    759f:	mov    %r13,%rsi
    75a2:	cmp    $0xcf,%rsi
    75a9:	cmovl  0x2617(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    75b1:	cmp    $0x6,%rcx
    75b5:	je     75c5 <botlish_fn_19+0x623d>
    75bb:	mov    $0x1b,%esi
    75c0:	jmp    80ed <botlish_fn_19+0x6d65>
    75c5:	mov    $0xd,%esi
    75ca:	jmp    80ed <botlish_fn_19+0x6d65>
    75cf:	mov    %r13,%rsi
    75d2:	mov    %rsi,%rax
    75d5:	sar    $1,%rax
    75d8:	cmp    $0x47,%rax
    75dc:	jl     75ec <botlish_fn_19+0x6264>
    75e2:	mov    $0x1b,%esi
    75e7:	jmp    80ed <botlish_fn_19+0x6d65>
    75ec:	mov    $0xd,%esi
    75f1:	jmp    80ed <botlish_fn_19+0x6d65>
    75f6:	mov    %r13,%rsi
    75f9:	test   $0x1,%rsi
    7600:	jne    7630 <botlish_fn_19+0x62a8>
    7606:	mov    $0x61,%edx
    760b:	mov    %r13,%rsi
    760e:	mov    0x3c0(%rsp),%rdi
    7616:	call   761b <botlish_fn_19+0x6293>
			7617: R_X86_64_PLT32	rt_int_cmp-0x4
    761b:	mov    $0x2,%ecx
    7620:	test   %rax,%rax
    7623:	cmovl  0x259d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    762b:	jmp    7644 <botlish_fn_19+0x62bc>
    7630:	mov    $0x2,%ecx
    7635:	mov    %r13,%rsi
    7638:	cmp    $0x61,%rsi
    763c:	cmovl  0x2584(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7644:	cmp    $0x6,%rcx
    7648:	je     7675 <botlish_fn_19+0x62ed>
    764e:	mov    %r13,%rsi
    7651:	mov    %rsi,%rax
    7654:	sar    $1,%rax
    7657:	cmp    $0x3a,%rax
    765b:	jl     766b <botlish_fn_19+0x62e3>
    7661:	mov    $0x1b,%esi
    7666:	jmp    80ed <botlish_fn_19+0x6d65>
    766b:	mov    $0xd,%esi
    7670:	jmp    80ed <botlish_fn_19+0x6d65>
    7675:	mov    $0x1b,%esi
    767a:	jmp    80ed <botlish_fn_19+0x6d65>
    767f:	mov    %r13,%rsi
    7682:	test   $0x1,%rsi
    7689:	jne    76b9 <botlish_fn_19+0x6331>
    768f:	mov    $0x83,%edx
    7694:	mov    %r13,%rsi
    7697:	mov    0x3c0(%rsp),%rdi
    769f:	call   76a4 <botlish_fn_19+0x631c>
			76a0: R_X86_64_PLT32	rt_int_cmp-0x4
    76a4:	mov    $0x2,%ecx
    76a9:	test   %rax,%rax
    76ac:	cmovl  0x2514(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    76b4:	jmp    76d0 <botlish_fn_19+0x6348>
    76b9:	mov    $0x2,%ecx
    76be:	mov    %r13,%rsi
    76c1:	cmp    $0x83,%rsi
    76c8:	cmovl  0x24f8(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    76d0:	cmp    $0x6,%rcx
    76d4:	je     77cb <botlish_fn_19+0x6443>
    76da:	mov    %r13,%rsi
    76dd:	test   $0x1,%rsi
    76e4:	jne    7714 <botlish_fn_19+0x638c>
    76ea:	mov    $0xc3,%edx
    76ef:	mov    %r13,%rsi
    76f2:	mov    0x3c0(%rsp),%rdi
    76fa:	call   76ff <botlish_fn_19+0x6377>
			76fb: R_X86_64_PLT32	rt_int_cmp-0x4
    76ff:	mov    $0x2,%ecx
    7704:	test   %rax,%rax
    7707:	cmovl  0x24b9(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    770f:	jmp    772b <botlish_fn_19+0x63a3>
    7714:	mov    $0x2,%ecx
    7719:	mov    %r13,%rsi
    771c:	cmp    $0xc3,%rsi
    7723:	cmovl  0x249d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    772b:	cmp    $0x6,%rcx
    772f:	je     77a4 <botlish_fn_19+0x641c>
    7735:	mov    %r13,%rsi
    7738:	test   $0x1,%rsi
    773f:	jne    776f <botlish_fn_19+0x63e7>
    7745:	mov    $0xcf,%edx
    774a:	mov    %r13,%rsi
    774d:	mov    0x3c0(%rsp),%rdi
    7755:	call   775a <botlish_fn_19+0x63d2>
			7756: R_X86_64_PLT32	rt_int_cmp-0x4
    775a:	mov    $0x2,%ecx
    775f:	test   %rax,%rax
    7762:	cmovl  0x245e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    776a:	jmp    7786 <botlish_fn_19+0x63fe>
    776f:	mov    $0x2,%ecx
    7774:	mov    %r13,%rsi
    7777:	cmp    $0xcf,%rsi
    777e:	cmovl  0x2442(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7786:	cmp    $0x6,%rcx
    778a:	je     779a <botlish_fn_19+0x6412>
    7790:	mov    $0x19,%esi
    7795:	jmp    80ed <botlish_fn_19+0x6d65>
    779a:	mov    $0xb,%esi
    779f:	jmp    80ed <botlish_fn_19+0x6d65>
    77a4:	mov    %r13,%rsi
    77a7:	mov    %rsi,%rax
    77aa:	sar    $1,%rax
    77ad:	cmp    $0x47,%rax
    77b1:	jl     77c1 <botlish_fn_19+0x6439>
    77b7:	mov    $0x19,%esi
    77bc:	jmp    80ed <botlish_fn_19+0x6d65>
    77c1:	mov    $0xb,%esi
    77c6:	jmp    80ed <botlish_fn_19+0x6d65>
    77cb:	mov    %r13,%rsi
    77ce:	test   $0x1,%rsi
    77d5:	jne    7805 <botlish_fn_19+0x647d>
    77db:	mov    $0x61,%edx
    77e0:	mov    %r13,%rsi
    77e3:	mov    0x3c0(%rsp),%rdi
    77eb:	call   77f0 <botlish_fn_19+0x6468>
			77ec: R_X86_64_PLT32	rt_int_cmp-0x4
    77f0:	mov    $0x2,%ecx
    77f5:	test   %rax,%rax
    77f8:	cmovl  0x23c8(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7800:	jmp    7819 <botlish_fn_19+0x6491>
    7805:	mov    $0x2,%ecx
    780a:	mov    %r13,%rsi
    780d:	cmp    $0x61,%rsi
    7811:	cmovl  0x23af(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7819:	cmp    $0x6,%rcx
    781d:	je     784a <botlish_fn_19+0x64c2>
    7823:	mov    %r13,%rsi
    7826:	mov    %rsi,%rax
    7829:	sar    $1,%rax
    782c:	cmp    $0x3a,%rax
    7830:	jl     7840 <botlish_fn_19+0x64b8>
    7836:	mov    $0x19,%esi
    783b:	jmp    80ed <botlish_fn_19+0x6d65>
    7840:	mov    $0xb,%esi
    7845:	jmp    80ed <botlish_fn_19+0x6d65>
    784a:	mov    $0x19,%esi
    784f:	jmp    80ed <botlish_fn_19+0x6d65>
    7854:	mov    %r13,%rsi
    7857:	test   $0x1,%rsi
    785e:	jne    788e <botlish_fn_19+0x6506>
    7864:	mov    $0x83,%edx
    7869:	mov    %r13,%rsi
    786c:	mov    0x3c0(%rsp),%rdi
    7874:	call   7879 <botlish_fn_19+0x64f1>
			7875: R_X86_64_PLT32	rt_int_cmp-0x4
    7879:	mov    $0x2,%ecx
    787e:	test   %rax,%rax
    7881:	cmovl  0x233f(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7889:	jmp    78a5 <botlish_fn_19+0x651d>
    788e:	mov    $0x2,%ecx
    7893:	mov    %r13,%rsi
    7896:	cmp    $0x83,%rsi
    789d:	cmovl  0x2323(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    78a5:	cmp    $0x6,%rcx
    78a9:	je     79a2 <botlish_fn_19+0x661a>
    78af:	mov    %r13,%rsi
    78b2:	test   $0x1,%rsi
    78b9:	jne    78e9 <botlish_fn_19+0x6561>
    78bf:	mov    $0xc3,%edx
    78c4:	mov    %r13,%rsi
    78c7:	mov    0x3c0(%rsp),%rdi
    78cf:	call   78d4 <botlish_fn_19+0x654c>
			78d0: R_X86_64_PLT32	rt_int_cmp-0x4
    78d4:	mov    $0x2,%ecx
    78d9:	test   %rax,%rax
    78dc:	cmovl  0x22e4(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    78e4:	jmp    7900 <botlish_fn_19+0x6578>
    78e9:	mov    $0x2,%ecx
    78ee:	mov    %r13,%rsi
    78f1:	cmp    $0xc3,%rsi
    78f8:	cmovl  0x22c8(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7900:	cmp    $0x6,%rcx
    7904:	je     797b <botlish_fn_19+0x65f3>
    790a:	mov    %r13,%rsi
    790d:	test   $0x1,%rsi
    7914:	jne    7945 <botlish_fn_19+0x65bd>
    791a:	mov    $0xcf,%edx
    791f:	mov    %r13,%rsi
    7922:	mov    0x3c0(%rsp),%rdi
    792a:	call   792f <botlish_fn_19+0x65a7>
			792b: R_X86_64_PLT32	rt_int_cmp-0x4
    792f:	mov    $0x2,%r8d
    7935:	test   %rax,%rax
    7938:	cmovl  0x2288(%rip),%r8        # 9bc8 <botlish_fn_19+0x8840>
    7940:	jmp    795d <botlish_fn_19+0x65d5>
    7945:	mov    $0x2,%r8d
    794b:	mov    %r13,%rsi
    794e:	cmp    $0xcf,%rsi
    7955:	cmovl  0x226b(%rip),%r8        # 9bc8 <botlish_fn_19+0x8840>
    795d:	cmp    $0x6,%r8
    7961:	je     7971 <botlish_fn_19+0x65e9>
    7967:	mov    $0x17,%esi
    796c:	jmp    80ed <botlish_fn_19+0x6d65>
    7971:	mov    $0x9,%esi
    7976:	jmp    80ed <botlish_fn_19+0x6d65>
    797b:	mov    %r13,%rsi
    797e:	mov    %rsi,%rax
    7981:	sar    $1,%rax
    7984:	cmp    $0x47,%rax
    7988:	jl     7998 <botlish_fn_19+0x6610>
    798e:	mov    $0x17,%esi
    7993:	jmp    80ed <botlish_fn_19+0x6d65>
    7998:	mov    $0x9,%esi
    799d:	jmp    80ed <botlish_fn_19+0x6d65>
    79a2:	mov    %r13,%rsi
    79a5:	test   $0x1,%rsi
    79ac:	jne    79dc <botlish_fn_19+0x6654>
    79b2:	mov    $0x61,%edx
    79b7:	mov    %r13,%rsi
    79ba:	mov    0x3c0(%rsp),%rdi
    79c2:	call   79c7 <botlish_fn_19+0x663f>
			79c3: R_X86_64_PLT32	rt_int_cmp-0x4
    79c7:	mov    $0x2,%ecx
    79cc:	test   %rax,%rax
    79cf:	cmovl  0x21f1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    79d7:	jmp    79f0 <botlish_fn_19+0x6668>
    79dc:	mov    $0x2,%ecx
    79e1:	mov    %r13,%rsi
    79e4:	cmp    $0x61,%rsi
    79e8:	cmovl  0x21d8(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    79f0:	cmp    $0x6,%rcx
    79f4:	je     7a21 <botlish_fn_19+0x6699>
    79fa:	mov    %r13,%rsi
    79fd:	mov    %rsi,%rax
    7a00:	sar    $1,%rax
    7a03:	cmp    $0x3a,%rax
    7a07:	jl     7a17 <botlish_fn_19+0x668f>
    7a0d:	mov    $0x17,%esi
    7a12:	jmp    80ed <botlish_fn_19+0x6d65>
    7a17:	mov    $0x9,%esi
    7a1c:	jmp    80ed <botlish_fn_19+0x6d65>
    7a21:	mov    $0x17,%esi
    7a26:	jmp    80ed <botlish_fn_19+0x6d65>
    7a2b:	test   %rax,%rax
    7a2e:	jle    801b <botlish_fn_19+0x6c93>
    7a34:	cmp    $0x2,%rax
    7a38:	jl     7c1b <botlish_fn_19+0x6893>
    7a3e:	mov    %r13,%rsi
    7a41:	test   $0x1,%rsi
    7a48:	jne    7a78 <botlish_fn_19+0x66f0>
    7a4e:	mov    $0x83,%edx
    7a53:	mov    %r13,%rsi
    7a56:	mov    0x3c0(%rsp),%rdi
    7a5e:	call   7a63 <botlish_fn_19+0x66db>
			7a5f: R_X86_64_PLT32	rt_int_cmp-0x4
    7a63:	mov    $0x2,%ecx
    7a68:	test   %rax,%rax
    7a6b:	cmovl  0x2155(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7a73:	jmp    7a8f <botlish_fn_19+0x6707>
    7a78:	mov    $0x2,%ecx
    7a7d:	mov    %r13,%rsi
    7a80:	cmp    $0x83,%rsi
    7a87:	cmovl  0x2139(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7a8f:	cmp    $0x6,%rcx
    7a93:	je     7b8f <botlish_fn_19+0x6807>
    7a99:	mov    %r13,%rsi
    7a9c:	test   $0x1,%rsi
    7aa3:	jne    7ad3 <botlish_fn_19+0x674b>
    7aa9:	mov    $0xc3,%edx
    7aae:	mov    %r13,%rsi
    7ab1:	mov    0x3c0(%rsp),%rdi
    7ab9:	call   7abe <botlish_fn_19+0x6736>
			7aba: R_X86_64_PLT32	rt_int_cmp-0x4
    7abe:	mov    $0x2,%esi
    7ac3:	test   %rax,%rax
    7ac6:	cmovl  0x20fa(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    7ace:	jmp    7ae9 <botlish_fn_19+0x6761>
    7ad3:	mov    $0x2,%esi
    7ad8:	mov    %r13,%rax
    7adb:	cmp    $0xc3,%rax
    7ae1:	cmovl  0x20df(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    7ae9:	cmp    $0x6,%rsi
    7aed:	je     7b65 <botlish_fn_19+0x67dd>
    7af3:	mov    %r13,%rsi
    7af6:	test   $0x1,%rsi
    7afd:	jne    7b2d <botlish_fn_19+0x67a5>
    7b03:	mov    $0xcf,%edx
    7b08:	mov    %r13,%rsi
    7b0b:	mov    0x3c0(%rsp),%rdi
    7b13:	call   7b18 <botlish_fn_19+0x6790>
			7b14: R_X86_64_PLT32	rt_int_cmp-0x4
    7b18:	mov    $0x2,%ecx
    7b1d:	test   %rax,%rax
    7b20:	cmovl  0x20a0(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7b28:	jmp    7b44 <botlish_fn_19+0x67bc>
    7b2d:	mov    $0x2,%ecx
    7b32:	mov    %r13,%rsi
    7b35:	cmp    $0xcf,%rsi
    7b3c:	cmovl  0x2084(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7b44:	cmp    $0x6,%rcx
    7b48:	je     7b58 <botlish_fn_19+0x67d0>
    7b4e:	mov    $0x15,%esi
    7b53:	jmp    80ed <botlish_fn_19+0x6d65>
    7b58:	mov    0x450(%rsp),%rsi
    7b60:	jmp    80ed <botlish_fn_19+0x6d65>
    7b65:	mov    %r13,%rsi
    7b68:	mov    %rsi,%rax
    7b6b:	sar    $1,%rax
    7b6e:	cmp    $0x47,%rax
    7b72:	jl     7b82 <botlish_fn_19+0x67fa>
    7b78:	mov    $0x15,%esi
    7b7d:	jmp    80ed <botlish_fn_19+0x6d65>
    7b82:	mov    0x450(%rsp),%rsi
    7b8a:	jmp    80ed <botlish_fn_19+0x6d65>
    7b8f:	mov    %r13,%rsi
    7b92:	test   $0x1,%rsi
    7b99:	jne    7bc9 <botlish_fn_19+0x6841>
    7b9f:	mov    $0x61,%edx
    7ba4:	mov    %r13,%rsi
    7ba7:	mov    0x3c0(%rsp),%rdi
    7baf:	call   7bb4 <botlish_fn_19+0x682c>
			7bb0: R_X86_64_PLT32	rt_int_cmp-0x4
    7bb4:	mov    $0x2,%ecx
    7bb9:	test   %rax,%rax
    7bbc:	cmovl  0x2004(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7bc4:	jmp    7bdd <botlish_fn_19+0x6855>
    7bc9:	mov    $0x2,%ecx
    7bce:	mov    %r13,%rsi
    7bd1:	cmp    $0x61,%rsi
    7bd5:	cmovl  0x1feb(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7bdd:	cmp    $0x6,%rcx
    7be1:	je     7c11 <botlish_fn_19+0x6889>
    7be7:	mov    %r13,%rsi
    7bea:	mov    %rsi,%rax
    7bed:	sar    $1,%rax
    7bf0:	cmp    $0x3a,%rax
    7bf4:	jl     7c04 <botlish_fn_19+0x687c>
    7bfa:	mov    $0x15,%esi
    7bff:	jmp    80ed <botlish_fn_19+0x6d65>
    7c04:	mov    0x450(%rsp),%rsi
    7c0c:	jmp    80ed <botlish_fn_19+0x6d65>
    7c11:	mov    $0x15,%esi
    7c16:	jmp    80ed <botlish_fn_19+0x6d65>
    7c1b:	mov    %r13,%rsi
    7c1e:	test   $0x1,%rsi
    7c25:	jne    7c55 <botlish_fn_19+0x68cd>
    7c2b:	mov    $0xcd,%edx
    7c30:	mov    %r13,%rsi
    7c33:	mov    0x3c0(%rsp),%rdi
    7c3b:	call   7c40 <botlish_fn_19+0x68b8>
			7c3c: R_X86_64_PLT32	rt_int_cmp-0x4
    7c40:	mov    $0x2,%ecx
    7c45:	test   %rax,%rax
    7c48:	cmovl  0x1f78(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7c50:	jmp    7c6c <botlish_fn_19+0x68e4>
    7c55:	mov    $0x2,%ecx
    7c5a:	mov    %r13,%rsi
    7c5d:	cmp    $0xcd,%rsi
    7c64:	cmovl  0x1f5c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7c6c:	cmp    $0x6,%rcx
    7c70:	je     7e75 <botlish_fn_19+0x6aed>
    7c76:	mov    %r13,%rsi
    7c79:	test   $0x1,%rsi
    7c80:	jne    7cb0 <botlish_fn_19+0x6928>
    7c86:	mov    $0xe5,%edx
    7c8b:	mov    %r13,%rsi
    7c8e:	mov    0x3c0(%rsp),%rdi
    7c96:	call   7c9b <botlish_fn_19+0x6913>
			7c97: R_X86_64_PLT32	rt_int_cmp-0x4
    7c9b:	mov    $0x2,%esi
    7ca0:	test   %rax,%rax
    7ca3:	cmovl  0x1f1d(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    7cab:	jmp    7cc6 <botlish_fn_19+0x693e>
    7cb0:	mov    $0x2,%esi
    7cb5:	mov    %r13,%rax
    7cb8:	cmp    $0xe5,%rax
    7cbe:	cmovl  0x1f02(%rip),%rsi        # 9bc8 <botlish_fn_19+0x8840>
    7cc6:	cmp    $0x6,%rsi
    7cca:	je     7e26 <botlish_fn_19+0x6a9e>
    7cd0:	mov    %r13,%rsi
    7cd3:	test   $0x1,%rsi
    7cda:	jne    7d0a <botlish_fn_19+0x6982>
    7ce0:	mov    $0xe9,%edx
    7ce5:	mov    %r13,%rsi
    7ce8:	mov    0x3c0(%rsp),%rdi
    7cf0:	call   7cf5 <botlish_fn_19+0x696d>
			7cf1: R_X86_64_PLT32	rt_int_cmp-0x4
    7cf5:	mov    $0x2,%ecx
    7cfa:	test   %rax,%rax
    7cfd:	cmovl  0x1ec3(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7d05:	jmp    7d21 <botlish_fn_19+0x6999>
    7d0a:	mov    $0x2,%ecx
    7d0f:	mov    %r13,%rsi
    7d12:	cmp    $0xe9,%rsi
    7d19:	cmovl  0x1ea7(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7d21:	cmp    $0x6,%rcx
    7d25:	je     7dff <botlish_fn_19+0x6a77>
    7d2b:	mov    %r13,%rsi
    7d2e:	test   $0x1,%rsi
    7d35:	jne    7d65 <botlish_fn_19+0x69dd>
    7d3b:	mov    $0xeb,%edx
    7d40:	mov    %r13,%rsi
    7d43:	mov    0x3c0(%rsp),%rdi
    7d4b:	call   7d50 <botlish_fn_19+0x69c8>
			7d4c: R_X86_64_PLT32	rt_int_cmp-0x4
    7d50:	mov    $0x2,%ecx
    7d55:	test   %rax,%rax
    7d58:	cmovl  0x1e68(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7d60:	jmp    7d7c <botlish_fn_19+0x69f4>
    7d65:	mov    $0x2,%ecx
    7d6a:	mov    %r13,%rsi
    7d6d:	cmp    $0xeb,%rsi
    7d74:	cmovl  0x1e4c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7d7c:	cmp    $0x6,%rcx
    7d80:	je     7df5 <botlish_fn_19+0x6a6d>
    7d86:	mov    %r13,%rsi
    7d89:	test   $0x1,%rsi
    7d90:	jne    7dc0 <botlish_fn_19+0x6a38>
    7d96:	mov    $0xed,%edx
    7d9b:	mov    %r13,%rsi
    7d9e:	mov    0x3c0(%rsp),%rdi
    7da6:	call   7dab <botlish_fn_19+0x6a23>
			7da7: R_X86_64_PLT32	rt_int_cmp-0x4
    7dab:	mov    $0x2,%ecx
    7db0:	test   %rax,%rax
    7db3:	cmovl  0x1e0d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7dbb:	jmp    7dd7 <botlish_fn_19+0x6a4f>
    7dc0:	mov    $0x2,%ecx
    7dc5:	mov    %r13,%rsi
    7dc8:	cmp    $0xed,%rsi
    7dcf:	cmovl  0x1df1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7dd7:	cmp    $0x6,%rcx
    7ddb:	je     7deb <botlish_fn_19+0x6a63>
    7de1:	mov    $0x13,%esi
    7de6:	jmp    80ed <botlish_fn_19+0x6d65>
    7deb:	mov    $0x5,%esi
    7df0:	jmp    80ed <botlish_fn_19+0x6d65>
    7df5:	mov    $0xd,%esi
    7dfa:	jmp    80ed <botlish_fn_19+0x6d65>
    7dff:	mov    %r13,%rsi
    7e02:	mov    %rsi,%rax
    7e05:	sar    $1,%rax
    7e08:	cmp    $0x73,%rax
    7e0c:	jl     7e1c <botlish_fn_19+0x6a94>
    7e12:	mov    $0x13,%esi
    7e17:	jmp    80ed <botlish_fn_19+0x6d65>
    7e1c:	mov    $0xd,%esi
    7e21:	jmp    80ed <botlish_fn_19+0x6d65>
    7e26:	mov    %r13,%rsi
    7e29:	mov    %rsi,%rax
    7e2c:	sar    $1,%rax
    7e2f:	cmp    $0x6e,%rax
    7e33:	jl     7e57 <botlish_fn_19+0x6acf>
    7e39:	cmp    $0x6f,%rax
    7e3d:	jl     7e4d <botlish_fn_19+0x6ac5>
    7e43:	mov    $0x13,%esi
    7e48:	jmp    80ed <botlish_fn_19+0x6d65>
    7e4d:	mov    $0xd,%esi
    7e52:	jmp    80ed <botlish_fn_19+0x6d65>
    7e57:	cmp    $0x67,%rax
    7e5b:	jl     7e6b <botlish_fn_19+0x6ae3>
    7e61:	mov    $0x13,%esi
    7e66:	jmp    80ed <botlish_fn_19+0x6d65>
    7e6b:	mov    $0xd,%esi
    7e70:	jmp    80ed <botlish_fn_19+0x6d65>
    7e75:	mov    %r13,%rsi
    7e78:	test   $0x1,%rsi
    7e7f:	jne    7eaf <botlish_fn_19+0x6b27>
    7e85:	mov    $0x61,%edx
    7e8a:	mov    %r13,%rsi
    7e8d:	mov    0x3c0(%rsp),%rdi
    7e95:	call   7e9a <botlish_fn_19+0x6b12>
			7e96: R_X86_64_PLT32	rt_int_cmp-0x4
    7e9a:	mov    $0x2,%ecx
    7e9f:	test   %rax,%rax
    7ea2:	cmovl  0x1d1e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7eaa:	jmp    7ec3 <botlish_fn_19+0x6b3b>
    7eaf:	mov    $0x2,%ecx
    7eb4:	mov    %r13,%rsi
    7eb7:	cmp    $0x61,%rsi
    7ebb:	cmovl  0x1d05(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7ec3:	cmp    $0x6,%rcx
    7ec7:	je     7f30 <botlish_fn_19+0x6ba8>
    7ecd:	mov    %r13,%rsi
    7ed0:	mov    %rsi,%rax
    7ed3:	sar    $1,%rax
    7ed6:	cmp    $0x5d,%rax
    7eda:	jl     7f12 <botlish_fn_19+0x6b8a>
    7ee0:	cmp    $0x62,%rax
    7ee4:	jl     7f08 <botlish_fn_19+0x6b80>
    7eea:	cmp    $0x63,%rax
    7eee:	jl     7efe <botlish_fn_19+0x6b76>
    7ef4:	mov    $0x13,%esi
    7ef9:	jmp    80ed <botlish_fn_19+0x6d65>
    7efe:	mov    $0xd,%esi
    7f03:	jmp    80ed <botlish_fn_19+0x6d65>
    7f08:	mov    $0x13,%esi
    7f0d:	jmp    80ed <botlish_fn_19+0x6d65>
    7f12:	cmp    $0x5c,%rax
    7f16:	jl     7f26 <botlish_fn_19+0x6b9e>
    7f1c:	mov    $0xd,%esi
    7f21:	jmp    80ed <botlish_fn_19+0x6d65>
    7f26:	mov    $0x13,%esi
    7f2b:	jmp    80ed <botlish_fn_19+0x6d65>
    7f30:	mov    %r13,%rsi
    7f33:	test   $0x1,%rsi
    7f3a:	jne    7f6a <botlish_fn_19+0x6be2>
    7f40:	mov    $0x47,%edx
    7f45:	mov    %r13,%rsi
    7f48:	mov    0x3c0(%rsp),%rdi
    7f50:	call   7f55 <botlish_fn_19+0x6bcd>
			7f51: R_X86_64_PLT32	rt_int_cmp-0x4
    7f55:	mov    $0x2,%ecx
    7f5a:	test   %rax,%rax
    7f5d:	cmovl  0x1c63(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7f65:	jmp    7f7e <botlish_fn_19+0x6bf6>
    7f6a:	mov    $0x2,%ecx
    7f6f:	mov    %r13,%rsi
    7f72:	cmp    $0x47,%rsi
    7f76:	cmovl  0x1c4a(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7f7e:	cmp    $0x6,%rcx
    7f82:	je     7faf <botlish_fn_19+0x6c27>
    7f88:	mov    %r13,%rsi
    7f8b:	mov    %rsi,%rdi
    7f8e:	sar    $1,%rdi
    7f91:	cmp    $0x2f,%rdi
    7f95:	jl     7fa5 <botlish_fn_19+0x6c1d>
    7f9b:	mov    $0xd,%esi
    7fa0:	jmp    80ed <botlish_fn_19+0x6d65>
    7fa5:	mov    $0x13,%esi
    7faa:	jmp    80ed <botlish_fn_19+0x6d65>
    7faf:	mov    %r13,%rsi
    7fb2:	test   $0x1,%rsi
    7fb9:	jne    7fe9 <botlish_fn_19+0x6c61>
    7fbf:	mov    $0x45,%edx
    7fc4:	mov    %r13,%rsi
    7fc7:	mov    0x3c0(%rsp),%rdi
    7fcf:	call   7fd4 <botlish_fn_19+0x6c4c>
			7fd0: R_X86_64_PLT32	rt_int_cmp-0x4
    7fd4:	mov    $0x2,%ecx
    7fd9:	test   %rax,%rax
    7fdc:	cmovl  0x1be4(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7fe4:	jmp    7ffd <botlish_fn_19+0x6c75>
    7fe9:	mov    $0x2,%ecx
    7fee:	mov    %r13,%rsi
    7ff1:	cmp    $0x45,%rsi
    7ff5:	cmovl  0x1bcb(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    7ffd:	cmp    $0x6,%rcx
    8001:	je     8011 <botlish_fn_19+0x6c89>
    8007:	mov    $0xd,%esi
    800c:	jmp    80ed <botlish_fn_19+0x6d65>
    8011:	mov    $0x13,%esi
    8016:	jmp    80ed <botlish_fn_19+0x6d65>
    801b:	mov    %r13,%rsi
    801e:	test   $0x1,%rsi
    8025:	jne    8055 <botlish_fn_19+0x6ccd>
    802b:	mov    $0xb9,%edx
    8030:	mov    %r13,%rsi
    8033:	mov    0x3c0(%rsp),%rdi
    803b:	call   8040 <botlish_fn_19+0x6cb8>
			803c: R_X86_64_PLT32	rt_int_cmp-0x4
    8040:	mov    $0x2,%ecx
    8045:	test   %rax,%rax
    8048:	cmovl  0x1b78(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    8050:	jmp    806c <botlish_fn_19+0x6ce4>
    8055:	mov    $0x2,%ecx
    805a:	mov    %r13,%rsi
    805d:	cmp    $0xb9,%rsi
    8064:	cmovl  0x1b5c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    806c:	cmp    $0x6,%rcx
    8070:	je     80e8 <botlish_fn_19+0x6d60>
    8076:	mov    %r13,%rsi
    8079:	test   $0x1,%rsi
    8080:	jne    80b0 <botlish_fn_19+0x6d28>
    8086:	mov    $0xbb,%edx
    808b:	mov    %r13,%rsi
    808e:	mov    0x3c0(%rsp),%rdi
    8096:	call   809b <botlish_fn_19+0x6d13>
			8097: R_X86_64_PLT32	rt_int_cmp-0x4
    809b:	mov    $0x2,%ecx
    80a0:	test   %rax,%rax
    80a3:	cmovl  0x1b1d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    80ab:	jmp    80c7 <botlish_fn_19+0x6d3f>
    80b0:	mov    $0x2,%ecx
    80b5:	mov    %r13,%rsi
    80b8:	cmp    $0xbb,%rsi
    80bf:	cmovl  0x1b01(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    80c7:	cmp    $0x6,%rcx
    80cb:	je     80db <botlish_fn_19+0x6d53>
    80d1:	mov    $0x11,%esi
    80d6:	jmp    80ed <botlish_fn_19+0x6d65>
    80db:	mov    0x488(%rsp),%rsi
    80e3:	jmp    80ed <botlish_fn_19+0x6d65>
    80e8:	mov    $0x11,%esi
    80ed:	mov    %rsi,%rax
    80f0:	sar    $1,%rax
    80f3:	cmp    $0x6,%rax
    80f7:	jl     8387 <botlish_fn_19+0x6fff>
    80fd:	cmp    $0x6,%rax
    8101:	mov    %rax,%rbx
    8104:	je     8358 <botlish_fn_19+0x6fd0>
    810a:	mov    %r13,%rsi
    810d:	test   $0x1,%rsi
    8114:	jne    8147 <botlish_fn_19+0x6dbf>
    811a:	mov    0x458(%rsp),%rdx
    8122:	mov    %r13,%rsi
    8125:	mov    0x3c0(%rsp),%rdi
    812d:	call   8132 <botlish_fn_19+0x6daa>
			812e: R_X86_64_PLT32	rt_int_cmp-0x4
    8132:	mov    $0x2,%ecx
    8137:	test   %rax,%rax
    813a:	cmove  0x1a86(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    8142:	jmp    815b <botlish_fn_19+0x6dd3>
    8147:	mov    $0x2,%ecx
    814c:	mov    %r13,%rsi
    814f:	cmp    $0xffffffffffffffff,%rsi
    8153:	cmove  0x1a6d(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    815b:	cmp    $0x6,%rcx
    815f:	je     81bd <botlish_fn_19+0x6e35>
    8165:	mov    %rbx,%rsi
    8168:	mov    0x3c0(%rsp),%rdi
    8170:	call   8175 <botlish_fn_19+0x6ded>
			8171: R_X86_64_PLT32	botlish_fn_5-0x4
    8175:	mov    0x3c0(%rsp),%rdi
    817d:	mov    0x10(%rdi),%rcx
    8181:	mov    0x1f8(%rcx),%rdx
    8188:	lea    0x338(%rsp),%r9
    8190:	mov    %rax,0x338(%rsp)
    8198:	mov    %r13,%rsi
    819b:	mov    %rsi,0x340(%rsp)
    81a3:	mov    $0x1,%esi
    81a8:	mov    $0x8,%ecx
    81ad:	mov    $0x2,%r8d
    81b3:	call   81b8 <botlish_fn_19+0x6e30>
			81b4: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    81b8:	jmp    8208 <botlish_fn_19+0x6e80>
    81bd:	mov    %rbx,%rsi
    81c0:	mov    0x3c0(%rsp),%rdi
    81c8:	call   81cd <botlish_fn_19+0x6e45>
			81c9: R_X86_64_PLT32	botlish_fn_5-0x4
    81cd:	mov    0x3c0(%rsp),%rdi
    81d5:	mov    0x10(%rdi),%rdx
    81d9:	mov    0x1f0(%rdx),%rdx
    81e0:	lea    0x330(%rsp),%r9
    81e8:	mov    %rax,0x330(%rsp)
    81f0:	mov    $0x2,%esi
    81f5:	mov    $0x1,%r8d
    81fb:	mov    0x488(%rsp),%rcx
    8203:	call   8208 <botlish_fn_19+0x6e80>
			8204: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8208:	mov    0x3c0(%rsp),%rdi
    8210:	call   8215 <botlish_fn_19+0x6e8d>
			8211: R_X86_64_PLT32	rt_co_failed-0x4
    8215:	mov    %rax,0xb8(%rsp)
    821d:	mov    %rax,%rsi
    8220:	mov    0x3c0(%rsp),%rdi
    8228:	call   822d <botlish_fn_19+0x6ea5>
			8229: R_X86_64_PLT32	rt_co_resume0-0x4
    822d:	test   %rax,%rax
    8230:	je     8252 <botlish_fn_19+0x6eca>
    8236:	mov    0x3c0(%rsp),%rdi
    823e:	mov    0x10(%rdi),%r9
    8242:	mov    0x48(%r9),%rsi
    8246:	mov    0x1b8(%r9),%rdx
    824d:	call   8252 <botlish_fn_19+0x6eca>
			824e: R_X86_64_PLT32	rt_raise-0x4
    8252:	mov    0x3c0(%rsp),%rdi
    825a:	call   825f <botlish_fn_19+0x6ed7>
			825b: R_X86_64_PLT32	rt_declared_error-0x4
    825f:	cmp    $0x1,%rax
    8263:	je     82e3 <botlish_fn_19+0x6f5b>
    8269:	mov    0x3c0(%rsp),%rdi
    8271:	call   8276 <botlish_fn_19+0x6eee>
			8272: R_X86_64_PLT32	rt_declared_error-0x4
    8276:	cmp    $0x2,%rax
    827a:	jne    9a02 <botlish_fn_19+0x867a>
    8280:	xor    %rsi,%rsi
    8283:	mov    0x3c0(%rsp),%rdi
    828b:	call   8290 <botlish_fn_19+0x6f08>
			828c: R_X86_64_PLT32	rt_declared_payload-0x4
    8290:	mov    %rax,%rbx
    8293:	mov    0x3c0(%rsp),%rdi
    829b:	call   82a0 <botlish_fn_19+0x6f18>
			829c: R_X86_64_PLT32	rt_clear_declared_error-0x4
    82a0:	mov    0x3c0(%rsp),%rdi
    82a8:	mov    0x10(%rdi),%rax
    82ac:	mov    0x1c8(%rax),%rdx
    82b3:	lea    0x120(%rsp),%r9
    82bb:	mov    %rbx,%rax
    82be:	mov    %rax,0x120(%rsp)
    82c6:	mov    $0x5,%esi
    82cb:	mov    $0x1,%r8d
    82d1:	mov    0x488(%rsp),%rcx
    82d9:	call   82de <botlish_fn_19+0x6f56>
			82da: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    82de:	jmp    9a02 <botlish_fn_19+0x867a>
    82e3:	xor    %rsi,%rsi
    82e6:	mov    0x3c0(%rsp),%rdi
    82ee:	call   82f3 <botlish_fn_19+0x6f6b>
			82ef: R_X86_64_PLT32	rt_declared_payload-0x4
    82f3:	mov    %rax,%rbx
    82f6:	mov    0x3c0(%rsp),%rdi
    82fe:	call   8303 <botlish_fn_19+0x6f7b>
			82ff: R_X86_64_PLT32	rt_clear_declared_error-0x4
    8303:	mov    0x470(%rsp),%rdx
    830b:	mov    0x10(%rdx),%rax
    830f:	mov    (%rax),%rcx
    8312:	mov    0x3c0(%rsp),%rdi
    831a:	mov    0x10(%rdi),%rax
    831e:	mov    0x1c0(%rax),%rdx
    8325:	lea    0x110(%rsp),%r9
    832d:	mov    %rcx,0x110(%rsp)
    8335:	mov    %rbx,%rax
    8338:	mov    %rax,0x118(%rsp)
    8340:	mov    $0x4,%esi
    8345:	mov    $0x2,%r8d
    834b:	mov    %r8,%rcx
    834e:	call   8353 <botlish_fn_19+0x6fcb>
			834f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8353:	jmp    9a02 <botlish_fn_19+0x867a>
    8358:	mov    0x488(%rsp),%rbx
    8360:	mov    %rbx,0xc0(%rsp)
    8368:	mov    $0x6,%r12d
    836e:	movq   $0x6,0xb0(%rsp)
    837a:	mov    0x488(%rsp),%r13
    8382:	jmp    83af <botlish_fn_19+0x7027>
    8387:	mov    %rsi,0xc8(%rsp)
    838f:	mov    $0x6,%r12d
    8395:	movq   $0x6,0xb0(%rsp)
    83a1:	mov    $0x1,%r13d
    83a7:	mov    %rsi,0x428(%rsp)
    83af:	mov    0x460(%rsp),%rax
    83b7:	mov    0x18(%rax),%rax
    83bb:	test   %rax,%rax
    83be:	je     9b42 <botlish_fn_19+0x87ba>
    83c4:	mov    0x460(%rsp),%rax
    83cc:	mov    0x10(%rax),%rax
    83d0:	mov    %r12,(%rax)
    83d3:	mov    %rbx,0x3e0(%rsp)
    83db:	mov    0x460(%rsp),%rbx
    83e3:	jmp    357d <botlish_fn_19+0x21f5>
    83e8:	mov    0x3c0(%rsp),%rdi
    83f0:	mov    0x10(%rdi),%rax
    83f4:	mov    0x1d0(%rax),%rdx
    83fb:	lea    0x100(%rsp),%r9
    8403:	mov    0x440(%rsp),%rcx
    840b:	mov    %rcx,0x100(%rsp)
    8413:	mov    0x3d8(%rsp),%rcx
    841b:	mov    %rcx,0x108(%rsp)
    8423:	mov    $0x8,%esi
    8428:	mov    $0x4,%ecx
    842d:	mov    $0x2,%r8d
    8433:	call   8438 <botlish_fn_19+0x70b0>
			8434: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8438:	jmp    9a02 <botlish_fn_19+0x867a>
    843d:	mov    0x448(%rsp),%rsi
    8445:	mov    0x3c0(%rsp),%rdi
    844d:	call   8452 <botlish_fn_19+0x70ca>
			844e: R_X86_64_PLT32	botlish_fn_14-0x4
    8452:	mov    0x470(%rsp),%rdx
    845a:	mov    %rax,%r12
    845d:	mov    0x10(%rdx),%rax
    8461:	mov    (%rax),%rax
    8464:	mov    0x3f0(%rsp),%r13
    846c:	cmp    $0x1,%r13
    8470:	je     849a <botlish_fn_19+0x7112>
    8476:	mov    $0xa,%esi
    847b:	cmp    $0xffffffffffffffff,%r13
    847f:	jne    8cff <botlish_fn_19+0x7977>
    8485:	mov    0x3d0(%rsp),%rbx
    848d:	mov    0x420(%rsp),%r12
    8495:	jmp    8d7e <botlish_fn_19+0x79f6>
    849a:	mov    0x480(%rsp),%rsi
    84a2:	mov    0x3c0(%rsp),%rdi
    84aa:	call   84af <botlish_fn_19+0x7127>
			84ab: R_X86_64_PLT32	rt_mv_pop-0x4
    84af:	mov    %rax,%rbx
    84b2:	mov    %rax,%r9
    84b5:	test   %r9,%rax
    84b8:	jne    8536 <botlish_fn_19+0x71ae>
    84be:	mov    0x3c0(%rsp),%rdi
    84c6:	call   84cb <botlish_fn_19+0x7143>
			84c7: R_X86_64_PLT32	rt_declared_error-0x4
    84cb:	cmp    $0x40000001,%rax
    84d1:	jne    8ce7 <botlish_fn_19+0x795f>
    84d7:	mov    0x3c0(%rsp),%rdi
    84df:	call   84e4 <botlish_fn_19+0x715c>
			84e0: R_X86_64_PLT32	rt_clear_declared_error-0x4
    84e4:	mov    0x3c0(%rsp),%rdi
    84ec:	mov    0x10(%rdi),%rcx
    84f0:	mov    0x1d8(%rcx),%rax
    84f7:	mov    0x1e0(%rcx),%rdx
    84fe:	lea    0x238(%rsp),%r9
    8506:	mov    0x440(%rsp),%rcx
    850e:	mov    %rcx,0x238(%rsp)
    8516:	mov    %rax,0x240(%rsp)
    851e:	mov    $0x6,%ecx
    8523:	mov    $0x2,%r8d
    8529:	mov    %rcx,%rsi
    852c:	call   8531 <botlish_fn_19+0x71a9>
			852d: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8531:	jmp    8ce7 <botlish_fn_19+0x795f>
    8536:	mov    %rbx,%rax
    8539:	test   $0x1,%rax
    853f:	jne    856f <botlish_fn_19+0x71e7>
    8545:	mov    $0x1,%edx
    854a:	mov    %rbx,%rsi
    854d:	mov    0x3c0(%rsp),%rdi
    8555:	call   855a <botlish_fn_19+0x71d2>
			8556: R_X86_64_PLT32	rt_int_cmp-0x4
    855a:	mov    $0x2,%ecx
    855f:	test   %rax,%rax
    8562:	cmove  0x165e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    856a:	jmp    8580 <botlish_fn_19+0x71f8>
    856f:	mov    $0x2,%ecx
    8574:	cmp    $0x1,%rbx
    8578:	cmove  0x1648(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    8580:	cmp    $0x6,%rcx
    8584:	je     8c7c <botlish_fn_19+0x78f4>
    858a:	test   $0x1,%rbx
    8591:	jne    85c1 <botlish_fn_19+0x7239>
    8597:	mov    $0x5,%edx
    859c:	mov    %rbx,%rsi
    859f:	mov    0x3c0(%rsp),%rdi
    85a7:	call   85ac <botlish_fn_19+0x7224>
			85a8: R_X86_64_PLT32	rt_int_cmp-0x4
    85ac:	mov    $0x2,%edx
    85b1:	test   %rax,%rax
    85b4:	cmove  0x160c(%rip),%rdx        # 9bc8 <botlish_fn_19+0x8840>
    85bc:	jmp    85d2 <botlish_fn_19+0x724a>
    85c1:	mov    $0x2,%edx
    85c6:	cmp    $0x5,%rbx
    85ca:	cmove  0x15f6(%rip),%rdx        # 9bc8 <botlish_fn_19+0x8840>
    85d2:	cmp    $0x6,%rdx
    85d6:	jne    85e6 <botlish_fn_19+0x725e>
    85dc:	cmp    $0x72,%r12
    85e0:	je     8c57 <botlish_fn_19+0x78cf>
    85e6:	test   $0x1,%rbx
    85ed:	jne    861d <botlish_fn_19+0x7295>
    85f3:	mov    $0x9,%edx
    85f8:	mov    %rbx,%rsi
    85fb:	mov    0x3c0(%rsp),%rdi
    8603:	call   8608 <botlish_fn_19+0x7280>
			8604: R_X86_64_PLT32	rt_int_cmp-0x4
    8608:	mov    $0x2,%ecx
    860d:	test   %rax,%rax
    8610:	cmove  0x15b0(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    8618:	jmp    862e <botlish_fn_19+0x72a6>
    861d:	mov    $0x2,%ecx
    8622:	cmp    $0x9,%rbx
    8626:	cmove  0x159a(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    862e:	cmp    $0x6,%rcx
    8632:	jne    8642 <botlish_fn_19+0x72ba>
    8638:	cmp    $0x32,%r12
    863c:	je     8c4a <botlish_fn_19+0x78c2>
    8642:	test   $0x1,%rbx
    8649:	jne    867c <botlish_fn_19+0x72f4>
    864f:	mov    0x450(%rsp),%rdx
    8657:	mov    %rbx,%rsi
    865a:	mov    0x3c0(%rsp),%rdi
    8662:	call   8667 <botlish_fn_19+0x72df>
			8663: R_X86_64_PLT32	rt_int_cmp-0x4
    8667:	mov    $0x2,%ecx
    866c:	test   %rax,%rax
    866f:	cmove  0x1551(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    8677:	jmp    868d <botlish_fn_19+0x7305>
    867c:	mov    $0x2,%ecx
    8681:	cmp    $0x7,%rbx
    8685:	cmove  0x153b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    868d:	cmp    $0x6,%rcx
    8691:	jne    86a7 <botlish_fn_19+0x731f>
    8697:	mov    %rbx,%rsi
    869a:	mov    0x3d0(%rsp),%rbx
    86a2:	jmp    8afe <botlish_fn_19+0x7776>
    86a7:	test   $0x1,%rbx
    86ae:	jne    86de <botlish_fn_19+0x7356>
    86b4:	mov    $0xb,%edx
    86b9:	mov    %rbx,%rsi
    86bc:	mov    0x3c0(%rsp),%rdi
    86c4:	call   86c9 <botlish_fn_19+0x7341>
			86c5: R_X86_64_PLT32	rt_int_cmp-0x4
    86c9:	mov    $0x2,%ecx
    86ce:	test   %rax,%rax
    86d1:	cmove  0x14ef(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    86d9:	jmp    86ef <botlish_fn_19+0x7367>
    86de:	mov    $0x2,%ecx
    86e3:	cmp    $0xb,%rbx
    86e7:	cmove  0x14d9(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    86ef:	cmp    $0x6,%rcx
    86f3:	jne    8709 <botlish_fn_19+0x7381>
    86f9:	mov    %rbx,%rsi
    86fc:	mov    0x3d0(%rsp),%rbx
    8704:	jmp    8afe <botlish_fn_19+0x7776>
    8709:	test   $0x1,%rbx
    8710:	jne    8741 <botlish_fn_19+0x73b9>
    8716:	mov    $0xf,%edx
    871b:	mov    %rbx,%rsi
    871e:	mov    0x3c0(%rsp),%rdi
    8726:	call   872b <botlish_fn_19+0x73a3>
			8727: R_X86_64_PLT32	rt_int_cmp-0x4
    872b:	mov    $0x2,%r11d
    8731:	test   %rax,%rax
    8734:	cmove  0x148c(%rip),%r11        # 9bc8 <botlish_fn_19+0x8840>
    873c:	jmp    8753 <botlish_fn_19+0x73cb>
    8741:	mov    $0x2,%r11d
    8747:	cmp    $0xf,%rbx
    874b:	cmove  0x1475(%rip),%r11        # 9bc8 <botlish_fn_19+0x8840>
    8753:	cmp    $0x6,%r11
    8757:	je     8a8e <botlish_fn_19+0x7706>
    875d:	test   $0x1,%rbx
    8764:	jne    8794 <botlish_fn_19+0x740c>
    876a:	mov    $0xd,%edx
    876f:	mov    %rbx,%rsi
    8772:	mov    0x3c0(%rsp),%rdi
    877a:	call   877f <botlish_fn_19+0x73f7>
			877b: R_X86_64_PLT32	rt_int_cmp-0x4
    877f:	mov    $0x2,%ecx
    8784:	test   %rax,%rax
    8787:	cmove  0x1439(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    878f:	jmp    87a5 <botlish_fn_19+0x741d>
    8794:	mov    $0x2,%ecx
    8799:	cmp    $0xd,%rbx
    879d:	cmove  0x1423(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    87a5:	cmp    $0x6,%rcx
    87a9:	jne    87bf <botlish_fn_19+0x7437>
    87af:	mov    %rbx,%rsi
    87b2:	mov    0x3d0(%rsp),%rbx
    87ba:	jmp    89c3 <botlish_fn_19+0x763b>
    87bf:	test   $0x1,%rbx
    87c6:	jne    87f6 <botlish_fn_19+0x746e>
    87cc:	mov    $0x9,%edx
    87d1:	mov    %rbx,%rsi
    87d4:	mov    0x3c0(%rsp),%rdi
    87dc:	call   87e1 <botlish_fn_19+0x7459>
			87dd: R_X86_64_PLT32	rt_int_cmp-0x4
    87e1:	mov    $0x2,%ecx
    87e6:	test   %rax,%rax
    87e9:	cmove  0x13d7(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    87f1:	jmp    8807 <botlish_fn_19+0x747f>
    87f6:	mov    $0x2,%ecx
    87fb:	cmp    $0x9,%rbx
    87ff:	cmove  0x13c1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    8807:	cmp    $0x6,%rcx
    880b:	jne    8821 <botlish_fn_19+0x7499>
    8811:	mov    %rbx,%rsi
    8814:	mov    0x3d0(%rsp),%rbx
    881c:	jmp    89c3 <botlish_fn_19+0x763b>
    8821:	mov    %r12,%rsi
    8824:	mov    0x3c0(%rsp),%rdi
    882c:	call   8831 <botlish_fn_19+0x74a9>
			882d: R_X86_64_PLT32	botlish_fn_15-0x4
    8831:	cmp    $0x6,%rax
    8835:	je     8896 <botlish_fn_19+0x750e>
    883b:	mov    %rbx,%rsi
    883e:	mov    0x3c0(%rsp),%rdi
    8846:	call   884b <botlish_fn_19+0x74c3>
			8847: R_X86_64_PLT32	botlish_fn_16-0x4
    884b:	mov    0x3c0(%rsp),%rdi
    8853:	mov    0x10(%rdi),%rcx
    8857:	mov    0x1e0(%rcx),%rdx
    885e:	lea    0x288(%rsp),%r9
    8866:	mov    0x440(%rsp),%rcx
    886e:	mov    %rcx,0x288(%rsp)
    8876:	mov    %rax,0x290(%rsp)
    887e:	mov    $0x6,%ecx
    8883:	mov    $0x2,%r8d
    8889:	mov    %rcx,%rsi
    888c:	call   8891 <botlish_fn_19+0x7509>
			888d: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8891:	jmp    8ce7 <botlish_fn_19+0x795f>
    8896:	mov    %rbx,%rsi
    8899:	test   $0x1,%rsi
    88a0:	jne    88ce <botlish_fn_19+0x7546>
    88a6:	mov    $0x5,%edx
    88ab:	mov    0x3c0(%rsp),%rdi
    88b3:	call   88b8 <botlish_fn_19+0x7530>
			88b4: R_X86_64_PLT32	rt_int_cmp-0x4
    88b8:	mov    $0x2,%r11d
    88be:	test   %rax,%rax
    88c1:	cmove  0x12ff(%rip),%r11        # 9bc8 <botlish_fn_19+0x8840>
    88c9:	jmp    88e0 <botlish_fn_19+0x7558>
    88ce:	mov    $0x2,%r11d
    88d4:	cmp    $0x5,%rsi
    88d8:	cmove  0x12e8(%rip),%r11        # 9bc8 <botlish_fn_19+0x8840>
    88e0:	cmp    $0x6,%r11
    88e4:	jne    8907 <botlish_fn_19+0x757f>
    88ea:	mov    0x450(%rsp),%rdx
    88f2:	mov    0x480(%rsp),%rsi
    88fa:	mov    0x3c0(%rsp),%rdi
    8902:	call   8907 <botlish_fn_19+0x757f>
			8903: R_X86_64_PLT32	rt_mv_push-0x4
    8907:	cmp    $0x52,%r12
    890b:	jne    892b <botlish_fn_19+0x75a3>
    8911:	mov    $0x5,%edx
    8916:	mov    0x480(%rsp),%rsi
    891e:	mov    0x3c0(%rsp),%rdi
    8926:	call   892b <botlish_fn_19+0x75a3>
			8927: R_X86_64_PLT32	rt_mv_push-0x4
    892b:	cmp    $0x12,%r12
    892f:	jne    894f <botlish_fn_19+0x75c7>
    8935:	mov    $0x9,%edx
    893a:	mov    0x480(%rsp),%rsi
    8942:	mov    0x3c0(%rsp),%rdi
    894a:	call   894f <botlish_fn_19+0x75c7>
			894b: R_X86_64_PLT32	rt_mv_push-0x4
    894f:	mov    0x480(%rsp),%rsi
    8957:	mov    0x3c0(%rsp),%rdi
    895f:	call   8964 <botlish_fn_19+0x75dc>
			8960: R_X86_64_PLT32	rt_mv_len-0x4
    8964:	sar    $1,%rax
    8967:	mov    0x3d0(%rsp),%rbx
    896f:	mov    %rbx,%rcx
    8972:	sar    $1,%rcx
    8975:	add    $0x1,%rcx
    897c:	cmp    %rcx,%rax
    897f:	jle    8c5f <botlish_fn_19+0x78d7>
    8985:	mov    0x3c0(%rsp),%rdi
    898d:	mov    0x10(%rdi),%rax
    8991:	mov    0x1e8(%rax),%rdx
    8998:	lea    0x298(%rsp),%r9
    89a0:	mov    %rbx,0x298(%rsp)
    89a8:	mov    $0x1,%r8d
    89ae:	mov    0x450(%rsp),%rcx
    89b6:	mov    %rcx,%rsi
    89b9:	call   89be <botlish_fn_19+0x7636>
			89ba: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    89be:	jmp    8ce7 <botlish_fn_19+0x795f>
    89c3:	cmp    $0xd2,%r12
    89ca:	je     8a28 <botlish_fn_19+0x76a0>
    89d0:	mov    0x3c0(%rsp),%rdi
    89d8:	call   89dd <botlish_fn_19+0x7655>
			89d9: R_X86_64_PLT32	botlish_fn_16-0x4
    89dd:	mov    0x3c0(%rsp),%rdi
    89e5:	mov    0x10(%rdi),%rcx
    89e9:	mov    0x1e0(%rcx),%rdx
    89f0:	lea    0x278(%rsp),%r9
    89f8:	mov    0x440(%rsp),%rcx
    8a00:	mov    %rcx,0x278(%rsp)
    8a08:	mov    %rax,0x280(%rsp)
    8a10:	mov    $0x6,%ecx
    8a15:	mov    $0x2,%r8d
    8a1b:	mov    %rcx,%rsi
    8a1e:	call   8a23 <botlish_fn_19+0x769b>
			8a1f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8a23:	jmp    8ce7 <botlish_fn_19+0x795f>
    8a28:	mov    %rsi,%rax
    8a2b:	sar    $1,%rax
    8a2e:	cmp    $0x4,%rax
    8a32:	jne    8c5f <botlish_fn_19+0x78d7>
    8a38:	mov    $0xb,%edx
    8a3d:	mov    0x480(%rsp),%rsi
    8a45:	mov    0x3c0(%rsp),%rdi
    8a4d:	call   8a52 <botlish_fn_19+0x76ca>
			8a4e: R_X86_64_PLT32	rt_mv_push-0x4
    8a52:	mov    0x488(%rsp),%rdx
    8a5a:	mov    0x480(%rsp),%rsi
    8a62:	mov    0x3c0(%rsp),%rdi
    8a6a:	call   8a6f <botlish_fn_19+0x76e7>
			8a6b: R_X86_64_PLT32	rt_mv_push-0x4
    8a6f:	mov    $0xf,%edx
    8a74:	mov    0x480(%rsp),%rsi
    8a7c:	mov    0x3c0(%rsp),%rdi
    8a84:	call   8a89 <botlish_fn_19+0x7701>
			8a85: R_X86_64_PLT32	rt_mv_push-0x4
    8a89:	jmp    8c5f <botlish_fn_19+0x78d7>
    8a8e:	mov    %rbx,%rsi
    8a91:	mov    0x3d0(%rsp),%rbx
    8a99:	cmp    $0x92,%r12
    8aa0:	je     8c5f <botlish_fn_19+0x78d7>
    8aa6:	mov    0x3c0(%rsp),%rdi
    8aae:	call   8ab3 <botlish_fn_19+0x772b>
			8aaf: R_X86_64_PLT32	botlish_fn_16-0x4
    8ab3:	mov    0x3c0(%rsp),%rdi
    8abb:	mov    0x10(%rdi),%rcx
    8abf:	mov    0x1e0(%rcx),%rdx
    8ac6:	lea    0x268(%rsp),%r9
    8ace:	mov    0x440(%rsp),%rcx
    8ad6:	mov    %rcx,0x268(%rsp)
    8ade:	mov    %rax,0x270(%rsp)
    8ae6:	mov    $0x6,%ecx
    8aeb:	mov    $0x2,%r8d
    8af1:	mov    %rcx,%rsi
    8af4:	call   8af9 <botlish_fn_19+0x7771>
			8af5: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8af9:	jmp    8ce7 <botlish_fn_19+0x795f>
    8afe:	mov    %rsi,%rcx
    8b01:	sar    $1,%rcx
    8b04:	cmp    $0x3,%rcx
    8b08:	jne    8b18 <botlish_fn_19+0x7790>
    8b0e:	cmp    $0x72,%r12
    8b12:	je     8c5f <botlish_fn_19+0x78d7>
    8b18:	cmp    $0x5,%rcx
    8b1c:	jne    8b2c <botlish_fn_19+0x77a4>
    8b22:	cmp    $0x32,%r12
    8b26:	je     8c5f <botlish_fn_19+0x78d7>
    8b2c:	cmp    $0xb2,%r12
    8b33:	je     8b91 <botlish_fn_19+0x7809>
    8b39:	mov    0x3c0(%rsp),%rdi
    8b41:	call   8b46 <botlish_fn_19+0x77be>
			8b42: R_X86_64_PLT32	botlish_fn_16-0x4
    8b46:	mov    0x3c0(%rsp),%rdi
    8b4e:	mov    0x10(%rdi),%rcx
    8b52:	mov    0x1e0(%rcx),%rdx
    8b59:	lea    0x258(%rsp),%r9
    8b61:	mov    0x440(%rsp),%rcx
    8b69:	mov    %rcx,0x258(%rsp)
    8b71:	mov    %rax,0x260(%rsp)
    8b79:	mov    $0x6,%ecx
    8b7e:	mov    $0x2,%r8d
    8b84:	mov    %rcx,%rsi
    8b87:	call   8b8c <botlish_fn_19+0x7804>
			8b88: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8b8c:	jmp    8ce7 <botlish_fn_19+0x795f>
    8b91:	cmp    $0x3,%rcx
    8b95:	je     8c0b <botlish_fn_19+0x7883>
    8b9b:	mov    $0xb,%edx
    8ba0:	mov    0x480(%rsp),%rsi
    8ba8:	mov    0x3c0(%rsp),%rdi
    8bb0:	call   8bb5 <botlish_fn_19+0x782d>
			8bb1: R_X86_64_PLT32	rt_mv_push-0x4
    8bb5:	mov    0x488(%rsp),%rdx
    8bbd:	mov    0x480(%rsp),%rsi
    8bc5:	mov    0x3c0(%rsp),%rdi
    8bcd:	call   8bd2 <botlish_fn_19+0x784a>
			8bce: R_X86_64_PLT32	rt_mv_push-0x4
    8bd2:	mov    $0xf,%edx
    8bd7:	mov    0x480(%rsp),%rsi
    8bdf:	mov    0x3c0(%rsp),%rdi
    8be7:	call   8bec <botlish_fn_19+0x7864>
			8be8: R_X86_64_PLT32	rt_mv_push-0x4
    8bec:	mov    $0xd,%edx
    8bf1:	mov    0x480(%rsp),%rsi
    8bf9:	mov    0x3c0(%rsp),%rdi
    8c01:	call   8c06 <botlish_fn_19+0x787e>
			8c02: R_X86_64_PLT32	rt_mv_push-0x4
    8c06:	jmp    8c5f <botlish_fn_19+0x78d7>
    8c0b:	mov    0x450(%rsp),%rdx
    8c13:	mov    0x480(%rsp),%rsi
    8c1b:	mov    0x3c0(%rsp),%rdi
    8c23:	call   8c28 <botlish_fn_19+0x78a0>
			8c24: R_X86_64_PLT32	rt_mv_push-0x4
    8c28:	mov    0x488(%rsp),%rdx
    8c30:	mov    0x480(%rsp),%rsi
    8c38:	mov    0x3c0(%rsp),%rdi
    8c40:	call   8c45 <botlish_fn_19+0x78bd>
			8c41: R_X86_64_PLT32	rt_mv_push-0x4
    8c45:	jmp    8c5f <botlish_fn_19+0x78d7>
    8c4a:	mov    0x3d0(%rsp),%rbx
    8c52:	jmp    8c5f <botlish_fn_19+0x78d7>
    8c57:	mov    0x3d0(%rsp),%rbx
    8c5f:	mov    $0x6,%r12d
    8c65:	movq   $0x6,0x90(%rsp)
    8c71:	mov    $0x1,%r13d
    8c77:	jmp    8d7e <botlish_fn_19+0x79f6>
    8c7c:	mov    %rbx,%rsi
    8c7f:	mov    0x3d0(%rsp),%rbx
    8c87:	cmp    $0x132,%r12
    8c8e:	je     8d64 <botlish_fn_19+0x79dc>
    8c94:	mov    0x3c0(%rsp),%rdi
    8c9c:	call   8ca1 <botlish_fn_19+0x7919>
			8c9d: R_X86_64_PLT32	botlish_fn_16-0x4
    8ca1:	mov    0x3c0(%rsp),%rdi
    8ca9:	mov    0x10(%rdi),%rcx
    8cad:	mov    0x1e0(%rcx),%rdx
    8cb4:	lea    0x248(%rsp),%r9
    8cbc:	mov    0x440(%rsp),%rcx
    8cc4:	mov    %rcx,0x248(%rsp)
    8ccc:	mov    %rax,0x250(%rsp)
    8cd4:	mov    $0x6,%ecx
    8cd9:	mov    $0x2,%r8d
    8cdf:	mov    %rcx,%rsi
    8ce2:	call   8ce7 <botlish_fn_19+0x795f>
			8ce3: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8ce7:	mov    0x3c0(%rsp),%rdi
    8cef:	call   8cf4 <botlish_fn_19+0x796c>
			8cf0: R_X86_64_PLT32	rt_co_failed-0x4
    8cf4:	mov    %rax,0x98(%rsp)
    8cfc:	mov    %rax,%rsi
    8cff:	mov    0x3c0(%rsp),%rdi
    8d07:	call   8d0c <botlish_fn_19+0x7984>
			8d08: R_X86_64_PLT32	rt_co_resume0-0x4
    8d0c:	test   %rax,%rax
    8d0f:	je     8d31 <botlish_fn_19+0x79a9>
    8d15:	mov    0x3c0(%rsp),%rdi
    8d1d:	mov    0x10(%rdi),%rax
    8d21:	mov    0x48(%rax),%rsi
    8d25:	mov    0x1b8(%rax),%rdx
    8d2c:	call   8d31 <botlish_fn_19+0x79a9>
			8d2d: R_X86_64_PLT32	rt_raise-0x4
    8d31:	mov    0x3c0(%rsp),%rdi
    8d39:	call   8d3e <botlish_fn_19+0x79b6>
			8d3a: R_X86_64_PLT32	rt_declared_error-0x4
    8d3e:	cmp    $0x6,%rax
    8d42:	je     9a02 <botlish_fn_19+0x867a>
    8d48:	mov    0x3c0(%rsp),%rdi
    8d50:	call   8d55 <botlish_fn_19+0x79cd>
			8d51: R_X86_64_PLT32	rt_declared_error-0x4
    8d55:	cmp    $0x7,%rax
    8d59:	jne    9a02 <botlish_fn_19+0x867a>
    8d5f:	jmp    9a02 <botlish_fn_19+0x867a>
    8d64:	mov    $0x6,%r12d
    8d6a:	movq   $0x6,0x90(%rsp)
    8d76:	mov    0x458(%rsp),%r13
    8d7e:	movq   $0x1,0x28(%rsp)
    8d87:	mov    0x468(%rsp),%r14
    8d8f:	mov    0x10(%r14),%rax
    8d93:	mov    (%rax),%rsi
    8d96:	mov    %rsi,0x30(%rsp)
    8d9b:	movq   $0x3,0x38(%rsp)
    8da4:	test   $0x1,%rsi
    8dab:	je     8dc3 <botlish_fn_19+0x7a3b>
    8db1:	mov    %rsi,%rcx
    8db4:	add    $0x2,%rcx
    8db8:	seto   %al
    8dbb:	test   %al,%al
    8dbd:	je     8ddb <botlish_fn_19+0x7a53>
    8dc3:	mov    0x488(%rsp),%rdx
    8dcb:	mov    0x3c0(%rsp),%rdi
    8dd3:	call   8dd8 <botlish_fn_19+0x7a50>
			8dd4: R_X86_64_PLT32	rt_int_add-0x4
    8dd8:	mov    %rax,%rcx
    8ddb:	mov    0x18(%r14),%rsi
    8ddf:	test   %rsi,%rsi
    8de2:	je     9b64 <botlish_fn_19+0x87dc>
    8de8:	mov    0x10(%r14),%rdi
    8dec:	mov    %rcx,(%rdi)
    8def:	mov    0x478(%rsp),%rcx
    8df7:	mov    %rbx,0x3d0(%rsp)
    8dff:	mov    %r13,0x3f0(%rsp)
    8e07:	mov    %r12,0x420(%rsp)
    8e0f:	mov    %r14,0x468(%rsp)
    8e17:	jmp    1b43 <botlish_fn_19+0x7bb>
    8e1c:	mov    0x3d0(%rsp),%rbx
    8e24:	mov    0x420(%rsp),%r12
    8e2c:	mov    0x3f0(%rsp),%r13
    8e34:	mov    0x468(%rsp),%r14
    8e3c:	cmp    $0x1,%r13
    8e40:	je     8e5a <botlish_fn_19+0x7ad2>
    8e46:	mov    $0xa,%esi
    8e4b:	cmp    $0xffffffffffffffff,%r13
    8e4f:	je     94ab <botlish_fn_19+0x8123>
    8e55:	jmp    9434 <botlish_fn_19+0x80ac>
    8e5a:	mov    0x480(%rsp),%rsi
    8e62:	mov    0x3c0(%rsp),%rdi
    8e6a:	call   8e6f <botlish_fn_19+0x7ae7>
			8e6b: R_X86_64_PLT32	rt_mv_pop-0x4
    8e6f:	mov    %rax,%rsi
    8e72:	mov    %rax,%r12
    8e75:	test   %rsi,%rax
    8e78:	jne    8ef6 <botlish_fn_19+0x7b6e>
    8e7e:	mov    0x3c0(%rsp),%rdi
    8e86:	call   8e8b <botlish_fn_19+0x7b03>
			8e87: R_X86_64_PLT32	rt_declared_error-0x4
    8e8b:	cmp    $0x40000001,%rax
    8e91:	jne    941c <botlish_fn_19+0x8094>
    8e97:	mov    0x3c0(%rsp),%rdi
    8e9f:	call   8ea4 <botlish_fn_19+0x7b1c>
			8ea0: R_X86_64_PLT32	rt_clear_declared_error-0x4
    8ea4:	mov    0x3c0(%rsp),%rdi
    8eac:	mov    0x10(%rdi),%rcx
    8eb0:	mov    0x1d8(%rcx),%rax
    8eb7:	mov    0x1e0(%rcx),%rdx
    8ebe:	lea    0x1c0(%rsp),%r9
    8ec6:	mov    0x440(%rsp),%rcx
    8ece:	mov    %rcx,0x1c0(%rsp)
    8ed6:	mov    %rax,0x1c8(%rsp)
    8ede:	mov    $0x6,%ecx
    8ee3:	mov    $0x2,%r8d
    8ee9:	mov    %rcx,%rsi
    8eec:	call   8ef1 <botlish_fn_19+0x7b69>
			8eed: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8ef1:	jmp    941c <botlish_fn_19+0x8094>
    8ef6:	mov    %r12,%rax
    8ef9:	test   $0x1,%rax
    8eff:	jne    8f2f <botlish_fn_19+0x7ba7>
    8f05:	mov    $0x1,%edx
    8f0a:	mov    %r12,%rsi
    8f0d:	mov    0x3c0(%rsp),%rdi
    8f15:	call   8f1a <botlish_fn_19+0x7b92>
			8f16: R_X86_64_PLT32	rt_int_cmp-0x4
    8f1a:	mov    $0x2,%ecx
    8f1f:	test   %rax,%rax
    8f22:	cmove  0xc9e(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    8f2a:	jmp    8f40 <botlish_fn_19+0x7bb8>
    8f2f:	mov    $0x2,%ecx
    8f34:	cmp    $0x1,%r12
    8f38:	cmove  0xc88(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    8f40:	cmp    $0x6,%rcx
    8f44:	je     9499 <botlish_fn_19+0x8111>
    8f4a:	test   $0x1,%r12
    8f51:	jne    8f81 <botlish_fn_19+0x7bf9>
    8f57:	mov    $0x5,%edx
    8f5c:	mov    %r12,%rsi
    8f5f:	mov    0x3c0(%rsp),%rdi
    8f67:	call   8f6c <botlish_fn_19+0x7be4>
			8f68: R_X86_64_PLT32	rt_int_cmp-0x4
    8f6c:	mov    $0x2,%ecx
    8f71:	test   %rax,%rax
    8f74:	cmove  0xc4c(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    8f7c:	jmp    8f92 <botlish_fn_19+0x7c0a>
    8f81:	mov    $0x2,%ecx
    8f86:	cmp    $0x5,%r12
    8f8a:	cmove  0xc36(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    8f92:	cmp    $0x6,%rcx
    8f96:	test   $0x1,%r12
    8f9d:	jne    8fcd <botlish_fn_19+0x7c45>
    8fa3:	mov    $0x9,%edx
    8fa8:	mov    %r12,%rsi
    8fab:	mov    0x3c0(%rsp),%rdi
    8fb3:	call   8fb8 <botlish_fn_19+0x7c30>
			8fb4: R_X86_64_PLT32	rt_int_cmp-0x4
    8fb8:	mov    $0x2,%ecx
    8fbd:	test   %rax,%rax
    8fc0:	cmove  0xc00(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    8fc8:	jmp    8fde <botlish_fn_19+0x7c56>
    8fcd:	mov    $0x2,%ecx
    8fd2:	cmp    $0x9,%r12
    8fd6:	cmove  0xbea(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    8fde:	cmp    $0x6,%rcx
    8fe2:	test   $0x1,%r12
    8fe9:	jne    901c <botlish_fn_19+0x7c94>
    8fef:	mov    0x450(%rsp),%rdx
    8ff7:	mov    %r12,%rsi
    8ffa:	mov    0x3c0(%rsp),%rdi
    9002:	call   9007 <botlish_fn_19+0x7c7f>
			9003: R_X86_64_PLT32	rt_int_cmp-0x4
    9007:	mov    $0x2,%ecx
    900c:	test   %rax,%rax
    900f:	cmove  0xbb1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    9017:	jmp    902d <botlish_fn_19+0x7ca5>
    901c:	mov    $0x2,%ecx
    9021:	cmp    $0x7,%r12
    9025:	cmove  0xb9b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    902d:	cmp    $0x6,%rcx
    9031:	jne    903f <botlish_fn_19+0x7cb7>
    9037:	mov    %r12,%rsi
    903a:	jmp    93bb <botlish_fn_19+0x8033>
    903f:	test   $0x1,%r12
    9046:	jne    9076 <botlish_fn_19+0x7cee>
    904c:	mov    $0xb,%edx
    9051:	mov    %r12,%rsi
    9054:	mov    0x3c0(%rsp),%rdi
    905c:	call   9061 <botlish_fn_19+0x7cd9>
			905d: R_X86_64_PLT32	rt_int_cmp-0x4
    9061:	mov    $0x2,%ecx
    9066:	test   %rax,%rax
    9069:	cmove  0xb57(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    9071:	jmp    9087 <botlish_fn_19+0x7cff>
    9076:	mov    $0x2,%ecx
    907b:	cmp    $0xb,%r12
    907f:	cmove  0xb41(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    9087:	cmp    $0x6,%rcx
    908b:	jne    9099 <botlish_fn_19+0x7d11>
    9091:	mov    %r12,%rsi
    9094:	jmp    93bb <botlish_fn_19+0x8033>
    9099:	test   $0x1,%r12
    90a0:	jne    90d0 <botlish_fn_19+0x7d48>
    90a6:	mov    $0xf,%edx
    90ab:	mov    %r12,%rsi
    90ae:	mov    0x3c0(%rsp),%rdi
    90b6:	call   90bb <botlish_fn_19+0x7d33>
			90b7: R_X86_64_PLT32	rt_int_cmp-0x4
    90bb:	mov    $0x2,%ecx
    90c0:	test   %rax,%rax
    90c3:	cmove  0xafd(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    90cb:	jmp    90e1 <botlish_fn_19+0x7d59>
    90d0:	mov    $0x2,%ecx
    90d5:	cmp    $0xf,%r12
    90d9:	cmove  0xae7(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    90e1:	cmp    $0x6,%rcx
    90e5:	je     9360 <botlish_fn_19+0x7fd8>
    90eb:	test   $0x1,%r12
    90f2:	jne    9122 <botlish_fn_19+0x7d9a>
    90f8:	mov    $0xd,%edx
    90fd:	mov    %r12,%rsi
    9100:	mov    0x3c0(%rsp),%rdi
    9108:	call   910d <botlish_fn_19+0x7d85>
			9109: R_X86_64_PLT32	rt_int_cmp-0x4
    910d:	mov    $0x2,%ecx
    9112:	test   %rax,%rax
    9115:	cmove  0xaab(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    911d:	jmp    9133 <botlish_fn_19+0x7dab>
    9122:	mov    $0x2,%ecx
    9127:	cmp    $0xd,%r12
    912b:	cmove  0xa95(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    9133:	cmp    $0x6,%rcx
    9137:	jne    9145 <botlish_fn_19+0x7dbd>
    913d:	mov    %r12,%rsi
    9140:	jmp    9308 <botlish_fn_19+0x7f80>
    9145:	test   $0x1,%r12
    914c:	jne    917c <botlish_fn_19+0x7df4>
    9152:	mov    $0x9,%edx
    9157:	mov    %r12,%rsi
    915a:	mov    0x3c0(%rsp),%rdi
    9162:	call   9167 <botlish_fn_19+0x7ddf>
			9163: R_X86_64_PLT32	rt_int_cmp-0x4
    9167:	mov    $0x2,%ecx
    916c:	test   %rax,%rax
    916f:	cmove  0xa51(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    9177:	jmp    918d <botlish_fn_19+0x7e05>
    917c:	mov    $0x2,%ecx
    9181:	cmp    $0x9,%r12
    9185:	cmove  0xa3b(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    918d:	cmp    $0x6,%rcx
    9191:	jne    919f <botlish_fn_19+0x7e17>
    9197:	mov    %r12,%rsi
    919a:	jmp    9308 <botlish_fn_19+0x7f80>
    919f:	mov    $0x132,%esi
    91a4:	mov    0x3c0(%rsp),%rdi
    91ac:	call   91b1 <botlish_fn_19+0x7e29>
			91ad: R_X86_64_PLT32	botlish_fn_15-0x4
    91b1:	cmp    $0x6,%rax
    91b5:	je     9216 <botlish_fn_19+0x7e8e>
    91bb:	mov    %r12,%rsi
    91be:	mov    0x3c0(%rsp),%rdi
    91c6:	call   91cb <botlish_fn_19+0x7e43>
			91c7: R_X86_64_PLT32	botlish_fn_16-0x4
    91cb:	mov    0x3c0(%rsp),%rdi
    91d3:	mov    0x10(%rdi),%rcx
    91d7:	mov    0x1e0(%rcx),%rdx
    91de:	lea    0x210(%rsp),%r9
    91e6:	mov    0x440(%rsp),%rcx
    91ee:	mov    %rcx,0x210(%rsp)
    91f6:	mov    %rax,0x218(%rsp)
    91fe:	mov    $0x6,%ecx
    9203:	mov    $0x2,%r8d
    9209:	mov    %rcx,%rsi
    920c:	call   9211 <botlish_fn_19+0x7e89>
			920d: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9211:	jmp    941c <botlish_fn_19+0x8094>
    9216:	mov    %r12,%rsi
    9219:	test   $0x1,%rsi
    9220:	jne    924d <botlish_fn_19+0x7ec5>
    9226:	mov    $0x5,%edx
    922b:	mov    0x3c0(%rsp),%rdi
    9233:	call   9238 <botlish_fn_19+0x7eb0>
			9234: R_X86_64_PLT32	rt_int_cmp-0x4
    9238:	mov    $0x2,%ecx
    923d:	test   %rax,%rax
    9240:	cmove  0x980(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    9248:	jmp    925e <botlish_fn_19+0x7ed6>
    924d:	mov    $0x2,%ecx
    9252:	cmp    $0x5,%rsi
    9256:	cmove  0x96a(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    925e:	cmp    $0x6,%rcx
    9262:	jne    9285 <botlish_fn_19+0x7efd>
    9268:	mov    0x450(%rsp),%rdx
    9270:	mov    0x480(%rsp),%rsi
    9278:	mov    0x3c0(%rsp),%rdi
    9280:	call   9285 <botlish_fn_19+0x7efd>
			9281: R_X86_64_PLT32	rt_mv_push-0x4
    9285:	mov    0x480(%rsp),%rsi
    928d:	mov    0x3c0(%rsp),%rdi
    9295:	call   929a <botlish_fn_19+0x7f12>
			9296: R_X86_64_PLT32	rt_mv_len-0x4
    929a:	sar    $1,%rax
    929d:	mov    %rbx,%rcx
    92a0:	sar    $1,%rcx
    92a3:	add    $0x1,%rcx
    92aa:	cmp    %rcx,%rax
    92ad:	jg     92ca <botlish_fn_19+0x7f42>
    92b3:	mov    $0x6,%r12d
    92b9:	movq   $0x6,0x90(%rsp)
    92c5:	jmp    94ab <botlish_fn_19+0x8123>
    92ca:	mov    0x3c0(%rsp),%rdi
    92d2:	mov    0x10(%rdi),%rsi
    92d6:	mov    0x1e8(%rsi),%rdx
    92dd:	lea    0x220(%rsp),%r9
    92e5:	mov    %rbx,0x220(%rsp)
    92ed:	mov    $0x1,%r8d
    92f3:	mov    0x450(%rsp),%rcx
    92fb:	mov    %rcx,%rsi
    92fe:	call   9303 <botlish_fn_19+0x7f7b>
			92ff: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9303:	jmp    941c <botlish_fn_19+0x8094>
    9308:	mov    0x3c0(%rsp),%rdi
    9310:	call   9315 <botlish_fn_19+0x7f8d>
			9311: R_X86_64_PLT32	botlish_fn_16-0x4
    9315:	mov    0x3c0(%rsp),%rdi
    931d:	mov    0x10(%rdi),%r8
    9321:	mov    0x1e0(%r8),%rdx
    9328:	lea    0x200(%rsp),%r9
    9330:	mov    0x440(%rsp),%rcx
    9338:	mov    %rcx,0x200(%rsp)
    9340:	mov    %rax,0x208(%rsp)
    9348:	mov    $0x6,%ecx
    934d:	mov    $0x2,%r8d
    9353:	mov    %rcx,%rsi
    9356:	call   935b <botlish_fn_19+0x7fd3>
			9357: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    935b:	jmp    941c <botlish_fn_19+0x8094>
    9360:	mov    %r12,%rsi
    9363:	mov    0x3c0(%rsp),%rdi
    936b:	call   9370 <botlish_fn_19+0x7fe8>
			936c: R_X86_64_PLT32	botlish_fn_16-0x4
    9370:	mov    0x3c0(%rsp),%rdi
    9378:	mov    0x10(%rdi),%rcx
    937c:	mov    0x1e0(%rcx),%rdx
    9383:	lea    0x1f0(%rsp),%r9
    938b:	mov    0x440(%rsp),%rcx
    9393:	mov    %rcx,0x1f0(%rsp)
    939b:	mov    %rax,0x1f8(%rsp)
    93a3:	mov    $0x6,%ecx
    93a8:	mov    $0x2,%r8d
    93ae:	mov    %rcx,%rsi
    93b1:	call   93b6 <botlish_fn_19+0x802e>
			93b2: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    93b6:	jmp    941c <botlish_fn_19+0x8094>
    93bb:	mov    %rsi,%rax
    93be:	sar    $1,%rax
    93c1:	cmp    $0x3,%rax
    93c5:	cmp    $0x5,%rax
    93c9:	mov    0x3c0(%rsp),%rdi
    93d1:	call   93d6 <botlish_fn_19+0x804e>
			93d2: R_X86_64_PLT32	botlish_fn_16-0x4
    93d6:	mov    0x3c0(%rsp),%rdi
    93de:	mov    0x10(%rdi),%rcx
    93e2:	mov    0x1e0(%rcx),%rdx
    93e9:	lea    0x1e0(%rsp),%r9
    93f1:	mov    0x440(%rsp),%rcx
    93f9:	mov    %rcx,0x1e0(%rsp)
    9401:	mov    %rax,0x1e8(%rsp)
    9409:	mov    $0x6,%ecx
    940e:	mov    $0x2,%r8d
    9414:	mov    %rcx,%rsi
    9417:	call   941c <botlish_fn_19+0x8094>
			9418: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    941c:	mov    0x3c0(%rsp),%rdi
    9424:	call   9429 <botlish_fn_19+0x80a1>
			9425: R_X86_64_PLT32	rt_co_failed-0x4
    9429:	mov    %rax,0x98(%rsp)
    9431:	mov    %rax,%rsi
    9434:	mov    0x3c0(%rsp),%rdi
    943c:	call   9441 <botlish_fn_19+0x80b9>
			943d: R_X86_64_PLT32	rt_co_resume0-0x4
    9441:	test   %rax,%rax
    9444:	je     9466 <botlish_fn_19+0x80de>
    944a:	mov    0x3c0(%rsp),%rdi
    9452:	mov    0x10(%rdi),%rax
    9456:	mov    0x48(%rax),%rsi
    945a:	mov    0x1b8(%rax),%rdx
    9461:	call   9466 <botlish_fn_19+0x80de>
			9462: R_X86_64_PLT32	rt_raise-0x4
    9466:	mov    0x3c0(%rsp),%rdi
    946e:	call   9473 <botlish_fn_19+0x80eb>
			946f: R_X86_64_PLT32	rt_declared_error-0x4
    9473:	cmp    $0x6,%rax
    9477:	je     9a02 <botlish_fn_19+0x867a>
    947d:	mov    0x3c0(%rsp),%rdi
    9485:	call   948a <botlish_fn_19+0x8102>
			9486: R_X86_64_PLT32	rt_declared_error-0x4
    948a:	cmp    $0x7,%rax
    948e:	jne    9a02 <botlish_fn_19+0x867a>
    9494:	jmp    9a02 <botlish_fn_19+0x867a>
    9499:	mov    $0x6,%r12d
    949f:	movq   $0x6,0x90(%rsp)
    94ab:	mov    0x10(%r14),%rax
    94af:	mov    (%rax),%rax
    94b2:	mov    %rax,(%rsp)
    94b6:	mov    0x470(%rsp),%rdx
    94be:	mov    0x10(%rdx),%rcx
    94c2:	mov    (%rcx),%rdx
    94c5:	mov    %rdx,0x8(%rsp)
    94ca:	lea    0x128(%rsp),%rcx
    94d2:	mov    %rax,0x128(%rsp)
    94da:	mov    %rdx,0x130(%rsp)
    94e2:	xor    %rsi,%rsi
    94e5:	mov    $0x2,%edx
    94ea:	mov    0x3c0(%rsp),%rdi
    94f2:	call   94f7 <botlish_fn_19+0x816f>
			94f3: R_X86_64_PLT32	rt_struct_new-0x4
    94f7:	mov    0x4a0(%rsp),%rbx
    94ff:	mov    0x4a8(%rsp),%r12
    9507:	mov    0x4b0(%rsp),%r13
    950f:	mov    0x4b8(%rsp),%r14
    9517:	mov    0x4c0(%rsp),%r15
    951f:	add    $0x4d0,%rsp
    9526:	mov    %rbp,%rsp
    9529:	pop    %rbp
    952a:	ret
    952b:	mov    0x3d0(%rsp),%rbx
    9533:	mov    0x420(%rsp),%r12
    953b:	mov    0x3f0(%rsp),%r13
    9543:	mov    0x468(%rsp),%r14
    954b:	movq   $0x1,0x28(%rsp)
    9554:	mov    0x470(%rsp),%rdx
    955c:	mov    0x10(%rdx),%rax
    9560:	mov    (%rax),%rsi
    9563:	mov    %rsi,0x30(%rsp)
    9568:	movq   $0x3,0x38(%rsp)
    9571:	test   $0x1,%rsi
    9578:	je     959d <botlish_fn_19+0x8215>
    957e:	mov    %rsi,%rcx
    9581:	add    $0x2,%rcx
    9585:	seto   %al
    9588:	test   %al,%al
    958a:	jne    959d <botlish_fn_19+0x8215>
    9590:	mov    0x470(%rsp),%rdx
    9598:	jmp    95bd <botlish_fn_19+0x8235>
    959d:	mov    0x488(%rsp),%rdx
    95a5:	mov    0x3c0(%rsp),%rdi
    95ad:	call   95b2 <botlish_fn_19+0x822a>
			95ae: R_X86_64_PLT32	rt_int_add-0x4
    95b2:	mov    %rax,%rcx
    95b5:	mov    0x470(%rsp),%rdx
    95bd:	mov    0x470(%rsp),%rdx
    95c5:	mov    0x18(%rdx),%rdx
    95c9:	test   %rdx,%rdx
    95cc:	je     9b7e <botlish_fn_19+0x87f6>
    95d2:	mov    0x470(%rsp),%rdx
    95da:	mov    0x10(%rdx),%rsi
    95de:	mov    %rcx,(%rsi)
    95e1:	movq   $0x1,0x28(%rsp)
    95ea:	mov    0x3e8(%rsp),%r15
    95f2:	cmp    $0x1,%r15
    95f6:	je     9618 <botlish_fn_19+0x8290>
    95fc:	mov    $0xa,%esi
    9601:	cmp    $0xffffffffffffffff,%r15
    9605:	jne    99a8 <botlish_fn_19+0x8620>
    960b:	mov    0x478(%rsp),%rcx
    9613:	jmp    9a79 <botlish_fn_19+0x86f1>
    9618:	movq   $0x3,0x40(%rsp)
    9621:	mov    0x400(%rsp),%rsi
    9629:	test   $0x1,%rsi
    9630:	jne    9643 <botlish_fn_19+0x82bb>
    9636:	mov    0x400(%rsp),%rsi
    963e:	jmp    967a <botlish_fn_19+0x82f2>
    9643:	mov    0x400(%rsp),%rsi
    964b:	mov    %rsi,%rax
    964e:	add    $0x2,%rax
    9652:	seto   %cl
    9655:	test   %cl,%cl
    9657:	je     966a <botlish_fn_19+0x82e2>
    965d:	mov    0x400(%rsp),%rsi
    9665:	jmp    967a <botlish_fn_19+0x82f2>
    966a:	mov    %rax,%rsi
    966d:	mov    %rax,0x400(%rsp)
    9675:	jmp    969a <botlish_fn_19+0x8312>
    967a:	mov    0x488(%rsp),%rdx
    9682:	mov    0x3c0(%rsp),%rdi
    968a:	call   968f <botlish_fn_19+0x8307>
			968b: R_X86_64_PLT32	rt_int_add-0x4
    968f:	mov    %rax,%rsi
    9692:	mov    %rax,0x400(%rsp)
    969a:	mov    %rsi,0x88(%rsp)
    96a2:	mov    0x408(%rsp),%rax
    96aa:	mov    0x400(%rsp),%rsi
    96b2:	mov    %rsi,%rcx
    96b5:	and    %rax,%rcx
    96b8:	test   $0x1,%rcx
    96bf:	jne    96f7 <botlish_fn_19+0x836f>
    96c5:	mov    0x408(%rsp),%rdx
    96cd:	mov    0x400(%rsp),%rsi
    96d5:	mov    0x3c0(%rsp),%rdi
    96dd:	call   96e2 <botlish_fn_19+0x835a>
			96de: R_X86_64_PLT32	rt_int_cmp-0x4
    96e2:	mov    $0x2,%ecx
    96e7:	test   %rax,%rax
    96ea:	cmovl  0x4d6(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    96f2:	jmp    9717 <botlish_fn_19+0x838f>
    96f7:	mov    $0x2,%ecx
    96fc:	mov    0x408(%rsp),%rax
    9704:	mov    0x400(%rsp),%rsi
    970c:	cmp    %rax,%rsi
    970f:	cmovl  0x4b1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    9717:	cmp    $0x6,%rcx
    971b:	je     992a <botlish_fn_19+0x85a2>
    9721:	movq   $0x3,0x40(%rsp)
    972a:	mov    0x418(%rsp),%rsi
    9732:	test   $0x1,%rsi
    9739:	jne    974c <botlish_fn_19+0x83c4>
    973f:	mov    0x418(%rsp),%rsi
    9747:	jmp    9783 <botlish_fn_19+0x83fb>
    974c:	mov    0x418(%rsp),%rsi
    9754:	mov    %rsi,%rax
    9757:	add    $0x2,%rax
    975b:	seto   %cl
    975e:	test   %cl,%cl
    9760:	je     9773 <botlish_fn_19+0x83eb>
    9766:	mov    0x418(%rsp),%rsi
    976e:	jmp    9783 <botlish_fn_19+0x83fb>
    9773:	mov    %rax,%rsi
    9776:	mov    %rax,0x418(%rsp)
    977e:	jmp    97a3 <botlish_fn_19+0x841b>
    9783:	mov    0x488(%rsp),%rdx
    978b:	mov    0x3c0(%rsp),%rdi
    9793:	call   9798 <botlish_fn_19+0x8410>
			9794: R_X86_64_PLT32	rt_int_add-0x4
    9798:	mov    %rax,%rsi
    979b:	mov    %rax,0x418(%rsp)
    97a3:	mov    %rsi,0x70(%rsp)
    97a8:	mov    0x490(%rsp),%rcx
    97b0:	mov    0x418(%rsp),%rsi
    97b8:	mov    %rsi,%rax
    97bb:	and    %rcx,%rax
    97be:	test   $0x1,%rax
    97c4:	jne    97fc <botlish_fn_19+0x8474>
    97ca:	mov    0x490(%rsp),%rdx
    97d2:	mov    0x418(%rsp),%rsi
    97da:	mov    0x3c0(%rsp),%rdi
    97e2:	call   97e7 <botlish_fn_19+0x845f>
			97e3: R_X86_64_PLT32	rt_int_cmp-0x4
    97e7:	mov    $0x2,%ecx
    97ec:	test   %rax,%rax
    97ef:	cmovl  0x3d1(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    97f7:	jmp    981c <botlish_fn_19+0x8494>
    97fc:	mov    $0x2,%ecx
    9801:	mov    0x490(%rsp),%rax
    9809:	mov    0x418(%rsp),%rsi
    9811:	cmp    %rax,%rsi
    9814:	cmovl  0x3ac(%rip),%rcx        # 9bc8 <botlish_fn_19+0x8840>
    981c:	cmp    $0x6,%rcx
    9820:	je     9854 <botlish_fn_19+0x84cc>
    9826:	movq   $0xffffffffffffffff,0x50(%rsp)
    982f:	mov    0x478(%rsp),%rcx
    9837:	mov    0x458(%rsp),%r15
    983f:	mov    0x458(%rsp),%rax
    9847:	mov    %rax,0x3f8(%rsp)
    984f:	jmp    9a79 <botlish_fn_19+0x86f1>
    9854:	mov    0x418(%rsp),%rsi
    985c:	test   $0x1,%rsi
    9863:	je     988c <botlish_fn_19+0x8504>
    9869:	mov    0x3c8(%rsp),%rcx
    9871:	mov    0x8(%rcx),%rdx
    9875:	mov    0x418(%rsp),%rsi
    987d:	mov    %rsi,%rcx
    9880:	sar    $1,%rcx
    9883:	cmp    %rdx,%rcx
    9886:	jb     98ca <botlish_fn_19+0x8542>
    988c:	mov    0x418(%rsp),%rdx
    9894:	mov    0x3c8(%rsp),%rsi
    989c:	mov    0x3c0(%rsp),%rdi
    98a4:	call   98a9 <botlish_fn_19+0x8521>
			98a5: R_X86_64_PLT32	rt_list_get-0x4
    98a9:	mov    %rax,%rcx
    98ac:	mov    %rax,0x410(%rsp)
    98b4:	test   %rcx,%rax
    98b7:	je     9993 <botlish_fn_19+0x860b>
    98bd:	mov    0x410(%rsp),%rax
    98c5:	jmp    98e2 <botlish_fn_19+0x855a>
    98ca:	mov    0x3c8(%rsp),%rax
    98d2:	mov    0x10(%rax),%r8
    98d6:	mov    (%r8,%rcx,8),%rax
    98da:	mov    %rax,0x410(%rsp)
    98e2:	mov    %rax,0x78(%rsp)
    98e7:	mov    0x410(%rsp),%rsi
    98ef:	mov    0x3c0(%rsp),%rdi
    98f7:	call   98fc <botlish_fn_19+0x8574>
			98f8: R_X86_64_PLT32	rt_list_len-0x4
    98fc:	mov    %rax,0x408(%rsp)
    9904:	mov    %rax,0x80(%rsp)
    990c:	mov    $0x1,%esi
    9911:	mov    %rsi,0x400(%rsp)
    9919:	movq   $0x1,0x88(%rsp)
    9925:	jmp    96b2 <botlish_fn_19+0x832a>
    992a:	mov    0x400(%rsp),%rsi
    9932:	test   $0x1,%rsi
    9939:	je     9962 <botlish_fn_19+0x85da>
    993f:	mov    0x410(%rsp),%rax
    9947:	mov    0x8(%rax),%rdx
    994b:	mov    0x400(%rsp),%rsi
    9953:	mov    %rsi,%rcx
    9956:	sar    $1,%rcx
    9959:	cmp    %rdx,%rcx
    995c:	jb     9a46 <botlish_fn_19+0x86be>
    9962:	mov    0x400(%rsp),%rdx
    996a:	mov    0x410(%rsp),%rsi
    9972:	mov    0x3c0(%rsp),%rdi
    997a:	call   997f <botlish_fn_19+0x85f7>
			997b: R_X86_64_PLT32	rt_list_get-0x4
    997f:	mov    %rax,%rcx
    9982:	mov    %rax,0x3f8(%rsp)
    998a:	test   %rcx,%rax
    998d:	jne    9a39 <botlish_fn_19+0x86b1>
    9993:	mov    0x3c0(%rsp),%rdi
    999b:	call   99a0 <botlish_fn_19+0x8618>
			999c: R_X86_64_PLT32	rt_co_failed-0x4
    99a0:	mov    %rax,0x58(%rsp)
    99a5:	mov    %rax,%rsi
    99a8:	mov    0x3c0(%rsp),%rdi
    99b0:	call   99b5 <botlish_fn_19+0x862d>
			99b1: R_X86_64_PLT32	rt_co_resume0-0x4
    99b5:	test   %rax,%rax
    99b8:	jne    99cb <botlish_fn_19+0x8643>
    99be:	mov    0x3c0(%rsp),%rdi
    99c6:	jmp    99ef <botlish_fn_19+0x8667>
    99cb:	mov    0x3c0(%rsp),%rdi
    99d3:	mov    0x10(%rdi),%rax
    99d7:	mov    0x48(%rax),%rsi
    99db:	mov    0x1b8(%rax),%rdx
    99e2:	call   99e7 <botlish_fn_19+0x865f>
			99e3: R_X86_64_PLT32	rt_raise-0x4
    99e7:	mov    0x3c0(%rsp),%rdi
    99ef:	mov    0x3c0(%rsp),%rdi
    99f7:	call   99fc <botlish_fn_19+0x8674>
			99f8: R_X86_64_PLT32	rt_declared_error-0x4
    99fc:	cmp    $0x40000001,%rax
    9a02:	xor    %rax,%rax
    9a05:	mov    0x4a0(%rsp),%rbx
    9a0d:	mov    0x4a8(%rsp),%r12
    9a15:	mov    0x4b0(%rsp),%r13
    9a1d:	mov    0x4b8(%rsp),%r14
    9a25:	mov    0x4c0(%rsp),%r15
    9a2d:	add    $0x4d0,%rsp
    9a34:	mov    %rbp,%rsp
    9a37:	pop    %rbp
    9a38:	ret
    9a39:	mov    0x3f8(%rsp),%rax
    9a41:	jmp    9a66 <botlish_fn_19+0x86de>
    9a46:	mov    0x410(%rsp),%rax
    9a4e:	mov    0x10(%rax),%rax
    9a52:	mov    (%rax,%rcx,8),%rcx
    9a56:	mov    %rcx,0x3f8(%rsp)
    9a5e:	mov    0x3f8(%rsp),%rax
    9a66:	mov    %rax,0x50(%rsp)
    9a6b:	mov    $0x1,%r15d
    9a71:	mov    0x478(%rsp),%rcx
    9a79:	mov    0x478(%rsp),%rcx
    9a81:	mov    0x18(%rcx),%rax
    9a85:	test   %rax,%rax
    9a88:	je     9b9d <botlish_fn_19+0x8815>
    9a8e:	mov    0x478(%rsp),%rcx
    9a96:	mov    0x10(%rcx),%rax
    9a9a:	mov    0x3f8(%rsp),%rcx
    9aa2:	mov    %rcx,(%rax)
    9aa5:	mov    0x478(%rsp),%rcx
    9aad:	mov    %rbx,0x3d0(%rsp)
    9ab5:	mov    %r15,0x3e8(%rsp)
    9abd:	mov    %r13,0x3f0(%rsp)
    9ac5:	mov    %r12,0x420(%rsp)
    9acd:	mov    %r14,0x468(%rsp)
    9ad5:	jmp    1b43 <botlish_fn_19+0x7bb>
    9ada:	mov    $0x1,%edx
    9adf:	mov    %r12,%rcx
    9ae2:	mov    0x460(%rsp),%rsi
    9aea:	mov    0x3c0(%rsp),%rdi
    9af2:	call   9af7 <botlish_fn_19+0x876f>
			9af3: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    9af7:	jmp    3575 <botlish_fn_19+0x21ed>
    9afc:	mov    $0x1,%edx
    9b01:	mov    0x470(%rsp),%rsi
    9b09:	mov    0x3c0(%rsp),%rdi
    9b11:	call   9b16 <botlish_fn_19+0x878e>
			9b12: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    9b16:	jmp    362c <botlish_fn_19+0x22a4>
    9b1b:	mov    $0x1,%edx
    9b20:	mov    0x3f8(%rsp),%rcx
    9b28:	mov    0x478(%rsp),%rsi
    9b30:	mov    0x3c0(%rsp),%rdi
    9b38:	call   9b3d <botlish_fn_19+0x87b5>
			9b39: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    9b3d:	jmp    3ad5 <botlish_fn_19+0x274d>
    9b42:	mov    $0x1,%edx
    9b47:	mov    %r12,%rcx
    9b4a:	mov    0x460(%rsp),%rsi
    9b52:	mov    0x3c0(%rsp),%rdi
    9b5a:	call   9b5f <botlish_fn_19+0x87d7>
			9b5b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    9b5f:	jmp    83d3 <botlish_fn_19+0x704b>
    9b64:	mov    $0x1,%edx
    9b69:	mov    %r14,%rsi
    9b6c:	mov    0x3c0(%rsp),%rdi
    9b74:	call   9b79 <botlish_fn_19+0x87f1>
			9b75: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    9b79:	jmp    8def <botlish_fn_19+0x7a67>
    9b7e:	mov    $0x1,%edx
    9b83:	mov    0x470(%rsp),%rsi
    9b8b:	mov    0x3c0(%rsp),%rdi
    9b93:	call   9b98 <botlish_fn_19+0x8810>
			9b94: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    9b98:	jmp    95e1 <botlish_fn_19+0x8259>
    9b9d:	mov    $0x1,%edx
    9ba2:	mov    0x3f8(%rsp),%rcx
    9baa:	mov    0x478(%rsp),%rsi
    9bb2:	mov    0x3c0(%rsp),%rdi
    9bba:	call   9bbf <botlish_fn_19+0x8837>
			9bbb: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    9bbf:	jmp    9aa5 <botlish_fn_19+0x871d>
    9bc4:	add    %al,(%rax)
    9bc6:	add    %al,(%rax)
    9bc8:	(bad)
    9bc9:	add    %al,(%rax)
    9bcb:	add    %al,(%rax)
    9bcd:	add    %al,(%rax)
	...

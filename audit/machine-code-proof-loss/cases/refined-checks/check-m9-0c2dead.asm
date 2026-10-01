; extracted from: git show 0c2dead:audit/native-scalar-asm/bench/refined-checks.asm
; compiler revision (that regeneration's README.md): a3c0550bd5f50c996ab94268635edcab78d317af

0000000000001494 <botlish_fn_16: check<int, int, str, str>>:
    1494:	push   rbp
    1495:	mov    rbp,rsp
    1498:	sub    rsp,0x50
    149c:	mov    QWORD PTR [rsp+0x20],rbx
    14a1:	mov    QWORD PTR [rsp+0x28],r12
    14a6:	mov    QWORD PTR [rsp+0x30],r13
    14ab:	mov    QWORD PTR [rsp+0x38],r14
    14b0:	mov    QWORD PTR [rsp+0x40],r15
    14b5:	mov    QWORD PTR [rsp+0x18],0x0
    14be:	mov    QWORD PTR [rsp],rdx
    14c2:	mov    QWORD PTR [rsp+0x8],rcx
    14c7:	mov    QWORD PTR [rsp+0x10],r8
    14cc:	mov    r14,r8
    14cf:	sar    rsi,1
    14d2:	mov    r13,rsi
    14d5:	mov    r15,rdx
    14d8:	test   r13,r13
    14db:	jle    15da <botlish_fn_16+0x146>
    14e1:	mov    rbx,rdi
    14e4:	mov    rax,QWORD PTR [rbx+0x10]
    14e8:	mov    rax,QWORD PTR [rax+0xb8]
    14ef:	mov    r12,rcx
    14f2:	mov    rsi,r12
    14f5:	call   14fa <botlish_fn_16+0x66>
			14f6: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    14fa:	test   rax,rax
    14fd:	je     1542 <botlish_fn_16+0xae>
    1503:	cmp    rax,0x6
    1507:	je     1523 <botlish_fn_16+0x8f>
    150d:	mov    edx,0x1
    1512:	mov    QWORD PTR [rsp+0x18],0x1
    151b:	mov    rsi,r15
    151e:	jmp    1588 <botlish_fn_16+0xf4>
    1523:	mov    rax,QWORD PTR [rbx+0x10]
    1527:	mov    rax,QWORD PTR [rax+0xc0]
    152e:	mov    rsi,r12
    1531:	mov    rdi,rbx
    1534:	call   1539 <botlish_fn_16+0xa5>
			1535: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    1539:	test   rax,rax
    153c:	jne    1567 <botlish_fn_16+0xd3>
    1542:	xor    rax,rax
    1545:	mov    rbx,QWORD PTR [rsp+0x20]
    154a:	mov    r12,QWORD PTR [rsp+0x28]
    154f:	mov    r13,QWORD PTR [rsp+0x30]
    1554:	mov    r14,QWORD PTR [rsp+0x38]
    1559:	mov    r15,QWORD PTR [rsp+0x40]
    155e:	add    rsp,0x50
    1562:	mov    rsp,rbp
    1565:	pop    rbp
    1566:	ret
    1567:	cmp    rax,0x6
    156b:	je     157b <botlish_fn_16+0xe7>
    1571:	mov    edx,0x1
    1576:	jmp    1580 <botlish_fn_16+0xec>
    157b:	mov    edx,0x3
    1580:	mov    QWORD PTR [rsp+0x18],rdx
    1585:	mov    rsi,r15
    1588:	mov    rax,rsi
    158b:	and    rax,rdx
    158e:	test   rax,0x1
    1594:	je     15af <botlish_fn_16+0x11b>
    159a:	lea    rcx,[rdx-0x1]
    159e:	mov    rax,rsi
    15a1:	add    rax,rcx
    15a4:	seto   cl
    15a7:	test   cl,cl
    15a9:	je     15b7 <botlish_fn_16+0x123>
    15af:	mov    rdi,rbx
    15b2:	call   15b7 <botlish_fn_16+0x123>
			15b3: R_X86_64_PLT32	rt_int_add-0x4
    15b7:	mov    QWORD PTR [rsp],rax
    15bb:	mov    QWORD PTR [rsp+0x8],r12
    15c0:	mov    r8,r14
    15c3:	mov    QWORD PTR [rsp+0x10],r8
    15c8:	sub    r13,0x1
    15cc:	mov    rcx,r12
    15cf:	mov    rdi,rbx
    15d2:	mov    r15,rax
    15d5:	jmp    14d8 <botlish_fn_16+0x44>
    15da:	mov    rax,r15
    15dd:	mov    rbx,QWORD PTR [rsp+0x20]
    15e2:	mov    r12,QWORD PTR [rsp+0x28]
    15e7:	mov    r13,QWORD PTR [rsp+0x30]
    15ec:	mov    r14,QWORD PTR [rsp+0x38]
    15f1:	mov    r15,QWORD PTR [rsp+0x40]
    15f6:	add    rsp,0x50
    15fa:	mov    rsp,rbp
    15fd:	pop    rbp
    15fe:	ret

00000000000015ff <botlish_entry_16: check<int, int, str, str>>:
    15ff:	push   rbp
    1600:	mov    rbp,rsp
    1603:	mov    rsi,QWORD PTR [rdx]
    1606:	mov    r9,QWORD PTR [rdx+0x8]
    160a:	mov    rcx,QWORD PTR [rdx+0x10]
    160e:	mov    r8,QWORD PTR [rdx+0x18]
    1612:	mov    rdx,r9
    1615:	call   161a <botlish_entry_16+0x1b>
			1616: R_X86_64_PLT32	botlish_fn_16-0x4 ; check<int, int, str, str>
    161a:	mov    rsp,rbp
    161d:	pop    rbp
    161e:	ret
	...


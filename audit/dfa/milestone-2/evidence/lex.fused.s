<botlish_fn_13>:
     c80:	push   %rbp
     c81:	mov    %rsp,%rbp
     c84:	sub    $0x370,%rsp
     c8b:	mov    %rbx,0x340(%rsp)
     c93:	mov    %r12,0x348(%rsp)
     c9b:	mov    %r13,0x350(%rsp)
     ca3:	mov    %r14,0x358(%rsp)
     cab:	mov    %r15,0x360(%rsp)
     cb3:	mov    %rdi,0x2a8(%rsp)
     cbb:	movq   $0x0,0x8(%rsp)
     cc4:	movq   $0x0,0x10(%rsp)
     ccd:	movq   $0x0,0x18(%rsp)
     cd6:	movq   $0x0,0x20(%rsp)
     cdf:	movq   $0x0,0x58(%rsp)
     ce8:	movq   $0x0,0x60(%rsp)
     cf1:	movq   $0x0,0x68(%rsp)
     cfa:	movq   $0x0,0x70(%rsp)
     d03:	movq   $0x0,0x78(%rsp)
     d0c:	movq   $0x0,0x80(%rsp)
     d18:	mov    %rdx,(%rsp)
     d1c:	mov    %rdx,0x2b8(%rsp)
     d24:	movq   $0xa,0x38(%rsp)
     d2d:	movq   $0xa,0x40(%rsp)
     d36:	movq   $0xa,0x48(%rsp)
     d3f:	movq   $0xa,0x50(%rsp)
     d48:	movq   $0xa,0x28(%rsp)
     d51:	movq   $0xa,0x30(%rsp)
     d5a:	mov    %rsi,0x38(%rsp)
     d5f:	mov    %rsi,0x2b0(%rsp)
     d67:	mov    0x2b0(%rsp),%rsi
     d6f:	mov    0x2a8(%rsp),%rdi
     d77:	call   d7c <botlish_fn_13+0xfc>
			d78: R_X86_64_PLT32	rt_list_len-0x4
     d7c:	mov    %rax,0x40(%rsp)
     d81:	mov    %rax,%r12
     d84:	mov    $0x1,%esi
     d89:	mov    %rsi,0x2e0(%rsp)
     d91:	movq   $0x1,0x48(%rsp)
     d9a:	xor    %r15,%r15
     d9d:	mov    $0xa,%eax
     da2:	mov    %rax,0x2d8(%rsp)
     daa:	mov    %r15,%r13
     dad:	mov    %r12,%r14
     db0:	mov    %rsi,%rax
     db3:	and    %r14,%rax
     db6:	mov    %rsi,0x2e0(%rsp)
     dbe:	test   $0x1,%rax
     dc4:	jne    dfb <botlish_fn_13+0x17b>
     dca:	mov    %r14,%rdx
     dcd:	mov    0x2e0(%rsp),%rsi
     dd5:	mov    0x2a8(%rsp),%rdi
     ddd:	call   de2 <botlish_fn_13+0x162>
			dde: R_X86_64_PLT32	rt_int_cmp-0x4
     de2:	mov    $0x2,%r8d
     de8:	test   %rax,%rax
     deb:	cmovl  0x3a45(%rip),%r8        # 4838 <botlish_fn_13+0x3bb8>
     df3:	mov    %r14,%r12
     df6:	jmp    e17 <botlish_fn_13+0x197>
     dfb:	mov    $0x2,%r8d
     e01:	mov    0x2e0(%rsp),%rsi
     e09:	cmp    %r14,%rsi
     e0c:	mov    %r14,%r12
     e0f:	cmovl  0x3a21(%rip),%r8        # 4838 <botlish_fn_13+0x3bb8>
     e17:	cmp    $0x6,%r8
     e1b:	je     e3e <botlish_fn_13+0x1be>
     e21:	mov    $0xffffffffffffffff,%rsi
     e28:	movq   $0xffffffffffffffff,0x28(%rsp)
     e31:	mov    %rsi,0x2d0(%rsp)
     e39:	jmp    104e <botlish_fn_13+0x3ce>
     e3e:	mov    0x2e0(%rsp),%rsi
     e46:	test   $0x1,%rsi
     e4d:	je     e76 <botlish_fn_13+0x1f6>
     e53:	mov    0x2b0(%rsp),%r14
     e5b:	mov    0x8(%r14),%rcx
     e5f:	mov    0x2e0(%rsp),%rsi
     e67:	mov    %rsi,%rax
     e6a:	sar    $1,%rax
     e6d:	cmp    %rcx,%rax
     e70:	jb     f16 <botlish_fn_13+0x296>
     e76:	mov    0x2e0(%rsp),%rdx
     e7e:	mov    0x2b0(%rsp),%rsi
     e86:	mov    0x2a8(%rsp),%rdi
     e8e:	call   e93 <botlish_fn_13+0x213>
			e8f: R_X86_64_PLT32	rt_list_get-0x4
     e93:	test   %rax,%rax
     e96:	jne    f26 <botlish_fn_13+0x2a6>
     e9c:	mov    0x2a8(%rsp),%rdi
     ea4:	call   ea9 <botlish_fn_13+0x229>
			ea5: R_X86_64_PLT32	rt_co_failed-0x4
     ea9:	mov    %rax,0x30(%rsp)
     eae:	mov    %rax,%rsi
     eb1:	mov    0x2a8(%rsp),%rdi
     eb9:	call   ebe <botlish_fn_13+0x23e>
			eba: R_X86_64_PLT32	rt_co_resume0-0x4
     ebe:	test   %rax,%rax
     ec1:	jne    ed4 <botlish_fn_13+0x254>
     ec7:	mov    0x2a8(%rsp),%rdi
     ecf:	jmp    ef8 <botlish_fn_13+0x278>
     ed4:	mov    0x2a8(%rsp),%rdi
     edc:	mov    0x10(%rdi),%rax
     ee0:	mov    0x50(%rax),%rsi
     ee4:	mov    0x128(%rax),%rdx
     eeb:	call   ef0 <botlish_fn_13+0x270>
			eec: R_X86_64_PLT32	rt_raise-0x4
     ef0:	mov    0x2a8(%rsp),%rdi
     ef8:	mov    0x2a8(%rsp),%rdi
     f00:	call   f05 <botlish_fn_13+0x285>
			f01: R_X86_64_PLT32	rt_declared_error-0x4
     f05:	cmp    $0x40000001,%rax
     f0b:	jne    44db <botlish_fn_13+0x385b>
     f11:	jmp    44db <botlish_fn_13+0x385b>
     f16:	mov    0x2b0(%rsp),%r14
     f1e:	mov    0x10(%r14),%rcx
     f22:	mov    (%rcx,%rax,8),%rax
     f26:	mov    %rax,0x50(%rsp)
     f2b:	mov    0x8(%rax),%r13
     f2f:	mov    %rax,0x2d8(%rsp)
     f37:	shl    $1,%r13
     f3a:	or     $0x1,%r13
     f3e:	sar    $1,%r13
     f41:	test   %r13,%r13
     f44:	jg     fe1 <botlish_fn_13+0x361>
     f4a:	mov    $0x3,%edx
     f4f:	movq   $0x3,0x20(%rsp)
     f58:	mov    0x2e0(%rsp),%rsi
     f60:	test   $0x1,%rsi
     f67:	jne    f7a <botlish_fn_13+0x2fa>
     f6d:	mov    0x2e0(%rsp),%rsi
     f75:	jmp    fb1 <botlish_fn_13+0x331>
     f7a:	mov    0x2e0(%rsp),%rsi
     f82:	mov    %rsi,%rcx
     f85:	add    $0x2,%rcx
     f89:	seto   %al
     f8c:	test   %al,%al
     f8e:	je     fa1 <botlish_fn_13+0x321>
     f94:	mov    0x2e0(%rsp),%rsi
     f9c:	jmp    fb1 <botlish_fn_13+0x331>
     fa1:	mov    %rcx,%rsi
     fa4:	mov    %rcx,0x2e0(%rsp)
     fac:	jmp    fc9 <botlish_fn_13+0x349>
     fb1:	mov    0x2a8(%rsp),%rdi
     fb9:	call   fbe <botlish_fn_13+0x33e>
			fba: R_X86_64_PLT32	rt_int_add-0x4
     fbe:	mov    %rax,%rsi
     fc1:	mov    %rax,0x2e0(%rsp)
     fc9:	mov    %rsi,0x48(%rsp)
     fce:	xor    %r15,%r15
     fd1:	mov    0x2e0(%rsp),%rsi
     fd9:	mov    %r12,%r14
     fdc:	jmp    db0 <botlish_fn_13+0x130>
     fe1:	mov    0x2d8(%rsp),%rax
     fe9:	movzbq 0x18(%rax),%rsi
     fee:	test   %rsi,%rsi
     ff1:	jne    1019 <botlish_fn_13+0x399>
     ff7:	mov    $0x1,%edx
     ffc:	mov    0x2d8(%rsp),%rsi
    1004:	mov    0x2a8(%rsp),%rdi
    100c:	call   1011 <botlish_fn_13+0x391>
			100d: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    1011:	mov    %rax,%rsi
    1014:	jmp    102e <botlish_fn_13+0x3ae>
    1019:	mov    0x2d8(%rsp),%rax
    1021:	movzbq 0x19(%rax),%rsi
    1026:	shl    $0x3,%rsi
    102a:	or     $0x4,%rsi
    102e:	shr    $0x3,%rsi
    1032:	mov    $0x1,%ecx
    1037:	mov    %rcx,0x2d0(%rsp)
    103f:	shl    $1,%rsi
    1042:	or     $0x1,%rsi
    1046:	mov    %rsi,0x28(%rsp)
    104b:	xor    %r15,%r15
    104e:	mov    %rsi,0x8(%rsp)
    1053:	mov    %rsi,0x300(%rsp)
    105b:	mov    $0x9,%esi
    1060:	movq   $0x9,0x10(%rsp)
    1069:	mov    $0x1,%edx
    106e:	movq   $0x1,0x18(%rsp)
    1077:	mov    0x2a8(%rsp),%rdi
    107f:	call   1084 <botlish_fn_13+0x404>
			1080: R_X86_64_PLT32	rt_mutarray_create-0x4
    1084:	mov    %rax,%rcx
    1087:	test   %rcx,%rcx
    108a:	je     44db <botlish_fn_13+0x385b>
    1090:	mov    %rcx,0x10(%rsp)
    1095:	mov    0x18(%rcx),%rax
    1099:	mov    %rcx,0x338(%rsp)
    10a1:	test   %rax,%rax
    10a4:	je     46ca <botlish_fn_13+0x3a4a>
    10aa:	mov    0x338(%rsp),%rcx
    10b2:	mov    0x10(%rcx),%rax
    10b6:	mov    0x300(%rsp),%rsi
    10be:	mov    %rsi,0x8(%rax)
    10c2:	mov    $0x8,%esi
    10c7:	mov    %rsi,0x330(%rsp)
    10cf:	mov    $0xffffffffffffffff,%rdx
    10d6:	mov    %rdx,0x328(%rsp)
    10de:	mov    $0x3,%r8d
    10e4:	mov    %r8,0x320(%rsp)
    10ec:	mov    0x338(%rsp),%rcx
    10f4:	mov    0x338(%rsp),%rcx
    10fc:	mov    0x10(%rcx),%rax
    1100:	mov    (%rax),%rsi
    1103:	mov    %rsi,0x8(%rsp)
    1108:	mov    %rsi,0x318(%rsp)
    1110:	mov    0x338(%rsp),%rcx
    1118:	mov    0x10(%rcx),%rax
    111c:	mov    0x8(%rax),%rsi
    1120:	test   $0x1,%rsi
    1127:	mov    %rsi,0x2c0(%rsp)
    112f:	jne    1167 <botlish_fn_13+0x4e7>
    1135:	mov    0x328(%rsp),%rdx
    113d:	mov    0x2c0(%rsp),%rsi
    1145:	mov    0x2a8(%rsp),%rdi
    114d:	call   1152 <botlish_fn_13+0x4d2>
			114e: R_X86_64_PLT32	rt_int_cmp-0x4
    1152:	mov    $0x2,%ecx
    1157:	test   %rax,%rax
    115a:	cmove  0x36d6(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1162:	jmp    1180 <botlish_fn_13+0x500>
    1167:	mov    $0x2,%ecx
    116c:	mov    0x2c0(%rsp),%rsi
    1174:	cmp    $0xffffffffffffffff,%rsi
    1178:	cmove  0x36b8(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1180:	cmp    $0x6,%rcx
    1184:	je     4649 <botlish_fn_13+0x39c9>
    118a:	mov    0x2c0(%rsp),%rsi
    1192:	mov    0x2a8(%rsp),%rdi
    119a:	call   119f <botlish_fn_13+0x51f>
			119b: R_X86_64_PLT32	botlish_fn_11-0x4
    119f:	cmp    $0x6,%rax
    11a3:	je     41e9 <botlish_fn_13+0x3569>
    11a9:	movq   $0xa,0x68(%rsp)
    11b2:	movq   $0xa,0x70(%rsp)
    11bb:	movq   $0xa,0x78(%rsp)
    11c4:	movq   $0xa,0x80(%rsp)
    11d0:	movq   $0xa,0x58(%rsp)
    11d9:	movq   $0xa,0x60(%rsp)
    11e2:	mov    0x2a8(%rsp),%rdi
    11ea:	mov    0x10(%rdi),%rax
    11ee:	mov    0x148(%rax),%rbx
    11f5:	mov    0x2c0(%rsp),%rsi
    11fd:	test   $0x1,%rsi
    1204:	jne    123c <botlish_fn_13+0x5bc>
    120a:	mov    0x328(%rsp),%rdx
    1212:	mov    0x2c0(%rsp),%rsi
    121a:	mov    0x2a8(%rsp),%rdi
    1222:	call   1227 <botlish_fn_13+0x5a7>
			1223: R_X86_64_PLT32	rt_int_cmp-0x4
    1227:	mov    $0x2,%ecx
    122c:	test   %rax,%rax
    122f:	cmovl  0x3601(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1237:	jmp    1255 <botlish_fn_13+0x5d5>
    123c:	mov    $0x2,%ecx
    1241:	mov    0x2c0(%rsp),%rsi
    1249:	cmp    $0xffffffffffffffff,%rsi
    124d:	cmovl  0x35e3(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1255:	cmp    $0x6,%rcx
    1259:	je     12df <botlish_fn_13+0x65f>
    125f:	mov    0x2c0(%rsp),%rsi
    1267:	test   $0x1,%rsi
    126e:	jne    12a3 <botlish_fn_13+0x623>
    1274:	mov    $0x1ff,%edx
    1279:	mov    0x2c0(%rsp),%rsi
    1281:	mov    0x2a8(%rsp),%rdi
    1289:	call   128e <botlish_fn_13+0x60e>
			128a: R_X86_64_PLT32	rt_int_cmp-0x4
    128e:	mov    $0x2,%ecx
    1293:	test   %rax,%rax
    1296:	cmovg  0x359a(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    129e:	jmp    12bf <botlish_fn_13+0x63f>
    12a3:	mov    $0x2,%ecx
    12a8:	mov    0x2c0(%rsp),%rsi
    12b0:	cmp    $0x1ff,%rsi
    12b7:	cmovg  0x3579(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    12bf:	cmp    $0x6,%rcx
    12c3:	je     12df <botlish_fn_13+0x65f>
    12c9:	mov    0x2c0(%rsp),%rsi
    12d1:	sar    $1,%rsi
    12d4:	movzbq 0x11(%rbx,%rsi,1),%rcx
    12da:	jmp    12e7 <botlish_fn_13+0x667>
    12df:	movzbq 0x111(%rbx),%rcx
    12e7:	mov    %rcx,%rsi
    12ea:	shl    $1,%rsi
    12ed:	or     $0x1,%rsi
    12f1:	mov    $0x2,%r11d
    12f7:	cmp    $0x3,%rsi
    12fb:	cmove  0x3535(%rip),%r11        # 4838 <botlish_fn_13+0x3bb8>
    1303:	cmp    $0x6,%r11
    1307:	je     22d0 <botlish_fn_13+0x1650>
    130d:	mov    %rcx,%r11
    1310:	shl    $1,%r11
    1313:	or     $0x1,%r11
    1317:	mov    $0x2,%edx
    131c:	cmp    $0x5,%r11
    1320:	cmove  0x3510(%rip),%rdx        # 4838 <botlish_fn_13+0x3bb8>
    1328:	cmp    $0x6,%rdx
    132c:	je     1aa8 <botlish_fn_13+0xe28>
    1332:	mov    %rcx,%rsi
    1335:	shl    $1,%rsi
    1338:	or     $0x1,%rsi
    133c:	mov    $0x2,%edx
    1341:	cmp    $0x7,%rsi
    1345:	cmove  0x34eb(%rip),%rdx        # 4838 <botlish_fn_13+0x3bb8>
    134d:	cmp    $0x6,%rdx
    1351:	je     179f <botlish_fn_13+0xb1f>
    1357:	shl    $1,%rcx
    135a:	or     $0x1,%rcx
    135e:	mov    $0x2,%edx
    1363:	cmp    $0x9,%rcx
    1367:	cmove  0x34c9(%rip),%rdx        # 4838 <botlish_fn_13+0x3bb8>
    136f:	cmp    $0x6,%rdx
    1373:	je     1493 <botlish_fn_13+0x813>
    1379:	mov    0x2c0(%rsp),%rsi
    1381:	test   $0x1,%rsi
    1388:	jne    13c0 <botlish_fn_13+0x740>
    138e:	mov    0x328(%rsp),%rdx
    1396:	mov    0x2c0(%rsp),%rsi
    139e:	mov    0x2a8(%rsp),%rdi
    13a6:	call   13ab <botlish_fn_13+0x72b>
			13a7: R_X86_64_PLT32	rt_int_cmp-0x4
    13ab:	mov    $0x2,%ecx
    13b0:	test   %rax,%rax
    13b3:	cmove  0x347d(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    13bb:	jmp    13d9 <botlish_fn_13+0x759>
    13c0:	mov    $0x2,%ecx
    13c5:	mov    0x2c0(%rsp),%rsi
    13cd:	cmp    $0xffffffffffffffff,%rsi
    13d1:	cmove  0x345f(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    13d9:	cmp    $0x6,%rcx
    13dd:	je     1445 <botlish_fn_13+0x7c5>
    13e3:	mov    0x2a8(%rsp),%rdi
    13eb:	mov    0x10(%rdi),%rdx
    13ef:	mov    0x1a8(%rdx),%rax
    13f6:	mov    0x8(%rdx),%rcx
    13fa:	mov    0x178(%rdx),%rdx
    1401:	lea    0x1c8(%rsp),%r9
    1409:	mov    %rax,0x1c8(%rsp)
    1411:	mov    %rcx,0x1d0(%rsp)
    1419:	mov    0x2c0(%rsp),%rsi
    1421:	mov    %rsi,0x1d8(%rsp)
    1429:	mov    $0x1,%esi
    142e:	mov    $0x6,%ecx
    1433:	mov    0x320(%rsp),%r8
    143b:	call   1440 <botlish_fn_13+0x7c0>
			143c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1440:	jmp    203f <botlish_fn_13+0x13bf>
    1445:	mov    0x2a8(%rsp),%rdi
    144d:	mov    0x10(%rdi),%rdx
    1451:	mov    0x1a8(%rdx),%rax
    1458:	mov    0x8(%rdx),%rcx
    145c:	mov    0x170(%rdx),%rdx
    1463:	lea    0x1b8(%rsp),%r9
    146b:	mov    %rax,0x1b8(%rsp)
    1473:	mov    %rcx,0x1c0(%rsp)
    147b:	mov    $0x2,%r8d
    1481:	mov    $0x5,%ecx
    1486:	mov    %r8,%rsi
    1489:	call   148e <botlish_fn_13+0x80e>
			148a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    148e:	jmp    203f <botlish_fn_13+0x13bf>
    1493:	mov    0x2a8(%rsp),%rdi
    149b:	mov    0x10(%rdi),%rax
    149f:	mov    0x198(%rax),%rbx
    14a6:	mov    0x2c0(%rsp),%rsi
    14ae:	test   $0x1,%rsi
    14b5:	jne    14ed <botlish_fn_13+0x86d>
    14bb:	mov    0x328(%rsp),%rdx
    14c3:	mov    0x2c0(%rsp),%rsi
    14cb:	mov    0x2a8(%rsp),%rdi
    14d3:	call   14d8 <botlish_fn_13+0x858>
			14d4: R_X86_64_PLT32	rt_int_cmp-0x4
    14d8:	mov    $0x2,%ecx
    14dd:	test   %rax,%rax
    14e0:	cmovl  0x3350(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    14e8:	jmp    1506 <botlish_fn_13+0x886>
    14ed:	mov    $0x2,%ecx
    14f2:	mov    0x2c0(%rsp),%rsi
    14fa:	cmp    $0xffffffffffffffff,%rsi
    14fe:	cmovl  0x3332(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1506:	cmp    $0x6,%rcx
    150a:	je     1593 <botlish_fn_13+0x913>
    1510:	mov    0x2c0(%rsp),%rsi
    1518:	test   $0x1,%rsi
    151f:	jne    1554 <botlish_fn_13+0x8d4>
    1525:	mov    $0x1ff,%edx
    152a:	mov    0x2c0(%rsp),%rsi
    1532:	mov    0x2a8(%rsp),%rdi
    153a:	call   153f <botlish_fn_13+0x8bf>
			153b: R_X86_64_PLT32	rt_int_cmp-0x4
    153f:	mov    $0x2,%ecx
    1544:	test   %rax,%rax
    1547:	cmovg  0x32e9(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    154f:	jmp    1570 <botlish_fn_13+0x8f0>
    1554:	mov    $0x2,%ecx
    1559:	mov    0x2c0(%rsp),%rsi
    1561:	cmp    $0x1ff,%rsi
    1568:	cmovg  0x32c8(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1570:	cmp    $0x6,%rcx
    1574:	je     1593 <botlish_fn_13+0x913>
    157a:	mov    0x2c0(%rsp),%rsi
    1582:	mov    %rsi,%rax
    1585:	sar    $1,%rax
    1588:	movzbq 0x11(%rbx,%rax,1),%rsi
    158e:	jmp    159b <botlish_fn_13+0x91b>
    1593:	movzbq 0xc1c(%rbx),%rsi
    159b:	mov    %rsi,%rdx
    159e:	shl    $1,%rdx
    15a1:	or     $0x1,%rdx
    15a5:	mov    $0x2,%ecx
    15aa:	cmp    $0x19,%rdx
    15ae:	cmovl  0x3282(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    15b6:	cmp    $0x6,%rcx
    15ba:	je     1752 <botlish_fn_13+0xad2>
    15c0:	mov    %rsi,%rdi
    15c3:	shl    $1,%rdi
    15c6:	mov    %rsi,0x2f8(%rsp)
    15ce:	or     $0x1,%rdi
    15d2:	mov    $0x2,%ecx
    15d7:	cmp    $0x19,%rdi
    15db:	cmove  0x3255(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    15e3:	cmp    $0x6,%rcx
    15e7:	je     1745 <botlish_fn_13+0xac5>
    15ed:	mov    0x2c0(%rsp),%rsi
    15f5:	test   $0x1,%rsi
    15fc:	jne    1635 <botlish_fn_13+0x9b5>
    1602:	mov    0x328(%rsp),%rdx
    160a:	mov    0x2c0(%rsp),%rsi
    1612:	mov    0x2a8(%rsp),%rdi
    161a:	call   161f <botlish_fn_13+0x99f>
			161b: R_X86_64_PLT32	rt_int_cmp-0x4
    161f:	mov    $0x2,%r9d
    1625:	test   %rax,%rax
    1628:	cmove  0x3208(%rip),%r9        # 4838 <botlish_fn_13+0x3bb8>
    1630:	jmp    164f <botlish_fn_13+0x9cf>
    1635:	mov    $0x2,%r9d
    163b:	mov    0x2c0(%rsp),%rsi
    1643:	cmp    $0xffffffffffffffff,%rsi
    1647:	cmove  0x31e9(%rip),%r9        # 4838 <botlish_fn_13+0x3bb8>
    164f:	cmp    $0x6,%r9
    1653:	je     16db <botlish_fn_13+0xa5b>
    1659:	mov    0x2a8(%rsp),%rdi
    1661:	mov    0x10(%rdi),%rax
    1665:	mov    0x1a0(%rax),%rbx
    166c:	mov    $0x1,%r12d
    1672:	mov    0x2f8(%rsp),%rsi
    167a:	shl    $1,%rsi
    167d:	or     $0x1,%rsi
    1681:	call   1686 <botlish_fn_13+0xa06>
			1682: R_X86_64_PLT32	botlish_fn_3-0x4
    1686:	mov    0x2a8(%rsp),%rdi
    168e:	mov    0x10(%rdi),%rcx
    1692:	mov    0x178(%rcx),%rdx
    1699:	lea    0x1a0(%rsp),%r9
    16a1:	mov    %rbx,0x1a0(%rsp)
    16a9:	mov    %rax,0x1a8(%rsp)
    16b1:	mov    0x2c0(%rsp),%rsi
    16b9:	mov    %rsi,0x1b0(%rsp)
    16c1:	mov    $0x6,%ecx
    16c6:	mov    %r12,%rsi
    16c9:	mov    0x320(%rsp),%r8
    16d1:	call   16d6 <botlish_fn_13+0xa56>
			16d2: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    16d6:	jmp    203f <botlish_fn_13+0x13bf>
    16db:	mov    0x2f8(%rsp),%rsi
    16e3:	mov    0x2a8(%rsp),%rdi
    16eb:	mov    0x10(%rdi),%rax
    16ef:	mov    0x1a0(%rax),%rbx
    16f6:	shl    $1,%rsi
    16f9:	or     $0x1,%rsi
    16fd:	call   1702 <botlish_fn_13+0xa82>
			16fe: R_X86_64_PLT32	botlish_fn_3-0x4
    1702:	mov    0x2a8(%rsp),%rdi
    170a:	mov    0x10(%rdi),%rcx
    170e:	mov    0x170(%rcx),%rdx
    1715:	lea    0x190(%rsp),%r9
    171d:	mov    %rbx,0x190(%rsp)
    1725:	mov    %rax,0x198(%rsp)
    172d:	mov    $0x2,%r8d
    1733:	mov    $0x5,%ecx
    1738:	mov    %r8,%rsi
    173b:	call   1740 <botlish_fn_13+0xac0>
			173c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1740:	jmp    203f <botlish_fn_13+0x13bf>
    1745:	mov    0x2c0(%rsp),%rsi
    174d:	jmp    22df <botlish_fn_13+0x165f>
    1752:	shl    $1,%rsi
    1755:	or     $0x1,%rsi
    1759:	mov    %rsi,0x80(%rsp)
    1761:	mov    %rsi,0x2f8(%rsp)
    1769:	mov    $0x1,%ebx
    176e:	movq   $0x1,0x58(%rsp)
    1777:	mov    $0x4,%r14d
    177d:	mov    $0xa,%esi
    1782:	mov    %rsi,0x2c8(%rsp)
    178a:	mov    %rsi,0x2e8(%rsp)
    1792:	mov    %rsi,0x2f0(%rsp)
    179a:	jmp    2391 <botlish_fn_13+0x1711>
    179f:	mov    0x2a8(%rsp),%rdi
    17a7:	mov    0x10(%rdi),%rax
    17ab:	mov    0x188(%rax),%rbx
    17b2:	mov    0x2c0(%rsp),%rsi
    17ba:	test   $0x1,%rsi
    17c1:	jne    17f9 <botlish_fn_13+0xb79>
    17c7:	mov    0x328(%rsp),%rdx
    17cf:	mov    0x2c0(%rsp),%rsi
    17d7:	mov    0x2a8(%rsp),%rdi
    17df:	call   17e4 <botlish_fn_13+0xb64>
			17e0: R_X86_64_PLT32	rt_int_cmp-0x4
    17e4:	mov    $0x2,%ecx
    17e9:	test   %rax,%rax
    17ec:	cmovl  0x3044(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    17f4:	jmp    1812 <botlish_fn_13+0xb92>
    17f9:	mov    $0x2,%ecx
    17fe:	mov    0x2c0(%rsp),%rsi
    1806:	cmp    $0xffffffffffffffff,%rsi
    180a:	cmovl  0x3026(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1812:	cmp    $0x6,%rcx
    1816:	je     189f <botlish_fn_13+0xc1f>
    181c:	mov    0x2c0(%rsp),%rsi
    1824:	test   $0x1,%rsi
    182b:	jne    1860 <botlish_fn_13+0xbe0>
    1831:	mov    $0x1ff,%edx
    1836:	mov    0x2c0(%rsp),%rsi
    183e:	mov    0x2a8(%rsp),%rdi
    1846:	call   184b <botlish_fn_13+0xbcb>
			1847: R_X86_64_PLT32	rt_int_cmp-0x4
    184b:	mov    $0x2,%ecx
    1850:	test   %rax,%rax
    1853:	cmovg  0x2fdd(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    185b:	jmp    187c <botlish_fn_13+0xbfc>
    1860:	mov    $0x2,%ecx
    1865:	mov    0x2c0(%rsp),%rsi
    186d:	cmp    $0x1ff,%rsi
    1874:	cmovg  0x2fbc(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    187c:	cmp    $0x6,%rcx
    1880:	je     189f <botlish_fn_13+0xc1f>
    1886:	mov    0x2c0(%rsp),%rsi
    188e:	mov    %rsi,%rax
    1891:	sar    $1,%rax
    1894:	movzbq 0x11(%rbx,%rax,1),%rsi
    189a:	jmp    18a7 <botlish_fn_13+0xc27>
    189f:	movzbq 0x919(%rbx),%rsi
    18a7:	mov    %rsi,%rdx
    18aa:	shl    $1,%rdx
    18ad:	or     $0x1,%rdx
    18b1:	mov    $0x2,%ecx
    18b6:	cmp    $0x13,%rdx
    18ba:	cmovl  0x2f76(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    18c2:	cmp    $0x6,%rcx
    18c6:	je     1a5c <botlish_fn_13+0xddc>
    18cc:	mov    %rsi,%rdx
    18cf:	shl    $1,%rdx
    18d2:	mov    %rsi,0x2f0(%rsp)
    18da:	or     $0x1,%rdx
    18de:	mov    $0x2,%ecx
    18e3:	cmp    $0x13,%rdx
    18e7:	cmove  0x2f49(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    18ef:	cmp    $0x6,%rcx
    18f3:	je     1a4f <botlish_fn_13+0xdcf>
    18f9:	mov    0x2c0(%rsp),%rsi
    1901:	test   $0x1,%rsi
    1908:	jne    1940 <botlish_fn_13+0xcc0>
    190e:	mov    0x328(%rsp),%rdx
    1916:	mov    0x2c0(%rsp),%rsi
    191e:	mov    0x2a8(%rsp),%rdi
    1926:	call   192b <botlish_fn_13+0xcab>
			1927: R_X86_64_PLT32	rt_int_cmp-0x4
    192b:	mov    $0x2,%ecx
    1930:	test   %rax,%rax
    1933:	cmove  0x2efd(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    193b:	jmp    1959 <botlish_fn_13+0xcd9>
    1940:	mov    $0x2,%ecx
    1945:	mov    0x2c0(%rsp),%rsi
    194d:	cmp    $0xffffffffffffffff,%rsi
    1951:	cmove  0x2edf(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1959:	cmp    $0x6,%rcx
    195d:	je     19e5 <botlish_fn_13+0xd65>
    1963:	mov    0x2a8(%rsp),%rdi
    196b:	mov    0x10(%rdi),%r9
    196f:	mov    0x190(%r9),%r12
    1976:	mov    $0x1,%r13d
    197c:	mov    0x2f0(%rsp),%rsi
    1984:	shl    $1,%rsi
    1987:	or     $0x1,%rsi
    198b:	call   1990 <botlish_fn_13+0xd10>
			198c: R_X86_64_PLT32	botlish_fn_1-0x4
    1990:	mov    0x2a8(%rsp),%rdi
    1998:	mov    0x10(%rdi),%r9
    199c:	mov    0x178(%r9),%rdx
    19a3:	lea    0x178(%rsp),%r9
    19ab:	mov    %r12,0x178(%rsp)
    19b3:	mov    %rax,0x180(%rsp)
    19bb:	mov    0x2c0(%rsp),%rsi
    19c3:	mov    %rsi,0x188(%rsp)
    19cb:	mov    $0x6,%ecx
    19d0:	mov    %r13,%rsi
    19d3:	mov    0x320(%rsp),%r8
    19db:	call   19e0 <botlish_fn_13+0xd60>
			19dc: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    19e0:	jmp    203f <botlish_fn_13+0x13bf>
    19e5:	mov    0x2f0(%rsp),%rsi
    19ed:	mov    0x2a8(%rsp),%rdi
    19f5:	mov    0x10(%rdi),%rax
    19f9:	mov    0x190(%rax),%r13
    1a00:	shl    $1,%rsi
    1a03:	or     $0x1,%rsi
    1a07:	call   1a0c <botlish_fn_13+0xd8c>
			1a08: R_X86_64_PLT32	botlish_fn_1-0x4
    1a0c:	mov    0x2a8(%rsp),%rdi
    1a14:	mov    0x10(%rdi),%rcx
    1a18:	mov    0x170(%rcx),%rdx
    1a1f:	lea    0x168(%rsp),%r9
    1a27:	mov    %r13,0x168(%rsp)
    1a2f:	mov    %rax,0x170(%rsp)
    1a37:	mov    $0x2,%r8d
    1a3d:	mov    $0x5,%ecx
    1a42:	mov    %r8,%rsi
    1a45:	call   1a4a <botlish_fn_13+0xdca>
			1a46: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1a4a:	jmp    203f <botlish_fn_13+0x13bf>
    1a4f:	mov    0x2c0(%rsp),%rsi
    1a57:	jmp    22df <botlish_fn_13+0x165f>
    1a5c:	shl    $1,%rsi
    1a5f:	or     $0x1,%rsi
    1a63:	mov    %rsi,0x78(%rsp)
    1a68:	mov    %rsi,0x2f0(%rsp)
    1a70:	mov    $0x1,%ebx
    1a75:	movq   $0x1,0x58(%rsp)
    1a7e:	mov    $0xa,%esi
    1a83:	mov    0x320(%rsp),%r14
    1a8b:	mov    %rsi,0x2c8(%rsp)
    1a93:	mov    %rsi,0x2e8(%rsp)
    1a9b:	mov    %rsi,0x2f8(%rsp)
    1aa3:	jmp    2391 <botlish_fn_13+0x1711>
    1aa8:	mov    0x2c0(%rsp),%rsi
    1ab0:	test   $0x1,%rsi
    1ab7:	jne    1aec <botlish_fn_13+0xe6c>
    1abd:	mov    $0x45,%edx
    1ac2:	mov    0x2c0(%rsp),%rsi
    1aca:	mov    0x2a8(%rsp),%rdi
    1ad2:	call   1ad7 <botlish_fn_13+0xe57>
			1ad3: R_X86_64_PLT32	rt_int_cmp-0x4
    1ad7:	mov    $0x2,%ecx
    1adc:	test   %rax,%rax
    1adf:	cmovl  0x2d51(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1ae7:	jmp    1b05 <botlish_fn_13+0xe85>
    1aec:	mov    $0x2,%ecx
    1af1:	mov    0x2c0(%rsp),%rsi
    1af9:	cmp    $0x45,%rsi
    1afd:	cmovl  0x2d33(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1b05:	cmp    $0x6,%rcx
    1b09:	je     1ba2 <botlish_fn_13+0xf22>
    1b0f:	mov    0x2c0(%rsp),%rsi
    1b17:	test   $0x1,%rsi
    1b1e:	jne    1b53 <botlish_fn_13+0xed3>
    1b24:	mov    $0x45,%edx
    1b29:	mov    0x2c0(%rsp),%rsi
    1b31:	mov    0x2a8(%rsp),%rdi
    1b39:	call   1b3e <botlish_fn_13+0xebe>
			1b3a: R_X86_64_PLT32	rt_int_cmp-0x4
    1b3e:	mov    $0x2,%ecx
    1b43:	test   %rax,%rax
    1b46:	cmovg  0x2cea(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1b4e:	jmp    1b6c <botlish_fn_13+0xeec>
    1b53:	mov    $0x2,%ecx
    1b58:	mov    0x2c0(%rsp),%rsi
    1b60:	cmp    $0x45,%rsi
    1b64:	cmovg  0x2ccc(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1b6c:	cmp    $0x6,%rcx
    1b70:	je     1ba2 <botlish_fn_13+0xf22>
    1b76:	mov    0x2c0(%rsp),%rsi
    1b7e:	mov    %rsi,%rcx
    1b81:	sar    $1,%rcx
    1b84:	cmp    $0x22,%rcx
    1b88:	jl     1ba2 <botlish_fn_13+0xf22>
    1b8e:	cmp    $0x23,%rcx
    1b92:	jge    1ba2 <botlish_fn_13+0xf22>
    1b98:	mov    $0x1,%esi
    1b9d:	jmp    1ba7 <botlish_fn_13+0xf27>
    1ba2:	mov    $0x4,%esi
    1ba7:	mov    %rsi,%rdx
    1baa:	shl    $1,%rdx
    1bad:	or     $0x1,%rdx
    1bb1:	mov    $0x2,%ecx
    1bb6:	cmp    $0x5,%rdx
    1bba:	cmovl  0x2c76(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1bc2:	cmp    $0x6,%rcx
    1bc6:	je     227e <botlish_fn_13+0x15fe>
    1bcc:	mov    %rsi,%rdx
    1bcf:	shl    $1,%rdx
    1bd2:	or     $0x1,%rdx
    1bd6:	mov    $0x2,%ecx
    1bdb:	cmp    $0x5,%rdx
    1bdf:	cmove  0x2c51(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1be7:	cmp    $0x6,%rcx
    1beb:	je     226a <botlish_fn_13+0x15ea>
    1bf1:	mov    %rsi,%rdx
    1bf4:	shl    $1,%rdx
    1bf7:	mov    %rsi,0x2c8(%rsp)
    1bff:	or     $0x1,%rdx
    1c03:	mov    $0x2,%ecx
    1c08:	cmp    $0x7,%rdx
    1c0c:	cmove  0x2c24(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1c14:	cmp    $0x6,%rcx
    1c18:	je     1d74 <botlish_fn_13+0x10f4>
    1c1e:	mov    0x2c0(%rsp),%rsi
    1c26:	test   $0x1,%rsi
    1c2d:	jne    1c65 <botlish_fn_13+0xfe5>
    1c33:	mov    0x328(%rsp),%rdx
    1c3b:	mov    0x2c0(%rsp),%rsi
    1c43:	mov    0x2a8(%rsp),%rdi
    1c4b:	call   1c50 <botlish_fn_13+0xfd0>
			1c4c: R_X86_64_PLT32	rt_int_cmp-0x4
    1c50:	mov    $0x2,%ecx
    1c55:	test   %rax,%rax
    1c58:	cmove  0x2bd8(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1c60:	jmp    1c7e <botlish_fn_13+0xffe>
    1c65:	mov    $0x2,%ecx
    1c6a:	mov    0x2c0(%rsp),%rsi
    1c72:	cmp    $0xffffffffffffffff,%rsi
    1c76:	cmove  0x2bba(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1c7e:	cmp    $0x6,%rcx
    1c82:	je     1d0a <botlish_fn_13+0x108a>
    1c88:	mov    0x2a8(%rsp),%rdi
    1c90:	mov    0x10(%rdi),%rax
    1c94:	mov    0x180(%rax),%r14
    1c9b:	mov    $0x1,%r15d
    1ca1:	mov    0x2c8(%rsp),%rsi
    1ca9:	shl    $1,%rsi
    1cac:	or     $0x1,%rsi
    1cb0:	call   1cb5 <botlish_fn_13+0x1035>
			1cb1: R_X86_64_PLT32	botlish_fn_7-0x4
    1cb5:	mov    0x2a8(%rsp),%rdi
    1cbd:	mov    0x10(%rdi),%rcx
    1cc1:	mov    0x178(%rcx),%rdx
    1cc8:	lea    0x150(%rsp),%r9
    1cd0:	mov    %r14,0x150(%rsp)
    1cd8:	mov    %rax,0x158(%rsp)
    1ce0:	mov    0x2c0(%rsp),%rsi
    1ce8:	mov    %rsi,0x160(%rsp)
    1cf0:	mov    $0x6,%ecx
    1cf5:	mov    %r15,%rsi
    1cf8:	mov    0x320(%rsp),%r8
    1d00:	call   1d05 <botlish_fn_13+0x1085>
			1d01: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1d05:	jmp    203f <botlish_fn_13+0x13bf>
    1d0a:	mov    0x2c8(%rsp),%rsi
    1d12:	mov    0x2a8(%rsp),%rdi
    1d1a:	mov    0x10(%rdi),%rax
    1d1e:	mov    0x180(%rax),%rbx
    1d25:	shl    $1,%rsi
    1d28:	or     $0x1,%rsi
    1d2c:	call   1d31 <botlish_fn_13+0x10b1>
			1d2d: R_X86_64_PLT32	botlish_fn_7-0x4
    1d31:	mov    0x2a8(%rsp),%rdi
    1d39:	mov    0x10(%rdi),%rcx
    1d3d:	mov    0x170(%rcx),%rdx
    1d44:	lea    0x140(%rsp),%r9
    1d4c:	mov    %rbx,0x140(%rsp)
    1d54:	mov    %rax,0x148(%rsp)
    1d5c:	mov    $0x2,%r8d
    1d62:	mov    $0x5,%ecx
    1d67:	mov    %r8,%rsi
    1d6a:	call   1d6f <botlish_fn_13+0x10ef>
			1d6b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1d6f:	jmp    203f <botlish_fn_13+0x13bf>
    1d74:	mov    0x2a8(%rsp),%rdi
    1d7c:	mov    0x10(%rdi),%rax
    1d80:	mov    0x160(%rax),%rbx
    1d87:	mov    0x2c0(%rsp),%rsi
    1d8f:	test   $0x1,%rsi
    1d96:	jne    1dce <botlish_fn_13+0x114e>
    1d9c:	mov    0x328(%rsp),%rdx
    1da4:	mov    0x2c0(%rsp),%rsi
    1dac:	mov    0x2a8(%rsp),%rdi
    1db4:	call   1db9 <botlish_fn_13+0x1139>
			1db5: R_X86_64_PLT32	rt_int_cmp-0x4
    1db9:	mov    $0x2,%ecx
    1dbe:	test   %rax,%rax
    1dc1:	cmovl  0x2a6f(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1dc9:	jmp    1de7 <botlish_fn_13+0x1167>
    1dce:	mov    $0x2,%ecx
    1dd3:	mov    0x2c0(%rsp),%rsi
    1ddb:	cmp    $0xffffffffffffffff,%rsi
    1ddf:	cmovl  0x2a51(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1de7:	cmp    $0x6,%rcx
    1deb:	je     1e74 <botlish_fn_13+0x11f4>
    1df1:	mov    0x2c0(%rsp),%rsi
    1df9:	test   $0x1,%rsi
    1e00:	jne    1e35 <botlish_fn_13+0x11b5>
    1e06:	mov    $0x1ff,%edx
    1e0b:	mov    0x2c0(%rsp),%rsi
    1e13:	mov    0x2a8(%rsp),%rdi
    1e1b:	call   1e20 <botlish_fn_13+0x11a0>
			1e1c: R_X86_64_PLT32	rt_int_cmp-0x4
    1e20:	mov    $0x2,%ecx
    1e25:	test   %rax,%rax
    1e28:	cmovg  0x2a08(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1e30:	jmp    1e51 <botlish_fn_13+0x11d1>
    1e35:	mov    $0x2,%ecx
    1e3a:	mov    0x2c0(%rsp),%rsi
    1e42:	cmp    $0x1ff,%rsi
    1e49:	cmovg  0x29e7(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1e51:	cmp    $0x6,%rcx
    1e55:	je     1e74 <botlish_fn_13+0x11f4>
    1e5b:	mov    0x2c0(%rsp),%rsi
    1e63:	mov    %rsi,%rax
    1e66:	sar    $1,%rax
    1e69:	movzbq 0x11(%rbx,%rax,1),%rsi
    1e6f:	jmp    1e7c <botlish_fn_13+0x11fc>
    1e74:	movzbq 0x616(%rbx),%rsi
    1e7c:	mov    %rsi,%rdx
    1e7f:	shl    $1,%rdx
    1e82:	or     $0x1,%rdx
    1e86:	mov    $0x2,%ecx
    1e8b:	cmp    $0xd,%rdx
    1e8f:	cmovl  0x29a1(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1e97:	cmp    $0x6,%rcx
    1e9b:	je     2213 <botlish_fn_13+0x1593>
    1ea1:	mov    %rsi,%rdx
    1ea4:	shl    $1,%rdx
    1ea7:	mov    %rsi,0x2e8(%rsp)
    1eaf:	or     $0x1,%rdx
    1eb3:	mov    $0x2,%ecx
    1eb8:	cmp    $0xd,%rdx
    1ebc:	cmove  0x2974(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1ec4:	cmp    $0x6,%rcx
    1ec8:	je     21f5 <botlish_fn_13+0x1575>
    1ece:	mov    0x2c0(%rsp),%rsi
    1ed6:	test   $0x1,%rsi
    1edd:	jne    1f15 <botlish_fn_13+0x1295>
    1ee3:	mov    0x328(%rsp),%rdx
    1eeb:	mov    0x2c0(%rsp),%rsi
    1ef3:	mov    0x2a8(%rsp),%rdi
    1efb:	call   1f00 <botlish_fn_13+0x1280>
			1efc: R_X86_64_PLT32	rt_int_cmp-0x4
    1f00:	mov    $0x2,%ecx
    1f05:	test   %rax,%rax
    1f08:	cmove  0x2928(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1f10:	jmp    1f2e <botlish_fn_13+0x12ae>
    1f15:	mov    $0x2,%ecx
    1f1a:	mov    0x2c0(%rsp),%rsi
    1f22:	cmp    $0xffffffffffffffff,%rsi
    1f26:	cmove  0x290a(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    1f2e:	cmp    $0x6,%rcx
    1f32:	je     1fca <botlish_fn_13+0x134a>
    1f38:	mov    0x2a8(%rsp),%rdi
    1f40:	mov    0x10(%rdi),%rax
    1f44:	mov    0x168(%rax),%rbx
    1f4b:	mov    $0x1,%r12d
    1f51:	mov    0x2e8(%rsp),%rsi
    1f59:	shl    $1,%rsi
    1f5c:	mov    %rsi,0x2e8(%rsp)
    1f64:	or     $0x1,%rsi
    1f68:	mov    %rsi,0x2e8(%rsp)
    1f70:	call   1f75 <botlish_fn_13+0x12f5>
			1f71: R_X86_64_PLT32	botlish_fn_5-0x4
    1f75:	mov    0x2a8(%rsp),%rdi
    1f7d:	mov    0x10(%rdi),%rcx
    1f81:	mov    0x178(%rcx),%rdx
    1f88:	lea    0x128(%rsp),%r9
    1f90:	mov    %rbx,0x128(%rsp)
    1f98:	mov    %rax,0x130(%rsp)
    1fa0:	mov    0x2c0(%rsp),%rsi
    1fa8:	mov    %rsi,0x138(%rsp)
    1fb0:	mov    $0x6,%ecx
    1fb5:	mov    %r12,%rsi
    1fb8:	mov    0x320(%rsp),%r8
    1fc0:	call   1fc5 <botlish_fn_13+0x1345>
			1fc1: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1fc5:	jmp    203f <botlish_fn_13+0x13bf>
    1fca:	mov    0x2a8(%rsp),%rdi
    1fd2:	mov    0x10(%rdi),%rdx
    1fd6:	mov    0x168(%rdx),%rbx
    1fdd:	mov    0x2e8(%rsp),%rsi
    1fe5:	shl    $1,%rsi
    1fe8:	mov    %rsi,0x2e8(%rsp)
    1ff0:	or     $0x1,%rsi
    1ff4:	mov    %rsi,0x2e8(%rsp)
    1ffc:	call   2001 <botlish_fn_13+0x1381>
			1ffd: R_X86_64_PLT32	botlish_fn_5-0x4
    2001:	mov    0x2a8(%rsp),%rdi
    2009:	mov    0x10(%rdi),%rdx
    200d:	mov    0x170(%rdx),%rdx
    2014:	lea    0x118(%rsp),%r9
    201c:	mov    %rbx,0x118(%rsp)
    2024:	mov    %rax,0x120(%rsp)
    202c:	mov    $0x2,%r8d
    2032:	mov    $0x5,%ecx
    2037:	mov    %r8,%rsi
    203a:	call   203f <botlish_fn_13+0x13bf>
			203b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    203f:	mov    0x2a8(%rsp),%rdi
    2047:	call   204c <botlish_fn_13+0x13cc>
			2048: R_X86_64_PLT32	rt_co_failed-0x4
    204c:	mov    %rax,0x60(%rsp)
    2051:	mov    %rax,%rsi
    2054:	mov    0x2a8(%rsp),%rdi
    205c:	call   2061 <botlish_fn_13+0x13e1>
			205d: R_X86_64_PLT32	rt_co_resume0-0x4
    2061:	test   %rax,%rax
    2064:	je     2086 <botlish_fn_13+0x1406>
    206a:	mov    0x2a8(%rsp),%rdi
    2072:	mov    0x10(%rdi),%r10
    2076:	mov    0x50(%r10),%rsi
    207a:	mov    0x128(%r10),%rdx
    2081:	call   2086 <botlish_fn_13+0x1406>
			2082: R_X86_64_PLT32	rt_raise-0x4
    2086:	mov    0x2a8(%rsp),%rdi
    208e:	call   2093 <botlish_fn_13+0x1413>
			208f: R_X86_64_PLT32	rt_declared_error-0x4
    2093:	cmp    $0x1,%rax
    2097:	je     2146 <botlish_fn_13+0x14c6>
    209d:	mov    0x2a8(%rsp),%rdi
    20a5:	call   20aa <botlish_fn_13+0x142a>
			20a6: R_X86_64_PLT32	rt_declared_error-0x4
    20aa:	cmp    $0x2,%rax
    20ae:	jne    44db <botlish_fn_13+0x385b>
    20b4:	xor    %rsi,%rsi
    20b7:	mov    0x2a8(%rsp),%rdi
    20bf:	call   20c4 <botlish_fn_13+0x1444>
			20c0: R_X86_64_PLT32	rt_declared_payload-0x4
    20c4:	mov    %rax,%rbx
    20c7:	mov    $0x1,%esi
    20cc:	mov    0x2a8(%rsp),%rdi
    20d4:	call   20d9 <botlish_fn_13+0x1459>
			20d5: R_X86_64_PLT32	rt_declared_payload-0x4
    20d9:	mov    %rax,%r12
    20dc:	mov    0x2a8(%rsp),%rdi
    20e4:	call   20e9 <botlish_fn_13+0x1469>
			20e5: R_X86_64_PLT32	rt_clear_declared_error-0x4
    20e9:	mov    0x2a8(%rsp),%rdi
    20f1:	mov    0x10(%rdi),%rax
    20f5:	mov    0x138(%rax),%rdx
    20fc:	lea    0xa8(%rsp),%r9
    2104:	mov    0x318(%rsp),%rsi
    210c:	mov    %rsi,0xa8(%rsp)
    2114:	mov    %rbx,%rax
    2117:	mov    %rax,0xb0(%rsp)
    211f:	mov    %r12,%rax
    2122:	mov    %rax,0xb8(%rsp)
    212a:	mov    $0x5,%esi
    212f:	mov    $0x2,%ecx
    2134:	mov    0x320(%rsp),%r8
    213c:	call   2141 <botlish_fn_13+0x14c1>
			213d: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2141:	jmp    44db <botlish_fn_13+0x385b>
    2146:	xor    %rsi,%rsi
    2149:	mov    0x2a8(%rsp),%rdi
    2151:	call   2156 <botlish_fn_13+0x14d6>
			2152: R_X86_64_PLT32	rt_declared_payload-0x4
    2156:	mov    %rax,%r12
    2159:	mov    $0x1,%ebx
    215e:	mov    %rbx,%rsi
    2161:	mov    0x2a8(%rsp),%rdi
    2169:	call   216e <botlish_fn_13+0x14ee>
			216a: R_X86_64_PLT32	rt_declared_payload-0x4
    216e:	mov    %rax,%r13
    2171:	mov    $0x2,%esi
    2176:	mov    0x2a8(%rsp),%rdi
    217e:	call   2183 <botlish_fn_13+0x1503>
			217f: R_X86_64_PLT32	rt_declared_payload-0x4
    2183:	mov    %rax,%r14
    2186:	mov    0x2a8(%rsp),%rdi
    218e:	call   2193 <botlish_fn_13+0x1513>
			218f: R_X86_64_PLT32	rt_clear_declared_error-0x4
    2193:	mov    0x2a8(%rsp),%rdi
    219b:	mov    0x10(%rdi),%rax
    219f:	mov    0x130(%rax),%rdx
    21a6:	lea    0x88(%rsp),%r9
    21ae:	mov    0x318(%rsp),%rsi
    21b6:	mov    %rsi,0x88(%rsp)
    21be:	mov    %r12,%rax
    21c1:	mov    %rax,0x90(%rsp)
    21c9:	mov    %r13,%rax
    21cc:	mov    %rax,0x98(%rsp)
    21d4:	mov    %r14,%rax
    21d7:	mov    %rax,0xa0(%rsp)
    21df:	mov    $0x4,%r8d
    21e5:	mov    %rbx,%rcx
    21e8:	mov    %r8,%rsi
    21eb:	call   21f0 <botlish_fn_13+0x1570>
			21ec: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    21f0:	jmp    44db <botlish_fn_13+0x385b>
    21f5:	movq   $0x3,0x68(%rsp)
    21fe:	mov    0x320(%rsp),%rax
    2206:	mov    %rax,0x2c8(%rsp)
    220e:	jmp    2292 <botlish_fn_13+0x1612>
    2213:	mov    %rsi,0x2e8(%rsp)
    221b:	shl    $1,%rsi
    221e:	mov    %rsi,0x2e8(%rsp)
    2226:	or     $0x1,%rsi
    222a:	mov    %rsi,0x2e8(%rsp)
    2232:	mov    %rsi,0x70(%rsp)
    2237:	mov    $0x1,%ebx
    223c:	movq   $0x1,0x58(%rsp)
    2245:	mov    $0xa,%esi
    224a:	mov    %rbx,%r14
    224d:	mov    %rsi,0x2c8(%rsp)
    2255:	mov    %rsi,0x2f0(%rsp)
    225d:	mov    %rsi,0x2f8(%rsp)
    2265:	jmp    2391 <botlish_fn_13+0x1711>
    226a:	mov    $0xfffffffffffffffd,%rsi
    2271:	mov    %rsi,0x2c0(%rsp)
    2279:	jmp    22df <botlish_fn_13+0x165f>
    227e:	shl    $1,%rsi
    2281:	or     $0x1,%rsi
    2285:	mov    %rsi,0x68(%rsp)
    228a:	mov    %rsi,0x2c8(%rsp)
    2292:	mov    $0x1,%ebx
    2297:	movq   $0x1,0x58(%rsp)
    22a0:	mov    $0x2,%r14d
    22a6:	mov    $0xa,%esi
    22ab:	mov    %rsi,0x2e8(%rsp)
    22b3:	mov    0x2e8(%rsp),%rax
    22bb:	mov    %rax,0x2f0(%rsp)
    22c3:	mov    %rax,0x2f8(%rsp)
    22cb:	jmp    2391 <botlish_fn_13+0x1711>
    22d0:	mov    $0xfffffffffffffffd,%rsi
    22d7:	mov    %rsi,0x2c0(%rsp)
    22df:	test   $0x1,%rsi
    22e6:	jne    231b <botlish_fn_13+0x169b>
    22ec:	mov    $0x1,%edx
    22f1:	mov    0x2c0(%rsp),%rsi
    22f9:	mov    0x2a8(%rsp),%rdi
    2301:	call   2306 <botlish_fn_13+0x1686>
			2302: R_X86_64_PLT32	rt_int_cmp-0x4
    2306:	mov    $0x2,%ecx
    230b:	test   %rax,%rax
    230e:	cmovge 0x2522(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2316:	jmp    233b <botlish_fn_13+0x16bb>
    231b:	mov    $0x2,%ecx
    2320:	mov    0x2c0(%rsp),%rax
    2328:	mov    0x2c0(%rsp),%rsi
    2330:	test   %rax,%rsi
    2333:	cmovg  0x24fd(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    233b:	cmp    $0x6,%rcx
    233f:	je     234f <botlish_fn_13+0x16cf>
    2345:	mov    $0x1,%ebx
    234a:	jmp    2357 <botlish_fn_13+0x16d7>
    234f:	mov    0x320(%rsp),%rbx
    2357:	mov    %rbx,0x58(%rsp)
    235c:	mov    $0xa,%esi
    2361:	mov    %rsi,0x2e8(%rsp)
    2369:	mov    0x328(%rsp),%r14
    2371:	mov    0x2e8(%rsp),%rax
    2379:	mov    %rax,0x2c8(%rsp)
    2381:	mov    %rax,0x2f0(%rsp)
    2389:	mov    %rax,0x2f8(%rsp)
    2391:	mov    0x338(%rsp),%rcx
    2399:	mov    0x18(%rcx),%rax
    239d:	test   %rax,%rax
    23a0:	je     46f1 <botlish_fn_13+0x3a71>
    23a6:	mov    0x338(%rsp),%rcx
    23ae:	mov    0x10(%rcx),%rax
    23b2:	mov    %rbx,0x18(%rax)
    23b6:	test   %r14,%r14
    23b9:	jl     3c59 <botlish_fn_13+0x2fd9>
    23bf:	mov    0x338(%rsp),%rcx
    23c7:	mov    0x10(%rcx),%rdx
    23cb:	mov    (%rdx),%rsi
    23ce:	mov    %rsi,0x18(%rsp)
    23d3:	movq   $0x3,0x20(%rsp)
    23dc:	test   $0x1,%rsi
    23e3:	je     2412 <botlish_fn_13+0x1792>
    23e9:	mov    %rsi,%rax
    23ec:	add    $0x2,%rax
    23f0:	mov    %rax,0x308(%rsp)
    23f8:	seto   %r9b
    23fc:	test   %r9b,%r9b
    23ff:	jne    2412 <botlish_fn_13+0x1792>
    2405:	mov    0x308(%rsp),%rcx
    240d:	jmp    2437 <botlish_fn_13+0x17b7>
    2412:	mov    0x320(%rsp),%rdx
    241a:	mov    0x2a8(%rsp),%rdi
    2422:	call   2427 <botlish_fn_13+0x17a7>
			2423: R_X86_64_PLT32	rt_int_add-0x4
    2427:	mov    %rax,0x308(%rsp)
    242f:	mov    0x308(%rsp),%rcx
    2437:	mov    %rcx,0x18(%rsp)
    243c:	mov    0x338(%rsp),%rcx
    2444:	mov    0x18(%rcx),%rax
    2448:	test   %rax,%rax
    244b:	je     4713 <botlish_fn_13+0x3a93>
    2451:	mov    0x338(%rsp),%rcx
    2459:	mov    0x10(%rcx),%rax
    245d:	mov    0x308(%rsp),%rcx
    2465:	mov    %rcx,(%rax)
    2468:	mov    0x2d0(%rsp),%rcx
    2470:	cmp    $0x1,%rcx
    2474:	je     249e <botlish_fn_13+0x181e>
    247a:	mov    $0xa,%esi
    247f:	cmp    $0xffffffffffffffff,%rcx
    2483:	jne    264a <botlish_fn_13+0x19ca>
    2489:	mov    0x300(%rsp),%rsi
    2491:	mov    %rcx,0x2d0(%rsp)
    2499:	jmp    27b7 <botlish_fn_13+0x1b37>
    249e:	add    $0x1,%r15
    24a5:	cmp    %r13,%r15
    24a8:	jl     2702 <botlish_fn_13+0x1a82>
    24ae:	movq   $0x3,0x20(%rsp)
    24b7:	mov    0x2e0(%rsp),%rsi
    24bf:	test   $0x1,%rsi
    24c6:	jne    24d9 <botlish_fn_13+0x1859>
    24cc:	mov    0x2e0(%rsp),%rsi
    24d4:	jmp    2510 <botlish_fn_13+0x1890>
    24d9:	mov    0x2e0(%rsp),%rsi
    24e1:	mov    %rsi,%rcx
    24e4:	add    $0x2,%rcx
    24e8:	seto   %al
    24eb:	test   %al,%al
    24ed:	je     2500 <botlish_fn_13+0x1880>
    24f3:	mov    0x2e0(%rsp),%rsi
    24fb:	jmp    2510 <botlish_fn_13+0x1890>
    2500:	mov    %rcx,%rsi
    2503:	mov    %rcx,0x2e0(%rsp)
    250b:	jmp    2530 <botlish_fn_13+0x18b0>
    2510:	mov    0x320(%rsp),%rdx
    2518:	mov    0x2a8(%rsp),%rdi
    2520:	call   2525 <botlish_fn_13+0x18a5>
			2521: R_X86_64_PLT32	rt_int_add-0x4
    2525:	mov    %rax,%rsi
    2528:	mov    %rax,0x2e0(%rsp)
    2530:	mov    %rsi,0x48(%rsp)
    2535:	mov    0x2e0(%rsp),%rsi
    253d:	mov    %rsi,%rax
    2540:	and    %r12,%rax
    2543:	test   $0x1,%rax
    2549:	jne    257c <botlish_fn_13+0x18fc>
    254f:	mov    %r12,%rdx
    2552:	mov    0x2e0(%rsp),%rsi
    255a:	mov    0x2a8(%rsp),%rdi
    2562:	call   2567 <botlish_fn_13+0x18e7>
			2563: R_X86_64_PLT32	rt_int_cmp-0x4
    2567:	mov    $0x2,%ecx
    256c:	test   %rax,%rax
    256f:	cmovl  0x22c1(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2577:	jmp    2594 <botlish_fn_13+0x1914>
    257c:	mov    $0x2,%ecx
    2581:	mov    0x2e0(%rsp),%rsi
    2589:	cmp    %r12,%rsi
    258c:	cmovl  0x22a4(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2594:	cmp    $0x6,%rcx
    2598:	je     25cc <botlish_fn_13+0x194c>
    259e:	movq   $0xffffffffffffffff,0x28(%rsp)
    25a7:	mov    0x328(%rsp),%rsi
    25af:	mov    0x328(%rsp),%rax
    25b7:	mov    %rax,0x2d0(%rsp)
    25bf:	mov    %rax,0x300(%rsp)
    25c7:	jmp    27b7 <botlish_fn_13+0x1b37>
    25cc:	mov    0x2e0(%rsp),%rsi
    25d4:	test   $0x1,%rsi
    25db:	je     2604 <botlish_fn_13+0x1984>
    25e1:	mov    0x2b0(%rsp),%rax
    25e9:	mov    0x8(%rax),%rcx
    25ed:	mov    0x2e0(%rsp),%rsi
    25f5:	mov    %rsi,%rax
    25f8:	sar    $1,%rax
    25fb:	cmp    %rcx,%rax
    25fe:	jb     26c7 <botlish_fn_13+0x1a47>
    2604:	mov    0x2e0(%rsp),%rdx
    260c:	mov    0x2b0(%rsp),%rsi
    2614:	mov    0x2a8(%rsp),%rdi
    261c:	call   2621 <botlish_fn_13+0x19a1>
			261d: R_X86_64_PLT32	rt_list_get-0x4
    2621:	mov    %rax,%rcx
    2624:	mov    %rax,0x2d8(%rsp)
    262c:	test   %rcx,%rax
    262f:	jne    26ba <botlish_fn_13+0x1a3a>
    2635:	mov    0x2a8(%rsp),%rdi
    263d:	call   2642 <botlish_fn_13+0x19c2>
			263e: R_X86_64_PLT32	rt_co_failed-0x4
    2642:	mov    %rax,0x30(%rsp)
    2647:	mov    %rax,%rsi
    264a:	mov    0x2a8(%rsp),%rdi
    2652:	call   2657 <botlish_fn_13+0x19d7>
			2653: R_X86_64_PLT32	rt_co_resume0-0x4
    2657:	test   %rax,%rax
    265a:	jne    266d <botlish_fn_13+0x19ed>
    2660:	mov    0x2a8(%rsp),%rdi
    2668:	jmp    269c <botlish_fn_13+0x1a1c>
    266d:	mov    0x2a8(%rsp),%rdi
    2675:	mov    0x10(%rdi),%rsi
    2679:	mov    0x50(%rsi),%rdi
    267d:	mov    0x128(%rsi),%rdx
    2684:	mov    %rdi,%rsi
    2687:	mov    0x2a8(%rsp),%rdi
    268f:	call   2694 <botlish_fn_13+0x1a14>
			2690: R_X86_64_PLT32	rt_raise-0x4
    2694:	mov    0x2a8(%rsp),%rdi
    269c:	mov    0x2a8(%rsp),%rdi
    26a4:	call   26a9 <botlish_fn_13+0x1a29>
			26a5: R_X86_64_PLT32	rt_declared_error-0x4
    26a9:	cmp    $0x40000001,%rax
    26af:	jne    44db <botlish_fn_13+0x385b>
    26b5:	jmp    44db <botlish_fn_13+0x385b>
    26ba:	mov    0x2d8(%rsp),%rax
    26c2:	jmp    26df <botlish_fn_13+0x1a5f>
    26c7:	mov    0x2b0(%rsp),%rcx
    26cf:	mov    0x10(%rcx),%rcx
    26d3:	mov    (%rcx,%rax,8),%rax
    26d7:	mov    %rax,0x2d8(%rsp)
    26df:	mov    %rax,0x50(%rsp)
    26e4:	mov    0x2d8(%rsp),%rax
    26ec:	mov    0x8(%rax),%r13
    26f0:	xor    %r15,%r15
    26f3:	shl    $1,%r13
    26f6:	or     $0x1,%r13
    26fa:	sar    $1,%r13
    26fd:	jmp    24a5 <botlish_fn_13+0x1825>
    2702:	mov    0x2d8(%rsp),%rax
    270a:	movzbq 0x18(%rax),%rax
    270f:	test   %rax,%rax
    2712:	jne    2747 <botlish_fn_13+0x1ac7>
    2718:	mov    %r15,%rdx
    271b:	shl    $1,%rdx
    271e:	or     $0x1,%rdx
    2722:	mov    0x2d8(%rsp),%rsi
    272a:	mov    0x2a8(%rsp),%rdi
    2732:	call   2737 <botlish_fn_13+0x1ab7>
			2733: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    2737:	mov    %rax,%rsi
    273a:	mov    %rax,0x300(%rsp)
    2742:	jmp    2782 <botlish_fn_13+0x1b02>
    2747:	mov    %r15,%rcx
    274a:	shl    $1,%rcx
    274d:	or     $0x1,%rcx
    2751:	sar    $1,%rcx
    2754:	mov    0x2d8(%rsp),%rax
    275c:	movzbq 0x19(%rax,%rcx,1),%rsi
    2762:	mov    %rsi,0x300(%rsp)
    276a:	shl    $0x3,%rsi
    276e:	mov    %rsi,0x300(%rsp)
    2776:	or     $0x4,%rsi
    277a:	mov    %rsi,0x300(%rsp)
    2782:	shr    $0x3,%rsi
    2786:	mov    %rsi,0x300(%rsp)
    278e:	mov    $0x1,%ecx
    2793:	mov    %rcx,0x2d0(%rsp)
    279b:	shl    $1,%rsi
    279e:	mov    %rsi,0x300(%rsp)
    27a6:	or     $0x1,%rsi
    27aa:	mov    %rsi,0x300(%rsp)
    27b2:	mov    %rsi,0x28(%rsp)
    27b7:	mov    %rsi,0x20(%rsp)
    27bc:	mov    0x338(%rsp),%rcx
    27c4:	mov    0x18(%rcx),%rax
    27c8:	test   %rax,%rax
    27cb:	je     473a <botlish_fn_13+0x3aba>
    27d1:	mov    0x338(%rsp),%rcx
    27d9:	mov    0x10(%rcx),%rax
    27dd:	mov    0x300(%rsp),%rsi
    27e5:	mov    %rsi,0x8(%rax)
    27e9:	mov    0x308(%rsp),%rcx
    27f1:	mov    0x318(%rsp),%rsi
    27f9:	mov    %rcx,%rax
    27fc:	and    %rsi,%rax
    27ff:	test   $0x1,%rax
    2805:	je     283a <botlish_fn_13+0x1bba>
    280b:	mov    0x308(%rsp),%rcx
    2813:	mov    0x318(%rsp),%rsi
    281b:	sub    %rsi,%rcx
    281e:	seto   %al
    2821:	lea    0x1(%rcx),%rsi
    2825:	test   %al,%al
    2827:	jne    283a <botlish_fn_13+0x1bba>
    282d:	mov    0x2b8(%rsp),%rdx
    2835:	jmp    2862 <botlish_fn_13+0x1be2>
    283a:	mov    0x318(%rsp),%rdx
    2842:	mov    0x308(%rsp),%rsi
    284a:	mov    0x2a8(%rsp),%rdi
    2852:	call   2857 <botlish_fn_13+0x1bd7>
			2853: R_X86_64_PLT32	rt_int_sub-0x4
    2857:	mov    0x2b8(%rsp),%rdx
    285f:	mov    %rax,%rsi
    2862:	mov    %rsi,%rax
    2865:	and    %rdx,%rax
    2868:	mov    %rdx,0x2b8(%rsp)
    2870:	test   $0x1,%rax
    2876:	jne    28a6 <botlish_fn_13+0x1c26>
    287c:	mov    0x2b8(%rsp),%rdx
    2884:	mov    0x2a8(%rsp),%rdi
    288c:	call   2891 <botlish_fn_13+0x1c11>
			288d: R_X86_64_PLT32	rt_int_cmp-0x4
    2891:	mov    $0x2,%ecx
    2896:	test   %rax,%rax
    2899:	cmovge 0x1f97(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    28a1:	jmp    28be <botlish_fn_13+0x1c3e>
    28a6:	mov    $0x2,%ecx
    28ab:	mov    0x2b8(%rsp),%rdx
    28b3:	cmp    %rdx,%rsi
    28b6:	cmovge 0x1f7a(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    28be:	cmp    $0x6,%rcx
    28c2:	je     3bf6 <botlish_fn_13+0x2f76>
    28c8:	cmp    $0x1,%r14
    28cc:	je     36bd <botlish_fn_13+0x2a3d>
    28d2:	cmp    $0x2,%r14
    28d6:	je     30a4 <botlish_fn_13+0x2424>
    28dc:	cmp    $0x3,%r14
    28e0:	je     2cde <botlish_fn_13+0x205e>
    28e6:	mov    $0x4,%ecx
    28eb:	mov    %rcx,0x310(%rsp)
    28f3:	cmp    $0x4,%r14
    28f7:	je     2911 <botlish_fn_13+0x1c91>
    28fd:	mov    $0xa,%esi
    2902:	cmp    $0xffffffffffffffff,%r14
    2906:	je     3bcc <botlish_fn_13+0x2f4c>
    290c:	jmp    39b4 <botlish_fn_13+0x2d34>
    2911:	mov    0x2a8(%rsp),%rdi
    2919:	mov    0x2f8(%rsp),%r14
    2921:	mov    0x300(%rsp),%rax
    2929:	mov    %rax,0x2c0(%rsp)
    2931:	mov    0x10(%rdi),%rax
    2935:	mov    0x198(%rax),%rbx
    293c:	mov    0x300(%rsp),%rsi
    2944:	test   $0x1,%rsi
    294b:	jne    2983 <botlish_fn_13+0x1d03>
    2951:	mov    0x328(%rsp),%rdx
    2959:	mov    0x300(%rsp),%rsi
    2961:	mov    0x2a8(%rsp),%rdi
    2969:	call   296e <botlish_fn_13+0x1cee>
			296a: R_X86_64_PLT32	rt_int_cmp-0x4
    296e:	mov    $0x2,%ecx
    2973:	test   %rax,%rax
    2976:	cmovl  0x1eba(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    297e:	jmp    299c <botlish_fn_13+0x1d1c>
    2983:	mov    $0x2,%ecx
    2988:	mov    0x300(%rsp),%rsi
    2990:	cmp    $0xffffffffffffffff,%rsi
    2994:	cmovl  0x1e9c(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    299c:	cmp    $0x6,%rcx
    29a0:	jne    29b3 <botlish_fn_13+0x1d33>
    29a6:	mov    0x2f8(%rsp),%rsi
    29ae:	jmp    2a76 <botlish_fn_13+0x1df6>
    29b3:	mov    0x300(%rsp),%rsi
    29bb:	test   $0x1,%rsi
    29c2:	jne    29f7 <botlish_fn_13+0x1d77>
    29c8:	mov    $0x1ff,%edx
    29cd:	mov    0x300(%rsp),%rsi
    29d5:	mov    0x2a8(%rsp),%rdi
    29dd:	call   29e2 <botlish_fn_13+0x1d62>
			29de: R_X86_64_PLT32	rt_int_cmp-0x4
    29e2:	mov    $0x2,%ecx
    29e7:	test   %rax,%rax
    29ea:	cmovg  0x1e46(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    29f2:	jmp    2a13 <botlish_fn_13+0x1d93>
    29f7:	mov    $0x2,%ecx
    29fc:	mov    0x300(%rsp),%rsi
    2a04:	cmp    $0x1ff,%rsi
    2a0b:	cmovg  0x1e25(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2a13:	cmp    $0x6,%rcx
    2a17:	jne    2a2a <botlish_fn_13+0x1daa>
    2a1d:	mov    0x2f8(%rsp),%rsi
    2a25:	jmp    2a76 <botlish_fn_13+0x1df6>
    2a2a:	mov    0x2f8(%rsp),%rsi
    2a32:	or     $0x1,%rsi
    2a36:	mov    %rsi,0x2f8(%rsp)
    2a3e:	sar    $1,%rsi
    2a41:	mov    %rsi,0x2f8(%rsp)
    2a49:	imul   $0x101,%rsi,%rax
    2a50:	mov    0x300(%rsp),%rsi
    2a58:	mov    %rsi,%rcx
    2a5b:	sar    $1,%rcx
    2a5e:	lea    0x1(%rax,%rcx,1),%rax
    2a63:	movzbq 0x10(%rbx,%rax,1),%rsi
    2a69:	mov    %rsi,0x2f8(%rsp)
    2a71:	jmp    2a9e <botlish_fn_13+0x1e1e>
    2a76:	or     $0x1,%rsi
    2a7a:	mov    %rsi,0x2f8(%rsp)
    2a82:	sar    $1,%rsi
    2a85:	mov    %rsi,0x2f8(%rsp)
    2a8d:	movzbq 0xc1c(%rbx,%rsi,1),%rsi
    2a96:	mov    %rsi,0x2f8(%rsp)
    2a9e:	mov    0x2f8(%rsp),%rsi
    2aa6:	mov    %rsi,%rcx
    2aa9:	shl    $1,%rcx
    2aac:	or     $0x1,%rcx
    2ab0:	mov    $0x2,%r8d
    2ab6:	cmp    $0x19,%rcx
    2aba:	cmovl  0x1d76(%rip),%r8        # 4838 <botlish_fn_13+0x3bb8>
    2ac2:	cmp    $0x6,%r8
    2ac6:	je     2c8c <botlish_fn_13+0x200c>
    2acc:	mov    0x2f8(%rsp),%rsi
    2ad4:	mov    %rsi,%rdx
    2ad7:	shl    $1,%rdx
    2ada:	or     $0x1,%rdx
    2ade:	mov    $0x2,%ecx
    2ae3:	cmp    $0x19,%rdx
    2ae7:	cmove  0x1d49(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2aef:	cmp    $0x6,%rcx
    2af3:	je     2c6f <botlish_fn_13+0x1fef>
    2af9:	mov    0x300(%rsp),%rsi
    2b01:	test   $0x1,%rsi
    2b08:	jne    2b40 <botlish_fn_13+0x1ec0>
    2b0e:	mov    0x328(%rsp),%rdx
    2b16:	mov    0x300(%rsp),%rsi
    2b1e:	mov    0x2a8(%rsp),%rdi
    2b26:	call   2b2b <botlish_fn_13+0x1eab>
			2b27: R_X86_64_PLT32	rt_int_cmp-0x4
    2b2b:	mov    $0x2,%ecx
    2b30:	test   %rax,%rax
    2b33:	cmove  0x1cfd(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2b3b:	jmp    2b59 <botlish_fn_13+0x1ed9>
    2b40:	mov    $0x2,%ecx
    2b45:	mov    0x300(%rsp),%rsi
    2b4d:	cmp    $0xffffffffffffffff,%rsi
    2b51:	cmove  0x1cdf(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2b59:	cmp    $0x6,%rcx
    2b5d:	je     2bf5 <botlish_fn_13+0x1f75>
    2b63:	mov    0x2a8(%rsp),%rdi
    2b6b:	mov    0x10(%rdi),%rax
    2b6f:	mov    0x1a0(%rax),%rbx
    2b76:	mov    $0x1,%r12d
    2b7c:	mov    0x2f8(%rsp),%rsi
    2b84:	shl    $1,%rsi
    2b87:	mov    %rsi,0x2f8(%rsp)
    2b8f:	or     $0x1,%rsi
    2b93:	mov    %rsi,0x2f8(%rsp)
    2b9b:	call   2ba0 <botlish_fn_13+0x1f20>
			2b9c: R_X86_64_PLT32	botlish_fn_3-0x4
    2ba0:	mov    0x2a8(%rsp),%rdi
    2ba8:	mov    0x10(%rdi),%rcx
    2bac:	mov    0x178(%rcx),%rdx
    2bb3:	lea    0x268(%rsp),%r9
    2bbb:	mov    %rbx,0x268(%rsp)
    2bc3:	mov    %rax,0x270(%rsp)
    2bcb:	mov    0x300(%rsp),%rsi
    2bd3:	mov    %rsi,0x278(%rsp)
    2bdb:	mov    $0x6,%ecx
    2be0:	mov    %r12,%rsi
    2be3:	mov    0x320(%rsp),%r8
    2beb:	call   2bf0 <botlish_fn_13+0x1f70>
			2bec: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2bf0:	jmp    399f <botlish_fn_13+0x2d1f>
    2bf5:	mov    0x2a8(%rsp),%rdi
    2bfd:	mov    0x10(%rdi),%rax
    2c01:	mov    0x1a0(%rax),%rbx
    2c08:	mov    0x2f8(%rsp),%rsi
    2c10:	shl    $1,%rsi
    2c13:	mov    %rsi,0x2f8(%rsp)
    2c1b:	or     $0x1,%rsi
    2c1f:	mov    %rsi,0x2f8(%rsp)
    2c27:	call   2c2c <botlish_fn_13+0x1fac>
			2c28: R_X86_64_PLT32	botlish_fn_3-0x4
    2c2c:	mov    0x2a8(%rsp),%rdi
    2c34:	mov    0x10(%rdi),%rcx
    2c38:	mov    0x170(%rcx),%rdx
    2c3f:	lea    0x258(%rsp),%r9
    2c47:	mov    %rbx,0x258(%rsp)
    2c4f:	mov    %rax,0x260(%rsp)
    2c57:	mov    $0x2,%r8d
    2c5d:	mov    $0x5,%ecx
    2c62:	mov    %r8,%rsi
    2c65:	call   2c6a <botlish_fn_13+0x1fea>
			2c66: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2c6a:	jmp    399f <botlish_fn_13+0x2d1f>
    2c6f:	mov    %r14,0x2f8(%rsp)
    2c77:	mov    0x2c8(%rsp),%r14
    2c7f:	mov    0x300(%rsp),%rsi
    2c87:	jmp    35c6 <botlish_fn_13+0x2946>
    2c8c:	mov    0x2f8(%rsp),%rsi
    2c94:	shl    $1,%rsi
    2c97:	mov    %rsi,0x2f8(%rsp)
    2c9f:	or     $0x1,%rsi
    2ca3:	mov    %rsi,0x2f8(%rsp)
    2cab:	mov    %rsi,0x80(%rsp)
    2cb3:	mov    $0x1,%ebx
    2cb8:	movq   $0x1,0x58(%rsp)
    2cc1:	mov    0x310(%rsp),%r14
    2cc9:	mov    0x2c0(%rsp),%rax
    2cd1:	mov    %rax,0x300(%rsp)
    2cd9:	jmp    3bcc <botlish_fn_13+0x2f4c>
    2cde:	mov    0x2a8(%rsp),%rdi
    2ce6:	mov    0x2f0(%rsp),%r14
    2cee:	mov    0x300(%rsp),%rax
    2cf6:	mov    %rax,0x2c0(%rsp)
    2cfe:	mov    0x10(%rdi),%rax
    2d02:	mov    0x188(%rax),%rbx
    2d09:	mov    0x300(%rsp),%rsi
    2d11:	test   $0x1,%rsi
    2d18:	jne    2d50 <botlish_fn_13+0x20d0>
    2d1e:	mov    0x328(%rsp),%rdx
    2d26:	mov    0x300(%rsp),%rsi
    2d2e:	mov    0x2a8(%rsp),%rdi
    2d36:	call   2d3b <botlish_fn_13+0x20bb>
			2d37: R_X86_64_PLT32	rt_int_cmp-0x4
    2d3b:	mov    $0x2,%ecx
    2d40:	test   %rax,%rax
    2d43:	cmovl  0x1aed(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2d4b:	jmp    2d69 <botlish_fn_13+0x20e9>
    2d50:	mov    $0x2,%ecx
    2d55:	mov    0x300(%rsp),%rsi
    2d5d:	cmp    $0xffffffffffffffff,%rsi
    2d61:	cmovl  0x1acf(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2d69:	cmp    $0x6,%rcx
    2d6d:	jne    2d80 <botlish_fn_13+0x2100>
    2d73:	mov    0x2f0(%rsp),%rsi
    2d7b:	jmp    2e40 <botlish_fn_13+0x21c0>
    2d80:	mov    0x300(%rsp),%rsi
    2d88:	test   $0x1,%rsi
    2d8f:	jne    2dc4 <botlish_fn_13+0x2144>
    2d95:	mov    $0x1ff,%edx
    2d9a:	mov    0x300(%rsp),%rsi
    2da2:	mov    0x2a8(%rsp),%rdi
    2daa:	call   2daf <botlish_fn_13+0x212f>
			2dab: R_X86_64_PLT32	rt_int_cmp-0x4
    2daf:	mov    $0x2,%ecx
    2db4:	test   %rax,%rax
    2db7:	cmovg  0x1a79(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2dbf:	jmp    2de0 <botlish_fn_13+0x2160>
    2dc4:	mov    $0x2,%ecx
    2dc9:	mov    0x300(%rsp),%rsi
    2dd1:	cmp    $0x1ff,%rsi
    2dd8:	cmovg  0x1a58(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2de0:	cmp    $0x6,%rcx
    2de4:	jne    2df7 <botlish_fn_13+0x2177>
    2dea:	mov    0x2f0(%rsp),%rsi
    2df2:	jmp    2e40 <botlish_fn_13+0x21c0>
    2df7:	mov    0x2f0(%rsp),%rsi
    2dff:	or     $0x1,%rsi
    2e03:	mov    %rsi,0x2f0(%rsp)
    2e0b:	sar    $1,%rsi
    2e0e:	mov    %rsi,0x2f0(%rsp)
    2e16:	imul   $0x101,%rsi,%rsi
    2e1d:	mov    0x300(%rsp),%rdi
    2e25:	sar    $1,%rdi
    2e28:	lea    0x1(%rsi,%rdi,1),%rsi
    2e2d:	movzbq 0x10(%rbx,%rsi,1),%rsi
    2e33:	mov    %rsi,0x2f0(%rsp)
    2e3b:	jmp    2e68 <botlish_fn_13+0x21e8>
    2e40:	or     $0x1,%rsi
    2e44:	mov    %rsi,0x2f0(%rsp)
    2e4c:	sar    $1,%rsi
    2e4f:	mov    %rsi,0x2f0(%rsp)
    2e57:	movzbq 0x919(%rbx,%rsi,1),%rsi
    2e60:	mov    %rsi,0x2f0(%rsp)
    2e68:	mov    0x2f0(%rsp),%rsi
    2e70:	mov    %rsi,%rdi
    2e73:	shl    $1,%rdi
    2e76:	or     $0x1,%rdi
    2e7a:	mov    $0x2,%ecx
    2e7f:	cmp    $0x13,%rdi
    2e83:	cmovl  0x19ad(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2e8b:	cmp    $0x6,%rcx
    2e8f:	je     3055 <botlish_fn_13+0x23d5>
    2e95:	mov    0x2f0(%rsp),%rsi
    2e9d:	mov    %rsi,%rdx
    2ea0:	shl    $1,%rdx
    2ea3:	or     $0x1,%rdx
    2ea7:	mov    $0x2,%ecx
    2eac:	cmp    $0x13,%rdx
    2eb0:	cmove  0x1980(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2eb8:	cmp    $0x6,%rcx
    2ebc:	je     3038 <botlish_fn_13+0x23b8>
    2ec2:	mov    0x300(%rsp),%rsi
    2eca:	test   $0x1,%rsi
    2ed1:	jne    2f09 <botlish_fn_13+0x2289>
    2ed7:	mov    0x328(%rsp),%rdx
    2edf:	mov    0x300(%rsp),%rsi
    2ee7:	mov    0x2a8(%rsp),%rdi
    2eef:	call   2ef4 <botlish_fn_13+0x2274>
			2ef0: R_X86_64_PLT32	rt_int_cmp-0x4
    2ef4:	mov    $0x2,%ecx
    2ef9:	test   %rax,%rax
    2efc:	cmove  0x1934(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2f04:	jmp    2f22 <botlish_fn_13+0x22a2>
    2f09:	mov    $0x2,%ecx
    2f0e:	mov    0x300(%rsp),%rsi
    2f16:	cmp    $0xffffffffffffffff,%rsi
    2f1a:	cmove  0x1916(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    2f22:	cmp    $0x6,%rcx
    2f26:	je     2fbe <botlish_fn_13+0x233e>
    2f2c:	mov    0x2a8(%rsp),%rdi
    2f34:	mov    0x10(%rdi),%rax
    2f38:	mov    0x190(%rax),%rbx
    2f3f:	mov    $0x1,%r12d
    2f45:	mov    0x2f0(%rsp),%rsi
    2f4d:	shl    $1,%rsi
    2f50:	mov    %rsi,0x2f0(%rsp)
    2f58:	or     $0x1,%rsi
    2f5c:	mov    %rsi,0x2f0(%rsp)
    2f64:	call   2f69 <botlish_fn_13+0x22e9>
			2f65: R_X86_64_PLT32	botlish_fn_1-0x4
    2f69:	mov    0x2a8(%rsp),%rdi
    2f71:	mov    0x10(%rdi),%rcx
    2f75:	mov    0x178(%rcx),%rdx
    2f7c:	lea    0x240(%rsp),%r9
    2f84:	mov    %rbx,0x240(%rsp)
    2f8c:	mov    %rax,0x248(%rsp)
    2f94:	mov    0x300(%rsp),%rsi
    2f9c:	mov    %rsi,0x250(%rsp)
    2fa4:	mov    $0x6,%ecx
    2fa9:	mov    %r12,%rsi
    2fac:	mov    0x320(%rsp),%r8
    2fb4:	call   2fb9 <botlish_fn_13+0x2339>
			2fb5: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2fb9:	jmp    399f <botlish_fn_13+0x2d1f>
    2fbe:	mov    0x2a8(%rsp),%rdi
    2fc6:	mov    0x10(%rdi),%rax
    2fca:	mov    0x190(%rax),%rbx
    2fd1:	mov    0x2f0(%rsp),%rsi
    2fd9:	shl    $1,%rsi
    2fdc:	mov    %rsi,0x2f0(%rsp)
    2fe4:	or     $0x1,%rsi
    2fe8:	mov    %rsi,0x2f0(%rsp)
    2ff0:	call   2ff5 <botlish_fn_13+0x2375>
			2ff1: R_X86_64_PLT32	botlish_fn_1-0x4
    2ff5:	mov    0x2a8(%rsp),%rdi
    2ffd:	mov    0x10(%rdi),%rcx
    3001:	mov    0x170(%rcx),%rdx
    3008:	lea    0x230(%rsp),%r9
    3010:	mov    %rbx,0x230(%rsp)
    3018:	mov    %rax,0x238(%rsp)
    3020:	mov    $0x2,%r8d
    3026:	mov    $0x5,%ecx
    302b:	mov    %r8,%rsi
    302e:	call   3033 <botlish_fn_13+0x23b3>
			302f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3033:	jmp    399f <botlish_fn_13+0x2d1f>
    3038:	mov    %r14,0x2f0(%rsp)
    3040:	mov    0x2c8(%rsp),%r14
    3048:	mov    0x300(%rsp),%rsi
    3050:	jmp    35c6 <botlish_fn_13+0x2946>
    3055:	mov    0x2f0(%rsp),%rsi
    305d:	shl    $1,%rsi
    3060:	mov    %rsi,0x2f0(%rsp)
    3068:	or     $0x1,%rsi
    306c:	mov    %rsi,0x2f0(%rsp)
    3074:	mov    %rsi,0x78(%rsp)
    3079:	mov    $0x1,%ebx
    307e:	movq   $0x1,0x58(%rsp)
    3087:	mov    0x320(%rsp),%r14
    308f:	mov    0x2c0(%rsp),%rax
    3097:	mov    %rax,0x300(%rsp)
    309f:	jmp    3bcc <botlish_fn_13+0x2f4c>
    30a4:	mov    0x2c8(%rsp),%rsi
    30ac:	mov    0x2c8(%rsp),%r14
    30b4:	mov    0x300(%rsp),%rax
    30bc:	mov    %rax,0x2c0(%rsp)
    30c4:	or     $0x1,%rsi
    30c8:	mov    %rsi,0x2c8(%rsp)
    30d0:	sar    $1,%rsi
    30d3:	mov    %rsi,%rax
    30d6:	mov    %rsi,0x2c8(%rsp)
    30de:	test   %rax,%rsi
    30e1:	jle    327c <botlish_fn_13+0x25fc>
    30e7:	mov    0x2c8(%rsp),%rsi
    30ef:	cmp    $0x2,%rsi
    30f3:	jl     3106 <botlish_fn_13+0x2486>
    30f9:	mov    0x2a8(%rsp),%rdi
    3101:	jmp    3699 <botlish_fn_13+0x2a19>
    3106:	mov    0x300(%rsp),%rsi
    310e:	test   $0x1,%rsi
    3115:	jne    314a <botlish_fn_13+0x24ca>
    311b:	mov    $0x41,%edx
    3120:	mov    0x300(%rsp),%rsi
    3128:	mov    0x2a8(%rsp),%rdi
    3130:	call   3135 <botlish_fn_13+0x24b5>
			3131: R_X86_64_PLT32	rt_int_cmp-0x4
    3135:	mov    $0x2,%esi
    313a:	test   %rax,%rax
    313d:	cmovl  0x16f3(%rip),%rsi        # 4838 <botlish_fn_13+0x3bb8>
    3145:	jmp    3163 <botlish_fn_13+0x24e3>
    314a:	mov    $0x2,%esi
    314f:	mov    0x300(%rsp),%rax
    3157:	cmp    $0x41,%rax
    315b:	cmovl  0x16d5(%rip),%rsi        # 4838 <botlish_fn_13+0x3bb8>
    3163:	cmp    $0x6,%rsi
    3167:	je     326a <botlish_fn_13+0x25ea>
    316d:	mov    0x300(%rsp),%rsi
    3175:	test   $0x1,%rsi
    317c:	jne    31b1 <botlish_fn_13+0x2531>
    3182:	mov    $0x21ffff,%edx
    3187:	mov    0x300(%rsp),%rsi
    318f:	mov    0x2a8(%rsp),%rdi
    3197:	call   319c <botlish_fn_13+0x251c>
			3198: R_X86_64_PLT32	rt_int_cmp-0x4
    319c:	mov    $0x2,%ecx
    31a1:	test   %rax,%rax
    31a4:	cmovg  0x168c(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    31ac:	jmp    31cd <botlish_fn_13+0x254d>
    31b1:	mov    $0x2,%ecx
    31b6:	mov    0x300(%rsp),%rsi
    31be:	cmp    $0x21ffff,%rsi
    31c5:	cmovg  0x166b(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    31cd:	cmp    $0x6,%rcx
    31d1:	je     326a <botlish_fn_13+0x25ea>
    31d7:	mov    0x300(%rsp),%rsi
    31df:	mov    %rsi,%rcx
    31e2:	sar    $1,%rcx
    31e5:	cmp    $0x5c,%rcx
    31e9:	jl     323a <botlish_fn_13+0x25ba>
    31ef:	cmp    $0xd800,%rcx
    31f6:	jl     321b <botlish_fn_13+0x259b>
    31fc:	cmp    $0xe000,%rcx
    3203:	jl     326a <botlish_fn_13+0x25ea>
    3209:	cmp    $0x110000,%rcx
    3210:	jge    326a <botlish_fn_13+0x25ea>
    3216:	jmp    3385 <botlish_fn_13+0x2705>
    321b:	cmp    $0x5d,%rcx
    321f:	jge    3385 <botlish_fn_13+0x2705>
    3225:	mov    0x320(%rsp),%rax
    322d:	mov    %rax,0x2c8(%rsp)
    3235:	jmp    33a4 <botlish_fn_13+0x2724>
    323a:	cmp    $0x22,%rcx
    323e:	jl     3260 <botlish_fn_13+0x25e0>
    3244:	cmp    $0x23,%rcx
    3248:	jge    3385 <botlish_fn_13+0x2705>
    324e:	mov    $0x2,%esi
    3253:	mov    %rsi,0x2c8(%rsp)
    325b:	jmp    33a4 <botlish_fn_13+0x2724>
    3260:	cmp    $0x20,%rcx
    3264:	jge    3385 <botlish_fn_13+0x2705>
    326a:	mov    $0x5,%esi
    326f:	mov    %rsi,0x2c8(%rsp)
    3277:	jmp    33a4 <botlish_fn_13+0x2724>
    327c:	mov    0x2c8(%rsp),%rax
    3284:	mov    0x2c8(%rsp),%rsi
    328c:	test   %rax,%rsi
    328f:	jl     3691 <botlish_fn_13+0x2a11>
    3295:	mov    0x300(%rsp),%rsi
    329d:	test   $0x1,%rsi
    32a4:	jne    32d9 <botlish_fn_13+0x2659>
    32aa:	mov    $0x45,%edx
    32af:	mov    0x300(%rsp),%rsi
    32b7:	mov    0x2a8(%rsp),%rdi
    32bf:	call   32c4 <botlish_fn_13+0x2644>
			32c0: R_X86_64_PLT32	rt_int_cmp-0x4
    32c4:	mov    $0x2,%esi
    32c9:	test   %rax,%rax
    32cc:	cmovl  0x1564(%rip),%rsi        # 4838 <botlish_fn_13+0x3bb8>
    32d4:	jmp    32f2 <botlish_fn_13+0x2672>
    32d9:	mov    $0x2,%esi
    32de:	mov    0x300(%rsp),%rax
    32e6:	cmp    $0x45,%rax
    32ea:	cmovl  0x1546(%rip),%rsi        # 4838 <botlish_fn_13+0x3bb8>
    32f2:	cmp    $0x6,%rsi
    32f6:	je     3397 <botlish_fn_13+0x2717>
    32fc:	mov    0x300(%rsp),%rsi
    3304:	test   $0x1,%rsi
    330b:	jne    3340 <botlish_fn_13+0x26c0>
    3311:	mov    $0x45,%edx
    3316:	mov    0x300(%rsp),%rsi
    331e:	mov    0x2a8(%rsp),%rdi
    3326:	call   332b <botlish_fn_13+0x26ab>
			3327: R_X86_64_PLT32	rt_int_cmp-0x4
    332b:	mov    $0x2,%ecx
    3330:	test   %rax,%rax
    3333:	cmovg  0x14fd(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    333b:	jmp    3359 <botlish_fn_13+0x26d9>
    3340:	mov    $0x2,%ecx
    3345:	mov    0x300(%rsp),%rsi
    334d:	cmp    $0x45,%rsi
    3351:	cmovg  0x14df(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    3359:	cmp    $0x6,%rcx
    335d:	je     3397 <botlish_fn_13+0x2717>
    3363:	mov    0x300(%rsp),%rsi
    336b:	mov    %rsi,%rcx
    336e:	sar    $1,%rcx
    3371:	cmp    $0x22,%rcx
    3375:	jl     3397 <botlish_fn_13+0x2717>
    337b:	cmp    $0x23,%rcx
    337f:	jge    3397 <botlish_fn_13+0x2717>
    3385:	mov    $0x1,%esi
    338a:	mov    %rsi,0x2c8(%rsp)
    3392:	jmp    33a4 <botlish_fn_13+0x2724>
    3397:	mov    $0x4,%esi
    339c:	mov    %rsi,0x2c8(%rsp)
    33a4:	mov    0x2c8(%rsp),%rsi
    33ac:	mov    %rsi,%rdx
    33af:	shl    $1,%rdx
    33b2:	or     $0x1,%rdx
    33b6:	mov    $0x2,%ecx
    33bb:	cmp    $0x5,%rdx
    33bf:	cmovl  0x1471(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    33c7:	cmp    $0x6,%rcx
    33cb:	je     3668 <botlish_fn_13+0x29e8>
    33d1:	mov    0x2c8(%rsp),%rsi
    33d9:	mov    %rsi,%rdx
    33dc:	shl    $1,%rdx
    33df:	or     $0x1,%rdx
    33e3:	mov    $0x2,%ecx
    33e8:	cmp    $0x5,%rdx
    33ec:	cmove  0x1444(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    33f4:	cmp    $0x6,%rcx
    33f8:	je     35b7 <botlish_fn_13+0x2937>
    33fe:	mov    0x2c8(%rsp),%rsi
    3406:	shl    $1,%rsi
    3409:	or     $0x1,%rsi
    340d:	mov    $0x2,%r8d
    3413:	cmp    $0x7,%rsi
    3417:	cmove  0x1419(%rip),%r8        # 4838 <botlish_fn_13+0x3bb8>
    341f:	cmp    $0x6,%r8
    3423:	je     359f <botlish_fn_13+0x291f>
    3429:	mov    0x300(%rsp),%rsi
    3431:	test   $0x1,%rsi
    3438:	jne    3470 <botlish_fn_13+0x27f0>
    343e:	mov    0x328(%rsp),%rdx
    3446:	mov    0x300(%rsp),%rsi
    344e:	mov    0x2a8(%rsp),%rdi
    3456:	call   345b <botlish_fn_13+0x27db>
			3457: R_X86_64_PLT32	rt_int_cmp-0x4
    345b:	mov    $0x2,%ecx
    3460:	test   %rax,%rax
    3463:	cmove  0x13cd(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    346b:	jmp    3489 <botlish_fn_13+0x2809>
    3470:	mov    $0x2,%ecx
    3475:	mov    0x300(%rsp),%rsi
    347d:	cmp    $0xffffffffffffffff,%rsi
    3481:	cmove  0x13af(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    3489:	cmp    $0x6,%rcx
    348d:	je     3525 <botlish_fn_13+0x28a5>
    3493:	mov    0x2a8(%rsp),%rdi
    349b:	mov    0x10(%rdi),%rax
    349f:	mov    0x180(%rax),%rbx
    34a6:	mov    $0x1,%r12d
    34ac:	mov    0x2c8(%rsp),%rsi
    34b4:	shl    $1,%rsi
    34b7:	mov    %rsi,0x2c8(%rsp)
    34bf:	or     $0x1,%rsi
    34c3:	mov    %rsi,0x2c8(%rsp)
    34cb:	call   34d0 <botlish_fn_13+0x2850>
			34cc: R_X86_64_PLT32	botlish_fn_7-0x4
    34d0:	mov    0x2a8(%rsp),%rdi
    34d8:	mov    0x10(%rdi),%rcx
    34dc:	mov    0x178(%rcx),%rdx
    34e3:	lea    0x218(%rsp),%r9
    34eb:	mov    %rbx,0x218(%rsp)
    34f3:	mov    %rax,0x220(%rsp)
    34fb:	mov    0x300(%rsp),%rsi
    3503:	mov    %rsi,0x228(%rsp)
    350b:	mov    $0x6,%ecx
    3510:	mov    %r12,%rsi
    3513:	mov    0x320(%rsp),%r8
    351b:	call   3520 <botlish_fn_13+0x28a0>
			351c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3520:	jmp    399f <botlish_fn_13+0x2d1f>
    3525:	mov    0x2a8(%rsp),%rdi
    352d:	mov    0x10(%rdi),%rax
    3531:	mov    0x180(%rax),%rbx
    3538:	mov    0x2c8(%rsp),%rsi
    3540:	shl    $1,%rsi
    3543:	mov    %rsi,0x2c8(%rsp)
    354b:	or     $0x1,%rsi
    354f:	mov    %rsi,0x2c8(%rsp)
    3557:	call   355c <botlish_fn_13+0x28dc>
			3558: R_X86_64_PLT32	botlish_fn_7-0x4
    355c:	mov    0x2a8(%rsp),%rdi
    3564:	mov    0x10(%rdi),%rcx
    3568:	mov    0x170(%rcx),%rdx
    356f:	lea    0x208(%rsp),%r9
    3577:	mov    %rbx,0x208(%rsp)
    357f:	mov    %rax,0x210(%rsp)
    3587:	mov    $0x2,%r8d
    358d:	mov    $0x5,%ecx
    3592:	mov    %r8,%rsi
    3595:	call   359a <botlish_fn_13+0x291a>
			3596: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    359a:	jmp    399f <botlish_fn_13+0x2d1f>
    359f:	xor    %rbx,%rbx
    35a2:	mov    0x2a8(%rsp),%rdi
    35aa:	mov    %r14,0x2c8(%rsp)
    35b2:	jmp    36e3 <botlish_fn_13+0x2a63>
    35b7:	mov    $0xfffffffffffffffd,%rsi
    35be:	mov    %rsi,0x300(%rsp)
    35c6:	test   $0x1,%rsi
    35cd:	jne    3602 <botlish_fn_13+0x2982>
    35d3:	mov    $0x1,%edx
    35d8:	mov    0x300(%rsp),%rsi
    35e0:	mov    0x2a8(%rsp),%rdi
    35e8:	call   35ed <botlish_fn_13+0x296d>
			35e9: R_X86_64_PLT32	rt_int_cmp-0x4
    35ed:	mov    $0x2,%ecx
    35f2:	test   %rax,%rax
    35f5:	cmovge 0x123b(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    35fd:	jmp    3622 <botlish_fn_13+0x29a2>
    3602:	mov    $0x2,%ecx
    3607:	mov    0x300(%rsp),%rax
    360f:	mov    0x300(%rsp),%rsi
    3617:	test   %rax,%rsi
    361a:	cmovg  0x1216(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    3622:	cmp    $0x6,%rcx
    3626:	je     3636 <botlish_fn_13+0x29b6>
    362c:	mov    $0x1,%ebx
    3631:	jmp    363e <botlish_fn_13+0x29be>
    3636:	mov    0x320(%rsp),%rbx
    363e:	mov    %rbx,0x58(%rsp)
    3643:	mov    0x2c0(%rsp),%rax
    364b:	mov    %rax,0x300(%rsp)
    3653:	mov    %r14,0x2c8(%rsp)
    365b:	mov    0x328(%rsp),%r14
    3663:	jmp    3bcc <botlish_fn_13+0x2f4c>
    3668:	mov    0x2c8(%rsp),%rsi
    3670:	shl    $1,%rsi
    3673:	mov    %rsi,0x2c8(%rsp)
    367b:	or     $0x1,%rsi
    367f:	mov    %rsi,0x2c8(%rsp)
    3687:	mov    %rsi,0x68(%rsp)
    368c:	jmp    3b6e <botlish_fn_13+0x2eee>
    3691:	mov    0x2a8(%rsp),%rdi
    3699:	mov    0x2a8(%rsp),%rdi
    36a1:	mov    0x10(%rdi),%rax
    36a5:	mov    0x150(%rax),%rsi
    36ac:	mov    0x158(%rax),%rdx
    36b3:	call   36b8 <botlish_fn_13+0x2a38>
			36b4: R_X86_64_PLT32	rt_raise-0x4
    36b8:	jmp    399f <botlish_fn_13+0x2d1f>
    36bd:	mov    0x2e8(%rsp),%rsi
    36c5:	mov    %rsi,%rbx
    36c8:	sar    $1,%rbx
    36cb:	mov    0x2a8(%rsp),%rdi
    36d3:	mov    0x300(%rsp),%rax
    36db:	mov    %rax,0x2c0(%rsp)
    36e3:	mov    0x2a8(%rsp),%rdi
    36eb:	mov    0x10(%rdi),%rax
    36ef:	mov    0x160(%rax),%r14
    36f6:	mov    0x300(%rsp),%rsi
    36fe:	test   $0x1,%rsi
    3705:	jne    373d <botlish_fn_13+0x2abd>
    370b:	mov    0x328(%rsp),%rdx
    3713:	mov    0x300(%rsp),%rsi
    371b:	mov    0x2a8(%rsp),%rdi
    3723:	call   3728 <botlish_fn_13+0x2aa8>
			3724: R_X86_64_PLT32	rt_int_cmp-0x4
    3728:	mov    $0x2,%ecx
    372d:	test   %rax,%rax
    3730:	cmovl  0x1100(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    3738:	jmp    3756 <botlish_fn_13+0x2ad6>
    373d:	mov    $0x2,%ecx
    3742:	mov    0x300(%rsp),%rsi
    374a:	cmp    $0xffffffffffffffff,%rsi
    374e:	cmovl  0x10e2(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    3756:	cmp    $0x6,%rcx
    375a:	je     37f8 <botlish_fn_13+0x2b78>
    3760:	mov    0x300(%rsp),%rsi
    3768:	test   $0x1,%rsi
    376f:	jne    37a4 <botlish_fn_13+0x2b24>
    3775:	mov    $0x1ff,%edx
    377a:	mov    0x300(%rsp),%rsi
    3782:	mov    0x2a8(%rsp),%rdi
    378a:	call   378f <botlish_fn_13+0x2b0f>
			378b: R_X86_64_PLT32	rt_int_cmp-0x4
    378f:	mov    $0x2,%esi
    3794:	test   %rax,%rax
    3797:	cmovg  0x1099(%rip),%rsi        # 4838 <botlish_fn_13+0x3bb8>
    379f:	jmp    37bf <botlish_fn_13+0x2b3f>
    37a4:	mov    $0x2,%esi
    37a9:	mov    0x300(%rsp),%rax
    37b1:	cmp    $0x1ff,%rax
    37b7:	cmovg  0x1079(%rip),%rsi        # 4838 <botlish_fn_13+0x3bb8>
    37bf:	cmp    $0x6,%rsi
    37c3:	je     37f8 <botlish_fn_13+0x2b78>
    37c9:	shl    $1,%rbx
    37cc:	or     $0x1,%rbx
    37d0:	sar    $1,%rbx
    37d3:	imul   $0x101,%rbx,%rsi
    37da:	mov    0x300(%rsp),%rax
    37e2:	mov    %rax,%rdi
    37e5:	sar    $1,%rdi
    37e8:	lea    0x1(%rsi,%rdi,1),%rsi
    37ed:	movzbq 0x10(%r14,%rsi,1),%rsi
    37f3:	jmp    380b <botlish_fn_13+0x2b8b>
    37f8:	shl    $1,%rbx
    37fb:	or     $0x1,%rbx
    37ff:	sar    $1,%rbx
    3802:	movzbq 0x616(%r14,%rbx,1),%rsi
    380b:	mov    %rsi,%rdi
    380e:	shl    $1,%rdi
    3811:	or     $0x1,%rdi
    3815:	mov    $0x2,%ecx
    381a:	cmp    $0xd,%rdi
    381e:	cmovl  0x1012(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    3826:	cmp    $0x6,%rcx
    382a:	je     3b97 <botlish_fn_13+0x2f17>
    3830:	mov    %rsi,%r10
    3833:	shl    $1,%r10
    3836:	mov    %rsi,%r14
    3839:	or     $0x1,%r10
    383d:	mov    $0x2,%ecx
    3842:	cmp    $0xd,%r10
    3846:	cmove  0xfea(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    384e:	cmp    $0x6,%rcx
    3852:	je     3b55 <botlish_fn_13+0x2ed5>
    3858:	mov    0x300(%rsp),%rsi
    3860:	test   $0x1,%rsi
    3867:	jne    389f <botlish_fn_13+0x2c1f>
    386d:	mov    0x328(%rsp),%rdx
    3875:	mov    0x300(%rsp),%rsi
    387d:	mov    0x2a8(%rsp),%rdi
    3885:	call   388a <botlish_fn_13+0x2c0a>
			3886: R_X86_64_PLT32	rt_int_cmp-0x4
    388a:	mov    $0x2,%ecx
    388f:	test   %rax,%rax
    3892:	cmove  0xf9e(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    389a:	jmp    38b8 <botlish_fn_13+0x2c38>
    389f:	mov    $0x2,%ecx
    38a4:	mov    0x300(%rsp),%rsi
    38ac:	cmp    $0xffffffffffffffff,%rsi
    38b0:	cmove  0xf80(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    38b8:	cmp    $0x6,%rcx
    38bc:	je     393f <botlish_fn_13+0x2cbf>
    38c2:	mov    0x2a8(%rsp),%rdi
    38ca:	mov    0x10(%rdi),%rax
    38ce:	mov    0x168(%rax),%rbx
    38d5:	mov    $0x1,%r12d
    38db:	mov    %r14,%rsi
    38de:	shl    $1,%rsi
    38e1:	or     $0x1,%rsi
    38e5:	call   38ea <botlish_fn_13+0x2c6a>
			38e6: R_X86_64_PLT32	botlish_fn_5-0x4
    38ea:	mov    0x2a8(%rsp),%rdi
    38f2:	mov    0x10(%rdi),%rcx
    38f6:	mov    0x178(%rcx),%rdx
    38fd:	lea    0x1f0(%rsp),%r9
    3905:	mov    %rbx,0x1f0(%rsp)
    390d:	mov    %rax,0x1f8(%rsp)
    3915:	mov    0x300(%rsp),%rsi
    391d:	mov    %rsi,0x200(%rsp)
    3925:	mov    $0x6,%ecx
    392a:	mov    %r12,%rsi
    392d:	mov    0x320(%rsp),%r8
    3935:	call   393a <botlish_fn_13+0x2cba>
			3936: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    393a:	jmp    399f <botlish_fn_13+0x2d1f>
    393f:	mov    %r14,%rsi
    3942:	mov    0x2a8(%rsp),%rdi
    394a:	mov    0x10(%rdi),%rax
    394e:	mov    0x168(%rax),%rbx
    3955:	shl    $1,%rsi
    3958:	or     $0x1,%rsi
    395c:	call   3961 <botlish_fn_13+0x2ce1>
			395d: R_X86_64_PLT32	botlish_fn_5-0x4
    3961:	mov    0x2a8(%rsp),%rdi
    3969:	mov    0x10(%rdi),%rcx
    396d:	mov    0x170(%rcx),%rdx
    3974:	lea    0x1e0(%rsp),%r9
    397c:	mov    %rbx,0x1e0(%rsp)
    3984:	mov    %rax,0x1e8(%rsp)
    398c:	mov    $0x2,%r8d
    3992:	mov    $0x5,%ecx
    3997:	mov    %r8,%rsi
    399a:	call   399f <botlish_fn_13+0x2d1f>
			399b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    399f:	mov    0x2a8(%rsp),%rdi
    39a7:	call   39ac <botlish_fn_13+0x2d2c>
			39a8: R_X86_64_PLT32	rt_co_failed-0x4
    39ac:	mov    %rax,0x60(%rsp)
    39b1:	mov    %rax,%rsi
    39b4:	mov    0x2a8(%rsp),%rdi
    39bc:	call   39c1 <botlish_fn_13+0x2d41>
			39bd: R_X86_64_PLT32	rt_co_resume0-0x4
    39c1:	test   %rax,%rax
    39c4:	je     39e6 <botlish_fn_13+0x2d66>
    39ca:	mov    0x2a8(%rsp),%rdi
    39d2:	mov    0x10(%rdi),%rax
    39d6:	mov    0x50(%rax),%rsi
    39da:	mov    0x128(%rax),%rdx
    39e1:	call   39e6 <botlish_fn_13+0x2d66>
			39e2: R_X86_64_PLT32	rt_raise-0x4
    39e6:	mov    0x2a8(%rsp),%rdi
    39ee:	call   39f3 <botlish_fn_13+0x2d73>
			39ef: R_X86_64_PLT32	rt_declared_error-0x4
    39f3:	cmp    $0x1,%rax
    39f7:	je     3aa6 <botlish_fn_13+0x2e26>
    39fd:	mov    0x2a8(%rsp),%rdi
    3a05:	call   3a0a <botlish_fn_13+0x2d8a>
			3a06: R_X86_64_PLT32	rt_declared_error-0x4
    3a0a:	cmp    $0x2,%rax
    3a0e:	jne    44db <botlish_fn_13+0x385b>
    3a14:	xor    %rsi,%rsi
    3a17:	mov    0x2a8(%rsp),%rdi
    3a1f:	call   3a24 <botlish_fn_13+0x2da4>
			3a20: R_X86_64_PLT32	rt_declared_payload-0x4
    3a24:	mov    %rax,%rbx
    3a27:	mov    $0x1,%esi
    3a2c:	mov    0x2a8(%rsp),%rdi
    3a34:	call   3a39 <botlish_fn_13+0x2db9>
			3a35: R_X86_64_PLT32	rt_declared_payload-0x4
    3a39:	mov    %rax,%r12
    3a3c:	mov    0x2a8(%rsp),%rdi
    3a44:	call   3a49 <botlish_fn_13+0x2dc9>
			3a45: R_X86_64_PLT32	rt_clear_declared_error-0x4
    3a49:	mov    0x2a8(%rsp),%rdi
    3a51:	mov    0x10(%rdi),%rax
    3a55:	mov    0x138(%rax),%rdx
    3a5c:	lea    0xf0(%rsp),%r9
    3a64:	mov    0x308(%rsp),%rcx
    3a6c:	mov    %rcx,0xf0(%rsp)
    3a74:	mov    %rbx,%rax
    3a77:	mov    %rax,0xf8(%rsp)
    3a7f:	mov    %r12,%rax
    3a82:	mov    %rax,0x100(%rsp)
    3a8a:	mov    $0x5,%esi
    3a8f:	mov    $0x2,%ecx
    3a94:	mov    0x320(%rsp),%r8
    3a9c:	call   3aa1 <botlish_fn_13+0x2e21>
			3a9d: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3aa1:	jmp    44db <botlish_fn_13+0x385b>
    3aa6:	xor    %rsi,%rsi
    3aa9:	mov    0x2a8(%rsp),%rdi
    3ab1:	call   3ab6 <botlish_fn_13+0x2e36>
			3ab2: R_X86_64_PLT32	rt_declared_payload-0x4
    3ab6:	mov    %rax,%r12
    3ab9:	mov    $0x1,%ebx
    3abe:	mov    %rbx,%rsi
    3ac1:	mov    0x2a8(%rsp),%rdi
    3ac9:	call   3ace <botlish_fn_13+0x2e4e>
			3aca: R_X86_64_PLT32	rt_declared_payload-0x4
    3ace:	mov    %rax,%r13
    3ad1:	mov    $0x2,%esi
    3ad6:	mov    0x2a8(%rsp),%rdi
    3ade:	call   3ae3 <botlish_fn_13+0x2e63>
			3adf: R_X86_64_PLT32	rt_declared_payload-0x4
    3ae3:	mov    %rax,%r14
    3ae6:	mov    0x2a8(%rsp),%rdi
    3aee:	call   3af3 <botlish_fn_13+0x2e73>
			3aef: R_X86_64_PLT32	rt_clear_declared_error-0x4
    3af3:	mov    0x2a8(%rsp),%rdi
    3afb:	mov    0x10(%rdi),%rax
    3aff:	mov    0x130(%rax),%rdx
    3b06:	lea    0xd0(%rsp),%r9
    3b0e:	mov    0x308(%rsp),%rcx
    3b16:	mov    %rcx,0xd0(%rsp)
    3b1e:	mov    %r12,%rax
    3b21:	mov    %rax,0xd8(%rsp)
    3b29:	mov    %r13,%rax
    3b2c:	mov    %rax,0xe0(%rsp)
    3b34:	mov    %r14,%rax
    3b37:	mov    %rax,0xe8(%rsp)
    3b3f:	mov    $0x4,%r8d
    3b45:	mov    %rbx,%rcx
    3b48:	mov    %r8,%rsi
    3b4b:	call   3b50 <botlish_fn_13+0x2ed0>
			3b4c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3b50:	jmp    44db <botlish_fn_13+0x385b>
    3b55:	movq   $0x3,0x68(%rsp)
    3b5e:	mov    0x320(%rsp),%rax
    3b66:	mov    %rax,0x2c8(%rsp)
    3b6e:	mov    $0x1,%ebx
    3b73:	movq   $0x1,0x58(%rsp)
    3b7c:	mov    $0x2,%r14d
    3b82:	mov    0x2c0(%rsp),%rax
    3b8a:	mov    %rax,0x300(%rsp)
    3b92:	jmp    3bcc <botlish_fn_13+0x2f4c>
    3b97:	shl    $1,%rsi
    3b9a:	or     $0x1,%rsi
    3b9e:	mov    %rsi,0x70(%rsp)
    3ba3:	mov    $0x1,%ebx
    3ba8:	movq   $0x1,0x58(%rsp)
    3bb1:	mov    %rbx,%r14
    3bb4:	mov    %rsi,0x2e8(%rsp)
    3bbc:	mov    0x2c0(%rsp),%rax
    3bc4:	mov    %rax,0x300(%rsp)
    3bcc:	mov    0x338(%rsp),%rcx
    3bd4:	mov    0x18(%rcx),%rax
    3bd8:	test   %rax,%rax
    3bdb:	je     4764 <botlish_fn_13+0x3ae4>
    3be1:	mov    0x338(%rsp),%rcx
    3be9:	mov    0x10(%rcx),%rsi
    3bed:	mov    %rbx,0x18(%rsi)
    3bf1:	jmp    23b6 <botlish_fn_13+0x1736>
    3bf6:	mov    0x2a8(%rsp),%rdi
    3bfe:	mov    0x10(%rdi),%rdi
    3c02:	mov    0x140(%rdi),%rdx
    3c09:	lea    0xc0(%rsp),%r9
    3c11:	mov    0x318(%rsp),%rsi
    3c19:	mov    %rsi,0xc0(%rsp)
    3c21:	mov    0x2b8(%rsp),%rax
    3c29:	mov    %rax,0xc8(%rsp)
    3c31:	mov    $0x2,%r8d
    3c37:	mov    0x320(%rsp),%rcx
    3c3f:	mov    0x330(%rsp),%rsi
    3c47:	mov    0x2a8(%rsp),%rdi
    3c4f:	call   3c54 <botlish_fn_13+0x2fd4>
			3c50: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3c54:	jmp    44db <botlish_fn_13+0x385b>
    3c59:	mov    0x338(%rsp),%rcx
    3c61:	mov    0x10(%rcx),%r11
    3c65:	mov    0x18(%r11),%rsi
    3c69:	test   $0x1,%rsi
    3c70:	jne    3c9d <botlish_fn_13+0x301d>
    3c76:	mov    $0x1,%edx
    3c7b:	mov    0x2a8(%rsp),%rdi
    3c83:	call   3c88 <botlish_fn_13+0x3008>
			3c84: R_X86_64_PLT32	rt_int_cmp-0x4
    3c88:	mov    $0x2,%ecx
    3c8d:	test   %rax,%rax
    3c90:	cmove  0xba0(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    3c98:	jmp    3cae <botlish_fn_13+0x302e>
    3c9d:	mov    $0x2,%ecx
    3ca2:	cmp    $0x1,%rsi
    3ca6:	cmove  0xb8a(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    3cae:	cmp    $0x6,%rcx
    3cb2:	je     3cc5 <botlish_fn_13+0x3045>
    3cb8:	mov    0x2d0(%rsp),%rbx
    3cc0:	jmp    413a <botlish_fn_13+0x34ba>
    3cc5:	mov    0x338(%rsp),%rcx
    3ccd:	mov    0x10(%rcx),%rax
    3cd1:	mov    0x8(%rax),%rsi
    3cd5:	test   $0x1,%rsi
    3cdc:	jne    3d0c <botlish_fn_13+0x308c>
    3ce2:	mov    0x328(%rsp),%rdx
    3cea:	mov    0x2a8(%rsp),%rdi
    3cf2:	call   3cf7 <botlish_fn_13+0x3077>
			3cf3: R_X86_64_PLT32	rt_int_cmp-0x4
    3cf7:	mov    $0x2,%ecx
    3cfc:	test   %rax,%rax
    3cff:	cmove  0xb31(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    3d07:	jmp    3d1d <botlish_fn_13+0x309d>
    3d0c:	mov    $0x2,%ecx
    3d11:	cmp    $0xffffffffffffffff,%rsi
    3d15:	cmove  0xb1b(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    3d1d:	cmp    $0x6,%rcx
    3d21:	jne    3d34 <botlish_fn_13+0x30b4>
    3d27:	mov    0x2d0(%rsp),%rbx
    3d2f:	jmp    413a <botlish_fn_13+0x34ba>
    3d34:	movq   $0x1,0x8(%rsp)
    3d3d:	mov    0x338(%rsp),%rcx
    3d45:	mov    0x10(%rcx),%rax
    3d49:	mov    (%rax),%rsi
    3d4c:	mov    %rsi,0x18(%rsp)
    3d51:	movq   $0x3,0x20(%rsp)
    3d5a:	test   $0x1,%rsi
    3d61:	je     3d86 <botlish_fn_13+0x3106>
    3d67:	mov    %rsi,%rcx
    3d6a:	add    $0x2,%rcx
    3d6e:	seto   %al
    3d71:	test   %al,%al
    3d73:	jne    3d86 <botlish_fn_13+0x3106>
    3d79:	mov    0x338(%rsp),%rax
    3d81:	jmp    3da6 <botlish_fn_13+0x3126>
    3d86:	mov    0x320(%rsp),%rdx
    3d8e:	mov    0x2a8(%rsp),%rdi
    3d96:	call   3d9b <botlish_fn_13+0x311b>
			3d97: R_X86_64_PLT32	rt_int_add-0x4
    3d9b:	mov    %rax,%rcx
    3d9e:	mov    0x338(%rsp),%rax
    3da6:	mov    0x338(%rsp),%rax
    3dae:	mov    0x18(%rax),%rax
    3db2:	test   %rax,%rax
    3db5:	je     4786 <botlish_fn_13+0x3b06>
    3dbb:	mov    0x338(%rsp),%rax
    3dc3:	mov    0x10(%rax),%rax
    3dc7:	mov    %rcx,(%rax)
    3dca:	movq   $0x3,0x8(%rsp)
    3dd3:	mov    0x2d0(%rsp),%rbx
    3ddb:	cmp    $0x1,%rbx
    3ddf:	je     3df9 <botlish_fn_13+0x3179>
    3de5:	mov    $0xa,%esi
    3dea:	cmp    $0xffffffffffffffff,%rbx
    3dee:	je     410d <botlish_fn_13+0x348d>
    3df4:	jmp    3f9a <botlish_fn_13+0x331a>
    3df9:	add    $0x1,%r15
    3e00:	cmp    %r13,%r15
    3e03:	jl     4060 <botlish_fn_13+0x33e0>
    3e09:	movq   $0x3,0x20(%rsp)
    3e12:	mov    0x2e0(%rsp),%rsi
    3e1a:	test   $0x1,%rsi
    3e21:	jne    3e34 <botlish_fn_13+0x31b4>
    3e27:	mov    0x2e0(%rsp),%rsi
    3e2f:	jmp    3e67 <botlish_fn_13+0x31e7>
    3e34:	mov    0x2e0(%rsp),%rsi
    3e3c:	add    $0x2,%rsi
    3e40:	seto   %dil
    3e44:	test   %dil,%dil
    3e47:	je     3e5a <botlish_fn_13+0x31da>
    3e4d:	mov    0x2e0(%rsp),%rsi
    3e55:	jmp    3e67 <botlish_fn_13+0x31e7>
    3e5a:	mov    %rsi,0x2e0(%rsp)
    3e62:	jmp    3e87 <botlish_fn_13+0x3207>
    3e67:	mov    0x320(%rsp),%rdx
    3e6f:	mov    0x2a8(%rsp),%rdi
    3e77:	call   3e7c <botlish_fn_13+0x31fc>
			3e78: R_X86_64_PLT32	rt_int_add-0x4
    3e7c:	mov    %rax,%rsi
    3e7f:	mov    %rax,0x2e0(%rsp)
    3e87:	mov    %rsi,0x48(%rsp)
    3e8c:	mov    0x2e0(%rsp),%rsi
    3e94:	mov    %rsi,%r11
    3e97:	and    %r12,%r11
    3e9a:	test   $0x1,%r11
    3ea1:	jne    3ed4 <botlish_fn_13+0x3254>
    3ea7:	mov    %r12,%rdx
    3eaa:	mov    0x2e0(%rsp),%rsi
    3eb2:	mov    0x2a8(%rsp),%rdi
    3eba:	call   3ebf <botlish_fn_13+0x323f>
			3ebb: R_X86_64_PLT32	rt_int_cmp-0x4
    3ebf:	mov    $0x2,%ecx
    3ec4:	test   %rax,%rax
    3ec7:	cmovl  0x969(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    3ecf:	jmp    3eec <botlish_fn_13+0x326c>
    3ed4:	mov    $0x2,%ecx
    3ed9:	mov    0x2e0(%rsp),%rsi
    3ee1:	cmp    %r12,%rsi
    3ee4:	cmovl  0x94c(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    3eec:	cmp    $0x6,%rcx
    3ef0:	je     3f1c <botlish_fn_13+0x329c>
    3ef6:	movq   $0xffffffffffffffff,0x28(%rsp)
    3eff:	mov    0x328(%rsp),%rbx
    3f07:	mov    0x328(%rsp),%rax
    3f0f:	mov    %rax,0x300(%rsp)
    3f17:	jmp    410d <botlish_fn_13+0x348d>
    3f1c:	mov    0x2e0(%rsp),%rsi
    3f24:	test   $0x1,%rsi
    3f2b:	je     3f54 <botlish_fn_13+0x32d4>
    3f31:	mov    0x2b0(%rsp),%r14
    3f39:	mov    0x8(%r14),%rcx
    3f3d:	mov    0x2e0(%rsp),%rsi
    3f45:	mov    %rsi,%rax
    3f48:	sar    $1,%rax
    3f4b:	cmp    %rcx,%rax
    3f4e:	jb     4025 <botlish_fn_13+0x33a5>
    3f54:	mov    0x2e0(%rsp),%rdx
    3f5c:	mov    0x2b0(%rsp),%rsi
    3f64:	mov    0x2a8(%rsp),%rdi
    3f6c:	call   3f71 <botlish_fn_13+0x32f1>
			3f6d: R_X86_64_PLT32	rt_list_get-0x4
    3f71:	mov    %rax,%r8
    3f74:	mov    %rax,0x2d8(%rsp)
    3f7c:	test   %r8,%rax
    3f7f:	jne    4018 <botlish_fn_13+0x3398>
    3f85:	mov    0x2a8(%rsp),%rdi
    3f8d:	call   3f92 <botlish_fn_13+0x3312>
			3f8e: R_X86_64_PLT32	rt_co_failed-0x4
    3f92:	mov    %rax,0x30(%rsp)
    3f97:	mov    %rax,%rsi
    3f9a:	mov    0x2a8(%rsp),%rdi
    3fa2:	call   3fa7 <botlish_fn_13+0x3327>
			3fa3: R_X86_64_PLT32	rt_co_resume0-0x4
    3fa7:	test   %rax,%rax
    3faa:	je     3fcc <botlish_fn_13+0x334c>
    3fb0:	mov    0x2a8(%rsp),%rdi
    3fb8:	mov    0x10(%rdi),%rax
    3fbc:	mov    0x50(%rax),%rsi
    3fc0:	mov    0x128(%rax),%rdx
    3fc7:	call   3fcc <botlish_fn_13+0x334c>
			3fc8: R_X86_64_PLT32	rt_raise-0x4
    3fcc:	mov    0x2a8(%rsp),%rdi
    3fd4:	call   3fd9 <botlish_fn_13+0x3359>
			3fd5: R_X86_64_PLT32	rt_declared_error-0x4
    3fd9:	cmp    $0x40000001,%rax
    3fdf:	je     3ff2 <botlish_fn_13+0x3372>
    3fe5:	mov    0x2a8(%rsp),%rdi
    3fed:	jmp    3ffa <botlish_fn_13+0x337a>
    3ff2:	mov    0x2a8(%rsp),%rdi
    3ffa:	mov    0x2a8(%rsp),%rdi
    4002:	call   4007 <botlish_fn_13+0x3387>
			4003: R_X86_64_PLT32	rt_declared_error-0x4
    4007:	cmp    $0x40000001,%rax
    400d:	jne    44db <botlish_fn_13+0x385b>
    4013:	jmp    44db <botlish_fn_13+0x385b>
    4018:	mov    0x2d8(%rsp),%rax
    4020:	jmp    403d <botlish_fn_13+0x33bd>
    4025:	mov    0x2b0(%rsp),%r14
    402d:	mov    0x10(%r14),%rcx
    4031:	mov    (%rcx,%rax,8),%rax
    4035:	mov    %rax,0x2d8(%rsp)
    403d:	mov    %rax,0x50(%rsp)
    4042:	mov    0x2d8(%rsp),%rax
    404a:	mov    0x8(%rax),%r13
    404e:	xor    %r15,%r15
    4051:	shl    $1,%r13
    4054:	or     $0x1,%r13
    4058:	sar    $1,%r13
    405b:	jmp    3e00 <botlish_fn_13+0x3180>
    4060:	mov    0x2d8(%rsp),%rax
    4068:	movzbq 0x18(%rax),%rax
    406d:	test   %rax,%rax
    4070:	jne    40a5 <botlish_fn_13+0x3425>
    4076:	mov    %r15,%rdx
    4079:	shl    $1,%rdx
    407c:	or     $0x1,%rdx
    4080:	mov    0x2d8(%rsp),%rsi
    4088:	mov    0x2a8(%rsp),%rdi
    4090:	call   4095 <botlish_fn_13+0x3415>
			4091: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    4095:	mov    %rax,%rsi
    4098:	mov    %rax,0x300(%rsp)
    40a0:	jmp    40e0 <botlish_fn_13+0x3460>
    40a5:	mov    %r15,%rcx
    40a8:	shl    $1,%rcx
    40ab:	or     $0x1,%rcx
    40af:	sar    $1,%rcx
    40b2:	mov    0x2d8(%rsp),%rax
    40ba:	movzbq 0x19(%rax,%rcx,1),%rsi
    40c0:	mov    %rsi,0x300(%rsp)
    40c8:	shl    $0x3,%rsi
    40cc:	mov    %rsi,0x300(%rsp)
    40d4:	or     $0x4,%rsi
    40d8:	mov    %rsi,0x300(%rsp)
    40e0:	shr    $0x3,%rsi
    40e4:	mov    %rsi,0x300(%rsp)
    40ec:	mov    $0x1,%ebx
    40f1:	shl    $1,%rsi
    40f4:	mov    %rsi,0x300(%rsp)
    40fc:	or     $0x1,%rsi
    4100:	mov    %rsi,0x300(%rsp)
    4108:	mov    %rsi,0x28(%rsp)
    410d:	mov    0x338(%rsp),%rcx
    4115:	mov    0x18(%rcx),%rax
    4119:	test   %rax,%rax
    411c:	je     47a5 <botlish_fn_13+0x3b25>
    4122:	mov    0x338(%rsp),%rcx
    412a:	mov    0x10(%rcx),%rax
    412e:	mov    0x300(%rsp),%rsi
    4136:	mov    %rsi,0x8(%rax)
    413a:	movq   $0x5,0x8(%rsp)
    4143:	mov    0x338(%rsp),%rcx
    414b:	mov    0x10(%rcx),%rdx
    414f:	mov    0x10(%rdx),%rsi
    4153:	mov    %rsi,0x18(%rsp)
    4158:	movq   $0x3,0x20(%rsp)
    4161:	test   $0x1,%rsi
    4168:	je     418f <botlish_fn_13+0x350f>
    416e:	mov    %rsi,%rcx
    4171:	add    $0x2,%rcx
    4175:	seto   %r9b
    4179:	test   %r9b,%r9b
    417c:	jne    418f <botlish_fn_13+0x350f>
    4182:	mov    0x338(%rsp),%rax
    418a:	jmp    41af <botlish_fn_13+0x352f>
    418f:	mov    0x320(%rsp),%rdx
    4197:	mov    0x2a8(%rsp),%rdi
    419f:	call   41a4 <botlish_fn_13+0x3524>
			41a0: R_X86_64_PLT32	rt_int_add-0x4
    41a4:	mov    %rax,%rcx
    41a7:	mov    0x338(%rsp),%rax
    41af:	mov    0x338(%rsp),%rax
    41b7:	mov    0x18(%rax),%rax
    41bb:	test   %rax,%rax
    41be:	je     47cf <botlish_fn_13+0x3b4f>
    41c4:	mov    0x338(%rsp),%rdx
    41cc:	mov    0x10(%rdx),%rax
    41d0:	mov    %rcx,0x10(%rax)
    41d4:	mov    0x338(%rsp),%rcx
    41dc:	mov    %rbx,0x2d0(%rsp)
    41e4:	jmp    10f4 <botlish_fn_13+0x474>
    41e9:	mov    0x2d0(%rsp),%rbx
    41f1:	movq   $0x1,0x18(%rsp)
    41fa:	movq   $0x3,0x20(%rsp)
    4203:	mov    0x318(%rsp),%rsi
    420b:	test   $0x1,%rsi
    4212:	jne    4225 <botlish_fn_13+0x35a5>
    4218:	mov    0x318(%rsp),%rsi
    4220:	jmp    4259 <botlish_fn_13+0x35d9>
    4225:	mov    0x318(%rsp),%rsi
    422d:	mov    %rsi,%rcx
    4230:	add    $0x2,%rcx
    4234:	seto   %al
    4237:	test   %al,%al
    4239:	je     424c <botlish_fn_13+0x35cc>
    423f:	mov    0x318(%rsp),%rsi
    4247:	jmp    4259 <botlish_fn_13+0x35d9>
    424c:	mov    0x338(%rsp),%rax
    4254:	jmp    4279 <botlish_fn_13+0x35f9>
    4259:	mov    0x320(%rsp),%rdx
    4261:	mov    0x2a8(%rsp),%rdi
    4269:	call   426e <botlish_fn_13+0x35ee>
			426a: R_X86_64_PLT32	rt_int_add-0x4
    426e:	mov    %rax,%rcx
    4271:	mov    0x338(%rsp),%rax
    4279:	mov    0x338(%rsp),%rax
    4281:	mov    0x18(%rax),%rax
    4285:	test   %rax,%rax
    4288:	je     47ee <botlish_fn_13+0x3b6e>
    428e:	mov    0x338(%rsp),%rax
    4296:	mov    0x10(%rax),%rax
    429a:	mov    %rcx,(%rax)
    429d:	movq   $0x3,0x8(%rsp)
    42a6:	cmp    $0x1,%rbx
    42aa:	je     42c4 <botlish_fn_13+0x3644>
    42b0:	mov    $0xa,%esi
    42b5:	cmp    $0xffffffffffffffff,%rbx
    42b9:	je     4607 <botlish_fn_13+0x3987>
    42bf:	jmp    4468 <botlish_fn_13+0x37e8>
    42c4:	add    $0x1,%r15
    42cb:	cmp    %r13,%r15
    42ce:	jl     455a <botlish_fn_13+0x38da>
    42d4:	movq   $0x3,0x20(%rsp)
    42dd:	mov    0x2e0(%rsp),%rsi
    42e5:	test   $0x1,%rsi
    42ec:	jne    42ff <botlish_fn_13+0x367f>
    42f2:	mov    0x2e0(%rsp),%rsi
    42fa:	jmp    4336 <botlish_fn_13+0x36b6>
    42ff:	mov    0x2e0(%rsp),%rsi
    4307:	mov    %rsi,%rcx
    430a:	add    $0x2,%rcx
    430e:	seto   %al
    4311:	test   %al,%al
    4313:	je     4326 <botlish_fn_13+0x36a6>
    4319:	mov    0x2e0(%rsp),%rsi
    4321:	jmp    4336 <botlish_fn_13+0x36b6>
    4326:	mov    %rcx,%rsi
    4329:	mov    %rcx,0x2e0(%rsp)
    4331:	jmp    4356 <botlish_fn_13+0x36d6>
    4336:	mov    0x320(%rsp),%rdx
    433e:	mov    0x2a8(%rsp),%rdi
    4346:	call   434b <botlish_fn_13+0x36cb>
			4347: R_X86_64_PLT32	rt_int_add-0x4
    434b:	mov    %rax,%rsi
    434e:	mov    %rax,0x2e0(%rsp)
    4356:	mov    %rsi,0x48(%rsp)
    435b:	mov    0x2e0(%rsp),%rsi
    4363:	mov    %rsi,%rax
    4366:	and    %r12,%rax
    4369:	test   $0x1,%rax
    436f:	jne    43a2 <botlish_fn_13+0x3722>
    4375:	mov    %r12,%rdx
    4378:	mov    0x2e0(%rsp),%rsi
    4380:	mov    0x2a8(%rsp),%rdi
    4388:	call   438d <botlish_fn_13+0x370d>
			4389: R_X86_64_PLT32	rt_int_cmp-0x4
    438d:	mov    $0x2,%ecx
    4392:	test   %rax,%rax
    4395:	cmovl  0x49b(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    439d:	jmp    43ba <botlish_fn_13+0x373a>
    43a2:	mov    $0x2,%ecx
    43a7:	mov    0x2e0(%rsp),%rsi
    43af:	cmp    %r12,%rsi
    43b2:	cmovl  0x47e(%rip),%rcx        # 4838 <botlish_fn_13+0x3bb8>
    43ba:	cmp    $0x6,%rcx
    43be:	je     43ea <botlish_fn_13+0x376a>
    43c4:	movq   $0xffffffffffffffff,0x28(%rsp)
    43cd:	mov    0x328(%rsp),%rbx
    43d5:	mov    0x328(%rsp),%rax
    43dd:	mov    %rax,0x300(%rsp)
    43e5:	jmp    4607 <botlish_fn_13+0x3987>
    43ea:	mov    0x2e0(%rsp),%rsi
    43f2:	test   $0x1,%rsi
    43f9:	je     4422 <botlish_fn_13+0x37a2>
    43ff:	mov    0x2b0(%rsp),%r14
    4407:	mov    0x8(%r14),%rcx
    440b:	mov    0x2e0(%rsp),%rsi
    4413:	mov    %rsi,%rax
    4416:	sar    $1,%rax
    4419:	cmp    %rcx,%rax
    441c:	jb     451f <botlish_fn_13+0x389f>
    4422:	mov    0x2e0(%rsp),%rdx
    442a:	mov    0x2b0(%rsp),%rsi
    4432:	mov    0x2a8(%rsp),%rdi
    443a:	call   443f <botlish_fn_13+0x37bf>
			443b: R_X86_64_PLT32	rt_list_get-0x4
    443f:	mov    %rax,%rsi
    4442:	mov    %rax,0x2d8(%rsp)
    444a:	test   %rsi,%rax
    444d:	jne    4512 <botlish_fn_13+0x3892>
    4453:	mov    0x2a8(%rsp),%rdi
    445b:	call   4460 <botlish_fn_13+0x37e0>
			445c: R_X86_64_PLT32	rt_co_failed-0x4
    4460:	mov    %rax,0x30(%rsp)
    4465:	mov    %rax,%rsi
    4468:	mov    0x2a8(%rsp),%rdi
    4470:	call   4475 <botlish_fn_13+0x37f5>
			4471: R_X86_64_PLT32	rt_co_resume0-0x4
    4475:	test   %rax,%rax
    4478:	je     449a <botlish_fn_13+0x381a>
    447e:	mov    0x2a8(%rsp),%rdi
    4486:	mov    0x10(%rdi),%rax
    448a:	mov    0x50(%rax),%rsi
    448e:	mov    0x128(%rax),%rdx
    4495:	call   449a <botlish_fn_13+0x381a>
			4496: R_X86_64_PLT32	rt_raise-0x4
    449a:	mov    0x2a8(%rsp),%rdi
    44a2:	call   44a7 <botlish_fn_13+0x3827>
			44a3: R_X86_64_PLT32	rt_declared_error-0x4
    44a7:	cmp    $0x40000001,%rax
    44ad:	je     44c0 <botlish_fn_13+0x3840>
    44b3:	mov    0x2a8(%rsp),%rdi
    44bb:	jmp    44c8 <botlish_fn_13+0x3848>
    44c0:	mov    0x2a8(%rsp),%rdi
    44c8:	mov    0x2a8(%rsp),%rdi
    44d0:	call   44d5 <botlish_fn_13+0x3855>
			44d1: R_X86_64_PLT32	rt_declared_error-0x4
    44d5:	cmp    $0x40000001,%rax
    44db:	xor    %rax,%rax
    44de:	mov    0x340(%rsp),%rbx
    44e6:	mov    0x348(%rsp),%r12
    44ee:	mov    0x350(%rsp),%r13
    44f6:	mov    0x358(%rsp),%r14
    44fe:	mov    0x360(%rsp),%r15
    4506:	add    $0x370,%rsp
    450d:	mov    %rbp,%rsp
    4510:	pop    %rbp
    4511:	ret
    4512:	mov    0x2d8(%rsp),%rax
    451a:	jmp    4537 <botlish_fn_13+0x38b7>
    451f:	mov    0x2b0(%rsp),%r14
    4527:	mov    0x10(%r14),%rcx
    452b:	mov    (%rcx,%rax,8),%rax
    452f:	mov    %rax,0x2d8(%rsp)
    4537:	mov    %rax,0x50(%rsp)
    453c:	mov    0x2d8(%rsp),%rax
    4544:	mov    0x8(%rax),%r13
    4548:	xor    %r15,%r15
    454b:	shl    $1,%r13
    454e:	or     $0x1,%r13
    4552:	sar    $1,%r13
    4555:	jmp    42cb <botlish_fn_13+0x364b>
    455a:	mov    0x2d8(%rsp),%rax
    4562:	movzbq 0x18(%rax),%rax
    4567:	test   %rax,%rax
    456a:	jne    459f <botlish_fn_13+0x391f>
    4570:	mov    %r15,%rdx
    4573:	shl    $1,%rdx
    4576:	or     $0x1,%rdx
    457a:	mov    0x2d8(%rsp),%rsi
    4582:	mov    0x2a8(%rsp),%rdi
    458a:	call   458f <botlish_fn_13+0x390f>
			458b: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    458f:	mov    %rax,%rsi
    4592:	mov    %rax,0x300(%rsp)
    459a:	jmp    45da <botlish_fn_13+0x395a>
    459f:	mov    %r15,%rcx
    45a2:	shl    $1,%rcx
    45a5:	or     $0x1,%rcx
    45a9:	sar    $1,%rcx
    45ac:	mov    0x2d8(%rsp),%rax
    45b4:	movzbq 0x19(%rax,%rcx,1),%rsi
    45ba:	mov    %rsi,0x300(%rsp)
    45c2:	shl    $0x3,%rsi
    45c6:	mov    %rsi,0x300(%rsp)
    45ce:	or     $0x4,%rsi
    45d2:	mov    %rsi,0x300(%rsp)
    45da:	shr    $0x3,%rsi
    45de:	mov    %rsi,0x300(%rsp)
    45e6:	mov    $0x1,%ebx
    45eb:	shl    $1,%rsi
    45ee:	mov    %rsi,0x300(%rsp)
    45f6:	or     $0x1,%rsi
    45fa:	mov    %rsi,0x300(%rsp)
    4602:	mov    %rsi,0x28(%rsp)
    4607:	mov    0x338(%rsp),%rcx
    460f:	mov    0x18(%rcx),%rax
    4613:	test   %rax,%rax
    4616:	je     480d <botlish_fn_13+0x3b8d>
    461c:	mov    0x338(%rsp),%rcx
    4624:	mov    0x10(%rcx),%rax
    4628:	mov    0x300(%rsp),%rsi
    4630:	mov    %rsi,0x8(%rax)
    4634:	mov    0x338(%rsp),%rcx
    463c:	mov    %rbx,0x2d0(%rsp)
    4644:	jmp    10f4 <botlish_fn_13+0x474>
    4649:	mov    0x338(%rsp),%rcx
    4651:	mov    0x10(%rcx),%rax
    4655:	mov    0x10(%rax),%rax
    4659:	mov    %rax,(%rsp)
    465d:	mov    0x10(%rcx),%rcx
    4661:	mov    (%rcx),%rdx
    4664:	mov    %rdx,0x8(%rsp)
    4669:	lea    0x108(%rsp),%rcx
    4671:	mov    %rax,0x108(%rsp)
    4679:	mov    %rdx,0x110(%rsp)
    4681:	xor    %rsi,%rsi
    4684:	mov    $0x2,%edx
    4689:	mov    0x2a8(%rsp),%rdi
    4691:	call   4696 <botlish_fn_13+0x3a16>
			4692: R_X86_64_PLT32	rt_struct_new-0x4
    4696:	mov    0x340(%rsp),%rbx
    469e:	mov    0x348(%rsp),%r12
    46a6:	mov    0x350(%rsp),%r13
    46ae:	mov    0x358(%rsp),%r14
    46b6:	mov    0x360(%rsp),%r15
    46be:	add    $0x370,%rsp
    46c5:	mov    %rbp,%rsp
    46c8:	pop    %rbp
    46c9:	ret
    46ca:	mov    $0x3,%edx
    46cf:	mov    0x300(%rsp),%rcx
    46d7:	mov    0x338(%rsp),%rsi
    46df:	mov    0x2a8(%rsp),%rdi
    46e7:	call   46ec <botlish_fn_13+0x3a6c>
			46e8: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    46ec:	jmp    10c2 <botlish_fn_13+0x442>
    46f1:	mov    $0x7,%edx
    46f6:	mov    %rbx,%rcx
    46f9:	mov    0x338(%rsp),%rsi
    4701:	mov    0x2a8(%rsp),%rdi
    4709:	call   470e <botlish_fn_13+0x3a8e>
			470a: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    470e:	jmp    23b6 <botlish_fn_13+0x1736>
    4713:	mov    $0x1,%edx
    4718:	mov    0x308(%rsp),%rcx
    4720:	mov    0x338(%rsp),%rsi
    4728:	mov    0x2a8(%rsp),%rdi
    4730:	call   4735 <botlish_fn_13+0x3ab5>
			4731: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    4735:	jmp    2468 <botlish_fn_13+0x17e8>
    473a:	mov    0x300(%rsp),%rcx
    4742:	mov    0x320(%rsp),%rdx
    474a:	mov    0x338(%rsp),%rsi
    4752:	mov    0x2a8(%rsp),%rdi
    475a:	call   475f <botlish_fn_13+0x3adf>
			475b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    475f:	jmp    27e9 <botlish_fn_13+0x1b69>
    4764:	mov    $0x7,%edx
    4769:	mov    %rbx,%rcx
    476c:	mov    0x338(%rsp),%rsi
    4774:	mov    0x2a8(%rsp),%rdi
    477c:	call   4781 <botlish_fn_13+0x3b01>
			477d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    4781:	jmp    23b6 <botlish_fn_13+0x1736>
    4786:	mov    $0x1,%edx
    478b:	mov    0x338(%rsp),%rsi
    4793:	mov    0x2a8(%rsp),%rdi
    479b:	call   47a0 <botlish_fn_13+0x3b20>
			479c: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    47a0:	jmp    3dca <botlish_fn_13+0x314a>
    47a5:	mov    0x300(%rsp),%rcx
    47ad:	mov    0x320(%rsp),%rdx
    47b5:	mov    0x338(%rsp),%rsi
    47bd:	mov    0x2a8(%rsp),%rdi
    47c5:	call   47ca <botlish_fn_13+0x3b4a>
			47c6: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    47ca:	jmp    413a <botlish_fn_13+0x34ba>
    47cf:	mov    $0x5,%edx
    47d4:	mov    0x338(%rsp),%rsi
    47dc:	mov    0x2a8(%rsp),%rdi
    47e4:	call   47e9 <botlish_fn_13+0x3b69>
			47e5: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    47e9:	jmp    41d4 <botlish_fn_13+0x3554>
    47ee:	mov    $0x1,%edx
    47f3:	mov    0x338(%rsp),%rsi
    47fb:	mov    0x2a8(%rsp),%rdi
    4803:	call   4808 <botlish_fn_13+0x3b88>
			4804: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    4808:	jmp    429d <botlish_fn_13+0x361d>
    480d:	mov    0x300(%rsp),%rcx
    4815:	mov    0x320(%rsp),%rdx
    481d:	mov    0x338(%rsp),%rsi
    4825:	mov    0x2a8(%rsp),%rdi
    482d:	call   4832 <botlish_fn_13+0x3bb2>
			482e: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    4832:	jmp    4634 <botlish_fn_13+0x39b4>
    4837:	add    %al,(%rsi)
    4839:	add    %al,(%rax)
    483b:	add    %al,(%rax)
    483d:	add    %al,(%rax)
	...

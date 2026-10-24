<botlish_fn_3>:
     e90:	push   %rbp
     e91:	mov    %rsp,%rbp
     e94:	sub    $0xf0,%rsp
     e9b:	mov    %rbx,0xc0(%rsp)
     ea3:	mov    %r12,0xc8(%rsp)
     eab:	mov    %r13,0xd0(%rsp)
     eb3:	mov    %r14,0xd8(%rsp)
     ebb:	mov    %r15,0xe0(%rsp)
     ec3:	movq   $0x0,0x10(%rsp)
     ecc:	movq   $0x0,0x18(%rsp)
     ed5:	movq   $0x0,0x20(%rsp)
     ede:	movq   $0x0,0x28(%rsp)
     ee7:	movq   $0x0,0x30(%rsp)
     ef0:	movq   $0x0,0x38(%rsp)
     ef9:	movq   $0x0,0x40(%rsp)
     f02:	movq   $0x0,0x48(%rsp)
     f0b:	movq   $0x0,0x50(%rsp)
     f14:	mov    %rsi,(%rsp)
     f18:	mov    %rsi,%rbx
     f1b:	mov    0x10(%rdi),%rax
     f1f:	mov    %rdi,0x90(%rsp)
     f27:	mov    (%rax),%rsi
     f2a:	mov    %rsi,0x8(%rsp)
     f2f:	call   f34 <botlish_fn_3+0xa4>
			f30: R_X86_64_PLT32	rt_co_create-0x4
     f34:	mov    %rax,0xb0(%rsp)
     f3c:	mov    %rax,0x8(%rsp)
     f41:	mov    0xb0(%rsp),%rsi
     f49:	mov    0x90(%rsp),%rdi
     f51:	call   f56 <botlish_fn_3+0xc6>
			f52: R_X86_64_PLT32	rt_co_start-0x4
     f56:	test   %rax,%rax
     f59:	je     13c0 <botlish_fn_3+0x530>
     f5f:	mov    %rax,0x10(%rsp)
     f64:	mov    %rax,%rdx
     f67:	mov    $0x3,%esi
     f6c:	movq   $0x3,0x18(%rsp)
     f75:	mov    0x90(%rsp),%rdi
     f7d:	call   f82 <botlish_fn_3+0xf2>
			f7e: R_X86_64_PLT32	rt_mutarray_create-0x4
     f82:	test   %rax,%rax
     f85:	je     13c0 <botlish_fn_3+0x530>
     f8b:	mov    %rax,0x10(%rsp)
     f90:	mov    %rax,%r13
     f93:	mov    %rbx,%rsi
     f96:	mov    0x90(%rsp),%rdi
     f9e:	call   fa3 <botlish_fn_3+0x113>
			f9f: R_X86_64_PLT32	rt_list_len-0x4
     fa3:	mov    %rax,%r12
     fa6:	mov    %r12,0x18(%rsp)
     fab:	mov    $0x1,%esi
     fb0:	mov    %rsi,0xa8(%rsp)
     fb8:	movq   $0x1,0x20(%rsp)
     fc1:	mov    %rsi,%rax
     fc4:	and    %r12,%rax
     fc7:	mov    %rsi,0xa8(%rsp)
     fcf:	test   $0x1,%rax
     fd5:	jne    1008 <botlish_fn_3+0x178>
     fdb:	mov    %r12,%rdx
     fde:	mov    0xa8(%rsp),%rsi
     fe6:	mov    0x90(%rsp),%rdi
     fee:	call   ff3 <botlish_fn_3+0x163>
			fef: R_X86_64_PLT32	rt_int_cmp-0x4
     ff3:	mov    $0x2,%ecx
     ff8:	test   %rax,%rax
     ffb:	cmovl  0x49d(%rip),%rcx        # 14a0 <botlish_fn_3+0x610>
    1003:	jmp    1020 <botlish_fn_3+0x190>
    1008:	mov    $0x2,%ecx
    100d:	mov    0xa8(%rsp),%rsi
    1015:	cmp    %r12,%rsi
    1018:	cmovl  0x480(%rip),%rcx        # 14a0 <botlish_fn_3+0x610>
    1020:	cmp    $0x6,%rcx
    1024:	je     107a <botlish_fn_3+0x1ea>
    102a:	mov    0xb0(%rsp),%rsi
    1032:	mov    0x90(%rsp),%rdi
    103a:	call   103f <botlish_fn_3+0x1af>
			103b: R_X86_64_PLT32	rt_co_release-0x4
    103f:	mov    0x10(%r13),%rax
    1043:	mov    (%rax),%rax
    1046:	mov    0xc0(%rsp),%rbx
    104e:	mov    0xc8(%rsp),%r12
    1056:	mov    0xd0(%rsp),%r13
    105e:	mov    0xd8(%rsp),%r14
    1066:	mov    0xe0(%rsp),%r15
    106e:	add    $0xf0,%rsp
    1075:	mov    %rbp,%rsp
    1078:	pop    %rbp
    1079:	ret
    107a:	mov    0xa8(%rsp),%rsi
    1082:	test   $0x1,%rsi
    1089:	je     10aa <botlish_fn_3+0x21a>
    108f:	mov    0x8(%rbx),%rcx
    1093:	mov    0xa8(%rsp),%rsi
    109b:	mov    %rsi,%rax
    109e:	sar    $1,%rax
    10a1:	cmp    %rcx,%rax
    10a4:	jb     10d0 <botlish_fn_3+0x240>
    10aa:	mov    0xa8(%rsp),%rdx
    10b2:	mov    %rbx,%rsi
    10b5:	mov    0x90(%rsp),%rdi
    10bd:	call   10c2 <botlish_fn_3+0x232>
			10be: R_X86_64_PLT32	rt_list_get-0x4
    10c2:	test   %rax,%rax
    10c5:	je     13c0 <botlish_fn_3+0x530>
    10cb:	jmp    10d8 <botlish_fn_3+0x248>
    10d0:	mov    0x10(%rbx),%rcx
    10d4:	mov    (%rcx,%rax,8),%rax
    10d8:	mov    %rax,0x28(%rsp)
    10dd:	mov    %rax,%r15
    10e0:	mov    %r15,%rsi
    10e3:	mov    0x90(%rsp),%rdi
    10eb:	call   10f0 <botlish_fn_3+0x260>
			10ec: R_X86_64_PLT32	rt_list_len-0x4
    10f0:	mov    %rax,0x30(%rsp)
    10f5:	mov    %rax,%r14
    10f8:	movq   $0x1,0x38(%rsp)
    1101:	xor    %rdx,%rdx
    1104:	mov    0x90(%rsp),%rdi
    110c:	mov    %rdx,%rsi
    110f:	call   1114 <botlish_fn_3+0x284>
			1110: R_X86_64_PLT32	rt_list_new-0x4
    1114:	test   %rax,%rax
    1117:	je     13c0 <botlish_fn_3+0x530>
    111d:	mov    %rax,0x40(%rsp)
    1122:	mov    %rax,0xa0(%rsp)
    112a:	mov    $0x1,%esi
    112f:	mov    %rsi,0x98(%rsp)
    1137:	mov    %rsi,%r9
    113a:	and    %r14,%r9
    113d:	mov    %rsi,0x98(%rsp)
    1145:	test   $0x1,%r9
    114c:	jne    117f <botlish_fn_3+0x2ef>
    1152:	mov    %r14,%rdx
    1155:	mov    0x98(%rsp),%rsi
    115d:	mov    0x90(%rsp),%rdi
    1165:	call   116a <botlish_fn_3+0x2da>
			1166: R_X86_64_PLT32	rt_int_cmp-0x4
    116a:	mov    $0x2,%ecx
    116f:	test   %rax,%rax
    1172:	cmovl  0x326(%rip),%rcx        # 14a0 <botlish_fn_3+0x610>
    117a:	jmp    1197 <botlish_fn_3+0x307>
    117f:	mov    $0x2,%ecx
    1184:	mov    0x98(%rsp),%rsi
    118c:	cmp    %r14,%rsi
    118f:	cmovl  0x309(%rip),%rcx        # 14a0 <botlish_fn_3+0x610>
    1197:	cmp    $0x6,%rcx
    119b:	je     1264 <botlish_fn_3+0x3d4>
    11a1:	lea    0x80(%rsp),%rcx
    11a9:	movq   $0x0,0x80(%rsp)
    11b5:	mov    0xa0(%rsp),%rax
    11bd:	mov    %rax,0x88(%rsp)
    11c5:	mov    $0x1,%esi
    11ca:	mov    $0x2,%edx
    11cf:	mov    0x90(%rsp),%rdi
    11d7:	call   11dc <botlish_fn_3+0x34c>
			11d8: R_X86_64_PLT32	rt_construct-0x4
    11dc:	test   %rax,%rax
    11df:	je     13c0 <botlish_fn_3+0x530>
    11e5:	movq   $0x3,0x28(%rsp)
    11ee:	mov    0xa8(%rsp),%rsi
    11f6:	test   $0x1,%rsi
    11fd:	je     122d <botlish_fn_3+0x39d>
    1203:	mov    0xa8(%rsp),%rsi
    120b:	mov    %rsi,%rax
    120e:	add    $0x2,%rax
    1212:	seto   %cl
    1215:	test   %cl,%cl
    1217:	jne    122d <botlish_fn_3+0x39d>
    121d:	mov    %rax,%rsi
    1220:	mov    %rax,0xa8(%rsp)
    1228:	jmp    1252 <botlish_fn_3+0x3c2>
    122d:	mov    $0x3,%edx
    1232:	mov    0xa8(%rsp),%rsi
    123a:	mov    0x90(%rsp),%rdi
    1242:	call   1247 <botlish_fn_3+0x3b7>
			1243: R_X86_64_PLT32	rt_int_add-0x4
    1247:	mov    %rax,%rsi
    124a:	mov    %rax,0xa8(%rsp)
    1252:	mov    %rsi,0x20(%rsp)
    1257:	mov    0xa8(%rsp),%rsi
    125f:	jmp    fc1 <botlish_fn_3+0x131>
    1264:	mov    0x98(%rsp),%rsi
    126c:	test   $0x1,%rsi
    1273:	je     1294 <botlish_fn_3+0x404>
    1279:	mov    0x8(%r15),%rcx
    127d:	mov    0x98(%rsp),%rsi
    1285:	mov    %rsi,%rax
    1288:	sar    $1,%rax
    128b:	cmp    %rcx,%rax
    128e:	jb     12ba <botlish_fn_3+0x42a>
    1294:	mov    0x98(%rsp),%rdx
    129c:	mov    %r15,%rsi
    129f:	mov    0x90(%rsp),%rdi
    12a7:	call   12ac <botlish_fn_3+0x41c>
			12a8: R_X86_64_PLT32	rt_list_get-0x4
    12ac:	test   %rax,%rax
    12af:	je     13c0 <botlish_fn_3+0x530>
    12b5:	jmp    12c2 <botlish_fn_3+0x432>
    12ba:	mov    0x10(%r15),%rcx
    12be:	mov    (%rcx,%rax,8),%rax
    12c2:	mov    %rax,0x48(%rsp)
    12c7:	mov    $0x1,%edx
    12cc:	movq   $0x1,0x50(%rsp)
    12d5:	lea    0x58(%rsp),%rcx
    12da:	mov    %rax,0x58(%rsp)
    12df:	xor    %rsi,%rsi
    12e2:	mov    0x90(%rsp),%rdi
    12ea:	call   12ef <botlish_fn_3+0x45f>
			12eb: R_X86_64_PLT32	rt_struct_new-0x4
    12ef:	mov    %rax,0x48(%rsp)
    12f4:	mov    %rax,%rdx
    12f7:	mov    0xb0(%rsp),%rsi
    12ff:	mov    0x90(%rsp),%rdi
    1307:	call   130c <botlish_fn_3+0x47c>
			1308: R_X86_64_PLT32	rt_co_resume-0x4
    130c:	test   %rax,%rax
    130f:	mov    %rax,%rcx
    1312:	jne    134b <botlish_fn_3+0x4bb>
    1318:	mov    0x90(%rsp),%rdi
    1320:	call   1325 <botlish_fn_3+0x495>
			1321: R_X86_64_PLT32	rt_declared_error-0x4
    1325:	cmp    $0x40000001,%rax
    132b:	jne    13c0 <botlish_fn_3+0x530>
    1331:	mov    0xb0(%rsp),%rsi
    1339:	mov    0x90(%rsp),%rdi
    1341:	call   1346 <botlish_fn_3+0x4b6>
			1342: R_X86_64_PLT32	rt_co_release-0x4
    1346:	jmp    13c0 <botlish_fn_3+0x530>
    134b:	mov    0x18(%r13),%rax
    134f:	test   %rax,%rax
    1352:	je     1483 <botlish_fn_3+0x5f3>
    1358:	mov    0x10(%r13),%rax
    135c:	mov    %rcx,(%rax)
    135f:	movq   $0xa,0x48(%rsp)
    1368:	lea    0x60(%rsp),%rcx
    136d:	movq   $0x0,0x60(%rsp)
    1376:	mov    0xa0(%rsp),%rax
    137e:	mov    %rax,0x68(%rsp)
    1383:	movq   $0x2,0x70(%rsp)
    138c:	movq   $0xa,0x78(%rsp)
    1395:	mov    $0x3,%esi
    139a:	mov    $0x4,%edx
    139f:	mov    0x90(%rsp),%rdi
    13a7:	call   13ac <botlish_fn_3+0x51c>
			13a8: R_X86_64_PLT32	rt_construct-0x4
    13ac:	mov    %rax,%rcx
    13af:	mov    %rax,0xa0(%rsp)
    13b7:	test   %rcx,%rax
    13ba:	jne    13f7 <botlish_fn_3+0x567>
    13c0:	xor    %rax,%rax
    13c3:	mov    0xc0(%rsp),%rbx
    13cb:	mov    0xc8(%rsp),%r12
    13d3:	mov    0xd0(%rsp),%r13
    13db:	mov    0xd8(%rsp),%r14
    13e3:	mov    0xe0(%rsp),%r15
    13eb:	add    $0xf0,%rsp
    13f2:	mov    %rbp,%rsp
    13f5:	pop    %rbp
    13f6:	ret
    13f7:	mov    0xa0(%rsp),%rax
    13ff:	mov    %rax,0x40(%rsp)
    1404:	movq   $0x3,0x48(%rsp)
    140d:	mov    0x98(%rsp),%rsi
    1415:	test   $0x1,%rsi
    141c:	je     144c <botlish_fn_3+0x5bc>
    1422:	mov    0x98(%rsp),%rsi
    142a:	mov    %rsi,%rcx
    142d:	add    $0x2,%rcx
    1431:	seto   %al
    1434:	test   %al,%al
    1436:	jne    144c <botlish_fn_3+0x5bc>
    143c:	mov    %rcx,%rsi
    143f:	mov    %rcx,0x98(%rsp)
    1447:	jmp    1471 <botlish_fn_3+0x5e1>
    144c:	mov    $0x3,%edx
    1451:	mov    0x98(%rsp),%rsi
    1459:	mov    0x90(%rsp),%rdi
    1461:	call   1466 <botlish_fn_3+0x5d6>
			1462: R_X86_64_PLT32	rt_int_add-0x4
    1466:	mov    %rax,%rsi
    1469:	mov    %rax,0x98(%rsp)
    1471:	mov    %rsi,0x38(%rsp)
    1476:	mov    0x98(%rsp),%rsi
    147e:	jmp    1137 <botlish_fn_3+0x2a7>
    1483:	mov    $0x1,%edx
    1488:	mov    %r13,%rsi
    148b:	mov    0x90(%rsp),%rdi
    1493:	call   1498 <botlish_fn_3+0x608>
			1494: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1498:	jmp    135f <botlish_fn_3+0x4cf>
    149d:	add    %al,(%rax)
    149f:	add    %al,(%rsi)
    14a1:	add    %al,(%rax)
    14a3:	add    %al,(%rax)
    14a5:	add    %al,(%rax)
	...

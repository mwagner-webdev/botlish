; extracted from: git show 844c37e:audit/native-scalar-asm/bench/refined-checks.asm
; compiler revision (that regeneration's README.md): e7d53b691af7363d9a3556ff0ca78be62b003e0f

0000000000000c49 <botlish_fn_10: char_at<generic>>:
     c49:	push   rbp
     c4a:	mov    rbp,rsp
     c4d:	sub    rsp,0x50
     c51:	mov    QWORD PTR [rsp+0x20],rbx
     c56:	mov    QWORD PTR [rsp+0x28],r12
     c5b:	mov    QWORD PTR [rsp+0x30],r13
     c60:	mov    QWORD PTR [rsp+0x38],r14
     c65:	mov    QWORD PTR [rsp+0x40],r15
     c6a:	mov    r12,rdi
     c6d:	mov    r15,rcx
     c70:	mov    QWORD PTR [rsp],rsi
     c74:	mov    QWORD PTR [rsp+0x8],rdx
     c79:	mov    r13,rdx
     c7c:	mov    QWORD PTR [rsp+0x10],0x3
     c85:	test   rsi,0x1
     c8c:	jne    c9a <botlish_fn_10+0x51>
     c92:	mov    rbx,rsi
     c95:	jmp    cba <botlish_fn_10+0x71>
     c9a:	mov    rax,rsi
     c9d:	add    rax,0x2
     ca1:	mov    rbx,rsi
     ca4:	seto   cl
     ca7:	test   cl,cl
     ca9:	jne    cba <botlish_fn_10+0x71>
     caf:	mov    rdi,r12
     cb2:	mov    r14,rax
     cb5:	jmp    cd0 <botlish_fn_10+0x87>
     cba:	mov    edx,0x3
     cbf:	mov    rsi,rbx
     cc2:	mov    rdi,r12
     cc5:	call   cca <botlish_fn_10+0x81>
			cc6: R_X86_64_PLT32	rt_int_add-0x4
     cca:	mov    r14,rax
     ccd:	mov    rdi,r12
     cd0:	mov    rcx,r14
     cd3:	mov    rdx,rbx
     cd6:	mov    rsi,r13
     cd9:	call   cde <botlish_fn_10+0x95>
			cda: R_X86_64_PLT32	rt_str_region_check-0x4
     cde:	test   rax,rax
     ce1:	jne    d0c <botlish_fn_10+0xc3>
     ce7:	xor    rax,rax
     cea:	mov    rbx,QWORD PTR [rsp+0x20]
     cef:	mov    r12,QWORD PTR [rsp+0x28]
     cf4:	mov    r13,QWORD PTR [rsp+0x30]
     cf9:	mov    r14,QWORD PTR [rsp+0x38]
     cfe:	mov    r15,QWORD PTR [rsp+0x40]
     d03:	add    rsp,0x50
     d07:	mov    rsp,rbp
     d0a:	pop    rbp
     d0b:	ret
     d0c:	mov    rcx,r15
     d0f:	mov    QWORD PTR [rcx],rbx
     d12:	mov    rax,r14
     d15:	mov    QWORD PTR [rcx+0x8],rax
     d19:	mov    rax,r13
     d1c:	mov    rbx,QWORD PTR [rsp+0x20]
     d21:	mov    r12,QWORD PTR [rsp+0x28]
     d26:	mov    r13,QWORD PTR [rsp+0x30]
     d2b:	mov    r14,QWORD PTR [rsp+0x38]
     d30:	mov    r15,QWORD PTR [rsp+0x40]
     d35:	add    rsp,0x50
     d39:	mov    rsp,rbp
     d3c:	pop    rbp
     d3d:	ret

0000000000000d3e <botlish_entry_10: char_at<generic>>:
     d3e:	push   rbp
     d3f:	mov    rbp,rsp
     d42:	ud2
     d44:	add    BYTE PTR [rax],al
	...

0000000000000d48 <botlish_fn_11: scan_local<generic>>:
     d48:	push   rbp
     d49:	mov    rbp,rsp
     d4c:	sub    rsp,0x80
     d53:	mov    QWORD PTR [rsp+0x50],rbx
     d58:	mov    QWORD PTR [rsp+0x58],r12
     d5d:	mov    QWORD PTR [rsp+0x60],r13
     d62:	mov    QWORD PTR [rsp+0x68],r14
     d67:	mov    QWORD PTR [rsp+0x70],r15
     d6c:	mov    r9,rdi
     d6f:	mov    QWORD PTR [rsp+0x18],0x0
     d78:	mov    QWORD PTR [rsp],rsi
     d7c:	mov    r15,rsi
     d7f:	mov    QWORD PTR [rsp+0x8],rdx
     d84:	mov    QWORD PTR [rsp+0x10],rcx
     d89:	mov    r12,rcx
     d8c:	lea    r14,[rsp+0x20]
     d91:	mov    r13,rdx
     d94:	mov    rdi,rsi
     d97:	and    rdi,r13
     d9a:	mov    r15,rsi
     d9d:	test   rdi,0x1
     da4:	jne    dd0 <botlish_fn_11+0x88>
     daa:	mov    rbx,r9
     dad:	mov    rdx,r13
     db0:	mov    rsi,r15
     db3:	mov    rdi,rbx
     db6:	call   dbb <botlish_fn_11+0x73>
			db7: R_X86_64_PLT32	rt_int_cmp-0x4
     dbb:	mov    ecx,0x2
     dc0:	test   rax,rax
     dc3:	cmovge rcx,QWORD PTR [rip+0x2c5]        # 1090 <botlish_fn_11+0x348>
     dcb:	jmp    de6 <botlish_fn_11+0x9e>
     dd0:	mov    rbx,r9
     dd3:	mov    ecx,0x2
     dd8:	mov    rsi,r15
     ddb:	cmp    rsi,r13
     dde:	cmovge rcx,QWORD PTR [rip+0x2aa]        # 1090 <botlish_fn_11+0x348>
     de6:	cmp    rcx,0x6
     dea:	je     1065 <botlish_fn_11+0x31d>
     df0:	mov    rcx,r14
     df3:	mov    rdx,r12
     df6:	mov    rsi,r15
     df9:	mov    rdi,rbx
     dfc:	call   e01 <botlish_fn_11+0xb9>
			dfd: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
     e01:	mov    rcx,rax
     e04:	mov    QWORD PTR [rsp+0x40],rax
     e09:	test   rax,rcx
     e0c:	je     e3c <botlish_fn_11+0xf4>
     e12:	mov    rdx,QWORD PTR [rsp+0x20]
     e17:	mov    QWORD PTR [rsp+0x38],rdx
     e1c:	mov    rcx,QWORD PTR [rsp+0x28]
     e21:	mov    QWORD PTR [rsp+0x30],rcx
     e26:	mov    rsi,QWORD PTR [rsp+0x40]
     e2b:	mov    rdi,rbx
     e2e:	call   e33 <botlish_fn_11+0xeb>
			e2f: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
     e33:	test   rax,rax
     e36:	jne    e64 <botlish_fn_11+0x11c>
     e3c:	xor    rax,rax
     e3f:	mov    rbx,QWORD PTR [rsp+0x50]
     e44:	mov    r12,QWORD PTR [rsp+0x58]
     e49:	mov    r13,QWORD PTR [rsp+0x60]
     e4e:	mov    r14,QWORD PTR [rsp+0x68]
     e53:	mov    r15,QWORD PTR [rsp+0x70]
     e58:	add    rsp,0x80
     e5f:	mov    rsp,rbp
     e62:	pop    rbp
     e63:	ret
     e64:	cmp    rax,0x6
     e68:	je     eae <botlish_fn_11+0x166>
     e6e:	mov    rax,QWORD PTR [rbx+0x10]
     e72:	mov    r8,QWORD PTR [rax+0xa8]
     e79:	mov    rcx,QWORD PTR [rsp+0x30]
     e7e:	mov    rdx,QWORD PTR [rsp+0x38]
     e83:	mov    rsi,QWORD PTR [rsp+0x40]
     e88:	mov    rdi,rbx
     e8b:	call   e90 <botlish_fn_11+0x148>
			e8c: R_X86_64_PLT32	rt_str_region_eq-0x4
     e90:	cmp    rax,0x6
     e94:	je     ea4 <botlish_fn_11+0x15c>
     e9a:	mov    ecx,0x2
     e9f:	jmp    eb3 <botlish_fn_11+0x16b>
     ea4:	mov    ecx,0x6
     ea9:	jmp    eb3 <botlish_fn_11+0x16b>
     eae:	mov    ecx,0x6
     eb3:	cmp    rcx,0x6
     eb7:	je     efd <botlish_fn_11+0x1b5>
     ebd:	mov    rax,QWORD PTR [rbx+0x10]
     ec1:	mov    r8,QWORD PTR [rax+0xb0]
     ec8:	mov    rcx,QWORD PTR [rsp+0x30]
     ecd:	mov    rdx,QWORD PTR [rsp+0x38]
     ed2:	mov    rsi,QWORD PTR [rsp+0x40]
     ed7:	mov    rdi,rbx
     eda:	call   edf <botlish_fn_11+0x197>
			edb: R_X86_64_PLT32	rt_str_region_eq-0x4
     edf:	cmp    rax,0x6
     ee3:	je     ef3 <botlish_fn_11+0x1ab>
     ee9:	mov    ecx,0x2
     eee:	jmp    f02 <botlish_fn_11+0x1ba>
     ef3:	mov    ecx,0x6
     ef8:	jmp    f02 <botlish_fn_11+0x1ba>
     efd:	mov    ecx,0x6
     f02:	cmp    rcx,0x6
     f06:	je     f4c <botlish_fn_11+0x204>
     f0c:	mov    rax,QWORD PTR [rbx+0x10]
     f10:	mov    r8,QWORD PTR [rax+0xb8]
     f17:	mov    rcx,QWORD PTR [rsp+0x30]
     f1c:	mov    rdx,QWORD PTR [rsp+0x38]
     f21:	mov    rsi,QWORD PTR [rsp+0x40]
     f26:	mov    rdi,rbx
     f29:	call   f2e <botlish_fn_11+0x1e6>
			f2a: R_X86_64_PLT32	rt_str_region_eq-0x4
     f2e:	cmp    rax,0x6
     f32:	je     f42 <botlish_fn_11+0x1fa>
     f38:	mov    ecx,0x2
     f3d:	jmp    f51 <botlish_fn_11+0x209>
     f42:	mov    ecx,0x6
     f47:	jmp    f51 <botlish_fn_11+0x209>
     f4c:	mov    ecx,0x6
     f51:	cmp    rcx,0x6
     f55:	je     f9b <botlish_fn_11+0x253>
     f5b:	mov    rax,QWORD PTR [rbx+0x10]
     f5f:	mov    r8,QWORD PTR [rax+0xc0]
     f66:	mov    rcx,QWORD PTR [rsp+0x30]
     f6b:	mov    rdx,QWORD PTR [rsp+0x38]
     f70:	mov    rsi,QWORD PTR [rsp+0x40]
     f75:	mov    rdi,rbx
     f78:	call   f7d <botlish_fn_11+0x235>
			f79: R_X86_64_PLT32	rt_str_region_eq-0x4
     f7d:	cmp    rax,0x6
     f81:	je     f91 <botlish_fn_11+0x249>
     f87:	mov    eax,0x2
     f8c:	jmp    fa0 <botlish_fn_11+0x258>
     f91:	mov    eax,0x6
     f96:	jmp    fa0 <botlish_fn_11+0x258>
     f9b:	mov    eax,0x6
     fa0:	cmp    rax,0x6
     fa4:	je     fea <botlish_fn_11+0x2a2>
     faa:	mov    rax,QWORD PTR [rbx+0x10]
     fae:	mov    r8,QWORD PTR [rax+0xc8]
     fb5:	mov    rcx,QWORD PTR [rsp+0x30]
     fba:	mov    rdx,QWORD PTR [rsp+0x38]
     fbf:	mov    rsi,QWORD PTR [rsp+0x40]
     fc4:	mov    rdi,rbx
     fc7:	call   fcc <botlish_fn_11+0x284>
			fc8: R_X86_64_PLT32	rt_str_region_eq-0x4
     fcc:	cmp    rax,0x6
     fd0:	je     fe0 <botlish_fn_11+0x298>
     fd6:	mov    eax,0x2
     fdb:	jmp    fef <botlish_fn_11+0x2a7>
     fe0:	mov    eax,0x6
     fe5:	jmp    fef <botlish_fn_11+0x2a7>
     fea:	mov    eax,0x6
     fef:	cmp    rax,0x6
     ff3:	je     1001 <botlish_fn_11+0x2b9>
     ff9:	mov    rax,r15
     ffc:	jmp    1068 <botlish_fn_11+0x320>
    1001:	mov    QWORD PTR [rsp+0x18],0x3
    100a:	mov    rsi,r15
    100d:	test   rsi,0x1
    1014:	je     1036 <botlish_fn_11+0x2ee>
    101a:	mov    rsi,r15
    101d:	add    rsi,0x2
    1021:	seto   r8b
    1025:	test   r8b,r8b
    1028:	jne    1036 <botlish_fn_11+0x2ee>
    102e:	mov    r15,rsi
    1031:	jmp    104c <botlish_fn_11+0x304>
    1036:	mov    edx,0x3
    103b:	mov    rsi,r15
    103e:	mov    rdi,rbx
    1041:	call   1046 <botlish_fn_11+0x2fe>
			1042: R_X86_64_PLT32	rt_int_add-0x4
    1046:	mov    rsi,rax
    1049:	mov    r15,rax
    104c:	mov    QWORD PTR [rsp],rsi
    1050:	mov    QWORD PTR [rsp+0x8],r13
    1055:	mov    QWORD PTR [rsp+0x10],r12
    105a:	mov    rsi,r15
    105d:	mov    r9,rbx
    1060:	jmp    d94 <botlish_fn_11+0x4c>
    1065:	mov    rax,r15
    1068:	mov    rbx,QWORD PTR [rsp+0x50]
    106d:	mov    r12,QWORD PTR [rsp+0x58]
    1072:	mov    r13,QWORD PTR [rsp+0x60]
    1077:	mov    r14,QWORD PTR [rsp+0x68]
    107c:	mov    r15,QWORD PTR [rsp+0x70]
    1081:	add    rsp,0x80
    1088:	mov    rsp,rbp
    108b:	pop    rbp
    108c:	ret
    108d:	add    BYTE PTR [rax],al
    108f:	add    BYTE PTR [rsi],al
    1091:	add    BYTE PTR [rax],al
    1093:	add    BYTE PTR [rax],al
    1095:	add    BYTE PTR [rax],al
	...

0000000000001098 <botlish_entry_11: scan_local<generic>>:
    1098:	push   rbp
    1099:	mov    rbp,rsp
    109c:	mov    rsi,QWORD PTR [rdx]
    109f:	mov    r8,QWORD PTR [rdx+0x8]
    10a3:	mov    rcx,QWORD PTR [rdx+0x10]
    10a7:	mov    rdx,r8
    10aa:	call   10af <botlish_entry_11+0x17>
			10ab: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_local<generic>
    10af:	mov    rsp,rbp
    10b2:	pop    rbp
    10b3:	ret
    10b4:	add    BYTE PTR [rax],al
	...

00000000000012e0 <botlish_fn_13: scan_alpha<generic>>:
    12e0:	push   rbp
    12e1:	mov    rbp,rsp
    12e4:	sub    rsp,0x60
    12e8:	mov    QWORD PTR [rsp+0x30],rbx
    12ed:	mov    QWORD PTR [rsp+0x38],r12
    12f2:	mov    QWORD PTR [rsp+0x40],r13
    12f7:	mov    QWORD PTR [rsp+0x48],r14
    12fc:	mov    QWORD PTR [rsp+0x50],r15
    1301:	mov    r15,rdi
    1304:	mov    QWORD PTR [rsp+0x18],0x0
    130d:	mov    QWORD PTR [rsp],rsi
    1311:	mov    r14,rsi
    1314:	mov    QWORD PTR [rsp+0x8],rdx
    1319:	mov    QWORD PTR [rsp+0x10],rcx
    131e:	mov    r12,rcx
    1321:	lea    r13,[rsp+0x20]
    1326:	mov    rbx,rdx
    1329:	mov    rax,rsi
    132c:	and    rax,rbx
    132f:	mov    r14,rsi
    1332:	test   rax,0x1
    1338:	jne    1361 <botlish_fn_13+0x81>
    133e:	mov    rdx,rbx
    1341:	mov    rsi,r14
    1344:	mov    rdi,r15
    1347:	call   134c <botlish_fn_13+0x6c>
			1348: R_X86_64_PLT32	rt_int_cmp-0x4
    134c:	mov    ecx,0x2
    1351:	test   rax,rax
    1354:	cmovge rcx,QWORD PTR [rip+0x11c]        # 1478 <botlish_fn_13+0x198>
    135c:	jmp    1374 <botlish_fn_13+0x94>
    1361:	mov    ecx,0x2
    1366:	mov    rsi,r14
    1369:	cmp    rsi,rbx
    136c:	cmovge rcx,QWORD PTR [rip+0x104]        # 1478 <botlish_fn_13+0x198>
    1374:	cmp    rcx,0x6
    1378:	je     1452 <botlish_fn_13+0x172>
    137e:	mov    rcx,r13
    1381:	mov    rdx,r12
    1384:	mov    rsi,r14
    1387:	mov    rdi,r15
    138a:	call   138f <botlish_fn_13+0xaf>
			138b: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    138f:	test   rax,rax
    1392:	mov    rsi,rax
    1395:	je     13b6 <botlish_fn_13+0xd6>
    139b:	mov    rdx,QWORD PTR [rsp+0x20]
    13a0:	mov    rcx,QWORD PTR [rsp+0x28]
    13a5:	mov    rdi,r15
    13a8:	call   13ad <botlish_fn_13+0xcd>
			13a9: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    13ad:	test   rax,rax
    13b0:	jne    13db <botlish_fn_13+0xfb>
    13b6:	xor    rax,rax
    13b9:	mov    rbx,QWORD PTR [rsp+0x30]
    13be:	mov    r12,QWORD PTR [rsp+0x38]
    13c3:	mov    r13,QWORD PTR [rsp+0x40]
    13c8:	mov    r14,QWORD PTR [rsp+0x48]
    13cd:	mov    r15,QWORD PTR [rsp+0x50]
    13d2:	add    rsp,0x60
    13d6:	mov    rsp,rbp
    13d9:	pop    rbp
    13da:	ret
    13db:	cmp    rax,0x6
    13df:	je     13ed <botlish_fn_13+0x10d>
    13e5:	mov    rax,r14
    13e8:	jmp    1455 <botlish_fn_13+0x175>
    13ed:	mov    QWORD PTR [rsp+0x18],0x3
    13f6:	mov    rsi,r14
    13f9:	test   rsi,0x1
    1400:	je     1426 <botlish_fn_13+0x146>
    1406:	mov    rsi,r14
    1409:	mov    rcx,rsi
    140c:	add    rcx,0x2
    1410:	seto   al
    1413:	test   al,al
    1415:	jne    1426 <botlish_fn_13+0x146>
    141b:	mov    rsi,rcx
    141e:	mov    r14,rcx
    1421:	jmp    143c <botlish_fn_13+0x15c>
    1426:	mov    edx,0x3
    142b:	mov    rsi,r14
    142e:	mov    rdi,r15
    1431:	call   1436 <botlish_fn_13+0x156>
			1432: R_X86_64_PLT32	rt_int_add-0x4
    1436:	mov    rsi,rax
    1439:	mov    r14,rax
    143c:	mov    QWORD PTR [rsp],rsi
    1440:	mov    QWORD PTR [rsp+0x8],rbx
    1445:	mov    QWORD PTR [rsp+0x10],r12
    144a:	mov    rsi,r14
    144d:	jmp    1329 <botlish_fn_13+0x49>
    1452:	mov    rax,r14
    1455:	mov    rbx,QWORD PTR [rsp+0x30]
    145a:	mov    r12,QWORD PTR [rsp+0x38]
    145f:	mov    r13,QWORD PTR [rsp+0x40]
    1464:	mov    r14,QWORD PTR [rsp+0x48]
    1469:	mov    r15,QWORD PTR [rsp+0x50]
    146e:	add    rsp,0x60
    1472:	mov    rsp,rbp
    1475:	pop    rbp
    1476:	ret
    1477:	add    BYTE PTR [rsi],al
    1479:	add    BYTE PTR [rax],al
    147b:	add    BYTE PTR [rax],al
    147d:	add    BYTE PTR [rax],al
	...

0000000000001480 <botlish_entry_13: scan_alpha<generic>>:
    1480:	push   rbp
    1481:	mov    rbp,rsp
    1484:	mov    rsi,QWORD PTR [rdx]
    1487:	mov    r8,QWORD PTR [rdx+0x8]
    148b:	mov    rcx,QWORD PTR [rdx+0x10]
    148f:	mov    rdx,r8
    1492:	call   1497 <botlish_entry_13+0x17>
			1493: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_alpha<generic>
    1497:	mov    rsp,rbp
    149a:	pop    rbp
    149b:	ret
    149c:	add    BYTE PTR [rax],al
	...


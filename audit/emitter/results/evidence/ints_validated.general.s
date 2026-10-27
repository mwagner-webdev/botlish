<botlish_fn_7>:
     b78:	push   %rbp
     b79:	mov    %rsp,%rbp
     b7c:	sub    $0x180,%rsp
     b83:	mov    %rbx,0x150(%rsp)
     b8b:	mov    %r12,0x158(%rsp)
     b93:	mov    %r13,0x160(%rsp)
     b9b:	mov    %r14,0x168(%rsp)
     ba3:	mov    %r15,0x170(%rsp)
     bab:	mov    %rsi,%r12
     bae:	mov    %rdi,0x128(%rsp)
     bb6:	movq   $0x0,0x10(%rsp)
     bbf:	movq   $0x0,0x18(%rsp)
     bc8:	movq   $0x0,0x20(%rsp)
     bd1:	movq   $0x0,0x28(%rsp)
     bda:	movq   $0x0,0x30(%rsp)
     be3:	mov    $0x7,%esi
     be8:	movq   $0x7,(%rsp)
     bf0:	mov    $0x1,%edx
     bf5:	movq   $0x1,0x8(%rsp)
     bfe:	mov    0x128(%rsp),%rdi
     c06:	call   c0b <botlish_fn_7+0x93>
			c07: R_X86_64_PLT32	rt_mutarray_create-0x4
     c0b:	test   %rax,%rax
     c0e:	je     17f9 <botlish_fn_7+0xc81>
     c14:	mov    %rax,(%rsp)
     c18:	xor    %rbx,%rbx
     c1b:	mov    %r12,%r13
     c1e:	cmp    %r13,%rbx
     c21:	jl     cab <botlish_fn_7+0x133>
     c27:	mov    %rax,%r12
     c2a:	mov    0x10(%r12),%rax
     c2f:	mov    0x8(%rax),%rax
     c33:	mov    %rax,0x8(%rsp)
     c38:	mov    0x10(%r12),%rcx
     c3d:	mov    (%rcx),%rcx
     c40:	mov    %rcx,(%rsp)
     c44:	lea    0x118(%rsp),%rdx
     c4c:	mov    %rax,0x118(%rsp)
     c54:	mov    %rcx,0x120(%rsp)
     c5c:	mov    $0x2,%esi
     c61:	mov    0x128(%rsp),%rdi
     c69:	call   c6e <botlish_fn_7+0xf6>
			c6a: R_X86_64_PLT32	rt_list_new-0x4
     c6e:	test   %rax,%rax
     c71:	je     17f9 <botlish_fn_7+0xc81>
     c77:	mov    0x150(%rsp),%rbx
     c7f:	mov    0x158(%rsp),%r12
     c87:	mov    0x160(%rsp),%r13
     c8f:	mov    0x168(%rsp),%r14
     c97:	mov    0x170(%rsp),%r15
     c9f:	add    $0x180,%rsp
     ca6:	mov    %rbp,%rsp
     ca9:	pop    %rbp
     caa:	ret
     cab:	mov    %rax,%r12
     cae:	mov    %rbx,%rsi
     cb1:	shl    $1,%rsi
     cb4:	or     $0x1,%rsi
     cb8:	mov    %rsi,0x8(%rsp)
     cbd:	mov    0x128(%rsp),%rdi
     cc5:	call   cca <botlish_fn_7+0x152>
			cc6: R_X86_64_PLT32	botlish_fn_6-0x4
     cca:	test   %rax,%rax
     ccd:	je     17f9 <botlish_fn_7+0xc81>
     cd3:	mov    %rax,0x8(%rsp)
     cd8:	lea    0x38(%rsp),%r8
     cdd:	mov    %rax,0x38(%rsp)
     ce2:	mov    $0x8,%esi
     ce7:	mov    0x0(%rip),%rdx        # cee <botlish_fn_7+0x176>
			cea: R_X86_64_GOTPCREL	botlish_entry_8-0x4
     cee:	mov    $0x1,%ecx
     cf3:	mov    0x128(%rsp),%rdi
     cfb:	call   d00 <botlish_fn_7+0x188>
			cfc: R_X86_64_PLT32	rt_closure_new-0x4
     d00:	mov    %rax,0x8(%rsp)
     d05:	mov    %rax,%rsi
     d08:	mov    0x128(%rsp),%rdi
     d10:	call   d15 <botlish_fn_7+0x19d>
			d11: R_X86_64_PLT32	rt_co_create-0x4
     d15:	mov    %rax,0x148(%rsp)
     d1d:	mov    %rax,0x8(%rsp)
     d22:	mov    0x148(%rsp),%rsi
     d2a:	mov    0x128(%rsp),%rdi
     d32:	call   d37 <botlish_fn_7+0x1bf>
			d33: R_X86_64_PLT32	rt_co_start-0x4
     d37:	test   %rax,%rax
     d3a:	jne    d73 <botlish_fn_7+0x1fb>
     d40:	mov    0x128(%rsp),%rdi
     d48:	call   d4d <botlish_fn_7+0x1d5>
			d49: R_X86_64_PLT32	rt_declared_error-0x4
     d4d:	cmp    $0x40000001,%rax
     d53:	jne    17f9 <botlish_fn_7+0xc81>
     d59:	mov    0x148(%rsp),%rsi
     d61:	mov    0x128(%rsp),%rdi
     d69:	call   d6e <botlish_fn_7+0x1f6>
			d6a: R_X86_64_PLT32	rt_co_release-0x4
     d6e:	jmp    17f9 <botlish_fn_7+0xc81>
     d73:	mov    %rax,0x10(%rsp)
     d78:	lea    0x40(%rsp),%r8
     d7d:	mov    %rax,0x40(%rsp)
     d82:	mov    %rax,%r14
     d85:	mov    $0x9,%esi
     d8a:	mov    0x0(%rip),%rdx        # d91 <botlish_fn_7+0x219>
			d8d: R_X86_64_GOTPCREL	botlish_entry_9-0x4
     d91:	mov    $0x1,%ecx
     d96:	mov    0x128(%rsp),%rdi
     d9e:	call   da3 <botlish_fn_7+0x22b>
			d9f: R_X86_64_PLT32	rt_closure_new-0x4
     da3:	mov    %rax,0x18(%rsp)
     da8:	mov    %rax,%rsi
     dab:	mov    0x128(%rsp),%rdi
     db3:	call   db8 <botlish_fn_7+0x240>
			db4: R_X86_64_PLT32	rt_co_create-0x4
     db8:	mov    %rax,0x140(%rsp)
     dc0:	mov    %rax,0x18(%rsp)
     dc5:	mov    0x140(%rsp),%rsi
     dcd:	mov    0x128(%rsp),%rdi
     dd5:	call   dda <botlish_fn_7+0x262>
			dd6: R_X86_64_PLT32	rt_co_start-0x4
     dda:	test   %rax,%rax
     ddd:	jne    f67 <botlish_fn_7+0x3ef>
     de3:	mov    0x128(%rsp),%rdi
     deb:	call   df0 <botlish_fn_7+0x278>
			dec: R_X86_64_PLT32	rt_declared_error-0x4
     df0:	cmp    $0x1,%rax
     df4:	je     ebc <botlish_fn_7+0x344>
     dfa:	mov    0x128(%rsp),%rdi
     e02:	call   e07 <botlish_fn_7+0x28f>
			e03: R_X86_64_PLT32	rt_declared_error-0x4
     e07:	cmp    $0x2,%rax
     e0b:	jne    17f9 <botlish_fn_7+0xc81>
     e11:	xor    %rbx,%rbx
     e14:	mov    %rbx,%rsi
     e17:	mov    0x128(%rsp),%rdi
     e1f:	call   e24 <botlish_fn_7+0x2ac>
			e20: R_X86_64_PLT32	rt_declared_payload-0x4
     e24:	mov    %rax,%r12
     e27:	mov    $0x1,%esi
     e2c:	mov    0x128(%rsp),%rdi
     e34:	call   e39 <botlish_fn_7+0x2c1>
			e35: R_X86_64_PLT32	rt_declared_payload-0x4
     e39:	mov    %rax,%r13
     e3c:	mov    0x128(%rsp),%rdi
     e44:	call   e49 <botlish_fn_7+0x2d1>
			e45: R_X86_64_PLT32	rt_clear_declared_error-0x4
     e49:	mov    0x148(%rsp),%rsi
     e51:	mov    0x128(%rsp),%rdi
     e59:	call   e5e <botlish_fn_7+0x2e6>
			e5a: R_X86_64_PLT32	rt_co_release-0x4
     e5e:	mov    0x140(%rsp),%rsi
     e66:	mov    0x128(%rsp),%rdi
     e6e:	call   e73 <botlish_fn_7+0x2fb>
			e6f: R_X86_64_PLT32	rt_co_release-0x4
     e73:	mov    0x128(%rsp),%rdi
     e7b:	mov    0x10(%rdi),%rax
     e7f:	mov    0x88(%rax),%rdx
     e86:	lea    0x60(%rsp),%r9
     e8b:	movq   $0x1,0x60(%rsp)
     e94:	mov    %r12,%rax
     e97:	mov    %rax,0x68(%rsp)
     e9c:	mov    %r13,%rax
     e9f:	mov    %rax,0x70(%rsp)
     ea4:	mov    $0xc,%esi
     ea9:	mov    $0x3,%r8d
     eaf:	mov    %rbx,%rcx
     eb2:	call   eb7 <botlish_fn_7+0x33f>
			eb3: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     eb7:	jmp    17f9 <botlish_fn_7+0xc81>
     ebc:	xor    %rbx,%rbx
     ebf:	mov    %rbx,%rsi
     ec2:	mov    0x128(%rsp),%rdi
     eca:	call   ecf <botlish_fn_7+0x357>
			ecb: R_X86_64_PLT32	rt_declared_payload-0x4
     ecf:	mov    %rax,%r12
     ed2:	mov    $0x1,%esi
     ed7:	mov    0x128(%rsp),%rdi
     edf:	call   ee4 <botlish_fn_7+0x36c>
			ee0: R_X86_64_PLT32	rt_declared_payload-0x4
     ee4:	mov    %rax,%r13
     ee7:	mov    0x128(%rsp),%rdi
     eef:	call   ef4 <botlish_fn_7+0x37c>
			ef0: R_X86_64_PLT32	rt_clear_declared_error-0x4
     ef4:	mov    0x148(%rsp),%rsi
     efc:	mov    0x128(%rsp),%rdi
     f04:	call   f09 <botlish_fn_7+0x391>
			f05: R_X86_64_PLT32	rt_co_release-0x4
     f09:	mov    0x140(%rsp),%rsi
     f11:	mov    0x128(%rsp),%rdi
     f19:	call   f1e <botlish_fn_7+0x3a6>
			f1a: R_X86_64_PLT32	rt_co_release-0x4
     f1e:	mov    0x128(%rsp),%rdi
     f26:	mov    0x10(%rdi),%rax
     f2a:	mov    0x88(%rax),%rdx
     f31:	lea    0x48(%rsp),%r9
     f36:	movq   $0x1,0x48(%rsp)
     f3f:	mov    %r12,%rax
     f42:	mov    %rax,0x50(%rsp)
     f47:	mov    %r13,%rax
     f4a:	mov    %rax,0x58(%rsp)
     f4f:	mov    $0xc,%esi
     f54:	mov    $0x3,%r8d
     f5a:	mov    %rbx,%rcx
     f5d:	call   f62 <botlish_fn_7+0x3ea>
			f5e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     f62:	jmp    17f9 <botlish_fn_7+0xc81>
     f67:	mov    0x18(%r12),%rax
     f6c:	test   %rax,%rax
     f6f:	je     1830 <botlish_fn_7+0xcb8>
     f75:	mov    %r14,%rcx
     f78:	mov    0x10(%r12),%rax
     f7d:	mov    %rcx,0x10(%rax)
     f81:	mov    $0x3,%r8d
     f87:	mov    %r8,0x138(%rsp)
     f8f:	mov    $0x2,%r15d
     f95:	mov    $0x7fffffff,%eax
     f9a:	mov    %rax,%r14
     f9d:	neg    %r14
     fa0:	cmovs  %rax,%r14
     fa4:	mov    0x140(%rsp),%rsi
     fac:	mov    0x128(%rsp),%rdi
     fb4:	call   fb9 <botlish_fn_7+0x441>
			fb5: R_X86_64_PLT32	rt_co_done-0x4
     fb9:	cmp    $0x6,%rax
     fbd:	je     177e <botlish_fn_7+0xc06>
     fc3:	movq   $0x1,0x10(%rsp)
     fcc:	mov    0x10(%r12),%rax
     fd1:	mov    (%rax),%rsi
     fd4:	mov    %rsi,0x20(%rsp)
     fd9:	mov    0x10(%r12),%rax
     fde:	mov    0x10(%rax),%rdx
     fe2:	mov    %rdx,0x28(%rsp)
     fe7:	mov    %rdx,0x130(%rsp)
     fef:	movq   $0x3f,0x30(%rsp)
     ff8:	test   $0x1,%rsi
     fff:	je     1029 <botlish_fn_7+0x4b1>
    1005:	mov    %rsi,%rax
    1008:	sar    $1,%rax
    100b:	imulq  0x896(%rip)        # 18a8 <botlish_fn_7+0xd30>
    1012:	seto   %cl
    1015:	or     $0x1,%rax
    1019:	test   %cl,%cl
    101b:	jne    1029 <botlish_fn_7+0x4b1>
    1021:	mov    %rax,%rsi
    1024:	jmp    103e <botlish_fn_7+0x4c6>
    1029:	mov    $0x3f,%edx
    102e:	mov    0x128(%rsp),%rdi
    1036:	call   103b <botlish_fn_7+0x4c3>
			1037: R_X86_64_PLT32	rt_int_mul-0x4
    103b:	mov    %rax,%rsi
    103e:	mov    %rsi,0x20(%rsp)
    1043:	mov    0x130(%rsp),%rdx
    104b:	mov    %rsi,%rax
    104e:	and    %rdx,%rax
    1051:	test   $0x1,%rax
    1057:	je     1074 <botlish_fn_7+0x4fc>
    105d:	lea    -0x1(%rdx),%rdi
    1061:	mov    %rsi,%rax
    1064:	add    %rdi,%rax
    1067:	seto   %dil
    106b:	test   %dil,%dil
    106e:	je     1081 <botlish_fn_7+0x509>
    1074:	mov    0x128(%rsp),%rdi
    107c:	call   1081 <botlish_fn_7+0x509>
			107d: R_X86_64_PLT32	rt_int_add-0x4
    1081:	mov    %rax,0x20(%rsp)
    1086:	movq   $0x3,0x28(%rsp)
    108f:	test   $0x1,%rax
    1095:	jne    10a3 <botlish_fn_7+0x52b>
    109b:	mov    %rax,%rsi
    109e:	jmp    10bb <botlish_fn_7+0x543>
    10a3:	mov    %rax,%rsi
    10a6:	add    $0x2,%rsi
    10aa:	mov    %rax,%rcx
    10ad:	seto   %al
    10b0:	test   %al,%al
    10b2:	je     10d3 <botlish_fn_7+0x55b>
    10b8:	mov    %rcx,%rsi
    10bb:	mov    0x138(%rsp),%rdx
    10c3:	mov    0x128(%rsp),%rdi
    10cb:	call   10d0 <botlish_fn_7+0x558>
			10cc: R_X86_64_PLT32	rt_int_add-0x4
    10d0:	mov    %rax,%rsi
    10d3:	mov    %rsi,0x20(%rsp)
    10d8:	mov    $0xffffffff,%eax
    10dd:	mov    %rax,0x28(%rsp)
    10e2:	test   $0x1,%rsi
    10e9:	jne    115a <botlish_fn_7+0x5e2>
    10ef:	mov    $0xffffffff,%edx
    10f4:	mov    0x128(%rsp),%rdi
    10fc:	call   1101 <botlish_fn_7+0x589>
			10fd: R_X86_64_PLT32	rt_int_mod-0x4
    1101:	test   %rax,%rax
    1104:	jne    1152 <botlish_fn_7+0x5da>
    110a:	mov    0x128(%rsp),%rdi
    1112:	call   1117 <botlish_fn_7+0x59f>
			1113: R_X86_64_PLT32	rt_declared_error-0x4
    1117:	cmp    $0x40000001,%rax
    111d:	jne    17f9 <botlish_fn_7+0xc81>
    1123:	mov    0x148(%rsp),%rsi
    112b:	mov    0x128(%rsp),%rdi
    1133:	call   1138 <botlish_fn_7+0x5c0>
			1134: R_X86_64_PLT32	rt_co_release-0x4
    1138:	mov    0x140(%rsp),%rsi
    1140:	mov    0x128(%rsp),%rdi
    1148:	call   114d <botlish_fn_7+0x5d5>
			1149: R_X86_64_PLT32	rt_co_release-0x4
    114d:	jmp    17f9 <botlish_fn_7+0xc81>
    1152:	mov    %rax,%rcx
    1155:	jmp    1198 <botlish_fn_7+0x620>
    115a:	sar    $1,%rsi
    115d:	mov    %rsi,%rax
    1160:	imulq  0x749(%rip)        # 18b0 <botlish_fn_7+0xd38>
    1167:	lea    (%rdx,%rsi,1),%rax
    116b:	sar    $0x1e,%rax
    116f:	mov    %rax,%rcx
    1172:	shr    $0x3f,%rcx
    1176:	add    %rcx,%rax
    1179:	imul   $0x7fffffff,%rax,%rax
    1180:	sub    %rax,%rsi
    1183:	lea    (%rsi,%r14,1),%rax
    1187:	test   %rsi,%rsi
    118a:	cmovl  %rax,%rsi
    118e:	shl    $1,%rsi
    1191:	or     $0x1,%rsi
    1195:	mov    %rsi,%rcx
    1198:	mov    0x18(%r12),%rax
    119d:	test   %rax,%rax
    11a0:	je     184d <botlish_fn_7+0xcd5>
    11a6:	mov    0x10(%r12),%rax
    11ab:	mov    %rcx,(%rax)
    11ae:	movq   $0x3,0x10(%rsp)
    11b7:	mov    0x10(%r12),%rax
    11bc:	mov    0x8(%rax),%rsi
    11c0:	mov    %rsi,0x20(%rsp)
    11c5:	movq   $0x3,0x28(%rsp)
    11ce:	test   $0x1,%rsi
    11d5:	je     11ed <botlish_fn_7+0x675>
    11db:	mov    %rsi,%rcx
    11de:	add    $0x2,%rcx
    11e2:	seto   %al
    11e5:	test   %al,%al
    11e7:	je     1205 <botlish_fn_7+0x68d>
    11ed:	mov    0x138(%rsp),%rdx
    11f5:	mov    0x128(%rsp),%rdi
    11fd:	call   1202 <botlish_fn_7+0x68a>
			11fe: R_X86_64_PLT32	rt_int_add-0x4
    1202:	mov    %rax,%rcx
    1205:	mov    0x18(%r12),%rax
    120a:	test   %rax,%rax
    120d:	je     1867 <botlish_fn_7+0xcef>
    1213:	mov    0x10(%r12),%rax
    1218:	mov    %rcx,0x8(%rax)
    121c:	mov    0x148(%rsp),%rsi
    1224:	mov    0x128(%rsp),%rdi
    122c:	call   1231 <botlish_fn_7+0x6b9>
			122d: R_X86_64_PLT32	rt_co_resume0-0x4
    1231:	test   %rax,%rax
    1234:	jne    1282 <botlish_fn_7+0x70a>
    123a:	mov    0x128(%rsp),%rdi
    1242:	call   1247 <botlish_fn_7+0x6cf>
			1243: R_X86_64_PLT32	rt_declared_error-0x4
    1247:	cmp    $0x40000001,%rax
    124d:	jne    17f9 <botlish_fn_7+0xc81>
    1253:	mov    0x148(%rsp),%rsi
    125b:	mov    0x128(%rsp),%rdi
    1263:	call   1268 <botlish_fn_7+0x6f0>
			1264: R_X86_64_PLT32	rt_co_release-0x4
    1268:	mov    0x140(%rsp),%rsi
    1270:	mov    0x128(%rsp),%rdi
    1278:	call   127d <botlish_fn_7+0x705>
			1279: R_X86_64_PLT32	rt_co_release-0x4
    127d:	jmp    17f9 <botlish_fn_7+0xc81>
    1282:	mov    %rax,0x10(%rsp)
    1287:	mov    %rax,0x130(%rsp)
    128f:	mov    0x148(%rsp),%rsi
    1297:	mov    0x128(%rsp),%rdi
    129f:	call   12a4 <botlish_fn_7+0x72c>
			12a0: R_X86_64_PLT32	rt_co_done-0x4
    12a4:	cmp    $0x6,%rax
    12a8:	je     14cb <botlish_fn_7+0x953>
    12ae:	lea    0x90(%rsp),%rcx
    12b6:	mov    0x130(%rsp),%rax
    12be:	mov    %rax,0x90(%rsp)
    12c6:	mov    $0x1,%edx
    12cb:	mov    0x128(%rsp),%rdi
    12d3:	mov    %rdx,%rsi
    12d6:	call   12db <botlish_fn_7+0x763>
			12d7: R_X86_64_PLT32	rt_struct_new-0x4
    12db:	mov    %rax,0x20(%rsp)
    12e0:	mov    %rax,%rdx
    12e3:	mov    0x140(%rsp),%rsi
    12eb:	mov    0x128(%rsp),%rdi
    12f3:	call   12f8 <botlish_fn_7+0x780>
			12f4: R_X86_64_PLT32	rt_co_resume-0x4
    12f8:	test   %rax,%rax
    12fb:	jne    14a7 <botlish_fn_7+0x92f>
    1301:	mov    0x128(%rsp),%rdi
    1309:	call   130e <botlish_fn_7+0x796>
			130a: R_X86_64_PLT32	rt_declared_error-0x4
    130e:	cmp    $0x1,%rax
    1312:	je     13eb <botlish_fn_7+0x873>
    1318:	mov    0x128(%rsp),%rdi
    1320:	call   1325 <botlish_fn_7+0x7ad>
			1321: R_X86_64_PLT32	rt_declared_error-0x4
    1325:	cmp    $0x2,%rax
    1329:	jne    17f9 <botlish_fn_7+0xc81>
    132f:	xor    %r12,%r12
    1332:	mov    %r12,%rsi
    1335:	mov    0x128(%rsp),%rdi
    133d:	call   1342 <botlish_fn_7+0x7ca>
			133e: R_X86_64_PLT32	rt_declared_payload-0x4
    1342:	mov    %r12,%rbx
    1345:	mov    %rax,%r12
    1348:	mov    $0x1,%esi
    134d:	mov    0x128(%rsp),%rdi
    1355:	call   135a <botlish_fn_7+0x7e2>
			1356: R_X86_64_PLT32	rt_declared_payload-0x4
    135a:	mov    %rax,%r13
    135d:	mov    0x128(%rsp),%rdi
    1365:	call   136a <botlish_fn_7+0x7f2>
			1366: R_X86_64_PLT32	rt_clear_declared_error-0x4
    136a:	mov    0x148(%rsp),%rsi
    1372:	mov    0x128(%rsp),%rdi
    137a:	call   137f <botlish_fn_7+0x807>
			137b: R_X86_64_PLT32	rt_co_release-0x4
    137f:	mov    0x140(%rsp),%rsi
    1387:	mov    0x128(%rsp),%rdi
    138f:	call   1394 <botlish_fn_7+0x81c>
			1390: R_X86_64_PLT32	rt_co_release-0x4
    1394:	mov    0x128(%rsp),%rdi
    139c:	mov    0x10(%rdi),%r11
    13a0:	mov    0x88(%r11),%rdx
    13a7:	lea    0xb0(%rsp),%r9
    13af:	movq   $0x1,0xb0(%rsp)
    13bb:	mov    %r12,%rax
    13be:	mov    %rax,0xb8(%rsp)
    13c6:	mov    %r13,%rax
    13c9:	mov    %rax,0xc0(%rsp)
    13d1:	mov    $0xc,%esi
    13d6:	mov    %rbx,%rcx
    13d9:	mov    0x138(%rsp),%r8
    13e1:	call   13e6 <botlish_fn_7+0x86e>
			13e2: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    13e6:	jmp    17f9 <botlish_fn_7+0xc81>
    13eb:	xor    %r15,%r15
    13ee:	mov    %r15,%rsi
    13f1:	mov    0x128(%rsp),%rdi
    13f9:	call   13fe <botlish_fn_7+0x886>
			13fa: R_X86_64_PLT32	rt_declared_payload-0x4
    13fe:	mov    %r15,%rbx
    1401:	mov    %rax,%r12
    1404:	mov    $0x1,%esi
    1409:	mov    0x128(%rsp),%rdi
    1411:	call   1416 <botlish_fn_7+0x89e>
			1412: R_X86_64_PLT32	rt_declared_payload-0x4
    1416:	mov    %rax,%r13
    1419:	mov    0x128(%rsp),%rdi
    1421:	call   1426 <botlish_fn_7+0x8ae>
			1422: R_X86_64_PLT32	rt_clear_declared_error-0x4
    1426:	mov    0x148(%rsp),%rsi
    142e:	mov    0x128(%rsp),%rdi
    1436:	call   143b <botlish_fn_7+0x8c3>
			1437: R_X86_64_PLT32	rt_co_release-0x4
    143b:	mov    0x140(%rsp),%rsi
    1443:	mov    0x128(%rsp),%rdi
    144b:	call   1450 <botlish_fn_7+0x8d8>
			144c: R_X86_64_PLT32	rt_co_release-0x4
    1450:	mov    0x128(%rsp),%rdi
    1458:	mov    0x10(%rdi),%rax
    145c:	mov    0x88(%rax),%rdx
    1463:	lea    0x98(%rsp),%r9
    146b:	movq   $0x1,0x98(%rsp)
    1477:	mov    %r12,%rax
    147a:	mov    %rax,0xa0(%rsp)
    1482:	mov    %r13,%rax
    1485:	mov    %rax,0xa8(%rsp)
    148d:	mov    $0xc,%esi
    1492:	mov    %rbx,%rcx
    1495:	mov    0x138(%rsp),%r8
    149d:	call   14a2 <botlish_fn_7+0x92a>
			149e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    14a2:	jmp    17f9 <botlish_fn_7+0xc81>
    14a7:	mov    0x18(%r12),%rax
    14ac:	test   %rax,%rax
    14af:	je     1884 <botlish_fn_7+0xd0c>
    14b5:	mov    0x130(%rsp),%rcx
    14bd:	mov    0x10(%r12),%rax
    14c2:	mov    %rcx,0x10(%rax)
    14c6:	jmp    fa4 <botlish_fn_7+0x42c>
    14cb:	mov    0x148(%rsp),%rsi
    14d3:	mov    0x128(%rsp),%rdi
    14db:	call   14e0 <botlish_fn_7+0x968>
			14dc: R_X86_64_PLT32	rt_co_release-0x4
    14e0:	movq   $0xffffffffffffffff,0x8(%rsp)
    14e9:	lea    0xc8(%rsp),%rcx
    14f1:	movq   $0xffffffffffffffff,0xc8(%rsp)
    14fd:	mov    $0x1,%edx
    1502:	mov    0x128(%rsp),%rdi
    150a:	mov    %rdx,%rsi
    150d:	call   1512 <botlish_fn_7+0x99a>
			150e: R_X86_64_PLT32	rt_struct_new-0x4
    1512:	mov    %rax,0x8(%rsp)
    1517:	mov    %rax,%rdx
    151a:	mov    0x140(%rsp),%rsi
    1522:	mov    0x128(%rsp),%rdi
    152a:	call   152f <botlish_fn_7+0x9b7>
			152b: R_X86_64_PLT32	rt_co_resume-0x4
    152f:	test   %rax,%rax
    1532:	mov    %rax,%r14
    1535:	jne    16b1 <botlish_fn_7+0xb39>
    153b:	mov    0x128(%rsp),%rdi
    1543:	call   1548 <botlish_fn_7+0x9d0>
			1544: R_X86_64_PLT32	rt_declared_error-0x4
    1548:	cmp    $0x1,%rax
    154c:	je     160d <botlish_fn_7+0xa95>
    1552:	mov    0x128(%rsp),%rdi
    155a:	call   155f <botlish_fn_7+0x9e7>
			155b: R_X86_64_PLT32	rt_declared_error-0x4
    155f:	cmp    $0x2,%rax
    1563:	jne    17f9 <botlish_fn_7+0xc81>
    1569:	xor    %rbx,%rbx
    156c:	mov    %rbx,%rsi
    156f:	mov    0x128(%rsp),%rdi
    1577:	call   157c <botlish_fn_7+0xa04>
			1578: R_X86_64_PLT32	rt_declared_payload-0x4
    157c:	mov    %rax,%r12
    157f:	mov    $0x1,%esi
    1584:	mov    0x128(%rsp),%rdi
    158c:	call   1591 <botlish_fn_7+0xa19>
			158d: R_X86_64_PLT32	rt_declared_payload-0x4
    1591:	mov    %rax,%r13
    1594:	mov    0x128(%rsp),%rdi
    159c:	call   15a1 <botlish_fn_7+0xa29>
			159d: R_X86_64_PLT32	rt_clear_declared_error-0x4
    15a1:	mov    0x140(%rsp),%rsi
    15a9:	mov    0x128(%rsp),%rdi
    15b1:	call   15b6 <botlish_fn_7+0xa3e>
			15b2: R_X86_64_PLT32	rt_co_release-0x4
    15b6:	mov    0x128(%rsp),%rdi
    15be:	mov    0x10(%rdi),%rax
    15c2:	mov    0x88(%rax),%rdx
    15c9:	lea    0xe8(%rsp),%r9
    15d1:	movq   $0x1,0xe8(%rsp)
    15dd:	mov    %r12,%rax
    15e0:	mov    %rax,0xf0(%rsp)
    15e8:	mov    %r13,%rax
    15eb:	mov    %rax,0xf8(%rsp)
    15f3:	mov    $0xc,%esi
    15f8:	mov    %rbx,%rcx
    15fb:	mov    0x138(%rsp),%r8
    1603:	call   1608 <botlish_fn_7+0xa90>
			1604: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1608:	jmp    17f9 <botlish_fn_7+0xc81>
    160d:	xor    %rbx,%rbx
    1610:	mov    %rbx,%rsi
    1613:	mov    0x128(%rsp),%rdi
    161b:	call   1620 <botlish_fn_7+0xaa8>
			161c: R_X86_64_PLT32	rt_declared_payload-0x4
    1620:	mov    %rax,%r12
    1623:	mov    $0x1,%esi
    1628:	mov    0x128(%rsp),%rdi
    1630:	call   1635 <botlish_fn_7+0xabd>
			1631: R_X86_64_PLT32	rt_declared_payload-0x4
    1635:	mov    %rax,%r13
    1638:	mov    0x128(%rsp),%rdi
    1640:	call   1645 <botlish_fn_7+0xacd>
			1641: R_X86_64_PLT32	rt_clear_declared_error-0x4
    1645:	mov    0x140(%rsp),%rsi
    164d:	mov    0x128(%rsp),%rdi
    1655:	call   165a <botlish_fn_7+0xae2>
			1656: R_X86_64_PLT32	rt_co_release-0x4
    165a:	mov    0x128(%rsp),%rdi
    1662:	mov    0x10(%rdi),%rax
    1666:	mov    0x88(%rax),%rdx
    166d:	lea    0xd0(%rsp),%r9
    1675:	movq   $0x1,0xd0(%rsp)
    1681:	mov    %r12,%rax
    1684:	mov    %rax,0xd8(%rsp)
    168c:	mov    %r13,%rax
    168f:	mov    %rax,0xe0(%rsp)
    1697:	mov    $0xc,%esi
    169c:	mov    %rbx,%rcx
    169f:	mov    0x138(%rsp),%r8
    16a7:	call   16ac <botlish_fn_7+0xb34>
			16a8: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    16ac:	jmp    17f9 <botlish_fn_7+0xc81>
    16b1:	mov    0x140(%rsp),%rsi
    16b9:	mov    0x128(%rsp),%rdi
    16c1:	call   16c6 <botlish_fn_7+0xb4e>
			16c2: R_X86_64_PLT32	rt_co_release-0x4
    16c6:	mov    %r14,%rax
    16c9:	test   $0x1,%rax
    16cf:	jne    16fa <botlish_fn_7+0xb82>
    16d5:	mov    $0x1,%edx
    16da:	mov    %r14,%rsi
    16dd:	mov    0x128(%rsp),%rdi
    16e5:	call   16ea <botlish_fn_7+0xb72>
			16e6: R_X86_64_PLT32	rt_int_cmp-0x4
    16ea:	test   %rax,%rax
    16ed:	cmove  0x1c3(%rip),%r15        # 18b8 <botlish_fn_7+0xd40>
    16f5:	jmp    1709 <botlish_fn_7+0xb91>
    16fa:	mov    %r14,%rsi
    16fd:	cmp    $0x1,%rsi
    1701:	cmove  0x1af(%rip),%r15        # 18b8 <botlish_fn_7+0xd40>
    1709:	cmp    $0x6,%r15
    170d:	je     176f <botlish_fn_7+0xbf7>
    1713:	mov    0x128(%rsp),%rdi
    171b:	mov    0x10(%rdi),%rdx
    171f:	mov    0x60(%rdx),%rax
    1723:	mov    0x90(%rdx),%rcx
    172a:	mov    0x88(%rdx),%rdx
    1731:	lea    0x100(%rsp),%r9
    1739:	movq   $0x1,0x100(%rsp)
    1745:	mov    %rax,0x108(%rsp)
    174d:	mov    %rcx,0x110(%rsp)
    1755:	mov    $0xc,%esi
    175a:	xor    %rcx,%rcx
    175d:	mov    0x138(%rsp),%r8
    1765:	call   176a <botlish_fn_7+0xbf2>
			1766: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    176a:	jmp    17f9 <botlish_fn_7+0xc81>
    176f:	add    $0x1,%rbx
    1776:	mov    %r12,%rax
    1779:	jmp    c1e <botlish_fn_7+0xa6>
    177e:	mov    0x148(%rsp),%rsi
    1786:	mov    0x128(%rsp),%rdi
    178e:	call   1793 <botlish_fn_7+0xc1b>
			178f: R_X86_64_PLT32	rt_co_release-0x4
    1793:	mov    0x140(%rsp),%rsi
    179b:	mov    0x128(%rsp),%rdi
    17a3:	call   17a8 <botlish_fn_7+0xc30>
			17a4: R_X86_64_PLT32	rt_co_release-0x4
    17a8:	mov    0x128(%rsp),%rdi
    17b0:	mov    0x10(%rdi),%rdx
    17b4:	mov    0x60(%rdx),%rax
    17b8:	mov    0x90(%rdx),%rcx
    17bf:	mov    0x88(%rdx),%rdx
    17c6:	lea    0x78(%rsp),%r9
    17cb:	movq   $0x1,0x78(%rsp)
    17d4:	mov    %rax,0x80(%rsp)
    17dc:	mov    %rcx,0x88(%rsp)
    17e4:	mov    $0xc,%esi
    17e9:	xor    %rcx,%rcx
    17ec:	mov    0x138(%rsp),%r8
    17f4:	call   17f9 <botlish_fn_7+0xc81>
			17f5: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    17f9:	xor    %rax,%rax
    17fc:	mov    0x150(%rsp),%rbx
    1804:	mov    0x158(%rsp),%r12
    180c:	mov    0x160(%rsp),%r13
    1814:	mov    0x168(%rsp),%r14
    181c:	mov    0x170(%rsp),%r15
    1824:	add    $0x180,%rsp
    182b:	mov    %rbp,%rsp
    182e:	pop    %rbp
    182f:	ret
    1830:	mov    $0x5,%edx
    1835:	mov    %r14,%rcx
    1838:	mov    %r12,%rsi
    183b:	mov    0x128(%rsp),%rdi
    1843:	call   1848 <botlish_fn_7+0xcd0>
			1844: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1848:	jmp    f81 <botlish_fn_7+0x409>
    184d:	mov    $0x1,%edx
    1852:	mov    %r12,%rsi
    1855:	mov    0x128(%rsp),%rdi
    185d:	call   1862 <botlish_fn_7+0xcea>
			185e: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1862:	jmp    11ae <botlish_fn_7+0x636>
    1867:	mov    0x138(%rsp),%rdx
    186f:	mov    %r12,%rsi
    1872:	mov    0x128(%rsp),%rdi
    187a:	call   187f <botlish_fn_7+0xd07>
			187b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    187f:	jmp    121c <botlish_fn_7+0x6a4>
    1884:	mov    $0x5,%edx
    1889:	mov    0x130(%rsp),%rcx
    1891:	mov    %r12,%rsi
    1894:	mov    0x128(%rsp),%rdi
    189c:	call   18a1 <botlish_fn_7+0xd29>
			189d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    18a1:	jmp    fa4 <botlish_fn_7+0x42c>
    18a6:	add    %al,(%rax)
    18a8:	ds add %al,(%rax)
    18ab:	add    %al,(%rax)
    18ad:	add    %al,(%rax)
    18af:	add    %al,(%rbx)
    18b1:	add    %al,(%rax)
    18b3:	add    %al,(%rcx)
    18b5:	add    %al,(%rax)
    18b7:	addb   $0x0,(%rsi)
    18ba:	add    %al,(%rax)
    18bc:	add    %al,(%rax)
	...

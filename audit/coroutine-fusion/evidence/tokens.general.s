<botlish_fn_6>:
     b28:	push   %rbp
     b29:	mov    %rsp,%rbp
     b2c:	sub    $0xc0,%rsp
     b33:	mov    %rbx,0x90(%rsp)
     b3b:	mov    %r12,0x98(%rsp)
     b43:	mov    %r13,0xa0(%rsp)
     b4b:	mov    %r14,0xa8(%rsp)
     b53:	mov    %r15,0xb0(%rsp)
     b5b:	mov    %rdi,%r15
     b5e:	movq   $0x0,0x8(%rsp)
     b67:	movq   $0x0,0x10(%rsp)
     b70:	movq   $0x0,0x18(%rsp)
     b79:	movq   $0x0,0x20(%rsp)
     b82:	movq   $0x0,0x28(%rsp)
     b8b:	movq   $0x0,0x30(%rsp)
     b94:	movq   $0x0,0x38(%rsp)
     b9d:	mov    %rsi,(%rsp)
     ba1:	lea    0x40(%rsp),%r8
     ba6:	mov    %rsi,0x40(%rsp)
     bab:	mov    $0x7,%esi
     bb0:	mov    0x0(%rip),%rdx        # bb7 <botlish_fn_6+0x8f>
			bb3: R_X86_64_GOTPCREL	botlish_entry_7-0x4
     bb7:	mov    $0x1,%ecx
     bbc:	mov    %r15,%rdi
     bbf:	call   bc4 <botlish_fn_6+0x9c>
			bc0: R_X86_64_PLT32	rt_closure_new-0x4
     bc4:	mov    %rax,(%rsp)
     bc8:	mov    %rax,%rsi
     bcb:	mov    %r15,%rdi
     bce:	call   bd3 <botlish_fn_6+0xab>
			bcf: R_X86_64_PLT32	rt_co_create-0x4
     bd3:	mov    %rax,0x88(%rsp)
     bdb:	mov    %rax,(%rsp)
     bdf:	mov    0x88(%rsp),%rsi
     be7:	mov    %r15,%rdi
     bea:	call   bef <botlish_fn_6+0xc7>
			beb: R_X86_64_PLT32	rt_co_start-0x4
     bef:	test   %rax,%rax
     bf2:	jne    c21 <botlish_fn_6+0xf9>
     bf8:	mov    %r15,%rdi
     bfb:	call   c00 <botlish_fn_6+0xd8>
			bfc: R_X86_64_PLT32	rt_declared_error-0x4
     c00:	cmp    $0x40000001,%rax
     c06:	jne    159f <botlish_fn_6+0xa77>
     c0c:	mov    0x88(%rsp),%rsi
     c14:	mov    %r15,%rdi
     c17:	call   c1c <botlish_fn_6+0xf4>
			c18: R_X86_64_PLT32	rt_co_release-0x4
     c1c:	jmp    159f <botlish_fn_6+0xa77>
     c21:	mov    %rax,0x8(%rsp)
     c26:	mov    %rax,%rdx
     c29:	mov    $0x3,%esi
     c2e:	movq   $0x3,0x10(%rsp)
     c37:	mov    %r15,%rdi
     c3a:	call   c3f <botlish_fn_6+0x117>
			c3b: R_X86_64_PLT32	rt_mutarray_create-0x4
     c3f:	test   %rax,%rax
     c42:	je     159f <botlish_fn_6+0xa77>
     c48:	mov    %rax,0x8(%rsp)
     c4d:	mov    %rax,%r12
     c50:	mov    $0x9,%esi
     c55:	movq   $0x9,0x10(%rsp)
     c5e:	mov    $0x1,%edx
     c63:	movq   $0x1,0x18(%rsp)
     c6c:	mov    %r15,%rdi
     c6f:	call   c74 <botlish_fn_6+0x14c>
			c70: R_X86_64_PLT32	rt_mutarray_create-0x4
     c74:	test   %rax,%rax
     c77:	je     159f <botlish_fn_6+0xa77>
     c7d:	mov    %rax,0x10(%rsp)
     c82:	mov    %rax,%r14
     c85:	mov    $0xffffffffffffffff,%rbx
     c8c:	mov    0x10(%r12),%rax
     c91:	mov    (%rax),%rsi
     c94:	test   $0x1,%rsi
     c9b:	mov    %rsi,%r13
     c9e:	jne    cc7 <botlish_fn_6+0x19f>
     ca4:	mov    %rbx,%rdx
     ca7:	mov    %r13,%rsi
     caa:	mov    %r15,%rdi
     cad:	call   cb2 <botlish_fn_6+0x18a>
			cae: R_X86_64_PLT32	rt_int_cmp-0x4
     cb2:	mov    $0x2,%ecx
     cb7:	test   %rax,%rax
     cba:	cmove  0x9f6(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     cc2:	jmp    cdb <botlish_fn_6+0x1b3>
     cc7:	mov    $0x2,%ecx
     ccc:	mov    %r13,%rsi
     ccf:	cmp    $0xffffffffffffffff,%rsi
     cd3:	cmove  0x9dd(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     cdb:	cmp    $0x6,%rcx
     cdf:	je     152b <botlish_fn_6+0xa03>
     ce5:	mov    %r13,%rsi
     ce8:	test   $0x1,%rsi
     cef:	jne    d1b <botlish_fn_6+0x1f3>
     cf5:	mov    $0x5b,%edx
     cfa:	mov    %r13,%rsi
     cfd:	mov    %r15,%rdi
     d00:	call   d05 <botlish_fn_6+0x1dd>
			d01: R_X86_64_PLT32	rt_int_cmp-0x4
     d05:	mov    $0x2,%r9d
     d0b:	test   %rax,%rax
     d0e:	cmove  0x9a2(%rip),%r9        # 16b8 <botlish_fn_6+0xb90>
     d16:	jmp    d30 <botlish_fn_6+0x208>
     d1b:	mov    $0x2,%r9d
     d21:	mov    %r13,%rsi
     d24:	cmp    $0x5b,%rsi
     d28:	cmove  0x988(%rip),%r9        # 16b8 <botlish_fn_6+0xb90>
     d30:	cmp    $0x6,%r9
     d34:	jne    d42 <botlish_fn_6+0x21a>
     d3a:	mov    %r15,%rdi
     d3d:	jmp    12e8 <botlish_fn_6+0x7c0>
     d42:	mov    %r13,%rsi
     d45:	mov    %r15,%rdi
     d48:	call   d4d <botlish_fn_6+0x225>
			d49: R_X86_64_PLT32	botlish_fn_1-0x4
     d4d:	cmp    $0x6,%rax
     d51:	jne    d5f <botlish_fn_6+0x237>
     d57:	mov    %r15,%rdi
     d5a:	jmp    12e8 <botlish_fn_6+0x7c0>
     d5f:	mov    %r13,%rsi
     d62:	test   $0x1,%rsi
     d69:	jne    d94 <botlish_fn_6+0x26c>
     d6f:	mov    $0x45,%edx
     d74:	mov    %r13,%rsi
     d77:	mov    %r15,%rdi
     d7a:	call   d7f <botlish_fn_6+0x257>
			d7b: R_X86_64_PLT32	rt_int_cmp-0x4
     d7f:	mov    $0x2,%ecx
     d84:	test   %rax,%rax
     d87:	cmove  0x929(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     d8f:	jmp    da8 <botlish_fn_6+0x280>
     d94:	mov    $0x2,%ecx
     d99:	mov    %r13,%rsi
     d9c:	cmp    $0x45,%rsi
     da0:	cmove  0x910(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     da8:	cmp    $0x6,%rcx
     dac:	je     10a6 <botlish_fn_6+0x57e>
     db2:	mov    %r13,%rsi
     db5:	test   $0x1,%rsi
     dbc:	jne    de7 <botlish_fn_6+0x2bf>
     dc2:	mov    $0xf7,%edx
     dc7:	mov    %r13,%rsi
     dca:	mov    %r15,%rdi
     dcd:	call   dd2 <botlish_fn_6+0x2aa>
			dce: R_X86_64_PLT32	rt_int_cmp-0x4
     dd2:	mov    $0x2,%ecx
     dd7:	test   %rax,%rax
     dda:	cmove  0x8d6(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     de2:	jmp    dfe <botlish_fn_6+0x2d6>
     de7:	mov    $0x2,%ecx
     dec:	mov    %r13,%rsi
     def:	cmp    $0xf7,%rsi
     df6:	cmove  0x8ba(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     dfe:	cmp    $0x6,%rcx
     e02:	je     fb0 <botlish_fn_6+0x488>
     e08:	mov    %r13,%rsi
     e0b:	test   $0x1,%rsi
     e12:	jne    e3d <botlish_fn_6+0x315>
     e18:	mov    $0xfb,%edx
     e1d:	mov    %r13,%rsi
     e20:	mov    %r15,%rdi
     e23:	call   e28 <botlish_fn_6+0x300>
			e24: R_X86_64_PLT32	rt_int_cmp-0x4
     e28:	mov    $0x2,%ecx
     e2d:	test   %rax,%rax
     e30:	cmove  0x880(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     e38:	jmp    e54 <botlish_fn_6+0x32c>
     e3d:	mov    $0x2,%ecx
     e42:	mov    %r13,%rsi
     e45:	cmp    $0xfb,%rsi
     e4c:	cmove  0x864(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     e54:	cmp    $0x6,%rcx
     e58:	je     fb0 <botlish_fn_6+0x488>
     e5e:	mov    %r13,%rsi
     e61:	test   $0x1,%rsi
     e68:	jne    e93 <botlish_fn_6+0x36b>
     e6e:	mov    $0xb7,%edx
     e73:	mov    %r13,%rsi
     e76:	mov    %r15,%rdi
     e79:	call   e7e <botlish_fn_6+0x356>
			e7a: R_X86_64_PLT32	rt_int_cmp-0x4
     e7e:	mov    $0x2,%ecx
     e83:	test   %rax,%rax
     e86:	cmove  0x82a(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     e8e:	jmp    eaa <botlish_fn_6+0x382>
     e93:	mov    $0x2,%ecx
     e98:	mov    %r13,%rsi
     e9b:	cmp    $0xb7,%rsi
     ea2:	cmove  0x80e(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     eaa:	cmp    $0x6,%rcx
     eae:	je     fb0 <botlish_fn_6+0x488>
     eb4:	mov    %r13,%rsi
     eb7:	test   $0x1,%rsi
     ebe:	jne    ee9 <botlish_fn_6+0x3c1>
     ec4:	mov    $0xbb,%edx
     ec9:	mov    %r13,%rsi
     ecc:	mov    %r15,%rdi
     ecf:	call   ed4 <botlish_fn_6+0x3ac>
			ed0: R_X86_64_PLT32	rt_int_cmp-0x4
     ed4:	mov    $0x2,%ecx
     ed9:	test   %rax,%rax
     edc:	cmove  0x7d4(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     ee4:	jmp    f00 <botlish_fn_6+0x3d8>
     ee9:	mov    $0x2,%ecx
     eee:	mov    %r13,%rsi
     ef1:	cmp    $0xbb,%rsi
     ef8:	cmove  0x7b8(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     f00:	cmp    $0x6,%rcx
     f04:	je     fb0 <botlish_fn_6+0x488>
     f0a:	mov    %r13,%rsi
     f0d:	test   $0x1,%rsi
     f14:	jne    f3f <botlish_fn_6+0x417>
     f1a:	mov    $0x75,%edx
     f1f:	mov    %r13,%rsi
     f22:	mov    %r15,%rdi
     f25:	call   f2a <botlish_fn_6+0x402>
			f26: R_X86_64_PLT32	rt_int_cmp-0x4
     f2a:	mov    $0x2,%ecx
     f2f:	test   %rax,%rax
     f32:	cmove  0x77e(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     f3a:	jmp    f53 <botlish_fn_6+0x42b>
     f3f:	mov    $0x2,%ecx
     f44:	mov    %r13,%rsi
     f47:	cmp    $0x75,%rsi
     f4b:	cmove  0x765(%rip),%rcx        # 16b8 <botlish_fn_6+0xb90>
     f53:	cmp    $0x6,%rcx
     f57:	je     fb0 <botlish_fn_6+0x488>
     f5d:	mov    %r13,%rsi
     f60:	test   $0x1,%rsi
     f67:	jne    f92 <botlish_fn_6+0x46a>
     f6d:	mov    $0x59,%edx
     f72:	mov    %r13,%rsi
     f75:	mov    %r15,%rdi
     f78:	call   f7d <botlish_fn_6+0x455>
			f79: R_X86_64_PLT32	rt_int_cmp-0x4
     f7d:	mov    $0x2,%edx
     f82:	test   %rax,%rax
     f85:	cmove  0x72b(%rip),%rdx        # 16b8 <botlish_fn_6+0xb90>
     f8d:	jmp    fa6 <botlish_fn_6+0x47e>
     f92:	mov    $0x2,%edx
     f97:	mov    %r13,%rsi
     f9a:	cmp    $0x59,%rsi
     f9e:	cmove  0x712(%rip),%rdx        # 16b8 <botlish_fn_6+0xb90>
     fa6:	cmp    $0x6,%rdx
     faa:	jne    1013 <botlish_fn_6+0x4eb>
     fb0:	movq   $0x5,0x18(%rsp)
     fb9:	mov    0x10(%r14),%rax
     fbd:	mov    0x10(%rax),%rsi
     fc1:	mov    %rsi,0x20(%rsp)
     fc6:	movq   $0x3,0x28(%rsp)
     fcf:	test   $0x1,%rsi
     fd6:	je     fee <botlish_fn_6+0x4c6>
     fdc:	mov    %rsi,%rcx
     fdf:	add    $0x2,%rcx
     fe3:	seto   %al
     fe6:	test   %al,%al
     fe8:	je     ffe <botlish_fn_6+0x4d6>
     fee:	mov    $0x3,%edx
     ff3:	mov    %r15,%rdi
     ff6:	call   ffb <botlish_fn_6+0x4d3>
			ff7: R_X86_64_PLT32	rt_int_add-0x4
     ffb:	mov    %rax,%rcx
     ffe:	mov    0x18(%r14),%rax
    1002:	test   %rax,%rax
    1005:	je     160a <botlish_fn_6+0xae2>
    100b:	mov    0x10(%r14),%rax
    100f:	mov    %rcx,0x10(%rax)
    1013:	movq   $0x1,0x18(%rsp)
    101c:	mov    0x88(%rsp),%rsi
    1024:	mov    %r15,%rdi
    1027:	call   102c <botlish_fn_6+0x504>
			1028: R_X86_64_PLT32	rt_co_resume0-0x4
    102c:	test   %rax,%rax
    102f:	mov    %rax,%rcx
    1032:	jne    1085 <botlish_fn_6+0x55d>
    1038:	mov    %r15,%rdi
    103b:	call   1040 <botlish_fn_6+0x518>
			103c: R_X86_64_PLT32	rt_declared_error-0x4
    1040:	cmp    $0x40000001,%rax
    1046:	jne    105c <botlish_fn_6+0x534>
    104c:	mov    0x88(%rsp),%rsi
    1054:	mov    %r15,%rdi
    1057:	call   105c <botlish_fn_6+0x534>
			1058: R_X86_64_PLT32	rt_co_release-0x4
    105c:	mov    %r15,%rdi
    105f:	call   1064 <botlish_fn_6+0x53c>
			1060: R_X86_64_PLT32	rt_declared_error-0x4
    1064:	cmp    $0x40000001,%rax
    106a:	jne    159f <botlish_fn_6+0xa77>
    1070:	mov    0x88(%rsp),%rsi
    1078:	mov    %r15,%rdi
    107b:	call   1080 <botlish_fn_6+0x558>
			107c: R_X86_64_PLT32	rt_co_release-0x4
    1080:	jmp    159f <botlish_fn_6+0xa77>
    1085:	mov    0x18(%r12),%rax
    108a:	test   %rax,%rax
    108d:	je     161f <botlish_fn_6+0xaf7>
    1093:	mov    0x10(%r12),%rax
    1098:	mov    %rcx,(%rax)
    109b:	mov    $0xa,%r9d
    10a1:	jmp    c8c <botlish_fn_6+0x164>
    10a6:	mov    %r15,%rdi
    10a9:	mov    0x10(%rdi),%rax
    10ad:	mov    0x10(%rax),%rsi
    10b1:	mov    %rsi,0x18(%rsp)
    10b6:	call   10bb <botlish_fn_6+0x593>
			10b7: R_X86_64_PLT32	rt_co_create-0x4
    10bb:	mov    %rax,0x78(%rsp)
    10c0:	mov    %rax,0x18(%rsp)
    10c5:	mov    0x78(%rsp),%rsi
    10ca:	mov    %r15,%rdi
    10cd:	call   10d2 <botlish_fn_6+0x5aa>
			10ce: R_X86_64_PLT32	rt_co_start-0x4
    10d2:	test   %rax,%rax
    10d5:	je     159f <botlish_fn_6+0xa77>
    10db:	lea    0x50(%rsp),%r13
    10e0:	mov    0x10(%r12),%rdx
    10e5:	mov    (%rdx),%rdx
    10e8:	mov    %rdx,0x20(%rsp)
    10ed:	mov    %rdx,0x50(%rsp)
    10f2:	xor    %rsi,%rsi
    10f5:	mov    $0x1,%edx
    10fa:	mov    %r13,%rcx
    10fd:	mov    %r15,%rdi
    1100:	call   1105 <botlish_fn_6+0x5dd>
			1101: R_X86_64_PLT32	rt_struct_new-0x4
    1105:	mov    %rax,0x20(%rsp)
    110a:	mov    %rax,%rdx
    110d:	mov    0x78(%rsp),%rsi
    1112:	mov    %r15,%rdi
    1115:	call   111a <botlish_fn_6+0x5f2>
			1116: R_X86_64_PLT32	rt_co_resume-0x4
    111a:	test   %rax,%rax
    111d:	je     159f <botlish_fn_6+0xa77>
    1123:	mov    %rax,0x20(%rsp)
    1128:	mov    0x18(%rax),%r10
    112c:	mov    %rax,0x80(%rsp)
    1134:	mov    (%r10),%r10
    1137:	cmp    $0x6,%r10
    113b:	je     114e <botlish_fn_6+0x626>
    1141:	mov    0x80(%rsp),%rax
    1149:	jmp    125b <botlish_fn_6+0x733>
    114e:	movq   $0x7,0x28(%rsp)
    1157:	mov    0x10(%r14),%rax
    115b:	mov    0x18(%rax),%rsi
    115f:	mov    %rsi,0x30(%rsp)
    1164:	movq   $0x3,0x38(%rsp)
    116d:	test   $0x1,%rsi
    1174:	je     118c <botlish_fn_6+0x664>
    117a:	mov    %rsi,%rcx
    117d:	add    $0x2,%rcx
    1181:	seto   %al
    1184:	test   %al,%al
    1186:	je     119c <botlish_fn_6+0x674>
    118c:	mov    $0x3,%edx
    1191:	mov    %r15,%rdi
    1194:	call   1199 <botlish_fn_6+0x671>
			1195: R_X86_64_PLT32	rt_int_add-0x4
    1199:	mov    %rax,%rcx
    119c:	mov    0x18(%r14),%rax
    11a0:	test   %rax,%rax
    11a3:	je     1634 <botlish_fn_6+0xb0c>
    11a9:	mov    0x10(%r14),%rax
    11ad:	mov    %rcx,0x18(%rax)
    11b1:	movq   $0x1,0x28(%rsp)
    11ba:	mov    0x88(%rsp),%rsi
    11c2:	mov    %r15,%rdi
    11c5:	call   11ca <botlish_fn_6+0x6a2>
			11c6: R_X86_64_PLT32	rt_co_resume0-0x4
    11ca:	test   %rax,%rax
    11cd:	mov    %rax,%rcx
    11d0:	jne    123d <botlish_fn_6+0x715>
    11d6:	mov    %r15,%rdi
    11d9:	call   11de <botlish_fn_6+0x6b6>
			11da: R_X86_64_PLT32	rt_declared_error-0x4
    11de:	cmp    $0x40000001,%rax
    11e4:	jne    1207 <botlish_fn_6+0x6df>
    11ea:	mov    0x88(%rsp),%rsi
    11f2:	mov    %r15,%rdi
    11f5:	call   11fa <botlish_fn_6+0x6d2>
			11f6: R_X86_64_PLT32	rt_co_release-0x4
    11fa:	mov    0x78(%rsp),%rsi
    11ff:	mov    %r15,%rdi
    1202:	call   1207 <botlish_fn_6+0x6df>
			1203: R_X86_64_PLT32	rt_co_release-0x4
    1207:	mov    %r15,%rdi
    120a:	call   120f <botlish_fn_6+0x6e7>
			120b: R_X86_64_PLT32	rt_declared_error-0x4
    120f:	cmp    $0x40000001,%rax
    1215:	jne    159f <botlish_fn_6+0xa77>
    121b:	mov    0x88(%rsp),%rsi
    1223:	mov    %r15,%rdi
    1226:	call   122b <botlish_fn_6+0x703>
			1227: R_X86_64_PLT32	rt_co_release-0x4
    122b:	mov    0x78(%rsp),%rsi
    1230:	mov    %r15,%rdi
    1233:	call   1238 <botlish_fn_6+0x710>
			1234: R_X86_64_PLT32	rt_co_release-0x4
    1238:	jmp    159f <botlish_fn_6+0xa77>
    123d:	mov    0x18(%r12),%rax
    1242:	test   %rax,%rax
    1245:	je     1649 <botlish_fn_6+0xb21>
    124b:	mov    0x10(%r12),%rax
    1250:	mov    %rcx,(%rax)
    1253:	mov    0x80(%rsp),%rax
    125b:	mov    0x18(%rax),%rax
    125f:	mov    0x8(%rax),%rax
    1263:	cmp    $0x6,%rax
    1267:	jne    10e0 <botlish_fn_6+0x5b8>
    126d:	mov    0x78(%rsp),%rsi
    1272:	mov    %r15,%rdi
    1275:	call   127a <botlish_fn_6+0x752>
			1276: R_X86_64_PLT32	rt_co_release-0x4
    127a:	movq   $0x3,0x18(%rsp)
    1283:	mov    0x10(%r14),%rax
    1287:	mov    0x8(%rax),%rsi
    128b:	mov    %rsi,0x20(%rsp)
    1290:	movq   $0x3,0x28(%rsp)
    1299:	test   $0x1,%rsi
    12a0:	je     12b8 <botlish_fn_6+0x790>
    12a6:	mov    %rsi,%rcx
    12a9:	add    $0x2,%rcx
    12ad:	seto   %al
    12b0:	test   %al,%al
    12b2:	je     12c8 <botlish_fn_6+0x7a0>
    12b8:	mov    $0x3,%edx
    12bd:	mov    %r15,%rdi
    12c0:	call   12c5 <botlish_fn_6+0x79d>
			12c1: R_X86_64_PLT32	rt_int_add-0x4
    12c5:	mov    %rax,%rcx
    12c8:	mov    0x18(%r14),%rsi
    12cc:	test   %rsi,%rsi
    12cf:	je     165e <botlish_fn_6+0xb36>
    12d5:	mov    0x10(%r14),%rdi
    12d9:	mov    %rcx,0x8(%rdi)
    12dd:	mov    $0xa,%r9d
    12e3:	jmp    c8c <botlish_fn_6+0x164>
    12e8:	mov    %r15,%rdi
    12eb:	mov    0x10(%rdi),%rax
    12ef:	mov    0x8(%rax),%rsi
    12f3:	mov    %rsi,0x18(%rsp)
    12f8:	call   12fd <botlish_fn_6+0x7d5>
			12f9: R_X86_64_PLT32	rt_co_create-0x4
    12fd:	mov    %rax,0x80(%rsp)
    1305:	mov    %rax,0x18(%rsp)
    130a:	mov    0x80(%rsp),%rsi
    1312:	mov    %r15,%rdi
    1315:	call   131a <botlish_fn_6+0x7f2>
			1316: R_X86_64_PLT32	rt_co_start-0x4
    131a:	test   %rax,%rax
    131d:	je     159f <botlish_fn_6+0xa77>
    1323:	lea    0x48(%rsp),%r13
    1328:	mov    0x10(%r12),%rax
    132d:	mov    (%rax),%rax
    1330:	mov    %rax,0x20(%rsp)
    1335:	mov    %rax,0x48(%rsp)
    133a:	xor    %rsi,%rsi
    133d:	mov    $0x1,%edx
    1342:	mov    %r13,%rcx
    1345:	mov    %r15,%rdi
    1348:	call   134d <botlish_fn_6+0x825>
			1349: R_X86_64_PLT32	rt_struct_new-0x4
    134d:	mov    %rax,0x20(%rsp)
    1352:	mov    %rax,%rdx
    1355:	mov    0x80(%rsp),%rsi
    135d:	mov    %r15,%rdi
    1360:	call   1365 <botlish_fn_6+0x83d>
			1361: R_X86_64_PLT32	rt_co_resume-0x4
    1365:	test   %rax,%rax
    1368:	je     159f <botlish_fn_6+0xa77>
    136e:	mov    %rax,0x20(%rsp)
    1373:	mov    0x18(%rax),%rcx
    1377:	mov    %rax,0x78(%rsp)
    137c:	mov    (%rcx),%rax
    137f:	cmp    $0x6,%rax
    1383:	je     1393 <botlish_fn_6+0x86b>
    1389:	mov    0x78(%rsp),%rax
    138e:	jmp    14a3 <botlish_fn_6+0x97b>
    1393:	movq   $0x7,0x28(%rsp)
    139c:	mov    0x10(%r14),%rax
    13a0:	mov    0x18(%rax),%rsi
    13a4:	mov    %rsi,0x30(%rsp)
    13a9:	movq   $0x3,0x38(%rsp)
    13b2:	test   $0x1,%rsi
    13b9:	je     13d1 <botlish_fn_6+0x8a9>
    13bf:	mov    %rsi,%rcx
    13c2:	add    $0x2,%rcx
    13c6:	seto   %al
    13c9:	test   %al,%al
    13cb:	je     13e1 <botlish_fn_6+0x8b9>
    13d1:	mov    $0x3,%edx
    13d6:	mov    %r15,%rdi
    13d9:	call   13de <botlish_fn_6+0x8b6>
			13da: R_X86_64_PLT32	rt_int_add-0x4
    13de:	mov    %rax,%rcx
    13e1:	mov    0x18(%r14),%rax
    13e5:	test   %rax,%rax
    13e8:	je     1673 <botlish_fn_6+0xb4b>
    13ee:	mov    0x10(%r14),%rax
    13f2:	mov    %rcx,0x18(%rax)
    13f6:	movq   $0x1,0x28(%rsp)
    13ff:	mov    0x88(%rsp),%rsi
    1407:	mov    %r15,%rdi
    140a:	call   140f <botlish_fn_6+0x8e7>
			140b: R_X86_64_PLT32	rt_co_resume0-0x4
    140f:	test   %rax,%rax
    1412:	mov    %rax,%rcx
    1415:	jne    1488 <botlish_fn_6+0x960>
    141b:	mov    %r15,%rdi
    141e:	call   1423 <botlish_fn_6+0x8fb>
			141f: R_X86_64_PLT32	rt_declared_error-0x4
    1423:	cmp    $0x40000001,%rax
    1429:	jne    144f <botlish_fn_6+0x927>
    142f:	mov    0x88(%rsp),%rsi
    1437:	mov    %r15,%rdi
    143a:	call   143f <botlish_fn_6+0x917>
			143b: R_X86_64_PLT32	rt_co_release-0x4
    143f:	mov    0x80(%rsp),%rsi
    1447:	mov    %r15,%rdi
    144a:	call   144f <botlish_fn_6+0x927>
			144b: R_X86_64_PLT32	rt_co_release-0x4
    144f:	mov    %r15,%rdi
    1452:	call   1457 <botlish_fn_6+0x92f>
			1453: R_X86_64_PLT32	rt_declared_error-0x4
    1457:	cmp    $0x40000001,%rax
    145d:	jne    159f <botlish_fn_6+0xa77>
    1463:	mov    0x88(%rsp),%rsi
    146b:	mov    %r15,%rdi
    146e:	call   1473 <botlish_fn_6+0x94b>
			146f: R_X86_64_PLT32	rt_co_release-0x4
    1473:	mov    0x80(%rsp),%rsi
    147b:	mov    %r15,%rdi
    147e:	call   1483 <botlish_fn_6+0x95b>
			147f: R_X86_64_PLT32	rt_co_release-0x4
    1483:	jmp    159f <botlish_fn_6+0xa77>
    1488:	mov    0x18(%r12),%rax
    148d:	test   %rax,%rax
    1490:	je     1688 <botlish_fn_6+0xb60>
    1496:	mov    0x10(%r12),%rax
    149b:	mov    %rcx,(%rax)
    149e:	mov    0x78(%rsp),%rax
    14a3:	mov    0x18(%rax),%rsi
    14a7:	mov    0x8(%rsi),%rsi
    14ab:	cmp    $0x6,%rsi
    14af:	jne    1328 <botlish_fn_6+0x800>
    14b5:	mov    0x80(%rsp),%rsi
    14bd:	mov    %r15,%rdi
    14c0:	call   14c5 <botlish_fn_6+0x99d>
			14c1: R_X86_64_PLT32	rt_co_release-0x4
    14c5:	movq   $0x1,0x18(%rsp)
    14ce:	mov    0x10(%r14),%r9
    14d2:	mov    (%r9),%rsi
    14d5:	mov    %rsi,0x20(%rsp)
    14da:	movq   $0x3,0x28(%rsp)
    14e3:	test   $0x1,%rsi
    14ea:	je     1502 <botlish_fn_6+0x9da>
    14f0:	mov    %rsi,%rcx
    14f3:	add    $0x2,%rcx
    14f7:	seto   %al
    14fa:	test   %al,%al
    14fc:	je     1512 <botlish_fn_6+0x9ea>
    1502:	mov    $0x3,%edx
    1507:	mov    %r15,%rdi
    150a:	call   150f <botlish_fn_6+0x9e7>
			150b: R_X86_64_PLT32	rt_int_add-0x4
    150f:	mov    %rax,%rcx
    1512:	mov    0x18(%r14),%rax
    1516:	test   %rax,%rax
    1519:	je     169d <botlish_fn_6+0xb75>
    151f:	mov    0x10(%r14),%rax
    1523:	mov    %rcx,(%rax)
    1526:	jmp    c8c <botlish_fn_6+0x164>
    152b:	mov    0x88(%rsp),%rsi
    1533:	mov    %r15,%rdi
    1536:	call   153b <botlish_fn_6+0xa13>
			1537: R_X86_64_PLT32	rt_co_release-0x4
    153b:	mov    0x10(%r14),%rax
    153f:	mov    (%rax),%rax
    1542:	mov    %rax,(%rsp)
    1546:	mov    0x10(%r14),%rcx
    154a:	mov    0x8(%rcx),%rcx
    154e:	mov    %rcx,0x8(%rsp)
    1553:	mov    0x10(%r14),%rdx
    1557:	mov    0x10(%rdx),%rdx
    155b:	mov    %rdx,0x18(%rsp)
    1560:	mov    0x10(%r14),%rsi
    1564:	mov    0x18(%rsi),%rsi
    1568:	mov    %rsi,0x10(%rsp)
    156d:	lea    0x58(%rsp),%rdi
    1572:	mov    %rax,0x58(%rsp)
    1577:	mov    %rcx,0x60(%rsp)
    157c:	mov    %rdx,0x68(%rsp)
    1581:	mov    %rsi,0x70(%rsp)
    1586:	mov    $0x4,%esi
    158b:	mov    %rdi,%rdx
    158e:	mov    %r15,%rdi
    1591:	call   1596 <botlish_fn_6+0xa6e>
			1592: R_X86_64_PLT32	rt_list_new-0x4
    1596:	test   %rax,%rax
    1599:	jne    15d6 <botlish_fn_6+0xaae>
    159f:	xor    %rax,%rax
    15a2:	mov    0x90(%rsp),%rbx
    15aa:	mov    0x98(%rsp),%r12
    15b2:	mov    0xa0(%rsp),%r13
    15ba:	mov    0xa8(%rsp),%r14
    15c2:	mov    0xb0(%rsp),%r15
    15ca:	add    $0xc0,%rsp
    15d1:	mov    %rbp,%rsp
    15d4:	pop    %rbp
    15d5:	ret
    15d6:	mov    0x90(%rsp),%rbx
    15de:	mov    0x98(%rsp),%r12
    15e6:	mov    0xa0(%rsp),%r13
    15ee:	mov    0xa8(%rsp),%r14
    15f6:	mov    0xb0(%rsp),%r15
    15fe:	add    $0xc0,%rsp
    1605:	mov    %rbp,%rsp
    1608:	pop    %rbp
    1609:	ret
    160a:	mov    $0x5,%edx
    160f:	mov    %r14,%rsi
    1612:	mov    %r15,%rdi
    1615:	call   161a <botlish_fn_6+0xaf2>
			1616: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    161a:	jmp    1013 <botlish_fn_6+0x4eb>
    161f:	mov    $0x1,%edx
    1624:	mov    %r12,%rsi
    1627:	mov    %r15,%rdi
    162a:	call   162f <botlish_fn_6+0xb07>
			162b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    162f:	jmp    109b <botlish_fn_6+0x573>
    1634:	mov    $0x7,%edx
    1639:	mov    %r14,%rsi
    163c:	mov    %r15,%rdi
    163f:	call   1644 <botlish_fn_6+0xb1c>
			1640: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1644:	jmp    11b1 <botlish_fn_6+0x689>
    1649:	mov    $0x1,%edx
    164e:	mov    %r12,%rsi
    1651:	mov    %r15,%rdi
    1654:	call   1659 <botlish_fn_6+0xb31>
			1655: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1659:	jmp    1253 <botlish_fn_6+0x72b>
    165e:	mov    $0x3,%edx
    1663:	mov    %r14,%rsi
    1666:	mov    %r15,%rdi
    1669:	call   166e <botlish_fn_6+0xb46>
			166a: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    166e:	jmp    12dd <botlish_fn_6+0x7b5>
    1673:	mov    $0x7,%edx
    1678:	mov    %r14,%rsi
    167b:	mov    %r15,%rdi
    167e:	call   1683 <botlish_fn_6+0xb5b>
			167f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1683:	jmp    13f6 <botlish_fn_6+0x8ce>
    1688:	mov    $0x1,%edx
    168d:	mov    %r12,%rsi
    1690:	mov    %r15,%rdi
    1693:	call   1698 <botlish_fn_6+0xb70>
			1694: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1698:	jmp    149e <botlish_fn_6+0x976>
    169d:	mov    $0x1,%edx
    16a2:	mov    %r14,%rsi
    16a5:	mov    %r15,%rdi
    16a8:	call   16ad <botlish_fn_6+0xb85>
			16a9: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    16ad:	jmp    c8c <botlish_fn_6+0x164>
    16b2:	add    %al,(%rax)
    16b4:	add    %al,(%rax)
    16b6:	add    %al,(%rax)
    16b8:	(bad)
    16b9:	add    %al,(%rax)
    16bb:	add    %al,(%rax)
    16bd:	add    %al,(%rax)
	...

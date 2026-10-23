<botlish_fn_6>:
    101c:	push   %rbp
    101d:	mov    %rsp,%rbp
    1020:	sub    $0x50,%rsp
    1024:	mov    %rbx,0x30(%rsp)
    1029:	mov    %r12,0x38(%rsp)
    102e:	mov    %r13,0x40(%rsp)
    1033:	mov    %r14,0x48(%rsp)
    1038:	mov    %rsi,%rbx
    103b:	mov    %rdi,%r13
    103e:	movq   $0x0,0x8(%rsp)
    1047:	xor    %rsi,%rsi
    104a:	mov    %r13,%rdi
    104d:	call   1052 <botlish_fn_6+0x36>
			104e: R_X86_64_PLT32	botlish_fn_5-0x4
    1052:	mov    %rax,(%rsp)
    1056:	lea    0x10(%rsp),%r8
    105b:	mov    %rax,0x10(%rsp)
    1060:	mov    $0x7,%esi
    1065:	mov    0x0(%rip),%rdx        # 106c <botlish_fn_6+0x50>
			1068: R_X86_64_GOTPCREL	botlish_entry_7-0x4
    106c:	mov    $0x1,%ecx
    1071:	mov    %r13,%rdi
    1074:	call   1079 <botlish_fn_6+0x5d>
			1075: R_X86_64_PLT32	rt_closure_new-0x4
    1079:	mov    %rax,(%rsp)
    107d:	mov    %rax,%rsi
    1080:	mov    %r13,%rdi
    1083:	call   1088 <botlish_fn_6+0x6c>
			1084: R_X86_64_PLT32	rt_co_create-0x4
    1088:	mov    %rax,%r14
    108b:	mov    %rax,(%rsp)
    108f:	mov    %r14,%rsi
    1092:	mov    %r13,%rdi
    1095:	call   109a <botlish_fn_6+0x7e>
			1096: R_X86_64_PLT32	rt_co_start-0x4
    109a:	test   %rax,%rax
    109d:	jne    10e7 <botlish_fn_6+0xcb>
    10a3:	mov    %r13,%rdi
    10a6:	call   10ab <botlish_fn_6+0x8f>
			10a7: R_X86_64_PLT32	rt_declared_error-0x4
    10ab:	cmp    $0x2,%rax
    10af:	je     10d7 <botlish_fn_6+0xbb>
    10b5:	mov    %r13,%rdi
    10b8:	call   10bd <botlish_fn_6+0xa1>
			10b9: R_X86_64_PLT32	rt_declared_error-0x4
    10bd:	cmp    $0x1,%rax
    10c1:	jne    1271 <botlish_fn_6+0x255>
    10c7:	mov    %r14,%rsi
    10ca:	mov    %r13,%rdi
    10cd:	call   10d2 <botlish_fn_6+0xb6>
			10ce: R_X86_64_PLT32	rt_co_release-0x4
    10d2:	jmp    1271 <botlish_fn_6+0x255>
    10d7:	mov    %r14,%rsi
    10da:	mov    %r13,%rdi
    10dd:	call   10e2 <botlish_fn_6+0xc6>
			10de: R_X86_64_PLT32	rt_co_release-0x4
    10e2:	jmp    1271 <botlish_fn_6+0x255>
    10e7:	mov    $0x1,%r12d
    10ed:	cmp    %rbx,%r12
    10f0:	jl     11ec <botlish_fn_6+0x1d0>
    10f6:	movq   $0xffffffffffffffff,0x8(%rsp)
    10ff:	lea    0x20(%rsp),%rcx
    1104:	movq   $0xffffffffffffffff,0x20(%rsp)
    110d:	xor    %rsi,%rsi
    1110:	mov    $0x1,%edx
    1115:	mov    %r13,%rdi
    1118:	call   111d <botlish_fn_6+0x101>
			1119: R_X86_64_PLT32	rt_struct_new-0x4
    111d:	mov    %rax,0x8(%rsp)
    1122:	mov    %rax,%rdx
    1125:	mov    %r14,%rsi
    1128:	mov    %r13,%rdi
    112b:	call   1130 <botlish_fn_6+0x114>
			112c: R_X86_64_PLT32	rt_co_resume-0x4
    1130:	test   %rax,%rax
    1133:	jne    117d <botlish_fn_6+0x161>
    1139:	mov    %r13,%rdi
    113c:	call   1141 <botlish_fn_6+0x125>
			113d: R_X86_64_PLT32	rt_declared_error-0x4
    1141:	cmp    $0x2,%rax
    1145:	je     116d <botlish_fn_6+0x151>
    114b:	mov    %r13,%rdi
    114e:	call   1153 <botlish_fn_6+0x137>
			114f: R_X86_64_PLT32	rt_declared_error-0x4
    1153:	cmp    $0x1,%rax
    1157:	jne    1271 <botlish_fn_6+0x255>
    115d:	mov    %r14,%rsi
    1160:	mov    %r13,%rdi
    1163:	call   1168 <botlish_fn_6+0x14c>
			1164: R_X86_64_PLT32	rt_co_release-0x4
    1168:	jmp    1271 <botlish_fn_6+0x255>
    116d:	mov    %r14,%rsi
    1170:	mov    %r13,%rdi
    1173:	call   1178 <botlish_fn_6+0x15c>
			1174: R_X86_64_PLT32	rt_co_release-0x4
    1178:	jmp    1271 <botlish_fn_6+0x255>
    117d:	mov    %r14,%rsi
    1180:	mov    %r13,%rdi
    1183:	call   1188 <botlish_fn_6+0x16c>
			1184: R_X86_64_PLT32	rt_co_done-0x4
    1188:	cmp    $0x6,%rax
    118c:	je     11bf <botlish_fn_6+0x1a3>
    1192:	mov    %r14,%rsi
    1195:	mov    %r13,%rdi
    1198:	call   119d <botlish_fn_6+0x181>
			1199: R_X86_64_PLT32	rt_co_release-0x4
    119d:	mov    $0x1,%eax
    11a2:	mov    0x30(%rsp),%rbx
    11a7:	mov    0x38(%rsp),%r12
    11ac:	mov    0x40(%rsp),%r13
    11b1:	mov    0x48(%rsp),%r14
    11b6:	add    $0x50,%rsp
    11ba:	mov    %rbp,%rsp
    11bd:	pop    %rbp
    11be:	ret
    11bf:	mov    %r14,%rsi
    11c2:	mov    %r13,%rdi
    11c5:	call   11ca <botlish_fn_6+0x1ae>
			11c6: R_X86_64_PLT32	rt_co_release-0x4
    11ca:	mov    $0x3,%eax
    11cf:	mov    0x30(%rsp),%rbx
    11d4:	mov    0x38(%rsp),%r12
    11d9:	mov    0x40(%rsp),%r13
    11de:	mov    0x48(%rsp),%r14
    11e3:	add    $0x50,%rsp
    11e7:	mov    %rbp,%rsp
    11ea:	pop    %rbp
    11eb:	ret
    11ec:	mov    %r12,%rsi
    11ef:	mov    %r13,%rdi
    11f2:	call   11f7 <botlish_fn_6+0x1db>
			11f3: R_X86_64_PLT32	botlish_fn_5-0x4
    11f7:	mov    %rax,0x8(%rsp)
    11fc:	lea    0x18(%rsp),%rcx
    1201:	mov    %rax,0x18(%rsp)
    1206:	xor    %rsi,%rsi
    1209:	mov    $0x1,%edx
    120e:	mov    %r13,%rdi
    1211:	call   1216 <botlish_fn_6+0x1fa>
			1212: R_X86_64_PLT32	rt_struct_new-0x4
    1216:	mov    %rax,0x8(%rsp)
    121b:	mov    %rax,%rdx
    121e:	mov    %r14,%rsi
    1221:	mov    %r13,%rdi
    1224:	call   1229 <botlish_fn_6+0x20d>
			1225: R_X86_64_PLT32	rt_co_resume-0x4
    1229:	test   %rax,%rax
    122c:	jne    1291 <botlish_fn_6+0x275>
    1232:	mov    %r13,%rdi
    1235:	call   123a <botlish_fn_6+0x21e>
			1236: R_X86_64_PLT32	rt_declared_error-0x4
    123a:	cmp    $0x2,%rax
    123e:	je     1266 <botlish_fn_6+0x24a>
    1244:	mov    %r13,%rdi
    1247:	call   124c <botlish_fn_6+0x230>
			1248: R_X86_64_PLT32	rt_declared_error-0x4
    124c:	cmp    $0x1,%rax
    1250:	jne    1271 <botlish_fn_6+0x255>
    1256:	mov    %r14,%rsi
    1259:	mov    %r13,%rdi
    125c:	call   1261 <botlish_fn_6+0x245>
			125d: R_X86_64_PLT32	rt_co_release-0x4
    1261:	jmp    1271 <botlish_fn_6+0x255>
    1266:	mov    %r14,%rsi
    1269:	mov    %r13,%rdi
    126c:	call   1271 <botlish_fn_6+0x255>
			126d: R_X86_64_PLT32	rt_co_release-0x4
    1271:	xor    %rax,%rax
    1274:	mov    0x30(%rsp),%rbx
    1279:	mov    0x38(%rsp),%r12
    127e:	mov    0x40(%rsp),%r13
    1283:	mov    0x48(%rsp),%r14
    1288:	add    $0x50,%rsp
    128c:	mov    %rbp,%rsp
    128f:	pop    %rbp
    1290:	ret
    1291:	add    $0x1,%r12
    1298:	jmp    10ed <botlish_fn_6+0xd1>

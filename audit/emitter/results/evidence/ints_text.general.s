<botlish_fn_8>:
     bd0:	push   %rbp
     bd1:	mov    %rsp,%rbp
     bd4:	sub    $0x90,%rsp
     bdb:	mov    %rbx,0x60(%rsp)
     be0:	mov    %r12,0x68(%rsp)
     be5:	mov    %r13,0x70(%rsp)
     bea:	mov    %r14,0x78(%rsp)
     bef:	mov    %r15,0x80(%rsp)
     bf7:	mov    %rsi,%r12
     bfa:	mov    %rdi,0x48(%rsp)
     bff:	movq   $0x0,0x10(%rsp)
     c08:	movq   $0x0,0x18(%rsp)
     c11:	movq   $0x0,0x20(%rsp)
     c1a:	movq   $0x0,0x28(%rsp)
     c23:	mov    $0x7,%esi
     c28:	movq   $0x7,(%rsp)
     c30:	mov    $0x1,%edx
     c35:	movq   $0x1,0x8(%rsp)
     c3e:	mov    0x48(%rsp),%rdi
     c43:	call   c48 <botlish_fn_8+0x78>
			c44: R_X86_64_PLT32	rt_mutarray_create-0x4
     c48:	test   %rax,%rax
     c4b:	je     10a7 <botlish_fn_8+0x4d7>
     c51:	mov    %rax,(%rsp)
     c55:	xor    %rbx,%rbx
     c58:	mov    %r12,%r13
     c5b:	cmp    %r13,%rbx
     c5e:	jl     cd0 <botlish_fn_8+0x100>
     c64:	mov    %rax,%r12
     c67:	mov    0x10(%r12),%rax
     c6c:	mov    0x8(%rax),%rax
     c70:	mov    %rax,0x8(%rsp)
     c75:	mov    0x10(%r12),%rcx
     c7a:	mov    (%rcx),%rcx
     c7d:	mov    %rcx,(%rsp)
     c81:	lea    0x38(%rsp),%rdx
     c86:	mov    %rax,0x38(%rsp)
     c8b:	mov    %rcx,0x40(%rsp)
     c90:	mov    $0x2,%esi
     c95:	mov    0x48(%rsp),%rdi
     c9a:	call   c9f <botlish_fn_8+0xcf>
			c9b: R_X86_64_PLT32	rt_list_new-0x4
     c9f:	test   %rax,%rax
     ca2:	je     10a7 <botlish_fn_8+0x4d7>
     ca8:	mov    0x60(%rsp),%rbx
     cad:	mov    0x68(%rsp),%r12
     cb2:	mov    0x70(%rsp),%r13
     cb7:	mov    0x78(%rsp),%r14
     cbc:	mov    0x80(%rsp),%r15
     cc4:	add    $0x90,%rsp
     ccb:	mov    %rbp,%rsp
     cce:	pop    %rbp
     ccf:	ret
     cd0:	mov    %rax,%r12
     cd3:	mov    %rbx,%rsi
     cd6:	shl    $1,%rsi
     cd9:	or     $0x1,%rsi
     cdd:	mov    %rsi,0x8(%rsp)
     ce2:	mov    0x48(%rsp),%rdi
     ce7:	call   cec <botlish_fn_8+0x11c>
			ce8: R_X86_64_PLT32	botlish_fn_7-0x4
     cec:	test   %rax,%rax
     cef:	je     10a7 <botlish_fn_8+0x4d7>
     cf5:	mov    %rax,0x8(%rsp)
     cfa:	lea    0x30(%rsp),%r8
     cff:	mov    %rax,0x30(%rsp)
     d04:	mov    $0x9,%esi
     d09:	mov    0x0(%rip),%rdx        # d10 <botlish_fn_8+0x140>
			d0c: R_X86_64_GOTPCREL	botlish_entry_9-0x4
     d10:	mov    $0x1,%ecx
     d15:	mov    0x48(%rsp),%rdi
     d1a:	call   d1f <botlish_fn_8+0x14f>
			d1b: R_X86_64_PLT32	rt_closure_new-0x4
     d1f:	mov    %rax,0x8(%rsp)
     d24:	mov    %rax,%rsi
     d27:	mov    0x48(%rsp),%rdi
     d2c:	call   d31 <botlish_fn_8+0x161>
			d2d: R_X86_64_PLT32	rt_co_create-0x4
     d31:	mov    %rax,0x58(%rsp)
     d36:	mov    %rax,0x8(%rsp)
     d3b:	mov    0x58(%rsp),%rsi
     d40:	mov    0x48(%rsp),%rdi
     d45:	call   d4a <botlish_fn_8+0x17a>
			d46: R_X86_64_PLT32	rt_co_start-0x4
     d4a:	test   %rax,%rax
     d4d:	mov    %rax,%rcx
     d50:	jne    da8 <botlish_fn_8+0x1d8>
     d56:	mov    0x48(%rsp),%rdi
     d5b:	call   d60 <botlish_fn_8+0x190>
			d5c: R_X86_64_PLT32	rt_declared_error-0x4
     d60:	cmp    $0x40000001,%rax
     d66:	je     d94 <botlish_fn_8+0x1c4>
     d6c:	mov    0x48(%rsp),%rdi
     d71:	call   d76 <botlish_fn_8+0x1a6>
			d72: R_X86_64_PLT32	rt_declared_error-0x4
     d76:	cmp    $0x3,%rax
     d7a:	jne    10a7 <botlish_fn_8+0x4d7>
     d80:	mov    0x58(%rsp),%rsi
     d85:	mov    0x48(%rsp),%rdi
     d8a:	call   d8f <botlish_fn_8+0x1bf>
			d8b: R_X86_64_PLT32	rt_co_release-0x4
     d8f:	jmp    10a7 <botlish_fn_8+0x4d7>
     d94:	mov    0x58(%rsp),%rsi
     d99:	mov    0x48(%rsp),%rdi
     d9e:	call   da3 <botlish_fn_8+0x1d3>
			d9f: R_X86_64_PLT32	rt_co_release-0x4
     da3:	jmp    10a7 <botlish_fn_8+0x4d7>
     da8:	mov    0x18(%r12),%rax
     dad:	test   %rax,%rax
     db0:	je     110c <botlish_fn_8+0x53c>
     db6:	mov    0x10(%r12),%rax
     dbb:	mov    %rcx,0x10(%rax)
     dbf:	mov    $0x3,%r14d
     dc5:	mov    $0x7fffffff,%eax
     dca:	mov    %rax,%r15
     dcd:	neg    %r15
     dd0:	cmovs  %rax,%r15
     dd4:	mov    0x58(%rsp),%rsi
     dd9:	mov    0x48(%rsp),%rdi
     dde:	call   de3 <botlish_fn_8+0x213>
			ddf: R_X86_64_PLT32	rt_co_done-0x4
     de3:	cmp    $0x6,%rax
     de7:	je     10ee <botlish_fn_8+0x51e>
     ded:	movq   $0x1,0x10(%rsp)
     df6:	mov    0x10(%r12),%rax
     dfb:	mov    (%rax),%rsi
     dfe:	mov    %rsi,0x18(%rsp)
     e03:	mov    0x10(%r12),%rax
     e08:	mov    0x10(%rax),%rdx
     e0c:	mov    %rdx,0x20(%rsp)
     e11:	mov    %rdx,0x50(%rsp)
     e16:	movq   $0x3f,0x28(%rsp)
     e1f:	test   $0x1,%rsi
     e26:	je     e50 <botlish_fn_8+0x280>
     e2c:	mov    %rsi,%rax
     e2f:	sar    $1,%rax
     e32:	imulq  0x32f(%rip)        # 1168 <botlish_fn_8+0x598>
     e39:	seto   %cl
     e3c:	or     $0x1,%rax
     e40:	test   %cl,%cl
     e42:	jne    e50 <botlish_fn_8+0x280>
     e48:	mov    %rax,%rsi
     e4b:	jmp    e62 <botlish_fn_8+0x292>
     e50:	mov    $0x3f,%edx
     e55:	mov    0x48(%rsp),%rdi
     e5a:	call   e5f <botlish_fn_8+0x28f>
			e5b: R_X86_64_PLT32	rt_int_mul-0x4
     e5f:	mov    %rax,%rsi
     e62:	mov    %rsi,0x18(%rsp)
     e67:	mov    0x50(%rsp),%rdx
     e6c:	mov    %rsi,%rax
     e6f:	and    %rdx,%rax
     e72:	test   $0x1,%rax
     e78:	je     e93 <botlish_fn_8+0x2c3>
     e7e:	lea    -0x1(%rdx),%rcx
     e82:	mov    %rsi,%rax
     e85:	add    %rcx,%rax
     e88:	seto   %cl
     e8b:	test   %cl,%cl
     e8d:	je     e9d <botlish_fn_8+0x2cd>
     e93:	mov    0x48(%rsp),%rdi
     e98:	call   e9d <botlish_fn_8+0x2cd>
			e99: R_X86_64_PLT32	rt_int_add-0x4
     e9d:	mov    %rax,0x18(%rsp)
     ea2:	movq   $0x3,0x20(%rsp)
     eab:	test   $0x1,%rax
     eb1:	jne    ebf <botlish_fn_8+0x2ef>
     eb7:	mov    %rax,%rsi
     eba:	jmp    ed7 <botlish_fn_8+0x307>
     ebf:	mov    %rax,%rsi
     ec2:	add    $0x2,%rsi
     ec6:	mov    %rax,%rdx
     ec9:	seto   %al
     ecc:	test   %al,%al
     ece:	je     ee7 <botlish_fn_8+0x317>
     ed4:	mov    %rdx,%rsi
     ed7:	mov    %r14,%rdx
     eda:	mov    0x48(%rsp),%rdi
     edf:	call   ee4 <botlish_fn_8+0x314>
			ee0: R_X86_64_PLT32	rt_int_add-0x4
     ee4:	mov    %rax,%rsi
     ee7:	mov    %rsi,0x18(%rsp)
     eec:	mov    $0xffffffff,%edx
     ef1:	mov    %rdx,0x20(%rsp)
     ef6:	test   $0x1,%rsi
     efd:	jne    f4d <botlish_fn_8+0x37d>
     f03:	mov    $0xffffffff,%edx
     f08:	mov    0x48(%rsp),%rdi
     f0d:	call   f12 <botlish_fn_8+0x342>
			f0e: R_X86_64_PLT32	rt_int_mod-0x4
     f12:	test   %rax,%rax
     f15:	jne    f45 <botlish_fn_8+0x375>
     f1b:	mov    0x48(%rsp),%rdi
     f20:	call   f25 <botlish_fn_8+0x355>
			f21: R_X86_64_PLT32	rt_declared_error-0x4
     f25:	cmp    $0x40000001,%rax
     f2b:	jne    10a7 <botlish_fn_8+0x4d7>
     f31:	mov    0x58(%rsp),%rsi
     f36:	mov    0x48(%rsp),%rdi
     f3b:	call   f40 <botlish_fn_8+0x370>
			f3c: R_X86_64_PLT32	rt_co_release-0x4
     f40:	jmp    10a7 <botlish_fn_8+0x4d7>
     f45:	mov    %rax,%rcx
     f48:	jmp    f8b <botlish_fn_8+0x3bb>
     f4d:	sar    $1,%rsi
     f50:	mov    %rsi,%rax
     f53:	imulq  0x216(%rip)        # 1170 <botlish_fn_8+0x5a0>
     f5a:	lea    (%rdx,%rsi,1),%r11
     f5e:	sar    $0x1e,%r11
     f62:	mov    %r11,%rax
     f65:	shr    $0x3f,%rax
     f69:	add    %r11,%rax
     f6c:	imul   $0x7fffffff,%rax,%rax
     f73:	sub    %rax,%rsi
     f76:	lea    (%rsi,%r15,1),%rax
     f7a:	test   %rsi,%rsi
     f7d:	cmovl  %rax,%rsi
     f81:	shl    $1,%rsi
     f84:	or     $0x1,%rsi
     f88:	mov    %rsi,%rcx
     f8b:	mov    0x18(%r12),%rax
     f90:	test   %rax,%rax
     f93:	je     1123 <botlish_fn_8+0x553>
     f99:	mov    0x10(%r12),%rax
     f9e:	mov    %rcx,(%rax)
     fa1:	movq   $0x3,0x10(%rsp)
     faa:	mov    0x10(%r12),%rax
     faf:	mov    0x8(%rax),%rsi
     fb3:	mov    %rsi,0x18(%rsp)
     fb8:	movq   $0x3,0x20(%rsp)
     fc1:	test   $0x1,%rsi
     fc8:	je     fe0 <botlish_fn_8+0x410>
     fce:	mov    %rsi,%rcx
     fd1:	add    $0x2,%rcx
     fd5:	seto   %al
     fd8:	test   %al,%al
     fda:	je     ff0 <botlish_fn_8+0x420>
     fe0:	mov    %r14,%rdx
     fe3:	mov    0x48(%rsp),%rdi
     fe8:	call   fed <botlish_fn_8+0x41d>
			fe9: R_X86_64_PLT32	rt_int_add-0x4
     fed:	mov    %rax,%rcx
     ff0:	mov    0x18(%r12),%rax
     ff5:	test   %rax,%rax
     ff8:	je     113a <botlish_fn_8+0x56a>
     ffe:	mov    0x10(%r12),%rax
    1003:	mov    %rcx,0x8(%rax)
    1007:	mov    $0x5,%edx
    100c:	mov    %rdx,0x50(%rsp)
    1011:	movq   $0x5,0x10(%rsp)
    101a:	mov    0x58(%rsp),%rsi
    101f:	mov    0x48(%rsp),%rdi
    1024:	call   1029 <botlish_fn_8+0x459>
			1025: R_X86_64_PLT32	rt_co_resume0-0x4
    1029:	test   %rax,%rax
    102c:	mov    %rax,%rcx
    102f:	jne    10d2 <botlish_fn_8+0x502>
    1035:	mov    0x48(%rsp),%rdi
    103a:	call   103f <botlish_fn_8+0x46f>
			103b: R_X86_64_PLT32	rt_declared_error-0x4
    103f:	cmp    $0x40000001,%rax
    1045:	je     1073 <botlish_fn_8+0x4a3>
    104b:	mov    0x48(%rsp),%rdi
    1050:	call   1055 <botlish_fn_8+0x485>
			1051: R_X86_64_PLT32	rt_declared_error-0x4
    1055:	cmp    $0x3,%rax
    1059:	jne    1082 <botlish_fn_8+0x4b2>
    105f:	mov    0x58(%rsp),%rsi
    1064:	mov    0x48(%rsp),%rdi
    1069:	call   106e <botlish_fn_8+0x49e>
			106a: R_X86_64_PLT32	rt_co_release-0x4
    106e:	jmp    1082 <botlish_fn_8+0x4b2>
    1073:	mov    0x58(%rsp),%rsi
    1078:	mov    0x48(%rsp),%rdi
    107d:	call   1082 <botlish_fn_8+0x4b2>
			107e: R_X86_64_PLT32	rt_co_release-0x4
    1082:	mov    0x48(%rsp),%rdi
    1087:	call   108c <botlish_fn_8+0x4bc>
			1088: R_X86_64_PLT32	rt_declared_error-0x4
    108c:	cmp    $0x40000001,%rax
    1092:	jne    10a7 <botlish_fn_8+0x4d7>
    1098:	mov    0x58(%rsp),%rsi
    109d:	mov    0x48(%rsp),%rdi
    10a2:	call   10a7 <botlish_fn_8+0x4d7>
			10a3: R_X86_64_PLT32	rt_co_release-0x4
    10a7:	xor    %rax,%rax
    10aa:	mov    0x60(%rsp),%rbx
    10af:	mov    0x68(%rsp),%r12
    10b4:	mov    0x70(%rsp),%r13
    10b9:	mov    0x78(%rsp),%r14
    10be:	mov    0x80(%rsp),%r15
    10c6:	add    $0x90,%rsp
    10cd:	mov    %rbp,%rsp
    10d0:	pop    %rbp
    10d1:	ret
    10d2:	mov    0x18(%r12),%rax
    10d7:	test   %rax,%rax
    10da:	je     114f <botlish_fn_8+0x57f>
    10e0:	mov    0x10(%r12),%rax
    10e5:	mov    %rcx,0x10(%rax)
    10e9:	jmp    dd4 <botlish_fn_8+0x204>
    10ee:	mov    0x58(%rsp),%rsi
    10f3:	mov    0x48(%rsp),%rdi
    10f8:	call   10fd <botlish_fn_8+0x52d>
			10f9: R_X86_64_PLT32	rt_co_release-0x4
    10fd:	add    $0x1,%rbx
    1104:	mov    %r12,%rax
    1107:	jmp    c5b <botlish_fn_8+0x8b>
    110c:	mov    $0x5,%edx
    1111:	mov    %r12,%rsi
    1114:	mov    0x48(%rsp),%rdi
    1119:	call   111e <botlish_fn_8+0x54e>
			111a: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    111e:	jmp    dbf <botlish_fn_8+0x1ef>
    1123:	mov    $0x1,%edx
    1128:	mov    %r12,%rsi
    112b:	mov    0x48(%rsp),%rdi
    1130:	call   1135 <botlish_fn_8+0x565>
			1131: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1135:	jmp    fa1 <botlish_fn_8+0x3d1>
    113a:	mov    %r14,%rdx
    113d:	mov    %r12,%rsi
    1140:	mov    0x48(%rsp),%rdi
    1145:	call   114a <botlish_fn_8+0x57a>
			1146: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    114a:	jmp    1007 <botlish_fn_8+0x437>
    114f:	mov    0x50(%rsp),%rdx
    1154:	mov    %r12,%rsi
    1157:	mov    0x48(%rsp),%rdi
    115c:	call   1161 <botlish_fn_8+0x591>
			115d: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1161:	jmp    dd4 <botlish_fn_8+0x204>
    1166:	add    %al,(%rax)
    1168:	ds add %al,(%rax)
    116b:	add    %al,(%rax)
    116d:	add    %al,(%rax)
    116f:	add    %al,(%rbx)
    1171:	add    %al,(%rax)
    1173:	add    %al,(%rcx)
    1175:	add    %al,(%rax)
    1177:	.byte 0x80

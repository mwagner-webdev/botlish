<botlish_fn_37>:
    2988:	push   %rbp
    2989:	mov    %rsp,%rbp
    298c:	sub    $0x710,%rsp
    2993:	mov    %rbx,0x6e0(%rsp)
    299b:	mov    %r12,0x6e8(%rsp)
    29a3:	mov    %r13,0x6f0(%rsp)
    29ab:	mov    %r14,0x6f8(%rsp)
    29b3:	mov    %r15,0x700(%rsp)
    29bb:	mov    %rdi,0x520(%rsp)
    29c3:	movq   $0x0,(%rsp)
    29cb:	movq   $0x0,0x8(%rsp)
    29d4:	movq   $0x0,0x10(%rsp)
    29dd:	movq   $0x0,0x18(%rsp)
    29e6:	movq   $0x0,0x20(%rsp)
    29ef:	movq   $0x0,0x28(%rsp)
    29f8:	movq   $0x0,0x30(%rsp)
    2a01:	movq   $0x0,0x38(%rsp)
    2a0a:	movq   $0x0,0x40(%rsp)
    2a13:	movq   $0x0,0x48(%rsp)
    2a1c:	movq   $0x0,0x50(%rsp)
    2a25:	movq   $0x0,0x58(%rsp)
    2a2e:	movq   $0x0,0x60(%rsp)
    2a37:	movq   $0x0,0x68(%rsp)
    2a40:	movq   $0x0,0x70(%rsp)
    2a49:	movq   $0x0,0x78(%rsp)
    2a52:	movq   $0x0,0x80(%rsp)
    2a5e:	movq   $0x0,0x88(%rsp)
    2a6a:	movq   $0x0,0x90(%rsp)
    2a76:	movq   $0x0,0x98(%rsp)
    2a82:	movq   $0x0,0xa0(%rsp)
    2a8e:	movq   $0x0,0xa8(%rsp)
    2a9a:	movq   $0x0,0xb0(%rsp)
    2aa6:	movq   $0x0,0xb8(%rsp)
    2ab2:	movq   $0x0,0xc0(%rsp)
    2abe:	movq   $0x0,0xc8(%rsp)
    2aca:	movq   $0x0,0xd0(%rsp)
    2ad6:	movq   $0x0,0xd8(%rsp)
    2ae2:	movq   $0x0,0xe0(%rsp)
    2aee:	movq   $0x0,0xe8(%rsp)
    2afa:	movq   $0x0,0xf0(%rsp)
    2b06:	movq   $0x0,0xf8(%rsp)
    2b12:	movq   $0x0,0x100(%rsp)
    2b1e:	movq   $0x0,0x108(%rsp)
    2b2a:	movq   $0x0,0x110(%rsp)
    2b36:	movq   $0x0,0x118(%rsp)
    2b42:	movq   $0x0,0x120(%rsp)
    2b4e:	movq   $0x0,0x128(%rsp)
    2b5a:	movq   $0x0,0x130(%rsp)
    2b66:	movq   $0x0,0x138(%rsp)
    2b72:	movq   $0x0,0x140(%rsp)
    2b7e:	movq   $0x0,0x148(%rsp)
    2b8a:	mov    0x520(%rsp),%rdi
    2b92:	call   2b97 <botlish_fn_37+0x20f>
			2b93: R_X86_64_PLT32	botlish_fn_36-0x4
    2b97:	test   %rax,%rax
    2b9a:	je     a46f <botlish_fn_37+0x7ae7>
    2ba0:	mov    %rax,(%rsp)
    2ba4:	mov    %rax,%r12
    2ba7:	mov    $0x7,%esi
    2bac:	movq   $0x7,0x8(%rsp)
    2bb5:	mov    $0x1,%edx
    2bba:	movq   $0x1,0x10(%rsp)
    2bc3:	mov    0x520(%rsp),%rdi
    2bcb:	call   2bd0 <botlish_fn_37+0x248>
			2bcc: R_X86_64_PLT32	rt_mutarray_create-0x4
    2bd0:	test   %rax,%rax
    2bd3:	je     a46f <botlish_fn_37+0x7ae7>
    2bd9:	mov    %rax,0x8(%rsp)
    2bde:	mov    %rax,0x6d0(%rsp)
    2be6:	movq   $0xa,0x38(%rsp)
    2bef:	movq   $0xa,0x40(%rsp)
    2bf8:	movq   $0xa,0x48(%rsp)
    2c01:	movq   $0xa,0x50(%rsp)
    2c0a:	movq   $0xa,0x58(%rsp)
    2c13:	movq   $0xa,0x60(%rsp)
    2c1c:	movq   $0xa,0x68(%rsp)
    2c25:	movq   $0xa,0x70(%rsp)
    2c2e:	movq   $0xa,0x78(%rsp)
    2c37:	movq   $0xa,0x80(%rsp)
    2c43:	movq   $0xa,0x88(%rsp)
    2c4f:	movq   $0xa,0x90(%rsp)
    2c5b:	movq   $0xa,0x98(%rsp)
    2c67:	movq   $0xa,0xa0(%rsp)
    2c73:	movq   $0xa,0xa8(%rsp)
    2c7f:	movq   $0xa,0xb0(%rsp)
    2c8b:	movq   $0xa,0xb8(%rsp)
    2c97:	movq   $0xa,0xc0(%rsp)
    2ca3:	movq   $0xa,0xc8(%rsp)
    2caf:	movq   $0xa,0xd0(%rsp)
    2cbb:	movq   $0xa,0xd8(%rsp)
    2cc7:	movq   $0xa,0xe0(%rsp)
    2cd3:	movq   $0xa,0xe8(%rsp)
    2cdf:	movq   $0xa,0xf0(%rsp)
    2ceb:	movq   $0xa,0xf8(%rsp)
    2cf7:	movq   $0xa,0x100(%rsp)
    2d03:	movq   $0xa,0x108(%rsp)
    2d0f:	movq   $0xa,0x110(%rsp)
    2d1b:	movq   $0xa,0x28(%rsp)
    2d24:	movq   $0xa,0x30(%rsp)
    2d2d:	mov    %r12,%rax
    2d30:	mov    %rax,(%rsp)
    2d34:	mov    $0x1,%ebx
    2d39:	movq   $0x1,0x10(%rsp)
    2d42:	lea    0x1f0(%rsp),%rcx
    2d4a:	mov    %rax,0x1f0(%rsp)
    2d52:	mov    %rax,%r12
    2d55:	movq   $0x1,0x1f8(%rsp)
    2d61:	mov    $0x3,%esi
    2d66:	mov    $0x2,%edx
    2d6b:	mov    0x520(%rsp),%rdi
    2d73:	call   2d78 <botlish_fn_37+0x3f0>
			2d74: R_X86_64_PLT32	rt_struct_new-0x4
    2d78:	mov    %rax,0x10(%rsp)
    2d7d:	lea    0x200(%rsp),%rdx
    2d85:	mov    %rax,0x200(%rsp)
    2d8d:	mov    %rbx,%rsi
    2d90:	mov    0x520(%rsp),%rdi
    2d98:	call   2d9d <botlish_fn_37+0x415>
			2d99: R_X86_64_PLT32	rt_list_new-0x4
    2d9d:	test   %rax,%rax
    2da0:	je     31d3 <botlish_fn_37+0x84b>
    2da6:	mov    %rax,0x10(%rsp)
    2dab:	mov    %rax,%rsi
    2dae:	mov    0x520(%rsp),%rdi
    2db6:	call   2dbb <botlish_fn_37+0x433>
			2db7: R_X86_64_PLT32	rt_mv_from_list-0x4
    2dbb:	mov    %rax,0x38(%rsp)
    2dc0:	mov    %rax,0x6c8(%rsp)
    2dc8:	mov    0x6c8(%rsp),%rsi
    2dd0:	mov    0x520(%rsp),%rdi
    2dd8:	call   2ddd <botlish_fn_37+0x455>
			2dd9: R_X86_64_PLT32	rt_mv_pop-0x4
    2ddd:	test   %rax,%rax
    2de0:	je     31d3 <botlish_fn_37+0x84b>
    2de6:	mov    $0x3,%esi
    2deb:	movq   $0x3,0x10(%rsp)
    2df4:	mov    %r12,%rdx
    2df7:	mov    0x520(%rsp),%rdi
    2dff:	call   2e04 <botlish_fn_37+0x47c>
			2e00: R_X86_64_PLT32	rt_mutarray_create-0x4
    2e04:	test   %rax,%rax
    2e07:	je     31d3 <botlish_fn_37+0x84b>
    2e0d:	mov    %rax,0x40(%rsp)
    2e12:	mov    0x10(%rax),%rcx
    2e16:	mov    %rax,0x6c0(%rsp)
    2e1e:	mov    (%rcx),%rcx
    2e21:	mov    %rcx,0x48(%rsp)
    2e26:	mov    0x18(%rcx),%rax
    2e2a:	mov    %rcx,0x5e0(%rsp)
    2e32:	mov    (%rax),%rcx
    2e35:	cmp    $0xb2,%rcx
    2e3c:	je     3461 <botlish_fn_37+0xad9>
    2e42:	cmp    $0xd2,%rcx
    2e49:	je     3461 <botlish_fn_37+0xad9>
    2e4f:	cmp    $0x12,%rcx
    2e53:	je     340a <botlish_fn_37+0xa82>
    2e59:	cmp    $0x52,%rcx
    2e5d:	je     33b3 <botlish_fn_37+0xa2b>
    2e63:	cmp    $0x32,%rcx
    2e67:	je     335c <botlish_fn_37+0x9d4>
    2e6d:	cmp    $0x72,%rcx
    2e71:	je     2ed2 <botlish_fn_37+0x54a>
    2e77:	mov    0x10(%rax),%r13
    2e7b:	mov    %r13,0xf8(%rsp)
    2e83:	mov    %r13,0x5a0(%rsp)
    2e8b:	mov    $0x45,%r12d
    2e91:	movq   $0x45,0x28(%rsp)
    2e9a:	mov    $0x2b,%r15d
    2ea0:	mov    $0xa,%ebx
    2ea5:	mov    %rbx,0x558(%rsp)
    2ead:	mov    %rbx,0x580(%rsp)
    2eb5:	mov    %rbx,0x588(%rsp)
    2ebd:	mov    %rbx,0x618(%rsp)
    2ec5:	mov    %rbx,0x620(%rsp)
    2ecd:	jmp    3517 <botlish_fn_37+0xb8f>
    2ed2:	mov    0x8(%rax),%rbx
    2ed6:	mov    %rbx,0x70(%rsp)
    2edb:	test   $0x1,%rbx
    2ee2:	jne    2f1b <botlish_fn_37+0x593>
    2ee8:	mov    $0x1,%edx
    2eed:	mov    %rbx,%rsi
    2ef0:	mov    0x520(%rsp),%rdi
    2ef8:	call   2efd <botlish_fn_37+0x575>
			2ef9: R_X86_64_PLT32	rt_int_cmp-0x4
    2efd:	mov    %rbx,0x558(%rsp)
    2f05:	mov    $0x2,%r10d
    2f0b:	test   %rax,%rax
    2f0e:	cmove  0x76ca(%rip),%r10        # a5e0 <botlish_fn_37+0x7c58>
    2f16:	jmp    2f35 <botlish_fn_37+0x5ad>
    2f1b:	mov    %rbx,0x558(%rsp)
    2f23:	mov    $0x2,%r10d
    2f29:	cmp    $0x1,%rbx
    2f2d:	cmove  0x76ab(%rip),%r10        # a5e0 <botlish_fn_37+0x7c58>
    2f35:	cmp    $0x6,%r10
    2f39:	je     330d <botlish_fn_37+0x985>
    2f3f:	test   $0x1,%rbx
    2f46:	jne    2f7e <botlish_fn_37+0x5f6>
    2f4c:	mov    $0x1,%edx
    2f51:	mov    %rbx,%rsi
    2f54:	mov    0x520(%rsp),%rdi
    2f5c:	call   2f61 <botlish_fn_37+0x5d9>
			2f5d: R_X86_64_PLT32	rt_int_cmp-0x4
    2f61:	mov    %rbx,0x558(%rsp)
    2f69:	mov    $0x2,%ecx
    2f6e:	test   %rax,%rax
    2f71:	cmovl  0x7667(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    2f79:	jmp    2fa6 <botlish_fn_37+0x61e>
    2f7e:	mov    %rbx,0x558(%rsp)
    2f86:	mov    $0x2,%ecx
    2f8b:	mov    0x558(%rsp),%rax
    2f93:	mov    0x558(%rsp),%rdx
    2f9b:	test   %rdx,%rax
    2f9e:	cmovle 0x763a(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    2fa6:	cmp    $0x6,%rcx
    2faa:	je     32c6 <botlish_fn_37+0x93e>
    2fb0:	mov    0x558(%rsp),%rcx
    2fb8:	mov    %rcx,0xb8(%rsp)
    2fc0:	movq   $0x3,(%rsp)
    2fc8:	lea    0x220(%rsp),%rdx
    2fd0:	movq   $0x3,0x220(%rsp)
    2fdc:	mov    $0x1,%esi
    2fe1:	mov    0x520(%rsp),%rdi
    2fe9:	call   2fee <botlish_fn_37+0x666>
			2fea: R_X86_64_PLT32	rt_list_new-0x4
    2fee:	test   %rax,%rax
    2ff1:	je     31d3 <botlish_fn_37+0x84b>
    2ff7:	mov    %rax,(%rsp)
    2ffb:	mov    %rax,%rsi
    2ffe:	mov    0x520(%rsp),%rdi
    3006:	call   300b <botlish_fn_37+0x683>
			3007: R_X86_64_PLT32	rt_mv_from_list-0x4
    300b:	mov    %rax,0xc0(%rsp)
    3013:	mov    %rax,0x620(%rsp)
    301b:	mov    0x620(%rsp),%rsi
    3023:	mov    0x520(%rsp),%rdi
    302b:	call   3030 <botlish_fn_37+0x6a8>
			302c: R_X86_64_PLT32	rt_mv_len-0x4
    3030:	sar    $1,%rax
    3033:	sub    $0x1,%rax
    3037:	shl    $1,%rax
    303a:	mov    %rax,%rdx
    303d:	or     $0x1,%rdx
    3041:	mov    0x620(%rsp),%rsi
    3049:	mov    0x520(%rsp),%rdi
    3051:	call   3056 <botlish_fn_37+0x6ce>
			3052: R_X86_64_PLT32	rt_mv_at-0x4
    3056:	mov    %rax,%rcx
    3059:	mov    %rax,%rsi
    305c:	test   %rcx,%rax
    305f:	je     31d3 <botlish_fn_37+0x84b>
    3065:	mov    %rsi,%rax
    3068:	mov    %rax,(%rsp)
    306c:	movq   $0x15,0x10(%rsp)
    3075:	test   $0x1,%rax
    307b:	je     30b0 <botlish_fn_37+0x728>
    3081:	mov    %rsi,%rax
    3084:	sar    $1,%rax
    3087:	imulq  0x755a(%rip)        # a5e8 <botlish_fn_37+0x7c60>
    308e:	seto   %cl
    3091:	or     $0x1,%rax
    3095:	test   %cl,%cl
    3097:	jne    30b0 <botlish_fn_37+0x728>
    309d:	mov    %rsi,%rbx
    30a0:	mov    %rax,%rsi
    30a3:	mov    0x558(%rsp),%rcx
    30ab:	jmp    30d0 <botlish_fn_37+0x748>
    30b0:	mov    $0x15,%edx
    30b5:	mov    %rsi,%rbx
    30b8:	mov    0x520(%rsp),%rdi
    30c0:	call   30c5 <botlish_fn_37+0x73d>
			30c1: R_X86_64_PLT32	rt_int_mul-0x4
    30c5:	mov    0x558(%rsp),%rcx
    30cd:	mov    %rax,%rsi
    30d0:	mov    0x558(%rsp),%rcx
    30d8:	mov    %rsi,%rax
    30db:	and    %rcx,%rax
    30de:	test   $0x1,%rax
    30e4:	jne    3114 <botlish_fn_37+0x78c>
    30ea:	mov    0x558(%rsp),%rdx
    30f2:	mov    0x520(%rsp),%rdi
    30fa:	call   30ff <botlish_fn_37+0x777>
			30fb: R_X86_64_PLT32	rt_int_cmp-0x4
    30ff:	mov    $0x2,%ecx
    3104:	test   %rax,%rax
    3107:	cmovg  0x74d1(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    310f:	jmp    312c <botlish_fn_37+0x7a4>
    3114:	mov    $0x2,%ecx
    3119:	mov    0x558(%rsp),%rax
    3121:	cmp    %rax,%rsi
    3124:	cmovg  0x74b4(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    312c:	cmp    $0x6,%rcx
    3130:	je     31aa <botlish_fn_37+0x822>
    3136:	movq   $0x15,0x10(%rsp)
    313f:	test   $0x1,%rbx
    3146:	jne    3154 <botlish_fn_37+0x7cc>
    314c:	mov    %rbx,%rsi
    314f:	jmp    317b <botlish_fn_37+0x7f3>
    3154:	mov    %rbx,%rax
    3157:	sar    $1,%rax
    315a:	mov    %rbx,%rsi
    315d:	imulq  0x7484(%rip)        # a5e8 <botlish_fn_37+0x7c60>
    3164:	seto   %cl
    3167:	or     $0x1,%rax
    316b:	test   %cl,%cl
    316d:	jne    317b <botlish_fn_37+0x7f3>
    3173:	mov    %rax,%rdx
    3176:	jmp    3190 <botlish_fn_37+0x808>
    317b:	mov    $0x15,%edx
    3180:	mov    0x520(%rsp),%rdi
    3188:	call   318d <botlish_fn_37+0x805>
			3189: R_X86_64_PLT32	rt_int_mul-0x4
    318d:	mov    %rax,%rdx
    3190:	mov    0x620(%rsp),%rsi
    3198:	mov    0x520(%rsp),%rdi
    31a0:	call   31a5 <botlish_fn_37+0x81d>
			31a1: R_X86_64_PLT32	rt_mv_push-0x4
    31a5:	jmp    301b <botlish_fn_37+0x693>
    31aa:	mov    0x620(%rsp),%rsi
    31b2:	mov    0x520(%rsp),%rdi
    31ba:	call   31bf <botlish_fn_37+0x837>
			31bb: R_X86_64_PLT32	rt_mv_pop-0x4
    31bf:	mov    %rax,%rcx
    31c2:	mov    %rax,0x588(%rsp)
    31ca:	test   %rcx,%rax
    31cd:	jne    324d <botlish_fn_37+0x8c5>
    31d3:	mov    0x520(%rsp),%rdi
    31db:	call   31e0 <botlish_fn_37+0x858>
			31dc: R_X86_64_PLT32	rt_co_failed-0x4
    31e0:	mov    %rax,0x30(%rsp)
    31e5:	mov    %rax,%rsi
    31e8:	mov    0x520(%rsp),%rdi
    31f0:	call   31f5 <botlish_fn_37+0x86d>
			31f1: R_X86_64_PLT32	rt_co_resume0-0x4
    31f5:	test   %rax,%rax
    31f8:	jne    320b <botlish_fn_37+0x883>
    31fe:	mov    0x520(%rsp),%rdi
    3206:	jmp    322f <botlish_fn_37+0x8a7>
    320b:	mov    0x520(%rsp),%rdi
    3213:	mov    0x10(%rdi),%rax
    3217:	mov    0x48(%rax),%rsi
    321b:	mov    0x218(%rax),%rdx
    3222:	call   3227 <botlish_fn_37+0x89f>
			3223: R_X86_64_PLT32	rt_raise-0x4
    3227:	mov    0x520(%rsp),%rdi
    322f:	mov    0x520(%rsp),%rdi
    3237:	call   323c <botlish_fn_37+0x8b4>
			3238: R_X86_64_PLT32	rt_declared_error-0x4
    323c:	cmp    $0x40000001,%rax
    3242:	jne    a46f <botlish_fn_37+0x7ae7>
    3248:	jmp    a46f <botlish_fn_37+0x7ae7>
    324d:	mov    0x588(%rsp),%rax
    3255:	mov    %rax,0xc8(%rsp)
    325d:	mov    0x588(%rsp),%rdx
    3265:	mov    0x558(%rsp),%rsi
    326d:	mov    0x520(%rsp),%rdi
    3275:	call   327a <botlish_fn_37+0x8f2>
			3276: R_X86_64_PLT32	botlish_fn_15-0x4
    327a:	mov    %rax,0x580(%rsp)
    3282:	mov    %rax,0xd0(%rsp)
    328a:	sar    $1,%rax
    328d:	lea    0x30(%rax),%r12
    3291:	shl    $1,%r12
    3294:	or     $0x1,%r12
    3298:	mov    %r12,0x28(%rsp)
    329d:	mov    $0x29,%r15d
    32a3:	mov    $0xa,%r13d
    32a9:	mov    %r13,0x5a0(%rsp)
    32b1:	mov    0x558(%rsp),%rax
    32b9:	mov    %rax,0x618(%rsp)
    32c1:	jmp    3517 <botlish_fn_37+0xb8f>
    32c6:	mov    $0x5b,%r12d
    32cc:	movq   $0x5b,0x28(%rsp)
    32d5:	mov    $0x26,%r15d
    32db:	mov    $0xa,%eax
    32e0:	mov    %rax,0x580(%rsp)
    32e8:	mov    %rax,0x588(%rsp)
    32f0:	mov    %rax,0x5a0(%rsp)
    32f8:	mov    %rax,0x618(%rsp)
    3300:	mov    %rax,0x620(%rsp)
    3308:	jmp    3517 <botlish_fn_37+0xb8f>
    330d:	mov    %rbx,0x558(%rsp)
    3315:	mov    $0x61,%r12d
    331b:	movq   $0x61,0x28(%rsp)
    3324:	mov    $0x25,%r15d
    332a:	mov    $0xa,%eax
    332f:	mov    %rax,0x580(%rsp)
    3337:	mov    %rax,0x588(%rsp)
    333f:	mov    %rax,0x5a0(%rsp)
    3347:	mov    %rax,0x618(%rsp)
    334f:	mov    %rax,0x620(%rsp)
    3357:	jmp    3517 <botlish_fn_37+0xb8f>
    335c:	mov    $0xcd,%r12d
    3362:	movq   $0xcd,0x28(%rsp)
    336b:	mov    $0x20,%r15d
    3371:	mov    $0xa,%ecx
    3376:	mov    %rcx,0x558(%rsp)
    337e:	mov    0x558(%rsp),%rax
    3386:	mov    %rax,0x580(%rsp)
    338e:	mov    %rax,0x588(%rsp)
    3396:	mov    %rax,0x5a0(%rsp)
    339e:	mov    %rax,0x618(%rsp)
    33a6:	mov    %rax,0x620(%rsp)
    33ae:	jmp    3517 <botlish_fn_37+0xb8f>
    33b3:	mov    $0xe9,%r12d
    33b9:	movq   $0xe9,0x28(%rsp)
    33c2:	mov    $0x1c,%r15d
    33c8:	mov    $0xa,%ecx
    33cd:	mov    %rcx,0x558(%rsp)
    33d5:	mov    0x558(%rsp),%rax
    33dd:	mov    %rax,0x580(%rsp)
    33e5:	mov    %rax,0x588(%rsp)
    33ed:	mov    %rax,0x5a0(%rsp)
    33f5:	mov    %rax,0x618(%rsp)
    33fd:	mov    %rax,0x620(%rsp)
    3405:	jmp    3517 <botlish_fn_37+0xb8f>
    340a:	mov    $0xdd,%r12d
    3410:	movq   $0xdd,0x28(%rsp)
    3419:	mov    $0x18,%r15d
    341f:	mov    $0xa,%ecx
    3424:	mov    %rcx,0x558(%rsp)
    342c:	mov    0x558(%rsp),%rax
    3434:	mov    %rax,0x580(%rsp)
    343c:	mov    %rax,0x588(%rsp)
    3444:	mov    %rax,0x5a0(%rsp)
    344c:	mov    %rax,0x618(%rsp)
    3454:	mov    %rax,0x620(%rsp)
    345c:	jmp    3517 <botlish_fn_37+0xb8f>
    3461:	cmp    $0xb2,%rcx
    3468:	je     34c5 <botlish_fn_37+0xb3d>
    346e:	mov    $0xf7,%r12d
    3474:	movq   $0xf7,0x28(%rsp)
    347d:	mov    $0x2,%r15d
    3483:	mov    $0xa,%ecx
    3488:	mov    %rcx,0x558(%rsp)
    3490:	mov    0x558(%rsp),%rax
    3498:	mov    %rax,0x580(%rsp)
    34a0:	mov    %rax,0x588(%rsp)
    34a8:	mov    %rax,0x5a0(%rsp)
    34b0:	mov    %rax,0x618(%rsp)
    34b8:	mov    %rax,0x620(%rsp)
    34c0:	jmp    3517 <botlish_fn_37+0xb8f>
    34c5:	mov    $0xb7,%r12d
    34cb:	movq   $0xb7,0x28(%rsp)
    34d4:	mov    $0x1,%r15d
    34da:	mov    $0xa,%ecx
    34df:	mov    %rcx,0x558(%rsp)
    34e7:	mov    0x558(%rsp),%rax
    34ef:	mov    %rax,0x580(%rsp)
    34f7:	mov    %rax,0x588(%rsp)
    34ff:	mov    %rax,0x5a0(%rsp)
    3507:	mov    %rax,0x618(%rsp)
    350f:	mov    %rax,0x620(%rsp)
    3517:	movq   $0xa,0x128(%rsp)
    3523:	movq   $0xa,0x130(%rsp)
    352f:	movq   $0xa,0x138(%rsp)
    353b:	movq   $0xa,0x140(%rsp)
    3547:	movq   $0xa,0x148(%rsp)
    3553:	movq   $0xa,0x118(%rsp)
    355f:	movq   $0xa,0x120(%rsp)
    356b:	mov    %r12,%r13
    356e:	mov    %r12,0x660(%rsp)
    3576:	xor    %rax,%rax
    3579:	mov    $0x6,%ecx
    357e:	mov    %rcx,0x6b8(%rsp)
    3586:	mov    $0x5b,%ecx
    358b:	mov    %rcx,0x6b0(%rsp)
    3593:	mov    $0x30,%ecx
    3598:	mov    %rcx,0x6a8(%rsp)
    35a0:	mov    $0x20,%ecx
    35a5:	mov    %rcx,0x6a0(%rsp)
    35ad:	test   $0x1,%r12
    35b4:	jne    35e6 <botlish_fn_37+0xc5e>
    35ba:	mov    $0xffffffffffffffff,%rdx
    35c1:	mov    %r12,%rsi
    35c4:	mov    0x520(%rsp),%rdi
    35cc:	call   35d1 <botlish_fn_37+0xc49>
			35cd: R_X86_64_PLT32	rt_int_cmp-0x4
    35d1:	mov    $0x2,%ecx
    35d6:	test   %rax,%rax
    35d9:	cmovl  0x6fff(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    35e1:	jmp    35f7 <botlish_fn_37+0xc6f>
    35e6:	mov    $0x2,%ecx
    35eb:	cmp    $0xffffffffffffffff,%r12
    35ef:	cmovl  0x6fe9(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    35f7:	cmp    $0x6,%rcx
    35fb:	je     3801 <botlish_fn_37+0xe79>
    3601:	test   $0x1,%r12
    3608:	jne    3638 <botlish_fn_37+0xcb0>
    360e:	mov    $0x21ffff,%edx
    3613:	mov    %r12,%rsi
    3616:	mov    0x520(%rsp),%rdi
    361e:	call   3623 <botlish_fn_37+0xc9b>
			361f: R_X86_64_PLT32	rt_int_cmp-0x4
    3623:	mov    $0x2,%ecx
    3628:	test   %rax,%rax
    362b:	cmovg  0x6fad(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3633:	jmp    364c <botlish_fn_37+0xcc4>
    3638:	mov    $0x2,%ecx
    363d:	cmp    $0x21ffff,%r12
    3644:	cmovg  0x6f94(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    364c:	cmp    $0x6,%rcx
    3650:	je     3801 <botlish_fn_37+0xe79>
    3656:	mov    %r12,%r8
    3659:	sar    $1,%r8
    365c:	cmp    $0x5c,%r8
    3660:	jl     372d <botlish_fn_37+0xda5>
    3666:	cmp    $0x75,%r8
    366a:	jl     36d3 <botlish_fn_37+0xd4b>
    3670:	cmp    $0x7e,%r8
    3674:	jl     36ab <botlish_fn_37+0xd23>
    367a:	cmp    $0xe000,%r8
    3681:	jl     3699 <botlish_fn_37+0xd11>
    3687:	cmp    $0x110000,%r8
    368e:	jge    3801 <botlish_fn_37+0xe79>
    3694:	jmp    37e3 <botlish_fn_37+0xe5b>
    3699:	cmp    $0xd800,%r8
    36a0:	jge    3801 <botlish_fn_37+0xe79>
    36a6:	jmp    37e3 <botlish_fn_37+0xe5b>
    36ab:	cmp    $0x7c,%r8
    36af:	jl     36c4 <botlish_fn_37+0xd3c>
    36b5:	cmp    $0x7d,%r8
    36b9:	jge    378c <botlish_fn_37+0xe04>
    36bf:	jmp    37e3 <botlish_fn_37+0xe5b>
    36c4:	cmp    $0x7b,%r8
    36c8:	jge    378c <botlish_fn_37+0xe04>
    36ce:	jmp    37e3 <botlish_fn_37+0xe5b>
    36d3:	cmp    $0x67,%r8
    36d7:	jl     3705 <botlish_fn_37+0xd7d>
    36dd:	cmp    $0x6f,%r8
    36e1:	jl     36f6 <botlish_fn_37+0xd6e>
    36e7:	cmp    $0x74,%r8
    36eb:	jge    378c <botlish_fn_37+0xe04>
    36f1:	jmp    37e3 <botlish_fn_37+0xe5b>
    36f6:	cmp    $0x6e,%r8
    36fa:	jge    378c <botlish_fn_37+0xe04>
    3700:	jmp    37e3 <botlish_fn_37+0xe5b>
    3705:	cmp    $0x5e,%r8
    3709:	jl     371e <botlish_fn_37+0xd96>
    370f:	cmp    $0x66,%r8
    3713:	jge    378c <botlish_fn_37+0xe04>
    3719:	jmp    37e3 <botlish_fn_37+0xe5b>
    371e:	cmp    $0x5d,%r8
    3722:	jge    378c <botlish_fn_37+0xe04>
    3728:	jmp    37e3 <botlish_fn_37+0xe5b>
    372d:	cmp    $0x21,%r8
    3731:	jl     3796 <botlish_fn_37+0xe0e>
    3737:	cmp    $0x2e,%r8
    373b:	jl     3769 <botlish_fn_37+0xde1>
    3741:	cmp    $0x3b,%r8
    3745:	jl     375a <botlish_fn_37+0xdd2>
    374b:	cmp    $0x5b,%r8
    374f:	jge    378c <botlish_fn_37+0xe04>
    3755:	jmp    37e3 <botlish_fn_37+0xe5b>
    375a:	cmp    $0x30,%r8
    375e:	jge    378c <botlish_fn_37+0xe04>
    3764:	jmp    37e3 <botlish_fn_37+0xe5b>
    3769:	cmp    $0x23,%r8
    376d:	jl     3782 <botlish_fn_37+0xdfa>
    3773:	cmp    $0x2c,%r8
    3777:	jge    378c <botlish_fn_37+0xe04>
    377d:	jmp    37e3 <botlish_fn_37+0xe5b>
    3782:	cmp    $0x22,%r8
    3786:	jl     37e3 <botlish_fn_37+0xe5b>
    378c:	mov    $0x2,%esi
    3791:	jmp    3806 <botlish_fn_37+0xe7e>
    3796:	cmp    $0xb,%r8
    379a:	jl     37c8 <botlish_fn_37+0xe40>
    37a0:	cmp    $0xe,%r8
    37a4:	jl     37b9 <botlish_fn_37+0xe31>
    37aa:	cmp    $0x20,%r8
    37ae:	jge    37db <botlish_fn_37+0xe53>
    37b4:	jmp    37e3 <botlish_fn_37+0xe5b>
    37b9:	cmp    $0xd,%r8
    37bd:	jge    37db <botlish_fn_37+0xe53>
    37c3:	jmp    37e3 <botlish_fn_37+0xe5b>
    37c8:	test   %r8,%r8
    37cb:	jl     37ed <botlish_fn_37+0xe65>
    37d1:	cmp    $0x9,%r8
    37d5:	jl     37e3 <botlish_fn_37+0xe5b>
    37db:	xor    %rsi,%rsi
    37de:	jmp    3806 <botlish_fn_37+0xe7e>
    37e3:	mov    $0x4,%esi
    37e8:	jmp    3806 <botlish_fn_37+0xe7e>
    37ed:	cmp    $0xffffffffffffffff,%r8
    37f1:	jl     3801 <botlish_fn_37+0xe79>
    37f7:	mov    $0x1,%esi
    37fc:	jmp    3806 <botlish_fn_37+0xe7e>
    3801:	mov    $0x3,%esi
    3806:	mov    %rsi,%rcx
    3809:	shl    $1,%rcx
    380c:	or     $0x1,%rcx
    3810:	mov    $0x2,%eax
    3815:	cmp    $0x3,%rcx
    3819:	cmovl  0x6dbf(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    3821:	cmp    $0x6,%rax
    3825:	je     495c <botlish_fn_37+0x1fd4>
    382b:	mov    %rsi,%rcx
    382e:	shl    $1,%rcx
    3831:	or     $0x1,%rcx
    3835:	mov    $0x2,%eax
    383a:	cmp    $0x3,%rcx
    383e:	cmove  0x6d9a(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    3846:	cmp    $0x6,%rax
    384a:	je     48fa <botlish_fn_37+0x1f72>
    3850:	mov    %rsi,%rcx
    3853:	shl    $1,%rcx
    3856:	or     $0x1,%rcx
    385a:	mov    $0x2,%eax
    385f:	cmp    $0x5,%rcx
    3863:	cmove  0x6d75(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    386b:	cmp    $0x6,%rax
    386f:	je     3902 <botlish_fn_37+0xf7a>
    3875:	mov    $0x1,%ebx
    387a:	shl    $1,%rsi
    387d:	or     $0x1,%rsi
    3881:	mov    %rsi,0x668(%rsp)
    3889:	mov    0x520(%rsp),%rdi
    3891:	call   3896 <botlish_fn_37+0xf0e>
			3892: R_X86_64_PLT32	botlish_fn_10-0x4
    3896:	mov    0x668(%rsp),%rsi
    389e:	mov    %rax,%r13
    38a1:	mov    0x520(%rsp),%rdi
    38a9:	call   38ae <botlish_fn_37+0xf26>
			38aa: R_X86_64_PLT32	botlish_fn_11-0x4
    38ae:	mov    %rax,%rcx
    38b1:	mov    0x520(%rsp),%rdi
    38b9:	mov    0x10(%rdi),%rax
    38bd:	mov    0x258(%rax),%rdx
    38c4:	lea    0x348(%rsp),%r9
    38cc:	mov    %r13,%rax
    38cf:	mov    %rax,0x348(%rsp)
    38d7:	mov    %rcx,%rax
    38da:	mov    %rax,0x350(%rsp)
    38e2:	mov    %r12,0x358(%rsp)
    38ea:	mov    $0x4,%ecx
    38ef:	mov    $0x3,%r8d
    38f5:	mov    %rbx,%rsi
    38f8:	call   38fd <botlish_fn_37+0xf75>
			38f9: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    38fd:	jmp    45dc <botlish_fn_37+0x1c54>
    3902:	mov    0x520(%rsp),%rdi
    390a:	mov    0x10(%rdi),%rcx
    390e:	mov    0x238(%rcx),%rbx
    3915:	test   $0x1,%r12
    391c:	jne    394e <botlish_fn_37+0xfc6>
    3922:	mov    $0xffffffffffffffff,%rdx
    3929:	mov    %r12,%rsi
    392c:	mov    0x520(%rsp),%rdi
    3934:	call   3939 <botlish_fn_37+0xfb1>
			3935: R_X86_64_PLT32	rt_int_cmp-0x4
    3939:	mov    $0x2,%ecx
    393e:	test   %rax,%rax
    3941:	cmovl  0x6c97(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3949:	jmp    395f <botlish_fn_37+0xfd7>
    394e:	mov    $0x2,%ecx
    3953:	cmp    $0xffffffffffffffff,%r12
    3957:	cmovl  0x6c81(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    395f:	cmp    $0x6,%rcx
    3963:	je     39cf <botlish_fn_37+0x1047>
    3969:	test   $0x1,%r12
    3970:	jne    39a0 <botlish_fn_37+0x1018>
    3976:	mov    $0x1ff,%edx
    397b:	mov    %r12,%rsi
    397e:	mov    0x520(%rsp),%rdi
    3986:	call   398b <botlish_fn_37+0x1003>
			3987: R_X86_64_PLT32	rt_int_cmp-0x4
    398b:	mov    $0x2,%ecx
    3990:	test   %rax,%rax
    3993:	cmovg  0x6c45(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    399b:	jmp    39b4 <botlish_fn_37+0x102c>
    39a0:	mov    $0x2,%ecx
    39a5:	cmp    $0x1ff,%r12
    39ac:	cmovg  0x6c2c(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    39b4:	cmp    $0x6,%rcx
    39b8:	je     39cf <botlish_fn_37+0x1047>
    39be:	mov    %r12,%rax
    39c1:	sar    $1,%rax
    39c4:	movzbq 0x11(%rbx,%rax,1),%rsi
    39ca:	jmp    39d7 <botlish_fn_37+0x104f>
    39cf:	movzbq 0x111(%rbx),%rsi
    39d7:	mov    %rsi,%rcx
    39da:	shl    $1,%rcx
    39dd:	or     $0x1,%rcx
    39e1:	mov    $0x2,%eax
    39e6:	cmp    $0x3,%rcx
    39ea:	cmove  0x6bee(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    39f2:	cmp    $0x6,%rax
    39f6:	je     4879 <botlish_fn_37+0x1ef1>
    39fc:	mov    %rsi,%rcx
    39ff:	shl    $1,%rcx
    3a02:	or     $0x1,%rcx
    3a06:	mov    $0x2,%eax
    3a0b:	cmp    $0x5,%rcx
    3a0f:	cmove  0x6bc9(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    3a17:	cmp    $0x6,%rax
    3a1b:	je     40e8 <botlish_fn_37+0x1760>
    3a21:	mov    %rsi,%rcx
    3a24:	shl    $1,%rcx
    3a27:	or     $0x1,%rcx
    3a2b:	mov    $0x2,%eax
    3a30:	cmp    $0x7,%rcx
    3a34:	cmove  0x6ba4(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    3a3c:	cmp    $0x6,%rax
    3a40:	je     3e24 <botlish_fn_37+0x149c>
    3a46:	shl    $1,%rsi
    3a49:	or     $0x1,%rsi
    3a4d:	mov    $0x2,%eax
    3a52:	cmp    $0x9,%rsi
    3a56:	cmove  0x6b82(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    3a5e:	cmp    $0x6,%rax
    3a62:	je     3b60 <botlish_fn_37+0x11d8>
    3a68:	test   $0x1,%r12
    3a6f:	jne    3aa1 <botlish_fn_37+0x1119>
    3a75:	mov    $0xffffffffffffffff,%rdx
    3a7c:	mov    %r12,%rsi
    3a7f:	mov    0x520(%rsp),%rdi
    3a87:	call   3a8c <botlish_fn_37+0x1104>
			3a88: R_X86_64_PLT32	rt_int_cmp-0x4
    3a8c:	mov    $0x2,%ecx
    3a91:	test   %rax,%rax
    3a94:	cmove  0x6b44(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3a9c:	jmp    3ab2 <botlish_fn_37+0x112a>
    3aa1:	mov    $0x2,%ecx
    3aa6:	cmp    $0xffffffffffffffff,%r12
    3aaa:	cmove  0x6b2e(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3ab2:	cmp    $0x6,%rcx
    3ab6:	je     3b13 <botlish_fn_37+0x118b>
    3abc:	mov    0x520(%rsp),%rdi
    3ac4:	mov    0x10(%rdi),%rdx
    3ac8:	mov    0x118(%rdx),%rax
    3acf:	mov    (%rdx),%rcx
    3ad2:	mov    0x258(%rdx),%rdx
    3ad9:	lea    0x330(%rsp),%r9
    3ae1:	mov    %rax,0x330(%rsp)
    3ae9:	mov    %rcx,0x338(%rsp)
    3af1:	mov    %r12,0x340(%rsp)
    3af9:	mov    $0x1,%esi
    3afe:	mov    $0x4,%ecx
    3b03:	mov    $0x3,%r8d
    3b09:	call   3b0e <botlish_fn_37+0x1186>
			3b0a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3b0e:	jmp    45dc <botlish_fn_37+0x1c54>
    3b13:	mov    0x520(%rsp),%rdi
    3b1b:	mov    0x10(%rdi),%rdx
    3b1f:	mov    0x118(%rdx),%rax
    3b26:	mov    (%rdx),%rcx
    3b29:	mov    0x250(%rdx),%rdx
    3b30:	lea    0x320(%rsp),%r9
    3b38:	mov    %rax,0x320(%rsp)
    3b40:	mov    %rcx,0x328(%rsp)
    3b48:	mov    $0x2,%r8d
    3b4e:	mov    $0x5,%ecx
    3b53:	mov    %r8,%rsi
    3b56:	call   3b5b <botlish_fn_37+0x11d3>
			3b57: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3b5b:	jmp    45dc <botlish_fn_37+0x1c54>
    3b60:	mov    0x520(%rsp),%rdi
    3b68:	mov    0x10(%rdi),%rax
    3b6c:	mov    0x278(%rax),%rbx
    3b73:	test   $0x1,%r12
    3b7a:	jne    3bac <botlish_fn_37+0x1224>
    3b80:	mov    $0xffffffffffffffff,%rdx
    3b87:	mov    %r12,%rsi
    3b8a:	mov    0x520(%rsp),%rdi
    3b92:	call   3b97 <botlish_fn_37+0x120f>
			3b93: R_X86_64_PLT32	rt_int_cmp-0x4
    3b97:	mov    $0x2,%ecx
    3b9c:	test   %rax,%rax
    3b9f:	cmovl  0x6a39(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3ba7:	jmp    3bbd <botlish_fn_37+0x1235>
    3bac:	mov    $0x2,%ecx
    3bb1:	cmp    $0xffffffffffffffff,%r12
    3bb5:	cmovl  0x6a23(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3bbd:	cmp    $0x6,%rcx
    3bc1:	je     3c2d <botlish_fn_37+0x12a5>
    3bc7:	test   $0x1,%r12
    3bce:	jne    3bfe <botlish_fn_37+0x1276>
    3bd4:	mov    $0x1ff,%edx
    3bd9:	mov    %r12,%rsi
    3bdc:	mov    0x520(%rsp),%rdi
    3be4:	call   3be9 <botlish_fn_37+0x1261>
			3be5: R_X86_64_PLT32	rt_int_cmp-0x4
    3be9:	mov    $0x2,%ecx
    3bee:	test   %rax,%rax
    3bf1:	cmovg  0x69e7(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3bf9:	jmp    3c12 <botlish_fn_37+0x128a>
    3bfe:	mov    $0x2,%ecx
    3c03:	cmp    $0x1ff,%r12
    3c0a:	cmovg  0x69ce(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3c12:	cmp    $0x6,%rcx
    3c16:	je     3c2d <botlish_fn_37+0x12a5>
    3c1c:	mov    %r12,%rax
    3c1f:	sar    $1,%rax
    3c22:	movzbq 0x11(%rbx,%rax,1),%rsi
    3c28:	jmp    3c35 <botlish_fn_37+0x12ad>
    3c2d:	movzbq 0xc1c(%rbx),%rsi
    3c35:	mov    %rsi,%rcx
    3c38:	shl    $1,%rcx
    3c3b:	or     $0x1,%rcx
    3c3f:	mov    $0x2,%eax
    3c44:	cmp    $0x19,%rcx
    3c48:	cmovl  0x6990(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    3c50:	cmp    $0x6,%rax
    3c54:	je     3dbd <botlish_fn_37+0x1435>
    3c5a:	mov    %rsi,%rcx
    3c5d:	shl    $1,%rcx
    3c60:	mov    %rsi,0x680(%rsp)
    3c68:	or     $0x1,%rcx
    3c6c:	mov    $0x2,%eax
    3c71:	cmp    $0x19,%rcx
    3c75:	cmove  0x6963(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    3c7d:	cmp    $0x6,%rax
    3c81:	je     4880 <botlish_fn_37+0x1ef8>
    3c87:	test   $0x1,%r12
    3c8e:	jne    3cc0 <botlish_fn_37+0x1338>
    3c94:	mov    $0xffffffffffffffff,%rdx
    3c9b:	mov    %r12,%rsi
    3c9e:	mov    0x520(%rsp),%rdi
    3ca6:	call   3cab <botlish_fn_37+0x1323>
			3ca7: R_X86_64_PLT32	rt_int_cmp-0x4
    3cab:	mov    $0x2,%edi
    3cb0:	test   %rax,%rax
    3cb3:	cmove  0x6925(%rip),%rdi        # a5e0 <botlish_fn_37+0x7c58>
    3cbb:	jmp    3cd1 <botlish_fn_37+0x1349>
    3cc0:	mov    $0x2,%edi
    3cc5:	cmp    $0xffffffffffffffff,%r12
    3cc9:	cmove  0x690f(%rip),%rdi        # a5e0 <botlish_fn_37+0x7c58>
    3cd1:	cmp    $0x6,%rdi
    3cd5:	je     3d53 <botlish_fn_37+0x13cb>
    3cdb:	mov    0x520(%rsp),%rdi
    3ce3:	mov    0x10(%rdi),%rax
    3ce7:	mov    0x280(%rax),%rbx
    3cee:	mov    $0x1,%r13d
    3cf4:	mov    0x680(%rsp),%rsi
    3cfc:	shl    $1,%rsi
    3cff:	or     $0x1,%rsi
    3d03:	call   3d08 <botlish_fn_37+0x1380>
			3d04: R_X86_64_PLT32	botlish_fn_3-0x4
    3d08:	mov    0x520(%rsp),%rdi
    3d10:	mov    0x10(%rdi),%rcx
    3d14:	mov    0x258(%rcx),%rdx
    3d1b:	lea    0x308(%rsp),%r9
    3d23:	mov    %rbx,0x308(%rsp)
    3d2b:	mov    %rax,0x310(%rsp)
    3d33:	mov    %r12,0x318(%rsp)
    3d3b:	mov    $0x4,%ecx
    3d40:	mov    $0x3,%r8d
    3d46:	mov    %r13,%rsi
    3d49:	call   3d4e <botlish_fn_37+0x13c6>
			3d4a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3d4e:	jmp    45dc <botlish_fn_37+0x1c54>
    3d53:	mov    0x680(%rsp),%rsi
    3d5b:	mov    0x520(%rsp),%rdi
    3d63:	mov    0x10(%rdi),%rax
    3d67:	mov    0x280(%rax),%rbx
    3d6e:	shl    $1,%rsi
    3d71:	or     $0x1,%rsi
    3d75:	call   3d7a <botlish_fn_37+0x13f2>
			3d76: R_X86_64_PLT32	botlish_fn_3-0x4
    3d7a:	mov    0x520(%rsp),%rdi
    3d82:	mov    0x10(%rdi),%rcx
    3d86:	mov    0x250(%rcx),%rdx
    3d8d:	lea    0x2f8(%rsp),%r9
    3d95:	mov    %rbx,0x2f8(%rsp)
    3d9d:	mov    %rax,0x300(%rsp)
    3da5:	mov    $0x2,%r8d
    3dab:	mov    $0x5,%ecx
    3db0:	mov    %r8,%rsi
    3db3:	call   3db8 <botlish_fn_37+0x1430>
			3db4: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3db8:	jmp    45dc <botlish_fn_37+0x1c54>
    3dbd:	shl    $1,%rsi
    3dc0:	or     $0x1,%rsi
    3dc4:	mov    %rsi,0x148(%rsp)
    3dcc:	mov    %rsi,0x680(%rsp)
    3dd4:	mov    $0x1,%ecx
    3dd9:	movq   $0x1,0x118(%rsp)
    3de5:	mov    $0x4,%edi
    3dea:	mov    $0xa,%esi
    3def:	mov    %rcx,0x528(%rsp)
    3df7:	mov    %rdi,0x530(%rsp)
    3dff:	mov    %rsi,0x668(%rsp)
    3e07:	mov    %rsi,0x670(%rsp)
    3e0f:	mov    %rsi,0x678(%rsp)
    3e17:	mov    %rsi,0x688(%rsp)
    3e1f:	jmp    49d6 <botlish_fn_37+0x204e>
    3e24:	mov    0x520(%rsp),%rdi
    3e2c:	mov    0x10(%rdi),%rax
    3e30:	mov    0x268(%rax),%rbx
    3e37:	test   $0x1,%r12
    3e3e:	jne    3e70 <botlish_fn_37+0x14e8>
    3e44:	mov    $0xffffffffffffffff,%rdx
    3e4b:	mov    %r12,%rsi
    3e4e:	mov    0x520(%rsp),%rdi
    3e56:	call   3e5b <botlish_fn_37+0x14d3>
			3e57: R_X86_64_PLT32	rt_int_cmp-0x4
    3e5b:	mov    $0x2,%ecx
    3e60:	test   %rax,%rax
    3e63:	cmovl  0x6775(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3e6b:	jmp    3e81 <botlish_fn_37+0x14f9>
    3e70:	mov    $0x2,%ecx
    3e75:	cmp    $0xffffffffffffffff,%r12
    3e79:	cmovl  0x675f(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3e81:	cmp    $0x6,%rcx
    3e85:	je     3ef1 <botlish_fn_37+0x1569>
    3e8b:	test   $0x1,%r12
    3e92:	jne    3ec2 <botlish_fn_37+0x153a>
    3e98:	mov    $0x1ff,%edx
    3e9d:	mov    %r12,%rsi
    3ea0:	mov    0x520(%rsp),%rdi
    3ea8:	call   3ead <botlish_fn_37+0x1525>
			3ea9: R_X86_64_PLT32	rt_int_cmp-0x4
    3ead:	mov    $0x2,%ecx
    3eb2:	test   %rax,%rax
    3eb5:	cmovg  0x6723(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3ebd:	jmp    3ed6 <botlish_fn_37+0x154e>
    3ec2:	mov    $0x2,%ecx
    3ec7:	cmp    $0x1ff,%r12
    3ece:	cmovg  0x670a(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3ed6:	cmp    $0x6,%rcx
    3eda:	je     3ef1 <botlish_fn_37+0x1569>
    3ee0:	mov    %r12,%rsi
    3ee3:	sar    $1,%rsi
    3ee6:	movzbq 0x11(%rbx,%rsi,1),%rsi
    3eec:	jmp    3ef9 <botlish_fn_37+0x1571>
    3ef1:	movzbq 0x919(%rbx),%rsi
    3ef9:	mov    %rsi,%rdi
    3efc:	shl    $1,%rdi
    3eff:	or     $0x1,%rdi
    3f03:	mov    $0x2,%eax
    3f08:	cmp    $0x13,%rdi
    3f0c:	cmovl  0x66cc(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    3f14:	cmp    $0x6,%rax
    3f18:	je     4081 <botlish_fn_37+0x16f9>
    3f1e:	mov    %rsi,%r10
    3f21:	shl    $1,%r10
    3f24:	mov    %rsi,0x678(%rsp)
    3f2c:	or     $0x1,%r10
    3f30:	mov    $0x2,%eax
    3f35:	cmp    $0x13,%r10
    3f39:	cmove  0x669f(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    3f41:	cmp    $0x6,%rax
    3f45:	je     4880 <botlish_fn_37+0x1ef8>
    3f4b:	test   $0x1,%r12
    3f52:	jne    3f84 <botlish_fn_37+0x15fc>
    3f58:	mov    $0xffffffffffffffff,%rdx
    3f5f:	mov    %r12,%rsi
    3f62:	mov    0x520(%rsp),%rdi
    3f6a:	call   3f6f <botlish_fn_37+0x15e7>
			3f6b: R_X86_64_PLT32	rt_int_cmp-0x4
    3f6f:	mov    $0x2,%ecx
    3f74:	test   %rax,%rax
    3f77:	cmove  0x6661(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3f7f:	jmp    3f95 <botlish_fn_37+0x160d>
    3f84:	mov    $0x2,%ecx
    3f89:	cmp    $0xffffffffffffffff,%r12
    3f8d:	cmove  0x664b(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    3f95:	cmp    $0x6,%rcx
    3f99:	je     4017 <botlish_fn_37+0x168f>
    3f9f:	mov    0x520(%rsp),%rdi
    3fa7:	mov    0x10(%rdi),%rax
    3fab:	mov    0x270(%rax),%rbx
    3fb2:	mov    $0x1,%r13d
    3fb8:	mov    0x678(%rsp),%rsi
    3fc0:	shl    $1,%rsi
    3fc3:	or     $0x1,%rsi
    3fc7:	call   3fcc <botlish_fn_37+0x1644>
			3fc8: R_X86_64_PLT32	botlish_fn_1-0x4
    3fcc:	mov    0x520(%rsp),%rdi
    3fd4:	mov    0x10(%rdi),%rcx
    3fd8:	mov    0x258(%rcx),%rdx
    3fdf:	lea    0x2e0(%rsp),%r9
    3fe7:	mov    %rbx,0x2e0(%rsp)
    3fef:	mov    %rax,0x2e8(%rsp)
    3ff7:	mov    %r12,0x2f0(%rsp)
    3fff:	mov    $0x4,%ecx
    4004:	mov    $0x3,%r8d
    400a:	mov    %r13,%rsi
    400d:	call   4012 <botlish_fn_37+0x168a>
			400e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4012:	jmp    45dc <botlish_fn_37+0x1c54>
    4017:	mov    0x678(%rsp),%rsi
    401f:	mov    0x520(%rsp),%rdi
    4027:	mov    0x10(%rdi),%rax
    402b:	mov    0x270(%rax),%rbx
    4032:	shl    $1,%rsi
    4035:	or     $0x1,%rsi
    4039:	call   403e <botlish_fn_37+0x16b6>
			403a: R_X86_64_PLT32	botlish_fn_1-0x4
    403e:	mov    0x520(%rsp),%rdi
    4046:	mov    0x10(%rdi),%rcx
    404a:	mov    0x250(%rcx),%rdx
    4051:	lea    0x2d0(%rsp),%r9
    4059:	mov    %rbx,0x2d0(%rsp)
    4061:	mov    %rax,0x2d8(%rsp)
    4069:	mov    $0x2,%r8d
    406f:	mov    $0x5,%ecx
    4074:	mov    %r8,%rsi
    4077:	call   407c <botlish_fn_37+0x16f4>
			4078: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    407c:	jmp    45dc <botlish_fn_37+0x1c54>
    4081:	shl    $1,%rsi
    4084:	or     $0x1,%rsi
    4088:	mov    %rsi,0x140(%rsp)
    4090:	mov    %rsi,0x678(%rsp)
    4098:	mov    $0x1,%ecx
    409d:	movq   $0x1,0x118(%rsp)
    40a9:	mov    $0x3,%edi
    40ae:	mov    $0xa,%esi
    40b3:	mov    %rcx,0x528(%rsp)
    40bb:	mov    %rdi,0x530(%rsp)
    40c3:	mov    %rsi,0x668(%rsp)
    40cb:	mov    %rsi,0x670(%rsp)
    40d3:	mov    %rsi,0x680(%rsp)
    40db:	mov    %rsi,0x688(%rsp)
    40e3:	jmp    49d6 <botlish_fn_37+0x204e>
    40e8:	test   $0x1,%r12
    40ef:	jne    411f <botlish_fn_37+0x1797>
    40f5:	mov    $0x45,%edx
    40fa:	mov    %r12,%rsi
    40fd:	mov    0x520(%rsp),%rdi
    4105:	call   410a <botlish_fn_37+0x1782>
			4106: R_X86_64_PLT32	rt_int_cmp-0x4
    410a:	mov    $0x2,%ecx
    410f:	test   %rax,%rax
    4112:	cmovl  0x64c6(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    411a:	jmp    4130 <botlish_fn_37+0x17a8>
    411f:	mov    $0x2,%ecx
    4124:	cmp    $0x45,%r12
    4128:	cmovl  0x64b0(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    4130:	cmp    $0x6,%rcx
    4134:	je     41b0 <botlish_fn_37+0x1828>
    413a:	test   $0x1,%r12
    4141:	jne    4171 <botlish_fn_37+0x17e9>
    4147:	mov    $0x45,%edx
    414c:	mov    %r12,%rsi
    414f:	mov    0x520(%rsp),%rdi
    4157:	call   415c <botlish_fn_37+0x17d4>
			4158: R_X86_64_PLT32	rt_int_cmp-0x4
    415c:	mov    $0x2,%esi
    4161:	test   %rax,%rax
    4164:	cmovg  0x6474(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    416c:	jmp    4182 <botlish_fn_37+0x17fa>
    4171:	mov    $0x2,%esi
    4176:	cmp    $0x45,%r12
    417a:	cmovg  0x645e(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    4182:	cmp    $0x6,%rsi
    4186:	je     41b0 <botlish_fn_37+0x1828>
    418c:	mov    %r12,%rax
    418f:	sar    $1,%rax
    4192:	cmp    $0x22,%rax
    4196:	jl     41b0 <botlish_fn_37+0x1828>
    419c:	cmp    $0x23,%rax
    41a0:	jge    41b0 <botlish_fn_37+0x1828>
    41a6:	mov    $0x1,%esi
    41ab:	jmp    41b5 <botlish_fn_37+0x182d>
    41b0:	mov    $0x4,%esi
    41b5:	mov    %rsi,%rdi
    41b8:	shl    $1,%rdi
    41bb:	or     $0x1,%rdi
    41bf:	mov    $0x2,%eax
    41c4:	cmp    $0x5,%rdi
    41c8:	cmovl  0x6410(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    41d0:	cmp    $0x6,%rax
    41d4:	je     480a <botlish_fn_37+0x1e82>
    41da:	mov    %rsi,%r10
    41dd:	shl    $1,%r10
    41e0:	or     $0x1,%r10
    41e4:	mov    $0x2,%eax
    41e9:	cmp    $0x5,%r10
    41ed:	cmove  0x63eb(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    41f5:	cmp    $0x6,%rax
    41f9:	je     47fe <botlish_fn_37+0x1e76>
    41ff:	mov    %rsi,%rcx
    4202:	shl    $1,%rcx
    4205:	mov    %rsi,0x688(%rsp)
    420d:	or     $0x1,%rcx
    4211:	mov    $0x2,%eax
    4216:	cmp    $0x7,%rcx
    421a:	cmove  0x63be(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    4222:	cmp    $0x6,%rax
    4226:	je     4362 <botlish_fn_37+0x19da>
    422c:	test   $0x1,%r12
    4233:	jne    4265 <botlish_fn_37+0x18dd>
    4239:	mov    $0xffffffffffffffff,%rdx
    4240:	mov    %r12,%rsi
    4243:	mov    0x520(%rsp),%rdi
    424b:	call   4250 <botlish_fn_37+0x18c8>
			424c: R_X86_64_PLT32	rt_int_cmp-0x4
    4250:	mov    $0x2,%ecx
    4255:	test   %rax,%rax
    4258:	cmove  0x6380(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    4260:	jmp    4276 <botlish_fn_37+0x18ee>
    4265:	mov    $0x2,%ecx
    426a:	cmp    $0xffffffffffffffff,%r12
    426e:	cmove  0x636a(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    4276:	cmp    $0x6,%rcx
    427a:	je     42f8 <botlish_fn_37+0x1970>
    4280:	mov    0x520(%rsp),%rdi
    4288:	mov    0x10(%rdi),%rax
    428c:	mov    0x260(%rax),%rbx
    4293:	mov    $0x1,%r13d
    4299:	mov    0x688(%rsp),%rsi
    42a1:	shl    $1,%rsi
    42a4:	or     $0x1,%rsi
    42a8:	call   42ad <botlish_fn_37+0x1925>
			42a9: R_X86_64_PLT32	botlish_fn_7-0x4
    42ad:	mov    0x520(%rsp),%rdi
    42b5:	mov    0x10(%rdi),%rcx
    42b9:	mov    0x258(%rcx),%rdx
    42c0:	lea    0x2b8(%rsp),%r9
    42c8:	mov    %rbx,0x2b8(%rsp)
    42d0:	mov    %rax,0x2c0(%rsp)
    42d8:	mov    %r12,0x2c8(%rsp)
    42e0:	mov    $0x4,%ecx
    42e5:	mov    $0x3,%r8d
    42eb:	mov    %r13,%rsi
    42ee:	call   42f3 <botlish_fn_37+0x196b>
			42ef: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    42f3:	jmp    45dc <botlish_fn_37+0x1c54>
    42f8:	mov    0x688(%rsp),%rsi
    4300:	mov    0x520(%rsp),%rdi
    4308:	mov    0x10(%rdi),%rax
    430c:	mov    0x260(%rax),%rbx
    4313:	shl    $1,%rsi
    4316:	or     $0x1,%rsi
    431a:	call   431f <botlish_fn_37+0x1997>
			431b: R_X86_64_PLT32	botlish_fn_7-0x4
    431f:	mov    0x520(%rsp),%rdi
    4327:	mov    0x10(%rdi),%rcx
    432b:	mov    0x250(%rcx),%rdx
    4332:	lea    0x2a8(%rsp),%r9
    433a:	mov    %rbx,0x2a8(%rsp)
    4342:	mov    %rax,0x2b0(%rsp)
    434a:	mov    $0x2,%r8d
    4350:	mov    $0x5,%ecx
    4355:	mov    %r8,%rsi
    4358:	call   435d <botlish_fn_37+0x19d5>
			4359: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    435d:	jmp    45dc <botlish_fn_37+0x1c54>
    4362:	mov    0x520(%rsp),%rdi
    436a:	mov    0x10(%rdi),%rax
    436e:	mov    0x240(%rax),%rbx
    4375:	test   $0x1,%r12
    437c:	jne    43ae <botlish_fn_37+0x1a26>
    4382:	mov    $0xffffffffffffffff,%rdx
    4389:	mov    %r12,%rsi
    438c:	mov    0x520(%rsp),%rdi
    4394:	call   4399 <botlish_fn_37+0x1a11>
			4395: R_X86_64_PLT32	rt_int_cmp-0x4
    4399:	mov    $0x2,%ecx
    439e:	test   %rax,%rax
    43a1:	cmovl  0x6237(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    43a9:	jmp    43bf <botlish_fn_37+0x1a37>
    43ae:	mov    $0x2,%ecx
    43b3:	cmp    $0xffffffffffffffff,%r12
    43b7:	cmovl  0x6221(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    43bf:	cmp    $0x6,%rcx
    43c3:	je     4431 <botlish_fn_37+0x1aa9>
    43c9:	test   $0x1,%r12
    43d0:	jne    4401 <botlish_fn_37+0x1a79>
    43d6:	mov    $0x1ff,%edx
    43db:	mov    %r12,%rsi
    43de:	mov    0x520(%rsp),%rdi
    43e6:	call   43eb <botlish_fn_37+0x1a63>
			43e7: R_X86_64_PLT32	rt_int_cmp-0x4
    43eb:	mov    $0x2,%r10d
    43f1:	test   %rax,%rax
    43f4:	cmovg  0x61e4(%rip),%r10        # a5e0 <botlish_fn_37+0x7c58>
    43fc:	jmp    4416 <botlish_fn_37+0x1a8e>
    4401:	mov    $0x2,%r10d
    4407:	cmp    $0x1ff,%r12
    440e:	cmovg  0x61ca(%rip),%r10        # a5e0 <botlish_fn_37+0x7c58>
    4416:	cmp    $0x6,%r10
    441a:	je     4431 <botlish_fn_37+0x1aa9>
    4420:	mov    %r12,%rax
    4423:	sar    $1,%rax
    4426:	movzbq 0x11(%rbx,%rax,1),%rsi
    442c:	jmp    4439 <botlish_fn_37+0x1ab1>
    4431:	movzbq 0x616(%rbx),%rsi
    4439:	mov    %rsi,%rcx
    443c:	shl    $1,%rcx
    443f:	or     $0x1,%rcx
    4443:	mov    $0x2,%eax
    4448:	cmp    $0xd,%rcx
    444c:	cmovl  0x618c(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    4454:	cmp    $0x6,%rax
    4458:	je     478c <botlish_fn_37+0x1e04>
    445e:	mov    %rsi,%rcx
    4461:	shl    $1,%rcx
    4464:	mov    %rsi,0x670(%rsp)
    446c:	or     $0x1,%rcx
    4470:	mov    $0x2,%eax
    4475:	cmp    $0xd,%rcx
    4479:	cmove  0x615f(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    4481:	cmp    $0x6,%rax
    4485:	je     476e <botlish_fn_37+0x1de6>
    448b:	test   $0x1,%r12
    4492:	jne    44c4 <botlish_fn_37+0x1b3c>
    4498:	mov    $0xffffffffffffffff,%rdx
    449f:	mov    %r12,%rsi
    44a2:	mov    0x520(%rsp),%rdi
    44aa:	call   44af <botlish_fn_37+0x1b27>
			44ab: R_X86_64_PLT32	rt_int_cmp-0x4
    44af:	mov    $0x2,%ecx
    44b4:	test   %rax,%rax
    44b7:	cmove  0x6121(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    44bf:	jmp    44d5 <botlish_fn_37+0x1b4d>
    44c4:	mov    $0x2,%ecx
    44c9:	cmp    $0xffffffffffffffff,%r12
    44cd:	cmove  0x610b(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    44d5:	cmp    $0x6,%rcx
    44d9:	je     4567 <botlish_fn_37+0x1bdf>
    44df:	mov    0x520(%rsp),%rdi
    44e7:	mov    0x10(%rdi),%rax
    44eb:	mov    0x248(%rax),%r13
    44f2:	mov    $0x1,%r14d
    44f8:	mov    0x670(%rsp),%rsi
    4500:	shl    $1,%rsi
    4503:	mov    %rsi,0x670(%rsp)
    450b:	or     $0x1,%rsi
    450f:	mov    %rsi,0x670(%rsp)
    4517:	call   451c <botlish_fn_37+0x1b94>
			4518: R_X86_64_PLT32	botlish_fn_5-0x4
    451c:	mov    0x520(%rsp),%rdi
    4524:	mov    0x10(%rdi),%rcx
    4528:	mov    0x258(%rcx),%rdx
    452f:	lea    0x290(%rsp),%r9
    4537:	mov    %r13,0x290(%rsp)
    453f:	mov    %rax,0x298(%rsp)
    4547:	mov    %r12,0x2a0(%rsp)
    454f:	mov    $0x4,%ecx
    4554:	mov    $0x3,%r8d
    455a:	mov    %r14,%rsi
    455d:	call   4562 <botlish_fn_37+0x1bda>
			455e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4562:	jmp    45dc <botlish_fn_37+0x1c54>
    4567:	mov    0x520(%rsp),%rdi
    456f:	mov    0x10(%rdi),%rax
    4573:	mov    0x248(%rax),%rbx
    457a:	mov    0x670(%rsp),%rsi
    4582:	shl    $1,%rsi
    4585:	mov    %rsi,0x670(%rsp)
    458d:	or     $0x1,%rsi
    4591:	mov    %rsi,0x670(%rsp)
    4599:	call   459e <botlish_fn_37+0x1c16>
			459a: R_X86_64_PLT32	botlish_fn_5-0x4
    459e:	mov    0x520(%rsp),%rdi
    45a6:	mov    0x10(%rdi),%rcx
    45aa:	mov    0x250(%rcx),%rdx
    45b1:	lea    0x280(%rsp),%r9
    45b9:	mov    %rbx,0x280(%rsp)
    45c1:	mov    %rax,0x288(%rsp)
    45c9:	mov    $0x2,%r8d
    45cf:	mov    $0x5,%ecx
    45d4:	mov    %r8,%rsi
    45d7:	call   45dc <botlish_fn_37+0x1c54>
			45d8: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    45dc:	mov    0x520(%rsp),%rdi
    45e4:	call   45e9 <botlish_fn_37+0x1c61>
			45e5: R_X86_64_PLT32	rt_co_failed-0x4
    45e9:	mov    %rax,0x120(%rsp)
    45f1:	mov    %rax,%rsi
    45f4:	mov    0x520(%rsp),%rdi
    45fc:	call   4601 <botlish_fn_37+0x1c79>
			45fd: R_X86_64_PLT32	rt_co_resume0-0x4
    4601:	test   %rax,%rax
    4604:	je     4626 <botlish_fn_37+0x1c9e>
    460a:	mov    0x520(%rsp),%rdi
    4612:	mov    0x10(%rdi),%rax
    4616:	mov    0x48(%rax),%rsi
    461a:	mov    0x218(%rax),%rdx
    4621:	call   4626 <botlish_fn_37+0x1c9e>
			4622: R_X86_64_PLT32	rt_raise-0x4
    4626:	mov    0x520(%rsp),%rdi
    462e:	call   4633 <botlish_fn_37+0x1cab>
			462f: R_X86_64_PLT32	rt_declared_error-0x4
    4633:	cmp    $0x1,%rax
    4637:	je     46e1 <botlish_fn_37+0x1d59>
    463d:	mov    0x520(%rsp),%rdi
    4645:	call   464a <botlish_fn_37+0x1cc2>
			4646: R_X86_64_PLT32	rt_declared_error-0x4
    464a:	cmp    $0x2,%rax
    464e:	jne    a46f <botlish_fn_37+0x7ae7>
    4654:	xor    %rbx,%rbx
    4657:	mov    %rbx,%rsi
    465a:	mov    0x520(%rsp),%rdi
    4662:	call   4667 <botlish_fn_37+0x1cdf>
			4663: R_X86_64_PLT32	rt_declared_payload-0x4
    4667:	mov    %rax,%r15
    466a:	mov    $0x1,%esi
    466f:	mov    0x520(%rsp),%rdi
    4677:	call   467c <botlish_fn_37+0x1cf4>
			4678: R_X86_64_PLT32	rt_declared_payload-0x4
    467c:	mov    %rax,%r12
    467f:	mov    0x520(%rsp),%rdi
    4687:	call   468c <botlish_fn_37+0x1d04>
			4688: R_X86_64_PLT32	rt_clear_declared_error-0x4
    468c:	mov    0x520(%rsp),%rdi
    4694:	mov    0x10(%rdi),%rax
    4698:	mov    0x220(%rax),%rdx
    469f:	lea    0x168(%rsp),%r9
    46a7:	movq   $0x1,0x168(%rsp)
    46b3:	mov    %r15,%rax
    46b6:	mov    %rax,0x170(%rsp)
    46be:	mov    %r12,%rax
    46c1:	mov    %rax,0x178(%rsp)
    46c9:	mov    $0xc,%esi
    46ce:	mov    $0x3,%r8d
    46d4:	mov    %rbx,%rcx
    46d7:	call   46dc <botlish_fn_37+0x1d54>
			46d8: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    46dc:	jmp    a46f <botlish_fn_37+0x7ae7>
    46e1:	xor    %rbx,%rbx
    46e4:	mov    %rbx,%rsi
    46e7:	mov    0x520(%rsp),%rdi
    46ef:	call   46f4 <botlish_fn_37+0x1d6c>
			46f0: R_X86_64_PLT32	rt_declared_payload-0x4
    46f4:	mov    %rax,%r12
    46f7:	mov    $0x1,%esi
    46fc:	mov    0x520(%rsp),%rdi
    4704:	call   4709 <botlish_fn_37+0x1d81>
			4705: R_X86_64_PLT32	rt_declared_payload-0x4
    4709:	mov    %rax,%r13
    470c:	mov    0x520(%rsp),%rdi
    4714:	call   4719 <botlish_fn_37+0x1d91>
			4715: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4719:	mov    0x520(%rsp),%rdi
    4721:	mov    0x10(%rdi),%rax
    4725:	mov    0x220(%rax),%rdx
    472c:	lea    0x150(%rsp),%r9
    4734:	movq   $0x1,0x150(%rsp)
    4740:	mov    %r12,%rax
    4743:	mov    %rax,0x158(%rsp)
    474b:	mov    %r13,%rax
    474e:	mov    %rax,0x160(%rsp)
    4756:	mov    $0xc,%esi
    475b:	mov    $0x3,%r8d
    4761:	mov    %rbx,%rcx
    4764:	call   4769 <botlish_fn_37+0x1de1>
			4765: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4769:	jmp    a46f <botlish_fn_37+0x7ae7>
    476e:	mov    $0x3,%esi
    4773:	movq   $0x3,0x130(%rsp)
    477f:	mov    %rsi,0x688(%rsp)
    4787:	jmp    4821 <botlish_fn_37+0x1e99>
    478c:	mov    %rsi,0x670(%rsp)
    4794:	shl    $1,%rsi
    4797:	mov    %rsi,0x670(%rsp)
    479f:	or     $0x1,%rsi
    47a3:	mov    %rsi,0x670(%rsp)
    47ab:	mov    %rsi,0x138(%rsp)
    47b3:	mov    $0x1,%ecx
    47b8:	movq   $0x1,0x118(%rsp)
    47c4:	mov    $0xa,%esi
    47c9:	mov    %rcx,0x528(%rsp)
    47d1:	mov    %rcx,0x530(%rsp)
    47d9:	mov    %rsi,0x668(%rsp)
    47e1:	mov    %rsi,0x678(%rsp)
    47e9:	mov    %rsi,0x680(%rsp)
    47f1:	mov    %rsi,0x688(%rsp)
    47f9:	jmp    49d6 <botlish_fn_37+0x204e>
    47fe:	mov    $0xfffffffffffffffd,%r12
    4805:	jmp    4880 <botlish_fn_37+0x1ef8>
    480a:	shl    $1,%rsi
    480d:	or     $0x1,%rsi
    4811:	mov    %rsi,0x130(%rsp)
    4819:	mov    %rsi,0x688(%rsp)
    4821:	mov    $0x1,%ecx
    4826:	movq   $0x1,0x118(%rsp)
    4832:	mov    $0x2,%edi
    4837:	mov    $0xa,%esi
    483c:	mov    %rsi,0x670(%rsp)
    4844:	mov    %rcx,0x528(%rsp)
    484c:	mov    %rdi,0x530(%rsp)
    4854:	mov    0x670(%rsp),%rax
    485c:	mov    %rax,0x668(%rsp)
    4864:	mov    %rax,0x678(%rsp)
    486c:	mov    %rax,0x680(%rsp)
    4874:	jmp    49d6 <botlish_fn_37+0x204e>
    4879:	mov    $0xfffffffffffffffd,%r12
    4880:	test   $0x1,%r12
    4887:	jne    48b9 <botlish_fn_37+0x1f31>
    488d:	mov    $0xfffffffffffffffd,%rdx
    4894:	mov    %r12,%rsi
    4897:	mov    0x520(%rsp),%rdi
    489f:	call   48a4 <botlish_fn_37+0x1f1c>
			48a0: R_X86_64_PLT32	rt_int_cmp-0x4
    48a4:	mov    $0x2,%ecx
    48a9:	test   %rax,%rax
    48ac:	cmove  0x5d2c(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    48b4:	jmp    48ca <botlish_fn_37+0x1f42>
    48b9:	mov    $0x2,%ecx
    48be:	cmp    $0xfffffffffffffffd,%r12
    48c2:	cmove  0x5d16(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    48ca:	cmp    $0x6,%rcx
    48ce:	je     48dc <botlish_fn_37+0x1f54>
    48d4:	xor    %rax,%rax
    48d7:	jmp    35ad <botlish_fn_37+0xc25>
    48dc:	mov    $0x1,%esi
    48e1:	mov    %rsi,0x668(%rsp)
    48e9:	movq   $0x1,0x128(%rsp)
    48f5:	jmp    4983 <botlish_fn_37+0x1ffb>
    48fa:	mov    $0x1,%ecx
    48ff:	movq   $0x1,0x118(%rsp)
    490b:	mov    $0xffffffffffffffff,%rdi
    4912:	mov    $0xa,%esi
    4917:	mov    %rsi,0x670(%rsp)
    491f:	mov    %rcx,0x528(%rsp)
    4927:	mov    %rdi,0x530(%rsp)
    492f:	mov    0x670(%rsp),%rax
    4937:	mov    %rax,0x668(%rsp)
    493f:	mov    %rax,0x678(%rsp)
    4947:	mov    %rax,0x680(%rsp)
    494f:	mov    %rax,0x688(%rsp)
    4957:	jmp    49d6 <botlish_fn_37+0x204e>
    495c:	mov    %rsi,0x668(%rsp)
    4964:	shl    $1,%rsi
    4967:	mov    %rsi,0x668(%rsp)
    496f:	or     $0x1,%rsi
    4973:	mov    %rsi,0x668(%rsp)
    497b:	mov    %rsi,0x128(%rsp)
    4983:	mov    $0x1,%ecx
    4988:	mov    %rcx,0x528(%rsp)
    4990:	movq   $0x1,0x118(%rsp)
    499c:	mov    $0x5,%edi
    49a1:	mov    %rdi,0x530(%rsp)
    49a9:	mov    $0xa,%esi
    49ae:	mov    %rsi,0x670(%rsp)
    49b6:	mov    0x670(%rsp),%rax
    49be:	mov    %rax,0x678(%rsp)
    49c6:	mov    %rax,0x680(%rsp)
    49ce:	mov    %rax,0x688(%rsp)
    49d6:	mov    0x6d0(%rsp),%rbx
    49de:	mov    0x18(%rbx),%rcx
    49e2:	test   %rcx,%rcx
    49e5:	je     a4da <botlish_fn_37+0x7b52>
    49eb:	mov    %r13,%rcx
    49ee:	mov    %rbx,0x6d0(%rsp)
    49f6:	mov    0x10(%rbx),%rax
    49fa:	mov    %rcx,0x10(%rax)
    49fe:	mov    $0xa,%eax
    4a03:	mov    %rax,0x540(%rsp)
    4a0b:	xor    %r12,%r12
    4a0e:	mov    %r12,0x550(%rsp)
    4a16:	mov    $0x10,%eax
    4a1b:	mov    %rax,0x698(%rsp)
    4a23:	mov    $0x7fffffff,%eax
    4a28:	mov    %rax,%rcx
    4a2b:	neg    %rcx
    4a2e:	mov    %rcx,%r14
    4a31:	cmovs  %rax,%r14
    4a35:	mov    %r14,0x690(%rsp)
    4a3d:	mov    0x540(%rsp),%rax
    4a45:	mov    %rax,0x548(%rsp)
    4a4d:	mov    %rax,0x560(%rsp)
    4a55:	mov    %rax,0x568(%rsp)
    4a5d:	mov    %rax,0x570(%rsp)
    4a65:	mov    %rax,0x578(%rsp)
    4a6d:	mov    %rax,0x590(%rsp)
    4a75:	mov    %rax,0x598(%rsp)
    4a7d:	mov    %rax,0x5a8(%rsp)
    4a85:	mov    0x550(%rsp),%rax
    4a8d:	mov    %rax,0x5b0(%rsp)
    4a95:	mov    0x540(%rsp),%rax
    4a9d:	mov    %rax,0x5b8(%rsp)
    4aa5:	mov    %rax,0x5c0(%rsp)
    4aad:	mov    %rax,0x5c8(%rsp)
    4ab5:	mov    0x550(%rsp),%rax
    4abd:	mov    %rax,0x5d0(%rsp)
    4ac5:	mov    %rax,0x5e8(%rsp)
    4acd:	mov    %rax,0x5f0(%rsp)
    4ad5:	mov    0x540(%rsp),%rax
    4add:	mov    %rax,0x5f8(%rsp)
    4ae5:	mov    %rax,0x600(%rsp)
    4aed:	mov    %rax,0x608(%rsp)
    4af5:	mov    %rax,0x610(%rsp)
    4afd:	mov    %rax,0x628(%rsp)
    4b05:	mov    %rax,0x630(%rsp)
    4b0d:	mov    0x550(%rsp),%rax
    4b15:	mov    %rax,0x638(%rsp)
    4b1d:	mov    %rax,0x640(%rsp)
    4b25:	mov    0x540(%rsp),%rax
    4b2d:	mov    %rax,0x648(%rsp)
    4b35:	mov    0x550(%rsp),%rax
    4b3d:	mov    %rax,0x650(%rsp)
    4b45:	mov    %rax,0x658(%rsp)
    4b4d:	movq   $0x1,(%rsp)
    4b55:	mov    0x6d0(%rsp),%rbx
    4b5d:	mov    0x10(%rbx),%rax
    4b61:	mov    (%rax),%rsi
    4b64:	mov    %rsi,0x10(%rsp)
    4b69:	mov    0x6d0(%rsp),%rbx
    4b71:	mov    0x10(%rbx),%rax
    4b75:	mov    0x10(%rax),%rdx
    4b79:	mov    %rdx,0x18(%rsp)
    4b7e:	mov    %rdx,%rbx
    4b81:	movq   $0x3f,0x20(%rsp)
    4b8a:	test   $0x1,%rsi
    4b91:	je     4bbb <botlish_fn_37+0x2233>
    4b97:	mov    %rsi,%rax
    4b9a:	sar    $1,%rax
    4b9d:	imulq  0x5a4c(%rip)        # a5f0 <botlish_fn_37+0x7c68>
    4ba4:	seto   %cl
    4ba7:	or     $0x1,%rax
    4bab:	test   %cl,%cl
    4bad:	jne    4bbb <botlish_fn_37+0x2233>
    4bb3:	mov    %rax,%rsi
    4bb6:	jmp    4bd0 <botlish_fn_37+0x2248>
    4bbb:	mov    $0x3f,%edx
    4bc0:	mov    0x520(%rsp),%rdi
    4bc8:	call   4bcd <botlish_fn_37+0x2245>
			4bc9: R_X86_64_PLT32	rt_int_mul-0x4
    4bcd:	mov    %rax,%rsi
    4bd0:	mov    %rsi,0x10(%rsp)
    4bd5:	mov    %rbx,%rdx
    4bd8:	mov    %rsi,%rax
    4bdb:	and    %rdx,%rax
    4bde:	test   $0x1,%rax
    4be4:	je     4bff <botlish_fn_37+0x2277>
    4bea:	lea    -0x1(%rdx),%rcx
    4bee:	mov    %rsi,%rax
    4bf1:	add    %rcx,%rax
    4bf4:	seto   %cl
    4bf7:	test   %cl,%cl
    4bf9:	je     4c0c <botlish_fn_37+0x2284>
    4bff:	mov    0x520(%rsp),%rdi
    4c07:	call   4c0c <botlish_fn_37+0x2284>
			4c08: R_X86_64_PLT32	rt_int_add-0x4
    4c0c:	mov    %rax,0x10(%rsp)
    4c11:	movq   $0x3,0x18(%rsp)
    4c1a:	test   $0x1,%rax
    4c20:	jne    4c2e <botlish_fn_37+0x22a6>
    4c26:	mov    %rax,%rcx
    4c29:	jmp    4c43 <botlish_fn_37+0x22bb>
    4c2e:	mov    %rax,%rsi
    4c31:	add    $0x2,%rsi
    4c35:	mov    %rax,%rcx
    4c38:	seto   %al
    4c3b:	test   %al,%al
    4c3d:	je     4c5b <botlish_fn_37+0x22d3>
    4c43:	mov    $0x3,%edx
    4c48:	mov    %rcx,%rsi
    4c4b:	mov    0x520(%rsp),%rdi
    4c53:	call   4c58 <botlish_fn_37+0x22d0>
			4c54: R_X86_64_PLT32	rt_int_add-0x4
    4c58:	mov    %rax,%rsi
    4c5b:	mov    %rsi,0x10(%rsp)
    4c60:	mov    $0xffffffff,%eax
    4c65:	mov    %rax,0x18(%rsp)
    4c6a:	test   $0x1,%rsi
    4c71:	jne    4cc0 <botlish_fn_37+0x2338>
    4c77:	mov    $0xffffffff,%edx
    4c7c:	mov    0x520(%rsp),%rdi
    4c84:	call   4c89 <botlish_fn_37+0x2301>
			4c85: R_X86_64_PLT32	rt_int_mod-0x4
    4c89:	test   %rax,%rax
    4c8c:	jne    4cb0 <botlish_fn_37+0x2328>
    4c92:	mov    0x520(%rsp),%rdi
    4c9a:	call   4c9f <botlish_fn_37+0x2317>
			4c9b: R_X86_64_PLT32	rt_declared_error-0x4
    4c9f:	cmp    $0x40000001,%rax
    4ca5:	jne    a46f <botlish_fn_37+0x7ae7>
    4cab:	jmp    a46f <botlish_fn_37+0x7ae7>
    4cb0:	mov    %rax,%rcx
    4cb3:	mov    0x6d0(%rsp),%rbx
    4cbb:	jmp    4d0e <botlish_fn_37+0x2386>
    4cc0:	sar    $1,%rsi
    4cc3:	mov    %rsi,%rax
    4cc6:	imulq  0x592b(%rip)        # a5f8 <botlish_fn_37+0x7c70>
    4ccd:	lea    (%rdx,%rsi,1),%rcx
    4cd1:	sar    $0x1e,%rcx
    4cd5:	mov    %rcx,%rdx
    4cd8:	shr    $0x3f,%rdx
    4cdc:	add    %rcx,%rdx
    4cdf:	imul   $0x7fffffff,%rdx,%rdx
    4ce6:	sub    %rdx,%rsi
    4ce9:	mov    0x690(%rsp),%rcx
    4cf1:	lea    (%rsi,%rcx,1),%rdx
    4cf5:	test   %rsi,%rsi
    4cf8:	cmovl  %rdx,%rsi
    4cfc:	shl    $1,%rsi
    4cff:	or     $0x1,%rsi
    4d03:	mov    %rsi,%rcx
    4d06:	mov    0x6d0(%rsp),%rbx
    4d0e:	mov    0x6d0(%rsp),%rbx
    4d16:	mov    0x18(%rbx),%rsi
    4d1a:	test   %rsi,%rsi
    4d1d:	je     a4ff <botlish_fn_37+0x7b77>
    4d23:	mov    0x6d0(%rsp),%rbx
    4d2b:	mov    0x10(%rbx),%rdi
    4d2f:	mov    %rcx,(%rdi)
    4d32:	movq   $0x3,(%rsp)
    4d3a:	mov    0x6d0(%rsp),%rbx
    4d42:	mov    0x10(%rbx),%r11
    4d46:	mov    0x8(%r11),%rsi
    4d4a:	mov    %rsi,0x10(%rsp)
    4d4f:	movq   $0x3,0x18(%rsp)
    4d58:	test   $0x1,%rsi
    4d5f:	je     4d84 <botlish_fn_37+0x23fc>
    4d65:	mov    %rsi,%rcx
    4d68:	add    $0x2,%rcx
    4d6c:	seto   %al
    4d6f:	test   %al,%al
    4d71:	jne    4d84 <botlish_fn_37+0x23fc>
    4d77:	mov    0x6d0(%rsp),%rbx
    4d7f:	jmp    4da1 <botlish_fn_37+0x2419>
    4d84:	mov    $0x3,%edx
    4d89:	mov    0x520(%rsp),%rdi
    4d91:	call   4d96 <botlish_fn_37+0x240e>
			4d92: R_X86_64_PLT32	rt_int_add-0x4
    4d96:	mov    %rax,%rcx
    4d99:	mov    0x6d0(%rsp),%rbx
    4da1:	mov    0x6d0(%rsp),%rbx
    4da9:	mov    0x18(%rbx),%rax
    4dad:	test   %rax,%rax
    4db0:	je     a51e <botlish_fn_37+0x7b96>
    4db6:	mov    0x6d0(%rsp),%rbx
    4dbe:	mov    0x10(%rbx),%rax
    4dc2:	mov    %rcx,0x8(%rax)
    4dc6:	cmp    $0x1,%r15
    4dca:	je     6da8 <botlish_fn_37+0x4420>
    4dd0:	cmp    $0x2,%r15
    4dd4:	je     6da8 <botlish_fn_37+0x4420>
    4dda:	cmp    $0x3,%r15
    4dde:	je     6c16 <botlish_fn_37+0x428e>
    4de4:	cmp    $0x4,%r15
    4de8:	je     6bee <botlish_fn_37+0x4266>
    4dee:	cmp    $0x5,%r15
    4df2:	je     6bca <botlish_fn_37+0x4242>
    4df8:	cmp    $0x6,%r15
    4dfc:	je     6aaa <botlish_fn_37+0x4122>
    4e02:	cmp    $0x7,%r15
    4e06:	je     6aa0 <botlish_fn_37+0x4118>
    4e0c:	cmp    $0x8,%r15
    4e10:	je     6a9b <botlish_fn_37+0x4113>
    4e16:	cmp    $0x9,%r15
    4e1a:	je     6a91 <botlish_fn_37+0x4109>
    4e20:	cmp    $0xa,%r15
    4e24:	je     6a87 <botlish_fn_37+0x40ff>
    4e2a:	cmp    $0xb,%r15
    4e2e:	je     6a7d <botlish_fn_37+0x40f5>
    4e34:	cmp    $0xc,%r15
    4e38:	je     6a5c <botlish_fn_37+0x40d4>
    4e3e:	cmp    $0xd,%r15
    4e42:	je     6a3b <botlish_fn_37+0x40b3>
    4e48:	cmp    $0xe,%r15
    4e4c:	je     69ba <botlish_fn_37+0x4032>
    4e52:	cmp    $0xf,%r15
    4e56:	je     693b <botlish_fn_37+0x3fb3>
    4e5c:	cmp    $0x10,%r15
    4e60:	je     693b <botlish_fn_37+0x3fb3>
    4e66:	cmp    $0x11,%r15
    4e6a:	je     6931 <botlish_fn_37+0x3fa9>
    4e70:	cmp    $0x12,%r15
    4e74:	je     6931 <botlish_fn_37+0x3fa9>
    4e7a:	cmp    $0x13,%r15
    4e7e:	je     6927 <botlish_fn_37+0x3f9f>
    4e84:	cmp    $0x14,%r15
    4e88:	je     6906 <botlish_fn_37+0x3f7e>
    4e8e:	mov    $0x15,%r12d
    4e94:	cmp    $0x15,%r15
    4e98:	je     6e42 <botlish_fn_37+0x44ba>
    4e9e:	cmp    $0x16,%r15
    4ea2:	je     677d <botlish_fn_37+0x3df5>
    4ea8:	cmp    $0x17,%r15
    4eac:	je     677d <botlish_fn_37+0x3df5>
    4eb2:	cmp    $0x18,%r15
    4eb6:	je     675c <botlish_fn_37+0x3dd4>
    4ebc:	cmp    $0x19,%r15
    4ec0:	je     673b <botlish_fn_37+0x3db3>
    4ec6:	cmp    $0x1a,%r15
    4eca:	je     671a <botlish_fn_37+0x3d92>
    4ed0:	cmp    $0x1b,%r15
    4ed4:	je     677d <botlish_fn_37+0x3df5>
    4eda:	cmp    $0x1c,%r15
    4ede:	je     66f9 <botlish_fn_37+0x3d71>
    4ee4:	cmp    $0x1d,%r15
    4ee8:	je     66d8 <botlish_fn_37+0x3d50>
    4eee:	cmp    $0x1e,%r15
    4ef2:	je     66b7 <botlish_fn_37+0x3d2f>
    4ef8:	cmp    $0x1f,%r15
    4efc:	je     66ad <botlish_fn_37+0x3d25>
    4f02:	cmp    $0x20,%r15
    4f06:	je     668c <botlish_fn_37+0x3d04>
    4f0c:	cmp    $0x21,%r15
    4f10:	je     666b <botlish_fn_37+0x3ce3>
    4f16:	cmp    $0x22,%r15
    4f1a:	je     664a <botlish_fn_37+0x3cc2>
    4f20:	cmp    $0x23,%r15
    4f24:	je     6629 <botlish_fn_37+0x3ca1>
    4f2a:	cmp    $0x24,%r15
    4f2e:	je     661f <botlish_fn_37+0x3c97>
    4f34:	cmp    $0x25,%r15
    4f38:	je     6615 <botlish_fn_37+0x3c8d>
    4f3e:	cmp    $0x26,%r15
    4f42:	je     6304 <botlish_fn_37+0x397c>
    4f48:	cmp    $0x27,%r15
    4f4c:	je     611a <botlish_fn_37+0x3792>
    4f52:	cmp    $0x28,%r15
    4f56:	je     6003 <botlish_fn_37+0x367b>
    4f5c:	cmp    $0x29,%r15
    4f60:	je     5e0e <botlish_fn_37+0x3486>
    4f66:	cmp    $0x2a,%r15
    4f6a:	je     5cf8 <botlish_fn_37+0x3370>
    4f70:	cmp    $0x2b,%r15
    4f74:	je     5b62 <botlish_fn_37+0x31da>
    4f7a:	cmp    $0x2c,%r15
    4f7e:	je     5b3a <botlish_fn_37+0x31b2>
    4f84:	cmp    $0x2d,%r15
    4f88:	je     5b16 <botlish_fn_37+0x318e>
    4f8e:	cmp    $0x2e,%r15
    4f92:	je     59ec <botlish_fn_37+0x3064>
    4f98:	cmp    $0x2f,%r15
    4f9c:	je     59d2 <botlish_fn_37+0x304a>
    4fa2:	cmp    $0x30,%r15
    4fa6:	je     59c0 <botlish_fn_37+0x3038>
    4fac:	cmp    $0x31,%r15
    4fb0:	je     59ae <botlish_fn_37+0x3026>
    4fb6:	cmp    $0x32,%r15
    4fba:	je     599c <botlish_fn_37+0x3014>
    4fc0:	cmp    $0x33,%r15
    4fc4:	je     598a <botlish_fn_37+0x3002>
    4fca:	cmp    $0x34,%r15
    4fce:	je     5961 <botlish_fn_37+0x2fd9>
    4fd4:	cmp    $0x35,%r15
    4fd8:	je     5938 <botlish_fn_37+0x2fb0>
    4fde:	cmp    $0x36,%r15
    4fe2:	je     58c3 <botlish_fn_37+0x2f3b>
    4fe8:	cmp    $0x37,%r15
    4fec:	je     584e <botlish_fn_37+0x2ec6>
    4ff2:	cmp    $0x38,%r15
    4ff6:	je     584e <botlish_fn_37+0x2ec6>
    4ffc:	cmp    $0x39,%r15
    5000:	je     583c <botlish_fn_37+0x2eb4>
    5006:	cmp    $0x3a,%r15
    500a:	je     583c <botlish_fn_37+0x2eb4>
    5010:	cmp    $0x3b,%r15
    5014:	je     582a <botlish_fn_37+0x2ea2>
    501a:	cmp    $0x3c,%r15
    501e:	je     5820 <botlish_fn_37+0x2e98>
    5024:	cmp    $0x3d,%r15
    5028:	je     560e <botlish_fn_37+0x2c86>
    502e:	cmp    $0x3e,%r15
    5032:	je     5478 <botlish_fn_37+0x2af0>
    5038:	cmp    $0x3f,%r15
    503c:	je     5450 <botlish_fn_37+0x2ac8>
    5042:	cmp    $0x40,%r15
    5046:	je     542c <botlish_fn_37+0x2aa4>
    504c:	cmp    $0x41,%r15
    5050:	je     5304 <botlish_fn_37+0x297c>
    5056:	cmp    $0x42,%r15
    505a:	je     52ea <botlish_fn_37+0x2962>
    5060:	cmp    $0x43,%r15
    5064:	je     52d8 <botlish_fn_37+0x2950>
    506a:	cmp    $0x44,%r15
    506e:	je     52c6 <botlish_fn_37+0x293e>
    5074:	cmp    $0x45,%r15
    5078:	je     52b4 <botlish_fn_37+0x292c>
    507e:	cmp    $0x46,%r15
    5082:	je     52a2 <botlish_fn_37+0x291a>
    5088:	cmp    $0x47,%r15
    508c:	je     5279 <botlish_fn_37+0x28f1>
    5092:	cmp    $0x48,%r15
    5096:	je     5250 <botlish_fn_37+0x28c8>
    509c:	cmp    $0x49,%r15
    50a0:	je     51db <botlish_fn_37+0x2853>
    50a6:	cmp    $0x4a,%r15
    50aa:	je     5166 <botlish_fn_37+0x27de>
    50b0:	cmp    $0x4b,%r15
    50b4:	je     5166 <botlish_fn_37+0x27de>
    50ba:	cmp    $0x4c,%r15
    50be:	je     5154 <botlish_fn_37+0x27cc>
    50c4:	cmp    $0x4d,%r15
    50c8:	je     5154 <botlish_fn_37+0x27cc>
    50ce:	cmp    $0x4e,%r15
    50d2:	je     5142 <botlish_fn_37+0x27ba>
    50d8:	cmp    $0x4f,%r15
    50dc:	je     5121 <botlish_fn_37+0x2799>
    50e2:	cmp    $0x50,%r15
    50e6:	je     5114 <botlish_fn_37+0x278c>
    50ec:	cmp    $0x51,%r15
    50f0:	je     677d <botlish_fn_37+0x3df5>
    50f6:	cmp    $0x52,%r15
    50fa:	je     677d <botlish_fn_37+0x3df5>
    5100:	mov    $0xa,%esi
    5105:	cmp    $0xffffffffffffffff,%r15
    5109:	je     7548 <botlish_fn_37+0x4bc0>
    510f:	jmp    74a6 <botlish_fn_37+0x4b1e>
    5114:	mov    0x648(%rsp),%rax
    511c:	jmp    5631 <botlish_fn_37+0x2ca9>
    5121:	mov    $0x75,%ecx
    5126:	movq   $0x75,0x28(%rsp)
    512f:	mov    $0x50,%r15d
    5135:	mov    %rcx,0x660(%rsp)
    513d:	jmp    7548 <botlish_fn_37+0x4bc0>
    5142:	mov    $0xa,%ecx
    5147:	mov    0x5d0(%rsp),%rax
    514f:	jmp    52f7 <botlish_fn_37+0x296f>
    5154:	mov    $0xa,%ecx
    5159:	mov    0x5d0(%rsp),%rax
    5161:	jmp    52f2 <botlish_fn_37+0x296a>
    5166:	mov    0x5d0(%rsp),%rax
    516e:	mov    %rax,%rcx
    5171:	and    $0xf,%rcx
    5175:	cmp    $0xa,%rcx
    5179:	jl     51ad <botlish_fn_37+0x2825>
    517f:	add    $0x57,%rcx
    5186:	shl    $1,%rcx
    5189:	or     $0x1,%rcx
    518d:	mov    %rcx,0x28(%rsp)
    5192:	mov    $0x4d,%r15d
    5198:	mov    %rax,0x5d0(%rsp)
    51a0:	mov    %rcx,0x660(%rsp)
    51a8:	jmp    7548 <botlish_fn_37+0x4bc0>
    51ad:	add    $0x30,%rcx
    51b4:	shl    $1,%rcx
    51b7:	or     $0x1,%rcx
    51bb:	mov    %rcx,0x28(%rsp)
    51c0:	mov    $0x4c,%r15d
    51c6:	mov    %rax,0x5d0(%rsp)
    51ce:	mov    %rcx,0x660(%rsp)
    51d6:	jmp    7548 <botlish_fn_37+0x4bc0>
    51db:	mov    0x5d0(%rsp),%rax
    51e3:	mov    %rax,%rcx
    51e6:	sar    $0x4,%rcx
    51ea:	cmp    $0xa,%rcx
    51ee:	jl     5222 <botlish_fn_37+0x289a>
    51f4:	add    $0x57,%rcx
    51fb:	shl    $1,%rcx
    51fe:	or     $0x1,%rcx
    5202:	mov    %rcx,0x28(%rsp)
    5207:	mov    $0x4b,%r15d
    520d:	mov    %rax,0x5d0(%rsp)
    5215:	mov    %rcx,0x660(%rsp)
    521d:	jmp    7548 <botlish_fn_37+0x4bc0>
    5222:	add    $0x30,%rcx
    5229:	shl    $1,%rcx
    522c:	or     $0x1,%rcx
    5230:	mov    %rcx,0x28(%rsp)
    5235:	mov    $0x4a,%r15d
    523b:	mov    %rax,0x5d0(%rsp)
    5243:	mov    %rcx,0x660(%rsp)
    524b:	jmp    7548 <botlish_fn_37+0x4bc0>
    5250:	mov    0x5d0(%rsp),%rax
    5258:	mov    $0x61,%ecx
    525d:	movq   $0x61,0x28(%rsp)
    5266:	mov    $0x49,%r15d
    526c:	mov    %rcx,0x660(%rsp)
    5274:	jmp    7548 <botlish_fn_37+0x4bc0>
    5279:	mov    0x5d0(%rsp),%rax
    5281:	mov    $0x61,%ecx
    5286:	movq   $0x61,0x28(%rsp)
    528f:	mov    $0x48,%r15d
    5295:	mov    %rcx,0x660(%rsp)
    529d:	jmp    7548 <botlish_fn_37+0x4bc0>
    52a2:	mov    0x5d0(%rsp),%rax
    52aa:	mov    $0xa,%ecx
    52af:	jmp    52f2 <botlish_fn_37+0x296a>
    52b4:	mov    0x5d0(%rsp),%rax
    52bc:	mov    $0xa,%ecx
    52c1:	jmp    52f2 <botlish_fn_37+0x296a>
    52c6:	mov    0x5d0(%rsp),%rax
    52ce:	mov    $0xa,%ecx
    52d3:	jmp    52f2 <botlish_fn_37+0x296a>
    52d8:	mov    0x5d0(%rsp),%rax
    52e0:	mov    $0xa,%ecx
    52e5:	jmp    52f2 <botlish_fn_37+0x296a>
    52ea:	mov    0x5d0(%rsp),%rax
    52f2:	mov    $0xa,%ecx
    52f7:	mov    %rax,0x5d0(%rsp)
    52ff:	jmp    542c <botlish_fn_37+0x2aa4>
    5304:	mov    0x5d0(%rsp),%rax
    530c:	cmp    $0x8,%rax
    5310:	je     5403 <botlish_fn_37+0x2a7b>
    5316:	cmp    $0x9,%rax
    531a:	je     53da <botlish_fn_37+0x2a52>
    5320:	cmp    $0xa,%rax
    5324:	je     53b1 <botlish_fn_37+0x2a29>
    532a:	cmp    $0xc,%rax
    532e:	je     5388 <botlish_fn_37+0x2a00>
    5334:	cmp    $0xd,%rax
    5338:	mov    %rax,0x5d0(%rsp)
    5340:	je     5367 <botlish_fn_37+0x29df>
    5346:	mov    $0xeb,%ecx
    534b:	movq   $0xeb,0x28(%rsp)
    5354:	mov    $0x47,%r15d
    535a:	mov    %rcx,0x660(%rsp)
    5362:	jmp    7548 <botlish_fn_37+0x4bc0>
    5367:	mov    $0xe5,%ecx
    536c:	movq   $0xe5,0x28(%rsp)
    5375:	mov    $0x46,%r15d
    537b:	mov    %rcx,0x660(%rsp)
    5383:	jmp    7548 <botlish_fn_37+0x4bc0>
    5388:	mov    %rax,0x5d0(%rsp)
    5390:	mov    $0xcd,%ecx
    5395:	movq   $0xcd,0x28(%rsp)
    539e:	mov    $0x45,%r15d
    53a4:	mov    %rcx,0x660(%rsp)
    53ac:	jmp    7548 <botlish_fn_37+0x4bc0>
    53b1:	mov    %rax,0x5d0(%rsp)
    53b9:	mov    $0xdd,%ecx
    53be:	movq   $0xdd,0x28(%rsp)
    53c7:	mov    $0x44,%r15d
    53cd:	mov    %rcx,0x660(%rsp)
    53d5:	jmp    7548 <botlish_fn_37+0x4bc0>
    53da:	mov    %rax,0x5d0(%rsp)
    53e2:	mov    $0xe9,%ecx
    53e7:	movq   $0xe9,0x28(%rsp)
    53f0:	mov    $0x43,%r15d
    53f6:	mov    %rcx,0x660(%rsp)
    53fe:	jmp    7548 <botlish_fn_37+0x4bc0>
    5403:	mov    %rax,0x5d0(%rsp)
    540b:	mov    $0xc5,%ecx
    5410:	movq   $0xc5,0x28(%rsp)
    5419:	mov    $0x42,%r15d
    541f:	mov    %rcx,0x660(%rsp)
    5427:	jmp    7548 <botlish_fn_37+0x4bc0>
    542c:	mov    0x650(%rsp),%rsi
    5434:	add    $0x1,%rsi
    543b:	mov    0x5c8(%rsp),%rax
    5443:	mov    0x658(%rsp),%rcx
    544b:	jmp    5499 <botlish_fn_37+0x2b11>
    5450:	mov    0x5c8(%rsp),%rax
    5458:	mov    0x650(%rsp),%rsi
    5460:	mov    %rax,0x28(%rsp)
    5465:	mov    $0x40,%r15d
    546b:	mov    %rax,0x660(%rsp)
    5473:	jmp    7548 <botlish_fn_37+0x4bc0>
    5478:	mov    0x5c8(%rsp),%rax
    5480:	mov    0x5c0(%rsp),%rdi
    5488:	mov    0x8(%rdi),%rcx
    548c:	xor    %rsi,%rsi
    548f:	shl    $1,%rcx
    5492:	or     $0x1,%rcx
    5496:	sar    $1,%rcx
    5499:	cmp    %rcx,%rsi
    549c:	mov    %rcx,0x658(%rsp)
    54a4:	jl     54db <botlish_fn_37+0x2b53>
    54aa:	mov    $0x45,%ecx
    54af:	movq   $0x45,0x28(%rsp)
    54b8:	mov    $0x4f,%r15d
    54be:	mov    %rax,0x5c8(%rsp)
    54c6:	mov    %rsi,0x650(%rsp)
    54ce:	mov    %rcx,0x660(%rsp)
    54d6:	jmp    7548 <botlish_fn_37+0x4bc0>
    54db:	mov    0x5c0(%rsp),%rax
    54e3:	movzbq 0x18(%rax),%rax
    54e8:	test   %rax,%rax
    54eb:	jne    551d <botlish_fn_37+0x2b95>
    54f1:	mov    %rsi,%rdx
    54f4:	shl    $1,%rdx
    54f7:	mov    %rsi,0x650(%rsp)
    54ff:	or     $0x1,%rdx
    5503:	mov    0x5c0(%rsp),%rsi
    550b:	mov    0x520(%rsp),%rdi
    5513:	call   5518 <botlish_fn_37+0x2b90>
			5514: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    5518:	jmp    554b <botlish_fn_37+0x2bc3>
    551d:	mov    %rsi,%rcx
    5520:	mov    %rsi,0x650(%rsp)
    5528:	mov    %rcx,%rax
    552b:	shl    $1,%rax
    552e:	or     $0x1,%rax
    5532:	sar    $1,%rax
    5535:	mov    0x5c0(%rsp),%rcx
    553d:	movzbq 0x19(%rcx,%rax,1),%rax
    5543:	shl    $0x3,%rax
    5547:	or     $0x4,%rax
    554b:	shr    $0x3,%rax
    554f:	shl    $1,%rax
    5552:	or     $0x1,%rax
    5556:	mov    %rax,0x110(%rsp)
    555e:	mov    %rax,%rdx
    5561:	sar    $1,%rdx
    5564:	cmp    $0x22,%rdx
    5568:	jne    557b <botlish_fn_37+0x2bf3>
    556e:	mov    %rax,0x5c8(%rsp)
    5576:	jmp    55ed <botlish_fn_37+0x2c65>
    557b:	cmp    $0x5c,%rdx
    557f:	jne    5592 <botlish_fn_37+0x2c0a>
    5585:	mov    %rax,0x5c8(%rsp)
    558d:	jmp    55ed <botlish_fn_37+0x2c65>
    5592:	cmp    $0x20,%rdx
    5596:	jl     55bc <botlish_fn_37+0x2c34>
    559c:	mov    %rax,0x28(%rsp)
    55a1:	mov    %rax,0x5c8(%rsp)
    55a9:	mov    $0x4e,%r15d
    55af:	mov    %rax,0x660(%rsp)
    55b7:	jmp    7548 <botlish_fn_37+0x4bc0>
    55bc:	mov    %rax,0x5c8(%rsp)
    55c4:	mov    $0xb9,%ecx
    55c9:	movq   $0xb9,0x28(%rsp)
    55d2:	mov    $0x41,%r15d
    55d8:	mov    %rdx,0x5d0(%rsp)
    55e0:	mov    %rcx,0x660(%rsp)
    55e8:	jmp    7548 <botlish_fn_37+0x4bc0>
    55ed:	mov    $0xb9,%ecx
    55f2:	movq   $0xb9,0x28(%rsp)
    55fb:	mov    $0x3f,%r15d
    5601:	mov    %rcx,0x660(%rsp)
    5609:	jmp    7548 <botlish_fn_37+0x4bc0>
    560e:	mov    0x5b8(%rsp),%rcx
    5616:	mov    0x18(%rcx),%rax
    561a:	mov    (%rax),%rax
    561d:	cmp    $0xd2,%rax
    5623:	je     5779 <botlish_fn_37+0x2df1>
    5629:	mov    0x648(%rsp),%rax
    5631:	mov    0x18(%rax),%rcx
    5635:	mov    %rax,0x648(%rsp)
    563d:	mov    0x8(%rcx),%rsi
    5641:	mov    %rsi,(%rsp)
    5645:	movq   $0x3,0x10(%rsp)
    564e:	test   $0x1,%rsi
    5655:	je     566d <botlish_fn_37+0x2ce5>
    565b:	mov    %rsi,%rax
    565e:	add    $0x2,%rax
    5662:	seto   %cl
    5665:	test   %cl,%cl
    5667:	je     567f <botlish_fn_37+0x2cf7>
    566d:	mov    $0x3,%edx
    5672:	mov    0x520(%rsp),%rdi
    567a:	call   567f <botlish_fn_37+0x2cf7>
			567b: R_X86_64_PLT32	rt_int_add-0x4
    567f:	mov    %rax,(%rsp)
    5683:	lea    0x270(%rsp),%rcx
    568b:	mov    0x5b8(%rsp),%rdx
    5693:	mov    %rdx,0x270(%rsp)
    569b:	mov    %rax,0x278(%rsp)
    56a3:	mov    $0x3,%esi
    56a8:	mov    $0x2,%edx
    56ad:	mov    0x520(%rsp),%rdi
    56b5:	call   56ba <botlish_fn_37+0x2d32>
			56b6: R_X86_64_PLT32	rt_struct_new-0x4
    56ba:	mov    %rax,%rdx
    56bd:	mov    0x6c8(%rsp),%rsi
    56c5:	mov    0x520(%rsp),%rdi
    56cd:	call   56d2 <botlish_fn_37+0x2d4a>
			56ce: R_X86_64_PLT32	rt_mv_push-0x4
    56d2:	mov    0x5b8(%rsp),%rcx
    56da:	mov    0x18(%rcx),%rax
    56de:	mov    0x18(%rax),%rsi
    56e2:	mov    0x648(%rsp),%rax
    56ea:	mov    0x18(%rax),%rax
    56ee:	mov    0x8(%rax),%rdx
    56f2:	test   $0x1,%rdx
    56f9:	je     5712 <botlish_fn_37+0x2d8a>
    56ff:	mov    0x8(%rsi),%rdi
    5703:	mov    %rdx,%rcx
    5706:	sar    $1,%rcx
    5709:	cmp    %rdi,%rcx
    570c:	jb     5738 <botlish_fn_37+0x2db0>
    5712:	mov    0x520(%rsp),%rdi
    571a:	call   571f <botlish_fn_37+0x2d97>
			571b: R_X86_64_PLT32	rt_list_get-0x4
    571f:	test   %rax,%rax
    5722:	je     7491 <botlish_fn_37+0x4b09>
    5728:	mov    %rax,%rcx
    572b:	mov    0x6c0(%rsp),%rdi
    5733:	jmp    5748 <botlish_fn_37+0x2dc0>
    5738:	mov    0x10(%rsi),%r8
    573c:	mov    (%r8,%rcx,8),%rcx
    5740:	mov    0x6c0(%rsp),%rdi
    5748:	mov    0x18(%rdi),%r9
    574c:	mov    %rdi,0x6c0(%rsp)
    5754:	test   %r9,%r9
    5757:	je     a53d <botlish_fn_37+0x7bb5>
    575d:	mov    0x6c0(%rsp),%rdi
    5765:	mov    0x10(%rdi),%rax
    5769:	mov    %rcx,(%rax)
    576c:	mov    0x6c0(%rsp),%rdi
    5774:	jmp    6f20 <botlish_fn_37+0x4598>
    5779:	mov    0x5b8(%rsp),%rcx
    5781:	mov    0x18(%rcx),%rax
    5785:	mov    0x20(%rax),%rsi
    5789:	mov    0x648(%rsp),%rax
    5791:	mov    0x18(%rax),%rax
    5795:	mov    0x8(%rax),%rdx
    5799:	test   $0x1,%rdx
    57a0:	je     57b9 <botlish_fn_37+0x2e31>
    57a6:	mov    0x8(%rsi),%rcx
    57aa:	mov    %rdx,%rax
    57ad:	sar    $1,%rax
    57b0:	cmp    %rcx,%rax
    57b3:	jb     57e7 <botlish_fn_37+0x2e5f>
    57b9:	mov    0x520(%rsp),%rdi
    57c1:	call   57c6 <botlish_fn_37+0x2e3e>
			57c2: R_X86_64_PLT32	rt_list_get-0x4
    57c6:	mov    %rax,%rcx
    57c9:	mov    %rax,0x5c0(%rsp)
    57d1:	test   %rcx,%rax
    57d4:	je     7491 <botlish_fn_37+0x4b09>
    57da:	mov    0x5c0(%rsp),%rax
    57e2:	jmp    57f7 <botlish_fn_37+0x2e6f>
    57e7:	mov    0x10(%rsi),%rcx
    57eb:	mov    (%rcx,%rax,8),%rax
    57ef:	mov    %rax,0x5c0(%rsp)
    57f7:	mov    %rax,0x108(%rsp)
    57ff:	mov    $0x45,%ecx
    5804:	movq   $0x45,0x28(%rsp)
    580d:	mov    $0x3e,%r15d
    5813:	mov    %rcx,0x660(%rsp)
    581b:	jmp    7548 <botlish_fn_37+0x4bc0>
    5820:	mov    $0xa,%eax
    5825:	jmp    677d <botlish_fn_37+0x3df5>
    582a:	mov    $0xa,%ecx
    582f:	mov    0x5b0(%rsp),%rax
    5837:	jmp    59df <botlish_fn_37+0x3057>
    583c:	mov    $0xa,%ecx
    5841:	mov    0x5b0(%rsp),%rax
    5849:	jmp    59da <botlish_fn_37+0x3052>
    584e:	mov    0x5b0(%rsp),%rax
    5856:	mov    %rax,%rcx
    5859:	and    $0xf,%rcx
    585d:	cmp    $0xa,%rcx
    5861:	jl     5895 <botlish_fn_37+0x2f0d>
    5867:	add    $0x57,%rcx
    586e:	shl    $1,%rcx
    5871:	or     $0x1,%rcx
    5875:	mov    %rcx,0x28(%rsp)
    587a:	mov    $0x3a,%r15d
    5880:	mov    %rax,0x5b0(%rsp)
    5888:	mov    %rcx,0x660(%rsp)
    5890:	jmp    7548 <botlish_fn_37+0x4bc0>
    5895:	add    $0x30,%rcx
    589c:	shl    $1,%rcx
    589f:	or     $0x1,%rcx
    58a3:	mov    %rcx,0x28(%rsp)
    58a8:	mov    $0x39,%r15d
    58ae:	mov    %rax,0x5b0(%rsp)
    58b6:	mov    %rcx,0x660(%rsp)
    58be:	jmp    7548 <botlish_fn_37+0x4bc0>
    58c3:	mov    0x5b0(%rsp),%rax
    58cb:	mov    %rax,%rcx
    58ce:	sar    $0x4,%rcx
    58d2:	cmp    $0xa,%rcx
    58d6:	jl     590a <botlish_fn_37+0x2f82>
    58dc:	add    $0x57,%rcx
    58e3:	shl    $1,%rcx
    58e6:	or     $0x1,%rcx
    58ea:	mov    %rcx,0x28(%rsp)
    58ef:	mov    $0x38,%r15d
    58f5:	mov    %rax,0x5b0(%rsp)
    58fd:	mov    %rcx,0x660(%rsp)
    5905:	jmp    7548 <botlish_fn_37+0x4bc0>
    590a:	add    $0x30,%rcx
    5911:	shl    $1,%rcx
    5914:	or     $0x1,%rcx
    5918:	mov    %rcx,0x28(%rsp)
    591d:	mov    $0x37,%r15d
    5923:	mov    %rax,0x5b0(%rsp)
    592b:	mov    %rcx,0x660(%rsp)
    5933:	jmp    7548 <botlish_fn_37+0x4bc0>
    5938:	mov    0x5b0(%rsp),%rax
    5940:	mov    $0x61,%ecx
    5945:	movq   $0x61,0x28(%rsp)
    594e:	mov    $0x36,%r15d
    5954:	mov    %rcx,0x660(%rsp)
    595c:	jmp    7548 <botlish_fn_37+0x4bc0>
    5961:	mov    0x5b0(%rsp),%rax
    5969:	mov    $0x61,%ecx
    596e:	movq   $0x61,0x28(%rsp)
    5977:	mov    $0x35,%r15d
    597d:	mov    %rcx,0x660(%rsp)
    5985:	jmp    7548 <botlish_fn_37+0x4bc0>
    598a:	mov    0x5b0(%rsp),%rax
    5992:	mov    $0xa,%ecx
    5997:	jmp    59da <botlish_fn_37+0x3052>
    599c:	mov    0x5b0(%rsp),%rax
    59a4:	mov    $0xa,%ecx
    59a9:	jmp    59da <botlish_fn_37+0x3052>
    59ae:	mov    0x5b0(%rsp),%rax
    59b6:	mov    $0xa,%ecx
    59bb:	jmp    59da <botlish_fn_37+0x3052>
    59c0:	mov    0x5b0(%rsp),%rax
    59c8:	mov    $0xa,%ecx
    59cd:	jmp    59da <botlish_fn_37+0x3052>
    59d2:	mov    0x5b0(%rsp),%rax
    59da:	mov    $0xa,%ecx
    59df:	mov    %rax,0x5b0(%rsp)
    59e7:	jmp    5b16 <botlish_fn_37+0x318e>
    59ec:	mov    0x5b0(%rsp),%rax
    59f4:	cmp    $0x8,%rax
    59f8:	je     5aed <botlish_fn_37+0x3165>
    59fe:	cmp    $0x9,%rax
    5a02:	je     5ac2 <botlish_fn_37+0x313a>
    5a08:	cmp    $0xa,%rax
    5a0c:	je     5a99 <botlish_fn_37+0x3111>
    5a12:	cmp    $0xc,%rax
    5a16:	je     5a70 <botlish_fn_37+0x30e8>
    5a1c:	cmp    $0xd,%rax
    5a20:	mov    %rax,0x5b0(%rsp)
    5a28:	je     5a4f <botlish_fn_37+0x30c7>
    5a2e:	mov    $0xeb,%ecx
    5a33:	movq   $0xeb,0x28(%rsp)
    5a3c:	mov    $0x34,%r15d
    5a42:	mov    %rcx,0x660(%rsp)
    5a4a:	jmp    7548 <botlish_fn_37+0x4bc0>
    5a4f:	mov    $0xe5,%ecx
    5a54:	movq   $0xe5,0x28(%rsp)
    5a5d:	mov    $0x33,%r15d
    5a63:	mov    %rcx,0x660(%rsp)
    5a6b:	jmp    7548 <botlish_fn_37+0x4bc0>
    5a70:	mov    %rax,0x5b0(%rsp)
    5a78:	mov    $0xcd,%ecx
    5a7d:	movq   $0xcd,0x28(%rsp)
    5a86:	mov    $0x32,%r15d
    5a8c:	mov    %rcx,0x660(%rsp)
    5a94:	jmp    7548 <botlish_fn_37+0x4bc0>
    5a99:	mov    %rax,0x5b0(%rsp)
    5aa1:	mov    $0xdd,%ecx
    5aa6:	movq   $0xdd,0x28(%rsp)
    5aaf:	mov    $0x31,%r15d
    5ab5:	mov    %rcx,0x660(%rsp)
    5abd:	jmp    7548 <botlish_fn_37+0x4bc0>
    5ac2:	mov    %rax,0x5b0(%rsp)
    5aca:	mov    $0xe9,%ecx
    5acf:	movq   $0xe9,0x28(%rsp)
    5ad8:	mov    0x6a8(%rsp),%r15
    5ae0:	mov    %rcx,0x660(%rsp)
    5ae8:	jmp    7548 <botlish_fn_37+0x4bc0>
    5aed:	mov    %rax,0x5b0(%rsp)
    5af5:	mov    $0xc5,%ecx
    5afa:	movq   $0xc5,0x28(%rsp)
    5b03:	mov    $0x2f,%r15d
    5b09:	mov    %rcx,0x660(%rsp)
    5b11:	jmp    7548 <botlish_fn_37+0x4bc0>
    5b16:	mov    0x638(%rsp),%rsi
    5b1e:	add    $0x1,%rsi
    5b25:	mov    0x5a8(%rsp),%rax
    5b2d:	mov    0x640(%rsp),%rcx
    5b35:	jmp    5b83 <botlish_fn_37+0x31fb>
    5b3a:	mov    0x5a8(%rsp),%rax
    5b42:	mov    0x638(%rsp),%rsi
    5b4a:	mov    %rax,0x28(%rsp)
    5b4f:	mov    $0x2d,%r15d
    5b55:	mov    %rax,0x660(%rsp)
    5b5d:	jmp    7548 <botlish_fn_37+0x4bc0>
    5b62:	mov    0x5a8(%rsp),%rax
    5b6a:	mov    0x5a0(%rsp),%r13
    5b72:	mov    0x8(%r13),%rcx
    5b76:	xor    %rsi,%rsi
    5b79:	shl    $1,%rcx
    5b7c:	or     $0x1,%rcx
    5b80:	sar    $1,%rcx
    5b83:	cmp    %rcx,%rsi
    5b86:	mov    %rcx,0x640(%rsp)
    5b8e:	jl     5bc5 <botlish_fn_37+0x323d>
    5b94:	mov    $0x45,%ecx
    5b99:	movq   $0x45,0x28(%rsp)
    5ba2:	mov    $0x3c,%r15d
    5ba8:	mov    %rax,0x5a8(%rsp)
    5bb0:	mov    %rsi,0x638(%rsp)
    5bb8:	mov    %rcx,0x660(%rsp)
    5bc0:	jmp    7548 <botlish_fn_37+0x4bc0>
    5bc5:	mov    0x5a0(%rsp),%r13
    5bcd:	movzbq 0x18(%r13),%rax
    5bd2:	test   %rax,%rax
    5bd5:	jne    5c07 <botlish_fn_37+0x327f>
    5bdb:	mov    %rsi,%rdx
    5bde:	shl    $1,%rdx
    5be1:	mov    %rsi,0x638(%rsp)
    5be9:	or     $0x1,%rdx
    5bed:	mov    0x5a0(%rsp),%rsi
    5bf5:	mov    0x520(%rsp),%rdi
    5bfd:	call   5c02 <botlish_fn_37+0x327a>
			5bfe: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    5c02:	jmp    5c35 <botlish_fn_37+0x32ad>
    5c07:	mov    %rsi,%rcx
    5c0a:	mov    %rsi,0x638(%rsp)
    5c12:	mov    %rcx,%rax
    5c15:	shl    $1,%rax
    5c18:	or     $0x1,%rax
    5c1c:	sar    $1,%rax
    5c1f:	mov    0x5a0(%rsp),%r13
    5c27:	movzbq 0x19(%r13,%rax,1),%rax
    5c2d:	shl    $0x3,%rax
    5c31:	or     $0x4,%rax
    5c35:	shr    $0x3,%rax
    5c39:	shl    $1,%rax
    5c3c:	or     $0x1,%rax
    5c40:	mov    %rax,0x100(%rsp)
    5c48:	mov    %rax,%rdx
    5c4b:	sar    $1,%rdx
    5c4e:	cmp    $0x22,%rdx
    5c52:	jne    5c65 <botlish_fn_37+0x32dd>
    5c58:	mov    %rax,0x5a8(%rsp)
    5c60:	jmp    5cd7 <botlish_fn_37+0x334f>
    5c65:	cmp    $0x5c,%rdx
    5c69:	jne    5c7c <botlish_fn_37+0x32f4>
    5c6f:	mov    %rax,0x5a8(%rsp)
    5c77:	jmp    5cd7 <botlish_fn_37+0x334f>
    5c7c:	cmp    $0x20,%rdx
    5c80:	jl     5ca6 <botlish_fn_37+0x331e>
    5c86:	mov    %rax,0x28(%rsp)
    5c8b:	mov    %rax,0x5a8(%rsp)
    5c93:	mov    $0x3b,%r15d
    5c99:	mov    %rax,0x660(%rsp)
    5ca1:	jmp    7548 <botlish_fn_37+0x4bc0>
    5ca6:	mov    %rax,0x5a8(%rsp)
    5cae:	mov    $0xb9,%ecx
    5cb3:	movq   $0xb9,0x28(%rsp)
    5cbc:	mov    $0x2e,%r15d
    5cc2:	mov    %rdx,0x5b0(%rsp)
    5cca:	mov    %rcx,0x660(%rsp)
    5cd2:	jmp    7548 <botlish_fn_37+0x4bc0>
    5cd7:	mov    $0xb9,%ecx
    5cdc:	movq   $0xb9,0x28(%rsp)
    5ce5:	mov    $0x2c,%r15d
    5ceb:	mov    %rcx,0x660(%rsp)
    5cf3:	jmp    7548 <botlish_fn_37+0x4bc0>
    5cf8:	movq   $0x1,(%rsp)
    5d00:	mov    0x590(%rsp),%rax
    5d08:	mov    0x598(%rsp),%rcx
    5d10:	mov    %rax,%rdx
    5d13:	and    %rcx,%rdx
    5d16:	test   $0x1,%rdx
    5d1d:	je     5d56 <botlish_fn_37+0x33ce>
    5d23:	mov    0x590(%rsp),%rax
    5d2b:	sar    $1,%rax
    5d2e:	mov    0x598(%rsp),%rcx
    5d36:	lea    -0x1(%rcx),%rsi
    5d3a:	imul   %rsi
    5d3d:	seto   %sil
    5d41:	or     $0x1,%rax
    5d45:	test   %sil,%sil
    5d48:	jne    5d56 <botlish_fn_37+0x33ce>
    5d4e:	mov    %rax,%rdx
    5d51:	jmp    5d76 <botlish_fn_37+0x33ee>
    5d56:	mov    0x598(%rsp),%rdx
    5d5e:	mov    0x590(%rsp),%rsi
    5d66:	mov    0x520(%rsp),%rdi
    5d6e:	call   5d73 <botlish_fn_37+0x33eb>
			5d6f: R_X86_64_PLT32	rt_int_mul-0x4
    5d73:	mov    %rax,%rdx
    5d76:	mov    %rdx,0x10(%rsp)
    5d7b:	mov    0x628(%rsp),%rbx
    5d83:	mov    %rbx,%r9
    5d86:	and    %rdx,%r9
    5d89:	test   $0x1,%r9
    5d90:	je     5dc2 <botlish_fn_37+0x343a>
    5d96:	mov    %rbx,%r11
    5d99:	sub    %rdx,%r11
    5d9c:	seto   %sil
    5da0:	lea    0x1(%r11),%rcx
    5da4:	test   %sil,%sil
    5da7:	jne    5dc2 <botlish_fn_37+0x343a>
    5dad:	mov    0x630(%rsp),%rax
    5db5:	mov    %rbx,0x628(%rsp)
    5dbd:	jmp    5de5 <botlish_fn_37+0x345d>
    5dc2:	mov    %rbx,%rsi
    5dc5:	mov    0x520(%rsp),%rdi
    5dcd:	call   5dd2 <botlish_fn_37+0x344a>
			5dce: R_X86_64_PLT32	rt_int_sub-0x4
    5dd2:	mov    %rbx,0x628(%rsp)
    5dda:	mov    %rax,%rcx
    5ddd:	mov    0x630(%rsp),%rax
    5de5:	mov    0x18(%rax),%rdx
    5de9:	mov    %rax,0x630(%rsp)
    5df1:	test   %rdx,%rdx
    5df4:	je     a55c <botlish_fn_37+0x7bd4>
    5dfa:	mov    0x630(%rsp),%rax
    5e02:	mov    0x10(%rax),%rax
    5e06:	mov    %rcx,(%rax)
    5e09:	jmp    5f2f <botlish_fn_37+0x35a7>
    5e0e:	movq   $0x3,(%rsp)
    5e16:	mov    0x580(%rsp),%rax
    5e1e:	mov    0x588(%rsp),%r9
    5e26:	mov    %rax,%rcx
    5e29:	and    %r9,%rcx
    5e2c:	test   $0x1,%rcx
    5e33:	je     5e6d <botlish_fn_37+0x34e5>
    5e39:	mov    0x580(%rsp),%rax
    5e41:	sar    $1,%rax
    5e44:	mov    0x588(%rsp),%rcx
    5e4c:	add    $0xffffffffffffffff,%rcx
    5e53:	imul   %rcx
    5e56:	seto   %cl
    5e59:	or     $0x1,%rax
    5e5d:	test   %cl,%cl
    5e5f:	jne    5e6d <botlish_fn_37+0x34e5>
    5e65:	mov    %rax,%rdx
    5e68:	jmp    5e8d <botlish_fn_37+0x3505>
    5e6d:	mov    0x588(%rsp),%rdx
    5e75:	mov    0x580(%rsp),%rsi
    5e7d:	mov    0x520(%rsp),%rdi
    5e85:	call   5e8a <botlish_fn_37+0x3502>
			5e86: R_X86_64_PLT32	rt_int_mul-0x4
    5e8a:	mov    %rax,%rdx
    5e8d:	mov    %rdx,0x10(%rsp)
    5e92:	mov    0x618(%rsp),%rbx
    5e9a:	mov    %rbx,%rax
    5e9d:	and    %rdx,%rax
    5ea0:	test   $0x1,%rax
    5ea6:	je     5ed9 <botlish_fn_37+0x3551>
    5eac:	mov    %rbx,%rsi
    5eaf:	sub    %rdx,%rsi
    5eb2:	mov    %rdx,%rax
    5eb5:	seto   %cl
    5eb8:	lea    0x1(%rsi),%rdx
    5ebc:	test   %cl,%cl
    5ebe:	je     5ecc <botlish_fn_37+0x3544>
    5ec4:	mov    %rax,%rdx
    5ec7:	jmp    5ed9 <botlish_fn_37+0x3551>
    5ecc:	mov    %rbx,0x618(%rsp)
    5ed4:	jmp    5ef4 <botlish_fn_37+0x356c>
    5ed9:	mov    %rbx,%rsi
    5edc:	mov    0x520(%rsp),%rdi
    5ee4:	call   5ee9 <botlish_fn_37+0x3561>
			5ee5: R_X86_64_PLT32	rt_int_sub-0x4
    5ee9:	mov    %rbx,0x618(%rsp)
    5ef1:	mov    %rax,%rdx
    5ef4:	mov    %rdx,0x10(%rsp)
    5ef9:	mov    $0x3,%esi
    5efe:	mov    0x520(%rsp),%rdi
    5f06:	call   5f0b <botlish_fn_37+0x3583>
			5f07: R_X86_64_PLT32	rt_mutarray_create-0x4
    5f0b:	mov    %rax,%rcx
    5f0e:	mov    %rax,0x630(%rsp)
    5f16:	test   %rcx,%rax
    5f19:	je     7491 <botlish_fn_37+0x4b09>
    5f1f:	mov    0x630(%rsp),%rax
    5f27:	mov    %rax,0xd8(%rsp)
    5f2f:	mov    0x620(%rsp),%rsi
    5f37:	mov    0x520(%rsp),%rdi
    5f3f:	call   5f44 <botlish_fn_37+0x35bc>
			5f40: R_X86_64_PLT32	rt_mv_empty-0x4
    5f44:	cmp    $0x6,%rax
    5f48:	je     5ff9 <botlish_fn_37+0x3671>
    5f4e:	mov    0x620(%rsp),%rsi
    5f56:	mov    0x520(%rsp),%rdi
    5f5e:	call   5f63 <botlish_fn_37+0x35db>
			5f5f: R_X86_64_PLT32	rt_mv_pop-0x4
    5f63:	mov    %rax,%rcx
    5f66:	mov    %rax,0x598(%rsp)
    5f6e:	test   %rcx,%rax
    5f71:	je     7491 <botlish_fn_37+0x4b09>
    5f77:	mov    0x598(%rsp),%rax
    5f7f:	mov    %rax,0xe0(%rsp)
    5f87:	mov    0x630(%rsp),%rax
    5f8f:	mov    0x10(%rax),%rax
    5f93:	mov    (%rax),%rcx
    5f96:	mov    %rcx,0x628(%rsp)
    5f9e:	mov    %rcx,0xe8(%rsp)
    5fa6:	mov    0x598(%rsp),%rdx
    5fae:	mov    0x628(%rsp),%rsi
    5fb6:	mov    0x520(%rsp),%rdi
    5fbe:	call   5fc3 <botlish_fn_37+0x363b>
			5fbf: R_X86_64_PLT32	botlish_fn_14-0x4
    5fc3:	mov    %rax,0x590(%rsp)
    5fcb:	mov    %rax,0xf0(%rsp)
    5fd3:	sar    $1,%rax
    5fd6:	lea    0x30(%rax),%rcx
    5fda:	shl    $1,%rcx
    5fdd:	or     $0x1,%rcx
    5fe1:	mov    %rcx,0x28(%rsp)
    5fe6:	mov    $0x2a,%r15d
    5fec:	mov    %rcx,0x660(%rsp)
    5ff4:	jmp    7548 <botlish_fn_37+0x4bc0>
    5ff9:	mov    $0xa,%eax
    5ffe:	jmp    6615 <botlish_fn_37+0x3c8d>
    6003:	movq   $0x1,(%rsp)
    600b:	mov    0x570(%rsp),%rax
    6013:	mov    0x578(%rsp),%rcx
    601b:	mov    %rax,%rdx
    601e:	and    %rcx,%rdx
    6021:	test   $0x1,%rdx
    6028:	je     6062 <botlish_fn_37+0x36da>
    602e:	mov    0x570(%rsp),%rax
    6036:	sar    $1,%rax
    6039:	mov    0x578(%rsp),%rcx
    6041:	add    $0xffffffffffffffff,%rcx
    6048:	imul   %rcx
    604b:	seto   %dl
    604e:	or     $0x1,%rax
    6052:	test   %dl,%dl
    6054:	jne    6062 <botlish_fn_37+0x36da>
    605a:	mov    %rax,%rdx
    605d:	jmp    6082 <botlish_fn_37+0x36fa>
    6062:	mov    0x578(%rsp),%rdx
    606a:	mov    0x570(%rsp),%rsi
    6072:	mov    0x520(%rsp),%rdi
    607a:	call   607f <botlish_fn_37+0x36f7>
			607b: R_X86_64_PLT32	rt_int_mul-0x4
    607f:	mov    %rax,%rdx
    6082:	mov    %rdx,0x10(%rsp)
    6087:	mov    0x608(%rsp),%rbx
    608f:	mov    %rbx,%rsi
    6092:	and    %rdx,%rsi
    6095:	test   $0x1,%rsi
    609c:	je     60ce <botlish_fn_37+0x3746>
    60a2:	mov    %rbx,%r8
    60a5:	sub    %rdx,%r8
    60a8:	seto   %r10b
    60ac:	lea    0x1(%r8),%rcx
    60b0:	test   %r10b,%r10b
    60b3:	jne    60ce <botlish_fn_37+0x3746>
    60b9:	mov    0x610(%rsp),%rax
    60c1:	mov    %rbx,0x608(%rsp)
    60c9:	jmp    60f1 <botlish_fn_37+0x3769>
    60ce:	mov    %rbx,%rsi
    60d1:	mov    0x520(%rsp),%rdi
    60d9:	call   60de <botlish_fn_37+0x3756>
			60da: R_X86_64_PLT32	rt_int_sub-0x4
    60de:	mov    %rbx,0x608(%rsp)
    60e6:	mov    %rax,%rcx
    60e9:	mov    0x610(%rsp),%rax
    60f1:	mov    0x18(%rax),%rdx
    60f5:	mov    %rax,0x610(%rsp)
    60fd:	test   %rdx,%rdx
    6100:	je     a57b <botlish_fn_37+0x7bf3>
    6106:	mov    0x610(%rsp),%rax
    610e:	mov    0x10(%rax),%rax
    6112:	mov    %rcx,(%rax)
    6115:	jmp    6230 <botlish_fn_37+0x38a8>
    611a:	movq   $0x3,(%rsp)
    6122:	mov    0x568(%rsp),%rbx
    612a:	mov    0x560(%rsp),%r12
    6132:	mov    %r12,%rax
    6135:	and    %rbx,%rax
    6138:	test   $0x1,%rax
    613e:	je     6178 <botlish_fn_37+0x37f0>
    6144:	mov    %r12,%rax
    6147:	sar    $1,%rax
    614a:	lea    -0x1(%rbx),%rcx
    614e:	imul   %rcx
    6151:	seto   %cl
    6154:	or     $0x1,%rax
    6158:	test   %cl,%cl
    615a:	jne    6178 <botlish_fn_37+0x37f0>
    6160:	mov    %rax,%rdx
    6163:	mov    %r12,0x560(%rsp)
    616b:	mov    %rbx,0x568(%rsp)
    6173:	jmp    619e <botlish_fn_37+0x3816>
    6178:	mov    %rbx,%rdx
    617b:	mov    %r12,%rsi
    617e:	mov    0x520(%rsp),%rdi
    6186:	call   618b <botlish_fn_37+0x3803>
			6187: R_X86_64_PLT32	rt_int_mul-0x4
    618b:	mov    %r12,0x560(%rsp)
    6193:	mov    %rbx,0x568(%rsp)
    619b:	mov    %rax,%rdx
    619e:	mov    %rdx,0x10(%rsp)
    61a3:	mov    0x5f8(%rsp),%rax
    61ab:	and    %rdx,%rax
    61ae:	test   $0x1,%rax
    61b4:	je     61dd <botlish_fn_37+0x3855>
    61ba:	mov    0x5f8(%rsp),%rax
    61c2:	mov    %rax,%rcx
    61c5:	sub    %rdx,%rcx
    61c8:	mov    %rdx,%rsi
    61cb:	seto   %al
    61ce:	lea    0x1(%rcx),%rdx
    61d2:	test   %al,%al
    61d4:	je     61f5 <botlish_fn_37+0x386d>
    61da:	mov    %rsi,%rdx
    61dd:	mov    0x5f8(%rsp),%rsi
    61e5:	mov    0x520(%rsp),%rdi
    61ed:	call   61f2 <botlish_fn_37+0x386a>
			61ee: R_X86_64_PLT32	rt_int_sub-0x4
    61f2:	mov    %rax,%rdx
    61f5:	mov    %rdx,0x10(%rsp)
    61fa:	mov    $0x3,%esi
    61ff:	mov    0x520(%rsp),%rdi
    6207:	call   620c <botlish_fn_37+0x3884>
			6208: R_X86_64_PLT32	rt_mutarray_create-0x4
    620c:	mov    %rax,%rcx
    620f:	mov    %rax,0x610(%rsp)
    6217:	test   %rcx,%rax
    621a:	je     7491 <botlish_fn_37+0x4b09>
    6220:	mov    0x610(%rsp),%rax
    6228:	mov    %rax,0x98(%rsp)
    6230:	mov    0x600(%rsp),%rsi
    6238:	mov    0x520(%rsp),%rdi
    6240:	call   6245 <botlish_fn_37+0x38bd>
			6241: R_X86_64_PLT32	rt_mv_empty-0x4
    6245:	cmp    $0x6,%rax
    6249:	je     62fa <botlish_fn_37+0x3972>
    624f:	mov    0x600(%rsp),%rsi
    6257:	mov    0x520(%rsp),%rdi
    625f:	call   6264 <botlish_fn_37+0x38dc>
			6260: R_X86_64_PLT32	rt_mv_pop-0x4
    6264:	mov    %rax,%rcx
    6267:	mov    %rax,0x578(%rsp)
    626f:	test   %rcx,%rax
    6272:	je     7491 <botlish_fn_37+0x4b09>
    6278:	mov    0x578(%rsp),%rax
    6280:	mov    %rax,0xa0(%rsp)
    6288:	mov    0x610(%rsp),%rax
    6290:	mov    0x10(%rax),%rax
    6294:	mov    (%rax),%rcx
    6297:	mov    %rcx,0x608(%rsp)
    629f:	mov    %rcx,0xa8(%rsp)
    62a7:	mov    0x578(%rsp),%rdx
    62af:	mov    0x608(%rsp),%rsi
    62b7:	mov    0x520(%rsp),%rdi
    62bf:	call   62c4 <botlish_fn_37+0x393c>
			62c0: R_X86_64_PLT32	botlish_fn_14-0x4
    62c4:	mov    %rax,0x570(%rsp)
    62cc:	mov    %rax,0xb0(%rsp)
    62d4:	sar    $1,%rax
    62d7:	lea    0x30(%rax),%rcx
    62db:	shl    $1,%rcx
    62de:	or     $0x1,%rcx
    62e2:	mov    %rcx,0x28(%rsp)
    62e7:	mov    %rcx,0x660(%rsp)
    62ef:	mov    $0x28,%r15d
    62f5:	jmp    7548 <botlish_fn_37+0x4bc0>
    62fa:	mov    $0xa,%eax
    62ff:	jmp    6615 <botlish_fn_37+0x3c8d>
    6304:	movq   $0x1,(%rsp)
    630c:	mov    0x558(%rsp),%rcx
    6314:	test   $0x1,%rcx
    631b:	je     6358 <botlish_fn_37+0x39d0>
    6321:	mov    $0x1,%eax
    6326:	mov    0x558(%rsp),%rcx
    632e:	sub    %rcx,%rax
    6331:	seto   %cl
    6334:	add    $0x1,%rax
    633b:	mov    %rax,0x5f8(%rsp)
    6343:	test   %cl,%cl
    6345:	jne    6358 <botlish_fn_37+0x39d0>
    634b:	mov    0x5f8(%rsp),%rax
    6353:	jmp    637a <botlish_fn_37+0x39f2>
    6358:	mov    $0x1,%esi
    635d:	mov    0x558(%rsp),%rdx
    6365:	mov    0x520(%rsp),%rdi
    636d:	call   6372 <botlish_fn_37+0x39ea>
			636e: R_X86_64_PLT32	rt_int_sub-0x4
    6372:	mov    %rax,0x5f8(%rsp)
    637a:	mov    %rax,0x78(%rsp)
    637f:	movq   $0x3,(%rsp)
    6387:	lea    0x260(%rsp),%rdx
    638f:	movq   $0x3,0x260(%rsp)
    639b:	mov    $0x1,%esi
    63a0:	mov    0x520(%rsp),%rdi
    63a8:	call   63ad <botlish_fn_37+0x3a25>
			63a9: R_X86_64_PLT32	rt_list_new-0x4
    63ad:	test   %rax,%rax
    63b0:	je     7491 <botlish_fn_37+0x4b09>
    63b6:	mov    %rax,(%rsp)
    63ba:	mov    %rax,%rsi
    63bd:	mov    0x520(%rsp),%rdi
    63c5:	call   63ca <botlish_fn_37+0x3a42>
			63c6: R_X86_64_PLT32	rt_mv_from_list-0x4
    63ca:	mov    %rax,0x600(%rsp)
    63d2:	mov    %rax,0x80(%rsp)
    63da:	mov    0x600(%rsp),%rsi
    63e2:	mov    0x520(%rsp),%rdi
    63ea:	call   63ef <botlish_fn_37+0x3a67>
			63eb: R_X86_64_PLT32	rt_mv_len-0x4
    63ef:	sar    $1,%rax
    63f2:	sub    $0x1,%rax
    63f6:	shl    $1,%rax
    63f9:	mov    %rax,%rdx
    63fc:	or     $0x1,%rdx
    6400:	mov    0x600(%rsp),%rsi
    6408:	mov    0x520(%rsp),%rdi
    6410:	call   6415 <botlish_fn_37+0x3a8d>
			6411: R_X86_64_PLT32	rt_mv_at-0x4
    6415:	mov    %rax,%rdx
    6418:	mov    %rax,%rsi
    641b:	test   %rdx,%rax
    641e:	je     7491 <botlish_fn_37+0x4b09>
    6424:	mov    %rsi,%rax
    6427:	mov    %rax,(%rsp)
    642b:	movq   $0x15,0x10(%rsp)
    6434:	test   $0x1,%rax
    643a:	jne    6448 <botlish_fn_37+0x3ac0>
    6440:	mov    %rsi,%r13
    6443:	jmp    647f <botlish_fn_37+0x3af7>
    6448:	mov    %rsi,%rax
    644b:	sar    $1,%rax
    644e:	imulq  0x4193(%rip)        # a5e8 <botlish_fn_37+0x7c60>
    6455:	seto   %cl
    6458:	or     $0x1,%rax
    645c:	test   %cl,%cl
    645e:	je     646c <botlish_fn_37+0x3ae4>
    6464:	mov    %rsi,%r13
    6467:	jmp    647f <botlish_fn_37+0x3af7>
    646c:	mov    %rsi,%r13
    646f:	mov    %rax,%rsi
    6472:	mov    0x5f8(%rsp),%rax
    647a:	jmp    649d <botlish_fn_37+0x3b15>
    647f:	mov    %r12,%rdx
    6482:	mov    %r13,%rsi
    6485:	mov    0x520(%rsp),%rdi
    648d:	call   6492 <botlish_fn_37+0x3b0a>
			648e: R_X86_64_PLT32	rt_int_mul-0x4
    6492:	mov    %rax,%rsi
    6495:	mov    0x5f8(%rsp),%rax
    649d:	mov    0x5f8(%rsp),%rax
    64a5:	mov    %rsi,%rcx
    64a8:	and    %rax,%rcx
    64ab:	test   $0x1,%rcx
    64b2:	jne    64e2 <botlish_fn_37+0x3b5a>
    64b8:	mov    0x5f8(%rsp),%rdx
    64c0:	mov    0x520(%rsp),%rdi
    64c8:	call   64cd <botlish_fn_37+0x3b45>
			64c9: R_X86_64_PLT32	rt_int_cmp-0x4
    64cd:	mov    $0x2,%esi
    64d2:	test   %rax,%rax
    64d5:	cmovg  0x4103(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    64dd:	jmp    64fd <botlish_fn_37+0x3b75>
    64e2:	mov    %rsi,%rax
    64e5:	mov    $0x2,%esi
    64ea:	mov    0x5f8(%rsp),%rcx
    64f2:	cmp    %rcx,%rax
    64f5:	cmovg  0x40e3(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    64fd:	cmp    $0x6,%rsi
    6501:	je     6579 <botlish_fn_37+0x3bf1>
    6507:	movq   $0x15,0x10(%rsp)
    6510:	test   $0x1,%r13
    6517:	jne    6525 <botlish_fn_37+0x3b9d>
    651d:	mov    %r13,%rsi
    6520:	jmp    654c <botlish_fn_37+0x3bc4>
    6525:	mov    %r13,%rax
    6528:	sar    $1,%rax
    652b:	mov    %r13,%rsi
    652e:	imulq  0x40b3(%rip)        # a5e8 <botlish_fn_37+0x7c60>
    6535:	seto   %cl
    6538:	or     $0x1,%rax
    653c:	test   %cl,%cl
    653e:	jne    654c <botlish_fn_37+0x3bc4>
    6544:	mov    %rax,%rdx
    6547:	jmp    655f <botlish_fn_37+0x3bd7>
    654c:	mov    %r12,%rdx
    654f:	mov    0x520(%rsp),%rdi
    6557:	call   655c <botlish_fn_37+0x3bd4>
			6558: R_X86_64_PLT32	rt_int_mul-0x4
    655c:	mov    %rax,%rdx
    655f:	mov    0x600(%rsp),%rsi
    6567:	mov    0x520(%rsp),%rdi
    656f:	call   6574 <botlish_fn_37+0x3bec>
			6570: R_X86_64_PLT32	rt_mv_push-0x4
    6574:	jmp    63da <botlish_fn_37+0x3a52>
    6579:	mov    0x600(%rsp),%rsi
    6581:	mov    0x520(%rsp),%rdi
    6589:	call   658e <botlish_fn_37+0x3c06>
			658a: R_X86_64_PLT32	rt_mv_pop-0x4
    658e:	mov    %rax,%rcx
    6591:	mov    %rax,0x568(%rsp)
    6599:	test   %rcx,%rax
    659c:	je     7491 <botlish_fn_37+0x4b09>
    65a2:	mov    0x568(%rsp),%rax
    65aa:	mov    %rax,0x88(%rsp)
    65b2:	mov    0x568(%rsp),%rdx
    65ba:	mov    0x5f8(%rsp),%rsi
    65c2:	mov    0x520(%rsp),%rdi
    65ca:	call   65cf <botlish_fn_37+0x3c47>
			65cb: R_X86_64_PLT32	botlish_fn_15-0x4
    65cf:	mov    %rax,0x560(%rsp)
    65d7:	mov    %rax,0x90(%rsp)
    65df:	sar    $1,%rax
    65e2:	lea    0x30(%rax),%rcx
    65e6:	mov    %rcx,0x660(%rsp)
    65ee:	shl    $1,%rcx
    65f1:	mov    %rcx,0x660(%rsp)
    65f9:	or     $0x1,%rcx
    65fd:	mov    %rcx,0x660(%rsp)
    6605:	mov    %rcx,0x28(%rsp)
    660a:	mov    $0x27,%r15d
    6610:	jmp    7548 <botlish_fn_37+0x4bc0>
    6615:	mov    $0xa,%eax
    661a:	jmp    677d <botlish_fn_37+0x3df5>
    661f:	mov    $0xa,%eax
    6624:	jmp    677d <botlish_fn_37+0x3df5>
    6629:	mov    $0xcb,%ecx
    662e:	mov    %rcx,0x660(%rsp)
    6636:	movq   $0xcb,0x28(%rsp)
    663f:	mov    $0x24,%r15d
    6645:	jmp    7548 <botlish_fn_37+0x4bc0>
    664a:	mov    $0xe7,%ecx
    664f:	mov    %rcx,0x660(%rsp)
    6657:	movq   $0xe7,0x28(%rsp)
    6660:	mov    $0x23,%r15d
    6666:	jmp    7548 <botlish_fn_37+0x4bc0>
    666b:	mov    $0xd9,%ecx
    6670:	mov    %rcx,0x660(%rsp)
    6678:	movq   $0xd9,0x28(%rsp)
    6681:	mov    $0x22,%r15d
    6687:	jmp    7548 <botlish_fn_37+0x4bc0>
    668c:	mov    $0xc3,%ecx
    6691:	mov    %rcx,0x660(%rsp)
    6699:	movq   $0xc3,0x28(%rsp)
    66a2:	mov    $0x21,%r15d
    66a8:	jmp    7548 <botlish_fn_37+0x4bc0>
    66ad:	mov    $0xa,%eax
    66b2:	jmp    677d <botlish_fn_37+0x3df5>
    66b7:	mov    $0xcb,%ecx
    66bc:	mov    %rcx,0x660(%rsp)
    66c4:	movq   $0xcb,0x28(%rsp)
    66cd:	mov    $0x1f,%r15d
    66d3:	jmp    7548 <botlish_fn_37+0x4bc0>
    66d8:	mov    $0xeb,%ecx
    66dd:	mov    %rcx,0x660(%rsp)
    66e5:	movq   $0xeb,0x28(%rsp)
    66ee:	mov    $0x1e,%r15d
    66f4:	jmp    7548 <botlish_fn_37+0x4bc0>
    66f9:	mov    $0xe5,%ecx
    66fe:	mov    %rcx,0x660(%rsp)
    6706:	movq   $0xe5,0x28(%rsp)
    670f:	mov    $0x1d,%r15d
    6715:	jmp    7548 <botlish_fn_37+0x4bc0>
    671a:	mov    $0xd9,%ecx
    671f:	mov    %rcx,0x660(%rsp)
    6727:	movq   $0xd9,0x28(%rsp)
    6730:	mov    $0x1b,%r15d
    6736:	jmp    7548 <botlish_fn_37+0x4bc0>
    673b:	mov    $0xd9,%ecx
    6740:	mov    %rcx,0x660(%rsp)
    6748:	movq   $0xd9,0x28(%rsp)
    6751:	mov    $0x1a,%r15d
    6757:	jmp    7548 <botlish_fn_37+0x4bc0>
    675c:	mov    $0xeb,%ecx
    6761:	mov    %rcx,0x660(%rsp)
    6769:	movq   $0xeb,0x28(%rsp)
    6772:	mov    $0x19,%r15d
    6778:	jmp    7548 <botlish_fn_37+0x4bc0>
    677d:	mov    0x6c8(%rsp),%rsi
    6785:	mov    0x520(%rsp),%rdi
    678d:	call   6792 <botlish_fn_37+0x3e0a>
			678e: R_X86_64_PLT32	rt_mv_empty-0x4
    6792:	cmp    $0x6,%rax
    6796:	je     68e1 <botlish_fn_37+0x3f59>
    679c:	mov    0x6c8(%rsp),%rsi
    67a4:	mov    0x520(%rsp),%rdi
    67ac:	call   67b1 <botlish_fn_37+0x3e29>
			67ad: R_X86_64_PLT32	rt_mv_pop-0x4
    67b1:	mov    %rax,%rcx
    67b4:	mov    %rax,0x648(%rsp)
    67bc:	test   %rcx,%rax
    67bf:	je     7491 <botlish_fn_37+0x4b09>
    67c5:	mov    0x648(%rsp),%rax
    67cd:	mov    %rax,0x50(%rsp)
    67d2:	mov    0x18(%rax),%rax
    67d6:	mov    (%rax),%rcx
    67d9:	mov    %rcx,0x5b8(%rsp)
    67e1:	mov    %rcx,0x58(%rsp)
    67e6:	mov    0x648(%rsp),%rax
    67ee:	mov    0x18(%rax),%rax
    67f2:	mov    0x8(%rax),%rsi
    67f6:	mov    %rsi,%rbx
    67f9:	mov    0x5b8(%rsp),%rsi
    6801:	mov    0x520(%rsp),%rdi
    6809:	call   680e <botlish_fn_37+0x3e86>
			680a: R_X86_64_PLT32	botlish_fn_32-0x4
    680e:	mov    %rbx,%rsi
    6811:	mov    %rsi,%rcx
    6814:	and    %rax,%rcx
    6817:	mov    %rax,%rdx
    681a:	test   $0x1,%rcx
    6821:	jne    6849 <botlish_fn_37+0x3ec1>
    6827:	mov    0x520(%rsp),%rdi
    682f:	call   6834 <botlish_fn_37+0x3eac>
			6830: R_X86_64_PLT32	rt_int_cmp-0x4
    6834:	mov    $0x2,%ecx
    6839:	test   %rax,%rax
    683c:	cmovl  0x3d9c(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    6844:	jmp    6859 <botlish_fn_37+0x3ed1>
    6849:	mov    $0x2,%ecx
    684e:	cmp    %rdx,%rsi
    6851:	cmovl  0x3d87(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    6859:	cmp    $0x6,%rcx
    685d:	je     68c0 <botlish_fn_37+0x3f38>
    6863:	mov    0x5b8(%rsp),%rcx
    686b:	mov    0x18(%rcx),%rax
    686f:	mov    (%rax),%rax
    6872:	cmp    $0xb2,%rax
    6878:	je     689f <botlish_fn_37+0x3f17>
    687e:	mov    $0xfb,%ecx
    6883:	mov    %rcx,0x660(%rsp)
    688b:	movq   $0xfb,0x28(%rsp)
    6894:	mov    $0x52,%r15d
    689a:	jmp    7548 <botlish_fn_37+0x4bc0>
    689f:	mov    $0xbb,%ecx
    68a4:	mov    %rcx,0x660(%rsp)
    68ac:	movq   $0xbb,0x28(%rsp)
    68b5:	mov    $0x51,%r15d
    68bb:	jmp    7548 <botlish_fn_37+0x4bc0>
    68c0:	mov    $0x59,%ecx
    68c5:	mov    %rcx,0x660(%rsp)
    68cd:	movq   $0x59,0x28(%rsp)
    68d6:	mov    $0x3d,%r15d
    68dc:	jmp    7548 <botlish_fn_37+0x4bc0>
    68e1:	mov    $0xffffffffffffffff,%rcx
    68e8:	mov    %rcx,0x660(%rsp)
    68f0:	movq   $0xffffffffffffffff,0x28(%rsp)
    68f9:	mov    0x660(%rsp),%r15
    6901:	jmp    7548 <botlish_fn_37+0x4bc0>
    6906:	mov    $0x75,%ecx
    690b:	mov    %rcx,0x660(%rsp)
    6913:	movq   $0x75,0x28(%rsp)
    691c:	mov    $0x15,%r15d
    6922:	jmp    7548 <botlish_fn_37+0x4bc0>
    6927:	mov    $0xa,%eax
    692c:	jmp    6bca <botlish_fn_37+0x4242>
    6931:	mov    $0xa,%eax
    6936:	jmp    6aa0 <botlish_fn_37+0x4118>
    693b:	mov    0x550(%rsp),%rcx
    6943:	mov    %rcx,%rsi
    6946:	and    $0xf,%rsi
    694a:	cmp    $0xa,%rsi
    694e:	jl     6987 <botlish_fn_37+0x3fff>
    6954:	lea    0x57(%rsi),%rcx
    6958:	mov    %rcx,0x660(%rsp)
    6960:	shl    $1,%rcx
    6963:	mov    %rcx,0x660(%rsp)
    696b:	or     $0x1,%rcx
    696f:	mov    %rcx,0x660(%rsp)
    6977:	mov    %rcx,0x28(%rsp)
    697c:	mov    $0x12,%r15d
    6982:	jmp    7548 <botlish_fn_37+0x4bc0>
    6987:	lea    0x30(%rsi),%rcx
    698b:	mov    %rcx,0x660(%rsp)
    6993:	shl    $1,%rcx
    6996:	mov    %rcx,0x660(%rsp)
    699e:	or     $0x1,%rcx
    69a2:	mov    %rcx,0x660(%rsp)
    69aa:	mov    %rcx,0x28(%rsp)
    69af:	mov    $0x11,%r15d
    69b5:	jmp    7548 <botlish_fn_37+0x4bc0>
    69ba:	mov    0x550(%rsp),%rcx
    69c2:	mov    %rcx,%rax
    69c5:	sar    $0x4,%rax
    69c9:	cmp    $0xa,%rax
    69cd:	jl     6a08 <botlish_fn_37+0x4080>
    69d3:	lea    0x57(%rax),%rcx
    69d7:	mov    %rcx,0x660(%rsp)
    69df:	shl    $1,%rcx
    69e2:	mov    %rcx,0x660(%rsp)
    69ea:	or     $0x1,%rcx
    69ee:	mov    %rcx,0x660(%rsp)
    69f6:	mov    %rcx,0x28(%rsp)
    69fb:	mov    0x698(%rsp),%r15
    6a03:	jmp    7548 <botlish_fn_37+0x4bc0>
    6a08:	lea    0x30(%rax),%rcx
    6a0c:	mov    %rcx,0x660(%rsp)
    6a14:	shl    $1,%rcx
    6a17:	mov    %rcx,0x660(%rsp)
    6a1f:	or     $0x1,%rcx
    6a23:	mov    %rcx,0x660(%rsp)
    6a2b:	mov    %rcx,0x28(%rsp)
    6a30:	mov    $0xf,%r15d
    6a36:	jmp    7548 <botlish_fn_37+0x4bc0>
    6a3b:	mov    $0x61,%ecx
    6a40:	mov    %rcx,0x660(%rsp)
    6a48:	movq   $0x61,0x28(%rsp)
    6a51:	mov    $0xe,%r15d
    6a57:	jmp    7548 <botlish_fn_37+0x4bc0>
    6a5c:	mov    $0x61,%ecx
    6a61:	mov    %rcx,0x660(%rsp)
    6a69:	movq   $0x61,0x28(%rsp)
    6a72:	mov    $0xd,%r15d
    6a78:	jmp    7548 <botlish_fn_37+0x4bc0>
    6a7d:	mov    $0xa,%eax
    6a82:	jmp    6aa0 <botlish_fn_37+0x4118>
    6a87:	mov    $0xa,%eax
    6a8c:	jmp    6aa0 <botlish_fn_37+0x4118>
    6a91:	mov    $0xa,%eax
    6a96:	jmp    6aa0 <botlish_fn_37+0x4118>
    6a9b:	mov    $0xa,%eax
    6aa0:	mov    $0xa,%eax
    6aa5:	jmp    6bca <botlish_fn_37+0x4242>
    6aaa:	mov    0x550(%rsp),%rcx
    6ab2:	cmp    $0x8,%rcx
    6ab6:	je     6ba9 <botlish_fn_37+0x4221>
    6abc:	mov    0x550(%rsp),%rcx
    6ac4:	cmp    $0x9,%rcx
    6ac8:	je     6b88 <botlish_fn_37+0x4200>
    6ace:	mov    0x550(%rsp),%rcx
    6ad6:	cmp    $0xa,%rcx
    6ada:	je     6b67 <botlish_fn_37+0x41df>
    6ae0:	mov    $0xc,%r15d
    6ae6:	mov    0x550(%rsp),%rcx
    6aee:	cmp    $0xc,%rcx
    6af2:	je     6b46 <botlish_fn_37+0x41be>
    6af8:	mov    0x550(%rsp),%rcx
    6b00:	cmp    $0xd,%rcx
    6b04:	je     6b25 <botlish_fn_37+0x419d>
    6b0a:	mov    $0xeb,%ecx
    6b0f:	mov    %rcx,0x660(%rsp)
    6b17:	movq   $0xeb,0x28(%rsp)
    6b20:	jmp    7548 <botlish_fn_37+0x4bc0>
    6b25:	mov    $0xe5,%ecx
    6b2a:	mov    %rcx,0x660(%rsp)
    6b32:	movq   $0xe5,0x28(%rsp)
    6b3b:	mov    $0xb,%r15d
    6b41:	jmp    7548 <botlish_fn_37+0x4bc0>
    6b46:	mov    $0xcd,%ecx
    6b4b:	mov    %rcx,0x660(%rsp)
    6b53:	movq   $0xcd,0x28(%rsp)
    6b5c:	mov    $0xa,%r15d
    6b62:	jmp    7548 <botlish_fn_37+0x4bc0>
    6b67:	mov    $0xdd,%ecx
    6b6c:	mov    %rcx,0x660(%rsp)
    6b74:	movq   $0xdd,0x28(%rsp)
    6b7d:	mov    $0x9,%r15d
    6b83:	jmp    7548 <botlish_fn_37+0x4bc0>
    6b88:	mov    $0xe9,%ecx
    6b8d:	mov    %rcx,0x660(%rsp)
    6b95:	movq   $0xe9,0x28(%rsp)
    6b9e:	mov    $0x8,%r15d
    6ba4:	jmp    7548 <botlish_fn_37+0x4bc0>
    6ba9:	mov    $0xc5,%ecx
    6bae:	mov    %rcx,0x660(%rsp)
    6bb6:	movq   $0xc5,0x28(%rsp)
    6bbf:	mov    $0x7,%r15d
    6bc5:	jmp    7548 <botlish_fn_37+0x4bc0>
    6bca:	mov    0x5e8(%rsp),%rcx
    6bd2:	add    $0x1,%rcx
    6bd9:	mov    0x548(%rsp),%rax
    6be1:	mov    0x5f0(%rsp),%rdx
    6be9:	jmp    6c37 <botlish_fn_37+0x42af>
    6bee:	mov    0x548(%rsp),%rax
    6bf6:	mov    0x5e8(%rsp),%rcx
    6bfe:	mov    %rax,0x28(%rsp)
    6c03:	mov    $0x5,%r15d
    6c09:	mov    %rax,0x660(%rsp)
    6c11:	jmp    7548 <botlish_fn_37+0x4bc0>
    6c16:	mov    0x548(%rsp),%rax
    6c1e:	mov    0x540(%rsp),%rcx
    6c26:	mov    0x8(%rcx),%rdx
    6c2a:	xor    %rcx,%rcx
    6c2d:	shl    $1,%rdx
    6c30:	or     $0x1,%rdx
    6c34:	sar    $1,%rdx
    6c37:	cmp    %rdx,%rcx
    6c3a:	mov    %rdx,0x5f0(%rsp)
    6c42:	jl     6c79 <botlish_fn_37+0x42f1>
    6c48:	mov    $0x45,%edx
    6c4d:	mov    %rdx,0x660(%rsp)
    6c55:	movq   $0x45,0x28(%rsp)
    6c5e:	mov    $0x14,%r15d
    6c64:	mov    %rax,0x548(%rsp)
    6c6c:	mov    %rcx,0x5e8(%rsp)
    6c74:	jmp    7548 <botlish_fn_37+0x4bc0>
    6c79:	mov    0x540(%rsp),%rax
    6c81:	movzbq 0x18(%rax),%rsi
    6c86:	test   %rsi,%rsi
    6c89:	jne    6cbb <botlish_fn_37+0x4333>
    6c8f:	mov    %rcx,%rdx
    6c92:	shl    $1,%rdx
    6c95:	mov    %rcx,0x5e8(%rsp)
    6c9d:	or     $0x1,%rdx
    6ca1:	mov    0x540(%rsp),%rsi
    6ca9:	mov    0x520(%rsp),%rdi
    6cb1:	call   6cb6 <botlish_fn_37+0x432e>
			6cb2: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    6cb6:	jmp    6ce6 <botlish_fn_37+0x435e>
    6cbb:	mov    %rcx,0x5e8(%rsp)
    6cc3:	mov    %rcx,%rdi
    6cc6:	shl    $1,%rdi
    6cc9:	or     $0x1,%rdi
    6ccd:	sar    $1,%rdi
    6cd0:	mov    0x540(%rsp),%rax
    6cd8:	movzbq 0x19(%rax,%rdi,1),%rax
    6cde:	shl    $0x3,%rax
    6ce2:	or     $0x4,%rax
    6ce6:	shr    $0x3,%rax
    6cea:	shl    $1,%rax
    6ced:	or     $0x1,%rax
    6cf1:	mov    %rax,0x68(%rsp)
    6cf6:	mov    %rax,%rcx
    6cf9:	sar    $1,%rcx
    6cfc:	cmp    $0x22,%rcx
    6d00:	jne    6d13 <botlish_fn_37+0x438b>
    6d06:	mov    %rax,0x548(%rsp)
    6d0e:	jmp    6d87 <botlish_fn_37+0x43ff>
    6d13:	cmp    $0x5c,%rcx
    6d17:	jne    6d2a <botlish_fn_37+0x43a2>
    6d1d:	mov    %rax,0x548(%rsp)
    6d25:	jmp    6d87 <botlish_fn_37+0x43ff>
    6d2a:	cmp    $0x20,%rcx
    6d2e:	jl     6d54 <botlish_fn_37+0x43cc>
    6d34:	mov    %rax,0x28(%rsp)
    6d39:	mov    %rax,0x548(%rsp)
    6d41:	mov    $0x13,%r15d
    6d47:	mov    %rax,0x660(%rsp)
    6d4f:	jmp    7548 <botlish_fn_37+0x4bc0>
    6d54:	mov    %rax,0x548(%rsp)
    6d5c:	mov    $0xb9,%eax
    6d61:	mov    %rax,0x660(%rsp)
    6d69:	movq   $0xb9,0x28(%rsp)
    6d72:	mov    0x6b8(%rsp),%r15
    6d7a:	mov    %rcx,0x550(%rsp)
    6d82:	jmp    7548 <botlish_fn_37+0x4bc0>
    6d87:	mov    $0xb9,%ecx
    6d8c:	mov    %rcx,0x660(%rsp)
    6d94:	movq   $0xb9,0x28(%rsp)
    6d9d:	mov    $0x4,%r15d
    6da3:	jmp    7548 <botlish_fn_37+0x4bc0>
    6da8:	mov    0x5e0(%rsp),%rsi
    6db0:	mov    0x520(%rsp),%rdi
    6db8:	call   6dbd <botlish_fn_37+0x4435>
			6db9: R_X86_64_PLT32	botlish_fn_32-0x4
    6dbd:	sar    $1,%rax
    6dc0:	test   %rax,%rax
    6dc3:	jg     6e26 <botlish_fn_37+0x449e>
    6dc9:	mov    0x5e0(%rsp),%rcx
    6dd1:	mov    0x18(%rcx),%rax
    6dd5:	mov    (%rax),%rax
    6dd8:	cmp    $0xb2,%rax
    6dde:	je     6e05 <botlish_fn_37+0x447d>
    6de4:	mov    $0xfb,%ecx
    6de9:	mov    %rcx,0x660(%rsp)
    6df1:	movq   $0xfb,0x28(%rsp)
    6dfa:	mov    $0x17,%r15d
    6e00:	jmp    7548 <botlish_fn_37+0x4bc0>
    6e05:	mov    $0xbb,%ecx
    6e0a:	mov    %rcx,0x660(%rsp)
    6e12:	movq   $0xbb,0x28(%rsp)
    6e1b:	mov    $0x16,%r15d
    6e21:	jmp    7548 <botlish_fn_37+0x4bc0>
    6e26:	mov    0x5e0(%rsp),%rcx
    6e2e:	mov    0x18(%rcx),%rax
    6e32:	mov    (%rax),%rcx
    6e35:	cmp    $0xd2,%rcx
    6e3c:	je     745a <botlish_fn_37+0x4ad2>
    6e42:	mov    $0x3,%esi
    6e47:	movq   $0x3,(%rsp)
    6e4f:	lea    0x250(%rsp),%rcx
    6e57:	mov    0x5e0(%rsp),%rax
    6e5f:	mov    %rax,0x250(%rsp)
    6e67:	movq   $0x3,0x258(%rsp)
    6e73:	mov    $0x2,%edx
    6e78:	mov    0x520(%rsp),%rdi
    6e80:	call   6e85 <botlish_fn_37+0x44fd>
			6e81: R_X86_64_PLT32	rt_struct_new-0x4
    6e85:	mov    %rax,%rdx
    6e88:	mov    0x6c8(%rsp),%rsi
    6e90:	mov    0x520(%rsp),%rdi
    6e98:	call   6e9d <botlish_fn_37+0x4515>
			6e99: R_X86_64_PLT32	rt_mv_push-0x4
    6e9d:	mov    0x5e0(%rsp),%rcx
    6ea5:	mov    0x18(%rcx),%rax
    6ea9:	mov    0x18(%rax),%rsi
    6ead:	mov    0x8(%rsi),%rax
    6eb1:	test   %rax,%rax
    6eb4:	jne    6ee5 <botlish_fn_37+0x455d>
    6eba:	mov    $0x1,%edx
    6ebf:	mov    0x520(%rsp),%rdi
    6ec7:	call   6ecc <botlish_fn_37+0x4544>
			6ec8: R_X86_64_PLT32	rt_list_get-0x4
    6ecc:	test   %rax,%rax
    6ecf:	je     7491 <botlish_fn_37+0x4b09>
    6ed5:	mov    %rax,%rcx
    6ed8:	mov    0x6c0(%rsp),%rdi
    6ee0:	jmp    6ef4 <botlish_fn_37+0x456c>
    6ee5:	mov    0x10(%rsi),%rax
    6ee9:	mov    (%rax),%rcx
    6eec:	mov    0x6c0(%rsp),%rdi
    6ef4:	mov    0x6c0(%rsp),%rdi
    6efc:	mov    0x18(%rdi),%rax
    6f00:	test   %rax,%rax
    6f03:	je     a59a <botlish_fn_37+0x7c12>
    6f09:	mov    0x6c0(%rsp),%rdi
    6f11:	mov    0x10(%rdi),%rax
    6f15:	mov    %rcx,(%rax)
    6f18:	mov    0x6c0(%rsp),%rdi
    6f20:	mov    0x6c0(%rsp),%rdi
    6f28:	mov    0x10(%rdi),%rax
    6f2c:	mov    (%rax),%rcx
    6f2f:	mov    %rcx,0x5e0(%rsp)
    6f37:	mov    %rcx,0x48(%rsp)
    6f3c:	mov    0x18(%rcx),%rax
    6f40:	mov    (%rax),%rcx
    6f43:	cmp    $0xb2,%rcx
    6f4a:	je     740b <botlish_fn_37+0x4a83>
    6f50:	cmp    $0xd2,%rcx
    6f57:	je     740b <botlish_fn_37+0x4a83>
    6f5d:	cmp    $0x12,%rcx
    6f61:	je     73ea <botlish_fn_37+0x4a62>
    6f67:	cmp    $0x52,%rcx
    6f6b:	je     73c9 <botlish_fn_37+0x4a41>
    6f71:	cmp    $0x32,%rcx
    6f75:	je     73a6 <botlish_fn_37+0x4a1e>
    6f7b:	cmp    $0x72,%rcx
    6f7f:	je     6fba <botlish_fn_37+0x4632>
    6f85:	mov    0x10(%rax),%r13
    6f89:	mov    %r13,0x5a0(%rsp)
    6f91:	mov    %r13,0xf8(%rsp)
    6f99:	mov    $0x45,%ecx
    6f9e:	mov    %rcx,0x660(%rsp)
    6fa6:	movq   $0x45,0x28(%rsp)
    6faf:	mov    $0x2b,%r15d
    6fb5:	jmp    7548 <botlish_fn_37+0x4bc0>
    6fba:	mov    0x8(%rax),%rcx
    6fbe:	mov    %rcx,0x558(%rsp)
    6fc6:	mov    %rcx,0x70(%rsp)
    6fcb:	mov    0x558(%rsp),%rcx
    6fd3:	test   $0x1,%rcx
    6fda:	jne    700f <botlish_fn_37+0x4687>
    6fe0:	mov    $0x1,%edx
    6fe5:	mov    0x558(%rsp),%rsi
    6fed:	mov    0x520(%rsp),%rdi
    6ff5:	call   6ffa <botlish_fn_37+0x4672>
			6ff6: R_X86_64_PLT32	rt_int_cmp-0x4
    6ffa:	mov    $0x2,%ecx
    6fff:	test   %rax,%rax
    7002:	cmove  0x35d6(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    700a:	jmp    7028 <botlish_fn_37+0x46a0>
    700f:	mov    $0x2,%ecx
    7014:	mov    0x558(%rsp),%rax
    701c:	cmp    $0x1,%rax
    7020:	cmove  0x35b8(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7028:	cmp    $0x6,%rcx
    702c:	je     7385 <botlish_fn_37+0x49fd>
    7032:	mov    0x558(%rsp),%rcx
    703a:	test   $0x1,%rcx
    7041:	jne    7076 <botlish_fn_37+0x46ee>
    7047:	mov    $0x1,%edx
    704c:	mov    0x558(%rsp),%rsi
    7054:	mov    0x520(%rsp),%rdi
    705c:	call   7061 <botlish_fn_37+0x46d9>
			705d: R_X86_64_PLT32	rt_int_cmp-0x4
    7061:	mov    $0x2,%ecx
    7066:	test   %rax,%rax
    7069:	cmovl  0x356f(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7071:	jmp    7096 <botlish_fn_37+0x470e>
    7076:	mov    $0x2,%ecx
    707b:	mov    0x558(%rsp),%rsi
    7083:	mov    0x558(%rsp),%rdi
    708b:	test   %rdi,%rsi
    708e:	cmovle 0x354a(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7096:	cmp    $0x6,%rcx
    709a:	je     7361 <botlish_fn_37+0x49d9>
    70a0:	mov    0x558(%rsp),%rcx
    70a8:	mov    %rcx,0xb8(%rsp)
    70b0:	movq   $0x3,(%rsp)
    70b8:	lea    0x268(%rsp),%rdx
    70c0:	movq   $0x3,0x268(%rsp)
    70cc:	mov    $0x1,%esi
    70d1:	mov    0x520(%rsp),%rdi
    70d9:	call   70de <botlish_fn_37+0x4756>
			70da: R_X86_64_PLT32	rt_list_new-0x4
    70de:	test   %rax,%rax
    70e1:	je     7491 <botlish_fn_37+0x4b09>
    70e7:	mov    %rax,(%rsp)
    70eb:	mov    %rax,%rsi
    70ee:	mov    0x520(%rsp),%rdi
    70f6:	call   70fb <botlish_fn_37+0x4773>
			70f7: R_X86_64_PLT32	rt_mv_from_list-0x4
    70fb:	mov    %rax,0x620(%rsp)
    7103:	mov    %rax,0xc0(%rsp)
    710b:	mov    $0x15,%ebx
    7110:	mov    0x620(%rsp),%rsi
    7118:	mov    0x520(%rsp),%rdi
    7120:	call   7125 <botlish_fn_37+0x479d>
			7121: R_X86_64_PLT32	rt_mv_len-0x4
    7125:	sar    $1,%rax
    7128:	sub    $0x1,%rax
    712c:	shl    $1,%rax
    712f:	mov    %rax,%rdx
    7132:	or     $0x1,%rdx
    7136:	mov    0x620(%rsp),%rsi
    713e:	mov    0x520(%rsp),%rdi
    7146:	call   714b <botlish_fn_37+0x47c3>
			7147: R_X86_64_PLT32	rt_mv_at-0x4
    714b:	mov    %rax,%rcx
    714e:	mov    %rax,%rdi
    7151:	test   %rcx,%rax
    7154:	je     7491 <botlish_fn_37+0x4b09>
    715a:	mov    %rdi,%rax
    715d:	mov    %rax,(%rsp)
    7161:	movq   $0x15,0x10(%rsp)
    716a:	test   $0x1,%rax
    7170:	jne    717e <botlish_fn_37+0x47f6>
    7176:	mov    %rdi,%r12
    7179:	jmp    71b5 <botlish_fn_37+0x482d>
    717e:	mov    %rdi,%rax
    7181:	sar    $1,%rax
    7184:	imulq  0x345d(%rip)        # a5e8 <botlish_fn_37+0x7c60>
    718b:	seto   %cl
    718e:	or     $0x1,%rax
    7192:	test   %cl,%cl
    7194:	je     71a2 <botlish_fn_37+0x481a>
    719a:	mov    %rdi,%r12
    719d:	jmp    71b5 <botlish_fn_37+0x482d>
    71a2:	mov    0x558(%rsp),%rcx
    71aa:	mov    %rax,%rsi
    71ad:	mov    %rdi,%r12
    71b0:	jmp    71d3 <botlish_fn_37+0x484b>
    71b5:	mov    %rbx,%rdx
    71b8:	mov    %r12,%rsi
    71bb:	mov    0x520(%rsp),%rdi
    71c3:	call   71c8 <botlish_fn_37+0x4840>
			71c4: R_X86_64_PLT32	rt_int_mul-0x4
    71c8:	mov    0x558(%rsp),%rcx
    71d0:	mov    %rax,%rsi
    71d3:	mov    0x558(%rsp),%rcx
    71db:	mov    %rsi,%rax
    71de:	and    %rcx,%rax
    71e1:	test   $0x1,%rax
    71e7:	jne    7217 <botlish_fn_37+0x488f>
    71ed:	mov    0x558(%rsp),%rdx
    71f5:	mov    0x520(%rsp),%rdi
    71fd:	call   7202 <botlish_fn_37+0x487a>
			71fe: R_X86_64_PLT32	rt_int_cmp-0x4
    7202:	mov    $0x2,%ecx
    7207:	test   %rax,%rax
    720a:	cmovg  0x33ce(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7212:	jmp    722f <botlish_fn_37+0x48a7>
    7217:	mov    $0x2,%ecx
    721c:	mov    0x558(%rsp),%rax
    7224:	cmp    %rax,%rsi
    7227:	cmovg  0x33b1(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    722f:	cmp    $0x6,%rcx
    7233:	je     72b5 <botlish_fn_37+0x492d>
    7239:	movq   $0x15,0x10(%rsp)
    7242:	test   $0x1,%r12
    7249:	jne    7257 <botlish_fn_37+0x48cf>
    724f:	mov    %r12,%rsi
    7252:	jmp    7288 <botlish_fn_37+0x4900>
    7257:	mov    %r12,%rax
    725a:	sar    $1,%rax
    725d:	mov    %r12,%rdi
    7260:	imulq  0x3381(%rip)        # a5e8 <botlish_fn_37+0x7c60>
    7267:	seto   %sil
    726b:	or     $0x1,%rax
    726f:	test   %sil,%sil
    7272:	je     7280 <botlish_fn_37+0x48f8>
    7278:	mov    %rdi,%rsi
    727b:	jmp    7288 <botlish_fn_37+0x4900>
    7280:	mov    %rax,%rdx
    7283:	jmp    729b <botlish_fn_37+0x4913>
    7288:	mov    %rbx,%rdx
    728b:	mov    0x520(%rsp),%rdi
    7293:	call   7298 <botlish_fn_37+0x4910>
			7294: R_X86_64_PLT32	rt_int_mul-0x4
    7298:	mov    %rax,%rdx
    729b:	mov    0x620(%rsp),%rsi
    72a3:	mov    0x520(%rsp),%rdi
    72ab:	call   72b0 <botlish_fn_37+0x4928>
			72ac: R_X86_64_PLT32	rt_mv_push-0x4
    72b0:	jmp    7110 <botlish_fn_37+0x4788>
    72b5:	mov    0x620(%rsp),%rsi
    72bd:	mov    0x520(%rsp),%rdi
    72c5:	call   72ca <botlish_fn_37+0x4942>
			72c6: R_X86_64_PLT32	rt_mv_pop-0x4
    72ca:	mov    %rax,%rcx
    72cd:	mov    %rax,0x588(%rsp)
    72d5:	test   %rcx,%rax
    72d8:	je     7491 <botlish_fn_37+0x4b09>
    72de:	mov    0x588(%rsp),%rax
    72e6:	mov    %rax,0xc8(%rsp)
    72ee:	mov    0x588(%rsp),%rdx
    72f6:	mov    0x558(%rsp),%rsi
    72fe:	mov    0x520(%rsp),%rdi
    7306:	call   730b <botlish_fn_37+0x4983>
			7307: R_X86_64_PLT32	botlish_fn_15-0x4
    730b:	mov    %rax,0x580(%rsp)
    7313:	mov    %rax,0xd0(%rsp)
    731b:	sar    $1,%rax
    731e:	lea    0x30(%rax),%rcx
    7322:	mov    %rcx,0x660(%rsp)
    732a:	shl    $1,%rcx
    732d:	mov    %rcx,0x660(%rsp)
    7335:	or     $0x1,%rcx
    7339:	mov    %rcx,0x660(%rsp)
    7341:	mov    %rcx,0x28(%rsp)
    7346:	mov    $0x29,%r15d
    734c:	mov    0x558(%rsp),%rax
    7354:	mov    %rax,0x618(%rsp)
    735c:	jmp    7548 <botlish_fn_37+0x4bc0>
    7361:	movq   $0x5b,0x28(%rsp)
    736a:	mov    $0x26,%r15d
    7370:	mov    0x6b0(%rsp),%rax
    7378:	mov    %rax,0x660(%rsp)
    7380:	jmp    7548 <botlish_fn_37+0x4bc0>
    7385:	mov    $0x61,%ecx
    738a:	mov    %rcx,0x660(%rsp)
    7392:	movq   $0x61,0x28(%rsp)
    739b:	mov    $0x25,%r15d
    73a1:	jmp    7548 <botlish_fn_37+0x4bc0>
    73a6:	mov    $0xcd,%ecx
    73ab:	mov    %rcx,0x660(%rsp)
    73b3:	movq   $0xcd,0x28(%rsp)
    73bc:	mov    0x6a0(%rsp),%r15
    73c4:	jmp    7548 <botlish_fn_37+0x4bc0>
    73c9:	mov    $0xe9,%ecx
    73ce:	mov    %rcx,0x660(%rsp)
    73d6:	movq   $0xe9,0x28(%rsp)
    73df:	mov    $0x1c,%r15d
    73e5:	jmp    7548 <botlish_fn_37+0x4bc0>
    73ea:	mov    $0xdd,%ecx
    73ef:	mov    %rcx,0x660(%rsp)
    73f7:	movq   $0xdd,0x28(%rsp)
    7400:	mov    $0x18,%r15d
    7406:	jmp    7548 <botlish_fn_37+0x4bc0>
    740b:	cmp    $0xb2,%rcx
    7412:	je     7439 <botlish_fn_37+0x4ab1>
    7418:	mov    $0xf7,%ecx
    741d:	mov    %rcx,0x660(%rsp)
    7425:	movq   $0xf7,0x28(%rsp)
    742e:	mov    $0x2,%r15d
    7434:	jmp    7548 <botlish_fn_37+0x4bc0>
    7439:	mov    $0xb7,%ecx
    743e:	mov    %rcx,0x660(%rsp)
    7446:	movq   $0xb7,0x28(%rsp)
    744f:	mov    $0x1,%r15d
    7455:	jmp    7548 <botlish_fn_37+0x4bc0>
    745a:	mov    0x20(%rax),%rsi
    745e:	mov    0x8(%rsi),%rax
    7462:	test   %rax,%rax
    7465:	jne    7518 <botlish_fn_37+0x4b90>
    746b:	mov    $0x1,%edx
    7470:	mov    0x520(%rsp),%rdi
    7478:	call   747d <botlish_fn_37+0x4af5>
			7479: R_X86_64_PLT32	rt_list_get-0x4
    747d:	mov    %rax,%rcx
    7480:	mov    %rax,0x540(%rsp)
    7488:	test   %rcx,%rax
    748b:	jne    750b <botlish_fn_37+0x4b83>
    7491:	mov    0x520(%rsp),%rdi
    7499:	call   749e <botlish_fn_37+0x4b16>
			749a: R_X86_64_PLT32	rt_co_failed-0x4
    749e:	mov    %rax,0x30(%rsp)
    74a3:	mov    %rax,%rsi
    74a6:	mov    0x520(%rsp),%rdi
    74ae:	call   74b3 <botlish_fn_37+0x4b2b>
			74af: R_X86_64_PLT32	rt_co_resume0-0x4
    74b3:	test   %rax,%rax
    74b6:	jne    74c9 <botlish_fn_37+0x4b41>
    74bc:	mov    0x520(%rsp),%rdi
    74c4:	jmp    74ed <botlish_fn_37+0x4b65>
    74c9:	mov    0x520(%rsp),%rdi
    74d1:	mov    0x10(%rdi),%rax
    74d5:	mov    0x48(%rax),%rsi
    74d9:	mov    0x218(%rax),%rdx
    74e0:	call   74e5 <botlish_fn_37+0x4b5d>
			74e1: R_X86_64_PLT32	rt_raise-0x4
    74e5:	mov    0x520(%rsp),%rdi
    74ed:	mov    0x520(%rsp),%rdi
    74f5:	call   74fa <botlish_fn_37+0x4b72>
			74f6: R_X86_64_PLT32	rt_declared_error-0x4
    74fa:	cmp    $0x40000001,%rax
    7500:	jne    a46f <botlish_fn_37+0x7ae7>
    7506:	jmp    a46f <botlish_fn_37+0x7ae7>
    750b:	mov    0x540(%rsp),%rax
    7513:	jmp    7527 <botlish_fn_37+0x4b9f>
    7518:	mov    0x10(%rsi),%rax
    751c:	mov    (%rax),%rax
    751f:	mov    %rax,0x540(%rsp)
    7527:	mov    %rax,0x60(%rsp)
    752c:	mov    $0x45,%ecx
    7531:	mov    %rcx,0x660(%rsp)
    7539:	movq   $0x45,0x28(%rsp)
    7542:	mov    $0x3,%r15d
    7548:	test   %r15,%r15
    754b:	jl     8e52 <botlish_fn_37+0x64ca>
    7551:	mov    0x530(%rsp),%r12
    7559:	cmp    $0x1,%r12
    755d:	je     88ed <botlish_fn_37+0x5f65>
    7563:	cmp    $0x2,%r12
    7567:	je     7668 <botlish_fn_37+0x4ce0>
    756d:	cmp    $0x3,%r12
    7571:	je     7635 <botlish_fn_37+0x4cad>
    7577:	cmp    $0x4,%r12
    757b:	je     75fa <botlish_fn_37+0x4c72>
    7581:	cmp    $0x5,%r12
    7585:	je     75c7 <botlish_fn_37+0x4c3f>
    758b:	mov    $0xa,%esi
    7590:	cmp    $0xffffffffffffffff,%r12
    7594:	jne    8bf8 <botlish_fn_37+0x6270>
    759a:	mov    0x678(%rsp),%rbx
    75a2:	mov    0x670(%rsp),%r13
    75aa:	mov    0x528(%rsp),%r14
    75b2:	mov    0x660(%rsp),%rax
    75ba:	mov    %rax,0x5d8(%rsp)
    75c2:	jmp    8df0 <botlish_fn_37+0x6468>
    75c7:	mov    0x668(%rsp),%rsi
    75cf:	mov    %rsi,%rax
    75d2:	sar    $1,%rax
    75d5:	mov    0x678(%rsp),%rbx
    75dd:	mov    0x660(%rsp),%rcx
    75e5:	mov    %rcx,0x538(%rsp)
    75ed:	mov    %rcx,0x5d8(%rsp)
    75f5:	jmp    7b72 <botlish_fn_37+0x51ea>
    75fa:	mov    0x680(%rsp),%rbx
    7602:	mov    %rbx,%r13
    7605:	sar    $1,%r13
    7608:	mov    0x678(%rsp),%rbx
    7610:	mov    0x520(%rsp),%rdi
    7618:	mov    0x660(%rsp),%rax
    7620:	mov    %rax,0x538(%rsp)
    7628:	mov    %rax,0x5d8(%rsp)
    7630:	jmp    81ad <botlish_fn_37+0x5825>
    7635:	mov    0x678(%rsp),%rbx
    763d:	mov    %rbx,%r13
    7640:	sar    $1,%r13
    7643:	mov    0x520(%rsp),%rdi
    764b:	mov    0x660(%rsp),%rax
    7653:	mov    %rax,0x538(%rsp)
    765b:	mov    %rax,0x5d8(%rsp)
    7663:	jmp    84d3 <botlish_fn_37+0x5b4b>
    7668:	mov    0x678(%rsp),%rbx
    7670:	mov    0x688(%rsp),%r14
    7678:	mov    %r14,%rax
    767b:	sar    $1,%rax
    767e:	mov    0x660(%rsp),%rcx
    7686:	mov    %rcx,0x538(%rsp)
    768e:	mov    %rcx,0x5d8(%rsp)
    7696:	shl    $1,%rax
    7699:	or     $0x1,%rax
    769d:	sar    $1,%rax
    76a0:	test   %rax,%rax
    76a3:	jle    781a <botlish_fn_37+0x4e92>
    76a9:	cmp    $0x2,%rax
    76ad:	jl     76c0 <botlish_fn_37+0x4d38>
    76b3:	mov    0x520(%rsp),%rdi
    76bb:	jmp    88c9 <botlish_fn_37+0x5f41>
    76c0:	mov    0x660(%rsp),%rcx
    76c8:	test   $0x1,%rcx
    76cf:	jne    7704 <botlish_fn_37+0x4d7c>
    76d5:	mov    $0x41,%edx
    76da:	mov    0x660(%rsp),%rsi
    76e2:	mov    0x520(%rsp),%rdi
    76ea:	call   76ef <botlish_fn_37+0x4d67>
			76eb: R_X86_64_PLT32	rt_int_cmp-0x4
    76ef:	mov    $0x2,%ecx
    76f4:	test   %rax,%rax
    76f7:	cmovl  0x2ee1(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    76ff:	jmp    771d <botlish_fn_37+0x4d95>
    7704:	mov    $0x2,%ecx
    7709:	mov    0x660(%rsp),%rax
    7711:	cmp    $0x41,%rax
    7715:	cmovl  0x2ec3(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    771d:	cmp    $0x6,%rcx
    7721:	je     7810 <botlish_fn_37+0x4e88>
    7727:	mov    0x660(%rsp),%rcx
    772f:	test   $0x1,%rcx
    7736:	jne    776c <botlish_fn_37+0x4de4>
    773c:	mov    $0x21ffff,%edx
    7741:	mov    0x660(%rsp),%rsi
    7749:	mov    0x520(%rsp),%rdi
    7751:	call   7756 <botlish_fn_37+0x4dce>
			7752: R_X86_64_PLT32	rt_int_cmp-0x4
    7756:	mov    $0x2,%r9d
    775c:	test   %rax,%rax
    775f:	cmovg  0x2e79(%rip),%r9        # a5e0 <botlish_fn_37+0x7c58>
    7767:	jmp    7789 <botlish_fn_37+0x4e01>
    776c:	mov    $0x2,%r9d
    7772:	mov    0x660(%rsp),%rcx
    777a:	cmp    $0x21ffff,%rcx
    7781:	cmovg  0x2e57(%rip),%r9        # a5e0 <botlish_fn_37+0x7c58>
    7789:	cmp    $0x6,%r9
    778d:	je     7810 <botlish_fn_37+0x4e88>
    7793:	mov    0x660(%rsp),%rcx
    779b:	mov    %rcx,%rax
    779e:	sar    $1,%rax
    77a1:	cmp    $0x5c,%rax
    77a5:	jl     77e8 <botlish_fn_37+0x4e60>
    77ab:	cmp    $0xd800,%rax
    77b1:	jl     77d4 <botlish_fn_37+0x4e4c>
    77b7:	cmp    $0xe000,%rax
    77bd:	jl     7810 <botlish_fn_37+0x4e88>
    77c3:	cmp    $0x110000,%rax
    77c9:	jge    7810 <botlish_fn_37+0x4e88>
    77cf:	jmp    7915 <botlish_fn_37+0x4f8d>
    77d4:	cmp    $0x5d,%rax
    77d8:	jge    7915 <botlish_fn_37+0x4f8d>
    77de:	mov    $0x3,%esi
    77e3:	jmp    7924 <botlish_fn_37+0x4f9c>
    77e8:	cmp    $0x22,%rax
    77ec:	jl     7806 <botlish_fn_37+0x4e7e>
    77f2:	cmp    $0x23,%rax
    77f6:	jge    7915 <botlish_fn_37+0x4f8d>
    77fc:	mov    $0x2,%esi
    7801:	jmp    7924 <botlish_fn_37+0x4f9c>
    7806:	cmp    $0x20,%rax
    780a:	jge    7915 <botlish_fn_37+0x4f8d>
    7810:	mov    $0x5,%esi
    7815:	jmp    7924 <botlish_fn_37+0x4f9c>
    781a:	test   %rax,%rax
    781d:	jl     88c1 <botlish_fn_37+0x5f39>
    7823:	mov    0x660(%rsp),%rcx
    782b:	test   $0x1,%rcx
    7832:	jne    7867 <botlish_fn_37+0x4edf>
    7838:	mov    $0x45,%edx
    783d:	mov    0x660(%rsp),%rsi
    7845:	mov    0x520(%rsp),%rdi
    784d:	call   7852 <botlish_fn_37+0x4eca>
			784e: R_X86_64_PLT32	rt_int_cmp-0x4
    7852:	mov    $0x2,%ecx
    7857:	test   %rax,%rax
    785a:	cmovl  0x2d7e(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7862:	jmp    7880 <botlish_fn_37+0x4ef8>
    7867:	mov    $0x2,%ecx
    786c:	mov    0x660(%rsp),%rdx
    7874:	cmp    $0x45,%rdx
    7878:	cmovl  0x2d60(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7880:	cmp    $0x6,%rcx
    7884:	je     791f <botlish_fn_37+0x4f97>
    788a:	mov    0x660(%rsp),%rcx
    7892:	test   $0x1,%rcx
    7899:	jne    78cf <botlish_fn_37+0x4f47>
    789f:	mov    $0x45,%edx
    78a4:	mov    0x660(%rsp),%rsi
    78ac:	mov    0x520(%rsp),%rdi
    78b4:	call   78b9 <botlish_fn_37+0x4f31>
			78b5: R_X86_64_PLT32	rt_int_cmp-0x4
    78b9:	mov    $0x2,%r9d
    78bf:	test   %rax,%rax
    78c2:	cmovg  0x2d16(%rip),%r9        # a5e0 <botlish_fn_37+0x7c58>
    78ca:	jmp    78e9 <botlish_fn_37+0x4f61>
    78cf:	mov    $0x2,%r9d
    78d5:	mov    0x660(%rsp),%rcx
    78dd:	cmp    $0x45,%rcx
    78e1:	cmovg  0x2cf7(%rip),%r9        # a5e0 <botlish_fn_37+0x7c58>
    78e9:	cmp    $0x6,%r9
    78ed:	je     791f <botlish_fn_37+0x4f97>
    78f3:	mov    0x660(%rsp),%rcx
    78fb:	mov    %rcx,%rax
    78fe:	sar    $1,%rax
    7901:	cmp    $0x22,%rax
    7905:	jl     791f <botlish_fn_37+0x4f97>
    790b:	cmp    $0x23,%rax
    790f:	jge    791f <botlish_fn_37+0x4f97>
    7915:	mov    $0x1,%esi
    791a:	jmp    7924 <botlish_fn_37+0x4f9c>
    791f:	mov    $0x4,%esi
    7924:	mov    %rsi,%rcx
    7927:	shl    $1,%rcx
    792a:	or     $0x1,%rcx
    792e:	mov    $0x2,%eax
    7933:	cmp    $0x5,%rcx
    7937:	cmovl  0x2ca1(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    793f:	cmp    $0x6,%rax
    7943:	je     889d <botlish_fn_37+0x5f15>
    7949:	mov    %rsi,%rcx
    794c:	shl    $1,%rcx
    794f:	or     $0x1,%rcx
    7953:	mov    $0x2,%eax
    7958:	cmp    $0x5,%rcx
    795c:	cmove  0x2c7c(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    7964:	cmp    $0x6,%rax
    7968:	je     7aff <botlish_fn_37+0x5177>
    796e:	mov    %rsi,%rcx
    7971:	shl    $1,%rcx
    7974:	mov    %rsi,%r13
    7977:	or     $0x1,%rcx
    797b:	mov    $0x2,%eax
    7980:	cmp    $0x7,%rcx
    7984:	cmove  0x2c54(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    798c:	cmp    $0x6,%rax
    7990:	je     7ae7 <botlish_fn_37+0x515f>
    7996:	mov    0x660(%rsp),%rcx
    799e:	test   $0x1,%rcx
    79a5:	jne    79dc <botlish_fn_37+0x5054>
    79ab:	mov    $0xffffffffffffffff,%rdx
    79b2:	mov    0x660(%rsp),%rsi
    79ba:	mov    0x520(%rsp),%rdi
    79c2:	call   79c7 <botlish_fn_37+0x503f>
			79c3: R_X86_64_PLT32	rt_int_cmp-0x4
    79c7:	mov    $0x2,%ecx
    79cc:	test   %rax,%rax
    79cf:	cmove  0x2c09(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    79d7:	jmp    79f5 <botlish_fn_37+0x506d>
    79dc:	mov    $0x2,%ecx
    79e1:	mov    0x660(%rsp),%rax
    79e9:	cmp    $0xffffffffffffffff,%rax
    79ed:	cmove  0x2beb(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    79f5:	cmp    $0x6,%rcx
    79f9:	je     7a7a <botlish_fn_37+0x50f2>
    79ff:	mov    0x520(%rsp),%rdi
    7a07:	mov    0x10(%rdi),%rax
    7a0b:	mov    0x260(%rax),%rbx
    7a12:	mov    $0x1,%r12d
    7a18:	mov    %r13,%rsi
    7a1b:	shl    $1,%rsi
    7a1e:	or     $0x1,%rsi
    7a22:	call   7a27 <botlish_fn_37+0x509f>
			7a23: R_X86_64_PLT32	botlish_fn_7-0x4
    7a27:	mov    0x520(%rsp),%rdi
    7a2f:	mov    0x10(%rdi),%rcx
    7a33:	mov    0x258(%rcx),%rdx
    7a3a:	lea    0x398(%rsp),%r9
    7a42:	mov    %rbx,0x398(%rsp)
    7a4a:	mov    %rax,0x3a0(%rsp)
    7a52:	mov    0x660(%rsp),%rcx
    7a5a:	mov    %rcx,0x3a8(%rsp)
    7a62:	mov    $0x4,%ecx
    7a67:	mov    $0x3,%r8d
    7a6d:	mov    %r12,%rsi
    7a70:	call   7a75 <botlish_fn_37+0x50ed>
			7a71: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    7a75:	jmp    8be0 <botlish_fn_37+0x6258>
    7a7a:	mov    %r13,%rsi
    7a7d:	mov    0x520(%rsp),%rdi
    7a85:	mov    0x10(%rdi),%rdi
    7a89:	mov    0x260(%rdi),%rbx
    7a90:	shl    $1,%rsi
    7a93:	or     $0x1,%rsi
    7a97:	mov    0x520(%rsp),%rdi
    7a9f:	call   7aa4 <botlish_fn_37+0x511c>
			7aa0: R_X86_64_PLT32	botlish_fn_7-0x4
    7aa4:	mov    0x520(%rsp),%rdi
    7aac:	mov    0x10(%rdi),%rsi
    7ab0:	mov    0x250(%rsi),%rdx
    7ab7:	lea    0x388(%rsp),%r9
    7abf:	mov    %rbx,0x388(%rsp)
    7ac7:	mov    %rax,0x390(%rsp)
    7acf:	mov    $0x2,%r8d
    7ad5:	mov    $0x5,%ecx
    7ada:	mov    %r8,%rsi
    7add:	call   7ae2 <botlish_fn_37+0x515a>
			7ade: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    7ae2:	jmp    8be0 <botlish_fn_37+0x6258>
    7ae7:	xor    %r14,%r14
    7aea:	mov    0x520(%rsp),%rdi
    7af2:	mov    0x670(%rsp),%r13
    7afa:	jmp    8923 <botlish_fn_37+0x5f9b>
    7aff:	mov    $0xfffffffffffffffd,%rcx
    7b06:	mov    %rcx,0x660(%rsp)
    7b0e:	test   $0x1,%rcx
    7b15:	jne    7b4c <botlish_fn_37+0x51c4>
    7b1b:	mov    $0xfffffffffffffffd,%rdx
    7b22:	mov    0x660(%rsp),%rsi
    7b2a:	mov    0x520(%rsp),%rdi
    7b32:	call   7b37 <botlish_fn_37+0x51af>
			7b33: R_X86_64_PLT32	rt_int_cmp-0x4
    7b37:	mov    $0x2,%ecx
    7b3c:	test   %rax,%rax
    7b3f:	cmove  0x2a99(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7b47:	jmp    7b65 <botlish_fn_37+0x51dd>
    7b4c:	mov    $0x2,%ecx
    7b51:	mov    0x660(%rsp),%rsi
    7b59:	cmp    $0xfffffffffffffffd,%rsi
    7b5d:	cmove  0x2a7b(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7b65:	cmp    $0x6,%rcx
    7b69:	je     884f <botlish_fn_37+0x5ec7>
    7b6f:	xor    %rax,%rax
    7b72:	mov    0x660(%rsp),%rcx
    7b7a:	test   $0x1,%rcx
    7b81:	jne    7bb8 <botlish_fn_37+0x5230>
    7b87:	mov    $0xffffffffffffffff,%rdx
    7b8e:	mov    0x660(%rsp),%rsi
    7b96:	mov    0x520(%rsp),%rdi
    7b9e:	call   7ba3 <botlish_fn_37+0x521b>
			7b9f: R_X86_64_PLT32	rt_int_cmp-0x4
    7ba3:	mov    $0x2,%ecx
    7ba8:	test   %rax,%rax
    7bab:	cmovl  0x2a2d(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7bb3:	jmp    7bd1 <botlish_fn_37+0x5249>
    7bb8:	mov    $0x2,%ecx
    7bbd:	mov    0x660(%rsp),%rax
    7bc5:	cmp    $0xffffffffffffffff,%rax
    7bc9:	cmovl  0x2a0f(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7bd1:	cmp    $0x6,%rcx
    7bd5:	je     7df4 <botlish_fn_37+0x546c>
    7bdb:	mov    0x660(%rsp),%rcx
    7be3:	test   $0x1,%rcx
    7bea:	jne    7c1f <botlish_fn_37+0x5297>
    7bf0:	mov    $0x21ffff,%edx
    7bf5:	mov    0x660(%rsp),%rsi
    7bfd:	mov    0x520(%rsp),%rdi
    7c05:	call   7c0a <botlish_fn_37+0x5282>
			7c06: R_X86_64_PLT32	rt_int_cmp-0x4
    7c0a:	mov    $0x2,%ecx
    7c0f:	test   %rax,%rax
    7c12:	cmovg  0x29c6(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7c1a:	jmp    7c3a <botlish_fn_37+0x52b2>
    7c1f:	mov    $0x2,%ecx
    7c24:	mov    0x660(%rsp),%rax
    7c2c:	cmp    $0x21ffff,%rax
    7c32:	cmovg  0x29a6(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7c3a:	cmp    $0x6,%rcx
    7c3e:	je     7df4 <botlish_fn_37+0x546c>
    7c44:	mov    0x660(%rsp),%rcx
    7c4c:	mov    %rcx,%rax
    7c4f:	sar    $1,%rax
    7c52:	cmp    $0x5c,%rax
    7c56:	jl     7d20 <botlish_fn_37+0x5398>
    7c5c:	cmp    $0x75,%rax
    7c60:	jl     7cc6 <botlish_fn_37+0x533e>
    7c66:	cmp    $0x7e,%rax
    7c6a:	jl     7c9e <botlish_fn_37+0x5316>
    7c70:	cmp    $0xe000,%rax
    7c76:	jl     7c8d <botlish_fn_37+0x5305>
    7c7c:	cmp    $0x110000,%rax
    7c82:	jge    7df4 <botlish_fn_37+0x546c>
    7c88:	jmp    7dd6 <botlish_fn_37+0x544e>
    7c8d:	cmp    $0xd800,%rax
    7c93:	jge    7df4 <botlish_fn_37+0x546c>
    7c99:	jmp    7dd6 <botlish_fn_37+0x544e>
    7c9e:	cmp    $0x7c,%rax
    7ca2:	jl     7cb7 <botlish_fn_37+0x532f>
    7ca8:	cmp    $0x7d,%rax
    7cac:	jge    7d7f <botlish_fn_37+0x53f7>
    7cb2:	jmp    7dd6 <botlish_fn_37+0x544e>
    7cb7:	cmp    $0x7b,%rax
    7cbb:	jge    7d7f <botlish_fn_37+0x53f7>
    7cc1:	jmp    7dd6 <botlish_fn_37+0x544e>
    7cc6:	cmp    $0x67,%rax
    7cca:	jl     7cf8 <botlish_fn_37+0x5370>
    7cd0:	cmp    $0x6f,%rax
    7cd4:	jl     7ce9 <botlish_fn_37+0x5361>
    7cda:	cmp    $0x74,%rax
    7cde:	jge    7d7f <botlish_fn_37+0x53f7>
    7ce4:	jmp    7dd6 <botlish_fn_37+0x544e>
    7ce9:	cmp    $0x6e,%rax
    7ced:	jge    7d7f <botlish_fn_37+0x53f7>
    7cf3:	jmp    7dd6 <botlish_fn_37+0x544e>
    7cf8:	cmp    $0x5e,%rax
    7cfc:	jl     7d11 <botlish_fn_37+0x5389>
    7d02:	cmp    $0x66,%rax
    7d06:	jge    7d7f <botlish_fn_37+0x53f7>
    7d0c:	jmp    7dd6 <botlish_fn_37+0x544e>
    7d11:	cmp    $0x5d,%rax
    7d15:	jge    7d7f <botlish_fn_37+0x53f7>
    7d1b:	jmp    7dd6 <botlish_fn_37+0x544e>
    7d20:	cmp    $0x21,%rax
    7d24:	jl     7d89 <botlish_fn_37+0x5401>
    7d2a:	cmp    $0x2e,%rax
    7d2e:	jl     7d5c <botlish_fn_37+0x53d4>
    7d34:	cmp    $0x3b,%rax
    7d38:	jl     7d4d <botlish_fn_37+0x53c5>
    7d3e:	cmp    $0x5b,%rax
    7d42:	jge    7d7f <botlish_fn_37+0x53f7>
    7d48:	jmp    7dd6 <botlish_fn_37+0x544e>
    7d4d:	cmp    $0x30,%rax
    7d51:	jge    7d7f <botlish_fn_37+0x53f7>
    7d57:	jmp    7dd6 <botlish_fn_37+0x544e>
    7d5c:	cmp    $0x23,%rax
    7d60:	jl     7d75 <botlish_fn_37+0x53ed>
    7d66:	cmp    $0x2c,%rax
    7d6a:	jge    7d7f <botlish_fn_37+0x53f7>
    7d70:	jmp    7dd6 <botlish_fn_37+0x544e>
    7d75:	cmp    $0x22,%rax
    7d79:	jl     7dd6 <botlish_fn_37+0x544e>
    7d7f:	mov    $0x2,%esi
    7d84:	jmp    7df9 <botlish_fn_37+0x5471>
    7d89:	cmp    $0xb,%rax
    7d8d:	jl     7dbb <botlish_fn_37+0x5433>
    7d93:	cmp    $0xe,%rax
    7d97:	jl     7dac <botlish_fn_37+0x5424>
    7d9d:	cmp    $0x20,%rax
    7da1:	jge    7dce <botlish_fn_37+0x5446>
    7da7:	jmp    7dd6 <botlish_fn_37+0x544e>
    7dac:	cmp    $0xd,%rax
    7db0:	jge    7dce <botlish_fn_37+0x5446>
    7db6:	jmp    7dd6 <botlish_fn_37+0x544e>
    7dbb:	test   %rax,%rax
    7dbe:	jl     7de0 <botlish_fn_37+0x5458>
    7dc4:	cmp    $0x9,%rax
    7dc8:	jl     7dd6 <botlish_fn_37+0x544e>
    7dce:	xor    %rsi,%rsi
    7dd1:	jmp    7df9 <botlish_fn_37+0x5471>
    7dd6:	mov    $0x4,%esi
    7ddb:	jmp    7df9 <botlish_fn_37+0x5471>
    7de0:	cmp    $0xffffffffffffffff,%rax
    7de4:	jl     7df4 <botlish_fn_37+0x546c>
    7dea:	mov    $0x1,%esi
    7def:	jmp    7df9 <botlish_fn_37+0x5471>
    7df4:	mov    $0x3,%esi
    7df9:	mov    %rsi,%r10
    7dfc:	shl    $1,%r10
    7dff:	or     $0x1,%r10
    7e03:	mov    $0x2,%eax
    7e08:	cmp    $0x3,%r10
    7e0c:	cmovl  0x27cc(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    7e14:	cmp    $0x6,%rax
    7e18:	je     8833 <botlish_fn_37+0x5eab>
    7e1e:	mov    %rsi,%rcx
    7e21:	shl    $1,%rcx
    7e24:	or     $0x1,%rcx
    7e28:	mov    $0x2,%eax
    7e2d:	cmp    $0x3,%rcx
    7e31:	cmove  0x27a7(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    7e39:	cmp    $0x6,%rax
    7e3d:	je     87fd <botlish_fn_37+0x5e75>
    7e43:	mov    %rsi,%rcx
    7e46:	shl    $1,%rcx
    7e49:	or     $0x1,%rcx
    7e4d:	mov    $0x2,%eax
    7e52:	cmp    $0x5,%rcx
    7e56:	cmove  0x2782(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    7e5e:	cmp    $0x6,%rax
    7e62:	je     7ef3 <botlish_fn_37+0x556b>
    7e68:	mov    $0x1,%ebx
    7e6d:	shl    $1,%rsi
    7e70:	or     $0x1,%rsi
    7e74:	mov    %rsi,%r14
    7e77:	mov    0x520(%rsp),%rdi
    7e7f:	call   7e84 <botlish_fn_37+0x54fc>
			7e80: R_X86_64_PLT32	botlish_fn_10-0x4
    7e84:	mov    %r14,%rsi
    7e87:	mov    %rax,%r12
    7e8a:	mov    0x520(%rsp),%rdi
    7e92:	call   7e97 <botlish_fn_37+0x550f>
			7e93: R_X86_64_PLT32	botlish_fn_11-0x4
    7e97:	mov    %rax,%rcx
    7e9a:	mov    0x520(%rsp),%rdi
    7ea2:	mov    0x10(%rdi),%rax
    7ea6:	mov    0x258(%rax),%rdx
    7ead:	lea    0x428(%rsp),%r9
    7eb5:	mov    %r12,%rax
    7eb8:	mov    %rax,0x428(%rsp)
    7ec0:	mov    %rcx,%rax
    7ec3:	mov    %rax,0x430(%rsp)
    7ecb:	mov    0x660(%rsp),%rcx
    7ed3:	mov    %rcx,0x438(%rsp)
    7edb:	mov    $0x4,%ecx
    7ee0:	mov    $0x3,%r8d
    7ee6:	mov    %rbx,%rsi
    7ee9:	call   7eee <botlish_fn_37+0x5566>
			7eea: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    7eee:	jmp    8be0 <botlish_fn_37+0x6258>
    7ef3:	mov    0x520(%rsp),%rdi
    7efb:	mov    0x10(%rdi),%rax
    7eff:	mov    0x238(%rax),%r12
    7f06:	mov    0x660(%rsp),%rcx
    7f0e:	test   $0x1,%rcx
    7f15:	jne    7f4d <botlish_fn_37+0x55c5>
    7f1b:	mov    $0xffffffffffffffff,%rdx
    7f22:	mov    0x660(%rsp),%rsi
    7f2a:	mov    0x520(%rsp),%rdi
    7f32:	call   7f37 <botlish_fn_37+0x55af>
			7f33: R_X86_64_PLT32	rt_int_cmp-0x4
    7f37:	mov    $0x2,%r10d
    7f3d:	test   %rax,%rax
    7f40:	cmovl  0x2698(%rip),%r10        # a5e0 <botlish_fn_37+0x7c58>
    7f48:	jmp    7f67 <botlish_fn_37+0x55df>
    7f4d:	mov    $0x2,%r10d
    7f53:	mov    0x660(%rsp),%rcx
    7f5b:	cmp    $0xffffffffffffffff,%rcx
    7f5f:	cmovl  0x2679(%rip),%r10        # a5e0 <botlish_fn_37+0x7c58>
    7f67:	cmp    $0x6,%r10
    7f6b:	je     7ff3 <botlish_fn_37+0x566b>
    7f71:	mov    0x660(%rsp),%rcx
    7f79:	test   $0x1,%rcx
    7f80:	jne    7fb5 <botlish_fn_37+0x562d>
    7f86:	mov    $0x1ff,%edx
    7f8b:	mov    0x660(%rsp),%rsi
    7f93:	mov    0x520(%rsp),%rdi
    7f9b:	call   7fa0 <botlish_fn_37+0x5618>
			7f9c: R_X86_64_PLT32	rt_int_cmp-0x4
    7fa0:	mov    $0x2,%ecx
    7fa5:	test   %rax,%rax
    7fa8:	cmovg  0x2630(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7fb0:	jmp    7fd0 <botlish_fn_37+0x5648>
    7fb5:	mov    $0x2,%ecx
    7fba:	mov    0x660(%rsp),%rax
    7fc2:	cmp    $0x1ff,%rax
    7fc8:	cmovg  0x2610(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    7fd0:	cmp    $0x6,%rcx
    7fd4:	je     7ff3 <botlish_fn_37+0x566b>
    7fda:	mov    0x660(%rsp),%rcx
    7fe2:	mov    %rcx,%rax
    7fe5:	sar    $1,%rax
    7fe8:	movzbq 0x11(%r12,%rax,1),%rax
    7fee:	jmp    7ffc <botlish_fn_37+0x5674>
    7ff3:	movzbq 0x111(%r12),%rax
    7ffc:	mov    %rax,%rdx
    7fff:	shl    $1,%rdx
    8002:	or     $0x1,%rdx
    8006:	mov    $0x2,%ecx
    800b:	cmp    $0x3,%rdx
    800f:	cmove  0x25c9(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    8017:	cmp    $0x6,%rcx
    801b:	je     87e9 <botlish_fn_37+0x5e61>
    8021:	mov    %rax,%rdx
    8024:	shl    $1,%rdx
    8027:	or     $0x1,%rdx
    802b:	mov    $0x2,%ecx
    8030:	cmp    $0x5,%rdx
    8034:	cmove  0x25a4(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    803c:	cmp    $0x6,%rcx
    8040:	je     87e1 <botlish_fn_37+0x5e59>
    8046:	mov    %rax,%rdx
    8049:	shl    $1,%rdx
    804c:	or     $0x1,%rdx
    8050:	mov    $0x2,%ecx
    8055:	cmp    $0x7,%rdx
    8059:	cmove  0x257f(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    8061:	cmp    $0x6,%rcx
    8065:	je     84c8 <botlish_fn_37+0x5b40>
    806b:	shl    $1,%rax
    806e:	or     $0x1,%rax
    8072:	mov    $0x2,%ecx
    8077:	cmp    $0x9,%rax
    807b:	cmove  0x255d(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    8083:	cmp    $0x6,%rcx
    8087:	je     81a2 <botlish_fn_37+0x581a>
    808d:	mov    0x660(%rsp),%rcx
    8095:	test   $0x1,%rcx
    809c:	jne    80d3 <botlish_fn_37+0x574b>
    80a2:	mov    $0xffffffffffffffff,%rdx
    80a9:	mov    0x660(%rsp),%rsi
    80b1:	mov    0x520(%rsp),%rdi
    80b9:	call   80be <botlish_fn_37+0x5736>
			80ba: R_X86_64_PLT32	rt_int_cmp-0x4
    80be:	mov    $0x2,%ecx
    80c3:	test   %rax,%rax
    80c6:	cmove  0x2512(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    80ce:	jmp    80ec <botlish_fn_37+0x5764>
    80d3:	mov    $0x2,%ecx
    80d8:	mov    0x660(%rsp),%rax
    80e0:	cmp    $0xffffffffffffffff,%rax
    80e4:	cmove  0x24f4(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    80ec:	cmp    $0x6,%rcx
    80f0:	je     8155 <botlish_fn_37+0x57cd>
    80f6:	mov    0x520(%rsp),%rdi
    80fe:	mov    0x10(%rdi),%rdx
    8102:	mov    0x118(%rdx),%rax
    8109:	mov    (%rdx),%rcx
    810c:	mov    0x258(%rdx),%rdx
    8113:	lea    0x410(%rsp),%r9
    811b:	mov    %rax,0x410(%rsp)
    8123:	mov    %rcx,0x418(%rsp)
    812b:	mov    0x660(%rsp),%rcx
    8133:	mov    %rcx,0x420(%rsp)
    813b:	mov    $0x1,%esi
    8140:	mov    $0x4,%ecx
    8145:	mov    $0x3,%r8d
    814b:	call   8150 <botlish_fn_37+0x57c8>
			814c: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8150:	jmp    8be0 <botlish_fn_37+0x6258>
    8155:	mov    0x520(%rsp),%rdi
    815d:	mov    0x10(%rdi),%rdx
    8161:	mov    0x118(%rdx),%rax
    8168:	mov    (%rdx),%rcx
    816b:	mov    0x250(%rdx),%rdx
    8172:	lea    0x400(%rsp),%r9
    817a:	mov    %rax,0x400(%rsp)
    8182:	mov    %rcx,0x408(%rsp)
    818a:	mov    $0x2,%r8d
    8190:	mov    $0x5,%ecx
    8195:	mov    %r8,%rsi
    8198:	call   819d <botlish_fn_37+0x5815>
			8199: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    819d:	jmp    8be0 <botlish_fn_37+0x6258>
    81a2:	xor    %r13,%r13
    81a5:	mov    0x520(%rsp),%rdi
    81ad:	mov    0x520(%rsp),%rdi
    81b5:	mov    0x10(%rdi),%rax
    81b9:	mov    0x278(%rax),%r12
    81c0:	mov    0x660(%rsp),%rcx
    81c8:	test   $0x1,%rcx
    81cf:	jne    8206 <botlish_fn_37+0x587e>
    81d5:	mov    $0xffffffffffffffff,%rdx
    81dc:	mov    0x660(%rsp),%rsi
    81e4:	mov    0x520(%rsp),%rdi
    81ec:	call   81f1 <botlish_fn_37+0x5869>
			81ed: R_X86_64_PLT32	rt_int_cmp-0x4
    81f1:	mov    $0x2,%ecx
    81f6:	test   %rax,%rax
    81f9:	cmovl  0x23df(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    8201:	jmp    821f <botlish_fn_37+0x5897>
    8206:	mov    $0x2,%ecx
    820b:	mov    0x660(%rsp),%rax
    8213:	cmp    $0xffffffffffffffff,%rax
    8217:	cmovl  0x23c1(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    821f:	cmp    $0x6,%rcx
    8223:	je     82be <botlish_fn_37+0x5936>
    8229:	mov    0x660(%rsp),%rcx
    8231:	test   $0x1,%rcx
    8238:	jne    826d <botlish_fn_37+0x58e5>
    823e:	mov    $0x1ff,%edx
    8243:	mov    0x660(%rsp),%rsi
    824b:	mov    0x520(%rsp),%rdi
    8253:	call   8258 <botlish_fn_37+0x58d0>
			8254: R_X86_64_PLT32	rt_int_cmp-0x4
    8258:	mov    $0x2,%ecx
    825d:	test   %rax,%rax
    8260:	cmovg  0x2378(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    8268:	jmp    8288 <botlish_fn_37+0x5900>
    826d:	mov    $0x2,%ecx
    8272:	mov    0x660(%rsp),%rax
    827a:	cmp    $0x1ff,%rax
    8280:	cmovg  0x2358(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    8288:	cmp    $0x6,%rcx
    828c:	je     82be <botlish_fn_37+0x5936>
    8292:	shl    $1,%r13
    8295:	or     $0x1,%r13
    8299:	sar    $1,%r13
    829c:	imul   $0x101,%r13,%rax
    82a3:	mov    0x660(%rsp),%rcx
    82ab:	sar    $1,%rcx
    82ae:	lea    0x1(%rax,%rcx,1),%rax
    82b3:	movzbq 0x10(%r12,%rax,1),%rsi
    82b9:	jmp    82d1 <botlish_fn_37+0x5949>
    82be:	shl    $1,%r13
    82c1:	or     $0x1,%r13
    82c5:	sar    $1,%r13
    82c8:	movzbq 0xc1c(%r12,%r13,1),%rsi
    82d1:	mov    %rsi,%rcx
    82d4:	shl    $1,%rcx
    82d7:	or     $0x1,%rcx
    82db:	mov    $0x2,%eax
    82e0:	cmp    $0x19,%rcx
    82e4:	cmovl  0x22f4(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    82ec:	cmp    $0x6,%rax
    82f0:	je     847c <botlish_fn_37+0x5af4>
    82f6:	mov    %rsi,%rcx
    82f9:	shl    $1,%rcx
    82fc:	mov    %rsi,%r13
    82ff:	or     $0x1,%rcx
    8303:	mov    $0x2,%eax
    8308:	cmp    $0x19,%rcx
    830c:	cmove  0x22cc(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    8314:	cmp    $0x6,%rax
    8318:	je     846f <botlish_fn_37+0x5ae7>
    831e:	mov    0x660(%rsp),%rcx
    8326:	test   $0x1,%rcx
    832d:	jne    8364 <botlish_fn_37+0x59dc>
    8333:	mov    $0xffffffffffffffff,%rdx
    833a:	mov    0x660(%rsp),%rsi
    8342:	mov    0x520(%rsp),%rdi
    834a:	call   834f <botlish_fn_37+0x59c7>
			834b: R_X86_64_PLT32	rt_int_cmp-0x4
    834f:	mov    $0x2,%ecx
    8354:	test   %rax,%rax
    8357:	cmove  0x2281(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    835f:	jmp    837d <botlish_fn_37+0x59f5>
    8364:	mov    $0x2,%ecx
    8369:	mov    0x660(%rsp),%rax
    8371:	cmp    $0xffffffffffffffff,%rax
    8375:	cmove  0x2263(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    837d:	cmp    $0x6,%rcx
    8381:	je     8402 <botlish_fn_37+0x5a7a>
    8387:	mov    0x520(%rsp),%rdi
    838f:	mov    0x10(%rdi),%rax
    8393:	mov    0x280(%rax),%rbx
    839a:	mov    $0x1,%r12d
    83a0:	mov    %r13,%rsi
    83a3:	shl    $1,%rsi
    83a6:	or     $0x1,%rsi
    83aa:	call   83af <botlish_fn_37+0x5a27>
			83ab: R_X86_64_PLT32	botlish_fn_3-0x4
    83af:	mov    0x520(%rsp),%rdi
    83b7:	mov    0x10(%rdi),%rcx
    83bb:	mov    0x258(%rcx),%rdx
    83c2:	lea    0x3e8(%rsp),%r9
    83ca:	mov    %rbx,0x3e8(%rsp)
    83d2:	mov    %rax,0x3f0(%rsp)
    83da:	mov    0x660(%rsp),%rcx
    83e2:	mov    %rcx,0x3f8(%rsp)
    83ea:	mov    $0x4,%ecx
    83ef:	mov    $0x3,%r8d
    83f5:	mov    %r12,%rsi
    83f8:	call   83fd <botlish_fn_37+0x5a75>
			83f9: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    83fd:	jmp    8be0 <botlish_fn_37+0x6258>
    8402:	mov    %r13,%rsi
    8405:	mov    0x520(%rsp),%rdi
    840d:	mov    0x10(%rdi),%rdi
    8411:	mov    0x280(%rdi),%r12
    8418:	shl    $1,%rsi
    841b:	or     $0x1,%rsi
    841f:	mov    0x520(%rsp),%rdi
    8427:	call   842c <botlish_fn_37+0x5aa4>
			8428: R_X86_64_PLT32	botlish_fn_3-0x4
    842c:	mov    0x520(%rsp),%rdi
    8434:	mov    0x10(%rdi),%rsi
    8438:	mov    0x250(%rsi),%rdx
    843f:	lea    0x3d8(%rsp),%r9
    8447:	mov    %r12,0x3d8(%rsp)
    844f:	mov    %rax,0x3e0(%rsp)
    8457:	mov    $0x2,%r8d
    845d:	mov    $0x5,%ecx
    8462:	mov    %r8,%rsi
    8465:	call   846a <botlish_fn_37+0x5ae2>
			8466: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    846a:	jmp    8be0 <botlish_fn_37+0x6258>
    846f:	mov    0x660(%rsp),%rcx
    8477:	jmp    7b0e <botlish_fn_37+0x5186>
    847c:	shl    $1,%rsi
    847f:	or     $0x1,%rsi
    8483:	mov    %rsi,0x148(%rsp)
    848b:	mov    $0x1,%r14d
    8491:	movq   $0x1,0x118(%rsp)
    849d:	mov    $0x4,%r12d
    84a3:	mov    0x670(%rsp),%r13
    84ab:	mov    0x538(%rsp),%rax
    84b3:	mov    %rax,0x660(%rsp)
    84bb:	mov    %rsi,0x680(%rsp)
    84c3:	jmp    8df0 <botlish_fn_37+0x6468>
    84c8:	xor    %r13,%r13
    84cb:	mov    0x520(%rsp),%rdi
    84d3:	mov    0x520(%rsp),%rdi
    84db:	mov    0x10(%rdi),%rax
    84df:	mov    0x268(%rax),%r12
    84e6:	mov    0x660(%rsp),%rcx
    84ee:	test   $0x1,%rcx
    84f5:	jne    852c <botlish_fn_37+0x5ba4>
    84fb:	mov    $0xffffffffffffffff,%rdx
    8502:	mov    0x660(%rsp),%rsi
    850a:	mov    0x520(%rsp),%rdi
    8512:	call   8517 <botlish_fn_37+0x5b8f>
			8513: R_X86_64_PLT32	rt_int_cmp-0x4
    8517:	mov    $0x2,%esi
    851c:	test   %rax,%rax
    851f:	cmovl  0x20b9(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    8527:	jmp    8545 <botlish_fn_37+0x5bbd>
    852c:	mov    $0x2,%esi
    8531:	mov    0x660(%rsp),%rcx
    8539:	cmp    $0xffffffffffffffff,%rcx
    853d:	cmovl  0x209b(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    8545:	cmp    $0x6,%rsi
    8549:	je     85e4 <botlish_fn_37+0x5c5c>
    854f:	mov    0x660(%rsp),%rcx
    8557:	test   $0x1,%rcx
    855e:	jne    8593 <botlish_fn_37+0x5c0b>
    8564:	mov    $0x1ff,%edx
    8569:	mov    0x660(%rsp),%rsi
    8571:	mov    0x520(%rsp),%rdi
    8579:	call   857e <botlish_fn_37+0x5bf6>
			857a: R_X86_64_PLT32	rt_int_cmp-0x4
    857e:	mov    $0x2,%ecx
    8583:	test   %rax,%rax
    8586:	cmovg  0x2052(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    858e:	jmp    85ae <botlish_fn_37+0x5c26>
    8593:	mov    $0x2,%ecx
    8598:	mov    0x660(%rsp),%rax
    85a0:	cmp    $0x1ff,%rax
    85a6:	cmovg  0x2032(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    85ae:	cmp    $0x6,%rcx
    85b2:	je     85e4 <botlish_fn_37+0x5c5c>
    85b8:	shl    $1,%r13
    85bb:	or     $0x1,%r13
    85bf:	sar    $1,%r13
    85c2:	imul   $0x101,%r13,%rax
    85c9:	mov    0x660(%rsp),%rcx
    85d1:	sar    $1,%rcx
    85d4:	lea    0x1(%rax,%rcx,1),%rax
    85d9:	movzbq 0x10(%r12,%rax,1),%rsi
    85df:	jmp    85f7 <botlish_fn_37+0x5c6f>
    85e4:	shl    $1,%r13
    85e7:	or     $0x1,%r13
    85eb:	sar    $1,%r13
    85ee:	movzbq 0x919(%r12,%r13,1),%rsi
    85f7:	mov    %rsi,%rcx
    85fa:	shl    $1,%rcx
    85fd:	or     $0x1,%rcx
    8601:	mov    $0x2,%eax
    8606:	cmp    $0x13,%rcx
    860a:	cmovl  0x1fce(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    8612:	cmp    $0x6,%rax
    8616:	je     879a <botlish_fn_37+0x5e12>
    861c:	mov    %rsi,%rcx
    861f:	shl    $1,%rcx
    8622:	mov    %rsi,%r13
    8625:	or     $0x1,%rcx
    8629:	mov    $0x2,%eax
    862e:	cmp    $0x13,%rcx
    8632:	cmove  0x1fa6(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    863a:	cmp    $0x6,%rax
    863e:	je     878d <botlish_fn_37+0x5e05>
    8644:	mov    0x660(%rsp),%rcx
    864c:	test   $0x1,%rcx
    8653:	jne    868a <botlish_fn_37+0x5d02>
    8659:	mov    $0xffffffffffffffff,%rdx
    8660:	mov    0x660(%rsp),%rsi
    8668:	mov    0x520(%rsp),%rdi
    8670:	call   8675 <botlish_fn_37+0x5ced>
			8671: R_X86_64_PLT32	rt_int_cmp-0x4
    8675:	mov    $0x2,%edi
    867a:	test   %rax,%rax
    867d:	cmove  0x1f5b(%rip),%rdi        # a5e0 <botlish_fn_37+0x7c58>
    8685:	jmp    86a3 <botlish_fn_37+0x5d1b>
    868a:	mov    $0x2,%edi
    868f:	mov    0x660(%rsp),%rcx
    8697:	cmp    $0xffffffffffffffff,%rcx
    869b:	cmove  0x1f3d(%rip),%rdi        # a5e0 <botlish_fn_37+0x7c58>
    86a3:	cmp    $0x6,%rdi
    86a7:	je     8728 <botlish_fn_37+0x5da0>
    86ad:	mov    0x520(%rsp),%rdi
    86b5:	mov    0x10(%rdi),%rax
    86b9:	mov    0x270(%rax),%rbx
    86c0:	mov    $0x1,%r12d
    86c6:	mov    %r13,%rsi
    86c9:	shl    $1,%rsi
    86cc:	or     $0x1,%rsi
    86d0:	call   86d5 <botlish_fn_37+0x5d4d>
			86d1: R_X86_64_PLT32	botlish_fn_1-0x4
    86d5:	mov    0x520(%rsp),%rdi
    86dd:	mov    0x10(%rdi),%rcx
    86e1:	mov    0x258(%rcx),%rdx
    86e8:	lea    0x3c0(%rsp),%r9
    86f0:	mov    %rbx,0x3c0(%rsp)
    86f8:	mov    %rax,0x3c8(%rsp)
    8700:	mov    0x660(%rsp),%rcx
    8708:	mov    %rcx,0x3d0(%rsp)
    8710:	mov    $0x4,%ecx
    8715:	mov    $0x3,%r8d
    871b:	mov    %r12,%rsi
    871e:	call   8723 <botlish_fn_37+0x5d9b>
			871f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8723:	jmp    8be0 <botlish_fn_37+0x6258>
    8728:	mov    %r13,%rsi
    872b:	mov    0x520(%rsp),%rdi
    8733:	mov    0x10(%rdi),%rax
    8737:	mov    0x270(%rax),%rbx
    873e:	shl    $1,%rsi
    8741:	or     $0x1,%rsi
    8745:	call   874a <botlish_fn_37+0x5dc2>
			8746: R_X86_64_PLT32	botlish_fn_1-0x4
    874a:	mov    0x520(%rsp),%rdi
    8752:	mov    0x10(%rdi),%rcx
    8756:	mov    0x250(%rcx),%rdx
    875d:	lea    0x3b0(%rsp),%r9
    8765:	mov    %rbx,0x3b0(%rsp)
    876d:	mov    %rax,0x3b8(%rsp)
    8775:	mov    $0x2,%r8d
    877b:	mov    $0x5,%ecx
    8780:	mov    %r8,%rsi
    8783:	call   8788 <botlish_fn_37+0x5e00>
			8784: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8788:	jmp    8be0 <botlish_fn_37+0x6258>
    878d:	mov    0x660(%rsp),%rcx
    8795:	jmp    7b0e <botlish_fn_37+0x5186>
    879a:	shl    $1,%rsi
    879d:	or     $0x1,%rsi
    87a1:	mov    %rsi,0x140(%rsp)
    87a9:	mov    $0x1,%r14d
    87af:	movq   $0x1,0x118(%rsp)
    87bb:	mov    $0x3,%r12d
    87c1:	mov    %rsi,%rbx
    87c4:	mov    0x670(%rsp),%r13
    87cc:	mov    0x538(%rsp),%rax
    87d4:	mov    %rax,0x660(%rsp)
    87dc:	jmp    8df0 <botlish_fn_37+0x6468>
    87e1:	xor    %rax,%rax
    87e4:	jmp    7696 <botlish_fn_37+0x4d0e>
    87e9:	mov    $0xfffffffffffffffd,%rcx
    87f0:	mov    %rcx,0x660(%rsp)
    87f8:	jmp    7b0e <botlish_fn_37+0x5186>
    87fd:	mov    $0x1,%r14d
    8803:	movq   $0x1,0x118(%rsp)
    880f:	mov    $0xffffffffffffffff,%r12
    8816:	mov    0x670(%rsp),%r13
    881e:	mov    0x538(%rsp),%rax
    8826:	mov    %rax,0x660(%rsp)
    882e:	jmp    8df0 <botlish_fn_37+0x6468>
    8833:	shl    $1,%rsi
    8836:	or     $0x1,%rsi
    883a:	mov    %rsi,0x128(%rsp)
    8842:	mov    %rsi,0x668(%rsp)
    884a:	jmp    8868 <botlish_fn_37+0x5ee0>
    884f:	mov    $0x1,%esi
    8854:	mov    %rsi,0x668(%rsp)
    885c:	movq   $0x1,0x128(%rsp)
    8868:	mov    $0x1,%r14d
    886e:	movq   $0x1,0x118(%rsp)
    887a:	mov    $0x5,%r12d
    8880:	mov    0x670(%rsp),%r13
    8888:	mov    0x538(%rsp),%rax
    8890:	mov    %rax,0x660(%rsp)
    8898:	jmp    8df0 <botlish_fn_37+0x6468>
    889d:	shl    $1,%rsi
    88a0:	or     $0x1,%rsi
    88a4:	mov    %rsi,0x130(%rsp)
    88ac:	mov    0x670(%rsp),%r13
    88b4:	mov    %rsi,0x688(%rsp)
    88bc:	jmp    8d8c <botlish_fn_37+0x6404>
    88c1:	mov    0x520(%rsp),%rdi
    88c9:	mov    0x520(%rsp),%rdi
    88d1:	mov    0x10(%rdi),%rax
    88d5:	mov    0x228(%rax),%rsi
    88dc:	mov    0x230(%rax),%rdx
    88e3:	call   88e8 <botlish_fn_37+0x5f60>
			88e4: R_X86_64_PLT32	rt_raise-0x4
    88e8:	jmp    8be0 <botlish_fn_37+0x6258>
    88ed:	mov    0x678(%rsp),%rbx
    88f5:	mov    0x670(%rsp),%r13
    88fd:	mov    %r13,%r14
    8900:	sar    $1,%r14
    8903:	mov    0x520(%rsp),%rdi
    890b:	mov    0x660(%rsp),%rax
    8913:	mov    %rax,0x538(%rsp)
    891b:	mov    %rax,0x5d8(%rsp)
    8923:	mov    0x520(%rsp),%rdi
    892b:	mov    0x10(%rdi),%rax
    892f:	mov    0x240(%rax),%r12
    8936:	mov    0x660(%rsp),%rcx
    893e:	test   $0x1,%rcx
    8945:	jne    897c <botlish_fn_37+0x5ff4>
    894b:	mov    $0xffffffffffffffff,%rdx
    8952:	mov    0x660(%rsp),%rsi
    895a:	mov    0x520(%rsp),%rdi
    8962:	call   8967 <botlish_fn_37+0x5fdf>
			8963: R_X86_64_PLT32	rt_int_cmp-0x4
    8967:	mov    $0x2,%ecx
    896c:	test   %rax,%rax
    896f:	cmovl  0x1c69(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    8977:	jmp    8995 <botlish_fn_37+0x600d>
    897c:	mov    $0x2,%ecx
    8981:	mov    0x660(%rsp),%rax
    8989:	cmp    $0xffffffffffffffff,%rax
    898d:	cmovl  0x1c4b(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    8995:	cmp    $0x6,%rcx
    8999:	je     8a34 <botlish_fn_37+0x60ac>
    899f:	mov    0x660(%rsp),%rcx
    89a7:	test   $0x1,%rcx
    89ae:	jne    89e3 <botlish_fn_37+0x605b>
    89b4:	mov    $0x1ff,%edx
    89b9:	mov    0x660(%rsp),%rsi
    89c1:	mov    0x520(%rsp),%rdi
    89c9:	call   89ce <botlish_fn_37+0x6046>
			89ca: R_X86_64_PLT32	rt_int_cmp-0x4
    89ce:	mov    $0x2,%ecx
    89d3:	test   %rax,%rax
    89d6:	cmovg  0x1c02(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    89de:	jmp    89fe <botlish_fn_37+0x6076>
    89e3:	mov    $0x2,%ecx
    89e8:	mov    0x660(%rsp),%rax
    89f0:	cmp    $0x1ff,%rax
    89f6:	cmovg  0x1be2(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    89fe:	cmp    $0x6,%rcx
    8a02:	je     8a34 <botlish_fn_37+0x60ac>
    8a08:	shl    $1,%r14
    8a0b:	or     $0x1,%r14
    8a0f:	sar    $1,%r14
    8a12:	imul   $0x101,%r14,%rax
    8a19:	mov    0x660(%rsp),%rcx
    8a21:	sar    $1,%rcx
    8a24:	lea    0x1(%rax,%rcx,1),%rax
    8a29:	movzbq 0x10(%r12,%rax,1),%rsi
    8a2f:	jmp    8a47 <botlish_fn_37+0x60bf>
    8a34:	shl    $1,%r14
    8a37:	or     $0x1,%r14
    8a3b:	sar    $1,%r14
    8a3e:	movzbq 0x616(%r12,%r14,1),%rsi
    8a47:	mov    %rsi,%rcx
    8a4a:	shl    $1,%rcx
    8a4d:	or     $0x1,%rcx
    8a51:	mov    $0x2,%eax
    8a56:	cmp    $0xd,%rcx
    8a5a:	cmovl  0x1b7e(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    8a62:	cmp    $0x6,%rax
    8a66:	je     8db9 <botlish_fn_37+0x6431>
    8a6c:	mov    %rsi,%rcx
    8a6f:	shl    $1,%rcx
    8a72:	mov    %rsi,%r14
    8a75:	or     $0x1,%rcx
    8a79:	mov    $0x2,%eax
    8a7e:	cmp    $0xd,%rcx
    8a82:	cmove  0x1b56(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    8a8a:	cmp    $0x6,%rax
    8a8e:	je     8d72 <botlish_fn_37+0x63ea>
    8a94:	mov    0x660(%rsp),%rcx
    8a9c:	test   $0x1,%rcx
    8aa3:	jne    8ada <botlish_fn_37+0x6152>
    8aa9:	mov    $0xffffffffffffffff,%rdx
    8ab0:	mov    0x660(%rsp),%rsi
    8ab8:	mov    0x520(%rsp),%rdi
    8ac0:	call   8ac5 <botlish_fn_37+0x613d>
			8ac1: R_X86_64_PLT32	rt_int_cmp-0x4
    8ac5:	mov    $0x2,%esi
    8aca:	test   %rax,%rax
    8acd:	cmove  0x1b0b(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    8ad5:	jmp    8af3 <botlish_fn_37+0x616b>
    8ada:	mov    $0x2,%esi
    8adf:	mov    0x660(%rsp),%rcx
    8ae7:	cmp    $0xffffffffffffffff,%rcx
    8aeb:	cmove  0x1aed(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    8af3:	cmp    $0x6,%rsi
    8af7:	je     8b78 <botlish_fn_37+0x61f0>
    8afd:	mov    0x520(%rsp),%rdi
    8b05:	mov    0x10(%rdi),%rax
    8b09:	mov    0x248(%rax),%rbx
    8b10:	mov    $0x1,%r12d
    8b16:	mov    %r14,%rsi
    8b19:	shl    $1,%rsi
    8b1c:	or     $0x1,%rsi
    8b20:	call   8b25 <botlish_fn_37+0x619d>
			8b21: R_X86_64_PLT32	botlish_fn_5-0x4
    8b25:	mov    0x520(%rsp),%rdi
    8b2d:	mov    0x10(%rdi),%rcx
    8b31:	mov    0x258(%rcx),%rdx
    8b38:	lea    0x370(%rsp),%r9
    8b40:	mov    %rbx,0x370(%rsp)
    8b48:	mov    %rax,0x378(%rsp)
    8b50:	mov    0x660(%rsp),%rcx
    8b58:	mov    %rcx,0x380(%rsp)
    8b60:	mov    $0x4,%ecx
    8b65:	mov    $0x3,%r8d
    8b6b:	mov    %r12,%rsi
    8b6e:	call   8b73 <botlish_fn_37+0x61eb>
			8b6f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8b73:	jmp    8be0 <botlish_fn_37+0x6258>
    8b78:	mov    %r14,%rsi
    8b7b:	mov    0x520(%rsp),%rdi
    8b83:	mov    0x10(%rdi),%rdi
    8b87:	mov    0x248(%rdi),%rbx
    8b8e:	shl    $1,%rsi
    8b91:	or     $0x1,%rsi
    8b95:	mov    0x520(%rsp),%rdi
    8b9d:	call   8ba2 <botlish_fn_37+0x621a>
			8b9e: R_X86_64_PLT32	botlish_fn_5-0x4
    8ba2:	mov    0x520(%rsp),%rdi
    8baa:	mov    0x10(%rdi),%rsi
    8bae:	mov    0x250(%rsi),%rdx
    8bb5:	lea    0x360(%rsp),%r9
    8bbd:	mov    %rbx,0x360(%rsp)
    8bc5:	mov    %rax,0x368(%rsp)
    8bcd:	mov    $0x2,%r8d
    8bd3:	mov    $0x5,%ecx
    8bd8:	mov    %r8,%rsi
    8bdb:	call   8be0 <botlish_fn_37+0x6258>
			8bdc: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8be0:	mov    0x520(%rsp),%rdi
    8be8:	call   8bed <botlish_fn_37+0x6265>
			8be9: R_X86_64_PLT32	rt_co_failed-0x4
    8bed:	mov    %rax,0x120(%rsp)
    8bf5:	mov    %rax,%rsi
    8bf8:	mov    0x520(%rsp),%rdi
    8c00:	call   8c05 <botlish_fn_37+0x627d>
			8c01: R_X86_64_PLT32	rt_co_resume0-0x4
    8c05:	test   %rax,%rax
    8c08:	je     8c2a <botlish_fn_37+0x62a2>
    8c0e:	mov    0x520(%rsp),%rdi
    8c16:	mov    0x10(%rdi),%r11
    8c1a:	mov    0x48(%r11),%rsi
    8c1e:	mov    0x218(%r11),%rdx
    8c25:	call   8c2a <botlish_fn_37+0x62a2>
			8c26: R_X86_64_PLT32	rt_raise-0x4
    8c2a:	mov    0x520(%rsp),%rdi
    8c32:	call   8c37 <botlish_fn_37+0x62af>
			8c33: R_X86_64_PLT32	rt_declared_error-0x4
    8c37:	cmp    $0x1,%rax
    8c3b:	je     8ce5 <botlish_fn_37+0x635d>
    8c41:	mov    0x520(%rsp),%rdi
    8c49:	call   8c4e <botlish_fn_37+0x62c6>
			8c4a: R_X86_64_PLT32	rt_declared_error-0x4
    8c4e:	cmp    $0x2,%rax
    8c52:	jne    a46f <botlish_fn_37+0x7ae7>
    8c58:	xor    %rbx,%rbx
    8c5b:	mov    %rbx,%rsi
    8c5e:	mov    0x520(%rsp),%rdi
    8c66:	call   8c6b <botlish_fn_37+0x62e3>
			8c67: R_X86_64_PLT32	rt_declared_payload-0x4
    8c6b:	mov    %rax,%r12
    8c6e:	mov    $0x1,%esi
    8c73:	mov    0x520(%rsp),%rdi
    8c7b:	call   8c80 <botlish_fn_37+0x62f8>
			8c7c: R_X86_64_PLT32	rt_declared_payload-0x4
    8c80:	mov    %rax,%r13
    8c83:	mov    0x520(%rsp),%rdi
    8c8b:	call   8c90 <botlish_fn_37+0x6308>
			8c8c: R_X86_64_PLT32	rt_clear_declared_error-0x4
    8c90:	mov    0x520(%rsp),%rdi
    8c98:	mov    0x10(%rdi),%rax
    8c9c:	mov    0x220(%rax),%rdx
    8ca3:	lea    0x198(%rsp),%r9
    8cab:	movq   $0x1,0x198(%rsp)
    8cb7:	mov    %r12,%rax
    8cba:	mov    %rax,0x1a0(%rsp)
    8cc2:	mov    %r13,%rax
    8cc5:	mov    %rax,0x1a8(%rsp)
    8ccd:	mov    $0xc,%esi
    8cd2:	mov    $0x3,%r8d
    8cd8:	mov    %rbx,%rcx
    8cdb:	call   8ce0 <botlish_fn_37+0x6358>
			8cdc: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8ce0:	jmp    a46f <botlish_fn_37+0x7ae7>
    8ce5:	xor    %rbx,%rbx
    8ce8:	mov    %rbx,%rsi
    8ceb:	mov    0x520(%rsp),%rdi
    8cf3:	call   8cf8 <botlish_fn_37+0x6370>
			8cf4: R_X86_64_PLT32	rt_declared_payload-0x4
    8cf8:	mov    %rax,%r12
    8cfb:	mov    $0x1,%esi
    8d00:	mov    0x520(%rsp),%rdi
    8d08:	call   8d0d <botlish_fn_37+0x6385>
			8d09: R_X86_64_PLT32	rt_declared_payload-0x4
    8d0d:	mov    %rax,%r13
    8d10:	mov    0x520(%rsp),%rdi
    8d18:	call   8d1d <botlish_fn_37+0x6395>
			8d19: R_X86_64_PLT32	rt_clear_declared_error-0x4
    8d1d:	mov    0x520(%rsp),%rdi
    8d25:	mov    0x10(%rdi),%rax
    8d29:	mov    0x220(%rax),%rdx
    8d30:	lea    0x180(%rsp),%r9
    8d38:	movq   $0x1,0x180(%rsp)
    8d44:	mov    %r12,%rax
    8d47:	mov    %rax,0x188(%rsp)
    8d4f:	mov    %r13,%rax
    8d52:	mov    %rax,0x190(%rsp)
    8d5a:	mov    $0xc,%esi
    8d5f:	mov    $0x3,%r8d
    8d65:	mov    %rbx,%rcx
    8d68:	call   8d6d <botlish_fn_37+0x63e5>
			8d69: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    8d6d:	jmp    a46f <botlish_fn_37+0x7ae7>
    8d72:	mov    $0x3,%r14d
    8d78:	mov    %r14,0x688(%rsp)
    8d80:	movq   $0x3,0x130(%rsp)
    8d8c:	mov    $0x1,%r14d
    8d92:	movq   $0x1,0x118(%rsp)
    8d9e:	mov    $0x2,%r12d
    8da4:	mov    0x538(%rsp),%rax
    8dac:	mov    %rax,0x660(%rsp)
    8db4:	jmp    8df0 <botlish_fn_37+0x6468>
    8db9:	shl    $1,%rsi
    8dbc:	or     $0x1,%rsi
    8dc0:	mov    %rsi,0x138(%rsp)
    8dc8:	mov    $0x1,%r14d
    8dce:	movq   $0x1,0x118(%rsp)
    8dda:	mov    %r14,%r12
    8ddd:	mov    %rsi,%r13
    8de0:	mov    0x538(%rsp),%rax
    8de8:	mov    %rax,0x660(%rsp)
    8df0:	mov    0x6d0(%rsp),%r10
    8df8:	mov    0x18(%r10),%rcx
    8dfc:	test   %rcx,%rcx
    8dff:	je     a5b9 <botlish_fn_37+0x7c31>
    8e05:	mov    0x6d0(%rsp),%rax
    8e0d:	mov    0x10(%rax),%rax
    8e11:	mov    0x660(%rsp),%rcx
    8e19:	mov    %rcx,0x10(%rax)
    8e1d:	mov    %r14,0x528(%rsp)
    8e25:	mov    %r12,0x530(%rsp)
    8e2d:	mov    0x5d8(%rsp),%rax
    8e35:	mov    %rax,0x660(%rsp)
    8e3d:	mov    %r13,0x670(%rsp)
    8e45:	mov    %rbx,0x678(%rsp)
    8e4d:	jmp    4b4d <botlish_fn_37+0x21c5>
    8e52:	mov    0x678(%rsp),%rbx
    8e5a:	mov    0x530(%rsp),%r12
    8e62:	mov    0x670(%rsp),%r13
    8e6a:	mov    0x528(%rsp),%r14
    8e72:	cmp    $0x1,%r12
    8e76:	je     9fcb <botlish_fn_37+0x7643>
    8e7c:	cmp    $0x2,%r12
    8e80:	je     8f15 <botlish_fn_37+0x658d>
    8e86:	cmp    $0x3,%r12
    8e8a:	je     8efe <botlish_fn_37+0x6576>
    8e90:	cmp    $0x4,%r12
    8e94:	je     8ed7 <botlish_fn_37+0x654f>
    8e9a:	cmp    $0x5,%r12
    8e9e:	je     8eb8 <botlish_fn_37+0x6530>
    8ea4:	mov    $0xa,%esi
    8ea9:	cmp    $0xffffffffffffffff,%r12
    8ead:	je     a41c <botlish_fn_37+0x7a94>
    8eb3:	jmp    a25e <botlish_fn_37+0x78d6>
    8eb8:	mov    0x668(%rsp),%rsi
    8ec0:	sar    $1,%rsi
    8ec3:	mov    %rsi,0x668(%rsp)
    8ecb:	mov    $0xffffffffffffffff,%r15
    8ed2:	jmp    93ab <botlish_fn_37+0x6a23>
    8ed7:	mov    0x680(%rsp),%rbx
    8edf:	sar    $1,%rbx
    8ee2:	mov    %rbx,0x680(%rsp)
    8eea:	mov    $0xffffffffffffffff,%r15
    8ef1:	mov    0x520(%rsp),%rdi
    8ef9:	jmp    9986 <botlish_fn_37+0x6ffe>
    8efe:	sar    $1,%rbx
    8f01:	mov    $0xffffffffffffffff,%r15
    8f08:	mov    0x520(%rsp),%rdi
    8f10:	jmp    9c77 <botlish_fn_37+0x72ef>
    8f15:	mov    0x688(%rsp),%r14
    8f1d:	sar    $1,%r14
    8f20:	mov    %r14,0x688(%rsp)
    8f28:	mov    $0xffffffffffffffff,%r15
    8f2f:	shl    $1,%r14
    8f32:	mov    %r14,0x688(%rsp)
    8f3a:	or     $0x1,%r14
    8f3e:	mov    %r14,0x688(%rsp)
    8f46:	sar    $1,%r14
    8f49:	mov    %r14,%rax
    8f4c:	mov    %r14,0x688(%rsp)
    8f54:	test   %rax,%r14
    8f57:	jle    90a5 <botlish_fn_37+0x671d>
    8f5d:	mov    0x688(%rsp),%r14
    8f65:	cmp    $0x2,%r14
    8f69:	jl     8f7c <botlish_fn_37+0x65f4>
    8f6f:	mov    0x520(%rsp),%rdi
    8f77:	jmp    9f9c <botlish_fn_37+0x7614>
    8f7c:	test   $0x1,%r15
    8f83:	jne    8fb3 <botlish_fn_37+0x662b>
    8f89:	mov    $0x41,%edx
    8f8e:	mov    %r15,%rsi
    8f91:	mov    0x520(%rsp),%rdi
    8f99:	call   8f9e <botlish_fn_37+0x6616>
			8f9a: R_X86_64_PLT32	rt_int_cmp-0x4
    8f9e:	mov    $0x2,%ecx
    8fa3:	test   %rax,%rax
    8fa6:	cmovl  0x1632(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    8fae:	jmp    8fc4 <botlish_fn_37+0x663c>
    8fb3:	mov    $0x2,%ecx
    8fb8:	cmp    $0x41,%r15
    8fbc:	cmovl  0x161c(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    8fc4:	cmp    $0x6,%rcx
    8fc8:	je     909b <botlish_fn_37+0x6713>
    8fce:	test   $0x1,%r15
    8fd5:	jne    9005 <botlish_fn_37+0x667d>
    8fdb:	mov    $0x21ffff,%edx
    8fe0:	mov    %r15,%rsi
    8fe3:	mov    0x520(%rsp),%rdi
    8feb:	call   8ff0 <botlish_fn_37+0x6668>
			8fec: R_X86_64_PLT32	rt_int_cmp-0x4
    8ff0:	mov    $0x2,%ecx
    8ff5:	test   %rax,%rax
    8ff8:	cmovg  0x15e0(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9000:	jmp    9019 <botlish_fn_37+0x6691>
    9005:	mov    $0x2,%ecx
    900a:	cmp    $0x21ffff,%r15
    9011:	cmovg  0x15c7(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9019:	cmp    $0x6,%rcx
    901d:	je     909b <botlish_fn_37+0x6713>
    9023:	mov    %r15,%rcx
    9026:	sar    $1,%rcx
    9029:	cmp    $0x5c,%rcx
    902d:	jl     9073 <botlish_fn_37+0x66eb>
    9033:	cmp    $0xd800,%rcx
    903a:	jl     905f <botlish_fn_37+0x66d7>
    9040:	cmp    $0xe000,%rcx
    9047:	jl     909b <botlish_fn_37+0x6713>
    904d:	cmp    $0x110000,%rcx
    9054:	jge    909b <botlish_fn_37+0x6713>
    905a:	jmp    917c <botlish_fn_37+0x67f4>
    905f:	cmp    $0x5d,%rcx
    9063:	jge    917c <botlish_fn_37+0x67f4>
    9069:	mov    $0x3,%esi
    906e:	jmp    918b <botlish_fn_37+0x6803>
    9073:	cmp    $0x22,%rcx
    9077:	jl     9091 <botlish_fn_37+0x6709>
    907d:	cmp    $0x23,%rcx
    9081:	jge    917c <botlish_fn_37+0x67f4>
    9087:	mov    $0x2,%esi
    908c:	jmp    918b <botlish_fn_37+0x6803>
    9091:	cmp    $0x20,%rcx
    9095:	jge    917c <botlish_fn_37+0x67f4>
    909b:	mov    $0x5,%esi
    90a0:	jmp    918b <botlish_fn_37+0x6803>
    90a5:	mov    0x688(%rsp),%rax
    90ad:	mov    0x688(%rsp),%r14
    90b5:	test   %rax,%r14
    90b8:	jl     9f94 <botlish_fn_37+0x760c>
    90be:	test   $0x1,%r15
    90c5:	jne    90f5 <botlish_fn_37+0x676d>
    90cb:	mov    $0x45,%edx
    90d0:	mov    %r15,%rsi
    90d3:	mov    0x520(%rsp),%rdi
    90db:	call   90e0 <botlish_fn_37+0x6758>
			90dc: R_X86_64_PLT32	rt_int_cmp-0x4
    90e0:	mov    $0x2,%ecx
    90e5:	test   %rax,%rax
    90e8:	cmovl  0x14f0(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    90f0:	jmp    9106 <botlish_fn_37+0x677e>
    90f5:	mov    $0x2,%ecx
    90fa:	cmp    $0x45,%r15
    90fe:	cmovl  0x14da(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9106:	cmp    $0x6,%rcx
    910a:	je     9186 <botlish_fn_37+0x67fe>
    9110:	test   $0x1,%r15
    9117:	jne    9147 <botlish_fn_37+0x67bf>
    911d:	mov    $0x45,%edx
    9122:	mov    %r15,%rsi
    9125:	mov    0x520(%rsp),%rdi
    912d:	call   9132 <botlish_fn_37+0x67aa>
			912e: R_X86_64_PLT32	rt_int_cmp-0x4
    9132:	mov    $0x2,%ecx
    9137:	test   %rax,%rax
    913a:	cmovg  0x149e(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9142:	jmp    9158 <botlish_fn_37+0x67d0>
    9147:	mov    $0x2,%ecx
    914c:	cmp    $0x45,%r15
    9150:	cmovg  0x1488(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9158:	cmp    $0x6,%rcx
    915c:	je     9186 <botlish_fn_37+0x67fe>
    9162:	mov    %r15,%r11
    9165:	sar    $1,%r11
    9168:	cmp    $0x22,%r11
    916c:	jl     9186 <botlish_fn_37+0x67fe>
    9172:	cmp    $0x23,%r11
    9176:	jge    9186 <botlish_fn_37+0x67fe>
    917c:	mov    $0x1,%esi
    9181:	jmp    918b <botlish_fn_37+0x6803>
    9186:	mov    $0x4,%esi
    918b:	mov    %rsi,%rcx
    918e:	shl    $1,%rcx
    9191:	or     $0x1,%rcx
    9195:	mov    $0x2,%eax
    919a:	cmp    $0x5,%rcx
    919e:	cmovl  0x143a(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    91a6:	cmp    $0x6,%rax
    91aa:	je     9f80 <botlish_fn_37+0x75f8>
    91b0:	mov    %rsi,%rcx
    91b3:	shl    $1,%rcx
    91b6:	or     $0x1,%rcx
    91ba:	mov    $0x2,%eax
    91bf:	cmp    $0x5,%rcx
    91c3:	cmove  0x1415(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    91cb:	cmp    $0x6,%rax
    91cf:	je     9338 <botlish_fn_37+0x69b0>
    91d5:	mov    %rsi,%rcx
    91d8:	shl    $1,%rcx
    91db:	mov    %rsi,%r13
    91de:	or     $0x1,%rcx
    91e2:	mov    $0x2,%eax
    91e7:	cmp    $0x7,%rcx
    91eb:	cmove  0x13ed(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    91f3:	cmp    $0x6,%rax
    91f7:	je     9328 <botlish_fn_37+0x69a0>
    91fd:	test   $0x1,%r15
    9204:	jne    9236 <botlish_fn_37+0x68ae>
    920a:	mov    $0xffffffffffffffff,%rdx
    9211:	mov    %r15,%rsi
    9214:	mov    0x520(%rsp),%rdi
    921c:	call   9221 <botlish_fn_37+0x6899>
			921d: R_X86_64_PLT32	rt_int_cmp-0x4
    9221:	mov    $0x2,%edx
    9226:	test   %rax,%rax
    9229:	cmove  0x13af(%rip),%rdx        # a5e0 <botlish_fn_37+0x7c58>
    9231:	jmp    9247 <botlish_fn_37+0x68bf>
    9236:	mov    $0x2,%edx
    923b:	cmp    $0xffffffffffffffff,%r15
    923f:	cmove  0x1399(%rip),%rdx        # a5e0 <botlish_fn_37+0x7c58>
    9247:	cmp    $0x6,%rdx
    924b:	je     92c3 <botlish_fn_37+0x693b>
    9251:	mov    0x520(%rsp),%rdi
    9259:	mov    0x10(%rdi),%rax
    925d:	mov    0x260(%rax),%r12
    9264:	mov    $0x1,%ebx
    9269:	mov    %r13,%rsi
    926c:	shl    $1,%rsi
    926f:	or     $0x1,%rsi
    9273:	call   9278 <botlish_fn_37+0x68f0>
			9274: R_X86_64_PLT32	botlish_fn_7-0x4
    9278:	mov    0x520(%rsp),%rdi
    9280:	mov    0x10(%rdi),%rcx
    9284:	mov    0x258(%rcx),%rdx
    928b:	lea    0x478(%rsp),%r9
    9293:	mov    %r12,0x478(%rsp)
    929b:	mov    %rax,0x480(%rsp)
    92a3:	mov    %r15,0x488(%rsp)
    92ab:	mov    $0x4,%ecx
    92b0:	mov    $0x3,%r8d
    92b6:	mov    %rbx,%rsi
    92b9:	call   92be <botlish_fn_37+0x6936>
			92ba: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    92be:	jmp    a246 <botlish_fn_37+0x78be>
    92c3:	mov    %r13,%rsi
    92c6:	mov    0x520(%rsp),%rdi
    92ce:	mov    0x10(%rdi),%rax
    92d2:	mov    0x260(%rax),%rbx
    92d9:	shl    $1,%rsi
    92dc:	or     $0x1,%rsi
    92e0:	call   92e5 <botlish_fn_37+0x695d>
			92e1: R_X86_64_PLT32	botlish_fn_7-0x4
    92e5:	mov    0x520(%rsp),%rdi
    92ed:	mov    0x10(%rdi),%rcx
    92f1:	mov    0x250(%rcx),%rdx
    92f8:	lea    0x468(%rsp),%r9
    9300:	mov    %rbx,0x468(%rsp)
    9308:	mov    %rax,0x470(%rsp)
    9310:	mov    $0x2,%r8d
    9316:	mov    $0x5,%ecx
    931b:	mov    %r8,%rsi
    931e:	call   9323 <botlish_fn_37+0x699b>
			931f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9323:	jmp    a246 <botlish_fn_37+0x78be>
    9328:	xor    %r13,%r13
    932b:	mov    0x520(%rsp),%rdi
    9333:	jmp    9fdd <botlish_fn_37+0x7655>
    9338:	mov    $0xfffffffffffffffd,%r15
    933f:	test   $0x1,%r15
    9346:	jne    9379 <botlish_fn_37+0x69f1>
    934c:	mov    $0xfffffffffffffffd,%rdx
    9353:	mov    %r15,%rsi
    9356:	mov    0x520(%rsp),%rdi
    935e:	call   9363 <botlish_fn_37+0x69db>
			935f: R_X86_64_PLT32	rt_int_cmp-0x4
    9363:	mov    $0x2,%r11d
    9369:	test   %rax,%rax
    936c:	cmove  0x126c(%rip),%r11        # a5e0 <botlish_fn_37+0x7c58>
    9374:	jmp    938b <botlish_fn_37+0x6a03>
    9379:	mov    $0x2,%r11d
    937f:	cmp    $0xfffffffffffffffd,%r15
    9383:	cmove  0x1255(%rip),%r11        # a5e0 <botlish_fn_37+0x7c58>
    938b:	cmp    $0x6,%r11
    938f:	je     9f5d <botlish_fn_37+0x75d5>
    9395:	mov    %rsi,%r10
    9398:	mov    %rsi,0x668(%rsp)
    93a0:	xor    %r10,%rsi
    93a3:	mov    %rsi,0x668(%rsp)
    93ab:	test   $0x1,%r15
    93b2:	jne    93e4 <botlish_fn_37+0x6a5c>
    93b8:	mov    $0xffffffffffffffff,%rdx
    93bf:	mov    %r15,%rsi
    93c2:	mov    0x520(%rsp),%rdi
    93ca:	call   93cf <botlish_fn_37+0x6a47>
			93cb: R_X86_64_PLT32	rt_int_cmp-0x4
    93cf:	mov    $0x2,%ecx
    93d4:	test   %rax,%rax
    93d7:	cmovl  0x1201(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    93df:	jmp    93f5 <botlish_fn_37+0x6a6d>
    93e4:	mov    $0x2,%ecx
    93e9:	cmp    $0xffffffffffffffff,%r15
    93ed:	cmovl  0x11eb(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    93f5:	cmp    $0x6,%rcx
    93f9:	je     95ff <botlish_fn_37+0x6c77>
    93ff:	test   $0x1,%r15
    9406:	jne    9436 <botlish_fn_37+0x6aae>
    940c:	mov    $0x21ffff,%edx
    9411:	mov    %r15,%rsi
    9414:	mov    0x520(%rsp),%rdi
    941c:	call   9421 <botlish_fn_37+0x6a99>
			941d: R_X86_64_PLT32	rt_int_cmp-0x4
    9421:	mov    $0x2,%ecx
    9426:	test   %rax,%rax
    9429:	cmovg  0x11af(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9431:	jmp    944a <botlish_fn_37+0x6ac2>
    9436:	mov    $0x2,%ecx
    943b:	cmp    $0x21ffff,%r15
    9442:	cmovg  0x1196(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    944a:	cmp    $0x6,%rcx
    944e:	je     95ff <botlish_fn_37+0x6c77>
    9454:	mov    %r15,%rcx
    9457:	sar    $1,%rcx
    945a:	cmp    $0x5c,%rcx
    945e:	jl     952b <botlish_fn_37+0x6ba3>
    9464:	cmp    $0x75,%rcx
    9468:	jl     94d1 <botlish_fn_37+0x6b49>
    946e:	cmp    $0x7e,%rcx
    9472:	jl     94a9 <botlish_fn_37+0x6b21>
    9478:	cmp    $0xe000,%rcx
    947f:	jl     9497 <botlish_fn_37+0x6b0f>
    9485:	cmp    $0x110000,%rcx
    948c:	jge    95ff <botlish_fn_37+0x6c77>
    9492:	jmp    95e1 <botlish_fn_37+0x6c59>
    9497:	cmp    $0xd800,%rcx
    949e:	jge    95ff <botlish_fn_37+0x6c77>
    94a4:	jmp    95e1 <botlish_fn_37+0x6c59>
    94a9:	cmp    $0x7c,%rcx
    94ad:	jl     94c2 <botlish_fn_37+0x6b3a>
    94b3:	cmp    $0x7d,%rcx
    94b7:	jge    958a <botlish_fn_37+0x6c02>
    94bd:	jmp    95e1 <botlish_fn_37+0x6c59>
    94c2:	cmp    $0x7b,%rcx
    94c6:	jge    958a <botlish_fn_37+0x6c02>
    94cc:	jmp    95e1 <botlish_fn_37+0x6c59>
    94d1:	cmp    $0x67,%rcx
    94d5:	jl     9503 <botlish_fn_37+0x6b7b>
    94db:	cmp    $0x6f,%rcx
    94df:	jl     94f4 <botlish_fn_37+0x6b6c>
    94e5:	cmp    $0x74,%rcx
    94e9:	jge    958a <botlish_fn_37+0x6c02>
    94ef:	jmp    95e1 <botlish_fn_37+0x6c59>
    94f4:	cmp    $0x6e,%rcx
    94f8:	jge    958a <botlish_fn_37+0x6c02>
    94fe:	jmp    95e1 <botlish_fn_37+0x6c59>
    9503:	cmp    $0x5e,%rcx
    9507:	jl     951c <botlish_fn_37+0x6b94>
    950d:	cmp    $0x66,%rcx
    9511:	jge    958a <botlish_fn_37+0x6c02>
    9517:	jmp    95e1 <botlish_fn_37+0x6c59>
    951c:	cmp    $0x5d,%rcx
    9520:	jge    958a <botlish_fn_37+0x6c02>
    9526:	jmp    95e1 <botlish_fn_37+0x6c59>
    952b:	cmp    $0x21,%rcx
    952f:	jl     9594 <botlish_fn_37+0x6c0c>
    9535:	cmp    $0x2e,%rcx
    9539:	jl     9567 <botlish_fn_37+0x6bdf>
    953f:	cmp    $0x3b,%rcx
    9543:	jl     9558 <botlish_fn_37+0x6bd0>
    9549:	cmp    $0x5b,%rcx
    954d:	jge    958a <botlish_fn_37+0x6c02>
    9553:	jmp    95e1 <botlish_fn_37+0x6c59>
    9558:	cmp    $0x30,%rcx
    955c:	jge    958a <botlish_fn_37+0x6c02>
    9562:	jmp    95e1 <botlish_fn_37+0x6c59>
    9567:	cmp    $0x23,%rcx
    956b:	jl     9580 <botlish_fn_37+0x6bf8>
    9571:	cmp    $0x2c,%rcx
    9575:	jge    958a <botlish_fn_37+0x6c02>
    957b:	jmp    95e1 <botlish_fn_37+0x6c59>
    9580:	cmp    $0x22,%rcx
    9584:	jl     95e1 <botlish_fn_37+0x6c59>
    958a:	mov    $0x2,%esi
    958f:	jmp    9604 <botlish_fn_37+0x6c7c>
    9594:	cmp    $0xb,%rcx
    9598:	jl     95c6 <botlish_fn_37+0x6c3e>
    959e:	cmp    $0xe,%rcx
    95a2:	jl     95b7 <botlish_fn_37+0x6c2f>
    95a8:	cmp    $0x20,%rcx
    95ac:	jge    95d9 <botlish_fn_37+0x6c51>
    95b2:	jmp    95e1 <botlish_fn_37+0x6c59>
    95b7:	cmp    $0xd,%rcx
    95bb:	jge    95d9 <botlish_fn_37+0x6c51>
    95c1:	jmp    95e1 <botlish_fn_37+0x6c59>
    95c6:	test   %rcx,%rcx
    95c9:	jl     95eb <botlish_fn_37+0x6c63>
    95cf:	cmp    $0x9,%rcx
    95d3:	jl     95e1 <botlish_fn_37+0x6c59>
    95d9:	xor    %rsi,%rsi
    95dc:	jmp    9604 <botlish_fn_37+0x6c7c>
    95e1:	mov    $0x4,%esi
    95e6:	jmp    9604 <botlish_fn_37+0x6c7c>
    95eb:	cmp    $0xffffffffffffffff,%rcx
    95ef:	jl     95ff <botlish_fn_37+0x6c77>
    95f5:	mov    $0x1,%esi
    95fa:	jmp    9604 <botlish_fn_37+0x6c7c>
    95ff:	mov    $0x3,%esi
    9604:	mov    %rsi,%rcx
    9607:	shl    $1,%rcx
    960a:	or     $0x1,%rcx
    960e:	mov    $0x2,%eax
    9613:	cmp    $0x3,%rcx
    9617:	cmovl  0xfc1(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    961f:	cmp    $0x6,%rax
    9623:	je     9f49 <botlish_fn_37+0x75c1>
    9629:	mov    %rsi,%rax
    962c:	shl    $1,%rax
    962f:	or     $0x1,%rax
    9633:	mov    $0x2,%ecx
    9638:	cmp    $0x3,%rax
    963c:	cmove  0xf9c(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9644:	cmp    $0x6,%rcx
    9648:	je     9f32 <botlish_fn_37+0x75aa>
    964e:	mov    %rsi,%rdx
    9651:	shl    $1,%rdx
    9654:	or     $0x1,%rdx
    9658:	mov    $0x2,%r11d
    965e:	cmp    $0x5,%rdx
    9662:	cmove  0xf76(%rip),%r11        # a5e0 <botlish_fn_37+0x7c58>
    966a:	cmp    $0x6,%r11
    966e:	je     9700 <botlish_fn_37+0x6d78>
    9674:	mov    $0x1,%r12d
    967a:	shl    $1,%rsi
    967d:	or     $0x1,%rsi
    9681:	mov    %rsi,%rbx
    9684:	mov    0x520(%rsp),%rdi
    968c:	call   9691 <botlish_fn_37+0x6d09>
			968d: R_X86_64_PLT32	botlish_fn_10-0x4
    9691:	mov    %rbx,%rsi
    9694:	mov    %rax,%rbx
    9697:	mov    0x520(%rsp),%rdi
    969f:	call   96a4 <botlish_fn_37+0x6d1c>
			96a0: R_X86_64_PLT32	botlish_fn_11-0x4
    96a4:	mov    %rax,%rcx
    96a7:	mov    0x520(%rsp),%rdi
    96af:	mov    0x10(%rdi),%rdi
    96b3:	mov    0x258(%rdi),%rdx
    96ba:	lea    0x508(%rsp),%r9
    96c2:	mov    %rbx,%rax
    96c5:	mov    %rax,0x508(%rsp)
    96cd:	mov    %rcx,%rax
    96d0:	mov    %rax,0x510(%rsp)
    96d8:	mov    %r15,0x518(%rsp)
    96e0:	mov    $0x4,%ecx
    96e5:	mov    $0x3,%r8d
    96eb:	mov    %r12,%rsi
    96ee:	mov    0x520(%rsp),%rdi
    96f6:	call   96fb <botlish_fn_37+0x6d73>
			96f7: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    96fb:	jmp    a246 <botlish_fn_37+0x78be>
    9700:	mov    0x520(%rsp),%rdi
    9708:	mov    0x10(%rdi),%rax
    970c:	mov    0x238(%rax),%r12
    9713:	test   $0x1,%r15
    971a:	jne    974c <botlish_fn_37+0x6dc4>
    9720:	mov    $0xffffffffffffffff,%rdx
    9727:	mov    %r15,%rsi
    972a:	mov    0x520(%rsp),%rdi
    9732:	call   9737 <botlish_fn_37+0x6daf>
			9733: R_X86_64_PLT32	rt_int_cmp-0x4
    9737:	mov    $0x2,%ecx
    973c:	test   %rax,%rax
    973f:	cmovl  0xe99(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9747:	jmp    975d <botlish_fn_37+0x6dd5>
    974c:	mov    $0x2,%ecx
    9751:	cmp    $0xffffffffffffffff,%r15
    9755:	cmovl  0xe83(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    975d:	cmp    $0x6,%rcx
    9761:	je     97cd <botlish_fn_37+0x6e45>
    9767:	test   $0x1,%r15
    976e:	jne    979e <botlish_fn_37+0x6e16>
    9774:	mov    $0x1ff,%edx
    9779:	mov    %r15,%rsi
    977c:	mov    0x520(%rsp),%rdi
    9784:	call   9789 <botlish_fn_37+0x6e01>
			9785: R_X86_64_PLT32	rt_int_cmp-0x4
    9789:	mov    $0x2,%ecx
    978e:	test   %rax,%rax
    9791:	cmovg  0xe47(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9799:	jmp    97b2 <botlish_fn_37+0x6e2a>
    979e:	mov    $0x2,%ecx
    97a3:	cmp    $0x1ff,%r15
    97aa:	cmovg  0xe2e(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    97b2:	cmp    $0x6,%rcx
    97b6:	je     97cd <botlish_fn_37+0x6e45>
    97bc:	mov    %r15,%rax
    97bf:	sar    $1,%rax
    97c2:	movzbq 0x11(%r12,%rax,1),%rcx
    97c8:	jmp    97d6 <botlish_fn_37+0x6e4e>
    97cd:	movzbq 0x111(%r12),%rcx
    97d6:	mov    %rcx,%rdx
    97d9:	shl    $1,%rdx
    97dc:	or     $0x1,%rdx
    97e0:	mov    $0x2,%eax
    97e5:	cmp    $0x3,%rdx
    97e9:	cmove  0xdef(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    97f1:	cmp    $0x6,%rax
    97f5:	je     9f26 <botlish_fn_37+0x759e>
    97fb:	mov    %rcx,%rdx
    97fe:	shl    $1,%rdx
    9801:	or     $0x1,%rdx
    9805:	mov    $0x2,%eax
    980a:	cmp    $0x5,%rdx
    980e:	cmove  0xdca(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    9816:	cmp    $0x6,%rax
    981a:	je     9f0b <botlish_fn_37+0x7583>
    9820:	mov    %rcx,%rdx
    9823:	shl    $1,%rdx
    9826:	or     $0x1,%rdx
    982a:	mov    $0x2,%eax
    982f:	cmp    $0x7,%rdx
    9833:	cmove  0xda5(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    983b:	cmp    $0x6,%rax
    983f:	je     9c6c <botlish_fn_37+0x72e4>
    9845:	shl    $1,%rcx
    9848:	or     $0x1,%rcx
    984c:	mov    $0x2,%r8d
    9852:	cmp    $0x9,%rcx
    9856:	cmove  0xd82(%rip),%r8        # a5e0 <botlish_fn_37+0x7c58>
    985e:	cmp    $0x6,%r8
    9862:	je     9968 <botlish_fn_37+0x6fe0>
    9868:	test   $0x1,%r15
    986f:	jne    98a1 <botlish_fn_37+0x6f19>
    9875:	mov    $0xffffffffffffffff,%rdx
    987c:	mov    %r15,%rsi
    987f:	mov    0x520(%rsp),%rdi
    9887:	call   988c <botlish_fn_37+0x6f04>
			9888: R_X86_64_PLT32	rt_int_cmp-0x4
    988c:	mov    $0x2,%ecx
    9891:	test   %rax,%rax
    9894:	cmove  0xd44(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    989c:	jmp    98b2 <botlish_fn_37+0x6f2a>
    98a1:	mov    $0x2,%ecx
    98a6:	cmp    $0xffffffffffffffff,%r15
    98aa:	cmove  0xd2e(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    98b2:	cmp    $0x6,%rcx
    98b6:	je     9913 <botlish_fn_37+0x6f8b>
    98bc:	mov    0x520(%rsp),%rdi
    98c4:	mov    0x10(%rdi),%rdx
    98c8:	mov    0x118(%rdx),%rax
    98cf:	mov    (%rdx),%rcx
    98d2:	mov    0x258(%rdx),%rdx
    98d9:	lea    0x4f0(%rsp),%r9
    98e1:	mov    %rax,0x4f0(%rsp)
    98e9:	mov    %rcx,0x4f8(%rsp)
    98f1:	mov    %r15,0x500(%rsp)
    98f9:	mov    $0x1,%esi
    98fe:	mov    $0x4,%ecx
    9903:	mov    $0x3,%r8d
    9909:	call   990e <botlish_fn_37+0x6f86>
			990a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    990e:	jmp    a246 <botlish_fn_37+0x78be>
    9913:	mov    0x520(%rsp),%rdi
    991b:	mov    0x10(%rdi),%rdx
    991f:	mov    0x118(%rdx),%rsi
    9926:	mov    (%rdx),%rdi
    9929:	mov    0x250(%rdx),%rdx
    9930:	lea    0x4e0(%rsp),%r9
    9938:	mov    %rsi,0x4e0(%rsp)
    9940:	mov    %rdi,0x4e8(%rsp)
    9948:	mov    $0x2,%r8d
    994e:	mov    $0x5,%ecx
    9953:	mov    0x520(%rsp),%rdi
    995b:	mov    %r8,%rsi
    995e:	call   9963 <botlish_fn_37+0x6fdb>
			995f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9963:	jmp    a246 <botlish_fn_37+0x78be>
    9968:	mov    %rbx,%rax
    996b:	mov    %rbx,0x680(%rsp)
    9973:	xor    %rax,%rbx
    9976:	mov    %rbx,0x680(%rsp)
    997e:	mov    0x520(%rsp),%rdi
    9986:	mov    0x520(%rsp),%rdi
    998e:	mov    0x10(%rdi),%rsi
    9992:	mov    0x278(%rsi),%r12
    9999:	test   $0x1,%r15
    99a0:	jne    99d2 <botlish_fn_37+0x704a>
    99a6:	mov    $0xffffffffffffffff,%rdx
    99ad:	mov    %r15,%rsi
    99b0:	mov    0x520(%rsp),%rdi
    99b8:	call   99bd <botlish_fn_37+0x7035>
			99b9: R_X86_64_PLT32	rt_int_cmp-0x4
    99bd:	mov    $0x2,%edx
    99c2:	test   %rax,%rax
    99c5:	cmovl  0xc13(%rip),%rdx        # a5e0 <botlish_fn_37+0x7c58>
    99cd:	jmp    99e3 <botlish_fn_37+0x705b>
    99d2:	mov    $0x2,%edx
    99d7:	cmp    $0xffffffffffffffff,%r15
    99db:	cmovl  0xbfd(%rip),%rdx        # a5e0 <botlish_fn_37+0x7c58>
    99e3:	cmp    $0x6,%rdx
    99e7:	jne    99fa <botlish_fn_37+0x7072>
    99ed:	mov    0x680(%rsp),%rbx
    99f5:	jmp    9aa3 <botlish_fn_37+0x711b>
    99fa:	test   $0x1,%r15
    9a01:	jne    9a31 <botlish_fn_37+0x70a9>
    9a07:	mov    $0x1ff,%edx
    9a0c:	mov    %r15,%rsi
    9a0f:	mov    0x520(%rsp),%rdi
    9a17:	call   9a1c <botlish_fn_37+0x7094>
			9a18: R_X86_64_PLT32	rt_int_cmp-0x4
    9a1c:	mov    $0x2,%ecx
    9a21:	test   %rax,%rax
    9a24:	cmovg  0xbb4(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9a2c:	jmp    9a45 <botlish_fn_37+0x70bd>
    9a31:	mov    $0x2,%ecx
    9a36:	cmp    $0x1ff,%r15
    9a3d:	cmovg  0xb9b(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9a45:	cmp    $0x6,%rcx
    9a49:	jne    9a5c <botlish_fn_37+0x70d4>
    9a4f:	mov    0x680(%rsp),%rbx
    9a57:	jmp    9aa3 <botlish_fn_37+0x711b>
    9a5c:	mov    0x680(%rsp),%rbx
    9a64:	shl    $1,%rbx
    9a67:	mov    %rbx,0x680(%rsp)
    9a6f:	or     $0x1,%rbx
    9a73:	mov    %rbx,0x680(%rsp)
    9a7b:	sar    $1,%rbx
    9a7e:	mov    %rbx,0x680(%rsp)
    9a86:	imul   $0x101,%rbx,%rax
    9a8d:	mov    %r15,%rcx
    9a90:	sar    $1,%rcx
    9a93:	lea    0x1(%rax,%rcx,1),%rax
    9a98:	movzbq 0x10(%r12,%rax,1),%rsi
    9a9e:	jmp    9ace <botlish_fn_37+0x7146>
    9aa3:	shl    $1,%rbx
    9aa6:	mov    %rbx,0x680(%rsp)
    9aae:	or     $0x1,%rbx
    9ab2:	mov    %rbx,0x680(%rsp)
    9aba:	sar    $1,%rbx
    9abd:	mov    %rbx,0x680(%rsp)
    9ac5:	movzbq 0xc1c(%r12,%rbx,1),%rsi
    9ace:	mov    %rsi,%rcx
    9ad1:	shl    $1,%rcx
    9ad4:	or     $0x1,%rcx
    9ad8:	mov    $0x2,%eax
    9add:	cmp    $0x19,%rcx
    9ae1:	cmovl  0xaf7(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    9ae9:	cmp    $0x6,%rax
    9aed:	je     9c46 <botlish_fn_37+0x72be>
    9af3:	mov    %rsi,%rcx
    9af6:	shl    $1,%rcx
    9af9:	mov    %rsi,%r13
    9afc:	or     $0x1,%rcx
    9b00:	mov    $0x2,%eax
    9b05:	cmp    $0x19,%rcx
    9b09:	cmove  0xacf(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    9b11:	cmp    $0x6,%rax
    9b15:	je     933f <botlish_fn_37+0x69b7>
    9b1b:	test   $0x1,%r15
    9b22:	jne    9b54 <botlish_fn_37+0x71cc>
    9b28:	mov    $0xffffffffffffffff,%rdx
    9b2f:	mov    %r15,%rsi
    9b32:	mov    0x520(%rsp),%rdi
    9b3a:	call   9b3f <botlish_fn_37+0x71b7>
			9b3b: R_X86_64_PLT32	rt_int_cmp-0x4
    9b3f:	mov    $0x2,%esi
    9b44:	test   %rax,%rax
    9b47:	cmove  0xa91(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    9b4f:	jmp    9b65 <botlish_fn_37+0x71dd>
    9b54:	mov    $0x2,%esi
    9b59:	cmp    $0xffffffffffffffff,%r15
    9b5d:	cmove  0xa7b(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    9b65:	cmp    $0x6,%rsi
    9b69:	je     9be1 <botlish_fn_37+0x7259>
    9b6f:	mov    0x520(%rsp),%rdi
    9b77:	mov    0x10(%rdi),%rax
    9b7b:	mov    0x280(%rax),%r12
    9b82:	mov    $0x1,%ebx
    9b87:	mov    %r13,%rsi
    9b8a:	shl    $1,%rsi
    9b8d:	or     $0x1,%rsi
    9b91:	call   9b96 <botlish_fn_37+0x720e>
			9b92: R_X86_64_PLT32	botlish_fn_3-0x4
    9b96:	mov    0x520(%rsp),%rdi
    9b9e:	mov    0x10(%rdi),%rcx
    9ba2:	mov    0x258(%rcx),%rdx
    9ba9:	lea    0x4c8(%rsp),%r9
    9bb1:	mov    %r12,0x4c8(%rsp)
    9bb9:	mov    %rax,0x4d0(%rsp)
    9bc1:	mov    %r15,0x4d8(%rsp)
    9bc9:	mov    $0x4,%ecx
    9bce:	mov    $0x3,%r8d
    9bd4:	mov    %rbx,%rsi
    9bd7:	call   9bdc <botlish_fn_37+0x7254>
			9bd8: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9bdc:	jmp    a246 <botlish_fn_37+0x78be>
    9be1:	mov    %r13,%rsi
    9be4:	mov    0x520(%rsp),%rdi
    9bec:	mov    0x10(%rdi),%rax
    9bf0:	mov    0x280(%rax),%rbx
    9bf7:	shl    $1,%rsi
    9bfa:	or     $0x1,%rsi
    9bfe:	call   9c03 <botlish_fn_37+0x727b>
			9bff: R_X86_64_PLT32	botlish_fn_3-0x4
    9c03:	mov    0x520(%rsp),%rdi
    9c0b:	mov    0x10(%rdi),%rcx
    9c0f:	mov    0x250(%rcx),%rdx
    9c16:	lea    0x4b8(%rsp),%r9
    9c1e:	mov    %rbx,0x4b8(%rsp)
    9c26:	mov    %rax,0x4c0(%rsp)
    9c2e:	mov    $0x2,%r8d
    9c34:	mov    $0x5,%ecx
    9c39:	mov    %r8,%rsi
    9c3c:	call   9c41 <botlish_fn_37+0x72b9>
			9c3d: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9c41:	jmp    a246 <botlish_fn_37+0x78be>
    9c46:	shl    $1,%rsi
    9c49:	or     $0x1,%rsi
    9c4d:	mov    %rsi,0x148(%rsp)
    9c55:	mov    $0x1,%r14d
    9c5b:	movq   $0x1,0x118(%rsp)
    9c67:	jmp    a41c <botlish_fn_37+0x7a94>
    9c6c:	xor    %rbx,%rbx
    9c6f:	mov    0x520(%rsp),%rdi
    9c77:	mov    0x520(%rsp),%rdi
    9c7f:	mov    0x10(%rdi),%rax
    9c83:	mov    0x268(%rax),%r12
    9c8a:	test   $0x1,%r15
    9c91:	jne    9cc3 <botlish_fn_37+0x733b>
    9c97:	mov    $0xffffffffffffffff,%rdx
    9c9e:	mov    %r15,%rsi
    9ca1:	mov    0x520(%rsp),%rdi
    9ca9:	call   9cae <botlish_fn_37+0x7326>
			9caa: R_X86_64_PLT32	rt_int_cmp-0x4
    9cae:	mov    $0x2,%ecx
    9cb3:	test   %rax,%rax
    9cb6:	cmovl  0x922(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9cbe:	jmp    9cd4 <botlish_fn_37+0x734c>
    9cc3:	mov    $0x2,%ecx
    9cc8:	cmp    $0xffffffffffffffff,%r15
    9ccc:	cmovl  0x90c(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9cd4:	cmp    $0x6,%rcx
    9cd8:	je     9d5a <botlish_fn_37+0x73d2>
    9cde:	test   $0x1,%r15
    9ce5:	jne    9d15 <botlish_fn_37+0x738d>
    9ceb:	mov    $0x1ff,%edx
    9cf0:	mov    %r15,%rsi
    9cf3:	mov    0x520(%rsp),%rdi
    9cfb:	call   9d00 <botlish_fn_37+0x7378>
			9cfc: R_X86_64_PLT32	rt_int_cmp-0x4
    9d00:	mov    $0x2,%esi
    9d05:	test   %rax,%rax
    9d08:	cmovg  0x8d0(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    9d10:	jmp    9d29 <botlish_fn_37+0x73a1>
    9d15:	mov    $0x2,%esi
    9d1a:	cmp    $0x1ff,%r15
    9d21:	cmovg  0x8b7(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    9d29:	cmp    $0x6,%rsi
    9d2d:	je     9d5a <botlish_fn_37+0x73d2>
    9d33:	shl    $1,%rbx
    9d36:	or     $0x1,%rbx
    9d3a:	sar    $1,%rbx
    9d3d:	imul   $0x101,%rbx,%rax
    9d44:	mov    %r15,%rcx
    9d47:	sar    $1,%rcx
    9d4a:	lea    0x1(%rax,%rcx,1),%rax
    9d4f:	movzbq 0x10(%r12,%rax,1),%rsi
    9d55:	jmp    9d6d <botlish_fn_37+0x73e5>
    9d5a:	shl    $1,%rbx
    9d5d:	or     $0x1,%rbx
    9d61:	sar    $1,%rbx
    9d64:	movzbq 0x919(%r12,%rbx,1),%rsi
    9d6d:	mov    %rsi,%rcx
    9d70:	shl    $1,%rcx
    9d73:	or     $0x1,%rcx
    9d77:	mov    $0x2,%eax
    9d7c:	cmp    $0x13,%rcx
    9d80:	cmovl  0x858(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    9d88:	cmp    $0x6,%rax
    9d8c:	je     9ee5 <botlish_fn_37+0x755d>
    9d92:	mov    %rsi,%rcx
    9d95:	shl    $1,%rcx
    9d98:	mov    %rsi,%r13
    9d9b:	or     $0x1,%rcx
    9d9f:	mov    $0x2,%eax
    9da4:	cmp    $0x13,%rcx
    9da8:	cmove  0x830(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    9db0:	cmp    $0x6,%rax
    9db4:	je     933f <botlish_fn_37+0x69b7>
    9dba:	test   $0x1,%r15
    9dc1:	jne    9df3 <botlish_fn_37+0x746b>
    9dc7:	mov    $0xffffffffffffffff,%rdx
    9dce:	mov    %r15,%rsi
    9dd1:	mov    0x520(%rsp),%rdi
    9dd9:	call   9dde <botlish_fn_37+0x7456>
			9dda: R_X86_64_PLT32	rt_int_cmp-0x4
    9dde:	mov    $0x2,%ecx
    9de3:	test   %rax,%rax
    9de6:	cmove  0x7f2(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9dee:	jmp    9e04 <botlish_fn_37+0x747c>
    9df3:	mov    $0x2,%ecx
    9df8:	cmp    $0xffffffffffffffff,%r15
    9dfc:	cmove  0x7dc(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    9e04:	cmp    $0x6,%rcx
    9e08:	je     9e80 <botlish_fn_37+0x74f8>
    9e0e:	mov    0x520(%rsp),%rdi
    9e16:	mov    0x10(%rdi),%rax
    9e1a:	mov    0x270(%rax),%r12
    9e21:	mov    $0x1,%ebx
    9e26:	mov    %r13,%rsi
    9e29:	shl    $1,%rsi
    9e2c:	or     $0x1,%rsi
    9e30:	call   9e35 <botlish_fn_37+0x74ad>
			9e31: R_X86_64_PLT32	botlish_fn_1-0x4
    9e35:	mov    0x520(%rsp),%rdi
    9e3d:	mov    0x10(%rdi),%rcx
    9e41:	mov    0x258(%rcx),%rdx
    9e48:	lea    0x4a0(%rsp),%r9
    9e50:	mov    %r12,0x4a0(%rsp)
    9e58:	mov    %rax,0x4a8(%rsp)
    9e60:	mov    %r15,0x4b0(%rsp)
    9e68:	mov    $0x4,%ecx
    9e6d:	mov    $0x3,%r8d
    9e73:	mov    %rbx,%rsi
    9e76:	call   9e7b <botlish_fn_37+0x74f3>
			9e77: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9e7b:	jmp    a246 <botlish_fn_37+0x78be>
    9e80:	mov    %r13,%rsi
    9e83:	mov    0x520(%rsp),%rdi
    9e8b:	mov    0x10(%rdi),%rax
    9e8f:	mov    0x270(%rax),%rbx
    9e96:	shl    $1,%rsi
    9e99:	or     $0x1,%rsi
    9e9d:	call   9ea2 <botlish_fn_37+0x751a>
			9e9e: R_X86_64_PLT32	botlish_fn_1-0x4
    9ea2:	mov    0x520(%rsp),%rdi
    9eaa:	mov    0x10(%rdi),%rcx
    9eae:	mov    0x250(%rcx),%rdx
    9eb5:	lea    0x490(%rsp),%r9
    9ebd:	mov    %rbx,0x490(%rsp)
    9ec5:	mov    %rax,0x498(%rsp)
    9ecd:	mov    $0x2,%r8d
    9ed3:	mov    $0x5,%ecx
    9ed8:	mov    %r8,%rsi
    9edb:	call   9ee0 <botlish_fn_37+0x7558>
			9edc: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    9ee0:	jmp    a246 <botlish_fn_37+0x78be>
    9ee5:	shl    $1,%rsi
    9ee8:	or     $0x1,%rsi
    9eec:	mov    %rsi,0x140(%rsp)
    9ef4:	mov    $0x1,%r14d
    9efa:	movq   $0x1,0x118(%rsp)
    9f06:	jmp    a41c <botlish_fn_37+0x7a94>
    9f0b:	mov    %r14,%rax
    9f0e:	mov    %r14,0x688(%rsp)
    9f16:	xor    %rax,%r14
    9f19:	mov    %r14,0x688(%rsp)
    9f21:	jmp    8f2f <botlish_fn_37+0x65a7>
    9f26:	mov    $0xfffffffffffffffd,%r15
    9f2d:	jmp    933f <botlish_fn_37+0x69b7>
    9f32:	mov    $0x1,%r14d
    9f38:	movq   $0x1,0x118(%rsp)
    9f44:	jmp    a41c <botlish_fn_37+0x7a94>
    9f49:	shl    $1,%rsi
    9f4c:	or     $0x1,%rsi
    9f50:	mov    %rsi,0x128(%rsp)
    9f58:	jmp    9f69 <botlish_fn_37+0x75e1>
    9f5d:	movq   $0x1,0x128(%rsp)
    9f69:	mov    $0x1,%r14d
    9f6f:	movq   $0x1,0x118(%rsp)
    9f7b:	jmp    a41c <botlish_fn_37+0x7a94>
    9f80:	shl    $1,%rsi
    9f83:	or     $0x1,%rsi
    9f87:	mov    %rsi,0x130(%rsp)
    9f8f:	jmp    a3e4 <botlish_fn_37+0x7a5c>
    9f94:	mov    0x520(%rsp),%rdi
    9f9c:	mov    0x520(%rsp),%rdi
    9fa4:	mov    0x10(%rdi),%rsi
    9fa8:	mov    0x228(%rsi),%rdi
    9faf:	mov    0x230(%rsi),%rdx
    9fb6:	mov    %rdi,%rsi
    9fb9:	mov    0x520(%rsp),%rdi
    9fc1:	call   9fc6 <botlish_fn_37+0x763e>
			9fc2: R_X86_64_PLT32	rt_raise-0x4
    9fc6:	jmp    a246 <botlish_fn_37+0x78be>
    9fcb:	sar    $1,%r13
    9fce:	mov    $0xffffffffffffffff,%r15
    9fd5:	mov    0x520(%rsp),%rdi
    9fdd:	mov    0x520(%rsp),%rdi
    9fe5:	mov    0x10(%rdi),%rsi
    9fe9:	mov    0x240(%rsi),%r12
    9ff0:	test   $0x1,%r15
    9ff7:	jne    a029 <botlish_fn_37+0x76a1>
    9ffd:	mov    $0xffffffffffffffff,%rdx
    a004:	mov    %r15,%rsi
    a007:	mov    0x520(%rsp),%rdi
    a00f:	call   a014 <botlish_fn_37+0x768c>
			a010: R_X86_64_PLT32	rt_int_cmp-0x4
    a014:	mov    $0x2,%esi
    a019:	test   %rax,%rax
    a01c:	cmovl  0x5bc(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    a024:	jmp    a03a <botlish_fn_37+0x76b2>
    a029:	mov    $0x2,%esi
    a02e:	cmp    $0xffffffffffffffff,%r15
    a032:	cmovl  0x5a6(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    a03a:	cmp    $0x6,%rsi
    a03e:	je     a0c0 <botlish_fn_37+0x7738>
    a044:	test   $0x1,%r15
    a04b:	jne    a07b <botlish_fn_37+0x76f3>
    a051:	mov    $0x1ff,%edx
    a056:	mov    %r15,%rsi
    a059:	mov    0x520(%rsp),%rdi
    a061:	call   a066 <botlish_fn_37+0x76de>
			a062: R_X86_64_PLT32	rt_int_cmp-0x4
    a066:	mov    $0x2,%ecx
    a06b:	test   %rax,%rax
    a06e:	cmovg  0x56a(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    a076:	jmp    a08f <botlish_fn_37+0x7707>
    a07b:	mov    $0x2,%ecx
    a080:	cmp    $0x1ff,%r15
    a087:	cmovg  0x551(%rip),%rcx        # a5e0 <botlish_fn_37+0x7c58>
    a08f:	cmp    $0x6,%rcx
    a093:	je     a0c0 <botlish_fn_37+0x7738>
    a099:	shl    $1,%r13
    a09c:	or     $0x1,%r13
    a0a0:	sar    $1,%r13
    a0a3:	imul   $0x101,%r13,%rax
    a0aa:	mov    %r15,%rcx
    a0ad:	sar    $1,%rcx
    a0b0:	lea    0x1(%rax,%rcx,1),%rax
    a0b5:	movzbq 0x10(%r12,%rax,1),%rsi
    a0bb:	jmp    a0d3 <botlish_fn_37+0x774b>
    a0c0:	shl    $1,%r13
    a0c3:	or     $0x1,%r13
    a0c7:	sar    $1,%r13
    a0ca:	movzbq 0x616(%r12,%r13,1),%rsi
    a0d3:	mov    %rsi,%rcx
    a0d6:	shl    $1,%rcx
    a0d9:	or     $0x1,%rcx
    a0dd:	mov    $0x2,%eax
    a0e2:	cmp    $0xd,%rcx
    a0e6:	cmovl  0x4f2(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    a0ee:	cmp    $0x6,%rax
    a0f2:	je     a3fb <botlish_fn_37+0x7a73>
    a0f8:	mov    %rsi,%rcx
    a0fb:	shl    $1,%rcx
    a0fe:	mov    %rsi,%r13
    a101:	or     $0x1,%rcx
    a105:	mov    $0x2,%eax
    a10a:	cmp    $0xd,%rcx
    a10e:	cmove  0x4ca(%rip),%rax        # a5e0 <botlish_fn_37+0x7c58>
    a116:	cmp    $0x6,%rax
    a11a:	je     a3d8 <botlish_fn_37+0x7a50>
    a120:	test   $0x1,%r15
    a127:	jne    a159 <botlish_fn_37+0x77d1>
    a12d:	mov    $0xffffffffffffffff,%rdx
    a134:	mov    %r15,%rsi
    a137:	mov    0x520(%rsp),%rdi
    a13f:	call   a144 <botlish_fn_37+0x77bc>
			a140: R_X86_64_PLT32	rt_int_cmp-0x4
    a144:	mov    $0x2,%esi
    a149:	test   %rax,%rax
    a14c:	cmove  0x48c(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    a154:	jmp    a16a <botlish_fn_37+0x77e2>
    a159:	mov    $0x2,%esi
    a15e:	cmp    $0xffffffffffffffff,%r15
    a162:	cmove  0x476(%rip),%rsi        # a5e0 <botlish_fn_37+0x7c58>
    a16a:	cmp    $0x6,%rsi
    a16e:	je     a1e6 <botlish_fn_37+0x785e>
    a174:	mov    0x520(%rsp),%rdi
    a17c:	mov    0x10(%rdi),%rax
    a180:	mov    0x248(%rax),%r12
    a187:	mov    $0x1,%ebx
    a18c:	mov    %r13,%rsi
    a18f:	shl    $1,%rsi
    a192:	or     $0x1,%rsi
    a196:	call   a19b <botlish_fn_37+0x7813>
			a197: R_X86_64_PLT32	botlish_fn_5-0x4
    a19b:	mov    0x520(%rsp),%rdi
    a1a3:	mov    0x10(%rdi),%rcx
    a1a7:	mov    0x258(%rcx),%rdx
    a1ae:	lea    0x450(%rsp),%r9
    a1b6:	mov    %r12,0x450(%rsp)
    a1be:	mov    %rax,0x458(%rsp)
    a1c6:	mov    %r15,0x460(%rsp)
    a1ce:	mov    $0x4,%ecx
    a1d3:	mov    $0x3,%r8d
    a1d9:	mov    %rbx,%rsi
    a1dc:	call   a1e1 <botlish_fn_37+0x7859>
			a1dd: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    a1e1:	jmp    a246 <botlish_fn_37+0x78be>
    a1e6:	mov    %r13,%rsi
    a1e9:	mov    0x520(%rsp),%rdi
    a1f1:	mov    0x10(%rdi),%rax
    a1f5:	mov    0x248(%rax),%rbx
    a1fc:	shl    $1,%rsi
    a1ff:	or     $0x1,%rsi
    a203:	call   a208 <botlish_fn_37+0x7880>
			a204: R_X86_64_PLT32	botlish_fn_5-0x4
    a208:	mov    0x520(%rsp),%rdi
    a210:	mov    0x10(%rdi),%rcx
    a214:	mov    0x250(%rcx),%rdx
    a21b:	lea    0x440(%rsp),%r9
    a223:	mov    %rbx,0x440(%rsp)
    a22b:	mov    %rax,0x448(%rsp)
    a233:	mov    $0x2,%r8d
    a239:	mov    $0x5,%ecx
    a23e:	mov    %r8,%rsi
    a241:	call   a246 <botlish_fn_37+0x78be>
			a242: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    a246:	mov    0x520(%rsp),%rdi
    a24e:	call   a253 <botlish_fn_37+0x78cb>
			a24f: R_X86_64_PLT32	rt_co_failed-0x4
    a253:	mov    %rax,0x120(%rsp)
    a25b:	mov    %rax,%rsi
    a25e:	mov    0x520(%rsp),%rdi
    a266:	call   a26b <botlish_fn_37+0x78e3>
			a267: R_X86_64_PLT32	rt_co_resume0-0x4
    a26b:	test   %rax,%rax
    a26e:	je     a290 <botlish_fn_37+0x7908>
    a274:	mov    0x520(%rsp),%rdi
    a27c:	mov    0x10(%rdi),%rax
    a280:	mov    0x48(%rax),%rsi
    a284:	mov    0x218(%rax),%rdx
    a28b:	call   a290 <botlish_fn_37+0x7908>
			a28c: R_X86_64_PLT32	rt_raise-0x4
    a290:	mov    0x520(%rsp),%rdi
    a298:	call   a29d <botlish_fn_37+0x7915>
			a299: R_X86_64_PLT32	rt_declared_error-0x4
    a29d:	cmp    $0x1,%rax
    a2a1:	je     a34b <botlish_fn_37+0x79c3>
    a2a7:	mov    0x520(%rsp),%rdi
    a2af:	call   a2b4 <botlish_fn_37+0x792c>
			a2b0: R_X86_64_PLT32	rt_declared_error-0x4
    a2b4:	cmp    $0x2,%rax
    a2b8:	jne    a46f <botlish_fn_37+0x7ae7>
    a2be:	xor    %rbx,%rbx
    a2c1:	mov    %rbx,%rsi
    a2c4:	mov    0x520(%rsp),%rdi
    a2cc:	call   a2d1 <botlish_fn_37+0x7949>
			a2cd: R_X86_64_PLT32	rt_declared_payload-0x4
    a2d1:	mov    %rax,%r12
    a2d4:	mov    $0x1,%esi
    a2d9:	mov    0x520(%rsp),%rdi
    a2e1:	call   a2e6 <botlish_fn_37+0x795e>
			a2e2: R_X86_64_PLT32	rt_declared_payload-0x4
    a2e6:	mov    %rax,%r13
    a2e9:	mov    0x520(%rsp),%rdi
    a2f1:	call   a2f6 <botlish_fn_37+0x796e>
			a2f2: R_X86_64_PLT32	rt_clear_declared_error-0x4
    a2f6:	mov    0x520(%rsp),%rdi
    a2fe:	mov    0x10(%rdi),%rax
    a302:	mov    0x220(%rax),%rdx
    a309:	lea    0x1c8(%rsp),%r9
    a311:	movq   $0x1,0x1c8(%rsp)
    a31d:	mov    %r12,%rax
    a320:	mov    %rax,0x1d0(%rsp)
    a328:	mov    %r13,%rax
    a32b:	mov    %rax,0x1d8(%rsp)
    a333:	mov    $0xc,%esi
    a338:	mov    $0x3,%r8d
    a33e:	mov    %rbx,%rcx
    a341:	call   a346 <botlish_fn_37+0x79be>
			a342: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    a346:	jmp    a46f <botlish_fn_37+0x7ae7>
    a34b:	xor    %rbx,%rbx
    a34e:	mov    %rbx,%rsi
    a351:	mov    0x520(%rsp),%rdi
    a359:	call   a35e <botlish_fn_37+0x79d6>
			a35a: R_X86_64_PLT32	rt_declared_payload-0x4
    a35e:	mov    %rax,%r12
    a361:	mov    $0x1,%esi
    a366:	mov    0x520(%rsp),%rdi
    a36e:	call   a373 <botlish_fn_37+0x79eb>
			a36f: R_X86_64_PLT32	rt_declared_payload-0x4
    a373:	mov    %rax,%r13
    a376:	mov    0x520(%rsp),%rdi
    a37e:	call   a383 <botlish_fn_37+0x79fb>
			a37f: R_X86_64_PLT32	rt_clear_declared_error-0x4
    a383:	mov    0x520(%rsp),%rdi
    a38b:	mov    0x10(%rdi),%rsi
    a38f:	mov    0x220(%rsi),%rdx
    a396:	lea    0x1b0(%rsp),%r9
    a39e:	movq   $0x1,0x1b0(%rsp)
    a3aa:	mov    %r12,%rax
    a3ad:	mov    %rax,0x1b8(%rsp)
    a3b5:	mov    %r13,%rax
    a3b8:	mov    %rax,0x1c0(%rsp)
    a3c0:	mov    $0xc,%esi
    a3c5:	mov    $0x3,%r8d
    a3cb:	mov    %rbx,%rcx
    a3ce:	call   a3d3 <botlish_fn_37+0x7a4b>
			a3cf: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    a3d3:	jmp    a46f <botlish_fn_37+0x7ae7>
    a3d8:	movq   $0x3,0x130(%rsp)
    a3e4:	mov    $0x1,%r14d
    a3ea:	movq   $0x1,0x118(%rsp)
    a3f6:	jmp    a41c <botlish_fn_37+0x7a94>
    a3fb:	shl    $1,%rsi
    a3fe:	or     $0x1,%rsi
    a402:	mov    %rsi,0x138(%rsp)
    a40a:	mov    $0x1,%r14d
    a410:	movq   $0x1,0x118(%rsp)
    a41c:	mov    0x6d0(%rsp),%rbx
    a424:	mov    0x10(%rbx),%rax
    a428:	mov    0x8(%rax),%rax
    a42c:	mov    %rax,(%rsp)
    a430:	mov    0x10(%rbx),%rcx
    a434:	mov    (%rcx),%rcx
    a437:	mov    %rcx,0x8(%rsp)
    a43c:	lea    0x1e0(%rsp),%rdx
    a444:	mov    %rax,0x1e0(%rsp)
    a44c:	mov    %rcx,0x1e8(%rsp)
    a454:	mov    $0x2,%esi
    a459:	mov    0x520(%rsp),%rdi
    a461:	call   a466 <botlish_fn_37+0x7ade>
			a462: R_X86_64_PLT32	rt_list_new-0x4
    a466:	test   %rax,%rax
    a469:	jne    a4a6 <botlish_fn_37+0x7b1e>
    a46f:	xor    %rax,%rax
    a472:	mov    0x6e0(%rsp),%rbx
    a47a:	mov    0x6e8(%rsp),%r12
    a482:	mov    0x6f0(%rsp),%r13
    a48a:	mov    0x6f8(%rsp),%r14
    a492:	mov    0x700(%rsp),%r15
    a49a:	add    $0x710,%rsp
    a4a1:	mov    %rbp,%rsp
    a4a4:	pop    %rbp
    a4a5:	ret
    a4a6:	mov    0x6e0(%rsp),%rbx
    a4ae:	mov    0x6e8(%rsp),%r12
    a4b6:	mov    0x6f0(%rsp),%r13
    a4be:	mov    0x6f8(%rsp),%r14
    a4c6:	mov    0x700(%rsp),%r15
    a4ce:	add    $0x710,%rsp
    a4d5:	mov    %rbp,%rsp
    a4d8:	pop    %rbp
    a4d9:	ret
    a4da:	mov    $0x5,%edx
    a4df:	mov    %r13,%rcx
    a4e2:	mov    %rbx,%rsi
    a4e5:	mov    0x520(%rsp),%rdi
    a4ed:	call   a4f2 <botlish_fn_37+0x7b6a>
			a4ee: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a4f2:	mov    %rbx,0x6d0(%rsp)
    a4fa:	jmp    49fe <botlish_fn_37+0x2076>
    a4ff:	mov    $0x1,%edx
    a504:	mov    0x6d0(%rsp),%rsi
    a50c:	mov    0x520(%rsp),%rdi
    a514:	call   a519 <botlish_fn_37+0x7b91>
			a515: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a519:	jmp    4d32 <botlish_fn_37+0x23aa>
    a51e:	mov    $0x3,%edx
    a523:	mov    0x6d0(%rsp),%rsi
    a52b:	mov    0x520(%rsp),%rdi
    a533:	call   a538 <botlish_fn_37+0x7bb0>
			a534: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a538:	jmp    4dc6 <botlish_fn_37+0x243e>
    a53d:	mov    $0x1,%edx
    a542:	mov    0x6c0(%rsp),%rsi
    a54a:	mov    0x520(%rsp),%rdi
    a552:	call   a557 <botlish_fn_37+0x7bcf>
			a553: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a557:	jmp    576c <botlish_fn_37+0x2de4>
    a55c:	mov    $0x1,%edx
    a561:	mov    0x630(%rsp),%rsi
    a569:	mov    0x520(%rsp),%rdi
    a571:	call   a576 <botlish_fn_37+0x7bee>
			a572: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a576:	jmp    5f2f <botlish_fn_37+0x35a7>
    a57b:	mov    $0x1,%edx
    a580:	mov    0x610(%rsp),%rsi
    a588:	mov    0x520(%rsp),%rdi
    a590:	call   a595 <botlish_fn_37+0x7c0d>
			a591: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a595:	jmp    6230 <botlish_fn_37+0x38a8>
    a59a:	mov    $0x1,%edx
    a59f:	mov    0x6c0(%rsp),%rsi
    a5a7:	mov    0x520(%rsp),%rdi
    a5af:	call   a5b4 <botlish_fn_37+0x7c2c>
			a5b0: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a5b4:	jmp    6f18 <botlish_fn_37+0x4590>
    a5b9:	mov    $0x5,%edx
    a5be:	mov    0x660(%rsp),%rcx
    a5c6:	mov    0x6d0(%rsp),%rsi
    a5ce:	mov    0x520(%rsp),%rdi
    a5d6:	call   a5db <botlish_fn_37+0x7c53>
			a5d7: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    a5db:	jmp    8e1d <botlish_fn_37+0x6495>
    a5e0:	(bad)
    a5e1:	add    %al,(%rax)
    a5e3:	add    %al,(%rax)
    a5e5:	add    %al,(%rax)
    a5e7:	add    %dl,(%rax,%rax,1)
    a5ea:	add    %al,(%rax)
    a5ec:	add    %al,(%rax)
    a5ee:	add    %al,(%rax)
    a5f0:	ds add %al,(%rax)
    a5f3:	add    %al,(%rax)
    a5f5:	add    %al,(%rax)
    a5f7:	add    %al,(%rbx)
    a5f9:	add    %al,(%rax)
    a5fb:	add    %al,(%rcx)
    a5fd:	add    %al,(%rax)
    a5ff:	.byte 0x80

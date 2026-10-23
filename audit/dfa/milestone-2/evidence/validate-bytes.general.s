<botlish_fn_19>:
    3838:	push   %rbp
    3839:	mov    %rsp,%rbp
    383c:	sub    $0x1c0,%rsp
    3843:	mov    %rbx,0x190(%rsp)
    384b:	mov    %r12,0x198(%rsp)
    3853:	mov    %r13,0x1a0(%rsp)
    385b:	mov    %r14,0x1a8(%rsp)
    3863:	mov    %r15,0x1b0(%rsp)
    386b:	mov    %rdi,0x128(%rsp)
    3873:	movq   $0x0,0x18(%rsp)
    387c:	movq   $0x0,0x20(%rsp)
    3885:	movq   $0x0,0x28(%rsp)
    388e:	movq   $0x0,0x30(%rsp)
    3897:	movq   $0x0,0x38(%rsp)
    38a0:	movq   $0x0,0x40(%rsp)
    38a9:	mov    %rsi,(%rsp)
    38ad:	mov    %rdx,0x8(%rsp)
    38b2:	mov    %rdx,%r12
    38b5:	mov    %rcx,0x10(%rsp)
    38ba:	mov    %rcx,%r14
    38bd:	lea    0x48(%rsp),%r8
    38c2:	mov    %rsi,0x48(%rsp)
    38c7:	mov    $0x14,%esi
    38cc:	mov    0x0(%rip),%rdx        # 38d3 <botlish_fn_19+0x9b>
			38cf: R_X86_64_GOTPCREL	botlish_entry_20-0x4
    38d3:	mov    $0x1,%ecx
    38d8:	mov    0x128(%rsp),%rdi
    38e0:	call   38e5 <botlish_fn_19+0xad>
			38e1: R_X86_64_PLT32	rt_closure_new-0x4
    38e5:	mov    %rax,(%rsp)
    38e9:	mov    %rax,%rsi
    38ec:	mov    0x128(%rsp),%rdi
    38f4:	call   38f9 <botlish_fn_19+0xc1>
			38f5: R_X86_64_PLT32	rt_co_create-0x4
    38f9:	mov    %rax,0x180(%rsp)
    3901:	mov    %rax,(%rsp)
    3905:	mov    0x180(%rsp),%rsi
    390d:	mov    0x128(%rsp),%rdi
    3915:	call   391a <botlish_fn_19+0xe2>
			3916: R_X86_64_PLT32	rt_co_start-0x4
    391a:	test   %rax,%rax
    391d:	je     47b1 <botlish_fn_19+0xf79>
    3923:	mov    %rax,0x18(%rsp)
    3928:	mov    %rax,%rbx
    392b:	lea    0x50(%rsp),%r8
    3930:	mov    %r12,%rdx
    3933:	mov    %rdx,0x50(%rsp)
    3938:	mov    $0x15,%esi
    393d:	mov    0x0(%rip),%rdx        # 3944 <botlish_fn_19+0x10c>
			3940: R_X86_64_GOTPCREL	botlish_entry_21-0x4
    3944:	mov    $0x1,%ecx
    3949:	mov    0x128(%rsp),%rdi
    3951:	call   3956 <botlish_fn_19+0x11e>
			3952: R_X86_64_PLT32	rt_closure_new-0x4
    3956:	mov    %rax,0x8(%rsp)
    395b:	mov    %rax,%rsi
    395e:	mov    0x128(%rsp),%rdi
    3966:	call   396b <botlish_fn_19+0x133>
			3967: R_X86_64_PLT32	rt_co_create-0x4
    396b:	mov    %rax,0x178(%rsp)
    3973:	mov    %rax,0x8(%rsp)
    3978:	mov    0x178(%rsp),%rsi
    3980:	mov    0x128(%rsp),%rdi
    3988:	call   398d <botlish_fn_19+0x155>
			3989: R_X86_64_PLT32	rt_co_start-0x4
    398d:	test   %rax,%rax
    3990:	jne    3a22 <botlish_fn_19+0x1ea>
    3996:	mov    0x128(%rsp),%rdi
    399e:	call   39a3 <botlish_fn_19+0x16b>
			399f: R_X86_64_PLT32	rt_declared_error-0x4
    39a3:	cmp    $0x6,%rax
    39a7:	je     39f3 <botlish_fn_19+0x1bb>
    39ad:	mov    0x128(%rsp),%rdi
    39b5:	call   39ba <botlish_fn_19+0x182>
			39b6: R_X86_64_PLT32	rt_declared_error-0x4
    39ba:	cmp    $0x7,%rax
    39be:	jne    47b1 <botlish_fn_19+0xf79>
    39c4:	mov    0x180(%rsp),%rsi
    39cc:	mov    0x128(%rsp),%rdi
    39d4:	call   39d9 <botlish_fn_19+0x1a1>
			39d5: R_X86_64_PLT32	rt_co_release-0x4
    39d9:	mov    0x178(%rsp),%rsi
    39e1:	mov    0x128(%rsp),%rdi
    39e9:	call   39ee <botlish_fn_19+0x1b6>
			39ea: R_X86_64_PLT32	rt_co_release-0x4
    39ee:	jmp    47b1 <botlish_fn_19+0xf79>
    39f3:	mov    0x180(%rsp),%rsi
    39fb:	mov    0x128(%rsp),%rdi
    3a03:	call   3a08 <botlish_fn_19+0x1d0>
			3a04: R_X86_64_PLT32	rt_co_release-0x4
    3a08:	mov    0x178(%rsp),%rsi
    3a10:	mov    0x128(%rsp),%rdi
    3a18:	call   3a1d <botlish_fn_19+0x1e5>
			3a19: R_X86_64_PLT32	rt_co_release-0x4
    3a1d:	jmp    47b1 <botlish_fn_19+0xf79>
    3a22:	mov    $0x9,%esi
    3a27:	movq   $0x9,0x20(%rsp)
    3a30:	mov    $0x1,%edx
    3a35:	movq   $0x1,0x28(%rsp)
    3a3e:	mov    0x128(%rsp),%rdi
    3a46:	call   3a4b <botlish_fn_19+0x213>
			3a47: R_X86_64_PLT32	rt_mutarray_create-0x4
    3a4b:	mov    %rax,%rcx
    3a4e:	mov    %rax,%r12
    3a51:	test   %rcx,%rax
    3a54:	je     47b1 <botlish_fn_19+0xf79>
    3a5a:	mov    %r12,%rax
    3a5d:	mov    %rax,0x20(%rsp)
    3a62:	mov    0x18(%rax),%rcx
    3a66:	test   %rcx,%rcx
    3a69:	je     488b <botlish_fn_19+0x1053>
    3a6f:	mov    %r12,%rax
    3a72:	mov    %rbx,%rcx
    3a75:	mov    0x10(%rax),%rdx
    3a79:	mov    %rcx,0x8(%rdx)
    3a7d:	mov    $0x8,%esi
    3a82:	mov    %rsi,0x170(%rsp)
    3a8a:	mov    $0xffffffffffffffff,%rbx
    3a91:	lea    0x70(%rsp),%r13
    3a96:	mov    %r13,0x168(%rsp)
    3a9e:	mov    0x0(%rip),%rax        # 3aa5 <botlish_fn_19+0x26d>
			3aa1: R_X86_64_GOTPCREL	botlish_entry_22-0x4
    3aa5:	mov    %rax,0x160(%rsp)
    3aad:	mov    %r12,%r15
    3ab0:	mov    0x10(%r15),%rax
    3ab4:	mov    (%rax),%rsi
    3ab7:	mov    %rsi,0x18(%rsp)
    3abc:	mov    %rsi,0x158(%rsp)
    3ac4:	mov    0x10(%r15),%rax
    3ac8:	mov    0x8(%rax),%rsi
    3acc:	mov    %rsi,0x28(%rsp)
    3ad1:	test   $0x1,%rsi
    3ad8:	mov    %rsi,0x150(%rsp)
    3ae0:	jne    3b13 <botlish_fn_19+0x2db>
    3ae6:	mov    %rbx,%rdx
    3ae9:	mov    0x150(%rsp),%rsi
    3af1:	mov    0x128(%rsp),%rdi
    3af9:	call   3afe <botlish_fn_19+0x2c6>
			3afa: R_X86_64_PLT32	rt_int_cmp-0x4
    3afe:	mov    $0x2,%ecx
    3b03:	test   %rax,%rax
    3b06:	cmove  0xe9a(%rip),%rcx        # 49a8 <botlish_fn_19+0x1170>
    3b0e:	jmp    3b2c <botlish_fn_19+0x2f4>
    3b13:	mov    $0x2,%ecx
    3b18:	mov    0x150(%rsp),%rsi
    3b20:	cmp    $0xffffffffffffffff,%rsi
    3b24:	cmove  0xe7c(%rip),%rcx        # 49a8 <botlish_fn_19+0x1170>
    3b2c:	cmp    $0x6,%rcx
    3b30:	je     46c4 <botlish_fn_19+0xe8c>
    3b36:	mov    0x150(%rsp),%rsi
    3b3e:	mov    0x128(%rsp),%rdi
    3b46:	call   3b4b <botlish_fn_19+0x313>
			3b47: R_X86_64_PLT32	botlish_fn_13-0x4
    3b4b:	cmp    $0x6,%rax
    3b4f:	je     45b3 <botlish_fn_19+0xd7b>
    3b55:	mov    0x150(%rsp),%rsi
    3b5d:	mov    %rsi,0x70(%rsp)
    3b62:	mov    $0x16,%esi
    3b67:	mov    $0x1,%ecx
    3b6c:	mov    0x160(%rsp),%rdx
    3b74:	mov    0x128(%rsp),%rdi
    3b7c:	mov    0x168(%rsp),%r8
    3b84:	call   3b89 <botlish_fn_19+0x351>
			3b85: R_X86_64_PLT32	rt_closure_new-0x4
    3b89:	mov    %rax,0x30(%rsp)
    3b8e:	mov    %rax,%rsi
    3b91:	mov    0x128(%rsp),%rdi
    3b99:	call   3b9e <botlish_fn_19+0x366>
			3b9a: R_X86_64_PLT32	rt_co_create-0x4
    3b9e:	mov    %rax,0x148(%rsp)
    3ba6:	mov    %rax,0x30(%rsp)
    3bab:	mov    0x148(%rsp),%rsi
    3bb3:	mov    0x128(%rsp),%rdi
    3bbb:	call   3bc0 <botlish_fn_19+0x388>
			3bbc: R_X86_64_PLT32	rt_co_start-0x4
    3bc0:	test   %rax,%rax
    3bc3:	mov    %rax,%rcx
    3bc6:	jne    3daf <botlish_fn_19+0x577>
    3bcc:	mov    0x128(%rsp),%rdi
    3bd4:	call   3bd9 <botlish_fn_19+0x3a1>
			3bd5: R_X86_64_PLT32	rt_declared_error-0x4
    3bd9:	cmp    $0x1,%rax
    3bdd:	je     3cc7 <botlish_fn_19+0x48f>
    3be3:	mov    0x128(%rsp),%rdi
    3beb:	call   3bf0 <botlish_fn_19+0x3b8>
			3bec: R_X86_64_PLT32	rt_declared_error-0x4
    3bf0:	cmp    $0x2,%rax
    3bf4:	jne    47b1 <botlish_fn_19+0xf79>
    3bfa:	xor    %rsi,%rsi
    3bfd:	mov    0x128(%rsp),%rdi
    3c05:	call   3c0a <botlish_fn_19+0x3d2>
			3c06: R_X86_64_PLT32	rt_declared_payload-0x4
    3c0a:	mov    %rax,%r12
    3c0d:	mov    $0x1,%esi
    3c12:	mov    0x128(%rsp),%rdi
    3c1a:	call   3c1f <botlish_fn_19+0x3e7>
			3c1b: R_X86_64_PLT32	rt_declared_payload-0x4
    3c1f:	mov    %rax,%rbx
    3c22:	mov    0x128(%rsp),%rdi
    3c2a:	call   3c2f <botlish_fn_19+0x3f7>
			3c2b: R_X86_64_PLT32	rt_clear_declared_error-0x4
    3c2f:	mov    0x180(%rsp),%rsi
    3c37:	mov    0x128(%rsp),%rdi
    3c3f:	call   3c44 <botlish_fn_19+0x40c>
			3c40: R_X86_64_PLT32	rt_co_release-0x4
    3c44:	mov    0x178(%rsp),%rsi
    3c4c:	mov    0x128(%rsp),%rdi
    3c54:	call   3c59 <botlish_fn_19+0x421>
			3c55: R_X86_64_PLT32	rt_co_release-0x4
    3c59:	mov    0x148(%rsp),%rsi
    3c61:	mov    0x128(%rsp),%rdi
    3c69:	call   3c6e <botlish_fn_19+0x436>
			3c6a: R_X86_64_PLT32	rt_co_release-0x4
    3c6e:	mov    0x128(%rsp),%rdi
    3c76:	mov    0x10(%rdi),%rax
    3c7a:	mov    0x200(%rax),%rdx
    3c81:	lea    0x98(%rsp),%r9
    3c89:	mov    0x158(%rsp),%rsi
    3c91:	mov    %rsi,0x98(%rsp)
    3c99:	mov    %r12,%rax
    3c9c:	mov    %rax,0xa0(%rsp)
    3ca4:	mov    %rbx,%rax
    3ca7:	mov    %rax,0xa8(%rsp)
    3caf:	mov    $0x5,%esi
    3cb4:	mov    $0x3,%r8d
    3cba:	mov    %r8,%rcx
    3cbd:	call   3cc2 <botlish_fn_19+0x48a>
			3cbe: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3cc2:	jmp    47b1 <botlish_fn_19+0xf79>
    3cc7:	xor    %rsi,%rsi
    3cca:	mov    0x128(%rsp),%rdi
    3cd2:	call   3cd7 <botlish_fn_19+0x49f>
			3cd3: R_X86_64_PLT32	rt_declared_payload-0x4
    3cd7:	mov    %rax,%r12
    3cda:	mov    $0x1,%esi
    3cdf:	mov    0x128(%rsp),%rdi
    3ce7:	call   3cec <botlish_fn_19+0x4b4>
			3ce8: R_X86_64_PLT32	rt_declared_payload-0x4
    3cec:	mov    %rax,%r13
    3cef:	mov    $0x2,%ebx
    3cf4:	mov    %rbx,%rsi
    3cf7:	mov    0x128(%rsp),%rdi
    3cff:	call   3d04 <botlish_fn_19+0x4cc>
			3d00: R_X86_64_PLT32	rt_declared_payload-0x4
    3d04:	mov    %rax,%r14
    3d07:	mov    0x128(%rsp),%rdi
    3d0f:	call   3d14 <botlish_fn_19+0x4dc>
			3d10: R_X86_64_PLT32	rt_clear_declared_error-0x4
    3d14:	mov    0x180(%rsp),%rsi
    3d1c:	mov    0x128(%rsp),%rdi
    3d24:	call   3d29 <botlish_fn_19+0x4f1>
			3d25: R_X86_64_PLT32	rt_co_release-0x4
    3d29:	mov    0x178(%rsp),%rsi
    3d31:	mov    0x128(%rsp),%rdi
    3d39:	call   3d3e <botlish_fn_19+0x506>
			3d3a: R_X86_64_PLT32	rt_co_release-0x4
    3d3e:	mov    0x148(%rsp),%rsi
    3d46:	mov    0x128(%rsp),%rdi
    3d4e:	call   3d53 <botlish_fn_19+0x51b>
			3d4f: R_X86_64_PLT32	rt_co_release-0x4
    3d53:	mov    0x128(%rsp),%rdi
    3d5b:	mov    0x10(%rdi),%rax
    3d5f:	mov    0x1f8(%rax),%rdx
    3d66:	lea    0x78(%rsp),%r9
    3d6b:	mov    0x158(%rsp),%rsi
    3d73:	mov    %rsi,0x78(%rsp)
    3d78:	mov    %r12,%rax
    3d7b:	mov    %rax,0x80(%rsp)
    3d83:	mov    %r13,%rax
    3d86:	mov    %rax,0x88(%rsp)
    3d8e:	mov    %r14,%rax
    3d91:	mov    %rax,0x90(%rsp)
    3d99:	mov    $0x4,%r8d
    3d9f:	mov    %rbx,%rcx
    3da2:	mov    %r8,%rsi
    3da5:	call   3daa <botlish_fn_19+0x572>
			3da6: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3daa:	jmp    47b1 <botlish_fn_19+0xf79>
    3daf:	mov    0x18(%r15),%rax
    3db3:	test   %rax,%rax
    3db6:	je     48a8 <botlish_fn_19+0x1070>
    3dbc:	mov    0x10(%r15),%rax
    3dc0:	mov    %rcx,0x18(%rax)
    3dc4:	mov    $0x3,%r8d
    3dca:	mov    %r8,0x140(%rsp)
    3dd2:	lea    0xc0(%rsp),%r12
    3dda:	mov    $0x5,%esi
    3ddf:	mov    %rsi,0x138(%rsp)
    3de7:	mov    0x148(%rsp),%rsi
    3def:	mov    0x128(%rsp),%rdi
    3df7:	call   3dfc <botlish_fn_19+0x5c4>
			3df8: R_X86_64_PLT32	rt_co_done-0x4
    3dfc:	cmp    $0x6,%rax
    3e00:	je     4253 <botlish_fn_19+0xa1b>
    3e06:	mov    0x10(%r15),%rax
    3e0a:	mov    (%rax),%rsi
    3e0d:	mov    %rsi,0x38(%rsp)
    3e12:	movq   $0x3,0x40(%rsp)
    3e1b:	test   $0x1,%rsi
    3e22:	je     3e45 <botlish_fn_19+0x60d>
    3e28:	mov    %rsi,%rax
    3e2b:	add    $0x2,%rax
    3e2f:	mov    %rax,%r13
    3e32:	seto   %cl
    3e35:	test   %cl,%cl
    3e37:	jne    3e45 <botlish_fn_19+0x60d>
    3e3d:	mov    %r13,%rax
    3e40:	jmp    3e5d <botlish_fn_19+0x625>
    3e45:	mov    0x140(%rsp),%rdx
    3e4d:	mov    0x128(%rsp),%rdi
    3e55:	call   3e5a <botlish_fn_19+0x622>
			3e56: R_X86_64_PLT32	rt_int_add-0x4
    3e5a:	mov    %rax,%r13
    3e5d:	mov    %rax,0x38(%rsp)
    3e62:	mov    0x18(%r15),%rcx
    3e66:	test   %rcx,%rcx
    3e69:	je     48c2 <botlish_fn_19+0x108a>
    3e6f:	mov    0x10(%r15),%rcx
    3e73:	mov    %r13,%rax
    3e76:	mov    %rax,(%rcx)
    3e79:	mov    0x180(%rsp),%rsi
    3e81:	mov    0x128(%rsp),%rdi
    3e89:	call   3e8e <botlish_fn_19+0x656>
			3e8a: R_X86_64_PLT32	rt_co_resume0-0x4
    3e8e:	mov    %rax,%rcx
    3e91:	mov    %rax,0x130(%rsp)
    3e99:	test   %rcx,%rax
    3e9c:	je     47b1 <botlish_fn_19+0xf79>
    3ea2:	mov    0x130(%rsp),%rax
    3eaa:	mov    %rax,0x40(%rsp)
    3eaf:	mov    0x18(%r15),%rcx
    3eb3:	test   %rcx,%rcx
    3eb6:	je     48df <botlish_fn_19+0x10a7>
    3ebc:	mov    0x10(%r15),%rcx
    3ec0:	mov    0x130(%rsp),%rax
    3ec8:	mov    %rax,0x8(%rcx)
    3ecc:	mov    0x158(%rsp),%rsi
    3ed4:	mov    %r13,%rdx
    3ed7:	and    %rsi,%rdx
    3eda:	test   $0x1,%rdx
    3ee1:	je     3f09 <botlish_fn_19+0x6d1>
    3ee7:	mov    0x158(%rsp),%rax
    3eef:	mov    %r13,%rsi
    3ef2:	sub    %rax,%rsi
    3ef5:	seto   %dil
    3ef9:	add    $0x1,%rsi
    3f00:	test   %dil,%dil
    3f03:	je     3f24 <botlish_fn_19+0x6ec>
    3f09:	mov    0x158(%rsp),%rdx
    3f11:	mov    %r13,%rsi
    3f14:	mov    0x128(%rsp),%rdi
    3f1c:	call   3f21 <botlish_fn_19+0x6e9>
			3f1d: R_X86_64_PLT32	rt_int_sub-0x4
    3f21:	mov    %rax,%rsi
    3f24:	mov    %rsi,%r10
    3f27:	and    %r14,%r10
    3f2a:	test   $0x1,%r10
    3f31:	jne    3f5c <botlish_fn_19+0x724>
    3f37:	mov    %r14,%rdx
    3f3a:	mov    0x128(%rsp),%rdi
    3f42:	call   3f47 <botlish_fn_19+0x70f>
			3f43: R_X86_64_PLT32	rt_int_cmp-0x4
    3f47:	mov    $0x2,%ecx
    3f4c:	test   %rax,%rax
    3f4f:	cmovge 0xa51(%rip),%rcx        # 49a8 <botlish_fn_19+0x1170>
    3f57:	jmp    3f6c <botlish_fn_19+0x734>
    3f5c:	mov    $0x2,%ecx
    3f61:	cmp    %r14,%rsi
    3f64:	cmovge 0xa3c(%rip),%rcx        # 49a8 <botlish_fn_19+0x1170>
    3f6c:	cmp    $0x6,%rcx
    3f70:	je     41c4 <botlish_fn_19+0x98c>
    3f76:	mov    0x130(%rsp),%rax
    3f7e:	mov    %rax,0xc0(%rsp)
    3f86:	mov    $0x1,%edx
    3f8b:	mov    %r12,%rcx
    3f8e:	mov    0x138(%rsp),%rsi
    3f96:	mov    0x128(%rsp),%rdi
    3f9e:	call   3fa3 <botlish_fn_19+0x76b>
			3f9f: R_X86_64_PLT32	rt_struct_new-0x4
    3fa3:	mov    %rax,0x40(%rsp)
    3fa8:	mov    %rax,%rdx
    3fab:	mov    0x148(%rsp),%rsi
    3fb3:	mov    0x128(%rsp),%rdi
    3fbb:	call   3fc0 <botlish_fn_19+0x788>
			3fbc: R_X86_64_PLT32	rt_co_resume-0x4
    3fc0:	test   %rax,%rax
    3fc3:	mov    %rax,%rcx
    3fc6:	jne    41aa <botlish_fn_19+0x972>
    3fcc:	mov    0x128(%rsp),%rdi
    3fd4:	call   3fd9 <botlish_fn_19+0x7a1>
			3fd5: R_X86_64_PLT32	rt_declared_error-0x4
    3fd9:	cmp    $0x1,%rax
    3fdd:	je     40c4 <botlish_fn_19+0x88c>
    3fe3:	mov    0x128(%rsp),%rdi
    3feb:	call   3ff0 <botlish_fn_19+0x7b8>
			3fec: R_X86_64_PLT32	rt_declared_error-0x4
    3ff0:	cmp    $0x2,%rax
    3ff4:	jne    47b1 <botlish_fn_19+0xf79>
    3ffa:	xor    %rsi,%rsi
    3ffd:	mov    0x128(%rsp),%rdi
    4005:	call   400a <botlish_fn_19+0x7d2>
			4006: R_X86_64_PLT32	rt_declared_payload-0x4
    400a:	mov    %rax,%r12
    400d:	mov    $0x1,%esi
    4012:	mov    0x128(%rsp),%rdi
    401a:	call   401f <botlish_fn_19+0x7e7>
			401b: R_X86_64_PLT32	rt_declared_payload-0x4
    401f:	mov    %rax,%rbx
    4022:	mov    0x128(%rsp),%rdi
    402a:	call   402f <botlish_fn_19+0x7f7>
			402b: R_X86_64_PLT32	rt_clear_declared_error-0x4
    402f:	mov    0x180(%rsp),%rsi
    4037:	mov    0x128(%rsp),%rdi
    403f:	call   4044 <botlish_fn_19+0x80c>
			4040: R_X86_64_PLT32	rt_co_release-0x4
    4044:	mov    0x178(%rsp),%rsi
    404c:	mov    0x128(%rsp),%rdi
    4054:	call   4059 <botlish_fn_19+0x821>
			4055: R_X86_64_PLT32	rt_co_release-0x4
    4059:	mov    0x148(%rsp),%rsi
    4061:	mov    0x128(%rsp),%rdi
    4069:	call   406e <botlish_fn_19+0x836>
			406a: R_X86_64_PLT32	rt_co_release-0x4
    406e:	mov    0x128(%rsp),%rdi
    4076:	mov    0x10(%rdi),%rax
    407a:	mov    0x200(%rax),%rdx
    4081:	lea    0xe8(%rsp),%r9
    4089:	mov    %r13,0xe8(%rsp)
    4091:	mov    %r12,%rax
    4094:	mov    %rax,0xf0(%rsp)
    409c:	mov    %rbx,%rax
    409f:	mov    %rax,0xf8(%rsp)
    40a7:	mov    0x138(%rsp),%rsi
    40af:	mov    0x140(%rsp),%r8
    40b7:	mov    %r8,%rcx
    40ba:	call   40bf <botlish_fn_19+0x887>
			40bb: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    40bf:	jmp    47b1 <botlish_fn_19+0xf79>
    40c4:	xor    %rsi,%rsi
    40c7:	mov    0x128(%rsp),%rdi
    40cf:	call   40d4 <botlish_fn_19+0x89c>
			40d0: R_X86_64_PLT32	rt_declared_payload-0x4
    40d4:	mov    %rax,%r12
    40d7:	mov    $0x1,%esi
    40dc:	mov    0x128(%rsp),%rdi
    40e4:	call   40e9 <botlish_fn_19+0x8b1>
			40e5: R_X86_64_PLT32	rt_declared_payload-0x4
    40e9:	mov    %rax,%r14
    40ec:	mov    $0x2,%ebx
    40f1:	mov    %rbx,%rsi
    40f4:	mov    0x128(%rsp),%rdi
    40fc:	call   4101 <botlish_fn_19+0x8c9>
			40fd: R_X86_64_PLT32	rt_declared_payload-0x4
    4101:	mov    %rax,%r15
    4104:	mov    0x128(%rsp),%rdi
    410c:	call   4111 <botlish_fn_19+0x8d9>
			410d: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4111:	mov    0x180(%rsp),%rsi
    4119:	mov    0x128(%rsp),%rdi
    4121:	call   4126 <botlish_fn_19+0x8ee>
			4122: R_X86_64_PLT32	rt_co_release-0x4
    4126:	mov    0x178(%rsp),%rsi
    412e:	mov    0x128(%rsp),%rdi
    4136:	call   413b <botlish_fn_19+0x903>
			4137: R_X86_64_PLT32	rt_co_release-0x4
    413b:	mov    0x148(%rsp),%rsi
    4143:	mov    0x128(%rsp),%rdi
    414b:	call   4150 <botlish_fn_19+0x918>
			414c: R_X86_64_PLT32	rt_co_release-0x4
    4150:	mov    0x128(%rsp),%rdi
    4158:	mov    0x10(%rdi),%rax
    415c:	mov    0x1f8(%rax),%rdx
    4163:	lea    0xc8(%rsp),%r9
    416b:	mov    %r13,0xc8(%rsp)
    4173:	mov    %r12,%rax
    4176:	mov    %rax,0xd0(%rsp)
    417e:	mov    %r14,%rax
    4181:	mov    %rax,0xd8(%rsp)
    4189:	mov    %r15,%rax
    418c:	mov    %rax,0xe0(%rsp)
    4194:	mov    $0x4,%r8d
    419a:	mov    %rbx,%rcx
    419d:	mov    %r8,%rsi
    41a0:	call   41a5 <botlish_fn_19+0x96d>
			41a1: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    41a5:	jmp    47b1 <botlish_fn_19+0xf79>
    41aa:	mov    0x18(%r15),%rax
    41ae:	test   %rax,%rax
    41b1:	je     4904 <botlish_fn_19+0x10cc>
    41b7:	mov    0x10(%r15),%rax
    41bb:	mov    %rcx,0x18(%rax)
    41bf:	jmp    3de7 <botlish_fn_19+0x5af>
    41c4:	mov    0x180(%rsp),%rsi
    41cc:	mov    0x128(%rsp),%rdi
    41d4:	call   41d9 <botlish_fn_19+0x9a1>
			41d5: R_X86_64_PLT32	rt_co_release-0x4
    41d9:	mov    0x178(%rsp),%rsi
    41e1:	mov    0x128(%rsp),%rdi
    41e9:	call   41ee <botlish_fn_19+0x9b6>
			41ea: R_X86_64_PLT32	rt_co_release-0x4
    41ee:	mov    0x148(%rsp),%rsi
    41f6:	mov    0x128(%rsp),%rdi
    41fe:	call   4203 <botlish_fn_19+0x9cb>
			41ff: R_X86_64_PLT32	rt_co_release-0x4
    4203:	mov    0x128(%rsp),%rdi
    420b:	mov    0x10(%rdi),%rax
    420f:	mov    0x208(%rax),%rdx
    4216:	lea    0xb0(%rsp),%r9
    421e:	mov    0x158(%rsp),%rsi
    4226:	mov    %rsi,0xb0(%rsp)
    422e:	mov    %r14,0xb8(%rsp)
    4236:	mov    $0x4,%ecx
    423b:	mov    $0x2,%r8d
    4241:	mov    0x170(%rsp),%rsi
    4249:	call   424e <botlish_fn_19+0xa16>
			424a: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    424e:	jmp    47b1 <botlish_fn_19+0xf79>
    4253:	mov    0x148(%rsp),%rsi
    425b:	mov    0x128(%rsp),%rdi
    4263:	call   4268 <botlish_fn_19+0xa30>
			4264: R_X86_64_PLT32	rt_co_release-0x4
    4268:	mov    0x10(%r15),%rax
    426c:	mov    0x18(%rax),%rsi
    4270:	test   $0x1,%rsi
    4277:	jne    42a4 <botlish_fn_19+0xa6c>
    427d:	mov    $0x1,%edx
    4282:	mov    0x128(%rsp),%rdi
    428a:	call   428f <botlish_fn_19+0xa57>
			428b: R_X86_64_PLT32	rt_int_cmp-0x4
    428f:	mov    $0x2,%ecx
    4294:	test   %rax,%rax
    4297:	cmove  0x709(%rip),%rcx        # 49a8 <botlish_fn_19+0x1170>
    429f:	jmp    42b5 <botlish_fn_19+0xa7d>
    42a4:	mov    $0x2,%ecx
    42a9:	cmp    $0x1,%rsi
    42ad:	cmove  0x6f3(%rip),%rcx        # 49a8 <botlish_fn_19+0x1170>
    42b5:	cmp    $0x6,%rcx
    42b9:	jne    4411 <botlish_fn_19+0xbd9>
    42bf:	mov    0x10(%r15),%rax
    42c3:	mov    0x8(%rax),%rsi
    42c7:	test   $0x1,%rsi
    42ce:	jne    42f9 <botlish_fn_19+0xac1>
    42d4:	mov    %rbx,%rdx
    42d7:	mov    0x128(%rsp),%rdi
    42df:	call   42e4 <botlish_fn_19+0xaac>
			42e0: R_X86_64_PLT32	rt_int_cmp-0x4
    42e4:	mov    $0x2,%ecx
    42e9:	test   %rax,%rax
    42ec:	cmove  0x6b4(%rip),%rcx        # 49a8 <botlish_fn_19+0x1170>
    42f4:	jmp    430a <botlish_fn_19+0xad2>
    42f9:	mov    $0x2,%ecx
    42fe:	cmp    $0xffffffffffffffff,%rsi
    4302:	cmove  0x69e(%rip),%rcx        # 49a8 <botlish_fn_19+0x1170>
    430a:	cmp    $0x6,%rcx
    430e:	je     4411 <botlish_fn_19+0xbd9>
    4314:	movq   $0x1,0x30(%rsp)
    431d:	mov    0x10(%r15),%rdi
    4321:	mov    (%rdi),%rsi
    4324:	mov    %rsi,0x38(%rsp)
    4329:	movq   $0x3,0x40(%rsp)
    4332:	test   $0x1,%rsi
    4339:	je     4351 <botlish_fn_19+0xb19>
    433f:	mov    %rsi,%rcx
    4342:	add    $0x2,%rcx
    4346:	seto   %al
    4349:	test   %al,%al
    434b:	je     4369 <botlish_fn_19+0xb31>
    4351:	mov    0x140(%rsp),%rdx
    4359:	mov    0x128(%rsp),%rdi
    4361:	call   4366 <botlish_fn_19+0xb2e>
			4362: R_X86_64_PLT32	rt_int_add-0x4
    4366:	mov    %rax,%rcx
    4369:	mov    0x18(%r15),%rax
    436d:	test   %rax,%rax
    4370:	je     491e <botlish_fn_19+0x10e6>
    4376:	mov    0x10(%r15),%rax
    437a:	mov    %rcx,(%rax)
    437d:	movq   $0x3,0x30(%rsp)
    4386:	mov    0x180(%rsp),%rsi
    438e:	mov    0x128(%rsp),%rdi
    4396:	call   439b <botlish_fn_19+0xb63>
			4397: R_X86_64_PLT32	rt_co_resume0-0x4
    439b:	test   %rax,%rax
    439e:	mov    %rax,%rcx
    43a1:	jne    43ef <botlish_fn_19+0xbb7>
    43a7:	mov    0x128(%rsp),%rdi
    43af:	call   43b4 <botlish_fn_19+0xb7c>
			43b0: R_X86_64_PLT32	rt_declared_error-0x4
    43b4:	cmp    $0x40000001,%rax
    43ba:	jne    47b1 <botlish_fn_19+0xf79>
    43c0:	mov    0x180(%rsp),%rsi
    43c8:	mov    0x128(%rsp),%rdi
    43d0:	call   43d5 <botlish_fn_19+0xb9d>
			43d1: R_X86_64_PLT32	rt_co_release-0x4
    43d5:	mov    0x178(%rsp),%rsi
    43dd:	mov    0x128(%rsp),%rdi
    43e5:	call   43ea <botlish_fn_19+0xbb2>
			43e6: R_X86_64_PLT32	rt_co_release-0x4
    43ea:	jmp    47b1 <botlish_fn_19+0xf79>
    43ef:	mov    0x18(%r15),%rax
    43f3:	test   %rax,%rax
    43f6:	je     4938 <botlish_fn_19+0x1100>
    43fc:	mov    0x10(%r15),%rax
    4400:	mov    %rcx,0x8(%rax)
    4404:	mov    0x150(%rsp),%rsi
    440c:	jmp    4419 <botlish_fn_19+0xbe1>
    4411:	mov    0x150(%rsp),%rsi
    4419:	mov    0x150(%rsp),%rsi
    4421:	mov    0x128(%rsp),%rdi
    4429:	call   442e <botlish_fn_19+0xbf6>
			442a: R_X86_64_PLT32	botlish_fn_14-0x4
    442e:	mov    %rax,0x28(%rsp)
    4433:	mov    0x10(%r15),%rcx
    4437:	mov    (%rcx),%rcx
    443a:	mov    %rcx,0x30(%rsp)
    443f:	lea    0x100(%rsp),%rdx
    4447:	mov    %rax,0x100(%rsp)
    444f:	mov    0x158(%rsp),%rsi
    4457:	mov    %rsi,0x108(%rsp)
    445f:	mov    %rcx,0x110(%rsp)
    4467:	mov    $0x1,%esi
    446c:	mov    %rdx,%rcx
    446f:	mov    0x140(%rsp),%rdx
    4477:	mov    0x128(%rsp),%rdi
    447f:	call   4484 <botlish_fn_19+0xc4c>
			4480: R_X86_64_PLT32	rt_struct_new-0x4
    4484:	mov    %rax,0x18(%rsp)
    4489:	mov    %rax,%rdx
    448c:	mov    0x178(%rsp),%rsi
    4494:	mov    0x128(%rsp),%rdi
    449c:	call   44a1 <botlish_fn_19+0xc69>
			449d: R_X86_64_PLT32	rt_co_resume-0x4
    44a1:	test   %rax,%rax
    44a4:	jne    4536 <botlish_fn_19+0xcfe>
    44aa:	mov    0x128(%rsp),%rdi
    44b2:	call   44b7 <botlish_fn_19+0xc7f>
			44b3: R_X86_64_PLT32	rt_declared_error-0x4
    44b7:	cmp    $0x6,%rax
    44bb:	je     4507 <botlish_fn_19+0xccf>
    44c1:	mov    0x128(%rsp),%rdi
    44c9:	call   44ce <botlish_fn_19+0xc96>
			44ca: R_X86_64_PLT32	rt_declared_error-0x4
    44ce:	cmp    $0x7,%rax
    44d2:	jne    47b1 <botlish_fn_19+0xf79>
    44d8:	mov    0x180(%rsp),%rsi
    44e0:	mov    0x128(%rsp),%rdi
    44e8:	call   44ed <botlish_fn_19+0xcb5>
			44e9: R_X86_64_PLT32	rt_co_release-0x4
    44ed:	mov    0x178(%rsp),%rsi
    44f5:	mov    0x128(%rsp),%rdi
    44fd:	call   4502 <botlish_fn_19+0xcca>
			44fe: R_X86_64_PLT32	rt_co_release-0x4
    4502:	jmp    47b1 <botlish_fn_19+0xf79>
    4507:	mov    0x180(%rsp),%rsi
    450f:	mov    0x128(%rsp),%rdi
    4517:	call   451c <botlish_fn_19+0xce4>
			4518: R_X86_64_PLT32	rt_co_release-0x4
    451c:	mov    0x178(%rsp),%rsi
    4524:	mov    0x128(%rsp),%rdi
    452c:	call   4531 <botlish_fn_19+0xcf9>
			452d: R_X86_64_PLT32	rt_co_release-0x4
    4531:	jmp    47b1 <botlish_fn_19+0xf79>
    4536:	movq   $0x5,0x18(%rsp)
    453f:	mov    0x10(%r15),%rax
    4543:	mov    0x10(%rax),%rsi
    4547:	mov    %rsi,0x28(%rsp)
    454c:	movq   $0x3,0x30(%rsp)
    4555:	test   $0x1,%rsi
    455c:	jne    456f <botlish_fn_19+0xd37>
    4562:	mov    0x140(%rsp),%rdx
    456a:	jmp    4589 <botlish_fn_19+0xd51>
    456f:	mov    %rsi,%rcx
    4572:	add    $0x2,%rcx
    4576:	seto   %dl
    4579:	test   %dl,%dl
    457b:	je     4599 <botlish_fn_19+0xd61>
    4581:	mov    0x140(%rsp),%rdx
    4589:	mov    0x128(%rsp),%rdi
    4591:	call   4596 <botlish_fn_19+0xd5e>
			4592: R_X86_64_PLT32	rt_int_add-0x4
    4596:	mov    %rax,%rcx
    4599:	mov    0x18(%r15),%rsi
    459d:	test   %rsi,%rsi
    45a0:	je     4955 <botlish_fn_19+0x111d>
    45a6:	mov    0x10(%r15),%r8
    45aa:	mov    %rcx,0x10(%r8)
    45ae:	jmp    3ab0 <botlish_fn_19+0x278>
    45b3:	movq   $0x1,0x28(%rsp)
    45bc:	mov    $0x3,%edx
    45c1:	mov    %rdx,%r12
    45c4:	movq   $0x3,0x30(%rsp)
    45cd:	mov    0x158(%rsp),%rsi
    45d5:	test   $0x1,%rsi
    45dc:	jne    45ef <botlish_fn_19+0xdb7>
    45e2:	mov    0x158(%rsp),%rsi
    45ea:	jmp    4611 <botlish_fn_19+0xdd9>
    45ef:	mov    0x158(%rsp),%rsi
    45f7:	mov    %rsi,%rcx
    45fa:	add    $0x2,%rcx
    45fe:	seto   %al
    4601:	test   %al,%al
    4603:	je     4624 <botlish_fn_19+0xdec>
    4609:	mov    0x158(%rsp),%rsi
    4611:	mov    %r12,%rdx
    4614:	mov    0x128(%rsp),%rdi
    461c:	call   4621 <botlish_fn_19+0xde9>
			461d: R_X86_64_PLT32	rt_int_add-0x4
    4621:	mov    %rax,%rcx
    4624:	mov    0x18(%r15),%rax
    4628:	test   %rax,%rax
    462b:	je     4972 <botlish_fn_19+0x113a>
    4631:	mov    0x10(%r15),%rax
    4635:	mov    %rcx,(%rax)
    4638:	movq   $0x3,0x18(%rsp)
    4641:	mov    0x180(%rsp),%rsi
    4649:	mov    0x128(%rsp),%rdi
    4651:	call   4656 <botlish_fn_19+0xe1e>
			4652: R_X86_64_PLT32	rt_co_resume0-0x4
    4656:	test   %rax,%rax
    4659:	mov    %rax,%rcx
    465c:	jne    46aa <botlish_fn_19+0xe72>
    4662:	mov    0x128(%rsp),%rdi
    466a:	call   466f <botlish_fn_19+0xe37>
			466b: R_X86_64_PLT32	rt_declared_error-0x4
    466f:	cmp    $0x40000001,%rax
    4675:	jne    47b1 <botlish_fn_19+0xf79>
    467b:	mov    0x180(%rsp),%rsi
    4683:	mov    0x128(%rsp),%rdi
    468b:	call   4690 <botlish_fn_19+0xe58>
			468c: R_X86_64_PLT32	rt_co_release-0x4
    4690:	mov    0x178(%rsp),%rsi
    4698:	mov    0x128(%rsp),%rdi
    46a0:	call   46a5 <botlish_fn_19+0xe6d>
			46a1: R_X86_64_PLT32	rt_co_release-0x4
    46a5:	jmp    47b1 <botlish_fn_19+0xf79>
    46aa:	mov    0x18(%r15),%rax
    46ae:	test   %rax,%rax
    46b1:	je     498c <botlish_fn_19+0x1154>
    46b7:	mov    0x10(%r15),%rax
    46bb:	mov    %rcx,0x8(%rax)
    46bf:	jmp    3ab0 <botlish_fn_19+0x278>
    46c4:	movq   $0x132,0x10(%rsp)
    46cd:	lea    0x58(%rsp),%rcx
    46d2:	movq   $0x132,0x58(%rsp)
    46db:	mov    0x158(%rsp),%rsi
    46e3:	mov    %rsi,0x60(%rsp)
    46e8:	mov    %rsi,0x68(%rsp)
    46ed:	mov    $0x1,%esi
    46f2:	mov    $0x3,%edx
    46f7:	mov    0x128(%rsp),%rdi
    46ff:	call   4704 <botlish_fn_19+0xecc>
			4700: R_X86_64_PLT32	rt_struct_new-0x4
    4704:	mov    %rax,0x10(%rsp)
    4709:	mov    %rax,%rdx
    470c:	mov    0x178(%rsp),%rsi
    4714:	mov    0x128(%rsp),%rdi
    471c:	call   4721 <botlish_fn_19+0xee9>
			471d: R_X86_64_PLT32	rt_co_resume-0x4
    4721:	test   %rax,%rax
    4724:	jne    47e8 <botlish_fn_19+0xfb0>
    472a:	mov    0x128(%rsp),%rdi
    4732:	call   4737 <botlish_fn_19+0xeff>
			4733: R_X86_64_PLT32	rt_declared_error-0x4
    4737:	cmp    $0x6,%rax
    473b:	je     4787 <botlish_fn_19+0xf4f>
    4741:	mov    0x128(%rsp),%rdi
    4749:	call   474e <botlish_fn_19+0xf16>
			474a: R_X86_64_PLT32	rt_declared_error-0x4
    474e:	cmp    $0x7,%rax
    4752:	jne    47b1 <botlish_fn_19+0xf79>
    4758:	mov    0x180(%rsp),%rsi
    4760:	mov    0x128(%rsp),%rdi
    4768:	call   476d <botlish_fn_19+0xf35>
			4769: R_X86_64_PLT32	rt_co_release-0x4
    476d:	mov    0x178(%rsp),%rsi
    4775:	mov    0x128(%rsp),%rdi
    477d:	call   4782 <botlish_fn_19+0xf4a>
			477e: R_X86_64_PLT32	rt_co_release-0x4
    4782:	jmp    47b1 <botlish_fn_19+0xf79>
    4787:	mov    0x180(%rsp),%rsi
    478f:	mov    0x128(%rsp),%rdi
    4797:	call   479c <botlish_fn_19+0xf64>
			4798: R_X86_64_PLT32	rt_co_release-0x4
    479c:	mov    0x178(%rsp),%rsi
    47a4:	mov    0x128(%rsp),%rdi
    47ac:	call   47b1 <botlish_fn_19+0xf79>
			47ad: R_X86_64_PLT32	rt_co_release-0x4
    47b1:	xor    %rax,%rax
    47b4:	mov    0x190(%rsp),%rbx
    47bc:	mov    0x198(%rsp),%r12
    47c4:	mov    0x1a0(%rsp),%r13
    47cc:	mov    0x1a8(%rsp),%r14
    47d4:	mov    0x1b0(%rsp),%r15
    47dc:	add    $0x1c0,%rsp
    47e3:	mov    %rbp,%rsp
    47e6:	pop    %rbp
    47e7:	ret
    47e8:	mov    0x180(%rsp),%rsi
    47f0:	mov    0x128(%rsp),%rdi
    47f8:	call   47fd <botlish_fn_19+0xfc5>
			47f9: R_X86_64_PLT32	rt_co_release-0x4
    47fd:	mov    0x178(%rsp),%rsi
    4805:	mov    0x128(%rsp),%rdi
    480d:	call   4812 <botlish_fn_19+0xfda>
			480e: R_X86_64_PLT32	rt_co_release-0x4
    4812:	mov    0x10(%r15),%rax
    4816:	mov    0x10(%rax),%rax
    481a:	mov    %rax,(%rsp)
    481e:	mov    0x10(%r15),%rcx
    4822:	mov    (%rcx),%rdx
    4825:	mov    %rdx,0x8(%rsp)
    482a:	lea    0x118(%rsp),%rcx
    4832:	mov    %rax,0x118(%rsp)
    483a:	mov    %rdx,0x120(%rsp)
    4842:	xor    %rsi,%rsi
    4845:	mov    $0x2,%edx
    484a:	mov    0x128(%rsp),%rdi
    4852:	call   4857 <botlish_fn_19+0x101f>
			4853: R_X86_64_PLT32	rt_struct_new-0x4
    4857:	mov    0x190(%rsp),%rbx
    485f:	mov    0x198(%rsp),%r12
    4867:	mov    0x1a0(%rsp),%r13
    486f:	mov    0x1a8(%rsp),%r14
    4877:	mov    0x1b0(%rsp),%r15
    487f:	add    $0x1c0,%rsp
    4886:	mov    %rbp,%rsp
    4889:	pop    %rbp
    488a:	ret
    488b:	mov    $0x3,%edx
    4890:	mov    %rbx,%rcx
    4893:	mov    %r12,%rsi
    4896:	mov    0x128(%rsp),%rdi
    489e:	call   48a3 <botlish_fn_19+0x106b>
			489f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    48a3:	jmp    3a7d <botlish_fn_19+0x245>
    48a8:	mov    $0x7,%edx
    48ad:	mov    %r15,%rsi
    48b0:	mov    0x128(%rsp),%rdi
    48b8:	call   48bd <botlish_fn_19+0x1085>
			48b9: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    48bd:	jmp    3dc4 <botlish_fn_19+0x58c>
    48c2:	mov    $0x1,%edx
    48c7:	mov    %r13,%rcx
    48ca:	mov    %r15,%rsi
    48cd:	mov    0x128(%rsp),%rdi
    48d5:	call   48da <botlish_fn_19+0x10a2>
			48d6: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    48da:	jmp    3e79 <botlish_fn_19+0x641>
    48df:	mov    0x130(%rsp),%rcx
    48e7:	mov    0x140(%rsp),%rdx
    48ef:	mov    %r15,%rsi
    48f2:	mov    0x128(%rsp),%rdi
    48fa:	call   48ff <botlish_fn_19+0x10c7>
			48fb: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    48ff:	jmp    3ecc <botlish_fn_19+0x694>
    4904:	mov    $0x7,%edx
    4909:	mov    %r15,%rsi
    490c:	mov    0x128(%rsp),%rdi
    4914:	call   4919 <botlish_fn_19+0x10e1>
			4915: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    4919:	jmp    3de7 <botlish_fn_19+0x5af>
    491e:	mov    $0x1,%edx
    4923:	mov    %r15,%rsi
    4926:	mov    0x128(%rsp),%rdi
    492e:	call   4933 <botlish_fn_19+0x10fb>
			492f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    4933:	jmp    437d <botlish_fn_19+0xb45>
    4938:	mov    0x140(%rsp),%rdx
    4940:	mov    %r15,%rsi
    4943:	mov    0x128(%rsp),%rdi
    494b:	call   4950 <botlish_fn_19+0x1118>
			494c: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    4950:	jmp    4404 <botlish_fn_19+0xbcc>
    4955:	mov    0x138(%rsp),%rdx
    495d:	mov    %r15,%rsi
    4960:	mov    0x128(%rsp),%rdi
    4968:	call   496d <botlish_fn_19+0x1135>
			4969: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    496d:	jmp    3ab0 <botlish_fn_19+0x278>
    4972:	mov    $0x1,%edx
    4977:	mov    %r15,%rsi
    497a:	mov    0x128(%rsp),%rdi
    4982:	call   4987 <botlish_fn_19+0x114f>
			4983: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    4987:	jmp    4638 <botlish_fn_19+0xe00>
    498c:	mov    %r12,%rdx
    498f:	mov    %r15,%rsi
    4992:	mov    0x128(%rsp),%rdi
    499a:	call   499f <botlish_fn_19+0x1167>
			499b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    499f:	jmp    3ab0 <botlish_fn_19+0x278>
    49a4:	add    %al,(%rax)
    49a6:	add    %al,(%rax)
    49a8:	(bad)
    49a9:	add    %al,(%rax)
    49ab:	add    %al,(%rax)
    49ad:	add    %al,(%rax)
	...

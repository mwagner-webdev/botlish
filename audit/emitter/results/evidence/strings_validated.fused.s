<botlish_fn_12>:
     618:	push   %rbp
     619:	mov    %rsp,%rbp
     61c:	sub    $0x290,%rsp
     623:	mov    %rbx,0x260(%rsp)
     62b:	mov    %r12,0x268(%rsp)
     633:	mov    %r13,0x270(%rsp)
     63b:	mov    %r14,0x278(%rsp)
     643:	mov    %r15,0x280(%rsp)
     64b:	mov    %rdi,0x1b0(%rsp)
     653:	mov    %rsi,0x1b8(%rsp)
     65b:	movq   $0x0,(%rsp)
     663:	movq   $0x0,0x8(%rsp)
     66c:	movq   $0x0,0x10(%rsp)
     675:	movq   $0x0,0x18(%rsp)
     67e:	movq   $0x0,0x20(%rsp)
     687:	movq   $0x0,0x28(%rsp)
     690:	movq   $0x0,0x30(%rsp)
     699:	movq   $0x0,0x38(%rsp)
     6a2:	movq   $0x0,0x40(%rsp)
     6ab:	movq   $0x0,0x48(%rsp)
     6b4:	movq   $0x0,0x50(%rsp)
     6bd:	movq   $0x0,0x58(%rsp)
     6c6:	movq   $0x0,0x60(%rsp)
     6cf:	movq   $0x0,0x68(%rsp)
     6d8:	mov    0x1b0(%rsp),%rdi
     6e0:	call   6e5 <botlish_fn_12+0xcd>
			6e1: R_X86_64_PLT32	botlish_fn_11-0x4
     6e5:	test   %rax,%rax
     6e8:	je     2438 <botlish_fn_12+0x1e20>
     6ee:	mov    %rax,(%rsp)
     6f2:	mov    %rax,0x258(%rsp)
     6fa:	mov    $0x7,%esi
     6ff:	movq   $0x7,0x8(%rsp)
     708:	mov    $0x1,%edx
     70d:	movq   $0x1,0x10(%rsp)
     716:	mov    0x1b0(%rsp),%rdi
     71e:	call   723 <botlish_fn_12+0x10b>
			71f: R_X86_64_PLT32	rt_mutarray_create-0x4
     723:	test   %rax,%rax
     726:	je     2438 <botlish_fn_12+0x1e20>
     72c:	mov    %rax,0x8(%rsp)
     731:	mov    %rax,0x250(%rsp)
     739:	xor    %rcx,%rcx
     73c:	mov    %rcx,0x1f8(%rsp)
     744:	mov    0x1b8(%rsp),%rdx
     74c:	mov    0x1f8(%rsp),%r15
     754:	mov    0x1f8(%rsp),%rax
     75c:	mov    %rax,0x200(%rsp)
     764:	mov    %rax,0x210(%rsp)
     76c:	cmp    %rdx,%rcx
     76f:	mov    %rdx,0x1b8(%rsp)
     777:	jl     804 <botlish_fn_12+0x1ec>
     77d:	mov    0x250(%rsp),%r8
     785:	mov    0x10(%r8),%rax
     789:	mov    0x8(%rax),%rax
     78d:	mov    %rax,(%rsp)
     791:	mov    0x10(%r8),%rcx
     795:	mov    (%rcx),%rcx
     798:	mov    %rcx,0x8(%rsp)
     79d:	lea    0x100(%rsp),%rdx
     7a5:	mov    %rax,0x100(%rsp)
     7ad:	mov    %rcx,0x108(%rsp)
     7b5:	mov    $0x2,%esi
     7ba:	mov    0x1b0(%rsp),%rdi
     7c2:	call   7c7 <botlish_fn_12+0x1af>
			7c3: R_X86_64_PLT32	rt_list_new-0x4
     7c7:	test   %rax,%rax
     7ca:	je     2438 <botlish_fn_12+0x1e20>
     7d0:	mov    0x260(%rsp),%rbx
     7d8:	mov    0x268(%rsp),%r12
     7e0:	mov    0x270(%rsp),%r13
     7e8:	mov    0x278(%rsp),%r14
     7f0:	mov    0x280(%rsp),%r15
     7f8:	add    $0x290,%rsp
     7ff:	mov    %rbp,%rsp
     802:	pop    %rbp
     803:	ret
     804:	mov    0x258(%rsp),%rbx
     80c:	mov    0x8(%rbx),%rdx
     810:	mov    %rcx,%rax
     813:	and    $0x7,%rax
     817:	shl    $1,%rax
     81a:	or     $0x1,%rax
     81e:	sar    $1,%rax
     821:	cmp    %rdx,%rax
     824:	jb     866 <botlish_fn_12+0x24e>
     82a:	mov    %rcx,%rdx
     82d:	and    $0x7,%rdx
     831:	mov    %rcx,0x1f8(%rsp)
     839:	shl    $1,%rdx
     83c:	or     $0x1,%rdx
     840:	mov    %rbx,%rsi
     843:	mov    0x1b0(%rsp),%rdi
     84b:	call   850 <botlish_fn_12+0x238>
			84c: R_X86_64_PLT32	rt_list_get-0x4
     850:	mov    %rbx,0x258(%rsp)
     858:	test   %rax,%rax
     85b:	je     2438 <botlish_fn_12+0x1e20>
     861:	jmp    881 <botlish_fn_12+0x269>
     866:	mov    %rbx,0x258(%rsp)
     86e:	mov    %rcx,0x1f8(%rsp)
     876:	mov    %rbx,%rcx
     879:	mov    0x10(%rcx),%rcx
     87d:	mov    (%rcx,%rax,8),%rax
     881:	movq   $0xa,0x40(%rsp)
     88a:	movq   $0xa,0x48(%rsp)
     893:	movq   $0xa,0x30(%rsp)
     89c:	movq   $0xa,0x38(%rsp)
     8a5:	mov    %rax,0x40(%rsp)
     8aa:	mov    %rax,0x1e8(%rsp)
     8b2:	movq   $0x45,0x30(%rsp)
     8bb:	movq   $0xa,0x60(%rsp)
     8c4:	movq   $0xa,0x68(%rsp)
     8cd:	movq   $0xa,0x50(%rsp)
     8d6:	movq   $0xa,0x58(%rsp)
     8df:	mov    $0x2,%eax
     8e4:	cmp    $0x6,%rax
     8e8:	je     90f <botlish_fn_12+0x2f7>
     8ee:	mov    $0x2,%edx
     8f3:	cmp    $0x6,%rdx
     8f7:	je     90f <botlish_fn_12+0x2f7>
     8fd:	mov    $0x1,%esi
     902:	mov    %rsi,0x1d8(%rsp)
     90a:	jmp    91c <botlish_fn_12+0x304>
     90f:	mov    $0x4,%esi
     914:	mov    %rsi,0x1d8(%rsp)
     91c:	mov    0x1d8(%rsp),%rsi
     924:	mov    %rsi,%r9
     927:	shl    $1,%r9
     92a:	or     $0x1,%r9
     92e:	mov    $0x2,%eax
     933:	cmp    $0x5,%r9
     937:	cmovl  0x1be9(%rip),%rax        # 2528 <botlish_fn_12+0x1f10>
     93f:	mov    $0x6,%ecx
     944:	mov    %rcx,0x248(%rsp)
     94c:	cmp    $0x6,%rax
     950:	je     e56 <botlish_fn_12+0x83e>
     956:	mov    0x1d8(%rsp),%rsi
     95e:	mov    %rsi,%rcx
     961:	shl    $1,%rcx
     964:	or     $0x1,%rcx
     968:	mov    $0x2,%eax
     96d:	cmp    $0x5,%rcx
     971:	cmove  0x1baf(%rip),%rax        # 2528 <botlish_fn_12+0x1f10>
     979:	cmp    $0x6,%rax
     97d:	je     e17 <botlish_fn_12+0x7ff>
     983:	mov    0x1d8(%rsp),%rsi
     98b:	mov    %rsi,%rcx
     98e:	shl    $1,%rcx
     991:	or     $0x1,%rcx
     995:	mov    $0x2,%eax
     99a:	cmp    $0x7,%rcx
     99e:	cmove  0x1b82(%rip),%rax        # 2528 <botlish_fn_12+0x1f10>
     9a6:	cmp    $0x6,%rax
     9aa:	je     ac1 <botlish_fn_12+0x4a9>
     9b0:	mov    $0x2,%eax
     9b5:	cmp    $0x6,%rax
     9b9:	je     a49 <botlish_fn_12+0x431>
     9bf:	mov    0x1b0(%rsp),%rdi
     9c7:	mov    0x10(%rdi),%rax
     9cb:	mov    0xd8(%rax),%rbx
     9d2:	mov    $0x1,%r12d
     9d8:	mov    0x1d8(%rsp),%rsi
     9e0:	shl    $1,%rsi
     9e3:	mov    %rsi,0x1d8(%rsp)
     9eb:	or     $0x1,%rsi
     9ef:	mov    %rsi,0x1d8(%rsp)
     9f7:	call   9fc <botlish_fn_12+0x3e4>
			9f8: R_X86_64_PLT32	botlish_fn_3-0x4
     9fc:	mov    0x1b0(%rsp),%rdi
     a04:	mov    0x10(%rdi),%rcx
     a08:	mov    0x118(%rcx),%rdx
     a0f:	lea    0x148(%rsp),%r9
     a17:	mov    %rbx,0x148(%rsp)
     a1f:	mov    %rax,0x150(%rsp)
     a27:	movq   $0x45,0x158(%rsp)
     a33:	mov    $0x3,%r8d
     a39:	mov    %r12,%rsi
     a3c:	mov    %r8,%rcx
     a3f:	call   a44 <botlish_fn_12+0x42c>
			a40: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     a44:	jmp    c32 <botlish_fn_12+0x61a>
     a49:	mov    0x1b0(%rsp),%rdi
     a51:	mov    0x10(%rdi),%rax
     a55:	mov    0xd8(%rax),%rbx
     a5c:	mov    0x1d8(%rsp),%rsi
     a64:	shl    $1,%rsi
     a67:	mov    %rsi,0x1d8(%rsp)
     a6f:	or     $0x1,%rsi
     a73:	mov    %rsi,0x1d8(%rsp)
     a7b:	call   a80 <botlish_fn_12+0x468>
			a7c: R_X86_64_PLT32	botlish_fn_3-0x4
     a80:	mov    0x1b0(%rsp),%rdi
     a88:	mov    0x10(%rdi),%rcx
     a8c:	mov    0x110(%rcx),%rdx
     a93:	lea    0x138(%rsp),%r9
     a9b:	mov    %rbx,0x138(%rsp)
     aa3:	mov    %rax,0x140(%rsp)
     aab:	mov    $0x2,%r8d
     ab1:	mov    %r8,%rcx
     ab4:	mov    %r8,%rsi
     ab7:	call   abc <botlish_fn_12+0x4a4>
			ab8: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     abc:	jmp    c32 <botlish_fn_12+0x61a>
     ac1:	mov    0x1b0(%rsp),%rdi
     ac9:	mov    0x10(%rdi),%rax
     acd:	mov    0x100(%rax),%rax
     ad4:	mov    $0x2,%ecx
     ad9:	cmp    $0x6,%rcx
     add:	je     afc <botlish_fn_12+0x4e4>
     ae3:	mov    $0x2,%ecx
     ae8:	cmp    $0x6,%rcx
     aec:	je     afc <botlish_fn_12+0x4e4>
     af2:	movzbq 0x33(%rax),%rsi
     af7:	jmp    b04 <botlish_fn_12+0x4ec>
     afc:	movzbq 0x616(%rax),%rsi
     b04:	mov    %rsi,%rcx
     b07:	shl    $1,%rcx
     b0a:	or     $0x1,%rcx
     b0e:	mov    $0x2,%eax
     b13:	cmp    $0xd,%rcx
     b17:	cmovl  0x1a09(%rip),%rax        # 2528 <botlish_fn_12+0x1f10>
     b1f:	cmp    $0x6,%rax
     b23:	je     dd3 <botlish_fn_12+0x7bb>
     b29:	mov    %rsi,%rcx
     b2c:	shl    $1,%rcx
     b2f:	or     $0x1,%rcx
     b33:	mov    $0x2,%eax
     b38:	cmp    $0xd,%rcx
     b3c:	cmove  0x19e4(%rip),%rax        # 2528 <botlish_fn_12+0x1f10>
     b44:	cmp    $0x6,%rax
     b48:	je     db8 <botlish_fn_12+0x7a0>
     b4e:	mov    $0x2,%edi
     b53:	cmp    $0x6,%rdi
     b57:	je     bcf <botlish_fn_12+0x5b7>
     b5d:	mov    0x1b0(%rsp),%rdi
     b65:	mov    0x10(%rdi),%rcx
     b69:	mov    0x108(%rcx),%rbx
     b70:	mov    $0x1,%r12d
     b76:	shl    $1,%rsi
     b79:	or     $0x1,%rsi
     b7d:	call   b82 <botlish_fn_12+0x56a>
			b7e: R_X86_64_PLT32	botlish_fn_1-0x4
     b82:	mov    0x1b0(%rsp),%rdi
     b8a:	mov    0x10(%rdi),%rcx
     b8e:	mov    0x118(%rcx),%rdx
     b95:	lea    0x120(%rsp),%r9
     b9d:	mov    %rbx,0x120(%rsp)
     ba5:	mov    %rax,0x128(%rsp)
     bad:	movq   $0x45,0x130(%rsp)
     bb9:	mov    $0x3,%r8d
     bbf:	mov    %r12,%rsi
     bc2:	mov    %r8,%rcx
     bc5:	call   bca <botlish_fn_12+0x5b2>
			bc6: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     bca:	jmp    c32 <botlish_fn_12+0x61a>
     bcf:	mov    0x1b0(%rsp),%rdi
     bd7:	mov    0x10(%rdi),%rdi
     bdb:	mov    0x108(%rdi),%r12
     be2:	shl    $1,%rsi
     be5:	or     $0x1,%rsi
     be9:	mov    0x1b0(%rsp),%rdi
     bf1:	call   bf6 <botlish_fn_12+0x5de>
			bf2: R_X86_64_PLT32	botlish_fn_1-0x4
     bf6:	mov    0x1b0(%rsp),%rdi
     bfe:	mov    0x10(%rdi),%rsi
     c02:	mov    0x110(%rsi),%rdx
     c09:	lea    0x110(%rsp),%r9
     c11:	mov    %r12,0x110(%rsp)
     c19:	mov    %rax,0x118(%rsp)
     c21:	mov    $0x2,%r8d
     c27:	mov    %r8,%rcx
     c2a:	mov    %r8,%rsi
     c2d:	call   c32 <botlish_fn_12+0x61a>
			c2e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     c32:	mov    0x1b0(%rsp),%rdi
     c3a:	call   c3f <botlish_fn_12+0x627>
			c3b: R_X86_64_PLT32	rt_co_failed-0x4
     c3f:	mov    %rax,0x58(%rsp)
     c44:	mov    %rax,%rsi
     c47:	mov    0x1b0(%rsp),%rdi
     c4f:	call   c54 <botlish_fn_12+0x63c>
			c50: R_X86_64_PLT32	rt_co_resume0-0x4
     c54:	test   %rax,%rax
     c57:	je     c79 <botlish_fn_12+0x661>
     c5d:	mov    0x1b0(%rsp),%rdi
     c65:	mov    0x10(%rdi),%rax
     c69:	mov    0x30(%rax),%rsi
     c6d:	mov    0xc8(%rax),%rdx
     c74:	call   c79 <botlish_fn_12+0x661>
			c75: R_X86_64_PLT32	rt_raise-0x4
     c79:	mov    0x1b0(%rsp),%rdi
     c81:	call   c86 <botlish_fn_12+0x66e>
			c82: R_X86_64_PLT32	rt_declared_error-0x4
     c86:	cmp    $0x1,%rax
     c8a:	je     d34 <botlish_fn_12+0x71c>
     c90:	mov    0x1b0(%rsp),%rdi
     c98:	call   c9d <botlish_fn_12+0x685>
			c99: R_X86_64_PLT32	rt_declared_error-0x4
     c9d:	cmp    $0x2,%rax
     ca1:	jne    2438 <botlish_fn_12+0x1e20>
     ca7:	xor    %rbx,%rbx
     caa:	mov    %rbx,%rsi
     cad:	mov    0x1b0(%rsp),%rdi
     cb5:	call   cba <botlish_fn_12+0x6a2>
			cb6: R_X86_64_PLT32	rt_declared_payload-0x4
     cba:	mov    %rax,%r13
     cbd:	mov    $0x1,%esi
     cc2:	mov    0x1b0(%rsp),%rdi
     cca:	call   ccf <botlish_fn_12+0x6b7>
			ccb: R_X86_64_PLT32	rt_declared_payload-0x4
     ccf:	mov    %rax,%r12
     cd2:	mov    0x1b0(%rsp),%rdi
     cda:	call   cdf <botlish_fn_12+0x6c7>
			cdb: R_X86_64_PLT32	rt_clear_declared_error-0x4
     cdf:	mov    0x1b0(%rsp),%rdi
     ce7:	mov    0x10(%rdi),%rax
     ceb:	mov    0xd0(%rax),%rdx
     cf2:	lea    0x88(%rsp),%r9
     cfa:	movq   $0x1,0x88(%rsp)
     d06:	mov    %r13,%rax
     d09:	mov    %rax,0x90(%rsp)
     d11:	mov    %r12,%rax
     d14:	mov    %rax,0x98(%rsp)
     d1c:	mov    $0xc,%esi
     d21:	mov    $0x3,%r8d
     d27:	mov    %rbx,%rcx
     d2a:	call   d2f <botlish_fn_12+0x717>
			d2b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     d2f:	jmp    2438 <botlish_fn_12+0x1e20>
     d34:	xor    %rbx,%rbx
     d37:	mov    %rbx,%rsi
     d3a:	mov    0x1b0(%rsp),%rdi
     d42:	call   d47 <botlish_fn_12+0x72f>
			d43: R_X86_64_PLT32	rt_declared_payload-0x4
     d47:	mov    %rax,%r15
     d4a:	mov    $0x1,%esi
     d4f:	mov    0x1b0(%rsp),%rdi
     d57:	call   d5c <botlish_fn_12+0x744>
			d58: R_X86_64_PLT32	rt_declared_payload-0x4
     d5c:	mov    %rax,%r12
     d5f:	mov    0x1b0(%rsp),%rdi
     d67:	call   d6c <botlish_fn_12+0x754>
			d68: R_X86_64_PLT32	rt_clear_declared_error-0x4
     d6c:	mov    0x1b0(%rsp),%rdi
     d74:	mov    0x10(%rdi),%rax
     d78:	mov    0xd0(%rax),%rdx
     d7f:	lea    0x70(%rsp),%r9
     d84:	movq   $0x1,0x70(%rsp)
     d8d:	mov    %r15,%rax
     d90:	mov    %rax,0x78(%rsp)
     d95:	mov    %r12,%rax
     d98:	mov    %rax,0x80(%rsp)
     da0:	mov    $0xc,%esi
     da5:	mov    $0x3,%r8d
     dab:	mov    %rbx,%rcx
     dae:	call   db3 <botlish_fn_12+0x79b>
			daf: R_X86_64_PLT32	rt_fail_declared_payload-0x4
     db3:	jmp    2438 <botlish_fn_12+0x1e20>
     db8:	mov    $0x3,%esi
     dbd:	mov    %rsi,0x1d8(%rsp)
     dc5:	movq   $0x3,0x60(%rsp)
     dce:	jmp    e7a <botlish_fn_12+0x862>
     dd3:	shl    $1,%rsi
     dd6:	or     $0x1,%rsi
     dda:	mov    %rsi,0x68(%rsp)
     ddf:	mov    $0x1,%ecx
     de4:	movq   $0x1,0x50(%rsp)
     ded:	mov    $0xa,%eax
     df2:	mov    %rax,0x1d8(%rsp)
     dfa:	mov    %rcx,0x1c0(%rsp)
     e02:	mov    %rcx,0x1c8(%rsp)
     e0a:	mov    %rsi,0x218(%rsp)
     e12:	jmp    eab <botlish_fn_12+0x893>
     e17:	mov    $0x1,%ecx
     e1c:	movq   $0x1,0x50(%rsp)
     e25:	mov    $0xffffffffffffffff,%r9
     e2c:	mov    $0xa,%esi
     e31:	mov    %rcx,0x1c0(%rsp)
     e39:	mov    %r9,0x1c8(%rsp)
     e41:	mov    %rsi,0x1d8(%rsp)
     e49:	mov    %rsi,0x218(%rsp)
     e51:	jmp    eab <botlish_fn_12+0x893>
     e56:	mov    0x1d8(%rsp),%rsi
     e5e:	shl    $1,%rsi
     e61:	mov    %rsi,0x1d8(%rsp)
     e69:	or     $0x1,%rsi
     e6d:	mov    %rsi,0x1d8(%rsp)
     e75:	mov    %rsi,0x60(%rsp)
     e7a:	mov    $0x1,%ecx
     e7f:	mov    %rcx,0x1c0(%rsp)
     e87:	movq   $0x1,0x50(%rsp)
     e90:	mov    $0x2,%r9d
     e96:	mov    %r9,0x1c8(%rsp)
     e9e:	mov    $0xa,%esi
     ea3:	mov    %rsi,0x218(%rsp)
     eab:	mov    0x250(%rsp),%r8
     eb3:	mov    0x18(%r8),%rax
     eb7:	test   %rax,%rax
     eba:	je     2496 <botlish_fn_12+0x1e7e>
     ec0:	mov    0x250(%rsp),%r8
     ec8:	mov    0x10(%r8),%rax
     ecc:	movq   $0x45,0x10(%rax)
     ed4:	mov    $0x1,%ebx
     ed9:	mov    $0xa,%eax
     ede:	mov    %rax,0x1f0(%rsp)
     ee6:	mov    $0x45,%ecx
     eeb:	mov    %rcx,0x1d0(%rsp)
     ef3:	mov    $0x10,%eax
     ef8:	mov    %rax,0x240(%rsp)
     f00:	mov    $0xffffffffffffffff,%rdx
     f07:	mov    %rdx,0x238(%rsp)
     f0f:	mov    $0x3,%r8d
     f15:	mov    %r8,0x230(%rsp)
     f1d:	mov    $0x2,%r8d
     f23:	mov    %r8,0x228(%rsp)
     f2b:	mov    $0x7fffffff,%eax
     f30:	mov    %rax,%r14
     f33:	neg    %r14
     f36:	cmovs  %rax,%r14
     f3a:	mov    %r14,0x220(%rsp)
     f42:	movq   $0x1,0x10(%rsp)
     f4b:	mov    0x250(%rsp),%r8
     f53:	mov    0x10(%r8),%rax
     f57:	mov    (%rax),%rsi
     f5a:	mov    %rsi,0x18(%rsp)
     f5f:	mov    0x250(%rsp),%r8
     f67:	mov    0x10(%r8),%rax
     f6b:	mov    0x10(%rax),%rdx
     f6f:	mov    %rdx,0x20(%rsp)
     f74:	mov    %rdx,%r12
     f77:	movq   $0x3f,0x28(%rsp)
     f80:	test   $0x1,%rsi
     f87:	je     fb1 <botlish_fn_12+0x999>
     f8d:	mov    %rsi,%rax
     f90:	sar    $1,%rax
     f93:	imulq  0x1596(%rip)        # 2530 <botlish_fn_12+0x1f18>
     f9a:	seto   %cl
     f9d:	or     $0x1,%rax
     fa1:	test   %cl,%cl
     fa3:	jne    fb1 <botlish_fn_12+0x999>
     fa9:	mov    %rax,%rsi
     fac:	jmp    fc6 <botlish_fn_12+0x9ae>
     fb1:	mov    $0x3f,%edx
     fb6:	mov    0x1b0(%rsp),%rdi
     fbe:	call   fc3 <botlish_fn_12+0x9ab>
			fbf: R_X86_64_PLT32	rt_int_mul-0x4
     fc3:	mov    %rax,%rsi
     fc6:	mov    %rsi,0x18(%rsp)
     fcb:	mov    %r12,%rdx
     fce:	mov    %rsi,%rdi
     fd1:	and    %rdx,%rdi
     fd4:	test   $0x1,%rdi
     fdb:	je     ff8 <botlish_fn_12+0x9e0>
     fe1:	lea    -0x1(%rdx),%rdi
     fe5:	mov    %rsi,%rax
     fe8:	add    %rdi,%rax
     feb:	seto   %dil
     fef:	test   %dil,%dil
     ff2:	je     1005 <botlish_fn_12+0x9ed>
     ff8:	mov    0x1b0(%rsp),%rdi
    1000:	call   1005 <botlish_fn_12+0x9ed>
			1001: R_X86_64_PLT32	rt_int_add-0x4
    1005:	mov    %rax,0x18(%rsp)
    100a:	movq   $0x3,0x20(%rsp)
    1013:	test   $0x1,%rax
    1019:	jne    1027 <botlish_fn_12+0xa0f>
    101f:	mov    %rax,%rsi
    1022:	jmp    103f <botlish_fn_12+0xa27>
    1027:	mov    %rax,%rsi
    102a:	add    $0x2,%rsi
    102e:	mov    %rax,%rcx
    1031:	seto   %al
    1034:	test   %al,%al
    1036:	je     1057 <botlish_fn_12+0xa3f>
    103c:	mov    %rcx,%rsi
    103f:	mov    0x230(%rsp),%rdx
    1047:	mov    0x1b0(%rsp),%rdi
    104f:	call   1054 <botlish_fn_12+0xa3c>
			1050: R_X86_64_PLT32	rt_int_add-0x4
    1054:	mov    %rax,%rsi
    1057:	mov    %rsi,0x18(%rsp)
    105c:	mov    $0xffffffff,%eax
    1061:	mov    %rax,0x20(%rsp)
    1066:	test   $0x1,%rsi
    106d:	jne    10bc <botlish_fn_12+0xaa4>
    1073:	mov    $0xffffffff,%edx
    1078:	mov    0x1b0(%rsp),%rdi
    1080:	call   1085 <botlish_fn_12+0xa6d>
			1081: R_X86_64_PLT32	rt_int_mod-0x4
    1085:	test   %rax,%rax
    1088:	jne    10ac <botlish_fn_12+0xa94>
    108e:	mov    0x1b0(%rsp),%rdi
    1096:	call   109b <botlish_fn_12+0xa83>
			1097: R_X86_64_PLT32	rt_declared_error-0x4
    109b:	cmp    $0x40000001,%rax
    10a1:	jne    2438 <botlish_fn_12+0x1e20>
    10a7:	jmp    2438 <botlish_fn_12+0x1e20>
    10ac:	mov    %rax,%rcx
    10af:	mov    0x250(%rsp),%r8
    10b7:	jmp    110a <botlish_fn_12+0xaf2>
    10bc:	sar    $1,%rsi
    10bf:	mov    %rsi,%rax
    10c2:	imulq  0x146f(%rip)        # 2538 <botlish_fn_12+0x1f20>
    10c9:	lea    (%rdx,%rsi,1),%rax
    10cd:	sar    $0x1e,%rax
    10d1:	mov    %rax,%rcx
    10d4:	shr    $0x3f,%rcx
    10d8:	add    %rcx,%rax
    10db:	imul   $0x7fffffff,%rax,%rax
    10e2:	sub    %rax,%rsi
    10e5:	mov    0x220(%rsp),%rcx
    10ed:	lea    (%rsi,%rcx,1),%rax
    10f1:	test   %rsi,%rsi
    10f4:	cmovl  %rax,%rsi
    10f8:	shl    $1,%rsi
    10fb:	or     $0x1,%rsi
    10ff:	mov    %rsi,%rcx
    1102:	mov    0x250(%rsp),%r8
    110a:	mov    0x250(%rsp),%r8
    1112:	mov    0x18(%r8),%rax
    1116:	test   %rax,%rax
    1119:	je     24ba <botlish_fn_12+0x1ea2>
    111f:	mov    0x250(%rsp),%r8
    1127:	mov    0x10(%r8),%rax
    112b:	mov    %rcx,(%rax)
    112e:	movq   $0x3,0x10(%rsp)
    1137:	mov    0x250(%rsp),%r8
    113f:	mov    0x10(%r8),%rcx
    1143:	mov    $0x8,%r13d
    1149:	mov    0x8(%rcx),%rsi
    114d:	mov    %rsi,0x18(%rsp)
    1152:	movq   $0x3,0x20(%rsp)
    115b:	test   $0x1,%rsi
    1162:	je     1187 <botlish_fn_12+0xb6f>
    1168:	mov    %rsi,%rcx
    116b:	add    $0x2,%rcx
    116f:	seto   %al
    1172:	test   %al,%al
    1174:	jne    1187 <botlish_fn_12+0xb6f>
    117a:	mov    0x250(%rsp),%r8
    1182:	jmp    11a7 <botlish_fn_12+0xb8f>
    1187:	mov    0x230(%rsp),%rdx
    118f:	mov    0x1b0(%rsp),%rdi
    1197:	call   119c <botlish_fn_12+0xb84>
			1198: R_X86_64_PLT32	rt_int_add-0x4
    119c:	mov    %rax,%rcx
    119f:	mov    0x250(%rsp),%r8
    11a7:	mov    0x250(%rsp),%r8
    11af:	mov    0x18(%r8),%rax
    11b3:	test   %rax,%rax
    11b6:	je     24d9 <botlish_fn_12+0x1ec1>
    11bc:	mov    0x250(%rsp),%r8
    11c4:	mov    0x10(%r8),%rax
    11c8:	mov    %rcx,0x8(%rax)
    11cc:	cmp    $0x1,%rbx
    11d0:	je     1694 <botlish_fn_12+0x107c>
    11d6:	cmp    $0x2,%rbx
    11da:	je     166c <botlish_fn_12+0x1054>
    11e0:	cmp    $0x3,%rbx
    11e4:	je     1645 <botlish_fn_12+0x102d>
    11ea:	cmp    $0x4,%rbx
    11ee:	je     150a <botlish_fn_12+0xef2>
    11f4:	cmp    $0x5,%rbx
    11f8:	je     14f0 <botlish_fn_12+0xed8>
    11fe:	cmp    $0x6,%rbx
    1202:	je     14de <botlish_fn_12+0xec6>
    1208:	cmp    $0x7,%rbx
    120c:	je     14cc <botlish_fn_12+0xeb4>
    1212:	cmp    $0x8,%rbx
    1216:	je     14ba <botlish_fn_12+0xea2>
    121c:	cmp    $0x9,%rbx
    1220:	je     14a8 <botlish_fn_12+0xe90>
    1226:	cmp    $0xa,%rbx
    122a:	je     147c <botlish_fn_12+0xe64>
    1230:	cmp    $0xb,%rbx
    1234:	je     1450 <botlish_fn_12+0xe38>
    123a:	cmp    $0xc,%rbx
    123e:	je     13dd <botlish_fn_12+0xdc5>
    1244:	cmp    $0xd,%rbx
    1248:	je     1359 <botlish_fn_12+0xd41>
    124e:	cmp    $0xe,%rbx
    1252:	je     1359 <botlish_fn_12+0xd41>
    1258:	cmp    $0xf,%rbx
    125c:	je     1347 <botlish_fn_12+0xd2f>
    1262:	cmp    $0x10,%rbx
    1266:	je     1347 <botlish_fn_12+0xd2f>
    126c:	cmp    $0x11,%rbx
    1270:	je     1335 <botlish_fn_12+0xd1d>
    1276:	cmp    $0x12,%rbx
    127a:	je     130c <botlish_fn_12+0xcf4>
    1280:	cmp    $0xffffffffffffffff,%rbx
    1284:	jne    12a2 <botlish_fn_12+0xc8a>
    128a:	mov    0x1d0(%rsp),%r12
    1292:	mov    0x210(%rsp),%r13
    129a:	mov    %r15,%r14
    129d:	jmp    17f4 <botlish_fn_12+0x11dc>
    12a2:	mov    $0xa,%esi
    12a7:	mov    0x1b0(%rsp),%rdi
    12af:	call   12b4 <botlish_fn_12+0xc9c>
			12b0: R_X86_64_PLT32	rt_co_resume0-0x4
    12b4:	test   %rax,%rax
    12b7:	jne    12ca <botlish_fn_12+0xcb2>
    12bd:	mov    0x1b0(%rsp),%rdi
    12c5:	jmp    12ee <botlish_fn_12+0xcd6>
    12ca:	mov    0x1b0(%rsp),%rdi
    12d2:	mov    0x10(%rdi),%rax
    12d6:	mov    0x30(%rax),%rsi
    12da:	mov    0xc8(%rax),%rdx
    12e1:	call   12e6 <botlish_fn_12+0xcce>
			12e2: R_X86_64_PLT32	rt_raise-0x4
    12e6:	mov    0x1b0(%rsp),%rdi
    12ee:	mov    0x1b0(%rsp),%rdi
    12f6:	call   12fb <botlish_fn_12+0xce3>
			12f7: R_X86_64_PLT32	rt_declared_error-0x4
    12fb:	cmp    $0x40000001,%rax
    1301:	jne    2438 <botlish_fn_12+0x1e20>
    1307:	jmp    2438 <botlish_fn_12+0x1e20>
    130c:	movq   $0xffffffffffffffff,0x30(%rsp)
    1315:	mov    0x238(%rsp),%rbx
    131d:	mov    0x238(%rsp),%r12
    1325:	mov    0x210(%rsp),%r13
    132d:	mov    %r15,%r14
    1330:	jmp    17f4 <botlish_fn_12+0x11dc>
    1335:	mov    $0xa,%eax
    133a:	mov    0x200(%rsp),%rcx
    1342:	jmp    14fd <botlish_fn_12+0xee5>
    1347:	mov    $0xa,%eax
    134c:	mov    0x200(%rsp),%rcx
    1354:	jmp    14f8 <botlish_fn_12+0xee0>
    1359:	mov    $0xf,%ebx
    135e:	mov    0x200(%rsp),%rcx
    1366:	mov    %rcx,%rax
    1369:	and    $0xf,%rax
    136d:	cmp    $0xa,%rax
    1371:	jl     13ae <botlish_fn_12+0xd96>
    1377:	mov    %rcx,%rax
    137a:	and    $0xf,%rax
    137e:	lea    0x57(%rax),%r12
    1382:	shl    $1,%r12
    1385:	or     $0x1,%r12
    1389:	mov    %r12,0x30(%rsp)
    138e:	mov    0x240(%rsp),%rbx
    1396:	mov    0x210(%rsp),%r13
    139e:	mov    %r15,%r14
    13a1:	mov    %rcx,0x200(%rsp)
    13a9:	jmp    17f4 <botlish_fn_12+0x11dc>
    13ae:	mov    %rcx,%rax
    13b1:	and    $0xf,%rax
    13b5:	lea    0x30(%rax),%r12
    13b9:	shl    $1,%r12
    13bc:	or     $0x1,%r12
    13c0:	mov    %r12,0x30(%rsp)
    13c5:	mov    0x210(%rsp),%r13
    13cd:	mov    %r15,%r14
    13d0:	mov    %rcx,0x200(%rsp)
    13d8:	jmp    17f4 <botlish_fn_12+0x11dc>
    13dd:	mov    0x200(%rsp),%rcx
    13e5:	mov    %rcx,%rax
    13e8:	sar    $0x4,%rax
    13ec:	cmp    $0xa,%rax
    13f0:	jl     1423 <botlish_fn_12+0xe0b>
    13f6:	lea    0x57(%rax),%r12
    13fa:	shl    $1,%r12
    13fd:	or     $0x1,%r12
    1401:	mov    %r12,0x30(%rsp)
    1406:	mov    $0xe,%ebx
    140b:	mov    0x210(%rsp),%r13
    1413:	mov    %r15,%r14
    1416:	mov    %rcx,0x200(%rsp)
    141e:	jmp    17f4 <botlish_fn_12+0x11dc>
    1423:	lea    0x30(%rax),%r12
    1427:	shl    $1,%r12
    142a:	or     $0x1,%r12
    142e:	mov    %r12,0x30(%rsp)
    1433:	mov    $0xd,%ebx
    1438:	mov    0x210(%rsp),%r13
    1440:	mov    %r15,%r14
    1443:	mov    %rcx,0x200(%rsp)
    144b:	jmp    17f4 <botlish_fn_12+0x11dc>
    1450:	mov    0x200(%rsp),%rcx
    1458:	mov    $0x61,%r12d
    145e:	movq   $0x61,0x30(%rsp)
    1467:	mov    $0xc,%ebx
    146c:	mov    0x210(%rsp),%r13
    1474:	mov    %r15,%r14
    1477:	jmp    17f4 <botlish_fn_12+0x11dc>
    147c:	mov    0x200(%rsp),%rcx
    1484:	mov    $0x61,%r12d
    148a:	movq   $0x61,0x30(%rsp)
    1493:	mov    $0xb,%ebx
    1498:	mov    0x210(%rsp),%r13
    14a0:	mov    %r15,%r14
    14a3:	jmp    17f4 <botlish_fn_12+0x11dc>
    14a8:	mov    0x200(%rsp),%rcx
    14b0:	mov    $0xa,%eax
    14b5:	jmp    14f8 <botlish_fn_12+0xee0>
    14ba:	mov    0x200(%rsp),%rcx
    14c2:	mov    $0xa,%eax
    14c7:	jmp    14f8 <botlish_fn_12+0xee0>
    14cc:	mov    0x200(%rsp),%rcx
    14d4:	mov    $0xa,%eax
    14d9:	jmp    14f8 <botlish_fn_12+0xee0>
    14de:	mov    0x200(%rsp),%rcx
    14e6:	mov    $0xa,%eax
    14eb:	jmp    14f8 <botlish_fn_12+0xee0>
    14f0:	mov    0x200(%rsp),%rcx
    14f8:	mov    $0xa,%eax
    14fd:	mov    %rcx,0x200(%rsp)
    1505:	jmp    1645 <botlish_fn_12+0x102d>
    150a:	mov    0x200(%rsp),%rcx
    1512:	cmp    $0x8,%rcx
    1516:	je     1619 <botlish_fn_12+0x1001>
    151c:	mov    $0x9,%ebx
    1521:	cmp    $0x9,%rcx
    1525:	je     15ea <botlish_fn_12+0xfd2>
    152b:	cmp    $0xa,%rcx
    152f:	je     15be <botlish_fn_12+0xfa6>
    1535:	cmp    $0xc,%rcx
    1539:	je     1594 <botlish_fn_12+0xf7c>
    153f:	cmp    $0xd,%rcx
    1543:	mov    %rcx,0x200(%rsp)
    154b:	je     1575 <botlish_fn_12+0xf5d>
    1551:	mov    $0xeb,%r12d
    1557:	movq   $0xeb,0x30(%rsp)
    1560:	mov    $0xa,%ebx
    1565:	mov    0x210(%rsp),%r13
    156d:	mov    %r15,%r14
    1570:	jmp    17f4 <botlish_fn_12+0x11dc>
    1575:	mov    $0xe5,%r12d
    157b:	movq   $0xe5,0x30(%rsp)
    1584:	mov    0x210(%rsp),%r13
    158c:	mov    %r15,%r14
    158f:	jmp    17f4 <botlish_fn_12+0x11dc>
    1594:	mov    %rcx,0x200(%rsp)
    159c:	mov    $0xcd,%r12d
    15a2:	movq   $0xcd,0x30(%rsp)
    15ab:	mov    %r15,%r14
    15ae:	mov    %r13,%rbx
    15b1:	mov    0x210(%rsp),%r13
    15b9:	jmp    17f4 <botlish_fn_12+0x11dc>
    15be:	mov    %rcx,0x200(%rsp)
    15c6:	mov    $0xdd,%r12d
    15cc:	movq   $0xdd,0x30(%rsp)
    15d5:	mov    $0x7,%ebx
    15da:	mov    0x210(%rsp),%r13
    15e2:	mov    %r15,%r14
    15e5:	jmp    17f4 <botlish_fn_12+0x11dc>
    15ea:	mov    %rcx,0x200(%rsp)
    15f2:	mov    $0xe9,%r12d
    15f8:	movq   $0xe9,0x30(%rsp)
    1601:	mov    0x248(%rsp),%rbx
    1609:	mov    0x210(%rsp),%r13
    1611:	mov    %r15,%r14
    1614:	jmp    17f4 <botlish_fn_12+0x11dc>
    1619:	mov    %rcx,0x200(%rsp)
    1621:	mov    $0xc5,%r12d
    1627:	movq   $0xc5,0x30(%rsp)
    1630:	mov    $0x5,%ebx
    1635:	mov    0x210(%rsp),%r13
    163d:	mov    %r15,%r14
    1640:	jmp    17f4 <botlish_fn_12+0x11dc>
    1645:	mov    0x210(%rsp),%r13
    164d:	add    $0x1,%r13
    1654:	mov    %r15,%r14
    1657:	mov    0x1e8(%rsp),%r15
    165f:	mov    0x1f0(%rsp),%rax
    1667:	jmp    16b5 <botlish_fn_12+0x109d>
    166c:	mov    0x1f0(%rsp),%rax
    1674:	mov    0x210(%rsp),%r13
    167c:	mov    %rax,0x30(%rsp)
    1681:	mov    0x230(%rsp),%rbx
    1689:	mov    %rax,%r12
    168c:	mov    %r15,%r14
    168f:	jmp    17f4 <botlish_fn_12+0x11dc>
    1694:	mov    0x1f0(%rsp),%rax
    169c:	mov    0x1e8(%rsp),%r15
    16a4:	mov    0x8(%r15),%r14
    16a8:	xor    %r13,%r13
    16ab:	shl    $1,%r14
    16ae:	or     $0x1,%r14
    16b2:	sar    $1,%r14
    16b5:	cmp    %r14,%r13
    16b8:	jl     16e7 <botlish_fn_12+0x10cf>
    16be:	mov    $0x45,%r12d
    16c4:	movq   $0x45,0x30(%rsp)
    16cd:	mov    $0x12,%ebx
    16d2:	mov    %r15,0x1e8(%rsp)
    16da:	mov    %rax,0x1f0(%rsp)
    16e2:	jmp    17f4 <botlish_fn_12+0x11dc>
    16e7:	movzbq 0x18(%r15),%rax
    16ec:	test   %rax,%rax
    16ef:	jne    171c <botlish_fn_12+0x1104>
    16f5:	mov    %r13,%rdx
    16f8:	shl    $1,%rdx
    16fb:	or     $0x1,%rdx
    16ff:	mov    %r15,%rsi
    1702:	mov    0x1b0(%rsp),%rdi
    170a:	call   170f <botlish_fn_12+0x10f7>
			170b: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    170f:	mov    %r15,0x1e8(%rsp)
    1717:	jmp    1747 <botlish_fn_12+0x112f>
    171c:	mov    %r15,0x1e8(%rsp)
    1724:	mov    %r13,%rax
    1727:	shl    $1,%rax
    172a:	or     $0x1,%rax
    172e:	sar    $1,%rax
    1731:	mov    0x1e8(%rsp),%rcx
    1739:	movzbq 0x19(%rcx,%rax,1),%rax
    173f:	shl    $0x3,%rax
    1743:	or     $0x4,%rax
    1747:	shr    $0x3,%rax
    174b:	shl    $1,%rax
    174e:	or     $0x1,%rax
    1752:	mov    %rax,0x48(%rsp)
    1757:	mov    %rax,%rcx
    175a:	sar    $1,%rcx
    175d:	cmp    $0x22,%rcx
    1761:	jne    1774 <botlish_fn_12+0x115c>
    1767:	mov    %rax,0x1f0(%rsp)
    176f:	jmp    17dd <botlish_fn_12+0x11c5>
    1774:	cmp    $0x5c,%rcx
    1778:	jne    178b <botlish_fn_12+0x1173>
    177e:	mov    %rax,0x1f0(%rsp)
    1786:	jmp    17dd <botlish_fn_12+0x11c5>
    178b:	cmp    $0x20,%rcx
    178f:	jl     17b4 <botlish_fn_12+0x119c>
    1795:	mov    %rax,0x30(%rsp)
    179a:	mov    %rax,0x1f0(%rsp)
    17a2:	mov    $0x11,%ebx
    17a7:	mov    0x1f0(%rsp),%r12
    17af:	jmp    17f4 <botlish_fn_12+0x11dc>
    17b4:	mov    %rax,0x1f0(%rsp)
    17bc:	mov    $0xb9,%r12d
    17c2:	movq   $0xb9,0x30(%rsp)
    17cb:	mov    $0x4,%ebx
    17d0:	mov    %rcx,0x200(%rsp)
    17d8:	jmp    17f4 <botlish_fn_12+0x11dc>
    17dd:	mov    $0xb9,%r12d
    17e3:	movq   $0xb9,0x30(%rsp)
    17ec:	mov    0x228(%rsp),%rbx
    17f4:	test   %rbx,%rbx
    17f7:	jl     23cd <botlish_fn_12+0x1db5>
    17fd:	mov    0x1c8(%rsp),%r15
    1805:	test   %r15,%r15
    1808:	jl     236e <botlish_fn_12+0x1d56>
    180e:	cmp    $0x1,%r15
    1812:	je     1dda <botlish_fn_12+0x17c2>
    1818:	cmp    $0x2,%r15
    181c:	je     184e <botlish_fn_12+0x1236>
    1822:	mov    $0xa,%esi
    1827:	cmp    $0xffffffffffffffff,%r15
    182b:	jne    2112 <botlish_fn_12+0x1afa>
    1831:	mov    %r12,0x208(%rsp)
    1839:	mov    %r12,0x1d0(%rsp)
    1841:	mov    0x1c0(%rsp),%r12
    1849:	jmp    2311 <botlish_fn_12+0x1cf9>
    184e:	mov    0x1d8(%rsp),%rsi
    1856:	mov    0x1d8(%rsp),%r15
    185e:	mov    %r12,0x1e0(%rsp)
    1866:	mov    %r12,0x208(%rsp)
    186e:	or     $0x1,%rsi
    1872:	sar    $1,%rsi
    1875:	test   %rsi,%rsi
    1878:	jle    1a09 <botlish_fn_12+0x13f1>
    187e:	cmp    $0x2,%rsi
    1882:	jl     1895 <botlish_fn_12+0x127d>
    1888:	mov    0x1b0(%rsp),%rdi
    1890:	jmp    1db6 <botlish_fn_12+0x179e>
    1895:	test   $0x1,%r12
    189c:	jne    18da <botlish_fn_12+0x12c2>
    18a2:	mov    $0x41,%edx
    18a7:	mov    %r12,%rsi
    18aa:	mov    0x1b0(%rsp),%rdi
    18b2:	call   18b7 <botlish_fn_12+0x129f>
			18b3: R_X86_64_PLT32	rt_int_cmp-0x4
    18b7:	mov    %r12,0x1d0(%rsp)
    18bf:	test   %rax,%rax
    18c2:	mov    0x228(%rsp),%r8
    18ca:	mov    %r8,%rcx
    18cd:	cmovl  0xc53(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    18d5:	jmp    18fc <botlish_fn_12+0x12e4>
    18da:	mov    %r12,%rcx
    18dd:	mov    0x228(%rsp),%r8
    18e5:	mov    %r12,0x1d0(%rsp)
    18ed:	cmp    $0x41,%rcx
    18f1:	mov    %r8,%rcx
    18f4:	cmovl  0xc2c(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    18fc:	cmp    $0x6,%rcx
    1900:	je     19ff <botlish_fn_12+0x13e7>
    1906:	mov    0x1d0(%rsp),%rcx
    190e:	test   $0x1,%rcx
    1915:	jne    1950 <botlish_fn_12+0x1338>
    191b:	mov    $0x21ffff,%edx
    1920:	mov    0x1d0(%rsp),%rsi
    1928:	mov    0x1b0(%rsp),%rdi
    1930:	call   1935 <botlish_fn_12+0x131d>
			1931: R_X86_64_PLT32	rt_int_cmp-0x4
    1935:	test   %rax,%rax
    1938:	mov    0x228(%rsp),%r8
    1940:	mov    %r8,%rcx
    1943:	cmovg  0xbdd(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    194b:	jmp    1972 <botlish_fn_12+0x135a>
    1950:	mov    0x1d0(%rsp),%rcx
    1958:	cmp    $0x21ffff,%rcx
    195f:	mov    0x228(%rsp),%r8
    1967:	mov    %r8,%rcx
    196a:	cmovg  0xbb6(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    1972:	cmp    $0x6,%rcx
    1976:	je     19ff <botlish_fn_12+0x13e7>
    197c:	mov    0x1d0(%rsp),%rcx
    1984:	sar    $1,%rcx
    1987:	cmp    $0x5c,%rcx
    198b:	jl     19d4 <botlish_fn_12+0x13bc>
    1991:	cmp    $0xd800,%rcx
    1998:	jl     19bd <botlish_fn_12+0x13a5>
    199e:	cmp    $0xe000,%rcx
    19a5:	jl     19ff <botlish_fn_12+0x13e7>
    19ab:	cmp    $0x110000,%rcx
    19b2:	jge    19ff <botlish_fn_12+0x13e7>
    19b8:	jmp    1b1f <botlish_fn_12+0x1507>
    19bd:	cmp    $0x5d,%rcx
    19c1:	jge    1b1f <botlish_fn_12+0x1507>
    19c7:	mov    0x230(%rsp),%rsi
    19cf:	jmp    1b2e <botlish_fn_12+0x1516>
    19d4:	cmp    $0x22,%rcx
    19d8:	jl     19f5 <botlish_fn_12+0x13dd>
    19de:	cmp    $0x23,%rcx
    19e2:	jge    1b1f <botlish_fn_12+0x1507>
    19e8:	mov    0x228(%rsp),%rsi
    19f0:	jmp    1b2e <botlish_fn_12+0x1516>
    19f5:	cmp    $0x20,%rcx
    19f9:	jge    1b1f <botlish_fn_12+0x1507>
    19ff:	mov    $0x5,%esi
    1a04:	jmp    1b2e <botlish_fn_12+0x1516>
    1a09:	mov    %r12,0x1d0(%rsp)
    1a11:	test   %rsi,%rsi
    1a14:	jl     1dae <botlish_fn_12+0x1796>
    1a1a:	mov    0x1d0(%rsp),%rcx
    1a22:	test   $0x1,%rcx
    1a29:	jne    1a64 <botlish_fn_12+0x144c>
    1a2f:	mov    $0x45,%edx
    1a34:	mov    0x1d0(%rsp),%rsi
    1a3c:	mov    0x1b0(%rsp),%rdi
    1a44:	call   1a49 <botlish_fn_12+0x1431>
			1a45: R_X86_64_PLT32	rt_int_cmp-0x4
    1a49:	test   %rax,%rax
    1a4c:	mov    0x228(%rsp),%r8
    1a54:	mov    %r8,%rcx
    1a57:	cmovl  0xac9(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    1a5f:	jmp    1a83 <botlish_fn_12+0x146b>
    1a64:	mov    0x1d0(%rsp),%rcx
    1a6c:	cmp    $0x45,%rcx
    1a70:	mov    0x228(%rsp),%r8
    1a78:	mov    %r8,%rcx
    1a7b:	cmovl  0xaa5(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    1a83:	cmp    $0x6,%rcx
    1a87:	je     1b29 <botlish_fn_12+0x1511>
    1a8d:	mov    0x1d0(%rsp),%rcx
    1a95:	test   $0x1,%rcx
    1a9c:	jne    1ad7 <botlish_fn_12+0x14bf>
    1aa2:	mov    $0x45,%edx
    1aa7:	mov    0x1d0(%rsp),%rsi
    1aaf:	mov    0x1b0(%rsp),%rdi
    1ab7:	call   1abc <botlish_fn_12+0x14a4>
			1ab8: R_X86_64_PLT32	rt_int_cmp-0x4
    1abc:	test   %rax,%rax
    1abf:	mov    0x228(%rsp),%r8
    1ac7:	mov    %r8,%rcx
    1aca:	cmovg  0xa56(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    1ad2:	jmp    1af6 <botlish_fn_12+0x14de>
    1ad7:	mov    0x1d0(%rsp),%rcx
    1adf:	cmp    $0x45,%rcx
    1ae3:	mov    0x228(%rsp),%r8
    1aeb:	mov    %r8,%rcx
    1aee:	cmovg  0xa32(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    1af6:	cmp    $0x6,%rcx
    1afa:	je     1b29 <botlish_fn_12+0x1511>
    1b00:	mov    0x1d0(%rsp),%rcx
    1b08:	sar    $1,%rcx
    1b0b:	cmp    $0x22,%rcx
    1b0f:	jl     1b29 <botlish_fn_12+0x1511>
    1b15:	cmp    $0x23,%rcx
    1b19:	jge    1b29 <botlish_fn_12+0x1511>
    1b1f:	mov    $0x1,%esi
    1b24:	jmp    1b2e <botlish_fn_12+0x1516>
    1b29:	mov    $0x4,%esi
    1b2e:	mov    %rsi,%rcx
    1b31:	shl    $1,%rcx
    1b34:	or     $0x1,%rcx
    1b38:	cmp    $0x5,%rcx
    1b3c:	mov    0x228(%rsp),%r8
    1b44:	mov    %r8,%rcx
    1b47:	cmovl  0x9d9(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    1b4f:	cmp    $0x6,%rcx
    1b53:	je     1d85 <botlish_fn_12+0x176d>
    1b59:	mov    %rsi,%rcx
    1b5c:	shl    $1,%rcx
    1b5f:	or     $0x1,%rcx
    1b63:	cmp    $0x5,%rcx
    1b67:	mov    0x228(%rsp),%r8
    1b6f:	cmove  0x9b1(%rip),%r8        # 2528 <botlish_fn_12+0x1f10>
    1b77:	cmp    $0x6,%r8
    1b7b:	je     1d51 <botlish_fn_12+0x1739>
    1b81:	mov    %rsi,%rcx
    1b84:	shl    $1,%rcx
    1b87:	mov    %rsi,0x1d8(%rsp)
    1b8f:	or     $0x1,%rcx
    1b93:	cmp    $0x7,%rcx
    1b97:	mov    0x228(%rsp),%r8
    1b9f:	mov    %r8,%rcx
    1ba2:	cmove  0x97e(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    1baa:	cmp    $0x6,%rcx
    1bae:	je     1d39 <botlish_fn_12+0x1721>
    1bb4:	mov    0x1d0(%rsp),%rcx
    1bbc:	test   $0x1,%rcx
    1bc3:	jne    1c01 <botlish_fn_12+0x15e9>
    1bc9:	mov    0x238(%rsp),%rdx
    1bd1:	mov    0x1d0(%rsp),%rsi
    1bd9:	mov    0x1b0(%rsp),%rdi
    1be1:	call   1be6 <botlish_fn_12+0x15ce>
			1be2: R_X86_64_PLT32	rt_int_cmp-0x4
    1be6:	test   %rax,%rax
    1be9:	mov    0x228(%rsp),%r8
    1bf1:	mov    %r8,%rax
    1bf4:	cmove  0x92c(%rip),%rax        # 2528 <botlish_fn_12+0x1f10>
    1bfc:	jmp    1c20 <botlish_fn_12+0x1608>
    1c01:	mov    0x1d0(%rsp),%rcx
    1c09:	cmp    $0xffffffffffffffff,%rcx
    1c0d:	mov    0x228(%rsp),%r8
    1c15:	mov    %r8,%rax
    1c18:	cmove  0x908(%rip),%rax        # 2528 <botlish_fn_12+0x1f10>
    1c20:	cmp    $0x6,%rax
    1c24:	je     1cbf <botlish_fn_12+0x16a7>
    1c2a:	mov    0x1b0(%rsp),%rdi
    1c32:	mov    0x10(%rdi),%r11
    1c36:	mov    0xd8(%r11),%r12
    1c3d:	mov    $0x1,%r13d
    1c43:	mov    0x1d8(%rsp),%rsi
    1c4b:	shl    $1,%rsi
    1c4e:	mov    %rsi,0x1d8(%rsp)
    1c56:	or     $0x1,%rsi
    1c5a:	mov    %rsi,0x1d8(%rsp)
    1c62:	call   1c67 <botlish_fn_12+0x164f>
			1c63: R_X86_64_PLT32	botlish_fn_3-0x4
    1c67:	mov    0x1b0(%rsp),%rdi
    1c6f:	mov    0x10(%rdi),%r11
    1c73:	mov    0x118(%r11),%rdx
    1c7a:	lea    0x198(%rsp),%r9
    1c82:	mov    %r12,0x198(%rsp)
    1c8a:	mov    %rax,0x1a0(%rsp)
    1c92:	mov    0x1d0(%rsp),%rcx
    1c9a:	mov    %rcx,0x1a8(%rsp)
    1ca2:	mov    %r13,%rsi
    1ca5:	mov    0x230(%rsp),%rcx
    1cad:	mov    0x230(%rsp),%r8
    1cb5:	call   1cba <botlish_fn_12+0x16a2>
			1cb6: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1cba:	jmp    20fd <botlish_fn_12+0x1ae5>
    1cbf:	mov    0x1b0(%rsp),%rdi
    1cc7:	mov    0x10(%rdi),%rax
    1ccb:	mov    0xd8(%rax),%r15
    1cd2:	mov    0x1d8(%rsp),%rsi
    1cda:	shl    $1,%rsi
    1cdd:	mov    %rsi,0x1d8(%rsp)
    1ce5:	or     $0x1,%rsi
    1ce9:	mov    %rsi,0x1d8(%rsp)
    1cf1:	call   1cf6 <botlish_fn_12+0x16de>
			1cf2: R_X86_64_PLT32	botlish_fn_3-0x4
    1cf6:	mov    0x1b0(%rsp),%rdi
    1cfe:	mov    0x10(%rdi),%rcx
    1d02:	mov    0x110(%rcx),%rdx
    1d09:	lea    0x188(%rsp),%r9
    1d11:	mov    %r15,0x188(%rsp)
    1d19:	mov    %rax,0x190(%rsp)
    1d21:	mov    0x228(%rsp),%r8
    1d29:	mov    %r8,%rcx
    1d2c:	mov    %r8,%rsi
    1d2f:	call   1d34 <botlish_fn_12+0x171c>
			1d30: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    1d34:	jmp    20fd <botlish_fn_12+0x1ae5>
    1d39:	xor    %r12,%r12
    1d3c:	mov    0x1b0(%rsp),%rdi
    1d44:	mov    %r15,0x1d8(%rsp)
    1d4c:	jmp    1e10 <botlish_fn_12+0x17f8>
    1d51:	mov    $0x1,%r12d
    1d57:	movq   $0x1,0x50(%rsp)
    1d60:	mov    %r15,0x1d8(%rsp)
    1d68:	mov    0x1e0(%rsp),%rax
    1d70:	mov    %rax,0x1d0(%rsp)
    1d78:	mov    0x238(%rsp),%r15
    1d80:	jmp    2311 <botlish_fn_12+0x1cf9>
    1d85:	mov    %rsi,0x1d8(%rsp)
    1d8d:	shl    $1,%rsi
    1d90:	mov    %rsi,0x1d8(%rsp)
    1d98:	or     $0x1,%rsi
    1d9c:	mov    %rsi,0x1d8(%rsp)
    1da4:	mov    %rsi,0x60(%rsp)
    1da9:	jmp    22af <botlish_fn_12+0x1c97>
    1dae:	mov    0x1b0(%rsp),%rdi
    1db6:	mov    0x1b0(%rsp),%rdi
    1dbe:	mov    0x10(%rdi),%rax
    1dc2:	mov    0xf0(%rax),%rsi
    1dc9:	mov    0xf8(%rax),%rdx
    1dd0:	call   1dd5 <botlish_fn_12+0x17bd>
			1dd1: R_X86_64_PLT32	rt_raise-0x4
    1dd5:	jmp    20fd <botlish_fn_12+0x1ae5>
    1dda:	mov    0x218(%rsp),%rsi
    1de2:	mov    %r12,0x1d0(%rsp)
    1dea:	mov    %rsi,%r12
    1ded:	sar    $1,%r12
    1df0:	mov    0x1b0(%rsp),%rdi
    1df8:	mov    0x1d0(%rsp),%rax
    1e00:	mov    %rax,0x1e0(%rsp)
    1e08:	mov    %rax,0x208(%rsp)
    1e10:	mov    0x1b0(%rsp),%rdi
    1e18:	mov    0x10(%rdi),%rax
    1e1c:	mov    0x100(%rax),%r15
    1e23:	mov    0x1d0(%rsp),%rcx
    1e2b:	test   $0x1,%rcx
    1e32:	jne    1e70 <botlish_fn_12+0x1858>
    1e38:	mov    0x238(%rsp),%rdx
    1e40:	mov    0x1d0(%rsp),%rsi
    1e48:	mov    0x1b0(%rsp),%rdi
    1e50:	call   1e55 <botlish_fn_12+0x183d>
			1e51: R_X86_64_PLT32	rt_int_cmp-0x4
    1e55:	test   %rax,%rax
    1e58:	mov    0x228(%rsp),%r8
    1e60:	mov    %r8,%rcx
    1e63:	cmovl  0x6bd(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    1e6b:	jmp    1e8f <botlish_fn_12+0x1877>
    1e70:	mov    0x1d0(%rsp),%rcx
    1e78:	cmp    $0xffffffffffffffff,%rcx
    1e7c:	mov    0x228(%rsp),%r8
    1e84:	mov    %r8,%rcx
    1e87:	cmovl  0x699(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    1e8f:	cmp    $0x6,%rcx
    1e93:	je     1f3b <botlish_fn_12+0x1923>
    1e99:	mov    0x1d0(%rsp),%rcx
    1ea1:	test   $0x1,%rcx
    1ea8:	jne    1ee3 <botlish_fn_12+0x18cb>
    1eae:	mov    $0x1ff,%edx
    1eb3:	mov    0x1d0(%rsp),%rsi
    1ebb:	mov    0x1b0(%rsp),%rdi
    1ec3:	call   1ec8 <botlish_fn_12+0x18b0>
			1ec4: R_X86_64_PLT32	rt_int_cmp-0x4
    1ec8:	test   %rax,%rax
    1ecb:	mov    0x228(%rsp),%r8
    1ed3:	mov    %r8,%rcx
    1ed6:	cmovg  0x64a(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    1ede:	jmp    1f05 <botlish_fn_12+0x18ed>
    1ee3:	mov    0x1d0(%rsp),%rcx
    1eeb:	cmp    $0x1ff,%rcx
    1ef2:	mov    0x228(%rsp),%r8
    1efa:	mov    %r8,%rcx
    1efd:	cmovg  0x623(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    1f05:	cmp    $0x6,%rcx
    1f09:	je     1f3b <botlish_fn_12+0x1923>
    1f0f:	shl    $1,%r12
    1f12:	or     $0x1,%r12
    1f16:	sar    $1,%r12
    1f19:	imul   $0x101,%r12,%rcx
    1f20:	mov    0x1d0(%rsp),%rax
    1f28:	sar    $1,%rax
    1f2b:	lea    0x1(%rcx,%rax,1),%rax
    1f30:	movzbq 0x10(%r15,%rax,1),%rsi
    1f36:	jmp    1f4e <botlish_fn_12+0x1936>
    1f3b:	shl    $1,%r12
    1f3e:	or     $0x1,%r12
    1f42:	sar    $1,%r12
    1f45:	movzbq 0x616(%r15,%r12,1),%rsi
    1f4e:	mov    %rsi,%rcx
    1f51:	shl    $1,%rcx
    1f54:	or     $0x1,%rcx
    1f58:	cmp    $0xd,%rcx
    1f5c:	mov    0x228(%rsp),%r8
    1f64:	mov    %r8,%rcx
    1f67:	cmovl  0x5b9(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    1f6f:	cmp    $0x6,%rcx
    1f73:	je     22db <botlish_fn_12+0x1cc3>
    1f79:	mov    %rsi,%rcx
    1f7c:	shl    $1,%rcx
    1f7f:	mov    %rsi,%r15
    1f82:	or     $0x1,%rcx
    1f86:	cmp    $0xd,%rcx
    1f8a:	mov    0x228(%rsp),%r8
    1f92:	mov    %r8,%rcx
    1f95:	cmove  0x58b(%rip),%rcx        # 2528 <botlish_fn_12+0x1f10>
    1f9d:	cmp    $0x6,%rcx
    1fa1:	je     2296 <botlish_fn_12+0x1c7e>
    1fa7:	mov    0x1d0(%rsp),%rcx
    1faf:	test   $0x1,%rcx
    1fb6:	jne    1ff4 <botlish_fn_12+0x19dc>
    1fbc:	mov    0x238(%rsp),%rdx
    1fc4:	mov    0x1d0(%rsp),%rsi
    1fcc:	mov    0x1b0(%rsp),%rdi
    1fd4:	call   1fd9 <botlish_fn_12+0x19c1>
			1fd5: R_X86_64_PLT32	rt_int_cmp-0x4
    1fd9:	test   %rax,%rax
    1fdc:	mov    0x228(%rsp),%r8
    1fe4:	mov    %r8,%rax
    1fe7:	cmove  0x539(%rip),%rax        # 2528 <botlish_fn_12+0x1f10>
    1fef:	jmp    2013 <botlish_fn_12+0x19fb>
    1ff4:	mov    0x1d0(%rsp),%rcx
    1ffc:	cmp    $0xffffffffffffffff,%rcx
    2000:	mov    0x228(%rsp),%r8
    2008:	mov    %r8,%rax
    200b:	cmove  0x515(%rip),%rax        # 2528 <botlish_fn_12+0x1f10>
    2013:	cmp    $0x6,%rax
    2017:	je     209d <botlish_fn_12+0x1a85>
    201d:	mov    0x1b0(%rsp),%rdi
    2025:	mov    0x10(%rdi),%rsi
    2029:	mov    0x108(%rsi),%r12
    2030:	mov    $0x1,%r13d
    2036:	mov    %r15,%rsi
    2039:	shl    $1,%rsi
    203c:	or     $0x1,%rsi
    2040:	call   2045 <botlish_fn_12+0x1a2d>
			2041: R_X86_64_PLT32	botlish_fn_1-0x4
    2045:	mov    0x1b0(%rsp),%rdi
    204d:	mov    0x10(%rdi),%rsi
    2051:	mov    0x118(%rsi),%rdx
    2058:	lea    0x170(%rsp),%r9
    2060:	mov    %r12,0x170(%rsp)
    2068:	mov    %rax,0x178(%rsp)
    2070:	mov    0x1d0(%rsp),%rcx
    2078:	mov    %rcx,0x180(%rsp)
    2080:	mov    %r13,%rsi
    2083:	mov    0x230(%rsp),%rcx
    208b:	mov    0x230(%rsp),%r8
    2093:	call   2098 <botlish_fn_12+0x1a80>
			2094: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2098:	jmp    20fd <botlish_fn_12+0x1ae5>
    209d:	mov    %r15,%rsi
    20a0:	mov    0x1b0(%rsp),%rdi
    20a8:	mov    0x10(%rdi),%r8
    20ac:	mov    0x108(%r8),%r12
    20b3:	shl    $1,%rsi
    20b6:	or     $0x1,%rsi
    20ba:	call   20bf <botlish_fn_12+0x1aa7>
			20bb: R_X86_64_PLT32	botlish_fn_1-0x4
    20bf:	mov    0x1b0(%rsp),%rdi
    20c7:	mov    0x10(%rdi),%r8
    20cb:	mov    0x110(%r8),%rdx
    20d2:	lea    0x160(%rsp),%r9
    20da:	mov    %r12,0x160(%rsp)
    20e2:	mov    %rax,0x168(%rsp)
    20ea:	mov    0x228(%rsp),%r8
    20f2:	mov    %r8,%rcx
    20f5:	mov    %r8,%rsi
    20f8:	call   20fd <botlish_fn_12+0x1ae5>
			20f9: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    20fd:	mov    0x1b0(%rsp),%rdi
    2105:	call   210a <botlish_fn_12+0x1af2>
			2106: R_X86_64_PLT32	rt_co_failed-0x4
    210a:	mov    %rax,0x58(%rsp)
    210f:	mov    %rax,%rsi
    2112:	mov    0x1b0(%rsp),%rdi
    211a:	call   211f <botlish_fn_12+0x1b07>
			211b: R_X86_64_PLT32	rt_co_resume0-0x4
    211f:	test   %rax,%rax
    2122:	je     2144 <botlish_fn_12+0x1b2c>
    2128:	mov    0x1b0(%rsp),%rdi
    2130:	mov    0x10(%rdi),%rax
    2134:	mov    0x30(%rax),%rsi
    2138:	mov    0xc8(%rax),%rdx
    213f:	call   2144 <botlish_fn_12+0x1b2c>
			2140: R_X86_64_PLT32	rt_raise-0x4
    2144:	mov    0x1b0(%rsp),%rdi
    214c:	call   2151 <botlish_fn_12+0x1b39>
			214d: R_X86_64_PLT32	rt_declared_error-0x4
    2151:	cmp    $0x1,%rax
    2155:	je     2204 <botlish_fn_12+0x1bec>
    215b:	mov    0x1b0(%rsp),%rdi
    2163:	call   2168 <botlish_fn_12+0x1b50>
			2164: R_X86_64_PLT32	rt_declared_error-0x4
    2168:	cmp    $0x2,%rax
    216c:	jne    2438 <botlish_fn_12+0x1e20>
    2172:	xor    %rbx,%rbx
    2175:	mov    %rbx,%rsi
    2178:	mov    0x1b0(%rsp),%rdi
    2180:	call   2185 <botlish_fn_12+0x1b6d>
			2181: R_X86_64_PLT32	rt_declared_payload-0x4
    2185:	mov    %rbx,%r12
    2188:	mov    %rax,%rbx
    218b:	mov    $0x1,%esi
    2190:	mov    0x1b0(%rsp),%rdi
    2198:	call   219d <botlish_fn_12+0x1b85>
			2199: R_X86_64_PLT32	rt_declared_payload-0x4
    219d:	mov    %rax,%r13
    21a0:	mov    0x1b0(%rsp),%rdi
    21a8:	call   21ad <botlish_fn_12+0x1b95>
			21a9: R_X86_64_PLT32	rt_clear_declared_error-0x4
    21ad:	mov    0x1b0(%rsp),%rdi
    21b5:	mov    0x10(%rdi),%rax
    21b9:	mov    0xd0(%rax),%rdx
    21c0:	lea    0xd0(%rsp),%r9
    21c8:	movq   $0x1,0xd0(%rsp)
    21d4:	mov    %rbx,%rax
    21d7:	mov    %rax,0xd8(%rsp)
    21df:	mov    %r13,%rax
    21e2:	mov    %rax,0xe0(%rsp)
    21ea:	mov    $0xc,%esi
    21ef:	mov    %r12,%rcx
    21f2:	mov    0x230(%rsp),%r8
    21fa:	call   21ff <botlish_fn_12+0x1be7>
			21fb: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    21ff:	jmp    2438 <botlish_fn_12+0x1e20>
    2204:	xor    %rbx,%rbx
    2207:	mov    %rbx,%rsi
    220a:	mov    0x1b0(%rsp),%rdi
    2212:	call   2217 <botlish_fn_12+0x1bff>
			2213: R_X86_64_PLT32	rt_declared_payload-0x4
    2217:	mov    %rbx,%r12
    221a:	mov    %rax,%rbx
    221d:	mov    $0x1,%esi
    2222:	mov    0x1b0(%rsp),%rdi
    222a:	call   222f <botlish_fn_12+0x1c17>
			222b: R_X86_64_PLT32	rt_declared_payload-0x4
    222f:	mov    %rax,%r13
    2232:	mov    0x1b0(%rsp),%rdi
    223a:	call   223f <botlish_fn_12+0x1c27>
			223b: R_X86_64_PLT32	rt_clear_declared_error-0x4
    223f:	mov    0x1b0(%rsp),%rdi
    2247:	mov    0x10(%rdi),%rax
    224b:	mov    0xd0(%rax),%rdx
    2252:	lea    0xb8(%rsp),%r9
    225a:	movq   $0x1,0xb8(%rsp)
    2266:	mov    %rbx,%rax
    2269:	mov    %rax,0xc0(%rsp)
    2271:	mov    %r13,%rax
    2274:	mov    %rax,0xc8(%rsp)
    227c:	mov    $0xc,%esi
    2281:	mov    %r12,%rcx
    2284:	mov    0x230(%rsp),%r8
    228c:	call   2291 <botlish_fn_12+0x1c79>
			228d: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2291:	jmp    2438 <botlish_fn_12+0x1e20>
    2296:	movq   $0x3,0x60(%rsp)
    229f:	mov    0x230(%rsp),%rax
    22a7:	mov    %rax,0x1d8(%rsp)
    22af:	mov    $0x1,%r12d
    22b5:	movq   $0x1,0x50(%rsp)
    22be:	mov    0x228(%rsp),%r15
    22c6:	mov    0x1e0(%rsp),%rax
    22ce:	mov    %rax,0x1d0(%rsp)
    22d6:	jmp    2311 <botlish_fn_12+0x1cf9>
    22db:	shl    $1,%rsi
    22de:	or     $0x1,%rsi
    22e2:	mov    %rsi,0x68(%rsp)
    22e7:	mov    $0x1,%r12d
    22ed:	movq   $0x1,0x50(%rsp)
    22f6:	mov    %r12,%r15
    22f9:	mov    0x1e0(%rsp),%rax
    2301:	mov    %rax,0x1d0(%rsp)
    2309:	mov    %rsi,0x218(%rsp)
    2311:	mov    0x250(%rsp),%r8
    2319:	mov    0x18(%r8),%rax
    231d:	test   %rax,%rax
    2320:	je     24fb <botlish_fn_12+0x1ee3>
    2326:	mov    0x250(%rsp),%r8
    232e:	mov    0x10(%r8),%rax
    2332:	mov    0x1d0(%rsp),%rcx
    233a:	mov    %rcx,0x10(%rax)
    233e:	mov    %r13,0x210(%rsp)
    2346:	mov    0x208(%rsp),%rax
    234e:	mov    %rax,0x1d0(%rsp)
    2356:	mov    %r15,0x1c8(%rsp)
    235e:	mov    %r12,0x1c0(%rsp)
    2366:	mov    %r14,%r15
    2369:	jmp    f42 <botlish_fn_12+0x92a>
    236e:	mov    0x1b0(%rsp),%rdi
    2376:	mov    0x10(%rdi),%rdx
    237a:	mov    0xd8(%rdx),%rax
    2381:	mov    0xe0(%rdx),%rcx
    2388:	mov    0xd0(%rdx),%rdx
    238f:	lea    0xa0(%rsp),%r9
    2397:	movq   $0x1,0xa0(%rsp)
    23a3:	mov    %rax,0xa8(%rsp)
    23ab:	mov    %rcx,0xb0(%rsp)
    23b3:	mov    $0xc,%esi
    23b8:	xor    %rcx,%rcx
    23bb:	mov    0x230(%rsp),%r8
    23c3:	call   23c8 <botlish_fn_12+0x1db0>
			23c4: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    23c8:	jmp    2438 <botlish_fn_12+0x1e20>
    23cd:	mov    0x1c8(%rsp),%r15
    23d5:	test   %r15,%r15
    23d8:	jl     246f <botlish_fn_12+0x1e57>
    23de:	mov    0x1b0(%rsp),%rdi
    23e6:	mov    0x10(%rdi),%rdx
    23ea:	mov    0xd8(%rdx),%rax
    23f1:	mov    0xe8(%rdx),%rcx
    23f8:	mov    0xd0(%rdx),%rdx
    23ff:	lea    0xe8(%rsp),%r9
    2407:	movq   $0x1,0xe8(%rsp)
    2413:	mov    %rax,0xf0(%rsp)
    241b:	mov    %rcx,0xf8(%rsp)
    2423:	mov    $0xc,%esi
    2428:	xor    %rcx,%rcx
    242b:	mov    0x230(%rsp),%r8
    2433:	call   2438 <botlish_fn_12+0x1e20>
			2434: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2438:	xor    %rax,%rax
    243b:	mov    0x260(%rsp),%rbx
    2443:	mov    0x268(%rsp),%r12
    244b:	mov    0x270(%rsp),%r13
    2453:	mov    0x278(%rsp),%r14
    245b:	mov    0x280(%rsp),%r15
    2463:	add    $0x290,%rsp
    246a:	mov    %rbp,%rsp
    246d:	pop    %rbp
    246e:	ret
    246f:	mov    0x1f8(%rsp),%rcx
    2477:	add    $0x1,%rcx
    247e:	mov    0x1b8(%rsp),%rdx
    2486:	mov    %r14,%r15
    2489:	mov    %r13,0x210(%rsp)
    2491:	jmp    76c <botlish_fn_12+0x154>
    2496:	mov    $0x5,%edx
    249b:	mov    $0x45,%ecx
    24a0:	mov    0x250(%rsp),%rsi
    24a8:	mov    0x1b0(%rsp),%rdi
    24b0:	call   24b5 <botlish_fn_12+0x1e9d>
			24b1: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    24b5:	jmp    ed4 <botlish_fn_12+0x8bc>
    24ba:	mov    $0x1,%edx
    24bf:	mov    0x250(%rsp),%rsi
    24c7:	mov    0x1b0(%rsp),%rdi
    24cf:	call   24d4 <botlish_fn_12+0x1ebc>
			24d0: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    24d4:	jmp    112e <botlish_fn_12+0xb16>
    24d9:	mov    0x230(%rsp),%rdx
    24e1:	mov    0x250(%rsp),%rsi
    24e9:	mov    0x1b0(%rsp),%rdi
    24f1:	call   24f6 <botlish_fn_12+0x1ede>
			24f2: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    24f6:	jmp    11cc <botlish_fn_12+0xbb4>
    24fb:	mov    $0x5,%edx
    2500:	mov    0x1d0(%rsp),%rcx
    2508:	mov    0x250(%rsp),%rsi
    2510:	mov    0x1b0(%rsp),%rdi
    2518:	call   251d <botlish_fn_12+0x1f05>
			2519: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    251d:	jmp    233e <botlish_fn_12+0x1d26>
    2522:	add    %al,(%rax)
    2524:	add    %al,(%rax)
    2526:	add    %al,(%rax)
    2528:	(bad)
    2529:	add    %al,(%rax)
    252b:	add    %al,(%rax)
    252d:	add    %al,(%rax)
    252f:	add    %bh,(%rsi)
    2531:	add    %al,(%rax)
    2533:	add    %al,(%rax)
    2535:	add    %al,(%rax)
    2537:	add    %al,(%rbx)
    2539:	add    %al,(%rax)
    253b:	add    %al,(%rcx)
    253d:	add    %al,(%rax)
    253f:	.byte 0x80

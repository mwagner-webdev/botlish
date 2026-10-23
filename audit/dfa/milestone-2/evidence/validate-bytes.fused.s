<botlish_fn_19>:
    18e8:	push   %rbp
    18e9:	mov    %rsp,%rbp
    18ec:	sub    $0x5b0,%rsp
    18f3:	mov    %rbx,0x580(%rsp)
    18fb:	mov    %r12,0x588(%rsp)
    1903:	mov    %r13,0x590(%rsp)
    190b:	mov    %r14,0x598(%rsp)
    1913:	mov    %r15,0x5a0(%rsp)
    191b:	mov    %rdi,0x4a0(%rsp)
    1923:	movq   $0x0,0x10(%rsp)
    192c:	movq   $0x0,0x18(%rsp)
    1935:	movq   $0x0,0x20(%rsp)
    193e:	movq   $0x0,0x28(%rsp)
    1947:	movq   $0x0,0x30(%rsp)
    1950:	movq   $0x0,0x78(%rsp)
    1959:	movq   $0x0,0x80(%rsp)
    1965:	movq   $0x0,0x88(%rsp)
    1971:	movq   $0x0,0x90(%rsp)
    197d:	movq   $0x0,0x98(%rsp)
    1989:	movq   $0x0,0xa0(%rsp)
    1995:	movq   $0x0,0xa8(%rsp)
    19a1:	movq   $0x0,0xb0(%rsp)
    19ad:	movq   $0x0,0xb8(%rsp)
    19b9:	movq   $0x0,0xc0(%rsp)
    19c5:	mov    %rdx,(%rsp)
    19c9:	mov    %rdx,0x4b0(%rsp)
    19d1:	mov    %rcx,0x8(%rsp)
    19d6:	mov    %rcx,0x4b8(%rsp)
    19de:	movq   $0xa,0x48(%rsp)
    19e7:	movq   $0xa,0x50(%rsp)
    19f0:	movq   $0xa,0x58(%rsp)
    19f9:	movq   $0xa,0x60(%rsp)
    1a02:	movq   $0xa,0x68(%rsp)
    1a0b:	movq   $0xa,0x70(%rsp)
    1a14:	movq   $0xa,0x38(%rsp)
    1a1d:	movq   $0xa,0x40(%rsp)
    1a26:	mov    %rsi,0x48(%rsp)
    1a2b:	mov    %rsi,0x4a8(%rsp)
    1a33:	mov    0x4a8(%rsp),%rsi
    1a3b:	mov    0x4a0(%rsp),%rdi
    1a43:	call   1a48 <botlish_fn_19+0x160>
			1a44: R_X86_64_PLT32	rt_list_len-0x4
    1a48:	mov    %rax,0x50(%rsp)
    1a4d:	mov    %rax,0x578(%rsp)
    1a55:	mov    $0x1,%esi
    1a5a:	mov    %rsi,0x4f8(%rsp)
    1a62:	movq   $0x1,0x58(%rsp)
    1a6b:	mov    $0xa,%esi
    1a70:	mov    %rsi,0x4e0(%rsp)
    1a78:	mov    0x578(%rsp),%rbx
    1a80:	mov    0x4f8(%rsp),%rsi
    1a88:	mov    0x4e0(%rsp),%rax
    1a90:	mov    %rax,0x4e8(%rsp)
    1a98:	mov    %rax,0x4f0(%rsp)
    1aa0:	mov    %rsi,%rdi
    1aa3:	and    %rbx,%rdi
    1aa6:	mov    %rsi,0x4f8(%rsp)
    1aae:	test   $0x1,%rdi
    1ab5:	jne    1af0 <botlish_fn_19+0x208>
    1abb:	mov    %rbx,%rdx
    1abe:	mov    0x4f8(%rsp),%rsi
    1ac6:	mov    0x4a0(%rsp),%rdi
    1ace:	call   1ad3 <botlish_fn_19+0x1eb>
			1acf: R_X86_64_PLT32	rt_int_cmp-0x4
    1ad3:	mov    $0x2,%ecx
    1ad8:	test   %rax,%rax
    1adb:	cmovl  0x548d(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    1ae3:	mov    %rbx,0x578(%rsp)
    1aeb:	jmp    1b10 <botlish_fn_19+0x228>
    1af0:	mov    $0x2,%ecx
    1af5:	mov    0x4f8(%rsp),%rsi
    1afd:	cmp    %rbx,%rsi
    1b00:	mov    %rbx,0x578(%rsp)
    1b08:	cmovl  0x5460(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    1b10:	cmp    $0x6,%rcx
    1b14:	je     1b37 <botlish_fn_19+0x24f>
    1b1a:	mov    $0xffffffffffffffff,%rcx
    1b21:	movq   $0xffffffffffffffff,0x38(%rsp)
    1b2a:	mov    %rcx,0x4c8(%rsp)
    1b32:	jmp    1dbf <botlish_fn_19+0x4d7>
    1b37:	mov    0x4f8(%rsp),%rsi
    1b3f:	test   $0x1,%rsi
    1b46:	je     1b6f <botlish_fn_19+0x287>
    1b4c:	mov    0x4a8(%rsp),%r13
    1b54:	mov    0x8(%r13),%rcx
    1b58:	mov    0x4f8(%rsp),%rsi
    1b60:	mov    %rsi,%rax
    1b63:	sar    $1,%rax
    1b66:	cmp    %rcx,%rax
    1b69:	jb     1bad <botlish_fn_19+0x2c5>
    1b6f:	mov    0x4f8(%rsp),%rdx
    1b77:	mov    0x4a8(%rsp),%rsi
    1b7f:	mov    0x4a0(%rsp),%rdi
    1b87:	call   1b8c <botlish_fn_19+0x2a4>
			1b88: R_X86_64_PLT32	rt_list_get-0x4
    1b8c:	mov    %rax,%rcx
    1b8f:	mov    %rax,0x4f0(%rsp)
    1b97:	test   %rcx,%rax
    1b9a:	je     1d39 <botlish_fn_19+0x451>
    1ba0:	mov    0x4f0(%rsp),%rax
    1ba8:	jmp    1bc5 <botlish_fn_19+0x2dd>
    1bad:	mov    0x4a8(%rsp),%r13
    1bb5:	mov    0x10(%r13),%rcx
    1bb9:	mov    (%rcx,%rax,8),%rax
    1bbd:	mov    %rax,0x4f0(%rsp)
    1bc5:	mov    %rax,0x60(%rsp)
    1bca:	mov    0x4f0(%rsp),%rsi
    1bd2:	mov    0x4a0(%rsp),%rdi
    1bda:	call   1bdf <botlish_fn_19+0x2f7>
			1bdb: R_X86_64_PLT32	rt_list_len-0x4
    1bdf:	mov    %rax,0x4e8(%rsp)
    1be7:	mov    %rax,0x68(%rsp)
    1bec:	movq   $0x1,0x70(%rsp)
    1bf5:	mov    0x4e8(%rsp),%rax
    1bfd:	test   $0x1,%rax
    1c03:	jne    1c38 <botlish_fn_19+0x350>
    1c09:	mov    $0x1,%esi
    1c0e:	mov    0x4e8(%rsp),%rdx
    1c16:	mov    0x4a0(%rsp),%rdi
    1c1e:	call   1c23 <botlish_fn_19+0x33b>
			1c1f: R_X86_64_PLT32	rt_int_cmp-0x4
    1c23:	mov    $0x2,%ecx
    1c28:	test   %rax,%rax
    1c2b:	cmovl  0x533d(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    1c33:	jmp    1c51 <botlish_fn_19+0x369>
    1c38:	mov    $0x2,%ecx
    1c3d:	mov    0x4e8(%rsp),%rax
    1c45:	cmp    $0x1,%rax
    1c49:	cmovg  0x531f(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    1c51:	cmp    $0x6,%rcx
    1c55:	je     1d01 <botlish_fn_19+0x419>
    1c5b:	mov    $0x3,%edx
    1c60:	movq   $0x3,0x28(%rsp)
    1c69:	mov    0x4f8(%rsp),%rsi
    1c71:	test   $0x1,%rsi
    1c78:	jne    1c8b <botlish_fn_19+0x3a3>
    1c7e:	mov    0x4f8(%rsp),%rsi
    1c86:	jmp    1cc2 <botlish_fn_19+0x3da>
    1c8b:	mov    0x4f8(%rsp),%rsi
    1c93:	mov    %rsi,%rcx
    1c96:	add    $0x2,%rcx
    1c9a:	seto   %al
    1c9d:	test   %al,%al
    1c9f:	je     1cb2 <botlish_fn_19+0x3ca>
    1ca5:	mov    0x4f8(%rsp),%rsi
    1cad:	jmp    1cc2 <botlish_fn_19+0x3da>
    1cb2:	mov    %rcx,%rsi
    1cb5:	mov    %rcx,0x4f8(%rsp)
    1cbd:	jmp    1cda <botlish_fn_19+0x3f2>
    1cc2:	mov    0x4a0(%rsp),%rdi
    1cca:	call   1ccf <botlish_fn_19+0x3e7>
			1ccb: R_X86_64_PLT32	rt_int_add-0x4
    1ccf:	mov    %rax,%rsi
    1cd2:	mov    %rax,0x4f8(%rsp)
    1cda:	mov    %rsi,0x58(%rsp)
    1cdf:	mov    $0x1,%esi
    1ce4:	mov    %rsi,0x4e0(%rsp)
    1cec:	mov    0x578(%rsp),%rbx
    1cf4:	mov    0x4f8(%rsp),%rsi
    1cfc:	jmp    1aa0 <botlish_fn_19+0x1b8>
    1d01:	mov    0x4f0(%rsp),%rax
    1d09:	mov    0x8(%rax),%rax
    1d0d:	test   %rax,%rax
    1d10:	jne    1d8d <botlish_fn_19+0x4a5>
    1d16:	mov    $0x1,%edx
    1d1b:	mov    0x4f0(%rsp),%rsi
    1d23:	mov    0x4a0(%rsp),%rdi
    1d2b:	call   1d30 <botlish_fn_19+0x448>
			1d2c: R_X86_64_PLT32	rt_list_get-0x4
    1d30:	test   %rax,%rax
    1d33:	jne    1d85 <botlish_fn_19+0x49d>
    1d39:	mov    0x4a0(%rsp),%rdi
    1d41:	call   1d46 <botlish_fn_19+0x45e>
			1d42: R_X86_64_PLT32	rt_co_failed-0x4
    1d46:	mov    %rax,0x40(%rsp)
    1d4b:	mov    %rax,%rsi
    1d4e:	mov    0x4a0(%rsp),%rdi
    1d56:	call   1d5b <botlish_fn_19+0x473>
			1d57: R_X86_64_PLT32	rt_co_resume0-0x4
    1d5b:	test   %rax,%rax
    1d5e:	je     6d30 <botlish_fn_19+0x5448>
    1d64:	mov    0x4a0(%rsp),%rdi
    1d6c:	mov    0x10(%rdi),%rax
    1d70:	mov    0x48(%rax),%rsi
    1d74:	mov    0x1b0(%rax),%rdx
    1d7b:	call   1d80 <botlish_fn_19+0x498>
			1d7c: R_X86_64_PLT32	rt_raise-0x4
    1d80:	jmp    6d30 <botlish_fn_19+0x5448>
    1d85:	mov    %rax,%rcx
    1d88:	jmp    1d9c <botlish_fn_19+0x4b4>
    1d8d:	mov    0x4f0(%rsp),%rax
    1d95:	mov    0x10(%rax),%rdx
    1d99:	mov    (%rdx),%rcx
    1d9c:	mov    %rcx,0x38(%rsp)
    1da1:	mov    $0x1,%r10d
    1da7:	mov    %r10,0x4c8(%rsp)
    1daf:	mov    0x4c8(%rsp),%rax
    1db7:	mov    %rax,0x4e0(%rsp)
    1dbf:	mov    %rcx,0x10(%rsp)
    1dc4:	mov    %rcx,%r12
    1dc7:	movq   $0xa,0x88(%rsp)
    1dd3:	movq   $0xa,0x90(%rsp)
    1ddf:	movq   $0xa,0x78(%rsp)
    1de8:	movq   $0xa,0x80(%rsp)
    1df4:	mov    0x4b0(%rsp),%rcx
    1dfc:	mov    %r12,0x528(%rsp)
    1e04:	mov    %rcx,0x88(%rsp)
    1e0c:	movq   $0x1,0x18(%rsp)
    1e15:	mov    $0x3,%r8d
    1e1b:	mov    %r8,0x570(%rsp)
    1e23:	movq   $0x3,0x20(%rsp)
    1e2c:	lea    0x158(%rsp),%rdx
    1e34:	movq   $0x1,0x158(%rsp)
    1e40:	movq   $0x3,0x160(%rsp)
    1e4c:	mov    $0x2,%esi
    1e51:	mov    0x4a0(%rsp),%rdi
    1e59:	call   1e5e <botlish_fn_19+0x576>
			1e5a: R_X86_64_PLT32	rt_list_new-0x4
    1e5e:	test   %rax,%rax
    1e61:	jne    1ee4 <botlish_fn_19+0x5fc>
    1e67:	mov    0x4a0(%rsp),%rdi
    1e6f:	call   1e74 <botlish_fn_19+0x58c>
			1e70: R_X86_64_PLT32	rt_co_failed-0x4
    1e74:	mov    %rax,0x80(%rsp)
    1e7c:	mov    %rax,%rsi
    1e7f:	mov    0x4a0(%rsp),%rdi
    1e87:	call   1e8c <botlish_fn_19+0x5a4>
			1e88: R_X86_64_PLT32	rt_co_resume0-0x4
    1e8c:	test   %rax,%rax
    1e8f:	je     1eb1 <botlish_fn_19+0x5c9>
    1e95:	mov    0x4a0(%rsp),%rdi
    1e9d:	mov    0x10(%rdi),%rax
    1ea1:	mov    0x48(%rax),%rsi
    1ea5:	mov    0x1b0(%rax),%rdx
    1eac:	call   1eb1 <botlish_fn_19+0x5c9>
			1ead: R_X86_64_PLT32	rt_raise-0x4
    1eb1:	mov    0x4a0(%rsp),%rdi
    1eb9:	call   1ebe <botlish_fn_19+0x5d6>
			1eba: R_X86_64_PLT32	rt_declared_error-0x4
    1ebe:	cmp    $0x6,%rax
    1ec2:	je     6d30 <botlish_fn_19+0x5448>
    1ec8:	mov    0x4a0(%rsp),%rdi
    1ed0:	call   1ed5 <botlish_fn_19+0x5ed>
			1ed1: R_X86_64_PLT32	rt_declared_error-0x4
    1ed5:	cmp    $0x7,%rax
    1ed9:	jne    6d30 <botlish_fn_19+0x5448>
    1edf:	jmp    6d30 <botlish_fn_19+0x5448>
    1ee4:	mov    %rax,0x18(%rsp)
    1ee9:	mov    %rax,%rsi
    1eec:	mov    0x4a0(%rsp),%rdi
    1ef4:	call   1ef9 <botlish_fn_19+0x611>
			1ef5: R_X86_64_PLT32	rt_mv_from_list-0x4
    1ef9:	mov    %rax,0x90(%rsp)
    1f01:	mov    %rax,0x568(%rsp)
    1f09:	movq   $0x6,0x78(%rsp)
    1f12:	mov    $0x9,%esi
    1f17:	movq   $0x9,(%rsp)
    1f1f:	mov    $0x1,%edx
    1f24:	movq   $0x1,0x18(%rsp)
    1f2d:	mov    0x4a0(%rsp),%rdi
    1f35:	call   1f3a <botlish_fn_19+0x652>
			1f36: R_X86_64_PLT32	rt_mutarray_create-0x4
    1f3a:	mov    %rax,%rbx
    1f3d:	test   %rbx,%rbx
    1f40:	je     6d30 <botlish_fn_19+0x5448>
    1f46:	mov    %rbx,(%rsp)
    1f4a:	mov    0x18(%rbx),%rax
    1f4e:	test   %rax,%rax
    1f51:	je     6dff <botlish_fn_19+0x5517>
    1f57:	mov    %rbx,%rax
    1f5a:	mov    %r12,%rcx
    1f5d:	mov    %rbx,0x560(%rsp)
    1f65:	mov    0x10(%rax),%rax
    1f69:	mov    %rcx,0x8(%rax)
    1f6d:	mov    $0x1,%ebx
    1f72:	mov    %rbx,0x4d0(%rsp)
    1f7a:	mov    $0x6,%r15d
    1f80:	mov    %r15,0x500(%rsp)
    1f88:	mov    $0x8,%ecx
    1f8d:	mov    %rcx,0x558(%rsp)
    1f95:	mov    $0xffffffffffffffff,%rdx
    1f9c:	mov    %rdx,0x550(%rsp)
    1fa4:	mov    $0x7,%ecx
    1fa9:	mov    %rcx,0x548(%rsp)
    1fb1:	mov    0x560(%rsp),%rax
    1fb9:	mov    0x560(%rsp),%rax
    1fc1:	mov    0x10(%rax),%rax
    1fc5:	mov    (%rax),%rsi
    1fc8:	mov    %rsi,0x10(%rsp)
    1fcd:	mov    %rsi,0x540(%rsp)
    1fd5:	mov    0x560(%rsp),%rax
    1fdd:	mov    0x10(%rax),%rax
    1fe1:	mov    0x8(%rax),%rsi
    1fe5:	mov    %rsi,0x18(%rsp)
    1fea:	test   $0x1,%rsi
    1ff1:	mov    %rsi,0x538(%rsp)
    1ff9:	jne    2031 <botlish_fn_19+0x749>
    1fff:	mov    0x550(%rsp),%rdx
    2007:	mov    0x538(%rsp),%rsi
    200f:	mov    0x4a0(%rsp),%rdi
    2017:	call   201c <botlish_fn_19+0x734>
			2018: R_X86_64_PLT32	rt_int_cmp-0x4
    201c:	mov    $0x2,%ecx
    2021:	test   %rax,%rax
    2024:	cmove  0x4f44(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    202c:	jmp    204a <botlish_fn_19+0x762>
    2031:	mov    $0x2,%ecx
    2036:	mov    0x538(%rsp),%rsi
    203e:	cmp    $0xffffffffffffffff,%rsi
    2042:	cmove  0x4f26(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    204a:	cmp    $0x6,%rcx
    204e:	je     66c1 <botlish_fn_19+0x4dd9>
    2054:	mov    0x538(%rsp),%rsi
    205c:	mov    0x4a0(%rsp),%rdi
    2064:	call   2069 <botlish_fn_19+0x781>
			2065: R_X86_64_PLT32	botlish_fn_13-0x4
    2069:	cmp    $0x6,%rax
    206d:	je     6164 <botlish_fn_19+0x487c>
    2073:	movq   $0xa,0xa0(%rsp)
    207f:	movq   $0xa,0xa8(%rsp)
    208b:	movq   $0xa,0xb0(%rsp)
    2097:	movq   $0xa,0xb8(%rsp)
    20a3:	movq   $0xa,0xc0(%rsp)
    20af:	movq   $0xa,0x30(%rsp)
    20b8:	movq   $0xa,0x98(%rsp)
    20c4:	mov    0x4a0(%rsp),%rdi
    20cc:	mov    0x10(%rdi),%rax
    20d0:	mov    0x1e8(%rax),%r14
    20d7:	mov    0x538(%rsp),%rsi
    20df:	test   $0x1,%rsi
    20e6:	jne    211f <botlish_fn_19+0x837>
    20ec:	mov    0x550(%rsp),%rdx
    20f4:	mov    0x538(%rsp),%rsi
    20fc:	mov    0x4a0(%rsp),%rdi
    2104:	call   2109 <botlish_fn_19+0x821>
			2105: R_X86_64_PLT32	rt_int_cmp-0x4
    2109:	mov    $0x2,%r9d
    210f:	test   %rax,%rax
    2112:	cmovl  0x4e56(%rip),%r9        # 6f70 <botlish_fn_19+0x5688>
    211a:	jmp    2139 <botlish_fn_19+0x851>
    211f:	mov    $0x2,%r9d
    2125:	mov    0x538(%rsp),%rsi
    212d:	cmp    $0xffffffffffffffff,%rsi
    2131:	cmovl  0x4e37(%rip),%r9        # 6f70 <botlish_fn_19+0x5688>
    2139:	cmp    $0x6,%r9
    213d:	je     21c6 <botlish_fn_19+0x8de>
    2143:	mov    0x538(%rsp),%rsi
    214b:	test   $0x1,%rsi
    2152:	jne    2187 <botlish_fn_19+0x89f>
    2158:	mov    $0x1ff,%edx
    215d:	mov    0x538(%rsp),%rsi
    2165:	mov    0x4a0(%rsp),%rdi
    216d:	call   2172 <botlish_fn_19+0x88a>
			216e: R_X86_64_PLT32	rt_int_cmp-0x4
    2172:	mov    $0x2,%ecx
    2177:	test   %rax,%rax
    217a:	cmovg  0x4dee(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    2182:	jmp    21a3 <botlish_fn_19+0x8bb>
    2187:	mov    $0x2,%ecx
    218c:	mov    0x538(%rsp),%rsi
    2194:	cmp    $0x1ff,%rsi
    219b:	cmovg  0x4dcd(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    21a3:	cmp    $0x6,%rcx
    21a7:	je     21c6 <botlish_fn_19+0x8de>
    21ad:	mov    0x538(%rsp),%rsi
    21b5:	mov    %rsi,%rax
    21b8:	sar    $1,%rax
    21bb:	movzbq 0x11(%r14,%rax,1),%rcx
    21c1:	jmp    21ce <botlish_fn_19+0x8e6>
    21c6:	movzbq 0x111(%r14),%rcx
    21ce:	mov    %rcx,%rdx
    21d1:	shl    $1,%rdx
    21d4:	or     $0x1,%rdx
    21d8:	mov    $0x2,%eax
    21dd:	cmp    $0x3,%rdx
    21e1:	cmove  0x4d87(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    21e9:	cmp    $0x6,%rax
    21ed:	je     3523 <botlish_fn_19+0x1c3b>
    21f3:	mov    %rcx,%rdx
    21f6:	shl    $1,%rdx
    21f9:	or     $0x1,%rdx
    21fd:	mov    $0x2,%eax
    2202:	cmp    $0x5,%rdx
    2206:	cmove  0x4d62(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    220e:	cmp    $0x6,%rax
    2212:	je     29ac <botlish_fn_19+0x10c4>
    2218:	mov    %rcx,%rax
    221b:	shl    $1,%rax
    221e:	or     $0x1,%rax
    2222:	mov    $0x2,%edx
    2227:	cmp    $0x7,%rax
    222b:	cmove  0x4d3d(%rip),%rdx        # 6f70 <botlish_fn_19+0x5688>
    2233:	cmp    $0x6,%rdx
    2237:	je     2698 <botlish_fn_19+0xdb0>
    223d:	shl    $1,%rcx
    2240:	or     $0x1,%rcx
    2244:	mov    $0x2,%eax
    2249:	cmp    $0x9,%rcx
    224d:	cmove  0x4d1b(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    2255:	cmp    $0x6,%rax
    2259:	je     2382 <botlish_fn_19+0xa9a>
    225f:	mov    0x538(%rsp),%rsi
    2267:	test   $0x1,%rsi
    226e:	jne    22a6 <botlish_fn_19+0x9be>
    2274:	mov    0x550(%rsp),%rdx
    227c:	mov    0x538(%rsp),%rsi
    2284:	mov    0x4a0(%rsp),%rdi
    228c:	call   2291 <botlish_fn_19+0x9a9>
			228d: R_X86_64_PLT32	rt_int_cmp-0x4
    2291:	mov    $0x2,%ecx
    2296:	test   %rax,%rax
    2299:	cmove  0x4ccf(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    22a1:	jmp    22bf <botlish_fn_19+0x9d7>
    22a6:	mov    $0x2,%ecx
    22ab:	mov    0x538(%rsp),%rsi
    22b3:	cmp    $0xffffffffffffffff,%rsi
    22b7:	cmove  0x4cb1(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    22bf:	cmp    $0x6,%rcx
    22c3:	je     232a <botlish_fn_19+0xa42>
    22c9:	mov    0x4a0(%rsp),%rdi
    22d1:	mov    0x10(%rdi),%rdx
    22d5:	mov    0x260(%rdx),%rax
    22dc:	mov    (%rdx),%rcx
    22df:	mov    0x220(%rdx),%rdx
    22e6:	lea    0x398(%rsp),%r9
    22ee:	mov    %rax,0x398(%rsp)
    22f6:	mov    %rcx,0x3a0(%rsp)
    22fe:	mov    0x538(%rsp),%rsi
    2306:	mov    %rsi,0x3a8(%rsp)
    230e:	mov    $0x1,%esi
    2313:	mov    $0x9,%ecx
    2318:	mov    0x570(%rsp),%r8
    2320:	call   2325 <botlish_fn_19+0xa3d>
			2321: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2325:	jmp    329a <botlish_fn_19+0x19b2>
    232a:	mov    0x4a0(%rsp),%rdi
    2332:	mov    0x10(%rdi),%r8
    2336:	mov    0x260(%r8),%rsi
    233d:	mov    (%r8),%rdi
    2340:	mov    0x218(%r8),%rdx
    2347:	lea    0x388(%rsp),%r9
    234f:	mov    %rsi,0x388(%rsp)
    2357:	mov    %rdi,0x390(%rsp)
    235f:	mov    $0x2,%r8d
    2365:	mov    0x558(%rsp),%rcx
    236d:	mov    0x4a0(%rsp),%rdi
    2375:	mov    %r8,%rsi
    2378:	call   237d <botlish_fn_19+0xa95>
			2379: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    237d:	jmp    329a <botlish_fn_19+0x19b2>
    2382:	mov    0x4a0(%rsp),%rdi
    238a:	mov    0x10(%rdi),%r8
    238e:	mov    0x250(%r8),%r12
    2395:	mov    0x538(%rsp),%rsi
    239d:	test   $0x1,%rsi
    23a4:	jne    23dc <botlish_fn_19+0xaf4>
    23aa:	mov    0x550(%rsp),%rdx
    23b2:	mov    0x538(%rsp),%rsi
    23ba:	mov    0x4a0(%rsp),%rdi
    23c2:	call   23c7 <botlish_fn_19+0xadf>
			23c3: R_X86_64_PLT32	rt_int_cmp-0x4
    23c7:	mov    $0x2,%ecx
    23cc:	test   %rax,%rax
    23cf:	cmovl  0x4b99(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    23d7:	jmp    23f5 <botlish_fn_19+0xb0d>
    23dc:	mov    $0x2,%ecx
    23e1:	mov    0x538(%rsp),%rsi
    23e9:	cmp    $0xffffffffffffffff,%rsi
    23ed:	cmovl  0x4b7b(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    23f5:	cmp    $0x6,%rcx
    23f9:	je     2482 <botlish_fn_19+0xb9a>
    23ff:	mov    0x538(%rsp),%rsi
    2407:	test   $0x1,%rsi
    240e:	jne    2443 <botlish_fn_19+0xb5b>
    2414:	mov    $0x1ff,%edx
    2419:	mov    0x538(%rsp),%rsi
    2421:	mov    0x4a0(%rsp),%rdi
    2429:	call   242e <botlish_fn_19+0xb46>
			242a: R_X86_64_PLT32	rt_int_cmp-0x4
    242e:	mov    $0x2,%ecx
    2433:	test   %rax,%rax
    2436:	cmovg  0x4b32(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    243e:	jmp    245f <botlish_fn_19+0xb77>
    2443:	mov    $0x2,%ecx
    2448:	mov    0x538(%rsp),%rsi
    2450:	cmp    $0x1ff,%rsi
    2457:	cmovg  0x4b11(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    245f:	cmp    $0x6,%rcx
    2463:	je     2482 <botlish_fn_19+0xb9a>
    2469:	mov    0x538(%rsp),%rsi
    2471:	mov    %rsi,%rax
    2474:	sar    $1,%rax
    2477:	movzbq 0x11(%r12,%rax,1),%rsi
    247d:	jmp    248b <botlish_fn_19+0xba3>
    2482:	movzbq 0xc1c(%r12),%rsi
    248b:	mov    %rsi,%rcx
    248e:	shl    $1,%rcx
    2491:	or     $0x1,%rcx
    2495:	mov    $0x2,%eax
    249a:	cmp    $0x19,%rcx
    249e:	cmovl  0x4aca(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    24a6:	cmp    $0x6,%rax
    24aa:	je     2643 <botlish_fn_19+0xd5b>
    24b0:	mov    %rsi,%rax
    24b3:	shl    $1,%rax
    24b6:	mov    %rsi,0x520(%rsp)
    24be:	or     $0x1,%rax
    24c2:	mov    $0x2,%esi
    24c7:	cmp    $0x19,%rax
    24cb:	cmove  0x4a9d(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    24d3:	cmp    $0x6,%rsi
    24d7:	je     2636 <botlish_fn_19+0xd4e>
    24dd:	mov    0x538(%rsp),%rsi
    24e5:	test   $0x1,%rsi
    24ec:	jne    2524 <botlish_fn_19+0xc3c>
    24f2:	mov    0x550(%rsp),%rdx
    24fa:	mov    0x538(%rsp),%rsi
    2502:	mov    0x4a0(%rsp),%rdi
    250a:	call   250f <botlish_fn_19+0xc27>
			250b: R_X86_64_PLT32	rt_int_cmp-0x4
    250f:	mov    $0x2,%ecx
    2514:	test   %rax,%rax
    2517:	cmove  0x4a51(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    251f:	jmp    253d <botlish_fn_19+0xc55>
    2524:	mov    $0x2,%ecx
    2529:	mov    0x538(%rsp),%rsi
    2531:	cmp    $0xffffffffffffffff,%rsi
    2535:	cmove  0x4a33(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    253d:	cmp    $0x6,%rcx
    2541:	je     25c9 <botlish_fn_19+0xce1>
    2547:	mov    0x4a0(%rsp),%rdi
    254f:	mov    0x10(%rdi),%rax
    2553:	mov    0x258(%rax),%rbx
    255a:	mov    $0x1,%r12d
    2560:	mov    0x520(%rsp),%rsi
    2568:	shl    $1,%rsi
    256b:	or     $0x1,%rsi
    256f:	call   2574 <botlish_fn_19+0xc8c>
			2570: R_X86_64_PLT32	botlish_fn_3-0x4
    2574:	mov    0x4a0(%rsp),%rdi
    257c:	mov    0x10(%rdi),%rcx
    2580:	mov    0x220(%rcx),%rdx
    2587:	lea    0x370(%rsp),%r9
    258f:	mov    %rbx,0x370(%rsp)
    2597:	mov    %rax,0x378(%rsp)
    259f:	mov    0x538(%rsp),%rsi
    25a7:	mov    %rsi,0x380(%rsp)
    25af:	mov    $0x9,%ecx
    25b4:	mov    %r12,%rsi
    25b7:	mov    0x570(%rsp),%r8
    25bf:	call   25c4 <botlish_fn_19+0xcdc>
			25c0: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    25c4:	jmp    329a <botlish_fn_19+0x19b2>
    25c9:	mov    0x520(%rsp),%rsi
    25d1:	mov    0x4a0(%rsp),%rdi
    25d9:	mov    0x10(%rdi),%rax
    25dd:	mov    0x258(%rax),%rbx
    25e4:	shl    $1,%rsi
    25e7:	or     $0x1,%rsi
    25eb:	call   25f0 <botlish_fn_19+0xd08>
			25ec: R_X86_64_PLT32	botlish_fn_3-0x4
    25f0:	mov    0x4a0(%rsp),%rdi
    25f8:	mov    0x10(%rdi),%rcx
    25fc:	mov    0x218(%rcx),%rdx
    2603:	lea    0x360(%rsp),%r9
    260b:	mov    %rbx,0x360(%rsp)
    2613:	mov    %rax,0x368(%rsp)
    261b:	mov    $0x2,%r8d
    2621:	mov    0x558(%rsp),%rcx
    2629:	mov    %r8,%rsi
    262c:	call   2631 <botlish_fn_19+0xd49>
			262d: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2631:	jmp    329a <botlish_fn_19+0x19b2>
    2636:	mov    0x538(%rsp),%rsi
    263e:	jmp    352a <botlish_fn_19+0x1c42>
    2643:	shl    $1,%rsi
    2646:	or     $0x1,%rsi
    264a:	mov    %rsi,0xc0(%rsp)
    2652:	mov    %rsi,0x520(%rsp)
    265a:	mov    $0x1,%ebx
    265f:	movq   $0x1,0x30(%rsp)
    2668:	mov    $0x5,%r12d
    266e:	mov    $0xa,%esi
    2673:	mov    %rsi,0x4c0(%rsp)
    267b:	mov    %rsi,0x508(%rsp)
    2683:	mov    %rsi,0x510(%rsp)
    268b:	mov    %rsi,0x518(%rsp)
    2693:	jmp    35cc <botlish_fn_19+0x1ce4>
    2698:	mov    0x4a0(%rsp),%rdi
    26a0:	mov    0x10(%rdi),%rax
    26a4:	mov    0x240(%rax),%rbx
    26ab:	mov    0x538(%rsp),%rsi
    26b3:	test   $0x1,%rsi
    26ba:	jne    26f2 <botlish_fn_19+0xe0a>
    26c0:	mov    0x550(%rsp),%rdx
    26c8:	mov    0x538(%rsp),%rsi
    26d0:	mov    0x4a0(%rsp),%rdi
    26d8:	call   26dd <botlish_fn_19+0xdf5>
			26d9: R_X86_64_PLT32	rt_int_cmp-0x4
    26dd:	mov    $0x2,%ecx
    26e2:	test   %rax,%rax
    26e5:	cmovl  0x4883(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    26ed:	jmp    270b <botlish_fn_19+0xe23>
    26f2:	mov    $0x2,%ecx
    26f7:	mov    0x538(%rsp),%rsi
    26ff:	cmp    $0xffffffffffffffff,%rsi
    2703:	cmovl  0x4865(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    270b:	cmp    $0x6,%rcx
    270f:	je     2797 <botlish_fn_19+0xeaf>
    2715:	mov    0x538(%rsp),%rsi
    271d:	test   $0x1,%rsi
    2724:	jne    2759 <botlish_fn_19+0xe71>
    272a:	mov    $0x1ff,%edx
    272f:	mov    0x538(%rsp),%rsi
    2737:	mov    0x4a0(%rsp),%rdi
    273f:	call   2744 <botlish_fn_19+0xe5c>
			2740: R_X86_64_PLT32	rt_int_cmp-0x4
    2744:	mov    $0x2,%esi
    2749:	test   %rax,%rax
    274c:	cmovg  0x481c(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    2754:	jmp    2774 <botlish_fn_19+0xe8c>
    2759:	mov    $0x2,%esi
    275e:	mov    0x538(%rsp),%rax
    2766:	cmp    $0x1ff,%rax
    276c:	cmovg  0x47fc(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    2774:	cmp    $0x6,%rsi
    2778:	je     2797 <botlish_fn_19+0xeaf>
    277e:	mov    0x538(%rsp),%rsi
    2786:	mov    %rsi,%rax
    2789:	sar    $1,%rax
    278c:	movzbq 0x11(%rbx,%rax,1),%rsi
    2792:	jmp    279f <botlish_fn_19+0xeb7>
    2797:	movzbq 0x919(%rbx),%rsi
    279f:	mov    %rsi,%rcx
    27a2:	shl    $1,%rcx
    27a5:	or     $0x1,%rcx
    27a9:	mov    $0x2,%eax
    27ae:	cmp    $0x13,%rcx
    27b2:	cmovl  0x47b6(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    27ba:	cmp    $0x6,%rax
    27be:	je     2957 <botlish_fn_19+0x106f>
    27c4:	mov    %rsi,%rcx
    27c7:	shl    $1,%rcx
    27ca:	mov    %rsi,0x518(%rsp)
    27d2:	or     $0x1,%rcx
    27d6:	mov    $0x2,%eax
    27db:	cmp    $0x13,%rcx
    27df:	cmove  0x4789(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    27e7:	cmp    $0x6,%rax
    27eb:	je     294a <botlish_fn_19+0x1062>
    27f1:	mov    0x538(%rsp),%rsi
    27f9:	test   $0x1,%rsi
    2800:	jne    2838 <botlish_fn_19+0xf50>
    2806:	mov    0x550(%rsp),%rdx
    280e:	mov    0x538(%rsp),%rsi
    2816:	mov    0x4a0(%rsp),%rdi
    281e:	call   2823 <botlish_fn_19+0xf3b>
			281f: R_X86_64_PLT32	rt_int_cmp-0x4
    2823:	mov    $0x2,%ecx
    2828:	test   %rax,%rax
    282b:	cmove  0x473d(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    2833:	jmp    2851 <botlish_fn_19+0xf69>
    2838:	mov    $0x2,%ecx
    283d:	mov    0x538(%rsp),%rsi
    2845:	cmp    $0xffffffffffffffff,%rsi
    2849:	cmove  0x471f(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    2851:	cmp    $0x6,%rcx
    2855:	je     28dd <botlish_fn_19+0xff5>
    285b:	mov    0x4a0(%rsp),%rdi
    2863:	mov    0x10(%rdi),%rax
    2867:	mov    0x248(%rax),%rbx
    286e:	mov    $0x1,%r12d
    2874:	mov    0x518(%rsp),%rsi
    287c:	shl    $1,%rsi
    287f:	or     $0x1,%rsi
    2883:	call   2888 <botlish_fn_19+0xfa0>
			2884: R_X86_64_PLT32	botlish_fn_1-0x4
    2888:	mov    0x4a0(%rsp),%rdi
    2890:	mov    0x10(%rdi),%rcx
    2894:	mov    0x220(%rcx),%rdx
    289b:	lea    0x348(%rsp),%r9
    28a3:	mov    %rbx,0x348(%rsp)
    28ab:	mov    %rax,0x350(%rsp)
    28b3:	mov    0x538(%rsp),%rsi
    28bb:	mov    %rsi,0x358(%rsp)
    28c3:	mov    $0x9,%ecx
    28c8:	mov    %r12,%rsi
    28cb:	mov    0x570(%rsp),%r8
    28d3:	call   28d8 <botlish_fn_19+0xff0>
			28d4: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    28d8:	jmp    329a <botlish_fn_19+0x19b2>
    28dd:	mov    0x518(%rsp),%rsi
    28e5:	mov    0x4a0(%rsp),%rdi
    28ed:	mov    0x10(%rdi),%rax
    28f1:	mov    0x248(%rax),%rbx
    28f8:	shl    $1,%rsi
    28fb:	or     $0x1,%rsi
    28ff:	call   2904 <botlish_fn_19+0x101c>
			2900: R_X86_64_PLT32	botlish_fn_1-0x4
    2904:	mov    0x4a0(%rsp),%rdi
    290c:	mov    0x10(%rdi),%rcx
    2910:	mov    0x218(%rcx),%rdx
    2917:	lea    0x338(%rsp),%r9
    291f:	mov    %rbx,0x338(%rsp)
    2927:	mov    %rax,0x340(%rsp)
    292f:	mov    $0x2,%r8d
    2935:	mov    0x558(%rsp),%rcx
    293d:	mov    %r8,%rsi
    2940:	call   2945 <botlish_fn_19+0x105d>
			2941: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2945:	jmp    329a <botlish_fn_19+0x19b2>
    294a:	mov    0x538(%rsp),%rsi
    2952:	jmp    352a <botlish_fn_19+0x1c42>
    2957:	shl    $1,%rsi
    295a:	or     $0x1,%rsi
    295e:	mov    %rsi,0xb8(%rsp)
    2966:	mov    %rsi,0x518(%rsp)
    296e:	mov    $0x1,%ebx
    2973:	movq   $0x1,0x30(%rsp)
    297c:	mov    $0x4,%r12d
    2982:	mov    $0xa,%esi
    2987:	mov    %rsi,0x4c0(%rsp)
    298f:	mov    %rsi,0x508(%rsp)
    2997:	mov    %rsi,0x510(%rsp)
    299f:	mov    %rsi,0x520(%rsp)
    29a7:	jmp    35cc <botlish_fn_19+0x1ce4>
    29ac:	mov    0x4a0(%rsp),%rdi
    29b4:	mov    0x10(%rdi),%rax
    29b8:	mov    0x200(%rax),%rbx
    29bf:	mov    0x538(%rsp),%rsi
    29c7:	test   $0x1,%rsi
    29ce:	jne    2a06 <botlish_fn_19+0x111e>
    29d4:	mov    0x550(%rsp),%rdx
    29dc:	mov    0x538(%rsp),%rsi
    29e4:	mov    0x4a0(%rsp),%rdi
    29ec:	call   29f1 <botlish_fn_19+0x1109>
			29ed: R_X86_64_PLT32	rt_int_cmp-0x4
    29f1:	mov    $0x2,%ecx
    29f6:	test   %rax,%rax
    29f9:	cmovl  0x456f(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    2a01:	jmp    2a1f <botlish_fn_19+0x1137>
    2a06:	mov    $0x2,%ecx
    2a0b:	mov    0x538(%rsp),%rsi
    2a13:	cmp    $0xffffffffffffffff,%rsi
    2a17:	cmovl  0x4551(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    2a1f:	cmp    $0x6,%rcx
    2a23:	je     2aa9 <botlish_fn_19+0x11c1>
    2a29:	mov    0x538(%rsp),%rsi
    2a31:	test   $0x1,%rsi
    2a38:	jne    2a6d <botlish_fn_19+0x1185>
    2a3e:	mov    $0x1ff,%edx
    2a43:	mov    0x538(%rsp),%rsi
    2a4b:	mov    0x4a0(%rsp),%rdi
    2a53:	call   2a58 <botlish_fn_19+0x1170>
			2a54: R_X86_64_PLT32	rt_int_cmp-0x4
    2a58:	mov    $0x2,%ecx
    2a5d:	test   %rax,%rax
    2a60:	cmovg  0x4508(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    2a68:	jmp    2a89 <botlish_fn_19+0x11a1>
    2a6d:	mov    $0x2,%ecx
    2a72:	mov    0x538(%rsp),%rsi
    2a7a:	cmp    $0x1ff,%rsi
    2a81:	cmovg  0x44e7(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    2a89:	cmp    $0x6,%rcx
    2a8d:	je     2aa9 <botlish_fn_19+0x11c1>
    2a93:	mov    0x538(%rsp),%rsi
    2a9b:	sar    $1,%rsi
    2a9e:	movzbq 0x11(%rbx,%rsi,1),%rsi
    2aa4:	jmp    2ab1 <botlish_fn_19+0x11c9>
    2aa9:	movzbq 0x212(%rbx),%rsi
    2ab1:	mov    %rsi,%r8
    2ab4:	shl    $1,%r8
    2ab7:	or     $0x1,%r8
    2abb:	mov    $0x2,%edi
    2ac0:	cmp    $0x5,%r8
    2ac4:	cmovl  0x44a4(%rip),%rdi        # 6f70 <botlish_fn_19+0x5688>
    2acc:	cmp    $0x6,%rdi
    2ad0:	je     34cc <botlish_fn_19+0x1be4>
    2ad6:	mov    %rsi,%rcx
    2ad9:	shl    $1,%rcx
    2adc:	or     $0x1,%rcx
    2ae0:	mov    $0x2,%eax
    2ae5:	cmp    $0x5,%rcx
    2ae9:	cmove  0x447f(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    2af1:	cmp    $0x6,%rax
    2af5:	je     34c0 <botlish_fn_19+0x1bd8>
    2afb:	mov    %rsi,%rcx
    2afe:	shl    $1,%rcx
    2b01:	or     $0x1,%rcx
    2b05:	mov    $0x2,%eax
    2b0a:	cmp    $0x7,%rcx
    2b0e:	cmove  0x445a(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    2b16:	cmp    $0x6,%rax
    2b1a:	je     2fec <botlish_fn_19+0x1704>
    2b20:	mov    %rsi,%rcx
    2b23:	shl    $1,%rcx
    2b26:	mov    %rsi,0x4c0(%rsp)
    2b2e:	or     $0x1,%rcx
    2b32:	mov    $0x2,%eax
    2b37:	cmp    $0x9,%rcx
    2b3b:	cmove  0x442d(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    2b43:	cmp    $0x6,%rax
    2b47:	je     2ca8 <botlish_fn_19+0x13c0>
    2b4d:	mov    0x538(%rsp),%rsi
    2b55:	test   $0x1,%rsi
    2b5c:	jne    2b95 <botlish_fn_19+0x12ad>
    2b62:	mov    0x550(%rsp),%rdx
    2b6a:	mov    0x538(%rsp),%rsi
    2b72:	mov    0x4a0(%rsp),%rdi
    2b7a:	call   2b7f <botlish_fn_19+0x1297>
			2b7b: R_X86_64_PLT32	rt_int_cmp-0x4
    2b7f:	mov    $0x2,%r11d
    2b85:	test   %rax,%rax
    2b88:	cmove  0x43e0(%rip),%r11        # 6f70 <botlish_fn_19+0x5688>
    2b90:	jmp    2baf <botlish_fn_19+0x12c7>
    2b95:	mov    $0x2,%r11d
    2b9b:	mov    0x538(%rsp),%rsi
    2ba3:	cmp    $0xffffffffffffffff,%rsi
    2ba7:	cmove  0x43c1(%rip),%r11        # 6f70 <botlish_fn_19+0x5688>
    2baf:	cmp    $0x6,%r11
    2bb3:	je     2c3b <botlish_fn_19+0x1353>
    2bb9:	mov    0x4a0(%rsp),%rdi
    2bc1:	mov    0x10(%rdi),%rax
    2bc5:	mov    0x238(%rax),%rbx
    2bcc:	mov    $0x1,%r12d
    2bd2:	mov    0x4c0(%rsp),%rsi
    2bda:	shl    $1,%rsi
    2bdd:	or     $0x1,%rsi
    2be1:	call   2be6 <botlish_fn_19+0x12fe>
			2be2: R_X86_64_PLT32	botlish_fn_9-0x4
    2be6:	mov    0x4a0(%rsp),%rdi
    2bee:	mov    0x10(%rdi),%rcx
    2bf2:	mov    0x220(%rcx),%rdx
    2bf9:	lea    0x320(%rsp),%r9
    2c01:	mov    %rbx,0x320(%rsp)
    2c09:	mov    %rax,0x328(%rsp)
    2c11:	mov    0x538(%rsp),%rsi
    2c19:	mov    %rsi,0x330(%rsp)
    2c21:	mov    $0x9,%ecx
    2c26:	mov    %r12,%rsi
    2c29:	mov    0x570(%rsp),%r8
    2c31:	call   2c36 <botlish_fn_19+0x134e>
			2c32: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2c36:	jmp    329a <botlish_fn_19+0x19b2>
    2c3b:	mov    0x4c0(%rsp),%rsi
    2c43:	mov    0x4a0(%rsp),%rdi
    2c4b:	mov    0x10(%rdi),%rax
    2c4f:	mov    0x238(%rax),%rbx
    2c56:	shl    $1,%rsi
    2c59:	or     $0x1,%rsi
    2c5d:	call   2c62 <botlish_fn_19+0x137a>
			2c5e: R_X86_64_PLT32	botlish_fn_9-0x4
    2c62:	mov    0x4a0(%rsp),%rdi
    2c6a:	mov    0x10(%rdi),%rcx
    2c6e:	mov    0x218(%rcx),%rdx
    2c75:	lea    0x310(%rsp),%r9
    2c7d:	mov    %rbx,0x310(%rsp)
    2c85:	mov    %rax,0x318(%rsp)
    2c8d:	mov    $0x2,%r8d
    2c93:	mov    0x558(%rsp),%rcx
    2c9b:	mov    %r8,%rsi
    2c9e:	call   2ca3 <botlish_fn_19+0x13bb>
			2c9f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2ca3:	jmp    329a <botlish_fn_19+0x19b2>
    2ca8:	mov    0x4a0(%rsp),%rdi
    2cb0:	mov    0x10(%rdi),%rax
    2cb4:	mov    0x228(%rax),%rbx
    2cbb:	mov    0x538(%rsp),%rsi
    2cc3:	test   $0x1,%rsi
    2cca:	jne    2d02 <botlish_fn_19+0x141a>
    2cd0:	mov    0x550(%rsp),%rdx
    2cd8:	mov    0x538(%rsp),%rsi
    2ce0:	mov    0x4a0(%rsp),%rdi
    2ce8:	call   2ced <botlish_fn_19+0x1405>
			2ce9: R_X86_64_PLT32	rt_int_cmp-0x4
    2ced:	mov    $0x2,%ecx
    2cf2:	test   %rax,%rax
    2cf5:	cmovl  0x4273(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    2cfd:	jmp    2d1b <botlish_fn_19+0x1433>
    2d02:	mov    $0x2,%ecx
    2d07:	mov    0x538(%rsp),%rsi
    2d0f:	cmp    $0xffffffffffffffff,%rsi
    2d13:	cmovl  0x4255(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    2d1b:	cmp    $0x6,%rcx
    2d1f:	je     2da7 <botlish_fn_19+0x14bf>
    2d25:	mov    0x538(%rsp),%rsi
    2d2d:	test   $0x1,%rsi
    2d34:	jne    2d69 <botlish_fn_19+0x1481>
    2d3a:	mov    $0x1ff,%edx
    2d3f:	mov    0x538(%rsp),%rsi
    2d47:	mov    0x4a0(%rsp),%rdi
    2d4f:	call   2d54 <botlish_fn_19+0x146c>
			2d50: R_X86_64_PLT32	rt_int_cmp-0x4
    2d54:	mov    $0x2,%esi
    2d59:	test   %rax,%rax
    2d5c:	cmovg  0x420c(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    2d64:	jmp    2d84 <botlish_fn_19+0x149c>
    2d69:	mov    $0x2,%esi
    2d6e:	mov    0x538(%rsp),%rax
    2d76:	cmp    $0x1ff,%rax
    2d7c:	cmovg  0x41ec(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    2d84:	cmp    $0x6,%rsi
    2d88:	je     2da7 <botlish_fn_19+0x14bf>
    2d8e:	mov    0x538(%rsp),%rsi
    2d96:	mov    %rsi,%rax
    2d99:	sar    $1,%rax
    2d9c:	movzbq 0x11(%rbx,%rax,1),%rsi
    2da2:	jmp    2daf <botlish_fn_19+0x14c7>
    2da7:	movzbq 0x818(%rbx),%rsi
    2daf:	mov    %rsi,%rdx
    2db2:	shl    $1,%rdx
    2db5:	or     $0x1,%rdx
    2db9:	mov    $0x2,%eax
    2dbe:	cmp    $0x11,%rdx
    2dc2:	cmovl  0x41a6(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    2dca:	cmp    $0x6,%rax
    2dce:	je     2f87 <botlish_fn_19+0x169f>
    2dd4:	mov    %rsi,%rdi
    2dd7:	shl    $1,%rdi
    2dda:	mov    %rsi,0x510(%rsp)
    2de2:	or     $0x1,%rdi
    2de6:	mov    $0x2,%eax
    2deb:	cmp    $0x11,%rdi
    2def:	cmove  0x4179(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    2df7:	cmp    $0x6,%rax
    2dfb:	je     2f7a <botlish_fn_19+0x1692>
    2e01:	mov    0x538(%rsp),%rsi
    2e09:	test   $0x1,%rsi
    2e10:	jne    2e48 <botlish_fn_19+0x1560>
    2e16:	mov    0x550(%rsp),%rdx
    2e1e:	mov    0x538(%rsp),%rsi
    2e26:	mov    0x4a0(%rsp),%rdi
    2e2e:	call   2e33 <botlish_fn_19+0x154b>
			2e2f: R_X86_64_PLT32	rt_int_cmp-0x4
    2e33:	mov    $0x2,%ecx
    2e38:	test   %rax,%rax
    2e3b:	cmove  0x412d(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    2e43:	jmp    2e61 <botlish_fn_19+0x1579>
    2e48:	mov    $0x2,%ecx
    2e4d:	mov    0x538(%rsp),%rsi
    2e55:	cmp    $0xffffffffffffffff,%rsi
    2e59:	cmove  0x410f(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    2e61:	cmp    $0x6,%rcx
    2e65:	je     2efd <botlish_fn_19+0x1615>
    2e6b:	mov    0x4a0(%rsp),%rdi
    2e73:	mov    0x10(%rdi),%rax
    2e77:	mov    0x230(%rax),%rbx
    2e7e:	mov    $0x1,%r12d
    2e84:	mov    0x510(%rsp),%rsi
    2e8c:	shl    $1,%rsi
    2e8f:	mov    %rsi,0x510(%rsp)
    2e97:	or     $0x1,%rsi
    2e9b:	mov    %rsi,0x510(%rsp)
    2ea3:	call   2ea8 <botlish_fn_19+0x15c0>
			2ea4: R_X86_64_PLT32	botlish_fn_7-0x4
    2ea8:	mov    0x4a0(%rsp),%rdi
    2eb0:	mov    0x10(%rdi),%rcx
    2eb4:	mov    0x220(%rcx),%rdx
    2ebb:	lea    0x2f8(%rsp),%r9
    2ec3:	mov    %rbx,0x2f8(%rsp)
    2ecb:	mov    %rax,0x300(%rsp)
    2ed3:	mov    0x538(%rsp),%rsi
    2edb:	mov    %rsi,0x308(%rsp)
    2ee3:	mov    $0x9,%ecx
    2ee8:	mov    %r12,%rsi
    2eeb:	mov    0x570(%rsp),%r8
    2ef3:	call   2ef8 <botlish_fn_19+0x1610>
			2ef4: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2ef8:	jmp    329a <botlish_fn_19+0x19b2>
    2efd:	mov    0x4a0(%rsp),%rdi
    2f05:	mov    0x10(%rdi),%rax
    2f09:	mov    0x230(%rax),%rbx
    2f10:	mov    0x510(%rsp),%rsi
    2f18:	shl    $1,%rsi
    2f1b:	mov    %rsi,0x510(%rsp)
    2f23:	or     $0x1,%rsi
    2f27:	mov    %rsi,0x510(%rsp)
    2f2f:	call   2f34 <botlish_fn_19+0x164c>
			2f30: R_X86_64_PLT32	botlish_fn_7-0x4
    2f34:	mov    0x4a0(%rsp),%rdi
    2f3c:	mov    0x10(%rdi),%rcx
    2f40:	mov    0x218(%rcx),%rdx
    2f47:	lea    0x2e8(%rsp),%r9
    2f4f:	mov    %rbx,0x2e8(%rsp)
    2f57:	mov    %rax,0x2f0(%rsp)
    2f5f:	mov    $0x2,%r8d
    2f65:	mov    0x558(%rsp),%rcx
    2f6d:	mov    %r8,%rsi
    2f70:	call   2f75 <botlish_fn_19+0x168d>
			2f71: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    2f75:	jmp    329a <botlish_fn_19+0x19b2>
    2f7a:	mov    0x570(%rsp),%rsi
    2f82:	jmp    3459 <botlish_fn_19+0x1b71>
    2f87:	mov    %rsi,0x510(%rsp)
    2f8f:	shl    $1,%rsi
    2f92:	mov    %rsi,0x510(%rsp)
    2f9a:	or     $0x1,%rsi
    2f9e:	mov    %rsi,0x510(%rsp)
    2fa6:	mov    %rsi,0xb0(%rsp)
    2fae:	mov    $0x1,%ebx
    2fb3:	movq   $0x1,0x30(%rsp)
    2fbc:	mov    $0x2,%r12d
    2fc2:	mov    $0xa,%esi
    2fc7:	mov    %rsi,0x4c0(%rsp)
    2fcf:	mov    %rsi,0x508(%rsp)
    2fd7:	mov    %rsi,0x518(%rsp)
    2fdf:	mov    %rsi,0x520(%rsp)
    2fe7:	jmp    35cc <botlish_fn_19+0x1ce4>
    2fec:	mov    0x4a0(%rsp),%rdi
    2ff4:	mov    0x10(%rdi),%rax
    2ff8:	mov    0x208(%rax),%rbx
    2fff:	mov    0x538(%rsp),%rsi
    3007:	test   $0x1,%rsi
    300e:	jne    3046 <botlish_fn_19+0x175e>
    3014:	mov    0x550(%rsp),%rdx
    301c:	mov    0x538(%rsp),%rsi
    3024:	mov    0x4a0(%rsp),%rdi
    302c:	call   3031 <botlish_fn_19+0x1749>
			302d: R_X86_64_PLT32	rt_int_cmp-0x4
    3031:	mov    $0x2,%ecx
    3036:	test   %rax,%rax
    3039:	cmovl  0x3f2f(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    3041:	jmp    305f <botlish_fn_19+0x1777>
    3046:	mov    $0x2,%ecx
    304b:	mov    0x538(%rsp),%rsi
    3053:	cmp    $0xffffffffffffffff,%rsi
    3057:	cmovl  0x3f11(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    305f:	cmp    $0x6,%rcx
    3063:	je     30ec <botlish_fn_19+0x1804>
    3069:	mov    0x538(%rsp),%rsi
    3071:	test   $0x1,%rsi
    3078:	jne    30ad <botlish_fn_19+0x17c5>
    307e:	mov    $0x1ff,%edx
    3083:	mov    0x538(%rsp),%rsi
    308b:	mov    0x4a0(%rsp),%rdi
    3093:	call   3098 <botlish_fn_19+0x17b0>
			3094: R_X86_64_PLT32	rt_int_cmp-0x4
    3098:	mov    $0x2,%ecx
    309d:	test   %rax,%rax
    30a0:	cmovg  0x3ec8(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    30a8:	jmp    30c9 <botlish_fn_19+0x17e1>
    30ad:	mov    $0x2,%ecx
    30b2:	mov    0x538(%rsp),%rsi
    30ba:	cmp    $0x1ff,%rsi
    30c1:	cmovg  0x3ea7(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    30c9:	cmp    $0x6,%rcx
    30cd:	je     30ec <botlish_fn_19+0x1804>
    30d3:	mov    0x538(%rsp),%rsi
    30db:	mov    %rsi,%rax
    30de:	sar    $1,%rax
    30e1:	movzbq 0x11(%rbx,%rax,1),%rsi
    30e7:	jmp    30f4 <botlish_fn_19+0x180c>
    30ec:	movzbq 0x616(%rbx),%rsi
    30f4:	mov    %rsi,%rcx
    30f7:	shl    $1,%rcx
    30fa:	or     $0x1,%rcx
    30fe:	mov    $0x2,%eax
    3103:	cmp    $0xd,%rcx
    3107:	cmovl  0x3e61(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    310f:	cmp    $0x6,%rax
    3113:	je     346e <botlish_fn_19+0x1b86>
    3119:	mov    %rsi,%rax
    311c:	shl    $1,%rax
    311f:	mov    %rsi,0x508(%rsp)
    3127:	or     $0x1,%rax
    312b:	mov    $0x2,%edx
    3130:	cmp    $0xd,%rax
    3134:	cmove  0x3e34(%rip),%rdx        # 6f70 <botlish_fn_19+0x5688>
    313c:	cmp    $0x6,%rdx
    3140:	je     3451 <botlish_fn_19+0x1b69>
    3146:	mov    0x538(%rsp),%rsi
    314e:	test   $0x1,%rsi
    3155:	jne    318d <botlish_fn_19+0x18a5>
    315b:	mov    0x550(%rsp),%rdx
    3163:	mov    0x538(%rsp),%rsi
    316b:	mov    0x4a0(%rsp),%rdi
    3173:	call   3178 <botlish_fn_19+0x1890>
			3174: R_X86_64_PLT32	rt_int_cmp-0x4
    3178:	mov    $0x2,%ecx
    317d:	test   %rax,%rax
    3180:	cmove  0x3de8(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    3188:	jmp    31a6 <botlish_fn_19+0x18be>
    318d:	mov    $0x2,%ecx
    3192:	mov    0x538(%rsp),%rsi
    319a:	cmp    $0xffffffffffffffff,%rsi
    319e:	cmove  0x3dca(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    31a6:	cmp    $0x6,%rcx
    31aa:	je     3232 <botlish_fn_19+0x194a>
    31b0:	mov    0x4a0(%rsp),%rdi
    31b8:	mov    0x10(%rdi),%rax
    31bc:	mov    0x210(%rax),%r12
    31c3:	mov    $0x1,%r13d
    31c9:	mov    0x508(%rsp),%rsi
    31d1:	shl    $1,%rsi
    31d4:	or     $0x1,%rsi
    31d8:	call   31dd <botlish_fn_19+0x18f5>
			31d9: R_X86_64_PLT32	botlish_fn_5-0x4
    31dd:	mov    0x4a0(%rsp),%rdi
    31e5:	mov    0x10(%rdi),%rcx
    31e9:	mov    0x220(%rcx),%rdx
    31f0:	lea    0x2d0(%rsp),%r9
    31f8:	mov    %r12,0x2d0(%rsp)
    3200:	mov    %rax,0x2d8(%rsp)
    3208:	mov    0x538(%rsp),%rsi
    3210:	mov    %rsi,0x2e0(%rsp)
    3218:	mov    $0x9,%ecx
    321d:	mov    %r13,%rsi
    3220:	mov    0x570(%rsp),%r8
    3228:	call   322d <botlish_fn_19+0x1945>
			3229: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    322d:	jmp    329a <botlish_fn_19+0x19b2>
    3232:	mov    0x508(%rsp),%rsi
    323a:	mov    0x4a0(%rsp),%rdi
    3242:	mov    0x10(%rdi),%rax
    3246:	mov    0x210(%rax),%rbx
    324d:	shl    $1,%rsi
    3250:	or     $0x1,%rsi
    3254:	call   3259 <botlish_fn_19+0x1971>
			3255: R_X86_64_PLT32	botlish_fn_5-0x4
    3259:	mov    0x4a0(%rsp),%rdi
    3261:	mov    0x10(%rdi),%rcx
    3265:	mov    0x218(%rcx),%rdx
    326c:	lea    0x2c0(%rsp),%r9
    3274:	mov    %rbx,0x2c0(%rsp)
    327c:	mov    %rax,0x2c8(%rsp)
    3284:	mov    $0x2,%r8d
    328a:	mov    0x558(%rsp),%rcx
    3292:	mov    %r8,%rsi
    3295:	call   329a <botlish_fn_19+0x19b2>
			3296: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    329a:	mov    0x4a0(%rsp),%rdi
    32a2:	call   32a7 <botlish_fn_19+0x19bf>
			32a3: R_X86_64_PLT32	rt_co_failed-0x4
    32a7:	mov    %rax,0x98(%rsp)
    32af:	mov    %rax,%rsi
    32b2:	mov    0x4a0(%rsp),%rdi
    32ba:	call   32bf <botlish_fn_19+0x19d7>
			32bb: R_X86_64_PLT32	rt_co_resume0-0x4
    32bf:	test   %rax,%rax
    32c2:	je     32e4 <botlish_fn_19+0x19fc>
    32c8:	mov    0x4a0(%rsp),%rdi
    32d0:	mov    0x10(%rdi),%rax
    32d4:	mov    0x48(%rax),%rsi
    32d8:	mov    0x1b0(%rax),%rdx
    32df:	call   32e4 <botlish_fn_19+0x19fc>
			32e0: R_X86_64_PLT32	rt_raise-0x4
    32e4:	mov    0x4a0(%rsp),%rdi
    32ec:	call   32f1 <botlish_fn_19+0x1a09>
			32ed: R_X86_64_PLT32	rt_declared_error-0x4
    32f1:	cmp    $0x1,%rax
    32f5:	je     33a2 <botlish_fn_19+0x1aba>
    32fb:	mov    0x4a0(%rsp),%rdi
    3303:	call   3308 <botlish_fn_19+0x1a20>
			3304: R_X86_64_PLT32	rt_declared_error-0x4
    3308:	cmp    $0x2,%rax
    330c:	jne    6d30 <botlish_fn_19+0x5448>
    3312:	xor    %rsi,%rsi
    3315:	mov    0x4a0(%rsp),%rdi
    331d:	call   3322 <botlish_fn_19+0x1a3a>
			331e: R_X86_64_PLT32	rt_declared_payload-0x4
    3322:	mov    %rax,%rbx
    3325:	mov    $0x1,%esi
    332a:	mov    0x4a0(%rsp),%rdi
    3332:	call   3337 <botlish_fn_19+0x1a4f>
			3333: R_X86_64_PLT32	rt_declared_payload-0x4
    3337:	mov    %rax,%r12
    333a:	mov    0x4a0(%rsp),%rdi
    3342:	call   3347 <botlish_fn_19+0x1a5f>
			3343: R_X86_64_PLT32	rt_clear_declared_error-0x4
    3347:	mov    0x4a0(%rsp),%rdi
    334f:	mov    0x10(%rdi),%rax
    3353:	mov    0x1c0(%rax),%rdx
    335a:	lea    0xe8(%rsp),%r9
    3362:	mov    0x540(%rsp),%rsi
    336a:	mov    %rsi,0xe8(%rsp)
    3372:	mov    %rbx,%rax
    3375:	mov    %rax,0xf0(%rsp)
    337d:	mov    %r12,%rax
    3380:	mov    %rax,0xf8(%rsp)
    3388:	mov    $0x5,%esi
    338d:	mov    0x570(%rsp),%r8
    3395:	mov    %r8,%rcx
    3398:	call   339d <botlish_fn_19+0x1ab5>
			3399: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    339d:	jmp    6d30 <botlish_fn_19+0x5448>
    33a2:	xor    %rsi,%rsi
    33a5:	mov    0x4a0(%rsp),%rdi
    33ad:	call   33b2 <botlish_fn_19+0x1aca>
			33ae: R_X86_64_PLT32	rt_declared_payload-0x4
    33b2:	mov    %rax,%r12
    33b5:	mov    $0x1,%esi
    33ba:	mov    0x4a0(%rsp),%rdi
    33c2:	call   33c7 <botlish_fn_19+0x1adf>
			33c3: R_X86_64_PLT32	rt_declared_payload-0x4
    33c7:	mov    %rax,%r13
    33ca:	mov    $0x2,%ebx
    33cf:	mov    %rbx,%rsi
    33d2:	mov    0x4a0(%rsp),%rdi
    33da:	call   33df <botlish_fn_19+0x1af7>
			33db: R_X86_64_PLT32	rt_declared_payload-0x4
    33df:	mov    %rax,%r14
    33e2:	mov    0x4a0(%rsp),%rdi
    33ea:	call   33ef <botlish_fn_19+0x1b07>
			33eb: R_X86_64_PLT32	rt_clear_declared_error-0x4
    33ef:	mov    0x4a0(%rsp),%rdi
    33f7:	mov    0x10(%rdi),%rax
    33fb:	mov    0x1b8(%rax),%rdx
    3402:	lea    0xc8(%rsp),%r9
    340a:	mov    0x540(%rsp),%rsi
    3412:	mov    %rsi,0xc8(%rsp)
    341a:	mov    %r12,%rax
    341d:	mov    %rax,0xd0(%rsp)
    3425:	mov    %r13,%rax
    3428:	mov    %rax,0xd8(%rsp)
    3430:	mov    %r14,%rax
    3433:	mov    %rax,0xe0(%rsp)
    343b:	mov    $0x4,%r8d
    3441:	mov    %rbx,%rcx
    3444:	mov    %r8,%rsi
    3447:	call   344c <botlish_fn_19+0x1b64>
			3448: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    344c:	jmp    6d30 <botlish_fn_19+0x5448>
    3451:	mov    0x570(%rsp),%rsi
    3459:	mov    %rsi,0xa0(%rsp)
    3461:	mov    %rsi,0x4c0(%rsp)
    3469:	jmp    34e3 <botlish_fn_19+0x1bfb>
    346e:	shl    $1,%rsi
    3471:	or     $0x1,%rsi
    3475:	mov    %rsi,0xa8(%rsp)
    347d:	mov    $0x1,%ebx
    3482:	movq   $0x1,0x30(%rsp)
    348b:	mov    $0xa,%eax
    3490:	mov    %rax,0x510(%rsp)
    3498:	mov    %rbx,%r12
    349b:	mov    %rax,0x4c0(%rsp)
    34a3:	mov    %rsi,0x508(%rsp)
    34ab:	mov    %rax,0x518(%rsp)
    34b3:	mov    %rax,0x520(%rsp)
    34bb:	jmp    35cc <botlish_fn_19+0x1ce4>
    34c0:	mov    $0xfffffffffffffffd,%rsi
    34c7:	jmp    352a <botlish_fn_19+0x1c42>
    34cc:	shl    $1,%rsi
    34cf:	or     $0x1,%rsi
    34d3:	mov    %rsi,0xa0(%rsp)
    34db:	mov    %rsi,0x4c0(%rsp)
    34e3:	mov    $0x1,%ebx
    34e8:	movq   $0x1,0x30(%rsp)
    34f1:	mov    $0xa,%esi
    34f6:	mov    0x570(%rsp),%r12
    34fe:	mov    %rsi,0x508(%rsp)
    3506:	mov    %rsi,0x510(%rsp)
    350e:	mov    %rsi,0x518(%rsp)
    3516:	mov    %rsi,0x520(%rsp)
    351e:	jmp    35cc <botlish_fn_19+0x1ce4>
    3523:	mov    $0xfffffffffffffffd,%rsi
    352a:	test   $0x1,%rsi
    3531:	jne    355e <botlish_fn_19+0x1c76>
    3537:	mov    $0x1,%edx
    353c:	mov    0x4a0(%rsp),%rdi
    3544:	call   3549 <botlish_fn_19+0x1c61>
			3545: R_X86_64_PLT32	rt_int_cmp-0x4
    3549:	mov    $0x2,%ecx
    354e:	test   %rax,%rax
    3551:	cmovge 0x3a17(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    3559:	jmp    356e <botlish_fn_19+0x1c86>
    355e:	mov    $0x2,%ecx
    3563:	test   %rsi,%rsi
    3566:	cmovg  0x3a02(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    356e:	cmp    $0x6,%rcx
    3572:	je     3582 <botlish_fn_19+0x1c9a>
    3578:	mov    $0x1,%ebx
    357d:	jmp    358a <botlish_fn_19+0x1ca2>
    3582:	mov    0x570(%rsp),%rbx
    358a:	mov    %rbx,0x30(%rsp)
    358f:	mov    $0xa,%esi
    3594:	mov    %rsi,0x508(%rsp)
    359c:	mov    0x550(%rsp),%r12
    35a4:	mov    0x508(%rsp),%rax
    35ac:	mov    %rax,0x4c0(%rsp)
    35b4:	mov    %rax,0x510(%rsp)
    35bc:	mov    %rax,0x518(%rsp)
    35c4:	mov    %rax,0x520(%rsp)
    35cc:	mov    0x560(%rsp),%rax
    35d4:	mov    0x18(%rax),%rsi
    35d8:	test   %rsi,%rsi
    35db:	je     6e27 <botlish_fn_19+0x553f>
    35e1:	mov    0x560(%rsp),%rax
    35e9:	mov    0x10(%rax),%r9
    35ed:	mov    %rbx,0x18(%r9)
    35f1:	test   %r12,%r12
    35f4:	jl     51a2 <botlish_fn_19+0x38ba>
    35fa:	mov    0x560(%rsp),%rax
    3602:	mov    0x10(%rax),%rax
    3606:	mov    (%rax),%rsi
    3609:	mov    %rsi,0x20(%rsp)
    360e:	movq   $0x3,0x28(%rsp)
    3617:	test   $0x1,%rsi
    361e:	je     3641 <botlish_fn_19+0x1d59>
    3624:	mov    %rsi,%rax
    3627:	add    $0x2,%rax
    362b:	mov    %rax,%rcx
    362e:	seto   %al
    3631:	test   %al,%al
    3633:	jne    3641 <botlish_fn_19+0x1d59>
    3639:	mov    %rcx,%r15
    363c:	jmp    365c <botlish_fn_19+0x1d74>
    3641:	mov    0x570(%rsp),%rdx
    3649:	mov    0x4a0(%rsp),%rdi
    3651:	call   3656 <botlish_fn_19+0x1d6e>
			3652: R_X86_64_PLT32	rt_int_add-0x4
    3656:	mov    %rax,%rcx
    3659:	mov    %rcx,%r15
    365c:	mov    %r15,0x20(%rsp)
    3661:	mov    0x560(%rsp),%rax
    3669:	mov    0x18(%rax),%rax
    366d:	test   %rax,%rax
    3670:	je     6e4c <botlish_fn_19+0x5564>
    3676:	mov    0x560(%rsp),%rax
    367e:	mov    0x10(%rax),%rax
    3682:	mov    %r15,(%rax)
    3685:	mov    0x4c8(%rsp),%r10
    368d:	cmp    $0x1,%r10
    3691:	je     36c3 <botlish_fn_19+0x1ddb>
    3697:	mov    $0xa,%esi
    369c:	cmp    $0xffffffffffffffff,%r10
    36a0:	jne    3a37 <botlish_fn_19+0x214f>
    36a6:	mov    0x528(%rsp),%rsi
    36ae:	mov    0x578(%rsp),%r14
    36b6:	mov    %r10,0x4c8(%rsp)
    36be:	jmp    3a99 <botlish_fn_19+0x21b1>
    36c3:	movq   $0x3,0x28(%rsp)
    36cc:	mov    0x4e0(%rsp),%rsi
    36d4:	test   $0x1,%rsi
    36db:	jne    36ee <botlish_fn_19+0x1e06>
    36e1:	mov    0x4e0(%rsp),%rsi
    36e9:	jmp    3725 <botlish_fn_19+0x1e3d>
    36ee:	mov    0x4e0(%rsp),%rsi
    36f6:	mov    %rsi,%rcx
    36f9:	add    $0x2,%rcx
    36fd:	seto   %al
    3700:	test   %al,%al
    3702:	je     3715 <botlish_fn_19+0x1e2d>
    3708:	mov    0x4e0(%rsp),%rsi
    3710:	jmp    3725 <botlish_fn_19+0x1e3d>
    3715:	mov    %rcx,%rsi
    3718:	mov    %rcx,0x4e0(%rsp)
    3720:	jmp    3745 <botlish_fn_19+0x1e5d>
    3725:	mov    0x570(%rsp),%rdx
    372d:	mov    0x4a0(%rsp),%rdi
    3735:	call   373a <botlish_fn_19+0x1e52>
			3736: R_X86_64_PLT32	rt_int_add-0x4
    373a:	mov    %rax,%rsi
    373d:	mov    %rax,0x4e0(%rsp)
    3745:	mov    %rsi,0x70(%rsp)
    374a:	mov    0x4e8(%rsp),%rax
    3752:	mov    0x4e0(%rsp),%rsi
    375a:	mov    %rsi,%rcx
    375d:	and    %rax,%rcx
    3760:	test   $0x1,%rcx
    3767:	jne    379f <botlish_fn_19+0x1eb7>
    376d:	mov    0x4e8(%rsp),%rdx
    3775:	mov    0x4e0(%rsp),%rsi
    377d:	mov    0x4a0(%rsp),%rdi
    3785:	call   378a <botlish_fn_19+0x1ea2>
			3786: R_X86_64_PLT32	rt_int_cmp-0x4
    378a:	mov    $0x2,%ecx
    378f:	test   %rax,%rax
    3792:	cmovl  0x37d6(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    379a:	jmp    37bf <botlish_fn_19+0x1ed7>
    379f:	mov    $0x2,%ecx
    37a4:	mov    0x4e8(%rsp),%rax
    37ac:	mov    0x4e0(%rsp),%rsi
    37b4:	cmp    %rax,%rsi
    37b7:	cmovl  0x37b1(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    37bf:	cmp    $0x6,%rcx
    37c3:	je     39bc <botlish_fn_19+0x20d4>
    37c9:	movq   $0x3,0x28(%rsp)
    37d2:	mov    0x4f8(%rsp),%rsi
    37da:	test   $0x1,%rsi
    37e1:	jne    37f4 <botlish_fn_19+0x1f0c>
    37e7:	mov    0x4f8(%rsp),%rsi
    37ef:	jmp    3827 <botlish_fn_19+0x1f3f>
    37f4:	mov    0x4f8(%rsp),%rsi
    37fc:	add    $0x2,%rsi
    3800:	seto   %dil
    3804:	test   %dil,%dil
    3807:	je     381a <botlish_fn_19+0x1f32>
    380d:	mov    0x4f8(%rsp),%rsi
    3815:	jmp    3827 <botlish_fn_19+0x1f3f>
    381a:	mov    %rsi,0x4f8(%rsp)
    3822:	jmp    3847 <botlish_fn_19+0x1f5f>
    3827:	mov    0x570(%rsp),%rdx
    382f:	mov    0x4a0(%rsp),%rdi
    3837:	call   383c <botlish_fn_19+0x1f54>
			3838: R_X86_64_PLT32	rt_int_add-0x4
    383c:	mov    %rax,%rsi
    383f:	mov    %rax,0x4f8(%rsp)
    3847:	mov    %rsi,0x58(%rsp)
    384c:	mov    0x4f8(%rsp),%rsi
    3854:	mov    0x578(%rsp),%r14
    385c:	mov    %rsi,%r11
    385f:	and    %r14,%r11
    3862:	test   $0x1,%r11
    3869:	jne    389c <botlish_fn_19+0x1fb4>
    386f:	mov    %r14,%rdx
    3872:	mov    0x4f8(%rsp),%rsi
    387a:	mov    0x4a0(%rsp),%rdi
    3882:	call   3887 <botlish_fn_19+0x1f9f>
			3883: R_X86_64_PLT32	rt_int_cmp-0x4
    3887:	mov    $0x2,%esi
    388c:	test   %rax,%rax
    388f:	cmovl  0x36d9(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    3897:	jmp    38b4 <botlish_fn_19+0x1fcc>
    389c:	mov    $0x2,%esi
    38a1:	mov    0x4f8(%rsp),%rax
    38a9:	cmp    %r14,%rax
    38ac:	cmovl  0x36bc(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    38b4:	cmp    $0x6,%rsi
    38b8:	je     38e4 <botlish_fn_19+0x1ffc>
    38be:	movq   $0xffffffffffffffff,0x38(%rsp)
    38c7:	mov    0x550(%rsp),%rsi
    38cf:	mov    0x550(%rsp),%rax
    38d7:	mov    %rax,0x4c8(%rsp)
    38df:	jmp    3a99 <botlish_fn_19+0x21b1>
    38e4:	mov    0x4f8(%rsp),%rsi
    38ec:	test   $0x1,%rsi
    38f3:	je     391c <botlish_fn_19+0x2034>
    38f9:	mov    0x4a8(%rsp),%r13
    3901:	mov    0x8(%r13),%rcx
    3905:	mov    0x4f8(%rsp),%rsi
    390d:	mov    %rsi,%rax
    3910:	sar    $1,%rax
    3913:	cmp    %rcx,%rax
    3916:	jb     395a <botlish_fn_19+0x2072>
    391c:	mov    0x4f8(%rsp),%rdx
    3924:	mov    0x4a8(%rsp),%rsi
    392c:	mov    0x4a0(%rsp),%rdi
    3934:	call   3939 <botlish_fn_19+0x2051>
			3935: R_X86_64_PLT32	rt_list_get-0x4
    3939:	mov    %rax,%rcx
    393c:	mov    %rax,0x4f0(%rsp)
    3944:	test   %rcx,%rax
    3947:	je     3a22 <botlish_fn_19+0x213a>
    394d:	mov    0x4f0(%rsp),%rax
    3955:	jmp    3972 <botlish_fn_19+0x208a>
    395a:	mov    0x4a8(%rsp),%r13
    3962:	mov    0x10(%r13),%rcx
    3966:	mov    (%rcx,%rax,8),%rax
    396a:	mov    %rax,0x4f0(%rsp)
    3972:	mov    %rax,0x60(%rsp)
    3977:	mov    0x4f0(%rsp),%rsi
    397f:	mov    0x4a0(%rsp),%rdi
    3987:	call   398c <botlish_fn_19+0x20a4>
			3988: R_X86_64_PLT32	rt_list_len-0x4
    398c:	mov    %rax,0x4e8(%rsp)
    3994:	mov    %rax,0x68(%rsp)
    3999:	mov    $0x1,%esi
    399e:	mov    %rsi,0x4e0(%rsp)
    39a6:	movq   $0x1,0x70(%rsp)
    39af:	mov    %r14,0x578(%rsp)
    39b7:	jmp    375a <botlish_fn_19+0x1e72>
    39bc:	mov    0x4e0(%rsp),%rsi
    39c4:	mov    0x578(%rsp),%r14
    39cc:	test   $0x1,%rsi
    39d3:	je     39fc <botlish_fn_19+0x2114>
    39d9:	mov    0x4f0(%rsp),%rax
    39e1:	mov    0x8(%rax),%rcx
    39e5:	mov    0x4e0(%rsp),%rsi
    39ed:	mov    %rsi,%rax
    39f0:	sar    $1,%rax
    39f3:	cmp    %rcx,%rax
    39f6:	jb     3a76 <botlish_fn_19+0x218e>
    39fc:	mov    0x4e0(%rsp),%rdx
    3a04:	mov    0x4f0(%rsp),%rsi
    3a0c:	mov    0x4a0(%rsp),%rdi
    3a14:	call   3a19 <botlish_fn_19+0x2131>
			3a15: R_X86_64_PLT32	rt_list_get-0x4
    3a19:	test   %rax,%rax
    3a1c:	jne    3a6e <botlish_fn_19+0x2186>
    3a22:	mov    0x4a0(%rsp),%rdi
    3a2a:	call   3a2f <botlish_fn_19+0x2147>
			3a2b: R_X86_64_PLT32	rt_co_failed-0x4
    3a2f:	mov    %rax,0x40(%rsp)
    3a34:	mov    %rax,%rsi
    3a37:	mov    0x4a0(%rsp),%rdi
    3a3f:	call   3a44 <botlish_fn_19+0x215c>
			3a40: R_X86_64_PLT32	rt_co_resume0-0x4
    3a44:	test   %rax,%rax
    3a47:	je     6d30 <botlish_fn_19+0x5448>
    3a4d:	mov    0x4a0(%rsp),%rdi
    3a55:	mov    0x10(%rdi),%rax
    3a59:	mov    0x48(%rax),%rsi
    3a5d:	mov    0x1b0(%rax),%rdx
    3a64:	call   3a69 <botlish_fn_19+0x2181>
			3a65: R_X86_64_PLT32	rt_raise-0x4
    3a69:	jmp    6d30 <botlish_fn_19+0x5448>
    3a6e:	mov    %rax,%rsi
    3a71:	jmp    3a86 <botlish_fn_19+0x219e>
    3a76:	mov    0x4f0(%rsp),%r8
    3a7e:	mov    0x10(%r8),%rcx
    3a82:	mov    (%rcx,%rax,8),%rsi
    3a86:	mov    %rsi,0x38(%rsp)
    3a8b:	mov    $0x1,%r10d
    3a91:	mov    %r10,0x4c8(%rsp)
    3a99:	mov    %rsi,0x28(%rsp)
    3a9e:	mov    0x560(%rsp),%rax
    3aa6:	mov    %rsi,0x528(%rsp)
    3aae:	mov    0x18(%rax),%rax
    3ab2:	test   %rax,%rax
    3ab5:	je     6e6e <botlish_fn_19+0x5586>
    3abb:	mov    0x560(%rsp),%rax
    3ac3:	mov    0x10(%rax),%rax
    3ac7:	mov    0x528(%rsp),%rsi
    3acf:	mov    %rsi,0x8(%rax)
    3ad3:	mov    0x540(%rsp),%rsi
    3adb:	mov    %r15,%rcx
    3ade:	and    %rsi,%rcx
    3ae1:	test   $0x1,%rcx
    3ae8:	je     3b1d <botlish_fn_19+0x2235>
    3aee:	mov    0x540(%rsp),%rax
    3af6:	mov    %r15,%rsi
    3af9:	sub    %rax,%rsi
    3afc:	seto   %dil
    3b00:	add    $0x1,%rsi
    3b07:	test   %dil,%dil
    3b0a:	jne    3b1d <botlish_fn_19+0x2235>
    3b10:	mov    0x4b8(%rsp),%r13
    3b18:	jmp    3b40 <botlish_fn_19+0x2258>
    3b1d:	mov    0x540(%rsp),%rdx
    3b25:	mov    %r15,%rsi
    3b28:	mov    0x4a0(%rsp),%rdi
    3b30:	call   3b35 <botlish_fn_19+0x224d>
			3b31: R_X86_64_PLT32	rt_int_sub-0x4
    3b35:	mov    %rax,%rsi
    3b38:	mov    0x4b8(%rsp),%r13
    3b40:	mov    %rsi,%r9
    3b43:	and    %r13,%r9
    3b46:	test   $0x1,%r9
    3b4d:	jne    3b80 <botlish_fn_19+0x2298>
    3b53:	mov    %r13,%rdx
    3b56:	mov    0x4a0(%rsp),%rdi
    3b5e:	call   3b63 <botlish_fn_19+0x227b>
			3b5f: R_X86_64_PLT32	rt_int_cmp-0x4
    3b63:	mov    %r13,0x4b8(%rsp)
    3b6b:	mov    $0x2,%esi
    3b70:	test   %rax,%rax
    3b73:	cmovge 0x33f5(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    3b7b:	jmp    3ba3 <botlish_fn_19+0x22bb>
    3b80:	mov    %rsi,%rax
    3b83:	mov    %r13,0x4b8(%rsp)
    3b8b:	mov    $0x2,%esi
    3b90:	mov    0x4b8(%rsp),%rcx
    3b98:	cmp    %rcx,%rax
    3b9b:	cmovge 0x33cd(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    3ba3:	cmp    $0x6,%rsi
    3ba7:	je     514a <botlish_fn_19+0x3862>
    3bad:	cmp    $0x1,%r12
    3bb1:	je     4beb <botlish_fn_19+0x3303>
    3bb7:	cmp    $0x2,%r12
    3bbb:	je     4889 <botlish_fn_19+0x2fa1>
    3bc1:	cmp    $0x3,%r12
    3bc5:	je     43a8 <botlish_fn_19+0x2ac0>
    3bcb:	mov    $0x4,%r13d
    3bd1:	cmp    $0x4,%r12
    3bd5:	je     3fd6 <botlish_fn_19+0x26ee>
    3bdb:	cmp    $0x5,%r12
    3bdf:	je     3c01 <botlish_fn_19+0x2319>
    3be5:	mov    $0xa,%esi
    3bea:	cmp    $0xffffffffffffffff,%r12
    3bee:	jne    4ef8 <botlish_fn_19+0x3610>
    3bf4:	mov    0x508(%rsp),%r13
    3bfc:	jmp    5110 <botlish_fn_19+0x3828>
    3c01:	mov    0x4a0(%rsp),%rdi
    3c09:	mov    0x520(%rsp),%r12
    3c11:	mov    0x528(%rsp),%rax
    3c19:	mov    %rax,0x4d8(%rsp)
    3c21:	mov    0x10(%rdi),%rax
    3c25:	mov    0x250(%rax),%rbx
    3c2c:	mov    0x528(%rsp),%rsi
    3c34:	test   $0x1,%rsi
    3c3b:	jne    3c73 <botlish_fn_19+0x238b>
    3c41:	mov    0x550(%rsp),%rdx
    3c49:	mov    0x528(%rsp),%rsi
    3c51:	mov    0x4a0(%rsp),%rdi
    3c59:	call   3c5e <botlish_fn_19+0x2376>
			3c5a: R_X86_64_PLT32	rt_int_cmp-0x4
    3c5e:	mov    $0x2,%ecx
    3c63:	test   %rax,%rax
    3c66:	cmovl  0x3302(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    3c6e:	jmp    3c8c <botlish_fn_19+0x23a4>
    3c73:	mov    $0x2,%ecx
    3c78:	mov    0x528(%rsp),%rsi
    3c80:	cmp    $0xffffffffffffffff,%rsi
    3c84:	cmovl  0x32e4(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    3c8c:	cmp    $0x6,%rcx
    3c90:	jne    3ca3 <botlish_fn_19+0x23bb>
    3c96:	mov    0x520(%rsp),%rsi
    3c9e:	jmp    3d66 <botlish_fn_19+0x247e>
    3ca3:	mov    0x528(%rsp),%rsi
    3cab:	test   $0x1,%rsi
    3cb2:	jne    3ce7 <botlish_fn_19+0x23ff>
    3cb8:	mov    $0x1ff,%edx
    3cbd:	mov    0x528(%rsp),%rsi
    3cc5:	mov    0x4a0(%rsp),%rdi
    3ccd:	call   3cd2 <botlish_fn_19+0x23ea>
			3cce: R_X86_64_PLT32	rt_int_cmp-0x4
    3cd2:	mov    $0x2,%ecx
    3cd7:	test   %rax,%rax
    3cda:	cmovg  0x328e(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    3ce2:	jmp    3d03 <botlish_fn_19+0x241b>
    3ce7:	mov    $0x2,%ecx
    3cec:	mov    0x528(%rsp),%rsi
    3cf4:	cmp    $0x1ff,%rsi
    3cfb:	cmovg  0x326d(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    3d03:	cmp    $0x6,%rcx
    3d07:	jne    3d1a <botlish_fn_19+0x2432>
    3d0d:	mov    0x520(%rsp),%rsi
    3d15:	jmp    3d66 <botlish_fn_19+0x247e>
    3d1a:	mov    0x520(%rsp),%rsi
    3d22:	or     $0x1,%rsi
    3d26:	mov    %rsi,0x520(%rsp)
    3d2e:	sar    $1,%rsi
    3d31:	mov    %rsi,0x520(%rsp)
    3d39:	imul   $0x101,%rsi,%rax
    3d40:	mov    0x528(%rsp),%rsi
    3d48:	mov    %rsi,%rcx
    3d4b:	sar    $1,%rcx
    3d4e:	lea    0x1(%rax,%rcx,1),%rax
    3d53:	movzbq 0x10(%rbx,%rax,1),%rsi
    3d59:	mov    %rsi,0x520(%rsp)
    3d61:	jmp    3d8e <botlish_fn_19+0x24a6>
    3d66:	or     $0x1,%rsi
    3d6a:	mov    %rsi,0x520(%rsp)
    3d72:	sar    $1,%rsi
    3d75:	mov    %rsi,0x520(%rsp)
    3d7d:	movzbq 0xc1c(%rbx,%rsi,1),%rsi
    3d86:	mov    %rsi,0x520(%rsp)
    3d8e:	mov    0x520(%rsp),%rsi
    3d96:	mov    %rsi,%rcx
    3d99:	shl    $1,%rcx
    3d9c:	or     $0x1,%rcx
    3da0:	mov    $0x2,%eax
    3da5:	cmp    $0x19,%rcx
    3da9:	cmovl  0x31bf(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    3db1:	cmp    $0x6,%rax
    3db5:	je     3f7e <botlish_fn_19+0x2696>
    3dbb:	mov    0x520(%rsp),%rsi
    3dc3:	mov    %rsi,%rax
    3dc6:	shl    $1,%rax
    3dc9:	or     $0x1,%rax
    3dcd:	mov    $0x2,%esi
    3dd2:	cmp    $0x19,%rax
    3dd6:	cmove  0x3192(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    3dde:	cmp    $0x6,%rsi
    3de2:	je     3f61 <botlish_fn_19+0x2679>
    3de8:	mov    0x528(%rsp),%rsi
    3df0:	test   $0x1,%rsi
    3df7:	jne    3e2f <botlish_fn_19+0x2547>
    3dfd:	mov    0x550(%rsp),%rdx
    3e05:	mov    0x528(%rsp),%rsi
    3e0d:	mov    0x4a0(%rsp),%rdi
    3e15:	call   3e1a <botlish_fn_19+0x2532>
			3e16: R_X86_64_PLT32	rt_int_cmp-0x4
    3e1a:	mov    $0x2,%ecx
    3e1f:	test   %rax,%rax
    3e22:	cmove  0x3146(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    3e2a:	jmp    3e48 <botlish_fn_19+0x2560>
    3e2f:	mov    $0x2,%ecx
    3e34:	mov    0x528(%rsp),%rsi
    3e3c:	cmp    $0xffffffffffffffff,%rsi
    3e40:	cmove  0x3128(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    3e48:	cmp    $0x6,%rcx
    3e4c:	je     3ee4 <botlish_fn_19+0x25fc>
    3e52:	mov    0x4a0(%rsp),%rdi
    3e5a:	mov    0x10(%rdi),%r10
    3e5e:	mov    0x258(%r10),%r12
    3e65:	mov    $0x1,%r13d
    3e6b:	mov    0x520(%rsp),%rsi
    3e73:	shl    $1,%rsi
    3e76:	mov    %rsi,0x520(%rsp)
    3e7e:	or     $0x1,%rsi
    3e82:	mov    %rsi,0x520(%rsp)
    3e8a:	call   3e8f <botlish_fn_19+0x25a7>
			3e8b: R_X86_64_PLT32	botlish_fn_3-0x4
    3e8f:	mov    0x4a0(%rsp),%rdi
    3e97:	mov    0x10(%rdi),%r10
    3e9b:	mov    0x220(%r10),%rdx
    3ea2:	lea    0x460(%rsp),%r9
    3eaa:	mov    %r12,0x460(%rsp)
    3eb2:	mov    %rax,0x468(%rsp)
    3eba:	mov    0x528(%rsp),%rsi
    3ec2:	mov    %rsi,0x470(%rsp)
    3eca:	mov    $0x9,%ecx
    3ecf:	mov    %r13,%rsi
    3ed2:	mov    0x570(%rsp),%r8
    3eda:	call   3edf <botlish_fn_19+0x25f7>
			3edb: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3edf:	jmp    4ee0 <botlish_fn_19+0x35f8>
    3ee4:	mov    0x4a0(%rsp),%rdi
    3eec:	mov    0x10(%rdi),%rax
    3ef0:	mov    0x258(%rax),%r14
    3ef7:	mov    0x520(%rsp),%rsi
    3eff:	shl    $1,%rsi
    3f02:	mov    %rsi,0x520(%rsp)
    3f0a:	or     $0x1,%rsi
    3f0e:	mov    %rsi,0x520(%rsp)
    3f16:	call   3f1b <botlish_fn_19+0x2633>
			3f17: R_X86_64_PLT32	botlish_fn_3-0x4
    3f1b:	mov    0x4a0(%rsp),%rdi
    3f23:	mov    0x10(%rdi),%rcx
    3f27:	mov    0x218(%rcx),%rdx
    3f2e:	lea    0x450(%rsp),%r9
    3f36:	mov    %r14,0x450(%rsp)
    3f3e:	mov    %rax,0x458(%rsp)
    3f46:	mov    $0x2,%r8d
    3f4c:	mov    0x558(%rsp),%rcx
    3f54:	mov    %r8,%rsi
    3f57:	call   3f5c <botlish_fn_19+0x2674>
			3f58: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    3f5c:	jmp    4ee0 <botlish_fn_19+0x35f8>
    3f61:	mov    %r12,0x520(%rsp)
    3f69:	mov    0x4c0(%rsp),%r12
    3f71:	mov    0x528(%rsp),%rsi
    3f79:	jmp    47a9 <botlish_fn_19+0x2ec1>
    3f7e:	mov    0x520(%rsp),%rsi
    3f86:	shl    $1,%rsi
    3f89:	mov    %rsi,0x520(%rsp)
    3f91:	or     $0x1,%rsi
    3f95:	mov    %rsi,0x520(%rsp)
    3f9d:	mov    %rsi,0xc0(%rsp)
    3fa5:	mov    $0x1,%ebx
    3faa:	movq   $0x1,0x30(%rsp)
    3fb3:	mov    $0x5,%r12d
    3fb9:	mov    0x508(%rsp),%r13
    3fc1:	mov    0x4d8(%rsp),%rax
    3fc9:	mov    %rax,0x528(%rsp)
    3fd1:	jmp    5110 <botlish_fn_19+0x3828>
    3fd6:	mov    0x4a0(%rsp),%rdi
    3fde:	mov    0x518(%rsp),%r12
    3fe6:	mov    0x528(%rsp),%rax
    3fee:	mov    %rax,0x4d8(%rsp)
    3ff6:	mov    0x10(%rdi),%rax
    3ffa:	mov    0x240(%rax),%rbx
    4001:	mov    0x528(%rsp),%rsi
    4009:	test   $0x1,%rsi
    4010:	jne    4048 <botlish_fn_19+0x2760>
    4016:	mov    0x550(%rsp),%rdx
    401e:	mov    0x528(%rsp),%rsi
    4026:	mov    0x4a0(%rsp),%rdi
    402e:	call   4033 <botlish_fn_19+0x274b>
			402f: R_X86_64_PLT32	rt_int_cmp-0x4
    4033:	mov    $0x2,%ecx
    4038:	test   %rax,%rax
    403b:	cmovl  0x2f2d(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4043:	jmp    4061 <botlish_fn_19+0x2779>
    4048:	mov    $0x2,%ecx
    404d:	mov    0x528(%rsp),%rsi
    4055:	cmp    $0xffffffffffffffff,%rsi
    4059:	cmovl  0x2f0f(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4061:	cmp    $0x6,%rcx
    4065:	jne    4078 <botlish_fn_19+0x2790>
    406b:	mov    0x518(%rsp),%rsi
    4073:	jmp    413b <botlish_fn_19+0x2853>
    4078:	mov    0x528(%rsp),%rsi
    4080:	test   $0x1,%rsi
    4087:	jne    40bc <botlish_fn_19+0x27d4>
    408d:	mov    $0x1ff,%edx
    4092:	mov    0x528(%rsp),%rsi
    409a:	mov    0x4a0(%rsp),%rdi
    40a2:	call   40a7 <botlish_fn_19+0x27bf>
			40a3: R_X86_64_PLT32	rt_int_cmp-0x4
    40a7:	mov    $0x2,%ecx
    40ac:	test   %rax,%rax
    40af:	cmovg  0x2eb9(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    40b7:	jmp    40d8 <botlish_fn_19+0x27f0>
    40bc:	mov    $0x2,%ecx
    40c1:	mov    0x528(%rsp),%rsi
    40c9:	cmp    $0x1ff,%rsi
    40d0:	cmovg  0x2e98(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    40d8:	cmp    $0x6,%rcx
    40dc:	jne    40ef <botlish_fn_19+0x2807>
    40e2:	mov    0x518(%rsp),%rsi
    40ea:	jmp    413b <botlish_fn_19+0x2853>
    40ef:	mov    0x518(%rsp),%rsi
    40f7:	or     $0x1,%rsi
    40fb:	mov    %rsi,0x518(%rsp)
    4103:	sar    $1,%rsi
    4106:	mov    %rsi,0x518(%rsp)
    410e:	imul   $0x101,%rsi,%rax
    4115:	mov    0x528(%rsp),%rsi
    411d:	mov    %rsi,%rcx
    4120:	sar    $1,%rcx
    4123:	lea    0x1(%rax,%rcx,1),%rax
    4128:	movzbq 0x10(%rbx,%rax,1),%rsi
    412e:	mov    %rsi,0x518(%rsp)
    4136:	jmp    4163 <botlish_fn_19+0x287b>
    413b:	or     $0x1,%rsi
    413f:	mov    %rsi,0x518(%rsp)
    4147:	sar    $1,%rsi
    414a:	mov    %rsi,0x518(%rsp)
    4152:	movzbq 0x919(%rbx,%rsi,1),%rsi
    415b:	mov    %rsi,0x518(%rsp)
    4163:	mov    0x518(%rsp),%rsi
    416b:	mov    %rsi,%rcx
    416e:	shl    $1,%rcx
    4171:	or     $0x1,%rcx
    4175:	mov    $0x2,%eax
    417a:	cmp    $0x13,%rcx
    417e:	cmovl  0x2dea(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    4186:	cmp    $0x6,%rax
    418a:	je     4353 <botlish_fn_19+0x2a6b>
    4190:	mov    0x518(%rsp),%rsi
    4198:	mov    %rsi,%rcx
    419b:	shl    $1,%rcx
    419e:	or     $0x1,%rcx
    41a2:	mov    $0x2,%eax
    41a7:	cmp    $0x13,%rcx
    41ab:	cmove  0x2dbd(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    41b3:	cmp    $0x6,%rax
    41b7:	je     4336 <botlish_fn_19+0x2a4e>
    41bd:	mov    0x528(%rsp),%rsi
    41c5:	test   $0x1,%rsi
    41cc:	jne    4204 <botlish_fn_19+0x291c>
    41d2:	mov    0x550(%rsp),%rdx
    41da:	mov    0x528(%rsp),%rsi
    41e2:	mov    0x4a0(%rsp),%rdi
    41ea:	call   41ef <botlish_fn_19+0x2907>
			41eb: R_X86_64_PLT32	rt_int_cmp-0x4
    41ef:	mov    $0x2,%ecx
    41f4:	test   %rax,%rax
    41f7:	cmove  0x2d71(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    41ff:	jmp    421d <botlish_fn_19+0x2935>
    4204:	mov    $0x2,%ecx
    4209:	mov    0x528(%rsp),%rsi
    4211:	cmp    $0xffffffffffffffff,%rsi
    4215:	cmove  0x2d53(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    421d:	cmp    $0x6,%rcx
    4221:	je     42b9 <botlish_fn_19+0x29d1>
    4227:	mov    0x4a0(%rsp),%rdi
    422f:	mov    0x10(%rdi),%rax
    4233:	mov    0x248(%rax),%rbx
    423a:	mov    $0x1,%r12d
    4240:	mov    0x518(%rsp),%rsi
    4248:	shl    $1,%rsi
    424b:	mov    %rsi,0x518(%rsp)
    4253:	or     $0x1,%rsi
    4257:	mov    %rsi,0x518(%rsp)
    425f:	call   4264 <botlish_fn_19+0x297c>
			4260: R_X86_64_PLT32	botlish_fn_1-0x4
    4264:	mov    0x4a0(%rsp),%rdi
    426c:	mov    0x10(%rdi),%rcx
    4270:	mov    0x220(%rcx),%rdx
    4277:	lea    0x438(%rsp),%r9
    427f:	mov    %rbx,0x438(%rsp)
    4287:	mov    %rax,0x440(%rsp)
    428f:	mov    0x528(%rsp),%rsi
    4297:	mov    %rsi,0x448(%rsp)
    429f:	mov    $0x9,%ecx
    42a4:	mov    %r12,%rsi
    42a7:	mov    0x570(%rsp),%r8
    42af:	call   42b4 <botlish_fn_19+0x29cc>
			42b0: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    42b4:	jmp    4ee0 <botlish_fn_19+0x35f8>
    42b9:	mov    0x4a0(%rsp),%rdi
    42c1:	mov    0x10(%rdi),%rsi
    42c5:	mov    0x248(%rsi),%r12
    42cc:	mov    0x518(%rsp),%rsi
    42d4:	shl    $1,%rsi
    42d7:	mov    %rsi,0x518(%rsp)
    42df:	or     $0x1,%rsi
    42e3:	mov    %rsi,0x518(%rsp)
    42eb:	call   42f0 <botlish_fn_19+0x2a08>
			42ec: R_X86_64_PLT32	botlish_fn_1-0x4
    42f0:	mov    0x4a0(%rsp),%rdi
    42f8:	mov    0x10(%rdi),%rsi
    42fc:	mov    0x218(%rsi),%rdx
    4303:	lea    0x428(%rsp),%r9
    430b:	mov    %r12,0x428(%rsp)
    4313:	mov    %rax,0x430(%rsp)
    431b:	mov    $0x2,%r8d
    4321:	mov    0x558(%rsp),%rcx
    4329:	mov    %r8,%rsi
    432c:	call   4331 <botlish_fn_19+0x2a49>
			432d: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4331:	jmp    4ee0 <botlish_fn_19+0x35f8>
    4336:	mov    %r12,0x518(%rsp)
    433e:	mov    0x4c0(%rsp),%r12
    4346:	mov    0x528(%rsp),%rsi
    434e:	jmp    47a9 <botlish_fn_19+0x2ec1>
    4353:	mov    0x518(%rsp),%rsi
    435b:	shl    $1,%rsi
    435e:	mov    %rsi,0x518(%rsp)
    4366:	or     $0x1,%rsi
    436a:	mov    %rsi,0x518(%rsp)
    4372:	mov    %rsi,0xb8(%rsp)
    437a:	mov    $0x1,%ebx
    437f:	movq   $0x1,0x30(%rsp)
    4388:	mov    0x4d8(%rsp),%rax
    4390:	mov    %rax,0x528(%rsp)
    4398:	mov    %r13,%r12
    439b:	mov    0x508(%rsp),%r13
    43a3:	jmp    5110 <botlish_fn_19+0x3828>
    43a8:	mov    0x4a0(%rsp),%rdi
    43b0:	mov    0x4c0(%rsp),%r12
    43b8:	mov    0x528(%rsp),%rax
    43c0:	mov    %rax,0x4d8(%rsp)
    43c8:	mov    0x10(%rdi),%rax
    43cc:	mov    0x200(%rax),%rbx
    43d3:	mov    0x528(%rsp),%rsi
    43db:	test   $0x1,%rsi
    43e2:	jne    441a <botlish_fn_19+0x2b32>
    43e8:	mov    0x550(%rsp),%rdx
    43f0:	mov    0x528(%rsp),%rsi
    43f8:	mov    0x4a0(%rsp),%rdi
    4400:	call   4405 <botlish_fn_19+0x2b1d>
			4401: R_X86_64_PLT32	rt_int_cmp-0x4
    4405:	mov    $0x2,%ecx
    440a:	test   %rax,%rax
    440d:	cmovl  0x2b5b(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4415:	jmp    4433 <botlish_fn_19+0x2b4b>
    441a:	mov    $0x2,%ecx
    441f:	mov    0x528(%rsp),%rsi
    4427:	cmp    $0xffffffffffffffff,%rsi
    442b:	cmovl  0x2b3d(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4433:	cmp    $0x6,%rcx
    4437:	jne    444a <botlish_fn_19+0x2b62>
    443d:	mov    0x4c0(%rsp),%rsi
    4445:	jmp    450d <botlish_fn_19+0x2c25>
    444a:	mov    0x528(%rsp),%rsi
    4452:	test   $0x1,%rsi
    4459:	jne    448e <botlish_fn_19+0x2ba6>
    445f:	mov    $0x1ff,%edx
    4464:	mov    0x528(%rsp),%rsi
    446c:	mov    0x4a0(%rsp),%rdi
    4474:	call   4479 <botlish_fn_19+0x2b91>
			4475: R_X86_64_PLT32	rt_int_cmp-0x4
    4479:	mov    $0x2,%ecx
    447e:	test   %rax,%rax
    4481:	cmovg  0x2ae7(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4489:	jmp    44aa <botlish_fn_19+0x2bc2>
    448e:	mov    $0x2,%ecx
    4493:	mov    0x528(%rsp),%rsi
    449b:	cmp    $0x1ff,%rsi
    44a2:	cmovg  0x2ac6(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    44aa:	cmp    $0x6,%rcx
    44ae:	jne    44c1 <botlish_fn_19+0x2bd9>
    44b4:	mov    0x4c0(%rsp),%rsi
    44bc:	jmp    450d <botlish_fn_19+0x2c25>
    44c1:	mov    0x4c0(%rsp),%rsi
    44c9:	or     $0x1,%rsi
    44cd:	mov    %rsi,0x4c0(%rsp)
    44d5:	sar    $1,%rsi
    44d8:	mov    %rsi,0x4c0(%rsp)
    44e0:	imul   $0x101,%rsi,%rax
    44e7:	mov    0x528(%rsp),%rsi
    44ef:	mov    %rsi,%rcx
    44f2:	sar    $1,%rcx
    44f5:	lea    0x1(%rax,%rcx,1),%rax
    44fa:	movzbq 0x10(%rbx,%rax,1),%rsi
    4500:	mov    %rsi,0x4c0(%rsp)
    4508:	jmp    4535 <botlish_fn_19+0x2c4d>
    450d:	or     $0x1,%rsi
    4511:	mov    %rsi,0x4c0(%rsp)
    4519:	sar    $1,%rsi
    451c:	mov    %rsi,0x4c0(%rsp)
    4524:	movzbq 0x212(%rbx,%rsi,1),%rsi
    452d:	mov    %rsi,0x4c0(%rsp)
    4535:	mov    0x4c0(%rsp),%rsi
    453d:	mov    %rsi,%rcx
    4540:	shl    $1,%rcx
    4543:	or     $0x1,%rcx
    4547:	mov    $0x2,%eax
    454c:	cmp    $0x5,%rcx
    4550:	cmovl  0x2a18(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    4558:	cmp    $0x6,%rax
    455c:	je     4855 <botlish_fn_19+0x2f6d>
    4562:	mov    0x4c0(%rsp),%rsi
    456a:	mov    %rsi,%rcx
    456d:	shl    $1,%rcx
    4570:	or     $0x1,%rcx
    4574:	mov    $0x2,%eax
    4579:	cmp    $0x5,%rcx
    457d:	cmove  0x29eb(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    4585:	cmp    $0x6,%rax
    4589:	je     479a <botlish_fn_19+0x2eb2>
    458f:	mov    0x4c0(%rsp),%rsi
    4597:	mov    %rsi,%rcx
    459a:	shl    $1,%rcx
    459d:	or     $0x1,%rcx
    45a1:	mov    $0x2,%eax
    45a6:	cmp    $0x7,%rcx
    45aa:	cmove  0x29be(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    45b2:	cmp    $0x6,%rax
    45b6:	je     477a <botlish_fn_19+0x2e92>
    45bc:	mov    0x4c0(%rsp),%rsi
    45c4:	mov    %rsi,%rcx
    45c7:	shl    $1,%rcx
    45ca:	or     $0x1,%rcx
    45ce:	mov    $0x2,%eax
    45d3:	cmp    $0x9,%rcx
    45d7:	cmove  0x2991(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    45df:	cmp    $0x6,%rax
    45e3:	je     4762 <botlish_fn_19+0x2e7a>
    45e9:	mov    0x528(%rsp),%rsi
    45f1:	test   $0x1,%rsi
    45f8:	jne    4630 <botlish_fn_19+0x2d48>
    45fe:	mov    0x550(%rsp),%rdx
    4606:	mov    0x528(%rsp),%rsi
    460e:	mov    0x4a0(%rsp),%rdi
    4616:	call   461b <botlish_fn_19+0x2d33>
			4617: R_X86_64_PLT32	rt_int_cmp-0x4
    461b:	mov    $0x2,%ecx
    4620:	test   %rax,%rax
    4623:	cmove  0x2945(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    462b:	jmp    4649 <botlish_fn_19+0x2d61>
    4630:	mov    $0x2,%ecx
    4635:	mov    0x528(%rsp),%rsi
    463d:	cmp    $0xffffffffffffffff,%rsi
    4641:	cmove  0x2927(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4649:	cmp    $0x6,%rcx
    464d:	je     46e5 <botlish_fn_19+0x2dfd>
    4653:	mov    0x4a0(%rsp),%rdi
    465b:	mov    0x10(%rdi),%rax
    465f:	mov    0x238(%rax),%rbx
    4666:	mov    $0x1,%r12d
    466c:	mov    0x4c0(%rsp),%rsi
    4674:	shl    $1,%rsi
    4677:	mov    %rsi,0x4c0(%rsp)
    467f:	or     $0x1,%rsi
    4683:	mov    %rsi,0x4c0(%rsp)
    468b:	call   4690 <botlish_fn_19+0x2da8>
			468c: R_X86_64_PLT32	botlish_fn_9-0x4
    4690:	mov    0x4a0(%rsp),%rdi
    4698:	mov    0x10(%rdi),%rcx
    469c:	mov    0x220(%rcx),%rdx
    46a3:	lea    0x410(%rsp),%r9
    46ab:	mov    %rbx,0x410(%rsp)
    46b3:	mov    %rax,0x418(%rsp)
    46bb:	mov    0x528(%rsp),%rsi
    46c3:	mov    %rsi,0x420(%rsp)
    46cb:	mov    $0x9,%ecx
    46d0:	mov    %r12,%rsi
    46d3:	mov    0x570(%rsp),%r8
    46db:	call   46e0 <botlish_fn_19+0x2df8>
			46dc: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    46e0:	jmp    4ee0 <botlish_fn_19+0x35f8>
    46e5:	mov    0x4a0(%rsp),%rdi
    46ed:	mov    0x10(%rdi),%rsi
    46f1:	mov    0x238(%rsi),%r12
    46f8:	mov    0x4c0(%rsp),%rsi
    4700:	shl    $1,%rsi
    4703:	mov    %rsi,0x4c0(%rsp)
    470b:	or     $0x1,%rsi
    470f:	mov    %rsi,0x4c0(%rsp)
    4717:	call   471c <botlish_fn_19+0x2e34>
			4718: R_X86_64_PLT32	botlish_fn_9-0x4
    471c:	mov    0x4a0(%rsp),%rdi
    4724:	mov    0x10(%rdi),%rsi
    4728:	mov    0x218(%rsi),%rdx
    472f:	lea    0x400(%rsp),%r9
    4737:	mov    %r12,0x400(%rsp)
    473f:	mov    %rax,0x408(%rsp)
    4747:	mov    $0x2,%r8d
    474d:	mov    0x558(%rsp),%rcx
    4755:	mov    %r8,%rsi
    4758:	call   475d <botlish_fn_19+0x2e75>
			4759: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    475d:	jmp    4ee0 <botlish_fn_19+0x35f8>
    4762:	xor    %rbx,%rbx
    4765:	mov    0x4a0(%rsp),%rdi
    476d:	mov    %r12,0x4c0(%rsp)
    4775:	jmp    48af <botlish_fn_19+0x2fc7>
    477a:	xor    %rbx,%rbx
    477d:	mov    0x4a0(%rsp),%rdi
    4785:	mov    0x508(%rsp),%r13
    478d:	mov    %r12,0x4c0(%rsp)
    4795:	jmp    4c11 <botlish_fn_19+0x3329>
    479a:	mov    $0xfffffffffffffffd,%rsi
    47a1:	mov    %rsi,0x528(%rsp)
    47a9:	test   $0x1,%rsi
    47b0:	jne    47e6 <botlish_fn_19+0x2efe>
    47b6:	mov    $0x1,%edx
    47bb:	mov    0x528(%rsp),%rsi
    47c3:	mov    0x4a0(%rsp),%rdi
    47cb:	call   47d0 <botlish_fn_19+0x2ee8>
			47cc: R_X86_64_PLT32	rt_int_cmp-0x4
    47d0:	mov    $0x2,%r10d
    47d6:	test   %rax,%rax
    47d9:	cmovge 0x278f(%rip),%r10        # 6f70 <botlish_fn_19+0x5688>
    47e1:	jmp    4807 <botlish_fn_19+0x2f1f>
    47e6:	mov    $0x2,%r10d
    47ec:	mov    0x528(%rsp),%rax
    47f4:	mov    0x528(%rsp),%rsi
    47fc:	test   %rax,%rsi
    47ff:	cmovg  0x2769(%rip),%r10        # 6f70 <botlish_fn_19+0x5688>
    4807:	cmp    $0x6,%r10
    480b:	je     481b <botlish_fn_19+0x2f33>
    4811:	mov    $0x1,%ebx
    4816:	jmp    4823 <botlish_fn_19+0x2f3b>
    481b:	mov    0x570(%rsp),%rbx
    4823:	mov    %rbx,0x30(%rsp)
    4828:	mov    0x4d8(%rsp),%rax
    4830:	mov    %rax,0x528(%rsp)
    4838:	mov    %r12,0x4c0(%rsp)
    4840:	mov    0x508(%rsp),%r13
    4848:	mov    0x550(%rsp),%r12
    4850:	jmp    5110 <botlish_fn_19+0x3828>
    4855:	mov    0x4c0(%rsp),%rsi
    485d:	shl    $1,%rsi
    4860:	mov    %rsi,0x4c0(%rsp)
    4868:	or     $0x1,%rsi
    486c:	mov    %rsi,0x4c0(%rsp)
    4874:	mov    %rsi,0xa0(%rsp)
    487c:	mov    0x508(%rsp),%r13
    4884:	jmp    50b2 <botlish_fn_19+0x37ca>
    4889:	mov    0x510(%rsp),%rsi
    4891:	mov    %rsi,%rbx
    4894:	sar    $1,%rbx
    4897:	mov    0x4a0(%rsp),%rdi
    489f:	mov    0x528(%rsp),%rax
    48a7:	mov    %rax,0x4d8(%rsp)
    48af:	mov    0x4a0(%rsp),%rdi
    48b7:	mov    0x10(%rdi),%rax
    48bb:	mov    0x228(%rax),%r12
    48c2:	mov    0x528(%rsp),%rsi
    48ca:	test   $0x1,%rsi
    48d1:	jne    490a <botlish_fn_19+0x3022>
    48d7:	mov    0x550(%rsp),%rdx
    48df:	mov    0x528(%rsp),%rsi
    48e7:	mov    0x4a0(%rsp),%rdi
    48ef:	call   48f4 <botlish_fn_19+0x300c>
			48f0: R_X86_64_PLT32	rt_int_cmp-0x4
    48f4:	mov    $0x2,%r11d
    48fa:	test   %rax,%rax
    48fd:	cmovl  0x266b(%rip),%r11        # 6f70 <botlish_fn_19+0x5688>
    4905:	jmp    4924 <botlish_fn_19+0x303c>
    490a:	mov    $0x2,%r11d
    4910:	mov    0x528(%rsp),%rsi
    4918:	cmp    $0xffffffffffffffff,%rsi
    491c:	cmovl  0x264c(%rip),%r11        # 6f70 <botlish_fn_19+0x5688>
    4924:	cmp    $0x6,%r11
    4928:	je     49c7 <botlish_fn_19+0x30df>
    492e:	mov    0x528(%rsp),%rsi
    4936:	test   $0x1,%rsi
    493d:	jne    4972 <botlish_fn_19+0x308a>
    4943:	mov    $0x1ff,%edx
    4948:	mov    0x528(%rsp),%rsi
    4950:	mov    0x4a0(%rsp),%rdi
    4958:	call   495d <botlish_fn_19+0x3075>
			4959: R_X86_64_PLT32	rt_int_cmp-0x4
    495d:	mov    $0x2,%ecx
    4962:	test   %rax,%rax
    4965:	cmovg  0x2603(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    496d:	jmp    498e <botlish_fn_19+0x30a6>
    4972:	mov    $0x2,%ecx
    4977:	mov    0x528(%rsp),%rsi
    497f:	cmp    $0x1ff,%rsi
    4986:	cmovg  0x25e2(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    498e:	cmp    $0x6,%rcx
    4992:	je     49c7 <botlish_fn_19+0x30df>
    4998:	shl    $1,%rbx
    499b:	or     $0x1,%rbx
    499f:	sar    $1,%rbx
    49a2:	imul   $0x101,%rbx,%rax
    49a9:	mov    0x528(%rsp),%rsi
    49b1:	mov    %rsi,%rcx
    49b4:	sar    $1,%rcx
    49b7:	lea    0x1(%rax,%rcx,1),%rax
    49bc:	movzbq 0x10(%r12,%rax,1),%rsi
    49c2:	jmp    49da <botlish_fn_19+0x30f2>
    49c7:	shl    $1,%rbx
    49ca:	or     $0x1,%rbx
    49ce:	sar    $1,%rbx
    49d1:	movzbq 0x818(%r12,%rbx,1),%rsi
    49da:	mov    %rsi,%rcx
    49dd:	shl    $1,%rcx
    49e0:	or     $0x1,%rcx
    49e4:	mov    $0x2,%eax
    49e9:	cmp    $0x11,%rcx
    49ed:	cmovl  0x257b(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    49f5:	cmp    $0x6,%rax
    49f9:	je     4ba3 <botlish_fn_19+0x32bb>
    49ff:	mov    %rsi,%rax
    4a02:	shl    $1,%rax
    4a05:	mov    %rsi,%r13
    4a08:	or     $0x1,%rax
    4a0c:	mov    $0x2,%esi
    4a11:	cmp    $0x11,%rax
    4a15:	cmove  0x2553(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    4a1d:	cmp    $0x6,%rsi
    4a21:	je     4b86 <botlish_fn_19+0x329e>
    4a27:	mov    0x528(%rsp),%rsi
    4a2f:	test   $0x1,%rsi
    4a36:	jne    4a6e <botlish_fn_19+0x3186>
    4a3c:	mov    0x550(%rsp),%rdx
    4a44:	mov    0x528(%rsp),%rsi
    4a4c:	mov    0x4a0(%rsp),%rdi
    4a54:	call   4a59 <botlish_fn_19+0x3171>
			4a55: R_X86_64_PLT32	rt_int_cmp-0x4
    4a59:	mov    $0x2,%ecx
    4a5e:	test   %rax,%rax
    4a61:	cmove  0x2507(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4a69:	jmp    4a87 <botlish_fn_19+0x319f>
    4a6e:	mov    $0x2,%ecx
    4a73:	mov    0x528(%rsp),%rsi
    4a7b:	cmp    $0xffffffffffffffff,%rsi
    4a7f:	cmove  0x24e9(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4a87:	cmp    $0x6,%rcx
    4a8b:	je     4b0e <botlish_fn_19+0x3226>
    4a91:	mov    0x4a0(%rsp),%rdi
    4a99:	mov    0x10(%rdi),%rsi
    4a9d:	mov    0x230(%rsi),%rbx
    4aa4:	mov    $0x1,%r12d
    4aaa:	mov    %r13,%rsi
    4aad:	shl    $1,%rsi
    4ab0:	or     $0x1,%rsi
    4ab4:	call   4ab9 <botlish_fn_19+0x31d1>
			4ab5: R_X86_64_PLT32	botlish_fn_7-0x4
    4ab9:	mov    0x4a0(%rsp),%rdi
    4ac1:	mov    0x10(%rdi),%rsi
    4ac5:	mov    0x220(%rsi),%rdx
    4acc:	lea    0x3e8(%rsp),%r9
    4ad4:	mov    %rbx,0x3e8(%rsp)
    4adc:	mov    %rax,0x3f0(%rsp)
    4ae4:	mov    0x528(%rsp),%rsi
    4aec:	mov    %rsi,0x3f8(%rsp)
    4af4:	mov    $0x9,%ecx
    4af9:	mov    %r12,%rsi
    4afc:	mov    0x570(%rsp),%r8
    4b04:	call   4b09 <botlish_fn_19+0x3221>
			4b05: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4b09:	jmp    4ee0 <botlish_fn_19+0x35f8>
    4b0e:	mov    %r13,%rsi
    4b11:	mov    0x4a0(%rsp),%rdi
    4b19:	mov    0x10(%rdi),%rdi
    4b1d:	mov    0x230(%rdi),%r12
    4b24:	shl    $1,%rsi
    4b27:	or     $0x1,%rsi
    4b2b:	mov    0x4a0(%rsp),%rdi
    4b33:	call   4b38 <botlish_fn_19+0x3250>
			4b34: R_X86_64_PLT32	botlish_fn_7-0x4
    4b38:	mov    0x4a0(%rsp),%rdi
    4b40:	mov    0x10(%rdi),%rdi
    4b44:	mov    0x218(%rdi),%rdx
    4b4b:	lea    0x3d8(%rsp),%r9
    4b53:	mov    %r12,0x3d8(%rsp)
    4b5b:	mov    %rax,0x3e0(%rsp)
    4b63:	mov    $0x2,%r8d
    4b69:	mov    0x558(%rsp),%rcx
    4b71:	mov    0x4a0(%rsp),%rdi
    4b79:	mov    %r8,%rsi
    4b7c:	call   4b81 <botlish_fn_19+0x3299>
			4b7d: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4b81:	jmp    4ee0 <botlish_fn_19+0x35f8>
    4b86:	mov    0x508(%rsp),%r13
    4b8e:	mov    0x570(%rsp),%rax
    4b96:	mov    %rax,0x4c0(%rsp)
    4b9e:	jmp    50a2 <botlish_fn_19+0x37ba>
    4ba3:	shl    $1,%rsi
    4ba6:	or     $0x1,%rsi
    4baa:	mov    %rsi,0xb0(%rsp)
    4bb2:	mov    $0x1,%ebx
    4bb7:	movq   $0x1,0x30(%rsp)
    4bc0:	mov    $0x2,%r12d
    4bc6:	mov    0x508(%rsp),%r13
    4bce:	mov    %rsi,0x510(%rsp)
    4bd6:	mov    0x4d8(%rsp),%rax
    4bde:	mov    %rax,0x528(%rsp)
    4be6:	jmp    5110 <botlish_fn_19+0x3828>
    4beb:	mov    0x508(%rsp),%r13
    4bf3:	mov    %r13,%rbx
    4bf6:	sar    $1,%rbx
    4bf9:	mov    0x4a0(%rsp),%rdi
    4c01:	mov    0x528(%rsp),%rax
    4c09:	mov    %rax,0x4d8(%rsp)
    4c11:	mov    0x4a0(%rsp),%rdi
    4c19:	mov    0x10(%rdi),%rax
    4c1d:	mov    0x208(%rax),%r12
    4c24:	mov    0x528(%rsp),%rsi
    4c2c:	test   $0x1,%rsi
    4c33:	jne    4c6b <botlish_fn_19+0x3383>
    4c39:	mov    0x550(%rsp),%rdx
    4c41:	mov    0x528(%rsp),%rsi
    4c49:	mov    0x4a0(%rsp),%rdi
    4c51:	call   4c56 <botlish_fn_19+0x336e>
			4c52: R_X86_64_PLT32	rt_int_cmp-0x4
    4c56:	mov    $0x2,%ecx
    4c5b:	test   %rax,%rax
    4c5e:	cmovl  0x230a(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4c66:	jmp    4c84 <botlish_fn_19+0x339c>
    4c6b:	mov    $0x2,%ecx
    4c70:	mov    0x528(%rsp),%rsi
    4c78:	cmp    $0xffffffffffffffff,%rsi
    4c7c:	cmovl  0x22ec(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4c84:	cmp    $0x6,%rcx
    4c88:	je     4d27 <botlish_fn_19+0x343f>
    4c8e:	mov    0x528(%rsp),%rsi
    4c96:	test   $0x1,%rsi
    4c9d:	jne    4cd2 <botlish_fn_19+0x33ea>
    4ca3:	mov    $0x1ff,%edx
    4ca8:	mov    0x528(%rsp),%rsi
    4cb0:	mov    0x4a0(%rsp),%rdi
    4cb8:	call   4cbd <botlish_fn_19+0x33d5>
			4cb9: R_X86_64_PLT32	rt_int_cmp-0x4
    4cbd:	mov    $0x2,%ecx
    4cc2:	test   %rax,%rax
    4cc5:	cmovg  0x22a3(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4ccd:	jmp    4cee <botlish_fn_19+0x3406>
    4cd2:	mov    $0x2,%ecx
    4cd7:	mov    0x528(%rsp),%rsi
    4cdf:	cmp    $0x1ff,%rsi
    4ce6:	cmovg  0x2282(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4cee:	cmp    $0x6,%rcx
    4cf2:	je     4d27 <botlish_fn_19+0x343f>
    4cf8:	shl    $1,%rbx
    4cfb:	or     $0x1,%rbx
    4cff:	sar    $1,%rbx
    4d02:	imul   $0x101,%rbx,%rax
    4d09:	mov    0x528(%rsp),%rsi
    4d11:	mov    %rsi,%rcx
    4d14:	sar    $1,%rcx
    4d17:	lea    0x1(%rax,%rcx,1),%rax
    4d1c:	movzbq 0x10(%r12,%rax,1),%rsi
    4d22:	jmp    4d3a <botlish_fn_19+0x3452>
    4d27:	shl    $1,%rbx
    4d2a:	or     $0x1,%rbx
    4d2e:	sar    $1,%rbx
    4d31:	movzbq 0x616(%r12,%rbx,1),%rsi
    4d3a:	mov    %rsi,%rcx
    4d3d:	shl    $1,%rcx
    4d40:	or     $0x1,%rcx
    4d44:	mov    $0x2,%eax
    4d49:	cmp    $0xd,%rcx
    4d4d:	cmovl  0x221b(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    4d55:	cmp    $0x6,%rax
    4d59:	je     50dd <botlish_fn_19+0x37f5>
    4d5f:	mov    %rsi,%rcx
    4d62:	shl    $1,%rcx
    4d65:	mov    %rsi,0x530(%rsp)
    4d6d:	or     $0x1,%rcx
    4d71:	mov    $0x2,%eax
    4d76:	cmp    $0xd,%rcx
    4d7a:	cmove  0x21ee(%rip),%rax        # 6f70 <botlish_fn_19+0x5688>
    4d82:	cmp    $0x6,%rax
    4d86:	je     5092 <botlish_fn_19+0x37aa>
    4d8c:	mov    0x528(%rsp),%rsi
    4d94:	test   $0x1,%rsi
    4d9b:	jne    4dd3 <botlish_fn_19+0x34eb>
    4da1:	mov    0x550(%rsp),%rdx
    4da9:	mov    0x528(%rsp),%rsi
    4db1:	mov    0x4a0(%rsp),%rdi
    4db9:	call   4dbe <botlish_fn_19+0x34d6>
			4dba: R_X86_64_PLT32	rt_int_cmp-0x4
    4dbe:	mov    $0x2,%ecx
    4dc3:	test   %rax,%rax
    4dc6:	cmove  0x21a2(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4dce:	jmp    4dec <botlish_fn_19+0x3504>
    4dd3:	mov    $0x2,%ecx
    4dd8:	mov    0x528(%rsp),%rsi
    4de0:	cmp    $0xffffffffffffffff,%rsi
    4de4:	cmove  0x2184(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    4dec:	cmp    $0x6,%rcx
    4df0:	je     4e78 <botlish_fn_19+0x3590>
    4df6:	mov    0x4a0(%rsp),%rdi
    4dfe:	mov    0x10(%rdi),%rax
    4e02:	mov    0x210(%rax),%rbx
    4e09:	mov    $0x1,%r12d
    4e0f:	mov    0x530(%rsp),%rsi
    4e17:	shl    $1,%rsi
    4e1a:	or     $0x1,%rsi
    4e1e:	call   4e23 <botlish_fn_19+0x353b>
			4e1f: R_X86_64_PLT32	botlish_fn_5-0x4
    4e23:	mov    0x4a0(%rsp),%rdi
    4e2b:	mov    0x10(%rdi),%rcx
    4e2f:	mov    0x220(%rcx),%rdx
    4e36:	lea    0x3c0(%rsp),%r9
    4e3e:	mov    %rbx,0x3c0(%rsp)
    4e46:	mov    %rax,0x3c8(%rsp)
    4e4e:	mov    0x528(%rsp),%rsi
    4e56:	mov    %rsi,0x3d0(%rsp)
    4e5e:	mov    $0x9,%ecx
    4e63:	mov    %r12,%rsi
    4e66:	mov    0x570(%rsp),%r8
    4e6e:	call   4e73 <botlish_fn_19+0x358b>
			4e6f: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4e73:	jmp    4ee0 <botlish_fn_19+0x35f8>
    4e78:	mov    0x530(%rsp),%rsi
    4e80:	mov    0x4a0(%rsp),%rdi
    4e88:	mov    0x10(%rdi),%rax
    4e8c:	mov    0x210(%rax),%rbx
    4e93:	shl    $1,%rsi
    4e96:	or     $0x1,%rsi
    4e9a:	call   4e9f <botlish_fn_19+0x35b7>
			4e9b: R_X86_64_PLT32	botlish_fn_5-0x4
    4e9f:	mov    0x4a0(%rsp),%rdi
    4ea7:	mov    0x10(%rdi),%rcx
    4eab:	mov    0x218(%rcx),%rdx
    4eb2:	lea    0x3b0(%rsp),%r9
    4eba:	mov    %rbx,0x3b0(%rsp)
    4ec2:	mov    %rax,0x3b8(%rsp)
    4eca:	mov    $0x2,%r8d
    4ed0:	mov    0x558(%rsp),%rcx
    4ed8:	mov    %r8,%rsi
    4edb:	call   4ee0 <botlish_fn_19+0x35f8>
			4edc: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4ee0:	mov    0x4a0(%rsp),%rdi
    4ee8:	call   4eed <botlish_fn_19+0x3605>
			4ee9: R_X86_64_PLT32	rt_co_failed-0x4
    4eed:	mov    %rax,0x98(%rsp)
    4ef5:	mov    %rax,%rsi
    4ef8:	mov    0x4a0(%rsp),%rdi
    4f00:	call   4f05 <botlish_fn_19+0x361d>
			4f01: R_X86_64_PLT32	rt_co_resume0-0x4
    4f05:	test   %rax,%rax
    4f08:	je     4f35 <botlish_fn_19+0x364d>
    4f0e:	mov    0x4a0(%rsp),%rdi
    4f16:	mov    0x10(%rdi),%rsi
    4f1a:	mov    0x48(%rsi),%rdi
    4f1e:	mov    0x1b0(%rsi),%rdx
    4f25:	mov    %rdi,%rsi
    4f28:	mov    0x4a0(%rsp),%rdi
    4f30:	call   4f35 <botlish_fn_19+0x364d>
			4f31: R_X86_64_PLT32	rt_raise-0x4
    4f35:	mov    0x4a0(%rsp),%rdi
    4f3d:	call   4f42 <botlish_fn_19+0x365a>
			4f3e: R_X86_64_PLT32	rt_declared_error-0x4
    4f42:	cmp    $0x1,%rax
    4f46:	je     4feb <botlish_fn_19+0x3703>
    4f4c:	mov    0x4a0(%rsp),%rdi
    4f54:	call   4f59 <botlish_fn_19+0x3671>
			4f55: R_X86_64_PLT32	rt_declared_error-0x4
    4f59:	cmp    $0x2,%rax
    4f5d:	jne    6d30 <botlish_fn_19+0x5448>
    4f63:	xor    %rsi,%rsi
    4f66:	mov    0x4a0(%rsp),%rdi
    4f6e:	call   4f73 <botlish_fn_19+0x368b>
			4f6f: R_X86_64_PLT32	rt_declared_payload-0x4
    4f73:	mov    %rax,%rbx
    4f76:	mov    $0x1,%esi
    4f7b:	mov    0x4a0(%rsp),%rdi
    4f83:	call   4f88 <botlish_fn_19+0x36a0>
			4f84: R_X86_64_PLT32	rt_declared_payload-0x4
    4f88:	mov    %rax,%r12
    4f8b:	mov    0x4a0(%rsp),%rdi
    4f93:	call   4f98 <botlish_fn_19+0x36b0>
			4f94: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4f98:	mov    0x4a0(%rsp),%rdi
    4fa0:	mov    0x10(%rdi),%rax
    4fa4:	mov    0x1c0(%rax),%rdx
    4fab:	lea    0x130(%rsp),%r9
    4fb3:	mov    %r15,0x130(%rsp)
    4fbb:	mov    %rbx,%rax
    4fbe:	mov    %rax,0x138(%rsp)
    4fc6:	mov    %r12,%rax
    4fc9:	mov    %rax,0x140(%rsp)
    4fd1:	mov    $0x5,%esi
    4fd6:	mov    0x570(%rsp),%r8
    4fde:	mov    %r8,%rcx
    4fe1:	call   4fe6 <botlish_fn_19+0x36fe>
			4fe2: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    4fe6:	jmp    6d30 <botlish_fn_19+0x5448>
    4feb:	xor    %rsi,%rsi
    4fee:	mov    0x4a0(%rsp),%rdi
    4ff6:	call   4ffb <botlish_fn_19+0x3713>
			4ff7: R_X86_64_PLT32	rt_declared_payload-0x4
    4ffb:	mov    %rax,%r12
    4ffe:	mov    $0x1,%esi
    5003:	mov    0x4a0(%rsp),%rdi
    500b:	call   5010 <botlish_fn_19+0x3728>
			500c: R_X86_64_PLT32	rt_declared_payload-0x4
    5010:	mov    %rax,%r13
    5013:	mov    $0x2,%ebx
    5018:	mov    %rbx,%rsi
    501b:	mov    0x4a0(%rsp),%rdi
    5023:	call   5028 <botlish_fn_19+0x3740>
			5024: R_X86_64_PLT32	rt_declared_payload-0x4
    5028:	mov    %rax,%r14
    502b:	mov    0x4a0(%rsp),%rdi
    5033:	call   5038 <botlish_fn_19+0x3750>
			5034: R_X86_64_PLT32	rt_clear_declared_error-0x4
    5038:	mov    0x4a0(%rsp),%rdi
    5040:	mov    0x10(%rdi),%rax
    5044:	mov    0x1b8(%rax),%rdx
    504b:	lea    0x110(%rsp),%r9
    5053:	mov    %r15,0x110(%rsp)
    505b:	mov    %r12,%rax
    505e:	mov    %rax,0x118(%rsp)
    5066:	mov    %r13,%rax
    5069:	mov    %rax,0x120(%rsp)
    5071:	mov    %r14,%rax
    5074:	mov    %rax,0x128(%rsp)
    507c:	mov    $0x4,%r8d
    5082:	mov    %rbx,%rcx
    5085:	mov    %r8,%rsi
    5088:	call   508d <botlish_fn_19+0x37a5>
			5089: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    508d:	jmp    6d30 <botlish_fn_19+0x5448>
    5092:	mov    0x570(%rsp),%rax
    509a:	mov    %rax,0x4c0(%rsp)
    50a2:	mov    0x4c0(%rsp),%rsi
    50aa:	mov    %rsi,0xa0(%rsp)
    50b2:	mov    $0x1,%ebx
    50b7:	movq   $0x1,0x30(%rsp)
    50c0:	mov    0x570(%rsp),%r12
    50c8:	mov    0x4d8(%rsp),%rax
    50d0:	mov    %rax,0x528(%rsp)
    50d8:	jmp    5110 <botlish_fn_19+0x3828>
    50dd:	shl    $1,%rsi
    50e0:	or     $0x1,%rsi
    50e4:	mov    %rsi,0xa8(%rsp)
    50ec:	mov    $0x1,%ebx
    50f1:	movq   $0x1,0x30(%rsp)
    50fa:	mov    %rbx,%r12
    50fd:	mov    %rsi,%r13
    5100:	mov    0x4d8(%rsp),%rax
    5108:	mov    %rax,0x528(%rsp)
    5110:	mov    0x560(%rsp),%rax
    5118:	mov    0x18(%rax),%rax
    511c:	test   %rax,%rax
    511f:	je     6e98 <botlish_fn_19+0x55b0>
    5125:	mov    0x560(%rsp),%rax
    512d:	mov    0x10(%rax),%rax
    5131:	mov    %rbx,0x18(%rax)
    5135:	mov    %r13,0x508(%rsp)
    513d:	mov    %r14,0x578(%rsp)
    5145:	jmp    35f1 <botlish_fn_19+0x1d09>
    514a:	mov    0x4a0(%rsp),%rdi
    5152:	mov    0x10(%rdi),%rax
    5156:	mov    0x1c8(%rax),%rdx
    515d:	lea    0x100(%rsp),%r9
    5165:	mov    0x540(%rsp),%rsi
    516d:	mov    %rsi,0x100(%rsp)
    5175:	mov    0x4b8(%rsp),%rcx
    517d:	mov    %rcx,0x108(%rsp)
    5185:	mov    $0x4,%ecx
    518a:	mov    $0x2,%r8d
    5190:	mov    0x558(%rsp),%rsi
    5198:	call   519d <botlish_fn_19+0x38b5>
			5199: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    519d:	jmp    6d30 <botlish_fn_19+0x5448>
    51a2:	mov    0x578(%rsp),%r14
    51aa:	mov    0x560(%rsp),%rax
    51b2:	mov    0x10(%rax),%rax
    51b6:	mov    0x18(%rax),%rsi
    51ba:	test   $0x1,%rsi
    51c1:	jne    51ee <botlish_fn_19+0x3906>
    51c7:	mov    $0x1,%edx
    51cc:	mov    0x4a0(%rsp),%rdi
    51d4:	call   51d9 <botlish_fn_19+0x38f1>
			51d5: R_X86_64_PLT32	rt_int_cmp-0x4
    51d9:	mov    $0x2,%ecx
    51de:	test   %rax,%rax
    51e1:	cmove  0x1d87(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    51e9:	jmp    51ff <botlish_fn_19+0x3917>
    51ee:	mov    $0x2,%ecx
    51f3:	cmp    $0x1,%rsi
    51f7:	cmove  0x1d71(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    51ff:	cmp    $0x6,%rcx
    5203:	je     5216 <botlish_fn_19+0x392e>
    5209:	mov    0x4c8(%rsp),%rbx
    5211:	jmp    5796 <botlish_fn_19+0x3eae>
    5216:	mov    0x560(%rsp),%rax
    521e:	mov    0x10(%rax),%rax
    5222:	mov    0x8(%rax),%rsi
    5226:	test   $0x1,%rsi
    522d:	jne    525e <botlish_fn_19+0x3976>
    5233:	mov    0x550(%rsp),%rdx
    523b:	mov    0x4a0(%rsp),%rdi
    5243:	call   5248 <botlish_fn_19+0x3960>
			5244: R_X86_64_PLT32	rt_int_cmp-0x4
    5248:	mov    $0x2,%r10d
    524e:	test   %rax,%rax
    5251:	cmove  0x1d17(%rip),%r10        # 6f70 <botlish_fn_19+0x5688>
    5259:	jmp    5270 <botlish_fn_19+0x3988>
    525e:	mov    $0x2,%r10d
    5264:	cmp    $0xffffffffffffffff,%rsi
    5268:	cmove  0x1d00(%rip),%r10        # 6f70 <botlish_fn_19+0x5688>
    5270:	cmp    $0x6,%r10
    5274:	jne    5287 <botlish_fn_19+0x399f>
    527a:	mov    0x4c8(%rsp),%rbx
    5282:	jmp    5796 <botlish_fn_19+0x3eae>
    5287:	movq   $0x1,0x20(%rsp)
    5290:	mov    0x560(%rsp),%rax
    5298:	mov    0x10(%rax),%rdx
    529c:	mov    (%rdx),%rsi
    529f:	mov    %rsi,0x28(%rsp)
    52a4:	movq   $0x3,0x30(%rsp)
    52ad:	test   $0x1,%rsi
    52b4:	je     52db <botlish_fn_19+0x39f3>
    52ba:	mov    %rsi,%rcx
    52bd:	add    $0x2,%rcx
    52c1:	seto   %r9b
    52c5:	test   %r9b,%r9b
    52c8:	jne    52db <botlish_fn_19+0x39f3>
    52ce:	mov    0x560(%rsp),%rax
    52d6:	jmp    52fb <botlish_fn_19+0x3a13>
    52db:	mov    0x570(%rsp),%rdx
    52e3:	mov    0x4a0(%rsp),%rdi
    52eb:	call   52f0 <botlish_fn_19+0x3a08>
			52ec: R_X86_64_PLT32	rt_int_add-0x4
    52f0:	mov    %rax,%rcx
    52f3:	mov    0x560(%rsp),%rax
    52fb:	mov    0x560(%rsp),%rax
    5303:	mov    0x18(%rax),%rax
    5307:	test   %rax,%rax
    530a:	je     6ebd <botlish_fn_19+0x55d5>
    5310:	mov    0x560(%rsp),%rax
    5318:	mov    0x10(%rax),%rax
    531c:	mov    %rcx,(%rax)
    531f:	movq   $0x3,0x20(%rsp)
    5328:	mov    0x4c8(%rsp),%rbx
    5330:	cmp    $0x1,%rbx
    5334:	je     5356 <botlish_fn_19+0x3a6e>
    533a:	mov    $0xa,%esi
    533f:	cmp    $0xffffffffffffffff,%rbx
    5343:	jne    56bd <botlish_fn_19+0x3dd5>
    5349:	mov    0x560(%rsp),%rax
    5351:	jmp    575c <botlish_fn_19+0x3e74>
    5356:	movq   $0x3,0x28(%rsp)
    535f:	mov    0x4e0(%rsp),%rsi
    5367:	test   $0x1,%rsi
    536e:	jne    5381 <botlish_fn_19+0x3a99>
    5374:	mov    0x4e0(%rsp),%rsi
    537c:	jmp    53b8 <botlish_fn_19+0x3ad0>
    5381:	mov    0x4e0(%rsp),%rsi
    5389:	mov    %rsi,%rcx
    538c:	add    $0x2,%rcx
    5390:	seto   %al
    5393:	test   %al,%al
    5395:	je     53a8 <botlish_fn_19+0x3ac0>
    539b:	mov    0x4e0(%rsp),%rsi
    53a3:	jmp    53b8 <botlish_fn_19+0x3ad0>
    53a8:	mov    %rcx,%rsi
    53ab:	mov    %rcx,0x4e0(%rsp)
    53b3:	jmp    53d8 <botlish_fn_19+0x3af0>
    53b8:	mov    0x570(%rsp),%rdx
    53c0:	mov    0x4a0(%rsp),%rdi
    53c8:	call   53cd <botlish_fn_19+0x3ae5>
			53c9: R_X86_64_PLT32	rt_int_add-0x4
    53cd:	mov    %rax,%rsi
    53d0:	mov    %rax,0x4e0(%rsp)
    53d8:	mov    %rsi,0x70(%rsp)
    53dd:	mov    0x4e8(%rsp),%rax
    53e5:	mov    0x4e0(%rsp),%rsi
    53ed:	mov    %rsi,%rcx
    53f0:	and    %rax,%rcx
    53f3:	test   $0x1,%rcx
    53fa:	jne    5432 <botlish_fn_19+0x3b4a>
    5400:	mov    0x4e8(%rsp),%rdx
    5408:	mov    0x4e0(%rsp),%rsi
    5410:	mov    0x4a0(%rsp),%rdi
    5418:	call   541d <botlish_fn_19+0x3b35>
			5419: R_X86_64_PLT32	rt_int_cmp-0x4
    541d:	mov    $0x2,%ecx
    5422:	test   %rax,%rax
    5425:	cmovl  0x1b43(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    542d:	jmp    5452 <botlish_fn_19+0x3b6a>
    5432:	mov    $0x2,%ecx
    5437:	mov    0x4e8(%rsp),%rax
    543f:	mov    0x4e0(%rsp),%rsi
    5447:	cmp    %rax,%rsi
    544a:	cmovl  0x1b1e(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5452:	cmp    $0x6,%rcx
    5456:	je     564a <botlish_fn_19+0x3d62>
    545c:	movq   $0x3,0x28(%rsp)
    5465:	mov    0x4f8(%rsp),%rsi
    546d:	test   $0x1,%rsi
    5474:	jne    5487 <botlish_fn_19+0x3b9f>
    547a:	mov    0x4f8(%rsp),%rsi
    5482:	jmp    54be <botlish_fn_19+0x3bd6>
    5487:	mov    0x4f8(%rsp),%rsi
    548f:	mov    %rsi,%rcx
    5492:	add    $0x2,%rcx
    5496:	seto   %al
    5499:	test   %al,%al
    549b:	je     54ae <botlish_fn_19+0x3bc6>
    54a1:	mov    0x4f8(%rsp),%rsi
    54a9:	jmp    54be <botlish_fn_19+0x3bd6>
    54ae:	mov    %rcx,%rsi
    54b1:	mov    %rcx,0x4f8(%rsp)
    54b9:	jmp    54de <botlish_fn_19+0x3bf6>
    54be:	mov    0x570(%rsp),%rdx
    54c6:	mov    0x4a0(%rsp),%rdi
    54ce:	call   54d3 <botlish_fn_19+0x3beb>
			54cf: R_X86_64_PLT32	rt_int_add-0x4
    54d3:	mov    %rax,%rsi
    54d6:	mov    %rax,0x4f8(%rsp)
    54de:	mov    %rsi,0x58(%rsp)
    54e3:	mov    0x4f8(%rsp),%rsi
    54eb:	mov    %rsi,%rax
    54ee:	and    %r14,%rax
    54f1:	test   $0x1,%rax
    54f7:	jne    552a <botlish_fn_19+0x3c42>
    54fd:	mov    %r14,%rdx
    5500:	mov    0x4f8(%rsp),%rsi
    5508:	mov    0x4a0(%rsp),%rdi
    5510:	call   5515 <botlish_fn_19+0x3c2d>
			5511: R_X86_64_PLT32	rt_int_cmp-0x4
    5515:	mov    $0x2,%ecx
    551a:	test   %rax,%rax
    551d:	cmovl  0x1a4b(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5525:	jmp    5542 <botlish_fn_19+0x3c5a>
    552a:	mov    $0x2,%ecx
    552f:	mov    0x4f8(%rsp),%rsi
    5537:	cmp    %r14,%rsi
    553a:	cmovl  0x1a2e(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5542:	cmp    $0x6,%rcx
    5546:	je     557a <botlish_fn_19+0x3c92>
    554c:	movq   $0xffffffffffffffff,0x38(%rsp)
    5555:	mov    0x560(%rsp),%rax
    555d:	mov    0x550(%rsp),%rbx
    5565:	mov    0x550(%rsp),%rcx
    556d:	mov    %rcx,0x528(%rsp)
    5575:	jmp    575c <botlish_fn_19+0x3e74>
    557a:	mov    0x4f8(%rsp),%rsi
    5582:	test   $0x1,%rsi
    5589:	je     55b2 <botlish_fn_19+0x3cca>
    558f:	mov    0x4a8(%rsp),%r13
    5597:	mov    0x8(%r13),%rcx
    559b:	mov    0x4f8(%rsp),%rsi
    55a3:	mov    %rsi,%rax
    55a6:	sar    $1,%rax
    55a9:	cmp    %rcx,%rax
    55ac:	jb     55f0 <botlish_fn_19+0x3d08>
    55b2:	mov    0x4f8(%rsp),%rdx
    55ba:	mov    0x4a8(%rsp),%rsi
    55c2:	mov    0x4a0(%rsp),%rdi
    55ca:	call   55cf <botlish_fn_19+0x3ce7>
			55cb: R_X86_64_PLT32	rt_list_get-0x4
    55cf:	mov    %rax,%rcx
    55d2:	mov    %rax,0x4f0(%rsp)
    55da:	test   %rcx,%rax
    55dd:	je     56a8 <botlish_fn_19+0x3dc0>
    55e3:	mov    0x4f0(%rsp),%rax
    55eb:	jmp    5608 <botlish_fn_19+0x3d20>
    55f0:	mov    0x4a8(%rsp),%r13
    55f8:	mov    0x10(%r13),%rcx
    55fc:	mov    (%rcx,%rax,8),%rax
    5600:	mov    %rax,0x4f0(%rsp)
    5608:	mov    %rax,0x60(%rsp)
    560d:	mov    0x4f0(%rsp),%rsi
    5615:	mov    0x4a0(%rsp),%rdi
    561d:	call   5622 <botlish_fn_19+0x3d3a>
			561e: R_X86_64_PLT32	rt_list_len-0x4
    5622:	mov    %rax,0x4e8(%rsp)
    562a:	mov    %rax,0x68(%rsp)
    562f:	mov    $0x1,%esi
    5634:	mov    %rsi,0x4e0(%rsp)
    563c:	movq   $0x1,0x70(%rsp)
    5645:	jmp    53ed <botlish_fn_19+0x3b05>
    564a:	mov    0x4e0(%rsp),%rsi
    5652:	test   $0x1,%rsi
    5659:	je     5682 <botlish_fn_19+0x3d9a>
    565f:	mov    0x4f0(%rsp),%rax
    5667:	mov    0x8(%rax),%rcx
    566b:	mov    0x4e0(%rsp),%rsi
    5673:	mov    %rsi,%rax
    5676:	sar    $1,%rax
    5679:	cmp    %rcx,%rax
    567c:	jb     5732 <botlish_fn_19+0x3e4a>
    5682:	mov    0x4e0(%rsp),%rdx
    568a:	mov    0x4f0(%rsp),%rsi
    5692:	mov    0x4a0(%rsp),%rdi
    569a:	call   569f <botlish_fn_19+0x3db7>
			569b: R_X86_64_PLT32	rt_list_get-0x4
    569f:	test   %rax,%rax
    56a2:	jne    5722 <botlish_fn_19+0x3e3a>
    56a8:	mov    0x4a0(%rsp),%rdi
    56b0:	call   56b5 <botlish_fn_19+0x3dcd>
			56b1: R_X86_64_PLT32	rt_co_failed-0x4
    56b5:	mov    %rax,0x40(%rsp)
    56ba:	mov    %rax,%rsi
    56bd:	mov    0x4a0(%rsp),%rdi
    56c5:	call   56ca <botlish_fn_19+0x3de2>
			56c6: R_X86_64_PLT32	rt_co_resume0-0x4
    56ca:	test   %rax,%rax
    56cd:	jne    56e0 <botlish_fn_19+0x3df8>
    56d3:	mov    0x4a0(%rsp),%rdi
    56db:	jmp    5704 <botlish_fn_19+0x3e1c>
    56e0:	mov    0x4a0(%rsp),%rdi
    56e8:	mov    0x10(%rdi),%rax
    56ec:	mov    0x48(%rax),%rsi
    56f0:	mov    0x1b0(%rax),%rdx
    56f7:	call   56fc <botlish_fn_19+0x3e14>
			56f8: R_X86_64_PLT32	rt_raise-0x4
    56fc:	mov    0x4a0(%rsp),%rdi
    5704:	mov    0x4a0(%rsp),%rdi
    570c:	call   5711 <botlish_fn_19+0x3e29>
			570d: R_X86_64_PLT32	rt_declared_error-0x4
    5711:	cmp    $0x40000001,%rax
    5717:	jne    6d30 <botlish_fn_19+0x5448>
    571d:	jmp    6d30 <botlish_fn_19+0x5448>
    5722:	mov    %rax,%rsi
    5725:	mov    %rax,0x528(%rsp)
    572d:	jmp    574a <botlish_fn_19+0x3e62>
    5732:	mov    0x4f0(%rsp),%rdi
    573a:	mov    0x10(%rdi),%rcx
    573e:	mov    (%rcx,%rax,8),%rsi
    5742:	mov    %rsi,0x528(%rsp)
    574a:	mov    %rsi,0x38(%rsp)
    574f:	mov    $0x1,%ebx
    5754:	mov    0x560(%rsp),%rax
    575c:	mov    0x560(%rsp),%rax
    5764:	mov    0x18(%rax),%rax
    5768:	test   %rax,%rax
    576b:	je     6edc <botlish_fn_19+0x55f4>
    5771:	mov    0x560(%rsp),%rax
    5779:	mov    0x10(%rax),%rax
    577d:	mov    0x528(%rsp),%rsi
    5785:	mov    %rsi,0x8(%rax)
    5789:	mov    0x538(%rsp),%rsi
    5791:	jmp    579e <botlish_fn_19+0x3eb6>
    5796:	mov    0x538(%rsp),%rsi
    579e:	mov    0x538(%rsp),%rsi
    57a6:	mov    0x4a0(%rsp),%rdi
    57ae:	call   57b3 <botlish_fn_19+0x3ecb>
			57af: R_X86_64_PLT32	botlish_fn_14-0x4
    57b3:	mov    %rax,%r12
    57b6:	mov    0x560(%rsp),%rax
    57be:	mov    0x10(%rax),%rax
    57c2:	mov    (%rax),%rax
    57c5:	mov    0x4d0(%rsp),%r15
    57cd:	cmp    $0x1,%r15
    57d1:	je     57f3 <botlish_fn_19+0x3f0b>
    57d7:	mov    $0xa,%esi
    57dc:	cmp    $0xffffffffffffffff,%r15
    57e0:	jne    6023 <botlish_fn_19+0x473b>
    57e6:	mov    0x500(%rsp),%r12
    57ee:	jmp    609f <botlish_fn_19+0x47b7>
    57f3:	mov    0x568(%rsp),%rsi
    57fb:	mov    0x4a0(%rsp),%rdi
    5803:	call   5808 <botlish_fn_19+0x3f20>
			5804: R_X86_64_PLT32	rt_mv_pop-0x4
    5808:	mov    %rax,%rcx
    580b:	mov    %rax,%r13
    580e:	test   %rcx,%rax
    5811:	jne    5897 <botlish_fn_19+0x3faf>
    5817:	mov    0x4a0(%rsp),%rdi
    581f:	call   5824 <botlish_fn_19+0x3f3c>
			5820: R_X86_64_PLT32	rt_declared_error-0x4
    5824:	cmp    $0x40000001,%rax
    582a:	jne    600b <botlish_fn_19+0x4723>
    5830:	mov    0x4a0(%rsp),%rdi
    5838:	call   583d <botlish_fn_19+0x3f55>
			5839: R_X86_64_PLT32	rt_clear_declared_error-0x4
    583d:	mov    0x4a0(%rsp),%rdi
    5845:	mov    0x10(%rdi),%rdi
    5849:	mov    0x1d0(%rdi),%rsi
    5850:	mov    0x1d8(%rdi),%rdx
    5857:	lea    0x258(%rsp),%r9
    585f:	mov    0x540(%rsp),%rax
    5867:	mov    %rax,0x258(%rsp)
    586f:	mov    %rsi,0x260(%rsp)
    5877:	mov    $0x6,%ecx
    587c:	mov    $0x2,%r8d
    5882:	mov    0x4a0(%rsp),%rdi
    588a:	mov    %rcx,%rsi
    588d:	call   5892 <botlish_fn_19+0x3faa>
			588e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5892:	jmp    600b <botlish_fn_19+0x4723>
    5897:	mov    %r13,%rax
    589a:	test   $0x1,%rax
    58a0:	jne    58d3 <botlish_fn_19+0x3feb>
    58a6:	mov    $0x1,%edx
    58ab:	mov    %r13,%rsi
    58ae:	mov    0x4a0(%rsp),%rdi
    58b6:	call   58bb <botlish_fn_19+0x3fd3>
			58b7: R_X86_64_PLT32	rt_int_cmp-0x4
    58bb:	mov    $0x2,%ecx
    58c0:	test   %rax,%rax
    58c3:	cmove  0x16a5(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    58cb:	mov    %r13,%r15
    58ce:	jmp    58e7 <botlish_fn_19+0x3fff>
    58d3:	mov    $0x2,%ecx
    58d8:	mov    %r13,%r15
    58db:	cmp    $0x1,%r15
    58df:	cmove  0x1689(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    58e7:	cmp    $0x6,%rcx
    58eb:	je     5fa8 <botlish_fn_19+0x46c0>
    58f1:	test   $0x1,%r15
    58f8:	jne    5928 <botlish_fn_19+0x4040>
    58fe:	mov    $0x5,%edx
    5903:	mov    %r15,%rsi
    5906:	mov    0x4a0(%rsp),%rdi
    590e:	call   5913 <botlish_fn_19+0x402b>
			590f: R_X86_64_PLT32	rt_int_cmp-0x4
    5913:	mov    $0x2,%esi
    5918:	test   %rax,%rax
    591b:	cmove  0x164d(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    5923:	jmp    5939 <botlish_fn_19+0x4051>
    5928:	mov    $0x2,%esi
    592d:	cmp    $0x5,%r15
    5931:	cmove  0x1637(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    5939:	cmp    $0x6,%rsi
    593d:	jne    594d <botlish_fn_19+0x4065>
    5943:	cmp    $0x72,%r12
    5947:	je     5f8e <botlish_fn_19+0x46a6>
    594d:	test   $0x1,%r15
    5954:	jne    5984 <botlish_fn_19+0x409c>
    595a:	mov    $0x9,%edx
    595f:	mov    %r15,%rsi
    5962:	mov    0x4a0(%rsp),%rdi
    596a:	call   596f <botlish_fn_19+0x4087>
			596b: R_X86_64_PLT32	rt_int_cmp-0x4
    596f:	mov    $0x2,%ecx
    5974:	test   %rax,%rax
    5977:	cmove  0x15f1(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    597f:	jmp    5995 <botlish_fn_19+0x40ad>
    5984:	mov    $0x2,%ecx
    5989:	cmp    $0x9,%r15
    598d:	cmove  0x15db(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5995:	cmp    $0x6,%rcx
    5999:	jne    59a9 <botlish_fn_19+0x40c1>
    599f:	cmp    $0x32,%r12
    59a3:	je     5f8e <botlish_fn_19+0x46a6>
    59a9:	test   $0x1,%r15
    59b0:	jne    59e3 <botlish_fn_19+0x40fb>
    59b6:	mov    0x548(%rsp),%rdx
    59be:	mov    %r15,%rsi
    59c1:	mov    0x4a0(%rsp),%rdi
    59c9:	call   59ce <botlish_fn_19+0x40e6>
			59ca: R_X86_64_PLT32	rt_int_cmp-0x4
    59ce:	mov    $0x2,%ecx
    59d3:	test   %rax,%rax
    59d6:	cmove  0x1592(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    59de:	jmp    59f4 <botlish_fn_19+0x410c>
    59e3:	mov    $0x2,%ecx
    59e8:	cmp    $0x7,%r15
    59ec:	cmove  0x157c(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    59f4:	cmp    $0x6,%rcx
    59f8:	jne    5a06 <botlish_fn_19+0x411e>
    59fe:	mov    %r15,%rsi
    5a01:	jmp    5e47 <botlish_fn_19+0x455f>
    5a06:	test   $0x1,%r15
    5a0d:	jne    5a3d <botlish_fn_19+0x4155>
    5a13:	mov    $0xb,%edx
    5a18:	mov    %r15,%rsi
    5a1b:	mov    0x4a0(%rsp),%rdi
    5a23:	call   5a28 <botlish_fn_19+0x4140>
			5a24: R_X86_64_PLT32	rt_int_cmp-0x4
    5a28:	mov    $0x2,%ecx
    5a2d:	test   %rax,%rax
    5a30:	cmove  0x1538(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5a38:	jmp    5a4e <botlish_fn_19+0x4166>
    5a3d:	mov    $0x2,%ecx
    5a42:	cmp    $0xb,%r15
    5a46:	cmove  0x1522(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5a4e:	cmp    $0x6,%rcx
    5a52:	jne    5a60 <botlish_fn_19+0x4178>
    5a58:	mov    %r15,%rsi
    5a5b:	jmp    5e47 <botlish_fn_19+0x455f>
    5a60:	test   $0x1,%r15
    5a67:	jne    5a97 <botlish_fn_19+0x41af>
    5a6d:	mov    $0xf,%edx
    5a72:	mov    %r15,%rsi
    5a75:	mov    0x4a0(%rsp),%rdi
    5a7d:	call   5a82 <botlish_fn_19+0x419a>
			5a7e: R_X86_64_PLT32	rt_int_cmp-0x4
    5a82:	mov    $0x2,%ecx
    5a87:	test   %rax,%rax
    5a8a:	cmove  0x14de(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5a92:	jmp    5aa8 <botlish_fn_19+0x41c0>
    5a97:	mov    $0x2,%ecx
    5a9c:	cmp    $0xf,%r15
    5aa0:	cmove  0x14c8(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5aa8:	cmp    $0x6,%rcx
    5aac:	je     5ddf <botlish_fn_19+0x44f7>
    5ab2:	test   $0x1,%r15
    5ab9:	jne    5ae9 <botlish_fn_19+0x4201>
    5abf:	mov    $0xd,%edx
    5ac4:	mov    %r15,%rsi
    5ac7:	mov    0x4a0(%rsp),%rdi
    5acf:	call   5ad4 <botlish_fn_19+0x41ec>
			5ad0: R_X86_64_PLT32	rt_int_cmp-0x4
    5ad4:	mov    $0x2,%ecx
    5ad9:	test   %rax,%rax
    5adc:	cmove  0x148c(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5ae4:	jmp    5afa <botlish_fn_19+0x4212>
    5ae9:	mov    $0x2,%ecx
    5aee:	cmp    $0xd,%r15
    5af2:	cmove  0x1476(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5afa:	cmp    $0x6,%rcx
    5afe:	jne    5b0c <botlish_fn_19+0x4224>
    5b04:	mov    %r15,%rsi
    5b07:	jmp    5d14 <botlish_fn_19+0x442c>
    5b0c:	test   $0x1,%r15
    5b13:	jne    5b46 <botlish_fn_19+0x425e>
    5b19:	mov    $0x9,%edx
    5b1e:	mov    %r15,%rsi
    5b21:	mov    0x4a0(%rsp),%rdi
    5b29:	call   5b2e <botlish_fn_19+0x4246>
			5b2a: R_X86_64_PLT32	rt_int_cmp-0x4
    5b2e:	mov    $0x2,%ecx
    5b33:	test   %rax,%rax
    5b36:	cmove  0x1432(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5b3e:	mov    %r15,%r13
    5b41:	jmp    5b5a <botlish_fn_19+0x4272>
    5b46:	mov    $0x2,%ecx
    5b4b:	cmp    $0x9,%r15
    5b4f:	mov    %r15,%r13
    5b52:	cmove  0x1416(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5b5a:	cmp    $0x6,%rcx
    5b5e:	jne    5b6c <botlish_fn_19+0x4284>
    5b64:	mov    %r13,%rsi
    5b67:	jmp    5d14 <botlish_fn_19+0x442c>
    5b6c:	mov    %r12,%rsi
    5b6f:	mov    0x4a0(%rsp),%rdi
    5b77:	call   5b7c <botlish_fn_19+0x4294>
			5b78: R_X86_64_PLT32	botlish_fn_15-0x4
    5b7c:	cmp    $0x6,%rax
    5b80:	je     5be1 <botlish_fn_19+0x42f9>
    5b86:	mov    %r13,%rsi
    5b89:	mov    0x4a0(%rsp),%rdi
    5b91:	call   5b96 <botlish_fn_19+0x42ae>
			5b92: R_X86_64_PLT32	botlish_fn_16-0x4
    5b96:	mov    0x4a0(%rsp),%rdi
    5b9e:	mov    0x10(%rdi),%rcx
    5ba2:	mov    0x1d8(%rcx),%rdx
    5ba9:	lea    0x2a8(%rsp),%r9
    5bb1:	mov    0x540(%rsp),%rsi
    5bb9:	mov    %rsi,0x2a8(%rsp)
    5bc1:	mov    %rax,0x2b0(%rsp)
    5bc9:	mov    $0x6,%ecx
    5bce:	mov    $0x2,%r8d
    5bd4:	mov    %rcx,%rsi
    5bd7:	call   5bdc <botlish_fn_19+0x42f4>
			5bd8: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5bdc:	jmp    600b <botlish_fn_19+0x4723>
    5be1:	mov    %r13,%rsi
    5be4:	test   $0x1,%rsi
    5beb:	jne    5c18 <botlish_fn_19+0x4330>
    5bf1:	mov    $0x5,%edx
    5bf6:	mov    0x4a0(%rsp),%rdi
    5bfe:	call   5c03 <botlish_fn_19+0x431b>
			5bff: R_X86_64_PLT32	rt_int_cmp-0x4
    5c03:	mov    $0x2,%ecx
    5c08:	test   %rax,%rax
    5c0b:	cmove  0x135d(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5c13:	jmp    5c29 <botlish_fn_19+0x4341>
    5c18:	mov    $0x2,%ecx
    5c1d:	cmp    $0x5,%rsi
    5c21:	cmove  0x1347(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    5c29:	cmp    $0x6,%rcx
    5c2d:	jne    5c50 <botlish_fn_19+0x4368>
    5c33:	mov    0x548(%rsp),%rdx
    5c3b:	mov    0x568(%rsp),%rsi
    5c43:	mov    0x4a0(%rsp),%rdi
    5c4b:	call   5c50 <botlish_fn_19+0x4368>
			5c4c: R_X86_64_PLT32	rt_mv_push-0x4
    5c50:	cmp    $0x52,%r12
    5c54:	jne    5c74 <botlish_fn_19+0x438c>
    5c5a:	mov    $0x5,%edx
    5c5f:	mov    0x568(%rsp),%rsi
    5c67:	mov    0x4a0(%rsp),%rdi
    5c6f:	call   5c74 <botlish_fn_19+0x438c>
			5c70: R_X86_64_PLT32	rt_mv_push-0x4
    5c74:	cmp    $0x12,%r12
    5c78:	jne    5c98 <botlish_fn_19+0x43b0>
    5c7e:	mov    $0x9,%edx
    5c83:	mov    0x568(%rsp),%rsi
    5c8b:	mov    0x4a0(%rsp),%rdi
    5c93:	call   5c98 <botlish_fn_19+0x43b0>
			5c94: R_X86_64_PLT32	rt_mv_push-0x4
    5c98:	mov    0x568(%rsp),%rsi
    5ca0:	mov    0x4a0(%rsp),%rdi
    5ca8:	call   5cad <botlish_fn_19+0x43c5>
			5ca9: R_X86_64_PLT32	rt_mv_len-0x4
    5cad:	sar    $1,%rax
    5cb0:	mov    0x4b0(%rsp),%r9
    5cb8:	mov    %r9,%rcx
    5cbb:	sar    $1,%rcx
    5cbe:	add    $0x1,%rcx
    5cc5:	cmp    %rcx,%rax
    5cc8:	jle    5f8e <botlish_fn_19+0x46a6>
    5cce:	mov    0x4a0(%rsp),%rdi
    5cd6:	mov    0x10(%rdi),%rax
    5cda:	mov    0x1e0(%rax),%rdx
    5ce1:	lea    0x2b8(%rsp),%r9
    5ce9:	mov    0x4b0(%rsp),%rax
    5cf1:	mov    %rax,0x2b8(%rsp)
    5cf9:	mov    $0x1,%r8d
    5cff:	mov    0x548(%rsp),%rcx
    5d07:	mov    %rcx,%rsi
    5d0a:	call   5d0f <botlish_fn_19+0x4427>
			5d0b: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5d0f:	jmp    600b <botlish_fn_19+0x4723>
    5d14:	cmp    $0xd2,%r12
    5d1b:	je     5d79 <botlish_fn_19+0x4491>
    5d21:	mov    0x4a0(%rsp),%rdi
    5d29:	call   5d2e <botlish_fn_19+0x4446>
			5d2a: R_X86_64_PLT32	botlish_fn_16-0x4
    5d2e:	mov    0x4a0(%rsp),%rdi
    5d36:	mov    0x10(%rdi),%rcx
    5d3a:	mov    0x1d8(%rcx),%rdx
    5d41:	lea    0x298(%rsp),%r9
    5d49:	mov    0x540(%rsp),%rsi
    5d51:	mov    %rsi,0x298(%rsp)
    5d59:	mov    %rax,0x2a0(%rsp)
    5d61:	mov    $0x6,%ecx
    5d66:	mov    $0x2,%r8d
    5d6c:	mov    %rcx,%rsi
    5d6f:	call   5d74 <botlish_fn_19+0x448c>
			5d70: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5d74:	jmp    600b <botlish_fn_19+0x4723>
    5d79:	mov    %rsi,%rcx
    5d7c:	sar    $1,%rcx
    5d7f:	cmp    $0x4,%rcx
    5d83:	jne    5f8e <botlish_fn_19+0x46a6>
    5d89:	mov    $0xb,%edx
    5d8e:	mov    0x568(%rsp),%rsi
    5d96:	mov    0x4a0(%rsp),%rdi
    5d9e:	call   5da3 <botlish_fn_19+0x44bb>
			5d9f: R_X86_64_PLT32	rt_mv_push-0x4
    5da3:	mov    0x570(%rsp),%rdx
    5dab:	mov    0x568(%rsp),%rsi
    5db3:	mov    0x4a0(%rsp),%rdi
    5dbb:	call   5dc0 <botlish_fn_19+0x44d8>
			5dbc: R_X86_64_PLT32	rt_mv_push-0x4
    5dc0:	mov    $0xf,%edx
    5dc5:	mov    0x568(%rsp),%rsi
    5dcd:	mov    0x4a0(%rsp),%rdi
    5dd5:	call   5dda <botlish_fn_19+0x44f2>
			5dd6: R_X86_64_PLT32	rt_mv_push-0x4
    5dda:	jmp    5f8e <botlish_fn_19+0x46a6>
    5ddf:	mov    %r15,%rsi
    5de2:	cmp    $0x92,%r12
    5de9:	je     5f8e <botlish_fn_19+0x46a6>
    5def:	mov    0x4a0(%rsp),%rdi
    5df7:	call   5dfc <botlish_fn_19+0x4514>
			5df8: R_X86_64_PLT32	botlish_fn_16-0x4
    5dfc:	mov    0x4a0(%rsp),%rdi
    5e04:	mov    0x10(%rdi),%r8
    5e08:	mov    0x1d8(%r8),%rdx
    5e0f:	lea    0x288(%rsp),%r9
    5e17:	mov    0x540(%rsp),%rsi
    5e1f:	mov    %rsi,0x288(%rsp)
    5e27:	mov    %rax,0x290(%rsp)
    5e2f:	mov    $0x6,%ecx
    5e34:	mov    $0x2,%r8d
    5e3a:	mov    %rcx,%rsi
    5e3d:	call   5e42 <botlish_fn_19+0x455a>
			5e3e: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5e42:	jmp    600b <botlish_fn_19+0x4723>
    5e47:	mov    %rsi,%rax
    5e4a:	sar    $1,%rax
    5e4d:	cmp    $0x3,%rax
    5e51:	jne    5e61 <botlish_fn_19+0x4579>
    5e57:	cmp    $0x72,%r12
    5e5b:	je     5f8e <botlish_fn_19+0x46a6>
    5e61:	cmp    $0x5,%rax
    5e65:	jne    5e75 <botlish_fn_19+0x458d>
    5e6b:	cmp    $0x32,%r12
    5e6f:	je     5f8e <botlish_fn_19+0x46a6>
    5e75:	cmp    $0xb2,%r12
    5e7c:	je     5eda <botlish_fn_19+0x45f2>
    5e82:	mov    0x4a0(%rsp),%rdi
    5e8a:	call   5e8f <botlish_fn_19+0x45a7>
			5e8b: R_X86_64_PLT32	botlish_fn_16-0x4
    5e8f:	mov    0x4a0(%rsp),%rdi
    5e97:	mov    0x10(%rdi),%rcx
    5e9b:	mov    0x1d8(%rcx),%rdx
    5ea2:	lea    0x278(%rsp),%r9
    5eaa:	mov    0x540(%rsp),%rsi
    5eb2:	mov    %rsi,0x278(%rsp)
    5eba:	mov    %rax,0x280(%rsp)
    5ec2:	mov    $0x6,%ecx
    5ec7:	mov    $0x2,%r8d
    5ecd:	mov    %rcx,%rsi
    5ed0:	call   5ed5 <botlish_fn_19+0x45ed>
			5ed1: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    5ed5:	jmp    600b <botlish_fn_19+0x4723>
    5eda:	cmp    $0x3,%rax
    5ede:	je     5f54 <botlish_fn_19+0x466c>
    5ee4:	mov    $0xb,%edx
    5ee9:	mov    0x568(%rsp),%rsi
    5ef1:	mov    0x4a0(%rsp),%rdi
    5ef9:	call   5efe <botlish_fn_19+0x4616>
			5efa: R_X86_64_PLT32	rt_mv_push-0x4
    5efe:	mov    0x570(%rsp),%rdx
    5f06:	mov    0x568(%rsp),%rsi
    5f0e:	mov    0x4a0(%rsp),%rdi
    5f16:	call   5f1b <botlish_fn_19+0x4633>
			5f17: R_X86_64_PLT32	rt_mv_push-0x4
    5f1b:	mov    $0xf,%edx
    5f20:	mov    0x568(%rsp),%rsi
    5f28:	mov    0x4a0(%rsp),%rdi
    5f30:	call   5f35 <botlish_fn_19+0x464d>
			5f31: R_X86_64_PLT32	rt_mv_push-0x4
    5f35:	mov    $0xd,%edx
    5f3a:	mov    0x568(%rsp),%rsi
    5f42:	mov    0x4a0(%rsp),%rdi
    5f4a:	call   5f4f <botlish_fn_19+0x4667>
			5f4b: R_X86_64_PLT32	rt_mv_push-0x4
    5f4f:	jmp    5f8e <botlish_fn_19+0x46a6>
    5f54:	mov    0x548(%rsp),%rdx
    5f5c:	mov    0x568(%rsp),%rsi
    5f64:	mov    0x4a0(%rsp),%rdi
    5f6c:	call   5f71 <botlish_fn_19+0x4689>
			5f6d: R_X86_64_PLT32	rt_mv_push-0x4
    5f71:	mov    0x570(%rsp),%rdx
    5f79:	mov    0x568(%rsp),%rsi
    5f81:	mov    0x4a0(%rsp),%rdi
    5f89:	call   5f8e <botlish_fn_19+0x46a6>
			5f8a: R_X86_64_PLT32	rt_mv_push-0x4
    5f8e:	mov    $0x6,%r12d
    5f94:	movq   $0x6,0x78(%rsp)
    5f9d:	mov    $0x1,%r15d
    5fa3:	jmp    609f <botlish_fn_19+0x47b7>
    5fa8:	mov    %r15,%rsi
    5fab:	cmp    $0x132,%r12
    5fb2:	je     6088 <botlish_fn_19+0x47a0>
    5fb8:	mov    0x4a0(%rsp),%rdi
    5fc0:	call   5fc5 <botlish_fn_19+0x46dd>
			5fc1: R_X86_64_PLT32	botlish_fn_16-0x4
    5fc5:	mov    0x4a0(%rsp),%rdi
    5fcd:	mov    0x10(%rdi),%rcx
    5fd1:	mov    0x1d8(%rcx),%rdx
    5fd8:	lea    0x268(%rsp),%r9
    5fe0:	mov    0x540(%rsp),%rsi
    5fe8:	mov    %rsi,0x268(%rsp)
    5ff0:	mov    %rax,0x270(%rsp)
    5ff8:	mov    $0x6,%ecx
    5ffd:	mov    $0x2,%r8d
    6003:	mov    %rcx,%rsi
    6006:	call   600b <botlish_fn_19+0x4723>
			6007: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    600b:	mov    0x4a0(%rsp),%rdi
    6013:	call   6018 <botlish_fn_19+0x4730>
			6014: R_X86_64_PLT32	rt_co_failed-0x4
    6018:	mov    %rax,0x80(%rsp)
    6020:	mov    %rax,%rsi
    6023:	mov    0x4a0(%rsp),%rdi
    602b:	call   6030 <botlish_fn_19+0x4748>
			602c: R_X86_64_PLT32	rt_co_resume0-0x4
    6030:	test   %rax,%rax
    6033:	je     6055 <botlish_fn_19+0x476d>
    6039:	mov    0x4a0(%rsp),%rdi
    6041:	mov    0x10(%rdi),%rax
    6045:	mov    0x48(%rax),%rsi
    6049:	mov    0x1b0(%rax),%rdx
    6050:	call   6055 <botlish_fn_19+0x476d>
			6051: R_X86_64_PLT32	rt_raise-0x4
    6055:	mov    0x4a0(%rsp),%rdi
    605d:	call   6062 <botlish_fn_19+0x477a>
			605e: R_X86_64_PLT32	rt_declared_error-0x4
    6062:	cmp    $0x6,%rax
    6066:	je     6d30 <botlish_fn_19+0x5448>
    606c:	mov    0x4a0(%rsp),%rdi
    6074:	call   6079 <botlish_fn_19+0x4791>
			6075: R_X86_64_PLT32	rt_declared_error-0x4
    6079:	cmp    $0x7,%rax
    607d:	jne    6d30 <botlish_fn_19+0x5448>
    6083:	jmp    6d30 <botlish_fn_19+0x5448>
    6088:	mov    $0x6,%r12d
    608e:	movq   $0x6,0x78(%rsp)
    6097:	mov    0x550(%rsp),%r15
    609f:	movq   $0x5,0x10(%rsp)
    60a8:	mov    0x560(%rsp),%rax
    60b0:	mov    0x10(%rax),%rsi
    60b4:	mov    0x10(%rsi),%rsi
    60b8:	mov    %rsi,0x18(%rsp)
    60bd:	movq   $0x3,0x20(%rsp)
    60c6:	test   $0x1,%rsi
    60cd:	je     60f2 <botlish_fn_19+0x480a>
    60d3:	mov    %rsi,%rcx
    60d6:	add    $0x2,%rcx
    60da:	seto   %al
    60dd:	test   %al,%al
    60df:	jne    60f2 <botlish_fn_19+0x480a>
    60e5:	mov    0x560(%rsp),%rax
    60ed:	jmp    6112 <botlish_fn_19+0x482a>
    60f2:	mov    0x570(%rsp),%rdx
    60fa:	mov    0x4a0(%rsp),%rdi
    6102:	call   6107 <botlish_fn_19+0x481f>
			6103: R_X86_64_PLT32	rt_int_add-0x4
    6107:	mov    %rax,%rcx
    610a:	mov    0x560(%rsp),%rax
    6112:	mov    0x560(%rsp),%rax
    611a:	mov    0x18(%rax),%rax
    611e:	test   %rax,%rax
    6121:	je     6f06 <botlish_fn_19+0x561e>
    6127:	mov    0x560(%rsp),%rax
    612f:	mov    0x10(%rax),%rax
    6133:	mov    %rcx,0x10(%rax)
    6137:	mov    0x560(%rsp),%rax
    613f:	mov    %rbx,0x4c8(%rsp)
    6147:	mov    %r15,0x4d0(%rsp)
    614f:	mov    %r12,0x500(%rsp)
    6157:	mov    %r14,0x578(%rsp)
    615f:	jmp    1fb9 <botlish_fn_19+0x6d1>
    6164:	mov    0x4c8(%rsp),%rbx
    616c:	mov    0x500(%rsp),%r12
    6174:	mov    0x578(%rsp),%r14
    617c:	mov    0x4d0(%rsp),%r15
    6184:	movq   $0x1,0x18(%rsp)
    618d:	movq   $0x3,0x20(%rsp)
    6196:	mov    0x540(%rsp),%rsi
    619e:	test   $0x1,%rsi
    61a5:	jne    61b8 <botlish_fn_19+0x48d0>
    61ab:	mov    0x540(%rsp),%rsi
    61b3:	jmp    61ec <botlish_fn_19+0x4904>
    61b8:	mov    0x540(%rsp),%rsi
    61c0:	mov    %rsi,%rcx
    61c3:	add    $0x2,%rcx
    61c7:	seto   %al
    61ca:	test   %al,%al
    61cc:	je     61df <botlish_fn_19+0x48f7>
    61d2:	mov    0x540(%rsp),%rsi
    61da:	jmp    61ec <botlish_fn_19+0x4904>
    61df:	mov    0x560(%rsp),%rax
    61e7:	jmp    620c <botlish_fn_19+0x4924>
    61ec:	mov    0x570(%rsp),%rdx
    61f4:	mov    0x4a0(%rsp),%rdi
    61fc:	call   6201 <botlish_fn_19+0x4919>
			61fd: R_X86_64_PLT32	rt_int_add-0x4
    6201:	mov    %rax,%rcx
    6204:	mov    0x560(%rsp),%rax
    620c:	mov    0x560(%rsp),%rax
    6214:	mov    0x18(%rax),%rax
    6218:	test   %rax,%rax
    621b:	je     6f25 <botlish_fn_19+0x563d>
    6221:	mov    0x560(%rsp),%rax
    6229:	mov    0x10(%rax),%rax
    622d:	mov    %rcx,(%rax)
    6230:	movq   $0x3,0x10(%rsp)
    6239:	cmp    $0x1,%rbx
    623d:	je     625f <botlish_fn_19+0x4977>
    6243:	mov    $0xa,%esi
    6248:	cmp    $0xffffffffffffffff,%rbx
    624c:	jne    65c8 <botlish_fn_19+0x4ce0>
    6252:	mov    0x560(%rsp),%rax
    625a:	jmp    6667 <botlish_fn_19+0x4d7f>
    625f:	movq   $0x3,0x28(%rsp)
    6268:	mov    0x4e0(%rsp),%rsi
    6270:	test   $0x1,%rsi
    6277:	jne    628a <botlish_fn_19+0x49a2>
    627d:	mov    0x4e0(%rsp),%rsi
    6285:	jmp    62c1 <botlish_fn_19+0x49d9>
    628a:	mov    0x4e0(%rsp),%rsi
    6292:	mov    %rsi,%rax
    6295:	add    $0x2,%rax
    6299:	seto   %cl
    629c:	test   %cl,%cl
    629e:	je     62b1 <botlish_fn_19+0x49c9>
    62a4:	mov    0x4e0(%rsp),%rsi
    62ac:	jmp    62c1 <botlish_fn_19+0x49d9>
    62b1:	mov    %rax,%rsi
    62b4:	mov    %rax,0x4e0(%rsp)
    62bc:	jmp    62e1 <botlish_fn_19+0x49f9>
    62c1:	mov    0x570(%rsp),%rdx
    62c9:	mov    0x4a0(%rsp),%rdi
    62d1:	call   62d6 <botlish_fn_19+0x49ee>
			62d2: R_X86_64_PLT32	rt_int_add-0x4
    62d6:	mov    %rax,%rsi
    62d9:	mov    %rax,0x4e0(%rsp)
    62e1:	mov    %rsi,0x70(%rsp)
    62e6:	mov    0x4e8(%rsp),%rax
    62ee:	mov    0x4e0(%rsp),%rsi
    62f6:	mov    %rsi,%rcx
    62f9:	and    %rax,%rcx
    62fc:	test   $0x1,%rcx
    6303:	jne    633b <botlish_fn_19+0x4a53>
    6309:	mov    0x4e8(%rsp),%rdx
    6311:	mov    0x4e0(%rsp),%rsi
    6319:	mov    0x4a0(%rsp),%rdi
    6321:	call   6326 <botlish_fn_19+0x4a3e>
			6322: R_X86_64_PLT32	rt_int_cmp-0x4
    6326:	mov    $0x2,%ecx
    632b:	test   %rax,%rax
    632e:	cmovl  0xc3a(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    6336:	jmp    635b <botlish_fn_19+0x4a73>
    633b:	mov    $0x2,%ecx
    6340:	mov    0x4e8(%rsp),%rax
    6348:	mov    0x4e0(%rsp),%rsi
    6350:	cmp    %rax,%rsi
    6353:	cmovl  0xc15(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    635b:	cmp    $0x6,%rcx
    635f:	je     6555 <botlish_fn_19+0x4c6d>
    6365:	movq   $0x3,0x28(%rsp)
    636e:	mov    0x4f8(%rsp),%rsi
    6376:	test   $0x1,%rsi
    637d:	jne    6390 <botlish_fn_19+0x4aa8>
    6383:	mov    0x4f8(%rsp),%rsi
    638b:	jmp    63c9 <botlish_fn_19+0x4ae1>
    6390:	mov    0x4f8(%rsp),%rsi
    6398:	mov    %rsi,%r9
    639b:	add    $0x2,%r9
    639f:	seto   %r11b
    63a3:	test   %r11b,%r11b
    63a6:	je     63b9 <botlish_fn_19+0x4ad1>
    63ac:	mov    0x4f8(%rsp),%rsi
    63b4:	jmp    63c9 <botlish_fn_19+0x4ae1>
    63b9:	mov    %r9,%rsi
    63bc:	mov    %r9,0x4f8(%rsp)
    63c4:	jmp    63e9 <botlish_fn_19+0x4b01>
    63c9:	mov    0x570(%rsp),%rdx
    63d1:	mov    0x4a0(%rsp),%rdi
    63d9:	call   63de <botlish_fn_19+0x4af6>
			63da: R_X86_64_PLT32	rt_int_add-0x4
    63de:	mov    %rax,%rsi
    63e1:	mov    %rax,0x4f8(%rsp)
    63e9:	mov    %rsi,0x58(%rsp)
    63ee:	mov    0x4f8(%rsp),%rsi
    63f6:	mov    %rsi,%rax
    63f9:	and    %r14,%rax
    63fc:	test   $0x1,%rax
    6402:	jne    6435 <botlish_fn_19+0x4b4d>
    6408:	mov    %r14,%rdx
    640b:	mov    0x4f8(%rsp),%rsi
    6413:	mov    0x4a0(%rsp),%rdi
    641b:	call   6420 <botlish_fn_19+0x4b38>
			641c: R_X86_64_PLT32	rt_int_cmp-0x4
    6420:	mov    $0x2,%ecx
    6425:	test   %rax,%rax
    6428:	cmovl  0xb40(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    6430:	jmp    644d <botlish_fn_19+0x4b65>
    6435:	mov    $0x2,%ecx
    643a:	mov    0x4f8(%rsp),%rsi
    6442:	cmp    %r14,%rsi
    6445:	cmovl  0xb23(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    644d:	cmp    $0x6,%rcx
    6451:	je     6485 <botlish_fn_19+0x4b9d>
    6457:	movq   $0xffffffffffffffff,0x38(%rsp)
    6460:	mov    0x560(%rsp),%rax
    6468:	mov    0x550(%rsp),%rbx
    6470:	mov    0x550(%rsp),%rcx
    6478:	mov    %rcx,0x528(%rsp)
    6480:	jmp    6667 <botlish_fn_19+0x4d7f>
    6485:	mov    0x4f8(%rsp),%rsi
    648d:	test   $0x1,%rsi
    6494:	je     64bd <botlish_fn_19+0x4bd5>
    649a:	mov    0x4a8(%rsp),%r13
    64a2:	mov    0x8(%r13),%rcx
    64a6:	mov    0x4f8(%rsp),%rsi
    64ae:	mov    %rsi,%rax
    64b1:	sar    $1,%rax
    64b4:	cmp    %rcx,%rax
    64b7:	jb     64fb <botlish_fn_19+0x4c13>
    64bd:	mov    0x4f8(%rsp),%rdx
    64c5:	mov    0x4a8(%rsp),%rsi
    64cd:	mov    0x4a0(%rsp),%rdi
    64d5:	call   64da <botlish_fn_19+0x4bf2>
			64d6: R_X86_64_PLT32	rt_list_get-0x4
    64da:	mov    %rax,%rcx
    64dd:	mov    %rax,0x4f0(%rsp)
    64e5:	test   %rcx,%rax
    64e8:	je     65b3 <botlish_fn_19+0x4ccb>
    64ee:	mov    0x4f0(%rsp),%rax
    64f6:	jmp    6513 <botlish_fn_19+0x4c2b>
    64fb:	mov    0x4a8(%rsp),%r13
    6503:	mov    0x10(%r13),%rcx
    6507:	mov    (%rcx,%rax,8),%rax
    650b:	mov    %rax,0x4f0(%rsp)
    6513:	mov    %rax,0x60(%rsp)
    6518:	mov    0x4f0(%rsp),%rsi
    6520:	mov    0x4a0(%rsp),%rdi
    6528:	call   652d <botlish_fn_19+0x4c45>
			6529: R_X86_64_PLT32	rt_list_len-0x4
    652d:	mov    %rax,0x4e8(%rsp)
    6535:	mov    %rax,0x68(%rsp)
    653a:	mov    $0x1,%esi
    653f:	mov    %rsi,0x4e0(%rsp)
    6547:	movq   $0x1,0x70(%rsp)
    6550:	jmp    62f6 <botlish_fn_19+0x4a0e>
    6555:	mov    0x4e0(%rsp),%rsi
    655d:	test   $0x1,%rsi
    6564:	je     658d <botlish_fn_19+0x4ca5>
    656a:	mov    0x4f0(%rsp),%rax
    6572:	mov    0x8(%rax),%rax
    6576:	mov    0x4e0(%rsp),%rsi
    657e:	mov    %rsi,%rcx
    6581:	sar    $1,%rcx
    6584:	cmp    %rax,%rcx
    6587:	jb     663d <botlish_fn_19+0x4d55>
    658d:	mov    0x4e0(%rsp),%rdx
    6595:	mov    0x4f0(%rsp),%rsi
    659d:	mov    0x4a0(%rsp),%rdi
    65a5:	call   65aa <botlish_fn_19+0x4cc2>
			65a6: R_X86_64_PLT32	rt_list_get-0x4
    65aa:	test   %rax,%rax
    65ad:	jne    662d <botlish_fn_19+0x4d45>
    65b3:	mov    0x4a0(%rsp),%rdi
    65bb:	call   65c0 <botlish_fn_19+0x4cd8>
			65bc: R_X86_64_PLT32	rt_co_failed-0x4
    65c0:	mov    %rax,0x40(%rsp)
    65c5:	mov    %rax,%rsi
    65c8:	mov    0x4a0(%rsp),%rdi
    65d0:	call   65d5 <botlish_fn_19+0x4ced>
			65d1: R_X86_64_PLT32	rt_co_resume0-0x4
    65d5:	test   %rax,%rax
    65d8:	jne    65eb <botlish_fn_19+0x4d03>
    65de:	mov    0x4a0(%rsp),%rdi
    65e6:	jmp    660f <botlish_fn_19+0x4d27>
    65eb:	mov    0x4a0(%rsp),%rdi
    65f3:	mov    0x10(%rdi),%rax
    65f7:	mov    0x48(%rax),%rsi
    65fb:	mov    0x1b0(%rax),%rdx
    6602:	call   6607 <botlish_fn_19+0x4d1f>
			6603: R_X86_64_PLT32	rt_raise-0x4
    6607:	mov    0x4a0(%rsp),%rdi
    660f:	mov    0x4a0(%rsp),%rdi
    6617:	call   661c <botlish_fn_19+0x4d34>
			6618: R_X86_64_PLT32	rt_declared_error-0x4
    661c:	cmp    $0x40000001,%rax
    6622:	jne    6d30 <botlish_fn_19+0x5448>
    6628:	jmp    6d30 <botlish_fn_19+0x5448>
    662d:	mov    %rax,%rsi
    6630:	mov    %rax,0x528(%rsp)
    6638:	jmp    6655 <botlish_fn_19+0x4d6d>
    663d:	mov    0x4f0(%rsp),%rax
    6645:	mov    0x10(%rax),%rdx
    6649:	mov    (%rdx,%rcx,8),%rsi
    664d:	mov    %rsi,0x528(%rsp)
    6655:	mov    %rsi,0x38(%rsp)
    665a:	mov    $0x1,%ebx
    665f:	mov    0x560(%rsp),%rax
    6667:	mov    0x560(%rsp),%rax
    666f:	mov    0x18(%rax),%rsi
    6673:	test   %rsi,%rsi
    6676:	je     6f44 <botlish_fn_19+0x565c>
    667c:	mov    0x560(%rsp),%rax
    6684:	mov    0x10(%rax),%rdi
    6688:	mov    0x528(%rsp),%rsi
    6690:	mov    %rsi,0x8(%rdi)
    6694:	mov    0x560(%rsp),%rax
    669c:	mov    %rbx,0x4c8(%rsp)
    66a4:	mov    %r15,0x4d0(%rsp)
    66ac:	mov    %r12,0x500(%rsp)
    66b4:	mov    %r14,0x578(%rsp)
    66bc:	jmp    1fb9 <botlish_fn_19+0x6d1>
    66c1:	mov    0x500(%rsp),%r12
    66c9:	mov    0x4d0(%rsp),%r15
    66d1:	cmp    $0x1,%r15
    66d5:	je     66ef <botlish_fn_19+0x4e07>
    66db:	mov    $0xa,%esi
    66e0:	cmp    $0xffffffffffffffff,%r15
    66e4:	je     6d76 <botlish_fn_19+0x548e>
    66ea:	jmp    6cd6 <botlish_fn_19+0x53ee>
    66ef:	mov    0x568(%rsp),%rsi
    66f7:	mov    0x4a0(%rsp),%rdi
    66ff:	call   6704 <botlish_fn_19+0x4e1c>
			6700: R_X86_64_PLT32	rt_mv_pop-0x4
    6704:	mov    %rax,%rcx
    6707:	mov    %rax,%rbx
    670a:	test   %rcx,%rax
    670d:	jne    678b <botlish_fn_19+0x4ea3>
    6713:	mov    0x4a0(%rsp),%rdi
    671b:	call   6720 <botlish_fn_19+0x4e38>
			671c: R_X86_64_PLT32	rt_declared_error-0x4
    6720:	cmp    $0x40000001,%rax
    6726:	jne    6cbe <botlish_fn_19+0x53d6>
    672c:	mov    0x4a0(%rsp),%rdi
    6734:	call   6739 <botlish_fn_19+0x4e51>
			6735: R_X86_64_PLT32	rt_clear_declared_error-0x4
    6739:	mov    0x4a0(%rsp),%rdi
    6741:	mov    0x10(%rdi),%rcx
    6745:	mov    0x1d0(%rcx),%rax
    674c:	mov    0x1d8(%rcx),%rdx
    6753:	lea    0x1e0(%rsp),%r9
    675b:	mov    0x540(%rsp),%rsi
    6763:	mov    %rsi,0x1e0(%rsp)
    676b:	mov    %rax,0x1e8(%rsp)
    6773:	mov    $0x6,%ecx
    6778:	mov    $0x2,%r8d
    677e:	mov    %rcx,%rsi
    6781:	call   6786 <botlish_fn_19+0x4e9e>
			6782: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6786:	jmp    6cbe <botlish_fn_19+0x53d6>
    678b:	mov    %rbx,%rax
    678e:	test   $0x1,%rax
    6794:	jne    67c4 <botlish_fn_19+0x4edc>
    679a:	mov    $0x1,%edx
    679f:	mov    %rbx,%rsi
    67a2:	mov    0x4a0(%rsp),%rdi
    67aa:	call   67af <botlish_fn_19+0x4ec7>
			67ab: R_X86_64_PLT32	rt_int_cmp-0x4
    67af:	mov    $0x2,%edx
    67b4:	test   %rax,%rax
    67b7:	cmove  0x7b1(%rip),%rdx        # 6f70 <botlish_fn_19+0x5688>
    67bf:	jmp    67d5 <botlish_fn_19+0x4eed>
    67c4:	mov    $0x2,%edx
    67c9:	cmp    $0x1,%rbx
    67cd:	cmove  0x79b(%rip),%rdx        # 6f70 <botlish_fn_19+0x5688>
    67d5:	cmp    $0x6,%rdx
    67d9:	je     6d67 <botlish_fn_19+0x547f>
    67df:	test   $0x1,%rbx
    67e6:	jne    6816 <botlish_fn_19+0x4f2e>
    67ec:	mov    $0x5,%edx
    67f1:	mov    %rbx,%rsi
    67f4:	mov    0x4a0(%rsp),%rdi
    67fc:	call   6801 <botlish_fn_19+0x4f19>
			67fd: R_X86_64_PLT32	rt_int_cmp-0x4
    6801:	mov    $0x2,%ecx
    6806:	test   %rax,%rax
    6809:	cmove  0x75f(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    6811:	jmp    6827 <botlish_fn_19+0x4f3f>
    6816:	mov    $0x2,%ecx
    681b:	cmp    $0x5,%rbx
    681f:	cmove  0x749(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    6827:	cmp    $0x6,%rcx
    682b:	test   $0x1,%rbx
    6832:	jne    6862 <botlish_fn_19+0x4f7a>
    6838:	mov    $0x9,%edx
    683d:	mov    %rbx,%rsi
    6840:	mov    0x4a0(%rsp),%rdi
    6848:	call   684d <botlish_fn_19+0x4f65>
			6849: R_X86_64_PLT32	rt_int_cmp-0x4
    684d:	mov    $0x2,%ecx
    6852:	test   %rax,%rax
    6855:	cmove  0x713(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    685d:	jmp    6873 <botlish_fn_19+0x4f8b>
    6862:	mov    $0x2,%ecx
    6867:	cmp    $0x9,%rbx
    686b:	cmove  0x6fd(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    6873:	cmp    $0x6,%rcx
    6877:	test   $0x1,%rbx
    687e:	jne    68b1 <botlish_fn_19+0x4fc9>
    6884:	mov    0x548(%rsp),%rdx
    688c:	mov    %rbx,%rsi
    688f:	mov    0x4a0(%rsp),%rdi
    6897:	call   689c <botlish_fn_19+0x4fb4>
			6898: R_X86_64_PLT32	rt_int_cmp-0x4
    689c:	mov    $0x2,%ecx
    68a1:	test   %rax,%rax
    68a4:	cmove  0x6c4(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    68ac:	jmp    68c2 <botlish_fn_19+0x4fda>
    68b1:	mov    $0x2,%ecx
    68b6:	cmp    $0x7,%rbx
    68ba:	cmove  0x6ae(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    68c2:	cmp    $0x6,%rcx
    68c6:	jne    68d4 <botlish_fn_19+0x4fec>
    68cc:	mov    %rbx,%rsi
    68cf:	jmp    6c5d <botlish_fn_19+0x5375>
    68d4:	test   $0x1,%rbx
    68db:	jne    690b <botlish_fn_19+0x5023>
    68e1:	mov    $0xb,%edx
    68e6:	mov    %rbx,%rsi
    68e9:	mov    0x4a0(%rsp),%rdi
    68f1:	call   68f6 <botlish_fn_19+0x500e>
			68f2: R_X86_64_PLT32	rt_int_cmp-0x4
    68f6:	mov    $0x2,%esi
    68fb:	test   %rax,%rax
    68fe:	cmove  0x66a(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    6906:	jmp    691c <botlish_fn_19+0x5034>
    690b:	mov    $0x2,%esi
    6910:	cmp    $0xb,%rbx
    6914:	cmove  0x654(%rip),%rsi        # 6f70 <botlish_fn_19+0x5688>
    691c:	cmp    $0x6,%rsi
    6920:	jne    692e <botlish_fn_19+0x5046>
    6926:	mov    %rbx,%rsi
    6929:	jmp    6c5d <botlish_fn_19+0x5375>
    692e:	test   $0x1,%rbx
    6935:	jne    6965 <botlish_fn_19+0x507d>
    693b:	mov    $0xf,%edx
    6940:	mov    %rbx,%rsi
    6943:	mov    0x4a0(%rsp),%rdi
    694b:	call   6950 <botlish_fn_19+0x5068>
			694c: R_X86_64_PLT32	rt_int_cmp-0x4
    6950:	mov    $0x2,%ecx
    6955:	test   %rax,%rax
    6958:	cmove  0x610(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    6960:	jmp    6976 <botlish_fn_19+0x508e>
    6965:	mov    $0x2,%ecx
    696a:	cmp    $0xf,%rbx
    696e:	cmove  0x5fa(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    6976:	cmp    $0x6,%rcx
    697a:	je     6c02 <botlish_fn_19+0x531a>
    6980:	test   $0x1,%rbx
    6987:	jne    69b7 <botlish_fn_19+0x50cf>
    698d:	mov    $0xd,%edx
    6992:	mov    %rbx,%rsi
    6995:	mov    0x4a0(%rsp),%rdi
    699d:	call   69a2 <botlish_fn_19+0x50ba>
			699e: R_X86_64_PLT32	rt_int_cmp-0x4
    69a2:	mov    $0x2,%ecx
    69a7:	test   %rax,%rax
    69aa:	cmove  0x5be(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    69b2:	jmp    69c8 <botlish_fn_19+0x50e0>
    69b7:	mov    $0x2,%ecx
    69bc:	cmp    $0xd,%rbx
    69c0:	cmove  0x5a8(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    69c8:	cmp    $0x6,%rcx
    69cc:	jne    69da <botlish_fn_19+0x50f2>
    69d2:	mov    %rbx,%rsi
    69d5:	jmp    6baa <botlish_fn_19+0x52c2>
    69da:	test   $0x1,%rbx
    69e1:	jne    6a11 <botlish_fn_19+0x5129>
    69e7:	mov    $0x9,%edx
    69ec:	mov    %rbx,%rsi
    69ef:	mov    0x4a0(%rsp),%rdi
    69f7:	call   69fc <botlish_fn_19+0x5114>
			69f8: R_X86_64_PLT32	rt_int_cmp-0x4
    69fc:	mov    $0x2,%ecx
    6a01:	test   %rax,%rax
    6a04:	cmove  0x564(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    6a0c:	jmp    6a22 <botlish_fn_19+0x513a>
    6a11:	mov    $0x2,%ecx
    6a16:	cmp    $0x9,%rbx
    6a1a:	cmove  0x54e(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    6a22:	cmp    $0x6,%rcx
    6a26:	jne    6a34 <botlish_fn_19+0x514c>
    6a2c:	mov    %rbx,%rsi
    6a2f:	jmp    6baa <botlish_fn_19+0x52c2>
    6a34:	mov    $0x132,%esi
    6a39:	mov    0x4a0(%rsp),%rdi
    6a41:	call   6a46 <botlish_fn_19+0x515e>
			6a42: R_X86_64_PLT32	botlish_fn_15-0x4
    6a46:	cmp    $0x6,%rax
    6a4a:	je     6aab <botlish_fn_19+0x51c3>
    6a50:	mov    %rbx,%rsi
    6a53:	mov    0x4a0(%rsp),%rdi
    6a5b:	call   6a60 <botlish_fn_19+0x5178>
			6a5c: R_X86_64_PLT32	botlish_fn_16-0x4
    6a60:	mov    0x4a0(%rsp),%rdi
    6a68:	mov    0x10(%rdi),%rcx
    6a6c:	mov    0x1d8(%rcx),%rdx
    6a73:	lea    0x230(%rsp),%r9
    6a7b:	mov    0x540(%rsp),%rsi
    6a83:	mov    %rsi,0x230(%rsp)
    6a8b:	mov    %rax,0x238(%rsp)
    6a93:	mov    $0x6,%ecx
    6a98:	mov    $0x2,%r8d
    6a9e:	mov    %rcx,%rsi
    6aa1:	call   6aa6 <botlish_fn_19+0x51be>
			6aa2: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6aa6:	jmp    6cbe <botlish_fn_19+0x53d6>
    6aab:	mov    %rbx,%rsi
    6aae:	test   $0x1,%rsi
    6ab5:	jne    6ae2 <botlish_fn_19+0x51fa>
    6abb:	mov    $0x5,%edx
    6ac0:	mov    0x4a0(%rsp),%rdi
    6ac8:	call   6acd <botlish_fn_19+0x51e5>
			6ac9: R_X86_64_PLT32	rt_int_cmp-0x4
    6acd:	mov    $0x2,%ecx
    6ad2:	test   %rax,%rax
    6ad5:	cmove  0x493(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    6add:	jmp    6af3 <botlish_fn_19+0x520b>
    6ae2:	mov    $0x2,%ecx
    6ae7:	cmp    $0x5,%rsi
    6aeb:	cmove  0x47d(%rip),%rcx        # 6f70 <botlish_fn_19+0x5688>
    6af3:	cmp    $0x6,%rcx
    6af7:	jne    6b1a <botlish_fn_19+0x5232>
    6afd:	mov    0x548(%rsp),%rdx
    6b05:	mov    0x568(%rsp),%rsi
    6b0d:	mov    0x4a0(%rsp),%rdi
    6b15:	call   6b1a <botlish_fn_19+0x5232>
			6b16: R_X86_64_PLT32	rt_mv_push-0x4
    6b1a:	mov    0x568(%rsp),%rsi
    6b22:	mov    0x4a0(%rsp),%rdi
    6b2a:	call   6b2f <botlish_fn_19+0x5247>
			6b2b: R_X86_64_PLT32	rt_mv_len-0x4
    6b2f:	sar    $1,%rax
    6b32:	mov    0x4b0(%rsp),%r9
    6b3a:	mov    %r9,%rcx
    6b3d:	sar    $1,%rcx
    6b40:	add    $0x1,%rcx
    6b47:	cmp    %rcx,%rax
    6b4a:	jg     6b64 <botlish_fn_19+0x527c>
    6b50:	mov    $0x6,%r12d
    6b56:	movq   $0x6,0x78(%rsp)
    6b5f:	jmp    6d76 <botlish_fn_19+0x548e>
    6b64:	mov    0x4a0(%rsp),%rdi
    6b6c:	mov    0x10(%rdi),%rsi
    6b70:	mov    0x1e0(%rsi),%rdx
    6b77:	lea    0x240(%rsp),%r9
    6b7f:	mov    0x4b0(%rsp),%rax
    6b87:	mov    %rax,0x240(%rsp)
    6b8f:	mov    $0x1,%r8d
    6b95:	mov    0x548(%rsp),%rcx
    6b9d:	mov    %rcx,%rsi
    6ba0:	call   6ba5 <botlish_fn_19+0x52bd>
			6ba1: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6ba5:	jmp    6cbe <botlish_fn_19+0x53d6>
    6baa:	mov    0x4a0(%rsp),%rdi
    6bb2:	call   6bb7 <botlish_fn_19+0x52cf>
			6bb3: R_X86_64_PLT32	botlish_fn_16-0x4
    6bb7:	mov    0x4a0(%rsp),%rdi
    6bbf:	mov    0x10(%rdi),%r8
    6bc3:	mov    0x1d8(%r8),%rdx
    6bca:	lea    0x220(%rsp),%r9
    6bd2:	mov    0x540(%rsp),%rsi
    6bda:	mov    %rsi,0x220(%rsp)
    6be2:	mov    %rax,0x228(%rsp)
    6bea:	mov    $0x6,%ecx
    6bef:	mov    $0x2,%r8d
    6bf5:	mov    %rcx,%rsi
    6bf8:	call   6bfd <botlish_fn_19+0x5315>
			6bf9: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6bfd:	jmp    6cbe <botlish_fn_19+0x53d6>
    6c02:	mov    %rbx,%rsi
    6c05:	mov    0x4a0(%rsp),%rdi
    6c0d:	call   6c12 <botlish_fn_19+0x532a>
			6c0e: R_X86_64_PLT32	botlish_fn_16-0x4
    6c12:	mov    0x4a0(%rsp),%rdi
    6c1a:	mov    0x10(%rdi),%rcx
    6c1e:	mov    0x1d8(%rcx),%rdx
    6c25:	lea    0x210(%rsp),%r9
    6c2d:	mov    0x540(%rsp),%rsi
    6c35:	mov    %rsi,0x210(%rsp)
    6c3d:	mov    %rax,0x218(%rsp)
    6c45:	mov    $0x6,%ecx
    6c4a:	mov    $0x2,%r8d
    6c50:	mov    %rcx,%rsi
    6c53:	call   6c58 <botlish_fn_19+0x5370>
			6c54: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6c58:	jmp    6cbe <botlish_fn_19+0x53d6>
    6c5d:	mov    %rsi,%rax
    6c60:	sar    $1,%rax
    6c63:	cmp    $0x3,%rax
    6c67:	cmp    $0x5,%rax
    6c6b:	mov    0x4a0(%rsp),%rdi
    6c73:	call   6c78 <botlish_fn_19+0x5390>
			6c74: R_X86_64_PLT32	botlish_fn_16-0x4
    6c78:	mov    0x4a0(%rsp),%rdi
    6c80:	mov    0x10(%rdi),%rcx
    6c84:	mov    0x1d8(%rcx),%rdx
    6c8b:	lea    0x200(%rsp),%r9
    6c93:	mov    0x540(%rsp),%rsi
    6c9b:	mov    %rsi,0x200(%rsp)
    6ca3:	mov    %rax,0x208(%rsp)
    6cab:	mov    $0x6,%ecx
    6cb0:	mov    $0x2,%r8d
    6cb6:	mov    %rcx,%rsi
    6cb9:	call   6cbe <botlish_fn_19+0x53d6>
			6cba: R_X86_64_PLT32	rt_fail_declared_payload-0x4
    6cbe:	mov    0x4a0(%rsp),%rdi
    6cc6:	call   6ccb <botlish_fn_19+0x53e3>
			6cc7: R_X86_64_PLT32	rt_co_failed-0x4
    6ccb:	mov    %rax,0x80(%rsp)
    6cd3:	mov    %rax,%rsi
    6cd6:	mov    0x4a0(%rsp),%rdi
    6cde:	call   6ce3 <botlish_fn_19+0x53fb>
			6cdf: R_X86_64_PLT32	rt_co_resume0-0x4
    6ce3:	test   %rax,%rax
    6ce6:	je     6d08 <botlish_fn_19+0x5420>
    6cec:	mov    0x4a0(%rsp),%rdi
    6cf4:	mov    0x10(%rdi),%rax
    6cf8:	mov    0x48(%rax),%rsi
    6cfc:	mov    0x1b0(%rax),%rdx
    6d03:	call   6d08 <botlish_fn_19+0x5420>
			6d04: R_X86_64_PLT32	rt_raise-0x4
    6d08:	mov    0x4a0(%rsp),%rdi
    6d10:	call   6d15 <botlish_fn_19+0x542d>
			6d11: R_X86_64_PLT32	rt_declared_error-0x4
    6d15:	cmp    $0x6,%rax
    6d19:	je     6d30 <botlish_fn_19+0x5448>
    6d1f:	mov    0x4a0(%rsp),%rdi
    6d27:	call   6d2c <botlish_fn_19+0x5444>
			6d28: R_X86_64_PLT32	rt_declared_error-0x4
    6d2c:	cmp    $0x7,%rax
    6d30:	xor    %rax,%rax
    6d33:	mov    0x580(%rsp),%rbx
    6d3b:	mov    0x588(%rsp),%r12
    6d43:	mov    0x590(%rsp),%r13
    6d4b:	mov    0x598(%rsp),%r14
    6d53:	mov    0x5a0(%rsp),%r15
    6d5b:	add    $0x5b0,%rsp
    6d62:	mov    %rbp,%rsp
    6d65:	pop    %rbp
    6d66:	ret
    6d67:	mov    $0x6,%r12d
    6d6d:	movq   $0x6,0x78(%rsp)
    6d76:	mov    0x560(%rsp),%rax
    6d7e:	mov    0x10(%rax),%rax
    6d82:	mov    0x10(%rax),%rax
    6d86:	mov    %rax,0x8(%rsp)
    6d8b:	mov    0x560(%rsp),%rcx
    6d93:	mov    0x10(%rcx),%rcx
    6d97:	mov    (%rcx),%rdx
    6d9a:	mov    %rdx,(%rsp)
    6d9e:	lea    0x148(%rsp),%rcx
    6da6:	mov    %rax,0x148(%rsp)
    6dae:	mov    %rdx,0x150(%rsp)
    6db6:	xor    %rsi,%rsi
    6db9:	mov    $0x2,%edx
    6dbe:	mov    0x4a0(%rsp),%rdi
    6dc6:	call   6dcb <botlish_fn_19+0x54e3>
			6dc7: R_X86_64_PLT32	rt_struct_new-0x4
    6dcb:	mov    0x580(%rsp),%rbx
    6dd3:	mov    0x588(%rsp),%r12
    6ddb:	mov    0x590(%rsp),%r13
    6de3:	mov    0x598(%rsp),%r14
    6deb:	mov    0x5a0(%rsp),%r15
    6df3:	add    $0x5b0,%rsp
    6dfa:	mov    %rbp,%rsp
    6dfd:	pop    %rbp
    6dfe:	ret
    6dff:	mov    %r12,%rcx
    6e02:	mov    0x570(%rsp),%rdx
    6e0a:	mov    %rbx,%rsi
    6e0d:	mov    0x4a0(%rsp),%rdi
    6e15:	call   6e1a <botlish_fn_19+0x5532>
			6e16: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6e1a:	mov    %rbx,0x560(%rsp)
    6e22:	jmp    1f6d <botlish_fn_19+0x685>
    6e27:	mov    %rbx,%rcx
    6e2a:	mov    0x548(%rsp),%rdx
    6e32:	mov    0x560(%rsp),%rsi
    6e3a:	mov    0x4a0(%rsp),%rdi
    6e42:	call   6e47 <botlish_fn_19+0x555f>
			6e43: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6e47:	jmp    35f1 <botlish_fn_19+0x1d09>
    6e4c:	mov    $0x1,%edx
    6e51:	mov    %r15,%rcx
    6e54:	mov    0x560(%rsp),%rsi
    6e5c:	mov    0x4a0(%rsp),%rdi
    6e64:	call   6e69 <botlish_fn_19+0x5581>
			6e65: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6e69:	jmp    3685 <botlish_fn_19+0x1d9d>
    6e6e:	mov    0x528(%rsp),%rcx
    6e76:	mov    0x570(%rsp),%rdx
    6e7e:	mov    0x560(%rsp),%rsi
    6e86:	mov    0x4a0(%rsp),%rdi
    6e8e:	call   6e93 <botlish_fn_19+0x55ab>
			6e8f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6e93:	jmp    3ad3 <botlish_fn_19+0x21eb>
    6e98:	mov    %rbx,%rcx
    6e9b:	mov    0x548(%rsp),%rdx
    6ea3:	mov    0x560(%rsp),%rsi
    6eab:	mov    0x4a0(%rsp),%rdi
    6eb3:	call   6eb8 <botlish_fn_19+0x55d0>
			6eb4: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6eb8:	jmp    5135 <botlish_fn_19+0x384d>
    6ebd:	mov    $0x1,%edx
    6ec2:	mov    0x560(%rsp),%rsi
    6eca:	mov    0x4a0(%rsp),%rdi
    6ed2:	call   6ed7 <botlish_fn_19+0x55ef>
			6ed3: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6ed7:	jmp    531f <botlish_fn_19+0x3a37>
    6edc:	mov    0x528(%rsp),%rcx
    6ee4:	mov    0x570(%rsp),%rdx
    6eec:	mov    0x560(%rsp),%rsi
    6ef4:	mov    0x4a0(%rsp),%rdi
    6efc:	call   6f01 <botlish_fn_19+0x5619>
			6efd: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6f01:	jmp    5789 <botlish_fn_19+0x3ea1>
    6f06:	mov    $0x5,%edx
    6f0b:	mov    0x560(%rsp),%rsi
    6f13:	mov    0x4a0(%rsp),%rdi
    6f1b:	call   6f20 <botlish_fn_19+0x5638>
			6f1c: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6f20:	jmp    6137 <botlish_fn_19+0x484f>
    6f25:	mov    $0x1,%edx
    6f2a:	mov    0x560(%rsp),%rsi
    6f32:	mov    0x4a0(%rsp),%rdi
    6f3a:	call   6f3f <botlish_fn_19+0x5657>
			6f3b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6f3f:	jmp    6230 <botlish_fn_19+0x4948>
    6f44:	mov    0x528(%rsp),%rcx
    6f4c:	mov    0x570(%rsp),%rdx
    6f54:	mov    0x560(%rsp),%rsi
    6f5c:	mov    0x4a0(%rsp),%rdi
    6f64:	call   6f69 <botlish_fn_19+0x5681>
			6f65: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    6f69:	jmp    6694 <botlish_fn_19+0x4dac>
    6f6e:	add    %al,(%rax)
    6f70:	(bad)
    6f71:	add    %al,(%rax)
    6f73:	add    %al,(%rax)
    6f75:	add    %al,(%rax)
	...

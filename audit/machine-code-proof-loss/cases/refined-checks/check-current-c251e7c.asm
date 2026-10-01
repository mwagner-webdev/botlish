; extracted from: git show c251e7c:audit/native-scalar-asm/bench/refined-checks.asm
; compiler revision (that regeneration's README.md): 795eaefa12c2e8dfca8b5a25955026a30058e544

0000000000002025 <botlish_fn_23: check<int, int, str, str>>:
    2025:	push   rbp
    2026:	mov    rbp,rsp
    2029:	sub    rsp,0x50
    202d:	mov    QWORD PTR [rsp+0x20],rbx
    2032:	mov    QWORD PTR [rsp+0x28],r12
    2037:	mov    QWORD PTR [rsp+0x30],r13
    203c:	mov    QWORD PTR [rsp+0x38],r14
    2041:	mov    QWORD PTR [rsp+0x40],r15
    2046:	mov    r14,rdi
    2049:	mov    QWORD PTR [rsp+0x18],0x0
    2052:	mov    QWORD PTR [rsp],rdx
    2056:	mov    QWORD PTR [rsp+0x8],rcx
    205b:	mov    QWORD PTR [rsp+0x10],r8
    2060:	mov    r13,r8
    2063:	sar    rsi,1
    2066:	mov    r12,rsi
    2069:	mov    r15,rdx
    206c:	test   r12,r12
    206f:	jle    2131 <botlish_fn_23+0x10c>
    2075:	mov    rbx,rcx
    2078:	mov    rsi,rbx
    207b:	mov    rdi,r14
    207e:	call   2083 <botlish_fn_23+0x5e>
			207f: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
    2083:	test   rax,rax
    2086:	jne    20b1 <botlish_fn_23+0x8c>
    208c:	xor    rax,rax
    208f:	mov    rbx,QWORD PTR [rsp+0x20]
    2094:	mov    r12,QWORD PTR [rsp+0x28]
    2099:	mov    r13,QWORD PTR [rsp+0x30]
    209e:	mov    r14,QWORD PTR [rsp+0x38]
    20a3:	mov    r15,QWORD PTR [rsp+0x40]
    20a8:	add    rsp,0x50
    20ac:	mov    rsp,rbp
    20af:	pop    rbp
    20b0:	ret
    20b1:	cmp    rax,0x6
    20b5:	je     20d1 <botlish_fn_23+0xac>
    20bb:	mov    edx,0x1
    20c0:	mov    QWORD PTR [rsp+0x18],0x1
    20c9:	mov    rsi,r15
    20cc:	jmp    20e2 <botlish_fn_23+0xbd>
    20d1:	mov    edx,0x3
    20d6:	mov    QWORD PTR [rsp+0x18],0x3
    20df:	mov    rsi,r15
    20e2:	mov    rax,rsi
    20e5:	and    rax,rdx
    20e8:	test   rax,0x1
    20ee:	je     2109 <botlish_fn_23+0xe4>
    20f4:	lea    rcx,[rdx-0x1]
    20f8:	mov    rax,rsi
    20fb:	add    rax,rcx
    20fe:	seto   cl
    2101:	test   cl,cl
    2103:	je     2111 <botlish_fn_23+0xec>
    2109:	mov    rdi,r14
    210c:	call   2111 <botlish_fn_23+0xec>
			210d: R_X86_64_PLT32	rt_int_add-0x4
    2111:	mov    QWORD PTR [rsp],rax
    2115:	mov    QWORD PTR [rsp+0x8],rbx
    211a:	mov    r8,r13
    211d:	mov    QWORD PTR [rsp+0x10],r8
    2122:	sub    r12,0x1
    2126:	mov    rcx,rbx
    2129:	mov    r15,rax
    212c:	jmp    206c <botlish_fn_23+0x47>
    2131:	mov    rax,r15
    2134:	mov    rbx,QWORD PTR [rsp+0x20]
    2139:	mov    r12,QWORD PTR [rsp+0x28]
    213e:	mov    r13,QWORD PTR [rsp+0x30]
    2143:	mov    r14,QWORD PTR [rsp+0x38]
    2148:	mov    r15,QWORD PTR [rsp+0x40]
    214d:	add    rsp,0x50
    2151:	mov    rsp,rbp
    2154:	pop    rbp
    2155:	ret

0000000000002156 <botlish_entry_23: check<int, int, str, str>>:
    2156:	push   rbp
    2157:	mov    rbp,rsp
    215a:	mov    rsi,QWORD PTR [rdx]
    215d:	mov    r9,QWORD PTR [rdx+0x8]
    2161:	mov    rcx,QWORD PTR [rdx+0x10]
    2165:	mov    r8,QWORD PTR [rdx+0x18]
    2169:	mov    rdx,r9
    216c:	call   2171 <botlish_entry_23+0x1b>
			216d: R_X86_64_PLT32	botlish_fn_23-0x4 ; check<int, int, str, str>
    2171:	mov    rsp,rbp
    2174:	pop    rbp
    2175:	ret

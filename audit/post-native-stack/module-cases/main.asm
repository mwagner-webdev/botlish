
/mnt/c/Users/MarkusWagner/dev/botlish/audit/post-native-stack/module-cases/main.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x70
   8:	mov    QWORD PTR [rsp+0x50],rbx
   d:	mov    QWORD PTR [rsp+0x58],r12
  12:	mov    QWORD PTR [rsp+0x60],r13
  17:	mov    QWORD PTR [rsp+0x68],r14
  1c:	mov    rbx,rdi
  1f:	mov    QWORD PTR [rsp+0x18],0x0
  28:	mov    QWORD PTR [rsp],0xf
  30:	mov    QWORD PTR [rsp+0x8],0x15
  39:	mov    QWORD PTR [rsp+0x10],0x29
  42:	lea    rdx,[rsp+0x20]
  47:	mov    QWORD PTR [rsp+0x20],0x15
  50:	mov    QWORD PTR [rsp+0x28],0x29
  59:	mov    esi,0x2
  5e:	mov    rdi,rbx
  61:	call   66 <botlish_fn_0+0x66>
			62: R_X86_64_PLT32	rt_list_new-0x4
  66:	test   rax,rax
  69:	je     120 <botlish_fn_0+0x120>
  6f:	mov    QWORD PTR [rsp+0x8],rax
  74:	mov    r12,rax
  77:	mov    esi,0x3
  7c:	mov    QWORD PTR [rsp+0x10],0x3
  85:	mov    rdi,rbx
  88:	call   8d <botlish_fn_0+0x8d>
			89: R_X86_64_PLT32	botlish_fn_1-0x4
  8d:	test   rax,rax
  90:	je     120 <botlish_fn_0+0x120>
  96:	mov    QWORD PTR [rsp+0x10],rax
  9b:	mov    r13,rax
  9e:	mov    esi,0x3
  a3:	mov    QWORD PTR [rsp+0x18],0x3
  ac:	mov    edx,0xf
  b1:	mov    rdi,rbx
  b4:	call   b9 <botlish_fn_0+0xb9>
			b5: R_X86_64_PLT32	botlish_fn_2-0x4
  b9:	test   rax,rax
  bc:	je     120 <botlish_fn_0+0x120>
  c2:	mov    QWORD PTR [rsp],rax
  c6:	mov    r14,rax
  c9:	mov    esi,0x3
  ce:	mov    QWORD PTR [rsp+0x18],0x3
  d7:	mov    rdx,r12
  da:	mov    rdi,rbx
  dd:	call   e2 <botlish_fn_0+0xe2>
			de: R_X86_64_PLT32	botlish_fn_3-0x4
  e2:	test   rax,rax
  e5:	je     120 <botlish_fn_0+0x120>
  eb:	mov    QWORD PTR [rsp+0x8],rax
  f0:	lea    rdx,[rsp+0x30]
  f5:	mov    rcx,r13
  f8:	mov    QWORD PTR [rsp+0x30],rcx
  fd:	mov    rcx,r14
 100:	mov    QWORD PTR [rsp+0x38],rcx
 105:	mov    QWORD PTR [rsp+0x40],rax
 10a:	mov    esi,0x3
 10f:	mov    rdi,rbx
 112:	call   117 <botlish_fn_0+0x117>
			113: R_X86_64_PLT32	rt_list_new-0x4
 117:	test   rax,rax
 11a:	jne    140 <botlish_fn_0+0x140>
 120:	xor    rax,rax
 123:	mov    rbx,QWORD PTR [rsp+0x50]
 128:	mov    r12,QWORD PTR [rsp+0x58]
 12d:	mov    r13,QWORD PTR [rsp+0x60]
 132:	mov    r14,QWORD PTR [rsp+0x68]
 137:	add    rsp,0x70
 13b:	mov    rsp,rbp
 13e:	pop    rbp
 13f:	ret
 140:	mov    rbx,QWORD PTR [rsp+0x50]
 145:	mov    r12,QWORD PTR [rsp+0x58]
 14a:	mov    r13,QWORD PTR [rsp+0x60]
 14f:	mov    r14,QWORD PTR [rsp+0x68]
 154:	add    rsp,0x70
 158:	mov    rsp,rbp
 15b:	pop    rbp
 15c:	ret

000000000000015d <botlish_entry_0>:
 15d:	push   rbp
 15e:	mov    rbp,rsp
 161:	call   166 <botlish_entry_0+0x9>
			162: R_X86_64_PLT32	botlish_fn_0-0x4
 166:	mov    rsp,rbp
 169:	pop    rbp
 16a:	ret

000000000000016b <botlish_fn_1>:
 16b:	push   rbp
 16c:	mov    rbp,rsp
 16f:	sar    rsi,1
 172:	lea    rax,[rsi+0x1]
 176:	shl    rax,1
 179:	or     rax,0x1
 17d:	mov    rsp,rbp
 180:	pop    rbp
 181:	ret

0000000000000182 <botlish_entry_1>:
 182:	push   rbp
 183:	mov    rbp,rsp
 186:	mov    rsi,QWORD PTR [rdx]
 189:	call   18e <botlish_entry_1+0xc>
			18a: R_X86_64_PLT32	botlish_fn_1-0x4
 18e:	mov    rsp,rbp
 191:	pop    rbp
 192:	ret

0000000000000193 <botlish_fn_2>:
 193:	push   rbp
 194:	mov    rbp,rsp
 197:	sub    rsp,0x20
 19b:	mov    QWORD PTR [rsp+0x10],rbx
 1a0:	mov    QWORD PTR [rsp],rsi
 1a4:	mov    QWORD PTR [rsp+0x8],rdx
 1a9:	mov    r8d,0x1
 1af:	test   rsi,0x1
 1b6:	jne    1d6 <botlish_fn_2+0x43>
 1bc:	xor    r8d,r8d
 1bf:	test   rsi,0x7
 1c6:	jne    1d6 <botlish_fn_2+0x43>
 1cc:	movzx  rax,BYTE PTR [rsi]
 1d0:	cmp    al,0x1
 1d2:	sete   r8b
 1d6:	test   r8b,r8b
 1d9:	jne    202 <botlish_fn_2+0x6f>
 1df:	mov    rax,QWORD PTR [rdi+0x10]
 1e3:	mov    rcx,QWORD PTR [rax]
 1e6:	xor    rbx,rbx
 1e9:	mov    rdx,rbx
 1ec:	call   1f1 <botlish_fn_2+0x5e>
			1ed: R_X86_64_PLT32	rt_type_error-0x4
 1f1:	mov    rax,rbx
 1f4:	mov    rbx,QWORD PTR [rsp+0x10]
 1f9:	add    rsp,0x20
 1fd:	mov    rsp,rbp
 200:	pop    rbp
 201:	ret
 202:	mov    rax,rsi
 205:	and    rax,rdx
 208:	test   rax,0x1
 20e:	je     229 <botlish_fn_2+0x96>
 214:	lea    rcx,[rdx-0x1]
 218:	mov    rax,rsi
 21b:	add    rax,rcx
 21e:	seto   cl
 221:	test   cl,cl
 223:	je     22e <botlish_fn_2+0x9b>
 229:	call   22e <botlish_fn_2+0x9b>
			22a: R_X86_64_PLT32	rt_int_add-0x4
 22e:	mov    rbx,QWORD PTR [rsp+0x10]
 233:	add    rsp,0x20
 237:	mov    rsp,rbp
 23a:	pop    rbp
 23b:	ret

000000000000023c <botlish_entry_2>:
 23c:	push   rbp
 23d:	mov    rbp,rsp
 240:	mov    rsi,QWORD PTR [rdx]
 243:	mov    rdx,QWORD PTR [rdx+0x8]
 247:	call   24c <botlish_entry_2+0x10>
			248: R_X86_64_PLT32	botlish_fn_2-0x4
 24c:	mov    rsp,rbp
 24f:	pop    rbp
 250:	ret

0000000000000251 <botlish_fn_3>:
 251:	push   rbp
 252:	mov    rbp,rsp
 255:	mov    r8d,0x1
 25b:	test   rsi,0x1
 262:	jne    282 <botlish_fn_3+0x31>
 268:	xor    r8d,r8d
 26b:	test   rsi,0x7
 272:	jne    282 <botlish_fn_3+0x31>
 278:	movzx  rax,BYTE PTR [rsi]
 27c:	cmp    al,0x1
 27e:	sete   r8b
 282:	test   r8b,r8b
 285:	jne    2a0 <botlish_fn_3+0x4f>
 28b:	mov    rax,QWORD PTR [rdi+0x10]
 28f:	mov    rcx,QWORD PTR [rax+0x8]
 293:	xor    rdx,rdx
 296:	call   29b <botlish_fn_3+0x4a>
			297: R_X86_64_PLT32	rt_type_error-0x4
 29b:	jmp    2e5 <botlish_fn_3+0x94>
 2a0:	test   rsi,0x1
 2a7:	jne    2bb <botlish_fn_3+0x6a>
 2ad:	mov    rax,rdx
 2b0:	mov    rdx,rsi
 2b3:	mov    rsi,rax
 2b6:	jmp    2d7 <botlish_fn_3+0x86>
 2bb:	mov    rcx,QWORD PTR [rdx+0x8]
 2bf:	mov    r8,rdx
 2c2:	mov    rax,rsi
 2c5:	sar    rax,1
 2c8:	mov    rdx,rsi
 2cb:	cmp    rax,rcx
 2ce:	jb     2f2 <botlish_fn_3+0xa1>
 2d4:	mov    rsi,r8
 2d7:	call   2dc <botlish_fn_3+0x8b>
			2d8: R_X86_64_PLT32	rt_list_get-0x4
 2dc:	test   rax,rax
 2df:	jne    2fd <botlish_fn_3+0xac>
 2e5:	xor    rax,rax
 2e8:	mov    rsp,rbp
 2eb:	pop    rbp
 2ec:	ret
 2ed:	jmp    2fd <botlish_fn_3+0xac>
 2f2:	mov    rsi,r8
 2f5:	mov    rcx,QWORD PTR [rsi+0x10]
 2f9:	mov    rax,QWORD PTR [rcx+rax*8]
 2fd:	mov    rsp,rbp
 300:	pop    rbp
 301:	ret

0000000000000302 <botlish_entry_3>:
 302:	push   rbp
 303:	mov    rbp,rsp
 306:	mov    rsi,QWORD PTR [rdx]
 309:	mov    rdx,QWORD PTR [rdx+0x8]
 30d:	call   312 <botlish_entry_3+0x10>
			30e: R_X86_64_PLT32	botlish_fn_3-0x4
 312:	mov    rsp,rbp
 315:	pop    rbp
 316:	ret
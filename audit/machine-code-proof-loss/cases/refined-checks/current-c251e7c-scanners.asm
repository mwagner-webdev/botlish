; extracted from: git show c251e7c:audit/native-scalar-asm/bench/refined-checks.asm
; compiler revision (that regeneration's README.md): 795eaefa12c2e8dfca8b5a25955026a30058e544

0000000000000d01 <botlish_fn_10: char_at<generic>>:
     d01:	push   rbp
     d02:	mov    rbp,rsp
     d05:	sub    rsp,0x50
     d09:	mov    QWORD PTR [rsp+0x20],rbx
     d0e:	mov    QWORD PTR [rsp+0x28],r12
     d13:	mov    QWORD PTR [rsp+0x30],r13
     d18:	mov    QWORD PTR [rsp+0x38],r14
     d1d:	mov    QWORD PTR [rsp+0x40],r15
     d22:	mov    r12,rdi
     d25:	mov    r15,rcx
     d28:	mov    QWORD PTR [rsp],rsi
     d2c:	mov    QWORD PTR [rsp+0x8],rdx
     d31:	mov    r13,rdx
     d34:	mov    QWORD PTR [rsp+0x10],0x3
     d3d:	test   rsi,0x1
     d44:	jne    d52 <botlish_fn_10+0x51>
     d4a:	mov    rbx,rsi
     d4d:	jmp    d72 <botlish_fn_10+0x71>
     d52:	mov    rax,rsi
     d55:	add    rax,0x2
     d59:	mov    rbx,rsi
     d5c:	seto   cl
     d5f:	test   cl,cl
     d61:	jne    d72 <botlish_fn_10+0x71>
     d67:	mov    rdi,r12
     d6a:	mov    r14,rax
     d6d:	jmp    d88 <botlish_fn_10+0x87>
     d72:	mov    edx,0x3
     d77:	mov    rsi,rbx
     d7a:	mov    rdi,r12
     d7d:	call   d82 <botlish_fn_10+0x81>
			d7e: R_X86_64_PLT32	rt_int_add-0x4
     d82:	mov    r14,rax
     d85:	mov    rdi,r12
     d88:	mov    rcx,r14
     d8b:	mov    rdx,rbx
     d8e:	mov    rsi,r13
     d91:	call   d96 <botlish_fn_10+0x95>
			d92: R_X86_64_PLT32	rt_str_region_check-0x4
     d96:	test   rax,rax
     d99:	jne    dc4 <botlish_fn_10+0xc3>
     d9f:	xor    rax,rax
     da2:	mov    rbx,QWORD PTR [rsp+0x20]
     da7:	mov    r12,QWORD PTR [rsp+0x28]
     dac:	mov    r13,QWORD PTR [rsp+0x30]
     db1:	mov    r14,QWORD PTR [rsp+0x38]
     db6:	mov    r15,QWORD PTR [rsp+0x40]
     dbb:	add    rsp,0x50
     dbf:	mov    rsp,rbp
     dc2:	pop    rbp
     dc3:	ret
     dc4:	mov    rcx,r15
     dc7:	mov    QWORD PTR [rcx],rbx
     dca:	mov    rax,r14
     dcd:	mov    QWORD PTR [rcx+0x8],rax
     dd1:	mov    rax,r13
     dd4:	mov    rbx,QWORD PTR [rsp+0x20]
     dd9:	mov    r12,QWORD PTR [rsp+0x28]
     dde:	mov    r13,QWORD PTR [rsp+0x30]
     de3:	mov    r14,QWORD PTR [rsp+0x38]
     de8:	mov    r15,QWORD PTR [rsp+0x40]
     ded:	add    rsp,0x50
     df1:	mov    rsp,rbp
     df4:	pop    rbp
     df5:	ret

0000000000000df6 <botlish_entry_10: char_at<generic>>:
     df6:	push   rbp
     df7:	mov    rbp,rsp
     dfa:	ud2

0000000000000dfc <botlish_fn_11: char_at<generic>>:
     dfc:	push   rbp
     dfd:	mov    rbp,rsp
     e00:	sub    rsp,0x40
     e04:	mov    QWORD PTR [rsp+0x20],rbx
     e09:	mov    QWORD PTR [rsp+0x28],r12
     e0e:	mov    QWORD PTR [rsp+0x30],r13
     e13:	mov    r12,rdi
     e16:	mov    QWORD PTR [rsp],rsi
     e1a:	mov    QWORD PTR [rsp+0x8],rdx
     e1f:	mov    r13,rdx
     e22:	mov    QWORD PTR [rsp+0x10],0x3
     e2b:	test   rsi,0x1
     e32:	jne    e40 <botlish_fn_11+0x44>
     e38:	mov    rbx,rsi
     e3b:	jmp    e55 <botlish_fn_11+0x59>
     e40:	mov    rcx,rsi
     e43:	add    rcx,0x2
     e47:	mov    rbx,rsi
     e4a:	seto   al
     e4d:	test   al,al
     e4f:	je     e68 <botlish_fn_11+0x6c>
     e55:	mov    edx,0x3
     e5a:	mov    rsi,rbx
     e5d:	mov    rdi,r12
     e60:	call   e65 <botlish_fn_11+0x69>
			e61: R_X86_64_PLT32	rt_int_add-0x4
     e65:	mov    rcx,rax
     e68:	mov    QWORD PTR [rsp+0x10],rcx
     e6d:	mov    rdx,rbx
     e70:	mov    rsi,r13
     e73:	mov    rdi,r12
     e76:	call   e7b <botlish_fn_11+0x7f>
			e77: R_X86_64_PLT32	rt_substr-0x4
     e7b:	test   rax,rax
     e7e:	jne    e9f <botlish_fn_11+0xa3>
     e84:	xor    rax,rax
     e87:	mov    rbx,QWORD PTR [rsp+0x20]
     e8c:	mov    r12,QWORD PTR [rsp+0x28]
     e91:	mov    r13,QWORD PTR [rsp+0x30]
     e96:	add    rsp,0x40
     e9a:	mov    rsp,rbp
     e9d:	pop    rbp
     e9e:	ret
     e9f:	mov    rbx,QWORD PTR [rsp+0x20]
     ea4:	mov    r12,QWORD PTR [rsp+0x28]
     ea9:	mov    r13,QWORD PTR [rsp+0x30]
     eae:	add    rsp,0x40
     eb2:	mov    rsp,rbp
     eb5:	pop    rbp
     eb6:	ret

0000000000000eb7 <botlish_entry_11: char_at<generic>>:
     eb7:	push   rbp
     eb8:	mov    rbp,rsp
     ebb:	mov    rsi,QWORD PTR [rdx]
     ebe:	mov    rdx,QWORD PTR [rdx+0x8]
     ec2:	call   ec7 <botlish_entry_11+0x10>
			ec3: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
     ec7:	mov    rsp,rbp
     eca:	pop    rbp
     ecb:	ret

0000000000000ecc <botlish_fn_12: local_char?<generic>>:
     ecc:	push   rbp
     ecd:	mov    rbp,rsp
     ed0:	sub    rsp,0x10
     ed4:	mov    QWORD PTR [rsp],rbx
     ed8:	mov    QWORD PTR [rsp+0x8],r12
     edd:	xor    r8d,r8d
     ee0:	test   rsi,0x7
     ee7:	jne    ef7 <botlish_fn_12+0x2b>
     eed:	movzx  rax,BYTE PTR [rsi]
     ef1:	cmp    al,0x2
     ef3:	sete   r8b
     ef7:	test   r8b,r8b
     efa:	jne    f1a <botlish_fn_12+0x4e>
     f00:	mov    rax,QWORD PTR [rdi+0x10]
     f04:	mov    rcx,QWORD PTR [rax+0xd8]
     f0b:	mov    edx,0x1
     f10:	call   f15 <botlish_fn_12+0x49>
			f11: R_X86_64_PLT32	rt_type_error-0x4
     f15:	jmp    f2e <botlish_fn_12+0x62>
     f1a:	mov    rbx,rsi
     f1d:	mov    r12,rdi
     f20:	call   f25 <botlish_fn_12+0x59>
			f21: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     f25:	test   rax,rax
     f28:	jne    f43 <botlish_fn_12+0x77>
     f2e:	xor    rax,rax
     f31:	mov    rbx,QWORD PTR [rsp]
     f35:	mov    r12,QWORD PTR [rsp+0x8]
     f3a:	add    rsp,0x10
     f3e:	mov    rsp,rbp
     f41:	pop    rbp
     f42:	ret
     f43:	cmp    rax,0x6
     f47:	je     f7d <botlish_fn_12+0xb1>
     f4d:	mov    rdi,r12
     f50:	mov    rax,QWORD PTR [rdi+0x30]
     f54:	mov    rsi,QWORD PTR [rax]
     f57:	mov    rdx,rbx
     f5a:	call   f5f <botlish_fn_12+0x93>
			f5b: R_X86_64_PLT32	rt_set_contains-0x4
     f5f:	cmp    rax,0x6
     f63:	je     f73 <botlish_fn_12+0xa7>
     f69:	mov    eax,0x2
     f6e:	jmp    f82 <botlish_fn_12+0xb6>
     f73:	mov    eax,0x6
     f78:	jmp    f82 <botlish_fn_12+0xb6>
     f7d:	mov    eax,0x6
     f82:	mov    rbx,QWORD PTR [rsp]
     f86:	mov    r12,QWORD PTR [rsp+0x8]
     f8b:	add    rsp,0x10
     f8f:	mov    rsp,rbp
     f92:	pop    rbp
     f93:	ret

0000000000000f94 <botlish_entry_12: local_char?<generic>>:
     f94:	push   rbp
     f95:	mov    rbp,rsp
     f98:	mov    rsi,QWORD PTR [rdx]
     f9b:	call   fa0 <botlish_entry_12+0xc>
			f9c: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<generic>
     fa0:	mov    rsp,rbp
     fa3:	pop    rbp
     fa4:	ret
     fa5:	add    BYTE PTR [rax],al
	...

0000000000000fa8 <botlish_fn_13: scan_while<generic>>:
     fa8:	push   rbp
     fa9:	mov    rbp,rsp
     fac:	sub    rsp,0x60
     fb0:	mov    QWORD PTR [rsp+0x30],rbx
     fb5:	mov    QWORD PTR [rsp+0x38],r12
     fba:	mov    QWORD PTR [rsp+0x40],r13
     fbf:	mov    QWORD PTR [rsp+0x48],r14
     fc4:	mov    QWORD PTR [rsp+0x50],r15
     fc9:	mov    rbx,rcx
     fcc:	mov    r14,rdi
     fcf:	mov    QWORD PTR [rsp+0x20],0x0
     fd8:	mov    QWORD PTR [rsp],rdx
     fdc:	mov    r13,rdx
     fdf:	mov    QWORD PTR [rsp+0x8],rcx
     fe4:	mov    QWORD PTR [rsp+0x10],r8
     fe9:	mov    r12,r8
     fec:	mov    QWORD PTR [rsp+0x18],rsi
     ff1:	mov    rax,rsi
     ff4:	mov    rcx,rbx
     ff7:	mov    r15,rsi
     ffa:	mov    rcx,rbx
     ffd:	and    rax,rcx
    1000:	test   rax,0x1
    1006:	jne    102f <botlish_fn_13+0x87>
    100c:	mov    rdx,rbx
    100f:	mov    rsi,r15
    1012:	mov    rdi,r14
    1015:	call   101a <botlish_fn_13+0x72>
			1016: R_X86_64_PLT32	rt_int_cmp-0x4
    101a:	mov    ecx,0x2
    101f:	test   rax,rax
    1022:	cmovl  rcx,QWORD PTR [rip+0x12e]        # 1158 <botlish_fn_13+0x1b0>
    102a:	jmp    1045 <botlish_fn_13+0x9d>
    102f:	mov    ecx,0x2
    1034:	mov    rax,r15
    1037:	mov    rdx,rbx
    103a:	cmp    rax,rdx
    103d:	cmovl  rcx,QWORD PTR [rip+0x113]        # 1158 <botlish_fn_13+0x1b0>
    1045:	cmp    rcx,0x6
    1049:	je     1074 <botlish_fn_13+0xcc>
    104f:	mov    rax,rbx
    1052:	mov    rbx,QWORD PTR [rsp+0x30]
    1057:	mov    r12,QWORD PTR [rsp+0x38]
    105c:	mov    r13,QWORD PTR [rsp+0x40]
    1061:	mov    r14,QWORD PTR [rsp+0x48]
    1066:	mov    r15,QWORD PTR [rsp+0x50]
    106b:	add    rsp,0x60
    106f:	mov    rsp,rbp
    1072:	pop    rbp
    1073:	ret
    1074:	mov    rdx,r12
    1077:	mov    rsi,r15
    107a:	mov    rdi,r14
    107d:	call   1082 <botlish_fn_13+0xda>
			107e: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    1082:	test   rax,rax
    1085:	je     10b3 <botlish_fn_13+0x10b>
    108b:	mov    QWORD PTR [rsp+0x20],rax
    1090:	lea    rcx,[rsp+0x28]
    1095:	mov    QWORD PTR [rsp+0x28],rax
    109a:	mov    edx,0x1
    109f:	mov    rsi,r13
    10a2:	mov    rdi,r14
    10a5:	call   10aa <botlish_fn_13+0x102>
			10a6: R_X86_64_PLT32	rt_call_value-0x4
    10aa:	test   rax,rax
    10ad:	jne    10d8 <botlish_fn_13+0x130>
    10b3:	xor    rax,rax
    10b6:	mov    rbx,QWORD PTR [rsp+0x30]
    10bb:	mov    r12,QWORD PTR [rsp+0x38]
    10c0:	mov    r13,QWORD PTR [rsp+0x40]
    10c5:	mov    r14,QWORD PTR [rsp+0x48]
    10ca:	mov    r15,QWORD PTR [rsp+0x50]
    10cf:	add    rsp,0x60
    10d3:	mov    rsp,rbp
    10d6:	pop    rbp
    10d7:	ret
    10d8:	cmp    rax,0x6
    10dc:	je     1107 <botlish_fn_13+0x15f>
    10e2:	mov    rax,r15
    10e5:	mov    rbx,QWORD PTR [rsp+0x30]
    10ea:	mov    r12,QWORD PTR [rsp+0x38]
    10ef:	mov    r13,QWORD PTR [rsp+0x40]
    10f4:	mov    r14,QWORD PTR [rsp+0x48]
    10f9:	mov    r15,QWORD PTR [rsp+0x50]
    10fe:	add    rsp,0x60
    1102:	mov    rsp,rbp
    1105:	pop    rbp
    1106:	ret
    1107:	mov    QWORD PTR [rsp+0x20],0x3
    1110:	mov    rax,r15
    1113:	test   rax,0x1
    1119:	je     1134 <botlish_fn_13+0x18c>
    111f:	mov    rcx,r15
    1122:	mov    rax,rcx
    1125:	add    rax,0x2
    1129:	seto   cl
    112c:	test   cl,cl
    112e:	je     1144 <botlish_fn_13+0x19c>
    1134:	mov    edx,0x3
    1139:	mov    rsi,r15
    113c:	mov    rdi,r14
    113f:	call   1144 <botlish_fn_13+0x19c>
			1140: R_X86_64_PLT32	rt_int_add-0x4
    1144:	mov    QWORD PTR [rsp+0x18],rax
    1149:	mov    rcx,rbx
    114c:	mov    r15,rax
    114f:	jmp    ffa <botlish_fn_13+0x52>
    1154:	add    BYTE PTR [rax],al
    1156:	add    BYTE PTR [rax],al
    1158:	(bad)
    1159:	add    BYTE PTR [rax],al
    115b:	add    BYTE PTR [rax],al
    115d:	add    BYTE PTR [rax],al
	...

0000000000001160 <botlish_entry_13: scan_while<generic>>:
    1160:	push   rbp
    1161:	mov    rbp,rsp
    1164:	mov    rsi,QWORD PTR [rdx]
    1167:	mov    r9,QWORD PTR [rdx+0x8]
    116b:	mov    rcx,QWORD PTR [rdx+0x10]
    116f:	mov    r8,QWORD PTR [rdx+0x18]
    1173:	mov    rdx,r9
    1176:	call   117b <botlish_entry_13+0x1b>
			1177: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<generic>
    117b:	mov    rsp,rbp
    117e:	pop    rbp
    117f:	ret

0000000000001180 <botlish_fn_14: tld?<generic>>:
    1180:	push   rbp
    1181:	mov    rbp,rsp
    1184:	sub    rsp,0x40
    1188:	mov    QWORD PTR [rsp+0x20],rbx
    118d:	mov    QWORD PTR [rsp+0x28],r12
    1192:	mov    QWORD PTR [rsp+0x30],r13
    1197:	mov    QWORD PTR [rsp+0x38],r14
    119c:	mov    QWORD PTR [rsp],rsi
    11a0:	mov    r8,rsi
    11a3:	mov    QWORD PTR [rsp+0x8],rdx
    11a8:	mov    r14,rdx
    11ab:	mov    QWORD PTR [rsp+0x10],rcx
    11b0:	mov    rax,QWORD PTR [rdi+0x10]
    11b4:	mov    r12,rdi
    11b7:	mov    rdx,QWORD PTR [rax+0xe0]
    11be:	mov    QWORD PTR [rsp+0x18],rdx
    11c3:	mov    rbx,r8
    11c6:	mov    r8,rcx
    11c9:	mov    rcx,r14
    11cc:	mov    rsi,rbx
    11cf:	call   11d4 <botlish_fn_14+0x54>
			11d0: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<generic>
    11d4:	mov    rcx,rax
    11d7:	mov    r13,rax
    11da:	test   rax,rcx
    11dd:	jne    1203 <botlish_fn_14+0x83>
    11e3:	xor    rax,rax
    11e6:	mov    rbx,QWORD PTR [rsp+0x20]
    11eb:	mov    r12,QWORD PTR [rsp+0x28]
    11f0:	mov    r13,QWORD PTR [rsp+0x30]
    11f5:	mov    r14,QWORD PTR [rsp+0x38]
    11fa:	add    rsp,0x40
    11fe:	mov    rsp,rbp
    1201:	pop    rbp
    1202:	ret
    1203:	mov    rax,r13
    1206:	mov    QWORD PTR [rsp+0x8],rax
    120b:	mov    rdx,r14
    120e:	and    rax,rdx
    1211:	test   rax,0x1
    1217:	jne    1240 <botlish_fn_14+0xc0>
    121d:	mov    rsi,r13
    1220:	mov    rdi,r12
    1223:	call   1228 <botlish_fn_14+0xa8>
			1224: R_X86_64_PLT32	rt_int_cmp-0x4
    1228:	mov    ecx,0x2
    122d:	test   rax,rax
    1230:	cmove  rcx,QWORD PTR [rip+0xe0]        # 1318 <botlish_fn_14+0x198>
    1238:	mov    rax,r13
    123b:	jmp    1253 <botlish_fn_14+0xd3>
    1240:	mov    ecx,0x2
    1245:	mov    rax,r13
    1248:	cmp    rax,rdx
    124b:	cmove  rcx,QWORD PTR [rip+0xc5]        # 1318 <botlish_fn_14+0x198>
    1253:	cmp    rcx,0x6
    1257:	je     126a <botlish_fn_14+0xea>
    125d:	mov    ecx,0x2
    1262:	mov    rax,rcx
    1265:	jmp    12f7 <botlish_fn_14+0x177>
    126a:	mov    rcx,rax
    126d:	and    rcx,rbx
    1270:	test   rcx,0x1
    1277:	jne    1288 <botlish_fn_14+0x108>
    127d:	mov    rdx,rbx
    1280:	mov    rsi,rax
    1283:	jmp    12a9 <botlish_fn_14+0x129>
    1288:	mov    rcx,rax
    128b:	sub    rcx,rbx
    128e:	mov    r8,rbx
    1291:	mov    r13,rax
    1294:	seto   al
    1297:	lea    rsi,[rcx+0x1]
    129b:	test   al,al
    129d:	je     12b4 <botlish_fn_14+0x134>
    12a3:	mov    rdx,r8
    12a6:	mov    rsi,r13
    12a9:	mov    rdi,r12
    12ac:	call   12b1 <botlish_fn_14+0x131>
			12ad: R_X86_64_PLT32	rt_int_sub-0x4
    12b1:	mov    rsi,rax
    12b4:	test   rsi,0x1
    12bb:	jne    12e6 <botlish_fn_14+0x166>
    12c1:	mov    edx,0x5
    12c6:	mov    rdi,r12
    12c9:	call   12ce <botlish_fn_14+0x14e>
			12ca: R_X86_64_PLT32	rt_int_cmp-0x4
    12ce:	mov    ecx,0x2
    12d3:	test   rax,rax
    12d6:	mov    rax,rcx
    12d9:	cmovge rax,QWORD PTR [rip+0x37]        # 1318 <botlish_fn_14+0x198>
    12e1:	jmp    12f7 <botlish_fn_14+0x177>
    12e6:	mov    eax,0x2
    12eb:	cmp    rsi,0x5
    12ef:	cmovge rax,QWORD PTR [rip+0x21]        # 1318 <botlish_fn_14+0x198>
    12f7:	mov    rbx,QWORD PTR [rsp+0x20]
    12fc:	mov    r12,QWORD PTR [rsp+0x28]
    1301:	mov    r13,QWORD PTR [rsp+0x30]
    1306:	mov    r14,QWORD PTR [rsp+0x38]
    130b:	add    rsp,0x40
    130f:	mov    rsp,rbp
    1312:	pop    rbp
    1313:	ret
    1314:	add    BYTE PTR [rax],al
    1316:	add    BYTE PTR [rax],al
    1318:	(bad)
    1319:	add    BYTE PTR [rax],al
    131b:	add    BYTE PTR [rax],al
    131d:	add    BYTE PTR [rax],al
	...

0000000000001320 <botlish_entry_14: tld?<generic>>:
    1320:	push   rbp
    1321:	mov    rbp,rsp
    1324:	mov    rsi,QWORD PTR [rdx]
    1327:	mov    r8,QWORD PTR [rdx+0x8]
    132b:	mov    rcx,QWORD PTR [rdx+0x10]
    132f:	mov    rdx,r8
    1332:	call   1337 <botlish_entry_14+0x17>
			1333: R_X86_64_PLT32	botlish_fn_14-0x4 ; tld?<generic>
    1337:	mov    rsp,rbp
    133a:	pop    rbp
    133b:	ret
    133c:	add    BYTE PTR [rax],al
	...


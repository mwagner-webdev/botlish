# command-line-arguments
main.fib STEXT size=100 args=0x8 locals=0x18 funcid=0x0 align=0x0
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	TEXT	main.fib(SB), ABIInternal, $24-8
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	CMPQ	SP, 16(R14)
	0x0004 00004 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	PCDATA	$0, $-2
	0x0004 00004 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	JLS	83
	0x0006 00006 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	PCDATA	$0, $-1
	0x0006 00006 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	PUSHQ	BP
	0x0007 00007 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	MOVQ	SP, BP
	0x000a 00010 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	SUBQ	$16, SP
	0x000e 00014 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	FUNCDATA	$0, gclocals·g2BeySu+wFnoycgXfElmcg==(SB)
	0x000e 00014 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	FUNCDATA	$1, gclocals·g2BeySu+wFnoycgXfElmcg==(SB)
	0x000e 00014 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	FUNCDATA	$5, main.fib.arginfo1(SB)
	0x000e 00014 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	FUNCDATA	$6, main.fib.argliveinfo(SB)
	0x000e 00014 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	PCDATA	$3, $1
	0x000e 00014 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:11)	CMPQ	AX, $2
	0x0012 00018 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:11)	JGE	26
	0x0014 00020 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:12)	ADDQ	$16, SP
	0x0018 00024 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:12)	POPQ	BP
	0x0019 00025 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:12)	RET
	0x001a 00026 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:11)	MOVQ	AX, main.n+32(SP)
	0x001f 00031 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:11)	PCDATA	$3, $-1
	0x001f 00031 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	LEAQ	-1(AX), CX
	0x0023 00035 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	MOVQ	CX, AX
	0x0026 00038 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	PCDATA	$1, $0
	0x0026 00038 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	CALL	main.fib(SB)
	0x002b 00043 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	MOVQ	AX, main..autotmp_4+8(SP)
	0x0030 00048 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	MOVQ	main.n+32(SP), CX
	0x0035 00053 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	ADDQ	$-2, CX
	0x0039 00057 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	MOVQ	CX, AX
	0x003c 00060 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	NOP
	0x0040 00064 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	CALL	main.fib(SB)
	0x0045 00069 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	MOVQ	main..autotmp_4+8(SP), CX
	0x004a 00074 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	ADDQ	CX, AX
	0x004d 00077 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	ADDQ	$16, SP
	0x0051 00081 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	POPQ	BP
	0x0052 00082 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	RET
	0x0053 00083 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:14)	NOP
	0x0053 00083 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	PCDATA	$1, $-1
	0x0053 00083 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	PCDATA	$0, $-2
	0x0053 00083 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	MOVQ	AX, 8(SP)
	0x0058 00088 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	CALL	runtime.morestack_noctxt(SB)
	0x005d 00093 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	PCDATA	$0, $-1
	0x005d 00093 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	MOVQ	8(SP), AX
	0x0062 00098 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:10)	JMP	0
	0x0000 49 3b 66 10 76 4d 55 48 89 e5 48 83 ec 10 48 83  I;f.vMUH..H...H.
	0x0010 f8 02 7d 06 48 83 c4 10 5d c3 48 89 44 24 20 48  ..}.H...].H.D$ H
	0x0020 8d 48 ff 48 89 c8 e8 00 00 00 00 48 89 44 24 08  .H.H.......H.D$.
	0x0030 48 8b 4c 24 20 48 83 c1 fe 48 89 c8 0f 1f 40 00  H.L$ H...H....@.
	0x0040 e8 00 00 00 00 48 8b 4c 24 08 48 01 c8 48 83 c4  .....H.L$.H..H..
	0x0050 10 5d c3 48 89 44 24 08 e8 00 00 00 00 48 8b 44  .].H.D$......H.D
	0x0060 24 08 eb 9c                                      $...
	rel 39+4 t=R_CALL main.fib+0
	rel 65+4 t=R_CALL main.fib+0
	rel 89+4 t=R_CALL runtime.morestack_noctxt+0
main.parseArgs STEXT size=440 args=0x0 locals=0x88 funcid=0x0 align=0x0
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	TEXT	main.parseArgs(SB), ABIInternal, $136-0
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	LEAQ	-8(SP), R12
	0x0005 00005 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	CMPQ	R12, 16(R14)
	0x0009 00009 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	PCDATA	$0, $-2
	0x0009 00009 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	JLS	430
	0x000f 00015 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	PCDATA	$0, $-1
	0x000f 00015 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	PUSHQ	BP
	0x0010 00016 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	MOVQ	SP, BP
	0x0013 00019 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	ADDQ	$-128, SP
	0x0017 00023 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	FUNCDATA	$0, gclocals·ykHN0vawYuq1dUW4zEe2gA==(SB)
	0x0017 00023 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	FUNCDATA	$1, gclocals·lf0jAOJ5icNqMXtP6rxGWQ==(SB)
	0x0017 00023 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	MOVL	$1, AX
	0x001c 00028 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	XORL	CX, CX
	0x001e 00030 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	XORL	DX, DX
	0x0020 00032 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	XORL	BX, BX
	0x0022 00034 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	MOVL	$5, SI
	0x0027 00039 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:20)	JMP	44
	0x0029 00041 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:20)	INCQ	AX
	0x002c 00044 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:20)	MOVQ	os.Args+8(SB), R8
	0x0033 00051 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:20)	CMPQ	AX, R8
	0x0036 00054 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:20)	JGE	347
	0x003c 00060 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:20)	NOP
	0x0040 00064 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	JCC	421
	0x0046 00070 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:20)	MOVQ	os.Args(SB), R9
	0x004d 00077 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	MOVQ	AX, R10
	0x0050 00080 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	SHLQ	$4, R10
	0x0054 00084 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	MOVQ	8(R10)(R9*1), R11
	0x0059 00089 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	MOVQ	(R10)(R9*1), R10
	0x005d 00093 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	NOP
	0x0060 00096 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	CMPQ	R11, $6
	0x0064 00100 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	JNE	229
	0x0066 00102 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	CMPL	(R10), $1970416941
	0x006d 00109 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	JNE	229
	0x006f 00111 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	CMPW	4(R10), $29550
	0x0076 00118 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	JNE	229
	0x0078 00120 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:22)	INCQ	AX
	0x007b 00123 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:22)	NOP
	0x0080 00128 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:23)	CMPQ	R8, AX
	0x0083 00131 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:23)	JLE	397
	0x0089 00137 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:26)	JLS	389
	0x008f 00143 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	CX, main.positional.cap+80(SP)
	0x0094 00148 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	BX, main.positional.len+72(SP)
	0x0099 00153 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:22)	MOVQ	AX, main.i+88(SP)
	0x009e 00158 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	DX, main.positional.ptr+112(SP)
	0x00a3 00163 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:26)	SHLQ	$4, AX
	0x00a7 00167 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:26)	MOVQ	(AX)(R9*1), DX
	0x00ab 00171 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:26)	MOVQ	8(AX)(R9*1), BX
	0x00b0 00176 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:26)	MOVQ	DX, AX
	0x00b3 00179 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:26)	PCDATA	$1, $1
	0x00b3 00179 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:26)	CALL	strconv.Atoi(SB)
	0x00b8 00184 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:26)	NOP
	0x00c0 00192 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:27)	TESTQ	BX, BX
	0x00c3 00195 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:27)	JNE	365
	0x00c9 00201 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	main.positional.cap+80(SP), CX
	0x00ce 00206 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	main.positional.len+72(SP), BX
	0x00d3 00211 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	main.positional.ptr+112(SP), DX
	0x00d8 00216 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:35)	MOVQ	AX, SI
	0x00db 00219 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:20)	MOVQ	main.i+88(SP), AX
	0x00e0 00224 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:31)	JMP	41
	0x00e5 00229 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	INCQ	BX
	0x00e8 00232 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	CMPQ	CX, BX
	0x00eb 00235 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	JCC	300
	0x00ed 00237 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:20)	MOVQ	AX, main..autotmp_19+104(SP)
	0x00f2 00242 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	MOVQ	R10, main..autotmp_20+120(SP)
	0x00f7 00247 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	MOVQ	R11, main..autotmp_21+96(SP)
	0x00fc 00252 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:35)	MOVQ	SI, main.runs+64(SP)
	0x0101 00257 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	DX, AX
	0x0104 00260 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVL	$1, DI
	0x0109 00265 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	LEAQ	type:string(SB), SI
	0x0110 00272 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	PCDATA	$1, $2
	0x0110 00272 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	CALL	runtime.growslice(SB)
	0x0115 00277 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:35)	MOVQ	main.runs+64(SP), SI
	0x011a 00282 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	main..autotmp_20+120(SP), R10
	0x011f 00287 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	main..autotmp_21+96(SP), R11
	0x0124 00292 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	AX, DX
	0x0127 00295 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:20)	MOVQ	main..autotmp_19+104(SP), AX
	0x012c 00300 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	LEAQ	-1(BX), R8
	0x0130 00304 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	SHLQ	$4, R8
	0x0134 00308 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	R11, 8(DX)(R8*1)
	0x0139 00313 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	CMPL	runtime.writeBarrier(SB), $0
	0x0140 00320 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	PCDATA	$0, $-2
	0x0140 00320 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	JEQ	338
	0x0142 00322 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	CALL	runtime.gcWriteBarrier2(SB)
	0x0147 00327 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	R10, (R11)
	0x014a 00330 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	(DX)(R8*1), R9
	0x014e 00334 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	R9, 8(R11)
	0x0152 00338 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	MOVQ	R10, (DX)(R8*1)
	0x0156 00342 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	PCDATA	$0, $-1
	0x0156 00342 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:33)	JMP	41
	0x015b 00347 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:35)	MOVQ	SI, AX
	0x015e 00350 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:35)	MOVQ	CX, DI
	0x0161 00353 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:35)	MOVQ	BX, CX
	0x0164 00356 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:35)	MOVQ	DX, BX
	0x0167 00359 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:35)	SUBQ	$-128, SP
	0x016b 00363 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:35)	POPQ	BP
	0x016c 00364 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:35)	RET
	0x016d 00365 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:28)	LEAQ	type:string(SB), AX
	0x0174 00372 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:28)	LEAQ	main..stmp_1(SB), BX
	0x017b 00379 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:28)	PCDATA	$1, $0
	0x017b 00379 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:28)	NOP
	0x0180 00384 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:28)	CALL	runtime.gopanic(SB)
	0x0185 00389 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:26)	MOVQ	R8, CX
	0x0188 00392 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:26)	CALL	runtime.panicIndex(SB)
	0x018d 00397 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:24)	LEAQ	type:string(SB), AX
	0x0194 00404 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:24)	LEAQ	main..stmp_0(SB), BX
	0x019b 00411 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:24)	NOP
	0x01a0 00416 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:24)	CALL	runtime.gopanic(SB)
	0x01a5 00421 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	MOVQ	R8, CX
	0x01a8 00424 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	CALL	runtime.panicIndex(SB)
	0x01ad 00429 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	XCHGL	AX, AX
	0x01ae 00430 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:21)	NOP
	0x01ae 00430 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	PCDATA	$1, $-1
	0x01ae 00430 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	PCDATA	$0, $-2
	0x01ae 00430 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	CALL	runtime.morestack_noctxt(SB)
	0x01b3 00435 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	PCDATA	$0, $-1
	0x01b3 00435 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:17)	JMP	0
	0x0000 4c 8d 64 24 f8 4d 3b 66 10 0f 86 9f 01 00 00 55  L.d$.M;f.......U
	0x0010 48 89 e5 48 83 c4 80 b8 01 00 00 00 31 c9 31 d2  H..H........1.1.
	0x0020 31 db be 05 00 00 00 eb 03 48 ff c0 4c 8b 05 00  1........H..L...
	0x0030 00 00 00 4c 39 c0 0f 8d 1f 01 00 00 0f 1f 40 00  ...L9.........@.
	0x0040 0f 83 5f 01 00 00 4c 8b 0d 00 00 00 00 49 89 c2  .._...L......I..
	0x0050 49 c1 e2 04 4f 8b 5c 0a 08 4f 8b 14 0a 0f 1f 00  I...O.\..O......
	0x0060 49 83 fb 06 75 7f 41 81 3a 2d 2d 72 75 75 76 66  I...u.A.:--ruuvf
	0x0070 41 81 7a 04 6e 73 75 6d 48 ff c0 0f 1f 44 00 00  A.z.nsumH....D..
	0x0080 49 39 c0 0f 8e 04 01 00 00 0f 86 f6 00 00 00 48  I9.............H
	0x0090 89 4c 24 50 48 89 5c 24 48 48 89 44 24 58 48 89  .L$PH.\$HH.D$XH.
	0x00a0 54 24 70 48 c1 e0 04 4a 8b 14 08 4a 8b 5c 08 08  T$pH...J...J.\..
	0x00b0 48 89 d0 e8 00 00 00 00 0f 1f 84 00 00 00 00 00  H...............
	0x00c0 48 85 db 0f 85 a4 00 00 00 48 8b 4c 24 50 48 8b  H........H.L$PH.
	0x00d0 5c 24 48 48 8b 54 24 70 48 89 c6 48 8b 44 24 58  \$HH.T$pH..H.D$X
	0x00e0 e9 44 ff ff ff 48 ff c3 48 39 d9 73 3f 48 89 44  .D...H..H9.s?H.D
	0x00f0 24 68 4c 89 54 24 78 4c 89 5c 24 60 48 89 74 24  $hL.T$xL.\$`H.t$
	0x0100 40 48 89 d0 bf 01 00 00 00 48 8d 35 00 00 00 00  @H.......H.5....
	0x0110 e8 00 00 00 00 48 8b 74 24 40 4c 8b 54 24 78 4c  .....H.t$@L.T$xL
	0x0120 8b 5c 24 60 48 89 c2 48 8b 44 24 68 4c 8d 43 ff  .\$`H..H.D$hL.C.
	0x0130 49 c1 e0 04 4e 89 5c 02 08 83 3d 00 00 00 00 00  I...N.\...=.....
	0x0140 74 10 e8 00 00 00 00 4d 89 13 4e 8b 0c 02 4d 89  t......M..N...M.
	0x0150 4b 08 4e 89 14 02 e9 ce fe ff ff 48 89 f0 48 89  K.N........H..H.
	0x0160 cf 48 89 d9 48 89 d3 48 83 ec 80 5d c3 48 8d 05  .H..H..H...].H..
	0x0170 00 00 00 00 48 8d 1d 00 00 00 00 0f 1f 44 00 00  ....H........D..
	0x0180 e8 00 00 00 00 4c 89 c1 e8 00 00 00 00 48 8d 05  .....L.......H..
	0x0190 00 00 00 00 48 8d 1d 00 00 00 00 0f 1f 44 00 00  ....H........D..
	0x01a0 e8 00 00 00 00 4c 89 c1 e8 00 00 00 00 90 e8 00  .....L..........
	0x01b0 00 00 00 e9 48 fe ff ff                          ....H...
	rel 3+0 t=R_USEIFACE type:string+0
	rel 3+0 t=R_USEIFACE type:string+0
	rel 47+4 t=R_PCREL os.Args+8
	rel 73+4 t=R_PCREL os.Args+0
	rel 180+4 t=R_CALL strconv.Atoi+0
	rel 268+4 t=R_PCREL type:string+0
	rel 273+4 t=R_CALL runtime.growslice+0
	rel 315+4 t=R_PCREL runtime.writeBarrier+-1
	rel 323+4 t=R_CALL runtime.gcWriteBarrier2+0
	rel 368+4 t=R_PCREL type:string+0
	rel 375+4 t=R_PCREL main..stmp_1+0
	rel 385+4 t=R_CALL runtime.gopanic+0
	rel 393+4 t=R_CALL runtime.panicIndex+0
	rel 400+4 t=R_PCREL type:string+0
	rel 407+4 t=R_PCREL main..stmp_0+0
	rel 417+4 t=R_CALL runtime.gopanic+0
	rel 425+4 t=R_CALL runtime.panicIndex+0
	rel 431+4 t=R_CALL runtime.morestack_noctxt+0
main.main STEXT size=464 args=0x0 locals=0xa0 funcid=0x0 align=0x0
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	TEXT	main.main(SB), ABIInternal, $160-0
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	LEAQ	-32(SP), R12
	0x0005 00005 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	CMPQ	R12, 16(R14)
	0x0009 00009 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	PCDATA	$0, $-2
	0x0009 00009 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	JLS	454
	0x000f 00015 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	PCDATA	$0, $-1
	0x000f 00015 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	PUSHQ	BP
	0x0010 00016 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	MOVQ	SP, BP
	0x0013 00019 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	SUBQ	$152, SP
	0x001a 00026 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	FUNCDATA	$0, gclocals·D1/YcbyNumM1nqYyoY4wEQ==(SB)
	0x001a 00026 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	FUNCDATA	$1, gclocals·BlHcitTlo7sYGWV8AFU29A==(SB)
	0x001a 00026 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	FUNCDATA	$2, main.main.stkobj(SB)
	0x001a 00026 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:39)	PCDATA	$1, $0
	0x001a 00026 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:39)	CALL	main.parseArgs(SB)
	0x001f 00031 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:39)	MOVQ	AX, main.runs+64(SP)
	0x0024 00036 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:41)	TESTQ	CX, CX
	0x0027 00039 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:41)	JNE	48
	0x0029 00041 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:41)	MOVL	$22, CX
	0x002e 00046 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:41)	JMP	82
	0x0030 00048 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:42)	MOVQ	(BX), AX
	0x0033 00051 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:42)	MOVQ	8(BX), BX
	0x0037 00055 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:42)	MOVL	$10, CX
	0x003c 00060 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:42)	MOVL	$64, DI
	0x0041 00065 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:42)	CALL	strconv.ParseInt(SB)
	0x0046 00070 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:43)	TESTQ	BX, BX
	0x0049 00073 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:43)	JNE	431
	0x004f 00079 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:49)	MOVQ	AX, CX
	0x0052 00082 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:49)	MOVQ	CX, main.n+72(SP)
	0x0057 00087 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:49)	MOVQ	CX, AX
	0x005a 00090 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:49)	CALL	main.fib(SB)
	0x005f 00095 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:52)	MOVQ	main.runs+64(SP), AX
	0x0064 00100 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:52)	XORL	CX, CX
	0x0066 00102 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:52)	MOVSD	$f64.43e0000000000000(SB), X0
	0x006e 00110 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:52)	JMP	125
	0x0070 00112 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:52)	MOVQ	main.i+80(SP), AX
	0x0075 00117 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:52)	DECQ	AX
	0x0078 00120 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:61)	MOVQ	main.value+56(SP), CX
	0x007d 00125 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:62)	MOVSD	X0, main.best+88(SP)
	0x0083 00131 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:52)	TESTQ	AX, AX
	0x0086 00134 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:52)	JLE	234
	0x0088 00136 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:52)	MOVQ	AX, main.i+80(SP)
	0x008d 00141 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:53)	CALL	time.Now(SB)
	0x0092 00146 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:53)	MOVQ	AX, main..autotmp_62+104(SP)
	0x0097 00151 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:53)	MOVQ	BX, main..autotmp_63+96(SP)
	0x009c 00156 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:53)	MOVQ	CX, main..autotmp_64+112(SP)
	0x00a1 00161 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:54)	MOVQ	main.n+72(SP), AX
	0x00a6 00166 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:54)	PCDATA	$1, $1
	0x00a6 00166 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:54)	CALL	main.fib(SB)
	0x00ab 00171 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:54)	MOVQ	AX, main.value+56(SP)
	0x00b0 00176 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:55)	MOVQ	main..autotmp_63+96(SP), BX
	0x00b5 00181 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:55)	MOVQ	main..autotmp_64+112(SP), CX
	0x00ba 00186 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:55)	MOVQ	main..autotmp_62+104(SP), AX
	0x00bf 00191 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:55)	PCDATA	$1, $0
	0x00bf 00191 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:55)	NOP
	0x00c0 00192 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:55)	CALL	time.Since(SB)
	0x00c5 00197 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:55)	XORPS	X0, X0
	0x00c8 00200 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:55)	CVTSQ2SD	AX, X0
	0x00cd 00205 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:55)	MOVSD	$f64.408f400000000000(SB), X1
	0x00d5 00213 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:55)	DIVSD	X1, X0
	0x00d9 00217 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:56)	MOVSD	main.best+88(SP), X2
	0x00df 00223 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:56)	UCOMISD	X0, X2
	0x00e3 00227 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:56)	JHI	112
	0x00e5 00229 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:62)	MOVUPS	X2, X0
	0x00e8 00232 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:56)	JMP	112
	0x00ea 00234 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:61)	MOVUPS	X15, main..autotmp_33+136(SP)
	0x00f3 00243 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:61)	MOVQ	CX, AX
	0x00f6 00246 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:61)	PCDATA	$1, $2
	0x00f6 00246 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:61)	CALL	runtime.convT64(SB)
	0x00fb 00251 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:61)	LEAQ	type:int64(SB), CX
	0x0102 00258 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:61)	MOVQ	CX, main..autotmp_33+136(SP)
	0x010a 00266 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:61)	MOVQ	AX, main..autotmp_33+144(SP)
	0x0112 00274 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:62)	MOVSD	main.best+88(SP), X0
	0x0118 00280 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:62)	MOVQ	X0, CX
	0x011d 00285 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:62)	MOVQ	CX, main..autotmp_62+104(SP)
	0x0122 00290 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVQ	os.Stdout(SB), BX
	0x0129 00297 (<unknown line number>)	NOP
	0x0129 00297 (/usr/lib/go-1.22/src/fmt/print.go:233)	LEAQ	go:itab.*os.File,io.Writer(SB), AX
	0x0130 00304 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVL	$10, DI
	0x0135 00309 (/usr/lib/go-1.22/src/fmt/print.go:233)	LEAQ	main..autotmp_33+136(SP), SI
	0x013d 00317 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVL	$1, R8
	0x0143 00323 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVQ	R8, R9
	0x0146 00326 (/usr/lib/go-1.22/src/fmt/print.go:233)	LEAQ	go:string."value: %d\n"(SB), CX
	0x014d 00333 (/usr/lib/go-1.22/src/fmt/print.go:233)	PCDATA	$1, $0
	0x014d 00333 (/usr/lib/go-1.22/src/fmt/print.go:233)	CALL	fmt.Fprintf(SB)
	0x0152 00338 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:62)	MOVUPS	X15, main..autotmp_36+120(SP)
	0x0158 00344 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:62)	MOVQ	main..autotmp_62+104(SP), AX
	0x015d 00349 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:62)	PCDATA	$1, $3
	0x015d 00349 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:62)	NOP
	0x0160 00352 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:62)	CALL	runtime.convT64(SB)
	0x0165 00357 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:62)	LEAQ	type:float64(SB), CX
	0x016c 00364 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:62)	MOVQ	CX, main..autotmp_36+120(SP)
	0x0171 00369 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:62)	MOVQ	AX, main..autotmp_36+128(SP)
	0x0179 00377 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVQ	os.Stdout(SB), BX
	0x0180 00384 (<unknown line number>)	NOP
	0x0180 00384 (/usr/lib/go-1.22/src/fmt/print.go:233)	LEAQ	go:itab.*os.File,io.Writer(SB), AX
	0x0187 00391 (/usr/lib/go-1.22/src/fmt/print.go:233)	LEAQ	go:string."best_us: %.3f\n"(SB), CX
	0x018e 00398 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVL	$14, DI
	0x0193 00403 (/usr/lib/go-1.22/src/fmt/print.go:233)	LEAQ	main..autotmp_36+120(SP), SI
	0x0198 00408 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVL	$1, R8
	0x019e 00414 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVQ	R8, R9
	0x01a1 00417 (/usr/lib/go-1.22/src/fmt/print.go:233)	PCDATA	$1, $0
	0x01a1 00417 (/usr/lib/go-1.22/src/fmt/print.go:233)	CALL	fmt.Fprintf(SB)
	0x01a6 00422 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:63)	ADDQ	$152, SP
	0x01ad 00429 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:63)	POPQ	BP
	0x01ae 00430 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:63)	RET
	0x01af 00431 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:44)	LEAQ	type:string(SB), AX
	0x01b6 00438 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:44)	LEAQ	main..stmp_2(SB), BX
	0x01bd 00445 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:44)	NOP
	0x01c0 00448 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:44)	CALL	runtime.gopanic(SB)
	0x01c5 00453 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:44)	XCHGL	AX, AX
	0x01c6 00454 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:44)	NOP
	0x01c6 00454 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	PCDATA	$1, $-1
	0x01c6 00454 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	PCDATA	$0, $-2
	0x01c6 00454 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	CALL	runtime.morestack_noctxt(SB)
	0x01cb 00459 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	PCDATA	$0, $-1
	0x01cb 00459 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go:38)	JMP	0
	0x0000 4c 8d 64 24 e0 4d 3b 66 10 0f 86 b7 01 00 00 55  L.d$.M;f.......U
	0x0010 48 89 e5 48 81 ec 98 00 00 00 e8 00 00 00 00 48  H..H...........H
	0x0020 89 44 24 40 48 85 c9 75 07 b9 16 00 00 00 eb 22  .D$@H..u......."
	0x0030 48 8b 03 48 8b 5b 08 b9 0a 00 00 00 bf 40 00 00  H..H.[.......@..
	0x0040 00 e8 00 00 00 00 48 85 db 0f 85 60 01 00 00 48  ......H....`...H
	0x0050 89 c1 48 89 4c 24 48 48 89 c8 e8 00 00 00 00 48  ..H.L$HH.......H
	0x0060 8b 44 24 40 31 c9 f2 0f 10 05 00 00 00 00 eb 0d  .D$@1...........
	0x0070 48 8b 44 24 50 48 ff c8 48 8b 4c 24 38 f2 0f 11  H.D$PH..H.L$8...
	0x0080 44 24 58 48 85 c0 7e 62 48 89 44 24 50 e8 00 00  D$XH..~bH.D$P...
	0x0090 00 00 48 89 44 24 68 48 89 5c 24 60 48 89 4c 24  ..H.D$hH.\$`H.L$
	0x00a0 70 48 8b 44 24 48 e8 00 00 00 00 48 89 44 24 38  pH.D$H.....H.D$8
	0x00b0 48 8b 5c 24 60 48 8b 4c 24 70 48 8b 44 24 68 90  H.\$`H.L$pH.D$h.
	0x00c0 e8 00 00 00 00 0f 57 c0 f2 48 0f 2a c0 f2 0f 10  ......W..H.*....
	0x00d0 0d 00 00 00 00 f2 0f 5e c1 f2 0f 10 54 24 58 66  .......^....T$Xf
	0x00e0 0f 2e d0 77 8b 0f 10 c2 eb 86 44 0f 11 bc 24 88  ...w......D...$.
	0x00f0 00 00 00 48 89 c8 e8 00 00 00 00 48 8d 0d 00 00  ...H.......H....
	0x0100 00 00 48 89 8c 24 88 00 00 00 48 89 84 24 90 00  ..H..$....H..$..
	0x0110 00 00 f2 0f 10 44 24 58 66 48 0f 7e c1 48 89 4c  .....D$XfH.~.H.L
	0x0120 24 68 48 8b 1d 00 00 00 00 48 8d 05 00 00 00 00  $hH......H......
	0x0130 bf 0a 00 00 00 48 8d b4 24 88 00 00 00 41 b8 01  .....H..$....A..
	0x0140 00 00 00 4d 89 c1 48 8d 0d 00 00 00 00 e8 00 00  ...M..H.........
	0x0150 00 00 44 0f 11 7c 24 78 48 8b 44 24 68 0f 1f 00  ..D..|$xH.D$h...
	0x0160 e8 00 00 00 00 48 8d 0d 00 00 00 00 48 89 4c 24  .....H......H.L$
	0x0170 78 48 89 84 24 80 00 00 00 48 8b 1d 00 00 00 00  xH..$....H......
	0x0180 48 8d 05 00 00 00 00 48 8d 0d 00 00 00 00 bf 0e  H......H........
	0x0190 00 00 00 48 8d 74 24 78 41 b8 01 00 00 00 4d 89  ...H.t$xA.....M.
	0x01a0 c1 e8 00 00 00 00 48 81 c4 98 00 00 00 5d c3 48  ......H......].H
	0x01b0 8d 05 00 00 00 00 48 8d 1d 00 00 00 00 0f 1f 00  ......H.........
	0x01c0 e8 00 00 00 00 90 e8 00 00 00 00 e9 30 fe ff ff  ............0...
	rel 3+0 t=R_USEIFACE type:string+0
	rel 3+0 t=R_USEIFACE type:int64+0
	rel 3+0 t=R_USEIFACE type:*os.File+0
	rel 3+0 t=R_USEIFACE type:float64+0
	rel 3+0 t=R_USEIFACE type:*os.File+0
	rel 27+4 t=R_CALL main.parseArgs+0
	rel 66+4 t=R_CALL strconv.ParseInt+0
	rel 91+4 t=R_CALL main.fib+0
	rel 106+4 t=R_PCREL $f64.43e0000000000000+0
	rel 142+4 t=R_CALL time.Now+0
	rel 167+4 t=R_CALL main.fib+0
	rel 193+4 t=R_CALL time.Since+0
	rel 209+4 t=R_PCREL $f64.408f400000000000+0
	rel 247+4 t=R_CALL runtime.convT64+0
	rel 254+4 t=R_PCREL type:int64+0
	rel 293+4 t=R_PCREL os.Stdout+0
	rel 300+4 t=R_PCREL go:itab.*os.File,io.Writer+0
	rel 329+4 t=R_PCREL go:string."value: %d\n"+0
	rel 334+4 t=R_CALL fmt.Fprintf+0
	rel 353+4 t=R_CALL runtime.convT64+0
	rel 360+4 t=R_PCREL type:float64+0
	rel 380+4 t=R_PCREL os.Stdout+0
	rel 387+4 t=R_PCREL go:itab.*os.File,io.Writer+0
	rel 394+4 t=R_PCREL go:string."best_us: %.3f\n"+0
	rel 418+4 t=R_CALL fmt.Fprintf+0
	rel 434+4 t=R_PCREL type:string+0
	rel 441+4 t=R_PCREL main..stmp_2+0
	rel 449+4 t=R_CALL runtime.gopanic+0
	rel 455+4 t=R_CALL runtime.morestack_noctxt+0
go:cuinfo.producer.main SDWARFCUINFO dupok size=0
	0x0000 72 65 67 61 62 69                                regabi
go:cuinfo.packagename.main SDWARFCUINFO dupok size=0
	0x0000 6d 61 69 6e                                      main
go:info.fmt.Printf$abstract SDWARFABSFCN dupok size=56
	0x0000 05 66 6d 74 2e 50 72 69 6e 74 66 00 01 e8 01 01  .fmt.Printf.....
	0x0010 13 66 6f 72 6d 61 74 00 00 00 00 00 00 13 61 00  .format.......a.
	0x0020 00 00 00 00 00 13 6e 00 01 00 00 00 00 13 65 72  ......n.......er
	0x0030 72 00 01 00 00 00 00 00                          r.......
	rel 0+0 t=R_USETYPE type:[]interface {}+0
	rel 0+0 t=R_USETYPE type:error+0
	rel 0+0 t=R_USETYPE type:int+0
	rel 0+0 t=R_USETYPE type:string+0
	rel 25+4 t=R_DWARFSECREF go:info.string+0
	rel 33+4 t=R_DWARFSECREF go:info.[]interface {}+0
	rel 41+4 t=R_DWARFSECREF go:info.int+0
	rel 51+4 t=R_DWARFSECREF go:info.error+0
go:itab.*os.File,io.Writer SRODATA dupok size=32
	0x0000 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
	0x0010 5a 22 ee 60 00 00 00 00 00 00 00 00 00 00 00 00  Z".`............
	rel 0+8 t=R_ADDR type:io.Writer+0
	rel 8+8 t=R_ADDR type:*os.File+0
	rel 24+8 t=RelocType(-32767) os.(*File).Write+0
main..inittask SNOPTRDATA size=8
	0x0000 00 00 00 00 00 00 00 00                          ........
	rel 0+0 t=R_INITORDER fmt..inittask+0
	rel 0+0 t=R_INITORDER os..inittask+0
	rel 0+0 t=R_INITORDER strconv..inittask+0
	rel 0+0 t=R_INITORDER time..inittask+0
go:string."--runs needs a value" SRODATA dupok size=20
	0x0000 2d 2d 72 75 6e 73 20 6e 65 65 64 73 20 61 20 76  --runs needs a v
	0x0010 61 6c 75 65                                      alue
go:string."--runs must be an integer" SRODATA dupok size=25
	0x0000 2d 2d 72 75 6e 73 20 6d 75 73 74 20 62 65 20 61  --runs must be a
	0x0010 6e 20 69 6e 74 65 67 65 72                       n integer
main..stmp_0 SRODATA static size=16
	0x0000 00 00 00 00 00 00 00 00 14 00 00 00 00 00 00 00  ................
	rel 0+8 t=R_ADDR go:string."--runs needs a value"+0
main..stmp_1 SRODATA static size=16
	0x0000 00 00 00 00 00 00 00 00 19 00 00 00 00 00 00 00  ................
	rel 0+8 t=R_ADDR go:string."--runs must be an integer"+0
go:string."n must be an integer" SRODATA dupok size=20
	0x0000 6e 20 6d 75 73 74 20 62 65 20 61 6e 20 69 6e 74  n must be an int
	0x0010 65 67 65 72                                      eger
go:string."value: %d\n" SRODATA dupok size=10
	0x0000 76 61 6c 75 65 3a 20 25 64 0a                    value: %d.
go:string."best_us: %.3f\n" SRODATA dupok size=14
	0x0000 62 65 73 74 5f 75 73 3a 20 25 2e 33 66 0a        best_us: %.3f.
main..stmp_2 SRODATA static size=16
	0x0000 00 00 00 00 00 00 00 00 14 00 00 00 00 00 00 00  ................
	rel 0+8 t=R_ADDR go:string."n must be an integer"+0
runtime.nilinterequal·f SRODATA dupok size=8
	0x0000 00 00 00 00 00 00 00 00                          ........
	rel 0+8 t=R_ADDR runtime.nilinterequal+0
runtime.memequal64·f SRODATA dupok size=8
	0x0000 00 00 00 00 00 00 00 00                          ........
	rel 0+8 t=R_ADDR runtime.memequal64+0
runtime.gcbits.0100000000000000 SRODATA dupok size=8
	0x0000 01 00 00 00 00 00 00 00                          ........
type:.namedata.*[1]interface {}- SRODATA dupok size=18
	0x0000 00 10 2a 5b 31 5d 69 6e 74 65 72 66 61 63 65 20  ..*[1]interface
	0x0010 7b 7d                                            {}
type:*[1]interface {} SRODATA dupok size=56
	0x0000 08 00 00 00 00 00 00 00 08 00 00 00 00 00 00 00  ................
	0x0010 a8 0e 57 36 08 08 08 36 00 00 00 00 00 00 00 00  ..W6...6........
	0x0020 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
	0x0030 00 00 00 00 00 00 00 00                          ........
	rel 24+8 t=R_ADDR runtime.memequal64·f+0
	rel 32+8 t=R_ADDR runtime.gcbits.0100000000000000+0
	rel 40+4 t=R_ADDROFF type:.namedata.*[1]interface {}-+0
	rel 48+8 t=R_ADDR type:[1]interface {}+0
runtime.gcbits.0200000000000000 SRODATA dupok size=8
	0x0000 02 00 00 00 00 00 00 00                          ........
type:[1]interface {} SRODATA dupok size=72
	0x0000 10 00 00 00 00 00 00 00 10 00 00 00 00 00 00 00  ................
	0x0010 6e 20 6a 3d 02 08 08 11 00 00 00 00 00 00 00 00  n j=............
	0x0020 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
	0x0030 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
	0x0040 01 00 00 00 00 00 00 00                          ........
	rel 24+8 t=R_ADDR runtime.nilinterequal·f+0
	rel 32+8 t=R_ADDR runtime.gcbits.0200000000000000+0
	rel 40+4 t=R_ADDROFF type:.namedata.*[1]interface {}-+0
	rel 44+4 t=RelocType(-32763) type:*[1]interface {}+0
	rel 48+8 t=R_ADDR type:interface {}+0
	rel 56+8 t=R_ADDR type:[]interface {}+0
gclocals·g2BeySu+wFnoycgXfElmcg== SRODATA dupok size=8
	0x0000 01 00 00 00 00 00 00 00                          ........
main.fib.arginfo1 SRODATA static dupok size=3
	0x0000 00 08 ff                                         ...
main.fib.argliveinfo SRODATA static dupok size=2
	0x0000 00 00                                            ..
gclocals·ykHN0vawYuq1dUW4zEe2gA== SRODATA dupok size=8
	0x0000 03 00 00 00 00 00 00 00                          ........
gclocals·lf0jAOJ5icNqMXtP6rxGWQ== SRODATA dupok size=11
	0x0000 03 00 00 00 02 00 00 00 00 01 02                 ...........
gclocals·D1/YcbyNumM1nqYyoY4wEQ== SRODATA dupok size=8
	0x0000 04 00 00 00 00 00 00 00                          ........
gclocals·BlHcitTlo7sYGWV8AFU29A== SRODATA dupok size=12
	0x0000 04 00 00 00 05 00 00 00 00 01 10 04              ............
main.main.stkobj SRODATA static size=40
	0x0000 02 00 00 00 00 00 00 00 e0 ff ff ff 10 00 00 00  ................
	0x0010 10 00 00 00 00 00 00 00 f0 ff ff ff 10 00 00 00  ................
	0x0020 10 00 00 00 00 00 00 00                          ........
	rel 20+4 t=R_ADDROFF runtime.gcbits.0200000000000000+0
	rel 36+4 t=R_ADDROFF runtime.gcbits.0200000000000000+0
$f64.408f400000000000 SRODATA size=8
	0x0000 00 00 00 00 00 40 8f 40                          .....@.@
$f64.43e0000000000000 SRODATA size=8
	0x0000 00 00 00 00 00 00 e0 43                          .......C

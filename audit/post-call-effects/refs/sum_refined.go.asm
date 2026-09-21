# command-line-arguments
main.sumRefined STEXT size=81 args=0x10 locals=0x18 funcid=0x0 align=0x0
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	TEXT	main.sumRefined(SB), ABIInternal, $24-16
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	CMPQ	SP, 16(R14)
	0x0004 00004 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	PCDATA	$0, $-2
	0x0004 00004 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	JLS	49
	0x0006 00006 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	PCDATA	$0, $-1
	0x0006 00006 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	PUSHQ	BP
	0x0007 00007 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	MOVQ	SP, BP
	0x000a 00010 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	SUBQ	$16, SP
	0x000e 00014 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	FUNCDATA	$0, gclocals·g2BeySu+wFnoycgXfElmcg==(SB)
	0x000e 00014 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	FUNCDATA	$1, gclocals·g2BeySu+wFnoycgXfElmcg==(SB)
	0x000e 00014 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	FUNCDATA	$5, main.sumRefined.arginfo1(SB)
	0x000e 00014 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	FUNCDATA	$6, main.sumRefined.argliveinfo(SB)
	0x000e 00014 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	PCDATA	$3, $1
	0x000e 00014 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:11)	TESTQ	AX, AX
	0x0011 00017 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:11)	JNE	28
	0x0013 00019 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:12)	MOVQ	BX, AX
	0x0016 00022 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:12)	ADDQ	$16, SP
	0x001a 00026 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:12)	POPQ	BP
	0x001b 00027 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:12)	RET
	0x001c 00028 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:15)	LEAQ	-1(AX), CX
	0x0020 00032 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:14)	ADDQ	AX, BX
	0x0023 00035 (<unknown line number>)	NOP
	0x0023 00035 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:15)	MOVQ	CX, AX
	0x0026 00038 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:15)	PCDATA	$1, $0
	0x0026 00038 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:15)	CALL	main.sumRefined(SB)
	0x002b 00043 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:15)	ADDQ	$16, SP
	0x002f 00047 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:15)	POPQ	BP
	0x0030 00048 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:15)	RET
	0x0031 00049 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:15)	NOP
	0x0031 00049 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	PCDATA	$1, $-1
	0x0031 00049 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	PCDATA	$0, $-2
	0x0031 00049 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	MOVQ	AX, 8(SP)
	0x0036 00054 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	MOVQ	BX, 16(SP)
	0x003b 00059 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	NOP
	0x0040 00064 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	CALL	runtime.morestack_noctxt(SB)
	0x0045 00069 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	PCDATA	$0, $-1
	0x0045 00069 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	MOVQ	8(SP), AX
	0x004a 00074 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	MOVQ	16(SP), BX
	0x004f 00079 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:10)	JMP	0
	0x0000 49 3b 66 10 76 2b 55 48 89 e5 48 83 ec 10 48 85  I;f.v+UH..H...H.
	0x0010 c0 75 09 48 89 d8 48 83 c4 10 5d c3 48 8d 48 ff  .u.H..H...].H.H.
	0x0020 48 01 c3 48 89 c8 e8 00 00 00 00 48 83 c4 10 5d  H..H.......H...]
	0x0030 c3 48 89 44 24 08 48 89 5c 24 10 0f 1f 44 00 00  .H.D$.H.\$...D..
	0x0040 e8 00 00 00 00 48 8b 44 24 08 48 8b 5c 24 10 eb  .....H.D$.H.\$..
	0x0050 af                                               .
	rel 39+4 t=R_CALL main.sumRefined+0
	rel 65+4 t=R_CALL runtime.morestack_noctxt+0
main.sumRefined.func1 STEXT nosplit size=5 args=0x8 locals=0x0 funcid=0x0 align=0x0
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:14)	TEXT	main.sumRefined.func1(SB), NOSPLIT|NEEDCTXT|NOFRAME|ABIInternal, $0-8
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:14)	FUNCDATA	$0, gclocals·g2BeySu+wFnoycgXfElmcg==(SB)
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:14)	FUNCDATA	$1, gclocals·g2BeySu+wFnoycgXfElmcg==(SB)
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:14)	FUNCDATA	$5, main.sumRefined.func1.arginfo1(SB)
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:14)	FUNCDATA	$6, main.sumRefined.func1.argliveinfo(SB)
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:14)	PCDATA	$3, $1
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:14)	ADDQ	8(DX), AX
	0x0004 00004 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:14)	RET
	0x0000 48 03 42 08 c3                                   H.B..
main.parseArgs STEXT size=440 args=0x0 locals=0x88 funcid=0x0 align=0x0
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	TEXT	main.parseArgs(SB), ABIInternal, $136-0
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	LEAQ	-8(SP), R12
	0x0005 00005 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	CMPQ	R12, 16(R14)
	0x0009 00009 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	PCDATA	$0, $-2
	0x0009 00009 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	JLS	430
	0x000f 00015 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	PCDATA	$0, $-1
	0x000f 00015 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	PUSHQ	BP
	0x0010 00016 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	MOVQ	SP, BP
	0x0013 00019 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	ADDQ	$-128, SP
	0x0017 00023 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	FUNCDATA	$0, gclocals·ykHN0vawYuq1dUW4zEe2gA==(SB)
	0x0017 00023 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	FUNCDATA	$1, gclocals·lf0jAOJ5icNqMXtP6rxGWQ==(SB)
	0x0017 00023 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	MOVL	$1, AX
	0x001c 00028 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	XORL	CX, CX
	0x001e 00030 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	XORL	DX, DX
	0x0020 00032 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	XORL	BX, BX
	0x0022 00034 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	MOVL	$5, SI
	0x0027 00039 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:21)	JMP	44
	0x0029 00041 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:21)	INCQ	AX
	0x002c 00044 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:21)	MOVQ	os.Args+8(SB), R8
	0x0033 00051 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:21)	CMPQ	AX, R8
	0x0036 00054 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:21)	JGE	347
	0x003c 00060 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:21)	NOP
	0x0040 00064 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	JCC	421
	0x0046 00070 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:21)	MOVQ	os.Args(SB), R9
	0x004d 00077 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	MOVQ	AX, R10
	0x0050 00080 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	SHLQ	$4, R10
	0x0054 00084 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	MOVQ	8(R10)(R9*1), R11
	0x0059 00089 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	MOVQ	(R10)(R9*1), R10
	0x005d 00093 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	NOP
	0x0060 00096 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	CMPQ	R11, $6
	0x0064 00100 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	JNE	229
	0x0066 00102 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	CMPL	(R10), $1970416941
	0x006d 00109 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	JNE	229
	0x006f 00111 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	CMPW	4(R10), $29550
	0x0076 00118 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	JNE	229
	0x0078 00120 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:23)	INCQ	AX
	0x007b 00123 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:23)	NOP
	0x0080 00128 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:24)	CMPQ	R8, AX
	0x0083 00131 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:24)	JLE	397
	0x0089 00137 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:27)	JLS	389
	0x008f 00143 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	CX, main.positional.cap+80(SP)
	0x0094 00148 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	BX, main.positional.len+72(SP)
	0x0099 00153 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:23)	MOVQ	AX, main.i+88(SP)
	0x009e 00158 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	DX, main.positional.ptr+112(SP)
	0x00a3 00163 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:27)	SHLQ	$4, AX
	0x00a7 00167 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:27)	MOVQ	(AX)(R9*1), DX
	0x00ab 00171 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:27)	MOVQ	8(AX)(R9*1), BX
	0x00b0 00176 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:27)	MOVQ	DX, AX
	0x00b3 00179 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:27)	PCDATA	$1, $1
	0x00b3 00179 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:27)	CALL	strconv.Atoi(SB)
	0x00b8 00184 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:27)	NOP
	0x00c0 00192 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:28)	TESTQ	BX, BX
	0x00c3 00195 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:28)	JNE	365
	0x00c9 00201 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	main.positional.cap+80(SP), CX
	0x00ce 00206 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	main.positional.len+72(SP), BX
	0x00d3 00211 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	main.positional.ptr+112(SP), DX
	0x00d8 00216 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:36)	MOVQ	AX, SI
	0x00db 00219 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:21)	MOVQ	main.i+88(SP), AX
	0x00e0 00224 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:32)	JMP	41
	0x00e5 00229 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	INCQ	BX
	0x00e8 00232 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	CMPQ	CX, BX
	0x00eb 00235 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	JCC	300
	0x00ed 00237 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:21)	MOVQ	AX, main..autotmp_19+104(SP)
	0x00f2 00242 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	MOVQ	R10, main..autotmp_20+120(SP)
	0x00f7 00247 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	MOVQ	R11, main..autotmp_21+96(SP)
	0x00fc 00252 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:36)	MOVQ	SI, main.runs+64(SP)
	0x0101 00257 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	DX, AX
	0x0104 00260 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVL	$1, DI
	0x0109 00265 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	LEAQ	type:string(SB), SI
	0x0110 00272 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	PCDATA	$1, $2
	0x0110 00272 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	CALL	runtime.growslice(SB)
	0x0115 00277 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:36)	MOVQ	main.runs+64(SP), SI
	0x011a 00282 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	main..autotmp_20+120(SP), R10
	0x011f 00287 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	main..autotmp_21+96(SP), R11
	0x0124 00292 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	AX, DX
	0x0127 00295 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:21)	MOVQ	main..autotmp_19+104(SP), AX
	0x012c 00300 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	LEAQ	-1(BX), R8
	0x0130 00304 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	SHLQ	$4, R8
	0x0134 00308 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	R11, 8(DX)(R8*1)
	0x0139 00313 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	CMPL	runtime.writeBarrier(SB), $0
	0x0140 00320 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	PCDATA	$0, $-2
	0x0140 00320 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	JEQ	338
	0x0142 00322 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	CALL	runtime.gcWriteBarrier2(SB)
	0x0147 00327 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	R10, (R11)
	0x014a 00330 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	(DX)(R8*1), R9
	0x014e 00334 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	R9, 8(R11)
	0x0152 00338 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	MOVQ	R10, (DX)(R8*1)
	0x0156 00342 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	PCDATA	$0, $-1
	0x0156 00342 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:34)	JMP	41
	0x015b 00347 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:36)	MOVQ	SI, AX
	0x015e 00350 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:36)	MOVQ	CX, DI
	0x0161 00353 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:36)	MOVQ	BX, CX
	0x0164 00356 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:36)	MOVQ	DX, BX
	0x0167 00359 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:36)	SUBQ	$-128, SP
	0x016b 00363 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:36)	POPQ	BP
	0x016c 00364 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:36)	RET
	0x016d 00365 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:29)	LEAQ	type:string(SB), AX
	0x0174 00372 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:29)	LEAQ	main..stmp_1(SB), BX
	0x017b 00379 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:29)	PCDATA	$1, $0
	0x017b 00379 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:29)	NOP
	0x0180 00384 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:29)	CALL	runtime.gopanic(SB)
	0x0185 00389 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:27)	MOVQ	R8, CX
	0x0188 00392 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:27)	CALL	runtime.panicIndex(SB)
	0x018d 00397 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:25)	LEAQ	type:string(SB), AX
	0x0194 00404 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:25)	LEAQ	main..stmp_0(SB), BX
	0x019b 00411 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:25)	NOP
	0x01a0 00416 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:25)	CALL	runtime.gopanic(SB)
	0x01a5 00421 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	MOVQ	R8, CX
	0x01a8 00424 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	CALL	runtime.panicIndex(SB)
	0x01ad 00429 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	XCHGL	AX, AX
	0x01ae 00430 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:22)	NOP
	0x01ae 00430 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	PCDATA	$1, $-1
	0x01ae 00430 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	PCDATA	$0, $-2
	0x01ae 00430 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	CALL	runtime.morestack_noctxt(SB)
	0x01b3 00435 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	PCDATA	$0, $-1
	0x01b3 00435 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:18)	JMP	0
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
main.main STEXT size=601 args=0x0 locals=0xb8 funcid=0x0 align=0x0
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	TEXT	main.main(SB), ABIInternal, $184-0
	0x0000 00000 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	LEAQ	-56(SP), R12
	0x0005 00005 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	CMPQ	R12, 16(R14)
	0x0009 00009 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	PCDATA	$0, $-2
	0x0009 00009 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	JLS	591
	0x000f 00015 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	PCDATA	$0, $-1
	0x000f 00015 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	PUSHQ	BP
	0x0010 00016 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	MOVQ	SP, BP
	0x0013 00019 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	SUBQ	$176, SP
	0x001a 00026 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	FUNCDATA	$0, gclocals·DsEZEqsV1VFgO2VgUUolkQ==(SB)
	0x001a 00026 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	FUNCDATA	$1, gclocals·O8bwXYvGruDmf9lU8HyB8Q==(SB)
	0x001a 00026 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	FUNCDATA	$2, main.main.stkobj(SB)
	0x001a 00026 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:40)	PCDATA	$1, $0
	0x001a 00026 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:40)	CALL	main.parseArgs(SB)
	0x001f 00031 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:40)	MOVQ	AX, main.runs+64(SP)
	0x0024 00036 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:43)	TESTQ	CX, CX
	0x0027 00039 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:43)	JNE	48
	0x0029 00041 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:43)	MOVL	$400, DX
	0x002e 00046 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:43)	JMP	116
	0x0030 00048 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:40)	MOVQ	CX, main.positional.len+72(SP)
	0x0035 00053 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:40)	MOVQ	BX, main.positional.ptr+128(SP)
	0x003d 00061 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:44)	MOVQ	(BX), AX
	0x0040 00064 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:44)	MOVQ	8(BX), DX
	0x0044 00068 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:44)	MOVL	$10, CX
	0x0049 00073 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:44)	MOVL	$64, DI
	0x004e 00078 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:44)	MOVQ	DX, BX
	0x0051 00081 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:44)	PCDATA	$1, $1
	0x0051 00081 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:44)	CALL	strconv.ParseInt(SB)
	0x0056 00086 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:45)	TESTQ	BX, BX
	0x0059 00089 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:45)	JNE	571
	0x005f 00095 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:50)	MOVQ	main.positional.len+72(SP), CX
	0x0064 00100 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:51)	MOVQ	main.positional.ptr+128(SP), BX
	0x006c 00108 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:58)	MOVQ	AX, DX
	0x006f 00111 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:61)	MOVQ	main.runs+64(SP), AX
	0x0074 00116 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:58)	MOVQ	DX, main.n0+80(SP)
	0x0079 00121 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:50)	CMPQ	CX, $1
	0x007d 00125 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:50)	JGT	131
	0x007f 00127 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:50)	XORL	CX, CX
	0x0081 00129 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:50)	JMP	177
	0x0083 00131 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:51)	MOVQ	16(BX), AX
	0x0087 00135 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:51)	MOVQ	24(BX), BX
	0x008b 00139 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:51)	MOVL	$10, CX
	0x0090 00144 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:51)	MOVL	$64, DI
	0x0095 00149 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:51)	PCDATA	$1, $0
	0x0095 00149 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:51)	CALL	strconv.ParseInt(SB)
	0x009a 00154 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:51)	NOP
	0x00a0 00160 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:52)	TESTQ	BX, BX
	0x00a3 00163 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:52)	JNE	552
	0x00a9 00169 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:58)	MOVQ	main.n0+80(SP), DX
	0x00ae 00174 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:58)	MOVQ	AX, CX
	0x00b1 00177 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:58)	MOVQ	CX, main.acc0+104(SP)
	0x00b6 00182 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:58)	MOVQ	DX, AX
	0x00b9 00185 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:58)	MOVQ	CX, BX
	0x00bc 00188 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:58)	NOP
	0x00c0 00192 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:58)	CALL	main.sumRefined(SB)
	0x00c5 00197 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:61)	MOVQ	main.runs+64(SP), AX
	0x00ca 00202 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:61)	XORL	CX, CX
	0x00cc 00204 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:61)	MOVSD	$f64.43e0000000000000(SB), X0
	0x00d4 00212 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:61)	JMP	227
	0x00d6 00214 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:61)	MOVQ	main.i+88(SP), AX
	0x00db 00219 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:61)	DECQ	AX
	0x00de 00222 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:70)	MOVQ	main.value+56(SP), CX
	0x00e3 00227 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:71)	MOVSD	X0, main.best+96(SP)
	0x00e9 00233 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:61)	TESTQ	AX, AX
	0x00ec 00236 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:61)	JLE	349
	0x00ee 00238 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:61)	MOVQ	AX, main.i+88(SP)
	0x00f3 00243 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:62)	CALL	time.Now(SB)
	0x00f8 00248 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:62)	MOVQ	AX, main..autotmp_70+120(SP)
	0x00fd 00253 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:62)	MOVQ	BX, main..autotmp_71+112(SP)
	0x0102 00258 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:62)	MOVQ	CX, main..autotmp_72+136(SP)
	0x010a 00266 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:63)	MOVQ	main.n0+80(SP), AX
	0x010f 00271 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:63)	MOVQ	main.acc0+104(SP), BX
	0x0114 00276 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:63)	PCDATA	$1, $2
	0x0114 00276 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:63)	CALL	main.sumRefined(SB)
	0x0119 00281 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:63)	MOVQ	AX, main.value+56(SP)
	0x011e 00286 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:64)	MOVQ	main..autotmp_71+112(SP), BX
	0x0123 00291 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:64)	MOVQ	main..autotmp_72+136(SP), CX
	0x012b 00299 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:64)	MOVQ	main..autotmp_70+120(SP), AX
	0x0130 00304 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:64)	PCDATA	$1, $0
	0x0130 00304 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:64)	CALL	time.Since(SB)
	0x0135 00309 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:64)	XORPS	X0, X0
	0x0138 00312 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:64)	CVTSQ2SD	AX, X0
	0x013d 00317 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:64)	MOVSD	$f64.408f400000000000(SB), X1
	0x0145 00325 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:64)	DIVSD	X1, X0
	0x0149 00329 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:65)	MOVSD	main.best+96(SP), X2
	0x014f 00335 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:65)	UCOMISD	X0, X2
	0x0153 00339 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:65)	JHI	214
	0x0155 00341 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:71)	MOVUPS	X2, X0
	0x0158 00344 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:65)	JMP	214
	0x015d 00349 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:70)	MOVUPS	X15, main..autotmp_39+160(SP)
	0x0166 00358 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:70)	MOVQ	CX, AX
	0x0169 00361 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:70)	PCDATA	$1, $3
	0x0169 00361 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:70)	CALL	runtime.convT64(SB)
	0x016e 00366 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:70)	LEAQ	type:int64(SB), CX
	0x0175 00373 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:70)	MOVQ	CX, main..autotmp_39+160(SP)
	0x017d 00381 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:70)	MOVQ	AX, main..autotmp_39+168(SP)
	0x0185 00389 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:71)	MOVSD	main.best+96(SP), X0
	0x018b 00395 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:71)	MOVQ	X0, CX
	0x0190 00400 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:71)	MOVQ	CX, main..autotmp_70+120(SP)
	0x0195 00405 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVQ	os.Stdout(SB), BX
	0x019c 00412 (<unknown line number>)	NOP
	0x019c 00412 (/usr/lib/go-1.22/src/fmt/print.go:233)	LEAQ	go:itab.*os.File,io.Writer(SB), AX
	0x01a3 00419 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVL	$10, DI
	0x01a8 00424 (/usr/lib/go-1.22/src/fmt/print.go:233)	LEAQ	main..autotmp_39+160(SP), SI
	0x01b0 00432 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVL	$1, R8
	0x01b6 00438 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVQ	R8, R9
	0x01b9 00441 (/usr/lib/go-1.22/src/fmt/print.go:233)	LEAQ	go:string."value: %d\n"(SB), CX
	0x01c0 00448 (/usr/lib/go-1.22/src/fmt/print.go:233)	PCDATA	$1, $0
	0x01c0 00448 (/usr/lib/go-1.22/src/fmt/print.go:233)	CALL	fmt.Fprintf(SB)
	0x01c5 00453 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:71)	MOVUPS	X15, main..autotmp_42+144(SP)
	0x01ce 00462 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:71)	MOVQ	main..autotmp_70+120(SP), AX
	0x01d3 00467 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:71)	PCDATA	$1, $4
	0x01d3 00467 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:71)	CALL	runtime.convT64(SB)
	0x01d8 00472 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:71)	LEAQ	type:float64(SB), CX
	0x01df 00479 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:71)	MOVQ	CX, main..autotmp_42+144(SP)
	0x01e7 00487 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:71)	MOVQ	AX, main..autotmp_42+152(SP)
	0x01ef 00495 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVQ	os.Stdout(SB), BX
	0x01f6 00502 (<unknown line number>)	NOP
	0x01f6 00502 (/usr/lib/go-1.22/src/fmt/print.go:233)	LEAQ	go:itab.*os.File,io.Writer(SB), AX
	0x01fd 00509 (/usr/lib/go-1.22/src/fmt/print.go:233)	LEAQ	go:string."best_us: %.3f\n"(SB), CX
	0x0204 00516 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVL	$14, DI
	0x0209 00521 (/usr/lib/go-1.22/src/fmt/print.go:233)	LEAQ	main..autotmp_42+144(SP), SI
	0x0211 00529 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVL	$1, R8
	0x0217 00535 (/usr/lib/go-1.22/src/fmt/print.go:233)	MOVQ	R8, R9
	0x021a 00538 (/usr/lib/go-1.22/src/fmt/print.go:233)	PCDATA	$1, $0
	0x021a 00538 (/usr/lib/go-1.22/src/fmt/print.go:233)	CALL	fmt.Fprintf(SB)
	0x021f 00543 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:72)	ADDQ	$176, SP
	0x0226 00550 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:72)	POPQ	BP
	0x0227 00551 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:72)	RET
	0x0228 00552 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:53)	LEAQ	type:string(SB), AX
	0x022f 00559 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:53)	LEAQ	main..stmp_3(SB), BX
	0x0236 00566 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:53)	CALL	runtime.gopanic(SB)
	0x023b 00571 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:46)	LEAQ	type:string(SB), AX
	0x0242 00578 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:46)	LEAQ	main..stmp_2(SB), BX
	0x0249 00585 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:46)	CALL	runtime.gopanic(SB)
	0x024e 00590 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:46)	XCHGL	AX, AX
	0x024f 00591 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:46)	NOP
	0x024f 00591 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	PCDATA	$1, $-1
	0x024f 00591 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	PCDATA	$0, $-2
	0x024f 00591 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	CALL	runtime.morestack_noctxt(SB)
	0x0254 00596 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	PCDATA	$0, $-1
	0x0254 00596 (/mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go:39)	JMP	0
	0x0000 4c 8d 64 24 c8 4d 3b 66 10 0f 86 40 02 00 00 55  L.d$.M;f...@...U
	0x0010 48 89 e5 48 81 ec b0 00 00 00 e8 00 00 00 00 48  H..H...........H
	0x0020 89 44 24 40 48 85 c9 75 07 ba 90 01 00 00 eb 44  .D$@H..u.......D
	0x0030 48 89 4c 24 48 48 89 9c 24 80 00 00 00 48 8b 03  H.L$HH..$....H..
	0x0040 48 8b 53 08 b9 0a 00 00 00 bf 40 00 00 00 48 89  H.S.......@...H.
	0x0050 d3 e8 00 00 00 00 48 85 db 0f 85 dc 01 00 00 48  ......H........H
	0x0060 8b 4c 24 48 48 8b 9c 24 80 00 00 00 48 89 c2 48  .L$HH..$....H..H
	0x0070 8b 44 24 40 48 89 54 24 50 48 83 f9 01 7f 04 31  .D$@H.T$PH.....1
	0x0080 c9 eb 2e 48 8b 43 10 48 8b 5b 18 b9 0a 00 00 00  ...H.C.H.[......
	0x0090 bf 40 00 00 00 e8 00 00 00 00 66 0f 1f 44 00 00  .@........f..D..
	0x00a0 48 85 db 0f 85 7f 01 00 00 48 8b 54 24 50 48 89  H........H.T$PH.
	0x00b0 c1 48 89 4c 24 68 48 89 d0 48 89 cb 0f 1f 40 00  .H.L$hH..H....@.
	0x00c0 e8 00 00 00 00 48 8b 44 24 40 31 c9 f2 0f 10 05  .....H.D$@1.....
	0x00d0 00 00 00 00 eb 0d 48 8b 44 24 58 48 ff c8 48 8b  ......H.D$XH..H.
	0x00e0 4c 24 38 f2 0f 11 44 24 60 48 85 c0 7e 6f 48 89  L$8...D$`H..~oH.
	0x00f0 44 24 58 e8 00 00 00 00 48 89 44 24 78 48 89 5c  D$X.....H.D$xH.\
	0x0100 24 70 48 89 8c 24 88 00 00 00 48 8b 44 24 50 48  $pH..$....H.D$PH
	0x0110 8b 5c 24 68 e8 00 00 00 00 48 89 44 24 38 48 8b  .\$h.....H.D$8H.
	0x0120 5c 24 70 48 8b 8c 24 88 00 00 00 48 8b 44 24 78  \$pH..$....H.D$x
	0x0130 e8 00 00 00 00 0f 57 c0 f2 48 0f 2a c0 f2 0f 10  ......W..H.*....
	0x0140 0d 00 00 00 00 f2 0f 5e c1 f2 0f 10 54 24 60 66  .......^....T$`f
	0x0150 0f 2e d0 77 81 0f 10 c2 e9 79 ff ff ff 44 0f 11  ...w.....y...D..
	0x0160 bc 24 a0 00 00 00 48 89 c8 e8 00 00 00 00 48 8d  .$....H.......H.
	0x0170 0d 00 00 00 00 48 89 8c 24 a0 00 00 00 48 89 84  .....H..$....H..
	0x0180 24 a8 00 00 00 f2 0f 10 44 24 60 66 48 0f 7e c1  $.......D$`fH.~.
	0x0190 48 89 4c 24 78 48 8b 1d 00 00 00 00 48 8d 05 00  H.L$xH......H...
	0x01a0 00 00 00 bf 0a 00 00 00 48 8d b4 24 a0 00 00 00  ........H..$....
	0x01b0 41 b8 01 00 00 00 4d 89 c1 48 8d 0d 00 00 00 00  A.....M..H......
	0x01c0 e8 00 00 00 00 44 0f 11 bc 24 90 00 00 00 48 8b  .....D...$....H.
	0x01d0 44 24 78 e8 00 00 00 00 48 8d 0d 00 00 00 00 48  D$x.....H......H
	0x01e0 89 8c 24 90 00 00 00 48 89 84 24 98 00 00 00 48  ..$....H..$....H
	0x01f0 8b 1d 00 00 00 00 48 8d 05 00 00 00 00 48 8d 0d  ......H......H..
	0x0200 00 00 00 00 bf 0e 00 00 00 48 8d b4 24 90 00 00  .........H..$...
	0x0210 00 41 b8 01 00 00 00 4d 89 c1 e8 00 00 00 00 48  .A.....M.......H
	0x0220 81 c4 b0 00 00 00 5d c3 48 8d 05 00 00 00 00 48  ......].H......H
	0x0230 8d 1d 00 00 00 00 e8 00 00 00 00 48 8d 05 00 00  ...........H....
	0x0240 00 00 48 8d 1d 00 00 00 00 e8 00 00 00 00 90 e8  ..H.............
	0x0250 00 00 00 00 e9 a7 fd ff ff                       .........
	rel 3+0 t=R_USEIFACE type:string+0
	rel 3+0 t=R_USEIFACE type:string+0
	rel 3+0 t=R_USEIFACE type:int64+0
	rel 3+0 t=R_USEIFACE type:*os.File+0
	rel 3+0 t=R_USEIFACE type:float64+0
	rel 3+0 t=R_USEIFACE type:*os.File+0
	rel 27+4 t=R_CALL main.parseArgs+0
	rel 82+4 t=R_CALL strconv.ParseInt+0
	rel 150+4 t=R_CALL strconv.ParseInt+0
	rel 193+4 t=R_CALL main.sumRefined+0
	rel 208+4 t=R_PCREL $f64.43e0000000000000+0
	rel 244+4 t=R_CALL time.Now+0
	rel 277+4 t=R_CALL main.sumRefined+0
	rel 305+4 t=R_CALL time.Since+0
	rel 321+4 t=R_PCREL $f64.408f400000000000+0
	rel 362+4 t=R_CALL runtime.convT64+0
	rel 369+4 t=R_PCREL type:int64+0
	rel 408+4 t=R_PCREL os.Stdout+0
	rel 415+4 t=R_PCREL go:itab.*os.File,io.Writer+0
	rel 444+4 t=R_PCREL go:string."value: %d\n"+0
	rel 449+4 t=R_CALL fmt.Fprintf+0
	rel 468+4 t=R_CALL runtime.convT64+0
	rel 475+4 t=R_PCREL type:float64+0
	rel 498+4 t=R_PCREL os.Stdout+0
	rel 505+4 t=R_PCREL go:itab.*os.File,io.Writer+0
	rel 512+4 t=R_PCREL go:string."best_us: %.3f\n"+0
	rel 539+4 t=R_CALL fmt.Fprintf+0
	rel 555+4 t=R_PCREL type:string+0
	rel 562+4 t=R_PCREL main..stmp_3+0
	rel 567+4 t=R_CALL runtime.gopanic+0
	rel 574+4 t=R_PCREL type:string+0
	rel 581+4 t=R_PCREL main..stmp_2+0
	rel 586+4 t=R_CALL runtime.gopanic+0
	rel 592+4 t=R_CALL runtime.morestack_noctxt+0
go:cuinfo.producer.main SDWARFCUINFO dupok size=0
	0x0000 72 65 67 61 62 69                                regabi
go:cuinfo.packagename.main SDWARFCUINFO dupok size=0
	0x0000 6d 61 69 6e                                      main
go:info.main.sumRefined.func1$abstract SDWARFABSFCN dupok size=35
	0x0000 05 6d 61 69 6e 2e 73 75 6d 52 65 66 69 6e 65 64  .main.sumRefined
	0x0010 2e 66 75 6e 63 31 00 01 0e 01 13 78 00 00 00 00  .func1.....x....
	0x0020 00 00 00                                         ...
	rel 30+4 t=R_DWARFSECREF go:info.int64+0
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
go:string."acc must be an integer" SRODATA dupok size=22
	0x0000 61 63 63 20 6d 75 73 74 20 62 65 20 61 6e 20 69  acc must be an i
	0x0010 6e 74 65 67 65 72                                nteger
go:string."value: %d\n" SRODATA dupok size=10
	0x0000 76 61 6c 75 65 3a 20 25 64 0a                    value: %d.
go:string."best_us: %.3f\n" SRODATA dupok size=14
	0x0000 62 65 73 74 5f 75 73 3a 20 25 2e 33 66 0a        best_us: %.3f.
main..stmp_2 SRODATA static size=16
	0x0000 00 00 00 00 00 00 00 00 14 00 00 00 00 00 00 00  ................
	rel 0+8 t=R_ADDR go:string."n must be an integer"+0
main..stmp_3 SRODATA static size=16
	0x0000 00 00 00 00 00 00 00 00 16 00 00 00 00 00 00 00  ................
	rel 0+8 t=R_ADDR go:string."acc must be an integer"+0
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
main.sumRefined.arginfo1 SRODATA static dupok size=5
	0x0000 00 08 08 08 ff                                   .....
main.sumRefined.argliveinfo SRODATA static dupok size=2
	0x0000 00 00                                            ..
main.sumRefined.func1.arginfo1 SRODATA static dupok size=3
	0x0000 00 08 ff                                         ...
main.sumRefined.func1.argliveinfo SRODATA static dupok size=2
	0x0000 00 00                                            ..
gclocals·ykHN0vawYuq1dUW4zEe2gA== SRODATA dupok size=8
	0x0000 03 00 00 00 00 00 00 00                          ........
gclocals·lf0jAOJ5icNqMXtP6rxGWQ== SRODATA dupok size=11
	0x0000 03 00 00 00 02 00 00 00 00 01 02                 ...........
gclocals·DsEZEqsV1VFgO2VgUUolkQ== SRODATA dupok size=8
	0x0000 05 00 00 00 00 00 00 00                          ........
gclocals·O8bwXYvGruDmf9lU8HyB8Q== SRODATA dupok size=13
	0x0000 05 00 00 00 06 00 00 00 00 01 02 20 08           ........... .
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

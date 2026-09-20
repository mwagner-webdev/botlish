TEXT runtime.main.func2(SB) /usr/lib/go-1.22/src/runtime/proc.go
  proc.go:204		0x435c20		493b6610		CMPQ SP, 0x10(R14)
  proc.go:204		0x435c24		7614			JBE 0x435c3a
  proc.go:204		0x435c26		55			PUSHQ BP
  proc.go:204		0x435c27		4889e5			MOVQ SP, BP
  proc.go:204		0x435c2a		488b4208		MOVQ 0x8(DX), AX
  proc.go:205		0x435c2e		803800			CMPB 0(AX), $0x0
  proc.go:205		0x435c31		7405			JE 0x435c38
  proc.go:206		0x435c33		e808a60000		CALL runtime.unlockOSThread(SB)
  proc.go:208		0x435c38		5d			POPQ BP
  proc.go:208		0x435c39		c3			RET
  proc.go:204		0x435c3a		e821a90200		CALL runtime.morestack.abi0(SB)
  proc.go:204		0x435c3f		90			NOPL
  proc.go:204		0x435c40		ebde			JMP runtime.main.func2(SB)

TEXT runtime.main.func1(SB) /usr/lib/go-1.22/src/runtime/proc.go
  proc.go:171		0x45d220		493b6610		CMPQ SP, 0x10(R14)
  proc.go:171		0x45d224		7625			JBE 0x45d24b
  proc.go:171		0x45d226		55			PUSHQ BP
  proc.go:171		0x45d227		4889e5			MOVQ SP, BP
  proc.go:171		0x45d22a		4883ec18		SUBQ $0x18, SP
  proc.go:172		0x45d22e		488d05f3a30400		LEAQ 0x4a3f3(IP), AX
  proc.go:172		0x45d235		31db			XORL BX, BX
  proc.go:172		0x45d237		48c7c1ffffffff		MOVQ $-0x1, CX
  proc.go:172		0x45d23e		6690			NOPW
  proc.go:172		0x45d240		e87bcdfdff		CALL runtime.newm(SB)
  proc.go:173		0x45d245		4883c418		ADDQ $0x18, SP
  proc.go:173		0x45d249		5d			POPQ BP
  proc.go:173		0x45d24a		c3			RET
  proc.go:171		0x45d24b		e890330000		CALL runtime.morestack_noctxt.abi0(SB)
  proc.go:171		0x45d250		ebce			JMP runtime.main.func1(SB)

TEXT main.sumRefined(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go
  sum_refined.go:10	0x483bc0		493b6610		CMPQ SP, 0x10(R14)
  sum_refined.go:10	0x483bc4		762b			JBE 0x483bf1
  sum_refined.go:10	0x483bc6		55			PUSHQ BP
  sum_refined.go:10	0x483bc7		4889e5			MOVQ SP, BP
  sum_refined.go:10	0x483bca		4883ec10		SUBQ $0x10, SP
  sum_refined.go:11	0x483bce		4885c0			TESTQ AX, AX
  sum_refined.go:11	0x483bd1		7509			JNE 0x483bdc
  sum_refined.go:12	0x483bd3		4889d8			MOVQ BX, AX
  sum_refined.go:12	0x483bd6		4883c410		ADDQ $0x10, SP
  sum_refined.go:12	0x483bda		5d			POPQ BP
  sum_refined.go:12	0x483bdb		c3			RET
  sum_refined.go:15	0x483bdc		488d48ff		LEAQ -0x1(AX), CX
  sum_refined.go:14	0x483be0		4801c3			ADDQ AX, BX
  sum_refined.go:15	0x483be3		4889c8			MOVQ CX, AX
  sum_refined.go:15	0x483be6		e8d5ffffff		CALL main.sumRefined(SB)
  sum_refined.go:15	0x483beb		4883c410		ADDQ $0x10, SP
  sum_refined.go:15	0x483bef		5d			POPQ BP
  sum_refined.go:15	0x483bf0		c3			RET
  sum_refined.go:10	0x483bf1		4889442408		MOVQ AX, 0x8(SP)
  sum_refined.go:10	0x483bf6		48895c2410		MOVQ BX, 0x10(SP)
  sum_refined.go:10	0x483bfb		0f1f440000		NOPL 0(AX)(AX*1)
  sum_refined.go:10	0x483c00		e8dbc9fdff		CALL runtime.morestack_noctxt.abi0(SB)
  sum_refined.go:10	0x483c05		488b442408		MOVQ 0x8(SP), AX
  sum_refined.go:10	0x483c0a		488b5c2410		MOVQ 0x10(SP), BX
  sum_refined.go:10	0x483c0f		ebaf			JMP main.sumRefined(SB)

TEXT main.parseArgs(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go
  sum_refined.go:18	0x483c20		4c8d6424f8		LEAQ -0x8(SP), R12
  sum_refined.go:18	0x483c25		4d3b6610		CMPQ R12, 0x10(R14)
  sum_refined.go:18	0x483c29		0f869f010000		JBE 0x483dce
  sum_refined.go:18	0x483c2f		55			PUSHQ BP
  sum_refined.go:18	0x483c30		4889e5			MOVQ SP, BP
  sum_refined.go:18	0x483c33		4883c480		ADDQ $-0x80, SP
  sum_refined.go:18	0x483c37		b801000000		MOVL $0x1, AX
  sum_refined.go:18	0x483c3c		31c9			XORL CX, CX
  sum_refined.go:18	0x483c3e		31d2			XORL DX, DX
  sum_refined.go:18	0x483c40		31db			XORL BX, BX
  sum_refined.go:18	0x483c42		be05000000		MOVL $0x5, SI
  sum_refined.go:21	0x483c47		eb03			JMP 0x483c4c
  sum_refined.go:21	0x483c49		48ffc0			INCQ AX
  sum_refined.go:21	0x483c4c		4c8b05c5fe0a00		MOVQ os.Args+8(SB), R8
  sum_refined.go:21	0x483c53		4c39c0			CMPQ AX, R8
  sum_refined.go:21	0x483c56		0f8d1f010000		JGE 0x483d7b
  sum_refined.go:21	0x483c5c		0f1f4000		NOPL 0(AX)
  sum_refined.go:22	0x483c60		0f835f010000		JAE 0x483dc5
  sum_refined.go:21	0x483c66		4c8b0da3fe0a00		MOVQ os.Args(SB), R9
  sum_refined.go:22	0x483c6d		4989c2			MOVQ AX, R10
  sum_refined.go:22	0x483c70		49c1e204		SHLQ $0x4, R10
  sum_refined.go:22	0x483c74		4f8b5c0a08		MOVQ 0x8(R10)(R9*1), R11
  sum_refined.go:22	0x483c79		4f8b140a		MOVQ 0(R10)(R9*1), R10
  sum_refined.go:22	0x483c7d		0f1f00			NOPL 0(AX)
  sum_refined.go:22	0x483c80		4983fb06		CMPQ R11, $0x6
  sum_refined.go:22	0x483c84		757f			JNE 0x483d05
  sum_refined.go:22	0x483c86		41813a2d2d7275		CMPL 0(R10), $0x75722d2d
  sum_refined.go:22	0x483c8d		7576			JNE 0x483d05
  sum_refined.go:22	0x483c8f		6641817a046e73		CMPW 0x4(R10), $0x736e
  sum_refined.go:22	0x483c96		756d			JNE 0x483d05
  sum_refined.go:23	0x483c98		48ffc0			INCQ AX
  sum_refined.go:23	0x483c9b		0f1f440000		NOPL 0(AX)(AX*1)
  sum_refined.go:24	0x483ca0		4939c0			CMPQ R8, AX
  sum_refined.go:24	0x483ca3		0f8e04010000		JLE 0x483dad
  sum_refined.go:27	0x483ca9		0f86f6000000		JBE 0x483da5
  sum_refined.go:34	0x483caf		48894c2450		MOVQ CX, 0x50(SP)
  sum_refined.go:34	0x483cb4		48895c2448		MOVQ BX, 0x48(SP)
  sum_refined.go:23	0x483cb9		4889442458		MOVQ AX, 0x58(SP)
  sum_refined.go:34	0x483cbe		4889542470		MOVQ DX, 0x70(SP)
  sum_refined.go:27	0x483cc3		48c1e004		SHLQ $0x4, AX
  sum_refined.go:27	0x483cc7		4a8b1408		MOVQ 0(AX)(R9*1), DX
  sum_refined.go:27	0x483ccb		4a8b5c0808		MOVQ 0x8(AX)(R9*1), BX
  sum_refined.go:27	0x483cd0		4889d0			MOVQ DX, AX
  sum_refined.go:27	0x483cd3		e88843feff		CALL strconv.Atoi(SB)
  sum_refined.go:27	0x483cd8		0f1f840000000000	NOPL 0(AX)(AX*1)
  sum_refined.go:28	0x483ce0		4885db			TESTQ BX, BX
  sum_refined.go:28	0x483ce3		0f85a4000000		JNE 0x483d8d
  sum_refined.go:34	0x483ce9		488b4c2450		MOVQ 0x50(SP), CX
  sum_refined.go:34	0x483cee		488b5c2448		MOVQ 0x48(SP), BX
  sum_refined.go:34	0x483cf3		488b542470		MOVQ 0x70(SP), DX
  sum_refined.go:36	0x483cf8		4889c6			MOVQ AX, SI
  sum_refined.go:21	0x483cfb		488b442458		MOVQ 0x58(SP), AX
  sum_refined.go:32	0x483d00		e944ffffff		JMP 0x483c49
  sum_refined.go:34	0x483d05		48ffc3			INCQ BX
  sum_refined.go:34	0x483d08		4839d9			CMPQ CX, BX
  sum_refined.go:34	0x483d0b		733f			JAE 0x483d4c
  sum_refined.go:21	0x483d0d		4889442468		MOVQ AX, 0x68(SP)
  sum_refined.go:22	0x483d12		4c89542478		MOVQ R10, 0x78(SP)
  sum_refined.go:22	0x483d17		4c895c2460		MOVQ R11, 0x60(SP)
  sum_refined.go:36	0x483d1c		4889742440		MOVQ SI, 0x40(SP)
  sum_refined.go:34	0x483d21		4889d0			MOVQ DX, AX
  sum_refined.go:34	0x483d24		bf01000000		MOVL $0x1, DI
  sum_refined.go:34	0x483d29		488d3550850000		LEAQ 0x8550(IP), SI
  sum_refined.go:34	0x483d30		e84b66fcff		CALL runtime.growslice(SB)
  sum_refined.go:36	0x483d35		488b742440		MOVQ 0x40(SP), SI
  sum_refined.go:34	0x483d3a		4c8b542478		MOVQ 0x78(SP), R10
  sum_refined.go:34	0x483d3f		4c8b5c2460		MOVQ 0x60(SP), R11
  sum_refined.go:34	0x483d44		4889c2			MOVQ AX, DX
  sum_refined.go:21	0x483d47		488b442468		MOVQ 0x68(SP), AX
  sum_refined.go:34	0x483d4c		4c8d43ff		LEAQ -0x1(BX), R8
  sum_refined.go:34	0x483d50		49c1e004		SHLQ $0x4, R8
  sum_refined.go:34	0x483d54		4e895c0208		MOVQ R11, 0x8(DX)(R8*1)
  sum_refined.go:34	0x483d59		833d40f9100000		CMPL runtime.writeBarrier(SB), $0x0
  sum_refined.go:34	0x483d60		7410			JE 0x483d72
  sum_refined.go:34	0x483d62		e8f9e5fdff		CALL runtime.gcWriteBarrier2(SB)
  sum_refined.go:34	0x483d67		4d8913			MOVQ R10, 0(R11)
  sum_refined.go:34	0x483d6a		4e8b0c02		MOVQ 0(DX)(R8*1), R9
  sum_refined.go:34	0x483d6e		4d894b08		MOVQ R9, 0x8(R11)
  sum_refined.go:34	0x483d72		4e891402		MOVQ R10, 0(DX)(R8*1)
  sum_refined.go:34	0x483d76		e9cefeffff		JMP 0x483c49
  sum_refined.go:36	0x483d7b		4889f0			MOVQ SI, AX
  sum_refined.go:36	0x483d7e		4889cf			MOVQ CX, DI
  sum_refined.go:36	0x483d81		4889d9			MOVQ BX, CX
  sum_refined.go:36	0x483d84		4889d3			MOVQ DX, BX
  sum_refined.go:36	0x483d87		4883ec80		SUBQ $-0x80, SP
  sum_refined.go:36	0x483d8b		5d			POPQ BP
  sum_refined.go:36	0x483d8c		c3			RET
  sum_refined.go:29	0x483d8d		488d05ec840000		LEAQ 0x84ec(IP), AX
  sum_refined.go:29	0x483d94		488d1d1dcd0300		LEAQ 0x3cd1d(IP), BX
  sum_refined.go:29	0x483d9b		0f1f440000		NOPL 0(AX)(AX*1)
  sum_refined.go:29	0x483da0		e81be6faff		CALL runtime.gopanic(SB)
  sum_refined.go:27	0x483da5		4c89c1			MOVQ R8, CX
  sum_refined.go:27	0x483da8		e853e9fdff		CALL runtime.panicIndex(SB)
  sum_refined.go:25	0x483dad		488d05cc840000		LEAQ 0x84cc(IP), AX
  sum_refined.go:25	0x483db4		488d1dedcc0300		LEAQ 0x3cced(IP), BX
  sum_refined.go:25	0x483dbb		0f1f440000		NOPL 0(AX)(AX*1)
  sum_refined.go:25	0x483dc0		e8fbe5faff		CALL runtime.gopanic(SB)
  sum_refined.go:22	0x483dc5		4c89c1			MOVQ R8, CX
  sum_refined.go:22	0x483dc8		e833e9fdff		CALL runtime.panicIndex(SB)
  sum_refined.go:22	0x483dcd		90			NOPL
  sum_refined.go:18	0x483dce		e80dc8fdff		CALL runtime.morestack_noctxt.abi0(SB)
  sum_refined.go:18	0x483dd3		e948feffff		JMP main.parseArgs(SB)

TEXT main.main(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/sum_refined.go
  sum_refined.go:39	0x483de0		4c8d6424c8		LEAQ -0x38(SP), R12
  sum_refined.go:39	0x483de5		4d3b6610		CMPQ R12, 0x10(R14)
  sum_refined.go:39	0x483de9		0f8640020000		JBE 0x48402f
  sum_refined.go:39	0x483def		55			PUSHQ BP
  sum_refined.go:39	0x483df0		4889e5			MOVQ SP, BP
  sum_refined.go:39	0x483df3		4881ecb0000000		SUBQ $0xb0, SP
  sum_refined.go:40	0x483dfa		e821feffff		CALL main.parseArgs(SB)
  sum_refined.go:40	0x483dff		4889442440		MOVQ AX, 0x40(SP)
  sum_refined.go:43	0x483e04		4885c9			TESTQ CX, CX
  sum_refined.go:43	0x483e07		7507			JNE 0x483e10
  sum_refined.go:43	0x483e09		ba90010000		MOVL $0x190, DX
  sum_refined.go:43	0x483e0e		eb44			JMP 0x483e54
  sum_refined.go:40	0x483e10		48894c2448		MOVQ CX, 0x48(SP)
  sum_refined.go:40	0x483e15		48899c2480000000	MOVQ BX, 0x80(SP)
  sum_refined.go:44	0x483e1d		488b03			MOVQ 0(BX), AX
  sum_refined.go:44	0x483e20		488b5308		MOVQ 0x8(BX), DX
  sum_refined.go:44	0x483e24		b90a000000		MOVL $0xa, CX
  sum_refined.go:44	0x483e29		bf40000000		MOVL $0x40, DI
  sum_refined.go:44	0x483e2e		4889d3			MOVQ DX, BX
  sum_refined.go:44	0x483e31		e86a3dfeff		CALL strconv.ParseInt(SB)
  sum_refined.go:45	0x483e36		4885db			TESTQ BX, BX
  sum_refined.go:45	0x483e39		0f85dc010000		JNE 0x48401b
  sum_refined.go:50	0x483e3f		488b4c2448		MOVQ 0x48(SP), CX
  sum_refined.go:51	0x483e44		488b9c2480000000	MOVQ 0x80(SP), BX
  sum_refined.go:58	0x483e4c		4889c2			MOVQ AX, DX
  sum_refined.go:61	0x483e4f		488b442440		MOVQ 0x40(SP), AX
  sum_refined.go:58	0x483e54		4889542450		MOVQ DX, 0x50(SP)
  sum_refined.go:50	0x483e59		4883f901		CMPQ CX, $0x1
  sum_refined.go:50	0x483e5d		7f04			JG 0x483e63
  sum_refined.go:50	0x483e5f		31c9			XORL CX, CX
  sum_refined.go:50	0x483e61		eb2e			JMP 0x483e91
  sum_refined.go:51	0x483e63		488b4310		MOVQ 0x10(BX), AX
  sum_refined.go:51	0x483e67		488b5b18		MOVQ 0x18(BX), BX
  sum_refined.go:51	0x483e6b		b90a000000		MOVL $0xa, CX
  sum_refined.go:51	0x483e70		bf40000000		MOVL $0x40, DI
  sum_refined.go:51	0x483e75		e8263dfeff		CALL strconv.ParseInt(SB)
  sum_refined.go:51	0x483e7a		660f1f440000		NOPW 0(AX)(AX*1)
  sum_refined.go:52	0x483e80		4885db			TESTQ BX, BX
  sum_refined.go:52	0x483e83		0f857f010000		JNE 0x484008
  sum_refined.go:58	0x483e89		488b542450		MOVQ 0x50(SP), DX
  sum_refined.go:58	0x483e8e		4889c1			MOVQ AX, CX
  sum_refined.go:58	0x483e91		48894c2468		MOVQ CX, 0x68(SP)
  sum_refined.go:58	0x483e96		4889d0			MOVQ DX, AX
  sum_refined.go:58	0x483e99		4889cb			MOVQ CX, BX
  sum_refined.go:58	0x483e9c		0f1f4000		NOPL 0(AX)
  sum_refined.go:58	0x483ea0		e81bfdffff		CALL main.sumRefined(SB)
  sum_refined.go:61	0x483ea5		488b442440		MOVQ 0x40(SP), AX
  sum_refined.go:61	0x483eaa		31c9			XORL CX, CX
  sum_refined.go:61	0x483eac		f20f1005ecca0300	MOVSD_XMM $f64.43e0000000000000(SB), X0
  sum_refined.go:61	0x483eb4		eb0d			JMP 0x483ec3
  sum_refined.go:61	0x483eb6		488b442458		MOVQ 0x58(SP), AX
  sum_refined.go:61	0x483ebb		48ffc8			DECQ AX
  sum_refined.go:70	0x483ebe		488b4c2438		MOVQ 0x38(SP), CX
  sum_refined.go:71	0x483ec3		f20f11442460		MOVSD_XMM X0, 0x60(SP)
  sum_refined.go:61	0x483ec9		4885c0			TESTQ AX, AX
  sum_refined.go:61	0x483ecc		7e6f			JLE 0x483f3d
  sum_refined.go:61	0x483ece		4889442458		MOVQ AX, 0x58(SP)
  sum_refined.go:62	0x483ed3		e8884effff		CALL time.Now(SB)
  sum_refined.go:62	0x483ed8		4889442478		MOVQ AX, 0x78(SP)
  sum_refined.go:62	0x483edd		48895c2470		MOVQ BX, 0x70(SP)
  sum_refined.go:62	0x483ee2		48898c2488000000	MOVQ CX, 0x88(SP)
  sum_refined.go:63	0x483eea		488b442450		MOVQ 0x50(SP), AX
  sum_refined.go:63	0x483eef		488b5c2468		MOVQ 0x68(SP), BX
  sum_refined.go:63	0x483ef4		e8c7fcffff		CALL main.sumRefined(SB)
  sum_refined.go:63	0x483ef9		4889442438		MOVQ AX, 0x38(SP)
  sum_refined.go:64	0x483efe		488b5c2470		MOVQ 0x70(SP), BX
  sum_refined.go:64	0x483f03		488b8c2488000000	MOVQ 0x88(SP), CX
  sum_refined.go:64	0x483f0b		488b442478		MOVQ 0x78(SP), AX
  sum_refined.go:64	0x483f10		e88b4dffff		CALL time.Since(SB)
  sum_refined.go:64	0x483f15		0f57c0			XORPS X0, X0
  sum_refined.go:64	0x483f18		f2480f2ac0		CVTSI2SDQ AX, X0
  sum_refined.go:64	0x483f1d		f20f100d73ca0300	MOVSD_XMM $f64.408f400000000000(SB), X1
  sum_refined.go:64	0x483f25		f20f5ec1		DIVSD X1, X0
  sum_refined.go:65	0x483f29		f20f10542460		MOVSD_XMM 0x60(SP), X2
  sum_refined.go:65	0x483f2f		660f2ed0		UCOMISD X0, X2
  sum_refined.go:65	0x483f33		7781			JA 0x483eb6
  sum_refined.go:71	0x483f35		0f10c2			MOVUPS X2, X0
  sum_refined.go:65	0x483f38		e979ffffff		JMP 0x483eb6
  sum_refined.go:70	0x483f3d		440f11bc24a0000000	MOVUPS X15, 0xa0(SP)
  sum_refined.go:70	0x483f46		4889c8			MOVQ CX, AX
  sum_refined.go:70	0x483f49		e8b269f8ff		CALL runtime.convT64(SB)
  sum_refined.go:70	0x483f4e		488d0deb840000		LEAQ 0x84eb(IP), CX
  sum_refined.go:70	0x483f55		48898c24a0000000	MOVQ CX, 0xa0(SP)
  sum_refined.go:70	0x483f5d		48898424a8000000	MOVQ AX, 0xa8(SP)
  sum_refined.go:71	0x483f65		f20f10442460		MOVSD_XMM 0x60(SP), X0
  sum_refined.go:71	0x483f6b		66480f7ec1		MOVQ X0, CX
  sum_refined.go:71	0x483f70		48894c2478		MOVQ CX, 0x78(SP)
  print.go:233		0x483f75		488b1d2cf90a00		MOVQ os.Stdout(SB), BX
  print.go:233		0x483f7c		488d05c5cf0300		LEAQ go:itab.*os.File,io.Writer(SB), AX
  print.go:233		0x483f83		bf0a000000		MOVL $0xa, DI
  print.go:233		0x483f88		488db424a0000000	LEAQ 0xa0(SP), SI
  print.go:233		0x483f90		41b801000000		MOVL $0x1, R8
  print.go:233		0x483f96		4d89c1			MOVQ R8, R9
  print.go:233		0x483f99		488d0dbbb70100		LEAQ 0x1b7bb(IP), CX
  print.go:233		0x483fa0		e83b94ffff		CALL fmt.Fprintf(SB)
  sum_refined.go:71	0x483fa5		440f11bc2490000000	MOVUPS X15, 0x90(SP)
  sum_refined.go:71	0x483fae		488b442478		MOVQ 0x78(SP), AX
  sum_refined.go:71	0x483fb3		e84869f8ff		CALL runtime.convT64(SB)
  sum_refined.go:71	0x483fb8		488d0d81860000		LEAQ 0x8681(IP), CX
  sum_refined.go:71	0x483fbf		48898c2490000000	MOVQ CX, 0x90(SP)
  sum_refined.go:71	0x483fc7		4889842498000000	MOVQ AX, 0x98(SP)
  print.go:233		0x483fcf		488b1dd2f80a00		MOVQ os.Stdout(SB), BX
  print.go:233		0x483fd6		488d056bcf0300		LEAQ go:itab.*os.File,io.Writer(SB), AX
  print.go:233		0x483fdd		488d0d2ac10100		LEAQ 0x1c12a(IP), CX
  print.go:233		0x483fe4		bf0e000000		MOVL $0xe, DI
  print.go:233		0x483fe9		488db42490000000	LEAQ 0x90(SP), SI
  print.go:233		0x483ff1		41b801000000		MOVL $0x1, R8
  print.go:233		0x483ff7		4d89c1			MOVQ R8, R9
  print.go:233		0x483ffa		e8e193ffff		CALL fmt.Fprintf(SB)
  sum_refined.go:72	0x483fff		4881c4b0000000		ADDQ $0xb0, SP
  sum_refined.go:72	0x484006		5d			POPQ BP
  sum_refined.go:72	0x484007		c3			RET
  sum_refined.go:53	0x484008		488d0571820000		LEAQ 0x8271(IP), AX
  sum_refined.go:53	0x48400f		488d1dc2ca0300		LEAQ 0x3cac2(IP), BX
  sum_refined.go:53	0x484016		e8a5e3faff		CALL runtime.gopanic(SB)
  sum_refined.go:46	0x48401b		488d055e820000		LEAQ 0x825e(IP), AX
  sum_refined.go:46	0x484022		488d1d9fca0300		LEAQ 0x3ca9f(IP), BX
  sum_refined.go:46	0x484029		e892e3faff		CALL runtime.gopanic(SB)
  sum_refined.go:46	0x48402e		90			NOPL
  sum_refined.go:39	0x48402f		e8acc5fdff		CALL runtime.morestack_noctxt.abi0(SB)
  sum_refined.go:39	0x484034		e9a7fdffff		JMP main.main(SB)

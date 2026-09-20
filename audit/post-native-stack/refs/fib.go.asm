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
  proc.go:172		0x45d22e		488d05db930400		LEAQ 0x493db(IP), AX
  proc.go:172		0x45d235		31db			XORL BX, BX
  proc.go:172		0x45d237		48c7c1ffffffff		MOVQ $-0x1, CX
  proc.go:172		0x45d23e		6690			NOPW
  proc.go:172		0x45d240		e87bcdfdff		CALL runtime.newm(SB)
  proc.go:173		0x45d245		4883c418		ADDQ $0x18, SP
  proc.go:173		0x45d249		5d			POPQ BP
  proc.go:173		0x45d24a		c3			RET
  proc.go:171		0x45d24b		e890330000		CALL runtime.morestack_noctxt.abi0(SB)
  proc.go:171		0x45d250		ebce			JMP runtime.main.func1(SB)

TEXT main.fib(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go
  fib.go:10		0x483bc0		493b6610		CMPQ SP, 0x10(R14)
  fib.go:10		0x483bc4		764d			JBE 0x483c13
  fib.go:10		0x483bc6		55			PUSHQ BP
  fib.go:10		0x483bc7		4889e5			MOVQ SP, BP
  fib.go:10		0x483bca		4883ec10		SUBQ $0x10, SP
  fib.go:11		0x483bce		4883f802		CMPQ AX, $0x2
  fib.go:11		0x483bd2		7d06			JGE 0x483bda
  fib.go:12		0x483bd4		4883c410		ADDQ $0x10, SP
  fib.go:12		0x483bd8		5d			POPQ BP
  fib.go:12		0x483bd9		c3			RET
  fib.go:11		0x483bda		4889442420		MOVQ AX, 0x20(SP)
  fib.go:14		0x483bdf		488d48ff		LEAQ -0x1(AX), CX
  fib.go:14		0x483be3		4889c8			MOVQ CX, AX
  fib.go:14		0x483be6		e8d5ffffff		CALL main.fib(SB)
  fib.go:14		0x483beb		4889442408		MOVQ AX, 0x8(SP)
  fib.go:14		0x483bf0		488b4c2420		MOVQ 0x20(SP), CX
  fib.go:14		0x483bf5		4883c1fe		ADDQ $-0x2, CX
  fib.go:14		0x483bf9		4889c8			MOVQ CX, AX
  fib.go:14		0x483bfc		0f1f4000		NOPL 0(AX)
  fib.go:14		0x483c00		e8bbffffff		CALL main.fib(SB)
  fib.go:14		0x483c05		488b4c2408		MOVQ 0x8(SP), CX
  fib.go:14		0x483c0a		4801c8			ADDQ CX, AX
  fib.go:14		0x483c0d		4883c410		ADDQ $0x10, SP
  fib.go:14		0x483c11		5d			POPQ BP
  fib.go:14		0x483c12		c3			RET
  fib.go:10		0x483c13		4889442408		MOVQ AX, 0x8(SP)
  fib.go:10		0x483c18		e8c3c9fdff		CALL runtime.morestack_noctxt.abi0(SB)
  fib.go:10		0x483c1d		488b442408		MOVQ 0x8(SP), AX
  fib.go:10		0x483c22		eb9c			JMP main.fib(SB)

TEXT main.parseArgs(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go
  fib.go:17		0x483c40		4c8d6424f8		LEAQ -0x8(SP), R12
  fib.go:17		0x483c45		4d3b6610		CMPQ R12, 0x10(R14)
  fib.go:17		0x483c49		0f869f010000		JBE 0x483dee
  fib.go:17		0x483c4f		55			PUSHQ BP
  fib.go:17		0x483c50		4889e5			MOVQ SP, BP
  fib.go:17		0x483c53		4883c480		ADDQ $-0x80, SP
  fib.go:17		0x483c57		b801000000		MOVL $0x1, AX
  fib.go:17		0x483c5c		31c9			XORL CX, CX
  fib.go:17		0x483c5e		31d2			XORL DX, DX
  fib.go:17		0x483c60		31db			XORL BX, BX
  fib.go:17		0x483c62		be05000000		MOVL $0x5, SI
  fib.go:20		0x483c67		eb03			JMP 0x483c6c
  fib.go:20		0x483c69		48ffc0			INCQ AX
  fib.go:20		0x483c6c		4c8b05a5ee0a00		MOVQ os.Args+8(SB), R8
  fib.go:20		0x483c73		4c39c0			CMPQ AX, R8
  fib.go:20		0x483c76		0f8d1f010000		JGE 0x483d9b
  fib.go:20		0x483c7c		0f1f4000		NOPL 0(AX)
  fib.go:21		0x483c80		0f835f010000		JAE 0x483de5
  fib.go:20		0x483c86		4c8b0d83ee0a00		MOVQ os.Args(SB), R9
  fib.go:21		0x483c8d		4989c2			MOVQ AX, R10
  fib.go:21		0x483c90		49c1e204		SHLQ $0x4, R10
  fib.go:21		0x483c94		4f8b5c0a08		MOVQ 0x8(R10)(R9*1), R11
  fib.go:21		0x483c99		4f8b140a		MOVQ 0(R10)(R9*1), R10
  fib.go:21		0x483c9d		0f1f00			NOPL 0(AX)
  fib.go:21		0x483ca0		4983fb06		CMPQ R11, $0x6
  fib.go:21		0x483ca4		757f			JNE 0x483d25
  fib.go:21		0x483ca6		41813a2d2d7275		CMPL 0(R10), $0x75722d2d
  fib.go:21		0x483cad		7576			JNE 0x483d25
  fib.go:21		0x483caf		6641817a046e73		CMPW 0x4(R10), $0x736e
  fib.go:21		0x483cb6		756d			JNE 0x483d25
  fib.go:22		0x483cb8		48ffc0			INCQ AX
  fib.go:22		0x483cbb		0f1f440000		NOPL 0(AX)(AX*1)
  fib.go:23		0x483cc0		4939c0			CMPQ R8, AX
  fib.go:23		0x483cc3		0f8e04010000		JLE 0x483dcd
  fib.go:26		0x483cc9		0f86f6000000		JBE 0x483dc5
  fib.go:33		0x483ccf		48894c2450		MOVQ CX, 0x50(SP)
  fib.go:33		0x483cd4		48895c2448		MOVQ BX, 0x48(SP)
  fib.go:22		0x483cd9		4889442458		MOVQ AX, 0x58(SP)
  fib.go:33		0x483cde		4889542470		MOVQ DX, 0x70(SP)
  fib.go:26		0x483ce3		48c1e004		SHLQ $0x4, AX
  fib.go:26		0x483ce7		4a8b1408		MOVQ 0(AX)(R9*1), DX
  fib.go:26		0x483ceb		4a8b5c0808		MOVQ 0x8(AX)(R9*1), BX
  fib.go:26		0x483cf0		4889d0			MOVQ DX, AX
  fib.go:26		0x483cf3		e86843feff		CALL strconv.Atoi(SB)
  fib.go:26		0x483cf8		0f1f840000000000	NOPL 0(AX)(AX*1)
  fib.go:27		0x483d00		4885db			TESTQ BX, BX
  fib.go:27		0x483d03		0f85a4000000		JNE 0x483dad
  fib.go:33		0x483d09		488b4c2450		MOVQ 0x50(SP), CX
  fib.go:33		0x483d0e		488b5c2448		MOVQ 0x48(SP), BX
  fib.go:33		0x483d13		488b542470		MOVQ 0x70(SP), DX
  fib.go:35		0x483d18		4889c6			MOVQ AX, SI
  fib.go:20		0x483d1b		488b442458		MOVQ 0x58(SP), AX
  fib.go:31		0x483d20		e944ffffff		JMP 0x483c69
  fib.go:33		0x483d25		48ffc3			INCQ BX
  fib.go:33		0x483d28		4839d9			CMPQ CX, BX
  fib.go:33		0x483d2b		733f			JAE 0x483d6c
  fib.go:20		0x483d2d		4889442468		MOVQ AX, 0x68(SP)
  fib.go:21		0x483d32		4c89542478		MOVQ R10, 0x78(SP)
  fib.go:21		0x483d37		4c895c2460		MOVQ R11, 0x60(SP)
  fib.go:35		0x483d3c		4889742440		MOVQ SI, 0x40(SP)
  fib.go:33		0x483d41		4889d0			MOVQ DX, AX
  fib.go:33		0x483d44		bf01000000		MOVL $0x1, DI
  fib.go:33		0x483d49		488d3530750000		LEAQ 0x7530(IP), SI
  fib.go:33		0x483d50		e82b66fcff		CALL runtime.growslice(SB)
  fib.go:35		0x483d55		488b742440		MOVQ 0x40(SP), SI
  fib.go:33		0x483d5a		4c8b542478		MOVQ 0x78(SP), R10
  fib.go:33		0x483d5f		4c8b5c2460		MOVQ 0x60(SP), R11
  fib.go:33		0x483d64		4889c2			MOVQ AX, DX
  fib.go:20		0x483d67		488b442468		MOVQ 0x68(SP), AX
  fib.go:33		0x483d6c		4c8d43ff		LEAQ -0x1(BX), R8
  fib.go:33		0x483d70		49c1e004		SHLQ $0x4, R8
  fib.go:33		0x483d74		4e895c0208		MOVQ R11, 0x8(DX)(R8*1)
  fib.go:33		0x483d79		833d20e9100000		CMPL runtime.writeBarrier(SB), $0x0
  fib.go:33		0x483d80		7410			JE 0x483d92
  fib.go:33		0x483d82		e8d9e5fdff		CALL runtime.gcWriteBarrier2(SB)
  fib.go:33		0x483d87		4d8913			MOVQ R10, 0(R11)
  fib.go:33		0x483d8a		4e8b0c02		MOVQ 0(DX)(R8*1), R9
  fib.go:33		0x483d8e		4d894b08		MOVQ R9, 0x8(R11)
  fib.go:33		0x483d92		4e891402		MOVQ R10, 0(DX)(R8*1)
  fib.go:33		0x483d96		e9cefeffff		JMP 0x483c69
  fib.go:35		0x483d9b		4889f0			MOVQ SI, AX
  fib.go:35		0x483d9e		4889cf			MOVQ CX, DI
  fib.go:35		0x483da1		4889d9			MOVQ BX, CX
  fib.go:35		0x483da4		4889d3			MOVQ DX, BX
  fib.go:35		0x483da7		4883ec80		SUBQ $-0x80, SP
  fib.go:35		0x483dab		5d			POPQ BP
  fib.go:35		0x483dac		c3			RET
  fib.go:28		0x483dad		488d05cc740000		LEAQ 0x74cc(IP), AX
  fib.go:28		0x483db4		488d1dd5bc0300		LEAQ 0x3bcd5(IP), BX
  fib.go:28		0x483dbb		0f1f440000		NOPL 0(AX)(AX*1)
  fib.go:28		0x483dc0		e8fbe5faff		CALL runtime.gopanic(SB)
  fib.go:26		0x483dc5		4c89c1			MOVQ R8, CX
  fib.go:26		0x483dc8		e833e9fdff		CALL runtime.panicIndex(SB)
  fib.go:24		0x483dcd		488d05ac740000		LEAQ 0x74ac(IP), AX
  fib.go:24		0x483dd4		488d1da5bc0300		LEAQ 0x3bca5(IP), BX
  fib.go:24		0x483ddb		0f1f440000		NOPL 0(AX)(AX*1)
  fib.go:24		0x483de0		e8dbe5faff		CALL runtime.gopanic(SB)
  fib.go:21		0x483de5		4c89c1			MOVQ R8, CX
  fib.go:21		0x483de8		e813e9fdff		CALL runtime.panicIndex(SB)
  fib.go:21		0x483ded		90			NOPL
  fib.go:17		0x483dee		e8edc7fdff		CALL runtime.morestack_noctxt.abi0(SB)
  fib.go:17		0x483df3		e948feffff		JMP main.parseArgs(SB)

TEXT main.main(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/fib.go
  fib.go:38		0x483e00		4c8d6424e0		LEAQ -0x20(SP), R12
  fib.go:38		0x483e05		4d3b6610		CMPQ R12, 0x10(R14)
  fib.go:38		0x483e09		0f86b7010000		JBE 0x483fc6
  fib.go:38		0x483e0f		55			PUSHQ BP
  fib.go:38		0x483e10		4889e5			MOVQ SP, BP
  fib.go:38		0x483e13		4881ec98000000		SUBQ $0x98, SP
  fib.go:39		0x483e1a		e821feffff		CALL main.parseArgs(SB)
  fib.go:39		0x483e1f		4889442440		MOVQ AX, 0x40(SP)
  fib.go:41		0x483e24		4885c9			TESTQ CX, CX
  fib.go:41		0x483e27		7507			JNE 0x483e30
  fib.go:41		0x483e29		b916000000		MOVL $0x16, CX
  fib.go:41		0x483e2e		eb22			JMP 0x483e52
  fib.go:42		0x483e30		488b03			MOVQ 0(BX), AX
  fib.go:42		0x483e33		488b5b08		MOVQ 0x8(BX), BX
  fib.go:42		0x483e37		b90a000000		MOVL $0xa, CX
  fib.go:42		0x483e3c		bf40000000		MOVL $0x40, DI
  fib.go:42		0x483e41		e85a3dfeff		CALL strconv.ParseInt(SB)
  fib.go:43		0x483e46		4885db			TESTQ BX, BX
  fib.go:43		0x483e49		0f8560010000		JNE 0x483faf
  fib.go:49		0x483e4f		4889c1			MOVQ AX, CX
  fib.go:49		0x483e52		48894c2448		MOVQ CX, 0x48(SP)
  fib.go:49		0x483e57		4889c8			MOVQ CX, AX
  fib.go:49		0x483e5a		e861fdffff		CALL main.fib(SB)
  fib.go:52		0x483e5f		488b442440		MOVQ 0x40(SP), AX
  fib.go:52		0x483e64		31c9			XORL CX, CX
  fib.go:52		0x483e66		f20f10050abb0300	MOVSD_XMM $f64.43e0000000000000(SB), X0
  fib.go:52		0x483e6e		eb0d			JMP 0x483e7d
  fib.go:52		0x483e70		488b442450		MOVQ 0x50(SP), AX
  fib.go:52		0x483e75		48ffc8			DECQ AX
  fib.go:61		0x483e78		488b4c2438		MOVQ 0x38(SP), CX
  fib.go:62		0x483e7d		f20f11442458		MOVSD_XMM X0, 0x58(SP)
  fib.go:52		0x483e83		4885c0			TESTQ AX, AX
  fib.go:52		0x483e86		7e62			JLE 0x483eea
  fib.go:52		0x483e88		4889442450		MOVQ AX, 0x50(SP)
  fib.go:53		0x483e8d		e8ce4effff		CALL time.Now(SB)
  fib.go:53		0x483e92		4889442468		MOVQ AX, 0x68(SP)
  fib.go:53		0x483e97		48895c2460		MOVQ BX, 0x60(SP)
  fib.go:53		0x483e9c		48894c2470		MOVQ CX, 0x70(SP)
  fib.go:54		0x483ea1		488b442448		MOVQ 0x48(SP), AX
  fib.go:54		0x483ea6		e815fdffff		CALL main.fib(SB)
  fib.go:54		0x483eab		4889442438		MOVQ AX, 0x38(SP)
  fib.go:55		0x483eb0		488b5c2460		MOVQ 0x60(SP), BX
  fib.go:55		0x483eb5		488b4c2470		MOVQ 0x70(SP), CX
  fib.go:55		0x483eba		488b442468		MOVQ 0x68(SP), AX
  fib.go:55		0x483ebf		90			NOPL
  fib.go:55		0x483ec0		e8db4dffff		CALL time.Since(SB)
  fib.go:55		0x483ec5		0f57c0			XORPS X0, X0
  fib.go:55		0x483ec8		f2480f2ac0		CVTSI2SDQ AX, X0
  fib.go:55		0x483ecd		f20f100d9bba0300	MOVSD_XMM $f64.408f400000000000(SB), X1
  fib.go:55		0x483ed5		f20f5ec1		DIVSD X1, X0
  fib.go:56		0x483ed9		f20f10542458		MOVSD_XMM 0x58(SP), X2
  fib.go:56		0x483edf		660f2ed0		UCOMISD X0, X2
  fib.go:56		0x483ee3		778b			JA 0x483e70
  fib.go:62		0x483ee5		0f10c2			MOVUPS X2, X0
  fib.go:56		0x483ee8		eb86			JMP 0x483e70
  fib.go:61		0x483eea		440f11bc2488000000	MOVUPS X15, 0x88(SP)
  fib.go:61		0x483ef3		4889c8			MOVQ CX, AX
  fib.go:61		0x483ef6		e8056af8ff		CALL runtime.convT64(SB)
  fib.go:61		0x483efb		488d0d3e750000		LEAQ 0x753e(IP), CX
  fib.go:61		0x483f02		48898c2488000000	MOVQ CX, 0x88(SP)
  fib.go:61		0x483f0a		4889842490000000	MOVQ AX, 0x90(SP)
  fib.go:62		0x483f12		f20f10442458		MOVSD_XMM 0x58(SP), X0
  fib.go:62		0x483f18		66480f7ec1		MOVQ X0, CX
  fib.go:62		0x483f1d		48894c2468		MOVQ CX, 0x68(SP)
  print.go:233		0x483f22		488b1d7fe90a00		MOVQ os.Stdout(SB), BX
  print.go:233		0x483f29		488d05d8bf0300		LEAQ go:itab.*os.File,io.Writer(SB), AX
  print.go:233		0x483f30		bf0a000000		MOVL $0xa, DI
  print.go:233		0x483f35		488db42488000000	LEAQ 0x88(SP), SI
  print.go:233		0x483f3d		41b801000000		MOVL $0x1, R8
  print.go:233		0x483f43		4d89c1			MOVQ R8, R9
  print.go:233		0x483f46		488d0d0ea80100		LEAQ 0x1a80e(IP), CX
  print.go:233		0x483f4d		e88e94ffff		CALL fmt.Fprintf(SB)
  fib.go:62		0x483f52		440f117c2478		MOVUPS X15, 0x78(SP)
  fib.go:62		0x483f58		488b442468		MOVQ 0x68(SP), AX
  fib.go:62		0x483f5d		0f1f00			NOPL 0(AX)
  fib.go:62		0x483f60		e89b69f8ff		CALL runtime.convT64(SB)
  fib.go:62		0x483f65		488d0dd4760000		LEAQ 0x76d4(IP), CX
  fib.go:62		0x483f6c		48894c2478		MOVQ CX, 0x78(SP)
  fib.go:62		0x483f71		4889842480000000	MOVQ AX, 0x80(SP)
  print.go:233		0x483f79		488b1d28e90a00		MOVQ os.Stdout(SB), BX
  print.go:233		0x483f80		488d0581bf0300		LEAQ go:itab.*os.File,io.Writer(SB), AX
  print.go:233		0x483f87		488d0d80b10100		LEAQ 0x1b180(IP), CX
  print.go:233		0x483f8e		bf0e000000		MOVL $0xe, DI
  print.go:233		0x483f93		488d742478		LEAQ 0x78(SP), SI
  print.go:233		0x483f98		41b801000000		MOVL $0x1, R8
  print.go:233		0x483f9e		4d89c1			MOVQ R8, R9
  print.go:233		0x483fa1		e83a94ffff		CALL fmt.Fprintf(SB)
  fib.go:63		0x483fa6		4881c498000000		ADDQ $0x98, SP
  fib.go:63		0x483fad		5d			POPQ BP
  fib.go:63		0x483fae		c3			RET
  fib.go:44		0x483faf		488d05ca720000		LEAQ 0x72ca(IP), AX
  fib.go:44		0x483fb6		488d1de3ba0300		LEAQ 0x3bae3(IP), BX
  fib.go:44		0x483fbd		0f1f00			NOPL 0(AX)
  fib.go:44		0x483fc0		e8fbe3faff		CALL runtime.gopanic(SB)
  fib.go:44		0x483fc5		90			NOPL
  fib.go:38		0x483fc6		e815c6fdff		CALL runtime.morestack_noctxt.abi0(SB)
  fib.go:38		0x483fcb		e930feffff		JMP main.main(SB)

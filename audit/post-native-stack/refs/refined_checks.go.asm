TEXT runtime.main.func2(SB) /usr/lib/go-1.22/src/runtime/proc.go
  proc.go:204		0x435f80		493b6610		CMPQ SP, 0x10(R14)
  proc.go:204		0x435f84		7614			JBE 0x435f9a
  proc.go:204		0x435f86		55			PUSHQ BP
  proc.go:204		0x435f87		4889e5			MOVQ SP, BP
  proc.go:204		0x435f8a		488b4208		MOVQ 0x8(DX), AX
  proc.go:205		0x435f8e		803800			CMPB 0(AX), $0x0
  proc.go:205		0x435f91		7405			JE 0x435f98
  proc.go:206		0x435f93		e808a60000		CALL runtime.unlockOSThread(SB)
  proc.go:208		0x435f98		5d			POPQ BP
  proc.go:208		0x435f99		c3			RET
  proc.go:204		0x435f9a		e8a1ae0200		CALL runtime.morestack.abi0(SB)
  proc.go:204		0x435f9f		90			NOPL
  proc.go:204		0x435fa0		ebde			JMP runtime.main.func2(SB)

TEXT runtime.main.func1(SB) /usr/lib/go-1.22/src/runtime/proc.go
  proc.go:171		0x45db00		493b6610		CMPQ SP, 0x10(R14)
  proc.go:171		0x45db04		7625			JBE 0x45db2b
  proc.go:171		0x45db06		55			PUSHQ BP
  proc.go:171		0x45db07		4889e5			MOVQ SP, BP
  proc.go:171		0x45db0a		4883ec18		SUBQ $0x18, SP
  proc.go:172		0x45db0e		488d054bbd0400		LEAQ 0x4bd4b(IP), AX
  proc.go:172		0x45db15		31db			XORL BX, BX
  proc.go:172		0x45db17		48c7c1ffffffff		MOVQ $-0x1, CX
  proc.go:172		0x45db1e		6690			NOPW
  proc.go:172		0x45db20		e8fbc7fdff		CALL runtime.newm(SB)
  proc.go:173		0x45db25		4883c418		ADDQ $0x18, SP
  proc.go:173		0x45db29		5d			POPQ BP
  proc.go:173		0x45db2a		c3			RET
  proc.go:171		0x45db2b		e890330000		CALL runtime.morestack_noctxt.abi0(SB)
  proc.go:171		0x45db30		ebce			JMP runtime.main.func1(SB)

TEXT main.tclAlnum(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/refined_checks.go
  refined_checks.go:16	0x4854e0		493b6610		CMPQ SP, 0x10(R14)
  refined_checks.go:16	0x4854e4		0f8685000000		JBE 0x48556f
  refined_checks.go:16	0x4854ea		55			PUSHQ BP
  refined_checks.go:16	0x4854eb		4889e5			MOVQ SP, BP
  refined_checks.go:16	0x4854ee		4883ec10		SUBQ $0x10, SP
  graphic.go:91		0x4854f2		3dff000000		CMPL AX, $0xff
  graphic.go:91		0x4854f7		7716			JA 0x48550f
  graphic.go:92		0x4854f9		0fb6c8			MOVZX AL, CX
  graphic.go:92		0x4854fc		488d15dd860a00		LEAQ unicode.properties(SB), DX
  graphic.go:92		0x485503		0fb60c0a		MOVZX 0(DX)(CX*1), CX
  graphic.go:92		0x485507		f6c160			TESTL $0x60, CL
  graphic.go:92		0x48550a		0f95c1			SETNE CL
  refined_checks.go:17	0x48550d		eb1c			JMP 0x48552b
  graphic.go:91		0x48550f		89442420		MOVL AX, 0x20(SP)
  graphic.go:94		0x485513		488b0dfee80a00		MOVQ unicode.Letter(SB), CX
  graphic.go:94		0x48551a		89c3			MOVL AX, BX
  graphic.go:94		0x48551c		4889c8			MOVQ CX, AX
  graphic.go:94		0x48551f		90			NOPL
  graphic.go:94		0x485520		e87bacfeff		CALL unicode.isExcludingLatin(SB)
  refined_checks.go:17	0x485525		89c1			MOVL AX, CX
  graphic.go:91		0x485527		8b442420		MOVL 0x20(SP), AX
  refined_checks.go:17	0x48552b		84c9			TESTL CL, CL
  refined_checks.go:17	0x48552d		7407			JE 0x485536
  refined_checks.go:17	0x48552f		b901000000		MOVL $0x1, CX
  refined_checks.go:17	0x485534		eb31			JMP 0x485567
  graphic.go:91		0x485536		3dff000000		CMPL AX, $0xff
  digit.go:9		0x48553b		7f14			JG 0x485551
  digit.go:9		0x48553d		0f1f00			NOPL 0(AX)
  digit.go:10		0x485540		83f830			CMPL AX, $0x30
  digit.go:10		0x485543		7c08			JL 0x48554d
  digit.go:10		0x485545		83f839			CMPL AX, $0x39
  digit.go:10		0x485548		0f9ec1			SETLE CL
  digit.go:10		0x48554b		eb1a			JMP 0x485567
  digit.go:10		0x48554d		31c9			XORL CX, CX
  digit.go:10		0x48554f		eb16			JMP 0x485567
  digit.go:12		0x485551		488b0db8e80a00		MOVQ unicode.Digit(SB), CX
  digit.go:12		0x485558		89c3			MOVL AX, BX
  digit.go:12		0x48555a		4889c8			MOVQ CX, AX
  digit.go:12		0x48555d		0f1f00			NOPL 0(AX)
  digit.go:12		0x485560		e83bacfeff		CALL unicode.isExcludingLatin(SB)
  refined_checks.go:17	0x485565		89c1			MOVL AX, CX
  refined_checks.go:17	0x485567		89c8			MOVL CX, AX
  refined_checks.go:17	0x485569		4883c410		ADDQ $0x10, SP
  refined_checks.go:17	0x48556d		5d			POPQ BP
  refined_checks.go:17	0x48556e		c3			RET
  refined_checks.go:16	0x48556f		89442408		MOVL AX, 0x8(SP)
  refined_checks.go:16	0x485573		e848b9fdff		CALL runtime.morestack_noctxt.abi0(SB)
  refined_checks.go:16	0x485578		8b442408		MOVL 0x8(SP), AX
  refined_checks.go:16	0x48557c		0f1f4000		NOPL 0(AX)
  refined_checks.go:16	0x485580		e95bffffff		JMP main.tclAlnum(SB)

TEXT main.isLocalChar(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/refined_checks.go
  refined_checks.go:20	0x4855a0		493b6610		CMPQ SP, 0x10(R14)
  refined_checks.go:20	0x4855a4		763f			JBE 0x4855e5
  refined_checks.go:20	0x4855a6		55			PUSHQ BP
  refined_checks.go:20	0x4855a7		4889e5			MOVQ SP, BP
  refined_checks.go:20	0x4855aa		4883ec18		SUBQ $0x18, SP
  refined_checks.go:21	0x4855ae		89442428		MOVL AX, 0x28(SP)
  refined_checks.go:21	0x4855b2		e829ffffff		CALL main.tclAlnum(SB)
  refined_checks.go:21	0x4855b7		84c0			TESTL AL, AL
  refined_checks.go:21	0x4855b9		7407			JE 0x4855c2
  refined_checks.go:21	0x4855bb		ba01000000		MOVL $0x1, DX
  refined_checks.go:21	0x4855c0		eb1b			JMP 0x4855dd
  strings.go:71		0x4855c2		488d0518bb0100		LEAQ 0x1bb18(IP), AX
  strings.go:71		0x4855c9		bb05000000		MOVL $0x5, BX
  strings.go:71		0x4855ce		8b4c2428		MOVL 0x28(SP), CX
  strings.go:71		0x4855d2		e8e9f4ffff		CALL strings.IndexRune(SB)
  strings.go:71		0x4855d7		4885c0			TESTQ AX, AX
  strings.go:71		0x4855da		0f9dc2			SETGE DL
  refined_checks.go:21	0x4855dd		89d0			MOVL DX, AX
  refined_checks.go:21	0x4855df		4883c418		ADDQ $0x18, SP
  refined_checks.go:21	0x4855e3		5d			POPQ BP
  refined_checks.go:21	0x4855e4		c3			RET
  refined_checks.go:20	0x4855e5		89442408		MOVL AX, 0x8(SP)
  refined_checks.go:20	0x4855e9		e8d2b8fdff		CALL runtime.morestack_noctxt.abi0(SB)
  refined_checks.go:20	0x4855ee		8b442408		MOVL 0x8(SP), AX
  refined_checks.go:20	0x4855f2		ebac			JMP main.isLocalChar(SB)

TEXT main.emailish(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/refined_checks.go
  refined_checks.go:28	0x485600		4c8d6424b0		LEAQ -0x50(SP), R12
  refined_checks.go:28	0x485605		4d3b6610		CMPQ R12, 0x10(R14)
  refined_checks.go:28	0x485609		0f8665020000		JBE 0x485874
  refined_checks.go:28	0x48560f		55			PUSHQ BP
  refined_checks.go:28	0x485610		4889e5			MOVQ SP, BP
  refined_checks.go:28	0x485613		4881ecc8000000		SUBQ $0xc8, SP
  refined_checks.go:28	0x48561a		48898424d8000000	MOVQ AX, 0xd8(SP)
  refined_checks.go:29	0x485622		4889d9			MOVQ BX, CX
  refined_checks.go:29	0x485625		4889c3			MOVQ AX, BX
  refined_checks.go:29	0x485628		488d442420		LEAQ 0x20(SP), AX
  refined_checks.go:29	0x48562d		e86e92fcff		CALL runtime.stringtoslicerune(SB)
  refined_checks.go:29	0x485632		48898424c0000000	MOVQ AX, 0xc0(SP)
  refined_checks.go:29	0x48563a		48899c24a0000000	MOVQ BX, 0xa0(SP)
  refined_checks.go:29	0x485642		31c9			XORL CX, CX
  refined_checks.go:33	0x485644		eb03			JMP 0x485649
  refined_checks.go:34	0x485646		48ffc1			INCQ CX
  refined_checks.go:33	0x485649		4839cb			CMPQ BX, CX
  refined_checks.go:33	0x48564c		7f04			JG 0x485652
  refined_checks.go:33	0x48564e		31d2			XORL DX, DX
  refined_checks.go:33	0x485650		eb32			JMP 0x485684
  refined_checks.go:33	0x485652		0f8610020000		JBE 0x485868
  refined_checks.go:33	0x485658		48898c24a8000000	MOVQ CX, 0xa8(SP)
  refined_checks.go:33	0x485660		8b1488			MOVL 0(AX)(CX*4), DX
  refined_checks.go:33	0x485663		89d0			MOVL DX, AX
  refined_checks.go:33	0x485665		e836ffffff		CALL main.isLocalChar(SB)
  refined_checks.go:34	0x48566a		488b8c24a8000000	MOVQ 0xa8(SP), CX
  refined_checks.go:33	0x485672		488b9c24a0000000	MOVQ 0xa0(SP), BX
  refined_checks.go:33	0x48567a		89c2			MOVL AX, DX
  refined_checks.go:39	0x48567c		488b8424c0000000	MOVQ 0xc0(SP), AX
  refined_checks.go:33	0x485684		84d2			TESTL DL, DL
  refined_checks.go:33	0x485686		75be			JNE 0x485646
  refined_checks.go:36	0x485688		4885c9			TESTQ CX, CX
  refined_checks.go:36	0x48568b		7429			JE 0x4856b6
  refined_checks.go:33	0x48568d		4839cb			CMPQ BX, CX
  refined_checks.go:39	0x485690		7e19			JLE 0x4856ab
  refined_checks.go:39	0x485692		0f86c5010000		JBE 0x48585d
  refined_checks.go:39	0x485698		8b1488			MOVL 0(AX)(CX*4), DX
  refined_checks.go:39	0x48569b		0f1f440000		NOPL 0(AX)(AX*1)
  refined_checks.go:39	0x4856a0		83fa40			CMPL DX, $0x40
  refined_checks.go:39	0x4856a3		7506			JNE 0x4856ab
  refined_checks.go:42	0x4856a5		488d5101		LEAQ 0x1(CX), DX
  refined_checks.go:44	0x4856a9		eb19			JMP 0x4856c4
  refined_checks.go:40	0x4856ab		31c0			XORL AX, AX
  refined_checks.go:40	0x4856ad		4881c4c8000000		ADDQ $0xc8, SP
  refined_checks.go:40	0x4856b4		5d			POPQ BP
  refined_checks.go:40	0x4856b5		c3			RET
  refined_checks.go:37	0x4856b6		31c0			XORL AX, AX
  refined_checks.go:37	0x4856b8		4881c4c8000000		ADDQ $0xc8, SP
  refined_checks.go:37	0x4856bf		5d			POPQ BP
  refined_checks.go:37	0x4856c0		c3			RET
  refined_checks.go:45	0x4856c1		4889fa			MOVQ DI, DX
  refined_checks.go:45	0x4856c4		48899424a8000000	MOVQ DX, 0xa8(SP)
  refined_checks.go:45	0x4856cc		4889d1			MOVQ DX, CX
  refined_checks.go:46	0x4856cf		eb56			JMP 0x485727
  refined_checks.go:49	0x4856d1		4839ca			CMPQ DX, CX
  refined_checks.go:49	0x4856d4		0f84be000000		JE 0x485798
  refined_checks.go:49	0x4856da		660f1f440000		NOPW 0(AX)(AX*1)
  refined_checks.go:46	0x4856e0		4839d3			CMPQ BX, DX
  refined_checks.go:52	0x4856e3		0f8ea4000000		JLE 0x48578d
  refined_checks.go:52	0x4856e9		0f8658010000		JBE 0x485847
  refined_checks.go:52	0x4856ef		8b3490			MOVL 0(AX)(DX*4), SI
  refined_checks.go:52	0x4856f2		83fe2e			CMPL SI, $0x2e
  refined_checks.go:52	0x4856f5		0f8592000000		JNE 0x48578d
  refined_checks.go:55	0x4856fb		488d7201		LEAQ 0x1(DX), SI
  refined_checks.go:55	0x4856ff		90			NOPL
  refined_checks.go:58	0x485700		e9a1000000		JMP 0x4857a6
  refined_checks.go:58	0x485705		4839f3			CMPQ BX, SI
  refined_checks.go:61	0x485708		7515			JNE 0x48571f
  refined_checks.go:61	0x48570a		4889f7			MOVQ SI, DI
  refined_checks.go:61	0x48570d		4829d6			SUBQ DX, SI
  refined_checks.go:61	0x485710		488d56ff		LEAQ -0x1(SI), DX
  refined_checks.go:61	0x485714		4883fa02		CMPQ DX, $0x2
  refined_checks.go:61	0x485718		7ca7			JL 0x4856c1
  refined_checks.go:61	0x48571a		e90f010000		JMP 0x48582e
  refined_checks.go:45	0x48571f		4889f7			MOVQ SI, DI
  refined_checks.go:61	0x485722		eb9d			JMP 0x4856c1
  refined_checks.go:47	0x485724		48ffc2			INCQ DX
  refined_checks.go:46	0x485727		48899424b8000000	MOVQ DX, 0xb8(SP)
  refined_checks.go:46	0x48572f		4839d3			CMPQ BX, DX
  refined_checks.go:46	0x485732		7f04			JG 0x485738
  refined_checks.go:46	0x485734		31f6			XORL SI, SI
  refined_checks.go:46	0x485736		eb4b			JMP 0x485783
  refined_checks.go:46	0x485738		0f8614010000		JBE 0x485852
  refined_checks.go:46	0x48573e		8b0c90			MOVL 0(AX)(DX*4), CX
  refined_checks.go:46	0x485741		894c241c		MOVL CX, 0x1c(SP)
  refined_checks.go:25	0x485745		89c8			MOVL CX, AX
  refined_checks.go:25	0x485747		e894fdffff		CALL main.tclAlnum(SB)
  refined_checks.go:25	0x48574c		84c0			TESTL AL, AL
  refined_checks.go:25	0x48574e		7407			JE 0x485757
  refined_checks.go:25	0x485750		ba01000000		MOVL $0x1, DX
  refined_checks.go:25	0x485755		eb0a			JMP 0x485761
  refined_checks.go:25	0x485757		8b54241c		MOVL 0x1c(SP), DX
  refined_checks.go:25	0x48575b		83fa2d			CMPL DX, $0x2d
  refined_checks.go:25	0x48575e		0f94c2			SETE DL
  refined_checks.go:52	0x485761		488b8424c0000000	MOVQ 0xc0(SP), AX
  refined_checks.go:49	0x485769		488b8c24a8000000	MOVQ 0xa8(SP), CX
  refined_checks.go:46	0x485771		488b9c24a0000000	MOVQ 0xa0(SP), BX
  refined_checks.go:46	0x485779		89d6			MOVL DX, SI
  refined_checks.go:47	0x48577b		488b9424b8000000	MOVQ 0xb8(SP), DX
  refined_checks.go:46	0x485783		4084f6			TESTL SI, SI
  refined_checks.go:46	0x485786		759c			JNE 0x485724
  refined_checks.go:46	0x485788		e944ffffff		JMP 0x4856d1
  refined_checks.go:53	0x48578d		31c0			XORL AX, AX
  refined_checks.go:53	0x48578f		4881c4c8000000		ADDQ $0xc8, SP
  refined_checks.go:53	0x485796		5d			POPQ BP
  refined_checks.go:53	0x485797		c3			RET
  refined_checks.go:50	0x485798		31c0			XORL AX, AX
  refined_checks.go:50	0x48579a		4881c4c8000000		ADDQ $0xc8, SP
  refined_checks.go:50	0x4857a1		5d			POPQ BP
  refined_checks.go:50	0x4857a2		c3			RET
  refined_checks.go:59	0x4857a3		48ffc6			INCQ SI
  refined_checks.go:58	0x4857a6		4839f3			CMPQ BX, SI
  refined_checks.go:58	0x4857a9		7e6c			JLE 0x485817
  refined_checks.go:58	0x4857ab		0f868b000000		JBE 0x48583c
  refined_checks.go:58	0x4857b1		8b3cb0			MOVL 0(AX)(SI*4), DI
  graphic.go:91		0x4857b4		81ffff000000		CMPL DI, $0xff
  graphic.go:91		0x4857ba		771a			JA 0x4857d6
  graphic.go:92		0x4857bc		400fb6ff		MOVZX DI, DI
  graphic.go:92		0x4857c0		4c8d0519840a00		LEAQ unicode.properties(SB), R8
  graphic.go:92		0x4857c7		410fb63c38		MOVZX 0(R8)(DI*1), DI
  graphic.go:92		0x4857cc		40f6c760		TESTL $0x60, DI
  graphic.go:92		0x4857d0		400f95c7		SETNE DI
  refined_checks.go:13	0x4857d4		eb4a			JMP 0x485820
  refined_checks.go:58	0x4857d6		4889b424b0000000	MOVQ SI, 0xb0(SP)
  graphic.go:94		0x4857de		488b0533e60a00		MOVQ unicode.Letter(SB), AX
  graphic.go:94		0x4857e5		89fb			MOVL DI, BX
  graphic.go:94		0x4857e7		e8b4a9feff		CALL unicode.isExcludingLatin(SB)
  refined_checks.go:61	0x4857ec		488b9424b8000000	MOVQ 0xb8(SP), DX
  refined_checks.go:58	0x4857f4		488b9c24a0000000	MOVQ 0xa0(SP), BX
  refined_checks.go:59	0x4857fc		488bb424b0000000	MOVQ 0xb0(SP), SI
  refined_checks.go:59	0x485804		4c8d05d5830a00		LEAQ unicode.properties(SB), R8
  refined_checks.go:58	0x48580b		89c7			MOVL AX, DI
  refined_checks.go:58	0x48580d		488b8424c0000000	MOVQ 0xc0(SP), AX
  refined_checks.go:13	0x485815		eb09			JMP 0x485820
  refined_checks.go:13	0x485817		4c8d05c2830a00		LEAQ unicode.properties(SB), R8
  refined_checks.go:13	0x48581e		31ff			XORL DI, DI
  refined_checks.go:58	0x485820		4084ff			TESTL DI, DI
  refined_checks.go:58	0x485823		0f857affffff		JNE 0x4857a3
  refined_checks.go:58	0x485829		e9d7feffff		JMP 0x485705
  refined_checks.go:62	0x48582e		b801000000		MOVL $0x1, AX
  refined_checks.go:62	0x485833		4881c4c8000000		ADDQ $0xc8, SP
  refined_checks.go:62	0x48583a		5d			POPQ BP
  refined_checks.go:62	0x48583b		c3			RET
  refined_checks.go:58	0x48583c		4889f0			MOVQ SI, AX
  refined_checks.go:58	0x48583f		4889d9			MOVQ BX, CX
  refined_checks.go:58	0x485842		e899d7fdff		CALL runtime.panicIndex(SB)
  refined_checks.go:52	0x485847		4889d0			MOVQ DX, AX
  refined_checks.go:52	0x48584a		4889d9			MOVQ BX, CX
  refined_checks.go:52	0x48584d		e88ed7fdff		CALL runtime.panicIndex(SB)
  refined_checks.go:46	0x485852		4889d0			MOVQ DX, AX
  refined_checks.go:46	0x485855		4889d9			MOVQ BX, CX
  refined_checks.go:46	0x485858		e883d7fdff		CALL runtime.panicIndex(SB)
  refined_checks.go:39	0x48585d		4889c8			MOVQ CX, AX
  refined_checks.go:39	0x485860		4889d9			MOVQ BX, CX
  refined_checks.go:39	0x485863		e878d7fdff		CALL runtime.panicIndex(SB)
  refined_checks.go:33	0x485868		4889c8			MOVQ CX, AX
  refined_checks.go:33	0x48586b		4889d9			MOVQ BX, CX
  refined_checks.go:33	0x48586e		e86dd7fdff		CALL runtime.panicIndex(SB)
  refined_checks.go:33	0x485873		90			NOPL
  refined_checks.go:28	0x485874		4889442408		MOVQ AX, 0x8(SP)
  refined_checks.go:28	0x485879		48895c2410		MOVQ BX, 0x10(SP)
  refined_checks.go:28	0x48587e		6690			NOPW
  refined_checks.go:28	0x485880		e83bb6fdff		CALL runtime.morestack_noctxt.abi0(SB)
  refined_checks.go:28	0x485885		488b442408		MOVQ 0x8(SP), AX
  refined_checks.go:28	0x48588a		488b5c2410		MOVQ 0x10(SP), BX
  refined_checks.go:28	0x48588f		e96cfdffff		JMP main.emailish(SB)

TEXT main.uriEscape(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/refined_checks.go
  refined_checks.go:75	0x4858a0		493b6610		CMPQ SP, 0x10(R14)
  refined_checks.go:75	0x4858a4		0f868d010000		JBE 0x485a37
  refined_checks.go:75	0x4858aa		55			PUSHQ BP
  refined_checks.go:75	0x4858ab		4889e5			MOVQ SP, BP
  refined_checks.go:75	0x4858ae		4883ec78		SUBQ $0x78, SP
  refined_checks.go:77	0x4858b2		48899c2490000000	MOVQ BX, 0x90(SP)
  refined_checks.go:77	0x4858ba		4889842488000000	MOVQ AX, 0x88(SP)
  refined_checks.go:76	0x4858c2		488d05b7f10000		LEAQ 0xf1b7(IP), AX
  refined_checks.go:76	0x4858c9		e89281f8ff		CALL runtime.newobject(SB)
  refined_checks.go:76	0x4858ce		4889442458		MOVQ AX, 0x58(SP)
  refined_checks.go:76	0x4858d3		48c7400800000000	MOVQ $0x0, 0x8(AX)
  refined_checks.go:76	0x4858db		31c9			XORL CX, CX
  refined_checks.go:77	0x4858dd		eb0a			JMP 0x4858e9
  refined_checks.go:79	0x4858df		488b442458		MOVQ 0x58(SP), AX
  refined_checks.go:77	0x4858e4		488b4c2450		MOVQ 0x50(SP), CX
  refined_checks.go:77	0x4858e9		488b9c2490000000	MOVQ 0x90(SP), BX
  refined_checks.go:77	0x4858f1		4839cb			CMPQ BX, CX
  refined_checks.go:77	0x4858f4		0f8e9c000000		JLE 0x485996
  refined_checks.go:77	0x4858fa		488b942488000000	MOVQ 0x88(SP), DX
  refined_checks.go:77	0x485902		0fb6340a		MOVZX 0(DX)(CX*1), SI
  refined_checks.go:77	0x485906		81fe80000000		CMPL SI, $0x80
  refined_checks.go:77	0x48590c		7d05			JGE 0x485913
  refined_checks.go:77	0x48590e		48ffc1			INCQ CX
  refined_checks.go:77	0x485911		eb22			JMP 0x485935
  refined_checks.go:77	0x485913		4889d0			MOVQ DX, AX
  refined_checks.go:77	0x485916		e82571fdff		CALL runtime.decoderune(SB)
  refined_checks.go:77	0x48591b		488b942488000000	MOVQ 0x88(SP), DX
  refined_checks.go:77	0x485923		89c6			MOVL AX, SI
  refined_checks.go:77	0x485925		4889d9			MOVQ BX, CX
  refined_checks.go:79	0x485928		488b442458		MOVQ 0x58(SP), AX
  refined_checks.go:77	0x48592d		488b9c2490000000	MOVQ 0x90(SP), BX
  refined_checks.go:77	0x485935		48894c2450		MOVQ CX, 0x50(SP)
  refined_checks.go:78	0x48593a		8d7ebf			LEAL -0x41(SI), DI
  refined_checks.go:78	0x48593d		0f1f00			NOPL 0(AX)
  refined_checks.go:78	0x485940		83ff19			CMPL DI, $0x19
  refined_checks.go:78	0x485943		7625			JBE 0x48596a
  refined_checks.go:78	0x485945		8d7e9f			LEAL -0x61(SI), DI
  refined_checks.go:78	0x485948		83ff19			CMPL DI, $0x19
  refined_checks.go:78	0x48594b		761d			JBE 0x48596a
  refined_checks.go:78	0x48594d		8d7ed0			LEAL -0x30(SI), DI
  refined_checks.go:78	0x485950		83ff09			CMPL DI, $0x9
  refined_checks.go:78	0x485953		7615			JBE 0x48596a
  refined_checks.go:78	0x485955		83fe2e			CMPL SI, $0x2e
  refined_checks.go:78	0x485958		7410			JE 0x48596a
  refined_checks.go:78	0x48595a		83fe5f			CMPL SI, $0x5f
  refined_checks.go:78	0x48595d		740b			JE 0x48596a
  refined_checks.go:78	0x48595f		90			NOPL
  refined_checks.go:78	0x485960		83fe7e			CMPL SI, $0x7e
  refined_checks.go:78	0x485963		7405			JE 0x48596a
  refined_checks.go:78	0x485965		83fe2d			CMPL SI, $0x2d
  refined_checks.go:78	0x485968		750c			JNE 0x485976
  refined_checks.go:79	0x48596a		89f3			MOVL SI, BX
  refined_checks.go:79	0x48596c		e80ff0ffff		CALL strings.(*Builder).WriteRune(SB)
  refined_checks.go:79	0x485971		e969ffffff		JMP 0x4858df
  refined_checks.go:81	0x485976		4863de			MOVSXD SI, BX
  refined_checks.go:81	0x485979		488d44243c		LEAQ 0x3c(SP), AX
  refined_checks.go:81	0x48597e		6690			NOPW
  refined_checks.go:81	0x485980		e8bb90fcff		CALL runtime.intstring(SB)
  refined_checks.go:81	0x485985		4889442460		MOVQ AX, 0x60(SP)
  refined_checks.go:81	0x48598a		48895c2448		MOVQ BX, 0x48(SP)
  refined_checks.go:81	0x48598f		31c9			XORL CX, CX
  refined_checks.go:81	0x485991		e997000000		JMP 0x485a2d
  builder.go:49		0x485996		488b4808		MOVQ 0x8(AX), CX
  builder.go:49		0x48599a		4889ca			MOVQ CX, DX
  builder.go:49		0x48599d		48f7d9			NEGQ CX
  builder.go:49		0x4859a0		488b5810		MOVQ 0x10(AX), BX
  builder.go:49		0x4859a4		4839cb			CMPQ BX, CX
  builder.go:49		0x4859a7		7709			JA 0x4859b2
  refined_checks.go:86	0x4859a9		4889d0			MOVQ DX, AX
  refined_checks.go:86	0x4859ac		4883c478		ADDQ $0x78, SP
  refined_checks.go:86	0x4859b0		5d			POPQ BP
  refined_checks.go:86	0x4859b1		c3			RET
  builder.go:49		0x4859b2		4885d2			TESTQ DX, DX
  builder.go:49		0x4859b5		7409			JE 0x4859c0
  builder.go:49		0x4859b7		e8c46efdff		CALL runtime.panicunsafestringlen(SB)
  builder.go:49		0x4859bc		0f1f4000		NOPL 0(AX)
  builder.go:49		0x4859c0		e8fb6efdff		CALL runtime.panicunsafestringnilptr(SB)
  refined_checks.go:81	0x4859c5		48894c2440		MOVQ CX, 0x40(SP)
  refined_checks.go:81	0x4859ca		0fb61408		MOVZX 0(AX)(CX*1), DX
  refined_checks.go:82	0x4859ce		440f117c2468		MOVUPS X15, 0x68(SP)
  refined_checks.go:82	0x4859d4		4c8d1565890000		LEAQ 0x8965(IP), R10
  refined_checks.go:82	0x4859db		4c89542468		MOVQ R10, 0x68(SP)
  refined_checks.go:82	0x4859e0		4c8d1db99b0a00		LEAQ runtime.staticuint64s(SB), R11
  refined_checks.go:82	0x4859e7		498d14d3		LEAQ 0(R11)(DX*8), DX
  refined_checks.go:82	0x4859eb		4889542470		MOVQ DX, 0x70(SP)
  refined_checks.go:82	0x4859f0		488b5c2458		MOVQ 0x58(SP), BX
  refined_checks.go:82	0x4859f5		bf06000000		MOVL $0x6, DI
  refined_checks.go:82	0x4859fa		488d742468		LEAQ 0x68(SP), SI
  refined_checks.go:82	0x4859ff		41b801000000		MOVL $0x1, R8
  refined_checks.go:82	0x485a05		4d89c1			MOVQ R8, R9
  refined_checks.go:82	0x485a08		488d0599d90300		LEAQ go:itab.*strings.Builder,io.Writer(SB), AX
  refined_checks.go:82	0x485a0f		488d0dc5b70100		LEAQ 0x1b7c5(IP), CX
  refined_checks.go:82	0x485a16		e8a585ffff		CALL fmt.Fprintf(SB)
  refined_checks.go:81	0x485a1b		488b4c2440		MOVQ 0x40(SP), CX
  refined_checks.go:81	0x485a20		48ffc1			INCQ CX
  refined_checks.go:81	0x485a23		488b442460		MOVQ 0x60(SP), AX
  refined_checks.go:81	0x485a28		488b5c2448		MOVQ 0x48(SP), BX
  refined_checks.go:81	0x485a2d		4839cb			CMPQ BX, CX
  refined_checks.go:81	0x485a30		7f93			JG 0x4859c5
  refined_checks.go:81	0x485a32		e9a8feffff		JMP 0x4858df
  refined_checks.go:75	0x485a37		4889442408		MOVQ AX, 0x8(SP)
  refined_checks.go:75	0x485a3c		48895c2410		MOVQ BX, 0x10(SP)
  refined_checks.go:75	0x485a41		e87ab4fdff		CALL runtime.morestack_noctxt.abi0(SB)
  refined_checks.go:75	0x485a46		488b442408		MOVQ 0x8(SP), AX
  refined_checks.go:75	0x485a4b		488b5c2410		MOVQ 0x10(SP), BX
  refined_checks.go:75	0x485a50		e94bfeffff		JMP main.uriEscape(SB)

TEXT main.check(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/refined_checks.go
  refined_checks.go:89	0x485a60		493b6610		CMPQ SP, 0x10(R14)
  refined_checks.go:89	0x485a64		0f8697000000		JBE 0x485b01
  refined_checks.go:89	0x485a6a		55			PUSHQ BP
  refined_checks.go:89	0x485a6b		4889e5			MOVQ SP, BP
  refined_checks.go:89	0x485a6e		4883ec30		SUBQ $0x30, SP
  refined_checks.go:89	0x485a72		48894c2450		MOVQ CX, 0x50(SP)
  refined_checks.go:89	0x485a77		4889742460		MOVQ SI, 0x60(SP)
  refined_checks.go:89	0x485a7c		0f1f4000		NOPL 0(AX)
  refined_checks.go:90	0x485a80		4885c0			TESTQ AX, AX
  refined_checks.go:90	0x485a83		7e73			JLE 0x485af8
  refined_checks.go:90	0x485a85		4889442440		MOVQ AX, 0x40(SP)
  refined_checks.go:90	0x485a8a		48895c2448		MOVQ BX, 0x48(SP)
  refined_checks.go:90	0x485a8f		4c89442468		MOVQ R8, 0x68(SP)
  refined_checks.go:90	0x485a94		4889742460		MOVQ SI, 0x60(SP)
  refined_checks.go:90	0x485a99		48897c2458		MOVQ DI, 0x58(SP)
  refined_checks.go:90	0x485a9e		48894c2450		MOVQ CX, 0x50(SP)
  refined_checks.go:94	0x485aa3		4889c8			MOVQ CX, AX
  refined_checks.go:94	0x485aa6		4889fb			MOVQ DI, BX
  refined_checks.go:94	0x485aa9		e852fbffff		CALL main.emailish(SB)
  refined_checks.go:94	0x485aae		84c0			TESTL AL, AL
  refined_checks.go:94	0x485ab0		7504			JNE 0x485ab6
  refined_checks.go:94	0x485ab2		31c9			XORL CX, CX
  refined_checks.go:94	0x485ab4		eb12			JMP 0x485ac8
  refined_checks.go:95	0x485ab6		488b442450		MOVQ 0x50(SP), AX
  refined_checks.go:95	0x485abb		488b5c2458		MOVQ 0x58(SP), BX
  refined_checks.go:95	0x485ac0		e83bfbffff		CALL main.emailish(SB)
  refined_checks.go:107	0x485ac5		0fb6c8			MOVZX AL, CX
  refined_checks.go:107	0x485ac8		488b442440		MOVQ 0x40(SP), AX
  refined_checks.go:107	0x485acd		48ffc8			DECQ AX
  refined_checks.go:107	0x485ad0		488b542448		MOVQ 0x48(SP), DX
  refined_checks.go:107	0x485ad5		488d1c11		LEAQ 0(CX)(DX*1), BX
  refined_checks.go:107	0x485ad9		488b4c2450		MOVQ 0x50(SP), CX
  refined_checks.go:107	0x485ade		488b7c2458		MOVQ 0x58(SP), DI
  refined_checks.go:107	0x485ae3		488b742460		MOVQ 0x60(SP), SI
  refined_checks.go:107	0x485ae8		4c8b442468		MOVQ 0x68(SP), R8
  refined_checks.go:107	0x485aed		e86effffff		CALL main.check(SB)
  refined_checks.go:107	0x485af2		4883c430		ADDQ $0x30, SP
  refined_checks.go:107	0x485af6		5d			POPQ BP
  refined_checks.go:107	0x485af7		c3			RET
  refined_checks.go:91	0x485af8		4889d8			MOVQ BX, AX
  refined_checks.go:91	0x485afb		4883c430		ADDQ $0x30, SP
  refined_checks.go:91	0x485aff		5d			POPQ BP
  refined_checks.go:91	0x485b00		c3			RET
  refined_checks.go:89	0x485b01		4889442408		MOVQ AX, 0x8(SP)
  refined_checks.go:89	0x485b06		48895c2410		MOVQ BX, 0x10(SP)
  refined_checks.go:89	0x485b0b		48894c2418		MOVQ CX, 0x18(SP)
  refined_checks.go:89	0x485b10		48897c2420		MOVQ DI, 0x20(SP)
  refined_checks.go:89	0x485b15		4889742428		MOVQ SI, 0x28(SP)
  refined_checks.go:89	0x485b1a		4c89442430		MOVQ R8, 0x30(SP)
  refined_checks.go:89	0x485b1f		90			NOPL
  refined_checks.go:89	0x485b20		e89bb3fdff		CALL runtime.morestack_noctxt.abi0(SB)
  refined_checks.go:89	0x485b25		488b442408		MOVQ 0x8(SP), AX
  refined_checks.go:89	0x485b2a		488b5c2410		MOVQ 0x10(SP), BX
  refined_checks.go:89	0x485b2f		488b4c2418		MOVQ 0x18(SP), CX
  refined_checks.go:89	0x485b34		488b7c2420		MOVQ 0x20(SP), DI
  refined_checks.go:89	0x485b39		488b742428		MOVQ 0x28(SP), SI
  refined_checks.go:89	0x485b3e		4c8b442430		MOVQ 0x30(SP), R8
  refined_checks.go:89	0x485b43		e918ffffff		JMP main.check(SB)

TEXT main.runOnce(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/refined_checks.go
  refined_checks.go:110	0x485b60		493b6610		CMPQ SP, 0x10(R14)
  refined_checks.go:110	0x485b64		0f86ac000000		JBE 0x485c16
  refined_checks.go:110	0x485b6a		55			PUSHQ BP
  refined_checks.go:110	0x485b6b		4889e5			MOVQ SP, BP
  refined_checks.go:110	0x485b6e		4883ec48		SUBQ $0x48, SP
  refined_checks.go:110	0x485b72		4c89842490000000	MOVQ R8, 0x90(SP)
  refined_checks.go:112	0x485b7a		4889b42488000000	MOVQ SI, 0x88(SP)
  refined_checks.go:112	0x485b82		4889442468		MOVQ AX, 0x68(SP)
  refined_checks.go:112	0x485b87		4889bc2480000000	MOVQ DI, 0x80(SP)
  refined_checks.go:112	0x485b8f		48895c2470		MOVQ BX, 0x70(SP)
  refined_checks.go:112	0x485b94		48894c2478		MOVQ CX, 0x78(SP)
  refined_checks.go:110	0x485b99		440f117c2458		MOVUPS X15, 0x58(SP)
  refined_checks.go:111	0x485b9f		4c89c0			MOVQ R8, AX
  refined_checks.go:111	0x485ba2		4c89cb			MOVQ R9, BX
  refined_checks.go:111	0x485ba5		e8f6fcffff		CALL main.uriEscape(SB)
  refined_checks.go:111	0x485baa		4889442440		MOVQ AX, 0x40(SP)
  refined_checks.go:111	0x485baf		48895c2430		MOVQ BX, 0x30(SP)
  refined_checks.go:112	0x485bb4		488b4c2470		MOVQ 0x70(SP), CX
  refined_checks.go:112	0x485bb9		488b7c2478		MOVQ 0x78(SP), DI
  refined_checks.go:112	0x485bbe		4889c6			MOVQ AX, SI
  refined_checks.go:112	0x485bc1		4989d8			MOVQ BX, R8
  refined_checks.go:112	0x485bc4		488b442468		MOVQ 0x68(SP), AX
  refined_checks.go:112	0x485bc9		31db			XORL BX, BX
  refined_checks.go:112	0x485bcb		e890feffff		CALL main.check(SB)
  refined_checks.go:112	0x485bd0		4889442438		MOVQ AX, 0x38(SP)
  refined_checks.go:112	0x485bd5		31db			XORL BX, BX
  refined_checks.go:112	0x485bd7		488b8c2480000000	MOVQ 0x80(SP), CX
  refined_checks.go:112	0x485bdf		488bbc2488000000	MOVQ 0x88(SP), DI
  refined_checks.go:112	0x485be7		488b742440		MOVQ 0x40(SP), SI
  refined_checks.go:112	0x485bec		4c8b442430		MOVQ 0x30(SP), R8
  refined_checks.go:112	0x485bf1		488b442468		MOVQ 0x68(SP), AX
  refined_checks.go:112	0x485bf6		e865feffff		CALL main.check(SB)
  refined_checks.go:112	0x485bfb		440f117c2458		MOVUPS X15, 0x58(SP)
  refined_checks.go:112	0x485c01		488b4c2438		MOVQ 0x38(SP), CX
  refined_checks.go:112	0x485c06		48894c2458		MOVQ CX, 0x58(SP)
  refined_checks.go:112	0x485c0b		4889442460		MOVQ AX, 0x60(SP)
  refined_checks.go:112	0x485c10		4883c448		ADDQ $0x48, SP
  refined_checks.go:112	0x485c14		5d			POPQ BP
  refined_checks.go:112	0x485c15		c3			RET
  refined_checks.go:110	0x485c16		4889442418		MOVQ AX, 0x18(SP)
  refined_checks.go:110	0x485c1b		48895c2420		MOVQ BX, 0x20(SP)
  refined_checks.go:110	0x485c20		48894c2428		MOVQ CX, 0x28(SP)
  refined_checks.go:110	0x485c25		48897c2430		MOVQ DI, 0x30(SP)
  refined_checks.go:110	0x485c2a		4889742438		MOVQ SI, 0x38(SP)
  refined_checks.go:110	0x485c2f		4c89442440		MOVQ R8, 0x40(SP)
  refined_checks.go:110	0x485c34		4c894c2448		MOVQ R9, 0x48(SP)
  refined_checks.go:110	0x485c39		e882b2fdff		CALL runtime.morestack_noctxt.abi0(SB)
  refined_checks.go:110	0x485c3e		488b442418		MOVQ 0x18(SP), AX
  refined_checks.go:110	0x485c43		488b5c2420		MOVQ 0x20(SP), BX
  refined_checks.go:110	0x485c48		488b4c2428		MOVQ 0x28(SP), CX
  refined_checks.go:110	0x485c4d		488b7c2430		MOVQ 0x30(SP), DI
  refined_checks.go:110	0x485c52		488b742438		MOVQ 0x38(SP), SI
  refined_checks.go:110	0x485c57		4c8b442440		MOVQ 0x40(SP), R8
  refined_checks.go:110	0x485c5c		4c8b4c2448		MOVQ 0x48(SP), R9
  refined_checks.go:110	0x485c61		e9fafeffff		JMP main.runOnce(SB)

TEXT main.parseArgs(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/refined_checks.go
  refined_checks.go:115	0x485c80		4c8d6424f8		LEAQ -0x8(SP), R12
  refined_checks.go:115	0x485c85		4d3b6610		CMPQ R12, 0x10(R14)
  refined_checks.go:115	0x485c89		0f869f010000		JBE 0x485e2e
  refined_checks.go:115	0x485c8f		55			PUSHQ BP
  refined_checks.go:115	0x485c90		4889e5			MOVQ SP, BP
  refined_checks.go:115	0x485c93		4883c480		ADDQ $-0x80, SP
  refined_checks.go:115	0x485c97		b801000000		MOVL $0x1, AX
  refined_checks.go:115	0x485c9c		31c9			XORL CX, CX
  refined_checks.go:115	0x485c9e		31d2			XORL DX, DX
  refined_checks.go:115	0x485ca0		31db			XORL BX, BX
  refined_checks.go:115	0x485ca2		be05000000		MOVL $0x5, SI
  refined_checks.go:118	0x485ca7		eb03			JMP 0x485cac
  refined_checks.go:118	0x485ca9		48ffc0			INCQ AX
  refined_checks.go:118	0x485cac		4c8b0505270b00		MOVQ os.Args+8(SB), R8
  refined_checks.go:118	0x485cb3		4c39c0			CMPQ AX, R8
  refined_checks.go:118	0x485cb6		0f8d1f010000		JGE 0x485ddb
  refined_checks.go:118	0x485cbc		0f1f4000		NOPL 0(AX)
  refined_checks.go:119	0x485cc0		0f835f010000		JAE 0x485e25
  refined_checks.go:118	0x485cc6		4c8b0de3260b00		MOVQ os.Args(SB), R9
  refined_checks.go:119	0x485ccd		4989c2			MOVQ AX, R10
  refined_checks.go:119	0x485cd0		49c1e204		SHLQ $0x4, R10
  refined_checks.go:119	0x485cd4		4f8b5c0a08		MOVQ 0x8(R10)(R9*1), R11
  refined_checks.go:119	0x485cd9		4f8b140a		MOVQ 0(R10)(R9*1), R10
  refined_checks.go:119	0x485cdd		0f1f00			NOPL 0(AX)
  refined_checks.go:119	0x485ce0		4983fb06		CMPQ R11, $0x6
  refined_checks.go:119	0x485ce4		757f			JNE 0x485d65
  refined_checks.go:119	0x485ce6		41813a2d2d7275		CMPL 0(R10), $0x75722d2d
  refined_checks.go:119	0x485ced		7576			JNE 0x485d65
  refined_checks.go:119	0x485cef		6641817a046e73		CMPW 0x4(R10), $0x736e
  refined_checks.go:119	0x485cf6		756d			JNE 0x485d65
  refined_checks.go:120	0x485cf8		48ffc0			INCQ AX
  refined_checks.go:120	0x485cfb		0f1f440000		NOPL 0(AX)(AX*1)
  refined_checks.go:121	0x485d00		4939c0			CMPQ R8, AX
  refined_checks.go:121	0x485d03		0f8e04010000		JLE 0x485e0d
  refined_checks.go:124	0x485d09		0f86f6000000		JBE 0x485e05
  refined_checks.go:131	0x485d0f		48894c2450		MOVQ CX, 0x50(SP)
  refined_checks.go:131	0x485d14		48895c2448		MOVQ BX, 0x48(SP)
  refined_checks.go:120	0x485d19		4889442458		MOVQ AX, 0x58(SP)
  refined_checks.go:131	0x485d1e		4889542470		MOVQ DX, 0x70(SP)
  refined_checks.go:124	0x485d23		48c1e004		SHLQ $0x4, AX
  refined_checks.go:124	0x485d27		4a8b1408		MOVQ 0(AX)(R9*1), DX
  refined_checks.go:124	0x485d2b		4a8b5c0808		MOVQ 0x8(AX)(R9*1), BX
  refined_checks.go:124	0x485d30		4889d0			MOVQ DX, AX
  refined_checks.go:124	0x485d33		e8082cfeff		CALL strconv.Atoi(SB)
  refined_checks.go:124	0x485d38		0f1f840000000000	NOPL 0(AX)(AX*1)
  refined_checks.go:125	0x485d40		4885db			TESTQ BX, BX
  refined_checks.go:125	0x485d43		0f85a4000000		JNE 0x485ded
  refined_checks.go:131	0x485d49		488b4c2450		MOVQ 0x50(SP), CX
  refined_checks.go:131	0x485d4e		488b5c2448		MOVQ 0x48(SP), BX
  refined_checks.go:131	0x485d53		488b542470		MOVQ 0x70(SP), DX
  refined_checks.go:133	0x485d58		4889c6			MOVQ AX, SI
  refined_checks.go:118	0x485d5b		488b442458		MOVQ 0x58(SP), AX
  refined_checks.go:129	0x485d60		e944ffffff		JMP 0x485ca9
  refined_checks.go:131	0x485d65		48ffc3			INCQ BX
  refined_checks.go:131	0x485d68		4839d9			CMPQ CX, BX
  refined_checks.go:131	0x485d6b		733f			JAE 0x485dac
  refined_checks.go:118	0x485d6d		4889442468		MOVQ AX, 0x68(SP)
  refined_checks.go:119	0x485d72		4c89542478		MOVQ R10, 0x78(SP)
  refined_checks.go:119	0x485d77		4c895c2460		MOVQ R11, 0x60(SP)
  refined_checks.go:133	0x485d7c		4889742440		MOVQ SI, 0x40(SP)
  refined_checks.go:131	0x485d81		4889d0			MOVQ DX, AX
  refined_checks.go:131	0x485d84		bf01000000		MOVL $0x1, DI
  refined_checks.go:131	0x485d89		488d3530850000		LEAQ 0x8530(IP), SI
  refined_checks.go:131	0x485d90		e84b49fcff		CALL runtime.growslice(SB)
  refined_checks.go:133	0x485d95		488b742440		MOVQ 0x40(SP), SI
  refined_checks.go:131	0x485d9a		4c8b542478		MOVQ 0x78(SP), R10
  refined_checks.go:131	0x485d9f		4c8b5c2460		MOVQ 0x60(SP), R11
  refined_checks.go:131	0x485da4		4889c2			MOVQ AX, DX
  refined_checks.go:118	0x485da7		488b442468		MOVQ 0x68(SP), AX
  refined_checks.go:131	0x485dac		4c8d43ff		LEAQ -0x1(BX), R8
  refined_checks.go:131	0x485db0		49c1e004		SHLQ $0x4, R8
  refined_checks.go:131	0x485db4		4e895c0208		MOVQ R11, 0x8(DX)(R8*1)
  refined_checks.go:131	0x485db9		833d8021110000		CMPL runtime.writeBarrier(SB), $0x0
  refined_checks.go:131	0x485dc0		7410			JE 0x485dd2
  refined_checks.go:131	0x485dc2		e879cefdff		CALL runtime.gcWriteBarrier2(SB)
  refined_checks.go:131	0x485dc7		4d8913			MOVQ R10, 0(R11)
  refined_checks.go:131	0x485dca		4e8b0c02		MOVQ 0(DX)(R8*1), R9
  refined_checks.go:131	0x485dce		4d894b08		MOVQ R9, 0x8(R11)
  refined_checks.go:131	0x485dd2		4e891402		MOVQ R10, 0(DX)(R8*1)
  refined_checks.go:131	0x485dd6		e9cefeffff		JMP 0x485ca9
  refined_checks.go:133	0x485ddb		4889f0			MOVQ SI, AX
  refined_checks.go:133	0x485dde		4889cf			MOVQ CX, DI
  refined_checks.go:133	0x485de1		4889d9			MOVQ BX, CX
  refined_checks.go:133	0x485de4		4889d3			MOVQ DX, BX
  refined_checks.go:133	0x485de7		4883ec80		SUBQ $-0x80, SP
  refined_checks.go:133	0x485deb		5d			POPQ BP
  refined_checks.go:133	0x485dec		c3			RET
  refined_checks.go:126	0x485ded		488d05cc840000		LEAQ 0x84cc(IP), AX
  refined_checks.go:126	0x485df4		488d1d05d10300		LEAQ 0x3d105(IP), BX
  refined_checks.go:126	0x485dfb		0f1f440000		NOPL 0(AX)(AX*1)
  refined_checks.go:126	0x485e00		e81bc9faff		CALL runtime.gopanic(SB)
  refined_checks.go:124	0x485e05		4c89c1			MOVQ R8, CX
  refined_checks.go:124	0x485e08		e8d3d1fdff		CALL runtime.panicIndex(SB)
  refined_checks.go:122	0x485e0d		488d05ac840000		LEAQ 0x84ac(IP), AX
  refined_checks.go:122	0x485e14		488d1dd5d00300		LEAQ 0x3d0d5(IP), BX
  refined_checks.go:122	0x485e1b		0f1f440000		NOPL 0(AX)(AX*1)
  refined_checks.go:122	0x485e20		e8fbc8faff		CALL runtime.gopanic(SB)
  refined_checks.go:119	0x485e25		4c89c1			MOVQ R8, CX
  refined_checks.go:119	0x485e28		e8b3d1fdff		CALL runtime.panicIndex(SB)
  refined_checks.go:119	0x485e2d		90			NOPL
  refined_checks.go:115	0x485e2e		e88db0fdff		CALL runtime.morestack_noctxt.abi0(SB)
  refined_checks.go:115	0x485e33		e948feffff		JMP main.parseArgs(SB)

TEXT main.main(SB) /mnt/c/Users/MarkusWagner/dev/botlish/bench/equivalents/go/refined_checks.go
  refined_checks.go:136	0x485e40		4c8da42478ffffff	LEAQ 0xffffff78(SP), R12
  refined_checks.go:136	0x485e48		4d3b6610		CMPQ R12, 0x10(R14)
  refined_checks.go:136	0x485e4c		0f8614030000		JBE 0x486166
  refined_checks.go:136	0x485e52		55			PUSHQ BP
  refined_checks.go:136	0x485e53		4889e5			MOVQ SP, BP
  refined_checks.go:136	0x485e56		4881ec00010000		SUBQ $0x100, SP
  refined_checks.go:137	0x485e5d		0f1f00			NOPL 0(AX)
  refined_checks.go:137	0x485e60		e81bfeffff		CALL main.parseArgs(SB)
  refined_checks.go:137	0x485e65		4889442468		MOVQ AX, 0x68(SP)
  refined_checks.go:142	0x485e6a		4885c9			TESTQ CX, CX
  refined_checks.go:142	0x485e6d		7507			JNE 0x485e76
  refined_checks.go:142	0x485e6f		ba90010000		MOVL $0x190, DX
  refined_checks.go:142	0x485e74		eb4a			JMP 0x485ec0
  refined_checks.go:137	0x485e76		48894c2478		MOVQ CX, 0x78(SP)
  refined_checks.go:137	0x485e7b		48899c24c0000000	MOVQ BX, 0xc0(SP)
  refined_checks.go:143	0x485e83		488b03			MOVQ 0(BX), AX
  refined_checks.go:143	0x485e86		488b5308		MOVQ 0x8(BX), DX
  refined_checks.go:143	0x485e8a		b90a000000		MOVL $0xa, CX
  refined_checks.go:143	0x485e8f		bf40000000		MOVL $0x40, DI
  refined_checks.go:143	0x485e94		4889d3			MOVQ DX, BX
  refined_checks.go:143	0x485e97		e8e425feff		CALL strconv.ParseInt(SB)
  refined_checks.go:143	0x485e9c		0f1f4000		NOPL 0(AX)
  refined_checks.go:144	0x485ea0		4885db			TESTQ BX, BX
  refined_checks.go:144	0x485ea3		0f85a5020000		JNE 0x48614e
  refined_checks.go:149	0x485ea9		488b4c2478		MOVQ 0x78(SP), CX
  refined_checks.go:150	0x485eae		488b9c24c0000000	MOVQ 0xc0(SP), BX
  refined_checks.go:159	0x485eb6		4889c2			MOVQ AX, DX
  refined_checks.go:162	0x485eb9		488b442468		MOVQ 0x68(SP), AX
  refined_checks.go:162	0x485ebe		6690			NOPW
  refined_checks.go:149	0x485ec0		4883f901		CMPQ CX, $0x1
  refined_checks.go:149	0x485ec4		7e0a			JLE 0x485ed0
  refined_checks.go:150	0x485ec6		4c8b5318		MOVQ 0x18(BX), R10
  refined_checks.go:150	0x485eca		4c8b5b10		MOVQ 0x10(BX), R11
  refined_checks.go:150	0x485ece		eb10			JMP 0x485ee0
  refined_checks.go:150	0x485ed0		41ba16000000		MOVL $0x16, R10
  refined_checks.go:150	0x485ed6		4c8d1df2db0100		LEAQ 0x1dbf2(IP), R11
  refined_checks.go:150	0x485edd		0f1f00			NOPL 0(AX)
  refined_checks.go:152	0x485ee0		4883f902		CMPQ CX, $0x2
  refined_checks.go:152	0x485ee4		7e0a			JLE 0x485ef0
  refined_checks.go:153	0x485ee6		4c8b6328		MOVQ 0x28(BX), R12
  refined_checks.go:153	0x485eea		4c8b6b20		MOVQ 0x20(BX), R13
  refined_checks.go:153	0x485eee		eb10			JMP 0x485f00
  refined_checks.go:153	0x485ef0		41bc0c000000		MOVL $0xc, R12
  refined_checks.go:153	0x485ef6		4c8d2dbebe0100		LEAQ 0x1bebe(IP), R13
  refined_checks.go:153	0x485efd		0f1f00			NOPL 0(AX)
  refined_checks.go:155	0x485f00		4883f903		CMPQ CX, $0x3
  refined_checks.go:155	0x485f04		7e0a			JLE 0x485f10
  refined_checks.go:156	0x485f06		4c8b7b38		MOVQ 0x38(BX), R15
  refined_checks.go:156	0x485f0a		488b4b30		MOVQ 0x30(BX), CX
  refined_checks.go:156	0x485f0e		eb0d			JMP 0x485f1d
  refined_checks.go:156	0x485f10		41bf03000000		MOVL $0x3, R15
  refined_checks.go:156	0x485f16		488d0d84b00100		LEAQ 0x1b084(IP), CX
  refined_checks.go:159	0x485f1d		4c89ac24a8000000	MOVQ R13, 0xa8(SP)
  refined_checks.go:159	0x485f25		4c89642458		MOVQ R12, 0x58(SP)
  refined_checks.go:159	0x485f2a		4c897c2470		MOVQ R15, 0x70(SP)
  refined_checks.go:159	0x485f2f		48898c24b8000000	MOVQ CX, 0xb8(SP)
  refined_checks.go:159	0x485f37		4c899c24b0000000	MOVQ R11, 0xb0(SP)
  refined_checks.go:159	0x485f3f		4c89542460		MOVQ R10, 0x60(SP)
  refined_checks.go:159	0x485f44		4889942480000000	MOVQ DX, 0x80(SP)
  refined_checks.go:159	0x485f4c		4889d0			MOVQ DX, AX
  refined_checks.go:159	0x485f4f		4c89db			MOVQ R11, BX
  refined_checks.go:159	0x485f52		4c89ef			MOVQ R13, DI
  refined_checks.go:159	0x485f55		4c89e6			MOVQ R12, SI
  refined_checks.go:159	0x485f58		4989c8			MOVQ CX, R8
  refined_checks.go:159	0x485f5b		4d89f9			MOVQ R15, R9
  refined_checks.go:159	0x485f5e		4c89d1			MOVQ R10, CX
  refined_checks.go:159	0x485f61		e8fafbffff		CALL main.runOnce(SB)
  refined_checks.go:161	0x485f66		440f117c2448		MOVUPS X15, 0x48(SP)
  refined_checks.go:162	0x485f6c		488b442468		MOVQ 0x68(SP), AX
  refined_checks.go:162	0x485f71		f20f100567ce0300	MOVSD_XMM $f64.43e0000000000000(SB), X0
  refined_checks.go:162	0x485f79		eb0b			JMP 0x485f86
  refined_checks.go:162	0x485f7b		488b842488000000	MOVQ 0x88(SP), AX
  refined_checks.go:162	0x485f83		48ffc8			DECQ AX
  refined_checks.go:172	0x485f86		f20f11842490000000	MOVSD_XMM X0, 0x90(SP)
  refined_checks.go:162	0x485f8f		4885c0			TESTQ AX, AX
  refined_checks.go:162	0x485f92		0f8eae000000		JLE 0x486046
  refined_checks.go:162	0x485f98		4889842488000000	MOVQ AX, 0x88(SP)
  refined_checks.go:163	0x485fa0		e89b39ffff		CALL time.Now(SB)
  refined_checks.go:163	0x485fa5		48898424a0000000	MOVQ AX, 0xa0(SP)
  refined_checks.go:163	0x485fad		48899c2498000000	MOVQ BX, 0x98(SP)
  refined_checks.go:163	0x485fb5		48898c24c8000000	MOVQ CX, 0xc8(SP)
  refined_checks.go:164	0x485fbd		488bbc24a8000000	MOVQ 0xa8(SP), DI
  refined_checks.go:164	0x485fc5		488b742458		MOVQ 0x58(SP), SI
  refined_checks.go:164	0x485fca		4c8b8424b8000000	MOVQ 0xb8(SP), R8
  refined_checks.go:164	0x485fd2		4c8b4c2470		MOVQ 0x70(SP), R9
  refined_checks.go:164	0x485fd7		488b842480000000	MOVQ 0x80(SP), AX
  refined_checks.go:164	0x485fdf		488b9c24b0000000	MOVQ 0xb0(SP), BX
  refined_checks.go:164	0x485fe7		488b4c2460		MOVQ 0x60(SP), CX
  refined_checks.go:164	0x485fec		e86ffbffff		CALL main.runOnce(SB)
  refined_checks.go:164	0x485ff1		0f100424		MOVUPS 0(SP), X0
  refined_checks.go:164	0x485ff5		0f11442448		MOVUPS X0, 0x48(SP)
  refined_checks.go:165	0x485ffa		488b8424a0000000	MOVQ 0xa0(SP), AX
  refined_checks.go:165	0x486002		488b9c2498000000	MOVQ 0x98(SP), BX
  refined_checks.go:165	0x48600a		488b8c24c8000000	MOVQ 0xc8(SP), CX
  refined_checks.go:165	0x486012		e86938ffff		CALL time.Since(SB)
  refined_checks.go:165	0x486017		0f57c0			XORPS X0, X0
  refined_checks.go:165	0x48601a		f2480f2ac0		CVTSI2SDQ AX, X0
  refined_checks.go:165	0x48601f		f20f100db1cd0300	MOVSD_XMM $f64.408f400000000000(SB), X1
  refined_checks.go:165	0x486027		f20f5ec1		DIVSD X1, X0
  refined_checks.go:166	0x48602b		f20f10942490000000	MOVSD_XMM 0x90(SP), X2
  refined_checks.go:166	0x486034		660f2ed0		UCOMISD X0, X2
  refined_checks.go:166	0x486038		0f873dffffff		JA 0x485f7b
  refined_checks.go:172	0x48603e		0f10c2			MOVUPS X2, X0
  refined_checks.go:166	0x486041		e935ffffff		JMP 0x485f7b
  refined_checks.go:171	0x486046		440f11bc24e0000000	MOVUPS X15, 0xe0(SP)
  refined_checks.go:171	0x48604f		440f11bc24f0000000	MOVUPS X15, 0xf0(SP)
  refined_checks.go:171	0x486058		488b442448		MOVQ 0x48(SP), AX
  refined_checks.go:171	0x48605d		0f1f00			NOPL 0(AX)
  refined_checks.go:171	0x486060		e8fb4bf8ff		CALL runtime.convT64(SB)
  refined_checks.go:171	0x486065		488d0d14840000		LEAQ 0x8414(IP), CX
  refined_checks.go:171	0x48606c		48898c24e0000000	MOVQ CX, 0xe0(SP)
  refined_checks.go:171	0x486074		48898424e8000000	MOVQ AX, 0xe8(SP)
  refined_checks.go:171	0x48607c		488b442450		MOVQ 0x50(SP), AX
  refined_checks.go:171	0x486081		e8da4bf8ff		CALL runtime.convT64(SB)
  refined_checks.go:171	0x486086		488d0df3830000		LEAQ 0x83f3(IP), CX
  refined_checks.go:171	0x48608d		48898c24f0000000	MOVQ CX, 0xf0(SP)
  refined_checks.go:171	0x486095		48898424f8000000	MOVQ AX, 0xf8(SP)
  refined_checks.go:172	0x48609d		f20f10842490000000	MOVSD_XMM 0x90(SP), X0
  refined_checks.go:172	0x4860a6		66480f7ec1		MOVQ X0, CX
  refined_checks.go:172	0x4860ab		48898c24a0000000	MOVQ CX, 0xa0(SP)
  print.go:233		0x4860b3		488b1d8e200b00		MOVQ os.Stdout(SB), BX
  print.go:233		0x4860ba		488d0507d30300		LEAQ go:itab.*os.File,io.Writer(SB), AX
  print.go:233		0x4860c1		bf10000000		MOVL $0x10, DI
  print.go:233		0x4860c6		488db424e0000000	LEAQ 0xe0(SP), SI
  print.go:233		0x4860ce		41b802000000		MOVL $0x2, R8
  print.go:233		0x4860d4		4d89c1			MOVQ R8, R9
  print.go:233		0x4860d7		488d0d14c70100		LEAQ 0x1c714(IP), CX
  print.go:233		0x4860de		6690			NOPW
  print.go:233		0x4860e0		e8db7effff		CALL fmt.Fprintf(SB)
  refined_checks.go:172	0x4860e5		440f11bc24d0000000	MOVUPS X15, 0xd0(SP)
  refined_checks.go:172	0x4860ee		488b8424a0000000	MOVQ 0xa0(SP), AX
  refined_checks.go:172	0x4860f6		e8654bf8ff		CALL runtime.convT64(SB)
  refined_checks.go:172	0x4860fb		488d0d7e850000		LEAQ 0x857e(IP), CX
  refined_checks.go:172	0x486102		48898c24d0000000	MOVQ CX, 0xd0(SP)
  refined_checks.go:172	0x48610a		48898424d8000000	MOVQ AX, 0xd8(SP)
  print.go:233		0x486112		488b1d2f200b00		MOVQ os.Stdout(SB), BX
  print.go:233		0x486119		488d05a8d20300		LEAQ go:itab.*os.File,io.Writer(SB), AX
  print.go:233		0x486120		488d0dd7c10100		LEAQ 0x1c1d7(IP), CX
  print.go:233		0x486127		bf0e000000		MOVL $0xe, DI
  print.go:233		0x48612c		488db424d0000000	LEAQ 0xd0(SP), SI
  print.go:233		0x486134		41b801000000		MOVL $0x1, R8
  print.go:233		0x48613a		4d89c1			MOVQ R8, R9
  print.go:233		0x48613d		0f1f00			NOPL 0(AX)
  print.go:233		0x486140		e87b7effff		CALL fmt.Fprintf(SB)
  refined_checks.go:173	0x486145		4881c400010000		ADDQ $0x100, SP
  refined_checks.go:173	0x48614c		5d			POPQ BP
  refined_checks.go:173	0x48614d		c3			RET
  refined_checks.go:145	0x48614e		488d056b810000		LEAQ 0x816b(IP), AX
  refined_checks.go:145	0x486155		488d1db4cd0300		LEAQ 0x3cdb4(IP), BX
  refined_checks.go:145	0x48615c		0f1f4000		NOPL 0(AX)
  refined_checks.go:145	0x486160		e8bbc5faff		CALL runtime.gopanic(SB)
  refined_checks.go:145	0x486165		90			NOPL
  refined_checks.go:136	0x486166		e855adfdff		CALL runtime.morestack_noctxt.abi0(SB)
  refined_checks.go:136	0x48616b		e9d0fcffff		JMP main.main(SB)

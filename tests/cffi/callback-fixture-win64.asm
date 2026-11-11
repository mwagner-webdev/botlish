; callback-fixture-win64.asm -- callback-fixture.c's assembly for Windows
; x86-64 (Win64), in MASM for Microsoft's ml64 (WINDOWS-X86-64-MILESTONE-9.md).
;
; Test infrastructure only: tests/ctoolchain.tcl assembles it beside
; callback-fixture.c's object (compiled by cl, which has no x64 inline
; assembly) into botlish_callback_fixture.lib. Two callers of a Botlish
; callback's C function pointer, each doing what C compiled by cl may do
; but cannot be made to do on purpose:
;
;   * cbx_win64_call_without_frame calls from a frame Windows' unwinder
;     cannot cross: it has no function table entry (a plain PROC: ml64
;     writes no .pdata for it), so the unwinder takes it for a leaf and
;     reads its return address at its stack pointer -- where it stored 0 --
;     and its RBP holds no frame (16). A collector that unwound C's frames
;     to find the Botlish frames waiting below them would stop here; the
;     runtime's walk jumps from the callback's entry frame to the
;     transition's record and never reads this frame;
;   * cbx_win64_abi_call places a mixed Win64 call by hand -- an int with
;     dirty upper bits, a double, a float third, an integer fourth, then a
;     double, an int, a signed char and a double on the stack, each narrow
;     one with dirty bits above its width, and the unused register of
;     every register position dirty -- with a sentinel in every
;     nonvolatile register (RBX, RBP, RDI, RSI, R12-R15, XMM6-XMM15), and
;     reports which of them the call did not preserve.
;
; Win64 (Microsoft's x64 calling convention): the first four arguments by
; position, an integer or pointer in rcx, rdx, r8, r9 and a float or double
; in xmm0-xmm3 (the other register of the same position unused); every later
; one in its own 8-byte stack slot, above the 32 bytes of shadow space the
; caller reserves at its stack pointer; the result in rax (xmm0); the stack
; 16-byte aligned at a call; RBX, RBP, RDI, RSI, R12-R15 and XMM6-XMM15
; preserved by the callee.

.data
ALIGN 16
; XMM6-XMM15's sentinels, 16 bytes each (read with movups: no alignment assumed).
abi_xmm QWORD 06666666666666601h, 06666666666666602h
        QWORD 07777777777777701h, 07777777777777702h
        QWORD 08888888888888801h, 08888888888888802h
        QWORD 09999999999999901h, 09999999999999902h
        QWORD 0AAAAAAAAAAAAAA01h, 0AAAAAAAAAAAAAA02h
        QWORD 0BBBBBBBBBBBBBB01h, 0BBBBBBBBBBBBBB02h
        QWORD 0CCCCCCCCCCCCCC01h, 0CCCCCCCCCCCCCC02h
        QWORD 0DDDDDDDDDDDDDD01h, 0DDDDDDDDDDDDDD02h
        QWORD 0EEEEEEEEEEEEEE01h, 0EEEEEEEEEEEEEE02h
        QWORD 0F0F0F0F0F0F0F01h, 0F0F0F0F0F0F0F02h

.code

; int cbx_win64_call_without_frame(int (*f)(int), int x): f(x), called from
; a frame with no function table entry (see the header). 40 bytes of frame
; below the two pushes: the callee's 32 bytes of shadow space and 8 to
; align the stack, all of it zeroed -- so the word at the stack pointer,
; where Windows' unwinder looks for a leaf's return address, is 0.
cbx_win64_call_without_frame PROC
    push rbp
    push rbx
    sub rsp, 40
    xor eax, eax
    mov qword ptr [rsp], rax
    mov qword ptr [rsp + 8], rax
    mov qword ptr [rsp + 16], rax
    mov qword ptr [rsp + 24], rax
    mov qword ptr [rsp + 32], rax
    mov rax, rcx
    mov ecx, edx
    mov ebp, 16
    call rax
    add rsp, 40
    pop rbx
    pop rbp
    ret
cbx_win64_call_without_frame ENDP

; long long cbx_win64_abi_call(long long (*f)(int, double, float, long long,
;     double, int, signed char, double), unsigned long long *changed):
; calls f(-5, double 0x7ff4000000000abc, float 0x7fa00abc, 0x123456789,
; double 0x8000000000000000, 77, -3, double 0x0000000000000001) and returns
; its result; *changed receives a bit per nonvolatile register the call did
; not preserve (RBX 1, RBP 2, RDI 4, RSI 8, R12 10h ... R15 80h, XMM6 100h
; ... XMM15 20000h). Its frame: eight pushes, then 232 bytes -- the
; outgoing area (32 bytes of shadow space, four stack arguments) at rsp,
; XMM6-XMM15 saved at rsp+64, the CHANGED pointer at rsp+224 -- which
; leaves the stack 16-byte aligned at the call. A function table entry
; describes all of it (PROC FRAME).
cbx_win64_abi_call PROC FRAME
    push rbp
    .pushreg rbp
    push rbx
    .pushreg rbx
    push rdi
    .pushreg rdi
    push rsi
    .pushreg rsi
    push r12
    .pushreg r12
    push r13
    .pushreg r13
    push r14
    .pushreg r14
    push r15
    .pushreg r15
    sub rsp, 232
    .allocstack 232
    movaps xmmword ptr [rsp + 64], xmm6
    .savexmm128 xmm6, 64
    movaps xmmword ptr [rsp + 80], xmm7
    .savexmm128 xmm7, 80
    movaps xmmword ptr [rsp + 96], xmm8
    .savexmm128 xmm8, 96
    movaps xmmword ptr [rsp + 112], xmm9
    .savexmm128 xmm9, 112
    movaps xmmword ptr [rsp + 128], xmm10
    .savexmm128 xmm10, 128
    movaps xmmword ptr [rsp + 144], xmm11
    .savexmm128 xmm11, 144
    movaps xmmword ptr [rsp + 160], xmm12
    .savexmm128 xmm12, 160
    movaps xmmword ptr [rsp + 176], xmm13
    .savexmm128 xmm13, 176
    movaps xmmword ptr [rsp + 192], xmm14
    .savexmm128 xmm14, 192
    movaps xmmword ptr [rsp + 208], xmm15
    .savexmm128 xmm15, 208
    .endprolog
    mov qword ptr [rsp + 224], rdx
    mov r10, rcx
    ; The sentinels.
    mov rbx, 0B0B0B0B0B0B0B011h
    mov rbp, 0B0B0B0B0B0B0B022h
    mov rdi, 0B0B0B0B0B0B0B033h
    mov rsi, 0B0B0B0B0B0B0B044h
    mov r12, 0B0B0B0B0B0B0B055h
    mov r13, 0B0B0B0B0B0B0B066h
    mov r14, 0B0B0B0B0B0B0B077h
    mov r15, 0B0B0B0B0B0B0B088h
    movups xmm6, xmmword ptr [abi_xmm]
    movups xmm7, xmmword ptr [abi_xmm + 16]
    movups xmm8, xmmword ptr [abi_xmm + 32]
    movups xmm9, xmmword ptr [abi_xmm + 48]
    movups xmm10, xmmword ptr [abi_xmm + 64]
    movups xmm11, xmmword ptr [abi_xmm + 80]
    movups xmm12, xmmword ptr [abi_xmm + 96]
    movups xmm13, xmmword ptr [abi_xmm + 112]
    movups xmm14, xmmword ptr [abi_xmm + 128]
    movups xmm15, xmmword ptr [abi_xmm + 144]
    ; The stack arguments, each narrow one with dirty bits above it: the
    ; double 0x8000000000000000 (-0), the int 77, the signed char -3, the
    ; double 0x1 (the least subnormal).
    mov rax, 8000000000000000h
    mov qword ptr [rsp + 32], rax
    mov rax, 0FFFFFFFF0000004Dh
    mov qword ptr [rsp + 40], rax
    mov rax, 55555555555555FDh
    mov qword ptr [rsp + 48], rax
    mov qword ptr [rsp + 56], 1
    ; The register arguments by position: 1 an int (rcx, dirty above 32
    ; bits), 2 a double (xmm1), 3 a float (xmm2, dirty above 32 bits), 4 an
    ; integer (r9); every unused register of those positions dirty.
    mov rcx, 55555555FFFFFFFBh
    mov rax, 7FF4000000000ABCh
    movq xmm1, rax
    mov rax, 555555557FA00ABCh
    movq xmm2, rax
    mov r9, 123456789h
    mov rdx, 0DEADBEEFDEADBEEFh
    mov r8, 0FEEDFACEFEEDFACEh
    movq xmm0, rdx
    movq xmm3, r8
    call r10
    ; RAX holds the result; R11 gathers the registers that changed.
    xor r11d, r11d
    mov r10, 0B0B0B0B0B0B0B011h
    cmp rbx, r10
    je @F
    or r11, 1h
@@:
    mov r10, 0B0B0B0B0B0B0B022h
    cmp rbp, r10
    je @F
    or r11, 2h
@@:
    mov r10, 0B0B0B0B0B0B0B033h
    cmp rdi, r10
    je @F
    or r11, 4h
@@:
    mov r10, 0B0B0B0B0B0B0B044h
    cmp rsi, r10
    je @F
    or r11, 8h
@@:
    mov r10, 0B0B0B0B0B0B0B055h
    cmp r12, r10
    je @F
    or r11, 10h
@@:
    mov r10, 0B0B0B0B0B0B0B066h
    cmp r13, r10
    je @F
    or r11, 20h
@@:
    mov r10, 0B0B0B0B0B0B0B077h
    cmp r14, r10
    je @F
    or r11, 40h
@@:
    mov r10, 0B0B0B0B0B0B0B088h
    cmp r15, r10
    je @F
    or r11, 80h
@@:
    movups xmm0, xmmword ptr [abi_xmm]
    pcmpeqb xmm0, xmm6
    pmovmskb ecx, xmm0
    cmp ecx, 0FFFFh
    je @F
    or r11, 100h
@@:
    movups xmm0, xmmword ptr [abi_xmm + 16]
    pcmpeqb xmm0, xmm7
    pmovmskb ecx, xmm0
    cmp ecx, 0FFFFh
    je @F
    or r11, 200h
@@:
    movups xmm0, xmmword ptr [abi_xmm + 32]
    pcmpeqb xmm0, xmm8
    pmovmskb ecx, xmm0
    cmp ecx, 0FFFFh
    je @F
    or r11, 400h
@@:
    movups xmm0, xmmword ptr [abi_xmm + 48]
    pcmpeqb xmm0, xmm9
    pmovmskb ecx, xmm0
    cmp ecx, 0FFFFh
    je @F
    or r11, 800h
@@:
    movups xmm0, xmmword ptr [abi_xmm + 64]
    pcmpeqb xmm0, xmm10
    pmovmskb ecx, xmm0
    cmp ecx, 0FFFFh
    je @F
    or r11, 1000h
@@:
    movups xmm0, xmmword ptr [abi_xmm + 80]
    pcmpeqb xmm0, xmm11
    pmovmskb ecx, xmm0
    cmp ecx, 0FFFFh
    je @F
    or r11, 2000h
@@:
    movups xmm0, xmmword ptr [abi_xmm + 96]
    pcmpeqb xmm0, xmm12
    pmovmskb ecx, xmm0
    cmp ecx, 0FFFFh
    je @F
    or r11, 4000h
@@:
    movups xmm0, xmmword ptr [abi_xmm + 112]
    pcmpeqb xmm0, xmm13
    pmovmskb ecx, xmm0
    cmp ecx, 0FFFFh
    je @F
    or r11, 8000h
@@:
    movups xmm0, xmmword ptr [abi_xmm + 128]
    pcmpeqb xmm0, xmm14
    pmovmskb ecx, xmm0
    cmp ecx, 0FFFFh
    je @F
    or r11, 10000h
@@:
    movups xmm0, xmmword ptr [abi_xmm + 144]
    pcmpeqb xmm0, xmm15
    pmovmskb ecx, xmm0
    cmp ecx, 0FFFFh
    je @F
    or r11, 20000h
@@:
    mov rdx, qword ptr [rsp + 224]
    mov qword ptr [rdx], r11
    movaps xmm6, xmmword ptr [rsp + 64]
    movaps xmm7, xmmword ptr [rsp + 80]
    movaps xmm8, xmmword ptr [rsp + 96]
    movaps xmm9, xmmword ptr [rsp + 112]
    movaps xmm10, xmmword ptr [rsp + 128]
    movaps xmm11, xmmword ptr [rsp + 144]
    movaps xmm12, xmmword ptr [rsp + 160]
    movaps xmm13, xmmword ptr [rsp + 176]
    movaps xmm14, xmmword ptr [rsp + 192]
    movaps xmm15, xmmword ptr [rsp + 208]
    add rsp, 232
    pop r15
    pop r14
    pop r13
    pop r12
    pop rsi
    pop rdi
    pop rbx
    pop rbp
    ret
cbx_win64_abi_call ENDP

END

; nl-win64-probe.asm -- a Win64 caller that checks what a callee leaves of the
; nonvolatile registers (tests/native-library.test, nl-windows-win64-abi;
; WINDOWS-X86-64-MILESTONE-8.md, "The C ABI"). Assembled by MSVC's ml64.
;
;   int32_t nl_probe(void *fn, const uint64_t *args, uint64_t *changed);
;
; Calls FN with the nine integer-class arguments ARGS[0..8] in their Win64
; places -- RCX, RDX, R8 and R9, then the stack after the 32-byte shadow
; space, the stack pointer 16-byte aligned at the call -- every nonvolatile
; register holding a sentinel of its own (RBX, RBP, RDI, RSI, R12-R15, and
; XMM6-XMM15 in both halves), and writes to *CHANGED a mask of the
; nonvolatile registers whose values differ after the call: bit 0 RBX, 1
; RBP, 2 RDI, 3 RSI, 4-7 R12-R15, 8+N XMM(6+N). Returns FN's 32-bit result.
; It is itself a correct Win64 function: it saves and restores every
; nonvolatile register it uses, and states its prologue as unwind codes.

.code

nl_probe PROC FRAME
    push rbx
    .pushreg rbx
    push rbp
    .pushreg rbp
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
    ; 8 (the return address) + 64 (the pushes) + 264 = 336: aligned.
    ; [rsp, rsp+32) the callee's shadow space, [rsp+32, rsp+72) its stack
    ; arguments 5 to 9, [rsp+72] CHANGED, [rsp+80] FN, [rsp+96, rsp+256)
    ; the caller's XMM6-XMM15.
    sub rsp, 264
    .allocstack 264
    movdqa [rsp+96], xmm6
    .savexmm128 xmm6, 96
    movdqa [rsp+112], xmm7
    .savexmm128 xmm7, 112
    movdqa [rsp+128], xmm8
    .savexmm128 xmm8, 128
    movdqa [rsp+144], xmm9
    .savexmm128 xmm9, 144
    movdqa [rsp+160], xmm10
    .savexmm128 xmm10, 160
    movdqa [rsp+176], xmm11
    .savexmm128 xmm11, 176
    movdqa [rsp+192], xmm12
    .savexmm128 xmm12, 192
    movdqa [rsp+208], xmm13
    .savexmm128 xmm13, 208
    movdqa [rsp+224], xmm14
    .savexmm128 xmm14, 224
    movdqa [rsp+240], xmm15
    .savexmm128 xmm15, 240
    .endprolog

    mov [rsp+72], r8
    mov [rsp+80], rcx

    mov rax, rdx
    mov r10, [rax+32]
    mov [rsp+32], r10
    mov r10, [rax+40]
    mov [rsp+40], r10
    mov r10, [rax+48]
    mov [rsp+48], r10
    mov r10, [rax+56]
    mov [rsp+56], r10
    mov r10, [rax+64]
    mov [rsp+64], r10
    mov rcx, [rax]
    mov rdx, [rax+8]
    mov r8, [rax+16]
    mov r9, [rax+24]

    mov rbx, 01111111111111111h
    mov rbp, 02222222222222222h
    mov rdi, 03333333333333333h
    mov rsi, 04444444444444444h
    mov r12, 05555555555555555h
    mov r13, 06666666666666666h
    mov r14, 07777777777777777h
    mov r15, 08888888888888888h
    mov r10, 0A6A6A6A6A6A6A6A6h
    movq xmm6, r10
    punpcklqdq xmm6, xmm6
    mov r10, 0A7A7A7A7A7A7A7A7h
    movq xmm7, r10
    punpcklqdq xmm7, xmm7
    mov r10, 0A8A8A8A8A8A8A8A8h
    movq xmm8, r10
    punpcklqdq xmm8, xmm8
    mov r10, 0A9A9A9A9A9A9A9A9h
    movq xmm9, r10
    punpcklqdq xmm9, xmm9
    mov r10, 0AAAAAAAAAAAAAAAAh
    movq xmm10, r10
    punpcklqdq xmm10, xmm10
    mov r10, 0ABABABABABABABABh
    movq xmm11, r10
    punpcklqdq xmm11, xmm11
    mov r10, 0ACACACACACACACACh
    movq xmm12, r10
    punpcklqdq xmm12, xmm12
    mov r10, 0ADADADADADADADADh
    movq xmm13, r10
    punpcklqdq xmm13, xmm13
    mov r10, 0AEAEAEAEAEAEAEAEh
    movq xmm14, r10
    punpcklqdq xmm14, xmm14
    mov r10, 0AFAFAFAFAFAFAFAFh
    movq xmm15, r10
    punpcklqdq xmm15, xmm15

    call qword ptr [rsp+80]

    ; RAX holds the status; R10 and R11 are free.
    xor r11, r11
    mov r10, 01111111111111111h
    cmp rbx, r10
    je rbx_ok
    or r11, 1
rbx_ok:
    mov r10, 02222222222222222h
    cmp rbp, r10
    je rbp_ok
    or r11, 2
rbp_ok:
    mov r10, 03333333333333333h
    cmp rdi, r10
    je rdi_ok
    or r11, 4
rdi_ok:
    mov r10, 04444444444444444h
    cmp rsi, r10
    je rsi_ok
    or r11, 8
rsi_ok:
    mov r10, 05555555555555555h
    cmp r12, r10
    je r12_ok
    or r11, 16
r12_ok:
    mov r10, 06666666666666666h
    cmp r13, r10
    je r13_ok
    or r11, 32
r13_ok:
    mov r10, 07777777777777777h
    cmp r14, r10
    je r14_ok
    or r11, 64
r14_ok:
    mov r10, 08888888888888888h
    cmp r15, r10
    je r15_ok
    or r11, 128
r15_ok:

    ; Each XMM register through the (now free) shadow space: both halves
    ; against its sentinel.
CHECKXMM MACRO reg, pattern, bit
    LOCAL bad, done
    movdqu [rsp], reg
    mov r10, pattern
    cmp [rsp], r10
    jne bad
    cmp [rsp+8], r10
    je done
bad:
    bts r11, bit
done:
ENDM
    CHECKXMM xmm6, 0A6A6A6A6A6A6A6A6h, 8
    CHECKXMM xmm7, 0A7A7A7A7A7A7A7A7h, 9
    CHECKXMM xmm8, 0A8A8A8A8A8A8A8A8h, 10
    CHECKXMM xmm9, 0A9A9A9A9A9A9A9A9h, 11
    CHECKXMM xmm10, 0AAAAAAAAAAAAAAAAh, 12
    CHECKXMM xmm11, 0ABABABABABABABABh, 13
    CHECKXMM xmm12, 0ACACACACACACACACh, 14
    CHECKXMM xmm13, 0ADADADADADADADADh, 15
    CHECKXMM xmm14, 0AEAEAEAEAEAEAEAEh, 16
    CHECKXMM xmm15, 0AFAFAFAFAFAFAFAFh, 17

    mov r10, [rsp+72]
    mov [r10], r11

    movdqa xmm6, [rsp+96]
    movdqa xmm7, [rsp+112]
    movdqa xmm8, [rsp+128]
    movdqa xmm9, [rsp+144]
    movdqa xmm10, [rsp+160]
    movdqa xmm11, [rsp+176]
    movdqa xmm12, [rsp+192]
    movdqa xmm13, [rsp+208]
    movdqa xmm14, [rsp+224]
    movdqa xmm15, [rsp+240]
    add rsp, 264
    pop r15
    pop r14
    pop r13
    pop r12
    pop rsi
    pop rdi
    pop rbp
    pop rbx
    ret
nl_probe ENDP

END

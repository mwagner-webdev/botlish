; fixture-win64.asm -- fixture.c's assembly for Windows x86-64 (Win64), in
; MASM for Microsoft's ml64 (WINDOWS-X86-64-MILESTONE-2.md, "ABI fixtures").
;
; Test infrastructure only: tests/ctoolchain.tcl assembles it beside
; fixture.c's object (compiled by cl, which has no x64 inline assembly) into
; botlish_cffi_fixture.lib. Each function is the Win64 text of one of
; fixture.c's GNU-syntax assembly functions, for what C cannot observe: a
; result register's bits beyond its width, and the registers and stack
; bytes a call arrives in.
;
; Win64 (Microsoft's x64 calling convention): the first four arguments by
; position, an integer or pointer in rcx, rdx, r8, r9 and a float or double
; in xmm0-xmm3 (the other register of the same position unused); every later
; one in its own 8-byte stack slot, above the 32 bytes of shadow space the
; caller reserves at its stack pointer; the result in rax (xmm0); the stack
; 16-byte aligned at a call.

EXTERN bcf_capture_record_win64:PROC
EXTERN bcf_vcapture_record:PROC

.code

; Narrow results with dirty upper register bits: 0x80 (as unsigned char),
; -128 (as signed char), 0x8000, -32768, 0xfffffff0 and -16, every higher
; bit of rax set the other way. The caller must extend the result itself.
bcf_dirty_uchar PROC
    mov rax, 5555555555555580h
    ret
bcf_dirty_uchar ENDP

bcf_dirty_schar PROC
    mov rax, 5555555555555580h
    ret
bcf_dirty_schar ENDP

bcf_dirty_ushort PROC
    mov rax, 5555555555558000h
    ret
bcf_dirty_ushort ENDP

bcf_dirty_short PROC
    mov rax, 5555555555558000h
    ret
bcf_dirty_short ENDP

bcf_dirty_uint PROC
    mov rax, 55555555FFFFFFF0h
    ret
bcf_dirty_uint ENDP

bcf_dirty_int PROC
    mov rax, 55555555FFFFFFF0h
    ret
bcf_dirty_int ENDP

; _Bool results: true and false with dirty bits above the byte, and a byte
; that is no _Bool (2).
bcf_dirty_bool_true PROC
    mov rax, 5555555555555501h
    ret
bcf_dirty_bool_true ENDP

bcf_dirty_bool_false PROC
    mov rax, 5555555555555500h
    ret
bcf_dirty_bool_false ENDP

bcf_invalid_bool PROC
    mov eax, 2
    ret
bcf_invalid_bool ENDP

; The machine state a call arrives in, saved before any compiled code runs:
; rcx, rdx, r8, r9 and the low 64 bits of xmm0-xmm3 (the save area at rsp+32,
; above the callee's own shadow space for the call it makes), and the
; caller's stack pointer at its call -- entry rsp plus the return address,
; where the caller's 32-byte shadow space and then its stack arguments are.
; bcf_capture_record_win64(saved, stack) keeps them and returns 0. 104 bytes
; of frame: 32 of shadow space, 64 of save area, 8 to align the stack.
bcf_capture PROC FRAME
    sub rsp, 104
    .allocstack 104
    .endprolog
    mov [rsp+32], rcx
    mov [rsp+40], rdx
    mov [rsp+48], r8
    mov [rsp+56], r9
    movsd QWORD PTR [rsp+64], xmm0
    movsd QWORD PTR [rsp+72], xmm1
    movsd QWORD PTR [rsp+80], xmm2
    movsd QWORD PTR [rsp+88], xmm3
    lea rcx, [rsp+32]
    lea rdx, [rsp+112]
    call bcf_capture_record_win64
    add rsp, 104
    ret
bcf_capture ENDP

; What a variadic call of bcf_vcapture (or bcf_vcapture_d) arrived in, saved
; before any compiled code runs (WINDOWS-X86-64-MILESTONE-6.md): fixture.c's
; bcf_vcapture_record(regs, stack) layout -- eight integer registers (rcx,
; rdx, r8, r9, then four zeros: Win64 has four argument positions), rax, eight
; floating-point registers (the low 64 bits of xmm0-xmm3, then four zeros) --
; and the caller's stack pointer at its call (entry rsp plus the return
; address: its 32-byte shadow space, then its stack arguments). A variadic
; call passes every float or double of the first four positions in both of
; its position's registers, which is why both are kept. 168 bytes of frame:
; 32 of shadow space, 136 of save area (17 words), which also aligns the
; stack.
bcf_vcapture PROC FRAME
    sub rsp, 168
    .allocstack 168
    .endprolog
    mov [rsp+32], rcx
    mov [rsp+40], rdx
    mov [rsp+48], r8
    mov [rsp+56], r9
    mov QWORD PTR [rsp+64], 0
    mov QWORD PTR [rsp+72], 0
    mov QWORD PTR [rsp+80], 0
    mov QWORD PTR [rsp+88], 0
    mov [rsp+96], rax
    movsd QWORD PTR [rsp+104], xmm0
    movsd QWORD PTR [rsp+112], xmm1
    movsd QWORD PTR [rsp+120], xmm2
    movsd QWORD PTR [rsp+128], xmm3
    mov QWORD PTR [rsp+136], 0
    mov QWORD PTR [rsp+144], 0
    mov QWORD PTR [rsp+152], 0
    mov QWORD PTR [rsp+160], 0
    lea rcx, [rsp+32]
    lea rdx, [rsp+176]
    call bcf_vcapture_record
    add rsp, 168
    ret
bcf_vcapture ENDP

; bcf_vcapture under the prototype of a fixed double first: the same code
; (fixture.c's alias on Unix), reached by a jump that leaves every register
; and the stack as the call left them -- a leaf of no stack effect, so no
; unwind data.
bcf_vcapture_d PROC
    jmp bcf_vcapture
bcf_vcapture_d ENDP

END

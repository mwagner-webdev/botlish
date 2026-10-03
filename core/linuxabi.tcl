# linuxabi.tcl -- linux::abi::syscall, the raw Linux x86-64 kernel
# transition (LINUX-X86-64-SYSCALL.md).
#
#   linux::abi::syscall({rax: R, rdi: R, rsi: R, rdx: R, r10: R, r8: R, r9: R})
#       -> abi::x86_64::Register64
#
# One root native, registered under its qualified name (no module file
# defines it: surface/modules.tcl and surface/lower.tcl resolve a qualified
# native name to a root reference). It is the one genuinely machine/OS-
# specific operation Botlish exposes: it executes the x86-64 `syscall`
# instruction with the given register contents and returns rax.
#
# The argument is a syscall-input description, not an inline assembly API:
# an anonymous struct whose fields are named after the Linux x86-64 syscall
# register convention and are abi::x86_64::Register64 values (lib/abi/
# x86_64.bot):
#
#   rax   the syscall number            (required)
#   rdi   argument 1    rsi   argument 2    rdx   argument 3
#   r10   argument 4    r8    argument 5    r9    argument 6
#
# An omitted argument register is zero. Any other field is rejected
# (hir/syscall.tcl: UNKNOWN-FIELD), and so is a missing rax (MISSING-FIELD)
# or a field that is not a Register64 (TYPE). The result is the raw rax
# after the transition, as a Register64: no errno, no -1 convention, no
# retry, no Result -- the kernel's own return value, nothing above it.
#
# The native knows the Linux x86-64 *transport* convention (which register
# carries what) and nothing about individual syscalls: no syscall number,
# argument meaning or signature is known to the compiler. getpid is
# `rax: abi::x86_64::register64(39)` in ordinary Botlish.
#
# Effects: maximally conservative, by the registry's own defaults and by
# being in no allowlist anywhere (CLOSED-CALL-EFFECTS.md, M6's "condition
# purity" and EXACT-VALUE-FACTS.md all name natives explicitly): never
# context-free (a module binding cannot be initialized with it: MODULE-
# CONTEXT), never exact-value-folded, never decided, never merged, never
# removed when its result is unused, never reordered; natively it is a
# helper *call* (native/src/runtime/syscall.rs), which Cranelift treats as
# reading and writing all memory.
#
# Backends: only the native backend performs it (cranelift, cranelift-
# generic, standalone executables; Linux x86-64 only -- the target the
# native backend is built for, checked again at code generation). The Tcl
# backends (interp, compile) cannot execute an x86-64 instruction and do
# not imitate one with some other host facility (a Tcl `pid` would test the
# wrong abstraction): a call raises the semantic error NATIVE-ONLY when it
# runs. Only the call is refused -- a program that defines but never calls
# it, and every pure abi::x86_64 conversion, runs on every backend.

namespace eval core::linuxabi {
    # The register fields the argument may name, in the syscall convention's
    # own order: rax (the number), then arguments 1-6.
    variable registers {rax rdi rsi rdx r10 r8 r9}
    # The struct declaration identity of a register word (lib/abi/x86_64.bot).
    variable registerType abi::x86_64::Register64
}

proc core::linuxabi::registers {} {
    variable registers
    return $registers
}

proc core::linuxabi::registerType {} {
    variable registerType
    return $registerType
}

proc core::linuxabi::syscallImpl {registers} {
    core::semanticError NATIVE-ONLY \
        "linux::abi::syscall executes the x86-64 \"syscall\" instruction (a raw Linux kernel transition) and is performed only by the native backend (cranelift, or a standalone executable) on Linux x86-64; the Tcl backends (interp, compile) do not execute machine instructions and do not imitate a syscall"
}

core::native::register linux::abi::syscall -arity 1 -impl core::linuxabi::syscallImpl \
    -param-types {struct} -result-type struct -runtime {raw-syscall} \
    -result-shape [list named-struct [core::linuxabi::registerType]]

# thread.tcl -- the runtime operations of Botlish-owned threads and of the
# cross-thread transport (BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-
# MILESTONE-1.md; stdlib/thread.bot, stdlib/actor/remote.bot).
#
#   std::thread::entry(NAME)       the std::thread::Entry of thread entry NAME
#                                  (hir/threads.tcl): a constant -- its index
#                                  among the program's entries and its name
#   std::thread::rt_*              the runtime's thread registry and transport
#                                  (native/src/runtime/thread.rs), internal to
#                                  the standard library
#
# The rt_* operations are one family natively (NIR `threadop CODE ...`, the
# CODE below; one runtime helper, rt_thread_op), each taking Ints, Strings
# and byte storage and returning an Int, a String or byte storage: the
# library (std::thread, std::actor::remote) gives them their types, their
# errors and their protocol. Every status is an Int the library decodes;
# nothing here raises a declared error.
#
# The Tcl backends have no OS threads and one interpreter per process: a
# program that starts a thread is refused before it runs (hir::threads::
# RefuseTcl, THREAD-UNAVAILABLE), and every operation here refuses the same
# way if one is ever reached (a program run unchecked), never emulated.

namespace eval core::thread {
    # The operation codes (native/src/runtime/thread.rs's `Op`): name ->
    # {CODE ARITY RESULT}, RESULT int | str | bytes.
    variable operations {
        rt_spawn          {1 4 int}
        rt_status         {2 1 int}
        rt_stop           {3 1 int}
        rt_await          {4 2 int}
        rt_result         {5 1 bytes}
        rt_error          {6 1 str}
        rt_release        {7 1 int}
        rt_stop_requested {8 0 int}
        rt_capacity       {9 0 int}
        rt_stat           {10 1 int}
        rt_port_open      {11 0 int}
        rt_port_take      {12 0 int}
        rt_port_a         {13 0 int}
        rt_port_b         {14 0 int}
        rt_port_close     {15 0 int}
        rt_domain         {16 0 int}
        rt_endpoint_open  {17 2 int}
        rt_endpoint_key   {18 1 int}
        rt_endpoint_close {19 1 int}
        rt_send           {20 5 int}
        rt_request        {21 6 int}
        rt_take           {22 1 int}
        rt_take_bytes     {23 0 bytes}
        rt_take_call      {24 0 int}
        rt_take_call_key  {25 0 int}
        rt_take_status    {26 0 int}
        rt_reply          {27 5 int}
        rt_cancel         {28 1 int}
        rt_entry_index    {29 0 int}
        rt_init           {30 0 bytes}
        rt_endpoint_queued {31 1 int}
        rt_take_text      {32 0 str}
        rt_watch          {33 1 int}
        rt_error_message  {34 1 str}
    }
}

# What rt_entry_index reports for a Vm that runs module initialization and
# no entry at all -- a native library's instance (NAME_create): the native
# runtime's thread::ENTRY_INDEX_INITIALIZE_ONLY, part of its ABI
# fingerprint. An application library's entry dispatch returns on it
# (native/lower.tcl's ThreadDispatch; RN-HOST-STARTABLE-APPLICATION-LIBRARY-
# MILESTONE-1.md).
proc core::thread::initializeOnly {} {
    return -1
}

# The code of operation NAME (an rt_* name without its namespace).
proc core::thread::code {name} {
    variable operations
    return [lindex [dict get $operations $name] 0]
}

# Every operation: name -> {CODE ARITY RESULT}.
proc core::thread::operations {} {
    variable operations
    return $operations
}

proc core::thread::Unavailable {args} {
    core::semanticError THREAD-UNAVAILABLE \
        "Botlish threads and the cross-thread transport are native-only: OS threads each running a VM of their own, which the Tcl backends do not have (they run one interpreter per process)"
}

# std::thread::entry(NAME) (hir/threads.tcl): the Entry of a thread entry,
# typed by hir::types::ShapeResult's `thread-entry`. Natively a constant
# (native/lower.tcl's threadentry); the Tcl backends refuse a program that
# makes one (RefuseTcl), and this one if it is ever reached.
core::native::register std::thread::entry -arity 1 -impl core::thread::Unavailable \
    -param-types {any} -result-type struct -result-shape {thread-entry 0} -ownership {observe}

apply {{} {
    foreach {name spec} [core::thread::operations] {
        lassign $spec code arity result
        set params [lrepeat $arity any]
        switch -- $result {
            int   { set options [list -result-type int] }
            str   { set options [list -result-type str] }
            bytes { set options [list -result-type struct -result-shape {named-struct std::abi::bytes::Bytes}] }
        }
        core::native::register std::thread::$name -arity $arity -impl core::thread::Unavailable \
            -param-types $params -nomethod 1 -ownership [lrepeat $arity observe] {*}$options
        core::native::declareInternalMember std::thread::$name
    }
}}

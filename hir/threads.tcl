# threads.tcl -- thread entries (BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-
# ACTORS-MILESTONE-1.md).
#
#   # worker.bot, a module
#   thread fn worker(init: Job) -> Summary errors Refused:
#       with context std::event_loop::create(64)
#       with context event_loop_linux::create()
#       ...
#       summarize(init)
#
#   # the entry program
#   e = std::thread::entry(worker::worker)      # std::thread::Entry[Job, Summary]
#   s = std::thread::start(e, Job {...})        # requires std::thread::Threads
#
# A thread entry is the first computation of a Botlish thread: the runtime
# makes a fresh VM of the program on a new OS thread, initializes its module
# statics (every module section, as the main VM does), copies the start's
# initialization value into it (std::transfer), and runs the entry with it;
# the entry's result (or failure) is copied back to whoever joins the
# thread. One compiled program, several entries: the entry program's top
# level is the main VM's entry, each thread entry a worker VM's.
#
# An entry installs its own contexts. Its body, like the entry program's top
# level, may install contexts with `with context EXPR` as its own
# statements (hir/contexts.tcl), and every call there is checked against
# what the entry has installed so far -- its own installations only: a
# worker VM never has its creator's contexts, which belong to another VM.
# The implementation selected for each context trait stays the program's
# (CONTEXT-TRAIT-SELECTION-CONFLICT otherwise); each VM installs its own
# instance. A thread entry requires nothing of anyone: it is never called.
#
# The declaration (THREAD-ENTRY-PLACEMENT, THREAD-ENTRY-SIGNATURE,
# THREAD-ENTRY-ENVIRONMENT):
#
#   * a top-level function of a MODULE, never of the entry program: a
#     worker VM runs the module sections (their statics) and then the
#     entry, never the entry program's top level, so everything an entry
#     reaches must be module code -- a module cannot see the entry program;
#   * exactly one parameter, the initialization value, with a declared
#     type, and a declared result type -- both sendable and closed
#     (Sendable, SENDABILITY-AND-VALUE-COPY-MILESTONE-1.md): they cross
#     between VMs by copy, never by reference;
#   * no flags, context parameters, place, variadic or resume clause;
#   * it never suspends (it is no coroutine body: the thread's own stack
#     is its whole execution), and captures no value.
#
# Its declared errors are its failure outcomes: a worker that fails reports
# the error's identity and message to whoever joins it.
#
# References (THREAD-ENTRY-REFERENCE): a thread entry is named only as the
# argument of std::thread::entry -- never called (`worker(x)` would run its
# installations in the caller's VM), never a value (a function value of it
# could be called). std::thread::entry is only called, with a thread entry
# by name.
#
# Backends: the native backends compile every entry into the one program
# image (native/lower.tcl's thread dispatch); the Tcl backends have one
# interpreter per process and no VM per thread, so a program that starts a
# thread (a call of std::thread::entry) is THREAD-UNAVAILABLE there, at
# compile time (RefuseTcl), never emulated on one thread.

namespace eval hir::threads {}

# 1 if block E is declared `thread fn` (a thread entry).
proc hir::threads::isEntry {hir e} {
    return [expr {[dict exists $hir exprs $e threadEntry] && [dict get $hir exprs $e threadEntry]}]
}

# 1 if native NAME makes a thread entry's Entry: its result shape is
# `thread-entry` (registration metadata, never its name).
proc hir::threads::IsEntryNative {name} {
    return [expr {[core::native::exists $name]
        && [lindex [dict get [core::native::metadata $name] resultShape] 0] eq "thread-entry"}]
}

# The entry native call NODE calls, or "".
proc hir::threads::EntryNative {hir node} {
    lassign [dict getdef $node target ""] kind y
    if {$kind ne "native"} {
        return ""
    }
    set name [dict get [hir::symbol $hir $y] name]
    if {![IsEntryNative $name]} {
        return ""
    }
    return $name
}

# The block of the thread entry the expression ARG names by reference, or
# "" when ARG is no such reference.
proc hir::threads::Referenced {hir arg} {
    if {$arg eq "" || ![dict exists $hir exprs $arg] || [hir::kind $hir $arg] ne "ref"} {
        return ""
    }
    set b [hir::get $hir $arg binding]
    if {$b eq ""} {
        return ""
    }
    set block [hir::aot::BoundBlock $hir $b]
    if {$block eq "" || ![isEntry $hir $block]} {
        return ""
    }
    return $block
}

# The block ExprIds of HIR's thread entries declared at the top level of the
# program or of a module, in program order (a nested one is
# THREAD-ENTRY-PLACEMENT).
proc hir::threads::Declarations {hir} {
    set found {}
    foreach e [dict get $hir roots] {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] ne "bind"} continue
        set value [dict get $node value]
        if {[isEntry $hir $value]} {
            lappend found $value
        }
    }
    return $found
}

# The thread entry records of HIR's valid thread entries, in program order:
# one dict each,
#
#   name     the entry's canonical name (its module's namespace, then its
#            name): the key the runtime starts it by
#   block    its block
#   param    its parameter's declared type (the initialization value's)
#   result   its declared result type
#   origin   the declaration's origin
proc hir::threads::of {hir} {
    set records {}
    foreach e [Declarations $hir] {
        if {[llength [Problems $hir $e]]} continue
        set bind [hir::callbacks::BindOf $hir $e]
        set node [dict get $hir exprs $e]
        lappend records [dict create name [hir::semantic::SourceName $hir [dict get $hir exprs $bind binding]] \
            block $e param [lindex [dict get $node declaredParamTypes] 0] result [dict get $node declaredResult] \
            origin [dict get $hir exprs $bind origin]]
    }
    return $records
}

# The entry type std::thread::entry(NAME) has for the valid thread entry
# block E: std::thread::Entry applied to its parameter and result types.
proc hir::threads::EntryType {hir e} {
    set node [dict get $hir exprs $e]
    return [hir::types::MakeApplied std::thread::Entry [list [lindex [dict get $node declaredParamTypes] 0] [dict get $node declaredResult]]]
}

# 1 if thread entry block E's declared signature is one an Entry can carry:
# one declared parameter and a declared result, each sendable and closed.
# What its Entry's type needs; the declaration's other problems are its own.
proc hir::threads::Typed {hir e} {
    set node [dict get $hir exprs $e]
    set params [dict get $node declaredParamTypes]
    if {[llength $params] != 1 || [lindex $params 0] eq {} || [dict get $node declaredResult] eq {}} {
        return 0
    }
    foreach type [list [lindex $params 0] [dict get $node declaredResult]] {
        if {![hir::types::IsSendable $type] || ![hir::types::IsClosedType $type]} {
            return 0
        }
    }
    return 1
}

# What keeps block E from being a thread entry: a list of {KIND MESSAGE}.
proc hir::threads::Problems {hir e} {
    set node [dict get $hir exprs $e]
    set bind [hir::callbacks::BindOf $hir $e]
    set modules {}
    if {[dict exists $hir modules]} {
        set modules [dict values [dict get $hir modules]]
    }
    if {$bind eq "" || $bind ni [dict get $hir roots]
            || [dict get $hir bindings [dict get $hir exprs $bind binding] scope] ni $modules} {
        set what [if {$bind eq ""} {string cat "this function"} else {string cat "\"[hir::callbacks::ShortName $hir $bind]\""}]
        return [list [list THREAD-ENTRY-PLACEMENT "$what is not a top-level function of a module: a thread entry is declared at the top level of a module (never of the entry program, whose top level a worker VM does not run, nor nested in another function), so that everything it reaches is module code, which every VM initializes for itself"]]
    }
    set problems {}
    set what "thread fn \"[hir::callbacks::ShortName $hir $bind]\""
    set params [dict get $node params]
    if {[llength $params] != 1} {
        lappend problems [list THREAD-ENTRY-SIGNATURE "$what declares [llength $params] parameters; a thread entry has exactly one, the thread's initialization value (a struct holds several values)"]
    }
    foreach b $params declared [dict get $node declaredParamTypes] {
        set param [dict get $hir bindings $b name]
        if {$declared eq {}} {
            lappend problems [list THREAD-ENTRY-SIGNATURE "$what: parameter \"$param\" has no declared type; a thread entry declares its initialization value's type, which is copied into the new VM (std::transfer)"]
            continue
        }
        lappend problems {*}[SendProblems $what "parameter \"$param\"" $declared]
    }
    set result [dict get $node declaredResult]
    if {$result eq {}} {
        lappend problems [list THREAD-ENTRY-SIGNATURE "$what declares no result type; a thread entry declares its result type, which is copied back to whoever joins the thread (-> unit for none)"]
    } else {
        lappend problems {*}[SendProblems $what "the result" $result]
    }
    if {[dict getdef $node flags {}] ne {}} {
        lappend problems [list THREAD-ENTRY-SIGNATURE "$what declares flags; a thread entry's one parameter is its initialization value"]
    }
    if {[dict exists $node contextParams]} {
        lappend problems [list THREAD-ENTRY-SIGNATURE "$what declares context parameters; a worker VM has no context of its creator's -- a thread entry installs the contexts it needs with \"with context EXPR\" in its own body"]
    }
    if {[dict exists $node variadic]} {
        lappend problems [list THREAD-ENTRY-SIGNATURE "$what is variadic; a thread entry has exactly one parameter, its initialization value"]
    }
    if {[dict getdef $node places {}] ne {}} {
        lappend problems [list THREAD-ENTRY-SIGNATURE "$what declares a place parameter; a thread entry's initialization value is copied into its own VM, never a place of its creator's"]
    }
    if {[dict getdef $node declaredResume {}] ne {}} {
        lappend problems [list THREAD-ENTRY-SIGNATURE "$what declares a resume clause; a thread entry is never a coroutine body"]
    }
    set values {}
    if {[dict get $node captures] ne {}} {
        set statics [hir::aot::StaticBlocks $hir]
        foreach b [dict get $node captures] {
            if {[hir::aot::BoundBlock $hir $b] ni $statics} {
                lappend values [hir::semantic::SourceName $hir $b]
            }
        }
    }
    if {$values ne {}} {
        lappend problems [list THREAD-ENTRY-ENVIRONMENT "$what captures [join $values {, }]; a thread entry is environment-free: it runs in a VM of its own, which shares no value with its creator's (pass what it needs in its initialization value)"]
    }
    if {[hir::coroutines::MayYield $hir $e]} {
        lappend problems [list THREAD-ENTRY-ENVIRONMENT "$what may suspend (it yields, or calls a function that does); a thread entry runs on its thread's own stack to its end: its coroutines are its own, constructed in its body"]
    }
    return $problems
}

# The problems of the declared type TYPE of WHAT's POSITION, which crosses
# between VMs: it must be sendable, and closed.
proc hir::threads::SendProblems {what position type} {
    lassign [hir::types::SendClass $type] class why
    if {$class ne "total"} {
        return [list [list THREAD-ENTRY-SIGNATURE "$what: $position is declared [hir::types::presented $type], which is not sendable: it cannot be reconstructed in another VM\n$why"]]
    }
    if {![hir::types::IsClosedType $type]} {
        return [list [list THREAD-ENTRY-SIGNATURE "$what: $position is declared [hir::types::presented $type], an open type: a thread entry's types are concrete, since its transfers' schemas are fixed where it is declared"]]
    }
    return {}
}

# Diagnoses every thread entry of HIRVAR's program, every reference to one
# and every use of the entry operation (a native whose result shape is
# `thread-entry`).
proc hir::threads::verify {hirVar} {
    upvar 1 $hirVar hir
    if {[hir::mode $hir] ne "program"} {
        return
    }
    if {[hir::traits::Planning] || [dict exists $hir traitSource]} {
        # The monomorphized program: judged as written.
        return
    }
    # The arguments of entry calls (a thread entry's one admitted use) and
    # the callees of every call.
    set admitted [dict create]
    set callees [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        dict set callees [dict get $node callee] $e
        if {[EntryNative $hir $node] ne ""} {
            dict set admitted [lindex [dict get $node args] 0] $e
        }
    }
    dict for {e node} [dict get $hir exprs] {
        switch -- [dict get $node kind] {
            block {
                if {![isEntry $hir $e]} continue
                foreach problem [Problems $hir $e] {
                    lassign $problem kind message
                    hir::Diagnose hir $kind $message $e
                }
            }
            call {
                set name [EntryNative $hir $node]
                if {$name eq ""} continue
                if {[dict exists $node reachable] && ![dict get $node reachable]} continue
                set arg [lindex [dict get $node args] 0]
                if {[Referenced $hir $arg] eq ""} {
                    set what "its argument"
                    if {$arg ne "" && [hir::kind $hir $arg] eq "ref"} {
                        set what "\"[hir::semantic::RefName $hir $arg]\""
                    }
                    hir::Diagnose hir THREAD-ENTRY-REFERENCE \
                        "[core::native::displayName $name]: $what is not a thread entry named directly; an Entry is made only of a module's top-level function declared \"thread fn NAME(init: T) -> R:\", by its name (a function value, a closure or a parameter is no thread entry)" $e
                }
            }
            ref {
                if {[dict exists $node reachable] && ![dict get $node reachable]} continue
                set name [hir::callbacks::RefNative $hir $node]
                if {$name ne ""} {
                    if {[IsEntryNative $name] && ![dict exists $callees $e]} {
                        hir::Diagnose hir THREAD-ENTRY-REFERENCE \
                            "[core::native::displayName $name] can only be called directly, with a thread entry by name: a function value of it would make an Entry of whatever it is given at run time" $e
                    }
                    continue
                }
                if {[dict exists $admitted $e]} continue
                set block [Referenced $hir $e]
                if {$block eq ""} continue
                set entry "\"[hir::semantic::RefName $hir $e]\""
                if {[dict exists $callees $e]} {
                    hir::Diagnose hir THREAD-ENTRY-REFERENCE \
                        "thread entry $entry is called here; a thread entry is never called: it runs only as a new thread's first computation, in a VM of its own (start it: std::thread::start(std::thread::entry(NAME), INIT))" $e
                } else {
                    hir::Diagnose hir THREAD-ENTRY-REFERENCE \
                        "thread entry $entry is used as a value here; a thread entry is named only as the argument of std::thread::entry (a function value of it could be called, in a VM that is not its own)" $e
                }
            }
        }
    }
}

# The first call of the thread-entry native in HIR (a program that starts a
# thread), or "".
proc hir::threads::FirstStart {hir} {
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "call" && [EntryNative $hir $node] ne ""} {
            return $e
        }
    }
    return ""
}

# Refuses, for a Tcl backend, a HIR that starts a thread
# (THREAD-UNAVAILABLE): the Tcl backends have one interpreter per process,
# no VM per thread and no OS thread to run one on, so a thread entry is
# never run there -- not emulated on the caller's thread, which would
# share its VM, its heap and its contexts. A program that only declares
# thread entries (a module's) runs; the same program's actors and event
# loops on one thread run on every backend.
proc hir::threads::RefuseTcl {hir backend} {
    if {[hir::mode $hir] ne "program"} {
        return
    }
    set e [FirstStart $hir]
    if {$e eq ""} {
        return
    }
    set where [hir::originLocation $hir [dict get $hir exprs $e origin]]
    throw {BACKEND THREAD-UNAVAILABLE} \
        "$where: this program starts Botlish threads (std::thread::entry), which the $backend backend cannot run: Botlish threads are OS threads, each running a VM of its own, which only the native backends (cranelift, cranelift-generic) have -- the Tcl backends run one interpreter per process (THREAD-UNAVAILABLE)"
}

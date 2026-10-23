# trait-constrained-types.tcl -- the performance report of parameterized
# structs and trait-constrained type slots (TRAIT-CONSTRAINED-IMPRINTED-
# TYPES.md, "Performance").
#
#   tclsh9.0 bench/trait-constrained-types.tcl ?-runs N? ?-sizes LIST?
#                                              ?-n N? ?-native-n N?
#
# Three tables:
#
#   * Front end, declarations: the compile time (surface::compile, no cache,
#     warnings off) of a program declaring SIZE structs of two fields and a
#     function per struct that projects one, as ordinary structs, as
#     parameterized structs `struct S[A, B]` and as constrained ones `struct
#     S[A satisfies Hashable, B]`, each function then over the application
#     (the same body in the last two: the difference is the constraint).
#   * Front end, applications: one `struct Box[T]` (and, constrained, `struct
#     Box[T satisfies Hashable]`) and SIZE ordinary structs T1..Tn, and a
#     function per T over Box[Ti]: SIZE distinct applications.
#     With it, the NIR's struct shapes: one for Box whatever the number of
#     applications (no runtime struct per application), beside one per Ti.
#   * Run time: N constructions and projections of a two-field struct, the
#     ordinary one against an application, and N public hashes of a field
#     through a function over the constrained H[K] against the same function
#     over a concrete struct -- time per iteration, best of RUNS, compilation
#     excluded -- and the heap allocations natively.
#
# Every timed number is best of RUNS in-process executions.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root bench backends.tcl]
interp recursionlimit {} 200000

set runs 5
set sizes {10 40 160}
set n 2000
set nativeN 200000
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -sizes { set sizes $value }
        -n { set n $value }
        -native-n { set nativeN $value }
        default { error "unknown option $option" }
    }
}

proc bestMicros {script} {
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        set micros [lindex [uplevel 1 [list time $script]] 0]
        if {$best eq "" || $micros < $best} {
            set best $micros
        }
    }
    return $best
}

proc compileMillis {text} {
    return [expr {[bestMicros [list surface::compile $text -warnings off]] / 1000.0}]
}

# SIZE declarations of kind KIND (plain, slots, constrained) and their
# functions.
proc declarations {kind size} {
    set text ""
    for {set i 1} {$i <= $size} {incr i} {
        switch -- $kind {
            plain {
                append text "struct S$i:\n    a: int\n    b: str\n\nfn get$i\(s: S$i) -> int:\n    s.a\n\n"
            }
            slots {
                append text "struct S$i\[A, B\]:\n    a: A\n    b: B\n\nfn get$i\(s: S$i\[A, B\]) -> A:\n    s.a\n\n"
            }
            constrained {
                append text "struct S$i\[A satisfies Hashable, B\]:\n    a: A\n    b: B\n\nfn get$i\(s: S$i\[A, B\]) -> A:\n    s.a\n\n"
            }
        }
    }
    set calls {}
    for {set i 1} {$i <= $size} {incr i} {
        lappend calls "get$i\(S$i {a: $i, b: \"x\"})"
    }
    append text "\[[join $calls {, }]\]\n"
    return $text
}

proc applications {size {constraint ""}} {
    set text "struct Box\[T$constraint\]:\n    value: T\n\n"
    for {set i 1} {$i <= $size} {incr i} {
        append text "struct T$i:\n    n: int\n\nfn open$i\(b: Box\[T$i\]) -> int:\n    b.value.n\n\n"
    }
    set calls {}
    for {set i 1} {$i <= $size} {incr i} {
        lappend calls "open$i\(Box {value: T$i {n: $i}})"
    }
    append text "\[[join $calls {, }]\]\n"
    return $text
}

set runtimePrelude "import std::list

struct Plain:
    a: int
    b: int

struct Pair\[A, B\]:
    a: A
    b: B

struct HInt:
    key: int

struct H\[K satisfies Hashable\]:
    key: K

fn hashPlain(h: HInt) -> int:
    hash(h.key)

fn hashConstrained(h: H\[K\]) -> int:
    hash(h.key)

"

proc runtimeProgram {kind n} {
    set body [dict get {
        plain "p = Plain {a: i, b: 1}\n        p.a + p.b"
        applied "p = Pair\[int, int\] {a: i, b: 1}\n        p.a + p.b"
        hash-plain "hashPlain(HInt {key: i})"
        hash-constrained "hashConstrained(H {key: i})"
    } $kind]
    return "$::runtimePrelude\nfn f(n: int) -> int:\n    xs = loop i from 0 to n:\n        $body\n    std::list::length(xs)\n\nf($n)\n"
}

proc timeOn {backend hir} {
    if {$backend eq "native"} {
        lassign [native::measure $hir $::runs] lower compile best collections value
        return $best
    }
    if {$backend eq "compile"} {
        set unit [core::compiler::compileHir $hir]
        set run {core::compiler::evalUnit $unit}
    } else {
        set program [hir::lower $hir]
        core::useBackend $backend
        set run {core::evalProgram $program}
    }
    eval $run
    return [bestMicros $run]
}

puts [bench::backends::manifest {interp compile native}]
puts ""
puts "Front end, declarations: compile time in ms (per declaration in parentheses), best of $runs"
puts ""
puts "| declarations | ordinary structs | `struct S\[A, B\]` | `struct S\[A satisfies Hashable, B\]` |"
puts "|---:|---:|---:|---:|"
foreach size $sizes {
    set row "| $size |"
    foreach kind {plain slots constrained} {
        set ms [compileMillis [declarations $kind $size]]
        append row [format " %.0f (%.2f) |" $ms [expr {$ms / $size}]]
    }
    puts $row
}
puts ""
puts "Front end, applications: compile time in ms of SIZE distinct applications Box\[Ti\] (per application in parentheses); NIR struct shapes of Box and of every struct"
puts ""
puts "| applications | compile ms, `Box\[T\]` | compile ms, `Box\[T satisfies Hashable\]` | Box shapes in NIR | all shapes in NIR |"
puts "|---:|---:|---:|---:|---:|"
foreach size $sizes {
    set text [applications $size]
    set ms [compileMillis $text]
    set constrained [compileMillis [applications $size " satisfies Hashable"]]
    set nir [dict get [native::lower::program [surface::compile $text -warnings off] -struct-opt 0] text]
    set boxes [regexp -all -line {^shape [0-9]+ named "Box" } $nir]
    set shapes [regexp -all -line {^shape [0-9]+ } $nir]
    puts [format "| %d | %.0f (%.2f) | %.0f (%.2f) | %d | %d |" $size $ms [expr {$ms / $size}] $constrained [expr {$constrained / $size}] $boxes $shapes]
}
puts ""
puts "Run time: ns per iteration, N = $n on the Tcl backends, $nativeN natively, best of $runs"
puts ""
puts "| program | Tcl interp | Tcl compile | Cranelift | Cranelift allocations (N = 1000) |"
puts "|---|---:|---:|---:|---:|"
foreach {label kind} {
    "construct and project an ordinary struct" plain
    "construct and project Pair[int, int]" applied
    "hash a field of an ordinary struct" hash-plain
    "hash a field through H[K] (K satisfies Hashable)" hash-constrained
} {
    set row "| $label |"
    foreach backend {interp compile native} {
        set count [expr {$backend eq "native" ? $nativeN : $n}]
        set micros [timeOn $backend [surface::compile [runtimeProgram $kind $count] -warnings off]]
        append row [format " %.1f |" [expr {$micros * 1000.0 / $count}]]
    }
    set allocations [dict get [native::allocationReport [surface::compile [runtimeProgram $kind 1000] -warnings off] summary] total allocations]
    append row " $allocations |"
    puts $row
}

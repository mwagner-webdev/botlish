# list-length-refinement.tcl -- the performance report of List length
# refinements (LIST-CARDINALITY-REFINEMENTS.md, "Performance").
#
#   tclsh9.0 bench/list-length-refinement.tcl ?-runs N? ?-n N? ?-native-n N?
#       ?-backends LIST? ?-scale LIST?
#
# A refinement is knowledge, not representation, so it can only remove work.
# Three tables:
#
#   * Per operation, on every backend (Tcl interp, Tcl compile, Cranelift):
#     programs that each repeat one operation N times inside a collecting
#     loop, reported as time per operation over the program's baseline,
#     (program - baseline) / N, the whole program per operation in
#     parentheses (bench/enums.tcl's method). Each operation is measured
#     twice, through a parameter of type List[T] (the index or extent check
#     runs) and through one of type List[T]{length: N} (the proof removes
#     it): std::list::at at a constant index, a whole fixed-array std::binary::write,
#     std::list::length, and a List validated once by std::list::with_length and then
#     read N times, against the same reads under a handler.
#   * The heap allocations of each Cranelift program: a refinement
#     allocates nothing, and std::list::with_length returns its operand (no
#     copy).
#   * Front-end scaling: a program declaring K distinct refined List types
#     (lengths 0 .. K-1, each a function parameter, each minted by
#     std::list::with_length), against the same program with List[int] and no
#     validation, for each K of -scale: the build time, and per declared
#     type. The refinement adds no fixpoint iteration per length, so the
#     cost is linear in K, as the program's text is.
#
# Every timed number is best of RUNS in-process executions, compilation
# excluded (the scaling table times the front end alone).

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root bench backends.tcl]
interp recursionlimit {} 200000

set runs 5
set n 20000
set nativeN 2000000
set backends {interp compile native}
set scale {10 100 1000}
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -native-n { set nativeN $value }
        -backends { set backends $value }
        -scale { set scale $value }
        default { error "unknown option $option" }
    }
}

set prelude {import std::abi
import std::abi::bytes
import std::binary
import std::list

layout ROW:
    size 32
    align 2
    field row: array 16 of std::binary::U16 at 0

}

# A program: the function F of SIGNATURE and BODY lines, and CALL, the
# program's result.
proc Program {signature body call} {
    set text $::prelude
    append text "fn f$signature:\n"
    foreach line $body {
        append text "    $line\n"
    }
    append text $call\n
    return $text
}

# BODY lines collecting LINES over `i from 0 to n`, then the List's length.
proc Each {lines {setup {}}} {
    return [concat $setup [list "out = loop i from 0 to n:"] [lmap line $lines {string cat "    " $line}] [list "std::list::length(out)"]]
}

# What every program runs: f(n, a List of 16 Ints, a row of 16 U16 values
# (the parse of 32 zero bytes), storage to write it into); @N@ is n.
set call {fn run(n: int) -> int errors IndexNotFound, LayoutExtentMismatch, LayoutLengthMismatch, LengthMismatch:
    data = std::abi::bytes::zeroed(std::abi::usize(32))
    row = std::binary::parse(ROW, std::abi::bytes::freeze(data)).row
    f(n, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16], row, data)

r = run(@N@):
    on IndexNotFound:
        -1
    on LayoutExtentMismatch:
        -2
    on LayoutLengthMismatch:
        -3
    on LengthMismatch:
        -4
r}

proc programText {kind n} {
    set plain "(n: int, xs: List\[int\], row: List\[std::binary::U16\], d: std::abi::bytes::MutableBytes) -> int errors IndexNotFound, LayoutExtentMismatch, LayoutLengthMismatch, LengthMismatch"
    set refined "(n: int, xs: List\[int\]{length: 16}, row: List\[std::binary::U16\]{length: 16}, d: std::abi::bytes::MutableBytes) -> int errors IndexNotFound, LayoutExtentMismatch, LayoutLengthMismatch, LengthMismatch"
    set call [string map [list @N@ $n] $::call]
    switch -- $kind {
        base           { return [Program $plain [Each {i}] $call] }
        base-refined   { return [Program $refined [Each {i}] $call] }
        at             { return [Program $plain [Each {"xs.at(7)"}] $call] }
        at-refined     { return [Program $refined [Each {"xs.at(7)"}] $call] }
        length         { return [Program $plain [Each {"xs.length()"}] $call] }
        length-refined { return [Program $refined [Each {"xs.length()"}] $call] }
        write          { return [Program $plain [Each {"w = std::binary::write(d, ROW.row, row)" "i"}] $call] }
        write-refined  { return [Program $refined [Each {"w = std::binary::write(d, ROW.row, row)" "i"}] $call] }
        reads          { return [Program $plain [Each {"xs.at(3) + xs.at(12)"}] $call] }
        validated      { return [Program $plain [Each {"ys.at(3) + ys.at(12)"} {"ys = std::list::with_length\[List\[int\]{length: 16}\](xs)"}] $call] }
        default { error "unknown program $kind" }
    }
}

proc program {kind n} {
    return [surface::compile [programText $kind $n] -warnings off]
}

proc nOf {backend} {
    return [expr {$backend eq "native" ? $::nativeN : $::n}]
}

# Best-of-RUNS microseconds of HIR on BACKEND (interp, compile, native).
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
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        set micros [lindex [time $run] 0]
        if {$best eq "" || $micros < $best} {
            set best $micros
        }
    }
    return $best
}

# {DELTA WHOLE} nanoseconds per operation of KIND over BASE.
proc perOp {kind base backend} {
    set n [nOf $backend]
    set t [timeOn $backend [program $kind $n]]
    set b [timeOn $backend [program $base $n]]
    return [list [expr {($t - $b) * 1000.0 / $n}] [expr {$t * 1000.0 / $n}]]
}

proc ns {x} {
    return [format "%.1f ns" $x]
}

set operations {
    "std::list::at(xs, 7), xs: List[int]" at base
    "std::list::at(xs, 7), xs: List[int]{length: 16}" at-refined base-refined
    "std::list::length(xs), xs: List[int]" length base
    "std::list::length(xs), xs: List[int]{length: 16}" length-refined base-refined
    "std::binary::write of a 16-element row, row: List[U16]" write base
    "std::binary::write of a 16-element row, row: List[U16]{length: 16}" write-refined base-refined
    "two reads of xs: List[int] (each may fail)" reads base
    "two reads of ys, validated once by std::list::with_length" validated base
}

puts "List length refinements: performance (n = $n operations per Tcl program, $nativeN per Cranelift program; best of $runs runs)\n"
puts [bench::backends::manifest $backends]
puts ""
puts "## Per operation\n"
puts "Time per operation over the baseline program, (program - baseline) / n; the whole program per operation in parentheses.\n"
puts "| operation | [join [lmap b $backends {bench::backends::displayName $b}] { | }] |"
puts "|---|[string repeat ---:| [llength $backends]]"
foreach {label kind base} $operations {
    set cells {}
    foreach backend $backends {
        lassign [perOp $kind $base $backend] delta whole
        lappend cells "[ns $delta] ([ns $whole])"
    }
    puts "| $label | [join $cells { | }] |"
}

if {"native" in $backends} {
    puts "\n## Native allocations\n"
    puts "Heap allocations of each whole Cranelift program, n = $nativeN.\n"
    puts "| program | allocations | Lists |"
    puts "|---|---:|---:|"
    foreach kind {base base-refined at at-refined write write-refined reads validated} {
        set report [native::allocationReport [program $kind $nativeN] summary]
        set lists [expr {[dict exists $report byKind List] ? [dict get $report byKind List allocations] : 0}]
        puts "| $kind | [dict get $report total allocations] | $lists |"
    }
}

# A program declaring K refined List types, lengths 0 .. K-1 (REFINED 1),
# or the same shape with List[int] and no validation (REFINED 0).
proc scaleText {k refined} {
    set text "import std::list\n\n"
    for {set i 0} {$i < $k} {incr i} {
        if {$refined} {
            append text "fn f$i\(xs: List\[int\]{length: $i}) -> List\[int\]{length: $i}:\n    xs\n\n"
            append text "fn g$i\(ys: List\[int\]) -> int:\n    r = std::list::with_length\[List\[int\]{length: $i}\](ys):\n        on LengthMismatch:\n            return -1\n    f$i\(r).length()\n\n"
        } else {
            append text "fn f$i\(xs: List\[int\]) -> List\[int\]:\n    xs\n\n"
            append text "fn g$i\(ys: List\[int\]) -> int:\n    r = ys\n    f$i\(r).length()\n\n"
        }
    }
    append text "ys = \[1, 2, 3\]\n\["
    append text [join [lmap i [lseq 0 [expr {$k - 1}]] {string cat "g$i\(ys)"}] ", "]
    append text "\]\n"
    return $text
}

# Best-of-RUNS milliseconds of a front-end build of TEXT.
proc buildTime {text} {
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        set micros [lindex [time {surface::compile $text -warnings off}] 0]
        if {$best eq "" || $micros < $best} {
            set best $micros
        }
    }
    return [expr {$best / 1000.0}]
}

puts "\n## Front-end scaling\n"
puts "A front-end build (surface::compile) of a program with K distinct refined List types (lengths 0 .. K-1), against the same program with List\[int\] and no validation; best of $runs builds.\n"
puts "| K | refined | per type | List\[int\] | per type | ratio |"
puts "|---:|---:|---:|---:|---:|---:|"
foreach k $scale {
    set r [buildTime [scaleText $k 1]]
    set p [buildTime [scaleText $k 0]]
    puts [format "| %d | %.0f ms | %.2f ms | %.0f ms | %.2f ms | %.2f |" $k $r [expr {$r / $k}] $p [expr {$p / $k}] [expr {$r / $p}]]
}

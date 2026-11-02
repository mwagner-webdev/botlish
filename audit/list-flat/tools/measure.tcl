# measure.tcl -- LIST-FLAT-MILESTONE-1.md's performance measurements.
#
#   tclsh9.0 audit/list-flat/tools/measure.tcl ?-parts LIST? ?-sizes LIST?
#       ?-repeat R? ?-runs N? ?-time 0|1? ?-instructions 0|1?
#
# Every workload is a pair of generated programs that differ only in the
# operation measured: WITH runs it R times on input built once per run,
# WITHOUT measures the same input's length R times. The difference divided
# by R is one operation's cost, input construction cancelled. For each
# program:
#
#   instructions   callgrind's instructions per run (audit/bench-bimodality/
#                  tools/profile.sh: the difference of a 4- and a 24-run
#                  profile of the standalone executable; deterministic)
#   allocations    the native allocation report (native::allocationReport):
#                  Lists allocated, List elements copied, the listflat site
#   time           best of N runs in one driver process (native::measure,
#                  JIT compilation excluded; noisy on a shared machine)
#
# Parts (-parts, default all):
#   basic      flat alone, five shapes (singletons, few large, many empty,
#              mixed lengths, structs) at each size: per-flat instructions,
#              per element and per (m + n)
#   idioms     flat against the existing ways to build the same List: an
#              element-by-element append in a fold (the repeated-prefix
#              baseline), flat([acc, xs]) in a fold, MutableVector pushes,
#              a self tail recursion appending (plan registers)
#   loop       a collecting loop whose body makes a List, then flat: the
#              inner Lists, the outer List and flat separately
#   chunks     FOLD-LOOPS-MILESTONE-1.md's chunk workloads (fold and tail
#              recursion) with and without a final flat
#
# Needs the release native backend and valgrind (for instructions).
# Scratch files live in a `file tempdir` directory, removed at the end.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set arguments $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
set argv $arguments

set options [dict create -parts {basic idioms loop chunks} -sizes {128 1024 4096 16384} -repeat 16 \
    -runs 30 -time 1 -instructions 1]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set R [dict get $options -repeat]
set work [file tempdir botlish-list-flat-measure]

proc readFile {path} {
    set channel [open $path r]
    fconfigure $channel -encoding utf-8 -translation lf
    set text [read $channel]
    close $channel
    return $text
}

proc writeProgram {name text} {
    set path [file join $::work $name.bot]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
    return $path
}

# {instructions flatInstructions} per run of PATH (profile.sh), or {- -}.
proc instructions {path {n1 4} {n2 24}} {
    if {![dict get $::options -instructions]} {
        return {- -}
    }
    set out [exec bash [file join $::root audit bench-bimodality tools profile.sh] $path $n1 $n2 2>@1]
    set total -
    set flat 0
    foreach line [split $out \n] {
        if {[regexp {instructions per run: ([0-9,]+)} $line -> n]} {
            set total [string map {, ""} $n]
        } elseif {[regexp {^\s*([0-9,]+)\s+[0-9.]+%\s+rt_list_flat$} $line -> n]} {
            set flat [string map {, ""} $n]
        }
    }
    return [list $total $flat]
}

# {lists copied flatAllocations flatBytes value} of PATH's native run.
proc allocations {path} {
    set hir [surface::readProgramFile $path -warnings off]
    set report [native::allocationReport $hir sites]
    set flatAllocations 0
    set flatBytes 0
    foreach site [dict get $report sites] {
        if {[dict get $site operation] eq "listflat"} {
            incr flatAllocations [dict get $site allocations]
            incr flatBytes [dict get $site allocatedBytes]
        }
    }
    return [list [dict get $report byKind List allocations] [dict get $report copies listElements] $flatAllocations $flatBytes]
}

# {bestMicroseconds value} of PATH, or {- value}.
proc timing {path} {
    set hir [surface::readProgramFile $path -warnings off]
    if {![dict get $::options -time]} {
        return {- -}
    }
    lassign [native::measure $hir [dict get $::options -runs]] lower compile best collections value
    return [list $best [core::formatValue $value]]
}

proc fmt {n} {
    if {$n eq "-"} { return - }
    return [regsub -all {\d(?=(\d{3})+(?!\d))} [format %.0f $n] {&,}]
}

# Measures the pair BUILD (declarations and `xss = ...`) with operation OP
# (an expression of xss whose value is a List) repeated R times.
proc pair {label build op {R ""} {n1 4} {n2 24}} {
    if {$R eq ""} {
        set R $::R
    }
    set with [writeProgram "$label-with" "import std::list\nimport std::mutable_vector\n\n$build\n\nfn rep(xss, r):\n    fold t from 0 to r with intermediate acc 0:\n        acc + std::list::length($op)\n\nrep(xss, $R)\n"]
    set without [writeProgram "$label-without" "import std::list\nimport std::mutable_vector\n\n$build\n\nfn rep(xss, r):\n    fold t from 0 to r with intermediate acc 0:\n        acc + std::list::length(xss)\n\nrep(xss, $R)\n"]
    lassign [instructions $with $n1 $n2] iw flatw
    lassign [instructions $without $n1 $n2] io -
    lassign [allocations $with] lw cw fa fb
    lassign [allocations $without] lo co - -
    lassign [timing $with] tw vw
    lassign [timing $without] to vo
    set per [expr {$iw eq "-" ? "-" : ($iw - $io) / double($R)}]
    set tper [expr {$tw eq "-" ? "-" : ($tw - $to) / double($R)}]
    return [dict create label $label perOp $per flatInstructions [expr {$flatw eq "-" ? "-" : $flatw / double($R)}] \
        lists [expr {($lw - $lo) / double($R)}] copies [expr {($cw - $co) / double($R)}] \
        flatAllocations $fa flatBytes $fb timePerOp $tper value $vw]
}

proc basicBuild {shape n} {
    switch -- $shape {
        singletons {
            return [list $n $n "fn mk(m):\n    loop i from 0 to m:\n        \[i\]\n\nxss = mk($n)"]
        }
        few-large {
            set k [expr {$n / 4}]
            return [list 4 $n "fn mk(m, k):\n    loop i from 0 to m:\n        loop j from 0 to k:\n            i * k + j\n\nxss = mk(4, $k)"]
        }
        many-empty {
            # 4n inner Lists, one in 64 holding 16 elements: n elements.
            set m [expr {4 * $n}]
            return [list $m $n "fn mk(m):\n    loop i from 0 to m:\n        if i.mod(64) == 0:\n            loop j from 0 to 16:\n                j\n        else:\n            \[\]\n\nxss = mk($m)"]
        }
        mixed {
            # Lengths 0, 1, ..., 7 in turn (3.5 on average).
            set m [expr {int(round($n / 3.5))}]
            set total 0
            for {set i 0} {$i < $m} {incr i} { incr total [expr {$i % 8}] }
            return [list $m $total "fn mk(m):\n    loop i from 0 to m:\n        loop j from 0 to i.mod(8):\n            j\n\nxss = mk($m)"]
        }
        structs {
            set m [expr {$n / 8}]
            return [list $m $n "struct Item:\n    id: int\n    name: str\n\nfn mk(m):\n    loop i from 0 to m:\n        loop j from 0 to 8:\n            Item {id: i * 8 + j, name: \"item\"}\n\nxss = mk($m)"]
        }
    }
}

proc table {header rows} {
    puts [join $header " | "]
    puts [join [lmap h $header {string repeat - [string length $h]}] " | "]
    foreach row $rows {
        puts [join $row " | "]
    }
    puts ""
}

try {
    set parts [dict get $options -parts]
    set sizes [dict get $options -sizes]
    if {"basic" in $parts} {
        puts "== basic: one flat (instructions per flat, input construction cancelled; R = $R)\n"
        set rows {}
        foreach shape {singletons few-large many-empty mixed structs} {
            foreach n $sizes {
                lassign [basicBuild $shape $n] m elements build
                set r [pair "basic-$shape-$n" $build "std::list::flat(xss)"]
                set per [dict get $r perOp]
                lappend rows [list $shape $m $elements [fmt $per] \
                    [expr {$per eq "-" ? "-" : [format %.2f [expr {$per / double($elements == 0 ? 1 : $elements)}]]}] \
                    [expr {$per eq "-" ? "-" : [format %.2f [expr {$per / double($m + $elements)}]]}] \
                    [fmt [dict get $r flatInstructions]] [format %.0f [dict get $r lists]] [format %.0f [dict get $r copies]] \
                    [expr {[dict get $r timePerOp] eq "-" ? "-" : [format %.2f [dict get $r timePerOp]]}]]
            }
        }
        table {shape m n instr/flat instr/n instr/(m+n) rt_list_flat/flat Lists/flat copies/flat us/flat} $rows
    }
    if {"idioms" in $parts} {
        puts "== idioms: building the same List of n elements from k = 8 per inner List (per construction; R = 2, profiles of 1 and 3 runs)\n"
        set idioms [dict create \
            flat "std::list::flat(xss)" \
            append-fold "per_element(xss)" \
            flat-pair-fold "pairwise(xss)" \
            vector-push "pushed(xss)" \
            tail-recursion "cat(xss, 0, 0, \[\])"]
        set helpers "fn per_element(xss: List\[List\[int\]\]) -> List\[int\]:\n    fold xs in xss with intermediate acc \[\]:\n        fold x in xs with intermediate a acc:\n            a.append(x)\n\nfn pairwise(xss: List\[List\[int\]\]) -> List\[int\]:\n    fold xs in xss with intermediate acc \[\]:\n        std::list::flat(\[acc, xs\])\n\nfn pushed(xss: List\[List\[int\]\]) -> List\[int\]:\n    v = std::mutable_vector::from_list(\[0\])\n    ignored = std::mutable_vector::pop(v):\n        on IndexNotFound:\n            0\n    loop xs in xss:\n        loop x in xs:\n            v.push(x)\n    loop x in v:\n        x\n\nfn cat(xss: List\[List\[int\]\], i: int, j: int, acc: List\[int\]) -> List\[int\]:\n    if i >= std::list::length(xss):\n        return acc\n    xs = std::list::get(xss, i, \[\])\n    if j >= std::list::length(xs):\n        return cat(xss, i + 1, 0, acc)\n    cat(xss, i, j + 1, acc.append(std::list::get(xs, j, 0)))\n"
        set rows {}
        foreach n [lrange $sizes 0 2] {
            set m [expr {$n / 8}]
            set build "fn mk(m: int) -> List\[List\[int\]\]:\n    loop i from 0 to m:\n        loop j from 0 to 8:\n            i * 8 + j\n\n$helpers\nxss = mk($m)"
            dict for {name op} $idioms {
                # (The quadratic idioms copy O(n^2) elements per
                # construction: fewer repeats and profiled runs.)
                set r [pair "idiom-$name-$n" $build $op 2 1 3]
                lappend rows [list $name $n [fmt [dict get $r perOp]] \
                    [expr {[dict get $r perOp] eq "-" ? "-" : [format %.1f [expr {[dict get $r perOp] / double($n)}]]}] \
                    [format %.0f [dict get $r lists]] [format %.0f [dict get $r copies]] \
                    [expr {[dict get $r timePerOp] eq "-" ? "-" : [format %.2f [dict get $r timePerOp]]}] [dict get $r value]]
            }
        }
        table {idiom n instr/construction instr/element Lists copies us value} $rows
    }
    if {"loop" in $parts} {
        puts "== loop: chunks = loop x in xs: expand(x) (k = 8 elements each), then flat\n"
        set rows {}
        foreach n [lrange $sizes 0 2] {
            set m [expr {$n / 8}]
            set expand "fn expand(x: int) -> List\[int\]:\n    loop j from 0 to 8:\n        x * 8 + j\n"
            set variants [dict create \
                outer-scalar "xs = loop i from 0 to $m:\n    i\nys = loop x in xs:\n    x * 8\nstd::list::length(ys)" \
                outer-and-inner "xs = loop i from 0 to $m:\n    i\nchunks = loop x in xs:\n    expand(x)\nstd::list::length(chunks)" \
                outer-inner-flat "xs = loop i from 0 to $m:\n    i\nchunks = loop x in xs:\n    expand(x)\nstd::list::length(std::list::flat(chunks))" \
                single-loop "xs = loop i from 0 to $m:\n    i\nys = loop i from 0 to $n:\n    i\nstd::list::length(ys)"]
            dict for {name body} $variants {
                set path [writeProgram "loop-$name-$n" "import std::list\n\n$expand\nfn run():\n    [string map [list \n "\n    "] $body]\n\nrun()\n"]
                lassign [instructions $path] total flat
                lassign [allocations $path] lists copies fa fb
                lassign [timing $path] best value
                lappend rows [list $name $n [fmt $total] [fmt $flat] $lists $copies $fa \
                    [expr {$best eq "-" ? "-" : [format %.2f $best]}] $value]
            }
        }
        table {variant n instr/run rt_list_flat Lists copies listflat-allocs us value} $rows
    }
    if {"chunks" in $parts} {
        puts "== chunks: FOLD-LOOPS-MILESTONE-1.md's chunk workloads, the chunks then flat\n"
        set rows {}
        foreach workload {chunks-fold chunks-recursive} {
            set text [readFile [file join $root audit fold-loops workloads $workload.bot]]
            set lines [split [string trimright $text \n] \n]
            set last [lindex $lines end]
            set head [join [lrange $lines 0 end-1] \n]
            foreach n {128 1024} {
                set base [regsub -line {^n = [0-9]+$} $head "n = $n"]
                set variants [dict create \
                    chunks-only "$base\ncs.length()\n" \
                    chunks-then-flat "$base\nstd::list::flat(cs).length()\n"]
                dict for {name body} $variants {
                    set path [writeProgram "$workload-$name-$n" $body]
                    lassign [instructions $path] total flat
                    lassign [allocations $path] lists copies fa fb
                    lassign [timing $path] best value
                    lappend rows [list $workload $name $n [fmt $total] [fmt $flat] $lists $copies $fa \
                        [expr {$best eq "-" ? "-" : [format %.2f $best]}] $value]
                }
            }
        }
        table {workload variant n instr/run rt_list_flat Lists copies listflat-allocs us value} $rows
    }
} finally {
    file delete -force $work
}

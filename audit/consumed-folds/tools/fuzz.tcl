# fuzz.tcl -- random folds against the elaboration that copies every
# mutated intermediate (CONSUMED-FOLD-INTERMEDIATES-MILESTONE-1.md).
#
#   tclsh9.0 audit/consumed-folds/tools/fuzz.tcl ?-seed N? ?-count N?
#       ?-backends LIST? ?-fault none|exits|incoming? ?-gc-stress 0|1?
#       ?-show 0|1?
#
# Each program is a function whose fold carries a MutableVector or a struct
# of two, over a List, a counted range or nothing (a bare fold ended by a
# break), with a random body: pushes onto the intermediate, a place
# parameter's helper, observations recorded into an outer log (its length,
# a sum through an observing function), a local copy of it pushed, inner
# loops with their own `break` and `continue`, handled calls whose handler
# continues, nested folds whose initial value is the intermediate, `if`s,
# and the fold's own `continue` and `break` before and after any of these;
# its initial value is fresh or a vector the function still reads after
# the fold, its completion the intermediate, a struct literal of its
# fields, a fresh vector or that outer vector. The program's value holds
# the fold's result, the log and the outer vector's length, so a lost
# rollback, a leaked push or a shared header shows.
#
# Every program is compiled with the consumption on and off
# (hir::mutvec::consumedFolds) and run on every backend of -backends (all
# four by default); all outcomes must be one. -fault makes the consumption
# unsound in this process, to show the comparison sees it: `exits` treats
# every fold's exits as clean (FoldExitsClean), `incoming` stops making the
# fold's initial value and completions exclusive (FoldIncoming). Prints a
# line per disagreement (the program with -show 1), then the totals:
# programs, folds consumed and kept, folds with exits, disagreements,
# rejected programs (a generator bug). Exits 1 on a disagreement or a
# rejected program, unless -fault is given (then 0 when it found one).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set options [dict create -seed 1 -count 60 -backends {interp compile cranelift-generic cranelift} \
    -fault none -gc-stress 0 -show 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        puts stderr "fuzz.tcl: unknown option $option"
        exit 2
    }
    dict set options $option $value
}
set argv {}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
set env(BOTLISH_WARNINGS) off
source [file join $root tests helpers.tcl]
source [file join $root native native.tcl]
if {[dict get $options -gc-stress]} {
    set env(BOTLISH_NATIVE_GC_STRESS) 1
}
switch -- [dict get $options -fault] {
    none {}
    exits {
        proc hir::mutvec::FoldExitsClean {hir parent f b} { return 1 }
    }
    incoming {
        proc hir::mutvec::FoldIncoming {hir f} { return {} }
    }
    default {
        puts stderr "fuzz.tcl: -fault is none, exits or incoming"
        exit 2
    }
}

expr {srand([dict get $options -seed])}
proc pick {list} { lindex $list [expr {int(rand() * [llength $list])}] }
proc chance {p} { expr {rand() < $p} }
proc indent {text n} {
    set pad [string repeat " " $n]
    return [join [lmap line [split $text \n] {string cat $pad $line}] \n]
}

set ::prelude {import std::mutable_vector

fn ints() -> MutableVector[int]:
    std::mutable_vector::from_list([])

fn add(place v: MutableVector[int], x: int):
    v.push(x)

fn total(v: MutableVector[int]) -> int:
    fold y in v with intermediate s 0:
        s + y

fn listed(v: MutableVector[int]) -> List[int]:
    loop y in v:
        y

error Odd

fn check(x: int) -> int errors Odd:
    if x == 3 or x == -3:
        fail Odd
    x

struct Acc:
    left: MutableVector[int]
    right: MutableVector[int]

}

# The vector paths of the intermediate of KIND (vector, struct).
proc paths {kind name} {
    if {$kind eq "vector"} {
        return [list $name]
    }
    return [list "$name.left" "$name.right"]
}

# A random statement of the fold body over intermediate NAME (KIND), at
# nesting DEPTH; EXITS 0 forbids the fold's own exits (a bare fold must
# make progress).
proc statement {kind name depth exits} {
    global counter
    set p [pick [paths $kind $name]]
    set choices {push push place observe sum copy}
    if {$exits} {
        lappend choices continue break guard handler
    }
    lappend choices handled
    if {$depth < 2} {
        lappend choices if inner nested
    }
    switch -- [pick $choices] {
        push { return "$p.push(x)" }
        place { return "add($p, x * 10)" }
        observe { return "log.push($p.length())" }
        sum { return "log.push(total($p))" }
        copy {
            set c "c[incr counter]"
            return "$c = $p\n$c.push(99)\nlog.push($c.length())"
        }
        continue { return "if x < 0:\n    continue" }
        break { return "if x == 2:\n    break" }
        guard { return "if $p.length() > 4:\n    break" }
        handler {
            set y "y[incr counter]"
            return "$y = check(x):\n    on Odd:\n        continue\nlog.push($y)"
        }
        handled {
            set y "y[incr counter]"
            return "$y = check(x):\n    on Odd:\n        0\nlog.push($y)"
        }
        if {
            set a [block $kind $name [expr {$depth + 1}] $exits]
            set b [block $kind $name [expr {$depth + 1}] $exits]
            return "if x > 0:\n[indent $a 4]\nelse:\n[indent $b 4]"
        }
        inner {
            set body [list "if z == 2:\n    [pick {break continue}]" "$p.push(z)"]
            if {[chance 0.5]} {
                set body [lreverse $body]
            }
            return "loop z in \[1, 2, 3\]:\n[indent [join $body \n] 4]"
        }
        nested {
            set q "q[incr counter]"
            set step "$q.push(x)\n"
            if {[chance 0.4]} {
                append step "if x < 0:\n    continue\n"
            }
            return "n[incr counter] = fold z in \[1, 2\] with intermediate $q $p:\n[indent "$step$q" 4]\nlog.push(n$counter.length())"
        }
    }
}

proc block {kind name depth exits} {
    set n [expr {1 + int(rand() * 3)}]
    set lines {}
    for {set i 0} {$i < $n} {incr i} {
        lappend lines [statement $kind $name $depth $exits]
    }
    return [join $lines \n]
}

# A random completion of the body: the intermediate (or a new struct of its
# fields), a fresh value, the outer vector, an `if` of two, or a nested
# fold whose initial value is the intermediate.
proc completion {kind name} {
    global counter
    if {$kind eq "vector"} {
        set choices [list $name $name $name "ints()" v "if x > 1:\n    $name\nelse:\n    v"]
        lappend choices "fold z in \[5, 6\] with intermediate q[incr counter] $name:\n    q$counter.push(z)\n    q$counter"
    } else {
        set choices [list $name $name "Acc {left: $name.left, right: $name.right}" \
            "Acc {left: $name.left, right: v}" "Acc {left: ints(), right: $name.right}" \
            "if x > 1:\n    $name\nelse:\n    Acc {left: v, right: $name.right}"]
    }
    return [pick $choices]
}

proc program {} {
    global counter
    set counter 0
    set kind [pick {vector vector struct}]
    set name [expr {$kind eq "vector" ? "acc" : "a"}]
    set shape [pick {list list count bare}]
    if {$kind eq "vector"} {
        set initial [pick {ints() v v std::mutable_vector::from_list([1])}]
    } else {
        set initial [pick {"Acc {left: ints(), right: ints()}" "Acc {left: ints(), right: v}"}]
    }
    switch -- $shape {
        list {
            set header "fold x in xs with intermediate $name $initial:"
            set body "[block $kind $name 0 1]\n[completion $kind $name]"
        }
        count {
            set header "fold i from 0 to 6 with intermediate $name $initial:"
            set body "x = i - 2\n[block $kind $name 0 1]\n[completion $kind $name]"
        }
        bare {
            # Ended by a break on the first path's length, which grows by
            # one each iteration.
            set p [lindex [paths $kind $name] 0]
            set guard "if $p.length() >= 5:\n    break"
            set lines [list "x = $p.length()" [block $kind $name 0 0] "$p.push(x)"]
            set lines [linsert $lines [pick {1 3}] $guard]
            set header "fold with intermediate $name $initial:"
            set body "[join $lines \n]\n$name"
        }
    }
    if {$kind eq "vector"} {
        set result {[listed(w), listed(log), [v.length()]]}
    } else {
        set result {[listed(w.left), listed(w.right), listed(log), [v.length()]]}
    }
    set after ""
    if {[chance 0.5]} {
        set after "    v.push(1)\n"
    }
    set xs [lmap i [lrepeat [expr {int(rand() * 6)}] 0] {expr {int(rand() * 8) - 3}}]
    return "${::prelude}fn f(xs: List\[int\]) -> List\[List\[int\]\]:
    log = ints()
    v = std::mutable_vector::from_list(\[7, 8\])
    w = $header
[indent $body 8]
${after}    $result

f(\[[join $xs {, }]\])
"
}

# {CONSUMED KEPT EXITS} of HIR: its folds whose intermediate the
# elaboration consumed or left uncopied, those it copies at entry, and
# those with a `continue` or bare `break` of their own.
proc census {hir} {
    set consumed 0
    set kept 0
    set exits 0
    dict for {e node} [dict get $hir exprs] {
        if {![dict exists $node foldBinding]} continue
        if {[string match *#entry [dict get $hir bindings [dict get $node foldBinding] name]]} {
            incr kept
        } else {
            incr consumed
        }
        foreach x [hir::walk $hir] {
            set xnode [dict get $hir exprs $x]
            if {[dict get $xnode kind] in {break continue} && [dict get $xnode target] eq $e} {
                incr exits
                break
            }
        }
    }
    return [list $consumed $kept $exits]
}

set totals [dict create programs 0 consumed 0 kept 0 exits 0 disagreements 0 rejected 0]
set backends [dict get $options -backends]
for {set k 0} {$k < [dict get $options -count]} {incr k} {
    set text [program]
    dict incr totals programs
    set outcomes {}
    set problem ""
    foreach on {1 0} {
        set ::hir::mutvec::consumedFolds $on
        if {[catch {surface::compile $text fuzz.bot -warnings off} hir]} {
            set problem "rejected: [lindex [split $hir \n] 0]"
            break
        }
        if {$on} {
            lassign [census $hir] c kept e
            dict incr totals consumed $c
            dict incr totals kept $kept
            dict incr totals exits $e
        }
        foreach backend $backends {
            lappend outcomes [list $on $backend [lrange [outcomeUnderHir $backend $hir] 0 1]]
        }
    }
    set ::hir::mutvec::consumedFolds 1
    if {$problem ne ""} {
        dict incr totals rejected
        puts "program $k: $problem"
        if {[dict get $options -show]} { puts $text }
        continue
    }
    if {[llength [lsort -unique [lmap o $outcomes {lindex $o 2}]]] != 1} {
        dict incr totals disagreements
        puts "program $k: DISAGREE [join [lmap o $outcomes {string cat [lindex $o 0] / [lindex $o 1] ": " [lindex $o 2]}] {; }]"
        if {[dict get $options -show]} { puts $text }
    }
}
puts "seed [dict get $options -seed] fault [dict get $options -fault]: [dict get $totals programs] programs, [dict get $totals consumed] folds consumed, [dict get $totals kept] copied at entry, [dict get $totals exits] with their own exits, [dict get $totals disagreements] disagreements, [dict get $totals rejected] rejected"
if {[dict get $options -fault] ne "none"} {
    exit [expr {[dict get $totals disagreements] == 0}]
}
exit [expr {[dict get $totals disagreements] > 0 || [dict get $totals rejected] > 0}]

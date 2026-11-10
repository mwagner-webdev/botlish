# fuzz.tcl -- the compiler's verdicts on parameterized applications nested
# past the applied-type bound against an independent exact model
# (oracle.py; APPLIED-TYPE-BOUND-PRECISION-MILESTONE-1.md, "Oracle and
# fuzzing").
#
#   tclsh9.0 audit/applied-type-bound/tools/fuzz.tcl ?-seed N? ?-programs N?
#       ?-run N? ?-backends LIST? ?-verbose 0|1?
#
# Each program declares a few random acyclic parameterized structs -- a
# slot held directly, inside an application of an earlier declaration (its
# slots permuted), inside a List, or not at all (a phantom slot, constructed
# through its written application) -- beside Box[T] and Pair[A, B], picks a
# random exact type nested across the bound (depths biased around
# hir::types::appliedDepth, a few far past it), builds a value of exactly
# that type (type-directed: every construction's fields hold what its slots
# say, some constructions written with their application), and then either
# keeps both, changes a leaf of the value or a leaf of the expected type at a
# random depth. The program holds the value to the expected type written as
# a parameter's type:
#
#   fn check(x: EXPECTED) -> int:
#       1
#   check(VALUE)
#
# The oracle decides the exact verdict (accepted, or rejected: TYPE or
# IMPRINT) and, separately, the old bounded check's. A program the oracle
# accepts must compile and one it rejects must not (a FAILURE otherwise);
# every difference from the old check is classified: same,
# bound-false-rejection-fixed (old rejected, the value satisfies the
# declaration, now accepted), more-precise-rejection (old accepted a
# mismatch the cut hid, now rejected) -- and a difference on a program the
# bound cuts nothing of is a FAILURE (within the bound nothing changes).
# The first -run accepted programs also run on BACKENDS, value 1 each.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set here [file dirname [file normalize [info script]]]
set options [dict create -seed 1 -programs 60 -run 6 -backends {interp cranelift} -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::argv {}
source [file join $root tests helpers.tcl]

expr {srand([dict get $options -seed])}
proc rnd {n} { return [expr {int(rand() * $n)}] }
proc pick {list} { return [lindex $list [rnd [llength $list]]] }

# ---------------------------------------------------------------------------
# Declarations: {name slots fields phantom} with fields {name TYPE ...},
# TYPE the oracle's form ({atom int}, {var A}, {list T}, {app NAME ARGS}).

proc baseDecls {} {
    return [list \
        [dict create name Box slots T fields [list value {var T}] phantom {}] \
        [dict create name Pair slots {A B} fields [list first {var A} second {var B}] phantom {}]]
}

proc randomDecls {} {
    set decls [baseDecls]
    for {set i 1} {$i <= 1 + [rnd 3]} {incr i} {
        set slots [lrange {A B C} 0 [rnd 3]]
        set fields {}
        set phantom {}
        set f 0
        foreach slot $slots {
            if {[llength $slots] > 1 && [rnd 6] == 0 && $phantom eq {}} {
                # A slot no field holds: constructions are written applied.
                lappend phantom $slot
                continue
            }
            incr f
            switch -- [rnd 5] {
                0 { set t [list list [list var $slot]] }
                1 {
                    # Inside an earlier declaration's application, at a
                    # random slot of it, its other slots closed.
                    set other [pick $decls]
                    set args [lmap s [dict get $other slots] {list atom int}]
                    lset args [rnd [llength $args]] [list var $slot]
                    set t [list app [dict get $other name] $args]
                }
                2 { set t [list app Box [list [list var $slot]]] }
                default { set t [list var $slot] }
            }
            lappend fields f$f $t
        }
        if {[rnd 3] == 0} {
            incr f
            lappend fields f$f [list atom [pick {int str}]]
        }
        lappend decls [dict create name D$i slots $slots fields $fields phantom $phantom]
    }
    return $decls
}

proc declOf {decls name} {
    foreach d $decls {
        if {[dict get $d name] eq $name} { return $d }
    }
    error "no declaration $name"
}

# ---------------------------------------------------------------------------
# Types and values

# A random exact type about DEPTH applications deep: a spine through Box,
# Pair's second slot or a random declaration's slot, closed by atoms.
proc randomType {decls depth} {
    if {$depth <= 0} {
        return [list atom [pick {int int str}]]
    }
    set d [pick $decls]
    if {[rnd 3] == 0} {
        set d [declOf $decls Box]
    }
    set slots [dict get $d slots]
    set deep [rnd [llength $slots]]
    set args {}
    set i 0
    foreach slot $slots {
        if {$i == $deep} {
            lappend args [randomType $decls [expr {$depth - 1}]]
        } else {
            lappend args [randomType $decls [expr {[rnd 2]}]]
        }
        incr i
    }
    return [list app [dict get $d name] $args]
}

proc subst {t binding} {
    switch -- [lindex $t 0] {
        var { return [dict get $binding [lindex $t 1]] }
        list { return [list list [subst [lindex $t 1] $binding]] }
        app { return [list app [lindex $t 1] [lmap a [lindex $t 2] {subst $a $binding}]] }
    }
    return $t
}

# A value (the oracle's form) of exactly type T.
proc valueOf {decls t} {
    switch -- [lindex $t 0] {
        atom { return [list lit [lindex $t 1]] }
        list { return [list list [valueOf $decls [lindex $t 1]]] }
        app {
            set d [declOf $decls [lindex $t 1]]
            set binding [dict create]
            foreach slot [dict get $d slots] a [lindex $t 2] {
                dict set binding $slot $a
            }
            set fields {}
            foreach {name ft} [dict get $d fields] {
                lappend fields [list $name [valueOf $decls [subst $ft $binding]]]
            }
            set explicit null
            if {[dict get $d phantom] ne {} || ([dict get $d slots] ne {} && [rnd 7] == 0)} {
                set explicit [lindex $t 2]
            }
            return [list cons [lindex $t 1] $fields $explicit]
        }
    }
    error "no value of $t"
}

# Paths to every atom leaf of type T / value V ({INDEX ...} for lset).
proc typeLeaves {t {path {}}} {
    switch -- [lindex $t 0] {
        atom { return [list $path] }
        list { return [typeLeaves [lindex $t 1] [linsert $path end 1]] }
        app {
            set leaves {}
            set i 0
            foreach a [lindex $t 2] {
                lappend leaves {*}[typeLeaves $a [concat $path 2 $i]]
                incr i
            }
            return $leaves
        }
    }
    return {}
}

proc valueLeaves {v {path {}}} {
    switch -- [lindex $v 0] {
        lit { return [list $path] }
        list { return [valueLeaves [lindex $v 1] [linsert $path end 1]] }
        cons {
            set leaves {}
            set i 0
            foreach f [lindex $v 2] {
                lappend leaves {*}[valueLeaves [lindex $f 1] [concat $path 2 $i 1]]
                incr i
            }
            return $leaves
        }
    }
    return {}
}

proc flip {atom} { return [expr {$atom eq "int" ? "str" : "int"}] }

# ---------------------------------------------------------------------------
# Rendering

proc renderType {t} {
    switch -- [lindex $t 0] {
        atom { return [lindex $t 1] }
        var { return [lindex $t 1] }
        list { return "List\[[renderType [lindex $t 1]]\]" }
        app {
            if {[lindex $t 2] eq {}} { return [lindex $t 1] }
            return "[lindex $t 1]\[[join [lmap a [lindex $t 2] {renderType $a}] {, }]\]"
        }
    }
}

proc renderValue {v} {
    switch -- [lindex $v 0] {
        lit { return [expr {[lindex $v 1] eq "int" ? 1 : "\"s\""}] }
        list { return "\[[renderValue [lindex $v 1]]\]" }
        cons {
            set fields [join [lmap f [lindex $v 2] {string cat [lindex $f 0] ": " [renderValue [lindex $f 1]]}] {, }]
            set head [lindex $v 1]
            if {[lindex $v 3] ne "null"} {
                set head "[lindex $v 1]\[[join [lmap a [lindex $v 3] {renderType $a}] {, }]\]"
            }
            return "$head \{$fields\}"
        }
    }
}

proc renderDecls {decls} {
    set text "import std::list\n\n"
    foreach d $decls {
        set slots [dict get $d slots]
        append text "struct [dict get $d name][expr {$slots eq {} ? "" : "\[[join $slots {, }]\]"}]:\n"
        set fields [dict get $d fields]
        if {$fields eq {}} {
            set fields {unused {atom int}}
        }
        foreach {name t} $fields {
            append text "    $name: [renderType $t]\n"
        }
        append text "\n"
    }
    return $text
}

# ---------------------------------------------------------------------------
# JSON for the oracle

proc jsonString {s} { return "\"[string map {\\ \\\\ \" \\\"} $s]\"" }

proc jsonType {t} {
    switch -- [lindex $t 0] {
        atom - var { return "\[[jsonString [lindex $t 0]],[jsonString [lindex $t 1]]\]" }
        list { return "\[\"list\",[jsonType [lindex $t 1]]\]" }
        app { return "\[\"app\",[jsonString [lindex $t 1]],\[[join [lmap a [lindex $t 2] {jsonType $a}] ,]\]\]" }
    }
}

proc jsonValue {v} {
    switch -- [lindex $v 0] {
        lit { return "\[\"lit\",[jsonString [lindex $v 1]]\]" }
        list { return "\[\"list\",[jsonValue [lindex $v 1]]\]" }
        cons {
            set fields [join [lmap f [lindex $v 2] {string cat "\[" [jsonString [lindex $f 0]] , [jsonValue [lindex $f 1]] "\]"}] ,]
            set explicit [expr {[lindex $v 3] eq "null" ? "null" : "\[[join [lmap a [lindex $v 3] {jsonType $a}] ,]\]"}]
            return "\[\"cons\",[jsonString [lindex $v 1]],\[$fields\],$explicit\]"
        }
    }
}

proc jsonDecls {decls} {
    set out {}
    foreach d $decls {
        set fields [join [lmap {n t} [dict get $d fields] {string cat "\[" [jsonString $n] , [jsonType $t] "\]"}] ,]
        set slots [join [lmap s [dict get $d slots] {jsonString $s}] ,]
        lappend out "\{\"name\":[jsonString [dict get $d name]],\"slots\":\[$slots\],\"fields\":\[$fields\]\}"
    }
    return "\[[join $out ,]\]"
}

# ---------------------------------------------------------------------------

set cases {}
for {set p 0} {$p < [dict get $options -programs]} {incr p} {
    set decls [randomDecls]
    set depth [pick {3 5 6 6 7 7 8 9 10 12 16 30}]
    set t [randomType $decls $depth]
    set v [valueOf $decls $t]
    set mode [pick {valid valid value expected}]
    switch -- $mode {
        value {
            set leaves [valueLeaves $v]
            set path [pick $leaves]
            lset v {*}$path 1 [flip [lindex $v {*}$path 1]]
        }
        expected {
            set leaves [typeLeaves $t]
            set path [pick $leaves]
            lset t {*}$path 1 [flip [lindex $t {*}$path 1]]
        }
    }
    set source "[renderDecls $decls]fn check(x: [renderType $t]) -> int:\n    1\n\ncheck([renderValue $v])\n"
    lappend cases [dict create mode $mode depth $depth source $source \
        json "\{\"decls\":[jsonDecls $decls],\"expected\":[jsonType $t],\"value\":[jsonValue $v]\}"]
}

set dir [file tempdir botlish-applied-fuzz]
set f [open [file join $dir cases.jsonl] w]
foreach c $cases {
    puts $f [dict get $c json]
}
close $f
if {[catch {exec python3 -I [file join $here oracle.py] check [file join $dir cases.jsonl]} out]} {
    puts "oracle failed (cases kept in $dir): [lindex [split $out \n] end]"
    exit 2
}
set verdicts [split [string trim $out] \n]
file delete -force $dir

proc field {json name} {
    regexp "\"$name\": (\"\[^\"\]*\"|\[0-9\]+)" $json -> v
    return [string trim $v \"]
}

set counts [dict create]
set failures 0
set ran 0
set i 0
foreach c $cases json $verdicts {
    incr i
    set exact [field $json exact]
    set model [field $json model]
    set old [field $json old]
    set cut [field $json cut]
    if {[catch {surface::compile [dict get $c source] -warnings off} hir caught]} {
        set got [expr {[dict exists $caught -diagnostics]
            ? [lindex [dict get [lindex [dict get $caught -diagnostics] 0] errorcode] end] : "ERROR"}]
    } else {
        set got accept
    }
    set problem ""
    if {$exact ne $model} {
        # (A difference only a List's contents hold: bounded, as the
        # milestone leaves aggregates.)
        dict incr counts list-bounded
    }
    if {($model eq "accept") != ($got eq "accept") || $got eq "ERROR"} {
        set problem "verdict $got, oracle $model (exactly: $exact)"
    } elseif {!$cut && ($old eq "accept") != ($got eq "accept")} {
        set problem "within the bound the verdict changed: old $old, now $got"
    }
    if {($old eq "accept") == ($got eq "accept")} {
        set class same
    } elseif {$got eq "accept"} {
        set class bound-false-rejection-fixed
    } else {
        set class more-precise-rejection
    }
    if {$problem ne ""} {
        set class DIFFERENT
        incr failures
        puts "FAILURE $i ([dict get $c mode], depth [dict get $c depth]): $problem\n[dict get $c source]"
    } elseif {[dict get $options -verbose]} {
        puts "ok $i ([dict get $c mode], depth [dict get $c depth]): exact $exact, old $old, got $got: $class"
    }
    dict incr counts $class
    dict incr counts kind-[expr {$model eq $got ? "same" : "other"}]
    if {$got eq "accept" && $ran < [dict get $options -run]} {
        incr ran
        set saved [interp recursionlimit {}]
        core::useProgramRecursionLimit
        try {
            foreach backend [dict get $options -backends] {
                set outcome [lrange [outcomeUnderHir $backend $hir] 0 1]
                if {$outcome ne {value 1}} {
                    incr failures
                    puts "FAILURE $i: $backend ran $outcome\n[dict get $c source]"
                }
            }
        } finally {
            interp recursionlimit {} $saved
        }
    }
}
puts "seed [dict get $options -seed]: [llength $cases] programs, $ran run; [join [lmap {k n} [lsort -stride 2 $counts] {string cat $k " " $n}] {, }]; $failures failures"
exit [expr {$failures > 0}]

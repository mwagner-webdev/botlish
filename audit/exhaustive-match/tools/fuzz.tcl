# fuzz.tcl -- random exhaustive matches against an independent model
# (PORTABILITY-EXHAUSTIVE-MATCH-MILESTONE-1.md, section 13).
#
#   tclsh9.0 audit/exhaustive-match/tools/fuzz.tcl ?-n 200? ?-seed 1?
#       ?-backends "interp compile cranelift-generic cranelift"?
#       ?-gc-stress 0|1? ?-faults 30? ?-verbose 0|1?
#
# Each program declares a few enums -- overlapping case names across enums,
# payload-free and payload-bearing cases, Int, String and Bool fields -- and
# functions that match a value of one of them: arms in a random order, each
# receiving its payload in a random form (nothing, the whole payload,
# destructured in full or in part, renamed), its body an Int computed from
# what it bound, a `return`, a declared failure carrying a payload, or a
# nested match over a value of another enum whose arms also read the outer
# arm's bindings. Each function is called on random values. The model is
# this file's own: a value is {ENUM CASE {FIELD VALUE ...}}, and the model
# selects the arm by (enum, case) and evaluates the body from the arm's
# bindings, never through the compiler. Every accepted program runs on
# every backend, which must agree with the model's value.
#
# With probability -faults percent a program carries one mistake, and the
# model predicts its rejection's diagnostic code instead: an arm missing
# (MATCH-NOT-EXHAUSTIVE), an arm named twice (MATCH-DUPLICATE-CASE), an arm
# of another enum or an untyped or non-enum scrutinee (TYPE), an unknown
# case (UNKNOWN-ENUM-CASE), a payload bound for a payload-free case
# (ENUM-PAYLOAD-UNEXPECTED), an unknown payload field (UNKNOWN-FIELD).
#
# -gc-stress 1 runs the native backends under BOTLISH_NATIVE_GC_STRESS.
# Exits with status 1 on any disagreement.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 200 -seed 1 -backends "interp compile cranelift-generic cranelift" \
    -gc-stress 0 -faults 30 -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "fuzz.tcl: unknown option $option" }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

namespace eval gen {
    variable state 1
}

# A pseudo-random integer in [0, N).
proc gen::rand {n} {
    variable state
    set state [expr {($state * 1103515245 + 12345) % 2147483648}]
    return [expr {($state >> 8) % $n}]
}

proc gen::pick {items} {
    return [lindex $items [rand [llength $items]]]
}

proc gen::chance {percent} {
    return [expr {[rand 100] < $percent}]
}

proc gen::shuffle {items} {
    set result {}
    while {[llength $items]} {
        set i [rand [llength $items]]
        lappend result [lindex $items $i]
        set items [lreplace $items $i $i]
    }
    return $result
}

# ---------------------------------------------------------------------------
# The model's data
#
#   enum   {name NAME cases {CASE ...}}, CASE {name NAME fields {{F TYPE} ...}}
#   value  {ENUM CASE {F V ...}}
#   arm    {case NAME enum ENUM bind none|whole|pattern name LOCAL
#          pattern {{FIELD LOCAL} ...} body BODY}
#   body   {kind expr k K terms {TERM ...}} | {kind return k K}
#          | {kind fail k K} | {kind nested match MATCH k K}
#   term   {local NAME type T} (a bound field) or {proj NAME field F type T}
#          (a field of a whole-payload binding)
#   match  {scrutinee x|y enum ENUM arms {ARM ...} level L}

proc gen::Enums {} {
    set pool {A B C D Ok Leaf}
    set enums {}
    set count [expr {1 + [rand 3]}]
    for {set e 0} {$e < $count} {incr e} {
        set names [lrange [shuffle $pool] 0 [rand 4]]
        set cases {}
        foreach name $names {
            set fields {}
            if {![chance 35]} {
                set fieldNames [lrange [shuffle {a b c n s f}] 0 [rand 3]]
                foreach f $fieldNames {
                    lappend fields [list $f [pick {int int int str bool}]]
                }
            }
            lappend cases [dict create name $name fields $fields]
        }
        lappend enums [dict create name E$e cases $cases]
    }
    return $enums
}

proc gen::Case {enum name} {
    foreach c [dict get $enum cases] {
        if {[dict get $c name] eq $name} { return $c }
    }
    return ""
}

proc gen::Value {enum} {
    set case [pick [dict get $enum cases]]
    set fields {}
    foreach f [dict get $case fields] {
        lassign $f name type
        switch -- $type {
            int { set v [expr {[rand 30] - 8}] }
            str { set v [pick {"" x ab hello}] }
            bool { set v [pick {true false}] }
        }
        lappend fields $name $v
    }
    return [list [dict get $enum name] [dict get $case name] $fields]
}

# The terms an arm body reads of the bindings OUTER and of its own arm ARM.
proc gen::Terms {arm outer} {
    set available $outer
    lappend available {*}[ArmTerms $arm]
    set terms {}
    foreach t $available {
        if {[chance 60]} { lappend terms $t }
    }
    return $terms
}

# The terms arm ARM's own bindings offer.
proc gen::ArmTerms {arm} {
    set terms {}
    set case [dict get $arm caseDesc]
    switch -- [dict get $arm bind] {
        whole {
            foreach f [dict get $case fields] {
                lappend terms [dict create proj [dict get $arm name] field [lindex $f 0] type [lindex $f 1]]
            }
        }
        pattern {
            foreach pair [dict get $arm pattern] {
                lassign $pair field local
                set type [lindex [lsearch -inline -index 0 [dict get $case fields] $field] 1]
                lappend terms [dict create local $local type $type]
            }
        }
    }
    return $terms
}

# A match over parameter SCRUTINEE of enum ENUM at nesting LEVEL; OTHER the
# other parameter's enum (for a nested match), OUTER the terms visible from
# enclosing arms; KVAR the next arm constant.
proc gen::Match {scrutinee enum other level outer kVar} {
    upvar 1 $kVar k
    set arms {}
    foreach case [shuffle [dict get $enum cases]] {
        set arm [dict create case [dict get $case name] enum [dict get $enum name] caseDesc $case \
            bind none name "" pattern {}]
        set fields [dict get $case fields]
        if {$fields ne {}} {
            switch -- [pick {none whole pattern pattern}] {
                whole {
                    dict set arm bind whole
                    dict set arm name p$level
                }
                pattern {
                    dict set arm bind pattern
                    set pattern {}
                    foreach f $fields {
                        set name [lindex $f 0]
                        if {[chance 75]} {
                            set local [expr {[chance 30] ? "r${name}$level" : "${name}$level"}]
                            lappend pattern [list $name $local]
                        }
                    }
                    if {$pattern eq {}} {
                        set f [lindex $fields 0 0]
                        lappend pattern [list $f ${f}$level]
                    }
                    dict set arm pattern $pattern
                }
            }
        }
        incr k 7
        set roll [rand 100]
        if {$level == 1 && $other ne "" && $roll < 15} {
            set inner [Match y $other "" 2 [concat $outer [ArmTerms $arm]] k]
            dict set arm body [dict create kind nested match $inner k $k]
        } elseif {$roll < 25} {
            dict set arm body [dict create kind return k $k]
        } elseif {$roll < 35} {
            dict set arm body [dict create kind fail k $k]
        } else {
            dict set arm body [dict create kind expr k $k terms [Terms $arm $outer]]
        }
        lappend arms $arm
    }
    return [dict create scrutinee $scrutinee enum [dict get $enum name] arms $arms level $level]
}

# ---------------------------------------------------------------------------
# Rendering

proc gen::TermText {term} {
    if {[dict exists $term proj]} {
        set text "[dict get $term proj].[dict get $term field]"
    } else {
        set text [dict get $term local]
    }
    switch -- [dict get $term type] {
        int { return $text }
        str { return "slen($text)" }
        bool { return "b2i($text)" }
    }
}

proc gen::ArmHead {arm} {
    set head "case [dict get $arm enum]::[dict get $arm case]"
    switch -- [dict get $arm bind] {
        whole { append head " [dict get $arm name]" }
        pattern {
            set parts [lmap pair [dict get $arm pattern] {
                lassign $pair field local
                expr {$field eq $local ? $field : "$field: $local"}
            }]
            append head " \{[join $parts {, }]\}"
        }
    }
    return "$head:"
}

proc gen::MatchLines {match indent} {
    set pad [string repeat "    " $indent]
    set lines [list "${pad}match [dict get $match scrutinee]:"]
    foreach arm [dict get $match arms] {
        lappend lines "$pad    [ArmHead $arm]"
        set body [dict get $arm body]
        set inner "$pad        "
        switch -- [dict get $body kind] {
            expr {
                set text [dict get $body k]
                foreach t [dict get $body terms] {
                    append text " + [TermText $t]"
                }
                lappend lines "$inner$text"
            }
            return {
                lappend lines "${inner}return [dict get $body k]"
            }
            fail {
                lappend lines "${inner}fail Bad \{code: [dict get $body k]\}"
            }
            nested {
                lappend lines {*}[MatchLines [dict get $body match] [expr {$indent + 2}]]
            }
        }
    }
    return $lines
}

proc gen::ValueText {value} {
    lassign $value enum case fields
    if {$fields eq {}} {
        return "${enum}::$case"
    }
    set parts {}
    foreach {f v} $fields {
        if {[lsearch -exact {true false} $v] >= 0 || [string is integer -strict $v]} {
            lappend parts "$f: $v"
        } else {
            lappend parts "$f: \"$v\""
        }
    }
    return "${enum}::$case \{[join $parts {, }]\}"
}

proc gen::Fails {match} {
    foreach arm [dict get $match arms] {
        set body [dict get $arm body]
        if {[dict get $body kind] eq "fail"} { return 1 }
        if {[dict get $body kind] eq "nested" && [Fails [dict get $body match]]} { return 1 }
    }
    return 0
}

# ---------------------------------------------------------------------------
# The model

namespace eval model {}

proc model::Term {term env} {
    if {[dict exists $term proj]} {
        set v [dict get [lindex [dict get $env [dict get $term proj]] 2] [dict get $term field]]
    } else {
        set v [dict get $env [dict get $term local]]
    }
    switch -- [dict get $term type] {
        int { return $v }
        str { return [string length $v] }
        bool { return [expr {$v eq "true" ? 1 : 0}] }
    }
}

# {normal V} | {return V} | {fail V}: MATCH evaluated with parameters
# X and Y and the outer bindings ENV.
proc model::Match {match x y env} {
    set value [expr {[dict get $match scrutinee] eq "x" ? $x : $y}]
    lassign $value enum case fields
    foreach arm [dict get $match arms] {
        if {[dict get $arm enum] ne $enum || [dict get $arm case] ne $case} continue
        switch -- [dict get $arm bind] {
            whole { dict set env [dict get $arm name] $value }
            pattern {
                foreach pair [dict get $arm pattern] {
                    lassign $pair field local
                    dict set env $local [dict get $fields $field]
                }
            }
        }
        set body [dict get $arm body]
        switch -- [dict get $body kind] {
            expr {
                set total [dict get $body k]
                foreach t [dict get $body terms] {
                    incr total [Term $t $env]
                }
                return [list normal $total]
            }
            return { return [list return [dict get $body k]] }
            fail { return [list fail [dict get $body k]] }
            nested { return [Match [dict get $body match] $x $y $env] }
        }
    }
    error "model: no arm for ${enum}::$case"
}

# ---------------------------------------------------------------------------
# A program

# {SOURCE EXPECTED}: EXPECTED {value TEXT} or {error CODE}.
proc gen::Program {faults} {
    set enums [Enums]
    set functions {}
    set k 0
    set count [expr {1 + [rand 3]}]
    for {set i 0} {$i < $count} {incr i} {
        set ex [pick $enums]
        set ey [pick $enums]
        set match [Match x $ex $ey 1 {} k]
        lappend functions [dict create name f$i ex $ex ey $ey match $match]
    }
    # One mistake, maybe, in the first function's outer match.
    set fault ""
    if {[chance $faults]} {
        set f [lindex $functions 0]
        set match [dict get $f match]
        set arms [dict get $match arms]
        set ex [dict get $f ex]
        set choices {duplicate untyped nonenum}
        if {[llength $arms] > 1} { lappend choices missing }
        if {[llength $enums] > 1} { lappend choices foreign }
        lappend choices unknown
        foreach arm $arms {
            if {[dict get $arm caseDesc fields] eq {}} { lappend choices payloadfree; break }
        }
        foreach arm $arms {
            if {[dict get $arm bind] eq "pattern"} { lappend choices unknownfield; break }
        }
        set fault [pick $choices]
        switch -- $fault {
            missing {
                set i [rand [llength $arms]]
                set arms [lreplace $arms $i $i]
                set code MATCH-NOT-EXHAUSTIVE
            }
            duplicate {
                set i [rand [llength $arms]]
                set arms [linsert $arms end [lindex $arms $i]]
                set code MATCH-DUPLICATE-CASE
            }
            foreign {
                set others [lmap e $enums {if {[dict get $e name] eq [dict get $ex name]} continue; set e}]
                set other [pick $others]
                set case [pick [dict get $other cases]]
                lappend arms [dict create case [dict get $case name] enum [dict get $other name] caseDesc $case \
                    bind none name "" pattern {} body [dict create kind expr k 1 terms {}]]
                set code TYPE
            }
            unknown {
                set i [rand [llength $arms]]
                set arm [lindex $arms $i]
                dict set arm case Zz
                dict set arm bind none
                dict set arm body [dict create kind expr k 1 terms {}]
                lset arms $i $arm
                set code UNKNOWN-ENUM-CASE
            }
            payloadfree {
                set i [lsearch -exact [lmap a $arms {expr {[dict get $a caseDesc fields] eq {}}}] 1]
                set arm [lindex $arms $i]
                dict set arm bind whole
                dict set arm name pz
                lset arms $i $arm
                set code ENUM-PAYLOAD-UNEXPECTED
            }
            unknownfield {
                set i [lsearch -exact [lmap a $arms {expr {[dict get $a bind] eq "pattern"}}] 1]
                set arm [lindex $arms $i]
                dict set arm pattern [linsert [dict get $arm pattern] end {zz zz1}]
                lset arms $i $arm
                set code UNKNOWN-FIELD
            }
            untyped - nonenum {
                set code TYPE
            }
        }
        dict set match arms $arms
        dict set f match $match
        dict set f fault $fault
        lset functions 0 $f
    }
    # The source.
    set lines [list "import std::str"]
    lappend lines "" "error Bad:" "    code: int" ""
    foreach e $enums {
        lappend lines "enum [dict get $e name]:"
        foreach c [dict get $e cases] {
            if {[dict get $c fields] eq {}} {
                lappend lines "    [dict get $c name],"
            } else {
                lappend lines "    [dict get $c name] \{[join [lmap f [dict get $c fields] {string cat [lindex $f 0] ": " [lindex $f 1]}] {, }]\},"
            }
        }
        lappend lines ""
    }
    lappend lines "fn slen(s: str) -> int:" "    std::str::length(s)" "" \
        "fn b2i(b: bool) -> int:" "    if b:" "        1" "    else:" "        0" ""
    set calls {}
    set expected {}
    foreach f $functions {
        set name [dict get $f name]
        set ex [dict get $f ex]
        set ey [dict get $f ey]
        set fails [Fails [dict get $f match]]
        set errors [expr {$fails ? " errors Bad" : ""}]
        set fault [dict getdef $f fault ""]
        set xparam [expr {$fault eq "untyped" ? "x" : "x: [dict get $ex name]"}]
        lappend lines "fn $name\($xparam, y: [dict get $ey name]) -> int$errors:"
        set body [MatchLines [dict get $f match] 1]
        if {$fault eq "nonenum"} {
            lset body 0 "    match 3:"
        }
        lappend lines {*}$body
        if {$fails} {
            lappend lines "fn call_$name\(x: [dict get $ex name], y: [dict get $ey name]) -> int:" \
                "    $name\(x, y):" "        on Bad \{code\}:" "            0 - code"
            set caller call_$name
        } else {
            set caller $name
        }
        set results {}
        set texts {}
        for {set j 0} {$j < 2 + [rand 4]} {incr j} {
            set x [Value $ex]
            set y [Value $ey]
            lappend texts "$caller\([ValueText $x], [ValueText $y])"
            if {$fault eq ""} {
                lassign [model::Match [dict get $f match] $x $y {}] how v
                lappend results [expr {$how eq "fail" ? -$v : $v}]
            }
        }
        lappend calls "\[[join $texts {, }]\]"
        lappend expected "\[[join $results {, }]\]"
    }
    lappend lines "\[[join $calls {, }]\]"
    set source "[join $lines \n]\n"
    set fault [dict getdef [lindex $functions 0] fault ""]
    if {$fault ne ""} {
        return [list $source [list error $code] $fault]
    }
    return [list $source [list value "\[[join $expected {, }]\]"] ""]
}

# ---------------------------------------------------------------------------
# The run

set gen::state [dict get $options -seed]
set n [dict get $options -n]
set backends [dict get $options -backends]
set failures 0
set accepted 0
set rejected 0
set faultCounts [dict create]
if {[dict get $options -gc-stress]} {
    set ::env(BOTLISH_NATIVE_GC_STRESS) 1
}
for {set i 0} {$i < $n} {incr i} {
    lassign [gen::Program [dict get $options -faults]] source expected fault
    if {[dict get $options -verbose]} {
        puts "--- program $i ($expected)\n$source"
    }
    if {[catch {surface::compile $source fz.bot -warnings off} hir compileOptions]} {
        set code [lindex [dict get $compileOptions -errorcode] end]
        if {[lindex $expected 0] eq "error" && $code eq [lindex $expected 1]} {
            incr rejected
            dict incr faultCounts $fault
            continue
        }
        incr failures
        puts "DISAGREE program $i: expected $expected, compilation failed ($code): [lindex [split $hir \n] 0]\n$source"
        continue
    }
    if {[lindex $expected 0] eq "error"} {
        incr failures
        puts "DISAGREE program $i: expected [lindex $expected 1] ($fault), the program was accepted\n$source"
        continue
    }
    set want [lindex $expected 1]
    foreach backend $backends {
        set outcome [outcomeUnderHir $backend $hir]
        if {[lindex $outcome 0] ne "value" || [lindex $outcome 1] ne $want} {
            incr failures
            puts "DISAGREE program $i on $backend: model $want, got [lrange $outcome 0 2]\n$source"
            break
        }
    }
    incr accepted
}
puts [format "fuzz: %d programs (seed %s): %d accepted and agreeing on %s, %d rejected as predicted (%s), %d disagreements" \
    $n [dict get $options -seed] $accepted [join $backends {, }] $rejected \
    [join [lmap {k v} $faultCounts {string cat $k " " $v}] {, }] $failures]
exit [expr {$failures > 0}]

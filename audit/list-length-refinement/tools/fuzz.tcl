# fuzz.tcl -- differential and soundness fuzzer of the List length
# refinement List[T]{length: N} (LIST-CARDINALITY-REFINEMENTS.md).
#
#   tclsh9.0 audit/list-length-refinement/tools/fuzz.tcl ?-seed N? ?-count N?
#       ?-backends "interp compile cranelift-generic cranelift"?
#       ?-gc-stress 0|1? ?-verbose 0|1? ?-keep DIR?
#
# Each case is a small random program that builds a List from random
# sources -- literals, numeric and List collecting loops, list::append, a
# filtering loop, a branch choosing between two Lists, a parameter of
# unknown length, an undeclared and a declared function result,
# list::with_length, copies of fixed layout arrays -- nested up to three
# deep, and hands it to a consumer that requires an exact length N: a
# refined parameter directly, behind a `list::length(xs) == N` guard, behind
# a `!=` early return, through list::with_length, through a refined struct
# field; or reads an index J of a refined parameter or of a source's List
# (with no handler where the rules promise its length, under one where they
# do not); or writes a copied array of extent N into an array of extent E.
#
# The oracle is the generator's own: it knows each source's run-time List
# (it computes it) and the exact length the language promises statically
# for it, by the rules of LIST-CARDINALITY-REFINEMENTS.md written out here
# from scratch (a literal's count, a collecting loop's domain, append's
# one more, an equal-length join, a declared result, a validator's
# imprint; nothing for a filter, a parameter, an undeclared result or an
# unequal join) -- never by asking hir/types.tcl or hir/cardinality.tcl. A
# case disagrees when
#
#   * the compiler accepts a program the rules reject, or rejects one they
#     accept, or rejects it with another diagnostic kind (TYPE for an
#     unproven length, KNOWN-ERROR for an index or an extent proven wrong);
#   * an accepted program's value on some backend is not the oracle's --
#     the run-time List itself is part of every value, so a refinement the
#     run does not have (an unsound fact) shows as a wrong List, a wrong
#     guard decision or a crash -- or the backends disagree.
#
# It prints one line per disagreement, the case mix, and a final "cases N
# disagreements D" line; the exit status is 1 when D > 0.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -seed 1 -count 60 -backends "interp compile cranelift-generic cranelift" \
    -gc-stress 0 -verbose 0 -keep ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set backends [dict get $options -backends]
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
if {[catch {native::binary}]} {
    set backends [lsearch -all -inline -not -glob $backends cranelift*]
}

expr {srand([dict get $options -seed])}
proc random {n} { return [expr {int(rand() * $n)}] }
proc pick {list} { return [lindex $list [random [llength $list]]] }
proc chance {p} { return [expr {rand() < $p}] }

# ---------------------------------------------------------------------------
# Sources. Each is a dict:
#   lines   the statements that compute it, indented for a function body
#   var     the variable they bind
#   value   the oracle's run-time List (a Tcl list of Ints, or of such lists)
#   static  the exact length the rules promise statically, or ""
#   inner   for a List of Lists: the exact length every element is promised
#           statically, or ""
#   helpers top-level declarations the lines use

namespace eval gen {
    variable counter 0
}

proc gen::Fresh {prefix} {
    variable counter
    incr counter
    return "$prefix$counter"
}

proc gen::Source {depth} {
    set kinds {lit lit count through param}
    if {$depth > 0} {
        lappend kinds append map filter join join undeclared declared validator
    }
    set kind [pick $kinds]
    set var [Fresh v]
    switch -- $kind {
        lit {
            set n [random 5]
            set value [lmap i [lrepeat $n 0] {expr {[random 9] - 2}}]
            return [dict create lines [list "$var = \[[join $value {, }]\]"] var $var value $value static $n inner "" helpers {}]
        }
        count {
            set n [random 5]
            set value {}
            for {set i 0} {$i < $n} {incr i} { lappend value [expr {$i * 3}] }
            return [dict create lines [list "$var = loop i from 0 to $n:" "    i * 3"] var $var value $value static $n inner "" helpers {}]
        }
        through {
            set n [random 4]
            set value {}
            for {set i 1} {$i <= $n} {incr i} { lappend value [expr {$i + 1}] }
            return [dict create lines [list "$var = loop i from 1 through $n:" "    i + 1"] var $var value $value static $n inner "" helpers {}]
        }
        param {
            # The function's own parameter p: its length is the caller's,
            # never statically known here.
            return [dict create lines [list "$var = p"] var $var value $::paramValue static "" inner "" helpers {}]
        }
        append {
            set src [Source [expr {$depth - 1}]]
            set x [random 7]
            set static [expr {[dict get $src static] eq "" ? "" : [dict get $src static] + 1}]
            return [dict create lines [concat [dict get $src lines] [list "$var = list::append([dict get $src var], $x)"]] \
                var $var value [concat [dict get $src value] [list $x]] static $static inner "" helpers [dict get $src helpers]]
        }
        map {
            set src [Source [expr {$depth - 1}]]
            set value [lmap x [dict get $src value] {expr {$x + 1}}]
            return [dict create lines [concat [dict get $src lines] [list "$var = loop x in [dict get $src var]:" "    x + 1"]] \
                var $var value $value static [dict get $src static] inner "" helpers [dict get $src helpers]]
        }
        filter {
            set src [Source [expr {$depth - 1}]]
            set t [random 4]
            set value [lmap x [dict get $src value] {if {$x == $t} continue; set x}]
            return [dict create lines [concat [dict get $src lines] [list "$var = loop x in [dict get $src var]:" "    if x == $t:" "        continue" "    x"]] \
                var $var value $value static "" inner "" helpers [dict get $src helpers]]
        }
        join {
            set a [Source [expr {$depth - 1}]]
            set b [Source [expr {$depth - 1}]]
            set static ""
            if {[dict get $a static] ne "" && [dict get $a static] eq [dict get $b static]} {
                set static [dict get $a static]
            }
            set value [expr {$::cValue ? [dict get $a value] : [dict get $b value]}]
            return [dict create lines [concat [dict get $a lines] [dict get $b lines] \
                    [list "$var = if c:" "    [dict get $a var]" "else:" "    [dict get $b var]"]] \
                var $var value $value static $static inner "" helpers [concat [dict get $a helpers] [dict get $b helpers]]]
        }
        undeclared {
            # An undeclared result forgets the literal's length.
            set n [random 5]
            set value [lmap i [lrepeat $n 0] {random 9}]
            set fn [Fresh u]
            return [dict create lines [list "$var = ${fn}()"] var $var value $value static "" inner "" \
                helpers [list "fn ${fn}():\n    \[[join $value {, }]\]"]]
        }
        declared {
            set n [random 5]
            set value [lmap i [lrepeat $n 0] {random 9}]
            set fn [Fresh d]
            return [dict create lines [list "$var = ${fn}()"] var $var value $value static $n inner "" \
                helpers [list "fn ${fn}() -> List\[int\]{length: $n}:\n    \[[join $value {, }]\]"]]
        }
        validator {
            set src [Source [expr {$depth - 1}]]
            set k [random 5]
            set fallback [lrepeat $k 7]
            set value [expr {[llength [dict get $src value]] == $k ? [dict get $src value] : $fallback}]
            return [dict create lines [concat [dict get $src lines] [list \
                    "$var = list::with_length\[List\[int\]{length: $k}\]([dict get $src var]):" \
                    "    on LengthMismatch:" "        \[[join $fallback {, }]\]"]] \
                var $var value $value static $k inner "" helpers [dict get $src helpers]]
        }
    }
}

# The display of the oracle's List VALUE, as core::value::show prints it.
proc gen::Show {value} {
    return "\[[join $value {, }]\]"
}

# ---------------------------------------------------------------------------
# Cases: {source TEXT expect accepted|KIND value DISPLAY family F}

proc gen::Program {helpers bodyLines params} {
    set text "import list\n"
    foreach h [lsort -unique $helpers] {
        append text $h "\n\n"
    }
    append text "fn consume(xs: List\[int\]{length: \$N}) -> List\[int\]:\n    xs\n\n"
    append text "fn run($params) -> List\[int\]:\n"
    foreach line $bodyLines {
        append text "    $line\n"
    }
    return $text
}

proc gen::ConsumerCase {} {
    set ::cValue [random 2]
    set ::paramValue [lmap i [lrepeat [random 5] 0] {random 9}]
    set src [Source [expr {1 + [random 3]}]]
    set n [expr {[chance 0.5] && [dict get $src static] ne "" ? [dict get $src static] : [random 5]}]
    set mode [pick {direct direct guard neguard validator field}]
    set v [dict get $src var]
    set static [dict get $src static]
    set actual [dict get $src value]
    set helpers [dict get $src helpers]
    switch -- $mode {
        direct {
            set tail [list "consume($v)"]
            set expect [expr {$static ne "" && $static == $n ? "accepted" : "TYPE"}]
            set value $actual
        }
        guard {
            set tail [list "if list::length($v) == $n:" "    consume($v)" "else:" "    \[-1\]"]
            set expect accepted
            set value [expr {[llength $actual] == $n ? $actual : {-1}}]
        }
        neguard {
            set tail [list "if list::length($v) != $n:" "    return \[-1\]" "consume($v)"]
            set expect accepted
            set value [expr {[llength $actual] == $n ? $actual : {-1}}]
        }
        validator {
            set tail [list "w = list::with_length\[List\[int\]{length: $n}\]($v):" "    on LengthMismatch:" "        return \[-1\]" "consume(w)"]
            set expect accepted
            set value [expr {[llength $actual] == $n ? $actual : {-1}}]
        }
        field {
            lappend helpers "struct Hold:\n    xs: List\[int\]{length: $n}"
            set tail [list "h = Hold{xs: $v}" "consume(h.xs)"]
            set expect [expr {$static ne "" && $static == $n ? "accepted" : "TYPE"}]
            set value $actual
        }
    }
    set text [string map [list \$N $n] [Program $helpers [concat [dict get $src lines] $tail] "c: bool, p: List\[int\]"]]
    append text "run([expr {$::cValue ? "true" : "false"}], [Show $::paramValue])\n"
    return [dict create source $text expect $expect value [Show $value] family consumer-$mode]
}

proc gen::IndexCase {} {
    if {[chance 0.5]} {
        # A refined parameter.
        set n [random 5]
        set j [expr {[random 7] - 1}]
        set value [lmap i [lrepeat $n 0] {random 9}]
        set text "import list\nfn pick(xs: List\[int\]{length: $n}) -> int:\n    xs.at($j)\n\npick(\[[join $value {, }]\])\n"
        if {$j >= 0 && $j < $n} {
            return [dict create source $text expect accepted value [lindex $value $j] family index-in]
        }
        return [dict create source $text expect KNOWN-ERROR value "" family index-out]
    }
    # A List some source computes, read through its binding: a source whose
    # length the rules promise is read with no handler (an index below the
    # length is proven, one outside a known failure); any other is read
    # under a handler, where a known failure is only sound when the index is
    # outside the List the run computes (a proof beyond the rules' own).
    set ::cValue [random 2]
    set ::paramValue [lmap i [lrepeat [random 5] 0] {random 9}]
    set src [Source [expr {1 + [random 3]}]]
    set static [dict get $src static]
    set actual [dict get $src value]
    set j [expr {[random [expr {[llength $actual] + 3}]] - 1}]
    set v [dict get $src var]
    set inside [expr {$j >= 0 && $j < [llength $actual]}]
    set text "import list\n"
    foreach h [lsort -unique [dict get $src helpers]] {
        append text $h "\n\n"
    }
    append text "fn run(c: bool, p: List\[int\]) -> int:\n"
    foreach line [dict get $src lines] {
        append text "    $line\n"
    }
    if {$static ne ""} {
        append text "    $v.at($j)\n"
    } else {
        append text "    r = $v.at($j):\n        on IndexNotFound:\n            -1\n    r\n"
    }
    append text "run([expr {$::cValue ? "true" : "false"}], [Show $::paramValue])\n"
    if {$static ne ""} {
        if {$inside} {
            return [dict create source $text expect accepted value [lindex $actual $j] family index-source-in]
        }
        return [dict create source $text expect KNOWN-ERROR value "" family index-source-out]
    }
    set value [expr {$inside ? [lindex $actual $j] : -1}]
    set also [expr {$inside ? {} : {KNOWN-ERROR}}]
    return [dict create source $text expect accepted value $value also $also family index-source-unknown]
}

proc gen::ExtentCase {} {
    set n [expr {1 + [random 4]}]
    set e [expr {[chance 0.5] ? $n : 1 + [random 4]}]
    set text [string cat "import abi\nimport abi::bytes\nimport binary\nimport byte\nimport list\n\n" \
        "layout SRC:\n    size $n\n    align 1\n    field b: array $n of binary::U8 at 0\n\n" \
        "layout DST:\n    size $e\n    align 1\n    field b: array $e of binary::U8 at 0\n\n" \
        "fn bytes_of(k: int) -> abi::bytes::Bytes:\n    bs = loop v from 0 to k:\n        b = byte::from_int(v * 7):\n            on byte::BelowRange:\n                0\n            on byte::AboveRange:\n                255\n        b\n    abi::bytes::from_list(bs)\n\n" \
        "fn put(xs: List\[binary::U8\]{length: $n}) -> abi::bytes::Bytes:\n    binary::emit(LayoutStruct\[DST\]{b: xs})\n\n" \
        "fn run():\n    s = binary::parse(SRC, bytes_of($n)):\n        on LayoutLengthMismatch:\n            return \[\]\n" \
        "    d = binary::parse(DST, put(s.b)):\n        on LayoutLengthMismatch:\n            return \[\]\n    d.b\n\nrun()\n"]
    if {$n == $e} {
        set value {}
        for {set i 0} {$i < $n} {incr i} { lappend value [expr {$i * 7}] }
        return [dict create source $text expect accepted value [Show $value] family extent-equal]
    }
    return [dict create source $text expect KNOWN-ERROR value "" family extent-unequal]
}

proc gen::NestedCase {} {
    set rows [random 4]
    set cols [random 3]
    set mode [pick {lit loop ragged}]
    switch -- $mode {
        lit {
            set value [lmap r [lrepeat $rows 0] {lmap c [lrepeat $cols 0] {random 9}}]
            set expr "\[[join [lmap row $value {Show $row}] {, }]\]"
            set static [list $rows $cols]
            set lines [list "vs = $expr"]
        }
        loop {
            set value {}
            for {set i 0} {$i < $rows} {incr i} { lappend value [lrepeat $cols $i] }
            set lines [list "vs = loop i from 0 to $rows:" "    \[[join [lrepeat $cols i] {, }]\]"]
            set static [list $rows $cols]
        }
        ragged {
            set value {}
            for {set i 0} {$i < $rows} {incr i} { lappend value [lrepeat [expr {$i % 2 + 1}] $i] }
            set expr "\[[join [lmap row $value {Show $row}] {, }]\]"
            set lines [list "vs = $expr"]
            set static [list $rows [expr {$rows <= 1 ? 1 : ""}]]
        }
    }
    set wantRows [expr {[chance 0.6] ? $rows : [random 4]}]
    set wantCols [expr {[chance 0.6] ? $cols : [random 3]}]
    lassign $static sr sc
    if {$rows == 0} {
        # The empty List[never] states every element fact vacuously.
        set ok [expr {$wantRows == 0}]
    } else {
        set ok [expr {$sr == $wantRows && $sc ne "" && $sc == $wantCols}]
    }
    set text [string cat "import list\nfn consume(xss: List\[List\[int\]{length: $wantCols}\]{length: $wantRows}) -> List\[List\[int\]\]:\n    xss\n\n" \
        "fn run() -> List\[List\[int\]\]:\n" [join [lmap l $lines {string cat "    " $l}] \n] "\n    consume(vs)\n\nrun()\n"]
    return [dict create source $text expect [expr {$ok ? "accepted" : "TYPE"}] \
        value "\[[join [lmap row $value {Show $row}] {, }]\]" family nested-$mode]
}

# ---------------------------------------------------------------------------
# Running

# {accepted HIR} or {rejected KINDS MESSAGE}, KINDS every diagnostic's.
proc Diagnosis {text} {
    if {[catch {surface::compile $text fuzz.bot -warnings off} message options]} {
        if {[dict exists $options -diagnostics]} {
            return [list rejected [lmap d [dict get $options -diagnostics] {lindex [dict get $d errorcode] end}] $message]
        }
        return [list rejected [list [lindex [dict get $options -errorcode] end]] $message]
    }
    return [list accepted $message]
}

proc Run {backend hir} {
    set saved [core::useBackend]
    resetEffects
    try {
        if {[catch {
            switch -- $backend {
                interp {
                    core::useBackend interp
                    core::evalProgram [hir::lower $hir]
                }
                compile { core::compiler::evalHir $hir }
                cranelift-generic { native::evalHir $hir -specialize 0 }
                cranelift { native::evalHir $hir }
            }
        } result options]} {
            return [list error [lrange [dict get $options -errorcode] 0 2] $result]
        }
        return [list value [core::value::show $result]]
    } finally {
        core::useBackend $saved
    }
}

if {[dict get $options -gc-stress]} {
    set ::env(BOTLISH_NATIVE_GC_STRESS) 1
}
set cases 0
set disagreements 0
set mix [dict create]
for {set k 0} {$k < [dict get $options -count]} {incr k} {
    set case [switch -- [pick {consumer consumer consumer consumer index index extent nested nested}] {
        consumer { gen::ConsumerCase }
        index { gen::IndexCase }
        extent { gen::ExtentCase }
        nested { gen::NestedCase }
    }]
    incr cases
    set text [dict get $case source]
    lassign [Diagnosis $text] verdict a b
    set family [dict get $case family]
    # A rejection is the expected one when its diagnostics include the
    # expected kind (a call of a function that can only fail is also an
    # unhandled error of its caller).
    set got [expr {$verdict eq "accepted" ? "accepted" : [lindex $a 0]}]
    if {$verdict ne "accepted" && [dict get $case expect] in $a} {
        set got [dict get $case expect]
    }
    dict incr mix "$family/$got"
    set problem ""
    if {$got ne [dict get $case expect] && $got in [dict getdef $case also {}]} {
        # (A sound outcome beyond what the rules promise: nothing runs.)
    } elseif {$got ne [dict get $case expect]} {
        set problem "expected [dict get $case expect], got $got[if {$verdict ne "accepted"} {string cat ": $b"}]"
    } elseif {$verdict eq "accepted"} {
        set outcomes [lmap backend $backends {Run $backend $a}]
        foreach backend $backends outcome $outcomes {
            if {$outcome ne [list value [dict get $case value]]} {
                set problem "on $backend: expected [dict get $case value], got $outcome"
                break
            }
        }
    }
    if {$problem ne ""} {
        incr disagreements
        puts "DISAGREE case $k ($family): $problem"
        if {[dict get $options -verbose]} {
            puts $text
        }
        if {[dict get $options -keep] ne ""} {
            file mkdir [dict get $options -keep]
            set f [open [file join [dict get $options -keep] case$k.bot] w]
            puts -nonewline $f $text
            close $f
        }
    }
}
foreach key [lsort [dict keys $mix]] {
    puts "  $key [dict get $mix $key]"
}
puts "cases $cases disagreements $disagreements"
exit [expr {$disagreements > 0}]

#!/usr/bin/env tclsh9.0
# fuzz.tcl -- bounded randomized check of the standard-namespace cleanup
# (STDLIB-NAMESPACES.md): list::at / list::get, mutable_array::at /
# mutable_array::get / mutable_array::set, str::* and list::* intrinsics in
# free and method spelling, the eager default of get, and the programs the
# cleanup made illegal.
#
#   tclsh9.0 audit/stdlib-namespaces/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1? ?-backends LIST?
#
# Each program is seeded individually and built from random Lists (Ints,
# Strings, nested Lists; empty included), random indices (in range, past the
# end, negative, a BigInt) and random defaults, as a List of checks whose
# expected value an independent Tcl oracle computes:
#
#   get        list::get(XS, I, D) / XS.get(I, D) (bound `get = list::get`)
#   explicit   list::get(XS, I, D) == the explicit at-with-handler program
#              (`v = list::at(xs, i): on IndexNotFound: d`) -- the theorem
#              that get has no semantics of its own
#   at         list::at through a handled call, free and method spelling:
#              the element, or the handler's "missing" for IndexNotFound
#   array      the same three for mutable_array::from_list(XS) with
#              mutable_array::at/get, plus mutable_array::set followed by a
#              read, by method spelling (bound names)
#   eager      list::get(XS, I, mark(D)): mark counts its own evaluations in
#              a one-slot MutableArray, read back at the end -- the default
#              is evaluated exactly once per call, present index or not
#   strings    str::concat/str::length/list::append/list::length, free and
#              method spelling
#
# The oracle checks every backend's value, and the backends must agree.
#
# Each program also has one NEGATIVE program, rotating through the shapes
# the cleanup must reject: `a eq b` (syntax), `eq(a, b)` and every
# historical root name (unbound), a namespace-declaring program redefining a
# protected intrinsic member (DUPLICATE-NATIVE), a provably missing literal
# index (KNOWN-ERROR), an unproven list::at in an undeclaring function
# (UNHANDLED-ERROR), a method spelling of an intrinsic never bound to a name
# (no function visible), and get applied to a non-List (the TYPE error
# propagates on every backend: it is not swallowed into the default). A
# negative program accepted, or rejected for another reason, is a "negative
# escape".
#
# The run ends with "stdlib-ns-fuzz programs N values V negatives M
# oracle-disagreements D negative-escapes X backend-disagreements B"; the
# exit status is 1 if D, X or B is not zero.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 100
set seed0 1
set dump 0
set backends {interp compile cranelift-generic cranelift}
while {[lindex $args 0] in {-n -seed -dump -backends}} {
    switch -- [lindex $args 0] {
        -n { set n [lindex $args 1] }
        -seed { set seed0 [lindex $args 1] }
        -dump { set dump [lindex $args 1] }
        -backends { set backends [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc rnd {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }

# ---------------------------------------------------------------------------
# Values: each is {SOURCE-TEXT SHOWN} (SHOWN as core::value::show prints it)

proc genScalar {} {
    if {rand() < 0.6} {
        set v [rnd -20 99]
        return [list $v $v]
    }
    set s [pick {a bc "" xyz é Q}]
    return [list "\"$s\"" "\"$s\""]
}

proc genList {{depth 0}} {
    set items {}
    foreach _ [lrepeat [rnd 0 4] x] {
        if {$depth == 0 && rand() < 0.15} {
            lappend items [genList 1]
        } else {
            lappend items [genScalar]
        }
    }
    return [list "\[[join [lmap i $items {lindex $i 0}] {, }]\]" "\[[join [lmap i $items {lindex $i 1}] {, }]\]" $items]
}

proc genIndex {len} {
    set r [expr {rand()}]
    if {$r < 0.5 && $len > 0} { return [rnd 0 [expr {$len - 1}]] }
    if {$r < 0.7} { return [expr {$len + [rnd 0 2]}] }
    if {$r < 0.9} { return [rnd -3 -1] }
    return 100000000000000000000
}

# The element of ITEMS at I as SHOWN, or "" when I designates no element.
proc elementAt {items i} {
    if {$i < 0 || $i >= [llength $items]} { return "" }
    return [lindex [lindex $items $i] 1]
}

proc literalString {} { return [pick {"" a bc "héllo" "x y"}] }

# ---------------------------------------------------------------------------
# Program text

set ::prelude {log = mutable_array::allocate(1)
mutable_array::set(log, 0, 0)
fn mark(v):
    mutable_array::set(log, 0, mutable_array::at(log, 0) + 1)
    v
fn explicit(xs, i, d):
    v = list::at(xs, i):
        on IndexNotFound:
            d
    v
fn explicit_array(a, i, d):
    v = mutable_array::at(a, i):
        on IndexNotFound:
            d
    v
at = list::at
get = list::get
aat = mutable_array::at
aget = mutable_array::get
aset = mutable_array::set
concat = str::concat
slength = str::length
append = list::append
llength = list::length
fn at_free(xs, i):
    v = list::at(xs, i):
        on IndexNotFound:
            "missing"
    v
fn at_method(xs, i):
    v = xs.at(i):
        on IndexNotFound:
            "missing"
    v
fn array_at(a, i):
    v = a.aat(i):
        on IndexNotFound:
            "missing"
    v
fn set_then_read(xs, i, value):
    a = mutable_array::from_list(xs)
    a.aset(i, value)
    v = a.aat(i):
        on IndexNotFound:
            "missing"
    v
}

# One check: {SOURCE EXPECTED-SHOWN MARKS} (MARKS: mark() evaluations).
proc genCheck {} {
    lassign [genList] xs _ items
    set len [llength $items]
    set i [genIndex $len]
    lassign [genScalar] d dShown
    set elem [elementAt $items $i]
    set got [expr {$elem eq "" ? $dShown : $elem}]
    set missing [expr {$elem eq "" ? {"missing"} : $elem}]
    switch -- [pick {get get-method explicit at at-method array-get array-get-method array-explicit array-at array-set eager strings lists}] {
        get { return [list "list::get($xs, $i, $d)" $got 0] }
        get-method { return [list "$xs.get($i, $d)" $got 0] }
        explicit { return [list "list::get($xs, $i, $d) == explicit($xs, $i, $d)" true 0] }
        at { return [list "at_free($xs, $i)" $missing 0] }
        at-method { return [list "at_method($xs, $i)" $missing 0] }
        array-get { return [list "mutable_array::get(mutable_array::from_list($xs), $i, $d)" $got 0] }
        array-get-method { return [list "mutable_array::from_list($xs).aget($i, $d)" $got 0] }
        array-explicit {
            return [list "mutable_array::get(mutable_array::from_list($xs), $i, $d) == explicit_array(mutable_array::from_list($xs), $i, $d)" true 0]
        }
        array-at { return [list "array_at(mutable_array::from_list($xs), $i)" $missing 0] }
        array-set {
            if {$len == 0} { return [list "array_at(mutable_array::from_list($xs), 0)" {"missing"} 0] }
            # The stored value is one of the List's own elements: the array
            # from_list builds is MutableArray[T] for the List's element type
            # T, which a store never widens (PARAMETERIZED-MUTABLEARRAY.md),
            # so an arbitrary scalar would be a (correct) static rejection.
            set j [rnd 0 [expr {$len - 1}]]
            set stored [lindex $items [rnd 0 [expr {$len - 1}]]]
            return [list "set_then_read($xs, $j, [lindex $stored 0])" [lindex $stored 1] 0]
        }
        eager { return [list "list::get($xs, $i, mark($d))" $got 1] }
        strings {
            set a [literalString]
            set b [literalString]
            set joined "$a$b"
            return [list "\[str::concat(\"$a\", \"$b\") == \"$a\".concat(\"$b\"), \"$a\".concat(\"$b\").slength(), str::length(\"$joined\")\]" \
                "\[true, [string length $joined], [string length $joined]\]" 0]
        }
        lists {
            return [list "\[list::length(list::append($xs, $d)), $xs.append($d).llength(), list::get(list::append($xs, $d), $len, \"no\") == $d\]" \
                "\[[expr {$len + 1}], [expr {$len + 1}], true\]" 0]
        }
    }
}

proc program {checks} {
    set exprs [lmap c $checks {lindex $c 0}]
    lappend exprs "mutable_array::at(log, 0)"
    return "$::prelude\[[join $exprs ",\n"]\]"
}

proc expected {checks} {
    set marks 0
    foreach c $checks { incr marks [lindex $c 2] }
    set shown [lmap c $checks {lindex $c 1}]
    lappend shown $marks
    return "\[[join $shown {, }]\]"
}

# ---------------------------------------------------------------------------
# Running

proc stripLocations {message} {
    return [regsub -all {[^ ]*\.bot:[0-9]+:[0-9]+} $message {t.bot:L:C}]
}

# HIR of SOURCE (read as a program file: library modules resolve), or
# {error CODE MESSAGE}.
proc compileFile {source {strict 1}} {
    set path [file join $::scratch t.bot]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $source
    close $channel
    if {[catch {surface::readProgramFile $path -strict $strict} hir options]} {
        return [list error [dict get $options -errorcode] [stripLocations $hir]]
    }
    return [list ok $hir]
}

proc outcomesOf {source {strict 1}} {
    set compiled [compileFile $source $strict]
    if {[lindex $compiled 0] eq "error"} {
        return [lmap b $::backends {set compiled}]
    }
    return [lmap b $::backends {
        set outcome [outcomeUnderHir $b [lindex $compiled 1]]
        if {[lindex $outcome 0] eq "value"} {
            list value [lindex $outcome 1]
        } else {
            list error [lindex $outcome 1]
        }
    }]
}

set ::protected {}
foreach name [core::native::names] {
    if {[string first :: $name] > 0 && ![string match linux::* $name]} {
        lappend ::protected $name
    }
}
set ::historical {
    {list_get([1], 0)} {list_append([1], 2)} {list_length([1])} {concat("a", "b")} {length("a")}
    {substring("ab", 0, 1)} {lowercase("A")} {encode_utf8("a")} {is_tcl_alpha("a")} {is_tcl_alnum("a")}
    {char_codepoint('a')} {mutable_array_allocate(1)} {mutable_array_get(mutable_array::allocate(1), 0)}
    {mutable_array_set(mutable_array::allocate(1), 0, 1)} {immutable_set_from_list([1])}
}

# {SOURCE STRICT CHECK} of a negative program: CHECK is a script that, given
# the program's outcome list, returns "" if the rejection is right, or why
# not.
proc negative {k} {
    lassign [genList] xs _ items
    set len [llength $items]
    switch -- [expr {$k % 8}] {
        0 { return [list "x = \"a\" eq \"a\"\nx" 1 {expect-code {SURFACE SYNTAX}}] }
        1 { return [list "eq(\"a\", \"a\")" 1 {expect-message UNBOUND}] }
        2 { return [list [pick $::historical] 1 {expect-message UNBOUND}] }
        3 {
            set full [pick $::protected]
            set i [string last :: $full]
            set ns [string range $full 0 [expr {$i - 1}]]
            set member [string range $full [expr {$i + 2}] end]
            return [list "namespace $ns\n\nfn ${member}(x):\n    x\n" 1 {expect-code {SURFACE MODULE DUPLICATE-NATIVE}}]
        }
        4 { return [list "list::at($xs, [expr {$len + [rnd 0 3]}])" 1 {expect-message KNOWN-ERROR}] }
        5 { return [list "fn f(xs, i):\n    list::at(xs, i)\nf($xs, 0)" 1 {expect-message UNHANDLED-ERROR}] }
        6 { return [list "$xs.at(0)" 1 {expect-text {no function named "at" is visible}}] }
        7 { return [list "list::get(\"abc\", 0, 1)" 0 {expect-runtime {CORE SEMANTIC TYPE}}] }
    }
}

proc checkNegative {outcomes check} {
    lassign $check kind want
    foreach outcome $outcomes {
        lassign $outcome tag code message
        if {$tag ne "error"} {
            return "accepted: $outcome"
        }
        switch -- $kind {
            expect-code {
                if {[lrange $code 0 [llength $want]-1] ne $want} { return "rejected as $code: $message" }
            }
            expect-message {
                if {[lindex $code end] ne $want} { return "rejected as $code: $message" }
            }
            expect-text {
                if {[string first $want $message] < 0} { return "rejected as $code: $message" }
            }
            expect-runtime {
                if {$code ne $want} { return "failed as $code" }
            }
        }
    }
    return ""
}

set scratch [file join $root .fuzz-stdlib-namespaces]
file mkdir $scratch

set programs 0
set values 0
set negatives 0
set oracleDisagreements 0
set negativeEscapes 0
set backendDisagreements 0

try {
    for {set k 0} {$k < $n} {incr k} {
        set seed [expr {$seed0 + $k}]
        expr {srand($seed)}
        set checks [lmap _ [lrepeat [rnd 3 8] x] {genCheck}]
        set source [program $checks]
        set want [expected $checks]
        if {$dump} {
            puts "---- seed $seed\n$source\n-- expect: $want"
        }
        incr programs
        set outcomes [outcomesOf $source]
        if {[llength [lsort -unique $outcomes]] != 1} {
            incr backendDisagreements
            puts "BACKEND DISAGREEMENT seed $seed"
            foreach backend $backends outcome $outcomes { puts "  $backend: $outcome" }
        } elseif {[lindex $outcomes 0] ne [list value $want]} {
            incr oracleDisagreements
            puts "ORACLE DISAGREEMENT seed $seed: expected $want, got [lindex $outcomes 0]"
        } else {
            incr values
        }

        lassign [negative $k] negSource strict check
        if {$dump} {
            puts "-- negative ($check)\n$negSource"
        }
        incr negatives
        set why [checkNegative [outcomesOf $negSource $strict] $check]
        if {$why ne ""} {
            incr negativeEscapes
            puts "NEGATIVE ESCAPE seed $seed ($check): $why\n$negSource"
        }
    }
} finally {
    file delete -force $scratch
}

puts "stdlib-ns-fuzz programs $programs values $values negatives $negatives oracle-disagreements $oracleDisagreements negative-escapes $negativeEscapes backend-disagreements $backendDisagreements"
exit [expr {$oracleDisagreements || $negativeEscapes || $backendDisagreements}]

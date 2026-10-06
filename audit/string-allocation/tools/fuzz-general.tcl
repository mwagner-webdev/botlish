#!/usr/bin/env tclsh9.0
# fuzz-general.tcl -- bounded randomized differential check of GENERAL String
# construction (STRING-ALLOCATION.md): the canonical one-allocation String
# built by concat, substring (ASCII and non-ASCII bases, every width, empty
# results), lowercase, calls with String parameters/results, recursion
# accumulating a String, storage in a List / MutableArray / struct / captured
# local, hashing, equality and out-of-range errors, over Strings of 0..~20
# characters mixing ASCII, Latin-1, ellipsis, BMP, astral, combining marks and
# NUL. Compares the reference interpreter, the Tcl compile backend and native
# with the short-String switch off/on, the packed-ASCII tier off/on, the demand
# rule off/on and leaf inlining off/on (and with -specialize 0 under
# -generic 1), for values, errors (code and message) and completion behavior.
# Run it under BOTLISH_NATIVE_GC_STRESS=1 for the GC-stress variant.
#
#   tclsh9.0 audit/string-allocation/tools/fuzz-general.tcl ?-n N? ?-seed S? ?-generic 1? ?-dump 1?
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 100000
set n 100
set seed0 1
set generic 0
set dump 0
while {[lindex $args 0] in {-n -seed -generic -dump}} {
    switch -- [lindex $args 0] {
        -n { set n [lindex $args 1] }
        -seed { set seed0 [lindex $args 1] }
        -generic { set generic [lindex $args 1] }
        -dump { set dump [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }

# A String literal of 0..~20 characters.
proc lit {} {
    set nul [format %c 0]
    set pool [list "" "a" "b" "hello" "HELLO, World" "abcdefgh" "abcdefghi" "x y" "\u00e9" "\u00c9t\u00e9" "\u2026" "a\u2026b" \
        "\u03bb" "\u732b\u732b" "\U0001f600" "a\U0001f600b\U0001f600" "e\u0301" "\u00df" "\u212a" "\u0130" "$nul" "a${nul}b" \
        "Gr\u00fc\u00dfe aus M\u00fcnchen\u2026" "\u0391\u0392\u0393" "ASCII only text" "mixed \u00e9\u2026\U0001f600 text" "\U0010ffff" "z"]
    return "\"[pick $pool]\""
}

proc intLit {} { return [pick {0 1 2 3 5 8 13}] }

set header {
fn clip(i, n):
    if i > n:
        n
    else:
        i

fn pass(s):
    s

fn twice(s):
    str::concat(s, s)

fn first_half(s):
    n = str::length(s)
    h = clip(3, n)
    str::substring(s, 0, h)

fn grow(n, acc, piece):
    if n < 1:
        acc
    else:
        grow(n - 1, str::concat(acc, piece), piece)
}

proc program {} {
    set lines [list $::header]
    set stmts {}
    set vars {}
    set k 0
    foreach i {0 1 2} { set v "v$i"; lappend stmts "    $v = [lit]"; lappend vars $v }
    set k 3
    set errorInjected 0
    set m [expr {6 + int(rand() * 10)}]
    for {set i 0} {$i < $m} {incr i} {
        set v "v$k"; incr k
        set a [pick $vars]
        set b [pick $vars]
        switch [pick {concat concat sub sub sub lower pass twice half grow lit cap}] {
            concat { lappend stmts "    $v = str::concat($a, $b)" }
            sub {
                lappend stmts "    n${k} = str::length($a)" "    a${k} = clip([intLit], n${k})" "    $v = str::substring($a, a${k}, a${k} + clip([intLit], n${k} - a${k}))"
            }
            lower { lappend stmts "    $v = str::lowercase($a)" }
            pass { lappend stmts "    $v = pass($a)" }
            twice { lappend stmts "    $v = twice($a)" }
            half { lappend stmts "    $v = first_half($a)" }
            grow { lappend stmts "    $v = grow([pick {0 1 2 3 7}], $a, $b)" }
            lit { lappend stmts "    $v = [lit]" }
            cap {
                lappend stmts "    fn add${k}(x):\n        str::concat($a, x)" "    $v = add${k}($b)"
            }
        }
        lappend vars $v
    }
    # an out-of-range substring now and then: the error must agree exactly
    if {rand() < 0.1} {
        set a [pick $vars]
        lappend stmts "    bad = str::substring($a, str::length($a) + 1, str::length($a) + 2)"
    }
    set last [lindex $vars end]
    set shown [lrange $vars [expr {[llength $vars] > 6 ? [llength $vars] - 6 : 0}] end]
    set lens [lmap v $shown {string cat "str::length($v)"}]
    set e1 [pick $vars]
    set e2 [pick $vars]
    set eqs [list "$e1 == $e2" "hash([pick $vars]) == hash([pick $vars])"]
    lappend stmts "    xs = list::append(list::append(\[\], [pick $vars]), [pick $vars])"
    lappend stmts "    m = mutable_array::allocate(2)" "    mutable_array::set(m, 0, [pick $vars])" "    mutable_array::set(m, 1, [pick $vars])"
    lappend stmts "    p = Pair {left: [pick $vars], right: [pick $vars]}"
    lappend lines "struct Pair:\n    left: str\n    right: str\n"
    lappend lines "fn run(unused):\n[join $stmts \n]\n    \[\[[join $shown {, }]\], \[[join $lens {, }]\], \[[join $eqs {, }]\], xs, mutable_array::at(m, 0), mutable_array::at(m, 1), p.left, p.right\]\n"
    lappend lines "run(0)\n"
    return [join $lines \n]
}

proc outcome {kind hir args} {
    if {[catch {
        switch $kind {
            interp  { core::useBackend interp;  set r [core::evalProgram [hir::lower $hir]] }
            compile { core::useBackend compile; set r [core::evalProgram [hir::lower $hir]] }
            native  { set r [native::evalHir $hir {*}$args] }
        }
    } msg opts]} {
        return [list error [dict get $opts -errorcode] $msg]
    }
    return [list value [core::value::show $r 1]]
}

set bad 0
set rejected 0
set kinds [dict create]
# Program files live in a fresh system temporary directory, removed when the
# run ends (never in the working directory, which concurrent runs share).
set scratch [file tempdir string-allocation-fuzz]
for {set s $seed0} {$s < $seed0 + $n} {incr s} {
    expr {srand($s)}
    set text [program]
    if {$dump} { puts "--- seed $s\n$text"; flush stdout }
    set path [file join $scratch p$s.bot]
    set ch [open $path w]; fconfigure $ch -encoding utf-8; puts $ch [surface::modules::ImportHeader $text]$text; close $ch
    if {[catch {set hir [surface::readProgramFile $path]} err]} {
        file delete $path
        incr rejected
        if {$dump} { puts "rejected: $err" }
        continue
    }
    file delete $path
    set outcomes [list [outcome interp $hir] [outcome compile $hir]]
    set prepared [native::prepareHir $hir]
    foreach opt {0 1} {
        foreach pack {0 1} {
            foreach inline {0 1} {
                foreach demand {0 1} {
                    if {!$opt && ($pack || $demand)} continue
                    lappend outcomes [outcome native $prepared -short-string-opt $opt -ascii-pack-opt $pack -tiny-leaf-inline-opt $inline -short-demand-opt $demand]
                }
            }
        }
    }
    if {$generic} {
        lappend outcomes [outcome native $prepared -specialize 0]
    }
    dict incr kinds [lindex [lindex $outcomes 0] 0]
    set norm [lmap o $outcomes {lrange $o 0 1}]
    set msgs [lsort -unique [lmap o $outcomes {expr {[lindex $o 0] eq "error" ? [lindex $o 2] : ""}}]]
    if {[llength [lsort -unique $norm]] != 1 || [llength $msgs] > 1} {
        incr bad
        puts "DISAGREEMENT seed $s:\n$text\n[join $outcomes \n]"
    }
}
file delete -force $scratch
puts "programs [expr {$n - $rejected}] of $n (rejected statically $rejected; outcomes: $kinds); disagreements $bad"
exit [expr {$bad ? 1 : 0}]

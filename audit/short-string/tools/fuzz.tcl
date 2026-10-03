#!/usr/bin/env tclsh9.0
# fuzz.tcl -- bounded randomized differential check of the tiered short-String
# regime (SHORT-STRING.md). Generates small programs over Strings of at most
# one character (Empty, ASCII, Latin-1, BMP, astral, NUL) and over ASCII
# Strings of 2..8 characters (NUL and DEL inside, the 8/9-character boundary,
# a non-ASCII multi-character negative control); branches, aliases, exact
# calls with String parameters and results, self-tail and non-tail recursion,
# substring slices, an error-capable helper with a handler, closures, tagged
# storage and general String operations; and compares the reference
# interpreter, the Tcl compile backend and native with the short-String
# switch off/on, the packed-ASCII tier off/on, the demand rule off/on and leaf inlining off/on, for
# values, errors and completion behavior. Any disagreement is printed with its program. The
# generator is bounded: recursion measures are small literals and nothing
# multiplies, so every program finishes quickly.
#
#   tclsh9.0 audit/short-string/tools/fuzz.tcl ?-n N? ?-seed S? ?-generic 1?
#
# Run it under BOTLISH_NATIVE_GC_STRESS=1 for the GC-stress variant.
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

# One-character (and Empty) literals: Empty, ASCII, Latin-1, BMP, astral, NUL.
proc strLit {} {
    set nul [format %c 0]
    set choices [list "\"\"" "\"a\"" "\"b\"" "\"z\"" "\"\u00e9\"" "\"\u03bb\"" "\"\u732b\"" "\"\U0001f600\"" "\"$nul\"" "\"\"" "\"a\""]
    return [pick $choices]
}

# A multi-character literal: ASCII of 2..8 characters (packed ASCII), the
# 9-character boundary and a non-ASCII pair (both stay tagged).
proc maybeLong {} {
    set nul [format %c 0]
    set del [format %c 0x7f]
    return [pick [list "\"ab\"" "\"hello\"" "\"12345678\"" "\"a${nul}b\"" "\"${del}z\"" "\"yes\"" "\"no\"" "\"abcdefg\"" \
        "\"123456789\"" "\"\u03bb\u03bb\"" "\"\U0001f600!\"" "\"ab\"" "\"hello\""]]
}

proc intLit {} { return [pick {0 1 2 3 4}] }

proc cond {ivars} {
    set v [pick $ivars]
    return [pick [list "$v < [intLit]" "$v == [intLit]" "$v > [intLit]" "$v <= [intLit]"]]
}

# An atom of String type: a literal, a String variable, or a call of an
# earlier function that returns a String.
proc atom {svars ivars callable} {
    set r rand()
    set x [expr {rand()}]
    if {$svars ne "" && $x < 0.35} { return [pick $svars] }
    if {$callable ne "" && $x < 0.65} {
        set f [pick $callable]
        lassign [split $f :] name kind
        set args {}
        foreach k [split $kind ""] {
            lappend args [expr {$k eq "s" ? [expr {$svars ne "" && rand() < 0.6 ? [pick $svars] : [strLit]}] : [pick [concat $ivars [list [intLit]]]]}]
        }
        return "${name}([join $args {, }])"
    }
    if {$x < 0.72 && $ivars ne ""} {
        return "str::substring($::TEXT, [pick $ivars], [pick $ivars] + 1)"
    }
    if {$x < 0.86} { return [maybeLong] }
    return [strLit]
}

# Emits statements binding fresh String variables; returns {lines svars}.
proc statements {svars ivars callable indent} {
    set lines {}
    set k [expr {1 + int(rand() * 3)}]
    for {set i 0} {$i < $k} {incr i} {
        set name v[incr ::counter]
        if {rand() < 0.45} {
            lappend lines "${indent}$name = if [cond $ivars]:" "${indent}    [atom $svars $ivars $callable]" "${indent}else:" "${indent}    [atom $svars $ivars $callable]"
        } else {
            lappend lines "${indent}$name = [atom $svars $ivars $callable]"
        }
        lappend svars $name
    }
    return [list $lines $svars]
}

proc finalExpr {svars ivars callable indent} {
    if {rand() < 0.5} {
        return [list "${indent}if [cond $ivars]:" "${indent}    [atom $svars $ivars $callable]" "${indent}else:" "${indent}    [atom $svars $ivars $callable]"]
    }
    return [list "${indent}[atom $svars $ivars $callable]"]
}

proc program {} {
    set ::counter 0
    set ::TEXT "\"a\u03bb\u732b\U0001f600z\""
    set lines {}
    set extra {}
    # peek, once: the corpus idiom
    if {rand() < 0.5} {
        lappend lines "fn peek(text, index):\n    if index >= str::length(text):\n        return \"\"\n\n    str::substring(text, index, index + 1)\n"
        set peekable 1
    } else {
        set peekable 0
    }
    set callable {}        ;# name:kind (s = String parameter, i = Int parameter), String-returning
    if {rand() < 0.6} {
        # an error-capable helper whose success value is a short String, and a
        # caller with a handler: Empty must stay a value, failure the status
        set lines [linsert $lines 0 "error Bad\n"]
        lappend lines "fn guarded(n, s) -> str errors Bad:\n    if n > 3:\n        fail Bad\n    else:\n        [atom {s} {n} {}]\n"
        lappend lines "fn run(n, s):\n    r = guarded(n, s):\n        on Bad:\n            [strLit]\n    r\n"
        lappend callable "run:is"
    }
    if {rand() < 0.4} {
        # a closure capturing a short local (the environment is tagged)
        lappend lines "fn cap(n, s):\n    v = [atom {s} {n} {}]\n    fn add(x):\n        str::concat(v, x)\n    add(\"!\")\n"
        lappend extra "cap:is"
    }
    set nfun [expr {2 + int(rand() * 4)}]
    for {set i 1} {$i <= $nfun} {incr i} {
        set kind [pick {s si is i ss ii si}]
        set vars {}
        set svars {}
        set ivars {}
        set pn 0
        foreach k [split $kind ""] {
            set p [expr {$k eq "s" ? "s[incr pn]" : "n[incr pn]"}]
            lappend vars $p
            if {$k eq "s"} { lappend svars $p } else { lappend ivars $p }
        }
        if {$ivars eq ""} { lappend vars m ; lappend ivars m; append kind i }
        set style [pick {plain plain branchy recursive tail}]
        set body {}
        lassign [statements $svars $ivars $callable "    "] stmts allS
        lappend body {*}$stmts
        switch $style {
            recursive {
                set measure [lindex $ivars 0]
                set recArgs [lmap k [split $kind ""] v $vars {
                    if {$v eq $measure} { expr {"$v - 1"} } elseif {$k eq "s"} { atom $allS $ivars $callable } else { set v }
                }]
                set last [atom $allS $ivars $callable]
                set body [list "    if $measure < 1:" "        $last" "    else:" "        f${i}([join $recArgs {, }])"]
                set body [concat $stmts $body]
            }
            tail {
                set measure [lindex $ivars 0]
                set recArgs [lmap k [split $kind ""] v $vars {
                    if {$v eq $measure} { expr {"$v - 1"} } elseif {$k eq "s"} { atom $allS $ivars $callable } else { set v }
                }]
                set body [concat $stmts [list "    if $measure < 1:" "        return [atom $allS $ivars $callable]" "" "    f${i}([join $recArgs {, }])"]]
            }
            default {
                lappend body {*}[finalExpr $allS $ivars $callable "    "]
            }
        }
        lappend lines "fn f${i}([join $vars {, }]):\n[join $body \n]\n"
        lappend callable "f$i:$kind"
    }
    # consumers of String results
    set cons {}
    foreach f [concat $callable $extra] {
        lassign [split $f :] name kind
        set args {}
        foreach k [split $kind ""] { lappend args [expr {$k eq "s" ? [strLit] : [intLit]}] }
        set call "${name}([join $args {, }])"
        lappend cons "str::length($call)" "$call == [strLit]" "$call == \"\"" "list::append(\[\], $call)" "str::concat($call, \"!\")" "hash($call) == hash($call)"
    }
    set picks {}
    set m [expr {3 + int(rand() * 6)}]
    for {set i 0} {$i < $m} {incr i} { lappend picks [pick $cons] }
    return "[join $lines \n]\n\[[join $picks {, }]\]\n"
}

proc outcome {kind hir args} {
    if {[catch {
        switch $kind {
            interp  { core::useBackend interp;  set r [core::evalProgram [hir::lower $hir]] }
            compile { core::useBackend compile; set r [core::evalProgram [hir::lower $hir]] }
            native  { set r [native::evalHir $hir {*}$args] }
        }
    } msg opts]} {
        set code [dict get $opts -errorcode]
        # the message is part of the observable error: RANGE texts must agree
        return [list error $code $msg]
    }
    return [list value [core::value::show $r 1]]
}

set bad 0
set rejected 0
set kinds [dict create]
for {set s $seed0} {$s < $seed0 + $n} {incr s} {
    expr {srand($s)}
    set text [program]
    if {$dump} { puts "--- seed $s\n$text"; flush stdout }
    set dir [file join [pwd] .fuzz-short-string]
    file mkdir $dir
    set path [file join $dir p$s.bot]
    set ch [open $path w]; fconfigure $ch -encoding utf-8; puts $ch $text; close $ch
    if {[catch {set hir [surface::readProgramFile $path]} err]} {
        file delete $path
        incr rejected
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
    set nir [native::nir $prepared -short-string-opt 1 -tiny-leaf-inline-opt 0]
    if {[regexp {shortparams=|shortresult=1|asciiparams=|asciiresult=1} $nir]} { dict incr kinds uses-scalar-abi }
    if {[regexp {asciiparams=|asciiresult=1} $nir]} { dict incr kinds ascii-abi }
    if {[regexp {shortparams=|shortresult=1} $nir]} { dict incr kinds short-abi }
    if {[regexp {asciiresult=1} $nir]} { dict incr kinds ascii-result }
    if {[regexp {asciiparams=} $nir]} { dict incr kinds ascii-param }
    if {[regexp {op asciitostr|op shorttostr} $nir]} { dict incr kinds materializes }
    if {[regexp {op strtoshort|op strtoascii} $nir]} { dict incr kinds extracts }
    if {[regexp {op strsliceshort} $nir]} { dict incr kinds slices }
    if {[regexp {op shorteq|op asciieq} $nir]} { dict incr kinds scalar-equality }
    if {[regexp {op asciilen|op shortlen} $nir]} { dict incr kinds scalar-length }
    if {[regexp {op asciitoshort|op asciishorteq} $nir]} { dict incr kinds tier-mix }
    set norm [lmap o $outcomes {lrange $o 0 1}]
    # error messages must also agree among the backends that produce them
    set msgs [lsort -unique [lmap o $outcomes {expr {[lindex $o 0] eq "error" ? [lindex $o 2] : ""}}]]
    if {[llength [lsort -unique $norm]] != 1 || [llength $msgs] > 1} {
        incr bad
        puts "DISAGREEMENT seed $s:\n$text\n[join $outcomes \n]"
    }
}
file delete -force [file join [pwd] .fuzz-short-string]
puts "programs [expr {$n - $rejected}] of $n (rejected statically $rejected; outcomes/features: $kinds); disagreements $bad"
exit [expr {$bad ? 1 : 0}]

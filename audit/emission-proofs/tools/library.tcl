# library.tcl -- the independent-library demonstration
# (MODULAR-EMISSION-PROOFS-MILESTONE-1.md, section 5): the library
# audit/emission-proofs/lib/emitlib.bot checked from five unrelated entry
# programs (audit/emission-proofs/callers/), by the modular checker and by
# the exploratory one; one certificate store reused across the five
# compilations; and the store's invalidation by the changes that must
# invalidate it and by those that must not.
#
#   tclsh9.0 audit/emission-proofs/tools/library.tcl ?-out FILE?
#
# Exits 1 when the modular verdicts of the library's claims differ between
# two callers, or an invalidation experiment does not behave as stated.

set here [file dirname [file normalize [info script]]]
set options [dict merge {-out ""} $argv]
set argv {}
source [file join $here concrete.tcl]
source [file join $here workspace.tcl]
source [file join $here modcheck.tcl]
source [file join [file dirname [file dirname $here]] emitter tools emitcheck.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

set callers {safe full invalid compose unused}
set failures 0

proc readText {path} {
    set f [open $path]
    fconfigure $f -encoding utf-8
    set t [read $f]
    close $f
    return $t
}

proc writeText {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

proc workspace {} {
    global here callers
    set dir [epws::scratch]
    foreach c $callers {
        file copy -force [file join [file dirname $here] callers $c.bot] [file join $dir $c.bot]
    }
    return $dir
}

# The library's claims: name/recognizer -> verdict, from modcheck RESULT.
proc libraryVerdicts {result} {
    set out [dict create]
    foreach c [dict get $result claims] {
        if {![string match emitlib::* [dict get $c name]]} continue
        dict set out "[dict get $c name] [namespace tail [dict get $c recognizer]]" [dict get $c verdict]
    }
    return $out
}

# The library's claims, from its directives: {emitlib::FN RECOGNIZER}...
proc EmitlibClaims {} {
    global here
    set out {}
    foreach d [modcheck::Directives [file join [file dirname $here] lib emitlib.bot]] {
        lassign $d line fn r
        lappend out [list emitlib::$fn [namespace tail $r]]
    }
    return $out
}

proc modular {path args} {
    set t0 [clock milliseconds]
    set r [modcheck::check $path {*}$args]
    return [list $r [expr {[clock milliseconds] - $t0}]]
}

# The exploratory checker's verdict per library claim: proved, or the kinds
# it reported.
proc original {path} {
    set t0 [clock milliseconds]
    set r [emitcheck::check $path]
    set ms [expr {[clock milliseconds] - $t0}]
    set out [dict create]
    # (The exploratory checker names a claim by its directive's function,
    # unqualified, and its location.)
    set lib [dict create]
    foreach e [dict get $r emitters] {
        if {[string match *emitlib.bot* [dict get $e location]]} {
            set claim "emitlib::[dict get $e name] [namespace tail [dict get $e recognizer]]"
            dict set out $claim proved
            dict set lib [dict get $e name] $claim
        }
    }
    foreach d [dict get $r diagnostics] {
        # Which claim: the related "checking ..." note, or the location.
        set claim ""
        foreach rel [dict get $d related] {
            if {[regexp {^checking (\S+)'s claim to emit (\S+)$} [lindex $rel 0] -> fn rec]
                    && [string match *emitlib.bot* [lindex $rel 1]]} {
                set claim "emitlib::$fn [namespace tail $rec]"
            }
        }
        if {$claim eq "" && [dict get $d kind] eq "EMIT-UNUSED" && [string match *emitlib.bot* [dict get $d location]]} {
            regexp {^(\S+) is not called} [dict get $d message] -> fn
            set claim "emitlib::$fn ?"
            foreach k [EmitlibClaims] {
                if {[lindex $k 0] eq "emitlib::$fn"} { set claim $k }
            }
        }
        if {$claim eq "" || ![string match emitlib::* $claim]} continue
        set old [dict getdef $out $claim ""]
        if {$old eq "proved"} { set old "" }
        dict set out $claim [string trim "$old [dict get $d kind]"]
    }
    return [list $out $ms]
}

set report {}
proc out {line} {
    global report
    lappend report $line
}

# ---------------------------------------------------------------------------
# A. Each caller alone, no store

set dir [workspace]
set verdicts [dict create]
set observed [dict create]
set originals [dict create]
set times [dict create]
foreach c $callers {
    lassign [modular [file join $dir $c.bot]] r -
    dict set verdicts $c [libraryVerdicts $r]
    lassign [modular [file join $dir $c.bot] -witness 0] r0 ms
    dict set times $c [list $ms [dict get $r0 stats frontEndMs] [dict get $r0 stats checkMs]]
    lassign [modular [file join $dir $c.bot] -witness 0 -facts observed] ro -
    dict set observed $c [libraryVerdicts $ro]
    lassign [original [file join $dir $c.bot]] o oms
    dict set originals $c $o
    dict lappend times $c $oms
    if {$c eq "compose"} {
        set composeClaims [lmap x [dict get $r claims] {
            if {[string match emitlib::* [dict get $x name]] || [string match number_emit::* [dict get $x name]]} continue
            list [dict get $x name] [dict get $x verdict]
        }]
    }
}
set claimNames [lsort [dict keys [dict get $verdicts safe]]]
out "## A. The library's claims, checked from each caller alone"
out ""
out "Modular checker (definition level, no certificate store):"
out ""
out "| claim | [join $callers { | }] |"
out "|---|[string repeat ---| [llength $callers]]"
foreach k $claimNames {
    set row "| `[lindex $k 0]` [lindex $k 1] |"
    foreach c $callers {
        append row " [dict getdef [dict get $verdicts $c] $k -] |"
    }
    out $row
}
set stable 1
foreach c [lrange $callers 1 end] {
    if {[dict get $verdicts $c] ne [dict get $verdicts safe]} {
        set stable 0
    }
}
if {!$stable} {
    incr failures
    out ""
    out "**FAILURE: the modular verdicts differ between callers.**"
}
out ""
out "The same checker with observed facts (`-facts observed`: each claim entered with what the program's own calls pass -- the exploratory model, for comparison):"
out ""
out "| claim | [join $callers { | }] |"
out "|---|[string repeat ---| [llength $callers]]"
foreach k $claimNames {
    set row "| `[lindex $k 0]` [lindex $k 1] |"
    foreach c $callers {
        append row " [dict getdef [dict get $observed $c] $k -] |"
    }
    out $row
}
out ""
out "Exploratory checker (EMITTER-COROUTINE-EXPLORATION.md: facts of the program's own calls):"
out ""
out "| claim | [join $callers { | }] |"
out "|---|[string repeat ---| [llength $callers]]"
foreach k $claimNames {
    set row "| `[lindex $k 0]` [lindex $k 1] |"
    foreach c $callers {
        append row " [dict getdef [dict get $originals $c] $k {not reported}] |"
    }
    out $row
}
out ""
out "compose.bot's own claims (through the library's certificates): [join [lmap x $composeClaims {string cat [lindex $x 0] ": " [lindex $x 1]}] {, }]"
out ""
out "Time per caller (ms): modular total / its front end / its check (no counterexample search); exploratory total:"
out ""
out "| caller | modular | front end | check | exploratory |"
out "|---|---:|---:|---:|---:|"
foreach c $callers {
    lassign [dict get $times $c] ms fe ck oms
    out "| $c | $ms | $fe | $ck | $oms |"
}

# ---------------------------------------------------------------------------
# B. One store across the five compilations

set store [file join $dir certs.store]
out ""
out "## B. One certificate store across the five compilations"
out ""
out "| caller | proved | reused | check ms |"
out "|---|---:|---:|---:|"
foreach c $callers {
    lassign [modular [file join $dir $c.bot] -store $store -witness 0] r ms
    set proved 0
    set reused 0
    foreach x [dict get $r claims] {
        if {[dict get $x verdict] ne "proven"} continue
        if {[dict exists $x reused]} { incr reused } else { incr proved }
    }
    out "| $c | $proved | $reused | [dict get $r stats checkMs] |"
}

# ---------------------------------------------------------------------------
# C. Invalidation

# The library claims' {verdict how} after changing FILE's OLD to NEW in
# the workspace (and back afterwards), checked from ENTRY with the store.
proc experiment {dir store entry file old new} {
    set saved [readText $store]
    if {$file ne ""} {
        set path [file join $dir $file]
        set text [readText $path]
        if {[string first $old $text] < 0} {
            error "experiment: no `$old` in $file"
        }
        writeText $path [string map [list $old $new] $text]
    }
    set r [modcheck::check [file join $dir $entry] -store $store -witness 0]
    if {$file ne ""} {
        writeText $path $text
    }
    writeText $store $saved
    set out [dict create]
    set ::lastCheckMs [dict get $r stats checkMs]
    foreach x [dict get $r claims] {
        set how proved
        if {[dict exists $x reused]} { set how reused }
        if {[dict exists $x invalidated]} { set how "proved again ([dict get $x invalidated])" }
        dict set out "[dict get $x name] [namespace tail [dict get $x recognizer]]" [list [dict get $x verdict] $how]
    }
    return $out
}

set experiments {
    comment "a comment changed in emitlib.bot" emitlib.bot
        "# The lowercase hexadecimal digit of N" "# The lowercase hex digit of N"
        {}
    caller "a new, unrelated caller program" ""
        "" ""
        {}
    policy "json_string's policy: '/' escaped as \\/" emitlib.bot
        "    elif c < 32:\n        unicode_escape(c)" "    elif c == 47:\n        short_escape(c)\n    elif c < 32:\n        unicode_escape(c)"
        {{emitlib::json_string json_string_strict}}
    helper "a helper's code: hex_digit's letters uppercase" emitlib.bot
        "        yield 87 + n" "        yield 55 + n"
        {{emitlib::json_string json_string_strict}}
    grammar "the recognizer: json_lex's escapes lose `\\/`" json_lex.bot
        "'\"' '\\\\' '/' 'b' 'f' 'n' 'r' 't' -> accept" "'\"' '\\\\' 'b' 'f' 'n' 'r' 't' -> accept"
        {{emitlib::json_string json_string_strict} {emitlib::json_string_source json_string_strict} {emitlib::member json_text}}
    number "number_emit's helper: magnitude's loop written another way" number_emit.bot
        "        if top * 10 > m:" "        if m < top * 10:"
        {{number_emit::integer json_number}}
}
out ""
out "## C. Invalidation (store of B, checked from unused.bot)"
out ""
out "| change | re-proved | reused | not proven | check ms |"
out "|---|---|---:|---|---:|"
writeText [file join $dir newcaller.bot] "import emitlib\nimport std::coroutine\n\nfn src() -> int errors emitlib::NotADigit:\n    emitlib::digit_checked(7)\n    -1\n\nfn run() -> int errors emitlib::NotADigit:\n    coroutine {step, first} = src()\n    first\n\nrun():\n    on emitlib::NotADigit:\n        -3\n"
foreach {name what file old new expect} $experiments {
    set entry unused.bot
    if {$name eq "caller"} { set entry newcaller.bot }
    if {[catch {experiment $dir $store $entry $file $old $new} result]} {
        out "| $what | (error: $result) | | |"
        incr failures
        continue
    }
    set again {}
    set reused 0
    set bad {}
    dict for {k v} $result {
        lassign $v verdict how
        if {$verdict ne "proven"} { lappend bad "$k ($verdict)" ; continue }
        if {$how eq "reused"} { incr reused } else { lappend again "`[lindex $k 0]`" }
    }
    out "| $what | [join $again {, }] | $reused | [join $bad {, }] | $::lastCheckMs |"
    if {1} {
        set want [lsort [lmap e $expect {string cat "`[lindex $e 0]`"}]]
        if {[lsort $again] ne $want} {
            incr failures
            out "| (expected re-proved: [join $want {, }]) | | | |"
        }
    }
}

# ---------------------------------------------------------------------------
# D. Invocation level: the unguarded digit at each call site

out ""
out "## D. Invocation level: \`emitlib::digit_unchecked\` where it is called"
out ""
out "| program | caller | arguments there | verdict |"
out "|---|---|---|---|"
foreach {c caller} {safe src_unchecked invalid src_bad unused emitlib::digit_unchecked_source} {
    set r [modcheck::check [file join $dir $c.bot] -witness 0 \
        -invocation [list $caller emitlib::digit_unchecked json_grammar::digit_symbol]]
    foreach i [dict get $r invocations] {
        out "| $c.bot | `[dict get $i caller]` | [join [dict get $i arguments] {, }] | [dict get $i verdict] |"
    }
}

set text [join $report \n]
if {[dict get $options -out] ne ""} {
    writeText [dict get $options -out] "$text\n"
}
puts $text
exit [expr {$failures > 0}]

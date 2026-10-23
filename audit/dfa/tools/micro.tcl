# micro.tcl -- the cost of one symbol in a recognizer alone
# (DFA-COROUTINE-EXPLORATION.md, section 12): a loop that resumes one
# recognizer N times with the same symbol, fused. Instructions: callgrind's
# count of the run at two sizes, whose difference is the symbols' cost
# alone. Time: at the larger size, the best of five native runs in each of
# five driver processes. It compares a declared recognizer with the same
# recognizer written by hand (by_hand.bot) and shows a unicode one beside
# them; then the front end's compile time of each module.
#
#   tclsh9.0 audit/dfa/tools/micro.tcl ?-out FILE?
#
# Needs valgrind and the release native backend.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set out ""
foreach {option value} $argv {
    switch -- $option {
        -out { set out $value }
        default { error "unknown option $option" }
    }
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root audit dfa tests support.tcl]

# Callgrind's instruction count of one native run of HIR.
proc instructions {hir} {
    lassign [file tempfile path micro.nir] ch
    puts -nonewline $ch [native::nir $hir]
    close $ch
    # Only the program's execution: inside the driver's execute, not inside
    # the compile it calls or the compiled program's release at its end
    # (whose counts vary from process to process with the heap's state).
    catch {exec valgrind --tool=callgrind --callgrind-out-file=/dev/null \
        --collect-atstart=no --toggle-collect=botlish_native::execute \
        "--toggle-collect=<botlish_native::codegen::CraneliftJit as botlish_native::codegen::Backend>::compile" \
        "--toggle-collect=core::ptr::drop_glue::<botlish_native::codegen::CompiledProgram>" \
        [native::binary] run $path 2>@1} out
    file delete $path
    if {![regexp {Collected : ([0-9]+)} $out -> count]} {
        error "callgrind reported no count:\n$out"
    }
    return $count
}

# A program that starts MODULE::RECOGNIZER with FIRST, resumes it N times
# with SYMBOL, then with the end of the input: 1 if it accepted, 0 if it is
# still running, -1 or -2 for its errors.
proc program {module recognizer first symbol n} {
    return "import dfa\nimport $module\nimport std::coroutine\n
fn run(n: int) -> int errors dfa::UnrecognizedInput, dfa::UnexpectedEnd:
    coroutine {step} = $module\::$recognizer\($first)
    loop i from 1 to n:
        step(dfa::Symbol {code: $symbol})
    step(dfa::Symbol {code: -1})
    if std::coroutine::done?(step):
        return 1
    0

run($n):
    on dfa::UnrecognizedInput:
        -1
    on dfa::UnexpectedEnd:
        -2
"
}

set sizes {2000 20000}
set lines {}
lappend lines "| recognizer | symbols | instructions per symbol | ns per symbol (min / median / max) | result | fused: yields, template |"
lappend lines "|---|---|---:|---:|---:|---|"
foreach {label module recognizer first symbol what} {
    json_number json_lex json_number 49 49 "declared: `1` then digits"
    number_by_hand by_hand number_by_hand 49 49 "by hand: the same"
    json_string json_lex json_string 34 97 "declared (unicode): `\"` then `a`s"
} {
    set counts {}
    set times {}
    set values {}
    set fusion ""
    foreach n $sizes {
        set dir [dfatest::workspaceOf $dfatest::json {dfa.bot json_lex.bot by_hand.bot} \
            main.bot [program $module $recognizer $first $symbol $n]]
        set hir [surface::readProgramFile $dir/main.bot -warnings off]
        file delete -force $dir
        if {$fusion eq ""} {
            # The recognizer's site: its suspension points once fusion has
            # inlined its helpers, and its template's NIR instructions.
            foreach line [native::fusion $hir] {
                if {[regexp {^fused .* yields ([0-9]+) .* template ([0-9]+) } $line -> yields template]} {
                    set fusion "$yields, $template"
                }
            }
        }
        lappend counts [instructions $hir]
        # The median over 5 driver processes of each one's best of 5 runs:
        # a tight loop's time depends on where its machine code lands, which
        # differs from process to process (by up to two times here).
        set bests {}
        foreach round {1 2 3 4 5} {
            lassign [native::measure $hir 5] - - best - value
            lappend bests $best
        }
        set bests [lsort -real $bests]
        lappend times [list [expr {[lindex $bests 0] * 1000.0 / $n}] [expr {[lindex $bests 2] * 1000.0 / $n}] [expr {[lindex $bests end] * 1000.0 / $n}]]
        lappend values $value
    }
    set span [expr {[lindex $sizes 1] - [lindex $sizes 0]}]
    lassign [lindex $times 1] min med max
    lappend lines [format "| `%s` | %s | %.1f | %.2f / %.2f / %.2f | %s | %s |" $label $what \
        [expr {double([lindex $counts 1] - [lindex $counts 0]) / $span}] \
        $min $med $max [lindex $values 1] $fusion]
}

# The front end's cost of a recognizer: a program that imports a module and
# runs one recognizer of it, compiled from source, for the
# hand-written json_number, the declared one generated alone (json_lex.dfa's
# classes and json_number) and the whole generated json_lex.
set dfaText [dfa::ReadText [file join $dfatest::json json_lex.dfa]]
set numberOnly [string range $dfaText 0 [expr {[string first "\ndfa json_literal " $dfaText] - 1}]]
set gen [file tempdir dfa-micro]
dfa::WriteText [file join $gen number_only.dfa] $numberOnly
set numberOnlyBot [dict get [dfa::compileFile [file join $gen number_only.dfa]] bot]
file delete -force $gen
lappend lines "" "| module | lines | front end ms (min / median / max) |" "|---|---:|---:|"
set modules {}
foreach {label module recognizer text} [list \
    by_hand.bot by_hand number_by_hand "" \
    "json_number alone, generated" number_only json_number $numberOnlyBot \
    json_lex.bot json_lex json_number ""] {
    set extra [list main.bot [program $module $recognizer 49 49 10]]
    if {$text ne ""} {
        lappend extra $module.bot $text
    }
    set dir [dfatest::workspaceOf $dfatest::json {dfa.bot json_lex.bot by_hand.bot} {*}$extra]
    set count [llength [split [string trimright [dfa::ReadText [file join $dir $module.bot]] \n] \n]]
    lappend modules [list $label $dir $count]
}
# One compile of each first (the front end's own procedures are compiled
# on first use), then seven rounds, the modules interleaved in each.
set ms [dict create]
foreach round {0 1 2 3 4 5 6 7} {
    foreach m $modules {
        lassign $m label dir
        set t0 [clock microseconds]
        surface::readProgramFile $dir/main.bot -warnings off
        if {$round > 0} {
            dict lappend ms $label [expr {([clock microseconds] - $t0) / 1000.0}]
        }
    }
}
foreach m $modules {
    lassign $m label dir count
    file delete -force $dir
    set sorted [lsort -real [dict get $ms $label]]
    lappend lines [format "| %s | %d | %.0f / %.0f / %.0f |" $label $count [lindex $sorted 0] [lindex $sorted 3] [lindex $sorted end]]
}

set text [join [list "# DFA prototype: one recognizer alone" "" \
    "Generated by audit/dfa/tools/micro.tcl on [exec uname -m]." \
    "Instructions: callgrind's count of the run (not the compile) at [lindex $sizes 1] symbols minus at [lindex $sizes 0], per symbol." \
    "Time: each of 5 driver processes' best of 5 native runs at [lindex $sizes 1] symbols, per symbol (the start and the loop included)." \
    "Result: 1 accepted at the end, -2 UnexpectedEnd (a string has no closing quote)." \
    "" {*}$lines] \n]
puts $text
if {$out ne ""} {
    dfa::WriteText $out "$text\n"
}

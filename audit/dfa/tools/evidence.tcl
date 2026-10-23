# evidence.tcl -- the native evidence of declared recognizers
# (DFA-COROUTINE-MILESTONE-2.md, "Native code evidence"; first written for
# the exploration's prototype, whose evidence audit/dfa/evidence/ keeps), the
# way audit/coroutine-fusion/tools/evidence.tcl gathers the fusion
# milestone's.
#
#   tclsh9.0 audit/dfa/tools/evidence.tcl ?-out DIR?
#
# For each workload (a program over examples/dfa's modules), writes to DIR
# (default audit/dfa/milestone-2/evidence/):
#
#   NAME.report.txt    the driver's fusion report (botlish-native fusion)
#   NAME.general.nir   the NIR native lowering writes (what the general
#                      runtime runs: fusion off)
#   NAME.fused.nir     the NIR after fusion: what the driver compiles
#   NAME.fused.s       the machine code of the consumer function, fused
#   NAME.general.s     the same function, unfused
#
# and summary.md: per workload and variant, the consumer's machine code
# bytes, call instructions and the coroutine helpers they call. Needs
# objdump. Deterministic for a given compiler, native backend and objdump.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set out [file join $root audit dfa milestone-2 evidence]
foreach {option value} $argv {
    switch -- $option {
        -out { set out $value }
        default { error "unknown option $option" }
    }
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
file mkdir $out

proc readText {path} {
    set f [open $path]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    return $text
}

proc writeText {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# A private directory holding examples/dfa's modules and main.bot (TEXT).
proc workspace {text} {
    set dir [file tempdir botlish-dfa-evidence]
    foreach sub {json yaml} {
        foreach path [glob -directory [file join $::root examples dfa $sub] *.bot] {
            file copy $path [file join $dir [file tail $path]]
        }
    }
    writeText [file join $dir main.bot] $text
    return $dir
}

proc functionNumber {text name} {
    if {![regexp -line "^func (\[0-9\]+) \"[string map {? \\? : \\:} $name]\"" $text -> n]} {
        error "no function $name"
    }
    return $n
}

proc disassemble {text n fused} {
    lassign [file tempfile nirPath botlish-evidence.nir] channel
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
    set object [file join [file dirname $nirPath] botlish-dfa-evidence-[pid].o]
    try {
        if {$fused} {
            exec [native::binary] object $object $nirPath
        } else {
            withoutCoroutineFusion {exec [native::binary] object $object $nirPath}
        }
        set dump [exec objdump -d -r --no-show-raw-insn $object]
    } finally {
        file delete $nirPath $object
    }
    set start [string first "<botlish_fn_$n>:" $dump]
    set end [string first "\n\n" $dump $start]
    return [string range $dump $start [expr {$end < 0 ? "end" : $end - 1}]]\n
}

proc census {asm} {
    set lines [split [string trim $asm] \n]
    set addresses {}
    foreach line $lines {
        if {[regexp {^\s*([0-9a-f]+):\s} $line -> address]} {
            lappend addresses [scan $address %x]
        }
    }
    set bytes [expr {[llength $addresses] ? [lindex $addresses end] - [lindex $addresses 0] : 0}]
    set calls 0
    set coroutine {}
    set helpers {}
    foreach line $lines {
        if {[regexp {\scall\s} $line]} {
            incr calls
        }
        if {[regexp {R_X86_64_\S+\s+(rt_co_[a-z0-9_]+)} $line -> helper]} {
            lappend coroutine $helper
        } elseif {[regexp {R_X86_64_PLT32\s+(rt_[a-z0-9_]+)} $line -> helper]} {
            lappend helpers $helper
        }
    }
    return [list $bytes $calls [lsort $coroutine] [lsort -unique $helpers]]
}

set utf8 {import std::dfa
import json_lex
import std::coroutine

fn pattern(i: int) -> int:
    k = i.mod(10)
    if k == 0:
        return 97
    elif k == 1:
        return 195
    elif k == 2:
        return 169
    elif k == 3:
        return 226
    elif k == 4:
        return 130
    elif k == 5:
        return 172
    elif k == 6:
        return 240
    elif k == 7:
        return 159
    elif k == 8:
        return 152
    128

fn validate_pattern(n: int) -> int errors std::dfa::UnrecognizedInput, std::dfa::UnexpectedEnd:
    coroutine {step} = json_lex::utf8_text(pattern(0))
    loop i from 1 to n:
        step(std::dfa::Symbol {code: pattern(i)})
    step(std::dfa::Symbol {code: -1})
    if std::coroutine::done?(step):
        return 1
    0

validate_pattern(1000):
    on std::dfa::UnrecognizedInput:
        -1
    on std::dfa::UnexpectedEnd:
        -2
}

set lex {import json

json::lex_text(["{\"a\": [1, -2.5e3, true, null, \"x\\u0041\"]}"], 1000):
    on IndexNotFound:
        json::Summary {tokens: -1, symbols: 0}
    on json::Lexical:
        json::Summary {tokens: -2, symbols: 0}
    on json::Truncated:
        json::Summary {tokens: -3, symbols: 0}
    on json::TokenTooLong:
        json::Summary {tokens: -4, symbols: 0}
}

set validate {import json

json::validate_bytes([[123, 34, 97, 34, 58, 91, 49, 44, 116, 114, 117, 101, 93, 125]], 64, 1000):
    on json::Lexical:
        json::Summary {tokens: -2, symbols: 0}
    on json::Truncated:
        json::Summary {tokens: -3, symbols: 0}
    on json::Structure:
        json::Summary {tokens: -4, symbols: 0}
    on json::TooDeep:
        json::Summary {tokens: -5, symbols: 0}
    on json::TokenTooLong:
        json::Summary {tokens: -6, symbols: 0}
}

set yaml {import yaml

yaml::tokens(["{a:b, c: d, 'k': [x::y, \"q\"]}"], 1000):
    on IndexNotFound:
        []
    on yaml::Lexical:
        []
    on yaml::Truncated:
        []
    on yaml::TokenTooLong:
        []
}

set summary "# Declared recognizers: native evidence\n\n"
append summary "Generated by audit/dfa/tools/evidence.tcl. Per workload, the consumer function's machine code\n"
append summary "(bytes, call instructions, the coroutine helpers and the other runtime helpers it calls).\n\n"
append summary "| workload | function | variant | bytes | calls | coroutine helper calls | other runtime helpers |\n|---|---|---|---:|---:|---|---|\n"
foreach {name program function} [list utf8 $utf8 validate_pattern lex $lex json::lex_text validate-bytes $validate json::validate_bytes yaml $yaml yaml::tokens] {
    set dir [workspace $program]
    try {
        set hir [surface::readProgramFile [file join $dir main.bot] -warnings off]
    } finally {
        file delete -force $dir
    }
    set general [native::nir $hir]
    writeText [file join $out $name.report.txt] [join [native::fusion $hir] \n]\n
    writeText [file join $out $name.general.nir] $general
    writeText [file join $out $name.fused.nir] [native::fusedNir $hir]\n
    set n [functionNumber $general $function]
    foreach {variant fused} {fused 1 general 0} {
        set asm [disassemble $general $n $fused]
        writeText [file join $out $name.$variant.s] $asm
        lassign [census $asm] bytes calls coroutine helpers
        append summary "| $name | `$function` | $variant | $bytes | $calls | [expr {$coroutine eq {} ? "none" : [join $coroutine {, }]}] | [expr {$helpers eq {} ? "none" : [join $helpers {, }]}] |\n"
    }
}
writeText [file join $out summary.md] $summary
puts $summary

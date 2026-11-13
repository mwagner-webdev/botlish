# evidence.tcl -- the observations of STDLIB-ENCODE-UTF8-RESULT-TYPE-
# STABILITY-MILESTONE-1.md, section B, for one checkout.
#
#   tclsh9.0 audit/encode-utf8-type-stability/tools/evidence.tcl ?-root DIR?
#
# Analyzes programs/repro.bot and programs/repro-byte.bot (the same program
# with an `import std::byte` nothing names) with the compiler of checkout
# DIR (default: this one) through the compiler service, and prints, for
# each: what a hover shows at `bs` (the result of s.encode_utf8()), at `x`
# (an indexed element), at the loop variable `b` and at the call itself;
# then every diagnostic (line:column and its summary, which states the
# argument's facts). Then it runs the census's probes c4 and c5 (the
# 256-entry table) on the four backends with DIR's main.tcl and prints each
# outcome. The programs are this checkout's, whatever DIR is, so two runs
# (the tree before a change and after it) compare one input.
set here [file dirname [file normalize [info script]]]
set audit [file dirname $here]
set repo [file dirname [file dirname $audit]]
set root $repo
foreach {option value} $argv {
    switch -- $option {
        -root { set root [file normalize $value] }
        default { puts stderr "usage: evidence.tcl ?-root DIR?"; exit 2 }
    }
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root service service.tcl]
interp recursionlimit {} 100000

# LINE COLUMN WHAT for each query, by the programs' shared text (repro-byte
# has one more line, its import, above every query).
set queries {
    20 5  "bs = s.encode_utf8()  (bs)"
    20 12 "s.encode_utf8()  (the call)"
    21 5  "x = bs.at(0)  (x)"
    16 10 "loop b in s.encode_utf8()  (b)"
}

proc Hover {rev path line column} {
    set facts [service::at $rev $path $line $column]
    if {[dict exists $facts hover]} {
        return [dict get $facts hover]
    }
    return "(none: [dict values [dict get $facts unavailable]])"
}

puts "## Compiler: $root"
foreach program {repro repro-byte} {
    set path [file join $audit programs $program.bot]
    set shift [expr {$program eq "repro-byte" ? 1 : 0}]
    set ws [service::workspace -warnings off -cache ""]
    set rev [service::analyze $ws $path]
    puts "\n### $program.bot"
    puts "\n| position | hover |\n|---|---|"
    foreach {line column what} $queries {
        puts "| `$what` | `[Hover $rev $path [expr {$line + $shift}] $column]` |"
    }
    puts "\ndiagnostics:"
    set diagnostics [service::diagnostics $rev -severity error]
    if {$diagnostics eq {}} {
        puts "  (none)"
    }
    foreach d $diagnostics {
        set at ""
        if {[dict exists $d line]} {
            set at "[expr {[dict get $d line] - $shift}]:[dict get $d column] "
        }
        puts "  ${at}[lindex [dict get $d code] end]: [dict get $d message]"
    }
    service::closeWorkspace $ws
}

puts "\n### probes c4 and c5 on the four backends\n"
puts "| probe | interp | compile | cranelift | cranelift-generic |\n|---|---|---|---|---|"
foreach probe {c4-unused-import-decides c5-unused-import-accepts} {
    set path [file join $repo audit text-collection-precision probes $probe.bot]
    set row "| $probe |"
    foreach backend {interp compile cranelift cranelift-generic} {
        catch {exec tclsh9.0 [file join $root main.tcl] -warnings off -backend $backend $path 2>@1} output
        set outcome rejected
        foreach line [split $output \n] {
            if {[regexp {^\s+value: (.*)$} $line -> value]} {
                set outcome $value
            }
        }
        append row " `$outcome` |"
    }
    puts $row
}

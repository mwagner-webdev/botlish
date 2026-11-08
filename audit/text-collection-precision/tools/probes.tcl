# probes.tcl -- run the census's probes and check the outcomes they record
# (TEXT-AND-COLLECTION-PRECISION-CENSUS.md, section K). The probes pin
# today's behavior; they assert nothing about what it should be.
#
#   tclsh9.0 audit/text-collection-precision/tools/probes.tcl \
#       [-backends {interp compile cranelift cranelift-generic}] [PROBE.bot ...]
#
# Each probe's leading comments state:
#   # outcome: accept | reject | runtime-error
#   # value: TEXT              (accept) the value line every backend prints
#   # diagnostic: L:C TEXT     (reject) one error at L:C whose message
#                              begins with TEXT; the errors are exactly these
#   # error: TEXT              (runtime-error) every backend's run fails so
#   # binding: L NAME TYPE     the compiler service's recorded type of the
#                              binding NAME declared on line L
#                              (service::BindingType, what a hover shows)
# Exit status 1 when any probe's outcome differs.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root service service.tcl]
interp recursionlimit {} 100000

set backends {interp compile cranelift cranelift-generic}
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -backends { set backends [lindex $argv [incr i]] }
        default { lappend files [file normalize [lindex $argv $i]] }
    }
}
if {$files eq ""} {
    set files [lsort [glob -directory [file join [file dirname $here] probes] *.bot]]
}

proc Header {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set spec [dict create outcome "" value "" diagnostics {} error "" bindings {}]
    while {[gets $f line] >= 0} {
        if {![string match "#*" $line]} break
        if {[regexp {^# outcome: (\S+)} $line -> v]} { dict set spec outcome $v }
        if {[regexp {^# value: (.*)$} $line -> v]} { dict set spec value $v }
        if {[regexp {^# error: (.*)$} $line -> v]} { dict set spec error $v }
        if {[regexp {^# diagnostic: (\d+):(\d+) (.*)$} $line -> l c t]} {
            dict lappend spec diagnostics [list $l $c $t]
        }
        if {[regexp {^# binding: (\d+) (\S+) (.*)$} $line -> l n t]} {
            dict lappend spec bindings [list $l $n $t]
        }
    }
    close $f
    return $spec
}

# The output lines of main.tcl ARGS, standard error included.
proc Main {args} {
    global root
    set env(LANG) C.utf8
    set command [list [info nameofexecutable] [file join $root main.tcl] -warnings off {*}$args]
    catch {exec {*}$command 2>@1} output
    return [split $output \n]
}

# {LINE COLUMN MESSAGE} of every error main.tcl -check reports.
proc Errors {lines} {
    set found {}
    foreach line $lines {
        if {[regexp {^\s*error: .*?:(\d+):(\d+): (.*?)(?: \([A-Z][A-Z-]* [A-Z].*\))?$} $line -> l c m]} {
            lappend found [list $l $c $m]
        }
    }
    return $found
}

# The recorded type of binding NAME declared on LINE of PATH.
proc BindingTypes {path} {
    set ws [service::workspace -warnings off -cache ""]
    set rev [service::analyze $ws $path]
    set hir [service::hir $rev]
    set types [dict create]
    if {$hir eq ""} { return $types }
    hir::activate $hir
    dict for {b binding} [dict get $hir bindings] {
        set origin [dict get $binding origin]
        if {[lindex $origin 0] ne "file" || ![dict exists $hir files [lindex $origin 1]]} continue
        if {[file normalize [dict get $hir files [lindex $origin 1] path]] ne $path} continue
        set line [dict getdef [lrange $origin 2 end] line 0]
        dict lappend types "$line [hir::semantic::SourceName $hir $b]" \
            [hir::types::presented [service::BindingType $hir $b]]
    }
    service::closeWorkspace $ws
    return $types
}

set failed 0
foreach path $files {
    set spec [Header $path]
    set name [file tail $path]
    set problems {}
    set check [Main -check $path]
    set errors [Errors $check]
    switch -- [dict get $spec outcome] {
        reject {
            set expected [dict get $spec diagnostics]
            foreach d $expected {
                lassign $d l c t
                set hit 0
                foreach e $errors {
                    if {[lindex $e 0] == $l && [lindex $e 1] == $c && [string first $t [lindex $e 2]] == 0} {
                        set hit 1
                    }
                }
                if {!$hit} { lappend problems "missing diagnostic $l:$c $t" }
            }
            if {[llength $errors] != [llength $expected]} {
                lappend problems "[llength $errors] errors, [llength $expected] expected: [join $errors {; }]"
            }
        }
        accept - runtime-error {
            if {[llength $errors]} {
                lappend problems "rejected: [join $errors {; }]"
            } else {
                foreach backend $backends {
                    set out [Main -backend $backend $path]
                    if {[dict get $spec outcome] eq "accept"} {
                        set line [lsearch -inline -regexp $out {^\s*value: }]
                        set got [regsub {^\s*value: } $line ""]
                        if {$got ne [dict get $spec value]} {
                            lappend problems "$backend: value \"$got\", expected \"[dict get $spec value]\""
                        }
                    } elseif {[string first "error: [dict get $spec error]" [join $out \n]] < 0} {
                        lappend problems "$backend: no error \"[dict get $spec error]\": [join $out { | }]"
                    }
                }
            }
        }
        default {
            lappend problems "no outcome stated"
        }
    }
    if {[llength [dict get $spec bindings]]} {
        set types [BindingTypes $path]
        foreach b [dict get $spec bindings] {
            lassign $b l n t
            set got [dict getdef $types "$l $n" {}]
            if {$t ni $got} {
                lappend problems "binding $n on line $l: recorded [list $got], expected $t"
            }
        }
    }
    if {[llength $problems]} {
        incr failed
        puts "FAIL $name"
        foreach p $problems { puts "    $p" }
    } else {
        puts "ok   $name ([dict get $spec outcome])"
    }
    flush stdout
}
puts "[llength $files] probes, $failed failed"
exit [expr {$failed > 0}]

# inventory.tcl -- the example inventory (campaign brief #4): one row per
# example program, nothing silently ignored.
#
#   tclsh9.0 fuzz/scripts/inventory.tcl > fuzz/inventory.tsv
#
# Columns:
#   name        file root name
#   source      repository path
#   kind        bot|hir|ir
#   input       the program's input surface, determined from the source
#               itself: "argv()" appears / reads stdin / reads a file /
#               none (Botlish has no other channel -- ARGV.md). Every
#               example's standalone executable still consumes its
#               process argv at the runtime level (runtime/aot.rs), which
#               is what the campaign fuzzes; the column says what the
#               *program* does with input.
#   expect      the "# expect:" comment from the source, if present
#   expecterr   the "# expect-error:" comment, if present
#   aot         ok|not-ready|negative|ir-input (from a build-aot.sh
#               manifest, if one exists; otherwise "?" -- run build-aot.sh)
#
# The fuzzable/ column and the reasoning live in FUZZING-EXAMPLES-AOT.md,
# which consumes this table; this script only states mechanically
# checkable facts.
set root [file normalize [file join [file dirname [info script]] .. ..]]

proc readText {path} {
    set channel [open $path r]
    fconfigure $channel -encoding utf-8
    try { return [read $channel] } finally { close $channel }
}

# The one "# expect: ..." / "# expect-error: ..." line of a source file.
proc headerComment {text tag} {
    foreach line [split $text \n] {
        if {[regexp "^\[ \\t\]*\[#\]+\\s*${tag}( \\(\[^)\]*\\))?:\\s*(.*)\$" $line -> _ _ value]} {
            return $value
        }
    }
    return ""
}

set sources {}
foreach pattern {stdlib/*.bot abi/*.bot linux/*.bot surface/*.bot hir/*.hir *.ir} {
    foreach path [lsort [glob -directory [file join $root examples] $pattern]] {
        set tail [file tail $path]
        if {$tail in {corpus.tcl main.tcl}} continue
        lappend sources $path
    }
}

# An AOT manifest from a previous build-aot.sh run, if present.
set manifest [file join $root fuzz build aot manifest.tsv]
set aot {}
if {[file exists $manifest]} {
    foreach line [split [readText $manifest] \n] {
        if {[llength [split $line \t]] >= 4} {
            lassign [split $line \t] name _ result note
            dict set aot $name "$result\t[string map {\t " "} $note]"
        }
    }
}

puts "name\tsource\tkind\tinput\texpect\temit-result\temit-note"
foreach path $sources {
    set name [file rootname [file tail $path]]
    set text [readText $path]
    set kind [string range [file extension $path] 1 end]
    if {[string match "*argv()*" $text]} {
        set input "argv()"
    } elseif {[string match "*stdin*" $text]} {
        set input "stdin"
    } else {
        set input "none"
    }
    set expect [headerComment $text expect]
    if {$expect eq ""} { set expect [headerComment $text expect-error] }
    set emit [expr {[dict exists $aot $name] ? [dict get $aot $name] : "?\t"}]
    set relative [file join examples [file tail [file dirname $path]] [file tail $path]]
    if {![file exists [file join $root $relative]]} {
        set relative [file join examples [file tail $path]]
    }
    puts [join [list $name $relative $kind $input \
        [string map {\t " "} $expect] $emit] \t]
}

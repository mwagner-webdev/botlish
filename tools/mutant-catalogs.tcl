# mutant-catalogs.tcl -- every mutation catalog still applies to this tree.
#
#   tclsh9.0 tools/mutant-catalogs.tcl ?-root DIR? ?-verbose 1?
#
# The audits' mutation harnesses (audit/NAME/tools/mutate.tcl and the
# censuses) read catalogs of deliberate bugs, each an exact text
# replacement: a block
#
#   <<<<
#   text to replace (must occur exactly once in its file)
#   ====
#   replacement
#   >>>>
#
# applied in order, every block of one mutant to the tree as the earlier
# blocks left it (`<<<< all`, which audit/mutable-map/tools/mutate.tcl also
# reads: every occurrence, at least one). A harness reports a mutant whose text no longer occurs
# exactly once as NOT-APPLIED -- but only when that harness runs, which is
# when its own area changes. A change elsewhere that rewrites or duplicates
# the text goes unnoticed until then, and the rule the mutant guarded is
# unguarded meanwhile (MAIN-TEST-DEFECTS-2026-11.md). This check reads
# every catalog and applies every mutant to an in-memory copy of the files
# it names, compiling and running nothing: it takes seconds, so CI runs it
# on every push (a step of tests.yml's canary job).
#
# A catalog is any .txt file under audit/ with a line that is exactly
# `<<<<`. Its edits name their files in one of three ways (Catalogs below):
#
#   edits    a `## FILE` line names the file of the blocks after it (the
#            mutation harnesses' format; FILE relative to the repository
#            root unless the table gives another base)
#   named    a mutant's `@@ NAME FILE ...` line names its one file, relative
#            to the table's base (the emission and CSV censuses)
#   single   every block edits the one file the table names (the DFA
#            mistakes)
#
# A file name starting with an out-of-tree prefix (OutOfTree below) names a
# file a harness makes at run time, never committed: such an edit is
# counted and skipped. Exits 1, listing each mutant that does not apply
# and why, when any does not, a catalog holds no mutant, or a mutant no
# edit; 0 otherwise.

set here [file dirname [file normalize [info script]]]
set options [dict create -root [file dirname $here] -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        puts stderr "mutant-catalogs.tcl: unknown option $option (-root DIR, -verbose 0|1)"
        exit 2
    }
    dict set options $option $value
}
set root [file normalize [dict get $options -root]]

# The catalogs whose edits are not the harnesses' default (format edits,
# relative to the repository root): GLOB (relative to the root) FORMAT BASE.
# A new catalog of another form or base goes here; until it does, its files
# are not found and the check fails, never passes it unread.
set Catalogs {
    audit/emission-proofs/tools/mutants.txt     edits  audit/emission-proofs/tools
    audit/hash-table/tools/mutants*.txt         edits  audit/hash-table
    audit/csv-emission/census/mutants.txt       named  examples/dfa/csv
    audit/emission-claims/census/mistakes.txt   named  examples/dfa/json
    audit/emitter/census/cases.txt              named  audit/emitter/json
    audit/dfa/tools/mistakes.txt                single examples/dfa/json/json_lex.bot
}
# The generated SDL3 binding the macOS Icy Tower mutants edit
# (audit/icy-tower/mutate.tcl: a private copy the macOS job stages).
set OutOfTree {@binding/}

proc readText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    try {
        return [read $f]
    } finally {
        close $f
    }
}

# Every .txt file under DIR, recursively, in sorted order.
proc textFiles {dir} {
    set found {}
    foreach entry [lsort [glob -nocomplain -directory $dir *]] {
        if {[file isdirectory $entry]} {
            lappend found {*}[textFiles $entry]
        } elseif {[file extension $entry] eq ".txt"} {
            lappend found $entry
        }
    }
    return $found
}

# FORMAT and BASE of the catalog at RELATIVE path.
proc configuration {relative} {
    foreach {pattern format base} $::Catalogs {
        if {[string match $pattern $relative]} {
            return [list $format $base]
        }
    }
    return {edits .}
}

# The mutants of TEXT, a catalog of FORMAT whose base is BASE, as
# {NAME LINE {FILE MODE OLD NEW ...}} (FILE relative to the root; MODE once or
# all).
proc parse {text format base} {
    set mutants {}
    set name ""
    set state outside
    set current ""
    set number 0
    foreach line [split $text \n] {
        incr number
        switch -- $state {
            outside {
                if {[regexp {^@@ (\S+)(?: (\S+))?} $line -> n second]} {
                    if {$name ne ""} { lappend mutants [list $name $at $edits] }
                    set name $n
                    set at $number
                    set edits {}
                    switch -- $format {
                        named { set current [file join $base $second] }
                        single { set current $base }
                    }
                } elseif {$format eq "edits" && [regexp {^## (\S+)$} $line -> file]} {
                    set current [expr {$base eq "." ? $file : "$base/$file"}]
                    # (An out-of-tree prefix stays at the front of the name.)
                    foreach prefix $::OutOfTree {
                        if {[string match $prefix* $file]} { set current $file }
                    }
                } elseif {$line eq "<<<<" || $line eq "<<<< all"} {
                    set mode [if {$line eq "<<<<"} {string cat once} else {string cat all}]
                    set state old
                    set old {}
                }
            }
            old {
                if {$line eq "===="} {
                    set state new
                    set new {}
                } else {
                    lappend old $line
                }
            }
            new {
                if {$line eq ">>>>"} {
                    lappend edits $current $mode [join $old \n] [join $new \n]
                    set state outside
                } else {
                    lappend new $line
                }
            }
        }
    }
    if {$name ne ""} { lappend mutants [list $name $at $edits] }
    return $mutants
}

set problems {}
set catalogs 0
set total 0
set skipped 0
foreach path [textFiles [file join $root audit]] {
    set text [readText $path]
    if {[lsearch -exact [split $text \n] "<<<<"] < 0} continue
    set relative [string range $path [string length $root/] end]
    lassign [configuration $relative] format base
    incr catalogs
    set mutants [parse $text $format $base]
    if {$mutants eq {}} {
        lappend problems "$relative: no mutant (no `@@ NAME` line before its first block)"
        continue
    }
    set applied 0
    foreach mutant $mutants {
        lassign $mutant name line edits
        incr total
        if {$edits eq {}} {
            lappend problems "$relative:$line $name: no edit"
            continue
        }
        set texts [dict create]
        set problem ""
        foreach {file mode old new} $edits {
            if {$file eq ""} {
                set problem "a block before any `## FILE` line"
                break
            }
            set outside 0
            foreach prefix $OutOfTree {
                if {[string match $prefix* $file]} { set outside 1 }
            }
            if {$outside} {
                incr skipped
                continue
            }
            if {![dict exists $texts $file]} {
                set target [file join $root $file]
                if {![file isfile $target]} {
                    set problem "$file: no such file"
                    break
                }
                dict set texts $file [readText $target]
            }
            set current [dict get $texts $file]
            set first [string first $old $current]
            if {$first < 0} {
                set problem "$file: the text to replace does not occur (its first line: [string trim [lindex [split $old \n] 0]])"
                break
            }
            if {$mode eq "all"} {
                dict set texts $file [string map [list $old $new] $current]
                continue
            }
            if {[string first $old $current [expr {$first + 1}]] >= 0} {
                set problem "$file: the text to replace occurs more than once (its first line: [string trim [lindex [split $old \n] 0]])"
                break
            }
            dict set texts $file [string replace $current $first [expr {$first + [string length $old] - 1}] $new]
        }
        if {$problem ne ""} {
            lappend problems "$relative:$line $name: $problem"
        } else {
            incr applied
        }
    }
    if {[dict get $options -verbose]} {
        puts [format "%-58s %4d of %4d apply" $relative $applied [llength $mutants]]
    }
}

puts "$catalogs catalogs, $total mutants, [llength $problems] problems ($skipped edits of files made at run time not checked)"
foreach problem $problems {
    puts "  $problem"
}
if {$problems ne {}} {
    puts "\nA mutant that does not apply guards nothing: update its text to the code it mutates, keeping it a mutant of the same rule, and run its harness (AGENTS.md)."
    exit 1
}
exit 0

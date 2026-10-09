# method-sweep.tcl -- phase P2 of the warning-driven refactor
# (REFACTOR-WARNINGS-CLEAN.md): every METHOD-ELIGIBLE call of the corpus
# respelled with method sugar, each one verified by the round-trip law before
# the next is taken, then the whole corpus verified once more.
#
#   tclsh9.0 audit/refactor/tools/method-sweep.tcl ?-apply 0|1? ?-only GLOB?
#
# It reuses milestone 2's rewrite machinery (audit/method-eligible/tools/
# rewrite.tcl, me::sugarCall: the call is located by its warning's span and
# its receiver cut out by the parser's own AST spans) and its fingerprint
# (the program's HIR text, core IR and NIR, specialized and generic), and
# works on a scratch copy of lib/, examples/ and bench/:
#
#   for every file F with a METHOD-ELIGIBLE finding, through a unit U that
#   compiles it (F itself for an entry program, the one-line loader
#   `import NS` for a library module), repeatedly
#     * take F's LAST finding in source order (innermost first: a call is
#       respelled before the calls its receiver contains -- milestone 2's
#       lesson),
#     * respell it with me::sugarCall in the scratch copy,
#     * recompile U and require: it compiles; F has exactly one
#       METHOD-ELIGIBLE finding fewer; every other warning of U is unchanged
#       (code, file, line and message: a respelling moves text within its
#       own line span only); and U's fingerprint equals the fingerprint of
#       the ORIGINAL tree's U, compiled right before it (the registries a
#       fingerprint reads are process-global: milestone 2's caveat).
#   A call that fails any check is restored, recorded and skipped: it is a
#   warning-design question, never hand-converted.
#
# Then every unit of the corpus (every corpus program and every loader) is
# compared once more, original against scratch: same fingerprint, no
# METHOD-ELIGIBLE finding left, every other warning unchanged. With -apply 1
# (the default is 0, a dry run) and no failure, the respelled files are
# copied over the tree's. The log of every call is printed on stdout.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set apply 0
set only *
foreach {option value} $argv {
    switch -- $option {
        -apply { set apply $value }
        -only { set only $value }
        default { error "unknown option $option" }
    }
}
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root audit method-eligible tools rewrite.tcl]
set ::refactorSweepLibrary 1
source [file join $here sweep.tcl]

set scratch [file tempdir refactor-method-sweep]
foreach dir {lib examples bench} {
    file copy [file join $root $dir] [file join $scratch $dir]
}
set realLib $::core::libraryDir
set loaderDir [file join $scratch loaders]
file mkdir $loaderDir

# The path of unit UNIT in TREE ($root or $scratch): an entry program's file,
# or a loader program (the same loader text serves both trees).
proc unitPath {tree unit} {
    if {[string match "import *" $unit]} {
        set ns [lindex $unit 1]
        set path [file join $::loaderDir load-[string map {:: -} $ns].bot]
        if {![file exists $path]} {
            refactor::sweep::writeText $path "import $ns\n0\n"
        }
        return $path
    }
    return [file join $tree $unit]
}

# HIR of UNIT compiled from TREE (its modules from TREE's lib/).
proc compileUnit {tree unit} {
    set ::core::libraryDir [file join $tree lib]
    try {
        return [surface::readProgramFile [unitPath $tree $unit] -warnings default -warning-channel ""]
    } finally {
        set ::core::libraryDir $::realLib
    }
}

proc nirOf {hir args} {
    if {[catch {native::lower::program $hir {*}$args} result options]} {
        return [list error [dict get $options -errorcode]]
    }
    return [dict get $result text]
}

# Milestone 2's fingerprint: HIR text, core IR, NIR specialized and generic.
proc fingerprint {hir} {
    return [dict create format [hir::format $hir] lower [hir::lower $hir] \
        nir [nirOf $hir] nirGeneric [nirOf $hir -specialize 0]]
}

proc differences {a b} {
    set diffs {}
    foreach key {format lower nir nirGeneric} {
        if {[dict get $a $key] ne [dict get $b $key]} {
            lappend diffs $key
        }
    }
    return $diffs
}

# The warnings of HIR as {CODE FILE LINE COL MESSAGE START END CALLEE}, FILE
# relative to TREE (scratch and root files compare equal by their relative
# path), START/END the primary origin's span.
proc warningsOf {tree hir} {
    set records {}
    foreach w [hir::warnings::of $hir] {
        set origin [dict get $w primary]
        set fields [lrange $origin 2 end]
        set file [refactor::sweep::Rel $tree [dict get [hir::sourceFile $hir [lindex $origin 1]] path]]
        set callee ""
        if {[dict get $w code] eq "METHOD-ELIGIBLE"} {
            set callee [dict get $w data functionName]
        }
        lappend records [list [dict get $w code] $file [dict get $fields line] [dict get $fields column] \
            [dict get $w message] [dict get $fields start] [dict get $fields end] $callee]
    }
    return $records
}

# The records of WARNINGS that are METHOD-ELIGIBLE findings in FILE, in
# source order.
proc eligibleIn {warnings file} {
    set found {}
    foreach r $warnings {
        if {[lindex $r 0] eq "METHOD-ELIGIBLE" && [lindex $r 1] eq $file} {
            lappend found $r
        }
    }
    return [lsort -integer -index 5 $found]
}

# Every warning of WARNINGS but the METHOD-ELIGIBLE ones, as a sorted list of
# {CODE FILE LINE MESSAGE} (columns move when a call before them on their
# line is respelled; nothing else may).
proc othersOf {warnings} {
    return [lsort [lmap r $warnings {
        if {[lindex $r 0] eq "METHOD-ELIGIBLE"} continue
        list [lindex $r 0] [lindex $r 1] [lindex $r 2] [lindex $r 4]
    }]]
}

proc rel {path} {
    return [refactor::sweep::Rel $::scratch $path]
}

# ---------------------------------------------------------------------------
# The files with findings, and a unit for each

set units [dict keys [refactor::sweep::observe $root]]
set fileUnit [dict create]   ;# file -> the unit its findings are taken from
set count [dict create]      ;# file -> findings at the start
foreach unit $units {
    if {[catch {compileUnit $scratch $unit} hir]} continue
    foreach r [warningsOf $scratch $hir] {
        lassign $r code file
        if {$code ne "METHOD-ELIGIBLE" || ![string match $only $file]} continue
        # A module's findings are taken through its own loader; an entry
        # program's through itself.
        set preferred [expr {[string match lib/* $file]
            ? "import [string map {/ ::} [string range [file rootname $file] 4 end]]" : $file}]
        if {$unit eq $preferred || ![dict exists $fileUnit $file]} {
            dict set fileUnit $file $unit
        }
    }
}
foreach file [dict keys $fileUnit] {
    set hir [compileUnit $scratch [dict get $fileUnit $file]]
    dict set count $file [llength [eligibleIn [warningsOf $scratch $hir] $file]]
}

puts "# METHOD-ELIGIBLE sweep (REFACTOR-WARNINGS-CLEAN.md, P2): every call respelled and verified"
lassign [refactor::sweep::Commit $root] commit state
puts "# tree $commit (corpus paths $state)"
puts ""
set total 0
dict for {file n} $count {
    incr total $n
}
puts "files with findings: [dict size $count]; findings: $total"
puts ""

# ---------------------------------------------------------------------------
# Per call

set failures {}
set steps 0
foreach file [lsort [dict keys $fileUnit]] {
    set unit [dict get $fileUnit $file]
    set path [file join $scratch $file]
    set skipped {}
    puts "## $file ([dict get $count $file] findings, through `$unit`)"
    while 1 {
        set hir [compileUnit $scratch $unit]
        set before [warningsOf $scratch $hir]
        set candidates [lmap r [eligibleIn $before $file] {
            if {[list [lindex $r 2] [lindex $r 3]] in $skipped} continue
            set r
        }]
        if {$candidates eq ""} break
        set r [lindex $candidates end]
        lassign $r code _ line column message start end callee
        set member [hir::warnings::MemberName $callee]
        set text [refactor::sweep::readText $path]
        set problem ""
        if {[catch {me::sugarCall $text $path $start $end $member} new]} {
            set problem "no rewrite: $new"
        } else {
            refactor::sweep::writeText $path $new
            if {[catch {compileUnit $scratch $unit} hir1 options]} {
                set problem "does not compile: [dict get $options -errorcode]"
            } else {
                set after [warningsOf $scratch $hir1]
                set left [llength [eligibleIn $after $file]]
                if {$left != [llength [eligibleIn $before $file]] - 1} {
                    set problem "findings in the file $left, expected [expr {[llength [eligibleIn $before $file]] - 1}]"
                } elseif {[othersOf $after] ne [othersOf $before]} {
                    set problem "another warning changed"
                } else {
                    set original [fingerprint [compileUnit $root $unit]]
                    set diffs [differences $original [fingerprint $hir1]]
                    if {$diffs ne ""} {
                        set problem "fingerprint differs: [join $diffs {, }]"
                    }
                }
            }
        }
        set shown [string trim [lindex [split $text \n] [expr {$line - 1}]]]
        if {$problem ne ""} {
            refactor::sweep::writeText $path $text
            lappend skipped [list $line $column]
            lappend failures [list $file $line $column $callee $problem]
            puts "  FAIL $file:$line:$column `$callee`: $problem   ($shown)"
            continue
        }
        incr steps
        puts "  ok   $file:$line:$column `$callee`"
    }
}
puts ""

# ---------------------------------------------------------------------------
# The whole corpus, once more

puts "## Every unit, original against respelled"
set unitFailures 0
foreach unit $units {
    if {[catch {compileUnit $root $unit} original]} {
        # A deliberate rejection, or a module that does not compile
        # standalone: the respelled copy must fail identically.
        set code [lindex $::errorCode end]
        if {[catch {compileUnit $scratch $unit}]} {
            puts "  same rejection: $unit"
        } else {
            incr unitFailures
            puts "  FAIL $unit: the original fails ($code), the respelled copy compiles"
        }
        continue
    }
    set originalFp [fingerprint $original]
    set originalWarnings [warningsOf $root $original]
    set respelled [compileUnit $scratch $unit]
    set problems [differences $originalFp [fingerprint $respelled]]
    set respelledWarnings [warningsOf $scratch $respelled]
    set left [llength [lsearch -all -index 0 $respelledWarnings METHOD-ELIGIBLE]]
    if {$left > 0} {
        lappend problems "$left METHOD-ELIGIBLE left"
    }
    if {[othersOf $respelledWarnings] ne [othersOf $originalWarnings]} {
        lappend problems "other warnings differ"
    }
    if {$problems ne ""} {
        incr unitFailures
        puts "  FAIL $unit: [join $problems {, }]"
    } else {
        puts "  same program: $unit ([llength [lsearch -all -index 0 $originalWarnings METHOD-ELIGIBLE]] findings before, 0 after)"
    }
}
puts ""
puts "calls respelled and verified: $steps of $total; call failures: [llength $failures]; unit failures: $unitFailures"
foreach f $failures {
    puts "  not converted: [lindex $f 0]:[lindex $f 1]:[lindex $f 2] `[lindex $f 3]`: [lindex $f 4]"
}

if {$apply && $failures eq "" && $unitFailures == 0} {
    foreach file [dict keys $count] {
        file copy -force [file join $scratch $file] [file join $root $file]
    }
    puts "applied to [dict size $count] files"
} elseif {$apply} {
    puts "NOT applied: failures"
}
file delete -force $scratch
exit [expr {$failures ne "" || $unitFailures > 0}]

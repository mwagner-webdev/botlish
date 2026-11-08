# workload.tcl -- the warning gate's compilations as a workload for the
# mid-end question (audit/mid-end-port/README.md, "The workload"):
#
#   tclsh9.0 audit/mid-end-port/tools/workload.tcl units
#   tclsh9.0 audit/mid-end-port/tools/workload.tcl phases
#   tclsh9.0 audit/mid-end-port/tools/workload.tcl analyses ?NS|FILE.bot?
#   tclsh9.0 audit/mid-end-port/tools/workload.tcl interchange ?NS ...?
#
# units        every unit of audit/refactor/tools/gate.tcl (each corpus
#              program and each library loader), compiled with warnings
#              collected and again under -warnings error, as the gate does:
#              one line per unit, `DEFAULT-SECONDS ERROR-SECONDS FILES
#              WARNINGS OUTCOME UNIT`, then the totals
# phases       the gate's first pass (every unit, warnings collected) split
#              into the front end's coarse phases: inclusive seconds and the
#              share of the whole, the outermost activation of each phase
# analyses     one loader `import NS` (default std::event_loop), or a program
#              FILE.bot (a synth.tcl program's main.bot): every hir::
#              procedure a build calls directly (the ones named in the bodies
#              of hir::BuildFull, BuildOnce, check and CheckOnce), with its
#              exclusive seconds (minus the wrapped calls inside it), its
#              share of the compilation and its number of calls, largest
#              first: how flat the mid-end's profile is
# interchange  for each loader `import NS` (default std::event_loop,
#              std::actor, std::mutable_map): its build, and encoding and
#              decoding its HIR as interchange text (hir/interchange.tcl),
#              the cost of handing a whole program's HIR across a language
#              boundary
#
# Every compilation uses no front-end cache. The loader programs are written
# to a `file tempdir` directory removed afterwards.

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname $here]]]
set part [lindex $argv 0]
source [file join $checkout surface surface.tcl]
set ::core::libraryDir [file join $checkout stdlib]
set ::refactorSweepLibrary 1
source [file join $checkout audit refactor tools sweep.tcl]

source [file join $here timing.tcl]
set phases {::surface::modules::BuildProgram ::surface::modules::CollectAndLoad
    ::surface::modules::Parse ::hir::buildSyntax ::hir::BuildOnce ::hir::check
    ::hir::DecideMethodCalls ::hir::traits::monomorphize ::hir::signatures::infer
    ::hir::resolve::program ::surface::lower::Finish ::hir::warnings::collect}
# Every hir:: procedure the build and the check call directly.
proc analysisProcs {} {
    set procs {}
    foreach caller {::hir::BuildFull ::hir::BuildOnce ::hir::check ::hir::CheckOnce} {
        foreach name [regexp -all -inline {hir::[A-Za-z_]+(?:::[A-Za-z_]+)?} [info body $caller]] {
            set name ::$name
            if {[info procs $name] ne "" && $name ni $procs} { lappend procs $name }
        }
    }
    foreach name {::hir::BuildOnce ::hir::CheckOnce ::surface::modules::CollectAndLoad
            ::surface::modules::Parse ::surface::lower::Finish} {
        if {$name ni $procs} { lappend procs $name }
    }
    # Accessors and bookkeeping, not analyses.
    return [lmap name $procs {
        expr {[regexp {::(node|get|kind|scope|binding|symbol|type|typeOf|bindingType|top|roots|mode|diagnostics|signatures|sourceFile|sourceTypes|errorDecls|originSpan|originLocation|Options|activate|buildStats|Diagnose|methodBuildAudit|methodReferenceAudit|ReferenceAudit|AuditRecheck|CheckWith|callables)$} $name] ? [continue] : $name}
    }]
}
if {$part eq "phases"} {
    # Wrapped before the warm-up (timing.tcl).
    timing::wrap $phases
} elseif {$part eq "analyses"} {
    set analysisProcs [analysisProcs]
    timing::wrap $analysisProcs
}
set scratch [file tempdir mid-end-workload]
proc loader {ns} {
    set path [file join $::scratch load-[string map {:: - @ -} $ns].bot]
    refactor::sweep::writeText $path "import $ns\n0\n"
    return $path
}
# Warm: load what a compilation loads lazily, outside the timing.
surface::readProgramFile [loader std::list] -warnings off -cache ""

# Every unit of the gate: {NAME PATH TARGET}.
proc units {} {
    set units {}
    foreach program [refactor::sweep::programs $::checkout] {
        lappend units [list $program [file join $::checkout $program] ""]
    }
    foreach module [refactor::sweep::modules $::checkout] {
        lassign [refactor::sweep::moduleTarget $module] ns target
        lappend units [list "import $module" [loader $ns] $target]
    }
    return $units
}

proc seconds {script} {
    set t0 [clock microseconds]
    uplevel 1 $script
    return [expr {([clock microseconds] - $t0) / 1e6}]
}

try {
    switch -- $part {
        units {
            set totals {0 0}
            foreach unit [units] {
                lassign $unit name path target
                set d [seconds {set r [refactor::sweep::Compile $::checkout $path default $target]}]
                set e [seconds {set s [refactor::sweep::Compile $::checkout $path error $target]}]
                set files [expr {[lindex $r 0] eq "ok" ? [llength [lindex $r 2]] : "-"}]
                set warnings [expr {[lindex $r 0] eq "ok" ? [llength [lindex $r 1]] : "-"}]
                puts [format "%7.3f %7.3f %4s %4s %-6s %s" $d $e $files $warnings [lindex $s 0] $name]
                lset totals 0 [expr {[lindex $totals 0] + $d}]
                if {[lindex $r 0] eq "ok" && [lindex $r 1] eq ""} {
                    # The gate compiles a unit again only when it expects no warning.
                    lset totals 1 [expr {[lindex $totals 1] + $e}]
                }
            }
            puts [format "total: first pass %.1f s, strict pass %.1f s (units the gate compiles again)" {*}$totals]
        }
        phases {
            timing::reset
            set all 0
            foreach unit [units] {
                lassign $unit name path target
                set all [expr {$all + [seconds {refactor::sweep::Compile $::checkout $path default $target}]}]
            }
            puts [format "first pass, every unit: %.1f s" $all]
            foreach p $phases {
                set t [timing::seconds $p]
                puts [format "%7.1f s %5.1f%%  %s" $t [expr {100.0 * $t / $all}] [string trimleft $p :]]
            }
        }
        analyses {
            set ns [lindex $argv 1]
            if {$ns eq ""} { set ns std::event_loop }
            if {[file extension $ns] eq ".bot"} {
                set path [file normalize $ns]
                set label [file tail [file dirname $path]]/[file tail $path]
            } else {
                set path [loader $ns]
                set label "import $ns"
            }
            timing::reset
            set all [seconds {surface::readProgramFile $path -warnings default -warning-channel "" -cache ""}]
            puts [format "%s: %.2f s, %d builds' procedures (exclusive seconds, share, calls)" $label $all [llength $analysisProcs]]
            set rows [lsort -real -decreasing -index 1 [lmap p $analysisProcs {list $p [timing::exclusiveSeconds $p] [timing::calls $p]}]]
            set covered 0
            foreach row $rows {
                lassign $row p t n
                set covered [expr {$covered + $t}]
                if {$t < 0.005} continue
                puts [format "%7.2f s %5.1f%% %6d  %s" $t [expr {100.0 * $t / $all}] $n [string trimleft $p :]]
            }
            puts [format "%7.2f s %5.1f%%         (in no wrapped procedure)" [expr {$all - $covered}] [expr {100.0 * ($all - $covered) / $all}]]
        }
        interchange {
            set namespaces [lrange $argv 1 end]
            if {$namespaces eq ""} { set namespaces {std::event_loop std::actor std::mutable_map} }
            foreach ns $namespaces {
                set path [loader $ns]
                set build [seconds {set hir [surface::readProgramFile $path -warnings default -warning-channel "" -cache ""]}]
                set encode [seconds {set text [hir::interchange::encode $hir]}]
                set decode [seconds {hir::interchange::decode $text}]
                puts [format "%-24s build %6.2f s  encode %5.2f s  decode %5.2f s  (%4.1f%% of the build)  %5.1f MB  %d exprs" \
                    $ns $build $encode $decode [expr {100.0 * ($encode + $decode) / $build}] \
                    [expr {[string length $text] / 1e6}] [dict size [dict get $hir exprs]]]
            }
        }
        default { error "workload.tcl: the part is units, phases, analyses or interchange" }
    }
} finally {
    file delete -force $scratch
}

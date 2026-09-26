# lib.tcl -- M7.a audit helpers (M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md).
#
# Observation only. Every proc here *reads* what the existing analyses
# already computed (hir::specialize::analyze, hir::range::analyze,
# hir::range::OpenInstances, hir::specialize::RefinementFacts, the
# hir/completions.tcl fields stamped on HIR nodes, native::lower::program):
# nothing is registered, patched, overridden or re-implemented inside a
# production namespace, and sourcing this file changes no compiler or
# runtime behavior.
#
# The one piece of "re-evaluation" here is the M6 attribution question
# ("which fact source decides this ConditionOutcome?"): Attribution feeds
# the existing pure lattice primitives (hir::range::Narrowed / IsEmpty /
# CouldBeEqual / MustBeEqual / intersect / TypeFact) with *substituted*
# operand Ranges -- declared-type-only, view-type-only, entry-only, full --
# and reports the weakest tier that already decides the outcome. The
# production query itself (hir::range::ConditionOutcome) is called
# unmodified, and the full tier is cross-checked against it on every
# condition (a mismatch is reported as TOOL-MISMATCH, never silently).
#
#   source audit/m7a-instance-selection/tools/lib.tcl
#   set hir [m7a::load PATH]          ;# .bot (modules resolved) or .ir
#   set a   [m7a::analyze $hir]       ;# {spec ranges open refine}
#   puts [m7a::instances $hir $a]     ;# instance table
#   puts [m7a::conditions $hir $a]    ;# ConditionOutcome + attribution
#   puts [m7a::guards $hir $a]        ;# representation blockers, attributed

namespace eval m7a {
    variable root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
}
source [file join $m7a::root compiler compiler.tcl]
source [file join $m7a::root surface surface.tcl]
source [file join $m7a::root native native.tcl]
interp recursionlimit {} 100000

# The HIR of program PATH, non-strict (diagnostics are kept on the HIR and
# reported by callers, so an *illegal* program can still be inspected --
# exactly how the M4 List[never] fixture was observed).
proc m7a::load {path} {
    if {[file extension $path] eq ".bot"} {
        return [surface::readProgramFile $path -strict 0]
    }
    return [native::buildProgramHir [core::loadProgramFile $path]]
}

# HIR of Botlish source TEXT, written to a scratch file first so module
# references (byte::, char::, web::) resolve exactly as for a real file.
proc m7a::source {text {dir ""}} {
    if {$dir eq ""} {
        # A per-process temporary directory, never inside the repository.
        variable scratch
        if {![info exists scratch]} { set scratch [file tempdir m7a] }
        set dir $scratch
    }
    file mkdir $dir
    variable counter
    if {![info exists counter]} { set counter 0 }
    incr counter
    set path [file join $dir probe$counter.bot]
    set f [open $path w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $text
    close $f
    return [load $path]
}

proc m7a::diagnostics {hir} {
    return [lmap d [hir::diagnostics $hir] {
        list [dict get $d kind] [dict get $d message]
    }]
}

# The analyses native::lower::program runs, with its defaults.
proc m7a::analyze {hir args} {
    set options [dict merge {-specialize 1 -call-facts-opt 1} $args]
    set spec [hir::specialize::analyze $hir -specialize [dict get $options -specialize] \
        -call-facts-opt [dict get $options -call-facts-opt]]
    set ranges [hir::range::analyze $hir $spec [dict get $options -call-facts-opt]]
    set open [hir::range::OpenInstances $spec]
    set refine [expr {[dict get $options -specialize] ? [hir::specialize::RefinementFacts $hir] : {}}]
    return [dict create spec $spec ranges $ranges open $open refine $refine]
}

proc m7a::bindingName {hir b} {
    return [dict get [hir::binding $hir $b] name]
}

proc m7a::Where {hir e} {
    if {[catch {hir::aot::Location $hir [hir::get $hir $e origin]} loc] || $loc eq ""
            || ![dict exists $loc file]} {
        return "?"
    }
    return "[file tail [dict get $loc file]]:[dict get $loc line]"
}

# Instance IDs (used) whose block is named NAME (or all if NAME is "").
proc m7a::instancesOf {a name} {
    set spec [dict get $a spec]
    set result {}
    foreach id [dict get $spec used] {
        if {$name eq "" || [dict get $spec instances $id name] eq $name} {
            lappend result $id
        }
    }
    return $result
}

# The type the instance's view gives the first reachable ref of binding B
# (what region inference actually seeded -- key, declared, RefineParams).
proc m7a::ViewTypeOfBinding {hir a id b} {
    set spec [dict get $a spec]
    set block [dict get $spec instances $id block]
    set view [hir::specialize::view $hir $spec $id]
    foreach e [dict get $spec context exprs $block] {
        if {[hir::kind $view $e] eq "ref" && [hir::get $view $e binding] eq $b
                && [hir::get $view $e reachable]} {
            return [hir::typeOf $view $e]
        }
    }
    return ""
}

# One dict per used instance:
#   id label name block generic open key result
#   params  list of {name declared viewType entry refineEvidence}
#   seeds   captured binding name -> seed type
#   calls   list of {callExpr where targetLabel}
#   values  materialized block names
proc m7a::instanceData {hir a} {
    set spec [dict get $a spec]
    set ranges [dict get $a ranges]
    set open [dict get $a open]
    set refine [dict get $a refine]
    set out {}
    foreach id [dict get $spec used] {
        set inst [dict get $spec instances $id]
        set block [dict get $inst block]
        set d [dict create id $id label [hir::specialize::label $spec $id] name [dict get $inst name] \
            block $block generic [dict get $inst generic] open [dict exists $open $id] \
            key [lmap t [dict get $inst args] {hir::types::show $t}] \
            result [hir::types::show [dict get $inst result]] \
            resultRange [hir::range::show [dict get $ranges instances $id result]] \
            params {} seeds {} calls {} values {}]
        if {$block ne "program"} {
            set entries [dict get $ranges instances $id params]
            set params {}
            foreach b [hir::get $hir $block params] r $entries \
                    decl [hir::get $hir $block declaredParamTypes] {
                set vt [ViewTypeOfBinding $hir $a $id $b]
                set ev [expr {[dict exists $refine $block $b] ? [dict get $refine $block $b] : {}}]
                lappend params [dict create name [bindingName $hir $b] \
                    declared [expr {$decl eq {} ? "-" : [hir::types::show $decl]}] \
                    viewType [expr {$vt eq "" ? "(no reachable ref)" : [hir::types::show $vt]}] \
                    entry [hir::range::show $r] refineEvidence $ev]
            }
            dict set d params $params
            set seeds {}
            foreach {b t} [dict get $inst seeds] {
                lappend seeds [bindingName $hir $b] [hir::types::show $t]
            }
            dict set d seeds $seeds
        }
        set calls {}
        foreach {ce target} [dict get $inst calls] {
            lappend calls [list $ce [Where $hir $ce] [hir::specialize::label $spec $target]]
        }
        dict set d calls $calls
        dict set d values [lmap v [dict get $inst values] {
            set n [expr {[dict exists [dict get $spec context] names $v] ? [dict get $spec context names $v] : ""}]
            expr {$n eq "" ? "block $v" : $n}
        }]
        lappend out $d
    }
    return $out
}

proc m7a::instances {hir a {filter ""}} {
    set lines {}
    foreach d [instanceData $hir $a] {
        if {$filter ne "" && [dict get $d name] ni $filter} continue
        lappend lines "[dict get $d id] [dict get $d label]  generic=[dict get $d generic] open=[dict get $d open] key={[dict get $d key]} result=[dict get $d result] resultRange=[dict get $d resultRange]"
        foreach p [dict get $d params] {
            lappend lines "    param [dict get $p name]: declared=[dict get $p declared] view=[dict get $p viewType] entry=[dict get $p entry][expr {[dict get $p refineEvidence] ne {} ? " refineEvidence={[dict get $p refineEvidence]}" : ""}]"
        }
        if {[dict get $d seeds] ne ""} {
            lappend lines "    captures: [join [lmap {n t} [dict get $d seeds] {string cat $n : $t}] {, }]"
        }
        foreach c [dict get $d calls] {
            lassign $c ce where target
            lappend lines "    call $ce $where -> $target"
        }
        if {[dict get $d values] ne ""} {
            lappend lines "    materializes: [join [dict get $d values] {, }]"
        }
    }
    return [join $lines \n]
}

# ---------------------------------------------------------------------------
# ConditionOutcome attribution (M7.a spec #35-39)

# The comparison-outcome rule of hir::range::ConditionOutcome, applied to
# explicit operand Ranges RA/RB (never to the program): the same Narrowed/
# IsEmpty/CouldBeEqual/MustBeEqual primitives, called read-only.
proc m7a::OutcomeFrom {name ra rb} {
    if {$name eq "=="} {
        if {![hir::range::CouldBeEqual $ra $rb]} { return 0 }
        if {[hir::range::MustBeEqual $ra $rb]} { return 1 }
        return ""
    }
    if {$name ni {< <= > >=}} { return "" }
    if {[hir::range::IsEmpty [hir::range::Narrowed $name $ra $rb]]} { return 0 }
    set negated [dict get {< >= <= > > <= >= <} $name]
    if {[hir::range::IsEmpty [hir::range::Narrowed $negated $ra $rb]]} { return 1 }
    return ""
}

# {tier -> Range} for operand expression X of instance ID (VIEW its view):
#   identity  what the instance key alone gives (TypeFact of the key type --
#             always unknown today, since KeyType erases integer evidence)
#   declared  the block's own declared parameter type (param refs only)
#   view      TypeFact of the ref's view type (declared + RefineParams
#             evidence + any type-test refinement on this path)
#   entry     joined entry Range (params) intersected with the view fact --
#             what a ref sees with no comparison narrowing on its path
#   full      hir::range::of (includes path narrowing)
# A const operand is its point at every tier; any other non-param operand
# (local, call, arithmetic) is "expression": unknown below full.
proc m7a::OperandTiers {hir a id view x} {
    set spec [dict get $a spec]
    set ranges [dict get $a ranges]
    set full [hir::range::of $ranges $id $x]
    if {[hir::kind $view $x] eq "const"} {
        return [list kind const identity $full declared $full view $full entry $full full $full]
    }
    set unk [hir::range::unknown]
    set block [dict get $spec instances $id block]
    if {[hir::kind $view $x] eq "ref" && $block ne "program"} {
        set b [hir::get $view $x binding]
        set params [hir::get $hir $block params]
        set i [lsearch -exact $params $b]
        if {$i >= 0} {
            set keyType [lindex [dict get $spec instances $id args] $i]
            set identity [expr {[hir::types::IsSpecific $keyType] ? $unk : [hir::range::TypeFact $keyType]}]
            set decl [lindex [hir::get $hir $block declaredParamTypes] $i]
            set declared [expr {$decl eq {} || [hir::types::IsSpecific $decl] ? $unk : [hir::range::TypeFact $decl]}]
            set viewFact [hir::range::TypeFact [hir::typeOf $view $x]]
            set entry [hir::range::intersect [lindex [dict get $ranges instances $id params] $i] $viewFact]
            return [list kind param identity $identity declared $declared view $viewFact entry $entry full $full]
        }
        if {[dict get [hir::binding $view $b] kind] ni {local param}} {
            return [list kind other identity $unk declared $unk view $unk entry $unk full $full]
        }
        # A captured binding (another block's local/param): region range
        # analysis never seeds it (unknown), so only its view type counts.
        if {[lsearch -exact [hir::get $hir $block captures] $b] >= 0} {
            set viewFact [hir::range::TypeFact [hir::typeOf $view $x]]
            return [list kind capture identity $unk declared $unk view $viewFact entry $viewFact full $full]
        }
        return [list kind local identity $unk declared $unk view $unk entry $unk full $full]
    }
    return [list kind expression identity $unk declared $unk view $unk entry $unk full $full]
}

# Every reachable `if` of every used instance: its condition, the production
# ConditionOutcome answer, and the weakest fact tier deciding it.
proc m7a::conditionData {hir a {names ""}} {
    set spec [dict get $a spec]
    set ranges [dict get $a ranges]
    set out {}
    foreach id [dict get $spec used] {
        set inst [dict get $spec instances $id]
        if {$names ne "" && [dict get $inst name] ni $names} continue
        set block [dict get $inst block]
        set view [hir::specialize::view $hir $spec $id]
        foreach e [dict get $spec context exprs $block] {
            if {[hir::kind $view $e] ne "if" || ![hir::get $view $e reachable]} continue
            set cond [hir::get $view $e condition]
            set outcome [hir::range::ConditionOutcome $view $ranges $id $cond]
            set text [ConditionText $view $cond]
            set known [hir::types::KnownOutcome $view $cond]
            set d [dict create id $id label [hir::specialize::label $spec $id] if $e \
                where [Where $hir $e] condition $text outcome $outcome decidedBy "" operands {}]
            if {$known ne ""} {
                dict set d decidedBy syntactic
                lappend out $d
                continue
            }
            set node [hir::node $view $cond]
            if {[dict get $node kind] ne "call" || [lindex [dict get $node target] 0] ne "native"
                    || [llength [dict get $node args]] != 2} {
                dict set d decidedBy [expr {$outcome eq "" ? "not-a-comparison" : "TOOL-MISMATCH"}]
                lappend out $d
                continue
            }
            set name [dict get [hir::symbol $view [lindex [dict get $node target] 1]] name]
            lassign [dict get $node args] ea eb
            set ta [OperandTiers $hir $a $id $view $ea]
            set tb [OperandTiers $hir $a $id $view $eb]
            dict set d operands [list [dict get $ta kind] [hir::range::show [dict get $ta full]] \
                [dict get $tb kind] [hir::range::show [dict get $tb full]]]
            # The weakest tier whose facts already give the production
            # answer. Tiers are *expected* to strengthen monotonically
            # (identity <= declared <= view <= entry <= full), but they
            # need not: a join after an impossible branch can leave the
            # path-level ("full") fact weaker than the entry fact (S11).
            # A tier that decides while the production answer is Unknown
            # is reported as "lost-after-TIER", and one that contradicts
            # the production answer as CONTRADICTION -- never silently.
            set decided ""
            foreach tier {identity declared view entry full} {
                set o [OutcomeFrom $name [dict get $ta $tier] [dict get $tb $tier]]
                if {$o eq ""} continue
                if {$o eq $outcome} {
                    set decided $tier
                } elseif {$outcome eq ""} {
                    set decided "lost-after-$tier"
                } else {
                    set decided "CONTRADICTION($tier=$o)"
                }
                break
            }
            set fullAnswer [OutcomeFrom $name [dict get $ta full] [dict get $tb full]]
            if {$fullAnswer ne $outcome} {
                set decided "TOOL-MISMATCH(full=$fullAnswer)"
            }
            if {$name ni {< <= > >= ==}} {
                set decided [expr {$outcome eq "" ? "not-a-comparison($name)" : "TOOL-MISMATCH"}]
            }
            dict set d decidedBy [expr {$decided eq "" ? "undecided" : $decided}]
            lappend out $d
        }
    }
    return $out
}

proc m7a::ConditionText {hir e} {
    set node [hir::node $hir $e]
    switch -- [dict get $node kind] {
        const { return [core::formatValue [dict get $node value]] }
        ref {
            set b [dict get $node binding]
            return [expr {$b eq "" ? "?" : [bindingName $hir $b]}]
        }
        call {
            lassign [dict get $node target] kind target
            if {$kind eq "native"} {
                set callee [dict get [hir::symbol $hir $target] name]
            } elseif {$kind eq "block"} {
                set callee [hir::aot::BlockName $hir $target]
            } else {
                set callee "<dynamic>"
            }
            return "$callee\([join [lmap x [dict get $node args] {ConditionText $hir $x}] {, }])"
        }
    }
    return "<[dict get $node kind]>"
}

proc m7a::conditions {hir a {names ""}} {
    set lines {}
    foreach d [conditionData $hir $a $names] {
        set o [dict get $d outcome]
        set shown [expr {$o eq "" ? "Unknown" : ($o ? "AlwaysTrue" : "AlwaysFalse")}]
        lappend lines [format "%-5s %-34s %-10s if %-40s -> %-11s via %s  %s" [dict get $d id] \
            [dict get $d label] [dict get $d where] [dict get $d condition] $shown \
            [dict get $d decidedBy] [expr {[dict get $d operands] eq "" ? "" : "operands={[dict get $d operands]}"}]]
    }
    return [join $lines \n]
}

# ---------------------------------------------------------------------------
# Representation-blocker (guard) attribution

# One dict per representation blocker in a used instance:
#   id label kind cause binding bindingKind where message
#   param: declared keyType viewType entry open
#   capture: 1 if the blocked binding is captured by the region
proc m7a::guardData {hir a} {
    set spec [dict get $a spec]
    set ranges [dict get $a ranges]
    set open [dict get $a open]
    set regions [hir::specialize::regions $hir $spec]
    set out {}
    foreach id [dict get $spec used] {
        set region [dict get $regions $id]
        set inst [dict get $spec instances $id]
        set block [dict get $inst block]
        set params [expr {$block eq "program" ? {} : [hir::get $hir $block params]}]
        set captures [expr {$block eq "program" ? {} : [hir::get $hir $block captures]}]
        foreach blocker [dict get $region blockers] {
            if {[dict get $blocker class] ne "representation"} continue
            set cause [dict get $blocker cause]
            set b [dict get $cause binding]
            set d [dict create id $id label [hir::specialize::label $spec $id] name [dict get $inst name] \
                generic [dict get $inst generic] open [dict exists $open $id] \
                kind [dict get $blocker kind] cause [dict get $cause cause] \
                requires [dict get $blocker requires] where [Where $hir [dict get $blocker expr]] \
                binding "" role "" declared "" keyType "" viewType "" entry "" \
                message [dict get $blocker message]]
            if {$b ne ""} {
                dict set d binding [bindingName $hir $b]
                set i [lsearch -exact $params $b]
                if {$i >= 0} {
                    set decl [lindex [hir::get $hir $block declaredParamTypes] $i]
                    set vt [ViewTypeOfBinding $hir $a $id $b]
                    dict set d role param
                    dict set d declared [expr {$decl eq {} ? "-" : [hir::types::show $decl]}]
                    dict set d keyType [hir::types::show [lindex [dict get $inst args] $i]]
                    dict set d viewType [expr {$vt eq "" ? "-" : [hir::types::show $vt]}]
                    dict set d entry [hir::range::show [lindex [dict get $ranges instances $id params] $i]]
                    # Call-site facts: the static type every exact call
                    # resolved to this instance passes at parameter I (in
                    # its own caller's view), and their kind join -- what an
                    # entry-kind theorem could at best establish if the
                    # instance's caller set were closed.
                    set siteTypes {}
                    set joined never
                    foreach caller [dict get $spec used] {
                        set cview ""
                        foreach {ce target} [dict get $spec instances $caller calls] {
                            if {$target ne $id} continue
                            if {$cview eq ""} { set cview [hir::specialize::view $hir $spec $caller] }
                            if {![hir::get $cview $ce reachable]} continue
                            set arg [lindex [hir::get $cview $ce args] $i]
                            set t [hir::typeOf $cview $arg]
                            set self [expr {$caller eq $id && [hir::kind $cview $arg] eq "ref" && [hir::get $cview $arg binding] eq $b}]
                            lappend siteTypes "[hir::specialize::label $spec $caller]:[expr {$self ? {(forward)} : [hir::types::show $t]}]"
                            if {!$self} { set joined [hir::types::lub $joined $t] }
                        }
                    }
                    dict set d callSites $siteTypes
                    dict set d callSiteJoin [hir::types::show $joined]
                    dict set d callSiteKind [hir::types::kindOf $joined]
                } elseif {$b in $captures} {
                    dict set d role capture
                    set seeds [dict get $inst seeds]
                    dict set d viewType [expr {[dict exists $seeds $b] ? [hir::types::show [dict get $seeds $b]] : "-"}]
                } else {
                    dict set d role local
                }
            }
            lappend out $d
        }
    }
    return $out
}

proc m7a::guards {hir a} {
    set lines {}
    foreach d [guardData $hir $a] {
        lappend lines [format "%-5s %-38s %-10s %-22s cause=%-16s binding=%s(%s) requires=%s key=%s declared=%s view=%s entry=%s open=%s" \
            [dict get $d id] [dict get $d label] [dict get $d where] [dict get $d kind] [dict get $d cause] \
            [dict get $d binding] [dict get $d role] [dict get $d requires] [dict get $d keyType] \
            [dict get $d declared] [dict get $d viewType] [dict get $d entry] [dict get $d open]]
        if {[dict exists $d callSites]} {
            lappend lines "        call-site arg types: [expr {[dict get $d callSites] eq {} ? {(no exact caller)} : [join [dict get $d callSites] {; }]}]  => join [dict get $d callSiteJoin] (kind [expr {[dict get $d callSiteKind] eq {} ? {none} : [dict get $d callSiteKind]}])"
        }
    }
    return [join $lines \n]
}

# ---------------------------------------------------------------------------
# NIR helpers

proc m7a::nir {hir args} {
    return [dict get [native::lower::program $hir {*}$args] text]
}

# NAME<instance> -> dict of counted NIR opcodes (guard, br, call, callenv,
# callvalue, fail, faildeclared, closure, capture, tail, tailenv, op:*)
proc m7a::nirCounts {nirText} {
    set funcs [dict create]
    set current ""
    foreach line [split $nirText \n] {
        if {[regexp {^func (\d+) "([^"]*)" params=(\d+) env=(\d+) regs=(\d+) .*?instance="([^"]*)"} $line -> fid name np envFlag regs inst]} {
            set current "$fid $name<$inst>"
            dict set funcs $current [dict create regs $regs env $envFlag]
            continue
        }
        if {$line eq "end"} { set current ""; continue }
        if {$current eq ""} continue
        set l [string trim $line]
        set key ""
        if {[regexp {^guard } $l]} { set key guard }
        if {[regexp {^guardbool } $l]} { set key guardbool }
        if {[regexp {= op (\w+)} $l -> op]} { set key "op:$op" }
        if {[regexp {= (call|callenv|callvalue|callmulti|callenvmulti) } $l -> c]} { set key $c }
        if {[regexp {^(tail|tailenv|fail|faildeclared|unreachable) ?} $l -> k]} { set key $k }
        if {[regexp {= (closure|capture|fnvalue) ?} $l -> k]} { set key $k }
        if {[regexp {^br } $l]} { set key br }
        if {$key ne ""} {
            set c [dict get $funcs $current]
            dict incr c $key
            dict set funcs $current $c
        }
    }
    return $funcs
}

# ---------------------------------------------------------------------------
# Census (tools/corpus.tcl, tools/counterfactual.tcl)

proc m7a::W {outdir name content} {
    set f [open [file join $outdir $name] w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $content
    close $f
}

# Writes instances/conditions/guards/functions/summary .txt for PATH into
# OUTDIR (see tools/corpus.tcl's header); returns the summary text.
proc m7a::census {path outdir} {

    file mkdir $outdir

    set hir [m7a::load $path]
    set a [m7a::analyze $hir]
    set spec [dict get $a spec]

    m7a::W $outdir instances.txt "[m7a::instances $hir $a]\n"
    m7a::W $outdir conditions.txt "[m7a::conditions $hir $a]\n"
    m7a::W $outdir guards.txt "[m7a::guards $hir $a]\n"

    set lowered [native::lower::program $hir]
    set nirText [dict get $lowered text]
    set counts [m7a::nirCounts $nirText]
    lassign [native::codeSize $hir] total perFunction
    set out {}
    set i 0
    set totals [dict create]
    foreach f [dict keys $counts] {
        set c [dict get $counts $f]
        set bytes [lindex $perFunction $i]
        incr i
        foreach k {guard guardbool br fail faildeclared call callenv callvalue callmulti callenvmulti tail tailenv closure capture} {
            if {[dict exists $c $k]} { dict incr totals $k [dict get $c $k] }
        }
        append out [format "%-52s bytes=%-5s %s\n" $f $bytes [join [lmap {k v} $c {string cat $k = $v}] " "]]
    }
    m7a::W $outdir functions.txt $out

    set used [dict get $spec used]
    set generic 0
    set specialized 0
    set open 0
    foreach id $used {
        if {[dict get $spec instances $id block] eq "program"} continue
        if {[dict get $spec instances $id generic]} { incr generic } else { incr specialized }
        if {[dict exists [dict get $a open] $id]} { incr open }
    }
    set guardData [m7a::guardData $hir $a]
    set byRole [dict create]
    foreach g $guardData {
        dict incr byRole "[expr {[dict get $g generic] ? {generic} : {specialized}}]/[dict get $g role]/[dict get $g kind]"
    }
    set conds [m7a::conditionData $hir $a]
    set byOutcome [dict create]
    foreach c $conds {
        set o [dict get $c outcome]
        dict incr byOutcome "[expr {$o eq {} ? {Unknown} : ($o ? {AlwaysTrue} : {AlwaysFalse})}] via [dict get $c decidedBy]"
    }
    set s "program: $path\n"
    append s "used instances: [llength $used] (program + $generic generic + $specialized specialized); open: $open\n"
    append s "emitted NIR functions: [dict size $counts]; machine code bytes: $total\n"
    append s "NIR totals: [join [lmap {k v} $totals {string cat $k = $v}] { }]\n"
    append s "representation blockers (guards): [llength $guardData]\n"
    dict for {k v} $byRole { append s "    $k: $v\n" }
    append s "reachable ifs in used instances: [llength $conds]\n"
    dict for {k v} $byOutcome { append s "    $k: $v\n" }
    append s "static diagnostics: [llength [hir::diagnostics $hir]]\n"
    if {[catch {native::evalHir $hir} value]} {
        set value "ERROR: $value"
    }
    append s "native run value: [string range $value 0 200]\n"
    if {[catch {native::allocationReport $hir summary 1} report]} {
        append s "allocations (one run): ERROR: $report\n"
    } else {
        set t [dict get $report total]
        append s "allocations (one run): [dict get $t allocations] objects / [dict get $t allocatedBytes] bytes"
        foreach kind {String List Block Cell BigInt Result} {
            set k [dict get $report byKind $kind]
            if {[dict get $k allocations]} { append s " $kind=[dict get $k allocations]" }
        }
        append s " static=[dict get [dict get $report static] allocations]\n"
    }
    m7a::W $outdir summary.txt $s
    return $s
}

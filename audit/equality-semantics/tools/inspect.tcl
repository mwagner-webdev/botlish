# inspect.tcl -- what the compiler knows about one program's comparisons,
# functions and calls (EQUALITY-SEMANTIC-CENSUS.md).
#
#   tclsh9.0 audit/equality-semantics/tools/inspect.tcl ?-semantic 0|1?
#       ?-max-per-block N? ?-max-instances N? PROGRAM.bot
#
# Compiles PROGRAM strict (warnings off); when that rejects it, prints the
# strict diagnostics and compiles it again with -strict 0 to inspect what
# the lenient build typed. Then prints, from the HIR:
#
#   fn       every function with a name: each parameter's declared type,
#            trusted inferred contract, checked inferred contract and the
#            provenance of the checked one (hir::signatures::of)
#   ==       every call of the root native `==`: its location, the static
#            types of its operands, their equality totality
#            (hir::types::Totality), the native operation native lowering
#            would choose (native::lower::NativeCallOp's rule, restated), and
#            the candidate relations of lib.tcl
#   call     every call whose target is a block: the callee, the target,
#            the semantic instance it uses (or why it was declined)
#   inst     every semantic instance the program uses: its function, entry
#            types, status (valid | invalid) and diagnostics, and the
#            operand types of each `==` in its region
#
# -semantic 0 turns semantic instances off (hir::semantic::enabled, a
# measurement switch of the compiler's own); -max-per-block and
# -max-instances set hir::semantic's budgets for this process. Nothing is
# written.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -semantic 1 -max-per-block "" -max-instances ""]
set args $argv
set program ""
while {[llength $args]} {
    set args [lassign $args arg]
    if {[dict exists $options $arg]} {
        set args [lassign $args value]
        dict set options $arg $value
    } else {
        set program [file normalize $arg]
    }
}
set ::argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join [file dirname [file normalize [info script]]] lib.tcl]
set hir::semantic::enabled [dict get $options -semantic]
if {[dict get $options -max-per-block] ne ""} {
    set hir::semantic::maxPerBlock [dict get $options -max-per-block]
}
if {[dict get $options -max-instances] ne ""} {
    set hir::semantic::maxInstances [dict get $options -max-instances]
}

proc Loc {hir e} {
    set origin [dict get $hir exprs $e origin]
    if {[dict exists $origin line]} {
        return "[dict get $origin line]:[dict get $origin column]"
    }
    return "?"
}

proc Show {t} {
    if {$t eq ""} { return "-" }
    return [hir::types::show $t]
}

proc NativeOp {hir a b} {
    set ta [hir::typeOf $hir $a]
    set tb [hir::typeOf $hir $b]
    set ka [hir::types::kindOf $ta]
    set kb [hir::types::kindOf $tb]
    if {$ka eq $kb} {
        switch -- $ka {
            int { return ieq }
            str { return streq }
            UnicodeChar { return chareq }
            enum { return enumeq }
            Float64 { return f64eq }
        }
    }
    if {[hir::types::IsEqualityTotal $ta] && [hir::types::IsEqualityTotal $tb]} {
        return veqtotal
    }
    return veq
}

proc Relations {a b} {
    return "head=[lindex [eqcensus::Head $a $b] 0] overlap=[join [eqcensus::Overlap $a $b] {: }] structural=[lindex [eqcensus::Structural $a $b] 0] kinded=[lindex [eqcensus::Kinded $a $b] 0] related=[eqcensus::Related $a $b] defined=[join [eqcensus::Defined $a $b] {: }]"
}

proc EqSites {hir region} {
    set out {}
    foreach e $region {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] ne "call"} continue
        lassign [dict getdef $node target {}] kind target
        if {$kind ne "native" || [dict get [hir::symbol $hir $target] name] ne "=="} continue
        lappend out $e
    }
    return $out
}

set strictError ""
if {[catch {surface::readProgramFile $program -warnings off} hir opts]} {
    set strictError $hir
    puts "strict: REJECTED"
    if {[dict exists $opts -diagnostics]} {
        foreach d [dict get $opts -diagnostics] {
            puts "  diag [dict getdef $d code ?] [dict getdef $d location ?]: [dict getdef $d message [dict getdef $d summary ?]]"
        }
    } else {
        puts "  [lindex [split $hir \n] 0]"
    }
    if {[catch {surface::readProgramFile $program -warnings off -strict 0} hir]} {
        puts "lenient: REJECTED: [lindex [split $hir \n] 0]"
        exit 0
    }
    puts "lenient build:"
    foreach d [dict get $hir diagnostics] {
        puts "  diag [dict get $d kind] [Loc $hir [dict get $d expr]]: [dict get $d message]"
    }
} else {
    puts "strict: accepted"
}

# Functions.
dict for {e node} [dict get $hir exprs] {
    if {[dict get $node kind] ne "block"} continue
    set name [hir::semantic::CallableName $hir $e]
    if {$name eq ""} continue
    set origin [dict get $node origin]
    if {[dict exists $origin file] && [dict exists $hir files [dict get $origin file]]
            && [dict get $hir files [dict get $origin file] path] ne $program} continue
    set sig [hir::signatures::of $hir $e]
    set parts {}
    foreach p [dict get $sig params] {
        set why ""
        foreach w [dict get $p why] {
            if {[dict exists $w type]} {
                append why " <[dict get $w kind] [Show [dict get $w type]]: [dict getdef $w what ?]>"
            }
        }
        lappend parts "[dict get $p name] declared=[Show [dict get $p declared]] trusted=[Show [dict get $p trusted]] checked=[Show [dict get $p checked]]$why"
    }
    puts "fn $name ($e) result=[Show [dict get $sig result]]"
    foreach part $parts { puts "    $part" }
}

# Equality sites of the program's own files.
foreach e [EqSites $hir [dict keys [dict get $hir exprs]]] {
    set node [dict get $hir exprs $e]
    set origin [dict get $node origin]
    if {[dict exists $origin file] && [dict exists $hir files [dict get $origin file]]
            && [dict get $hir files [dict get $origin file] path] ne $program} continue
    lassign [dict get $node args] a b
    set ta [hir::typeOf $hir $a]
    set tb [hir::typeOf $hir $b]
    puts "== [Loc $hir $e] ($e) [Show $ta] vs [Show $tb] reachable=[dict getdef $node reachable 1] known=[dict getdef $node known {}]"
    puts "    totality [lindex [hir::types::Totality equality $ta] 0]/[lindex [hir::types::Totality equality $tb] 0] op=[NativeOp $hir $a $b]"
    puts "    [Relations $ta $tb]"
}

# Calls with a block target.
set semantic [dict getdef $hir semantic {}]
dict for {e node} [dict get $hir exprs] {
    if {[dict get $node kind] ne "call"} continue
    set origin [dict get $node origin]
    if {[dict exists $origin file] && [dict exists $hir files [dict get $origin file]]
            && [dict get $hir files [dict get $origin file] path] ne $program} continue
    lassign [dict getdef $node target {}] kind target
    set calleeType [hir::typeOf $hir [dict get $node callee]]
    if {$kind ne "block" && ![hir::types::IsFn $calleeType]} continue
    set label ""
    if {$kind eq "block"} {
        set label [hir::semantic::CallableName $hir $target]
    }
    set inst -
    if {$semantic ne {} && [dict exists $semantic calls [list generic $e]]} {
        set inst [dict get $semantic calls [list generic $e]]
    } elseif {$semantic ne {} && [dict exists $semantic declined [list generic $e]]} {
        set inst "declined:[dict get $semantic declined [list generic $e]]"
    }
    puts "call [Loc $hir $e] ($e) target=[expr {$kind eq "" ? "none" : "$kind $target"}] $label callee=[Show $calleeType] args=[join [lmap a [dict get $node args] {Show [hir::typeOf $hir $a]}] {, }] instance=$inst"
}

# Instances.
if {$semantic ne {} && [dict exists $semantic used]} {
    set status [dict create]
    foreach pair [dict getdef $semantic status {}] {
        dict set status {*}$pair
    }
    foreach id [dict get $semantic used] {
        set inst [dict get $semantic instances $id]
        puts "inst $id [hir::semantic::Label $hir $id]([hir::semantic::Environment $hir $id]) status=[dict getdef $status $id ?] result=[Show [dict get $inst result]]"
        foreach d [dict getdef $semantic diagnostics $id {}] {
            puts "    diag [dict get $d kind]: [dict get $d message]"
        }
        set view [hir::semantic::View $hir $id]
        foreach e [EqSites $view [hir::semantic::Region $view [dict get $inst block]]] {
            lassign [dict get $view exprs $e args] a b
            set ta [hir::typeOf $view $a]
            set tb [hir::typeOf $view $b]
            puts "    == [Loc $view $e] [Show $ta] vs [Show $tb] op=[NativeOp $view $a $b] [Relations $ta $tb]"
        }
    }
    puts "semantic: requests=[dict get $semantic requests] instances=[dict size [dict get $semantic instances]] declined=[dict get $semantic declinedCount]"
}

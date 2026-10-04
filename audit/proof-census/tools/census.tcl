# census.tcl -- per-call proof observations for PROOF-FACT-CENSUS.md.
#
#   tclsh9.0 audit/proof-census/tools/census.tcl ?-nir? ?-clif FUNC? PROGRAM.bot...
#
# Observation only: nothing here changes the compiler. For each program it
# compiles the source exactly as main.tcl does (surface::readProgramFile,
# -strict 0 so rejected programs are still inspectable, warnings off), then
# prints:
#
#   * the static diagnostics (kind + message head) -- the legality outcome
#     the completion proof produced;
#   * every call whose callee declares errors (an error-declaring native or
#     an exact Botlish block): its declared errors, the effectiveErrors /
#     mayReturnNormally the completion proof stored on the HIR node (the
#     generic, once-per-function-body walk: hir/completions.tcl
#     CheckCallLegality), and, for every specialization instance that
#     contains the call, each argument's hir::range fact (the codegen-facing
#     interprocedural Range fixpoint, hir/rangerec.tcl hir::range::analyze);
#   * with -nir, the NIR lines native lowering emitted for each such call
#     (matched by the @eN source tag), per function;
#   * with -clif FUNC, the Cranelift IR of the function whose name matches.
#
# Run from the repository root, LANG=C.utf8 LC_ALL=C.utf8, Tcl 9.0.1, with
# the release native backend built for -clif.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set showNir 0
set clifFunc ""
set paths {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    switch -- $a {
        -nir { set showNir 1 }
        -clif { incr i; set clifFunc [lindex $argv $i] }
        default { lappend paths $a }
    }
}

proc CalleeLabel {hir e} {
    lassign [hir::get $hir $e target] kind target
    switch -- $kind {
        native { return "native [dict get [hir::symbol $hir $target] name]" }
        block {
            set callee [hir::get $hir $e callee]
            set name ?
            if {[hir::kind $hir $callee] eq "ref"} { set name [hir::get $hir $callee name] }
            return "block $target ($name)"
        }
        default { return "$kind $target" }
    }
}

proc DeclaredErrors {hir e} {
    lassign [hir::get $hir $e target] kind target
    switch -- $kind {
        native {
            set meta [core::native::metadata [dict get [hir::symbol $hir $target] name]]
            if {[dict exists $meta errors]} { return [dict get $meta errors] }
            return {}
        }
        block {
            set node [hir::node $hir $target]
            if {[dict exists $node declaredErrors]} { return [dict get $node declaredErrors] }
            return {}
        }
    }
    return {}
}

proc Census {path} {
    global showNir clifFunc
    puts "=== [file tail $path]"
    set hir [surface::readProgramFile $path -strict 0 -warnings off]
    set diags [hir::diagnostics $hir]
    if {$diags eq ""} {
        puts "diagnostics: none"
    }
    foreach d $diags {
        set msg [dict get $d message]
        if {[string length $msg] > 150} { set msg "[string range $msg 0 149]..." }
        puts "diagnostic [dict get $d kind] at [dict get $d expr]: $msg"
    }
    set prepared [native::prepareHir $hir]
    if {[catch {
        set spec [hir::specialize::analyze $prepared]
        set ranges [hir::range::analyze $prepared $spec]
    } message]} {
        puts "analysis error: $message"
        return
    }
    # Which instances contain which call expression.
    set callsIn {}
    foreach id [dict get $spec used] {
        set view [hir::specialize::view $prepared $spec $id]
        foreach e [hir::walk $view] {
            if {[hir::kind $view $e] eq "call"} {
                dict lappend callsIn $e $id
            }
        }
    }
    # The prepared HIR: native::prepareHir attaches the bodies of
    # module-backed natives (lib/web.bot's emailish?, ...) that native
    # lowering compiles, so their calls are listed too.
    set hir $prepared
    foreach e [lsort -dictionary [dict keys [dict get $hir exprs]]] {
        if {[hir::kind $hir $e] ne "call"} continue
        set declared [DeclaredErrors $hir $e]
        if {$declared eq ""} continue
        set node [hir::node $hir $e]
        set eff [expr {[dict exists $node effectiveErrors] ? "{[dict get $node effectiveErrors]}" : "(not reached)"}]
        set normal [expr {[dict exists $node mayReturnNormally] ? [dict get $node mayReturnNormally] : "-"}]
        puts "call $e [CalleeLabel $hir $e]: declared {$declared} effective $eff mayReturnNormally $normal"
        if {[dict exists $callsIn $e]} {
            foreach id [dict get $callsIn $e] {
                # Only instances whose own analysis reached this call (an
                # enclosing instance's view also lists nested bodies).
                if {![dict exists [dict get $ranges instances $id] exprs $e]} continue
                set view [hir::specialize::view $prepared $spec $id]
                set args [hir::get $view $e args]
                set shown [lmap a $args {hir::range::show [hir::range::of $ranges $id $a]}]
                puts "    instance $id ([hir::specialize::label $spec $id]) arg ranges: [join $shown { | }]"
            }
        }
    }
    if {$showNir} {
        set nir [native::nir $prepared]
        set func ""
        foreach line [split $nir \n] {
            if {[regexp {^func \d+ "([^"]*)".*instance="([^"]*)"} $line -> name inst]} {
                set func "$name<$inst>"
                continue
            }
            if {[regexp {@(e\d+)\s*$} $line -> tag]} {
                set n [hir::node $hir $tag]
                if {[dict get $n kind] eq "call" && [DeclaredErrors $hir $tag] ne ""} {
                    puts "nir $func: [string trim $line]"
                }
            }
        }
    }
    if {$clifFunc ne ""} {
        set clif [native::clif $prepared]
        puts $clif
    }
}

foreach path $paths {
    Census $path
}

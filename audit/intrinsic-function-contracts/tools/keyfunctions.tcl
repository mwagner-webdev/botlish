#!/usr/bin/env tclsh9.0
# keyfunctions.tcl -- INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md's per-
# function before/after record (spec items 39, 52-55): for each key function
# of the canonical benchmarks, in the relifted pipeline bench/bench.tcl
# compiles (native::buildProgramHir [hir::lower ...], so web::emailish?'s
# helpers are present through the module-native bridge),
#
#   * the source/intrinsic signature (hir::signatures, when the tree has it)
#   * the exact Block type of the function's own binding and its canonical
#     structural supertype (structuralOf)
#   * every used specialization instance: its label, AOT status (hir::aot
#     via hir::specialize::regions), seeded parameter types and result
#
# Runs against whatever tree it is started in (the parent commit has no
# hir::signatures: every untyped parameter is reported as any there).
#
#   (cd TREE && tclsh9.0 audit/intrinsic-function-contracts/tools/keyfunctions.tcl OUTFILE)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv out
set haveSignatures [llength [info commands ::hir::signatures::of]]

proc show {t} { return [hir::types::show $t] }

proc blockNamed {hir name} {
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding name] ne $name || [dict get $binding kind] ne "local"} continue
        set d [dict get $binding declaredBy]
        if {$d eq ""} continue
        set v [hir::get $hir $d value]
        if {[hir::kind $hir $v] eq "block"} { return [list $b $v] }
    }
    return ""
}

set L {}
lappend L "tree: [exec git -C $root rev-parse HEAD] (plus any uncommitted working-tree changes)"
foreach {program names} {
    refined-checks {scan_while local_char? label_char? tld? domain? char_at web::emailish?}
    uri-steady {scan_while local_char?}
    lex-strategy {lenient_ident_char? choose_classifier classify}
    source-checks {is_underscore? is_hyphen? classify_leading}
    test-selection {make_changed? affected?}
} {
    set hir [native::buildProgramHir [hir::lower [surface::readProgramFile [file join $root bench $program.bot]]]]
    set spec [hir::specialize::analyze $hir]
    set regions [hir::specialize::regions $hir $spec]
    lappend L "" "== bench/$program.bot"
    foreach name $names {
        set found [blockNamed $hir $name]
        if {$found eq ""} { lappend L "  $name: (not in this program's HIR)"; continue }
        lassign $found b e
        lappend L "  $name ($e)"
        if {$haveSignatures} {
            set sig [hir::signatures::of $hir $e]
            set ps [lmap p [dict get $sig params] {
                set kind [expr {[dict get $p source] ne "inferred" ? "" : [dict get $p trusted] ne "" ? ", trusted" : ", checked"}]
                string cat [dict get $p name] ": " [show [hir::signatures::paramType $p]] " ([dict get $p source]$kind)"
            }]
            lappend L "    intrinsic signature: ([join $ps {, }]) -> [show [dict get $sig result]] errors \[[join [dict get $sig errors] {, }]\]"
            foreach p [dict get $sig params] {
                foreach line [hir::signatures::explain $hir $p] { lappend L "        [dict get $p name] <- $line" }
            }
        } else {
            set ps [lmap pb [hir::get $hir $e params] d [hir::get $hir $e declaredParamTypes] {
                string cat [dict get $hir bindings $pb name] ": " [expr {$d eq {} ? "any (untyped)" : "[show $d] (declared)"}]
            }]
            lappend L "    signature: ([join $ps {, }]) -> [show [hir::type $hir [hir::get $hir $e resultType]]]"
        }
        set exact [hir::bindingType $hir $b]
        lappend L "    exact Block type: [show $exact]; structuralOf: [show [hir::types::structuralOf $exact]]"
        foreach id [dict get $spec used] {
            set inst [hir::specialize::instance $spec $id]
            if {[dict get $inst block] ne $e} continue
            set region [dict get $regions $id]
            set params [join [lmap p [dict get $region params] {string cat [dict get $p name] " : " [show [dict get $p type]]}] {, }]
            lappend L "    instance [dict get $region label]: [dict get $region status] (transitively [dict get $region transitive]); params: $params; result: [show [dict get $inst result]]"
            set blockers [dict get $region blockers]
            foreach blocker $blockers {
                lappend L "        blocker: [dict get $blocker kind] [dict get $blocker message]"
            }
        }
    }
}
set f [open $out w]
fconfigure $f -encoding utf-8
puts $f [join $L \n]
close $f
puts "wrote $out"

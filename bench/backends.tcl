# backends.tcl -- backend identity for benchmark reports.
#
# NATIVE-AUDIT.md's Appendix E documents the mistake this module exists to
# prevent: "compile" in a benchmark table is bench.tcl's Tcl-generated-code
# backend (compiler/compiler.tcl), not Cranelift, and was misread as native
# machine-code execution. This module is the one place bench.tcl gets a
# column's display name and timing-scope description from, so no report can
# repeat that mistake by construction.
#
#   bench::backends::displayName ID     unambiguous label for column ID
#   bench::backends::manifest IDS       a self-explanatory "Backends:" block
#                                       describing every one of IDS, meant
#                                       to head a report read later with no
#                                       repository context

namespace eval bench::backends {
    # Internal id (core::useBackend's names, or bench.tcl's own "native") ->
    # display name. Never bare "compile" or "native": both read, out of
    # context, as "the compiled/native backend", which is exactly the
    # ambiguity NATIVE-AUDIT.md flagged.
    variable names [dict create \
        interp  "Tcl interp" \
        compile "Tcl compile" \
        native  "Cranelift" \
        python  "Python" \
        rust    "Rust"]

    # Internal id -> {what it is, and what a timed number in its column
    # scopes to}. Every description says in-process execution (bench.tcl
    # times no backend as subprocess wall time: the Tcl backends run
    # core::evalProgram in this same process, and native::measure -- see
    # native/native.tcl -- spawns one subprocess that starts timing only
    # after Cranelift has already JIT-compiled, so the timed region is
    # in-process execution there too); Cranelift's says so explicitly since
    # it is the one column where compile time is a real, separate cost that
    # could otherwise be conflated with it.
    variable descriptions [dict create \
        interp  "semantic interpreter -- in-process execution" \
        compile "Tcl source/codegen backend (not Cranelift) -- in-process execution" \
        native  "Cranelift native machine-code backend -- in-process execution, JIT compile time excluded" \
        python  "reference implementation -- in-process execution" \
        rust    "reference implementation -- in-process execution"]
}

# The unambiguous display name of internal backend/column id ID: ID itself
# if this module has no mapping for it, rather than showing nothing.
proc bench::backends::displayName {id} {
    variable names
    if {[dict exists $names $id]} {
        return [dict get $names $id]
    }
    return $id
}

# A "Backends:" block naming and describing every one of IDS, one line each,
# meant to head a benchmark report so it stays self-explanatory when read
# later without this repository open alongside it.
proc bench::backends::manifest {ids} {
    variable descriptions
    set lines {Backends:}
    foreach id $ids {
        set desc [expr {[dict exists $descriptions $id] ? [dict get $descriptions $id] : ""}]
        lappend lines [format "  %-11s %s" [displayName $id] $desc]
    }
    return [join $lines \n]
}

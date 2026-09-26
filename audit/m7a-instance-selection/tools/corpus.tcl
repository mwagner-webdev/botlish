#!/usr/bin/env tclsh9.0
# corpus.tcl -- M7.a frozen-corpus instance/guard/condition census
# (M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md, "Current frozen-corpus instance
# census" / "Current guard census"). Observation only: reads the analyses
# native::lower::program itself runs, with its defaults.
#
#   tclsh9.0 audit/m7a-instance-selection/tools/corpus.tcl PROGRAM OUTDIR
#
# Writes into OUTDIR:
#   instances.txt   every used instance: key, generic/open, per-parameter
#                   declared type / view type / entry Range / RefineParams
#                   evidence, captured-binding seed types, direct calls,
#                   materialized Block values
#   conditions.txt  every reachable `if` of every used instance: the
#                   production hir::range::ConditionOutcome answer and the
#                   weakest fact tier that already decides it
#   guards.txt      every representation blocker (the `guard` NIR ops of
#                   generic/specialized instances) with its cause, the
#                   blocked binding's role (param/capture/local), key,
#                   declared type, view type, entry Range, open status
#   functions.txt   per emitted NIR function: machine-code bytes, regs,
#                   guard/br/fail/call-form counts
#   summary.txt     totals

source [file join [file dirname [file normalize [info script]]] lib.tcl]

lassign $argv path outdir
puts [m7a::census $path $outdir]

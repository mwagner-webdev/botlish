#!/usr/bin/env tclsh9.0
# generate-scalar-audit.tcl -- regenerates the committed scalar-machine-code
# audit corpus under audit/native-scalar-asm/ (see that directory's
# README.md and the top-level SCALAR-ASM-AUDIT.md for what this is for).
#
#   tclsh9.0 native/generate-scalar-audit.tcl [-outdir DIR]
#
# For every program in the audit corpus (the bench/*.ir programs and every
# examples/stdlib/*.bot program), this:
#
#   1. Loads/lowers the program to HIR the same way main.tcl and
#      bench/corpus.tcl do (core::loadProgramFile for .ir, surface::
#      readProgramFile for .bot).
#   2. Attempts native::object (specialize 1, the default "cranelift"
#      backend) to an object file in a scratch temp directory.
#   3. On success: disassembles the object with `objdump -dr
#      --no-show-raw-insn -M intel` (relocations shown, so runtime-helper
#      and cross-function call targets are visible by name; the object is
#      unlinked, so this is exactly the Botlish-generated code -- no
#      runtime/library disassembly, per the audit's item 64), normalizes
#      away the scratch file's own absolute path, and writes the result as
#      a committed .asm text file, alongside a compact per-program summary
#      (native::roots' per-function register/safepoint/root/shadow-slot
#      counts, machine-code size, and mechanically counted suspicious
#      patterns: rt_* helper call sites, rbox/runbox/closure-new counts).
#   4. On a NATIVE UNSUPPORTED (or other native) error: records the file as
#      unsupported/failed with the exact error, and writes no assembly.
#
# The scratch object files themselves are never committed (only the text
# disassembly derived from them) and are deleted after each program.
#
# This script changes no compiler/runtime behavior: it only calls existing
# native::* Tcl entry points and the existing botlish-native CLI.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root examples stdlib corpus.tcl]

set outdir [file join $root audit native-scalar-asm]
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -outdir { set outdir [lindex $argv [incr i]] }
        default { puts stderr "unknown argument: $arg"; exit 2 }
    }
}

lassign [file tempfile tmpMarker] tmpChannel
close $tmpChannel
file delete -force $tmpMarker
set scratch [file join [file dirname $tmpMarker] "botlish-scalar-audit-[pid]"]
file mkdir $scratch

proc W {path content} {
    file mkdir [file dirname $path]
    set f [open $path w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $content
    close $f
}

# ---------------------------------------------------------------------------
# NIR function-header parsing: id -> {name instance rawregs regs}

proc ParseNirFunctions {nirText} {
    set out [dict create]
    foreach line [split $nirText \n] {
        if {[regexp {^func (\d+) "([^"]*)" params=\d+ env=\d+ regs=(\d+) .*?instance="([^"]*)"} \
                $line -> id name regs instance]} {
            dict set out $id [dict create name $name instance $instance regs $regs]
        } elseif {[regexp {^func (\d+) "([^"]*)" params=\d+ env=\d+ regs=(\d+)} $line -> id name regs]} {
            dict set out $id [dict create name $name instance "" regs $regs]
        }
    }
    return $out
}

# Human label for NIR function id ID, given the ParseNirFunctions dict FUNCS.
proc Label {funcs id} {
    if {![dict exists $funcs $id]} {
        return "fn$id"
    }
    set info [dict get $funcs $id]
    set name [dict get $info name]
    set instance [dict get $info instance]
    if {$name eq "<program>"} {
        return "<program entry>"
    }
    if {$instance eq "" || $instance eq "generic"} {
        return "$name<generic>"
    }
    return "$name<$instance>"
}

# ---------------------------------------------------------------------------
# Disassembly

# Disassembles OBJPATH, normalizes away its own scratch path (replaced by
# DISPLAYNAME), and rewrites every "botlish_fn_N"/"botlish_entry_N" symbol
# occurrence (both the label lines and relocation targets) to carry its
# human label from FUNCS, without touching the raw instruction bytes or
# any function-local offset/address (item 9: only the label text changes).
proc Disassemble {objPath displayName funcs} {
    set pipe [open |[list objdump -dr --no-show-raw-insn -M intel $objPath] r]
    set text [read $pipe]
    close $pipe
    set text [string map [list $objPath $displayName] $text]
    set out {}
    foreach line [split $text \n] {
        if {[regexp {^([0-9a-f]+) <(botlish_(?:fn|entry)_\d+)>:$} $line -> addr sym]} {
            regexp {_(\d+)$} $sym -> id
            append out "$addr <$sym: [Label $funcs $id]>:\n"
            continue
        }
        if {[regexp {^(\s+[0-9a-f]+:\s+\w+\s+)(botlish_(?:fn|entry)_\d+)((?:[+-]0x[0-9a-f]+)?)(.*)$} \
                $line -> pre sym suffix post]} {
            regexp {_(\d+)$} $sym -> id
            append out "$pre$sym$suffix ; [Label $funcs $id]$post\n"
            continue
        }
        if {[regexp {^(\s+[0-9a-f]+:\s+R_X86_64_\w+\s+)(botlish_(?:fn|entry)_\d+)(-0x[0-9a-f]+)?$} \
                $line -> pre sym off]} {
            regexp {_(\d+)$} $sym -> id
            append out "$pre$sym$off ; [Label $funcs $id]\n"
            continue
        }
        append out "$line\n"
    }
    return [string trimright $out \n]
}

# ---------------------------------------------------------------------------
# Suspicious-pattern triage (mechanical only; item 54 -- human inspection
# decides whether a pattern is actually a problem, see SCALAR-ASM-AUDIT.md).

proc Triage {asm nirText} {
    set out {}
    foreach {label pattern} {
        {calls to rt_closure_new}      {R_X86_64_\w+\s+rt_closure_new}
        {calls to rt_int_add}          {R_X86_64_\w+\s+rt_int_add}
        {calls to rt_int_sub}          {R_X86_64_\w+\s+rt_int_sub}
        {calls to rt_int_mul}          {R_X86_64_\w+\s+rt_int_mul}
        {calls to rt_int_cmp}          {R_X86_64_\w+\s+rt_int_cmp}
        {calls to other rt_* helpers}  {R_X86_64_\w+\s+rt_(?!closure_new|int_add|int_sub|int_mul|int_cmp)\w+}
        {indirect calls (call rax/reg)} {\scall\s+r[a-z0-9]+\s*$}
    } {
        set n [regexp -all -inline $pattern $asm]
        dict set out $label [llength $n]
    }
    dict set out {op rbox (tagged->raw box)}   [regexp -all -line {\bop rbox\b} $nirText]
    dict set out {op runbox (raw->tagged unbox)} [regexp -all -line {\bop runbox\b} $nirText]
    dict set out {op closure (Block materialization)} [regexp -all -line {\bop closure\b} $nirText]
    dict set out {guard/guardbool instructions}  [regexp -all -line {^\s+guard(bool)? } $nirText]
    return $out
}

# ---------------------------------------------------------------------------
# Per-program processing

proc ProcessProgram {label sourcePath hir asmPath summaryPath statusVar} {
    upvar 1 $statusVar status
    global scratch

    if {[catch {native::nir $hir} nirText]} {
        dict set status kind unsupported
        dict set status detail $nirText
        return
    }
    set funcs [ParseNirFunctions $nirText]

    if {[catch {native::roots $hir} rootsText]} {
        set rootsText "(roots report unavailable: $rootsText)"
    }
    if {[catch {native::codeSize $hir} sizeInfo]} {
        set sizeInfo {? {}}
    }
    lassign $sizeInfo totalBytes perFunctionBytes

    set objPath [file join $scratch "[file tail $asmPath].o"]
    if {[catch {native::object $hir $objPath} objResult options]} {
        dict set status kind failed
        dict set status detail $objResult
        return
    }

    set displayName "[file tail $asmPath].o"
    set header "; source:  $sourcePath\n"
    append header "; backend: Cranelift (specialize=1), native::object\n"
    append header "; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime\n"
    append header ";          helpers are unresolved imports, so their bodies are not present)\n"
    append header "; format:  objdump -dr --no-show-raw-insn -M intel\n"
    append header "; total machine code bytes: $totalBytes  (per function: $perFunctionBytes)\n"
    append header ";\n"
    append header "; function symbol -> Botlish label:\n"
    foreach id [lsort -integer [dict keys $funcs]] {
        append header ";   botlish_fn_$id / botlish_entry_$id -> [Label $funcs $id]\n"
    }
    append header "\n"

    set asm [Disassemble $objPath $displayName $funcs]
    W $asmPath "$header$asm\n"
    file delete -force $objPath

    set triage [Triage $asm $nirText]

    set summary "source:  $sourcePath\n"
    append summary "backend: Cranelift (specialize=1)\n"
    append summary "asm:     [file tail $asmPath]\n"
    append summary "machine-code bytes: $totalBytes (per function: $perFunctionBytes)\n\n"
    append summary "functions:\n"
    foreach id [lsort -integer [dict keys $funcs]] {
        set info [dict get $funcs $id]
        append summary "  $id [Label $funcs $id]: nir-regs=[dict get $info regs]\n"
    }
    append summary "\nGC roots ([file tail $asmPath]'s NIR ids match roots.txt's \"function N\"):\n"
    append summary [string map {"\n" "\n  "} "  $rootsText"]
    append summary "\n\nmechanical pattern counts (triage only; see report for interpretation):\n"
    dict for {k v} $triage {
        if {$v > 0} {
            append summary "  $v x $k\n"
        }
    }
    W $summaryPath $summary

    dict set status kind ok
    dict set status bytes $totalBytes
    dict set status functions [dict size $funcs]
    dict set status triage $triage
}

# ---------------------------------------------------------------------------
# Corpus enumeration

set benchDir [file join $root bench]
set benchFiles {fib.ir loop-count.ir sum-refined.ir refined-checks.ir}

set results {}

puts "== bench/ =="
foreach name $benchFiles {
    set path [file join $benchDir $name]
    set base [file rootname $name]
    set asmPath [file join $outdir bench "$base.asm"]
    set summaryPath [file join $outdir bench "$base.summary.txt"]
    set status [dict create source "bench/$name" kind unknown]
    if {[catch {
        set program [core::loadProgramFile $path]
        set hir [hir::build $program -strict 0]
    } err]} {
        dict set status kind failed
        dict set status detail "could not load/build HIR: $err"
    } else {
        ProcessProgram $base "bench/$name" $hir $asmPath $summaryPath status
    }
    if {[dict get $status kind] ne "ok"} {
        file delete -force $asmPath $summaryPath
        set statusPath [file join $outdir bench "$base.status.txt"]
        W $statusPath "source: bench/$name\nstatus: [dict get $status kind]\ndetail: [dict get $status detail]\n"
    } else {
        set statusPath [file join $outdir bench "$base.status.txt"]
        file delete -force $statusPath
    }
    puts "  $name: [dict get $status kind]"
    lappend results $status
}

puts "== examples/stdlib/ =="
foreach name [corpus::names] {
    set path [corpus::path $name]
    set asmPath [file join $outdir examples-stdlib "$name.asm"]
    set summaryPath [file join $outdir examples-stdlib "$name.summary.txt"]
    set status [dict create source "examples/stdlib/$name.bot" kind unknown]
    if {[catch {
        foreach req [core::programFileRequires $path] { core::loadLibrary $req }
        set hir [surface::compile [core::ReadFile $path] $path]
    } err]} {
        dict set status kind failed
        dict set status detail "could not load/build HIR: $err"
    } else {
        ProcessProgram $name "examples/stdlib/$name.bot" $hir $asmPath $summaryPath status
    }
    if {[dict get $status kind] ne "ok"} {
        file delete -force $asmPath $summaryPath
        set statusPath [file join $outdir examples-stdlib "$name.status.txt"]
        W $statusPath "source: examples/stdlib/$name.bot\nstatus: [dict get $status kind]\ndetail: [dict get $status detail]\n"
    } else {
        set statusPath [file join $outdir examples-stdlib "$name.status.txt"]
        file delete -force $statusPath
    }
    puts "  $name: [dict get $status kind]"
    lappend results $status
}

file delete -force $scratch

# ---------------------------------------------------------------------------
# Index / README

proc GitCommit {} {
    if {[catch {exec git rev-parse HEAD} out]} { return "unknown" }
    return $out
}
proc RustcVersion {} {
    if {[catch {exec rustc --version} out]} { return "unknown" }
    return $out
}
proc CargoLockVersion {crate} {
    global root
    set text [core::ReadFile [file join $root native Cargo.lock]]
    if {[regexp "name = \"$crate\"\\nversion = \"(\[^\"\]+)\"" $text -> v]} {
        return $v
    }
    return "unknown"
}

set totalBytes 0
set totalFunctions 0
set okCount 0
set unsupportedCount 0
foreach r $results {
    if {[dict get $r kind] eq "ok"} {
        incr okCount
        incr totalBytes [dict get $r bytes]
        incr totalFunctions [dict get $r functions]
    } else {
        incr unsupportedCount
    }
}

set index "# Native scalar machine-code audit corpus\n\n"
append index "**Temporary diagnostic snapshot.** Regenerate with:\n\n"
append index "```sh\ntclsh9.0 native/generate-scalar-audit.tcl\n```\n\n"
append index "This directory is not a canonical build product. It may be removed once the\n"
append index "scalar audit (see /SCALAR-ASM-AUDIT.md) and any follow-up fixes it leads to\n"
append index "are complete.\n\n"
append index "## Compiler revision\n\n"
append index "- git commit: [GitCommit]\n"
append index "- Tcl: [info patchlevel]\n"
append index "- [RustcVersion]\n"
append index "- cranelift-codegen: [CargoLockVersion cranelift-codegen]\n"
append index "- target: x86_64 (System V ABI, Linux ELF64)\n"
append index "- backend flags: cranelift, -specialize 1 (default), -repr-opt 1 (default)\n"
append index "- disassembly: objdump -dr --no-show-raw-insn -M intel, on the unlinked\n"
append index "  object (native::object) -- Botlish-generated code only, no linked runtime\n"
append index "  or libc disassembly\n\n"
append index "## Corpus summary\n\n"
append index "- bench/ files attempted: [llength $benchFiles]\n"
append index "- examples/stdlib/ files attempted: [llength [corpus::names]]\n"
append index "- native-compilable programs: $okCount\n"
append index "- unsupported/failed programs: $unsupportedCount\n"
append index "- total native functions inspected: $totalFunctions\n"
append index "- total committed disassembly bytes of machine code: $totalBytes\n\n"
append index "## Status\n\n"
append index "| file | status | assembly | notes |\n"
append index "|---|---|---|---|\n"
foreach r $results {
    set src [dict get $r source]
    set group [expr {[string match "bench/*" $src] ? "bench" : "examples-stdlib"}]
    set base [file rootname [file tail $src]]
    if {[dict get $r kind] eq "ok"} {
        append index "| $src | compiled / inspected | \[$group/$base.asm\]($group/$base.asm) | [dict get $r functions] functions, [dict get $r bytes] bytes |\n"
    } else {
        set detail [string map {"\n" " "} [dict get $r detail]]
        if {[string length $detail] > 160} { set detail "[string range $detail 0 157]..." }
        append index "| $src | [dict get $r kind] | \[$group/$base.status.txt\]($group/$base.status.txt) | $detail |\n"
    }
}
append index "\nSee /SCALAR-ASM-AUDIT.md at the repository root for the analysis of this\n"
append index "corpus (per-function classification, findings, severity, and the milestone\n"
append index "recommendation).\n"

W [file join $outdir README.md] $index
puts "wrote [file join $outdir README.md]"

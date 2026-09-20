#!/usr/bin/env tclsh9.0
# Selected semantic and allocation dumps for the post-stack audit.
set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root compiler compiler.tcl]
source [file join $root native native.tcl]
set out [file join $root audit post-native-stack bench]
file mkdir $out
proc writeText {path value} {
    set ch [open $path w]
    fconfigure $ch -encoding utf-8
    puts -nonewline $ch $value
    close $ch
}
foreach name {fib loop-count sum-refined refined-checks} {
    set hir [native::buildProgramHir [core::loadProgramFile [file join $root bench "$name.ir"]]]
    writeText [file join $out "$name.hir"] [hir::format $hir]
    writeText [file join $out "$name.nir"] [native::nir $hir]
    writeText [file join $out "$name.clif"] [native::clif $hir]
    writeText [file join $out "$name.alloc.txt"] [native::allocationText [native::allocationReport $hir sites]]
    puts "$name: details written"
}
# A matched envless / scalar-capture / managed-capture module probe.
source [file join $root surface surface.tcl]
set moduleDir [file join $root audit post-native-stack module-cases]
set savedLibraryDir $::core::libraryDir
set ::core::libraryDir $moduleDir
try {
    set hir [surface::readProgramFile [file join $moduleDir main.bot]]
    writeText [file join $moduleDir main.hir] [hir::format $hir]
    writeText [file join $moduleDir main.nir] [native::nir $hir]
    writeText [file join $moduleDir main.clif] [native::clif $hir]
    writeText [file join $moduleDir main.vcode] [native::vcode $hir]
    writeText [file join $moduleDir main.roots.txt] [native::roots $hir]
    writeText [file join $moduleDir main.alloc.txt] [native::allocationText [native::allocationReport $hir sites]]
    set obj [file join $moduleDir main.o]
    native::object $hir $obj
    writeText [file join $moduleDir main.asm] [exec objdump -dr --no-show-raw-insn -M intel $obj]
    file delete $obj
} finally {
    set ::core::libraryDir $savedLibraryDir
}
puts "module cases: details written"
# Corpus-wide NIR for structural call and specialization counts.
source [file join $root examples stdlib corpus.tcl]
set stdlibOut [file join $root audit post-native-stack examples-stdlib]
foreach name [corpus::names] {
    set path [corpus::path $name]
    foreach req [core::programFileRequires $path] { core::loadLibrary $req }
    set hir [surface::compile [core::ReadFile $path] $path]
    writeText [file join $stdlibOut "$name.nir"] [native::nir $hir]
    puts "$name: NIR written"
}
# Keep generated text reviewable and make git diff --check meaningful.
foreach group {bench examples-stdlib module-cases refs} {
    foreach path [glob -nocomplain -directory [file join $root audit post-native-stack $group] *] {
        if {![file isfile $path]} { continue }
        set ch [open $path r]
        fconfigure $ch -encoding utf-8
        set data [read $ch]
        close $ch
        regsub -all -line {[ \t]+$} $data {} normalized
        if {$normalized ne $data} { writeText $path $normalized }
    }
}
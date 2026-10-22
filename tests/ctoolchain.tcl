# ctoolchain.tcl -- the host's own C toolchain, as the tests build their C
# fixtures with it (test infrastructure only: nothing in the compiler, the
# runtime or the libraries loads it).
#
#   ctool::available                     1 if the host's C toolchain is there
#   ctool::objectFile SOURCE DIR         the object SOURCE compiles to in DIR
#   ctool::staticName NAME               the file of static library NAME
#   ctool::staticLibrary DIR NAME SOURCE ?SOURCE ...? ?-crt static|dynamic?
#                                        builds it in DIR from the sources
#                                        (one object each, named after its
#                                        source); returns its path
#   ctool::sharedLibrary DIR NAME SOURCE ?-crt static|dynamic?
#                                        builds the shared library NAME:
#                                        {LIBRARY LINKED}, LINKED the file the
#                                        linker reads (the library itself, or
#                                        a Windows DLL's import library)
#   ctool::executable DIR NAME SOURCE    builds the C program NAME (NAME.exe on
#                                        Windows); returns its path
#   ctool::msvc COMMAND ARG ...          runs an MSVC tool (Windows)
#
# On Linux and macOS the toolchain is `cc` and `ar`, run exactly as the tests
# always ran them (`cc -c -O2 -fPIC SOURCE -o OBJECT`, `ar rcs libNAME.a
# OBJECT...`; GCC or Clang, Apple clang). On Windows it is Microsoft's
# (WINDOWS-X86-64-MILESTONE-2.md, "ABI fixtures"): `cl` compiles C, `ml64`
# assembles MASM (a fixture's `.asm` sources), `lib` archives NAME.lib, and
# `cl /LD` links a DLL with its import library. Their environment is
# vcvars64.bat's (the Visual Studio vswhere names), captured once and set for
# those tools' runs alone: Botlish's own links never run in it -- rustc finds
# link.exe and the SDK by itself (WINDOWS-X86-64-MILESTONE-1.md). The image's
# `cc` there is a MinGW gcc, whose archives are no MSVC fixture.
#
# Every fixture is built with the static release C runtime (`/MT`, cl's
# default), which every Windows executable links (codegen/aot.rs's
# crt_args); `-crt dynamic` builds one for the dynamic runtime (`/MD`), as
# the C runtime tests need.

namespace eval ctool {
    variable windows [expr {$::tcl_platform(platform) eq "windows"}]
}

# The environment vcvars64.bat makes, as a dict (empty when the current one
# is already a developer environment), or "" when there is no MSVC.
proc ctool::MsvcEnvironment {} {
    variable msvcEnvironment
    if {[info exists msvcEnvironment]} {
        return $msvcEnvironment
    }
    set msvcEnvironment ""
    if {[info exists ::env(VCToolsInstallDir)] && [auto_execok cl] ne ""} {
        set msvcEnvironment [dict create]
        return $msvcEnvironment
    }
    set programs [lindex [array get ::env {ProgramFiles(x86)}] 1]
    if {$programs eq ""} {
        set programs {C:/Program Files (x86)}
    }
    set vswhere [file join $programs "Microsoft Visual Studio" Installer vswhere.exe]
    if {![file exists $vswhere]} {
        return ""
    }
    if {[catch {exec $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath} install]} {
        return ""
    }
    set vcvars [file join [string trim $install] VC Auxiliary Build vcvars64.bat]
    if {![file exists $vcvars]} {
        return ""
    }
    set dir [file tempdir botlish-vcvars]
    try {
        set script [file join $dir environment.cmd]
        set channel [open $script w]
        fconfigure $channel -translation crlf
        puts $channel "@echo off\ncall \"[file nativename $vcvars]\" >nul\nif errorlevel 1 exit /b 1\nset"
        close $channel
        if {[catch {exec cmd.exe /c [file nativename $script]} output]} {
            return ""
        }
    } finally {
        file delete -force $dir
    }
    set environment [dict create]
    foreach line [split $output \n] {
        if {[regexp {^([^=]+)=(.*)$} [string trimright $line \r] -> name value]} {
            dict set environment $name $value
        }
    }
    if {![dict exists $environment VCToolsInstallDir]} {
        return ""
    }
    set msvcEnvironment $environment
    return $msvcEnvironment
}

# The name ::env spells NAME with, Windows' names being case-insensitive.
proc ctool::EnvName {name} {
    foreach existing [array names ::env] {
        if {[string equal -nocase $existing $name]} {
            return $existing
        }
    }
    return $name
}

# Runs the MSVC tool COMMAND with ARGS in vcvars64's environment (this
# process's own afterwards): exec's result.
proc ctool::msvc {command args} {
    set environment [MsvcEnvironment]
    if {$environment eq ""} {
        error "no MSVC toolchain: vswhere found no Visual Studio with the x64 C tools"
    }
    set saved [dict create]
    dict for {name value} $environment {
        set name [EnvName $name]
        dict set saved $name [array get ::env $name]
        set ::env($name) $value
    }
    try {
        return [exec -ignorestderr $command {*}$args]
    } finally {
        dict for {name value} $saved {
            if {$value eq ""} { unset -nocomplain ::env($name) } else { set ::env($name) [lindex $value 1] }
        }
    }
}

proc ctool::available {} {
    variable windows
    if {$windows} {
        return [expr {[MsvcEnvironment] ne ""}]
    }
    return [expr {[auto_execok cc] ne "" && [auto_execok ar] ne ""}]
}

proc ctool::objectFile {source dir} {
    variable windows
    return [file join $dir [file rootname [file tail $source]][expr {$windows ? ".obj" : ".o"}]]
}

proc ctool::staticName {name} {
    variable windows
    return [expr {$windows ? "$name.lib" : "lib$name.a"}]
}

# The C runtime option of -crt KIND (Windows).
proc ctool::CrtFlag {kind} {
    switch -- $kind {
        static { return /MT }
        dynamic { return /MD }
    }
    error "unknown C runtime \"$kind\" (static, dynamic)"
}

proc ctool::staticLibrary {dir name args} {
    variable windows
    set crt static
    set sources {}
    for {set i 0} {$i < [llength $args]} {incr i} {
        if {[lindex $args $i] eq "-crt"} {
            set crt [lindex $args [incr i]]
        } else {
            lappend sources [lindex $args $i]
        }
    }
    set objects {}
    foreach source $sources {
        set object [objectFile $source $dir]
        if {!$windows} {
            exec cc -c -O2 -fPIC $source -o $object
        } elseif {[file extension $source] eq ".asm"} {
            msvc ml64 /nologo /c /Fo[file nativename $object] [file nativename $source]
        } else {
            msvc cl /nologo /c /O2 /W3 /std:c11 [CrtFlag $crt] /Fo[file nativename $object] [file nativename $source]
        }
        lappend objects $object
    }
    set library [file join $dir [staticName $name]]
    if {$windows} {
        msvc lib /nologo /OUT:[file nativename $library] {*}[lmap o $objects {file nativename $o}]
    } else {
        exec ar rcs $library {*}$objects
    }
    return $library
}

proc ctool::sharedLibrary {dir name source args} {
    variable windows
    set crt static
    foreach {option value} $args {
        if {$option ne "-crt"} { error "unknown option $option" }
        set crt $value
    }
    if {$windows} {
        set library [file join $dir $name.dll]
        msvc cl /nologo /LD /O2 /W3 /std:c11 [CrtFlag $crt] /Fo[file nativename [objectFile $source $dir]] \
            /Fe[file nativename $library] [file nativename $source]
        return [list $library [file join $dir $name.lib]]
    }
    if {$::tcl_platform(os) eq "Darwin"} {
        set library [file join $dir lib$name.dylib]
        exec cc -dynamiclib -O2 $source -install_name $library -o $library
    } else {
        set library [file join $dir lib$name.so]
        exec cc -shared -fPIC -O2 $source -o $library
    }
    return [list $library $library]
}

proc ctool::executable {dir name source} {
    variable windows
    if {$windows} {
        set program [file join $dir $name.exe]
        msvc cl /nologo /O2 /W3 /std:c11 /MT /Fo[file nativename [objectFile $source $dir]] \
            /Fe[file nativename $program] [file nativename $source]
        return $program
    }
    set program [file join $dir $name]
    exec cc -O2 $source -o $program
    return $program
}

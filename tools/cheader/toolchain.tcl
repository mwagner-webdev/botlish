# toolchain.tcl -- the C toolchain adapter of the C header library
# (C-HEADER-ARCHAEOLOGY.md, "The toolchain adapter"; C-BINDGEN.md,
# "Toolchain").
#
# The one place that knows how to run an installed C toolchain. The header
# archaeology and the binding generator ask it to
#
#   preprocess ENTRY      the preprocessed C of a translation unit
#   macros ENTRY          the same with every #define kept (macro census)
#   predefined            the compiler's predefined macros
#   compile SOURCE        does generated C compile? (thunk and oracle probes)
#   run SOURCE            compile, link and run a native probe (ABI probe)
#   assemble SOURCE       the assembly of a probe (facts read from its data,
#                         for any target: nothing runs)
#   llvm SOURCE           the optimized LLVM IR of a translation unit (the
#                         generator's semantic evidence, clang only)
#   recordLayouts SOURCE  the record layouts the compiler computes for a
#                         translation unit, as it dumps them (clang only:
#                         the size and alignment of an anonymous member,
#                         which no C expression names)
#   object SOURCE OUT     compile to an object file
#   archive OBJECTS OUT   a static library of objects
#   searchDirs            the directories the compiler searches for
#                         <...> includes, in order
#   libraryFile NAME      the library file -lNAME names (an import library)
#   symbolsOf PATH        the symbols an object or archive defines (or
#                         references)
#
# configFor TARGET is the configuration for a Botlish C target
# (core/cabi.tcl's names): a clang-family compiler with --target, so that
# every target is preprocessed and probed by one compiler and differences
# between targets are the targets', not the toolchains'.
#
# and never sees a command line. Configuration comes from the environment
# (and the profile adds its include directories and defines):
#
#   BOTLISH_C_CC          the C compiler command (default: the first of cc,
#                         gcc, clang on PATH)
#   BOTLISH_C_CPP         a distinct preprocessor command (default: CC -E)
#   BOTLISH_C_TARGET      a target triple (clang family only: --target=)
#   BOTLISH_C_INCLUDE     extra include directories (the platform's path
#                         separator)
#   BOTLISH_C_DEFINES     extra NAME or NAME=VALUE words
#   BOTLISH_C_UNDEFINES   extra NAME words
#   BOTLISH_C_FLAGS       extra flags, verbatim words
#
# Only the GCC/Clang command shape ("gnu" style below) is implemented. Every
# flag it spells is in the style table, so a second style (MSVC's cl /E /I
# /D, no -dD equivalent) is one table entry plus whatever capability it
# lacks, not edits throughout the instrument.

namespace eval ::chdr::toolchain {
    variable styles {
        gnu {
            preprocess {-E}
            language {-x c}
            include -I
            define -D
            undefine -U
            macros {-dD}
            predefined {-dM -E}
            compile {-c}
            output -o
            target --target=
            version --version
            assemble {-S}
            llvm {-S -emit-llvm}
            recordLayouts {-fsyntax-only -Xclang -fdump-record-layouts}
            sysroot --sysroot=
            appleSysroot -isysroot
            verbose -v
        }
    }
    # Botlish C targets (core/cabi.tcl) -> the clang target triple configFor
    # gives them. windows-x86_64-gnu is MinGW-w64's GNU ABI (clang's
    # x86_64-w64-mingw32, with the MinGW-w64 headers and import libraries a
    # cross installation provides); windows-x86_64 is MSVC's (clang's
    # x86_64-pc-windows-msvc, with the headers of Visual Studio and the
    # Windows SDK, which clang finds by itself on a Windows host and which
    # exist nowhere else: ICY-TOWER-WINDOWS.md); windows-aarch64 is not
    # implemented.
    variable triples {
        linux-x86_64 x86_64-linux-gnu
        linux-aarch64 aarch64-linux-gnu
        macos-x86_64 x86_64-apple-macos10.15
        macos-aarch64 arm64-apple-macos11
        windows-x86_64-gnu x86_64-w64-mingw32
        windows-x86_64 x86_64-pc-windows-msvc
    }
}

proc ::chdr::toolchain::Words {name} {
    if {![info exists ::env($name)] || [string trim $::env($name)] eq ""} { return {} }
    return [regexp -all -inline {\S+} $::env($name)]
}

# The configuration: a dict of cc, cpp, style, family, version, target,
# include, defines, undefines, flags.
proc ::chdr::toolchain::config {} {
    set cc [Words BOTLISH_C_CC]
    if {$cc eq ""} {
        foreach candidate {cc gcc clang} {
            if {[auto_execok $candidate] ne ""} { set cc [list $candidate]; break }
        }
    }
    if {$cc eq ""} { error "toolchain: no C compiler (set BOTLISH_C_CC)" }
    set cpp [Words BOTLISH_C_CPP]
    set separator [expr {$::tcl_platform(platform) eq "windows" ? ";" : ":"}]
    set include {}
    if {[info exists ::env(BOTLISH_C_INCLUDE)] && $::env(BOTLISH_C_INCLUDE) ne ""} {
        set include [split $::env(BOTLISH_C_INCLUDE) $separator]
    }
    set config [dict create cc $cc cpp $cpp style gnu target [lindex [Words BOTLISH_C_TARGET] 0] \
        include $include defines [Words BOTLISH_C_DEFINES] undefines [Words BOTLISH_C_UNDEFINES] \
        flags [Words BOTLISH_C_FLAGS]]
    lassign [Identify $cc] family version path
    dict set config family $family
    dict set config version $version
    dict set config path $path
    if {$family eq "msvc"} {
        error "toolchain: $cc looks like MSVC cl; this adapter implements only the GCC/Clang command shape"
    }
    if {[dict get $config target] ne "" && $family ne "clang"} {
        error "toolchain: BOTLISH_C_TARGET needs a clang-family compiler (a GCC cross compiler is its own BOTLISH_C_CC)"
    }
    return $config
}

# {FAMILY VERSION PATH} from `CC --version`: clang, gcc, msvc or unknown.
proc ::chdr::toolchain::Identify {cc} {
    set path [auto_execok [lindex $cc 0]]
    if {[catch {exec {*}$cc --version 2>@1} out]} {
        if {[regexp {Microsoft} $out]} { return [list msvc [lindex [split $out \n] 0] $path] }
        return [list unknown [lindex [split $out \n] 0] $path]
    }
    set first [lindex [split $out \n] 0]
    if {[regexp -nocase {clang} $out]} { return [list clang $first $path] }
    if {[regexp {Free Software Foundation|\mgcc\M|GCC} $out]} { return [list gcc $first $path] }
    return [list unknown $first $path]
}

# The configuration for Botlish C target TARGET: config's, with the target
# triple of the table and, for that target, BOTLISH_C_SYSROOT_<TARGET>
# (a sysroot or SDK directory; "-" and "." in the target name become "_")
# or BOTLISH_C_SYSROOT. The compiler is BOTLISH_C_CC when set (it must be
# clang-family, or a compiler of exactly that target, which is then given
# no --target), else clang.
proc ::chdr::toolchain::configFor {target} {
    variable triples
    if {![dict exists $triples $target]} {
        error "toolchain: no C toolchain configuration for target \"$target\" (known: [join [dict keys $triples] {, }])"
    }
    set saved [expr {[info exists ::env(BOTLISH_C_CC)] ? [list $::env(BOTLISH_C_CC)] : {}}]
    if {$saved eq "" || [string trim [lindex $saved 0]] eq ""} {
        set ::env(BOTLISH_C_CC) clang
    }
    set savedTarget [expr {[info exists ::env(BOTLISH_C_TARGET)] ? [list $::env(BOTLISH_C_TARGET)] : {}}]
    catch {unset ::env(BOTLISH_C_TARGET)}
    try {
        set config [config]
    } finally {
        if {$saved eq ""} { unset ::env(BOTLISH_C_CC) } else { set ::env(BOTLISH_C_CC) [lindex $saved 0] }
        if {$savedTarget ne ""} { set ::env(BOTLISH_C_TARGET) [lindex $savedTarget 0] }
    }
    # A binding's configuration is its profile's and its target's: the
    # archaeology's extra-word knobs (BOTLISH_C_INCLUDE, _DEFINES,
    # _UNDEFINES, _FLAGS) never reach a generated binding from a shell.
    foreach k {include defines undefines flags} { dict set config $k {} }
    set triple [dict get $triples $target]
    if {[dict get $config family] eq "clang"} {
        dict set config target $triple
    } elseif {![string match "[lindex [split $triple -] 0]-*" [Machine $config]]} {
        error "toolchain: [dict get $config cc] is a [dict get $config family] compiler for [Machine $config]: target $target ($triple) needs clang or a compiler of that target"
    }
    dict set config botlishTarget $target
    set var BOTLISH_C_SYSROOT_[string map {- _ . _} $target]
    set sysroot ""
    foreach v [list $var BOTLISH_C_SYSROOT] {
        if {[info exists ::env($v)] && $::env($v) ne ""} { set sysroot $::env($v); break }
    }
    dict set config sysroot $sysroot
    return $config
}

# The machine a non-clang compiler targets (`-dumpmachine`).
proc ::chdr::toolchain::Machine {config} {
    if {[catch {exec {*}[dict get $config cc] -dumpmachine} out]} { return "" }
    return [string trim $out]
}

proc ::chdr::toolchain::Flag {config name} {
    variable styles
    return [dict get $styles [dict get $config style] $name]
}

# The words every command shares: target, include directories, defines,
# undefines and extra flags, the profile's first.
proc ::chdr::toolchain::CommonWords {config profile} {
    set words {}
    if {[dict get $config target] ne ""} {
        lappend words "[Flag $config target][dict get $config target]"
    }
    if {[dict exists $config sysroot] && [dict get $config sysroot] ne ""} {
        if {[string match *-apple-* [dict get $config target]]} {
            lappend words [Flag $config appleSysroot] [dict get $config sysroot]
        } else {
            lappend words "[Flag $config sysroot][dict get $config sysroot]"
        }
    }
    foreach f [concat [dict get $profile flags] [dict get $config flags]] { lappend words $f }
    foreach d [concat [dict get $profile includeDirs] [dict get $config include]] {
        lappend words "[Flag $config include]$d"
    }
    foreach d [concat [dict get $profile defines] [dict get $config defines]] {
        lappend words "[Flag $config define]$d"
    }
    foreach d [concat [dict get $profile undefines] [dict get $config undefines]] {
        lappend words "[Flag $config undefine]$d"
    }
    return $words
}

proc ::chdr::toolchain::PreprocessCommand {config profile} {
    if {[dict get $config cpp] ne ""} {
        set cmd [dict get $config cpp]
    } else {
        set cmd [concat [dict get $config cc] [Flag $config preprocess]]
    }
    return [concat $cmd [Flag $config language] [CommonWords $config $profile]]
}

# Run a command; {OK STDOUT STDERR SECONDS}.
proc ::chdr::toolchain::Exec {command} {
    set err [file tempfile errPath]
    close $err
    set t0 [clock microseconds]
    set ok [expr {![catch {exec {*}$command 2> $errPath} out]}]
    set seconds [expr {([clock microseconds] - $t0) / 1e6}]
    set f [open $errPath]
    set stderr [read $f]
    close $f
    file delete $errPath
    if {!$ok && $stderr eq ""} { set stderr $out; set out "" }
    return [list $ok $out $stderr $seconds]
}

# Preprocess ENTRY (a C file): {OK TEXT STDERR SECONDS COMMAND}.
proc ::chdr::toolchain::preprocess {config profile entry} {
    set command [concat [PreprocessCommand $config $profile] [list $entry]]
    return [concat [Exec $command] [list $command]]
}

# The same with every #define and #undef kept in place.
proc ::chdr::toolchain::macros {config profile entry} {
    set command [concat [PreprocessCommand $config $profile] [Flag $config macros] [list $entry]]
    return [concat [Exec $command] [list $command]]
}

# The predefined macros of the configuration (an empty translation unit).
proc ::chdr::toolchain::predefined {config profile} {
    set dir [file tempfile path .c]
    close $dir
    set command [concat [dict get $config cc] [Flag $config predefined] [Flag $config language] \
        [CommonWords $config $profile] [list $path]]
    set result [Exec $command]
    file delete $path
    return [concat $result [list $command]]
}

# Compile SOURCE (C text) to an object; {OK STDERR COMMAND}.
proc ::chdr::toolchain::compile {config profile source {extra {}}} {
    set dir [file tempdir]
    set c [file join $dir probe.c]
    set f [open $c w]
    puts $f $source
    close $f
    set command [concat [dict get $config cc] [Flag $config language] [CommonWords $config $profile] \
        $extra [Flag $config compile] [list $c] [Flag $config output] [list [file join $dir probe.o]]]
    lassign [Exec $command] ok out stderr
    file delete -force $dir
    return [list $ok $stderr $command]
}

# Compile, link and run SOURCE on the host; {OK STDOUT STDERR COMMAND}.
# Native only: refuses a configuration with a target.
proc ::chdr::toolchain::run {config profile source} {
    if {[dict get $config target] ne ""} {
        return [list 0 "" "toolchain: a probe runs only natively (BOTLISH_C_TARGET is set)" {}]
    }
    set dir [file tempdir]
    set c [file join $dir probe.c]
    set exe [file join $dir probe]
    set f [open $c w]
    puts $f $source
    close $f
    set command [concat [dict get $config cc] [Flag $config language] [CommonWords $config $profile] \
        [list $c] [Flag $config output] [list $exe]]
    lassign [Exec $command] ok out stderr
    if {!$ok} {
        file delete -force $dir
        return [list 0 "" $stderr $command]
    }
    lassign [Exec [list $exe]] ok out stderr2
    file delete -force $dir
    return [list $ok $out "$stderr$stderr2" $command]
}

# Compile SOURCE (C text) to assembly; {OK ASSEMBLY STDERR COMMAND}. Works
# for any target the compiler has: nothing is linked or run, so the
# generator reads compile-time facts from the data a probe defines.
proc ::chdr::toolchain::assemble {config profile source {extra {}}} {
    return [Emit $config $profile $source assemble .s $extra]
}

# The LLVM IR of SOURCE (clang only); {OK IR STDERR COMMAND}.
proc ::chdr::toolchain::llvm {config profile source {extra {}}} {
    if {[dict get $config family] ne "clang"} {
        return [list 0 "" "toolchain: LLVM IR needs a clang-family compiler ([dict get $config cc] is [dict get $config family])" {}]
    }
    return [Emit $config $profile $source llvm .ll $extra]
}

# The record layouts clang computes for SOURCE (C text), as it dumps them
# (clang only); {OK TEXT STDERR COMMAND}, TEXT every "*** Dumping AST Record
# Layout" block of the records SOURCE lays out.
proc ::chdr::toolchain::recordLayouts {config profile source} {
    if {[dict get $config family] ne "clang"} {
        return [list 0 "" "toolchain: a record layout dump needs a clang-family compiler ([dict get $config cc] is [dict get $config family])" {}]
    }
    set dir [file tempdir]
    set c [file join $dir probe.c]
    set f [open $c w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $source
    close $f
    set command [concat [dict get $config cc] [Flag $config language] [CommonWords $config $profile] \
        [list -w] [Flag $config recordLayouts] [list $c]]
    lassign [Exec $command] ok out stderr
    file delete -force $dir
    return [list $ok $out [string map [list $c probe.c] $stderr] $command]
}

proc ::chdr::toolchain::Emit {config profile source flag suffix extra} {
    set dir [file tempdir]
    set c [file join $dir probe.c]
    set out [file join $dir probe$suffix]
    set f [open $c w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $source
    close $f
    set command [concat [dict get $config cc] [Flag $config language] [CommonWords $config $profile] \
        $extra [Flag $config $flag] [list $c] [Flag $config output] [list $out]]
    lassign [Exec $command] ok text stderr
    set result ""
    if {$ok && [file exists $out]} {
        set result [::chdr::readFile $out]
    }
    file delete -force $dir
    return [list $ok $result [string map [list $c probe.c] $stderr] $command]
}

# Compile the C file SOURCEPATH to the object OUT; {OK STDERR COMMAND}.
proc ::chdr::toolchain::object {config profile sourcePath out {extra {}}} {
    set command [concat [dict get $config cc] [Flag $config language] [CommonWords $config $profile] \
        $extra [Flag $config compile] [list $sourcePath] [Flag $config output] [list $out]]
    lassign [Exec $command] ok text stderr
    return [list $ok $stderr $command]
}

# A static library OUT of OBJECTS, by BOTLISH_C_AR (default: llvm-ar for a
# clang-family configuration when installed, else ar); {OK STDERR COMMAND}.
proc ::chdr::toolchain::archive {config objects out} {
    set ar [Words BOTLISH_C_AR]
    if {$ar eq ""} {
        set ar [expr {[dict get $config family] eq "clang" && [auto_execok llvm-ar] ne "" ? "llvm-ar" : "ar"}]
    }
    file delete -force $out
    set command [concat $ar rcs [list $out] $objects]
    lassign [Exec $command] ok text stderr
    return [list $ok $stderr $command]
}

# The directories the configuration searches for <...> includes, in
# order: the compiler's own listing (-E -v of an empty translation unit),
# between "#include <...> search starts here:" and "End of search list.".
# {OK DIRS STDERR COMMAND}.
proc ::chdr::toolchain::searchDirs {config profile} {
    set dir [file tempdir]
    set c [file join $dir empty.c]
    close [open $c w]
    set command [concat [PreprocessCommand $config $profile] [Flag $config verbose] [list $c] \
        [Flag $config output] [list [file join $dir empty.i]]]
    lassign [Exec $command] ok out stderr
    file delete -force $dir
    set dirs {}
    set inside 0
    foreach line [split $stderr \n] {
        if {[string match "#include <...> search starts here:*" $line]} { set inside 1; continue }
        if {[string match "End of search list.*" $line]} { set inside 0; continue }
        if {$inside} { lappend dirs [file normalize [string trim [regsub { \(framework directory\)$} $line ""]]] }
    }
    return [list $ok $dirs $stderr $command]
}

# The library file the configuration's linker would use for -lNAME (its
# -print-file-name=libNAME.a), or "" when it has none.
proc ::chdr::toolchain::libraryFile {config profile name} {
    set command [concat [dict get $config cc] [CommonWords $config $profile] [list -print-file-name=lib$name.a]]
    lassign [Exec $command] ok out stderr
    set path [string trim $out]
    if {!$ok || $path eq "" || $path eq "lib$name.a" || ![file exists $path]} { return "" }
    return [file normalize $path]
}

# The external symbols the object or archive PATH defines (WHICH defined)
# or references undefined (WHICH undefined), sorted: BOTLISH_C_NM, else
# llvm-nm for a clang-family configuration when installed, else nm.
# {OK SYMBOLS STDERR COMMAND}.
proc ::chdr::toolchain::symbolsOf {config path {which defined}} {
    set nm [Words BOTLISH_C_NM]
    if {$nm eq ""} {
        set nm [expr {[dict get $config family] eq "clang" && [auto_execok llvm-nm] ne "" ? "llvm-nm" : "nm"}]
    }
    set flag [expr {$which eq "defined" ? "--defined-only" : "--undefined-only"}]
    set command [concat $nm [list -g $flag --format=posix $path]]
    lassign [Exec $command] ok out stderr
    set symbols {}
    foreach line [split $out \n] {
        # posix format: NAME TYPE [VALUE [SIZE]]; an archive's member lines
        # (NAME[member]:) and blank lines carry no symbol.
        if {[regexp {^(\S+) ([A-Za-z]) ?} $line -> sym type] && ![string match *: $sym]} {
            lappend symbols $sym
        }
    }
    return [list $ok [lsort -unique $symbols] $stderr $command]
}

# A description of the configuration for the import profile record.
proc ::chdr::toolchain::describe {config} {
    set host "$::tcl_platform(os) $::tcl_platform(osVersion) $::tcl_platform(machine)"
    return [dict create cc [dict get $config cc] path [dict get $config path] \
        family [dict get $config family] version [dict get $config version] \
        style [dict get $config style] target [expr {[dict get $config target] eq "" ? "native" : [dict get $config target]}] \
        sysroot [expr {[dict exists $config sysroot] && [dict get $config sysroot] ne "" ? "set" : "none"}] \
        host $host]
}

# rust-unit.tcl -- the author's side of a Rust native unit: a Rust
# staticlib localized into a static archive that an executable linking the
# Botlish runtime -- Rust too -- can take (HTTP-MACOS-RUST-ARCHIVE-LINK-
# FEASIBILITY-MILESTONE-1.md; the HTTP stack census's B3).
#
#   tclsh9.0 tools/rust-unit.tcl localize -target T -exports PATTERNS RAW OUT
#       localize the cargo staticlib RAW into the archive OUT for target T
#       (linux-x86_64, linux-aarch64: ELF; macos-aarch64: Mach-O); its only
#       global definitions are the symbols matching PATTERNS (glob patterns,
#       C names: bh_*); prints the exports
#   tclsh9.0 tools/rust-unit.tcl surface -target T FILE
#       the global symbols FILE defines (C names), one per line
#
# Sourced: rustunit::Localize, Surface, Defined, Format (tools/http-package.tcl,
# audit/rust-archive-link/tools/rlf.tcl).
#
# Why. A Rust staticlib carries its own copy of the Rust standard library,
# its panic runtime, personality routine and allocator shim, as global
# symbols. An executable that also links the Botlish runtime links a second
# copy: two definitions of `__rust_alloc`, `rust_eh_personality` and every
# monomorphic standard-library function the two toolchains share -- a
# duplicate-symbol failure, or, where one toolchain built both, the unit
# silently bound to the runtime's copy. Localizing makes the unit one
# relocatable object whose only global definitions are its C ABI; its
# undefined references (libc, a provider's archive) stay undefined for the
# final link, which every consumer makes with no flag of its own.
#
# ELF (GNU binutils): `ld -r --whole-archive`, then `objcopy
# --keep-global-symbols` with the debug sections stripped and Rust's one
# COMDAT group (DW.ref.rust_eh_personality) renamed -- a COMDAT group is
# deduplicated by its signature's name across the whole link, so beside the
# runtime's own Rust code the unit's must be its own (the census's B3) --
# then a deterministic archive (`ar rcsD`). These are the commands
# tools/http-package.tcl ran since http 0.1.0, in the same order: its units
# are byte-identical through this file.
#
# Mach-O (Apple's tools): `ld -r -force_load` of the staticlib with
# `-exported_symbols_list` (the exports, Apple-spelled `_NAME`) makes every
# other global symbol private extern and, without -keep_private_externs,
# static: none is left global, not even hidden (a private extern is still
# global to a static link, and collides as one). `-S` keeps no debug
# information (DWARF or STABS: no object path, no build directory). Mach-O
# has no COMDAT groups, so nothing is renamed. The archive is made by
# `libtool -static -D` (deterministic: no dates, owners or modes) under
# ZERO_AR_DATE=1. Every claim of this paragraph is checked where the
# milestone's CI runs it (`surface`, `nm -m`), not assumed.
namespace eval rustunit {
    variable here [file dirname [file normalize [info script]]]
    variable root [file dirname $here]
}

# The object format of TARGET's native files: elf or macho.
proc rustunit::Format {target} {
    switch -glob -- $target {
        linux-* { return elf }
        macos-* { return macho }
    }
    error "rust-unit: no localization for target $target (ELF: linux-*; Mach-O: macos-*)"
}

# Apple's -arch name of TARGET (macos-aarch64: arm64).
proc rustunit::AppleArch {target} {
    switch -- $target {
        macos-aarch64 { return arm64 }
    }
    error "rust-unit: no Apple architecture for target $target"
}

# Run SCRIPT in the caller's frame with the environment variables of VARS
# set, then put back exactly those variables (never `array unset env`: it
# unlinks Tcl's env array from the process environment).
proc rustunit::WithEnv {vars script} {
    set saved {}
    dict for {k v} $vars {
        dict set saved $k [expr {[info exists ::env($k)] ? [list 1 $::env($k)] : [list 0 {}]}]
        set ::env($k) $v
    }
    try {
        uplevel 1 $script
    } finally {
        dict for {k state} $saved {
            lassign $state had value
            if {$had} {
                set ::env($k) $value
            } else {
                unset -nocomplain ::env($k)
            }
        }
    }
}

# Defined global symbols of the ELF FILE (GNU nm), as http-package.tcl's
# Defined read them: every defined symbol whose type letter is uppercase
# (weak ones included: W, V; never U).
proc rustunit::DefinedElf {file} {
    set out {}
    foreach line [split [exec nm -A --defined-only $file 2>/dev/null] \n] {
        if {[regexp {^(.*):([0-9a-f]+)? +([A-Za-z]) +(\S+)$} $line -> where addr type sym]} {
            if {![string is lower $type] && $type ni {U w v}} {
                lappend out $sym
            }
        }
    }
    return [lsort -unique $out]
}

# Defined global symbols of the Mach-O FILE (Apple's nm, POSIX output), as
# C names (Apple's leading underscore dropped). A private extern -- global
# to a static link, hidden from a dynamic one -- counts: nm -g lists it.
proc rustunit::DefinedMacho {file} {
    set out {}
    foreach line [split [exec nm -g -P $file 2>/dev/null] \n] {
        set fields [regexp -inline -all {\S+} $line]
        if {[llength $fields] < 2 || [string match *: [lindex $fields 0]]} continue
        lassign $fields sym type
        if {[string length $type] != 1 || $type in {U u} || [string is lower $type]} continue
        if {[string index $sym 0] eq "_"} {
            set sym [string range $sym 1 end]
        }
        lappend out $sym
    }
    return [lsort -unique $out]
}

# Defined global symbols of FILE (an object or an archive) of FORMAT.
proc rustunit::Defined {format file} {
    switch -- $format {
        elf { return [DefinedElf $file] }
        macho { return [DefinedMacho $file] }
    }
    error "rust-unit: no format $format"
}

# The symbols of SYMBOLS matching one of the glob PATTERNS.
proc rustunit::Matching {symbols patterns} {
    set out {}
    foreach s $symbols {
        foreach p $patterns {
            if {[string match $p $s]} {
                lappend out $s
                break
            }
        }
    }
    return $out
}

proc rustunit::WriteLines {path lines} {
    set f [open $path w]
    puts $f [join $lines \n]
    close $f
}

# Localize the cargo staticlib RAW for TARGET into the archive UNIT: one
# relocatable object whose only global definitions are the symbols matching
# PATTERNS (C names), in a deterministic archive. WORK is a scratch
# directory (its files are left there: keep lists, the object). The
# exports, sorted.
proc rustunit::Localize {target raw unit patterns work} {
    set format [Format $target]
    file mkdir $work
    # The unit's name without its "lib": the archive's one member is
    # NAME.o, and NAME prefixes the renamed COMDAT signature (ELF).
    set prefix [file rootname [file tail $unit]]
    regsub {^lib} $prefix {} prefix
    set object [file join $work $prefix.o]
    set keep [file join $work keep.txt]
    file delete -force $object $unit
    switch -- $format {
        elf {
            # One relocatable object of the whole unit, whose only global
            # definitions are the exports: its private Rust standard library
            # never meets the Botlish runtime's. Undefined references stay
            # undefined (global) for the final link.
            exec ld -r --whole-archive $raw -o $object
            set exports [Matching [DefinedElf $object] $patterns]
            WriteLines $keep $exports
            # Rust's one COMDAT group (DW.ref.rust_eh_personality) is
            # deduplicated by its signature's name across the whole link:
            # beside the Botlish runtime's own Rust code the unit's must be
            # its own (B3).
            set groups [regexp -all -inline {COMDAT group section \[[^\]]*\] `[^']*' \[([^\]]+)\]} [exec readelf -g $object]]
            set rename {}
            foreach {- sig} $groups {
                lappend rename --redefine-sym $sig=$prefix.$sig
            }
            exec objcopy --strip-debug {*}$rename --keep-global-symbols=$keep $object
            exec ar rcsD $unit $object
        }
        macho {
            set arch [AppleArch $target]
            set exports [Matching [DefinedMacho $raw] $patterns]
            if {$exports eq ""} {
                error "rust-unit: $raw defines no symbol matching $patterns"
            }
            WriteLines $keep [lmap s $exports {string cat _ $s}]
            WithEnv {ZERO_AR_DATE 1} {
                exec ld -r -arch $arch -S -exported_symbols_list $keep -o $object -force_load $raw 2>@stderr
                exec libtool -static -D -no_warning_for_no_symbols -o $unit $object 2>@stderr
            }
        }
    }
    file delete $object
    return $exports
}

# The global symbols the localized UNIT defines (C names): exactly its
# exports when localization did its work.
proc rustunit::Surface {target unit} {
    return [Defined [Format $target] $unit]
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    set opts [dict create -target "" -exports bh_* -work ""]
    set args [lrange $::argv 1 end]
    set positional {}
    for {set i 0} {$i < [llength $args]} {incr i} {
        set a [lindex $args $i]
        if {[string match -* $a]} {
            dict set opts $a [lindex $args [incr i]]
        } else {
            lappend positional $a
        }
    }
    set target [dict get $opts -target]
    switch -- [lindex $::argv 0] {
        localize {
            lassign $positional raw out
            set work [dict get $opts -work]
            if {$work eq ""} { set work [file join [file dirname [file normalize $out]] localize-work] }
            puts [join [rustunit::Localize $target [file normalize $raw] [file normalize $out] [dict get $opts -exports] $work] \n]
        }
        surface {
            puts [join [rustunit::Surface $target [lindex $positional 0]] \n]
        }
        default {
            puts stderr "usage: tclsh9.0 tools/rust-unit.tcl localize -target T -exports PATTERNS RAW OUT | surface -target T FILE"
            exit 2
        }
    }
}

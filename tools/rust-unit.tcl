# rust-unit.tcl -- localizing a Rust static library for a Botlish package
# (HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md). A package's
# native unit written in Rust (packages/http/native, the milestone's fixture
# audit/rust-archive-link/unit) is linked into executables that also hold
# the Botlish runtime, which is Rust too: two copies of Rust's standard
# library, its allocator shim, its personality routine. Localization makes
# the unit's archive one object whose only global definitions are the
# unit's C ABI (and the symbols it must leave interposable), so nothing of
# its Rust meets the runtime's. Author's side only: a consumer links the
# localized archive and runs none of this.
#
#   rustunit::localize RAW OUT -format elf|macho -keep GLOBS ?-require NAMES?
#                      ?-label LABEL? ?-arch ARCH? ?-member NAME.o? ?-macos MIN?
#       RAW, the archive cargo made, into OUT, a deterministic archive of
#       one relocatable object: global definitions matching GLOBS are kept
#       (C names: without Mach-O's leading underscore), every other one
#       becomes local; references stay undefined for the final link. Each
#       name of NAMES must be among the kept ones (an export the unit was
#       meant to have and does not is an error here, not at a consumer's
#       link). MEMBER: the object's name in OUT (default OUT's root name
#       with .o). Returns the kept names.
#   rustunit::globals FILE ?-format F?    FILE's global definitions (C names),
#                                         locals excluded
#   rustunit::undefined FILE ?-format F?  FILE's undefined references
#   rustunit::check ARCHIVE NAMES ?-format F?
#       an error unless ARCHIVE's global definitions are exactly NAMES
#
# ELF (Linux): GNU ld -r --whole-archive, objcopy --keep-global-symbols
# with the debug sections stripped and every COMDAT group signature renamed
# LABEL.SIGNATURE (Rust's DW.ref.rust_eh_personality group is deduplicated
# by its signature's name across the whole link: beside the runtime's own
# it must be the unit's; HTTP-SHIPPING-CENSUS.md's B3), ar rcsD -- the
# sequence tools/http-package.tcl ran for botlish_http before it called
# this procedure, unchanged, so its archives are byte for byte what they
# were.
#
# Mach-O (macOS): Apple's ld -r -S with the archive force-loaded, the
# platform and deployment target (-platform_version: ld -r writes none
# otherwise) and an exported-symbols list: every global definition the
# list does not name
# becomes private extern, which ld -r (without -keep_private_externs) makes
# a local symbol; the debug information is left out (-S). Mach-O has no
# COMDAT groups: a weak definition (Rust's generic instances, its
# personality pointer) the list does not name becomes local too. The object
# is archived by libtool -static -D (no dates, owners or modes;
# ZERO_AR_DATE for the index). Nothing is computed about a symbol's binding
# or visibility here: ld decides, and `check` reads the result with nm.
namespace eval rustunit {}

proc rustunit::Fail {message} {
    return -code error -errorcode {RUSTUNIT} "rust-unit: $message"
}

proc rustunit::Options {defaults argv} {
    set opts $defaults
    foreach {k v} $argv {
        if {![dict exists $defaults $k]} {
            Fail "unknown option $k (known: [join [dict keys $defaults] {, }])"
        }
        dict set opts $k $v
    }
    return $opts
}

# The object format of this host's native files.
proc rustunit::HostFormat {} {
    if {$::tcl_platform(os) eq "Darwin"} {
        return macho
    }
    return elf
}

# nm ARGS: its standard output. Apple's nm (llvm-nm) exits non-zero when it
# warns -- a member with no symbols, which a Rust static library has --
# after printing every other file's symbols: its output is taken then, when
# all it said is that some member has no symbols; an nm that printed
# nothing, or said anything else, is an error (with what it said).
proc rustunit::Nm {args} {
    set err [file join [expr {[info exists ::env(TMPDIR)] && $::env(TMPDIR) ne "" ? $::env(TMPDIR) : "/tmp"}] rustunit-nm-[pid].err]
    set failed [catch {exec nm {*}$args 2>$err} out opts]
    set said ""
    if {[file exists $err]} {
        set f [open $err r]
        set said [string trim [read $f]]
        close $f
        file delete $err
    }
    if {$failed} {
        if {[lindex [dict get $opts -errorcode] 0] ne "CHILDSTATUS"} {
            Fail "nm [join $args]: $out"
        }
        # exec's message is the output and a last line of its own.
        set lines [split $out \n]
        if {[lindex $lines end] eq "child process exited abnormally"} {
            set out [join [lrange $lines 0 end-1] \n]
        }
        if {[string trim $out] eq ""} {
            Fail "nm [join $args] printed nothing (exit [lindex [dict get $opts -errorcode] 2]): [string range $said 0 600]"
        }
        # Only a member with no symbols may have made it fail: anything else
        # it said may be a member it did not read (a partial list).
        foreach line [split $said \n] {
            if {[string trim $line] eq "" || [string match "*no symbols*" $line]} continue
            Fail "nm [join $args] failed (exit [lindex [dict get $opts -errorcode] 2]) after printing: [string range $line 0 600]"
        }
    }
    return $out
}

# nm ARGS for a Mach-O file. A Rust unit holds the Rust standard
# library's objects, which embed their LLVM bitcode (__LLVM,__bitcode), and
# Apple's nm reads an object's symbols from its bitcode when it has some --
# bitcode of a newer LLVM than Xcode's (rustc 1.97.0's LLVM 22 against
# Xcode 16.4's) it cannot read, and prints nothing. --no-llvm-bc makes it
# read the Mach-O symbol table, which is what a link uses (a link that is
# no LTO link never reads the bitcode). An nm without the option (an older
# one) is asked without it.
proc rustunit::MachoNm {args} {
    if {[catch {Nm --no-llvm-bc {*}$args} out]} {
        if {![regexp -nocase {unknown (command line )?(argument|option)|unrecognized option} $out]} {
            error $out $::errorInfo $::errorCode
        }
        set out [Nm {*}$args]
    }
    return $out
}

# The defined (DEFINED 1) or undefined (DEFINED 0) global symbols of FILE,
# C names, sorted and unique: every symbol another object of the final
# link can resolve against. ELF: nm's upper-case types (a weak definition,
# W or V, included; U excluded; a hidden one too: visibility binds only
# the linked image, not the link). Mach-O: nm -m's "external", "weak
# external" and "private external" symbols -- a private external
# (visibility hidden, as Rust's allocator shim is on Apple targets) is
# resolved between the objects of a link like any external -- never
# "non-external" ones.
proc rustunit::Symbols {file format defined} {
    set out {}
    if {$format eq "elf"} {
        foreach line [split [Nm -A $file] \n] {
            if {![regexp {^(.*):([0-9a-f]+)? +([A-Za-z]) +(\S+)$} $line -> where addr type sym]} continue
            if {$defined} {
                if {![string is upper $type] || $type eq "U"} continue
            } else {
                if {$type ni {U w v}} continue
            }
            lappend out $sym
        }
    } elseif {$format eq "macho"} {
        foreach line [split [MachoNm -m $file] \n] {
            set undefined [string match "*(undefined)*" $line]
            if {$defined == $undefined} continue
            if {[string match "*non-external*" $line]} continue
            if {![regexp {\mexternal (\S+)} $line -> sym]} continue
            if {[string index $sym 0] eq "_"} {
                set sym [string range $sym 1 end]
            }
            lappend out $sym
        }
    } else {
        Fail "unknown object format $format (elf, macho)"
    }
    return [lsort -unique $out]
}

proc rustunit::globals {file args} {
    set opts [Options [dict create -format [HostFormat]] $args]
    return [Symbols $file [dict get $opts -format] 1]
}

proc rustunit::undefined {file args} {
    set opts [Options [dict create -format [HostFormat]] $args]
    return [Symbols $file [dict get $opts -format] 0]
}

proc rustunit::Matching {names globs} {
    set out {}
    foreach name $names {
        foreach g $globs {
            if {[string match $g $name]} {
                lappend out $name
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

# An error unless PATH is a Mach-O 64-bit object that HOW wrote.
proc rustunit::MachoObject {path how} {
    if {![file isfile $path] || [file size $path] < 32} {
        Fail "$how wrote no object ([file tail $path] [expr {[file exists $path] ? "has [file size $path] bytes" : "does not exist"}])"
    }
    set f [open $path rb]
    set head [read $f 4]
    close $f
    if {$head ne "\xcf\xfa\xed\xfe"} {
        Fail "$how wrote [file tail $path], which is no Mach-O 64-bit object"
    }
}

# The deployment target and the SDK a Mach-O unit's object records
# (LC_BUILD_VERSION): Apple's ld -r writes no platform load command unless
# told one, and every final link then warns "no platform load command
# found ..., assuming: macOS". MIN: the -macos option, else
# MACOSX_DEPLOYMENT_TARGET, else 11.0 (rustc's for aarch64-apple-darwin);
# the SDK: xcrun's.
proc rustunit::MacosPlatform {min} {
    if {$min eq ""} {
        set min 11.0
        if {[info exists ::env(MACOSX_DEPLOYMENT_TARGET)] && $::env(MACOSX_DEPLOYMENT_TARGET) ne ""} {
            set min $::env(MACOSX_DEPLOYMENT_TARGET)
        }
    }
    if {[catch {exec xcrun --show-sdk-version 2>@1} sdk]} {
        Fail "xcrun --show-sdk-version: $sdk"
    }
    return [list -platform_version macos $min [string trim $sdk]]
}

proc rustunit::localize {raw out args} {
    set opts [Options [dict create -format [HostFormat] -keep {} -require {} -label unit -arch arm64 -member "" -macos ""] $args]
    set format [dict get $opts -format]
    if {![file isfile $raw]} {
        Fail "$raw: no such archive"
    }
    set raw [file normalize $raw]
    set out [file normalize $out]
    set dir [file dirname $out]
    file mkdir $dir
    set work [file join $dir [file rootname [file tail $out]].work]
    file delete -force $work
    file mkdir $work
    set member [dict get $opts -member]
    if {$member eq ""} {
        set member [file rootname [file tail $out]].o
    }
    set object [file join $work $member]
    try {
        if {$format eq "elf"} {
            # One relocatable object of the whole unit, whose only global
            # definitions are the kept ones; references stay undefined.
            exec ld -r --whole-archive $raw -o $object
            set kept [Matching [Symbols $object elf 1] [dict get $opts -keep]]
            set keep [file join $work keep.txt]
            WriteLines $keep $kept
            set groups [regexp -all -inline {COMDAT group section \[[^\]]*\] `[^']*' \[([^\]]+)\]} [exec readelf -g $object]]
            set rename {}
            foreach {- sig} $groups {
                lappend rename --redefine-sym $sig=[dict get $opts -label].$sig
            }
            exec objcopy --strip-debug {*}$rename --keep-global-symbols=$keep $object
            file delete -force $out
            exec ar rcsD $out $object
        } elseif {$format eq "macho"} {
            set arch [dict get $opts -arch]
            set platform [MacosPlatform [dict get $opts -macos]]
            # The whole unit (-force_load: every member of the archive)
            # once, to read its global definitions; then again with the
            # list of those it keeps.
            set whole [file join $work whole.o]
            exec ld -r -arch $arch {*}$platform -S -force_load $raw -o $whole 2>@stderr
            MachoObject $whole "ld -r -force_load"
            set kept [Matching [Symbols $whole macho 1] [dict get $opts -keep]]
            set keep [file join $work exported.txt]
            WriteLines $keep [lmap s $kept {string cat _ $s}]
            exec ld -r -arch $arch {*}$platform -S -force_load $raw -exported_symbols_list $keep -o $object 2>@stderr
            MachoObject $object "ld -r -force_load -exported_symbols_list"
            file delete -force $out
            set saved [expr {[info exists ::env(ZERO_AR_DATE)] ? [list 1 $::env(ZERO_AR_DATE)] : {0 {}}}]
            set ::env(ZERO_AR_DATE) 1
            try {
                exec libtool -static -D -no_warning_for_no_symbols -o $out $object 2>@stderr
            } finally {
                if {[lindex $saved 0]} { set ::env(ZERO_AR_DATE) [lindex $saved 1] } else { unset ::env(ZERO_AR_DATE) }
            }
        } else {
            Fail "unknown object format $format (elf, macho)"
        }
        set missing {}
        foreach name [dict get $opts -require] {
            if {$name ni $kept} {
                lappend missing $name
            }
        }
        if {$missing ne ""} {
            file delete -force $out
            Fail "$raw does not define [join $missing {, }] (required exports; it defines [llength $kept] matching [join [dict get $opts -keep] {, }])"
        }
        return $kept
    } finally {
        file delete -force $work
    }
}

proc rustunit::check {archive names args} {
    set opts [Options [dict create -format [HostFormat]] $args]
    set have [globals $archive -format [dict get $opts -format]]
    set want [lsort -unique $names]
    if {$have ne $want} {
        set extra [lmap s $have {expr {$s in $want ? [continue] : $s}}]
        set absent [lmap s $want {expr {$s in $have ? [continue] : $s}}]
        Fail "$archive: global definitions differ from the unit's exports: [llength $extra] more ([join [lrange $extra 0 9] { }][expr {[llength $extra] > 10 ? " ..." : ""}]), [llength $absent] missing ([join $absent { }])"
    }
    return $have
}

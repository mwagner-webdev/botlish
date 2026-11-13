# native.tcl -- native dependencies of a target view: verification, the
# application's native closure, and its deployment plan
# (PACKAGE-MANAGER-MILESTONE-2.md, "Native verification", "Native
# deployment").
#
#   pm::native::Plan TARGET INSTANCES ORIGINS    the native plan of a view
#   pm::native::CheckBundled TARGET LIBRARY BYTES LABEL   a bundled file's
#                                               facts, or {PM NATIVE}
#   pm::native::System TARGET LIBRARY           a system library's evidence
#   pm::native::SourceLinks TEXT                a module's link declarations
#
# INSTANCES are the view's package instances, in tree order, each a dict
# {instance I name N version V descriptor D dir VIEWDIR}: their native
# metadata (schema 2's targets.T.libraries, frameworks, headers) and the
# files a view holds. The plan is the whole application's: nested Botlish
# package instances are separate modules, but one process has one native
# loader namespace, so one library name, one loader identity and one
# exported symbol must mean one thing across every instance.
#
# What is verified, and what is not (the report's section D):
#
#   * a bundled file is read, never run: its format, architecture, kind
#     (static archive, import library, shared library), loader identity,
#     loader dependencies and, when declared, exported symbols must be what
#     its metadata says and what the target is (pm/binary.tcl);
#   * a system library is verified only on its own target's host, and only
#     by system metadata: the distribution's package database (dpkg) owning
#     the file, or a pkg-config record in the system's directories naming
#     its directory; the file is then inspected as a bundled one is. A file
#     merely present in a library directory is no system installation;
#   * a version is the metadata's version (dpkg's, pkg-config's), compared
#     by its numbers with the request: a version is not an ABI, so the
#     loader identity and the declared symbols are checked too;
#   * for another target than the host, system libraries are unverified,
#     and the plan says so;
#   * glibc's symbol versions a Linux library requires are compared with
#     the host's C library when the target is the host's.

namespace eval pm::native {
    variable platformCache [dict create]
}

proc pm::native::Fail {message} {
    return -code error -errorcode {PM NATIVE} $message
}

# The selected form of FACTS for TARGET: a universal Mach-O's slice for the
# target's architecture (or "" when it has none), else FACTS.
proc pm::native::Slice {target facts} {
    if {[dict get $facts kind] ne "fat"} {
        return $facts
    }
    set want [dict get [pm::target::facts $target] machine]
    foreach slice [dict get $facts slices] {
        if {[dict get $slice cputype] == $want} {
            return [dict get $slice facts]
        }
    }
    return ""
}

# 1 if the object FACTS (an archive member, or a whole file) is of TARGET's
# format and machine.
proc pm::native::Matches {target facts} {
    set t [pm::target::facts $target]
    switch -- [dict get $facts kind] {
        elf {
            return [expr {[dict get $t format] eq "elf" && [dict get $facts class] == 64
                && [dict get $facts endian] eq "le" && [dict get $facts machine] == [dict get $t machine]}]
        }
        macho {
            return [expr {[dict get $t format] eq "macho" && [dict get $facts cputype] == [dict get $t machine]}]
        }
        coff - import - pe {
            return [expr {[dict get $t format] eq "pe" && [dict get $facts machine] == [dict get $t machine]}]
        }
    }
    return 0
}

# The facts of a static archive ARCHIVE for TARGET: {objects N imports
# {DLL...} index {SYMBOL...}}, or a refusal.
proc pm::native::ArchiveFacts {target archive label} {
    set objects 0
    set imports {}
    set foreign {}
    foreach member [dict get $archive members] {
        set kind [dict get $member kind]
        if {$kind in {symbols names bitcode}} continue
        if {$kind eq "fat"} {
            set member [Slice $target $member]
            if {$member eq ""} {
                lappend foreign "a universal member without a slice for $target"
                continue
            }
            set kind [dict get $member kind]
        }
        if {$kind eq "import" || ($kind eq "coff" && [dict exists $member dll])} {
            lappend imports [dict get $member dll]
            if {![Matches $target $member]} {
                lappend foreign "[dict get $member name]: [pm::binary::describe $member]"
            }
            continue
        }
        if {$kind ni {elf macho coff}} {
            lappend foreign "[dict get $member name]: [pm::binary::describe $member]"
            continue
        }
        if {$kind eq "elf" && [dict get $member type] ne "rel"} {
            lappend foreign "[dict get $member name]: [pm::binary::describe $member] (an archive holds objects)"
            continue
        }
        if {![Matches $target $member]} {
            lappend foreign "[dict get $member name]: [pm::binary::describe $member]"
            continue
        }
        incr objects
    }
    if {$foreign ne ""} {
        set shown [lrange $foreign 0 4]
        if {[llength $foreign] > 5} { lappend shown "... ([llength $foreign] members)" }
        Fail "$label holds members that are not $target objects: [join $shown {; }]"
    }
    return [dict create objects $objects imports [lsort -unique -nocase $imports] index [dict get $archive index] \
        weak [dict getdef $archive weak {}]]
}

# The highest version of PREFIX (GLIBC_) in VERSIONS, as a list of numbers,
# or "".
proc pm::native::Highest {versions prefix} {
    set best ""
    foreach version $versions {
        if {![regexp "^${prefix}(\[0-9\]+(?:\\.\[0-9\]+)*)\$" $version -> number]} continue
        set parts [split $number .]
        if {$best eq "" || [Compare $parts $best] > 0} {
            set best $parts
        }
    }
    return $best
}

proc pm::native::Compare {a b} {
    foreach x $a y $b {
        if {$x eq ""} { set x 0 }
        if {$y eq ""} { set y 0 }
        if {$x != $y} {
            return [expr {$x < $y ? -1 : 1}]
        }
    }
    return 0
}

# Checks the bundled file of LIBRARY (its bytes BYTES, read from the view)
# for TARGET; its facts {description D identity I needs {...} glibc G
# signed S rpath R imports {...}}. IMPORTBYTES is the import library's (a
# Windows DLL's), else "".
proc pm::native::CheckBundled {target library bytes label {importBytes ""}} {
    set name [dict get $library name]
    set linkage [dict get $library linkage]
    set t [pm::target::facts $target]
    set facts [pm::binary::inspect $bytes $label]
    set what [pm::binary::describe $facts]
    set result [dict create description $what identity "" needs {} glibc "" signed "" rpath {} symbols {}]
    if {$linkage eq "static"} {
        if {[dict get $facts kind] ne "archive"} {
            Fail "$label is $what, and library $name is declared a static archive for $target: a static library is an ar archive of $target objects (never a shared library, a stub, a linker script or a thin archive)"
        }
        set archive [ArchiveFacts $target $facts $label]
        if {[dict get $archive imports] ne ""} {
            Fail "$label is an import library of [join [dict get $archive imports] {, }], and library $name is declared a static archive: an import library links a DLL, which must then be deployed (declare it shared, with the DLL as its file and this as its import)"
        }
        if {[dict get $archive objects] == 0} {
            Fail "$label holds no $target object"
        }
        foreach symbol [dict get $library symbols] {
            if {$symbol ni [dict get $archive index]} {
                Fail "$label: library $name does not define the declared symbol $symbol (its archive index)"
            }
        }
        dict set result symbols [dict get $archive index]
        dict set result weak [dict get $archive weak]
        dict set result description "$what"
        return $result
    }
    # Shared.
    set facts [Slice $target $facts]
    if {$facts eq ""} {
        Fail "$label is $what, with no slice for $target"
    }
    if {![Matches $target $facts]} {
        Fail "$label is [pm::binary::describe $facts], and $target's libraries are [dict get $t format] [dict get $t arch]"
    }
    set identity [dict get $library identity]
    switch -- [dict get $t format] {
        elf {
            if {[dict get $facts type] ne "dyn"} {
                Fail "$label is [pm::binary::describe $facts], not a shared object"
            }
            set actual [dict get $facts soname]
            set needed [dict get $facts needed]
            foreach need $needed {
                if {[string match libc.musl-* $need] || [string match ld-musl-* $need]} {
                    Fail "$label needs $need: it was built against musl, and $target is the GNU C library's target"
                }
            }
            if {[string match *ld-musl* [dict get $facts interpreter]]} {
                Fail "$label uses musl's loader: $target is the GNU C library's target"
            }
            dict set result glibc [Highest [dict getdef [dict get $facts verneed] libc.so.6 {}] GLIBC_]
            dict set result rpath [concat [dict get $facts runpath] [dict get $facts rpath]]
        }
        macho {
            if {[dict get $facts filetype] ne "dylib"} {
                Fail "$label is [pm::binary::describe $facts], not a dynamic library"
            }
            set actual [dict get $facts id]
            set needed [dict get $facts needed]
            dict set result signed [dict get $facts signed]
            dict set result rpath [dict get $facts rpath]
        }
        pe {
            if {![dict get $facts dll]} {
                Fail "$label is [pm::binary::describe $facts], not a DLL"
            }
            set actual [file tail [dict get $library file]]
            if {[dict get $facts name] ne "" && ![string equal -nocase [dict get $facts name] $actual]} {
                Fail "$label exports itself as [dict get $facts name], and its file is named $actual: a DLL is loaded by its file name"
            }
            set needed [dict get $facts needed]
        }
    }
    if {($target ne "" && [dict get $t format] eq "pe" && ![string equal -nocase $actual $identity])
            || ([dict get $t format] ne "pe" && $actual ne $identity)} {
        Fail "$label's loader identity is \"$actual\", and its metadata declares \"$identity\": a consumer's executable would ask the loader for the declared one"
    }
    set declared [dict get $library needs]
    set fold [expr {[dict get $t format] eq "pe" ? "-nocase" : "-ascii"}]
    if {[lsort -unique $fold $needed] ne [lsort -unique $fold $declared]} {
        Fail "$label needs [Or [lsort -unique $needed]], and its metadata declares [Or [lsort -unique $declared]]: every loader dependency is declared, so the plan can resolve it"
    }
    foreach symbol [dict get $library symbols] {
        if {$symbol ni [dict get $facts symbols]} {
            Fail "$label does not export the declared symbol $symbol"
        }
    }
    dict set result identity $actual
    dict set result needs $needed
    dict set result symbols [dict get $facts symbols]
    dict set result description [pm::binary::describe $facts]
    if {[dict get $t format] eq "pe"} {
        # The import library the linker links must import this DLL.
        if {$importBytes eq ""} {
            Fail "$label: no import library"
        }
        set import [pm::binary::inspect $importBytes "the import library of $name"]
        if {[dict get $import kind] ne "archive"} {
            Fail "the import library of $name is [pm::binary::describe $import], not an import library"
        }
        set archive [ArchiveFacts $target $import "the import library of $name"]
        if {[dict get $archive imports] eq ""} {
            Fail "the import library of $name imports no DLL: it is a static archive"
        }
        if {[lsearch -exact -nocase [dict get $archive imports] $identity] < 0} {
            Fail "the import library of $name imports [join [dict get $archive imports] {, }], not $identity"
        }
    }
    return $result
}

proc pm::native::Or {list} {
    if {$list eq ""} { return "nothing" }
    return [join $list {, }]
}

# ---------------------------------------------------------------------------
# System libraries (verified on their own target only)

# The library directories of a Linux TARGET, in the order its loader and
# linker search them by default (Debian's multiarch layout first).
proc pm::native::LinuxDirs {target} {
    set triplet [dict get {x86_64 x86_64-linux-gnu aarch64 aarch64-linux-gnu} [dict get [pm::target::facts $target] arch]]
    return [list /usr/lib/$triplet /lib/$triplet /usr/lib /lib /usr/lib64 /usr/local/lib /usr/local/lib/$triplet]
}

# The distribution's pkg-config directories of a Linux TARGET. /usr/local's
# are left out on purpose: a record there was written by whatever installed
# a library by hand, not by the system's package management, and is no
# evidence that the library is system-managed.
proc pm::native::PkgConfigDirs {target} {
    set triplet [dict get {x86_64 x86_64-linux-gnu aarch64 aarch64-linux-gnu} [dict get [pm::target::facts $target] arch]]
    return [list /usr/lib/$triplet/pkgconfig /usr/lib/pkgconfig /usr/share/pkgconfig]
}

# The variables and fields of the pkg-config file PATH: {Version V Libs L
# ...} with ${var} expanded.
proc pm::native::PcFile {path} {
    set vars [dict create pcfiledir [file dirname $path]]
    set fields [dict create]
    foreach line [split [pm::ReadBytes $path] \n] {
        set line [string trim $line]
        if {$line eq "" || [string index $line 0] eq "#"} continue
        if {[regexp {^([A-Za-z0-9_.]+)\s*=\s*(.*)$} $line -> key value]} {
            dict set vars $key [Expand $value $vars]
        } elseif {[regexp {^([A-Za-z0-9_.]+):\s*(.*)$} $line -> key value]} {
            dict set fields $key [Expand $value $vars]
        }
    }
    return $fields
}

proc pm::native::Expand {text vars} {
    for {set i 0} {$i < 16 && [regexp {\$\{([A-Za-z0-9_.]+)\}} $text -> var]} {incr i} {
        set text [string map [list "\${$var}" [dict getdef $vars $var ""]] $text]
    }
    return $text
}

# The dpkg package owning PATH (or the file it resolves to), with its
# version: {package P version V}, or "" when the distribution's package
# database has no record of it (or there is no dpkg database).
proc pm::native::DpkgOwner {path} {
    set info /var/lib/dpkg/info
    if {![file isdirectory $info]} {
        return ""
    }
    set candidates [list $path]
    catch {lappend candidates [file normalize [file join [file dirname $path] [file readlink $path]]]}
    catch {lappend candidates [file normalize $path]}
    # Debian lists /lib/... files under /usr/lib/... after the /usr merge
    # and the reverse before it: both spellings.
    foreach candidate [lrange $candidates 0 end] {
        if {[string match /lib/* $candidate]} {
            lappend candidates /usr$candidate
        } elseif {[string match /usr/lib/* $candidate]} {
            lappend candidates [string range $candidate 4 end]
        }
    }
    set owner ""
    foreach list [glob -nocomplain -directory $info *.list] {
        set text [pm::ReadBytes $list]
        foreach candidate $candidates {
            if {[string first "$candidate\n" $text] >= 0} {
                set owner [file rootname [file tail $list]]
                break
            }
        }
        if {$owner ne ""} break
    }
    if {$owner eq ""} {
        return ""
    }
    set package [lindex [split $owner :] 0]
    set version ""
    if {[file isfile /var/lib/dpkg/status]} {
        foreach stanza [split [string map {"\n\n" \x01} [pm::ReadBytes /var/lib/dpkg/status]] \x01] {
            if {[regexp -line "^Package: [string map {+ \\+ . \\.} $package]\$" $stanza]
                    && [regexp -line {^Status: install ok installed$} $stanza]
                    && [regexp -line {^Version: (\S+)$} $stanza -> version]} {
                break
            }
        }
    }
    return [dict create package $owner version $version]
}

# The numbers of a distribution's version text (an epoch and any suffix
# dropped: 1:1.3.dfsg-3.1ubuntu2 is 1 3).
proc pm::native::VersionNumbers {text} {
    regsub {^[0-9]+:} $text "" text
    regexp {^[0-9]+(\.[0-9]+)*} $text numbers
    if {![info exists numbers]} {
        return ""
    }
    return [split $numbers .]
}

# 1 if the system version VERSION (a list of numbers) satisfies the request
# REQUEST (pm/version.tcl's precision rule: each of its numbers equal).
proc pm::native::Satisfies {version request} {
    foreach want [split $request .] have $version {
        if {$want eq ""} break
        if {$have eq ""} { set have 0 }
        if {$want != $have} { return 0 }
    }
    return 1
}

# The evidence for the system LIBRARY of TARGET, which must be this host's:
# {path P evidence E version V facts F}, or {PM NATIVE}.
proc pm::native::System {target library} {
    set name [dict get $library name]
    set t [pm::target::facts $target]
    if {[dict get $t os] ne "linux"} {
        Fail "system library $name: verifying a system library on [dict get $t os] is not implemented (the plan reports it unverified)"
    }
    # Candidate files: the declared identity, then the linker's names.
    set names {}
    if {[dict get $library identity] ne ""} {
        lappend names [dict get $library identity]
    }
    lappend names [pm::target::linkFiles $target $name [dict get $library linkage]]
    set found {}
    foreach dir [LinuxDirs $target] {
        foreach file $names {
            set path [file join $dir $file]
            if {[file isfile $path] && $path ni $found} {
                lappend found $path
            }
        }
    }
    # Evidence: pkg-config's record (whose library directory holds one of
    # them), else the package database owning one.
    set module [dict get $library pkg-config]
    if {$module eq ""} {
        set module [string tolower $name]
    }
    set evidence ""
    set version ""
    set path ""
    foreach dir [PkgConfigDirs $target] {
        set pc [file join $dir $module.pc]
        if {![file isfile $pc]} continue
        set fields [PcFile $pc]
        set libdirs [regexp -all -inline -- {-L\S+} [dict getdef $fields Libs ""]]
        foreach candidate $found {
            foreach flag $libdirs {
                if {[file normalize [string range $flag 2 end]] eq [file normalize [file dirname $candidate]]} {
                    set path $candidate
                    set evidence "pkg-config $pc"
                    set version [dict getdef $fields Version ""]
                    break
                }
            }
            if {$path ne ""} break
        }
        if {$path ne ""} break
    }
    if {$path eq ""} {
        foreach candidate $found {
            set owner [DpkgOwner $candidate]
            if {$owner ne ""} {
                set path $candidate
                set evidence "dpkg package [dict get $owner package]"
                set version [dict get $owner version]
                break
            }
        }
    }
    if {$path eq ""} {
        if {$found eq ""} {
            Fail "system library $name ([join $names { or }]) is not installed in $target's system library directories ([join [LinuxDirs $target] {, }])"
        }
        Fail "system library $name: [join $found {, }] is installed, but no system metadata (the dpkg database, or a pkg-config file of the system's) records it: a file in a library directory is not a system-managed installation"
    }
    if {[dict get $library version] ne ""} {
        set numbers [VersionNumbers $version]
        if {$numbers eq "" || ![Satisfies $numbers [dict get $library version]]} {
            Fail "system library $name is version $version ($evidence), which the request \"[dict get $library version]\" does not accept"
        }
    }
    set bytes [pm::ReadBytes $path]
    set facts [pm::binary::inspect $bytes $path]
    if {[dict get $facts kind] eq "script"} {
        # A development link that is a linker script (libm.so): the
        # identity is checked through the declared file name only.
        return [dict create path $path evidence $evidence version $version facts "a linker script" identity [dict get $library identity]]
    }
    if {[dict get $library linkage] eq "shared"} {
        if {[dict get $facts kind] ne "elf" || [dict get $facts type] ne "dyn" || ![Matches $target $facts]} {
            Fail "system library $name: $path is [pm::binary::describe $facts], not a $target shared object"
        }
        if {[dict get $library identity] ne "" && [dict get $facts soname] ne [dict get $library identity]} {
            Fail "system library $name: $path's soname is [dict get $facts soname], and the package declares [dict get $library identity]"
        }
        foreach symbol [dict get $library symbols] {
            if {$symbol ni [dict get $facts symbols]} {
                Fail "system library $name: $path does not export the declared symbol $symbol"
            }
        }
        set identity [dict get $facts soname]
    } else {
        if {[dict get $facts kind] ne "archive"} {
            Fail "system library $name: $path is [pm::binary::describe $facts], not a static archive"
        }
        ArchiveFacts $target $facts $path
        set identity ""
    }
    return [dict create path $path evidence $evidence version $version facts [pm::binary::describe $facts] identity $identity]
}

# The highest GLIBC_ version this host's C library defines, or "".
proc pm::native::HostGlibc {target} {
    variable platformCache
    if {[dict exists $platformCache glibc]} {
        return [dict get $platformCache glibc]
    }
    set best ""
    foreach dir [LinuxDirs $target] {
        set path [file join $dir libc.so.6]
        if {![file isfile $path]} continue
        catch {
            set facts [pm::binary::inspect [pm::ReadBytes $path] $path]
            set best [Highest [dict get $facts verdef] GLIBC_]
        }
        break
    }
    dict set platformCache glibc $best
    return $best
}

# ---------------------------------------------------------------------------
# Source link declarations

# The link declarations of the Botlish module text TEXT: a list of {kind
# library|framework name N linkage default|static path P line L}. Botlish
# has no multi-line literal, and an extern declaration is one line, so a
# line whose statement starts `extern c library` (or `framework`) is one.
proc pm::native::SourceLinks {text} {
    set out {}
    set number 0
    foreach line [split $text \n] {
        incr number
        if {[regexp {^\s*(?:private\s+)?extern\s+c\s+library\s+"([^"\\]*)"(?:\s+(static)(?:\s+at\s+"([^"\\]*)")?)?\s*(?:#.*)?$} $line -> name static path]} {
            lappend out [dict create kind library name $name linkage [expr {$static eq "" ? "default" : "static"}] path $path line $number]
        } elseif {[regexp {^\s*(?:private\s+)?extern\s+c\s+framework\s+"([^"\\]*)"\s*(?:#.*)?$} $line -> name]} {
            lappend out [dict create kind framework name $name linkage default path "" line $number]
        }
    }
    return $out
}

# The path P normalized as the compiler compares archive paths ("." and
# empty components dropped).
proc pm::native::NormalPath {path} {
    return [join [lmap part [split $path /] {if {$part in {"" .}} continue; set part}] /]
}

# The loader identities a library NAME of TARGET conventionally has when it
# declares none (an ELF soname libNAME.so.N): used only to keep a failed
# declaration from being reported a second time as a missing one.
proc pm::native::ConventionalIdentities {target name} {
    if {[dict get [pm::target::facts $target] os] ne "linux"} {
        return {}
    }
    set out {}
    foreach suffix {0 1 2 3 4 5 6 7 8 9} {
        lappend out lib$name.so.$suffix
    }
    lappend out lib$name.so
    return $out
}

# ---------------------------------------------------------------------------
# The plan

# The native plan of TARGET for the view's INSTANCES (header) with the
# consumer's ORIGINS choices (LIBRARY -> system|bundled): a dict
#
#   target T  host H  verifiable 0|1
#   libraries {ENTRY...}   one per library the application links natively
#   frameworks {{name F instances {I...}}...}
#   headers {{instance I dir ABS}...}
#   placed {FILE {path ABS sha256 D}...}   the library directory's files
#   problems {TEXT...}   notes {TEXT...}
#
# ENTRY: {name N origin O linkage L instances {I...} file ABS import ABS
# identity ID needs {...} facts TEXT evidence TEXT version V verified 0|1
# glibc G signed S}. Problems make an operation fail; notes are reported.
proc pm::native::Plan {target instances origins} {
    set host [pm::target::host]
    set plan [dict create target $target host $host verifiable [expr {$host eq $target}] \
        libraries {} frameworks {} headers {} placed {} problems {} notes {} sources {}]
    set problems {}
    set notes {}
    # Every instance's declarations for TARGET, by library name.
    set offers [dict create]
    set frameworks [dict create]
    set headers {}
    foreach instance $instances {
        set descriptor [dict get $instance descriptor]
        set id [dict get $instance instance]
        if {![pm::targets::Aware $descriptor]} continue
        set spec [dict get $descriptor targets $target]
        set byName [dict create]
        foreach library [dict get $spec libraries] {
            dict lappend byName [dict get $library name] $library
        }
        dict for {name alternatives} $byName {
            set chosen [lindex $alternatives 0]
            if {[llength $alternatives] > 1} {
                set want [dict getdef $origins $name bundled]
                foreach alternative $alternatives {
                    if {[dict get $alternative origin] eq $want} {
                        set chosen $alternative
                    }
                }
            } elseif {[dict exists $origins $name] && [dict get $origins $name] ne [dict get $chosen origin]} {
                lappend notes "$name: botlish.json's origins choose $name's [dict get $origins $name] library, and package [dict get $instance name] (instance $id) offers only a [dict get $chosen origin] one"
            }
            dict lappend offers $name [list $id $instance $chosen]
        }
        foreach framework [dict get $spec frameworks] {
            dict lappend frameworks $framework $id
        }
        foreach dir [dict get $spec headers] {
            lappend headers [dict create instance $id dir [file join [dict get $instance dir] {*}[split $dir /]]]
        }
    }
    dict for {name choice} $origins {
        if {![dict exists $offers $name]} {
            lappend notes "origins: no package of this application declares a native library $name for $target"
        }
    }
    # One process, one library of each name.
    set libraries {}
    set identities [dict create]
    set failedProviders [dict create]
    dict for {name offerList} $offers {
        lassign [lindex $offerList 0] firstId firstInstance first
        set entry [dict create name $name origin [dict get $first origin] linkage [dict get $first linkage] \
            instances {} file "" import "" identity [dict get $first identity] needs [dict get $first needs] \
            facts "" evidence "" version "" verified 0 glibc "" signed "" symbols {} requests {} \
            declared [dict get $first symbols]]
        set digest ""
        set ok 1
        foreach offer $offerList {
            lassign $offer id instance library
            dict lappend entry instances $id
            foreach key {origin linkage} {
                if {[dict get $library $key] ne [dict get $entry $key]} {
                    lappend problems "$name: instance $firstId uses a [dict get $first origin] [dict get $first linkage] $name and instance $id a [dict get $library origin] [dict get $library linkage] one: one process links one $name (choose one origin with botlish.json's \"origins\", or use packages that agree)"
                    set ok 0
                    break
                }
            }
            if {!$ok} break
            if {[dict get $library origin] eq "bundled"} {
                set path [file join [dict get $instance dir] {*}[split [dict get $library file] /]]
                set bytes [pm::ReadBytes $path]
                set sha [pm::sha256::hex $bytes]
                if {$digest eq ""} {
                    set digest $sha
                    dict set entry file $path
                    dict set entry sha256 $sha
                    if {[dict get $library import] ne ""} {
                        dict set entry import [file join [dict get $instance dir] {*}[split [dict get $library import] /]]
                    }
                    dict set entry library $library
                } elseif {$sha ne $digest} {
                    lappend problems "$name: instances $firstId and $id bundle different $name libraries (sha256 [pm::Short $digest] and [pm::Short $sha]): one process loads one $name, and the package manager never chooses between them"
                    set ok 0
                    break
                }
            } else {
                if {[dict get $library version] ne ""} {
                    dict lappend entry requests [list $id [dict get $library version]]
                }
                if {[dict get $library identity] ne ""} {
                    if {[dict get $entry identity] ne "" && [dict get $entry identity] ne [dict get $library identity]} {
                        lappend problems "$name: instances $firstId and $id expect different loader identities of the system $name ([dict get $entry identity], [dict get $library identity])"
                        set ok 0
                    }
                    dict set entry identity [dict get $library identity]
                }
                dict set entry declared [lsort -unique [concat [dict get $entry declared] [dict get $library symbols]]]
                if {![dict exists $entry library]} {
                    dict set entry library $library
                }
            }
        }
        if {!$ok} continue
        # Verify.
        set library [dict get $entry library]
        if {[dict get $entry origin] eq "bundled"} {
            set importBytes ""
            if {[dict get $entry import] ne ""} {
                set importBytes [pm::ReadBytes [dict get $entry import]]
            }
            if {[catch {CheckBundled $target $library [pm::ReadBytes [dict get $entry file]] \
                    "$name's file [dict get $library file] (instance [lindex [dict get $entry instances] 0])" $importBytes} facts]} {
                lappend problems $facts
                continue
            }
            dict set entry facts [dict get $facts description]
            dict set entry identity [dict get $facts identity]
            dict set entry needs [dict get $facts needs]
            dict set entry glibc [dict get $facts glibc]
            dict set entry signed [dict get $facts signed]
            dict set entry symbols [dict get $facts symbols]
            dict set entry weak [dict getdef $facts weak {}]
            dict set entry rpath [dict get $facts rpath]
            dict set entry verified 1
            dict set entry evidence "bundled file, sha256 [pm::Short [dict get $entry sha256]]"
        } elseif {$host eq $target} {
            # Every instance's request must be met by the one library.
            set requested $library
            if {[catch {System $target $requested} evidence]} {
                lappend problems "$evidence (declared by [Or [lmap id [dict get $entry instances] {string cat "instance " $id}]])"
                # The declaration stands: a loader dependency it was declared
                # for is not undeclared, and is not reported again below
                # (the failure above is the one diagnostic).
                set claimed [dict get $entry identity]
                if {$claimed eq ""} {
                    set claimed [ConventionalIdentities $target $name]
                }
                foreach identity $claimed {
                    if {$identity ne ""} {
                        dict set failedProviders [string tolower $identity] $name
                    }
                }
                continue
            }
            foreach request [dict get $entry requests] {
                lassign $request id want
                set numbers [VersionNumbers [dict get $evidence version]]
                if {$numbers eq "" || ![Satisfies $numbers $want]} {
                    lappend problems "$name: instance $id requests system $name \"$want\", and the system's is [dict get $evidence version] ([dict get $evidence evidence])"
                }
            }
            if {[dict get $entry declared] ne "" && [dict get $entry linkage] eq "shared"} {
                set facts [pm::binary::inspect [pm::ReadBytes [dict get $evidence path]] [dict get $evidence path]]
                foreach symbol [dict get $entry declared] {
                    if {[dict exists $facts symbols] && $symbol ni [dict get $facts symbols]} {
                        lappend problems "$name: the system's [dict get $evidence path] does not export $symbol, which instance [lindex [dict get $entry instances] 0] declares"
                    }
                }
            }
            dict set entry file [dict get $evidence path]
            dict set entry facts [dict get $evidence facts]
            dict set entry evidence [dict get $evidence evidence]
            dict set entry version [dict get $evidence version]
            if {[dict get $evidence identity] ne ""} {
                dict set entry identity [dict get $evidence identity]
            }
            dict set entry verified 1
        } else {
            lappend notes "$name: a system library of $target, not verified (this host is [Or $host]): the target system must provide it[expr {[dict get $entry requests] ne "" ? " ([join [lsort -unique [lmap r [dict get $entry requests] {lindex $r 1}]] {, }])" : ""}]"
        }
        if {[dict get $entry linkage] eq "shared" && [dict get $entry identity] ne ""} {
            set key [dict get $entry identity]
            if {[pm::target::facts $target] ne "" && [dict get [pm::target::facts $target] format] eq "pe"} {
                set key [string tolower $key]
            }
            if {[dict exists $identities $key] && [dict get $identities $key] ne $name} {
                lappend problems "the libraries [dict get $identities $key] and $name both load as [dict get $entry identity]: one loader identity is one library in a process"
            }
            dict set identities $key $name
        }
        lappend libraries $entry
    }
    # Every loader dependency of every bundled shared library resolves: to
    # the target's platform, or a library of the plan.
    set provided [dict create]
    foreach entry $libraries {
        if {[dict get $entry linkage] eq "shared" && [dict get $entry identity] ne ""} {
            dict set provided [string tolower [dict get $entry identity]] [dict get $entry name]
            dict set provided [string tolower [file tail [dict get $entry identity]]] [dict get $entry name]
        }
    }
    foreach entry $libraries {
        if {[dict get $entry origin] ne "bundled" || [dict get $entry linkage] ne "shared"} continue
        foreach need [dict get $entry needs] {
            if {[pm::target::platformLibrary $target $need]} continue
            if {[dict exists $provided [string tolower $need]]} continue
            if {[string match @rpath/* $need] && [dict exists $provided [string tolower [file tail $need]]]} continue
            if {[dict exists $failedProviders [string tolower $need]] || [dict exists $failedProviders [string tolower [file tail $need]]]} continue
            lappend problems "[dict get $entry name] needs $need, which is neither part of $target's platform nor a library of this application's packages (declare it, bundled or system, in the package that needs it)"
        }
    }
    # glibc: a bundled library needing a newer C library than the host's.
    if {$host eq $target && [dict get [pm::target::facts $target] os] eq "linux"} {
        set hostGlibc [HostGlibc $target]
        foreach entry $libraries {
            if {[dict get $entry glibc] ne "" && $hostGlibc ne "" && [Compare [dict get $entry glibc] $hostGlibc] > 0} {
                lappend problems "[dict get $entry name] requires GLIBC_[join [dict get $entry glibc] .], and this system's C library provides up to GLIBC_[join $hostGlibc .]: it would not load here"
            }
        }
    }
    # Symbols two different static archives both define (a weak definition
    # is no duplicate: the link takes the other definition first).
    set definers [dict create]
    foreach entry $libraries {
        if {[dict get $entry origin] ne "bundled" || [dict get $entry linkage] ne "static"} continue
        foreach symbol [dict get $entry symbols] {
            if {$symbol in [dict getdef $entry weak {}]} continue
            if {[dict exists $definers $symbol] && [dict get $definers $symbol] ne [dict get $entry name]} {
                lappend problems "the static libraries [dict get $definers $symbol] and [dict get $entry name] both define $symbol: linking both into one executable is a duplicate definition"
            }
            dict set definers $symbol [dict get $entry name]
        }
    }
    # The library directory: each bundled library under the name a linker
    # finds it by, a shared one also under its loader identity.
    set placed [dict create]
    foreach entry $libraries {
        if {[dict get $entry origin] ne "bundled" || ![dict get $entry verified]} continue
        set name [dict get $entry name]
        set files {}
        set os [dict get [pm::target::facts $target] os]
        if {[dict get $entry linkage] eq "static"} {
            lappend files [pm::target::linkFiles $target $name static] [dict get $entry file]
        } elseif {$os eq "windows"} {
            lappend files [pm::target::linkFiles $target $name import] [dict get $entry import]
            lappend files [file tail [dict get $entry identity]] [dict get $entry file]
        } else {
            lappend files [pm::target::linkFiles $target $name shared] [dict get $entry file]
            set runtime [file tail [dict get $entry identity]]
            if {$runtime ne [pm::target::linkFiles $target $name shared]} {
                lappend files $runtime [dict get $entry file]
            }
        }
        foreach {file source} $files {
            if {[dict exists $placed [string tolower $file]]} {
                lappend problems "$name and [dict get $placed [string tolower $file] library] both need the library directory's file $file"
                continue
            }
            dict set placed [string tolower $file] [dict create file $file source $source library $name]
        }
        # Deployment requirements the plan reports.
        if {$os eq "macos"} {
            if {![string match @rpath/* [dict get $entry identity]]} {
                lappend notes "$name: its install name [dict get $entry identity] is not @rpath-relative: an executable linked with it loads it from that absolute path, wherever the application is deployed"
            }
            if {[dict get $entry signed] ne "1"} {
                lappend notes "$name: [file tail [dict get $entry file]] carries no code signature: macOS on arm64 loads only signed code, so sign it when the application is signed (codesign; the package manager signs nothing)"
            }
        }
    }
    dict for {name ids} $frameworks {
        dict lappend plan frameworks [dict create name $name instances $ids]
    }
    # Run-time dependencies (schema 3): reported, never part of the link or
    # the loader's closure, never a problem -- a program that does not use
    # a capability runs without it, and what a program opens at run time is
    # its own business to report when it is missing.
    set runtime {}
    foreach instance $instances {
        set descriptor [dict get $instance descriptor]
        if {![pm::targets::Aware $descriptor]} continue
        foreach dependency [dict getdef [dict get $descriptor targets $target] runtime {}] {
            set candidate ""
            if {$host eq $target && [dict get $dependency kind] eq "library"} {
                set probe [dict create name [dict get $dependency name] linkage shared identity [dict get $dependency identity] \
                    version "" pkg-config "" symbols {}]
                if {[catch {System $target $probe} evidence]} {
                    set candidate [dict create found 0 text $evidence]
                } else {
                    set candidate [dict create found 1 text "[dict get $evidence path] ([dict get $evidence evidence][expr {[dict get $evidence version] ne "" ? ", version [dict get $evidence version]" : ""}])"]
                }
            }
            lappend runtime [dict merge $dependency [dict create instance [dict get $instance instance] candidate $candidate]]
        }
    }
    dict set plan runtime $runtime
    dict set plan libraries $libraries
    dict set plan headers $headers
    dict set plan placed [dict values $placed]
    # The packages' source link declarations against their metadata.
    set selected [dict create]
    foreach entry $libraries {
        dict set selected [dict get $entry name] $entry
    }
    foreach instance $instances {
        set id [dict get $instance instance]
        foreach declaration [dict getdef $instance links {}] {
            set name [dict get $declaration name]
            set where "[dict get $declaration file]:[dict get $declaration line]"
            if {[dict get $declaration kind] eq "framework"} {
                if {![dict exists $frameworks $name]} {
                    lappend notes "$where links the framework $name, which no package's metadata declares for $target"
                }
                continue
            }
            if {![dict exists $selected $name]} {
                if {[pm::targets::Aware [dict get $instance descriptor]]} {
                    lappend notes "$where links $name by name, and no package's native metadata declares it for $target: the linker's search decides, unverified"
                }
                continue
            }
            set entry [dict get $selected $name]
            if {[dict get $declaration linkage] eq "static" && [dict get $entry linkage] ne "static"} {
                lappend problems "$where requires a static $name, and the package metadata provides a [dict get $entry origin] [dict get $entry linkage] one: correct the metadata or the declaration"
            }
            if {[dict get $declaration path] ne "" && [dict get $entry origin] eq "bundled" && $id in [dict get $entry instances]} {
                set file [dict get [dict get $entry library] file]
                if {[NormalPath [dict get $declaration path]] ne [NormalPath $file]} {
                    lappend problems "$where links $name from [dict get $declaration path], and the package metadata bundles it as $file: correct the metadata or the declaration"
                }
            }
        }
    }
    dict set plan problems $problems
    dict set plan notes $notes
    return $plan
}

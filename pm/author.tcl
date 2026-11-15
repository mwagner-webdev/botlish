# author.tcl -- the package author's side (PACKAGE-MANAGER-MILESTONE-3.md):
# turning already-built native files, generated bindings and headers into a
# package directory, and auditing it before it is packed.
#
#   pm::author::Open DIR                     the package directory being authored
#   pm::author::AddNative PKG FILE OPTIONS   import a built native library
#   pm::author::Require PKG NAME OPTIONS     declare a system or run-time dependency
#   pm::author::Stage PKG OPTIONS            copy modules, headers or files in
#   pm::author::Audit FILES DESCRIPTOR ?TARGETS?   the native audit of a
#                                            package's files (dict PATH -> BYTES)
#
# A package being authored is an ordinary package directory: its
# botlish.json and its files, the common ones at the root and each target's
# under the directory its `files` names (targets/TARGET by default). The
# operations here write only inside it: a native file into its target's
# directory, staged files at a deterministic path, botlish.json replaced
# atomically. Nothing here builds, compiles, links or runs anything: a file
# an author imports is read as bytes (pm/binary.tcl), and whatever produced
# it -- CMake, a cross compiler, a generator -- ran before, on the author's
# side, by the author's choice. Every fact the metadata states that a file
# can establish (format, architecture, loader identity, loader
# dependencies, exports) is taken from the file; what a file cannot
# establish -- which of its dependencies the system provides, what it opens
# at run time, its license -- the author states, and the operation says
# which is which.
#
# Existing metadata is never silently replaced: an operation whose result
# contradicts what botlish.json already declares, or whose file differs
# from the one already at its destination, is refused (CONFLICT) unless
# -replace says to replace it. Repeating an operation with the same input
# changes nothing.

namespace eval pm::author {
    # The file extensions `package stage -headers` takes as C headers.
    variable headerExtensions {.h .hh .hpp .hxx .inc .inl .def}
    # The link names of a target's platform libraries: `extern c library
    # "m"` names the platform's libm, which no package declares.
    variable platformLinkNames {
        linux {c m pthread dl rt resolv util anl mvec gcc_s}
        macos {System c m pthread dl objc}
        windows {kernel32 user32 gdi32 advapi32 shell32 ole32 oleaut32 imm32 version winmm setupapi
            cfgmgr32 ntdll ws2_32 shlwapi comdlg32 comctl32 dwmapi uxtheme hid dxgi d3d11 d3d12 dinput8
            xinput1_4 bcrypt crypt32 secur32 rpcrt4 userenv ucrt msvcrt dbghelp psapi iphlpapi winhttp}
    }
}

proc pm::author::Fail {kind message} {
    return -code error -errorcode [list PM $kind] $message
}

# ---------------------------------------------------------------------------
# The package directory

# The package directory DIR: {dir D path BOTLISH-JSON descriptor DESCRIPTOR}.
proc pm::author::Open {dir} {
    set dir [file normalize $dir]
    if {![file isdirectory $dir]} {
        Fail AUTHOR "$dir is not a directory"
    }
    set path [file join $dir botlish.json]
    if {![file isfile $path]} {
        Fail AUTHOR "$dir has no botlish.json: a package being authored has one (at least {\"schema\": 1, \"name\": NAME, \"version\": VERSION})"
    }
    set descriptor [pm::descriptor::read $path project]
    if {[dict get $descriptor name] eq ""} {
        Fail AUTHOR "$path names no package: a package being authored has a \"name\" (its root namespace)"
    }
    return [dict create dir $dir path $path descriptor $descriptor]
}

# The lowest schema DESCRIPTOR's contents need: 1 without targets, 3 with a
# runtime dependency or a library's license or notices, else 2.
proc pm::author::NeededSchema {descriptor} {
    if {[dict getdef $descriptor tools {}] ne ""} {
        return 4
    }
    set targets [dict getdef $descriptor targets {}]
    if {$targets eq "" && [dict getdef $descriptor origins {}] eq ""} {
        return 1
    }
    dict for {target entry} $targets {
        if {[dict getdef $entry runtime {}] ne ""} {
            return 3
        }
        foreach library [dict get $entry libraries] {
            if {[dict getdef $library license ""] ne "" || [dict getdef $library notices {}] ne ""} {
                return 3
            }
        }
    }
    return 2
}

# DESCRIPTOR in schema SCHEMA (never lower than it is): the keys that
# schema's in-memory form has.
proc pm::author::Upgrade {descriptor schema} {
    if {$schema <= [dict get $descriptor schema]} {
        return $descriptor
    }
    dict set descriptor schema $schema
    if {$schema >= 4 && ![dict exists $descriptor tools]} {
        dict set descriptor tools {}
    }
    if {$schema >= 2} {
        if {![dict exists $descriptor targets]} { dict set descriptor targets {} }
        if {![dict exists $descriptor origins]} { dict set descriptor origins {} }
    }
    if {$schema >= 3} {
        set targets [dict create]
        dict for {target entry} [dict get $descriptor targets] {
            if {![dict exists $entry runtime]} { dict set entry runtime {} }
            set libraries {}
            foreach library [dict get $entry libraries] {
                if {![dict exists $library license]} { dict set library license "" }
                if {![dict exists $library notices]} { dict set library notices {} }
                lappend libraries $library
            }
            dict set entry libraries $libraries
            dict set targets $target $entry
        }
        dict set descriptor targets $targets
    }
    return $descriptor
}

# Writes DESCRIPTOR as PKG's botlish.json: raised to the schema its contents
# need (never lowered: an author's schema is kept), validated as the reader
# reads it, replaced atomically. The schema it was written in.
proc pm::author::Save {pkg descriptor} {
    set needed [NeededSchema $descriptor]
    set descriptor [Upgrade $descriptor $needed]
    set bytes [pm::descriptor::encode $descriptor]
    pm::descriptor::fromBytes $bytes project "the new botlish.json"
    set path [dict get $pkg path]
    if {[pm::ReadBytes $path] ne $bytes} {
        pm::ReplaceFile $path $bytes
    }
    return [dict get $descriptor schema]
}

# The target entry of TARGET in DESCRIPTOR, made when it has none, with a
# target directory (targets/TARGET unless the entry names another).
proc pm::author::TargetEntry {descriptor target} {
    set entry [dict getdef [dict getdef $descriptor targets {}] $target {}]
    if {$entry eq ""} {
        set entry [dict create files "" libraries {} frameworks {} headers {}]
        if {[dict get $descriptor schema] >= 3} {
            dict set entry runtime {}
        }
    }
    if {[dict get $entry files] eq ""} {
        dict set entry files targets/$target
    }
    return $entry
}

proc pm::author::SetTarget {descriptor target entry} {
    if {[dict get $descriptor schema] < 2} {
        set descriptor [Upgrade $descriptor 2]
    }
    dict set descriptor targets $target $entry
    return $descriptor
}

# The absolute path of the package-relative path RELATIVE ("/"-separated).
proc pm::author::PathOf {pkg relative} {
    return [file join [dict get $pkg dir] {*}[split $relative /]]
}

# Writes BYTES at the package path RELATIVE: unchanged when it already holds
# them; a different file there is a CONFLICT unless REPLACE. "written",
# "unchanged".
proc pm::author::PlaceFile {pkg relative bytes replace what} {
    set path [PathOf $pkg $relative]
    if {[pm::Exists $path]} {
        if {[file type $path] ne "file"} {
            Fail CONFLICT "$relative is a [file type $path] in the package directory, where $what goes: remove it"
        }
        if {[pm::ReadBytes $path] eq $bytes} {
            return unchanged
        }
        if {!$replace} {
            Fail CONFLICT "$relative already holds a different file (sha256 [pm::Short [pm::sha256::hex [pm::ReadBytes $path]]], the new one [pm::Short [pm::sha256::hex $bytes]]): pass -replace to replace it"
        }
        pm::ReplaceFile $path $bytes
        return replaced
    }
    file mkdir [file dirname $path]
    set temporary $path.tmp-[pid]
    file delete $temporary
    pm::WriteNew $temporary $bytes
    pm::Rename $temporary $path
    return written
}

# The bytes of the file PATH an author names: a regular file, or a link
# (followed, and said so: the operation is explicit); never a directory or
# a device.
proc pm::author::ReadInput {path what notesVar} {
    upvar 1 $notesVar notes
    if {![pm::Exists $path]} {
        Fail AUTHOR "$path does not exist"
    }
    if {[file type $path] eq "link"} {
        set resolved [file normalize $path]
        lappend notes "$path is a symbolic link: the bytes of [file normalize [file join [file dirname $path] [file readlink $path]]] are $what"
        set path $resolved
    }
    if {![file isfile $path]} {
        Fail AUTHOR "$path is not a regular file"
    }
    return [pm::ReadBytes $path]
}

# ---------------------------------------------------------------------------
# native add

# The facts of the native file BYTES as a library of TARGET: {linkage
# static|shared identity I needs {...} symbols {...} facts F description D
# glibc G rpath {...} archive A}, or a refusal saying what the file is and
# what a library is.
proc pm::author::LibraryFacts {target bytes label} {
    set facts [pm::binary::inspect $bytes $label]
    set kind [dict get $facts kind]
    set t [pm::target::facts $target]
    set described [pm::binary::describe $facts]
    switch -- $kind {
        archive {
            set archive [pm::native::ArchiveFacts $target $facts $label]
            if {[dict get $archive imports] ne ""} {
                Fail NATIVE "$label is an import library of [join [dict get $archive imports] {, }]: it links a DLL, which must be part of the package too -- add the DLL, with this file as its -import"
            }
            if {[dict get $archive objects] == 0} {
                Fail NATIVE "$label holds no $target object"
            }
            return [dict create linkage static identity "" needs {} symbols [dict get $archive index] \
                description $described \
                glibc "" rpath {} facts $facts]
        }
        elf - macho - fat - pe {
            set selected [pm::native::Slice $target $facts]
            if {$selected eq ""} {
                Fail NATIVE "$label is $described, with no slice for $target"
            }
            if {![pm::native::Matches $target $selected]} {
                Fail NATIVE "$label is [pm::binary::describe $selected], and $target's libraries are [dict get $t format] [dict get $t arch]"
            }
            set shared 0
            switch -- [dict get $selected kind] {
                elf { set shared [expr {[dict get $selected type] eq "dyn"}] }
                macho { set shared [expr {[dict get $selected filetype] eq "dylib"}] }
                pe { set shared [dict get $selected dll] }
            }
            if {!$shared} {
                Fail NATIVE "$label is [pm::binary::describe $selected]: a native library is an ar archive of $target objects or a shared library (an object file goes into an archive first; an executable is no library)"
            }
            switch -- [dict get $selected kind] {
                elf {
                    set identity [dict get $selected soname]
                    if {$identity eq ""} {
                        Fail NATIVE "$label has no soname (DT_SONAME): an executable linked with it would record the path it was linked from, not a name its loader can find; link the library with -Wl,-soname,NAME"
                    }
                }
                macho { set identity [dict get $selected id] }
                pe {
                    set identity [dict get $selected name]
                    if {$identity eq ""} {
                        Fail NATIVE "$label exports no DLL name: its loader identity is its file name, which cannot be established from the file"
                    }
                }
            }
            set glibc ""
            set rpath {}
            if {[dict get $selected kind] eq "elf"} {
                set glibc [pm::native::Highest [dict getdef [dict get $selected verneed] libc.so.6 {}] GLIBC_]
                set rpath [concat [dict get $selected runpath] [dict get $selected rpath]]
            } elseif {[dict get $selected kind] eq "macho"} {
                set rpath [dict get $selected rpath]
            }
            return [dict create linkage shared identity $identity needs [dict get $selected needed] \
                symbols [dict get $selected symbols] description [pm::binary::describe $selected] \
                glibc $glibc rpath $rpath facts $selected]
        }
        thin {
            Fail NATIVE "$label is a thin archive: it holds the paths of objects, not the objects, so it cannot travel in a package (make an ordinary archive: ar rcs, not ar rcT)"
        }
        script {
            Fail NATIVE "$label is a GNU linker script: it names other files, which cannot be inspected through it (add the libraries it names)"
        }
        bitcode {
            Fail NATIVE "$label is LLVM bitcode: no target's linker links it as a library here (build $target objects)"
        }
        tbd {
            Fail NATIVE "$label is an Apple text-based stub: it describes a system library, which is declared, not bundled (native require NAME -origin system)"
        }
        coff {
            Fail NATIVE "$label is [pm::binary::describe $facts]: an object file goes into an archive first"
        }
    }
    Fail NATIVE "$label is not a native library file ($described)"
}

# The view path where a library of TARGET named NAME whose facts are FACTS
# goes, unless the author says where (-as): native/ and the name its linker
# searches for (a static archive), or its loader identity's file name (a
# shared library: the name the loader asks for).
proc pm::author::Destination {target name facts} {
    if {[dict get $facts linkage] eq "static"} {
        return native/[pm::target::linkFiles $target $name static]
    }
    return native/[file tail [dict get $facts identity]]
}

# The fields of a library entry that differ between OLD and NEW, as text.
# An author's statement (symbols, license, notices) made where none was is
# an addition, not a contradiction; any other difference is one.
proc pm::author::Differences {old new keys} {
    set out {}
    foreach key $keys {
        set a [dict getdef $old $key ""]
        set b [dict getdef $new $key ""]
        if {$key in {symbols license notices} && $a eq ""} continue
        if {$a ne $b} {
            lappend out "$key [expr {$a eq "" ? "(none)" : "\"[join $a {, }]\""}] -> [expr {$b eq "" ? "(none)" : "\"[join $b {, }]\""}]"
        }
    }
    return $out
}

# Imports the native library FILE into the package PKG for OPTIONS' target:
# {target T name N linkage L as PATH import FILE symbols {S...}|"-" license
# L|"-" notices {P...}|"-" replace 0|1} ("-": not given). Report lines.
proc pm::author::AddNative {pkg file options} {
    set target [dict get $options target]
    set name [dict get $options name]
    if {[set problem [pm::targets::LibraryNameProblem $name]] ne ""} {
        Fail AUTHOR "-name: $problem"
    }
    set notes {}
    set bytes [ReadInput $file "the library imported" notes]
    set facts [LibraryFacts $target $bytes $file]
    set linkage [dict get $facts linkage]
    if {[dict get $options linkage] ne "" && [dict get $options linkage] ne $linkage} {
        Fail NATIVE "$file is [dict get $facts description]: a [expr {$linkage eq "static" ? "static" : "shared"}] library, and -linkage says [dict get $options linkage]"
    }
    set descriptor [dict get $pkg descriptor]
    set entry [TargetEntry $descriptor $target]
    set base [dict get $entry files]
    set relative [dict get $options as]
    if {$relative eq ""} {
        set relative [Destination $target $name $facts]
    } elseif {[set problem [pm::archive::pathProblem $relative]] ne ""} {
        Fail AUTHOR "-as: $problem"
    }
    set t [pm::target::facts $target]
    set importRelative ""
    set importBytes ""
    if {[dict get $options import] ne ""} {
        if {!($linkage eq "shared" && [dict get $t os] eq "windows")} {
            Fail AUTHOR "-import names a Windows DLL's import library, and $file is a $target [dict get $facts description]"
        }
        set importBytes [ReadInput [dict get $options import] "the import library" notes]
        set importRelative native/[pm::target::linkFiles $target $name import]
    } elseif {$linkage eq "shared" && [dict get $t os] eq "windows"} {
        Fail AUTHOR "a Windows DLL is linked through its import library: give it with -import FILE"
    }
    # The entry: what the file establishes, and what the author states.
    set library [dict create name $name origin bundled linkage $linkage file $relative import $importRelative \
        identity [dict get $facts identity] needs [dict get $facts needs] version "" pkg-config "" symbols {}]
    set old ""
    set index -1
    set i 0
    foreach existing [dict get $entry libraries] {
        if {[dict get $existing name] eq $name && [dict get $existing origin] eq "bundled"} {
            set old $existing
            set index $i
        }
        incr i
    }
    foreach key {symbols license notices} {
        if {[dict get $options $key] ne "-"} {
            dict set library $key [dict get $options $key]
        } elseif {$old ne "" && [dict exists $old $key]} {
            dict set library $key [dict get $old $key]
        }
    }
    if {[dict exists $library license] || [dict exists $library notices]} {
        foreach key {license notices} {
            if {![dict exists $library $key]} { dict set library $key "" }
        }
    }
    if {$linkage eq "static"} {
        dict set library identity ""
        dict set library needs {}
    }
    # The file must be what the entry says (the pack's own check, now).
    set checked [pm::native::CheckBundled $target $library $bytes $file $importBytes]
    # Another library's file at the destination?
    foreach existing [dict get $entry libraries] {
        if {[dict get $existing name] ne $name && [dict get $existing file] eq $relative} {
            Fail CONFLICT "$target's library [dict get $existing name] is already the file $relative: give this one another destination (-as)"
        }
    }
    set keys {linkage file import identity needs symbols license notices}
    if {$old ne ""} {
        set differences [Differences $old $library $keys]
        if {$differences ne "" && ![dict get $options replace]} {
            Fail CONFLICT "botlish.json already declares $target's bundled library $name differently: [join $differences {; }] (the file establishes identity and needs; pass -replace to replace the declaration)"
        }
    }
    set fileState [PlaceFile $pkg $base/$relative $bytes [dict get $options replace] "$name's file"]
    set importState ""
    if {$importRelative ne ""} {
        set importState [PlaceFile $pkg $base/$importRelative $importBytes [dict get $options replace] "$name's import library"]
    }
    set libraries [dict get $entry libraries]
    if {$index >= 0} {
        set libraries [lreplace $libraries $index $index $library]
    } else {
        lappend libraries $library
    }
    dict set entry libraries $libraries
    set descriptor [SetTarget $descriptor $target $entry]
    set changed [expr {$old eq "" || [dict filter $old key {*}$keys] ne [dict filter $library key {*}$keys] || $fileState ne "unchanged" || ($importState ni {"" unchanged})}]
    set schema [Save $pkg $descriptor]
    # The report: what was established, and what was not.
    set lines {}
    lappend lines "native add: $target library $name (bundled $linkage) -> $base/$relative[expr {$changed ? "" : " (unchanged)"}]"
    lappend lines "  established from the file: [dict get $facts description] (sha256 [pm::Short [pm::sha256::hex $bytes]], [string length $bytes] bytes)"
    if {$linkage eq "shared"} {
        lappend lines "    loader identity [dict get $facts identity]; needs [pm::native::Or [dict get $facts needs]]"
        if {[dict get $facts glibc] ne ""} {
            lappend lines "    requires GLIBC_[join [dict get $facts glibc] .] or newer"
        }
        foreach entryPath [dict get $facts rpath] {
            lappend lines "    note: it carries a run-time search path entry \"$entryPath\" (native audit judges it)"
        }
    }
    lappend lines "    [llength [dict get $facts symbols]] exported symbol[expr {[llength [dict get $facts symbols]] == 1 ? "" : "s"}][expr {[dict get $library symbols] ne "" ? "; required by the package: [join [dict get $library symbols] {, }] (present)" : ""}]"
    if {$importRelative ne ""} {
        lappend lines "    import library $base/$importRelative imports it"
    }
    set descriptor [dict get [Open [dict get $pkg dir]] descriptor]
    set declared [DeclaredIdentities [dict get $descriptor targets $target]]
    set unresolved {}
    foreach need [dict get $facts needs] {
        if {[pm::target::platformLibrary $target $need]} continue
        if {[string tolower $need] in $declared || [string tolower [file tail $need]] in $declared} continue
        lappend unresolved $need
    }
    foreach need $unresolved {
        lappend lines "  unresolved: it needs $need, which no library of $target declares and $target's platform does not provide: native require NAME -target $target -origin system -identity $need (the system's), or native add its file (bundled)"
    }
    set missing {}
    if {[dict getdef $library license ""] eq ""} {
        lappend missing "its license and redistribution terms (-license, -notice)"
    }
    lappend missing "which libraries it opens at run time (native require NAME -target $target -runtime ...)"
    lappend lines "  not established from the file: [join $missing {; }]"
    lappend lines "  botlish.json: targets.$target.libraries: $name [expr {$old eq "" ? "added" : ($changed ? "updated" : "unchanged")}] (schema $schema)"
    foreach note $notes {
        lappend lines "  note: $note"
    }
    return $lines
}

# The loader identities a target ENTRY declares (lowercased, also their file
# names): its libraries' identities.
proc pm::author::DeclaredIdentities {entry} {
    set out {}
    foreach library [dict get $entry libraries] {
        if {[dict get $library identity] ne ""} {
            lappend out [string tolower [dict get $library identity]] [string tolower [file tail [dict get $library identity]]]
        }
    }
    return $out
}

# ---------------------------------------------------------------------------
# native require

# Declares, for OPTIONS' target, the native dependency NAME of the package
# PKG: a system library (origin system: {linkage identity version pkg-config
# symbols}) or a run-time dependency (runtime REQUIREMENT: {kind identity
# loaded-by capability purpose}). Report lines.
proc pm::author::Require {pkg name options} {
    set target [dict get $options target]
    set descriptor [dict get $pkg descriptor]
    set entry [TargetEntry $descriptor $target]
    set lines {}
    if {[dict get $options runtime] ne ""} {
        set descriptor [Upgrade $descriptor 3]
        set entry [TargetEntry $descriptor $target]
        if {![dict exists $entry runtime]} { dict set entry runtime {} }
        set kind [dict get $options kind]
        if {$kind eq ""} {
            set kind [expr {[dict get $options identity] ne "" ? "library" : "facility"}]
        }
        set dependency [dict create name $name kind $kind identity [dict get $options identity] \
            loaded-by [dict get $options loaded-by] requirement [dict get $options runtime] \
            capability [dict get $options capability] purpose [dict get $options purpose]]
        set problems {}
        set parsed [pm::targets::Runtime $target [pm::targets::RuntimeValue $dependency] "runtime" problems]
        if {$problems ne ""} {
            Fail AUTHOR "native require $name:\n  [join $problems "\n  "]"
        }
        set old ""
        set index -1
        set i 0
        foreach existing [dict get $entry runtime] {
            if {[dict get $existing name] eq $name} {
                set old $existing
                set index $i
            }
            incr i
        }
        set keys {kind identity loaded-by requirement capability purpose}
        if {$old ne "" && [Differences $old $dependency $keys] ne "" && ![dict get $options replace]} {
            Fail CONFLICT "botlish.json already declares $target's run-time dependency $name differently: [join [Differences $old $dependency $keys] {; }] (pass -replace to replace it)"
        }
        set runtime [dict get $entry runtime]
        if {$index >= 0} {
            set runtime [lreplace $runtime $index $index $dependency]
        } else {
            lappend runtime $dependency
        }
        dict set entry runtime $runtime
        set descriptor [SetTarget $descriptor $target $entry]
        # The schema's relations (a loaded-by naming a library, an identity
        # the link already has) are checked by reading the result back.
        set schema [Save $pkg $descriptor]
        set when [dict get {always "always (whenever the package's native code runs)" capability "only for the capability" optional "optional (used when present)"} [dict get $dependency requirement]]
        if {[dict get $dependency requirement] eq "capability"} {
            append when " \"[dict get $dependency capability]\""
        }
        lappend lines "native require: $target run-time [dict get $dependency kind] $name, $when[expr {$old ne "" && [Differences $old $dependency $keys] eq "" ? " (unchanged)" : ""}]"
        lappend lines "  purpose: [dict get $dependency purpose]"
        lappend lines "  never part of the link or the loader's closure: installing the package never requires it[expr {[dict get $dependency requirement] eq "always" ? ", and its programs fail to start their native code without it" : ""}]"
        foreach line [RuntimeEvidence $pkg $target $dependency] {
            lappend lines "  $line"
        }
        lappend lines "  botlish.json: targets.$target.runtime: $name [expr {$old eq "" ? "added" : "replaced"}] (schema $schema)"
        return $lines
    }
    # A system library.
    set library [dict create name $name origin system linkage [dict get $options linkage] file "" import "" \
        identity [dict get $options identity] needs {} version [dict get $options version] \
        pkg-config [dict get $options pkg-config] symbols [expr {[dict get $options symbols] eq "-" ? {} : [dict get $options symbols]}]]
    if {[dict get $library linkage] eq ""} {
        dict set library linkage shared
    }
    if {[dict get $descriptor schema] >= 3} {
        dict set library license ""
        dict set library notices {}
    }
    set problems {}
    pm::targets::Library $target [pm::targets::LibraryValue $library] "native require" problems [dict get $descriptor schema]
    if {$problems ne ""} {
        Fail AUTHOR "native require $name:\n  [join $problems "\n  "]"
    }
    set old ""
    set index -1
    set i 0
    foreach existing [dict get $entry libraries] {
        if {[dict get $existing name] eq $name && [dict get $existing origin] eq "system"} {
            set old $existing
            set index $i
        }
        incr i
    }
    set keys {linkage identity version pkg-config symbols}
    if {$old ne "" && [dict get $options symbols] eq "-"} {
        dict set library symbols [dict get $old symbols]
    }
    if {$old ne "" && [Differences $old $library $keys] ne "" && ![dict get $options replace]} {
        Fail CONFLICT "botlish.json already declares $target's system library $name differently: [join [Differences $old $library $keys] {; }] (pass -replace to replace it)"
    }
    set libraries [dict get $entry libraries]
    if {$index >= 0} {
        set libraries [lreplace $libraries $index $index $library]
    } else {
        lappend libraries $library
    }
    dict set entry libraries $libraries
    set descriptor [SetTarget $descriptor $target $entry]
    set schema [Save $pkg $descriptor]
    lappend lines "native require: $target system library $name ([dict get $library linkage][expr {[dict get $library identity] ne "" ? ", loads as [dict get $library identity]" : ""}][expr {[dict get $library version] ne "" ? ", version \"[dict get $library version]\"" : ""}])[expr {$old ne "" && [Differences $old $library $keys] eq "" ? " (unchanged)" : ""}]"
    lappend lines "  stated by the author: the target's own installation provides it; a consumer's system is verified when the package is installed there (the distribution's metadata, then the file)"
    if {$target eq [pm::target::host]} {
        if {[catch {pm::native::System $target $library} evidence]} {
            lappend lines "  this host: not verified: $evidence"
            lappend lines "    (a fact of this machine, not of the package: the requirement is what botlish.json states)"
        } else {
            lappend lines "  this host: [dict get $evidence path], [dict get $evidence evidence][expr {[dict get $evidence version] ne "" ? ", version [dict get $evidence version]" : ""}]"
            lappend lines "    (an observation of this machine, never recorded as a requirement: the version requirement is only what -version states)"
        }
    } else {
        lappend lines "  this host is [pm::native::Or [pm::target::host]]: $target's system library cannot be verified here"
    }
    if {[dict get $library identity] eq ""} {
        set wanting {}
        foreach other [dict get $entry libraries] {
            foreach need [dict get $other needs] {
                if {[string match -nocase "lib$name.*" [file tail $need]]} {
                    lappend wanting "[dict get $other name] needs $need"
                }
            }
        }
        if {$wanting ne ""} {
            lappend lines "  note: no -identity: [join $wanting {; }] -- a need resolves only to a declared identity (-identity)"
        }
    }
    lappend lines "  botlish.json: targets.$target.libraries: $name (system) [expr {$old eq "" ? "added" : "replaced"}] (schema $schema)"
    return $lines
}

# What can be established, without running anything, about the run-time
# dependency DEPENDENCY of TARGET in the package PKG (a directory) or the
# FILES of a package (dict PATH -> BYTES), as report lines.
proc pm::author::RuntimeEvidence {pkg target dependency {files ""} {descriptor ""}} {
    set lines {}
    if {$files eq ""} {
        set descriptor [dict get [Open [dict get $pkg dir]] descriptor]
        set files [pm::commands::Collect [dict get $pkg dir]]
    }
    set view [pm::targets::Map $descriptor $target [dict keys $files]]
    set identity [dict get $dependency identity]
    if {$identity ne ""} {
        set searched {}
        foreach library [dict get $descriptor targets $target libraries] {
            if {[dict get $library origin] ne "bundled"} continue
            if {[dict get $dependency loaded-by] ne "" && [dict get $library name] ne [dict get $dependency loaded-by]} continue
            if {![dict exists $view [dict get $library file]]} continue
            set bytes [dict get $files [dict get $view [dict get $library file]]]
            lappend searched [dict get $library name]
            if {[string first $identity\x00 $bytes] >= 0 || [string first [file rootname $identity]\x00 $bytes] >= 0} {
                lappend lines "statically consistent: the string $identity occurs in [dict get $library name]'s file, as a library opened by that name has it (read, never run: not a proof that it is opened)"
                set found 1
                break
            }
        }
        if {![info exists found] && $searched ne ""} {
            lappend lines "not found statically: no string $identity in [join $searched {, }] (it may build the name at run time): the author's statement stands unconfirmed"
        }
        if {$target eq [pm::target::host] && [dict get $dependency kind] eq "library"} {
            set probe [dict create name [dict get $dependency name] linkage shared identity $identity version "" pkg-config "" symbols {}]
            if {[catch {pm::native::System $target $probe} evidence]} {
                lappend lines "this host: no verified candidate ($evidence)"
            } else {
                lappend lines "this host: a candidate, [dict get $evidence path] ([dict get $evidence evidence][expr {[dict get $evidence version] ne "" ? ", version [dict get $evidence version]" : ""}]): an observation of this machine, not a promise about a consumer's"
            }
        }
    } else {
        lappend lines "a facility, no file: nothing about it can be established from the package or this machine's files"
    }
    return $lines
}

# ---------------------------------------------------------------------------
# package stage

# The files of the directory DIR, recursively, as {RELATIVE BYTES ...}
# ("/"-separated); a link, a device or a name an archive cannot hold is
# refused; hidden entries are skipped (and counted in SKIPPEDVAR).
proc pm::author::ReadTree {dir skippedVar} {
    upvar 1 $skippedVar skipped
    set files [dict create]
    set problems {}
    ReadTreeInto $dir "" files problems skipped
    if {$problems ne ""} {
        Fail AUTHOR "$dir cannot be staged:\n  [join $problems "\n  "]"
    }
    return $files
}

proc pm::author::ReadTreeInto {dir relative filesVar problemsVar skippedVar} {
    upvar 1 $filesVar files $problemsVar problems $skippedVar skipped
    set here [file join $dir {*}[split $relative /]]
    foreach name [pm::state::Entries $here] {
        set path [expr {$relative eq "" ? $name : "$relative/$name"}]
        if {[string index $name 0] eq "."} {
            lappend skipped $path
            continue
        }
        set full [file join $here $name]
        set type [file type $full]
        if {[set problem [pm::archive::pathProblem $path]] ne ""} {
            lappend problems "$path: $problem"
            continue
        }
        switch -- $type {
            directory { ReadTreeInto $dir $path files problems skipped }
            file { dict set files $path [pm::ReadBytes $full] }
            link { lappend problems "$path is a symbolic link: staging copies regular files only, and never follows a link into the package" }
            default { lappend problems "$path is a $type: staging copies regular files only" }
        }
    }
}

# The package files under the package path PREFIX (a directory), as
# {RELATIVE BYTES ...}, or "" when there is none.
proc pm::author::Existing {pkg prefix} {
    set path [PathOf $pkg $prefix]
    if {![pm::Exists $path]} {
        return [dict create]
    }
    if {[file type $path] ne "directory"} {
        Fail CONFLICT "$prefix is a [file type $path] in the package directory, where a staged directory goes"
    }
    set skipped {}
    return [ReadTree $path skipped]
}

# Stages OPTIONS {targets {T...} kind modules|headers|files source SRC as
# DIR replace 0|1} into the package PKG. Report lines.
proc pm::author::Stage {pkg options} {
    variable headerExtensions
    set kind [dict get $options kind]
    set source [file normalize [dict get $options source]]
    set descriptor [dict get $pkg descriptor]
    set name [dict get $descriptor name]
    set skipped {}
    if {![pm::Exists $source]} {
        Fail AUTHOR "$source does not exist"
    }
    if {[file type $source] eq "link"} {
        Fail AUTHOR "$source is a symbolic link: name the directory or file itself"
    }
    if {[file isdirectory $source]} {
        set input [ReadTree $source skipped]
        set single 0
    } elseif {[file isfile $source]} {
        set input [dict create [file tail $source] [pm::ReadBytes $source]]
        set single 1
    } else {
        Fail AUTHOR "$source is neither a directory nor a regular file"
    }
    if {[dict size $input] == 0} {
        Fail AUTHOR "$source holds no file to stage"
    }
    set as [dict get $options as]
    switch -- $kind {
        modules {
            # A package's modules are its namespace: NAME.bot and NAME/...
            if {$as eq ""} {
                if {$single} {
                    set as ""
                } else {
                    set as [file tail $source]
                }
            }
            foreach path [dict keys $input] {
                if {![string match *.bot $path]} {
                    Fail AUTHOR "$source: $path is no Botlish module (*.bot): stage other files with -files"
                }
                set full [expr {$as eq "" ? $path : "$as/$path"}]
                if {$full ne "$name.bot" && [string first $name/ $full] != 0} {
                    Fail AUTHOR "$source: the module $full is outside the package's namespace $name (its modules are $name.bot and $name/...): -as names where the modules go"
                }
            }
        }
        headers {
            if {$as eq ""} { set as include }
            foreach path [dict keys $input] {
                if {[string tolower [file extension $path]] ni $headerExtensions} {
                    Fail AUTHOR "$source: $path is no C header ([join $headerExtensions { }]): -headers stages a package's public headers only"
                }
            }
            if {[dict get $options targets] eq ""} {
                Fail AUTHOR "header directories are declared per target: give -target (any number)"
            }
        }
        files {
            if {$as eq ""} {
                Fail AUTHOR "-files needs -as DIR: the directory the files go to"
            }
        }
    }
    if {$as ne "" && [set problem [pm::archive::pathProblem $as]] ne ""} {
        Fail AUTHOR "-as: $problem"
    }
    if {$as eq "botlish.json" || [string match botlish.json/* $as]} {
        Fail AUTHOR "-as names botlish.json"
    }
    set targets [dict get $options targets]
    set destinations {}
    if {$targets eq ""} {
        # Common files: never inside a target's directory.
        foreach {target dir} [pm::targets::Dirs $descriptor] {
            if {$as eq "" || [pm::targets::Under $as $dir] || [pm::targets::Under $dir $as]} {
                Fail AUTHOR "common files cannot go to [expr {$as eq "" ? "the package root" : $as}]: it is, or holds, $target's directory $dir"
            }
        }
        if {$as eq ""} {
            Fail AUTHOR "common modules staged from a single file go to the package root, where its own files are: give -as"
        }
        lappend destinations "" $as
    } else {
        foreach target $targets {
            set entry [TargetEntry $descriptor $target]
            set descriptor [SetTarget $descriptor $target $entry]
            set prefix [dict get $entry files]
            lappend destinations $target [expr {$as eq "" ? $prefix : "$prefix/$as"}]
        }
    }
    # Every destination first: a conflict anywhere changes nothing.
    set plans {}
    foreach {target prefix} $destinations {
        set existing [Existing $pkg $prefix]
        if {$single} {
            # A single file is staged as that file: only it is compared and
            # replaced, so several files can be staged into one directory.
            set existing [dict filter $existing script {path -} {dict exists $input $path}]
        }
        set state unchanged
        if {[lsort -stride 2 -index 0 $existing] ne [lsort -stride 2 -index 0 $input]} {
            if {[dict size $existing] > 0 && ![dict get $options replace]} {
                set differ {}
                dict for {path bytes} $input {
                    if {![dict exists $existing $path]} {
                        lappend differ "$path is new"
                    } elseif {[dict get $existing $path] ne $bytes} {
                        lappend differ "$path differs"
                    }
                }
                dict for {path -} $existing {
                    if {![dict exists $input $path]} { lappend differ "$path would be removed" }
                }
                Fail CONFLICT "$prefix already holds different files ([join [lrange $differ 0 4] {; }][expr {[llength $differ] > 5 ? "; ..." : ""}]): pass -replace to make it exactly $source"
            }
            set state [expr {[dict size $existing] > 0 ? "replaced" : "staged"}]
        }
        lappend plans [list $target $prefix $state]
    }
    # The layout the package would have: the target rules still hold.
    if {$kind eq "headers"} {
        foreach target $targets {
            set entry [dict get $descriptor targets $target]
            if {$as ni [dict get $entry headers]} {
                dict lappend entry headers $as
                set descriptor [SetTarget $descriptor $target $entry]
            }
        }
    }
    set before [pm::targets::Problems [dict get $pkg descriptor] [dict keys [pm::commands::Collect [dict get $pkg dir]]]]
    set after [pm::commands::Collect [dict get $pkg dir]]
    foreach plan $plans {
        lassign $plan target prefix state
        if {$state eq "replaced"} {
            dict for {path -} [Existing $pkg $prefix] {
                if {!$single || [dict exists $input $path]} {
                    dict unset after $prefix/$path
                }
            }
        }
        dict for {path bytes} $input {
            dict set after $prefix/$path $bytes
        }
    }
    set problems {}
    foreach problem [pm::targets::Problems $descriptor [dict keys $after]] {
        if {$problem ni $before} { lappend problems $problem }
    }
    if {[set collision [pm::archive::CollisionProblem [lsort [dict keys $after]]]] ne ""} {
        lappend problems $collision
    }
    if {$problems ne ""} {
        Fail CONFLICT "staging $source would break the package's layout:\n  [join $problems "\n  "]"
    }
    set lines {}
    foreach plan $plans {
        lassign $plan target prefix state
        if {$state eq "replaced" && !$single} {
            pm::RemoveTree [PathOf $pkg $prefix]
        }
        if {$state ne "unchanged"} {
            dict for {path bytes} $input {
                set full [PathOf $pkg $prefix/$path]
                file mkdir [file dirname $full]
                if {[pm::Exists $full]} { file delete $full }
                pm::WriteNew $full $bytes
            }
        }
        lappend lines "package stage: [dict size $input] [expr {$kind eq "files" ? "file" : [string range $kind 0 end-1]}][expr {[dict size $input] == 1 ? "" : "s"}] of $source -> $prefix[expr {$target ne "" ? " ($target)" : " (common)"}]: $state"
    }
    set schema [Save $pkg $descriptor]
    if {$kind eq "headers"} {
        lappend lines "  botlish.json: the headers of [join $targets {, }] hold $as (schema $schema)"
    } elseif {$targets ne ""} {
        lappend lines "  botlish.json: the target directories of [join $targets {, }] (schema $schema)"
    }
    if {$skipped ne ""} {
        lappend lines "  skipped [llength $skipped] hidden entr[expr {[llength $skipped] == 1 ? "y" : "ies"}] ([join [lrange $skipped 0 2] {, }]): a package holds no hidden file"
    }
    return $lines
}

# ---------------------------------------------------------------------------
# The audit

# 1 when BYTES start like a native binary (ELF, ar, Mach-O, PE, LLVM
# bitcode): a file the audit requires the metadata to declare.
proc pm::author::LooksNative {bytes} {
    set head [string range $bytes 0 7]
    if {[string range $head 0 3] in [list "\x7fELF" "\xcf\xfa\xed\xfe" "\xce\xfa\xed\xfe" "\xca\xfe\xba\xbe" "BC\xc0\xde" "\xde\xc0\x17\x0b"]} {
        return 1
    }
    if {$head in [list "!<arch>\n" "!<thin>\n"]} {
        return 1
    }
    if {[string range $head 0 1] eq "MZ" && [string length $bytes] > 64} {
        return 1
    }
    return 0
}

# The C functions the Botlish modules of a view declare (extern c fn NAME
# [named "SYMBOL"]): {SYMBOL {FILE LINE} ...}.
proc pm::author::ExternFunctions {view files} {
    set out [dict create]
    foreach {viewPath path} $view {
        if {![string match *.bot $viewPath]} continue
        set number 0
        foreach line [split [encoding convertfrom utf-8 [dict get $files $path]] \n] {
            incr number
            if {[regexp {^\s*(?:private\s+)?extern\s+c\s+fn\s+([A-Za-z_][A-Za-z0-9_]*)(?:\s+named\s+"([^"\\]+)")?} $line -> fn symbol]} {
                if {$symbol eq ""} { set symbol $fn }
                if {![dict exists $out $symbol]} {
                    dict set out $symbol [list $viewPath $number]
                }
            }
        }
    }
    return $out
}

# The link declarations of the Botlish modules of a view.
proc pm::author::ViewLinks {view files} {
    set links {}
    foreach {viewPath path} $view {
        if {![string match *.bot $viewPath]} continue
        foreach declaration [pm::native::SourceLinks [encoding convertfrom utf-8 [dict get $files $path]]] {
            dict set declaration file $viewPath
            lappend links $declaration
        }
    }
    return $links
}

# The exported symbols of TARGET's platform libraries on this host (the
# host's own target only), cached.
proc pm::author::PlatformSymbols {target} {
    variable platformSymbols
    if {[info exists platformSymbols($target)]} {
        return $platformSymbols($target)
    }
    set symbols {}
    if {$target eq [pm::target::host] && [dict get [pm::target::facts $target] os] eq "linux"} {
        foreach identity {libc.so.6 libm.so.6 libpthread.so.0 libdl.so.2 librt.so.1 libgcc_s.so.1 libmvec.so.1 libresolv.so.2} {
            foreach dir [pm::native::LinuxDirs $target] {
                set path [file join $dir $identity]
                if {![file isfile $path]} continue
                catch {
                    lappend symbols {*}[dict get [pm::binary::inspect [pm::ReadBytes $path] $path] symbols]
                }
                break
            }
        }
    }
    set platformSymbols($target) [lsort -unique $symbols]
    return $platformSymbols($target)
}

# The native audit of a package: its FILES (dict PATH -> BYTES, as packed)
# and DESCRIPTOR, for TARGETS (default: every target it names). A dict:
#
#   problems {TEXT...}           layout problems (every target)
#   targets {TARGET REPORT ...}
#
# REPORT: {status complete|partial|incomplete  problems {...}  partial {...}
# notes {...}  libraries {LIBRARY-REPORT...}  runtime {RUNTIME-REPORT...}
# functions {declared N bundled N system N platform N unresolved {...}}}.
#
#   complete     every mandatory native dependency is accounted for and
#                every check that can run here passed;
#   partial      complete in its metadata, with facts this host cannot
#                verify (another target's system libraries, a system
#                library this machine does not have, C functions expected
#                from an unverifiable library);
#   incomplete   a mandatory dependency unresolved, or a declared fact
#                contradicted: never packed.
proc pm::author::Audit {files descriptor {targets ""}} {
    variable platformLinkNames
    set result [dict create problems {} targets {}]
    if {![pm::targets::Aware $descriptor]} {
        return $result
    }
    set paths [dict keys $files]
    dict set result problems [pm::targets::Problems $descriptor $paths]
    if {$targets eq ""} {
        set targets [lsort [dict keys [dict get $descriptor targets]]]
    }
    # One public API: every target's view defines the same modules.
    set modules [dict create]
    foreach target [lsort [dict keys [dict get $descriptor targets]]] {
        set view [pm::targets::Map $descriptor $target $paths]
        dict set modules $target [lsort [lsearch -all -inline -glob [dict keys $view] *.bot]]
    }
    set host [pm::target::host]
    foreach target $targets {
        set problems {}
        set partial {}
        set notes {}
        set reports {}
        set entry [dict get $descriptor targets $target]
        set t [pm::target::facts $target]
        set view [pm::targets::Map $descriptor $target $paths]
        # Modules every target has.
        dict for {other list} $modules {
            if {$other eq $target} continue
            set missing {}
            foreach module $list {
                if {$module ni [dict get $modules $target]} { lappend missing $module }
            }
            if {$missing ne ""} {
                lappend problems "its view lacks [llength $missing] module[expr {[llength $missing] == 1 ? "" : "s"}] $other's has ([join [lrange $missing 0 2] {, }][expr {[llength $missing] > 3 ? ", ..." : ""}]): a release offers one set of modules on every target it names (stage the target's binding, or drop the target)"
            }
        }
        # Every native file of the view is declared (a library's, or a
        # tool's program: pm/tools.tcl).
        set declaredFiles [pm::tools::Programs $descriptor]
        foreach library [dict get $entry libraries] {
            foreach key {file import} {
                if {[dict get $library $key] ne ""} { lappend declaredFiles [dict get $library $key] }
            }
        }
        foreach {viewPath path} $view {
            if {$viewPath in $declaredFiles} continue
            if {[LooksNative [dict get $files $path]]} {
                lappend problems "$path is a native binary ([pm::binary::describe [pm::binary::inspect [dict get $files $path] $path]]) no library declares: packed, it would be neither linked nor verified (native add it, or remove it)"
            }
        }
        # Each library.
        set identities [dict create]
        set exports [dict create]
        set definers [dict create]
        set provides [dict create]
        foreach library [dict get $entry libraries] {
            set name [dict get $library name]
            set report [dict create name $name origin [dict get $library origin] linkage [dict get $library linkage] \
                description "" sha256 "" identity [dict get $library identity] needs {} glibc "" \
                status "" evidence "" license [dict getdef $library license ""] symbols [llength [dict get $library symbols]]]
            if {[dict get $library origin] eq "bundled"} {
                if {![dict exists $view [dict get $library file]]} {
                    # (A layout problem, reported above.)
                    dict set report status missing
                    lappend reports $report
                    continue
                }
                set bytes [dict get $files [dict get $view [dict get $library file]]]
                dict set report sha256 [pm::sha256::hex $bytes]
                dict set report file [dict get $view [dict get $library file]]
                set importBytes ""
                if {[dict get $library import] ne "" && [dict exists $view [dict get $library import]]} {
                    set importBytes [dict get $files [dict get $view [dict get $library import]]]
                }
                if {[catch {pm::native::CheckBundled $target $library $bytes "library $name ([dict get $view [dict get $library file]])" $importBytes} facts]} {
                    lappend problems $facts
                    dict set report status contradicted
                    lappend reports $report
                    continue
                }
                dict set report description [dict get $facts description]
                dict set report needs [dict get $facts needs]
                dict set report glibc [dict get $facts glibc]
                dict set report status "as declared"
                if {[dict get $library linkage] eq "shared"} {
                    if {[pm::target::platformLibrary $target [dict get $facts identity]]} {
                        lappend problems "library $name is [dict get $facts identity], a library of $target's platform: a package never bundles the platform's own libraries (they are every installation's, in the version it has)"
                    }
                    foreach entryPath [dict get $facts rpath] {
                        if {$entryPath eq ""} {
                            lappend problems "library $name carries an empty run-time search path entry (RUNPATH/RPATH): the loader searches the current directory for its dependencies there, wherever a program runs (rebuild it without the build tree's search path, e.g. CMake's -DCMAKE_SKIP_RPATH=ON)"
                        } elseif {[string match {$ORIGIN*} $entryPath] || [string match {@loader_path*} $entryPath] || [string match {@executable_path*} $entryPath] || [string match {@rpath*} $entryPath]} {
                            lappend notes "library $name searches $entryPath at run time (relative to where it is installed)"
                        } else {
                            lappend problems "library $name carries the run-time search path $entryPath, a directory of the machine that built it: on a consumer's machine the loader would search it first, and the path varies with the build machine (rebuild it without the build tree's search path, e.g. CMake's -DCMAKE_SKIP_RPATH=ON)"
                        }
                    }
                    set key [string tolower [dict get $facts identity]]
                    if {[dict get $t format] ne "pe"} { set key [dict get $facts identity] }
                    if {[dict exists $identities $key] && [dict get $identities $key] ne $name} {
                        lappend problems "libraries [dict get $identities $key] and $name both load as [dict get $facts identity]: one loader identity is one library in a process"
                    }
                    dict set identities $key $name
                    dict set provides [string tolower [dict get $facts identity]] "bundled $name"
                    dict set provides [string tolower [file tail [dict get $facts identity]]] "bundled $name"
                    foreach symbol [dict get $facts symbols] { dict set exports $symbol "bundled $name" }
                } else {
                    foreach symbol [dict get $facts symbols] {
                        if {[string match __* $symbol]} continue
                        # A weak definition is no duplicate (the link takes
                        # the other definition first).
                        if {$symbol in [dict getdef $facts weak {}]} {
                            dict set exports $symbol "bundled $name"
                            continue
                        }
                        if {[dict exists $definers $symbol] && [dict get $definers $symbol] ne $name} {
                            lappend problems "the static libraries [dict get $definers $symbol] and $name both define $symbol: linking both is a duplicate definition"
                        }
                        dict set definers $symbol $name
                        # (C names: pm::binary takes a Mach-O member's
                        # leading underscore off its index names.)
                        dict set exports $symbol "bundled $name"
                    }
                }
                if {[dict getdef $library license ""] eq ""} {
                    lappend notes "library $name states no license: a consumer who redistributes it (native deploy places it beside an application) cannot learn its terms from the package (native add ... -license EXPR -notice PATH)"
                }
            } else {
                # A system library: the author states it; this host can
                # verify it only when it is the target's own.
                if {[dict get $library identity] ne ""} {
                    dict set provides [string tolower [dict get $library identity]] "system $name"
                    dict set provides [string tolower [file tail [dict get $library identity]]] "system $name"
                    set key [dict get $library identity]
                    if {[dict get $t format] eq "pe"} { set key [string tolower $key] }
                    if {[dict exists $identities $key] && [dict get $identities $key] ne $name} {
                        lappend problems "libraries [dict get $identities $key] and $name both load as [dict get $library identity]: one loader identity is one library in a process"
                    }
                    dict set identities $key $name
                }
                if {[pm::target::platformLibrary $target [dict get $library identity]]} {
                    lappend notes "system library $name is [dict get $library identity], part of $target's platform: declaring it is redundant"
                }
                if {$target eq $host} {
                    if {[catch {pm::native::System $target $library} evidence]} {
                        dict set report status "not verified here"
                        dict set report evidence $evidence
                        lappend partial "system library $name is not verified on this machine: $evidence (the consumer's system is verified when the package is installed there)"
                    } else {
                        dict set report status "verified here"
                        dict set report evidence "[dict get $evidence path], [dict get $evidence evidence][expr {[dict get $evidence version] ne "" ? ", version [dict get $evidence version]" : ""}]"
                        dict set report description [dict get $evidence facts]
                        catch {
                            set systemFacts [pm::binary::inspect [pm::ReadBytes [dict get $evidence path]] [dict get $evidence path]]
                            if {[dict exists $systemFacts symbols]} {
                                foreach symbol [dict get $systemFacts symbols] {
                                    if {![dict exists $exports $symbol]} { dict set exports $symbol "system $name" }
                                }
                            }
                        }
                    }
                } else {
                    dict set report status "unverifiable here"
                    lappend partial "system library $name of $target cannot be verified on this host ([pm::native::Or $host]): $target's system must provide it"
                }
            }
            lappend reports $report
        }
        # Every loader dependency of every bundled shared library resolves.
        set closure {}
        foreach library [dict get $entry libraries] {
            if {[dict get $library origin] ne "bundled" || [dict get $library linkage] ne "shared"} continue
            foreach need [dict get $library needs] {
                if {[pm::target::platformLibrary $target $need]} {
                    lappend closure [list [dict get $library name] $need platform ""]
                } elseif {[dict exists $provides [string tolower $need]]} {
                    lappend closure [list [dict get $library name] $need {*}[dict get $provides [string tolower $need]]]
                } elseif {[string match @rpath/* $need] && [dict exists $provides [string tolower [file tail $need]]]} {
                    lappend closure [list [dict get $library name] $need {*}[dict get $provides [string tolower [file tail $need]]]]
                } else {
                    lappend closure [list [dict get $library name] $need unresolved ""]
                    lappend problems "library [dict get $library name] needs $need, which is neither $target's platform nor a library this package declares for $target: unresolved (native require NAME -target $target -origin system -identity $need, or native add its file)"
                }
            }
        }
        # The package's source against its metadata.
        set selected [dict create]
        foreach library [dict get $entry libraries] {
            if {![dict exists $selected [dict get $library name]]} {
                dict set selected [dict get $library name] $library
            }
        }
        set linked {}
        foreach declaration [ViewLinks $view $files] {
            set name [dict get $declaration name]
            set where "[dict get $declaration file]:[dict get $declaration line]"
            if {[dict get $declaration kind] eq "framework"} {
                if {$name ni [dict get $entry frameworks]} {
                    lappend problems "$where links the framework $name, which $target's metadata does not declare (frameworks)"
                }
                continue
            }
            lappend linked $name
            if {![dict exists $selected $name]} {
                if {$name in [dict get $platformLinkNames [dict get $t os]]} continue
                lappend problems "$where links $name, which no library of $target's metadata declares: a consumer's link would depend on whatever its linker finds (native add the library, or native require $name -origin system)"
                continue
            }
            set library [dict get $selected $name]
            if {[dict get $declaration linkage] eq "static"} {
                set static 0
                foreach candidate [dict get $entry libraries] {
                    if {[dict get $candidate name] eq $name && [dict get $candidate linkage] eq "static"} { set static 1 }
                }
                if {!$static} {
                    lappend problems "$where requires a static $name, and $target's metadata provides a [dict get $library origin] [dict get $library linkage] one"
                }
            }
            if {[dict get $declaration path] ne ""} {
                set match 0
                foreach candidate [dict get $entry libraries] {
                    if {[dict get $candidate name] eq $name && [dict get $candidate origin] eq "bundled"
                            && [pm::native::NormalPath [dict get $declaration path]] eq [pm::native::NormalPath [dict get $candidate file]]} {
                        set match 1
                    }
                }
                if {!$match} {
                    lappend problems "$where links $name from [dict get $declaration path], and $target's metadata bundles no $name there"
                }
            }
        }
        foreach library [dict get $entry libraries] {
            set name [dict get $library name]
            if {$name in $linked} continue
            set needed 0
            foreach item $closure {
                if {[lindex $item 3] eq $name} { set needed 1 }
            }
            if {!$needed && [dict get $library origin] eq "bundled"} {
                lappend notes "library $name is neither linked by the package's modules nor needed by another of its libraries"
            }
        }
        # The C functions the modules declare, against the libraries' exports.
        set functions [ExternFunctions $view $files]
        set counts [dict create declared [dict size $functions] bundled 0 system 0 platform 0]
        set unresolved {}
        set platformSymbols {}
        dict for {symbol where} $functions {
            if {[dict exists $exports $symbol]} {
                dict incr counts [lindex [dict get $exports $symbol] 0]
                continue
            }
            lappend unresolved $symbol
        }
        if {$unresolved ne "" && $target eq $host} {
            set platformSymbols [PlatformSymbols $target]
            set still {}
            foreach symbol $unresolved {
                if {[lsearch -sorted $platformSymbols $symbol] >= 0} {
                    dict incr counts platform
                } else {
                    lappend still $symbol
                }
            }
            set unresolved $still
        }
        dict set counts unresolved $unresolved
        if {$unresolved ne ""} {
            set shown [lmap symbol [lrange $unresolved 0 3] {
                lassign [dict get $functions $symbol] file line
                string cat "$symbol ($file:$line)"
            }]
            set unverified 0
            foreach report $reports {
                if {[dict get $report origin] eq "system" && [dict get $report status] ne "verified here"} { set unverified 1 }
            }
            if {$unverified || $target ne $host} {
                lappend partial "[llength $unresolved] C function[expr {[llength $unresolved] == 1 ? "" : "s"}] the modules declare [expr {[llength $unresolved] == 1 ? "is" : "are"}] in no library readable here ([join $shown {, }][expr {[llength $unresolved] > 4 ? ", ..." : ""}]): expected from $target's platform[expr {$unverified ? " or its system libraries" : ""}], unverified"
            } else {
                lappend problems "[llength $unresolved] C function[expr {[llength $unresolved] == 1 ? "" : "s"}] the modules declare [expr {[llength $unresolved] == 1 ? "is" : "are"}] exported by no library of $target -- bundled, system or platform ([join $shown {, }][expr {[llength $unresolved] > 4 ? ", ..." : ""}]): a consumer's link would fail"
            }
        }
        # Run-time dependencies: never part of the closure, only reported.
        set runtime {}
        foreach dependency [dict getdef $entry runtime {}] {
            lappend runtime [dict create dependency $dependency evidence [RuntimeEvidence "" $target $dependency $files $descriptor]]
        }
        set status complete
        if {$partial ne ""} { set status partial }
        if {$problems ne ""} { set status incomplete }
        dict set result targets $target [dict create status $status problems $problems partial $partial notes $notes \
            libraries $reports closure $closure runtime $runtime functions $counts]
    }
    return $result
}

# 1 when the audit RESULT may be packed (no layout problem, no incomplete
# target).
proc pm::author::Packable {result} {
    if {[dict get $result problems] ne ""} {
        return 0
    }
    dict for {target report} [dict get $result targets] {
        if {[dict get $report status] eq "incomplete"} {
            return 0
        }
    }
    return 1
}

# The audit RESULT as report lines (VERBOSE 1: every library and need).
proc pm::author::AuditLines {result {verbose 1}} {
    set lines {}
    foreach problem [dict get $result problems] {
        lappend lines "problem: $problem"
    }
    dict for {target report} [dict get $result targets] {
        lappend lines "target $target: [dict get {complete complete partial "partially verified" incomplete INCOMPLETE} [dict get $report status]]"
        if {$verbose} {
            foreach library [dict get $report libraries] {
                set text "  library [dict get $library name]: [dict get $library origin] [dict get $library linkage]"
                if {[dict get $library description] ne ""} { append text ", [dict get $library description]" }
                lappend lines $text
                if {[dict get $library origin] eq "bundled" && [dict get $library sha256] ne ""} {
                    set detail "    [dict get $library file], sha256 [pm::Short [dict get $library sha256]]"
                    if {[dict get $library identity] ne "" && [dict get $library linkage] eq "shared"} {
                        append detail "; loads as [dict get $library identity]"
                    }
                    if {[dict get $library glibc] ne ""} {
                        append detail "; requires GLIBC_[join [dict get $library glibc] .]"
                    }
                    lappend lines $detail
                    lappend lines "    license: [expr {[dict get $library license] ne "" ? "[dict get $library license] (the author's statement)" : "none stated"}]; metadata [dict get $library status]"
                } elseif {[dict get $library origin] eq "system"} {
                    lappend lines "    [dict get $library status][expr {[dict get $library evidence] ne "" ? ": [dict get $library evidence]" : ""}]"
                }
            }
            foreach item [dict get $report closure] {
                lassign $item from need kind provider
                lappend lines "  [format %-22s $from] needs [format %-24s $need] [expr {$kind eq "platform" ? "the platform's" : ($kind eq "unresolved" ? "UNRESOLVED" : "$kind ($provider)")}]"
            }
            set f [dict get $report functions]
            if {[dict get $f declared] > 0} {
                lappend lines "  C functions the modules declare: [dict get $f declared] ([dict get $f bundled] bundled, [dict get $f system] system, [dict get $f platform] platform[expr {[dict get $f unresolved] ne "" ? ", [llength [dict get $f unresolved]] not found here" : ""}])"
            }
            foreach item [dict get $report runtime] {
                set d [dict get $item dependency]
                set when [dict get $d requirement]
                if {$when eq "capability"} { set when "capability \"[dict get $d capability]\"" }
                lappend lines "  run-time [dict get $d kind] [dict get $d name][expr {[dict get $d identity] ne "" ? " ([dict get $d identity])" : ""}]: $when[expr {[dict get $d loaded-by] ne "" ? ", loaded by [dict get $d loaded-by]" : ""}] -- [dict get $d purpose]"
                foreach line [dict get $item evidence] {
                    lappend lines "    $line"
                }
            }
        }
        foreach problem [dict get $report problems] {
            lappend lines "  problem: $problem"
        }
        foreach item [dict get $report partial] {
            lappend lines "  unverified: $item"
        }
        foreach note [dict get $report notes] {
            lappend lines "  note: $note"
        }
    }
    return $lines
}

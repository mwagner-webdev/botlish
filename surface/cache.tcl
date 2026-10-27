# cache.tcl -- the front-end cache (HIR-INTERCHANGE.md, "The front-end cache").
#
#   surface::cache::directory              the cache directory in effect ("" off)
#   surface::cache::lookup DIR PATH SOURCE MODE STRICT   the cached HIR, or ""
#   surface::cache::store DIR PATH SOURCE MODE STRICT HIR READS
#   surface::cache::stats / resetStats
#
# A program file's analyzed HIR, kept across processes in a directory the
# user names (BOTLISH_HIR_CACHE, or compileProgramFile's -cache option), in
# the HIR interchange format: a later compilation of the same program by the
# same front end, against the same modules, reads it instead of running the
# front end. It is an optimization only: a hit returns exactly the HIR the
# build would have returned (the build is a pure function of what the key and
# the dependencies hold: audit/hir-interchange/tools/roundtrip.tcl -via cache
# checks it over the golden corpus; the one exception is the time staticStats
# records, depMs, which a hit carries from the build it kept), and anything
# unexpected -- a missing, unreadable, foreign or stale entry, an unwritable
# directory -- is a miss, never an error.
#
# The key, compared exactly (its checksum only names the file):
#
#   the front end's fingerprint (hir::interchange::fingerprint)
#   the program's path as given (the HIR records it) and its exact text
#   its application root (the entry file's directory: surface/modules.tcl)
#   the library directory modules are read from, and the Tcl libraries loaded
#   -strict, the warning mode, the C target (std::ffi::c's widths, and the
#   architecture that selects an architecture-specific module), and the
#   static scheduler (BOTLISH_STATIC_SCHEDULER)
#
# The dependencies, checked on every hit: the module paths of each namespace
# a file of the program imports, by `import NS` or `import type NS::Type`
# (imports are the only thing that loads a module) -- its standard-library
# path, its architecture-specific file for the target's architecture
# (stdlib/linux/sys.x86_64.bot) and its application-module path -- with the
# exact text the build read there, or none for a path that had no module
# file (an intrinsics-only namespace's, `str`; an application path a
# standard namespace does not need), which must still have none. A module's
# paths are a function of its namespace, the library directory, the
# target's architecture and the application root alone (surface/modules.tcl:
# no search path), so nothing else can change which files a program reads --
# but which packages are installed, below the root: every package directory
# the loader asked about (there or not) and every file of a package's tree
# it probed are dependencies too (BOT-MODULES-MILESTONE-1.md).
#
# Targets: the key holds the full target name (macos-aarch64, never its
# architecture alone), so a compilation for one target never reads another
# target's entry, and a hit's HIR is checked against the target once more
# when it is decoded (hir::interchange::decode -target: a HIR built for
# another target is an invalid entry, a miss). An entry is per target even
# for a program whose HIR is every target's (hir::cabi::targetOf ""): the key
# is computed before the build that would tell, and the entries of such a
# program are equal.
#
# Warnings: an entry is per warning mode, and a hit in the default mode
# prints the warnings its HIR carries, as the build did. A compilation that
# fails, or that traces its static decisions (BOTLISH_STATIC_TRACE), is
# never cached.
#
# Sources: every text and every absence is the compilation's source provider's
# (surface/source.tcl), the program's and its dependencies' alike, from the
# one snapshot the compilation reads -- a lookup validates an entry against
# what that snapshot says, so a hit is exactly as valid for an unsaved buffer
# as for a file: validity is a matter of contents, never of where they came
# from. But only a compilation whose every answer came from the disk is kept
# (surface::source::persistable; stats `buffered` otherwise): an editor's
# buffer is a transient state of a document, and an entry built from one
# would only displace the disk's.

namespace eval surface::cache {
    variable version 1
    variable magic botlish-hir-cache
    variable stats [dict create hits 0 misses 0 stores 0 stale 0 invalid 0 unstored 0 buffered 0]
}

# The cache directory compilations use unless told otherwise: the
# environment's BOTLISH_HIR_CACHE (the host's configuration, read fresh by
# each compilation, like BOTLISH_WARNINGS), else "" (no cache).
proc surface::cache::directory {} {
    if {[info exists ::env(BOTLISH_HIR_CACHE)]} {
        return $::env(BOTLISH_HIR_CACHE)
    }
    return ""
}

proc surface::cache::stats {} {
    variable stats
    return $stats
}

proc surface::cache::resetStats {} {
    variable stats
    dict for {name _} $stats {
        dict set stats $name 0
    }
}

# 1 when a compilation may use the cache at all.
proc surface::cache::Usable {dir} {
    return [expr {$dir ne "" && !([info exists ::env(BOTLISH_STATIC_TRACE)]
        && $::env(BOTLISH_STATIC_TRACE) ni {"" 0})}]
}

proc surface::cache::Key {path source mode strict {target ""} {root ""}} {
    variable version
    # TARGET is the resolved C ABI target (hir::cabi::ResolveTarget): the
    # widths of std::ffi::c's integer scalars follow it (C-ABI-TYPES.md), and its
    # architecture picks an architecture-specific module's file
    # (surface/modules.tcl's ModuleFile). ROOT is the application root (the
    # same PATH as given names another directory from another working
    # directory). DFA-LOWERING is how a declared recognizer's table is
    # written (surface/dfa.tcl's `lowering`: the measurements' choice).
    return [list version $version front-end [hir::interchange::fingerprint] \
        path $path source $source library $::core::libraryDir \
        libraries $::core::loadedLibraries strict $strict warnings $mode target $target \
        root $root \
        scheduler [if {[info exists ::env(BOTLISH_STATIC_SCHEDULER)]} {set ::env(BOTLISH_STATIC_SCHEDULER)} else {string cat ""}] \
        dfa-lowering $::surface::dfa::lowering]
}

proc surface::cache::EntryPath {dir key} {
    set bytes [encoding convertto utf-8 $key]
    return [file join $dir [format %08x%08x.hirc [zlib crc32 $bytes] [zlib adler32 $bytes]]]
}

# The text of source file PATH, or "" with EXISTS 0 when there is none: the
# compilation's source provider's answer (surface/source.tcl).
proc surface::cache::Contents {path existsVar} {
    upvar 1 $existsVar exists
    set exists [surface::source::exists $path]
    if {$exists} {
        return [surface::source::text $path]
    }
    return ""
}

# HIR's dependencies besides the program itself: {PATH EXISTS TEXT} for the
# module paths of each namespace a file of it imports, by `import NS` or by
# `import type NS::Type`: its standard-library path, its architecture-
# specific file of C target TARGET's architecture (surface/modules.tcl's
# ModuleFile: the host's when "", as the build's) and its application-module
# path under ROOT, the program's application root ("" for none) -- imports
# are the only thing that loads a module (IMPORTS.md: dependencies are
# declared, never discovered), so these are every file its build read
# besides the program, and the paths it found no file at -- with the text
# its build read (READS: PATH -> text). Every candidate path of every
# namespace is kept, whichever exists: a file appearing at another one
# changes what the build would do.
#
# Resolution reads more than the imports' candidates
# (BOT-MODULES-MILESTONE-1.md): which file a namespace names depends on
# whether a package of its first segment is installed, in the importing
# file's scope, and a package's modules on its own scope's; and whether a
# qualifier names a namespace at all depends on a file no import names (an
# enum's case Color::Red, while no file Color.bot makes Color a namespace:
# AMBIGUOUS-QUALIFIER). The loader records every file and directory it asks
# about -- each candidate file of the application's or a package's tree and
# each package directory (OWNER/.bot_modules/NAME), there or not -- in PROBES
# (PATH -> file or directory, surface/modules.tcl's Probe), and every one is
# a dependency: {PATH EXISTS "" directory} for a directory, which must still
# be one (or still none). A build's application-module paths are among its
# probes; the HIR's own candidates above are what a caller with a HIR alone
# (no probes) gets.
proc surface::cache::Dependencies {hir reads {target ""} {root ""} {probes ""}} {
    set target [hir::cabi::ResolveTarget $target]
    if {$target eq ""} {
        set arch ""
    } else {
        set arch [dict get [core::cabi::target $target] arch]
    }
    set paths {}
    dict for {ns environment} [dict get $hir declarations imports] {
        set imported [dict get $environment namespaces]
        dict for {short qualified} [dict get $environment types] {
            set segments [split [string map {:: \x00} $qualified] \x00]
            lappend imported [join [lrange $segments 0 end-1] ::]
        }
        foreach namespace $imported {
            if {[string first / $namespace] >= 0} {
                # A module of a package installed by a package: its paths are
                # the loader's probes (below).
                continue
            }
            # A standard namespace's library files (none outside std), and
            # its path under the application root: the application's module
            # or, for std::NAME, the file that would make the import
            # RESERVED-NAMESPACE (STD-NAMESPACE.md).
            lappend paths [surface::modules::ModulePath $namespace]
            if {$arch ne ""} {
                lappend paths [surface::modules::ArchModulePath $namespace $arch]
            }
            if {$root ne ""} {
                lappend paths [surface::modules::NamespaceFile $root $namespace]
            }
        }
    }
    set directories {}
    dict for {path kind} $probes {
        if {$kind eq "directory"} {
            lappend directories $path
        } else {
            lappend paths $path
        }
    }
    set result {}
    foreach directory [lsort -unique $directories] {
        lappend result [list $directory [surface::source::directory $directory] "" directory]
    }
    foreach dependency [lsort -unique $paths] {
        if {$dependency eq ""} {
            continue
        }
        if {[dict exists $reads $dependency]} {
            lappend result [list $dependency 1 [dict get $reads $dependency]]
        } else {
            set text [Contents $dependency exists]
            lappend result [list $dependency $exists $text]
        }
    }
    return $result
}

# The HIR cached in DIR for the program at PATH with text SOURCE, compiled
# with warning MODE, -strict STRICT, C target TARGET and application root
# ROOT, or "" (a miss).
proc surface::cache::lookup {dir path source mode strict {target ""} {root ""}} {
    variable stats
    variable magic
    variable version
    if {![Usable $dir]} {
        return ""
    }
    set key [Key $path $source $mode $strict $target $root]
    set entryPath [EntryPath $dir $key]
    if {![file isfile $entryPath]} {
        dict incr stats misses
        return ""
    }
    try {
        set entry [core::ReadFile $entryPath]
        if {[dict get $entry $magic] ne $version || [dict get $entry key] ne $key} {
            # Another format, or another key with the same checksum.
            dict incr stats misses
            return ""
        }
        foreach dependency [dict get $entry dependencies] {
            lassign $dependency file exists text kind
            if {$kind eq "directory"} {
                if {[surface::source::directory $file] != $exists} {
                    dict incr stats stale
                    dict incr stats misses
                    return ""
                }
                continue
            }
            if {[Contents $file present] ne $text || $present != $exists} {
                dict incr stats stale
                dict incr stats misses
                return ""
            }
        }
        # The key holds the target; a HIR built for another one is still
        # never taken for this compilation's (an invalid entry: a miss).
        set hir [hir::interchange::decode [dict get $entry interchange] -target $target]
    } on error {} {
        dict incr stats invalid
        dict incr stats misses
        return ""
    }
    dict incr stats hits
    return $hir
}

# HIR, read from the cache for a compilation under warning MODE, after
# doing what the build would have done with its warnings: in the default
# mode, print each on CHANNEL ("" for none). (In the error mode a HIR has
# none: a build that found one raised it, and was not kept.)
proc surface::cache::Replay {hir mode channel} {
    if {$mode eq "default" && $channel ne ""} {
        foreach warning [hir::warnings::of $hir] {
            puts $channel [hir::warnings::render $hir $warning]
        }
    }
    return $hir
}

# Keeps HIR, just built from the program at PATH with text SOURCE under
# warning MODE and -strict STRICT, reading the module files READS (PATH ->
# text) after the probes PROBES (Dependencies), in DIR. Writes the entry under a private name, then renames it into
# place: a concurrent lookup sees the whole entry or none. A failure leaves
# the cache as it was (unstored).
proc surface::cache::store {dir path source mode strict hir reads {target ""} {root ""} {probes ""}} {
    variable stats
    variable magic
    variable version
    if {![Usable $dir]} {
        return
    }
    set key [Key $path $source $mode $strict $target $root]
    set entryPath [EntryPath $dir $key]
    set temporary ""
    try {
        set dependencies [Dependencies $hir $reads $target $root $probes]
        if {![surface::source::persistable]} {
            # (Asked after Dependencies, whose probes are the snapshot's too.)
            dict incr stats buffered
            return
        }
        set entry [list $magic $version key $key \
            dependencies $dependencies \
            interchange [hir::interchange::encode $hir -trait-source 1]]
        file mkdir $dir
        set temporary $entryPath.[pid].[clock microseconds]
        set channel [open $temporary w]
        try {
            fconfigure $channel -encoding utf-8 -translation lf
            puts -nonewline $channel $entry
        } finally {
            close $channel
        }
        file rename -force $temporary $entryPath
        dict incr stats stores
    } on error {} {
        dict incr stats unstored
        if {$temporary ne ""} {
            catch {file delete $temporary}
        }
    }
}

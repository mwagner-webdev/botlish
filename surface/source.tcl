# source.tcl -- where the front end's program text comes from: source
# providers (COMPILER-SERVICE-MILESTONE-1.md, "The source-provider seam").
#
#   surface::source::exists PATH          1 if PATH is a usable source file
#   surface::source::text PATH            its text, normalized
#   surface::source::directory PATH       1 if PATH is a directory (a package
#                                         installation's: BOT-MODULES-MILESTONE-1.md)
#   surface::source::normalize TEXT       the one line-ending normalization
#   surface::source::disk                 the disk provider (the default)
#   surface::source::overlay ENTRIES ?BASE?   unsaved buffers over BASE
#   surface::source::with PROVIDER SCRIPT     SCRIPT in a new snapshot of PROVIDER
#   surface::source::session SCRIPT       SCRIPT in the current snapshot (or a
#                                         new one of the disk)
#   surface::source::observed             what the current snapshot answered
#   surface::source::persistable          1 if every answer was the disk's
#
# The front end asks exactly three questions about program source, and asks
# them only here: is there a usable source file at a path (the loader's
# candidate module files: surface/modules.tcl's ResolveModule, ModuleFile,
# HasModule, ...), what is its text (the entry program, every module, the
# front-end cache's dependencies), and is there a directory at a path (the
# one directory the loader asks about: a package installation,
# OWNER/.bot_modules/NAME, BOT-MODULES-MILESTONE-1.md). Which namespace a
# path stands for is the loader's business alone (search-free: IMPORTS.md);
# a provider only answers for paths it is given, so it can never change
# resolution, only what is at a location.
#
# A provider is a command prefix, called as
#
#   PROVIDER lookup PATH     {exists 0|1 from disk|buffer ?version V?}
#   PROVIDER text PATH       the text at PATH (an error if there is none)
#   PROVIDER directory PATH  {exists 0|1 from disk}: a directory at PATH
#
# `from` says where the answer came from -- the file system, or an unsaved
# editor buffer with the caller's opaque VERSION -- for the front-end cache,
# which keeps only what the disk said (surface/cache.tcl). The disk provider
# is the default: what a compilation reads when nobody says otherwise. An
# overlay answers for the paths it holds -- a buffer's text, or "absent"
# (a file deleted in the editor) -- and asks its base for every other path.
# Directories are its base's: an overlay holds documents, never directories,
# so a package is installed where the disk says it is.
#
# Text is normalized at this boundary, once, whatever the provider: every
# "\r\n" and every lone "\r" becomes "\n" (normalize). That is what reading a
# file with Tcl's `auto` input translation always did (core::ReadFile), so a
# file analyzes exactly as before, and an editor's buffer of the same
# document -- CRLF or not -- analyzes exactly like the file: one text, one
# analysis. Positions inside the compiler count Unicode scalar values of the
# normalized text (lines and columns 1-based); no other convention enters.
#
# A snapshot. One compilation must see one consistent set of source facts,
# whatever happens to the disk meanwhile: inside `with` (or `session`) every
# path is asked about once -- the first answer is the snapshot's, and every
# later question gets it again -- and every answer is recorded (observed):
# the paths the compilation read, with their text, and the paths it probed
# and found no file at. That record is the compilation's dependency set (the
# front-end cache's, and a compiler-service revision's). Outside a snapshot
# the disk is asked directly. A directory's observation is {directory 1
# exists E from F}, under its path: a package directory and a module file
# never have one path (a module file's name ends in .bot, a package
# directory's is an identifier), and asking one path both ways is an error.

namespace eval surface::source {
    # The provider the questions go to (a command prefix).
    variable current [list ::surface::source::Disk]
    # The snapshot in force: PATH -> its observation ({exists E from F
    # ?version V? ?text T?}), or "" outside one.
    variable snapshot ""
    variable active 0
}

# The disk provider: the file system, read as UTF-8 (program files are UTF-8
# whatever the platform's encoding is), a path a usable source exactly when it
# is a file.
proc surface::source::disk {} {
    return [list ::surface::source::Disk]
}

proc surface::source::Disk {method path} {
    switch -- $method {
        lookup {
            return [dict create exists [file isfile $path] from disk]
        }
        directory {
            return [dict create exists [file isdirectory $path] from disk]
        }
        text {
            set channel [open $path r]
            # No translation here: normalize is the one place line endings
            # change.
            fconfigure $channel -encoding utf-8 -translation lf
            try {
                return [read $channel]
            } finally {
                close $channel
            }
        }
    }
    error "surface::source: unknown provider method \"$method\""
}

# TEXT with its line endings normalized: "\r\n" and a lone "\r" are "\n".
proc surface::source::normalize {text} {
    return [string map [list \r\n \n \r \n] $text]
}

# A provider answering for the paths of ENTRIES -- a dict PATH -> {text TEXT
# ?version V?} (an unsaved buffer, as the editor has it: `text` normalizes it
# like any provider's) or PATH -> {absent 1 ?version V?} (a file deleted in
# the editor) -- and asking BASE (the disk by default) about every other
# path. Paths are compared normalized (`file normalize`), so a buffer is
# found under any spelling of its path.
proc surface::source::overlay {entries {base ""}} {
    if {$base eq ""} {
        set base [disk]
    }
    set normal [dict create]
    dict for {path entry} $entries {
        if {![dict exists $entry text] && ![dict exists $entry absent]} {
            error "surface::source::overlay: an entry needs text or absent: $path"
        }
        dict set normal [file normalize $path] $entry
    }
    return [list ::surface::source::Overlay $normal $base]
}

proc surface::source::Overlay {entries base method path} {
    if {$method eq "directory"} {
        return [{*}$base directory $path]
    }
    set key [file normalize $path]
    if {![dict exists $entries $key]} {
        return [{*}$base $method $path]
    }
    set entry [dict get $entries $key]
    switch -- $method {
        lookup {
            return [dict create exists [dict exists $entry text] from buffer \
                version [dict getdef $entry version ""]]
        }
        text {
            if {![dict exists $entry text]} {
                NoSuchFile $path
            }
            return [dict get $entry text]
        }
    }
    error "surface::source: unknown provider method \"$method\""
}

# Raises what opening PATH raises when there is no file there.
proc surface::source::NoSuchFile {path} {
    error "couldn't open \"$path\": no such file or directory" "" {POSIX ENOENT {no such file or directory}}
}

# Runs SCRIPT (in the caller's frame) in a new snapshot whose questions go to
# PROVIDER, and returns its result. The snapshot ends with SCRIPT: a caller
# that wants the record reads `observed` before SCRIPT ends.
proc surface::source::with {provider script} {
    variable current
    variable snapshot
    variable active
    set saved [list $current $snapshot $active]
    set current $provider
    set snapshot [dict create]
    set active 1
    try {
        return [uplevel 1 $script]
    } finally {
        lassign $saved current snapshot active
    }
}

# Runs SCRIPT (in the caller's frame) in the snapshot in force, or in a new
# one of the current provider (the disk, unless `with` says otherwise) if
# there is none: what one compilation runs in (surface/modules.tcl's
# compileProgramFile).
proc surface::source::session {script} {
    variable active
    variable current
    if {$active} {
        return [uplevel 1 $script]
    }
    return [uplevel 1 [list surface::source::with $current $script]]
}

# The snapshot's observation of PATH, made now if it is the first question
# about PATH.
proc surface::source::Observe {path} {
    variable snapshot
    variable current
    if {![dict exists $snapshot $path]} {
        dict set snapshot $path [{*}$current lookup $path]
    } elseif {[dict exists $snapshot $path directory]} {
        error "surface::source: $path was asked about as a directory and as a file"
    }
    return [dict get $snapshot $path]
}

# 1 if PATH is a directory: a package installation (the loader's only
# directory question, surface/modules.tcl's Installed). Recorded in the
# snapshot as {directory 1 exists E from F}.
proc surface::source::directory {path} {
    variable active
    variable current
    variable snapshot
    if {!$active} {
        return [dict get [{*}$current directory $path] exists]
    }
    if {![dict exists $snapshot $path]} {
        dict set snapshot $path [dict merge [{*}$current directory $path] {directory 1}]
    } elseif {![dict exists $snapshot $path directory]} {
        error "surface::source: $path was asked about as a file and as a directory"
    }
    return [dict get $snapshot $path exists]
}

# 1 if PATH is a usable source file.
proc surface::source::exists {path} {
    variable active
    variable current
    if {!$active} {
        return [dict get [{*}$current lookup $path] exists]
    }
    return [dict get [Observe $path] exists]
}

# The text of the source file PATH, normalized (normalize); an error if there
# is none.
proc surface::source::text {path} {
    variable active
    variable current
    variable snapshot
    if {!$active} {
        return [normalize [{*}$current text $path]]
    }
    set observation [Observe $path]
    if {[dict exists $observation text]} {
        return [dict get $observation text]
    }
    if {![dict get $observation exists]} {
        NoSuchFile $path
    }
    set text [normalize [{*}$current text $path]]
    dict set snapshot $path text $text
    return $text
}

# The current snapshot's observations: PATH -> {exists E from F ?version V?
# ?text T?} for every path asked about, in the order first asked (text only
# for a path whose text was read; {directory 1 exists E from F} for a
# directory). Empty outside a snapshot.
proc surface::source::observed {} {
    variable snapshot
    variable active
    if {!$active} {
        return [dict create]
    }
    return $snapshot
}

# 1 when every answer of the current snapshot came from the disk: a
# compilation whose result the persistent front-end cache may keep
# (surface/cache.tcl). Unsaved buffers are a transient state of a document;
# an entry built from them would only push out the disk's.
proc surface::source::persistable {} {
    dict for {path observation} [observed] {
        if {[dict get $observation from] ne "disk"} {
            return 0
        }
    }
    return 1
}

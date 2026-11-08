# catalog.tcl -- where artifacts come from (PACKAGE-MANAGER-MILESTONE-1.md,
# "Local package sources").
#
# An artifact is acquired from exactly one of:
#
#   * an archive source: the project's botlish.json names one .botpkg file
#     for a direct dependency, with its SHA-256 ("sources": {"NAME":
#     {"archive": PATH, "sha256": D}}), PATH relative to the project
#     directory;
#   * a local repository: a directory the command line names
#     (-repository DIR, any number), holding artifacts under their
#     canonical names NAME-VERSION.botpkg, side by side (no subdirectories).
#     An artifact NAME VERSION is the file NAME-VERSION.botpkg of each
#     repository; when two repositories hold different bytes under that
#     name, the lookup fails and names both: there is no precedence among
#     repositories, and no candidate is ever chosen arbitrarily.
#
# Whatever the source, an artifact is read whole, its SHA-256 computed from
# the bytes read (never taken from a file name or a record), the archive
# validated completely (pm::archive) and its botlish.json validated as an
# artifact's (pm::descriptor, context artifact); its embedded identity must
# be the one asked for. Nothing else is consulted: no parent directory, no
# working directory, no environment variable, no global installation, no
# network. A digest a project writes beside an archive source is that
# project's own integrity assertion, not evidence of who published the
# artifact (no artifact carries a signature before PM-4).
#
# Editable dependencies ("sources": {"NAME": {"directory": PATH}}) are no
# artifacts: they are linked, never copied or packed (Editable).

namespace eval pm::catalog {
    # The repositories of this command (absolute directories).
    variable repositories {}
    # Artifacts already acquired by this command: normalized path -> artifact.
    variable loaded [dict create]
}

# The repositories DIRS of a command: kept sorted, so that nothing a
# command does or says -- not even the order a message names them in --
# depends on the order the command line gave them (there is no precedence
# among them).
proc pm::catalog::configure {dirs} {
    variable repositories
    variable loaded
    set repositories {}
    set loaded [dict create]
    foreach dir $dirs {
        set dir [file normalize $dir]
        if {![file isdirectory $dir]} {
            pm::Fail REPOSITORY "the repository $dir is not a directory"
        }
        lappend repositories $dir
    }
    set repositories [lsort -unique $repositories]
}

proc pm::catalog::RepositoryCount {} {
    variable repositories
    return [llength $repositories]
}

# The artifact of the archive file PATH: {name version digest path size
# files descriptor}. ORIGIN describes how it was reached, for messages.
proc pm::catalog::Load {path origin} {
    variable loaded
    set path [file normalize $path]
    if {[dict exists $loaded $path]} {
        return [dict get $loaded $path]
    }
    if {![file isfile $path]} {
        pm::Fail ARTIFACT "$origin: no archive $path"
    }
    if {[catch {
        set bytes [pm::ReadBytes $path]
        set archive [pm::archive::fromBytes $bytes $path]
    } message options]} {
        if {[lrange [dict get $options -errorcode] 0 1] eq {PM ARCHIVE}} {
            pm::Fail ARTIFACT "$origin: the archive is invalid: $message"
        }
        return -options $options $message
    }
    set digest [pm::sha256::hex $bytes]
    if {[catch {pm::descriptor::fromBytes [dict get $archive descriptor] artifact "$path: botlish.json"} descriptor]} {
        pm::Fail ARTIFACT "$origin: $descriptor"
    }
    if {[pm::targets::Aware $descriptor]} {
        set problems [pm::targets::Problems $descriptor [dict keys [dict get $archive files]]]
        if {$problems ne ""} {
            pm::Fail ARTIFACT "$origin: the artifact's target layout is invalid:\n  [join $problems "\n  "]"
        }
    }
    if {[dict getdef $descriptor tools {}] ne ""} {
        # A tool's programs are files of the artifact, each an executable of
        # its host: checked at every acquisition, never run by it.
        set problems [pm::tools::Problems $descriptor [dict get $archive files]]
        if {$problems ne ""} {
            pm::Fail ARTIFACT "$origin: the artifact's tools are invalid:\n  [join $problems "\n  "]"
        }
    }
    set artifact [dict create name [dict get $descriptor name] version [dict get $descriptor version] \
        digest $digest path $path size [dict get $archive size] files [dict get $archive files] \
        descriptor $descriptor]
    dict set loaded $path $artifact
    return $artifact
}

# The artifact of the archive source of dependency NAME of the project
# PROJECT: its file's digest must be the source's, its identity NAME.
proc pm::catalog::ArchiveSource {project name source} {
    set path [pm::ProjectPath $project [dict get $source path]]
    set artifact [Load $path "dependency $name (archive source [dict get $source path])"]
    if {[dict get $artifact digest] ne [dict get $source sha256]} {
        pm::Fail INTEGRITY "dependency $name: the archive [dict get $source path] has the SHA-256 [dict get $artifact digest], and botlish.json's sources record [dict get $source sha256]: the file is not the artifact this project was set up with. If the change is intended, add it again (add PATH -replace)"
    }
    if {[dict get $artifact name] ne $name} {
        pm::Fail IDENTITY "dependency $name: the archive [dict get $source path] is the package [dict get $artifact name] [dict get $artifact version], not $name"
    }
    return $artifact
}

# The versions of NAME the repositories hold (by their files' canonical
# names), oldest first.
proc pm::catalog::Versions {name} {
    variable repositories
    set versions {}
    foreach repository $repositories {
        foreach path [glob -nocomplain -directory $repository -types {f l} $name-*.botpkg] {
            set version [string range [file tail $path] [string length $name-] end-7]
            if {![pm::version::isVersion $version]} {
                pm::Fail REPOSITORY "the repository file $path is not named NAME-VERSION.botpkg (an exact version)"
            }
            lappend versions $version
        }
    }
    return [pm::version::sort [lsort -unique $versions]]
}

# The artifact NAME VERSION from the repositories; CHAIN is the dependency
# path that needs it (a list of NAME VERSION pairs), for messages.
proc pm::catalog::Find {name version chain} {
    variable repositories
    set needed [Chain $chain]
    if {$repositories eq ""} {
        pm::Fail UNAVAILABLE "$needed needs $name $version, and no repository was given: pass -repository DIR, a directory holding $name-$version.botpkg"
    }
    set found {}
    foreach repository $repositories {
        set path [file join $repository $name-$version.botpkg]
        if {[file isfile $path]} {
            lappend found [Load $path "$name $version (needed by $needed)"]
        }
    }
    if {$found eq ""} {
        set have [Versions $name]
        if {$have eq ""} {
            set held "no version of $name"
        } else {
            set held "only $name [join $have {, }]"
        }
        pm::Fail UNAVAILABLE "$needed needs $name $version, which no repository holds ($held in [join $repositories {, }])"
    }
    set first [lindex $found 0]
    foreach artifact [lrange $found 1 end] {
        if {[dict get $artifact digest] ne [dict get $first digest]} {
            pm::Fail CONFLICT "two different artifacts claim $name $version: [dict get $first path] (sha256 [dict get $first digest]) and [dict get $artifact path] (sha256 [dict get $artifact digest]). A release is immutable: remove the one that is not $name $version"
        }
    }
    if {[dict get $first name] ne $name || [dict get $first version] ne $version} {
        pm::Fail IDENTITY "the repository file [dict get $first path] holds [dict get $first name] [dict get $first version], not $name $version: an artifact's file is named by its own identity"
    }
    return $first
}

# "the project" or "the project -> a 1.0.0 -> b 2.1.0" for CHAIN.
proc pm::catalog::Chain {chain} {
    set text "the project"
    foreach {name version} $chain {
        append text " -> $name $version"
    }
    return $text
}

# The editable dependency NAME whose source is the directory SOURCE of the
# project PROJECT: {name version target descriptor}. Its botlish.json must
# name it NAME and give its version.
proc pm::catalog::Editable {project name source} {
    set target [pm::ProjectPath $project [dict get $source path]]
    if {![file isdirectory $target]} {
        pm::Fail EDITABLE "dependency $name: the editable directory [dict get $source path] ($target) does not exist"
    }
    if {[catch {pm::descriptor::read [file join $target botlish.json] project} descriptor]} {
        pm::Fail EDITABLE "dependency $name: the editable directory [dict get $source path]: $descriptor"
    }
    if {$name eq ""} {
        set name [dict get $descriptor name]
        if {$name eq ""} {
            pm::Fail EDITABLE "the directory [dict get $source path] has no package name in its botlish.json"
        }
    }
    if {[dict get $descriptor name] ne $name} {
        pm::Fail IDENTITY "dependency $name: the editable directory [dict get $source path] is the package \"[dict get $descriptor name]\", not $name"
    }
    if {[dict get $descriptor version] eq ""} {
        pm::Fail EDITABLE "dependency $name: the editable directory [dict get $source path] has no version in its botlish.json"
    }
    return [dict create name $name version [dict get $descriptor version] target $target descriptor $descriptor]
}

# descriptor.tcl -- botlish.json, schemas 1 to 4 (BOTLISH-JSON.md, the
# normative specification; PACKAGE-MANAGER-MILESTONE-1.md and
# PACKAGE-MANAGER-MILESTONE-2.md).
#
#   pm::descriptor::read PATH CONTEXT          the descriptor of the file PATH
#   pm::descriptor::fromBytes BYTES CONTEXT LABEL
#   pm::descriptor::encode DESCRIPTOR ?-sources 0|1?   canonical UTF-8 text
#   pm::descriptor::new                        an empty project descriptor
#
# A descriptor is a dict:
#
#   schema        1, 2 or 3 (as the file says: a file is read and written in
#                 its own schema; schema 3 is schema 2 with runtime
#                 dependencies and a library's license and notices,
#                 BOTLISH-JSON.md section 13)
#   name          the package's root namespace, or "" (an application may
#                 have none)
#   version       its exact release, or ""
#   dependencies  dict NAME -> REQUEST (direct dependencies only)
#   lock          dict NAME -> exact VERSION (direct dependencies only)
#   sources       dict NAME -> {kind archive path P sha256 D}
#                            | {kind directory path P}
#   targets       (schema 2 only: absent from a schema 1 descriptor) dict TARGET -> {files DIR libraries {LIB...}
#                 frameworks {NAME...} headers {DIR...}}: a target-aware
#                 package's targets, each with the artifact directory
#                 overlaid on the package root for it and its native
#                 dependencies; empty for a target-independent package
#                 (pm/targets.tcl, BOTLISH-JSON.md section 12)
#   origins       (schema 2, projects) dict LIBRARY -> system|bundled: the
#                 consumer's choice where a package offers both
#   tools         (schema 4 only) dict NAME -> {protocol N summary S programs
#                 {HOST PATH ...} inputs {KIND...} environment {VAR...}}: the
#                 programs the package carries for a developer to run
#                 explicitly (pm/tools.tcl, BOTLISH-TOOLS.md); never run by
#                 any other operation
#
# CONTEXT says which rules apply:
#
#   project    a project being managed (an application or a package under
#              development): name and version optional, locks may be
#              incomplete while authoring, sources allowed;
#   pack       a package directory being packed: name and version required,
#              every dependency locked (an editable dependency has no lock,
#              so it cannot be packed), sources allowed (never packed);
#   artifact   the botlish.json inside a .botpkg: name and version required,
#              every dependency locked, no sources at all.
#
# In every context: unknown keys are errors (a newer schema is refused, not
# half-read), a lock or a source names a declared dependency, a lock
# satisfies its request, an editable (directory) dependency has no lock, and
# no package depends on its own name. Every problem is reported, each on its
# own line, as {PM DESCRIPTOR}.

namespace eval pm::descriptor {
    variable keys {schema name version dependencies lock sources}
    variable keys2 {schema name version dependencies lock sources targets origins}
    # Schema 4 (EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md,
    # BOTLISH-JSON.md section 14) is schema 3 with `tools`.
    variable keys4 {schema name version dependencies lock sources targets origins tools}
    variable reserved {std}
    variable nameRule {^[a-z][a-z0-9_]{0,63}$}
}

# The lexer's keywords, which no namespace segment can be (an import would
# not parse). Read from the compiler's own lexer, never copied.
proc pm::descriptor::Keywords {} {
    if {![info exists ::surface::lexer::keywords]} {
        uplevel #0 [list source [file join $::pm::root surface lexer.tcl]]
    }
    return $::surface::lexer::keywords
}

# "" when NAME is a valid package name, else why not.
proc pm::descriptor::NameProblem {name} {
    variable nameRule
    variable reserved
    if {![regexp $nameRule $name]} {
        return "the package name \"$name\" is not a package name: a package's name is its root namespace, a lowercase identifier of at most 64 characters (a-z first, then a-z, 0-9, _), the same on every file system"
    }
    if {$name in $reserved} {
        return "the package name \"$name\" is reserved: std and every namespace under it belong to the compiler's standard library"
    }
    if {$name in [Keywords]} {
        return "the package name \"$name\" is a Botlish keyword, which no import can name"
    }
    return ""
}

proc pm::descriptor::new {} {
    return [dict create schema 1 name "" version "" dependencies {} lock {} sources {}]
}

proc pm::descriptor::read {path context} {
    if {![file isfile $path]} {
        return -code error -errorcode {PM DESCRIPTOR MISSING} "no botlish.json at $path"
    }
    set channel [open $path rb]
    set bytes [::read $channel [expr {1024 * 1024 + 1}]]
    close $channel
    return [fromBytes $bytes $context $path]
}

proc pm::descriptor::fromBytes {bytes context label} {
    if {[catch {pm::json::decode $bytes} value options]} {
        return -code error -errorcode {PM DESCRIPTOR} "$label: $value"
    }
    return [Validate $value $context $label]
}

proc pm::descriptor::Validate {value context label} {
    variable keys
    variable keys2
    variable keys4
    set problems {}
    set result [new]
    if {[pm::json::type $value] ne "obj"} {
        Raise $label [list "the file is not a JSON object"]
    }
    set members [pm::json::payload $value]
    # schema
    if {![dict exists $members schema]} {
        lappend problems "no \"schema\": a botlish.json starts with \"schema\": 1 (or 2, 3 or 4)"
        Raise $label $problems
    }
    set schema [dict get $members schema]
    if {[pm::json::type $schema] ne "num" || ![regexp {^[0-9]+$} [pm::json::payload $schema]]} {
        lappend problems "\"schema\" must be the number 1, 2, 3 or 4"
        Raise $label $problems
    }
    set number [pm::json::payload $schema]
    if {$number ni {1 2 3 4}} {
        lappend problems "unsupported schema $number: this package manager reads schemas 1, 2, 3 and 4 (a newer one needs a newer Botlish)"
        Raise $label $problems
    }
    dict set result schema $number
    if {$number >= 2} {
        dict set result targets {}
        dict set result origins {}
    }
    if {$number >= 4} {
        dict set result tools {}
    }
    set allowed [expr {$number == 1 ? $keys : ($number < 4 ? $keys2 : $keys4)}]
    foreach {key item} $members {
        if {$key ni $allowed} {
            if {$key eq "tools" && $number < 4} {
                lappend problems "\"tools\" is a schema 4 key: a botlish.json declaring tools says \"schema\": 4 (a reader of an earlier schema would not know them)"
            } elseif {$number == 1 && $key in $keys2} {
                lappend problems "\"$key\" is a schema 2 key: a botlish.json using it says \"schema\": 2 (schema 1 has [join $keys {, }])"
            } else {
                lappend problems "unknown key \"$key\" (schema $number has [join $allowed {, }]): a key a later schema adds is never silently ignored"
            }
        }
    }
    # name, version
    foreach key {name version} {
        if {![dict exists $members $key]} continue
        set item [dict get $members $key]
        if {[pm::json::type $item] ne "str"} {
            lappend problems "\"$key\" must be a string"
            continue
        }
        set text [pm::json::payload $item]
        if {$key eq "name"} {
            set problem [NameProblem $text]
        } else {
            set problem [pm::version::Problem $text "package version"]
        }
        if {$problem ne ""} {
            lappend problems $problem
        } else {
            dict set result $key $text
        }
    }
    if {$context in {pack artifact}} {
        foreach key {name version} {
            if {![dict exists $members $key]} {
                lappend problems "no \"$key\": a [Describe $context] has a name and an exact version"
            }
        }
    } elseif {[dict exists $members version] && ![dict exists $members name]} {
        lappend problems "a \"version\" without a \"name\": the version of what?"
    }
    # dependencies, lock
    foreach key {dependencies lock} {
        if {![dict exists $members $key]} continue
        set item [dict get $members $key]
        if {[pm::json::type $item] ne "obj"} {
            lappend problems "\"$key\" must be an object of package names"
            continue
        }
        foreach {dep text} [pm::json::payload $item] {
            set problem [NameProblem $dep]
            if {$problem ne ""} {
                lappend problems "$key: $problem"
                continue
            }
            if {[pm::json::type $text] ne "str"} {
                lappend problems "$key: \"$dep\" must be a version string"
                continue
            }
            set text [pm::json::payload $text]
            if {$key eq "dependencies"} {
                set problem [pm::version::RequestProblem $text]
            } else {
                set problem [pm::version::Problem $text "locked version"]
            }
            if {$problem ne ""} {
                lappend problems "$key: \"$dep\": $problem"
                continue
            }
            dict set result $key $dep $text
        }
    }
    # sources
    if {[dict exists $members sources]} {
        set item [dict get $members sources]
        if {$context eq "artifact"} {
            lappend problems "an artifact's botlish.json has no \"sources\": where a consumer finds a dependency is its own installation's business, never the published package's"
        } elseif {[pm::json::type $item] ne "obj"} {
            lappend problems "\"sources\" must be an object of package names"
        } else {
            foreach {dep spec} [pm::json::payload $item] {
                set problem [NameProblem $dep]
                if {$problem ne ""} {
                    lappend problems "sources: $problem"
                    continue
                }
                set source [Source $dep $spec problems]
                if {$source ne ""} {
                    dict set result sources $dep $source
                }
            }
        }
    }
    # targets, origins (schema 2)
    if {[dict exists $members targets] && $number >= 2} {
        dict set result targets [pm::targets::Parse [dict get $members targets] problems $number]
    }
    if {[dict exists $members origins] && $number >= 2} {
        set item [dict get $members origins]
        if {$context eq "artifact"} {
            lappend problems "an artifact's botlish.json has no \"origins\": which origin a consumer's native library comes from is the consumer's choice, never the published package's"
        } elseif {[pm::json::type $item] ne "obj"} {
            lappend problems "\"origins\" must be an object of native library names"
        } else {
            foreach {library choice} [pm::json::payload $item] {
                if {[set problem [pm::targets::LibraryNameProblem $library]] ne ""} {
                    lappend problems "origins: $problem"
                } elseif {[pm::json::type $choice] ne "str" || [pm::json::payload $choice] ni {system bundled}} {
                    lappend problems "origins: \"$library\" must be \"system\" or \"bundled\""
                } else {
                    dict set result origins $library [pm::json::payload $choice]
                }
            }
        }
    }
    # tools (schema 4)
    if {[dict exists $members tools] && $number >= 4} {
        dict set result tools [pm::tools::Parse [dict get $members tools] problems]
    }
    # Relations.
    set own [dict get $result name]
    dict for {dep request} [dict get $result dependencies] {
        if {$own ne "" && $dep eq $own} {
            lappend problems "the package $own depends on its own name: its dependency would claim the namespace $own inside it"
        }
        set editable [expr {[dict exists $result sources $dep] && [dict get $result sources $dep kind] eq "directory"}]
        if {[dict exists $result lock $dep]} {
            set locked [dict get $result lock $dep]
            if {$editable} {
                lappend problems "lock: \"$dep\" is an editable directory dependency, which has no exact lock (its contents are whatever the directory holds)"
            } elseif {![pm::version::satisfies $locked $request]} {
                lappend problems "lock: \"$dep\" is locked to $locked, which the request \"$request\" does not accept"
            }
        } elseif {$context in {pack artifact}} {
            if {$editable} {
                lappend problems "dependencies: \"$dep\" is an editable directory dependency: a [Describe $context] locks every direct dependency to an exact release"
            } else {
                lappend problems "lock: \"$dep\" has no lock: a [Describe $context] locks every direct dependency to an exact release"
            }
        }
    }
    foreach key {lock sources} {
        dict for {dep -} [dict get $result $key] {
            if {![dict exists $result dependencies $dep]} {
                lappend problems "$key: \"$dep\" is no dependency (it is not in \"dependencies\")"
            }
        }
    }
    if {$problems ne ""} {
        Raise $label $problems
    }
    return $result
}

proc pm::descriptor::Describe {context} {
    return [dict get {pack {package being packed} artifact {package artifact} project project} $context]
}

proc pm::descriptor::Raise {label problems} {
    return -code error -errorcode {PM DESCRIPTOR} \
        "$label:\n  [join $problems "\n  "]"
}

# The source of dependency DEP from its JSON SPEC, or "" with a problem
# appended to PROBLEMS.
proc pm::descriptor::Source {dep spec problemsVar} {
    upvar 1 $problemsVar problems
    if {[pm::json::type $spec] ne "obj"} {
        lappend problems "sources: \"$dep\" must be an object: {\"archive\": PATH, \"sha256\": DIGEST} or {\"directory\": PATH}"
        return ""
    }
    set members [pm::json::payload $spec]
    set keys [dict keys $members]
    foreach {key item} $members {
        if {[pm::json::type $item] ne "str"} {
            lappend problems "sources: \"$dep\": \"$key\" must be a string"
            return ""
        }
    }
    if {[lsort $keys] eq {archive sha256}} {
        set path [pm::json::payload [dict get $members archive]]
        set digest [pm::json::payload [dict get $members sha256]]
        if {[set problem [PathProblem $path]] ne ""} {
            lappend problems "sources: \"$dep\": $problem"
            return ""
        }
        if {![regexp {^[0-9a-f]{64}$} $digest]} {
            lappend problems "sources: \"$dep\": \"sha256\" must be the artifact's SHA-256 digest, 64 lowercase hexadecimal digits"
            return ""
        }
        return [dict create kind archive path $path sha256 $digest]
    }
    if {$keys eq {directory}} {
        set path [pm::json::payload [dict get $members directory]]
        if {[set problem [PathProblem $path]] ne ""} {
            lappend problems "sources: \"$dep\": $problem"
            return ""
        }
        return [dict create kind directory path $path]
    }
    lappend problems "sources: \"$dep\" must be {\"archive\": PATH, \"sha256\": DIGEST} (an immutable local artifact) or {\"directory\": PATH} (an editable local package), found the keys [join $keys {, }]"
    return ""
}

# "" when PATH is a valid source path: relative to the project directory,
# "/"-separated, no empty or "." segment (".." is allowed: the project's own
# configuration may name a sibling directory).
proc pm::descriptor::PathProblem {path} {
    if {$path eq ""} {
        return "the path is empty"
    }
    if {[string match /* $path] || [regexp {^[A-Za-z]:} $path] || [string first \\ $path] >= 0} {
        return "the path \"$path\" must be relative to the project's directory, with \"/\" separators: an absolute or Windows-style path would tie the project to one machine"
    }
    foreach segment [split $path /] {
        if {$segment in {"" .}} {
            return "the path \"$path\" has an empty or \".\" segment"
        }
    }
    return ""
}

# The canonical UTF-8 text of DESCRIPTOR: keys in schema order (schema, name,
# version, dependencies, lock, sources), every map sorted by name, no empty
# key but dependencies of a project. WITHSOURCES 0 leaves sources out (an
# artifact's descriptor never holds them).
proc pm::descriptor::encode {descriptor {withSources 1}} {
    set members [list schema [list num [dict getdef $descriptor schema 1]]]
    foreach key {name version} {
        if {[dict get $descriptor $key] ne ""} {
            lappend members $key [list str [dict get $descriptor $key]]
        }
    }
    foreach key {dependencies lock} {
        set map [dict get $descriptor $key]
        if {$map eq "" && $key eq "lock"} continue
        set object {}
        foreach dep [lsort [dict keys $map]] {
            lappend object $dep [list str [dict get $map $dep]]
        }
        lappend members $key [list obj $object]
    }
    if {$withSources && [dict get $descriptor sources] ne ""} {
        set object {}
        foreach dep [lsort [dict keys [dict get $descriptor sources]]] {
            set source [dict get $descriptor sources $dep]
            if {[dict get $source kind] eq "archive"} {
                lappend object $dep [list obj [list archive [list str [dict get $source path]] sha256 [list str [dict get $source sha256]]]]
            } else {
                lappend object $dep [list obj [list directory [list str [dict get $source path]]]]
            }
        }
        lappend members sources [list obj $object]
    }
    if {[dict getdef $descriptor targets {}] ne ""} {
        lappend members targets [pm::targets::Value [dict get $descriptor targets]]
    }
    if {[dict getdef $descriptor tools {}] ne ""} {
        lappend members tools [pm::tools::Value [dict get $descriptor tools]]
    }
    if {$withSources && [dict getdef $descriptor origins {}] ne ""} {
        set object {}
        foreach library [lsort [dict keys [dict get $descriptor origins]]] {
            lappend object $library [list str [dict get $descriptor origins $library]]
        }
        lappend members origins [list obj $object]
    }
    return [pm::json::encode [list obj $members]]
}

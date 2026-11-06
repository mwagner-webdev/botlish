# state.tcl -- the installation record (PACKAGE-MANAGER-MILESTONE-1.md,
# "Ownership").
#
# A project's managed packages are recorded in
# PROJECT/.bot_modules/.botlish/state.json, which only the package manager
# writes. It is what makes a directory of .bot_modules *managed*: a
# top-level PROJECT/.bot_modules/NAME the record names is the manager's
# (with everything under it, its nested .bot_modules included); any other
# entry of .bot_modules is the user's, and is never modified, replaced or
# deleted. (The compiler cannot name .botlish: a namespace segment is an
# identifier.)
#
#   {"state": 1, "packages": {NAME: NODE, ...}}
#   NODE := {"kind": "artifact", "version": V, "sha256": D,
#            "files": {PATH: {"size": N, "crc32": "HHHHHHHH"}, ...},
#            "dependencies": {NAME: NODE, ...}}
#         | {"kind": "editable", "directory": RELATIVE-PATH, "version": V}
#
# An artifact node's files are exactly the artifact's (its botlish.json
# among them), with the sizes and CRC-32s the archive's own validation
# established; its dependencies are the instances installed under its own
# .bot_modules. The record detects changes to installed files (Changes);
# the artifacts themselves, when available, are the authority on contents
# (pm::commands' verify compares bytes).
#
# In memory a node is a dict {kind version sha256 files children} or {kind
# version directory}; files a dict PATH -> {SIZE CRC}.
#
# Target views (PACKAGE-MANAGER-MILESTONE-2.md, "Target views") make the
# record schema 2, which adds
#
#   "views": {TARGET: {"derived": D, "files": {PATH: {"size": N, "crc32": C}},
#                      "links": {PATH: ABSOLUTE-DIRECTORY}}}
#
# for each view PROJECT/.bot_modules/.targets/TARGET the manager made: D the
# SHA-256 of what it was derived from (pm/view.tcl's Derived: the record of
# the packages, the target, the consumer's origins and the manual packages
# it links), its files and links relative to the view's directory. A record
# without views was written as schema 1, byte for byte PM-1's.
#
# Shared dependencies (SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md, pm/graph.tcl)
# make the record schema 3, which every operation now writes: the packages
# are the application's one dependency graph, each installed once at
# PROJECT/.bot_modules/NAME, none under another's .bot_modules:
#
#   {"state": 3, "application": [NAME, ...], "packages": {NAME: NODE, ...},
#    "views": {...}}
#   NODE := {"kind": "artifact", "version": V, "sha256": D,
#            "files": {...}, "uses": {NAME: VERSION, ...}}
#         | {"kind": "editable", "directory": RELATIVE-PATH, "version": V,
#            "uses": {NAME: VERSION, ...}}
#
# `application` the project's direct dependencies, `uses` each package's own
# (the versions its botlish.json locks, which are the graph's): together the
# graph PROJECT/.bot_modules/.graph states (pm::graph::OfState). A schema 1
# or 2 record is read as the nested layout of earlier package managers (one
# instance per dependency path, `children`), which an operation replaces by
# the graph's layout. In memory a schema 3 node has `uses` and no children.

namespace eval pm::state {}

proc pm::state::Path {meta} {
    return [file join $meta state.json]
}

proc pm::state::empty {} {
    return [dict create]
}

# The record's packages (dict NAME -> NODE) of the metadata directory META;
# empty when there is none.
proc pm::state::read {meta} {
    return [dict get [readAll $meta] packages]
}

# The record's views (TARGET -> {derived D files {PATH {SIZE CRC}} links
# {PATH DIR}}).
proc pm::state::views {meta} {
    return [dict get [readAll $meta] views]
}

# The record's application dependencies (schema 3), and its layout: graph
# (schema 3), nested (an earlier package manager's schema 1 or 2) or none
# (no record).
proc pm::state::application {meta} {
    return [dict get [readAll $meta] application]
}

proc pm::state::layout {meta} {
    return [dict get [readAll $meta] layout]
}

proc pm::state::readAll {meta} {
    set path [Path $meta]
    if {![pm::Exists $path]} {
        return [dict create packages [empty] views [dict create] application {} layout none]
    }
    if {[file type $path] ne "file"} {
        pm::Fail STATE "the installation record $path is not a regular file"
    }
    if {[catch {
        set value [pm::json::decode [pm::ReadBytes $path] -limit [expr {64 * 1024 * 1024}]]
        set members [Object $value record]
        set views [dict create]
        set application {}
        set layout nested
        if {[dict keys $members] eq {state packages} && [dict get $members state] eq {num 1}} {
        } elseif {[dict keys $members] eq {state packages views} && [dict get $members state] eq {num 2}} {
            set views [Views [dict get $members views]]
        } elseif {[dict keys $members] eq {state application packages views} && [dict get $members state] eq {num 3}} {
            set views [Views [dict get $members views]]
            set layout graph
            set list [dict get $members application]
            if {[pm::json::type $list] ne "arr"} {
                error "the application's dependencies are not a list"
            }
            foreach item [pm::json::payload $list] {
                if {[pm::json::type $item] ne "str" || [pm::descriptor::NameProblem [pm::json::payload $item]] ne ""} {
                    error "the application's dependency \"[pm::json::payload $item]\""
                }
                lappend application [pm::json::payload $item]
            }
        } else {
            error "not a schema 1, 2 or 3 installation record"
        }
        set packages [Nodes [dict get $members packages] $layout]
        if {$layout eq "graph"} {
            foreach name $application {
                if {![dict exists $packages $name]} {
                    error "the application's dependency $name is no package of the record"
                }
            }
            dict for {name node} $packages {
                foreach dep [dict keys [dict get $node uses]] {
                    if {![dict exists $packages $dep]} {
                        error "$name uses $dep, which is no package of the record"
                    }
                }
            }
        }
    } message]} {
        pm::Fail STATE "the installation record $path is damaged ($message): the package manager cannot tell its packages from yours. Move .bot_modules aside and run install again"
    }
    return [dict create packages $packages views $views application $application layout $layout]
}

proc pm::state::Views {value} {
    set views [dict create]
    foreach {target item} [Object $value views] {
        if {![pm::target::isTarget $target]} {
            error "the view target \"$target\""
        }
        set members [Object $item $target]
        if {[lsort [dict keys $members]] ne {derived files links}} {
            error "$target: unexpected view keys"
        }
        set derived [String $members derived]
        if {![regexp {^[0-9a-f]{64}$} $derived]} {
            error "$target: the view's digest"
        }
        set files [Files [dict get $members files] $target]
        set links [dict create]
        foreach {path dir} [Object [dict get $members links] links] {
            if {[pm::json::type $dir] ne "str" || [ViewPathProblem $path] ne ""} {
                error "$target: the link \"$path\""
            }
            dict set links $path [pm::json::payload $dir]
        }
        dict set views $target [dict create derived $derived files $files links $links]
    }
    return $views
}

# "" when PATH is a path inside a view: an archive path, or one under its
# .lib or a package's .bot_modules, or its package graph .graph.
proc pm::state::ViewPathProblem {path} {
    if {$path eq ".graph"} {
        return ""
    }
    return [pm::archive::pathProblem [string map {.bot_modules/ bot_modules/ .lib/ lib/} $path]]
}

proc pm::state::Files {value what} {
    set files [dict create]
    foreach {path entry} [Object $value files] {
        if {[ViewPathProblem $path] ne ""} {
            error "$what: the file path \"$path\""
        }
        set entry [Object $entry $path]
        set size [dict get $entry size]
        if {[lsort [dict keys $entry]] ne {crc32 size} || [pm::json::type $size] ne "num"
                || ![regexp {^[0-9]+$} [pm::json::payload $size]]
                || ![regexp {^[0-9a-f]{8}$} [String $entry crc32]]} {
            error "$what: the file entry \"$path\""
        }
        dict set files $path [list [pm::json::payload $size] [String $entry crc32]]
    }
    return $files
}

proc pm::state::Object {value what} {
    if {[pm::json::type $value] ne "obj"} {
        error "$what is not an object"
    }
    return [pm::json::payload $value]
}

proc pm::state::String {members key} {
    if {![dict exists $members $key] || [pm::json::type [dict get $members $key]] ne "str"} {
        error "\"$key\" is missing or not a string"
    }
    return [pm::json::payload [dict get $members $key]]
}

# The nodes of the record's `packages` VALUE, in the LAYOUT of its schema:
# graph (flat, each with the versions it uses) or nested.
proc pm::state::Nodes {value {layout nested}} {
    set nodes [dict create]
    foreach {name item} [Object $value packages] {
        if {[pm::descriptor::NameProblem $name] ne ""} {
            error "the package name \"$name\""
        }
        set members [Object $item $name]
        set kind [String $members kind]
        switch -- $kind {
            artifact {
                set expected [expr {$layout eq "graph" ? {files kind sha256 uses version} : {dependencies files kind sha256 version}}]
                if {[lsort [dict keys $members]] ne $expected} {
                    error "$name: unexpected keys"
                }
                set files [dict create]
                foreach {path entry} [Object [dict get $members files] files] {
                    if {[pm::archive::pathProblem $path] ne ""} {
                        error "$name: the file path \"$path\""
                    }
                    set entry [Object $entry $path]
                    set size [dict get $entry size]
                    if {[lsort [dict keys $entry]] ne {crc32 size} || [pm::json::type $size] ne "num"
                            || ![regexp {^[0-9]+$} [pm::json::payload $size]]
                            || ![regexp {^[0-9a-f]{8}$} [String $entry crc32]]} {
                        error "$name: the file entry \"$path\""
                    }
                    dict set files $path [list [pm::json::payload $size] [String $entry crc32]]
                }
                set version [String $members version]
                set digest [String $members sha256]
                if {![pm::version::isVersion $version] || ![regexp {^[0-9a-f]{64}$} $digest]} {
                    error "$name: the version or digest"
                }
                if {$layout eq "graph"} {
                    dict set nodes $name [dict create kind artifact version $version sha256 $digest \
                        files $files children {} uses [Uses [dict get $members uses] $name]]
                } else {
                    dict set nodes $name [dict create kind artifact version $version sha256 $digest \
                        files $files children [Nodes [dict get $members dependencies]]]
                }
            }
            editable {
                set expected [expr {$layout eq "graph" ? {directory kind uses version} : {directory kind version}}]
                if {[lsort [dict keys $members]] ne $expected} {
                    error "$name: unexpected keys"
                }
                dict set nodes $name [dict create kind editable version [String $members version] \
                    directory [String $members directory]]
                if {$layout eq "graph"} {
                    dict set nodes $name uses [Uses [dict get $members uses] $name]
                }
            }
            default {
                error "$name: unknown kind \"$kind\""
            }
        }
    }
    return $nodes
}

# A graph node's `uses` VALUE (NAME -> exact version) of the package NAME.
proc pm::state::Uses {value name} {
    set uses [dict create]
    foreach {dep version} [Object $value "$name's uses"] {
        if {[pm::descriptor::NameProblem $dep] ne "" || [pm::json::type $version] ne "str"
                || ![pm::version::isVersion [pm::json::payload $version]] || $dep eq $name} {
            error "$name: the dependency \"$dep\""
        }
        dict set uses $dep [pm::json::payload $version]
    }
    return $uses
}

# The JSON value of NODES (graph nodes with their `uses`; nested ones with
# their dependencies' nodes).
proc pm::state::Value {nodes} {
    set object {}
    foreach name [lsort [dict keys $nodes]] {
        set node [dict get $nodes $name]
        set uses {}
        if {[dict exists $node uses]} {
            foreach dep [lsort [dict keys [dict get $node uses]]] {
                lappend uses $dep [list str [dict get $node uses $dep]]
            }
        }
        if {[dict get $node kind] eq "editable"} {
            set members [list kind {str editable} \
                directory [list str [dict get $node directory]] version [list str [dict get $node version]]]
            if {[dict exists $node uses]} {
                lappend members uses [list obj $uses]
            }
            lappend object $name [list obj $members]
            continue
        }
        set files {}
        foreach path [lsort [dict keys [dict get $node files]]] {
            lassign [dict get $node files $path] size crc
            lappend files $path [list obj [list size [list num $size] crc32 [list str $crc]]]
        }
        set members [list kind {str artifact} version [list str [dict get $node version]] \
            sha256 [list str [dict get $node sha256]] files [list obj $files]]
        if {[dict exists $node uses]} {
            lappend members uses [list obj $uses]
        } else {
            lappend members dependencies [Value [dict get $node children]]
        }
        lappend object $name [list obj $members]
    }
    return [list obj $object]
}

# The record's bytes: the graph's packages NODES (each with its `uses`), the
# views VIEWS and the application's dependencies APPLICATION, schema 3.
proc pm::state::encode {nodes {views ""} {application {}}} {
    set object {}
    foreach target [lsort [dict keys $views]] {
        set view [dict get $views $target]
        set files {}
        foreach path [lsort [dict keys [dict get $view files]]] {
            lassign [dict get $view files $path] size crc
            lappend files $path [list obj [list size [list num $size] crc32 [list str $crc]]]
        }
        set links {}
        foreach path [lsort [dict keys [dict get $view links]]] {
            lappend links $path [list str [dict get $view links $path]]
        }
        lappend object $target [list obj [list derived [list str [dict get $view derived]] \
            files [list obj $files] links [list obj $links]]]
    }
    set list [lmap name [lsort $application] {list str $name}]
    return [pm::json::encode [list obj [list state {num 3} application [list arr $list] \
        packages [Value $nodes] views [list obj $object]]]]
}

# How the view directory DIR differs from its record VIEW: a list of
# descriptions naming paths relative to SHOWN (empty when it is exactly
# what the record says). Links are compared by their targets; nothing is
# followed.
proc pm::state::ViewChanges {dir view shown} {
    if {![pm::Exists $dir]} {
        return [list "$shown is missing"]
    }
    if {[file type $dir] ne "directory"} {
        return [list "$shown should be a directory, and is a [file type $dir]"]
    }
    set files [dict get $view files]
    set links [dict get $view links]
    set dirs [dict create]
    foreach path [concat [dict keys $files] [dict keys $links]] {
        set prefix ""
        foreach part [lrange [split $path /] 0 end-1] {
            append prefix $part
            dict set dirs $prefix 1
            append prefix /
        }
    }
    set changes {}
    ViewWalk $dir "" $files $links $dirs $shown changes
    foreach path [concat [dict keys $files] [dict keys $links]] {
        if {![pm::Exists [file join $dir {*}[split $path /]]]} {
            lappend changes "$shown/$path is missing"
        }
    }
    return $changes
}

proc pm::state::ViewWalk {dir relative files links dirs shown changesVar} {
    upvar 1 $changesVar changes
    set here [file join $dir {*}[split $relative /]]
    foreach name [Entries $here] {
        set path [expr {$relative eq "" ? $name : "$relative/$name"}]
        set full [file join $here $name]
        set type [file type $full]
        if {[dict exists $links $path]} {
            if {$type ne "link" || [file normalize [file join $here [file readlink $full]]] ne [dict get $links $path]} {
                lappend changes "$shown/$path should be a link to [dict get $links $path]"
            }
            continue
        }
        if {$type eq "directory" && [dict exists $dirs $path]} {
            ViewWalk $dir $path $files $links $dirs $shown changes
            continue
        }
        if {$type eq "file" && [dict exists $files $path]} {
            lassign [dict get $files $path] size crc
            if {[file size $full] != $size
                    || [format %08x [expr {[zlib crc32 [pm::ReadBytes $full]] & 0xffffffff}]] ne $crc} {
                lappend changes "$shown/$path was changed"
            }
            continue
        }
        lappend changes "$shown/$path ($type) is not part of the view"
    }
}

# The record of an artifact node made from the validated archive FILES
# (dict PATH -> BYTES), its VERSION, DIGEST and CHILDREN.
proc pm::state::ArtifactNode {version digest files children} {
    set record [dict create]
    dict for {path bytes} $files {
        dict set record $path [list [string length $bytes] [format %08x [expr {[zlib crc32 $bytes] & 0xffffffff}]]]
    }
    return [dict create kind artifact version $version sha256 $digest files $record children $children]
}

# Every entry of the directory DIR (hidden ones included), as names.
proc pm::state::Entries {dir} {
    set names {}
    foreach path [concat [glob -nocomplain -directory $dir *] [glob -nocomplain -directory $dir -types hidden *]] {
        set name [file tail $path]
        if {$name in {. ..}} continue
        lappend names $name
    }
    return [lsort -unique $names]
}

# How the installed tree DIR differs from NODE: a list of descriptions,
# each naming a path relative to SHOWN (empty when it is exactly what the
# record says); without RECURSE, its dependencies' trees are left to the
# caller (only their presence is checked). Only the entry types are read (links are never followed);
# a file's bytes are read to compare its CRC-32.
proc pm::state::Changes {dir node shown {recurse 1}} {
    set changes {}
    if {![pm::Exists $dir]} {
        return [list "$shown is missing"]
    }
    if {[dict get $node kind] eq "editable"} {
        if {[file type $dir] ne "link"} {
            return [list "$shown should be a link to the editable directory [dict get $node directory], and is a [file type $dir]"]
        }
        return {}
    }
    if {[file type $dir] ne "directory"} {
        return [list "$shown should be a directory, and is a [file type $dir]"]
    }
    set files [dict get $node files]
    set children [dict get $node children]
    # Directories the record's paths imply.
    set dirs [dict create]
    foreach path [dict keys $files] {
        set prefix ""
        foreach part [lrange [split $path /] 0 end-1] {
            append prefix $part
            dict set dirs $prefix 1
            append prefix /
        }
    }
    Walk $dir "" $files $dirs [expr {$children ne ""}] $shown changes
    dict for {path -} $files {
        if {![pm::Exists [file join $dir {*}[split $path /]]]} {
            lappend changes "$shown/$path is missing"
        }
    }
    if {$children ne ""} {
        set modules [file join $dir .bot_modules]
        if {![pm::Exists $modules] || [file type $modules] ne "directory"} {
            lappend changes "$shown/.bot_modules is missing or not a directory"
        } else {
            foreach name [Entries $modules] {
                if {![dict exists $children $name]} {
                    lappend changes "$shown/.bot_modules/$name is not part of the installation"
                }
            }
            dict for {name child} $children {
                if {$recurse} {
                    lappend changes {*}[Changes [file join $modules $name] $child $shown/.bot_modules/$name]
                } elseif {![pm::Exists [file join $modules $name]]} {
                    lappend changes "$shown/.bot_modules/$name is missing"
                }
            }
        }
    }
    return $changes
}

proc pm::state::Walk {dir relative files dirs hasModules shown changesVar} {
    upvar 1 $changesVar changes
    set here [file join $dir {*}[split $relative /]]
    foreach name [Entries $here] {
        if {$relative eq ""} {
            set path $name
        } else {
            set path $relative/$name
        }
        if {$relative eq "" && $name eq ".bot_modules" && $hasModules} continue
        set full [file join $here $name]
        set type [file type $full]
        if {$type eq "directory" && [dict exists $dirs $path]} {
            Walk $dir $path $files $dirs $hasModules $shown changes
            continue
        }
        if {$type eq "file" && [dict exists $files $path]} {
            lassign [dict get $files $path] size crc
            if {[file size $full] != $size} {
                lappend changes "$shown/$path was changed (size [file size $full], installed $size)"
            } elseif {[format %08x [expr {[zlib crc32 [pm::ReadBytes $full]] & 0xffffffff}]] ne $crc} {
                lappend changes "$shown/$path was changed"
            }
            continue
        }
        if {[dict exists $files $path]} {
            lappend changes "$shown/$path is a $type where the installation has a file"
        } elseif {[dict exists $dirs $path]} {
            lappend changes "$shown/$path is a $type where the installation has a directory"
        } else {
            lappend changes "$shown/$path ($type) is not part of the installation"
        }
    }
}

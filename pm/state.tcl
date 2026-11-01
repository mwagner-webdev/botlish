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
    set path [Path $meta]
    if {![pm::Exists $path]} {
        return [empty]
    }
    if {[file type $path] ne "file"} {
        pm::Fail STATE "the installation record $path is not a regular file"
    }
    if {[catch {
        set value [pm::json::decode [pm::ReadBytes $path] -limit [expr {64 * 1024 * 1024}]]
        set members [Object $value record]
        if {[dict keys $members] ne {state packages} || [dict get $members state] ne {num 1}} {
            error "not a schema 1 installation record"
        }
        set packages [Nodes [dict get $members packages]]
    } message]} {
        pm::Fail STATE "the installation record $path is damaged ($message): the package manager cannot tell its packages from yours. Move .bot_modules aside and run install again"
    }
    return $packages
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

proc pm::state::Nodes {value} {
    set nodes [dict create]
    foreach {name item} [Object $value packages] {
        if {[pm::descriptor::NameProblem $name] ne ""} {
            error "the package name \"$name\""
        }
        set members [Object $item $name]
        set kind [String $members kind]
        switch -- $kind {
            artifact {
                if {[lsort [dict keys $members]] ne {dependencies files kind sha256 version}} {
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
                dict set nodes $name [dict create kind artifact version $version sha256 $digest \
                    files $files children [Nodes [dict get $members dependencies]]]
            }
            editable {
                if {[lsort [dict keys $members]] ne {directory kind version}} {
                    error "$name: unexpected keys"
                }
                dict set nodes $name [dict create kind editable version [String $members version] \
                    directory [String $members directory]]
            }
            default {
                error "$name: unknown kind \"$kind\""
            }
        }
    }
    return $nodes
}

# The JSON value of NODES.
proc pm::state::Value {nodes} {
    set object {}
    foreach name [lsort [dict keys $nodes]] {
        set node [dict get $nodes $name]
        if {[dict get $node kind] eq "editable"} {
            lappend object $name [list obj [list kind {str editable} \
                directory [list str [dict get $node directory]] version [list str [dict get $node version]]]]
            continue
        }
        set files {}
        foreach path [lsort [dict keys [dict get $node files]]] {
            lassign [dict get $node files $path] size crc
            lappend files $path [list obj [list size [list num $size] crc32 [list str $crc]]]
        }
        lappend object $name [list obj [list kind {str artifact} version [list str [dict get $node version]] \
            sha256 [list str [dict get $node sha256]] files [list obj $files] \
            dependencies [Value [dict get $node children]]]]
    }
    return [list obj $object]
}

proc pm::state::encode {nodes} {
    return [pm::json::encode [list obj [list state {num 1} packages [Value $nodes]]]]
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

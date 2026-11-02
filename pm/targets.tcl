# targets.tcl -- a package's targets: schema 2's `targets` (BOTLISH-JSON.md
# section 12, PACKAGE-MANAGER-MILESTONE-2.md "Metadata").
#
#   pm::targets::Parse VALUE PROBLEMSVAR   the targets dict of a JSON value
#   pm::targets::Value TARGETS             its canonical JSON value
#   pm::targets::Map DESCRIPTOR TARGET PATHS   how a package's files appear
#                                         in TARGET's view: {VIEWPATH PATH ...}
#   pm::targets::CheckFiles DESCRIPTOR PATHS LABEL   every structural rule an
#                                         artifact's file list must meet
#
# A target-aware package (one whose botlish.json has `targets`) supports
# exactly the targets it names, each a compiler target name. For each:
#
#   files        an artifact directory whose contents appear, in that
#                target's view, at the package root: targets/T/sdl3/video.bot
#                is sdl3/video.bot (the module sdl3::video) when compiling
#                for T. Every file outside every target's directory is
#                common: it appears as it is, for every target.
#   libraries    the native libraries the package's link declarations need,
#                where they come from (bundled with the package, or system)
#                and how they link (static or shared), with the facts the
#                package manager checks against the binary or the system.
#   frameworks   Apple frameworks (system-provided) the package links.
#   headers      view directories holding public C headers, for consumers'
#                own C code.
#
# A package without `targets` is target-independent: every file appears as
# it is, for every target (a schema 1 package, a pure-Botlish one).

namespace eval pm::targets {
    variable targetKeys {files libraries frameworks headers}
    variable libraryKeys {name origin linkage file import identity needs version pkg-config symbols}
}

# "" when NAME is a native library name (what `extern c library "NAME"`
# accepts: nir::is_link_name, letters, digits and _ + . -, not starting
# with -), else why not.
proc pm::targets::LibraryNameProblem {name} {
    if {![regexp {^[A-Za-z0-9_+.][A-Za-z0-9_+.-]{0,127}$} $name]} {
        return "\"$name\" is not a native library name (letters, digits and _ + . -, not starting with -, as in extern c library \"NAME\")"
    }
    return ""
}

proc pm::targets::Strings {value what problemsVar} {
    upvar 1 $problemsVar problems
    if {[pm::json::type $value] ne "arr"} {
        lappend problems "$what must be an array of strings"
        return {}
    }
    set out {}
    foreach item [pm::json::payload $value] {
        if {[pm::json::type $item] ne "str"} {
            lappend problems "$what must be an array of strings"
            return {}
        }
        lappend out [pm::json::payload $item]
    }
    if {[llength [lsort -unique $out]] != [llength $out]} {
        lappend problems "$what names an entry twice"
    }
    return $out
}

proc pm::targets::Parse {value problemsVar} {
    upvar 1 $problemsVar problems
    variable targetKeys
    variable libraryKeys
    set result [dict create]
    if {[pm::json::type $value] ne "obj"} {
        lappend problems "\"targets\" must be an object of target names"
        return $result
    }
    if {[pm::json::payload $value] eq ""} {
        lappend problems "\"targets\" names no target: a target-independent package leaves it out"
    }
    foreach {target spec} [pm::json::payload $value] {
        set where "targets: \"$target\""
        if {![pm::target::isTarget $target]} {
            lappend problems "$where is not a compilation target (the compiler's targets: [join [pm::target::names] {, }])"
            continue
        }
        if {[pm::json::type $spec] ne "obj"} {
            lappend problems "$where must be an object"
            continue
        }
        set members [pm::json::payload $spec]
        set entry [dict create files "" libraries {} frameworks {} headers {}]
        foreach {key item} $members {
            if {$key ni $targetKeys} {
                lappend problems "$where: unknown key \"$key\" (a target has [join $targetKeys {, }])"
                continue
            }
            switch -- $key {
                files {
                    if {[pm::json::type $item] ne "str"} {
                        lappend problems "$where: \"files\" must be a directory path"
                    } elseif {[set problem [pm::archive::pathProblem [pm::json::payload $item]]] ne ""} {
                        lappend problems "$where: \"files\": $problem"
                    } elseif {[pm::json::payload $item] eq "botlish.json"} {
                        lappend problems "$where: \"files\" names botlish.json, which is no directory"
                    } else {
                        dict set entry files [pm::json::payload $item]
                    }
                }
                frameworks {
                    set names [Strings $item "$where: \"frameworks\"" problems]
                    if {$names ne "" && ![dict get [pm::target::facts $target] frameworks]} {
                        lappend problems "$where: \"frameworks\": $target has no frameworks (an Apple platform's linker mechanism)"
                    }
                    foreach name $names {
                        if {[set problem [LibraryNameProblem $name]] ne ""} {
                            lappend problems "$where: frameworks: [string map {library framework} $problem]"
                        }
                    }
                    dict set entry frameworks $names
                }
                headers {
                    set dirs [Strings $item "$where: \"headers\"" problems]
                    foreach dir $dirs {
                        if {[set problem [pm::archive::pathProblem $dir]] ne ""} {
                            lappend problems "$where: headers: $problem"
                        }
                    }
                    dict set entry headers $dirs
                }
                libraries {
                    if {[pm::json::type $item] ne "arr"} {
                        lappend problems "$where: \"libraries\" must be an array of library objects"
                        continue
                    }
                    set libraries {}
                    foreach library [pm::json::payload $item] {
                        set parsed [Library $target $library "$where: libraries" problems]
                        if {$parsed ne ""} {
                            lappend libraries $parsed
                        }
                    }
                    # One library has at most one entry per origin: the
                    # alternatives a consumer chooses between (origins).
                    set seen [dict create]
                    foreach library $libraries {
                        set key [list [dict get $library name] [dict get $library origin]]
                        if {[dict exists $seen $key]} {
                            lappend problems "$where: libraries: \"[dict get $library name]\" has two [dict get $library origin] entries"
                        }
                        dict set seen $key 1
                    }
                    dict set entry libraries $libraries
                }
            }
        }
        dict set result $target $entry
    }
    return $result
}

# One library object of target TARGET, or "" with its problems appended.
proc pm::targets::Library {target value where problemsVar} {
    upvar 1 $problemsVar problems
    variable libraryKeys
    if {[pm::json::type $value] ne "obj"} {
        lappend problems "$where: an entry must be an object"
        return ""
    }
    set members [pm::json::payload $value]
    set library [dict create name "" origin "" linkage "" file "" import "" identity "" needs {} version "" pkg-config "" symbols {}]
    set count [llength $problems]
    foreach {key item} $members {
        if {$key ni $libraryKeys} {
            lappend problems "$where: unknown key \"$key\" (a library has [join $libraryKeys {, }])"
            continue
        }
        if {$key in {needs symbols}} {
            dict set library $key [Strings $item "$where: \"$key\"" problems]
            continue
        }
        if {[pm::json::type $item] ne "str"} {
            lappend problems "$where: \"$key\" must be a string"
            continue
        }
        dict set library $key [pm::json::payload $item]
    }
    set name [dict get $library name]
    if {$name eq ""} {
        lappend problems "$where: an entry without a \"name\""
        return ""
    }
    set where "$where: \"$name\""
    if {[set problem [LibraryNameProblem $name]] ne ""} {
        lappend problems "$where: $problem"
    }
    set origin [dict get $library origin]
    set linkage [dict get $library linkage]
    if {$origin ni {bundled system}} {
        lappend problems "$where: \"origin\" must be \"bundled\" (a file of the package) or \"system\" (the target's own installation)"
    }
    if {$linkage ni {static shared}} {
        lappend problems "$where: \"linkage\" must be \"static\" or \"shared\""
    }
    set windows [expr {[dict get [pm::target::facts $target] os] eq "windows"}]
    foreach key {file import} {
        set path [dict get $library $key]
        if {$path ne "" && [set problem [pm::archive::pathProblem $path]] ne ""} {
            lappend problems "$where: \"$key\": $problem"
        }
    }
    foreach text [concat [list [dict get $library identity]] [dict get $library needs]] {
        if {$text ne "" && (![regexp {^[A-Za-z0-9_@/.+-]+$} $text] || [string length $text] > 1024)} {
            lappend problems "$where: \"$text\" is not a loader identity (a file name, or on macOS an install name)"
        }
    }
    foreach symbol [dict get $library symbols] {
        if {![regexp {^[A-Za-z_][A-Za-z0-9_$.@]{0,255}$} $symbol]} {
            lappend problems "$where: \"$symbol\" is not a C symbol name"
        }
    }
    if {[dict get $library version] ne "" && [set problem [pm::version::RequestProblem [dict get $library version]]] ne ""} {
        lappend problems "$where: \"version\": $problem"
    }
    if {[dict get $library pkg-config] ne "" && ![regexp {^[A-Za-z0-9_.+-]{1,128}$} [dict get $library pkg-config]]} {
        lappend problems "$where: \"pkg-config\" is not a pkg-config module name"
    }
    if {$origin eq "bundled"} {
        if {[dict get $library file] eq ""} {
            lappend problems "$where: a bundled library names its \"file\" (a path in the target's view)"
        }
        foreach key {version pkg-config} {
            if {[dict get $library $key] ne ""} {
                lappend problems "$where: \"$key\" describes a system library; a bundled one is its file"
            }
        }
        if {$linkage eq "shared"} {
            if {[dict get $library identity] eq ""} {
                lappend problems "$where: a bundled shared library states its loader \"identity\" (its soname, install name or DLL name)"
            }
            if {![dict exists $members needs]} {
                lappend problems "$where: a bundled shared library states what it \"needs\" (its loader dependencies, \[\] for none)"
            }
            if {$windows && [dict get $library import] eq ""} {
                lappend problems "$where: a bundled Windows DLL names its \"import\" library (what the linker links)"
            }
        }
        if {!($linkage eq "shared" && $windows) && [dict get $library import] ne ""} {
            lappend problems "$where: \"import\" names a Windows DLL's import library"
        }
        if {$linkage eq "static" && ([dict get $library identity] ne "" || [dict get $library needs] ne "")} {
            lappend problems "$where: a static library has no loader \"identity\" or \"needs\""
        }
    } elseif {$origin eq "system"} {
        foreach key {file import} {
            if {[dict get $library $key] ne ""} {
                lappend problems "$where: \"$key\" names a bundled file; a system library is the target's own"
            }
        }
        if {[dict get $library needs] ne ""} {
            lappend problems "$where: \"needs\" describes a bundled shared library"
        }
    }
    if {[llength $problems] > $count} {
        return ""
    }
    return $library
}

# The canonical JSON value of TARGETS.
proc pm::targets::Value {targets} {
    variable libraryKeys
    set object {}
    foreach target [lsort [dict keys $targets]] {
        set entry [dict get $targets $target]
        set members {}
        if {[dict get $entry files] ne ""} {
            lappend members files [list str [dict get $entry files]]
        }
        if {[dict get $entry libraries] ne ""} {
            set libraries {}
            foreach library [dict get $entry libraries] {
                set fields {}
                foreach key $libraryKeys {
                    set v [dict get $library $key]
                    if {$key in {needs symbols}} {
                        if {$key eq "needs" && [dict get $library origin] eq "bundled" && [dict get $library linkage] eq "shared"} {
                            lappend fields $key [list arr [lmap x $v {list str $x}]]
                        } elseif {$v ne ""} {
                            lappend fields $key [list arr [lmap x $v {list str $x}]]
                        }
                    } elseif {$v ne ""} {
                        lappend fields $key [list str $v]
                    }
                }
                lappend libraries [list obj $fields]
            }
            lappend members libraries [list arr $libraries]
        }
        foreach key {frameworks headers} {
            if {[dict get $entry $key] ne ""} {
                lappend members $key [list arr [lmap x [dict get $entry $key] {list str $x}]]
            }
        }
        lappend object $target [list obj $members]
    }
    return [list obj $object]
}

# The target directories of DESCRIPTOR (TARGET -> DIR, only targets with
# files).
proc pm::targets::Dirs {descriptor} {
    set dirs [dict create]
    dict for {target entry} [dict getdef $descriptor targets {}] {
        if {[dict get $entry files] ne ""} {
            dict set dirs $target [dict get $entry files]
        }
    }
    return $dirs
}

# 1 if PATH is DIR or under it.
proc pm::targets::Under {path dir} {
    return [expr {$path eq $dir || [string first $dir/ $path] == 0}]
}

# The view of a package's files PATHS for TARGET: a list {VIEWPATH PATH
# ...} in PATHS' order -- every common file as it is, every file of
# TARGET's directory without that prefix; nothing of another target's
# directory. A target-independent package's view is its files as they are.
proc pm::targets::Map {descriptor target paths} {
    set dirs [Dirs $descriptor]
    set own [dict getdef $dirs $target ""]
    set out {}
    foreach path $paths {
        set common 1
        dict for {- dir} $dirs {
            if {[Under $path $dir]} {
                set common 0
                break
            }
        }
        if {$common} {
            lappend out $path $path
        } elseif {$own ne "" && [string first $own/ $path] == 0} {
            lappend out [string range $path [string length $own/] end] $path
        }
    }
    return $out
}

# The problems of an artifact's (or a package directory's) file list PATHS
# against its DESCRIPTOR's targets: each target's directory holds files and
# lies inside no other's, and in each target's view no file collides with
# another (ignoring case, or as a file and a directory), every library's
# file and import library and every header directory exists, and no target
# file replaces botlish.json. A list of problems, each naming the target.
proc pm::targets::Problems {descriptor paths} {
    set problems {}
    set dirs [Dirs $descriptor]
    dict for {target dir} $dirs {
        dict for {other otherDir} $dirs {
            if {$other ne $target && $dir ne $otherDir && ([Under $dir $otherDir] || [Under $otherDir $dir])} {
                lappend problems "targets: the directories of $target ($dir) and $other ($otherDir) are nested"
            }
        }
        if {[lsearch -glob $paths $dir/*] < 0} {
            lappend problems "targets: \"$target\": its directory $dir holds no file"
        }
    }
    dict for {target entry} [dict getdef $descriptor targets {}] {
        set view [Map $descriptor $target $paths]
        set viewPaths [dict keys $view]
        if {[llength $viewPaths] != [llength $view] / 2} {
            # Two files of one view at one path.
            set seen [dict create]
            foreach {viewPath path} $view {
                if {[dict exists $seen $viewPath]} {
                    lappend problems "targets: \"$target\": $path and [dict get $seen $viewPath] are both $viewPath in its view (a target's file never replaces a common one)"
                }
                dict set seen $viewPath $path
            }
        }
        if {[dict exists $view botlish.json] && [dict get $view botlish.json] ne "botlish.json"} {
            lappend problems "targets: \"$target\": [dict get $view botlish.json] would replace the package's botlish.json in its view"
        }
        set problem [pm::archive::CollisionProblem [lsort -unique $viewPaths]]
        if {$problem ne ""} {
            lappend problems "targets: \"$target\": in its view, $problem"
        }
        foreach library [dict get $entry libraries] {
            foreach key {file import} {
                set path [dict get $library $key]
                if {$path ne "" && ![dict exists $view $path]} {
                    lappend problems "targets: \"$target\": library \"[dict get $library name]\": its $key $path is no file of the target's view"
                }
            }
        }
        foreach dir [dict get $entry headers] {
            if {[lsearch -glob $viewPaths $dir/*] < 0} {
                lappend problems "targets: \"$target\": the header directory $dir holds no file in the target's view"
            }
        }
    }
    return $problems
}

# Raises {PM TARGETS} for the problems of the file list PATHS (Problems).
proc pm::targets::CheckFiles {descriptor paths label} {
    set problems [Problems $descriptor $paths]
    if {$problems ne ""} {
        pm::Fail TARGETS "$label:\n  [join $problems "\n  "]"
    }
}

# The targets DESCRIPTOR supports: its targets, or every target ("*") when
# it is target-independent.
proc pm::targets::Supported {descriptor} {
    if {[dict getdef $descriptor targets {}] eq ""} {
        return *
    }
    return [lsort [dict keys [dict get $descriptor targets]]]
}

proc pm::targets::Aware {descriptor} {
    return [expr {[dict getdef $descriptor targets {}] ne ""}]
}

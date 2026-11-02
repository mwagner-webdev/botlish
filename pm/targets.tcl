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
    # Schema 2's keys; schema 3 (PACKAGE-MANAGER-MILESTONE-3.md, BOTLISH-JSON.md
    # section 13) adds a target's `runtime` and a library's `license` and
    # `notices`, and nothing else.
    variable targetKeys {files libraries frameworks headers}
    variable libraryKeys {name origin linkage file import identity needs version pkg-config symbols}
    variable targetKeys3 {files libraries frameworks headers runtime}
    variable libraryKeys3 {name origin linkage file import identity needs version pkg-config symbols license notices}
    variable runtimeKeys {name kind identity loaded-by requirement capability purpose}
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

proc pm::targets::Parse {value problemsVar {schema 2}} {
    upvar 1 $problemsVar problems
    variable targetKeys
    variable targetKeys3
    set allowed [expr {$schema >= 3 ? $targetKeys3 : $targetKeys}]
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
        if {$schema >= 3} {
            dict set entry runtime {}
        }
        foreach {key item} $members {
            if {$key ni $allowed} {
                if {$key in $targetKeys3} {
                    lappend problems "$where: \"$key\" is a schema 3 key: a botlish.json using it says \"schema\": 3"
                } else {
                    lappend problems "$where: unknown key \"$key\" (a target has [join $allowed {, }])"
                }
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
                        set parsed [Library $target $library "$where: libraries" problems $schema]
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
                runtime {
                    if {[pm::json::type $item] ne "arr"} {
                        lappend problems "$where: \"runtime\" must be an array of runtime dependency objects"
                        continue
                    }
                    set runtime {}
                    foreach dependency [pm::json::payload $item] {
                        set parsed [Runtime $target $dependency "$where: runtime" problems]
                        if {$parsed ne ""} {
                            lappend runtime $parsed
                        }
                    }
                    set seen [dict create]
                    foreach dependency $runtime {
                        if {[dict exists $seen [dict get $dependency name]]} {
                            lappend problems "$where: runtime: \"[dict get $dependency name]\" is named twice"
                        }
                        dict set seen [dict get $dependency name] 1
                    }
                    dict set entry runtime $runtime
                }
            }
        }
        # Relations a single entry cannot check: a runtime dependency loaded
        # by a library names one of this target's libraries, and is no
        # library the loader loads (those are libraries, `needs`).
        if {[dict exists $entry runtime]} {
            set names [lmap library [dict get $entry libraries] {dict get $library name}]
            set loaded {}
            foreach library [dict get $entry libraries] {
                foreach need [dict get $library needs] {
                    lappend loaded [string tolower $need]
                }
                if {[dict get $library identity] ne ""} {
                    lappend loaded [string tolower [dict get $library identity]]
                }
            }
            foreach dependency [dict get $entry runtime] {
                set by [dict get $dependency loaded-by]
                if {$by ne "" && $by ni $names} {
                    lappend problems "$where: runtime: \"[dict get $dependency name]\": \"loaded-by\" names $by, which is no library of $target"
                }
                if {[dict get $dependency identity] ne "" && [string tolower [dict get $dependency identity]] in $loaded} {
                    lappend problems "$where: runtime: \"[dict get $dependency name]\": [dict get $dependency identity] is a library of $target's link (a declared library or a bundled library's loader dependency): a runtime dependency is one only the program loads"
                }
            }
        }
        dict set result $target $entry
    }
    return $result
}

# One library object of target TARGET, or "" with its problems appended.
proc pm::targets::Library {target value where problemsVar {schema 2}} {
    upvar 1 $problemsVar problems
    variable libraryKeys
    variable libraryKeys3
    set allowed [expr {$schema >= 3 ? $libraryKeys3 : $libraryKeys}]
    if {[pm::json::type $value] ne "obj"} {
        lappend problems "$where: an entry must be an object"
        return ""
    }
    set members [pm::json::payload $value]
    set library [dict create name "" origin "" linkage "" file "" import "" identity "" needs {} version "" pkg-config "" symbols {}]
    if {$schema >= 3} {
        dict set library license ""
        dict set library notices {}
    }
    set count [llength $problems]
    foreach {key item} $members {
        if {$key ni $allowed} {
            if {$key in $libraryKeys3} {
                lappend problems "$where: \"$key\" is a schema 3 key: a botlish.json using it says \"schema\": 3"
            } else {
                lappend problems "$where: unknown key \"$key\" (a library has [join $allowed {, }])"
            }
            continue
        }
        if {$key in {needs symbols notices}} {
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
    if {[dict exists $library license]} {
        if {[dict get $library license] ne "" && [set problem [LicenseProblem [dict get $library license]]] ne ""} {
            lappend problems "$where: \"license\": $problem"
        }
        foreach path [dict get $library notices] {
            if {[set problem [pm::archive::pathProblem $path]] ne ""} {
                lappend problems "$where: \"notices\": $problem"
            }
        }
        if {$origin eq "system" && ([dict get $library license] ne "" || [dict get $library notices] ne "")} {
            lappend problems "$where: \"license\" and \"notices\" describe a bundled library (what a consumer redistributes); a system library is the target's own"
        }
        if {[dict get $library notices] ne "" && [dict get $library license] eq ""} {
            lappend problems "$where: \"notices\" without a \"license\": state the license the notices belong to"
        }
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

# "" when TEXT is a license expression: SPDX's syntax (license identifiers,
# LicenseRef-..., AND, OR, WITH and parentheses), else why not. Its meaning
# is the author's statement: nothing checks it against the library.
proc pm::targets::LicenseProblem {text} {
    if {[string length $text] > 256} {
        return "a license expression longer than 256 characters"
    }
    set tokens [regexp -all -inline {\(|\)|[^\s()]+} $text]
    if {$tokens eq "" || [join $tokens ""] ne [string map {" " ""} $text]} {
        return "\"$text\" is not a license expression (SPDX: MIT, Apache-2.0 AND OFL-1.1, (MIT OR Unlicense), LicenseRef-NAME)"
    }
    set depth 0
    set expect operand
    foreach token $tokens {
        switch -- $token {
            ( {
                if {$expect ne "operand"} { set expect bad; break }
                incr depth
            }
            ) {
                if {$expect ne "operator" || $depth == 0} { set expect bad; break }
                incr depth -1
            }
            AND - OR - WITH {
                if {$expect ne "operator"} { set expect bad; break }
                set expect operand
            }
            default {
                if {$expect ne "operand" || ![regexp {^[A-Za-z0-9][A-Za-z0-9.+-]*$} $token]} { set expect bad; break }
                set expect operator
            }
        }
    }
    if {$expect ne "operator" || $depth != 0} {
        return "\"$text\" is not a license expression (SPDX: MIT, Apache-2.0 AND OFL-1.1, (MIT OR Unlicense), LicenseRef-NAME)"
    }
    return ""
}

# One runtime dependency object of target TARGET (schema 3), or "" with its
# problems appended: something a program of the package loads or uses at
# run time that no loader dependency names -- a library opened by name
# (dlopen, LoadLibrary), or a facility that is no file (a graphics driver,
# a display server). REQUIREMENT says when it is needed:
#
#   always       whenever the package's native code runs
#   capability   only for the named CAPABILITY (a program that does not use
#                it runs without it)
#   optional     used when present, never required
#
# A runtime dependency is never part of the link or the loader's closure,
# and its absence never makes the package uninstallable.
proc pm::targets::Runtime {target value where problemsVar} {
    upvar 1 $problemsVar problems
    variable runtimeKeys
    if {[pm::json::type $value] ne "obj"} {
        lappend problems "$where: an entry must be an object"
        return ""
    }
    set dependency [dict create name "" kind "" identity "" loaded-by "" requirement "" capability "" purpose ""]
    set count [llength $problems]
    foreach {key item} [pm::json::payload $value] {
        if {$key ni $runtimeKeys} {
            lappend problems "$where: unknown key \"$key\" (a runtime dependency has [join $runtimeKeys {, }])"
            continue
        }
        if {[pm::json::type $item] ne "str"} {
            lappend problems "$where: \"$key\" must be a string"
            continue
        }
        dict set dependency $key [pm::json::payload $item]
    }
    set name [dict get $dependency name]
    if {$name eq ""} {
        lappend problems "$where: an entry without a \"name\""
        return ""
    }
    set where "$where: \"$name\""
    if {[set problem [LibraryNameProblem $name]] ne ""} {
        lappend problems "$where: [string map {"native library name" "runtime dependency name"} $problem]"
    }
    set kind [dict get $dependency kind]
    if {$kind ni {library facility}} {
        lappend problems "$where: \"kind\" must be \"library\" (a library opened by name at run time) or \"facility\" (something that is no file: a driver, a display)"
    }
    set identity [dict get $dependency identity]
    if {$kind eq "library" && $identity eq ""} {
        lappend problems "$where: a runtime library states the \"identity\" it is opened by (its soname, install name or DLL name)"
    }
    if {$kind eq "facility" && $identity ne ""} {
        lappend problems "$where: a facility is no file: it has no \"identity\""
    }
    if {$identity ne "" && (![regexp {^[A-Za-z0-9_@/.+-]+$} $identity] || [string length $identity] > 1024)} {
        lappend problems "$where: \"$identity\" is not a loader identity"
    }
    if {[dict get $dependency loaded-by] ne "" && [set problem [LibraryNameProblem [dict get $dependency loaded-by]]] ne ""} {
        lappend problems "$where: \"loaded-by\": $problem"
    }
    set requirement [dict get $dependency requirement]
    if {$requirement ni {always capability optional}} {
        lappend problems "$where: \"requirement\" must be \"always\", \"capability\" (only for the named capability) or \"optional\" (used when present)"
    }
    set capability [dict get $dependency capability]
    if {$requirement eq "capability" && ![regexp {^[a-z][a-z0-9-]{0,63}$} $capability]} {
        lappend problems "$where: a capability requirement names its \"capability\" (lowercase letters, digits and -)"
    }
    if {$requirement ne "capability" && $capability ne ""} {
        lappend problems "$where: \"capability\" belongs to a \"capability\" requirement"
    }
    set purpose [dict get $dependency purpose]
    if {$purpose eq "" || [string length $purpose] > 300 || [regexp {[\x00-\x1f]} $purpose]} {
        lappend problems "$where: \"purpose\" says what needs it, in one line of at most 300 characters"
    }
    if {[llength $problems] > $count} {
        return ""
    }
    return $dependency
}

# The canonical JSON value of a runtime dependency DEPENDENCY.
proc pm::targets::RuntimeValue {dependency} {
    variable runtimeKeys
    set fields {}
    foreach key $runtimeKeys {
        if {[dict get $dependency $key] ne ""} {
            lappend fields $key [list str [dict get $dependency $key]]
        }
    }
    return [list obj $fields]
}

# The canonical JSON value of one library LIBRARY.
proc pm::targets::LibraryValue {library} {
    variable libraryKeys
    variable libraryKeys3
    set fields {}
    foreach key [expr {[dict exists $library license] ? $libraryKeys3 : $libraryKeys}] {
        set v [dict get $library $key]
        if {$key in {needs symbols notices}} {
            if {$key eq "needs" && [dict get $library origin] eq "bundled" && [dict get $library linkage] eq "shared"} {
                lappend fields $key [list arr [lmap x $v {list str $x}]]
            } elseif {$v ne ""} {
                lappend fields $key [list arr [lmap x $v {list str $x}]]
            }
        } elseif {$v ne ""} {
            lappend fields $key [list str $v]
        }
    }
    return [list obj $fields]
}

# The canonical JSON value of TARGETS.
proc pm::targets::Value {targets} {
    variable libraryKeys
    variable libraryKeys3
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
                lappend libraries [LibraryValue $library]
            }
            lappend members libraries [list arr $libraries]
        }
        foreach key {frameworks headers} {
            if {[dict get $entry $key] ne ""} {
                lappend members $key [list arr [lmap x [dict get $entry $key] {list str $x}]]
            }
        }
        if {[dict getdef $entry runtime {}] ne ""} {
            lappend members runtime [list arr [lmap dependency [dict get $entry runtime] {RuntimeValue $dependency}]]
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
        foreach library [dict get $entry libraries] {
            foreach path [dict getdef $library notices {}] {
                if {![dict exists $view $path]} {
                    lappend problems "targets: \"$target\": library \"[dict get $library name]\": its notice $path is no file of the target's view"
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

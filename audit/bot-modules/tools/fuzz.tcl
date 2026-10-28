#!/usr/bin/env tclsh9.0
# fuzz.tcl -- randomized differential check of package-scoped module
# resolution and package-instance identity (BOT-MODULES-MILESTONE-1.md).
#
#   tclsh9.0 audit/bot-modules/tools/fuzz.tcl ?-n N? ?-seed S? ?-backends LIST? ?-dump 1?
#
# Each case is a random application directory: application modules of a
# small pool of names (some nested, NAME/sub.bot), packages of the same names
# installed in its .bot_modules -- some without their root module, some with
# a stray file outside their root namespace -- and packages installed by
# packages, to depth three, so the same name is installed on several
# branches at once (two geometry packages, one of the application's and one
# of a package's); now and then a package installs one of its own name, or a
# scope a package directory named std. Every module file defines `t()`, a
# String: its own unique tag and, in parentheses, the t() of each namespace
# it imports, in order; the entry program is the List of its imports' t().
# Imports are random (a namespace of the pool, NAME::sub, rooted or not), so
# the cases include every outcome: a value, and UNKNOWN-NAMESPACE,
# MODULE-COLLISION, RESERVED-NAMESPACE, CYCLE and SELF-IMPORT.
#
# The oracle is an independent model of the resolution table of the report's
# section B and of the loader's depth-first order -- written from the
# report, not from surface/modules.tcl -- which predicts each case's value (so
# which file every import named: the tags say) or its first diagnostic (kind,
# file and import). A case passes when the compiler's outcome on every
# backend of LIST (default interp and compile) is the oracle's. A failure
# prints the seed that replays it (`-seed S -n 1`, with -dump 1 for the tree).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
# (tests/helpers.tcl configures tcltest from argv: these options are ours.)
set arguments $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

set options [dict create -n 200 -seed 1 -backends {interp compile} -dump 0]
set ::env(BOTLISH_WARNINGS) off
foreach {option value} $arguments {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
interp recursionlimit {} 100000

set pool {geo ui net}

proc chance {p} { expr {rand() < $p} }
proc pick {list} { lindex $list [expr {int(rand() * [llength $list])}] }

# ---------------------------------------------------------------------------
# The tree: FILES, a dict RELATIVE-PATH -> {imports {{NS ROOTED} ...} tag T},
# and DIRS, the package directories (relative), made by GenScope.

# Adds to FILES and DIRS the scope whose directory is DIR (relative, "" for
# the application) and whose root namespace is ROOTNAME ("" for the
# application), DEPTH levels below the application.
proc GenScope {filesVar dirsVar dir rootName depth} {
    upvar 1 $filesVar files $dirsVar dirs
    global pool
    set prefix [expr {$dir eq "" ? "" : "$dir/"}]
    # The scope's own modules.
    if {$rootName eq ""} {
        foreach name $pool {
            if {[chance 0.3]} { dict set files ${prefix}$name.bot {} }
            if {[chance 0.15]} { dict set files ${prefix}$name/sub.bot {} }
        }
    } else {
        if {[chance 0.85]} { dict set files ${prefix}$rootName.bot {} }
        if {[chance 0.5]} { dict set files ${prefix}$rootName/sub.bot {} }
        if {[chance 0.1]} { dict set files ${prefix}[pick $pool].bot {} }
    }
    # Its installed packages.
    if {$depth < 3} {
        foreach name $pool {
            set p [expr {$name eq $rootName ? 0.08 : ($depth == 0 ? 0.6 : 0.35)}]
            if {[chance $p]} {
                set pkg ${prefix}.bot_modules/$name
                lappend dirs $pkg
                GenScope files dirs $pkg $name [expr {$depth + 1}]
            }
        }
        if {[chance 0.03]} {
            lappend dirs ${prefix}.bot_modules/std
        }
    }
}

# The namespaces a file in a scope of ROOTNAME may plausibly write.
proc Candidates {rootName} {
    global pool
    set c {}
    foreach name $pool {
        lappend c $name ${name}::sub
    }
    return $c
}

# A random case: {files FILES dirs DIRS entry ENTRY-IMPORTS}. Most imports
# name a namespace that resolves in the importing file's scope (so most
# cases have a value, and exercise identity); some name any namespace of the
# pool (so the diagnostics are exercised too).
proc GenCase {} {
    set files [dict create]
    set dirs {}
    GenScope files dirs "" "" 0
    set case [dict create files $files dirs $dirs]
    set result [dict create]
    set tag 0
    dict for {path _} $files {
        set scope [ScopeOf $path]
        dict set result $path [dict create imports [GenImports $case $scope [expr {int(rand() * 3)}] [OwnNamespace $path $scope]] \
            tag [incr tag]]
    }
    return [dict create files $result dirs $dirs entry [GenImports $case {"" "" ""} 3 ""]]
}

# The namespace the module file PATH of SCOPE is, as its scope spells it.
proc OwnNamespace {path scope} {
    set dir [lindex $scope 0]
    set inside [expr {$dir eq "" ? $path : [string range $path [string length $dir/] end]}]
    return [string map {/ ::} [file rootname $inside]]
}

# COUNT random imports for a file of SCOPE in CASE whose own namespace is
# OWN.
proc GenImports {case scope count own} {
    set good [lmap ns [Candidates [lindex $scope 1]] {
        if {$ns eq $own || [lindex [Resolve $case $scope $ns] 0] ne "ok"} continue
        set ns
    }]
    # A package's own packages, preferred: so that one name is read through
    # several branches (the application's geo and ui's geo).
    set deps [lmap ns $good {
        set r [Resolve $case $scope $ns]
        if {[llength [lindex $r 2 2]] == 0 || [lindex $r 2 2] eq [lindex $scope 2]} continue
        set ns
    }]
    set imports {}
    for {set i 0} {$i < $count} {incr i} {
        if {$deps ne {} && [lindex $scope 1] ne "" && [chance 0.6]} {
            set ns [pick $deps]
        } elseif {$good ne {} && [chance 0.92]} {
            set ns [pick $good]
        } else {
            set ns [pick [Candidates [lindex $scope 1]]]
        }
        if {$ns in [lmap x $imports {lindex $x 0}]} continue
        lappend imports [list $ns [chance 0.15]]
    }
    return $imports
}

# The scope ({DIR ROOTNAME INSTANCE}, the oracle's) of the module file PATH
# (relative).
proc ScopeOf {path} {
    set parts [file split $path]
    set dir {}
    set instance {}
    set rootName ""
    for {set i 0} {$i < [llength $parts] - 1} {incr i} {
        if {[lindex $parts $i] eq ".bot_modules"} {
            set rootName [lindex $parts [expr {$i + 1}]]
            lappend instance $rootName
            set dir [lrange $parts 0 [expr {$i + 1}]]
        }
    }
    return [list [join $dir /] $rootName [join $instance /]]
}

# ---------------------------------------------------------------------------
# Writing it

proc Text {imports body} {
    set lines {}
    lappend lines "import std::str"
    foreach import $imports {
        lassign $import ns rooted
        lappend lines "import [expr {$rooted ? "::" : ""}]$ns"
    }
    return "[join $lines \n]\n\n$body"
}

proc Call {import} {
    lassign $import ns rooted
    return "[expr {$rooted ? "::" : ""}]${ns}::t()"
}

proc ModuleText {entry} {
    set expr "\"[dict get $entry tag]\""
    if {[dict get $entry imports] ne {}} {
        set inner "\"\""
        foreach import [dict get $entry imports] {
            set inner "std::str::concat($inner, [Call $import])"
        }
        set expr "std::str::concat(std::str::concat(std::str::concat($expr, \"(\"), $inner), \")\")"
    }
    return [Text [dict get $entry imports] "fn t() -> str:\n    $expr\n"]
}

proc EntryText {imports} {
    return [Text $imports "\[[join [lmap i $imports {Call $i}] {, }]\]\n"]
}

proc WriteCase {dir case} {
    foreach d [dict get $case dirs] {
        file mkdir [file join $dir $d]
    }
    dict for {path entry} [dict get $case files] {
        Write [file join $dir $path] [ModuleText $entry]
    }
    Write [file join $dir main.bot] [EntryText [dict get $case entry]]
}

proc Write {path text} {
    file mkdir [file dirname $path]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# ---------------------------------------------------------------------------
# The oracle: the resolution table of BOT-MODULES-MILESTONE-1.md, section B,
# and the loader's depth-first order, over the case's description (never the
# file system or the compiler).

# A scope is {DIR ROOTNAME INSTANCE}: its directory (relative), its root
# namespace ("" for the application) and its instance ("" for the
# application, NAME/NAME/... for a package).

proc Installed {case dir name} {
    set prefix [expr {$dir eq "" ? "" : "$dir/"}]
    return [expr {"${prefix}.bot_modules/$name" in [dict get $case dirs]}]
}

proc FileOf {dir ns} {
    set prefix [expr {$dir eq "" ? "" : "$dir/"}]
    return "${prefix}[string map {:: /} $ns].bot"
}

proc Exists {case path} {
    return [dict exists [dict get $case files] $path]
}

# {ok PATH SCOPE IDENTITY} or {error KIND} for the import of NS by a file of
# SCOPE.
proc Resolve {case scope ns} {
    lassign $scope dir rootName instance
    set head [lindex [split [string map {:: \x00} $ns] \x00] 0]
    if {$head eq "std"} {
        if {[Installed $case $dir std]} { return {error RESERVED-NAMESPACE} }
        return {ok "" "" std}
    }
    if {$rootName ne "" && $head eq $rootName} {
        if {[Installed $case $dir $head]} { return {error MODULE-COLLISION} }
        set path [FileOf $dir $ns]
        if {![Exists $case $path]} { return {error UNKNOWN-NAMESPACE} }
        return [list ok $path $scope [Identity $instance $ns]]
    }
    if {[Installed $case $dir $head]} {
        set child [list [expr {$dir eq "" ? ".bot_modules/$head" : "$dir/.bot_modules/$head"}] $head \
            [expr {$instance eq "" ? $head : "$instance/$head"}]]
        if {$rootName eq "" && [Exists $case [FileOf $dir $ns]]} { return {error MODULE-COLLISION} }
        set path [FileOf [lindex $child 0] $ns]
        if {![Exists $case $path]} { return {error UNKNOWN-NAMESPACE} }
        return [list ok $path $child [Identity [lindex $child 2] $ns]]
    }
    if {$rootName ne ""} { return {error UNKNOWN-NAMESPACE} }
    set path [FileOf $dir $ns]
    if {![Exists $case $path]} { return {error UNKNOWN-NAMESPACE} }
    return [list ok $path $scope $ns]
}

proc Identity {instance ns} {
    if {$instance eq ""} { return $ns }
    set cut [string first :: $ns]
    return [expr {$cut < 0 ? $instance : "$instance[string range $ns $cut end]"}]
}

# The value of the case: {value V} or {error KIND FILE INDEX} (FILE relative,
# INDEX the import's position in it).
proc Oracle {case} {
    set ::loaded [dict create]
    set ::stack {}
    try {
        StdImport $case main.bot {"" "" ""}
        set values [lmap import [dict get $case entry] {
            ValueOf $case main.bot {"" "" ""} "" $import [expr {[lsearch -exact [dict get $case entry] $import] + 1}]
        }]
    } trap ORACLE {message} {
        return $message
    }
    return [list value "\[[join [lmap v $values {string cat \" $v \"}] {, }]\]"]
}

# Every file's first import, `import std::str` (index 0), in SCOPE.
proc StdImport {case file scope} {
    if {[lindex [Resolve $case $scope std::str] 0] eq "error"} {
        return -code error -errorcode ORACLE [list error [lindex [Resolve $case $scope std::str] 1] $file 0]
    }
}

# Loads (depth first, as the loader does) and evaluates the module the
# import IMPORT (index INDEX) of FILE, in SCOPE with own namespace OWN, names.
proc ValueOf {case file scope own import index} {
    lassign $import ns
    if {$ns eq $own} {
        return -code error -errorcode ORACLE [list error SELF-IMPORT $file $index]
    }
    set r [Resolve $case $scope $ns]
    if {[lindex $r 0] eq "error"} {
        return -code error -errorcode ORACLE [list error [lindex $r 1] $file $index]
    }
    lassign $r - path childScope identity
    if {$identity in $::stack} {
        return -code error -errorcode ORACLE [list error CYCLE $file $index]
    }
    if {![dict exists $::loaded $identity]} {
        lappend ::stack $identity
        set entry [dict get $case files $path]
        set inner {}
        StdImport $case $path $childScope
        set i 1
        foreach sub [dict get $entry imports] {
            lappend inner [ValueOf $case $path $childScope $ns $sub $i]
            incr i
        }
        set ::stack [lrange $::stack 0 end-1]
        set v [dict get $entry tag]
        if {$inner ne {}} {
            set v "$v\([join $inner ""])"
        }
        dict set ::loaded $identity $v
    }
    return [dict get $::loaded $identity]
}

# 1 if the oracle's last case loaded two modules a namespace of one name
# spells in different scopes (the application's geo, a package geo, and
# ui's geo: geo, ui/geo).
proc SameNamedInstances {} {
    set seen [dict create]
    foreach identity [dict keys $::loaded] {
        set instance [lindex [split $identity :] 0]
        dict lappend seen [lindex [split $instance /] end] $instance
    }
    dict for {name instances} $seen {
        if {[llength [lsort -unique $instances]] > 1} { return 1 }
    }
    return 0
}

# ---------------------------------------------------------------------------
# The compiler's outcome

proc Compiled {dir backends} {
    if {[catch {surface::readProgramFile [file join $dir main.bot] -warnings off -cache ""} hir options]} {
        set kind [lindex [dict get $options -errorcode] end]
        set location [dict getdef [lindex [dict getdef $options -diagnostics {{}}] 0] location ""]
        set file ""
        if {$location ne ""} {
            set file [string range [dict get $location file] [string length $dir/] end]
        }
        return [list error $kind $file [dict getdef $location line ""]]
    }
    return [lmap backend $backends {
        lassign [outcomeUnderHir $backend $hir] tag value
        # (Never expr's ?: over a value: `nan` and `inf` read as numbers.)
        if {$tag eq "value"} {
            set value
        } else {
            string cat "$tag: " $value
        }
    }]
}

# The oracle's expectation in the compiler's terms: a value per backend, or
# {error KIND FILE LINE} -- the import's line: line INDEX + 1 (index 0 is
# `import std::str`, the first).
proc Expected {case oracle backends} {
    if {[lindex $oracle 0] eq "value"} {
        return [lrepeat [llength $backends] [lindex $oracle 1]]
    }
    lassign $oracle - kind file index
    return [list error $kind $file [expr {$index + 1}]]
}

set n [dict get $options -n]
set seed [dict get $options -seed]
set backends [dict get $options -backends]
set failures 0
set outcomes [dict create]
set base [file tempdir botlish-bot-modules-fuzz]
try {
    for {set i 0} {$i < $n} {incr i} {
        set s [expr {$seed + $i}]
        expr {srand($s)}
        set case [GenCase]
        set dir [file join $base case$s]
        WriteCase $dir $case
        set oracle [Oracle $case]
        set expected [Expected $case $oracle $backends]
        set got [Compiled $dir $backends]
        if {[lindex $oracle 0] eq "value"} {
            dict incr outcomes value
        } else {
            dict incr outcomes [lindex $oracle 1]
        }
        if {[lindex $oracle 0] eq "value" && [SameNamedInstances]} {
            # (A value read through two instances of one package name.)
            dict incr outcomes "value with same-named instances"
        }
        if {$got ne $expected} {
            incr failures
            puts "FAIL seed $s\n  expected: $expected\n  got:      $got"
            if {[dict get $options -dump]} {
                foreach d [dict get $case dirs] { puts "  dir  $d" }
                dict for {path entry} [dict get $case files] {
                    puts "  file $path: [dict get $entry tag] imports [dict get $entry imports]"
                }
                puts "  main imports [dict get $case entry]"
            }
        }
        file delete -force $dir
    }
} finally {
    file delete -force $base
}
puts "$n cases (seeds $seed..[expr {$seed + $n - 1}]), [join [lmap {k v} [lsort -stride 2 $outcomes] {string cat "$k $v"}] {, }]; $failures failed"
exit [expr {$failures > 0}]

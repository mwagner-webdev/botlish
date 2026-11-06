# fuzz.tcl -- model-based fuzzing of the application's one dependency graph
# (SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md): random package universes,
# resolved by the package manager (pm/graph.tcl) and by an independent
# reference resolver (oracle.py, beside this script), installed, verified
# and compiled.
#
#   tclsh9.0 audit/shared-dependencies/tools/fuzz.tcl ?-seed N? ?-cases N?
#       ?-compile EVERY? ?-backends {interp compile}?
#
# Each case draws a universe -- 2 to 6 package names, 1 to 3 releases of
# each, each release 0 to 3 dependencies on other names, locked mostly to a
# release that exists, sometimes to one no repository holds -- and an
# application depending on 1 to 3 of the names. The releases are written
# as ordinary .botpkg artifacts (pm/archive.tcl), split between two
# repositories at random. Then, for the case:
#
#   1. the package manager's resolution (pm::graph::Resolve) and the
#      oracle's verdict agree: the same kind -- ok, DEPENDENCY-CONFLICT
#      (the same conflicting packages), UNAVAILABLE, CYCLE -- and for an
#      accepted graph the same selected version of every package;
#   2. resolution is independent of order: the application's botlish.json
#      with its entries in reverse order and the repositories given in the
#      other order give the same result, its message byte for byte;
#   3. an accepted graph installs (pm::install::Apply): one directory per
#      selected package, none inside another, the graph file the oracle's
#      text;
#   4. every EVERY-th accepted graph compiles and runs: each package's
#      module returns its name, its version and its dependencies' values,
#      and passes a value of a shared dependency's struct from its own
#      import of that package to another package's (moduleText), so a
#      program over the application's dependencies evaluates to what the
#      oracle's selection predicts, on every one of BACKENDS -- every import
#      bound to the graph's one instance of its package, one nominal type.
#
# A disagreement is reported with its universe (as the oracle's JSON) and
# the run exits 1. Scratch files live in a `file tempdir` directory, removed
# at the end.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set options [dict create -seed 1 -cases 200 -compile 5 -backends {interp compile}]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
# (tests/helpers.tcl loads tcltest, which reads argv.)
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root pm pm.tcl]

expr {srand([dict get $options -seed])}
proc pick {list} { lindex $list [expr {int(rand() * [llength $list])}] }
proc shuffle {list} {
    for {set i [expr {[llength $list] - 1}]} {$i > 0} {incr i -1} {
        set j [expr {int(rand() * ($i + 1))}]
        set t [lindex $list $i]
        lset list $i [lindex $list $j]
        lset list $j $t
    }
    return $list
}
proc chance {p} { expr {rand() < $p} }

set scratch [file tempdir botlish-shared-fuzz]
set oracle [file join $here oracle.py]

proc writeBytes {path bytes} {
    file mkdir [file dirname $path]
    set channel [open $path wb]
    puts -nonewline $channel $bytes
    close $channel
}

# A universe: {releases {"NAME VERSION" {DEP LOCK ...}} application {NAME
# LOCK ...}}.
proc universe {} {
    set names [lrange {alpha beta gamma delta eps zeta} 0 [expr {1 + int(rand() * 5)}]]
    set versions [dict create]
    foreach name $names {
        set list {}
        foreach v {1.0.0 1.1.0 2.0.0} {
            if {$list eq "" || [chance 0.5]} { lappend list $v }
        }
        dict set versions $name $list
    }
    # Each name has a favoured release most locks name, so that graphs
    # agree often enough to be installed and shared.
    set favoured [dict create]
    foreach name $names {
        dict set favoured $name [pick [dict get $versions $name]]
    }
    set releases [dict create]
    foreach name $names {
        foreach v [dict get $versions $name] {
            set deps [dict create]
            set others [lmap n $names {if {$n eq $name} continue; set n}]
            set count [expr {int(rand() * 3)}]
            for {set i 0} {$i < $count && $others ne ""} {incr i} {
                set dep [pick $others]
                if {[chance 0.06]} {
                    dict set deps $dep 9.9.9
                } elseif {[chance 0.75]} {
                    dict set deps $dep [dict get $favoured $dep]
                } else {
                    dict set deps $dep [pick [dict get $versions $dep]]
                }
            }
            dict set releases "$name $v" $deps
        }
    }
    set application [dict create]
    foreach name [lrange [shuffle $names] 0 [expr {int(rand() * 3)}]] {
        if {[chance 0.75]} {
            dict set application $name [dict get $favoured $name]
        } else {
            dict set application $name [pick [dict get $versions $name]]
        }
    }
    return [dict create releases $releases application $application]
}

# The oracle's JSON of UNIVERSE, and its verdict as a Tcl dict.
proc universeJson {u} {
    set rel {}
    dict for {key deps} [dict get $u releases] {
        lappend rel $key [list obj [concat {*}[lmap {d v} $deps {list $d [list str $v]}]]]
    }
    set app [concat {*}[lmap {n v} [dict get $u application] {list $n [list str $v]}]]
    return [pm::json::encode [list obj [list releases [list obj $rel] application [list obj $app]]]]
}

proc verdict {u} {
    set json [exec python3 -I $::oracle resolve << [encoding convertfrom utf-8 [universeJson $u]]]
    return [JsonToTcl [pm::json::decode [encoding convertto utf-8 $json]]]
}

proc JsonToTcl {value} {
    switch -- [pm::json::type $value] {
        obj { return [concat {*}[lmap {k v} [pm::json::payload $value] {list $k [JsonToTcl $v]}]] }
        arr { return [lmap v [pm::json::payload $value] {JsonToTcl $v}] }
        default { return [pm::json::payload $value] }
    }
}

# The module of release NAME VERSION with dependencies DEPS, in universe
# U: a struct T holding its own name, make() making one, take_D(t) reading
# one of each dependency D's T, and v(): its name, version, its
# dependencies' v() values, and, for every pair of its dependencies A and D
# where A's locked release uses D too, A::take_D(D::make()) -- a value of
# D's type made through this package's import of D, read through A's: one
# type exactly when both imports are the graph's one instance of D.
proc moduleText {name version deps u} {
    set text ""
    foreach dep [lsort [dict keys $deps]] {
        append text "import $dep\n"
    }
    append text "import std::str\n\nstruct T:\n    s: str\n\nfn make() -> T:\n    T {s: \"$name@$version\"}\n"
    foreach dep [lsort [dict keys $deps]] {
        append text "\nfn take_$dep\(t: ${dep}::T) -> str:\n    t.s\n"
    }
    append text "\nfn v() -> str:\n    \"$name@$version\""
    foreach dep [lsort [dict keys $deps]] {
        append text ".concat(\"(\").concat(${dep}::v()).concat(\")\")"
    }
    foreach call [Crossings $deps $u] {
        append text ".concat(\"\[\").concat($call).concat(\"\]\")"
    }
    append text \n
    return $text
}

# The crossing calls of a scope whose dependencies are DEPS (NAME -> lock):
# A::take_D(D::make()) for each A and D of DEPS where A's locked release
# uses D.
proc Crossings {deps u} {
    set calls {}
    foreach a [lsort [dict keys $deps]] {
        set key "$a [dict get $deps $a]"
        if {![dict exists $u releases $key]} continue
        foreach d [lsort [dict keys [dict get $u releases $key]]] {
            if {[dict exists $deps $d]} {
                lappend calls "${a}::take_$d\(${d}::make())"
            }
        }
    }
    return $calls
}

# Writes UNIVERSE's releases as artifacts into REPOS (each into one of them).
proc writeRepositories {u repos} {
    dict for {key deps} [dict get $u releases] {
        lassign $key name version
        set locks $deps
        set requests [concat {*}[lmap {d v} $deps {list $d [join [lrange [split $v .] 0 1] .]}]]
        set descriptor [dict create schema 1 name $name version $version dependencies $requests lock $locks sources {}]
        set files [dict create botlish.json [pm::descriptor::encode $descriptor 0] \
            $name.bot [encoding convertto utf-8 [moduleText $name $version $deps $u]]]
        writeBytes [file join [pick $repos] $name-$version.botpkg] [pm::archive::bytes $files]
    }
}

# The application project APP for UNIVERSE (its botlish.json, entries in
# order, or REVERSED).
proc writeProject {u app reversed} {
    set deps [dict get $u application]
    set names [dict keys $deps]
    if {$reversed} { set names [lreverse $names] }
    set requests [concat {*}[lmap n $names {list $n [list str [join [lrange [split [dict get $deps $n] .] 0 1] .]]}]]
    set locks [concat {*}[lmap n $names {list $n [list str [dict get $deps $n]]}]]
    # (Written as JSON in this order, not canonically: the reader must not
    # care.)
    set members [list schema {num 1} dependencies [list obj $requests] lock [list obj $locks]]
    if {$reversed} {
        set members [list schema {num 1} lock [list obj $locks] dependencies [list obj $requests]]
    }
    writeBytes [file join $app botlish.json] [pm::json::encode [list obj $members]]
    set main ""
    foreach name [lsort $names] { append main "import $name\n" }
    set items [concat [lmap n [lsort $names] {string cat $n "::v()"}] [Crossings $deps $u]]
    append main "\n\[[join $items {, }]\]\n"
    writeBytes [file join $app main.bot] [encoding convertto utf-8 $main]
}

# {kind KIND message M selected {NAME VERSION ...}} of resolving APP with
# REPOS.
proc resolution {app repos} {
    pm::catalog::configure $repos
    set ctx [pm::install::Project $app]
    set descriptor [pm::install::Descriptor $ctx]
    if {[catch {pm::graph::Resolve $ctx $descriptor [dict create]} plan options]} {
        return [dict create kind [lindex [dict get $options -errorcode] 1] message $plan selected {}]
    }
    set selected {}
    foreach name [lsort [dict keys [dict get $plan packages]]] {
        lappend selected $name [dict get $plan packages $name version]
    }
    return [dict create kind ok message "" selected $selected plan $plan ctx $ctx descriptor $descriptor]
}

# What the oracle predicts APP's value to be: v() of each dependency.
proc expectedValue {verdict u} {
    set values {}
    set deps [dict get $u application]
    foreach name [lsort [dict keys $deps]] {
        lappend values "\"[Value $name $verdict $u]\""
    }
    foreach take [CrossingValues $deps $verdict $u] {
        lappend values "\"$take\""
    }
    return "\[[join $values {, }]\]"
}

proc Value {name verdict u} {
    set version [dict get $verdict selected $name]
    set deps [dict get $u releases "$name $version"]
    set text "$name@$version"
    foreach dep [lsort [dict keys $deps]] {
        append text "([Value $dep $verdict $u])"
    }
    foreach take [CrossingValues $deps $verdict $u] {
        append text "\[$take\]"
    }
    return $text
}

# What a scope's crossing calls (Crossings) return: D's T made by the graph's
# selected D.
proc CrossingValues {deps verdict u} {
    set values {}
    foreach a [lsort [dict keys $deps]] {
        set key "$a [dict get $deps $a]"
        if {![dict exists $u releases $key]} continue
        foreach d [lsort [dict keys [dict get $u releases $key]]] {
            if {[dict exists $deps $d]} {
                lappend values "$d@[dict get $verdict selected $d]"
            }
        }
    }
    return $values
}

set stats [dict create ok 0 DEPENDENCY-CONFLICT 0 UNAVAILABLE 0 CYCLE 0 compiled 0 shared 0]
set failures 0
proc disagree {case u what} {
    puts "DISAGREEMENT case $case: $what"
    puts "  universe: [encoding convertfrom utf-8 [universeJson $u]]"
    incr ::failures
}

set accepted 0
for {set case 1} {$case <= [dict get $options -cases]} {incr case} {
    set u [universe]
    set dir [file join $scratch case-$case]
    set repos [list [file join $dir repo-a] [file join $dir repo-b]]
    foreach repo $repos { file mkdir $repo }
    writeRepositories $u $repos
    set app [file join $dir app]
    set app2 [file join $dir app2]
    file mkdir $app $app2
    writeProject $u $app 0
    writeProject $u $app2 1
    set v [verdict $u]
    set mine [resolution $app $repos]
    set again [resolution $app2 [lreverse $repos]]
    set expected [dict create ok ok conflict DEPENDENCY-CONFLICT unavailable UNAVAILABLE cycle CYCLE]
    set want [dict get $expected [dict get $v result]]
    dict incr stats [dict get $mine kind]
    if {[dict get $mine kind] ne $want} {
        disagree $case $u "the package manager says [dict get $mine kind] ([dict get $mine message]), the oracle [dict get $v result]"
        continue
    }
    if {[dict get $mine message] ne [dict get $again message] || [dict get $mine selected] ne [dict get $again selected]} {
        disagree $case $u "resolution depends on order: [dict get $mine message] / [dict get $again message]"
        continue
    }
    if {$want eq "DEPENDENCY-CONFLICT"} {
        set names [lsort [lmap {- n} [regexp -all -inline {cannot (?:select one version of|select) ([a-z]+)} [dict get $mine message]] {set n}]]
        if {$names ne [dict get $v names]} {
            disagree $case $u "conflicting packages: the package manager's $names, the oracle's [dict get $v names]"
        }
        continue
    }
    if {$want ne "ok"} continue
    set oracleSelected {}
    foreach name [lsort [dict keys [dict get $v selected]]] {
        lappend oracleSelected $name [dict get $v selected $name]
    }
    if {[dict get $mine selected] ne $oracleSelected} {
        disagree $case $u "selection: the package manager's [dict get $mine selected], the oracle's $oracleSelected"
        continue
    }
    # Install it.
    set ctx [dict get $mine ctx]
    pm::install::Lock $ctx 0
    set installed [catch {pm::install::Apply $ctx [dict get $mine plan] [dict create] 0 ""} message]
    pm::install::Unlock $ctx
    if {$installed} {
        disagree $case $u "the graph does not install: $message"
        continue
    }
    set graph [file join $app .bot_modules .graph]
    set text ""
    if {[file exists $graph]} {
        set channel [open $graph rb]; set text [read $channel]; close $channel
    }
    if {$text ne [dict get $v graph]} {
        disagree $case $u "the installed graph:\n$text\nthe oracle's:\n[dict get $v graph]"
        continue
    }
    set dirs [lsort [lmap d [glob -nocomplain -tails -directory [file join $app .bot_modules] *] {if {[string index $d 0] eq "."} continue; set d}]]
    if {$dirs ne [lsort [dict keys [dict get $v selected]]]} {
        disagree $case $u "installed directories $dirs"
        continue
    }
    set users [dict create]
    foreach name [dict keys [dict get $u application]] { dict incr users $name }
    dict for {name uses} [dict get $v uses] { foreach dep $uses { dict incr users $dep } }
    dict for {dep count} $users { if {$count > 1} { dict incr stats shared; break } }
    incr accepted
    if {$accepted % [dict get $options -compile] == 0} {
        if {[catch {surface::readProgramFile [file join $app main.bot] -warnings off -cache ""} hir]} {
            disagree $case $u "the program does not compile: [lindex [split $hir \n] 0]"
            continue
        }
        set want [expectedValue $v $u]
        foreach backend [dict get $options -backends] {
            lassign [outcomeUnderHir $backend $hir] tag value
            if {$tag ne "value" || $value ne $want} {
                disagree $case $u "$backend: $tag $value, expected $want"
            }
        }
        dict incr stats compiled
    }
    file delete -force $dir
}
file delete -force $scratch
puts "seed [dict get $options -seed]: [dict get $options -cases] cases: [dict get $stats ok] accepted ([dict get $stats shared] with a package two scopes share), [dict get $stats DEPENDENCY-CONFLICT] conflicts, [dict get $stats UNAVAILABLE] unavailable, [dict get $stats CYCLE] cycles; [dict get $stats compiled] compiled and run; $failures disagreement(s)"
exit [expr {$failures > 0}]

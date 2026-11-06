# graph.tcl -- the application's one resolved dependency graph
# (SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md).
#
#   pm::graph::Resolve CTX DESCRIPTOR STATE   the plan: every package of the
#                                             graph, one version each
#   pm::graph::Demands CTX DESCRIPTOR STATE   what every package of the graph
#                                             asks of every other (no check)
#   pm::graph::Text APPLICATION USES          the compiler's .graph file
#
# A package declares its direct dependencies and locks each to the exact
# release its author built and tested it with (BOTLISH-JSON.md, section 6).
# An application has one dependency graph: every package that appears in it
# appears once, at one version, and every package that depends on it -- the
# application among them -- uses that one instance (one module identity, one
# set of types and contexts, one native archive). Resolution is therefore
# unification, not search:
#
#   1. The demands. The application's direct dependencies are demanded at
#      the versions its botlish.json locks (or, editable, at the directory's
#      version); every release that is demanded is acquired (or, installed
#      exactly so, read from the installation record) and demands each of
#      its own dependencies at the version its own botlish.json locks. Every
#      demanded release is explored, whether or not it is in conflict, so
#      that what is reported does not depend on the order anything was
#      visited in.
#   2. The selection. A package is selected at the one version every demand
#      of it names. Two demands naming two versions are a
#      DEPENDENCY-CONFLICT, reported with every demand, the lock that makes
#      it and a dependency path to the package that holds the lock. No lock
#      is ever moved, relaxed or overridden to make the graph agree -- not
#      the application's, not a package author's -- and no second instance
#      is ever made: there is no fallback. An editable dependency (a
#      directory, no release) satisfies no other package's lock: it is a
#      conflict as soon as a package locks it.
#   3. The artifact. A selected release is one artifact: the application's
#      archive source for it, or the repositories' file (two different
#      files claiming one release are a CONFLICT, as everywhere: pm/catalog.tcl).
#      A release some package locks and the application supplies from an
#      archive source must be the same bytes as the repositories' file of
#      that release, when they hold one.
#   4. Cycles. A package that depends on itself through its dependencies is
#      a CYCLE, whatever the versions (one instance each: the graph would
#      need the package before it).
#
# The plan is a pure function of the botlish.json files involved and the
# artifacts' bytes: equal inputs give equal graphs, whatever the order of the
# dependencies, the repositories or the files on disk.

namespace eval pm::graph {
    variable maxPackages 1000
}

# ---------------------------------------------------------------------------
# Demands

# What the project CTX (descriptor DESCRIPTOR, installation record STATE)
# demands, transitively: a dict
#
#   application  its direct dependencies (sorted)
#   demands      NAME -> {DEMAND...}, each {version V by BY kind K ...}: BY ""
#                for the application, else the demanding release {NAME
#                VERSION}; K lock (an exact lock: the application's carries
#                `request` too) or editable (the application's directory
#                dependency: `directory` too)
#   pairs        {NAME VERSION} -> the release's node, or {error MESSAGE
#                options OPTIONS} when it could not be acquired
#   paths        {NAME VERSION} -> the dependency path that first reached it
#                (NAME VERSION ...), breadth first in name order
#
# A node is
#
#   {kind artifact name N version V digest D uses {DEP VERSION ...}
#    artifact A reuse 0}                  to be extracted from the artifact A
#   {kind artifact ... reuse 1 record R}  installed exactly so (R its record)
#   {kind editable name N version V directory P target T descriptor D
#    uses {...} reuse 0|1}
proc pm::graph::Demands {ctx descriptor state} {
    variable maxPackages
    set project [dict get $ctx project]
    set sources [dict get $descriptor sources]
    set application [lsort [dict keys [dict get $descriptor dependencies]]]
    set demands [dict create]
    set pairs [dict create]
    set paths [dict create]
    set level {}
    foreach name $application {
        set request [dict get $descriptor dependencies $name]
        set source [dict getdef $sources $name ""]
        if {$source ne "" && [dict get $source kind] eq "directory"} {
            set node [Editable $ctx $name $request $source $state]
            set key [list $name [dict get $node version]]
            dict lappend demands $name [dict create version [dict get $node version] by "" kind editable \
                directory [dict get $source path]]
            dict set pairs $key $node
            dict set paths $key $key
            foreach {dep version} [dict get $node uses] {
                dict lappend demands $dep [dict create version $version by $key kind lock]
                lappend level [list $dep $version $key]
            }
            continue
        }
        if {![dict exists $descriptor lock $name]} {
            pm::Fail LOCK "dependency $name (request \"$request\") has no lock in botlish.json: install installs exact releases only. Run update $name to choose one"
        }
        set version [dict get $descriptor lock $name]
        dict lappend demands $name [dict create version $version by "" kind lock request $request]
        lappend level [list $name $version {}]
    }
    # Breadth first, each level in the order its parents were reached and
    # each release's dependencies in name order: the first path to reach a
    # release is a shortest one, the same on every run.
    while {$level ne ""} {
        set next {}
        foreach item $level {
            lassign $item name version chain
            set key [list $name $version]
            if {[dict exists $pairs $key]} continue
            if {[dict size $pairs] >= $maxPackages} {
                pm::Fail LIMIT "the dependency graph has more than $maxPackages package releases"
            }
            set path [concat $chain $key]
            dict set paths $key $path
            if {[catch {Release $ctx $descriptor $state $name $version $chain} node options]} {
                if {[lindex [dict get $options -errorcode] 0] ne "PM"} {
                    return -options $options $node
                }
                dict set pairs $key [dict create error $node options $options]
                continue
            }
            dict set pairs $key $node
            foreach {dep depVersion} [dict get $node uses] {
                dict lappend demands $dep [dict create version $depVersion by $key kind lock]
                lappend next [list $dep $depVersion $path]
            }
        }
        set level $next
    }
    return [dict create application $application demands $demands pairs $pairs paths $paths]
}

# The node of the editable dependency NAME (request REQUEST, directory
# SOURCE) of CTX: its dependencies are its botlish.json's, each locked there
# (an editable package's dependencies are releases like every package's).
proc pm::graph::Editable {ctx name request source state} {
    set editable [pm::catalog::Editable [dict get $ctx project] $name $source]
    set descriptor [dict get $editable descriptor]
    if {![pm::version::satisfies [dict get $editable version] $request]} {
        pm::Fail REQUEST "dependency $name: the editable directory [dict get $source path] is version [dict get $editable version], which the request \"$request\" does not accept"
    }
    set uses {}
    foreach dep [lsort [dict keys [dict get $descriptor dependencies]]] {
        if {[dict exists $descriptor sources $dep] && [dict get $descriptor sources $dep kind] eq "directory"} {
            pm::Fail EDITABLE "the editable package $name ([dict get $source path]) has an editable dependency of its own, $dep: an application's dependency graph holds releases and the application's own editable dependencies only (make $dep the application's editable dependency instead)"
        }
        if {![dict exists $descriptor lock $dep]} {
            pm::Fail LOCK "the editable package $name ([dict get $source path]) has no lock for its dependency $dep in its botlish.json: its dependencies are installed in the application's graph from exact releases, like every package's. Run update $dep in [dict get $source path]"
        }
        lappend uses $dep [dict get $descriptor lock $dep]
    }
    set record [dict getdef $state $name ""]
    set installed [file join [dict get $ctx modules] $name]
    set reuse [expr {$record ne "" && [dict get $record kind] eq "editable"
        && [dict get $record directory] eq [dict get $source path]
        && [pm::install::LinkTarget $installed] eq [dict get $editable target]}]
    return [dict create kind editable name $name version [dict get $editable version] \
        directory [dict get $source path] target [dict get $editable target] reuse $reuse \
        descriptor $descriptor uses $uses]
}

# The node of the release NAME VERSION, demanded through CHAIN (NAME VERSION
# ... of the release that demands it; empty for the application).
proc pm::graph::Release {ctx descriptor state name version chain} {
    set record [dict getdef $state $name ""]
    set installed [file join [dict get $ctx modules] $name]
    set source [dict getdef [dict get $descriptor sources] $name ""]
    # The application's archive source supplies the release its lock names.
    set archive [expr {$source ne "" && [dict get $source kind] eq "archive"
        && [dict getdef [dict get $descriptor lock] $name ""] eq $version}]
    set digest ""
    if {$archive} {
        set digest [dict get $source sha256]
    }
    if {[Reusable $record $version $digest $installed]} {
        return [dict create kind artifact name $name version $version digest [dict get $record sha256] \
            uses [dict get $record uses] reuse 1 record $record]
    }
    if {$archive} {
        set artifact [pm::catalog::ArchiveSource [dict get $ctx project] $name $source]
        if {[dict get $artifact version] ne $version} {
            pm::Fail LOCK "dependency $name: the archive [dict get $source path] is version [dict get $artifact version], and the lock says $version"
        }
    } else {
        set artifact [pm::catalog::Find $name $version $chain]
    }
    set artifactDescriptor [dict get $artifact descriptor]
    set uses {}
    foreach dep [lsort [dict keys [dict get $artifactDescriptor dependencies]]] {
        lappend uses $dep [dict get $artifactDescriptor lock $dep]
    }
    return [dict create kind artifact name $name version $version digest [dict get $artifact digest] \
        artifact $artifact uses $uses reuse 0]
}

# 1 when the RECORD at INSTALLED is the release VERSION (with the digest
# DIGEST, when one is required), installed in the graph's layout exactly so.
proc pm::graph::Reusable {record version digest installed} {
    if {$record eq "" || [dict get $record kind] ne "artifact" || ![dict exists $record uses]
            || [dict get $record version] ne $version} {
        return 0
    }
    if {$digest ne "" && [dict get $record sha256] ne $digest} {
        return 0
    }
    return [expr {[pm::state::Changes $installed $record x] eq ""}]
}

# ---------------------------------------------------------------------------
# Selection

# The plan of the project CTX (descriptor DESCRIPTOR, record STATE): a dict
#
#   application  its direct dependencies, sorted
#   packages     NAME -> node (Demands), one per package of the graph
#   paths        NAME -> a dependency path to it (NAME VERSION ...)
#   users        NAME -> the scopes that use it ("" for the application,
#                else a package name), sorted
#   demands      NAME -> what every scope demands of it (Demands)
#
# or {PM DEPENDENCY-CONFLICT}, {PM CYCLE}, or the error that kept a selected
# release from being acquired.
proc pm::graph::Resolve {ctx descriptor state} {
    set found [Demands $ctx $descriptor $state]
    set demands [dict get $found demands]
    set pairs [dict get $found pairs]
    set paths [dict get $found paths]
    set conflicts {}
    foreach name [lsort [dict keys $demands]] {
        set list [dict get $demands $name]
        set versions [lsort -unique [lmap d $list {dict get $d version}]]
        set editable 0
        foreach demand $list {
            if {[dict get $demand kind] eq "editable"} {
                set editable 1
            }
        }
        if {[llength $versions] > 1 || ($editable && [llength $list] > 1)} {
            lappend conflicts [Conflict $name $list $paths]
        }
    }
    if {$conflicts ne ""} {
        pm::Fail DEPENDENCY-CONFLICT "[join $conflicts \n]\nA package of the application's dependency graph has one instance, at one version, used by every package that depends on it; a lock is the release its package was built and tested with, and is never changed, relaxed or overridden to make the graph agree, and no second instance is made. Choose versions whose locks agree (update, add -request), or ask the packages' authors for releases that lock the same version"
    }
    # Every demanded release is selected now: one per package.
    foreach key [lsort [dict keys $pairs]] {
        set node [dict get $pairs $key]
        if {[dict exists $node error]} {
            return -options [dict get $node options] [dict get $node error]
        }
    }
    set packages [dict create]
    set byName [dict create]
    foreach key [lsort [dict keys $pairs]] {
        lassign $key name version
        dict set packages $name [dict get $pairs $key]
        dict set byName $name [dict get $paths $key]
    }
    ArchiveAgrees $ctx $descriptor $demands $packages $byName
    Cycles [dict get $found application] $packages
    set users [dict create]
    foreach name [dict keys $packages] {
        dict set users $name {}
    }
    foreach name [dict get $found application] {
        dict lappend users $name ""
    }
    dict for {name node} $packages {
        foreach {dep -} [dict get $node uses] {
            dict lappend users $dep $name
        }
    }
    dict for {name list} $users {
        dict set users $name [lsort $list]
    }
    return [dict create application [dict get $found application] packages $packages paths $byName users $users \
        demands $demands]
}

# A conflict's report: the package NAME and every demand LIST of it, each
# with the lock that makes it and the path to the package that holds it
# (PATHS), sorted by version and then by who demands it.
proc pm::graph::Conflict {name list paths} {
    set lines {}
    foreach demand $list {
        set by [dict get $demand by]
        set version [dict get $demand version]
        if {$by eq ""} {
            if {[dict get $demand kind] eq "editable"} {
                set text "the application's editable dependency [dict get $demand directory] (version $version, a directory: no release, no lock, so it satisfies no package's lock)"
            } else {
                set text "the application's botlish.json locks $name $version (request \"[dict get $demand request]\")"
            }
            set order [list 0 ""]
        } else {
            lassign $by owner ownerVersion
            set text "$owner $ownerVersion locks $name $version ([pm::catalog::Chain [dict get $paths $by]])"
            set order [list 1 $by]
        }
        lappend lines [list $version $order $text]
    }
    set sorted [lsort -command [list apply {{a b} {
        set c [pm::version::compare [lindex $a 0] [lindex $b 0]]
        if {$c != 0} { return $c }
        return [string compare [lindex $a 1] [lindex $b 1]]
    }}] $lines]
    set versions [lsort -unique [lmap line $lines {lindex $line 0}]]
    if {[llength $versions] > 1} {
        set head "cannot select one version of $name for the application's dependency graph: [join [pm::version::sort $versions] { and }] are demanded"
    } else {
        set head "cannot select $name for the application's dependency graph: it is the application's editable dependency, and a package locks a release of it"
    }
    return "$head:\n  [join [lmap line $sorted {lindex $line 2}] "\n  "]"
}

# A release the application supplies from an archive source and some package
# of the graph locks too must be the repositories' file of that release, when
# a repository holds one: two different files claiming one release are never
# chosen between (pm/catalog.tcl's CONFLICT).
proc pm::graph::ArchiveAgrees {ctx descriptor demands packages paths} {
    if {[pm::catalog::RepositoryCount] == 0} {
        return
    }
    dict for {name source} [dict get $descriptor sources] {
        if {[dict get $source kind] ne "archive" || ![dict exists $packages $name]} continue
        set packageDemands [lmap d [dict get $demands $name] {if {[dict get $d by] eq ""} continue; set d}]
        if {$packageDemands eq ""} continue
        set node [dict get $packages $name]
        set version [dict get $node version]
        set chain [lrange [dict get $paths $name] 0 end-2]
        if {[catch {pm::catalog::Find $name $version $chain} artifact options]} {
            if {[lindex [dict get $options -errorcode] 1] eq "UNAVAILABLE"} continue
            return -options $options $artifact
        }
        if {[dict get $artifact digest] ne [dict get $node digest]} {
            set lockers [lsort -unique [lmap d $packageDemands {join [dict get $d by]}]]
            pm::Fail CONFLICT "two different artifacts claim $name $version: the application's archive source [dict get $source path] (sha256 [dict get $node digest]) and [dict get $artifact path] (sha256 [dict get $artifact digest]), and [join $lockers {, }] lock[expr {[llength $lockers] == 1 ? "s" : ""}] $name $version: the graph has one instance of $name, and the package manager never chooses between two files claiming one release. Remove the one that is not $name $version"
        }
    }
}

# Refuses a package of PACKAGES that depends on itself through its
# dependencies: CYCLE with the path from the application.
proc pm::graph::Cycles {application packages} {
    set done [dict create]
    foreach name $application {
        CycleWalk $name $packages {} done
    }
}

proc pm::graph::CycleWalk {name packages stack doneVar} {
    upvar 1 $doneVar done
    if {[dict exists $done $name]} return
    set node [dict get $packages $name]
    set here [concat $stack [list $name [dict get $node version]]]
    foreach {dep -} [dict get $node uses] {
        if {[lsearch -exact [lmap {n v} $here {set n}] $dep] >= 0} {
            pm::Fail CYCLE "[pm::catalog::Chain [concat $here [list $dep [dict get $packages $dep version]]]]: a dependency cycle (a package cannot depend on itself through its dependencies: the graph holds one instance of each package)"
        }
        CycleWalk $dep $packages $here done
    }
    dict set done $name 1
}

# ---------------------------------------------------------------------------
# The compiler's graph file

# The text of PACKAGES/.graph (surface/modules.tcl's ReadGraph): the
# application's dependencies APPLICATION and, for each package NAME of USES
# (NAME -> its dependencies), the packages it uses. One graph, one text.
proc pm::graph::Text {application uses} {
    set text "botlish package graph 1\napplication"
    foreach name [lsort $application] {
        append text " $name"
    }
    append text \n
    foreach name [lsort [dict keys $uses]] {
        append text "package $name"
        foreach dep [lsort [dict get $uses $name]] {
            append text " $dep"
        }
        append text \n
    }
    return $text
}

# The graph text of the installation record STATE (NAME -> node) and its
# application's dependencies APPLICATION ("" when nothing is installed in
# the graph's layout).
proc pm::graph::OfState {application state} {
    if {$application eq "" && [dict size $state] == 0} {
        return ""
    }
    set uses [dict create]
    dict for {name node} $state {
        if {![dict exists $node uses]} {
            return ""
        }
        dict set uses $name [dict keys [dict get $node uses]]
    }
    return [Text $application $uses]
}

# A dependency path (NAME VERSION ...) to each package of the installation
# record STATE whose application uses APPLICATION, for messages: breadth
# first in name order, as resolution's (Demands).
proc pm::graph::PathsOfState {application state} {
    set paths [dict create]
    set level [lmap name [lsort $application] {list $name {}}]
    while {$level ne ""} {
        set next {}
        foreach item $level {
            lassign $item name chain
            if {[dict exists $paths $name] || ![dict exists $state $name]} continue
            set node [dict get $state $name]
            set path [concat $chain [list $name [dict get $node version]]]
            dict set paths $name $path
            foreach dep [lsort [dict keys [dict getdef $node uses {}]]] {
                lappend next [list $dep $path]
            }
        }
        set level $next
    }
    return $paths
}


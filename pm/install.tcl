# install.tcl -- resolution, plans and transactions
# (PACKAGE-MANAGER-MILESTONE-1.md, "Installation algorithm" and
# "Transactions").
#
# A project is a directory with a botlish.json; its packages are installed
# in PROJECT/.bot_modules, and the package manager keeps its own files in
# PROJECT/.bot_modules/.botlish:
#
#   state.json      the installation record (pm/state.tcl): which top-level
#                   entries of .bot_modules are managed
#   lock            present while an operation runs: its process id
#   txn/            the operation's transaction directory: new/NAME (staged
#                   packages), old/NAME (replaced ones), journal.json,
#                   committed, old-state.json, old-botlish.json
#
# Every operation (add, install, update, remove) is one transaction:
#
#   1. lock the project (an interrupted operation found here is rolled back
#      first, or, if it had committed, finished);
#   2. resolve the whole dependency tree and validate every artifact in it
#      (resolve): nothing has been written yet;
#   3. refuse to replace or remove anything that is not the manager's, or
#      that changed since it was installed (unless -force);
#   4. stage every new or changed top-level package -- its files and, in its
#      own .bot_modules, its dependencies, recursively -- under txn/new, in
#      directories the manager created, with files it creates exclusively;
#   5. write the journal, then move each replaced package to txn/old and
#      each staged one into place (renames within .bot_modules), write the
#      record, write botlish.json, and mark the transaction committed;
#   6. delete txn and the lock.
#
# A failure before step 5 leaves the project as it was (the staging is
# deleted). A failure during step 5 rolls the renames back and restores the
# record and botlish.json from the copies the journal names; an interrupted
# process leaves the journal, and the next operation does the same before
# anything else (or completes the cleanup of a committed one). The previous
# installation is therefore either kept or replaced as a whole.

namespace eval pm::install {
    variable maxDepth 32
    variable maxInstances 1000
    variable created {}
}

# ---------------------------------------------------------------------------
# The project

# A project context for the directory PROJECT: {project modules meta}.
proc pm::install::Project {project} {
    set project [file normalize $project]
    if {![file isdirectory $project]} {
        pm::Fail PROJECT "the project directory $project does not exist"
    }
    # The compiler's own standard library is never a project: no package
    # operation writes there.
    set library [file normalize [file join $::pm::root stdlib]]
    if {$project eq $library || [string first $library/ $project/] == 0} {
        pm::Fail PROJECT "$project is inside the compiler's standard library ($library): packages are never installed there"
    }
    set modules [file join $project .bot_modules]
    set meta [file join $modules .botlish]
    foreach dir [list $modules $meta] {
        if {[pm::Exists $dir] && [file type $dir] ne "directory"} {
            pm::Fail PROJECT "$dir is a [file type $dir], not a directory: the package manager manages a real directory only (it never follows a link to a directory it writes into)"
        }
    }
    return [dict create project $project modules $modules meta $meta descriptor [file join $project botlish.json]]
}

# The project's descriptor, or a new one when it has no botlish.json and
# MAYCREATE.
proc pm::install::Descriptor {ctx {mayCreate 0}} {
    set path [dict get $ctx descriptor]
    if {![pm::Exists $path]} {
        if {$mayCreate} {
            return [pm::descriptor::new]
        }
        pm::Fail PROJECT "the project [dict get $ctx project] has no botlish.json"
    }
    return [pm::descriptor::read $path project]
}

# ---------------------------------------------------------------------------
# Locking and recovery

# 1 if the process PID runs, 0 if not, "" when this host cannot tell.
proc pm::install::ProcessAlive {pid} {
    if {![string is digit -strict $pid] || $pid == [pid]} {
        return 0
    }
    if {[file isdirectory /proc/self]} {
        return [file isdirectory /proc/$pid]
    }
    if {$::tcl_platform(platform) eq "unix"} {
        if {[catch {exec kill -0 $pid 2>@1} message]} {
            if {[string match *ermission* $message]} {
                return 1
            }
            return 0
        }
        return 1
    }
    return ""
}

# Locks the project of CTX for an operation, recovering an interrupted one
# first. RECOVER allows recovery when the holder's liveness is unknown.
proc pm::install::Lock {ctx recover} {
    set meta [dict get $ctx meta]
    # The directories this operation creates, which Unlock removes again
    # when the operation leaves them empty (a failed first add).
    variable created {}
    foreach dir [list [dict get $ctx modules] $meta] {
        if {![pm::Exists $dir]} {
            lappend created $dir
        }
    }
    file mkdir $meta
    set lock [file join $meta lock]
    for {set attempt 0} {$attempt < 2} {incr attempt} {
        if {![catch {open $lock {WRONLY CREAT EXCL}} channel]} {
            puts $channel "pid [pid]"
            close $channel
            # A transaction directory without a lock is an interrupted
            # operation's too (its lock removed by hand): never discarded
            # unread.
            if {[catch {Recover $ctx} message options]} {
                Unlock $ctx
                return -options $options $message
            }
            return
        }
        set holder ""
        catch {regexp {pid ([0-9]+)} [pm::ReadBytes $lock] -> holder}
        set alive [ProcessAlive $holder]
        if {$alive eq "1"} {
            pm::Fail BUSY "another package operation (process $holder) is running in [dict get $ctx project]: wait for it to finish"
        }
        if {$alive eq "" && !$recover} {
            pm::Fail LOCKED "a package operation (process $holder) holds [dict get $ctx project]'s lock, and this host cannot tell whether it still runs. If none is running (it was interrupted), run the command again with -recover"
        }
        Recover $ctx
        file delete $lock
    }
    pm::Fail LOCKED "cannot lock [dict get $ctx project] ($lock)"
}

proc pm::install::Unlock {ctx} {
    variable created
    file delete [file join [dict get $ctx meta] lock]
    foreach dir [lreverse $created] {
        if {[pm::Exists $dir] && [file type $dir] eq "directory" && [pm::state::Entries $dir] eq ""} {
            file delete $dir
        }
    }
    set created {}
}

proc pm::install::Txn {ctx} {
    return [file join [dict get $ctx meta] txn]
}

# Finishes what an interrupted operation left in CTX's txn: a committed one
# is cleaned up, any other rolled back. Reports what it did on stderr.
proc pm::install::Recover {ctx} {
    set txn [Txn $ctx]
    if {![pm::Exists $txn]} {
        return
    }
    if {[pm::Exists [file join $txn committed]]} {
        pm::RemoveTree $txn
        puts stderr "note: completed the cleanup of a package operation that was interrupted after it committed"
        return
    }
    if {[pm::Exists [file join $txn journal.json]]} {
        Rollback $ctx
        puts stderr "note: rolled back a package operation that was interrupted: the previous installation is restored"
    } else {
        pm::RemoveTree $txn
        puts stderr "note: removed the staging of a package operation that was interrupted before it changed anything"
    }
}

# Undoes the journal's renames and restores the record and botlish.json.
proc pm::install::Rollback {ctx} {
    set txn [Txn $ctx]
    set modules [dict get $ctx modules]
    set journal [pm::json::decode [pm::ReadBytes [file join $txn journal.json]]]
    set members [pm::json::payload $journal]
    set operations [pm::json::payload [dict get $members operations]]
    file mkdir [file join $txn discard]
    foreach operation [lreverse $operations] {
        set op [pm::json::payload $operation]
        set name [pm::json::payload [dict get $op name]]
        set hasOld [pm::json::payload [dict get $op old]]
        set hasNew [pm::json::payload [dict get $op new]]
        # (A PM-1 journal has no kind: its operations are packages'.)
        set kind package
        if {[dict exists $op kind]} {
            set kind [pm::json::payload [dict get $op kind]]
        }
        lassign [Paths $ctx $kind $name] active staged old
        if {$hasNew && ![pm::Exists $staged] && [pm::Exists $active]} {
            pm::Rename $active [file join $txn discard $kind-$name]
        }
        if {$hasOld && [pm::Exists $old] && ![pm::Exists $active]} {
            file mkdir [file dirname $active]
            pm::Rename $old $active
        }
    }
    TidyViews $ctx
    foreach {key path} [list state [pm::state::Path [dict get $ctx meta]] descriptor [dict get $ctx descriptor] \
            graph [GraphPath $ctx]] {
        # (A journal of an earlier package manager has no graph.)
        if {![dict exists $members $key]} continue
        set saved [pm::json::payload [dict get $members $key]]
        set copy [file join $txn old-$key]
        switch -- $saved {
            unchanged {}
            none { file delete $path }
            file { pm::ReplaceFile $path [pm::ReadBytes $copy] }
        }
    }
    pm::RemoveTree $txn
}

# {ACTIVE STAGED OLD}: where the operation KIND (package or view) on NAME
# puts its active, staged and replaced trees.
proc pm::install::Paths {ctx kind name} {
    set txn [Txn $ctx]
    if {$kind eq "view"} {
        return [list [pm::view::Dir $ctx $name] [file join $txn views $name] [file join $txn oldviews $name]]
    }
    return [list [file join [dict get $ctx modules] $name] [file join $txn new $name] [file join $txn old $name]]
}

# Removes PROJECT/.bot_modules/.targets when it holds nothing: an empty one
# would tell the compiler the packages are prepared for no target at all
# (BOT-MODULES-MILESTONE-1.md, "Target package trees"), and the manager
# never leaves one.
proc pm::install::TidyViews {ctx} {
    set root [pm::view::Root $ctx]
    if {[pm::Exists $root] && [file type $root] eq "directory" && [pm::state::Entries $root] eq ""} {
        file delete $root
    }
}

# ---------------------------------------------------------------------------
# Resolution

# The plan of the project CTX with the descriptor DESCRIPTOR and the current
# record STATE: the application's one dependency graph (pm/graph.tcl's
# Resolve: {application NAMES packages {NAME NODE ...} paths users}), every
# release in it acquired and validated, every lock checked, before anything
# is written. FORCE allows replacing installed packages that changed since
# they were installed (Apply).
proc pm::install::Resolve {ctx descriptor state force} {
    return [pm::graph::Resolve $ctx $descriptor $state]
}

# The normalized target of the link PATH, or "".
proc pm::install::LinkTarget {path} {
    if {![pm::Exists $path] || [file type $path] ne "link"} {
        return ""
    }
    return [file normalize [file join [file dirname $path] [file readlink $path]]]
}

# ---------------------------------------------------------------------------
# Applying a plan

# The path of the project's package graph (surface/modules.tcl's ReadGraph):
# PROJECT/.bot_modules/.graph.
proc pm::install::GraphPath {ctx} {
    return [file join [dict get $ctx modules] .graph]
}

# Applies PLAN to the project CTX whose record is STATE, then writes
# DESCRIPTORBYTES as its botlish.json ("" leaves it as it is). Lines
# describing what changed are returned.
#
# Every package of the graph is installed once, at .bot_modules/NAME, and
# .bot_modules/.graph says which package uses which (the compiler's scopes:
# BOT-MODULES-MILESTONE-1.md, "Package graphs"); no package has a
# .bot_modules of its own. An installation of an earlier package manager
# (its record's nested layout: one copy per dependency path) is replaced as
# a whole.
proc pm::install::Apply {ctx plan state force descriptorBytes {viewSpec {}}} {
    set modules [dict get $ctx modules]
    set packages [dict get $plan packages]
    set application [dict get $plan application]
    set report {}
    set operations {}
    set meta [dict get $ctx meta]
    # (The record read once: a large one's JSON costs.)
    set old [pm::state::readAll $meta]
    set oldViews [dict get $old views]
    set oldLayout [dict get $old layout]
    # The package graph: the manager's own file, never one someone placed.
    set graphPath [GraphPath $ctx]
    if {[pm::Exists $graphPath] && ($oldLayout ne "graph" || [file type $graphPath] ne "file")} {
        pm::Fail MANUAL "$graphPath exists, and the package manager did not make it: a package graph there is yours (the compiler reads it), and it never replaces one. Move it out of .bot_modules and run the command again"
    }
    # What the plan replaces or removes must be the manager's, unchanged.
    set changed {}
    foreach name [lsort [dict keys $packages]] {
        set node [dict get $packages $name]
        if {[dict get $node reuse]} continue
        set active [file join $modules $name]
        if {![dict exists $state $name]} {
            if {[pm::Exists $active]} {
                pm::Fail MANUAL "$active is a package the package manager did not install: it never replaces one. Move it out of .bot_modules (or delete it) and run the command again"
            }
            lappend operations [list $name 0 1]
            continue
        }
        lappend changed {*}[Changed $ctx $name [dict get $state $name] $force]
        lappend operations [list $name [pm::Exists $active] 1]
    }
    foreach name [lsort [dict keys $state]] {
        if {[dict exists $packages $name]} continue
        lappend changed {*}[Changed $ctx $name [dict get $state $name] $force]
        lappend operations [list $name [pm::Exists [file join $modules $name]] 0]
    }
    if {$changed ne ""} {
        set names [lsort -unique [lmap change $changed {lindex $change 0}]]
        set shown [lmap change [lrange $changed 0 9] {lindex $change 1}]
        if {[llength $changed] > 10} {
            lappend shown "... ([llength $changed] changes)"
        }
        if {[llength $names] == 1} {
            set what "the installed package [lindex $names 0] changed since it was installed, and this operation would replace or remove it"
        } else {
            set what "the installed packages [join $names {, }] changed since they were installed, and this operation would replace or remove them"
        }
        pm::Fail MODIFIED "$what:\n  [join $shown "\n  "]\nKeep the changes elsewhere, or pass -force to discard them"
    }
    set newState [dict create]
    set txn [Txn $ctx]
    pm::RemoveTree $txn
    file mkdir [file join $txn new] [file join $txn old]
    try {
        # Stage.
        set sources [dict create]
        foreach name [lsort [dict keys $packages]] {
            set node [dict get $packages $name]
            if {[dict get $node reuse]} {
                dict set newState $name [Record $node]
                dict set sources $name [file join $modules $name]
                continue
            }
            dict set newState $name [Materialize $node [file join $txn new $name]]
            dict set sources $name [file join $txn new $name]
            pm::Fault stage
        }
        # The target views (pm/view.tcl): derived again where their inputs
        # changed, made for the targets asked for, removed when dropped or
        # when no package is target-aware any more.
        lassign [Views $ctx $state $newState $sources $oldViews $viewSpec $application] newViews viewOperations viewLines
        lappend operations {*}$viewOperations
    } on error {message options} {
        pm::RemoveTree $txn
        return -options $options $message
    }
    set graphBytes [encoding convertto utf-8 [pm::graph::OfState $application $newState]]
    set oldGraph ""
    if {[pm::Exists $graphPath]} {
        set oldGraph [pm::ReadBytes $graphPath]
    }
    set newStateBytes [pm::state::encode $newState $newViews $application]
    set statePath [pm::state::Path $meta]
    set notes {}
    if {$oldLayout eq "nested" && [dict size $state] > 0} {
        lappend notes "note: the packages were installed one copy per dependency path by an earlier package manager: they are installed again as the application's one dependency graph, each package once"
    }
    if {$oldGraph ne "" && [encoding convertfrom utf-8 $oldGraph] ne [pm::graph::OfState [dict get $old application] $state]} {
        lappend notes "note: .bot_modules/.graph was changed since it was written; it is derived again (the package graph is the package manager's, never your file)"
    }
    if {$operations eq "" && [pm::Exists $statePath] && [pm::ReadBytes $statePath] eq $newStateBytes
            && $oldGraph eq $graphBytes
            && ($descriptorBytes eq "" || ([pm::Exists [dict get $ctx descriptor]]
                && [pm::ReadBytes [dict get $ctx descriptor]] eq $descriptorBytes))} {
        pm::RemoveTree $txn
        return [concat $notes [Report $plan $state {}] $viewLines]
    }
    Commit $ctx $operations $newStateBytes $descriptorBytes $graphBytes
    return [concat $notes [Report $plan $state $operations] $viewLines]
}

# The views of the new installation: {VIEWS OPERATIONS LINES}, VIEWS its
# record (TARGET -> {derived files links}), OPERATIONS the view renames
# ({TARGET HASOLD HASNEW view}) and LINES the report, after staging every
# view that must be made in the transaction directory. VIEWSPEC: {requested
# {T...} dropped {T...} origins {LIBRARY ORIGIN...}}; APPLICATION the
# application's dependencies (the graph's first line).
proc pm::install::Views {ctx oldState newState sources oldViews viewSpec application} {
    set requested [dict getdef $viewSpec requested {}]
    set dropped [dict getdef $viewSpec dropped {}]
    set origins [dict getdef $viewSpec origins {}]
    set lines {}
    set root [pm::view::Root $ctx]
    if {[dict size $oldViews] == 0 && [pm::Exists $root]} {
        pm::Fail MANUAL "$root exists, and the package manager did not make it: target package trees there are yours (the compiler reads them), and it never replaces them. Move it out of .bot_modules and run the command again"
    }
    foreach target [concat $requested $dropped] {
        if {![pm::target::isTarget $target]} {
            pm::Fail TARGET "\"$target\" is not a compilation target (the compiler's targets: [join [pm::target::names] {, }])"
        }
    }
    set targets [lsort -unique [concat [dict keys $oldViews] $requested]]
    set targets [lmap t $targets {if {$t in $dropped} continue; set t}]
    set artifacts [dict create]
    dict for {name record} $newState {
        if {[dict get $record kind] eq "artifact"} {
            dict set artifacts $name $record
        }
    }
    set aware [pm::view::Aware $artifacts $sources]
    if {!$aware} {
        if {[dict size $oldViews] > 0} {
            lappend lines "note: no installed package is target-specific any more: its target views are removed, and every target compiles from .bot_modules itself"
        } elseif {$requested ne ""} {
            lappend lines "note: no installed package is target-specific: every target compiles from .bot_modules itself, so there is no target view to keep"
        }
        set targets {}
    } elseif {$targets eq "" && $dropped eq ""} {
        set host [pm::target::host]
        set supported [pm::view::Supported $artifacts $sources]
        if {$host eq "" || ($supported ne "*" && $host ni $supported)} {
            pm::Fail TARGET "the packages are target-specific and support [join $supported {, }], and this host's target is [expr {$host eq "" ? "none of the compiler's" : $host}]: prepare one with -target TARGET"
        }
        set targets [list $host]
    }
    # Manual packages (installed by hand: not the old or the new record's).
    set manual [pm::view::Manual $ctx [dict merge $oldState $newState]]
    set views [dict create]
    set operations {}
    foreach target $targets {
        set dir [pm::view::Dir $ctx $target]
        set derived [pm::view::Derived $target $newState $origins $manual $application]
        if {[dict exists $oldViews $target] && [dict get $oldViews $target derived] eq $derived} {
            set changes [pm::state::ViewChanges $dir [dict get $oldViews $target] .bot_modules/.targets/$target]
            if {$changes eq ""} {
                dict set views $target [dict get $oldViews $target]
                lappend lines "view $target: unchanged"
                continue
            }
            lappend lines "note: the view of $target was changed ([lindex $changes 0][expr {[llength $changes] > 1 ? ", ..." : ""}]); it is derived again (a view holds the package manager's copies, never your files)"
        }
        set staged [file join [Txn $ctx] views $target]
        file mkdir [file dirname $staged]
        set built [pm::view::Build $ctx $newState $sources $target $origins $manual $staged $application]
        dict set views $target [dict get $built record]
        set plan [dict get $built plan]
        lappend operations [list $target [pm::Exists $dir] 1 view]
        set libs [llength [dict get $plan libraries]]
        lappend lines "view $target: [expr {[dict exists $oldViews $target] ? "derived again" : "derived"}] ([dict size [dict get $built record files]] files, $libs native librar[expr {$libs == 1 ? "y" : "ies"}])"
        foreach note [dict get $plan notes] {
            lappend lines "note: $target: $note"
        }
    }
    dict for {target view} $oldViews {
        if {![dict exists $views $target]} {
            lappend operations [list $target [pm::Exists [pm::view::Dir $ctx $target]] 0 view]
            lappend lines "view $target: removed"
        }
    }
    return [list $views $operations $lines]
}

# How the installed package NAME (its record RECORD) changed since it was
# installed: {NAME CHANGE} pairs, none with FORCE (its changes are then
# discarded).
proc pm::install::Changed {ctx name record force} {
    set active [file join [dict get $ctx modules] $name]
    if {$force || ![pm::Exists $active]} {
        return {}
    }
    return [lmap change [pm::state::Changes $active $record .bot_modules/$name] {list $name $change}]
}

# The record of a reused NODE (its own record, or for an editable one the
# link it is), with the versions it uses.
proc pm::install::Record {node} {
    if {[dict get $node kind] eq "editable"} {
        return [dict create kind editable version [dict get $node version] directory [dict get $node directory] \
            uses [dict get $node uses]]
    }
    return [dict get $node record]
}

# Writes NODE at DEST (which does not exist): an artifact's files; an
# editable one's link. Its record.
proc pm::install::Materialize {node dest} {
    if {[dict get $node kind] eq "editable"} {
        file link -symbolic $dest [dict get $node target]
        return [Record $node]
    }
    set artifact [dict get $node artifact]
    file mkdir $dest
    set files [dict get $artifact files]
    foreach {path bytes} $files {
        set target [file join $dest {*}[split $path /]]
        file mkdir [file dirname $target]
        pm::WriteNew $target $bytes
    }
    pm::Fault extract
    set record [pm::state::ArtifactNode [dict get $artifact version] [dict get $artifact digest] $files {}]
    dict set record uses [dict get $node uses]
    return $record
}

# The commit: OPERATIONS ({NAME HASOLD HASNEW} each) move the old
# installations out and the staged ones in; the package graph is replaced
# by GRAPHBYTES ("" removes it), the record and botlish.json are replaced.
# A failure rolls back.
proc pm::install::Commit {ctx operations stateBytes descriptorBytes graphBytes} {
    set txn [Txn $ctx]
    set modules [dict get $ctx modules]
    set statePath [pm::state::Path [dict get $ctx meta]]
    set descriptorPath [dict get $ctx descriptor]
    set graphPath [GraphPath $ctx]
    set oldGraph ""
    if {[pm::Exists $graphPath]} {
        set oldGraph [pm::ReadBytes $graphPath]
    }
    # The journal: what the renames are, and how to restore the record,
    # botlish.json and the package graph.
    set saved [dict create]
    foreach {key path changes} [list state $statePath 1 descriptor $descriptorPath [expr {$descriptorBytes ne ""}] \
            graph $graphPath [expr {$oldGraph ne $graphBytes}]] {
        if {!$changes} {
            dict set saved $key unchanged
        } elseif {[pm::Exists $path]} {
            pm::WriteNew [file join $txn old-$key] [pm::ReadBytes $path]
            dict set saved $key file
        } else {
            dict set saved $key none
        }
    }
    set ops [lmap op $operations {
        lassign $op name hasOld hasNew kind
        if {$kind eq ""} { set kind package }
        list obj [list kind [list str $kind] name [list str $name] old [list bool $hasOld] new [list bool $hasNew]]
    }]
    set journal [list obj [list journal {num 1} operations [list arr $ops] \
        state [list str [dict get $saved state]] descriptor [list str [dict get $saved descriptor]] \
        graph [list str [dict get $saved graph]]]]
    pm::ReplaceFile [file join $txn journal.json] [pm::json::encode $journal]
    try {
        pm::Fault journal
        file mkdir $modules
        set step 0
        foreach op $operations {
            lassign $op name hasOld hasNew kind
            if {$kind eq ""} { set kind package }
            lassign [Paths $ctx $kind $name] active staged old
            set suffix [expr {$kind eq "view" ? "-view" : ""}]
            if {$hasOld} {
                file mkdir [file dirname $old]
                pm::Rename $active $old
                pm::Fault commit${suffix}-old
            }
            if {$hasNew} {
                file mkdir [file dirname $active]
                pm::Rename $staged $active
                pm::Fault commit${suffix}-new
            }
            incr step
        }
        TidyViews $ctx
        if {$oldGraph ne $graphBytes} {
            if {$graphBytes eq ""} {
                file delete -- $graphPath
            } else {
                pm::ReplaceFile $graphPath $graphBytes
            }
            pm::Fault graph-written
        }
        pm::ReplaceFile $statePath $stateBytes
        pm::Fault state-written
        if {$descriptorBytes ne ""} {
            pm::ReplaceFile $descriptorPath $descriptorBytes
            pm::Fault descriptor-written
        }
        pm::WriteNew [file join $txn committed] ""
    } on error {message options} {
        if {[catch {Rollback $ctx} rollbackError]} {
            pm::Fail ROLLBACK "$message; then rolling back failed too ($rollbackError): the next package command rolls back what is left in [Txn $ctx]"
        }
        return -options $options "$message (rolled back: the previous installation is unchanged)"
    }
    pm::Fault committed
    pm::RemoveTree $txn
}

# Lines describing the outcome of PLAN over the previous record STATE: one
# per package of the graph, in name order, with the scopes that share it.
proc pm::install::Report {plan state operations} {
    set lines {}
    dict for {name node} [lsort -stride 2 [dict get $plan packages]] {
        lappend lines [Describe $node [dict getdef $state $name ""] [dict get $plan users $name]]
    }
    foreach op $operations {
        lassign $op name hasOld hasNew kind
        if {!$hasNew && $kind ne "view"} {
            lappend lines "removed $name"
        }
    }
    return $lines
}

# The line of NODE, installed over RECORD, used by USERS ("" the
# application, else package names).
proc pm::install::Describe {node record users} {
    set name [dict get $node name]
    set version [dict get $node version]
    set shared ""
    if {$users ne [list ""]} {
        set shown {}
        foreach user $users {
            if {$user eq ""} {
                lappend shown "the application"
            } else {
                lappend shown $user
            }
        }
        set shared ", used by [join $shown {, }]"
    }
    if {[dict get $node kind] eq "editable"} {
        if {[dict get $node reuse]} {
            return "$name $version (editable [dict get $node directory]): unchanged$shared"
        }
        return "$name $version (editable [dict get $node directory]): linked$shared"
    }
    if {[dict get $node reuse]} {
        return "$name $version: unchanged$shared"
    }
    set what installed
    if {$record ne "" && [dict get $record kind] eq "artifact"} {
        if {[dict get $record version] ne $version} {
            set what "installed (was [dict get $record version])"
        } elseif {[dict exists $record uses]} {
            set what reinstalled
        }
    }
    return "$name $version (sha256 [pm::Short [dict get $node digest]]): $what$shared"
}

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
    foreach {key path} [list state [pm::state::Path [dict get $ctx meta]] descriptor [dict get $ctx descriptor]] {
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
# record STATE: a dict NAME -> NODE of every direct dependency, where NODE is
#
#   {kind artifact name N version V digest D artifact A children {NAME NODE ...}
#    reuse 0}                    to be extracted from the artifact A
#   {kind artifact ... reuse 1 record R}    already installed exactly so
#                                            (R its record), kept as it is
#   {kind editable name N version V directory P target T reuse 0|1}
#
# Every artifact is acquired and validated, every lock checked, before
# anything is written. FORCE allows replacing installed packages that
# changed since they were installed.
proc pm::install::Resolve {ctx descriptor state force} {
    set plan [dict create]
    set count 0
    foreach name [lsort [dict keys [dict get $descriptor dependencies]]] {
        dict set plan $name [ResolveDirect $ctx $descriptor $state $name count]
    }
    return $plan
}

proc pm::install::ResolveDirect {ctx descriptor state name countVar} {
    upvar 1 $countVar count
    set project [dict get $ctx project]
    set request [dict get $descriptor dependencies $name]
    set record [dict getdef $state $name ""]
    set installed [file join [dict get $ctx modules] $name]
    set source [dict getdef [dict get $descriptor sources] $name ""]
    if {$source ne "" && [dict get $source kind] eq "directory"} {
        set editable [pm::catalog::Editable $project $name $source]
        if {![pm::version::satisfies [dict get $editable version] $request]} {
            pm::Fail REQUEST "dependency $name: the editable directory [dict get $source path] is version [dict get $editable version], which the request \"$request\" does not accept"
        }
        set reuse [expr {$record ne "" && [dict get $record kind] eq "editable"
            && [dict get $record directory] eq [dict get $source path]
            && [LinkTarget $installed] eq [dict get $editable target]}]
        incr count
        return [dict create kind editable name $name version [dict get $editable version] \
            directory [dict get $source path] target [dict get $editable target] reuse $reuse \
            descriptor [dict get $editable descriptor]]
    }
    if {![dict exists $descriptor lock $name]} {
        pm::Fail LOCK "dependency $name (request \"$request\") has no lock in botlish.json: install installs exact releases only. Run update $name to choose one"
    }
    set version [dict get $descriptor lock $name]
    set digest ""
    if {$source ne ""} {
        set digest [dict get $source sha256]
    }
    if {[Reusable $record $version $digest $installed]} {
        incr count [Count $record]
        return [dict create kind artifact name $name version $version reuse 1 record $record]
    }
    if {$source ne ""} {
        set artifact [pm::catalog::ArchiveSource $project $name $source]
        if {[dict get $artifact version] ne $version} {
            pm::Fail LOCK "dependency $name: the archive [dict get $source path] is version [dict get $artifact version], and the lock says $version"
        }
    } else {
        set artifact [pm::catalog::Find $name $version {}]
    }
    return [ArtifactNode $artifact [list $name $version] $record $installed count]
}

# The node of ARTIFACT at the dependency path CHAIN (NAME VERSION pairs, its
# own last), its children resolved from the repositories; RECORD and
# INSTALLED the record and directory of what is installed at its place now.
proc pm::install::ArtifactNode {artifact chain record installed countVar} {
    upvar 1 $countVar count
    variable maxDepth
    variable maxInstances
    if {[incr count] > $maxInstances} {
        pm::Fail LIMIT "the dependency tree has more than $maxInstances package instances"
    }
    if {[llength $chain] / 2 > $maxDepth} {
        pm::Fail LIMIT "[pm::catalog::Chain $chain]: the dependency tree is deeper than $maxDepth levels"
    }
    set descriptor [dict get $artifact descriptor]
    set children [dict create]
    foreach dep [lsort [dict keys [dict get $descriptor dependencies]]] {
        set version [dict get $descriptor lock $dep]
        foreach {ancestor ancestorVersion} $chain {
            if {$ancestor eq $dep && $ancestorVersion eq $version} {
                pm::Fail CYCLE "[pm::catalog::Chain $chain] -> $dep $version: a dependency cycle (a package cannot contain itself)"
            }
        }
        set childRecord ""
        if {$record ne "" && [dict get $record kind] eq "artifact"} {
            set childRecord [dict getdef [dict get $record children] $dep ""]
        }
        set childInstalled [file join $installed .bot_modules $dep]
        if {[Reusable $childRecord $version "" $childInstalled]} {
            incr count [Count $childRecord]
            dict set children $dep [dict create kind artifact name $dep version $version reuse 1 \
                record $childRecord installed $childInstalled]
            continue
        }
        set child [pm::catalog::Find $dep $version $chain]
        dict set children $dep [ArtifactNode $child [concat $chain [list $dep $version]] $childRecord $childInstalled count]
    }
    return [dict create kind artifact name [dict get $artifact name] version [dict get $artifact version] \
        digest [dict get $artifact digest] artifact $artifact children $children reuse 0]
}

# 1 when the RECORD at INSTALLED is the artifact node VERSION (with the
# digest DIGEST, when one is required) exactly as it was installed.
proc pm::install::Reusable {record version digest installed} {
    if {$record eq "" || [dict get $record kind] ne "artifact" || [dict get $record version] ne $version} {
        return 0
    }
    if {$digest ne "" && [dict get $record sha256] ne $digest} {
        return 0
    }
    return [expr {[pm::state::Changes $installed $record x] eq ""}]
}

proc pm::install::Count {record} {
    set n 1
    if {[dict get $record kind] eq "artifact"} {
        dict for {- child} [dict get $record children] {
            incr n [Count $child]
        }
    }
    return $n
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

# Applies PLAN to the project CTX whose record is STATE, then writes
# DESCRIPTORBYTES as its botlish.json ("" leaves it as it is). Lines
# describing what changed are returned.
proc pm::install::Apply {ctx plan state force descriptorBytes {viewSpec {}}} {
    set modules [dict get $ctx modules]
    set report {}
    set operations {}
    set oldViews [pm::state::views [dict get $ctx meta]]
    # What the plan replaces or removes must be the manager's, unchanged.
    foreach name [lsort [dict keys $plan]] {
        set node [dict get $plan $name]
        if {[dict get $node reuse]} continue
        set active [file join $modules $name]
        if {![dict exists $state $name]} {
            if {[pm::Exists $active]} {
                pm::Fail MANUAL "$active is a package the package manager did not install: it never replaces one. Move it out of .bot_modules (or delete it) and run the command again"
            }
            lappend operations [list $name 0 1]
            continue
        }
        CheckUnchanged $ctx $name [dict get $state $name] $force
        lappend operations [list $name [pm::Exists $active] 1]
    }
    foreach name [lsort [dict keys $state]] {
        if {[dict exists $plan $name]} continue
        CheckUnchanged $ctx $name [dict get $state $name] $force
        lappend operations [list $name [pm::Exists [file join $modules $name]] 0]
    }
    set newState [dict create]
    set txn [Txn $ctx]
    pm::RemoveTree $txn
    file mkdir [file join $txn new] [file join $txn old]
    try {
        # Stage.
        set sources [dict create]
        foreach name [lsort [dict keys $plan]] {
            set node [dict get $plan $name]
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
        lassign [Views $ctx $state $newState $sources $oldViews $viewSpec] newViews viewOperations viewLines
        lappend operations {*}$viewOperations
    } on error {message options} {
        pm::RemoveTree $txn
        return -options $options $message
    }
    set newStateBytes [pm::state::encode $newState $newViews]
    set statePath [pm::state::Path [dict get $ctx meta]]
    if {$operations eq "" && [pm::Exists $statePath] && [pm::ReadBytes $statePath] eq $newStateBytes
            && ($descriptorBytes eq "" || ([pm::Exists [dict get $ctx descriptor]]
                && [pm::ReadBytes [dict get $ctx descriptor]] eq $descriptorBytes))} {
        pm::RemoveTree $txn
        return [concat [Report $plan $state {}] $viewLines]
    }
    Commit $ctx $operations $newStateBytes $descriptorBytes
    return [concat [Report $plan $state $operations] $viewLines]
}

# The views of the new installation: {VIEWS OPERATIONS LINES}, VIEWS its
# record (TARGET -> {derived files links}), OPERATIONS the view renames
# ({TARGET HASOLD HASNEW view}) and LINES the report, after staging every
# view that must be made in the transaction directory. VIEWSPEC: {requested
# {T...} dropped {T...} origins {LIBRARY ORIGIN...}}.
proc pm::install::Views {ctx oldState newState sources oldViews viewSpec} {
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
        set derived [pm::view::Derived $target $newState $origins $manual]
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
        set built [pm::view::Build $ctx $newState $sources $target $origins $manual $staged]
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

proc pm::install::CheckUnchanged {ctx name record force} {
    set active [file join [dict get $ctx modules] $name]
    if {!$force && [pm::Exists $active]} {
        set changes [pm::state::Changes $active $record .bot_modules/$name]
        if {$changes ne ""} {
            set shown [lrange $changes 0 9]
            if {[llength $changes] > 10} {
                lappend shown "... ([llength $changes] changes)"
            }
            pm::Fail MODIFIED "the installed package $name changed since it was installed, and this operation would replace or remove it:\n  [join $shown "\n  "]\nKeep the changes elsewhere, or pass -force to discard them"
        }
    }
}

# The record of a reused NODE (its own record, or for an editable one the
# link it is).
proc pm::install::Record {node} {
    if {[dict get $node kind] eq "editable"} {
        return [dict create kind editable version [dict get $node version] directory [dict get $node directory]]
    }
    return [dict get $node record]
}

# Writes NODE at DEST (which does not exist): an artifact's files, then its
# children under DEST/.bot_modules; a reused node's installed tree, copied;
# an editable one's link. Its record.
proc pm::install::Materialize {node dest} {
    switch -- [dict get $node kind] {
        editable {
            file link -symbolic $dest [dict get $node target]
            return [Record $node]
        }
    }
    if {[dict get $node reuse]} {
        file copy -- [dict get $node installed] $dest
        return [dict get $node record]
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
    set children [dict create]
    if {[dict get $node children] ne ""} {
        file mkdir [file join $dest .bot_modules]
        dict for {name child} [dict get $node children] {
            dict set children $name [Materialize $child [file join $dest .bot_modules $name]]
        }
    }
    return [pm::state::ArtifactNode [dict get $artifact version] [dict get $artifact digest] $files $children]
}

# The commit: OPERATIONS ({NAME HASOLD HASNEW} each) move the old
# installations out and the staged ones in; the record and botlish.json are
# replaced. A failure rolls back.
proc pm::install::Commit {ctx operations stateBytes descriptorBytes} {
    set txn [Txn $ctx]
    set modules [dict get $ctx modules]
    set statePath [pm::state::Path [dict get $ctx meta]]
    set descriptorPath [dict get $ctx descriptor]
    # The journal: what the renames are, and how to restore the record and
    # botlish.json.
    set saved [dict create]
    foreach {key path changes} [list state $statePath 1 descriptor $descriptorPath [expr {$descriptorBytes ne ""}]] {
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
        state [list str [dict get $saved state]] descriptor [list str [dict get $saved descriptor]]]]
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

# Lines describing the outcome of PLAN over the previous record STATE.
proc pm::install::Report {plan state operations} {
    set lines {}
    foreach name [lsort [dict keys $plan]] {
        Describe [dict get $plan $name] [dict getdef $state $name ""] "" lines
    }
    foreach op $operations {
        lassign $op name hasOld hasNew kind
        if {!$hasNew && $kind ne "view"} {
            lappend lines "removed $name"
        }
    }
    return $lines
}

proc pm::install::Describe {node record indent linesVar} {
    upvar 1 $linesVar lines
    set name [dict get $node name]
    set version [dict get $node version]
    if {[dict get $node kind] eq "editable"} {
        if {[dict get $node reuse]} {
            lappend lines "${indent}$name $version (editable [dict get $node directory]): unchanged"
        } else {
            lappend lines "${indent}$name $version (editable [dict get $node directory]): linked"
        }
        return
    }
    if {[dict get $node reuse]} {
        lappend lines "${indent}$name $version: unchanged"
        return
    }
    set what installed
    if {$record ne "" && [dict get $record kind] eq "artifact"} {
        if {[dict get $record version] ne $version} {
            set what "installed (was [dict get $record version])"
        } else {
            set what reinstalled
        }
    }
    lappend lines "${indent}$name $version (sha256 [pm::Short [dict get $node digest]]): $what"
    dict for {child childNode} [dict get $node children] {
        set childRecord ""
        if {$record ne "" && [dict get $record kind] eq "artifact"} {
            set childRecord [dict getdef [dict get $record children] $child ""]
        }
        Describe $childNode $childRecord "$indent  " lines
    }
}

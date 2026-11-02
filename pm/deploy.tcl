# deploy.tcl -- placing a target's bundled shared libraries where an
# application's executable loads them (PACKAGE-MANAGER-MILESTONE-2.md,
# "Native deployment").
#
#   pm::deploy::Apply OUT PLACING FORCE    PLACING: RELATIVE -> SOURCE FILE
#
# A deployment is the package manager's files in a directory the
# application builder names: each placed file is recorded, with its
# SHA-256, in OUT/.botlish-deploy.json, and only recorded files are ever
# replaced or removed (a file of OUT the manager did not place is the
# builder's: MANUAL, unless -force; a placed file that changed since:
# MODIFIED, unless -force). The operation is a transaction of its own, in
# OUT/.botlish-deploy.txn: the new files staged, the replaced ones moved
# aside, the record replaced, a commit marker; a failure rolls back, and a
# deployment interrupted is rolled back (or, committed, finished) by the
# next one. Placed files are regular files, mode 0644 on Unix: no loader of
# a target the manager deploys for needs an executable bit on a library,
# and the archive's modes are never carried (an artifact has none).

namespace eval pm::deploy {}

proc pm::deploy::RecordPath {out} {
    return [file join $out .botlish-deploy.json]
}

proc pm::deploy::Txn {out} {
    return [file join $out .botlish-deploy.txn]
}

# The deployment record of OUT: RELATIVE -> SHA-256.
proc pm::deploy::Read {out} {
    set path [RecordPath $out]
    set files [dict create]
    if {![pm::Exists $path]} {
        return $files
    }
    if {[catch {
        set members [pm::json::payload [pm::json::decode [pm::ReadBytes $path]]]
        if {[dict keys $members] ne {deploy files} || [dict get $members deploy] ne {num 1}} {
            error "not a deployment record"
        }
        foreach {relative digest} [pm::json::payload [dict get $members files]] {
            if {[pm::archive::pathProblem $relative] ne "" || ![regexp {^[0-9a-f]{64}$} [pm::json::payload $digest]]} {
                error "the entry $relative"
            }
            dict set files $relative [pm::json::payload $digest]
        }
    } message]} {
        pm::Fail STATE "the deployment record $path is damaged ($message)"
    }
    return $files
}

proc pm::deploy::Encode {files} {
    set object {}
    foreach relative [lsort [dict keys $files]] {
        lappend object $relative [list str [dict get $files $relative]]
    }
    return [pm::json::encode [list obj [list deploy {num 1} files [list obj $object]]]]
}

proc pm::deploy::Recover {out} {
    set txn [Txn $out]
    if {![pm::Exists $txn]} return
    if {[pm::Exists [file join $txn committed]]} {
        pm::RemoveTree $txn
        puts stderr "note: completed the cleanup of a deployment that was interrupted after it committed"
        return
    }
    if {[pm::Exists [file join $txn journal.json]]} {
        Rollback $out
        puts stderr "note: rolled back a deployment that was interrupted: the previous deployment is restored"
    } else {
        pm::RemoveTree $txn
    }
}

proc pm::deploy::Rollback {out} {
    set txn [Txn $out]
    set journal [pm::json::payload [pm::json::decode [pm::ReadBytes [file join $txn journal.json]]]]
    foreach item [pm::json::payload [dict get $journal new]] {
        set relative [pm::json::payload $item]
        set dest [file join $out {*}[split $relative /]]
        if {![pm::Exists [file join $txn new {*}[split $relative /]]] && [pm::Exists $dest]} {
            file delete -- $dest
        }
    }
    foreach item [pm::json::payload [dict get $journal old]] {
        set relative [pm::json::payload $item]
        set moved [file join $txn old {*}[split $relative /]]
        set dest [file join $out {*}[split $relative /]]
        if {[pm::Exists $moved] && ![pm::Exists $dest]} {
            file mkdir [file dirname $dest]
            pm::Rename $moved $dest
        }
    }
    if {[pm::Exists [file join $txn old-record]]} {
        pm::ReplaceFile [RecordPath $out] [pm::ReadBytes [file join $txn old-record]]
    } elseif {[pm::json::payload [dict get $journal record]] eq "none"} {
        file delete -- [RecordPath $out]
    }
    pm::RemoveTree $txn
}

proc pm::deploy::Apply {out placing force} {
    Recover $out
    set old [Read $out]
    set txn [Txn $out]
    # What would be replaced must be the manager's, unchanged.
    foreach relative [lsort -unique [concat [dict keys $placing] [dict keys $old]]] {
        set dest [file join $out {*}[split $relative /]]
        if {![pm::Exists $dest]} continue
        if {[file type $dest] ne "file"} {
            pm::Fail MANUAL "$dest is a [file type $dest]: a deployment places regular files only, and never replaces anything else"
        }
        if {![dict exists $old $relative]} {
            if {!$force} {
                pm::Fail MANUAL "$dest exists, and the package manager did not place it: it never replaces a file it did not deploy (move it, or pass -force)"
            }
        } elseif {!$force && [pm::sha256::file $dest] ne [dict get $old $relative]} {
            pm::Fail MODIFIED "$dest changed since it was deployed: pass -force to replace it"
        }
    }
    set new [dict create]
    pm::RemoveTree $txn
    file mkdir [file join $txn new] [file join $txn old]
    try {
        dict for {relative source} $placing {
            set bytes [pm::ReadBytes $source]
            set staged [file join $txn new {*}[split $relative /]]
            file mkdir [file dirname $staged]
            pm::WriteNew $staged $bytes
            if {$::tcl_platform(platform) eq "unix"} {
                file attributes $staged -permissions 0644
            }
            dict set new $relative [pm::sha256::hex $bytes]
        }
        pm::Fault deploy-staged
    } on error {message options} {
        pm::RemoveTree $txn
        return -options $options $message
    }
    set moved [lmap relative [lsort [dict keys $old]] {
        if {![pm::Exists [file join $out {*}[split $relative /]]]} continue
        set relative
    }]
    foreach relative [dict keys $placing] {
        if {$relative ni $moved && [pm::Exists [file join $out {*}[split $relative /]]]} {
            lappend moved $relative
        }
    }
    set recordPath [RecordPath $out]
    if {[pm::Exists $recordPath]} {
        pm::WriteNew [file join $txn old-record] [pm::ReadBytes $recordPath]
    }
    set journal [list obj [list journal {num 1} \
        new [list arr [lmap r [lsort [dict keys $placing]] {list str $r}]] \
        old [list arr [lmap r $moved {list str $r}]] \
        record [list str [expr {[pm::Exists $recordPath] ? "file" : "none"}]]]]
    pm::ReplaceFile [file join $txn journal.json] [pm::json::encode $journal]
    try {
        foreach relative $moved {
            set aside [file join $txn old {*}[split $relative /]]
            file mkdir [file dirname $aside]
            pm::Rename [file join $out {*}[split $relative /]] $aside
            pm::Fault deploy-old
        }
        foreach relative [lsort [dict keys $placing]] {
            set dest [file join $out {*}[split $relative /]]
            file mkdir [file dirname $dest]
            pm::Rename [file join $txn new {*}[split $relative /]] $dest
            pm::Fault deploy-new
        }
        pm::ReplaceFile $recordPath [Encode $new]
        pm::Fault deploy-record
        pm::WriteNew [file join $txn committed] ""
    } on error {message options} {
        if {[catch {Rollback $out} rollbackError]} {
            pm::Fail ROLLBACK "$message; then rolling back failed too ($rollbackError): the next deployment rolls back what is left in $txn"
        }
        return -options $options "$message (rolled back: the previous deployment is unchanged)"
    }
    pm::RemoveTree $txn
}

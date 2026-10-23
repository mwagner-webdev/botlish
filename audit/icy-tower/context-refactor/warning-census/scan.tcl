# scan.tcl -- applies the warning candidate's measuring instrument,
# audit/icy-tower/context-refactor/tools/escape-candidates.tcl, to a list of
# compilation units (units-a.tcl's output), and records with each unit the
# module facts a classification needs: every module's directness status and
# what its public surface exposes (C addresses, native views and edits).
#
#   tclsh9.0 audit/icy-tower/context-refactor/warning-census/scan.tcl \
#       UNITS.tsv ?-shard I/N? > RAW.tsv
#
# The instrument is sourced, not copied: its escape::Program compiles each
# unit (front end only, -warnings off, no cache, the unit's -target) and
# returns its sites and statuses. An execution trace on
# surface::readProgramFile keeps the HIR that call built, from which the
# module facts are read (hir::activate first: COMPILATION-ISOLATION.md).
# Nothing is renamed or redefined. -shard I/N scans every Nth unit from the
# Ith (1-based), for sequential runs split across processes.
#
# Output, tab-separated, paths mapped back to the repository by the unit's
# MAP (REV:PATH for a baseline copy) and made repository-relative:
#
#   UNIT  ID  ok|error  SECONDS  ERRORCODE  MESSAGE(first line)
#   SITE  ID  BUCKET  LOCATION  FROM  TO  RULES  WHAT
#   MOD   ID  NS  STATUS  FILE  CONTEXTS  FUNCTIONS  PTR-FUNCTIONS
#         VIEW-FUNCTIONS  PTR-STRUCTS  VIEW-STRUCTS  EXTERNS  PTR-EXTERNS
#
# A MOD line per module (and the entry program, NS "entry") the unit
# compiled. CONTEXTS: the context structs and context traits the module
# declares. FUNCTIONS: its top-level Botlish functions (a module has no
# private members: every one is public). PTR-FUNCTIONS / VIEW-FUNCTIONS:
# those whose parameter or result types hold a C address / a native view or
# edit (escape::Holds, modes carry and view, the opaque-struct stop of the
# view search included), as NAME(r) for a result, NAME(p) for a parameter.
# PTR-STRUCTS: its struct types holding a C address, NAME[opaque] for an
# opaque one; VIEW-STRUCTS: those with a field holding a native view or
# edit (a nested opaque struct stopping the search). EXTERNS / PTR-EXTERNS: its `extern c fn` declarations, and
# those with a pointer parameter or result.

set censusHere [file dirname [file normalize [info script]]]
set censusRoot [file normalize [file join $censusHere .. .. .. ..]]

set censusArgs $argv
set argv {}
set argc 0
# Defines escape::* (and, with no files, prints an empty "totals:" line).
source [file join $censusHere .. tools escape-candidates.tcl]

namespace eval census {
    variable hir ""
}
proc census::Capture {command code result op} {
    variable hir
    if {$code == 0} {
        set hir $result
    }
}
trace add execution surface::readProgramFile leave ::census::Capture

proc census::Map {map path} {
    set best ""
    foreach {from to} $map {
        if {$path eq $from} {
            return $to
        }
        if {[string first $from/ $path] == 0 && [string length $from] > [string length $best]} {
            set best $from
        }
    }
    if {$best ne ""} {
        set to [dict get $map $best]
        return $to[string range $path [string length $best] end]
    }
    set root $::censusRoot
    if {[string first $root/ $path] == 0} {
        return [string range $path [string length $root/] end]
    }
    return $path
}

# LOCATION "PATH:LINE:COL" with PATH mapped.
proc census::MapLocation {map location} {
    if {[regexp {^(.*):(\d+):(\d+)$} $location -> path line column]} {
        return "[Map $map $path]:$line:$column"
    }
    return $location
}

# Which of carry (C address) and view (native view or edit) TYPES hold.
proc census::Kinds {types} {
    set kinds {}
    foreach t $types {
        if {$t eq ""} continue
        if {[escape::Holds $t carry]} { lappend kinds ptr }
        if {[escape::Holds $t view]} { lappend kinds view }
    }
    return [lsort -unique $kinds]
}

proc census::Modules {hir id map entryFile} {
    hir::activate $hir
    set lines {}
    set status [dict create]
    if {[dict exists $hir direct units]} {
        dict for {ns u} [dict get $hir direct units] {
            dict set status $ns [dict get $u status]
        }
    }
    # Context declarations per namespace.
    set contexts [dict create]
    set structs [dict create]
    set viewStructs [dict create]
    foreach entry [hir::sourceTypes $hir] {
        if {![dict exists $entry id]} continue
        set eid [dict get $entry id]
        set i [string last :: $eid]
        set ns [expr {$i < 0 ? "" : [string range $eid 0 [expr {$i - 1}]]}]
        if {[dict exists $entry context] && [dict get $entry context]} {
            dict lappend contexts $ns [string range $eid [expr {$i < 0 ? 0 : $i + 2}] end]
        }
        if {[dict getdef $entry kind ""] eq "struct" && [hir::structs::declared $eid]
                && [escape::Holds [list nstruct $eid] carry]} {
            set name [string range $eid [expr {$i < 0 ? 0 : $i + 2}] end]
            if {[hir::structs::isOpaque $eid]} { append name {[opaque]} }
            dict lappend structs $ns $name
        }
        if {[dict getdef $entry kind ""] eq "struct" && [hir::structs::declared $eid]} {
            set holds 0
            foreach {field t} [hir::structs::fieldTypes $eid] {
                if {[escape::Holds $t view]} { set holds 1 }
            }
            if {$holds} {
                set name [string range $eid [expr {$i < 0 ? 0 : $i + 2}] end]
                if {[hir::structs::isOpaque $eid]} { append name {[opaque]} }
                dict lappend viewStructs $ns $name
            }
        }
    }
    # Externs per namespace.
    set externs [dict create]
    set ptrExterns [dict create]
    dict for {key record} [hir::foreign::declarations $hir] {
        set ns [dict get $record namespace]
        dict incr externs $ns
        set native [dict get $record native]
        set types {}
        if {[core::native::exists $native]} {
            set foreign [dict getdef [core::native::metadata $native] foreign {}]
            foreach p [dict getdef $foreign params {}] {
                lappend types [dict getdef $p type ""]
            }
            set r [dict getdef $foreign result {}]
            if {[llength $r] % 2 == 0 && [dict exists $r type]} {
                lappend types [dict get $r type]
            }
        }
        if {"ptr" in [Kinds $types]} {
            dict lappend ptrExterns $ns [dict get $record name]
        }
    }
    set scopes [dict getdef $hir modules {}]
    foreach {ns scope} [concat [list entry ""] $scopes] {
        set file ""
        set bindings {}
        if {$ns eq "entry"} {
            set file [Map $map $entryFile]
            if {[dict exists $hir top]} {
                set top [dict get $hir top]
                if {[dict exists $hir scopes $top bindings]} {
                    set bindings [dict get $hir scopes $top bindings]
                }
            }
        } else {
            set origin [dict get $hir scopes $scope origin]
            if {[dict exists $origin file]} {
                set file [Map $map [dict get $hir files [dict get $origin file] path]]
            }
            set bindings [dict get $hir scopes $scope bindings]
        }
        set functions 0
        set ptrFns {}
        set viewFns {}
        foreach b $bindings {
            set by [dict get $hir bindings $b declaredBy]
            if {$by eq "" || ![dict exists $hir exprs $by value]} continue
            set v [dict get $hir exprs $by value]
            if {$v eq "" || [dict get $hir exprs $v kind] ne "block"} continue
            incr functions
            set type [hir::typeOf $hir $v]
            set name [hir::semantic::CallableName $hir $v]
            set result [lindex $type 3]
            set params [dict getdef [lindex $type 4] args {}]
            set marks {}
            foreach {kinds where} [list [Kinds [list $result]] r [Kinds $params] p] {
                foreach k $kinds { dict lappend marks $k $where }
            }
            if {[dict exists $marks ptr]} { lappend ptrFns "$name\([join [dict get $marks ptr] ,]\)" }
            if {[dict exists $marks view]} { lappend viewFns "$name\([join [dict get $marks view] ,]\)" }
        }
        set key [expr {$ns eq "entry" ? "" : $ns}]
        set st [dict getdef $status $key ""]
        lappend lines [join [list MOD $id $ns $st $file \
            [join [dict getdef $contexts $key {}] ,] $functions [join $ptrFns " "] [join $viewFns " "] \
            [join [dict getdef $structs $key {}] " "] [join [dict getdef $viewStructs $key {}] " "] \
            [dict getdef $externs $key 0] \
            [llength [dict getdef $ptrExterns $key {}]]] \t]
    }
    return $lines
}

set unitsFile [lindex $censusArgs 0]
set shard 1/1
foreach {option value} [lrange $censusArgs 1 end] {
    switch -- $option {
        -shard { set shard $value }
        default { error "unknown option $option" }
    }
}
lassign [split $shard /] shardI shardN
set f [open $unitsFile r]
fconfigure $f -encoding utf-8
set unitLines [split [string trimright [read $f] \n] \n]
close $f
set n 0
fconfigure stdout -buffering line
foreach line $unitLines {
    incr n
    if {($n - $shardI) % $shardN != 0} continue
    lassign [split $line \t] id set label entry target expect map
    set census::hir ""
    set start [clock milliseconds]
    if {[catch {escape::Program $entry $target} result options]} {
        set seconds [format %.1f [expr {([clock milliseconds] - $start) / 1000.0}]]
        set message [lindex [split $result \n] 0]
        foreach {from to} $map { set message [string map [list $from $to] $message] }
        set message [string map [list $censusRoot/ ""] $message]
        puts [join [list UNIT $id error $seconds [dict getdef $options -errorcode ""] $message] \t]
        continue
    }
    set seconds [format %.1f [expr {([clock milliseconds] - $start) / 1000.0}]]
    lassign $result hits status
    puts [join [list UNIT $id ok $seconds "" ""] \t]
    foreach hit $hits {
        lassign $hit bucket where v u rules what
        puts [join [list SITE $id $bucket [census::MapLocation $map $where] $v $u [join $rules ,] $what] \t]
    }
    if {$census::hir ne ""} {
        if {[catch {census::Modules $census::hir $id $map $entry} lines]} {
            puts [join [list MODERROR $id [lindex [split $lines \n] 0]] \t]
        } else {
            foreach l $lines { puts $l }
        }
    }
}

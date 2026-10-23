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
# edit (a nested opaque struct stopping the search). EXTERNS / PTR-EXTERNS:
# its `extern c fn` declarations, and those with a pointer parameter or
# result.
#
#   XCALL ID  STATUS-OF-U  LOCATION  FROM  TO  KINDS  CALLEE
#
# A supplementary measurement outside the instrument's rules: a call from
# unit V of an `extern c fn` that another unit U declares (the instrument's
# R1-R3 see calls of Botlish functions only, escape::CalleeBlock), with
# KINDS the ptr/view kinds of its argument and result types (the same
# escape::Holds searches) -- a C call made across a module boundary on a
# pointer. Only calls whose KINDS are not empty are listed.
#
#   VREF  ID  LOCATION  FROM  TO  KINDS  FUNCTION
#
# A second supplementary measurement: a reference from unit V to a function
# of a contextualized module U that is not the callee of a call -- the
# function taken as a value, which escape::CalleeBlock never follows (KINDS
# as above, of the function's own parameter and result types).

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

# XCALL lines of HIR (see the header).
proc census::ExternCalls {hir id map} {
    hir::activate $hir
    set sections [dict create]
    dict for {ns scope} [dict getdef $hir modules {}] { dict set sections $scope $ns }
    set status [dict create]
    if {[dict exists $hir direct units]} {
        dict for {ns u} [dict get $hir direct units] { dict set status $ns [dict get $u status] }
    }
    set owners [dict create]
    dict for {key record} [hir::foreign::declarations $hir] {
        dict set owners [dict get $record native] [dict get $record namespace]
    }
    set memo [dict create]
    set lines {}
    set seen [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        set callee [dict get $hir exprs [dict get $node callee]]
        if {[dict get $callee kind] ne "ref" || [dict get $callee binding] eq ""} continue
        set value [dict get $hir bindings [dict get $callee binding] value]
        if {[lindex $value 0] ne "native" || ![dict exists $owners [lindex $value 1]]} continue
        set u [dict get $owners [lindex $value 1]]
        set v [hir::direct::UnitOfScope $hir [dict get $node scope] memo $sections]
        if {$u eq $v} continue
        set types [list [hir::typeOf $hir $e]]
        foreach a [dict get $node args] { lappend types [hir::typeOf $hir $a] }
        set kinds [Kinds $types]
        if {$kinds eq {}} continue
        set where [escape::Location $hir $e]
        if {$where eq "" || [dict exists $seen $where]} continue
        dict set seen $where 1
        lappend lines [join [list XCALL $id [dict getdef $status $u ""] [MapLocation $map $where] \
            [expr {$v eq "" ? "entry" : $v}] $u [join $kinds ,] [core::native::displayName [lindex $value 1]]] \t]
    }
    return $lines
}

# VREF lines of HIR (see the header).
proc census::ValueRefs {hir id map} {
    set sections [dict create]
    dict for {ns scope} [dict getdef $hir modules {}] { dict set sections $scope $ns }
    set status [dict create]
    if {[dict exists $hir direct units]} {
        dict for {ns u} [dict get $hir direct units] { dict set status $ns [dict get $u status] }
    }
    set callees [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "call"} { dict set callees [dict get $node callee] 1 }
    }
    set memo [dict create]
    set lines {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || [dict exists $callees $e] || [dict get $node binding] eq ""} continue
        set binding [dict get $hir bindings [dict get $node binding]]
        set by [dict get $binding declaredBy]
        if {$by eq "" || ![dict exists $hir exprs $by value]} continue
        set block [dict get $hir exprs $by value]
        if {$block eq "" || [dict get $hir exprs $block kind] ne "block"} continue
        set u [hir::direct::UnitOfScope $hir [dict get $hir exprs $block scope] memo $sections]
        if {$u eq "" || [dict getdef $status $u ""] ne "contextualized"} continue
        set v [hir::direct::UnitOfScope $hir [dict get $node scope] memo $sections]
        if {$u eq $v} continue
        set type [hir::typeOf $hir $block]
        set kinds [Kinds [concat [list [lindex $type 3]] [dict getdef [lindex $type 4] args {}]]]
        set where [escape::Location $hir $e]
        lappend lines [join [list VREF $id [MapLocation $map $where] [expr {$v eq "" ? "entry" : $v}] $u \
            [join $kinds ,] [hir::semantic::CallableName $hir $block]] \t]
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
        if {[catch {census::ValueRefs $census::hir $id $map} lines]} {
            puts [join [list VERROR $id [lindex [split $lines \n] 0]] \t]
        } else {
            foreach l $lines { puts $l }
        }
        if {[catch {census::ExternCalls $census::hir $id $map} lines]} {
            puts [join [list XERROR $id [lindex [split $lines \n] 0]] \t]
        } else {
            foreach l $lines { puts $l }
        }
    }
}

# escape-candidates.tcl -- the measuring instrument of the warning candidate
# in ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md, "Warning proposal": every place
# where a foreign resource crosses the boundary of a module that already
# mediates its raw authority through a context of its own. A census tool,
# not a compiler warning: it reports, it never rejects, and nothing in the
# compiler loads it.
#
#   tclsh9.0 audit/icy-tower/context-refactor/tools/escape-candidates.tcl \
#       ?-target T? ?-format text|tsv? FILE.bot ...
#
# Each FILE is compiled by the front end (no backend runs; -warnings off, no
# cache) and its HIR searched. A *boundary module* U is a module whose
# directness status is `contextualized` (DIRECT-MODULES.md: it has direct
# edges and its own contexts mediate every one) -- the module that, by the
# language's own accounting, is the airlock of some raw authority. Modules
# that only declare a context (status ordinary) and designated direct
# modules are reported in their own buckets, never as hits.
#
# The rules, each a fact the HIR states (types are the inferred types of the
# arguments and results at the site):
#
#   R1 carry   a call from another unit V to a function of U passes or
#              returns a value whose type holds a C address (Ptr or FnPtr,
#              directly or through struct fields, Lists, vectors, arrays):
#              foreign resource ownership crosses the airlock;
#   R2 raw     the same, where the crossing type exposes the C address's
#              representation to V: the address itself, or a non-opaque
#              struct, anonymous struct or List holding one (an opaque
#              struct of U stops the search: V cannot read it);
#   R3 view    a call from V to U passes or returns a native view or edit
#              (NativeView[L], NativeEdit[L], directly or nested as above,
#              an opaque struct stopping the search as in R2):
#              unrestricted access to native memory -- pointers included --
#              crossing the airlock;
#   R4 shape   code in V constructs, destructures or projects a struct that
#              U declares and that holds a C address (U's resource record
#              taken apart outside U).
#
# A site is a source location (FILE:LINE:COLUMN), so a function the trait
# plan clones counts once. Output: one line per site, then totals.

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here .. .. .. ..]]
source [file join $root surface surface.tcl]

namespace eval escape {}

# 1 if TYPE holds a C address (MODE carry) or exposes one to another module
# (MODE raw), or exposes a native view or edit (MODE view). An opaque struct
# stops the raw and view searches: the other module cannot read its fields.
proc escape::Holds {type mode {seen {}}} {
    if {[llength $type] < 2} {
        return [expr {$mode ne "view" && $type in {cptr cfnptr}}]
    }
    switch -- [lindex $type 0] {
        cptr - cfnptr { return [expr {$mode ne "view"}] }
        nview - nedit { return [expr {$mode eq "view"}] }
        srefined { return [Holds [hir::refinements::Base $type] $mode $seen] }
        list - immutableSet - mutarray - mutvec {
            if {[Holds [lindex $type 1] $mode $seen]} { return 1 }
            if {[lindex $type 0] eq "list" && [llength $type] == 3} {
                foreach p [lindex $type 2] {
                    if {[Holds $p $mode $seen]} { return 1 }
                }
            }
            return 0
        }
        struct {
            foreach {name t} [lindex $type 1] {
                if {[Holds $t $mode $seen]} { return 1 }
            }
            return 0
        }
        nstruct {
            set id [lindex $type 1]
            if {$id in $seen || ![hir::structs::declared $id]} { return 0 }
            if {$mode ne "carry" && [hir::structs::isOpaque $id]} { return 0 }
            foreach {name t} [hir::structs::fieldTypes $id] {
                if {[Holds $t $mode [concat $seen [list $id]]]} { return 1 }
            }
            return 0
        }
    }
    return 0
}

proc escape::Location {hir e} {
    set origin [dict get $hir exprs $e origin]
    if {[lindex $origin 0] ne "file"} { return "" }
    return [hir::originLocation $hir $origin]
}

# The block call C targets exactly, "" if none.
proc escape::CalleeBlock {hir c} {
    set callee [dict get $hir exprs [dict get $hir exprs $c callee]]
    if {[dict get $callee kind] ne "ref" || [dict get $callee binding] eq ""} { return "" }
    set binding [dict get $hir bindings [dict get $callee binding]]
    set by [dict get $binding declaredBy]
    if {$by eq "" || ![dict exists $hir exprs $by value]} { return "" }
    set value [dict get $hir exprs $by value]
    if {[dict get $hir exprs $value kind] ne "block"} { return "" }
    return $value
}

proc escape::Program {file target} {
    set options [list -warnings off -cache ""]
    if {$target ne ""} { lappend options -target $target }
    set hir [surface::readProgramFile $file {*}$options]
    set sections [dict create]
    if {[dict exists $hir modules]} {
        dict for {ns scope} [dict get $hir modules] { dict set sections $scope $ns }
    }
    set memo [dict create]
    set status [dict create]
    if {[dict exists $hir direct units]} {
        dict for {ns u} [dict get $hir direct units] { dict set status $ns [dict get $u status] }
    }
    # Modules that declare a context (struct or trait) of their own.
    set declares [dict create]
    foreach entry [hir::sourceTypes $hir] {
        if {[dict exists $entry context] && [dict get $entry context] && [dict exists $entry id]} {
            set id [dict get $entry id]
            set i [string last :: $id]
            dict set declares [expr {$i < 0 ? "" : [string range $id 0 [expr {$i - 1}]]}] 1
        }
    }
    set hits {}
    set seen [dict create]
    dict for {e node} [dict get $hir exprs] {
        set kind [dict get $node kind]
        if {$kind ni {call struct project bind}} continue
        set where [Location $hir $e]
        if {$where eq ""} continue
        set v [hir::direct::UnitOfScope $hir [dict get $node scope] memo $sections]
        if {$kind eq "call"} {
            set b [CalleeBlock $hir $e]
            if {$b eq ""} continue
            set u [hir::direct::UnitOfScope $hir [dict get $hir exprs $b scope] memo $sections]
            if {$u eq $v || $u eq ""} continue
            set types [list [hir::typeOf $hir $e]]
            foreach a [dict get $node args] { lappend types [hir::typeOf $hir $a] }
            set rules {}
            foreach {rule mode} {R1 carry R2 raw R3 view} {
                foreach t $types {
                    if {$t ne "" && [Holds $t $mode]} { lappend rules $rule; break }
                }
            }
            if {$rules eq {}} continue
            set what "call [hir::semantic::CallableName $hir $b]"
        } else {
            # R4: U's pointer-holding struct taken apart or built in V.
            set type [expr {$kind eq "project" ? [hir::typeOf $hir [dict get $node receiver]] : [hir::typeOf $hir $e]}]
            if {$kind eq "project"} {
                # A destructuring's own projections are its one site.
                set r [dict get $hir exprs [dict get $node receiver]]
                if {[dict get $r kind] eq "ref" && [dict get $r binding] ne ""
                        && [string match destructure#* [dict get $hir bindings [dict get $r binding] name]]} continue
            }
            if {$kind eq "bind"} {
                set name [dict get $hir bindings [dict get $node binding] name]
                if {![string match destructure#* $name]} continue
                set type [hir::typeOf $hir [dict get $node value]]
            }
            if {[lindex $type 0] ne "nstruct"} continue
            set id [lindex $type 1]
            if {![hir::structs::declared $id]} continue
            set i [string last :: $id]
            set u [expr {$i < 0 ? "" : [string range $id 0 [expr {$i - 1}]]}]
            if {$u eq $v || $u eq "" || ![Holds $type carry]} continue
            set rules R4
            set what "[dict get {struct construct project project bind destructure} $kind] $id"
        }
        set bucket [dict getdef $status $u ""]
        if {$bucket ne "contextualized"} {
            set bucket [expr {$bucket eq "direct" || $bucket eq "provided" ? "designated-direct" : ([dict exists $declares $u] ? "context-but-ordinary" : "no-context")}]
        } else {
            set bucket hit
        }
        set key "$where $rules"
        if {[dict exists $seen $key]} continue
        dict set seen $key 1
        lappend hits [list $bucket $where [expr {$v eq "" ? "entry" : $v}] $u $rules $what]
    }
    return [list $hits $status]
}

set options [dict create -target "" -format text]
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    if {[string match -* $a]} {
        dict set options $a [lindex $argv [incr i]]
    } else {
        lappend files $a
    }
}
set totals [dict create]
foreach file $files {
    if {[catch {escape::Program $file [dict get $options -target]} result]} {
        puts "ERROR\t$file\t[lindex [split $result \n] 0]"
        dict incr totals error
        continue
    }
    lassign $result hits status
    foreach hit $hits {
        lassign $hit bucket where v u rules what
        dict incr totals "$bucket sites"
        foreach r $rules { dict incr totals "$bucket $r" }
        if {[dict get $options -format] eq "tsv"} {
            puts [join [list $bucket $where $v $u [join $rules ,] $what] \t]
        } else {
            puts "$bucket  $where  $v -> $u  [join $rules ,]  $what"
        }
    }
}
puts "totals: [lsort -stride 2 $totals]"

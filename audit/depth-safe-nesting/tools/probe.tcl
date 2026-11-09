# probe.tcl -- every compile-time path a nested program takes, at Tcl's
# default recursion limit (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md).
#
#   tclsh9.0 audit/depth-safe-nesting/tools/probe.tcl ?-depth N?
#       ?-kinds KIND,...? ?-scenarios NAME,...? ?-limit L? ?-root DIR?
#
# For each specimen kind (specimens.tcl) N deep (1000 by default) and each
# scenario -- the compilation with every warning pass, the HIR text printed
# and read back, interchange text, the core IR and its check, the Tcl
# compiler's unit, native lowering, the program wrapped in a trait program,
# a coroutine program, a `static compile:` block and an imported module, and
# the compiler service's analysis and position queries -- it runs the path
# under Tcl's default limit of 1000 nested evaluations and reports any that
# fails with TCL LIMIT STACK, naming the procedures that repeat most in the
# error's stack: a walk whose recursion follows the nesting and carries no
# guard (core/deep.tcl), and any other error the program 3 deep does not
# get too. It prints one line per kind and scenario, then a summary; exit
# status 1 if any path failed. -root runs another checkout's
# compiler (the revision before the milestone fails nearly everything).

set options [dict create -depth 1000 -kinds "" -scenarios "" -limit 1000 \
    -root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "unknown option $option"
    }
    dict set options $option $value
}
set ::dsnOptions $options
set root [dict get $options -root]
source [file join $root native native.tcl]
source [file join $root surface surface.tcl]
source [file join $root service service.tcl]
source [file join [file dirname [file normalize [info script]]] specimens.tcl]
set options $::dsnOptions

source [file join [file dirname [file normalize [info script]]] scenarios.tcl]
set scenarios $dsn::scenarios

# The procedures repeated most in a stack trace INFO.
proc Repeated {info} {
    set names {}
    foreach line [split $info \n] {
        if {[regexp {\(procedure "([^"]+)"} $line -> name]} {
            dict incr names $name
        }
    }
    return [lmap {name count} [lrange [lsort -stride 2 -index 1 -integer -decreasing $names] 0 9] {
        if {$count < 3} { break }
        string cat $name ×$count
    }]
}

set kinds [dict get $options -kinds]
if {$kinds eq ""} {
    set kinds [dsn::kinds]
} else {
    set kinds [split $kinds ,]
}
set names [dict get $options -scenarios]
if {$names eq ""} {
    set names [dict keys $scenarios]
} else {
    set names [split $names ,]
}
set failures 0
set dir [file tempdir dsn-probe]
foreach kind $kinds {
    set source [dict get [dsn::specimen $kind [dict get $options -depth]] source]
    foreach name $names {
        set saved [interp recursionlimit {}]
        interp recursionlimit {} [dict get $options -limit]
        set started [clock milliseconds]
        set code [catch [dict get $scenarios $name] result info]
        interp recursionlimit {} $saved
        set ms [expr {[clock milliseconds] - $started}]
        if {$code == 1 && [lrange [dict get $info -errorcode] 0 2] eq {TCL LIMIT STACK}} {
            incr failures
            puts "$kind $name: TCL LIMIT STACK ($ms ms) [Repeated [dict get $info -errorinfo]]"
        } elseif {$code == 1} {
            # (A refusal is the language's when the program 3 deep gets it
            # too -- a module binding's initializer that is no
            # context-free form, say; otherwise it is the depth's.)
            set refusal [lrange [dict get $info -errorcode] 0 2]
            set deep $source
            set source [dict get [dsn::specimen $kind 3] source]
            catch [dict get $scenarios $name] shallowResult shallow
            set source $deep
            if {[lrange [dict get $shallow -errorcode] 0 2] eq $refusal} {
                puts "$kind $name: refused at any depth: $refusal ($ms ms)"
            } else {
                incr failures
                puts "$kind $name: $refusal only [dict get $options -depth] deep ($ms ms) [string range $result 0 120]"
            }
        } else {
            puts "$kind $name: ok ($ms ms)"
        }
        flush stdout
    }
}
file delete -force $dir
puts "[llength $kinds] kinds, [llength $names] scenarios, $failures paths that failed"
exit [expr {$failures > 0}]

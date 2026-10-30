# census.tcl -- every `==` and `!=` the corpus writes, by what the static
# types of its two operands say about it (EQUALITY-SEMANTICS.md).
#
#   tclsh9.0 audit/equality-semantics/tools/census.tcl ?-out FILE? ?-sites FILE?
#       ?-cache DIR?
#
# (-cache DIR: read and keep the programs' HIRs in the front-end cache DIR,
# surface::readProgramFile -cache; a hit equals the build.)
#
# Compiles every program of the corpus -- examples/**/*.bot, bench/**/*.bot,
# tests/golden/*.bot -- and a loader of every standard-library module
# (`import std::NAME` and a value; a Darwin or Windows module for its
# platform's target), each strict with warnings off, and visits every
# call of the root native `==` in the generic HIR (a `!=` lowers to one, in a
# branch: surface/lower.tcl). A site is counted once, by its file, line and
# column, however many compilations reach it (a library module's sites are
# reached by every program that loads it). For each it records the operator
# as written, the operands' static types (hir::typeOf, hir::types::show) and
# their exact values where the checker has one (hir::exact::Of), and
# classifies the pair:
#
#   refused        an operand's type has no equality (hir::types::Totality:
#                  none -- a callable, a MutableArray, ...): the comparison
#                  raises EQUALITY whenever it runs
#   unknown        an operand's type fixes no runtime kind (any, an imprint
#                  variable, a trait view, a structural Fn type): nothing is
#                  known statically
#   disjoint-kind  both kinds are fixed and differ (str and UnicodeChar, Int
#                  and Float64, a List and a struct): always false
#   disjoint-nominal  the same kind, different declarations or shapes (two
#                  enums, two named structs, a named and an anonymous struct,
#                  anonymous structs with different fields): always false
#   disjoint-domain  two integer types whose domains do not meet, or an Int
#                  constant outside the other operand's domain: always false
#   empty-only     Lists or sets whose element types share no value: equal
#                  only when both are empty
#   compatible     anything else: the types share a value
#
# An unknown site is further split by what Level 2 of the report (equality in
# contract inference) would do with it: `untyped-parameter` (one operand is
# a reference to a parameter with no declared or inferred type, the other
# has a fixed kind: Level 2 would give the parameter a contract),
# `both-unknown` and `computed` (the unknown operand is another expression:
# an untyped call's result, an element of a List[any], ...).
#
# Then every semantic instance the compilation used (hir/semantic.tcl) is
# visited the same way, with the instance's types: a site that is not
# disjoint in the generic HIR but disjoint or refused in some instance is
# counted as `instance-disjoint` (Level 1's per-instance check would reject
# the call that needs that instance).
#
# The classification reads only static types and the checker's exact values,
# never a run. Writes the table of classes per corpus area (-out, default
# stdout) and one line per site (-sites, default none). The real checkout is
# only read.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -out "" -sites "" -cache ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::cacheDir [dict get $options -cache]
set ::argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]

namespace eval census {
    variable sites [dict create]
    variable failed {}
}

proc census::ReadText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    return $text
}

# The relation of static types A and B under `==`, as {CLASS WHY}.
proc census::Relation {a b} {
    foreach t [list $a $b] {
        if {[lindex [hir::types::Totality equality $t] 0] eq "none"} {
            return [list refused [lindex [hir::types::Totality equality $t] 1]]
        }
    }
    set ka [hir::types::kindOf $a]
    set kb [hir::types::kindOf $b]
    if {$ka eq "" || $kb eq "" || $a eq "any" || $b eq "any" || $ka eq "any" || $kb eq "any"} {
        return {unknown "an operand's type fixes no runtime kind"}
    }
    if {$ka ne $kb} {
        return [list disjoint-kind "$ka vs $kb"]
    }
    switch -- $ka {
        enum {
            if {[lindex $a 1] ne [lindex $b 1]} {
                return [list disjoint-nominal "enum [lindex $a 1] vs enum [lindex $b 1]"]
            }
        }
        struct {
            set sa [hir::types::StructShape $a]
            set sb [hir::types::StructShape $b]
            if {[lindex $sa 0] ne [lindex $sb 0]} {
                return [list disjoint-nominal "struct identity [expr {[lindex $sa 0] eq "" ? "anonymous" : [lindex $sa 0]}] vs [expr {[lindex $sb 0] eq "" ? "anonymous" : [lindex $sb 0]}]"]
            }
            if {[lindex $sa 0] eq ""} {
                if {[lrange $sa 1 end] ne [lrange $sb 1 end]} {
                    return [list disjoint-nominal "anonymous structs with fields {[lrange $sa 1 end]} vs {[lrange $sb 1 end]}"]
                }
                set worst compatible
                foreach field [lrange $sa 1 end] {
                    set fa [hir::types::StructField $a $field]
                    set fb [hir::types::StructField $b $field]
                    if {$fa eq "" || $fb eq ""} continue
                    lassign [Relation $fa $fb] class why
                    if {[string match disjoint-* $class]} {
                        return [list $class "field $field: $why"]
                    }
                    if {$class in {empty-only unknown} && $worst eq "compatible"} {
                        set worst $class
                    }
                }
                return [list $worst ""]
            }
            if {[hir::types::IsAppliedStruct $a] && [hir::types::IsAppliedStruct $b]} {
                foreach x [hir::types::StructArgs $a] y [hir::types::StructArgs $b] {
                    lassign [Relation $x $y] class why
                    if {[string match disjoint-* $class]} {
                        return [list disjoint-nominal "type arguments [hir::types::show $x] vs [hir::types::show $y]"]
                    }
                }
            }
        }
        list - immutableSet {
            set ea [Element $a]
            set eb [Element $b]
            if {$ea eq "" || $eb eq "" || $ea eq "never" || $eb eq "never"} {
                return {compatible ""}
            }
            lassign [Relation $ea $eb] class why
            if {[string match disjoint-* $class] || $class eq "empty-only"} {
                return [list empty-only "elements: $why"]
            }
            if {$class eq "unknown"} {
                return {unknown "an element type fixes no runtime kind"}
            }
        }
        int {
            set fa [IntFacts $a]
            set fb [IntFacts $b]
            if {$fa ne {} && $fb ne {}
                    && ([dict get $fa max] < [dict get $fb min] || [dict get $fb max] < [dict get $fa min])} {
                return [list disjoint-domain "[hir::types::show $a] and [hir::types::show $b] do not meet"]
            }
        }
    }
    return {compatible ""}
}

proc census::Element {type} {
    if {[hir::types::IsSet $type]} {
        return [lindex $type 1]
    }
    return [hir::types::elementOf $type]
}

# An integer type's domain as core::type::integerFacts gives it, {} if none.
proc census::IntFacts {type} {
    if {[catch {core::type::integerFacts $type} facts]} {
        return {}
    }
    return $facts
}

# An exact Int constant outside the other operand's domain.
proc census::ConstantOutside {hir a b} {
    foreach {x y} [list $a $b $b $a] {
        set fact [hir::exact::Of $hir $x]
        if {[lindex $fact 0] ne "int"} continue
        set value [lindex $fact 1]
        set facts [IntFacts [hir::typeOf $hir $y]]
        if {$facts ne {} && ($value < [dict get $facts min] || $value > [dict get $facts max])} {
            return "the constant $value is outside [hir::types::show [hir::typeOf $hir $y]]"
        }
    }
    return ""
}

proc census::Exact {hir e} {
    set fact [hir::exact::Of $hir $e]
    switch -- [lindex $fact 0] {
        val { return [core::value::show [lindex $fact 1]] }
        int { return [lindex $fact 1] }
    }
    return ""
}

# Records every `==` site of HIR not seen before; AREA labels where the
# compilation came from.
proc census::Visit {hir area} {
    variable sites
    set keyOf [dict create]
    set paths [dict create]
    dict for {id file} [dict get $hir files] {
        dict set paths $id [dict get $file path]
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        lassign [dict get $node target] targetKind target
        if {$targetKind ne "native" || [dict get [hir::symbol $hir $target] name] ne "=="} continue
        set origin [dict get $node origin]
        if {![dict exists $origin file] || ![dict exists $paths [dict get $origin file]]} continue
        set path [dict get $paths [dict get $origin file]]
        set relative [string range $path [string length $::root/] end]
        set key [list $relative [dict get $origin line] [dict get $origin column]]
        if {[dict exists $sites $key]} {
            dict set keyOf $e $key
            continue
        }
        lassign [dict get $node args] a b
        set ta [hir::typeOf $hir $a]
        set tb [hir::typeOf $hir $b]
        lassign [Relation $ta $tb] class why
        if {$class eq "compatible"} {
            set outside [ConstantOutside $hir $a $b]
            if {$outside ne ""} {
                set class disjoint-domain
                set why $outside
            }
        }
        set shape -
        if {$class eq "unknown"} {
            set shape [UnknownShape $hir $a $ta $b $tb]
        }
        dict set sites $key [dict create area [Area $relative] operator [Operator $hir $node $path] \
            a [hir::types::show $ta] b [hir::types::show $tb] exactA [Exact $hir $a] exactB [Exact $hir $b] \
            class $class why $why reachable [dict getdef $node reachable 1] shape $shape instance -]
        dict set keyOf $e $key
    }
    VisitInstances $hir $keyOf
}

proc census::IsUnknown {type} {
    set kind [hir::types::kindOf $type]
    return [expr {$kind eq "" || $kind eq "any" || $type eq "any"}]
}

# untyped-parameter, both-unknown or computed (header).
proc census::UnknownShape {hir a ta b tb} {
    set ua [IsUnknown $ta]
    set ub [IsUnknown $tb]
    if {$ua && $ub} {
        return both-unknown
    }
    set u [expr {$ua ? $a : $b}]
    set node [dict get $hir exprs $u]
    if {[dict get $node kind] eq "ref" && [dict exists $node binding]
            && [dict exists $hir bindings [dict get $node binding]]} {
        set binding [dict get $hir bindings [dict get $node binding]]
        if {[dict get $binding kind] eq "param" && [dict get $binding type] eq ""} {
            return untyped-parameter
        }
    }
    return computed
}

# Marks every site of KEYOF (call ExprId -> site key) that some used semantic
# instance of HIR sees as disjoint or refused while the generic HIR does not.
proc census::VisitInstances {hir keyOf} {
    variable sites
    if {![dict exists $hir semantic used]} {
        return
    }
    foreach id [dict get $hir semantic used] {
        if {[catch {
            set view [hir::semantic::View $hir $id]
            set region [hir::semantic::Region $view [dict get $hir semantic instances $id block]]
        }]} continue
        foreach e $region {
            if {![dict exists $keyOf $e]} continue
            set key [dict get $keyOf $e]
            set site [dict get $sites $key]
            if {[string match disjoint-* [dict get $site class]] || [dict get $site class] in {refused empty-only}} continue
            if {[dict get $site instance] ne "-"} continue
            set node [dict get $view exprs $e]
            if {![dict getdef $node reachable 1]} continue
            lassign [dict get $node args] a b
            set ta [hir::typeOf $view $a]
            set tb [hir::typeOf $view $b]
            lassign [Relation $ta $tb] class why
            if {[string match disjoint-* $class] || $class in {refused empty-only}} {
                dict set sites $key instance "$class: [hir::types::show $ta] vs [hir::types::show $tb]"
            }
        }
    }
}

# == or != as written: the source text at the callee's origin.
proc census::Operator {hir node path} {
    variable texts
    set callee [hir::node $hir [dict get $node callee]]
    set origin [dict get $callee origin]
    if {![info exists texts($path)]} {
        set texts($path) [ReadText $path]
    }
    set text [string range $texts($path) [dict get $origin start] [expr {[dict get $origin end] - 1}]]
    if {$text in {== !=}} {
        return $text
    }
    return "?"
}

proc census::Area {relative} {
    switch -glob -- $relative {
        stdlib/* { return stdlib }
        examples/* { return examples }
        bench/* { return bench }
        tests/golden/* { return golden }
        default { return other }
    }
}

proc census::Compile {path area} {
    variable failed
    set cache {}
    if {$::cacheDir ne ""} {
        set cache [list -cache $::cacheDir]
    }
    if {[catch {surface::readProgramFile $path -warnings off {*}$cache} hir]} {
        lappend failed [list $path [lindex [split $hir \n] 0]]
        return
    }
    Visit $hir $area
}

proc census::CompileText {text name area args} {
    variable failed
    if {[catch {surface::compile $text $name -warnings off {*}$args} hir]} {
        lappend failed [list $name [lindex [split $hir \n] 0]]
        return
    }
    Visit $hir $area
}

set programs {}
foreach dir {examples bench} {
    foreach path [split [exec find [file join $root $dir] -name *.bot] \n] {
        if {$path ne ""} { lappend programs $path }
    }
}
lappend programs {*}[glob -directory [file join $root tests golden] *.bot]
foreach path [lsort $programs] {
    census::Compile $path [census::Area [string range $path [string length $root/] end]]
}
foreach path [lsort [split [exec find [file join $root stdlib] -name *.bot] \n]] {
    if {$path eq ""} continue
    set namespace std::[string map {/ ::} [file rootname [string range $path [string length $root/stdlib/] end]]]
    # An architecture-specific module (stdlib/P.ARCH.bot) is std::P.
    regsub {\.(x86_64|aarch64)$} $namespace {} namespace
    # A platform's modules compile for one of its targets only; the loader
    # ends with a value of its own, so a module whose last declaration
    # requires a context is no program value.
    set target {}
    switch -glob -- $namespace {
        std::darwin* { set target {-target macos-aarch64} }
        std::windows* { set target {-target windows-x86_64} }
    }
    census::CompileText "import $namespace\n0\n" [file join $root census-loader.bot] stdlib {*}$target
}

set classes {refused unknown disjoint-kind disjoint-nominal disjoint-domain empty-only compatible}
set areas {stdlib examples bench golden}
set counts [dict create]
dict for {key site} $census::sites {
    dict incr counts [list [dict get $site area] [dict get $site class]]
    dict incr counts [list all [dict get $site class]]
    dict incr counts [list [dict get $site area] total]
    dict incr counts [list all total]
}
set out {}
lappend out "| class | [join $areas { | }] | all |"
lappend out "|---|[string repeat ---:| [expr {[llength $areas] + 1}]]"
foreach class [concat $classes total] {
    set row "| $class |"
    foreach area [concat $areas all] {
        append row " [dict getdef $counts [list $area $class] 0] |"
    }
    lappend out $row
}
set shapes {untyped-parameter both-unknown computed}
lappend out "" "Unknown sites, by what Level 2 would do with them:" ""
lappend out "| unknown operand | [join $areas { | }] | all |"
lappend out "|---|[string repeat ---:| [expr {[llength $areas] + 1}]]"
set shapeCounts [dict create]
set instanceCounts [dict create]
dict for {key site} $census::sites {
    if {[dict get $site shape] ne "-"} {
        dict incr shapeCounts [list [dict get $site area] [dict get $site shape]]
        dict incr shapeCounts [list all [dict get $site shape]]
    }
    if {[dict get $site instance] ne "-"} {
        dict incr instanceCounts [dict get $site area]
        dict incr instanceCounts all
    }
}
foreach shape $shapes {
    set row "| $shape |"
    foreach area [concat $areas all] {
        append row " [dict getdef $shapeCounts [list $area $shape] 0] |"
    }
    lappend out $row
}
set row "| instance-disjoint (not disjoint in the generic HIR) |"
foreach area [concat $areas all] {
    append row " [dict getdef $instanceCounts $area 0] |"
}
lappend out "" $row
lappend out "" "[dict size $census::sites] sites; [llength $census::failed] compilations failed:"
foreach f $census::failed {
    # (No file is written: census-loader.bot only names a loader's text.)
    lappend out "  [string range [lindex $f 0] [string length $root/] end]: [string range [string map [list $root/ ""] [lindex $f 1]] 0 160]"
}
if {[dict get $options -out] eq ""} {
    puts [join $out \n]
} else {
    set f [open [dict get $options -out] w]
    fconfigure $f -encoding utf-8
    puts $f [join $out \n]
    close $f
}
if {[dict get $options -sites] ne ""} {
    set f [open [dict get $options -sites] w]
    fconfigure $f -encoding utf-8
    puts $f [join {file line column area operator class a b exactA exactB reachable shape instance why} \t]
    foreach key [lsort -dictionary [dict keys $census::sites]] {
        set site [dict get $census::sites $key]
        puts $f [join [list {*}$key [dict get $site area] [dict get $site operator] [dict get $site class] \
            [dict get $site a] [dict get $site b] [dict get $site exactA] [dict get $site exactB] \
            [dict get $site reachable] [dict get $site shape] [dict get $site instance] [dict get $site why]] \t]
    }
    close $f
}

# reclassify.tcl -- every `==` and `!=` of the corpus under the candidate
# relations and policies of EQUALITY-SEMANTIC-CENSUS.md (section 10), the
# census of EQUALITY-SEMANTICS.md extended.
#
#   tclsh9.0 audit/equality-semantics/tools/reclassify.tcl ?-out DIR?
#       ?-cache DIR?
#
# Compiles the same corpus as census.tcl -- every program of examples/,
# bench/ and tests/golden/, and a loader of every standard-library module --
# strict with warnings off; a program that imports a platform's namespaces
# is compiled for that platform's target (surface::modules::PlatformTarget,
# as the golden runner and the warning gate do), which census.tcl did not.
# Visits every call of the root native `==` once per site (file, line,
# column) in the generic HIR, and again in every semantic instance the
# compilation used (hir/semantic.tcl). For each site it records:
#
#   head, overlap, kinded, structural, defined, related   lib.tcl's
#             relations of the
#             operands' generic static types
#   unknown   for a site with an operand of no fixed kind, where that
#             operand comes from: declared-any (a parameter declared `any`),
#             untyped (an untyped parameter with no inferred contract),
#             contract (an untyped parameter whose checked contract fixes no
#             kind), imprint (an imprint variable), view (a trait view),
#             fn (a structural Fn type), computed (any other expression)
#   other     the other operand's class: known (a fixed kind) or unknown
#   inst-*    the worst head / overlap / kinded / structural class any
#             used instance gives the site, and the operand types of the
#             instance with the worst structural class
#
# and, for every untyped parameter compared with an operand of fixed kind
# (outside a kind test of it: its use-site type is still unknown), the
# concrete contract a concrete-inference policy would give it -- the other
# operand's type -- with the parameter's existing inferred contract.
#
# Writes into DIR (default: a fresh temporary directory, printed): sites.tsv
# (one line per site), params.tsv (one line per would-be contract),
# policies.txt (the per-area tables) and failed.txt (compilations skipped).
# The checkout is only read.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -out "" -cache ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::cacheDir [dict get $options -cache]
set outDir [dict get $options -out]
if {$outDir eq ""} {
    set outDir [file tempdir equality-reclassify]
}
file mkdir $outDir
set ::argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join [file dirname [file normalize [info script]]] lib.tcl]

namespace eval reclass {
    variable sites [dict create]
    variable params [dict create]
    variable failed {}
}

proc reclass::Area {relative} {
    switch -glob -- $relative {
        stdlib/* { return stdlib }
        examples/* { return examples }
        bench/* { return bench }
        tests/golden/* { return golden }
        default { return other }
    }
}

# The binding a ref expression E reads, through immutable aliases (y = x).
proc reclass::RootBinding {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "ref" || [dict get $node binding] eq ""} {
        return ""
    }
    set b [dict get $node binding]
    set seen {}
    while {$b ni $seen && [dict exists $hir bindings $b]} {
        lappend seen $b
        set binding [dict get $hir bindings $b]
        if {[dict get $binding kind] eq "param"} {
            return $b
        }
        set d [dict getdef $binding declaredBy ""]
        if {$d eq "" || ![dict exists $hir exprs $d value]} {
            return ""
        }
        set v [dict get $hir exprs $d value]
        if {[dict get $hir exprs $v kind] ne "ref" || [dict get $hir exprs $v binding] eq ""} {
            return ""
        }
        set b [dict get $hir exprs $v binding]
    }
    return ""
}

# {BLOCK INDEX} of parameter binding B, or "".
proc reclass::ParamSlot {hir b} {
    variable slotOf
    if {![info exists slotOf]} {
        set slotOf [dict create]
        dict for {e node} [dict get $hir exprs] {
            if {[dict get $node kind] eq "block"} {
                set i 0
                foreach p [dict get $node params] {
                    dict set slotOf $p [list $e $i]
                    incr i
                }
            }
        }
    }
    return [dict getdef $slotOf $b ""]
}

# Where an operand E of no fixed kind comes from (header).
proc reclass::UnknownOrigin {hir e type} {
    if {[hir::types::IsImprint $type]} { return imprint }
    if {[hir::types::IsTrait $type]} { return view }
    if {[hir::types::IsFn $type]} { return fn }
    set b [RootBinding $hir $e]
    if {$b ne ""} {
        lassign [ParamSlot $hir $b] block index
        if {$block ne ""} {
            set declared [lindex [dict get $hir exprs $block declaredParamTypes] $index]
            if {$declared eq "any"} { return declared-any }
            if {$declared ne ""} { return declared-other }
            set checked [lindex [hir::signatures::checkedTypes $hir $block] $index]
            set trusted [lindex [hir::signatures::entryTypes $hir $block] $index]
            if {$checked ne "" || $trusted ne ""} { return contract }
            return untyped
        }
    }
    return computed
}

proc reclass::Show {t} {
    if {$t eq ""} { return "-" }
    return [hir::types::show $t]
}

proc reclass::Visit {hir relativeOf} {
    variable sites
    variable params
    variable slotOf
    unset -nocomplain slotOf
    set keyOf [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        lassign [dict getdef $node target {}] targetKind target
        if {$targetKind ne "native" || [dict get [hir::symbol $hir $target] name] ne "=="} continue
        set origin [dict get $node origin]
        if {![dict exists $origin file] || ![dict exists $relativeOf [dict get $origin file]]} continue
        set relative [dict get $relativeOf [dict get $origin file]]
        set key [list $relative [dict get $origin line] [dict get $origin column]]
        dict set keyOf $e $key
        if {[dict exists $sites $key]} continue
        lassign [dict get $node args] a b
        set ta [hir::typeOf $hir $a]
        set tb [hir::typeOf $hir $b]
        set ua [eqcensus::Unknown $ta]
        set ub [eqcensus::Unknown $tb]
        set unknown -
        set other -
        if {$ua || $ub} {
            set origins {}
            if {$ua} { lappend origins [UnknownOrigin $hir $a $ta] }
            if {$ub} { lappend origins [UnknownOrigin $hir $b $tb] }
            set unknown [join [lsort $origins] +]
            set other [expr {$ua && $ub ? "unknown" : "known"}]
        }
        set site [dict create area [Area $relative] a [Show $ta] b [Show $tb] \
            head [lindex [eqcensus::Head $ta $tb] 0] \
            why [lindex [eqcensus::Head $ta $tb] 1] \
            overlap [lindex [eqcensus::Overlap $ta $tb] 0] \
            kinded [lindex [eqcensus::Kinded $ta $tb] 0] \
            structural [lindex [eqcensus::Structural $ta $tb] 0] \
            defined [lindex [eqcensus::Defined $ta $tb] 0] \
            related [eqcensus::Related $ta $tb] \
            unknown $unknown other $other reachable [dict getdef $node reachable 1] \
            instHead - instOverlap - instKinded - instStructural - instTypes -]
        dict set sites $key $site
        # A would-be concrete contract (header).
        if {$other eq "known"} {
            set u [expr {$ua ? $a : $b}]
            set known [expr {$ua ? $tb : $ta}]
            if {[UnknownOrigin $hir $u [hir::typeOf $hir $u]] in {untyped contract}} {
                set p [RootBinding $hir $u]
                lassign [ParamSlot $hir $p] block index
                set fnOrigin [dict get $hir exprs $block origin]
                set fnFile [dict getdef $relativeOf [dict getdef $fnOrigin file ""] "?"]
                set pkey [list $fnFile [dict getdef $fnOrigin line ?] [hir::semantic::CallableName $hir $block] [hir::semantic::SourceName $hir $p]]
                set entry [dict getdef $params $pkey [dict create area [Area $fnFile] types {} sites {} \
                    checked [Show [lindex [hir::signatures::checkedTypes $hir $block] $index]] \
                    trusted [Show [lindex [hir::signatures::entryTypes $hir $block] $index]] \
                    first [expr {$index == 0}]]]
                set shown [Show [hir::types::ForgetInferred $known]]
                if {$shown ni [dict get $entry types]} {
                    dict lappend entry types $shown
                }
                dict lappend entry sites "[lindex $key 1]:[lindex $key 2]"
                dict set params $pkey $entry
            }
        }
    }
    VisitInstances $hir $keyOf
}

proc reclass::Rank {relation class} {
    switch -- $relation {
        head { return [lsearch -exact {head-unknown head-equal head-disjoint} $class] }
        overlap { return [lsearch -exact {unknown overlap disjoint} $class] }
        kinded { return [lsearch -exact {unknown compatible empty-only disjoint refused} $class] }
        structural { return [lsearch -exact {unknown compatible incompatible refused} $class] }
    }
}

proc reclass::VisitInstances {hir keyOf} {
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
            set node [dict get $view exprs $e]
            if {![dict getdef $node reachable 1]} continue
            set key [dict get $keyOf $e]
            set site [dict get $sites $key]
            lassign [dict get $node args] a b
            set ta [hir::typeOf $view $a]
            set tb [hir::typeOf $view $b]
            set worse 0
            foreach relation {head overlap kinded structural} field {instHead instOverlap instKinded instStructural} {
                switch -- $relation {
                    head { set class [lindex [eqcensus::Head $ta $tb] 0] }
                    overlap { set class [lindex [eqcensus::Overlap $ta $tb] 0] }
                    kinded { set class [lindex [eqcensus::Kinded $ta $tb] 0] }
                    structural { set class [lindex [eqcensus::Structural $ta $tb] 0] }
                }
                set current [dict get $site $field]
                if {$current eq "-" || [Rank $relation $class] > [Rank $relation $current]} {
                    dict set site $field $class
                    if {$relation eq "structural"} { set worse 1 }
                }
            }
            if {$worse} {
                dict set site instTypes "[Show $ta] vs [Show $tb]"
            }
            dict set sites $key $site
        }
    }
}

proc reclass::Compile {path text relativeName} {
    variable failed
    set cache {}
    if {$::cacheDir ne ""} {
        set cache [list -cache $::cacheDir]
    }
    set target {}
    if {$text eq ""} {
        set f [open $path r]
        fconfigure $f -encoding utf-8
        set source [read $f]
        close $f
        set t [surface::modules::PlatformTarget $source]
        if {$t ne ""} { set target [list -target $t] }
        set code [catch {surface::readProgramFile $path -warnings off {*}$cache {*}$target} hir]
    } else {
        lassign $text source targetName
        if {$targetName ne ""} { set target [list -target $targetName] }
        set code [catch {surface::compile $source $path -warnings off {*}$target} hir]
    }
    if {$code} {
        lappend failed [list $relativeName [lindex [split $hir \n] 0]]
        return
    }
    set relativeOf [dict create]
    dict for {id file} [dict get $hir files] {
        set p [dict get $file path]
        if {[string first $::root/ $p] == 0} {
            dict set relativeOf $id [string range $p [string length $::root/] end]
        }
    }
    Visit $hir $relativeOf
}

set programs {}
foreach dir {examples bench} {
    foreach path [split [exec find [file join $root $dir] -name *.bot] \n] {
        if {$path ne ""} { lappend programs $path }
    }
}
lappend programs {*}[glob -directory [file join $root tests golden] *.bot]
foreach path [lsort $programs] {
    reclass::Compile $path "" [string range $path [string length $root/] end]
    puts stderr [string range $path [string length $root/] end]
}
foreach path [lsort [split [exec find [file join $root stdlib] -name *.bot] \n]] {
    if {$path eq ""} continue
    set namespace std::[string map {/ ::} [file rootname [string range $path [string length $root/stdlib/] end]]]
    regsub {\.(x86_64|aarch64)$} $namespace {} namespace
    set target ""
    switch -glob -- $namespace {
        std::darwin* { set target macos-aarch64 }
        std::windows* { set target windows-x86_64 }
    }
    reclass::Compile [file join $root census-loader.bot] [list "import $namespace\n0\n" $target] "loader of $namespace"
    puts stderr "loader of $namespace"
}

# ---------------------------------------------------------------------------
# Output

set f [open [file join $outDir sites.tsv] w]
fconfigure $f -encoding utf-8
puts $f [join {file line column area head why overlap kinded structural defined related unknown other reachable instHead instOverlap instKinded instStructural a b instTypes} \t]
foreach key [lsort -dictionary [dict keys $reclass::sites]] {
    set s [dict get $reclass::sites $key]
    puts $f [join [concat $key [lmap field {area head why overlap kinded structural defined related unknown other reachable instHead instOverlap instKinded instStructural a b instTypes} {dict get $s $field}]] \t]
}
close $f

set f [open [file join $outDir params.tsv] w]
fconfigure $f -encoding utf-8
puts $f [join {file line function parameter area first trusted checked types sites} \t]
foreach key [lsort -dictionary [dict keys $reclass::params]] {
    set p [dict get $reclass::params $key]
    puts $f [join [concat $key [list [dict get $p area] [dict get $p first] [dict get $p trusted] [dict get $p checked] [join [dict get $p types] ", "] [join [dict get $p sites] " "]]] \t]
}
close $f

set f [open [file join $outDir failed.txt] w]
fconfigure $f -encoding utf-8
foreach item $reclass::failed {
    puts $f "[lindex $item 0]: [string range [string map [list $root/ ""] [lindex $item 1]] 0 200]"
}
close $f
puts "wrote $outDir ([dict size $reclass::sites] sites, [dict size $reclass::params] would-be contracts, [llength $reclass::failed] failed compilations)"

# policies.tcl -- the tables of EQUALITY-SEMANTIC-CENSUS.md, section 10,
# from reclassify.tcl's output.
#
#   tclsh9.0 audit/equality-semantics/tools/policies.tcl DIR ?-out FILE?
#
# Reads DIR/sites.tsv and DIR/params.tsv and prints, per corpus area
# (stdlib, examples, bench, golden, all):
#
#   1. every site by the operands' generic static types: known pairs by the
#      structural relation (and how the other relations split them), and
#      the pair's definedness;
#   2. the unknown sites by where the unknown operand comes from;
#   3. what each candidate policy rejects (section 11's models), in the
#      generic HIR and -- for the instance-checked variants -- in the
#      semantic instances the compilation used;
#   4. the concrete contracts a concrete-inference policy would infer:
#      parameters gaining one, agreeing with an existing one, conflicting.
#
# Writes the tables to FILE (default stdout). Reads nothing else.

set dir ""
set out ""
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {$arg eq "-out"} {
        set out [lindex $argv [incr i]]
    } else {
        set dir $arg
    }
}

proc ReadTsv {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set lines [split [string trimright [read $f] \n] \n]
    close $f
    set header [split [lindex $lines 0] \t]
    set rows {}
    foreach line [lrange $lines 1 end] {
        set row [dict create]
        foreach name $header value [split $line \t] {
            dict set row $name $value
        }
        lappend rows $row
    }
    return $rows
}

set sites [ReadTsv [file join $dir sites.tsv]]
set params [ReadTsv [file join $dir params.tsv]]
set areas {stdlib examples bench golden all}
set lines {}

proc Count {rows predicate} {
    set counts [dict create]
    foreach row $rows {
        if {[uplevel 1 [list apply [list {row} $predicate] $row]]} {
            dict incr counts [dict get $row area]
            dict incr counts all
        }
    }
    return $counts
}

proc Row {label counts} {
    global areas
    set text "| $label |"
    foreach area $areas {
        append text " [dict getdef $counts $area 0] |"
    }
    return $text
}

proc Header {first} {
    global areas
    return [list "| $first | [join $areas { | }] |" "|---|[string repeat ---:| [llength $areas]]"]
}

proc Known {row} {
    return [expr {[dict get $row unknown] eq "-"}]
}

# 1. Known pairs.
lappend lines "## 1. Sites by the operands' generic static types" ""
lappend lines {*}[Header class]
lappend lines [Row "all sites" [Count $sites {expr 1}]]
lappend lines [Row "both operands of fixed kind" [Count $sites {expr {[dict get $row unknown] eq "-"}}]]
lappend lines [Row "  structural: compatible" [Count $sites {expr {[dict get $row unknown] eq "-" && [dict get $row structural] eq "compatible"}}]]
lappend lines [Row "  structural: incompatible, heads differ (kinds)" [Count $sites {expr {[dict get $row structural] eq "incompatible" && [dict get $row head] eq "head-disjoint" && [string match "kinds *" [dict get $row why]]}}]]
lappend lines [Row "  structural: incompatible, heads differ (declarations or shapes)" [Count $sites {expr {[dict get $row structural] eq "incompatible" && [dict get $row head] eq "head-disjoint" && ![string match "kinds *" [dict get $row why]]}}]]
lappend lines [Row "  structural: incompatible, heads equal (a component)" [Count $sites {expr {[dict get $row structural] eq "incompatible" && [dict get $row head] eq "head-equal"}}]]
lappend lines [Row "    of which some value pair is equal (overlap)" [Count $sites {expr {[dict get $row structural] eq "incompatible" && [dict get $row head] eq "head-equal" && [dict get $row overlap] eq "overlap"}}]]
lappend lines [Row "  structural: refused (a top-level kind with no equality)" [Count $sites {expr {[dict get $row structural] eq "refused"}}]]
lappend lines [Row "  structural: unknown (a component of no fixed kind)" [Count $sites {expr {[dict get $row unknown] eq "-" && [dict get $row structural] eq "unknown"}}]]
lappend lines [Row "  overlap: disjoint (always false or refused)" [Count $sites {expr {[dict get $row unknown] eq "-" && [dict get $row overlap] eq "disjoint"}}]]
lappend lines [Row "  compatible structurally, never equal (integer domains, List lengths)" [Count $sites {expr {[dict get $row structural] eq "compatible" && [dict get $row overlap] eq "disjoint"}}]]
lappend lines [Row "  first census: empty-only" [Count $sites {expr {[dict get $row kinded] eq "empty-only"}}]]
lappend lines [Row "  first census: disjoint" [Count $sites {expr {[dict get $row kinded] eq "disjoint"}}]]
lappend lines [Row "an operand of no fixed kind" [Count $sites {expr {[dict get $row unknown] ne "-"}}]]
lappend lines ""
lappend lines {*}[Header definedness]
foreach class {total partial undefined unknown} {
    lappend lines [Row $class [Count $sites [list expr "\[dict get \$row defined\] eq \"$class\""]]]
}

# 2. Unknown origins.
lappend lines "" "## 2. Sites with an operand of no fixed kind, by origin" ""
lappend lines {*}[Header "origin (other operand)"]
set origins [lsort -unique [lmap row $sites {
    if {[dict get $row unknown] eq "-"} continue
    list [dict get $row unknown] [dict get $row other]
}]]
foreach pair $origins {
    lassign $pair origin other
    lappend lines [Row "$origin ($other)" [Count $sites [list expr "\[dict get \$row unknown\] eq \"$origin\" && \[dict get \$row other\] eq \"$other\""]]]
}

# 3. Policies.
lappend lines "" "## 3. What each policy rejects" ""
lappend lines {*}[Header policy]
lappend lines [Row "head rule (kinds, declarations, shapes), generic HIR" [Count $sites {expr {[dict get $row head] eq "head-disjoint"}}]]
lappend lines [Row "overlap rule (no equal value pair), generic HIR" [Count $sites {expr {[dict get $row unknown] eq "-" && [dict get $row overlap] eq "disjoint" && [dict get $row structural] ne "refused"}}]]
lappend lines [Row "structural rule (incompatible), generic HIR" [Count $sites {expr {[dict get $row structural] eq "incompatible"}}]]
lappend lines [Row "first census Level 1 (disjoint, empty-only), generic HIR" [Count $sites {expr {[dict get $row kinded] in {disjoint empty-only}}}]]
lappend lines [Row "refusal of a top-level kind with no equality" [Count $sites {expr {[dict get $row structural] eq "refused"}}]]
lappend lines [Row "structural rule, further sites only an instance shows" [Count $sites {expr {[dict get $row structural] ne "incompatible" && [dict get $row instStructural] eq "incompatible"}}]]
lappend lines [Row "  of which an operand is a declared any" [Count $sites {expr {[dict get $row structural] ne "incompatible" && [dict get $row instStructural] eq "incompatible" && [string match *declared-any* [dict get $row unknown]]}}]]
lappend lines [Row "  of which an operand is an untyped parameter" [Count $sites {expr {[dict get $row structural] ne "incompatible" && [dict get $row instStructural] eq "incompatible" && [string match *untyped* [dict get $row unknown]]}}]]
lappend lines [Row "relational: two untyped parameters" [Count $sites {expr {[dict get $row unknown] eq "untyped+untyped"}}]]
lappend lines [Row "  of which an instance is incompatible" [Count $sites {expr {[dict get $row unknown] eq "untyped+untyped" && [dict get $row instStructural] eq "incompatible"}}]]
lappend lines [Row "restrictive: every operand of no fixed kind" [Count $sites {expr {[dict get $row unknown] ne "-"}}]]
lappend lines [Row "  less declared any" [Count $sites {expr {[dict get $row unknown] ne "-" && ![string match *declared-any* [dict get $row unknown]]}}]]
lappend lines [Row "  less declared any and imprint variables" [Count $sites {expr {[dict get $row unknown] ne "-" && ![string match *declared-any* [dict get $row unknown]] && ![string match *imprint* [dict get $row unknown]]}}]]

# 4. Concrete contracts.
lappend lines "" "## 4. Concrete contracts a concrete-inference policy would infer" ""
proc Kinds {types} {
    set kinds {}
    foreach t [split $types ,] {
        set t [string trim $t]
        regsub {\{length: [0-9]+\}$} $t {} t
        regsub {^int\[.*\]$} $t int t
        if {$t ni $kinds} { lappend kinds $t }
    }
    return $kinds
}
proc PCount {rows predicate} {
    set counts [dict create]
    foreach row $rows {
        if {[apply [list {row} $predicate] $row]} {
            dict incr counts [dict get $row area]
            dict incr counts all
        }
    }
    return $counts
}
lappend lines {*}[Header parameters]
lappend lines [Row "untyped parameters compared with an operand of fixed kind" [PCount $params {expr 1}]]
lappend lines [Row "  no inferred contract today" [PCount $params {expr {[dict get $row checked] eq "-" && [dict get $row trusted] eq "-"}}]]
lappend lines [Row "  an inferred contract today" [PCount $params {expr {[dict get $row checked] ne "-" || [dict get $row trusted] ne "-"}}]]
lappend lines [Row "  compared with more than one kind (a conflict)" [PCount $params {expr {[llength [Kinds [dict get $row types]]] > 1}}]]
lappend lines [Row "  compared with a List, set or struct type (List invariance)" [PCount $params {expr {[regexp {List\[|ImmutableSet\[|struct\{} [dict get $row types]]}}]]
lappend lines [Row "  compared with an integer domain" [PCount $params {expr {[string match *int\\\[* [dict get $row types]]}}]]
lappend lines [Row "  the first parameter (a method receiver)" [PCount $params {expr {[dict get $row first]}}]]

set text [join $lines \n]
if {$out eq ""} {
    puts $text
} else {
    set f [open $out w]
    fconfigure $f -encoding utf-8
    puts $f $text
    close $f
}

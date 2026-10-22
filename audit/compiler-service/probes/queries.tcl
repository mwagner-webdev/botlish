# queries.tcl -- which semantic queries does the existing front end answer,
# on valid and on broken programs? (COMPILER-SERVICE-CENSUS.md, "Query
# capability matrix")
#
#   tclsh9.0 audit/compiler-service/probes/queries.tcl
#
# Each case is a small application (main.bot, and util.bot where the case
# needs a module), analyzed leniently by lib.tcl's cs::analyze, then asked,
# at a marked position of main.bot:
#
#   construct   the innermost HIR expression's kind and its AST node id (or,
#               with no HIR, whether the recovered AST still has the node)
#   resolve     the BindingId a reference resolves to
#   type        its type, as hir::types::show prints it
#   definition  the declaring binding's origin
#   references  every reference to that binding in the analysis
#   diagnostics the diagnostics whose range holds the position
#   topic       their Compilerpedia topics
#
# and prints one row per case: "yes" where the answer exists, "-" where it
# does not. It then checks the stable symbol key the census proposes,
# {module, AST node id of the declaration}: distinct for same-named
# declarations in different modules and scopes, and equal across an edit
# that moves the declaration.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $here lib.tcl]
cs::load $root

set dir [file normalize [file tempdir]]
set util "fn f(n: int) -> int:\n    n * 10\n\nfn g(s: str) -> str:\n    s\n"

# NAME {MAIN-TEXT UTIL-TEXT MARKER}: the query is made at MARKER's first
# character in main.bot ("|" marks it and is removed).
set cases [list \
    valid [list "import util\n\nfn add(a: int, b: int) -> int:\n    a + b\n\nx = add(1, util::f(2))\n|x\n" $util] \
    unfinished-expression [list "import util\n\nfn add(a: int, b: int) -> int:\n    a +\n\nx = add(1, util::f(2))\n|x\n" $util] \
    unfinished-declaration [list "import util\n\nfn add(a: int, b: int) ->\n\nx = add(1, util::f(2))\n|x\n" $util] \
    unresolved-import [list "import util\nimport nosuch\n\nfn add(a: int, b: int) -> int:\n    a + b\n\nx = add(1, util::f(2))\n|x\n" $util] \
    unknown-identifier [list "import util\n\nfn add(a: int, b: int) -> int:\n    a + nosuch\n\nx = add(1, util::f(2))\n|x\n" $util] \
    type-mismatch [list "import util\n\nfn add(a: int, b: int) -> int:\n    a + b\n\nx = add(1, util::f(|\"two\"))\nx\n" $util] \
    multiple-errors [list "import util\n\nfn add(a: int, b: int) -> int:\n    a + nosuch\n\nx = add(1, util::f(\"two\"))\ny = util::g(3)\n|x\n" $util] \
    edited-declaration [list "import util\n\nfn add(a: int, b: int) -> int:\n    a + b\n\nx = add(1, |util::f(2))\nx\n" \
        "fn f(n: str) -> int:\n    10\n\nfn g(s: str) -> str:\n    s\n"] \
]

proc put {rel text} {
    global dir
    set ch [open [file join $dir $rel] w]
    fconfigure $ch -encoding utf-8 -translation lf
    puts -nonewline $ch $text
    close $ch
}

proc mark {text} {
    set i [string first | $text]
    set before [string range $text 0 [expr {$i - 1}]]
    set line [expr {[regexp -all \n $before] + 1}]
    set column [expr {$i - ([string last \n $before] + 1) + 1}]
    return [list [string replace $text $i $i] $line $column]
}

proc yes {cond} { return [expr {$cond ? "yes" : "-"}] }

puts [format "%-24s %-9s %-10s %-8s %-6s %-11s %-11s %-12s %-6s  %s" case status construct resolve type definition references diagnostics topic detail]
foreach {name spec} $cases {
    lassign $spec mainText utilText
    lassign [mark $mainText] text line column
    put main.bot $text
    put util.bot $utilText
    set r [cs::analyze [file join $dir main.bot] -warnings off]
    if {[dict get $r hir] ne ""} {
        hir::activate [dict get $r hir]
    }
    set q [cs::query $r [file join $dir main.bot] $line $column]
    set construct [yes [dict exists $q kind]]
    if {$construct eq "-" && [dict get $r ast] ne ""} {
        # No HIR: is the statement still in the recovered AST?
        set construct [expr {[llength [dict get $r ast body]] > 0 ? "ast only" : "-"}]
    }
    set detail ""
    if {[dict exists $q kind]} {
        set detail "[dict get $q kind] [dict get $q node] : [dict get $q type]"
    }
    set codes [lmap d [dict get $r diagnostics] {lindex [dict get $d code] end}]
    puts [format "%-24s %-9s %-10s %-8s %-6s %-11s %-11s %-12s %-6s  %s" $name [dict get $r status] $construct \
        [yes [expr {[dict getdef $q binding ""] ne ""}]] [yes [dict exists $q type]] \
        [yes [dict exists $q definition]] [yes [expr {[llength [dict getdef $q references {}]] > 0}]] \
        "[llength [dict get $q diagnostics]] here/[llength $codes]" [yes [expr {[dict get $q topics] ne ""}]] \
        "$detail; all: $codes"]
}

# --- the stable symbol key --------------------------------------------------
#
# KEY = {MODULE NODE}: MODULE the canonical namespace ("" for the entry
# program), NODE the AST node id of the declaring statement (a binding's
# origin's `node`; a parameter's is FN()/(PARAM)).

proc SymbolKeys {r} {
    set hir [dict get $r hir]
    set keys [dict create]
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding kind] in {root ambient}} continue
        set origin [dict get $binding origin]
        if {[lindex $origin 0] ne "file"} continue
        set path [dict get [hir::sourceFile $hir [lindex $origin 1]] path]
        set module [expr {[lindex $origin 1] eq "f1" ? "" : [file rootname [file tail $path]]}]
        set node [dict get [lrange $origin 2 end] node]
        dict lappend keys [list $module $node] $b
    }
    return $keys
}

put main.bot "import util\n\nfn f(n: int) -> int:\n    x = n\n    x\n\nfn h(n: int) -> int:\n    x = n + 1\n    x\n\nf(1) + h(2) + util::f(3)\n"
put util.bot $util
set r1 [cs::analyze [file join $dir main.bot] -warnings off]
set keys1 [SymbolKeys $r1]
set shared [dict filter $keys1 script {k bs} {expr {[llength $bs] > 1}}]
puts "\nsymbol keys: [dict size $keys1] keys for [llength [concat {*}[dict values $keys1]]] source bindings; keys naming more than one binding: [dict size $shared]"
puts "  same name f, different modules: [dict exists $keys1 [list {} f()]] and [dict exists $keys1 [list util f()]] (1 and 1: two keys)"
puts "  same name x, different functions: [dict exists $keys1 [list {} f()/x=]] and [dict exists $keys1 [list {} h()/x=]] (1 and 1: two keys)"
# Move every declaration down two lines and insert a function in util: the
# keys of the moved declarations must be unchanged, their BindingIds need not.
put main.bot "import util\n\n# moved\n\nfn f(n: int) -> int:\n    x = n\n    x\n\nfn h(n: int) -> int:\n    x = n + 1\n    x\n\nf(1) + h(2) + util::f(3)\n"
put util.bot "fn zero() -> int:\n    0\n\n$util"
set r2 [cs::analyze [file join $dir main.bot] -warnings off]
set keys2 [SymbolKeys $r2]
set kept 0
set moved 0
dict for {k bs} $keys1 {
    if {[dict exists $keys2 $k]} {
        incr kept
        if {[dict get $keys2 $k] ne $bs} { incr moved }
    }
}
puts "  after moving every declaration and adding one before them: $kept of [dict size $keys1] keys survive; $moved of them now name a different BindingId"
file delete -force $dir

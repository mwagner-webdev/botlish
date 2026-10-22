# bodyfacts.tcl -- does an edit of a module function's body, with its
# signature unchanged, change what its importers are told? (COMPILER-SERVICE-
# CENSUS.md, "Incrementality alternatives")
#
#   tclsh9.0 audit/compiler-service/probes/bodyfacts.tcl
#
# Each row analyzes an entry program against one version of a module `c`
# (an in-memory workspace: lib.tcl's overlay) and prints the importer's
# diagnostics. Rows of one group differ only in c's function body, or in
# whether its signature is annotated. If any group's diagnostics differ,
# reusing an importer's analysis because a module's interface text is
# unchanged would be unsound.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $here lib.tcl]
cs::load $root
set d [file join [file normalize [file tempdir]] ws]

proc show {label r} {
    set diags [lmap x [dict get $r diagnostics] {
        if {[dict get $x severity] ne "error"} continue
        string cat [lindex [dict get $x code] end] " " [file tail [dict get $x file]]:[dict get $x line]
    }]
    puts [format "  %-40s %-9s %s" $label [dict get $r status] [expr {$diags eq "" ? "(no error)" : $diags}]]
}

puts "bounds of std::list::at(xs, c::pick()) with xs = \[10, 20, 30\]:"
set main "import c\nimport std::list\n\nxs = \[10, 20, 30\]\nstd::list::at(xs, c::pick())\n"
foreach {label ctext} {
    "declared -> int, body 2" "fn pick() -> int:\n    2\n"
    "declared -> int, body 7" "fn pick() -> int:\n    7\n"
    "unannotated, body 2" "fn pick():\n    2\n"
    "unannotated, body 7" "fn pick():\n    7\n"
} {
    show $label [cs::analyze $d/main.bot -overlay [list $d/main.bot $main $d/c.bot $ctext] -warnings off]
}

puts "an unannotated function's inferred result reaching a typed parameter:"
set main "import c\n\nfn use(n: int) -> int:\n    n\n\nuse(c::pick())\n"
foreach {label ctext} {
    "unannotated, body 2" "fn pick():\n    2\n"
    "unannotated, body \"s\"" "fn pick():\n    \"s\"\n"
} {
    show $label [cs::analyze $d/main.bot -overlay [list $d/main.bot $main $d/c.bot $ctext] -warnings off]
}

puts "completion facts: pick(1) of a function declaring `errors Boom`:"
set main "import c\n\nx = c::pick(1)\nx\n"
foreach {label ctext} {
    "body: fail when n > 1" "error Boom\nfn pick(n: int) -> int errors Boom:\n    if n > 1:\n        fail Boom\n    n\n"
    "body: fail when n > 0" "error Boom\nfn pick(n: int) -> int errors Boom:\n    if n > 0:\n        fail Boom\n    n\n"
    "body: never fails" "error Boom\nfn pick(n: int) -> int errors Boom:\n    n\n"
} {
    show $label [cs::analyze $d/main.bot -overlay [list $d/main.bot $main $d/c.bot $ctext] -warnings off]
}

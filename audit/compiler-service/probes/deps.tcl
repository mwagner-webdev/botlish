# deps.tcl -- what does one edit change, and what does the front end redo?
# (COMPILER-SERVICE-CENSUS.md, "Incrementality alternatives")
#
#   tclsh9.0 audit/compiler-service/probes/deps.tcl
#
# A four-file application (main imports a and b; a and b both import c; main
# imports the standard list) is analyzed, then each edit below is applied as
# an overlay and analyzed again in the same warm process. For each edit it
# reports:
#
#   parsed     the files surface::parse lexed and parsed again (the loader's
#              parse cache, surface/modules.tcl's `parsed`, keeps a module's
#              AST while its text is unchanged; the entry file is always
#              parsed)
#   cache      what the front-end cache (surface/cache.tcl) did for the
#              edited program: hit, miss, stale
#   changed    the files whose diagnostics or whose expressions' types
#              changed, judged per AST node id (which survives edits
#              elsewhere, surface/ast.tcl "Node ids")
#   ids        whether main.bot's HIR expression ids survived the edit
#   value      the program's value (compile backend)
#
# The edits are the census's seven: a body edit with the signature
# unchanged, an exported declaration's type, a declaration several modules
# use, an import statement, a transitive dependency, a standard-library
# module, and a syntax error.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $here lib.tcl]
cs::load $root

set dir [file normalize [file tempdir]]
set cacheDir [file join $dir cache]
set files [dict create \
    main.bot "import a\nimport b\nimport std::list\n\nfn total(x: int, y: int) -> int:\n    x + y\n\nstd::list::get(\[total(a::fa(1), b::fb(2))\], 0, 0)\n" \
    a.bot "import c\n\nfn fa(n: int) -> int:\n    c::base(n) + 1\n" \
    b.bot "import c\n\nfn fb(n: int) -> int:\n    c::base(n) * 2\n" \
    c.bot "fn base(n: int) -> int:\n    n + 10\n"]
dict for {rel text} $files {
    set ch [open [file join $dir $rel] w]
    fconfigure $ch -encoding utf-8 -translation lf
    puts -nonewline $ch $text
    close $ch
}
set libList [file join $root stdlib list.bot]
set listText [core::ReadFile $libList]

set edits [list \
    "body edit, signature unchanged (a::fa)" \
        [list a.bot "import c\n\nfn fa(n: int) -> int:\n    c::base(n) + 2\n"] \
    "exported declaration's type (c::base takes str)" \
        [list c.bot "fn base(n: str) -> int:\n    10\n"] \
    "declaration used by several modules (c::base body)" \
        [list c.bot "fn base(n: int) -> int:\n    n + 11\n"] \
    "import statement removed (main drops b)" \
        [list main.bot "import a\nimport std::list\n\nfn total(x: int, y: int) -> int:\n    x + y\n\nstd::list::get(\[total(a::fa(1), b::fb(2))\], 0, 0)\n"] \
    "transitive dependency only (c gains a function)" \
        [list c.bot "fn base(n: int) -> int:\n    n + 10\n\nfn unused() -> int:\n    0\n"] \
    "standard-library module (stdlib/list.bot comment)" \
        [list $libList "# edited\n$listText"] \
    "syntax error in a module (a.bot)" \
        [list a.bot "import c\n\nfn fa(n: int) -> int:\n    c::base(n) +\n"] \
    "entry-file edit that adds a line above everything" \
        [list main.bot "# a comment line\nimport a\nimport b\nimport std::list\n\nfn total(x: int, y: int) -> int:\n    x + y\n\nstd::list::get(\[total(a::fa(1), b::fb(2))\], 0, 0)\n"] \
]

# Counts surface::parse calls by file.
rename surface::parse surface::RealParse
proc surface::parse {source args} {
    set file [lindex $args 0]
    if {$file ne "" && $file ne "-recover"} {
        lappend ::parsedFiles [file tail $file]
    }
    return [surface::RealParse $source {*}$args]
}

# NODE-ID -> type, and the diagnostics, per file of an analysis.
proc Facts {r} {
    set facts [dict create]
    foreach d [dict get $r diagnostics] {
        dict lappend facts [file tail [dict get $d file]] diag [list [dict get $d code] [dict get $d line] [dict get $d message]]
    }
    set hir [dict get $r hir]
    if {$hir eq ""} { return $facts }
    hir::activate $hir
    dict for {e node} [dict get $hir exprs] {
        set origin [dict get $node origin]
        if {[lindex $origin 0] ne "file"} continue
        set file [file tail [dict get [hir::sourceFile $hir [lindex $origin 1]] path]]
        set id [dict get [lrange $origin 2 end] node]
        # A function type prints its block's ExprId (block(e12)/1 -> int),
        # which shifts with any edit before it: compare the type without it.
        regsub -all {block\(e[0-9]+\)} [hir::types::show [hir::typeOf $hir $e]] block type
        dict set facts $file type $id $type
    }
    return $facts
}

# main.bot's expressions as NODE-ID -> ExprId.
proc MainIds {r} {
    set ids [dict create]
    set hir [dict get $r hir]
    if {$hir eq ""} { return $ids }
    dict for {e node} [dict get $hir exprs] {
        set origin [dict get $node origin]
        if {[lindex $origin 0] eq "file" && [lindex $origin 1] eq "f1"} {
            dict set ids [dict get [lrange $origin 2 end] node] $e
        }
    }
    return $ids
}

proc Value {r} {
    if {[dict get $r status] ni {ok}} { return "-" }
    set hir [dict get $r hir]
    hir::activate $hir
    if {[catch {core::value::show [core::compiler::evalHir $hir] 1} v]} { return "run-time error" }
    return $v
}

# The front-end cache's verdict for the program with OVERLAY applied: a
# strict, cached compilation (compileProgramFile) of it.
proc CacheVerdict {overlay} {
    surface::cache::resetStats
    catch {
        cs::withOverlay $overlay {
            surface::modules::compileProgramFile [file join $::dir main.bot] -cache $::cacheDir \
                -warnings off -warning-channel ""
        }
    }
    set s [surface::cache::stats]
    foreach {k word} {hits hit stale stale misses miss} {
        if {[dict get $s $k]} { return $word }
    }
    return "-"
}

set main [file join $dir main.bot]
set parsedFiles {}
set base [cs::analyze $main -warnings off]
set baseFacts [Facts $base]
set baseIds [MainIds $base]
CacheVerdict {}
puts "baseline: status [dict get $base status], value [Value $base], cache warmed"

foreach {label edit} $edits {
    lassign $edit rel text
    set path [expr {[file pathtype $rel] eq "absolute" ? $rel : [file join $dir $rel]}]
    set overlay [list $path $text]
    set ::parsedFiles {}
    set r [cs::analyze $main -overlay $overlay -warnings off]
    set parsed [lsort -unique $::parsedFiles]
    set facts [Facts $r]
    set changed {}
    foreach file [lsort -unique [concat [dict keys $baseFacts] [dict keys $facts]]] {
        if {[dict getdef $baseFacts $file {}] ne [dict getdef $facts $file {}]} {
            lappend changed $file
        }
    }
    set ids [MainIds $r]
    set same 0
    set total 0
    dict for {node e} $baseIds {
        if {[dict exists $ids $node]} {
            incr total
            if {[dict get $ids $node] eq $e} { incr same }
        }
    }
    puts "\n$label"
    puts "   status   [dict get $r status]   value [Value $r]"
    puts "   parsed   $parsed"
    puts "   cache    [CacheVerdict $overlay]"
    puts "   changed  [expr {$changed eq "" ? "(nothing)" : $changed}]"
    puts "   ids      main.bot: $same of $total surviving AST nodes keep their HIR expression id"
    foreach d [dict get $r diagnostics] {
        puts "   diag     [lindex [dict get $d code] end] [file tail [dict get $d file]]:[dict get $d line] [string range [dict get $d message] 0 80]"
    }
    # Restore the baseline's parse cache and front-end cache entry (the
    # verdict above stored the edited program's entry) for the next edit.
    set ::parsedFiles {}
    cs::analyze $main -warnings off
    CacheVerdict {}
}

file delete -force $dir

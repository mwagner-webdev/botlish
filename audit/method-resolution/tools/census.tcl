# census.tcl -- what a checkout reports for programs whose method-style
# calls the decision rejects (METHOD-RESOLUTION-DIAGNOSTICS-MILESTONE-2.md,
# "Starting census").
#
#   tclsh9.0 audit/method-resolution/tools/census.tcl ?-root DIR? ?-full 1?
#       ?-before DIR? ?-only CASE,...? ?-write DIR?
#
# Writes each case's application (a main.bot and its modules) to a
# temporary directory, runs `main.tcl -check main.bot` of the checkout DIR
# (default: this one) in it, and prints one line per case: the diagnostics
# the check reports, `KIND FILE:LINE:COLUMN` each, in order. -full 1 prints
# the whole report instead. -before DIR prints the line of the checkout DIR
# first, then this one's: the before and after of a change. It reads only
# the printed report, never the compiler's internals. -write DIR only writes
# each case's application to DIR/CASE (for invariance.tcl, which compares
# what two front ends decide for them).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set options [dict create -root $root -full 0 -before "" -only "" -write ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

set cases [dict create]
proc case {name files} {
    global cases
    dict set cases $name $files
}

# The application of the context cases (SFIAE-MILESTONE-1.md, section 2).
set envt "context trait Env:\n    fn tick(n: int) -> int\n"
set ca "context struct CA:\n    k: int\n\nfn tick(n: int, context c: CA) -> int:\n    n + c.k\n"
set cb "context struct CB:\n    k: int\n\nfn tick(n: int, context c: CB) -> int:\n    n * c.k\n"
set ctx [dict create env.bot $envt ca.bot $ca cb.bot $cb \
    alpha.bot "import env\n\nfn f(x: int, context e: env::Env) -> int:\n    e.tick(x)\n" \
    beta.bot "fn f(x: int) -> int:\n    x + 1000\n" gamma.bot "fn f(x: str) -> int:\n    0\n"]
set two "with context ca::CA{k: 1}\nwith context cb::CB{k: 2}\n"
case sfiae-ambiguous-providers [dict merge $ctx [dict create main.bot "import ca\nimport cb\nimport alpha\nimport beta\n\n${two}7.f()\n"]]
case sfiae-missing-context [dict merge $ctx [dict create main.bot "import ca\nimport cb\nimport alpha\nimport beta\n\n7.f()\n"]]
case sfiae-in-a-body [dict merge $ctx [dict create main.bot "import ca\nimport cb\nimport alpha\nimport beta\n\nfn h() -> int:\n    7.f()\n\nh()\n"]]
case sfiae-unique-missing [dict merge $ctx [dict create main.bot "import ca\nimport cb\nimport alpha\nimport gamma\n\n7.f()\n"]]
case sfiae-unique-ambiguous [dict merge $ctx [dict create main.bot "import ca\nimport cb\nimport alpha\nimport gamma\n\n${two}7.f()\n"]]

# No applicable candidate.
set aa "fn size(s: List\[int\]) -> int:\n    0\n\nfn pick(a: int, b: int) -> int:\n    a + b\n"
set zz "fn size(s: List\[str\]) -> int:\n    1\n\nfn pick(a: str, b: int) -> int:\n    b\n"
set none [dict create aa.bot $aa zz.bot $zz]
case none-alone [dict merge $none [dict create main.bot "import aa\nimport zz\n\n(7).size()\n"]]
case none-inner [dict merge $none [dict create main.bot "import aa\nimport zz\n\n(1).pick((7).size())\n"]]
case none-operator [dict merge $none [dict create main.bot "import aa\nimport zz\n\nfn h() -> int:\n    (7).size() + 1\nh()\n"]]
case none-placeholder-errors [dict create two.bot "fn at(m: str, i: int) -> int:\n    0\n" main.bot "import std::list\nimport two\n\nfn first() -> int:\n    (5).at(0)\n\nfirst()\n"]
case none-poisoned-arg [dict merge $none [dict create main.bot "import aa\nimport zz\n\nfn h() -> int:\n    (1.5).pick((5).q)\nh()\n"]]
case none-receiver-dependent-arg [dict merge $none [dict create main.bot "import aa\nimport zz\n\nfn h() -> int:\n    (1.5).pick((7).size())\nh()\n"]]
case none-independent-error [dict merge $none [dict create main.bot "import aa\nimport zz\n\nfn take_str(s: str) -> int:\n    0\n\nfn h() -> int:\n    a = (7).size()\n    a + take_str(9)\nh()\n"]]
case nested-failing [dict merge $none [dict create main.bot "import aa\nimport zz\n\n(\"q\").pick((7).size())\n"]]

# Ambiguous, and the uses of its result: the placeholder aa::size is an Int,
# the other candidate a Float64.
set sizes [dict create aa.bot "fn size(s: List\[int\]) -> int:\n    0\n" zz.bot "fn size(s: List\[int\]) -> Float64:\n    1.5\n"]
case amb-argument [dict merge $sizes [dict create main.bot "import aa\nimport zz\n\nfn take(n: Float64) -> Float64:\n    n\n\ntake(\[1, 2\].size())\n"]]
case amb-operator [dict merge $sizes [dict create main.bot "import aa\nimport zz\n\nfn h() -> Float64:\n    \[1, 2\].size() + 0.5\nh()\n"]]
case amb-result [dict merge $sizes [dict create main.bot "import aa\nimport zz\n\nfn h() -> Float64:\n    \[1, 2\].size()\nh()\n"]]
case amb-binding [dict merge $sizes [dict create main.bot "import aa\nimport zz\n\nfn h() -> Float64:\n    n = \[1, 2\].size()\n    n + 0.5\nh()\n"]]
case amb-condition [dict merge $sizes [dict create main.bot "import aa\nimport zz\n\nfn h() -> int:\n    if \[1, 2\].size() < 0.5:\n        1\n    else:\n        2\nh()\n"]]
case amb-receiver [dict merge $sizes [dict create main.bot "import aa\nimport zz\n\nfn half(n: Float64) -> Float64:\n    n\n\n\[1, 2\].size().half()\n"]]
case amb-list [dict merge $sizes [dict create main.bot "import aa\nimport zz\n\nfn h() -> List\[Float64\]:\n    \[\[1, 2\].size(), 1.5\]\nh()\n"]]
case amb-several [dict merge $sizes [dict create main.bot "import aa\nimport zz\n\nfn h() -> int:\n    a = \[1\].size()\n    b = (5).size()\n    0\n\nfn k() -> Float64:\n    \[2\].size()\nh()\n"]]

# Backward channels: a parameter's contract, an affine argument's move.
set bag "struct Bag:\n    n: int\n\nfn length(b: Bag) -> int:\n    b.n\n"
case amb-untyped-param [dict create bag.bot $bag main.bot "import std::list\nimport std::str\nimport bag\n\nfn g(x):\n    x.length()\n\ng(\[1\])\n"]
set message "struct Message:\n    value: int\n"
set coF "import msg\n\nfn f(c: Coroutine{args: \[msg::Message\], return: int}) -> int:\n    1\n"
case amb-affine-argument [dict create msg.bot $message a.bot $coF b.bot $coF main.bot "import msg\nimport a\nimport b\n\nfn worker(seed: int, resume msg::Message) -> int:\n    m = yield seed\n    m.value\n\nfn h() -> int:\n    coroutine {step} = worker(1)\n    n = step.f()\n    k = step.f()\n    n + k\n\nh()\n"]

# Independent and dependent errors around a rejected call.
set f2 "fn f(x: int, y: int) -> int:\n    x\n"
case amb-independent-arg [dict create alpha.bot $f2 beta.bot $f2 main.bot "import alpha\nimport beta\n\nfn take_str(s: str) -> int:\n    0\n\nfn h() -> int:\n    1.f(take_str(5))\nh()\n"]
case amb-poisoned-arg [dict create alpha.bot $f2 beta.bot $f2 main.bot "import alpha\nimport beta\n\nfn h() -> int:\n    1.f((5).q)\nh()\n"]
case amb-unbound-arg [dict create alpha.bot $f2 beta.bot $f2 main.bot "import alpha\nimport beta\n\nfn h() -> int:\n    1.f(nothere)\nh()\n"]
set pa "fn pick(a: int, b: Float64) -> int:\n    a\n\nfn size(s: List\[int\]) -> int:\n    0\n"
set pb "fn pick(a: int, b: str) -> int:\n    a\n\nfn size(s: List\[int\]) -> Float64:\n    1.5\n"
case nested-dependent [dict create pa.bot $pa pb.bot $pb main.bot "import pa\nimport pb\n\nfn h() -> int:\n    (1).pick(\[1\].size())\nh()\n"]

# A static compile block judged by a placeholder's consequence.
case static-placeholder-cascade [dict create bag.bot $bag main.bot "import std::list\nimport std::str\nimport bag\nimport std::compiler\n\nfn g(x):\n    x.length()\n\nfn k() -> int errors std::compiler::CompilerError:\n    static compile:\n        g(\[1\])\n\nr = k():\n    on std::compiler::CompilerError:\n        0\nr\n"]

# The report of CASE by the checkout FRONT, run in DIR.
proc check {front dir} {
    set ::env(LANG) C.utf8
    set ::env(LC_ALL) C.utf8
    catch {exec [info nameofexecutable] [file join $front main.tcl] -check main.bot 2>@1} output
    # (Paths shown as file names; exec's own note of the exit status left
    # out.)
    regsub {\nchild process exited abnormally$} $output {} output
    return [string map [list "$dir/" ""] $output]
}

# The diagnostics of the report OUTPUT: {KIND FILE:LINE:COLUMN} each. An
# error's text runs from its "   error: " line to the next note, help, error
# or end; its code is the last parenthesized one in it.
proc brief {output} {
    set items {}
    set at ""
    set text ""
    foreach line [concat [split $output \n] [list "   end"]] {
        if {[regexp {^   (error|note|help|ok|end)\M} $line -> what]} {
            if {$at ne "" && [regexp {\((?:CORE SEMANTIC|SURFACE[A-Z ]*) ([A-Z-]+)\)\s*$} $text -> code]} {
                lappend items "$code $at"
            }
            set at ""
            set text ""
            if {$what eq "error"} {
                regexp {^   error: (\S+?:\d+:\d+): } $line -> at
                set text $line
            }
            continue
        }
        if {$at ne ""} {
            append text \n $line
        }
    }
    if {$items eq {}} {
        return [expr {[string match "*   ok*" $output] ? "ok" : [string trim $output]}]
    }
    return [join $items {, }]
}

set only [split [dict get $options -only] ,]
if {[dict get $options -write] ne ""} {
    dict for {name files} $cases {
        if {$only ne {} && $name ni $only} continue
        set dir [file join [dict get $options -write] $name]
        file mkdir $dir
        dict for {file text} $files {
            set f [open [file join $dir $file] w]
            fconfigure $f -encoding utf-8 -translation lf
            puts -nonewline $f $text
            close $f
        }
    }
    exit 0
}
set tmp [file tempdir botlish-method-census]
try {
    dict for {name files} $cases {
        if {$only ne {} && $name ni $only} continue
        set dir [file join $tmp $name]
        file mkdir $dir
        dict for {file text} $files {
            set f [open [file join $dir $file] w]
            fconfigure $f -encoding utf-8 -translation lf
            puts -nonewline $f $text
            close $f
        }
        set fronts [list [dict get $options -root]]
        if {[dict get $options -before] ne ""} {
            set fronts [list [dict get $options -before] [dict get $options -root]]
        }
        set labels [expr {[llength $fronts] > 1 ? {before after} : {{}}}]
        foreach front $fronts label $labels {
            set cwd [pwd]
            cd $dir
            try {
                set output [check [file normalize $front] $dir]
            } finally {
                cd $cwd
            }
            if {[dict get $options -full]} {
                puts "=== $name $label\n$output"
            } else {
                puts [format "%-30s %-7s %s" $name $label [brief $output]]
            }
        }
    }
} finally {
    file delete -force $tmp
}

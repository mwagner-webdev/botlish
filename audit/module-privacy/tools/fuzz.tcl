#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated applications against an independent model of module
# privacy and CONTEXT-RESOURCE-ESCAPE
# (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md).
#
#   tclsh9.0 audit/module-privacy/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#
# Each program is an application of a module `u`, a consumer -- the entry
# program, or a module `v` the entry program imports -- and the entry
# program, varied along every dimension the two rules read:
#
#   u     an airlock (contextualized: a retaining C call mediated by its own
#         context), an ordinary module (no raw authority) or a designated
#         `direct module`; three structs, Open (a C pointer and an Int, open
#         representation), Sealed (an opaque struct holding a pointer) and
#         Plain (an Int), each public or private; 2..5 functions, each
#         public or private, taking nothing, an Int, a pointer, an Open or a
#         Plain, returning an Int, a pointer, a native view, a List of
#         pointers, an Open, a Sealed or a Plain (declared, or inferred), and
#         requiring u's context or not; and public value-returning wrappers
#         of private pointer helpers;
#   the consumer   ordinary, designated direct (its own unmediated C call),
#         or an airlock itself (its own mediated C call); uses of u's
#         functions -- a qualified call, a method-syntax call, the function
#         taken as a value -- with the arguments built in the consumer (an
#         Open or a Plain constructed there), and Open values taken apart
#         (projected or destructured) there; uses of private members on
#         purpose (an illegal access).
#
# The model, written from the specification and never from hir/privacy.tcl
# or hir/resourceescape.tcl, predicts from the generated source alone:
#
#   * PRIVATE-ACCESS when the consumer names a private member (a qualified
#     call or value, a construction of a private struct: the loader's, which
#     ends the compilation) or calls a private function with method syntax
#     where no other function of the name is visible and the receiver has no
#     such field, or takes apart a value of a private struct (which only a
#     public function exposing it can have handed out);
#   * PRIVATE-TYPE-ESCAPE when a public function of u names a private
#     struct in its declared parameter or result, or infers one;
#   * otherwise the CONTEXT-RESOURCE-ESCAPE warnings, as the set of
#     exposing declarations: u must be an airlock; a public function the
#     consumer calls whose result is raw (a pointer, a view, a List of
#     pointers, an Open), or whose argument is raw when the consumer has no
#     raw authority of its own; one taken as a value whose result is raw;
#     the struct Open, public, constructed or taken apart by the consumer.
#     Sealed (opaque) and Plain are never raw; private members never cross.
#
# The compiler's -strict 0 diagnostic kinds (restricted to the two privacy
# kinds; any other diagnostic is a disagreement) and its warnings' declared
# names must equal the model's. The last line is "programs N ... disagreements
# D"; the exit status is 1 if D > 0. Nothing runs a program.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 60
set seed0 1
set dump 0
while {[lindex $args 0] in {-n -seed -dump}} {
    switch -- [lindex $args 0] {
        -n { set n [lindex $args 1] }
        -seed { set seed0 [lindex $args 1] }
        -dump { set dump [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}

# A private directory (never the working directory: concurrent runs, AGENTS.md).
set scratch [file tempdir module-privacy-fuzz]

proc rnd {n} {
    set ::rng [expr {($::rng * 1103515245 + 12345) % 2147483648}]
    return [expr {($::rng / 65536) % $n}]
}
proc pick {list} {
    return [lindex $list [rnd [llength $list]]]
}
proc chance {percent} {
    return [expr {[rnd 100] < $percent}]
}

set ptr {std::ffi::c::Ptr[std::ffi::c::Void]}

# The type spelling of a value kind in u (QUAL "u::" from outside).
proc typeOf {kind {qual ""}} {
    switch -- $kind {
        int     { return int }
        ptr     { return $::ptr }
        view    { return "NativeView\[${qual}Record\]" }
        listptr { return "List\[$::ptr\]" }
        open    { return ${qual}Open }
        sealed  { return ${qual}Sealed }
        plain   { return ${qual}Plain }
    }
}

# 1 if a value of KIND carries raw foreign representation its holder may read.
proc raw {kind} {
    return [expr {$kind in {ptr view listptr open}}]
}

# The struct a value of KIND is, "" for none.
proc structOf {kind} {
    return [dict getdef {open Open sealed Sealed plain Plain} $kind ""]
}

# One program: {FILES MODEL}.
proc generate {seed} {
    set ::rng $seed
    set uKind [pick {airlock airlock airlock ordinary direct}]
    set vKind [pick {ordinary ordinary direct airlock}]
    if {$uKind eq "direct"} {
        # (A call into a designated module is a direct edge: its callers
        # are low-level too.)
        set vKind direct
    }
    set vModule [chance 50]
    set private [dict create Open [chance 12] Sealed [chance 12] Plain [chance 12]]
    # u's functions.
    set functions {}
    set count [expr {2 + [rnd 4]}]
    for {set i 1} {$i <= $count} {incr i} {
        set results {int ptr listptr open sealed plain}
        if {$uKind ne "ordinary"} {
            lappend results view
        }
        set result [pick $results]
        set param [pick {none none int ptr open plain}]
        set ctx [expr {$uKind eq "airlock" && ($result eq "view" || [chance 50])}]
        dict set functions f$i [dict create private [chance 30] result $result param $param \
            ctx $ctx declared [expr {$result eq "view" || [chance 80]}] wrapper ""]
    }
    # Public wrappers of private pointer helpers: values only.
    foreach name [dict keys $functions] {
        set f [dict get $functions $name]
        if {[dict get $f private] && [dict get $f result] in {ptr listptr} && [dict get $f param] eq "none" && [chance 60]} {
            dict set functions w$name [dict create private 0 result int param none ctx [dict get $f ctx] \
                declared 1 wrapper $name]
        }
    }
    # The u module's text.
    set u ""
    if {$uKind eq "direct"} {
        append u "direct module\n"
    }
    append u "import std::binary\nimport std::binary::native\nimport std::ffi::c\n\n"
    append u "extern c fn handle() -> $::ptr\nextern c fn use(p: $::ptr) -> std::ffi::c::Int\n\n"
    append u "layout Record:\n    size 8\n    align 8\n    field p: $::ptr at 0\n\n"
    append u "opaque context struct Ctx:\n    ready: bool\n\nfn create() -> Ctx:\n    Ctx \{ready: true\}\n\n"
    foreach {s fields} [list Open "    p: $::ptr\n    n: int\n" Sealed "    p: $::ptr\n" Plain "    n: int\n"] {
        append u [expr {[dict get $private $s] ? "private " : ""}]
        append u [expr {$s eq "Sealed" ? "opaque " : ""}] "struct $s:\n$fields\n"
    }
    switch -- $uKind {
        airlock { append u "fn mediated(context c: Ctx) -> std::ffi::c::Int:\n    p = handle()\n    p.use()\n\n" }
        direct  { append u "fn raw() -> std::ffi::c::Int:\n    p = handle()\n    p.use()\n\n" }
    }
    dict for {name f} $functions {
        set params {}
        if {[dict get $f param] ne "none"} {
            lappend params "x: [typeOf [dict get $f param]]"
        }
        if {[dict get $f ctx]} {
            lappend params "context c: Ctx"
        }
        set head "[expr {[dict get $f private] ? "private " : ""}]fn ${name}([join $params {, }])"
        if {[dict get $f declared]} {
            append head " -> [typeOf [dict get $f result]]"
        }
        if {[dict get $f result] eq "view"} {
            append head " errors NativeViewNull"
        }
        set body [dict get {
            int     "    1\n"
            ptr     "    handle()\n"
            view    "    p = handle()\n    std::binary::native::view(Record, p)\n"
            listptr "    \[handle()\]\n"
            open    "    Open \{p: handle(), n: 1\}\n"
            sealed  "    Sealed \{p: handle()\}\n"
            plain   "    Plain \{n: 1\}\n"
        } [dict get $f result]]
        if {[dict get $f wrapper] ne ""} {
            set body "    r = [dict get $f wrapper]()\n    1\n"
        }
        append u "$head:\n$body\n"
    }
    # The consumer's uses.
    set uses {}
    set illegal 0
    set lines {}
    set useCount [expr {1 + [rnd 4]}]
    set public [lmap {name f} $functions {if {[dict get $f private]} continue; set name}]
    set hidden [lmap {name f} $functions {if {![dict get $f private]} continue; set name}]
    for {set k 1} {$k <= $useCount} {incr k} {
        # Mostly public members; now and then a private one, on purpose.
        if {$hidden ne {} && ($public eq {} || [chance 12])} {
            set name [pick $hidden]
        } else {
            set name [pick $public]
        }
        set f [dict get $functions $name]
        set form [pick {call call method value}]
        if {$form eq "method" && [dict get $f param] ni {int ptr}} {
            set form call
        }
        if {$form eq "value" && [dict get $f ctx]} {
            set form call
        }
        set body {}
        set arg ""
        switch -- [dict get $f param] {
            int   { set arg 1 }
            ptr   { lappend body "    a = std::ffi::c::null\[std::ffi::c::Void\]()"; set arg a }
            open  { lappend body "    a = u::Open \{p: std::ffi::c::null\[std::ffi::c::Void\](), n: 1\}"; set arg a
                    lappend uses [list construct Open] }
            plain { lappend body "    a = u::Plain \{n: 1\}"; set arg a
                    lappend uses [list construct Plain] }
        }
        set handler ""
        if {[dict get $f result] eq "view"} {
            set handler ":\n        on NativeViewNull:\n            return 0"
        }
        switch -- $form {
            call   { lappend body "    r = u::${name}($arg)$handler" }
            method { lappend body "    r = ${arg}.${name}()$handler" }
            value  { lappend body "    g = u::$name" }
        }
        if {$form ne "value" && [dict get $f result] eq "open" && [chance 60]} {
            if {[chance 50]} {
                lappend body "    \{p, n\} = r"
            } else {
                lappend body "    m = r.n"
            }
            lappend uses [list takeapart Open]
        }
        lappend body "    0"
        lappend lines "fn use${k}() -> int:\n[join $body \n]\n"
        lappend uses [list $form $name]
    }
    # The consumer's own raw authority.
    set own ""
    switch -- $vKind {
        direct  { set own "extern c fn keep(p: $::ptr) -> std::ffi::c::Int\n\nfn own() -> std::ffi::c::Int:\n    q = std::ffi::c::null\[std::ffi::c::Void\]()\n    keep(q)\n\n" }
        airlock { set own "extern c fn keep(p: $::ptr) -> std::ffi::c::Int\n\nopaque context struct VCtx:\n    ready: bool\n\nfn vcreate() -> VCtx:\n    VCtx \{ready: true\}\n\nfn own(context c: VCtx) -> std::ffi::c::Int:\n    q = std::ffi::c::null\[std::ffi::c::Void\]()\n    keep(q)\n\n" }
    }
    set consumer [expr {$vKind eq "direct" ? "direct module\n" : ""}]
    append consumer "import std::ffi::c\nimport u\n\n$own[join $lines \n]"
    if {$vModule} {
        # (The entry program's installation of u's context is a call into
        # u: a direct edge when u is designated.)
        set main [expr {$uKind eq "direct" ? "direct module\n" : ""}]
        append main "import u\nimport v\n\nwith context u::create()\n"
        if {$vKind eq "airlock"} {
            append main "with context v::vcreate()\n"
        }
        append main "0\n"
        set files [list u.bot $u v.bot $consumer main.bot $main]
        set consumerUnit v
    } else {
        append consumer "\nwith context u::create()\n"
        if {$vKind eq "airlock"} {
            append consumer "with context vcreate()\n"
        }
        append consumer "0\n"
        set files [list u.bot $u main.bot $consumer]
        set consumerUnit ""
    }
    return [list $files [Model $uKind $vKind $private $functions $uses]]
}

# The model's prediction: {kinds {KIND ...} warnings {DECLARATION ...}}.
proc Model {uKind vKind private functions uses} {
    set loader 0
    set hir {}
    foreach use $uses {
        lassign $use form what
        switch -- $form {
            construct {
                if {[dict get $private $what]} { set loader 1 }
            }
            call - value {
                if {[dict get $functions $what private]} { set loader 1 }
            }
            method {
                # No other function of the name is visible, and an Int or a
                # pointer has no field: the private access is HIR's.
                if {[dict get $functions $what private]} { lappend hir PRIVATE-ACCESS }
            }
            takeapart {
                # A value of another module's private struct (one a public
                # function hands out: PRIVATE-TYPE-ESCAPE) has no field
                # another module may read: HIR's private access too.
                if {[dict get $private $what]} { lappend hir PRIVATE-ACCESS }
            }
        }
    }
    if {$loader} {
        # The loader rejects every private reference before HIR is built.
        return [dict create kinds PRIVATE-ACCESS warnings {}]
    }
    dict for {name f} $functions {
        if {[dict get $f private]} continue
        foreach kind [list [dict get $f param] [dict get $f result]] {
            set s [structOf $kind]
            if {$s ne "" && [dict get $private $s]} {
                lappend hir PRIVATE-TYPE-ESCAPE
            }
        }
    }
    if {$hir ne {}} {
        return [dict create kinds [lsort -unique $hir] warnings {}]
    }
    set warnings {}
    if {$uKind eq "airlock"} {
        set ownAuthority [expr {$vKind in {direct airlock}}]
        foreach use $uses {
            lassign $use form what
            switch -- $form {
                call - method {
                    set f [dict get $functions $what]
                    if {[raw [dict get $f result]] || ([raw [dict get $f param]] && !$ownAuthority)} {
                        lappend warnings u::$what
                    }
                }
                value {
                    if {[raw [dict get $functions $what result]]} {
                        lappend warnings u::$what
                    }
                }
                construct - takeapart {
                    if {$what eq "Open"} {
                        lappend warnings u::Open
                    }
                }
            }
        }
    }
    return [dict create kinds {} warnings [lsort -unique $warnings]]
}

# What the compiler says of the application FILES written into DIR.
proc observe {dir files} {
    foreach {name text} $files {
        set channel [open [file join $dir $name] w]
        fconfigure $channel -encoding utf-8 -translation lf
        puts -nonewline $channel $text
        close $channel
    }
    set main [file join $dir main.bot]
    if {[catch {surface::readProgramFile $main -warnings default -warning-channel "" -cache "" -strict 0} hir options]} {
        set kinds [lmap d [dict getdef $options -diagnostics [list [dict create errorcode [dict get $options -errorcode]]]] {
            lindex [dict get $d errorcode] end
        }]
        return [dict create kinds [lsort -unique $kinds] warnings {}]
    }
    set kinds [lsort -unique [lmap d [hir::recovery::reported $hir] {dict get $d kind}]]
    set warnings {}
    if {$kinds eq {}} {
        # (Warnings are found for a program with no diagnostic: -strict 0
        # keeps them, so a clean program is compiled again to be warned.)
        set hir [surface::readProgramFile $main -warnings default -warning-channel "" -cache ""]
        foreach w [hir::warnings::of $hir] {
            if {[dict get $w code] eq "CONTEXT-RESOURCE-ESCAPE"} {
                lappend warnings [dict get $w data declaration]
            }
        }
    }
    return [dict create kinds $kinds warnings [lsort -unique $warnings]]
}

set disagreements 0
set counts [dict create accepted 0 rejected 0 warned 0]
for {set i 0} {$i < $n} {incr i} {
    set seed [expr {$seed0 * 100003 + $i}]
    lassign [generate $seed] files model
    set dir [file join $scratch p$i]
    file mkdir $dir
    if {[catch {observe $dir $files} seen]} {
        set seen [dict create error $seen]
    }
    set ok [expr {![dict exists $seen error] && $seen eq $model}]
    if {[dict exists $seen kinds]} {
        if {[dict get $seen kinds] eq {}} {
            dict incr counts accepted
            if {[dict get $seen warnings] ne {}} {
                dict incr counts warned
            }
        } else {
            dict incr counts rejected
        }
    }
    if {!$ok || $dump} {
        if {!$ok} {
            incr disagreements
            puts "DISAGREE seed $seed"
        }
        foreach {name text} $files {
            puts "--- $name\n$text"
        }
        puts "model:    $model"
        puts "compiler: $seen"
    }
    file delete -force $dir
}
file delete -force $scratch
puts "programs $n accepted [dict get $counts accepted] (warned [dict get $counts warned]) rejected [dict get $counts rejected] disagreements $disagreements"
exit [expr {$disagreements > 0}]

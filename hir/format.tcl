# format.tcl -- human-readable HIR, for debugging and tests.
#
#   hir::format HIR ?-origins 1?
#
# One line per expression, children indented by four spaces:
#
#   program s2 binds b1 x, b2 y
#   e1 bind b1 x : int
#       e2 const 10 : int
#   e3 bind b2 y : int
#       e4 call native(+) : int
#           e5 ref b3 + : native +
#           e6 ref b1 x : int
#           e7 const 1 : int
#
# Line shapes (then ": TYPE", then flags):
#
#   eN const LITERAL
#   eN ref BINDING NAME                  ref ? NAME when unresolved
#   eN bind BINDING NAME
#   eN block SCOPE (PARAMS) captures (BINDINGS)
#   eN call TARGET                       native(NAME), block(eN) or generic;
#                                        "= true"/"= false" when decided
#   eN if                                followed by "then SCOPE ..." and
#                                        "else SCOPE ..." lines with the
#                                        refinements proven on entry
#   eN loop SCOPE
#   eN return -> eN / break -> eN / continue -> eN
#   eN ok / eN error
#
# Flags: unbound, before-binding, deferred (bound when a closure runs),
# duplicate, unreachable. With -origins 1 each line ends with @ORIGIN.

namespace eval hir::format {}

proc hir::format {hir args} {
    set options [dict create -origins 0]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "hir::format: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set lines {}
    set top [dict get $hir top]
    lappend lines [string trimright "[dict get $hir scopes $top kind] $top [hir::format::Binds $hir $top]"]
    foreach e [dict get $hir roots] {
        hir::format::Expr $hir $e 0 [dict get $options -origins] lines
    }
    return [join $lines \n]
}

proc hir::format::BindingLabel {hir b} {
    return "$b [dict get $hir bindings $b name]"
}

proc hir::format::BindingList {hir bindings} {
    return [join [lmap b $bindings {BindingLabel $hir $b}] {, }]
}

proc hir::format::Binds {hir s} {
    set locals [lmap b [dict get $hir scopes $s bindings] {
        if {[dict get $hir bindings $b kind] ne "local"} continue
        set b
    }]
    if {$locals eq ""} {
        return ""
    }
    return "binds [BindingList $hir $locals]"
}

proc hir::format::Facts {hir pairs} {
    set shown {}
    foreach {b fact} $pairs {
        lappend shown "[BindingLabel $hir $b] : [hir::types::show $fact]"
    }
    if {$shown eq ""} {
        return ""
    }
    return "refines [join $shown {, }]"
}

proc hir::format::Line {hir e text indent origins linesVar {typed 1}} {
    upvar 1 $linesVar lines
    set node [dict get $hir exprs $e]
    set line "[string repeat {    } $indent]$e $text"
    if {$typed} {
        append line " : [hir::types::show [hir::typeOf $hir $e]]"
    }
    set flags {}
    switch -- [dict get $node kind] {
        ref {
            if {[dict get $node binding] eq ""} {
                lappend flags unbound
            } else {
                switch -- [dict get $node init] {
                    no       { lappend flags before-binding }
                    deferred { lappend flags deferred }
                }
            }
        }
        bind {
            if {[dict get $node duplicate]} {
                lappend flags duplicate
            }
        }
    }
    if {![dict get $node reachable]} {
        lappend flags unreachable
    }
    if {$flags ne ""} {
        append line " [join $flags { }]"
    }
    if {$origins} {
        append line " @[dict get $node origin]"
    }
    lappend lines $line
}

proc hir::format::Target {hir target} {
    lassign $target kind id
    switch -- $kind {
        native  { return "native([dict get $hir symbols $id name])" }
        block   { return "block($id)" }
        default { return generic }
    }
}

proc hir::format::Expr {hir e indent origins linesVar} {
    upvar 1 $linesVar lines
    set node [dict get $hir exprs $e]
    set inner [expr {$indent + 1}]
    switch -- [dict get $node kind] {
        const {
            Line $hir $e "const [dict get $node literal]" $indent $origins lines
        }
        ref {
            set b [dict get $node binding]
            set label [expr {$b eq "" ? "? [dict get $node name]" : [BindingLabel $hir $b]}]
            Line $hir $e "ref $label" $indent $origins lines
        }
        bind {
            Line $hir $e "bind [BindingLabel $hir [dict get $node binding]]" $indent $origins lines
            Expr $hir [dict get $node value] $inner $origins lines
        }
        block {
            set text "block [dict get $node bodyScope] ([BindingList $hir [dict get $node params]])"
            append text " captures ([BindingList $hir [dict get $node captures]])"
            set binds [Binds $hir [dict get $node bodyScope]]
            if {$binds ne ""} {
                append text " $binds"
            }
            Line $hir $e $text $indent $origins lines
            foreach child [dict get $node body] {
                Expr $hir $child $inner $origins lines
            }
        }
        call {
            set text "call [Target $hir [dict get $node target]]"
            switch -- [dict get $node known] {
                1 { append text " = true" }
                0 { append text " = false" }
            }
            Line $hir $e $text $indent $origins lines
            Expr $hir [dict get $node callee] $inner $origins lines
            foreach arg [dict get $node args] {
                Expr $hir $arg $inner $origins lines
            }
        }
        if {
            Line $hir $e if $indent $origins lines
            Expr $hir [dict get $node condition] $inner $origins lines
            foreach {role outcome} {then 1 else 0} {
                set s [dict get $node ${role}Scope]
                set header "[string repeat {    } $inner]$role $s"
                foreach part [list [Binds $hir $s] [Facts $hir [dict get $node refinements $outcome]]] {
                    if {$part ne ""} {
                        append header " $part"
                    }
                }
                lappend lines $header
                foreach child [dict get $node ${role}Body] {
                    Expr $hir $child [expr {$inner + 1}] $origins lines
                }
            }
        }
        loop {
            set text "loop [dict get $node bodyScope]"
            set binds [Binds $hir [dict get $node bodyScope]]
            if {$binds ne ""} {
                append text " $binds"
            }
            Line $hir $e $text $indent $origins lines
            foreach child [dict get $node body] {
                Expr $hir $child $inner $origins lines
            }
        }
        return - break - continue {
            set target [dict get $node target]
            set text "[dict get $node kind] -> [expr {$target eq "" ? "?" : $target}]"
            Line $hir $e $text $indent $origins lines
            if {[dict get $node kind] ne "continue" && [dict get $node value] ne ""} {
                Expr $hir [dict get $node value] $inner $origins lines
            }
        }
        ok - error {
            Line $hir $e [dict get $node kind] $indent $origins lines
            Expr $hir [dict get $node value] $inner $origins lines
        }
    }
}

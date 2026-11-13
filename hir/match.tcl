# match.tcl -- exhaustive case selection (PORTABILITY-EXHAUSTIVE-MATCH-
# MILESTONE-1.md).
#
#   hir::match::verify HIRVAR     the match checks, after typing (hir::check)
#   hir::match::chains HIR        => {MATCH CHAIN ...}: every match of HIR
#   hir::match::chain HIR E       => the chain of match E (Chain), or a
#                                    {malformed REASON} dict
#   hir::match::validate HIR      => "" or why HIR's matches and selections
#                                    are not the shape a match builds: the
#                                    readers' check (HIR text, interchange)
#
# A match is no node kind. surface/lower.tcl's Match writes it as
#
#     if ^true:                                  carries `match 1`
#         match#N = SUBJECT
#         if enum#is(match#N, "ID", "C1"):       the first arm's selection
#             P1 = enum#payload(match#N, "ID", "C1")
#             ...
#         else:
#             if enum#is(match#N, "ID", "C2"):
#                 ...
#             else:
#                 enum#unmatched()
#
# and hir/resolve.tcl's MatchSyntax resolves each arm's case name to the
# enum's declaration identity and the case (core/enums.tcl). Every analysis
# and backend reads that as the ordinary code it is: one evaluation of the
# scrutinee, an `if` per arm, the arms' values joined as an `if`'s are, an
# affine scrutinee moved by whichever arm takes its payload. What none of
# them can see is what the source promised: that the arms name the cases of
# the scrutinee's enum, each exactly once. That is this file's check.
#
# The rule (the report, section 3). For a match whose scrutinee has the
# static type of enum E -- in the program's own typing walk, never a
# semantic instance's (a match is checked once, whatever callers it has):
#
#   * every arm names a case of E (an arm naming a case of another enum F is
#     a TYPE error naming both enums: nominal identity, never a spelling);
#   * no case is named twice (MATCH-DUPLICATE-CASE, at the later arm);
#   * every case of E is named (MATCH-NOT-EXHAUSTIVE, at the match, listing
#     the missing cases in E's declaration order: EnumCases(E), the closed
#     set the registry keeps, never the cases a program happens to build).
#
# A scrutinee of any other type -- a non-enum, `any` (an untyped parameter's
# value), a join of different enums -- is a TYPE error: a match never tests
# a type at run time. Coverage is the declared case set whatever the
# analyses know of the value: an exact-case fact (hir::enums::caseFact)
# never excuses an arm. An arm whose case name resolution could not resolve
# was diagnosed there (MATCH-NOT-A-CASE, UNKNOWN-ENUM-CASE); the match's
# coverage is then not stated (it would only restate that mistake).
#
# The shape (Chain): the checks above read the chain exactly as Match builds
# it, and so does every reader of HIR that did not build it (validate):
# a selection's payload is taken only as the first statement of its own
# selection's then-branch, from the same scrutinee binding, for the same
# case -- never anywhere else. enum#payload checks the identity at run time
# too (core/enums.tcl, runtime/ops.rs), so even a HIR built around the
# checks reads no other case's payload; the check makes such a HIR a
# rejection rather than a run-time failure.

namespace eval hir::match {}

# The root native call E calls ("" for anything else).
proc hir::match::Native {hir e} {
    if {$e eq "" || ![dict exists $hir exprs $e] || [dict get $hir exprs $e kind] ne "call"} {
        return ""
    }
    set target [dict getdef [dict get $hir exprs $e] target ""]
    if {[lindex $target 0] eq "native"} {
        return [dict get [hir::symbol $hir [lindex $target 1]] name]
    }
    set callee [dict get $hir exprs [dict get $hir exprs $e callee]]
    if {[dict get $callee kind] ne "ref" || [dict getdef $callee binding ""] eq ""} {
        return ""
    }
    set binding [dict get $hir bindings [dict get $callee binding]]
    if {[dict get $binding kind] ne "root"} {
        return ""
    }
    if {[dict getdef $binding symbol ""] ne ""} {
        return [dict get [hir::symbol $hir [dict get $binding symbol]] name]
    }
    return [dict get $binding name]
}

# The String literal of constant expression E, or "" with OKVAR set to 0.
proc hir::match::Str {hir e okVar} {
    upvar 1 $okVar ok
    if {$e eq "" || [dict get $hir exprs $e kind] ne "const"} {
        set ok 0
        return ""
    }
    set literal [dict get $hir exprs $e literal]
    if {[lindex $literal 0] ne "str" || [llength $literal] != 2} {
        set ok 0
        return ""
    }
    return [lindex $literal 1]
}

# 1 if E is a reference to binding B.
proc hir::match::RefersTo {hir e b} {
    return [expr {$e ne "" && [dict get $hir exprs $e kind] eq "ref" && [dict get $hir exprs $e binding] eq $b}]
}

# The selection call E of NATIVE on binding B: {id ID case CASE} of its
# constants, or "" when E is no such call.
proc hir::match::Selection {hir e native b} {
    if {[Native $hir $e] ne $native} {
        return ""
    }
    set args [dict get $hir exprs $e args]
    if {[llength $args] != 3 || ![RefersTo $hir [lindex $args 0] $b]} {
        return ""
    }
    set ok 1
    set id [Str $hir [lindex $args 1] ok]
    set case [Str $hir [lindex $args 2] ok]
    if {!$ok} {
        return ""
    }
    return [dict create id $id case $case]
}

# The chain of match E (an `if` carrying `match`): a dict
#
#   subject  the binding the scrutinee is bound to
#   bind     the binding statement (its value: the scrutinee)
#   arms     {test E id ID case CASE origin ORIGIN take E payload B
#            resolved 0|1} per arm, in written order: its enum#is call, its
#            case, the origin of its case name, its enum#payload call and
#            the binding the payload is bound to, and whether ID and CASE
#            name a declared case
#   end      the enum#unmatched call that ends the chain
#
# or {malformed REASON}: E is not the shape surface/lower.tcl's Match builds.
proc hir::match::chain {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "if" || ![dict exists $node match]} {
        return [dict create malformed "not a match"]
    }
    set condition [dict get $hir exprs [dict get $node condition]]
    if {[dict get $condition kind] ne "ref" || [dict get $condition binding] eq ""
            || [dict get $hir bindings [dict get $condition binding] kind] ne "root"
            || [dict get $hir bindings [dict get $condition binding] name] ne "true"} {
        return [dict create malformed "a match's block is not `if true`"]
    }
    set then [dict get $node thenBody]
    if {[llength $then] != 2} {
        return [dict create malformed "a match's block is not the scrutinee's binding and the chain of its selections"]
    }
    lassign $then bind level
    if {[dict get $hir exprs $bind kind] ne "bind" || [dict get $hir exprs $bind binding] eq ""} {
        return [dict create malformed "a match's scrutinee is not bound"]
    }
    set subject [dict get $hir exprs $bind binding]
    set arms {}
    while 1 {
        set levelNode [dict get $hir exprs $level]
        if {[dict get $levelNode kind] ne "if"} {
            if {[Native $hir $level] eq "enum#unmatched" && [dict get $hir exprs $level args] eq {}} {
                break
            }
            return [dict create malformed "a match's chain of selections does not end in enum#unmatched"]
        }
        set test [dict get $levelNode condition]
        set selection [Selection $hir $test enum#is $subject]
        if {$selection eq ""} {
            return [dict create malformed "a selection of a match is not enum#is of its scrutinee and a case"]
        }
        set body [dict get $levelNode thenBody]
        set take [lindex $body 0]
        if {$take eq "" || [dict get $hir exprs $take kind] ne "bind"} {
            return [dict create malformed "an arm of a match does not start by taking its payload"]
        }
        set takeCall [dict get $hir exprs $take value]
        set taken [Selection $hir $takeCall enum#payload $subject]
        if {$taken eq "" || $taken ne $selection} {
            return [dict create malformed "an arm of a match takes the payload of another case than it selects"]
        }
        set id [dict get $selection id]
        set case [dict get $selection case]
        set resolved [expr {[hir::enums::declared $id] && [hir::enums::hasCase $id $case]}]
        lappend arms [dict create test $test id $id case $case \
            origin [dict get $hir exprs $test origin] take $takeCall \
            payload [dict get $hir exprs $take binding] resolved $resolved]
        set else [dict get $levelNode elseBody]
        if {[llength $else] != 1} {
            return [dict create malformed "a selection's else-branch of a match is not the next selection"]
        }
        set level [lindex $else 0]
    }
    if {$arms eq {}} {
        return [dict create malformed "a match has no arm"]
    }
    return [dict create subject $subject bind $bind arms $arms end $level]
}

# {MATCH CHAIN ...}: every match of HIR, by ExprId order (its id's number),
# with its chain (chain).
proc hir::match::chains {hir} {
    set found {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "if" && [dict exists $node match]} {
            lappend found $e
        }
    }
    set result {}
    foreach e [lsort -dictionary $found] {
        lappend result $e [chain $hir $e]
    }
    return $result
}

# "" when every match of HIR has the shape Match builds and every
# enum#payload call is the payload of its own selection (Chain), else why
# not. The check a reader of HIR it did not build makes (HIR text,
# interchange): what the source checks proved of the matches still holds of
# what it reads, or it is no program.
proc hir::match::validate {hir} {
    set guarded [dict create]
    foreach {e chain} [chains $hir] {
        if {[dict exists $chain malformed]} {
            return "match $e: [dict get $chain malformed]"
        }
        foreach arm [dict get $chain arms] {
            dict set guarded [dict get $arm take] 1
        }
        set problem [Coverage $hir $chain]
        if {$problem ne ""} {
            return "match $e: $problem"
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "call" && [Native $hir $e] eq "enum#payload" && ![dict exists $guarded $e]} {
            return "the enum#payload call $e is no match arm's payload (a payload is taken only under its own case's selection)"
        }
    }
    return ""
}

# "" when CHAIN's arms name every case of their enum exactly once, else why
# not: the readers' form of the coverage check (validate), which no
# scrutinee type decides -- the arms must all name one declared enum.
proc hir::match::Coverage {hir chain} {
    set ids [lsort -unique [lmap arm [dict get $chain arms] {dict get $arm id}]]
    if {[llength $ids] != 1} {
        return "its arms name cases of several enums ([join $ids {, }])"
    }
    set id [lindex $ids 0]
    if {![hir::enums::declared $id]} {
        return "enum $id is not declared"
    }
    set seen [dict create]
    foreach arm [dict get $chain arms] {
        set case [dict get $arm case]
        if {![hir::enums::hasCase $id $case]} {
            return "enum $id has no case $case"
        }
        if {[dict exists $seen $case]} {
            return "it names ${id}::$case twice"
        }
        dict set seen $case 1
    }
    set missing [lmap case [hir::enums::cases $id] {
        if {[dict exists $seen $case]} continue
        set case
    }]
    if {$missing ne {}} {
        return "it does not name [join [lmap c $missing {string cat $id :: $c}] {, }]"
    }
    return ""
}

# The checks of every match of HIR (the header's rule), once its program is
# typed: reported as diagnostics of the match. A match whose shape is not
# Match's is the compiler's own failure (a source program's matches are
# built by it): an internal diagnostic.
proc hir::match::verify {hirVar} {
    upvar 1 $hirVar hir
    set guarded [dict create]
    foreach {e chain} [chains $hir] {
        if {[dict exists $chain malformed]} {
            Internal hir "the compiler built a malformed match: [dict get $chain malformed]" $e
            continue
        }
        foreach arm [dict get $chain arms] {
            dict set guarded [dict get $arm take] 1
        }
        Check hir $e $chain
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "call" && [Native $hir $e] eq "enum#payload" && ![dict exists $guarded $e]} {
            Internal hir "the enum#payload call is no match arm's payload (a payload is taken only under its own case's selection)" $e
        }
    }
}

# The diagnostics of match E, whose chain is CHAIN (verify).
proc hir::match::Check {hirVar e chain} {
    upvar 1 $hirVar hir
    set bind [dict get $chain bind]
    set value [dict get $hir exprs $bind value]
    set arms [dict get $chain arms]
    set type [hir::types::Unrefined [hir::typeOf $hir $value]]
    if {[hir::types::Poisoned $hir $value] || [hir::types::Poisoned $hir $bind]} {
        # The scrutinee is a value an earlier diagnostic rejected: it has no
        # type to select a case of.
        return
    }
    set resolved [lmap arm $arms {
        if {![dict get $arm resolved]} continue
        set arm
    }]
    set complete [expr {[llength $resolved] == [llength $arms]}]
    if {$type eq "never"} {
        # The scrutinee never completes (or the match is unreachable): no
        # value is ever selected. The arms are still held to one enum and to
        # naming its cases once each.
        set ids [lsort -unique [lmap arm $resolved {dict get $arm id}]]
        if {[llength $ids] != 1} {
            return
        }
        set id [lindex $ids 0]
    } elseif {[hir::types::IsEnum $type]} {
        set id [lindex $type 1]
    } else {
        hir::Diagnose hir TYPE [ScrutineeMessage $hir $type] $value
        return
    }
    set seen [dict create]
    set foreign 0
    foreach arm $resolved {
        set case [dict get $arm case]
        if {[dict get $arm id] ne $id} {
            incr foreign
            hir::DiagnoseAt hir TYPE [format {case %s::%s is a case of enum %s, but the matched value is of enum %s (a match names the cases of its value's enum only)} \
                [hir::enums::display [dict get $arm id]] $case [hir::enums::display [dict get $arm id]] \
                [hir::enums::display $id]] [dict get $arm test] [dict get $arm origin]
            continue
        }
        if {[dict exists $seen $case]} {
            set first [dict get $seen $case]
            dict lappend hir diagnostics [dict create kind MATCH-DUPLICATE-CASE \
                message [format {case %s::%s is already handled by an earlier arm of this match (at %s): a match names each case exactly once} \
                    [hir::enums::display $id] $case [hir::originLocation $hir $first]] \
                expr [dict get $arm test] origin [dict get $arm origin] related [list $first]]
            continue
        }
        dict set seen $case [dict get $arm origin]
    }
    if {!$complete} {
        # An arm names no case (resolution said why): what the match covers
        # is not stated.
        return
    }
    set missing [lmap case [hir::enums::cases $id] {
        if {[dict exists $seen $case]} continue
        set case
    }]
    if {$missing ne {}} {
        hir::Diagnose hir MATCH-NOT-EXHAUSTIVE [format {this match does not handle every case of enum %s: %s %s not handled (a match names every case of its enum exactly once; add an arm for %s)} \
            [hir::enums::display $id] \
            [join [lmap c $missing {string cat [hir::enums::display $id] :: $c}] {, }] \
            [expr {[llength $missing] == 1 ? "is" : "are"}] \
            [expr {[llength $missing] == 1 ? "it" : "each"}]] $e
    }
}

# Reports MESSAGE at E as the compiler's own failure (an internal
# diagnostic: never a program's problem, never a static block's rejection).
proc hir::match::Internal {hirVar message e} {
    upvar 1 $hirVar hir
    dict lappend hir diagnostics [dict create kind MATCH-INVALID message $message expr $e internal 1]
}

# {ID CASE} when expression E reads a match arm's payload binding (bound to
# the arm's enum#payload of case CASE of enum ID), else "": what a
# diagnostic about the value names it by.
proc hir::match::PayloadCase {hir e} {
    if {$e eq "" || [dict get $hir exprs $e kind] ne "ref"} {
        return ""
    }
    set b [dict get $hir exprs $e binding]
    if {$b eq "" || [dict get $hir bindings $b kind] ne "local"} {
        return ""
    }
    set bind [dict getdef [dict get $hir bindings $b] declaredBy ""]
    if {$bind eq "" || [dict get $hir exprs $bind kind] ne "bind"} {
        return ""
    }
    set value [dict get $hir exprs $bind value]
    if {[Native $hir $value] ne "enum#payload"} {
        return ""
    }
    set args [dict get $hir exprs $value args]
    set ok 1
    set id [Str $hir [lindex $args 1] ok]
    set case [Str $hir [lindex $args 2] ok]
    if {!$ok || ![hir::enums::hasCase $id $case]} {
        return ""
    }
    return [list $id $case]
}

# The TYPE message of a match whose scrutinee has the static type TYPE, no
# enum's.
proc hir::match::ScrutineeMessage {hir type} {
    if {$type eq "any" || [hir::types::kindOf $type] in {"" any}} {
        return [format {a match selects a case of a value whose enum is known statically, but the matched value's type is %s: a match never tests a type at run time (give the value an enum type, e.g. annotate the parameter it comes from)} \
            [hir::semantic::ShowType $hir $type]]
    }
    return [format {a match selects a case of an enum value, but the matched value is %s} \
        [hir::semantic::ShowType $hir $type]]
}

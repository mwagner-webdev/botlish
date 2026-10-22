# refinements.tcl -- scalar refinements: compiler-known integer facts on a
# type (DECIMAL-ROUNDED-MILESTONE-1.md, "Scalar refinements").
#
#   DecimalRounded{minDecimalsPreserved: 2}
#   DecimalRounded{minDecimalsPreserved: 2, maxDecimalsPreserved: 4}
#
# A scalar refinement is a *family* of types over one base type, each member
# naming the base plus a canonical set of integer-valued parameters -- facts
# the compiler knows about every value of the type. It is a type
# refinement with scalar parameters, not a generic: the parameters are
# numbers, never types, and a member is one type, never an instantiation.
# A family is declared here, by the compiler, never by a program; this
# milestone declares exactly one, DecimalRounded. Everything else about
# refinements is generic over the schema below:
#
#   * declaration   `families`: the base, the parameters (each required or
#                   optional, its range, the order its implication uses and
#                   what an absent one means) and the constraints between
#                   parameters;
#   * validation    Resolve, every problem a diagnostic
#                   (REFINEMENT-PARAMETER);
#   * canonical form  {srefined FAMILY FACTS}, FACTS the present parameters in
#                   schema order (Canonical), so equal types are equal values;
#   * implication   Implies: weakening is subtyping (hir::types::subtype);
#   * joins         Lub, Glb (hir::types::lub, FnGlb);
#   * formatting    Show / Parse: the source spelling, which HIR text writes
#                   and reads back (hir/format.tcl, hir/read.tcl);
#   * decay         the base: every member is a subtype of its family's base
#                   type, which states no fact (a bare DecimalRounded, of
#                   unknown precision), so forgetting every fact is ordinary
#                   subtyping too; minting a fact never is (a value acquires
#                   one only by a proof, hir/decimal.tcl).
#
# A parameter's *order* says which values are stronger facts: `atLeast` (the
# parameter bounds a property from below; a larger value is a stronger fact,
# so A implies B when A's value is at least B's). An absent optional
# parameter takes its `absent` value in comparisons (`inf`: no bound at all,
# the strongest). Both DecimalRounded parameters are atLeast:
#
#   minDecimalsPreserved  the precision every observation may rely on: a
#                         value correct to 4 places is one correct to 2;
#   maxDecimalsPreserved  the precision observations of the value are
#                         limited to (its observation ceiling): a value whose
#                         observations may be as fine as 6 places (or are
#                         unbounded, absent) may stand where observations are
#                         limited to 4, never the reverse -- dropping a
#                         ceiling would let a later observation see
#                         distinctions the value's type excluded.
#
# A second family, List (LIST-CARDINALITY-REFINEMENTS.md), refines an
# *applied* base: `List[int]{length: 4}` is a List[int] of which the
# compiler knows the exact length. Its parameter's order is `exactly` (an
# equality fact: a value of length 4 is no value of length 3 nor of 5, so A
# implies B only when the two values are equal, two different values join
# to no fact at all, and meet to none). A family over a type constructor
# carries its base type in the canonical form, {srefined FAMILY FACTS
# BASE}: the facts say nothing about the elements, which BASE describes
# (the base is a List form, hir/types.tcl; its element type is the one an
# unrefined List[T] has). A family over a core type (DecimalRounded) keeps
# the three-word form, its base implied by the schema.
#
# Further orders (`atMost` for a magnitude bound) are what later families
# need; the schema keeps that one word.
#
# Where a fact may come from is the family's `interface` (a property of the
# theory, read by hir/types.tcl's ForgetInferred, never a family's name):
#
#   inferred   a fact is minted only by a proof where a refined type is
#              expected (a DecimalRounded constant), so a value carrying one
#              got it from a declaration: an undeclared function result
#              keeps it, like every inferred type;
#   declared   inference mints facts without any annotation (a List
#              literal's length), so a fact crosses a function boundary
#              only as a declared contract: an undeclared result, and the
#              entry types of a semantic instance, forget it -- an
#              implementation's accident never becomes its callers' proof
#              obligation (LIST-CARDINALITY-REFINEMENTS.md, "Function
#              contracts").

namespace eval hir::refinements {
    # FAMILY -> its schema:
    #   base         the core type (core/type.tcl) the facts refine: a value
    #                of every member is a value of it; for a family over a
    #                type constructor (`applied`), the runtime kind of every
    #                base it refines (`list`)
    #   applied      1 when the family refines an applied type, whose base
    #                type every member carries (the file header)
    #   example      a spelling for a message (Example)
    #   interface    inferred | declared (the file header)
    #   params       PARAM -> {required 0|1 min LO max HI order ORDER absent
    #                A}, in canonical order (HI "" for no upper bound)
    #   constraints  {atLeast A B ...}: parameter A, when present, is at
    #                least parameter B
    #   message      for each constraint, what a violation means
    variable families [dict create \
        DecimalRounded [dict create \
            base DecimalRounded applied 0 interface inferred \
            params [dict create \
                minDecimalsPreserved [dict create required 1 min 0 max 1000 order atLeast absent ""] \
                maxDecimalsPreserved [dict create required 0 min 0 max 1000 order atLeast absent inf]] \
            constraints [list [list atLeast maxDecimalsPreserved minDecimalsPreserved \
                "an upper precision bound below the guaranteed precision describes no value: maxDecimalsPreserved must be at least minDecimalsPreserved"]]] \
        List [dict create \
            base list applied 1 interface declared \
            params [dict create \
                length [dict create required 1 min 0 max "" order exactly absent ""]] \
            constraints {}]]
}

# 1 if NAME is a scalar-refinement family.
proc hir::refinements::isFamily {name} {
    variable families
    return [dict exists $families $name]
}

# The schema of FAMILY.
proc hir::refinements::Schema {family} {
    variable families
    return [dict get $families $family]
}

# The base core type of FAMILY.
proc hir::refinements::base {family} {
    return [dict get [Schema $family] base]
}

# 1 if TYPEEXPR (a surface::parser::TypeExpr) is a scalar refinement
# {refine NAME FIELDS} or, of an applied type, {refine NAME FIELDS BASE}
# (surface::parser::ScalarRefinement: `List[int]{length: 4}` is {refine List
# {{length 4}} {List int}}).
proc hir::refinements::IsRefinementExpr {typeExpr} {
    return [expr {[llength $typeExpr] in {3 4} && [lindex $typeExpr 0] eq "refine"}]
}

# 1 if TYPE is a scalar-refined static type {srefined FAMILY FACTS} or
# {srefined FAMILY FACTS BASE}.
proc hir::refinements::IsRefined {type} {
    return [expr {[llength $type] in {3 4} && [lindex $type 0] eq "srefined"}]
}

proc hir::refinements::Family {type} { return [lindex $type 1] }
proc hir::refinements::Facts {type} { return [lindex $type 2] }

# 1 if FAMILY refines an applied type, whose base its members carry.
proc hir::refinements::IsApplied {family} {
    return [dict get [Schema $family] applied]
}

# The base type of the refined TYPE: the type it refines with every fact
# forgotten -- the carried base of a family over a type constructor, the
# schema's base otherwise.
proc hir::refinements::Base {type} {
    if {[llength $type] == 4} {
        return [lindex $type 3]
    }
    return [base [Family $type]]
}

# The interface of FAMILY's facts: inferred or declared (the file header).
proc hir::refinements::Interface {family} {
    return [dict get [Schema $family] interface]
}

# The families, in table order.
proc hir::refinements::Families {} {
    variable families
    return [dict keys $families]
}

# The value of parameter PARAM of the refined TYPE, its schema's `absent`
# value when TYPE does not state it.
proc hir::refinements::fact {type param} {
    set facts [Facts $type]
    if {[dict exists $facts $param]} {
        return [dict get $facts $param]
    }
    return [dict get [Schema [Family $type]] params $param absent]
}

# The canonical refined type of FAMILY with the parameter values FACTS (a
# dict, any order), assumed valid (Problems); a family over a type
# constructor refines the base type BASE (hir/types.tcl's Refine builds
# those, canonicalizing the base).
proc hir::refinements::Canonical {family facts {base ""}} {
    set canonical [CanonicalFacts $family $facts]
    if {[IsApplied $family]} {
        return [list srefined $family $canonical $base]
    }
    return [list srefined $family $canonical]
}

# FACTS (a dict, any order) as FAMILY's canonical facts: the stated
# parameters in schema order, each a canonical integer.
proc hir::refinements::CanonicalFacts {family facts} {
    set canonical [dict create]
    dict for {param spec} [dict get [Schema $family] params] {
        if {[dict exists $facts $param]} {
            dict set canonical $param [expr {[dict get $facts $param] + 0}]
        }
    }
    return $canonical
}

# The problems of FAMILY applied to the written parameters FIELDS (a list of
# {PARAM TEXT}, written order): a list of messages, empty for a valid type.
proc hir::refinements::Problems {family fields} {
    set schema [Schema $family]
    set params [dict get $schema params]
    set problems {}
    set given [dict create]
    set written [dict create]
    foreach field $fields {
        lassign $field param text
        if {![dict exists $params $param]} {
            lappend problems [format {"%s" is not a parameter of %s (its parameters: %s)} \
                $param [Spelling $family] [join [dict keys $params] {, }]]
            continue
        }
        if {[dict exists $written $param]} {
            lappend problems "[Spelling $family] states \"$param\" twice"
            continue
        }
        # Written: a required parameter with a bad value is that problem,
        # not also a missing parameter.
        dict set written $param 1
        if {![regexp {^-?[0-9]+$} $text]} {
            lappend problems "[Spelling $family]'s \"$param\" is an integer, not \"$text\""
            continue
        }
        set spec [dict get $params $param]
        if {[dict get $spec max] eq "" && $text < [dict get $spec min]} {
            lappend problems [format {%s's "%s" must be at least %s, not %s} \
                [Spelling $family] $param [dict get $spec min] $text]
            continue
        }
        if {[dict get $spec max] ne "" && ($text < [dict get $spec min] || $text > [dict get $spec max])} {
            lappend problems [format {%s's "%s" must be from %s to %s, not %s} \
                $family $param [dict get $spec min] [dict get $spec max] $text]
            continue
        }
        dict set given $param $text
    }
    dict for {param spec} $params {
        if {[dict get $spec required] && ![dict exists $written $param]} {
            lappend problems [format {%s requires "%s" (write %s)} [Spelling $family] $param [Example $family]]
        }
    }
    if {$problems ne {}} {
        return $problems
    }
    foreach constraint [dict get $schema constraints] {
        lassign $constraint relation a b message
        if {[dict exists $given $a] && [dict exists $given $b]
                && $relation eq "atLeast" && [dict get $given $a] < [dict get $given $b]} {
            lappend problems "$message ($family{[ShowFacts $given]})"
        }
    }
    return $problems
}

# A spelling of FAMILY with its required parameters, for a message.
proc hir::refinements::Example {family} {
    set fields {}
    dict for {param spec} [dict get [Schema $family] params] {
        if {[dict get $spec required]} {
            lappend fields "$param: N"
        }
    }
    return "[Spelling $family]{[join $fields {, }]}"
}

# FAMILY as a message names it: a family over a type constructor with its
# element written T (List[T]).
proc hir::refinements::Spelling {family} {
    if {[IsApplied $family]} {
        return "$family\[T\]"
    }
    return $family
}

# The canonical facts the type expression FAMILY{FIELDS} states (FIELDS:
# {PARAM TEXT} pairs, surface::parser::TypeExpr's), or a Tcl error
# (REFINEMENT-PARAMETER) naming every problem. APPLIED says whether the
# expression refines an applied type (`List[int]{...}`, BASE given) or a
# bare name (`DecimalRounded{...}`): each family is written one way.
proc hir::refinements::ResolveFacts {family fields applied} {
    variable families
    if {![isFamily $family]} {
        return -code error -errorcode {BOTLISH REFINEMENT-PARAMETER} \
            "\"$family\" has no scalar refinements: NAME{...} refines one of [join [lmap f [dict keys $families] {Spelling $f}] {, }]"
    }
    if {[IsApplied $family] && !$applied} {
        return -code error -errorcode {BOTLISH REFINEMENT-PARAMETER} \
            "[Spelling $family]{...} refines an applied type: write its type argument before the refinement ([Example $family])"
    }
    if {![IsApplied $family] && $applied} {
        return -code error -errorcode {BOTLISH REFINEMENT-PARAMETER} \
            "$family takes no type argument: write [Example $family]"
    }
    set problems [Problems $family $fields]
    if {$problems ne {}} {
        return -code error -errorcode {BOTLISH REFINEMENT-PARAMETER} [join $problems {; }]
    }
    set facts [dict create]
    foreach field $fields {
        dict set facts [lindex $field 0] [lindex $field 1]
    }
    return [CanonicalFacts $family $facts]
}

# The refined type the type expression FAMILY{FIELDS} denotes, for a family
# over a core type (a family over a type constructor is resolved with its
# base, hir::resolve::ResolveTypeExpr and hir::types::Refine), or a Tcl
# error (REFINEMENT-PARAMETER) naming every problem.
proc hir::refinements::Resolve {family fields} {
    return [Canonical $family [ResolveFacts $family $fields 0]]
}

# The error a bare annotation naming FAMILY is: its facts are part of the
# type, so there is no unrefined spelling.
proc hir::refinements::BareMessage {family} {
    return "$family is written with its refinement parameters, which are part of the type: [Example $family]"
}

# 1 if parameter value A is at least B (either may be `inf`).
proc hir::refinements::AtLeast {a b} {
    if {$b eq "inf"} {
        return [expr {$a eq "inf"}]
    }
    if {$a eq "inf"} {
        return 1
    }
    return [expr {$a >= $b}]
}

# 1 if parameter value A (of a parameter of order ORDER) is a fact at least
# as strong as B: atLeast compares them (AtLeast), exactly asks for the same
# value.
proc hir::refinements::Stronger {order a b} {
    if {$order eq "exactly"} {
        return [expr {$a eq $b}]
    }
    return [AtLeast $a $b]
}

# 1 if the facts of the refined type A imply the facts of the refined type
# B: the same family, every parameter of A implying B's (its order). The
# facts only: a base a family carries is the caller's (hir::types::subtype
# relates the bases).
proc hir::refinements::Implies {a b} {
    if {[Family $a] ne [Family $b]} {
        return 0
    }
    return [ImpliesFacts [Family $a] [Facts $a] [Facts $b]]
}

# The value of parameter PARAM of FAMILY in the facts dict FACTS, the
# schema's `absent` value when FACTS does not state it.
proc hir::refinements::FactIn {family facts param} {
    if {[dict exists $facts $param]} {
        return [dict get $facts $param]
    }
    return [dict get [Schema $family] params $param absent]
}

# 1 if the FAMILY facts FA (a dict) imply the facts FB: every parameter of
# FA implying FB's, by its order.
proc hir::refinements::ImpliesFacts {family fa fb} {
    dict for {param spec} [dict get [Schema $family] params] {
        set va [FactIn $family $fa $param]
        set vb [FactIn $family $fb $param]
        if {$vb eq ""} {
            continue
        }
        if {$va eq "" || ![Stronger [dict get $spec order] $va $vb]} {
            return 0
        }
    }
    return 1
}

# The FAMILY facts true of the values of either fact set FA or FB (dicts): each
# parameter the weaker of the two -- an `exactly` parameter only when both
# state the same value -- canonical, {} when nothing holds of both. For a
# family over a type constructor, whose members need no parameter but the
# facts they state (hir::types::Refine).
proc hir::refinements::LubFacts {family fa fb} {
    set facts [dict create]
    dict for {param spec} [dict get [Schema $family] params] {
        set va [FactIn $family $fa $param]
        set vb [FactIn $family $fb $param]
        if {$va eq "" || $vb eq ""} {
            continue
        }
        if {[dict get $spec order] eq "exactly"} {
            if {$va eq $vb} {
                dict set facts $param $va
            }
        } elseif {[AtLeast $va $vb]} {
            if {$vb ne "inf"} { dict set facts $param $vb }
        } elseif {$va ne "inf"} {
            dict set facts $param $va
        }
    }
    return [CanonicalFacts $family $facts]
}

# The FAMILY facts of the values of both fact sets FA and FB (dicts): every
# fact of either, a parameter both state the stronger of the two; `none`
# when they contradict each other (two values of an `exactly` parameter: no
# value has both) or break a constraint.
proc hir::refinements::GlbFacts {family fa fb} {
    set facts [dict create]
    dict for {param spec} [dict get [Schema $family] params] {
        set va [FactIn $family $fa $param]
        set vb [FactIn $family $fb $param]
        if {$va eq "" || $va eq "inf"} {
            set v $vb
        } elseif {$vb eq "" || $vb eq "inf"} {
            set v $va
        } elseif {[dict get $spec order] eq "exactly"} {
            if {$va ne $vb} {
                return none
            }
            set v $va
        } elseif {[AtLeast $va $vb]} {
            set v $va
        } else {
            set v $vb
        }
        if {$v ne "" && $v ne "inf"} {
            dict set facts $param $v
        }
    }
    if {[ConstraintProblem $family $facts]} {
        return none
    }
    return [CanonicalFacts $family $facts]
}

# 1 if the FAMILY facts FACTS break one of its constraints.
proc hir::refinements::ConstraintProblem {family facts} {
    foreach constraint [dict get [Schema $family] constraints] {
        lassign $constraint relation a b
        if {[dict exists $facts $a] && [dict exists $facts $b]
                && $relation eq "atLeast" && [dict get $facts $a] < [dict get $facts $b]} {
            return 1
        }
    }
    return 0
}

# The parameter values FACTS (absent ones as the schema's `absent` value)
# made a canonical type of FAMILY (over BASE, for a family over a type
# constructor), absent values left out again; "" when the result breaks a
# constraint or states no required parameter (no fact holds: the caller's
# answer is the base).
proc hir::refinements::FromValues {family values {base ""}} {
    set facts [dict create]
    dict for {param value} $values {
        if {$value ne "inf" && $value ne ""} {
            dict set facts $param $value
        }
    }
    set fields [lmap {param value} $facts {list $param $value}]
    if {[Problems $family $fields] ne {}} {
        return ""
    }
    return [Canonical $family $facts $base]
}

# The most precise type describing values of the refined types A or B (of
# one family; over BASE, the join of their bases, for a family over a type
# constructor): each parameter the weaker of the two -- for an `exactly`
# parameter its one value when both agree, else no fact. "" when no fact
# holds for both.
proc hir::refinements::Lub {a b {base ""}} {
    set family [Family $a]
    set values [dict create]
    dict for {param spec} [dict get [Schema $family] params] {
        set va [fact $a $param]
        set vb [fact $b $param]
        if {[dict get $spec order] eq "exactly"} {
            # (Equal values are the join's; different ones state nothing.)
            if {$va eq $vb} {
                dict set values $param $va
            } else {
                dict set values $param ""
            }
        } elseif {[AtLeast $va $vb]} {
            dict set values $param $vb
        } else {
            dict set values $param $va
        }
    }
    return [FromValues $family $values $base]
}

# The type of values of both refined types A and B (of one family; over
# BASE, the meet of their bases, for a family over a type constructor):
# each parameter the stronger of the two; "" when none is representable --
# two different values of an `exactly` parameter describe no value.
proc hir::refinements::Glb {a b {base ""}} {
    set family [Family $a]
    set values [dict create]
    dict for {param spec} [dict get [Schema $family] params] {
        set va [fact $a $param]
        set vb [fact $b $param]
        if {[dict get $spec order] eq "exactly"} {
            if {$va ne "" && $vb ne "" && $va ne $vb} {
                return ""
            }
            if {$va eq ""} {
                dict set values $param $vb
            } else {
                dict set values $param $va
            }
        } elseif {[AtLeast $va $vb]} {
            dict set values $param $va
        } else {
            dict set values $param $vb
        }
    }
    return [FromValues $family $values $base]
}

# FACTS (a dict) as the fields of a source spelling.
proc hir::refinements::ShowFacts {facts} {
    return [join [lmap {param value} $facts {format {%s: %s} $param $value}] {, }]
}

# The source spelling of the refined TYPE: FAMILY{PARAM: VALUE, ...} in
# canonical order -- or, of a family over a type constructor, its base's
# spelling followed by the facts (List[int]{length: 4}; hir::types::show
# spells the base). It is a Tcl-list-safe text (balanced braces), as Fn{...}
# is, so HIR text writes it and hir::read parses it back (Parse,
# ParseApplied).
proc hir::refinements::Show {type} {
    if {[llength $type] == 4} {
        return "[hir::types::show [Base $type]]{[ShowFacts [Facts $type]]}"
    }
    return "[Family $type]{[ShowFacts [Facts $type]]}"
}

# The facts the fields text BODY (between the braces of Show's output, or
# any spelling with commas between its fields) states for FAMILY, as a
# canonical facts dict, or "" when BODY is none.
proc hir::refinements::ParseFacts {family body} {
    set fields {}
    foreach part [split $body ,] {
        set part [string trim $part]
        if {$part eq ""} {
            continue
        }
        if {![regexp {^([A-Za-z_][A-Za-z0-9_]*):\s*(-?[0-9]+)$} $part -> param value]} {
            return ""
        }
        lappend fields [list $param $value]
    }
    if {[Problems $family $fields] ne {}} {
        return ""
    }
    set facts [dict create]
    foreach field $fields {
        dict set facts [lindex $field 0] [lindex $field 1]
    }
    return [CanonicalFacts $family $facts]
}

# The refined type TEXT spells, for a family over a core type, or "" when
# TEXT is none.
proc hir::refinements::Parse {text} {
    if {![regexp {^([A-Za-z_][A-Za-z0-9_]*)\{(.*)\}$} $text -> family body] || ![isFamily $family]
            || [IsApplied $family]} {
        return ""
    }
    set facts [ParseFacts $family $body]
    if {$facts eq ""} {
        return ""
    }
    return [Canonical $family $facts]
}

# TEXT split as the spelling of a member of a family over a type
# constructor: {FAMILY BASE-TEXT FACTS} (FACTS canonical), the base's text
# for the caller to read (hir::read::ParseType), or "" when TEXT is none.
proc hir::refinements::ParseApplied {text} {
    variable families
    if {![regexp {^(.*)\{([^\{\}]*)\}$} $text -> baseText body]} {
        return ""
    }
    dict for {family schema} $families {
        if {![dict get $schema applied]} {
            continue
        }
        # The base: an application of the family's constructor
        # (List[int]), or its bare base kind (`list`, List[any]).
        if {[string match "$family\\\[*\\\]" $baseText] || $baseText eq [dict get $schema base]} {
            set facts [ParseFacts $family $body]
            if {$facts eq ""} {
                return ""
            }
            return [list $family $baseText $facts]
        }
    }
    return ""
}

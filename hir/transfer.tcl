# transfer.tcl -- the transfer schema of a sendable type, and the
# elaboration of std::transfer's operations (SENDABILITY-AND-VALUE-COPY-
# MILESTONE-1.md).
#
#   hir::transfer::Schema TYPE              the schema of closed, sendable
#                                           static TYPE: {nodes NODES fns
#                                           FNS text TEXT fingerprint FP}
#   hir::transfer::verifyDeclarations HIRVAR
#                                           the `sendable through` clauses'
#                                           functions, part of hir::check
#   hir::transfer::Elaborate HIRVAR         std::transfer::encode and decode
#                                           written out as the run-time
#                                           operations (after hir::check)
#
# A value crosses from one Botlish VM to another as owned bytes: the sender
# encodes it (std::transfer::encode), the receiver decodes it into its own
# heap (std::transfer::decode[T]). Both read the same description of the
# value's static type, its *schema*, which this file derives from the
# checked type alone: no run-time type information, no program-relative
# number (a struct's shape, an enum's number) and no name of this
# compilation's own making ever enters the bytes.
#
# A schema is a list of nodes, node 0 the root; a node refers to others by
# index, so a recursive type (a tree) is a finite schema. Each node is one
# of (the run-time forms core/transfer.tcl and native/src/runtime/
# transfer.rs read; native lowering resolves ids to its tables first):
#
#   unit | bool | char | float64 | raw32 | raw64 | str
#   int DOMAINS             an Int, DOMAINS the integer domains every value
#                           belongs to ({interval LO HI} | {exact VALUES}),
#                           checked by the receiver ({} for a plain int)
#   decimal FACTS           a DecimalRounded value of the facts FACTS (its
#                           binary64 is the value: kept bit for bit)
#   list E LENGTH           a List of node E's values, LENGTH its exact
#                           length when the type states one, else ""
#   set E | vector E | array E
#                           an ImmutableSet, MutableVector, MutableArray
#   struct ID SLOTS WIRE    a struct of declaration ID ("" for an anonymous
#                           one), SLOTS its field names in slot order, WIRE
#                           {FIELD SLOT NODE} per field in the order the
#                           bytes hold them: sorted by name
#   enum ID CASES           a case of enum ID, CASES its case names sorted:
#                           the bytes hold a case's index among them
#   bytes ID FIELD          an opaque struct of the standard library whose
#   mutbytes ID FIELD       one field FIELD holds (mutable) byte storage
#   through ID R K          an opaque struct its owner projects to node R's
#                           values with function value K of the call's
#                           function list and rebuilds with K + 1
#
# The schema's *text* names every node canonically -- declarations by
# identity, struct fields and enum cases sorted, nodes numbered in the
# order a walk in that order meets them, an owner's functions by their
# qualified names -- so two compilations of the same declarations, in any
# program, write the same text. What a receiver can check is left out of
# it and checked instead: an Int's integer domains and a List's stated
# length are refinements of an Int and a List, so bytes of `[1, 2]` (a List
# literal's length-refined type) decode as a List[int], and bytes of an
# Int as a std::byte::Byte when the Int is one. A DecimalRounded value's
# facts stay in it: its guarantee is no property a receiver can check. Its fingerprint (a 64-bit FNV-1a of the
# text) heads the bytes; a receiver whose own type's fingerprint differs
# refuses them (TransferTypeMismatch). The fingerprint is a check of intent,
# not of soundness: a decoder validates every value against the receiver's
# own schema, so even bytes that forged a fingerprint decode into a valid
# value of the receiver's type or not at all.

namespace eval hir::transfer {
    # The natives whose calls this file elaborates, and the run-time
    # operations they become.
    variable operations {std::transfer::encode transfer#encode std::transfer::decode transfer#decode}
    # The format version this compiler writes and reads (core/transfer.tcl).
    variable version 1
}

# The schema of the closed, sendable static TYPE (hir::types::SendClass
# total, hir::types::IsClosedType): {nodes NODES fns FNS text TEXT
# fingerprint FP}, FNS the qualified names of the owner functions the
# `through` nodes call, in index order.
proc hir::transfer::Schema {type} {
    set state [dict create nodes {} keys [dict create] fns {}]
    Node state $type
    set text [Text [dict get $state nodes] [dict get $state fns]]
    return [dict create nodes [dict get $state nodes] fns [dict get $state fns] \
        text $text fingerprint [Fingerprint $text]]
}

# The index of the node of TYPE in STATEVAR's schema, made first if new.
proc hir::transfer::Node {stateVar type} {
    upvar 1 $stateVar state
    if {[hir::cabi::IsFiniteFloating $type]} {
        set type [hir::cabi::Carrier $type]
    }
    if {[dict exists $state keys $type]} {
        return [dict get $state keys $type]
    }
    # The index first: a struct reached again through its own fields (a
    # tree's children) refers back to it.
    set index [llength [dict get $state nodes]]
    dict set state keys $type $index
    dict lappend state nodes {}
    set made [Make state $type]
    set nodes [dict get $state nodes]
    lset nodes $index $made
    dict set state nodes $nodes
    return $index
}

# The node of TYPE (Node's).
proc hir::transfer::Make {stateVar type} {
    upvar 1 $stateVar state
    if {$type eq "never"} {
        # (No value: List[never] is the empty List; its element node is
        # never read.)
        return unit
    }
    if {[hir::refinements::IsRefined $type]} {
        set family [hir::refinements::Family $type]
        if {[hir::refinements::IsApplied $family]} {
            set base [hir::refinements::Base $type]
            set length [hir::refinements::fact $type length]
            set node [Make state $base]
            if {[lindex $node 0] eq "list"} {
                lset node 2 $length
            }
            return $node
        }
        return [list decimal [hir::refinements::Facts $type]]
    }
    if {[hir::types::IsList $type]} {
        # (A positional shape is knowledge about one value, never the
        # type's identity: the element type is the List's.)
        return [list list [Node state [lindex $type 1]] ""]
    }
    if {[hir::types::IsSet $type]} {
        return [list set [Node state [lindex $type 1]]]
    }
    if {[hir::types::IsMutVec $type]} {
        return [list vector [Node state [lindex $type 1]]]
    }
    if {[hir::types::IsMutArray $type]} {
        return [list array [Node state [lindex $type 1]]]
    }
    if {[hir::types::IsStruct $type]} {
        return [StructNode state "" [lindex $type 1]]
    }
    if {[hir::types::IsNamedStruct $type]} {
        set id [lindex $type 1]
        if {[hir::structs::isOpaque $id] && [hir::structs::sendableOf $id] ne ""} {
            set clause [hir::structs::sendableOf $id]
            switch -- [dict get $clause form] {
                bytes - mutable_bytes {
                    return [list [expr {[dict get $clause form] eq "bytes" ? "bytes" : "mutbytes"}] \
                        $id [lindex [dict get $clause args] 0]]
                }
                through {
                    set k [llength [dict get $state fns]]
                    set owner [hir::structs::owner $id]
                    foreach f [dict get $clause args] {
                        if {$owner eq ""} {
                            dict lappend state fns $f
                        } else {
                            dict lappend state fns "${owner}::$f"
                        }
                    }
                    return [list through $id [Node state [hir::structs::AppliedRepresentation $type]] $k]
                }
            }
        }
        return [StructNode state $id [hir::structs::AppliedFieldTypes $type]]
    }
    if {[hir::types::IsEnum $type]} {
        set id [lindex $type 1]
        return [list enum $id [lsort [hir::enums::cases $id]]]
    }
    set normal [core::type::normalize $type]
    switch -- [core::type::base $normal] {
        unit { return unit }
        bool { return bool }
        UnicodeChar { return char }
        Float64 { return float64 }
        DecimalRounded { return [list decimal {}] }
        rawfloat32 { return raw32 }
        rawfloat64 { return raw64 }
        str { return str }
        int {
            set domains {}
            foreach name [core::type::evidenceClosure $normal] {
                set domain [dict get [core::type::metadata $name] integerDomain]
                if {$domain ne {} && $domain ni $domains} {
                    lappend domains $domain
                }
            }
            return [list int [lsort $domains]]
        }
    }
    error "hir::transfer: no schema for [hir::types::show $type] (not a sendable type)"
}

# The node of a struct of declaration ID ("" anonymous) with the fields
# FIELDS {NAME TYPE ...} in slot order: its fields' nodes made in sorted
# name order, the order the bytes hold them (so the numbering is the same
# whatever order a declaration writes its fields in).
proc hir::transfer::StructNode {stateVar id fields} {
    upvar 1 $stateVar state
    set slots [dict keys $fields]
    set wire {}
    foreach name [lsort $slots] {
        lappend wire [list $name [lsearch -exact $slots $name] [Node state [dict get $fields $name]]]
    }
    return [list struct $id $slots $wire]
}

# The canonical text of schema NODES with the owner functions FNS.
proc hir::transfer::Text {nodes fns} {
    variable version
    set lines [list "botlish-transfer $version"]
    set i 0
    foreach node $nodes {
        switch -- [lindex $node 0] {
            struct {
                lassign $node kind id slots wire
                set line "struct [Shown $id] {[join [lmap w $wire {lassign $w name slot n; string cat $name " " $n}] { }]}"
            }
            through {
                lassign $node kind id r k
                set line "through [Shown $id] $r [lindex $fns $k] [lindex $fns [expr {$k + 1}]]"
            }
            bytes - mutbytes {
                set line "[lindex $node 0] [lindex $node 1]"
            }
            int {
                # (An Int's integer domains are checked by the receiver,
                # never compared: a value of a domain is an Int.)
                set line int
            }
            list {
                # (Likewise a List's stated length.)
                set line "list [lindex $node 1]"
            }
            default {
                set line $node
            }
        }
        lappend lines "$i $line"
        incr i
    }
    return [join $lines \n]
}

proc hir::transfer::Shown {id} {
    if {$id eq ""} {
        return "{}"
    }
    return $id
}

# The 64-bit FNV-1a hash of TEXT's UTF-8 encoding, as 16 lowercase
# hexadecimal digits.
proc hir::transfer::Fingerprint {text} {
    set h 0xcbf29ce484222325
    binary scan [encoding convertto utf-8 $text] cu* bytes
    foreach b $bytes {
        set h [expr {(($h ^ $b) * 0x100000001b3) & 0xffffffffffffffff}]
    }
    return [format %016llx $h]
}

# The run-time form of SCHEMA (Schema's) a transfer call carries as its
# String constant: {VERSION FINGERPRINT NODES}.
proc hir::transfer::RuntimeText {schema} {
    variable version
    return [list $version [dict get $schema fingerprint] [dict get $schema nodes]]
}

# ---------------------------------------------------------------------------
# The owner functions of `sendable through(TO, FROM) as R`

# {BINDING BLOCK} of the top-level function NAME of the owner module of
# struct ID, or "" when the module declares none.
proc hir::transfer::OwnerFunction {hir id name} {
    set ns [hir::structs::owner $id]
    if {$ns eq ""} {
        set scope [dict get $hir top]
        set key $name
    } else {
        if {![dict exists $hir modules $ns]} {
            return ""
        }
        set scope [dict get $hir modules $ns]
        set key "${ns}::$name"
    }
    set b [dict getdef $hir scopes $scope names $key ""]
    if {$b eq ""} {
        return ""
    }
    set by [dict get $hir bindings $b declaredBy]
    if {$by eq "" || ![dict exists $hir exprs $by] || [dict get $hir exprs $by kind] ne "bind"} {
        return ""
    }
    set block [dict get $hir exprs $by value]
    if {[dict get $hir exprs $block kind] ne "block"} {
        return ""
    }
    return [list $b $block]
}

# Checks every `sendable through(TO, FROM) as R` clause of the program's
# structs: TO and FROM are top-level functions of the struct's own module,
# TO of exactly one parameter declared the struct's application to its own
# slots and the declared result R, FROM of one parameter declared R and the
# declared result the application; each total (no declared error), free of
# every context requirement and yield (the codec calls them in the middle
# of a walk, where nothing could handle, provide or suspend), and without
# flags. A clause that fails is SENDABLE-DECLARATION at the clause.
proc hir::transfer::verifyDeclarations {hirVar} {
    upvar 1 $hirVar hir
    if {[hir::mode $hir] ne "program" || [hir::traits::Planning] || [dict exists $hir traitSource]} {
        return
    }
    dict for {id entry} $::hir::structs::registry {
        set clause [hir::structs::sendableOf $id]
        if {$clause eq "" || [dict get $clause form] ne "through"} continue
        set ns [hir::structs::owner $id]
        if {$ns ne "" && ![dict exists $hir modules $ns]} continue
        set self [hir::structs::SelfType $id]
        set r [dict get $clause representation]
        set origin [hir::privacy::SpanOrigin $hir [dict getdef $clause span ""]]
        lassign [dict get $clause args] to from
        foreach role {to from} name [list $to $from] want [list [list $self $r] [list $r $self]] {
            set problem [FunctionProblem $hir $id $name {*}$want]
            if {$problem ne ""} {
                hir::DiagnoseAt hir SENDABLE-DECLARATION \
                    "the sendable clause of struct [hir::structs::display $id] names [expr {$role eq "to" ? "its projection" : "its rebuild"}] \"$name\", $problem" \
                    "" $origin
                break
            }
        }
    }
}

# Why function NAME of the owner module of struct ID is not a total,
# context-free function of the one parameter type PARAM and the result type
# RESULT ("" when it is).
proc hir::transfer::FunctionProblem {hir id name param result} {
    set found [OwnerFunction $hir $id $name]
    if {$found eq ""} {
        return "which is no top-level function of [hir::structs::ownerOf $id]"
    }
    lassign $found b block
    set node [dict get $hir exprs $block]
    set params [dict get $node params]
    set flags [dict getdef $node flags {}]
    set declared [dict getdef $node declaredParamTypes {}]
    if {[llength $params] - [llength $flags] != 1 || $flags ne {}} {
        return "which must take exactly one parameter (and no flag)"
    }
    set got [lindex $declared 0]
    if {$got eq "" || [hir::types::canonical $got] ne [hir::types::canonical $param]} {
        return "whose parameter must be declared [hir::types::show $param] (it is [if {$got eq ""} {string cat "undeclared"} else {hir::types::show $got}])"
    }
    set declaredResult [dict getdef $node declaredResult ""]
    if {$declaredResult eq "" || [hir::types::canonical $declaredResult] ne [hir::types::canonical $result]} {
        return "whose result must be declared [hir::types::show $result] (it is [if {$declaredResult eq ""} {string cat "undeclared"} else {hir::types::show $declaredResult}])"
    }
    if {[dict getdef $node declaredErrors {}] ne {}} {
        return "which declares errors: a transfer has no handler to give them to (the projection and the rebuild must be total)"
    }
    if {[hir::contexts::required $hir $block] ne {}} {
        return "which requires a context: a transfer runs it where no context is provided (it must be context-free)"
    }
    if {[dict exists $hir coroutines blocks $block]} {
        # (A yield-capable function: hir::coroutines::analyze's table.)
        return "which yields: a transfer runs it to completion in the middle of a walk"
    }
    return ""
}

# ---------------------------------------------------------------------------
# Elaboration

# Writes every call of std::transfer::encode and std::transfer::decode out
# as its run-time operation, after hir::check: transfer#encode(VALUE,
# SCHEMA, FNS) and transfer#decode(BYTES, SCHEMA, FNS), SCHEMA the String
# constant of the transferred type's schema (RuntimeText) and FNS the List
# of the owner functions its `through` nodes call. The call keeps its static
# type (Bytes for encode, the imprinted T for decode, whose imprint the
# run-time operation keeps). Every check ran on the call as written
# (hir::range::VerifySending held its type to Sendable and closed).
proc hir::transfer::Elaborate {hirVar} {
    upvar 1 $hirVar hir
    variable operations
    if {[hir::mode $hir] ne "program"} {
        return
    }
    set calls {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        set name [hir::decimal::CalledNative $hir $e]
        if {[dict exists $operations $name]} {
            lappend calls $e $name
        }
    }
    if {$calls eq {}} {
        return
    }
    set root [dict get $hir scopes [dict get $hir top] parent]
    foreach native {transfer#encode transfer#decode list} {
        hir::resolve::RootBinding hir $root $native
    }
    set parent ""
    foreach {e name} $calls {
        set node [dict get $hir exprs $e]
        set args [dict get $node args]
        if {$name eq "std::transfer::encode"} {
            set type [hir::typeOf $hir [lindex $args 0]]
        } else {
            set type [hir::typeOf $hir $e]
        }
        if {[lindex [hir::types::SendClass $type] 0] ne "total" || ![hir::types::IsClosedType $type]
                || [hir::types::IsTrait $type]} {
            # (Unreachable in an accepted program: VerifySending reported it,
            # and a view of Sendable is a witness type once the trait
            # monomorphization has cloned its function. A lenient build of a
            # rejected program runs nothing that reaches it.)
            continue
        }
        set schema [Schema $type]
        set refs {}
        foreach f [dict get $schema fns] {
            if {$parent eq ""} {
                lassign [hir::contexts::Walk $hir] owner parent rootOf callsOf blocks
            }
            lappend refs [FunctionRef hir $parent $e $f]
        }
        set fns [hir::mutvec::NewCall hir list $refs [list list any] $e]
        hir::mutvec::Retarget hir $e [dict get $operations $name]
        # (decode's run-time operation keeps the call's imprint: an analysis
        # that types the call again -- a semantic instance's, native
        # specialization -- reads its result type from it.)
        dict set hir exprs $e args [list [lindex $args 0] [hir::mutvec::NewConst hir [RuntimeText $schema] $e] $fns]
    }
}

# A reference, placed like expression AT, to the owner function QUALIFIED
# (an `ns::name` of Schema's FNS) as a value; every block enclosing AT
# (PARENT the parent map) reaches it as a module-static reference
# (hir::iteration::Rewrite's rule).
proc hir::transfer::FunctionRef {hirVar parent at qualified} {
    upvar 1 $hirVar hir
    set i [string last :: $qualified]
    if {$i < 0} {
        # (A function of the entry program: its top-level scope's.)
        set scope [dict get $hir top]
    } else {
        set scope [dict get $hir modules [string range $qualified 0 [expr {$i - 1}]]]
    }
    set b [dict get $hir scopes $scope names $qualified]
    set node [dict get $hir exprs $at]
    set r [hir::NewId hir expr]
    dict set hir exprs $r [dict create id $r kind ref origin [dict get $node origin] \
        scope [dict get $node scope] type [hir::types::intern hir [hir::affine::BindingType $hir $b]] \
        reachable [dict get $node reachable] name $qualified binding $b init yes]
    set x $at
    for {set i 0} {$i < 4096 && [dict exists $parent $x]} {incr i} {
        set x [lindex [dict get $parent $x] 0]
        if {$x eq ""} break
        if {[dict get $hir exprs $x kind] ne "block"} continue
        set staticRefs [dict get $hir exprs $x staticRefs]
        if {$b ni $staticRefs && [dict get $hir scopes [dict get $hir bindings $b scope] invocation]
                ne [dict get $hir scopes [dict get $hir exprs $x bodyScope] invocation]} {
            lappend staticRefs $b
            dict set hir exprs $x staticRefs $staticRefs
        }
    }
    return $r
}

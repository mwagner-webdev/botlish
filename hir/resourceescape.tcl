# resourceescape.tcl -- CONTEXT-RESOURCE-ESCAPE: a contextualized module
# that hands its raw foreign representation across its boundary
# (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md; the rule of
# ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md, section 11).
#
#   hir::resourceescape::findings HIR    warning records (hir/warnings.tcl's
#                                        CONTEXT-RESOURCE-ESCAPE pass)
#
# A module U is an *airlock* when the direct-module analysis proves it
# contextualized (hir/direct.tcl: U makes direct calls, and a context U
# declares mediates every one). Such a module already converts raw authority
# into a capability; what it should hand to the code above it is operations
# and values, not the raw foreign resources the operations use. The warning
# reports the contradiction -- U is an airlock, and code of another unit V
# can take its raw representation -- in three shapes, each a fact of the
# checked HIR:
#
#   R2  a crossing: V references a public member of U (calls a function,
#       takes it as a value, reads a binding), and an argument V passes, the
#       result V receives, or the member's value, holds a C address (Ptr,
#       FnPtr) V can read: the address itself, or inside a List, vector,
#       array, anonymous struct or struct whose representation V may read;
#   R3  the same with a native view or edit (NativeView, NativeEdit): read
#       authority over native memory, pointers included, needs none to use;
#   R4  V constructs, projects or destructures a struct of U whose
#       representation holds such raw representation.
#
# What stops the search -- the *opaque stopping rule* -- is representation V
# may not read: a struct declared opaque (or private) by a module other than
# V. A public opaque resource value is an intended abstraction (the census's
# Design A): it may hold pointers and cross freely; only a public operation
# that hands out the pointer or a view of it is reported. The *private
# stopping rule*: a private member of U is never a crossing, so a private
# helper may take and return pointers and views. It holds by construction:
# no other unit can reference a private member (PRIVATE-ACCESS: the loader
# rejects a written reference, method syntax never binds one,
# hir/privacy.tcl), and no value of a private struct can reach another
# module (PRIVATE-TYPE-ESCAPE) -- Sealed treats one as opaque all the same,
# so an analysis of a lenient HIR never reports a privacy violation a second
# time. And the *provenance rule*: an argument is reported only
# when V has no raw authority of its own (V is not direct and not itself an
# airlock): a pointer an ordinary module passes in can only have come from
# an airlock or C, while a direct module or another airlock may pass its own
# resource for U to use. A result is always U's.
#
# Never reported: calls inside U; members of a module that is not
# contextualized (an ordinary module mediates nothing; a designated direct
# module is a raw layer by declaration); values with no raw representation;
# trait operations (their types are the trait's contract, written by
# whoever declared it).
#
# One warning per exposing declaration of U -- the function or binding (R2,
# R3) or the struct (R4): where the fix is -- located there, with every
# consuming unit, its number of crossing sites (distinct source locations,
# so a function the trait plan clones counts once) and its first one, which
# is also a related location. Its text names the first raw value found
# (where, and its type).

namespace eval hir::resourceescape {}

# The first raw foreign representation TYPE exposes to code of unit FROM:
# {RAW TYPE PATH} -- RAW one of address, function-address, view, edit, TYPE
# the raw type, PATH the fields and elements leading to it ({} for TYPE
# itself) -- or "". SEEN guards recursive structs.
proc hir::resourceescape::Raw {hir type from {seen {}}} {
    if {$type in {cptr}} {
        return [list address $type {}]
    }
    if {[llength $type] < 2} {
        return ""
    }
    switch -- [lindex $type 0] {
        cptr   { return [list address $type {}] }
        cfnptr { return [list function-address $type {}] }
        nview  { return [list view $type {}] }
        nedit  { return [list edit $type {}] }
        srefined {
            return [Raw $hir [hir::refinements::Base $type] $from $seen]
        }
        list - immutableSet - mutarray - mutvec {
            set found [Raw $hir [lindex $type 1] $from $seen]
            if {$found eq "" && [lindex $type 0] eq "list"} {
                foreach t [lindex $type 2] {
                    set found [Raw $hir $t $from $seen]
                    if {$found ne ""} break
                }
            }
            return [Within $found element]
        }
        struct {
            foreach {name t} [lindex $type 1] {
                set found [Raw $hir $t $from $seen]
                if {$found ne ""} {
                    return [Within $found $name]
                }
            }
            return ""
        }
        nstruct {
            set id [lindex $type 1]
            if {$id in $seen || [Sealed $hir $id $from]} {
                return ""
            }
            lappend seen $id
            foreach name [hir::types::StructLayout $type] {
                set found [Raw $hir [hir::types::StructField $type $name] $from $seen]
                if {$found ne ""} {
                    return [Within $found $name]
                }
            }
            return ""
        }
        fn - coroutine {
            # A callable that hands out raw representation when V calls it.
            set found [Raw $hir [dict getdef [lindex $type 1] return any] $from $seen]
            return [Within $found result]
        }
        block {
            return [Within [Raw $hir [lindex $type 3] $from $seen] result]
        }
    }
    return ""
}

# FOUND (Raw's) one step deeper, through STEP (a field name, `element`,
# `result`).
proc hir::resourceescape::Within {found step} {
    if {$found eq ""} {
        return ""
    }
    lassign $found raw type path
    return [list $raw $type [linsert $path 0 $step]]
}

# 1 if code of unit FROM may not read the representation of struct ID: it is
# opaque or private, and FROM is not the module that declares it.
proc hir::resourceescape::Sealed {hir id from} {
    if {![hir::structs::declared $id] && [hir::layouts::OfStructId $id] eq ""} {
        return 1
    }
    set owner [hir::structs::owner $id]
    if {$owner eq $from} {
        return 0
    }
    if {[hir::structs::declared $id] && [hir::structs::isOpaque $id]} {
        return 1
    }
    lassign [hir::privacy::Member $id] ns name
    return [expr {[hir::privacy::Entry [hir::privacy::Decls $hir] $ns types $name] ne ""}]
}

# "a raw C pointer" and the like, for RAW (Raw's first element).
proc hir::resourceescape::RawPhrase {raw} {
    return [dict get {address "a raw C pointer" function-address "a raw C function pointer"
        view "a native view" edit "a native edit"} $raw]
}

# The rule RAW is reported under: R2 for a C address, R3 for a view or edit.
proc hir::resourceescape::Rule {raw} {
    return [expr {$raw in {view edit} ? "R3" : "R2"}]
}

# "(parameter `renderer`, std::ffi::c::Ptr[...])", "(its result, at
# .handles: NativeView[...])": where FOUND sits in the position POSITION.
proc hir::resourceescape::Where {position found} {
    lassign $found raw type path
    set text $position
    if {$path ne {}} {
        append text ", at " [join [lmap step $path {
            if {$step in {element result}} {string cat \[ $step \]} else {string cat . $step}
        }] ""]
    }
    return "($text: [hir::types::presented $type])"
}

proc hir::resourceescape::findings {hir} {
    if {![dict exists $hir direct units] || ![dict exists $hir moduleDecls]} {
        return {}
    }
    set units [dict get $hir direct units]
    set airlocks [dict create]
    dict for {ns unit} $units {
        if {[dict get $unit status] eq "contextualized"} {
            set contexts {}
            foreach edge [dict get $unit edges] {
                set c [dict get $edge discharged]
                if {$c ne "" && $c ni $contexts} {
                    lappend contexts $c
                }
            }
            dict set airlocks $ns [lsort $contexts]
        }
    }
    if {[dict size $airlocks] == 0} {
        return {}
    }
    set sections [dict create]
    set airlockScopes [dict create]
    dict for {ns scope} [dict getdef $hir modules {}] {
        dict set sections $scope $ns
        if {[dict exists $airlocks $ns]} {
            dict set airlockScopes $scope $ns
        }
    }
    set decls [hir::privacy::Decls $hir]
    set memo [dict create]
    # The calls by callee expression.
    set calls [dict create]
    dict for {c node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "call"} {
            dict set calls [dict get $node callee] $c
        }
    }
    # DECLARATION -> {name NAME unit U origin ORIGIN rules {..} raw TEXT
    # consumers {V {sites {LOCATION ...} first ORIGIN how {...}} ...}}
    set found [dict create]
    dict for {e node} [dict get $hir exprs] {
        set kind [dict get $node kind]
        if {$kind ni {ref struct project}} continue
        set origin [dict get $node origin]
        if {[lindex $origin 0] ne "file"} continue
        set v [hir::direct::UnitOfScope $hir [dict get $node scope] memo $sections]
        if {$kind eq "ref"} {
            set b [dict get $node binding]
            if {$b eq "" || ![dict exists $hir bindings $b]} continue
            set u [dict getdef $airlockScopes [dict get $hir bindings $b scope] ""]
            if {$u eq "" || ![dict exists $airlocks $u] || $u eq $v} continue
            if {[dict exists $hir bindings $b extern]} continue
            # (B is a public member: the private stopping rule, header.)
            set source [hir::semantic::SourceName $hir $b]
            set raw ""
            set how ""
            if {[dict exists $calls $e]} {
                set c [dict get $calls $e]
                if {[dict exists $hir exprs $c traitCall]} continue
                set raw [Raw $hir [hir::typeOf $hir $c] $v]
                if {$raw ne ""} {
                    set where [Where "its result" $raw]
                    set how receives
                }
                if {![RawAuthority $units $v]} {
                    set names [ParamNames $hir $b]
                    set i 0
                    foreach a [dict get $hir exprs $c args] {
                        set r [Raw $hir [hir::typeOf $hir $a] $v]
                        if {$r ne ""} {
                            if {$raw eq ""} {
                                set raw $r
                                set where [Where "parameter `[lindex $names $i]`" $r]
                            }
                            set how [expr {$how eq "" ? "passes" : "both"}]
                            break
                        }
                        incr i
                    }
                }
            } else {
                set raw [Raw $hir [hir::typeOf $hir $e] $v]
                if {$raw ne ""} {
                    set where [Where "its value" $raw]
                    set how value
                }
            }
            if {$raw eq ""} continue
            set key binding:$b
            if {![dict exists $found $key]} {
                dict set found $key [dict create name $source unit $u kind function \
                    origin [dict get $hir bindings $b origin] rules {} raw [RawPhrase [lindex $raw 0]] \
                    where $where consumers [dict create]]
            }
            dict set found $key rules [lsort -unique [concat [dict get $found $key rules] [Rule [lindex $raw 0]]]]
            Note found $key $v $hir $origin $how
            continue
        }
        # R4: a struct of U built or taken apart in V.
        if {$kind eq "struct"} {
            set type [hir::typeOf $hir $e]
            set how constructs
            set site $origin
        } else {
            set type [hir::typeOf $hir [dict get $node receiver]]
            set how projects
            set site $origin
            set synthesized [hir::structs::SynthesizedReceiver $hir $node]
            if {$synthesized ne ""} {
                # A destructuring is one site: its statement's.
                set how destructures
                set by [dict get $hir bindings $synthesized declaredBy]
                if {$by ne "" && [dict exists $hir exprs $by]} {
                    set site [dict get $hir exprs $by origin]
                }
            }
        }
        if {![hir::types::IsNamedStruct $type]} continue
        set id [lindex $type 1]
        if {![hir::structs::declared $id] && [hir::layouts::OfStructId $id] eq ""} continue
        set u [hir::structs::owner $id]
        if {![dict exists $airlocks $u] || $u eq $v || [Sealed $hir $id $v]} continue
        set raw [Raw $hir $type $v]
        if {$raw eq ""} continue
        set key struct:$id
        if {![dict exists $found $key]} {
            lassign [hir::privacy::Member $id] ns name
            dict set found $key [dict create name $id unit $u kind struct \
                origin [dict getdef $decls $u declarations types $name ""] rules R4 \
                raw [RawPhrase [lindex $raw 0]] where [Where "in its representation" $raw] \
                consumers [dict create]]
        }
        Note found $key $v $hir $site $how
    }
    set warnings {}
    dict for {key entry} $found {
        lappend warnings [Warning $hir $entry [dict get $airlocks [dict get $entry unit]]]
    }
    return $warnings
}

# Records, in FOUND's entry KEY, a crossing of consuming unit V at ORIGIN, of
# the manner HOW (passes, receives, both, value, constructs, projects,
# destructures).
proc hir::resourceescape::Note {foundVar key v hir origin how} {
    upvar 1 $foundVar found
    set location [hir::originLocation $hir $origin]
    set consumer [dict getdef $found $key consumers $v [dict create sites {} first "" how {}]]
    if {$location ni [dict get $consumer sites]} {
        dict lappend consumer sites $location
        if {[dict get $consumer first] eq ""
                || [Before [dict get $origin start] [lindex $origin 1] [dict get $consumer first]]} {
            dict set consumer first $origin
        }
    }
    if {$how eq "both"} {
        set how [list passes receives]
    }
    dict set consumer how [lsort -unique [concat [dict get $consumer how] $how]]
    dict set found $key consumers $v $consumer
}

# 1 if offset START of file FILE is before ORIGIN.
proc hir::resourceescape::Before {start file origin} {
    set other [lindex $origin 1]
    if {$file ne $other} {
        return [expr {[string range $file 1 end] < [string range $other 1 end]}]
    }
    return [expr {$start < [dict get $origin start]}]
}

# 1 if unit V has raw authority of its own (the provenance rule, header): it
# is designated direct, or an airlock itself.
proc hir::resourceescape::RawAuthority {units v} {
    set status [dict getdef $units $v status ordinary]
    return [expr {$status in {direct provided contextualized}}]
}

# The source names of the parameters of the function binding B denotes, or
# argument positions for one whose block is not known.
proc hir::resourceescape::ParamNames {hir b} {
    set block [hir::contexts::Denotes $hir $b]
    if {$block eq ""} {
        return {}
    }
    return [lmap p [dict get $hir exprs $block params] {hir::semantic::SourceName $hir $p}]
}

# The warning record of one exposing declaration ENTRY (findings') of the
# airlock whose mediating contexts are CONTEXTS.
proc hir::resourceescape::Warning {hir entry contexts} {
    set u [dict get $entry unit]
    set consumers {}
    set secondary {}
    set order [lsort -command [list hir::resourceescape::ConsumerOrder [dict get $entry consumers]] \
        [dict keys [dict get $entry consumers]]]
    foreach v $order {
        set consumer [dict get $entry consumers $v]
        set n [llength [dict get $consumer sites]]
        set what [expr {[dict get $entry kind] eq "struct" ? "site" : "call"}]
        set first [dict get $consumer first]
        lappend secondary $first
        lappend consumers [format {%s %s (%d %s%s; first at %s)} \
            [hir::privacy::UnitPhrase $v] [HowPhrase [dict get $consumer how]] \
            $n $what [expr {$n == 1 ? "" : "s"}] [hir::originLocation $hir $first]]
    }
    set through [expr {[llength $contexts] == 1 ? "its context [lindex $contexts 0]"
        : "its contexts [join $contexts {, }]"}]
    if {[dict get $entry kind] eq "struct"} {
        set message [format {%s holds %s %s and its representation is open across the boundary of module "%s", which mediates its raw authority through %s: %s. Keep the resource behind the context, or declare %s opaque so that only module "%s" can build and take it apart} \
            [dict get $entry name] [dict get $entry raw] [dict get $entry where] $u $through \
            [join $consumers {; }] [dict get $entry name] $u]
    } else {
        set message [format {%s exposes %s %s across the boundary of module "%s", which mediates its raw authority through %s: %s. Keep the resource behind the context and give module "%s" an operation that takes and returns values, or seal the resource in an opaque struct} \
            [dict get $entry name] [dict get $entry raw] [dict get $entry where] $u $through \
            [join $consumers {; }] $u]
    }
    return [hir::warnings::New CONTEXT-RESOURCE-ESCAPE $message [dict get $entry origin] $secondary \
        [dict create note "a crossing of this resource" declaration [dict get $entry name] \
            module $u rules [dict get $entry rules] \
            consumers [lmap v $order {list $v [llength [dict get $entry consumers $v sites]]}]]]
}

# Consuming units in the order of their first crossing.
proc hir::resourceescape::ConsumerOrder {consumers a b} {
    set x [dict get $consumers $a first]
    set y [dict get $consumers $b first]
    if {[Before [dict get $x start] [lindex $x 1] $y]} {
        return -1
    }
    if {[Before [dict get $y start] [lindex $y 1] $x]} {
        return 1
    }
    return [string compare $a $b]
}

# What the consumer does, in prose: HOW is a sorted list of manners.
proc hir::resourceescape::HowPhrase {how} {
    set words [lmap h $how {
        dict get {passes "passes one in" receives "receives one" value "takes it as a value"
            constructs "constructs it" projects "reads its fields" destructures "destructures it"} $h
    }]
    return [join $words " and "]
}

# report.tcl -- the coverage report and the manifest of a generation
# (C-BINDGEN.md, "Report", "Manifest").
#
#   report.tsv    one row per public name: KIND NAME STATUS MODULE REASON
#                 DETAIL (tab-separated, translation-unit order) -- what
#                 `c-bindgen report PROFILE -why NAME` answers from
#   report.txt    the counts: inventory, what was bound and how, every
#                 blocker by reason, pointer contracts and their evidence,
#                 the capability pressure (which missing FFI capability
#                 blocks or limits how many APIs), macros and stub-table
#                 redirections, generated source size
#   manifest.txt  what the generation read and wrote: profile, target,
#                 source pin, headers and their CRCs, defines, toolchain,
#                 libraries, files, the shim, counts and every favorable
#                 contract fact with its source
#
# All three are deterministic: no time, no temporary path, no host name.

namespace eval ::cbind::report {}

proc ::cbind::report::Clean {s} {
    return [string map [list \t " " \n " "] $s]
}

# The rows of MODEL: {KIND NAME STATUS MODULE REASON DETAIL}.
proc ::cbind::report::rows {model} {
    set ns [dict get $model profile name]
    set rows {}
    foreach e [dict get $model apis] {
        set k [dict get $e kind]
        set module [expr {$k in {direct alias} ? "${ns}::[dict get $e module]" : ($k eq "thunk" ? "${ns}::thunks::[dict get $e module]" : "")}]
        set ids [dict get $model identities]
        set sig ""
        if {$k in {direct alias thunk}} {
            set types [lmap q [dict get $e params] {ReportType $ids [dict get $q type]}]
            if {[dict getdef $e variadic 0]} {
                lappend types variadic
            }
            set sig "; ([join $types {, }]) -> [ReportType $ids [dict get $e result type]]"
        }
        set lib [expr {[dict exists $e library] ? "; library [dict get $e library]" : ""}]
        switch -- $k {
            direct {
                set reason direct
                set detail "symbol [dict get $e symbol]$lib$sig"
            }
            alias {
                set reason "alias of [dict get $e targetName]"
                set detail "symbol [dict get $e symbol]$lib$sig"
            }
            thunk {
                set reason "thunk ([dict get $e via][expr {[dict exists $e shadowedBy] ? ": [dict get $e shadowedBy]" : ""}])"
                set detail "symbol [dict get $e symbol]$sig"
            }
            excluded {
                set reason excluded
                set detail "the profile's exclude policy"
            }
            unsupported {
                set reasons [lsort -unique [lmap b [dict get $e blockers] {lindex $b 0}]]
                set reason [join $reasons ,]
                set detail [join [lmap b [dict get $e blockers] {lindex $b 1}] "; "]
            }
        }
        lappend rows [list [expr {[dict exists $e macro] ? "macro" : "function"}] [dict get $e name] $k $module $reason $detail]
    }
    foreach c [dict get $model constants] {
        set module [expr {[dict get $c status] eq "constant" ? "${ns}::[dict get $c module]" : ""}]
        if {[dict get $c status] eq "constant"} {
            set reason [dict get $c type]
            set detail "[dict get $c ctype] [dict get $c value]"
        } else {
            set reason [dict get $c reason]
            set detail [dict get $c detail]
        }
        lappend rows [list [dict get $c kind] [dict get $c name] [dict get $c status] $module $reason $detail]
    }
    # Types: public typedefs and tags.
    set ids [dict get $model identities]
    set ix [::cir::index [dict get $model records]]
    foreach r [dict get $model records] {
        lassign $r kind name body
        if {[dict get $body origin] ne "public"} continue
        if {$kind eq "typedef"} {
            lappend rows [TypedefRow $model $ix $ids $name $body]
        }
    }
    foreach key [PublicTags $model $ix] {
        set complete [expr {[dict exists $ix tag $key] && [dict get $ix tag $key complete]}]
        if {[dict exists $ids $key]} {
            lappend rows [list tag $key opaque "${ns}::ctypes" [expr {$complete ? "complete, behind pointers" : "incomplete"}] "identity [dict get $ids $key name]"]
        } else {
            lappend rows [list tag $key unused "" [expr {$complete ? "complete" : "incomplete"}] "no bound signature points to it"]
        }
    }
    # Records: one row each, what its layout became (records.tcl).
    if {[dict exists $model layouts]} {
        dict for {key rec} [dict get $model layouts] {
            if {[dict get $rec status] eq "promoted"} continue
            lappend rows [RecordRow $ns $rec]
        }
    }
    return $rows
}

# The report row of record REC: {record KEY STATUS MODULE REASON DETAIL},
# REASON the layout's name or the blockers' reasons, DETAIL the sizes or
# every blocker, located.
proc ::cbind::report::RecordRow {ns rec} {
    set key [dict get $rec key]
    if {[dict get $rec status] eq "layout-direct" && [dict get $rec unheld]} {
        return [list record $key layout-unheld "" [dict get $rec layoutName] \
            "an anonymous member of [dict get $rec owner], whose layout is blocked: representable, not emitted"]
    }
    switch -- [dict get $rec status] {
        layout-direct {
            return [list record $key layout-direct "${ns}::layouts" [dict get $rec layoutName] \
                "sizeof [dict get $rec size], _Alignof [dict get $rec align], [llength [dict get $rec fields]] fields"]
        }
        opaque-only {
            return [list record $key opaque-only "" incomplete "no definition: a pointee identity only"]
        }
        default {
            set reasons [lsort -unique [concat [lmap b [dict get $rec direct] {lindex $b 0}] \
                [lmap b [dict get $rec transitive] {lindex $b 0}]]]
            set details [concat [lmap b [dict get $rec direct] {lindex $b 1}] [lmap b [dict get $rec transitive] {lindex $b 1}]]
            return [list record $key layout-blocked "" [join $reasons ,] [join $details "; "]]
        }
    }
}

# The layout manifest (layouts.tsv) of MODEL: every record the generation
# considered, one `record` row each and one `field` row per member, so that
# what a feature would unlock can be computed without the headers. Columns:
#
#   record   KEY - LAYOUT STATUS - SIZE ALIGN CNAME - DETAIL
#   field    KEY INDEX NAME CATEGORY OFFSET SIZE - CDECL TYPE DETAIL
#   promoted KEY - PATH - OFFSET SIZE - CMEMBER TYPE DETAIL
#
# KEY the C tag ("struct T"; an anonymous record's anon@FILE:LINE), LAYOUT
# the emitted layout's name ("-" when none), STATUS layout-direct,
# layout-blocked, opaque-only, layout-unheld (a synthetic record that is
# representable but held by a blocked record: not emitted); CNAME the C type the probes named it by;
# DETAIL key=value items: typedefs, identity, header, blockers (direct),
# nested (transitive: the chain to the first direct blocker), roots (every
# direct reason it waits for), deps, pointed-by (bound APIs pointing to
# it); a synthetic record's (an anonymous member's, records.tcl) owner,
# place (the generated field holding it, from its owner's layout) and at
# (where clang locates it: FILE:LINE:COL), its CNAME "-". A field's NAME is its Botlish name (an unnamed member's its
# place, member3), CATEGORY scalar, pointer, function-pointer, nested,
# array, or its first blocker's reason; TYPE its Botlish type when
# representable; DETAIL its C name, its array element and extent, its
# bitfield width, its blockers. A `promoted` row maps a C member name an
# anonymous member promotes into record KEY (C11: Offset of OVERLAPPED) to
# the generated path that reaches it from KEY's layout (PATH,
# member3.member1.Offset), with its offset in KEY (OFFSET) and the
# anonymous members it goes through (DETAIL via=).
proc ::cbind::report::layoutsTsv {model} {
    set p [dict get $model profile]
    set ns [dict get $p name]
    set tc [dict get $model toolchain]
    set recs [dict get $model layouts]
    set ids [dict get $model identities]
    set users [dict get [::cbind::pressure::api $model] users]
    set out "# c-bindgen layout manifest: profile [dict get $p name], target [dict get $model target], toolchain [dict get $tc family] [dict get $tc target] ([dict get $tc version]) (C-BINDGEN-LAYOUTS.md)\n"
    append out "kind\trecord\tindex\tname\tstatus\toffset\tsize\talign\tc\ttype\tdetail\n"
    dict for {key rec} $recs {
        if {[dict get $rec status] eq "promoted"} continue
        set detail {}
        if {[llength [dict get $rec typedefs]]} { lappend detail "typedefs=[join [dict get $rec typedefs] ,]" }
        lappend detail "identity=[expr {[dict exists $ids $key] ? "${ns}::ctypes::[dict get $ids $key name]" : "-"}]"
        lappend detail "header=[expr {[dict get $rec origin] in {public bundled internal} ? "[dict get $rec header]:[dict get $rec line]" : "(a system header)"}]"
        if {[dict get $rec status] eq "layout-blocked"} {
            set direct [lmap b [dict get $rec direct] {string cat [lindex $b 0] ": " [lindex $b 1]}]
            if {[llength $direct]} { lappend detail "blockers=[join $direct { | }]" }
            set trans [lmap b [dict get $rec transitive] {lindex $b 1}]
            if {[llength $trans]} { lappend detail "nested=[join $trans { | }]" }
            lappend detail "roots=[join [::cbind::records::RootReasons $recs $key] ,]"
        }
        if {[llength [dict get $rec deps]]} {
            lappend detail "deps=[join [lsort -unique [lmap d [dict get $rec deps] {lindex $d 0}]] ,]"
        }
        if {[dict exists $users $key]} { lappend detail "pointed-by=[llength [dict get $users $key]]" }
        if {[dict get $rec synthetic]} {
            lappend detail "owner=[dict get $rec owner]" "place=[::cbind::records::Path $recs $key]"
            if {[dict exists $rec at]} { lappend detail "at=[dict get $rec at]" }
        }
        set status [dict get $rec status]
        if {$status eq "layout-direct" && [dict get $rec unheld]} { set status layout-unheld }
        set name [expr {$status eq "layout-direct" ? [dict get $rec layoutName] : "-"}]
        append out [join [lmap c [list record $key - $name $status - \
            [Dash [dict get $rec size]] [Dash [dict get $rec align]] [Dash [dict get $rec cname]] - [join $detail {; }]] {Clean $c}] \t]\n
        foreach f [dict get $rec fields] {
            set cat [dict get $f kind]
            if {$cat eq "pointer" && [string match std::ffi::c::FnPtr* [dict get $f type]]} { set cat function-pointer }
            if {$cat eq "blocked"} { set cat [lindex [dict get $f blockers] 0 0] }
            set type [expr {$cat in {scalar pointer function-pointer nested array} ? [::cbind::records::FieldText $recs $f] : [dict get $f type]}]
            set fd [list "c=[Dash [dict get $f cname]]"]
            if {[llength [dict get $f via]]} { lappend fd "promoted-from=[join [dict get $f via] ,]" }
            if {[dict exists $f array]} {
                set a [dict get $f array]
                lappend fd "element=[dict get $a category] [dict get $a element]" "bounds=[join [dict get $a bounds] ,]"
                if {[dict exists $f extent]} { lappend fd "extent=[dict get $f extent]" }
            }
            if {[dict get $f bits] ne ""} { lappend fd "bits=[::cir::BoundText [dict get $f bits]]" }
            if {[llength [dict get $f blockers]]} {
                lappend fd "blockers=[join [lmap b [dict get $f blockers] {string cat [lindex $b 0] ": " [lindex $b 1]}] { | }]"
            }
            set cdecl [regsub -all {\s+} [::cir::render [dict get $f ctype] [dict get $f cname]] " "]
            append out [join [lmap c [list field $key [dict get $f index] [Dash [dict get $f name]] $cat \
                [Dash [dict get $f offset]] [Dash [dict get $f size]] - $cdecl [Dash [::cbind::report::ReportType $ids $type]] [join $fd {; }]] {Clean $c}] \t]\n
        }
        if {![dict get $rec synthetic]} {
            foreach p [Promoted $recs $rec "" 0 {}] {
                lassign $p path offset f via
                set cat [dict get $f kind]
                set type [expr {$cat in {scalar pointer nested array} ? [::cbind::records::FieldText $recs $f] : [dict get $f type]}]
                append out [join [lmap c [list promoted $key - $path - [Dash $offset] [Dash [dict get $f size]] - \
                    [dict get $f cname] [Dash [::cbind::report::ReportType $ids $type]] "via=[join $via ,]"] {Clean $c}] \t]\n
            }
        }
    }
    return $out
}

# The C member names the synthetic records held by REC's fields promote
# into it, through any number of them: {PATH OFFSET FIELD VIA} each, PATH
# the generated path (PREFIX's), OFFSET its offset in the owner (BASE plus
# the fields' offsets; "" when one is unknown), FIELD the synthetic record's
# field, VIA the anonymous records it goes through.
proc ::cbind::report::Promoted {recs rec prefix base via} {
    set out {}
    foreach f [dict get $rec fields] {
        set t [dict get $f type]
        if {[dict get $f cname] ne "" || [dict get $f bits] ne "" || ![dict exists $recs $t] || ![dict get $recs $t synthetic]} continue
        set at [expr {$base eq "" || [dict get $f offset] eq "" ? "" : $base + [dict get $f offset]}]
        set inner [dict get $recs $t]
        foreach g [dict get $inner fields] {
            set path "$prefix[dict get $f name].[dict get $g name]"
            if {[dict get $g cname] ne ""} {
                lappend out [list $path [expr {$at eq "" || [dict get $g offset] eq "" ? "" : $at + [dict get $g offset]}] $g [concat $via [list $t]]]
            }
        }
        lappend out {*}[Promoted $recs $inner "$prefix[dict get $f name]." $at [concat $via [list $t]]]
    }
    return $out
}

proc ::cbind::report::Dash {v} {
    return [expr {$v eq "" ? "-" : $v}]
}

# The layout counts of MODEL (report.txt's and the manifest's).
proc ::cbind::report::layoutCounts {model} {
    set c [dict create structs 0 unions 0 incomplete 0 emitted 0 blocked 0 blockedStructs 0 \
        blockedUnions 0 blockedDirect 0 blockedTransitive 0 public 0 system 0 anonymous 0 promoted 0 \
        emittedUnions 0 synthetic 0 emittedSynthetic 0 unheld 0]
    set reasons [dict create]
    set transitiveRoots [dict create]
    if {![dict exists $model layouts]} { dict set c reasons {}; dict set c roots {}; return $c }
    set recs [dict get $model layouts]
    dict for {key rec} $recs {
        set st [dict get $rec status]
        if {$st eq "promoted"} { dict incr c promoted; continue }
        if {$st eq "opaque-only"} { dict incr c incomplete; continue }
        dict incr c [expr {[dict get $rec kind] eq "union" ? "unions" : "structs"}]
        dict incr c [expr {[dict get $rec origin] eq "public" ? "public" : "system"}]
        if {[dict get $rec anonymous]} { dict incr c anonymous }
        if {[dict get $rec synthetic]} { dict incr c synthetic }
        if {$st eq "layout-direct" && [dict get $rec unheld]} {
            dict incr c unheld
            continue
        }
        if {$st eq "layout-direct"} {
            dict incr c emitted
            if {[dict get $rec kind] eq "union"} { dict incr c emittedUnions }
            if {[dict get $rec synthetic]} { dict incr c emittedSynthetic }
            continue
        }
        dict incr c blocked
        dict incr c [expr {[dict get $rec kind] eq "union" ? "blockedUnions" : "blockedStructs"}]
        dict incr c [expr {[llength [dict get $rec direct]] ? "blockedDirect" : "blockedTransitive"}]
        foreach r [lsort -unique [lmap b [dict get $rec direct] {lindex $b 0}]] { dict incr reasons $r }
        if {[llength [dict get $rec transitive]]} { dict incr reasons nested-layout-blocked }
        if {![llength [dict get $rec direct]]} {
            foreach r [::cbind::records::RootReasons $recs $key] { dict incr transitiveRoots $r }
        }
    }
    dict set c reasons $reasons
    dict set c roots $transitiveRoots
    return $c
}

proc ::cbind::report::TypedefRow {model ix ids name body} {
    set ns [dict get $model profile name]
    lassign [::cir::resolve $ix [dict get $body type]] chain final
    set final [::cir::unq $final]
    switch -- [lindex $final 0] {
        int {
            set s [::cbind::model::ScalarOf [lindex $final 1]]
            set problem [::cbind::model::TypedefAbiProblem $name [lindex $final 1]]
            if {$problem ne ""} { return [list typedef $name unsupported "" typedef-abi-mismatch $problem] }
            return [list typedef $name scalar "" $s "an ABI alias of C [lindex $final 1]"]
        }
        bool { return [list typedef $name scalar "" std::ffi::c::Bool "C _Bool"] }
        enum {
            set e [::cbind::model::EnumScalar [lindex $final 1] $name]
            if {$e eq ""} { return [list typedef $name unsupported "" enum-unknown-abi "enum [lindex $final 1]"] }
            return [list typedef $name scalar "" [lindex $e 0] "enum [lindex $final 1], C [lindex $e 1] on this target"]
        }
        struct - union {
            set key "[lindex $final 0] [lindex $final 1]"
            if {[dict exists $ids $key]} {
                return [list typedef $name opaque "${ns}::ctypes" "identity [dict get $ids $key name]" $key]
            }
            return [list typedef $name unused "" $key "no bound signature points to it"]
        }
        ptr - fn {
            set m [::cbind::model::Value $final param]
            set callback [expr {[lindex $final 0] eq "fn" || [lindex [::cir::unq [lindex $final 1]] 0] eq "fn"}]
            if {[lindex $m 0] eq "ok"} {
                set what [expr {$callback ? "callback" : "pointer"}]
                return [list typedef $name $what "" [ReportType $ids [lindex $m 1]] [::cbind::model::Spell $final]]
            }
            set reasons [lsort -unique [lmap b [lindex $m 1] {lindex $b 0}]]
            return [list typedef $name unsupported "" [join $reasons ,] [join [lmap b [lindex $m 1] {lindex $b 1}] "; "]]
        }
        default {
            set m [::cbind::model::Value $final param]
            if {[lindex $m 0] eq "ok"} {
                return [list typedef $name other "" [ReportType $ids [lindex $m 1]] [::cbind::model::Spell $final]]
            }
            set reasons [lsort -unique [lmap b [lindex $m 1] {lindex $b 0}]]
            return [list typedef $name unsupported "" [join $reasons ,] [join [lmap b [lindex $m 1] {lindex $b 1}] "; "]]
        }
    }
}

# TEXT with its pointee identities spelled for the report: a generated
# identity by its Botlish name, a tag no bound signature uses by its C tag.
proc ::cbind::report::ReportType {ids text} {
    while {[regexp {\x01([^\x02]+)\x02} $text -> key]} {
        set spelled [expr {[dict exists $ids $key] ? "[dict get $ids $key name]" : "<$key>"}]
        set text [string map [list \x01$key\x02 $spelled] $text]
    }
    return $text
}

# The struct and union tags of the public API: declared in a public header
# or named by a public typedef (through pointers), anonymous ones left out.
proc ::cbind::report::PublicTags {model ix} {
    set tags {}
    dict for {key tag} [dict get $ix tag] {
        if {[dict get $tag origin] eq "public" && [lindex $key 0] ne "enum" && ![string match anon@* [lindex $key 1]]} {
            lappend tags $key
        }
    }
    foreach r [dict get $model records] {
        lassign $r kind name body
        if {$kind ne "typedef" || [dict get $body origin] ne "public"} continue
        set t [::cir::unq [dict get $body type]]
        while {[lindex $t 0] eq "ptr"} { set t [::cir::unq [lindex $t 1]] }
        if {[lindex $t 0] in {struct union} && ![string match anon@* [lindex $t 1]]} {
            lappend tags "[lindex $t 0] [lindex $t 1]"
        }
    }
    return [lsort -unique $tags]
}

proc ::cbind::report::tsv {model} {
    set text "kind\tname\tstatus\tmodule\treason\tdetail\n"
    foreach row [rows $model] {
        append text [join [lmap c $row {Clean $c}] \t]\n
    }
    return $text
}

proc ::cbind::report::Percent {n total} {
    if {$total == 0} { return "-" }
    return [format %.1f%% [expr {100.0 * $n / $total}]]
}

proc ::cbind::report::Line {label n {total ""} {note ""}} {
    set s [format "  %-70s %7s" $label $n]
    if {$total ne ""} { append s [format " %8s" [Percent $n $total]] }
    if {$note ne ""} { append s "  $note" }
    return $s
}

# The counts of MODEL as a dict (also the manifest's).
proc ::cbind::report::counts {model} {
    set c [dict create]
    foreach k {declared inline fnmacros aliases tablestubs opaque complete fnptrTypedefs
            constantsSeen constants enumerators direct alias thunk unsupported excluded
            ptrParams manual proven unknownParams resultIndependent resultAlias resultUnknown
            ptrResults bool boolOnly callbacks views unknownRetention} {
        dict set c $k 0
    }
    set blockers [dict create]
    foreach r [dict get $model records] {
        lassign $r kind name body
        if {[dict get $body origin] ne "public"} continue
        if {$kind eq "typedef"} {
            set t [::cir::unq [dict get $body type]]
            if {[lindex $t 0] eq "fn" || ([lindex $t 0] eq "ptr" && [lindex [::cir::unq [lindex $t 1]] 0] eq "fn")} {
                dict incr c fnptrTypedefs
            }
        }
    }
    set ix [::cir::index [dict get $model records]]
    foreach key [PublicTags $model $ix] {
        set complete [expr {[dict exists $ix tag $key] && [dict get $ix tag $key complete]}]
        dict incr c [expr {$complete ? "complete" : "opaque"}]
    }
    foreach e [dict get $model apis] {
        set k [dict get $e kind]
        if {[dict exists $e macro]} {
            if {[dict exists [dict get $model macros] [dict get $e name]] && [dict get $model macros [dict get $e name] form] eq "function"} {
                dict incr c fnmacros
            } else {
                dict incr c aliases
            }
        } elseif {[dict exists $e decl] && ([dict get $e decl definition] || [dict get $e decl storage] eq "static")} {
            dict incr c inline
        } else {
            dict incr c declared
        }
        if {[dict exists $e via] && [dict get $e via] eq "stub"} { dict incr c tablestubs }
        dict incr c $k
        if {$k eq "unsupported"} {
            foreach r [lsort -unique [lmap b [dict get $e blockers] {lindex $b 0}]] { dict incr blockers $r }
        }
        if {[dict exists $e usesBool] && [dict get $e usesBool]} {
            dict incr c bool
            if {$k in {direct alias thunk}} { dict incr c boolOnly }
        }
        if {$k ni {direct alias thunk}} continue
        set retains 0
        foreach p [dict get $e params] {
            if {"callback" in [dict get $p features] && [string match std::ffi::c::FnPtr* [dict get $p type]]} { set cb 1 }
            if {"pointer" ni [dict get $p features]} continue
            dict incr c ptrParams
            set kinds [lmap s [dict get $p sources] {lindex $s 0}]
            if {"manual" in $kinds} { dict incr c manual }
            if {"compiler" in $kinds} { dict incr c proven }
            if {[dict get $p escape] eq "" && [dict get $p access] eq ""} { dict incr c unknownParams }
            if {[dict get $p escape] in {"" captures}} { set retains 1 }
        }
        if {[info exists cb]} { dict incr c callbacks; unset cb }
        set view 0
        foreach f [concat {*}[lmap p [dict get $e params] {dict get $p features}] [dict get $e result features]] {
            if {$f eq "view"} { set view 1 }
        }
        if {$view} { dict incr c views }
        if {$retains} { dict incr c unknownRetention }
        if {[string match std::ffi::c::Ptr* [dict get $e result type]]} {
            dict incr c ptrResults
            switch -- [lindex [dict get $e result provenance] 0] {
                independent { dict incr c resultIndependent }
                alias { dict incr c resultAlias }
                default { dict incr c resultUnknown }
            }
        }
    }
    foreach k [dict get $model constants] {
        if {[dict get $k kind] eq "macro"} {
            if {[string match constant:* [dict get $k category]]} { dict incr c constantsSeen }
        } else {
            dict incr c enumerators
        }
        if {[dict get $k status] eq "constant"} { dict incr c constants }
    }
    dict set c blockers $blockers
    return $c
}

# The generated source sizes of FILES: {FILES LINES EXTERNS OPAQUES
# CONSTANTS SHIMTHUNKS}.
proc ::cbind::report::Sizes {files} {
    set n 0
    set lines 0
    set externs 0
    set opaques 0
    set constants 0
    set shim 0
    dict for {path text} $files {
        if {[string match *.bot $path]} {
            incr n
            incr lines [llength [split [string trimright $text \n] \n]]
            incr externs [regexp -all -line {^extern c fn } $text]
            incr opaques [regexp -all -line {^opaque struct } $text]
            incr constants [regexp -all -line {^[A-Za-z_][A-Za-z0-9_]* = } $text]
        } elseif {$path eq "shim.c"} {
            incr shim [regexp -all -line {^[^ /#*].*\{$} $text]
        }
    }
    return [list $n $lines $externs $opaques $constants $shim]
}

proc ::cbind::report::text {model} {
    set p [dict get $model profile]
    set c [counts $model]
    set apis [expr {[dict get $c declared] + [dict get $c inline] + [dict get $c fnmacros] + [dict get $c aliases]}]
    set bound [expr {[dict get $c direct] + [dict get $c alias] + [dict get $c thunk]}]
    set out {}
    lappend out "c-bindgen report: profile [dict get $p name], target [dict get $model target]"
    lappend out "[dict get $p description]"
    lappend out "(report.tsv has one row per name; `tclsh9.0 tools/c-bindgen.tcl report [::cbind::profile::cliName $p] -target [dict get $model target] -why NAME` explains one)"
    lappend out ""
    lappend out "Inventory (public headers, as this target's preprocessor sees them)"
    lappend out [Line "public declared functions" [dict get $c declared]]
    lappend out [Line "static inline callable APIs" [dict get $c inline]]
    lappend out [Line "function-like macros" [dict get $c fnmacros]]
    lappend out [Line "object-like macros naming a function (aliases)" [dict get $c aliases]]
    lappend out [Line "API names in all" $apis]
    lappend out [Line "opaque (incomplete) struct types" [dict get $c opaque]]
    lappend out [Line "complete struct and union types" [dict get $c complete]]
    lappend out [Line "function-pointer typedefs" [dict get $c fnptrTypedefs]]
    lappend out [Line "object-like constant macros" [dict get $c constantsSeen]]
    lappend out [Line "enumerators" [dict get $c enumerators]]
    lappend out ""
    lappend out "Bound (of the API names)"
    lappend out [Line "directly linked externs" [dict get $c direct] $apis]
    lappend out [Line "aliases (externs of the symbol a macro names)" [dict get $c alias] $apis]
    lappend out [Line "thunks (C wrappers in the shim)" [dict get $c thunk] $apis]
    lappend out [Line "  of them table-redirected names (stubs)" [dict get $c tablestubs]]
    lappend out [Line "bound in all" $bound $apis]
    lappend out [Line "unsupported" [dict get $c unsupported] $apis]
    lappend out [Line "excluded by the profile" [dict get $c excluded] $apis]
    lappend out [Line "constants generated" [dict get $c constants] [expr {[dict get $c constantsSeen] + [dict get $c enumerators]}]]
    lappend out ""
    lappend out "Unsupported API names by blocker (an API may have several)"
    set b [dict get $c blockers]
    foreach {reason n} [lsort -stride 2 -index 1 -integer -decreasing [lsort -stride 2 $b]] {
        lappend out [Line $reason $n $apis]
    }
    if {![dict size $b]} { lappend out "  (none)" }
    lappend out ""
    lappend out "Pointer contracts (bound APIs)"
    lappend out [Line "pointer parameters" [dict get $c ptrParams]]
    lappend out [Line "  with a favorable manual fact (the profile)" [dict get $c manual] [dict get $c ptrParams]]
    lappend out [Line "  with a compiler-proven fact" [dict get $c proven] [dict get $c ptrParams]]
    lappend out [Line "  unknown (no fact: no exposure, retains)" [dict get $c unknownParams] [dict get $c ptrParams]]
    lappend out [Line "pointer results" [dict get $c ptrResults]]
    lappend out [Line "  independent" [dict get $c resultIndependent] [dict get $c ptrResults]]
    lappend out [Line "  alias of a parameter" [dict get $c resultAlias] [dict get $c ptrResults]]
    lappend out [Line "  unknown" [dict get $c resultUnknown] [dict get $c ptrResults]]
    # The C floating positions the profile writes raw (RAW-C-FLOAT-FFI-
    # MILESTONE-1.md): shown only when there are any.
    set raws {}
    foreach e [dict get $model apis] {
        if {[dict get $e kind] in {direct alias thunk} && [dict exists $e representations]} {
            lappend raws {*}[lmap position [dict keys [dict get $e representations]] {list [dict get $e name] $position}]
        }
    }
    if {[llength $raws]} {
        lappend out ""
        lappend out "C floating representations (bound APIs)"
        lappend out [Line "positions bound raw (std::ffi::c::RawFloat, RawDouble; the profile)" [llength $raws]]
        foreach r $raws {
            lappend out "  [lindex $r 0] [lindex $r 1]"
        }
    }
    lappend out ""
    lappend out "Capability pressure (API names a missing FFI capability blocks or limits)"
    lappend out [Line "C _Bool in the signature (blocked without std::ffi::c::Bool)" [dict get $c bool] $apis]
    lappend out [Line "  of them bound now, bool their only blocker" [dict get $c boolOnly] $apis]
    foreach {label reasons} {
        "long double and the other floating types (C float and double are bound)" {long-double unsupported-floating}
        "aggregates by value (struct, union)" {by-value-aggregate union-by-value}
        "varargs (..., va_list)" {variadic va-list}
        "callback signature outside the ABI universe" {unsupported-callback-signature}
        "explicit calling convention (one the target does not take as its default)" {unsupported-calling-convention}
        "macro without a signature" {macro-needs-signature unsupported-macro}
    } {
        set n 0
        foreach e [dict get $model apis] {
            if {[dict get $e kind] ne "unsupported"} continue
            foreach bl [dict get $e blockers] {
                if {[lindex $bl 0] in $reasons} { incr n; break }
            }
        }
        lappend out [Line $label $n $apis]
    }
    set ccBound 0
    foreach e [dict get $model apis] {
        if {[dict get $e kind] in {direct alias thunk} && [dict exists $e conventions]} { incr ccBound }
    }
    lappend out [Line "bound, declaring a convention the target takes as its default" $ccBound $apis]
    lappend out [Line "bound, taking a callback (no Botlish function can be one yet)" [dict get $c callbacks] $apis]
    lappend out [Line "bound, pointing to a complete C struct (needs memory views)" [dict get $c views] $apis]
    lappend out [Line "bound, a pointer parameter that may be retained (direct)" [dict get $c unknownRetention] $apis]
    lappend out ""
    lappend out {*}[RecordSections $model $apis]
    lappend out ""
    lappend out "Macro APIs (apparent callables that are macros, and what each became)"
    set m [dict create shadowedDirect 0 selfAlias 0 objectAlias 0 rename 0 stubThunk 0 stubUnsupported 0 macroThunk 0 noSignature 0 otherMacro 0]
    foreach e [dict get $model apis] {
        if {[dict exists $e shadowedBy]} { dict incr m shadowedDirect }
        if {[dict exists $e via] && [dict get $e via] eq "self-alias"} { dict incr m selfAlias }
        if {[dict get $e kind] eq "alias"} {
            dict incr m [expr {[dict exists $e rename] ? "rename" : "objectAlias"}]
        }
        if {[dict exists $e via] && [dict get $e via] eq "stub"} {
            dict incr m [expr {[dict get $e kind] eq "thunk" ? "stubThunk" : "stubUnsupported"}]
        }
        if {[dict exists $e via] && [dict get $e via] eq "macro" && [dict get $e kind] eq "thunk"} { dict incr m macroThunk }
        if {[dict exists $e blockers]} {
            set rs [lmap b [dict get $e blockers] {lindex $b 0}]
            if {"macro-needs-signature" in $rs} { dict incr m noSignature }
            if {"unsupported-macro" in $rs} { dict incr m otherMacro }
        }
    }
    lappend out [Line "declared functions a function-like macro shadows (thunked: the macro)" [dict get $m shadowedDirect]]
    lappend out [Line "declared functions with a self-naming macro (bound as declared)" [dict get $m selfAlias]]
    lappend out [Line "object-like aliases of a function (bound: its symbol, named)" [dict get $m objectAlias]]
    lappend out [Line "function-like renames of a function (bound: its symbol, named)" [dict get $m rename]]
    lappend out [Line "stub-table redirections (thunked: the C call goes through the table)" [dict get $m stubThunk]]
    lappend out [Line "stub-table redirections not bound (a blocker, or no stub policy)" [dict get $m stubUnsupported]]
    lappend out [Line "function-like macros thunked by a profile signature" [dict get $m macroThunk]]
    lappend out [Line "function-like macros needing a signature (not bound)" [dict get $m noSignature]]
    lappend out [Line "other macros no thunk can stand for (not bound)" [dict get $m otherMacro]]
    lappend out ""
    lappend out "Macros"
    set cats [dict create]
    foreach name [dict get $model macroOrder] {
        set m [dict get $model macros $name]
        if {[dict get $m form] eq "object"} {
            dict incr cats "object: [::cmacro::objectCategory $name $m]"
        } else {
            dict incr cats "function: [lindex [::cmacro::functionCategory $name $m] 0]"
        }
    }
    foreach {k n} [lsort -stride 2 -index 1 -integer -decreasing [lsort -stride 2 $cats]] {
        lappend out [Line $k $n]
    }
    lappend out ""
    lappend out "Generated source"
    lassign [Sizes [dict get $model files]] n lines externs opaques constants shim
    lappend out [Line "Botlish files" $n]
    lappend out [Line "lines" $lines]
    lappend out [Line "extern c fn declarations" $externs]
    lappend out [Line "opaque types" $opaques]
    lappend out [Line "constants" $constants]
    lappend out [Line "layouts" [regexp -all -line {^layout } [expr {[dict exists $model files ${::cbind::emit::ns}/layouts.bot] ? [dict get $model files ${::cbind::emit::ns}/layouts.bot] : ""}]]]
    lappend out [Line "shim thunks" $shim]
    return [join $out \n]\n
}

# The report.txt sections of MODEL's records: the inventory and what became
# of it, every blocker, the pressure of each missing feature, the API
# pressure (C-BINDGEN-LAYOUTS.md).
proc ::cbind::report::RecordSections {model apis} {
    set c [layoutCounts $model]
    set complete [expr {[dict get $c structs] + [dict get $c unions]}]
    set out {}
    lappend out "Records and layouts (complete C records of the public headers and every record they hold by value)"
    lappend out [Line "complete structs" [dict get $c structs]]
    lappend out [Line "complete unions" [dict get $c unions]]
    lappend out [Line "  of them in a system header (held by value by a public record)" [dict get $c system]]
    lappend out [Line "  of them anonymous" [dict get $c anonymous]]
    lappend out [Line "  of them anonymous members laid out as records of their own" [dict get $c synthetic]]
    lappend out [Line "incomplete struct and union tags (pointee identities only)" [dict get $c incomplete]]
    lappend out [Line "anonymous struct members promoted into their record" [dict get $c promoted]]
    lappend out [Line "layouts emitted" [dict get $c emitted] $complete]
    lappend out [Line "  union layouts" [dict get $c emittedUnions] $complete]
    lappend out [Line "  synthetic layouts of anonymous members" [dict get $c emittedSynthetic] $complete]
    lappend out [Line "anonymous members representable but held by a blocked record (not emitted)" [dict get $c unheld] $complete]
    lappend out [Line "records whose layout is blocked" [dict get $c blocked] $complete]
    lappend out [Line "  structs" [dict get $c blockedStructs] $complete]
    lappend out [Line "  unions" [dict get $c blockedUnions] $complete]
    lappend out [Line "  with a direct blocker of their own" [dict get $c blockedDirect] $complete]
    lappend out [Line "  only through a record they hold by value" [dict get $c blockedTransitive] $complete]
    lappend out ""
    lappend out "Layout blockers (records blocked; a record may have several)"
    set r [dict get $c reasons]
    foreach {reason n} [lsort -stride 2 -index 1 -integer -decreasing [lsort -stride 2 $r]] {
        lappend out [Line $reason $n $complete]
    }
    if {![dict size $r]} { lappend out "  (none)" }
    lappend out "  records blocked only transitively, by the direct reasons below them:"
    set r [dict get $c roots]
    foreach {reason n} [lsort -stride 2 -index 1 -integer -decreasing [lsort -stride 2 $r]] {
        lappend out [Line "    $reason" $n $complete]
    }
    lappend out ""
    lappend out "Layout pressure (blocked records a missing feature would make layouts: directly + transitively)"
    if {[dict exists $model layouts]} {
        set recs [dict get $model layouts]
        foreach {label lift} [::cbind::pressure::features] {
            lassign [::cbind::pressure::recovered $recs $lift [dict get $model recordOrder]] d t
            lappend out [Line "$label" [expr {[llength $d] + [llength $t]}] $complete "[llength $d] + [llength $t]"]
        }
    }
    lappend out ""
    lappend out "API pressure (bound APIs pointing to C records)"
    if {[dict exists $model layouts]} {
        set a [::cbind::pressure::api $model]
        lappend out [Line "bound APIs with a pointer to a C record (parameter or result)" [dict get $a functions] $apis]
        lappend out [Line "  to a record with an emitted layout" [dict get $a functions_layout] [dict get $a functions]]
        lappend out [Line "  to a complete record whose layout is blocked" [dict get $a functions_blocked] [dict get $a functions]]
        lappend out [Line "  only to incomplete records (or complete ones outside the headers)" [dict get $a functions_opaque] [dict get $a functions]]
        lappend out "  pointers by shape and record (layout / blocked / incomplete / outside):"
        foreach shape {{param T *} {param const T *} {param T **} {result T *} {result T **}} {
            set ns [lmap st {layout blocked opaque outside} {expr {[dict exists $a "$shape $st"] ? [dict get $a "$shape $st"] : 0}}]
            lappend out [format "    %-24s %s" $shape [join $ns " / "]]
        }
        lappend out [Line "records bound signatures point to" [dict get $a identities]]
        lappend out [Line "  complete" [dict get $a complete] [dict get $a identities]]
        lappend out [Line "    with an emitted layout" [dict get $a layout] [dict get $a identities]]
        lappend out [Line "    whose layout is blocked" [dict get $a blocked] [dict get $a identities]]
        lappend out [Line "    outside the profile's records (a system header's)" [dict get $a outside] [dict get $a identities]]
        lappend out [Line "  incomplete (opaque only)" [dict get $a incomplete] [dict get $a identities]]
        lappend out "  bound APIs a missing feature would give a layout of a record they point to:"
        set users [dict get $a users]
        foreach {label lift} [::cbind::pressure::features] {
            lassign [::cbind::pressure::recovered $recs $lift [dict get $model recordOrder]] d t
            set gained {}
            set pointedTo 0
            foreach k [concat $d $t] {
                if {![dict exists $users $k]} continue
                incr pointedTo
                lappend gained {*}[dict get $users $k]
            }
            lappend out [Line "    $label" [llength [lsort -unique $gained]] [dict get $a functions] "$pointedTo record[expr {$pointedTo == 1 ? "" : "s"}]"]
        }
    }
    return $out
}

# The manifest of MODEL and its generated FILES.
proc ::cbind::report::manifest {model files} {
    set p [dict get $model profile]
    set h [::cbind::profile::headersFor $p [dict get $model target]]
    set tc [dict get $model toolchain]
    set lines {}
    lappend lines "c-bindgen manifest (C-BINDGEN.md, \"Manifest\")"
    lappend lines "generator_version $::cbind::emit::version"
    lappend lines "profile [dict get $p name]"
    lappend lines "profile_file [list [::chdr::relPath $::chdr::repoDir [dict get $p path]]] [::chdr::fileCrc32 [dict get $p path]]"
    lappend lines "target [dict get $model target]"
    lappend lines "library [dict get $h library]"
    lappend lines "source [list [dict get $h source]]"
    lappend lines "revision [dict get $model run revision]"
    lappend lines "entry [list [dict get $h entry]]"
    lappend lines "include [list [dict get $h includeDirs]]"
    lappend lines "defines [list [dict get $h defines]]"
    lappend lines "undefines [list [dict get $h undefines]]"
    lappend lines "flags [list [dict get $h flags]]"
    lappend lines "command [list [dict get $model run command]]"
    lappend lines "toolchain_family [dict get $tc family]"
    lappend lines "toolchain_version [list [dict get $tc version]]"
    lappend lines "toolchain_target [dict get $tc target]"
    lappend lines "toolchain_sysroot [dict get $tc sysroot]"
    lappend lines "user_label_prefix [list [dict get $model labelPrefix]]"
    lappend lines "evidence [dict get $p evidence][expr {[dict get $model evidenceProducer] ne "" ? " [list [dict get $model evidenceProducer]]" : ""}]"
    lappend lines "preprocessed_tokens [dict get $model run tokens]"
    # The headers the declarations and macros came from, with their CRCs.
    set headers {}
    foreach r [dict get $model records] {
        set f [lindex [dict get [lindex $r 2] loc] 0]
        if {[dict get [lindex $r 2] origin] eq "public" && $f ni $headers} { lappend headers $f }
    }
    foreach f [lsort $headers] {
        set abs [file join [dict get $model sourceRoot] $f]
        lappend lines "header [list $f] [expr {[file exists $abs] ? [::chdr::fileCrc32 $abs] : "missing"}]"
    }
    set shim [::cbind::emit::ShimName]
    lappend lines "shim_library [expr {$shim eq "" ? "none" : $shim}]"
    foreach path [lsort [dict keys $files]] {
        if {$path in {manifest.txt}} continue
        set text [dict get $files $path]
        lappend lines "file [list $path] [llength [split [string trimright $text \n] \n]] [::chdr::crc32 $text]"
    }
    set mods [dict create]
    foreach path [lsort [dict keys $files]] {
        if {[regexp {\.bot$} $path]} {
            foreach l [regexp -all -inline -line {^extern c library "([^"]+)"} [dict get $files $path]] {
                if {![string match {extern*} $l]} { dict lappend mods $path $l }
            }
        }
    }
    dict for {path libs} $mods { lappend lines "libraries [list $path] [list $libs]" }
    # Libraries found by symbol: each library's file and how many bound
    # functions it gives, every symbol more than one of them defines (the
    # first won), and the shim's references none of them define.
    if {[dict exists $model symbolLibraries] && [llength [dict get $model symbolLibraries]]} {
        set per [dict create]
        set multiple {}
        foreach e [dict get $model apis] {
            if {![dict exists $e library]} continue
            dict incr per [dict get $e library]
            if {[llength [dict get $e libraryAlso]]} {
                lappend multiple "import_multiple [dict get $e symbol] [dict get $e library] [list [dict get $e libraryAlso]]"
            }
        }
        foreach l [dict get $model symbolLibraries] {
            lappend lines "import_library $l [dict get $model libraryFiles $l] [expr {[dict exists $per $l] ? [dict get $per $l] : 0}]"
        }
        lappend lines {*}[lsort -unique $multiple]
        if {[dict exists $model shimUnresolved]} {
            foreach sym [dict get $model shimUnresolved] { lappend lines "shim_unresolved $sym" }
        }
    }
    set c [counts $model]
    foreach k [lsort [dict keys $c]] {
        if {$k eq "blockers"} continue
        lappend lines "count $k [dict get $c $k]"
    }
    foreach {reason n} [lsort -stride 2 [dict get $c blockers]] { lappend lines "blocked $reason $n" }
    # Explicit calling conventions the compiler takes as the target's
    # default (the cc: probe): how many bound APIs declare each.
    set ccs [dict create]
    foreach e [dict get $model apis] {
        if {[dict get $e kind] in {direct alias thunk} && [dict exists $e conventions]} {
            foreach cc [dict get $e conventions] { dict incr ccs $cc }
        }
    }
    foreach cc [lsort [dict keys $ccs]] {
        lappend lines "convention_default $cc [dict get $ccs $cc]"
    }
    # The records: the ABI identity their layouts are facts of, the counts.
    lappend lines "layout_abi [dict get $model target] [list [dict get $tc family] [dict get $tc target] [dict get $tc version]]"
    set lc [layoutCounts $model]
    foreach k [lsort [dict keys $lc]] {
        if {$k in {reasons roots}} continue
        lappend lines "layout_count $k [dict get $lc $k]"
    }
    foreach {reason n} [lsort -stride 2 [dict get $lc reasons]] { lappend lines "layout_blocked $reason $n" }
    # Every favorable contract fact, with its source.
    foreach e [dict get $model apis] {
        if {[dict get $e kind] ni {direct alias thunk}} continue
        foreach q [dict get $e params] {
            foreach s [dict get $q sources] {
                lappend lines "contract [dict get $e name] [dict get $q cname] [list [lindex $s 2]] [lindex $s 0] [list [lindex $s 1]]"
            }
        }
        foreach s [dict get $e result sources] {
            lappend lines "contract [dict get $e name] result [list [lindex $s 2]] [lindex $s 0] [list [lindex $s 1]]"
        }
    }
    # Every position written raw (RAW-C-FLOAT-FFI-MILESTONE-1.md), with its
    # source.
    foreach e [dict get $model apis] {
        if {[dict get $e kind] ni {direct alias thunk} || ![dict exists $e representations]} continue
        dict for {position chosen} [dict get $e representations] {
            lappend lines "representation [dict get $e name] $position [lindex $chosen 0] [list [lindex $chosen 1]]"
        }
    }
    # Policy for declared functions this target cannot bind: checked, kept,
    # applied to nothing.
    if {[dict exists $model unusedContracts]} {
        dict for {fn labels} [dict get $model unusedContracts] {
            lappend lines "contract-unused $fn [list $labels] (not bound on this target)"
        }
    }
    return [join $lines \n]\n
}

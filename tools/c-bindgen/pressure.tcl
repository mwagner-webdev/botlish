# pressure.tcl -- what the missing layout features would unlock
# (C-BINDGEN-LAYOUTS.md, "Layout pressure", "API pressure").
#
#   ::cbind::pressure::features            the feature sets the report weighs
#   ::cbind::pressure::recovered RECS F    the blocked records a layout
#                                          language with the features F would
#                                          represent: {DIRECT TRANSITIVE}
#   ::cbind::pressure::api MODEL           the bound APIs' pointers to C
#                                          records, by shape and by what their
#                                          record is now
#
# A counterfactual is computed on the dependency graph records.tcl built,
# never on a guess: a record becomes representable when every one of its
# direct blockers is a reason the features lift and every record it
# contains by value becomes representable too (an array of a blocked record
# is recovered only with its element; a struct holding a union by value is
# recovered only with whatever the union's alternatives wait for).
# Nothing here implements a feature; it counts.

namespace eval ::cbind::pressure {
    # Feature -> the blocker reasons it lifts, in report order.
    # (Fixed arrays are no missing feature since FIXED-LAYOUT-ARRAYS.md,
    # unions and anonymous members none since LAYOUT-UNIONS.md -- a union of
    # representable alternatives is a union layout -- and C float and double
    # fields none since C-FLOAT-FFI-MILESTONE-1.md: they are std::ffi::c::Float
    # and std::ffi::c::Double fields. long double and the extended floating
    # types still are.)
    variable features {
        {std::ffi::c::Bool fields} {c-bool}
        {long double fields} {long-double}
        {other floating fields (_Float16, __float128, ...)} {unsupported-floating}
        {bitfields} {bitfield}
        {flexible array members} {flexible-array}
        {explicit calling conventions} {unsupported-calling-convention}
        {all of the above} {c-bool long-double unsupported-floating bitfield flexible-array unsupported-calling-convention}
    }
}

proc ::cbind::pressure::features {} {
    variable features
    return $features
}

# The blocked complete records of RECS that the reasons LIFT would make
# representable: {DIRECT TRANSITIVE}, DIRECT those with a direct blocker of
# their own (all of them lifted), TRANSITIVE those blocked only by what they
# contain (recovered with it). Keys, in RECS order. ORDER is the records in
# dependency order (records.tcl's Order, the model's recordOrder), so that
# each is decided once, after what it holds.
proc ::cbind::pressure::recovered {recs lift {order ""}} {
    if {$order eq ""} { set order [::cbind::records::Order recs [dict keys $recs]] }
    set ok [dict create]
    foreach key $order {
        set rec [dict get $recs $key]
        switch -- [dict get $rec status] {
            layout-direct { dict set ok $key 1; continue }
            layout-blocked {}
            default { dict set ok $key 0; continue }
        }
        set yes 1
        foreach b [dict get $rec direct] {
            if {[lindex $b 0] ni $lift} { set yes 0; break }
        }
        if {$yes} {
            foreach d [dict get $rec deps] {
                if {![dict exists $ok [lindex $d 0]] || ![dict get $ok [lindex $d 0]]} { set yes 0; break }
            }
        }
        dict set ok $key $yes
    }
    set direct {}
    set transitive {}
    dict for {key rec} $recs {
        if {[dict get $rec status] ne "layout-blocked" || ![dict get $ok $key]} continue
        if {[llength [dict get $rec direct]]} { lappend direct $key } else { lappend transitive $key }
    }
    return [list $direct $transitive]
}

# The pointer SHAPE of C TYPE and the record it reaches: {SHAPE KEY} with
# SHAPE "T *", "const T *" or "T **" (two or more levels) and KEY the record
# ("struct T"), or "" when TYPE points to no C record.
proc ::cbind::pressure::Shape {type} {
    set ix $::cbind::model::ix
    set t [::cir::unq [::cir::final $ix $type]]
    if {[lindex $t 0] ne "ptr"} { return "" }
    set depth 0
    set const 0
    while {[lindex $t 0] eq "ptr"} {
        incr depth
        lassign [::cir::resolve $ix [lindex $t 1]] chain final
        if {$depth == 1} { set const [expr {"const" in [::cir::quals $final]}] }
        set t [::cir::unq $final]
    }
    if {[lindex $t 0] ni {struct union}} { return "" }
    set shape [expr {$depth > 1 ? "T **" : ($const ? "const T *" : "T *")}]
    return [list $shape "[lindex $t 0] [lindex $t 1]"]
}

# The API pressure of MODEL: a dict of counts and, per record key, the
# bound APIs pointing to it (`users`), for the report and the manifest.
#
#   functions         bound APIs with a pointer (parameter or result, any
#                     depth) to a C record
#   functions_layout  of them, pointing to at least one record with an
#                     emitted layout
#   functions_blocked of them, pointing to a complete record whose layout is
#                     blocked
#   functions_opaque  of them, pointing only to incomplete records or to
#                     records outside the candidates
#   SHAPE STATUS      pointer parameters and results by shape (param T *,
#                     param const T *, param T **, result T *, result T **)
#                     and what the record is (layout, blocked, opaque)
#   identities        the distinct records bound signatures point to, and of
#                     them complete, with a layout, blocked, incomplete
proc ::cbind::pressure::api {model} {
    set recs [dict get $model layouts]
    set c [dict create functions 0 functions_layout 0 functions_blocked 0 functions_opaque 0]
    set users [dict create]
    set pointed [dict create]
    foreach e [dict get $model apis] {
        if {[dict get $e kind] ni {direct alias thunk}} continue
        set uses {}
        foreach p [dict get $e params] { lappend uses [list param [dict get $p ctype]] }
        lappend uses [list result [dict get $e result ctype]]
        set statuses {}
        foreach u $uses {
            lassign $u role ctype
            set s [Shape $ctype]
            if {$s eq ""} continue
            lassign $s shape key
            set st [StatusOf $recs $key]
            lappend statuses $st
            set shapeKey [expr {$role eq "result" && $shape eq "const T *" ? "T *" : $shape}]
            dict incr c "$role $shapeKey $st"
            dict lappend users $key [dict get $e name]
            dict set pointed $key 1
        }
        if {![llength $statuses]} continue
        dict incr c functions
        if {"layout" in $statuses} { dict incr c functions_layout }
        if {"blocked" in $statuses} { dict incr c functions_blocked }
        if {"layout" ni $statuses && "blocked" ni $statuses} { dict incr c functions_opaque }
    }
    set ids [dict create identities 0 complete 0 layout 0 blocked 0 outside 0 incomplete 0]
    dict for {key _} $pointed {
        dict incr ids identities
        set st [StatusOf $recs $key]
        if {$st in {layout blocked outside}} { dict incr ids complete }
        dict incr ids [expr {$st eq "opaque" ? "incomplete" : $st}]
    }
    set out [dict merge $c $ids]
    dict set out users [dict map {k v} $users {lsort -unique $v}]
    return $out
}

# What record KEY is to the API pressure: layout, blocked, opaque
# (incomplete) or outside (a complete record of a header outside the
# profile's public ones that no candidate contains by value: no layout is
# considered for it).
proc ::cbind::pressure::StatusOf {recs key} {
    if {![dict exists $recs $key]} {
        set tag [dict get $::cbind::model::ix tag]
        if {[dict exists $tag $key] && [dict get $tag $key complete]} { return outside }
        return opaque
    }
    switch -- [dict get $recs $key status] {
        layout-direct { return layout }
        layout-blocked { return blocked }
        default { return opaque }
    }
}

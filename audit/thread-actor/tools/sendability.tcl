# sendability.tcl -- Probe C's analysis prototype
# (THREAD-ACTOR-ARCHITECTURE-CENSUS.md, "Message and sendability model").
# Disposable: it proves a rule can be DERIVED from facts the checker
# already has (types, the struct registry's opacity, context-ness, owner,
# tree field), not that the rule is final.
#
#   tclsh9.0 audit/thread-actor/tools/sendability.tcl [FILE.bot] [-struct Matrix]
#
# Builds FILE (default probe-c/matrix.bot), then classifies the declared type
# of every field of struct Matrix. Verdicts, strongest first:
#
#   reject   cannot cross a VM boundary at all (a continuation, code, an
#            installed authority, raw native memory access)
#   local    representation is a module's own (an opaque struct): a copy
#            may not mean the same in another VM (an identity such as
#            std::event_loop::Reg); only its owner can say otherwise
#   unknown  the static type does not say (any, an imprint variable, a
#            trait view): a dynamic check, or a static rejection
#   move     an affine C word: the bits can be handed over and the sender
#            loses them statically, but only an explicit authority may say
#            the pointee is usable from another thread
#   copy     a deep copy into the receiver's heap means exactly the value
#
# A composite takes the strongest verdict of its components (the first one
# reached is named).
set root [file normalize [file join [file dirname [info script]] .. .. ..]]
set file [file join $root audit thread-actor probe-c matrix.bot]
set structName Matrix
set rest {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    if {$a eq "-struct"} { set structName [lindex $argv [incr i]] } else { set file [file normalize $a] }
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

set rank {copy 0 move 1 unknown 2 local 3 reject 4}

# Standard-library opaque types whose owner (the standard library) would
# declare them sendable -- the owner's statement this rule requires of every
# opaque struct, written here as a table: byte storage, and the collections
# whose representation is ordinary Botlish values (MutableVectors of keys, values and stored keyed hashes). The keyed
# hashes are valid in another VM of the same runtime copy (one
# TABLE_HASH_KEY, ops.rs); a copy into another runtime copy (another
# native library) recomputes them.
set stdSendable {std::mutable_map::MutableMap std::mutable_set::MutableSet std::immutable_map::ImmutableMap std::ordered_table::Table std::ordered_table::Frozen}
# ... and the two whose representation the checker cannot see at all
# (`storage: any`, stdlib/abi/bytes.bot): only the owner knows the storage
# is one byte block, so its statement is the verdict itself.
set stdCopy {std::abi::bytes::Bytes std::abi::bytes::MutableBytes}

proc stronger {a b} {
    if {[dict get $::rank [lindex $a 0]] >= [dict get $::rank [lindex $b 0]]} { return $a }
    return $b
}

proc classify {type {seen {}}} {
    if {$type eq "never"} { return {copy "no value"} }
    if {[hir::types::IsTrait $type]} { return [list unknown "a view of trait [lindex $type 1]"] }
    if {[hir::types::IsFn $type]} { return {reject "a function value: code addresses and captures are its VM's"} }
    if {[hir::types::IsImprint $type]} { return {unknown "an imprint variable"} }
    if {[hir::types::IsCFnPtr $type]} { return {move "a C function pointer: a word, but only an authority knows the function is thread-safe"} }
    if {[hir::types::IsNativeMemory $type]} { return {reject "a native view or edit: access to native memory, not a value"} }
    if {[hir::cabi::IsFiniteFloating $type]} { return [classify [hir::cabi::Carrier $type] $seen] }
    if {[hir::refinements::IsRefined $type] && [hir::refinements::IsApplied [hir::refinements::Family $type]]} {
        return [classify [hir::refinements::Base $type] $seen]
    }
    if {[llength $type] >= 2} {
        switch -- [lindex $type 0] {
            coroutine { return {reject "a coroutine: its frames hold its VM (coroutine.rs prepare) and live on its stack"} }
            list {
                if {[llength $type] == 3} {
                    set v {copy ""}
                    foreach p [lindex $type 2] { set v [stronger $v [classify $p $seen]] }
                    return $v
                }
                return [Part "element" [lindex $type 1] $seen]
            }
            immutableSet { return [Part "member" [lindex $type 1] $seen] }
            mutvec - mutarray {
                set v [Part "element" [lindex $type 1] $seen]
                if {[lindex $v 0] eq "copy"} { return {copy "deep copy (a value: no alias survives)"} }
                return $v
            }
            struct {
                set v {copy ""}
                foreach {name t} [lindex $type 1] { set v [stronger $v [Part "field $name" $t $seen]] }
                return $v
            }
            nstruct {
                set id [lindex $type 1]
                if {$type in $seen} { return {copy ""} }
                if {![hir::structs::declared $id]} { return [list reject "$id: not a declared struct"] }
                if {$id in $::stdCopy} { return [list copy "byte storage ($id's owner's statement: its `storage: any` is one byte block)"] }
                if {[hir::structs::isContext $id]} { return [list reject "$id is a context: installed authority, never a message"] }
                if {[hir::structs::isOpaque $id] && $id ni $::stdSendable} {
                    set owner [hir::structs::owner $id]
                    if {$owner eq ""} { set owner "the entry program" } else { set owner "module $owner" }
                    return [list local "$id is opaque: its representation is $owner's, which alone could declare it sendable"]
                }
                set child [hir::structs::treeField $id]
                set v {copy ""}
                foreach {name t} [hir::structs::AppliedFieldTypes $type] {
                    if {$name eq $child} { continue }
                    if {$t eq {}} { set t any }
                    set v [stronger $v [Part "field $name of $id" $t [concat $seen [list $type]]]]
                }
                return $v
            }
        }
    }
    set kind [hir::types::kindOf $type]
    switch -- $kind {
        int - bool - unit - UnicodeChar - Float64 - DecimalRounded - rawfloat32 - rawfloat64 - str - enum {
            return [list copy "a $kind"]
        }
        cptr { return {move "an affine C pointer word: movable bits, but only an authority knows the pointee may be used from another thread"} }
        "" { return [list unknown "static type [hir::types::show $type]"] }
        default { return [list unknown "kind $kind"] }
    }
}

proc Part {what t seen} {
    set v [classify $t $seen]
    if {[lindex $v 1] eq ""} { return $v }
    return [list [lindex $v 0] "$what: [lindex $v 1]"]
}

set hir [surface::readProgramFile $file -warnings off]
hir::activate $hir
set id ""
foreach candidate [list $structName "::$structName"] {
    if {[hir::structs::declared $candidate]} { set id $candidate }
}
if {$id eq ""} { puts "no struct $structName"; exit 1 }
foreach {name t} [hir::structs::AppliedFieldTypes [list nstruct $id]] {
    lassign [classify $t] verdict why
    set affine [expr {[hir::types::IsAffine $t] ? "affine" : "unrestricted"}]
    puts [format "%-24s %-8s %-13s %s" $name $verdict $affine $why]
}

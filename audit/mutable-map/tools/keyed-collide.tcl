#!/usr/bin/env tclsh9.0
# keyed-collide.tcl -- writes audit/mutable-map/data/keyed-collide.txt: Ints
# whose keyed table hash (std::table_hash::of, HASHABLE-AND-KEYED-HASH.md)
# under one fixed hidden key has its low BITS bits zero, so that every one of
# them has the same home slot in every index of up to 2^BITS slots
# (ORDERED-MUTABLE-MAP-SET.md, "Collision corpus").
#
#   tclsh9.0 audit/mutable-map/tools/keyed-collide.tcl ?-key {K0 K1}?
#       ?-bits B? ?-count N? ?-out FILE?
#
# The collisions are genuine: they are collisions of the hash the table
# itself uses, under the key the tests and the fuzzer install
# (core::hashing::useTableHashKey, the driver's --table-hash-key), unlike
# audit/hashable/data/int-collide-1024.txt, whose keys collide under the
# public hash only (and so are ordinary keys to the table). Under any other
# key -- a process's own drawn one -- they are ordinary keys again: the
# secret is what an adversary does not know.
#
# The defaults are the ones the committed file was written with; the file
# is one decimal Int per line, ascending.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -key {1 2} -bits 10 -count 512 \
    -out [file join $root audit mutable-map data keyed-collide.txt]]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "keyed-collide.tcl: unknown option $option"
    }
    dict set options $option $value
}
set argv {}
source [file join $root core core.tcl]

core::hashing::useTableHashKey [dict get $options -key]
set mask [expr {(1 << [dict get $options -bits]) - 1}]
set found {}
for {set i 0} {[llength $found] < [dict get $options -count]} {set i [expr {$i + 1}]} {
    set h [core::value::intOf [core::hashing::tableHash [core::value::intFromNumber $i]]]
    if {($h & $mask) == 0} {
        lappend found $i
    }
}
core::hashing::useTableHashKey ""
file mkdir [file dirname [dict get $options -out]]
set f [open [dict get $options -out] w]
puts -nonewline $f [join $found \n]\n
close $f
puts "[llength $found] keys of $i tried -> [dict get $options -out]"

# transfer.tcl -- the transfer codec of the Tcl backends
# (SENDABILITY-AND-VALUE-COPY-MILESTONE-1.md): a sendable value encoded into
# owned bytes, and those bytes decoded into an independent value of the
# receiver's own.
#
#   std::transfer::encode(value) -> std::abi::bytes::Bytes
#   std::transfer::decode[T](data: std::abi::bytes::Bytes) -> T
#       errors TransferMalformed, TransferVersion, TransferTypeMismatch,
#              TransferInvalidValue, TransferLimit
#
# Both are written out after the checks (hir::transfer::Elaborate) as the
# run-time operations
#
#   transfer#encode(VALUE, SCHEMA, FNS)     transfer#decode(DATA, SCHEMA, FNS)
#
# SCHEMA the String {VERSION FINGERPRINT NODES} of the transferred static
# type (hir/transfer.tcl's header describes the nodes), FNS the List of the
# owner functions its `through` nodes call. The native runtime's codec
# (native/src/runtime/transfer.rs) writes and reads the same bytes: the
# format is one, not a backend's.
#
# The format (version 1). Every multi-byte number is little-endian; a
# *varuint* is unsigned LEB128, minimal (no trailing zero group), at most
# ten bytes and below 2^62.
#
#   header      the four bytes "BOTX", the version byte (1), and the
#               schema's 64-bit fingerprint (8 bytes)
#   unit        nothing
#   bool        one byte, 0 or 1
#   int         a varuint byte count L, then L bytes: the Int's minimal
#               two's complement (0 is L = 0); checked against the node's
#               integer domains
#   char        a varuint, a Unicode scalar value
#   float64     the 8 bytes of the binary64; finite, never -0
#   decimal     the 8 bytes of its binary64 representation; finite
#   raw32/raw64 the 4 or 8 bytes of the bit pattern, any pattern
#   str         a varuint byte count, then the UTF-8 bytes (strict)
#   list/set/vector/array
#               a varuint count, then the elements in order (a List's
#               stated length: checked)
#   struct      the fields, in the node's wire order (sorted names)
#   enum        a varuint: the case's index among the sorted case names
#   bytes/mutbytes
#               a varuint byte count, then the bytes
#   through     the representation's encoding
#
# After the root value the bytes end: anything after is TransferMalformed.
#
# Decoding never trusts a count. A count of elements of nonzero minimum
# size must fit in the bytes left (TransferMalformed otherwise); elements
# of zero size (unit, a struct of units) draw on a budget of 2^24 per
# decode (TransferLimit), and so does every Int's byte count beyond 2^20.
# The walks of both directions are iterative: a value's depth is bounded by
# memory, never by the host's stack. A decoded value is built entirely of
# fresh values of this process: byte storage, Strings and collections are
# made anew, ImmutableSets and the owner's `through` rebuild their own
# derived state (the receiver's hashes), and nothing of the bytes is kept.

namespace eval core::transfer {
    variable magic BOTX
    variable version 1
    # The largest Int byte count a decode accepts (8 Mi bits).
    variable maxIntBytes [expr {1 << 20}]
    # The zero-size elements one decode may make.
    variable zeroBudget [expr {1 << 24}]
    # The largest varuint (counts and lengths).
    variable maxVaruint [expr {(1 << 62) - 1}]
}

foreach name {TransferMalformed TransferVersion TransferTypeMismatch TransferInvalidValue TransferLimit} {
    core::native::declareError $name
}
unset name

# ---------------------------------------------------------------------------
# Encoding

# The value transfer#encode(VALUE, SCHEMA, FNS) completes with: a normal
# completion with the std::abi::bytes::Bytes of VALUE's encoding, or the
# completion of an owner projection that did not complete normally (none
# does: hir::transfer::verifyDeclarations holds them total).
proc core::transfer::encode {value schema fns} {
    variable magic
    lassign [core::value::strOf $schema] version fingerprint nodes
    set functions [core::value::items $fns]
    set out [binary format a4cu $magic $version]
    append out [binary format w [expr {"0x$fingerprint"}]]
    set stack [list [list 0 $value]]
    while {[llength $stack]} {
        lassign [lpop stack] n v
        set node [lindex $nodes $n]
        switch -- [lindex $node 0] {
            unit {}
            bool {
                append out [binary format cu [expr {[lindex $v 1] eq "true" ? 1 : 0}]]
            }
            int {
                append out [Int [lindex $v 1]]
            }
            char {
                append out [Varuint [lindex $v 1]]
            }
            float64 - decimal {
                append out [binary format q [lindex $v 1]]
            }
            raw32 {
                append out [binary format iu [lindex $v 1]]
            }
            raw64 {
                append out [binary format wu [lindex $v 1]]
            }
            str {
                set raw [encoding convertto utf-8 [lindex $v 1]]
                append out [Varuint [string length $raw]] $raw
            }
            list - set {
                set items [lindex $v 1]
                append out [Varuint [llength $items]]
                Push stack [lindex $node 1] $items
            }
            vector {
                set items [core::mutvec::items $v]
                append out [Varuint [llength $items]]
                Push stack [lindex $node 1] $items
            }
            array {
                set items [core::mutarray::items $v]
                append out [Varuint [llength $items]]
                Push stack [lindex $node 1] $items
            }
            struct {
                set values [lindex $v 2]
                set wire [lindex $node 3]
                for {set i [expr {[llength $wire] - 1}]} {$i >= 0} {incr i -1} {
                    lassign [lindex $wire $i] field slot child
                    lappend stack [list $child [lindex $values $slot]]
                }
            }
            enum {
                set index [lsearch -exact [lindex $node 2] [lindex $v 2]]
                if {$index < 0} {
                    error "core::transfer::encode: [core::value::show $v] is no case of [lindex $node 1]"
                }
                append out [Varuint $index]
            }
            bytes - mutbytes {
                set raw [binary decode hex [lindex $v 2 0 1]]
                append out [Varuint [string length $raw]] $raw
            }
            through {
                lassign $node kind id r k
                set completion [core::callable::invoke [lindex $functions $k] [list $v]]
                if {[core::completion::kind $completion] ne "value"} {
                    return $completion
                }
                lappend stack [list $r [core::completion::payload $completion]]
            }
            default {
                error "core::transfer::encode: unknown schema node \"$node\""
            }
        }
    }
    return [core::completion::normal [BytesValue $out]]
}

# Pushes onto STACKVAR one task per item of ITEMS, of node N, so the first
# item is popped first.
proc core::transfer::Push {stackVar n items} {
    upvar 1 $stackVar stack
    for {set i [expr {[llength $items] - 1}]} {$i >= 0} {incr i -1} {
        lappend stack [list $n [lindex $items $i]]
    }
}

# The varuint of the nonnegative integer N.
proc core::transfer::Varuint {n} {
    set out ""
    while {$n >= 0x80} {
        append out [binary format cu [expr {($n & 0x7f) | 0x80}]]
        set n [expr {$n >> 7}]
    }
    append out [binary format cu $n]
    return $out
}

# The encoding of the Int N (canonical decimal digits): its byte count and
# its minimal two's complement, little-endian.
proc core::transfer::Int {n} {
    if {$n == 0} {
        return [Varuint 0]
    }
    # The bits of the magnitude a two's complement needs besides the sign.
    set m [expr {$n < 0 ? -$n - 1 : $n}]
    set bits [expr {$m == 0 ? 0 : [string length [format %llb $m]]}]
    set count [expr {$bits / 8 + 1}]
    set u [expr {$n & ((1 << (8 * $count)) - 1)}]
    set hex [format %0*llx [expr {2 * $count}] $u]
    return "[Varuint $count][string reverse [binary decode hex $hex]]"
}

# The std::abi::bytes::Bytes value holding the bytes RAW.
proc core::transfer::BytesValue {raw} {
    return [core::value::structOf {std::abi::bytes::Bytes storage} \
        [list [core::value::bytestore [binary encode hex $raw]]]]
}

# ---------------------------------------------------------------------------
# Decoding

# The completion transfer#decode(DATA, SCHEMA, FNS) completes with: the
# decoded value, or the declared error that refuses the bytes.
proc core::transfer::decode {data schema fns} {
    try {
        return [Decode $data $schema $fns]
    } trap {TRANSFER-REFUSED} {message options} {
        return [core::completion::propagatingError [core::value::errorId [lindex [dict get $options -errorcode] 1]]]
    }
}

# Refuses the bytes being decoded with builtin error NAME.
proc core::transfer::Refuse {name message} {
    return -code error -errorcode [list TRANSFER-REFUSED $name] $message
}

proc core::transfer::Decode {data schema fns} {
    variable magic
    variable version
    variable zeroBudget
    lassign [core::value::strOf $schema] schemaVersion fingerprint nodes
    set functions [core::value::items $fns]
    set storage [lindex $data 2 0]
    set raw [binary decode hex [lindex $storage 1]]
    set end [string length $raw]
    if {$end < 13 || [string range $raw 0 3] ne $magic} {
        Refuse TransferMalformed "not transfer bytes: no header"
    }
    binary scan $raw @4cu got
    if {$got != $version} {
        Refuse TransferVersion "transfer format version $got (this runtime reads version $version)"
    }
    binary scan $raw @5wu fp
    if {[format %016llx $fp] ne $fingerprint} {
        Refuse TransferTypeMismatch "the bytes hold a value of another type (fingerprint [format %016llx $fp], expected $fingerprint)"
    }
    set min [MinSizes $nodes]
    set pos 13
    set budget $zeroBudget
    set values {}
    # Instructions, last first: {decode N}, {repeat N COUNT}, {build N K},
    # {rebuild N}.
    set work [list [list decode 0]]
    while {[llength $work]} {
        set instruction [lpop work]
        switch -- [lindex $instruction 0] {
            repeat {
                lassign $instruction op n count
                if {$count > 1} {
                    lappend work [list repeat $n [expr {$count - 1}]]
                }
                lappend work [list decode $n]
                continue
            }
            build {
                lassign $instruction op n k
                set node [lindex $nodes $n]
                if {$k == 0} {
                    set parts {}
                } else {
                    set parts [lrange $values end-[expr {$k - 1}] end]
                    set values [lreplace $values end-[expr {$k - 1}] end]
                }
                lappend values [Build $node $parts]
                continue
            }
            rebuild {
                lassign $instruction op n
                set node [lindex $nodes $n]
                set r [lpop values]
                set completion [core::callable::invoke [lindex $functions [expr {[lindex $node 3] + 1}]] [list $r]]
                if {[core::completion::kind $completion] ne "value"} {
                    error "core::transfer::decode: the rebuild of [lindex $node 1] did not complete normally"
                }
                lappend values [core::completion::payload $completion]
                continue
            }
        }
        set n [lindex $instruction 1]
        set node [lindex $nodes $n]
        switch -- [lindex $node 0] {
            unit {
                lappend values [core::value::unit]
            }
            bool {
                set b [Byte $raw pos $end]
                if {$b > 1} {
                    Refuse TransferInvalidValue "a Bool byte $b"
                }
                lappend values [core::value::bool $b]
            }
            int {
                lappend values [core::value::int [ReadInt $raw pos $end [lindex $node 1] budget]]
            }
            char {
                set c [ReadVaruint $raw pos $end]
                if {$c > 0x10FFFF || ($c >= 0xD800 && $c <= 0xDFFF)} {
                    Refuse TransferInvalidValue "$c is no Unicode scalar value"
                }
                lappend values [core::value::char $c]
            }
            float64 - decimal {
                set bits [Take $raw pos $end 8]
                binary scan $bits wu u
                if {(($u >> 52) & 0x7ff) == 0x7ff} {
                    Refuse TransferInvalidValue "a non-finite floating-point value"
                }
                if {[lindex $node 0] eq "float64" && $u == 0x8000000000000000} {
                    Refuse TransferInvalidValue "a negative zero Float64 (Float64 has one zero)"
                }
                binary scan $bits q x
                if {[lindex $node 0] eq "float64"} {
                    lappend values [core::value::float Float64 $x]
                } else {
                    lappend values [core::decimal::value $x]
                }
            }
            raw32 {
                binary scan [Take $raw pos $end 4] iu u
                lappend values [core::cabi::rawValue binary32 $u]
            }
            raw64 {
                binary scan [Take $raw pos $end 8] wu u
                lappend values [core::cabi::rawValue binary64 $u]
            }
            str {
                set count [ReadVaruint $raw pos $end]
                set utf8 [Take $raw pos $end $count]
                if {[catch {encoding convertfrom -profile strict utf-8 $utf8} text]} {
                    Refuse TransferInvalidValue "a String that is not UTF-8"
                }
                lappend values [core::value::str $text]
            }
            bytes - mutbytes {
                set count [ReadVaruint $raw pos $end]
                set hex [binary encode hex [Take $raw pos $end $count]]
                set store [expr {[lindex $node 0] eq "bytes" ? [core::value::bytestore $hex] : [core::value::mutbytes $hex]}]
                lappend values [core::value::structOf [list [lindex $node 1] [lindex $node 2]] [list $store]]
            }
            list - set - vector - array {
                set count [ReadVaruint $raw pos $end]
                set e [lindex $node 1]
                if {[lindex $node 0] eq "list" && [lindex $node 2] ne "" && $count != [lindex $node 2]} {
                    Refuse TransferInvalidValue "a List of $count elements where the type states [lindex $node 2]"
                }
                Admit $count [dict get $min $e] [expr {$end - $pos}] budget
                lappend work [list build $n $count]
                if {$count > 0} {
                    lappend work [list repeat $e $count]
                }
            }
            struct {
                set wire [lindex $node 3]
                lappend work [list build $n [llength $wire]]
                for {set i [expr {[llength $wire] - 1}]} {$i >= 0} {incr i -1} {
                    lappend work [list decode [lindex $wire $i 2]]
                }
            }
            enum {
                set index [ReadVaruint $raw pos $end]
                set cases [lindex $node 2]
                if {$index >= [llength $cases]} {
                    Refuse TransferInvalidValue "case index $index of enum [lindex $node 1] (it has [llength $cases])"
                }
                lappend values [core::value::enumValue [lindex $node 1] [lindex $cases $index]]
            }
            through {
                lappend work [list rebuild $n] [list decode [lindex $node 2]]
            }
            default {
                error "core::transfer::decode: unknown schema node \"$node\""
            }
        }
    }
    if {$pos != $end} {
        Refuse TransferMalformed "[expr {$end - $pos}] bytes after the value"
    }
    return [core::completion::normal [lindex $values 0]]
}

# The composite value of NODE (list, set, vector, array or struct)
# whose parts, in wire order, are PARTS.
proc core::transfer::Build {node parts} {
    switch -- [lindex $node 0] {
        list {
            return [core::value::listOf $parts]
        }
        set {
            # The receiver's own set: its members deduplicated by its own
            # equality (bytes holding one member twice decode to the set).
            return [core::value::immutableSet [core::immutableset::Dedup $parts]]
        }
        vector {
            return [core::mutvec::New $parts]
        }
        array {
            return [core::mutarray::New $parts]
        }
        struct {
            lassign $node kind id slots wire
            set values [lrepeat [llength $slots] {}]
            foreach w $wire part $parts {
                lset values [lindex $w 1] $part
            }
            return [core::value::structOf [concat [list $id] $slots] $values]
        }
    }
    error "core::transfer::Build: no composite node \"$node\""
}

# Checks a count of COUNT elements of minimum size MIN against the LEFT bytes
# remaining, and against BUDGETVAR's zero-size budget.
proc core::transfer::Admit {count min left budgetVar} {
    upvar 1 $budgetVar budget
    if {$min > 0} {
        if {$count > $left / $min} {
            Refuse TransferMalformed "$count elements of at least $min bytes each, $left bytes left"
        }
        return
    }
    set budget [expr {$budget - $count}]
    if {$budget < 0} {
        Refuse TransferLimit "more than [set ::core::transfer::zeroBudget] elements of no size"
    }
}

# Node index -> the fewest bytes a value of the node takes.
proc core::transfer::MinSizes {nodes} {
    set result [dict create]
    for {set n [expr {[llength $nodes] - 1}]} {$n >= 0} {incr n -1} {
        MinSize $nodes $n result {}
    }
    return $result
}

proc core::transfer::MinSize {nodes n resultVar visiting} {
    upvar 1 $resultVar result
    if {[dict exists $result $n]} {
        return [dict get $result $n]
    }
    if {$n in $visiting} {
        # A recursive type reaches itself only through a collection, whose
        # count is its size: nothing more is needed.
        return 0
    }
    lappend visiting $n
    set node [lindex $nodes $n]
    switch -- [lindex $node 0] {
        unit { set size 0 }
        float64 - decimal - raw64 { set size 8 }
        raw32 { set size 4 }
        struct {
            set size 0
            foreach w [lindex $node 3] {
                incr size [MinSize $nodes [lindex $w 2] result $visiting]
            }
        }
        through { set size [MinSize $nodes [lindex $node 2] result $visiting] }
        default { set size 1 }
    }
    dict set result $n $size
    return $size
}

# The next byte of RAW at POSVAR (END its length), advancing.
proc core::transfer::Byte {raw posVar end} {
    upvar 1 $posVar pos
    if {$pos >= $end} {
        Refuse TransferMalformed "the bytes end inside a value"
    }
    binary scan $raw @${pos}cu b
    incr pos
    return $b
}

# The next COUNT bytes of RAW at POSVAR, advancing.
proc core::transfer::Take {raw posVar end count} {
    upvar 1 $posVar pos
    if {$count > $end - $pos} {
        Refuse TransferMalformed "the bytes end inside a value"
    }
    set bytes [string range $raw $pos [expr {$pos + $count - 1}]]
    incr pos $count
    return $bytes
}

# The next varuint of RAW at POSVAR, advancing.
proc core::transfer::ReadVaruint {raw posVar end} {
    variable maxVaruint
    upvar 1 $posVar pos
    set value 0
    set shift 0
    for {set i 0} {$i < 10} {incr i} {
        set b [Byte $raw pos $end]
        set value [expr {$value | (($b & 0x7f) << $shift)}]
        if {($b & 0x80) == 0} {
            if {$b == 0 && $i > 0} {
                Refuse TransferMalformed "a varuint that is not minimal"
            }
            if {$value > $maxVaruint} {
                Refuse TransferLimit "a count or length of $value"
            }
            return $value
        }
        incr shift 7
    }
    Refuse TransferMalformed "a varuint of more than ten bytes"
}

# The next Int of RAW at POSVAR, advancing: checked minimal and in every
# integer domain of DOMAINS.
proc core::transfer::ReadInt {raw posVar end domains budgetVar} {
    variable maxIntBytes
    upvar 1 $posVar pos
    set count [ReadVaruint $raw pos $end]
    if {$count > $maxIntBytes} {
        Refuse TransferLimit "an Int of $count bytes"
    }
    if {$count == 0} {
        set n 0
    } else {
        set bytes [Take $raw pos $end $count]
        binary scan $bytes cu* codes
        set last [lindex $codes end]
        if {$count == 1 && $last == 0} {
            Refuse TransferInvalidValue "an Int that is not minimal (zero has no bytes)"
        }
        if {$count > 1} {
            set below [lindex $codes end-1]
            if {($last == 0 && ($below & 0x80) == 0) || ($last == 0xff && ($below & 0x80) != 0)} {
                Refuse TransferInvalidValue "an Int that is not minimal"
            }
        }
        set n [expr {"0x[binary encode hex [string reverse $bytes]]"}]
        if {$last & 0x80} {
            set n [expr {$n - (1 << (8 * $count))}]
        }
    }
    foreach domain $domains {
        if {[lindex $domain 0] eq "interval"} {
            lassign $domain kind lo hi
            if {$n < $lo || $n > $hi} {
                Refuse TransferInvalidValue "$n is outside its integer domain $lo..$hi"
            }
        } elseif {$n ni [lindex $domain 1]} {
            Refuse TransferInvalidValue "$n is no value of its integer domain"
        }
    }
    return $n
}

# ---------------------------------------------------------------------------
# Registration

# The public operations are written out by hir::transfer::Elaborate before
# any backend runs; their own implementations are never reached.
proc core::transfer::Unelaborated {args} {
    error "std::transfer: a call that hir::transfer::Elaborate did not write out (internal)"
}

core::native::register std::transfer::encode -arity 1 -impl core::transfer::Unelaborated \
    -param-types {any} -result-type struct -sending 0 -ownership {observe} \
    -result-shape {named-struct std::abi::bytes::Bytes}
core::native::register std::transfer::decode -arity 1 -impl core::transfer::Unelaborated \
    -param-types {struct} -result-type any -sending result \
    -errors {TransferMalformed TransferVersion TransferTypeMismatch TransferInvalidValue TransferLimit} \
    -imprint {vars {T} params {{nstruct std::abi::bytes::Bytes}} result {imprint T}}
core::native::register transfer#encode -arity 3 -impl core::transfer::encode \
    -param-types {any str list} -result-type struct -completion 1 -ownership {observe observe observe} \
    -result-shape {named-struct std::abi::bytes::Bytes}
core::native::register transfer#decode -arity 3 -impl core::transfer::decode \
    -param-types {struct str list} -result-type any -completion 1 \
    -errors {TransferMalformed TransferVersion TransferTypeMismatch TransferInvalidValue TransferLimit} \
    -imprint {vars {T} params {{nstruct std::abi::bytes::Bytes} any any} result {imprint T}}

# The owner functions of the standard library's `sendable through` clauses
# are internal: the protocol's, never API.
foreach name {
    std::immutable_map::transfer_out std::immutable_map::transfer_in
    std::mutable_map::transfer_out std::mutable_map::transfer_in
    std::mutable_set::transfer_out std::mutable_set::transfer_in
} {
    core::native::declareInternalMember $name
}
unset name

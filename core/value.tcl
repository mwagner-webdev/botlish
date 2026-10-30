# value.tcl -- runtime value representation.
#
# Every runtime value is a tagged Tcl list whose first element names its kind.
# The tag is deliberate: Tcl's "everything is a string" must not leak into the
# language, so the integer 10, the string "10" and the Boolean true are
# distinct values.
#
#   {int DIGITS}              arbitrary-precision integer, canonical decimal
#   {str TEXT}                string. A String carries nothing but its
#                             text: a refinement of str (REFINEMENT-VALUES.md)
#                             is a static proof fact with exactly this
#                             representation -- no tag, no evidence, no
#                             wrapper (Strings used to carry runtime
#                             "evidence" of opaque named types; that is gone).
#   {bool true|false}         Boolean
#   {unit}                    the unit value
#   {UnicodeChar CODEPOINT}   exactly one Unicode scalar value (U+0000..U+D7FF
#                             or U+E000..U+10FFFF; never a surrogate),
#                             CODEPOINT its canonical decimal value. Distinct
#                             from Int: same tagged-list shape as {int N},
#                             but a different tag, so a UnicodeChar can never
#                             be mistaken for an Int by kind (see
#                             UNICODE-CHAR-LITERALS.md). Immutable.
#   {Float64 X}               a finite floating-point number of the
#                             primitive float type the tag names
#                             (FLOAT64-MILESTONE-1.md; core/type.tcl's
#                             float family, each width a kind of its own),
#                             X a Tcl double already rounded to that type.
#                             Never NaN, never an infinity, never negative
#                             zero: a value is a finite real number with one
#                             representation, so == and hash are exact
#                             comparisons of X. Only core::value::float
#                             makes one, from a double core/float.tcl has
#                             checked. Distinct from Int: no float is ever
#                             an Int by kind, nor the reverse. Immutable.
#   {list ITEMS}              ITEMS is a Tcl list of runtime values
#   {immutableSet ITEMS}      an immutable set of unique Botlish values
#                             (core::value::equal): ITEMS is a Tcl list of
#                             members, already deduplicated at construction
#                             (core::immutableset::Dedup is the one caller
#                             that guarantees this -- this constructor does
#                             not re-deduplicate). Kept in first-occurrence
#                             order purely as an implementation/display
#                             detail: a set has no semantic order (MINIMAL-
#                             IMMUTABLE-SET.md). A distinct runtime kind
#                             from List: {list ...} and {immutableSet ...}
#                             are never confused by core::value::kind, so
#                             untyped code cannot feed a set to a List
#                             operation. Immutable: there is no in-place
#                             insertion/removal operation.
#   {result ok|error VALUE}   Result
#   {errorId NAME ?PAYLOAD?}  identity of a declared application error
#                             completion (EXPLICIT-ERROR-COMPLETIONS.md): the
#                             payload of a `propagate-error` completion
#                             (core/completion.tcl), never an ordinary
#                             Botlish value a program can bind, pass or
#                             inspect -- it exists only to let `handle`
#                             (core/ir.tcl) tell declared errors apart by
#                             identity, never by message text. NAME is the
#                             error's own declared (program-unique) name;
#                             PAYLOAD, present exactly for an error that
#                             declares one, the payload value it carries (an
#                             anonymous struct value, ERROR-PAYLOADS.md):
#                             the identity and the payload stay two
#                             components, and a payload-free error is the
#                             one-word form it always was.
#   {block PARAMS BODY ENV CODE}
#                             Block: parameters, body expressions (IR),
#                             captured env, and the compiled code for the
#                             body ("" when the body is to be interpreted)
#   {native NAME}             native callable; metadata lives in the registry
#   {struct SHAPE VALUES}     a struct value (STRUCTS.md): SHAPE is {ID FIELD...}
#                             -- ID is "" for an anonymous struct (whose
#                             identity is its field set, FIELDs in canonical
#                             sorted order) or the declaration identity
#                             of a named struct ("Name", "namespace::Name";
#                             FIELDs in declared slot order) -- and VALUES
#                             the field values, one per FIELD, in slot
#                             order. Immutable. Distinct from List: a
#                             struct's kind is never `list`. The field names
#                             live in the shape, never in the individual
#                             value's own payload.
#   {enum ID CASE}            a case value of an enum (ENUMS.md): ID is the
#                             declaration identity of the enum ("Name",
#                             "namespace::Name"), CASE the declared name of
#                             one of its cases. The pair is the value's
#                             whole identity: two values are equal iff both
#                             parts are, so a same-spelled case of another
#                             enum is a different value. No ordinal, no
#                             integer and no String meaning is carried or
#                             implied (the case's position in its
#                             declaration is not part of the value).
#                             Immutable, unrestricted, no heap state. A
#                             future payload-bearing case extends this
#                             form; it does not replace it.
#   {bytestore HEX}           the owned byte storage behind std::abi::bytes::Bytes (ABI-
#                             BYTES.md): an immutable, finite sequence of
#                             bytes, HEX its lowercase hexadecimal text (two
#                             digits per byte, so the byte count is
#                             [string length HEX] / 2 and the empty
#                             sequence is {bytestore {}}). A distinct runtime
#                             kind from List and String: a byte is a plain
#                             0..255 value, never a character, and nothing
#                             terminates the sequence (a NUL byte is
#                             "00"). Equality is exact byte-sequence
#                             equality. It exists only inside the owning
#                             module's opaque struct (stdlib/abi/bytes.bot's Bytes);
#                             no source type spells it.
#   {mutbytes HEX}            the owned writable byte storage behind
#                             std::abi::bytes::MutableBytes (MUTABLE-BYTES.md): a finite
#                             sequence of bytes of one fixed length, HEX its
#                             lowercase hexadecimal text exactly as for
#                             `bytestore`. A distinct runtime kind from
#                             `bytestore` (so a MutableBytes is never
#                             accepted where an immutable byte storage is
#                             required, nor the reverse). It is a VALUE, not
#                             a reference: like every other kind it
#                             is an immutable Tcl value (a mutarray or mutvec
#                             header is a value too, by a different route:
#                             see below), and an update
#                             (core/bytestore.tcl's mutableSet) returns a
#                             new one, so two logical copies can never
#                             influence each other here. Equality is exact
#                             byte-sequence equality, never identity.
#   {coroutine ID}            a coroutine handle (COROUTINES.md); ID indexes
#                             core::coroutines' store (coroutines.tcl), which
#                             holds the coroutine's lifecycle state (fresh,
#                             suspended, running, completed, failed) and its
#                             continuation. Not a value in the immutable
#                             sense: resuming it changes that state. The
#                             compiler proves every handle has one owner
#                             (an affine binding), so the store's mutation
#                             is never observable as aliasing. No equality,
#                             no hash, no storage in another value.
#   {mutvec ID}               a MutableVector header (MUTABLE-VECTOR.md); ID
#                             indexes core::mutvec's store (mutvec.tcl), the
#                             vector's current elements. A VALUE with a
#                             mutable header: a mutation changes the header
#                             it is applied to, and the compiler proves only
#                             the one place owning a header ever mutates it
#                             (every logical copy is a new header,
#                             mutable_vector#share), so no alias of a header
#                             can observe it. No equality, no hash.
#   {mutarray ID}             a MutableArray header (MUTABLE-ARRAY.md); ID
#                             indexes core::mutarray's store (mutarray.tcl),
#                             the array's current elements. Like a mutvec, a
#                             VALUE with a mutable header: a mutation changes
#                             the header it is applied to, and the compiler
#                             proves only the one place owning a header ever
#                             mutates it (every logical copy is a new header,
#                             mutable_vector#share), so no alias of a header
#                             can observe it. No equality, no hash.
#   {cptr ADDRESS}            a raw C address (C-ABI-TYPES.md, core/cabi.tcl):
#                             a data or a function pointer -- distinct static
#                             types of this one kind -- ADDRESS its bits as
#                             a canonical unsigned decimal, 0 for null. Not
#                             an Int: no arithmetic, ordering, conversion,
#                             equality or hash (an affine value has none);
#                             the pointee identity is static only.
#
# Every value is treated as a value: a {mutbytes HEX} because the backends
# realize each update as a new storage, a {mutarray ID}/{mutvec ID} header
# because only its one owning place ever mutates it (above). Code outside
# this file should construct and inspect values only through these
# procedures.

namespace eval core::value {
    # Every row of core/type.tcl's float family is a kind of its own here;
    # type.tcl checks that the two lists agree when it loads.
    variable kinds {int str bool unit list result block native mutarray UnicodeChar immutableSet errorId struct bytestore mutbytes coroutine mutvec enum cptr Float64 DecimalRounded}
    # The kinds whose values have no type-blind structural equality: `equal`
    # refuses them (EQUALITY), and the compiler's equality-totality proof
    # (hir::types::HashClass, HASHABLE-AND-KEYED-HASH.md) reads this very
    # list, so the static answer and the operation cannot disagree. Callables
    # and coroutine handles would need identity semantics; MutableArray and
    # MutableVector have none (their header's identity is never a value's); a
    # C pointer's or native view's address is never observable; a
    # DecimalRounded value is equal to another only at its static type's
    # precision, which a type-blind comparison does not know. native/src/
    # runtime/ops.rs's `equal` refuses the same kinds.
    variable incomparable {block native mutarray coroutine mutvec cptr DecimalRounded}
}

proc core::value::isCanonicalInt {text} {
    regexp {^(?:0|-?[1-9][0-9]*)$} $text
}

# 1 if TEXT is the canonical decimal form of a Unicode scalar value: an
# integer in 0..0xD7FF or 0xE000..0x10FFFF. Surrogates (0xD800..0xDFFF) are
# never scalar values (see UNICODE-CHAR-LITERALS.md); this is the one place
# that rule is enforced, so both the lexer's own literal validation and
# core::value::char share it.
proc core::value::isValidScalar {text} {
    if {![isCanonicalInt $text]} {
        return 0
    }
    set n $text
    return [expr {($n >= 0 && $n <= 0xD7FF) || ($n >= 0xE000 && $n <= 0x10FFFF)}]
}

# ---------------------------------------------------------------------------
# Constructors

proc core::value::int {digits} {
    if {![isCanonicalInt $digits]} {
        error "core::value::int: not a canonical integer: \"$digits\""
    }
    return [list int $digits]
}

# The Int whose value is N, an integer Tcl itself computed -- an integer
# `expr` result on Ints' own payloads (or such a payload itself), or a count
# such as `llength` or `string length` returns -- never text from a program
# or other input (that goes through `int`). Tcl renders every integer it
# computes in canonical decimal, so N is not validated. That is the point:
# isCanonicalInt's regexp would make Tcl generate the decimal string of a
# bignum (quadratic in its digits: about 50 s for 2^1048576 in Tcl 9.0.1)
# and then replace its bignum internal representation by a string one,
# which the next arithmetic on it has to parse back. Kept unvalidated, a
# computed Int stays a number until something needs its text.
proc core::value::intFromNumber {n} {
    return [list int $n]
}

proc core::value::str {text} {
    return [list str $text]
}

# CODEPOINT (canonical decimal text) must be a valid Unicode scalar value
# (isValidScalar): never a surrogate, never above U+10FFFF. This is the only
# constructor of a UnicodeChar value -- there is no Int -> UnicodeChar
# conversion (see UNICODE-CHAR-LITERALS.md item 5).
proc core::value::char {codepoint} {
    if {![isValidScalar $codepoint]} {
        error "core::value::char: not a Unicode scalar value: \"$codepoint\""
    }
    return [list UnicodeChar $codepoint]
}

# The value of the floating-point type TYPE (a kind of core/type.tcl's float
# family) whose number is X, a Tcl double that core/float.tcl has rounded to
# TYPE and found finite (core::float::Make, the one caller). Zero is always
# the positive zero: a value has one representation (header).
proc core::value::float {type x} {
    if {$x == 0} {
        set x 0.0
    }
    return [list $type $x]
}

# The single point where a host (Tcl) truth value becomes a language Boolean.
# Only exactly 0 or 1 is accepted; no Tcl truthiness rules apply.
proc core::value::bool {flag} {
    if {$flag eq "1"} { return {bool true} }
    if {$flag eq "0"} { return {bool false} }
    error "core::value::bool: expected 0 or 1, got \"$flag\""
}

proc core::value::true {} { return {bool true} }
proc core::value::false {} { return {bool false} }
proc core::value::unit {} { return {unit} }

proc core::value::listOf {items} {
    foreach item $items { check $item }
    return [list list $items]
}

# ITEMS must already be deduplicated by core::value::equal -- the one caller
# that guarantees this is core::immutableset::Dedup (core/immutableset.tcl);
# this constructor does not re-deduplicate.
proc core::value::immutableSet {items} {
    foreach item $items { check $item }
    return [list immutableSet $items]
}

# The byte storage holding the bytes of HEX (lowercase hexadecimal text, two
# digits per byte; "" is the empty storage). Trusted natives only: the one
# constructor of a bytestore value (core/bytestore.tcl).
proc core::value::bytestore {hex} {
    if {![regexp {^(?:[0-9a-f][0-9a-f])*$} $hex]} {
        error "core::value::bytestore: not lowercase hexadecimal byte text: \"$hex\""
    }
    return [list bytestore $hex]
}

# The writable byte storage holding the bytes of HEX (same text form as
# `bytestore`). Trusted natives only: the one constructor of a mutbytes value
# (core/bytestore.tcl).
proc core::value::mutbytes {hex} {
    if {![regexp {^(?:[0-9a-f][0-9a-f])*$} $hex]} {
        error "core::value::mutbytes: not lowercase hexadecimal byte text: \"$hex\""
    }
    return [list mutbytes $hex]
}

# The struct value with SHAPE ({ID FIELD...}, see this file's header) and
# VALUES (one per FIELD, in slot order).
proc core::value::structOf {shape values} {
    if {[llength [lindex $shape 0]] > 1 || [llength $values] != [llength $shape] - 1} {
        error "core::value::structOf: shape \"$shape\" does not fit [llength $values] value(s)"
    }
    foreach v $values { check $v }
    return [list struct $shape $values]
}

# The case CASE of the enum declared as ID (ENUMS.md): its whole identity is
# the pair. Neither may be empty: both come from a resolved declaration.
proc core::value::enumValue {id case} {
    if {$id eq "" || $case eq "" || [string first :: $case] >= 0} {
        error "core::value::enumValue: not an enum case: \"$id\" \"$case\""
    }
    return [list enum $id $case]
}

proc core::value::ok {payload} {
    return [list result ok [check $payload]]
}

# The identity of declared error NAME (a program-unique name -- see
# hir/errordecls.tcl): the payload `core::completion::propagatingError`
# carries. NAME must not be empty: it always comes from a validated `error`
# declaration, never from unchecked input.
proc core::value::errorId {name args} {
    if {$name eq ""} {
        error "core::value::errorId: name must not be empty"
    }
    if {[llength $args] > 1} {
        error "core::value::errorId: at most one payload"
    }
    return [list errorId $name {*}$args]
}

proc core::value::errorIdName {v} { Require errorId $v; return [lindex $v 1] }

# 1 if error identity V carries a payload (ERROR-PAYLOADS.md).
proc core::value::errorIdHasPayload {v} { Require errorId $v; return [expr {[llength $v] == 3}] }

# The payload error identity V carries (it must carry one).
proc core::value::errorIdPayload {v} {
    Require errorId $v
    if {[llength $v] != 3} {
        error "core::value::errorIdPayload: error [lindex $v 1] carries no payload"
    }
    return [lindex $v 2]
}

proc core::value::err {payload} {
    return [list result error [check $payload]]
}

proc core::value::block {params body env {code ""}} {
    # The Block keeps its captured environment alive (env.tcl, Lifetime).
    core::env::pin $env
    return [list block $params $body $env $code]
}

proc core::value::native {name} {
    return [list native $name]
}

# ---------------------------------------------------------------------------
# Inspection

proc core::value::kind {v} {
    variable kinds
    if {[catch {llength $v} length] || $length == 0 || [lindex $v 0] ni $kinds} {
        error "core::value: not a runtime value: \"$v\""
    }
    return [lindex $v 0]
}

proc core::value::check {v} {
    kind $v
    return $v
}

# Implementation-level accessor guard: a mismatch here is an evaluator bug.
proc core::value::Require {kind v} {
    if {[kind $v] ne $kind} {
        error "core::value: expected $kind value, got \"$v\""
    }
}

# Language-level guard for primitives: a mismatch is an invalid program.
proc core::value::expect {kind v context} {
    if {[kind $v] ne $kind} {
        core::semanticError TYPE "$context: expected $kind, got [show $v]"
    }
    return $v
}

proc core::value::intOf {v}  { Require int $v;  return [lindex $v 1] }
proc core::value::strOf {v}  { Require str $v;  return [lindex $v 1] }
proc core::value::items {v}  { Require list $v; return [lindex $v 1] }
proc core::value::charOf {v} { Require UnicodeChar $v; return [lindex $v 1] }

# The number (a Tcl double) of V, a value of any floating-point type.
proc core::value::floatOf {v} {
    if {![core::type::isFloat [kind $v]]} {
        error "core::value: expected a floating-point value, got \"$v\""
    }
    return [lindex $v 1]
}
proc core::value::immutableSetItems {v} { Require immutableSet $v; return [lindex $v 1] }
proc core::value::bytestoreHex {v} { Require bytestore $v; return [lindex $v 1] }
proc core::value::bytestoreLength {v} { Require bytestore $v; return [expr {[string length [lindex $v 1]] / 2}] }
proc core::value::mutbytesHex {v} { Require mutbytes $v; return [lindex $v 1] }
proc core::value::mutbytesLength {v} { Require mutbytes $v; return [expr {[string length [lindex $v 1]] / 2}] }

# Returns host 1/0 for a language Boolean.
proc core::value::isTrue {v} {
    Require bool $v
    return [expr {[lindex $v 1] eq "true"}]
}

proc core::value::resultTag {v}     { Require result $v; return [lindex $v 1] }
proc core::value::resultPayload {v} { Require result $v; return [lindex $v 2] }

proc core::value::blockParams {v} { Require block $v; return [lindex $v 1] }
proc core::value::blockBody {v}   { Require block $v; return [lindex $v 2] }
proc core::value::blockEnv {v}    { Require block $v; return [lindex $v 3] }
proc core::value::blockCode {v}   { Require block $v; return [lindex $v 4] }

proc core::value::structShape {v}  { Require struct $v; return [lindex $v 1] }
proc core::value::structId {v}     { Require struct $v; return [lindex $v 1 0] }
proc core::value::structFields {v} { Require struct $v; return [lrange [lindex $v 1] 1 end] }
proc core::value::structValues {v} { Require struct $v; return [lindex $v 2] }

# The value of field NAME of struct value V, or an error (a Tcl error: the
# callers are the evaluator's own `project`, which has already proven the
# kind, and trusted code).
proc core::value::structGet {v name} {
    Require struct $v
    set slot [lsearch -exact [lrange [lindex $v 1] 1 end] $name]
    if {$slot < 0} {
        error "core::value::structGet: no field \"$name\" in [show $v]"
    }
    return [lindex $v 2 $slot]
}

proc core::value::enumId {v}       { Require enum $v; return [lindex $v 1] }
proc core::value::enumCaseName {v} { Require enum $v; return [lindex $v 2] }

proc core::value::nativeName {v}  { Require native $v; return [lindex $v 1] }
proc core::value::mutarrayId {v}  { Require mutarray $v; return [lindex $v 1] }
proc core::value::coroutineId {v} { Require coroutine $v; return [lindex $v 1] }
proc core::value::mutvecId {v}    { Require mutvec $v; return [lindex $v 1] }

# 1 if V is a Block or contains one (in a list, set, struct, Result, vector or
# array), at any depth: a work list of the values still to look into, never
# the host's recursion (a tree struct's value nests as deep as a program
# builds it: TREE-STRUCT-MILESTONE-1.md).
proc core::value::containsBlock {v} {
    set pending [list $v]
    while {[llength $pending] > 0} {
        set v [lpop pending]
        switch -- [kind $v] {
            block  { return 1 }
            list - immutableSet { lappend pending {*}[lindex $v 1] }
            struct { lappend pending {*}[lindex $v 2] }
            result { lappend pending [lindex $v 2] }
            mutvec { lappend pending {*}[core::mutvec::items $v] }
            mutarray { lappend pending {*}[core::mutarray::items $v] }
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# Equality: approximation of the future language's ==.
#
# Values of different kinds are never equal. Integers compare numerically,
# strings by exact characters, lists element-wise, Results by tag and payload.
# Equality of callables would require identity semantics, which are out of
# scope, so comparing a callable is an invalid program.
# Returns host 1/0.

proc core::value::equal {a b} {
    variable incomparable
    set ka [kind $a]
    set kb [kind $b]
    # MutableArray and MutableVector, like Block/Native, have no equality
    # (MUTABLE-ARRAY.md, MUTABLE-VECTOR.md: none was added for either; a
    # header's identity is never a value's). The refused kinds are the
    # `incomparable` list above.
    if {($ka in $incomparable && $ka ne "DecimalRounded") || ($kb in $incomparable && $kb ne "DecimalRounded")} {
        core::semanticError EQUALITY \
            "== is not defined for callables: [show $a] == [show $b]"
    }
    if {$ka eq "DecimalRounded" || $kb eq "DecimalRounded"} {
        # A DecimalRounded value (DECIMAL-ROUNDED-MILESTONE-1.md) is equal
        # to another at the precision its static type guarantees, which a
        # type-blind comparison does not know: its representation may hold
        # digits no type guarantees, and comparing those would make a
        # decision two correct implementations disagree on. `==` of two
        # DecimalRounded operands is the precise comparison
        # (core/decimal.tcl); inside a List, a struct or a set there is none.
        core::semanticError EQUALITY \
            "== of a DecimalRounded value needs the precision of its type, which this equality does not know (compare DecimalRounded values directly)"
    }
    if {$ka ne $kb} {
        return 0
    }
    switch -- $ka {
        bytestore - mutbytes {
            # Exact byte-sequence equality: the hex text is canonical
            # (lowercase, two digits per byte), so it is the bytes. A
            # MutableBytes compares by its current contents, never by
            # storage identity (it has none).
            return [string equal [lindex $a 1] [lindex $b 1]]
        }
        int - str - bool - UnicodeChar {
            # Integers and codepoints are canonical, so textual identity is
            # numeric equality. UnicodeChar never compares equal to Int or
            # String: different kinds are rejected above, before this
            # switch runs (no coercive equality).
            return [string equal [lindex $a 1] [lindex $b 1]]
        }
        unit {
            return 1
        }
        enum {
            # Nominal (ENUMS.md): the same enum declaration and the same
            # case of it. A same-spelled case of another enum is unequal,
            # and no position or number of a case takes part.
            return [expr {[lindex $a 1] eq [lindex $b 1] && [lindex $a 2] eq [lindex $b 2]}]
        }
        list {
            set xs [lindex $a 1]
            set ys [lindex $b 1]
            if {[llength $xs] != [llength $ys]} {
                return 0
            }
            foreach x $xs y $ys {
                if {![equal $x $y]} {
                    return 0
                }
            }
            return 1
        }
        result {
            return [expr {[lindex $a 1] eq [lindex $b 1]
                          && [equal [lindex $a 2] [lindex $b 2]]}]
        }
        struct {
            # Equal iff the same shape (an anonymous struct's field set, or
            # the same named declaration identity: a named struct is never
            # equal to an anonymous one or to another named struct, whatever
            # their fields) and every field equal, slot by slot
            # (STRUCTS.md). A shape mismatch is unequal without comparing
            # any contents, exactly as List's length mismatch is.
            if {[lindex $a 1] ne [lindex $b 1]} {
                return 0
            }
            set child [treeChildOf [lindex $a 1 0]]
            if {$child ne ""} {
                # A tree struct's value (TREE-STRUCT-MILESTONE-1.md): the
                # same comparison, slot by slot and child by child, walked
                # with a work stack instead of the host's recursion.
                return [TreeEqual $a $b $child]
            }
            set identity [identityOf [lindex $a 1 0]]
            if {$identity ne ""} {
                # A struct that declares its identity (REPRESENTATION-
                # INDEPENDENT-VALUE-IDENTITY.md) is equal to another of its
                # declaration when their identities are: the representation's
                # other fields take no part. Opaque, so a refusal inside it
                # is the opaque values' (below).
                try {
                    return [IdentityEqual $identity [lindex $a 2] [lindex $b 2]]
                } trap {CORE SEMANTIC EQUALITY} {} {
                    core::semanticError EQUALITY \
                        "== is not defined for callables: [show $a] == [show $b]"
                }
            }
            if {[isOpaqueStruct [lindex $a 1 0]]} {
                # An opaque struct's equality is its representation's, which
                # no message may show (OPAQUE-STRUCTS.md): a refusal inside
                # it is the opaque values' (ORDERED-MUTABLE-MAP-SET.md: a
                # MutableMap's index would show the hidden hash's placement).
                try {
                    foreach x [lindex $a 2] y [lindex $b 2] {
                        if {![equal $x $y]} {
                            return 0
                        }
                    }
                } trap {CORE SEMANTIC EQUALITY} {} {
                    core::semanticError EQUALITY \
                        "== is not defined for callables: [show $a] == [show $b]"
                }
                return 1
            }
            foreach x [lindex $a 2] y [lindex $b 2] {
                if {![equal $x $y]} {
                    return 0
                }
            }
            return 1
        }
        immutableSet {
            # Set equality, independent of construction/insertion order
            # (MINIMAL-IMMUTABLE-SET.md item 16): both operands are already
            # deduplicated by construction, so equal cardinality plus "every
            # member of A has an equal member in B" is exactly set equality
            # (a bijection must exist between two duplicate-free sets of the
            # same size where every A-member matches some B-member).
            set xs [lindex $a 1]
            set ys [lindex $b 1]
            if {[llength $xs] != [llength $ys]} {
                return 0
            }
            if {[llength $xs] > $::core::value::pairwiseLimit} {
                # A larger set is matched by hash (BucketMatch, the matching
                # identity equality uses): expected O(n). Where a member has
                # no hash, the comparison below is the one that refuses it.
                set matched [BucketMatch $xs {} $ys {} 0 0]
                if {$matched ne ""} {
                    return $matched
                }
            }
            foreach x $xs {
                set found 0
                foreach y $ys {
                    if {[equal $x $y]} {
                        set found 1
                        break
                    }
                }
                if {!$found} {
                    return 0
                }
            }
            return 1
        }
        default {
            # A floating-point type (core/type.tcl's float family): a finite
            # number with one representation (no NaN, no negative zero:
            # header), so numeric equality is exact identity of the value.
            # Two floats of different widths are different kinds (rejected
            # above).
            if {[core::type::isFloat $ka]} {
                return [expr {[lindex $a 1] == [lindex $b 1]}]
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Tree values (TREE-STRUCT-MILESTONE-1.md)
#
# A tree struct's value is an ordinary struct value whose child field holds a
# List of values of the same declaration: a finite rooted ordered tree, as
# deep as a program builds it. Equality, both hashes (core/hashing.tcl) and
# the display (show) of such a value mean exactly what they mean for any
# struct -- the same comparisons in the same order, the same canonical input,
# the same text -- but they walk the tree's topology with a work stack of
# their own, so its depth is bounded by memory, never by the host's
# recursion (a chain of a million nodes compares, hashes and prints). Which
# struct identities are tree structs, and which slot is the child field, is
# the compilation's struct registry's knowledge (hir/structs.tcl installs the
# test below); nothing here reads an address, an allocation order or anything
# else of the representation.

namespace eval core::value {
    # A command prefix taking a named-struct identity and returning the slot
    # position of its child field if it is a tree struct, else "" (also when
    # no registry is installed).
    variable treeTest ""
}

# Installs the tree test (see above); "" removes it.
proc core::value::setTreeTest {command} {
    variable treeTest
    set treeTest $command
}

# The child field's slot position of named struct ID if it is a tree struct,
# else "".
proc core::value::treeChildOf {id} {
    variable treeTest
    if {$id eq "" || $treeTest eq ""} {
        return ""
    }
    return [{*}$treeTest $id]
}

# 1 if V is a node of the tree struct whose shape is SHAPE (an element of a
# child List of such a node: a value of the same declaration).
proc core::value::IsTreeNode {v shape} {
    return [expr {[lindex $v 0] eq "struct" && [lindex $v 1] eq $shape}]
}

# equal's struct case for A and B, values of the tree struct whose child
# field is slot CHILD (same shape: equal checked it). The recursive
# comparison's exact order -- slot by slot, the child List's length before
# its elements, each child completely before the next slot -- run from a work
# stack of frames {fields XS YS I} (compare slots I.. of two nodes) and {kids
# XS YS I} (compare child pairs I..). The first unequal pair answers 0; a
# refusal (EQUALITY) propagates as the recursive comparison's would: as the
# opaque values' own when the tree struct is opaque, else as the pair that
# raised it.
proc core::value::TreeEqual {a b child} {
    set shape [lindex $a 1]
    if {[isOpaqueStruct [lindex $shape 0]]} {
        try {
            return [TreeEqualWalk $a $b $shape $child]
        } trap {CORE SEMANTIC EQUALITY} {} {
            core::semanticError EQUALITY \
                "== is not defined for callables: [show $a] == [show $b]"
        }
    }
    return [TreeEqualWalk $a $b $shape $child]
}

proc core::value::TreeEqualWalk {a b shape child} {
    set stack [list [list fields [lindex $a 2] [lindex $b 2] 0]]
    while {[llength $stack] > 0} {
        lassign [lpop stack] what xs ys i
        if {$what eq "kids"} {
            if {$i >= [llength $xs]} {
                continue
            }
            set x [lindex $xs $i]
            set y [lindex $ys $i]
            lappend stack [list kids $xs $ys [expr {$i + 1}]]
            if {[IsTreeNode $x $shape] && [IsTreeNode $y $shape]} {
                lappend stack [list fields [lindex $x 2] [lindex $y 2] 0]
            } elseif {![equal $x $y]} {
                return 0
            }
            continue
        }
        set n [llength $xs]
        for {} {$i < $n} {incr i} {
            set x [lindex $xs $i]
            set y [lindex $ys $i]
            if {$i == $child && [kind $x] eq "list" && [kind $y] eq "list"} {
                set kx [lindex $x 1]
                set ky [lindex $y 1]
                if {[llength $kx] != [llength $ky]} {
                    return 0
                }
                lappend stack [list fields $xs $ys [expr {$i + 1}]] [list kids $kx $ky 0]
                break
            }
            if {![equal $x $y]} {
                return 0
            }
        }
    }
    return 1
}

# show's text for V, a value of the tree struct of shape SHAPE whose child
# field is slot CHILD (DEBUG and REVEAL as show takes them): the recursive
# rendering's exact text, produced from a work stack of pieces -- literal
# text, or a node still to render.
proc core::value::TreeShow {v shape child debug reveal} {
    set name [lindex $shape 0]
    set fields [lrange $shape 1 end]
    set out ""
    set stack [list [list node $v]]
    while {[llength $stack] > 0} {
        lassign [lpop stack] what piece
        if {$what eq "text"} {
            append out $piece
            continue
        }
        if {![IsTreeNode $piece $shape]} {
            append out [show $piece $debug $reveal]
            continue
        }
        # The node's pieces, last first.
        set pieces {}
        set slot 0
        foreach field $fields item [lindex $piece 2] {
            if {$slot == 0} {
                lappend pieces [list text "$name \{$field: "]
            } else {
                lappend pieces [list text ", $field: "]
            }
            if {$slot == $child && [kind $item] eq "list"} {
                lappend pieces [list text "\["]
                set first 1
                foreach kid [lindex $item 1] {
                    if {!$first} {
                        lappend pieces [list text ", "]
                    }
                    set first 0
                    lappend pieces [list node $kid]
                }
                lappend pieces [list text "\]"]
            } else {
                lappend pieces [list text [show $item $debug $reveal]]
            }
            incr slot
        }
        lappend pieces [list text "\}"]
        lappend stack {*}[lreverse $pieces]
    }
    return $out
}

# ---------------------------------------------------------------------------
# Semantic identity (REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md)
#
# A struct may declare its identity apart from its representation: the
# elements of one List field in no order (`members`), or the pairs of two in
# no order (`associations`). Which structs do, and which fields, is the
# compilation's struct registry's knowledge (hir/structs.tcl installs the
# test below, as it installs the opaque-struct test); a struct of no declared
# identity is compared field by field, as always.
#
# Both forms are multiset equality, of the elements or of the pairs (a pair
# matches a pair whose key and value are both equal): equal exactly when a
# one-to-one matching of equal entries exists. That is set or map equality
# for the distinct members or keys an owner keeps, and an equivalence
# relation coherent with the hashes' commutative combination whatever the
# representation holds (core/hashing.tcl). Matching is greedy, which is exact
# for an equivalence: a positional prefix first (two values built alike match
# in order with no hashing), then the rest by hash buckets (expected O(n)),
# or pairwise where an entry has no hash (its comparison refuses it) or the
# rest is small.

namespace eval core::value {
    # A command prefix taking a named-struct identity and returning its
    # identity, {FORM {POSITION ...}} (the identity fields' slot positions),
    # or "" (no identity, or no registry installed).
    variable identityTest ""
    # Up to this many entries are matched pairwise, never hashed.
    variable pairwiseLimit 8
}

# Installs the identity test (see above); "" removes it.
proc core::value::setIdentityTest {command} {
    variable identityTest
    set identityTest $command
}

# The identity {FORM {POSITION ...}} of named struct ID, or "".
proc core::value::identityOf {id} {
    variable identityTest
    if {$id eq "" || $identityTest eq ""} {
        return ""
    }
    return [{*}$identityTest $id]
}

# The entries of a struct value's identity, from its field values VALUES:
# {KEYS VALUES PAIRS} -- the members (PAIRS 0, VALUES {}) or the keys and
# values, as many as both Lists hold (PAIRS 1).
proc core::value::IdentityEntries {identity values} {
    lassign $identity form positions
    switch -- $form {
        members {
            return [list [items [lindex $values [lindex $positions 0]]] {} 0]
        }
        associations {
            set keys [items [lindex $values [lindex $positions 0]]]
            set vals [items [lindex $values [lindex $positions 1]]]
            set n [expr {min([llength $keys], [llength $vals])}]
            return [list [lrange $keys 0 $n-1] [lrange $vals 0 $n-1] 1]
        }
    }
    error "core::value: unknown identity form $form"
}

# 1/0: whether two struct values of one declaration whose identity is
# IDENTITY, with field values AVALUES and BVALUES, are equal.
proc core::value::IdentityEqual {identity avalues bvalues} {
    variable pairwiseLimit
    lassign [IdentityEntries $identity $avalues] aKeys aVals pairs
    lassign [IdentityEntries $identity $bvalues] bKeys bVals
    set n [llength $aKeys]
    if {$n != [llength $bKeys]} {
        return 0
    }
    # The positional prefix: entries equal in place are matched in place.
    set i 0
    while {$i < $n && [EntryEqual $aKeys $aVals $i $bKeys $bVals $i $pairs]} {
        incr i
    }
    if {$i == $n} {
        return 1
    }
    if {$n - $i > $pairwiseLimit} {
        set matched [BucketMatch $aKeys $aVals $bKeys $bVals $pairs $i]
        if {$matched ne ""} {
            return $matched
        }
    }
    # Pairwise from I on: each entry of A matched to an unused equal entry of
    # B.
    set used [dict create]
    for {set x $i} {$x < $n} {incr x} {
        set found 0
        for {set y $i} {$y < $n} {incr y} {
            if {![dict exists $used $y] && [EntryEqual $aKeys $aVals $x $bKeys $bVals $y $pairs]} {
                dict set used $y 1
                set found 1
                break
            }
        }
        if {!$found} {
            return 0
        }
    }
    return 1
}

# 1/0: whether entry X of A equals entry Y of B (its key and, for pairs, its
# value).
proc core::value::EntryEqual {aKeys aVals x bKeys bVals y pairs} {
    if {![equal [lindex $aKeys $x] [lindex $bKeys $y]]} {
        return 0
    }
    return [expr {!$pairs || [equal [lindex $aVals $x] [lindex $bVals $y]]}]
}

# Matches A's entries from position FROM on against B's by hash: 1 when
# every one has an unused equal entry of B, 0 when one has none, or "" when
# an entry's key has no hash (the caller then compares pairwise, which is
# where such an entry is refused). Equal keys hash equally (the hashes'
# coherence), so only a bucket's entries are compared. The buckets are the
# public hash's: collisions cost time here, never a wrong answer.
proc core::value::BucketMatch {aKeys aVals bKeys bVals pairs from} {
    set n [llength $aKeys]
    set buckets [dict create]
    set aHashes {}
    try {
        for {set y $from} {$y < $n} {incr y} {
            dict lappend buckets [core::hashing::Fold public [lindex $bKeys $y]] $y
        }
        for {set x $from} {$x < $n} {incr x} {
            lappend aHashes [core::hashing::Fold public [lindex $aKeys $x]]
        }
    } trap {CORE SEMANTIC EQUALITY} {} {
        return ""
    }
    set used [dict create]
    for {set x $from} {$x < $n} {incr x} {
        set found 0
        foreach y [dict getdef $buckets [lindex $aHashes $x-$from] {}] {
            if {![dict exists $used $y] && [EntryEqual $aKeys $aVals $x $bKeys $bVals $y $pairs]} {
                dict set used $y 1
                set found 1
                break
            }
        }
        if {!$found} {
            return 0
        }
    }
    return 1
}

# ---------------------------------------------------------------------------
# Display: unambiguous human-readable rendering. DEBUG 1 asks for the
# debugging/differential rendering tests and tools compare backends with; it
# renders exactly like the plain form now (a String used to append its runtime
# evidence, "TEXT"#{Name ...}, which REFINEMENT-VALUES.md removed: a refined
# value renders as its carrier), and stays an argument of its own so REVEAL
# keeps its position.
#
# A value of an *opaque struct* (OPAQUE-STRUCTS.md: a struct whose
# representation belongs to the module declaring it) is rendered by its
# nominal type only, `<opaque geo::Point>`, wherever it sits (alone, in a list,
# in a struct, in a Result): normal user-facing text -- the program's printed
# value, runtime error messages, diagnostics -- never dumps a private
# representation. REVEAL 1 is the explicit request of internal tooling (the
# test harness's differential printer, audit scripts) for the full
# representation, `geo::Point {x: 1, y: 2}`, as for any struct. Which struct
# identities are opaque is the compilation's struct registry's knowledge
# (hir/structs.tcl installs the predicate below); a program with no opaque
# struct renders exactly as before.

namespace eval core::value {
    # A command prefix taking a named-struct identity and returning 1 if it
    # is an opaque struct, or "" (no opaque struct is known).
    variable opaqueStructTest ""
}

# Installs the opaque-struct predicate (see above); "" removes it.
proc core::value::setOpaqueStructTest {command} {
    variable opaqueStructTest
    set opaqueStructTest $command
}

# 1 if ID is the identity of an opaque struct.
proc core::value::isOpaqueStruct {id} {
    variable opaqueStructTest
    return [expr {$id ne "" && $opaqueStructTest ne "" && [{*}$opaqueStructTest $id]}]
}

proc core::value::show {v {debug 0} {reveal 0}} {
    switch -- [kind $v] {
        int  { return [lindex $v 1] }
        str  {
            # The lexer's escape set, as for a UnicodeChar below (with \"
            # for \'): the display is a literal denoting the String, and
            # never carries a raw line break or carriage return.
            set escaped [string map {\\ \\\\ \" \\\" \n \\n \r \\r \t \\t} [lindex $v 1]]
            return "\"$escaped\""
        }
        bool { return [lindex $v 1] }
        unit { return unit }
        UnicodeChar {
            set ch [format %c [lindex $v 1]]
            set escaped [string map {\\ \\\\ ' \\' \n \\n \r \\r \t \\t} $ch]
            return "'$escaped'"
        }
        list {
            set parts {}
            foreach item [lindex $v 1] {
                lappend parts [show $item $debug $reveal]
            }
            return "\[[join $parts {, }]\]"
        }
        result { return "[lindex $v 1]([show [lindex $v 2] $debug $reveal])" }
        enum {
            # Debug rendering only (ENUMS.md): the qualified spelling of the
            # case, never a String conversion or a serialization contract.
            return "[lindex $v 1]::[lindex $v 2]"
        }
        struct {
            # {name: "Grace", age: 45} / Person {name: "Ada", age: 36}: field
            # names in slot order (anonymous: canonical sorted order). An
            # opaque struct is its nominal type only (above), unless REVEAL.
            if {!$reveal && [isOpaqueStruct [lindex $v 1 0]]} {
                return "<opaque [lindex $v 1 0]>"
            }
            set child [treeChildOf [lindex $v 1 0]]
            if {$child ne ""} {
                # A tree struct's value: the same text, rendered without
                # the host's recursion (Tree values, above).
                return [TreeShow $v [lindex $v 1] $child $debug $reveal]
            }
            set parts {}
            foreach field [lrange [lindex $v 1] 1 end] item [lindex $v 2] {
                lappend parts "$field: [show $item $debug $reveal]"
            }
            set text "{[join $parts {, }]}"
            if {[lindex $v 1 0] ne ""} {
                return "[lindex $v 1 0] $text"
            }
            return $text
        }
        immutableSet {
            # Punctuation only; no semantic ordering is implied (item 87).
            set parts {}
            foreach item [lindex $v 1] {
                lappend parts [show $item $debug $reveal]
            }
            return "{[join $parts {, }]}"
        }
        bytestore {
            # Internal tooling only (reveal of an opaque std::abi::bytes::Bytes): the
            # byte count and the bytes. Normal rendering never reaches it.
            return "<bytes [expr {[string length [lindex $v 1]] / 2}]: [lindex $v 1]>"
        }
        mutbytes {
            # Internal tooling only (reveal of an opaque std::abi::bytes::MutableBytes).
            return "<mutbytes [expr {[string length [lindex $v 1]] / 2}]: [lindex $v 1]>"
        }
        block  { return "<block ([join [lindex $v 1] { }])>" }
        native { return "<native [lindex $v 1]>" }
        errorId {
            # Diagnostic rendering only (ERROR-PAYLOADS.md): the identity,
            # then the payload's ordinary rendering -- not a serialization.
            if {[llength $v] == 3} {
                return "<error [lindex $v 1] [show [lindex $v 2] $debug $reveal]>"
            }
            return "<error [lindex $v 1]>"
        }
        mutarray {
            # The current elements (a value's contents, never its header).
            set parts {}
            foreach item [core::mutarray::items $v] {
                lappend parts [show $item $debug $reveal]
            }
            return "<mutable-array \[[join $parts {, }]\]>"
        }
        coroutine { return "<coroutine>" }
        cptr { return [core::cabi::show $v] }
        mutvec {
            # The current elements (a value's contents, never its header).
            set parts {}
            foreach item [core::mutvec::items $v] {
                lappend parts [show $item $debug $reveal]
            }
            return "<mutable-vector \[[join $parts {, }]\]>"
        }
        DecimalRounded {
            # No digits (DECIMAL-ROUNDED-MILESTONE-1.md): a type-blind
            # rendering does not know how many decimal places the value's
            # type guarantees, and its representation may hold digits none
            # does. A display that knows the static type shows round(v, N)
            # (hir::decimal::Display, core::decimal::text). REVEAL (internal
            # differential tooling, never user-facing) shows the
            # representation, so backends are compared bit for bit.
            if {$reveal} {
                return "<DecimalRounded [core::float::Text [core::decimal::of $v]]>"
            }
            return "<DecimalRounded>"
        }
        default {
            # A floating-point type: its canonical decimal text
            # (core::float::text), the shortest digits that read back as
            # this number, written as a decimal literal.
            if {[core::type::isFloat [kind $v]]} {
                return [core::float::text $v]
            }
        }
    }
}

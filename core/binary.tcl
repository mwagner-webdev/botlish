# binary.tcl -- the binary operations of fixed layouts (BINARY-LAYOUT.md):
# imprinting bytes into a LayoutStruct[L] and emitting one back.
#
#   std::binary::parse(L, data)          LayoutStruct[L], imprinted from DATA, an
#                                   std::abi::bytes::Bytes of exactly L's size
#                                   (LayoutLengthMismatch otherwise)
#   std::binary::emit(value)             the std::abi::bytes::Bytes of L's size a
#                                   LayoutStruct[L] VALUE emits, L from the
#                                   value's static type
#   std::binary::layout_length(L)        L's size, a compile-time constant
#   std::binary::layout_alignment(L)     L's alignment, likewise
#   std::binary::read(data, L.path)      the value of the one representation the
#                                   designator L.path names, imprinted from
#                                   DATA, a std::abi::bytes::Bytes of exactly L's
#                                   size (LayoutLengthMismatch otherwise): a
#                                   scalar's Int, a nested layout's
#                                   LayoutStruct, an array's List -- one
#                                   alternative of a union, which has no
#                                   copied value of its own (LAYOUT-UNIONS.md)
#
# L is static evidence, never a value: written as a layout name where these
# operations take it (hir/resolve.tcl resolves it to the layout's descriptor
# constant), or read from the value's static type (hir::layouts::Elaborate
# rewrites std::binary::emit(v) to the internal binary#emit(v, DESCRIPTOR)). The
# descriptor (hir::layouts::descriptor) is the whole of what these
# implementations know about a layout -- they read no registry -- so a core
# IR program runs them unchanged on any front end's registry state:
#
#   {STRUCTID SIZE ALIGN {FIELD ...}}
#   FIELD = {NAME OFFSET u|i WIDTH ENDIAN}  a scalar: WIDTH bytes, unsigned
#                                           or two's-complement, ENDIAN
#                                           little (the target's)
#         | {NAME OFFSET f WIDTH ENDIAN}    a C floating scalar (C-FLOAT-FFI-
#                                           MILESTONE-1.md): the IEEE 754
#                                           format of WIDTH bytes (binary32,
#                                           binary64), its value a Float64
#         | {NAME OFFSET layout DESCRIPTOR} a nested layout, by value
#         | {NAME OFFSET ptr WIDTH ENDIAN}  a C pointer (native memory only)
#         | {NAME OFFSET array N STRIDE ELEMENT}
#                                           a fixed array (FIXED-LAYOUT-
#                                           ARRAYS.md): N elements STRIDE
#                                           bytes apart, ELEMENT the
#                                           element's representation words
#                                           (any of the forms above, after
#                                           NAME OFFSET); its value a List of
#                                           exactly N element values
#         | {NAME OFFSET union DESCRIPTOR}  a union held by value (LAYOUT-
#                                           UNIONS.md): DESCRIPTOR headed
#                                           LayoutUnion[ID], its FIELDs the
#                                           alternatives, all at offset 0. It
#                                           has no copied value, so nothing
#                                           here imprints or emits one
#
# This file is the reference implementation the interpreter runs, reading the
# descriptor at run time. The Tcl compiler and native lowering read the same
# descriptor statically and emit straight-line code (compiler/compiler.tcl's
# CompileLayoutOperation, native/lower.tcl's LayoutParse / LayoutEmit); none
# of them is a schema walker for a layout it knows.
#
# Semantics, every backend:
#
#   * parse requires exactly L's size: fewer or more bytes is the declared
#     builtin error LayoutLengthMismatch (no prefix parse, no cursor). Every
#     bit pattern of an integer field is a value of its type (hir/layouts.tcl's
#     "Scalar encodings"); a C floating field's is one only when it is
#     finite -- NaN and the infinities are the builtin NonFiniteFloat, a
#     negative zero is zero (core::cabi's Admit rule) -- so nothing else can
#     fail. Padding bytes -- bytes no
#     field covers -- are read by no one: two inputs that differ only in
#     padding imprint equal values. The value holds the fields only, never
#     the input (no provenance, no borrowed buffer).
#   * emit writes every field at its offset, recursively for a nested layout,
#     into L's size zero bytes: padding is always zero, so equal values emit
#     equal bytes. A field's value is already in its domain (its type says
#     so), so nothing is truncated; the reference implementation checks it
#     anyway (RANGE: a value no checked program can build). A Float64 written
#     into a binary32 field is narrowed (core::cabi's Narrow rule: to nearest,
#     ties to even), and one that overflows is NonFiniteFloat, never clamped.
#   * parse(emit(v)) == v for every v: the fields are written and read at the
#     same offsets with the same encodings.

namespace eval core::binary {
    # Tcl `binary` format letters of the little-endian WIDTH-byte integer.
    variable letters {1 c 2 s 4 i 8 w}
}

# The bytes (a Tcl byte string) of the std::abi::bytes::Bytes DATA.
proc core::binary::BytesOf {data context} {
    core::value::expect struct $data $context
    set bytesType [core::bytestore::bytesType]
    if {[core::value::structId $data] ne $bytesType} {
        core::semanticError TYPE "$context: expected $bytesType, got [core::value::show $data]"
    }
    return [binary decode hex [core::value::bytestoreHex [core::value::structGet $data [core::bytestore::storageField]]]]
}

# The layout identity a descriptor head STRUCTID names: LayoutStruct[ID]
# (a layout's struct view) or LayoutUnion[ID] (a union, LAYOUT-UNIONS.md).
proc core::binary::LayoutName {structId} {
    if {[string match {LayoutUnion\[*\]} $structId]} {
        return [string range $structId 12 end-1]
    }
    return [string range $structId 13 end-1]
}

# The std::abi::bytes::Bytes holding the byte string BYTES.
proc core::binary::BytesValue {bytes} {
    return [core::value::structOf [list [core::bytestore::bytesType] [core::bytestore::storageField]] \
        [list [core::value::bytestore [binary encode hex $bytes]]]]
}

# The Tcl `binary scan` / `binary format` field of a scalar of WIDTH bytes,
# SIGN u|i, ENDIAN (SCAN 1 adds the unsigned flag a scan needs).
proc core::binary::Letter {width sign endian {scan 1}} {
    variable letters
    set letter [dict get $letters $width]
    if {$endian eq "big" && $width > 1} {
        set letter [string toupper $letter]
    }
    if {$scan && $sign eq "u"} {
        append letter u
    }
    return $letter
}

# The value DESCRIPTOR imprints from BYTES at byte BASE.
proc core::binary::Decode {descriptor bytes base} {
    lassign $descriptor structId size align fields
    set names {}
    set values {}
    foreach field $fields {
        set name [lindex $field 0]
        lappend names $name
        lappend values [DecodeRepr [lrange $field 2 end] $bytes [expr {$base + [lindex $field 1]}] $name $structId]
    }
    return [core::value::structOf [linsert $names 0 $structId] $values]
}

# The value the representation words REPR (a descriptor field entry after
# its name and offset) imprint from BYTES at byte AT: an Int, a nested
# LayoutStruct, or a fixed array's List of exactly N element values
# (FIXED-LAYOUT-ARRAYS.md), element i at AT + i * STRIDE. NAME and STRUCTID
# name the field in a refusal.
proc core::binary::DecodeRepr {repr bytes at name structId} {
    switch -- [lindex $repr 0] {
        layout {
            return [Decode [lindex $repr 1] $bytes $at]
        }
        ptr {
            # Statically LAYOUT-NATIVE-ONLY (hir/layouts.tcl): arbitrary
            # bytes never become a pointer.
            core::semanticError TYPE "std::binary::parse: field \"$name\" of $structId is a C pointer, which is never imprinted from bytes"
        }
        union {
            # Statically LAYOUT-UNION (hir/layouts.tcl): several
            # interpretations of the same bytes are no value to imprint.
            core::semanticError LAYOUT-UNION "field \"$name\" of $structId is the union layout [LayoutName [lindex $repr 1 0]], which has no copied value (one of its alternatives is read at a time)"
        }
        array {
            lassign $repr - extent stride element
            set items {}
            for {set i 0} {$i < $extent} {incr i} {
                lappend items [DecodeRepr $element $bytes [expr {$at + $i * $stride}] $name $structId]
            }
            return [core::value::listOf $items]
        }
        f {
            # A C floating field: admitted, or NonFiniteFloat.
            set format [core::cabi::formatOfWidth [lindex $repr 1]]
            return [core::cabi::FloatingValue "field \"$name\" of $structId" \
                [core::cabi::DecodeFloating $format $bytes $at]]
        }
        r {
            # A raw C floating field (RAW-C-FLOAT-FFI-MILESTONE-1.md): its
            # bits, as they are.
            return [RawDecode $repr $bytes $at]
        }
    }
    lassign $repr sign width endian
    binary scan $bytes @$at[Letter $width $sign $endian] n
    return [core::value::intFromNumber $n]
}

# 1 if DESCRIPTOR holds a raw C floating field or element ({r ...} words),
# directly, in a nested layout, an array or a union alternative.
proc core::binary::HoldsRaw {descriptor} {
    foreach field [lindex $descriptor 3] {
        if {[ReprHoldsRaw [lrange $field 2 end]]} {
            return 1
        }
    }
    return 0
}

proc core::binary::ReprHoldsRaw {repr} {
    switch -- [lindex $repr 0] {
        r { return 1 }
        layout - union { return [HoldsRaw [lindex $repr 1]] }
        array { return [ReprHoldsRaw [lindex $repr 3]] }
    }
    return 0
}

# The raw C floating value the representation words REPR ({r WIDTH ENDIAN})
# hold at byte AT of BYTES: exactly its bits.
proc core::binary::RawDecode {repr bytes at} {
    lassign $repr - width endian
    binary scan $bytes @$at[Letter $width u $endian] n
    return [core::cabi::rawValue [core::cabi::formatOfWidth $width] $n]
}

# The bytes of the raw C floating VALUE written by OPERATION into the
# representation REPR ({r WIDTH ENDIAN}; WHAT names the place): exactly its
# bits, never narrowed, normalized or refused (a value of the other format
# is a TYPE error a checked program never reaches).
proc core::binary::RawPiece {operation repr value what} {
    lassign $repr - width endian
    set kind [core::cabi::RawKindOf [core::cabi::formatOfWidth $width]]
    if {[core::value::kind $value] ne $kind} {
        core::semanticError TYPE "$operation: $what is a [core::cabi::rawName $kind], not [core::value::show $value]"
    }
    return [ScalarPiece [core::cabi::rawBitsOf $value] u $width $endian]
}

# BYTES with VALUE (a LayoutStruct of DESCRIPTOR) written at byte BASE.
proc core::binary::Encode {descriptor value bytes base} {
    lassign $descriptor structId size align fields
    if {[core::value::kind $value] ne "struct" || [core::value::structId $value] ne $structId} {
        core::semanticError TYPE "std::binary::emit: expected a $structId, got [core::value::show $value]"
    }
    foreach field $fields {
        set name [lindex $field 0]
        set bytes [EncodeRepr std::binary::emit [lrange $field 2 end] [core::value::structGet $value $name] \
            $bytes [expr {$base + [lindex $field 1]}] "field \"$name\" of $structId"]
    }
    return $bytes
}

# BYTES with VALUE written at byte AT in the representation words REPR (a
# descriptor field entry after its name and offset), by OPERATION; WHAT
# names the place in a failure. A fixed array's value must be a List of
# exactly its extent (FIXED-LAYOUT-ARRAYS.md), every nested List too: the
# declared LayoutExtentMismatch otherwise. Only the representation's own
# bytes change (a nested layout's padding is emission's zeros only because
# emission starts from zeros).
proc core::binary::EncodeRepr {operation repr value bytes at what} {
    switch -- [lindex $repr 0] {
        layout {
            return [Encode [lindex $repr 1] $value $bytes $at]
        }
        ptr {
            core::semanticError TYPE "$operation: $what is a C pointer, which is never written into bytes"
        }
        union {
            # Statically LAYOUT-UNION (LAYOUT-UNIONS.md).
            core::semanticError LAYOUT-UNION "$operation: $what is the union layout [LayoutName [lindex $repr 1 0]], which has no copied value to write (one of its alternatives is written at a time)"
        }
        array {
            lassign $repr - extent stride element
            set items [ArrayItems $operation $value $extent $what]
            set i 0
            foreach item $items {
                set bytes [EncodeRepr $operation $element $item $bytes [expr {$at + $i * $stride}] "element $i of $what"]
                incr i
            }
            return $bytes
        }
        f {
            return [string replace $bytes $at [expr {$at + [lindex $repr 1] - 1}] [FloatPiece $operation $repr $value $what]]
        }
        r {
            return [string replace $bytes $at [expr {$at + [lindex $repr 1] - 1}] [RawPiece $operation $repr $value $what]]
        }
    }
    lassign $repr sign width endian
    set n [core::value::intOf $value]
    set piece [ScalarPiece $n $sign $width $endian]
    if {$piece eq ""} {
        lassign [EncodingRange $sign $width] lo hi
        core::semanticError RANGE "$operation: $what holds $n, outside its $width-byte encoding $lo..$hi"
    }
    return [string replace $bytes $at [expr {$at + $width - 1}] $piece]
}

# The bytes of the Float64 VALUE written by OPERATION into the C floating
# representation REPR ({f WIDTH ENDIAN}; WHAT names the place): narrowed by
# the boundary's rule (core::cabi::Narrow), NonFiniteFloat when a binary32
# cannot hold it.
proc core::binary::FloatPiece {operation repr value what} {
    lassign $repr - width endian
    core::value::expect Float64 $value $operation
    set format [core::cabi::formatOfWidth $width]
    set encoded [core::cabi::EncodeFloating $format [core::value::floatOf $value]]
    if {[lindex $encoded 0] ne "ok"} {
        core::native::failDeclared NonFiniteFloat \
            "$operation: $what is a C $format, which cannot hold [core::float::text $value] (it rounds to an infinity)" \
            [core::float::Payload [lindex $encoded 2]]
    }
    return [lindex $encoded 1]
}

# The elements of VALUE, a List written by OPERATION into a fixed array of
# EXTENT elements (WHAT names it), once it has exactly EXTENT of them: the
# declared builtin error LayoutExtentMismatch otherwise (FIXED-LAYOUT-
# ARRAYS.md: a List's length is not its type's, so a whole-array write
# checks it).
proc core::binary::ArrayItems {operation value extent what} {
    core::value::expect list $value $operation
    set items [core::value::items $value]
    if {[llength $items] != $extent} {
        core::native::failDeclared LayoutExtentMismatch \
            "$operation: $what is a fixed array of $extent elements, but the List written has [llength $items]"
    }
    return $items
}

# {LO HI}, the values of the WIDTH-byte encoding SIGN u|i.
proc core::binary::EncodingRange {sign width} {
    set bits [expr {8 * $width}]
    if {$sign eq "u"} {
        return [list 0 [expr {2 ** $bits - 1}]]
    }
    return [list [expr {-(2 ** ($bits - 1))}] [expr {2 ** ($bits - 1) - 1}]]
}

# The WIDTH bytes (a Tcl byte string) encoding the Int N as SIGN u|i,
# ENDIAN; "" when N lies outside the encoding (a value no checked program
# builds: a field's type is its encoding's exact range). Emission and the
# layout writes (NATIVE-LAYOUT-WRITES.md) share it.
proc core::binary::ScalarPiece {n sign width endian} {
    lassign [EncodingRange $sign $width] lo hi
    if {$n < $lo || $n > $hi} {
        return ""
    }
    return [binary format [Letter $width $sign $endian 0] $n]
}

# 1 if DESCRIPTOR has a fixed array field, directly or in a nested layout
# (FIXED-LAYOUT-ARRAYS.md).
proc core::binary::HasArrays {descriptor} {
    foreach field [lindex $descriptor 3] {
        switch -- [lindex $field 2] {
            array {
                return 1
            }
            layout - union {
                if {[HasArrays [lindex $field 3]]} {
                    return 1
                }
            }
        }
    }
    return 0
}

# The List value of the numbers NUMBERS (a counted `binary scan`'s result,
# every element of a fixed array of scalars row after row) in the shape of
# the extents DIMS: a List of Ints for one dimension, a List of such Lists
# for two, and so on (the Tcl compiler's parse, compiler/compiler.tcl).
proc core::binary::Rows {numbers dims} {
    if {[llength $dims] == 1} {
        return [list list [lmap n $numbers {list int $n}]]
    }
    set inner [lrange $dims 1 end]
    set size 1
    foreach d $inner {
        set size [expr {$size * $d}]
    }
    set rows {}
    for {set i 0} {$i < [lindex $dims 0]} {incr i} {
        lappend rows [Rows [lrange $numbers [expr {$i * $size}] [expr {($i + 1) * $size - 1}]] $inner]
    }
    return [list list $rows]
}

# The path of the first pointer field of DESCRIPTOR ("link.next"), or "":
# such a layout is native-only (NATIVE-LAYOUT-VIEWS.md), statically
# LAYOUT-NATIVE-ONLY for parse and emit -- refused here too, for a program
# compiled unchecked (-strict 0) or core IR written by hand.
proc core::binary::PointerPath {descriptor} {
    foreach field [lindex $descriptor 3] {
        set inner [ReprPointerPath [lrange $field 2 end]]
        if {$inner ne "none"} {
            return [lindex $field 0]$inner
        }
    }
    return ""
}

# The path of a pointer within the representation words REPR ("" for REPR
# itself, "[]" for an array element, "[].next" ...), or "none".
proc core::binary::ReprPointerPath {repr} {
    switch -- [lindex $repr 0] {
        ptr {
            return ""
        }
        layout - union {
            set inner [PointerPath [lindex $repr 1]]
            if {$inner eq ""} {
                return none
            }
            return ".$inner"
        }
        array {
            set inner [ReprPointerPath [lindex $repr 3]]
            if {$inner eq "none"} {
                return none
            }
            return "\[\]$inner"
        }
    }
    return none
}

proc core::binary::RefuseNativeOnly {operation descriptor} {
    set path [UnionPath $descriptor]
    if {$path ne "none"} {
        # Statically LAYOUT-UNION (LAYOUT-UNIONS.md).
        set where [if {$path eq ""} {string cat ""} else {string cat " ($path)"}]
        core::semanticError LAYOUT-UNION \
            "$operation: [LayoutName [lindex $descriptor 0]] holds a union$where, which has no copied value"
    }
    set path [PointerPath $descriptor]
    if {$path ne ""} {
        core::semanticError LAYOUT-NATIVE-ONLY \
            "$operation: field \"$path\" of [lindex $descriptor 0] is a C pointer, which bytes never become and are never written from (a layout with a pointer field is read through a native view only)"
    }
}

# The path of the first union DESCRIPTOR holds by value ("" when it is a
# union's own descriptor, "u", "inner.u", "us[]" ...), or "none"
# (LAYOUT-UNIONS.md).
proc core::binary::UnionPath {descriptor} {
    if {[string match {LayoutUnion\[*\]} [lindex $descriptor 0]]} {
        return ""
    }
    foreach field [lindex $descriptor 3] {
        set inner [ReprUnionPath [lrange $field 2 end]]
        if {$inner ne "none"} {
            return [lindex $field 0]$inner
        }
    }
    return none
}

# The path of a union within the representation words REPR, or "none".
proc core::binary::ReprUnionPath {repr} {
    switch -- [lindex $repr 0] {
        union {
            return ""
        }
        layout {
            set inner [UnionPath [lindex $repr 1]]
            if {$inner eq "none"} {
                return none
            }
            return ".$inner"
        }
        array {
            set inner [ReprUnionPath [lindex $repr 3]]
            if {$inner eq "none"} {
                return none
            }
            return "\[\]$inner"
        }
    }
    return none
}

proc core::binary::parse {descriptor data} {
    set descriptor [core::value::strOf $descriptor]
    RefuseNativeOnly std::binary::parse $descriptor
    set bytes [BytesOf $data std::binary::parse]
    set size [lindex $descriptor 1]
    if {[string length $bytes] != $size} {
        core::native::failDeclared LayoutLengthMismatch \
            "std::binary::parse: [string length $bytes] bytes given, but the layout [LayoutName [lindex $descriptor 0]] has size $size"
    }
    return [Decode $descriptor $bytes 0]
}

# std::binary::read(data, L.path) (LAYOUT-UNIONS.md): the one representation the
# designator constant PATH names -- {STRUCTID SIZE PATH FIELD}, FIELD its
# descriptor entry at its absolute offset -- imprinted from DATA, exactly
# L's size. Never a pointer (LAYOUT-NATIVE-ONLY) or a union (LAYOUT-UNION):
# both statically refused, and here too.
proc core::binary::read {data path} {
    set path [core::value::strOf $path]
    lassign $path structId size text field
    set repr [lrange $field 2 end]
    set union [ReprUnionPath $repr]
    if {$union ne "none"} {
        core::semanticError LAYOUT-UNION \
            "std::binary::read: [PathText $path] holds a union, which has no copied value (one of its alternatives is read at a time)"
    }
    if {[ReprPointerPath $repr] ne "none"} {
        core::semanticError LAYOUT-NATIVE-ONLY \
            "std::binary::read: [PathText $path] holds a C pointer, which bytes never become"
    }
    set bytes [BytesOf $data std::binary::read]
    if {[string length $bytes] != $size} {
        core::native::failDeclared LayoutLengthMismatch \
            "std::binary::read: [string length $bytes] bytes given, but the layout [LayoutName $structId] has size $size"
    }
    return [DecodeRepr $repr $bytes [lindex $field 1] [lindex $field 0] $structId]
}

proc core::binary::emit {value descriptor} {
    set descriptor [core::value::strOf $descriptor]
    RefuseNativeOnly std::binary::emit $descriptor
    set size [lindex $descriptor 1]
    return [BytesValue [Encode $descriptor $value [binary format x$size] 0]]
}

# std::binary::emit before elaboration and the layout queries before resolution
# never run: hir/resolve.tcl replaces a query by its constant, and
# hir::layouts::Elaborate turns every emit whose value has a layout into
# binary#emit. A core IR program that calls one directly has no static
# layout to give it.
proc core::binary::Unelaborated {name args} {
    core::semanticError TYPE "$name: the layout is static (named at the call, or the static type of the emitted value), and this call has none"
}

# ---------------------------------------------------------------------------
# Read-only native views (NATIVE-LAYOUT-VIEWS.md)
#
#   std::binary::native::view(L, p)      NativeView[L]: the live native memory the
#                                   data pointer P (a std::ffi::c::Ptr[T])
#                                   addresses, read through layout L
#                                   (NativeViewNull for a null P). P is
#                                   observed; the view is P's address word.
#   v.field                         one field read at its offset: a scalar's
#                                   Int, a nested layout's NativeView[Inner]
#                                   (its address plus the offset, nothing
#                                   read), a pointer field's std::ffi::c::Ptr /
#                                   FnPtr (hir::layouts::Elaborate rewrites
#                                   the projection to the internal
#                                   binary#view_field(v, FIELD), FIELD the
#                                   field's descriptor entry)
#   std::binary::load(v)                 LayoutStruct[L]: every field read once,
#                                   L from the view's static type (elaborated
#                                   to binary#load(v, DESCRIPTOR))
#
# std::binary::native is an intrinsic namespace designated direct
# (DIRECT-MODULES.md): reading live process memory is raw authority, so a
# call of view is a direct edge of its module. Reading a view (a projection,
# std::binary::load) is not: the view is the authority, already granted.
#
# The Tcl backends have no native memory: a null pointer is NativeViewNull
# on every backend, and any other view is refused (NATIVE-ONLY) -- nothing
# imitates a memory read. The native backend lowers each operation to
# straight-line loads (native/lower.tcl's LayoutCall; runtime/nview.rs).

proc core::binary::NativeOnly {operation {access reads}} {
    core::semanticError NATIVE-ONLY \
        "$operation $access live native process memory, which only the native backends (cranelift, cranelift-generic, a native executable) have; the Tcl backends (interp, compile) have no native address space and do not imitate one"
}

proc core::binary::nativeView {descriptor p} {
    set descriptor [core::value::strOf $descriptor]
    if {[core::cabi::addressOf $p] == 0} {
        core::native::failDeclared NativeViewNull \
            "std::binary::native::view: the pointer is null, so there is no [LayoutName [lindex $descriptor 0]] to read"
    }
    NativeOnly std::binary::native::view
}

proc core::binary::viewField {view field} {
    NativeOnly "a native view's field read"
}

proc core::binary::load {view descriptor} {
    NativeOnly std::binary::load
}

# ---------------------------------------------------------------------------
# Layout writes (NATIVE-LAYOUT-WRITES.md)
#
#   std::binary::native::edit(L, p)  NativeEdit[L]: the live native memory the
#                                    data pointer P addresses, read and WRITTEN
#                                    through layout L (NativeEditNull for a
#                                    null P). P is observed; the edit is P's
#                                    address word. Direct authority, like a
#                                    view; reading an edit is a view's read
#   std::binary::store(e, L.f, v)    writes V into field f of the memory the
#                                    NativeEdit[L] E addresses: one store of
#                                    the field's width at its offset, nothing
#                                    else touched. A pointer field takes a
#                                    pointer the program already has (V
#                                    observed: its address bits are copied)
#   std::binary::write(d, L.f, v)    the std::abi::bytes::MutableBytes D with
#                                    field f of layout L written to V: a new
#                                    value (D is unchanged), every other byte
#                                    D's. D must have exactly L's size
#                                    (LayoutLengthMismatch). Never a pointer
#                                    field (LAYOUT-NATIVE-ONLY)
#   std::binary::write_foreign(d, L.f, p)  the same for a C pointer field f: the
#                                   address bits of the pointer P (an
#                                   existing std::ffi::c::Ptr or FnPtr, observed)
#                                   encoded into it -- the explicit foreign
#                                   encoding, which bytes never decode back
#                                   (std::binary::parse stays LAYOUT-NATIVE-ONLY)
#
# L.f is a static field designator, resolved to the constant {STRUCTID SIZE
# PATH FIELD} (hir/layouts.tcl's "Field designators"), FIELD the leaf's
# descriptor entry at its absolute offset: the whole of what these
# implementations know.
#
# The Tcl backends have no native memory: an edit of the null pointer is
# NativeEditNull, any other edit is refused (NATIVE-ONLY), and so is a
# store. Byte storage is theirs, so std::binary::write and std::binary::write_foreign
# run on every backend; a C pointer's address bits are its value there too.

# The bytes (a Tcl byte string) of the std::abi::bytes::MutableBytes DATA.
proc core::binary::MutableBytesOf {data context} {
    core::value::expect struct $data $context
    set mutableType [core::bytestore::mutableBytesType]
    if {[core::value::structId $data] ne $mutableType} {
        core::semanticError TYPE "$context: expected $mutableType, got [core::value::show $data]"
    }
    return [binary decode hex [core::value::mutbytesHex [core::value::structGet $data [core::bytestore::storageField]]]]
}

# The std::abi::bytes::MutableBytes holding the byte string BYTES.
proc core::binary::MutableBytesValue {bytes} {
    return [core::value::structOf [list [core::bytestore::mutableBytesType] [core::bytestore::storageField]] \
        [list [core::value::mutbytes [binary encode hex $bytes]]]]
}

# The bytes of the MutableBytes DATA given to OPERATION, once they are
# exactly the size of the designator PATH's layout (LayoutLengthMismatch).
proc core::binary::RecordBytes {operation data path} {
    lassign $path structId size
    set bytes [MutableBytesOf $data $operation]
    set length [string length $bytes]
    if {$length != $size} {
        core::native::failDeclared LayoutLengthMismatch \
            "$operation: $length bytes given, but the layout [LayoutName $structId] has size $size"
    }
    return $bytes
}

# The designator PATH as written ("RECORD.origin.x").
proc core::binary::PathText {path} {
    return "[LayoutName [lindex $path 0]].[lindex $path 2]"
}

proc core::binary::write {data path value} {
    set path [core::value::strOf $path]
    lassign [lindex $path 3] name offset sign width endian
    if {$sign eq "ptr" || [ReprPointerPath [lrange [lindex $path 3] 2 end]] ne "none"} {
        # Statically LAYOUT-NATIVE-ONLY (hir/layouts.tcl).
        core::semanticError LAYOUT-NATIVE-ONLY \
            "std::binary::write: field [PathText $path] holds a C pointer, which an ordinary byte write never encodes (std::binary::write_foreign encodes a pointer the program already has)"
    }
    if {$sign eq "array"} {
        # A whole fixed array (FIXED-LAYOUT-ARRAYS.md): one new value, every
        # element encoded into the array's bytes and nothing else; the
        # List's extent checked first (LayoutExtentMismatch, D unchanged).
        set bytes [RecordBytes std::binary::write $data $path]
        ArrayItems std::binary::write $value [lindex [lindex $path 3] 3] "field [PathText $path]"
        return [MutableBytesValue [EncodeRepr std::binary::write [lrange [lindex $path 3] 2 end] $value $bytes \
            $offset "field [PathText $path]"]]
    }
    set bytes [RecordBytes std::binary::write $data $path]
    if {$sign eq "f"} {
        # A C floating field: narrowed (C-FLOAT-FFI-MILESTONE-1.md).
        set piece [FloatPiece std::binary::write [lrange [lindex $path 3] 2 end] $value "field [PathText $path]"]
        return [MutableBytesValue [string replace $bytes $offset [expr {$offset + $width - 1}] $piece]]
    }
    if {$sign eq "r"} {
        # A raw C floating field: its bits (RAW-C-FLOAT-FFI-MILESTONE-1.md).
        set piece [RawPiece std::binary::write [lrange [lindex $path 3] 2 end] $value "field [PathText $path]"]
        return [MutableBytesValue [string replace $bytes $offset [expr {$offset + $width - 1}] $piece]]
    }
    set n [core::value::intOf $value]
    set piece [ScalarPiece $n $sign $width $endian]
    if {$piece eq ""} {
        lassign [EncodingRange $sign $width] lo hi
        core::semanticError RANGE "std::binary::write: field [PathText $path] cannot hold $n, outside its $width-byte encoding $lo..$hi"
    }
    return [MutableBytesValue [string replace $bytes $offset [expr {$offset + $width - 1}] $piece]]
}

proc core::binary::writeForeign {data path pointer} {
    set path [core::value::strOf $path]
    lassign [lindex $path 3] name offset kind width endian
    if {$kind eq "array"} {
        # An array of C pointers (FIXED-LAYOUT-ARRAYS.md): every element
        # an existing pointer of the field's type, observed; the List's
        # extent checked first.
        set repr [lrange [lindex $path 3] 2 end]
        set leaf $repr
        while {[lindex $leaf 0] eq "array"} {
            set leaf [lindex $leaf 3]
        }
        if {[lindex $leaf 0] ne "ptr"} {
            core::semanticError LAYOUT-FOREIGN-WRITE \
                "std::binary::write_foreign: field [PathText $path] is no array of C pointers (an ordinary field is written by std::binary::write)"
        }
        set bytes [RecordBytes std::binary::write_foreign $data $path]
        ArrayItems std::binary::write_foreign $pointer [lindex $repr 1] "field [PathText $path]"
        return [MutableBytesValue [EncodeForeign $repr $pointer $bytes $offset "field [PathText $path]"]]
    }
    if {$kind ne "ptr"} {
        # Statically LAYOUT-FOREIGN-WRITE (hir/layouts.tcl).
        core::semanticError LAYOUT-FOREIGN-WRITE \
            "std::binary::write_foreign: field [PathText $path] is no C pointer field (an ordinary field is written by std::binary::write)"
    }
    # The pointer's own address bits, never an Int made into one: a C
    # address value, or the type error a checked program never reaches.
    set address [core::cabi::addressOf $pointer]
    set bytes [RecordBytes std::binary::write_foreign $data $path]
    set bits [expr {$address & ((1 << (8 * $width)) - 1)}]
    set piece [binary format [Letter $width u $endian 0] $bits]
    return [MutableBytesValue [string replace $bytes $offset [expr {$offset + $width - 1}] $piece]]
}

# BYTES with the pointers VALUE (one, or a fixed array's List of them,
# nested) encoded at byte AT by the pointer representation words REPR
# ({ptr WIDTH ENDIAN}, or arrays of it): each pointer's own address bits,
# observed (std::binary::write_foreign).
proc core::binary::EncodeForeign {repr value bytes at what} {
    if {[lindex $repr 0] eq "array"} {
        lassign $repr - extent stride element
        set i 0
        foreach item [ArrayItems std::binary::write_foreign $value $extent $what] {
            set bytes [EncodeForeign $element $item $bytes [expr {$at + $i * $stride}] "element $i of $what"]
            incr i
        }
        return $bytes
    }
    lassign $repr kind width endian
    set address [core::cabi::addressOf $value]
    set bits [expr {$address & ((1 << (8 * $width)) - 1)}]
    return [string replace $bytes $at [expr {$at + $width - 1}] [binary format [Letter $width u $endian 0] $bits]]
}

proc core::binary::nativeEdit {descriptor p} {
    set descriptor [core::value::strOf $descriptor]
    set address [core::cabi::addressOf $p]
    if {$address == 0} {
        core::native::failDeclared NativeEditNull \
            "std::binary::native::edit: the pointer is null, so there is no [LayoutName [lindex $descriptor 0]] to edit"
    }
    NativeOnly std::binary::native::edit "reads and writes"
}

proc core::binary::store {edit path value} {
    NativeOnly std::binary::store writes
}

# ---------------------------------------------------------------------------
# Live fixed arrays (FIXED-LAYOUT-ARRAYS.md)
#
#   std::binary::element(a, i)           element I of the live array A (a
#                                        NativeView[array N of E] or a
#                                        NativeEdit[array N of E], a field of a
#                                        view or an edit, or an element of
#                                        another): a scalar's Int, a pointer
#                                        (fresh, observed from memory), a
#                                        nested layout's or array's live view
#                                        or edit (its address, nothing read).
#                                        One access at A + I * STRIDE, the
#                                        whole array never read; IndexNotFound
#                                        unless 0 <= I < N
#   std::binary::store_element(a, i, v)  V written into scalar or pointer
#                                        element I of the live array A (a
#                                        NativeEdit[array N of E]): one store,
#                                        nothing else touched; IndexNotFound
#                                        unless 0 <= I < N
#   std::binary::load(a)                 the whole live array A copied into its
#                                        List (binary#load_array)
#
# elaborated (hir::layouts::Elaborate) to binary#element(a, i, ARRAY),
# binary#store_element(a, i, v, ARRAY), binary#load_array(a, ARRAY), ARRAY
# the array's descriptor words {array N STRIDE ELEMENT}. A live array exists
# only in native memory: the Tcl backends never have one (a view or an edit
# is refused before it could be made), and refuse these too.

proc core::binary::element {array index args} {
    NativeOnly std::binary::element
}

proc core::binary::storeElement {array index value args} {
    NativeOnly std::binary::store_element writes
}

proc core::binary::loadArray {array descriptor} {
    NativeOnly std::binary::load
}

core::native::declareError LayoutLengthMismatch
core::native::declareError NativeViewNull
core::native::declareError NativeEditNull
core::native::declareError LayoutExtentMismatch

# A layout operation reading a C floating field (a NaN or an infinity is no
# Float64) or writing a binary32 one (a Float64 may overflow it) may fail
# with the builtin NonFiniteFloat (C-FLOAT-FFI-MILESTONE-1.md): each one
# that can lists it, and hir::layouts::CallErrors charges a call with it
# only when the representation it reads or writes holds such a field.

core::native::register std::binary::parse -arity 2 -impl core::binary::parse \
    -param-types {str struct} -result-type struct -result-shape {layout-struct 0} \
    -errors {LayoutLengthMismatch NonFiniteFloat} -layout {operand 0 input 1 op parse} -nomethod 1
core::native::register std::binary::emit -arity 1 -impl {core::binary::Unelaborated std::binary::emit} \
    -param-types {struct} -result-type struct -result-shape [list named-struct [core::bytestore::bytesType]] \
    -ownership {observe} -errors {LayoutExtentMismatch NonFiniteFloat} -bounds {extents 0} -layout {typed {0 binary#emit}}
core::native::register binary#emit -arity 2 -impl core::binary::emit \
    -param-types {struct str} -result-type struct -result-shape [list named-struct [core::bytestore::bytesType]] \
    -runtime {bytestore-alloc} -ownership {observe observe} -errors {LayoutExtentMismatch NonFiniteFloat} -bounds {extents 0} \
    -layout {operand 1 op emit} -nomethod 1
# std::binary::read(data, L.path) (LAYOUT-UNIONS.md): one designated
# representation imprinted from bytes -- how a union's alternative is read
# from byte storage, a union having no copied value of its own. Its result
# is the representation's copied type (a scalar's domain, LayoutStruct[R],
# a List); `-result-length {path 1}` states an array's extent.
core::native::register std::binary::read -arity 2 -impl core::binary::read \
    -param-types {struct str} -result-type any -result-shape {layout-read 1} -ownership {observe observe} \
    -errors {LayoutLengthMismatch NonFiniteFloat} -result-length {path 1} -layout {input 0 path 1 op read} -nomethod 1
core::native::register std::binary::layout_length -arity 1 -impl {core::binary::Unelaborated std::binary::layout_length} \
    -param-types {any} -result-type int -layout {operand 0 query length} -nomethod 1
core::native::register std::binary::layout_alignment -arity 1 -impl {core::binary::Unelaborated std::binary::layout_alignment} \
    -param-types {any} -result-type int -layout {operand 0 query alignment} -nomethod 1
core::native::register std::binary::native::view -arity 2 -impl core::binary::nativeView \
    -param-types {str any} -result-type any -result-shape {native-view 0} -ownership {observe observe} \
    -errors {NativeViewNull} -layout {operand 0 pointer 1 op view} -nomethod 1
core::native::register std::binary::load -arity 1 -impl {core::binary::Unelaborated std::binary::load} \
    -param-types {any} -result-type any -result-shape {view-struct 0} -ownership {observe} \
    -errors {NonFiniteFloat} -result-length {extent 0} -layout {viewed {0 binary#load} arrayed {0 binary#load_array}}
core::native::register binary#load -arity 2 -impl core::binary::load \
    -param-types {any str} -result-type struct -result-shape {layout-struct 1} -ownership {observe observe} \
    -errors {NonFiniteFloat} -layout {operand 1 op load} -nomethod 1
core::native::register binary#view_field -arity 2 -impl core::binary::viewField \
    -param-types {any str} -result-type any -result-shape {view-field 0 1} -ownership {observe observe} \
    -errors {NonFiniteFloat} -layout {field 1 op field} -nomethod 1
core::native::register std::binary::native::edit -arity 2 -impl core::binary::nativeEdit \
    -param-types {str any} -result-type any -result-shape {native-edit 0} -ownership {observe observe} \
    -errors {NativeEditNull} -layout {operand 0 pointer 1 op edit} -nomethod 1
core::native::register std::binary::store -arity 3 -impl core::binary::store \
    -param-types {any str any} -result-type unit -ownership {observe observe observe} \
    -errors {LayoutExtentMismatch NonFiniteFloat} -bounds {extents 2} -layout {edited 0 path 1 value 2 op store} -nomethod 1
core::native::register std::binary::write -arity 3 -impl core::binary::write \
    -param-types {struct str any} -result-type struct -result-shape [list named-struct [core::bytestore::mutableBytesType]] \
    -runtime {bytestore-alloc} -ownership {observe observe observe} -errors {LayoutExtentMismatch LayoutLengthMismatch NonFiniteFloat} \
    -bounds {extents 2} -layout {output 0 path 1 value 2 op write} -nomethod 1
core::native::register std::binary::write_foreign -arity 3 -impl core::binary::writeForeign \
    -param-types {struct str any} -result-type struct -result-shape [list named-struct [core::bytestore::mutableBytesType]] \
    -runtime {bytestore-alloc} -ownership {observe observe observe} -errors {LayoutExtentMismatch LayoutLengthMismatch} \
    -bounds {extents 2} -layout {output 0 path 1 value 2 op write_foreign} -nomethod 1
# Live fixed arrays (FIXED-LAYOUT-ARRAYS.md): an element read or store at a
# dynamic index (IndexNotFound unless the index designates an element: the
# narray bounds family, whose N is the extent the array's static type
# states), and a whole array's copy.
core::native::register std::binary::element -arity 2 -impl {core::binary::Unelaborated std::binary::element} \
    -param-types {any int} -result-type any -result-shape {native-element 0} -ownership {observe observe} \
    -errors {IndexNotFound NonFiniteFloat} -bounds {index narray 0 1} -layout {arrayed {0 binary#element} index 1 op element} -nomethod 1
core::native::register binary#element -arity 3 -impl core::binary::element \
    -param-types {any int str} -result-type any -result-shape {native-element 0} -ownership {observe observe observe} \
    -errors {IndexNotFound NonFiniteFloat} -bounds {index narray 0 1} -layout {array 2 index 1 op element} -nomethod 1
core::native::register std::binary::store_element -arity 3 -impl {core::binary::Unelaborated std::binary::store_element} \
    -param-types {any int any} -result-type unit -ownership {observe observe observe} \
    -errors {IndexNotFound NonFiniteFloat} -bounds {index narray 0 1} \
    -layout {arrayed {0 binary#store_element} index 1 value 2 op store_element} -nomethod 1
core::native::register binary#store_element -arity 4 -impl core::binary::storeElement \
    -param-types {any int any str} -result-type unit -ownership {observe observe observe observe} \
    -errors {IndexNotFound NonFiniteFloat} -bounds {index narray 0 1} -layout {array 3 index 1 value 2 op store_element} -nomethod 1
core::native::register binary#load_array -arity 2 -impl core::binary::loadArray \
    -param-types {any str} -result-type any -result-shape {view-struct 0} -ownership {observe observe} \
    -errors {NonFiniteFloat} -result-length {extent 0} -layout {array 1 op load_array} -nomethod 1
# Reading live process memory is raw authority (DIRECT-MODULES.md): every
# call of std::binary::native::view is a direct edge of the module making it --
# and so is every call of std::binary::native::edit, write authority over it
# (NATIVE-LAYOUT-WRITES.md). Using an edit someone made (std::binary::store, its
# reads) is not: the edit is the authority, already granted.
core::native::declareDirectNamespace std::binary::native

# layouts.tcl -- fixed binary layouts and LayoutStruct[L] (BINARY-LAYOUT.md).
#
#   hir::layouts::apply DECLS        => HIR `sourceTypes` entries of the layouts
#   hir::layouts::lookup NAME NS     => declaration identity, or ""
#   hir::layouts::declared ID        => 1 if ID is a registered layout
#   hir::layouts::entry ID           => the resolved layout (below)
#   hir::layouts::structId ID        => "LayoutStruct[ID]", the identity of
#                                       the struct view of layout ID
#   hir::layouts::structType ID      => {nstruct LayoutStruct[ID]}
#   hir::layouts::descriptor ID      => the static descriptor (below)
#
# Vocabulary
# ----------
#   layout          a compile-time schema of a fixed number of physical
#                   bytes, declared `layout Name:`. Not a struct, a type, a
#                   type alias, a function or a value: a declaration with
#                   nominal identity, named only in a type (LayoutStruct[L],
#                   a layout field) or as the layout operand of a binary
#                   operation (std::binary::parse(L, data), std::binary::layout_length(L))
#   LayoutStruct[L] the immutable structural value imprinting with layout L
#                   produces: one field per layout field, nothing else (no
#                   padding, no offsets)
#   imprinting      bytes + the static evidence L -> LayoutStruct[L]; its
#                   inverse, emission, LayoutStruct[L] -> bytes, reads L from
#                   the value's static type
#   descriptor      the self-contained static text of one resolved layout
#                   that the binary operations carry as a constant argument
#                   (so no backend reads this registry)
#
# A layout's identity is its declaration identity, exactly a named struct's
# or an enum's: the declared name for the entry program and
# "namespace::Name" for a module's. Two layouts with identical fields,
# offsets, size and alignment are distinct layouts, and LayoutStruct[A] and
# LayoutStruct[B] distinct types. Layouts share the one type namespace of
# structs, enums, traits and source types: a layout field names an integer
# domain or a nested layout by one spelling, which must never be ambiguous.
#
# The resolved layout (the registry entry; the one authoritative
# representation -- nothing else records an offset, a width or a size):
#
#   {id ID name NAME namespace NS size N align A span SPAN fields FIELDS}
#
# FIELDS in declared order, each
#
#   {name F offset O kind scalar width W signed 0|1 endian little type T}
#   {name F offset O kind float format FORMAT width W endian little
#        ctype C type T}
#   {name F offset O kind layout layout INNER width W type T}
#   {name F offset O kind pointer width W endian little type T}
#   {name F offset O kind array extent N stride S width W element E type T}
#   {name F offset O kind union layout U width W type any}
#
# where T is the field's consumer type -- the declared integer domain
# (`{refined int {std::binary::U16}}`), `{nstruct LayoutStruct[INNER]}`, or the
# declared C pointer type (`{cptr P}`, std::ffi::c::Ptr[P]; `{cfnptr F}`,
# std::ffi::c::FnPtr[F]) -- and W its byte width (a nested layout's width is its
# size, a pointer's the compilation's C target's pointer width). `endian` is
# the byte order: the target's, little-endian on every supported target; it
# is recorded per field so an explicit big-endian encoding is one more value
# here, never a new representation.
#
# Representations. Everything after a field's name and offset is its
# *representation*: a scalar, a pointer, a nested layout -- or a fixed array
# (FIXED-LAYOUT-ARRAYS.md), N consecutive elements of one representation E
# (itself any of the four: `array 2 of array 3 of std::binary::U32` is two rows
# of three), the element at offset i * S, S the stride: E's own width (a
# scalar's encoding, the target's pointer width, a nested layout's size --
# tail padding included -- or a nested array's whole width), never a C
# alignment rule. The array's width is N * S, and its consumer type is the
# copied value, List[T_E] (exactly N elements whenever the layout machinery
# makes it; the extent is the layout's, not the List type's). An array is
# repetition, not a new object model: no ordinary Botlish value gains an
# array representation, and an array of characters is not text.
#
# Unions (LAYOUT-UNIONS.md). Arrays repeat representation; unions overlap
# it. A union layout (`union layout U:`, an entry with `union 1`) is a named
# representation of SIZE bytes whose FIELDS are its *alternatives*: several
# declared interpretations of the same bytes, every one at offset 0 (the
# union's origin), each any representation (a scalar, a pointer, a nested
# layout, an array, another union) no wider than the union. It is not a
# tagged sum: there is no case, tag, discriminant or active alternative, and
# choosing one is interpretation, never conversion. Overlap is what a union
# declares, and only a union: an ordinary layout's fields still never share a
# byte (LAYOUT-FIELD-OVERLAP). A field (or an array element, or another
# union's alternative) of a union holds it by value: the representation
# {kind union layout U width SIZE}, read through a native view or edit as
# the live union NativeView[U] / NativeEdit[U] (one window, every
# alternative read at its address), its alternatives named by designators
# (`L.u.whole`). A union has no copied value: its alternatives are not
# independent fields, so there is no LayoutStruct of a union nor of anything
# holding one by value -- std::binary::parse, std::binary::emit, std::binary::load and
# whole-array writes of such a representation are LAYOUT-UNION, and its
# consumer type here is `any`, which no checked program ever holds. Bytes
# are interpreted one alternative at a time through a static designator
# (std::binary::read, std::binary::write), native memory through a view or an edit.
#
# Pointer fields (NATIVE-LAYOUT-VIEWS.md). A field may hold a C data or
# function pointer: its width and placement are representation facts like a
# scalar's, but its meaning is authority -- an address some foreign code
# handed out. So a layout with a pointer field (directly or in a nested
# layout) is *native-only*: it is read through a native view of live native
# memory (NativeView[L], std::binary::load), where the pointer is the one that
# memory holds, and never imprinted from bytes (std::binary::parse would make a
# pointer out of arbitrary bytes) or emitted into them (writing pointers is a
# later milestone's): both are LAYOUT-NATIVE-ONLY. A pointer field's
# pointee may name an opaque struct, which is registered after the layouts:
# the width (the target's) is known at once, so the declaration checks run
# as for any field, and the pointer type itself is resolved after the
# structs (ResolvePointers).
#
# Native views (NATIVE-LAYOUT-VIEWS.md). NativeView[L] is {nview L}: a
# window onto live native memory read through layout L, whose run-time value
# is the address word of the pointer it was made from. Its fields are L's,
# each read when projected: a scalar's integer domain, a nested layout's
# NativeView[INNER] (no load: the inner layout's address), a pointer's
# declared C pointer type (ViewFieldType). The same registry entry and the
# same descriptor serve both backings -- bytes (LayoutStruct[L]) and native
# memory (NativeView[L]); nothing here describes a layout twice.
#
# Scalar encodings. A scalar field's type is an integer domain whose value
# set is exactly the value set of one fixed-width two's-complement or
# unsigned encoding: 0..2^(8k)-1 (unsigned) or -2^(8k-1)..2^(8k-1)-1
# (signed), k in 1, 2, 4, 8. The encoding is the domain's: every one of the
# eight value sets is distinct, so the width and signedness follow from the
# declared type alone, with no table of names (`std::binary::U16`, `std::abi::U16Value`,
# `std::byte::Byte` -- 0..255, an unsigned byte -- all qualify). Because the
# domain is exactly the encoding's value set, every bit pattern decodes to a
# value of the field's type (parse cannot fail on a field) and every value of
# the type encodes (emit cannot truncate). `int` (no finite width), a domain
# of another interval, an exact-set domain and a refinement (whose values
# carry a proof imprinting cannot make) are not scalar field types.
#
# The struct view. LayoutStruct[L] is the named-struct type {nstruct
# LayoutStruct[L]}: every consumer -- projection, destructuring, equality,
# hashing, printing, the struct analyses, scalar replacement, every
# backend's struct representation -- sees an ordinary immutable named struct
# whose declaration identity is the string "LayoutStruct[L]" (which no
# source declaration can spell). Its schema is never registered as a struct:
# hir/structs.tcl's accessors answer for such an identity from this
# registry (StructNames, StructFieldTypes), so the field set is mechanically
# L's and is recorded once. There is no `LayoutStruct Foo:`, no `struct
# Foo[T]:` and no generic struct declaration of any kind.
#
# C floating fields (C-FLOAT-FFI-MILESTONE-1.md). A field of type
# std::ffi::c::Float or std::ffi::c::Double holds C's float or double: its
# representation is the C type's on the compilation's target (core/cabi.tcl's
# floatingInfo: binary32 in 4 bytes, binary64 in 8 -- C is the C type,
# {cfloat NAME}, and the width is never its carrier's), and its consumer
# type T its carrier, Float64. Unlike an integer encoding, not every bit
# pattern is a value: imprinting one (std::binary::parse, std::binary::read, a read
# through a view or an edit, std::binary::load) admits it -- NaN and the
# infinities are NonFiniteFloat, negative zero is zero -- and writing a
# Float64 into a binary32 field narrows it (round to nearest, ties to even;
# an overflow is NonFiniteFloat, never clamped). Those are the boundary's
# rules (core::cabi::Narrow and AdmitBits), written once. So the operations
# that read or write such a field may fail with NonFiniteFloat, and which do
# is decided per call by the representation they read or write
# (FloatErrors): a program whose layouts hold no float is charged nothing
# new. An array of floats strides the C type's width (4 for a float), never
# a Float64's.
#
# Compilation isolation: the registry is captured and installed with the
# other declaration registries (hir/declarations.tcl); it is reset with the
# source types (hir::sourcetypes::Reset) and filled by hir::sourcetypes::
# apply from the `kind layout` entries of -type-decls, after the integer
# domains a field may name and before the structs whose fields may name
# LayoutStruct[L].

namespace eval hir::layouts {
    # ID -> the resolved layout (the file header).
    variable registry [dict create]
    # The eight scalar encodings: {WIDTH SIGNED} -> {MIN MAX}.
    variable encodings [dict create \
        {1 0} {0 255} {2 0} {0 65535} {4 0} {0 4294967295} {8 0} {0 18446744073709551615} \
        {1 1} {-128 127} {2 1} {-32768 32767} {4 1} {-2147483648 2147483647} \
        {8 1} {-9223372036854775808 9223372036854775807}]
    # The largest alignment a layout may state (2^28): far beyond any target's
    # page size, small enough that no arithmetic on it is ever large.
    variable maxAlign 268435456
    # The largest size a layout may state: a fixed layout is a record, not a
    # buffer (2^31 - 1 bytes).
    variable maxSize 2147483647
}

proc hir::layouts::Reset {} {
    variable registry
    set registry [dict create]
}

proc hir::layouts::Fail {span message {kind TYPE}} {
    if {$span eq ""} {
        core::semanticError $kind $message
    }
    core::semanticError $kind "[dict get $span file]:[dict get $span line]:[dict get $span column]: $message"
}

# The declaration identity of a layout NAME declared in module NAMESPACE (""
# for the entry program).
proc hir::layouts::identity {name namespace} {
    if {$namespace eq ""} {
        return $name
    }
    return "${namespace}::${name}"
}

# 1 if ID is a registered layout declaration identity.
proc hir::layouts::declared {id} {
    variable registry
    return [dict exists $registry $id]
}

# The resolved layout ID (the file header's form).
proc hir::layouts::entry {id} {
    variable registry
    return [dict get $registry $id]
}

# The identity the layout spelling NAME (as written: "Pair", "geo::Pair")
# denotes in code of module namespace NS ("" for the entry program), or "":
# a qualified spelling is exactly that declaration, a bare one the code's own
# namespace's -- a named struct's visibility (no `import type`: a layout is
# not a type).
proc hir::layouts::lookup {name {ns ""}} {
    variable registry
    if {[dict size $registry] == 0} {
        return ""
    }
    if {[string first :: $name] >= 0} {
        if {[dict exists $registry $name]} {
            return $name
        }
        return ""
    }
    set id [identity $name $ns]
    if {[dict exists $registry $id]} {
        return $id
    }
    return ""
}

# The identity of the struct view of layout ID.
proc hir::layouts::structId {id} {
    return "LayoutStruct\[$id\]"
}

# 1 if the registered layout ID is a union layout (LAYOUT-UNIONS.md).
proc hir::layouts::IsUnion {id} {
    variable registry
    return [expr {[dict exists $registry $id] && [dict getdef [dict get $registry $id] union 0]}]
}

# The head of layout ID's descriptor: its struct view's identity, or, for a
# union, "LayoutUnion[ID]" -- a union has no struct view (LAYOUT-UNIONS.md).
proc hir::layouts::DescriptorHead {id} {
    if {[IsUnion $id]} {
        return "LayoutUnion\[$id\]"
    }
    return [structId $id]
}

# "layout" or "union layout": what declaration ID is, for a message.
proc hir::layouts::Noun {id} {
    return [expr {[IsUnion $id] ? "union layout" : "layout"}]
}

proc hir::layouts::structType {id} {
    return [list nstruct [structId $id]]
}

# The layout whose struct view has the declaration identity STRUCTID
# ("LayoutStruct[ID]"), or "" if STRUCTID is no registered layout's view.
proc hir::layouts::OfStructId {structId} {
    variable registry
    if {![string match {LayoutStruct\[*\]} $structId]} {
        return ""
    }
    set id [string range $structId 13 end-1]
    if {[dict exists $registry $id] && ![IsUnion $id]} {
        # (A union has no struct view: LAYOUT-UNIONS.md.)
        return $id
    }
    return ""
}

# The layout of TYPE when TYPE is a LayoutStruct type, else "".
proc hir::layouts::OfType {type} {
    if {![hir::types::IsNamedStruct $type]} {
        return ""
    }
    return [OfStructId [lindex $type 1]]
}

# The field names of layout ID, in declared order: the slot order of its
# struct view.
proc hir::layouts::StructNames {id} {
    return [lmap field [dict get [entry $id] fields] {dict get $field name}]
}

# {FIELD TYPE ...} of the struct view of layout ID, in declared order.
proc hir::layouts::StructFieldTypes {id} {
    set result {}
    foreach field [dict get [entry $id] fields] {
        lappend result [dict get $field name] [dict get $field type]
    }
    return $result
}

proc hir::layouts::size {id} {
    return [dict get [entry $id] size]
}

proc hir::layouts::align {id} {
    return [dict get [entry $id] align]
}

# The static descriptor of layout ID: a Tcl list
#
#   {STRUCTID SIZE ALIGN {FIELD ...}}
#
# STRUCTID the struct view's identity (the Tcl struct head is STRUCTID
# followed by the field names), each FIELD {NAME OFFSET u|i WIDTH ENDIAN} for
# a scalar, {NAME OFFSET f WIDTH ENDIAN} for a C floating field (the IEEE 754
# format of WIDTH bytes), {NAME OFFSET layout DESCRIPTOR} for a nested layout
# or {NAME OFFSET ptr WIDTH ENDIAN} for a pointer (read only through a native
# view),
# in declared order. It is the whole of what imprinting and emission need, so it is the
# constant argument the binary operations carry (core/binary.tcl reads it at
# run time on the interpreter; the Tcl compiler and native lowering read it
# statically). One layout has exactly one descriptor text.
#
# A union's descriptor (LAYOUT-UNIONS.md) has the same shape, headed
# LayoutUnion[ID]: {LayoutUnion[ID] SIZE ALIGN {ALTERNATIVE ...}}, every
# ALTERNATIVE a FIELD at offset 0. Nothing imprints or emits one (a union
# has no copied value); it is the words a union field's entry carries,
# {NAME OFFSET union DESCRIPTOR}, and the alternatives a live union's
# reads are elaborated with.
proc hir::layouts::descriptor {id} {
    set entry [entry $id]
    set fields {}
    foreach field [dict get $entry fields] {
        lappend fields [list [dict get $field name] [dict get $field offset] {*}[ReprDescriptor $field]]
    }
    return [list [DescriptorHead $id] [dict get $entry size] [dict get $entry align] $fields]
}

# The descriptor words of the representation REPR (a registry field, or an
# array's element): {u|i WIDTH ENDIAN} a scalar, {ptr WIDTH ENDIAN} a
# pointer, {layout DESCRIPTOR} a nested layout, {array N STRIDE ELEMENT} a
# fixed array of N elements STRIDE bytes apart, ELEMENT its element's words
# (FIXED-LAYOUT-ARRAYS.md), {union DESCRIPTOR} a union held by value
# (LAYOUT-UNIONS.md). A field's descriptor entry is its name and offset
# followed by these.
proc hir::layouts::ReprDescriptor {repr} {
    switch -- [dict get $repr kind] {
        float {
            # A C floating field: {f WIDTH ENDIAN}, the IEEE 754 format of
            # WIDTH bytes (core::cabi::formatOfWidth).
            return [list f [dict get $repr width] [dict get $repr endian]]
        }
        layout {
            return [list layout [descriptor [dict get $repr layout]]]
        }
        union {
            return [list union [descriptor [dict get $repr layout]]]
        }
        pointer {
            return [list ptr [dict get $repr width] [dict get $repr endian]]
        }
        array {
            return [list array [dict get $repr extent] [dict get $repr stride] \
                [ReprDescriptor [dict get $repr element]]]
        }
    }
    return [list [expr {[dict get $repr signed] ? "i" : "u"}] [dict get $repr width] [dict get $repr endian]]
}

# ---------------------------------------------------------------------------
# Fixed arrays (FIXED-LAYOUT-ARRAYS.md)
#
# An array field's representation is {kind array extent N stride S width W
# element E type T} (the file header), E itself a representation. Through a
# native view or edit an array field is not read: it is the live array, the
# type NativeView[array N of E] ({nview TERM}; NativeEdit's {nedit TERM}),
# TERM the representation as a type-level term:
#
#   T                   a scalar element: its integer domain type
#   {cfloat NAME}       a C floating element: its C type, never its carrier
#                       (an array of floats and one of doubles differ)
#   {cptr P}, {cfnptr F} a pointer element: its pointer type
#   {layout ID}         a nested layout element
#   {union ID}          a union element (LAYOUT-UNIONS.md)
#   {array N TERM}      a nested array element
#
# A term is structural -- two arrays of four POINTs are one type, whichever
# layout holds them -- and carries everything an element access needs: the
# element's type, its width (the stride) and its encoding, derived here from
# the registries (ReprOfTerm), never from a C rule.

# 1 if the surface type expression TYPEEXPR is a fixed array representation
# {array N ELEMENT} (surface::parser::ArrayTypeExpr).
proc hir::layouts::IsArrayTypeExpr {typeExpr} {
    return [expr {[llength $typeExpr] == 3 && [lindex $typeExpr 0] eq "array"}]
}

# The consumer (copied value) type of the array whose element has the
# consumer type ELEMENT: List[ELEMENT].
proc hir::layouts::ArrayConsumerType {element} {
    return [hir::types::MakeList $element {} 0 0]
}

# The type-level term of the representation REPR (above).
proc hir::layouts::ReprTerm {repr} {
    switch -- [dict get $repr kind] {
        float  { return [dict get $repr ctype] }
        layout { return [list layout [dict get $repr layout]] }
        union  { return [list union [dict get $repr layout]] }
        array  { return [list array [dict get $repr extent] [ReprTerm [dict get $repr element]]] }
    }
    return [dict get $repr type]
}

# The term of the registered layout ID held by value: {union ID} for a
# union, {layout ID} for any other (the one spelling of each: a term is a
# type's payload, so it must be canonical).
proc hir::layouts::NamedTerm {id} {
    return [list [expr {[IsUnion $id] ? "union" : "layout"}] $id]
}

# 1 if TERM names a registered layout or union by value ({layout ID},
# {union ID}).
proc hir::layouts::IsNamedTerm {term} {
    return [expr {[llength $term] == 2 && [lindex $term 0] in {layout union}}]
}

# The consumer type of a union held by value (LAYOUT-UNIONS.md): a union has
# no copied value, and every copy of a representation holding one is
# LAYOUT-UNION, so no checked program holds a value of this type.
proc hir::layouts::UnionConsumerType {} {
    return any
}

# 1 if TERM is an array term {array N TERM}.
proc hir::layouts::IsArrayTerm {term} {
    return [expr {[llength $term] == 3 && [lindex $term 0] eq "array"}]
}

# The representation (a dict as the registry's, without name and offset) the
# type-level term TERM denotes, from the registries of the active
# compilation; "" if TERM is no representation (an unknown layout, a type
# with no fixed-width encoding).
proc hir::layouts::ReprOfTerm {term} {
    if {[IsArrayTerm $term]} {
        lassign $term - extent inner
        set element [ReprOfTerm $inner]
        if {$element eq "" || ![string is entier -strict $extent] || $extent < 1} {
            return ""
        }
        set stride [dict get $element width]
        return [dict create kind array extent $extent stride $stride width [expr {$extent * $stride}] \
            element $element type [ArrayConsumerType [dict get $element type]]]
    }
    if {[IsNamedTerm $term]} {
        set id [lindex $term 1]
        if {![declared $id] || [NamedTerm $id] ne $term} {
            # (An unknown layout, or a union spelled as a record or back.)
            return ""
        }
        if {[IsUnion $id]} {
            return [dict create kind union layout $id width [size $id] type [UnionConsumerType]]
        }
        return [dict create kind layout layout $id width [size $id] type [structType $id]]
    }
    if {[hir::types::IsCPtr $term] || [hir::types::IsCFnPtr $term]} {
        set width [PointerWidth]
        if {$width eq ""} {
            return ""
        }
        return [dict create kind pointer width $width endian little type $term]
    }
    if {[hir::cabi::IsFloating $term]} {
        if {[hir::cabi::CompilationTarget] eq ""} {
            return ""
        }
        return [FloatingRepr $term]
    }
    set encoding [Encoding $term]
    if {$encoding eq ""} {
        return ""
    }
    lassign $encoding width signed
    return [dict create kind scalar width $width signed $signed endian little type $term]
}

# The array term of the native memory type TYPE when TYPE is a live array
# (NativeView[array N of E] or NativeEdit[array N of E]), else "".
proc hir::layouts::OfArrayType {type} {
    if {![hir::types::IsNativeMemory $type] || ![IsArrayTerm [lindex $type 1]]} {
        return ""
    }
    return [lindex $type 1]
}

# The native memory type (a view's, or an edit's when EDIT) of the
# representation term TERM read in place: a scalar's or pointer's own type
# for a leaf (read, not a window), NativeView[ID] / NativeEdit[ID] for a
# nested layout or a union (the live union, LAYOUT-UNIONS.md),
# NativeView[array ...] / NativeEdit[array ...] for an array.
proc hir::layouts::NativeTermType {term edit} {
    set head [expr {$edit ? "nedit" : "nview"}]
    if {[IsArrayTerm $term]} {
        return [list $head $term]
    }
    if {[IsNamedTerm $term]} {
        return [list $head [lindex $term 1]]
    }
    # (A C floating leaf reads as its carrier's value: a Float64.)
    return [hir::cabi::Carrier $term]
}

# The static type of one element of the live array type TYPE (a
# NativeView[array N of E] or NativeEdit[array N of E]), read through it:
# NativeTermType of E, write authority kept for an edit.
proc hir::layouts::ElementType {type} {
    set term [OfArrayType $type]
    if {$term eq ""} {
        return ""
    }
    return [NativeTermType [lindex $term 2] [hir::types::IsNativeEdit $type]]
}

# The consumer (copied) type of the representation term TERM: what
# std::binary::load makes of it (CopyType: a copied array's List states its
# extent).
proc hir::layouts::TermConsumerType {term} {
    set repr [ReprOfTerm $term]
    if {$repr eq ""} {
        return any
    }
    return [CopyType $repr]
}

# The type of a *copy* of the representation REPR -- what std::binary::load,
# std::binary::read or a field of what std::binary::parse made holds: its consumer
# type (the registry's `type`), with every fixed array's List refined by its
# extent, at every depth (LIST-CARDINALITY-REFINEMENTS.md): `array 2 of
# array 3 of E` copies to List[List[T]{length: 3}]{length: 2}. A copy has
# exactly the layout's extents -- the layout machinery made it so -- while a
# value written into an array (the consumer type a write's value and a
# LayoutStruct construction are held to) may have any length, which the
# write checks (LayoutExtentMismatch). A union has no copied value (`any`,
# UnionConsumerType), and neither has an array of one.
proc hir::layouts::CopyType {repr} {
    if {[dict get $repr kind] ne "array"} {
        return [dict get $repr type]
    }
    set element [CopyType [dict get $repr element]]
    if {$element eq [UnionConsumerType] && [dict get $repr element kind] eq "union"} {
        return [dict get $repr type]
    }
    return [hir::types::Refine [ArrayConsumerType $element] List [list length [dict get $repr extent]]]
}

# The copy type (CopyType) of field NAME of a copy of the layout ID, or ""
# when ID has no such field.
proc hir::layouts::CopiedFieldType {id name} {
    foreach field [dict get [entry $id] fields] {
        if {[dict get $field name] eq $name} {
            return [CopyType $field]
        }
    }
    return ""
}

# TERM as source text, the way hir::types::show prints a type: "array 16 of
# int[std::binary::U16]", "array 4 of POINT".
proc hir::layouts::ShowTerm {term} {
    if {[IsArrayTerm $term]} {
        return "array [lindex $term 1] of [ShowTerm [lindex $term 2]]"
    }
    if {[IsNamedTerm $term]} {
        return [lindex $term 1]
    }
    return [hir::types::show $term]
}

# What a NativeView[...] or NativeEdit[...] type shows between its brackets:
# a layout's identity, or a live array's representation (ShowTerm).
proc hir::layouts::ShowNative {payload} {
    if {[IsArrayTerm $payload]} {
        return [ShowTerm $payload]
    }
    return $payload
}

# The array descriptor (ReprDescriptor's {array N STRIDE ELEMENT}) of the
# array term TERM: the constant an element access or a whole-array load
# carries once elaborated.
proc hir::layouts::TermDescriptor {term} {
    set repr [ReprOfTerm $term]
    if {$repr eq ""} {
        error "internal compiler error: no representation for [ShowTerm $term]"
    }
    return [ReprDescriptor $repr]
}

# The representation REPR as HIR text's layout line spells a field type (the
# canonical identity of a scalar's domain, a nested layout's identity, a
# pointer's type, `array N of ...`): read back by hir::read::TypeDeclLine.
proc hir::layouts::ReprText {repr} {
    switch -- [dict get $repr kind] {
        float {
            return [hir::types::show [dict get $repr ctype]]
        }
        array {
            return "array [dict get $repr extent] of [ReprText [dict get $repr element]]"
        }
        layout - union {
            return [dict get $repr layout]
        }
    }
    return [FieldTypeText [dict get $repr type]]
}

# The path of a pointer within the representation REPR ("" for the
# representation itself, "[]" for an array's element, "[].next" for a field
# of a nested layout element, ".ptr" for a union's alternative), or "none"
# when REPR holds no pointer. Pointer authority is recursive: through every
# alternative of a union too (LAYOUT-UNIONS.md).
proc hir::layouts::ReprPointerPath {repr} {
    switch -- [dict get $repr kind] {
        pointer {
            return ""
        }
        layout - union {
            set inner [PointerField [dict get $repr layout]]
            if {$inner eq ""} {
                return none
            }
            return ".$inner"
        }
        array {
            set inner [ReprPointerPath [dict get $repr element]]
            if {$inner eq "none"} {
                return none
            }
            return "\[\]$inner"
        }
    }
    return none
}

# The layout identity a descriptor text DESCRIPTOR describes (the inner ID of
# its STRUCTID, or of a union's LayoutUnion[ID]), or "" if it is not a
# descriptor.
proc hir::layouts::DescriptorLayout {descriptor} {
    if {[catch {lindex $descriptor 0} structId]} {
        return ""
    }
    if {[string match {LayoutStruct\[*\]} $structId]} {
        return [string range $structId 13 end-1]
    }
    if {[string match {LayoutUnion\[*\]} $structId]} {
        return [string range $structId 12 end-1]
    }
    return ""
}

# ---------------------------------------------------------------------------
# Unions held by value (LAYOUT-UNIONS.md)
#
# A union has no copied value, so neither has any representation holding one
# by value: these find the union a copy would have to make, for LAYOUT-UNION.

# The path of a union within the representation REPR ("" for REPR itself,
# ".u" for a nested layout's field, "[]" for an array's element, ".alt.u"
# for a union within a union's alternative), or "none" when REPR holds no
# union by value. A pointer to one is no union held (a pointer field names a
# pointee identity, never a representation).
proc hir::layouts::ReprUnionPath {repr} {
    switch -- [dict get $repr kind] {
        union {
            return ""
        }
        layout {
            set inner [UnionField [dict get $repr layout]]
            if {$inner eq ""} {
                return none
            }
            return ".$inner"
        }
        array {
            set inner [ReprUnionPath [dict get $repr element]]
            if {$inner eq "none"} {
                return none
            }
            return "\[\]$inner"
        }
    }
    return none
}

# The path ("u", "inner.u", "us[]") of the first field of the record layout
# ID that holds a union by value, in declared order, or "".
proc hir::layouts::UnionField {id} {
    foreach field [dict get [entry $id] fields] {
        set inner [ReprUnionPath $field]
        if {$inner ne "none"} {
            return "[dict get $field name]$inner"
        }
    }
    return ""
}

# 1 if layout ID is a union or holds one by value: it has no copied value.
proc hir::layouts::HoldsUnion {id} {
    return [expr {[IsUnion $id] || [UnionField $id] ne ""}]
}

# Why the representation REPR has no copied value, for LAYOUT-UNION -- or
# "" when it has one. SUBJECT names REPR in the message ("layout OVL", "its
# elements"); ROOT, when given, is what REPR is reached by in a designator
# (a layout's identity for its NamedRepr, or a designator's text: "OVL",
# "ARRS.ws"), so the message can say where the union is and name a
# designator through it.
proc hir::layouts::UnionRefusal {repr subject {root ""}} {
    set path [ReprUnionPath $repr]
    if {$path eq "none"} {
        return ""
    }
    set union [ReprUnionAt $repr]
    set example [dict get [lindex [dict get [entry $union] fields] 0] name]
    set why "a union is several interpretations of the same bytes, never independent values, so it has no copied value"
    if {$path eq ""} {
        return "$union is a union layout: $why; a program reads or writes one alternative at a time ($union.$example, or through a native view or edit)"
    }
    if {$root ne ""} {
        set at " at $root$path"
        set hint "$root[string map {{[]} {[0]}} $path].$example"
    } else {
        set at ""
        set hint "$union.$example"
    }
    return "$subject holds the union layout $union by value$at: $why; a program reads or writes it a field or an alternative at a time (a designator such as $hint, or through a native view or edit)"
}

# The union REPR holds first (its ReprUnionPath's), or "".
proc hir::layouts::ReprUnionAt {repr} {
    switch -- [dict get $repr kind] {
        union { return [dict get $repr layout] }
        array { return [ReprUnionAt [dict get $repr element]] }
        layout {
            foreach field [dict get [entry [dict get $repr layout]] fields] {
                if {[ReprUnionPath $field] ne "none"} {
                    return [ReprUnionAt $field]
                }
            }
        }
    }
    return ""
}

# The descriptor entry of field NAME of layout ID (the FIELD of its
# descriptor), or "" when ID has no such field.
proc hir::layouts::FieldDescriptor {id name} {
    foreach field [lindex [descriptor $id] 3] {
        if {[lindex $field 0] eq $name} {
            return $field
        }
    }
    return ""
}

# 1 if layout ID holds a pointer field, directly or in a nested layout: it is
# native-only (the file header's "Pointer fields").
proc hir::layouts::NativeOnly {id} {
    return [expr {[PointerField $id] ne ""}]
}

# The path ("next", "inner.handle", "handles[]", "pts[].next") of the first
# pointer field of layout ID in declared order, nested layouts and array
# elements included, or "".
proc hir::layouts::PointerField {id} {
    foreach field [dict get [entry $id] fields] {
        set inner [ReprPointerPath $field]
        if {$inner ne "none"} {
            return "[dict get $field name]$inner"
        }
    }
    return ""
}

# The representation of the registered layout ID held by value: a nested
# layout's, or a union's (LAYOUT-UNIONS.md).
proc hir::layouts::NamedRepr {id} {
    return [ReprOfTerm [NamedTerm $id]]
}

# The native view type NativeView[ID].
proc hir::layouts::viewType {id} {
    return [list nview $id]
}

# The native edit type NativeEdit[ID] (NATIVE-LAYOUT-WRITES.md).
proc hir::layouts::editType {id} {
    return [list nedit $id]
}

# The layout of TYPE when TYPE is a NativeView type, else "".
proc hir::layouts::OfViewType {type} {
    if {![hir::types::IsNativeView $type]} {
        return ""
    }
    set id [lindex $type 1]
    if {[declared $id]} {
        return $id
    }
    return ""
}

# The layout of TYPE when TYPE is a NativeEdit type, else ""
# (NATIVE-LAYOUT-WRITES.md): the only type a store writes through.
proc hir::layouts::OfEditType {type} {
    if {![hir::types::IsNativeEdit $type]} {
        return ""
    }
    set id [lindex $type 1]
    if {[declared $id]} {
        return $id
    }
    return ""
}

# The layout of TYPE when TYPE reads native memory -- a NativeView[L] or a
# NativeEdit[L], whose reads are the same (NATIVE-LAYOUT-WRITES.md) -- else
# "".
proc hir::layouts::OfNativeType {type} {
    if {![hir::types::IsNativeMemory $type]} {
        return ""
    }
    set id [lindex $type 1]
    if {[declared $id]} {
        return $id
    }
    return ""
}

# The static type of field NAME read through a NativeView[ID] (the file
# header's "Native views"), or "" when ID has no such field. Read through a
# NativeEdit[ID] (EDIT 1), a nested layout is a NativeEdit[INNER]: the
# subrecord of memory the edit may write (NATIVE-LAYOUT-WRITES.md); every
# other field reads exactly as through a view.
proc hir::layouts::ViewFieldType {id name {edit 0}} {
    foreach field [dict get [entry $id] fields] {
        if {[dict get $field name] ne $name} continue
        if {[dict get $field kind] eq "array"} {
            # A fixed array (FIXED-LAYOUT-ARRAYS.md): the live array, read
            # one element at a time (std::binary::element) or copied whole
            # (std::binary::load); nothing is read by the projection.
            return [NativeTermType [ReprTerm $field] $edit]
        }
        if {[dict get $field kind] in {layout union}} {
            # A nested layout, or a union held by value (the live union:
            # LAYOUT-UNIONS.md): its window, nothing read.
            if {$edit} {
                return [editType [dict get $field layout]]
            }
            return [viewType [dict get $field layout]]
        }
        return [dict get $field type]
    }
    return ""
}

# The static type of field NAME read through the native memory type TYPE
# (a NativeView or a NativeEdit), or "".
proc hir::layouts::NativeFieldType {type name} {
    set id [OfNativeType $type]
    if {$id eq ""} {
        return ""
    }
    return [ViewFieldType $id $name [hir::types::IsNativeEdit $type]]
}

# ---------------------------------------------------------------------------
# Field designators (NATIVE-LAYOUT-WRITES.md)
#
# A write names one field statically, as LAYOUT.FIELD or a path through
# nested layouts, LAYOUT.FIELD.FIELD...: the operand of std::binary::store,
# std::binary::write and std::binary::write_foreign (role `path K`). Resolution
# (hir/resolve.tcl's FieldPathOperand) turns it into the constant
#
#   {STRUCTID SIZE PATH FIELD}
#
# STRUCTID the root layout's struct identity (as a descriptor's), SIZE its
# size, PATH the dotted field path ("origin.x"), and FIELD the leaf's
# descriptor entry with its offset made absolute -- {NAME OFFSET u|i WIDTH
# ENDIAN} for a scalar, {NAME OFFSET ptr WIDTH ENDIAN} for a pointer. It is
# the whole of what a backend needs for the write (one store of WIDTH bytes
# at OFFSET from the record's start); the field's semantic type, which the
# value is held to, is the registry's (PathField). A designator names a
# leaf: a nested layout is written through its fields.

# {ok CONSTANT} for the path NAMES (field names, outermost first) of layout
# ID, INDICES the static element indices written after each name (one list
# per name, {} for none: `L.pts[2].x`, FIXED-LAYOUT-ARRAYS.md), or {problem
# KIND MESSAGE INDEX ELEMENT}, INDEX the position of the name the problem
# is located at and ELEMENT, when it is about an element index, that
# index's position among the name's ("" otherwise). A designator names a
# leaf (a scalar or a pointer, a field or an element) or a whole fixed
# array (a field, or a row of one: `L.m[1]`); an element index past the
# array's extent is LAYOUT-ARRAY-INDEX, an index of something that is no
# array LAYOUT-OPERAND. With RECORDS 1 (std::binary::read, LAYOUT-UNIONS.md) it
# may also name a nested layout, whose whole copied value a read makes.
#
# A union (LAYOUT-UNIONS.md) is walked like a nested layout: its
# alternatives are its fields, all at its own offset, so `L.u.whole` is one
# leaf at u's absolute offset. A designator never ends at a union
# (LAYOUT-OPERAND: name one of its alternatives) -- it has no value of its
# own to read or write.
proc hir::layouts::FieldPath {id names {indices {}} {records 0}} {
    set layout $id
    set base 0
    set path {}
    set index 0
    set count [llength $names]
    foreach name $names {
        set field ""
        foreach f [dict get [entry $layout] fields] {
            if {[dict get $f name] eq $name} {
                set field $f
                break
            }
        }
        set written [join [concat [list $id] $path] .]
        if {$field eq ""} {
            if {[IsUnion $layout]} {
                return [list problem UNKNOWN-FIELD [format {%s has no alternative "%s" (union layout %s has alternatives: %s)} \
                    $written $name $layout [join [StructNames $layout] {, }]] $index ""]
            }
            return [list problem UNKNOWN-FIELD [format {%s has no field "%s" (layout %s has fields: %s)} \
                $written $name $layout [join [StructNames $layout] {, }]] $index ""]
        }
        set offset [expr {$base + [dict get $field offset]}]
        set repr $field
        set text $name
        set element 0
        foreach i [lindex $indices $index] {
            if {[dict get $repr kind] ne "array"} {
                return [list problem LAYOUT-OPERAND [format {%s.%s is %s, not a fixed array: an element index [%s] names an element of an array} \
                    $written $text [ReprWhat $repr] $i] $index $element]
            }
            set extent [dict get $repr extent]
            if {$i >= $extent} {
                return [list problem LAYOUT-ARRAY-INDEX [format {%s.%s is a fixed array of %s elements (indices 0..%s): the element index [%s] lies outside it} \
                    $written $text $extent [expr {$extent - 1}] $i] $index $element]
            }
            set offset [expr {$offset + $i * [dict get $repr stride]}]
            set repr [dict get $repr element]
            append text "\[$i\]"
            incr element
        }
        lappend path $text
        set last [expr {$index == $count - 1}]
        if {[dict get $repr kind] eq "union"} {
            set union [dict get $repr layout]
            if {$last} {
                return [list problem LAYOUT-OPERAND [format {%s.%s is the union layout %s, several interpretations of the same bytes: a designator names one of its alternatives (%s.%s.%s), never the union itself} \
                    $written $text $union $written $text [dict get [lindex [dict get [entry $union] fields] 0] name]] $index ""]
            }
            set layout $union
            set base $offset
            incr index
            continue
        }
        if {[dict get $repr kind] eq "layout" && $last && $records} {
            set entry [list $text $offset {*}[ReprDescriptor $repr]]
            return [list ok [list [DescriptorHead $id] [size $id] [join $path .] $entry]]
        }
        if {[dict get $repr kind] eq "layout"} {
            if {$last} {
                # (A fixed array is named too, said where the layout has one.)
                return [list problem LAYOUT-OPERAND [format {%s.%s is the nested layout %s, not a field a write can name: a write names one scalar or pointer field%s (%s.%s.%s)} \
                    $written $text [dict get $repr layout] [expr {[HasArrays $id] ? ", or a fixed array" : ""}] \
                    $written $text [lindex [StructNames [dict get $repr layout]] 0]] $index ""]
            }
            set layout [dict get $repr layout]
            set base $offset
            incr index
            continue
        }
        if {!$last} {
            set hint [expr {[dict get $repr kind] eq "array" ? " (an element of a fixed array is named by its index: $written.$text\[0\])" : ""}]
            return [list problem UNKNOWN-FIELD [format {%s.%s is %s, which has no field "%s"%s} \
                $written $text [ReprWhat $repr] [lindex $names [expr {$index + 1}]] $hint] [expr {$index + 1}] ""]
        }
        set entry [list $text $offset {*}[ReprDescriptor $repr]]
        return [list ok [list [DescriptorHead $id] [size $id] [join $path .] $entry]]
    }
    error "internal compiler error: an empty field path of layout $id"
}

# What the representation REPR is, for a message: "a scalar", "a C
# pointer", "a fixed array", "the nested layout L".
proc hir::layouts::ReprWhat {repr} {
    switch -- [dict get $repr kind] {
        float   { return "a C floating scalar ([hir::types::show [dict get $repr ctype]])" }
        pointer { return "a C pointer" }
        array   { return "a fixed array" }
        layout  { return "the nested layout [dict get $repr layout]" }
        union   { return "the union layout [dict get $repr layout]" }
    }
    return "a scalar"
}

# The root layout of the field designator constant PATH, or "" if it is
# not one.
proc hir::layouts::PathLayout {path} {
    if {[catch {llength $path} n] || $n != 4} {
        return ""
    }
    return [DescriptorLayout $path]
}

# The representation (the registry's FIELD, or an array element's) of the
# leaf the field designator constant PATH names, or "": its path's steps
# ("pts[2].x": a field name, then any element indices) walked again
# through the registry.
proc hir::layouts::PathField {path} {
    set layout [PathLayout $path]
    if {$layout eq "" || ![declared $layout]} {
        return ""
    }
    set repr ""
    foreach step [split [lindex $path 2] .] {
        if {![regexp {^([^\[]+)((?:\[[0-9]+\])*)$} $step -> name indices]} {
            return ""
        }
        if {$repr ne ""} {
            if {[dict get $repr kind] ni {layout union}} {
                return ""
            }
            set layout [dict get $repr layout]
        }
        set repr ""
        foreach f [dict get [entry $layout] fields] {
            if {[dict get $f name] eq $name} {
                set repr $f
                break
            }
        }
        if {$repr eq ""} {
            return ""
        }
        foreach i [regexp -all -inline {[0-9]+} $indices] {
            if {[dict get $repr kind] ne "array" || $i >= [dict get $repr extent]} {
                return ""
            }
            set repr [dict get $repr element]
        }
    }
    return $repr
}

# "RECORD.origin.x": the designator constant PATH as written.
proc hir::layouts::PathText {path} {
    return "[PathLayout $path].[lindex $path 2]"
}

# The pointer width in bytes on the compilation's C target: the target the
# std::ffi::c scalars of this compilation were declared for (hir/cabi.tcl's
# NamespaceTypeDecls; a pointer type can only be written where std::ffi::c is
# imported), or "" when no file of the compilation imports std::ffi::c.
proc hir::layouts::PointerWidth {} {
    set target [hir::cabi::CompilationTarget]
    if {$target eq ""} {
        return ""
    }
    return [expr {[dict get [core::cabi::target $target] pointer] / 8}]
}

# 1 if the field type expression TYPEEXPR is written as a C pointer type
# (std::ffi::c::Ptr[...] or std::ffi::c::FnPtr[...]).
proc hir::layouts::PointerTypeExpr {typeExpr} {
    return [expr {[llength $typeExpr] == 2 && [lindex $typeExpr 0] in [list [hir::cabi::PtrName] [hir::cabi::FnPtrName]]}]
}

# ---------------------------------------------------------------------------
# Declaration

# 1 if N is a power of two (N >= 1).
proc hir::layouts::PowerOfTwo {n} {
    return [expr {$n >= 1 && ($n & ($n - 1)) == 0}]
}

# The {WIDTH SIGNED} encoding of the resolved field type TYPE, or "" if TYPE
# is not a scalar field type (the file header's "Scalar encodings").
proc hir::layouts::Encoding {type} {
    variable encodings
    if {[lindex $type 0] ne "refined" || [lindex $type 1] ne "int"} {
        return ""
    }
    foreach name [core::type::evidenceClosure $type] {
        if {[core::type::isRefinement $name]} {
            return ""
        }
    }
    set facts [core::type::integerFacts $type]
    if {$facts eq "" || [dict exists $facts exact]} {
        return ""
    }
    dict for {encoding range} $encodings {
        if {[dict get $facts min] == [lindex $range 0] && [dict get $facts max] == [lindex $range 1]} {
            return $encoding
        }
    }
    return ""
}

# Why the resolved type TYPE, written SPELLED, is not a scalar field type.
proc hir::layouts::NotScalarReason {type spelled} {
    if {$type eq "int"} {
        return "int has no fixed width: a scalar field is an integer domain whose values are exactly one fixed-width encoding's (e.g. std::binary::U32, Int in 0..4294967295)"
    }
    if {[lindex $type 0] eq "refined" && [lindex $type 1] eq "int"} {
        foreach name [core::type::evidenceClosure $type] {
            if {[core::type::isRefinement $name]} {
                return "$spelled is a refinement: its values carry a proof that imprinting bytes cannot make (use its carrier's integer domain and refine the value afterwards)"
            }
        }
        set facts [core::type::integerFacts $type]
        if {[dict exists $facts exact]} {
            return "$spelled is a set of exact values, not one fixed-width encoding's whole range (not every bit pattern would be a value of it)"
        }
        return "$spelled is Int in [dict get $facts min]..[dict get $facts max], which is not the range of a fixed-width encoding (8, 16, 32 or 64 bits, unsigned 0..2^n-1 or two's-complement -2^(n-1)..2^(n-1)-1), so its width is unknown or not every bit pattern would be a value of it"
    }
    if {$type eq "Float64" || ([hir::refinements::IsRefined $type] && ![hir::types::IsRefinedApplied $type])} {
        # (C-FLOAT-FFI-MILESTONE-1.md: a field names a representation. A
        # refined List is a List, LIST-CARDINALITY-REFINEMENTS.md.)
        return "[hir::types::show $type] is a type of Botlish values, not a binary representation: a floating field names the representation it holds, [hir::cabi::FloatName] (IEEE 754 binary32) or [hir::cabi::DoubleName] (binary64), whose values are Float64s"
    }
    if {[hir::types::IsNamedStruct $type]} {
        return "[hir::types::show $type] is a struct type, not an integer domain or a layout (a nested layout field names the layout itself)"
    }
    if {[hir::types::IsCAddress $type]} {
        # A pointer field is written std::ffi::c::Ptr[T] or std::ffi::c::FnPtr[F]
        # (NATIVE-LAYOUT-VIEWS.md): its pointee identity is part of its type.
        return "[hir::types::show $type] is a C pointer of no single pointee identity: a pointer field is written std::ffi::c::Ptr\[T\] or std::ffi::c::FnPtr\[F\]"
    }
    return "[hir::types::show $type] has no fixed binary width (a layout field is an integer domain of exact fixed width, or a nested layout)"
}

# The kind of declaration (for a message) the identity ID already is, or "".
proc hir::layouts::OtherDeclaration {id name} {
    if {$name in {Int any never Fn Coroutine enum unit} || [core::type::isBuiltinName $name]
            || [dict exists $::hir::types::constructors $name] || [core::native::isBuiltinEnum $name]
            || [hir::traits::isIntrinsicName $name]} {
        return "a built-in type"
    }
    if {[core::type::valid $id]} {
        return "a type"
    }
    if {[hir::enums::declared $id]} {
        return "an enum"
    }
    if {[hir::traits::declared $id]} {
        return "a trait"
    }
    return ""
}

# Validates and registers DECLS (surface/lower.tcl's LayoutDeclOf dicts, or
# hir/read.tcl's resolved lines), resetting the previous compilation's
# registry, after the integer domains of the same compilation are registered.
# Returns HIR's own `sourceTypes` entries for them: {kind layout id ID name
# NAME namespace NS size N align A fields {{name F offset O type T} ...}}, in
# declaration order. Every malformed declaration is a located error:
#
#   LAYOUT-SIZE            size is 0 or beyond the limit
#   LAYOUT-ALIGNMENT       align is not a power of two (or beyond the limit)
#   DUPLICATE-FIELD        two fields of one name
#   LAYOUT-FIELD-TYPE      a field's type is unknown, or neither a scalar
#                          domain (the header) nor a layout
#   LAYOUT-FIELD-BOUNDS    a field does not lie inside 0..size
#   LAYOUT-FIELD-OVERLAP   two fields share a byte (an overlay is declared
#                          by a union layout, never implied)
#   LAYOUT-CYCLE           a layout contains itself by value
#
# A union layout (a decl with `union 1`, LAYOUT-UNIONS.md) is validated the
# same way but for overlap, which is its meaning: every alternative starts at
# offset 0 and must fit in the union's size (LAYOUT-FIELD-BOUNDS); two
# alternatives of one name are DUPLICATE-FIELD; a union with no alternative
# is never declared (the parser's, and HIR text's, refusal).
#
# No alignment of a field's offset is required: the declared, resolved layout
# is authoritative (a packed or vendor-aligned C layout is legal as stated),
# and `align` is the layout's own requirement for placement and storage.
proc hir::layouts::apply {decls {structDecls {}}} {
    variable registry
    variable maxAlign
    variable maxSize
    variable batchStructs
    variable pendingPointers
    Reset
    set pendingPointers {}
    # The structs of the same batch, registered after the layouts: a field
    # type naming one is reported as a struct, not as an unknown type.
    set batchStructs [dict create]
    foreach struct $structDecls {
        dict set batchStructs [identity [dict get $struct name] [dict get $struct namespace]] 1
    }
    set byId [dict create]
    foreach decl $decls {
        set name [dict get $decl name]
        set ns [dict get $decl namespace]
        set id [identity $name $ns]
        if {[dict exists $decl resolved] && [dict get $decl resolved]} {
            set id $name
            set name [lindex [split [string map {:: \x01} $id] \x01] end]
            dict set decl name $name
        }
        set other [OtherDeclaration $id $name]
        if {$other ne ""} {
            Fail [dict get $decl nameSpan] "\"$name\" cannot be declared as a layout: the name is already $other (layouts share the type namespace)"
        }
        if {[dict exists $byId $id]} {
            Fail [dict get $decl nameSpan] "layout \"$name\" is already declared"
        }
        dict set decl id $id
        dict set byId $id $decl
        # The skeleton: a field may name any layout of the batch (and know
        # at once whether it is a union, LAYOUT-UNIONS.md).
        dict set registry $id [dict create id $id name $name namespace $ns size "" align "" \
            span [dict get $decl nameSpan] fields {}]
        if {[dict getdef $decl union 0]} {
            dict set registry $id union 1
        }
    }
    set done [dict create]
    foreach id [dict keys $byId] {
        Resolve $id $byId done {}
    }
    set entries {}
    foreach id [dict keys $byId] {
        set entry [dict get $registry $id]
        set source [dict create kind layout id $id name [dict get $entry name] \
            namespace [dict get $entry namespace] size [dict get $entry size] align [dict get $entry align] \
            fields [SourceFields $id]]
        if {[IsUnion $id]} {
            dict set source union 1
        }
        lappend entries $source
    }
    return $entries
}

# The `sourceTypes` fields of registered layout ID: {name F offset O type T}
# each, and an array field's, a union field's or a C floating field's
# representation as `repr` (FIXED-LAYOUT-ARRAYS.md: its consumer type, a
# List, does not say the extent HIR text prints; LAYOUT-UNIONS.md: a union
# has no consumer type; C-FLOAT-FFI-MILESTONE-1.md: a float's and a
# double's consumer type is the same Float64).
proc hir::layouts::SourceFields {id} {
    variable registry
    return [lmap f [dict get $registry $id fields] {
        set source [dict create name [dict get $f name] offset [dict get $f offset] type [dict get $f type]]
        if {[dict get $f kind] in {array union float}} {
            dict set source repr [dict remove $f name offset]
        }
        set source
    }]
}

# Resolves and validates layout ID of BYID (DONE: the identities already
# resolved; STACK: the layouts whose resolution is under way, for LAYOUT-CYCLE),
# first resolving every layout of the batch a field of it names.
proc hir::layouts::Resolve {id byId doneVar stack} {
    upvar 1 $doneVar done
    variable registry
    variable maxAlign
    variable maxSize
    if {[dict exists $done $id]} {
        return
    }
    set decl [dict get $byId $id]
    set name [dict get $decl name]
    set ns [dict get $decl namespace]
    set size [dict get $decl size]
    set align [dict get $decl align]
    set sizeSpan [dict getdef $decl sizeSpan [dict get $decl nameSpan]]
    set alignSpan [dict getdef $decl alignSpan [dict get $decl nameSpan]]
    if {![string is entier -strict $size] || $size < 1 || $size > $maxSize} {
        Fail $sizeSpan "layout \"$name\" has size $size: a layout's size is a byte count from 1 to $maxSize" LAYOUT-SIZE
    }
    if {![string is entier -strict $align] || ![PowerOfTwo $align] || $align > $maxAlign} {
        Fail $alignSpan "layout \"$name\" has alignment $align: an alignment is a power of two from 1 to $maxAlign" LAYOUT-ALIGNMENT
    }
    set union [IsUnion $id]
    if {$union && [dict get $decl fields] eq ""} {
        Fail [dict get $decl nameSpan] "union layout \"$name\" declares no alternative: a union layout needs at least one \"alternative NAME: TYPE\" line" LAYOUT-FIELD-BOUNDS
    }
    set fields {}
    set names [dict create]
    foreach field [dict get $decl fields] {
        set fieldName [dict get $field name]
        set nameSpan [dict getdef $field nameSpan [dict get $decl nameSpan]]
        set typeSpan [dict getdef $field typeSpan $nameSpan]
        set offsetSpan [dict getdef $field offsetSpan $nameSpan]
        if {[dict exists $names $fieldName]} {
            if {$union} {
                Fail $nameSpan "duplicate alternative \"$fieldName\" in union layout \"$name\" (first declared at [Where [dict get $names $fieldName]]): a union's alternatives have distinct names" DUPLICATE-FIELD
            }
            Fail $nameSpan "duplicate field \"$fieldName\" in layout \"$name\" (first declared at [Where [dict get $names $fieldName]]): a layout's fields have distinct names" DUPLICATE-FIELD
        }
        dict set names $fieldName $nameSpan
        set offset [dict get $field offset]
        if {![string is entier -strict $offset] || $offset < 0} {
            Fail $offsetSpan "field \"$fieldName\" of layout \"$name\" has offset $offset: an offset is a byte count from 0" LAYOUT-FIELD-BOUNDS
        }
        if {$union && $offset != 0} {
            # (Neither the parser nor HIR text makes one: every alternative
            # starts at the union's origin.)
            Fail $offsetSpan "alternative \"$fieldName\" of union layout \"$name\" has offset $offset: every alternative of a union starts at its first byte" LAYOUT-FIELD-BOUNDS
        }
        set repr [ResolveRepr [dict get $field type] [dict exists $field pointerText] $ns $byId done $stack \
            $id $name $fieldName $typeSpan 0]
        lappend fields [dict merge [dict create name $fieldName offset [expr {$offset + 0}]] $repr \
            [dict create span $nameSpan typeSpan $typeSpan offsetSpan $offsetSpan]]
    }
    foreach field $fields {
        set end [expr {[dict get $field offset] + [dict get $field width]}]
        if {$end > $size} {
            if {$union} {
                # (Alternatives overlap by declaration; each must fit.)
                Fail [dict get $field typeSpan] [format {alternative "%s" of union layout "%s" is %s bytes wide (bytes 0..%s), more than the union's size %s: every alternative lies inside the union} \
                    [dict get $field name] $name [dict get $field width] [expr {$end - 1}] $size] LAYOUT-FIELD-BOUNDS
            }
            Fail [dict get $field offsetSpan] [format {field "%s" of layout "%s" occupies bytes %s..%s (offset %s, width %s), outside the layout's size %s} \
                [dict get $field name] $name [dict get $field offset] [expr {$end - 1}] [dict get $field offset] \
                [dict get $field width] $size] LAYOUT-FIELD-BOUNDS
        }
    }
    # Overlap: any two fields sharing a byte; the later-declared field of the
    # first such pair (in declared order) is the one located. A union's
    # alternatives overlap by declaration: that is what a union says, and
    # nothing else may (LAYOUT-UNIONS.md).
    set index 0
    set others $fields
    if {$union} {
        set others {}
    }
    foreach field $others {
        set lo [dict get $field offset]
        set hi [expr {$lo + [dict get $field width]}]
        foreach earlier [lrange $fields 0 [expr {$index - 1}]] {
            set elo [dict get $earlier offset]
            set ehi [expr {$elo + [dict get $earlier width]}]
            if {$lo < $ehi && $elo < $hi} {
                Fail [dict get $field offsetSpan] [format {field "%s" of layout "%s" (bytes %s..%s) overlaps field "%s" (bytes %s..%s): the fields of a layout never share a byte (bytes several interpretations share are declared by a union layout, `union layout NAME:`, held by value in one field)} \
                    [dict get $field name] $name $lo [expr {$hi - 1}] [dict get $earlier name] $elo [expr {$ehi - 1}]] LAYOUT-FIELD-OVERLAP
            }
        }
        incr index
    }
    dict set registry $id size $size
    dict set registry $id align $align
    dict set registry $id fields [lmap f $fields {
        dict remove $f span typeSpan offsetSpan
    }]
    dict set done $id 1
}

# The representation (a registry field without its name and offset) of the
# field type TYPEEXPR of field FIELDNAME of layout ID (NAME, module NS),
# located at TYPESPAN, validated -- a scalar, a pointer, a nested layout
# (resolved first, BYID/DONE/STACK as Resolve's), or a fixed array of any of
# these (FIXED-LAYOUT-ARRAYS.md), DEPTH arrays deep. POINTERTEXT 1: a leaf
# pointer is HIR text's canonical type text (hir/read.tcl). Every size is
# computed exactly (Tcl's integers have no width), so no extent can wrap:
#
#   LAYOUT-ARRAY-EXTENT  an extent that is not a positive integer, or an
#                        array wider than the largest layout size
#   LAYOUT-FIELD-TYPE    an element (or a field) of no representation
#   LAYOUT-CYCLE         a layout containing itself, through arrays too
proc hir::layouts::ResolveRepr {typeExpr pointerText ns byId doneVar stack id name fieldName typeSpan depth} {
    upvar 1 $doneVar done
    variable registry
    variable maxSize
    if {[IsUnion $id]} {
        set owner "alternative \"$fieldName\" of union layout \"$name\""
    } else {
        set owner "field \"$fieldName\" of layout \"$name\""
    }
    if {$depth == 0} {
        set what $owner
        set anArray "is an array"
        set aPointer "is a C pointer"
    } else {
        set what "the elements of [string repeat {the elements of } [expr {$depth - 1}]]$owner"
        set anArray "are arrays"
        set aPointer "are C pointers"
    }
    if {[IsArrayTypeExpr $typeExpr]} {
        lassign $typeExpr - extent elementExpr
        if {![string is entier -strict $extent] || $extent < 1} {
            Fail $typeSpan "$what $anArray of $extent elements: a fixed array's extent is a positive integer (a C zero-length or flexible array is not a fixed array)" LAYOUT-ARRAY-EXTENT
        }
        set element [ResolveRepr $elementExpr $pointerText $ns $byId done $stack $id $name $fieldName $typeSpan \
            [expr {$depth + 1}]]
        set stride [dict get $element width]
        set width [expr {$extent * $stride}]
        if {$width > $maxSize} {
            Fail $typeSpan "$what $anArray of $extent elements of $stride bytes, $width bytes in all: more than the largest layout size, $maxSize bytes" LAYOUT-ARRAY-EXTENT
        }
        return [dict create kind array extent [expr {$extent + 0}] stride $stride width $width \
            element $element type [ArrayConsumerType [dict get $element type]]]
    }
    set nested [NestedLayout $typeExpr $ns $byId]
    if {$nested ne ""} {
        if {$nested in [concat $stack [list $id]]} {
            set chain [concat [lrange $stack [lsearch -exact $stack $nested] end] [list $id $nested]]
            if {$nested eq $id} {
                set chain [list $id $id]
            }
            Fail $typeSpan "[Noun $id] \"$name\" contains itself by value through [join $chain { -> }]: a fixed layout has a finite size, so it can never contain itself (a reference to one is a pointer field, not a nested layout)" LAYOUT-CYCLE
        }
        if {[dict exists $byId $nested]} {
            Resolve $nested $byId done [concat $stack [list $id]]
        }
        set width [dict get $registry $nested size]
        if {[IsUnion $nested]} {
            # A union held by value (LAYOUT-UNIONS.md): its declared size is
            # its width -- and an array's stride -- never recomputed from its
            # alternatives.
            return [dict create kind union layout $nested width $width type [UnionConsumerType]]
        }
        return [dict create kind layout layout $nested width $width type [structType $nested]]
    }
    if {$pointerText || [PointerTypeExpr $typeExpr]} {
        # A C pointer (the file header's "Pointer fields"): the target's
        # width now, the type itself once the structs a pointee may name
        # are registered (ResolvePointers).
        set width [PointerWidth]
        if {$width eq ""} {
            Fail $typeSpan "$what $aPointer, whose width is the compilation's C target's: no file of this compilation imports std::ffi::c, so there is none" LAYOUT-FIELD-TYPE
        }
        variable pendingPointers
        lappend pendingPointers [dict create id $id field $fieldName name $name ns $ns typeExpr $typeExpr \
            typeSpan $typeSpan typeText [if {$pointerText} {set typeExpr} else {string cat ""}] depth $depth]
        # The bare pointer kind until then: affine, like every pointer.
        return [dict create kind pointer width $width endian little type cptr]
    }
    set floating [hir::cabi::FloatingOfExpr $typeExpr]
    if {$floating ne ""} {
        # A C floating field (the file header's "C floating fields"): the C
        # type's format and width on the compilation's target.
        if {[hir::cabi::CompilationTarget] eq ""} {
            Fail $typeSpan "$what is a C floating scalar ([hir::types::show $floating]), whose representation is the compilation's C target's: no file of this compilation imports std::ffi::c, so there is none" LAYOUT-FIELD-TYPE
        }
        return [FloatingRepr $floating]
    }
    set spelled [ShowTypeExpr $typeExpr]
    if {[catch {hir::resolve::ResolveTypeExpr $typeExpr $ns} resolved]} {
        Fail $typeSpan [UnresolvedFieldType $typeExpr $ns $spelled $fieldName $name $resolved] LAYOUT-FIELD-TYPE
    }
    set encoding [Encoding $resolved]
    if {$encoding eq ""} {
        Fail $typeSpan "$what cannot have type $spelled: [NotScalarReason $resolved $spelled]" LAYOUT-FIELD-TYPE
    }
    lassign $encoding width signed
    return [dict create kind scalar width $width signed $signed endian little type $resolved]
}

# The representation of the C floating type CTYPE ({cfloat NAME}) on the
# compilation's C target (the file header's "C floating fields"): its IEEE
# 754 format and width -- the C type's, never its carrier's -- and its
# carrier as the consumer type.
proc hir::layouts::FloatingRepr {ctype} {
    set info [hir::cabi::FloatingInfo $ctype]
    return [dict create kind float format [dict get $info format] width [dict get $info bytes] endian little \
        ctype $ctype type [hir::cabi::Carrier $ctype]]
}

# REPR (a representation) with the type of the leaf DEPTH arrays down set to
# TYPE, and every enclosing array's consumer type rebuilt from it.
proc hir::layouts::WithLeafType {repr depth type} {
    if {$depth == 0} {
        dict set repr type $type
        return $repr
    }
    set element [WithLeafType [dict get $repr element] [expr {$depth - 1}] $type]
    dict set repr element $element
    dict set repr type [ArrayConsumerType [dict get $element type]]
    return $repr
}

# Resolves the type of every pointer field apply registered (the file
# header's "Pointer fields"), once the structs a pointee may name are
# registered (hir::sourcetypes::apply, after hir::structs::apply), and
# writes it into the registry and into the layouts' `sourceTypes` entries
# of ORDERVAR. A pointee or signature the C ABI types reject is
# LAYOUT-FIELD-TYPE at the field's type.
proc hir::layouts::ResolvePointers {orderVar} {
    upvar 1 $orderVar order
    variable registry
    variable pendingPointers
    if {![info exists pendingPointers] || $pendingPointers eq {}} {
        return
    }
    set resolvedTypes [dict create]
    foreach pending $pendingPointers {
        dict with pending {}
        set spelled [ShowTypeExpr $typeExpr]
        if {$typeText ne ""} {
            # HIR text (hir/read.tcl): the canonical type text, read now that
            # the structs a pointee names are registered, and validated again.
            if {[catch {hir::read::ParseType $typeText 0} type]} {
                Fail $typeSpan "invalid type $typeText for field \"$field\" of layout \"$name\": $type" LAYOUT-FIELD-TYPE
            }
            set spelled $typeText
            if {[hir::types::IsCPtr $type]} {
                if {[lindex $type 1] eq "void"} {
                    set problem ""
                } else {
                    set problem [hir::cabi::PointeeProblem [lindex $type 1]]
                }
            } elseif {[hir::types::IsCFnPtr $type]} {
                set problem [hir::cabi::SignatureProblem [lindex $type 1]]
            } else {
                set problem "[hir::types::show $type] is not a C pointer type"
            }
            if {$problem ne ""} {
                Fail $typeSpan "field \"$field\" of layout \"$name\" cannot have type $spelled: $problem" LAYOUT-FIELD-TYPE
            }
        } elseif {[catch {hir::resolve::ResolveTypeExpr $typeExpr $ns} type]} {
            Fail $typeSpan "invalid type $spelled for field \"$field\" of layout \"$name\": $type" LAYOUT-FIELD-TYPE
        }
        dict set resolvedTypes $id 1
        set fields [lmap f [dict get $registry $id fields] {
            if {[dict get $f name] eq $field} {
                # (An array's pointer element, `depth` arrays down: its
                # arrays' List types follow, FIXED-LAYOUT-ARRAYS.md.)
                set f [WithLeafType $f $depth $type]
            }
            set f
        }]
        dict set registry $id fields $fields
    }
    set pendingPointers {}
    set order [lmap entry $order {
        if {[dict exists $entry kind] && [dict get $entry kind] eq "layout"
                && [dict exists $resolvedTypes [dict get $entry id]]} {
            dict set entry fields [SourceFields [dict get $entry id]]
        }
        set entry
    }]
}

# The message of a field type TYPEEXPR (written SPELLED in namespace NS)
# that does not resolve, DETAIL the resolver's reason: a struct of the same
# compilation (registered after the layouts) is named as one, a single
# unknown name as unknown.
proc hir::layouts::UnresolvedFieldType {typeExpr ns spelled fieldName layoutName detail} {
    variable batchStructs
    if {[llength $typeExpr] == 1} {
        if {$typeExpr eq [hir::cabi::VoidName]} {
            # C-ABI-TYPES.md: no field holds a value of C's void.
            return "field \"$fieldName\" of layout \"$layoutName\" cannot have type $spelled: [hir::cabi::VoidMessage]"
        }
        if {[string first :: $typeExpr] >= 0} {
            set id $typeExpr
        } else {
            set id [identity $typeExpr $ns]
        }
        if {[info exists batchStructs] && [dict exists $batchStructs $id]} {
            return "field \"$fieldName\" of layout \"$layoutName\" cannot have type $spelled: $spelled is a struct type, not an integer domain or a layout (a struct holds domain meaning, not bytes; a nested layout field names a layout)"
        }
        return "unknown type $spelled for field \"$fieldName\" of layout \"$layoutName\": no layout, union layout, integer domain or other type of that name is visible here (a field names a fixed-width integer domain, a nested layout or a union layout)"
    }
    return "unknown or invalid type $spelled for field \"$fieldName\" of layout \"$layoutName\": $detail"
}

# "FILE:LINE:COLUMN" of SPAN.
proc hir::layouts::Where {span} {
    if {$span eq "" || ![dict exists $span file]} {
        return "?"
    }
    return "[dict get $span file]:[dict get $span line]:[dict get $span column]"
}

# The layout identity a field type expression TYPEEXPR (written in module NS)
# names, or "" if it does not name a layout: a bare or qualified name that is
# a layout of BYID (this batch) or of the registry.
proc hir::layouts::NestedLayout {typeExpr ns byId} {
    if {[llength $typeExpr] != 1} {
        return ""
    }
    if {[string first :: $typeExpr] >= 0} {
        set id $typeExpr
    } else {
        set id [identity $typeExpr $ns]
    }
    if {[dict exists $byId $id] || [declared $id]} {
        return $id
    }
    return ""
}

proc hir::layouts::ShowTypeExpr {typeExpr} {
    if {[catch {hir::resolve::ShowTypeExpr $typeExpr} text]} {
        return $typeExpr
    }
    return $text
}

# The canonical text of a layout field's consumer type T for HIR text
# (hir/format.tcl): its nested layout's identity, or its integer domain's.
proc hir::layouts::FieldTypeText {type} {
    set id [OfType $type]
    if {$id ne ""} {
        return $id
    }
    if {[hir::types::IsNamedStruct $type] && [string match {LayoutStruct\[*\]} [lindex $type 1]]} {
        return [string range [lindex $type 1] 13 end-1]
    }
    if {[lindex $type 0] eq "refined" && [llength [lindex $type 2]] == 1} {
        return [lindex $type 2 0]
    }
    return [hir::types::show $type]
}

# ---------------------------------------------------------------------------
# LayoutStruct[L] in a type annotation

# The type LayoutStruct[ARG] denotes in code of namespace NS, ARG the
# argument's surface type expression; raises a located-by-caller error
# ({BOTLISH UNKNOWN-LAYOUT} or {BOTLISH LAYOUT-STRUCT-PARAMETER}) when ARG does
# not designate a layout.
#
# A union, and a layout holding one by value, has no copied value
# (LAYOUT-UNIONS.md): LayoutStruct of one is {BOTLISH LAYOUT-UNION}.
proc hir::layouts::ResolveLayoutStruct {arg ns} {
    if {[llength $arg] == 1} {
        set id [lookup $arg $ns]
        if {$id ne ""} {
            set why [UnionRefusal [NamedRepr $id] "layout $id" $id]
            if {$why ne ""} {
                return -code error -errorcode {BOTLISH LAYOUT-UNION} \
                    "LayoutStruct\[$arg\] does not exist: $why"
            }
            return [structType $id]
        }
    }
    set spelled [ShowTypeExpr $arg]
    set what [ArgumentKind $arg $ns]
    if {$what eq ""} {
        return -code error -errorcode {BOTLISH UNKNOWN-LAYOUT} \
            "unknown layout \"$spelled\" in LayoutStruct\[$spelled\]: no \"layout [lindex [split [string map {:: \x01} $spelled] \x01] end]:\" declaration is visible (the argument of LayoutStruct must name a layout)"
    }
    return -code error -errorcode {BOTLISH LAYOUT-STRUCT-PARAMETER} \
        "LayoutStruct\[$spelled\]: $spelled is $what, not a layout; the argument of LayoutStruct must name a layout declaration (`layout Name:`), whose fields LayoutStruct\[Name\] has"
}

# The type NativeView[ARG] denotes in code of namespace NS
# (NATIVE-LAYOUT-VIEWS.md): the same argument rules, and the same
# diagnostics, as LayoutStruct[ARG]'s.
proc hir::layouts::ResolveNativeView {arg ns} {
    if {[IsArrayTypeExpr $arg]} {
        # A live fixed array (FIXED-LAYOUT-ARRAYS.md): NativeView[array N of
        # E], read one element at a time.
        return [list nview [ResolveArrayTerm $arg $ns NativeView]]
    }
    if {[llength $arg] == 1} {
        set id [lookup $arg $ns]
        if {$id ne ""} {
            return [viewType $id]
        }
    }
    set spelled [ShowTypeExpr $arg]
    set what [ArgumentKind $arg $ns]
    if {$what eq ""} {
        return -code error -errorcode {BOTLISH UNKNOWN-LAYOUT} \
            "unknown layout \"$spelled\" in NativeView\[$spelled\]: no \"layout [lindex [split [string map {:: \x01} $spelled] \x01] end]:\" declaration is visible (the argument of NativeView must name a layout)"
    }
    return -code error -errorcode {BOTLISH LAYOUT-STRUCT-PARAMETER} \
        "NativeView\[$spelled\]: $spelled is $what, not a layout; the argument of NativeView must name a layout declaration (`layout Name:`), the layout through which the view reads native memory"
}

# The type NativeEdit[ARG] denotes in code of namespace NS
# (NATIVE-LAYOUT-WRITES.md): the same argument rules, and the same
# diagnostics, as NativeView[ARG]'s.
proc hir::layouts::ResolveNativeEdit {arg ns} {
    if {[IsArrayTypeExpr $arg]} {
        # A live fixed array written through (FIXED-LAYOUT-ARRAYS.md).
        return [list nedit [ResolveArrayTerm $arg $ns NativeEdit]]
    }
    if {[llength $arg] == 1} {
        set id [lookup $arg $ns]
        if {$id ne ""} {
            return [editType $id]
        }
    }
    set spelled [ShowTypeExpr $arg]
    set what [ArgumentKind $arg $ns]
    if {$what eq ""} {
        return -code error -errorcode {BOTLISH UNKNOWN-LAYOUT} \
            "unknown layout \"$spelled\" in NativeEdit\[$spelled\]: no \"layout [lindex [split [string map {:: \x01} $spelled] \x01] end]:\" declaration is visible (the argument of NativeEdit must name a layout)"
    }
    return -code error -errorcode {BOTLISH LAYOUT-STRUCT-PARAMETER} \
        "NativeEdit\[$spelled\]: $spelled is $what, not a layout; the argument of NativeEdit must name a layout declaration (`layout Name:`), the layout through which the edit reads and writes native memory"
}

# The representation term (the "Fixed arrays" section) of the array type
# expression ARG -- {array N ELEMENT}, the argument of CTOR (NativeView or
# NativeEdit) written in code of namespace NS -- or a located-by-caller error:
#
#   LAYOUT-ARRAY-EXTENT      an extent that is not a positive integer, or an
#                            array wider than the largest layout size
#   LAYOUT-STRUCT-PARAMETER  an element that is no representation (not a
#                            fixed-width integer domain, a C pointer, a
#                            layout or an array)
proc hir::layouts::ResolveArrayTerm {arg ns ctor} {
    variable maxSize
    lassign $arg - extent elementExpr
    set spelled [ShowTypeExpr $arg]
    if {![string is entier -strict $extent] || $extent < 1} {
        return -code error -errorcode {BOTLISH LAYOUT-ARRAY-EXTENT} \
            "$ctor\[$spelled\]: a fixed array's extent is a positive integer, not $extent"
    }
    if {[IsArrayTypeExpr $elementExpr]} {
        set element [ResolveArrayTerm $elementExpr $ns $ctor]
    } elseif {[llength $elementExpr] == 1 && [lookup $elementExpr $ns] ne ""} {
        # A nested layout's or a union's element (LAYOUT-UNIONS.md).
        set element [NamedTerm [lookup $elementExpr $ns]]
    } else {
        set elementText [ShowTypeExpr $elementExpr]
        if {[catch {hir::resolve::ResolveTypeExpr $elementExpr $ns} element]} {
            return -code error -errorcode {BOTLISH LAYOUT-STRUCT-PARAMETER} \
                "$ctor\[$spelled\]: unknown element type $elementText: $element"
        }
        if {!([hir::types::IsCPtr $element] || [hir::types::IsCFnPtr $element]) && [Encoding $element] eq ""} {
            return -code error -errorcode {BOTLISH LAYOUT-STRUCT-PARAMETER} \
                "$ctor\[$spelled\]: the element $elementText is not a layout representation: [NotScalarReason $element $elementText] (an element is a fixed-width integer domain, a C pointer, a layout or an array)"
        }
    }
    set term [list array [expr {$extent + 0}] $element]
    set repr [ReprOfTerm $term]
    if {$repr eq ""} {
        return -code error -errorcode {BOTLISH LAYOUT-STRUCT-PARAMETER} \
            "$ctor\[$spelled\]: its element has no width in this compilation (a C pointer's width is the C target's: import std::ffi::c)"
    }
    if {[dict get $repr width] > $maxSize} {
        return -code error -errorcode {BOTLISH LAYOUT-ARRAY-EXTENT} \
            "$ctor\[$spelled\]: [dict get $repr width] bytes, more than the largest layout size, $maxSize bytes"
    }
    return $term
}

# The message of a fixed array representation written where a type of
# values is (FIXED-LAYOUT-ARRAYS.md): LAYOUT-NOT-A-TYPE.
proc hir::layouts::ArrayNotATypeMessage {typeExpr} {
    set spelled [ShowTypeExpr $typeExpr]
    return "$spelled is a layout representation, not a type: a fixed array is a layout field's type (field NAME: $spelled at OFFSET) or the live array NativeView\[$spelled\], and a copied fixed array is a List"
}

# What the type expression ARG (written in NS) is when it is not a layout:
# "a type", "a struct", "an enum", "a refinement", "a trait", "a built-in
# type", "an applied type", or "" when it names nothing.
proc hir::layouts::ArgumentKind {arg ns} {
    if {[IsArrayTypeExpr $arg]} {
        return "a fixed array representation (a copied fixed array is a List, a live one NativeView\[[ShowTypeExpr $arg]\])"
    }
    if {[llength $arg] != 1} {
        return "an applied or structural type"
    }
    if {$arg in {int str bool unit any never list block native result struct mutarray}
            || [core::type::isBuiltinName $arg] || [dict exists $::hir::types::constructors $arg]} {
        return "a built-in type"
    }
    if {[hir::structs::lookup $arg $ns] ne ""} {
        return "a struct"
    }
    if {[hir::enums::lookup $arg $ns] ne ""} {
        return "an enum"
    }
    if {[hir::traits::lookup $arg $ns] ne ""} {
        return "a trait"
    }
    set canonical [hir::types::CanonicalTypeName $arg $ns]
    if {[core::type::isSource $canonical] || [core::type::valid $canonical]} {
        if {[core::type::isRefinement $canonical]} {
            return "a refinement type"
        }
        return "a type"
    }
    return ""
}

# ---------------------------------------------------------------------------
# The binary operations (core/binary.tcl)
#
# Each is a root native whose registration carries its layout role
# (core/native.tcl's -layout), read here and by every backend, never a name:
#
#   operand K       argument K is the static layout operand: written as a
#                   layout name, resolved (hir/resolve.tcl's LayoutOperand)
#                   to the layout's descriptor constant
#   query WHAT      (with operand 0) the call is a compile-time fact of the
#                   layout, replaced by its constant at resolution: WHAT is
#                   length (the size) or alignment
#   typed AT FORM   argument AT's static type is LayoutStruct[L]; once types
#                   are known the call becomes a call of FORM with L's
#                   descriptor appended (Elaborate)
#   input K         argument K is the bytes being imprinted: statically an
#                   std::abi::bytes::Bytes (verify)
#   pointer K       argument K is the data pointer a native view reads
#                   through: statically a std::ffi::c::Ptr[T] (verify)
#   viewed AT FORM  argument AT's static type is NativeView[L]; once types
#                   are known the call becomes a call of FORM with L's
#                   descriptor appended (Elaborate)
#   field K         argument K is one field's descriptor entry (the
#                   internal read a native view's projection becomes)
#   edited K        argument K is the native edit a store writes through:
#                   statically a NativeEdit[L] -- never a NativeView[L],
#                   which is read-only (verify)
#   output K        argument K is the byte storage a layout write writes
#                   into: statically a std::abi::bytes::MutableBytes (verify)
#   path K          argument K is the static field designator, written
#                   LAYOUT.FIELD[.FIELD...] and resolved (hir/resolve.tcl's
#                   FieldPathOperand) to the field designator constant (the
#                   "Field designators" section above)
#   value K         argument K is the value written: proven admissible for
#                   the designated field's type (VerifyWriteValue)
#   arrayed AT FORM argument AT's static type is a live fixed array,
#                   NativeView[array N of E] or NativeEdit[array N of E];
#                   once types are known the call becomes a call of FORM
#                   with the array's descriptor words appended (Elaborate)
#   array K         argument K is a live fixed array's descriptor words,
#                   {array N STRIDE ELEMENT}
#   index K         argument K is the element index, IndexNotFound unless
#                   it designates an element (the narray bounds family)
#
# and `op` the operation a backend performs (parse, emit; view, load,
# field: NATIVE-LAYOUT-VIEWS.md; edit, store, write, write_foreign:
# NATIVE-LAYOUT-WRITES.md; element, store_element, load_array:
# FIXED-LAYOUT-ARRAYS.md; read: LAYOUT-UNIONS.md, one designated
# representation imprinted from bytes -- its `input K` the bytes, its `path
# K` the designator, which may also name a nested layout).

# The -layout role of native NAME, or "".
proc hir::layouts::Role {name} {
    if {![core::native::exists $name]} {
        return ""
    }
    set meta [core::native::metadata $name]
    return [dict getdef $meta layout ""]
}

# The value of role WORD ("operand", "typed", "input", "query") in ROLE, or
# "" when ROLE has none.
proc hir::layouts::RoleOf {role word} {
    foreach {key value} $role {
        if {$key eq $word} {
            return $value
        }
    }
    return ""
}

# The root native call E of HIR is a call of (or "" when it is not a call of
# a native).
proc hir::layouts::CalledNative {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "call"} {
        return ""
    }
    lassign [dict get $node target] targetKind target
    if {$targetKind ne "native"} {
        return ""
    }
    return [dict get [hir::symbol $hir $target] name]
}

# Diagnostics of the binary operations' static operands (part of
# hir::CheckOnce):
#
#   BINARY-OPERAND      emit's value is not statically a LayoutStruct[L];
#                       the bytes given to parse are not statically an
#                       std::abi::bytes::Bytes; the pointer given to
#                       std::binary::native::view is not statically a data
#                       pointer std::ffi::c::Ptr[T]; load's value is not
#                       statically a NativeView[L]; an operation used as a
#                       value (it takes static operands, so it has no
#                       function value)
#   LAYOUT-NATIVE-ONLY  parse or emit of a layout with a pointer field (the
#                       file header's "Pointer fields"); an ordinary
#                       std::binary::write of a pointer field
#
# and for the writes (NATIVE-LAYOUT-WRITES.md):
#
#   BINARY-OPERAND      a store's edit is not statically a NativeEdit[L] (a
#                       NativeView[L] is read-only); a write's storage is
#                       not statically a std::abi::bytes::MutableBytes
#   LAYOUT-OPERAND      a store's field designator names a field of
#                       another layout than its edit's
#   LAYOUT-FOREIGN-WRITE  std::binary::write_foreign of a field that is not a C
#                       pointer (an ordinary scalar is written by
#                       std::binary::write)
#
# and for unions (LAYOUT-UNIONS.md):
#
#   LAYOUT-UNION        a copy of a representation holding a union by
#                       value: std::binary::parse, std::binary::emit, std::binary::load of
#                       one, std::binary::read of one, a whole-array write of an
#                       array of unions (a union has no copied value)
#   LAYOUT-NATIVE-ONLY  std::binary::read of a C pointer, or of anything holding
#                       one (bytes never become a pointer)
#   LAYOUT-OPERAND      std::binary::store_element of a union element (written
#                       through its alternatives, std::binary::element(a, i))
#
# The written value is held to the field's type by hir/range.tcl
# (VerifyWriteValue).
proc hir::layouts::verify {hirVar} {
    upvar 1 $hirVar hir
    set callees [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        dict set callees [dict get $node callee] 1
        set name [CalledNative $hir $e]
        if {$name eq ""} continue
        set role [Role $name]
        if {$role eq "" || ![dict get $node reachable]} continue
        # (The call's own problems with its operation: hir::CheckingCall.)
        hir::CheckingCall $e {
            foreach problem [Problems $hir $e $name $role] {
                lassign $problem kind message expr
                hir::Diagnose hir $kind $message $expr
            }
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || [dict exists $callees $e]} continue
        set b [dict get $node binding]
        if {$b eq ""} continue
        set binding [hir::binding $hir $b]
        if {[dict get $binding kind] ne "root" || [Role [dict get $binding name]] eq ""} continue
        hir::Diagnose hir BINARY-OPERAND \
            "[dict get $binding name] can only be called directly: its layout is a static operand (named at the call, or the static type of the value it emits), so it has no function value" $e
    }
}

# The problems of call E of the binary operation NAME (ROLE its -layout
# role) in HIR: a list of {KIND MESSAGE EXPR}. Native lowering asks again of
# the HIR it lowers.
proc hir::layouts::Problems {hir e name role} {
    set args [dict get $hir exprs $e args]
    set problems {}
    set at [RoleOf $role typed]
    if {$at ne ""} {
        set at [lindex $at 0]
        set arg [lindex $args $at]
        set type [hir::typeOf $hir $arg]
        if {$type ne "never" && [OfType $type] eq ""} {
            lappend problems [list BINARY-OPERAND \
                "$name needs a value whose static type is LayoutStruct\[L\] for a layout L (the layout it emits with); this value's type here is [hir::types::show $type]" $arg]
        }
    }
    set viewed [RoleOf $role viewed]
    set arrayed [RoleOf $role arrayed]
    if {$viewed ne "" || $arrayed ne ""} {
        if {$viewed ne ""} {
            set arg [lindex $args [lindex $viewed 0]]
        } else {
            set arg [lindex $args [lindex $arrayed 0]]
        }
        set type [hir::typeOf $hir $arg]
        if {$type ne "never" && !(($viewed ne "" && [OfNativeType $type] ne "")
                || ($arrayed ne "" && [OfArrayType $type] ne ""))} {
            if {$viewed eq ""} {
                # (FIXED-LAYOUT-ARRAYS.md.)
                lappend problems [list BINARY-OPERAND \
                    "$name needs a live fixed array: a value whose static type is NativeView\[array N of E\] or NativeEdit\[array N of E\] (an array field read through a native view or edit, v.items, or an element of such an array); this value's type here is [hir::types::show $type]" $arg]
            } else {
                lappend problems [list BINARY-OPERAND \
                    "$name needs a value whose static type is NativeView\[L\] or NativeEdit\[L\] for a layout L (a native view or edit, std::binary::native::view or std::binary::native::edit, whose layout it reads every field of) or a live fixed array NativeView\[array N of E\] (v.items); this value's type here is [hir::types::show $type]" $arg]
            }
        }
    }
    if {$viewed ne "" || [RoleOf $role op] in {load load_array}} {
        # std::binary::load of a live union, or of anything holding one by value
        # (LAYOUT-UNIONS.md): it has no copied value. (Its argument 0, a
        # view, an edit or a live array, before and after elaboration.)
        set arg [lindex $args 0]
        set why [NativeUnionRefusal [hir::typeOf $hir $arg]]
        if {$why ne ""} {
            lappend problems [list LAYOUT-UNION "$name cannot copy $why" $arg]
        }
    }
    if {[RoleOf $role op] eq "store_element"} {
        # One element written through a live array (FIXED-LAYOUT-ARRAYS.md):
        # the array must be write authority, and its element a scalar or a
        # pointer (a nested layout or array is written through its own
        # elements or fields, std::binary::element(a, i)).
        set arg [lindex $args 0]
        set type [hir::typeOf $hir $arg]
        set term [OfArrayType $type]
        if {$term ne "" && ![hir::types::IsNativeEdit $type]} {
            lappend problems [list BINARY-OPERAND \
                "$name writes live native memory through a native edit; this array is [hir::types::show $type], read through a native view, which is read-only: write authority over native memory is a NativeEdit, made from a pointer by std::binary::native::edit (a view never becomes one)" $arg]
        } elseif {$term ne "" && ([IsArrayTerm [lindex $term 2]] || [IsNamedTerm [lindex $term 2]])} {
            set element [lindex $term 2]
            if {[IsArrayTerm $element]} {
                set what "an array"
                set parts "elements"
                set window "array"
            } elseif {[lindex $element 0] eq "union"} {
                # (LAYOUT-UNIONS.md: a union is written one alternative at
                # a time.)
                set what "the union layout [lindex $element 1]"
                set parts "alternatives"
                set window "edit"
            } else {
                set what "the nested layout [lindex $element 1]"
                set parts "fields"
                set window "edit"
            }
            lappend problems [list LAYOUT-OPERAND \
                "$name writes one scalar or pointer element, but an element of [hir::types::show $type] is $what: write its $parts through std::binary::element(a, i), the element's own live $window" $arg]
        }
    }
    set at [RoleOf $role edited]
    if {$at ne ""} {
        set arg [lindex $args $at]
        set type [hir::typeOf $hir $arg]
        if {$type ne "never" && [OfEditType $type] eq ""} {
            if {[hir::types::IsNativeView $type]} {
                set why "[hir::types::show $type], a native view, which is read-only: write authority over native memory is a NativeEdit\[L\], made from a pointer by std::binary::native::edit (a view never becomes one)"
            } else {
                set why [hir::types::show $type]
            }
            lappend problems [list BINARY-OPERAND \
                "$name writes live native memory through a native edit (a NativeEdit\[L\], std::binary::native::edit); this value's type here is $why" $arg]
        }
    }
    set at [RoleOf $role output]
    if {$at ne ""} {
        set arg [lindex $args $at]
        set type [hir::typeOf $hir $arg]
        set mutable [core::bytestore::mutableBytesType]
        if {$type ne "never" && $type ne [list nstruct $mutable]} {
            lappend problems [list BINARY-OPERAND \
                "$name writes a field into the bytes of a $mutable (a record built in byte storage the program owns: std::abi::bytes::zeroed); this argument's type here is [hir::types::show $type]" $arg]
        }
    }
    set at [RoleOf $role path]
    if {$at ne ""} {
        set where [lindex $args $at]
        set path [ConstText $hir $where]
        set field [PathField $path]
        if {$field ne ""} {
            set text [PathText $path]
            set root [PathLayout $path]
            set edited [RoleOf $role edited]
            if {$edited ne ""} {
                set id [OfEditType [hir::typeOf $hir [lindex $args $edited]]]
                if {$id ne "" && $id ne $root} {
                    lappend problems [list LAYOUT-OPERAND \
                        "the field $text belongs to layout $root, but this edit is NativeEdit\[$id\]: a store names a field of its edit's own layout ($id.[lindex [StructNames $id] 0])" $where]
                }
            }
            set pointer [expr {[dict get $field kind] eq "pointer"}]
            set why [UnionRefusal $field $text $text]
            if {$why ne "" && [RoleOf $role op] in {write write_foreign store read}} {
                # A whole array of unions written from (or read into) a
                # List of copies none can be (LAYOUT-UNIONS.md).
                lappend problems [list LAYOUT-UNION "$name cannot [expr {[RoleOf $role op] eq "read" ? "read" : "write"}] $text whole: $why" $where]
                set field ""
            }
        }
        if {$field ne ""} {
            switch -- [RoleOf $role op] {
                read {
                    # Bytes are interpreted one representation at a time
                    # (LAYOUT-UNIONS.md); a pointer is never decoded from
                    # them.
                    set inner [ReprPointerPath $field]
                    if {$inner ne "none"} {
                        lappend problems [list LAYOUT-NATIVE-ONLY \
                            "$name cannot read $text from bytes: [expr {$inner eq "" ? "it is a C pointer" : "it holds a C pointer ($text$inner)"}], and arbitrary bytes never become one; a pointer is read from live native memory, through a native view or edit" $where]
                    }
                }
                write {
                    if {$pointer} {
                        lappend problems [list LAYOUT-NATIVE-ONLY \
                            "$name cannot write the field $text: it is a C pointer, and an ordinary byte write never encodes one; encoding a pointer the program already has into a pointer field is the explicit foreign write std::binary::write_foreign(data, $text, p)" $where]
                    } elseif {[ReprPointerPath $field] ne "none"} {
                        # A fixed array holding C pointers (FIXED-LAYOUT-
                        # ARRAYS.md), directly or in its nested elements.
                        lappend problems [list LAYOUT-NATIVE-ONLY \
                            "$name cannot write the field $text: it holds C pointers ($text[ReprPointerPath $field]), and an ordinary byte write never encodes one; an array of pointers is encoded only by the explicit foreign write std::binary::write_foreign(data, $text, pointers)" $where]
                    }
                }
                write_foreign {
                    if {!$pointer && ![PointerArray $field]} {
                        if {[dict get $field kind] eq "array"} {
                            # (FIXED-LAYOUT-ARRAYS.md: an array of C
                            # pointers takes a List of them.)
                            set message "$name encodes existing foreign values (std::ffi::c::Ptr or std::ffi::c::FnPtr values, a List of them for an array of C pointers) into a C pointer field or an array of C pointers; $text is an ordinary field of type [hir::types::show [dict get $field type]], written by std::binary::write"
                        } else {
                            set message "$name encodes an existing foreign value (a std::ffi::c::Ptr or std::ffi::c::FnPtr) into a C pointer field; $text is an ordinary field of type [hir::types::show [dict get $field type]], written by std::binary::write"
                        }
                        lappend problems [list LAYOUT-FOREIGN-WRITE $message $where]
                    }
                }
            }
        }
    }
    set pointer [RoleOf $role pointer]
    if {$pointer ne ""} {
        set arg [lindex $args $pointer]
        set type [hir::typeOf $hir $arg]
        if {$type ne "never" && ![hir::types::IsCPtr $type]} {
            if {[hir::types::IsCFnPtr $type]} {
                set why "a C function pointer, which addresses code, not data"
            } else {
                set why [hir::types::show $type]
            }
            set access [expr {[RoleOf $role op] eq "edit" ? "reads and writes" : "reads"}]
            lappend problems [list BINARY-OPERAND \
                "$name $access the live native memory a C data pointer addresses (a std::ffi::c::Ptr\[T\], which only foreign code hands out); this argument's type here is $why" $arg]
        }
    }
    # A native-only layout (a pointer field) imprinted from or emitted into
    # bytes: its pointer is authority, which arbitrary bytes are not.
    set op [RoleOf $role op]
    if {[RoleOf $role typed] ne ""} {
        # std::binary::emit before elaboration.
        set op emit
    }
    if {$op in {parse emit}} {
        set id ""
        set at [RoleOf $role typed]
        if {$at ne ""} {
            set id [OfType [hir::typeOf $hir [lindex $args [lindex $at 0]]]]
            set where [lindex $args [lindex $at 0]]
        }
        set operand [RoleOf $role operand]
        if {$id eq "" && $operand ne ""} {
            set where [lindex $args $operand]
            if {$where ne "" && [hir::kind $hir $where] eq "const"} {
                set id [DescriptorLayout [lindex [hir::get $hir $where literal] end]]
            }
        }
        set why ""
        if {$id ne "" && [declared $id]} {
            set why [UnionRefusal [NamedRepr $id] "layout $id" $id]
        }
        if {$why ne ""} {
            # (LAYOUT-UNIONS.md: before a pointer, which a union may hold
            # too -- there is no copy to make at all.)
            if {$op eq "parse"} {
                lappend problems [list LAYOUT-UNION "$name cannot imprint [Noun $id] $id from bytes: $why" $where]
            } else {
                lappend problems [list LAYOUT-UNION "$name cannot emit [Noun $id] $id into bytes: $why" $where]
            }
        } elseif {$id ne "" && [declared $id] && [NativeOnly $id]} {
            set path [PointerField $id]
            if {$op eq "parse"} {
                set message "$name cannot imprint layout \"$id\" from bytes: its field \"$path\" is a C pointer, and imprinting arbitrary bytes into it would make a pointer no foreign code handed out; a layout with a pointer field is read through a native view of live native memory (std::binary::native::view, std::binary::load)"
            } else {
                set message "$name cannot emit layout \"$id\" into bytes: its field \"$path\" is a C pointer, and writing a pointer into bytes is not supported (a layout with a pointer field is read through a native view only)"
            }
            lappend problems [list LAYOUT-NATIVE-ONLY $message $where]
        }
    }
    set input [RoleOf $role input]
    if {$input ne ""} {
        set arg [lindex $args $input]
        set type [hir::typeOf $hir $arg]
        set bytes [core::bytestore::bytesType]
        if {$type ne "never" && $type ne [list nstruct $bytes]} {
            lappend problems [list BINARY-OPERAND \
                "$name imprints the bytes of a $bytes (an owned, immutable byte value: std::abi::bytes::from_list, std::binary::emit); this argument's type here is [hir::types::show $type]" $arg]
        }
    }
    return $problems
}

# Why the native memory type TYPE -- the operand of std::binary::load: a live
# layout, union or array -- has no copied value ("TYPE: " and UnionRefusal's
# reason), or "".
proc hir::layouts::NativeUnionRefusal {type} {
    set term [OfArrayType $type]
    if {$term ne ""} {
        set repr [ReprOfTerm $term]
        if {$repr eq ""} {
            return ""
        }
        set why [UnionRefusal $repr "the array"]
    } else {
        set id [OfNativeType $type]
        if {$id eq ""} {
            return ""
        }
        set why [UnionRefusal [NamedRepr $id] "layout $id" $id]
    }
    if {$why eq ""} {
        return ""
    }
    return "[hir::types::show $type]: $why"
}

# 1 if the representation REPR is a fixed array whose leaf element, under
# every nested array, is a C pointer (FIXED-LAYOUT-ARRAYS.md: what
# std::binary::write_foreign may encode, a List of existing pointers).
proc hir::layouts::PointerArray {repr} {
    if {[dict get $repr kind] ne "array"} {
        return 0
    }
    while {[dict get $repr kind] eq "array"} {
        set repr [dict get $repr element]
    }
    return [expr {[dict get $repr kind] eq "pointer"}]
}

# 1 if the representation REPR holds a fixed array, itself or in a nested
# layout (a write of it checks extents: LayoutExtentMismatch).
proc hir::layouts::ReprHasArrays {repr} {
    switch -- [dict get $repr kind] {
        array  { return 1 }
        layout - union { return [HasArrays [dict get $repr layout]] }
    }
    return 0
}

# 1 if layout ID holds a fixed array, directly or in a nested layout.
proc hir::layouts::HasArrays {id} {
    foreach field [dict get [entry $id] fields] {
        if {[ReprHasArrays $field]} {
            return 1
        }
    }
    return 0
}

# The constant text expression E of HIR holds (a resolved operand's
# descriptor or field designator), or "" when E is no constant.
proc hir::layouts::ConstText {hir e} {
    if {$e eq "" || [hir::kind $hir $e] ne "const"} {
        return ""
    }
    return [lindex [hir::get $hir $e literal] end]
}

# ---------------------------------------------------------------------------
# NonFiniteFloat of the layout operations (the file header's "C floating
# fields")
#
# A layout operation fails with NonFiniteFloat only through a C floating
# value: reading one that is NaN or an infinity, or writing a Float64 that a
# binary32 cannot hold. Its registered -errors list NonFiniteFloat
# wherever it can; CallErrors charges a call with it only when the
# representation the call reads or writes holds such a value, so every
# other layout program is charged exactly what it always was. Everything is
# read from the call's static evidence -- its descriptor, designator or
# element constant, or its operand's static type -- before and after
# elaboration alike (the completion analysis runs on both).

# The IEEE 754 formats (core/cabi.tcl's floatingFormats) of the C floating
# values the representation words WORDS (a descriptor field entry's words
# after its name and offset) hold, sorted, without repeats.
proc hir::layouts::WordsFormats {words} {
    switch -- [lindex $words 0] {
        f {
            return [list [core::cabi::formatOfWidth [lindex $words 1]]]
        }
        layout - union {
            return [DescriptorFormats [lindex $words 1]]
        }
        array {
            return [WordsFormats [lindex $words 3]]
        }
    }
    return {}
}

# WordsFormats of every field of the descriptor DESCRIPTOR.
proc hir::layouts::DescriptorFormats {descriptor} {
    set formats {}
    foreach field [lindex $descriptor 3] {
        lappend formats {*}[WordsFormats [lrange $field 2 end]]
    }
    return [lsort -unique $formats]
}

# What call CALLARGS (their static types ARGTYPES) of the layout native NAME
# reads or writes, as {HOW WORDS}: HOW `copy` (every value the
# representation words WORDS hold is read: parse, read, load), `leaf` (a
# field read or an element access, which reads a value only when WORDS are
# a leaf's -- anything else is a window, nothing read) or `write` (every
# value WORDS hold is written: emit, a write, a store) -- or "" when the call
# reads and writes no layout value (a view's construction, a query, a
# pointer write) or its static evidence is missing (diagnosed elsewhere).
proc hir::layouts::CallWords {hir name callArgs argTypes} {
    set role [Role $name]
    set op [RoleOf $role op]
    switch -- $op {
        parse - load - emit {
            set descriptor [ArgConst $hir $callArgs [RoleOf $role operand]]
            if {[DescriptorLayout $descriptor] eq ""} {
                return ""
            }
            return [list [expr {$op eq "emit" ? "write" : "copy"}] [list layout $descriptor]]
        }
        read - store - write {
            set path [ArgConst $hir $callArgs [RoleOf $role path]]
            if {[PathLayout $path] eq ""} {
                return ""
            }
            return [list [expr {$op eq "read" ? "copy" : "write"}] [lrange [lindex $path 3] 2 end]]
        }
        field {
            set field [ArgConst $hir $callArgs [RoleOf $role field]]
            if {[llength $field] < 3} {
                return ""
            }
            return [list leaf [lrange $field 2 end]]
        }
        element - store_element - load_array {
            set how [dict get {element leaf store_element write load_array copy} $op]
            set words [ArgConst $hir $callArgs [RoleOf $role array]]
            if {$words eq ""} {
                # Before elaboration: the live array's static type.
                set arrayed [RoleOf $role arrayed]
                if {$arrayed eq ""} {
                    return ""
                }
                set term [OfArrayType [lindex $argTypes [lindex $arrayed 0]]]
                if {$term eq "" || [ReprOfTerm $term] eq ""} {
                    return ""
                }
                set words [TermDescriptor $term]
            }
            if {[lindex $words 0] ne "array"} {
                return ""
            }
            if {$op eq "load_array"} {
                return [list copy $words]
            }
            return [list $how [lindex $words 3]]
        }
    }
    # Before elaboration: std::binary::emit's value, std::binary::load's view or array.
    set typed [RoleOf $role typed]
    if {$typed ne ""} {
        set id [OfType [lindex $argTypes [lindex $typed 0]]]
        if {$id eq ""} {
            return ""
        }
        return [list write [list layout [descriptor $id]]]
    }
    set viewed [RoleOf $role viewed]
    if {$viewed ne ""} {
        set type [lindex $argTypes [lindex $viewed 0]]
        set id [OfNativeType $type]
        if {$id ne "" && ![HoldsUnion $id]} {
            return [list copy [list layout [descriptor $id]]]
        }
        set term [OfArrayType $type]
        if {$term ne "" && [ReprOfTerm $term] ne ""} {
            return [list copy [TermDescriptor $term]]
        }
    }
    return ""
}

# The constant text of argument AT ("" for none) of ARGS, or "".
proc hir::layouts::ArgConst {hir callArgs at} {
    if {$at eq ""} {
        return ""
    }
    return [ConstText $hir [lindex $callArgs $at]]
}

# {NonFiniteFloat} when call CALLARGS (static types ARGTYPES) of the layout
# native NAME can fail through a C floating value -- it reads one (any
# format: NaN and the infinities are no Float64), or writes a Float64 into a
# binary32, which may overflow -- else {}.
proc hir::layouts::FloatErrors {hir name callArgs argTypes} {
    lassign [CallWords $hir $name $callArgs $argTypes] how words
    switch -- $how {
        copy {
            if {[WordsFormats $words] ne {}} {
                return NonFiniteFloat
            }
        }
        leaf {
            if {[lindex $words 0] eq "f"} {
                return NonFiniteFloat
            }
        }
        write {
            if {"binary32" in [WordsFormats $words]} {
                return NonFiniteFloat
            }
        }
    }
    return {}
}

# ERRORS -- declared errors of native NAME -- as call CALLARGS (static types
# ARGTYPES) charges them: a layout operation's NonFiniteFloat only when the
# call can fail through a C floating value (FloatErrors). Every other
# native's errors as they are.
proc hir::layouts::CallErrors {hir name callArgs argTypes errors} {
    if {"NonFiniteFloat" ni $errors || [Role $name] eq ""} {
        return $errors
    }
    if {[FloatErrors $hir $name $callArgs $argTypes] ne {}} {
        return $errors
    }
    return [lsearch -all -inline -not -exact $errors NonFiniteFloat]
}

# The C floating format of the leaf a write call CALLARGS of the layout native
# NAME writes, when it writes exactly one C floating value (a float or
# double field, or an element) -- binary32 or binary64 -- else "".
proc hir::layouts::WrittenFloatFormat {hir name callArgs argTypes} {
    lassign [CallWords $hir $name $callArgs $argTypes] how words
    if {$how ne "write" || [lindex $words 0] ne "f"} {
        return ""
    }
    return [core::cabi::formatOfWidth [lindex $words 1]]
}

# 1 if a projection of field NAME through a receiver of static type TYPE (a
# NativeView[L] or NativeEdit[L]) reads a C floating value from native
# memory: it may fail with NonFiniteFloat (the projection becomes
# binary#view_field after the checks: Elaborate).
proc hir::layouts::ProjectionReadsFloat {type name} {
    set id [OfNativeType $type]
    if {$id eq ""} {
        return 0
    }
    set field [FieldDescriptor $id $name]
    return [expr {$field ne "" && [lindex $field 2] eq "f"}]
}

# Holds the value a write (std::binary::store, std::binary::write,
# std::binary::write_foreign: role `value K`) puts into its designated field to
# the field's type, in call E (NODE) of native NAME (NATIVE-LAYOUT-WRITES.md):
# the one admissibility proof a construction's field values are held to
# (hir::range::ProvesValueAcceptedBy) -- a scalar's integer domain, proven
# by the value's type or its Range (no conversion, truncation or run-time
# guard); a pointer field's exact pointer type (no implicit erasure or
# retyping, no Int). Called by hir/range.tcl's VerifyCall with the call's
# RANGES.
proc hir::layouts::VerifyWriteValue {hirVar ranges e node name} {
    upvar 1 $hirVar hir
    set role [Role $name]
    set at [RoleOf $role value]
    if {$at eq "" || ![dict get $node reachable]} {
        return
    }
    set args [dict get $node args]
    if {[RoleOf $role op] eq "store_element"} {
        # One element of a live array (FIXED-LAYOUT-ARRAYS.md), held to the
        # element's type exactly as a field's value is.
        set arrayType [hir::typeOf $hir [lindex $args 0]]
        set term [OfArrayType $arrayType]
        if {$term eq "" || ![hir::types::IsNativeEdit $arrayType] || [ReprOfTerm [lindex $term 2]] eq ""
                || [dict get [ReprOfTerm [lindex $term 2]] kind] ni {scalar float pointer}} {
            return
        }
        # (A C floating element holds its carrier's values: a Float64.)
        set declared [lindex $term 2]
        set arg [lindex $args $at]
        set valueType [hir::typeOf $hir $arg]
        if {$valueType eq "never" || ![hir::get $hir $arg reachable]} {
            return
        }
        set range [dict getdef $ranges $arg [hir::range::unknown]]
        if {[hir::range::ProvesValueAcceptedBy $valueType $range [hir::cabi::Carrier $declared]]} {
            return
        }
        hir::Diagnose hir TYPE [format {the value %s writes into an element of %s cannot be proven to satisfy the element's type %s (value type: %s%s)} \
            $name [hir::types::show $arrayType] [hir::types::show $declared] [hir::semantic::ShowType $hir [hir::range::ShownArgType $valueType $declared]] \
            [hir::range::FactsClause $valueType $declared $range]] $arg
        return
    }
    set path [ConstText $hir [lindex $args [RoleOf $role path]]]
    set field [PathField $path]
    if {$field eq ""} {
        return
    }
    set pointer [expr {[dict get $field kind] eq "pointer" || [PointerArray $field]}]
    set op [RoleOf $role op]
    if {($op eq "write" && [ReprPointerPath $field] ne "none") || ($op eq "write_foreign" && !$pointer)
            || [ReprUnionPath $field] ne "none" || $op eq "read"} {
        # The operation does not write this kind of field (verify; an array
        # of unions has no copied value to write, LAYOUT-UNIONS.md).
        return
    }
    set declared [dict get $field type]
    set arg [lindex $args $at]
    set valueType [hir::typeOf $hir $arg]
    if {$valueType eq "never" || ![hir::get $hir $arg reachable]} {
        return
    }
    set range [dict getdef $ranges $arg [hir::range::unknown]]
    if {[hir::range::ProvesValueAcceptedBy $valueType $range $declared]} {
        return
    }
    set hint ""
    if {[hir::types::IsCPtr $declared] && [hir::types::IsCPtr $valueType]} {
        set hint ": a pointer's pointee identity is never converted implicitly (std::ffi::c::erase makes a Ptr\[std::ffi::c::Void\], std::ffi::c::retype\[T\] one back)"
    } elseif {[hir::types::IsCAddress $declared] && ![hir::types::IsCAddress $valueType]} {
        set hint ": a pointer field holds only a pointer the program already has, never an Int or any other value"
    } elseif {[hir::types::IsCPtr $declared] != [hir::types::IsCPtr $valueType]} {
        set hint ": data and function pointers are distinct, and nothing converts one into the other"
    }
    hir::Diagnose hir TYPE [format {the value written to field %s by %s cannot be proven to satisfy the field's type %s (value type: %s%s)%s} \
        [PathText $path] $name [hir::types::show $declared] [hir::semantic::ShowType $hir [hir::range::ShownArgType $valueType $declared]] \
        [hir::range::FactsClause $valueType $declared $range] $hint] $arg
}

# Writes out the layout every `typed` binary operation reads from its value's
# static type (BINARY-LAYOUT.md, "Emission"): the call becomes a call of its
# role's FORM with the layout's descriptor appended, so every backend reads
# the layout from the call alone. Part of hir::BuildFull, after the checks;
# a call whose value is not a LayoutStruct (a BINARY-OPERAND diagnostic) is
# left alone.
#
# Native views (NATIVE-LAYOUT-VIEWS.md) likewise: std::binary::load(v) becomes
# binary#load(v, DESCRIPTOR) from v's static NativeView[L], and every
# projection `v.f` of a receiver statically a NativeView[L] becomes the
# internal read binary#view_field(v, FIELD), FIELD f's descriptor entry --
# its static type the projection's -- so no backend reads a layout or
# knows the view type: a field read is an explicit operation with constant
# operands.
proc hir::layouts::Elaborate {hirVar} {
    upvar 1 $hirVar hir
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "project"} {
            # (A NativeEdit[L]'s reads are a view's: NATIVE-LAYOUT-WRITES.md.)
            set id [OfNativeType [hir::typeOf $hir [dict get $node receiver]]]
            if {$id eq ""} continue
            set field [FieldDescriptor $id [dict get $node name]]
            if {$field eq ""} continue
            ViewRead hir $e $field
            continue
        }
        if {[dict get $node kind] ne "call"} continue
        set name [CalledNative $hir $e]
        if {$name eq ""} continue
        set role [Role $name]
        set constant ""
        set typed [RoleOf $role typed]
        if {$typed ne ""} {
            lassign $typed at form
            set id [OfType [hir::typeOf $hir [lindex [dict get $node args] $at]]]
            if {$id ne ""} {
                set constant [descriptor $id]
            }
        } else {
            set type ""
            set viewed [RoleOf $role viewed]
            if {$viewed ne ""} {
                lassign $viewed at form
                set type [hir::typeOf $hir [lindex [dict get $node args] $at]]
                set id [OfNativeType $type]
                if {$id ne ""} {
                    set constant [descriptor $id]
                }
            }
            set arrayed [RoleOf $role arrayed]
            if {$constant eq "" && $arrayed ne ""} {
                # A live fixed array's element access or copy
                # (FIXED-LAYOUT-ARRAYS.md): its descriptor words {array N
                # STRIDE ELEMENT}, from its static type.
                lassign $arrayed at form
                set term [OfArrayType [hir::typeOf $hir [lindex [dict get $node args] $at]]]
                if {$term ne ""} {
                    set constant [TermDescriptor $term]
                }
            }
        }
        if {$constant eq ""} continue
        hir::mutvec::Retarget hir $e $form
        dict set hir exprs $e args [concat [dict get $hir exprs $e args] \
            [list [hir::mutvec::NewConst hir $constant $e]]]
    }
}

# The native that reads one field through a native view (core/binary.tcl).
proc hir::layouts::ViewReadNative {} {
    return binary#view_field
}

# Rewrites projection E of a native view, in place, into the call
# binary#view_field(RECEIVER, FIELD) of the same static type: E keeps its
# identity, so its parent, its type and every side table naming it are
# unchanged.
proc hir::layouts::ViewRead {hirVar e field} {
    upvar 1 $hirVar hir
    set node [dict get $hir exprs $e]
    set native [ViewReadNative]
    set b [hir::mutvec::NativeBinding $hir $native]
    set y [dict get $hir bindings $b symbol]
    set r [hir::NewId hir expr]
    dict set hir exprs $r [dict create id $r kind ref origin [dict get $node origin] \
        scope [dict get $node scope] type [hir::types::intern hir [list native $native]] \
        reachable [dict get $node reachable] name $native binding $b init yes]
    set c [hir::mutvec::NewConst hir $field $e]
    dict set hir exprs $e [dict create id $e kind call origin [dict get $node origin] \
        scope [dict get $node scope] type [dict get $node type] reachable [dict get $node reachable] \
        callee $r args [list [dict get $node receiver] $c] target [list native $y] known ""]
}

# Diagnoses, in the view of semantic instance HIR (hir/semantic.tcl's View)
# whose generic program is GENERIC, every projection in EXPRS whose receiver
# is a native view in the instance but not statically one in the generic
# program: a field read through a view lowers to the field's constant offset
# and encoding (Elaborate), which an untyped receiver does not have -- so the
# receiver must be statically NativeView[L] (BINARY-OPERAND), as emit's value
# must be statically a LayoutStruct.
proc hir::layouts::verifyInstance {hirVar generic exprs} {
    upvar 1 $hirVar hir
    foreach e $exprs {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] ne "project" || ![dict get $node reachable]} continue
        set receiver [dict get $node receiver]
        set type [hir::typeOf $hir $receiver]
        set id [OfNativeType $type]
        if {$id eq "" || [OfNativeType [hir::typeOf $generic $receiver]] ne ""} continue
        set shown [hir::types::show $type]
        hir::Diagnose hir BINARY-OPERAND \
            "the field \"[dict get $node name]\" is read through a native view ($shown) whose type is not static here: a native view's field is read at its layout's constant offset, so the receiver must be statically a NativeView\[L\] or NativeEdit\[L\] (declare the parameter or result that carries it $shown)" $e
    }
}

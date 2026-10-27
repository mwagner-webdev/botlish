# cdecl.tcl -- a small declaration parser for preprocessed C
# (C-HEADER-ARCHAEOLOGY.md).
#
# Research instrument, not part of the compiler: it reads what a real C
# preprocessor wrote (`cc -E` output: C tokens plus line markers and the
# directives the preprocessor passes through, `#pragma` and, with -dD,
# `#define`) and turns every top-level declaration into a record of the
# exploratory FFI IR. It never evaluates a preprocessor conditional, expands
# a macro or resolves an include: that is the preprocessor's job.
#
#   tokenizer (Lex)  ->  declaration parser (External)  ->  IR records
#
# A record is a three-element Tcl list {KIND NAME BODY}, BODY a dict:
#
#   function NAME   type {fn ...} storage extern|static|none inline 0|1
#                   definition 0|1 (an inline body in the header) link ...
#   typedef NAME    type TYPE
#   variable NAME   type TYPE storage ... init TEXT
#   struct TAG      kind struct|union complete 0|1 fields {{NAME TYPE BITS ATTRS} ...}
#   enum TAG        complete 0|1 enumerators {{NAME FORM VALUE TEXT} ...}
#   static_assert - / asm - / pragma -
#   unsupported -   category CATEGORY reason TEXT state STATE
#
# Every record also has loc {FILE LINE ENDLINE}, attrs (the attributes that
# survived preprocessing, with the position they were written at) and text
# (the preprocessed tokens of the declaration, normalized spacing).
#
# C types are recursive Tcl lists (C-HEADER-ARCHAEOLOGY.md, "The IR"):
#
#   {void} {bool} {int SPELLING} {float SPELLING} {complex SPELLING}
#   {builtin NAME}            __builtin_va_list and its kin
#   {typedef NAME}            a typedef reference, never flattened
#   {struct TAG} {union TAG} {enum TAG}
#   {ptr TYPE}                a pointer
#   {q QUALS TYPE}            qualifiers (sorted) of TYPE
#   {array TYPE BOUND ?QUALS?}  BOUND {} | {lit N} | {expr TEXT} | {vla}
#   {fn RESULT PARAMS FLAGS}  PARAMS {{NAME TYPE ATTRS} ...}, FLAGS among
#                             variadic (...) and noproto (an empty "()")
#   {typeof TEXT} {atomic TYPE} {bitint TEXT}   compiler extensions

namespace eval ::cdecl {
    # The token stream: parallel lists, one element per token.
    variable kinds {}
    variable texts {}
    variable tfile {}
    variable tline {}
    # Files named by line markers: index -> name, and the system flag (3).
    variable fileNames {}
    variable fileSystem {}
    # Directives the preprocessor passed through: {TOKENINDEX FILE LINE TEXT}.
    variable directives {}

    # Parser state.
    variable pos 0
    variable ntok 0
    variable typedefs [dict create]
    variable enumerators [dict create]
    variable records {}
    variable anon [dict create]
    variable stack {}
    variable diags {}
    # A procedure (one argument: a file name) that classifies a file as
    # public, internal, system, builtin or entry; set by the driver.
    variable originCommand {}
    variable originCache [dict create]
    # Typedef names known before the text (parse's TYPEDEFS).
    variable seedTypedefs {}

    variable storageWords {typedef extern static auto register _Thread_local __thread thread_local constexpr}
    variable fnspecWords {inline __inline __inline__ __forceinline _Noreturn __noreturn__}
    variable qualWords {
        const const __const const __const__ const
        volatile volatile __volatile volatile __volatile__ volatile
        restrict restrict __restrict restrict __restrict__ restrict
        _Nonnull _Nonnull _Nullable _Nullable _Null_unspecified _Null_unspecified
        _Nullable_result _Nullable_result
        __ptr32 __ptr32 __ptr64 __ptr64 __unaligned __unaligned __w64 __w64
        __sptr __sptr __uptr __uptr
    }
    # (MSVC's sized integer keywords, __int8 to __int64, which its own
    # headers spell size_t and intptr_t with, are its char, short, int and
    # long long: BaseType spells them so.)
    variable typeWords {void char short int long float double signed __signed
        __signed__ unsigned _Bool _Complex __complex__ __complex _Imaginary __int128
        __int8 __int16 __int32 __int64}
    # Type names that are keywords of some compilers and typedefs of others
    # (glibc typedefs _Float32 for clang): a type only where no type
    # specifier was seen yet, like a typedef name.
    variable softTypes {
        _Float16 float _Float32 float _Float64 float _Float128 float
        _Float32x float _Float64x float _Float128x float __float128 float
        __float80 float __ibm128 float __bf16 float _Decimal32 float
        _Decimal64 float _Decimal128 float bool bool
    }
    # Builtin type names that behave like typedef names.
    variable builtinTypes {__builtin_va_list __builtin_ms_va_list __int128_t __uint128_t}
    variable ccWords {__cdecl _cdecl __stdcall _stdcall __fastcall _fastcall
        __thiscall __vectorcall __clrcall __pascal __regcall}
    variable attrWords {__attribute__ __attribute __declspec _Alignas alignas}
    variable typeofWords {typeof __typeof__ __typeof typeof_unqual __typeof_unqual__ __auto_type}
}

# ---------------------------------------------------------------------------
# Tokenizer.

# Lex TEXT (preprocessed C) into the token stream. Line markers
# (`# N "file" flags`, `#line N "file"`) set the location of the lines that
# follow; every other directive is kept, with the index of the token it
# precedes, in `directives`.
proc ::cdecl::Lex {text} {
    variable kinds {}
    variable texts {}
    variable tfile {}
    variable tline {}
    variable fileNames {}
    variable fileSystem {}
    variable directives {}
    set index [dict create]
    set file [FileIndex index <unknown> 0]
    set line 1
    set re {(?:L|u8|u|U)?"(?:[^"\\]|\\.)*"|(?:L|u8|u|U)?'(?:[^'\\]|\\.)*'|[A-Za-z_$][A-Za-z0-9_$]*|\.?[0-9](?:[eEpP][-+]|[A-Za-z0-9_.])*|\.\.\.|<<=|>>=|->|\+\+|--|<<|>>|<=|>=|==|!=|&&|\|\||[-*/%+&^|]=|##|::|[][(){}.&*+~!/%<>^|?:;=,#-]|\S}
    foreach raw [split $text \n] {
        if {[string index [string trimleft $raw] 0] eq "#"} {
            if {[regexp {^\s*#\s*(?:line\s+)?([0-9]+)(?:\s+"((?:[^"\\]|\\.)*)"(.*))?\s*$} $raw -> n name flags]} {
                if {$name ne ""} {
                    set name [string map {\\\\ \\ \\\" \"} $name]
                    set file [FileIndex index $name [expr {3 in $flags}]]
                }
                set line $n
                continue
            }
            lappend directives [list [llength $kinds] $file $line [string trim $raw]]
            incr line
            continue
        }
        foreach token [regexp -all -inline $re $raw] {
            set c [string index $token 0]
            if {[string is alpha $c] || $c eq "_" || $c eq "$"} {
                if {[regexp {^(?:L|u8|u|U)?(["'])} $token -> q]} {
                    set kind [expr {$q eq "\"" ? "str" : "chr"}]
                } else {
                    set kind id
                }
            } elseif {[string is digit $c] || ($c eq "." && [string length $token] > 1 && [string is digit [string index $token 1]])} {
                set kind num
            } elseif {$c eq "\""} {
                set kind str
            } elseif {$c eq "'"} {
                set kind chr
            } elseif {[string first $c "\[\](){}.&*+~!/%<>^|?:;=,#-"] >= 0} {
                set kind punct
            } else {
                set kind bad
            }
            lappend kinds $kind
            lappend texts $token
            lappend tfile $file
            lappend tline $line
        }
        incr line
    }
    return [llength $kinds]
}

proc ::cdecl::FileIndex {indexVar name system} {
    upvar 1 $indexVar index
    variable fileNames
    variable fileSystem
    if {![dict exists $index $name]} {
        dict set index $name [llength $fileNames]
        lappend fileNames $name
        lappend fileSystem $system
    } elseif {$system} {
        lset fileSystem [dict get $index $name] 1
    }
    return [dict get $index $name]
}

# ---------------------------------------------------------------------------
# Token access.

proc ::cdecl::Peek {{k 0}} {
    variable texts
    variable pos
    return [lindex $texts [expr {$pos + $k}]]
}
proc ::cdecl::Kind {{k 0}} {
    variable kinds
    variable pos
    return [lindex $kinds [expr {$pos + $k}]]
}
proc ::cdecl::Next {} {
    variable texts
    variable pos
    variable ntok
    if {$pos >= $ntok} { Fail DECLARATION-PARSE-FAILURE "unexpected end of input" }
    set t [lindex $texts $pos]
    incr pos
    return $t
}
proc ::cdecl::Expect {t} {
    if {[Peek] ne $t} {
        Fail DECLARATION-PARSE-FAILURE "expected \"$t\", found \"[Peek]\""
    }
    Next
}
proc ::cdecl::Fail {category reason} {
    return -code error -errorcode [list CDECL $category] $reason
}

# The text of tokens FROM .. TO-1, normalized spacing.
proc ::cdecl::TextOf {from to} {
    variable texts
    variable kinds
    set out ""
    set prev ""
    set prevKind ""
    for {set i $from} {$i < $to} {incr i} {
        set t [lindex $texts $i]
        set k [lindex $kinds $i]
        if {$i > $from} {
            set space 1
            if {$t in {, ; ) ]} || $prev in {( [}} { set space 0 }
            if {$prev eq "*" && $t ne "*" && $k ne "punct"} { set space 0 }
            if {$prev eq "*" && $t eq "*"} { set space 0 }
            if {$t eq "\[" } { set space 0 }
            if {$t eq "(" && $prevKind eq "id" && ![IsKeyword $prev]} { set space 0 }
            if {$space} { append out " " }
        }
        append out $t
        set prev $t
        set prevKind $k
    }
    return $out
}

proc ::cdecl::IsKeyword {t} {
    variable storageWords
    variable fnspecWords
    variable qualWords
    variable typeWords
    expr {$t in $storageWords || $t in $fnspecWords || [dict exists $qualWords $t]
          || $t in $typeWords || $t in {struct union enum sizeof return _Alignof __alignof__ typeof __typeof__ _Static_assert}}
}

proc ::cdecl::Loc {i} {
    variable tfile
    variable tline
    variable fileNames
    return [list [lindex $fileNames [lindex $tfile $i]] [lindex $tline $i]]
}

# ---------------------------------------------------------------------------
# Records.

proc ::cdecl::Origin {file} {
    variable originCommand
    variable originCache
    if {![dict exists $originCache $file]} {
        if {$originCommand eq ""} {
            dict set originCache $file unknown
        } else {
            dict set originCache $file [{*}$originCommand $file]
        }
    }
    return [dict get $originCache $file]
}

proc ::cdecl::Emit {kind name from to body} {
    variable records
    variable tline
    variable tfile
    lassign [Loc $from] file line
    set last [expr {$to - 1}]
    set endline [expr {[lindex $tfile $last] == [lindex $tfile $from] ? [lindex $tline $last] : $line}]
    set head [dict create loc [list $file $line $endline] origin [Origin $file]]
    set body [dict merge $head $body]
    if {![dict exists $body text]} {
        dict set body text [TextOf $from $to]
    }
    dict set body pos $from
    lappend records [list $kind $name $body]
}

# ---------------------------------------------------------------------------
# Parser entry point.

# Parse the whole token stream into `records`, recovering after every
# declaration that fails.
proc ::cdecl::ParseAll {} {
    variable pos 0
    variable ntok
    variable kinds
    variable records {}
    variable typedefs [dict create]
    variable enumerators [dict create]
    variable anon [dict create]
    variable diags {}
    variable stack {}
    variable originCache [dict create]
    variable seedTypedefs
    foreach name $seedTypedefs { dict set typedefs $name 1 }
    set ntok [llength $kinds]
    while {$pos < $ntok} {
        set start $pos
        set mark [llength $records]
        if {[catch {External} message options]} {
            set code [dict get $options -errorcode]
            if {[lindex $code 0] ne "CDECL"} {
                return -options $options $message
            }
            set state [expr {[llength $stack] ? [lindex $stack end] : "top"}]
            set failedAt $pos
            set records [lrange $records 0 [expr {$mark - 1}]]
            set stack {}
            set pos $start
            Recover
            if {$pos <= $start} { set pos [expr {$start + 1}] }
            Emit unsupported - $start $pos [dict create category [lindex $code 1] \
                reason $message state $state at [expr {$failedAt - $start}]]
        }
    }
    return $records
}

# Skip from the start of a failed declaration to its end: the next ";" at
# bracket depth 0, or the "}" closing a function body (a brace block opened
# right after ")").
proc ::cdecl::Recover {} {
    variable pos
    variable ntok
    variable texts
    set depth 0
    set opened {}
    while {$pos < $ntok} {
        set t [lindex $texts $pos]
        incr pos
        switch -- $t {
            ( - [ { incr depth }
            ) - ] { incr depth -1 }
            \{ {
                lappend opened [lindex $texts [expr {$pos - 2}]]
                incr depth
            }
            \} {
                incr depth -1
                set before [lindex $opened end]
                set opened [lrange $opened 0 end-1]
                if {$depth <= 0 && $before eq ")"} { return }
            }
            ; { if {$depth <= 0} { return } }
        }
    }
}

# ---------------------------------------------------------------------------
# External declarations.

proc ::cdecl::External {} {
    variable pos
    variable stack
    set start $pos
    set t [Peek]
    if {$t eq ";"} { Next; return }
    if {$t in {_Static_assert static_assert}} {
        Next
        set text [Balanced {;}]
        Expect ";"
        Emit static_assert - $start $pos [dict create expr $text]
        return
    }
    if {$t in {__asm__ __asm asm}} {
        Next
        while {[Peek] in {volatile __volatile__}} { Next }
        set text [Balanced {;}]
        Expect ";"
        Emit asm - $start $pos [dict create text [TextOf $start $pos]]
        return
    }
    lappend stack declaration-specifiers
    set spec [Specifiers top]
    set stack [lrange $stack 0 end-1]
    set base [dict get $spec type]
    if {[Peek] eq ";"} {
        Next
        # A declaration of a tag alone: "struct ssl_st;" (a forward
        # declaration) or a definition already recorded by Specifiers.
        if {![dict get $spec defined] && [lindex [Unqualified $base] 0] in {struct union enum}} {
            lassign [Unqualified $base] kw tag
            if {$kw eq "enum"} {
                Emit enum $tag $start $pos [dict create complete 0 enumerators {} attrs [dict get $spec attrs]]
            } else {
                Emit struct $tag $start $pos [dict create kind $kw complete 0 fields {} attrs [dict get $spec attrs]]
            }
        } elseif {[dict get $spec storage] ne "" || [dict get $spec defined] == 0} {
            Emit unsupported - $start $pos [dict create category DECLARATION-PARSE-FAILURE \
                reason "declaration declares nothing" state top at 0]
        }
        return
    }
    set first 1
    set emitted {}
    while 1 {
        lappend stack declarator
        set d [Declarator 0]
        set stack [lrange $stack 0 end-1]
        set attrs [concat [Tagged spec [dict get $spec attrs]] [dict get $d attrs]]
        set link ""
        lassign [AfterDeclarator] after link
        lappend attrs {*}[Tagged decl $after]
        set type [Apply $base [dict get $d ops]]
        set name [dict get $d name]
        set storage [Storage [dict get $spec storage]]
        set kind [expr {$storage eq "typedef" ? "typedef" : ([lindex $type 0] eq "fn" ? "function" : "variable")}]
        if {$first && $kind eq "function" && [Peek] eq "\{"} {
            set bodyStart $pos
            SkipBraces
            set body [dict create type $type storage $storage inline [Inline $spec] \
                definition 1 bodytokens [expr {$pos - $bodyStart}] attrs $attrs \
                fnspec [dict get $spec fnspec] \
                text "[TextOf $start $bodyStart] \{ ... \}"]
            if {$link ne ""} { dict set body link $link }
            Emit function $name $start $pos $body
            return
        }
        set init ""
        if {[Peek] eq "="} {
            Next
            set init [Balanced {, ;}]
        }
        set body [dict create type $type storage $storage attrs $attrs]
        if {$kind eq "function"} {
            dict set body inline [Inline $spec]
            dict set body definition 0
            dict set body fnspec [dict get $spec fnspec]
        }
        if {$init ne ""} { dict set body init $init }
        if {$link ne ""} { dict set body link $link }
        if {[dict get $spec unknown] ne ""} { dict set body unknowntypes [dict get $spec unknown] }
        lappend emitted [list $kind $name $body]
        if {$kind eq "typedef"} { variable typedefs; dict set typedefs $name 1 }
        if {[Peek] eq ","} { Next; set first 0; continue }
        Expect ";"
        break
    }
    foreach e $emitted {
        lassign $e kind name body
        Emit $kind $name $start $pos $body
    }
}

proc ::cdecl::Tagged {position attrs} {
    set out {}
    foreach a $attrs { lappend out [linsert $a 1 $position] }
    return $out
}

proc ::cdecl::Storage {words} {
    foreach w {typedef extern static} {
        if {$w in $words} { return $w }
    }
    if {[llength $words]} { return [lindex $words 0] }
    return none
}

proc ::cdecl::Inline {spec} {
    expr {[llength [lsearch -all -inline -regexp [dict get $spec fnspec] {inline}]] > 0}
}

proc ::cdecl::Unqualified {type} {
    while {[lindex $type 0] eq "q"} { set type [lindex $type 2] }
    return $type
}

# Attributes and an asm label after a declarator: {ATTRS LINK}.
proc ::cdecl::AfterDeclarator {} {
    set attrs {}
    set link ""
    while 1 {
        set t [Peek]
        if {$t in {__asm__ __asm asm}} {
            Next
            Expect "("
            set label ""
            while {[Kind] eq "str"} { append label [string range [Next] 1 end-1] }
            Expect ")"
            set link $label
            lappend attrs [list asm $label]
        } elseif {[IsAttributeStart]} {
            lappend attrs {*}[Attribute]
        } else {
            break
        }
    }
    return [list $attrs $link]
}

proc ::cdecl::SkipBraces {} {
    Expect "\{"
    set depth 1
    while {$depth > 0} {
        set t [Next]
        if {$t eq "\{"} { incr depth } elseif {$t eq "\}"} { incr depth -1 }
    }
}

# The text of a balanced token sequence up to (not including) one of
# TERMINATORS at depth 0.
proc ::cdecl::Balanced {terminators} {
    variable pos
    variable ntok
    variable texts
    set from $pos
    set depth 0
    while {$pos < $ntok} {
        set t [lindex $texts $pos]
        if {$depth == 0 && $t in $terminators} { break }
        switch -- $t {
            ( - [ - \{ { incr depth }
            ) - ] - \} {
                if {$depth == 0} { break }
                incr depth -1
            }
        }
        incr pos
    }
    if {$pos >= $ntok} { Fail DECLARATION-PARSE-FAILURE "unterminated expression" }
    return [TextOf $from $pos]
}

# ---------------------------------------------------------------------------
# Declaration specifiers.

# Parse declaration specifiers; CONTEXT is top, member or param. Returns a
# dict: type (the base type, qualified), storage, fnspec, attrs, defined (1
# when a struct/union/enum body was parsed), unknown (identifiers taken as
# type names without a typedef in sight).
proc ::cdecl::Specifiers {context} {
    variable storageWords
    variable fnspecWords
    variable qualWords
    variable typeWords
    variable softTypes
    variable builtinTypes
    variable ccWords
    variable typeofWords
    variable typedefs
    set storage {}
    set fnspec {}
    set quals {}
    set attrs {}
    set words {}
    set base {}
    set defined 0
    set unknown {}
    while 1 {
        set t [Peek]
        set k [Kind]
        if {$k ne "id"} {
            if {$t eq "\[" && [Peek 1] eq "\["} {
                lappend attrs {*}[Attribute]
                continue
            }
            break
        }
        if {$t in $storageWords} {
            lappend storage [Next]
        } elseif {$t in $fnspecWords} {
            lappend fnspec [Next]
        } elseif {[dict exists $qualWords $t]} {
            lappend quals [dict get $qualWords [Next]]
        } elseif {$t eq "_Atomic"} {
            Next
            if {[Peek] eq "("} {
                Next
                set inner [TypeName]
                Expect ")"
                set base [list atomic $inner]
            } else {
                lappend quals _Atomic
            }
        } elseif {$t in $typeWords} {
            if {$base ne ""} { Fail DECLARATION-PARSE-FAILURE "type keyword \"$t\" after a complete type" }
            lappend words [Next]
        } elseif {$t in {struct union}} {
            if {$base ne "" || $words ne ""} { Fail DECLARATION-PARSE-FAILURE "two types in one declaration" }
            lassign [StructSpecifier] base def
            if {$def} { set defined 1 }
        } elseif {$t eq "enum"} {
            if {$base ne "" || $words ne ""} { Fail DECLARATION-PARSE-FAILURE "two types in one declaration" }
            lassign [EnumSpecifier] base def
            if {$def} { set defined 1 }
        } elseif {[IsAttributeStart]} {
            lappend attrs {*}[Attribute]
        } elseif {$t in {__extension__}} {
            Next
            lappend attrs [list extension __extension__]
        } elseif {$t in $ccWords} {
            lappend attrs [list cc [Next]]
        } elseif {$t in $typeofWords} {
            Next
            if {$t eq "__auto_type"} {
                set base [list typeof __auto_type]
            } else {
                Expect "("
                set text [Balanced {)}]
                Expect ")"
                set base [list typeof $text]
            }
        } elseif {$t eq "_BitInt"} {
            Next
            Expect "("
            set text [Balanced {)}]
            Expect ")"
            lappend words "_BitInt($text)"
        } elseif {$base eq "" && $words eq "" && [dict exists $typedefs $t]} {
            set base [list typedef [Next]]
        } elseif {$base eq "" && $words eq "" && $t in $builtinTypes} {
            set base [list builtin [Next]]
        } elseif {$base eq "" && $words eq "" && [dict exists $softTypes $t]} {
            set kw [Next]
            set base [expr {$kw eq "bool" ? {bool} : [list float $kw]}]
        } elseif {$base eq "" && $words eq "" && ([Kind 1] eq "id" || [Peek 1] eq "*")
                  && $context ne "member-name"} {
            # An identifier where a type must be, followed by a declarator:
            # an unknown type name (a typedef the parser never saw).
            lappend unknown $t
            set base [list typedef [Next]]
        } else {
            break
        }
    }
    if {$base eq ""} {
        if {$words eq ""} {
            Fail DECLARATION-PARSE-FAILURE "no type specifier before \"[Peek]\""
        }
        set base [BaseType $words]
    } elseif {$words ne ""} {
        Fail DECLARATION-PARSE-FAILURE "type keywords [list $words] with $base"
    }
    if {$quals ne ""} {
        set base [list q [lsort -unique $quals] $base]
    }
    return [dict create type $base storage $storage fnspec $fnspec attrs $attrs defined $defined unknown $unknown]
}

# A type name (specifiers and an abstract declarator), as in _Atomic(T).
proc ::cdecl::TypeName {} {
    set spec [Specifiers param]
    set d [Declarator 1]
    return [Apply [dict get $spec type] [dict get $d ops]]
}

# The base type of a list of type keywords, canonically spelled.
proc ::cdecl::BaseType {words} {
    set count [dict create]
    foreach w $words {
        if {$w in {__signed __signed__}} { set w signed }
        if {$w in {__complex__ __complex}} { set w _Complex }
        switch -- $w {
            __int8 { set w char }
            __int16 { set w short }
            __int32 { set w int }
            __int64 { dict incr count long 2; continue }
        }
        dict incr count $w
    }
    set n [lambda {count w} { expr {[dict exists $count $w] ? [dict get $count $w] : 0} }]
    set longs [apply $n $count long]
    set signed [apply $n $count signed]
    set unsigned [apply $n $count unsigned]
    set complex [apply $n $count _Complex]
    set rest [dict keys [dict remove $count long signed unsigned int _Complex]]
    if {$signed + $unsigned > 1} { Fail TYPE-SHAPE-UNSUPPORTED "signed and unsigned together: $words" }
    set bitint [lsearch -inline $rest _BitInt*]
    if {$bitint ne ""} {
        return [list bitint [expr {$unsigned ? "unsigned $bitint" : $bitint}]]
    }
    switch -- [lsort $rest] {
        void { return {void} }
        _Bool { return {bool} }
        char {
            if {$signed} { return {int {signed char}} }
            if {$unsigned} { return {int {unsigned char}} }
            return {int char}
        }
        short {
            return [list int [expr {$unsigned ? "unsigned short" : "short"}]]
        }
        __int128 {
            return [list int [expr {$unsigned ? "unsigned __int128" : "__int128"}]]
        }
        float {
            return [list [expr {$complex ? "complex" : "float"}] float]
        }
        double {
            set s [expr {$longs ? "long double" : "double"}]
            return [list [expr {$complex ? "complex" : "float"}] $s]
        }
        {} {
            if {$complex && !$longs} { return {complex double} }
            set s [lindex {int long {long long}} $longs]
            if {$s eq ""} { Fail TYPE-SHAPE-UNSUPPORTED "too many longs: $words" }
            if {$unsigned} { set s "unsigned $s" }
            return [list int $s]
        }
    }
    Fail TYPE-SHAPE-UNSUPPORTED "type keywords $words"
}

proc ::cdecl::lambda {args body} { list $args $body }

# ---------------------------------------------------------------------------
# Attributes and extension syntax that survive preprocessing.

proc ::cdecl::IsAttributeStart {} {
    variable attrWords
    set t [Peek]
    expr {$t in $attrWords || ($t eq "\[" && [Peek 1] eq "\[")}
}

# One attribute construct: a list of {FORM NAME ARGS} items.
proc ::cdecl::Attribute {} {
    set t [Next]
    set out {}
    switch -- $t {
        __attribute__ - __attribute {
            Expect "("
            Expect "("
            foreach item [Items {)}] { lappend out [linsert $item 0 gnu] }
            Expect ")"
            Expect ")"
        }
        __declspec {
            Expect "("
            foreach item [Items {)}] { lappend out [linsert $item 0 declspec] }
            Expect ")"
        }
        _Alignas - alignas {
            Expect "("
            set text [Balanced {)}]
            Expect ")"
            lappend out [list alignas aligned $text]
        }
        \[ {
            Expect "\["
            foreach item [Items {]}] { lappend out [linsert $item 0 std] }
            Expect "\]"
            Expect "\]"
        }
    }
    return $out
}

# Comma-separated attribute items up to CLOSE: {NAME ARGS}, the name without
# its __reserved__ underscores, the arguments as text.
proc ::cdecl::Items {close} {
    set items {}
    while {[Peek] ni $close} {
        if {[Peek] eq ","} { Next; continue }
        set name [Next]
        while {[Peek] eq "::"} { Next; append name ::[Next] }
        regsub {^__(.*)__$} $name {\1} name
        set args ""
        if {[Peek] eq "("} {
            Next
            set args [Balanced {)}]
            Expect ")"
        }
        lappend items [list $name $args]
    }
    return $items
}

# ---------------------------------------------------------------------------
# struct, union and enum specifiers.

proc ::cdecl::AnonTag {kw} {
    variable anon
    variable pos
    lassign [Loc $pos] file line
    set key "[file tail $file]:$line"
    dict incr anon $key
    set n [dict get $anon $key]
    return [expr {$n == 1 ? "anon@$key" : "anon@$key#$n"}]
}

# {TYPE DEFINED}
proc ::cdecl::StructSpecifier {} {
    variable pos
    variable stack
    set start $pos
    set kw [Next]
    set attrs {}
    while {[IsAttributeStart]} { lappend attrs {*}[Tagged tag [Attribute]] }
    set tag ""
    if {[Kind] eq "id"} { set tag [Next] }
    while {[IsAttributeStart]} { lappend attrs {*}[Tagged tag [Attribute]] }
    if {[Peek] ne "\{"} {
        if {$tag eq ""} { Fail DECLARATION-PARSE-FAILURE "$kw without a tag or a body" }
        return [list [list $kw $tag] 0]
    }
    if {$tag eq ""} { set tag [AnonTag $kw]; set anonymous 1 } else { set anonymous 0 }
    lappend stack "$kw $tag"
    Next
    set fields {}
    while {[Peek] ne "\}"} {
        lappend fields {*}[MemberDeclaration $tag]
    }
    Next
    while {[IsAttributeStart]} { lappend attrs {*}[Tagged body [Attribute]] }
    set stack [lrange $stack 0 end-1]
    set parent [lsearch -inline -regexp [lreverse $stack] {^(struct|union) }]
    set body [dict create kind $kw complete 1 anonymous $anonymous fields $fields attrs $attrs]
    if {$parent ne ""} { dict set body parent [lindex $parent 1] }
    Emit struct $tag $start $pos $body
    return [list [list $kw $tag] 1]
}

# Fields of one member declaration: {{NAME TYPE BITS ATTRS} ...}.
proc ::cdecl::MemberDeclaration {owner} {
    variable pos
    if {[Peek] eq ";"} { Next; return {} }
    if {[Peek] in {_Static_assert static_assert}} {
        Next
        Balanced {;}
        Expect ";"
        return {}
    }
    set spec [Specifiers member]
    set base [dict get $spec type]
    set sattrs [Tagged spec [dict get $spec attrs]]
    if {[Peek] eq ";"} {
        Next
        # An anonymous struct or union member (C11), or nothing.
        return [list [list "" $base "" $sattrs]]
    }
    set fields {}
    while 1 {
        if {[Peek] eq ":"} {
            Next
            set bits [Bound [Balanced {, ;}]]
            lappend fields [list "" $base $bits $sattrs]
        } else {
            set d [Declarator 0]
            lassign [AfterDeclarator] after
            set bits ""
            if {[Peek] eq ":"} {
                Next
                set bits [Bound [Balanced {, ; __attribute__}]]
                lassign [AfterDeclarator] more
                lappend after {*}$more
            }
            set attrs [concat $sattrs [dict get $d attrs] [Tagged decl $after]]
            lappend fields [list [dict get $d name] [Apply $base [dict get $d ops]] $bits $attrs]
        }
        if {[Peek] eq ","} { Next; continue }
        Expect ";"
        break
    }
    return $fields
}

# {TYPE DEFINED}
proc ::cdecl::EnumSpecifier {} {
    variable pos
    variable enumerators
    set start $pos
    Next
    set attrs {}
    while {[IsAttributeStart]} { lappend attrs {*}[Tagged tag [Attribute]] }
    set tag ""
    if {[Kind] eq "id"} { set tag [Next] }
    while {[IsAttributeStart]} { lappend attrs {*}[Tagged tag [Attribute]] }
    set underlying ""
    if {[Peek] eq ":" && [Peek 1] ne ":"} {
        Next
        set underlying [TypeName]
    }
    if {[Peek] ne "\{"} {
        if {$tag eq ""} { Fail DECLARATION-PARSE-FAILURE "enum without a tag or a body" }
        return [list [list enum $tag] 0]
    }
    if {$tag eq ""} { set tag [AnonTag enum]; set anonymous 1 } else { set anonymous 0 }
    Next
    set list {}
    set previous ""
    while {[Peek] ne "\}"} {
        if {[Kind] ne "id"} { Fail DECLARATION-PARSE-FAILURE "expected an enumerator, found \"[Peek]\"" }
        set name [Next]
        set eattrs {}
        while {[IsAttributeStart]} { lappend eattrs {*}[Attribute] }
        if {[Peek] eq "="} {
            Next
            set from $pos
            set text [Balanced {, \}}]
            lassign [EnumValue $from $pos] form value
        } else {
            set text ""
            if {$previous eq ""} {
                set form implicit
                set value 0
            } elseif {[lindex $previous 2] ne ""} {
                set form implicit
                set value [expr {[lindex $previous 2] + 1}]
            } else {
                set form implicit
                set value ""
            }
        }
        set previous [list $name $form $value $text]
        if {$eattrs ne ""} { lappend previous $eattrs }
        lappend list $previous
        dict set enumerators $name $value
        if {[Peek] eq ","} { Next }
    }
    Next
    while {[IsAttributeStart]} { lappend attrs {*}[Tagged body [Attribute]] }
    set body [dict create complete 1 anonymous $anonymous enumerators $list attrs $attrs]
    if {$underlying ne ""} { dict set body underlying $underlying }
    Emit enum $tag $start $pos $body
    return [list [list enum $tag] 1]
}

# The form of an enumerator's value expression (tokens FROM .. TO-1) and its
# value when the form is trivial: {FORM VALUE}. FORM is literal,
# negated-literal, char, ref (a previous enumerator), or expr; the value is
# computed only for the first four (no C expression evaluator).
proc ::cdecl::EnumValue {from to} {
    variable texts
    variable kinds
    variable enumerators
    set toks [lrange $texts $from [expr {$to - 1}]]
    set ks [lrange $kinds $from [expr {$to - 1}]]
    while {[lindex $toks 0] eq "(" && [lindex $toks end] eq ")" && [Parenthesized $toks]} {
        set toks [lrange $toks 1 end-1]
        set ks [lrange $ks 1 end-1]
    }
    if {[llength $toks] == 1 && [lindex $ks 0] eq "num"} {
        set v [IntLiteral [lindex $toks 0]]
        if {$v ne ""} { return [list literal $v] }
    }
    if {[llength $toks] == 2 && [lindex $toks 0] eq "-" && [lindex $ks 1] eq "num"} {
        set v [IntLiteral [lindex $toks 1]]
        if {$v ne ""} { return [list negated-literal [expr {-$v}]] }
    }
    if {[llength $toks] == 1 && [lindex $ks 0] eq "chr"} {
        set v [CharLiteral [lindex $toks 0]]
        if {$v ne ""} { return [list char $v] }
    }
    if {[llength $toks] == 1 && [lindex $ks 0] eq "id" && [dict exists $enumerators [lindex $toks 0]]} {
        return [list ref [dict get $enumerators [lindex $toks 0]]]
    }
    return [list expr ""]
}

proc ::cdecl::Parenthesized {toks} {
    set depth 0
    set n [llength $toks]
    for {set i 0} {$i < $n} {incr i} {
        set t [lindex $toks $i]
        if {$t eq "("} { incr depth } elseif {$t eq ")"} { incr depth -1 }
        if {$depth == 0 && $i < $n - 1} { return 0 }
    }
    return 1
}

# The value of a C integer literal, or "" when it is not one.
proc ::cdecl::IntLiteral {t} {
    set t [string tolower $t]
    regsub {(u|l|ul|lu|ll|ull|llu|z|uz|zu)$} $t {} t
    if {[regexp {^0x([0-9a-f]+)$} $t -> h]} { return [expr {"0x$h" + 0}] }
    if {[regexp {^0b([01]+)$} $t -> b]} { return [expr {"0b$b" + 0}] }
    if {[regexp {^0([0-7]+)$} $t -> o]} { return [expr {"0o$o" + 0}] }
    if {[regexp {^[0-9]+$} $t]} { return [expr {[scan $t %lld] + 0}] }
    return ""
}

proc ::cdecl::CharLiteral {t} {
    if {[regexp {^'(.)'$} $t -> c]} { return [scan $c %c] }
    if {[regexp {^'\\([0-7]{1,3})'$} $t -> o]} { return [expr {"0o$o" + 0}] }
    if {[regexp {^'\\x([0-9a-fA-F]+)'$} $t -> h]} { return [expr {"0x$h" + 0}] }
    set escapes {n 10 t 9 r 13 0 0 \\ 92 ' 39 \" 34 a 7 b 8 f 12 v 11}
    if {[regexp {^'\\(.)'$} $t -> e] && [dict exists $escapes $e]} { return [dict get $escapes $e] }
    return ""
}

# An array bound or a bitfield width: {} | {lit N} | {vla} | {expr TEXT}.
proc ::cdecl::Bound {text} {
    if {$text eq ""} { return {} }
    if {$text eq "*"} { return {vla} }
    set v [IntLiteral $text]
    if {$v ne ""} { return [list lit $v] }
    return [list expr $text]
}

# ---------------------------------------------------------------------------
# Declarators.

# Parse a declarator; ABSTRACT allows it to have no name. Returns a dict:
# name, ops (derivations, applied to the base type in order), attrs.
#
# The derivations of  POINTERS DIRECT SUFFIXES  apply the pointers first,
# then the suffixes from the last to the first, then the derivations of a
# parenthesized inner declarator:  int (*a[4])(const char *)  is
# fn(const char *) -> int, then a pointer to it, then an array of 4 of those.
proc ::cdecl::Declarator {abstract} {
    variable typedefs
    variable qualWords
    variable ccWords
    set pointers {}
    set attrs {}
    # Attributes and calling conventions written before the pointers of a
    # (parenthesized) declarator: `int (__attribute__((__stdcall__)) *f)(int)`,
    # what MinGW's CALLBACK and WINAPI become.
    while {[Peek] in $ccWords || [IsAttributeStart]} {
        if {[Peek] in $ccWords} {
            lappend attrs [list cc inner [Next]]
        } else {
            lappend attrs {*}[Tagged inner [Attribute]]
        }
    }
    while {[Peek] in {* ^}} {
        set star [Next]
        set quals {}
        while 1 {
            set t [Peek]
            if {[dict exists $qualWords $t]} {
                lappend quals [dict get $qualWords [Next]]
            } elseif {$t eq "_Atomic"} {
                Next
                lappend quals _Atomic
            } elseif {[IsAttributeStart]} {
                lappend attrs {*}[Tagged ptr [Attribute]]
            } elseif {$t in $ccWords} {
                lappend attrs [list cc ptr [Next]]
            } else {
                break
            }
        }
        lappend pointers [list [expr {$star eq "*" ? "ptr" : "block"}] [lsort -unique $quals]]
    }
    while {[Peek] in $ccWords || [IsAttributeStart]} {
        if {[Peek] in $ccWords} {
            lappend attrs [list cc inner [Next]]
        } else {
            lappend attrs {*}[Tagged inner [Attribute]]
        }
    }
    set name ""
    set inner {}
    if {[Kind] eq "id" && ![IsKeywordish [Peek]]} {
        set name [Next]
    } elseif {[Peek] eq "(" && [NestedStart]} {
        Next
        set d [Declarator $abstract]
        Expect ")"
        set name [dict get $d name]
        set inner [dict get $d ops]
        lappend attrs {*}[dict get $d attrs]
    } elseif {!$abstract} {
        Fail DECLARATION-PARSE-FAILURE "expected a declarator, found \"[Peek]\""
    }
    set suffixes {}
    while 1 {
        if {[Peek] eq "\["} {
            if {[Peek 1] eq "\["} { break }
            Next
            set quals {}
            set static 0
            while {[Peek] eq "static" || [dict exists $qualWords [Peek]]} {
                if {[Peek] eq "static"} { Next; set static 1 } else { lappend quals [dict get $qualWords [Next]] }
            }
            set bound [Bound [Balanced {]}]]
            Expect "\]"
            if {$static} { lappend quals static }
            lappend suffixes [list array $bound [lsort -unique $quals]]
        } elseif {[Peek] eq "("} {
            lappend suffixes [Parameters]
        } else {
            break
        }
    }
    set ops [concat $pointers [lreverse $suffixes] $inner]
    return [dict create name $name ops $ops attrs $attrs]
}

# Is the word a type keyword or a typedef name (so not a declarator name)?
proc ::cdecl::IsTypeStart {t} {
    variable typedefs
    variable typeWords
    variable qualWords
    variable builtinTypes
    variable storageWords
    expr {$t in $typeWords || [dict exists $qualWords $t] || [dict exists $typedefs $t]
          || $t in $builtinTypes || $t in {struct union enum} || $t in $storageWords}
}

# A word that can never be a declarator's name.
proc ::cdecl::IsKeywordish {t} {
    variable typeWords
    variable qualWords
    variable storageWords
    variable fnspecWords
    expr {$t in $typeWords || [dict exists $qualWords $t] || $t in $storageWords
          || $t in $fnspecWords || $t in {struct union enum}}
}

# At "(": does a parenthesized declarator start (rather than a parameter
# list)?
proc ::cdecl::NestedStart {} {
    variable ccWords
    variable attrWords
    set t [Peek 1]
    if {$t in {* ^ ( \[}} { return 1 }
    if {$t in $ccWords || $t in $attrWords} { return 1 }
    if {[Kind 1] eq "id" && ![IsTypeStart $t]} {
        variable softTypes
        if {[dict exists $softTypes $t]} { return 0 }
        return 1
    }
    return 0
}

# A parameter list: {fn PARAMS FLAGS}.
proc ::cdecl::Parameters {} {
    variable stack
    Expect "("
    if {[Peek] eq ")"} {
        Next
        return [list fn {} noproto]
    }
    if {[Peek] eq "void" && [Peek 1] eq ")"} {
        Next
        Next
        return [list fn {} {}]
    }
    lappend stack parameter
    set params {}
    set flags {}
    while 1 {
        if {[Peek] eq "..."} {
            Next
            lappend flags variadic
            break
        }
        set spec [Specifiers param]
        set d [Declarator 1]
        lassign [AfterDeclarator] after
        set attrs [concat [Tagged spec [dict get $spec attrs]] [dict get $d attrs] [Tagged decl $after]]
        set param [list [dict get $d name] [Apply [dict get $spec type] [dict get $d ops]] $attrs]
        if {[dict get $spec storage] ne ""} { lappend param [dict get $spec storage] }
        lappend params $param
        if {[Peek] eq ","} { Next; continue }
        break
    }
    Expect ")"
    set stack [lrange $stack 0 end-1]
    return [list fn $params $flags]
}

# Apply declarator derivations to a base type.
proc ::cdecl::Apply {type ops} {
    foreach op $ops {
        switch -- [lindex $op 0] {
            ptr - block {
                set type [list [lindex $op 0] $type]
                if {[lindex $op 1] ne ""} { set type [list q [lindex $op 1] $type] }
            }
            array {
                set type [list array $type [lindex $op 1]]
                if {[lindex $op 2] ne ""} { lappend type [lindex $op 2] }
            }
            fn {
                set type [list fn $type [lindex $op 1] [lindex $op 2]]
            }
        }
    }
    return $type
}

# ---------------------------------------------------------------------------
# Driver helpers.

# Parse TEXT (preprocessed C); return the records, directives merged in as
# pragma/directive records at their positions. TYPEDEFS names typedefs
# declared before TEXT (a declaration parsed apart from its translation
# unit, such as a binding profile's signature of a macro API).
proc ::cdecl::parse {text {originCommand {}} {typedefs {}}} {
    variable directives
    variable fileNames
    variable seedTypedefs $typedefs
    set ::cdecl::originCommand $originCommand
    Lex $text
    set records [ParseAll]
    set seedTypedefs {}
    # Merge the directives (pragmas, #ident, ...) in by token position.
    set out {}
    set di 0
    set nd [llength $directives]
    foreach r $records {
        set p [dict get [lindex $r 2] pos]
        while {$di < $nd && [lindex $directives $di 0] <= $p} {
            lappend out [DirectiveRecord [lindex $directives $di]]
            incr di
        }
        lappend out $r
    }
    while {$di < $nd} {
        lappend out [DirectiveRecord [lindex $directives $di]]
        incr di
    }
    return $out
}

proc ::cdecl::DirectiveRecord {d} {
    variable fileNames
    lassign $d index file line text
    set name [lindex $fileNames $file]
    set kind directive
    if {[regexp {^#\s*pragma\s+(.*)$} $text -> rest]} { set kind pragma; set text $rest }
    return [list $kind - [dict create loc [list $name $line $line] origin [Origin $name] text $text pos $index]]
}

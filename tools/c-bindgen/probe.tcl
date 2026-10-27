# probe.tcl -- what the C compiler knows that a declaration does not say
# (C-BINDGEN.md, "ABI probes", "Link symbols", "Compiler evidence").
#
# Every fact here is computed by the installed C compiler for the profile's
# target, in one batched translation unit per question, never by
# interpreting C in Tcl:
#
#   values      integer constant expressions: sizeof, the C integer type a
#               typedef, an enum or a constant expression has (a _Generic
#               selection), a constant's value. The probe defines one
#               `const unsigned long long botlish_probe_N[]` per entry and is
#               compiled to assembly, whose data directives are the values:
#               nothing is linked or run, so every target works the same way
#               (the header archaeology's probe ran a native program).
#   symbols     the link symbol an API name denotes: `&(NAME)` as the
#               initializer of a function-pointer constant, the assembly's
#               relocation target with the target's user label prefix
#               stripped. It is the compiler that applies asm labels,
#               `#pragma redefine_extname` and object-like macro aliases; an
#               API name that is no link-time constant (a stub-table member)
#               is a compile error, recorded.
#   evidence    clang's optimized LLVM IR of the shim: the nocapture,
#               readonly, writeonly, readnone and returned attributes it
#               inferred on the thunks' own parameters.
#   anonymous   clang's record layouts of the anonymous members (a union
#               or struct member without a name, C11) of the records it
#               lays out: their sizeof, alignment and member offsets, which
#               no C expression asks, as -fdump-record-layouts prints them
#               (LAYOUT-UNIONS.md, "C bindgen").
#
# An entry the compiler rejects is dropped with the compiler's message and
# the rest compiled again, so one bad macro never hides the others.

namespace eval ::cbind::probe {
    # The C integer (and floating) types a _Generic selection names, by code.
    variable codes {
        1 char 2 {signed char} 3 {unsigned char} 4 short 5 {unsigned short}
        6 int 7 {unsigned int} 8 long 9 {unsigned long} 10 {long long}
        11 {unsigned long long} 12 _Bool 13 float 14 double 15 {long double}
    }
    variable rounds 40
}

# The C type CODE names ("" for 0, a type outside the table: a pointer, a
# struct, ...).
proc ::cbind::probe::typeOfCode {code} {
    variable codes
    return [expr {[dict exists $codes $code] ? [dict get $codes $code] : ""}]
}

# A C expression evaluating to the code of EXPR's type.
proc ::cbind::probe::Generic {expr} {
    variable codes
    set assoc {}
    dict for {code type} $codes { lappend assoc "$type: $code" }
    return "_Generic(($expr), [join $assoc {, }], default: 0)"
}

proc ::cbind::probe::typeCodeOf {type} { Generic "($type)0" }
proc ::cbind::probe::exprCodeOf {expr} { Generic $expr }

# The prelude of a probe: the profile's entry headers.
proc ::cbind::probe::Prelude {hprofile} {
    set text ""
    foreach h [dict get $hprofile entry] { append text "#include <$h>\n" }
    return $text
}

# Compiles SOURCE (C text whose entry lines are LINES: line number ->
# entry index) to assembly, dropping every entry the compiler rejects;
# returns {ASSEMBLY REJECTED COMMAND}, REJECTED a dict index -> message.
# MAKE is a command prefix called with the list of live entry indices that
# returns {SOURCE LINES}.
proc ::cbind::probe::Assemble {config hprofile make live} {
    variable rounds
    set rejected [dict create]
    for {set round 0} {$round < $rounds} {incr round} {
        lassign [{*}$make $live] source lines
        lassign [::chdr::toolchain::assemble $config $hprofile $source {-w -O0}] ok asm stderr command
        if {$ok} {
            return [list $asm $rejected $command]
        }
        set blame [Blame $stderr $lines]
        if {[dict size $blame] == 0} {
            error "c-bindgen: a probe failed outside its entries: [string range $stderr 0 2000]"
        }
        dict for {index message} $blame {
            dict set rejected $index $message
            set live [lsearch -all -inline -not -exact $live $index]
        }
    }
    error "c-bindgen: a probe did not converge in $rounds rounds"
}

# The entries an error diagnostic of STDERR is attributed to: the probe.c
# line of the error itself or of any note that follows it (a macro's
# expansion site), LINES mapping a line to its entry.
proc ::cbind::probe::Blame {stderr lines} {
    set blame [dict create]
    set current ""
    set message ""
    foreach line [split $stderr \n] {
        if {[regexp {: (?:fatal )?error: (.*)$} $line -> msg]} {
            set current {}
            set message $msg
        }
        if {$current eq "" && $message eq ""} continue
        foreach {_ n} [regexp -all -inline {probe\.c:([0-9]+):} $line] {
            if {[dict exists $lines $n] && $message ne ""} {
                set index [dict get $lines $n]
                if {![dict exists $blame $index]} { dict set blame $index $message }
            }
        }
    }
    return $blame
}

# The values of ENTRIES (a list of {KEY {EXPR ...}}): a dict KEY -> {ok
# {VALUE ...}} (each a 64-bit word as an unsigned decimal) or {error
# MESSAGE}.
proc ::cbind::probe::values {config hprofile entries {extra ""}} {
    set prelude [Prelude $hprofile]$extra
    set make [list ::cbind::probe::ValueSource $prelude $entries]
    set live [lsearch -all [lmap e $entries {expr 1}] 1]
    lassign [Assemble $config $hprofile $make $live] asm rejected command
    set words [DataWords $asm botlish_probe_]
    set out [dict create]
    set i 0
    foreach e $entries {
        lassign $e key exprs
        if {[dict exists $rejected $i]} {
            dict set out $key [list error [dict get $rejected $i]]
        } elseif {![dict exists $words $i] || [llength [dict get $words $i]] != [llength $exprs]} {
            dict set out $key [list error "the probe's data for this entry was not found in the assembly"]
        } else {
            dict set out $key [list ok [dict get $words $i]]
        }
        incr i
    }
    return $out
}

proc ::cbind::probe::ValueSource {prelude entries live} {
    set text $prelude
    set line [llength [split $prelude \n]]
    set lines [dict create]
    foreach i $live {
        set exprs [lindex $entries $i 1]
        append text "const unsigned long long botlish_probe_$i\[\] = \{ [join [lmap e $exprs {string cat "(unsigned long long)($e)"}] {, }] \};\n"
        dict set lines $line $i
        incr line
    }
    return [list $text $lines]
}

# The 64-bit data words of every label PREFIX<N> of ASM: a dict N -> words
# (unsigned decimal, or address:SYMBOL for a relocated word). Data
# directives: .quad, .xword, .8byte, .dword, and .zero/.space runs of zero
# bytes.
proc ::cbind::probe::DataWords {asm prefix} {
    set out [dict create]
    set current ""
    foreach line [split $asm \n] {
        set t [string trim $line]
        if {[regexp "^_?${prefix}(\[0-9\]+):" $t -> n]} {
            set current $n
            dict set out $n {}
            continue
        }
        if {$current eq ""} continue
        if {[regexp {^\.(quad|xword|8byte|dword)\s+(-?(?:0x[0-9a-fA-F]+|[0-9]+))\s*(?:$|[#/;@])} $t -> _ v]} {
            dict lappend out $current [expr {$v & 0xFFFFFFFFFFFFFFFF}]
        } elseif {[regexp {^\.(quad|xword|8byte|dword)\s+(\S+)} $t -> _ v]} {
            # A relocation (an address: a pointer-valued expression), no
            # integer the compiler computed.
            dict lappend out $current address:$v
        } elseif {[regexp {^\.(zero|space)\s+([0-9]+)} $t -> _ n]} {
            for {set k 0} {$k < $n / 8} {incr k} { dict lappend out $current 0 }
        } elseif {[regexp {^[A-Za-z_.$][A-Za-z0-9_.$]*:} $t] || [regexp {^\.size\M} $t]} {
            set current ""
        }
    }
    return $out
}

# The link symbols of NAMES (C API names): a dict NAME -> {ok SYMBOL} or
# {error MESSAGE}. PREFIX is the target's user label prefix
# (__USER_LABEL_PREFIX__, "_" on Apple targets), stripped from what the
# assembler names; a symbol without it has no C-level name (an asm label
# that bypasses the prefix) and is reported so.
proc ::cbind::probe::symbols {config hprofile names prefix} {
    set prelude [Prelude $hprofile]
    set make [list ::cbind::probe::SymbolSource $prelude $names]
    set live [lsearch -all [lmap n $names {expr 1}] 1]
    lassign [Assemble $config $hprofile $make $live] asm rejected command
    set targets [dict create]
    set current ""
    foreach line [split $asm \n] {
        set t [string trim $line]
        if {[regexp {^_?botlish_sym_([0-9]+):} $t -> n]} {
            set current $n
            continue
        }
        if {$current ne "" && [regexp {^\.(quad|xword|8byte|dword)\s+([A-Za-z_.$][A-Za-z0-9_.$@]*)} $t -> _ sym]} {
            dict set targets $current $sym
            set current ""
        }
    }
    set out [dict create]
    set i 0
    foreach name $names {
        if {[dict exists $rejected $i]} {
            dict set out $name [list error [dict get $rejected $i]]
        } elseif {![dict exists $targets $i]} {
            dict set out $name [list error "no symbol in the probe's assembly"]
        } else {
            set sym [dict get $targets $i]
            if {$prefix ne "" && [string first $prefix $sym] != 0} {
                dict set out $name [list error "the assembler symbol $sym lacks the target's user label prefix \"$prefix\": it has no C-level name"]
            } else {
                dict set out $name [list ok [string range $sym [string length $prefix] end]]
            }
        }
        incr i
    }
    return $out
}

# Whether the compiler's own type of each variadic function is the
# prototype the header parser read (VARIADICS-VERTICAL-SLICE-1.md): REQUESTS
# {NAME RENDERED} pairs, RENDERED the parsed function type spelled back in C
# (::cir::render: its fixed parameters, then `...`). A dict NAME -> {ok} or
# {error MESSAGE}: one translation unit asserting __builtin_types_compatible_p
# of __typeof__(NAME) and RENDERED for every NAME, so a `va_list` parameter
# read as `...` -- or a `...` lost -- can never become a binding: the C
# compiler, not the parser, says the function is variadic.
proc ::cbind::probe::prototypes {config hprofile requests} {
    set out [dict create]
    if {[llength $requests] == 0} {
        return $out
    }
    set prelude [Prelude $hprofile]
    set make [list ::cbind::probe::PrototypeSource $prelude $requests]
    set live [lsearch -all [lmap r $requests {expr 1}] 1]
    lassign [Assemble $config $hprofile $make $live] asm rejected command
    set i 0
    foreach request $requests {
        set name [lindex $request 0]
        if {[dict exists $rejected $i]} {
            dict set out $name [list error [dict get $rejected $i]]
        } else {
            dict set out $name [list ok]
        }
        incr i
    }
    return $out
}

proc ::cbind::probe::PrototypeSource {prelude requests live} {
    set text $prelude
    set line [llength [split $prelude \n]]
    set lines [dict create]
    foreach i $live {
        lassign [lindex $requests $i] name rendered
        append text "_Static_assert(__builtin_types_compatible_p(__typeof__($name), $rendered), \"variadic prototype of $name\");\n"
        dict set lines $line $i
        incr line
    }
    return [list $text $lines]
}

proc ::cbind::probe::SymbolSource {prelude names live} {
    set text $prelude
    set line [llength [split $prelude \n]]
    set lines [dict create]
    foreach i $live {
        append text "void (*const botlish_sym_$i)(void) = (void (*)(void))&([lindex $names $i]);\n"
        dict set lines $line $i
        incr line
    }
    return [list $text $lines]
}

# The parameter attributes clang inferred for the functions SYMBOLS defined
# in the C source SOURCE (the shim), from its -O2 LLVM IR: a dict SYMBOL ->
# {list of per-parameter attribute lists}, and the IR's producer line.
# Only the attributes whose meaning the generator translates are kept:
# nocapture (and LLVM 21's captures(none)), readonly, writeonly, readnone,
# returned, in that order whatever order the IR spells them in.
proc ::cbind::probe::evidence {config hprofile source symbols} {
    lassign [::chdr::toolchain::llvm $config $hprofile $source {-w -O2}] ok ir stderr command
    if {!$ok} {
        return [list 0 $stderr {} ""]
    }
    set out [dict create]
    set producer ""
    regexp -line {^!llvm\.ident = !\{!([0-9]+)\}} $ir -> identNode
    if {[info exists identNode]} {
        regexp -line "^!$identNode = !\\{!\"(\[^\"\]*)\"\\}" $ir -> producer
    }
    foreach line [split $ir \n] {
        if {![regexp {^define [^@]*@([A-Za-z_.$][A-Za-z0-9_.$]*)\((.*)\)[^)]*\{\s*$} $line -> sym params]} continue
        if {$sym ni $symbols} continue
        set facts {}
        foreach p [SplitParams $params] {
            set kept {}
            foreach a {nocapture readonly writeonly readnone returned} {
                if {[regexp "\\m$a\\M" $p]
                        || ($a eq "nocapture" && [regexp {captures\(none\)} $p])} {
                    lappend kept $a
                }
            }
            lappend facts $kept
        }
        dict set out $sym $facts
    }
    return [list 1 "" $out $producer]
}

# The record layouts clang computes for the records NAMES (C type
# expressions: every record holding an anonymous member), after EXTRA (the
# #undefs of the layout probe): {OK BLOCKS MESSAGE}, BLOCKS the anonymous
# records' layouts, each a dict
#
#   kind    struct or union
#   file    the tail of the file clang locates it in
#   line    its line there (the struct or union keyword's), col its column
#   size    its sizeof, align its alignment (bytes)
#   members its own members, in order: {NAME OFFSET LOC}, NAME "" for an
#           unnamed member (an anonymous record, LOC its location
#           FILE:LINE:COL; an unnamed bitfield, LOC ""), OFFSET relative to
#           the record (a bitfield's byte)
#   leaves  every member name reachable through anonymous members (C11's
#           promoted names) -> its offset relative to the record
#   nested  every anonymous member's location -> its offset relative to
#           the record
#
# and nothing for a record that is not an anonymous member's (named, or a
# named member's): those are probed by C expressions. Clang dumps a record
# when it lays it out, the anonymous ones first.
proc ::cbind::probe::anonymous {config hprofile names extra} {
    set source "[Prelude $hprofile]$extra"
    if {[llength $names]} {
        append source "const unsigned long long botlish_layouts\[\] = \{ [join [lmap n $names {string cat "sizeof($n)"}] {, }] \};\n"
    }
    lassign [::chdr::toolchain::recordLayouts $config $hprofile $source] ok text stderr command
    if {!$ok} { return [list 0 {} [string range $stderr 0 2000]] }
    return [list 1 [ParseLayouts $text] ""]
}

# The anonymous-member blocks of a record layout dump TEXT (anonymous's).
proc ::cbind::probe::ParseLayouts {text} {
    set out {}
    foreach block [lrange [split [string map [list "*** Dumping AST Record Layout" \x01] $text] \x01] 1 end] {
        set lines [split [string trim $block \n] \n]
        if {![regexp {^\s*0 \| (struct|union) (.*)$} [lindex $lines 0] -> kind name]} continue
        if {![regexp {\(anonymous at ([^()]*):([0-9]+):([0-9]+)\)$} $name -> file line col]} continue
        set b [dict create kind $kind file [file tail $file] line $line col $col size "" align "" \
            members {} leaves [dict create] nested [dict create]]
        # The members, by depth: the stack holds whether each enclosing
        # member is an anonymous record (its members are this record's
        # promoted ones).
        set open {}
        foreach l [lrange $lines 1 end] {
            if {[regexp {^\s*\| \[sizeof=([0-9]+),.*\malign=([0-9]+)} $l -> size align]} {
                dict set b size $size
                dict set b align $align
                continue
            }
            if {![regexp {^\s*([0-9]+)(?::[0-9]+-[0-9]+)? \| (  +)(.*)$} $l -> offset indent rest]} continue
            set depth [expr {[string length $indent] / 2}]
            set open [lrange $open 0 [expr {$depth - 2}]]
            set name ""
            set loc ""
            if {[regexp { $} $rest]} {
                # No name: an anonymous record (its location), or an
                # unnamed bitfield.
                regexp {\((?:anonymous|unnamed) at ([^()]*):([0-9]+):([0-9]+)\) $} $rest -> f ln cl
                if {[info exists f]} { set loc "[file tail $f]:$ln:$cl"; unset f }
            } else {
                set name [lindex [split $rest " "] end]
            }
            set reachable [expr {$depth == 1 || ([llength $open] == $depth - 1 && "0" ni $open)}]
            if {$depth == 1} { dict lappend b members [list $name $offset $loc] }
            if {$reachable} {
                if {$name ne ""} {
                    if {![dict exists $b leaves $name]} { dict set b leaves $name $offset }
                } elseif {$loc ne ""} {
                    dict set b nested $loc $offset
                }
            }
            lappend open [expr {$reachable && $name eq "" && $loc ne ""}]
        }
        if {[dict get $b size] ne ""} { lappend out $b }
    }
    return $out
}

# The parameters of an LLVM define's parameter list, split at top-level
# commas.
proc ::cbind::probe::SplitParams {text} {
    set out {}
    set depth 0
    set cur ""
    foreach c [split $text ""] {
        if {$c in {( \{ [ <}} { incr depth }
        if {$c in {) \} ] >}} { incr depth -1 }
        if {$c eq "," && $depth == 0} { lappend out [string trim $cur]; set cur ""; continue }
        append cur $c
    }
    if {[string trim $cur] ne ""} { lappend out [string trim $cur] }
    return $out
}

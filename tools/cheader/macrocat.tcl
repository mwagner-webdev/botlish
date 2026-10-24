# macrocat.tcl -- what a macro means, from the preprocessor's own expansion
# (C-HEADER-ARCHAEOLOGY.md, "Macro report"; C-BINDGEN.md, "Macros").
#
# The classifiers of the header archaeology's census, shared with the
# binding generator: an object-like macro's category (a constant, an alias
# of a function, a stub-table entry, a type spelling, a fragment, ...) and a
# function-like macro's category and argument flags, both read from the
# expansion the preprocessor computed (macros.tcl's records, `expansion`
# and `arguses`, filled in by pipeline.tcl's probe). Nothing here expands a
# macro or evaluates an expression: categories are token shapes of what the
# preprocessor wrote, checked against the declaration index `ix`
# (::cir::index of the translation unit's records), which the caller sets
# before classifying.

namespace eval ::cmacro {
    variable ix {}
}

# Tokens of a macro text (for classification only; the same token shapes as
# the tokenizer).
proc ::cmacro::tokens {text} {
    regexp -all -inline {(?:L|u8|u|U)?"(?:[^"\\]|\\.)*"|(?:L|u8|u|U)?'(?:[^'\\]|\\.)*'|[A-Za-z_$][A-Za-z0-9_$]*|\.?[0-9](?:[eEpP][-+]|[A-Za-z0-9_.])*|\.\.\.|->|<<|>>|<=|>=|==|!=|&&|\|\||##|[^\sA-Za-z0-9_]} $text
}

proc ::cmacro::stripParens {toks} {
    while {[lindex $toks 0] eq "(" && [lindex $toks end] eq ")" && [::cdecl::Parenthesized $toks]} {
        set toks [lrange $toks 1 end-1]
    }
    return $toks
}

proc ::cmacro::isTypeWord {t} {
    variable ix
    expr {$t in {void char short int long float double signed unsigned _Bool struct union enum const volatile * __int128 __int8 __int16 __int32 __int64}
          || [dict exists $ix typedef $t]}
}

# The text a macro means in this profile: the preprocessor's expansion
# (macros.tcl's probe) when there is one, else the replacement as written.
proc ::cmacro::meaning {b} {
    if {[dict exists $b expansion]} { return [dict get $b expansion] }
    return [dict get $b body]
}

# The category of an object-like macro (C-HEADER-ARCHAEOLOGY.md, "Macro
# categories"), from its expansion.
proc ::cmacro::objectCategory {name b} {
    variable ix
    set e [meaning $b]
    if {$e eq ""} { return empty }
    set toks [stripParens [tokens $e]]
    if {[llength $toks] == 1} {
        set t [lindex $toks 0]
        if {[::cdecl::IntLiteral $t] ne ""} { return "constant: integer literal" }
        if {[regexp {^\.?[0-9]} $t]} { return "constant: floating literal" }
        if {[regexp {^(L|u8|u|U)?"} $t]} { return "constant: string literal" }
        if {[regexp {^(L|u8|u|U)?'} $t]} { return "constant: char literal" }
        if {[dict exists $ix function $t]} { return "alias: function" }
        if {[dict exists $ix variable $t]} { return "alias: object" }
        if {[isTypeWord $t]} { return "type spelling" }
        if {[dict exists $::cdecl::enumerators $t]} { return "constant: enumerator alias" }
        if {$t in {extern static inline __inline const volatile}} { return "decoration: storage or qualifier" }
        return "alias: undeclared identifier"
    }
    if {[llength $toks] == 2 && [lindex $toks 0] in {- +} && [::cdecl::IntLiteral [lindex $toks 1]] ne ""} {
        return "constant: integer literal"
    }
    if {[regexp {__attribute__|__declspec|__pragma|^#pragma} $e]} { return "decoration: attribute" }
    set storage 1
    foreach t $toks { if {$t ni {extern static inline __inline __inline__ const volatile}} { set storage 0 } }
    if {$storage} { return "decoration: storage or qualifier" }
    set alltype 1
    foreach t $toks { if {![isTypeWord $t] && ![regexp {^[A-Za-z_]\w*$} $t]} { set alltype 0 } }
    if {$alltype && [isTypeWord [lindex $toks 0]]} { return "type spelling" }
    if {[lindex $toks 0] eq "\{"} { return "initializer (braced)" }
    if {[topLevelComma $toks]} { return "comma list (an initializer or argument fragment)" }
    if {"\{" in $toks || ";" in $toks} { return "statement or declaration" }
    for {set i 0} {$i < [llength $toks] - 1} {incr i} {
        if {[lindex $toks [expr {$i + 1}]] eq "(" && [dict exists $ix function [lindex $toks $i]]} {
            return "expression: calls a function"
        }
    }
    if {[llength $toks] == 3 && [lindex $toks 1] eq "->" && [dict exists $ix variable [lindex $toks 0]]} {
        return "expression: a member of a global table (a stub-table entry)"
    }
    set refs 0
    foreach t $toks { if {[dict exists $ix function $t] || [dict exists $ix variable $t]} { set refs 1 } }
    if {$refs && "?" in $toks} { return "expression: selects a function or object at compile time" }
    if {$refs} { return "expression: refers to a function or object" }
    if {"sizeof" in $toks || "_Alignof" in $toks || "__alignof__" in $toks} { return "constant: expression with sizeof (needs ABI)" }
    if {"->" in $toks || "." in $toks} { return "expression: member access" }
    if {"&" in $toks && [lindex $toks 0] eq "&"} { return "expression: address of an object" }
    set ids 0
    set casts 0
    for {set i 0} {$i < [llength $toks]} {incr i} {
        set t [lindex $toks $i]
        if {[regexp {^[A-Za-z_]\w*$} $t]} {
            if {[isTypeWord $t]} { set casts 1 } elseif {[dict exists $::cdecl::enumerators $t]} { set ids 1 } else { return "expression: undeclared identifier" }
        } elseif {[::cdecl::IntLiteral $t] eq "" && [string index $t 0] ni {\" '} && $t ni {( ) | & << >> + - ~ * / % ^ ? : == != < > <= >= && || !}} {
            return other
        }
    }
    if {$casts} { return "constant: expression with casts" }
    if {$ids} { return "constant: expression over enumerators" }
    return "constant: integer expression"
}

# The category of a function-like macro, and its flags: {CATEGORY FLAGS}.
# The category comes from the preprocessor's expansion of the macro applied
# to marker arguments (run.tcl's probe), the argument flags from where the
# markers went (arguses: standalone uses, uses inside string literals,
# uses pasted into longer identifiers).
proc ::cmacro::functionCategory {name b} {
    variable ix
    set body [dict get $b body]
    set e [meaning $b]
    set params [dict get $b params]
    if {[dict get $b variadic]} { lappend params __VA_ARGS__ }
    set flags {}
    if {[dict exists $b arguses]} {
        foreach u [dict get $b arguses] {
            lassign $u p standalone strings pasted
            set plain [expr {$standalone - $strings}]
            if {$strings} { lappend flags stringify }
            if {$pasted} { lappend flags paste }
            if {$plain > 1} { lappend flags multiple-evaluation }
            if {$plain + $strings + $pasted == 0} { lappend flags unused-argument }
        }
    } else {
        if {[regexp {(^|[^#])#\s*[A-Za-z_]} $body]} { lappend flags stringify }
        if {[regexp {##} $body]} { lappend flags paste }
    }
    if {[regexp {\m(__FILE__|__LINE__|__func__|__FUNCTION__)\M} $body] || [string first "\"botlish-macro-probe\"" $e] >= 0} {
        lappend flags location-sensitive
    }
    foreach p $params {
        if {[regexp "\\(\\s*(const\\s+)?$p\\s*\\*+\\s*\\)|sizeof\\s*\\(\\s*\\*?\\s*\\(?\\s*$p\\s*\\)?\\s*\\)|\\(\\s*$p\\s*\\)\\s*\[A-Za-z_(\]|\\mtypedef\\s+$p\\M" $e]} {
            lappend flags type-generic
            break
        }
    }
    set toks [stripParens [tokens $e]]
    if {"->" in $toks || "." in $toks} { lappend flags member-access }
    if {[regexp {[^=!<>+\-*/%&|^]=[^=]|\+\+|--|[-+*/%&|^]=} $e]} { lappend flags assignment }
    if {[regexp {\(\s*\*\s*\(|\)\s*->\s*\w+\s*\)\s*\(|\(\s*\*\s*\w+\s*\)\s*\(} $e]} { lappend flags calls-through-pointer }
    if {[regexp {_Static_assert} $e]} { lappend flags compile-time-assertion }
    if {[regexp {\(\s*\{} $e]} { lappend flags gnu-statement-expression }
    set flags [lsort -unique $flags]
    if {[dict exists $b probe]} { return [list "syntax-sensitive: rejected with identifier arguments" $flags] }
    if {$e eq ""} { return [list empty $flags] }
    if {[regexp {^\s*do\s*\{.*\}\s*while\s*\(\s*0\s*\)\s*;?\s*$} $e]} { return [list statement $flags] }
    if {[topLevelSemicolon $toks]} {
        if {[isTypeWord [lindex $toks 0]] || [lindex $toks 0] in {typedef static extern inline struct union enum}} {
            return [list declaration-generating $flags]
        }
        return [list statement $flags]
    }
    if {[lindex $toks 0] eq "\{"} { return [list "initializer fragment" $flags] }
    if {[topLevelBrace $toks]} { return [list declaration-generating $flags] }
    if {[regexp {__attribute__|__declspec|__pragma} $e]} { return [list "decoration: attribute" $flags] }
    set alltype 1
    foreach t $toks { if {![isTypeWord $t] && ![regexp {^[A-Za-z_]\w*$} $t]} { set alltype 0 } }
    if {$alltype && $toks ne "" && [isTypeWord [lindex $toks 0]]} { return [list "type-producing" $flags] }
    if {[topLevelComma $toks]} { return [list "comma list (an argument or initializer fragment)" $flags] }
    set f [lindex $toks 0]
    if {[lindex $toks 1] eq "(" && [lindex $toks end] eq ")" && [::cdecl::Parenthesized [lrange $toks 1 end]]} {
        if {[dict exists $ix function $f]} {
            set inner [stripArgParens [lrange $toks 2 end-1]]
            set same [expr {$inner eq [join [dict get $b params] " , "]}]
            return [list [expr {$same ? "call wrapper: rename" : "call wrapper: computed arguments"}] $flags]
        }
        if {[regexp {^[A-Za-z_]\w*$} $f] && ![isTypeWord $f] && $f ne "sizeof"} {
            return [list "call wrapper: undeclared callee" $flags]
        }
    }
    if {"member-access" in $flags && "assignment" ni $flags} {
        return [list "expression: member access" $flags]
    }
    foreach t $toks {
        if {[dict exists $ix function $t]} { return [list "expression: calls a function" $flags] }
    }
    return [list expression $flags]
}

# The arguments of a call as text, each argument's own outer parentheses
# removed: "( a ) , ( b )" -> "a , b".
proc ::cmacro::stripArgParens {toks} {
    set args {}
    set cur {}
    set depth 0
    foreach t $toks {
        if {$t eq "," && $depth == 0} { lappend args [join [stripParens $cur] " "]; set cur {}; continue }
        if {$t in {( [ \{}} { incr depth } elseif {$t in {) ] \}}} { incr depth -1 }
        lappend cur $t
    }
    if {$cur ne ""} { lappend args [join [stripParens $cur] " "] }
    return [join $args " , "]
}

proc ::cmacro::topLevelBrace {toks} {
    set depth 0
    foreach t $toks {
        switch -- $t {
            ( - \[ { incr depth }
            ) - \] { incr depth -1 }
            \{ { if {$depth == 0} { return 1 } }
        }
    }
    return 0
}

proc ::cmacro::topLevelComma {toks} {
    set depth 0
    foreach t $toks {
        switch -- $t {
            ( - \[ - \{ { incr depth }
            ) - \] - \} { incr depth -1 }
            , { if {$depth == 0} { return 1 } }
        }
    }
    return 0
}

proc ::cmacro::topLevelSemicolon {toks} {
    set depth 0
    foreach t $toks {
        switch -- $t {
            ( - \[ - \{ { incr depth }
            ) - \] - \} { incr depth -1 }
            ; { if {$depth == 0} { return 1 } }
        }
    }
    return 0
}

# Could a generated wrapper with a declared signature stand in for the
# macro (C-HEADER-ARCHAEOLOGY.md, "Thunks")? yes, per-signature
# (type-generic: one wrapper per instantiation), no (syntax-sensitive or a
# declaration/type), or n/a (decorations, constants).
proc ::cmacro::thunkable {form category flags} {
    if {$form eq "object"} {
        switch -glob -- $category {
            constant:* { return "constant (value import, or a thunk returning it)" }
            "alias: function" { return "n/a (import the function under the alias)" }
            "alias: object" { return "n/a (import the object under the alias)" }
            "type spelling" { return "n/a (a type)" }
            "expression: a member of a global table*" { return "yes (the same-named declaration supplies the signature)" }
            "expression: refers to a function or object" - "expression: selects a function or object at compile time" { return "yes (with a declared signature)" }
            "alias: undeclared identifier" - "expression: undeclared identifier" { return "n/a (names nothing declared in this profile)" }
            "comma list*" - "initializer*" - "statement or declaration" { return "no (a fragment, not an expression)" }
            decoration* - empty* { return "n/a (erased by preprocessing)" }
            "expression: member access" - "expression: calls a function" - "expression: address of an object" { return yes }
            default { return "unclear" }
        }
    }
    switch -glob -- $category {
        syntax-sensitive* { return "no (syntax-sensitive: needs literal or identifier arguments)" }
        empty - decoration* { return "n/a (erased by preprocessing)" }
        declaration-generating { return "no (import the declarations it generates)" }
        "initializer fragment" - "comma list*" { return "no (a fragment of an initializer or argument list, not an expression)" }
        type-producing { return "n/a (a type, resolved at each use)" }
        "call wrapper: rename" { return "n/a (import the callee)" }
    }
    if {"stringify" in $flags || "paste" in $flags} { return "per identifier argument (an argument pasted or stringified is a name, not a value)" }
    if {"type-generic" in $flags} { return "per signature (type-generic)" }
    if {"location-sensitive" in $flags} { return "yes, but __FILE__/__LINE__ become the wrapper's" }
    if {$category eq "statement"} { return "yes (a void wrapper)" }
    if {$category eq "expression: member access"} { return "yes (a read; the expansion is an lvalue too: writing needs a second wrapper)" }
    if {"assignment" in $flags} { return "yes (side effects on its arguments)" }
    return yes
}


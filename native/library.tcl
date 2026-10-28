# library.tcl -- native libraries (NATIVE-LIBRARY-MILESTONE-1.md): a Botlish
# program compiled into a library a C host calls.
#
#   native::library HIR -name NAME -out DIR ?-exports NAMES? ?-shared 0|1?
#       ?-target TARGET? ?LOWERING-OPTIONS...?
#
# writes into DIR (made if missing; files of these names replaced):
#
#   libNAME.a           the static library: one relocatable object holding
#                       the program's machine code, its startup data and a
#                       private copy of the native runtime, every symbol local
#                       but the library's public C functions
#   libNAME.so          the same object linked as a shared library (-shared 1,
#                       the default)
#   NAME.h              the C interface: the types, statuses, lifecycle, error
#                       and result accessors, and one function per export
#   NAME.manifest.json  the same interface as data (manifest schema 1), from
#                       the compiler's facts: what a binding generator or a
#                       package tool reads instead of the HIR
#
# and returns a dict {static PATH shared PATH|"" header PATH manifest PATH
# exports RECORDS}, RECORDS hir::exports' records. Failures raise
# core::raiseDiagnostics errors, code {NATIVE LIBRARY KIND} with the
# location of what is refused as data, or the front end's or the driver's
# own errors.
#
# The exports are the program's `exported c fn`s (hir/exports.tcl), or with
# -exports the entry program's top-level functions NAMES, checked the same
# way. Each is NAME_FUNCTION in C. Either way the program is checked as a
# library:
#
#   * its entry file holds declarations only (LIBRARY-TOP-LEVEL): creating an
#     instance runs the program's initialization -- every imported module's
#     static initialization -- and nothing of an entry script, so a program
#     run as an executable is never run by accident as a library;
#   * it exports something (LIBRARY-NO-EXPORTS), each export's C symbol is
#     its own (LIBRARY-SYMBOL: two exports of one name, or an export named
#     like the runtime API, create, destroy, error_*, bytes_release,
#     abi_version).
#
# How the archive is made (Linux glibc, x86_64 and aarch64: native::
# capabilities' `libraries`): the driver writes the library's program object
# (botlish-native library: the program's code, descriptor and record with
# local symbols, and the public C functions over runtime::library), GNU ld
# links it with the runtime's static archive into one relocatable object
# (`ld -r`: only the runtime members it needs), objcopy keeps exactly the
# public functions global (and drops debug information), and ar archives it.
# (No `--gc-sections` there: GNU ld 2.42's relocatable link with it makes the
# Rust standard library's weak references to newer glibc functions strong,
# and a consumer's link then fails. A consumer may pass -Wl,--gc-sections
# to its own final link, which halves the runtime's text.)
# Every runtime symbol of the library is then its own: two libraries in one
# process -- built from one runtime or from two -- share no code, no state
# and no name but their public ones. The shared library is that object
# linked by `cc -shared` with the system libraries, collecting the sections
# its public functions do not reach (`-Wl,--gc-sections`).

namespace eval native::library {
    # The system libraries a consumer links a static library with: the Rust
    # standard library's on Linux glibc (rustc's native-static-libs for the
    # runtime archive). A shared library is linked with them already.
    variable systemLibraries {-lgcc_s -lutil -lrt -lpthread -lm -ldl -lc}
    # The manifest's schema revision (its "schema" member).
    variable schema 1
    # The C ABI version (runtime::library's ABI_VERSION, NAME_ABI_VERSION).
    variable abiVersion 1
    # The runtime API's public function suffixes (runtime::library's
    # FORWARDERS): an export may not take one.
    variable reserved {create destroy abi_version error_release error_status error_identity
        error_message error_field_count error_field_name error_field_type error_field_int
        error_field_bool error_field_float64 error_field_str bytes_release}
    # C keywords and the header's own names, which a parameter's C name
    # avoids.
    variable cKeywords {auto break case char const continue default do double else enum extern
        float for goto if inline int long register restrict return short signed sizeof static
        struct switch typedef union unsigned void volatile while bool true false instance result
        error}
}

proc native::library {hir args} {
    set options [dict create -name "" -out "" -shared 1 -target ""]
    set selected 0
    set names {}
    set lowering {}
    foreach {option value} $args {
        if {$option eq "-exports"} {
            set selected 1
            set names $value
        } elseif {[dict exists $options $option]} {
            dict set options $option $value
        } else {
            lappend lowering $option $value
        }
    }
    set name [dict get $options -name]
    set out [dict get $options -out]
    if {![regexp {^[A-Za-z_][A-Za-z0-9_]*$} $name]} {
        throw {NATIVE LIBRARY NAME} "native::library: the library name \"$name\" is not a C identifier (it prefixes every public C name: NAME_create)"
    }
    if {$out eq ""} {
        throw {NATIVE LIBRARY OUT} "native::library: -out DIR is required"
    }
    if {![native::hostSupports libraries]} {
        throw {NATIVE UNSUPPORTED library} "native libraries are made on Linux glibc (x86_64, aarch64) only; this host is [core::cabi::hostTarget] (NATIVE-LIBRARY-MILESTONE-1.md)"
    }
    hir::activate $hir
    set built [hir::cabi::targetOf $hir]
    set wanted [dict get $options -target]
    if {$wanted ne "" && $wanted ne [core::cabi::hostTarget]} {
        throw {NATIVE TARGET} "native::library: a library is made for this host's target ([core::cabi::hostTarget]), not $wanted"
    }
    if {$built ne "" && $built ne [core::cabi::hostTarget]} {
        throw {NATIVE TARGET} "native::library: the program was built for $built, and a library is made for this host's target ([core::cabi::hostTarget])"
    }

    set problems [library::TopLevelProblems $hir]
    if {$selected} {
        lassign [hir::exports::select $hir $names] records refused
        foreach problem $refused {
            lassign $problem function kind message
            lappend problems [list $kind "$function: $message" ""]
        }
    } else {
        set records [hir::exports::of $hir]
    }
    if {![llength $records] && ![llength $problems]} {
        lappend problems [list LIBRARY-NO-EXPORTS "the program exports nothing: declare its C exports with \"exported c fn NAME(...) -> T:\" (or name top-level functions with -exports)" ""]
    }
    set symbols [dict create]
    foreach record $records {
        set function [dict get $record name]
        if {$function in $library::reserved} {
            lappend problems [list LIBRARY-SYMBOL "the export \"$function\" would be ${name}_$function, a function of the library's runtime API: rename it" [dict get $record origin]]
        } elseif {[dict exists $symbols $function]} {
            lappend problems [list LIBRARY-SYMBOL "two exports are named \"$function\" ([library::Where $hir [dict get $symbols $function]] and [library::Where $hir $record]): each export's C symbol, ${name}_$function, is its own" [dict get $record origin]]
        }
        dict set symbols $function $record
    }
    if {[llength $problems]} {
        core::raiseDiagnostics [lmap problem $problems {
            lassign $problem kind message origin
            library::Diagnostic $hir $kind $message $origin
        }]
    }

    set lowered [lmap record $records {
        dict create symbol ${name}_[dict get $record name] block [dict get $record block] \
            params [lmap {p t} [dict get $record params] {set t}] result [dict get $record result]
    }]
    set text [nir $hir -exports $lowered {*}$lowering]
    file mkdir $out
    set work [file tempdir]
    try {
        set object [file join $work $name.program.o]
        set lines [Driver library $text $object $name]
        foreach line $lines {
            if {[lindex $line 0] eq "error"} { Outcome $lines }
        }
        set runtime [file join [file dirname [binary]] libbotlish_native.a]
        if {![file exists $runtime]} {
            throw {NATIVE NOT-BUILT} "native runtime archive missing: $runtime; run cargo build --release --manifest-path native/Cargo.toml"
        }
        set keep [file join $work $name.keep]
        set public [library::PublicNames $name $records]
        library::Write $keep [join $public \n]\n
        set linked [file join $work $name.linked.o]
        set final [file join $work $name.o]
        library::Tool ld -r -o $linked $object $runtime
        library::Tool objcopy --strip-debug --keep-global-symbols=$keep $linked $final
        set static [file join $out lib$name.a]
        file delete $static
        library::Tool ar rcs $static $final
        set shared ""
        if {[dict get $options -shared]} {
            set shared [file join $out lib$name.so]
            library::Tool cc -shared -o $shared $final -Wl,-z,defs -Wl,--gc-sections -Wl,-soname,lib$name.so \
                {*}$library::systemLibraries
        }
        set header [file join $out $name.h]
        library::Write $header [library::Header $hir $name $records]
        set manifest [file join $out $name.manifest.json]
        library::Write $manifest [library::Manifest $hir $name $records [expr {$shared ne ""}]]
    } finally {
        file delete -force $work
    }
    return [dict create static $static shared $shared header $header manifest $manifest exports $records]
}

# The entry program's top-level statements that are no declaration: a list
# of {KIND MESSAGE ORIGIN}.
proc native::library::TopLevelProblems {hir} {
    set top [dict get $hir top]
    set problems {}
    foreach e [dict get $hir roots] {
        set node [dict get $hir exprs $e]
        if {[dict get $node scope] ne $top} continue
        if {[dict get $node kind] eq "bind"} {
            set b [dict get $node binding]
            if {[dict get $hir bindings $b scope] eq $top
                    && [dict get $hir exprs [dict get $node value] kind] eq "block"} {
                continue
            }
        }
        lappend problems [list LIBRARY-TOP-LEVEL "a library's entry file holds declarations only: this top-level statement would run whenever an instance is created (move a constant or a computation into a function or an imported module)" [dict get $node origin]]
    }
    return $problems
}

# A core::raiseDiagnostics entry for the library problem KIND at ORIGIN.
proc native::library::Diagnostic {hir kind message origin} {
    set location [if {$origin ne ""} {hir::originSpan $hir $origin} else {string cat ""}]
    set text $message
    if {$location ne ""} {
        set text "[hir::originLocation $hir $origin]: $message"
    }
    return [dict create errorcode [list NATIVE LIBRARY $kind] message $text summary $message \
        location $location related {} shown $kind]
}

# Where export RECORD is declared, for messages.
proc native::library::Where {hir record} {
    set module [dict get $record module]
    return "[expr {$module eq "" ? "" : "${module}::"}][dict get $record name] at [hir::originLocation $hir [dict get $record origin]]"
}

# The library's public C names: the runtime API's and the exports'.
proc native::library::PublicNames {name records} {
    variable reserved
    return [concat [lmap suffix $reserved {string cat ${name}_$suffix}] \
        [lmap record $records {string cat ${name}_[dict get $record name]}]]
}

# Runs the build tool TOOL with ARGS (an argv list: no shell), raising its
# output on failure.
proc native::library::Tool {tool args} {
    if {[catch {exec $tool {*}$args 2>@1} output]} {
        throw [list NATIVE LIBRARY TOOL $tool] "native::library: $tool failed: $output"
    }
}

proc native::library::Write {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

# The C name of parameter PARAM: itself when it is a C identifier and no C
# keyword or header name, else argINDEX.
proc native::library::CName {param index} {
    variable cKeywords
    if {[regexp {^[A-Za-z_][A-Za-z0-9_]*$} $param] && $param ni $cKeywords && ![string match *_len $param]} {
        return $param
    }
    return arg$index
}

# The C parameters of export RECORD, after `NAME_instance *instance`.
proc native::library::CParams {name record} {
    set params [list "${name}_instance *instance"]
    set index 0
    foreach {param type} [dict get $record params] {
        set c [CName $param $index]
        switch -- $type {
            int     { lappend params "int64_t $c" }
            bool    { lappend params "bool $c" }
            float64 { lappend params "double $c" }
            str     { lappend params "const uint8_t *$c" "size_t ${c}_len" }
        }
        incr index
    }
    switch -- [dict get $record result] {
        int     { lappend params "int64_t *result" }
        bool    { lappend params "bool *result" }
        float64 { lappend params "double *result" }
        str     { lappend params "${name}_bytes *result" }
    }
    lappend params "${name}_error **error"
    return $params
}

# The Botlish declaration of export RECORD, for comments and the manifest.
proc native::library::Signature {record} {
    set types {int int bool bool float64 Float64 str str unit unit}
    set params [lmap {p t} [dict get $record params] {string cat "$p: [dict get $types $t]"}]
    set text "[dict get $record name]([join $params {, }]) -> [dict get $types [dict get $record result]]"
    if {[dict size [dict get $record errors]]} {
        set errors {}
        dict for {error fields} [dict get $record errors] {
            if {[dict size $fields]} {
                set shown [lmap {f t} $fields {string cat "$f: [dict getdef $types $t $t]"}]
                lappend errors "$error {[join $shown {, }]}"
            } else {
                lappend errors $error
            }
        }
        append text " errors [join $errors {, }]"
    }
    return $text
}

proc native::library::Header {hir name records} {
    variable abiVersion
    set N $name
    set guard [string toupper $name]_BOTLISH_H
    set entry [file tail [dict get [hir::sourceFile $hir f1] path]]
    set h "/* $N.h -- the C interface of the Botlish native library \"$N\".\n"
    append h " * Generated by the Botlish compiler from $entry (native::library,\n"
    append h " * NATIVE-LIBRARY-MILESTONE-1.md); do not edit.\n"
    append h " *\n"
    append h " * Lifecycle. ${N}_create makes an instance on the calling thread and runs the\n"
    append h " * program's initialization; every call on it, and its ${N}_destroy, must come\n"
    append h " * from that thread, one at a time, never from inside one of its own calls\n"
    append h " * (otherwise ${N}_STATUS_INVOCATION: WRONG-THREAD, REENTRANT-CALL). Instances\n"
    append h " * share nothing. A destroyed or foreign handle is refused (INVALID-INSTANCE).\n"
    append h " * Botlish code runs on the caller's thread and stack, and bounds its own\n"
    append h " * recursion there: a call whose Botlish recursion would exhaust that stack\n"
    append h " * fails with ${N}_STATUS_RUNTIME NATIVE LIMIT STACK, and the instance goes on.\n"
    append h " * No stack guard is installed in a library: C or runtime code that\n"
    append h " * exhausts the stack still ends the process.\n"
    append h " *\n"
    append h " * Calls. Every function returns a status. On ${N}_STATUS_OK the result is\n"
    append h " * written to *result; otherwise, when error is not NULL, *error receives an\n"
    append h " * error the caller owns (${N}_error_release): its status, its identity (a\n"
    append h " * declared error's canonical name, e.g. \"Rejected\" or \"module::Malformed\";\n"
    append h " * a runtime error's code, e.g. \"CORE SEMANTIC RANGE\"; a boundary or\n"
    append h " * invocation error's name), a message, and its payload's fields, typed.\n"
    append h " *\n"
    append h " * Values. int is int64_t (an Int result outside it is ${N}_STATUS_BOUNDARY\n"
    append h " * RESULT-OUT-OF-RANGE, never wrapped); bool is bool; Float64 is double (a NaN\n"
    append h " * or an infinity argument is ARGUMENT-NOT-FINITE; -0.0 enters as 0.0); str is\n"
    append h " * UTF-8: an argument is (pointer, length), NULL allowed for length 0, embedded\n"
    append h " * NULs allowed, validated (ARGUMENT-NOT-UTF8) and copied; a result is a\n"
    append h " * ${N}_bytes buffer the caller owns, NUL-terminated after its len bytes, valid\n"
    append h " * until ${N}_bytes_release -- across later calls, collections, the instance's\n"
    append h " * destruction and other libraries. Releasing a released buffer or error\n"
    append h " * through the same variable is a no-op; releasing one this library does not\n"
    append h " * hold is refused (${N}_STATUS_INVOCATION) and changes nothing.\n"
    append h " */\n"
    append h "#ifndef $guard\n#define $guard\n\n"
    append h "#include <stdbool.h>\n#include <stddef.h>\n#include <stdint.h>\n\n"
    append h "#ifdef __cplusplus\nextern \"C\" \{\n#endif\n\n"
    append h "#define ${N}_ABI_VERSION $abiVersion\n\n"
    append h "typedef struct ${N}_instance ${N}_instance;\n"
    append h "typedef struct ${N}_error ${N}_error;\n"
    append h "typedef struct ${N}_bytes \{\n    uint8_t *ptr;\n    size_t len;\n\} ${N}_bytes;\n\n"
    append h "enum \{\n"
    foreach {status value comment} {
        OK 0 {success}
        DECLARED 1 {a declared Botlish error (identity: its canonical name)}
        RUNTIME 2 {a runtime error (identity: its error code)}
        BOUNDARY 3 {an argument or result the C boundary cannot convert}
        INVOCATION 4 {a call the lifecycle or calling convention forbids}
        INTERNAL 5 {a defect of the Botlish runtime}
    } {
        append h "    ${N}_STATUS_$status = $value, /* $comment */\n"
    }
    append h "\};\n\n"
    append h "enum \{ /* ${N}_error_field_type */\n"
    foreach {type value} {INT 1 BOOL 2 FLOAT64 3 STR 4 OTHER 5} {
        append h "    ${N}_FIELD_$type = $value,\n"
    }
    append h "\};\n\n"
    append h "uint32_t ${N}_abi_version(void);\n"
    append h "int32_t ${N}_create(${N}_instance **instance, ${N}_error **error);\n"
    append h "int32_t ${N}_destroy(${N}_instance *instance);\n\n"
    append h "int32_t ${N}_error_release(${N}_error **error);\n"
    append h "int32_t ${N}_error_status(const ${N}_error *error);\n"
    append h "int32_t ${N}_error_identity(const ${N}_error *error, const uint8_t **ptr, size_t *len);\n"
    append h "int32_t ${N}_error_message(const ${N}_error *error, const uint8_t **ptr, size_t *len);\n"
    append h "size_t ${N}_error_field_count(const ${N}_error *error);\n"
    append h "int32_t ${N}_error_field_name(const ${N}_error *error, size_t index, const uint8_t **ptr, size_t *len);\n"
    append h "int32_t ${N}_error_field_type(const ${N}_error *error, size_t index);\n"
    append h "int32_t ${N}_error_field_int(const ${N}_error *error, size_t index, int64_t *value);\n"
    append h "int32_t ${N}_error_field_bool(const ${N}_error *error, size_t index, bool *value);\n"
    append h "int32_t ${N}_error_field_float64(const ${N}_error *error, size_t index, double *value);\n"
    append h "int32_t ${N}_error_field_str(const ${N}_error *error, size_t index, const uint8_t **ptr, size_t *len);\n"
    append h "int32_t ${N}_bytes_release(${N}_bytes *bytes);\n\n"
    append h "/* Exports. */\n"
    foreach record $records {
        append h "\n/* [Signature $record] */\n"
        append h "int32_t ${N}_[dict get $record name]([join [CParams $N $record] {, }]);\n"
    }
    append h "\n#ifdef __cplusplus\n\}\n#endif\n\n#endif\n"
    return $h
}

# ---------------------------------------------------------------- manifest

# JSON text of the typed value VALUE: {str TEXT} {num TEXT} {bool 0|1}
# {arr {V...}} {obj {KEY V ...}} (keys in the order given).
proc native::library::Json {value {indent ""}} {
    lassign $value type payload
    set inner "$indent  "
    switch -- $type {
        str {
            set text [string map [list \\ \\\\ \" \\\" \n \\n \r \\r \t \\t] $payload]
            return "\"$text\""
        }
        num { return $payload }
        null { return null }
        bool { return [expr {$payload ? "true" : "false"}] }
        arr {
            if {![llength $payload]} { return "\[\]" }
            return "\[\n$inner[join [lmap v $payload {Json $v $inner}] ",\n$inner"]\n$indent\]"
        }
        obj {
            if {![llength $payload]} { return "\{\}" }
            set members [lmap {k v} $payload {string cat [Json [list str $k]] ": " [Json $v $inner]}]
            return "\{\n$inner[join $members ",\n$inner"]\n$indent\}"
        }
    }
    error "native::library::Json: no JSON type $type"
}

proc native::library::S {text} { return [list str $text] }
proc native::library::N {n} { return [list num $n] }

# The C type of boundary TYPE as a parameter (a str: two words) and as a
# result's out-parameter.
proc native::library::CTypes {type} {
    return [dict get {
        int {{int64_t} {int64_t *}}
        bool {{bool} {bool *}}
        float64 {{double} {double *}}
        str {{const uint8_t *} {NAME_bytes *}}
        unit {{} {}}
    } $type]
}

proc native::library::Manifest {hir name records shared} {
    variable schema
    variable abiVersion
    variable systemLibraries
    variable reserved
    set target [core::cabi::hostTarget]
    set exports {}
    foreach record $records {
        set params {}
        foreach {param type} [dict get $record params] {
            lassign [CTypes $type] cType
            set c [list [S $cType]]
            if {$type eq "str"} {
                lappend c [S size_t]
            }
            lappend params [list obj [list name [S $param] type [S $type] c [list arr $c]]]
        }
        set result [dict get $record result]
        lassign [CTypes $result] - out
        set errors {}
        dict for {error fields} [dict get $record errors] {
            lappend errors [list obj [list name [S $error] fields [list arr [lmap {f t} $fields {
                list obj [list name [S $f] type [S $t]]
            }]]]]
        }
        lappend exports [list obj [list \
            name [S [dict get $record name]] \
            module [S [dict get $record module]] \
            symbol [S ${name}_[dict get $record name]] \
            botlish [S [Signature $record]] \
            params [list arr $params] \
            result [list obj [list type [S $result] c [S [string map [list NAME $name] $out]]]] \
            errors [list arr $errors]]]
    }
    set api [lmap suffix $reserved {S ${name}_$suffix}]
    set value [list obj [list \
        schema [N $schema] \
        kind [S botlish-native-library] \
        library [S $name] \
        abi [N $abiVersion] \
        target [list obj [list name [S $target] triple [S [dict get [core::cabi::target $target] triple]]]] \
        artifacts [list obj [list \
            static [S lib$name.a] \
            shared [if {$shared} {S lib$name.so} else {list null {}}] \
            header [S $name.h]]] \
        link [list arr [lmap l $systemLibraries {S $l}]] \
        threading [S thread-affine] \
        statuses [list obj [list ok [N 0] declared [N 1] runtime [N 2] boundary [N 3] invocation [N 4] internal [N 5]]] \
        fieldTypes [list obj [list int [N 1] bool [N 2] float64 [N 3] str [N 4] other [N 5]]] \
        types [list obj [list \
            int [list obj [list c [S int64_t] rule [S "every int64_t is an Int; an Int result outside int64_t is a BOUNDARY error RESULT-OUT-OF-RANGE"]]] \
            bool [list obj [list c [S bool]]] \
            float64 [list obj [list c [S double] rule [S "a NaN or infinite argument is a BOUNDARY error ARGUMENT-NOT-FINITE; -0.0 enters as 0.0"]]] \
            str [list obj [list c [S "const uint8_t *, size_t"] result [S ${name}_bytes] rule [S "UTF-8, validated and copied; NULL allowed for length 0; embedded NULs allowed; a result is an owned buffer, NUL-terminated after len bytes, released with ${name}_bytes_release"]]]]] \
        lifecycle [list obj [list create [S ${name}_create] destroy [S ${name}_destroy] \
            initialization [S "module static initialization only: the entry file holds declarations"]]] \
        api [list arr $api] \
        exports [list arr $exports]]]
    return "[Json $value]\n"
}

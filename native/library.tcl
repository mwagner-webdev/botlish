# library.tcl -- native libraries: a program compiled into a static (and a
# shared) library with C exports (NATIVE-LIBRARY-MILESTONE-1.md).
#
#   native::library HIR -name NAME -out DIR ?-exports {FUNCTION ...}?
#       ?-shared 0|1? ?-debug 0|1?
#
# returns a dict of what it wrote into DIR (absolute paths):
#
#   archive   libNAME.a        one relocatable object: the program's machine
#                              code, its descriptor, its C entry points and
#                              the Botlish runtime, with every symbol but the
#                              library's public C API local
#   shared    libNAME.so       the same object, linked as a shared library
#                              (-shared 1, the default)
#   header    NAME.h           the C interface
#   manifest  NAME.json        the machine-readable export manifest
#   exports   the export records (hir::exports::of, with their C symbols)
#
# A library's exports are its `exported c fn` declarations
# (hir/exports.tcl), or, with -exports, the root file's top-level functions
# it names (hir::exports::select): both are one representation, verified by
# the same rules. NAME is a C identifier: the prefix of every symbol of the
# library's public API (NAME_create, NAME_destroy, ...), and of an export's
# C symbol when its declaration states none (NAME_FUNCTION).
#
# How (every step reads the compiler's own facts, never an artifact's text):
#
#   1. The exports are checked (hir::exports::verify), and the root file is
#      checked to hold declarations only: a library has no entry script, and
#      creating an instance runs only the initialization of the modules the
#      root file imports (its functions' module bindings). A top-level
#      statement of the root file would never run, so it is refused rather
#      than ignored.
#   2. Native lowering compiles the program with the exports as independent
#      roots (native::lower::program -library -exports; hir::specialize's
#      "Export roots"), and every function that makes a Botlish call checks
#      its stack pointer (a library runs on its host's stacks).
#   3. The driver emits the program object (codegen::emit_object): the
#      program's code with every function local, its descriptor
#      (runtime::program), and the public C API (codegen::library).
#   4. The system linker combines it with the runtime's static library
#      (native/target/release/libbotlish_native.a: the runtime and Rust's
#      standard library) into one relocatable object (`ld -r`), pulling only
#      what the program uses, and objcopy makes every symbol but the public
#      API local. Two libraries in one process therefore share no symbol: each
#      has its own copy of the runtime, with its own state.
#   5. `ar` archives that object; `cc -shared` links it as a shared library.
#   6. The header and the manifest are written from the export records.
#
# Supported on Linux glibc, x86-64 and AArch64 (native::capabilities'
# `libraries`): the GNU binutils' relocatable link and symbol localization
# are the one way this milestone isolates a library. Failures raise
# {NATIVE LIBRARY ...} errors (and the export checks' diagnostics, as a
# compilation raises them).

namespace eval native {
    # The libraries a C program linking libNAME.a statically must link too:
    # the Botlish runtime's and Rust's standard library's system libraries
    # (rustc's native-static-libs for these targets).
    variable librarySystemLinks {
        linux-x86_64 {gcc_s util rt pthread m dl c}
        linux-aarch64 {gcc_s util rt pthread m dl c}
    }
    # The names of a library's public API besides its exports (codegen/
    # library.rs's FORWARDS and NAME_abi_version), after the NAME_ prefix.
    variable libraryApi {abi_version create destroy error_release error_status error_identity
        error_message error_field_count error_field_name error_field_kind error_field_int
        error_field_bool error_field_float64 error_field_str error_field_text bytes_release}
}

proc native::library {hir args} {
    variable librarySystemLinks
    variable libraryApi
    set options [hir::Options native::library {-name "" -out "" -exports {} -shared 1 -debug 0} $args]
    set name [dict get $options -name]
    if {![regexp {^[A-Za-z_][A-Za-z0-9_]*$} $name]} {
        throw {NATIVE LIBRARY NAME} "a native library's name is a C identifier (letters, digits and _, not starting with a digit), the prefix of its C symbols: \"$name\" is not one"
    }
    if {[dict get $options -out] eq ""} {
        throw {NATIVE LIBRARY OUTPUT} "native::library needs -out DIR, the directory its files are written to"
    }
    if {![hostSupports libraries]} {
        throw {NATIVE LIBRARY HOST} "native libraries are built on Linux glibc (x86_64, aarch64) only: this host is [core::cabi::hostTarget] (NATIVE-LIBRARY-MILESTONE-1.md)"
    }
    if {[hir::mode $hir] ne "program"} {
        throw {NATIVE LIBRARY ROOT} "a native library is compiled from a program, not a sequence"
    }
    hir::activate $hir
    if {[dict get $options -exports] ne {}} {
        set hir [hir::exports::select $hir [dict get $options -exports]]
        set before [llength [dict get $hir diagnostics]]
        hir::exports::verify hir
        set found [lrange [dict get $hir diagnostics] $before end]
        if {$found ne {}} {
            hir::recovery::raise $hir $found 1
        }
    }
    set records [hir::exports::of $hir]
    if {$records eq {}} {
        throw {NATIVE LIBRARY EXPORT} "a native library exports at least one function: declare one \"exported c fn\", or name one with -exports"
    }
    LibraryRootStatements $hir

    # C symbols: a stated one, else NAME_FUNCTION (the function's own name,
    # without its module).
    set taken [dict create]
    foreach api $libraryApi {
        dict set taken ${name}_$api "the library's own ${name}_$api"
    }
    set exports {}
    foreach record $records {
        set symbol [dict get $record symbol]
        if {$symbol eq ""} {
            set symbol ${name}_[namespace tail [dict get $record name]]
        }
        if {[dict exists $taken $symbol]} {
            throw {NATIVE LIBRARY SYMBOL} "exported c fn \"[dict get $record name]\" would be the C symbol $symbol, which is [dict get $taken $symbol]: state another with `named \"SYMBOL\"`"
        }
        dict set taken $symbol "exported c fn \"[dict get $record name]\"'s"
        dict set record symbol $symbol
        lappend exports $record
    }
    set lowering [lmap record $exports {
        dict create block [dict get $record block] symbol [dict get $record symbol] name [dict get $record name] \
            params [lmap p [dict get $record params] {lindex $p 1}] result [dict get $record result]
    }]
    LibraryAotReady $hir [lmap record $exports {dict get $record block}]

    set runtime [file join [file dirname [binary]] libbotlish_native.a]
    if {![file isfile $runtime]} {
        throw {NATIVE NOT-BUILT} "the native runtime library $runtime is missing: run \"cargo build --release\" in [file dirname [file dirname [file dirname $runtime]]]"
    }
    foreach tool {ld objcopy ar cc} {
        if {[auto_execok $tool] eq ""} {
            throw {NATIVE LIBRARY TOOL} "building a native library needs \"$tool\" (GNU binutils and a C compiler driver) on the PATH"
        }
    }
    set out [file normalize [dict get $options -out]]
    file mkdir $out
    set work [file tempdir [file join $out .botlish-library-]]
    try {
        set text [nir $hir -library $name -exports $lowering]
        set program [file join $work program.o]
        set lines [Driver object $text $program]
        if {![regexp {^object } [lindex $lines 0]]} {
            Outcome $lines
        }
        set combined [file join $work combined.o]
        LibraryTool ld -r -o $combined $program $runtime
        set keep [file join $work public.txt]
        set public [concat [lmap api $libraryApi {string cat ${name}_$api}] [lmap record $exports {dict get $record symbol}]]
        set channel [open $keep w]
        puts $channel [join $public \n]
        close $channel
        set object [file join $work $name.o]
        set localize [list objcopy --keep-global-symbols=$keep]
        if {![dict get $options -debug]} {
            lappend localize --strip-debug
        }
        LibraryTool {*}$localize $combined $object
        set archive [file join $work lib$name.a]
        LibraryTool ar rcD $archive $object
        set links [dict get $librarySystemLinks [core::cabi::hostTarget]]
        set programLinks [hir::foreign::links $hir]
        set written [dict create archive [file join $out lib$name.a]]
        set files [list $archive lib$name.a]
        if {[dict get $options -shared]} {
            set shared [file join $work lib$name.so]
            set command [list cc -shared -o $shared $object -Wl,-soname,lib$name.so]
            variable linkDirs
            foreach dir $linkDirs {
                lappend command -L$dir
            }
            foreach library $programLinks {
                lappend command -l$library
            }
            foreach library $links {
                lappend command -l$library
            }
            LibraryTool {*}$command
            lappend files $shared lib$name.so
            dict set written shared [file join $out lib$name.so]
        }
        set header [file join $work $name.h]
        WriteText $header [LibraryHeader $hir $name $exports]
        lappend files $header $name.h
        set manifest [file join $work $name.json]
        WriteText $manifest [LibraryManifest $hir $name $exports [concat $programLinks $links] [dict get $options -shared]]
        lappend files $manifest $name.json
        # Publish only a complete library: each file moved into place.
        foreach {from to} $files {
            file rename -force $from [file join $out $to]
        }
        dict set written header [file join $out $name.h]
        dict set written manifest [file join $out $name.json]
        dict set written exports $exports
        return $written
    } finally {
        file delete -force $work
    }
}

# Refuses a root file that has statements: its top level may declare
# functions (and types, errors, imports, C declarations), and nothing else
# runs in a library (the file header, step 1).
proc native::LibraryRootStatements {hir} {
    set top [hir::top $hir]
    foreach e [hir::roots $hir] {
        set node [dict get $hir exprs $e]
        if {[dict get $node scope] ne $top} {
            continue
        }
        if {[dict get $node kind] eq "bind" && [dict get $hir exprs [dict get $node value] kind] eq "block"} {
            continue
        }
        set where [hir::originLocation $hir [dict get $node origin]]
        throw {NATIVE LIBRARY TOP-LEVEL} "$where: a native library's root file declares and runs nothing: this statement would never run (creating an instance initializes only the modules it imports); move it into a function, or the data it binds into a module"
    }
}

# Refuses a library whose code needs a run-time representation fallback,
# exactly as native::executable refuses such an executable, analyzing the
# program with the exports ROOTS as its roots.
proc native::LibraryAotReady {hir roots} {
    set analysis [hir::specialize::analyze $hir -roots $roots]
    set failures {}
    dict for {id region} [hir::specialize::regions $hir $analysis] {
        if {[dict get $region status] eq "closed"} continue
        if {[hir::specialize::dormant $hir $analysis $id]} continue
        lappend failures "[dict get $region label]: [dict get $region status]"
        foreach blocker [dict get $region blockers] {
            lappend failures "  [hir::aot::LocationText [dict get $blocker location]]: [dict get $blocker message]"
        }
    }
    if {$failures ne ""} {
        throw {NATIVE AOT NOT-READY} "program is not AOT-ready:\n[join $failures \n]"
    }
}

# Runs the external tool COMMAND (an argv list, never a shell), or raises
# {NATIVE LIBRARY TOOL} with what it reported.
proc native::LibraryTool {args} {
    if {[catch {exec {*}$args 2>@1} output]} {
        throw {NATIVE LIBRARY TOOL} "[lindex $args 0] failed building the native library: [string trim $output]"
    }
}

proc native::WriteText {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

# A C identifier for the Botlish name NAME in a C prototype: its letters,
# digits and _ (anything else _), never a C keyword or a name the prototype
# uses itself.
proc native::CName {name} {
    set c [regsub -all {[^A-Za-z0-9_]} $name _]
    if {[regexp {^[0-9]} $c]} {
        set c _$c
    }
    if {$c in {auto bool break case char const continue default do double else enum extern float for goto
            if inline int long register restrict return short signed sizeof static struct switch typedef
            union unsigned void volatile while instance result error true false}} {
        append c _
    }
    return $c
}

# The C parameters of one export parameter: {C-TYPE NAME} pairs.
proc native::LibraryCParams {param} {
    lassign $param name rep
    set c [CName $name]
    switch -- $rep {
        int { return [list [list int64_t $c]] }
        bool { return [list [list bool $c]] }
        Float64 { return [list [list double $c]] }
        str { return [list [list {const uint8_t *} $c] [list size_t ${c}_len]] }
    }
}

# The C type of an export's result out-parameter, "" for unit.
proc native::LibraryCResult {name rep} {
    return [dict get [list int {int64_t *} bool {bool *} Float64 {double *} str "${name}_bytes *" unit ""] $rep]
}

# The C prototype of export RECORD of library NAME.
proc native::LibraryPrototype {name record} {
    set params [list "${name}_instance *instance"]
    foreach param [dict get $record params] {
        foreach pair [LibraryCParams $param] {
            lassign $pair type c
            lappend params [string map {{* } *} "$type $c"]
        }
    }
    set result [LibraryCResult $name [dict get $record result]]
    if {$result ne ""} {
        lappend params [string map {{* } *} "$result result"]
    }
    lappend params "${name}_error **error"
    return "int32_t [dict get $record symbol]([join $params {, }]);"
}

# The Botlish signature of export RECORD, for the header's comments.
proc native::LibrarySignature {record} {
    set params [lmap param [dict get $record params] {
        lassign $param pname rep
        string cat $pname ": " $rep
    }]
    set text "[dict get $record name]([join $params {, }]) -> [dict get $record result]"
    if {[dict get $record errors] ne {}} {
        append text " errors [join [dict get $record errors] {, }]"
    }
    return $text
}

# The C header of library NAME exporting EXPORTS.
proc native::LibraryHeader {hir name exports} {
    set guard [string toupper ${name}]_BOTLISH_LIBRARY_H
    set h "/* $name.h -- the C interface of the Botlish native library $name.\n"
    append h " *\n"
    append h " * Generated by the Botlish compiler (native::library; NATIVE-LIBRARY-MILESTONE-1.md\n"
    append h " * states the contract in full). Link lib$name.a (with the system libraries\n"
    append h " * $name.json lists) or lib$name.so.\n"
    append h " *\n"
    append h " * Instances. ${name}_create makes an instance: its own Botlish heap, module\n"
    append h " * state and error state, initialized by running the initialization of the\n"
    append h " * modules the library imports. Every call into an instance, and its\n"
    append h " * destruction, must come from the thread that created it; any other thread,\n"
    append h " * a call while one is running (reentrance), a handle that is no live\n"
    append h " * instance of this library, or a null pointer where one is required, is\n"
    append h " * ${name}_INVOCATION_ERROR and touches nothing. Instances of one library, and of\n"
    append h " * several libraries, share no state and may run on different threads at once.\n"
    append h " * Botlish code runs on the caller's thread and stack: recursion that would\n"
    append h " * exhaust the stack fails with the runtime error NATIVE LIMIT STACK while an\n"
    append h " * eighth of the thread's stack (at least 64 KiB, at most 1 MiB) remains; no\n"
    append h " * signal handler is installed and nothing ends the process.\n"
    append h " *\n"
    append h " * Statuses. Every function returns a status; on anything but ${name}_OK, *error\n"
    append h " * (when error is not NULL) receives an error the caller owns and releases with\n"
    append h " * ${name}_error_release: its status, its identity (a declared error's canonical\n"
    append h " * name, e.g. \"Rejected\" or \"json_tokens::Malformed\"; a runtime error's code,\n"
    append h " * e.g. \"NATIVE LIMIT STACK\"; \"BOUNDARY ...\"; \"INVOCATION ...\"), a message,\n"
    append h " * and a declared error's payload fields, as data. Nothing in it points into\n"
    append h " * Botlish memory, and it stays valid after later calls and after the\n"
    append h " * instance is destroyed. *error is NULL after a successful call.\n"
    append h " *\n"
    append h " * Types. A Botlish int is int64_t: every int64_t argument enters exactly, and an\n"
    append h " * Int result outside int64_t is ${name}_BOUNDARY_ERROR (never truncated). bool is\n"
    append h " * C's bool. Float64 is a finite double: a NaN or infinite argument is\n"
    append h " * ${name}_BOUNDARY_ERROR (and -0.0 is 0.0). A str argument is a pointer and a\n"
    append h " * length of UTF-8 bytes (NULL with length 0 is the empty string; embedded NUL\n"
    append h " * bytes are characters), validated: bytes that are not UTF-8 are\n"
    append h " * ${name}_BOUNDARY_ERROR. A str result is a ${name}_bytes the caller owns: its\n"
    append h " * bytes (UTF-8, followed by a NUL that len does not count, so data is a C string\n"
    append h " * when the text has no NUL of its own), valid until ${name}_bytes_release, after\n"
    append h " * later calls and after the instance is destroyed. A unit result has no result\n"
    append h " * parameter.\n"
    append h " *\n"
    append h " * Release. ${name}_bytes_release frees a buffer and empties the ${name}_bytes\n"
    append h " * (releasing an empty one does nothing); a buffer this library did not return,\n"
    append h " * or already took back, is ${name}_INVOCATION_ERROR and nothing is freed.\n"
    append h " * ${name}_error_release likewise for errors (NULL does nothing). Release a\n"
    append h " * result with the library that returned it.\n"
    append h " */\n"
    append h "#ifndef $guard\n#define $guard\n\n"
    append h "#include <stdbool.h>\n#include <stddef.h>\n#include <stdint.h>\n\n"
    append h "#ifdef __cplusplus\nextern \"C\" \{\n#endif\n\n"
    append h "/* The version of this C interface; ${name}_abi_version() returns the library's. */\n"
    append h "#define [string toupper $name]_ABI_VERSION 1\n\n"
    append h "typedef struct ${name}_instance ${name}_instance;\n"
    append h "typedef struct ${name}_error ${name}_error;\n"
    append h "typedef struct ${name}_bytes \{\n    uint8_t *data;\n    size_t len;\n\} ${name}_bytes;\n"
    append h "typedef struct ${name}_text \{\n    const uint8_t *data;\n    size_t len;\n\} ${name}_text;\n\n"
    append h "enum \{\n"
    append h "    ${name}_OK = 0,\n"
    append h "    ${name}_DECLARED_ERROR = 1,   /* the function failed with a declared error */\n"
    append h "    ${name}_RUNTIME_ERROR = 2,    /* a runtime error: a semantic error, NATIVE LIMIT STACK, ... */\n"
    append h "    ${name}_BOUNDARY_ERROR = 3,   /* a value that cannot cross the boundary */\n"
    append h "    ${name}_INVOCATION_ERROR = 4  /* an invalid call: handle, thread, reentrance, NULL */\n"
    append h "\};\n\n"
    append h "/* The kind of a declared error's payload field. */\n"
    append h "enum \{\n"
    append h "    ${name}_FIELD_OTHER = 0,      /* no C representation: read its text */\n"
    append h "    ${name}_FIELD_INT = 1,\n"
    append h "    ${name}_FIELD_BOOL = 2,\n"
    append h "    ${name}_FIELD_FLOAT64 = 3,\n"
    append h "    ${name}_FIELD_STR = 4\n"
    append h "\};\n\n"
    append h "int32_t ${name}_abi_version(void);\n\n"
    append h "/* Lifecycle. */\n"
    append h "int32_t ${name}_create(${name}_instance **instance, ${name}_error **error);\n"
    append h "int32_t ${name}_destroy(${name}_instance *instance);\n\n"
    append h "/* Errors. Text views stay valid until the error is released. */\n"
    append h "int32_t ${name}_error_release(${name}_error *error);\n"
    append h "int32_t ${name}_error_status(const ${name}_error *error);   /* -1: not a live error */\n"
    append h "int32_t ${name}_error_identity(const ${name}_error *error, ${name}_text *identity);\n"
    append h "int32_t ${name}_error_message(const ${name}_error *error, ${name}_text *message);\n"
    append h "size_t ${name}_error_field_count(const ${name}_error *error);\n"
    append h "int32_t ${name}_error_field_name(const ${name}_error *error, size_t index, ${name}_text *name);\n"
    append h "int32_t ${name}_error_field_kind(const ${name}_error *error, size_t index);   /* -1: no such field */\n"
    append h "int32_t ${name}_error_field_int(const ${name}_error *error, size_t index, int64_t *value);\n"
    append h "int32_t ${name}_error_field_bool(const ${name}_error *error, size_t index, bool *value);\n"
    append h "int32_t ${name}_error_field_float64(const ${name}_error *error, size_t index, double *value);\n"
    append h "int32_t ${name}_error_field_str(const ${name}_error *error, size_t index, ${name}_text *value);\n"
    append h "int32_t ${name}_error_field_text(const ${name}_error *error, size_t index, ${name}_text *text);\n\n"
    append h "/* Owned results. */\n"
    append h "int32_t ${name}_bytes_release(${name}_bytes *bytes);\n\n"
    append h "/* Exports. */\n"
    foreach record $exports {
        append h "\n/* [LibrarySignature $record] */\n"
        append h "[LibraryPrototype $name $record]\n"
    }
    append h "\n#ifdef __cplusplus\n\}\n#endif\n\n#endif\n"
    return $h
}

# The export manifest of library NAME (JSON, deterministic): everything a
# tool generating bindings needs, from the compiler's facts.
proc native::LibraryManifest {hir name exports links shared} {
    variable home
    if {[info commands ::lsp::json::write] eq ""} {
        source [file join [file dirname $home] lsp json.tcl]
    }
    set target [core::cabi::hostTarget]
    set built [hir::cabi::targetOf $hir]
    if {$built ne ""} {
        set target $built
    }
    set ctypes [dict create int int64_t bool bool Float64 double str {const uint8_t *, size_t}]
    set records {}
    foreach record $exports {
        set params {}
        foreach param [dict get $record params] {
            lassign $param pname rep
            lappend params [lsp::json::obj name [lsp::json::str $pname] type [lsp::json::str $rep] \
                c [lsp::json::arrayOf [lmap pair [LibraryCParams $param] {lsp::json::str [lindex $pair 0]}]]]
        }
        set result [dict get $record result]
        lappend records [lsp::json::obj \
            name [lsp::json::str [dict get $record name]] \
            symbol [lsp::json::str [dict get $record symbol]] \
            params [lsp::json::arrayOf $params] \
            result [lsp::json::obj type [lsp::json::str $result] \
                c [lsp::json::str [LibraryCResult $name $result]]] \
            errors [lsp::json::arrayOf [lmap e [dict get $record errors] {lsp::json::str $e}]] \
            prototype [lsp::json::str [LibraryPrototype $name $record]]]
    }
    set api [lsp::json::obj \
        abiVersion [lsp::json::str ${name}_abi_version] \
        create [lsp::json::str ${name}_create] \
        destroy [lsp::json::str ${name}_destroy] \
        errorRelease [lsp::json::str ${name}_error_release] \
        errorStatus [lsp::json::str ${name}_error_status] \
        errorIdentity [lsp::json::str ${name}_error_identity] \
        errorMessage [lsp::json::str ${name}_error_message] \
        errorFieldCount [lsp::json::str ${name}_error_field_count] \
        errorFieldName [lsp::json::str ${name}_error_field_name] \
        errorFieldKind [lsp::json::str ${name}_error_field_kind] \
        errorFieldInt [lsp::json::str ${name}_error_field_int] \
        errorFieldBool [lsp::json::str ${name}_error_field_bool] \
        errorFieldFloat64 [lsp::json::str ${name}_error_field_float64] \
        errorFieldStr [lsp::json::str ${name}_error_field_str] \
        errorFieldText [lsp::json::str ${name}_error_field_text] \
        bytesRelease [lsp::json::str ${name}_bytes_release]]
    set artifacts [list staticLibrary [lsp::json::str lib$name.a] header [lsp::json::str $name.h]]
    if {$shared} {
        lappend artifacts sharedLibrary [lsp::json::str lib$name.so]
    }
    set manifest [lsp::json::obj \
        format [lsp::json::str botlish-native-library] \
        version [lsp::json::int 1] \
        library [lsp::json::str $name] \
        abiVersion [lsp::json::int 1] \
        target [lsp::json::obj name [lsp::json::str $target] triple [lsp::json::str [dict get [core::cabi::target $target] triple]]] \
        artifacts [lsp::json::obj {*}$artifacts] \
        link [lsp::json::arrayOf [lmap l $links {lsp::json::str $l}]] \
        statuses [lsp::json::obj OK [lsp::json::int 0] DECLARED_ERROR [lsp::json::int 1] RUNTIME_ERROR [lsp::json::int 2] \
            BOUNDARY_ERROR [lsp::json::int 3] INVOCATION_ERROR [lsp::json::int 4]] \
        fieldKinds [lsp::json::obj OTHER [lsp::json::int 0] INT [lsp::json::int 1] BOOL [lsp::json::int 2] \
            FLOAT64 [lsp::json::int 3] STR [lsp::json::int 4]] \
        types [lsp::json::obj {*}[concat {*}[lmap {type c} $ctypes {list $type [lsp::json::str $c]}]] \
            unit [lsp::json::str "no result parameter"]] \
        ownership [lsp::json::obj \
            strResult [lsp::json::str "${name}_bytes owned by the caller, released with ${name}_bytes_release"] \
            error [lsp::json::str "${name}_error owned by the caller, released with ${name}_error_release"] \
            instance [lsp::json::str "created and destroyed on one thread, which every call comes from"]] \
        api $api \
        exports [lsp::json::arrayOf $records]]
    return "[PrettyJson $manifest ""]\n"
}

# The JSON text of the typed value VALUE (lsp::json's), one member or
# element per line, indented from INDENT: a manifest a person can read and
# diff, written deterministically.
proc native::PrettyJson {value indent} {
    set payload [lindex $value 1]
    set inner "$indent  "
    switch -- [lindex $value 0] {
        arr {
            if {$payload eq {}} {
                return {[]}
            }
            return "\[\n$inner[join [lmap element $payload {PrettyJson $element $inner}] ",\n$inner"]\n$indent\]"
        }
        obj {
            if {$payload eq {}} {
                return "{}"
            }
            set members {}
            dict for {key member} $payload {
                lappend members "[lsp::json::Quote $key]: [PrettyJson $member $inner]"
            }
            return "\{\n$inner[join $members ",\n$inner"]\n$indent\}"
        }
        default {
            return [lsp::json::write $value]
        }
    }
}

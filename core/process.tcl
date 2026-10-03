# process.tcl -- the process boundary: argv() (ARGV.md).
#
#   argv() -> List[String] errors InvalidArgumentEncoding
#
# An ordinary callable root native, not a magic variable or a parameter of
# the program: its result is the process argument vector *including element
# zero* (the invocation name the launching process supplied -- not
# necessarily a canonical executable path), read from a stable snapshot
# taken when the run began. Linux argument vectors are NUL-terminated byte
# strings; a Botlish String is valid Unicode, so every argument is validated
# as strict UTF-8 *when argv() is called* (never earlier: a program that
# does not call it is unaffected by malformed arguments). One argument that
# is not valid UTF-8 fails the whole call with the declared error
# InvalidArgumentEncoding, an ordinary Botlish error completion (`on
# InvalidArgumentEncoding:` handles it, a caller's `errors` clause may
# forward it): never a lossy decode, never a partial List.
#
# The raw snapshot -- the *injected argv* of the Tcl backends -- is a Tcl list
# of byte strings: each element a string whose characters are all in
# 0..255, one character per argument byte (what `encoding convertto utf-8`
# and `binary format` produce). Bytes, not text, so a harness can express
# invalid UTF-8. core::process::withArgv runs a script with a given snapshot
# (the interpreter, the Tcl compiler and -- through native::Driver -- the
# native in-process backends all read the same one); outside it the default
# is core::process::defaultArgv, so a test runner's own argv never leaks in.
# The snapshot is dynamically scoped: nothing outside withArgv's own
# duration observes it, and runs in different Tcl interpreters (threads)
# never share it.

namespace eval core::process {
    # The synthetic argument zero of a run with no injected argv.
    variable defaultArgv {botlish-runner}
    # The snapshot argv() reads: the injected argv of the enclosing
    # withArgv, else the default.
    variable current $defaultArgv
}

proc core::process::defaultArgv {} {
    variable defaultArgv
    return $defaultArgv
}

# The raw snapshot of the run in progress (a list of byte strings).
proc core::process::snapshot {} {
    variable current
    return $current
}

# The bytes of the UTF-8 encoding of TEXT, as an injectable argv element.
proc core::process::bytesOfText {text} {
    return [encoding convertto utf-8 $text]
}

# Throws unless ARGV is a valid raw vector: a list of byte strings (every
# character 0..255) none containing NUL (a Linux argument cannot).
proc core::process::Check {argv} {
    set index 0
    foreach element $argv {
        if {[regexp {[^\x01-\xff]} $element]} {
            throw {CORE PROCESS ARGV} \
                "argv element $index is not a byte string without NUL (every character must be 1..255)"
        }
        incr index
    }
}

# Runs SCRIPT (in the caller's scope) with ARGV as the process argument
# snapshot, restoring the previous snapshot afterwards however SCRIPT
# ends. Returns SCRIPT's result.
proc core::process::withArgv {argv script} {
    variable current
    Check $argv
    set saved $current
    set current $argv
    try {
        return [uplevel 1 $script]
    } finally {
        set current $saved
    }
}

# The current snapshot in the native driver's `--argv` syntax
# (native/src/main.rs): comma-separated arguments, each `x` and the hex of its
# bytes -- exact for every byte sequence, empty argument and empty vector
# included.
proc core::process::driverArgv {} {
    variable current
    return [join [lmap bytes $current {string cat x [binary encode hex $bytes]}] ,]
}

# The UTF-8 text of raw argument BYTES, or throws the Tcl error `bad` on an
# invalid sequence: strict decoding rejects exactly what Rust's
# std::str::from_utf8 does (overlong forms, surrogates, > U+10FFFF,
# truncated and stray bytes).
proc core::process::Decode {bytes} {
    return [encoding convertfrom -profile strict utf-8 $bytes]
}

# argv(): the snapshot validated and converted, all or nothing.
proc core::process::argvImpl {} {
    variable current
    set items {}
    set index 0
    foreach bytes $current {
        if {[catch {Decode $bytes} text]} {
            core::native::failDeclared InvalidArgumentEncoding \
                "argv: argument $index is not valid UTF-8"
        }
        lappend items [core::value::str $text]
        incr index
    }
    return [core::value::listOf $items]
}

core::native::declareError InvalidArgumentEncoding

core::native::register argv -arity 0 -impl core::process::argvImpl \
    -param-types {} -result-type list -runtime {process-argv string-alloc list-alloc} \
    -result-shape {element-type str} -errors InvalidArgumentEncoding

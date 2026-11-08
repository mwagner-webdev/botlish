# main.tcl -- the Botlish compiler's command line.
#
#   tclsh9.0 main.tcl [OPTION...] FILE.bot|FILE.hir|FILE.hirx|FILE.ir ...
#   tclsh9.0 main.tcl run [OPTION...] FILE [ARG...]
#                                         one program run as a command (below)
#   tclsh9.0 main.tcl -aot-run [OPTION...] FILE [-- ARG...]
#                                         one program built as a standalone
#                                         executable and run as a command
#                                         (below; AOT-RUN-MILESTONE-1.md)
#   tclsh9.0 main.tcl -help [QUERY...]
#   tclsh9.0 main.tcl -version
#   tclsh9.0 main.tcl                     (no arguments: the usage summary)
#   tclsh9.0 main.tcl add|install|update|remove|verify|package ...
#                                         the package manager (pm/pm.tcl,
#                                         PACKAGE-MANAGER-MILESTONE-1.md):
#                                         a first argument naming one of
#                                         its commands runs it, without the
#                                         compiler (no other invocation
#                                         loads it or reads a botlish.json)
#
# The options, one table (cliOptions below) that the parser, the usage
# summary and Compilerpedia's cli.options topic (tests/main-cli.test checks
# it) all follow:
#
#   -backend NAME          interp (default), compile, cranelift, cranelift-generic
#   -warnings MODE         default | off | error
#   -target NAME           the C ABI target of a .bot compilation
#   -L DIR                 a library directory for a program that calls C
#   -F DIR                 a framework directory (macOS) for one that links a
#                          framework
#   -runtime-path PATH     a directory an emitted executable's loader searches
#                          for shared libraries ($ORIGIN/lib)
#   -argv TEXT / -argv-hex HEX / -argv-none    the program's argv()
#   -code -hir -ast -aot -aot-data -aot-spec -contexts -direct -traits
#   -emit-nir -emit-clif   inspection output, before the program runs
#   -emit-native-executable / -emit-hir-interchange    build, do not run
#   -aot-run ?-aot-keep?   build the one input as a standalone executable and
#                          run it as a command (-- ARG... its arguments)
#   -native-startup POLICY the executable's startup policy: worker (default)
#                          or main-thread (macOS AArch64)
#   -emit-native-library NAME ?-export FUNCTION...? ?-out DIR?    build the
#                          native library NAME (NATIVE-LIBRARY-MILESTONE-1.md:
#                          libNAME.a, libNAME.so, NAME.h,
#                          NAME.manifest.json) from the one input; its exports
#                          are its `exported c fn`s, or the top-level
#                          functions -export names
#   -check                 analyze each .bot input, report its diagnostics,
#                          run and build nothing (the compiler service)
#   -lsp ?-lsp-scheduler worker|sync?    the language server, on stdin and
#                          stdout (no input file); -lsp-worker is its
#                          analysis worker, started by -lsp itself
#   -help [QUERY...]       Compilerpedia, the built-in reference
#                          (compilerpedia/, COMPILERPEDIA.md); everything
#                          after -help is the query
#   -version               the compiler's version and build identity
#
# Without arguments it prints the usage summary and exits 0; -help and
# -version print and exit without compiling anything (help needs neither the
# compiler nor a backend: compilerpedia/ is data). An unknown option, an
# option missing its argument, an invalid value, or options with no input
# file are usage errors: a message on stderr, exit status 2. A run exits 1
# when any input fails, 0 otherwise. A printed diagnostic with notes
# (further locations with a text of their own: where a rejected method-style
# call's candidates are declared) is followed by a "note: LOCATION: TEXT"
# line for each. Each printed diagnostic is followed,
# once per topic, by a "help: ... -help TOPIC" line naming the Compilerpedia
# topic of its rule or code (compilerpedia::topicForDiagnostic: presentation
# only, read from the catalogue, never from or into the compiler's
# diagnostics).
#
# -warnings sets the one global compiler-warning policy of a .bot compilation
# (WARNINGS-SAME-RETURN.md): default prints warnings on stderr and runs the
# program; off runs no warning pass (generated source, benchmarking); error
# rejects a program that has a warning, with the warning's own code
# (SAME-RETURN-VALUE), before any backend runs. There are no per-warning
# switches (no -Wfoo): that is intentional.
#
# -target NAME selects the C ABI target of a .bot compilation (C-ABI-TYPES.md;
# core/cabi.tcl lists linux-x86_64, linux-aarch64, macos-x86_64,
# macos-aarch64, windows-x86_64, windows-x86_64-gnu, windows-aarch64): the
# widths and signedness of std::ffi::c's integer scalars follow its data model, and
# its architecture picks the file of an architecture-specific module (std::linux::sys: the Linux
# syscall numbers and registers, LINUX-SYSCALL-TRANSPORTS.md), and its
# operating system which platform namespaces it may import (linux::* only
# for a Linux target: UNSUPPORTED-PLATFORM otherwise). The default is the
# host's. A .hirx input is a compilation for that target too: one built for
# another target is refused (HIR INTERCHANGE TARGET), never reinterpreted.
# The Tcl backends run a program built for any target; the native backends
# and -emit-native-executable only one built for the host, or one whose HIR
# is every target's (anything else is NATIVE TARGET: native code runs where
# it was built for, and a matching architecture is not a matching target).
#
# Runs the given program files and prints each program's value after a
# "== FILE (BACKEND)" header: the development view of a run, which every
# backend shows, the Tcl backends included. On the
# native backends what a program prints (std::io::print_line) goes to this
# process's standard output and error as it writes it, between its "== FILE"
# line and its value; the Tcl backends
# cannot print (io's only context makes raw syscalls). With
# -backend compile it also prints the inferred types of program-level
# bindings; -code prints the Tcl code the compiler generates; -hir prints the
# program's semantic HIR (hir::format); -ast prints the surface AST of a .bot
# file (surface::formatAst). -aot prints the closed-AOT readiness of every
# function (hir::aot::explain), and -aot-data the analysis itself as a Tcl
# dict (hir::aot::analyze), before running the program; -aot-spec prints the
# same report for every function instance call-site specialization uses,
# next to each function's semantic report (hir::specialize::explain).
# -contexts prints the program's execution-environment contexts (CONTEXTS.md,
# hir::contexts::summary): the context structs, the installations in program
# order, every function's context parameters, and the direct and transitive
# context requirements of every function that has one, each with the chain
# that explains it.
# -direct prints the program's module directness (DIRECT-MODULES.md,
# hir::direct::summary): for every module and the entry program, whether it
# is declared and inferred direct and its status (ordinary, contextualized,
# direct, provided), and every call into a direct module with the
# module-owned context that mediates it, if one does.
# -traits prints the program's traits (TRAITS.md, hir::traits::report): each
# trait and its requirements, every conformance the program relies on (which
# concrete witness satisfies which trait, through which implementation of
# each requirement), every concrete type the program declares against every
# trait (satisfied through which implementations, or why not) and every
# trait-polymorphic function with the specializations it was replaced by.
# -emit-nir prints the native backend IR the program lowers to
# (native/lower.tcl), and -emit-clif the Cranelift IR of every function (both
# need no -backend cranelift; with -backend cranelift-generic, or
# BOTLISH_NATIVE_SPECIALIZE=0, they show the unspecialized code).
# -emit-native-executable compiles closed specialized workloads to standalone
# executables beside the inputs, removing the extension (FILE.bot gives FILE;
# on Windows FILE.exe): ELF on Linux glibc (x86_64, aarch64), Mach-O on macOS
# (aarch64), PE on Windows (x86_64, MSVC's toolchain), for the host's target only,
# linked as BOTLISH_NATIVE_LINKER says (rustc, the default, everywhere; stub
# needs no toolchain and is Linux x86_64's only; system needs the host's C
# compiler driver and the runtime archive, never rustc; auto, what the
# single-file compiler uses, is system for a program that calls C and stub
# for any other: SINGLE-EXECUTABLE.md, SINGLE-EXECUTABLE-FFI-MILESTONE-1.md).
# It does not evaluate the program.
# Running the executable prints nothing but what the program writes: its value
# is never printed (PROGRAM-OUTPUT-MILESTONE-1.md); it exits 0 when the
# program completes and 1, with the error on stderr, when it fails.
# -native-startup POLICY sets the executable's startup policy
# (MAIN-THREAD-STARTUP-MILESTONE-1.md), fixed in it when it is built, never
# by the environment it later runs in: worker (the default) runs the
# program on a worker thread of its own, whose stack
# BOTLISH_NATIVE_STACK_BYTES sizes (1 GiB by default); main-thread runs it
# on the process's main thread, which a macOS graphical program needs
# (AppKit, so SDL3's Cocoa driver, works there only), with a 512 MiB stack
# the link reserves (LC_MAIN) -- for a macOS AArch64 executable only, and
# refused for any other target before anything is written. Nothing else
# changes: the program's meaning, its output, errors and exit status are the
# same under both. It is an option of -emit-native-executable only (no
# other invocation makes an executable); given twice, it must name the same
# policy.
# -emit-hir-interchange writes each .bot or .hir input's analyzed HIR in the
# HIR interchange format (HIR-INTERCHANGE.md) beside it, as FILE.hirx, without
# evaluating it; a .hirx input is run like any other, on any backend, with no
# front end at all (the same front end only). With BOTLISH_HIR_CACHE=DIR in
# the environment, a .bot input's analyzed HIR is kept in DIR and read back,
# with no front end, while the program, its modules and the front end are
# unchanged (the front-end cache, surface/cache.tcl).
#
# run FILE [ARG...] runs one program as a command (PROGRAM-OUTPUT-MILESTONE-1.md),
# as an executable built from it runs: no header and no value -- standard
# output and error are the program's own --, argv() is FILE as typed and the
# ARGs after it (every word after FILE is the program's, an option-like one
# too), and the exit status is 0 when the program completes and 1 when it is
# rejected (its diagnostics on stderr after "FILE: ") or fails at run time
# (on stderr, "MESSAGE (CODE)", as an executable writes it). It runs on the
# native backend (cranelift) unless -backend says otherwise; of the other
# options only -warnings, -target, -L and -F combine with it. The program
# cannot choose its exit status yet.
#
# -aot-run FILE [-- ARG...] (AOT-RUN-MILESTONE-1.md) is the native
# development cycle without a JIT: it builds the one input as the standalone
# executable -emit-native-executable links -- the same compilation, link plan,
# linker and startup policy (-native-startup) -- in a private directory of
# its own under the system's temporary directory, runs it, and removes the
# directory when it has ended. The program runs as a command, as `run` runs
# one: its standard input, output and error are this process's, unchanged;
# its working directory and environment are the user's; argv() is FILE as
# typed and the words after `--` (every one of them the program's, `--` and
# option-like words included); and the exit status is the program's own --
# its process's exit status (a C `exit`, 0 when it completes, 1 when it
# fails at run time), or 128+N when signal N ended it (POSIX shells' $?; a
# line on stderr names the signal, except SIGINT and SIGPIPE). A program
# that is rejected, not AOT-ready, or cannot be linked is never run: its
# diagnostics go to stderr after "FILE: " and the status is 1. A
# compilation or link that fails after an earlier success never runs the
# earlier executable: every run builds anew. -aot-keep keeps the
# directory, with the program's NIR beside the executable, and names it on
# stderr. Of the other options only -warnings, -L, -F, -native-startup and
# -target (which must be the host's: the program runs here) combine with
# it. It needs no native JIT: a distribution without one (the macOS
# application) runs `run`'s native default this way too.
#
# -check analyzes each .bot input as a compilation does and reports what it
# reports -- the same diagnostics, in the same words, the same "note:" and
# "help:" lines,
# its warnings on stderr under the -warnings policy -- without evaluating the
# program, generating native code or writing anything: through the compiler
# service (service/service.tcl, COMPILER-SERVICE-MILESTONE-1.md), the
# in-process analysis an editor's tooling shares. A file with no error prints
# "ok"; one with errors makes the run exit 1. Of the other options only
# -warnings and -target (which decide the analysis) combine with it; the
# rest run, build or inspect, and -check does none of that, so naming one
# beside it is a usage error, as is an input that is not Botlish source.
#
# -lsp runs Botlish's language server (lsp/server.tcl, LSP-MILESTONE-1.md):
# the Language Server Protocol on stdin and stdout, for an editor, with
# nothing else on stdout (its log goes to stderr). It takes no input file
# (the editor sends the documents) and analyzes what the editor opens with
# the compiler service, as -check does -- never running, building or
# writing anything -- so only -warnings and -target combine with it, and
# -lsp-scheduler NAME, which says where its analyses run: worker (the
# default; a persistent analysis worker process the server starts itself as
# `-lsp-worker`, so it keeps answering while an analysis runs) or sync (in
# its own process, the reference design). It exits 0 when the editor ends
# the session in order (shutdown, then exit) and 1 otherwise.
#
# -L DIR adds DIR to the system linker's library search path (-LDIR) for a
# program that calls C (C-FFI.md: `extern c library` and `extern c fn`), which
# the native backends and -emit-native-executable link with the libraries it
# declares; the toolchain's own search path comes first otherwise. It is also
# where a library declared `static` without a path finds its archive, before
# the toolchain's own directories (NATIVE-LINK-PLAN-MILESTONE-1.md). -F DIR
# adds DIR to Apple's ld's framework search path (-FDIR), for a program that
# declares `extern c framework`; it is passed to no other linker. Such a
# program needs the host's system linker and its libraries; one that calls no
# C needs neither.
#
# -runtime-path PATH records PATH in an executable -emit-native-executable
# links as a directory its loader searches for shared libraries (an ELF
# RUNPATH, a Mach-O LC_RPATH; PACKAGE-MANAGER-MILESTONE-2.md, "Native
# deployment"): $ORIGIN/lib on Linux, @executable_path/lib on macOS, where
# `botlish native deploy` places a target's bundled libraries, so the
# executable runs wherever its directory is moved. Windows has none (its
# loader searches the executable's own directory): the link refuses it there.
# A program compiled from a target package tree (.bot_modules/.targets/T)
# links that tree's .lib without -L, and a native backend's own run finds
# its shared libraries there.
#
# A .hir file (HIR text, e.g. examples/hir/*.hir) is read with hir::readFile;
# a .hirx file (HIR interchange) with hir::interchange::readFile;
# a .bot file (Botlish source, e.g. examples/surface/*.bot) is parsed and
# lowered to HIR with surface::readProgramFile -- its `import`s name standard
# namespaces (stdlib/) and, otherwise, the program's own modules: the .bot files
# beside it, in its directory (IMPORTS.md, "Application modules"), whatever
# the working directory. From that HIR, the interpreter
# runs the core IR it lowers to (the Tcl reference branch), the compiler
# compiles the HIR itself (core::compiler::compileHir: -code and the printed
# types are that compilation's, the code that runs) and the native backends
# lower it directly to NIR (native::evalHir): neither compiler goes through
# core IR (DIRECT-HIR-NATIVE-PATH.md). A .ir file is core IR text: it runs on
# interp and compile only, and is rejected by the native backends and by
# -emit-native-executable (use the .hir fixtures of examples/hir/ instead).
#
# -argv TEXT / -argv-hex HEX / -argv-none give the process argument vector
# `argv()` reads (core/process.tcl, ARGV.md): each -argv appends one argument
# (its UTF-8 bytes, argument zero first), each -argv-hex one argument given as
# the hex of its raw bytes (so invalid UTF-8 is expressible; the empty string
# is the empty argument), and -argv-none selects the empty vector. Without any
# of them the vector is the synthetic one-element default (`botlish-runner`),
# never this runner's own arguments. The same vector reaches every backend.
# A standalone executable ignores all three: it reads its own process
# arguments each time it runs. `run` takes none of them: the words after its
# FILE are the program's arguments.
#
# For every Block in the result (directly or as a list element) the runner
# also prints the refinements visible in the Block's captured environment, so
# blocks can serve as scope probes.

set root [file dirname [file normalize [info script]]]

# The command-line options: NAME ARGUMENT GROUP SUMMARY, ARGUMENT "" for a
# flag, SUMMARY one usage line. The parser and the usage summary read this
# table; Compilerpedia's cli.options topic documents each entry in full
# (tests/main-cli.test checks that it names every one).
set cliOptions {
    -backend NAME run {interp (default), compile, cranelift, cranelift-generic}
    -warnings MODE run {default (print them), off, error (reject)}
    -target NAME run {the C ABI target (default: the host's)}
    -L DIR run {a library directory, for a program that calls C}
    -F DIR run {a framework directory (macOS), for a program linking one}
    -runtime-path PATH build {where an executable loads shared libraries from}
    -argv TEXT argv {append the argument TEXT to argv()}
    -argv-hex HEX argv {append an argument given as hex bytes}
    -argv-none {} argv {run the program with an empty argv()}
    -aot-run {} run {build and run one input as an executable (-- ARG...)}
    -aot-keep {} run {keep -aot-run's build directory and name it}
    -emit-native-executable {} build {build a standalone executable beside each input}
    -native-startup POLICY build {the executable's thread: worker (default) or main-thread}
    -emit-hir-interchange {} build {write each input's analyzed HIR as FILE.hirx}
    -emit-native-library NAME build {build native library NAME from the one input}
    -export FUNCTION build {export a top-level function (default: exported c fns)}
    -out DIR build {the library's directory (default: the input's)}
    -check {} check {report each .bot input's diagnostics; run nothing}
    -lsp {} lsp {run the language server on stdin and stdout}
    -lsp-scheduler NAME lsp {where -lsp analyzes: worker (default) or sync}
    -lsp-worker {} lsp {(internal) the language server's analysis worker}
    -code {} inspect {the compile backend's generated Tcl code}
    -hir {} inspect {the program's semantic HIR}
    -ast {} inspect {a .bot file's surface syntax tree}
    -aot {} inspect {every function's closed-AOT readiness}
    -aot-data {} inspect {the closed-AOT analysis, as data}
    -aot-spec {} inspect {the AOT report of each specialized instance}
    -contexts {} inspect {contexts and each function's requirements}
    -direct {} inspect {each module's directness}
    -traits {} inspect {traits and conformances}
    -emit-nir {} inspect {the native IR (NIR)}
    -emit-clif {} inspect {the Cranelift IR of every function}
    -help {[QUERY...]} help {Compilerpedia, the built-in reference (offline)}
    -version {} help {the compiler's version and build identity}
}
# Spellings of -help and -version other tools taught people to type.
set cliAliases {--help -help -h -help --version -version}

# How this compiler is invoked, as messages name it: the single executable's
# own name, or tclsh9.0 main.tcl in a checkout -- as typed, so without the
# .exe Windows finds by itself.
proc cliInvocation {} {
    set name [file tail [info nameofexecutable]]
    if {$::tcl_platform(platform) eq "windows" && [string equal -nocase [file extension $name] .exe]} {
        set name [file rootname $name]
    }
    if {[info exists ::single::app]} {
        return $name
    }
    return "$name main.tcl"
}
set cliInvocation [cliInvocation]

# The package manager's commands (pm/pm.tcl, PACKAGE-MANAGER-MILESTONE-1.md):
# a first argument naming one runs the package manager, and nothing of the
# compiler is loaded. No other invocation loads the package manager or reads
# a botlish.json: compiling reads .bot_modules as it is.
set pmCommands {add install update remove verify package native}
if {[lindex $argv 0] in $pmCommands} {
    source [file join $root pm pm.tcl]
    exit [pm::cli::main $argv $cliInvocation]
}

proc usage {} {
    global cliOptions cliInvocation
    set me $cliInvocation
    set lines [list "usage: $me \[OPTION...\] FILE..." \
        "       $me run \[OPTION...\] FILE \[ARG...\]" \
        "       $me -aot-run \[OPTION...\] FILE \[-- ARG...\]" \
        "       $me -help \[QUERY...\]" \
        "       $me -version" \
        "       $me add|install|update|remove|verify|package ..." "" \
        "Compiles and runs Botlish programs: FILE.bot (source), FILE.hir (HIR text)," \
        "FILE.hirx (HIR interchange) or FILE.ir (core IR text; interp and compile only)." \
        "Each program's output is printed, then its value." \
        "run runs one program as a command: natively, with the ARGs as its arguments," \
        "its output only, exit status 0 or 1 (-backend, -warnings, -target, -L, -F)." \
        "-aot-run builds one program as a native executable and runs it as a command:" \
        "the ARGs after -- as its arguments, its output and exit status its own." "" \
        "Before writing a program, read: $me -help primer" ""]
    foreach {group heading} {run Running argv {Program arguments} build Building check {Checking (with -warnings, -target)} lsp {Language server (with -warnings, -target; no FILE)} inspect {Inspecting (printed before the program runs)} help Reference} {
        lappend lines "$heading:"
        foreach {name argument optionGroup description} $cliOptions {
            if {$optionGroup ne $group} continue
            set spelled [string trim "$name $argument"]
            if {[string length $spelled] > 18} {
                lappend lines "  $spelled" "  [string repeat " " 18]  $description"
            } else {
                lappend lines [format "  %-18s  %s" $spelled $description]
            }
        }
        lappend lines ""
    }
    lappend lines "Examples:" \
        "  $me -backend cranelift game.bot" \
        "  $me run tool.bot -n 3 < input   the program as a command" \
        "  $me -aot-run tool.bot -- -n 3   the same, as a native executable" \
        "  $me -lsp                      the language server, for an editor" \
        "  $me -help                     the indices of Compilerpedia" \
        "  $me -help cli.options         every option in detail" \
        "  $me -help KNOWN-ERROR         a diagnostic or warning code" \
        "  $me -help \"bounds proof\"      a search" \
        "  $me -help cli.packages        the package manager"
    return [join $lines \n]
}

# A usage error: MESSAGE on stderr, a pointer to the usage, exit status 2.
proc usageError {message} {
    puts stderr "$::cliInvocation: $message"
    puts stderr "run $::cliInvocation with no arguments for the usage summary, or $::cliInvocation -help cli.options"
    exit 2
}

# Parses the command line ARGV (syntax only: values are checked once the
# compiler is loaded) into a dict: action (run, help, version, usage),
# options (the given options in order, as {NAME VALUE} pairs, VALUE "" for a
# flag), files, query (the words after -help).
proc parseCommandLine {argv} {
    global cliOptions cliAliases
    set result [dict create action run options {} files {} query {} arguments {} separator 0]
    if {$argv eq ""} {
        dict set result action usage
        return $result
    }
    set table [dict create]
    foreach {name argument group description} $cliOptions {
        dict set table $name $argument
    }
    # `run [OPTION...] FILE [ARG...]`: one program, run as a command; every
    # word after FILE is one of its arguments, options included.
    set start 0
    if {[lindex $argv 0] eq "run"} {
        dict set result action program
        set start 1
    }
    for {set i $start} {$i < [llength $argv]} {incr i} {
        set arg [lindex $argv $i]
        if {[dict exists $cliAliases $arg]} {
            set arg [dict get $cliAliases $arg]
        }
        if {$arg eq "-help"} {
            dict set result action help
            dict set result query [lrange $argv [expr {$i + 1}] end]
            return $result
        }
        if {$arg eq "-version"} {
            if {$i + 1 < [llength $argv]} {
                usageError "-version takes no arguments (found \"[lindex $argv [expr {$i + 1}]]\")"
            }
            dict set result action version
            return $result
        }
        if {[dict exists $table $arg]} {
            set argument [dict get $table $arg]
            if {$argument eq ""} {
                dict lappend result options [list $arg ""]
                continue
            }
            if {$i + 1 >= [llength $argv]} {
                usageError "option $arg needs an argument ($argument)"
            }
            dict lappend result options [list $arg [lindex $argv [incr i]]]
            continue
        }
        if {$arg eq "--" && [dict get $result action] ne "program"} {
            # -aot-run FILE -- ARG...: every word after -- is the program's.
            dict set result separator 1
            dict set result arguments [lrange $argv [expr {$i + 1}] end]
            break
        }
        if {[string match -* $arg] && $arg ne "-"} {
            usageError "unknown option \"$arg\""
        }
        dict lappend result files $arg
        if {[dict get $result action] eq "program"} {
            dict set result arguments [lrange $argv [expr {$i + 1}] end]
            break
        }
    }
    if {[dict get $result action] eq "program" && [dict get $result files] eq ""} {
        usageError "run needs the program's file: run \[OPTION...\] FILE \[ARG...\]"
    }
    if {[dict get $result files] eq "" && [lspMode $result] eq ""} {
        usageError "no input file"
    }
    return $result
}

# -lsp or -lsp-worker when COMMANDLINE (parseCommandLine's) names one, else "".
proc lspMode {commandLine} {
    set mode ""
    foreach option [dict get $commandLine options] {
        if {[lindex $option 0] in {-lsp -lsp-worker}} {
            set mode [lindex $option 0]
        }
    }
    return $mode
}

# The -version text: what this build is, from the information that exists
# (no release version number does): the source revision (the single
# executable's packaged BUILD file, or git in a checkout), the front end's
# identity (the HIR interchange fingerprint, HIR-INTERCHANGE.md), Tcl, and
# the native backend's state.
proc versionText {} {
    global root
    set lines [list "Botlish compiler (no release version; this is a development build)"]
    set revision unknown
    set build [file join $root BUILD]
    if {[file isfile $build]} {
        set channel [open $build]
        foreach line [split [read $channel] \n] {
            if {[regexp {^commit (.+)$} $line -> commit]} {
                set revision "$commit, packaged"
            }
        }
        close $channel
    } elseif {![catch {exec git -C $root rev-parse --short HEAD 2>/dev/null} commit]} {
        set dirty [expr {[catch {exec git -C $root status --porcelain --untracked-files=no 2>/dev/null} status] || $status ne "" ? " (modified)" : ""}]
        set revision "$commit$dirty"
    }
    lappend lines "source revision: $revision"
    lappend lines "front end: [hir::interchange::fingerprint]"
    lappend lines "Tcl: [info patchlevel]"
    if {[info exists ::single::app]} {
        lappend lines "native backend: packaged ([string trim [core::ReadFile [file join $::single::app native-bin ID]]])"
    } elseif {[catch {native::binary} path]} {
        lappend lines "native backend: not built (cargo build --release --manifest-path native/Cargo.toml)"
    } else {
        lappend lines "native backend: $path"
    }
    # Whether the native backend runs programs in-process (native::
    # jitAvailable): a distribution without the JIT runs them natively as
    # executables (-aot-run).
    if {![catch {native::jitAvailable} jit]} {
        lappend lines "native JIT: [if {$jit} {set _ available} else {set _ {unavailable (programs run natively as executables: -aot-run)}}]"
    }
    lappend lines "invocation: $::cliInvocation"
    return [join $lines \n]
}

# Runs SCRIPT, which prints, and exits with its result (STATUS when it
# returns nothing). A reader that stops early (-help errors | head) ends the
# output quietly, not with a write error.
proc printing {script {status 0}} {
    if {[catch {set result [uplevel 1 $script]; flush stdout} message options]} {
        if {[lrange [dict get $options -errorcode] 0 1] eq {POSIX EPIPE}} {
            exit 0
        }
        puts stderr [dict get $options -errorinfo]
        exit 1
    }
    exit [if {$result eq ""} {set status} else {set result}]
}

set commandLine [parseCommandLine $argv]
switch -- [dict get $commandLine action] {
    usage {
        printing {puts [usage]}
    }
    help {
        source [file join $root compilerpedia compilerpedia.tcl]
        printing {compilerpedia::main [dict get $commandLine query]}
    }
    program {
        # `run` runs one program as a command: of the options only those
        # that decide how it compiles and links. Anything else inspects,
        # builds or checks, which a run as a command never does: refused,
        # never ignored.
        foreach option [dict get $commandLine options] {
            set arg [lindex $option 0]
            if {$arg ni {-backend -warnings -target -L -F}} {
                usageError "run cannot be combined with $arg: it runs one program as a command, its standard output and error the program's own (it takes -backend, -warnings, -target, -L and -F; the program's arguments follow its file)"
            }
        }
    }
}

# -lsp: the language server, and -lsp-worker, its analysis worker
# (lsp/server.tcl, lsp/worker.tcl, LSP-MILESTONE-1.md). Both speak a
# protocol on stdin and stdout and analyze with the compiler service: they
# load the front end and no backend, take no input file, and of the other
# options only -warnings and -target, which decide the analysis (and
# -lsp-scheduler, which says where -lsp analyzes). Anything else is refused,
# never ignored.
if {[set lspMode [lspMode $commandLine]] ne "" && [dict get $commandLine action] eq "run"} {
    set lspOptions [dict create]
    foreach option [dict get $commandLine options] {
        lassign $option arg value
        if {$arg ni {-lsp -lsp-worker -lsp-scheduler -warnings -target}} {
            usageError "$lspMode cannot be combined with $arg: the language server analyzes the programs an editor opens, without running, building or inspecting them (it takes -warnings, -target and -lsp-scheduler)"
        }
        if {$arg in {-lsp -lsp-worker} && $arg ne $lspMode} {
            usageError "-lsp and -lsp-worker cannot be combined"
        }
        if {$arg eq "-lsp-scheduler" && $lspMode ne "-lsp"} {
            usageError "-lsp-scheduler is an option of -lsp"
        }
        dict set lspOptions $arg $value
    }
    if {[dict get $commandLine files] ne ""} {
        usageError "$lspMode takes no input file: the editor sends the documents (found \"[lindex [dict get $commandLine files] 0]\")"
    }
    if {[dict exists $lspOptions -lsp-scheduler] && [dict get $lspOptions -lsp-scheduler] ni {worker sync}} {
        usageError "unknown language server scheduler \"[dict get $lspOptions -lsp-scheduler]\" (known: worker sync)"
    }
    if {[dict exists $lspOptions -warnings] && [dict get $lspOptions -warnings] ni {default off error}} {
        usageError "unknown warnings mode \"[dict get $lspOptions -warnings]\" (known: default off error)"
    }
    source [file join $root lsp lsp.tcl]
    if {[dict exists $lspOptions -target] && ![core::cabi::isTarget [dict get $lspOptions -target]]} {
        usageError "unknown C ABI target \"[dict get $lspOptions -target]\" (known: [join [core::cabi::targetNames] {, }])"
    }
    set analysis [dict create -warnings [dict getdef $lspOptions -warnings [hir::warnings::defaultMode]] \
        -target [dict getdef $lspOptions -target ""]]
    if {$lspMode eq "-lsp"} {
        lsp::server::main {*}$analysis -scheduler [dict getdef $lspOptions -lsp-scheduler worker]
    } else {
        lsp::worker::main {*}$analysis
    }
}

source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
if {[dict get $commandLine action] eq "version"} {
    printing {puts [versionText]}
}
# The Tcl backends evaluate a Botlish call as nested Tcl evaluations: run
# programs under the entry points' recursion limit (core/core.tcl), not
# tclsh's default 1000, which ends an interpreted recursion ~140 calls deep.
core::useProgramRecursionLimit

# Prints the error MESSAGE (OPTIONS: its return options) to CHANNEL as
# "PREFIXMESSAGE (ERRORCODE)" -- one such line per diagnostic when a rejected
# compilation reports several (core::raiseDiagnostics, DIAGNOSTIC-RECOVERY.md).
proc printError {channel prefix message options} {
    if {[dict exists $options -diagnostics]} {
        foreach diagnostic [dict get $options -diagnostics] {
            puts $channel "$prefix[dict get $diagnostic message] ([core::ShownCode $diagnostic])"
            printNotes $channel $prefix [lmap n [dict getdef $diagnostic notes {}] {dict get $n message}]
            helpHint $channel $prefix [core::ShownCode $diagnostic] [dict get $diagnostic message]
        }
        return
    }
    puts $channel "$prefix$message ([dict get $options -errorcode])"
    helpHint $channel $prefix [dict get $options -errorcode] $message
}

# After a printed diagnostic, a line "PREFIXnote: TEXT" for each of its
# notes (TEXTS, each located: core::raiseDiagnostics), PREFIX's "error"
# word replaced, its indentation kept.
proc printNotes {channel prefix texts} {
    regsub {[^ ].*$} $prefix "" indent
    foreach text $texts {
        puts $channel "${indent}note: $text"
    }
}

# After a printed diagnostic of error code CODE and MESSAGE, the line
# "PREFIXhelp: ... -help TOPIC" naming the Compilerpedia topic of its rule or
# code (compilerpedia::topicForDiagnostic), once per topic for each input
# file (hintsShown, reset by runFile and the emit procs). Presentation only:
# the topic is looked up in the catalogue from the printed code and text, and
# nothing of the compiler's diagnostics changes.
set hintsShown {}
proc helpHint {channel prefix code message} {
    global root hintsShown
    if {[info commands compilerpedia::topicForDiagnostic] eq ""} {
        source [file join $root compilerpedia compilerpedia.tcl]
    }
    set topic [compilerpedia::topicForDiagnostic $code $message]
    if {$topic eq "" || $topic in $hintsShown} {
        return
    }
    lappend hintsShown $topic
    regsub {[^ ].*$} $prefix "" indent
    puts $channel "${indent}help: $::cliInvocation -help $topic"
}

# After a compilation that printed warnings (on stderr), the topic of each
# distinct warning code of CODES (the warnings' codes), once.
proc warningHints {codes} {
    global root hintsShown
    set codes [lsort -unique $codes]
    if {$codes eq ""} {
        return
    }
    if {[info commands compilerpedia::topicForDiagnostic] eq ""} {
        source [file join $root compilerpedia compilerpedia.tcl]
    }
    foreach code $codes {
        set topic [compilerpedia::topicForDiagnostic $code ""]
        if {$topic ne "" && $topic ni $hintsShown} {
            lappend hintsShown $topic
            puts stderr "help: $::cliInvocation -help $topic"
        }
    }
}

proc probeValues {value} {
    switch -- [core::value::kind $value] {
        block   { return [list $value] }
        list    { return [lsearch -all -inline -index 0 [core::value::items $value] block] }
        default { return {} }
    }
}

# The display of the program value VALUE: core::value::show's, with every
# DecimalRounded value it holds rounded to the precision its static type
# guarantees (hir::decimal::Display), the type of HIR's final expression,
# when HIR ("" for core IR text) says one.
proc ShowResult {hir value} {
    if {$hir eq "" || [hir::roots $hir] eq ""} {
        return [core::value::show $value 1]
    }
    return [hir::decimal::Display $value [hir::typeOf $hir [lindex [hir::roots $hir] end]]]
}

proc runFile {path showCode showHir showAst showAot showNative} {
    global backend nativeBackends warnings target showContexts showDirect showTraits hintsShown
    set hintsShown {}
    puts "== [file tail $path] ($backend)"
    set hir ""
    set extension [file extension $path]
    if {$extension eq ".bot"} {
        # Parse with recovery first, so every syntax error is reported (the
        # text as every compilation reads it, surface/source.tcl; the AST
        # kept for the compilation's own parse, surface::modules::Parse).
        set ast [surface::modules::Parse $path [surface::source::text $path]]
        if {$showAst} {
            puts [surface::formatAst $ast]
        }
        if {[dict get $ast diagnostics] ne ""} {
            foreach diagnostic [dict get $ast diagnostics] {
                puts "   error: [dict get $diagnostic file]:[dict get $diagnostic line]:[dict get $diagnostic column]: [dict get $diagnostic message] (SURFACE SYNTAX)"
                helpHint stdout "   " {SURFACE SYNTAX} [dict get $diagnostic message]
            }
            return 1
        }
    }
    if {$extension in {.hir .hirx .bot}} {
        if {$extension eq ".hir"} {
            set hir [hir::readFile $path]
        } elseif {$extension eq ".hirx"} {
            if {[catch {hir::interchange::readFile $path -target [hir::cabi::ResolveTarget $target]} hir options]} {
                printError stdout "   error: " $hir $options
                return 1
            }
        } elseif {[catch {surface::readProgramFile $path -warnings $warnings -target $target} hir options]} {
            printError stdout "   error: " $hir $options
            return 1
        } else {
            warningHints [lmap w [hir::warnings::of $hir] {dict get $w code}]
        }
        # Core IR is only produced for the branch that consumes it, the
        # interpreter. The Tcl compiler compiles the HIR once (below), for
        # running, -code and the printed types alike.
        set program ""
        if {$backend eq "interp"} {
            set program [hir::lower $hir]
        }
        # A native run writes what the program prints to this process's own
        # standard output and error, before the value line below, as a
        # standalone executable does.
        set run [dict get {
            compile   {core::compiler::evalUnit $unit}
            cranelift {native::evalHir $hir -output inherit}
            cranelift-generic {native::evalHir $hir -specialize 0 -output inherit}
            interp    {core::evalProgram $program}
        } $backend]
    } else {
        if {$backend in $nativeBackends || $showNative ne ""} {
            printError stdout "   error: " "$path is core IR text; native compilation starts from HIR (.bot or .hir), never core IR" {-errorcode {NATIVE AOT INPUT}}
            return 1
        }
        set program [core::loadProgramFile $path]
        set run {core::evalProgram $program}
    }
    if {$showHir || $showAot ne "" || $showNative ne "" || $showContexts || $showDirect || $showTraits} {
        if {$hir ne ""} {
            set shownHir $hir
        } else {
            set shownHir [hir::build $program -strict 0]
        }
    }
    if {$showHir} {
        puts [hir::format $shownHir]
    }
    if {$showTraits} {
        puts [hir::traits::report $shownHir]
    }
    if {$showDirect} {
        puts [hir::direct::summary $shownHir]
    }
    if {$showContexts} {
        puts [hir::contexts::summary $shownHir]
        if {[dict exists $shownHir contexts]} {
            foreach b [dict get $shownHir contexts blocks] {
                foreach id [hir::contexts::required $shownHir $b] {
                    puts "why [hir::contexts::BlockName $shownHir $b] requires $id:"
                    puts [hir::contexts::explain $shownHir $b $id]
                }
            }
        }
        if {[dict exists $shownHir traitSource contexts]} {
            # Context-trait requirements (CONTEXT-TRAITS.md) exist in the
            # checked source program only: explain them there.
            set source [dict get $shownHir traitSource]
            foreach b [dict get $source contexts blocks] {
                foreach id [hir::contexts::required $source $b] {
                    if {![hir::contexts::isTrait $id]} continue
                    puts "why [hir::contexts::BlockName $source $b] requires $id:"
                    puts [hir::contexts::explain $source $b $id]
                }
            }
        }
    }
    switch -- $showAot {
        text { puts [hir::aot::explain $shownHir] }
        data { puts [hir::aot::analyze $shownHir] }
        spec { puts [hir::specialize::explain $shownHir] }
    }
    # A .bot/.hir/.hirx program: the Tcl compiler's one compilation of its HIR.
    set compiled [expr {$extension in {.hir .hirx .bot} && ($backend eq "compile" || $showCode)}]
    if {$compiled && [catch {core::compiler::compileHir $hir} unit options]} {
        printError stdout "   error: " $unit $options
        return 1
    }
    if {$showCode} {
        puts [if {$compiled} {dict get $unit code} else {core::compiler::generatedCode $program}]
    }
    set nativeOptions [expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
    if {$showNative ne "" && [catch {
        switch -- $showNative {
            nir  { puts -nonewline [native::nir $shownHir {*}$nativeOptions] }
            clif { puts [native::clif $shownHir {*}$nativeOptions] }
        }
    } message options]} {
        printError stdout "   error: " $message $options
        return 1
    }
    if {[catch {core::process::withArgv $::injectedArgv $run} value options]} {
        printError stdout "   error: " $value $options
        return 1
    }
    puts "   value: [ShowResult $hir $value]"
    if {$backend eq "compile"} {
        dict for {name type} [if {$compiled} {dict get $unit types} else {core::compiler::programTypes $program}] {
            puts "   type:  $name : [hir::types::show $type]"
        }
    }
    set index 0
    foreach probe [probeValues $value] {
        set shown {}
        dict for {name facts} [core::envRefinements [core::blockEnv $probe]] {
            lappend shown "$name : [join [lmap fact $facts {core::type::show $fact}] {, }]"
        }
        if {$shown eq ""} {
            set shown [list (none)]
        }
        puts "   block #$index refinements: [join $shown {; }]"
        incr index
    }
    return 0
}

# Runs the program PATH as a command (`run`, PROGRAM-OUTPUT-MILESTONE-1.md):
# what an executable built from it does when it runs. Standard output and
# error are the program's own -- no header, and the program's value is never
# printed -- its argv() is the injected vector (PATH and the arguments after
# it), and it returns the exit status: 0 when the program completes, 1 when
# it is rejected (each diagnostic on stderr after "PATH: ", as a build
# reports it) or fails at run time (on stderr as an executable reports it,
# "MESSAGE (CODE)"). The Tcl backends run it too, though they cannot print
# (the only std::io contexts are native: POST-2048-PRODUCT-FIXES.md, S15).
proc runProgram {path} {
    global backend nativeBackends warnings target hintsShown
    set hintsShown {}
    if {[catch {
        set extension [file extension $path]
        if {$extension in {.hir .hirx .bot}} {
            switch -- $extension {
                .bot {
                    set hir [surface::readProgramFile $path -warnings $warnings -target $target]
                    warningHints [lmap w [hir::warnings::of $hir] {dict get $w code}]
                }
                .hir { set hir [hir::readFile $path] }
                .hirx { set hir [hir::interchange::readFile $path -target [hir::cabi::ResolveTarget $target]] }
            }
            switch -- $backend {
                interp {
                    set program [hir::lower $hir]
                    set run {core::evalProgram $program}
                }
                compile {
                    set unit [core::compiler::compileHir $hir]
                    set run {core::compiler::evalUnit $unit}
                }
                cranelift { set run {native::evalHir $hir -output inherit} }
                cranelift-generic { set run {native::evalHir $hir -specialize 0 -output inherit} }
            }
        } elseif {$backend in $nativeBackends} {
            throw {NATIVE AOT INPUT} "$path is core IR text; native compilation starts from HIR (.bot or .hir), never core IR (run it with -backend interp or compile)"
        } else {
            set program [core::loadProgramFile $path]
            set run {core::evalProgram $program}
        }
    } message options]} {
        printError stderr "$path: " $message $options
        return 1
    }
    if {[catch {core::process::withArgv $::injectedArgv $run} message options]} {
        puts stderr "$message ([dict get $options -errorcode])"
        return 1
    }
    return 0
}

# The analyzed HIR of the program file PATH (.bot, .hir or .hirx) for a
# native build: a .bot file's warnings printed as a compilation prints them.
# Core IR text has no native path: {NATIVE AOT INPUT}.
proc nativeProgramHir {path} {
    global warnings target
    switch -- [file extension $path] {
        .bot {
            set hir [surface::readProgramFile $path -warnings $warnings -target $target]
            warningHints [lmap w [hir::warnings::of $hir] {dict get $w code}]
            return $hir
        }
        .hir { return [hir::readFile $path] }
        .hirx { return [hir::interchange::readFile $path -target [hir::cabi::ResolveTarget $target]] }
        default { throw {NATIVE AOT INPUT} "expected a .bot, .hir or .hirx input file (native executables are built from HIR, never from core IR text): $path" }
    }
}

# The environment a program run as a command gets that this process does
# not have (native::aotRun's -environment): a packaged compiler's own
# settings (single/main.tcl's ::single::userEnvironment: the variables it
# set for its native backend, as the user had them), nothing in a checkout.
proc childEnvironment {} {
    if {[info exists ::single::userEnvironment]} {
        return $::single::userEnvironment
    }
    return {}
}

# The exit status of this process for a child's exit code CODE: on Windows
# an exit code is 32 bits, which Tcl's exit takes as a signed integer.
proc childExitStatus {code} {
    if {$code > 0x7fffffff} {
        return [expr {$code - 0x100000000}]
    }
    return $code
}

# Builds the program PATH as a standalone executable and runs it as a
# command (-aot-run, native::aotRun, AOT-RUN-MILESTONE-1.md): its argv() the
# injected vector (PATH and the arguments after --), its standard streams,
# working directory and environment the user's. Returns the program's exit
# status -- its process's exit code, or 128+N for signal N (a line on stderr
# names the signal, unless it is SIGINT or SIGPIPE, as a shell says nothing
# of those) -- or 1 when it is rejected, not AOT-ready, cannot be linked or
# cannot be started (each diagnostic on stderr after "PATH: "), and then
# nothing ran. With -aot-keep a line on stderr names the build directory.
proc aotRunProgram {path} {
    global hintsShown nativeStartup aotKeep
    set hintsShown {}
    if {[catch {
        set hir [nativeProgramHir $path]
        set result [core::process::withArgv $::injectedArgv {
            native::aotRun $hir [file rootname [file tail $path]] -startup $nativeStartup -keep $aotKeep \
                -environment [childEnvironment]
        }]
    } message options]} {
        printError stderr "$path: " $message $options
        return 1
    }
    if {[dict exists $result kept]} {
        puts stderr "$path: -aot-keep: the build directory [dict get $result kept] is kept (the executable [dict getdef $result executable {(none: it was not linked)}])"
    }
    set status [dict get $result status]
    switch -- [lindex $status 0] {
        exit {
            return [childExitStatus [lindex $status 1]]
        }
        signal {
            lassign $status - number name
            if {$name ni {SIGINT SIGPIPE}} {
                puts stderr "$path: the program was ended by signal $number ($name)"
            }
            return [expr {128 + $number}]
        }
        interrupted {
            lassign $status - number name
            puts stderr "$path: interrupted ([if {$name eq "parent"} {set _ "its command ended"} else {set name}]) before the program started: nothing ran"
            return [if {$number > 0} {expr {128 + $number}} else {set _ 1}]
        }
    }
    puts stderr "$path: the native backend reported an unknown status: $status (NATIVE BUG)"
    return 1
}

# Writes the analyzed HIR of the .bot or .hir file PATH in the HIR
# interchange format, as PATH without its extension plus .hirx.
proc emitInterchange {path} {
    global warnings target hintsShown
    set hintsShown {}
    if {[catch {
        switch -- [file extension $path] {
            .bot {
                set hir [surface::readProgramFile $path -warnings $warnings -target $target]
                warningHints [lmap w [hir::warnings::of $hir] {dict get $w code}]
            }
            .hir { set hir [hir::readFile $path] }
            default { throw {HIR INTERCHANGE INPUT} "expected a .bot or .hir input file: $path" }
        }
        hir::interchange::writeFile [file rootname $path].hirx $hir
    } message options]} {
        printError stderr "$path: " $message $options
        return 1
    }
    puts "hir interchange: [file rootname $path].hirx"
    return 0
}

# Analyzes the .bot file PATH without running or building it (-check), in
# the compiler service's workspace checkWorkspace, and prints what a
# compilation of it reports: each error as runFile prints a rejected
# program's, each warning on stderr as the compilation would, with the same
# help lines; "ok" when it has no error. Returns 1 for a program with errors.
proc checkFile {path} {
    global checkWorkspace hintsShown
    set hintsShown {}
    puts "== [file tail $path] (check)"
    if {[catch {service::analyze $checkWorkspace $path} revision options]} {
        printError stdout "   error: " $revision $options
        return 1
    }
    try {
        set warnings [service::diagnostics $revision -severity warning]
        foreach warning $warnings {
            puts stderr [dict get $warning text]
        }
        warningHints [lmap w $warnings {dict get $w code}]
        set errors [service::diagnostics $revision -severity error]
        foreach error $errors {
            puts "   error: [dict get $error text] ([dict get $error code])"
            printNotes stdout "   " [lmap n [dict get $error notes] {dict get $n text}]
            helpHint stdout "   " [dict get $error code] [dict get $error text]
        }
    } finally {
        service::release $revision
    }
    if {$errors ne {}} {
        return 1
    }
    puts "   ok"
    return 0
}

# Builds native library NAME from PATH into DIR (native::library): its
# exports are the program's `exported c fn`s, or EXPORTS (top-level function
# names) when given.
proc emitLibrary {path name exports dir} {
    global warnings target hintsShown
    set hintsShown {}
    if {[catch {
        switch -- [file extension $path] {
            .bot {
                set hir [surface::readProgramFile $path -warnings $warnings -target $target]
                warningHints [lmap w [hir::warnings::of $hir] {dict get $w code}]
            }
            .hirx { set hir [hir::interchange::readFile $path -target [hir::cabi::ResolveTarget $target]] }
            default { throw {NATIVE LIBRARY INPUT} "expected a .bot or .hirx input file (a native library is built from source or its HIR interchange): $path" }
        }
        if {$dir eq ""} {
            set dir [file dirname $path]
        }
        set options [list -name $name -out $dir]
        if {[llength $exports]} {
            lappend options -exports $exports
        }
        set built [native::library $hir {*}$options]
    } message options]} {
        printError stderr "$path: " $message $options
        return 1
    }
    foreach artifact {static shared header manifest} {
        if {[dict get $built $artifact] ne ""} {
            puts "$artifact: [dict get $built $artifact]"
        }
    }
    return 0
}

proc emitExecutable {path} {
    global warnings target hintsShown
    set hintsShown {}
    if {[catch {
        switch -- [file extension $path] {
            .bot {
                set hir [surface::readProgramFile $path -warnings $warnings -target $target]
                warningHints [lmap w [hir::warnings::of $hir] {dict get $w code}]
            }
            .hir { set hir [hir::readFile $path] }
            .hirx { set hir [hir::interchange::readFile $path -target [hir::cabi::ResolveTarget $target]] }
            default { throw {NATIVE AOT INPUT} "expected a .bot, .hir or .hirx input file (native executables are built from HIR, never from core IR text): $path" }
        }
        set executable [native::executable $hir [file rootname $path] -startup $::nativeStartup]
    } message options]} {
        printError stderr "$path: " $message $options
        return 1
    }
    puts "executable: $executable"
    return 0
}

set nativeBackends {cranelift cranelift-generic}
set backend [core::useBackend]
if {[dict get $commandLine action] eq "program"} {
    # A program run as a command runs as its executable would: natively,
    # unless -backend says otherwise.
    set backend cranelift
}
set files [dict get $commandLine files]
set warnings [hir::warnings::defaultMode]
set target ""
set showCode 0
set showHir 0
set showContexts 0
set showDirect 0
set showTraits 0
set showAst 0
set showAot ""
set showNative ""
set injectedArgv [core::process::defaultArgv]
set injectedArgvGiven 0
set libraryName ""
set libraryExports {}
set libraryDir ""
set nativeStartup ""
set aotRun 0
set aotKeep 0
set backendGiven 0
set check 0
foreach option [dict get $commandLine options] {
    lassign $option arg value
    if {$arg eq "-check"} {
        set check 1
    }
}
if {$check} {
    # -check analyzes; every option but the analysis's own runs, builds or
    # inspects, which it never does: refused, never ignored.
    foreach option [dict get $commandLine options] {
        set arg [lindex $option 0]
        if {$arg ni {-check -warnings -target}} {
            usageError "-check cannot be combined with $arg: it analyzes the program and reports its diagnostics, without running, building or inspecting it (it takes -warnings and -target)"
        }
    }
    foreach path $files {
        if {[file extension $path] ne ".bot"} {
            usageError "-check analyzes Botlish source files (.bot), and $path is not one"
        }
    }
}
foreach option [dict get $commandLine options] {
    lassign $option arg value
    switch -- $arg {
        -backend {
            set backend $value
            set backendGiven 1
            if {$backend in $nativeBackends} {
                # Native backends are not core::registerBackend backends:
                # they compile HIR (native::evalHir), never core IR.
            } elseif {$backend in [core::backends]} {
                core::useBackend $backend
            } else {
                usageError "unknown backend \"$backend\" (known: [core::backends] $nativeBackends)"
            }
        }
        -target {
            set target $value
            if {![core::cabi::isTarget $target]} {
                usageError "unknown C ABI target \"$target\" (known: [join [core::cabi::targetNames] {, }])"
            }
        }
        -warnings {
            set warnings $value
            if {$warnings ni {default off error}} {
                usageError "unknown warnings mode \"$warnings\" (known: default off error)"
            }
        }
        -code    { set showCode 1 }
        -hir     { set showHir 1 }
        -contexts { set showContexts 1 }
        -direct  { set showDirect 1 }
        -traits  { set showTraits 1 }
        -ast     { set showAst 1 }
        -aot     { set showAot text }
        -aot-data { set showAot data }
        -aot-spec { set showAot spec }
        -emit-nir { set showNative nir }
        -emit-clif { set showNative clif }
        -emit-native-executable { set showNative executable }
        -aot-run { set aotRun 1 }
        -aot-keep { set aotKeep 1 }
        -emit-hir-interchange { set showNative interchange }
        -emit-native-library {
            if {![regexp {^[A-Za-z_][A-Za-z0-9_]*$} $value]} {
                usageError "-emit-native-library needs the library's name, a C identifier (it prefixes every public C name: NAME_create), found \"$value\""
            }
            set showNative library
            set libraryName $value
        }
        -native-startup {
            if {$value ni {worker main-thread}} {
                usageError "unknown native startup policy \"$value\" (known: worker main-thread)"
            }
            if {$nativeStartup ne "" && $nativeStartup ne $value} {
                usageError "-native-startup is given twice with different policies (\"$nativeStartup\" and \"$value\"): an executable has one"
            }
            set nativeStartup $value
        }
        -export { lappend libraryExports $value }
        -out { set libraryDir $value }
        -argv - -argv-hex {
            if {!$injectedArgvGiven} { set injectedArgv {}; set injectedArgvGiven 1 }
            if {$arg eq "-argv"} {
                lappend injectedArgv [core::process::bytesOfText $value]
            } else {
                if {![regexp {^([0-9A-Fa-f]{2})*$} $value]} {
                    usageError "-argv-hex needs an even number of hexadecimal digits (found \"$value\")"
                }
                lappend injectedArgv [binary decode hex $value]
            }
        }
        -argv-none { set injectedArgv {}; set injectedArgvGiven 1 }
        -L {
            if {$value eq ""} {
                usageError "-L needs a directory (found an empty one)"
            }
            lappend native::linkDirs [file normalize $value]
        }
        -F {
            if {$value eq ""} {
                usageError "-F needs a directory (found an empty one)"
            }
            lappend native::frameworkDirs [file normalize $value]
        }
        -runtime-path {
            if {$value eq "" || [regexp {[,\x00\n:;]} $value]} {
                usageError "-runtime-path needs one path, with no comma, colon, semicolon or newline (found \"$value\")"
            }
            lappend native::runtimePaths $value
        }
        -lsp-scheduler {
            usageError "-lsp-scheduler is an option of -lsp"
        }
    }
}
if {$showNative ne "library" && ($libraryExports ne "" || $libraryDir ne "")} {
    usageError "-export and -out are options of -emit-native-library"
}
if {$aotRun} {
    # -aot-run builds one program and runs it as a command: of the options
    # only those that decide how it compiles and links. Anything else runs
    # it another way, inspects, builds something else or checks: refused,
    # never ignored.
    foreach option [dict get $commandLine options] {
        set arg [lindex $option 0]
        if {$arg ni {-aot-run -aot-keep -warnings -target -L -F -native-startup}} {
            usageError "-aot-run cannot be combined with $arg: it builds one program as a standalone executable and runs it as a command, its standard output and error the program's own (it takes -warnings, -target, -L, -F, -native-startup and -aot-keep; the program's arguments follow --)"
        }
    }
    if {[llength $files] != 1} {
        usageError "-aot-run runs one program (found [llength $files] input files: the program's arguments follow --, as in -aot-run FILE -- ARG...)"
    }
    if {$target ne "" && $target ne [core::cabi::hostTarget]} {
        usageError "-aot-run runs the program here, on [core::cabi::hostTarget]: -target $target builds for another host (build there, with -emit-native-executable or -aot-run)"
    }
} elseif {$aotKeep} {
    usageError "-aot-keep is an option of -aot-run"
}
if {[dict get $commandLine separator] && !$aotRun} {
    usageError "-- ends -aot-run's options: the words after it are the program's arguments (-aot-run FILE -- ARG...; run FILE ARG... takes them after its FILE)"
}
if {$nativeStartup ne "" && $showNative ne "executable" && !$aotRun} {
    # The policy is fixed into an executable when it is built: no other
    # invocation makes one, and an explicit choice is never ignored.
    usageError "-native-startup is an option of -emit-native-executable and -aot-run: it chooses the thread a built executable runs its program on, and nothing else this invocation does makes one (a native library runs on its host's thread; -backend cranelift runs a program on the driver's own)"
}
if {$nativeStartup eq ""} {
    set nativeStartup worker
}
if {$showNative eq "library" && [llength $files] != 1} {
    usageError "-emit-native-library builds one library from one input file (found [llength $files])"
}
if {[dict get $commandLine action] eq "program" || $aotRun} {
    # The program's own argv(): its file as typed, then its arguments, each
    # as its UTF-8 bytes.
    set injectedArgv [lmap word [concat [lrange $files 0 0] [dict get $commandLine arguments]] {
        core::process::bytesOfText $word
    }]
}
# Native JIT execution (-backend cranelift, cranelift-generic: the driver's
# in-process code generator) where the native backend has none
# (native::jitAvailable: the macOS application's, built without it,
# MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md): refused before anything is
# compiled, naming what runs instead -- the interpreter, or the program as
# an executable (-aot-run). `run`'s native default, which the user did not
# choose, runs as -aot-run does: as the program's executable would.
set runsNatively [expr {$backend in $nativeBackends && !$check && !$aotRun
    && $showNative ni {executable library interchange}}]
if {$runsNatively && [lspMode $commandLine] eq "" && ![native::jitAvailable]} {
    if {[dict get $commandLine action] eq "program" && !$backendGiven} {
        exit [aotRunProgram [lindex $files 0]]
    }
    set message "native JIT execution (-backend $backend) is unavailable in this distribution: its native backend has no JIT. Run the program natively as a standalone executable with -aot-run FILE \[-- ARG...\], or on the interpreter (-backend interp, the default)"
    puts stderr "$cliInvocation: $message (NATIVE UNSUPPORTED jit)"
    helpHint stderr "" {NATIVE UNSUPPORTED jit} $message
    exit 1
}
if {$aotRun} {
    exit [aotRunProgram [lindex $files 0]]
}
if {[dict get $commandLine action] eq "program"} {
    exit [runProgram [lindex $files 0]]
}
set failures 0
if {$check} {
    source [file join $root service service.tcl]
    set checkWorkspace [service::workspace -warnings $warnings -target $target]
}
foreach path $files {
    if {$check} {
        incr failures [checkFile $path]
    } elseif {$showNative eq "executable"} {
        incr failures [emitExecutable $path]
    } elseif {$showNative eq "library"} {
        incr failures [emitLibrary $path $libraryName $libraryExports $libraryDir]
    } elseif {$showNative eq "interchange"} {
        incr failures [emitInterchange $path]
    } else {
        incr failures [runFile $path $showCode $showHir $showAst $showAot $showNative]
    }
}
exit [expr {$failures > 0}]

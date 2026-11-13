# library.tcl -- native libraries (NATIVE-LIBRARY-MILESTONE-1.md): a Botlish
# program compiled into a library a C host calls.
#
#   native::library HIR -name NAME -out DIR ?-exports NAMES? ?-shared 0|1?
#       ?-target TARGET? ?-application 0|1? ?LOWERING-OPTIONS...?
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
#   NAME.dll, NAME.lib  on Windows x86-64 (WINDOWS-X86-64-MILESTONE-8.md),
#                       in place of the two libraries above: the DLL -- the
#                       program and a private runtime, exporting exactly the
#                       library's public C functions -- and its import
#                       library, both made by link.exe (botlish-native
#                       library-dll) and checked from their bytes
#                       (`ValidateDll`, native/pe.tcl); no static library is
#                       made there (-shared 0 is refused)
#   NAME.manifest.json  the same interface as data (manifest schema 2), from
#                       the compiler's facts: what a binding generator or a
#                       package tool reads instead of the HIR, and the
#                       program's native dependencies (`dependencies`: the
#                       resolved link plan, NATIVE-LINK-PLAN-MILESTONE-1.md),
#                       which the shared library is linked with and a
#                       consumer of the static library links itself
#
# and returns a dict {static PATH|"" shared PATH|"" import PATH|"" header
# PATH manifest PATH exports RECORDS}, RECORDS hir::exports' records (import
# the import library of a Windows DLL, "" elsewhere). Failures raise
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
# With -application 1 the library is an application library
# (RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md): its entry file is
# an ordinary entry program -- installations, statements, a loop -- which
# the library runs through one more public function, NAME_main(argc, argv,
# &error), on the calling thread, in a Vm made and dropped inside the call.
# LIBRARY-TOP-LEVEL and LIBRARY-NO-EXPORTS are waived for it (the entry
# program is checked as any entry program is, for an executable as for
# this); its exports, if any, keep every export rule (they are reached
# through NAME_create instances, whose initialization never runs the entry
# program's statements, and never see its contexts), and `main` is one more
# reserved name. The NIR says `application`, the header declares NAME_main,
# and the manifest is schema 3 with an `application` member; an ordinary
# library's files are what they were (schema 2).
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
    # The manifest's schema revision (its "schema" member): 2, and 3 for an
    # application library's (its `application` member).
    variable schema 2
    variable applicationSchema 3
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
    set options [dict create -name "" -out "" -shared 1 -target "" -support "" -application 0]
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
    set application [dict get $options -application]
    if {$application ni {0 1}} {
        throw {NATIVE LIBRARY APPLICATION} "native::library: -application is 0 or 1, not \"$application\""
    }
    if {![regexp {^[A-Za-z_][A-Za-z0-9_]*$} $name]} {
        throw {NATIVE LIBRARY NAME} "native::library: the library name \"$name\" is not a C identifier (it prefixes every public C name: NAME_create)"
    }
    if {$out eq ""} {
        throw {NATIVE LIBRARY OUT} "native::library: -out DIR is required"
    }
    hir::activate $hir
    set host [core::cabi::hostTarget]
    set built [hir::cabi::targetOf $hir]
    set wanted [dict get $options -target]
    set support [dict get $options -support]
    # The library's target: -target's, else the one the program was built
    # for, else the host's. A library of another target than the host's is
    # emitted for it and linked with its runtime -- a target support
    # package's, with the toolchain the package declares
    # (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md): never with this
    # host's runtime, which is another target's.
    set target [if {$wanted ne ""} {set wanted} elseif {$built ne ""} {set built} else {set host}]
    if {$built ne "" && $built ne $target} {
        throw {NATIVE TARGET} "native::library: the program was built for $built, and the library is made for $target: compile it for $target (-target $target)"
    }
    # A Windows library (WINDOWS-X86-64-MILESTONE-8.md) is a DLL and its
    # import library, linked by link.exe on its own host.
    set windows [expr {$target eq "windows-x86_64"}]
    if {$support eq ""} {
        if {$target ne $host} {
            throw {NATIVE TARGET} "native::library: a library of $target is linked with $target's runtime, which this compiler does not carry: name the target support package of $target (-target-support NAME); this host is $host"
        }
        if {![native::hostSupports libraries]} {
            throw {NATIVE UNSUPPORTED library} "native libraries are made on Linux glibc (x86_64, aarch64) and Windows x86-64 (MSVC) only; this host is $host (NATIVE-LIBRARY-MILESTONE-1.md, WINDOWS-X86-64-MILESTONE-8.md)"
        }
        if {$windows && ![dict get $options -shared]} {
            throw {NATIVE UNSUPPORTED library} "native::library: a Windows library is its DLL and the DLL's import library, and -shared 0 asks for a static library only, which is not made for windows-x86_64: two static Botlish libraries in one executable would share their runtimes' symbols (WINDOWS-X86-64-MILESTONE-8.md, \"Static COFF libraries\")"
        }
    } else {
        if {[dict get $support target] ne $target} {
            throw {NATIVE TARGET} "native::library: the target support package [dict get $support package] supports [dict get $support target], and the library is made for $target"
        }
        if {![native::targetSupports libraries $target]} {
            throw {NATIVE UNSUPPORTED library} "native libraries are made for [join [dict get $native::targetCapabilities libraries] {, }] only, not $target"
        }
    }

    # An application library's entry file is an entry program: its
    # statements are what NAME_main runs (LIBRARY-TOP-LEVEL is a library
    # instance's rule, and NAME_create never runs them).
    set problems [if {$application} {list} else {library::TopLevelProblems $hir}]
    if {$selected} {
        lassign [hir::exports::select $hir $names] records refused
        foreach problem $refused {
            lassign $problem function kind message
            lappend problems [list $kind "$function: $message" ""]
        }
    } else {
        set records [hir::exports::of $hir]
    }
    if {![llength $records] && ![llength $problems] && !$application} {
        lappend problems [list LIBRARY-NO-EXPORTS "the program exports nothing: declare its C exports with \"exported c fn NAME(...) -> T:\" (or name top-level functions with -exports; or build it as an application library, -application, whose entry program NAME_main runs)" ""]
    }
    set symbols [dict create]
    foreach record $records {
        set function [dict get $record name]
        if {$function in $library::reserved || ($application && $function eq "main")} {
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

    if {$windows && $support eq ""} {
        # The toolchain and the runtime archive after the program's own
        # checks (a program's problem is the program's, whatever the
        # environment) and before anything is lowered: a missing link.exe is
        # said at once, never after the whole compilation.
        library::WindowsToolchain
    }
    set lowered [lmap record $records {
        dict create symbol ${name}_[dict get $record name] block [dict get $record block] \
            params [lmap {p t} [dict get $record params] {set t}] result [dict get $record result]
    }]
    set text [nir $hir -exports $lowered -application $application {*}$lowering]
    if {$support ne ""} {
        # The toolchain is the host's, found before anything is written: a
        # missing one is never mistaken for a broken package.
        set tools [support::toolchain $support]
    }
    # The program's native dependencies (NATIVE-LINK-PLAN-MILESTONE-1.md),
    # resolved as the library's link resolves them -- for the library's
    # target, by that target's linker (a library of another target: the
    # driver's link-plan --target, RN-HOST-STARTABLE-APPLICATION-LIBRARY-
    # MILESTONE-1.md, "Cross-target link plans"; never the host's plan for
    # another target's object): the shared library is linked with them, and
    # the manifest names them for a consumer of the static library, which
    # holds none of them.
    set targetArgs {}
    if {$target ne $host} {
        lappend targetArgs --target [dict get [core::cabi::target $target] triple]
    }
    set dependencies {}
    if {[hir::foreign::linkPlan $hir] ne {}} {
        set dependencies [LinkPlanOf $text {*}$targetArgs]
    }
    file mkdir $out
    set work [file tempdir]
    try {
        set object [file join $work $name.program.o]
        set public [library::PublicNames $name $records $application]
        if {$windows} {
            set static ""
            set shared [file join $out $name.dll]
            set import [file join $out $name.lib]
            # A failed link never leaves an earlier build's files under the
            # new manifest's names.
            file delete $shared $import [file join $out $name.manifest.json]
            set lines [Driver library-dll $text $out $name]
            foreach line $lines {
                if {[lindex $line 0] eq "error"} { Outcome $lines }
            }
            library::ValidateDll $shared $import $name $public
            set header [file join $out $name.h]
            library::Write $header [library::Header $hir $name $records $target $application]
            set manifest [file join $out $name.manifest.json]
            set digests [dict create shared [library::Sha256 $shared] import [library::Sha256 $import] header [library::Sha256 $header]]
            library::Write $manifest [library::Manifest $hir $name $records 1 $dependencies $digests $target $support $application]
            return [dict create static $static shared $shared import $import header $header manifest $manifest exports $records application $application]
        }
        set lines [Driver library $text $object $name {*}$targetArgs]
        foreach line $lines {
            if {[lindex $line 0] eq "error"} { Outcome $lines }
        }
        set keep [file join $work $name.keep]
        library::Write $keep [join $public \n]\n
        set linked [file join $work $name.linked.o]
        set final [file join $work $name.o]
        set static [file join $out lib$name.a]
        set shared ""
        if {[dict get $options -shared]} {
            set shared [file join $out lib$name.so]
        }
        # A failed link never leaves an earlier build's files under the new
        # manifest's names.
        file delete $static [file join $out $name.manifest.json]
        if {$shared ne ""} {
            file delete $shared
        }
        if {$support eq ""} {
            set runtime [library::RuntimeArchive]
            library::Tool ld -r -o $linked $object $runtime
            library::Tool objcopy --strip-debug --keep-global-symbols=$keep $linked $final
            library::Tool ar rcs $static $final
            if {$shared ne ""} {
                library::Tool cc -shared -o $shared $final -Wl,-z,defs -Wl,--gc-sections -Wl,-soname,lib$name.so \
                    {*}[library::DependencyArgs $dependencies] {*}$library::systemLibraries
            }
        } else {
            library::LinkWithToolchain $support $tools $target $name $object $keep $linked $final $static $shared \
                $dependencies $public
            dict set support toolchainName [dict get $tools name]
            dict set support toolchainRevision [dict get $tools revision]
        }
        set header [file join $out $name.h]
        library::Write $header [library::Header $hir $name $records $target $application]
        set manifest [file join $out $name.manifest.json]
        set digests [dict create static [library::Sha256 $static] header [library::Sha256 $header]]
        if {$shared ne ""} {
            dict set digests shared [library::Sha256 $shared]
        }
        library::Write $manifest [library::Manifest $hir $name $records [expr {$shared ne ""}] $dependencies $digests $target $support $application]
    } finally {
        file delete -force $work
    }
    return [dict create static $static shared $shared import "" header $header manifest $manifest exports $records application $application]
}

# Checks, before a Windows library is lowered, that it can be linked: the
# system linker's tool (link.exe, from a Developer environment, or
# BOTLISH_NATIVE_SYSTEM_LINKER) and the driver's runtime archive, as the
# driver itself finds them (botlish-native system-linker). A missing or
# wrong tool is {NATIVE LIBRARY TOOLCHAIN}, an unusable runtime archive
# {NATIVE LIBRARY RUNTIME}, each with the driver's words.
proc native::library::WindowsToolchain {} {
    # The driver exits 1 when a fact failed; its lines still say which (and
    # exec's own last line, "child process exited abnormally", none).
    catch {exec [native::binary] system-linker 2>@1} output
    foreach line [split $output \n] {
        if {[catch {lindex $line 1} second] || $second ne "error"} continue
        switch -- [lindex $line 0] {
            tool { throw {NATIVE LIBRARY TOOLCHAIN} "native::library: [lindex $line 2]" }
            runtime { throw {NATIVE LIBRARY RUNTIME} "native::library: [lindex $line 2]" }
        }
    }
}

# Checks the DLL PATH and its import library IMPORT that link.exe made for
# library NAME, from their bytes (native/pe.tcl): a PE32+ DLL of x86-64 with
# ASLR and DEP, exporting exactly the library's PUBLIC functions -- each by
# name, none forwarded, under the DLL's own name -- and importing no DLL of
# a C runtime (the static one is linked into it: codegen/aot.rs's
# crt_args policy); the import library naming exactly those functions, each
# a code import of NAME.dll. A failure is {NATIVE LIBRARY PE} and both files
# are removed: a library that fails is never left looking like a build.
proc native::library::ValidateDll {path import name public} {
    set problems {}
    set facts [native::pe::facts $path]
    if {[dict get $facts machine] != 0x8664} {
        lappend problems "its machine is [format 0x%x [dict get $facts machine]], not x86-64's 0x8664"
    }
    if {![dict get $facts dll]} {
        lappend problems "it is no DLL (IMAGE_FILE_DLL is not set)"
    }
    set characteristics [dict get $facts dllCharacteristics]
    if {!($characteristics & 0x40) || !($characteristics & 0x100)} {
        lappend problems "it is not relocatable and DEP-compatible (DllCharacteristics [format 0x%x $characteristics])"
    }
    if {[dict get $facts exportName] ne "$name.dll"} {
        set named [dict get $facts exportName]
        if {$named eq ""} { set named "no DLL" }
        lappend problems "its export directory names $named, not $name.dll"
    }
    set exports [dict get $facts exports]
    set expected [lsort $public]
    set missing [lmap p $expected {if {$p in $exports} continue; set p}]
    if {[llength $missing]} {
        lappend problems "it does not export [join $missing {, }]"
    }
    set extra [lmap e $exports {if {$e in $public} continue; set e}]
    if {[llength $extra]} {
        lappend problems "it exports [llength $extra] names that are no public function of the library: [join [lrange $extra 0 4] {, }][expr {[llength $extra] > 5 ? ", ..." : ""}]"
    }
    if {[dict get $facts exportFunctions] != [llength $exports]} {
        lappend problems "it exports [dict get $facts exportFunctions] functions, [expr {[dict get $facts exportFunctions] - [llength $exports]}] of them by ordinal only"
    }
    if {[llength [dict get $facts forwarders]]} {
        lappend problems "it forwards [join [dict get $facts forwarders] {, }] to another DLL"
    }
    set runtimes [lsearch -all -inline -regexp -nocase [dict get $facts imports] {^(vcruntime|msvcp|concrt|ucrtbase|msvcr|api-ms-win-crt-)}]
    if {[llength $runtimes]} {
        lappend problems "it imports a C runtime's DLLs ([join $runtimes {, }]): a library links the static C runtime, and its host's runtime is its host's"
    }
    set library [native::pe::importLibrary $import]
    set named [lsort [lmap entry [dict get $library imports] {lindex $entry 0}]]
    set foreign [lmap entry [dict get $library imports] {
        lassign $entry symbol dll type
        if {[string equal -nocase $dll $name.dll] && $type eq "code"} continue
        set symbol
    }]
    if {$named ne $expected} {
        lappend problems "its import library names [llength $named] functions, not exactly the [llength $expected] public ones"
    }
    if {[llength $foreign]} {
        lappend problems "its import library's [join $foreign {, }] are no code imports of $name.dll"
    }
    if {[llength $problems]} {
        file delete $path $import
        throw {NATIVE LIBRARY PE} "native::library: the DLL made for windows-x86_64 is not the library: [join $problems {; }]"
    }
}

# Links library NAME's program OBJECT with target support SUPPORT's runtime
# archive by the toolchain TOOLS (native::support::toolchain) for TARGET
# (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md): the same four steps as the
# host's link -- a relocatable link of the object and the runtime archive
# (only the members it needs; no --gc-sections, as for GNU ld), every
# symbol but the PUBLIC ones (the file KEEP) made local, the static archive,
# and the shared library -- each by the toolchain's own tool, never this
# host's: an LLVM linker, objcopy and archiver, and the C compiler driver for
# TARGET's triple at the package's platform version (the NDK's clang with
# --target=aarch64-linux-androidN). The shared library is position-
# independent and its loadable segments 16 KiB-aligned (`Alignment`), and it
# is checked before anything is reported (`ValidateShared`).
proc native::library::LinkWithToolchain {support tools target name object keep linked final static shared dependencies public} {
    set runtime [dict get $support archive]
    set triple [dict get [core::cabi::target $target] triple]
    ToolchainTool $tools ld -r -o $linked $object $runtime
    ToolchainTool $tools objcopy --strip-debug --keep-global-symbols=$keep $linked $final
    ToolchainTool $tools ar rcs $static $final
    if {$shared eq ""} {
        return
    }
    set driverTarget $triple[dict get $tools api]
    set args [list --target=$driverTarget -shared -o $shared $final -Wl,-z,defs -Wl,-z,text -Wl,--gc-sections \
        -Wl,-z,max-page-size=[Alignment $target] -Wl,-soname,lib$name.so]
    lappend args {*}[DependencyArgs $dependencies] {*}[dict get $support libraries]
    ToolchainTool $tools cc {*}$args
    ValidateShared $shared $target $support $public $name $dependencies
}

# The page size a shared library of TARGET is aligned to: Android AArch64's
# largest, 16 KiB (devices with 16 KiB pages load only libraries whose
# loadable segments are aligned to it; a 4 KiB device loads them too).
proc native::library::Alignment {target} {
    return [dict getdef {android-aarch64 16384} $target 4096]
}

# Runs the toolchain's TOOL with ARGS (an argv list: no shell). A link that
# fails because an archive is not position-independent is {NATIVE LIBRARY
# PIC}; any other failure {NATIVE LIBRARY TOOL TOOL}, with the tool's words.
proc native::library::ToolchainTool {tools tool args} {
    set program [dict get $tools $tool]
    if {[catch {exec $program {*}$args 2>@1} output]} {
        if {[string match "*recompile with -fPIC*" $output] || [string match "*can't create dynamic relocation*" $output]
                || [string match "*relocation R_AARCH64_*cannot be used against*" $output]} {
            throw {NATIVE LIBRARY PIC} "native::library: the shared library cannot be linked: an archive linked into it is not position-independent (the target support package's runtime must be built for the pic relocation model): $output"
        }
        throw [list NATIVE LIBRARY TOOL $tool] "native::library: [dict get $tools name] $tool failed: $output"
    }
}

# Checks the shared library PATH a toolchain link made for TARGET with
# SUPPORT's runtime, from its bytes (native/elf.tcl): an ELF shared object
# of TARGET's machine, every loadable segment aligned to `Alignment`, no
# text relocation, an executable stack nowhere, no symbol version of another
# C library (GLIBC_), nothing needed but the system libraries SUPPORT states
# (and the program's own dependencies), and exactly the library's public
# functions exported. A failure is {NATIVE LIBRARY ELF} and the file is
# removed: a library that fails is never left looking like a build.
proc native::library::ValidateShared {path target support public name dependencies} {
    set facts [native::elf::facts $path]
    set problems {}
    set machine [dict get {x86_64 62 aarch64 183} [dict get [core::cabi::target $target] arch]]
    if {[dict get $facts machine] != $machine} {
        lappend problems "its machine is [dict get $facts machine], not $target's $machine"
    }
    if {[dict get $facts type] ne "dyn"} {
        lappend problems "it is no shared object (ELF type [dict get $facts type])"
    }
    set align [Alignment $target]
    foreach load [dict get $facts loads] {
        if {[dict get $load align] < $align || [dict get $load vaddr] % $align != [dict get $load offset] % $align} {
            lappend problems "a loadable segment (offset [dict get $load offset], vaddr [dict get $load vaddr]) is aligned to [dict get $load align], not $align"
        }
    }
    if {[dict get $facts textrel]} {
        lappend problems "it has text relocations (DT_TEXTREL): its code is not position-independent"
    }
    if {[dict get $facts stackExec]} {
        lappend problems "it asks for an executable stack"
    }
    if {[dict get $facts interpreter] ne ""} {
        lappend problems "it names a program interpreter ([dict get $facts interpreter])"
    }
    foreach {library versions} [dict get $facts verneed] {
        foreach version $versions {
            if {[string match GLIBC_* $version]} {
                lappend problems "it requires $library's $version: the GNU C library's symbol version, which $target's C library has none of"
            }
        }
    }
    set allowed [lmap l [dict get $support libraries] {string cat lib[string range $l 2 end].so}]
    lappend allowed {*}[lmap d $dependencies {if {[lindex $d 0] ne "library"} continue; string cat lib[lindex $d 1].so}]
    foreach need [dict get $facts needed] {
        if {$need ni $allowed} {
            lappend problems "it needs $need, which is neither one of $target's system libraries nor a library the program declares ([join [lsort -unique $allowed] {, }])"
        }
    }
    set exports [dict get $facts exports]
    set missing [lmap p $public {if {$p in $exports} continue; set p}]
    if {[llength $missing]} {
        lappend problems "it does not export [join $missing {, }]"
    }
    set extra [lmap e $exports {if {[string match ${name}_* $e]} continue; set e}]
    if {[llength $extra]} {
        lappend problems "it exports [llength $extra] symbols that are no public function of the library (the first: [lindex $extra 0])"
    }
    if {[llength $problems]} {
        file delete $path
        throw {NATIVE LIBRARY ELF} "native::library: the shared library made for $target is not one: [join $problems {; }]"
    }
}

# The native runtime archive a library's object is linked with: the
# driver's libbotlish_native.a beside it (a checkout's build), else the
# system linker's runtime archive, libbotlish_runtime.a, which holds the same
# runtime and an executable's C `main` that a library's relocatable link
# never pulls in (nothing a library's object calls is in its member): the
# one the single executable carries (EXTERNAL-COMPILER-TOOLS-AND-TARGET-
# PACKAGES-MILESTONE-1.md, "Native libraries from the single executable").
proc native::library::RuntimeArchive {} {
    set dir [file dirname [native::binary]]
    foreach name {libbotlish_native.a libbotlish_runtime.a} {
        set runtime [file join $dir $name]
        if {[file isfile $runtime]} {
            return $runtime
        }
    }
    throw {NATIVE NOT-BUILT} "native runtime archive missing: [file join $dir libbotlish_native.a] (or libbotlish_runtime.a); run cargo build --release --manifest-path native/Cargo.toml"
}

# The SHA-256 of the file PATH, lowercase hexadecimal, from the system's own
# tool at its fixed path -- GNU coreutils' sha256sum on Linux glibc,
# certutil.exe in %SystemRoot%\System32 on Windows -- never a program found
# on PATH: the manifest's record of which build's files it describes.
proc native::library::Sha256 {path} {
    if {$::tcl_platform(platform) eq "windows"} {
        set root C:/Windows
        if {[info exists ::env(SystemRoot)] && [regexp {^[A-Za-z]:[\\/][^;]*$} $::env(SystemRoot)]} {
            set root [file normalize $::env(SystemRoot)]
        }
        set tool [file join $root System32 certutil.exe]
        if {[catch {exec $tool -hashfile [file nativename $path] SHA256} output]} {
            throw {NATIVE LIBRARY TOOL certutil} "native::library: $tool failed: $output"
        }
        # A header line, the digest (spaced in older Windows versions), a
        # status line.
        set digest [string tolower [string map {" " ""} [lindex [split [string map {"\r" ""} $output] \n] 1]]]
        if {![regexp {^[0-9a-f]{64}$} $digest]} {
            throw {NATIVE LIBRARY TOOL certutil} "native::library: $tool gave no digest: $output"
        }
        return $digest
    }
    foreach tool {/usr/bin/sha256sum /bin/sha256sum} {
        if {![file executable $tool]} continue
        if {[catch {exec $tool -b -- $path} output]} {
            throw {NATIVE LIBRARY TOOL sha256sum} "native::library: $tool failed: $output"
        }
        if {![regexp {^([0-9a-f]{64}) } $output -> digest]} {
            throw {NATIVE LIBRARY TOOL sha256sum} "native::library: $tool gave no digest: $output"
        }
        return $digest
    }
    throw {NATIVE LIBRARY TOOL sha256sum} "native::library: no sha256sum at /usr/bin or /bin (GNU coreutils): the manifest records each artifact's SHA-256"
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

# The library's public C names: the runtime API's, an application
# library's entry (NAME_main, when APPLICATION) and the exports'.
proc native::library::PublicNames {name records {application 0}} {
    variable reserved
    set names [lmap suffix $reserved {string cat ${name}_$suffix}]
    if {$application} {
        lappend names ${name}_main
    }
    return [concat $names [lmap record $records {string cat ${name}_[dict get $record name]}]]
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

proc native::library::Header {hir name records {target ""} {application 0}} {
    variable abiVersion
    set N $name
    # A Windows library's functions are a DLL's (WINDOWS-X86-64-MILESTONE-8.md):
    # declared __declspec(dllimport), which a host calls through its import
    # address table (the import library's), and stated so in the contract.
    set windows [expr {$target eq "windows-x86_64"}]
    set api [expr {$windows ? "${N}_API " : ""}]
    set guard [string toupper $name]_BOTLISH_H
    set entry [file tail [dict get [hir::sourceFile $hir f1] path]]
    set h "/* $N.h -- the C interface of the Botlish native library \"$N\".\n"
    append h " * Generated by the Botlish compiler from $entry (native::library,\n"
    append h " * NATIVE-LIBRARY-MILESTONE-1.md); do not edit.\n"
    append h " *\n"
    if {$application} {
        append h " * Application. This is an application library: its entry program runs\n"
        append h " * through ${N}_main (below), on the calling thread, blocking, to its end.\n"
        append h " * Each call makes a fresh Botlish VM there -- module initialization, then the\n"
        append h " * entry program's statements, which install its own contexts -- and drops it\n"
        append h " * on that thread before returning: no handle escapes, nothing is left behind,\n"
        append h " * and the host supplies the thread, never a context. argc and argv (argv\[0\]\n"
        append h " * included) become argv(), copied first; each argument must be UTF-8\n"
        append h " * (${N}_STATUS_BOUNDARY ARGUMENT-NOT-UTF8 or ARGUMENT-NULL), argc never\n"
        append h " * negative (${N}_STATUS_INVOCATION ARGUMENT-COUNT) and argv never NULL when\n"
        append h " * argc is positive (NULL-POINTER). It returns ${N}_STATUS_OK when the entry\n"
        append h " * completed; otherwise the failure's status, with *error as below. A call\n"
        append h " * while this thread runs a call of this library (from inside the entry, an\n"
        append h " * export or an initialization) is ${N}_STATUS_INVOCATION REENTRANT-CALL;\n"
        append h " * calls on different threads are independent, each with its own VM.\n"
        append h " * ${N}_create never runs the entry program: its instances are initialized\n"
        append h " * only, and their exports never see the entry's contexts.\n"
        append h " *\n"
    }
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
    if {$windows} {
        append h " *\n"
        append h " * Windows. The library is $N.dll: link its import library $N.lib, or load\n"
        append h " * it with LoadLibraryW and find each function with GetProcAddress by the\n"
        append h " * name declared here. Loading runs no Botlish code (${N}_create does). The\n"
        append h " * DLL holds its own C runtime: release its results and errors with its own\n"
        append h " * functions, never free() or delete. Before FreeLibrary, destroy every\n"
        append h " * instance and release every result and error it handed out: nothing of\n"
        append h " * the library -- a buffer, an error, a function's address -- is usable\n"
        append h " * once it is unloaded. Define ${N}_API before including this header to\n"
        append h " * declare the functions otherwise (it is __declspec(dllimport) by default).\n"
    }
    append h " */\n"
    append h "#ifndef $guard\n#define $guard\n\n"
    append h "#include <stdbool.h>\n#include <stddef.h>\n#include <stdint.h>\n\n"
    append h "#ifdef __cplusplus\nextern \"C\" \{\n#endif\n\n"
    append h "#define ${N}_ABI_VERSION $abiVersion\n\n"
    if {$windows} {
        append h "#ifndef ${N}_API\n#define ${N}_API __declspec(dllimport)\n#endif\n\n"
    }
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
    append h "${api}uint32_t ${N}_abi_version(void);\n"
    append h "${api}int32_t ${N}_create(${N}_instance **instance, ${N}_error **error);\n"
    append h "${api}int32_t ${N}_destroy(${N}_instance *instance);\n\n"
    append h "${api}int32_t ${N}_error_release(${N}_error **error);\n"
    append h "${api}int32_t ${N}_error_status(const ${N}_error *error);\n"
    append h "${api}int32_t ${N}_error_identity(const ${N}_error *error, const uint8_t **ptr, size_t *len);\n"
    append h "${api}int32_t ${N}_error_message(const ${N}_error *error, const uint8_t **ptr, size_t *len);\n"
    append h "${api}size_t ${N}_error_field_count(const ${N}_error *error);\n"
    append h "${api}int32_t ${N}_error_field_name(const ${N}_error *error, size_t index, const uint8_t **ptr, size_t *len);\n"
    append h "${api}int32_t ${N}_error_field_type(const ${N}_error *error, size_t index);\n"
    append h "${api}int32_t ${N}_error_field_int(const ${N}_error *error, size_t index, int64_t *value);\n"
    append h "${api}int32_t ${N}_error_field_bool(const ${N}_error *error, size_t index, bool *value);\n"
    append h "${api}int32_t ${N}_error_field_float64(const ${N}_error *error, size_t index, double *value);\n"
    append h "${api}int32_t ${N}_error_field_str(const ${N}_error *error, size_t index, const uint8_t **ptr, size_t *len);\n"
    append h "${api}int32_t ${N}_bytes_release(${N}_bytes *bytes);\n\n"
    if {$application} {
        append h "/* The application entry: runs the entry program on the calling thread. */\n"
        append h "${api}int32_t ${N}_main(int argc, char **argv, ${N}_error **error);\n\n"
    }
    append h "/* Exports. */\n"
    foreach record $records {
        append h "\n/* [Signature $record] */\n"
        append h "${api}int32_t ${N}_[dict get $record name]([join [CParams $N $record] {, }]);\n"
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

# The linker arguments of the resolved link plan DEPENDENCIES
# (native::linkPlan's records) after a library's object: the library search
# directories in force (-L), then every library by name and every static
# archive by its file, in the plan's order, inside one GNU archive group --
# the executable link's plan (codegen/aot.rs's link_plan_args_for), which a
# shared library's link is on Linux.
proc native::library::DependencyArgs {dependencies} {
    if {$dependencies eq {}} {
        return {}
    }
    set args [lmap dir $::native::linkDirs {string cat -L $dir}]
    lappend args -Wl,--start-group
    foreach dependency $dependencies {
        switch -- [lindex $dependency 0] {
            library { lappend args -l[lindex $dependency 1] }
            archive { lappend args [lindex $dependency 2] }
        }
    }
    lappend args -Wl,--end-group
    return $args
}

# The manifest's record of the resolved dependency DEPENDENCY (a
# native::linkPlan record): its kind and name, and how a consumer of the
# static library links it -- the static library holds none of a program's
# native dependencies, a consumer's link names each after it (`link`: the
# shared library is linked with them already, a static archive's code in
# it).
proc native::library::Dependency {dependency} {
    lassign $dependency kind name path how what
    switch -- $kind {
        library {
            return [list obj [list kind [S library] name [S $name] linkage [S default] link [S -l$name]]]
        }
        archive {
            return [list obj [list kind [S library] name [S $name] linkage [S static] archive [S $path] link [S $path]]]
        }
        default {
            return [list obj [list kind [S framework] name [S $name] link [S "-framework $name"]]]
        }
    }
}

# The manifest (schema 2, EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-
# MILESTONE-1.md, "The artifact manifest") of the library NAME with the
# export RECORDS: schema 1's interface as data, and what makes it an artifact
# contract a tool can rely on without the HIR -- the build it describes
# (`sha256`: each file's digest, DIGESTS), the compiler that made it
# (`compiler`: the front end's fingerprint and the runtime ABI's), and the
# ownership of every value that crosses the boundary as data (each
# parameter's and result's `ownership`, the release function of what the
# caller owns, each export's `error` out-parameter).
proc native::library::Manifest {hir name records shared {dependencies {}} {digests {}} {target ""} {support ""} {application 0}} {
    variable schema
    variable applicationSchema
    variable abiVersion
    variable systemLibraries
    variable reserved
    if {$target eq ""} {
        set target [core::cabi::hostTarget]
    }
    set links $systemLibraries
    set supported {}
    if {$support ne ""} {
        # A library linked with a target support package's runtime
        # (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md): the system
        # libraries its runtime is linked with, and which package, platform
        # version and toolchain made it.
        set links [dict get $support libraries]
        set platform [lmap {k v} [dict get $support platform] {list $k [N $v]}]
        set supported [list targetSupport [list obj [list \
            package [S [dict get $support package]] \
            runtimeAbi [S [dict get $support abi]] \
            platform [list obj [concat {*}$platform]] \
            toolchain [list obj [list name [S [dict get $support toolchainName]] revision [S [dict get $support toolchainRevision]]]]]]]
    }
    set exports {}
    foreach record $records {
        set params {}
        foreach {param type} [dict get $record params] {
            lassign [CTypes $type] cType
            set c [list [S $cType]]
            if {$type eq "str"} {
                lappend c [S size_t]
            }
            lappend params [list obj [list name [S $param] type [S $type] c [list arr $c] {*}[ParamPassing $type]]]
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
            result [list obj [list type [S $result] c [S [string map [list NAME $name] $out]] {*}[ResultPassing $name $result]]] \
            error [list obj [list c [S "${name}_error **"] nullable [list bool 1] ownership [S owned] release [S ${name}_error_release]]] \
            errors [list arr $errors]]]
    }
    set api [lmap suffix $reserved {S ${name}_$suffix}]
    set initialization "module static initialization only: the entry file holds declarations"
    set entry {}
    if {$application} {
        # The application entry (RN-HOST-STARTABLE-APPLICATION-LIBRARY-
        # MILESTONE-1.md): schema 3's one addition, what a tool that needs an
        # application reads instead of the header.
        lappend api [S ${name}_main]
        set initialization "module static initialization only: the entry program's statements run in ${name}_main, never in ${name}_create"
        set entry [list application [list obj [list \
            symbol [S ${name}_main] \
            c [S "int32_t ${name}_main(int argc, char **argv, ${name}_error **error)"] \
            thread [S calling] \
            execution [S blocking-to-completion] \
            vm [S "made and dropped on the calling thread inside each call; no handle escapes"] \
            argv [list obj [list encoding [S utf-8] includes [S argv0] copied [list bool 1] \
                refusals [list arr [list [S ARGUMENT-COUNT] [S NULL-POINTER] [S ARGUMENT-NULL] [S ARGUMENT-NOT-UTF8]]]]] \
            contexts [S "installed by the entry program itself; the host supplies none"] \
            returns [list obj [list ok [S "the entry completed"] otherwise [S "the failure's status"]]] \
            status [S native-library] \
            error [list obj [list c [S "${name}_error **"] nullable [list bool 1] ownership [S owned] release [S ${name}_error_release]]] \
            reentrancy [S "refused while this thread runs a call of this library (REENTRANT-CALL)"] \
            concurrency [S "independent calls on different threads, each with its own VM"] \
            stack [S "the calling thread's, bounded by the library's stack check (NATIVE LIMIT STACK); no signal handler"]]]]
    }
    # A Windows library (WINDOWS-X86-64-MILESTONE-8.md) is its DLL and import
    # library, and no static library: `static` is null, `shared` the DLL,
    # `import` -- a member only a Windows manifest has -- the import library
    # a consumer links; `link` is empty (the DLL is linked with its
    # system libraries and holds its C runtime; a consumer links the import
    # library only), and `lifecycle` states the unloading precondition.
    set windows [expr {$target eq "windows-x86_64"}]
    if {$windows} {
        set links {}
        set files [list static [list null {}] shared [S $name.dll] import [S $name.lib] header [S $name.h]]
        set sha256 [list static [list null {}] shared [S [dict getdef $digests shared ""]] \
            import [S [dict getdef $digests import ""]] header [S [dict getdef $digests header ""]]]
        set unloading [list unload [S "FreeLibrary only after every instance is destroyed and every result and error it handed out is released: nothing of the library is usable once it is unloaded"]]
    } else {
        set files [list static [S lib$name.a] shared [if {$shared} {S lib$name.so} else {list null {}}] header [S $name.h]]
        set sha256 [list static [S [dict getdef $digests static ""]]]
        lappend sha256 shared [if {$shared} {S [dict getdef $digests shared ""]} else {list null {}}]
        lappend sha256 header [S [dict getdef $digests header ""]]
        set unloading {}
    }
    set value [list obj [list \
        schema [N [if {$application} {set applicationSchema} else {set schema}]] \
        kind [S botlish-native-library] \
        library [S $name] \
        abi [N $abiVersion] \
        target [list obj [list name [S $target] triple [S [dict get [core::cabi::target $target] triple]]]] \
        compiler [list obj [list frontEnd [S [hir::interchange::fingerprint]] runtimeAbi [S [native::runtimeAbi [dict get [core::cabi::target $target] triple]]]]] \
        artifacts [list obj $files] \
        sha256 [list obj $sha256] \
        link [list arr [lmap l $links {S $l}]] \
        dependencies [list arr [lmap d $dependencies {Dependency $d}]] \
        threading [S thread-affine] \
        reentrancy [S refused] \
        callbacks [list arr {}] \
        statuses [list obj [list ok [N 0] declared [N 1] runtime [N 2] boundary [N 3] invocation [N 4] internal [N 5]]] \
        fieldTypes [list obj [list int [N 1] bool [N 2] float64 [N 3] str [N 4] other [N 5]]] \
        types [list obj [list \
            int [list obj [list c [S int64_t] rule [S "every int64_t is an Int; an Int result outside int64_t is a BOUNDARY error RESULT-OUT-OF-RANGE"]]] \
            bool [list obj [list c [S bool]]] \
            float64 [list obj [list c [S double] rule [S "a NaN or infinite argument is a BOUNDARY error ARGUMENT-NOT-FINITE; -0.0 enters as 0.0"]]] \
            str [list obj [list c [S "const uint8_t *, size_t"] result [S ${name}_bytes] rule [S "UTF-8, validated and copied; NULL allowed for length 0; embedded NULs allowed; a result is an owned buffer, NUL-terminated after len bytes, released with ${name}_bytes_release"]]]]] \
        ownership [list obj [list \
            instance [list obj [list owner [S caller] create [S ${name}_create] release [S ${name}_destroy]]] \
            str-argument [list obj [list owner [S caller] lifetime [S call] copied [list bool 1] null [S length-zero]]] \
            str-result [list obj [list owner [S caller] release [S ${name}_bytes_release] terminated [S nul-after-length] survives [S "later calls, collections, the instance's destruction"]]] \
            error [list obj [list owner [S caller] release [S ${name}_error_release] survives [S "later calls, collections, the instance's destruction"]]]]] \
        lifecycle [list obj [list create [S ${name}_create] destroy [S ${name}_destroy] \
            initialization [S $initialization] {*}$unloading]] \
        api [list arr $api] \
        {*}$entry \
        exports [list arr $exports] {*}$supported]]
    return "[Json $value]\n"
}

# The manifest's ownership members of a parameter of boundary TYPE: a str is
# borrowed for the call (copied before it returns), a scalar passed by value.
proc native::library::ParamPassing {type} {
    if {$type eq "str"} {
        return [list ownership [S borrowed] lifetime [S call]]
    }
    return [list ownership [S value]]
}

# The manifest's ownership members of the result of boundary TYPE of library
# NAME: a str result is an owned buffer the caller releases with
# NAME_bytes_release; a scalar is a value; unit has none.
proc native::library::ResultPassing {name type} {
    switch -- $type {
        str { return [list ownership [S owned] release [S ${name}_bytes_release]] }
        unit { return [list ownership [S none]] }
        default { return [list ownership [S value]] }
    }
}

# aot-facts.tcl -- the native backend's program objects and standalone
# executables on this host, checked with the host's own tools
# (MACOS-AARCH64-MILESTONE-5.md; MACOS-AARCH64-PORT-AUDIT.md, section 5).
#
#   tclsh9.0 tests/platform/aot-facts.tcl ?-verbose 0|1?
#
# Compiles one small pure Botlish program (a context, a recursion, Strings,
# a List) to a relocatable object (native::object) and to a standalone
# executable (native::executable, the rustc linker), and checks them as the
# host's toolchain sees them, against what is recorded below for the host
# target (core::cabi::hostTarget):
#
#   object      its format, architecture and kind (`file`, and the header
#               read here), its symbols (`nm -P`: every botlish_fn_N and
#               botlish_entry_N defined, the runtime helpers undefined, the
#               context area local, each with the object format's own
#               decoration and nothing else), its relocations (`objdump -r`:
#               the context area and a runtime helper reached through the
#               GOT, no relocation of another format) and, on macOS, its
#               LC_BUILD_VERSION (`otool -l`)
#   executable  its format, architecture and kind; on macOS one
#               architecture (`lipo -archs`), a valid signature (`codesign
#               -v`; the linker's ad-hoc one); the dynamic libraries it
#               loads (`otool -L`, `ldd`), all the system's, none of this
#               checkout's or toolchain's; and the platform linker's command
#               line as rustc runs it (`rustc --print link-args`, through a
#               RUSTC wrapper: printed with -verbose 1)
#   C calls     a static C library compiled here, a program calling it and
#               the system C library linked by the platform linker's link
#               plan (its command line), run standalone; labs imported from
#               the system C library (`nm`); the linker's words for a
#               missing library and an undefined symbol (MACOS-AARCH64-
#               MILESTONE-6.md)
#   standalone  the executable moved out of its build directory, its source
#               deleted, run with an empty environment from another
#               directory: its value, also under BOTLISH_NATIVE_GC_STRESS=1;
#               a coroutine program's value; a runtime error's status and
#               standard error; a stack overflow of the thread's stack and of
#               a coroutine's (exit status 1, exactly the NATIVE LIMIT STACK
#               line on standard error, no signal); a deep finite recursion
#
# The checks are host-independent but for the tools and the expected formats
# (ELF on Linux, Mach-O on macOS); the programs' values and statuses are the
# same everywhere. The executable checks do not run where executable
# emission is refused.
#
# On Windows (windows-x86_64, MSVC's toolchain: WINDOWS-X86-64-MILESTONE-1.md)
# the same program is checked by `windowsChecks`, which reads the COFF object
# and the PE executable itself (tests/binary-header.tcl's coffFacts and
# peFacts: no MSVC tool needed): the object's sections, symbols (undecorated
# on x64) and relocation types; the executable's format, console subsystem
# and imported DLLs -- every one the system's (System32's, or an API set),
# none of the Visual C++ runtime or the UCRT's (the C runtime is linked
# statically); its name (NAME.exe); and the standalone runs, from another
# directory with only the system directory on PATH, where the outcomes
# differ from Unix's exactly as recorded: native coroutines and C calls are
# refused, the depth check's NATIVE LIMIT STACK is reported as any run-time
# error is (MESSAGE (CODE)), and a native stack exhausted before the shadow
# stack's depth check fires ends the process (no stack guard yet). Prints
# one line per check, the tools' own output with
# -verbose 1 (and always for a failed check), the object and link times, and
# exits 1 on any failure. Needs the native backend built (cargo build
# --release --manifest-path native/Cargo.toml). Its scratch files are in a
# private temporary directory, removed at the end.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname $here]]
source [file join $root native native.tcl]
source [file join $root tests binary-header.tcl]

set verbose 0
foreach {option value} $argv {
    switch -- $option {
        -verbose { set verbose $value }
        default {
            puts stderr "usage: tclsh9.0 tests/platform/aot-facts.tcl ?-verbose 0|1?"
            exit 2
        }
    }
}

# What the host's tools must report, per host target: the object's and the
# executable's {FORMAT ARCHITECTURE KIND} (from the header), the `file`
# pattern of each, the symbol decoration (the object format's user label
# prefix), and the relocation types of a GOT access to the context area and
# to a runtime helper.
set expected [dict create \
    linux-x86_64 {
        object {elf x86_64 relocatable} objectFile {ELF 64-bit LSB relocatable, x86-64*}
        executable {elf x86_64 shared} executableFile {ELF 64-bit LSB pie executable, x86-64*}
        prefix "" contextReloc {R_X86_64_REX_GOTPCRELX} helperReloc {R_X86_64_GOTPCREL R_X86_64_PLT32}
        foreignRelocs {ARM64_RELOC_* R_AARCH64_*}
    } \
    linux-aarch64 {
        object {elf aarch64 relocatable} objectFile {ELF 64-bit LSB relocatable, ARM aarch64*}
        executable {elf aarch64 shared} executableFile {ELF 64-bit LSB pie executable, ARM aarch64*}
        prefix "" contextReloc {R_AARCH64_ADR_GOT_PAGE R_AARCH64_LD64_GOT_LO12_NC}
        helperReloc {R_AARCH64_ADR_GOT_PAGE R_AARCH64_LD64_GOT_LO12_NC}
        foreignRelocs {ARM64_RELOC_* R_X86_64_*}
    } \
    macos-aarch64 {
        object {macho arm64 object} objectFile {Mach-O 64-bit object arm64*}
        executable {macho arm64 execute} executableFile {Mach-O 64-bit executable arm64*}
        prefix _ contextReloc {ARM64_RELOC_GOT_LOAD_PAGE21 ARM64_RELOC_GOT_LOAD_PAGEOFF12}
        helperReloc {ARM64_RELOC_GOT_LOAD_PAGE21 ARM64_RELOC_GOT_LOAD_PAGEOFF12}
        foreignRelocs {R_X86_64_* R_AARCH64_*}
    } \
    windows-x86_64 {
        object {coff x86_64 object} executable {pe x86_64 executable}
        prefix "" relocTypes {ADDR64 ADDR32NB REL32}
    }]

set host [core::cabi::hostTarget]
if {![dict exists $expected $host]} {
    puts "FAIL: no native object facts recorded for host target \"$host\" ($::tcl_platform(os) $::tcl_platform(machine))"
    exit 1
}
set facts [dict get $expected $host]
set prefix [dict get $facts prefix]
set macos [string match macos-* $host]

# The program: a context (the object's one data symbol, botlish_context_area),
# a recursion, String building and a List.
set program {import str

type Small = Int in 0..1000

context struct Counter:
    value: Small

fn read(context c: Counter) -> int:
    c.value

fn fib(n):
    if n <= 1:
        return n

    fib(n - 1) + fib(n - 2)

fn build(n):
    if n < 1:
        return ""

    "xy".concat(build(n - 1))

with context Counter {value: 41}
[fib(20), build(50).length(), read() + 1]
}
set programValue {[6765, 100, 42]}

set coroutineProgram {struct Message:
    value: int

struct Event:
    value: int

fn worker(base: int, resume Message) -> Event:
    message = yield Event {value: base}
    return Event {value: message.value}

coroutine {step, first} = worker(10)
second = step(Message {value: 7})
[first.value, second.value]
}

set downProgram {fn down(n: int) -> int:
    if n == 0:
        return 0

    1 + down(n - 1)

down(DEPTH)
}

set coroutineOverflowProgram {struct Event:
    value: int

fn down(n: int) -> int:
    if n == 0:
        return 0

    1 + down(n - 1)

fn worker(depth: int) -> Event:
    yield Event {value: 0}
    return Event {value: down(depth)}

coroutine {step, first} = worker(100000000)
step().value
}

# What performance-compute runs: fib(25) and a String built by 2000
# concatenations.
set benchProgram {import str

fn fib(n):
    if n <= 1:
        return n

    fib(n - 1) + fib(n - 2)

fn build(n: int, acc: str) -> int:
    if n == 0:
        return acc.length()

    build(n - 1, acc.concat("x"))

[fib(25), build(2000, "")]
}
set benchValue {[75025, 2000]}

set errorProgram {import mutable_array
mutable_array::allocate(0 - 1)
}

set overflowLine "error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}"

set work [file tempdir botlish-aot-facts]
set failures 0

# Prints check NAME: OK, what it saw (SUMMARY) and, with -verbose 1 or when
# it failed, DETAIL (a tool's own output).
proc check {name ok summary {detail ""}} {
    global verbose failures
    if {!$ok} { incr failures }
    puts [format "%-4s %-28s %s" [expr {$ok ? "ok" : "FAIL"}] $name $summary]
    if {$detail ne "" && (!$ok || $verbose)} {
        # At most 40 lines of a tool's output (a symbol table is long).
        set lines [split [string trimright $detail \n] \n]
        foreach line [lrange $lines 0 39] {
            puts "       $line"
        }
        if {[llength $lines] > 40} {
            puts "       ... [expr {[llength $lines] - 40}] more lines"
        }
    }
    return $ok
}

proc readText {path} {
    set channel [open $path r]
    fconfigure $channel -encoding utf-8
    try { return [read $channel] } finally { close $channel }
}

proc writeText {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

# Runs ARGS (a command and its arguments) with standard output and error
# captured apart: {STATUS STDOUT STDERR}, STATUS the exit status, or
# "signal NAME" for a process a signal killed.
proc run {args} {
    global work
    set out [file join $work stdout.txt]
    set err [file join $work stderr.txt]
    set code [catch {exec {*}$args > $out 2> $err} message options]
    set stdout [readText $out]
    set stderr [readText $err]
    if {$code == 0} {
        return [list 0 $stdout $stderr]
    }
    set errorCode [dict get $options -errorcode]
    switch -- [lindex $errorCode 0] {
        CHILDSTATUS { return [list [lindex $errorCode 2] $stdout $stderr] }
        CHILDKILLED { return [list "signal [lindex $errorCode 2]" $stdout $stderr] }
        default { return [list "cannot run: $message" $stdout $stderr] }
    }
}

# A run's {STATUS STDOUT STDERR} on one line.
proc shown {outcome} {
    lassign $outcome status stdout stderr
    set escape {apply {{text} {string map [list \n \\n] $text}}}
    return "exit $status, stdout \"[{*}$escape $stdout]\", stderr \"[{*}$escape $stderr]\""
}

# A host tool's standard output (and error), or "" with the reason in
# ::toolError when it is not installed or fails.
proc tool {args} {
    set ::toolError ""
    if {[auto_execok [lindex $args 0]] eq ""} {
        set ::toolError "[lindex $args 0] is not installed"
        return ""
    }
    lassign [run {*}$args] status stdout stderr
    if {$status ne "0"} {
        set ::toolError "[join $args] exited $status: $stderr"
    }
    return "$stdout$stderr"
}

# The Mach-O header flags of PATH (MH_PIE is 0x200000), or "".
proc machoFlags {path} {
    set channel [open $path rb]
    set bytes [read $channel 32]
    close $channel
    binary scan $bytes @24iu flags
    return $flags
}

# Links source TEXT (named NAME.bot) into runDir/NAME and runs it as
# standalone runs it: an empty environment but ENVIRONMENT, another working
# directory.
proc standalone {name text environment} {
    global runDir cwdDir
    set hir [surface::compile $text $name.bot -warnings off]
    set path [file join $runDir $name]
    native::executable $hir $path
    return [run env -i PATH=/nonexistent {*}$environment /bin/sh -c {cd "$1" && exec "$2"} sh $cwdDir $path]
}

# {FAILED MESSAGE COMMAND NAMED} of linking HIR into PATH while rustc prints
# the platform linker's command line (`--print link-args`, through a wrapper
# given as RUSTC: the link itself is native::executable's): whether the
# link failed and its message, the command, and the command with this run's
# temporary paths named (BUILD, RELEASE, WORK, SYSROOT, LINKDIR).
proc linkCommand {hir path} {
    global work
    set wrapper [file join $work rustc-print-link-args]
    set printed [file join $work link-args.txt]
    file delete -force $printed
    writeText $wrapper "#!/bin/sh\nexec \"\$REAL_RUSTC\" --print link-args \"\$@\" > \"$printed\"\n"
    file attributes $wrapper -permissions 0755
    set saved [array get ::env RUSTC]
    set ::env(REAL_RUSTC) [expr {$saved ne {} ? [lindex $saved 1] : "rustc"}]
    set ::env(RUSTC) $wrapper
    try {
        set relinked [catch {native::executable $hir $path} message]
    } finally {
        unset ::env(RUSTC) ::env(REAL_RUSTC)
        if {$saved ne {}} { set ::env(RUSTC) [lindex $saved 1] }
    }
    set command [expr {[file exists $printed] ? [string trim [readText $printed]] : ""}]
    set release [file dirname [native::binary]]
    # rustc prints the linker's environment first: on macOS `env -u NAME
    # ...`, then NAME="VALUE" assignments.
    regsub {^env(\s+-u\s+\S+)*\s+} $command {} command
    regsub {^(\w+="[^"]*"\s+)*} $command {} command
    set sysroot [string trim [lindex [run rustc --print sysroot] 1]]
    # A -L directory reaches the linker normalized (native::withLinkDirs):
    # on macOS the temporary directory's /var is /private/var.
    set named [string map [list [file join $work "build dir"] BUILD $release RELEASE [file normalize $work] WORK $work WORK] $command]
    if {$sysroot ne ""} { set named [string map [list $sysroot SYSROOT] $named] }
    regsub -all {"[^"]*/\.botlish-aot-[^/"]*/} $named {"LINKDIR/} named
    return [list $relinked $message $command $named]
}

# C calls (MACOS-AARCH64-MILESTONE-6.md): a static C library compiled here
# by the host's C compiler, its symbol as the object format spells it; a
# program calling it (narrow signed and unsigned arguments, a `named` link
# symbol) and the system C library's labs, linked with the platform
# linker's link plan -- its command line printed -- and run standalone; the
# system function imported from the system's C library; and the platform
# linker's own words for a missing library and an undefined symbol.
proc cCalls {} {
    global work runDir prefix macos
    set lib [file join $work "c lib"]
    file mkdir $lib
    writeText [file join $lib facts.c] "long bcfx_widen(signed char c, unsigned short s, long l) { return c * 100000L + s + l; }\n"
    lassign [run cc -c -O2 -fPIC [file join $lib facts.c] -o [file join $lib facts.o]] status stdout stderr
    if {$status eq "0"} {
        lassign [run ar rcs [file join $lib libbotlish_aot_facts.a] [file join $lib facts.o]] status stdout stderr
    }
    set symbols [tool nm -g [file join $lib libbotlish_aot_facts.a]]
    set header [expr {[file exists [file join $lib facts.o]] ? [binaryHeader [file join $lib facts.o]] : ""}]
    if {![check c-library [expr {$status eq "0" && $header eq [hostBinaryHeader object] && [regexp -line "T ${prefix}bcfx_widen\$" $symbols]}] \
            "libbotlish_aot_facts.a: $header, defines ${prefix}bcfx_widen: [regexp -line "T ${prefix}bcfx_widen\$" $symbols]" "$stderr$symbols"]} {
        return
    }
    set decls "import ffi::c\n\nextern c library \"botlish_aot_facts\"\n\nextern c fn labs(x: ffi::c::Long) -> ffi::c::Long\nextern c fn widen named \"bcfx_widen\"(c: ffi::c::SChar, s: ffi::c::UShort, l: ffi::c::Long) -> ffi::c::Long\n"
    set text "$decls\n\[labs(-42), widen(-1, 65535, 7)\]\n"
    set started [clock microseconds]
    if {[catch {native::withLinkDirs [list $lib] {standalone c-call $text {}}} outcome options]} {
        check c-call-run 0 "the link failed: [lrange [dict get $options -errorcode] 0 1]" $outcome
        return
    }
    set ms [expr {([clock microseconds] - $started) / 1000}]
    check c-call-run [expr {$outcome eq [list 0 "\[42, -34458\]\n" ""]}] "[shown $outcome] ($ms ms, link included)"

    set exe [file join $runDir c-call]
    if {$macos} {
        set imports [tool nm -m $exe]
        set from [lindex [regexp -inline -line "\\(undefined\\) external _labs \\(from (\\S+)\\)" $imports] 1]
        check c-call-import [expr {$from eq "libSystem"}] "_labs imported from [expr {$from eq "" ? "nothing" : $from}]" $::toolError
    } else {
        set imports [tool nm -D $exe]
        set from [lindex [regexp -inline -line {^\s+U labs@(\S+)$} $imports] 1]
        check c-call-import [string match GLIBC_* $from] "labs imported, version [expr {$from eq "" ? "none" : $from}]" $::toolError
    }

    lassign [native::withLinkDirs [list $lib] {linkCommand [surface::compile $text c-call.bot -warnings off] [file join $work c-relinked]}] failed message command named
    set group [expr {[string first --start-group $command] >= 0}]
    set nodefault [expr {[string first -nodefaultlibs $command] >= 0}]
    check c-link-command [expr {!$failed && [string first -lbotlish_aot_facts $command] >= 0 && [string first "-L[file normalize $lib]" $command] >= 0
            && $group == !$macos && !$nodefault}] \
        "-lbotlish_aot_facts and -L its directory passed; GNU archive group: $group; -nodefaultlibs: $nodefault" \
        [expr {$failed ? $message : $named}]

    set missing [surface::compile "import ffi::c\n\nextern c library \"botlish_aot_facts_missing\"\n\n1 + 1\n" missing.bot -warnings off]
    set failed [catch {native::executable $missing [file join $work missing]} message options]
    check c-link-missing-library [expr {$failed && [lrange [dict get $options -errorcode] 0 1] eq {NATIVE LINK}
            && [regexp {botlish_aot_facts_missing} [join [lrange [split $message \n] 1 end] \n]]}] \
        "[expr {$failed ? [lrange [dict get $options -errorcode] 0 1] : "linked"}]: the linker names the library" $message
    set undefined [surface::compile "$decls\nextern c fn nope named \"botlish_aot_facts_nope\"(x: ffi::c::Int) -> ffi::c::Int\n\nnope(1)\n" undefined.bot -warnings off]
    set failed [native::withLinkDirs [list $lib] {catch {native::executable $undefined [file join $work undefined]} message options}]
    check c-link-undefined-symbol [expr {$failed && [lrange [dict get $options -errorcode] 0 1] eq {NATIVE LINK}
            && [regexp {botlish_aot_facts_nope} [join [lrange [split $message \n] 1 end] \n]]}] \
        "[expr {$failed ? [lrange [dict get $options -errorcode] 0 1] : "linked"}]: the linker names the symbol" $message
}

proc checks {} {
    global work facts prefix macos root program programValue coroutineProgram downProgram
    global coroutineOverflowProgram errorProgram overflowLine runDir cwdDir
    set sourceDir [file join $work "source dir"]
    set buildDir [file join $work "build dir"]
    set runDir [file join $work "run dir"]
    set cwdDir [file join $work "elsewhere"]
    file mkdir $sourceDir $buildDir $runDir $cwdDir
    set source [file join $sourceDir probe.bot]
    writeText $source $program
    set hir [surface::readProgramFile $source -warnings off]

    # ---- The object.
    set object [file join $buildDir probe.o]
    set started [clock microseconds]
    native::object $hir $object
    set objectMs [expr {([clock microseconds] - $started) / 1000}]
    set objectHeader [binaryHeader $object]
    set flags ""
    if {[lindex $objectHeader 0] eq "macho"} {
        # MH_SUBSECTIONS_VIA_SYMBOLS (0x2000): cranelift-object's, what lets
        # Apple's ld dead-strip per symbol.
        set flags [format ", flags 0x%x" [machoFlags $object]]
    }
    check object-header [expr {$objectHeader eq [dict get $facts object] && $objectHeader eq [hostBinaryHeader object]}] "$objectHeader$flags ([file size $object] bytes, $objectMs ms)"
    set described [string trim [string range [tool file -b $object] 0 end]]
    check object-file [string match [dict get $facts objectFile] $described] $described

    set symbols [tool nm -P $object]
    set defined {}
    set undefined {}
    set local {}
    foreach line [split $symbols \n] {
        lassign $line name type
        if {$name eq ""} continue
        if {$type eq "U"} { lappend undefined $name } elseif {$type in {T D B S}} { lappend defined $name } else { lappend local $name }
    }
    set functions [regexp -all {botlish_fn_[0-9]+} $symbols]
    set wanted {}
    set missing {}
    foreach name [lsearch -all -inline -regexp $defined "^${prefix}botlish_(fn|entry)_\[0-9\]+\$"] {
        lappend wanted $name
    }
    set decorated [lsearch -all -inline -regexp [concat $defined $undefined $local] {botlish_|rt_}]
    set misdecorated [lsearch -all -inline -not -regexp $decorated "^${prefix}(botlish_|rt_)"]
    set helpers [lsearch -all -inline -regexp $undefined "^${prefix}rt_"]
    set context [lsearch -all -inline -exact $local ${prefix}botlish_context_area]
    check object-symbols [expr {$::toolError eq "" && [llength $wanted] >= 8 && [llength $wanted] % 2 == 0
            && [llength $helpers] > 0 && [llength $context] == 1 && $misdecorated eq ""
            && [lsearch -regexp $defined "^${prefix}botlish_fn_0\$"] >= 0}] \
        "[expr {[llength $wanted] / 2}] functions defined (${prefix}botlish_fn_N and ${prefix}botlish_entry_N), [llength $helpers] runtime helpers undefined (${prefix}rt_*), context area local: [expr {$context ne {}}], misdecorated: [expr {$misdecorated eq {} ? "none" : $misdecorated}]" \
        "$::toolError$symbols"

    set relocations [tool objdump -r $object]
    set types [dict create]
    foreach line [split $relocations \n] {
        if {[regexp {^[0-9a-fA-F]+\s+(\S+)\s+(\S+)} $line -> type value]} {
            regsub {[-+].*$} $value {} value
            dict lappend types $type $value
        }
    }
    set contextTypes {}
    set helperTypes {}
    dict for {type values} $types {
        if {"${prefix}botlish_context_area" in $values} { lappend contextTypes $type }
        if {[lsearch -glob $values "${prefix}rt_*"] >= 0} { lappend helperTypes $type }
    }
    set foreign {}
    foreach pattern [dict get $facts foreignRelocs] {
        lappend foreign {*}[lsearch -all -inline -glob [dict keys $types] $pattern]
    }
    set contextOk [expr {[llength [lmap t [dict get $facts contextReloc] {expr {$t in $contextTypes ? $t : [continue]}}]] > 0}]
    set helperOk [expr {[llength [lmap t [dict get $facts helperReloc] {expr {$t in $helperTypes ? $t : [continue]}}]] > 0}]
    check object-relocations [expr {$::toolError eq "" && $contextOk && $helperOk && $foreign eq ""}] \
        "types [lsort [dict keys $types]]; context area: [lsort $contextTypes]; helpers: [lsort $helperTypes]" \
        "$::toolError$relocations"

    if {$macos} {
        set loads [tool otool -l $object]
        set version ""
        if {[regexp {cmd LC_BUILD_VERSION.*?platform (\S+).*?minos (\S+)} $loads -> platform minos]} {
            set version "platform $platform minos $minos"
        }
        check object-build-version [expr {$::toolError eq "" && [regexp {^platform (1|MACOS|macos) } $version]}] \
            [expr {$version eq "" ? "no LC_BUILD_VERSION" : $version}] "$::toolError$loads"
    }

    # ---- The executable.
    set executable [file join $buildDir "probe program"]
    set started [clock microseconds]
    set linked [catch {native::executable $hir $executable} message options]
    set linkMs [expr {([clock microseconds] - $started) / 1000}]
    if {$linked} {
        check executable-link 0 "[dict get $options -errorcode]: [lindex [split $message \n] 0]" $message
        return
    }
    if {![file executable $executable]} {
        check executable-link 0 "linked in $linkMs ms, but no executable at $executable"
        return
    }
    check executable-link 1 "linked in $linkMs ms ([file size $executable] bytes), mode [file attributes $executable -permissions]"
    set executableHeader [binaryHeader $executable]
    set pie ""
    if {[lindex $executableHeader 0] eq "macho"} {
        set flags [machoFlags $executable]
        set pie [format "%s, flags 0x%x" [expr {$flags & 0x200000 ? " pie" : " not pie"}] $flags]
    }
    check executable-header [expr {$executableHeader eq [dict get $facts executable]
        && $executableHeader eq [hostBinaryHeader executable] && ![string match " not pie*" $pie]}] "$executableHeader$pie"
    set described [string trim [tool file -b $executable]]
    check executable-file [string match [dict get $facts executableFile] $described] $described
    if {$macos} {
        set archs [string trim [tool lipo -archs $executable]]
        check executable-thin [expr {$archs eq "arm64"}] "lipo -archs: $archs" $::toolError
        set verified [tool codesign -v $executable]
        set verifyError $::toolError
        set signature [tool codesign -dv $executable]
        regexp -line {^CodeDirectory .*flags=(\S+)} $signature -> flags
        check executable-signature [expr {$verifyError eq ""}] \
            "codesign -v: [expr {$verifyError eq "" ? "valid" : "invalid"}], flags [expr {[info exists flags] ? $flags : "?"}]" \
            "$verifyError$verified$signature"
        set libraries [tool otool -L $executable]
        set paths [lmap line [lrange [split [string trim $libraries] \n] 1 end] {lindex [string trim $line] 0}]
        set system [lmap p $paths {expr {[string match /usr/lib/* $p] || [string match /System/* $p] ? [continue] : $p}}]
    } else {
        set libraries [tool ldd $executable]
        set paths {}
        foreach line [split [string trim $libraries] \n] {
            set line [string trim $line]
            if {[regexp {=> (\S+)} $line -> p] || [regexp {^(/\S+)} $line -> p]} { lappend paths $p }
        }
        set system [lmap p $paths {expr {[string match /lib*/* $p] || [string match /usr/lib*/* $p] ? [continue] : $p}}]
    }
    set ours [lmap p $paths {expr {[string first $root $p] == 0 || [string match */target/* $p] || [string match *rustup* $p] ? $p : [continue]}}]
    check executable-libraries [expr {$::toolError eq "" && $paths ne "" && $system eq "" && $ours eq ""}] \
        "[llength $paths] dynamic libraries: [join [lmap p $paths {file tail $p}] {, }]" "$::toolError$libraries"
    set exeSymbols [tool nm -P $executable]
    check executable-symbols [expr {[regexp -line "^${prefix}botlish_fn_0 T " $exeSymbols]}] \
        "${prefix}botlish_fn_0 [expr {[regexp -line "^${prefix}botlish_fn_0 T " $exeSymbols] ? "defined" : "missing"}] in the executable" $::toolError

    # The platform linker's command line, as rustc runs it for this link
    # (`--print link-args`, through a wrapper given as RUSTC: the link
    # itself is native::executable's): the linker program and its options,
    # with this run's temporary paths named.
    lassign [linkCommand $hir [file join $buildDir relinked]] relinked message command named
    set linker [lindex [regexp -inline {^"?([^" ]+)} $named] 1]
    check executable-link-command [expr {!$relinked && $command ne "" && [string first program.o $command] >= 0
        && [string first libbotlish_native.rlib $command] >= 0}] \
        "linker [file tail $linker], [llength [regexp -all -inline {"[^"]*"|\S+} $named]] arguments, program.o and libbotlish_native.rlib among them" \
        [expr {$relinked ? $message : $named}]

    # ---- Standalone: moved, source deleted, empty environment, another
    # working directory.
    set moved [file join $runDir "moved program"]
    file rename $executable $moved
    file delete -force $sourceDir
    set started [clock microseconds]
    set outcome [run env -i PATH=/nonexistent /bin/sh -c {cd "$1" && exec "$2"} sh $cwdDir $moved]
    set runMs [expr {([clock microseconds] - $started) / 1000}]
    check standalone-run [expr {$outcome eq [list 0 "$programValue\n" ""]}] "[shown $outcome] ($runMs ms)"
    set outcome [run env -i PATH=/nonexistent BOTLISH_NATIVE_GC_STRESS=1 /bin/sh -c {cd "$1" && exec "$2"} sh $cwdDir $moved]
    check standalone-gc-stress [expr {$outcome eq [list 0 "$programValue\n" ""]}] [shown $outcome]

    # The other programs, each linked and run likewise.
    set outcome [standalone coroutine $coroutineProgram {}]
    check standalone-coroutine [expr {$outcome eq [list 0 "\[10, 7\]\n" ""]}] [shown $outcome]
    set outcome [run env -i BOTLISH_NATIVE_GC_STRESS=1 [file join $runDir coroutine]]
    check standalone-coroutine-gc [expr {$outcome eq [list 0 "\[10, 7\]\n" ""]}] [shown $outcome]
    set outcome [standalone error $errorProgram {}]
    check standalone-error [expr {[lindex $outcome 0] eq "1" && [lindex $outcome 1] eq ""
        && [string match "*(CORE SEMANTIC RANGE)\n" [lindex $outcome 2]]}] [shown $outcome]
    set outcome [standalone down [string map {DEPTH 100000} $downProgram] {}]
    check standalone-deep-finite [expr {$outcome eq [list 0 "100000\n" ""]}] [shown $outcome]
    set started [clock microseconds]
    set outcome [standalone overflow [string map {DEPTH 100000000} $downProgram] {BOTLISH_NATIVE_STACK_BYTES=16777216}]
    set overflowMs [expr {([clock microseconds] - $started) / 1000}]
    check standalone-stack-overflow [expr {$outcome eq [list 1 "" "$overflowLine\n"]}] "[shown $outcome] ($overflowMs ms, link included)"
    set outcome [run env -i [file join $runDir overflow]]
    check standalone-overflow-default [expr {$outcome eq [list 1 "" "$overflowLine\n"]}] "1 GiB stack: [shown $outcome]"
    set outcome [standalone co-overflow $coroutineOverflowProgram {}]
    check standalone-co-overflow [expr {$outcome eq [list 1 "" "$overflowLine\n"]}] [shown $outcome]

    cCalls

    # ---- Observations, not limits: the same program's best run in the JIT
    # (native::measure) and inside its executable (the driver protocol's
    # BOTLISH_NATIVE_RUNS, timed by the executable itself), and an
    # executable's whole process (startup included) for a trivial program,
    # the median of five. Checked only for the right value.
    global benchProgram benchValue
    set runs 20
    set hir [surface::compile $benchProgram bench.bot -warnings off]
    lassign [native::measure $hir $runs] - - jitBest - jitValue
    set path [file join $runDir bench]
    native::executable $hir $path
    set result [file join $work result.txt]
    lassign [run env BOTLISH_NATIVE_RESULT=$result BOTLISH_NATIVE_RUNS=$runs $path] status
    set lines [split [string trim [readText $result]] \n]
    set times [lrange [lsearch -inline $lines {times *}] 1 end]
    set aotBest [expr {[llength $times] ? [tcl::mathfunc::min {*}$times] / 1000.0 : 0}]
    set aotValue [lindex [lsearch -inline $lines {value *}] 1]
    check performance-compute [expr {$status eq "0" && [core::formatValue $jitValue] eq $benchValue && $aotValue ne "" && [core::formatValue $aotValue] eq $benchValue && $aotBest > 0}] \
        [format "best of %d runs: JIT %.0f us, executable %.0f us (ratio %.2f)" $runs $jitBest $aotBest [expr {$aotBest / max($jitBest, 1)}]]
    native::executable [surface::compile 42 trivial.bot] [file join $runDir trivial]
    set walls {}
    for {set i 0} {$i < 5} {incr i} {
        set started [clock microseconds]
        lassign [run [file join $runDir trivial]] status stdout
        lappend walls [expr {([clock microseconds] - $started) / 1000.0}]
    }
    set median [lindex [lsort -real $walls] 2]
    check performance-startup [expr {$status eq "0" && $stdout eq "42\n"}] \
        [format "a trivial executable's whole process: median %.1f ms of five (%s)" $median [join [lmap w $walls {format %.1f $w}] {, }]]
}

# The checks on Windows (this file's header). The system directory, read
# once (System32 of the Windows directory).
if {$::tcl_platform(platform) eq "windows"} {
    set systemDir [file join [if {[info exists ::env(SystemRoot)]} {set ::env(SystemRoot)} else {set ::env(WINDIR)}] System32]
}
proc windowsChecks {} {
    global work facts program programValue coroutineProgram downProgram errorProgram overflowLine root
    set sourceDir [file join $work "source dir"]
    set buildDir [file join $work "build dir"]
    set runDir [file join $work "run dir"]
    set cwdDir [file join $work "elsewhere"]
    file mkdir $sourceDir $buildDir $runDir $cwdDir
    set source [file join $sourceDir probe.bot]
    writeText $source $program
    set hir [surface::readProgramFile $source -warnings off]

    # ---- The object.
    set object [file join $buildDir probe.obj]
    set started [clock microseconds]
    native::object $hir $object
    set objectMs [expr {([clock microseconds] - $started) / 1000}]
    set header [binaryHeader $object]
    check object-header [expr {$header eq [dict get $facts object] && $header eq [hostBinaryHeader object]}] "$header ([file size $object] bytes, $objectMs ms)"
    set coff [coffFacts $object]
    set defined {}
    set undefined {}
    foreach symbol [dict get $coff symbols] {
        lassign $symbol name section class
        if {$class != 2} continue
        if {$section == 0} { lappend undefined $name } elseif {$section > 0} { lappend defined $name }
    }
    set functions [lsearch -all -inline -regexp $defined {^botlish_(fn|entry)_[0-9]+$}]
    set helpers [lsearch -all -inline -regexp $undefined {^rt_}]
    set misdecorated [lsearch -all -inline -regexp [concat $defined $undefined] {^_+(botlish|rt)_}]
    set context [lsearch -all -inline -exact [lmap s [dict get $coff symbols] {lindex $s 0}] botlish_context_area]
    check object-symbols [expr {[llength $functions] >= 8 && [llength $functions] % 2 == 0 && [llength $helpers] > 0
            && "botlish_fn_0" in $defined && $misdecorated eq "" && [llength $context] == 1}] \
        "[expr {[llength $functions] / 2}] functions defined (botlish_fn_N, botlish_entry_N), [llength $helpers] runtime helpers undefined (rt_*), context area: [llength $context], decorated: [expr {$misdecorated eq {} ? "none" : $misdecorated}]" \
        [join [dict get $coff symbols] \n]
    set types [lsort -unique [lmap r [dict get $coff relocations] {lindex $r 1}]]
    set foreign [lmap t $types {expr {$t in [dict get $facts relocTypes] ? [continue] : $t}}]
    check object-relocations [expr {$types ne "" && $foreign eq ""}] \
        "sections [dict get $coff sections]; relocation types $types" [join [dict get $coff relocations] \n]

    # ---- The executable: NAME.exe for NAME.
    set started [clock microseconds]
    set linked [catch {native::executable $hir [file join $buildDir "probe program"]} executable options]
    set linkMs [expr {([clock microseconds] - $started) / 1000}]
    if {$linked} {
        check executable-link 0 "[dict get $options -errorcode]: [lindex [split $executable \n] 0]" $executable
        return
    }
    check executable-link [expr {[file tail $executable] eq "probe program.exe" && [file isfile $executable]}] \
        "linked in $linkMs ms: [file tail $executable] ([file size $executable] bytes)"
    set header [binaryHeader $executable]
    check executable-header [expr {$header eq [dict get $facts executable] && $header eq [hostBinaryHeader executable]}] $header
    set pe [peFacts $executable]
    check executable-subsystem [expr {[dict get $pe subsystem] == 3}] "subsystem [dict get $pe subsystem] (3: the Windows console)"
    # Every imported DLL the system's: an API set (resolved by the loader,
    # no file) or a file of the system directory; none of the Visual C++
    # runtime's (vcruntime, msvcp, concrt) or the UCRT's (ucrtbase,
    # api-ms-win-crt-*): the C runtime is linked statically (codegen/aot.rs's
    # crt_args).
    set system $::systemDir
    set imports [lsort -unique -nocase [dict get $pe imports]]
    set crt [lsearch -all -inline -regexp -nocase $imports {^(vcruntime|msvcp|concrt|ucrtbase|api-ms-win-crt-)}]
    set foreign [lmap dll $imports {
        expr {[string match -nocase api-ms-win-* $dll] || [string match -nocase ext-ms-* $dll] || [file isfile [file join $system $dll]] ? [continue] : $dll}
    }]
    check executable-imports [expr {$imports ne "" && $crt eq "" && $foreign eq ""}] \
        "[llength $imports] DLLs: [join $imports {, }]; C runtime DLLs: [expr {$crt eq "" ? "none" : $crt}]; not the system's: [expr {$foreign eq "" ? "none" : $foreign}]"

    # ---- Standalone: moved, source deleted, run from another directory
    # with only the system directory on PATH.
    set moved [file join $runDir "moved program.exe"]
    file rename $executable $moved
    file delete -force $sourceDir
    set started [clock microseconds]
    set outcome [windowsRun $cwdDir $moved {}]
    set runMs [expr {([clock microseconds] - $started) / 1000}]
    check standalone-run [expr {$outcome eq [list 0 "$programValue\n" ""]}] "[shown $outcome] ($runMs ms)"
    set outcome [windowsRun $cwdDir $moved {BOTLISH_NATIVE_GC_STRESS 1}]
    check standalone-gc-stress [expr {$outcome eq [list 0 "$programValue\n" ""]}] [shown $outcome]
    set standalone {apply {{runDir cwdDir name text environment} {
        set path [native::executable [surface::compile $text $name.bot -warnings off] [file join $runDir $name]]
        return [windowsRun $cwdDir $path $environment]
    }}}
    set outcome [{*}$standalone $runDir $cwdDir error $errorProgram {}]
    check standalone-error [expr {[lindex $outcome 0] eq "1" && [lindex $outcome 1] eq ""
        && [string match "*(CORE SEMANTIC RANGE)\n" [lindex $outcome 2]]}] [shown $outcome]
    set outcome [{*}$standalone $runDir $cwdDir down [string map {DEPTH 100000} $downProgram] {}]
    check standalone-deep-finite [expr {$outcome eq [list 0 "100000\n" ""]}] [shown $outcome]
    # The shadow stack's depth check (codegen::roots's depth_reservation)
    # bounds Botlish recursion on the default 1 GiB stack: NATIVE LIMIT
    # STACK, exit status 1, as everywhere -- an ordinary run-time error
    # here, which the executable reports as it reports every one (MESSAGE
    # (CODE), like standalone-error), where the guard of the other hosts
    # writes its own fixed line ($overflowLine). A smaller stack is
    # exhausted first, and with no stack guard yet the process ends in
    # Rust's own stack overflow report, a failure status.
    set outcome [{*}$standalone $runDir $cwdDir overflow [string map {DEPTH 100000000} $downProgram] {}]
    check standalone-depth-limit [expr {$outcome eq [list 1 "" "native stack exhausted: too many nested calls (NATIVE LIMIT STACK)\n"]}] "1 GiB stack: [shown $outcome]"
    set outcome [windowsRun $cwdDir [file join $runDir overflow.exe] {BOTLISH_NATIVE_STACK_BYTES 16777216}]
    check standalone-stack-overflow [expr {[lindex $outcome 0] ni {0 1} && [lindex $outcome 1] eq ""
        && [string match "*has overflowed its stack*" [lindex $outcome 2]]}] "16 MiB stack, no guard: [shown $outcome]"
    set outcome [{*}$standalone $runDir $cwdDir coroutine $coroutineProgram {}]
    check standalone-coroutine-refused [expr {[lindex $outcome 0] eq "1" && [lindex $outcome 1] eq ""
        && [string match "native coroutines need stack switching*(NATIVE UNSUPPORTED value)\n" [lindex $outcome 2]]}] [shown $outcome]
    set failed [catch {native::executable [surface::compile "import ffi::c\n\nextern c fn labs(x: ffi::c::Long) -> ffi::c::Long\n\nlabs(-5)\n" c-call.bot -warnings off] [file join $runDir c-call]} message options]
    check c-call-refused [expr {$failed && [lrange [dict get $options -errorcode] 0 1] eq {NATIVE LINK}
        && [string match "*C calls are linked on Linux glibc (x86_64, aarch64) and macOS (aarch64) only*" $message]
        && ![file exists [file join $runDir c-call.exe]]}] \
        "[expr {$failed ? [lrange [dict get $options -errorcode] 0 1] : "linked"}]: refused before the linker runs" $message

    # ---- Observations, not limits (as checks' own).
    global benchProgram benchValue
    set runs 20
    set hir [surface::compile $benchProgram bench.bot -warnings off]
    lassign [native::measure $hir $runs] - - jitBest - jitValue
    set path [native::executable $hir [file join $runDir bench]]
    set result [file join $work result.txt]
    lassign [windowsRun $cwdDir $path [list BOTLISH_NATIVE_RESULT $result BOTLISH_NATIVE_RUNS $runs]] status
    set lines [split [string trim [readText $result]] \n]
    set times [lrange [lsearch -inline $lines {times *}] 1 end]
    set aotBest [expr {[llength $times] ? [tcl::mathfunc::min {*}$times] / 1000.0 : 0}]
    set aotValue [lindex [lsearch -inline $lines {value *}] 1]
    check performance-compute [expr {$status eq "0" && [core::formatValue $jitValue] eq $benchValue && $aotValue ne "" && [core::formatValue $aotValue] eq $benchValue && $aotBest > 0}] \
        [format "best of %d runs: JIT %.0f us, executable %.0f us (ratio %.2f)" $runs $jitBest $aotBest [expr {$aotBest / max($jitBest, 1)}]]
    set trivial [native::executable [surface::compile 42 trivial.bot] [file join $runDir trivial]]
    set walls {}
    for {set i 0} {$i < 5} {incr i} {
        set started [clock microseconds]
        lassign [windowsRun $cwdDir $trivial {}] status stdout
        lappend walls [expr {([clock microseconds] - $started) / 1000.0}]
    }
    set median [lindex [lsort -real $walls] 2]
    check performance-startup [expr {$status eq "0" && $stdout eq "42\n"}] \
        [format "a trivial executable's whole process: median %.1f ms of five (%s)" $median [join [lmap w $walls {format %.1f $w}] {, }]]
}

# Runs the executable PATH in the directory CWD with only the system
# directory on PATH and the environment ENVIRONMENT ({NAME VALUE ...}) added:
# run's {STATUS STDOUT STDERR}. (Windows: no `env -i`; the C runtime and the
# loader need SystemRoot, which stays.)
proc windowsRun {cwd path environment} {
    set names [concat PATH [dict keys $environment]]
    set saved [dict create]
    foreach name $names {
        if {[info exists ::env($name)]} { dict set saved $name $::env($name) }
    }
    set here [pwd]
    try {
        set ::env(PATH) [file nativename $::systemDir]
        foreach {name value} $environment { set ::env($name) $value }
        cd $cwd
        return [run $path]
    } finally {
        cd $here
        foreach name $names { unset -nocomplain ::env($name) }
        dict for {name value} $saved { set ::env($name) $value }
    }
}

puts "aot facts on $host ($::tcl_platform(os) $::tcl_platform(machine)), driver [native::binary]"
try {
    if {[string match windows-* $host]} {
        windowsChecks
    } else {
        checks
    }
} finally {
    file delete -force $work
}
if {$failures} {
    puts "FAIL: $failures checks of this host's native objects and executables differ from what is recorded for $host"
    exit 1
}
puts "ok: native objects and executables on $host are as recorded"

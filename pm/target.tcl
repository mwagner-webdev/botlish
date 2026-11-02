# target.tcl -- compilation targets as the package manager sees them
# (PACKAGE-MANAGER-MILESTONE-2.md, "Targets").
#
#   pm::target::names              the compiler's target names, sorted
#   pm::target::isTarget NAME
#   pm::target::host               this machine's target, or ""
#   pm::target::facts NAME         {os ARCH arch ARCH libc gnu|"" format
#                                  elf|macho|pe ...}: what a native file of
#                                  the target is (pm/binary.tcl's terms)
#   pm::target::platformLibrary NAME IDENTITY   1 if the loader identity
#                                  IDENTITY is part of the target's platform
#   pm::target::linkFiles NAME LIBRARY LINKAGE  the file names a linker
#                                  searches for LIBRARY (libX.a, X.lib, ...)
#
# The names are the compiler's own (core/cabi.tcl's `targets` table: an
# operating system *and* an architecture, and on Windows the C toolchain's
# ABI family), read from that file's text as data -- never copied, and never
# by loading the compiler (the package manager runs without it). A package
# names a target exactly as `-target` does: there is no second naming
# convention. linux-x86_64 and linux-aarch64 are the GNU C library's
# targets (the compiler's triples say -gnu); a library built against musl
# is another target's, which the table does not have, and is refused as one
# (pm/native.tcl).

namespace eval pm::target {
    variable table ""
    # What a native file of each operating system and architecture is, in
    # pm/binary.tcl's terms: the object format, ELF's e_machine, Mach-O's
    # cputype, PE/COFF's Machine.
    variable machines [dict create \
        x86_64  {elf 62 macho 0x01000007 pe 0x8664} \
        aarch64 {elf 183 macho 0x0100000c pe 0xaa64}]
    variable formats [dict create linux elf macos macho windows pe]
}

# The compiler's target table (NAME -> {os OS arch ARCH triple T ...}),
# parsed from core/cabi.tcl's `variable targets [dict create ...]` as a
# list: nothing of the file is evaluated.
proc pm::target::Table {} {
    variable table
    if {$table ne ""} {
        return $table
    }
    set text [pm::ReadBytes [file join $::pm::root core cabi.tcl]]
    if {![regexp {variable targets \[dict create \\\n(.*?)\]\n} $text -> body]} {
        error "pm::target: core/cabi.tcl has no target table"
    }
    set body [string map [list \\\n " "] $body]
    if {[catch {llength $body} n] || $n % 2} {
        error "pm::target: core/cabi.tcl's target table is not a list of pairs"
    }
    set table [dict create {*}$body]
    return $table
}

proc pm::target::names {} {
    return [lsort [dict keys [Table]]]
}

proc pm::target::isTarget {name} {
    return [dict exists [Table] $name]
}

# The target of this machine (core::cabi::hostTarget's rule), or "".
proc pm::target::host {} {
    set os [string tolower $::tcl_platform(os)]
    switch -glob -- $os {
        linux { set os linux }
        darwin { set os macos }
        windows* { set os windows }
        default { return "" }
    }
    switch -- [string tolower $::tcl_platform(machine)] {
        x86_64 - amd64 - intel64 { set arch x86_64 }
        aarch64 - arm64 { set arch aarch64 }
        default { return "" }
    }
    if {[isTarget $os-$arch]} {
        return $os-$arch
    }
    return ""
}

# The native facts of target NAME: its os, arch, triple, object format
# (elf, macho or pe), machine number in that format, C library family
# (gnu on Linux, "" elsewhere), Windows toolchain (msvc or gnu, "" elsewhere),
# and whether it has frameworks.
proc pm::target::facts {name} {
    variable machines
    variable formats
    set row [dict get [Table] $name]
    set os [dict get $row os]
    set arch [dict get $row arch]
    set format [dict get $formats $os]
    set triple [dict get $row triple]
    set toolchain ""
    if {$os eq "windows"} {
        set toolchain [expr {[string match *-gnu $triple] ? "gnu" : "msvc"}]
    }
    return [dict create name $name os $os arch $arch triple $triple format $format \
        machine [dict get $machines $arch $format] \
        libc [expr {$os eq "linux" ? "gnu" : ""}] toolchain $toolchain \
        frameworks [expr {$os eq "macos"}]]
}

# The file names under which a linker given the library LIBRARY by name
# finds its LINKAGE (static, shared, import) form on target NAME: what a
# bundled library is called in a target view's library directory.
proc pm::target::linkFile {name library linkage} {
    set facts [facts $name]
    switch -- [dict get $facts os] {
        linux {
            return [dict get {static lib%s.a shared lib%s.so} $linkage]
        }
        macos {
            return [dict get {static lib%s.a shared lib%s.dylib} $linkage]
        }
        windows {
            if {[dict get $facts toolchain] eq "msvc"} {
                return [dict get {static %s.lib import %s.lib} $linkage]
            }
            return [dict get {static lib%s.a import lib%s.dll.a} $linkage]
        }
    }
}

proc pm::target::linkFiles {name library linkage} {
    return [format [linkFile $name $library $linkage] $library]
}

# 1 if the loader identity IDENTITY (an ELF DT_NEEDED name, a Mach-O
# install name, a DLL name) is part of target NAME's platform: present on
# every installation of the target, so no package declares it. Linux: the
# GNU C library's own shared objects and libgcc_s (glibc's unwinder);
# macOS: anything in the system's dyld shared cache (/usr/lib,
# /System/Library); Windows: the system's DLLs (never VCRUNTIME140, the
# MSVC runtime, which is redistributed, nor MinGW's runtime DLLs).
proc pm::target::platformLibrary {name identity} {
    set os [dict get [facts $name] os]
    switch -- $os {
        linux {
            return [expr {$identity in {libc.so.6 libm.so.6 libpthread.so.0 libdl.so.2 librt.so.1
                libresolv.so.2 libutil.so.1 libanl.so.1 libmvec.so.1 libgcc_s.so.1
                ld-linux-x86-64.so.2 ld-linux-aarch64.so.1}}]
        }
        macos {
            return [expr {[string match /usr/lib/* $identity] || [string match /System/Library/* $identity]}]
        }
        windows {
            set lower [string tolower $identity]
            if {[string match api-ms-win-* $lower] || [string match ext-ms-* $lower]} {
                return 1
            }
            return [expr {$lower in {kernel32.dll user32.dll gdi32.dll advapi32.dll shell32.dll
                ole32.dll oleaut32.dll imm32.dll version.dll winmm.dll setupapi.dll cfgmgr32.dll
                ntdll.dll ws2_32.dll shlwapi.dll comdlg32.dll comctl32.dll dwmapi.dll uxtheme.dll
                hid.dll dxgi.dll d3d11.dll d3d12.dll dinput8.dll xinput1_4.dll bcrypt.dll
                crypt32.dll secur32.dll rpcrt4.dll userenv.dll ucrtbase.dll msvcrt.dll
                dbghelp.dll psapi.dll iphlpapi.dll winhttp.dll}}]
        }
    }
    return 0
}

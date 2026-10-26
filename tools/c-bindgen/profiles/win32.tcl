# win32.tcl -- the raw Win32 binding profile, for Windows x86-64 with the
# GNU ABI of MinGW-w64 (C-BINDGEN-LAYOUTS.md, "Win32 GNU x86-64"): the
# MinGW-w64 headers of the cross toolchain's own include directory (Debian
# and Ubuntu's mingw-w64-x86-64-dev, MinGW-w64 13.0.0), preprocessed and
# probed by clang --target=x86_64-w64-mingw32, entirely on Linux. This is
# MinGW evidence: what this toolchain says the records, symbols and
# constants are. It is not MSVC's and claims nothing about it.
#
# The translation unit is <windows.h> under an explicit, complete
# configuration (nothing comes from the shell: configFor drops the
# BOTLISH_C_* extra-word knobs):
#
#   WIN32_LEAN_AND_MEAN   the core Win32 API -- kernel32's base services
#                         (files, directories, processes and threads,
#                         synchronization, memory, time, I/O completion),
#                         user32, gdi32, advapi32's registry and security,
#                         the console, NLS -- without the OLE/COM, RPC,
#                         Shell, Winsock, crypto and multimedia headers
#                         windows.h otherwise pulls in (bindings of their
#                         own, later)
#   UNICODE, _UNICODE     every generic name (CreateFile, FindFirstFile,
#                         STARTUPINFO) is the W API's: the binding binds
#                         both FooA and FooW as declared, and the generic
#                         macro Foo as an alias of FooW (its symbol)
#   _WIN32_WINNT, WINVER  0x0A00: the Windows 10 API surface
#   NTDDI_VERSION         0x0A000000 (NTDDI_WIN10), the same, as winnt.h
#                         gates newer declarations
#   STRICT                distinct handle types (DECLARE_HANDLE: HWND is
#                         struct HWND__ *), one pointee identity each
#   NOMINMAX              no min/max macros
#
# Public: every header of the source root but MinGW-w64's C runtime and
# the annotation-macro headers (private below); a header's module is its
# file stem (winbase.h is win32::winbase, fileapi.h win32::fileapi).
#
# Libraries: a Win32 header declares functions of several DLLs (winbase.h:
# kernel32's and advapi32's). Each bound function's import library is the
# first library of the list below whose MinGW-w64 import library (the
# toolchain's -print-file-name=libNAME.a) defines its link symbol -- the
# toolchain's answer, never a table of names; a symbol several of them
# define takes the first (the manifest lists every one), a symbol none of
# them define is unsupported (no-import-library). The list is the classic
# DLLs these headers declare functions of, the kernel's first, then the
# smaller ones the remaining declarations' symbols are found in
# (synchronization: WaitOnAddress; opengl32: wgl*; msimg32: TransparentBlt,
# GradientFill; winspool: DeviceCapabilities). No API-set umbrella library
# (api-ms-win-*, onecore, mincore, windowsapp) is searched: a function only
# those define (VirtualAllocFromApp, UnmapViewOfFile2) stays unsupported,
# and so does one MinGW-w64 13's import libraries do not define at all.
dict create \
    name win32 \
    description "the raw Win32 API of MinGW-w64 13.0.0's <windows.h> (WIN32_LEAN_AND_MEAN, UNICODE, Windows 10), for Windows x86-64 with the GNU ABI (MinGW-w64), not MSVC" \
    headers {
        library mingw-w64
        source {toolchain windows.h version {__MINGW64_VERSION_MAJOR 13 __MINGW64_VERSION_MINOR 0 __MINGW64_VERSION_BUGFIX 0}}
        defines {WIN32_LEAN_AND_MEAN UNICODE _UNICODE _WIN32_WINNT=0x0A00 WINVER=0x0A00 NTDDI_VERSION=0x0A000000 STRICT NOMINMAX}
        public {*.h}
        private {_mingw*.h corecrt*.h crtdefs.h ctype.h errno.h excpt.h limits.h malloc.h stdarg.h
            stddef.h stdint.h stdio.h stdlib.h string.h vadefs.h wchar.h sec_api/* psdk_inc/* sdks/*
            sal.h specstrings.h driverspecs.h concurrencysal.h}
        entry {windows.h}
    } \
    targets {windows-x86_64-gnu} \
    modules {stripPrefix ""} \
    libraries {
        {targets * symbols {kernel32 user32 gdi32 advapi32 version mpr imm32 virtdisk ntdll
            synchronization opengl32 msimg32 winspool}}
    } \
    evidence llvm

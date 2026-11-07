# support.tcl -- target support packages
# (EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md, "Target
# support packages").
#
#   native::support::select ROOT TARGET NAME
#       the target support package NAME of the application whose root is
#       ROOT (the directory of its entry file), for the compilation target
#       TARGET, checked: a dict {package NAME directory DIR descriptor PATH
#       target T triple TRIPLE archive PATH abi HEX libraries {-l...}}, or
#       a {NATIVE TARGET-SUPPORT KIND} error before anything is linked
#   native::support::identity PATH
#       the identity record of the runtime archive PATH: {triple T abi HEX},
#       or "" when it holds none
#
# A target support package is an ordinary package -- a pure data package as
# far as the compiler is concerned -- that supplies, for a target the
# compiler already generates code for, the runtime artifacts an executable
# of that target is linked with: today the native runtime archive the
# system linker links (libbotlish_runtime.a, native/runtime-archive). It
# says so in one file at its package root,
#
#   botlish-target-support.json
#     {"schema": 1, "kind": "botlish-target-support",
#      "target": "linux-x86_64", "triple": "x86_64-unknown-linux-gnu",
#      "linker": "system",
#      "runtime": {"archive": "runtime/libbotlish_runtime.a",
#                  "abi": "d554d5ff4c234348"},
#      "systemLibraries": ["-lgcc_s", "-lutil", ...]}
#
# which the compiler reads when -- and only when -- a compilation names the
# package (main.tcl's -target-support NAME, native::executable's
# -runtime-archive): installing a target support package selects nothing,
# changes no target and runs nothing, and a program that does not name one
# links exactly as before. Nothing in the package is executed when it is
# selected: its descriptor is data, and its archive is read as bytes.
#
# The package is found where the compiler finds the application's packages
# for TARGET (surface/modules.tcl's ApplicationTree): ROOT/.bot_modules/
# .targets/TARGET/NAME when the application has target package trees
# (.bot_modules/.targets), else ROOT/.bot_modules/NAME -- the compilation
# target's tree, never the host's. Its checks, each a refusal of its own:
#
#   MISSING         no package NAME is installed for TARGET
#   DESCRIPTOR      no descriptor, or one this compiler cannot read (another
#                   schema, an unknown or missing member)
#   UNKNOWN-TARGET  the descriptor's target is no compilation target this
#                   compiler knows (core/cabi.tcl's table): it cannot
#                   generate code for it
#   TARGET          the descriptor supports another target than the
#                   compilation's
#   TRIPLE          the descriptor's triple is not its target's
#   LINKER          a linker other than the system linker
#   RUNTIME         the archive is missing, a link, outside the package,
#                   holds no identity record, or its record names another
#                   triple (another operating system's or C library's
#                   build: an Android/Bionic archive is never a Linux/glibc
#                   one, whatever its architecture)
#   ABI             the descriptor's or the archive's runtime ABI
#                   fingerprint is not this driver's
#   LIBRARIES       the system libraries it states are not the ones the
#                   system linker links for the target
#
# The driver checks the archive's object format and architecture again when
# it links (codegen/aot.rs's runtime_archive), and the executable's startup
# the program record's fingerprint (runtime::program::read_linked). A
# missing host toolchain (no C compiler driver) is the driver's own error,
# {NATIVE LINK TOOLCHAIN}, never one of these: the package and the compiler
# have what they need.

namespace eval native::support {
    # The compiler's root (a checkout's, or the packaged compiler's archive):
    # lsp/json.tcl, the JSON reader, is there.
    variable home [file dirname [file dirname [file normalize [info script]]]]
    variable descriptorName botlish-target-support.json
    variable schema 1
    variable keys {schema kind target triple linker runtime systemLibraries}
    variable runtimeKeys {archive abi}
}

proc native::support::Fail {kind message} {
    return -code error -errorcode [list NATIVE TARGET-SUPPORT $kind] "target support: $message"
}

# The directory where the application of ROOT keeps its packages for TARGET.
proc native::support::PackagesDir {root target} {
    set modules [file join $root .bot_modules]
    if {[file isdirectory [file join $modules .targets]]} {
        return [file join $modules .targets $target]
    }
    return $modules
}

proc native::support::select {root target name} {
    variable descriptorName
    variable schema
    variable keys
    variable runtimeKeys
    if {![regexp {^[a-z][a-z0-9_]{0,63}$} $name]} {
        Fail MISSING "\"$name\" is not a package name"
    }
    set root [file normalize $root]
    set dir [file join [PackagesDir $root $target] $name]
    if {![file isdirectory $dir]} {
        Fail MISSING "no package $name is installed for $target ([file join [PackagesDir $root $target] $name] does not exist): install the target support package (add it to the application), or name another"
    }
    set path [file join $dir $descriptorName]
    if {![file isfile $path]} {
        Fail DESCRIPTOR "the package $name has no $descriptorName: it is no target support package"
    }
    if {[info commands ::lsp::json::parse] eq ""} {
        variable home
        uplevel #0 [list source [file join $home lsp json.tcl]]
    }
    set channel [open $path rb]
    set bytes [read $channel]
    close $channel
    if {[catch {lsp::json::parse [encoding convertfrom -profile strict utf-8 $bytes]} value]} {
        Fail DESCRIPTOR "$path is no JSON text: $value"
    }
    if {[lsp::json::type $value] ne "obj"} {
        Fail DESCRIPTOR "$path is not a JSON object"
    }
    foreach {key -} [lsp::json::members $value] {
        if {$key ni $keys} {
            Fail DESCRIPTOR "$path: unknown member \"$key\" (schema $schema has [join $keys {, }]): a member a later schema adds is never ignored"
        }
    }
    foreach key $keys {
        if {![lsp::json::has $value $key]} {
            Fail DESCRIPTOR "$path: no \"$key\""
        }
    }
    if {[lsp::json::type [lsp::json::get $value schema]] ne "num" || [lsp::json::get $value schema] ne {num 1}} {
        Fail DESCRIPTOR "$path: unsupported schema [lindex [lsp::json::get $value schema] 1] (this compiler reads schema $schema: a newer one needs a newer Botlish)"
    }
    set fields [dict create]
    foreach key {kind target triple linker} {
        set item [lsp::json::get $value $key]
        if {[lsp::json::type $item] ne "str"} {
            Fail DESCRIPTOR "$path: \"$key\" must be a string"
        }
        dict set fields $key [lsp::json::text $item]
    }
    if {[dict get $fields kind] ne "botlish-target-support"} {
        Fail DESCRIPTOR "$path: \"kind\" is \"[dict get $fields kind]\", not \"botlish-target-support\""
    }
    set runtime [lsp::json::get $value runtime]
    if {[lsp::json::type $runtime] ne "obj"} {
        Fail DESCRIPTOR "$path: \"runtime\" must be an object {\"archive\": PATH, \"abi\": FINGERPRINT}"
    }
    foreach {key item} [lsp::json::members $runtime] {
        if {$key ni $runtimeKeys} {
            Fail DESCRIPTOR "$path: runtime: unknown member \"$key\""
        }
        if {[lsp::json::type $item] ne "str"} {
            Fail DESCRIPTOR "$path: runtime: \"$key\" must be a string"
        }
        dict set fields $key [lsp::json::text $item]
    }
    foreach key $runtimeKeys {
        if {![dict exists $fields $key]} {
            Fail DESCRIPTOR "$path: runtime: no \"$key\""
        }
    }
    set libraries [lsp::json::get $value systemLibraries]
    if {[lsp::json::type $libraries] ne "arr"} {
        Fail DESCRIPTOR "$path: \"systemLibraries\" must be an array of linker library arguments"
    }
    set stated {}
    foreach item [lsp::json::elements $libraries] {
        if {[lsp::json::type $item] ne "str"} {
            Fail DESCRIPTOR "$path: \"systemLibraries\" holds a non-string"
        }
        lappend stated [lsp::json::text $item]
    }

    set declared [dict get $fields target]
    if {![dict exists $::core::cabi::targets $declared]} {
        Fail UNKNOWN-TARGET "the package $name supports $declared, which is no compilation target this compiler knows ([join [lsort [dict keys $::core::cabi::targets]] {, }]): it cannot generate code for $declared, and a target support package supplies runtime artifacts only, never code generation"
    }
    if {$declared ne $target} {
        Fail TARGET "the package $name supports $declared, and this compilation's target is $target: select a target support package of $target (or compile for $declared with -target $declared)"
    }
    set triple [dict get [core::cabi::target $target] triple]
    if {[dict get $fields triple] ne $triple} {
        Fail TRIPLE "the package $name states the triple [dict get $fields triple] for $target, whose triple is $triple"
    }
    if {[dict get $fields linker] ne "system"} {
        Fail LINKER "the package $name's runtime is for the [dict get $fields linker] linker: a target support package's runtime archive is linked by the system linker"
    }
    set abi [dict get $fields abi]
    if {![regexp {^[0-9a-f]{16}$} $abi]} {
        Fail DESCRIPTOR "$path: runtime: \"abi\" must be a runtime ABI fingerprint, 16 lowercase hexadecimal digits"
    }
    set relative [dict get $fields archive]
    if {$relative eq "" || [string match /* $relative] || [regexp {^[A-Za-z]:} $relative]
            || [string first \\ $relative] >= 0 || [lsearch -exact [split $relative /] ..] >= 0
            || [lsearch -exact [split $relative /] .] >= 0 || [lsearch -exact [split $relative /] ""] >= 0} {
        Fail RUNTIME "the package $name names its runtime archive \"$relative\": a path inside the package, relative, with \"/\" separators and no \".\", \"..\" or empty segment"
    }
    set archive [file join $dir {*}[split $relative /]]
    if {[catch {file lstat $archive stat}] || $stat(type) ne "file"} {
        Fail RUNTIME "the package $name's runtime archive $relative is missing (or not a regular file: a link is never followed)"
    }
    set mine [native::runtimeAbi]
    if {$abi ne $mine} {
        Fail ABI "the package $name's runtime ABI fingerprint is $abi, and this compiler's is $mine: its runtime was built by another compiler build, whose generated code addresses another runtime (use the target support package of this build)"
    }
    set record [identity $archive]
    if {$record eq ""} {
        Fail RUNTIME "the package $name's runtime archive $relative holds no runtime identity record: it is no Botlish runtime archive (native/runtime-archive), or one built before the record existed"
    }
    if {[dict get $record triple] ne $triple} {
        Fail RUNTIME "the package $name's runtime archive $relative was built for [dict get $record triple], not $target's $triple: [Mismatch [dict get $record triple] $triple]"
    }
    if {[dict get $record abi] ne $abi} {
        Fail ABI "the package $name's runtime archive $relative holds the runtime ABI [dict get $record abi], and its descriptor states $abi"
    }
    if {$target eq [core::cabi::hostTarget]} {
        set expected [SystemLibraries]
        if {$expected ne "" && $stated ne $expected} {
            Fail LIBRARIES "the package $name states the system libraries [join $stated { }], and the system linker links $target's runtime with [join $expected { }]: its runtime archive was built differently"
        }
    }
    return [dict create package $name directory $dir descriptor $path target $target triple $triple \
        archive $archive abi $abi libraries $stated]
}

# Why an archive built for FOUND is not one for WANTED, both triples.
proc native::support::Mismatch {found wanted} {
    lassign [split $found -] farch
    lassign [split $wanted -] warch
    if {$farch ne $warch} {
        return "another architecture"
    }
    return "the same architecture, another operating system or C library ABI, whose runtime is never interchangeable"
}

# The identity record of the runtime archive PATH (runtime::aotimage::
# identity_record: "BOTLISH-RUNTIME-IDENTITY v1 TRIPLE FINGERPRINT", NUL
# terminated), read from its bytes: {triple T abi HEX}; "" when it holds
# none. Two different records are no identity either.
proc native::support::identity {path} {
    set channel [open $path rb]
    set bytes [read $channel]
    close $channel
    set found {}
    set at 0
    set prefix "BOTLISH-RUNTIME-IDENTITY v1 "
    while {[set at [string first $prefix $bytes $at]] >= 0} {
        set end [string first \x00 $bytes $at]
        if {$end < 0} break
        set text [string range $bytes [expr {$at + [string length $prefix]}] [expr {$end - 1}]]
        if {[regexp {^([a-z0-9_.]+(?:-[a-z0-9_.]+)+) ([0-9a-f]{16})$} $text -> triple abi]} {
            lappend found [list triple $triple abi $abi]
        }
        set at $end
    }
    set found [lsort -unique $found]
    if {[llength $found] != 1} {
        return ""
    }
    return [lindex $found 0]
}

# The system libraries the system linker links this host's runtime with
# (botlish-native system-linker's `libraries`), or "" if it does not say.
proc native::support::SystemLibraries {} {
    variable systemLibrariesCache
    if {[info exists systemLibrariesCache]} {
        return $systemLibrariesCache
    }
    set pipe [open |[list [native::binary] system-linker 2>@1] r]
    fconfigure $pipe -encoding utf-8 -translation lf
    set output [read $pipe]
    catch {close $pipe}
    set systemLibrariesCache ""
    foreach line [split $output \n] {
        if {[lindex $line 0] eq "libraries"} {
            set systemLibrariesCache [lrange $line 1 end]
        }
    }
    return $systemLibrariesCache
}

# support.tcl -- target support packages
# (EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md, "Target
# support packages").
#
#   native::support::select ROOT TARGET NAME ?ARTIFACT?
#       the target support package NAME of the application whose root is
#       ROOT (the directory of its entry file), for the compilation target
#       TARGET and the artifact kind ARTIFACT (native-executable, the
#       default, or native-library), checked: a dict {package NAME directory
#       DIR descriptor PATH target T triple TRIPLE archive PATH abi HEX
#       libraries {-l...} schema 1|2 artifact KIND} (schema 2 adds platform
#       {MEMBER VERSION}, toolchain DECLARATION and relocation), or a
#       {NATIVE TARGET-SUPPORT KIND} error before anything is linked
#   native::support::toolchain SUPPORT
#       the schema 2 package SUPPORT's declared toolchain found on this host
#       (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md): {name root revision
#       cc ld objcopy ar platformLibraries api}, or {NATIVE LIBRARY
#       TOOLCHAIN} (the host's toolchain is missing or too old) or {NATIVE
#       TARGET-SUPPORT API} (it has no libraries of the package's API level)
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
#                  "abi": "FINGERPRINT"},
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
#                   system linker links for the target (for another target
#                   than the host's, `targetLibraries`)
#   ARTIFACT        it does not supply the artifact kind being built
#   PIC             (schema 2) its runtime archive is not stated
#                   position-independent ("relocation": "pic")
#   API             (schema 2) the platform version it states is below
#                   this compiler's runtime's floor for the target
#
# Schema 2 (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md; BOTLISH-TOOLS.md,
# section 9) is how a native library of another target than the host's is
# linked -- android-aarch64's from Linux x86-64:
#
#   {"schema": 2, "kind": "botlish-target-support",
#    "target": "android-aarch64", "triple": "aarch64-linux-android",
#    "artifacts": ["native-library"],
#    "platform": {"minimumApi": 21},
#    "runtime": {"archive": "runtime/libbotlish_runtime.a",
#                "abi": "FINGERPRINT", "relocation": "pic"},
#    "systemLibraries": ["-ldl", "-llog", "-lunwind", "-ldl", "-lm", "-lc"],
#    "toolchain": {"name": "Android NDK", "root": "ANDROID_NDK_ROOT",
#                  "revision": {"file": "source.properties",
#                               "key": "Pkg.Revision", "minimum": "28.0"},
#                  "hosts": {"linux-x86_64": "toolchains/llvm/prebuilt/linux-x86_64"},
#                  "tools": {"cc": "bin/clang", "ld": "bin/ld.lld",
#                            "objcopy": "bin/llvm-objcopy", "ar": "bin/llvm-ar"},
#                  "platformLibraries": "sysroot/usr/lib/aarch64-linux-android/{api}"}}
#
# The toolchain is data: where it is (an environment variable: nothing is
# searched), its minimum revision and its tools' relative paths. The
# compiler composes every argument itself (native::library's
# LinkWithToolchain): a descriptor adds no flag, and its system libraries
# are compared with the target's, never added.
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
    # Schema 2 (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md): the artifact
    # kinds a package supports, a platform's minimum version, and the C
    # toolchain that links them, declared as data. A member a schema lists is
    # required; `platform` only where the target's operating system has a
    # platform version (`platformVersions`).
    variable keys2 {schema kind target triple artifacts runtime systemLibraries toolchain}
    variable optional2 {platform}
    variable runtimeKeys2 {archive abi relocation}
    variable toolchainKeys {name root revision hosts tools platformLibraries}
    variable revisionKeys {file key minimum}
    variable toolKeys {cc ld objcopy ar}
    # The artifact kinds a schema-2 package's toolchain links (only native
    # libraries so far: an executable of another target is no artifact this
    # compiler makes). Schema 1's one artifact is the system linker's
    # executable.
    variable artifactKinds {native-library}
    # The operating systems whose targets name a minimum platform version,
    # its member in `platform`, and the lowest this compiler's runtime
    # supports: android, the Android API level of the NDK's
    # aarch64-linux-androidN (the runtime calls nothing of Bionic newer than
    # it: the report's section 7).
    variable platformVersions [dict create android {member minimumApi floor 21}]
    # The system libraries a target's runtime archive is linked with, for a
    # target this host does not run (rustc's native-static-libs of the
    # runtime archive built for the target): what a descriptor must state,
    # never what it may add.
    variable targetLibraries [dict create android-aarch64 {-ldl -llog -lunwind -ldl -lm -lc}]
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

proc native::support::select {root target name {artifact native-executable}} {
    variable descriptorName
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
    if {![lsp::json::has $value schema]} {
        Fail DESCRIPTOR "$path: no \"schema\""
    }
    set version [lsp::json::get $value schema]
    if {$version eq {num 1}} {
        set fields [Schema1 $path $value]
    } elseif {$version eq {num 2}} {
        set fields [Schema2 $path $value $target]
    } else {
        Fail DESCRIPTOR "$path: unsupported schema [lindex $version 1] (this compiler reads schemas 1 and 2: a newer one needs a newer Botlish)"
    }
    set stated [dict get $fields libraries]

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
    if {[dict exists $fields platformItem]} {
        dict set fields platform [Platform $path $target [dict get $fields platformItem]]
    }
    if {$artifact ni [dict get $fields artifacts]} {
        set how [dict get {
            native-library "a native library is linked by a package's declared toolchain (schema 2, artifacts native-library)"
            native-executable "an executable is linked by the system linker with a schema 1 package's runtime"
        } $artifact]
        Fail ARTIFACT "the package $name supplies [join [dict get $fields artifacts] {, }] for $target, not a $artifact: $how"
    }
    if {$version eq {num 1} && [dict get $fields linker] ne "system"} {
        Fail LINKER "the package $name's runtime is for the [dict get $fields linker] linker: a target support package's runtime archive is linked by the system linker"
    }
    set abi [dict get $fields abi]
    if {![regexp {^[0-9a-f]{16}$} $abi]} {
        Fail DESCRIPTOR "$path: runtime: \"abi\" must be a runtime ABI fingerprint, 16 lowercase hexadecimal digits"
    }
    set relative [dict get $fields archive]
    if {![RelativePath $relative]} {
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
    variable targetLibraries
    if {$target eq [core::cabi::hostTarget]} {
        set expected [SystemLibraries]
    } else {
        set expected [dict getdef $targetLibraries $target ""]
    }
    if {$expected ne "" && $stated ne $expected} {
        Fail LIBRARIES "the package $name states the system libraries [join $stated { }], and $target's runtime is linked with [join $expected { }]: its runtime archive was built differently"
    }
    return [dict merge [dict create package $name directory $dir descriptor $path target $target triple $triple \
        archive $archive abi $abi libraries $stated schema [lindex $version 1] artifact $artifact] \
        [dict filter $fields key platform toolchain relocation]]
}

# 1 if RELATIVE is a path inside a package: relative, "/"-separated, with no
# ".", ".." or empty segment, no drive and no backslash.
proc native::support::RelativePath {relative} {
    return [expr {!($relative eq "" || [string match /* $relative] || [regexp {^[A-Za-z]:} $relative]
        || [string first \\ $relative] >= 0 || [lsearch -exact [split $relative /] ..] >= 0
        || [lsearch -exact [split $relative /] .] >= 0 || [lsearch -exact [split $relative /] ""] >= 0)}]
}

# The strings of the JSON object VALUE's members KEYS, into a dict; WHERE
# names the object in a refusal.
proc native::support::Strings {path where value keys} {
    set fields [dict create]
    foreach key $keys {
        if {![lsp::json::has $value $key]} {
            Fail DESCRIPTOR "$path: ${where}no \"$key\""
        }
        set item [lsp::json::get $value $key]
        if {[lsp::json::type $item] ne "str"} {
            Fail DESCRIPTOR "$path: ${where}\"$key\" must be a string"
        }
        dict set fields $key [lsp::json::text $item]
    }
    return $fields
}

# Refuses a member of the JSON object VALUE not in KEYS.
proc native::support::OnlyMembers {path where value keys} {
    foreach {key -} [lsp::json::members $value] {
        if {$key ni $keys} {
            Fail DESCRIPTOR "$path: ${where}unknown member \"$key\" (the schema has [join $keys {, }]): a member a later schema adds is never ignored"
        }
    }
}

# The strings of the JSON array ITEM.
proc native::support::StringArray {path what item} {
    if {[lsp::json::type $item] ne "arr"} {
        Fail DESCRIPTOR "$path: \"$what\" must be an array of strings"
    }
    set out {}
    foreach element [lsp::json::elements $item] {
        if {[lsp::json::type $element] ne "str"} {
            Fail DESCRIPTOR "$path: \"$what\" holds a non-string"
        }
        lappend out [lsp::json::text $element]
    }
    return $out
}

# A schema 1 descriptor VALUE (the system linker's executables): its fields.
proc native::support::Schema1 {path value} {
    variable keys
    variable runtimeKeys
    OnlyMembers $path "" $value $keys
    foreach key $keys {
        if {![lsp::json::has $value $key]} {
            Fail DESCRIPTOR "$path: no \"$key\""
        }
    }
    set fields [Strings $path "" $value {kind target triple linker}]
    if {[dict get $fields kind] ne "botlish-target-support"} {
        Fail DESCRIPTOR "$path: \"kind\" is \"[dict get $fields kind]\", not \"botlish-target-support\""
    }
    set runtime [lsp::json::get $value runtime]
    if {[lsp::json::type $runtime] ne "obj"} {
        Fail DESCRIPTOR "$path: \"runtime\" must be an object {\"archive\": PATH, \"abi\": FINGERPRINT}"
    }
    OnlyMembers $path "runtime: " $runtime $runtimeKeys
    set fields [dict merge $fields [Strings $path "runtime: " $runtime $runtimeKeys]]
    dict set fields libraries [StringArray $path systemLibraries [lsp::json::get $value systemLibraries]]
    dict set fields artifacts {native-executable}
    return $fields
}

# A schema 2 descriptor VALUE for TARGET (artifacts linked by a declared
# toolchain): its fields, with `platform` (a dict MEMBER VERSION),
# `toolchain` (the declared toolchain, a dict) and `relocation`.
proc native::support::Schema2 {path value target} {
    variable keys2
    variable optional2
    variable runtimeKeys2
    variable toolchainKeys
    variable revisionKeys
    variable toolKeys
    variable artifactKinds
    OnlyMembers $path "" $value [concat $keys2 $optional2]
    foreach key $keys2 {
        if {![lsp::json::has $value $key]} {
            Fail DESCRIPTOR "$path: no \"$key\""
        }
    }
    set fields [Strings $path "" $value {kind target triple}]
    if {[dict get $fields kind] ne "botlish-target-support"} {
        Fail DESCRIPTOR "$path: \"kind\" is \"[dict get $fields kind]\", not \"botlish-target-support\""
    }
    dict set fields linker toolchain
    set artifacts [StringArray $path artifacts [lsp::json::get $value artifacts]]
    if {![llength $artifacts]} {
        Fail DESCRIPTOR "$path: \"artifacts\" names no artifact kind"
    }
    foreach kind $artifacts {
        if {$kind ni $artifactKinds} {
            Fail DESCRIPTOR "$path: \"artifacts\" names \"$kind\", which no declared toolchain links (this compiler's: [join $artifactKinds {, }])"
        }
    }
    dict set fields artifacts $artifacts
    set runtime [lsp::json::get $value runtime]
    if {[lsp::json::type $runtime] ne "obj"} {
        Fail DESCRIPTOR "$path: \"runtime\" must be an object {\"archive\": PATH, \"abi\": FINGERPRINT, \"relocation\": \"pic\"}"
    }
    OnlyMembers $path "runtime: " $runtime $runtimeKeys2
    set fields [dict merge $fields [Strings $path "runtime: " $runtime $runtimeKeys2]]
    if {[dict get $fields relocation] ne "pic"} {
        Fail PIC "the package's runtime archive is built for the \"[dict get $fields relocation]\" relocation model: a shared library's code is position-independent, and so is every archive linked into one (\"relocation\": \"pic\")"
    }
    dict set fields libraries [StringArray $path systemLibraries [lsp::json::get $value systemLibraries]]

    # The platform's minimum version, judged once the target is known to be
    # the compilation's (`Platform`).
    dict set fields platformItem {}
    if {[lsp::json::has $value platform]} {
        dict set fields platformItem [list [lsp::json::get $value platform]]
    }

    # The toolchain: where it is (an environment variable naming its root:
    # nothing is searched), which revision it must be at least, its
    # directory for each host, and its tools, relative paths each.
    set item [lsp::json::get $value toolchain]
    if {[lsp::json::type $item] ne "obj"} {
        Fail DESCRIPTOR "$path: \"toolchain\" must be an object"
    }
    OnlyMembers $path "toolchain: " $item $toolchainKeys
    set toolchain [Strings $path "toolchain: " $item {name root platformLibraries}]
    if {![regexp {^[A-Z][A-Z0-9_]{0,63}$} [dict get $toolchain root]]} {
        Fail DESCRIPTOR "$path: toolchain: \"root\" must name an environment variable (uppercase letters, digits and \"_\")"
    }
    foreach sub {revision hosts tools} {
        if {![lsp::json::has $item $sub] || [lsp::json::type [lsp::json::get $item $sub]] ne "obj"} {
            Fail DESCRIPTOR "$path: toolchain: \"$sub\" must be an object"
        }
    }
    set revision [lsp::json::get $item revision]
    OnlyMembers $path "toolchain: revision: " $revision $revisionKeys
    dict set toolchain revision [Strings $path "toolchain: revision: " $revision $revisionKeys]
    if {![regexp {^[0-9]+(\.[0-9]+)*$} [dict get $toolchain revision minimum]]} {
        Fail DESCRIPTOR "$path: toolchain: revision: \"minimum\" must be a dotted version (28.0)"
    }
    set hosts [dict create]
    foreach {host dirItem} [lsp::json::members [lsp::json::get $item hosts]] {
        if {![dict exists $::core::cabi::targets $host] || [lsp::json::type $dirItem] ne "str" || ![RelativePath [lsp::json::text $dirItem]]} {
            Fail DESCRIPTOR "$path: toolchain: hosts: \"$host\" must be a compilation target naming a relative directory"
        }
        dict set hosts $host [lsp::json::text $dirItem]
    }
    dict set toolchain hosts $hosts
    set tools [lsp::json::get $item tools]
    OnlyMembers $path "toolchain: tools: " $tools $toolKeys
    dict set toolchain tools [Strings $path "toolchain: tools: " $tools $toolKeys]
    foreach paths [list [dict values [dict get $toolchain tools]] [list [string map {{{api}} 1} [dict get $toolchain platformLibraries]]]] {
        foreach relative $paths {
            if {![RelativePath $relative]} {
                Fail DESCRIPTOR "$path: toolchain: \"$relative\" is no relative path inside the toolchain"
            }
        }
    }
    dict set fields toolchain $toolchain
    return $fields
}

# The platform version a schema 2 descriptor at PATH states for TARGET in
# ITEM (a one-element list holding the JSON value of its `platform`, or an
# empty list): required exactly where TARGET's operating system has one,
# never below the runtime's floor. A dict MEMBER VERSION (empty for a target
# with none).
proc native::support::Platform {path target item} {
    variable platformVersions
    set os [dict get [core::cabi::target $target] os]
    if {![dict exists $platformVersions $os]} {
        if {[llength $item]} {
            Fail DESCRIPTOR "$path: \"platform\" is a member of a target with a platform version, and $target has none"
        }
        return {}
    }
    set member [dict get $platformVersions $os member]
    if {![llength $item]} {
        Fail DESCRIPTOR "$path: no \"platform\" (a [core::cabi::systemName $os] target states its \"$member\")"
    }
    set item [lindex $item 0]
    if {[lsp::json::type $item] ne "obj"} {
        Fail DESCRIPTOR "$path: \"platform\" must be an object {\"$member\": N}"
    }
    OnlyMembers $path "platform: " $item [list $member]
    if {![lsp::json::has $item $member] || [lsp::json::type [lsp::json::get $item $member]] ne "num"
            || ![regexp {^[1-9][0-9]{0,3}$} [lindex [lsp::json::get $item $member] 1]]} {
        Fail DESCRIPTOR "$path: platform: \"$member\" must be a positive integer"
    }
    set version [lindex [lsp::json::get $item $member] 1]
    set floor [dict get $platformVersions $os floor]
    if {$version < $floor} {
        Fail API "the package's runtime states $member $version, and this compiler's [core::cabi::systemName $os] runtime needs at least $floor: it calls Bionic functions an older platform lacks"
    }
    return [dict create $member $version]
}

# The declared toolchain of target support SUPPORT (select's result, schema
# 2) on this host: {name N root DIR revision R cc PATH ld PATH objcopy PATH
# ar PATH platformLibraries DIR}, or a {NATIVE LIBRARY TOOLCHAIN} error --
# the host's toolchain, never the package's fault: the root's variable unset
# or not a directory, a revision older than the minimum, no directory for
# this host, a missing tool -- or {NATIVE TARGET-SUPPORT API} when the
# toolchain has no libraries of the package's platform version. Nothing is
# run: the revision is read from the file the declaration names.
proc native::support::toolchain {support} {
    set declared [dict get $support toolchain]
    set name [dict get $declared name]
    set variable [dict get $declared root]
    set package [dict get $support package]
    if {![info exists ::env($variable)] || $::env($variable) eq ""} {
        ToolchainFail "the target support package $package links with the $name, found through the environment variable $variable, which is not set: install the $name and set $variable to its directory"
    }
    set root [file normalize $::env($variable)]
    if {![file isdirectory $root]} {
        ToolchainFail "$variable names $root, which is no directory (the $name)"
    }
    set revisionFile [file join $root {*}[split [dict get $declared revision file] /]]
    set revision ""
    if {[file isfile $revisionFile]} {
        set channel [open $revisionFile r]
        set text [read $channel]
        close $channel
        set key [dict get $declared revision key]
        foreach line [split $text \n] {
            if {[regexp {^\s*([^=]+?)\s*=\s*(\S+)\s*$} $line -> k v] && $k eq $key} {
                set revision $v
            }
        }
    }
    if {![regexp {^[0-9]+(\.[0-9]+)*$} $revision]} {
        ToolchainFail "the $name at $root states no revision ([dict get $declared revision key] in [dict get $declared revision file]): it is no $name, or an incomplete one"
    }
    set minimum [dict get $declared revision minimum]
    if {[CompareVersions $revision $minimum] < 0} {
        ToolchainFail "the $name at $root is revision $revision, and the target support package $package needs at least $minimum"
    }
    set host [core::cabi::hostTarget]
    if {![dict exists $declared hosts $host]} {
        ToolchainFail "the $name has no toolchain for this host ($host) that the target support package $package knows (its hosts: [join [dict keys [dict get $declared hosts]] {, }])"
    }
    set base [file join $root {*}[split [dict get $declared hosts $host] /]]
    set result [dict create name $name root $root revision $revision]
    dict for {tool relative} [dict get $declared tools] {
        set file [file join $base {*}[split $relative /]]
        if {![file isfile $file]} {
            ToolchainFail "the $name at $root has no $tool ($file is missing)"
        }
        dict set result $tool $file
    }
    set api [lindex [dict values [dict get $support platform]] 0]
    set libraries [file join $base {*}[split [string map [list "{api}" $api] [dict get $declared platformLibraries]] /]]
    if {$api ne "" && ![file isdirectory $libraries]} {
        Fail API "the $name at $root (revision $revision) has no platform libraries of API level $api ($libraries is missing): the package's runtime needs that level, and this toolchain does not support it"
    }
    dict set result platformLibraries $libraries
    dict set result api $api
    return $result
}

proc native::support::ToolchainFail {message} {
    return -code error -errorcode {NATIVE LIBRARY TOOLCHAIN} "native::library: $message"
}

# -1, 0 or 1 as the dotted version A is older than, the same as or newer
# than B (missing components are 0).
proc native::support::CompareVersions {a b} {
    set as [split $a .]
    set bs [split $b .]
    set n [expr {max([llength $as], [llength $bs])}]
    for {set i 0} {$i < $n} {incr i} {
        set x 0
        set y 0
        scan [lindex $as $i] %d x
        scan [lindex $bs $i] %d y
        if {$x != $y} {
            return [expr {$x < $y ? -1 : 1}]
        }
    }
    return 0
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

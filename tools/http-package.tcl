# http-package.tcl -- the author's side of the `boringssl` and `http`
# packages' native files (HTTP-CLIENT-PACKAGE-MILESTONE-1.md, "Building
# the packages"). Nothing here reaches a consumer: a consumer installs the
# released .botpkg artifacts and compiles nothing of them.
#
#   tclsh9.0 tools/http-package.tcl provider       build the pinned BoringSSL
#                                                   (once); print its directory
#   tclsh9.0 tools/http-package.tcl unit ?-testing 1?
#                                                   build the localized
#                                                   libbotlish_http.a; print it
#   tclsh9.0 tools/http-package.tcl app DIR ?-testing 1?
#                                                   install the three packages
#                                                   (event_loop_linux,
#                                                   boringssl, http) into
#                                                   DIR/.bot_modules as one
#                                                   package graph (a test's or
#                                                   an example's application)
#   tclsh9.0 tools/http-package.tcl check           the unit's symbols, the
#                                                   provider's identity
#
# Sourced: httppkg::Provider, ProviderArchives, Unit, App (tests/cffi/http.tcl,
# tools/package-repository.tcl's author::boringssl and author::http).
#
# The provider (packages/boringssl/PIN): BoringSSL fetched by its pinned tag
# and checked by tag object and commit, built with upstream's CMake (Ninja,
# Release, position-independent, unpatched, unprefixed). Its archives are
# put in one archive of its own name, libbotlish_boringssl.a, with one more
# member, the provider's identity symbol (packages/boringssl/native/identity.c).
#
# The unit (packages/http/native, crate botlish_http): built by cargo
# --locked against the provider's headers in link-only mode -- boring-sys is
# given empty archives, so nothing of BoringSSL is bundled (the census's
# B1) and every reference stays undefined for the final link, which takes
# the provider's archives -- then localized: one relocatable object (ld -r)
# whose only global definitions are the bh_* functions (objcopy
# --keep-global-symbols), its debug sections stripped, its Rust COMDAT
# group renamed (the census's B3), in a deterministic archive. The unit
# references the provider's identity symbol: with another provider the link
# fails (the census's B2). -testing 1 builds the test unit (feature
# `testing`: fault injection, counters, a counting allocator), never
# released.
#
# Reproducibility: the cargo build runs with --locked and one codegen unit,
# its paths remapped (--remap-path-prefix for the crate, the registry and
# the cache; -ffile-prefix-map for its C file), and every archive is made
# with ar's deterministic mode. Everything is built under Botlish's cache
# ($BOTLISH_CACHE_DIR, $XDG_CACHE_HOME/botlish or ~/.cache/botlish), in
# http-package/, never in the repository.
namespace eval httppkg {
    variable here [file dirname [file normalize [info script]]]
    variable root [file dirname $here]
}

proc httppkg::Log {text} {
    puts stderr "http-package: $text"
}

proc httppkg::CacheDir {} {
    foreach {var sub} {BOTLISH_CACHE_DIR {} XDG_CACHE_HOME botlish} {
        if {[info exists ::env($var)] && $::env($var) ne ""} {
            return [file normalize [file join $::env($var) {*}$sub http-package]]
        }
    }
    return [file normalize [file join [file home] .cache botlish http-package]]
}

# Run SCRIPT in the caller's frame with the environment variables of VARS
# set, then put back exactly those variables (never `array unset env`: it
# unlinks Tcl's env array from the process environment).
proc httppkg::WithEnv {vars script} {
    set saved {}
    dict for {k v} $vars {
        dict set saved $k [expr {[info exists ::env($k)] ? [list 1 $::env($k)] : [list 0 {}]}]
        set ::env($k) $v
    }
    try {
        uplevel 1 $script
    } finally {
        dict for {k state} $saved {
            lassign $state had value
            if {$had} {
                set ::env($k) $value
            } else {
                unset -nocomplain ::env($k)
            }
        }
    }
}

proc httppkg::Read {path} {
    set f [open $path rb]
    set data [read $f]
    close $f
    return $data
}

proc httppkg::Sha256 {path} {
    lindex [exec sha256sum $path] 0
}

# The provider's pin (packages/boringssl/PIN), a dict.
proc httppkg::Pin {} {
    variable root
    set lines {}
    foreach line [split [Read [file join $root packages boringssl PIN]] \n] {
        if {![string match "#*" [string trim $line]]} {
            lappend lines $line
        }
    }
    return [join $lines \n]
}

# The identity of the provider: its tag and commit as one C identifier
# (0_20261020_0_d3bf...).
proc httppkg::ProviderId {} {
    set pin [Pin]
    return "[string map {. _} [dict get $pin tag]]_[dict get $pin commit]"
}

proc httppkg::Host {} {
    switch -- $::tcl_platform(machine) {
        x86_64 - amd64 { return linux-x86_64 }
        aarch64 - arm64 { return linux-aarch64 }
    }
    error "http-package: no Linux target for machine $::tcl_platform(machine)"
}

proc httppkg::CheckTarget {target} {
    if {$target ne [Host]} {
        error "http-package: the packages' native files are built for $target on $target only (this host is [Host]): no cross build of the provider or the unit is set up"
    }
}

# Fetch the pinned tag into SRC and check its tag object and commit.
proc httppkg::Fetch {pin src} {
    set tag [dict get $pin tag]
    if {![file isdirectory [file join $src .git]]} {
        file mkdir $src
        exec git -C $src init -q
        exec git -C $src remote add origin [dict get $pin url]
    }
    exec git -C $src fetch -q --depth 1 origin refs/tags/$tag:refs/tags/$tag 2>@stderr
    set object [exec git -C $src rev-parse refs/tags/$tag]
    set commit [exec git -C $src rev-parse "refs/tags/$tag^{commit}"]
    if {$object ne [dict get $pin tagObject]} {
        error "http-package: tag $tag is object $object, the pin says [dict get $pin tagObject]"
    }
    if {$commit ne [dict get $pin commit]} {
        error "http-package: tag $tag is commit $commit, the pin says [dict get $pin commit]"
    }
    exec git -C $src -c advice.detachedHead=false checkout -q --force $commit
    exec git -C $src clean -qfdx
    return $src
}

# The provider built for TARGET (upstream's archive names): its directory
# (lib/libcrypto.a, lib/libssl.a, include/, PROVENANCE).
proc httppkg::Provider {{target ""}} {
    if {$target eq ""} { set target [Host] }
    CheckTarget $target
    set pin [Pin]
    set commit [dict get $pin commit]
    set dir [file join [CacheDir] provider $commit-$target]
    if {[file exists [file join $dir PROVENANCE]]} {
        return $dir
    }
    set src [Fetch $pin [file join [CacheDir] src boringssl-$commit]]
    set build [file join [CacheDir] build boringssl-$commit-$target]
    file delete -force $build $dir
    Log "building BoringSSL [dict get $pin tag] ($commit) for $target"
    # The source and build directories are mapped out of the objects' paths
    # (__FILE__, debug information).
    set flags "-ffile-prefix-map=$src=/boringssl -ffile-prefix-map=$build=/boringssl-build"
    exec cmake -S $src -B $build -GNinja {*}[dict get $pin cmake] \
        "-DCMAKE_C_FLAGS=$flags" "-DCMAKE_CXX_FLAGS=$flags" -DCMAKE_AR=[auto_execok ar] >@stderr 2>@stderr
    exec ninja -C $build {*}[dict get $pin targets] >@stderr 2>@stderr
    file mkdir [file join $dir lib]
    foreach lib {crypto ssl} {
        file copy [file join $build lib$lib.a] [file join $dir lib lib$lib.a]
    }
    file copy [file join $src include] [file join $dir include]
    set record [dict create pin $pin target $target compiler [lindex [split [exec cc --version] \n] 0] \
        cxx [lindex [split [exec c++ --version] \n] 0] cmake [lindex [split [exec cmake --version] \n] 0]]
    foreach lib {crypto ssl} {
        dict set record sha256 $lib [Sha256 [file join $dir lib lib$lib.a]]
    }
    set f [open [file join $dir PROVENANCE] w]
    puts $f $record
    close $f
    return $dir
}

# The provider package's archive for TARGET, libbotlish_boringssl.a: the
# members of libcrypto.a and of libssl.a, in their order, and the identity
# member. One archive, not two: BoringSSL's C++ objects define their inline
# functions and its stack helpers weakly in both libraries, which a link
# merges but an audit of two static libraries reads as one symbol defined
# twice (HTTP-CLIENT-PACKAGE-MILESTONE-1.md, "The provider"). No member name
# occurs in both libraries (checked here).
proc httppkg::ProviderArchives {{target ""}} {
    variable root
    if {$target eq ""} { set target [Host] }
    set provider [Provider $target]
    set id [ProviderId]
    set dir [file join [CacheDir] provider-archives $id-$target]
    set archive [file join $dir libbotlish_boringssl.a]
    if {[file exists $archive] && [file exists [file join $dir STAMP]]} {
        return $dir
    }
    file delete -force $dir
    file mkdir $dir
    set identity [file join $dir botlish_boringssl_identity.o]
    exec cc -O2 -Wall -Wextra -Werror -fPIC -DBOTLISH_BORINGSSL_ID=$id \
        -ffile-prefix-map=$root=/botlish -c [file join $root packages boringssl native identity.c] -o $identity
    # Upstream's members, in their order, then the identity member: ar's
    # deterministic mode (no times, owners or modes).
    set paths {}
    set seen [dict create]
    foreach lib {crypto ssl} {
        set work [file join $dir members-$lib]
        file mkdir $work
        set members [split [exec ar t [file join $provider lib lib$lib.a]] \n]
        exec ar x --output $work [file join $provider lib lib$lib.a]
        foreach m $members {
            if {[dict exists $seen $m]} {
                error "http-package: libcrypto.a and libssl.a both hold a member $m"
            }
            dict set seen $m 1
            lappend paths [file join $work $m]
        }
    }
    lappend paths $identity
    # Upstream's build carries full debug information (93% of the archive's
    # bytes, over a package entry's limit): stripped, members unchanged
    # otherwise.
    foreach path $paths {
        exec objcopy --strip-debug $path
    }
    exec ar qcsD $archive {*}$paths
    foreach lib {crypto ssl} {
        file delete -force [file join $dir members-$lib]
    }
    file delete $identity
    set f [open [file join $dir STAMP] w]
    puts $f [list id $id archive [Sha256 $archive]]
    close $f
    return $dir
}

# Defined global symbols of FILE (nm).
proc httppkg::Defined {file} {
    set out {}
    foreach line [split [exec nm -A --defined-only $file 2>/dev/null] \n] {
        if {[regexp {^(.*):([0-9a-f]+)? +([A-Za-z]) +(\S+)$} $line -> where addr type sym]} {
            if {![string is lower $type] && $type ni {U w v}} {
                lappend out $sym
            }
        }
    }
    return [lsort -unique $out]
}

# The localized unit for TARGET (TESTING 1: the test unit): its archive.
proc httppkg::Unit {{target ""} {testing 0}} {
    variable root
    if {$target eq ""} { set target [Host] }
    CheckTarget $target
    set provider [Provider $target]
    set kind [expr {$testing ? "testing" : "release"}]
    set crate [file join $root packages http native]
    set dir [file join [CacheDir] units $kind-$target]
    file mkdir $dir
    # Link-only BoringSSL: the provider's headers, empty archives.
    set stub [file join [CacheDir] stub-bssl]
    file mkdir [file join $stub lib]
    foreach lib {crypto ssl} {
        if {![file exists [file join $stub lib lib$lib.a]]} {
            exec ar rcsD [file join $stub lib lib$lib.a]
        }
    }
    set targetDir [file join [CacheDir] cargo $kind-$target]
    set home [expr {[info exists ::env(CARGO_HOME)] && $::env(CARGO_HOME) ne "" ? $::env(CARGO_HOME) : [file join [file home] .cargo]}]
    set remap [list --remap-path-prefix=$crate=/botlish_http --remap-path-prefix=$home=/cargo \
        --remap-path-prefix=$targetDir=/target --remap-path-prefix=[file normalize $root]=/botlish]
    set env [dict create BORING_BSSL_PATH $stub BORING_BSSL_INCLUDE_PATH [file join $provider include] \
        BOTLISH_BORINGSSL_PROVIDER [ProviderId] CARGO_TARGET_DIR $targetDir RUSTFLAGS [join $remap " "] \
        CFLAGS "-ffile-prefix-map=$crate=/botlish_http -ffile-prefix-map=$targetDir=/target" \
        SOURCE_DATE_EPOCH 0 CARGO_INCREMENTAL 0]
    set cmd [list cargo build --release --locked --manifest-path [file join $crate Cargo.toml]]
    if {$testing} {
        lappend cmd --features testing
    }
    Log "unit $kind $target: [join $cmd]"
    WithEnv $env {
        exec {*}$cmd >@stderr 2>@stderr
    }
    set raw [file join $targetDir release libbotlish_http.a]
    set object [file join $dir botlish_http.o]
    file delete -force $object
    # One relocatable object of the whole unit, whose only global
    # definitions are the bh_* functions: its private Rust standard library
    # never meets the Botlish runtime's. BoringSSL's and libc's references
    # stay undefined (global) for the final link.
    exec ld -r --whole-archive $raw -o $object
    set exports [lmap s [Defined $object] {expr {[string match bh_* $s] ? $s : [continue]}}]
    set keep [file join $dir keep.txt]
    set f [open $keep w]
    puts $f [join $exports \n]
    close $f
    # Rust's one COMDAT group (DW.ref.rust_eh_personality) is deduplicated
    # by its signature's name across the whole link: beside the Botlish
    # runtime's own Rust code the unit's must be its own (B3).
    set groups [regexp -all -inline {COMDAT group section \[[^\]]*\] `[^']*' \[([^\]]+)\]} [exec readelf -g $object]]
    set rename {}
    foreach {- sig} $groups {
        lappend rename --redefine-sym $sig=botlish_http.$sig
    }
    exec objcopy --strip-debug {*}$rename --keep-global-symbols=$keep $object
    set unit [file join $dir libbotlish_http.a]
    file delete -force $unit
    exec ar rcsD $unit $object
    file delete $object
    set f [open [file join $dir UNIT.txt] w]
    puts $f [dict create kind $kind target $target provider [ProviderId] exports $exports sha256 [Sha256 $unit] cargo $cmd]
    close $f
    Log "unit $kind $target: [llength $exports] exports, sha256 [Sha256 $unit]"
    return $unit
}

# Install event_loop_linux, boringssl and http into APP/.bot_modules as one
# package graph (the application uses all three; http uses the other two):
# what the package manager's installation makes, assembled from this
# checkout and the cache, for tests and examples that run before a release.
proc httppkg::App {app {testing 0}} {
    variable root
    set target [Host]
    set modules [file join $app .bot_modules]
    foreach name {event_loop_linux boringssl http} {
        file delete -force [file join $modules $name]
    }
    file mkdir $modules
    source [file join $root tools event-loop-linux.tcl]
    eventLoopLinux::install $app
    set archives [ProviderArchives $target]
    set b [file join $modules boringssl]
    file mkdir [file join $b native]
    file copy [file join $root packages boringssl boringssl.bot] $b
    file copy [file join $archives libbotlish_boringssl.a] [file join $b native libbotlish_boringssl.a]
    set h [file join $modules http]
    file mkdir [file join $h native]
    file copy [file join $root packages http http.bot] $h
    file copy [Unit $target $testing] [file join $h native libbotlish_http.a]
    set f [open [file join $modules .graph] w]
    puts -nonewline $f "botlish package graph 1\napplication boringssl event_loop_linux http\npackage boringssl\npackage event_loop_linux\npackage http boringssl event_loop_linux\n"
    close $f
    return $app
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    set opts [dict create -testing 0]
    set args [lrange $::argv 1 end]
    set positional {}
    for {set i 0} {$i < [llength $args]} {incr i} {
        set a [lindex $args $i]
        if {[string match -* $a]} {
            dict set opts $a [lindex $args [incr i]]
        } else {
            lappend positional $a
        }
    }
    switch -- [lindex $::argv 0] {
        provider { puts [httppkg::ProviderArchives] }
        unit { puts [httppkg::Unit "" [dict get $opts -testing]] }
        app { puts [httppkg::App [file normalize [lindex $positional 0]] [dict get $opts -testing]] }
        default {
            puts stderr "usage: tclsh9.0 tools/http-package.tcl provider | unit ?-testing 1? | app DIR ?-testing 1?"
            exit 2
        }
    }
}

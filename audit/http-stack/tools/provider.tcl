# provider.tcl -- the HTTP stack census's one BoringSSL provider
# (HTTP-STACK-INTEGRATION-CENSUS.md, "BoringSSL provider").
#
#   tclsh9.0 audit/http-stack/tools/provider.tcl build     fetch and build it
#                                                         (once); print its dir
#   tclsh9.0 audit/http-stack/tools/provider.tcl dir       its dir, "" if unbuilt
#   tclsh9.0 audit/http-stack/tools/provider.tcl verify    check the built
#                                                         archives against the
#                                                         provenance record
#
# The pin is audit/http-stack/boringssl/PIN: a tag, its tag object id and
# its commit. The fetch takes the tag from the pinned URL and refuses
# anything whose tag object or peeled commit differs from the pin -- the
# pin is the authority, never the server. The build is upstream's CMake
# (Ninja, Release, position-independent), unprefixed, unpatched; its
# install layout is what boring-sys's BORING_BSSL_PATH expects
# (DIR/lib/libcrypto.a, DIR/lib/libssl.a, DIR/include/openssl/...).
#
# DIR/PROVENANCE records the pin, the compiler, the flags and the SHA-256
# of both archives and of every member: tools/linkcheck.tcl reads it to
# decide which archive members of a final link are the provider's.
#
# Everything lives under Botlish's cache directory ($BOTLISH_CACHE_DIR,
# $XDG_CACHE_HOME/botlish or ~/.cache/botlish), in http-stack/: never the
# repository. Census tooling only: Botlish's compiler never runs it.
namespace eval provider {
    variable here [file dirname [file normalize [info script]]]
    variable census [file dirname $here]
}

# Run SCRIPT (in the caller's frame) with the environment variables of the
# dict VARS set, then put back exactly those variables. Never `array unset
# env`: in Tcl that deletes the env array's link to the process environment,
# after which nothing set in it reaches a child process (the census's first
# harness ran its fault-injection controls without their faults so).
proc provider::WithEnv {vars script} {
    set saved {}
    dict for {k v} $vars {
        if {[info exists ::env($k)]} {
            dict set saved $k [list 1 $::env($k)]
        } else {
            dict set saved $k [list 0 {}]
        }
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

proc provider::CacheDir {} {
    foreach {var sub} {BOTLISH_CACHE_DIR {} XDG_CACHE_HOME botlish} {
        if {[info exists ::env($var)] && $::env($var) ne ""} {
            return [file normalize [file join $::env($var) {*}$sub http-stack]]
        }
    }
    return [file normalize [file join [file home] .cache botlish http-stack]]
}

# The pin, a dict (PIN's comment lines dropped). FILE: another pin (the
# negative controls build a second provider from one).
proc provider::Pin {{file ""}} {
    variable census
    if {$file eq ""} {
        set file [file join $census boringssl PIN]
    }
    set f [open $file r]
    set text [read $f]
    close $f
    set lines {}
    foreach line [split $text \n] {
        if {![string match "#*" [string trim $line]]} {
            lappend lines $line
        }
    }
    return [join $lines \n]
}

proc provider::Dir {{pin ""}} {
    if {$pin eq ""} {
        set pin [Pin]
    }
    return [file join [CacheDir] boringssl [dict get $pin commit]]
}

proc provider::SourceDir {pin} {
    return [file join [CacheDir] src boringssl-[dict get $pin commit]]
}

proc provider::Sha256 {file} {
    lindex [exec sha256sum $file] 0
}

# Fetch the pinned tag into the source directory and check it.
proc provider::Fetch {pin} {
    set src [SourceDir $pin]
    set tag [dict get $pin tag]
    if {![file isdirectory [file join $src .git]]} {
        file mkdir $src
        exec git -C $src init -q
        exec git -C $src remote add origin [dict get $pin url]
    }
    exec git -C $src fetch -q --depth 1 origin refs/tags/$tag:refs/tags/$tag 2>@stderr
    set object [exec git -C $src rev-parse refs/tags/$tag]
    set commit [exec git -C $src rev-parse "refs/tags/$tag^{commit}"]
    if {[dict exists $pin tagObject] && $object ne [dict get $pin tagObject]} {
        error "provider: tag $tag is object $object, the pin says [dict get $pin tagObject]"
    }
    if {$commit ne [dict get $pin commit]} {
        error "provider: tag $tag is commit $commit, the pin says [dict get $pin commit]"
    }
    exec git -C $src -c advice.detachedHead=false checkout -q --force $commit
    exec git -C $src clean -qfdx
    return $src
}

proc provider::Members {archive} {
    set tmp [file tempdir]
    try {
        exec ar x --output $tmp $archive
        set out {}
        foreach name [lsort [exec ar t $archive]] {
            lappend out $name [Sha256 [file join $tmp $name]]
        }
        return $out
    } finally {
        file delete -force $tmp
    }
}

proc provider::Build {{pinFile ""}} {
    set pin [Pin $pinFile]
    set dir [Dir $pin]
    if {[file exists [file join $dir PROVENANCE]]} {
        return $dir
    }
    set src [Fetch $pin]
    set build [file join [CacheDir] build boringssl-[dict get $pin commit]]
    file delete -force $build $dir
    puts stderr "provider: building BoringSSL [dict get $pin tag] ([dict get $pin commit]) in $build"
    exec cmake -S $src -B $build -GNinja {*}[dict get $pin cmake] >@stderr 2>@stderr
    exec ninja -C $build {*}[dict get $pin targets] >@stderr 2>@stderr
    file mkdir [file join $dir lib]
    foreach lib {crypto ssl} {
        file copy [file join $build lib$lib.a] [file join $dir lib lib$lib.a]
    }
    file copy [file join $src include] [file join $dir include]
    set cc [lindex [split [exec cc --version] \n] 0]
    set record [dict create pin $pin compiler $cc cmake [dict get $pin cmake]]
    foreach lib {crypto ssl} {
        set archive [file join $dir lib lib$lib.a]
        dict set record archive $lib [dict create sha256 [Sha256 $archive] members [Members $archive]]
    }
    set f [open [file join $dir PROVENANCE] w]
    puts $f $record
    close $f
    return $dir
}

proc provider::Provenance {{dir ""}} {
    if {$dir eq ""} {
        set dir [Dir]
    }
    set f [open [file join $dir PROVENANCE] r]
    set record [read $f]
    close $f
    return $record
}

# The archives still hash as recorded.
proc provider::Verify {{dir ""}} {
    if {$dir eq ""} {
        set dir [Dir]
    }
    set record [Provenance $dir]
    foreach lib {crypto ssl} {
        set want [dict get $record archive $lib sha256]
        set have [Sha256 [file join $dir lib lib$lib.a]]
        if {$want ne $have} {
            error "provider: lib$lib.a hashes $have, its provenance says $want"
        }
    }
    return ok
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    switch -- [lindex $::argv 0] {
        build { puts [provider::Build {*}[lrange $::argv 1 end]] }
        dir {
            set dir [provider::Dir]
            puts [expr {[file exists [file join $dir PROVENANCE]] ? $dir : ""}]
        }
        verify { puts [provider::Verify] }
        default {
            puts stderr "usage: tclsh9.0 provider.tcl build ?PIN? | dir | verify"
            exit 2
        }
    }
}

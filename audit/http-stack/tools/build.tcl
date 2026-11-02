# build.tcl -- the census's builds (HTTP-STACK-INTEGRATION-CENSUS.md,
# "Single-link proof", "Packaging").
#
#   tclsh9.0 audit/http-stack/tools/build.tcl unit NAME ?OPTIONS?
#       build the Rust linking unit (crate hs_native) as NAME:
#       -features LIST   cargo features (default: hyper tls quiche count-alloc)
#       -bssl MODE       link   BoringSSL is compiled against (the
#                               provider's headers) but not bundled: the
#                               final link takes the provider's archives
#                        bundle boring-sys bundles the provider's archives
#                               into the unit (the negative control)
#                        pin:FILE as bundle, from another pin's provider
#                        embed  as link, then the provider's archives are
#                               folded into the localized unit: a private
#                               second copy (the negative control the
#                               localization makes silent)
#                        embed:FILE as embed, another pin's archives
#       -localize 0|1    keep only the hs_* symbols global (default 1)
#   tclsh9.0 audit/http-stack/tools/build.tcl app NAME UNIT
#       assemble application NAME: the census's Botlish modules and
#       programs, UNIT's libhs_native.a, the provider's libcrypto.a and
#       libssl.a, the crypto airlock's archive, the Linux driver package
#   tclsh9.0 audit/http-stack/tools/build.tcl run APP PROGRAM ?VAR VALUE ...?
#       compile PROGRAM.bot of APP with -warnings error and run it on the
#       native backend with the environment given; prints its output
#
# Everything is built under Botlish's cache (http-stack/), never in the
# repository. Each unit directory keeps the record of its build (UNIT.txt:
# the cargo command, features, the BoringSSL mode, the unit's symbols).
namespace eval build {
    variable here [file dirname [file normalize [info script]]]
    variable census [file dirname $here]
    variable root [file dirname [file dirname $census]]
}
source [file join $build::here provider.tcl]

proc build::Target {} {
    return [file join [provider::CacheDir] target]
}

proc build::UnitDir {name} {
    return [file join [provider::CacheDir] units $name]
}

proc build::AppDir {name} {
    return [file join [provider::CacheDir] apps $name]
}

proc build::Log {text} {
    puts stderr "build: $text"
}

# Defined global symbols of the archive or object FILE (nm), a dict
# symbol -> member (the first one defining it).
proc build::Defined {file} {
    set out [dict create]
    set member ""
    foreach line [split [exec nm -A --defined-only $file 2>/dev/null] \n] {
        # file.a:member.o:ADDR T name   (or file.o:ADDR T name)
        if {![regexp {^(.*):([0-9a-f]+)? +([A-Za-z]) +(\S+)$} $line -> where addr type sym]} {
            continue
        }
        if {[string is lower $type] || $type in {U w v}} {
            continue
        }
        if {![dict exists $out $sym]} {
            dict set out $sym [lindex [split $where :] end]
        }
    }
    return $out
}

# The provider's defined symbols, cached.
proc build::ProviderSymbols {{dir ""}} {
    variable providerSymbols
    if {$dir eq ""} {
        set dir [provider::Dir]
    }
    if {![info exists providerSymbols($dir)]} {
        set syms [dict create]
        foreach lib {crypto ssl} {
            dict for {s m} [Defined [file join $dir lib lib$lib.a]] {
                dict set syms $s lib$lib.a($m)
            }
        }
        set providerSymbols($dir) $syms
    }
    return $providerSymbols($dir)
}

proc build::Unit {name args} {
    variable census
    set opts [dict merge {-features {hyper tls quiche count-alloc} -bssl link -localize 1} $args]
    set provider [provider::Build]
    provider::Verify $provider
    set dir [UnitDir $name]
    file delete -force $dir
    file mkdir $dir
    set env [dict create]
    set mode [dict get $opts -bssl]
    set bsslPath $provider
    set embed {}
    if {$mode eq "embed"} {
        set embed [lmap lib {crypto ssl} {file join $provider lib lib$lib.a}]
    } elseif {[string match embed:* $mode]} {
        set other [provider::Build [string range $mode 6 end]]
        set bsslPath $other
        set embed [lmap lib {crypto ssl} {file join $other lib lib$lib.a}]
    }
    if {$mode eq "link" || [string match embed* $mode]} {
        # Headers from the provider; archives without members, so nothing
        # is bundled into the unit and every BoringSSL reference stays
        # undefined for the final link to resolve from the provider.
        set stub [file join $dir stub-bssl]
        file mkdir [file join $stub lib]
        foreach lib {crypto ssl} {
            exec ar rcs [file join $stub lib lib$lib.a]
        }
        dict set env BORING_BSSL_PATH $stub
        dict set env BORING_BSSL_INCLUDE_PATH [file join $provider include]
    } elseif {$mode eq "bundle"} {
        dict set env BORING_BSSL_PATH $provider
    } elseif {[string match pin:* $mode]} {
        set other [provider::Build [string range $mode 4 end]]
        set bsslPath $other
        dict set env BORING_BSSL_PATH $other
    } else {
        error "build: -bssl $mode"
    }
    set features [join [dict get $opts -features] ,]
    set cmd [list cargo build --release --manifest-path [file join $census Cargo.toml] --target-dir [Target]/$name -p hs_native --no-default-features --features $features]
    Log "unit $name: [join $cmd] (BoringSSL: $mode)"
    provider::WithEnv $env {
        exec {*}$cmd >@stderr 2>@stderr
    }
    set raw [file join [Target]/$name release libhs_native.a]
    file copy -force $raw [file join $dir libhs_native.raw.a]
    set unit [file join $dir libhs_native.a]
    if {[dict get $opts -localize]} {
        # One relocatable object of the whole unit, whose only global
        # definitions are the hs_* functions: its private copy of the Rust
        # standard library (and of anything boring-sys bundled) can never
        # meet another one (NATIVE-LIBRARY-MILESTONE-1.md does the same for
        # a native library's runtime). Undefined references -- BoringSSL's
        # functions under -bssl link, libc's -- stay global.
        set object [file join $dir hs_native.o]
        # (Under -bssl bundle this fails: boring-sys and quiche both bundle
        # libcrypto.a and libssl.a, so the unit holds every BoringSSL
        # member twice, which --whole-archive turns into multiple
        # definitions. The census records it.)
        exec ld -r --whole-archive $raw {*}$embed -o $object
        set keep [file join $dir keep.txt]
        set exports [lsort [lmap s [dict keys [Defined $object]] {expr {[string match hs_* $s] ? $s : [continue]}}]]
        set f [open $keep w]
        puts $f [join $exports \n]
        close $f
        # Rust code's one COMDAT group (DW.ref.rust_eh_personality, the
        # personality routine's indirection) is deduplicated by its
        # signature's name across the whole link: beside the Botlish
        # runtime's own Rust code the linker kept the runtime's group,
        # discarded the unit's and left the unit's (now local) references
        # pointing into a discarded section ("relocation refers to a symbol
        # in a discarded section"). Renamed, the unit's group is its own.
        set groups [regexp -all -inline {COMDAT group section \[[^\]]*\] `[^']*' \[([^\]]+)\]} [exec readelf -g $object]]
        set rename {}
        foreach {- sig} $groups {
            lappend rename --redefine-sym $sig=hs_native.$sig
        }
        exec objcopy {*}$rename --keep-global-symbols=$keep $object
        file delete -force $unit
        exec ar rcs $unit $object
        file delete $object
    } else {
        file copy -force $raw $unit
    }
    # The record: what this unit defines that the provider also defines
    # (a bundled implementation), and what it leaves for the final link.
    set defined [Defined $unit]
    set provided [ProviderSymbols $provider]
    set dup [lsort [lmap s [dict keys $defined] {expr {[dict exists $provided $s] ? $s : [continue]}}]]
    set undefined [lsort -unique [lmap l [split [exec nm -u $unit 2>/dev/null] \n] {lindex $l end}]]
    set needed [lmap s $undefined {expr {[dict exists $provided $s] ? $s : [continue]}}]
    set f [open [file join $dir UNIT.txt] w]
    puts $f [dict create name $name features [dict get $opts -features] bssl $mode \
        localize [dict get $opts -localize] cargo $cmd provider $bsslPath \
        globalDefined [dict size $defined] providerSymbolsDefined [llength $dup] \
        providerSymbolsNeeded [llength $needed] sizeBytes [file size $unit]]
    close $f
    Log "unit $name: [dict size $defined] global definitions, [llength $dup] of them BoringSSL's, [llength $needed] BoringSSL references left for the final link"
    return $dir
}

# The census's Botlish files: every */botlish/*.bot of audit/http-stack.
proc build::Sources {} {
    variable census
    return [glob -directory $census */botlish/*.bot]
}

proc build::App {name unit} {
    variable root
    set dir [AppDir $name]
    file delete -force $dir
    file mkdir [file join $dir native]
    foreach f [Sources] {
        file copy $f $dir
    }
    file copy [file join [UnitDir $unit] libhs_native.a] [file join $dir native libhs_native.a]
    set provider [provider::Dir]
    foreach lib {crypto ssl} {
        file copy [file join $provider lib lib$lib.a] [file join $dir native lib$lib.a]
    }
    CryptoAirlock $dir $provider
    exec [info nameofexecutable] [file join $root tools event-loop-linux.tcl] install $dir
    return $dir
}

# The crypto airlock's C half (boringssl/hscrypto.c), compiled against the
# provider's headers into DIR/native/libhscrypto.a: it bundles nothing of
# BoringSSL (a C archive never does); the link takes the provider's.
proc build::CryptoAirlock {dir provider} {
    variable census
    set object [file join $dir native hscrypto.o]
    exec cc -O2 -Wall -Wextra -Werror -fPIC -I[file join $provider include] \
        -c [file join $census boringssl hscrypto.c] -o $object
    exec ar rcs [file join $dir native libhscrypto.a] $object
    file delete $object
}

proc build::Run {app program args} {
    variable root
    set dir [AppDir $app]
    set vars [dict create LANG C.utf8 LC_ALL C.utf8 {*}$args]
    provider::WithEnv $vars {
        set out [exec [info nameofexecutable] [file join $root main.tcl] -backend cranelift -warnings error [file join $dir $program.bot] 2>@1]
    }
    return $out
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    switch -- [lindex $::argv 0] {
        unit { puts [build::Unit {*}[lrange $::argv 1 end]] }
        app { puts [build::App {*}[lrange $::argv 1 end]] }
        run { puts [build::Run {*}[lrange $::argv 1 end]] }
        default {
            puts stderr "usage: tclsh9.0 build.tcl unit NAME ?-features L? ?-bssl link|bundle|pin:FILE? ?-localize 0|1? | app NAME UNIT | run APP PROGRAM ?VAR VALUE ...?"
            exit 2
        }
    }
}

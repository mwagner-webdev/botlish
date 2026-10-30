# check.tcl -- the census's executable evidence
# (HTTP-STACK-INTEGRATION-CENSUS.md, "Testing"): builds the Rust units and
# the applications, runs
# every probe and every negative control, and checks each claim against the
# program's own report.
#
#   tclsh9.0 audit/http-stack/tools/check.tcl ?-parts LIST? ?-build 0|1?
#
# Parts: build probes controls determinism link compile (default: all).
# -build 0 reuses units and applications already built. Prints a line per
# claim (PASS / FAIL, with the measurement) and a summary; writes the
# transcript to Botlish's cache (http-stack/check.txt); exits 1 on a FAIL.
#
# Linux x86-64 only (the Linux event-loop driver, epoll, loopback sockets);
# needs cmake, ninja, a C and C++ compiler, cargo (rustc 1.95+) and network
# access to crates.io and boringssl.googlesource.com on the first run.
source [file join [file dirname [file normalize [info script]]] linkcheck.tcl]

namespace eval check {
    variable passed 0
    variable failed 0
    variable lines {}
}

proc check::Say {text} {
    variable lines
    puts $text
    flush stdout
    lappend lines $text
}

proc check::Claim {name ok detail} {
    variable passed
    variable failed
    if {$ok} {
        incr passed
        Say "PASS $name: $detail"
    } else {
        incr failed
        Say "FAIL $name: $detail"
    }
}

# The strings a probe returned (its trace), or the failure text.
proc check::Probe {app program args} {
    if {[catch {build::Run $app $program {*}$args} out]} {
        return [list "RUN FAILED: [string range $out 0 1500]"]
    }
    set strings {}
    foreach {- s} [regexp -all -inline {"((?:[^"\\]|\\.)*)"} $out] {
        # A trace line's turn prefix ("t=12: ") is dropped: claims read the
        # text.
        regsub {^t=[0-9]+: } [subst -nocommands -novariables $s] {} s
        lappend strings $s
    }
    if {![llength $strings]} {
        return [list "NO OUTPUT: [string range $out 0 1500]"]
    }
    return $strings
}

# The first line of LINES matching RE, or "".
proc check::Line {lines re} {
    foreach l $lines {
        if {[regexp -- $re $l]} {
            return $l
        }
    }
    return ""
}

# The first capture of RE in LINES, or "".
proc check::Num {lines re} {
    foreach l $lines {
        if {[regexp -- $re $l -> v]} {
            return $v
        }
    }
    return ""
}

proc check::Has {lines re} {
    expr {[Line $lines $re] ne ""}
}

proc check::Build {} {
    Say "== build"
    provider::Build
    Claim provider-provenance [expr {[provider::Verify] eq "ok"}] "pinned [dict get [provider::Provenance] pin tag] [dict get [provider::Provenance] pin commit], archives hash as recorded"
    build::Unit full
    set rec [build::Read [file join [build::UnitDir full] UNIT.txt]]
    Claim unit-link-only [expr {[dict get $rec providerSymbolsDefined] == 0 && [dict get $rec providerSymbolsNeeded] > 0}] \
        "the Rust unit defines [dict get $rec providerSymbolsDefined] BoringSSL symbols and leaves [dict get $rec providerSymbolsNeeded] for the final link"
    build::App probes full
    build::Unit tokioctl -features {hyper tls quiche tokio-control}
    build::App tokioctl tokioctl
}

proc check::Probes {} {
    # (measure.bot runs here too; its lines are printed, not judged.)
    Say "== probes (Linux driver unless noted)"
    set t [Probe probes cryptoonly]
    Claim A-crypto-only [expr {[Has $t {^sha256 kat ok}] && [Has $t {^hmac-sha256 kat ok}] && [Has $t {^ed25519 verify ok}] && [Has $t {rejects altered message ok}] && [Has $t {sign after release bytes 0}]}] \
        "known answers, Ed25519 sign/verify, key wiped on release; no Rust unit, no event loop in the link ([Line $t {^api version}])"
    set t [Probe probes h1]
    Claim hyper-http1 [expr {[Has $t {client: status 200}] && [Has $t {client: body bytes 55 reads 5 end -1}] && [Has $t {bystander: ticks}]}] \
        [Line $t {client: body bytes}]
    set t [Probe probes h2]
    set fast [Num $t {consumer /fast .* done at us (\d+)}]
    set slow [Num $t {consumer /slow .* done at us (\d+)}]
    set slowProducer [Num $t {producer GET /slow done at us (\d+)}]
    set waited [Num $t {producer GET /slow .* waited for room (\d+)}]
    set held [lmap l $t {expr {[regexp {max chunks held by rust (\d+)} $l -> v] ? $v : [continue]}}]
    Claim hyper-http2-streams [expr {$fast ne "" && $slow ne "" && $fast < $slow && [Has $t {consumer /fast status 200 bytes 65536}] && [Has $t {consumer /slow status 200 bytes 65536}]}] \
        "two streams on one connection; /fast done [expr {$slow ne "" && $fast ne "" ? ($slow - $fast) / 1000 : "?"}] ms before /slow"
    Claim hyper-http2-backpressure [expr {$waited ne "" && $waited > 0 && $slowProducer ne "" && $slowProducer > $fast && [tcl::mathfunc::max 0 {*}$held] <= 1}] \
        "the /slow producer waited for room $waited times and finished [expr {$slow ne "" && $slowProducer ne "" ? ($slow - $slowProducer) / 1000 : "?"}] ms before its consumer; Rust held at most [tcl::mathfunc::max 0 {*}$held] chunk"
    Claim hyper-http2-cleanup [Has $t {watched after stop 0 retired 3}] [Line $t {watched after stop}]
    Claim hyper-http2-bounded-polls [expr {[Num $t {max polls per run (\d+)}] <= 16}] [Line $t {^rust: polls}]
    set t [Probe probes tls]
    Claim tls-scenarios [Has $t {tls scenarios as expected 8 of 8}] [join [lmap l $t {expr {[string match "tls *" $l] ? $l : [continue]}}] "; "]
    Claim tls-cleanup [Has $t {watched after stop 0}] [Line $t {watched after stop}]
    set t [Probe probes h3]
    set fast [Num $t {h3 consumer /fast .* done at us (\d+)}]
    set slow [Num $t {h3 consumer /slow .* done at us (\d+)}]
    Claim quiche-http3-streams [expr {[Has $t {h3 handshake: state 1}] && [Has $t {h3 consumer /fast status 200 bytes 65536}] && [Has $t {h3 consumer /slow status 200 bytes 65536}] && $fast ne "" && $slow ne "" && $fast < $slow}] \
        "[Line $t {h3 handshake}]; /fast done [expr {$fast ne "" && $slow ne "" ? ($slow - $fast) / 1000 : "?"}] ms before /slow"
    set held [Num $t {h3 consumer /slow .* max bytes held by rust (\d+)}]
    Claim quiche-http3-backpressure [expr {[Num $t {h3 producer GET /slow .* waited for room (\d+)}] > 0 && $held ne "" && $held <= 16384}] \
        "[Line $t {h3 producer GET /slow done}]; Rust held at most $held bytes"
    Claim quiche-tls-verify [Has $t {h3 wrong-host: state -92298}] "[Line $t {h3 wrong-host}] (CRYPTO_ERROR bad_certificate)"
    Claim quiche-release [expr {[Has $t {h3 released endpoint: stream state -90008}] && [Has $t {watched after stop 0}]}] "[Line $t {h3 released endpoint}]; [Line $t {watched after stop}]"
    set t [Probe probes h3time]
    Claim quiche-pacing [expr {[Num $t {server paced packets (\d+)}] > 0}] [Line $t {h3 paced}]
    set after [Num $t {h3 idle: closed with state -92000 after us (\d+)}]
    Claim quiche-idle-timer [expr {$after ne "" && $after >= 300000 && $after < 450000 && [Num $t {h3 idle: .* kernel sleeps (\d+)}] >= 1}] [Line $t {h3 idle}]
    set t [Probe probes sched]
    set turns [Num $t {bounded: spinner 20000 over turns (\d+)}]
    Claim bounded-progress [expr {$turns ne "" && $turns >= 1000 && [Num $t {bounded: .* max polls per run (\d+)}] <= 16 && [Num $t {yielder: turns (\d+)}] >= 1000}] \
        "[Line $t {^bounded}]; [Line $t {^yielder}]"
    set us [Num $t {foreign: completed after us (\d+)}]
    Claim foreign-wake [expr {$us ne "" && $us < 200000 && [Has $t {posts 1 lost 0}]}] [Line $t {^foreign}]
    set us [Num $t {kick: .* finished after us (\d+)}]
    Claim application-call-kick [expr {$us ne "" && $us < 100000}] [Line $t {^kick}]
    Claim panic-containment [Has $t {panics: contained 2 call returned -90001 other thread got -90002}] [Line $t {^panics}]
    set t [Probe probes mem]
    Claim deterministic-driver [expr {[Has $t {http/1.1: status 200 bytes 1230 reads 40}] && [Has $t {http/2: status 200 bytes 1230 reads 40}] && [Has $t {woke at 5000002 after start}] && [Has $t {interest requests 0}]}] \
        "[Line $t {^http/2}]; [Line $t {rust sleep}]"
    set t [Probe probes lifetimes]
    Claim lifetime-listener [Has $t {after release, same connection status 200 body fast}] [Line $t {^listener}]
    Claim lifetime-connection [expr {[llength [lmap l $t {expr {[string match "connection: stream *: error -90008" $l] ? $l : [continue]}}]] == 2}] "both streams of the released connection failed (-90008, cancelled)"
    Claim lifetime-stale [Has $t {its status 80 ms later 200}] [Line $t {^stale}]
    Claim lifetime-shutdown [Has $t {shutdown: .* watched 0}] [Line $t {^shutdown}]
    set t [Probe probes stall]
    set offered [Num $t {stall 500 ms: producer offered bytes (\d+)}]
    set holds [Num $t {rust holds at most (\d+)}]
    Claim stalled-consumer [expr {$offered ne "" && $offered <= 131072 && $holds ne "" && $holds <= 16384 && [Has $t {drained: bytes 4194304 rust held at most 16384}]}] \
        "[Line $t {^stall}]; [Line $t {^drained}]"
    set cpu [Num $t {idle 1 s .* cpu us (\d+)}]
    Claim idle-cpu [expr {$cpu ne "" && $cpu < 30000 && [Num $t {idle 1 s .* kernel sleeps (\d+)}] >= 5}] [Line $t {^idle}]
    set t [Probe probes combined]
    Claim combined-consumers [expr {[Has $t {^A crypto airlock: sha256 bytes 32}] && [Has $t {^B https: protocol 2 status 200}] && [Has $t {^C http/3: status 200}]}] \
        "[Line $t {^B https}]; [Line $t {^C http/3}]"
    Claim combined-one-provider [Has $t {-- ONE PROVIDER$}] [Line $t {^provider}]
    set t [Probe tokioctl tokioctl]
    Claim no-tokio-runtime [expr {[Has $t {fixture result 0 panics contained 1}] && [Has $t {executor still runs}]}] "[Line $t {tokio::spawn}] (the control's unit has tokio's runtime feature; tokio::spawn finds no runtime, the panic is contained)"
    set t [Probe probes measure]
    set m [lmap l $t {expr {[string match "measure *" $l] || [string match "longest *" $l] || [string match "bystander*" $l] ? $l : [continue]}}]
    foreach l $m {
        Say "     $l"
    }
    Claim measurements-recorded [expr {[llength $m] >= 6}] "measure.bot: [llength $m] lines (section 13 of the report)"
    set tree [exec cargo tree --manifest-path [file join $::build::census Cargo.toml] -p hs_native -e features -i tokio --prefix none 2>@1]
    set names [lsort -unique [lmap {- f} [regexp -all -inline {tokio feature "([a-z-]+)"} $tree] {set f}]]
    Claim tokio-features [expr {"rt" ni $names && "time" ni $names && "net" ni $names}] "tokio in the probes' unit (a dependency of hyper and h2) has features: $names"
}

proc check::Controls {} {
    Say "== negative controls (HS_CENSUS_FAULT)"
    set t [Probe probes sched HS_CENSUS_FAULT 2]
    Claim control-unbounded-poll [expr {[Num $t {max polls per run (\d+)}] >= 20000 && [Num $t {yielder: turns (\d+)}] <= 5}] "[Line $t {^bounded}]; [Line $t {^yielder}]"
    set t [Probe probes sched HS_CENSUS_FAULT 1]
    set us [Num $t {foreign: completed after us (\d+)}]
    Claim control-lost-foreign-wake [expr {$us ne "" && $us >= 400000 && [Has $t {lost 1}]}] [Line $t {^foreign}]
    set t [Probe probes sched HS_CENSUS_FAULT 8]
    set us [Num $t {kick: .* finished after us (\d+)}]
    Claim control-no-kick [expr {($us ne "" && $us >= 400000) || [Has $t {STALLED}]}] "[Line $t {^kick}] [Line $t {STALLED}]"
    set t [Probe probes mem HS_CENSUS_FAULT 64]
    Claim control-missing-timer [expr {[Has $t {STALLED: parts finished 2 of 3}]}] [Line $t {STALLED}]
    set t [Probe probes h3time HS_CENSUS_FAULT 32]
    Claim quiche-loss-recovery [expr {[Has $t {h3 handshake: state 1}] && [Num $t {client timeouts (\d+)}] >= 1}] "first Initial dropped: [Line $t {h3 handshake}]"
    set t [Probe probes h3time HS_CENSUS_FAULT 48]
    Claim control-quiche-timer-never-armed [Has $t {STALLED}] "first Initial dropped, timeouts never armed: [Line $t {STALLED}]"
    set t [Probe probes lifetimes HS_CENSUS_FAULT 384]
    Claim control-stale-completion [Has $t {its status 80 ms later 299}] [Line $t {^stale}]
    set t [Probe probes stall HS_CENSUS_FAULT 512]
    set holds [Num $t {rust holds at most (\d+)}]
    Claim control-no-backpressure [expr {$holds ne "" && $holds >= 4000000}] [Line $t {^stall}]
}

proc check::Determinism {} {
    Say "== determinism"
    set a [Probe probes mem]
    set b [Probe probes mem]
    Claim deterministic-trace [expr {$a eq $b && [llength $a] > 100}] "two runs under the deterministic driver: [llength $a] trace lines, identical: [expr {$a eq $b}]"
}

proc check::Link {} {
    Say "== single-link proof"
    foreach linker {rustc system} {
        set r [linkcheck::Run probes combined $linker]
        Say $r
        Claim link-one-provider-$linker [string match "*verdict: ONE PROVIDER" $r] "[lindex [split $r \n] end]"
    }
    # A private second copy inside the localized unit: the link is silent,
    # the runtime identity and the symbol table are not.
    build::Unit embed -bssl embed
    build::App dup embed
    set t [Probe dup combined]
    Claim control-private-copy-runtime [Has $t {DIFFERENT PROVIDERS}] [Line $t {^provider}]
    set r [linkcheck::Run dup combined rustc]
    Claim control-private-copy-link [string match "*NOT ONE PROVIDER*" $r] [lindex [split $r \n] end]
    # boring-sys's own arrangement: BoringSSL bundled into the Rust unit
    # (twice: boring-sys and quiche each declare it), not localized. Not a
    # failure to detect: with the provider's archives first in Botlish's
    # archive group, every BoringSSL member the link needs comes from them,
    # and the bundled copies are dead weight -- decided by archive order
    # alone.
    build::Unit bundled -bssl bundle -localize 0 -features {hyper tls quiche}
    set raw [file join [build::UnitDir bundled] libhs_native.raw.a]
    set copies [llength [lsearch -all -exact [split [exec ar t $raw] \n] sha256.cc.o]]
    Claim bundled-twice [expr {$copies == 2}] "boring-sys and quiche both bundle libcrypto.a: sha256.cc.o appears $copies times in the Rust staticlib"
    build::App bundled bundled
    set t [Probe bundled combined]
    if {[catch {linkcheck::Run bundled combined rustc} r]} {
        set r "the link failed: [string range $r 0 400]"
    }
    Say $r
    Claim bundled-link-order [expr {[string match "*verdict: ONE PROVIDER" $r] && [Has $t {-- ONE PROVIDER$}]}] \
        "the program ran ([Line $t {^provider}]); the link took every BoringSSL member from the provider's archives (first in the group): [lindex [split $r \n] end]"
    # Another revision: the repository's C FFI pin, bundled.
    build::Unit otherpin -bssl pin:[file join $::build::census boringssl PIN.repo-c-ffi] -localize 0 -features {hyper tls quiche}
    build::App otherpin otherpin
    set t [Probe otherpin combined]
    Claim control-other-revision [expr {[Has $t {DIFFERENT PROVIDERS}]}] \
        "the program linked and ran: [Line $t {^provider}]"
}

proc check::Compile {} {
    Say "== compile-time controls"
    set t [Probe probes reject_provider]
    regexp {library "crypto" is declared with two static archives[^(]*} [lindex $t 0] said
    Claim control-second-provider-declared [string match "*LINK-CONFLICT*" [lindex $t 0]] "LINK-CONFLICT: [expr {[info exists said] ? $said : [string range [lindex $t 0] 0 200]}]"
    set t [Probe probes reject_driver]
    Claim control-library-installs-driver [string match "*CONTEXT-INSTALLATION-UNSUPPORTED*" [lindex $t 0]] "a protocol library installing its own driver: rejected"
}

proc build::Read {path} {
    set f [open $path r]
    set t [read $f]
    close $f
    return $t
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    set parts {build probes controls determinism link compile}
    set doBuild 1
    foreach {k v} $::argv {
        switch -- $k {
            -parts { set parts $v }
            -build { set doBuild $v }
            default { puts stderr "usage: tclsh9.0 check.tcl ?-parts LIST? ?-build 0|1?"; exit 2 }
        }
    }
    if {!$doBuild} {
        set parts [lsearch -all -inline -not -exact $parts build]
    }
    set started [clock milliseconds]
    foreach part $parts {
        check::[string totitle $part]
    }
    check::Say "== $check::passed passed, $check::failed failed ([expr {([clock milliseconds] - $started) / 1000}] s)"
    set f [open [file join [provider::CacheDir] check.txt] w]
    puts $f [join $check::lines \n]
    close $f
    exit [expr {$check::failed > 0}]
}

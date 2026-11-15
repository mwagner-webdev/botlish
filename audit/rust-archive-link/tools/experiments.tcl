# experiments.tcl -- the matrix of HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-
# MILESTONE-1.md, sections 3 and 4, on this host: the fixture's unit built
# with each notification object, linked raw (unlocalized) and localized,
# into each consumer program, with each Botlish linker; every case's link
# outcome, exit status and value, and the executable's copies of the
# symbols two Rust standard libraries share. Records what happens; judges
# nothing (tests/rust-archive-link.test does).
#
#   tclsh9.0 audit/rust-archive-link/tools/experiments.tcl OUTDIR ?-toolchain2 T?
#
# OUTDIR/results.tsv, OUTDIR/surfaces.txt (each archive's global
# definitions and undefined references), OUTDIR/logs/CASE.txt (a failed
# link's or run's output). The units: default-weakdef (the weak fallback,
# the package's), default-weakref (http's notify.c), both built by cargo's
# default rustc -- the Botlish runtime's -- and, with -toolchain2 T, the
# weak-fallback unit built by another rustc (a rustup toolchain).
source [file join [file dirname [file normalize [info script]]] rustlink.tcl]

set out [file normalize [lindex $argv 0]]
if {$out eq ""} {
    puts stderr "usage: tclsh9.0 audit/rust-archive-link/tools/experiments.tcl OUTDIR ?-toolchain2 T?"
    exit 2
}
set opts [dict create -toolchain2 ""]
foreach {k v} [lrange $argv 1 end] { dict set opts $k $v }
file mkdir [file join $out logs]
set work [file join [rustlink::CacheDir] experiments]
file delete -force $work
file mkdir $work

# The most telling line of a failed link's output: a linker's own
# duplicate, multiple-definition or undefined-symbol line before anything
# else.
proc first {text} {
    foreach pattern {{duplicate symbol} {multiple definition} {[Uu]ndefined symbol} {undefined reference} {in function} {error}} {
        foreach line [split $text \n] {
            if {[regexp -- $pattern $line]} {
                return [string range [string trim $line] 0 200]
            }
        }
    }
    return [string range [string trim [lindex [split $text \n] 0]] 0 200]
}

set units [list default-weakdef [rustlink::unit -notify weakdef] default-weakref [rustlink::unit -notify weakref]]
if {[dict get $opts -toolchain2] ne ""} {
    set t [dict get $opts -toolchain2]
    lappend units $t-weakdef [rustlink::unit -notify weakdef -toolchain $t]
}
set provider [rustlink::provider]
set surfaces [open [file join $out surfaces.txt] w]
set results [open [file join $out results.tsv] w]
puts $results [join {unit form program linker link status verdict personality_global personality_local detail} \t]
foreach {name raw} $units {
    set forms [list raw $raw localized [rustlink::localized $raw -out [file join $work $name-localized librustlink.a]]]
    if {$name eq "default-weakdef"} {
        lappend forms fallback-localized-away [rustlink::localized $raw -keep {rl_*} -out [file join $work $name-hidden librustlink.a]]
    }
    foreach {form archive} $forms {
        set g [rustunit::globals $archive -format [rustlink::format]]
        set u [rustunit::undefined $archive -format [rustlink::format]]
        set how ""
        if {$form ne "raw" && [rustlink::format] eq "macho"} {
            set how ", LC_BUILD_VERSION [rustunit::buildVersion $archive]"
        }
        puts $surfaces "== $name $form [file size $archive] bytes: [llength $g] global definitions, [llength $u] undefined references$how"
        puts $surfaces "   global: [join [lrange $g 0 39] { }][expr {[llength $g] > 40 ? " ..." : ""}]"
        puts $surfaces "   undefined (weak or Rust/C runtime): [join [lmap s $u {expr {[string match *post2* $s] || [string match *personality* $s] || [string match __rust* $s] ? $s : [continue]}}] { }]"
        foreach program {without_provider.bot with_provider.bot} {
            set app [rustlink::app [file join $work app-$name-$form] $archive $provider]
            foreach linker {rustc system} {
                set c [rustlink::case $app $program $linker]
                set p [expr {[dict get $c exe] ne "" ? [rustlink::copies [dict get $c exe] rust_eh_personality] : {global - local -}}]
                set detail ""
                set log [file join $out logs $name-$form-[file rootname $program]-$linker.txt]
                if {[dict get $c link] eq "failed"} {
                    set detail [first [dict get $c error]]
                    set f [open $log w]; puts $f [dict get $c error]; close $f
                } elseif {[dict get $c verdict] ne "pass"} {
                    set detail [join [dict get $c value] " | "]
                    set f [open $log w]; puts $f "status [dict get $c status]\n[dict get $c output]\n[dict get $c value]"; close $f
                } else {
                    set detail "toolchain [dict get $c toolchain]"
                }
                puts $results [join [list $name $form [file rootname $program] $linker [dict get $c link] [dict get $c status] \
                    [dict get $c verdict] [dict get $p global] [dict get $p local] $detail] \t]
                flush $results
            }
        }
    }
}
close $results
close $surfaces
puts [string trim [exec cat [file join $out results.tsv]]]

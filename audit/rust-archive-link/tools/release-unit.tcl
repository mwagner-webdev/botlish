# release-unit.tcl -- the fixture's native files as a release recipe builds
# them (HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md, section
# 7): the unit (its notification object the weak fallback, unit/notify-
# weakdef.c) by cargo --locked with a pinned rustc in a fresh target
# directory, localized (tools/rust-unit.tcl), and the provider's archive,
# into OUTDIR with a record of the toolchain and every file's SHA-256.
# Two runs on two machines with the same pin must write the same archives:
# the CI compares them (reproducible native compilation), and the package
# job packs each machine's set (reproducible complete package).
#
#   tclsh9.0 audit/rust-archive-link/tools/release-unit.tcl OUTDIR ?-toolchain T?
#
# OUTDIR/librustlink.a, OUTDIR/librustlink_provider.a, OUTDIR/RECORD.txt.
# The toolchain defaults to 1.97.0, the pinned author image's
# (tools/package-build/Dockerfile).
source [file join [file dirname [file normalize [info script]]] rustlink.tcl]

set out [lindex $argv 0]
if {$out eq ""} {
    puts stderr "usage: tclsh9.0 audit/rust-archive-link/tools/release-unit.tcl OUTDIR ?-toolchain T?"
    exit 2
}
set out [file normalize $out]
set opts [dict create -toolchain 1.97.0]
foreach {k v} [lrange $argv 1 end] { dict set opts $k $v }
set toolchain [dict get $opts -toolchain]
file delete -force $out
file mkdir $out

proc sha256 {path} {
    if {[auto_execok sha256sum] ne ""} {
        return [lindex [exec sha256sum $path] 0]
    }
    return [lindex [exec shasum -a 256 $path] 0]
}

proc firstLine {args} {
    if {[catch {exec {*}$args 2>@1} text]} {
        return "(unavailable: [lindex [split $text \n] 0])"
    }
    return [lindex [split [string trim $text] \n] 0]
}

# One target directory path for every release build (it is mapped out of
# the objects, and the mapping is part of RUSTFLAGS: a path of its own per
# build could change what cargo hashes), emptied first: nothing
# incremental, nothing reused.
set dir [file join [rustlink::CacheDir] release-target]
file delete -force $dir
set raw [rustlink::unit -notify weakdef -toolchain $toolchain -dir $dir]
rustlink::localized $raw -out [file join $out librustlink.a]
rustunit::check [file join $out librustlink.a] [rustlink::surface weakdef] -format [rustlink::format]
rustlink::provider -out [file join $out librustlink_provider.a]
set record [list \
    target [rustlink::target] \
    format [rustlink::format] \
    rustc [firstLine rustc +$toolchain --version] \
    cargo [firstLine cargo +$toolchain --version] \
    cc [firstLine cc --version] \
    sdk [expr {[rustlink::format] eq "macho" ? [firstLine xcrun --show-sdk-version] : "-"}] \
    xcode [expr {[rustlink::format] eq "macho" ? [firstLine xcodebuild -version] : "-"}] \
    ld [expr {[rustlink::format] eq "macho" ? [firstLine ld -v] : [firstLine ld --version]}] \
    raw_sha256 [sha256 $raw] \
    raw_bytes [file size $raw] \
    unit_sha256 [sha256 [file join $out librustlink.a]] \
    unit_bytes [file size [file join $out librustlink.a]] \
    provider_sha256 [sha256 [file join $out librustlink_provider.a]] \
    exports [join [rustunit::globals [file join $out librustlink.a] -format [rustlink::format]] " "]]
file delete -force $dir
set f [open [file join $out RECORD.txt] w]
foreach {k v} $record {
    puts $f "$k\t$v"
}
close $f
puts [string trim [exec cat [file join $out RECORD.txt]]]

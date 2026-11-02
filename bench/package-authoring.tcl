# package-authoring.tcl -- the author's side's costs
# (PACKAGE-MANAGER-MILESTONE-3.md, "Performance").
#
#   tclsh9.0 bench/package-authoring.tcl -repository DIR ?-runs N?
#
# DIR holds a raven release and its provenance record (made by
# tools/package-repository.tcl or tools/package-build/author.sh). Measured,
# each the median of N runs (default 5), every command as main.tcl in a
# child process, as an author runs it:
#
#   native add of the release's x86-64 libraven.so.0 (1.7 MB) into a fresh
#     package, and the same again (unchanged);
#   package stage of the 22-module generated binding, and again (unchanged);
#   native audit of the release's package directory (both targets);
#   package pack of it (the audit included), into an empty directory and
#     over the identical artifact (unchanged);
#   package pack -evidence (the provenance record: every file's digest, two
#     Git trees recomputed from 450 and 80 source files) -- with the record's
#     sources' directories when this machine has them, else without;
#   package compare of the release with itself and with a candidate whose
#     one library differs;
#   package inspect -provenance;
#   a pure-Botlish package's pack (no audit: the PM-1 path).

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root pm pm.tcl]
set runs 5
set repo ""
foreach {option value} $argv {
    switch -- $option {
        -runs { set runs $value }
        -repository { set repo [file normalize $value] }
        default { puts stderr "usage: tclsh9.0 bench/package-authoring.tcl -repository DIR ?-runs N?"; exit 2 }
    }
}
set artifacts [glob -nocomplain -directory $repo raven-*.botpkg]
if {$repo eq "" || [llength $artifacts] != 1} {
    puts stderr "bench/package-authoring.tcl: -repository DIR must hold one raven-VERSION.botpkg"
    exit 2
}
set artifact [lindex $artifacts 0]
set record [string map {.botpkg .provenance.json} $artifact]
set main [file join $root main.tcl]
set work [file tempdir botlish-authoring-bench]

proc median {values} {
    return [lindex [lsort -real $values] [expr {[llength $values] / 2}]]
}

proc measure {n script {setup ""}} {
    set times {}
    for {set i 0} {$i < $n} {incr i} {
        uplevel 1 $setup
        set t [clock microseconds]
        uplevel 1 $script
        lappend times [expr {([clock microseconds] - $t) / 1000.0}]
    }
    return [format %.1f [median $times]]
}

proc run {args} {
    if {[catch {exec [info nameofexecutable] $::main {*}$args 2>@1} out]} {
        if {[lindex $::errorCode 0] ne "CHILDSTATUS" || [lindex $::errorCode end] != 1} {
            error $out
        }
    }
    return $out
}

proc row {what ms} {
    puts [format "| %-74s | %9s ms |" $what $ms]
}

try {
    # The release as a package directory (its files are exactly that).
    set files [dict get [pm::archive::read $artifact] files]
    set pkg [file join $work raven]
    foreach {path bytes} $files {
        set full [file join $pkg {*}[split $path /]]
        file mkdir [file dirname $full]
        pm::WriteNew $full $bytes
    }
    set lib [file join $work libraven.so.0]
    pm::WriteNew $lib [dict get $files targets/linux-x86_64/native/libraven.so.0]
    set binding [file join $work gen raven]
    foreach {path bytes} $files {
        if {[string match targets/linux-x86_64/raven/* $path]} {
            set full [file join $binding [string range $path [string length targets/linux-x86_64/raven/] end]]
            file mkdir [file dirname $full]
            pm::WriteNew $full $bytes
        }
    }
    puts "authoring costs ([pm::target::host], $runs runs each, medians): [file tail $artifact], [file size $artifact] bytes"
    puts ""
    puts "| operation | median |"
    puts "|---|---:|"
    set n 0
    row "native add libraven.so.0 (1.7 MB) into a fresh package" [measure $runs {
        run native add $lib -target linux-x86_64 -name raven -symbol Rinit_ex -package $fresh
    } {
        set fresh [file join $work fresh-[incr n]]
        file mkdir $fresh
        pm::WriteNew [file join $fresh botlish.json] "{\"schema\": 1, \"name\": \"raven\", \"version\": \"1.0.0\"}\n"
    }]
    row "native add of the same file again (unchanged)" [measure $runs {
        run native add $lib -target linux-x86_64 -name raven -symbol Rinit_ex -package $fresh
    }]
    row "package stage -modules of the 22-module binding" [measure $runs {
        run package stage $fresh -target linux-x86_64 -modules $binding
    } {
        file delete -force [file join $fresh targets linux-x86_64 raven]
    }]
    row "package stage of the same binding again (unchanged)" [measure $runs {
        run package stage $fresh -target linux-x86_64 -modules $binding
    }]
    row "native audit of the release (2 targets, 4 bundled files, 943 C functions each)" [measure $runs {
        run native audit $pkg
    }]
    set out [file join $work out]
    row "package pack of the release (audit included), into an empty directory" [measure $runs {
        run package pack $pkg -out $out
    } {
        file delete -force $out
    }]
    row "package pack again over the identical artifact (unchanged)" [measure $runs {
        run package pack $pkg -out $out
    }]
    # The evidence of the record, rebuilt: its sources' directories exist
    # here only on the machine that built them.
    set evidence [file join $work evidence.json]
    set recordValue [pm::json::decode [pm::ReadBytes $record] -limit [expr {64 * 1024 * 1024}]]
    set members [pm::json::payload $recordValue]
    set sources {}
    set cache [expr {[info exists ::env(BOTLISH_CACHE_DIR)] ? $::env(BOTLISH_CACHE_DIR) : [file join [file home] .cache botlish]}]
    set checked 0
    foreach source [pm::json::payload [dict get $members sources]] {
        set fields [pm::json::payload $source]
        set name [pm::json::payload [dict get $fields name]]
        set dir [file join $cache c-header-src $name]
        if {[file isdirectory $dir]} {
            lappend fields directory [list str $dir]
            incr checked
        }
        lappend sources [list obj $fields]
    }
    set ev [list obj [list evidence {num 1} sources [list arr $sources] builds [dict get $members builds] generators [dict get $members generators]]]
    pm::WriteNew $evidence [pm::json::encode $ev]
    set withRecord [file join $work out-record]
    row "package pack -evidence (the record; $checked source tree(s) recomputed)" [measure $runs {
        run package pack $pkg -out $withRecord -evidence $evidence
    } {
        file delete -force $withRecord
    }]
    row "package compare of the release with itself" [measure $runs {
        run package compare $artifact $artifact
    }]
    set candidate [file join $work candidate raven]
    file mkdir [file dirname $candidate]
    file copy $pkg $candidate
    set lib2 [file join $candidate targets linux-aarch64 native libraven.so.0]
    set bytes [pm::ReadBytes $lib2]
    file delete $lib2
    pm::WriteNew $lib2 [string replace $bytes 1000 1000 [expr {[string index $bytes 1000] eq "x" ? "y" : "x"}]]
    set candidateOut [file join $work candidate-out]
    file mkdir $candidateOut
    set descriptor [pm::descriptor::read [file join $candidate botlish.json] pack]
    set candidateFiles [pm::commands::Collect $candidate]
    dict set candidateFiles botlish.json [pm::descriptor::encode $descriptor 0]
    pm::WriteNew [file join $candidateOut [file tail $artifact]] [pm::archive::bytes $candidateFiles]
    row "package compare with a candidate whose AArch64 libraven differs" [measure $runs {
        run package compare $artifact [file join $candidateOut [file tail $artifact]]
    }]
    row "package inspect -provenance" [measure $runs {
        run package inspect $artifact -provenance $record
    }]
    set pure [file join $work pure]
    file mkdir $pure
    pm::WriteNew [file join $pure botlish.json] "{\"schema\": 1, \"name\": \"pure\", \"version\": \"1.0.0\"}\n"
    pm::WriteNew [file join $pure pure.bot] "fn n() -> int:\n    1\n"
    row "package pack of a pure-Botlish package (no audit)" [measure $runs {
        run package pack $pure -out [file join $work pure-out]
    } {
        file delete -force [file join $work pure-out]
    }]
} finally {
    file delete -force $work
}

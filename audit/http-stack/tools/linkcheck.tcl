# linkcheck.tcl -- the single-link proof (HTTP-STACK-INTEGRATION-CENSUS.md,
# "Single-link proof").
#
#   tclsh9.0 audit/http-stack/tools/linkcheck.tcl APP PROGRAM ?-linker rustc|system?
#
# Builds PROGRAM of application APP (tools/build.tcl app) as a standalone
# executable with Botlish's own linker (main.tcl -emit-native-executable),
# wrapping the linker -- RUSTC for the rustc linker, BOTLISH_NATIVE_SYSTEM_LINKER
# for the system linker -- to keep the exact link command and a link map,
# and reports:
#
#   inputs     the link plan Botlish resolved (BOTLISH_NATIVE_LINK_LOG) and
#              the archives on the final command line
#   provider   the provider's archives in the link, hashed against its
#              PROVENANCE record (the archives the pin built)
#   members    every archive member the link map shows included, by
#              archive: the provider's, and any other member that defines a
#              symbol the provider defines (a bundled copy)
#   symbols    every global symbol the provider defines, counted in the
#              executable's whole symbol table (local symbols included): a
#              second copy shows as a count above one, even when it was
#              made local inside another archive
#
# and the verdict: ONE PROVIDER when the provider's archives are the pinned
# ones, no other included member defines a provider symbol, and no
# provider symbol is defined twice. The report goes to stdout and to
# APP/linkcheck-PROGRAM-LINKER.txt.
source [file join [file dirname [file normalize [info script]]] build.tcl]

namespace eval linkcheck {}

proc linkcheck::Wrapper {dir linker} {
    set log [file join $dir link-args.txt]
    set map [file join $dir link.map]
    set script [file join $dir wrap-$linker.sh]
    set f [open $script w]
    if {$linker eq "system"} {
        puts $f "#!/bin/sh\nprintf '%s\\n' \"\$@\" > '$log'\nexec cc -Wl,-Map='$map' \"\$@\""
    } else {
        # rustc: the final link's arguments (--print link-args) and a map.
        puts $f "#!/bin/sh\nexec rustc --print link-args -C link-arg=-Wl,-Map='$map' \"\$@\" > '$log'"
    }
    close $f
    file attributes $script -permissions 0755
    return [list $script $log $map]
}

proc linkcheck::Run {app program {linker rustc}} {
    set appdir [build::AppDir $app]
    set dir [file join $appdir linkcheck-$program-$linker]
    file delete -force $dir
    file mkdir $dir
    lassign [Wrapper $dir $linker] script argsLog map
    set planLog [file join $dir link-plan.txt]
    set env [list BOTLISH_NATIVE_LINK_LOG $planLog LANG C.utf8 LC_ALL C.utf8]
    if {$linker eq "system"} {
        lappend env BOTLISH_NATIVE_LINKER system BOTLISH_NATIVE_SYSTEM_LINKER $script
    } else {
        lappend env BOTLISH_NATIVE_LINKER rustc RUSTC $script
    }
    provider::WithEnv $env {
        set out [exec [info nameofexecutable] [file join $::build::root main.tcl] -backend cranelift -warnings error \
            -emit-native-executable [file join $appdir $program.bot] 2>@1]
    }
    if {![regexp {executable: (\S+)} $out -> exe]} {
        error "linkcheck: no executable:\n$out"
    }
    set report {}
    lappend report "linkcheck $app $program ($linker linker): $exe"
    # Inputs.
    set plan [split [string trim [Read $planLog]] \n]
    lappend report "link plan (BOTLISH_NATIVE_LINK_LOG):"
    foreach line $plan {
        lappend report "  $line"
    }
    set argv [Read $argsLog]
    set archives [lsort -unique [regexp -all -inline {[^\s"']+\.a\M} $argv]]
    lappend report "archives on the final link's command line: [llength $archives]"
    foreach a $archives {
        lappend report "  $a"
    }
    # The provider's archives, against their provenance.
    set provider [provider::Dir]
    set record [provider::Provenance $provider]
    set problems {}
    foreach lib {crypto ssl} {
        set linked [file join $appdir native lib$lib.a]
        set want [dict get $record archive $lib sha256]
        set have [provider::Sha256 $linked]
        set ok [expr {$want eq $have ? "matches" : "DIFFERS FROM"}]
        lappend report "provider lib$lib.a in the link: sha256 $have $ok the provenance record ([dict get $record pin tag] [dict get $record pin commit])"
        if {$want ne $have} {
            lappend problems "lib$lib.a is not the pinned build"
        }
    }
    # Members the map shows included.
    set text [Read $map]
    set members [dict create]
    foreach {- archive member} [regexp -all -inline {([^\s()]+\.a)\(([^()]+)\)} $text] {
        dict set members [file normalize $archive] $member 1
    }
    set providerArchives [lmap lib {crypto ssl} {file normalize [file join $appdir native lib$lib.a]}]
    set psyms [build::ProviderSymbols $provider]
    set foreign {}
    dict for {archive set} $members {
        set n [dict size $set]
        if {$archive in $providerArchives} {
            lappend report "included from the provider's [file tail $archive]: $n members"
            continue
        }
        # A member of another archive that defines a provider symbol, locally
        # or globally, is a second implementation.
        set tmp [file tempdir]
        try {
            exec ar x --output $tmp $archive {*}[dict keys $set]
            set hits 0
            foreach m [dict keys $set] {
                set path [file join $tmp $m]
                if {![file exists $path]} {
                    continue
                }
                foreach line [split [exec nm --defined-only $path 2>/dev/null] \n] {
                    set sym [lindex $line end]
                    if {[dict exists $psyms $sym] && [lindex $line end-1] in {T t D d R r B b}} {
                        incr hits
                    }
                }
            }
        } finally {
            file delete -force $tmp
        }
        lappend report "included from [file tail $archive]: $n members, defining provider symbols: $hits"
        if {$hits > 0} {
            lappend foreign "[file tail $archive] ($hits)"
        }
    }
    if {[llength $foreign]} {
        lappend problems "other archives define provider symbols: [join $foreign {, }]"
    }
    # The executable's symbol table.
    set counts [dict create]
    foreach line [split [exec nm $exe 2>/dev/null] \n] {
        set sym [lindex $line end]
        if {[dict exists $psyms $sym] && [lindex $line end-1] ni {U w v}} {
            dict incr counts $sym
        }
    }
    set dups [dict filter $counts script {k v} {expr {$v > 1}}]
    lappend report "provider symbols in the executable: [dict size $counts] defined, [dict size $dups] of them more than once"
    if {[dict size $dups]} {
        set sample [lrange [dict keys $dups] 0 5]
        lappend report "  defined twice, e.g.: $sample"
        lappend problems "[dict size $dups] provider symbols defined more than once"
    }
    set verdict [expr {[llength $problems] ? "NOT ONE PROVIDER: [join $problems {; }]" : "ONE PROVIDER"}]
    lappend report "verdict: $verdict"
    set f [open [file join $appdir linkcheck-$program-$linker.txt] w]
    puts $f [join $report \n]
    close $f
    return [join $report \n]
}

proc linkcheck::Read {path} {
    if {![file exists $path]} {
        return ""
    }
    set f [open $path r]
    set t [read $f]
    close $f
    return $t
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    set args $::argv
    set linker rustc
    if {[set i [lsearch $args -linker]] >= 0} {
        set linker [lindex $args $i+1]
        set args [lreplace $args $i $i+1]
    }
    if {[llength $args] != 2} {
        puts stderr "usage: tclsh9.0 linkcheck.tcl APP PROGRAM ?-linker rustc|system?"
        exit 2
    }
    puts [linkcheck::Run {*}$args $linker]
}

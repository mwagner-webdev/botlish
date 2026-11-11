# pipeline.tcl -- one header profile through the preprocessor and the
# declaration parser (C-HEADER-ARCHAEOLOGY.md, "Pipeline"; C-BINDGEN.md,
# "Pipeline"): the steps the header archaeology's run.tcl and the binding
# generator share.
#
#   ::chdr::pipeline::run PROFILE SOURCEROOT CONFIG
#
#   1. writes a translation unit including the profile's entry headers,
#   2. preprocesses it with the toolchain adapter (and once more with -dD,
#      every #define kept),
#   3. parses the preprocessed C into IR records (cdecl.tcl), relocates them
#      to the library source root, notes the macros written on each
#      declaration's source lines, and lets the preprocessor expand every
#      library macro once (ExpandMacros: the compiler's expansion, never
#      ours).
#
# PROFILE is a header profile: library, source, includeDirs (relative to
# SOURCEROOT), defines, undefines, flags, public, bundled, entry. CONFIG is
# a toolchain configuration (toolchain.tcl). Nothing here writes a result
# file or decides what a record means.

namespace eval ::chdr::pipeline {}

# The pipeline's result for PROFILE: a dict
#
#   ok           0 if preprocessing failed (then stderr says why)
#   stderr       the preprocessor's diagnostics, paths sanitized
#   records      the IR records, library and system, in source order
#   macros       the macro records (every origin), expanded
#   text         the preprocessed translation unit
#   command      the preprocessing command, paths sanitized
#   profileText  the import profile record (ProfileText)
#   tokens       the token count
#   timing       {preprocess S macroPreprocess S parse S probe S}
proc ::chdr::pipeline::run {profile sourceRoot config {name ""}} {
    if {$name eq ""} { set name [dict get $profile library] }
    set abs {}
    foreach d [dict get $profile includeDirs] { lappend abs [file join $sourceRoot $d] }
    set tcProfile [dict replace $profile includeDirs $abs]
    set revision [expr {[file isdirectory [file join $sourceRoot .git]] ? [exec git -C $sourceRoot rev-parse HEAD] : "unversioned"}]

    set tmp [file tempdir]
    set entry [file join $tmp entry.c]
    set tu ""
    foreach h [dict get $profile entry] { append tu "#include <$h>\n" }
    ::chdr::writeFile $entry $tu

    lassign [::chdr::toolchain::preprocess $config $tcProfile $entry] ok text stderr ppSeconds command
    set describe [::chdr::toolchain::describe $config]
    set predefined [::chdr::toolchain::predefined $config $tcProfile]
    set result [dict create ok $ok stderr [Sanitize $stderr $sourceRoot $entry] records {} macros {} \
        text $text command [::chdr::toolchain::hide $config [Sanitize $command $sourceRoot $entry]] revision $revision tokens 0 \
        profileText [::chdr::toolchain::hide $config [ProfileText $name $profile $describe $revision $command $sourceRoot $entry $predefined]] \
        predefined [lindex $predefined 1]]
    if {!$ok} {
        file delete -force $tmp
        dict set result timing [dict create preprocess $ppSeconds]
        return $result
    }
    lassign [::chdr::toolchain::macros $config $tcProfile $entry] mok mtext mstderr mSeconds

    set origin [list ::chdr::origin $profile $sourceRoot $entry]
    set t0 [clock microseconds]
    set records [::cdecl::parse $text $origin]
    set parseSeconds [expr {([clock microseconds] - $t0) / 1e6}]
    dict set result tokens [llength $::cdecl::kinds]
    set records [Relocate $records $sourceRoot $entry]
    set records [SourceMacros $records $sourceRoot]
    set macros {}
    if {$mok} {
        set macros [Relocate [::cmacro::parse $mtext $origin] $sourceRoot $entry]
    }
    set records [AnnotateMacros $records $macros]
    set t2 [clock microseconds]
    set macros [ExpandMacros $config $tcProfile $profile $macros $tmp $sourceRoot $entry]
    set probeSeconds [expr {([clock microseconds] - $t2) / 1e6}]
    file delete -force $tmp
    dict set result records $records
    dict set result macros $macros
    dict set result timing [dict create preprocess $ppSeconds macroPreprocess $mSeconds \
        parse $parseSeconds probe $probeSeconds]
    return $result
}

# The import profile record (deterministic for profile/toolchain/revision).
proc ::chdr::pipeline::ProfileText {name profile describe revision command sourceRoot entry predefined} {
    set lines {}
    lappend lines "profile $name"
    lappend lines "description [list [dict get $profile description]]"
    lappend lines "library [dict get $profile library]"
    lappend lines "source [list [dict get $profile source]]"
    lappend lines "revision $revision"
    lappend lines "entry [list [dict get $profile entry]]"
    lappend lines "include [list [dict get $profile includeDirs]]"
    lappend lines "defines [list [dict get $profile defines]]"
    lappend lines "undefines [list [dict get $profile undefines]]"
    lappend lines "flags [list [dict get $profile flags]]"
    foreach k {cc path family version style target host} {
        lappend lines "toolchain_$k [list [dict get $describe $k]]"
    }
    set env {}
    foreach v {BOTLISH_C_CC BOTLISH_C_CPP BOTLISH_C_TARGET BOTLISH_C_INCLUDE BOTLISH_C_DEFINES BOTLISH_C_UNDEFINES BOTLISH_C_FLAGS} {
        if {[info exists ::env($v)] && $::env($v) ne ""} { lappend env $v $::env($v) }
    }
    lappend lines "environment [list $env]"
    lappend lines "command [list [Sanitize $command $sourceRoot $entry]]"
    # The predefined macros that matter to the headers we analyze.
    lassign $predefined pok ptext
    set std ""
    set facts {}
    foreach l [split $ptext \n] {
        if {[regexp {^#define (__STDC_VERSION__|__SIZEOF_[A-Z_]+__|__CHAR_UNSIGNED__|__x86_64__|__aarch64__|__linux__|_WIN32|__APPLE__|__GNUC__|__clang_major__|__USER_LABEL_PREFIX__|__PRAGMA_REDEFINE_EXTNAME|__LP64__|_LP64|__ILP32__)\s*(.*)$} $l -> k v]} {
            lappend facts "$k=$v"
        }
    }
    lappend lines "predefined_count [llength [regexp -all -inline -line {^#define} $ptext]]"
    lappend lines "predefined [list [lsort $facts]]"
    return [join $lines \n]\n
}

proc ::chdr::pipeline::Sanitize {text sourceRoot entry} {
    string map [list [file normalize $sourceRoot] {$SRC} [file dirname $entry] {$TU}] $text
}

# Make every loc relative to the library source root, the TU <entry>.
proc ::chdr::pipeline::Relocate {records sourceRoot entry} {
    set cache [dict create]
    set out {}
    foreach r $records {
        lassign $r kind name body
        set loc [dict get $body loc]
        set f [lindex $loc 0]
        if {![dict exists $cache $f]} {
            dict set cache $f [expr {[file tail $f] eq [file tail $entry] ? "<entry>" : [::chdr::relPath $sourceRoot $f]}]
        }
        lset loc 0 [dict get $cache $f]
        dict set body loc $loc
        lappend out [list $kind $name $body]
    }
    return $out
}

# Cheap co-occurrence, not expansion provenance: the identifiers written on
# the original header lines a library declaration came from (its loc line
# span), kept as `srcwords` for the macro census to match against macro
# names.
proc ::chdr::pipeline::SourceMacros {records sourceRoot} {
    set lines [dict create]
    set out {}
    foreach r $records {
        lassign $r kind name body
        if {[dict get $body origin] in {public bundled internal} && $kind ni {pragma directive}} {
            lassign [dict get $body loc] f a b
            if {![dict exists $lines $f]} {
                set path [file join $sourceRoot $f]
                dict set lines $f [expr {[file exists $path] ? [split [::chdr::readFile $path] \n] : {}}]
            }
            set words {}
            set conds {}
            foreach l [lrange [dict get $lines $f] [expr {$a - 1}] [expr {$b - 1}]] {
                regsub -all {/\*.*?\*/} $l {} l
                regsub {(//|/\*).*$} $l {} l
                if {[regexp {^\s*\*} $l]} continue
                if {[regexp {^\s*#\s*(if|ifdef|ifndef|elif|else|endif)} $l]} {
                    foreach w [regexp -all -inline {[A-Za-z_][A-Za-z0-9_]*} $l] {
                        if {$w ni {if ifdef ifndef elif else endif defined}} { lappend conds $w }
                    }
                    continue
                }
                if {[regexp {^\s*#} $l]} continue
                foreach w [regexp -all -inline {[A-Za-z_][A-Za-z0-9_]*} $l] {
                    if {$w ne $name} { lappend words $w }
                }
            }
            dict set body srcwords [lsort -unique $words]
            if {$conds ne ""} { dict set body srcconditionals [lsort -unique $conds] }
            # Documentation hints (reporting only): words of the comment
            # right above a struct definition and of the comments inside it
            # that say consumers should keep out.
            if {$kind eq "struct" && [dict get $body complete]} {
                set doc ""
                set all [dict get $lines $f]
                for {set k [expr {$a - 2}]} {$k >= 0 && $k >= $a - 16} {incr k -1} {
                    set l [lindex $all $k]
                    if {[regexp {^\s*(//|/\*|\*)} $l]} { append doc " $l" } elseif {[string trim $l] eq ""} { continue } else { break }
                }
                foreach l [lrange $all [expr {$a - 1}] [expr {$b - 1}]] {
                    if {[regexp {(//|/\*)(.*)$} $l -> _ c]} { append doc " $c" }
                }
                set hints {}
                foreach {w re} {private {\mprivate\M} opaque {\mopaque\M} internal {\minternal\M}
                        do-not {\m(do not|don't|should not|must not|shouldn't)\M} public {\mpublic\M}
                        deprecated {\mdeprecated\M}} {
                    if {[regexp -nocase $re $doc]} { lappend hints $w }
                }
                if {$hints ne ""} { dict set body dochints $hints }
            }
        }
        lappend out [list $kind $name $body]
    }
    return $out
}

# Let the preprocessor expand every library macro once, after the
# profile's headers: an object-like macro alone, a function-like one applied
# to its own parameter names (`MAX(a, b)` -> `((a) > (b) ? (a) : (b))`). Each
# probe is preceded by a marker identifier no header defines. The
# expansion is what the macro means in this profile; nothing here expands a
# macro itself.
proc ::chdr::pipeline::ExpandMacros {config tcProfile profile macros tmp sourceRoot entry} {
    set lib {}
    set calls {}
    foreach m $macros {
        lassign $m _ name b
        if {[dict get $b origin] ni {public bundled internal} || [dict get $b undefined]} continue
        set call $name
        if {[dict get $b form] eq "function"} {
            set args {}
            set n [llength [dict get $b params]]
            if {[dict get $b variadic]} { incr n }
            for {set k 0} {$k < $n} {incr k} { lappend args "__botlish_a${k}__" }
            set call "$name\([join $args {, }]\)"
        }
        lappend lib $name
        lappend calls $call
    }
    # A probe the preprocessor rejects (a macro that needs a string or a
    # number for an argument: _Pragma(#s), #if) is left out and recorded;
    # the rest is preprocessed again.
    set rejected [dict create]
    for {set round 0} {$round < 20} {incr round} {
        set probe ""
        foreach h [dict get $profile entry] { append probe "#include <$h>\n" }
        append probe "#line 1 \"botlish-macro-probe\"\n"
        set i 0
        foreach name $lib call $calls {
            if {[dict exists $rejected $name]} {
                append probe "\n"
            } else {
                append probe "__botlish_probe_${i}__ $call\n"
            }
            incr i
        }
        set path [file join $tmp probe.c]
        ::chdr::writeFile $path $probe
        lassign [::chdr::toolchain::preprocess $config $tcProfile $path] ok text stderr
        if {$ok} break
        set more 0
        foreach line [split $stderr \n] {
            if {[regexp {botlish-macro-probe:([0-9]+):[0-9]+: (?:fatal )?error: (.*)$} $line -> ln msg]} {
                set name [lindex $lib [expr {$ln - 1}]]
                if {$name ne "" && ![dict exists $rejected $name]} {
                    dict set rejected $name $msg
                    set more 1
                }
            }
        }
        if {!$more} {
            puts stderr "macro expansion probe failed: [string range $stderr 0 300]"
            return $macros
        }
    }
    set at [string first "botlish-macro-probe" $text]
    set section [string range $text $at end]
    set nl [string first \n $section]
    set section [string range $section [expr {$nl + 1}] end]
    ::cdecl::Lex $section
    set expansions [dict create]
    set current ""
    set from 0
    set n [llength $::cdecl::texts]
    for {set k 0} {$k <= $n} {incr k} {
        set t [lindex $::cdecl::texts $k]
        if {$k == $n || [regexp {^__botlish_probe_([0-9]+)__$} $t -> idx]} {
            if {$current ne ""} {
                dict set expansions [lindex $lib $current] [::cdecl::TextOf $from $k]
            }
            if {$k < $n} { set current $idx; set from [expr {$k + 1}] }
        }
    }
    set out {}
    foreach m $macros {
        lassign $m kind name b
        if {[dict exists $expansions $name] && ![dict get $b undefined]} {
            set raw [dict get $expansions $name]
            if {[dict get $b form] eq "function"} {
                # Where each argument went: standalone uses, inside a string
                # (stringified), inside a longer identifier (pasted).
                set params [dict get $b params]
                if {[dict get $b variadic]} { lappend params __VA_ARGS__ }
                set map {}
                set uses {}
                set k 0
                foreach p $params {
                    set marker "__botlish_a${k}__"
                    lappend map $marker $p
                    set standalone [llength [regexp -all -inline "(?:^|\[^A-Za-z0-9_\])${marker}(?:\[^A-Za-z0-9_\]|\$)" $raw]]
                    set strings 0
                    foreach str [regexp -all -inline {"(?:[^"\\]|\\.)*"} $raw] {
                        if {[string first $marker $str] >= 0} { incr strings }
                    }
                    set pasted [llength [regexp -all -inline "\[A-Za-z0-9_\]${marker}|${marker}\[A-Za-z0-9_\]" $raw]]
                    lappend uses [list $p $standalone $strings $pasted]
                    incr k
                }
                dict set b expansion [string map $map $raw]
                dict set b arguses $uses
            } else {
                dict set b expansion $raw
            }
        }
        if {[dict exists $rejected $name]} {
            dict set b probe [list rejected [dict get $rejected $name]]
        }
        lappend out [list $kind $name $b]
    }
    return $out
}

# Replace srcwords by srcmacros: the words that are macros of the library.
proc ::chdr::pipeline::AnnotateMacros {records macros} {
    set names [dict create]
    foreach m $macros {
        if {[dict get [lindex $m 2] origin] in {public bundled internal}} { dict set names [lindex $m 1] 1 }
    }
    set out {}
    foreach r $records {
        lassign $r kind name body
        if {[dict exists $body srcwords]} {
            set ms {}
            foreach w [dict get $body srcwords] { if {[dict exists $names $w]} { lappend ms $w } }
            set body [dict remove $body srcwords]
            if {$ms ne ""} { dict set body srcmacros $ms }
        }
        lappend out [list $kind $name $body]
    }
    return $out
}

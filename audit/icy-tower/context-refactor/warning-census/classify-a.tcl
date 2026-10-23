# classify-a.tcl -- turns partition A's scan (scan.tcl's output over
# units-a.tcl's units) into the census files: one row per site with its
# classification, one row per unit with its outcome, and the module facts
# the report (partition-a.md) quotes.
#
#   tclsh9.0 audit/icy-tower/context-refactor/warning-census/classify-a.tcl \
#       UNITS.tsv RAW.tsv... -out DIR
#
# Writes DIR/partition-a.tsv (bucket, location, from, to, rules, what,
# classification, reason: a site is a source location and its rules, once
# whatever number of units observed it), DIR/partition-a-units.tsv (every
# unit: id, set, label, target, expectation, outcome, error code and
# message, seconds, modules compiled, sites per bucket) and prints the
# summaries (totals per bucket, rule and classification; the
# contextualized modules and what they expose; the compile failures; the
# sites with the units that observed them; scan.tcl's supplementary XCALL
# lines, the C calls across a module boundary on a pointer, grouped; the
# per-directory unit listing partition-a.md quotes). VREF lines (scan.tcl's
# other supplementary measurement) are not read: partition-a.md, section 7,
# reports them.
#
# The classification is the census author's judgment, written below as
# rules: a site matches the first rule whose location pattern (a glob over
# the repository-relative location, REV: prefix included), callee or
# struct pattern (a glob over the site's WHAT) and rule pattern (a glob
# over its rules) all match. A site no rule matches stops the script: every
# site must be judged.

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here .. .. .. ..]]

# {LOCATION-GLOB WHAT-GLOB RULES-GLOB CLASS REASON}
set classification {
    {6df89a8e:examples/games/icy-tower/render.bot:* {call sdl::*} * SUSPICIOUS
     "the baseline's airlock leak: sdl is contextualized (its Sdl context mediates every raw SDL call) yet every drawing operation takes the renderer (a raw C pointer, R2) from render.bot, which keeps it alive only to hand it back; the working tree keeps the same pointers behind sdl::Sdl (no site), so they could stay behind the context"}
    {6df89a8e:examples/games/icy-tower/render.bot:* {* sdl::Video} R4 SUSPICIOUS
     "the baseline takes sdl's pointer record apart and rebuilds it in render.bot: the airlock's resource representation (window, renderer, keyboard and scratch pointers) is public; the working tree has no such struct outside sdl.bot"}
    {6df89a8e:examples/games/icy-tower/main.bot:* {call sdl::*} * SUSPICIOUS
     "the baseline's airlock hands the open session's pointers (sdl::Video, a non-opaque struct of C pointers) to the entry program, which threads them through the loop and every exit to call sdl::close; the working tree's open/close/poll take and return no pointer"}
    {6df89a8e:examples/games/icy-tower/main.bot:* {* sdl::Polled} R4 SUSPICIOUS
     "the baseline's poll result carries the Video back and the entry program destructures it: sdl's pointer record handled outside the airlock; gone in the working tree"}
    {6df89a8e:examples/games/icy-tower/main.bot:* {call render::draw} * LEGITIMATE
     "not an airlock boundary: render declares no context and makes no direct call, so it has no authority to keep the pointers behind; it forwards sdl's Video (the leak is sdl's, reported at sdl's boundary) and the site disappears with it in the working tree"}
    {6df89a8e:examples/games/icy-tower/main.bot:* {* render::Drawn} R4 LEGITIMATE
     "not an airlock boundary: render::Drawn is ordinary render.bot's result struct handing sdl's Video back to the loop; a consequence of sdl's leak, which is reported at sdl's boundary"}
    {stdlib/windows/io.bot:* {call std::windows::*} * LEGITIMATE
     "std::windows is the thin Win32 layer, ordinary and context-free (GetStdHandle and WriteFile's handle are non-retaining): no airlock. The handle is a borrowed standard handle that std::windows::io fetches and passes back within one call (write_some) and never stores (AGENTS.md, Windows I/O: a C pointer cannot live in a context); std::windows::io, the context's owner, is itself ordinary because nothing it calls is direct"}
    {audit/icy-tower/context-refactor/repro/g1-view-leak/main.bot:* {call airlock::record} R3 SUSPICIOUS
     "the targeted shape, written on purpose (reproducer g1): contextualized airlock returns the unrestricted view of its native record, and the ordinary entry program reads the C string pointer out of it and hands it to strlen with no diagnostic and no directness; the airlock could read the record inline behind its context, as the working tree's sdl.bot does"}
    {audit/icy-tower/context-refactor/variants/opaque-values/*:* {call sdl::*} R1 LEGITIMATE
     "intended ownership transfer (Design A, variants/opaque-values/NOTES.md): sdl::Video is an opaque affine resource value that open returns, poll/show take and hand back and close consumes; R2 and R3 do not fire (the representation is sealed: OPAQUE-REPRESENTATION outside sdl.bot), and the transfer is what buys Design A its static use-after-close and double-close errors (USE-AFTER-MOVE), which the context-retained design gives up (census section 7)"}
    {audit/icy-tower/context-refactor/variants/opaque-values/*:* {destructure sdl::*} R4 LEGITIMATE
     "the hand-back carrier Design A's affine value forces (no observing parameter: an operation that takes the Video must return it): the struct is sdl's, but its one pointer-holding field is the opaque Video, so no pointer representation is taken apart outside sdl.bot; R4 follows C addresses through opaque structs (its carry search), unlike R2"}
    {audit/icy-tower/context-refactor/variants/opaque-values/main.bot:* {call render::draw} R1 LEGITIMATE
     "not an airlock boundary: render declares no context and makes no direct call; it forwards Design A's opaque sdl::Video, an intended ownership transfer (see the sdl sites)"}
    {audit/icy-tower/context-refactor/variants/opaque-values/main.bot:* {destructure render::Drawn} R4 LEGITIMATE
     "not an airlock boundary: render::Drawn is ordinary render.bot's carrier handing Design A's opaque Video back to the loop; no representation exposed"}
    {examples/ffi/tcl/demo.bot:* {call tcl::eval} * LEGITIMATE
     "tcl.bot is a hand-written thin binding with no context and no direct edge (Tcl_EvalEx's interp is noescape): no airlock; the program owns the interpreter pointer by design (it creates and deletes it) and lends a clone to the wrapper"}
}

proc ReadLines {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set lines [split [string trimright [read $f] \n] \n]
    close $f
    return $lines
}

set outDir ""
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    if {$a eq "-out"} {
        set outDir [lindex $argv [incr i]]
    } else {
        lappend files $a
    }
}
set unitsFile [lindex $files 0]
set rawFiles [lrange $files 1 end]

set units [dict create]
set order {}
foreach line [ReadLines $unitsFile] {
    lassign [split $line \t] id set label entry target expect map
    dict set units $id [dict create set $set label $label entry $entry target $target expect $expect \
        outcome missing code "" message "" seconds "" modules {} sites {}]
    lappend order $id
}
set sites [dict create]
set xcalls [dict create]
set siteOrder {}
set mods {}
foreach raw $rawFiles {
    foreach line [ReadLines $raw] {
        set fields [split $line \t]
        switch -- [lindex $fields 0] {
            UNIT {
                lassign $fields - id outcome seconds code message
                dict set units $id outcome $outcome
                dict set units $id seconds $seconds
                dict set units $id code $code
                dict set units $id message $message
            }
            SITE {
                lassign $fields - id bucket location from to rules what
                dict set units $id sites [linsert [dict get $units $id sites] end [list $bucket $location $rules]]
                set key [list $location $rules]
                if {![dict exists $sites $key]} {
                    dict set sites $key [dict create bucket $bucket from $from to $to rules $rules what $what units {}]
                    lappend siteOrder $key
                }
                dict set sites $key units [linsert [dict get $sites $key units] end $id]
            }
            MOD {
                lassign $fields - id ns status file contexts functions ptrFns viewFns ptrStructs viewStructs externs ptrExterns
                dict set units $id modules [linsert [dict get $units $id modules] end $ns]
                lappend mods [list $id $ns $status $file $contexts $functions $ptrFns $viewFns $ptrStructs $viewStructs $externs $ptrExterns]
            }
            XCALL {
                lassign $fields - id ustatus location from to kinds callee
                if {![dict exists $xcalls $location]} {
                    dict set xcalls $location [list $ustatus $from $to $kinds $callee]
                }
            }
        }
    }
}

# Classify.
set rows {}
set totals [dict create]
foreach key $siteOrder {
    set s [dict get $sites $key]
    lassign $key location rules
    set what [dict get $s what]
    set class ""
    foreach rule $classification {
        lassign $rule lglob wglob rglob c reason
        if {[string match $lglob $location] && [string match $wglob $what] && [string match $rglob $rules]} {
            set class $c
            break
        }
    }
    if {$class eq ""} {
        puts stderr "UNCLASSIFIED: [dict get $s bucket] $location [dict get $s from] -> [dict get $s to] $rules $what (units [dict get $s units])"
        continue
    }
    set bucket [dict get $s bucket]
    lappend rows [list $bucket $location [dict get $s from] [dict get $s to] $rules $what $class $reason]
    dict incr totals "sites $bucket"
    dict incr totals "class $class"
    dict incr totals "class $bucket $class"
    foreach r [split $rules ,] {
        dict incr totals "rule $bucket $r"
        dict incr totals "rule $r"
        dict incr totals "rule $r $class"
    }
}
if {[llength $rows] != [llength $siteOrder]} {
    puts stderr "[expr {[llength $siteOrder] - [llength $rows]}] sites unclassified"
    exit 1
}

if {$outDir ne ""} {
    set f [open [file join $outDir partition-a.tsv] w]
    fconfigure $f -encoding utf-8 -translation lf
    puts $f [join {bucket location from to rules what classification reason} \t]
    foreach row $rows { puts $f [join $row \t] }
    close $f
    set f [open [file join $outDir partition-a-units.tsv] w]
    fconfigure $f -encoding utf-8 -translation lf
    puts $f [join {id set label target expect outcome errorcode message seconds modules hit context-but-ordinary no-context designated-direct} \t]
    foreach id $order {
        set u [dict get $units $id]
        set counts [dict create hit 0 context-but-ordinary 0 no-context 0 designated-direct 0]
        foreach site [dict get $u sites] { dict incr counts [lindex $site 0] }
        # The module count leaves out the entry program.
        set modules [expr {[llength [dict get $u modules]] ? [llength [dict get $u modules]] - 1 : 0}]
        puts $f [join [list $id [dict get $u set] [dict get $u label] [dict get $u target] [dict get $u expect] \
            [dict get $u outcome] [regsub { \{.*$} [dict get $u code] ""] [string map [list $root/ ""] [dict get $u message]] [dict get $u seconds] $modules \
            {*}[dict values $counts]] \t]
    }
    close $f
}

# Summaries.
puts "== units per set and outcome"
set per [dict create]
foreach id $order {
    set u [dict get $units $id]
    set e [expr {[string match invalid:* [dict get $u expect]] ? "invalid" : "ok"}]
    dict incr per "[dict get $u set] expect=$e outcome=[dict get $u outcome]"
}
dict for {k v} $per { puts "  $k: $v" }
puts "== compile failures and expectation mismatches"
foreach id $order {
    set u [dict get $units $id]
    set invalid [string match invalid:* [dict get $u expect]]
    if {[dict get $u outcome] ne "ok" || $invalid} {
        puts "  $id [dict get $u label] target=[dict get $u target] expect=[dict get $u expect] outcome=[dict get $u outcome] ([dict get $u code]) [dict get $u message]"
    }
}
puts "== totals"
foreach k [lsort [dict keys $totals]] { puts "  $k: [dict get $totals $k]" }
puts "== sites (with observing units)"
foreach key $siteOrder {
    set s [dict get $sites $key]
    puts "  [dict get $s bucket] $key [dict get $s from] -> [dict get $s to] [dict get $s what]: [dict get $s units]"
}
puts "== modules by status (distinct files; units observing)"
set byFile [dict create]
foreach m $mods {
    lassign $m id ns status file contexts functions ptrFns viewFns ptrStructs viewStructs externs ptrExterns
    if {$ns eq "entry" && $status eq "ordinary"} continue
    set key [list $status $ns $file]
    if {![dict exists $byFile $key]} {
        dict set byFile $key [dict create facts [lrange $m 4 end] units {}]
    }
    dict set byFile $key units [linsert [dict get $byFile $key units] end $id]
}
foreach key [lsort [dict keys $byFile]] {
    lassign $key status ns file
    if {$status eq "ordinary"} continue
    set info [dict get $byFile $key]
    lassign [dict get $info facts] contexts functions ptrFns viewFns ptrStructs viewStructs externs ptrExterns
    puts "  $status $ns $file contexts={$contexts} functions=$functions ptrFns={$ptrFns} viewFns={$viewFns} ptrStructs={$ptrStructs} viewStructs={$viewStructs} externs=$externs ptrExterns=$ptrExterns units=[llength [dict get $info units]]"
}
puts "== ordinary modules exposing C pointers or views (distinct files)"
foreach key [lsort [dict keys $byFile]] {
    lassign $key status ns file
    if {$status ne "ordinary"} continue
    set info [dict get $byFile $key]
    lassign [dict get $info facts] contexts functions ptrFns viewFns ptrStructs viewStructs externs ptrExterns
    if {$ptrFns eq "" && $viewFns eq "" && $ptrStructs eq "" && $viewStructs eq ""} continue
    puts "  $ns $file contexts={$contexts} functions=$functions ptrFns={$ptrFns} viewFns={$viewFns} ptrStructs={$ptrStructs} viewStructs={$viewStructs} externs=$externs ptrExterns=$ptrExterns"
}
puts "== distinct module files compiled: [llength [lsort -unique [lmap k [dict keys $byFile] {lindex $k 2}]]]"
puts "== cross-module C calls on a pointer (scan.tcl's XCALL; outside the instrument's rules): [dict size $xcalls] distinct locations"
set pairs [dict create]
set contextual [dict create]
foreach {status ns file} [concat {*}[dict keys $byFile]] {
    set info [dict get $byFile [list $status $ns $file]]
    if {$status ne "ordinary" || [lindex [dict get $info facts] 0] ne ""} { dict set contextual $ns $status }
}
dict for {location x} $xcalls {
    lassign $x ustatus from to kinds callee
    set file [lindex [split $location :] 0]
    if {[string match 6df89a8e:* $location]} { set file [join [lrange [split $location :] 0 1] :] }
    dict incr pairs "$ustatus $from -> [expr {[string match sdl3::* $to] ? "sdl3::*" : $to}] ($file) $kinds"
    if {[dict exists $contextual $to]} { puts "  INTO A CONTEXT-DECLARING OR NON-ORDINARY MODULE: $location $from -> $to $callee" }
}
dict for {k n} $pairs { puts "  $n  $k" }
puts "== units per directory (markdown)"
set byDir [dict create]
foreach id $order {
    set u [dict get $units $id]
    set label [dict get $u label]
    regexp {^(\S+)} $label -> path
    set dir [file dirname $path]
    set name [string range $label [string length $dir/] end]
    if {[dict get $u set] eq "generated"} {
        regexp {^(generated/c/[^/]+/[^/]+)/} $path -> dir
        set name [file rootname [string range $path [string length $dir/] end]]
    }
    if {[dict get $u outcome] ne "ok"} { append name " (REJECTED)" }
    dict lappend byDir "[dict get $u set]|$dir" $name
}
dict for {key names} $byDir {
    lassign [split $key |] set dir
    puts "* `$dir/` ($set, [llength $names]): [join $names {, }]"
}

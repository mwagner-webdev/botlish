# census.tcl -- the before/after counts of ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md:
# how much SDL authority, affine C-pointer plumbing and resource-lifetime
# ceremony an Icy Tower application tree shows, measured the same way for
# every tree.
#
#   tclsh9.0 audit/icy-tower/context-refactor/tools/census.tcl APP_DIR ?-json 0|1?
#   tclsh9.0 audit/icy-tower/context-refactor/tools/census.tcl -rev REV ?-json 0|1?
#
# APP_DIR holds the game's .bot files (examples/games/icy-tower/ or a
# variant's directory); -rev REV reads examples/games/icy-tower/ at a git
# revision instead (HEAD~1, a commit). The tree is staged with the committed
# generated SDL3 binding (tools/c-bindgen.tcl stage) in a private temporary
# directory, its main.bot compiled by the front end (no backend runs), and
# every measure is read from the HIR -- types, call targets, origins --
# except the two that are spelling (`.clone()` and the modules whose text
# names a C pointer type). Only the game's own files count (the binding's
# and the standard library's are below the airlock by definition); a site
# is a source location, so a function the trait plan clones is counted once.
#
# "Pointer-carrying" is hir::types::IsAffine: the game has no affine root
# but C addresses (no coroutine), so an affine type is exactly a type that
# holds a C pointer, directly or through struct fields and Lists.

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here .. .. .. ..]]
source [file join $root surface surface.tcl]

set options [dict create -json 0 -rev ""]
set app ""
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    if {[string match -* $a]} {
        dict set options $a [lindex $argv [incr i]]
    } else {
        set app [file normalize $a]
    }
}

set tmp [file tempdir]
try {
    if {[dict get $options -rev] ne ""} {
        set app [file join $tmp source]
        file mkdir $app
        set rev [dict get $options -rev]
        foreach f [split [exec git -C $root ls-tree --name-only $rev examples/games/icy-tower/] \n] {
            if {![string match *.bot $f]} continue
            set channel [open [file join $app [file tail $f]] w]
            fconfigure $channel -translation binary
            puts -nonewline $channel [exec git -C $root show $rev:$f]
            close $channel
        }
    }
    set stage [file normalize [file join $tmp app]]
    exec [info nameofexecutable] [file join $root tools c-bindgen.tcl] stage sdl3 -target linux-x86_64 -app $app -into $stage
    set hir [surface::readProgramFile [file join $stage main.bot] -warnings off -target linux-x86_64 -cache ""]

    # The game's modules: the .bot files of the application (its programs
    # golden.bot and headless.bot are not part of main.bot's program).
    set game {}
    foreach f [lsort [glob -directory $app *.bot]] {
        set name [file rootname [file tail $f]]
        if {$name in {golden headless}} continue
        lappend game $name
    }

    # The game module of expression E and its line and column, "" outside
    # the game: a file of the stage's root, never of a subdirectory (the
    # staged binding has a render.bot of its own, sdl3/render.bot).
    proc ModuleOf {hir e} {
        set origin [dict get $hir exprs $e origin]
        if {[lindex $origin 0] ne "file"} { return "" }
        set location [hir::originLocation $hir $origin]
        if {![regexp {^(.*):(\d+):(\d+)$} $location -> path line column]} { return "" }
        if {[file normalize [file dirname $path]] ne $::stage} { return "" }
        return [list [file rootname [file tail $path]] $line $column]
    }

    # The block a call targets, "" if none (a native, an indirect call).
    proc CalleeBlock {hir e} {
        set callee [dict get $hir exprs [dict get $hir exprs $e callee]]
        if {[dict get $callee kind] ne "ref" || [dict get $callee binding] eq ""} { return "" }
        set binding [dict get $hir bindings [dict get $callee binding]]
        set by [dict get $binding declaredBy]
        if {$by eq "" || ![dict exists $hir exprs $by value]} { return "" }
        set value [dict get $hir exprs $by value]
        if {[dict get $hir exprs $value kind] ne "block"} { return "" }
        return $value
    }

    proc Carrying {type} {
        if {$type eq "" || $type eq "any"} { return 0 }
        return [hir::types::IsAffine $type]
    }

    set counts [dict create]
    proc Count {key module {site ""}} {
        upvar 1 counts counts seen seen
        if {$site ne ""} {
            if {[dict exists $seen $key $site]} return
            dict set seen $key $site 1
        }
        dict incr counts "$key $module"
    }
    set seen [dict create]
    set lists [dict create]

    dict for {e node} [dict get $hir exprs] {
        set where [ModuleOf $hir $e]
        if {$where eq ""} continue
        lassign $where module line column
        if {$module ni $game} continue
        set site "$module:$line:$column"
        switch -- [dict get $node kind] {
            block {
                # A function: its declared or trusted parameter types and its
                # result. (A nested function is a function too.)
                set name [hir::semantic::CallableName $hir $e]
                if {$name eq ""} continue
                set signature [hir::signatures::of $hir $e]
                set types [lmap p [dict get $signature params] {
                    expr {[dict get $p declared] ne "" ? [dict get $p declared] : [dict get $p trusted]}
                }]
                set carrying 0
                foreach t [concat $types [list [dict get $signature result]]] {
                    if {[Carrying $t]} { set carrying 1 }
                }
                Count functions $module $site
                if {$carrying} {
                    Count pointer-functions $module $site
                    if {![dict exists $lists pointer-functions $site]} {
                        dict set lists pointer-functions $site $name
                    }
                }
                if {[dict exists $node requiredContexts] && "sdl::Sdl" in [dict get $node requiredContexts]} {
                    Count sdl-requiring-functions $module $site
                }
                if {[dict exists $node directContexts] && "sdl::Sdl" in [dict get $node directContexts]} {
                    Count sdl-context-parameters $module $site
                }
            }
            call {
                set native [hir::affine::NativeName $hir $e]
                if {[string match extern#* $native]} {
                    set key [string range $native 7 end]
                    Count [expr {[string match sdl3::* $key] ? "sdl-c-calls" : "other-c-calls"}] $module $site
                    if {[string match sdl3::* $key]} {
                        dict set lists sdl-c-call-names $module $key 1
                    }
                }
                if {$native in {std::binary::native::view std::binary::native::edit}} {
                    Count native-view-edit $module $site
                }
                if {$native eq "std::ffi::c::clone"} {
                    Count pointer-clones-hir $module $site
                }
                set target [CalleeBlock $hir $e]
                if {$target eq ""} continue
                set callee [ModuleOf $hir $target]
                if {$callee eq ""} continue
                set calleeModule [lindex $callee 0]
                if {$calleeModule ni $game || $calleeModule eq $module} continue
                set carrying [Carrying [hir::typeOf $hir $e]]
                foreach a [dict get $node args] {
                    if {[Carrying [hir::typeOf $hir $a]]} { set carrying 1 }
                }
                Count cross-module-calls $module $site
                if {$carrying} {
                    Count pointer-crossing-calls $module $site
                    dict set lists crossing "$module -> [hir::semantic::CallableName $hir $target]" 1
                }
            }
            struct {
                if {[Carrying [hir::typeOf $hir $e]]} {
                    Count pointer-struct-constructions $module $site
                }
            }
            bind {
                set b [dict get $node binding]
                if {[string match destructure#* [dict get $hir bindings $b name]]
                        && [Carrying [hir::typeOf $hir [dict get $node value]]]} {
                    Count pointer-destructurings $module $site
                }
            }
        }
    }

    # Pointer-carrying struct types each game module declares, and the
    # modules whose signatures mention one.
    foreach entry [hir::sourceTypes $hir] {
        if {![dict exists $entry kind] || [dict get $entry kind] ne "struct"} continue
        set id [dict get $entry id]
        set ns [lindex [split [string map {:: \x00} $id] \x00] 0]
        set module [expr {[string first :: $id] >= 0 ? $ns : "main"}]
        if {$module ni $game} continue
        if {[Carrying [list nstruct $id]]} {
            dict incr counts "pointer-struct-types $module"
            dict set lists pointer-struct-types $id 1
        }
    }

    # Spelling: `.clone()` (every clone in the game is of a C pointer) and the
    # modules whose text names a C pointer type or imports the raw binding.
    foreach module $game {
        set text [core::ReadFile [file join $app $module.bot]]
        set code [join [lmap l [split $text \n] {regsub {#.*$} $l ""}] \n]
        set clones [regexp -all {\.clone\(\)|std::ffi::c::clone\(} $code]
        if {$clones} { dict set counts "pointer-clones $module" $clones }
        if {[regexp {std::ffi::c::(Ptr|FnPtr)\[|sdl3::ctypes::} $code]} {
            dict set counts "names-c-pointer-types $module" 1
        }
        set imports [regexp -all -line {^import sdl3::} $code]
        if {$imports} { dict set counts "raw-binding-imports $module" $imports }
    }

    set statuses {}
    foreach line [split [hir::direct::summary $hir] \n] {
        if {[regexp {^module (\S+): (\S+)} $line -> m status] && $m in $game} {
            lappend statuses $m $status
        } elseif {[regexp {^entry program: (\S+)} $line -> status]} {
            lappend statuses main $status
        }
    }

    set measures {functions pointer-functions pointer-struct-types pointer-clones pointer-clones-hir
        pointer-destructurings pointer-struct-constructions cross-module-calls pointer-crossing-calls
        sdl-c-calls other-c-calls native-view-edit names-c-pointer-types raw-binding-imports
        sdl-context-parameters sdl-requiring-functions}
    if {[dict get $options -json]} {
        set out {}
        foreach m $measures {
            set row {}
            foreach module $game {
                lappend row "\"$module\": [dict getdef $counts "$m $module" 0]"
            }
            lappend out "  \"$m\": {[join $row {, }]}"
        }
        puts "{\n[join $out ,\n]\n}"
    } else {
        puts [format "%-30s %s" measure [join [lmap m $game {format %8s $m}] ""]]
        foreach m $measures {
            set row [format "%-30s" $m]
            set total 0
            foreach module $game {
                set n [dict getdef $counts "$m $module" 0]
                incr total $n
                append row [format %8d $n]
            }
            puts "$row   total $total"
        }
        puts ""
        puts "direct status: $statuses"
        foreach key {pointer-struct-types crossing} {
            if {[dict exists $lists $key]} {
                puts "$key:"
                foreach item [lsort [dict keys [dict get $lists $key]]] { puts "    $item" }
            }
        }
        if {[dict exists $lists pointer-functions]} {
            puts "pointer-functions:"
            foreach site [lsort -dictionary [dict keys [dict get $lists pointer-functions]]] {
                puts "    [dict get $lists pointer-functions $site]  ($site)"
            }
        }
        if {[dict exists $lists sdl-c-call-names]} {
            dict for {module names} [dict get $lists sdl-c-call-names] {
                puts "SDL functions called from $module: [lsort [dict keys $names]]"
            }
        }
    }
} finally {
    file delete -force $tmp
}

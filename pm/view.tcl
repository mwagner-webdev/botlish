# view.tcl -- target views (PACKAGE-MANAGER-MILESTONE-2.md, "Target views").
#
#   pm::view::Root CTX                 PROJECT/.bot_modules/.targets
#   pm::view::Dir CTX TARGET           the view of TARGET
#   pm::view::Aware STATE SOURCES      1 if an installed instance is
#                                      target-aware
#   pm::view::Derived TARGET STATE ORIGINS MANUAL   what a view is derived from
#   pm::view::Build CTX STATE SOURCES TARGET ORIGINS DEST   stage a view
#   pm::view::Instances DIR            a view's instances, read back
#
# A project's packages are installed once, as their artifacts are, in
# PROJECT/.bot_modules/NAME (the store: PM-1's tree, its record, its
# verification). When any installed instance is target-aware (its
# botlish.json has `targets`), the compiler cannot read the store: a
# package's target files are under its target directories, not at the
# module paths its imports name. For each target the project is prepared
# for, the manager then derives a *view*: an ordinary package tree of every
# instance -- its common files, and its target files at the paths they
# have for that target -- at PROJECT/.bot_modules/.targets/TARGET, with
# the target's bundled native libraries under the view's .lib directory.
# The compiler reads the view of the target it compiles for
# (BOT-MODULES-MILESTONE-1.md, "Target package trees"): it knows the
# directory's name and nothing of how it was made.
#
# A view is a pure function of the store's record, the target, the
# consumer's origins choices and the manual packages it links (Derived), so
# a view whose recorded digest is the one its inputs give now, and whose
# files are unchanged, is reused as it is; any change to the store makes
# every view of the project derived again, in the same transaction as the
# change. Views of different targets are different directories: preparing
# one never touches another.
#
# What a view holds, for each top-level package NAME:
#
#   artifact     NAME/... -- the instance's files mapped for the target
#                (pm/targets.tcl's Map), its dependencies under its own
#                .bot_modules, recursively;
#   editable     NAME -> the editable directory (a link: never copied);
#   manual       NAME -> PROJECT/.bot_modules/NAME (a link to the package
#                installed by hand, which stays the user's)
#
# and .lib/ the bundled libraries the native plan selected
# (pm/native.tcl's Plan: `placed`), each under the name a linker searches
# for and its loader identity.

namespace eval pm::view {
    variable format 1
}

proc pm::view::Root {ctx} {
    return [file join [dict get $ctx modules] .targets]
}

proc pm::view::Dir {ctx target} {
    return [file join [Root $ctx] $target]
}

# The descriptor of the installed artifact tree DIR (its botlish.json, as an
# artifact's).
proc pm::view::Descriptor {dir} {
    return [pm::descriptor::read [file join $dir botlish.json] artifact]
}

# 1 if any artifact instance of the record STATE, installed at SOURCES
# (NAME -> its directory, staged or active), is target-aware.
proc pm::view::Aware {state sources} {
    dict for {name record} $state {
        if {[dict get $record kind] ne "artifact"} continue
        if {[NodeAware [dict get $sources $name] $record]} {
            return 1
        }
    }
    return 0
}

proc pm::view::NodeAware {dir record} {
    if {[pm::targets::Aware [Descriptor $dir]]} {
        return 1
    }
    dict for {child childRecord} [dict get $record children] {
        if {[NodeAware [file join $dir .bot_modules $child] $childRecord]} {
            return 1
        }
    }
    return 0
}

# The targets every artifact instance of STATE (at SOURCES) supports: a
# list, or * when every instance is target-independent.
proc pm::view::Supported {state sources} {
    set supported *
    dict for {name record} $state {
        if {[dict get $record kind] ne "artifact"} continue
        set supported [Intersect $supported [NodeSupported [dict get $sources $name] $record]]
    }
    return $supported
}

proc pm::view::NodeSupported {dir record} {
    set supported [pm::targets::Supported [Descriptor $dir]]
    dict for {child childRecord} [dict get $record children] {
        set supported [Intersect $supported [NodeSupported [file join $dir .bot_modules $child] $childRecord]]
    }
    return $supported
}

proc pm::view::Intersect {a b} {
    if {$a eq "*"} { return $b }
    if {$b eq "*"} { return $a }
    return [lmap x $a {if {$x ni $b} continue; set x}]
}

# The digest of what the view of TARGET is derived from: the record of the
# packages STATE, the origins choices ORIGINS and the manual packages MANUAL
# (NAME -> DIRECTORY) it links.
proc pm::view::Derived {target state origins manual} {
    variable format
    set text "botlish target view $format\ntarget $target\n"
    append text "origins [lsort -stride 2 $origins]\nmanual [lsort -stride 2 $manual]\n"
    append text [pm::state::encode $state]
    return [pm::sha256::hex [encoding convertto utf-8 $text]]
}

# The manual packages of CTX: top-level entries of .bot_modules that are
# neither the record's (STATE) nor the manager's own, NAME -> directory.
proc pm::view::Manual {ctx state} {
    set manual [dict create]
    set modules [dict get $ctx modules]
    if {![file isdirectory $modules]} {
        return $manual
    }
    foreach name [pm::state::Entries $modules] {
        if {[string index $name 0] eq "." || [dict exists $state $name]} continue
        if {[pm::descriptor::NameProblem $name] ne ""} continue
        dict set manual $name [file normalize [file join $modules $name]]
    }
    return $manual
}

# Stages the view of TARGET at DEST (which does not exist), from the
# packages STATE installed at SOURCES (NAME -> directory: staged or active)
# with the consumer's ORIGINS and the MANUAL packages; its record {derived D
# files F links L} and the native plan. A package that does not support
# TARGET, a native problem or a collision is {PM ...}: nothing of DEST is
# then left for the caller to keep.
proc pm::view::Build {ctx state sources target origins manual dest} {
    set files [dict create]
    set links [dict create]
    set instances {}
    file mkdir $dest
    foreach name [lsort [dict keys $state]] {
        set record [dict get $state $name]
        if {[dict get $record kind] eq "editable"} {
            set link [file normalize [pm::ProjectPath [dict get $ctx project] [dict get $record directory]]]
            file link -symbolic [file join $dest $name] $link
            dict set links $name $link
            continue
        }
        Project [dict get $sources $name] $record $dest $name $name $target [list $name [dict get $record version]] files instances
    }
    dict for {name dir} $manual {
        file link -symbolic [file join $dest $name] $dir
        dict set links $name $dir
    }
    pm::Fault project
    set plan [pm::native::Plan $target $instances $origins]
    if {[dict get $plan problems] ne ""} {
        pm::Fail NATIVE "the native dependencies of the packages for $target:\n  [join [dict get $plan problems] "\n  "]"
    }
    foreach placed [dict get $plan placed] {
        set lib [file join $dest .lib]
        file mkdir $lib
        set bytes [pm::ReadBytes [dict get $placed source]]
        pm::WriteNew [file join $lib [dict get $placed file]] $bytes
        dict set files .lib/[dict get $placed file] [list [string length $bytes] [format %08x [expr {[zlib crc32 $bytes] & 0xffffffff}]]]
    }
    pm::Fault native-placed
    return [dict create record [dict create derived [Derived $target $state $origins $manual] files $files links $links] plan $plan]
}

# Writes the instance installed at SOURCE (record RECORD) into the view at
# VIEW/RELATIVE for TARGET; INSTANCE its identity (a/b), CHAIN its
# dependency path (NAME VERSION ...) for messages.
proc pm::view::Project {source record view relative instance target chain filesVar instancesVar} {
    upvar 1 $filesVar files $instancesVar instances
    set descriptor [Descriptor $source]
    set supported [pm::targets::Supported $descriptor]
    if {$supported ne "*" && $target ni $supported} {
        pm::Fail UNSUPPORTED "[pm::catalog::Chain $chain]: [dict get $descriptor name] [dict get $descriptor version] supports [join $supported {, }], not $target: its package has no bindings or native files for $target (the package's own metadata says so; nothing is assumed portable)"
    }
    set paths [lsort [dict keys [dict get $record files]]]
    if {[pm::targets::Aware $descriptor]} {
        pm::targets::CheckFiles $descriptor $paths "[dict get $descriptor name] [dict get $descriptor version] (instance $instance)"
    }
    set dest [file join $view {*}[split $relative /]]
    file mkdir $dest
    set links {}
    foreach {viewPath path} [pm::targets::Map $descriptor $target $paths] {
        set bytes [pm::ReadBytes [file join $source {*}[split $path /]]]
        set target_ [file join $dest {*}[split $viewPath /]]
        file mkdir [file dirname $target_]
        pm::WriteNew $target_ $bytes
        dict set files $relative/$viewPath [dict get $record files $path]
        if {[string match *.bot $viewPath]} {
            foreach declaration [pm::native::SourceLinks [encoding convertfrom utf-8 $bytes]] {
                dict set declaration file $relative/$viewPath
                lappend links $declaration
            }
        }
    }
    lappend instances [dict create instance $instance name [dict get $descriptor name] \
        version [dict get $descriptor version] descriptor $descriptor dir $dest links $links]
    dict for {child childRecord} [dict get $record children] {
        Project [file join $source .bot_modules $child] $childRecord $view $relative/.bot_modules/$child \
            $instance/$child $target [concat $chain [list $child [dict get $childRecord version]]] files instances
    }
}

# The instances of the view directory VIEW, read back for a plan
# (`native plan`, `verify -target`): its artifact packages' descriptors,
# directories and link declarations, in tree order. Links (editable and
# manual packages) are followed for their descriptors when they have
# target metadata.
proc pm::view::Instances {view} {
    set instances {}
    foreach name [pm::state::Entries $view] {
        if {[string index $name 0] eq "."} continue
        ReadInstance [file join $view $name] $name $name instances
    }
    return $instances
}

proc pm::view::ReadInstance {dir relative instance instancesVar} {
    upvar 1 $instancesVar instances
    if {![file isfile [file join $dir botlish.json]]} {
        return
    }
    if {[catch {pm::descriptor::read [file join $dir botlish.json] artifact} descriptor]} {
        if {[catch {pm::descriptor::read [file join $dir botlish.json] project} descriptor]} {
            return
        }
    }
    set links {}
    foreach path [BotFiles $dir ""] {
        foreach declaration [pm::native::SourceLinks [encoding convertfrom utf-8 [pm::ReadBytes [file join $dir {*}[split $path /]]]]] {
            dict set declaration file $relative/$path
            lappend links $declaration
        }
    }
    lappend instances [dict create instance $instance name [dict get $descriptor name] \
        version [dict get $descriptor version] descriptor $descriptor dir $dir links $links]
    set modules [file join $dir .bot_modules]
    if {[file isdirectory $modules]} {
        foreach child [pm::state::Entries $modules] {
            if {[string index $child 0] eq "."} continue
            ReadInstance [file join $modules $child] $relative/.bot_modules/$child $instance/$child instances
        }
    }
}

proc pm::view::BotFiles {dir relative} {
    set out {}
    set here [file join $dir {*}[split $relative /]]
    foreach name [pm::state::Entries $here] {
        if {[string index $name 0] eq "."} continue
        set path [expr {$relative eq "" ? $name : "$relative/$name"}]
        set full [file join $here $name]
        if {[file type $full] eq "directory"} {
            lappend out {*}[BotFiles $dir $path]
        } elseif {[file type $full] eq "file" && [string match *.bot $name]} {
            lappend out $path
        }
    }
    return $out
}

# commands.tcl -- the package manager's commands and command line
# (PACKAGE-MANAGER-MILESTONE-1.md, "Commands").
#
#   botlish add SPEC [-request R] [-replace]     SPEC: NAME (from a repository),
#                                                FILE.botpkg (an archive source),
#                                                or DIR (an editable directory:
#                                                a path with a "/")
#   botlish install
#   botlish update [NAME...]
#   botlish remove NAME...
#   botlish verify
#   botlish package pack [DIR] [-out DIR] [-force] [-evidence FILE.json]
#   botlish package inspect FILE.botpkg [-target T] [-provenance FILE.json]
#   botlish package stage [DIR] -target T... -modules|-headers|-files SRC [-as PATH] [-replace]
#   botlish package compare A.botpkg B.botpkg [-provenance A.json -provenance B.json]
#   botlish native inspect FILE [-target T]       what a native file is
#   botlish native plan [-target T]               the project's native plan
#   botlish native deploy -target T -out DIR      its shared libraries, placed
#   botlish native add FILE -target T -name N     import a built native library
#   botlish native require NAME -target T (-origin system | -runtime WHEN -purpose TEXT)
#   botlish native audit [DIR] [-target T]        a package's native closure
#
# (PACKAGE-MANAGER-MILESTONE-3.md: the author's commands -- native add,
# require and audit, package stage, compare and pack's -evidence -- take the
# package directory as -package DIR or DIR, default the current directory.)
#
# add, install, update and remove take -target T (prepare the target view
# of T: any number) and -drop-target T (remove that view); verify takes
# -target T (check that view too) (PACKAGE-MANAGER-MILESTONE-2.md).
#
# with, for add, install, update, remove and verify, -project DIR (the
# project: default the current directory), -repository DIR (a local
# repository; any number), and for the first four -force (replace installed
# packages that changed since they were installed) and -recover (roll back
# an interrupted operation whose process this host cannot check).
# ("botlish" is the single-file compiler; in a checkout it is tclsh9.0
# main.tcl.)
#
# Exit status: 0 success, 1 a failed operation (its error on stderr as
# "error: MESSAGE (PM KIND)"; verify: any problem found), 2 a usage error.

namespace eval pm::cli {
    variable invocation botlish
    # Each command's options: NAME ARGUMENT ("" for a flag).
    variable options {
        add {-request R -replace {} -project DIR -repository DIR -force {} -recover {} -target T -drop-target T}
        install {-project DIR -repository DIR -force {} -recover {} -target T -drop-target T}
        update {-project DIR -repository DIR -force {} -recover {} -target T -drop-target T}
        remove {-project DIR -force {} -recover {} -target T -drop-target T}
        verify {-project DIR -repository DIR -target T}
        pack {-out DIR -force {} -evidence FILE}
        inspect {-target T -provenance FILE}
        stage {-target T -modules DIR -headers DIR -files DIR -as PATH -replace {}}
        compare {-provenance FILE}
        native-inspect {-target T}
        native-plan {-project DIR -target T -include {}}
        native-deploy {-project DIR -target T -out DIR -force {}}
        native-add {-package DIR -target T -name N -linkage L -as PATH -import FILE -symbol S -license EXPR -notice PATH -replace {}}
        native-require {-package DIR -target T -origin O -linkage L -identity I -version V -pkg-config M -symbol S
            -runtime WHEN -capability C -purpose TEXT -kind K -loaded-by L -replace {}}
        native-audit {-target T}
    }
    variable commands {add install update remove verify package native}
}

proc pm::cli::usage {} {
    variable invocation
    set me $invocation
    return [join [list \
        "usage: $me add NAME|FILE.botpkg|DIR \[-request R\] \[-replace\] \[OPTION...\]" \
        "       $me install \[OPTION...\]" \
        "       $me update \[NAME...\] \[OPTION...\]" \
        "       $me remove NAME... \[OPTION...\]" \
        "       $me verify \[-project DIR\] \[-repository DIR\]..." \
        "       $me package pack \[DIR\] \[-out DIR\] \[-force\] \[-evidence FILE\]" \
        "       $me package inspect FILE.botpkg \[-target T\] \[-provenance FILE\]" \
        "       $me package stage \[DIR\] -target T -modules|-headers|-files SRC" \
        "                     \[-as PATH\] \[-replace\]" \
        "       $me package compare A.botpkg B.botpkg \[-provenance FILE\]..." \
        "       $me native inspect FILE \[-target T\]" \
        "       $me native plan \[-project DIR\] \[-target T\] \[-include\]" \
        "       $me native deploy -target T -out DIR \[-project DIR\] \[-force\]" \
        "       $me native add FILE -target T -name N \[-linkage L\] \[-as PATH\]" \
        "                     \[-import FILE\] \[-symbol S\]... \[-license EXPR\]" \
        "                     \[-notice PATH\]... \[-replace\] \[-package DIR\]" \
        "       $me native require NAME -target T -origin system \[-identity I\]" \
        "                     \[-version V\] \[-pkg-config M\] \[-symbol S\]..." \
        "       $me native require NAME -target T -runtime always|capability|optional" \
        "                     -purpose TEXT \[-capability C\] \[-identity I\]" \
        "                     \[-kind library|facility\] \[-loaded-by LIB\]" \
        "       $me native audit \[DIR\] \[-target T\]" \
        "" \
        "Options of add, install, update and remove:" \
        "  -project DIR       the project (the directory of its botlish.json);" \
        "                     default: the current directory" \
        "  -repository DIR    a local repository of NAME-VERSION.botpkg artifacts" \
        "                     (any number; never searched implicitly)" \
        "  -target T          prepare the target view of T (a compilation target:" \
        "                     linux-x86_64, macos-aarch64, ...; any number); views" \
        "                     already prepared are kept up to date" \
        "  -drop-target T     remove the target view of T" \
        "  -force             replace installed packages that were changed" \
        "  -recover           roll back an interrupted operation" \
        "" \
        "Packages are installed under PROJECT/.bot_modules, each package's own" \
        "dependencies in its own .bot_modules. Nothing is downloaded and nothing a" \
        "package holds is run. Reference: $me -help packages"] \n]
}

proc pm::cli::UsageError {message} {
    variable invocation
    return -code error -errorcode {PM USAGE} $message
}

# Runs the package command ARGV (its first word the command); the exit
# status.
proc pm::cli::main {argv invocation} {
    set ::pm::cli::invocation $invocation
    if {[catch {Run $argv} result options]} {
        set code [dict get $options -errorcode]
        if {[lindex $code 0] eq "PM" && [lindex $code 1] eq "USAGE"} {
            puts stderr "$invocation [lindex $argv 0]: $result"
            puts stderr "run $invocation [lindex $argv 0] -help for this command's usage"
            return 2
        }
        if {[lindex $code 0] eq "PM"} {
            puts stderr "error: $result ([join [lrange $code 0 1]])"
            return 1
        }
        puts stderr [dict get $options -errorinfo]
        return 1
    }
    return $result
}

proc pm::cli::Run {argv} {
    variable options
    set command [lindex $argv 0]
    set rest [lrange $argv 1 end]
    if {$command eq "package"} {
        set command [lindex $rest 0]
        set rest [lrange $rest 1 end]
        if {$command ni {pack inspect stage compare}} {
            if {$command in {"" -help --help -h}} {
                puts [usage]
                return 0
            }
            UsageError "unknown package command \"$command\" (known: pack, inspect, stage, compare)"
        }
    } elseif {$command eq "native"} {
        set command [lindex $rest 0]
        set rest [lrange $rest 1 end]
        if {$command ni {inspect plan deploy add require audit}} {
            if {$command in {"" -help --help -h}} {
                puts [usage]
                return 0
            }
            UsageError "unknown native command \"$command\" (known: inspect, plan, deploy, add, require, audit)"
        }
        set command native-$command
    }
    if {[lsearch -exact $rest -help] >= 0 || [lsearch -exact $rest --help] >= 0 || [lsearch -exact $rest -h] >= 0} {
        puts [usage]
        return 0
    }
    lassign [Parse $command $rest [dict get $options $command]] words given
    if {$command in {verify inspect native-inspect native-plan native-deploy native-add native-require native-audit}
            && [dict exists $given -target] && [llength [dict get $given -target]] > 1} {
        UsageError "-target is given twice: $command checks one target"
    }
    foreach target [concat [dict getdef $given -target {}] [dict getdef $given -drop-target {}]] {
        if {![pm::target::isTarget $target]} {
            UsageError "\"$target\" is not a compilation target (known: [join [pm::target::names] {, }])"
        }
    }
    return [pm::commands::[string map {- _} $command] $words $given]
}

# The positional WORDS and the GIVEN options (dict NAME -> list of values) of
# ARGS for a command whose options are TABLE.
proc pm::cli::Parse {command args table} {
    set words {}
    set given [dict create]
    for {set i 0} {$i < [llength $args]} {incr i} {
        set arg [lindex $args $i]
        if {[string match -* $arg] && $arg ne "-"} {
            if {![dict exists $table $arg]} {
                set known [dict keys $table]
                if {$known eq ""} {
                    UsageError "$command takes no options (found \"$arg\")"
                }
                UsageError "unknown option \"$arg\" (known: [join $known {, }])"
            }
            if {[dict get $table $arg] eq ""} {
                dict set given $arg 1
                continue
            }
            if {$i + 1 >= [llength $args]} {
                UsageError "option $arg needs an argument ([dict get $table $arg])"
            }
            dict lappend given $arg [lindex $args [incr i]]
            continue
        }
        lappend words $arg
    }
    foreach option {-project -request -out -package -name -linkage -as -import -license -origin -identity -version
            -pkg-config -runtime -capability -purpose -kind -loaded-by -evidence -modules -headers -files} {
        if {[dict exists $given $option] && [llength [dict get $given $option]] > 1} {
            UsageError "$option is given twice"
        }
    }
    return [list $words $given]
}

# ---------------------------------------------------------------------------
# The commands

namespace eval pm::commands {}

proc pm::commands::Option {given name {default ""}} {
    if {[dict exists $given $name]} {
        return [lindex [dict get $given $name] 0]
    }
    return $default
}

proc pm::commands::Flag {given name} {
    return [dict exists $given $name]
}

# Opens the project of GIVEN for an operation: its context, locked, with the
# repositories configured.
proc pm::commands::Open {given} {
    set ctx [pm::install::Project [Option $given -project [pwd]]]
    pm::catalog::configure [dict getdef $given -repository {}]
    pm::install::Lock $ctx [Flag $given -recover]
    return $ctx
}

proc pm::commands::Print {lines} {
    foreach line $lines {
        puts $line
    }
}

# Runs SCRIPT with the project of GIVEN open and locked.
proc pm::commands::Locked {given ctxVar script} {
    upvar 1 $ctxVar ctx
    set ctx [Open $given]
    try {
        uplevel 1 $script
    } finally {
        pm::install::Unlock $ctx
    }
}

# The canonical bytes of the project descriptor DESCRIPTOR, validated again
# as a project's (a change never writes a descriptor the reader refuses).
proc pm::commands::DescriptorBytes {descriptor} {
    set bytes [pm::descriptor::encode $descriptor]
    pm::descriptor::fromBytes $bytes project "the new botlish.json"
    return $bytes
}

# The target views GIVEN asks for, with DESCRIPTOR's origins choices
# (pm::install::Views).
proc pm::commands::ViewSpec {given descriptor} {
    return [dict create requested [dict getdef $given -target {}] dropped [dict getdef $given -drop-target {}] \
        origins [dict getdef $descriptor origins {}]]
}

proc pm::commands::install {words given} {
    if {$words ne ""} {
        pm::cli::UsageError "install takes no package names (found \"[lindex $words 0]\"): it installs what botlish.json locks; add adds a package"
    }
    Locked $given ctx {
        set state [pm::state::read [dict get $ctx meta]]
        set descriptor [pm::install::Descriptor $ctx]
        set plan [pm::install::Resolve $ctx $descriptor $state [Flag $given -force]]
        Print [pm::install::Apply $ctx $plan $state [Flag $given -force] "" [ViewSpec $given $descriptor]]
        Notes $ctx $plan
    }
    return 0
}

# Notes about editable dependencies whose own dependencies are not
# installed (the manager never writes into an editable directory).
proc pm::commands::Notes {ctx plan} {
    dict for {name node} $plan {
        if {[dict get $node kind] ne "editable"} continue
        set descriptor [dict get $node descriptor]
        foreach dep [lsort [dict keys [dict get $descriptor dependencies]]] {
            if {![file isdirectory [file join [dict get $node target] .bot_modules $dep]]} {
                puts "note: the editable package $name needs $dep, which is not installed in [dict get $node target]/.bot_modules: run install there (the package manager never writes into an editable directory)"
            }
        }
    }
}

proc pm::commands::add {words given} {
    if {[llength $words] != 1} {
        pm::cli::UsageError "add takes one package: a NAME, a FILE.botpkg or a DIR (found [llength $words])"
    }
    set spec [lindex $words 0]
    set request [Option $given -request]
    if {$request ne "" && [set problem [pm::version::RequestProblem $request]] ne ""} {
        pm::cli::UsageError "-request: $problem"
    }
    Locked $given ctx {
        set project [dict get $ctx project]
        set state [pm::state::read [dict get $ctx meta]]
        set descriptor [pm::install::Descriptor $ctx 1]
        set source ""
        if {[string match *.botpkg $spec]} {
            set path [file normalize $spec]
            set artifact [pm::catalog::Load $path "the archive $spec"]
            set name [dict get $artifact name]
            set version [dict get $artifact version]
            set relative [pm::RelativePath $project $path]
            if {$relative eq ""} {
                pm::Fail PROJECT "the archive $path is on another volume than the project: botlish.json records a source relative to the project"
            }
            set source [dict create kind archive path $relative sha256 [dict get $artifact digest]]
        } elseif {[string first / $spec] >= 0 || [string first \\ $spec] >= 0 || $spec in {. ..}} {
            set dir [file normalize $spec]
            set relative [pm::RelativePath $project $dir]
            if {$relative eq ""} {
                pm::Fail PROJECT "the directory $dir is on another volume than the project: botlish.json records a source relative to the project"
            }
            if {![file isdirectory $dir]} {
                pm::Fail EDITABLE "$spec is not a directory (a package name has no \"/\"; an archive ends in .botpkg)"
            }
            set probe [pm::catalog::Editable $project "" [dict create path $relative]]
            set name [dict get $probe name]
            set version [dict get $probe version]
            set source [dict create kind directory path $relative]
        } else {
            if {[set problem [pm::descriptor::NameProblem $spec]] ne ""} {
                pm::cli::UsageError "$problem (a directory is written with a \"/\", as ./$spec)"
            }
            set name $spec
            if {[pm::catalog::RepositoryCount] == 0} {
                pm::Fail UNAVAILABLE "add $name needs a repository to find it in: pass -repository DIR (or add a FILE.botpkg)"
            }
            set versions [pm::catalog::Versions $name]
            if {$versions eq ""} {
                pm::Fail UNAVAILABLE "no repository holds a version of $name"
            }
            if {$request ne ""} {
                set version [pm::version::newest $versions $request]
                if {$version eq ""} {
                    pm::Fail REQUEST "no version of $name the repositories hold ([join $versions {, }]) satisfies the request \"$request\""
                }
            } else {
                set version [lindex $versions end]
            }
            # Validate it (identity, archive, locks) before anything is
            # written: resolution acquires it again from memory.
            pm::catalog::Find $name $version {}
        }
        if {$request eq ""} {
            set request [pm::version::defaultRequest $version]
        } elseif {![pm::version::satisfies $version $request]} {
            pm::Fail REQUEST "$name $version does not satisfy the request \"$request\""
        }
        if {[dict exists $descriptor dependencies $name] && ![Flag $given -replace]} {
            set was "request \"[dict get $descriptor dependencies $name]\""
            if {[dict exists $descriptor lock $name]} {
                append was ", locked to [dict get $descriptor lock $name]"
            }
            if {[dict exists $descriptor sources $name]} {
                append was ", [SourceText [dict get $descriptor sources $name]]"
            }
            pm::Fail EXISTS "$name is already a dependency ($was): pass -replace to replace it, or use update $name to move its lock"
        }
        dict set descriptor dependencies $name $request
        dict unset descriptor lock $name
        dict unset descriptor sources $name
        if {$source eq "" || [dict get $source kind] eq "archive"} {
            dict set descriptor lock $name $version
        }
        if {$source ne ""} {
            dict set descriptor sources $name $source
        }
        set bytes [DescriptorBytes $descriptor]
        set descriptor [pm::descriptor::fromBytes $bytes project botlish.json]
        set plan [pm::install::Resolve $ctx $descriptor $state [Flag $given -force]]
        Print [pm::install::Apply $ctx $plan $state [Flag $given -force] $bytes [ViewSpec $given $descriptor]]
        if {$source ne "" && [dict get $source kind] eq "directory"} {
            puts "added $name (request \"$request\"), editable: a link to [dict get $source path], not an immutable release"
        } else {
            puts "added $name (request \"$request\", lock $version)"
        }
        Notes $ctx $plan
    }
    return 0
}

proc pm::commands::SourceText {source} {
    if {[dict get $source kind] eq "archive"} {
        return "from the archive [dict get $source path]"
    }
    return "editable from [dict get $source path]"
}

proc pm::commands::update {words given} {
    Locked $given ctx {
        set state [pm::state::read [dict get $ctx meta]]
        set descriptor [pm::install::Descriptor $ctx]
        set deps [dict get $descriptor dependencies]
        set names $words
        if {$names eq ""} {
            set names [lsort [dict keys $deps]]
        }
        foreach name $names {
            if {![dict exists $deps $name]} {
                pm::Fail UNKNOWN "$name is not a dependency of [dict get $ctx project]"
            }
        }
        set lines {}
        foreach name $names {
            set request [dict get $deps $name]
            set source [dict getdef [dict get $descriptor sources] $name ""]
            if {$source ne "" && [dict get $source kind] eq "directory"} {
                lappend lines "$name: editable ([dict get $source path]): nothing to update"
                continue
            }
            if {$source ne ""} {
                lappend lines "$name: pinned to the archive [dict get $source path]: add a newer archive with -replace to update it"
                continue
            }
            if {[pm::catalog::RepositoryCount] == 0} {
                pm::Fail UNAVAILABLE "update $name needs a repository to look in: pass -repository DIR"
            }
            set versions [pm::catalog::Versions $name]
            set newest [pm::version::newest $versions $request]
            if {$newest eq ""} {
                pm::Fail UNAVAILABLE "no version of $name the repositories hold ([join [Or $versions none] {, }]) satisfies the request \"$request\""
            }
            set locked [dict getdef [dict get $descriptor lock] $name ""]
            if {$locked eq $newest} {
                lappend lines "$name: $newest is the newest version \"$request\" accepts"
            } elseif {$locked eq ""} {
                lappend lines "$name: locked to $newest"
            } else {
                lappend lines "$name: $locked -> $newest"
            }
            dict set descriptor lock $name $newest
        }
        set bytes [DescriptorBytes $descriptor]
        set plan [pm::install::Resolve $ctx $descriptor $state [Flag $given -force]]
        Print [pm::install::Apply $ctx $plan $state [Flag $given -force] $bytes [ViewSpec $given $descriptor]]
        Print $lines
    }
    return 0
}

proc pm::commands::Or {list default} {
    if {$list eq ""} {
        return [list $default]
    }
    return $list
}

proc pm::commands::remove {words given} {
    if {$words eq ""} {
        pm::cli::UsageError "remove needs the names of the dependencies to remove"
    }
    Locked $given ctx {
        set state [pm::state::read [dict get $ctx meta]]
        set descriptor [pm::install::Descriptor $ctx]
        set notes {}
        foreach name $words {
            if {![dict exists $descriptor dependencies $name]} {
                pm::Fail UNKNOWN "$name is not a dependency of [dict get $ctx project]"
            }
            foreach key {dependencies lock sources} {
                dict unset descriptor $key $name
            }
            if {![dict exists $state $name] && [pm::Exists [file join [dict get $ctx modules] $name]]} {
                lappend notes "note: left .bot_modules/$name in place: the package manager did not install it"
            }
        }
        set bytes [DescriptorBytes $descriptor]
        set plan [pm::install::Resolve $ctx $descriptor $state [Flag $given -force]]
        Print [pm::install::Apply $ctx $plan $state [Flag $given -force] $bytes [ViewSpec $given $descriptor]]
        Print $notes
        puts "removed [join $words {, }] from botlish.json"
    }
    return 0
}

# ---------------------------------------------------------------------------
# verify

proc pm::commands::verify {words given} {
    if {$words ne ""} {
        pm::cli::UsageError "verify takes no package names (it verifies the whole installation)"
    }
    set ctx [pm::install::Project [Option $given -project [pwd]]]
    pm::catalog::configure [dict getdef $given -repository {}]
    set problems {}
    set notes {}
    set checked 0
    if {[pm::Exists [file join [dict get $ctx meta] lock]] || [pm::Exists [pm::install::Txn $ctx]]} {
        lappend problems "a package operation is running, or was interrupted (the next add, install, update or remove recovers it)"
    }
    set descriptor [pm::install::Descriptor $ctx]
    set state [pm::state::read [dict get $ctx meta]]
    set modules [dict get $ctx modules]
    foreach name [lsort [dict keys [dict get $descriptor dependencies]]] {
        set record [dict getdef $state $name ""]
        set active [file join $modules $name]
        set source [dict getdef [dict get $descriptor sources] $name ""]
        if {$record eq ""} {
            if {[pm::Exists $active]} {
                lappend problems "$name: .bot_modules/$name was not installed by the package manager: not verified"
            } else {
                lappend problems "$name: not installed (run install)"
            }
            continue
        }
        if {$source ne "" && [dict get $source kind] eq "directory"} {
            if {[dict get $record kind] ne "editable"} {
                lappend problems "$name: botlish.json makes it editable, and an artifact is installed (run install)"
                continue
            }
            set target [pm::ProjectPath [dict get $ctx project] [dict get $source path]]
            if {[pm::install::LinkTarget $active] ne $target} {
                lappend problems "$name: .bot_modules/$name is not the link to [dict get $source path] (run install)"
            }
            lappend notes "$name [dict get $record version]: editable ([dict get $source path]): a local directory, not an immutable artifact; its contents cannot be authenticated"
            incr checked
            continue
        }
        if {[dict get $record kind] ne "artifact"} {
            lappend problems "$name: an editable link is installed where botlish.json names a release (run install)"
            continue
        }
        set locked [dict getdef [dict get $descriptor lock] $name ""]
        if {$locked eq ""} {
            lappend problems "$name: no lock in botlish.json (run update $name)"
        } elseif {$locked ne [dict get $record version]} {
            lappend problems "$name: [dict get $record version] is installed, and botlish.json locks $locked (run install)"
        }
        set artifactSource ""
        if {$source ne ""} {
            if {[dict get $record sha256] ne [dict get $source sha256]} {
                lappend problems "$name: the installed artifact (sha256 [dict get $record sha256]) is not the archive source's ([dict get $source sha256]) (run install)"
            }
            set artifactSource $source
        }
        VerifyNode $ctx $name $record $active .bot_modules/$name $artifactSource [list $name [dict get $record version]] problems notes checked
    }
    foreach name [lsort [dict keys $state]] {
        if {![dict exists $descriptor dependencies $name]} {
            lappend problems "$name: installed by the package manager, and no longer a dependency (install removes it)"
        }
    }
    VerifyViews $ctx $state $descriptor [Option $given -target] problems notes
    if {[file isdirectory $modules]} {
        foreach entry [pm::state::Entries $modules] {
            if {$entry in {.botlish .targets} || [dict exists $state $entry] || [dict exists $descriptor dependencies $entry]} continue
            lappend notes "$entry: .bot_modules/$entry was installed by hand: not managed, not verified"
        }
    }
    Print [lmap note $notes {string cat "note: " $note}]
    Print [lmap problem $problems {string cat "problem: " $problem}]
    if {$problems ne ""} {
        puts "verify: [llength $problems] problem(s) in [dict get $ctx project]"
        return 1
    }
    puts "verify: $checked package instance(s) in [dict get $ctx project]: as installed"
    puts "(integrity only: installed bytes against local artifacts and the installation record; no artifact carries a publisher signature to authenticate)"
    return 0
}

proc pm::commands::VerifyNode {ctx name record dir shown source chain problemsVar notesVar checkedVar} {
    upvar 1 $problemsVar problems $notesVar notes $checkedVar checked
    incr checked
    set version [dict get $record version]
    set changes [pm::state::Changes $dir $record $shown 0]
    foreach change $changes {
        lappend problems "$name $version: $change"
    }
    # The installed descriptor: the artifact's, with the record's children as
    # its locks.
    set descriptorPath [file join $dir botlish.json]
    if {[file isfile $descriptorPath]} {
        if {[catch {pm::descriptor::read $descriptorPath artifact} descriptor]} {
            lappend problems "$name $version: $descriptor"
        } else {
            if {[dict get $descriptor name] ne $name || [dict get $descriptor version] ne $version} {
                lappend problems "$name $version: its installed botlish.json says [dict get $descriptor name] [dict get $descriptor version]"
            }
            set locks [lsort -stride 2 [dict get $descriptor lock]]
            set installed [lsort -stride 2 [concat {*}[lmap {child childRecord} [dict get $record children] {
                list $child [dict get $childRecord version]
            }]]]
            if {$locks ne $installed} {
                lappend problems "$name $version: its dependencies installed ([Pairs $installed]) are not the ones its botlish.json locks ([Pairs $locks])"
            }
        }
    }
    # The artifact, when one is available: its digest must be the record's,
    # and every installed file its bytes.
    set artifact ""
    if {$source ne ""} {
        if {[catch {pm::catalog::ArchiveSource [dict get $ctx project] $name $source} artifact]} {
            lappend problems "$name $version: $artifact"
            set artifact ""
        }
    } elseif {[pm::catalog::RepositoryCount] > 0} {
        if {[catch {pm::catalog::Find $name $version [lrange $chain 0 end-2]} artifact options]} {
            if {[lindex [dict get $options -errorcode] 1] ne "UNAVAILABLE"} {
                lappend problems "$name $version: $artifact"
            }
            set artifact ""
        }
    }
    if {$artifact eq ""} {
        lappend notes "$name $version: no artifact available: checked against the installation record (sizes and CRC-32) only"
    } else {
        if {[dict get $artifact digest] ne [dict get $record sha256]} {
            lappend problems "$name $version: the artifact [dict get $artifact path] (sha256 [dict get $artifact digest]) is not the one installed (sha256 [dict get $record sha256])"
        } else {
            foreach {path bytes} [dict get $artifact files] {
                set file [file join $dir {*}[split $path /]]
                if {[file isfile $file] && [file type $file] eq "file" && [pm::ReadBytes $file] ne $bytes} {
                    lappend problems "$name $version: $shown/$path differs from the artifact"
                }
            }
        }
    }
    dict for {child childRecord} [dict get $record children] {
        VerifyNode $ctx $child $childRecord [file join $dir .bot_modules $child] $shown/.bot_modules/$child "" \
            [concat $chain [list $child [dict get $childRecord version]]] problems notes checked
    }
}

# The project's target views against their record and their inputs; with
# TARGET, that view's native plan verified again (system libraries
# included, where the target is the host's).
proc pm::commands::VerifyViews {ctx state descriptor target problemsVar notesVar} {
    upvar 1 $problemsVar problems $notesVar notes
    set views [pm::state::views [dict get $ctx meta]]
    set origins [dict getdef $descriptor origins {}]
    set manual [pm::view::Manual $ctx $state]
    dict for {name view} $views {
        set changes [pm::state::ViewChanges [pm::view::Dir $ctx $name] $view .bot_modules/.targets/$name]
        foreach change $changes {
            lappend problems "view $name: $change (run install)"
        }
        if {[dict get $view derived] ne [pm::view::Derived $name $state $origins $manual]} {
            lappend problems "view $name: derived from another installation than the current one (run install)"
        }
    }
    if {$target eq ""} {
        if {[dict size $views] > 0} {
            lappend notes "target views: [join [lsort [dict keys $views]] {, }] (verify -target T verifies one's native dependencies again)"
        }
        return
    }
    if {![dict exists $views $target]} {
        if {[dict size $views] == 0} {
            lappend notes "no installed package is target-specific: $target compiles from .bot_modules itself"
        } else {
            lappend problems "the packages are not prepared for $target (prepared: [join [lsort [dict keys $views]] {, }]): run install -target $target"
        }
        return
    }
    set plan [pm::native::Plan $target [pm::view::Instances [pm::view::Dir $ctx $target]] $origins]
    foreach problem [dict get $plan problems] {
        lappend problems "$target: $problem"
    }
    foreach note [dict get $plan notes] {
        lappend notes "$target: $note"
    }
    foreach entry [dict get $plan libraries] {
        if {[dict get $entry verified]} {
            lappend notes "$target: [dict get $entry name]: [dict get $entry origin] [dict get $entry linkage], [dict get $entry facts]: [dict get $entry evidence]"
        }
    }
}

proc pm::commands::Pairs {pairs} {
    if {$pairs eq ""} {
        return none
    }
    return [join [lmap {name version} $pairs {string cat $name " " $version}] {, }]
}

# ---------------------------------------------------------------------------
# package pack, package inspect

proc pm::commands::pack {words given} {
    if {[llength $words] > 1} {
        pm::cli::UsageError "package pack takes one package directory (found [llength $words])"
    }
    set dir [file normalize [lindex [concat $words [list [pwd]]] 0]]
    if {![file isdirectory $dir]} {
        pm::Fail PACK "$dir is not a directory"
    }
    set descriptor [pm::descriptor::read [file join $dir botlish.json] pack]
    set name [dict get $descriptor name]
    set version [dict get $descriptor version]
    set files [Collect $dir]
    dict set files botlish.json [pm::descriptor::encode $descriptor 0]
    set targetNotes [PackTargets $descriptor $files $dir]
    # The native audit (PACKAGE-MANAGER-MILESTONE-3.md): a target-aware
    # package is packed only when every target's mandatory native closure
    # is complete; a pure-Botlish package goes on as in PM-1.
    set evidence ""
    if {[Option $given -evidence] ne "" || [pm::targets::Aware $descriptor]} {
        pm::authoring
    }
    if {[Option $given -evidence] ne ""} {
        set evidence [pm::release::readEvidence [file normalize [Option $given -evidence]]]
    }
    if {[pm::targets::Aware $descriptor]} {
        set audit [pm::author::Audit $files $descriptor]
        if {![pm::author::Packable $audit]} {
            set problems [dict get $audit problems]
            dict for {target report} [dict get $audit targets] {
                foreach problem [dict get $report problems] {
                    lappend problems "$target: $problem"
                }
            }
            pm::Fail PACK "$dir cannot be packed: its native audit is incomplete:\n  [join $problems "\n  "]\n(native audit $dir shows the whole audit)"
        }
        dict for {target report} [dict get $audit targets] {
            set status [dict get {complete complete partial "partially verified" incomplete incomplete} [dict get $report status]]
            set line "  audit $target: $status"
            if {[dict get $report status] eq "partial"} {
                append line " ([llength [dict get $report partial]] fact[expr {[llength [dict get $report partial]] == 1 ? "" : "s"}] unverifiable from this host: native audit lists them)"
            }
            lappend targetNotes $line
        }
    }
    set bytes [pm::archive::bytes $files]
    # The reader must accept what the writer made.
    set archive [pm::archive::fromBytes $bytes "the new artifact"]
    pm::descriptor::fromBytes [dict get $archive descriptor] artifact "the new artifact's botlish.json"
    set out [file normalize [Option $given -out $dir]]
    file mkdir $out
    set target [file join $out $name-$version.botpkg]
    set digest [pm::sha256::hex $bytes]
    # The provenance record, made (and its checks run) before anything is
    # written: evidence the files contradict stops the pack.
    set provenance ""
    if {$evidence ne ""} {
        set made [pm::release::record $bytes [file tail $target] $files $descriptor $evidence]
        set provenance [pm::release::encode [dict get $made record]]
        set recordPath [file join $out $name-$version.provenance.json]
    }
    if {[pm::Exists $target]} {
        if {[file type $target] ne "file"} {
            pm::Fail PACK "$target is a [file type $target], not an artifact file"
        }
        if {[pm::ReadBytes $target] eq $bytes} {
            puts "packed $name $version: $target (unchanged)"
            puts "  sha256 $digest"
            if {$provenance ne ""} {
                WriteRecord $recordPath $provenance $digest [Flag $given -force]
                Print [dict get $made lines]
            }
            Print [lsearch -all -inline $targetNotes "  audit *"]
            return 0
        }
        if {![Flag $given -force]} {
            pm::Fail EXISTS "$target already holds a different $name $version: a release is immutable. Raise the version, or pass -force to overwrite this local file"
        }
    }
    if {$provenance ne ""} {
        # Checked before the artifact is written: a record of another
        # artifact under this name is refused as the artifact is.
        RecordReplaceable $recordPath $provenance $digest [Flag $given -force]
    }
    pm::ReplaceFile $target $bytes
    set size 0
    dict for {path content} $files {
        incr size [string length $content]
    }
    puts "packed $name $version: $target"
    puts "  sha256 $digest"
    puts "  [dict size $files] files, [string length $bytes] bytes ($size bytes unpacked)"
    if {$provenance ne ""} {
        WriteRecord $recordPath $provenance $digest [Flag $given -force]
        Print [dict get $made lines]
    }
    set paths [dict keys $files]
    if {[pm::targets::Aware $descriptor]} {
        foreach target [dict keys [dict get $descriptor targets]] {
            lappend paths {*}[dict keys [pm::targets::Map $descriptor $target [dict keys $files]]]
        }
    }
    if {"$name.bot" ni $paths && [llength [lsearch -all -inline -glob $paths $name/*.bot]] == 0} {
        puts "note: the package has no module of its namespace ($name.bot or $name/...): an import of $name names nothing in it"
    }
    if {[dict get $descriptor sources] ne ""} {
        puts "note: botlish.json's \"sources\" stay with this directory: an artifact never holds them"
    }
    if {[dict getdef $descriptor origins {}] ne ""} {
        puts "note: botlish.json's \"origins\" stay with this directory: an artifact never holds them"
    }
    Print $targetNotes
    return 0
}

# Refuses to replace the provenance record PATH unless it holds BYTES
# already, or a record of this same artifact (DIGEST), or FORCE: a record
# of another artifact under this release's name is a release conflict.
proc pm::commands::RecordReplaceable {path bytes digest force} {
    if {![pm::Exists $path] || $force} {
        return
    }
    if {[file type $path] ne "file"} {
        pm::Fail PACK "$path is a [file type $path], not a provenance record"
    }
    if {[catch {pm::release::readRecord $path} old]} {
        pm::Fail EXISTS "$path exists and is no provenance record: it is left as it is (pass -force to replace it)"
    }
    if {[dict get $old subject sha256] ne $digest} {
        pm::Fail EXISTS "$path records the artifact with SHA-256 [dict get $old subject sha256], not this one ([pm::Short $digest]): the release it describes is another file (pass -force to replace this local record)"
    }
}

proc pm::commands::WriteRecord {path bytes digest force} {
    RecordReplaceable $path $bytes $digest $force
    if {[pm::Exists $path] && [pm::ReadBytes $path] eq $bytes} {
        puts "  provenance $path (unchanged)"
        return
    }
    pm::ReplaceFile $path $bytes
    puts "  provenance $path (sha256 [pm::Short [pm::sha256::hex $bytes]]; bound to the artifact's sha256 [pm::Short $digest]; unsigned)"
}

# The checks of a target-aware package's FILES (dict PATH -> BYTES) before
# it is packed: its target layout, and every target's bundled libraries
# (pm::native::CheckBundled) and their loader dependencies, which must be
# the target's platform or libraries the package itself declares. Lines of
# report; a problem fails the pack.
proc pm::commands::PackTargets {descriptor files dir} {
    if {![pm::targets::Aware $descriptor]} {
        return {}
    }
    set problems [pm::targets::Problems $descriptor [dict keys $files]]
    set lines {}
    dict for {target entry} [dict get $descriptor targets] {
        set view [pm::targets::Map $descriptor $target [dict keys $files]]
        set identities {}
        foreach library [dict get $entry libraries] {
            if {[dict get $library identity] ne ""} {
                lappend identities [string tolower [dict get $library identity]] [string tolower [file tail [dict get $library identity]]]
            }
        }
        set summary {}
        foreach library [dict get $entry libraries] {
            set name [dict get $library name]
            lappend summary "$name ([dict get $library origin] [dict get $library linkage])"
            if {[dict get $library origin] ne "bundled" || ![dict exists $view [dict get $library file]]} continue
            set importBytes ""
            if {[dict get $library import] ne "" && [dict exists $view [dict get $library import]]} {
                set importBytes [dict get $files [dict get $view [dict get $library import]]]
            }
            if {[catch {pm::native::CheckBundled $target $library [dict get $files [dict get $view [dict get $library file]]] \
                    "$target: library $name ([dict get $view [dict get $library file]])" $importBytes} facts]} {
                lappend problems $facts
                continue
            }
            foreach need [dict get $facts needs] {
                if {[pm::target::platformLibrary $target $need]} continue
                if {[string tolower $need] in $identities || [string tolower [file tail $need]] in $identities} continue
                lappend problems "$target: library $name needs $need, which is neither $target's platform nor a library this package declares for $target (with its identity): a consumer could not resolve it"
            }
        }
        lappend lines "  target $target: [dict size $view] files[expr {$summary ne "" ? ", libraries [join $summary {, }]" : ""}]"
    }
    if {$problems ne ""} {
        pm::Fail PACK "$dir cannot be packed:\n  [join $problems "\n  "]"
    }
    return $lines
}

# The files of the package directory DIR, as {PATH BYTES ...} with "/"
# paths: every regular file, except hidden entries (a name starting with
# ".": .git, .bot_modules, editors' files) at any depth and *.botpkg files.
# A link, a device, a socket or a pipe, or a name an archive cannot hold, is
# an error: the package would not be what the directory holds.
proc pm::commands::Collect {dir} {
    set files [dict create]
    set problems {}
    CollectInto $dir "" files problems
    if {$problems ne ""} {
        pm::Fail PACK "$dir cannot be packed:\n  [join $problems "\n  "]"
    }
    if {[set problem [pm::archive::CollisionProblem [lsort [dict keys $files]]]] ne ""} {
        pm::Fail PACK "$dir cannot be packed: $problem"
    }
    return $files
}

proc pm::commands::CollectInto {dir relative filesVar problemsVar} {
    upvar 1 $filesVar files $problemsVar problems
    set here [file join $dir {*}[split $relative /]]
    # Every entry, hidden ones too (glob's * leaves them out on Unix only):
    # the rule below, not the platform, decides what is left out.
    foreach name [pm::state::Entries $here] {
        if {[string index $name 0] eq "."} continue
        if {$relative eq ""} {
            set path $name
        } else {
            set path $relative/$name
        }
        set full [file join $here $name]
        set type [file type $full]
        if {$type eq "file" && [string match *.botpkg $name]} continue
        if {[set problem [pm::archive::pathProblem $path]] ne ""} {
            lappend problems "$path: $problem"
            continue
        }
        switch -- $type {
            directory { CollectInto $dir $path files problems }
            file { dict set files $path [pm::ReadBytes $full] }
            link { lappend problems "$path is a symbolic link: a package holds regular files only" }
            default { lappend problems "$path is a $type: a package holds regular files only" }
        }
    }
}

proc pm::commands::inspect {words given} {
    if {[llength $words] != 1} {
        pm::cli::UsageError "package inspect takes one FILE.botpkg"
    }
    pm::authoring
    set artifact [pm::catalog::Load [lindex $words 0] [lindex $words 0]]
    set descriptor [dict get $artifact descriptor]
    puts "[dict get $artifact name] [dict get $artifact version]"
    puts "  sha256 [dict get $artifact digest]"
    puts "  [string length [pm::ReadBytes [dict get $artifact path]]] bytes, [expr {[llength [dict get $artifact files]] / 2}] files"
    foreach dep [lsort [dict keys [dict get $descriptor dependencies]]] {
        puts "  dependency $dep \"[dict get $descriptor dependencies $dep]\", locked [dict get $descriptor lock $dep]"
    }
    foreach {path bytes} [dict get $artifact files] {
        puts "  [format %9d [string length $bytes]]  $path"
    }
    if {[pm::targets::Aware $descriptor]} {
        dict for {target entry} [dict get $descriptor targets] {
            set view [pm::targets::Map $descriptor $target [dict keys [dict get $artifact files]]]
            puts "  target $target: [dict size $view] files in its view[expr {[dict get $entry files] ne "" ? " ([dict get $entry files] at the package root)" : ""}]"
            foreach library [dict get $entry libraries] {
                set text "    library [dict get $library name]: [dict get $library origin] [dict get $library linkage]"
                if {[dict get $library file] ne ""} { append text ", [dict get $library file]" }
                if {[dict get $library identity] ne ""} { append text ", loads as [dict get $library identity]" }
                if {[dict get $library version] ne ""} { append text ", version \"[dict get $library version]\"" }
                if {[dict getdef $library license ""] ne ""} { append text ", license [dict get $library license] (the author's statement)" }
                puts $text
                if {[dict getdef $library notices {}] ne ""} {
                    puts "      notices: [join [dict get $library notices] {, }]"
                }
            }
            foreach dependency [dict getdef $entry runtime {}] {
                set when [dict get $dependency requirement]
                if {$when eq "capability"} { set when "for \"[dict get $dependency capability]\"" }
                puts "    run time: [dict get $dependency kind] [dict get $dependency name][expr {[dict get $dependency identity] ne "" ? " ([dict get $dependency identity])" : ""}], $when[expr {[dict get $dependency loaded-by] ne "" ? ", opened by [dict get $dependency loaded-by]" : ""}]: [dict get $dependency purpose]"
            }
            set modules [lsearch -all -inline -glob [dict keys $view] *.bot]
            set own [lsearch -all -inline -glob [lmap {v p} $view {if {[string match *.bot $v] && $v ne $p} {set v} else continue}] *]
            if {$own ne ""} {
                puts "    bindings: [llength $own] module[expr {[llength $own] == 1 ? "" : "s"}] of the target's own ([join [lsort -unique [lmap m $own {lindex [split $m /] 0}]] {, }]/...), [expr {[llength $modules] - [llength $own]}] common"
            }
            foreach framework [dict get $entry frameworks] {
                puts "    framework $framework (system)"
            }
            foreach header [dict get $entry headers] {
                puts "    headers $header"
            }
        }
        set target [Option $given -target]
        if {$target ne ""} {
            if {![dict exists $descriptor targets $target]} {
                pm::Fail UNSUPPORTED "[dict get $artifact name] [dict get $artifact version] supports [join [pm::targets::Supported $descriptor] {, }], not $target"
            }
            set view [pm::targets::Map $descriptor $target [dict keys [dict get $artifact files]]]
            set files [dict get $artifact files]
            foreach library [dict get $descriptor targets $target libraries] {
                if {[dict get $library origin] ne "bundled"} continue
                set importBytes ""
                if {[dict get $library import] ne ""} {
                    set importBytes [dict get $files [dict get $view [dict get $library import]]]
                }
                set facts [pm::native::CheckBundled $target $library [dict get $files [dict get $view [dict get $library file]]] \
                    "library [dict get $library name]" $importBytes]
                puts "  $target: [dict get $library name]: [dict get $facts description]: as declared"
            }
        }
        # The audit of the release as it is (read, never run).
        set audit [pm::author::Audit [dict create {*}[dict get $artifact files]] $descriptor]
        dict for {target report} [dict get $audit targets] {
            set status [dict get {complete complete partial "partially verified" incomplete INCOMPLETE} [dict get $report status]]
            puts "  native closure of $target: $status"
            foreach problem [dict get $report problems] {
                puts "    problem: $problem"
            }
            foreach item [dict get $report partial] {
                puts "    unverified from this host: $item"
            }
        }
        InspectProvenance $given $artifact
        puts "(a valid .botpkg, format 1, schema [dict get $descriptor schema]: one release for every target it names; nothing authenticates who made it)"
        return 0
    } else {
        puts "  target-independent: every target"
        InspectProvenance $given $artifact
        puts "(a valid .botpkg, format 1; its digest is computed here, and nothing authenticates who made it)"
    }
    return 0
}

# The provenance record GIVEN names (-provenance), against ARTIFACT.
proc pm::commands::InspectProvenance {given artifact} {
    set path [Option $given -provenance]
    if {$path eq ""} {
        return
    }
    set record [pm::release::readRecord $path]
    set relation [pm::release::check $record $artifact]
    puts "  provenance $path (sha256 [pm::Short [pm::sha256::file $path]], format 1)"
    if {![dict get $relation matches]} {
        foreach problem [dict get $relation problems] {
            puts "    MISMATCH: $problem"
        }
        pm::Fail PROVENANCE "$path is not a record of [dict get $artifact path]"
    }
    puts "    describes this artifact: its subject's SHA-256 and every file's digest are the artifact's"
    puts "    asserted by the author, unchecked unless a check below says so: [dict get $record sources] source(s), [dict get $record builds] build(s), [dict get $record generators] generator(s)"
    foreach check [dict get $record checks] {
        puts "    check made when the record was made: [dict get $check subject] [dict get $check fact]: [dict get $check result] ([pm::Short [dict get $check value]])"
    }
    puts "    unsigned: the record does not authenticate who made the artifact or its sources (PM-4 and PM-5)"
}

proc pm::commands::compare {words given} {
    if {[llength $words] != 2} {
        pm::cli::UsageError "package compare takes two FILE.botpkg: two candidates of one release"
    }
    pm::authoring
    set records [dict getdef $given -provenance {}]
    if {[llength $records] ni {0 2}} {
        pm::cli::UsageError "-provenance is given twice or not at all: the records of A and of B"
    }
    lassign $words pa pb
    set a [pm::catalog::Load $pa $pa]
    set b [pm::catalog::Load $pb $pb]
    set ra ""
    set rb ""
    if {$records ne ""} {
        set ra [pm::release::readRecord [lindex $records 0]]
        set rb [pm::release::readRecord [lindex $records 1]]
        foreach {record artifact name} [list $ra $a A $rb $b B] {
            set relation [pm::release::check $record $artifact]
            if {![dict get $relation matches]} {
                pm::Fail PROVENANCE "the record given for $name is not $name's: [lindex [dict get $relation problems] 0]"
            }
        }
    }
    set result [pm::release::compare $a $b $ra $rb]
    Print [dict get $result lines]
    return [expr {[dict get $result identical] ? 0 : 1}]
}

# ---------------------------------------------------------------------------
# native inspect, plan, deploy

proc pm::commands::native_inspect {words given} {
    if {[llength $words] != 1} {
        pm::cli::UsageError "native inspect takes one FILE"
    }
    set path [lindex $words 0]
    if {![file isfile $path]} {
        pm::Fail NATIVE "$path is not a file"
    }
    set facts [pm::binary::inspect [pm::ReadBytes $path] $path]
    puts "$path: [pm::binary::describe $facts]"
    set shown $facts
    foreach key {symbols index} {
        if {[dict exists $shown $key]} {
            dict set shown $key "[llength [dict get $shown $key]] names"
        }
    }
    if {[dict exists $shown members]} {
        dict set shown members "[llength [dict get $shown members]] members"
    }
    if {[dict exists $shown slices]} {
        dict set shown slices [lmap slice [dict get $shown slices] {pm::binary::describe [dict get $slice facts]}]
    }
    dict for {key value} $shown {
        if {$key eq "kind" || $value eq ""} continue
        puts "  $key: $value"
    }
    set target [Option $given -target]
    if {$target ne ""} {
        set selected [pm::native::Slice $target $facts]
        if {[dict get $facts kind] eq "archive"} {
            set archive [pm::native::ArchiveFacts $target $facts $path]
            puts "  for $target: [dict get $archive objects] object(s)[expr {[dict get $archive imports] ne "" ? ", an import library of [join [dict get $archive imports] {, }]" : ""}]"
        } elseif {$selected eq "" || ![pm::native::Matches $target $selected]} {
            pm::Fail NATIVE "$path is [pm::binary::describe $facts], not a native file of $target"
        } else {
            puts "  for $target: [pm::binary::describe $selected]"
        }
    }
    puts "(read, never run: the file's own headers, not its provenance)"
    return 0
}

# The project's native plan of TARGET (the host's by default), from its
# view, verified: {ctx descriptor plan view}.
proc pm::commands::NativePlan {given} {
    set ctx [pm::install::Project [Option $given -project [pwd]]]
    set descriptor [pm::install::Descriptor $ctx]
    set target [Option $given -target [pm::target::host]]
    if {$target eq ""} {
        pm::cli::UsageError "this host is no compilation target: pass -target T"
    }
    set views [pm::state::views [dict get $ctx meta]]
    if {![dict exists $views $target]} {
        if {[dict size $views] == 0} {
            return [dict create ctx $ctx descriptor $descriptor target $target plan "" view ""]
        }
        pm::Fail TARGET "the packages are not prepared for $target (prepared: [join [lsort [dict keys $views]] {, }]): run install -target $target"
    }
    set dir [pm::view::Dir $ctx $target]
    set changes [pm::state::ViewChanges $dir [dict get $views $target] .bot_modules/.targets/$target]
    if {$changes ne ""} {
        pm::Fail MODIFIED "the view of $target changed since it was derived ([lindex $changes 0]): run install"
    }
    set plan [pm::native::Plan $target [pm::view::Instances $dir] [dict getdef $descriptor origins {}]]
    return [dict create ctx $ctx descriptor $descriptor target $target plan $plan view $dir]
}

# Where TARGET's executables find shared libraries deployed beside them:
# {SUBDIRECTORY RUNTIME-PATH} (RUNTIME-PATH "" when the loader needs none).
proc pm::commands::DeployLayout {target} {
    switch -- [dict get [pm::target::facts $target] os] {
        linux { return [list lib {$ORIGIN/lib}] }
        macos { return [list lib @executable_path/lib] }
        windows { return [list . ""] }
    }
}

proc pm::commands::native_plan {words given} {
    if {$words ne ""} {
        pm::cli::UsageError "native plan takes no arguments"
    }
    set result [NativePlan $given]
    set target [dict get $result target]
    set plan [dict get $result plan]
    set project [dict get [dict get $result ctx] project]
    if {[Flag $given -include]} {
        # The include directories of the packages' public headers, one C
        # compiler option per line (cc $(botlish native plan -include) ...).
        if {$plan ne ""} {
            if {[dict get $plan problems] ne ""} {
                pm::Fail NATIVE "the native plan of $target has problems:\n  [join [dict get $plan problems] "\n  "]"
            }
            foreach header [dict get $plan headers] {
                puts -I[dict get $header dir]
            }
        }
        return 0
    }
    puts "native plan for $target ([expr {$target eq [pm::target::host] ? "this host" : "not this host: system libraries unverified"}]), project $project"
    if {$plan eq ""} {
        puts "  no installed package is target-specific: no native dependency is declared"
        return 0
    }
    if {[dict get $plan problems] ne ""} {
        Print [lmap p [dict get $plan problems] {string cat "problem: " $p}]
        return 1
    }
    set shared {}
    foreach entry [dict get $plan libraries] {
        set text "  library [dict get $entry name]: [dict get $entry origin] [dict get $entry linkage] (instance[expr {[llength [dict get $entry instances]] > 1 ? "s" : ""}] [join [dict get $entry instances] {, }])"
        puts $text
        if {[dict get $entry verified]} {
            puts "    [dict get $entry facts]; [dict get $entry evidence][expr {[dict get $entry version] ne "" ? ", version [dict get $entry version]" : ""}]"
            puts "    [dict get $entry file]"
        } else {
            puts "    unverified on this host: $target's system must provide it"
        }
        if {[dict get $entry linkage] eq "shared"} {
            if {[dict get $entry identity] ne ""} {
                puts "    loads as [dict get $entry identity][expr {[dict get $entry needs] ne "" ? ", needs [join [dict get $entry needs] {, }]" : ""}]"
            }
            if {[dict get $entry glibc] ne ""} {
                puts "    requires GLIBC_[join [dict get $entry glibc] .] or newer on the target system"
            }
            if {[dict get $entry origin] eq "bundled"} {
                lappend shared [file tail [dict get $entry identity]]
            }
        }
    }
    foreach framework [dict get $plan frameworks] {
        puts "  framework [dict get $framework name]: system ([join [dict get $framework instances] {, }])"
    }
    if {[dict getdef $plan runtime {}] ne ""} {
        puts "  run time (opened by the program, never linked or loaded by the loader; installing never requires them):"
        foreach dependency [dict get $plan runtime] {
            set when [dict get $dependency requirement]
            switch -- $when {
                always { set when "always needed" }
                capability { set when "needed for \"[dict get $dependency capability]\"" }
                optional { set when "optional, used when present" }
            }
            puts "    [dict get $dependency kind] [dict get $dependency name][expr {[dict get $dependency identity] ne "" ? " ([dict get $dependency identity])" : ""}]: $when (instance [dict get $dependency instance][expr {[dict get $dependency loaded-by] ne "" ? ", opened by [dict get $dependency loaded-by]" : ""}])"
            puts "      [dict get $dependency purpose]"
            set candidate [dict get $dependency candidate]
            if {$candidate ne ""} {
                if {[dict get $candidate found]} {
                    puts "      this host: [dict get $candidate text] -- a candidate; whether it works is known only when the program uses it"
                } else {
                    puts "      this host: none ([dict get $candidate text]): [expr {[dict get $dependency requirement] eq "always" ? "the package's native code cannot run here" : "programs that use it fail when they do, and the others run"}]"
                }
            } elseif {[dict get $dependency kind] eq "facility"} {
                puts "      not a file: the package manager cannot verify it"
            } else {
                puts "      unverified on this host: $target's system must provide it where it is needed"
            }
        }
    }
    foreach header [dict get $plan headers] {
        puts "  headers ([dict get $header instance]): [dict get $header dir]"
    }
    Print [lmap n [dict get $plan notes] {string cat "note: " $n}]
    set lib [file join [dict get $result view] .lib]
    puts "link: the compiler links these from the target package tree (.bot_modules/.targets/$target[expr {[file isdirectory $lib] ? ", its .lib" : ""}]): no -L is needed for bundled libraries"
    if {$shared ne ""} {
        lassign [DeployLayout $target] sub runtime
        puts "deploy: $target's loader must find [join $shared {, }] at run time:"
        puts "  botlish native deploy -target $target -out DIR    places them in DIR[expr {$sub ne "." ? "/$sub" : ""}]"
        if {$runtime ne ""} {
            puts "  and link the executable with -runtime-path '$runtime' (the compiler's option), so it finds them wherever DIR is moved"
        } else {
            puts "  beside the executable: Windows' loader searches the application's directory first (never PATH)"
        }
        puts "  (a native backend's own run finds them in the target package tree without either)"
    }
    return 0
}

# Deploys TARGET's bundled shared libraries into DIR (-out): a transaction
# of its own, recorded in DIR/.botlish-deploy.json, which says which files
# of DIR the package manager placed. A file it did not place is never
# replaced (without -force); a failure, or an interruption the next deploy
# finds, restores the previous deployment.
proc pm::commands::native_deploy {words given} {
    if {$words ne ""} {
        pm::cli::UsageError "native deploy takes no arguments"
    }
    if {[Option $given -target] eq "" || [Option $given -out] eq ""} {
        pm::cli::UsageError "native deploy needs -target T and -out DIR"
    }
    set result [NativePlan $given]
    set target [dict get $result target]
    set plan [dict get $result plan]
    set out [file normalize [Option $given -out]]
    if {$plan eq ""} {
        puts "nothing to deploy: no installed package is target-specific"
        return 0
    }
    if {[dict get $plan problems] ne ""} {
        pm::Fail NATIVE "the native plan of $target has problems:
  [join [dict get $plan problems] "
  "]"
    }
    lassign [DeployLayout $target] sub runtime
    # What to place: every bundled shared library, under its loader identity.
    set placing [dict create]
    foreach entry [dict get $plan libraries] {
        if {[dict get $entry origin] ne "bundled" || [dict get $entry linkage] ne "shared"} continue
        set file [file tail [dict get $entry identity]]
        set relative [expr {$sub eq "." ? $file : "$sub/$file"}]
        dict set placing $relative [dict get $entry file]
    }
    file mkdir $out
    pm::deploy::Apply $out $placing [Flag $given -force]
    if {$placing eq ""} {
        puts "deploy $target: no bundled shared library (static and system libraries are not deployed)"
        return 0
    }
    foreach relative [lsort [dict keys $placing]] {
        puts "deployed $relative"
    }
    if {$runtime ne ""} {
        puts "link the executable into $out with -runtime-path '$runtime'"
    } else {
        puts "put the executable in $out, beside its DLLs"
    }
    if {[dict get [pm::target::facts $target] os] eq "macos"} {
        puts "note: sign the deployed libraries with the application (codesign): macOS arm64 loads only signed code, and the package manager signs nothing"
    }
    return 0
}

# ---------------------------------------------------------------------------
# The author's commands (PACKAGE-MANAGER-MILESTONE-3.md): native add,
# require and audit, package stage and compare

# The package directory an author's command works in: DIR (WORDS), else
# -package, else the current directory.
proc pm::commands::AuthorPackage {words given {positional 0}} {
    pm::authoring
    set dir [Option $given -package [pwd]]
    if {$positional && $words ne ""} {
        if {[llength $words] > 1 || [dict exists $given -package]} {
            pm::cli::UsageError "one package directory: DIR or -package DIR"
        }
        set dir [lindex $words 0]
    }
    return [pm::author::Open $dir]
}

proc pm::commands::OneTarget {given command} {
    set target [Option $given -target]
    if {$target eq ""} {
        pm::cli::UsageError "$command needs -target T: the target the file or dependency is"
    }
    return $target
}

proc pm::commands::native_add {words given} {
    if {[llength $words] != 1} {
        pm::cli::UsageError "native add takes one FILE: the built library to import"
    }
    set target [OneTarget $given "native add"]
    if {[Option $given -name] eq ""} {
        pm::cli::UsageError "native add needs -name N: the library's name as the package's extern c library \"N\" writes it (never read from a file name)"
    }
    if {[Option $given -linkage] ni {"" static shared}} {
        pm::cli::UsageError "-linkage is static or shared"
    }
    set license [Option $given -license -]
    set notices [expr {[dict exists $given -notice] ? [dict get $given -notice] : "-"}]
    if {$notices ne "-" && $license eq "-"} {
        pm::cli::UsageError "-notice names the files of a license: give -license too"
    }
    set pkg [AuthorPackage {} $given]
    set options [dict create target $target name [Option $given -name] linkage [Option $given -linkage] \
        as [Option $given -as] import [Option $given -import] \
        symbols [expr {[dict exists $given -symbol] ? [dict get $given -symbol] : "-"}] \
        license $license notices $notices replace [Flag $given -replace]]
    Print [pm::author::AddNative $pkg [file normalize [lindex $words 0]] $options]
    return 0
}

proc pm::commands::native_require {words given} {
    if {[llength $words] != 1} {
        pm::cli::UsageError "native require takes one NAME: the dependency's name"
    }
    set target [OneTarget $given "native require"]
    set origin [Option $given -origin]
    set runtime [Option $given -runtime]
    if {($origin eq "") == ($runtime eq "")} {
        pm::cli::UsageError "native require declares either a system library (-origin system) or a run-time dependency (-runtime always|capability|optional)"
    }
    if {$origin ne "" && $origin ne "system"} {
        pm::cli::UsageError "-origin is system here (a bundled library is a file: native add)"
    }
    if {$origin ne ""} {
        foreach option {-capability -purpose -kind -loaded-by} {
            if {[dict exists $given $option]} {
                pm::cli::UsageError "$option describes a run-time dependency (-runtime)"
            }
        }
    } else {
        foreach option {-linkage -version -pkg-config -symbol} {
            if {[dict exists $given $option]} {
                pm::cli::UsageError "$option describes a system library (-origin system); a run-time dependency is opened by the program, never linked"
            }
        }
    }
    set pkg [AuthorPackage {} $given]
    set name [lindex $words 0]
    if {[set problem [pm::targets::LibraryNameProblem $name]] ne ""} {
        pm::cli::UsageError $problem
    }
    set options [dict create target $target linkage [Option $given -linkage] identity [Option $given -identity] \
        version [Option $given -version] pkg-config [Option $given -pkg-config] \
        symbols [expr {[dict exists $given -symbol] ? [dict get $given -symbol] : "-"}] \
        runtime $runtime capability [Option $given -capability] purpose [Option $given -purpose] \
        kind [Option $given -kind] loaded-by [Option $given -loaded-by] replace [Flag $given -replace]]
    Print [pm::author::Require $pkg $name $options]
    return 0
}

proc pm::commands::native_audit {words given} {
    set pkg [AuthorPackage $words $given 1]
    set descriptor [dict get $pkg descriptor]
    set dir [dict get $pkg dir]
    if {![pm::targets::Aware $descriptor]} {
        puts "native audit of [dict get $descriptor name] ($dir): target-independent, no native metadata: nothing to audit"
        return 0
    }
    set target [Option $given -target]
    if {$target ne "" && ![dict exists $descriptor targets $target]} {
        pm::Fail UNSUPPORTED "[dict get $descriptor name] declares [join [pm::targets::Supported $descriptor] {, }], not $target"
    }
    set files [Collect $dir]
    set result [pm::author::Audit $files $descriptor [expr {$target eq "" ? "" : [list $target]}]]
    puts "native audit of [dict get $descriptor name] [dict get $descriptor version] ($dir), from this host ([pm::native::Or [pm::target::host]])"
    Print [pm::author::AuditLines $result]
    set packable [pm::author::Packable $result]
    puts [expr {$packable ? "audit: no problem that blocks packing (read, never run: the files' own headers and the author's statements)" : "audit: INCOMPLETE: package pack refuses it until the problems are resolved"}]
    return [expr {$packable ? 0 : 1}]
}

proc pm::commands::stage {words given} {
    set pkg [AuthorPackage $words $given 1]
    set kinds {}
    foreach kind {modules headers files} {
        if {[dict exists $given -$kind]} {
            lappend kinds $kind
        }
    }
    if {[llength $kinds] != 1} {
        pm::cli::UsageError "package stage stages one thing: -modules DIR, -headers DIR or -files DIR"
    }
    set kind [lindex $kinds 0]
    set targets [lsort -unique [dict getdef $given -target {}]]
    if {$targets eq "" && $kind ne "files"} {
        pm::cli::UsageError "-$kind needs -target T (any number): target modules and headers are staged per target; common files are the package's own (-files without -target)"
    }
    set options [dict create targets $targets kind $kind source [Option $given -$kind] as [Option $given -as] \
        replace [Flag $given -replace]]
    Print [pm::author::Stage $pkg $options]
    return 0
}

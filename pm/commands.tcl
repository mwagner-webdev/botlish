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
#   botlish package pack [DIR] [-out DIR] [-force]
#   botlish package inspect FILE.botpkg
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
        add {-request R -replace {} -project DIR -repository DIR -force {} -recover {}}
        install {-project DIR -repository DIR -force {} -recover {}}
        update {-project DIR -repository DIR -force {} -recover {}}
        remove {-project DIR -force {} -recover {}}
        verify {-project DIR -repository DIR}
        pack {-out DIR -force {}}
        inspect {}
    }
    variable commands {add install update remove verify package}
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
        "       $me package pack \[DIR\] \[-out DIR\] \[-force\]" \
        "       $me package inspect FILE.botpkg" \
        "" \
        "Options of add, install, update and remove:" \
        "  -project DIR       the project (the directory of its botlish.json);" \
        "                     default: the current directory" \
        "  -repository DIR    a local repository of NAME-VERSION.botpkg artifacts" \
        "                     (any number; never searched implicitly)" \
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
        if {$command ni {pack inspect}} {
            if {$command in {"" -help --help -h}} {
                puts [usage]
                return 0
            }
            UsageError "unknown package command \"$command\" (known: pack, inspect)"
        }
    }
    if {[lsearch -exact $rest -help] >= 0 || [lsearch -exact $rest --help] >= 0 || [lsearch -exact $rest -h] >= 0} {
        puts [usage]
        return 0
    }
    lassign [Parse $command $rest [dict get $options $command]] words given
    return [pm::commands::$command $words $given]
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
    foreach option {-project -request -out} {
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

proc pm::commands::install {words given} {
    if {$words ne ""} {
        pm::cli::UsageError "install takes no package names (found \"[lindex $words 0]\"): it installs what botlish.json locks; add adds a package"
    }
    Locked $given ctx {
        set state [pm::state::read [dict get $ctx meta]]
        set descriptor [pm::install::Descriptor $ctx]
        set plan [pm::install::Resolve $ctx $descriptor $state [Flag $given -force]]
        Print [pm::install::Apply $ctx $plan $state [Flag $given -force] ""]
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
        Print [pm::install::Apply $ctx $plan $state [Flag $given -force] $bytes]
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
        Print [pm::install::Apply $ctx $plan $state [Flag $given -force] $bytes]
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
        Print [pm::install::Apply $ctx $plan $state [Flag $given -force] $bytes]
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
    if {[file isdirectory $modules]} {
        foreach entry [pm::state::Entries $modules] {
            if {$entry eq ".botlish" || [dict exists $state $entry] || [dict exists $descriptor dependencies $entry]} continue
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
    set bytes [pm::archive::bytes $files]
    # The reader must accept what the writer made.
    set archive [pm::archive::fromBytes $bytes "the new artifact"]
    pm::descriptor::fromBytes [dict get $archive descriptor] artifact "the new artifact's botlish.json"
    set out [file normalize [Option $given -out $dir]]
    file mkdir $out
    set target [file join $out $name-$version.botpkg]
    set digest [pm::sha256::hex $bytes]
    if {[pm::Exists $target]} {
        if {[file type $target] ne "file"} {
            pm::Fail PACK "$target is a [file type $target], not an artifact file"
        }
        if {[pm::ReadBytes $target] eq $bytes} {
            puts "packed $name $version: $target (unchanged)"
            puts "  sha256 $digest"
            return 0
        }
        if {![Flag $given -force]} {
            pm::Fail EXISTS "$target already holds a different $name $version: a release is immutable. Raise the version, or pass -force to overwrite this local file"
        }
    }
    pm::ReplaceFile $target $bytes
    set size 0
    dict for {path content} $files {
        incr size [string length $content]
    }
    puts "packed $name $version: $target"
    puts "  sha256 $digest"
    puts "  [dict size $files] files, [string length $bytes] bytes ($size bytes unpacked)"
    if {![dict exists $files $name.bot] && [llength [lsearch -all -inline -glob [dict keys $files] $name/*.bot]] == 0} {
        puts "note: the package has no module of its namespace ($name.bot or $name/...): an import of $name names nothing in it"
    }
    if {[dict get $descriptor sources] ne ""} {
        puts "note: botlish.json's \"sources\" stay with this directory: an artifact never holds them"
    }
    return 0
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
    puts "(a valid .botpkg, format 1; its digest is computed here, and nothing authenticates who made it)"
    return 0
}

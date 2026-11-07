# tools.tcl -- external tools: schema 4's `tools` and the `tool` and `tools`
# commands (EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md; the
# normative specification is BOTLISH-TOOLS.md, and BOTLISH-JSON.md section
# 14 the key).
#
#   pm::tools::Parse VALUE PROBLEMSVAR      `tools`: dict NAME -> {protocol N
#                                           summary S programs {HOST PATH ...}
#                                           inputs {KIND...} environment {VAR...}}
#   pm::tools::Value TOOLS                  its canonical JSON value
#   pm::tools::Problems DESCRIPTOR FILES    the problems of the tools' programs
#                                           in an artifact's (or a package
#                                           directory's) FILES (PATH -> BYTES):
#                                           each a file, a native executable of
#                                           its host
#   pm::tools::Programs DESCRIPTOR          the paths of every tool program
#   pm::commands::tool, pm::commands::tools the commands
#
# A tool is a program a package carries, which a developer runs explicitly:
#
#   botlish tool [-project DIR] -out DIR [-artifact MANIFEST]... [-target T]
#                [-target-support NAME] [-report FILE] TOOL [ARG...]
#   botlish tools [-project DIR]
#
# Nothing else ever runs it: installing, updating, verifying or removing the
# package, importing its modules, compiling a program that uses them -- none
# of these runs any program of a package, and none writes an executable file
# (an installed package's files are never executable: BOTPKG-FORMAT.md). A
# tool runs only when `tool` names it, as a separate operating-system
# process with the user's own permissions: no sandbox, no capability
# restriction (BOTLISH-TOOLS.md, "Security").
#
# Resolution is explicit: TOOL is a short name (`emit-caller`) or a
# qualified one (`abi_tools:emit-caller`), and only the project's own direct
# dependencies -- the packages its botlish.json names -- provide runnable
# tools. A short name two of them declare is ambiguous and refused, never
# resolved by order; a tool only a transitive dependency declares is
# refused, naming the package to add.
#
# The invocation (protocol 1): the program for this host (`programs`, never
# the compilation target's: a host runs the tool, the target runs what it
# builds) is checked against the installation record, copied into a private
# temporary directory and made executable there, and started with the
# arguments after TOOL exactly as given -- through a fixed /bin/sh trampoline
# on Unix (each word a positional parameter, never shell text), since Tcl's
# exec reads words starting with <, >, | or 2> as redirections -- its
# standard streams the command's own, its working directory the command's,
# its environment the command's with BOTLISH_TOOL_REQUEST naming the request
# file (BOTLISH-TOOLS.md, "The request"). The project is locked while it
# runs, and the installation is checked afterwards: a tool that changed an
# installed package's files fails the command (TOOL-MODIFIED), whatever it
# returned.

namespace eval pm::tools {
    # The tool protocols this package manager speaks.
    variable protocols {1}
    variable nameRule {^[a-z][a-z0-9-]{0,63}$}
    variable keys {protocol summary programs inputs environment}
    # The input kinds protocol 1 knows (-artifact's).
    variable inputKinds {native-library}
    variable envRule {^[A-Za-z_][A-Za-z0-9_]{0,127}$}
    # The /bin/sh trampoline: every word after the script is the program
    # and its arguments, each prefixed with "x" (so that exec never reads
    # one as a redirection); the shell strips the one "x" of each and execs
    # the program with them, as positional parameters -- never shell text.
    variable trampoline {n=$#; while [ "$n" -gt 0 ]; do a=$1; shift; set -- "$@" "${a#x}"; n=$((n - 1)); done; exec "$@"}
}

# ---------------------------------------------------------------------------
# The declaration

proc pm::tools::NameProblem {name} {
    variable nameRule
    if {![regexp $nameRule $name]} {
        return "the tool name \"$name\" is not a tool name: a lowercase letter, then lowercase letters, digits and \"-\", at most 64 characters"
    }
    return ""
}

proc pm::tools::Parse {value problemsVar} {
    upvar 1 $problemsVar problems
    variable keys
    variable envRule
    set tools [dict create]
    if {[pm::json::type $value] ne "obj"} {
        lappend problems "\"tools\" must be an object of tool names"
        return $tools
    }
    set members [pm::json::payload $value]
    if {$members eq ""} {
        lappend problems "\"tools\" is empty: a package that provides no tool leaves \"tools\" out"
        return $tools
    }
    foreach {name spec} $members {
        set where "tools: \"$name\""
        if {[set problem [NameProblem $name]] ne ""} {
            lappend problems "tools: $problem"
            continue
        }
        if {[pm::json::type $spec] ne "obj"} {
            lappend problems "$where must be an object {\"protocol\": N, \"summary\": TEXT, \"programs\": {HOST: PATH}}"
            continue
        }
        set fields [pm::json::payload $spec]
        set tool [dict create protocol "" summary "" programs {} inputs {} environment {}]
        foreach {key item} $fields {
            if {$key ni $keys} {
                lappend problems "$where: unknown key \"$key\" (a tool has [join $keys {, }]; there is no script, hook or install step)"
            }
        }
        foreach key {protocol summary programs} {
            if {![dict exists $fields $key]} {
                lappend problems "$where: no \"$key\""
            }
        }
        if {[dict exists $fields protocol]} {
            set item [dict get $fields protocol]
            if {[pm::json::type $item] ne "num" || ![regexp {^[1-9][0-9]{0,8}$} [pm::json::payload $item]]} {
                lappend problems "$where: \"protocol\" must be a positive integer (the tool protocol it speaks: 1)"
            } else {
                dict set tool protocol [pm::json::payload $item]
            }
        }
        if {[dict exists $fields summary]} {
            set item [dict get $fields summary]
            if {[pm::json::type $item] ne "str"} {
                lappend problems "$where: \"summary\" must be a string"
            } else {
                set text [pm::json::payload $item]
                if {$text eq "" || [string length $text] > 300 || [regexp {[\x00-\x1f\x7f]} $text]} {
                    lappend problems "$where: \"summary\" is one line of 1 to 300 characters"
                } else {
                    dict set tool summary $text
                }
            }
        }
        if {[dict exists $fields programs]} {
            set item [dict get $fields programs]
            if {[pm::json::type $item] ne "obj" || [pm::json::payload $item] eq ""} {
                lappend problems "$where: \"programs\" must be a non-empty object HOST -> PATH: the tool's executable for each host it runs on"
            } else {
                foreach {host path} [pm::json::payload $item] {
                    if {![pm::target::isTarget $host]} {
                        lappend problems "$where: programs: \"$host\" is not a host (a compilation target's name: [join [pm::target::names] {, }])"
                        continue
                    }
                    if {[pm::json::type $path] ne "str"} {
                        lappend problems "$where: programs: \"$host\" must be an archive path"
                        continue
                    }
                    set path [pm::json::payload $path]
                    if {[set problem [pm::archive::pathProblem $path]] ne ""} {
                        lappend problems "$where: programs: \"$host\": $problem"
                        continue
                    }
                    if {$path eq "botlish.json"} {
                        lappend problems "$where: programs: \"$host\": botlish.json is no program"
                        continue
                    }
                    dict set tool programs $host $path
                }
            }
        }
        foreach key {inputs environment} {
            if {![dict exists $fields $key]} continue
            set item [dict get $fields $key]
            if {[pm::json::type $item] ne "arr"} {
                lappend problems "$where: \"$key\" must be an array of strings"
                continue
            }
            set list {}
            foreach element [pm::json::payload $item] {
                if {[pm::json::type $element] ne "str"} {
                    lappend problems "$where: \"$key\" holds a non-string"
                    continue
                }
                set text [pm::json::payload $element]
                if {$key eq "inputs" && ![regexp {^[a-z][a-z0-9-]{0,63}$} $text]} {
                    lappend problems "$where: inputs: \"$text\" is not an input kind (native-library)"
                    continue
                }
                if {$key eq "environment" && ![regexp $envRule $text]} {
                    lappend problems "$where: environment: \"$text\" is not an environment variable's name"
                    continue
                }
                if {$text in $list} {
                    lappend problems "$where: $key: \"$text\" is given twice"
                    continue
                }
                lappend list $text
            }
            dict set tool $key $list
        }
        dict set tools $name $tool
    }
    return $tools
}

proc pm::tools::Value {tools} {
    set object {}
    foreach name [lsort [dict keys $tools]] {
        set tool [dict get $tools $name]
        set members [list protocol [list num [dict get $tool protocol]] summary [list str [dict get $tool summary]]]
        set programs {}
        foreach host [lsort [dict keys [dict get $tool programs]]] {
            lappend programs $host [list str [dict get $tool programs $host]]
        }
        lappend members programs [list obj $programs]
        foreach key {inputs environment} {
            if {[dict get $tool $key] ne ""} {
                lappend members $key [list arr [lmap item [dict get $tool $key] {list str $item}]]
            }
        }
        lappend object $name [list obj $members]
    }
    return [list obj $object]
}

# Every program path of DESCRIPTOR's tools (the native files its tools
# declare).
proc pm::tools::Programs {descriptor} {
    set paths {}
    dict for {name tool} [dict getdef $descriptor tools {}] {
        dict for {host path} [dict get $tool programs] {
            lappend paths $path
        }
    }
    return [lsort -unique $paths]
}

# Why BYTES are not a native executable of HOST (a compilation target's
# name), or "".
proc pm::tools::ExecutableProblem {host bytes label} {
    set facts [pm::target::facts $host]
    if {[catch {pm::binary::inspect $bytes $label} found]} {
        return "$label is not a native executable: $found"
    }
    set kind [dict get $found kind]
    set want [dict get $facts format]
    set machine [dict get $facts machine]
    set what [pm::binary::describe $found]
    switch -- $kind {
        elf {
            if {$want eq "elf" && [dict get $found machine] == $machine
                    && ([dict get $found type] eq "program" || ([dict get $found type] eq "dyn" && [dict get $found interpreter] ne ""))} {
                return ""
            }
        }
        macho {
            if {$want eq "macho" && [dict get $found cputype] == $machine && [dict get $found filetype] eq "execute"} {
                return ""
            }
        }
        fat {
            if {$want eq "macho"} {
                foreach slice [dict get $found slices] {
                    if {[dict get $slice cputype] == $machine && [dict get [dict get $slice macho] filetype] eq "execute"} {
                        return ""
                    }
                }
            }
        }
        pe {
            if {$want eq "pe" && [dict get $found machine] == $machine && [dict get $found executable] && ![dict get $found dll]} {
                return ""
            }
        }
    }
    return "$label is $what, not an executable for $host ([dict get $facts os] [dict get $facts arch], [string toupper $want])"
}

# The problems of DESCRIPTOR's tools against FILES (PATH -> BYTES, an
# artifact's or a package directory's): each program is a file of the
# package and a native executable of its host.
proc pm::tools::Problems {descriptor files} {
    set problems {}
    dict for {name tool} [dict getdef $descriptor tools {}] {
        dict for {host path} [dict get $tool programs] {
            if {![dict exists $files $path]} {
                lappend problems "tools: \"$name\": its $host program $path is no file of the package"
                continue
            }
            set problem [ExecutableProblem $host [dict get $files $path] "tools: \"$name\": its $host program $path"]
            if {$problem ne ""} {
                lappend problems $problem
            }
        }
    }
    return $problems
}

# ---------------------------------------------------------------------------
# What a project's packages provide

# The tools the packages installed in CTX provide: a list of records {name
# package version protocol summary programs inputs environment direct dir
# kind record}, DIRECT 1 for the project's own dependencies. A package whose
# installed descriptor cannot be read is a {PM TOOL-INSTALLATION} error.
proc pm::tools::Installed {ctx descriptor} {
    set meta [dict get $ctx meta]
    set state [pm::state::read $meta]
    set direct [dict keys [dict get $descriptor dependencies]]
    set found {}
    foreach name [lsort [dict keys $state]] {
        set record [dict get $state $name]
        set dir [file join [dict get $ctx modules] $name]
        set path [file join $dir botlish.json]
        set context [expr {[dict get $record kind] eq "editable" ? "project" : "artifact"}]
        if {[catch {pm::descriptor::read $path $context} installed]} {
            pm::Fail TOOL-INSTALLATION "the installed package $name cannot be read ($installed): run verify, then install"
        }
        dict for {tool spec} [dict getdef $installed tools {}] {
            lappend found [dict merge $spec [dict create name $tool package $name version [dict get $record version] \
                direct [expr {$name in $direct}] dir $dir kind [dict get $record kind] record $record]]
        }
    }
    return $found
}

# The tool TOOL (a short or qualified name) among FOUND (Installed's).
proc pm::tools::Resolve {tool found} {
    if {[regexp {^([a-z][a-z0-9_]{0,63}):(.+)$} $tool -> package short]} {
        if {[set problem [NameProblem $short]] ne ""} {
            pm::Fail TOOL-UNKNOWN $problem
        }
        foreach entry $found {
            if {[dict get $entry package] eq $package && [dict get $entry name] eq $short} {
                if {![dict get $entry direct]} {
                    pm::Fail TOOL-NOT-DIRECT "$tool is a tool of $package, which is not one of the project's dependencies (another package depends on it): only the project's own dependencies provide the tools it runs -- add $package to them to run its tools"
                }
                return $entry
            }
        }
        if {![llength [lsearch -all -inline -index 0 [lmap e $found {list [dict get $e package]}] $package]]} {
            pm::Fail TOOL-UNKNOWN "no installed package $package provides tools (tools lists the project's)"
        }
        pm::Fail TOOL-UNKNOWN "the package $package declares no tool $short (tools lists the project's)"
    }
    if {[set problem [NameProblem $tool]] ne ""} {
        pm::Fail TOOL-UNKNOWN $problem
    }
    set direct {}
    set indirect {}
    foreach entry $found {
        if {[dict get $entry name] ne $tool} continue
        if {[dict get $entry direct]} {
            lappend direct $entry
        } else {
            lappend indirect $entry
        }
    }
    if {[llength $direct] == 1} {
        return [lindex $direct 0]
    }
    if {[llength $direct] > 1} {
        set names [lsort [lmap e $direct {string cat [dict get $e package] : $tool}]]
        pm::Fail TOOL-AMBIGUOUS "the tool $tool is declared by [llength $direct] of the project's dependencies: name the one to run ([join $names {, }]); no package's tool is preferred"
    }
    if {[llength $indirect]} {
        set packages [lsort -unique [lmap e $indirect {dict get $e package}]]
        pm::Fail TOOL-NOT-DIRECT "the tool $tool is declared only by [join $packages {, }], which [expr {[llength $packages] == 1 ? "is" : "are"}] not among the project's dependencies (another package depends on [expr {[llength $packages] == 1 ? "it" : "them"}]): only the project's own dependencies provide the tools it runs -- add [lindex $packages 0] to them to run its tools"
    }
    pm::Fail TOOL-UNKNOWN "no package of the project declares a tool $tool (tools lists the project's)"
}

# ---------------------------------------------------------------------------
# The commands

namespace eval pm::commands {}

# `tools`: the project's tools.
proc pm::commands::tools {words given} {
    if {$words ne ""} {
        pm::cli::UsageError "tools takes no arguments (found \"[lindex $words 0]\")"
    }
    set ctx [pm::install::Project [Option $given -project [pwd]]]
    set descriptor [pm::install::Descriptor $ctx]
    set found [pm::tools::Installed $ctx $descriptor]
    if {$found eq ""} {
        puts "tools: no installed package of [dict get $ctx project] provides a tool"
        return 0
    }
    set host [pm::target::host]
    foreach entry [lsort -command {apply {{a b} {string compare "[dict get $a package]:[dict get $a name]" "[dict get $b package]:[dict get $b name]"}}} $found] {
        set hosts [lsort [dict keys [dict get $entry programs]]]
        set line "[dict get $entry package]:[dict get $entry name] ([dict get $entry package] [dict get $entry version]), protocol [dict get $entry protocol], hosts [join $hosts {, }]"
        if {[dict get $entry inputs] ne ""} {
            append line ", inputs [join [dict get $entry inputs] {, }]"
        }
        puts $line
        puts "    [dict get $entry summary]"
        if {![dict get $entry direct]} {
            puts "    not runnable: [dict get $entry package] is not one of the project's dependencies"
        } elseif {[dict get $entry protocol] ni $::pm::tools::protocols} {
            puts "    not runnable: protocol [dict get $entry protocol] needs a newer Botlish (this one speaks [join $::pm::tools::protocols {, }])"
        } elseif {$host eq "" || ![dict exists $entry programs $host]} {
            puts "    not runnable on this host ([expr {$host eq "" ? "unknown" : $host}])"
        }
        foreach variable [dict get $entry environment] {
            puts "    reads \$$variable ([expr {[info exists ::env($variable)] ? "set" : "unset"}] here)"
        }
    }
    return 0
}

# `tool`: runs one tool. Its own options come before the tool's name; every
# word after it is the tool's.
proc pm::commands::tool {words given} {
    # pm::cli::Run hands the whole argument list over unparsed (words), so
    # that the tool's own words, options among them, are never read here.
    set options [dict create -project {} -out {} -artifact {} -target {} -target-support {} -report {}]
    set rest $words
    set name ""
    while {[llength $rest]} {
        set rest [lassign $rest arg]
        if {[string match -* $arg]} {
            if {$arg in {-help --help -h}} {
                puts [pm::cli::usage]
                return 0
            }
            if {![dict exists $options $arg]} {
                pm::cli::UsageError "unknown option \"$arg\" (tool's options, before the tool's name: [join [dict keys $options] {, }]; every word after the name is the tool's)"
            }
            if {![llength $rest]} {
                pm::cli::UsageError "option $arg needs an argument"
            }
            set rest [lassign $rest value]
            if {$arg ne "-artifact" && [dict get $options $arg] ne ""} {
                pm::cli::UsageError "$arg is given twice"
            }
            dict lappend options $arg $value
            continue
        }
        set name $arg
        break
    }
    if {$name eq ""} {
        pm::cli::UsageError "tool needs the name of the tool to run (tools lists the project's)"
    }
    if {[dict get $options -out] eq ""} {
        pm::cli::UsageError "tool needs -out DIR: the directory the tool writes its output into"
    }
    set target [lindex [dict get $options -target] 0]
    if {$target ne "" && ![pm::target::isTarget $target]} {
        pm::cli::UsageError "\"$target\" is not a compilation target (known: [join [pm::target::names] {, }])"
    }
    set report [lindex [dict get $options -report] 0]
    set outcome [dict create stage refused code "" message "" exit "" signal "" diagnostics {} changed {} tool "" package "" version ""]
    try {
        set status [pm::tools::Run $name $rest $options outcome]
    } on error {message errorOptions} {
        set code [dict get $errorOptions -errorcode]
        # The tool did not run (or could not be started): a refusal.
        dict set outcome stage refused
        dict set outcome code [lindex $code 1]
        dict set outcome message $message
        if {$report ne ""} {
            pm::tools::WriteReport $report $outcome
        }
        return -options $errorOptions $message
    }
    if {$report ne ""} {
        pm::tools::WriteReport $report $outcome
    }
    return $status
}

# Resolves, checks and runs the tool NAME with the arguments ARGS and the
# tool command's OPTIONS; the command's exit status. OUTCOMEVAR records what
# happened, for the report.
proc pm::tools::Run {name args options outcomeVar} {
    upvar 1 $outcomeVar outcome
    variable protocols
    variable inputKinds
    set ctx [pm::install::Project [lindex [concat [dict get $options -project] [list [pwd]]] 0]]
    set descriptor [pm::install::Descriptor $ctx]
    if {![file isfile [pm::state::Path [dict get $ctx meta]]]} {
        pm::Fail TOOL-NOT-INSTALLED "the project [dict get $ctx project] has no packages installed by the package manager: tools come from installed packages (run install)"
    }
    pm::install::Lock $ctx 0
    try {
        set entry [Resolve $name [Installed $ctx $descriptor]]
        set qualified [dict get $entry package]:[dict get $entry name]
        dict set outcome tool $qualified
        dict set outcome package [dict get $entry package]
        dict set outcome version [dict get $entry version]
        if {[dict get $entry protocol] ni $protocols} {
            pm::Fail TOOL-PROTOCOL "the tool $qualified ([dict get $entry package] [dict get $entry version]) speaks tool protocol [dict get $entry protocol], and this Botlish speaks [join $protocols {, }]: it needs a newer Botlish"
        }
        foreach kind [dict get $entry inputs] {
            if {$kind ni $inputKinds} {
                pm::Fail TOOL-PROTOCOL "the tool $qualified requires an input of kind \"$kind\", which protocol [dict get $entry protocol] does not have (it knows [join $inputKinds {, }])"
            }
        }
        set host [pm::target::host]
        if {$host eq "" || ![dict exists $entry programs $host]} {
            pm::Fail TOOL-HOST "the tool $qualified runs on [join [lsort [dict keys [dict get $entry programs]]] {, }], and this host is [expr {$host eq "" ? "none of the compiler's targets" : $host}]: its package carries no program for this host"
        }
        set relative [dict get $entry programs $host]
        set programPath [file join [dict get $entry dir] {*}[split $relative /]]
        if {[catch {file lstat $programPath stat}] || $stat(type) ne "file"} {
            pm::Fail TOOL-PROGRAM "the tool $qualified's $host program $relative is missing from [dict get $entry dir] (run verify)"
        }
        set bytes [pm::ReadBytes $programPath]
        if {[dict get $entry kind] eq "artifact"} {
            set files [dict get $entry record files]
            if {![dict exists $files $relative]} {
                pm::Fail TOOL-PROGRAM "the tool $qualified's program $relative is not a file of the installed [dict get $entry package] [dict get $entry version] (run verify)"
            }
            lassign [dict get $files $relative] size crc
            if {[string length $bytes] != $size || [format %08x [expr {[zlib crc32 $bytes] & 0xffffffff}]] ne $crc} {
                pm::Fail TOOL-PROGRAM "the tool $qualified's program .bot_modules/[dict get $entry package]/$relative was changed since it was installed: it is not run (verify reports the installation; install -force restores it)"
            }
        }
        set problem [ExecutableProblem $host $bytes "the tool $qualified's program $relative"]
        if {$problem ne ""} {
            pm::Fail TOOL-PROGRAM $problem
        }
        # Inputs.
        set target [lindex [dict get $options -target] 0]
        if {$target eq ""} {
            set target $host
        }
        set artifacts {}
        foreach manifest [dict get $options -artifact] {
            lappend artifacts [Artifact $manifest $target]
        }
        foreach kind [dict get $entry inputs] {
            set given 0
            foreach artifact $artifacts {
                if {[dict get $artifact kind] eq $kind} { set given 1 }
            }
            if {!$given} {
                pm::Fail TOOL-INPUT "the tool $qualified requires a $kind artifact: name its manifest with -artifact FILE (main.tcl -emit-native-library NAME writes NAME.manifest.json)"
            }
        }
        set support ""
        set supportName [lindex [dict get $options -target-support] 0]
        if {$supportName ne ""} {
            set support [Support $ctx $descriptor $supportName $target]
        }
        set out [file normalize [lindex [dict get $options -out] 0]]
        Output $ctx $out
        # The program, made executable in a private directory.
        set work [file tempdir]
        try {
            set program [file join $work [file tail $relative]]
            set channel [open $program {WRONLY CREAT EXCL BINARY}]
            puts -nonewline $channel $bytes
            close $channel
            if {$::tcl_platform(platform) eq "unix"} {
                file attributes $program -permissions 0700
                if {![file executable $program]} {
                    pm::Fail TOOL-EXEC "the tool $qualified cannot be run from the temporary directory $work (it does not allow execution: a noexec file system?): set TMPDIR to a directory that does"
                }
            }
            set request [file join $work request.json]
            set diagnostics [file join $work diagnostics.json]
            pm::WriteNew $request [Request $ctx $entry $program $host $target $out $artifacts $support $args $diagnostics]
            set meta [dict get $ctx meta]
            set record [list [pm::state::read $meta] [pm::state::views $meta]]
            set before [Snapshot $ctx $record]
            dict set outcome stage running
            lassign [Spawn $program $args $request] exit signal
            set after [Snapshot $ctx $record]
            set changed {}
            foreach change $after {
                if {$change ni $before} {
                    lappend changed $change
                }
            }
            dict set outcome exit $exit
            dict set outcome signal $signal
            dict set outcome changed $changed
            if {[file isfile $diagnostics]} {
                dict set outcome diagnostics [ReadDiagnostics $diagnostics]
                foreach d [dict get $outcome diagnostics] {
                    set where [dict get $d location]
                    puts stderr "$qualified: [dict get $d severity]: [expr {$where ne "" ? "$where: " : ""}][dict get $d message][expr {[dict get $d code] ne "" ? " ([dict get $d code])" : ""}]"
                }
            }
        } finally {
            file delete -force $work
        }
    } finally {
        pm::install::Unlock $ctx
    }
    if {$signal ne ""} {
        dict set outcome stage crashed
        if {$changed ne ""} {
            dict set outcome stage modified
        }
        set status 1
        puts stderr "error: the tool $qualified was ended by the signal $signal (PM TOOL-CRASHED)"
    } else {
        dict set outcome stage [expr {$exit == 0 ? "completed" : "failed"}]
        set status $exit
        if {$exit != 0} {
            puts stderr "tool $qualified ([dict get $entry package] [dict get $entry version]) exited with status $exit"
        }
    }
    if {$changed ne ""} {
        dict set outcome stage modified
        puts stderr "error: the tool $qualified changed the project's installed packages, which a tool never does:\n  [join $changed "\n  "]\n(verify reports the installation; install -force restores it) (PM TOOL-MODIFIED)"
        if {$status == 0} {
            set status 1
        }
    }
    return $status
}

# The input artifact whose manifest is MANIFEST (a native library's,
# NAME.manifest.json), checked for the compilation TARGET: its schema, kind
# and target, and every file it describes being the one it describes (its
# sha256). A record {kind native-library manifest PATH library NAME sha256
# DIGEST}.
proc pm::tools::Artifact {manifest target} {
    set path [file normalize $manifest]
    if {![file isfile $path]} {
        pm::Fail TOOL-ARTIFACT "no artifact manifest $path"
    }
    set bytes [pm::ReadBytes $path]
    if {[catch {pm::json::decode $bytes} value]} {
        pm::Fail TOOL-ARTIFACT "$path is no artifact manifest: $value"
    }
    set get {apply {{value key} {
        if {[pm::json::type $value] ne "obj" || ![dict exists [pm::json::payload $value] $key]} { return "" }
        return [dict get [pm::json::payload $value] $key]
    }}}
    if {[{*}$get $value kind] ne {str botlish-native-library}} {
        pm::Fail TOOL-ARTIFACT "$path is no native library manifest (its kind is not botlish-native-library)"
    }
    set schema [{*}$get $value schema]
    if {$schema ne {num 2}} {
        if {$schema eq {num 1}} {
            pm::Fail TOOL-ARTIFACT "$path is a schema 1 native library manifest, which records neither the files it describes nor their ownership: rebuild the library with this compiler (-emit-native-library)"
        }
        pm::Fail TOOL-ARTIFACT "$path is a native library manifest of schema [lindex $schema 1], and this Botlish reads schema 2"
    }
    set library [lindex [{*}$get $value library] 1]
    set built [lindex [{*}$get [{*}$get $value target] name] 1]
    if {$built ne $target} {
        pm::Fail TOOL-ARTIFACT "$path describes a library built for $built, and the tool runs for the target $target (-target)"
    }
    set dir [file dirname $path]
    set artifacts [{*}$get $value artifacts]
    set digests [{*}$get $value sha256]
    foreach key {static shared header} {
        set file [{*}$get $artifacts $key]
        if {[pm::json::type $file] ne "str"} continue
        set file [pm::json::payload $file]
        set full [file join $dir $file]
        set digest [{*}$get $digests $key]
        if {[pm::json::type $digest] ne "str" || ![regexp {^[0-9a-f]{64}$} [pm::json::payload $digest]]} {
            pm::Fail TOOL-ARTIFACT "$path records no SHA-256 of its $key file $file"
        }
        if {![file isfile $full]} {
            pm::Fail TOOL-ARTIFACT "$path describes the $key file $file, which is missing from $dir"
        }
        set actual [pm::sha256::file $full]
        if {$actual ne [pm::json::payload $digest]} {
            pm::Fail TOOL-ARTIFACT "$full is not the file $path describes (its SHA-256 is [pm::Short $actual]..., the manifest's [pm::Short [pm::json::payload $digest]]...): the manifest belongs to another build of $library"
        }
    }
    return [dict create kind native-library manifest $path library $library sha256 [pm::sha256::hex $bytes]]
}

# The target support package NAME of the project CTX for TARGET, as the
# request names it: an installed direct dependency. The compiler checks it
# when a compilation names it (native/support.tcl); here it is only found.
proc pm::tools::Support {ctx descriptor name target} {
    if {![dict exists $descriptor dependencies $name]} {
        pm::Fail TOOL-TARGET-SUPPORT "-target-support $name: $name is not one of the project's dependencies"
    }
    set state [pm::state::read [dict get $ctx meta]]
    if {![dict exists $state $name]} {
        pm::Fail TOOL-TARGET-SUPPORT "-target-support $name: $name is not installed (run install)"
    }
    set modules [dict get $ctx modules]
    set dir [file join $modules $name]
    if {[file isdirectory [file join $modules .targets]]} {
        set dir [file join $modules .targets $target $name]
    }
    if {![file isfile [file join $dir botlish-target-support.json]]} {
        pm::Fail TOOL-TARGET-SUPPORT "-target-support $name: the package $name supports no target $target (no [file join $dir botlish-target-support.json]: prepare the target view with install -target $target, or name a target support package)"
    }
    return [dict create package $name version [dict get $state $name version] directory $dir]
}

# Refuses OUT as a tool's output directory when it lies inside the
# project's .bot_modules (the installation, which no tool writes) or the
# compiler's own files; makes it.
proc pm::tools::Output {ctx out} {
    set modules [file normalize [dict get $ctx modules]]
    foreach {forbidden what} [list $modules "the project's installed packages" [file normalize $::pm::root] "the compiler's own files"] {
        if {$out eq $forbidden || [string first $forbidden/ $out/] == 0} {
            pm::Fail TOOL-OUTPUT "-out $out lies inside $what ($forbidden): a tool writes its output elsewhere"
        }
    }
    if {[pm::Exists $out] && [file type $out] ne "directory"} {
        pm::Fail TOOL-OUTPUT "-out $out is a [file type $out], not a directory"
    }
    file mkdir $out
}

# The request (protocol 1, BOTLISH-TOOLS.md "The request") as JSON bytes.
proc pm::tools::Request {ctx entry program host target out artifacts support args diagnostics} {
    set revision {null {}}
    set build [file join $::pm::root BUILD]
    if {[file isfile $build]} {
        foreach line [split [pm::ReadBytes $build] \n] {
            if {[regexp {^commit (.+)$} $line -> commit]} {
                set revision [list str $commit]
            }
        }
    }
    set command [list [info nameofexecutable]]
    if {![info exists ::single::app]} {
        lappend command [file join $::pm::root main.tcl]
    }
    set value [list obj [list \
        protocol {num 1} \
        kind {str botlish-tool-request} \
        tool [list obj [list name [list str [dict get $entry name]] package [list str [dict get $entry package]] \
            version [list str [dict get $entry version]] directory [list str [file normalize [dict get $entry dir]]] \
            program [list str $program]]] \
        compiler [list obj [list revision $revision command [list arr [lmap word $command {list str $word}]]]] \
        project [list str [dict get $ctx project]] \
        host [list str $host] \
        target [list str $target] \
        output [list str $out] \
        artifacts [list arr [lmap a $artifacts {
            list obj [list kind [list str [dict get $a kind]] manifest [list str [dict get $a manifest]] \
                library [list str [dict get $a library]] sha256 [list str [dict get $a sha256]]]
        }]] \
        targetSupport [if {$support eq ""} {list null {}} else {
            list obj [list package [list str [dict get $support package]] version [list str [dict get $support version]] \
                directory [list str [dict get $support directory]]]
        }] \
        environment [list arr [lmap variable [dict get $entry environment] {
            list obj [list name [list str $variable] set [list bool [info exists ::env($variable)]]]
        }]] \
        arguments [list arr [lmap word $args {list str $word}]] \
        diagnostics [list str $diagnostics]]]
    return [pm::json::encode $value]
}

# What the installation of CTX differs from RECORD by, now ({PACKAGES
# VIEWS}, the record as it was read before the tool ran): the changes of
# every installed package and target view, and the checksums of the files
# the package manager keeps (the record, the graph).
proc pm::tools::Snapshot {ctx record} {
    set meta [dict get $ctx meta]
    set modules [dict get $ctx modules]
    lassign $record packages views
    set changes {}
    dict for {name node} $packages {
        if {![dict exists $node children]} {
            dict set node children {}
        }
        lappend changes {*}[pm::state::Changes [file join $modules $name] $node .bot_modules/$name 0]
    }
    dict for {target view} $views {
        lappend changes {*}[pm::state::ViewChanges [file join $modules .targets $target] $view .bot_modules/.targets/$target]
    }
    foreach {path shown} [list [pm::state::Path $meta] .bot_modules/.botlish/state.json [file join $modules .graph] .bot_modules/.graph] {
        if {[pm::Exists $path]} {
            lappend changes "$shown [zlib crc32 [pm::ReadBytes $path]]"
        }
    }
    return [lsort $changes]
}

# Starts PROGRAM with the words ARGS, the request REQUEST in its
# environment, its standard streams this process's, and waits: {EXIT
# SIGNAL}, EXIT its status (when it exited), SIGNAL the signal's name that
# ended it (or "").
proc pm::tools::Spawn {program args request} {
    variable trampoline
    if {$::tcl_platform(platform) eq "unix"} {
        if {![file executable /bin/sh]} {
            pm::Fail TOOL-EXEC "/bin/sh, which starts a tool with its exact arguments, is missing"
        }
        set command [list /bin/sh -c $trampoline sh {*}[lmap word [list $program {*}$args] {string cat x $word}]]
    } else {
        # Windows: exec quotes every word for the C runtime's parser; it
        # reads a word starting with <, >, | or 2> as a redirection, and a
        # last word & as "in the background", which no word can escape.
        foreach word $args {
            if {[regexp {^(<|>|\||2>)} $word] || ($word eq "&" && $word eq [lindex $args end])} {
                pm::Fail TOOL-ARGUMENT "the argument \"$word\" cannot be passed to a tool on Windows (Tcl reads it as a redirection of the command line); the request file's \"arguments\" holds every argument exactly"
            }
        }
        set command [list $program {*}$args]
    }
    set saved [expr {[info exists ::env(BOTLISH_TOOL_REQUEST)] ? [list $::env(BOTLISH_TOOL_REQUEST)] : ""}]
    set ::env(BOTLISH_TOOL_REQUEST) $request
    try {
        flush stdout
        flush stderr
        if {[catch {exec {*}$command <@stdin >@stdout 2>@stderr} message options]} {
            set code [dict get $options -errorcode]
            switch -- [lindex $code 0] {
                CHILDSTATUS { return [list [lindex $code 2] ""] }
                CHILDKILLED { return [list "" [lindex $code 2]] }
                default { pm::Fail TOOL-EXEC "the tool $program could not be started: $message" }
            }
        }
        return [list 0 ""]
    } finally {
        if {$saved eq ""} {
            unset ::env(BOTLISH_TOOL_REQUEST)
        } else {
            set ::env(BOTLISH_TOOL_REQUEST) [lindex $saved 0]
        }
    }
}

# The structured diagnostics a tool wrote to PATH ({"diagnostics": [{
# "severity", "code", "message", "file", "line", "column"}]}): a list of
# dicts {severity code message location}; a file that is no such list is one
# note saying so.
proc pm::tools::ReadDiagnostics {path} {
    if {[catch {pm::json::decode [pm::ReadBytes $path]} value]
            || [pm::json::type $value] ne "obj" || ![dict exists [pm::json::payload $value] diagnostics]
            || [pm::json::type [dict get [pm::json::payload $value] diagnostics]] ne "arr"} {
        return [list [dict create severity note code "" message "the tool's diagnostics file is not {\"diagnostics\": \[...\]} (ignored)" location "" file "" line "" column ""]]
    }
    set result {}
    foreach item [pm::json::payload [dict get [pm::json::payload $value] diagnostics]] {
        set d [dict create severity error code "" message "" file "" line "" column ""]
        if {[pm::json::type $item] eq "obj"} {
            foreach {key v} [pm::json::payload $item] {
                if {$key in {severity code message file} && [pm::json::type $v] eq "str"} {
                    dict set d $key [pm::json::payload $v]
                } elseif {$key in {line column} && [pm::json::type $v] eq "num" && [string is digit -strict [pm::json::payload $v]]} {
                    dict set d $key [pm::json::payload $v]
                }
            }
        }
        if {[dict get $d severity] ni {error warning note}} {
            dict set d severity error
        }
        set location [dict get $d file]
        if {$location ne "" && [dict get $d line] ne ""} {
            append location :[dict get $d line]
            if {[dict get $d column] ne ""} {
                append location :[dict get $d column]
            }
        }
        dict set d location $location
        lappend result $d
    }
    return $result
}

# Writes the report of a tool command (-report FILE): what happened, as
# data (BOTLISH-TOOLS.md, "The report").
proc pm::tools::WriteReport {path outcome} {
    set nullable {apply {{value type} {
        if {$value eq ""} { return {null {}} }
        return [list $type $value]
    }}}
    set value [list obj [list \
        protocol {num 1} \
        kind {str botlish-tool-report} \
        tool [{*}$nullable [dict get $outcome tool] str] \
        package [{*}$nullable [dict get $outcome package] str] \
        version [{*}$nullable [dict get $outcome version] str] \
        stage [list str [dict get $outcome stage]] \
        code [{*}$nullable [dict get $outcome code] str] \
        message [{*}$nullable [dict get $outcome message] str] \
        exit [{*}$nullable [dict get $outcome exit] num] \
        signal [{*}$nullable [dict get $outcome signal] str] \
        diagnostics [list arr [lmap d [dict get $outcome diagnostics] {
            list obj [list severity [list str [dict get $d severity]] code [list str [dict get $d code]] \
                message [list str [dict get $d message]] location [list str [dict get $d location]]]
        }]] \
        packagesChanged [list arr [lmap c [dict get $outcome changed] {list str $c}]]]]
    set channel [open $path {WRONLY CREAT TRUNC BINARY}]
    puts -nonewline $channel [pm::json::encode $value]
    close $channel
}

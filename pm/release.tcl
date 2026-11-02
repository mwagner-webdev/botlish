# release.tcl -- a release's evidence: provenance records and the
# comparison of release candidates (PACKAGE-MANAGER-MILESTONE-3.md;
# BOTPKG-PROVENANCE.md, the normative record format).
#
#   pm::release::readEvidence PATH           the author's evidence file, validated
#   pm::release::record ARTIFACT EVIDENCE    the provenance record of a packed
#                                            artifact: {record VALUE lines {...}}
#   pm::release::encode RECORD               its canonical bytes
#   pm::release::readRecord PATH             a provenance record, validated
#   pm::release::check RECORD ARTIFACT       how a record and an artifact relate
#   pm::release::compare A B ?RA RB?         two release candidates, explained
#
# A provenance record is a file beside the artifact (NAME-VERSION.provenance.json),
# never inside it: it names the artifact by its SHA-256, which the artifact
# cannot contain. It holds three kinds of statement, kept apart:
#
#   * facts the package manager computed from the artifact's bytes when the
#     record was made: the artifact's digest and size, every file's digest,
#     each bundled native file's facts (format, machine, loader identity,
#     needs, GNU build ID, the compilers .comment names);
#   * the author's assertions (the evidence file): where the sources came
#     from (repository, Git commit, tree and tag), how the native files were
#     built (toolchain, flags, environment, image), copied as stated;
#   * checks of assertions the package manager could make without running
#     anything: a Git tree identity recomputed from the source files given
#     (SHA-1, Git's object format, no Git program), a source archive's or
#     patch's SHA-256, that every file a build names is in the artifact.
#     A check that fails stops the record from being written: an author's
#     statement the files contradict is never published.
#
# A record is evidence, not authentication: it is unsigned, made by
# whoever packed the artifact, and says nothing about whether the sources
# or the builder can be trusted. PM-4's signatures authenticate the
# artifact's bytes (and may cover a record's bytes too); PM-5 checks source
# history against earlier authenticated anchors. Nothing here decides
# either.

namespace eval pm::release {
    variable format 1
    variable evidenceFormat 1
    # The evidence file's grammar: KEY -> TYPE, `*` marking a required key.
    # Types: str, hex40, hex64, hexgit (40 or 64), local (a path on the
    # author's machine, used for a check and never recorded), target, path
    # (an artifact path, or a directory prefix ending in /), arr:T, map (an
    # object of strings), or a nested grammar's name.
    variable grammars {
        evidence {evidence* num1 package package sources arr:source builds arr:build generators arr:generator notes arr:str}
        package {name* str version* str}
        source {name* str role str repository str git git sha256 hex64 directory local archive local submodules arr:submodule patches arr:patch notes str}
        git {object-format* str commit hexgit tree hexgit tag str tag-object hexgit}
        submodule {path* str commit* hexgit}
        patch {name* str sha256 hex64 file local description str}
        build {name* str targets arr:target outputs* arr:path sources arr:str configuration str toolchain map flags arr:str environment map image str sysroot str inputs arr:input steps arr:str notes str}
        input {name* str sha256* hex64 source str}
        generator {name* str version str inputs arr:str outputs* arr:path command arr:str notes str}
    }
    variable trust "This record was made by whoever packed the artifact. Its computed facts were computed from the artifact's bytes when it was made; its assertions are the author's own statements, checked only where its checks say so. It is not a signature: it does not authenticate who made the artifact, and it does not show that the sources or the build environment can be trusted."
}

proc pm::release::Fail {kind message} {
    return -code error -errorcode [list PM $kind] $message
}

# ---------------------------------------------------------------------------
# The evidence file

# "" when TEXT can be published, else why not: no path of the author's
# machine (a home, a temporary or a cache directory, this user's home) and
# nothing shaped like a credential.
proc pm::release::PublishProblem {text} {
    set home ""
    catch {set home [file normalize ~]}
    if {[regexp {(^|[\s=:"'(,])(/home/|/root(/|$)|/tmp/|/Users/|/var/folders/|/private/var/|[A-Za-z]:[\\/][Uu]sers[\\/])} $text]
            || ($home ne "" && [string length $home] > 1 && [string first $home $text] >= 0)} {
        return "it holds a path of the machine that built the package: write paths relative to a named root (\$SOURCE, \$BUILD, \$CACHE) -- a record is published, and the path says nothing a consumer can use"
    }
    if {[regexp -- {-----BEGIN [A-Z ]*PRIVATE KEY-----|\mghp_[A-Za-z0-9]{20,}|\mgithub_pat_|\mxox[abpr]-|\mAKIA[0-9A-Z]{16}\M|\mglpat-} $text]} {
        return "it looks like a credential: a record is published"
    }
    return ""
}

# The value VALUE (pm/json.tcl's form) checked against TYPE; its Tcl form.
proc pm::release::Typed {value type where problemsVar} {
    upvar 1 $problemsVar problems
    variable grammars
    if {[string match arr:* $type]} {
        if {[pm::json::type $value] ne "arr"} {
            lappend problems "$where must be an array"
            return {}
        }
        set out {}
        set i 0
        foreach item [pm::json::payload $value] {
            lappend out [Typed $item [string range $type 4 end] "$where\[$i\]" problems]
            incr i
        }
        return $out
    }
    if {$type eq "map"} {
        if {[pm::json::type $value] ne "obj"} {
            lappend problems "$where must be an object of strings"
            return {}
        }
        set out [dict create]
        foreach {key item} [pm::json::payload $value] {
            if {[pm::json::type $item] ne "str"} {
                lappend problems "$where: \"$key\" must be a string"
                continue
            }
            if {[regexp -nocase {token|secret|passw|credential|private.?key|api.?key|auth|cookie|session} $key]} {
                lappend problems "$where: \"$key\" names a credential: a record is published, and a secret is never part of one"
                continue
            }
            if {[set problem [PublishProblem $key=[pm::json::payload $item]]] ne ""} {
                lappend problems "$where: \"$key\": $problem"
                continue
            }
            dict set out $key [pm::json::payload $item]
        }
        return $out
    }
    if {[dict exists $grammars $type]} {
        return [Object $value $type $where problems]
    }
    if {$type eq "num1"} {
        if {[pm::json::type $value] ne "num" || [pm::json::payload $value] ne "1"} {
            lappend problems "$where must be 1 (this package manager reads evidence format 1)"
        }
        return 1
    }
    if {[pm::json::type $value] ne "str"} {
        lappend problems "$where must be a string"
        return ""
    }
    set text [pm::json::payload $value]
    switch -- $type {
        hex40 { set ok [regexp {^[0-9a-f]{40}$} $text] }
        hex64 { set ok [regexp {^[0-9a-f]{64}$} $text] }
        hexgit { set ok [regexp {^([0-9a-f]{40}|[0-9a-f]{64})$} $text] }
        target { set ok [pm::target::isTarget $text] }
        path {
            set bare [string trimright $text /]
            set ok [expr {$bare ne "" && [pm::archive::pathProblem $bare] eq ""}]
        }
        local { return $text }
        default { set ok 1 }
    }
    if {!$ok} {
        lappend problems "$where: \"$text\" is not [dict get {hex40 {a 40-digit lowercase hexadecimal identity} hex64 {a SHA-256 digest (64 lowercase hexadecimal digits)} hexgit {a Git object identity (40 or 64 lowercase hexadecimal digits)} target {a compilation target} path {a path of the artifact (or a directory of it, ending in /)}} $type]"
    } elseif {[set problem [PublishProblem $text]] ne ""} {
        lappend problems "$where: $problem"
    }
    return $text
}

proc pm::release::Object {value grammar where problemsVar} {
    upvar 1 $problemsVar problems
    variable grammars
    set spec [dict get $grammars $grammar]
    if {[pm::json::type $value] ne "obj"} {
        lappend problems "$where must be an object"
        return {}
    }
    set keys {}
    foreach {key type} $spec {
        lappend keys [string trimright $key *]
    }
    set out [dict create]
    foreach {key item} [pm::json::payload $value] {
        set index [lsearch -exact $keys $key]
        if {$index < 0} {
            lappend problems "$where: unknown key \"$key\" ([join $keys {, }])"
            continue
        }
        dict set out $key [Typed $item [lindex $spec [expr {$index * 2 + 1}]] "$where.$key" problems]
    }
    foreach {key type} $spec {
        if {[string index $key end] eq "*" && ![dict exists $out [string trimright $key *]]} {
            lappend problems "$where: no \"[string trimright $key *]\""
        }
    }
    return $out
}

# The evidence file PATH: the author's statements about a release, validated
# (unknown keys, malformed identities, host paths and credentials refused).
# Local paths in it (directory, archive, file) are relative to the file's
# own directory unless absolute; they are read for checks and never
# recorded.
proc pm::release::readEvidence {path} {
    if {![file isfile $path]} {
        Fail EVIDENCE "no evidence file $path"
    }
    if {[catch {pm::json::decode [pm::ReadBytes $path]} value]} {
        Fail EVIDENCE "$path: $value"
    }
    set problems {}
    set evidence [Object $value evidence evidence problems]
    if {$problems ne ""} {
        Fail EVIDENCE "$path:\n  [join $problems "\n  "]"
    }
    dict set evidence base [file dirname [file normalize $path]]
    # Names are unique, and builds name sources the evidence has.
    set names {}
    foreach source [dict getdef $evidence sources {}] {
        if {[dict get $source name] in $names} {
            lappend problems "sources: \"[dict get $source name]\" is named twice"
        }
        lappend names [dict get $source name]
        if {[dict exists $source git] && [dict get $source git object-format] ni {sha1 sha256}} {
            lappend problems "sources: \"[dict get $source name]\": git.object-format is sha1 or sha256"
        }
    }
    foreach build [dict getdef $evidence builds {}] {
        foreach name [dict getdef $build sources {}] {
            if {$name ni $names} {
                lappend problems "builds: \"[dict get $build name]\" names the source $name, which the evidence does not describe"
            }
        }
    }
    if {$problems ne ""} {
        Fail EVIDENCE "$path:\n  [join $problems "\n  "]"
    }
    return $evidence
}

proc pm::release::Local {evidence path} {
    if {[file pathtype $path] ne "absolute"} {
        set path [file join [dict get $evidence base] $path]
    }
    return [file normalize $path]
}

# ---------------------------------------------------------------------------
# Git trees, computed from files (no Git program, no repository)

# The .gitattributes rules of the directory DIR (RELATIVE in the tree):
# {PATTERN ATTRIBUTES BASE} each, in order.
proc pm::release::Attributes {dir relative} {
    set path [file join $dir .gitattributes]
    if {![file isfile $path]} {
        return {}
    }
    set rules {}
    foreach line [split [pm::ReadBytes $path] \n] {
        set line [string trim $line]
        if {$line eq "" || [string index $line 0] eq "#"} continue
        set words [regexp -all -inline {\S+} $line]
        lappend rules [list [lindex $words 0] [lrange $words 1 end] $relative]
    }
    return $rules
}

# The text conversion Git's "clean" direction applies to the file PATH
# (relative to the tree) under RULES: "crlf" (CRLF to LF), "auto" (the same
# when the content has no NUL) or "".
proc pm::release::Conversion {rules path} {
    set text ""
    set eol ""
    set name [file tail $path]
    foreach rule $rules {
        lassign $rule pattern attributes base
        set below [expr {$base eq "" ? $path : [string range $path [string length $base/] end]}]
        if {$base ne "" && [string first $base/ $path] != 0} continue
        set pattern [string trimleft $pattern /]
        set matches [expr {[string first / $pattern] < 0 ? [string match $pattern $name] : [string match $pattern $below]}]
        if {!$matches} continue
        foreach attribute $attributes {
            switch -glob -- $attribute {
                text { set text set }
                -text - binary { set text unset }
                text=auto { set text auto }
                !text { set text "" }
                eol=* { set eol [string range $attribute 4 end] }
                crlf { set text set }
                -crlf { set text unset }
            }
        }
    }
    if {$text eq "unset"} {
        return ""
    }
    if {$text eq "set" || $eol ne ""} {
        return crlf
    }
    if {$text eq "auto"} {
        return auto
    }
    return ""
}

# The Git tree object identity (SHA-1, Git's default object format) of the
# files under DIR, as `git add` of a clean checkout would make it: regular
# files as blobs (mode 100644, or 100755 when executable), symbolic links as
# blobs of their targets (120000), directories as trees (40000; empty ones
# omitted, as Git tracks none), the gitlinks SUBMODULES ({PATH COMMIT ...})
# as 160000, .git left out, and .gitattributes' text conversions applied
# (CRLF to LF where `text`, `eol` or `text=auto` say so). {tree HEX files N}.
proc pm::release::GitTree {dir {submodules {}}} {
    set count 0
    set tree [GitTreeOf $dir "" $submodules {} count]
    if {$tree eq ""} {
        Fail EVIDENCE "$dir holds no file"
    }
    return [dict create tree $tree files $count]
}

proc pm::release::GitTreeOf {dir relative submodules rules countVar} {
    upvar 1 $countVar count
    set here [file join $dir {*}[split $relative /]]
    set rules [concat $rules [Attributes $here $relative]]
    set entries {}
    foreach name [pm::state::Entries $here] {
        if {$relative eq "" && $name eq ".git"} continue
        set path [expr {$relative eq "" ? $name : "$relative/$name"}]
        set full [file join $here $name]
        set type [file type $full]
        if {[dict exists $submodules $path]} {
            lappend entries [list $name 160000 [dict get $submodules $path] 0]
            continue
        }
        switch -- $type {
            directory {
                set sub [GitTreeOf $dir $path $submodules $rules count]
                if {$sub ne ""} {
                    lappend entries [list $name 40000 $sub 1]
                }
            }
            link {
                set target [encoding convertto utf-8 [file readlink $full]]
                lappend entries [list $name 120000 [pm::sha1::hex "blob [string length $target]\x00$target"] 0]
                incr count
            }
            file {
                set bytes [pm::ReadBytes $full]
                switch -- [Conversion $rules $path] {
                    crlf { set bytes [string map [list \r\n \n] $bytes] }
                    auto {
                        if {[string first \x00 [string range $bytes 0 7999]] < 0} {
                            set bytes [string map [list \r\n \n] $bytes]
                        }
                    }
                }
                set mode 100644
                if {$::tcl_platform(platform) eq "unix" && ([file attributes $full -permissions] & 0o100)} {
                    set mode 100755
                }
                lappend entries [list $name $mode [pm::sha1::hex "blob [string length $bytes]\x00$bytes"] 0]
                incr count
            }
            default {
                Fail EVIDENCE "$full is a $type: a Git tree holds files, links and directories"
            }
        }
    }
    if {$entries eq ""} {
        return ""
    }
    # Git orders a tree's entries by name, a directory's as if it ended in /.
    set keyed [lmap entry $entries {
        list [encoding convertto utf-8 [lindex $entry 0]][expr {[lindex $entry 3] ? "/" : ""}] $entry
    }]
    set content ""
    foreach item [lsort -ascii -index 0 $keyed] {
        lassign [lindex $item 1] name mode id
        append content "$mode [encoding convertto utf-8 $name]\x00[binary decode hex $id]"
    }
    return [pm::sha1::hex "tree [string length $content]\x00$content"]
}

# The SHA-256 of a directory's files as a list, a Botlish identity of exactly
# the bytes given (no conversion): "MODE SIZE SHA256 PATH\n" per file, by
# path. {sha256 HEX files N bytes N}.
proc pm::release::FilesDigest {dir} {
    set lines {}
    set bytes 0
    FilesDigestOf $dir "" lines bytes
    set lines [lsort $lines]
    return [dict create sha256 [pm::sha256::hex [encoding convertto utf-8 [join $lines ""]]] files [llength $lines] bytes $bytes]
}

proc pm::release::FilesDigestOf {dir relative linesVar bytesVar} {
    upvar 1 $linesVar lines $bytesVar bytes
    set here [file join $dir {*}[split $relative /]]
    foreach name [pm::state::Entries $here] {
        if {$relative eq "" && $name eq ".git"} continue
        set path [expr {$relative eq "" ? $name : "$relative/$name"}]
        set full [file join $here $name]
        switch -- [file type $full] {
            directory { FilesDigestOf $dir $path lines bytes }
            link { lappend lines "120000 0 [pm::sha256::hex [encoding convertto utf-8 [file readlink $full]]] $path\n" }
            file {
                set mode [expr {$::tcl_platform(platform) eq "unix" && ([file attributes $full -permissions] & 0o100) ? "100755" : "100644"}]
                set size [file size $full]
                incr bytes $size
                lappend lines "$mode $size [pm::sha256::file $full] $path\n"
            }
        }
    }
}

# ---------------------------------------------------------------------------
# The record

# JSON helpers: values of pm/json.tcl's form.
proc pm::release::S {text} { return [list str $text] }
proc pm::release::N {number} { return [list num $number] }
proc pm::release::A {items} { return [list arr $items] }
proc pm::release::SA {items} { return [list arr [lmap item $items {list str $item}]] }

# The JSON value of the evidence item ITEM of GRAMMAR, local paths left out,
# keys in the grammar's order.
proc pm::release::Asserted {item grammar} {
    variable grammars
    set fields {}
    foreach {key type} [dict get $grammars $grammar] {
        set key [string trimright $key *]
        if {![dict exists $item $key] || $type eq "local"} continue
        set v [dict get $item $key]
        if {[string match arr:* $type]} {
            set inner [string range $type 4 end]
            if {[dict exists $grammars $inner]} {
                lappend fields $key [A [lmap x $v {Asserted $x $inner}]]
            } else {
                lappend fields $key [SA $v]
            }
        } elseif {$type eq "map"} {
            lappend fields $key [list obj [concat {*}[lmap k [lsort [dict keys $v]] {list $k [S [dict get $v $k]]}]]]
        } elseif {[dict exists $grammars $type]} {
            lappend fields $key [Asserted $v $type]
        } else {
            lappend fields $key [S $v]
        }
    }
    return [list obj $fields]
}

# The provenance record of the artifact whose bytes are BYTES (the file
# FILENAME, already validated: its files FILES, its DESCRIPTOR), with the
# author's EVIDENCE (readEvidence; "" for none): {record VALUE lines
# {REPORT...}}, or {PM PROVENANCE} when a check contradicts an assertion.
proc pm::release::record {bytes filename files descriptor evidence} {
    variable format
    variable trust
    set digest [pm::sha256::hex $bytes]
    set lines {}
    set checks {}
    set problems {}
    if {$evidence ne "" && [dict exists $evidence package]} {
        foreach key {name version} {
            if {[dict get $evidence package $key] ne [dict get $descriptor $key]} {
                lappend problems "the evidence describes [dict get $evidence package name] [dict get $evidence package version], and the artifact is [dict get $descriptor name] [dict get $descriptor version]"
                break
            }
        }
    }
    # Computed: the artifact and its files.
    set targets [pm::targets::Supported $descriptor]
    set subject [list obj [list name [S [dict get $descriptor name]] version [S [dict get $descriptor version]] \
        artifact [S $filename] sha256 [S $digest] size [N [string length $bytes]] format [N 1] \
        schema [N [dict get $descriptor schema]] targets [SA $targets]]]
    set contents {}
    foreach path [lsort [dict keys $files]] {
        lappend contents [list obj [list path [S $path] size [N [string length [dict get $files $path]]] sha256 [S [pm::sha256::hex [dict get $files $path]]]]]
    }
    set native [NativeFacts $files $descriptor]
    # Asserted, and checked where it can be.
    set sources {}
    set builds {}
    set generators {}
    if {$evidence ne ""} {
        foreach source [dict getdef $evidence sources {}] {
            set name [dict get $source name]
            lappend sources [Asserted $source source]
            if {[dict exists $source directory]} {
                set dir [Local $evidence [dict get $source directory]]
                if {![file isdirectory $dir]} {
                    lappend problems "source $name: its directory $dir does not exist"
                    continue
                }
                set given [FilesDigest $dir]
                lappend checks [Check "source $name" files [dict get $given sha256] computed \
                    "SHA-256 of the list of the [dict get $given files] files given ([dict get $given bytes] bytes): each file's mode, size, SHA-256 and path, .git left out"]
                if {[dict exists $source git tree]} {
                    if {[dict get $source git object-format] ne "sha1"} {
                        lappend checks [Check "source $name" git-tree [dict get $source git tree] "not checked" \
                            "a SHA-256 Git object format: this package manager computes SHA-1 trees only"]
                    } else {
                        set submodules [dict create]
                        foreach submodule [dict getdef $source submodules {}] {
                            dict set submodules [dict get $submodule path] [dict get $submodule commit]
                        }
                        set computed [GitTree $dir $submodules]
                        if {[dict get $computed tree] ne [dict get $source git tree]} {
                            lappend problems "source $name: the Git tree computed from $dir is [dict get $computed tree], and the evidence asserts [dict get $source git tree] (a modified or incomplete checkout, untracked files, or a working-tree conversion this check does not model; give the exact checkout, or leave \"directory\" out to make the tree an unchecked assertion)"
                        } else {
                            lappend checks [Check "source $name" git-tree [dict get $computed tree] confirmed \
                                "the Git tree object computed from the [dict get $computed files] files given equals the asserted tree (SHA-1 objects as git add makes them, .gitattributes' text conversions applied; no Git program run, no repository read)"]
                        }
                    }
                }
            }
            if {[dict exists $source archive]} {
                set file [Local $evidence [dict get $source archive]]
                if {![file isfile $file]} {
                    lappend problems "source $name: its archive $file does not exist"
                } else {
                    set sha [pm::sha256::file $file]
                    if {[dict exists $source sha256]} {
                        if {$sha ne [dict get $source sha256]} {
                            lappend problems "source $name: the archive given has SHA-256 $sha, and the evidence asserts [dict get $source sha256]"
                        } else {
                            lappend checks [Check "source $name" sha256 $sha confirmed "SHA-256 of the source archive given ([file size $file] bytes)"]
                        }
                    } else {
                        lappend checks [Check "source $name" sha256 $sha computed "SHA-256 of the source archive given ([file size $file] bytes)"]
                    }
                }
            }
            foreach patch [dict getdef $source patches {}] {
                if {![dict exists $patch file]} continue
                set file [Local $evidence [dict get $patch file]]
                if {![file isfile $file]} {
                    lappend problems "source $name: patch [dict get $patch name]: $file does not exist"
                    continue
                }
                set sha [pm::sha256::file $file]
                if {[dict exists $patch sha256] && $sha ne [dict get $patch sha256]} {
                    lappend problems "source $name: patch [dict get $patch name] has SHA-256 $sha, and the evidence asserts [dict get $patch sha256]"
                } else {
                    lappend checks [Check "source $name" "patch [dict get $patch name]" $sha [expr {[dict exists $patch sha256] ? "confirmed" : "computed"}] "SHA-256 of the patch file given"]
                }
            }
        }
        foreach build [dict getdef $evidence builds {}] {
            lappend builds [Asserted $build build]
            foreach output [dict get $build outputs] {
                set found [OutputFiles $files $output]
                if {$found eq ""} {
                    lappend problems "build [dict get $build name]: its output $output is no file of the artifact"
                    continue
                }
                lappend checks [Check "build [dict get $build name]" "output $output" [DigestOfFiles $files $found] confirmed \
                    "the artifact holds [llength $found] file[expr {[llength $found] == 1 ? "" : "s"}] the build names (the value: [expr {[llength $found] == 1 ? "its SHA-256" : "the SHA-256 of their paths' and digests' list"}]); that the build made them is the author's statement"]
            }
            foreach target [dict getdef $build targets {}] {
                if {$target ni $targets && $targets ne "*"} {
                    lappend problems "build [dict get $build name] names the target $target, which the package does not support"
                }
            }
        }
        foreach generator [dict getdef $evidence generators {}] {
            lappend generators [Asserted $generator generator]
            foreach output [dict get $generator outputs] {
                set found [OutputFiles $files $output]
                if {$found eq ""} {
                    lappend problems "generator [dict get $generator name]: its output $output is no file of the artifact"
                    continue
                }
                lappend checks [Check "generator [dict get $generator name]" "output $output" [DigestOfFiles $files $found] confirmed \
                    "the artifact holds the [llength $found] file[expr {[llength $found] == 1 ? "" : "s"}] the generator names; that it generated them is the author's statement"]
            }
        }
    }
    if {$problems ne ""} {
        Fail PROVENANCE "the evidence and the artifact disagree, and no record is written:\n  [join $problems "\n  "]"
    }
    set value [list obj [list \
        provenance [N $format] \
        subject $subject \
        producer [list obj [list tool [S "botlish package manager"] sources-sha256 [S [ProducerDigest]]]] \
        contents [A $contents] \
        native [A $native] \
        sources [A $sources] \
        builds [A $builds] \
        generators [A $generators] \
        checks [A $checks] \
        notes [SA [expr {$evidence eq "" ? {} : [dict getdef $evidence notes {}]}]] \
        trust [S $trust]]]
    lappend lines "  provenance: [llength $contents] files and [llength $native] native files computed; [llength $sources] source(s), [llength $builds] build(s), [llength $generators] generator(s) asserted; [llength $checks] check(s) made"
    foreach check $checks {
        set fields [lindex $check 1]
        lappend lines "    [lindex [dict get $fields subject] 1] [lindex [dict get $fields fact] 1]: [lindex [dict get $fields result] 1]"
    }
    return [dict create record $value lines $lines]
}

proc pm::release::Check {subject fact value result method} {
    return [list obj [list subject [S $subject] fact [S $fact] value [S $value] result [S $result] method [S $method]]]
}

# The artifact paths FILES has for the output OUTPUT (a file, or a directory
# prefix ending in /).
proc pm::release::OutputFiles {files output} {
    if {[string index $output end] eq "/"} {
        return [lsort [lsearch -all -inline -glob [dict keys $files] $output*]]
    }
    if {[dict exists $files $output]} {
        return [list $output]
    }
    return {}
}

proc pm::release::DigestOfFiles {files paths} {
    if {[llength $paths] == 1} {
        return [pm::sha256::hex [dict get $files [lindex $paths 0]]]
    }
    set lines {}
    foreach path $paths {
        lappend lines "[pm::sha256::hex [dict get $files $path]] $path\n"
    }
    return [pm::sha256::hex [encoding convertto utf-8 [join $lines ""]]]
}

# A digest of the package manager's own sources: which producer made a
# record (it changes with them; two records of one artifact may differ in
# it alone).
proc pm::release::ProducerDigest {} {
    set lines {}
    foreach path [lsort [glob -directory [file join $::pm::root pm] *.tcl]] {
        lappend lines "[pm::sha256::hex [pm::ReadBytes $path]] [file tail $path]\n"
    }
    return [pm::sha256::hex [encoding convertto utf-8 [join $lines ""]]]
}

# The computed facts of every bundled native file of every target.
proc pm::release::NativeFacts {files descriptor} {
    set out {}
    if {![pm::targets::Aware $descriptor]} {
        return $out
    }
    foreach target [lsort [dict keys [dict get $descriptor targets]]] {
        set view [pm::targets::Map $descriptor $target [dict keys $files]]
        foreach library [dict get $descriptor targets $target libraries] {
            if {[dict get $library origin] ne "bundled" || ![dict exists $view [dict get $library file]]} continue
            set path [dict get $view [dict get $library file]]
            set bytes [dict get $files $path]
            set facts [pm::binary::inspect $bytes $path]
            set selected [pm::native::Slice $target $facts]
            if {$selected eq ""} { set selected $facts }
            set fields [list target [S $target] library [S [dict get $library name]] linkage [S [dict get $library linkage]] \
                path [S $path] sha256 [S [pm::sha256::hex $bytes]] description [S [pm::binary::describe $selected]]]
            if {[dict get $library linkage] eq "shared"} {
                lappend fields identity [S [dict get $library identity]] needs [SA [dict get $library needs]]
            }
            if {[dict get $selected kind] eq "elf" && [dict get $selected class] == 64 && [dict get $selected endian] eq "le"} {
                set sections [pm::binary::elfSections $bytes $path]
                lappend fields build-id [S [dict get $sections buildid]] compilers [SA [dict get $sections comment]]
                lappend fields runtime-search-path [SA [concat [dict get $selected runpath] [dict get $selected rpath]]]
                set glibc [pm::native::Highest [dict getdef [dict get $selected verneed] libc.so.6 {}] GLIBC_]
                if {$glibc ne ""} { lappend fields glibc [S [join $glibc .]] }
            } elseif {[dict get $selected kind] eq "archive"} {
                set members [ArMembers $bytes $path]
                lappend fields members [A [lmap member $members {list obj [list name [S [dict get $member name]] size [N [dict get $member size]] sha256 [S [dict get $member sha256]]]}]]
                set compilers {}
                foreach member $members {
                    if {[string range [dict get $member data] 0 3] eq "\x7fELF"} {
                        catch {lappend compilers {*}[dict get [pm::binary::elfSections [dict get $member data] $path] comment]}
                    }
                }
                lappend fields compilers [SA [lsort -unique $compilers]]
            }
            lappend out [list obj $fields]
        }
    }
    return $out
}

# The members of the ar archive BYTES: {name N size S sha256 D data BYTES}
# each, in order (the symbol index and GNU's long-name table left out).
proc pm::release::ArMembers {bytes label} {
    if {[string range $bytes 0 7] ne "!<arch>\n"} {
        Fail BINARY "$label is not an ar archive"
    }
    set members {}
    set names ""
    set at 8
    set length [string length $bytes]
    while {$at + 60 <= $length} {
        set header [string range $bytes $at [expr {$at + 59}]]
        set name [string trimright [string range $header 0 15]]
        set size [string trim [string range $header 48 57]]
        if {![string is digit -strict $size]} {
            Fail BINARY "$label: a malformed member header at offset $at"
        }
        set data [string range $bytes [expr {$at + 60}] [expr {$at + 59 + $size}]]
        if {$name eq "//"} {
            set names $data
        } elseif {$name ni {/ /SYM64/ __.SYMDEF {__.SYMDEF SORTED}}} {
            if {[regexp {^/([0-9]+)$} $name -> offset]} {
                set end [string first "/\n" $names $offset]
                set name [string range $names $offset [expr {$end - 1}]]
            } elseif {[regexp {^#1/([0-9]+)$} $name -> n]} {
                set name [string trimright [string range $data 0 [expr {$n - 1}]] \x00]
                set data [string range $data $n end]
            } else {
                set name [string trimright $name /]
            }
            lappend members [dict create name $name size [string length $data] sha256 [pm::sha256::hex $data] data $data]
        }
        set at [expr {$at + 60 + $size + ($size % 2)}]
    }
    return $members
}

proc pm::release::encode {record} {
    return [pm::json::encode $record]
}

# ---------------------------------------------------------------------------
# Reading a record back

# The provenance record of the file PATH: {value V subject {name version
# artifact sha256 size ...} contents {PATH {size S sha256 D} ...} checks
# {...} sources N builds N}, or {PM PROVENANCE} when it is no record of
# format 1.
proc pm::release::readRecord {path} {
    if {![file isfile $path]} {
        Fail PROVENANCE "no provenance record $path"
    }
    if {[catch {pm::json::decode [pm::ReadBytes $path] -limit [expr {64 * 1024 * 1024}]} value]} {
        Fail PROVENANCE "$path: $value"
    }
    set keys {provenance subject producer contents native sources builds generators checks notes trust}
    if {[pm::json::type $value] ne "obj"} {
        Fail PROVENANCE "$path is not a provenance record (no JSON object)"
    }
    set members [pm::json::payload $value]
    if {[dict keys $members] ne $keys} {
        Fail PROVENANCE "$path is not a provenance record of format 1 (its keys are [join [dict keys $members] {, }]; a record has [join $keys {, }], in that order)"
    }
    if {[dict get $members provenance] ne {num 1}} {
        Fail PROVENANCE "$path: unsupported provenance format [pm::json::payload [dict get $members provenance]]"
    }
    set subject [dict create]
    foreach {key item} [pm::json::payload [dict get $members subject]] {
        dict set subject $key [pm::json::payload $item]
    }
    foreach key {name version artifact sha256 size} {
        if {![dict exists $subject $key]} {
            Fail PROVENANCE "$path: its subject has no $key"
        }
    }
    if {![regexp {^[0-9a-f]{64}$} [dict get $subject sha256]]} {
        Fail PROVENANCE "$path: its subject's sha256 is no SHA-256 digest"
    }
    set contents [dict create]
    foreach item [pm::json::payload [dict get $members contents]] {
        set fields [pm::json::payload $item]
        dict set contents [pm::json::payload [dict get $fields path]] \
            [dict create size [pm::json::payload [dict get $fields size]] sha256 [pm::json::payload [dict get $fields sha256]]]
    }
    set checks {}
    foreach item [pm::json::payload [dict get $members checks]] {
        set fields [dict create]
        foreach {key v} [pm::json::payload $item] {
            dict set fields $key [pm::json::payload $v]
        }
        lappend checks $fields
    }
    # The record's own canonical form: a record is what encode writes.
    if {[pm::ReadBytes $path] ne [encode $value]} {
        Fail PROVENANCE "$path is not in the canonical form a provenance record is written in"
    }
    return [dict create value $value subject $subject contents $contents checks $checks \
        sources [llength [pm::json::payload [dict get $members sources]]] \
        builds [llength [pm::json::payload [dict get $members builds]]] \
        generators [llength [pm::json::payload [dict get $members generators]]]]
}

# How the record RECORD (readRecord) and the artifact ARTIFACT
# (pm::catalog::Load) relate: {matches 0|1 problems {...}}.
proc pm::release::check {record artifact} {
    set problems {}
    set subject [dict get $record subject]
    if {[dict get $subject sha256] ne [dict get $artifact digest]} {
        lappend problems "the record describes the artifact with SHA-256 [dict get $subject sha256], and this artifact's is [dict get $artifact digest]: it is the record of another file"
    }
    foreach key {name version} {
        if {[dict get $subject $key] ne [dict get $artifact $key]} {
            lappend problems "the record's $key is [dict get $subject $key], the artifact's [dict get $artifact $key]"
        }
    }
    set files [dict create {*}[dict get $artifact files]]
    if {[lsort [dict keys $files]] ne [lsort [dict keys [dict get $record contents]]]} {
        lappend problems "the record lists other files than the artifact holds"
    } else {
        dict for {path bytes} $files {
            if {[pm::sha256::hex $bytes] ne [dict get $record contents $path sha256]} {
                lappend problems "$path: the record's SHA-256 is not the artifact's"
            }
        }
    }
    return [dict create matches [expr {$problems eq ""}] problems $problems]
}

# ---------------------------------------------------------------------------
# Comparing release candidates

# The differences between two candidate artifacts A and B (pm::catalog::Load
# results), and, given, their records RA and RB (readRecord): {identical
# 0|1 lines {...}}.
proc pm::release::compare {a b {ra ""} {rb ""}} {
    set lines {}
    set label "[dict get $a name] [dict get $a version]"
    if {[dict get $a name] ne [dict get $b name] || [dict get $a version] ne [dict get $b version]} {
        lappend lines "not two candidates of one release: [dict get $a name] [dict get $a version] and [dict get $b name] [dict get $b version]"
    }
    lappend lines "A: sha256 [dict get $a digest] ([file size [dict get $a path]] bytes, [expr {[llength [dict get $a files]] / 2}] files)"
    lappend lines "B: sha256 [dict get $b digest] ([file size [dict get $b path]] bytes, [expr {[llength [dict get $b files]] / 2}] files)"
    set identical [expr {[dict get $a digest] eq [dict get $b digest]}]
    if {$identical} {
        lappend lines "identical: the same bytes, one artifact"
    } else {
        set fa [dict create {*}[dict get $a files]]
        set fb [dict create {*}[dict get $b files]]
        set differing {}
        foreach path [lsort -unique [concat [dict keys $fa] [dict keys $fb]]] {
            if {![dict exists $fa $path]} {
                lappend lines "  only in B: $path"
                lappend differing $path
            } elseif {![dict exists $fb $path]} {
                lappend lines "  only in A: $path"
                lappend differing $path
            } elseif {[dict get $fa $path] ne [dict get $fb $path]} {
                lappend differing $path
                lappend lines "  differs: $path ([string length [dict get $fa $path]] and [string length [dict get $fb $path]] bytes; sha256 [pm::Short [pm::sha256::hex [dict get $fa $path]]] and [pm::Short [pm::sha256::hex [dict get $fb $path]]])"
                lappend lines {*}[lmap line [FileDifferences [dict get $fa $path] [dict get $fb $path] $path] {string cat "    " $line}]
            }
        }
        if {$differing eq ""} {
            lappend lines "  every file is identical: the archives differ in their ZIP encoding only (the deflate streams: a different zlib), not in what they hold"
        } else {
            lappend lines "  [llength $differing] of [dict size $fa] files differ; the first: [lindex $differing 0]"
        }
        lappend lines "two different candidates of $label: a release is one artifact, so at most one of them may be published as $label (the other is a rebuild that did not reproduce it)"
    }
    if {$ra ne "" && $rb ne ""} {
        lappend lines {*}[RecordDifferences $ra $rb]
    }
    return [dict create identical $identical lines $lines]
}

# How two versions A and B of one file differ, as lines: for ELF files the
# sections whose bytes differ, the build IDs, the run-time search paths and
# the compilers recorded; for archives the members; else the first byte.
proc pm::release::FileDifferences {a b path} {
    set lines {}
    if {[string range $a 0 3] eq "\x7fELF" && [string range $b 0 3] eq "\x7fELF"} {
        if {[catch {
            set sa [pm::binary::elfSections $a $path]
            set sb [pm::binary::elfSections $b $path]
            set ia [pm::binary::inspect $a $path]
            set ib [pm::binary::inspect $b $path]
        } message]} {
            return [list "unreadable: $message"]
        }
        foreach key {runpath rpath needed soname} {
            if {[dict get $ia $key] ne [dict get $ib $key]} {
                lappend lines "[string toupper $key]: \"[join [dict get $ia $key] :]\" and \"[join [dict get $ib $key] :]\""
            }
        }
        if {[dict get $sa buildid] ne [dict get $sb buildid]} {
            lappend lines "GNU build ID: [dict get $sa buildid] and [dict get $sb buildid] (a hash of the file's contents: it differs whenever anything else does)"
        }
        if {[dict get $sa comment] ne [dict get $sb comment]} {
            lappend lines "compilers (.comment): [join [dict get $sa comment] {; }] and [join [dict get $sb comment] {; }]"
        }
        set byName [dict create]
        foreach section [dict get $sb sections] {
            dict set byName [dict get $section name] $section
        }
        set changed {}
        set moved {}
        foreach section [dict get $sa sections] {
            set name [dict get $section name]
            if {$name eq ""} continue
            if {![dict exists $byName $name]} {
                lappend changed "$name (only in A)"
                continue
            }
            set other [dict get $byName $name]
            set ba [string range $a [dict get $section offset] [expr {[dict get $section offset] + [dict get $section size] - 1}]]
            set bb [string range $b [dict get $other offset] [expr {[dict get $other offset] + [dict get $other size] - 1}]]
            if {$ba ne $bb} {
                lappend changed "$name ([dict get $section size] and [dict get $other size] bytes)"
            } elseif {[dict get $section offset] != [dict get $other offset]} {
                lappend moved $name
            }
        }
        if {$changed ne ""} {
            lappend lines "sections whose bytes differ: [join [lrange $changed 0 11] {, }][expr {[llength $changed] > 12 ? ", ..." : ""}]"
        }
        if {$moved ne ""} {
            lappend lines "sections with equal bytes at other offsets: [join [lrange $moved 0 11] {, }][expr {[llength $moved] > 12 ? ", ..." : ""}]"
        }
        return $lines
    }
    if {[string range $a 0 7] eq "!<arch>\n" && [string range $b 0 7] eq "!<arch>\n"} {
        if {[catch {
            set ma [ArMembers $a $path]
            set mb [ArMembers $b $path]
        } message]} {
            return [list "unreadable: $message"]
        }
        set byName [dict create]
        foreach member $mb { dict set byName [dict get $member name] $member }
        foreach member $ma {
            set name [dict get $member name]
            if {![dict exists $byName $name]} {
                lappend lines "member $name: only in A"
            } elseif {[dict get $member sha256] ne [dict get $byName $name sha256]} {
                lappend lines "member $name differs"
                foreach line [FileDifferences [dict get $member data] [dict get $byName $name data] "$path, member $name"] {
                    lappend lines "  $line"
                }
            }
        }
        foreach member $mb {
            if {[lsearch -exact [lmap m $ma {dict get $m name}] [dict get $member name]] < 0} {
                lappend lines "member [dict get $member name]: only in B"
            }
        }
        if {$lines eq ""} {
            lappend lines "every member is identical: the archives differ in their headers or symbol index (member order, timestamps, owners)"
        }
        return $lines
    }
    set n [expr {min([string length $a], [string length $b])}]
    for {set i 0} {$i < $n && [string index $a $i] eq [string index $b $i]} {incr i} {}
    return [list "the first differing byte is at offset $i"]
}

proc pm::release::RecordDifferences {ra rb} {
    set lines {}
    set va [pm::json::payload [dict get $ra value]]
    set vb [pm::json::payload [dict get $rb value]]
    set same {}
    set different {}
    foreach key {sources builds generators notes} {
        if {[dict get $va $key] eq [dict get $vb $key]} {
            lappend same $key
        } else {
            lappend different $key
        }
    }
    if {[dict get $va producer] ne [dict get $vb producer]} {
        lappend lines "records: made by different package manager sources (producer), a difference of the tool, not of the release"
    }
    if {$different eq ""} {
        lappend lines "records: the same declared inputs (sources, builds, generators, notes): the builds were described identically, so what differs is an input neither record states"
    } else {
        lappend lines "records: the declared inputs differ in [join $different {, }] (equal: [Or $same])"
        foreach key $different {
            set ia [pm::json::payload [dict get $va $key]]
            set ib [pm::json::payload [dict get $vb $key]]
            for {set i 0} {$i < max([llength $ia], [llength $ib])} {incr i} {
                set x [lindex $ia $i]
                set y [lindex $ib $i]
                if {$x eq $y} continue
                foreach field [lsort -unique [concat [dict keys [pm::json::payload $x]] [dict keys [pm::json::payload $y]]]] {
                    set fx [dict getdef [pm::json::payload $x] $field ""]
                    set fy [dict getdef [pm::json::payload $y] $field ""]
                    if {$fx ne $fy} {
                        lappend lines "  $key\[$i\].$field: [Show $fx] and [Show $fy]"
                    }
                }
            }
        }
    }
    return $lines
}

proc pm::release::Show {value} {
    if {$value eq ""} { return "(absent)" }
    set text [string map {\n " "} [encoding convertfrom utf-8 [pm::json::encode $value]]]
    regsub -all {\s+} $text " " text
    if {[string length $text] > 160} { set text "[string range $text 0 156]..." }
    return $text
}

proc pm::release::Or {list} {
    if {$list eq ""} { return "nothing" }
    return [join $list {, }]
}

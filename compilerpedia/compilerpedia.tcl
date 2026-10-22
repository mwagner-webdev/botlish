# compilerpedia.tcl -- Compilerpedia, the compiler's built-in reference
# (COMPILERPEDIA.md).
#
#   compilerpedia::main WORDS             print the help WORDS ask for;
#                                         returns the exit status (main.tcl's
#                                         -help)
#   compilerpedia::lookup QUERY           what QUERY finds: {kind page|list|
#                                         index|overview|none ...}
#   compilerpedia::render ID              the reference page of topic ID
#   compilerpedia::topicForDiagnostic CODE MESSAGE
#                                         the topic a printed diagnostic
#                                         points at ("" for none)
#   compilerpedia::topics / topic ID      the catalogue
#   compilerpedia::validate               the catalogue's structural problems
#
# The unit is a *topic*: one documented language rule, compiler capability,
# diagnostic, warning, principle, standard-library entry or backend fact,
# with a stable ID. Indices (concepts, rules, proofs, errors, warnings, lint,
# principles, stdlib, backends) are views over topics: a topic names the
# indices it belongs to, and one topic may be in several, so nothing is
# written twice. Topics are plain text files (topics/*.topic, written by
# hand; generated/*.topic, written by tools/compilerpedia.tcl from the
# compiler's own registries and library sources), read on demand: nothing
# here runs when the compiler compiles, and nothing here compiles, loads a
# module or starts a backend.
#
# The topic file format (COMPILERPEDIA.md, "Topic files"):
#
#   @topic ID                     starts a topic
#   KEY: VALUE                    header lines, up to the first blank line:
#                                   title summary (one each), index related
#                                   docs symbol (words), alias keywords (";"-
#                                   separated phrases), code (one diagnostic
#                                   or warning code per line), match ("CODE |
#                                   GLOB": a printed diagnostic of CODE whose
#                                   message matches GLOB points here)
#   == HEADING                    starts a section; its lines follow verbatim
#   @example accept|reject        an executable example, its code lines, then
#   @DIRECTIVE ...                  directives (@value, @warn, @nowarn,
#   @end                            @quiet, @backends, @output, @error, @at,
#                                   @message, @caption, @target) and @end
#
# Lines before a file's first @topic are its header comment; after it, a
# line starting with "#" (outside an example) is a comment.

namespace eval compilerpedia {
    variable home [file dirname [file normalize [info script]]]
    # The loaded catalogue: topics (ID -> topic dict, in file order) and the
    # lookup tables built from them; "" until first use.
    variable catalogue ""
    # The diagnostic tables read without the catalogue (DiagnosticTables).
    variable diagnosticTables ""
    # The indices, in the order the overview lists them. Each is a view: the
    # topics whose `index:` names it.
    variable indices {
        concepts   {What Botlish's constructs are and why they exist}
        rules      {Language rules and semantic guarantees}
        proofs     {What the compiler proves, and what it does not}
        errors     {Diagnostic codes and the specific rules behind them}
        warnings   {The linter's rules, with their rationale}
        lint       {The linter as a whole: policy, modes and principles}
        principles {Programming principles and recommended practices}
        stdlib     {Standard-library modules, functions and types}
        backends   {Backends, targets, the command line and platforms}
    }
    # Words a query may contain that carry no meaning for the search.
    variable stopWords {
        a an the to of for how do does did i is are was can could what why when
        with my it its be use using used should which where there this that
        these into from by me we you your via vs about get make way want need
        any some does
    }
    # The header keys a topic may carry, and whether each is a list of words
    # (words), of ";"-separated phrases (phrases), repeatable whole lines
    # (lines), or one line (line).
    variable keys {
        title line summary line index words related words docs words symbol words
        alias phrases keywords phrases code lines match lines
    }
    variable exampleDirectives {value warn nowarn quiet backends output error at message caption target}
}

# ---------------------------------------------------------------------------
# Reading topic files

# The topics of the topic-file TEXT (named FILE in errors), in order, each a
# dict {id file line title summary index related docs symbol alias keywords
# code match body examples}: BODY a list of {heading ITEMS} sections (each
# item {text LINE} or {example N}), EXAMPLES a list of example dicts
# {id kind lines value warn nowarn quiet backends output error at message
# caption target line}.
proc compilerpedia::parse {text file} {
    variable keys
    variable exampleDirectives
    set topics {}
    set topic ""
    set state header
    set number 0
    # The section being read: its heading and items (sections are closed
    # into `sections` when the next one starts, and into the topic by
    # Finish).
    set sections {}
    set heading ""
    set items {}
    foreach line [split $text \n] {
        incr number
        set line [string trimright $line "\r"]
        set first [string index $line 0]
        if {$first eq "@" && [regexp {^@topic\s+(\S+)\s*$} $line -> id]} {
            if {$topic ne ""} {
                lappend sections [list $heading $items]
                lappend topics [Finish $topic $sections $file]
            }
            set topic [dict create id $id file $file line $number examples {}]
            dict for {key kind} $keys {
                dict set topic $key {}
            }
            set sections {}
            set heading ""
            set items {}
            set state header
            continue
        }
        if {$topic eq ""} {
            continue
        }
        if {$state eq "example"} {
            if {$line eq "@end"} {
                dict lappend topic examples $example
                lappend items [list example [expr {[llength [dict get $topic examples]] - 1}]]
                set state body
            } elseif {$first eq "@" && [regexp {^@(\w+)(?:\s+(.*))?$} $line -> directive argument]} {
                if {$directive ni $exampleDirectives} {
                    Fail $file $number "unknown example directive @$directive"
                }
                switch -- $directive {
                    warn - nowarn - output { dict lappend example $directive $argument }
                    quiet { dict set example quiet 1 }
                    backends { dict set example backends $argument }
                    default { dict set example $directive $argument }
                }
            } else {
                dict lappend example lines $line
            }
            continue
        }
        # A "#" in column 0 outside an example (whose lines are Botlish,
        # comments included) is a comment of the file: body text is
        # indented or starts with another character.
        if {$first eq "#"} {
            continue
        }
        if {$first eq "@"} {
            if {[regexp {^@example\s+(accept|reject)\s*$} $line -> kind]} {
                set example [dict create id "[dict get $topic id]#[expr {[llength [dict get $topic examples]] + 1}]" \
                    kind $kind lines {} value "" warn {} nowarn {} quiet 0 backends {interp compile} \
                    output {} error "" at "" message "" caption "" target "" line $number]
                set state example
                continue
            }
            Fail $file $number "unknown directive \"[lindex [split $line] 0]\""
        }
        if {$state eq "header"} {
            if {[string trim $line] eq ""} {
                set state body
                continue
            }
            if {![regexp {^([a-z]+):\s*(.*)$} $line -> key value] || ![dict exists $keys $key]} {
                Fail $file $number "expected a header line KEY: VALUE (keys: [join [dict keys $keys] {, }]), found \"$line\""
            }
            switch -- [dict get $keys $key] {
                line {
                    if {[dict get $topic $key] ne ""} {
                        Fail $file $number "\"$key:\" given twice"
                    }
                    dict set topic $key [string trim $value]
                }
                words { dict set topic $key [concat [dict get $topic $key] [split [string trim $value]]] }
                phrases {
                    foreach phrase [split $value ";"] {
                        if {[string trim $phrase] ne ""} {
                            dict lappend topic $key [string trim $phrase]
                        }
                    }
                }
                lines { dict lappend topic $key [string trim $value] }
            }
            continue
        }
        if {$first eq "=" && [regexp {^==\s+(.+?)\s*$} $line -> newHeading]} {
            if {$heading ne "" || $items ne ""} {
                lappend sections [list $heading $items]
            }
            set heading $newHeading
            set items {}
            continue
        }
        lappend items [list text $line]
    }
    if {$state eq "example"} {
        Fail $file $number "@example without @end"
    }
    if {$topic ne ""} {
        lappend sections [list $heading $items]
        lappend topics [Finish $topic $sections $file]
    }
    return $topics
}

proc compilerpedia::Fail {file line message} {
    throw {COMPILERPEDIA FORMAT} "$file:$line: $message"
}

# TOPIC with its SECTIONS ({HEADING ITEMS}) as its body: trailing blank
# lines dropped, and an untitled empty section (a topic's header followed
# directly by "== X") left out.
proc compilerpedia::Finish {topic sections file} {
    foreach key {title summary index} {
        if {[dict get $topic $key] eq ""} {
            Fail $file [dict get $topic line] "topic [dict get $topic id] has no \"$key:\""
        }
    }
    set body {}
    foreach section $sections {
        lassign $section heading items
        while {[llength $items] && [lindex $items end 0] eq "text" && [string trim [lindex $items end 1]] eq ""} {
            set items [lrange $items 0 end-1]
        }
        if {$heading eq "" && $items eq ""} {
            continue
        }
        lappend body [list $heading $items]
    }
    dict set topic body $body
    return $topic
}

# The topic files of the catalogue: the hand-written topics, then the
# generated ones, each directory's files in name order.
proc compilerpedia::files {} {
    variable home
    set files {}
    foreach dir {topics generated} {
        lappend files {*}[lsort [glob -nocomplain -directory [file join $home $dir] -types f *.topic]]
    }
    return $files
}

proc compilerpedia::ReadFile {path} {
    set channel [open $path r]
    fconfigure $channel -encoding utf-8
    set text [read $channel]
    close $channel
    return $text
}

# Loads the catalogue once: every topic, by ID, and the lookup tables.
proc compilerpedia::Load {} {
    variable catalogue
    if {$catalogue ne ""} {
        return $catalogue
    }
    set topics [dict create]
    set duplicates {}
    foreach path [files] {
        foreach topic [parse [ReadFile $path] [file join [file tail [file dirname $path]] [file tail $path]]] {
            set id [dict get $topic id]
            if {[dict exists $topics $id]} {
                lappend duplicates [list $id [dict get $topics $id file] [dict get $topic file]]
                continue
            }
            dict set topics $id $topic
        }
    }
    set catalogue [BuildTables $topics]
    dict set catalogue duplicates $duplicates
    return $catalogue
}

# Drops the loaded catalogue (tests that write topic files of their own).
proc compilerpedia::reset {} {
    variable catalogue
    variable diagnosticTables
    set catalogue ""
    set diagnosticTables ""
}

# The diagnostic tables alone, {matches {{CODE GLOB ID}...} codes {CODE
# IDS...}}, equal to Load's (tests/compilerpedia.test): read from the
# topics' header lines without parsing the catalogue, so the help line under
# a diagnostic costs a scan of the files, not a load.
proc compilerpedia::DiagnosticTables {} {
    variable catalogue
    variable diagnosticTables
    if {$catalogue ne ""} {
        return [dict create matches [dict get $catalogue matches] codes [dict get $catalogue codes]]
    }
    if {$diagnosticTables ne ""} {
        return $diagnosticTables
    }
    set matches {}
    set codes [dict create]
    set seen [dict create]
    foreach path [files] {
        set id ""
        set header 0
        foreach line [split [ReadFile $path] \n] {
            set line [string trimright $line "\r"]
            if {[regexp {^@topic\s+(\S+)\s*$} $line -> id]} {
                # The first topic of an ID wins, as in Load.
                set header [expr {![dict exists $seen $id]}]
                dict set seen $id 1
                continue
            }
            if {!$header} {
                continue
            }
            if {[string trim $line] eq ""} {
                set header 0
            } elseif {[regexp {^code:\s*(.*)$} $line -> code]} {
                dict lappend codes [string trim $code] $id
            } elseif {[regexp {^match:\s*(.*)$} $line -> match]} {
                set cut [string first | $match]
                lappend matches [list [string trim [string range $match 0 [expr {$cut - 1}]]] \
                    [string trim [string range $match [expr {$cut + 1}] end]] $id]
            }
        }
    }
    set diagnosticTables [dict create matches $matches codes $codes]
    return $diagnosticTables
}

# The lookup tables over TOPICS:
#   cased   key -> {RANK ID...}: the topic ID itself (rank 1), a code or a
#           code's kind, a symbol (2), an alias (3), as written
#   exact   the same keys, lowercased
#   loose   the same keys, loosely normalized (Loose)
#   members index name -> topic IDs
#   matches {CODE GLOB ID}: diagnostic matchers, in topic order
#   codes   code -> topic IDs documenting it
# (The word index of the text search is built on first use: WordTable.)
proc compilerpedia::BuildTables {topics} {
    variable indices
    set cased [dict create]
    set exact [dict create]
    set loose [dict create]
    set members [dict create]
    foreach {name description} $indices {
        dict set members $name {}
    }
    set matches {}
    set codes [dict create]
    set symbols [dict create]
    dict for {id topic} $topics {
        AddKey exact loose $id 1 $id
        foreach code [dict get $topic code] {
            AddKey exact loose $code 2 $id
            dict lappend codes $code $id
            # A code's last word alone finds it too: KNOWN-ERROR in any case,
            # a plain word (TYPE, STRUCT, RANGE) only as written, so that
            # "type", "struct" and "range" stay words a reader searches for.
            if {[llength $code] > 1} {
                set last [lindex $code end]
                AddKey exact loose $last 2 $id [expr {[regexp {^[A-Za-z]+$} $last] ? "cased" : "all"}]
            }
        }
        foreach symbol [dict get $topic symbol] {
            AddKey exact loose $symbol 2 $id
            dict lappend symbols $symbol $id
        }
        foreach alias [dict get $topic alias] {
            AddKey exact loose $alias 3 $id
        }
        foreach name [dict get $topic index] {
            dict lappend members $name $id
        }
        foreach match [dict get $topic match] {
            set cut [string first | $match]
            lappend matches [list [string trim [string range $match 0 [expr {$cut - 1}]]] \
                [string trim [string range $match [expr {$cut + 1}] end]] $id]
        }
    }
    return [dict create topics $topics cased $cased exact $exact loose $loose members $members \
        matches $matches codes $codes symbols $symbols]
}

# KEY finds topic ID with RANK (lower wins) as written, and, unless TABLES is
# "cased", case-insensitively and loosely.
proc compilerpedia::AddKey {exactVar looseVar key rank id {tables all}} {
    upvar 1 $exactVar exact $looseVar loose cased cased
    set key [string trim $key]
    if {![dict exists $cased $key] || $id ni [lmap e [dict get $cased $key] {lindex $e 1}]} {
        dict lappend cased $key [list $rank $id]
    }
    if {$tables eq "cased"} {
        return
    }
    set k [string tolower $key]
    if {![dict exists $exact $k] || $id ni [dict get $exact $k]} {
        dict lappend exact $k [list $rank $id]
    }
    set l [Loose $key]
    if {$l ne $k && (![dict exists $loose $l] || $id ni [lmap e [dict get $loose $l] {lindex $e 1}])} {
        dict lappend loose $l [list $rank $id]
    }
}

# KEY with case, `-`, `_`, `.` and runs of spaces ignored: "Method eligible",
# "method_eligible" and "METHOD-ELIGIBLE" are one loose key.
proc compilerpedia::Loose {key} {
    return [string trim [regsub -all {[\s\-_.]+} [string tolower $key] " "]]
}

# The word index of the text search, topic -> {field -> words}, built the
# first time a query needs it (an exact lookup or an index page never does).
proc compilerpedia::WordTable {} {
    variable catalogue
    Load
    if {![dict exists $catalogue words]} {
        set words [dict create]
        dict for {id topic} [dict get $catalogue topics] {
            dict set words $id [TopicWords $topic]
        }
        dict set catalogue words $words
    }
    return [dict get $catalogue words]
}

# The words of TOPIC's fields for the text search: {FIELD WORDS} with FIELD
# one of name (ID, codes, symbols), title, alias, keywords, summary, body.
proc compilerpedia::TopicWords {topic} {
    set name [concat [list [dict get $topic id]] [dict get $topic code] [dict get $topic symbol]]
    set body {}
    foreach section [dict get $topic body] {
        lassign $section heading items
        lappend body $heading
        foreach item $items {
            if {[lindex $item 0] eq "text"} {
                lappend body [lindex $item 1]
            }
        }
    }
    return [dict create \
        name [Words [join $name " "]] \
        title [Words [dict get $topic title]] \
        alias [Words [join [dict get $topic alias] " "]] \
        keywords [Words [join [dict get $topic keywords] " "]] \
        summary [Words [dict get $topic summary]] \
        body [Words [join $body " "]]]
}

# TEXT's search words: lowercased runs of letters, digits, `_` and `?`, each
# Stemmed, as a dict word -> 1.
proc compilerpedia::Words {text} {
    set result [dict create]
    foreach word [regexp -all -inline {[[:alnum:]_?]+} [string tolower $text]] {
        dict set result [Stem $word] 1
    }
    return $result
}

# A crude plural fold, applied to text and query alike: "errors" and "error",
# "capabilities" and "capability", "matches" and "match" are one word
# ("access", "class" keep their s).
proc compilerpedia::Stem {word} {
    if {[string length $word] <= 3} {
        return $word
    }
    if {[string length $word] > 4 && [string match *ies $word]} {
        return "[string range $word 0 end-3]y"
    }
    if {[regexp {(ss|x|ch|sh|z)es$} $word]} {
        return [string range $word 0 end-2]
    }
    if {[string index $word end] eq "s" && [string index $word end-1] ni {s u i}} {
        return [string range $word 0 end-1]
    }
    return $word
}

# ---------------------------------------------------------------------------
# The catalogue

proc compilerpedia::topics {} {
    return [dict keys [dict get [Load] topics]]
}

proc compilerpedia::exists {id} {
    return [dict exists [dict get [Load] topics] $id]
}

proc compilerpedia::topic {id} {
    return [dict get [Load] topics $id]
}

# The topic IDs of index NAME, in ID order.
proc compilerpedia::members {name} {
    return [lsort [dict get [Load] members $name]]
}

# The topics index NAME lists: its members, minus its own introduction
# (index.NAME), which is the index page itself.
proc compilerpedia::Listed {name} {
    return [lmap id [members $name] {if {$id eq "index.$name"} {continue} else {set id}}]
}

proc compilerpedia::indexNames {} {
    variable indices
    return [dict keys $indices]
}

# The topics that document CODE (a diagnostic's error code, e.g. CORE SEMANTIC
# TYPE, or a warning code).
proc compilerpedia::codeTopics {code} {
    set codes [dict get [Load] codes]
    return [dict getdef $codes $code {}]
}

# The topic a printed diagnostic of error code CODE with MESSAGE (its text,
# with or without the leading FILE:LINE:COLUMN:) points at: the first topic
# whose matcher for CODE matches the message (a specific rule), else the
# topic documenting CODE itself or, failing that, its longest documented
# prefix of two or more words, else "". For main.tcl's "help:" lines; it
# reads only the catalogue, never the diagnostic's compiler state.
proc compilerpedia::topicForDiagnostic {code message} {
    regsub {^\S+:\d+:\d+: } $message {} message
    set tables [DiagnosticTables]
    foreach match [dict get $tables matches] {
        lassign $match matchCode glob id
        if {$matchCode eq $code && [string match $glob $message]} {
            return $id
        }
    }
    # A code whose last words vary (NATIVE UNSUPPORTED value, CORE
    # DECLARED-ERROR NAME) falls back to its documented prefix.
    while 1 {
        set ids [dict getdef $tables codes $code {}]
        if {[llength $ids] > 0} {
            if {[llength $ids] == 1} {
                return [lindex $ids 0]
            }
            return ""
        }
        if {[llength $code] <= 2} {
            return ""
        }
        set code [lrange $code 0 end-1]
    }
}

# ---------------------------------------------------------------------------
# Search

# What QUERY (one string; words separated by spaces) finds:
#   {kind overview}                  an empty query
#   {kind index name NAME}           an index name (concepts, rules, ...,
#                                    all), or its singular
#   {kind page id ID}                one topic: an exact ID, code, symbol or
#                                    alias, or the only topic the words find
#   {kind list ids IDS exact 0|1}    several topics, best first (exact: they
#                                    share the query as an identifier)
#   {kind none near IDS}             nothing; IDS are near matches, if any
# Deterministic: ties are broken by topic ID.
proc compilerpedia::lookup {query} {
    variable indices
    set query [string trim $query]
    if {$query eq ""} {
        return [dict create kind overview]
    }
    set lower [string tolower $query]
    if {[dict exists $indices $lower] || $lower eq "all"} {
        return [dict create kind index name $lower]
    }
    foreach {singular plural} {concept concepts rule rules proof proofs error errors warning warnings
            principle principles backend backends index all} {
        if {$lower eq $singular} {
            return [dict create kind index name $plural]
        }
    }
    set catalogue [Load]
    # The key as written first (std::abi::I8 the type, std::abi::i8 the function), then
    # case-insensitively, then loosely.
    foreach table {cased exact loose} key [list $query $lower [Loose $query]] {
        if {[dict exists $catalogue $table $key]} {
            set entries [lsort -integer -index 0 [lsort -index 1 [dict get $catalogue $table $key]]]
            set best [lindex $entries 0 0]
            set ids [lsort -unique [lmap e $entries {if {[lindex $e 0] == $best} {lindex $e 1} else {continue}}]]
            if {[llength $ids] == 1} {
                return [PageOrIndex [lindex $ids 0]]
            }
            return [dict create kind list ids $ids exact 1]
        }
    }
    set ranked [Search $query]
    if {[llength $ranked] == 1} {
        return [PageOrIndex [lindex $ranked 0]]
    }
    if {[llength $ranked] > 1} {
        return [dict create kind list ids $ranked exact 0]
    }
    return [dict create kind none near [Near $query]]
}

# What finding topic ID shows: its page, or, for an index's introduction
# (index.NAME), the whole index.
proc compilerpedia::PageOrIndex {id} {
    variable indices
    if {[regexp {^index\.(.+)$} $id -> name] && [dict exists $indices $name]} {
        return [dict create kind index name $name]
    }
    return [dict create kind page id $id]
}

# The query's search terms: its words, minus stop words, stemmed.
proc compilerpedia::Terms {query} {
    variable stopWords
    set terms {}
    foreach word [regexp -all -inline {[[:alnum:]_?]+} [string tolower $query]] {
        if {$word in $stopWords} {
            continue
        }
        set word [Stem $word]
        if {$word ni $terms} {
            lappend terms $word
        }
    }
    return $terms
}

# The topics every term of QUERY occurs in, best first (Score), with at
# least half of the terms in the topic's name, title, aliases, keywords or
# summary: a single generic word never pulls in a topic that lacks the
# others, and a page that merely mentions the words in its text ("no such
# topic anywhere") is no answer. Those weak matches are left to Near.
proc compilerpedia::Search {query} {
    set terms [Terms $query]
    if {$terms eq ""} {
        return {}
    }
    set scored {}
    dict for {id fields} [WordTable] {
        lassign [Score $fields $terms] score strong
        if {$score > 0 && 2 * $strong >= [llength $terms]} {
            lappend scored [list $score $id]
        }
    }
    return [Ranked $scored]
}

# How well a topic's FIELDS (WordTable) match TERMS: {SCORE STRONG}, SCORE
# the sum over terms of the best field each occurs in (an identifier or title
# over aliases and keywords over the summary over the body text), 0 unless
# every term occurs; STRONG the number of terms found outside the body.
proc compilerpedia::Score {fields terms} {
    set score 0
    set strong 0
    foreach term $terms {
        set best 0
        foreach {field weight} {name 30 title 30 alias 25 keywords 20 summary 10 body 2} {
            if {[dict exists $fields $field $term]} {
                set best $weight
                break
            }
        }
        if {$best == 0} {
            return {0 0}
        }
        incr score $best
        if {$best > 2} {
            incr strong
        }
    }
    return [list $score $strong]
}

# The IDs of SCORED ({SCORE ID} pairs), best first, ties by ID.
proc compilerpedia::Ranked {scored} {
    set scored [lsort -index 1 $scored]
    set scored [lsort -integer -decreasing -index 0 $scored]
    return [lmap s $scored {lindex $s 1}]
}

# Near matches for a QUERY that found nothing: identifiers (IDs, codes,
# symbols, aliases) within a small edit distance, then the topics whose text
# holds every term, then those with most of the terms in their name, title,
# aliases, keywords or summary. At most eight, deterministic.
proc compilerpedia::Near {query} {
    set catalogue [Load]
    set lower [string tolower [string trim $query]]
    set candidates {}
    if {[string length $lower] >= 3} {
        dict for {key entries} [dict get $catalogue exact] {
            set limit [expr {max(1, [string length $lower] / 4)}]
            if {abs([string length $key] - [string length $lower]) > $limit} {
                continue
            }
            set distance [Distance $lower $key]
            if {$distance <= $limit} {
                foreach entry $entries {
                    lappend candidates [list $distance [lindex $entry 1]]
                }
            }
        }
    }
    set near {}
    foreach candidate [lsort -index 1 [lsort -integer -index 0 $candidates]] {
        set id [lindex $candidate 1]
        if {$id ni $near} {
            lappend near $id
        }
    }
    # Weak matches: topics whose text holds every term.
    set terms [Terms $query]
    if {$terms ne ""} {
        set scored {}
        dict for {id fields} [WordTable] {
            set score [lindex [Score $fields $terms] 0]
            if {$score > 0} {
                lappend scored [list $score $id]
            }
        }
        foreach id [Ranked $scored] {
            if {$id ni $near} {
                lappend near $id
            }
        }
    }
    # Partial word matches: topics that hold most of the terms.
    if {[llength $terms] > 1} {
        set needed [expr {([llength $terms] + 1) / 2}]
        set scored {}
        dict for {id fields} [WordTable] {
            set hits 0
            foreach term $terms {
                foreach field {name title alias keywords summary} {
                    if {[dict exists $fields $field $term]} {
                        incr hits
                        break
                    }
                }
            }
            if {$hits >= $needed} {
                lappend scored [list $hits $id]
            }
        }
        foreach s [lsort -integer -decreasing -index 0 [lsort -index 1 $scored]] {
            if {[lindex $s 1] ni $near} {
                lappend near [lindex $s 1]
            }
        }
    }
    return [lrange $near 0 7]
}

# The Levenshtein distance of A and B.
proc compilerpedia::Distance {a b} {
    set n [string length $b]
    set previous {}
    for {set j 0} {$j <= $n} {incr j} {
        lappend previous $j
    }
    set i 0
    foreach ca [split $a ""] {
        incr i
        set current [list $i]
        set j 0
        foreach cb [split $b ""] {
            incr j
            set cost [expr {$ca eq $cb ? 0 : 1}]
            lappend current [expr {min([lindex $previous $j] + 1, [lindex $current end] + 1,
                [lindex $previous [expr {$j - 1}]] + $cost)}]
        }
        set previous $current
    }
    return [lindex $previous end]
}

# ---------------------------------------------------------------------------
# Rendering

namespace eval compilerpedia {
    # The width wrapped text is filled to (no terminal is asked).
    variable width 78
}

# TEXT filled to lines of at most WIDTH columns after INDENT.
proc compilerpedia::Wrap {text indent {width ""}} {
    if {$width eq ""} {
        set width $::compilerpedia::width
    }
    set lines {}
    set line ""
    foreach word [regexp -all -inline {\S+} $text] {
        if {$line ne "" && [string length "$indent$line $word"] > $width} {
            lappend lines "$indent$line"
            set line $word
        } elseif {$line eq ""} {
            set line $word
        } else {
            append line " $word"
        }
    }
    if {$line ne ""} {
        lappend lines "$indent$line"
    }
    return [join $lines \n]
}

# The reference page of topic ID, as plain text.
proc compilerpedia::render {id} {
    set topic [topic $id]
    set out {}
    lappend out $id [dict get $topic title]
    lappend out "Indices: [join [dict get $topic index] {, }]"
    lappend out ""
    lappend out SUMMARY [Wrap [dict get $topic summary] "    "]
    if {[dict get $topic code] ne ""} {
        lappend out "" [expr {[llength [dict get $topic code]] > 1 ? "CODES" : "CODE"}]
        foreach code [dict get $topic code] {
            lappend out "    $code"
        }
    }
    if {[dict get $topic symbol] ne ""} {
        lappend out "" [expr {[llength [dict get $topic symbol]] > 1 ? "SYMBOLS" : "SYMBOL"}] \
            "    [join [dict get $topic symbol] {, }]"
    }
    lappend out {*}[RenderSections $topic]
    # A code topic lists the specific rules that point at its code.
    set rules {}
    foreach code [dict get $topic code] {
        foreach match [dict get [Load] matches] {
            lassign $match matchCode glob rule
            if {$matchCode eq $code && $rule ne $id && $rule ni $rules} {
                lappend rules $rule
            }
        }
    }
    if {$rules ne ""} {
        lappend out "" "SPECIFIC RULES"
        lappend out {*}[EntryLines [lsort $rules]]
    }
    set related [dict get $topic related]
    # Topics that name this one as related.
    foreach other [ReverseRelated $id] {
        if {$other ni $related} {
            lappend related $other
        }
    }
    if {$related ne ""} {
        lappend out "" RELATED
        lappend out {*}[EntryLines $related]
    }
    if {[dict get $topic docs] ne ""} {
        lappend out "" "DESIGN DOCUMENTS (in a repository checkout; optional)"
        foreach doc [dict get $topic docs] {
            lappend out "    docs/$doc"
        }
    }
    return [join $out \n]
}

# The lines of TOPIC's sections: each heading upper-cased, its text indented
# four columns, its examples as RenderExample shows them.
proc compilerpedia::RenderSections {topic} {
    set out {}
    foreach section [dict get $topic body] {
        lassign $section heading items
        lappend out ""
        if {$heading ne ""} {
            lappend out [string toupper $heading]
        }
        set blank 0
        foreach item $items {
            lassign $item kind value
            if {$kind eq "example"} {
                if {[llength $out] && [lindex $out end] ne ""} {
                    lappend out ""
                }
                lappend out {*}[RenderExample [lindex [dict get $topic examples] $value]] ""
                set blank 1
                continue
            }
            if {[string trim $value] eq ""} {
                if {!$blank} {
                    lappend out ""
                }
                set blank 1
                continue
            }
            set blank 0
            lappend out "    $value"
        }
        while {[llength $out] && [lindex $out end] eq ""} {
            set out [lrange $out 0 end-1]
        }
    }
    return $out
}

# The hand-written topics that name ID as related, in ID order: the links a
# page's RELATED adds to its own. (A generated member's link to its module
# is not repeated on the module's page, which lists its members already.)
proc compilerpedia::ReverseRelated {id} {
    set result {}
    dict for {other t} [dict get [Load] topics] {
        if {$other ne $id && $id in [dict get $t related] && ![string match generated/* [dict get $t file]]} {
            lappend result $other
        }
    }
    return [lsort $result]
}

# "    ID  summary" lines for topic IDs IDS, the summary wrapped beside a
# short ID and under a long one (an unknown ID shown as such).
proc compilerpedia::EntryLines {ids} {
    set lines {}
    foreach id $ids {
        if {[exists $id]} {
            set summary [dict get [topic $id] summary]
        } else {
            set summary "(no such topic)"
        }
        if {[string length $id] <= 26} {
            set wrapped [split [Wrap $summary [string repeat " " 32]] \n]
            lappend lines [format "    %-26s  %s" $id [string trimleft [lindex $wrapped 0]]] {*}[lrange $wrapped 1 end]
        } else {
            lappend lines "    $id" {*}[split [Wrap $summary [string repeat " " 32]] \n]
        }
    }
    return $lines
}

proc compilerpedia::RenderExample {example} {
    set label [expr {[dict get $example kind] eq "accept" ? "Accepted" : "Rejected"}]
    set notes {}
    if {[dict get $example kind] eq "accept"} {
        if {[dict get $example value] ne ""} {
            lappend notes "value [dict get $example value]"
        }
        foreach code [dict get $example warn] {
            lappend notes "warns $code"
        }
        foreach code [dict get $example nowarn] {
            lappend notes "no $code"
        }
        if {[dict get $example quiet]} {
            lappend notes "no warnings"
        }
        if {[dict get $example backends] ne "interp compile"} {
            lappend notes "on [join [dict get $example backends] {, }]"
        }
    } else {
        set where [expr {[dict get $example at] ne "" ? " at [dict get $example at]" : ""}]
        lappend notes "[dict get $example error]$where"
    }
    if {[dict get $example target] ne ""} {
        lappend notes "for [dict get $example target]"
    }
    set head "$label[if {$notes ne ""} {string cat " ([join $notes {; }])"} else {string cat ""}]"
    if {[dict get $example caption] ne ""} {
        append head " -- [dict get $example caption]"
    }
    set lines [split [Wrap "$head:" "    "] \n]
    foreach line [dict get $example lines] {
        # (Not expr's ?: -- it would read "        0" as the number 0.)
        if {[string trim $line] eq ""} {
            lappend lines ""
        } else {
            lappend lines "        $line"
        }
    }
    return $lines
}

# The page of index NAME (or `all`): its introduction (the topic
# index.NAME), then its topics, one line each.
proc compilerpedia::renderIndex {name} {
    variable indices
    set out {}
    if {$name eq "all"} {
        lappend out "ALL TOPICS -- Compilerpedia" ""
        foreach index [indexNames] {
            lappend out "[string toupper $index] ([llength [Listed $index]])"
            foreach id [Listed $index] {
                lappend out "    $id"
            }
            lappend out ""
        }
        set pages [lmap index [indexNames] {expr {[exists index.$index] ? "index.$index" : [continue]}}]
        lappend out "INDEX PAGES ([llength $pages])" {*}[lmap id $pages {string cat "    " $id}] ""
        lappend out [Wrap "[llength [topics]] topics. [Invocation] -help ID shows one." ""]
        return [join $out \n]
    }
    lappend out "[string toupper $name] -- Compilerpedia index" \
        [Wrap [dict get $indices $name] ""] ""
    if {[exists index.$name]} {
        # The introduction: the sections of the topic index.NAME.
        lappend out {*}[lrange [RenderSections [topic index.$name]] 1 end] ""
    }
    set ids [Listed $name]
    set heading "TOPICS ([llength $ids])"
    if {$name eq "stdlib"} {
        # The symbols are listed on their module's page.
        set all [llength $ids]
        set ids [lmap id $ids {if {[string match stdlib.module.* $id] || ![string match stdlib.* $id]} {set id} else {continue}}]
        set heading "TOPICS ($all: these [llength $ids], and the [expr {$all - [llength $ids]}] symbols listed on their modules' pages)"
    }
    lappend out $heading
    lappend out {*}[EntryLines $ids]
    lappend out "" [Wrap "[Invocation] -help ID shows a topic; [Invocation] -help WORDS searches every index." ""]
    return [join $out \n]
}

proc compilerpedia::renderOverview {} {
    variable indices
    set me [Invocation]
    set out [list "Compilerpedia -- the Botlish compiler's built-in reference (offline)" ""]
    lappend out [Wrap "What Botlish means, what it guarantees, what this compiler can prove, and why its rules and warnings exist: every diagnostic code, warning, language rule, proof capability, standard-library symbol and backend fact is a topic with a stable ID, reachable from several indices and by search." ""] ""
    lappend out "New to Botlish?  $me -help \"best practices\"" ""
    lappend out INDICES
    foreach {name description} $indices {
        set wrapped [split [Wrap "$description ([llength [Listed $name]])" [string repeat " " 16]] \n]
        lappend out [format "    %-11s %s" $name [string trimleft [lindex $wrapped 0]]] {*}[lrange $wrapped 1 end]
    }
    lappend out [format "    %-11s %s" all "every topic ID, by index"] ""
    lappend out "LOOKING THINGS UP"
    set examples {
        KNOWN-ERROR               "a code (error or warning)"
        std::list::at                  "a standard-library symbol"
        concept.method-sugar      "a topic ID"
        {"bounds proof"}          "an alias, or a word search"
        {"handle several errors"} "a task"
        {"negative tests"}        "testing a failing call"
        warnings                  "an index"
    }
    set column [tcl::mathfunc::max {*}[lmap {query note} $examples {string length "$me -help $query"}]]
    foreach {query note} $examples {
        lappend out [format "    %-*s  %s" $column "$me -help $query" $note]
    }
    lappend out "" [Wrap "An exact topic ID, code or symbol wins over everything else, then an alias, then the topics that contain every word of the query. Case does not matter, except that a code's last word in capitals (TYPE, STRUCT) is the code and in lower case a word. Several matches are listed best first." "    "]
    lappend out "" [Wrap "[llength [topics]] topics. $me (no arguments) shows the command-line usage." ""]
    return [join $out \n]
}

# How this compiler is invoked, as the help names it: the single
# executable's own name, or tclsh9.0 main.tcl in a checkout -- as typed, so
# without the .exe Windows finds by itself (main.tcl's cliInvocation).
proc compilerpedia::Invocation {} {
    set name [file tail [info nameofexecutable]]
    if {$::tcl_platform(platform) eq "windows" && [string equal -nocase [file extension $name] .exe]} {
        set name [file rootname $name]
    }
    if {[info exists ::single::app]} {
        return $name
    }
    return "$name main.tcl"
}

# ---------------------------------------------------------------------------
# The command

# Prints what the help query WORDS (the arguments after -help, joined by
# spaces) asks for on OUT (found) or ERR (nothing found); returns the exit
# status: 0 when something was shown, 1 when nothing matches.
proc compilerpedia::main {words {out stdout} {err stderr}} {
    set query [join $words " "]
    set result [lookup $query]
    switch -- [dict get $result kind] {
        overview { puts $out [renderOverview] }
        index    { puts $out [renderIndex [dict get $result name]] }
        page     { puts $out [render [dict get $result id]] }
        list {
            set ids [dict get $result ids]
            set shown [lrange $ids 0 19]
            set how [expr {[dict get $result exact] ? "is an identifier of" : "occurs in"}]
            puts $out "\"$query\" $how [llength $ids] topics[expr {[llength $ids] > 20 ? " (the first 20 shown)" : ""}]:"
            puts $out ""
            puts $out [join [EntryLines $shown] \n]
            puts $out ""
            puts $out "[Invocation] -help ID shows one."
        }
        none {
            puts $err "no Compilerpedia topic matches \"$query\""
            set near [dict get $result near]
            if {$near ne ""} {
                puts $err ""
                puts $err "Near matches:"
                puts $err [join [EntryLines $near] \n]
            }
            puts $err ""
            puts $err "[Invocation] -help lists the indices; [Invocation] -help all lists every topic."
            return 1
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# Validation (tests/compilerpedia.test): the catalogue's own consistency. The
# checks against the compiler -- every diagnostic kind and warning code
# documented, every example compiling as stated -- live in the tests and in
# tools/compilerpedia.tcl, which load the compiler; this file never does.

# Every structural problem of the catalogue, as text lines ({} when sound).
proc compilerpedia::validate {} {
    variable indices
    set catalogue [Load]
    set problems {}
    foreach duplicate [dict get $catalogue duplicates] {
        lassign $duplicate id first second
        lappend problems "duplicate topic ID $id ($first, $second)"
    }
    dict for {id topic} [dict get $catalogue topics] {
        if {![regexp {^[a-z][a-z0-9]*(\.[a-zA-Z0-9_:?+*/<>=!-]+)+$} $id]} {
            lappend problems "$id: a topic ID is a lowercase category, a dot and a name (e.g. concept.method-sugar)"
        }
        foreach name [dict get $topic index] {
            if {![dict exists $indices $name]} {
                lappend problems "$id: unknown index \"$name\""
            }
        }
        foreach ref [dict get $topic related] {
            if {![dict exists [dict get $catalogue topics] $ref]} {
                lappend problems "$id: related topic $ref does not exist"
            }
            if {$ref eq $id} {
                lappend problems "$id: names itself as related"
            }
        }
        foreach match [dict get $topic match] {
            if {[string first | $match] < 0} {
                lappend problems "$id: a match line is \"CODE | GLOB\": $match"
            }
        }
        foreach example [dict get $topic examples] {
            if {[dict get $example kind] eq "reject" && [dict get $example error] eq ""} {
                lappend problems "[dict get $example id]: a rejected example states its @error"
            }
            if {[dict get $example lines] eq ""} {
                lappend problems "[dict get $example id]: an example with no code"
            }
        }
        if {[string length [dict get $topic title]] > 78} {
            lappend problems "$id: a title fits one line (at most 78 characters)"
        }
        if {[string length [dict get $topic summary]] > 200} {
            lappend problems "$id: a summary is one sentence (at most 200 characters)"
        }
        # The text: every topic ID it mentions exists, and a hand-written
        # line of prose fits 80 columns once indented (code, indented four
        # or more, may be longer).
        foreach section [dict get $topic body] {
            foreach item [lindex $section 1] {
                lassign $item kind line
                if {$kind ne "text"} continue
                foreach ref [regexp -all -inline {\m(?:concept|rule|proof|error|warning|principle|backend|cli|capability|task|lint|index)\.[a-z0-9][a-z0-9-]*[a-z0-9]} $line] {
                    if {![dict exists [dict get $catalogue topics] $ref]} {
                        lappend problems "$id: the text names topic $ref, which does not exist"
                    }
                }
                if {[string length $line] > 76 && ![string match "    *" $line]
                        && ![string match generated/* [dict get $topic file]]} {
                    lappend problems "$id: a line of [string length $line] characters (at most 76): [string range $line 0 40]..."
                }
            }
        }
    }
    # A code or a symbol is documented by one topic.
    foreach table {codes symbols} what {code symbol} {
        dict for {key ids} [dict get $catalogue $table] {
            if {[llength $ids] > 1} {
                lappend problems "$what \"$key\" is documented by several topics: [join [lsort $ids] {, }]"
            }
        }
    }
    # An ID or an alias that two topics share is ambiguous (a code's last
    # word may be shared: `-help UNSUPPORTED` lists both codes); an alias that
    # is another topic's ID, code or symbol never finds its own topic.
    dict for {key entries} [dict get $catalogue cased] {
        set ranks [dict create]
        foreach entry $entries {
            dict lappend ranks [lindex $entry 0] [lindex $entry 1]
        }
        dict for {rank ids} $ranks {
            if {[llength $ids] > 1 && $rank != 2} {
                lappend problems "\"$key\" is [expr {$rank == 1 ? "an ID" : "an alias"}] of several topics: [join [lsort $ids] {, }]"
            }
        }
        set best [lindex [lsort -integer -index 0 $entries] 0 0]
        foreach entry $entries {
            if {[lindex $entry 0] == 3 && $best < 3} {
                lappend problems "alias \"$key\" of [lindex $entry 1] is shadowed by an ID, code or symbol of [lindex [lsort -integer -index 0 $entries] 0 1]"
            }
        }
    }
    dict for {key entries} [dict get $catalogue loose] {
        set ids [lsort -unique [lmap e $entries {lindex $e 1}]]
        if {[llength $ids] > 1 && [lsort -unique [lmap e $entries {lindex $e 0}]] eq {3}} {
            lappend problems "\"$key\" loosely names several topics: [join $ids {, }]"
        }
    }
    foreach name [dict keys $indices] {
        if {[dict get $catalogue members $name] eq ""} {
            lappend problems "index $name has no topics"
        }
    }
    return $problems
}

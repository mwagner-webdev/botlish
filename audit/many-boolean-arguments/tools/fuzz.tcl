# fuzz.tcl -- focused fuzzer for MANY-BOOLEAN-ARGUMENTS, the global warning
# modes and the conditional conversion law (WARNINGS-MANY-BOOLEAN-ARGUMENTS.md,
# "Fuzzing and the conversion law").
#
#   tclsh9.0 audit/many-boolean-arguments/tools/fuzz.tcl ?SEEDS? ?FIRST-SEED?
#   tclsh9.0 audit/many-boolean-arguments/tools/fuzz.tcl -show SEED
#     (prints the program SEED generates and its prediction)
#
# Each seed generates a program *model* -- callees and call sites known by
# construction -- and renders it to source. The model is rendered again, with
# one callee converted to flags, for the conversion law.
#
# Callees (`oK`) have 0-3 parameters of a proven-bool kind, each either
#   bool       declared `: bool`, or
#   inferred   untyped and forwarded to `weight`'s declared bool parameter
#              (`p.weight(W)`): the checker's TRUSTED inferred contract,
# 0-2 parameters of an unprovable kind, each either
#   unproven   untyped and only used as a condition (`p.pick(W)`, pick's
#              parameter is a checked condition): a CHECKED contract, not a
#              proof, or
#   any        declared `: any`,
# 0-2 subject parameters (`: int`, or untyped and used in arithmetic), all in
# random order; 0-2 flags; and, in some programs, a context parameter of a
# context struct C (never a parameter). The body sums one weighted term per
# parameter and flag (`W` a distinct power of two), so every parameter's value
# is visible in the result. The gate is the oracle's own: at least two
# parameters of a proven-bool kind and at least one of any other kind. Some
# programs also call probe natives registered here (milestone 2's probe
# style): `str::fz_opts` (int, bool, bool: past the gate), `str::fz_xor`
# (bool, bool: all bool) and `str::fz_one` (int, bool: one bool).
#
# Call sites pass, at each ordinary position: an Int at a subject, and at every
# other position a written literal (`true`/`false`), a computed bool
# (`N == N` / `N == M`, N unique per site) or a named binding (`yes`/`no`),
# per the site's mode (all literals, all computed, all bindings, mixed). They
# are spelled functionally, with method sugar (the receiver is position 1;
# never a computed receiver), or through an alias (`aK = oK`); they supply a
# random subset of the callee's flags; and they are placed at the top level,
# in a nested function, in a closure, in a statically dead branch, after a
# `return`, under a range-infeasible branch, or in a function nobody calls.
# Some unflagged callees are also passed as a function value and called
# through it with literals (`g(...)`), and returned by a function and called
# on its result (`getK()(...)`, a call the resolver's exact-callable
# provenance does resolve to the callee): both silent. Synthesized calls with two bool
# literals -- `[true, false]`, `true != false` -- appear in the result. About a
# third of the programs are quiet: at most one literal reaches a callee past
# the gate.
#
# THE ORACLE predicts, per written call site, warn or silent, the anchor (the
# call's start: its callee name, or a method call's receiver; columns counted
# in characters) and the literal count: a site warns iff it is a written call
# to a declared callee (source or native, an alias included, never a function
# value) past the gate, passes >= 2 literals at ordinary positions, and is in
# a structurally reachable placement (everything but dead and after-return).
# Another code can fire: METHOD-ELIGIBLE, at a reachable functional call (not
# through an alias) to a declared callee of >= 2 ordinary parameters whose
# first argument is not an operator expression. The oracle predicts those too,
# exactly; no third code can fire (no String literal, one exit per function,
# no list result, no `fail`, no `proves`). For every program it checks
#
#   default   compiles; the MANY-BOOLEAN-ARGUMENTS warnings are exactly the
#             prediction, counts included (a missed or mislocated one fails;
#             an unpredicted one is printed as EXTRA and counted, and the
#             summary must show 0; a site reported twice fails); the
#             METHOD-ELIGIBLE warnings are exactly theirs; any other code
#             fails
#   off       compiles; no warning, no pass ran (stats counter, execution
#             trace on the pass), and the HIR equals default's without its
#             side table
#   error     rejected iff a warning is predicted, with the code of the
#             sort-first predicted warning across both codes (location, then
#             code); compiles otherwise
#   HIR text  the program's HIR read back from hir::format text (which keeps
#             the declared bool parameters but no provenance marker) has no
#             MANY-BOOLEAN-ARGUMENTS warning
#
# and THE CONVERSION LAW, conditional. A source callee past the gate is
# CONVERT-NOW when it has at least one call site and every call site (in any
# placement, aliases included) passes a literal at every proven-bool position,
# and it is never used as a value. For each, the program is rendered again
# with that callee converted: its proven-bool parameters become flags named
# like the parameters (`flags :b1, :b2`, ahead of its own flags), each call's
# `true` at parameter P becomes `:P`, each `false` is dropped, a method call
# whose receiver was converted is spelled functionally. The rewritten program
# must compile, have no MANY-BOOLEAN-ARGUMENTS warning for that callee and
# exactly the original's for every other callee, and evaluate to the
# identical value on the reference interpreter. A callee with a computed or
# bound bool at a proven-bool position (computed-caller), one used as a value
# (function-value) and a native are catalogued, never a failure. The law tests
# a mapping, the parameter names; it prescribes none. For the catalog of why
# the warning is not autofixable, each convert-now callee with two converted
# parameters is also rewritten with those two flags SWAPPED at every call: the
# mis-mapped program must still compile (there is no arity safety net), and
# whether its value changed is recorded.
#
# Exits non-zero on any failure.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root surface surface.tcl]

set show ""
if {[lindex $argv 0] eq "-show"} {
    set show [lindex $argv 1]
    set argv {}
}
set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 300}]
set first [expr {[llength $argv] > 1 ? [lindex $argv 1] : 1}]

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}

proc chance {p} {
    return [expr {rand() < $p}]
}

proc census {key {n 1}} {
    dict incr ::census $key $n
}

proc shuffle {list} {
    set result {}
    while {[llength $list]} {
        set i [expr {int(rand() * [llength $list])}]
        lappend result [lindex $list $i]
        set list [lreplace $list $i $i]
    }
    return $result
}

# ---------------------------------------------------------------------------
# The probe natives (registered once; their values are the sum of their
# weighted arguments, as the source callees' are).

proc boolBit {v} {
    return [core::value::isTrue $v]
}
core::native::register str::fz_opts -arity 3 -param-types {int bool bool} -result-type int \
    -impl {apply {{s a b} {core::value::intFromNumber [expr {[core::value::intOf $s] + 2 * [boolBit $a] + 4 * [boolBit $b]}]}}}
core::native::register str::fz_xor -arity 2 -param-types {bool bool} -result-type int \
    -impl {apply {{a b} {core::value::intFromNumber [expr {[boolBit $a] + 2 * [boolBit $b]}]}}}
core::native::register str::fz_one -arity 2 -param-types {int bool} -result-type int \
    -impl {apply {{s a} {core::value::intFromNumber [expr {[core::value::intOf $s] + 2 * [boolBit $a]}]}}}
set ::natives [dict create \
    str::fz_opts {params {{s int} {a bool} {b bool}}} \
    str::fz_xor {params {{a bool} {b bool}}} \
    str::fz_one {params {{s int} {a bool}}}]

# The kinds of an ordinary parameter, and whether the gate counts it as bool.
proc boolKind {kind} {
    return [expr {$kind in {bool inferred}}]
}

# ---------------------------------------------------------------------------
# The model

# A callee: {name NAME native 0|1 params {{NAME KIND}...} flags NAMES context
# 0|1 alias NAME-or-"" value 0|1}. KIND: bool inferred unproven any int
# subject.
proc newCallee {k hasContext} {
    set params {}
    set nbool [pick {0 1 1 2 2 2 3 3 3}]
    # Unprovable parameters are subjects to the gate, never bools: often the
    # only subject, or the would-be second bool of a one-bool callee.
    set nunp [pick {0 0 1 1 2}]
    set nsub [pick {0 0 1 1 2}]
    if {$nbool + $nunp + $nsub == 0} {
        set nsub 1
    }
    for {set i 0} {$i < $nbool} {incr i} {
        lappend params [list b${k}_$i [pick {bool bool inferred}]]
    }
    for {set i 0} {$i < $nunp} {incr i} {
        lappend params [list u${k}_$i [pick {unproven unproven any}]]
    }
    for {set i 0} {$i < $nsub} {incr i} {
        lappend params [list s${k}_$i [pick {int subject}]]
    }
    set flags {}
    set nflags [pick {0 0 0 1 2}]
    for {set i 0} {$i < $nflags} {incr i} {
        lappend flags f${k}_$i
    }
    set context [expr {$hasContext && [chance 0.35]}]
    # Literal callers: every call of this callee passes literals (the
    # convert-now class, when it is past the gate and never a value).
    set callee [dict create name o$k native 0 params [shuffle $params] flags $flags context $context alias "" value 0 \
        literalCallers [chance 0.4]]
    if {!$context && [chance 0.2]} {
        dict set callee alias a$k
    }
    if {!$context && $flags eq "" && [chance 0.25]} {
        # Passed as a value and called through it with these arguments.
        dict set callee value 1
        dict set callee valueArgs [lmap p [dict get $callee params] {
            expr {[lindex $p 1] in {int subject} ? 1 : [pick {true false}]}
        }]
    }
    return $callee
}

proc gate {callee} {
    set bools 0
    set others 0
    foreach param [dict get $callee params] {
        if {[boolKind [lindex $param 1]]} { incr bools } else { incr others }
    }
    return [expr {$bools >= 2 && $others >= 1}]
}

# The argument at a position of KIND for a site in MODE: {KIND TEXT} with
# KIND literal / computed / binding / int.
proc newArg {kind mode n} {
    if {$kind in {int subject}} {
        return [list int [expr {int(rand() * 10)}]]
    }
    switch -- $mode {
        literals { set how literal }
        computed { set how computed }
        bindings { set how binding }
        default  { set how [pick {literal literal computed binding}] }
    }
    switch -- $how {
        literal  { return [list literal [pick {true false}]] }
        computed { return [list computed [expr {[chance 0.5] ? "$n == $n" : "$n == [expr {$n + 1}]"}]] }
        binding  { return [list binding [pick {yes no}]] }
    }
}

# A call site of CALLEE: {id I callee NAME spelling S placement P args
# {{KIND TEXT}...} supplied FLAGS}. QUIET: at most one literal.
proc newSite {i callee quiet} {
    set mode [pick {literals literals mixed mixed computed bindings}]
    if {[dict exists $callee literalCallers] && [dict get $callee literalCallers]} {
        set mode literals
    }
    if {$quiet} {
        set mode [pick {computed bindings mixed}]
    }
    set args {}
    set n [expr {100 + $i * 3}]
    set literals 0
    foreach param [dict get $callee params] {
        set arg [newArg [lindex $param 1] $mode $n]
        if {$quiet && [lindex $arg 0] eq "literal"} {
            if {$literals >= 1} {
                set arg [list binding [pick {yes no}]]
            }
            incr literals
        }
        lappend args $arg
        incr n 7
    }
    set spellings {functional functional method}
    if {[dict get $callee alias] ne ""} {
        lappend spellings alias
    }
    set spelling [pick $spellings]
    if {$spelling eq "method" && ([llength $args] == 0 || [lindex $args 0 0] eq "computed")} {
        set spelling functional
    }
    set supplied {}
    foreach flag [dict get $callee flags] {
        if {[chance 0.5]} {
            lappend supplied $flag
        }
    }
    return [dict create id $i callee [dict get $callee name] spelling $spelling \
        placement [pick {top top top nested closure dead after range uncalled}] args $args supplied $supplied]
}

proc generate {seed} {
    expr {srand($seed)}
    set model [dict create quiet [chance 0.33] context [chance 0.3] natives [chance 0.4] \
        callees {} sites {} synthesized [chance 0.5]]
    set callees {}
    set count [expr {2 + int(rand() * 3)}]
    for {set k 0} {$k < $count} {incr k} {
        lappend callees [newCallee $k [dict get $model context]]
    }
    if {[dict get $model natives]} {
        foreach name [dict keys $::natives] {
            lappend callees [dict create name $name native 1 params [dict get $::natives $name params] \
                flags {} context 0 alias "" value 0 literalCallers 0]
        }
    }
    dict set model callees $callees
    set sites {}
    set i 0
    foreach callee $callees {
        # A callee with no call site at all is the no-sites class: nothing
        # to state, nothing to convert.
        set n [pick {0 1 1 2 2 3 3}]
        for {set j 0} {$j < $n} {incr j} {
            lappend sites [newSite $i $callee [dict get $model quiet]]
            incr i
        }
    }
    dict set model sites [shuffle $sites]
    return $model
}

# ---------------------------------------------------------------------------
# Rendering. CONVERT names the callee to render converted to flags ("" for
# none), SWAP 1 maps its first two converted flags the wrong way round. The
# result is {SOURCE PLACED}: PLACED one dict per site with its line, col.

proc emit {text} {
    lappend ::lines $text
}

proc calleeOf {model name} {
    foreach callee [dict get $model callees] {
        if {[dict get $callee name] eq $name} {
            return $callee
        }
    }
    error "no callee $name"
}

# The converted positions of CALLEE (the proven-bool parameters) when it is
# CONVERT, else none.
proc converted {callee convert} {
    if {[dict get $callee name] ne $convert} {
        return {}
    }
    set positions {}
    set i 0
    foreach param [dict get $callee params] {
        if {[boolKind [lindex $param 1]]} {
            lappend positions $i
        }
        incr i
    }
    return $positions
}

proc renderCallee {callee convert} {
    set conv [converted $callee $convert]
    set ordinary {}
    set flags {}
    set i 0
    foreach param [dict get $callee params] {
        lassign $param name kind
        if {$i in $conv} {
            lappend flags $name
        } else {
            switch -- $kind {
                bool    { lappend ordinary "$name: bool" }
                any     { lappend ordinary "$name: any" }
                int     { lappend ordinary "$name: int" }
                default { lappend ordinary $name }
            }
        }
        incr i
    }
    lappend flags {*}[dict get $callee flags]
    set sections $ordinary
    if {$flags ne ""} {
        lappend sections "flags [join [lmap f $flags {string cat : $f}] {, }]"
    }
    if {[dict get $callee context]} {
        lappend sections "context c: C"
    }
    emit "fn [dict get $callee name]([join $sections {, }]) -> int:"
    set terms {}
    set w 1
    set t 0
    foreach name [concat [lmap p [dict get $callee params] {lindex $p 0}] [dict get $callee flags]] {
        set kind [expr {[string match f* $name] ? "flag" : [lindex [lsearch -inline -index 0 [dict get $callee params] $name] 1]}]
        switch -- $kind {
            bool - inferred - flag { emit "    t$t = $name.weight($w)" }
            unproven - any         { emit "    t$t = $name.pick($w)" }
            int - subject          { emit "    t$t = $name * $w" }
        }
        lappend terms t$t
        incr t
        set w [expr {$w * 2}]
    }
    if {[dict get $callee context]} {
        lappend terms c.v
    }
    emit "    [join $terms { + }]"
}

# The call text of SITE and the offset of its anchor in it.
proc callText {model site convert swap} {
    set callee [calleeOf $model [dict get $site callee]]
    set conv [converted $callee $convert]
    set args {}
    set newFlags {}
    set i 0
    set names [lmap p [dict get $callee params] {lindex $p 0}]
    set convNames [lmap c $conv {lindex $names $c}]
    foreach arg [dict get $site args] {
        lassign $arg kind text
        if {$i in $conv} {
            if {$kind ne "literal"} {
                error "converting a non-literal argument"
            }
            if {$text eq "true"} {
                set name [lindex $names $i]
                if {$swap} {
                    # The wrong mapping: the first two converted names swap.
                    set a [lindex $convNames 0]
                    set b [lindex $convNames 1]
                    set name [expr {$name eq $a ? $b : $name eq $b ? $a : $name}]
                }
                lappend newFlags $name
            }
        } else {
            lappend args $text
        }
        incr i
    }
    set flags [concat $newFlags [dict get $site supplied]]
    set spelling [dict get $site spelling]
    if {$spelling eq "method" && 0 in $conv} {
        set spelling functional
    }
    set flagTexts [lmap f $flags {string cat : $f}]
    set name [dict get $callee name]
    switch -- $spelling {
        functional - alias {
            set head [expr {$spelling eq "alias" ? [dict get $callee alias] : $name}]
            return [list "$head\([join [concat $args $flagTexts] {, }])" 0]
        }
        method {
            set receiver [lindex $args 0]
            set short [lindex [split $name :] end]
            return [list "$receiver.$short\([join [concat [lrange $args 1 end] $flagTexts] {, }])" 0]
        }
    }
}

# Emits LINE-PREFIX + the call of SITE + SUFFIX as the next line, recording
# the call's anchor.
proc emitCall {model site prefix suffix convert swap} {
    lassign [callText $model $site $convert $swap] text offset
    set placed $site
    dict set placed line [expr {[llength $::lines] + 1}]
    dict set placed col [expr {[string length $prefix] + $offset + 1}]
    lappend ::placed $placed
    emit "$prefix$text$suffix"
}

proc render {model {convert ""} {swap 0}} {
    set ::lines {}
    set ::placed {}
    if {[dict get $model natives]} {
        emit "import str"
    }
    foreach line {
        "fn weight(bit: bool, w: int) -> int:" "    if bit:" "        return w" "    0"
        "fn pick(c, w: int) -> int:" "    if c:" "        return w" "    0"
        "yes = true" "no = false"
    } {
        emit $line
    }
    if {[dict get $model context]} {
        foreach line {"context struct C:" "    v: int" "with context C {v: 64}"} {
            emit $line
        }
    }
    set results {}
    foreach callee [dict get $model callees] {
        if {[dict get $callee native]} continue
        renderCallee $callee $convert
        if {[dict get $callee alias] ne ""} {
            emit "[dict get $callee alias] = [dict get $callee name]"
        }
        if {[dict get $callee value]} {
            # A function-value call: the callee passed to `g` and called
            # through it, with literals. Never a candidate.
            set k [string range [dict get $callee name] 1 end]
            emit "fn callv$k\(x, g) -> int:"
            emit "    g([join [dict get $callee valueArgs] {, }])"
            lappend results "1.callv$k\([dict get $callee name])"
            # ... and returned by a function and called on its result.
            emit "fn get$k\():"
            emit "    [dict get $callee name]"
            lappend results "get$k\()([join [dict get $callee valueArgs] {, }])"
        }
    }
    foreach site [dict get $model sites] {
        set i [dict get $site id]
        switch -- [dict get $site placement] {
            top {
                emitCall $model $site "r$i = " "" $convert $swap
                lappend results r$i
                continue
            }
            nested - closure {
                emit "fn h$i\(x):"
                emit "    fn inner(y):"
                if {[dict get $site placement] eq "closure"} {
                    emit "        z = x + y"
                }
                emitCall $model $site "        " "" $convert $swap
                emit "    inner(x)"
            }
            dead {
                emit "fn h$i\(x):"
                emit "    if 1 == 2:"
                emitCall $model $site "        return " "" $convert $swap
                emit "    x"
            }
            after {
                emit "fn h$i\(x):"
                emit "    if x == 1:"
                emit "        return x"
                emit "    else:"
                emit "        return x + 1"
                emitCall $model $site "    return " "" $convert $swap
            }
            range {
                emit "fn h$i\(x):"
                emit "    if x < 0:"
                emit "        if x > 5:"
                emitCall $model $site "            return " "" $convert $swap
                emit "    x"
            }
            uncalled {
                emit "fn h$i\(x):"
                emit "    if x == x:"
                emitCall $model $site "        return " "" $convert $swap
                emit "    x"
            }
        }
        if {[dict get $site placement] ne "uncalled"} {
            lappend results "h$i\(1)"
        }
    }
    if {[dict get $model synthesized]} {
        lappend results {[true, false]} {true != false}
    }
    emit "\[[join $results {, }]\]"
    return [list [join $::lines \n] $::placed]
}

# ---------------------------------------------------------------------------
# The oracle

# {LINE COL COUNT} per predicted MANY-BOOLEAN-ARGUMENTS warning, and {LINE
# COL} per predicted METHOD-ELIGIBLE warning, of the rendered sites PLACED.
proc predict {model placed} {
    set many {}
    set eligible {}
    foreach site $placed {
        if {[dict get $site placement] in {dead after}} continue
        set callee [calleeOf $model [dict get $site callee]]
        set literals 0
        foreach arg [dict get $site args] {
            if {[lindex $arg 0] eq "literal"} {
                incr literals
            }
        }
        if {[gate $callee] && $literals >= 2} {
            lappend many [list [dict get $site line] [dict get $site col] $literals]
        }
        if {[dict get $site spelling] eq "functional" && [llength [dict get $callee params]] >= 2
                && [lindex [dict get $site args] 0 0] ne "computed"} {
            lappend eligible [list [dict get $site line] [dict get $site col]]
        }
    }
    return [list [lsort -dictionary $many] [lsort -dictionary $eligible]]
}

# A callee's class: convert-now, computed-caller, function-value, native,
# below-gate or no-sites.
proc classify {model callee} {
    if {[dict get $callee native]} {
        return native
    }
    if {![gate $callee]} {
        return below-gate
    }
    if {[dict get $callee value]} {
        return function-value
    }
    set sites 0
    foreach site [dict get $model sites] {
        if {[dict get $site callee] ne [dict get $callee name]} continue
        incr sites
        set i 0
        foreach param [dict get $callee params] {
            if {[boolKind [lindex $param 1]] && [lindex [dict get $site args] $i 0] ne "literal"} {
                return computed-caller
            }
            incr i
        }
    }
    return [expr {$sites ? "convert-now" : "no-sites"}]
}

if {$show ne ""} {
    set model [generate $show]
    lassign [render $model] source placed
    lassign [predict $model $placed] many eligible
    puts "$source\n--- predicted MANY-BOOLEAN-ARGUMENTS (line col literals): $many\n--- predicted METHOD-ELIGIBLE: $eligible"
    foreach callee [dict get $model callees] {
        puts "--- [dict get $callee name]: [classify $model $callee]"
    }
    exit 0
}

# ---------------------------------------------------------------------------
# Checking

proc compileMode {source mode} {
    return [surface::compile $source fuzz.bot -warnings $mode -warning-channel ""]
}

# {LINE COL ...} of each warning of HIR with CODE (and the literal count for
# this warning).
proc warningsOf {hir code} {
    set result {}
    foreach w [hir::warnings::of $hir] {
        if {[dict get $w code] ne $code} continue
        set at [lrange [dict get $w primary] 2 end]
        set entry [list [dict get $at line] [dict get $at column]]
        if {$code eq "MANY-BOOLEAN-ARGUMENTS"} {
            lappend entry [dict get $w data literals]
        }
        lappend result $entry
    }
    return [lsort -dictionary $result]
}

# CALLEE NAME -> number of MANY-BOOLEAN-ARGUMENTS warnings, of HIR.
proc perCallee {hir} {
    set counts [dict create]
    foreach w [hir::warnings::of $hir] {
        if {[dict get $w code] eq "MANY-BOOLEAN-ARGUMENTS"} {
            dict incr counts [dict get $w data calleeName]
        }
    }
    return $counts
}

proc valueOf {hir} {
    if {[catch {core::formatValue [core::evalProgram [hir::lower $hir]]} v options]} {
        return [list error [dict get $options -errorcode]]
    }
    return [list value $v]
}

set ::census [dict create]
set ::catalog [dict create]
set failures 0
set extras 0
set warned 0
set clean 0
set lawHeld 0
set lawChecked 0
set lawFailures 0
set swapped 0
set swapChanged 0
set swapSame 0
for {set seed $first} {$seed < $first + $seeds} {incr seed} {
    set model [generate $seed]
    lassign [render $model] source placed
    lassign [predict $model $placed] predicted eligible
    foreach site [dict get $model sites] {
        census [dict get $site placement]
        census [dict get $site spelling]
    }
    if {[dict get $model quiet]} { census quietPrograms }
    if {[dict get $model context]} { census contextPrograms }
    if {[dict get $model natives]} { census nativePrograms }
    set problems {}
    if {[catch {compileMode $source default} hir options]} {
        lappend problems "default mode did not compile: $hir"
    } else {
        foreach w [hir::warnings::of $hir] {
            if {[dict get $w code] ni {MANY-BOOLEAN-ARGUMENTS METHOD-ELIGIBLE}} {
                lappend problems "unexpected code [dict get $w code]: [dict get $w message]"
            } elseif {[dict get $w secondary] ne ""} {
                lappend problems "a warning with secondary locations"
            }
        }
        set actual [warningsOf $hir MANY-BOOLEAN-ARGUMENTS]
        foreach p $predicted {
            if {$p ni $actual} {
                lappend problems "MISSED predicted warning $p (actual: $actual)"
            }
        }
        if {[llength $actual] != [llength [lsort -unique $actual]]} {
            lappend problems "a site was reported more than once: $actual"
        }
        foreach a $actual {
            if {$a ni $predicted} {
                puts "EXTRA seed $seed: warning $a is not predicted:\n$source"
                incr extras
            }
        }
        set actualEligible [warningsOf $hir METHOD-ELIGIBLE]
        if {$actualEligible ne $eligible} {
            lappend problems "METHOD-ELIGIBLE warnings $actualEligible, predicted $eligible"
        }
        # off: compiles, silently, runs no warning pass, same HIR.
        hir::warnings::resetStats
        set ::passCalls 0
        trace add execution hir::warnings::ManyBooleanArguments enter {apply {{args} {incr ::passCalls}}}
        try {
            set offFailed [catch {compileMode $source off} off]
        } finally {
            trace remove execution hir::warnings::ManyBooleanArguments enter {apply {{args} {incr ::passCalls}}}
        }
        if {$offFailed} {
            lappend problems "off mode did not compile: $off"
        } elseif {[hir::warnings::of $off] ne "" || [hir::warnings::stats] ne "" || $::passCalls != 0} {
            lappend problems "off mode ran or reported warnings"
        } elseif {$off ne [dict remove $hir warnings]} {
            lappend problems "HIR differs between off and default"
        }
        # error: rejected iff a warning is predicted, with the sort-first
        # predicted warning's code (location, then code).
        set all [concat [lmap p $predicted {list [lindex $p 0] [lindex $p 1] MANY-BOOLEAN-ARGUMENTS}] \
            [lmap p $eligible {list [lindex $p 0] [lindex $p 1] METHOD-ELIGIBLE}]]
        set all [lsort -command {apply {{a b} {
            foreach i {0 1} {
                if {[lindex $a $i] != [lindex $b $i]} {
                    return [expr {[lindex $a $i] < [lindex $b $i] ? -1 : 1}]
                }
            }
            return [string compare [lindex $a 2] [lindex $b 2]]
        }}} $all]
        set firstCode [lindex $all 0 2]
        set rejected [catch {compileMode $source error} message options]
        if {$rejected} {
            if {$all eq ""} {
                lappend problems "error mode rejected a program with no predicted warning: $message"
            } elseif {[dict get $options -errorcode] ne [list CORE SEMANTIC $firstCode]} {
                lappend problems "error mode rejected with [dict get $options -errorcode], predicted $firstCode: $message"
            }
        } elseif {$all ne ""} {
            lappend problems "error mode accepted a program with a predicted warning"
        }
        # HIR text: the declared bool parameters survive, the provenance
        # marker does not.
        if {[catch {hir::parse [hir::format $off]} parsed]} {
            census hirTextUnreadable
        } else {
            census hirTextRead
            set textual [lmap w [hir::warnings::collect $parsed] {
                if {[dict get $w code] ne "MANY-BOOLEAN-ARGUMENTS"} continue
                set w
            }]
            if {$textual ne ""} {
                lappend problems "HIR text input (no provenance marker) warns: [llength $textual] warnings"
            }
        }
        # The conversion law, per convert-now callee.
        set value [valueOf $hir]
        set original [perCallee $hir]
        foreach callee [dict get $model callees] {
            set class [classify $model $callee]
            dict incr ::catalog $class
            if {$class ne "convert-now"} continue
            incr lawChecked
            set name [dict get $callee name]
            set law {}
            lassign [render $model $name] rewritten
            if {[catch {compileMode $rewritten default} rhir]} {
                lappend law "the rewrite does not compile: $rhir"
            } else {
                set expected [dict remove $original $name]
                set after [perCallee $rhir]
                if {[dict exists $after $name]} {
                    lappend law "the converted callee still warns ([dict get $after $name])"
                }
                if {[lsort -stride 2 $after] ne [lsort -stride 2 $expected]} {
                    lappend law "other callees' warnings changed: $after, expected $expected"
                }
                set rvalue [valueOf $rhir]
                if {$rvalue ne $value} {
                    lappend law "the rewrite's value is $rvalue, not $value"
                }
            }
            if {$law eq ""} {
                incr lawHeld
            } else {
                incr lawFailures
                lappend problems "CONVERSION LAW for $name: [join $law {; }]\n--- rewritten:\n$rewritten"
            }
            # The mis-mapped rewrite (catalog): compiles, value changed or not.
            if {[llength [converted $callee $name]] >= 2} {
                lassign [render $model $name 1] mismapped
                incr swapped
                if {[catch {compileMode $mismapped off} mhir]} {
                    lappend problems "the mis-mapped rewrite of $name does not compile: $mhir"
                } elseif {[valueOf $mhir] eq $value} {
                    incr swapSame
                } else {
                    incr swapChanged
                }
            }
        }
        if {$actual eq ""} { incr clean } else { incr warned }
    }
    if {$problems ne ""} {
        incr failures
        puts "FAIL seed $seed:\n[join $problems \n]\n--- source:\n$source"
    }
}
set c $::census
proc get {c key} {
    return [expr {[dict exists $c $key] ? [dict get $c $key] : 0}]
}
set cat $::catalog
puts "callee classes: convert-now [get $cat convert-now], computed-caller [get $cat computed-caller], function-value [get $cat function-value], native [get $cat native], below-gate [get $cat below-gate], no-sites [get $cat no-sites]; mis-mapped rewrites (two flags swapped at every call) $swapped, all compiled, value changed $swapChanged, value unchanged $swapSame"
puts "seeds $seeds (from $first): $warned with warnings, $clean without; failures $failures; extra warnings $extras; conversion law $lawHeld of $lawChecked convert-now callees, failures $lawFailures; placements top [get $c top], nested [get $c nested], closure [get $c closure], dead [get $c dead], after [get $c after], range [get $c range], uncalled [get $c uncalled]; spellings functional [get $c functional], method [get $c method], alias [get $c alias]; quiet programs [get $c quietPrograms], context programs [get $c contextPrograms], native programs [get $c nativePrograms]; HIR text read [get $c hirTextRead], unreadable [get $c hirTextUnreadable]"
exit [expr {$failures > 0 || $extras > 0}]

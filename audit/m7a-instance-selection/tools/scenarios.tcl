#!/usr/bin/env tclsh9.0
# scenarios.tcl -- M7.a synthetic/adversarial observation scenarios
# (M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md). Each scenario compiles a small
# program (non-strict, so an *illegal* program's analysis can be observed
# too -- its diagnostics are always printed first) and reports, for the
# named functions only: instance keys, generic/open status, per-parameter
# declared/view/entry facts, captured seeds, reachable conditions with
# their ConditionOutcome and deciding fact tier, NIR op counts, and (where
# relevant) the hir/completions.tcl facts stamped on exact calls.
#
# Observation only: these are "audit helper says current result = X"
# outputs (spec #59), not compiler contracts. Nothing here is a test.
#
#   tclsh9.0 audit/m7a-instance-selection/tools/scenarios.tcl ?NAME-GLOB?

source [file join [file dirname [file normalize [info script]]] lib.tcl]

set pattern [expr {[llength $argv] ? [lindex $argv 0] : "*"}]

proc completions {hir names} {
    set lines {}
    foreach e [lsort -dictionary [dict keys [dict get $hir exprs]]] {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] ne "call" || ![dict exists $node effectiveErrors]} continue
        lassign [dict get $node target] tk tt
        if {$tk ne "block"} continue
        set callee [hir::aot::BlockName $hir $tt]
        if {$callee ni $names} continue
        set rr [expr {[dict exists $node resultRangeFact] ? [hir::range::show [dict get $node resultRangeFact]] : "-"}]
        lappend lines "    completion: call $e [m7a::Where $hir $e] -> $callee effectiveErrors={[dict get $node effectiveErrors]} mayReturnNormally=[dict get $node mayReturnNormally] resultRangeFact=$rr"
    }
    return [join $lines \n]
}

proc scenario {name question src names {extra ""}} {
    if {![string match $::pattern $name]} return
    puts "=============================================================================="
    puts "$name -- $question"
    puts "------------------------------------------------------------------------------"
    puts [string trimright $src]
    puts "------------------------------------------------------------------------------"
    set hir [m7a::source $src]
    set diags [m7a::diagnostics $hir]
    puts "diagnostics ([llength $diags]): [expr {$diags eq {} ? {none (legal program)} : [join $diags {; }]}]"
    set a [m7a::analyze $hir]
    puts [m7a::instances $hir $a $names]
    set c [m7a::conditions $hir $a $names]
    if {$c ne ""} { puts $c }
    set comp [completions $hir $names]
    if {$comp ne ""} { puts $comp }
    if {[catch {m7a::nir $hir -tiny-leaf-inline-opt 0} nir]} {
        puts "    NIR: ERROR $nir"
    } else {
        dict for {f counts} [m7a::nirCounts $nir] {
            set fname [lindex [regexp -inline {^\d+ (.*)<} $f] 1]
            if {$fname ni $names} continue
            puts "    NIR $f: [join [lmap {k v} $counts {string cat $k = $v}] { }]"
        }
    }
    if {$extra ne ""} { uplevel #0 [list apply [list {hir a} $extra] $hir $a] }
    puts ""
}

set F {fn f(x):
    if x < 100:
        1
    else:
        2
}

# ---------------------------------------------------------------------------
# Scalar literal values and shared callers (spec #18, #28, #29, #46)

scenario S01-literals-share-int-instance {do f(1) and f(2) share one f<int>? (is a literal value part of identity?)} \
    "$F\nf(1)\nf(2)\n" {f}
scenario S02a-single-narrow-caller {one narrow caller} "$F\nf(5)\n" {f}
scenario S02b-two-compatible-callers {two narrow compatible callers} "$F\nf(5)\nf(9)\n" {f}
scenario S02c-two-disjoint-callers {two disjoint narrow callers spanning the threshold} "$F\nf(5)\nf(500)\n" {f}
scenario S02d-narrow-plus-broad {narrow + broad (collection-length) caller} \
    "$F\nfn g(y):\n    f(y)\nf(5)\ng(length(\"abc\"))\n" {f g}
scenario S02e-narrow-plus-open {narrow + a caller reached through dynamic dispatch (legal: untyped, handled)} \
    "$F\nfn g(y):\n    f(y + 0)\nfn apply(k, v):\n    k(v)\nf(5)\napply(g, 3)\n" {f g apply}
scenario S02f-alias-materializes-callee {an exact alias call (h = g; h(3)) stays exact, but materializing g creates an open g<generic> that calls f<generic>} \
    "$F\nfn g(y):\n    f(y)\nh = g\nf(5)\nh(3)\n" {f g}

# ---------------------------------------------------------------------------
# The M5/M6 byte::from_int shared-instance case (spec #19)

scenario S03a-from-int-safe-only {byte::from_int(45) as the instance's only caller} \
    {byte::from_int(45)
} {byte::from_int}
scenario S03b-from-int-plus-legal-open-caller {byte::from_int(45) + a legal (handled, untyped) caller reached only through callvalue} \
    {byte::from_int(45)
fn dyn(m):
    r = byte::from_int(m + 0):
        on BelowRange:
            0
        on AboveRange:
            255
    r
fn caller(g, v):
    g(v)
caller(dyn, 45)
} {byte::from_int dyn caller}
scenario S03c-from-int-m6-fixture-as-written {the M6 condition-outcome-12 / M5 shared-instance fixture, compiled as written (non-strict): note its diagnostics} \
    {byte::from_int(45)
fn dyn(m: int) -> Byte errors BelowRange, AboveRange:
    byte::from_int(m)
fn caller(g, v) -> Byte errors BelowRange, AboveRange:
    g(v)
caller(dyn, 45)
} {byte::from_int dyn caller}

# ---------------------------------------------------------------------------
# Declared scalar refined-Int domains (spec #12, #13)

scenario S04-refined-domains {Byte / Small / LowNibble / HighNibble declared parameters: key, view, entry, exact set, branch outcome} \
    {type Small = Int in 10..20
fn fb(b: Byte):
    if b < 0:
        1
    else:
        if b > 200:
            2
        else:
            3
fn fs(s: Small):
    if s < 10:
        1
    else:
        2
fn fl(n: LowNibble):
    if n > 15:
        1
    else:
        2
fn fh(h: HighNibble):
    if h == 17:
        1
    else:
        if h < 16:
            2
        else:
            3
fb(byte::from_int(7))
fs(15)
fl(byte::low_nibble(200))
fh(byte::high_nibble(200))
} {fb fs fl fh}
scenario S04b-undeclared-refined-caller {undeclared parameter, every exact caller passes a Byte: RefineParams evidence (entry theorem), not identity} \
    {fn f(x):
    if x > 255:
        1
    else:
        2
f(byte::from_int(7))
f(byte::complement(byte::from_int(8)))
} {f}

# ---------------------------------------------------------------------------
# Applied List[T] (spec #14, #37, questions 15-19)

scenario S05a-declared-list-empty {declared List[int] parameter, argument []} \
    {fn g(xs: List[int]) -> int:
    list_length(xs)
g([])
} {g}
scenario S05b-declared-list-nonempty {declared List[int] parameter, argument [1, 2, 3]} \
    {fn g(xs: List[int]) -> int:
    list_length(xs)
g([1, 2, 3])
} {g}
scenario S05c-undeclared-list-empty-and-nonempty {undeclared list parameter: [] and [1, 2]} \
    {fn g(xs):
    loop x in xs:
        x + 1
g([])
g([1, 2])
} {g}
scenario S05d-declared-list-byte-specialized {declared List[Byte] reached by an exact caller: does the specialized instance keep the element domain?} \
    {fn f(xs: List[Byte]) -> int:
    b = list_get(xs, 0)
    if b > 255:
        1
    else:
        2
f([byte::from_int(1), byte::from_int(2)])
} {f}
scenario S05e-declared-list-byte-generic-and-specialized {same function, also materialized (alias) so its generic instance is used: compare the two instances} \
    {fn f(xs: List[Byte]) -> int:
    b = list_get(xs, 0)
    if b > 255:
        1
    else:
        2
g = f
g([byte::from_int(1), byte::from_int(2)])
} {f}
scenario S05f-encode-utf8-to-list-byte {encode_utf8's result passed to a declared List[Byte] parameter} \
    {fn f(xs: List[Byte]) -> int:
    list_length(xs)
byte::from_int(1)
f(encode_utf8("a"))
} {f} {
    foreach e [dict keys [dict get $hir exprs]] {
        if {[hir::kind $hir $e] eq "call" && [lindex [hir::get $hir $e target] 0] eq "native"
                && [dict get [hir::symbol $hir [lindex [hir::get $hir $e target] 1]] name] eq "encode_utf8"} {
            puts "    raw static type of encode_utf8(...): [list [hir::typeOf $hir $e]]"
        }
        if {[hir::kind $hir $e] eq "block" && [lindex [hir::get $hir $e declaredParamTypes] 0] ne ""} {
            puts "    raw declared parameter type: [list [lindex [hir::get $hir $e declaredParamTypes] 0]]"
        }
    }
}

# ---------------------------------------------------------------------------
# ImmutableSet[T] (spec #15, #38)

scenario S06a-declared-set {declared ImmutableSet[Byte] parameter} \
    {fn f(s: ImmutableSet[Byte], b: Byte) -> bool:
    immutable_set_contains(s, b)
f(byte::set(['a']), byte::from_int(3))
} {f}
scenario S06b-undeclared-set-and-empty-set {undeclared set parameter; a Byte set and an empty set share one instance} \
    {fn f(s, b):
    immutable_set_contains(s, b)
f(byte::set(['a']), byte::from_int(3))
f(immutable_set_from_list([]), byte::from_int(4))
} {f}
scenario S06c-module-retained-set {module-retained ImmutableSet[Byte] captured by a module function (web::is_unreserved shape)} \
    {s = byte::set(['-', '.'])
fn member(b: Byte) -> bool:
    immutable_set_contains(s, b)
member(byte::from_int(45))
} {member}

# ---------------------------------------------------------------------------
# Callable identity (spec #10, #11, #25, questions 20-24)

scenario S07a-callable-parameter {an exact callable forwarded through an untyped parameter} \
    {fn foo(x):
    x + 1
fn bar(x):
    x + 2
fn apply(f, x):
    f(x)
apply(foo, 1)
apply(bar, 2)
} {apply foo bar}
scenario S07b-callable-alias-capture {an immutable alias captured by another function} \
    {fn foo(x):
    x + 1
g = foo
fn user(y):
    g(y)
user(3)
} {user foo}
scenario S07c-typed-callable-argument {a typed (Bearing) callable passed as an ordinary argument} \
    {fn take(b: Byte):
    b
fn apply(f, x):
    f(x)
apply(take, byte::from_int(3))
} {apply take}
scenario S07d-callable-through-result {a closure returned by a function and called through the result binding} \
    {fn mk(n):
    fn add(x):
        x + n
    add
h = mk(1)
h(5)
k = mk(2)
k(7)
} {mk add}

# ---------------------------------------------------------------------------
# Closure environments and captures (spec #23-26)

scenario S08a-closure-int-capture {same block, different Int environment values (mk(1), mk(2))} \
    {fn mk(n):
    fn add(x):
        if n > 100:
            x
        else:
            x + n
    add(10)
mk(1)
mk(2)
} {mk add}
scenario S08b-closure-str-capture {same shape with a Str capture} \
    {fn mk(s):
    fn add(x):
        concat(s, x)
    add("a")
mk("p")
mk("q")
} {mk add}
scenario S08c-closure-declared-capture {a captured declared-Byte binding: does the capture's domain reach the closure?} \
    {fn mk(n: Byte):
    fn inner(x):
        if n > 255:
            x
        else:
            x + 1
    inner(1)
mk(byte::from_int(5))
} {mk inner}

# ---------------------------------------------------------------------------
# Completion facts vs instance identity (spec #40-41)

scenario S09-completion-per-call-shared-instance {different per-call effectiveErrors, one shared instance} \
    {byte::from_int(45)
fn dyn(m):
    r = byte::from_int(m + 0):
        on BelowRange:
            0
        on AboveRange:
            255
    r
dyn(1000)
} {byte::from_int dyn}

# ---------------------------------------------------------------------------
# Container contents (spec #32, #54)

scenario S10-byte-set-literal-and-dynamic {byte::set punctuation literal + a dynamic byte::set caller} \
    {p = byte::set(['-', '.', '_', '~'])
fn dyn(chars):
    r = byte::set(chars):
        on AboveRange:
            p
    r
dyn(['A'])
} {byte::set byte::from_int dyn}

# ---------------------------------------------------------------------------
# not / != composition (spec #34)

scenario S11-not-and-ne {x is the single point 5: x == 3 is decided; what about x != 3 and not(x < 0)?} \
    {fn f(x):
    a = if x == 3:
        1
    else:
        2
    b = if x != 3:
        1
    else:
        2
    c = if not (x < 0):
        1
    else:
        2
    a + b + c
f(5)
} {f}

# ---------------------------------------------------------------------------
# Narrowed / impossible hypotheses (spec #35-36, questions 40-45)

scenario S12a-exact-set-impossibility-missed {x in {0,255}; inside x > 100, x is {255}: is x < 200 decided?} \
    {fn pick(flag):
    if flag:
        0
    else:
        255
fn f(flag):
    x = pick(flag)
    if x > 100:
        if x < 200:
            1
        else:
            2
    else:
        3
f(true)
f(false)
} {f}
scenario S12b-eq-impossibility-codegen-vs-legality {HighNibble h == 17: ConditionOutcome vs hir/completions.tcl} \
    {error Bad
fn g(h: HighNibble) -> int errors Bad:
    if h == 17:
        fail Bad
    else:
        1
g(byte::high_nibble(200))
} {g}
scenario S12c-interval-impossibility-both-agree {Byte b > 255: ConditionOutcome and hir/completions.tcl agree} \
    {error Bad
fn g(b: Byte) -> int errors Bad:
    if b > 255:
        fail Bad
    else:
        1
g(byte::from_int(7))
} {g}
scenario S12d-empty-range-stored-in-dead-branch {x in [1,2]; the dead branch's narrowed x is stored and joined} \
    {fn f(x):
    if x < 0:
        x + 1000
    else:
        x
f(1)
f(2)
} {f} {
    set spec [dict get $a spec]
    set ranges [dict get $a ranges]
    foreach id [m7a::instancesOf $a f] {
        set view [hir::specialize::view $hir $spec $id]
        foreach e [dict get $spec context exprs [dict get $spec instances $id block]] {
            if {[hir::kind $view $e] in {ref call} && [dict exists [dict get $ranges instances $id exprs] $e]} {
                puts "    range $id $e [hir::kind $view $e] [m7a::ConditionText $view $e] = [hir::range::show [hir::range::of $ranges $id $e]]"
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Result theorems (spec #39, "result summary hysteresis")

scenario S13-result-summary-hysteresis {from_int<int>'s own settled result is [7,7]; what does its caller see?} \
    {fn fb(b: Byte):
    b
fb(byte::from_int(7))
} {fb byte::from_int} {
    set spec [dict get $a spec]
    set ranges [dict get $a ranges]
    foreach {e t} [dict get $spec instances i0 calls] {
        puts "    program call $e -> [hir::specialize::label $spec $t]: call-site result range [hir::range::show [hir::range::of $ranges i0 $e]]"
    }
}

# ---------------------------------------------------------------------------
# Native metadata (spec #39)

scenario S14-native-result-range {char::codepoint's -result-range nonneg reaches a shared from_int instance} \
    {fn conv(c: UnicodeChar):
    r = byte::from_int(char::codepoint(c)):
        on AboveRange:
            0
    r
conv('a')
} {conv byte::from_int char::codepoint}

# ---------------------------------------------------------------------------
# Self-tail widening (specialize.tcl header)

scenario S15-self-tail-widening {a self tail call whose argument kinds differ from the instance key climbs to generic} \
    {fn f(a, b, n):
    if n <= 0:
        0
    else:
        f(b, a, n - 1)
f(1, "x", 3)
} {f}

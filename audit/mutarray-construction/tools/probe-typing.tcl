# probe-typing.tcl -- the typing/runtime probes the MutableArray
# construction/refinement milestone was developed against: static types of
# from_list / mutarray? programs and their outcome on every backend. Runs
# against the tree it is started in (pwd is the root).
#
#   tclsh9.0 audit/mutarray-construction/tools/probe-typing.tcl
set root [pwd]
source $root/compiler/compiler.tcl
source $root/surface/surface.tcl
source $root/native/native.tcl
interp recursionlimit {} 20000
proc compile {src} {
    set f [file join [file tempdir] probe-typing.bot]
    set c [open $f w]; puts $c $src; close $c
    try { return [surface::readProgramFile $f -strict 1] } finally { file delete $f }
}
proc last {src} {
    set hir [compile $src]
    set e [lindex [hir::roots $hir] end]
    hir::types::show [hir::typeOf $hir $e]
}
proc block {hir name} {
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding name] ne $name || [dict get $binding declaredBy] eq ""} continue
        set value [hir::get $hir [dict get $binding declaredBy] value]
        if {[hir::kind $hir $value] eq "block"} { return $value }
    }
}
proc sig {hir name} {
    set sig [hir::signatures::of $hir [block $hir $name]]
    lmap p [dict get $sig params] { format {%s: %s (%s)} [dict get $p name] [hir::types::show [hir::signatures::paramType $p]] [dict get $p source] }
}
proc fnType {src name} {
    set hir [compile $src]
    hir::types::show [hir::typeOf $hir [block $hir $name]]
}
proc run {backend src} {
    set hir [compile $src]
    outcomeUnder $backend [hir::lower $hir]
}
proc outcomeUnder {backend exprs} {
    set saved [core::useBackend]
    core::useBackend $backend
    try {
        if {[catch {core::evalProgram $exprs} result options]} {
            return [list error [dict get $options -errorcode] $result]
        }
        return [list value [core::value::show $result 1]]
    } finally { core::useBackend $saved }
}
foreach {label src} {
 A "xs = \[1,2,3\]\nm = mutarray::from_list(xs)\nn = m\nn"
 B "fn make():\n    mutarray::from_list(\[1,2,3\])\nfn forward():\n    make()\nforward()"
 C "fn a():\n    mutarray::from_list(\[1\])\nfn b():\n    mutarray::from_list(\[2\])\nfn j(c):\n    if c:\n        a()\n    else:\n        b()\nj(true)"
 D "fn a():\n    mutarray::from_list(\[1\])\nfn j(c):\n    if c:\n        a()\n    else:\n        \[\]\nj(true)"
 E "rows = \[mutarray::from_list(\[1\]), mutarray::from_list(\[2\])\]\nfn g(i):\n    list_get(rows, i)\ng(1)"
 F "mutarray::from_list(\[\"x\", 1, true\])"
 G "mutarray::from_list(123)"
 H "fn f(x):\n    mutarray::from_list(x)\nf(1)"
} {
  puts "== $label"
  if {[catch {puts [last $src]} e]} { puts "REJECT: [string range $e 0 300]" }
}
puts "=========== runtime"
foreach {label src} {
 order "xs = \[10, 20, 30\]\nm = mutarray::from_list(xs)\n\[mutable_array_capacity(m), mutable_array_get(m, 0), mutable_array_get(m, 1), mutable_array_get(m, 2)\]"
 mutate "fn f():\n    xs = \[1, 2, 3\]\n    m = mutarray::from_list(xs)\n    mutable_array_set(m, 0, 99)\n    \[xs, mutable_array_get(m, 0)\]\nf()"
 empty "fn f():\n    m = mutarray::from_list(\[\])\n    \[mutable_array_capacity(m), mutarray?(m)\]\nf()"
 hetero "fn f():\n    m = mutarray::from_list(\[\"x\", 1, true\])\n    \[mutable_array_get(m, 0), mutable_array_get(m, 1), mutable_array_get(m, 2)\]\nf()"
 pred "\[mutarray?(mutable_array_allocate(1)), mutarray?(\[1\]), mutarray?(1), mutarray?(\"s\"), mutarray?(true), mutarray?(mutarray::from_list(\[\]))\]"
} {
  puts "== $label"
  foreach b {interp compile cranelift-generic cranelift} {
     if {[catch {puts "$b: [run $b $src]"} e]} { puts "$b ERR: [string range $e 0 300]" }
  }
}
puts "=========== typing/inference"
proc show {label script} { puts "== $label"; if {[catch {uplevel #0 $script} r]} {puts "ERR: [string range $r 0 250]"} else {puts $r} }
show "maybe_capacity sig" {sig [compile "fn maybe_capacity(x):\n    if mutarray?(x):\n        mutable_array_capacity(x)\n    else:\n        0\nmaybe_capacity(1)"] maybe_capacity}
show "capacity sig" {sig [compile "fn capacity(x):\n    mutable_array_capacity(x)\ncapacity(mutable_array_allocate(1))"] capacity}
show "after-branch" {sig [compile "fn f(x):\n    if mutarray?(x):\n        0\n    mutable_array_capacity(x)\nf(mutable_array_allocate(1))"] f}
show "nested alias" {last "fn f(x):\n    if mutarray?(x):\n        y = x\n        mutable_array_capacity(y)\n    else:\n        0\nf(1)"}
show "mixed fnType" {fnType "fn f(x):\n    if mutarray?(x):\n        x\n    else:\n        0\nf(1)" f}
show "record ctrl" {fnType "fn mkpair():\n    \[mutarray::from_list(\[1\]), 0\]\nfn first():\n    list_get(mkpair(), 0)\nfirst()" first}
show "record ctrl2" {last "fn mkpair():\n    \[mutarray::from_list(\[1\]), 0\]\nfn first(p):\n    list_get(p, 0)\nfirst(mkpair())"}
show "local record" {last "p = \[mutarray::from_list(\[1\]), 0\]\nlist_get(p, 0)"}
show "append" {last "rows = list_append(\[mutarray::from_list(\[1\])\], mutarray::from_list(\[2\]))\nrows"}
show "pred type" {last "mutarray?"}
show "int pred type" {last "integer?"}
show "pred call" {fnType "fn p(x):\n    mutarray?(x)\np(1)" p}
show "unused pass" {last "fn apply(f, v):\n    f(v)\napply(mutarray?, 1)"}
puts "=========== callable"
show "list of preds" {last "\[integer?, list?, mutarray?\]"}
show "accept" {last "fn apply(p: Fn{args: \[any\], return: bool, errors: \[\]}, v) -> bool:\n    p(v)\napply(mutarray?, 1)"}
show "accept int" {last "fn apply(p: Fn{args: \[any\], return: bool, errors: \[\]}, v) -> bool:\n    p(v)\napply(integer?, 1)"}
show "used view" {
  set hir [compile "fn p(x):\n    mutarray?(x)\np(1)"]
  set spec [hir::specialize::analyze $hir]
  lmap id [dict get $spec used] {list [hir::specialize::label $spec $id] [hir::types::show [dict get $spec instances $id result]]}
}

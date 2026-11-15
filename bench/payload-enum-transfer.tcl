# payload-enum-transfer.tcl -- the performance report of PORTABILITY-
# PAYLOAD-ENUM-TRANSFER-MILESTONE-1.md: what std::transfer::encode and decode
# cost for payload-bearing enums, beside equivalent structs, natively
# (cranelift) and on the Tcl compiler (compile); what the schema and the
# native plan cost at compile time; and a message's way through the remote
# actor transport.
#
#   tclsh9.0 bench/payload-enum-transfer.tcl ?-runs N? ?-backends LIST?
#       ?-scale F? ?-parts "codec schema remote"?
#
# The codec part is bench/value-transfer.tcl's method: a program builds the
# value once and encodes it (or decodes its bytes) K times in a fold whose
# result depends on every copy; the same program with K = 0 is the
# baseline, and one operation costs (time(K) - time(0)) / K. Natively the
# time is native::measure's best of N runs in one process (compilation
# excluded) and the allocations native::allocationReport's difference of
# the K = 1 and K = 0 programs; on the Tcl compiler the best of N runs of a
# unit compiled once. The schema part times hir::transfer::Schema and
# native lowering's TransferPlan per type (the median of 50 calls). The
# remote part sends M messages from a worker thread into a mailbox of the
# main VM (tests/payload-enum-transfer.test's programs' shape), payload enum
# messages beside struct messages of the same content, and reports the
# best of N runs' time per message. Times are a shared container's: compare
# them with each other, never as absolutes.

set here [file dirname [file normalize [info script]]]
set root [file dirname $here]
set options [dict create -runs 3 -backends {cranelift compile} -scale 1.0 -parts {codec schema remote}]
foreach {k v} $argv {
    if {![dict exists $options $k]} {
        puts stderr "unknown option $k"
        exit 2
    }
    dict set options $k $v
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
cd $root
set argv {}
set argc 0
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root tools event-loop-linux.tcl]

set decls {
enum Message:
    Ping,
    Text {body: str},
    Number {value: int},
    Batch {items: List[int]},

struct NumberS:
    value: int

enum Shape:
    Dot,
    Rect {w: int, h: int, label: str, filled: bool},

struct RectS:
    w: int
    h: int
    label: str
    filled: bool

enum Outer:
    Empty,
    Wrap {inner: Message},

struct OuterS:
    inner: NumberS

enum Tree:
    Leaf {value: int},
    Branch {children: List[Tree]},

tree struct Node:
    value: int
    kids: List[Node]

enum Expr:
    Lit {value: int},
    Neg {e: Expr},
    Add {left: Expr, right: Expr},

enum Wide:
    C00 {a: int, b: int, c: str, d: bool}, C01 {a: int, b: int, c: str, d: bool},
    C02 {a: int, b: int, c: str, d: bool}, C03 {a: int, b: int, c: str, d: bool},
    C04 {a: int, b: int, c: str, d: bool}, C05 {a: int, b: int, c: str, d: bool},
    C06 {a: int, b: int, c: str, d: bool}, C07 {a: int, b: int, c: str, d: bool},
    C08 {a: int, b: int, c: str, d: bool}, C09 {a: int, b: int, c: str, d: bool},
    C10 {a: int, b: int, c: str, d: bool}, C11 {a: int, b: int, c: str, d: bool},
    C12 {a: int, b: int, c: str, d: bool}, C13 {a: int, b: int, c: str, d: bool},
    C14 {a: int, b: int, c: str, d: bool}, C15 {a: int, b: int, c: str, d: bool},
    C16 {a: int, b: int, c: str, d: bool}, C17 {a: int, b: int, c: str, d: bool},
    C18 {a: int, b: int, c: str, d: bool}, C19 {a: int, b: int, c: str, d: bool},
    C20 {a: int, b: int, c: str, d: bool}, C21 {a: int, b: int, c: str, d: bool},
    C22 {a: int, b: int, c: str, d: bool}, C23 {a: int, b: int, c: str, d: bool},
    C24 {a: int, b: int, c: str, d: bool}, C25 {a: int, b: int, c: str, d: bool},
    C26 {a: int, b: int, c: str, d: bool}, C27 {a: int, b: int, c: str, d: bool},
    C28 {a: int, b: int, c: str, d: bool}, C29 {a: int, b: int, c: str, d: bool},
    C30 {a: int, b: int, c: str, d: bool}, C31 {a: int, b: int, c: str, d: bool},
    Empty,

fn tree(depth: int) -> Tree:
    if depth == 0:
        return Tree::Leaf {value: 1}
    Tree::Branch {children: [tree(depth - 1), tree(depth - 1)]}

fn node(depth: int) -> Node:
    if depth == 0:
        return Node {value: 1, kids: []}
    Node {value: depth, kids: [node(depth - 1), node(depth - 1)]}

fn message(i: int) -> Message:
    k = i.mod(4)
    if k == 0:
        return Message::Ping
    if k == 1:
        return Message::Text {body: i.to_string()}
    if k == 2:
        return Message::Number {value: i * 7919}
    Message::Batch {items: [i, i + 1]}
}

set prelude {import std::transfer
import std::abi::bytes
import std::byte
import std::int
import std::list
import std::str

fn size(data: std::abi::bytes::Bytes) -> int:
    std::abi::bytes::length(data).value
}

# NAME TYPE BUILD OBSERVE K-native K-tcl.
set workloads {
    payload-free-case  Message   {Message::Ping}                                      {1}                    200000 2000
    payload-case-int   Message   {Message::Number {value: 42}}                        {1}                    200000 2000
    struct-int         NumberS   {NumberS {value: 42}}                                {c.value}              200000 2000
    payload-case-4     Shape     {Shape::Rect {w: 3, h: -1, label: "héllo", filled: true}} {1}               200000 2000
    struct-4           RectS     {RectS {w: 3, h: -1, label: "héllo", filled: true}}  {c.w}                  200000 2000
    nested-enum        Outer     {Outer::Wrap {inner: Message::Number {value: 7}}}    {1}                    200000 2000
    nested-struct      OuterS    {OuterS {inner: NumberS {value: 7}}}                 {c.inner.value}        200000 2000
    wide-last-case     Wide      {Wide::C31 {a: 1, b: 2, c: "x3", d: true}}           {1}                    200000 2000
    list-1000-enum     {List[Message]} {loop i from 0 to 1000:\n    message(i)}       {c.length()}           2000 20
    list-1000-struct   {List[NumberS]} {loop i from 0 to 1000:\n    NumberS {value: i * 7919}} {c.length()} 2000 20
    tree-enum-d10      Tree      {tree(10)}                                           {1}                    500 5
    tree-struct-d10    Node      {node(10)}                                           {c.value}              500 5
    chain-enum-10000   Expr      {fold i from 0 to 10000 with intermediate e Expr::Lit {value: 1}:\n    Expr::Neg {e: e}} {1} 50 2
}

proc program {mode type build observe k} {
    global prelude decls
    set text "$prelude\n$decls\n"
    append text "fn build() -> $type:\n[indent "    " $build]\n"
    append text "value = build()\ndata = std::transfer::encode(value)\n"
    if {$mode eq "encode"} {
        append text "fold i from 0 to $k with intermediate acc 0:\n    acc + size(std::transfer::encode(value))\n"
    } elseif {$mode eq "decode"} {
        append text "fn copy(d: std::abi::bytes::Bytes) -> int:\n    c = std::transfer::decode\[$type\](d):\n"
        foreach e {TransferMalformed TransferVersion TransferTypeMismatch TransferInvalidValue TransferLimit} {
            append text "        on $e:\n            return -1\n"
        }
        append text "    $observe\n\nfold i from 0 to $k with intermediate acc 0:\n    acc + copy(data)\n"
    } else {
        append text "size(data)\n"
    }
    return $text
}

proc indent {pad text} {
    return [join [lmap line [split [string map {\\n \n} $text] \n] {string cat $pad $line}] \n]
}

proc hirOf {text} {
    return [surface::compile $text bench.bot -warnings off]
}

proc bestTime {backend hir runs} {
    if {$backend eq "compile"} {
        set unit [core::compiler::compileHir $hir]
        set best ""
        for {set r 0} {$r <= $runs} {incr r} {
            set t [lindex [time {core::compiler::evalUnit $unit}] 0]
            if {$best eq "" || $t < $best} { set best $t }
        }
        return $best
    }
    lassign [native::measure $hir $runs {*}[expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]] lower compile best collections value
    return $best
}

proc allocations {hir} {
    set report [native::allocationReport $hir summary]
    set total [dict get $report total]
    return [list [dict get $total allocations] [dict get $total allocatedBytes] [dict get $total peakLiveBytes] [dict get $total collections]]
}

set runs [dict get $options -runs]
set scale [dict get $options -scale]

if {"codec" in [dict get $options -parts]} {
    puts "== The codec: one operation's cost (time(K) - time(0)) / K"
    puts [format "%-18s %-10s %6s %10s %10s %9s %9s %16s %11s %16s" workload backend bytes "enc us" "dec us" "enc MB/s" "dec MB/s" "enc allocs/B" "dec allocs/B" "dec peak +B / GCs"]
    foreach {name type build observe kNative kTcl} $workloads {
        set size ""
        foreach backend [dict get $options -backends] {
            set k [expr {max(1, int(($backend eq "compile" ? $kTcl : $kNative) * $scale))}]
            if {$size eq ""} {
                set size [string trim [core::value::show [core::compiler::evalHir [hirOf [program size $type $build $observe 0]]]]]
            }
            set row {}
            foreach mode {encode decode} {
                set t0 [bestTime $backend [hirOf [program $mode $type $build $observe 0]] $runs]
                set tk [bestTime $backend [hirOf [program $mode $type $build $observe $k]] $runs]
                dict set row $mode [expr {double($tk - $t0) / $k}]
            }
            set encAllocs -
            set decAllocs -
            set peak -
            if {$backend ne "compile"} {
                foreach mode {encode decode} {
                    lassign [allocations [hirOf [program $mode $type $build $observe 0]]] a0 b0 p0 g0
                    lassign [allocations [hirOf [program $mode $type $build $observe 1]]] a1 b1 p1 g1
                    dict set row ${mode}Allocs "[expr {$a1 - $a0}]/[expr {$b1 - $b0}]"
                    if {$mode eq "decode"} {
                        set peak "[expr {$p1 - $p0}] / [expr {$g1 - $g0}]"
                    }
                }
                set encAllocs [dict get $row encodeAllocs]
                set decAllocs [dict get $row decodeAllocs]
            }
            set enc [dict get $row encode]
            set dec [dict get $row decode]
            puts [format "%-18s %-10s %6s %10.3f %10.3f %9.1f %9.1f %16s %11s %16s" $name $backend $size $enc $dec \
                [expr {$enc > 0 ? $size / $enc : 0}] [expr {$dec > 0 ? $size / $dec : 0}] $encAllocs $decAllocs $peak]
            flush stdout
        }
    }
}

# The median of 50 timed calls of SCRIPT, in microseconds.
proc median {script} {
    set ts {}
    for {set i 0} {$i < 50} {incr i} {
        lappend ts [lindex [uplevel 1 [list time $script]] 0]
    }
    return [lindex [lsort -integer $ts] 25]
}

if {"schema" in [dict get $options -parts]} {
    puts "\n== Compile time: hir::transfer::Schema and native::lower::TransferPlan (median of 50 calls)"
    set hir [hirOf "$prelude\n$decls\n[join [lmap {name type b o kn kt} $workloads {string cat "fn f_[string map {- _} $name](x: $type) -> int:\n    1\n"}] \n]\n1\n"]
    hir::activate $hir
    puts [format "%-18s %6s %12s %12s" workload nodes "schema us" "plan us"]
    foreach {name type b o kn kt} $workloads {
        set fn "f_[string map {- _} $name]"
        foreach r [dict get $hir roots] {
            set n [dict get $hir exprs $r]
            if {[dict get $n kind] ne "bind"} continue
            set binding [hir::binding $hir [dict get $n binding]]
            if {$binding eq "" || [dict get $binding name] ne $fn} continue
            set t [lindex [dict get [dict get $hir exprs [dict get $n value]] declaredParamTypes] 0]
        }
        set schema [hir::transfer::Schema $t]
        set us [median {hir::transfer::Schema $t}]
        set text [hir::transfer::RuntimeText $schema]
        set plan -
        if {![catch {native::binary}]} {
            set native::lower::hir $hir
            if {[catch {set plan [median {native::lower::TransferPlan e0 $text}]} message]} {
                set plan "($message)"
            }
        }
        puts [format "%-18s %6d %12d %12s" $name [llength [dict get $schema nodes]] $us $plan]
    }
}

# The remote part: an application directory with the Linux driver.
set remoteWorker {
import event_loop_linux
import std::actor::remote
import std::event_loop
import std::thread

enum Request:
    Stop,
    Calculate {requestId: int, x: int, y: int},
    Store {key: str, value: List[int]},

struct Calc:
    stop: bool
    requestId: int
    x: int
    y: int

struct Plan:
    to: std::actor::remote::Remote[Request]
    count: int

struct PlanS:
    to: std::actor::remote::Remote[Calc]
    count: int

thread fn send_enums(plan: Plan) -> int:
    fold i from 0 to plan.count + 1 with intermediate full 0:
        m = if i == plan.count:
            Request::Stop
        else:
            Request::Calculate {requestId: i, x: i, y: 2}
        tries = fold with intermediate t 0:
            s = std::actor::remote::send(plan.to, m)
            if s == std::actor::remote::Sent::Delivered:
                break
            t + 1
        full + tries

thread fn send_structs(plan: PlanS) -> int:
    fold i from 0 to plan.count + 1 with intermediate full 0:
        m = Calc {stop: i == plan.count, requestId: i, x: i, y: 2}
        tries = fold with intermediate t 0:
            s = std::actor::remote::send(plan.to, m)
            if s == std::actor::remote::Sent::Delivered:
                break
            t + 1
        full + tries
}

proc remoteMain {kind count} {
    if {$kind eq "enum"} {
        set m worker::Request
        set entry worker::send_enums
        set plan "worker::Plan {to: remote, count: $count}"
        set handle "        done = match r:\n            case worker::Request::Stop:\n                true\n            case worker::Request::Calculate {requestId, x, y}:\n                false\n            case worker::Request::Store {key, value}:\n                false\n"
    } else {
        set m worker::Calc
        set entry worker::send_structs
        set plan "worker::PlanS {to: remote, count: $count}"
        set handle "        done = r.stop\n"
    }
    return "import event_loop_linux
import worker
import std::actor
import std::actor::remote
import std::event_loop
import std::thread

fn collector(inbox: std::actor::Inbox\[$m\], context ev: std::event_loop::Loop, resume std::actor::Answer) -> std::actor::Exit:
    rx = std::actor::listen(inbox):
        on std::actor::Closed:
            return std::actor::exit(-1)
    n = fold with intermediate n 0:
        r = std::actor::receive(rx):
            on std::actor::Closed:
                break
$handle        if done:
            break
        n + 1
    std::event_loop::stop():
        on std::event_loop::SchedulerFault:
            return std::actor::exit(-2)
    std::actor::exit(n)

fn go(context ev: std::event_loop::Loop, d: std::event_loop::Driver, ac: std::actor::Actors, t: std::thread::Threads, p: std::thread::Port, db: std::thread::Doorbell) -> int errors std::event_loop::SchedulerFault, std::event_loop::DriverFault, std::event_loop::LoopReentered, std::thread::ThreadLimit, std::thread::ThreadStartFailed, std::thread::ThreadFailed:
    std::thread::serve()
    {to, inbox} = std::actor::open\[$m\](64)
    remote = std::actor::remote::export(to, 64)
    c = inject context std::event_loop::Loop:
        coroutine {step, first} = collector(inbox)
        std::actor::spawned(step, first)
    std::actor::start(c)
    {thread} = std::thread::start(std::thread::entry($entry), $plan)
    std::event_loop::run()
    full = std::thread::join(thread)
    std::thread::close_port()
    full

with context std::event_loop::create(64)
with context event_loop_linux::create()
with context event_loop_linux::native()
with context std::actor::create()
with context std::thread::create(2)
with context std::thread::port()
go():
    on std::event_loop::SchedulerFault:
        -1
    on std::event_loop::DriverFault {code}:
        -2
    on std::event_loop::LoopReentered:
        -3
    on std::thread::ThreadLimit:
        -4
    on std::thread::ThreadStartFailed {reason}:
        -5
    on std::thread::ThreadFailed {identity, message}:
        -6
"
}

if {"remote" in [dict get $options -parts] && $::tcl_platform(os) eq "Linux" && ![catch {native::binary}]} {
    puts "\n== The remote transport: M messages from a worker thread into a mailbox (best of $runs runs; per message)"
    set app [file tempdir botlish-pet-bench]
    try {
        set f [open [file join $app worker.bot] w]
        puts $f $remoteWorker
        close $f
        eventLoopLinux::install $app
        set count [expr {max(100, int(20000 * $scale))}]
        puts [format "%-10s %8s %14s %14s" message count "total us" "us/message"]
        foreach kind {enum struct} {
            set f [open [file join $app main-$kind.bot] w]
            puts $f [remoteMain $kind $count]
            close $f
            set hir [surface::readProgramFile [file join $app main-$kind.bot] -warnings off]
            lassign [native::measure $hir $runs] lower compile best collections value
            puts [format "%-10s %8d %14.0f %14.3f" $kind $count $best [expr {double($best) / $count}]]
        }
    } finally {
        file delete -force $app
    }
}

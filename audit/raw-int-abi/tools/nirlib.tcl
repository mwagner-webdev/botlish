# nirlib.tcl -- NIR text helpers shared by the raw Int ABI audit tools
# (census.tcl, demand.tcl): function/attribute parsing, the rbox/runbox
# conversion census, call-edge classes, and the classification of every
# remaining rbox by where its raw value came from and whether anything else
# in the function wanted that value raw.

# {name header-attrs-dict body-lines} per NIR function, in id order.
proc nirFunctions {nir} {
    set out {}
    foreach chunk [split [string map [list "\n\nfunc " "\n\u0001func "] $nir] \u0001] {
        if {![regexp {^func (\d+) "([^"]*)" (.*)$} [lindex [split $chunk \n] 0] -> id name rest]} continue
        set rawparams {}
        regexp {rawparams="([^"]*)"} $rest -> rawparams
        set rawregs {}
        regexp {rawregs="([^"]*)"} $rest -> rawregs
        set instance ""
        regexp {instance="([^"]*)"} $rest -> instance
        set params 0
        regexp {params=(\d+)} $rest -> params
        set body [lrange [split $chunk \n] 1 end]
        lappend out [list $id $name [dict create rawparams $rawparams rawresult [regexp {rawresult=1} $rest] \
            rawregs $rawregs instance $instance params $params] $body]
    }
    return $out
}

proc hasRaw {attrs} {
    return [expr {[dict get $attrs rawparams] ne "" || [dict get $attrs rawresult]}]
}

# Conversion census of one function body: {rbox runbox boundaryRbox boundaryRunbox}.
proc conversions {attrs body} {
    set defs [dict create]      ;# reg -> kind of defining instruction
    set callUse [dict create]   ;# reg -> 1 if used as a call/callenv/tail argument or `ret`
    set rbox {}
    set runbox {}
    set params [dict get $attrs params]
    foreach line $body {
        set line [string trim $line]
        if {[regexp {^%(\d+) = (call|callenv) } $line -> d]} {
            dict set defs $d call
        }
        if {[regexp {^%(\d+) = op rbox %(\d+)} $line -> d s]} {
            lappend rbox $d
        }
        if {[regexp {^%(\d+) = op runbox %(\d+)} $line -> d s]} {
            lappend runbox [list $d $s]
        }
        if {[regexp {^%\d+ = (?:call|callenv) \d+ (.*?)(?: @e\d+)?$} $line -> args] ||
            [regexp {^(?:tail|tailenv) (.*?)(?: @e\d+)?$} $line -> args] || [regexp {^ret (%\d+)} $line -> args]} {
            foreach {- r} [regexp -all -inline {%(\d+)} $args] {
                dict set callUse $r 1
            }
        }
    }
    set bRbox 0
    foreach d $rbox {
        if {[dict exists $callUse $d]} { incr bRbox }
    }
    set bRunbox 0
    foreach pair $runbox {
        lassign $pair d s
        if {([dict exists $defs $s] && [dict get $defs $s] eq "call") || $s < $params} { incr bRunbox }
    }
    return [list [llength $rbox] [llength $runbox] $bRbox $bRunbox]
}

# Call-edge classes of a program's NIR: dict class -> count.
proc edgeCensus {funcs} {
    set abi [dict create]
    foreach f $funcs {
        lassign $f id name attrs body
        dict set abi $id [hasRaw $attrs]
    }
    set edges [dict create raw->raw 0 tagged->raw 0 raw->tagged 0 tagged->tagged 0]
    foreach f $funcs {
        lassign $f id name attrs body
        foreach line $body {
            if {[regexp {^\s*%\d+ = (?:call|callenv) (\d+) } $line -> callee]} {
                set cls [expr {[dict get $abi $id] ? "raw" : "tagged"}]->[expr {[dict get $abi $callee] ? "raw" : "tagged"}]
                dict incr edges $cls
            }
        }
    }
    return $edges
}

# ---------------------------------------------------------------------------
# Conversion classification

set ::rawOpNames {riadd risub rimul rilt rile rigt rige rieq rishr rishl}

# Registers (as integers) used by NIR line LINE, in textual order.
proc lineRegs {line} {
    return [lmap {- r} [regexp -all -inline {%(\d+)} $line] {set r}]
}

# The classification of every rbox of the program FUNCS (nirFunctions):
# a list of {function category source consumer} per rbox, where
#
#   category  program-boundary    an rbox in <program> feeding its result
#             frontier            a raw *computation* (arithmetic, constant,
#                                 join) boxed for a tagged consumer: the
#                                 inherent tagged frontier of raw arithmetic
#             mixed               a raw parameter / raw call result that has
#                                 at least one genuine raw consumer in the
#                                 same function as this tagged one (retained
#                                 by policy)
#             mixed-callers       a raw call result with no raw consumer at
#                                 this call site, kept raw because another
#                                 call site of the callee wants it raw
#                                 (retained by policy: mixed consumers)
#             NO-RAW-CONSUMER     a raw parameter whose every use is tagged:
#                                 raw selected with no raw consumer (a bug of
#                                 the demand rule)
#             other
#   source    param | call | arith | const | join | runbox | other
#   consumer  ret | call-arg | tagged-op | other (the first use of the box)
proc classifyRboxes {funcs} {
    set attrs [dict create]
    foreach f $funcs {
        lassign $f id name a body
        dict set attrs $id $a
    }
    set out {}
    foreach f $funcs {
        lassign $f id name a body
        set rawparams [dict get $a rawparams]
        set rawresult [dict get $a rawresult]
        set rawregs [dict get $a rawregs]
        set nparams [dict get $a params]
        set defs [dict create]
        set rawUse [dict create]
        set boxUses [dict create]
        set rboxes {}
        foreach line $body {
            set line [string trim $line]
            if {[regexp {^%(\d+) = (.*?)(?: @e\d+)?$} $line -> d rhs]} {
                set kind other
                if {[regexp {^op (\w+) } $rhs -> opname]} {
                    if {$opname in $::rawOpNames && $opname ni {rilt rile rigt rige rieq}} {
                        set kind arith
                    } elseif {$opname eq "runbox"} {
                        set kind runbox
                    } elseif {$opname eq "rbox"} {
                        set kind rbox
                    }
                } elseif {[regexp {^rawint } $rhs]} {
                    set kind const
                } elseif {[regexp {^(call|callenv) (\d+)} $rhs -> - callee]} {
                    set kind [expr {[dict get $attrs $callee rawresult] ? "call" : "taggedcall"}]
                } elseif {[regexp {^move } $rhs]} {
                    set kind join
                }
                if {[dict exists $defs $d] && [dict get $defs $d] ne $kind} {
                    dict set defs $d join
                } else {
                    dict set defs $d $kind
                }
                if {[regexp {^op rbox %(\d+)} $rhs -> s]} {
                    lappend rboxes [list $d $s]
                }
            }
            # raw consumers of registers
            if {[regexp {^%\d+ = op (\w+) (.*?)(?: @e\d+)?$} $line -> opname rest]} {
                if {$opname in $::rawOpNames} {
                    foreach r [lineRegs $rest] { dict incr rawUse $r }
                }
            }
            if {[regexp {^%\d+ = call (\d+) (.*?)(?: @e\d+)?$} $line -> callee rest] ||
                [regexp {^%\d+ = callenv (\d+) %\d+ (.*?)(?: @e\d+)?$} $line -> callee rest]} {
                set cp [dict get $attrs $callee rawparams]
                set i 0
                foreach r [lineRegs $rest] {
                    if {$i in $cp} { dict incr rawUse $r }
                    incr i
                }
            }
            if {[regexp {^ret %(\d+)} $line -> r] && $rawresult} {
                dict incr rawUse $r
            }
            if {[regexp {^%(\d+) = move %(\d+)} $line -> d s] && $d in $rawregs} {
                dict incr rawUse $s
            }
            if {[regexp {^(?:tail|tailenv) (.*?)(?: @e\d+)?$} $line -> rest]} {
                set i 0
                foreach r [lineRegs $rest] {
                    if {$i in $rawregs} { dict incr rawUse $r }
                    incr i
                }
            }
            # the first tagged use of each reg, for the consumer column
            set consumer other
            if {[regexp {^ret } $line]} {
                set consumer ret
            } elseif {[regexp {^%\d+ = (?:call|callenv) } $line]} {
                set consumer call-arg
            } elseif {[regexp {^%\d+ = op } $line]} {
                set consumer tagged-op
            }
            set operands $line
            regexp {^%\d+ = (.*)$} $line -> operands
            foreach r [lineRegs $operands] {
                if {![dict exists $boxUses $r]} { dict set boxUses $r $consumer }
            }
        }
        foreach pair $rboxes {
            lassign $pair d s
            if {$s < $nparams && $s in [split $rawparams " "] && ![dict exists $defs $s]} {
                set source param
            } elseif {[dict exists $defs $s]} {
                set source [dict get $defs $s]
                if {$source eq "taggedcall"} { set source other }
            } else {
                set source other
            }
            set consumer [expr {[dict exists $boxUses $d] ? [dict get $boxUses $d] : "other"}]
            set mixed [expr {[dict exists $rawUse $s] ? [dict get $rawUse $s] : 0}]
            if {$name eq "<program>" && $consumer eq "ret"} {
                set category program-boundary
            } elseif {$source in {arith const join runbox}} {
                set category frontier
            } elseif {$source eq "call"} {
                # The raw result may be demanded at another call site only.
                set category [expr {$mixed > 0 ? "mixed" : "mixed-callers"}]
            } elseif {$source eq "param"} {
                set category [expr {$mixed > 0 ? "mixed" : "NO-RAW-CONSUMER"}]
            } else {
                set category other
            }
            lappend out [list $name $category $source $consumer]
        }
    }
    return $out
}

# window.tcl -- test infrastructure for tests/c-ffi-error-capture.test, its
# audit tools and bench/c-ffi-error-capture.tcl (C-FFI-ERROR-CAPTURE-
# MILESTONE-1.md): the code between a C call's return and the capture of its
# error state, in NIR and in machine code.
#
#   window::nirWindows NIR FUNCTION CAPTURE ?START?
#       one entry per C call (`foreigncall`; START, a regexp, names another
#       starting instruction: `= callmulti `) of NIR function FUNCTION (every
#       function of that name) from which a call of NIR function CAPTURE is
#       reachable -- or, CAPTURE "", a return: the instructions on some path
#       from the C call to that call (through no other C call), in text
#       order, each without its `@eN` origin.
#   window::nirOps WINDOW        the operation words of a window (`keepalive`,
#                                `ilt`, `structnew`, `call`, ...)
#   window::nirHazards WINDOW    the instructions of a window that may run
#                                anything but the program's own straight-line
#                                code: an allocation, a call, a safepoint
#   window::machine OBJECT ?SYMBOL?
#                                the functions of object file OBJECT
#                                (`objdump -dr`; SYMBOL's alone, GNU
#                                objdump): name -> instructions
#   window::machineWindow FUNCS FUNCTION FOREIGN TARGET
#       the calls (their target symbols) on some path, in FUNCTION's machine
#       code, from the return of its call of the C function FOREIGN (through
#       no other call of FOREIGN) to its call of TARGET (a symbol); FOREIGN
#       "" means from the function's entry, TARGET "" to its returns
#
# The paths are the control-flow graph's: a branch's every successor, an
# error exit never (a call's failure ends the window: nothing after it reads
# the result). Machine code is read with its relocations, so a call is named
# by the symbol its relocation names -- a direct call's own, an indirect
# call's (a C function's, or a runtime helper's on AArch64: a GOT load and
# `blr`) through the register its GOT load wrote -- on every target
# (ELF's R_X86_64_*, R_AARCH64_*, Mach-O's ARM64_RELOC_*; Mach-O's leading
# `_` dropped).

namespace eval window {
    # Whether the object `machine` read last is Mach-O (its symbols carry a
    # leading `_`).
    variable macho 0
}

# ---------------------------------------------------------------------------
# NIR

# The bodies (lists of instruction lines, origins removed) of every NIR
# function named NAME.
proc window::nirBodies {nir name} {
    set bodies {}
    set body ""
    set inside 0
    foreach line [split $nir \n] {
        if {[string match "func *" $line]} {
            set inside [string match "func * \"$name\" *" $line]
            set body {}
            continue
        }
        if {$line eq "end"} {
            if {$inside} {
                lappend bodies $body
            }
            set inside 0
            continue
        }
        if {$inside} {
            lappend body [string trim [regsub -all { @e[0-9]+} $line ""]]
        }
    }
    return $bodies
}

# The NIR function id of function NAME (its first one).
proc window::nirId {nir name} {
    foreach line [split $nir \n] {
        if {[string match "func * \"$name\" *" $line]} {
            return [lindex $line 1]
        }
    }
    return ""
}

# The successors (indices) of instruction I of BODY; LABELS maps a label to
# its index.
proc window::NirSuccessors {body labels i} {
    set line [lindex $body $i]
    set next [expr {$i + 1 < [llength $body] ? [list [expr {$i + 1}]] : {}}]
    switch -regexp -matchvar m -- $line {
        {^br \S+ (\S+) (\S+)$} {
            return [list [dict get $labels [lindex $m 1]] [dict get $labels [lindex $m 2]]]
        }
        {^jump (\S+)$} {
            return [list [dict get $labels [lindex $m 1]]]
        }
        {^(ret|retmulti|raise|unreachable|reraise|faildeclared|tail|tailenv)\M} {
            return {}
        }
    }
    return $next
}

# The indices on some path (SUCC: each node's successors) from FROM to TO
# (TO excluded, FROM included): forward-reachable from FROM without passing
# TO or a node of BARRIER, and reaching TO.
proc window::OnPath {succ from to {barrier {}}} {
    set n [llength $succ]
    set fwd [dict create]
    set stack [list $from]
    while {$stack ne ""} {
        set i [lindex $stack end]
        set stack [lrange $stack 0 end-1]
        if {$i == $to || [dict exists $fwd $i] || $i in $barrier} {
            continue
        }
        dict set fwd $i 1
        lappend stack {*}[lindex $succ $i]
    }
    set pred [dict create]
    for {set i 0} {$i < $n} {incr i} {
        foreach s [lindex $succ $i] {
            dict lappend pred $s $i
        }
    }
    set bwd [dict create]
    set stack [dict getdef $pred $to {}]
    while {$stack ne ""} {
        set i [lindex $stack end]
        set stack [lrange $stack 0 end-1]
        if {$i == $to || [dict exists $bwd $i] || $i in $barrier} {
            continue
        }
        dict set bwd $i 1
        lappend stack {*}[dict getdef $pred $i {}]
    }
    set on {}
    for {set i 0} {$i < $n} {incr i} {
        if {[dict exists $fwd $i] && [dict exists $bwd $i]} {
            lappend on $i
        }
    }
    return $on
}

proc window::nirWindows {nir function capture {start {= foreigncall }}} {
    if {$capture ne ""} {
        set id [nirId $nir $capture]
        if {$id eq ""} {
            error "window::nirWindows: no NIR function \"$capture\""
        }
    }
    set windows {}
    foreach body [nirBodies $nir $function] {
        set labels [dict create]
        set i 0
        foreach line $body {
            if {[regexp {^label (\S+)$} $line -> label]} {
                dict set labels $label $i
            }
            incr i
        }
        set succ {}
        for {set i 0} {$i < [llength $body]} {incr i} {
            lappend succ [NirSuccessors $body $labels $i]
        }
        if {$capture eq ""} {
            set targets [lsearch -all -regexp $body {^(ret|retmulti) }]
        } else {
            set targets [lsearch -all -regexp $body "= call $id\$"]
        }
        set starts [lsearch -all -regexp $body $start]
        foreach c $starts {
            foreach t $targets {
                set on [OnPath $succ [expr {$c + 1}] $t $starts]
                if {$on ne "" || $t == $c + 1} {
                    lappend windows [lmap i $on {lindex $body $i}]
                }
            }
        }
    }
    return $windows
}

# The operation word of each instruction of WINDOW: an op's name (`ilt`,
# `keepalive`), an instruction's own word (`structnew`, `call`, `br`), the
# labels and jumps of its control flow left out.
proc window::nirOps {window} {
    set ops {}
    foreach line $window {
        if {[regexp {^%[0-9]+ = op (\S+)} $line -> op]} {
            lappend ops $op
        } elseif {[regexp {^%[0-9]+ = (\S+)} $line -> word]} {
            if {$word ni {int rawint unit move}} {
                lappend ops $word
            }
        } elseif {![regexp {^(label|jump|br) } $line]} {
            lappend ops [lindex $line 0]
        }
    }
    return $ops
}

# The ops whose machine code is the program's own straight-line code: no
# allocation, no call -- but for the tagged comparisons' BigInt slow path
# (`rt_int_cmp`, reached only when an operand is no small Int) -- and no
# safepoint. `keepalive` is no machine code at all.
proc window::PureOps {} {
    return {keepalive ilt ile igt ige ieq runbox rilt rile rigt rige rieq cptrisnull charcodepoint}
}

proc window::nirHazards {window} {
    set hazards {}
    foreach line $window {
        if {[regexp {^%[0-9]+ = op (\S+)} $line -> op]} {
            if {$op ni [PureOps]} {
                lappend hazards $line
            }
        } elseif {[regexp {^%[0-9]+ = (\S+)} $line -> word]} {
            if {$word ni {int rawint unit move}} {
                lappend hazards $line
            }
        } elseif {![regexp {^(label|jump|br) } $line]} {
            lappend hazards $line
        }
    }
    return $hazards
}

# ---------------------------------------------------------------------------
# Machine code

# `objdump -dr` of OBJECT (only function SYMBOL's code when given: GNU
# objdump's --disassemble=), in Intel syntax on x86-64 (destination first, as
# AArch64 is written).
proc window::Disassemble {object {symbol ""}} {
    set options {-d -r --no-show-raw-insn}
    set kind [exec file $object]
    if {[string match *x86_64* $kind] || [string match *x86-64* $kind]} {
        lappend options -M intel
    }
    if {$symbol ne ""} {
        lappend options --disassemble=$symbol
    }
    return [exec objdump {*}$options $object]
}

# The symbol a relocation names, without Mach-O's `_` and an addend.
proc window::RelocSymbol {macho value} {
    regsub {[-+]0x[0-9a-fA-F]+$} $value {} value
    regsub {[-+][0-9]+$} $value {} value
    if {$macho} {
        regsub {^_} $value {} value
    }
    return $value
}

# The functions of OBJECT: a dict name -> list of instructions, each a dict
# {address mnemonic operands reloc}, RELOC {TYPE SYMBOL} of the relocation at
# the instruction ("" if none). Function names as `nm` prints them without
# Mach-O's `_`.
proc window::machine {object {symbol ""}} {
    variable macho
    set text [Disassemble $object $symbol]
    set macho [string match "*Mach-O*" [exec file $object]]
    set functions [dict create]
    set name ""
    set instrs {}
    foreach line [split $text \n] {
        if {[regexp {^([0-9a-fA-F]+) <([^>]+)>:$} $line -> - fname]} {
            if {$name ne ""} {
                dict set functions $name $instrs
            }
            set name [RelocSymbol $macho $fname]
            set instrs {}
            continue
        }
        if {$name eq ""} {
            continue
        }
        if {[regexp {^\s*([0-9a-fA-F]+):\s+((?:R_|ARM64_RELOC_|X86_64_RELOC_)\S+)\s+(\S+)} $line -> offset type value]} {
            if {$type eq "ARM64_RELOC_ADDEND"} {
                # An addend record of the relocation that follows it.
                continue
            }
            # The relocation applies to the instruction that holds OFFSET.
            set offset [expr {"0x$offset"}]
            for {set i [expr {[llength $instrs] - 1}]} {$i >= 0} {incr i -1} {
                if {[dict get [lindex $instrs $i] address] <= $offset} {
                    lset instrs $i [dict replace [lindex $instrs $i] reloc [list $type [RelocSymbol $macho $value]]]
                    break
                }
            }
            continue
        }
        if {[regexp {^\s*([0-9a-fA-F]+):\s+(\S+)\s*(.*)$} $line -> address mnemonic operands]} {
            # Without the disassembler's comments: GNU objdump's `# addr
            # <sym>` (x86-64) and `// b.tstop` (AArch64), llvm-objdump's
            # `; ...`.
            regsub {\s+(#\s+[0-9a-fA-F]+\s*<[^>]*>|//.*|;.*)$} $operands {} operands
            lappend instrs [dict create address [expr {"0x$address"}] mnemonic $mnemonic operands [string trim $operands] reloc ""]
        }
    }
    if {$name ne ""} {
        dict set functions $name $instrs
    }
    return $functions
}

# The kind of instruction INSTR: call (a direct or indirect call), branch
# (conditional), jump (unconditional, direct), stop (returns or never
# continues), or plain.
proc window::Kind {instr} {
    set m [dict get $instr mnemonic]
    switch -regexp -- $m {
        {^(call|callq|bl|blr|blraa|blrab)$} { return call }
        {^(ret|retq|retaa|retab|ud2|udf|brk|hlt|br|braa|brab)$} { return stop }
        {^(jmp|jmpq|b)$} {
            if {[BranchTarget $instr] eq ""} {
                return stop
            }
            return jump
        }
        {^(j[a-z]+|b\.[a-z]+|cbz|cbnz|tbz|tbnz)$} { return branch }
    }
    return plain
}

# The target address of branch or jump INSTR ("" if indirect).
proc window::BranchTarget {instr} {
    # The last operand, its symbolic comment (`<f+0x10>`) removed: GNU
    # objdump writes the address bare, llvm-objdump with `0x` (or `#`).
    set last [string trim [lindex [split [dict get $instr operands] ,] end]]
    regsub {\s*<[^>]*>$} $last {} last
    if {[regexp {^#?(?:0x)?([0-9a-fA-F]+)$} $last -> hex]} {
        return [expr {"0x$hex"}]
    }
    return ""
}

# The symbol call instruction I of INSTRS calls: its relocation's, or for an
# indirect call (`call rax`, `blr x16`) the GOT relocation of the latest
# instruction before it that wrote that register; "?" when unknown.
proc window::CallTarget {instrs i} {
    variable macho
    set instr [lindex $instrs $i]
    set reloc [dict get $instr reloc]
    set operands [dict get $instr operands]
    if {$reloc ne ""} {
        # A direct call's own relocation, or a call through the GOT entry
        # its own operand names.
        return [lindex $reloc 1]
    }
    regsub {^\*} $operands {} register
    set register [lindex [split $register " ,"] 0]
    if {[regexp {^(r[a-z0-9]+|e[a-z]+|x[0-9]+)$} $register]} {
        for {set j [expr {$i - 1}]} {$j >= 0 && $j >= $i - 16} {incr j -1} {
            set prev [lindex $instrs $j]
            set preloc [dict get $prev reloc]
            set dest [lindex [split [dict get $prev operands] " ,"] 0]
            if {$dest eq $register} {
                if {$preloc ne "" && [regexp {GOT} [lindex $preloc 0]]} {
                    return [lindex $preloc 1]
                }
                return "?"
            }
        }
        return "?"
    }
    if {[regexp {<([^>+]+)>$} $operands -> name]} {
        # A call resolved inside the object, with no relocation left.
        return [RelocSymbol $macho $name]
    }
    return "?"
}

proc window::machineWindow {functions function foreign target} {
    if {![dict exists $functions $function]} {
        error "window::machineWindow: no function $function"
    }
    set instrs [dict get $functions $function]
    set n [llength $instrs]
    set index [dict create]
    set callees {}
    for {set i 0} {$i < $n} {incr i} {
        dict set index [dict get [lindex $instrs $i] address] $i
        lappend callees [expr {[Kind [lindex $instrs $i]] eq "call" ? [CallTarget $instrs $i] : ""}]
    }
    if {"?" in $callees} {
        error "window::machineWindow: a call of $function whose target is not known"
    }
    # A sink node N: every return, and TARGET's calls.
    set succ {}
    for {set i 0} {$i < $n} {incr i} {
        set instr [lindex $instrs $i]
        set next [expr {$i + 1 < $n ? [list [expr {$i + 1}]] : {}}]
        switch -- [Kind $instr] {
            call {
                if {$target ne "" && [lindex $callees $i] eq $target} {
                    lappend succ [list $n]
                } else {
                    lappend succ $next
                }
            }
            stop {
                lappend succ [expr {$target eq "" && [dict get $instr mnemonic] in {ret retq retaa retab} ? [list $n] : {}}]
            }
            jump - branch {
                set to [BranchTarget $instr]
                if {![dict exists $index $to]} {
                    error "window::machineWindow: a branch of $function to [dict get $instr operands] (no instruction of it)"
                }
                lappend succ [concat [expr {[Kind $instr] eq "branch" ? $next : {}}] [list [dict get $index $to]]]
            }
            default {
                lappend succ $next
            }
        }
    }
    lappend succ {}
    if {$foreign eq ""} {
        set barrier {}
        set starts 0
    } else {
        set barrier [lsearch -all $callees $foreign]
        set starts [lmap i $barrier {expr {$i + 1}}]
    }
    if {$starts eq ""} {
        error "window::machineWindow: $function calls no $foreign"
    }
    set calls {}
    foreach start $starts {
        foreach i [OnPath $succ $start $n $barrier] {
            if {$i < $n && [lindex $callees $i] ne "" && [lindex $callees $i] ne $target} {
                lappend calls [lindex $callees $i]
            }
        }
    }
    return $calls
}

# The offsets, from FUNCTION's first instruction, of the instruction after
# each of its calls of FOREIGN: where the window of each call starts (the
# same offsets in an executable linked from the same code).
proc window::machineCallReturns {functions function foreign} {
    set instrs [dict get $functions $function]
    set base [dict get [lindex $instrs 0] address]
    set offsets {}
    for {set i 0} {$i < [llength $instrs] - 1} {incr i} {
        if {[Kind [lindex $instrs $i]] eq "call" && [CallTarget $instrs $i] eq $foreign} {
            lappend offsets [expr {[dict get [lindex $instrs [expr {$i + 1}]] address] - $base}]
        }
    }
    return $offsets
}

# The mnemonics of FUNCTION's instructions, in order (to compare one
# function's code in an object file and in an executable).
proc window::machineMnemonics {functions function} {
    return [lmap instr [dict get $functions $function] {dict get $instr mnemonic}]
}

# The calls of FUNCTION in text order (their target symbols).
proc window::machineCalls {functions function} {
    set instrs [dict get $functions $function]
    set calls {}
    for {set i 0} {$i < [llength $instrs]} {incr i} {
        if {[Kind [lindex $instrs $i]] eq "call"} {
            lappend calls [CallTarget $instrs $i]
        }
    }
    return $calls
}

# The runtime helpers a window may contain because they convert a value that
# is no small Int: the boxing of a 64-bit C result outside the small-Int
# range and a tagged comparison's BigInt path. Neither runs for a small Int
# (a C failure sentinel such as -1); every other call is a hazard.
proc window::bigIntPaths {} {
    return {rt_ffi_box_i64 rt_ffi_box_u64 rt_int_cmp}
}

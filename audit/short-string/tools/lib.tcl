# lib.tcl -- helpers shared by the ShortString1 audit tools (SHORT-STRING.md).
# Observation only: nothing here changes a plan or a lowering.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000

# The canonical corpus (the same 17 programs the RawInt audit uses).
proc corpusPaths {} {
    global root
    set paths {}
    foreach name {fib lex-strategy loop-count refined-checks source-checks sum-refined test-selection uri-steady} {
        lappend paths [file join $root bench $name.bot]
    }
    foreach name {ai_text_clean csv csv_chunked csv_geometric csv_records hashtable matmul string_replace string_reverse} {
        lappend paths [file join $root examples stdlib $name.bot]
    }
    return $paths
}

proc programName {path} { return [file rootname [file tail $path]] }

# {id name attrs-dict body-lines} per NIR function.
proc nirFunctions {nir} {
    set out {}
    foreach chunk [split [string map [list "\n\nfunc " "\n\u0001func "] $nir] \u0001] {
        if {![regexp {^func (\d+) "([^"]*)" (.*)$} [lindex [split $chunk \n] 0] -> id name rest]} continue
        set d [dict create shortparams "" shortresult 0 shortregs "" asciiparams "" asciiresult 0 asciiregs "" instance "" results 1]
        foreach attr {shortparams shortregs asciiparams asciiregs} {
            if {[regexp "$attr=\"(\[^\"\]*)\"" $rest -> v]} { dict set d $attr $v }
        }
        dict set d shortresult [regexp {shortresult=1} $rest]
        dict set d asciiresult [regexp {asciiresult=1} $rest]
        if {[regexp {instance="([^"]*)"} $rest -> inst]} { dict set d instance $inst }
        if {[regexp {results=(\d+)} $rest -> r]} { dict set d results $r }
        lappend out [list $id $name $d [lrange [split $chunk \n] 1 end]]
    }
    return $out
}

# The static short-String operation counts of NIR text, both tiers (ShortString1
# `short*`, packed ASCII `ascii*`).
proc shortCounts {nir} {
    set c [dict create]
    foreach k {strtoshort shorttostr shortlit shortlen shorteq strsliceshort shortparams shortresult shortregs
            strtoascii asciitostr asciilit asciilen asciieq asciitoshort asciishorteq asciiparams asciiresult asciiregs
            functions shortFunctions asciiFunctions scalarFunctions} {
        dict set c $k 0
    }
    foreach f [nirFunctions $nir] {
        lassign $f id name attrs body
        dict incr c functions
        foreach line $body {
            foreach op {strtoshort shorttostr shortlen shorteq strsliceshort strtoascii asciitostr asciilen asciieq asciitoshort asciishorteq} {
                if {[regexp "= op $op " $line]} { dict incr c $op }
            }
            if {[regexp {= shortlit } $line]} { dict incr c shortlit }
            if {[regexp {= asciilit } $line]} { dict incr c asciilit }
        }
        dict incr c shortparams [llength [dict get $attrs shortparams]]
        dict incr c shortresult [dict get $attrs shortresult]
        dict incr c shortregs [llength [dict get $attrs shortregs]]
        dict incr c asciiparams [llength [dict get $attrs asciiparams]]
        dict incr c asciiresult [dict get $attrs asciiresult]
        dict incr c asciiregs [llength [dict get $attrs asciiregs]]
        set s [expr {[llength [dict get $attrs shortparams]] || [dict get $attrs shortresult]}]
        set a [expr {[llength [dict get $attrs asciiparams]] || [dict get $attrs asciiresult]}]
        if {$s} { dict incr c shortFunctions }
        if {$a} { dict incr c asciiFunctions }
        if {$s || $a} { dict incr c scalarFunctions }
    }
    return $c
}

# Materialization frontier class of every `shorttostr`: what consumes the
# String. Returns a dict class -> count; also per source short register the
# number of shorttostr ops (for the zero/one/many census).
proc materializations {nir} {
    set classes [dict create]
    set perValue [dict create]
    foreach f [nirFunctions $nir] {
        lassign $f id name attrs body
        set defIsMat [dict create]
        set n [llength $body]
        for {set i 0} {$i < $n} {incr i} {
            set line [string trim [lindex $body $i]]
            if {[regexp {^%(\d+) = op (?:short|ascii)tostr %(\d+)} $line -> d s]} {
                dict set defIsMat $d [list $s $i]
                dict incr perValue "$id:$s"
            }
        }
        dict for {d info} $defIsMat {
            lassign $info s at
            # the first later line that uses %d as an operand
            set cls "other"
            for {set j [expr {$at + 1}]} {$j < $n} {incr j} {
                set line [string trim [lindex $body $j]]
                if {![regexp "(^| )%${d}( |\$)" $line] || [regexp "^%${d} = " $line]} continue
                set cls [ClassifyUse $line $d $name $attrs]
                break
            }
            dict incr classes $cls
        }
    }
    return [list $classes $perValue]
}

proc ClassifyUse {line d fname attrs} {
    if {[regexp {^ret } $line]} {
        return [expr {$fname eq "<program>" ? "program frontier" : "tagged result (return)"}]
    }
    if {[regexp {= op (listnew|listappend)} $line]} { return "collection/storage frontier" }
    if {[regexp {= op (mutarrayset|mutarrayfreeze|mutarrayallocate)} $line] || [regexp {= structnew} $line]} { return "collection/storage frontier" }
    if {[regexp {= op (setfromlist|setcontains)} $line]} { return "collection/storage frontier" }
    if {[regexp {= construct } $line]} { return "general String operation" }
    if {[regexp {= op (strcat|strlower|substr |hash|strutf8bytes|strtclalpha|strtclalnum|veq)} $line]} { return "general String operation" }
    if {[regexp {= op streq} $line]} { return "mixed scalar/tagged use (equality with an unrestricted String)" }
    if {[regexp {= (callvalue)} $line]} { return "generic/dynamic call" }
    if {[regexp {= (closure|staticset)|staticset|^closure} $line]} { return "collection/storage frontier" }
    if {[regexp {= (call|callenv|callmulti|callenvmulti) } $line] || [regexp {^(tail|tailenv) } $line]} { return "tagged argument of an exact call" }
    if {[regexp {= move } $line]} { return "tagged join/move" }
    return "other"
}

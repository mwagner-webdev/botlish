# dumpbin-entries.tcl -- an executable's Botlish unwind entries, as MSVC's
# dumpbin decodes them (WINDOWS-X86-64-MILESTONE-3.md, section 7.2).
#
#   tclsh9.0 audit/windows-unwind/tools/dumpbin-entries.tcl OBJECT-LISTING IMAGE-LISTING OUT
#
# OBJECT-LISTING is `dumpbin /unwindinfo` of a program's COFF object (its
# function table undecoded: each entry's Begin 0, End the function's size
# -- its relocations' addends -- and Info the offset of its UNWIND_INFO in
# the object's .xdata); IMAGE-LISTING the same of the executable linked from
# it, every entry decoded but none named. The program's entries are the one
# run of consecutive image entries with the object's sizes and their
# UNWIND_INFO at the object's distances from each other; each must be the
# frame codegen::unwind describes: RBP pushed, the frame pointer set from
# it. Writes those entries' decodings to OUT, prints what it found, and
# exits 1 when there is not exactly one such run or an entry is another
# frame.

lassign $argv objectListing imageListing out

# The entries of LISTING: {START BEGIN END INFO LINES}, LINES the entry's
# own line and its decoding's.
proc entries {listing} {
    set f [open $listing r]
    set lines [split [read $f] \n]
    close $f
    set found {}
    set current -1
    foreach line $lines {
        set line [string trimright $line \r]
        if {[regexp {^\s+([0-9A-F]{8})\s+([0-9A-F]{8})\s+([0-9A-F]{8})\s+([0-9A-F]{8})\s*$} $line -> a b c d]} {
            lappend found [list [scan $a %x] [scan $b %x] [scan $c %x] [scan $d %x] [list $line]]
            set current [expr {[llength $found] - 1}]
        } elseif {[string match Summary* [string trim $line]]} {
            set current -1
        } elseif {$current >= 0 && [string trim $line] ne ""} {
            lset found $current 4 end+1 $line
        }
    }
    return $found
}

set want [entries $objectListing]
set have [entries $imageListing]
set n [llength $want]
set sizes [lmap e $want {expr {[lindex $e 2] - [lindex $e 1]}}]
set distances [lmap e $want {expr {[lindex $e 3] - [lindex $want 0 3]}}]
set runs {}
for {set i 0} {$i + $n <= [llength $have]} {incr i} {
    set match 1
    for {set k 0} {$k < $n && $match} {incr k} {
        lassign [lindex $have [expr {$i + $k}]] - begin end info
        if {$end - $begin != [lindex $sizes $k] || $info - [lindex $have $i 3] != [lindex $distances $k]} {
            set match 0
        }
    }
    if {$match} { lappend runs $i }
}
puts "the object's table: $n entries, sizes [lmap s $sizes {format %#x $s}]; the image's: [llength $have] entries, runs of them that match: [llength $runs]"
if {$n == 0 || [llength $runs] != 1} {
    exit 1
}
set blocks [lrange $have [lindex $runs 0] [expr {[lindex $runs 0] + $n - 1}]]
set f [open $out w]
set other {}
foreach block $blocks {
    set decoding [lindex $block 4]
    puts $f [join $decoding \n]\n
    foreach needed {{Frame register: rbp} {SET_FPREG, register=rbp} {PUSH_NONVOL, register=rbp}} {
        if {[lsearch -glob $decoding "*$needed*"] < 0} {
            lappend other [format %#x [lindex $block 1]]
            break
        }
    }
}
close $f
puts [format "Botlish entries at RVA %#x..%#x; another frame: %s" [lindex $blocks 0 1] [lindex $blocks end 2] [expr {$other eq {} ? "none" : $other}]]
exit [expr {$other ne {}}]

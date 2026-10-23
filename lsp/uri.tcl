# uri.tcl -- document URIs and file paths at the language server's boundary
# (LSP-MILESTONE-1.md, "Coordinates").
#
#   lsp::uri::toPath URI ?PLATFORM?     the file path a file: URI names
#   lsp::uri::fromPath PATH ?PLATFORM?  the file: URI of an absolute path
#
# PLATFORM is unix or windows (the host's, $::tcl_platform(platform), when
# omitted): the conversions are Tcl string functions, so both are tested on
# any host.
#
# Only file: URIs name documents the compiler can read. toPath decodes the
# path's percent-escapes as UTF-8 (a name with spaces, `#`, `%` or any
# Unicode character round-trips), takes `file:///C:/x` and `file:///c%3A/x`
# on Windows to the drive path `C:/x` / `c:/x`, and a URI with a host
# (`file://server/share/x`) to the UNC path `//server/share/x` there; on Unix
# a host other than `localhost` names another machine's file. Anything else
# -- another scheme, a host on Unix, escapes that are not UTF-8, a NUL -- is
# {LSP URI UNSUPPORTED} with the reason, never a guess.
#
# Paths use `/` (as Tcl's own file commands return them on every platform).

namespace eval lsp::uri {}

proc lsp::uri::Unsupported {uri reason} {
    return -code error -level 2 -errorcode {LSP URI UNSUPPORTED} \
        "unsupported document URI \"[string range $uri 0 200]\": $reason"
}

proc lsp::uri::toPath {uri {platform ""}} {
    if {$platform eq ""} {
        set platform $::tcl_platform(platform)
    }
    if {![regexp {^([A-Za-z][A-Za-z0-9+.-]*):(.*)$} $uri -> scheme rest]} {
        Unsupported $uri "not a URI"
    }
    if {[string tolower $scheme] ne "file"} {
        Unsupported $uri "the $scheme: scheme names no file the compiler can read (only file: URIs do)"
    }
    # A query or fragment is not part of a file's path.
    regsub {[?#].*$} $rest "" rest
    set authority ""
    if {[string range $rest 0 1] eq "//"} {
        set rest [string range $rest 2 end]
        set slash [string first / $rest]
        if {$slash < 0} {
            set authority $rest
            set rest /
        } else {
            set authority [string range $rest 0 [expr {$slash - 1}]]
            set rest [string range $rest $slash end]
        }
    }
    set path [Decode $uri $rest]
    set host [Decode $uri $authority]
    if {[string first \0 $path] >= 0 || [string first \0 $host] >= 0} {
        Unsupported $uri "a NUL character"
    }
    if {[string tolower $host] eq "localhost"} {
        set host ""
    }
    if {$platform eq "windows"} {
        if {$host ne ""} {
            return "//$host$path"
        }
        if {[regexp {^/[A-Za-z]:(/|$)} $path]} {
            set path [string range $path 1 end]
        }
        return $path
    }
    if {$host ne ""} {
        Unsupported $uri "the host \"$host\": the file is on another machine"
    }
    if {[string index $path 0] ne "/"} {
        Unsupported $uri "not an absolute path"
    }
    return $path
}

# TEXT with its percent-escapes decoded, as UTF-8.
proc lsp::uri::Decode {uri text} {
    if {[string first % $text] < 0} {
        return $text
    }
    set bytes ""
    set i 0
    set n [string length $text]
    while {$i < $n} {
        set c [string index $text $i]
        if {$c eq "%"} {
            set hex [string range $text [expr {$i + 1}] [expr {$i + 2}]]
            if {![regexp {^[0-9A-Fa-f]{2}$} $hex]} {
                Unsupported $uri "a malformed percent-escape"
            }
            append bytes [binary format H2 $hex]
            incr i 3
        } else {
            append bytes [encoding convertto utf-8 $c]
            incr i
        }
    }
    if {[catch {encoding convertfrom -profile strict utf-8 $bytes} decoded]} {
        Unsupported $uri "percent-escapes that are not UTF-8"
    }
    return $decoded
}

proc lsp::uri::fromPath {path {platform ""}} {
    if {$platform eq ""} {
        set platform $::tcl_platform(platform)
    }
    set host ""
    if {$platform eq "windows"} {
        set path [string map {\\ /} $path]
        if {[regexp {^//([^/]+)(/.*)?$} $path -> host rest]} {
            set path $rest
            if {$path eq ""} {
                set path /
            }
        } elseif {[regexp {^[A-Za-z]:} $path]} {
            set path /$path
        }
    }
    set encoded ""
    foreach byte [split [encoding convertto utf-8 $path] ""] {
        if {[regexp {^[A-Za-z0-9/._~-]$} $byte]} {
            append encoded $byte
        } else {
            append encoded [format %%%02X [scan $byte %c]]
        }
    }
    if {$platform eq "windows"} {
        # The drive's colon stays as it is.
        regsub {^/([A-Za-z])%3A} $encoded {/\1:} encoded
    }
    return "file://$host$encoded"
}

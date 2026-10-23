# jsonrpc.tcl -- JSON-RPC 2.0 messages for the language server
# (LSP-MILESTONE-1.md, "JSON and JSON-RPC").
#
#   lsp::rpc::classify BYTES          what a message body is (below)
#   lsp::rpc::success ID VALUE        a success response's body
#   lsp::rpc::failure ID NAME MESSAGE ?DATA?  an error response's body
#   lsp::rpc::notification METHOD PARAMS     a notification's body
#   lsp::rpc::request ID METHOD PARAMS       a request's body
#   lsp::rpc::fail CODE MESSAGE       raise CODE from a request handler
#
# Messages are JSON values of lsp::json (typed: an id stays the JSON value
# the peer wrote -- the number 0, the number 12345678901234567890 or the
# string "7" -- and goes back unchanged). Bodies are UTF-8 bytes for
# lsp::transport. Nothing here knows the language server's methods or
# lifecycle; the server (server.tcl) dispatches.
#
# classify returns a dict whose `kind` is
#
#   request       method, id, params ("" when absent)
#   notification  method, params
#   response      id, and result or error
#   invalid       a JSON value that is no JSON-RPC 2.0 message: problem, and
#                 id when the message had a usable one (else JSON null)
#   parse-error   not JSON (or not UTF-8): problem
#
# An array (a batch) is invalid: the language server protocol has none.

namespace eval lsp::rpc {
    # JSON-RPC's and the language server protocol's error codes.
    variable codes [dict create \
        ParseError -32700 InvalidRequest -32600 MethodNotFound -32601 \
        InvalidParams -32602 InternalError -32603 ServerNotInitialized -32002 \
        UnknownErrorCode -32001 RequestFailed -32803 ServerCancelled -32802 \
        ContentModified -32801 RequestCancelled -32800]
}

# The error code named NAME (codes).
proc lsp::rpc::code {name} {
    variable codes
    return [dict get $codes $name]
}

# Raises the JSON-RPC error NAME (codes) with MESSAGE from a request handler:
# the dispatcher answers the request with it.
proc lsp::rpc::fail {name message} {
    return -code error -level 2 -errorcode [list LSP RPC $name] $message
}

proc lsp::rpc::classify {bytes} {
    if {[catch {lsp::json::decode $bytes} message options]} {
        set code [dict get $options -errorcode]
        if {[lindex $code 0] ne "LSP" || [lindex $code 1] ne "JSON"} {
            return -options $options $message
        }
        return [dict create kind parse-error problem $message]
    }
    if {[lsp::json::type $message] ne "obj"} {
        set what [expr {[lsp::json::type $message] eq "arr" ? "a batch (an array), which the language server protocol does not use" : "not a JSON-RPC message (not an object)"}]
        return [dict create kind invalid id [lsp::json::null] problem $what]
    }
    set members [lsp::json::members $message]
    set id [lsp::json::null]
    set hasId [dict exists $members id]
    if {$hasId} {
        set candidate [dict get $members id]
        if {[lsp::json::type $candidate] in {num str}} {
            set id $candidate
        }
    }
    if {![dict exists $members jsonrpc] || [dict get $members jsonrpc] ne {str 2.0}} {
        return [dict create kind invalid id $id problem "not a JSON-RPC 2.0 message (\"jsonrpc\" is not \"2.0\")"]
    }
    if {$hasId && [lsp::json::type [dict get $members id]] ni {num str}} {
        return [dict create kind invalid id $id problem "an id must be a number or a string"]
    }
    if {[dict exists $members method]} {
        set method [dict get $members method]
        if {[lsp::json::type $method] ne "str"} {
            return [dict create kind invalid id $id problem "a method name must be a string"]
        }
        set params ""
        # (A null params is taken for none: clients send it for methods
        # without parameters, shutdown and exit.)
        if {[dict exists $members params] && [dict get $members params] ne {null {}}} {
            set params [dict get $members params]
            if {[lsp::json::type $params] ni {obj arr}} {
                return [dict create kind invalid id $id problem "params must be an object or an array"]
            }
        }
        if {$hasId} {
            return [dict create kind request id $id method [lsp::json::text $method] params $params]
        }
        return [dict create kind notification method [lsp::json::text $method] params $params]
    }
    if {$hasId && ([dict exists $members result] != [dict exists $members error])} {
        set response [dict create kind response id $id]
        if {[dict exists $members result]} {
            dict set response result [dict get $members result]
        } else {
            dict set response error [dict get $members error]
        }
        return $response
    }
    return [dict create kind invalid id $id problem "neither a request, a notification nor a response"]
}

proc lsp::rpc::success {id value} {
    return [lsp::json::encode [lsp::json::obj jsonrpc {str 2.0} id $id result $value]]
}

proc lsp::rpc::failure {id name message {data ""}} {
    set error [lsp::json::obj code [lsp::json::int [code $name]] message [lsp::json::str $message]]
    if {$data ne ""} {
        lset error 1 [dict replace [lindex $error 1] data $data]
    }
    return [lsp::json::encode [lsp::json::obj jsonrpc {str 2.0} id $id error $error]]
}

proc lsp::rpc::notification {method params} {
    return [lsp::json::encode [lsp::json::obj jsonrpc {str 2.0} method [lsp::json::str $method] params $params]]
}

proc lsp::rpc::request {id method params} {
    return [lsp::json::encode [lsp::json::obj jsonrpc {str 2.0} id $id method [lsp::json::str $method] params $params]]
}

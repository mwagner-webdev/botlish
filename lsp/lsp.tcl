# lsp.tcl -- loads Botlish's language server (LSP-MILESTONE-1.md): main.tcl
# sources it for -lsp and -lsp-worker, after the compiler service.
#
#   json.tcl       JSON values (typed), reading and writing
#   transport.tcl  Content-Length framing over Tcl channels
#   jsonrpc.tcl    JSON-RPC 2.0 messages
#   positions.tcl  UTF-16 and UTF-32 positions <-> the compiler's scalars
#   uri.tcl        file: URIs <-> paths
#   stats.tcl      the server's own measurements
#   scheduler.tcl  where analyses run: in process, or a worker process
#   worker.tcl     the analysis worker (main.tcl -lsp-worker)
#   server.tcl     the language server (main.tcl -lsp)

if {[info commands ::service::analyze] eq ""} {
    source [file join [file dirname [file dirname [file normalize [info script]]]] service service.tcl]
}
foreach file {json transport jsonrpc positions uri stats scheduler worker server} {
    source [file join [file dirname [file normalize [info script]]] $file.tcl]
}
unset file

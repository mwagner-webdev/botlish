"""server.py -- the http package's independent test peer
(HTTP-CLIENT-PACKAGE-MILESTONE-1.md, "Testing and interoperability").

An HTTP/1.1 and HTTP/2 server written for the tests, sharing nothing with
the client under test: Python's asyncio and ssl (OpenSSL), the `h2`
library (hyper-h2, a pure-Python HTTP/2 implementation) for HTTP/2, and a
small HTTP/1.1 implementation of its own. TLS offers ALPN h2 and http/1.1
(or what --alpn says); a plaintext port speaks HTTP/1.1.

    python3 -I server.py --port P [--tls CERT KEY] [--alpn h2,http/1.1]

prints "ready PORT" when it listens. Endpoints (GET unless said):

    /hello                 "hello\\n"
    /bytes?n=N             N bytes, byte i = i % 256
    /stream?n=N&size=S&delay=MS&id=ID
                           N chunks of S bytes, MS between them; the bytes
                           written so far are recorded under ID (/progress)
    /progress?id=ID        what /stream ID has written: "written N"
    /echo (any method)     the request body back; x-echo-method,
                           x-echo-version, x-echo-length (the request's
                           content-length, or "none"), and x-echo-HEADER for
                           content-type, authorization, x-custom
    /status/NNN            status NNN, body "status NNN"
    /headers               set-cookie twice, x-multi twice
    /slowhead?delay=MS     the head after MS
    /idle?delay=MS         one chunk, then MS of silence, then one more
    /truncate              HTTP/1.1: content-length 100, 10 bytes, close;
                           HTTP/2: 10 bytes, then RST_STREAM (INTERNAL_ERROR)
    /utf8                  UTF-8 text sent one byte per write
    /close                 HTTP/1.1: connection: close
    /malformed             HTTP/1.1: an invalid status line
    /conns                 "connections N" (TCP connections accepted)
"""

import argparse
import asyncio
import ssl
import sys
import urllib.parse

import h2.config
import h2.connection
import h2.events
import h2.exceptions
import h2.settings

PROGRESS = {}
CONNECTIONS = [0]
UTF8_TEXT = "héllo wörld ✓ \U0001F600 end\n".encode("utf-8")


def parse_target(target):
    parsed = urllib.parse.urlsplit(target)
    query = dict(urllib.parse.parse_qsl(parsed.query))
    return parsed.path, query


def pattern(n, start=0):
    return bytes((start + i) % 256 for i in range(n))


class Response:
    """What a handler answers: a status, headers and body chunks, each
    chunk preceded by a delay (seconds); `reset` ends the stream abruptly
    after the chunks; `head_delay` delays the head."""

    def __init__(self, status=200, headers=None, chunks=None, head_delay=0.0, reset=False, length=None):
        self.status = status
        self.headers = headers or []
        self.chunks = chunks or []
        self.head_delay = head_delay
        self.reset = reset
        self.length = length


def handle(method, path, query, headers, body, version):
    if path == "/hello":
        return Response(headers=[("content-type", "text/plain")], chunks=[(0, b"hello\n")])
    if path == "/bytes":
        n = int(query.get("n", "0"))
        return Response(headers=[("content-type", "application/octet-stream")], chunks=[(0, pattern(n))], length=n)
    if path == "/stream":
        n = int(query.get("n", "10"))
        size = int(query.get("size", "1024"))
        delay = int(query.get("delay", "0")) / 1000.0
        ident = query.get("id", "")
        chunks = [(delay if i else 0, pattern(size, i * size)) for i in range(n)]
        r = Response(headers=[("content-type", "application/octet-stream")], chunks=chunks)
        r.ident = ident
        PROGRESS[ident] = 0
        return r
    if path == "/progress":
        return Response(chunks=[(0, ("written %d" % PROGRESS.get(query.get("id", ""), -1)).encode())])
    if path == "/echo":
        h = dict(headers)
        out = [("x-echo-method", method), ("x-echo-version", version),
               ("x-echo-length", h.get("content-length", "none"))]
        for name in ("content-type", "authorization", "x-custom"):
            if name in h:
                out.append(("x-echo-" + name, h[name]))
        return Response(headers=out, chunks=[(0, body)] if body else [], length=len(body))
    if path.startswith("/status/"):
        code = int(path[len("/status/"):])
        text = ("status %d" % code).encode()
        if code in (204, 304) or method == "HEAD":
            return Response(status=code)
        return Response(status=code, chunks=[(0, text)], length=len(text))
    if path == "/headers":
        return Response(headers=[("set-cookie", "a=1"), ("x-multi", "one"), ("set-cookie", "b=2"), ("x-multi", "two")],
                        chunks=[(0, b"ok")])
    if path == "/slowhead":
        return Response(head_delay=int(query.get("delay", "1000")) / 1000.0, chunks=[(0, b"late")])
    if path == "/idle":
        return Response(chunks=[(0, b"first"), (int(query.get("delay", "1000")) / 1000.0, b"second")])
    if path == "/truncate":
        return Response(chunks=[(0, pattern(10))], reset=True, length=100)
    if path == "/utf8":
        return Response(headers=[("content-type", "text/plain; charset=utf-8")],
                        chunks=[(0.002, UTF8_TEXT[i:i + 1]) for i in range(len(UTF8_TEXT))])
    if path == "/close":
        return Response(headers=[("connection", "close")], chunks=[(0, b"closing")])
    if path == "/conns":
        return Response(chunks=[(0, ("connections %d" % CONNECTIONS[0]).encode())])
    return Response(status=404, chunks=[(0, b"not found")])


# --------------------------------------------------------------- HTTP/1.1

async def read_head(reader):
    data = await reader.readuntil(b"\r\n\r\n")
    lines = data.decode("latin-1").split("\r\n")
    method, target, version = lines[0].split(" ", 2)
    headers = []
    for line in lines[1:]:
        if not line:
            continue
        name, value = line.split(":", 1)
        headers.append((name.strip().lower(), value.strip()))
    return method, target, version, headers


async def read_body(reader, headers):
    h = dict(headers)
    if "content-length" in h:
        n = int(h["content-length"])
        return await reader.readexactly(n) if n else b""
    if h.get("transfer-encoding", "").lower() == "chunked":
        out = b""
        while True:
            size = int((await reader.readuntil(b"\r\n")).strip().split(b";")[0], 16)
            if size == 0:
                await reader.readuntil(b"\r\n")
                return out
            out += await reader.readexactly(size)
            await reader.readexactly(2)
    return b""


async def serve_h1(reader, writer):
    while True:
        try:
            method, target, version, headers = await read_head(reader)
        except (asyncio.IncompleteReadError, ConnectionError, ValueError):
            break
        body = await read_body(reader, headers)
        path, query = parse_target(target)
        if path == "/malformed":
            writer.write(b"HTTP/1.1 9x9 Broken\r\nfoo\r\n\r\n")
            await writer.drain()
            break
        r = handle(method, path, query, headers, body, "HTTP/1.1")
        if r.head_delay:
            await asyncio.sleep(r.head_delay)
        close = any(n == "connection" and v.lower() == "close" for n, v in headers + r.headers) or path in ("/close", "/truncate")
        reason = {200: "OK", 404: "Not Found"}.get(r.status, "Status")
        head = ["HTTP/1.1 %d %s" % (r.status, reason)]
        for n, v in r.headers:
            if n != "connection":
                head.append("%s: %s" % (n, v))
        chunked = r.length is None and r.status not in (204, 304) and method != "HEAD"
        if r.length is not None:
            head.append("content-length: %d" % r.length)
        elif chunked:
            head.append("transfer-encoding: chunked")
        if close:
            head.append("connection: close")
        writer.write(("\r\n".join(head) + "\r\n\r\n").encode("latin-1"))
        await writer.drain()
        ident = getattr(r, "ident", None)
        for delay, chunk in r.chunks:
            if delay:
                await asyncio.sleep(delay)
            writer.write(b"%x\r\n%s\r\n" % (len(chunk), chunk) if chunked else chunk)
            await writer.drain()
            if ident is not None:
                PROGRESS[ident] += len(chunk)
        if chunked and not r.reset:
            writer.write(b"0\r\n\r\n")
            await writer.drain()
        if close or r.reset:
            break
    try:
        writer.close()
        await writer.wait_closed()
    except Exception:
        pass


# ----------------------------------------------------------------- HTTP/2

class H2Conn:
    def __init__(self, reader, writer):
        self.reader = reader
        self.writer = writer
        self.conn = h2.connection.H2Connection(config=h2.config.H2Configuration(client_side=False, header_encoding=None))
        self.windows = {}
        self.streams = {}

    async def flush(self):
        data = self.conn.data_to_send()
        if data:
            self.writer.write(data)
            await self.writer.drain()

    async def run(self):
        self.conn.initiate_connection()
        await self.flush()
        while True:
            try:
                data = await self.reader.read(65536)
            except (ConnectionError, OSError):
                break
            if not data:
                break
            try:
                events = self.conn.receive_data(data)
            except h2.exceptions.ProtocolError:
                await self.flush()
                break
            for event in events:
                if isinstance(event, h2.events.RequestReceived):
                    self.streams[event.stream_id] = {"headers": event.headers, "body": b""}
                    if event.stream_ended:
                        asyncio.ensure_future(self.respond(event.stream_id))
                elif isinstance(event, h2.events.DataReceived):
                    self.conn.acknowledge_received_data(event.flow_controlled_length, event.stream_id)
                    if event.stream_id in self.streams:
                        self.streams[event.stream_id]["body"] += event.data
                    if event.stream_ended:
                        asyncio.ensure_future(self.respond(event.stream_id))
                elif isinstance(event, h2.events.StreamEnded):
                    s = self.streams.get(event.stream_id)
                    if s is not None and "started" not in s:
                        asyncio.ensure_future(self.respond(event.stream_id))
                elif isinstance(event, h2.events.WindowUpdated):
                    for w in list(self.windows.values()):
                        if not w.done():
                            w.set_result(None)
                    self.windows.clear()
                elif isinstance(event, h2.events.StreamReset):
                    self.streams.pop(event.stream_id, None)
            await self.flush()

    async def wait_window(self, stream_id):
        f = asyncio.get_event_loop().create_future()
        self.windows[stream_id] = f
        await f

    async def send_data(self, stream_id, data, ident):
        while data:
            if stream_id not in self.streams:
                return False
            window = min(self.conn.local_flow_control_window(stream_id), self.conn.max_outbound_frame_size)
            if window <= 0:
                await self.wait_window(stream_id)
                continue
            piece, data = data[:window], data[window:]
            self.conn.send_data(stream_id, piece)
            await self.flush()
            if ident is not None:
                PROGRESS[ident] += len(piece)
        return True

    async def respond(self, stream_id):
        s = self.streams.get(stream_id)
        if s is None or "started" in s:
            return
        s["started"] = True
        headers = [(n.decode() if isinstance(n, bytes) else n, v.decode() if isinstance(v, bytes) else v) for n, v in s["headers"]]
        h = dict(headers)
        method = h[":method"]
        path, query = parse_target(h[":path"])
        plain = [(n, v) for n, v in headers if not n.startswith(":")]
        r = handle(method, path, query, plain, s["body"], "HTTP/2")
        if r.head_delay:
            await asyncio.sleep(r.head_delay)
        out = [(":status", str(r.status))] + [(n, v) for n, v in r.headers if n != "connection"]
        if r.length is not None and not r.reset:
            out.append(("content-length", str(r.length)))
        end = not r.chunks and not r.reset
        try:
            self.conn.send_headers(stream_id, out, end_stream=end)
            await self.flush()
            ident = getattr(r, "ident", None)
            for i, (delay, chunk) in enumerate(r.chunks):
                if delay:
                    await asyncio.sleep(delay)
                if not await self.send_data(stream_id, chunk, ident):
                    return
            if r.reset:
                self.conn.reset_stream(stream_id, error_code=2)
            elif r.chunks:
                self.conn.end_stream(stream_id)
            await self.flush()
        except (h2.exceptions.StreamClosedError, h2.exceptions.ProtocolError, ConnectionError):
            pass
        self.streams.pop(stream_id, None)


async def connection(reader, writer):
    CONNECTIONS[0] += 1
    ssl_object = writer.get_extra_info("ssl_object")
    proto = ssl_object.selected_alpn_protocol() if ssl_object else None
    if proto == "h2":
        await H2Conn(reader, writer).run()
        try:
            writer.close()
        except Exception:
            pass
    else:
        await serve_h1(reader, writer)


async def main():
    p = argparse.ArgumentParser()
    p.add_argument("--port", type=int, default=0)
    p.add_argument("--host", default="127.0.0.1")
    p.add_argument("--tls", nargs=2, metavar=("CERT", "KEY"))
    p.add_argument("--alpn", default="h2,http/1.1")
    a = p.parse_args()
    context = None
    if a.tls:
        context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
        context.load_cert_chain(a.tls[0], a.tls[1])
        if a.alpn:
            context.set_alpn_protocols(a.alpn.split(","))
    server = await asyncio.start_server(connection, a.host, a.port, ssl=context, limit=1 << 20)
    port = server.sockets[0].getsockname()[1]
    print("ready %d" % port, flush=True)
    async with server:
        await server.serve_forever()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        sys.exit(0)

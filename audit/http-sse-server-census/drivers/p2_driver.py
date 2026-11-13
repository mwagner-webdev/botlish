#!/usr/bin/env python3
"""Census probe P2's independent client (HTTP-SSE-SERVER-CENSUS-MILESTONE-1.md).

    python3 -I p2_driver.py SERVER_EXECUTABLE [SCENARIO...]

Each scenario starts its own server process (the Botlish executable built
from probes/p2/server.bot) on its own port, drives it over TCP with raw
sockets and curl -- never through Botlish code -- and prints one verdict
line plus the observations behind it. Nothing here implements the server.
"""
import json, os, socket, subprocess, sys, threading, time

EXE = sys.argv[1]
ONLY = set(sys.argv[2:])
BASE_PORT = 18200
CLIENT_TIMEOUT = float(os.environ.get("CLIENT_TIMEOUT", "10"))
results = []

class Server:
    def __init__(self, port, sndbuf=0, sub_limit=65536, heartbeat=1000000, idle=10000000, max_conns=1000, ring=4096):
        self.port = port
        self.p = subprocess.Popen([EXE, str(port), str(sndbuf), str(sub_limit), str(heartbeat), str(idle), str(max_conns), str(ring)],
                                  stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        for _ in range(100):
            try:
                socket.create_connection(("127.0.0.1", port), timeout=0.2).close()
                break
            except OSError:
                time.sleep(0.05)
    def fds(self):
        try:
            return len(os.listdir(f"/proc/{self.p.pid}/fd"))
        except OSError:
            return -1
    def rss_kb(self):
        try:
            for line in open(f"/proc/{self.p.pid}/status"):
                if line.startswith("VmRSS:"):
                    return int(line.split()[1])
        except OSError:
            return -1
    def stop(self):
        try:
            request(self.port, "POST", "/shutdown", timeout=2)
        except Exception:
            pass
        try:
            out, _ = self.p.communicate(timeout=5)
        except subprocess.TimeoutExpired:
            self.p.kill(); out, _ = self.p.communicate(); out += "\n(killed)"
        return self.p.returncode, out

def request(port, method, path, body=b"", headers=None, timeout=5):
    """One request on a fresh connection (Connection: close); (status, headers, body)."""
    s = socket.create_connection(("127.0.0.1", port), timeout=timeout)
    h = {"Host": "t", "Connection": "close"}
    h.update(headers or {})
    if body:
        h["Content-Length"] = str(len(body))
    head = f"{method} {path} HTTP/1.1\r\n" + "".join(f"{k}: {v}\r\n" for k, v in h.items()) + "\r\n"
    s.sendall(head.encode() + body)
    data = recv_all(s)
    s.close()
    return parse_response(data)

def recv_all(s):
    data = b""
    while True:
        try:
            b = s.recv(65536)
        except socket.timeout:
            break
        if not b:
            break
        data += b
    return data

def parse_response(data):
    head, _, body = data.partition(b"\r\n\r\n")
    lines = head.decode("latin-1").split("\r\n")
    status = int(lines[0].split()[1]) if lines and len(lines[0].split()) > 1 else 0
    headers = {}
    for l in lines[1:]:
        if ":" in l:
            k, v = l.split(":", 1); headers[k.strip().lower()] = v.strip()
    return status, headers, body

def stats(port):
    return json.loads(request(port, "GET", "/stats")[2])

def read_responses(s, count, timeout=5):
    """Read COUNT Content-Length responses from one connection."""
    s.settimeout(timeout)
    buf = b""; out = []
    while len(out) < count:
        while b"\r\n\r\n" not in buf:
            b = s.recv(65536)
            if not b: return out
            buf += b
        head, _, rest = buf.partition(b"\r\n\r\n")
        st, hd, _ = parse_response(head + b"\r\n\r\n")
        n = int(hd.get("content-length", "0"))
        while len(rest) < n:
            b = s.recv(65536)
            if not b: break
            rest += b
        out.append((st, rest[:n])); buf = rest[n:]
    return out

class SSE:
    """An event-stream client on its own thread: records (time, event dict)."""
    def __init__(self, port, last_id=None, read=True, rcvbuf=None):
        self.events = []; self.comments = 0; self.closed_at = None; self.status = None
        self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        if rcvbuf:
            self.s.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, rcvbuf)
        self.s.connect(("127.0.0.1", port))
        h = "GET /events HTTP/1.1\r\nHost: t\r\nAccept: text/event-stream\r\n"
        if last_id is not None:
            h += f"Last-Event-ID: {last_id}\r\n"
        self.s.sendall((h + "\r\n").encode())
        if read:
            self.t = threading.Thread(target=self.run, daemon=True); self.t.start()
    def run(self):
        buf = b""; head_done = False
        try:
            while True:
                b = self.s.recv(65536)
                if not b:
                    break
                buf += b
                if not head_done and b"\r\n\r\n" in buf:
                    head, _, buf = buf.partition(b"\r\n\r\n")
                    self.status = head.split(b"\r\n")[0].decode(); head_done = True
                while head_done and b"\n\n" in buf:
                    block, _, buf = buf.partition(b"\n\n")
                    ev = {}
                    for line in block.decode().split("\n"):
                        if line.startswith(":"):
                            self.comments += 1; continue
                        k, _, v = line.partition(":")
                        v = v[1:] if v.startswith(" ") else v
                        ev[k] = ev[k] + "\n" + v if k in ev else v
                    if ev and "retry" not in ev:
                        self.events.append((time.monotonic(), ev))
        except OSError:
            pass
        self.closed_at = time.monotonic()
    def close(self):
        # shutdown first: on Linux, close() while this object's reader
        # thread is blocked in recv() on the socket sends no FIN until the
        # recv returns (the in-flight call holds the file).
        try: self.s.shutdown(socket.SHUT_RDWR)
        except OSError: pass
        try: self.s.close()
        except OSError: pass

def scenario(name):
    def wrap(fn):
        if ONLY and name not in ONLY:
            return fn
        port = BASE_PORT + len(results)
        t0 = time.monotonic()
        try:
            verdict, notes = fn(port)
        except Exception as e:
            verdict, notes = "ERROR", f"{type(e).__name__}: {e}"
        results.append((name, verdict, notes))
        print(f"{name}: {verdict} ({time.monotonic() - t0:.1f}s)\n    {notes}", flush=True)
        return fn
    return wrap

@scenario("S01-curl")
def s01(port):
    srv = Server(port)
    r = subprocess.run(["curl", "-sS", "-i", "--max-time", "5", f"http://127.0.0.1:{port}/health"], capture_output=True, text=True)
    r2 = subprocess.run(["curl", "-sS", "--max-time", "5", "-X", "POST", "-H", "Content-Type: application/json", "-d", '{"name": "first"}', f"http://127.0.0.1:{port}/items"], capture_output=True, text=True)
    r3 = subprocess.run(["curl", "-sS", "--max-time", "5", f"http://127.0.0.1:{port}/items"], capture_output=True, text=True)
    items = json.loads(r3.stdout)
    code, out = srv.stop()
    ok = r.returncode == 0 and r.stdout.startswith("HTTP/1.1 200") and r2.returncode == 0 and items == [{"name": "first"}] and code == 0
    return ("PASS" if ok else "FAIL"), f"curl /health exit {r.returncode} {r.stdout.splitlines()[0]!r}; POST {r2.stdout!r}; GET /items parsed by json.loads: {items}; server exit {code}"

@scenario("S02-keepalive-pipelining")
def s02(port):
    srv = Server(port)
    s = socket.create_connection(("127.0.0.1", port), timeout=5)
    s.sendall(b"GET /health HTTP/1.1\r\nHost: t\r\n\r\n")
    a = read_responses(s, 1)
    s.sendall(b"GET /items HTTP/1.1\r\nHost: t\r\n\r\n")
    b = read_responses(s, 1)
    s.sendall(b"GET /health HTTP/1.1\r\nHost: t\r\n\r\nGET /stats HTTP/1.1\r\nHost: t\r\n\r\nGET /health HTTP/1.1\r\nHost: t\r\nConnection: close\r\n\r\n")
    c = read_responses(s, 3)
    tail = recv_all(s)
    s.close()
    st = stats(port)
    code, _ = srv.stop()
    ok = [x[0] for x in a + b + c] == [200] * 5 and tail == b"" and st["accepted"] == 3
    return ("PASS" if ok else "FAIL"), f"5 responses on one connection {[x[0] for x in a + b + c]}, 3 of them pipelined in one send; closed after 'Connection: close' (tail {tail!r}); accepted connections {st['accepted']} (the driver's readiness probe, this one, the stats request)"

@scenario("S03-fragmented")
def s03(port):
    srv = Server(port)
    body = '{"name": "café ☕"}'.encode()
    req = b"POST /items HTTP/1.1\r\nHost: t\r\nContent-Length: " + str(len(body)).encode() + b"\r\n\r\n" + body
    s = socket.create_connection(("127.0.0.1", port), timeout=5)
    for i in range(len(req)):
        s.sendall(req[i:i + 1]); time.sleep(0.003)
    r = read_responses(s, 1)
    s.close()
    items = json.loads(request(port, "GET", "/items")[2])
    code, _ = srv.stop()
    ok = r and r[0][0] == 201 and items == [{"name": "café ☕"}]
    return ("PASS" if ok else "FAIL"), f"{len(req)} one-byte sends (the UTF-8 body split inside multi-byte characters): status {r[0][0] if r else None}; stored item {items}"

@scenario("S04-concurrency")
def s04(port):
    srv = Server(port, idle=2000000)
    stalled = socket.create_connection(("127.0.0.1", port), timeout=5)
    stalled.sendall(b"GET /health HTTP/1.1\r\nHo")          # a head never finished
    lat = []
    for _ in range(20):
        t = time.monotonic(); st, _, _ = request(port, "GET", "/health"); lat.append((time.monotonic() - t) * 1000)
    # the stalled client is closed by the idle deadline (2 s)
    stalled.settimeout(5); t = time.monotonic(); tail = recv_all(stalled); waited = time.monotonic() - t
    st = stats(port)
    code, _ = srv.stop()
    ok = max(lat) < 100 and tail == b"" and 1.0 < waited < 4.5 and st["idle_closed"] == 1
    return ("PASS" if ok else "FAIL"), f"20 requests while another connection holds half a head: max latency {max(lat):.1f} ms, median {sorted(lat)[10]:.1f} ms; the stalled connection closed by the idle deadline after {waited:.2f}s more (idle_closed {st['idle_closed']})"

@scenario("S05-sse-stream")
def s05(port):
    srv = Server(port)
    c = SSE(port); time.sleep(0.2)
    sent = []
    for i in range(3):
        # a JSON object with a line break between its members: the event's
        # data must be split into data lines and rejoined by the client
        sent.append(time.monotonic()); request(port, "POST", "/items", body=('{"n": %d,\r\n "text": "x"}' % i).encode()); time.sleep(0.3)
    time.sleep(0.2)
    got = c.events
    lat = [(g[0] - s) * 1000 for g, s in zip(got, sent)]
    still_open = c.closed_at is None
    c.close(); code, _ = srv.stop()
    ids = [e[1].get("id") for e in got]
    data = [json.loads(e[1]["data"]) for e in got]
    ok = c.status == "HTTP/1.1 200 OK" and ids == ["1", "2", "3"] and max(lat) < 100 and still_open and data == [{"n": i, "text": "x"} for i in range(3)]
    return ("PASS" if ok else "FAIL"), f"status {c.status!r}; 3 events over one response, 300 ms apart: ids {ids}, events {[e[1].get('event') for e in got]}, latency after each POST {[round(x, 1) for x in lat]} ms; a CRLF inside the data arrived as two data lines, rejoined by the client: {got[0][1]['data']!r} -> {data[0]}; connection still open after the last event: {still_open}"

@scenario("S06-requests-beside-streams")
def s06(port):
    srv = Server(port)
    subs = [SSE(port) for _ in range(5)]; time.sleep(0.2)
    lat = []
    for i in range(50):
        t = time.monotonic(); request(port, "GET", "/health"); lat.append((time.monotonic() - t) * 1000)
    request(port, "POST", "/items", body=b'{"x": 1}'); time.sleep(0.3)
    counts = [len(s.events) for s in subs]
    st = stats(port)
    for s in subs: s.close()
    code, _ = srv.stop()
    ok = counts == [1] * 5 and max(lat) < 100 and st["subscribers"] == 5
    return ("PASS" if ok else "FAIL"), f"5 open streams; 50 ordinary requests: max {max(lat):.1f} ms, median {sorted(lat)[25]:.1f} ms; one POST reached every stream: {counts}"

@scenario("S07-heartbeat")
def s07(port):
    srv = Server(port, heartbeat=300000)
    c = SSE(port); time.sleep(1.65)
    n = c.comments; c.close(); srv.stop()
    ok = 4 <= n <= 7
    return ("PASS" if ok else "FAIL"), f"an idle stream received {n} heartbeat comments in 1.65 s (period 300 ms, ticked by the 100 ms ticker)"

@scenario("S08-disconnect")
def s08(port):
    srv = Server(port)
    base = srv.fds()
    subs = [SSE(port) for _ in range(3)]; time.sleep(0.3)
    during = srv.fds()
    t = time.monotonic()
    for s in subs: s.close()
    ended = None
    for _ in range(100):
        st = stats(port)
        if st["subscribers_ended"] == 3:
            ended = time.monotonic() - t; break
        time.sleep(0.01)
    after = srv.fds()
    code, _ = srv.stop()
    ok = ended is not None and ended < 0.5 and after == base and st["released"] == st["closed"]
    return ("PASS" if ok else "FAIL"), f"server descriptors: {base} idle, {during} with 3 streams, {after} after the clients closed; all 3 streams ended {ended*1000 if ended else -1:.0f} ms after the close with no event written to them (EOF seen by the read side); released {st['released']} == closed {st['closed']}"

@scenario("S09-last-event-id")
def s09(port):
    srv = Server(port)
    for i in range(5):
        request(port, "POST", "/items", body=json.dumps({"n": i}).encode())
    c = SSE(port, last_id=2); time.sleep(0.3)
    ids = [e[1]["id"] for e in c.events]
    c.close(); srv.stop()
    ok = ids == ["3", "4", "5"]
    return ("PASS" if ok else "FAIL"), f"reconnect with Last-Event-ID: 2 after 5 events: received ids {ids} from the in-memory ring (no durable replay)"

@scenario("S10-slow-consumer")
def s10(port):
    srv = Server(port, sndbuf=4096, sub_limit=65536)
    healthy = SSE(port)
    slow = SSE(port, read=False, rcvbuf=4096)
    time.sleep(0.3)
    rss0 = srv.rss_kb()
    t = time.monotonic()
    st0, _, b = request(port, "POST", "/burst?n=2000&size=200", timeout=30)
    burst_s = time.monotonic() - t
    time.sleep(1.0)
    st = stats(port); rss1 = srv.rss_kb()
    # the slow client: its connection is closed by the server
    slow.s.settimeout(3)
    got = recv_all(slow.s)
    lat = []
    for _ in range(10):
        t = time.monotonic(); request(port, "GET", "/health"); lat.append((time.monotonic() - t) * 1000)
    n_healthy = len(healthy.events)
    healthy.close(); slow.close(); code, _ = srv.stop()
    ok = st["slow_dropped"] == 1 and n_healthy == 2000 and st["max_pending"] <= 65536 + 32 * 300 and max(lat) < 100
    return ("PASS" if ok else "FAIL"), f"2000 events of ~230 bytes: the healthy stream received {n_healthy}; the stream that never reads was dropped (slow_dropped {st['slow_dropped']}) with at most {st['max_pending']} bytes queued (limit 65536); it received {len(got)} bytes before the close; RSS {rss0} -> {rss1} KiB; eagain {st['eagain']}, mode switches {st['mode_switches']}; burst took {burst_s:.2f}s; ordinary requests afterwards: max {max(lat):.1f} ms"

@scenario("S11-limits-and-malformed")
def s11(port):
    srv = Server(port)
    def raw(data):
        s = socket.create_connection(("127.0.0.1", port), timeout=5); s.sendall(data)
        r = recv_all(s); s.close(); return parse_response(r)[0] if r else None
    cases = {
        "header > 8 KiB": raw(b"GET /health HTTP/1.1\r\nHost: t\r\nX-Big: " + b"a" * 9000 + b"\r\n\r\n"),
        "body > 64 KiB": raw(b"POST /items HTTP/1.1\r\nHost: t\r\nContent-Length: 100000\r\n\r\n"),
        "garbage request line": raw(b"HELLO\r\n\r\n"),
        "no Host (HTTP/1.1)": raw(b"GET /health HTTP/1.1\r\n\r\n"),
        "chunked request body": raw(b"POST /items HTTP/1.1\r\nHost: t\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\n"),
        "HTTP/2.0 version": raw(b"GET /health HTTP/2.0\r\nHost: t\r\n\r\n"),
        "invalid UTF-8 head": raw(b"GET /\xff\xfe HTTP/1.1\r\nHost: t\r\n\r\n"),
        "non-JSON body": raw(b"POST /items HTTP/1.1\r\nHost: t\r\nContent-Length: 5\r\n\r\nhello"),
        "unknown path": raw(b"GET /nope HTTP/1.1\r\nHost: t\r\nConnection: close\r\n\r\n"),
        "HTTP/1.0 default close": raw(b"GET /health HTTP/1.0\r\n\r\n"),
    }
    alive = request(port, "GET", "/health")[0]
    srv.stop()
    expect = {"header > 8 KiB": 431, "body > 64 KiB": 413, "garbage request line": 400, "no Host (HTTP/1.1)": 400, "chunked request body": 501,
              "HTTP/2.0 version": 505, "invalid UTF-8 head": 400, "non-JSON body": 400, "unknown path": 404, "HTTP/1.0 default close": 200}
    ok = cases == expect and alive == 200
    return ("PASS" if ok else "FAIL"), f"{cases}; server still answers: {alive}"

@scenario("S12-many-connections")
def s12(port):
    srv = Server(port)
    errors = []; done = []
    def client():
        try:
            s = socket.create_connection(("127.0.0.1", port), timeout=CLIENT_TIMEOUT)
            for i in range(5):
                s.sendall(b"GET /health HTTP/1.1\r\nHost: t\r\n\r\n")
                r = read_responses(s, 1, timeout=CLIENT_TIMEOUT)
                if not r or r[0][0] != 200: errors.append("bad"); break
            s.close(); done.append(1)
        except Exception as e:
            errors.append(str(e))
    t = time.monotonic()
    ts = [threading.Thread(target=client) for _ in range(200)]
    for x in ts: x.start()
    for x in ts: x.join()
    wall = time.monotonic() - t
    st = stats(port); fds = srv.fds()
    srv.stop()
    ok = len(done) == 200 and not errors
    return ("PASS" if ok else "FAIL"), f"200 concurrent clients x 5 keep-alive requests: {len(done)} completed, {len(errors)} errors {sorted(set(errors))[:3]}, {wall:.2f}s wall (client timeout {CLIENT_TIMEOUT}s); requests {st['requests']}; server descriptors afterwards {fds}"

@scenario("S13-shutdown-with-active-connections")
def s13(port):
    srv = Server(port, idle=60000000)
    subs = [SSE(port) for _ in range(3)]
    stalled = socket.create_connection(("127.0.0.1", port), timeout=5); stalled.sendall(b"GET /hea")
    idle = socket.create_connection(("127.0.0.1", port), timeout=5); idle.sendall(b"GET /health HTTP/1.1\r\nHost: t\r\n\r\n"); read_responses(idle, 1)
    time.sleep(0.3)
    t = time.monotonic()
    st, _, _ = request(port, "POST", "/shutdown")
    try:
        out, _ = srv.p.communicate(timeout=5); code = srv.p.returncode
    except subprocess.TimeoutExpired:
        srv.p.kill(); out, _ = srv.p.communicate(); code = "killed"
    exit_s = time.monotonic() - t
    time.sleep(0.1)
    got_shutdown = [any(e[1].get("event") == "shutdown" for e in s.events) for s in subs]
    closed = [s.closed_at is not None for s in subs]
    stalled.settimeout(2); idle.settimeout(2)
    eofs = [recv_all(stalled) == b"", recv_all(idle) == b""]
    final = [l for l in out.splitlines() if l.startswith(("run", "stats", "outcomes"))]
    stats_line = json.loads(final[1][6:]) if len(final) > 1 else {}
    ok = code == 0 and all(got_shutdown) and all(closed) and all(eofs) and stats_line.get("released") == stats_line.get("accepted") and exit_s < 2
    return ("PASS" if ok else "FAIL"), f"POST /shutdown with 3 streams, a half-sent head and an idle keep-alive connection: server exit {code} after {exit_s:.2f}s; every stream got 'event: shutdown' {got_shutdown} then EOF {closed}; the other two saw EOF {eofs}; final: {final}"

@scenario("S14-rst-during-burst")
def s14(port):
    srv = Server(port, sndbuf=4096)
    c = SSE(port, read=False, rcvbuf=4096); time.sleep(0.2)
    def burst():
        try: request(port, "POST", "/burst?n=500&size=200", timeout=10)
        except Exception: pass
    th = threading.Thread(target=burst); th.start(); time.sleep(0.05)
    c.s.setsockopt(socket.SOL_SOCKET, socket.SO_LINGER, b"\x01\x00\x00\x00\x00\x00\x00\x00")
    c.s.close()                                     # RST while the server writes
    th.join()
    alive = request(port, "GET", "/health")[0]
    st = stats(port)
    code, _ = srv.stop()
    ok = alive == 200 and code == 0
    return ("PASS" if ok else "FAIL"), f"client reset its stream while the server was writing (SO_LINGER 0): server still answers {alive}, exit {code} (sendto with MSG_NOSIGNAL; the runtime also ignores SIGPIPE); stream ended {st['subscribers_ended']}"

@scenario("S15-memory-steady")
def s15(port):
    srv = Server(port)
    def batch(n):
        s = socket.create_connection(("127.0.0.1", port), timeout=10)
        for i in range(n):
            s.sendall(b"GET /health HTTP/1.1\r\nHost: t\r\n\r\n")
            read_responses(s, 1)
        s.close()
    batch(1000); r1 = srv.rss_kb()
    for _ in range(5): batch(1000)
    r2 = srv.rss_kb()
    for _ in range(20): request(port, "GET", "/health")
    r3 = srv.rss_kb()
    srv.stop()
    ok = r2 - r1 < 2048
    return ("PASS" if ok else "FAIL"), f"VmRSS after 1000 keep-alive requests {r1} KiB, after 6000 {r2} KiB, after 20 more connections {r3} KiB"

print()
print("summary:", " ".join(f"{n}={v}" for n, v, _ in results))

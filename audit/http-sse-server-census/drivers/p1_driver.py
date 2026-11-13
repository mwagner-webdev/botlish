#!/usr/bin/env python3
"""Census probe P1's independent client (HTTP-SSE-SERVER-CENSUS-MILESTONE-1.md).

Starts the P1 executable (probes/p1/listen.bot built; argv[1]) on PORT
(argv[2]) serving 3 connections, then:
  1. curl -sS -i  (an ordinary client, one send)
  2. a request sent in 1-3 byte fragments with 20 ms gaps
  3. a request whose path holds a 2-byte UTF-8 character split across two
     fragments (the head is accumulated as decoded text per read)
Prints every client-side observation; the server's trace follows.
"""
import socket, subprocess, sys, time

exe, port = sys.argv[1], int(sys.argv[2])
srv = subprocess.Popen([exe, str(port), "3"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
time.sleep(0.5)

def report(name, fn):
    try:
        print(f"[{name}] " + fn())
    except Exception as e:
        print(f"[{name}] CLIENT ERROR {type(e).__name__}: {e}")

def curl():
    r = subprocess.run(["curl", "-sS", "-i", "--max-time", "5", f"http://127.0.0.1:{port}/health"], capture_output=True, text=True)
    return f"curl exit {r.returncode}; status line {r.stdout.splitlines()[0] if r.stdout else ''!r}; body {r.stdout.split(chr(13)+chr(10)*2 if False else chr(10)+chr(10))[-1]!r}; stderr {r.stderr.strip()!r}".replace("\r", "")

def fragmented(payload, cuts, gap=0.02):
    s = socket.create_connection(("127.0.0.1", port), timeout=5)
    i = 0
    for c in cuts:
        s.sendall(payload[i:i + c]); i += c
        time.sleep(gap)
    s.sendall(payload[i:])
    data = b""
    while True:
        b = s.recv(4096)
        if not b: break
        data += b
    s.close()
    return data

def frag_small():
    req = b"GET /items?x=1 HTTP/1.1\r\nHost: t\r\nUser-Agent: frag\r\n\r\n"
    cuts = [1 + (k % 3) for k in range(25)]
    data = fragmented(req, cuts)
    return f"fragments {len(cuts)+1}; response {data!r}"

def frag_utf8():
    req = "GET /café HTTP/1.1\r\nHost: t\r\n\r\n".encode()
    k = req.index(b"\xc3") + 1          # cut inside the 2-byte character
    data = fragmented(req, [k])
    return f"cut at byte {k} (inside U+00E9); response {data!r}"

report("1 curl", curl)
report("2 fragmented", frag_small)
report("3 utf8 split", frag_utf8)
try:
    out, _ = srv.communicate(timeout=5)
except subprocess.TimeoutExpired:
    srv.kill(); out, _ = srv.communicate()
    out += "\n(server killed after timeout)"
print(f"[server exit {srv.returncode}]")
print(out.rstrip())

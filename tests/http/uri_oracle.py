"""uri_oracle.py -- an independent statement of the http package's URI rules
(packages/http/http.bot's `uri`; HTTP-CLIENT-PACKAGE-MILESTONE-1.md,
"URIs"), for audit/http-client/tools/uri-fuzz.tcl: Python's ipaddress for
the address forms, and the rules written out here again, from RFC 3986 and
the package's documentation, never from its code.

    python3 -I uri_oracle.py URI...   one line per URI: "invalid" or
                                      "SCHEME HOST PORT TARGET AUTHORITY"
"""
import ipaddress
import sys

UNRESERVED = set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
SUBDELIMS = set("!$&'()*+,;=")
PCHAR = UNRESERVED | SUBDELIMS | set(":@/")
HEX = set("0123456789abcdefABCDEF")


def escaped(text, query):
    i = 0
    while i < len(text):
        c = text[i]
        if c == "%":
            if i + 2 >= len(text):
                return False
            if text[i + 1] not in HEX or text[i + 2] not in HEX:
                return False
        elif c == "?":
            if not query:
                return False
        elif c not in PCHAR:
            return False
        i += 1
    return True


def dns_name(h):
    if not h or len(h) > 254:
        return False
    if len(h) == 254 and not h.endswith("."):
        return False
    labels = h[:-1].split(".") if h.endswith(".") else h.split(".")
    for label in labels:
        if not label or len(label) > 63:
            return False
        if label[0] == "-" or label[-1] == "-":
            return False
        if any(not (c.isascii() and (c.isalnum() or c in "-_")) for c in label):
            return False
    return True


def ipv4(h):
    try:
        ipaddress.IPv4Address(h)
        return True
    except ValueError:
        return False


def parse(text):
    if any(ord(c) <= 32 or ord(c) >= 127 for c in text):
        return None
    colon = text.find(":")
    if colon <= 0:
        return None
    scheme = text[:colon]
    if not scheme[0].isalpha() or any(not (c.isalnum() or c in "+-.") for c in scheme):
        return None
    scheme = scheme.lower()
    if scheme not in ("http", "https") or text[colon + 1:colon + 3] != "//":
        return None
    rest = text[colon + 3:]
    stop = min([rest.find(c) for c in "/?#" if rest.find(c) >= 0] or [len(rest)])
    authority, tail = rest[:stop], rest[stop:]
    if "@" in authority or not authority:
        return None
    if authority.startswith("["):
        close = authority.find("]")
        if close < 0:
            return None
        inner = authority[1:close]
        if "%" in inner:
            return None
        try:
            ipaddress.IPv6Address(inner)
        except ValueError:
            return None
        host = inner.lower()
        after = authority[close + 1:]
    else:
        c = authority.find(":")
        raw = authority if c < 0 else authority[:c]
        after = "" if c < 0 else authority[c:]
        host = raw.lower()
        if host and all(ch.isdigit() or ch == "." for ch in host):
            if not ipv4(host):
                return None
        elif not dns_name(host):
            return None
    default = 443 if scheme == "https" else 80
    if after:
        if after[0] != ":":
            return None
        digits = after[1:]
        if digits == "":
            port = default
        else:
            if not digits.isdigit() or not digits.isascii():
                return None
            port = int(digits)
            if port < 1 or port > 65535:
                return None
    else:
        port = default
    q = tail.find("?")
    h = tail.find("#")
    path_end = min([x for x in (q, h) if x >= 0] or [len(tail)])
    path = tail[:path_end]
    if not escaped(path, False):
        return None
    has_query = path_end < len(tail) and tail[path_end] == "?"
    query = ""
    if has_query:
        end = h if h >= 0 else len(tail)
        query = tail[path_end + 1:end]
        if not escaped(query, True):
            return None
    if h >= 0:
        fragment = tail[h + 1:]
        if "#" in fragment or not escaped(fragment, True):
            return None
    target = (path or "/") + ("?" + query if has_query else "")
    shown = "[" + host + "]" if ":" in host else host
    auth = shown if port == default else "%s:%d" % (shown, port)
    return "%s %s %d %s %s" % (scheme, host, port, target, auth)


if __name__ == "__main__":
    for arg in sys.argv[1:]:
        r = parse(arg)
        print(r if r is not None else "invalid")

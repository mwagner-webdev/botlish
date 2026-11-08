"""header_oracle.py -- an independent statement of the http package's
request-header rules (packages/http/http.bot's `header`; GUIDE.md, section
3), for audit/http-client/tools/syntax-fuzz.tcl: RFC 9110's token for the
name, the documented field-value rule for the value, the documented list of
names the client sets itself. Written from the documentation, never from
the package's code.

    python3 -I header_oracle.py NAME VALUE ...   one line per pair:
                                                 "accepted LOWERNAME" or "refused"
"""
import sys

TCHAR = set("!#$%&'*+-.^_`|~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
CLIENT_OWNED = {"connection", "keep-alive", "proxy-connection", "transfer-encoding",
                "upgrade", "te", "host", "content-length"}


def check(name, value):
    if not name or any(c not in TCHAR for c in name):
        return "refused"
    lower = name.lower()
    if lower in CLIENT_OWNED:
        return "refused"
    for i, c in enumerate(value):
        k = ord(c)
        if k in (9, 32):
            if i == 0 or i == len(value) - 1:
                return "refused"
        elif k < 32 or k == 127:
            return "refused"
    return "accepted " + lower


if __name__ == "__main__":
    args = sys.argv[1:]
    for i in range(0, len(args) - 1, 2):
        print(check(args[i], args[i + 1]))

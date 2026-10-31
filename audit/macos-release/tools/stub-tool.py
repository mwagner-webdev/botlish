#!/usr/bin/env python3
"""stub-tool.py -- recording stand-ins for Apple's tools, for release.py's
tests (audit/macos-release/tests/test_release.py). Installed under the
names security, codesign, spctl, xcrun, ditto, xattr and unzip in a
directory put first on PATH; every invocation is appended to
$STUB_STATE/calls.log (one JSON list per line), and what each tool does is
a small model of the real one, configured by $STUB_STATE/config.json:

  security     keychains (files), their search list, imports (the .p12
               read with the password, as the real one must), identities
               (valid only when config "valid"), Apple Root CA's hash
  codesign     a signature: Contents/_CodeSignature/CodeResources holding
               the identity, the flags and a seal of every file but the
               signature and the stapled ticket; --verify recomputes the
               seal; -dvvv prints codesign's fields (Authority chain,
               TeamIdentifier, Timestamp, flags, CDHash)
  spctl        accepted as "Notarized Developer ID" only for an Apple-chain
               signature with a stapled ticket of its CDHash
  xcrun        notarytool (store-credentials, submit, wait, info, log) and
               stapler (staple, validate), their answers from the config
  ditto/unzip  ZIP archives with the files' modes (zipfile); copies
  xattr        nothing
"""
import hashlib
import json
import os
import shutil
import stat
import sys
import uuid
import zipfile

STATE = os.environ["STUB_STATE"]
TOOL = os.environ.get("STUB_TOOL") or os.path.basename(sys.argv[0])
ARGS = sys.argv[1:]


def config():
    path = os.path.join(STATE, "config.json")
    if os.path.exists(path):
        with open(path) as f:
            return json.load(f)
    return {}


CFG = config()


def save(name, value):
    with open(os.path.join(STATE, name + ".json"), "w") as f:
        json.dump(value, f)


def load(name, default):
    path = os.path.join(STATE, name + ".json")
    if os.path.exists(path):
        with open(path) as f:
            return json.load(f)
    return default


with open(os.path.join(STATE, "calls.log"), "a") as f:
    f.write(json.dumps([TOOL] + ARGS) + "\n")


def opt(name, default=None):
    return ARGS[ARGS.index(name) + 1] if name in ARGS else default


def die(text, code=1):
    print(text, file=sys.stderr)
    sys.exit(code)


# --- signatures -----------------------------------------------------------------

def bundle_of(path):
    p = os.path.abspath(path)
    while p != "/" and not p.endswith(".app"):
        p = os.path.dirname(p)
    return p


def seal(app):
    h = hashlib.sha256()
    for dirpath, dirnames, filenames in os.walk(app):
        dirnames.sort()
        for n in sorted(filenames):
            p = os.path.join(dirpath, n)
            rel = os.path.relpath(p, app)
            if rel in ("Contents/_CodeSignature/CodeResources", "Contents/CodeResources"):
                continue
            h.update(rel.encode() + b"\0" + oct(os.stat(p).st_mode & 0o777).encode() + b"\0")
            with open(p, "rb") as f:
                h.update(f.read())
    return h.hexdigest()


def signature(app):
    p = os.path.join(app, "Contents", "_CodeSignature", "CodeResources")
    if not os.path.exists(p):
        return None
    with open(p) as f:
        return json.load(f)


def info_plist(app):
    import plistlib
    with open(os.path.join(app, "Contents", "Info.plist"), "rb") as f:
        return plistlib.load(f)


def codesign():
    if "--sign" in ARGS:
        app = ARGS[-1]
        if CFG.get("sign_fails"):
            die("%s: errSecInternalComponent" % app)
        ident = opt("--sign")
        identities = load("identities", {})
        if ident != "-":
            kc = opt("--keychain")
            if not kc or ident not in identities.get(kc, {}):
                die("%s: no identity found" % ident)
            subject, team = identities[kc][ident]
        else:
            subject, team = None, None
        runtime = opt("--options") == "runtime" and CFG.get("sign_runtime", True)
        timestamp = "--timestamp" in ARGS and CFG.get("timestamp", True)
        s = seal(app)
        sig = {"identity": ident, "subject": subject, "team": team, "runtime": runtime, "timestamp": timestamp, "seal": s,
               "cdhash": hashlib.sha1((s + ident).encode()).hexdigest(), "apple": bool(CFG.get("apple_chain")) and ident != "-"}
        os.makedirs(os.path.join(app, "Contents", "_CodeSignature"), exist_ok=True)
        with open(os.path.join(app, "Contents", "_CodeSignature", "CodeResources"), "w") as f:
            json.dump(sig, f)
        print("%s: replacing existing signature" % app, file=sys.stderr)
        return
    if "--verify" in ARGS:
        app = bundle_of(ARGS[-1])
        sig = signature(app)
        if sig is None:
            die("%s: code object is not signed at all" % ARGS[-1])
        if seal(app) != sig["seal"]:
            die("%s: a sealed resource is missing or invalid" % ARGS[-1])
        print("%s: valid on disk\n%s: satisfies its Designated Requirement" % (ARGS[-1], ARGS[-1]), file=sys.stderr)
        return
    if "--entitlements" in ARGS:
        if CFG.get("entitlements"):
            print('<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict><key>%s</key><true/></dict></plist>'
                  % CFG["entitlements"])
        return
    if "-dvvv" in ARGS:
        app = bundle_of(ARGS[-1])
        sig = signature(app)
        if sig is None:
            die("%s: code object is not signed at all" % ARGS[-1])
        flags = (["adhoc"] if sig["identity"] == "-" else []) + (["runtime"] if sig["runtime"] else [])
        value = (0x2 if sig["identity"] == "-" else 0) | (0x10000 if sig["runtime"] else 0)
        lines = ["Executable=%s/Contents/MacOS/icy-tower" % app, "Identifier=%s" % info_plist(app)["CFBundleIdentifier"],
                 "Format=app bundle with Mach-O thin (arm64)",
                 "CodeDirectory v=20500 size=1 flags=0x%x(%s) hashes=1+7 location=embedded" % (value, ",".join(flags) or "none"),
                 "CDHash=%s" % sig["cdhash"]]
        if sig["identity"] == "-":
            lines += ["Signature=adhoc", "TeamIdentifier=not set"]
        else:
            lines += ["Signature size=9000", "Authority=%s" % sig["subject"]]
            if sig["apple"]:
                lines += ["Authority=Developer ID Certification Authority", "Authority=Apple Root CA"]
            if sig["timestamp"]:
                lines.append("Timestamp=Oct 31, 2026 at 10:00:00")
            else:
                lines.append("Signed Time=Oct 31, 2026 at 10:00:00")
            lines.append("TeamIdentifier=%s" % sig["team"])
        print("\n".join(lines), file=sys.stderr)
        return
    die("codesign stub: unknown use %s" % ARGS)


# --- security -----------------------------------------------------------------------

def security():
    cmd = ARGS[0]
    if CFG.get("echo_args"):
        print("security called with: " + " ".join(ARGS))
    if cmd == "list-keychains":
        if "-s" in ARGS:
            save("searchlist", ARGS[ARGS.index("-s") + 1:])
        else:
            for k in load("searchlist", ["/Users/runner/Library/Keychains/login.keychain-db"]):
                print('    "%s"' % k)
        return
    if cmd == "create-keychain":
        path = ARGS[-1]
        with open(path, "w") as f:
            f.write("stub keychain")
        pw = load("passwords", {})
        pw[path] = opt("-p")
        save("passwords", pw)
        return
    if cmd in ("set-keychain-settings", "set-key-partition-list"):
        return
    if cmd == "unlock-keychain":
        if load("passwords", {}).get(ARGS[-1]) != opt("-p"):
            die("security: SecKeychainUnlock: The user name or passphrase you entered is not correct.")
        return
    if cmd == "import":
        path, kc = ARGS[1], opt("-k")
        if opt("-t") == "cert":
            return
        if CFG.get("import_fails"):
            die("security: SecKeychainItemImport: MAC verification failed during PKCS12 import (wrong password?)")
        from cryptography.hazmat.primitives.serialization import pkcs12
        from cryptography.hazmat.primitives import serialization
        with open(path, "rb") as f:
            data = f.read()
        try:
            loaded = pkcs12.load_pkcs12(data, (opt("-P") or "").encode())
        except ValueError:
            die("security: SecKeychainItemImport: MAC verification failed during PKCS12 import (wrong password?)")
        cert = loaded.cert.certificate
        der = cert.public_bytes(serialization.Encoding.DER)
        sha1 = hashlib.sha1(der).hexdigest().upper()
        cn = [a.value for a in cert.subject if a.oid.dotted_string == "2.5.4.3"][0]
        ou = [a.value for a in cert.subject if a.oid.dotted_string == "2.5.4.11"][0]
        ids = load("identities", {})
        ids.setdefault(kc, {})[sha1] = [cn, ou]
        for extra in CFG.get("extra_identities", []):
            ids[kc][extra] = ["Developer ID Application: Another (OTHER98765)", "OTHER98765"]
        save("identities", ids)
        print("1 identity imported.")
        return
    if cmd == "find-identity":
        kc = ARGS[-1]
        ids = load("identities", {}).get(kc, {})
        valid = "-v" in ARGS
        n = 0
        print("\nPolicy: Code Signing\n  Matching identities")
        for i, (h, (cn, ou)) in enumerate(sorted(ids.items()), 1):
            if valid and not CFG.get("valid", True):
                continue
            suffix = "" if CFG.get("valid", True) else " (CSSMERR_TP_NOT_TRUSTED)"
            print('  %d) %s "%s"%s' % (i, h, cn, suffix))
            n += 1
        print("     %d %sidentities found" % (n, "valid " if valid else ""))
        return
    if cmd == "find-certificate":
        h = CFG.get("root_sha256", "B0B1730ECBC7FF4505142C49F1295E6EDA6BCAED7E2C68C5BE91B5A11001F024")
        print("SHA-256 hash: %s\nSHA-1 hash: 611E5B662C593A08FF58D14AE22452D198DF6C60" % h)
        return
    if cmd == "delete-keychain":
        if os.path.exists(ARGS[-1]):
            os.unlink(ARGS[-1])
        return
    die("security stub: unknown use %s" % ARGS)


# --- spctl, xcrun ---------------------------------------------------------------------

def spctl():
    app = ARGS[-1]
    sig = signature(app)
    ticket = os.path.join(app, "Contents", "CodeResources")
    stapled = os.path.exists(ticket) and json.load(open(ticket)).get("ticket") == (sig or {}).get("cdhash")
    # Gatekeeper asks Apple online for the ticket of a notarized bundle that has none stapled.
    online = CFG.get("notary_status", "Accepted") == "Accepted" and any(
        s_["cdhash"] == (sig or {}).get("cdhash") for s_ in load("submissions", {}).values())
    if CFG.get("spctl") == "rejected" or not sig or not sig["apple"] or not (stapled or online) or seal(app) != sig["seal"]:
        source = "no usable signature" if not sig or sig["identity"] == "-" else "Unnotarized Developer ID"
        print("%s: rejected\nsource=%s" % (app, source), file=sys.stderr)
        sys.exit(3)
    print("%s: accepted\nsource=Notarized Developer ID\norigin=%s" % (app, sig["subject"]), file=sys.stderr)


def notarytool():
    sub = ARGS[1]
    if sub == "store-credentials":
        mode = CFG.get("notary_auth", "ok")
        print("This process stores your credentials securely in the Keychain.\nValidating your credentials...")
        answers = {
            "ok": None,
            "401": "Error: HTTP status code: 401. Unable to authenticate. Invalid authentication (Unauthorized). Ensure that all authentication arguments are correct.",
            "agreement": "Error: HTTP status code: 403. A required agreement is missing or has expired. This request requires an in-effect agreement that has not been signed or has expired.",
            "403": "Error: HTTP status code: 403. Forbidden: the key's role is not authorized for this resource.",
            "offline": "Error: The Internet connection appears to be offline.",
            "weird": "Error: something unprecedented.",
        }
        if answers[mode]:
            print(answers[mode])
            sys.exit(1)
        print("Success. Credentials validated.\nCredentials saved to Keychain.")
        return
    if sub == "submit":
        if CFG.get("submit") == "fail":
            print("Error: HTTP status code: 500. The service is temporarily unavailable.")
            sys.exit(1)
        z = zipfile.ZipFile(ARGS[2])
        names = [n for n in z.namelist() if n.endswith("Contents/_CodeSignature/CodeResources")]
        cdhash = json.loads(z.read(names[0]))["cdhash"] if names else None
        sid = str(uuid.UUID(int=0x1234))
        subs = load("submissions", {})
        subs[sid] = {"cdhash": cdhash, "polls": 0}
        save("submissions", subs)
        print(json.dumps({"id": sid, "message": "Successfully uploaded file", "path": ARGS[2]}))
        return
    if sub in ("wait", "info"):
        sid = ARGS[2]
        subs = load("submissions", {})
        if sid not in subs:
            print(json.dumps({"id": sid, "message": "Submission not found"}))
            sys.exit(1)
        subs[sid]["polls"] += 1
        save("submissions", subs)
        status = CFG.get("notary_status", "Accepted")
        print(json.dumps({"id": sid, "status": status, "message": "Processing complete" if status != "In Progress" else "In progress"}))
        if sub == "wait" and status == "In Progress":
            sys.exit(1)
        return
    if sub == "log":
        sid = ARGS[2]
        subs = load("submissions", {})
        status = CFG.get("notary_status", "Accepted")
        cdhash = CFG.get("ticket_cdhash", subs.get(sid, {}).get("cdhash"))
        issues = CFG.get("issues")
        # (ticket_always: a log with ticket contents whatever its status -- no real log has one for a
        # rejected submission; the tests use it so the status checks alone stand between it and a release)
        entry = {"jobId": sid, "status": status, "issues": issues,
                 "ticketContents": [{"path": "submission.zip/Icy Tower.app", "digestAlgorithm": "SHA-256", "cdhash": cdhash,
                                     "arch": "arm64"}] if status == "Accepted" or CFG.get("ticket_always") else None}
        with open(ARGS[-1], "w") as f:
            json.dump(entry, f)
        return
    die("notarytool stub: unknown use %s" % ARGS)


def stapler():
    sub, app = ARGS[1], ARGS[-1]
    sig = signature(app) or {}
    ticket = os.path.join(app, "Contents", "CodeResources")
    if sub == "staple":
        if CFG.get("staple_fatal"):
            die("Processing: %s\nThe signature of the binary is invalid.\nThe staple and validate action failed! Error 65." % app, 65)
        tries = load("staple_tries", 0) + 1
        save("staple_tries", tries)
        if tries <= CFG.get("staple_transient", 0):
            die("Processing: %s\nCloudKit query for Icy Tower.app (2/%s) failed due to \"Record not found\".\n"
                "Could not find base64 encoded ticket in response for 2/%s\nThe staple and validate action failed! Error 65."
                % (app, sig.get("cdhash"), sig.get("cdhash")), 65)
        subs = load("submissions", {})
        if not any(s["cdhash"] == sig.get("cdhash") for s in subs.values()) or CFG.get("notary_status", "Accepted") != "Accepted":
            die("Could not find base64 encoded ticket in response for %s\nThe staple and validate action failed! Error 65." % app, 65)
        with open(ticket, "w") as f:
            json.dump({"ticket": sig.get("cdhash")}, f)
        print("Processing: %s\nThe staple and validate action worked!" % app)
        return
    if sub == "validate":
        if os.path.exists(ticket) and json.load(open(ticket)).get("ticket") == sig.get("cdhash"):
            print("Processing: %s\nThe validate action worked!" % app)
            return
        die("Processing: %s\n%s does not have a ticket stapled to it." % (app, app), 65)
    die("stapler stub: unknown use %s" % ARGS)


def xcrun():
    if ARGS[0] == "notarytool":
        return notarytool()
    if ARGS[0] == "stapler":
        return stapler()
    die("xcrun stub: unknown use %s" % ARGS)


# --- ditto, unzip, xattr ------------------------------------------------------------------

def ditto():
    if ARGS[:2] == ["-c", "-k"]:
        src, dst = ARGS[-2], ARGS[-1]
        parent = os.path.dirname(os.path.abspath(src)) if "--keepParent" in ARGS else os.path.abspath(src)
        with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as z:
            for dirpath, dirnames, filenames in os.walk(src):
                dirnames.sort()
                for n in sorted(filenames):
                    p = os.path.join(dirpath, n)
                    info = zipfile.ZipInfo(os.path.relpath(p, parent))
                    mode = os.stat(p).st_mode & 0o777
                    if CFG.get("drop_modes"):
                        mode = 0o644
                    info.external_attr = (stat.S_IFREG | mode) << 16
                    with open(p, "rb") as f:
                        z.writestr(info, f.read())
        return
    if ARGS[:2] == ["-x", "-k"]:
        src, dst = ARGS[-2], ARGS[-1]
        with zipfile.ZipFile(src) as z:
            for info in z.infolist():
                out = os.path.join(dst, info.filename)
                os.makedirs(os.path.dirname(out), exist_ok=True)
                with open(out, "wb") as f:
                    f.write(z.read(info))
                os.chmod(out, (info.external_attr >> 16) & 0o777)
        return
    src, dst = ARGS[-2], ARGS[-1]
    shutil.copytree(src, dst, symlinks=True)


def unzip():
    with zipfile.ZipFile(ARGS[-1]) as z:
        bad = z.testzip()
    if bad:
        die("unzip: %s is damaged" % bad)


{"codesign": codesign, "security": security, "spctl": spctl, "xcrun": xcrun, "ditto": ditto, "unzip": unzip,
 "xattr": lambda: None}[TOOL]()

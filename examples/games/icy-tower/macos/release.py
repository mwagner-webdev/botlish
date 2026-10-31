#!/usr/bin/env python3
"""release.py -- Icy Tower.app's trust paths: signing, notarization,
stapling, Gatekeeper and the release artifact (ICY-TOWER-MACOS-APP-
MILESTONE-1.md, "Release pipeline").

    python3 -I release.py STAGE --work DIR [options]

The release is a sequence of stages, each one command, each recording what
it established in DIR/state.json (public facts only) and each refusing to
run unless the stages it depends on succeeded -- so a later stage can never
act on an artifact an earlier one refused, and `publishable` can tell a
release whose every stage passed from anything else:

    preflight        the credentials (credentials.py), locally; decoded into
                     DIR/secret/ (owner-only)
    keychain         a temporary keychain with a generated password: the
                     .p12 and its Apple intermediate imported, codesign's
                     access granted, exactly one valid code-signing identity
                     in it, the one whose SHA-1 the preflight computed
    notary-auth      notarytool store-credentials (Apple's own validation of
                     the Key ID, Issuer ID and .p8 together) into a profile
                     of that keychain; failures classified
    sign             codesign the bundle (ad hoc, dry-run, developer-id)
    verify-signature the signature as the mode requires it (codesign
                     --verify --deep --strict, its authority chain, team,
                     identifier, hardened runtime, secure timestamp, no
                     entitlement)
    record           a graphical acceptance's results (macos-session.py
                     results.json) for the bundle as it is now
    notarize         the submission (ditto ZIP, notarytool submit, its ID
                     recorded at once, wait, info, log), Accepted required,
                     the log's issues inspected, its ticket's cdhash the
                     bundle's; --resume ID continues an earlier submission
    staple           stapler staple (bounded retries while Apple publishes
                     the ticket) and stapler validate
    gatekeeper       spctl's assessment (notarized: accepted, "Notarized
                     Developer ID", the team; ad hoc: rejected)
    tamper           a private copy with one byte changed must fail
                     verification; the original must still pass
    package          the final ZIP, made after stapling, extracted again
                     into a fresh directory and verified there; SHA256SUMS;
                     provenance.json
    publishable      whether DIR's release may be published: every stage
                     of the mode's sequence passed, on the same signature,
                     the ZIP's digest the one verified and launched
    cleanup          the temporary keychain deleted, the keychain search
                     list restored, the decoded credentials removed

Modes: `adhoc` (ordinary CI: no credentials, an ad hoc signature with the
hardened runtime), `dry-run` (ordinary CI: a throwaway self-signed identity
through the very keychain and codesign steps a release takes -- no Apple
trust, no timestamp, no notarization, never publishable) and `release`
(the Developer ID path). A release never falls back to another mode: each
stage reads the mode DIR was made with, and a release's sign stage signs
with the keychain identity or not at all.

Apple's tools are found on PATH (codesign, security, spctl, ditto, xattr,
xcrun), never by absolute path, so audit/macos-release/'s tests run the
stages against recording stubs. Diagnostics use the release's stable codes;
nothing secret is printed (every tool's output passes the redaction of the
run's secret values first, and a command line holding one is printed with
it masked).
"""
import datetime
import hashlib
import json
import os
import plistlib
import re
import secrets as pysecrets
import shutil
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import bundle  # noqa: E402
import credentials  # noqa: E402

ZIP = "icy-tower-macos-aarch64.zip"
SUMS = "SHA256SUMS"
PROVENANCE = "provenance.json"
PROFILE = "icy-tower-notary"
STAPLE_TRIES = 6
# What stapler says while Apple's ticket for an Accepted submission is not
# published yet (or the network failed); anything else -- an invalid
# signature, a bundle that is not signed -- is never retried. (stapler ends
# every failure with "Error 65": that word alone means nothing.)
TRANSIENT_STAPLE = re.compile(r"Record not found|Could not find base64 encoded ticket|CloudKit query.*failed|"
                              r"timed out|network connection|offline", re.I)
DRY_RUN_TEAM = "DRYRUN0000"
# Every wait of the release (stapling's backoff, notarization's polling) is
# scaled by this; audit/macos-release/'s tests make it small.
WAIT = float(os.environ.get("ICY_TOWER_RELEASE_WAIT_SCALE", "1"))

# The stages each mode must pass, in order, for its result to be published.
SEQUENCE = {
    "release": ["preflight", "identity", "keychain", "notary-auth", "sign", "verify-signature", "record:hardened-runtime",
                "notarize", "staple", "verify-signature:stapled", "gatekeeper", "tamper", "package", "record:final-artifact"],
}


class Failed(Exception):
    def __init__(self, code, text, remedy=""):
        super().__init__("%s: %s" % (code, text))
        self.code, self.text, self.remedy = code, text, remedy


# ---------------------------------------------------------------------------
# The work directory

class Work:
    def __init__(self, path, create_mode=None):
        self.path = os.path.abspath(path)
        self.state_file = os.path.join(self.path, "state.json")
        self.secret = os.path.join(self.path, "secret")
        if create_mode:
            os.makedirs(self.path, exist_ok=True)
            if os.path.exists(self.state_file):
                with open(self.state_file) as f:
                    old = json.load(f)
                if old.get("mode") != create_mode:
                    raise Failed("MACOS-CONFIG-MISSING", "%s was made for mode %s, not %s: use a fresh work directory"
                                 % (self.path, old.get("mode"), create_mode))
            else:
                self.state = {"mode": create_mode, "stages": []}
                self.save()
        if not os.path.exists(self.state_file):
            raise Failed("MACOS-CONFIG-MISSING", "%s holds no release state: run a first stage with --mode" % self.path)
        with open(self.state_file) as f:
            self.state = json.load(f)

    @property
    def mode(self):
        return self.state["mode"]

    def save(self):
        tmp = self.state_file + ".new"
        with open(tmp, "w") as f:
            json.dump(self.state, f, indent=1, sort_keys=True)
        os.replace(tmp, self.state_file)

    def passed(self, name):
        return [s for s in self.state["stages"] if s["stage"] == name and s["ok"]]

    def last(self, name):
        p = self.passed(name)
        return p[-1] if p else None

    def require(self, *names, code="MACOS-SIGN"):
        for n in names:
            if not self.passed(n):
                raise Failed(code, "stage %s has not passed: refusing to go on (the stages run in order, each on what "
                             "the ones before it established)" % n)

    def add(self, name, ok, facts):
        self.state["stages"].append(dict(facts, stage=name, ok=ok, at=datetime.datetime.now(datetime.timezone.utc).isoformat()))
        self.save()


# ---------------------------------------------------------------------------
# Tools

SECRET_VALUES = []


def redact(text):
    for v in SECRET_VALUES:
        if v and len(v) >= 4:
            text = text.replace(v, "[REDACTED]")
    text = re.sub(r"-----BEGIN ([A-Z ]*PRIVATE KEY)-----.*?-----END \1-----", "[REDACTED PRIVATE KEY]", text, flags=re.S)
    return text


def shown(cmd):
    return " ".join("[REDACTED]" if any(v and v in w for v in SECRET_VALUES) else (w if re.fullmatch(r"[\w@%+=:,./-]+", w) else repr(w))
                    for w in cmd)


def run(cmd, check=True, timeout=None, quiet=False, env=None):
    """CMD's (status, stdout, stderr), both redacted; printed (masked) unless QUIET."""
    if not quiet:
        print("$ " + shown(cmd), flush=True)
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout, env=env, stdin=subprocess.DEVNULL)
    except FileNotFoundError:
        raise Failed("MACOS-SIGN", "%s is not installed (Xcode's command-line tools are needed)" % cmd[0])
    out, err = redact(r.stdout), redact(r.stderr)
    if check and r.returncode != 0:
        raise ToolFailed(cmd, r.returncode, out, err)
    return r.returncode, out, err


class ToolFailed(Exception):
    def __init__(self, cmd, status, out, err):
        super().__init__("%s exited %d" % (cmd[0], status))
        self.cmd, self.status, self.out, self.err = cmd, status, out, err

    def text(self):
        return (self.out + self.err).strip()


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


# ---------------------------------------------------------------------------
# preflight

def stage_preflight(work, args):
    anchors = args.trust_anchors
    if work.mode == "release" and anchors:
        raise Failed("MACOS-CERTIFICATE-IDENTITY", "a release takes Apple's own certificate authorities: --trust-anchors "
                     "(test fixtures) is refused in release mode")
    if work.mode == "adhoc":
        raise Failed("MACOS-CONFIG-MISSING", "an ad hoc signature needs no credentials: preflight is for dry-run and release")
    problems, facts = credentials.check(dict(os.environ), work.secret, anchors)
    if problems:
        work.add("preflight", False, {"codes": sorted({p.code for p in problems})})
        print("The macOS release's configuration has %d problem(s); nothing was signed or sent to Apple:" % len(problems))
        for p in problems:
            print(p.render())
        raise Failed(problems[0].code, "the credential preflight failed (above)")
    if work.mode == "release" and facts["anchors"] != "apple":
        raise Failed("MACOS-CERTIFICATE-IDENTITY", "the identity was checked against test trust anchors: no release")
    i = facts["identity"]
    print("preflight: %s, SHA-1 %s, issued by %s, team %s; notary key %s (issuer %s); bundle %s"
          % (i["subject"], i["sha1"], i["issuer"], i["team"], facts["notary"]["key_id"], facts["notary"]["issuer_id"],
             facts["bundle_id"]))
    work.add("preflight", True, {"identity": i, "anchors": facts["anchors"], "team": facts["team"],
                                 "bundle_id": facts["bundle_id"], "notary": facts["notary"],
                                 "anchors_dir": os.path.abspath(anchors) if anchors else None})


# ---------------------------------------------------------------------------
# keychain

def keychains_now():
    _, out, _ = run(["security", "list-keychains", "-d", "user"], quiet=True)
    return [line.strip().strip('"') for line in out.splitlines() if line.strip()]


def identities(keychain, valid):
    cmd = ["security", "find-identity"] + (["-v"] if valid else []) + ["-p", "codesigning", keychain]
    _, out, _ = run(cmd, quiet=True)
    found = re.findall(r"^\s*\d+\)\s+([0-9A-F]{40})\s+\"(.*?)\"(.*)$", out, re.M)
    return found, out


def apple_root_matches():
    """The system's Apple Root CA has the committed root's SHA-256 (a second, independent source for it)."""
    code, out, err = run(["security", "find-certificate", "-a", "-c", "Apple Root CA", "-Z",
                          "/System/Library/Keychains/SystemRootCertificates.keychain"], check=False, quiet=True)
    hashes = [h.lower() for h in re.findall(r"SHA-256 hash:\s*([0-9A-Fa-f]{64})", out)]
    return credentials.APPLE_CA[credentials.APPLE_ROOT] in hashes


def stage_keychain(work, args):
    work.require("preflight")
    pre = work.last("preflight")
    if work.mode == "release" and not apple_root_matches():
        raise Failed("MACOS-CERTIFICATE-IDENTITY", "the system's Apple Root CA is not the committed apple-ca/ root: refusing to trust either")
    password = pysecrets.token_urlsafe(32)
    SECRET_VALUES.append(password)
    p12_password = os.environ.get("MACOS_CERTIFICATE_PASSWORD", "")
    SECRET_VALUES.append(p12_password)
    keychain = os.path.join(work.secret, "icy-tower-signing.keychain-db")
    with open(os.path.join(work.secret, "keychain-password"), "w") as f:
        os.chmod(f.name, 0o600)
        f.write(password)
    original = keychains_now()
    with open(os.path.join(work.path, "keychains-before.json"), "w") as f:
        json.dump(original, f)
    if os.path.exists(keychain):
        run(["security", "delete-keychain", keychain], check=False)
    run(["security", "create-keychain", "-p", password, keychain])
    run(["security", "set-keychain-settings", "-lut", "21600", keychain])
    run(["security", "unlock-keychain", "-p", password, keychain])
    try:
        run(["security", "import", os.path.join(work.secret, "identity.p12"), "-k", keychain, "-P", p12_password,
             "-f", "pkcs12", "-T", "/usr/bin/codesign", "-T", "/usr/bin/security"])
    except ToolFailed as t:
        raise Failed("MACOS-CERTIFICATE-DECRYPT", "security could not import the .p12 the preflight decrypted: %s"
                     % " / ".join(t.text().splitlines()[-3:]), "Export the identity again (%s)" % credentials.EXPORT_HINT)
    # The issuer beside the identity, so codesign can build the chain: Apple's
    # Developer ID intermediate (its root is the system's), or a dry run's
    # test authority (root and intermediate: trusted by nothing).
    intermediate = pre["identity"].get("intermediate")
    if pre["anchors"] == "apple" and intermediate:
        chain = [os.path.join(HERE, "apple-ca", intermediate)]
    elif pre.get("anchors_dir"):
        chain = [os.path.join(pre["anchors_dir"], n) for n in sorted(os.listdir(pre["anchors_dir"]))]
    else:
        chain = []
    for cert in chain:
        run(["security", "import", cert, "-k", keychain, "-t", "cert", "-f", "x509"], check=False)
    run(["security", "set-key-partition-list", "-S", "apple-tool:,apple:,codesign:", "-s", "-k", password, keychain], quiet=False)
    run(["security", "list-keychains", "-d", "user", "-s", keychain] + original)
    want = pre["identity"]["sha1"]
    every, listing = identities(keychain, valid=False)
    valid, vlisting = identities(keychain, valid=True)
    print(redact(vlisting).strip())
    hashes = [h for h, _, _ in every]
    if len(set(hashes)) != 1:
        raise Failed("MACOS-CERTIFICATE-IDENTITY", "the temporary keychain holds %d code-signing identities (%s), not "
                     "exactly the one the preflight checked: refusing to choose one" % (len(set(hashes)),
                     ", ".join('"%s"' % n for _, n, _ in every) or "none"),
                     "Export only the Developer ID Application identity into the .p12")
    if hashes[0] != want:
        raise Failed("MACOS-CERTIFICATE-IDENTITY", "the keychain's identity has SHA-1 %s, not the preflight's %s" % (hashes[0], want))
    if work.mode == "release":
        if [h for h, _, _ in valid] != [want]:
            reason = (re.findall(r"\((CSSMERR_\w+|[^)]*)\)", listing) or ["not valid"])[0]
            raise Failed("MACOS-CERTIFICATE-IDENTITY", "the imported identity is not a valid code-signing identity for "
                         "macOS (%s): its private key may be unusable or its chain untrusted" % reason,
                         "Export the identity again with its private key; check that the certificate is not revoked")
    work.add("keychain", True, {"keychain": keychain, "identity": want, "valid": bool(valid), "before": original})
    print("keychain: %s holds exactly the identity %s (%s)" % (keychain, want, pre["identity"]["subject"]))


# ---------------------------------------------------------------------------
# notary-auth

AUTH_CLASSES = (
    ("MACOS-NOTARY-ACCOUNT", re.compile(r"agreement|has not been signed|expired.*agreement|account.*(locked|disabled|not.*active)|"
                                        r"Team is not (yet )?configured|programs? membership", re.I),
     "Apple accepted the key but the developer account cannot notarize: a required agreement is missing or expired, "
     "or the membership is not active", "Sign the pending agreements at developer.apple.com (Account) as the Account "
     "Holder, then retry"),
    ("MACOS-NOTARY-PERMISSION", re.compile(r"HTTP status code: 403|forbidden|not authorized|insufficient|permission", re.I),
     "Apple authenticated the key, but it lacks the permission to notarize",
     "Use a team API key whose access is Developer (or higher) in App Store Connect, Users and Access, Integrations"),
    ("MACOS-NOTARY-AUTH", re.compile(r"HTTP status code: 401|Unable to authenticate|Invalid credentials|Unauthorized|"
                                     r"authentication|NOT_AUTHORIZED|invalid.*key", re.I),
     "The key is structurally valid, but Apple's notarization service rejected the configured Key ID / Issuer ID / "
     "private-key combination",
     "Verify that all three come from the same App Store Connect team API key (the Issuer ID above the team keys, the "
     "key's Key ID, its AuthKey_<KEY_ID>.p8) and that the key is not revoked"),
    ("MACOS-NOTARY-SERVICE", re.compile(r"offline|could not connect|connection|timed out|hostname could not be found|"
                                        r"NSURLErrorDomain|HTTP status code: 5\d\d|service unavailable|temporarily|"
                                        r"network|DNS|resolve", re.I),
     "Apple's notarization service could not be reached or answered with a server error: not a credential problem",
     "Retry later; https://developer.apple.com/system-status/ shows the service's state"),
)


def classify_notary(text):
    """(code, explanation, remedy) of a failed notarytool command's output."""
    for code, pattern, why, remedy in AUTH_CLASSES:
        if pattern.search(text):
            return code, why, remedy
    return "MACOS-NOTARY-TOOL", "notarytool failed in a way this release does not recognize", \
        "Read notarytool's own output (above); it is kept, redacted, in the diagnostics"


def notary_args(work):
    k = work.last("keychain")
    return ["--keychain-profile", PROFILE, "--keychain", k["keychain"]]


def stage_notary_auth(work, args):
    work.require("preflight", "keychain")
    pre = work.last("preflight")
    key = os.path.join(work.secret, "notary-key.p8")
    k = work.last("keychain")
    cmd = ["xcrun", "notarytool", "store-credentials", PROFILE, "--key", key, "--key-id", pre["notary"]["key_id"],
           "--issuer", pre["notary"]["issuer_id"], "--keychain", k["keychain"]]
    code, out, err = run(cmd, check=False, timeout=300)
    text = (out + err).strip()
    with open(os.path.join(work.path, "notary-auth.log"), "w") as f:
        f.write(text + "\n")
    if code != 0 or not re.search(r"validated|Success", text, re.I):
        cls, why, remedy = classify_notary(text)
        print(text)
        work.add("notary-auth", False, {"code": cls})
        raise Failed(cls, why, remedy)
    work.add("notary-auth", True, {"profile": PROFILE})
    print("notary-auth: Apple validated the Key ID, the Issuer ID and the key together (profile %s of the temporary keychain)" % PROFILE)


# ---------------------------------------------------------------------------
# sign and verify

def signature_facts(app):
    _, out, err = run(["codesign", "-dvvv", app], quiet=True)
    text = out + err
    facts = {"authority": re.findall(r"^Authority=(.*)$", text, re.M)}
    for key in ("Identifier", "Format", "TeamIdentifier", "Timestamp", "Signature", "CDHash", "Runtime Version", "Signed Time"):
        m = re.search(r"^%s=(.*)$" % re.escape(key), text, re.M)
        facts[key] = m.group(1).strip() if m else None
    m = re.search(r"^CodeDirectory .*flags=(0x[0-9a-f]+)\(([^)]*)\)", text, re.M)
    facts["flags"] = (m.group(2).split(",") if m else [])
    facts["flags_value"] = int(m.group(1), 16) if m else 0
    return facts


def entitlements(app):
    _, out, _ = run(["codesign", "-d", "--entitlements", "-", "--xml", app], quiet=True)
    body = out.strip()
    if not body:
        return {}
    start = body.find("<?xml")
    if start < 0:
        start = body.find("<plist")
    try:
        return plistlib.loads(body[start:].encode()) if start >= 0 else {}
    except Exception:
        raise Failed("MACOS-SIGN", "the signature's entitlements do not parse")


def stage_sign(work, args):
    app = os.path.abspath(args.app)
    bundle.check_bundle(app)
    mode = work.mode
    if mode == "adhoc":
        identity, keychain_args, timestamp = "-", [], "--timestamp=none"
    else:
        work.require("preflight", "keychain")
        k = work.last("keychain")
        identity, keychain_args = k["identity"], ["--keychain", k["keychain"]]
        # Apple's timestamp service stamps only signatures that chain to Apple:
        # the dry run's throwaway identity has none.
        timestamp = "--timestamp" if mode == "release" else "--timestamp=none"
        if mode == "release":
            work.require("notary-auth")
    run(["xattr", "-cr", app], check=False)
    try:
        run(["codesign", "--force", "--sign", identity] + keychain_args + ["--options", "runtime", timestamp, app], timeout=600)
    except ToolFailed as t:
        raise Failed("MACOS-SIGN", "codesign could not sign the bundle: %s" % t.text(),
                     "errSecInternalComponent: the keychain is locked or codesign has no access to the key; "
                     "a timestamp failure: Apple's timestamp service was unreachable (retry)")
    f = signature_facts(app)
    work.add("sign", True, {"mode": mode, "cdhash": f["CDHash"], "identity": identity})
    print("sign (%s): %s, CDHash %s" % (mode, f["authority"][0] if f["authority"] else "ad hoc", f["CDHash"]))


def check_signature(app, mode, team=None, bundle_id=None, dry_subject=None):
    """The bundle's signature as MODE requires it; its facts."""
    try:
        run(["codesign", "--verify", "--deep", "--strict", "--verbose=2", app], quiet=True)
        run(["codesign", "--verify", "--strict", "--verbose=2", os.path.join(app, "Contents", "MacOS", bundle.EXECUTABLE)], quiet=True)
    except ToolFailed as t:
        raise Failed("MACOS-SIGN", "the bundle's signature does not verify: %s" % t.text())
    f = signature_facts(app)
    d = bundle.check_bundle(app)
    problems = []
    if f["Identifier"] != (bundle_id or d["CFBundleIdentifier"]):
        problems.append("its identifier is %s, not the bundle's %s" % (f["Identifier"], bundle_id or d["CFBundleIdentifier"]))
    if "runtime" not in f["flags"]:
        problems.append("the hardened runtime is not enabled (flags %s)" % (",".join(f["flags"]) or "none"))
    if f["Format"] and "arm64" not in f["Format"]:
        problems.append("its format is %s" % f["Format"])
    ents = entitlements(app)
    if ents:
        problems.append("it carries entitlements (%s): the game needs none" % ", ".join(sorted(ents)))
    if mode == "adhoc":
        if f["Signature"] != "adhoc":
            problems.append("it is not an ad hoc signature (Signature=%s)" % f["Signature"])
    else:
        if f["Signature"] == "adhoc" or not f["authority"]:
            problems.append("it is an ad hoc signature, not the %s identity's: no fallback is allowed" % mode)
        if mode == "release":
            want = ["Developer ID Certification Authority", "Apple Root CA"]
            if len(f["authority"]) != 3 or not f["authority"][0].startswith("Developer ID Application: ") or f["authority"][1:] != want:
                problems.append("its authority chain is %s, not Developer ID Application, Developer ID Certification "
                                "Authority, Apple Root CA" % (f["authority"] or "empty"))
            if team and f["TeamIdentifier"] != team:
                problems.append("its team is %s, not APPLE_TEAM_ID %s" % (f["TeamIdentifier"], team))
            if not f["Timestamp"]:
                problems.append("it has no secure timestamp (notarization requires one)")
        elif mode == "dry-run":
            if dry_subject and f["authority"][:1] != [dry_subject]:
                problems.append("its authority is %s, not the dry run's identity %s" % (f["authority"], dry_subject))
    if problems:
        raise Failed("MACOS-SIGN", "the bundle's signature is not a %s signature: %s" % (mode, "; ".join(problems)))
    return f


def stage_verify(work, args):
    app = os.path.abspath(args.app)
    mode = work.mode
    team = bundle_id = subject = None
    if mode != "adhoc":
        pre = work.last("preflight")
        team, bundle_id, subject = pre["team"], pre["bundle_id"], pre["identity"]["subject"]
    work.require("sign")
    f = check_signature(app, mode, team, bundle_id, subject)
    signed = work.last("sign")["cdhash"]
    stapled = args.label == "stapled"
    if f["CDHash"] != signed:
        raise Failed("MACOS-SIGN", "the bundle's CDHash is %s, not the one sign made (%s): it was changed or signed again"
                     % (f["CDHash"], signed))
    name = "verify-signature" + (":" + args.label if args.label else "")
    work.add(name, True, {"cdhash": f["CDHash"], "authority": f["authority"], "team": f["TeamIdentifier"],
                          "timestamp": f["Timestamp"], "flags": f["flags"], "identifier": f["Identifier"]})
    print("verify-signature%s: %s; %s; team %s; identifier %s; flags %s; %s" % (
        " (" + args.label + ")" if args.label else "", "valid (codesign --verify --deep --strict)",
        " < ".join(f["authority"]) or "ad hoc", f["TeamIdentifier"], f["Identifier"], ",".join(f["flags"]),
        ("timestamp " + f["Timestamp"]) if f["Timestamp"] else "no timestamp") + ("; stapled" if stapled else ""))


def stage_adopt(work, args):
    """A bundle signed by an earlier run of this release (its notarization to be resumed, never uploaded
    again): its signature must be this release's -- Developer ID, the team, the identifier -- and becomes
    this run's sign stage."""
    if work.mode != "release" or not args.resume:
        raise Failed("MACOS-NOTARIZE", "adopt continues a release's submission: --resume SUBMISSION_ID is required")
    work.require("preflight", "keychain", "notary-auth")
    app = os.path.abspath(args.app)
    pre = work.last("preflight")
    f = check_signature(app, "release", pre["team"], pre["bundle_id"])
    work.add("sign", True, {"mode": "release", "cdhash": f["CDHash"], "identity": "adopted", "resume": args.resume})
    print("adopt: the bundle signed by %s (CDHash %s) continues submission %s" % (f["authority"][0], f["CDHash"], args.resume))


def stage_identity(work, args):
    """The bundle identifier is the application's identity: never a different one from an earlier release's."""
    work.require("preflight", code="MACOS-BUNDLE-METADATA")
    mine = work.last("preflight")["bundle_id"]
    seen = []
    for path in args.previous or []:
        if not os.path.exists(path):
            continue
        with open(path) as f:
            p = json.load(f)
        seen.append((path, p.get("bundle_id"), p.get("version")))
    for path, other, version in seen:
        if other and other != mine:
            raise Failed("MACOS-BUNDLE-METADATA", "MACOS_BUNDLE_ID is %s, but the release %s was %s: a release never "
                         "changes the application's identity" % (mine, version, other),
                         "Set MACOS_BUNDLE_ID back to %s (a new identifier is a new application for macOS)" % other)
    work.add("identity", True, {"bundle_id": mine, "previous": [s_[2] for s_ in seen]})
    print("identity: %s%s" % (mine, ", as every earlier release's (%s)" % ", ".join(v for _, _, v in seen) if seen else
                               ", the first release"))


def current_cdhash(app):
    return signature_facts(app)["CDHash"]


def sealed(app, code):
    """CODE's failure unless the bundle's signature still verifies: the CDHash codesign -d prints is the one the
    signature holds, whatever happened to the files since, so every stage that acts on a signed bundle verifies it."""
    try:
        run(["codesign", "--verify", "--deep", "--strict", "--verbose=2", app], quiet=True)
    except ToolFailed as t:
        raise Failed(code, "the bundle's signature does not verify (it was changed after signing): %s" % t.text()[-300:])
    return current_cdhash(app)


def stage_record(work, args):
    """A graphical acceptance's RESULTS for what it ran: the bundle (its CDHash) or the final ZIP (its digest)."""
    with open(args.results) as f:
        cases = json.load(f)
    wanted = [c for c in args.cases.split(",") if c] if args.cases else None
    got = {c["name"]: c["class"] for c in cases}
    missing = [c for c in (wanted or []) if c not in got]
    failed = sorted(n for n, cls in got.items() if cls != "EXECUTED" and (wanted is None or n in wanted))
    facts = {"cases": got}
    if args.app:
        facts["cdhash"] = sealed(os.path.abspath(args.app), "MACOS-LAUNCH")
    if args.zip:
        facts["zip_sha256"] = sha256(args.zip)
    ok = not missing and not failed and bool(got)
    work.add("record:" + args.label, ok, facts)
    if not ok:
        raise Failed("MACOS-LAUNCH", "the %s acceptance did not pass: %s" % (
            args.label, "; ".join(["%s %s" % (n, got[n]) for n in failed] + ["%s did not run" % m for m in missing])))
    print("record %s: %d case(s) EXECUTED: %s" % (args.label, len(got), ", ".join(sorted(got))))


# ---------------------------------------------------------------------------
# notarize

def notary_json(cmd, timeout):
    code, out, err = run(cmd + ["--output-format", "json"], check=False, timeout=timeout)
    data = None
    for line in reversed(out.strip().splitlines()):
        try:
            data = json.loads(line)
            break
        except ValueError:
            continue
    if data is None:
        try:
            data = json.loads(out)
        except ValueError:
            data = None
    return code, data, (out + err).strip()


def stage_notarize(work, args):
    work.require("verify-signature", "record:hardened-runtime", code="MACOS-NOTARIZE")
    if work.mode != "release":
        raise Failed("MACOS-NOTARIZE", "only a release is notarized (mode %s)" % work.mode)
    app = os.path.abspath(args.app)
    cdhash = sealed(app, "MACOS-NOTARIZE")
    if cdhash != work.last("sign")["cdhash"] or cdhash != work.last("record:hardened-runtime").get("cdhash"):
        raise Failed("MACOS-NOTARIZE", "the bundle is not the one signed and accepted (CDHash %s)" % cdhash)
    auth = notary_args(work)
    record = os.path.join(work.path, "notary-submission.json")
    if args.resume:
        if not credentials.UUID.fullmatch(args.resume):
            raise Failed("MACOS-NOTARIZE", "--resume %r is no submission ID (a UUID)" % args.resume)
        sid = args.resume
        print("notarize: resuming submission %s (no new upload)" % sid)
    else:
        submission = os.path.join(work.path, "submission.zip")
        if os.path.exists(submission):
            os.unlink(submission)
        run(["ditto", "-c", "-k", "--keepParent", app, submission])
        run(["unzip", "-tq", submission])
        code, data, text = notary_json(["xcrun", "notarytool", "submit", submission] + auth, timeout=3600)
        sid = (data or {}).get("id")
        if code != 0 or not sid or not credentials.UUID.fullmatch(sid):
            cls, why, remedy = classify_notary(text)
            if cls == "MACOS-NOTARY-TOOL":
                cls, why = "MACOS-NOTARIZE", "the submission did not return a submission ID: %s" % text[-400:]
            work.add("notarize", False, {"code": cls})
            raise Failed(cls, why, remedy)
    with open(record, "w") as f:
        json.dump({"id": sid, "cdhash": cdhash, "submitted": datetime.datetime.now(datetime.timezone.utc).isoformat()}, f)
    print("notarize: submission ID %s (recorded in %s)" % (sid, record), flush=True)
    deadline = time.time() + args.timeout
    status, info = None, None
    while time.time() < deadline:
        remaining = max(60, int(deadline - time.time()))
        code, data, text = notary_json(["xcrun", "notarytool", "wait", sid] + auth + ["--timeout", "%dm" % max(1, min(60, remaining // 60))],
                                       timeout=remaining + 120)
        code, info, text = notary_json(["xcrun", "notarytool", "info", sid] + auth, timeout=300)
        status = (info or {}).get("status")
        if status in ("Accepted", "Invalid", "Rejected"):
            break
        if code != 0 and info is None:
            cls, why, remedy = classify_notary(text)
            if cls in ("MACOS-NOTARY-AUTH", "MACOS-NOTARY-PERMISSION", "MACOS-NOTARY-ACCOUNT"):
                raise Failed(cls, why, remedy)
        print("notarize: %s is %s" % (sid, status or "not answering"), flush=True)
        time.sleep(30 * WAIT)
    if status not in ("Accepted", "Invalid", "Rejected"):
        work.add("notarize", False, {"id": sid, "status": status, "code": "timeout"})
        raise Failed("MACOS-NOTARIZE", "submission %s has no final status after %d s (last: %s). A timeout is not a "
                     "rejection: the submission may still be accepted." % (sid, args.timeout, status),
                     "Resume it instead of uploading again: rerun with --resume %s (the workflow's resume_submission "
                     "input), or check it with xcrun notarytool info %s" % (sid, sid))
    log = os.path.join(work.path, "notary-log.json")
    code, _, text = run(["xcrun", "notarytool", "log", sid] + auth + [log], check=False, timeout=600)
    entry = {}
    if code == 0 and os.path.exists(log):
        with open(log) as f:
            entry = json.load(f)
    issues = entry.get("issues") or []
    errors = [i for i in issues if (i.get("severity") or "").lower() == "error"]
    warnings = [i for i in issues if (i.get("severity") or "").lower() != "error"]
    for i in issues:
        print("notarization %s: %s: %s" % (i.get("severity"), i.get("path"), i.get("message")))
    if status != "Accepted":
        work.add("notarize", False, {"id": sid, "status": status, "issues": len(issues)})
        raise Failed("MACOS-NOTARIZE", "Apple's notarization of %s is %s, not Accepted: %s" % (
            sid, status, "; ".join("%s: %s" % (i.get("path"), i.get("message")) for i in errors) or (info or {}).get("message")),
            "The log (notary-log.json, in the diagnostics) names each rejected component and Apple's documentation for it")
    if not entry:
        raise Failed("MACOS-NOTARIZE", "submission %s is Accepted, but its log could not be read: refusing to go on "
                     "without inspecting it" % sid)
    if entry.get("status") != "Accepted" or errors:
        raise Failed("MACOS-NOTARIZE", "the log of %s says %s with %d error(s)" % (sid, entry.get("status"), len(errors)))
    tickets = {(t.get("cdhash") or "").lower() for t in entry.get("ticketContents") or []}
    if cdhash.lower() not in tickets:
        raise Failed("MACOS-NOTARIZE", "the ticket of %s does not hold the bundle's CDHash %s (it holds %s): another "
                     "artifact was notarized" % (sid, cdhash, ", ".join(sorted(tickets)) or "none"))
    work.add("notarize", True, {"id": sid, "status": status, "warnings": len(warnings), "cdhash": cdhash})
    print("notarize: %s Accepted (%d warning(s)); its ticket holds CDHash %s" % (sid, len(warnings), cdhash))


def stage_staple(work, args):
    work.require("notarize", code="MACOS-STAPLE")
    app = os.path.abspath(args.app)
    if sealed(app, "MACOS-STAPLE") != work.last("notarize")["cdhash"]:
        raise Failed("MACOS-STAPLE", "the bundle is not the one notarized")
    last = ""
    for attempt in range(STAPLE_TRIES):
        code, out, err = run(["xcrun", "stapler", "staple", app], check=False, timeout=300)
        last = (out + err).strip()
        if code == 0:
            break
        if not TRANSIENT_STAPLE.search(last):
            raise Failed("MACOS-STAPLE", "stapler could not staple the ticket: %s" % last[-400:])
        print("staple: the ticket is not available yet (attempt %d of %d): waiting" % (attempt + 1, STAPLE_TRIES), flush=True)
        time.sleep(min(120, 15 * 2 ** attempt) * WAIT)
    else:
        raise Failed("MACOS-STAPLE", "Apple's ticket was still not available after %d attempts: %s" % (STAPLE_TRIES, last[-300:]),
                     "Run the release again later (the submission is Accepted; stapling only fetches its ticket)")
    try:
        run(["xcrun", "stapler", "validate", app], timeout=300)
    except ToolFailed as t:
        raise Failed("MACOS-STAPLE", "stapler validate refuses the stapled bundle: %s" % t.text())
    work.add("staple", True, {"cdhash": current_cdhash(app)})
    print("staple: the ticket is stapled and validates")


def stage_gatekeeper(work, args):
    app = os.path.abspath(args.app)
    code, out, err = run(["spctl", "--assess", "--type", "execute", "--verbose=4", app], check=False)
    text = (out + err).strip()
    print(text)
    facts = {"text": text, "status": code}
    if args.expect == "notarized":
        work.require("staple", code="MACOS-GATEKEEPER")
        team = work.last("preflight")["team"]
        ok = code == 0 and re.search(r":\s*accepted\b", text) and "source=Notarized Developer ID" in text \
            and re.search(r"origin=Developer ID Application: .*\(%s\)" % re.escape(team), text)
        if not ok:
            work.add("gatekeeper", False, facts)
            raise Failed("MACOS-GATEKEEPER", "Gatekeeper does not accept the bundle as a notarized Developer ID application: %s" % text)
    else:
        ok = code != 0 and "rejected" in text
        if not ok:
            raise Failed("MACOS-GATEKEEPER", "Gatekeeper should refuse a bundle that is not notarized: %s" % text)
    work.add("gatekeeper" if args.expect == "notarized" else "gatekeeper:refused", True, facts)


def stage_tamper(work, args):
    """A private copy changed after signing must fail verification; the original must pass after it."""
    app = os.path.abspath(args.app)
    before = current_cdhash(app)
    tmp = tempfile.mkdtemp(prefix="icy-tower-tamper.")
    try:
        results = []
        for what in ("executable", "resource"):
            copy = os.path.join(tmp, what, bundle.NAME + ".app")
            os.makedirs(os.path.dirname(copy))
            run(["ditto", app, copy], quiet=True)
            target = os.path.join(copy, "Contents", "MacOS", bundle.EXECUTABLE) if what == "executable" else \
                os.path.join(copy, "Contents", "Resources", bundle.RESOURCES[0])
            with open(target, "r+b") as f:
                f.seek(os.path.getsize(target) // 2)
                b = f.read(1)
                f.seek(-1, 1)
                f.write(bytes([b[0] ^ 0x01]))
            code, out, err = run(["codesign", "--verify", "--deep", "--strict", copy], check=False, quiet=True)
            results.append((what, code, (out + err).strip().splitlines()[-1:]))
            if code == 0:
                raise Failed("MACOS-SIGN", "a copy with one byte of its %s changed still verifies: the signature seals "
                             "nothing" % what)
            print("tamper: one byte of the copy's %s changed: codesign refuses it (%s)" % (what, "; ".join(results[-1][2])))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    run(["codesign", "--verify", "--deep", "--strict", app], quiet=True)
    if current_cdhash(app) != before:
        raise Failed("MACOS-SIGN", "the original bundle changed during the tamper control")
    work.add("tamper", True, {"cdhash": before})


# ---------------------------------------------------------------------------
# package, publishable

def tree(root):
    out = {}
    for dirpath, dirnames, filenames in os.walk(root):
        for n in filenames:
            p = os.path.join(dirpath, n)
            st = os.lstat(p)
            out[os.path.relpath(p, root)] = (st.st_mode & 0o777, sha256(p))
    return out


def stage_package(work, args):
    app = os.path.abspath(args.app)
    out = os.path.abspath(args.out)
    os.makedirs(out, exist_ok=True)
    if work.mode == "release":
        work.require("staple", "gatekeeper", "tamper", "verify-signature:stapled", code="MACOS-PUBLISH")
        if sealed(app, "MACOS-PUBLISH") != work.last("notarize")["cdhash"]:
            raise Failed("MACOS-PUBLISH", "the bundle is not the notarized one")
    z = os.path.join(out, ZIP)
    for p in (z, os.path.join(out, SUMS)):
        if os.path.exists(p):
            os.unlink(p)
    run(["ditto", "-c", "-k", "--keepParent", app, z])
    run(["unzip", "-tq", z])
    digest = sha256(z)
    fresh = tempfile.mkdtemp(prefix="icy-tower-unpacked.")
    try:
        run(["ditto", "-x", "-k", z, fresh])
        unpacked = os.path.join(fresh, bundle.NAME + ".app")
        if tree(unpacked) != tree(app):
            raise Failed("MACOS-PUBLISH", "the ZIP's bundle differs from the bundle it was made of (files, modes or bytes)")
        mode = os.stat(os.path.join(unpacked, "Contents", "MacOS", bundle.EXECUTABLE)).st_mode & 0o777
        if mode != 0o755:
            raise Failed("MACOS-PUBLISH", "the ZIP loses the executable's permissions (mode %o)" % mode)
        check_signature(unpacked, work.mode)
        if work.mode == "release":
            run(["xcrun", "stapler", "validate", unpacked])
    finally:
        shutil.rmtree(fresh, ignore_errors=True)
    provenance = dict(json.loads(args.provenance) if args.provenance else {})
    provenance.update({"zip": ZIP, "zip_sha256": digest, "cdhash": current_cdhash(app), "mode": work.mode})
    if work.mode == "release":
        provenance["notarization_submission"] = work.last("notarize")["id"]
        provenance["team"] = work.last("preflight")["team"]
        provenance["bundle_id"] = work.last("preflight")["bundle_id"]
    with open(os.path.join(out, PROVENANCE), "w") as f:
        json.dump(provenance, f, indent=1, sort_keys=True)
    with open(os.path.join(out, SUMS), "w") as f:
        for name in (ZIP, PROVENANCE):
            f.write("%s  %s\n" % (sha256(os.path.join(out, name)), name))
    work.add("package", True, {"zip_sha256": digest, "cdhash": provenance["cdhash"]})
    print("package: %s (%d bytes), sha256 %s" % (z, os.path.getsize(z), digest))


def check_sums(directory):
    with open(os.path.join(directory, SUMS)) as f:
        lines = [ln.split() for ln in f if ln.strip()]
    sums = {name: h for h, name in lines}
    if set(sums) != {ZIP, PROVENANCE}:
        raise Failed("MACOS-PUBLISH", "SHA256SUMS lists %s, not exactly %s and %s" % (sorted(sums), ZIP, PROVENANCE))
    for name, h in sums.items():
        if sha256(os.path.join(directory, name)) != h:
            raise Failed("MACOS-PUBLISH", "%s's SHA-256 is not the one SHA256SUMS lists" % name)
    return sums


def stage_publishable(work, args):
    if work.mode not in SEQUENCE:
        raise Failed("MACOS-PUBLISH", "a %s build is never published: only a release (Developer ID, notarized, stapled)"
                     % work.mode)
    seq = SEQUENCE[work.mode]
    stages = work.state["stages"]
    failed = [s["stage"] for s in stages if not s["ok"]]
    if failed:
        raise Failed("MACOS-PUBLISH", "stage(s) %s failed in this release: nothing is published" % ", ".join(sorted(set(failed))))
    order = [s["stage"] for s in stages]
    pos = -1
    for name in seq:
        if name not in order[pos + 1:]:
            raise Failed("MACOS-PUBLISH", "stage %s did not pass after %s: nothing is published" % (name, seq[seq.index(name) - 1] if seq.index(name) else "the start"))
        pos = order.index(name, pos + 1)
    if work.last("preflight")["anchors"] != "apple":
        raise Failed("MACOS-PUBLISH", "the identity was not checked against Apple's certificate authorities")
    cd = work.last("notarize")["cdhash"]
    for name in ("sign", "verify-signature", "record:hardened-runtime", "staple", "tamper", "package"):
        if work.last(name).get("cdhash") != cd:
            raise Failed("MACOS-PUBLISH", "stage %s saw CDHash %s, not the notarized %s" % (name, work.last(name).get("cdhash"), cd))
    sums = check_sums(os.path.abspath(args.out))
    digest = work.last("package")["zip_sha256"]
    if sums[ZIP] != digest or work.last("record:final-artifact").get("zip_sha256") != digest:
        raise Failed("MACOS-PUBLISH", "the ZIP to publish is not the one packaged and launched")
    if work.last("verify-signature")["authority"][0].startswith("Developer ID Application: ") is False:
        raise Failed("MACOS-PUBLISH", "the signature is not a Developer ID one")
    print("publishable: every stage of the release passed on CDHash %s; %s sha256 %s" % (cd, ZIP, digest))


def stage_cleanup(work, args):
    k = work.last("keychain")
    problems = []
    before_file = os.path.join(work.path, "keychains-before.json")
    if os.path.exists(before_file):
        with open(before_file) as f:
            before = json.load(f)
        run(["security", "list-keychains", "-d", "user", "-s"] + before, check=False)
    if k and os.path.exists(k["keychain"]):
        run(["security", "delete-keychain", k["keychain"]], check=False)
    if os.path.isdir(work.secret):
        shutil.rmtree(work.secret, ignore_errors=True)
    if k:
        if os.path.exists(k["keychain"]):
            problems.append("the temporary keychain still exists")
        if k["keychain"] in keychains_now():
            problems.append("the temporary keychain is still in the search list")
    if os.path.exists(work.secret):
        problems.append("the decoded credentials still exist")
    if problems:
        raise Failed("MACOS-SIGN", "cleanup incomplete: %s" % "; ".join(problems))
    print("cleanup: the temporary keychain deleted, the search list restored, the decoded credentials removed")


STAGES = {
    "preflight": stage_preflight, "keychain": stage_keychain, "notary-auth": stage_notary_auth, "sign": stage_sign,
    "verify-signature": stage_verify, "record": stage_record, "notarize": stage_notarize, "staple": stage_staple,
    "gatekeeper": stage_gatekeeper, "tamper": stage_tamper, "package": stage_package,
    "publishable": stage_publishable, "cleanup": stage_cleanup, "adopt": stage_adopt, "identity": stage_identity,
}


def main(argv):
    import argparse
    p = argparse.ArgumentParser(prog="release.py")
    p.add_argument("stage", choices=sorted(STAGES))
    p.add_argument("--work", required=True)
    p.add_argument("--mode", choices=("adhoc", "dry-run", "release"))
    p.add_argument("--app")
    p.add_argument("--out")
    p.add_argument("--zip")
    p.add_argument("--results")
    p.add_argument("--cases")
    p.add_argument("--label", default="")
    p.add_argument("--expect", choices=("notarized", "refused"), default="notarized")
    p.add_argument("--resume")
    p.add_argument("--timeout", type=int, default=5400)
    p.add_argument("--trust-anchors")
    p.add_argument("--provenance")
    p.add_argument("--previous", action="append")
    a = p.parse_args(argv)
    for name in credentials.SECRETS:
        if os.environ.get(name):
            SECRET_VALUES.append(os.environ[name])
    try:
        work = Work(a.work, a.mode)
        secret_file = os.path.join(work.secret, "keychain-password")
        if os.path.exists(secret_file):
            with open(secret_file) as f:
                SECRET_VALUES.append(f.read())
        STAGES[a.stage](work, a)
    except Failed as f:
        print(redact(str(f)), file=sys.stderr)
        if f.remedy:
            print("    " + redact(f.remedy), file=sys.stderr)
        return 1
    except bundle.Refused as r:
        print(str(r), file=sys.stderr)
        return 1
    except ToolFailed as t:
        print("MACOS-SIGN: %s failed (status %d): %s" % (t.cmd[0], t.status, t.text()[-600:]), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

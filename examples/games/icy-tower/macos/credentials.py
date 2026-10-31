#!/usr/bin/env python3
"""credentials.py -- the macOS release's credential preflight
(ICY-TOWER-MACOS-APP-MILESTONE-1.md, "Credential preflight").

    python3 -I credentials.py check --out DIR [--trust-anchors DIR]

Reads the release's configuration from the environment -- the names are the
GitHub Actions configuration contract:

    MACOS_CERTIFICATE_P12_BASE64   secret    Base64 of the Developer ID Application .p12
    MACOS_CERTIFICATE_PASSWORD     secret    the .p12's password
    APPLE_NOTARY_KEY_BASE64        secret    Base64 of the App Store Connect team API key .p8
    APPLE_NOTARY_KEY_ID            variable  the API key's Key ID
    APPLE_NOTARY_ISSUER_ID         variable  the team API key's Issuer ID (a UUID)
    APPLE_TEAM_ID                  variable  the Apple Developer Team ID
    MACOS_BUNDLE_ID                variable  the game's stable bundle identifier

-- and validates every one locally, before any Apple tool sees it: present;
strict Base64 (the standard alphabet, its padding, canonical; line breaks
between lines accepted, nothing else); the decoded bytes of the type they
must be (a binary PKCS#12 container, never PEM text, a path, the encoding
command or the Base64 of Base64; a PEM PKCS#8 private key, never a
certificate, a public key, SEC1, an encrypted key or a .p12); the .p12
decrypted with its password (its own integrity check, PKCS#12's MAC, tells a
wrong password from damaged contents where it can, and says so where it
cannot); a private key that matches the certificate; the certificate a
Developer ID Application one (its name and Apple's marker extension; never
Developer ID Installer, Apple Development or Apple Distribution), for code
signing, valid now, issued by Apple's Developer ID Certification Authority
(G1 or G2, the committed apple-ca/ certificates, whose fingerprints this
file pins) and Team APPLE_TEAM_ID's; the .p8 an EC P-256 key (App Store
Connect's ES256); the Key ID, Issuer ID, Team ID and bundle identifier of
the forms Apple gives them.

Every problem found is reported -- all of them, not only the first --
under a stable code (MACOS-CONFIG-MISSING, MACOS-CREDENTIAL-BASE64,
MACOS-CREDENTIAL-FORMAT, MACOS-CERTIFICATE-DECRYPT,
MACOS-CERTIFICATE-IDENTITY, MACOS-TEAM-MISMATCH, MACOS-NOTARY-KEY-FORMAT,
MACOS-NOTARY-CONFIG, MACOS-BUNDLE-METADATA), naming the variable and the
remedy, and the exit status is 1. Nothing secret is ever printed: no
decoded byte, no key, no password, no Base64 of either, not even a piece
of one; only public facts (the certificate's subject, issuer, dates and
fingerprints, which are in every signature it makes).

On success DIR (created owner-only) receives identity.p12 and
notary-key.p8, the decoded files (owner-only), and identity.json, the
public facts the later stages need (the certificate's SHA-1, which selects
the identity in the temporary keychain, never "the first one"; its team,
subject and issuer; the intermediate to import beside it; the notary
key's ID and issuer; the bundle identifier).

That the .p8 is the key the Key ID and Issuer ID name is something no
local check can know: a .p8 carries no identifier. Apple's service decides
it (release.py notary-auth: notarytool store-credentials, which validates
the three together before anything is uploaded).

--trust-anchors DIR replaces the committed Apple certificates with DIR's
(test fixtures only: audit/macos-release/); identity.json then says so
("anchors": "test"), and release.py refuses such an identity for a release.
"""
import base64
import binascii
import datetime
import hashlib
import hmac
import json
import os
import re
import stat
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import bundle  # noqa: E402

VARIABLES = (
    ("MACOS_CERTIFICATE_P12_BASE64", "secret"),
    ("MACOS_CERTIFICATE_PASSWORD", "secret"),
    ("APPLE_NOTARY_KEY_BASE64", "secret"),
    ("APPLE_NOTARY_KEY_ID", "variable"),
    ("APPLE_NOTARY_ISSUER_ID", "variable"),
    ("APPLE_TEAM_ID", "variable"),
    ("MACOS_BUNDLE_ID", "variable"),
)
SECRETS = tuple(n for n, kind in VARIABLES if kind == "secret")
DOC = "docs/ICY-TOWER-MACOS-APP-MILESTONE-1.md, \"GitHub configuration\""

# Apple's public certificates (apple-ca/), pinned by SHA-256: the root that
# issues both Developer ID Certification Authorities, and the two.
APPLE_CA = {
    "AppleIncRootCertificate.cer": "b0b1730ecbc7ff4505142c49f1295e6eda6bcaed7e2c68c5be91b5a11001f024",
    "DeveloperIDCA.cer": "7afc9d01a62f03a2de9637936d4afe68090d2de18d03f29c88cfb0b1ba63587f",
    "DeveloperIDG2CA.cer": "f16cd3c54c7f83cea4bf1a3e6a0819c8aaa8e4a1528fd144715f350643d2df3a",
}
APPLE_ROOT = "AppleIncRootCertificate.cer"

# Apple's certificate extensions (the marker of a certificate's kind).
OID_DEVELOPER_ID_APPLICATION = "1.2.840.113635.100.6.1.13"
OID_DEVELOPER_ID_INSTALLER = "1.2.840.113635.100.6.1.14"
OID_MAC_DEVELOPMENT = "1.2.840.113635.100.6.1.12"
OID_IOS_DEVELOPMENT = "1.2.840.113635.100.6.1.2"
OID_IOS_DISTRIBUTION = "1.2.840.113635.100.6.1.4"
OID_MAC_APP_DISTRIBUTION = "1.2.840.113635.100.6.1.7"
OID_MAC_INSTALLER_DISTRIBUTION = "1.2.840.113635.100.6.1.8"
OID_CODE_SIGNING = "1.3.6.1.5.5.7.3.3"
OID_UID = "0.9.2342.19200300.100.1.1"

# What a certificate of another kind is for, by its common name's prefix
# and Apple's marker extension.
OTHER_KINDS = (
    ("Developer ID Installer: ", OID_DEVELOPER_ID_INSTALLER,
     "a Developer ID Installer certificate: it signs installer packages (.pkg), not applications"),
    ("Apple Development: ", OID_MAC_DEVELOPMENT, "an Apple Development certificate: it signs builds for your own devices, "
     "which Gatekeeper does not accept from anyone else"),
    ("Mac Developer: ", OID_MAC_DEVELOPMENT, "a Mac Developer (development) certificate"),
    ("iPhone Developer: ", OID_IOS_DEVELOPMENT, "an iPhone Developer (development) certificate"),
    ("Apple Distribution: ", OID_IOS_DISTRIBUTION, "an Apple Distribution certificate: it signs for the App Store, "
     "not for distribution outside it"),
    ("3rd Party Mac Developer Application: ", OID_MAC_APP_DISTRIBUTION, "a Mac App Store application certificate"),
    ("3rd Party Mac Developer Installer: ", OID_MAC_INSTALLER_DISTRIBUTION, "a Mac App Store installer certificate"),
    ("iPhone Distribution: ", OID_IOS_DISTRIBUTION, "an iPhone Distribution certificate"),
)
EXPORT_HINT = ("in Keychain Access, under My Certificates, select \"Developer ID Application: ...\" (the certificate "
               "with its private key beneath it) and export it as a .p12 (File > Export Items...)")

KEY_ID = re.compile(r"[A-Z0-9]{10}")
TEAM_ID = re.compile(r"[A-Z0-9]{10}")
UUID = re.compile(r"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")
B64_ALPHABET = re.compile(r"[A-Za-z0-9+/]*={0,2}")


class Problem(Exception):
    def __init__(self, code, variable, text, remedy=""):
        super().__init__(text)
        self.code, self.variable, self.text, self.remedy = code, variable, text, remedy

    def render(self):
        line = "%s: %s %s" % (self.code, self.variable, self.text) if self.variable else "%s: %s" % (self.code, self.text)
        return line + ("\n    " + self.remedy if self.remedy else "")


# ---------------------------------------------------------------------------
# Base64

def looks_like_path(text):
    t = text.strip()
    return bool(re.match(r"(~|/|\./|\.\./|[A-Za-z]:\\)", t)) or bool(re.search(r"\.(p12|pfx|p8|cer|pem|key|crt)\s*$", t, re.I))


def looks_like_command(text):
    return bool(re.search(r"\bbase64\b|\||\$\(|`|<\s*\S|\btr\s+-d\b|\bopenssl\b|\bcat\s", text))


def strict_base64(variable, raw):
    """The bytes RAW's Base64 encodes, or a Problem: the standard alphabet only, line breaks only between
    lines, correct padding, canonical (what an encoder writes), at least one byte."""
    stripped = raw.strip(" \t\r\n")
    if stripped == "":
        raise Problem("MACOS-CREDENTIAL-BASE64", variable, "holds only white space, no Base64",
                      "Store the Base64 of the file: base64 < FILE | tr -d '\\n'")
    if stripped.startswith("-----BEGIN"):
        raise Problem("MACOS-CREDENTIAL-BASE64", variable, "is PEM text itself, not the Base64 of the file",
                      "Encode the file's contents: base64 < FILE | tr -d '\\n', and store that output")
    if looks_like_command(stripped):
        raise Problem("MACOS-CREDENTIAL-BASE64", variable, "holds a shell command (it mentions base64, a pipe or a "
                      "redirection), not that command's output",
                      "Run the command on your own machine and store what it prints, not the command")
    if looks_like_path(stripped) and not B64_ALPHABET.fullmatch(stripped.replace("\n", "")):
        raise Problem("MACOS-CREDENTIAL-BASE64", variable, "is not valid Base64: it looks like a file name or path",
                      "Encode the binary file, not its filename or its textual description: base64 < FILE | tr -d '\\n'")
    lines = stripped.replace("\r\n", "\n").split("\n")
    text = "".join(lines)
    for i, c in enumerate(text):
        if c.isalnum() and c.isascii() or c in "+/=":
            continue
        if c in "-_":
            what = "a '%s' (URL-safe Base64's alphabet, not the standard one)" % c
        elif c in " \t":
            what = "white space inside a line"
        elif c == "\r":
            what = "a carriage return that does not end a line"
        elif ord(c) < 32 or ord(c) == 127:
            what = "a control character"
        elif not c.isascii():
            what = "a non-ASCII character"
        else:
            what = "a %r" % c
        raise Problem("MACOS-CREDENTIAL-BASE64", variable, "is not valid Base64: %s at character %d" % (what, i + 1),
                      "Encode the file with the standard alphabet: base64 < FILE | tr -d '\\n' (macOS and Linux)")
    if not B64_ALPHABET.fullmatch(text):
        raise Problem("MACOS-CREDENTIAL-BASE64", variable, "is not valid Base64: '=' padding before the end of the value",
                      "Store one Base64 encoding of the file, unaltered")
    if len(text) % 4:
        raise Problem("MACOS-CREDENTIAL-BASE64", variable, "is not valid Base64: invalid padding (%d characters, not a "
                      "multiple of 4: the value was cut short or its '=' padding removed)" % len(text),
                      "Copy the whole output of base64 < FILE | tr -d '\\n', including any trailing '='")
    try:
        data = binascii.a2b_base64(text, strict_mode=True)
    except (binascii.Error, ValueError):
        raise Problem("MACOS-CREDENTIAL-BASE64", variable, "is not valid Base64: invalid padding",
                      "Copy the whole output of base64 < FILE | tr -d '\\n'")
    if base64.b64encode(data).decode() != text:
        raise Problem("MACOS-CREDENTIAL-BASE64", variable, "is not valid Base64: invalid padding (nonzero bits in its last "
                      "character: no encoder writes it)", "Store the unaltered output of base64 < FILE | tr -d '\\n'")
    if not data:
        raise Problem("MACOS-CREDENTIAL-BASE64", variable, "decodes to no bytes", "Encode the file itself")
    return data


def as_text(data):
    """DATA as text when it is printable text (UTF-8, no control character but white space), else None."""
    try:
        t = data.decode("utf-8")
    except UnicodeDecodeError:
        return None
    if any((ord(c) < 32 and c not in "\r\n\t") or ord(c) == 127 for c in t):
        return None
    return t


def base64_again(text):
    """The bytes TEXT encodes when it is itself strict Base64 (a value encoded twice), else None."""
    joined = "".join(text.strip().replace("\r\n", "\n").split("\n"))
    if len(joined) < 8 or len(joined) % 4 or not B64_ALPHABET.fullmatch(joined):
        return None
    try:
        return binascii.a2b_base64(joined, strict_mode=True)
    except (binascii.Error, ValueError):
        return None


# ---------------------------------------------------------------------------
# DER (BER) structure: enough to tell a PKCS#12 container, a certificate and a
# PKCS#8 key apart, and to check one is whole, before any decryption.

class Malformed(Exception):
    pass


def read_tlv(data, off, end):
    if off + 2 > end:
        raise Malformed("truncated")
    tag = data[off]
    off += 1
    if tag & 0x1F == 0x1F:
        while True:
            if off >= end:
                raise Malformed("truncated")
            b = data[off]
            off += 1
            if not b & 0x80:
                break
    if off >= end:
        raise Malformed("truncated")
    first = data[off]
    off += 1
    if first == 0x80:
        if not tag & 0x20:
            raise Malformed("an indefinite length on a primitive value")
        p = off
        while True:
            if p + 2 > end:
                raise Malformed("truncated: no end of contents")
            if data[p] == 0 and data[p + 1] == 0:
                return tag, off, p, p + 2
            _, _, _, p = read_tlv(data, p, end)
    if first & 0x80:
        n = first & 0x7F
        if n == 0 or n > 4 or off + n > end:
            raise Malformed("a malformed length")
        length = int.from_bytes(data[off:off + n], "big")
        off += n
    else:
        length = first
    if off + length > end:
        raise Malformed("truncated")
    return tag, off, off + length, off + length


def children(data, start, end):
    out = []
    p = start
    while p < end:
        tag, s, e, p = read_tlv(data, p, end)
        out.append((tag, s, e))
    return out


def oid(data, s, e):
    b = data[s:e]
    if not b:
        raise Malformed("an empty object identifier")
    parts = [b[0] // 40, b[0] % 40] if b[0] < 80 else [2, b[0] - 80]
    v = 0
    for x in b[1:]:
        v = (v << 7) | (x & 0x7F)
        if not x & 0x80:
            parts.append(v)
            v = 0
    return ".".join(str(p) for p in parts)


def octets(data, tag, s, e):
    """An OCTET STRING's contents, primitive (0x04) or constructed of chunks (0x24)."""
    if tag == 0x04:
        return data[s:e]
    if tag == 0x24:
        return b"".join(octets(data, t, a, b) for t, a, b in children(data, s, e))
    raise Malformed("no OCTET STRING")


def whole(data):
    """The one top-level SEQUENCE DATA is, or Malformed (trailing data included)."""
    tag, s, e, nxt = read_tlv(data, 0, len(data))
    if tag != 0x30:
        raise Malformed("no SEQUENCE")
    if nxt != len(data):
        raise Malformed("%d bytes of unexpected data after it" % (len(data) - nxt))
    return s, e


def pfx_structure(data):
    """The PKCS#12 PFX's (authsafe bytes, mac or None): version 3, a data ContentInfo, optional MacData."""
    s, e = whole(data)
    parts = children(data, s, e)
    if len(parts) < 2 or parts[0][0] != 0x02 or data[parts[0][1]:parts[0][2]] != b"\x03":
        raise Malformed("no PKCS#12 version 3")
    tag, cs, ce = parts[1]
    if tag != 0x30:
        raise Malformed("no ContentInfo")
    ci = children(data, cs, ce)
    if not ci or ci[0][0] != 0x06:
        raise Malformed("no content type")
    kind = oid(data, ci[0][1], ci[0][2])
    if kind != "1.2.840.113549.1.7.1":
        raise Malformed("authenticated safe of content type %s (public-key integrity mode), not data" % kind)
    if len(ci) < 2 or ci[1][0] != 0xA0:
        raise Malformed("no content")
    inner = children(data, ci[1][1], ci[1][2])
    if len(inner) != 1:
        raise Malformed("no content")
    authsafe = octets(data, *inner[0])
    mac = None
    if len(parts) >= 3:
        tag, ms, me = parts[2]
        m = children(data, ms, me)
        digest_info = children(data, m[0][1], m[0][2])
        alg = children(data, digest_info[0][1], digest_info[0][2])
        mac = {"hash": oid(data, alg[0][1], alg[0][2]), "digest": octets(data, *digest_info[1]),
               "salt": octets(data, *m[1]),
               "iterations": int.from_bytes(data[m[2][1]:m[2][2]], "big") if len(m) > 2 else 1}
    return authsafe, mac


HASHES = {"1.3.14.3.2.26": ("sha1", 64), "2.16.840.1.101.3.4.2.1": ("sha256", 64), "2.16.840.1.101.3.4.2.4": ("sha224", 64),
          "2.16.840.1.101.3.4.2.2": ("sha384", 128), "2.16.840.1.101.3.4.2.3": ("sha512", 128)}


def pkcs12_kdf(name, block, password, salt, ident, iterations, n):
    """RFC 7292, appendix B.2: N bytes of key material of purpose IDENT."""
    u = hashlib.new(name).digest_size
    P = password.encode("utf-16-be") + b"\0\0" if password else b""
    D = bytes([ident]) * block

    def fill(x):
        if not x:
            return b""
        n = block * ((len(x) + block - 1) // block)
        return (x * (n // len(x) + 1))[:n]
    I = fill(salt) + fill(P)
    out = b""
    while len(out) < n:
        a = hashlib.new(name, D + I).digest()
        for _ in range(iterations - 1):
            a = hashlib.new(name, a).digest()
        out += a
        B = int.from_bytes((a * (block // u + 1))[:block], "big")
        I = b"".join(((int.from_bytes(I[j:j + block], "big") + B + 1) % (1 << (8 * block))).to_bytes(block, "big")
                     for j in range(0, len(I), block))
    return out[:n]


def mac_verifies(authsafe, mac, password):
    """True when PKCS#12's MAC verifies with PASSWORD, False when not, None when its algorithm is not known here."""
    if mac is None or mac["hash"] not in HASHES or mac["iterations"] > 10_000_000:
        return None
    name, block = HASHES[mac["hash"]]
    key = pkcs12_kdf(name, block, password, mac["salt"], 3, mac["iterations"], hashlib.new(name).digest_size)
    return hmac.compare_digest(hmac.new(key, authsafe, name).digest(), mac["digest"])


def pem_blocks(text):
    return re.findall(r"-----BEGIN ([A-Z0-9 ]+)-----(.*?)-----END ([A-Z0-9 ]+)-----", text, re.S)


# ---------------------------------------------------------------------------
# Certificates

def crypto():
    try:
        from cryptography import x509
        from cryptography.hazmat.primitives import hashes, serialization
        from cryptography.hazmat.primitives.serialization import pkcs12
        from cryptography.hazmat.primitives.asymmetric import ec, rsa
    except ImportError:
        sys.exit("credentials.py: the Python package cryptography is not installed: "
                 "pip install --require-hashes --only-binary :all: -r %s" % os.path.join(HERE, "requirements.txt"))
    return x509, hashes, serialization, pkcs12, ec, rsa


def load_anchors(directory=None):
    """The root and the Developer ID intermediates: Apple's committed ones (their fingerprints checked), or a
    test directory's (root.cer plus any others)."""
    x509 = crypto()[0]
    certs = {}
    if directory is None:
        for name, fingerprint in APPLE_CA.items():
            with open(os.path.join(HERE, "apple-ca", name), "rb") as f:
                der = f.read()
            if hashlib.sha256(der).hexdigest() != fingerprint:
                sys.exit("credentials.py: apple-ca/%s is not Apple's certificate (its SHA-256 differs from the pinned one)" % name)
            certs[name] = x509.load_der_x509_certificate(der)
        root = certs.pop(APPLE_ROOT)
    else:
        for name in sorted(os.listdir(directory)):
            with open(os.path.join(directory, name), "rb") as f:
                der = f.read()
            certs[name] = x509.load_pem_x509_certificate(der) if der.startswith(b"-----") else x509.load_der_x509_certificate(der)
        root = certs.pop("root.cer")
    for name, c in certs.items():
        c.verify_directly_issued_by(root)
    return root, certs


def name_of(cert, oidtext):
    x509 = crypto()[0]
    values = [a.value for a in cert.subject.get_attributes_for_oid(x509.ObjectIdentifier(oidtext))]
    return values[0] if values else None


def cn(cert):
    return name_of(cert, "2.5.4.3") or ""


def extensions_of(cert):
    return {e.oid.dotted_string: e for e in cert.extensions}


def is_ca(cert):
    x509 = crypto()[0]
    try:
        return cert.extensions.get_extension_for_class(x509.BasicConstraints).value.ca
    except x509.ExtensionNotFound:
        return False


def certificate_kind(cert):
    """None for a Developer ID Application certificate, else what it is instead."""
    name = cn(cert)
    exts = extensions_of(cert)
    if name.startswith("Developer ID Application: ") and OID_DEVELOPER_ID_APPLICATION in exts:
        return None
    for prefix, marker, what in OTHER_KINDS:
        if name.startswith(prefix) or marker in exts:
            return what
    if name.startswith("Developer ID Application: "):
        return "named Developer ID Application but without Apple's Developer ID Application extension (%s)" % OID_DEVELOPER_ID_APPLICATION
    return "not an Apple code-signing certificate (its common name is %r)" % name


def now_utc():
    return datetime.datetime.now(datetime.timezone.utc)


def check_identity(p12, password, team, anchors_dir=None):
    """The identity facts of the decoded .p12 P12 with PASSWORD, or raises Problem(s) (a list)."""
    x509, hashes, serialization, pkcs12, ec, rsa = crypto()
    v = "MACOS_CERTIFICATE_P12_BASE64"
    try:
        authsafe, mac = pfx_structure(p12)
    except Malformed as m:
        raise Problem("MACOS-CREDENTIAL-FORMAT", v, "decoded successfully, but the result is not a PKCS#12 container "
                      "(.p12): %s" % m, "Export the Developer ID Application identity again as a .p12 and encode "
                      "that file; %s" % EXPORT_HINT)
    except (IndexError, ValueError):
        raise Problem("MACOS-CREDENTIAL-FORMAT", v, "decoded successfully, but the result is not a well-formed PKCS#12 "
                      "container (.p12)", "Export the identity again as a .p12; %s" % EXPORT_HINT)
    try:
        loaded = pkcs12.load_pkcs12(p12, password.encode("utf-8"))
    except ValueError:
        verdict = None
        try:
            verdict = mac_verifies(authsafe, mac, password)
        except Exception:
            verdict = None
        trailing = " MACOS_CERTIFICATE_PASSWORD ends with white space or a line break; if that is not part of the " \
                   "password, store the password without it." if password != password.rstrip() else ""
        if verdict is True:
            raise Problem("MACOS-CERTIFICATE-DECRYPT", v, "passes its integrity check with MACOS_CERTIFICATE_PASSWORD "
                          "(so the password is right), but its contents cannot be decrypted: the exported file is "
                          "damaged or uses an encryption this check does not support",
                          "Export the identity again as a .p12 and encode the new file")
        raise Problem("MACOS-CERTIFICATE-DECRYPT", v, "could not be decrypted with MACOS_CERTIFICATE_PASSWORD. "
                      "The password may be wrong, or the exported file may be damaged." + trailing,
                      "Check the password you chose when exporting the .p12, or export it again with a new password "
                      "and update both secrets")
    key, cert = loaded.key, loaded.cert.certificate if loaded.cert else None
    extra = [c.certificate for c in loaded.additional_certs]
    spki = serialization.PublicFormat.SubjectPublicKeyInfo

    def public(k):
        return k.public_key().public_bytes(serialization.Encoding.DER, spki)
    leaves = [c for c in extra if not is_ca(c)]
    if key is None:
        if cert is None and not leaves:
            raise Problem("MACOS-CERTIFICATE-IDENTITY", v, "holds neither a signing certificate nor a private key", EXPORT_HINT)
        raise Problem("MACOS-CERTIFICATE-IDENTITY", v, "holds the certificate %r but no private key: a certificate "
                      "alone cannot sign" % cn(cert or leaves[0]), EXPORT_HINT)
    if cert is None:
        # A key and certificates the container does not pair: the key's own certificate, if one is among them.
        mine = [c for c in leaves if public(c) == public(key)]
        if not mine:
            raise Problem("MACOS-CERTIFICATE-IDENTITY", v, "holds a private key that does not match its certificate%s: "
                          "an unrelated key and certificate cannot sign" % (" %r" % cn(leaves[0]) if leaves else " (it has none)"),
                          "Export the identity (the certificate with its own private key) from the Mac that created "
                          "its certificate request; %s" % EXPORT_HINT)
        cert = mine[0]
    if public(key) != public(cert):
        raise Problem("MACOS-CERTIFICATE-IDENTITY", v, "holds a private key that does not match its certificate %r: "
                      "an unrelated key and certificate cannot sign" % cn(cert),
                      "Export the identity (the certificate with its own private key) from the Mac that created "
                      "its certificate request; %s" % EXPORT_HINT)
    problems = []
    kind = certificate_kind(cert)
    if kind:
        problems.append(Problem("MACOS-CERTIFICATE-IDENTITY", v, "holds %s, not a Developer ID Application certificate"
                                % kind, "Create a Developer ID Application certificate (developer.apple.com, "
                                "Certificates, Identifiers & Profiles; or Xcode, Settings, Accounts, Manage "
                                "Certificates) and export that identity"))
    exts = extensions_of(cert)
    eku = exts.get("2.5.29.37")
    if eku is None or OID_CODE_SIGNING not in [o.dotted_string for o in eku.value]:
        problems.append(Problem("MACOS-CERTIFICATE-IDENTITY", v, "holds a certificate whose extended key usage does not "
                                "include code signing", "Export a Developer ID Application identity"))
    ku = exts.get("2.5.29.15")
    if ku is not None and not ku.value.digital_signature:
        problems.append(Problem("MACOS-CERTIFICATE-IDENTITY", v, "holds a certificate whose key usage excludes digital "
                                "signatures", "Export a Developer ID Application identity"))
    t = now_utc()
    if t < cert.not_valid_before_utc:
        problems.append(Problem("MACOS-CERTIFICATE-IDENTITY", v, "holds a certificate that is not valid until %s"
                                % cert.not_valid_before_utc.date(), "Check the runner's clock, or wait for the date"))
    if t > cert.not_valid_after_utc:
        problems.append(Problem("MACOS-CERTIFICATE-IDENTITY", v, "holds a certificate that expired on %s (certificate "
                                "validity)" % cert.not_valid_after_utc.date(), "Create a new Developer ID Application "
                                "certificate, export it as a .p12 and update both secrets"))
    root, intermediates = load_anchors(anchors_dir)
    issuer = None
    for name, ca in intermediates.items():
        if ca.subject == cert.issuer:
            try:
                cert.verify_directly_issued_by(ca)
                issuer = (name, ca)
            except Exception:
                pass
    if issuer is None:
        issuer_cn = [a.value for a in cert.issuer.get_attributes_for_oid(x509.ObjectIdentifier("2.5.4.3"))]
        named = any(ca.subject == cert.issuer for ca in intermediates.values())
        if named:
            why = "names Apple's Developer ID Certification Authority as its issuer, but that authority's signature on " \
                  "it does not verify: it is not a certificate Apple issued"
        elif cert.issuer == cert.subject:
            why = "is self-signed"
        else:
            why = "is issued by %r" % (issuer_cn[0] if issuer_cn else "?")
        problems.append(Problem("MACOS-CERTIFICATE-IDENTITY", v, "holds a certificate that is not issued by Apple's "
                                "Developer ID Certification Authority (it %s): a self-signed or other authority's "
                                "certificate is no Developer ID" % why,
                                "Use the Developer ID Application certificate Apple issued to your team"))
    elif not (issuer[1].not_valid_before_utc <= t <= issuer[1].not_valid_after_utc):
        problems.append(Problem("MACOS-CERTIFICATE-IDENTITY", v, "holds a certificate whose issuer, %s, is not valid now"
                                % cn(issuer[1]), "Create a new Developer ID Application certificate"))
    ou = name_of(cert, "2.5.4.11")
    uid = name_of(cert, OID_UID)
    suffix = re.search(r"\(([A-Z0-9]{10})\)$", cn(cert))
    teams = {x for x in (ou, uid, suffix.group(1) if suffix else None) if x}
    if len(teams) > 1:
        problems.append(Problem("MACOS-CERTIFICATE-IDENTITY", v, "holds a certificate whose name gives more than one "
                                "team (%s)" % ", ".join(sorted(teams)), "Export a Developer ID Application identity Apple issued"))
    elif team is not None and TEAM_ID.fullmatch(team) and teams != {team}:
        problems.append(Problem("MACOS-TEAM-MISMATCH", "APPLE_TEAM_ID", "is %s, but the signing certificate %r is team "
                                "%s's" % (team, cn(cert), ", ".join(sorted(teams)) or "no team"),
                                "Set APPLE_TEAM_ID to the team of the Developer ID certificate (its common name ends with "
                                "it in parentheses), or export the identity of team %s" % team))
    if problems:
        raise ProblemList(problems)
    der = cert.public_bytes(serialization.Encoding.DER)
    key_desc = ("RSA %d" % key.key_size) if isinstance(key, rsa.RSAPrivateKey) else \
        ("EC %s" % key.curve.name) if isinstance(key, ec.EllipticCurvePrivateKey) else type(key).__name__
    return {
        "subject": cn(cert),
        "team": ou,
        "sha1": hashlib.sha1(der).hexdigest().upper(),
        "sha256": hashlib.sha256(der).hexdigest(),
        "issuer": cn(issuer[1]),
        "intermediate": issuer[0],
        "not_before": cert.not_valid_before_utc.isoformat(),
        "not_after": cert.not_valid_after_utc.isoformat(),
        "key": key_desc,
        "chain_in_p12": len(extra),
    }


class ProblemList(Exception):
    def __init__(self, problems):
        super().__init__("; ".join(p.text for p in problems))
        self.problems = problems


def classify_p12_bytes(data):
    """A Problem when the decoded .p12 secret is plainly no binary container, else None."""
    v = "MACOS_CERTIFICATE_P12_BASE64"
    text = as_text(data)
    if text is None:
        return None
    if "-----BEGIN" in text:
        labels = [b[0] for b in pem_blocks(text)] or re.findall(r"-----BEGIN ([A-Z0-9 ]+)-----", text)
        if "PRIVATE KEY" in labels or any("PRIVATE KEY" in label for label in labels):
            what = "a PEM private key (perhaps the notarization key, which belongs in APPLE_NOTARY_KEY_BASE64)"
        elif "CERTIFICATE" in labels:
            what = "a PEM certificate"
        else:
            what = "PEM text (%s)" % ", ".join(labels)
        return Problem("MACOS-CREDENTIAL-FORMAT", v, "decoded to %s, not a binary PKCS#12 container." % what,
                       "Export the Developer ID Application identity, including its private key, as a .p12 file; "
                       + EXPORT_HINT)
    again = base64_again(text)
    if again is not None:
        return Problem("MACOS-CREDENTIAL-FORMAT", v, "decoded to Base64 text again: the .p12 was Base64-encoded twice",
                       "Encode the .p12 file once: base64 < DeveloperIDApplication.p12 | tr -d '\\n'")
    if looks_like_path(text):
        return Problem("MACOS-CREDENTIAL-FORMAT", v, "decoded to a file name or path, not a binary PKCS#12 container: "
                       "the Base64 of the file's name was stored, not of its contents",
                       "Encode the file's contents: base64 < DeveloperIDApplication.p12 | tr -d '\\n'")
    return Problem("MACOS-CREDENTIAL-FORMAT", v, "decoded to text, not a binary PKCS#12 container (.p12)",
                   "Encode the binary .p12 file, not a text file: " + EXPORT_HINT)


# ---------------------------------------------------------------------------
# The notarization key

def check_notary_key(data):
    """The normalized PEM of the decoded .p8 DATA and its facts, or raises Problem."""
    x509, hashes, serialization, pkcs12, ec, rsa = crypto()
    v = "APPLE_NOTARY_KEY_BASE64"
    original = "Supply the original AuthKey_<KEY_ID>.p8 downloaded from App Store Connect (Users and Access, " \
               "Integrations, Team Keys), Base64-encoded once: base64 < AuthKey_KEYID.p8 | tr -d '\\n'"
    text = as_text(data)
    if text is None:
        try:
            pfx_structure(data)
            raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "decoded to a PKCS#12 container (a .p12: the signing identity?), "
                          "not the PEM-encoded PKCS#8 private key (.p8).", original)
        except Malformed:
            pass
        except (IndexError, ValueError):
            pass
        try:
            x509.load_der_x509_certificate(data)
            raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "decoded to a DER certificate, not the PEM-encoded PKCS#8 "
                          "private key (.p8).", original)
        except ValueError:
            pass
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "decoded successfully, but the result is binary data, not a "
                      "PEM-encoded PKCS#8 private key (.p8). Expected -----BEGIN PRIVATE KEY-----.", original)
    text = text.replace("\r\n", "\n")
    if "-----BEGIN" not in text:
        again = base64_again(text)
        if again is not None and b"-----BEGIN" in again:
            raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "decoded to Base64 text again: the .p8 was Base64-encoded twice.",
                          original)
        if looks_like_path(text):
            raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "decoded to a file name or path, not the key: the Base64 of "
                          "the file's name was stored, not of its contents.", original)
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "decoded successfully, but the result is not a PEM-encoded PKCS#8 "
                      "private key (.p8). Expected -----BEGIN PRIVATE KEY-----.", original)
    if "\\n" in text and "\n" not in text.strip():
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "holds the PEM text on one line with literal \\n sequences instead "
                      "of line breaks (an escaped copy of the key, e.g. from JSON).", original)
    blocks = pem_blocks(text)
    begins = re.findall(r"-----BEGIN ([A-Z0-9 ]+)-----", text)
    if len(begins) != len(blocks) or not blocks:
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "holds truncated PEM: a -----BEGIN %s----- line without its "
                      "-----END line." % (begins[0] if begins else "?"), original)
    if len(blocks) > 1:
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "holds %d PEM blocks (%s); a .p8 holds exactly one private key "
                      "and nothing else." % (len(blocks), ", ".join(b[0] for b in blocks)), original)
    label, body, end_label = blocks[0]
    if label != end_label:
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "holds PEM whose BEGIN (%s) and END (%s) lines differ." % (label, end_label), original)
    outside = re.sub(r"-----BEGIN [A-Z0-9 ]+-----.*?-----END [A-Z0-9 ]+-----", "", text, flags=re.S)
    if outside.strip():
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "holds unexpected text before or after the PEM block (a .p8 is "
                      "the key alone).", original)
    wrong = {
        "EC PRIVATE KEY": "is an EC private key but is not the expected PKCS#8 PEM .p8 format (it is SEC1: "
                          "BEGIN EC PRIVATE KEY).",
        "RSA PRIVATE KEY": "is an RSA private key (PKCS#1), not an App Store Connect API key (EC P-256, PKCS#8).",
        "PUBLIC KEY": "is a public key, not the private key: notarytool needs the private key Apple let you download once.",
        "ENCRYPTED PRIVATE KEY": "is an encrypted private key; App Store Connect's .p8 is not encrypted.",
        "CERTIFICATE": "is a certificate, not the notarization private key (.p8).",
    }
    if label in wrong:
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, wrong[label], original)
    if label != "PRIVATE KEY":
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "holds a PEM %s block, not BEGIN PRIVATE KEY (PKCS#8)." % label, original)
    lines = [ln.strip() for ln in body.strip().split("\n")]
    joined = "".join(lines)
    try:
        if not joined or len(joined) % 4 or not B64_ALPHABET.fullmatch(joined):
            raise ValueError
        der = binascii.a2b_base64(joined, strict_mode=True)
    except (binascii.Error, ValueError):
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "holds a PEM block whose body is not valid Base64 (damaged or "
                      "truncated).", original)
    try:
        s, e = whole(der)
        parts = children(der, s, e)
        if len(parts) < 3 or parts[0][0] != 0x02 or parts[1][0] != 0x30 or parts[2][0] != 0x04:
            raise Malformed("not a PrivateKeyInfo")
        alg = children(der, parts[1][1], parts[1][2])
        algorithm = oid(der, alg[0][1], alg[0][2])
    except (Malformed, IndexError, ValueError) as m:
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "holds a PEM block that is not a well-formed PKCS#8 private key "
                      "(%s): damaged or truncated." % m, original)
    try:
        key = serialization.load_der_private_key(der, password=None)
    except (ValueError, TypeError):
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "holds a PKCS#8 structure the cryptography library cannot read as a "
                      "private key (damaged).", original)
    except Exception:
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "holds a PKCS#8 key of an algorithm this check does not know.", original)
    if not isinstance(key, ec.EllipticCurvePrivateKey):
        what = "an RSA key" if isinstance(key, rsa.RSAPrivateKey) else "a %s key (%s)" % (type(key).__name__.replace("PrivateKey", ""), algorithm)
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "is %s: wrong key algorithm. App Store Connect API keys are EC keys "
                      "on the P-256 curve (ES256)." % what, original)
    if key.curve.name != "secp256r1":
        raise Problem("MACOS-NOTARY-KEY-FORMAT", v, "is an EC key on the %s curve: wrong curve. App Store Connect API "
                      "keys are P-256 (secp256r1, ES256)." % key.curve.name, original)
    pem = "-----BEGIN PRIVATE KEY-----\n" + "\n".join(lines) + "\n-----END PRIVATE KEY-----\n"
    return pem, {"algorithm": "EC P-256", "public_sha256": hashlib.sha256(key.public_key().public_bytes(
        serialization.Encoding.DER, serialization.PublicFormat.SubjectPublicKeyInfo)).hexdigest()}


# ---------------------------------------------------------------------------
# The public identifiers

def check_key_id(value):
    v = "APPLE_NOTARY_KEY_ID"
    remedy = "Copy the Key ID from App Store Connect, Users and Access, Integrations, Team Keys (10 letters and " \
             "digits, e.g. 2X9R4HXF34)"
    m = re.fullmatch(r"\s*AuthKey_([A-Za-z0-9]+)\.p8\s*", value)
    if m:
        raise Problem("MACOS-NOTARY-CONFIG", v, "is the key's file name, not its Key ID: the Key ID is the part after "
                      "AuthKey_ (%s)" % m.group(1), remedy)
    if value != value.strip():
        raise Problem("MACOS-NOTARY-CONFIG", v, "has leading or trailing white space or a line break", remedy)
    if value[:1] in "\"'" or value[-1:] in "\"'":
        raise Problem("MACOS-NOTARY-CONFIG", v, "is quoted; store the Key ID alone", remedy)
    if value.lower().startswith(("http:", "https:")):
        raise Problem("MACOS-NOTARY-CONFIG", v, "is a URL, not a Key ID", remedy)
    if UUID.fullmatch(value):
        raise Problem("MACOS-NOTARY-CONFIG", v, "is a UUID: that is the Issuer ID's form (APPLE_NOTARY_ISSUER_ID); the "
                      "Key ID is 10 characters", remedy)
    if not KEY_ID.fullmatch(value):
        raise Problem("MACOS-NOTARY-CONFIG", v, "is not a Key ID (10 upper-case letters and digits)", remedy)


def check_issuer_id(value):
    v = "APPLE_NOTARY_ISSUER_ID"
    remedy = "Copy the Issuer ID shown above the team keys in App Store Connect, Users and Access, Integrations " \
             "(a UUID such as 57246542-96fe-1a63-e053-0824d011072a)"
    if value != value.strip():
        raise Problem("MACOS-NOTARY-CONFIG", v, "has leading or trailing white space or a line break", remedy)
    if value.startswith("{") or value.endswith("}"):
        raise Problem("MACOS-NOTARY-CONFIG", v, "is in braces; store the UUID alone", remedy)
    if value.lower().startswith("urn:uuid:"):
        raise Problem("MACOS-NOTARY-CONFIG", v, "has a urn:uuid: prefix; store the UUID alone", remedy)
    if value[:1] in "\"'" or value[-1:] in "\"'":
        raise Problem("MACOS-NOTARY-CONFIG", v, "is quoted; store the UUID alone", remedy)
    if KEY_ID.fullmatch(value):
        raise Problem("MACOS-NOTARY-CONFIG", v, "looks like a Key ID (10 characters), not the Issuer ID (a UUID)", remedy)
    if not UUID.fullmatch(value):
        raise Problem("MACOS-NOTARY-CONFIG", v, "is not a valid UUID (8-4-4-4-12 hexadecimal digits)", remedy)


def check_team_id(value):
    v = "APPLE_TEAM_ID"
    remedy = "Copy the Team ID from developer.apple.com, Account, Membership details (10 letters and digits); it is " \
             "also in parentheses at the end of the Developer ID certificate's name"
    if value != value.strip():
        raise Problem("MACOS-NOTARY-CONFIG", v, "has leading or trailing white space or a line break", remedy)
    if not TEAM_ID.fullmatch(value):
        raise Problem("MACOS-NOTARY-CONFIG", v, "is not a Team ID (10 upper-case letters and digits)", remedy)


# ---------------------------------------------------------------------------

def secret_values(env):
    """Every secret's raw value: what output must never contain (tests and the redaction check read it)."""
    return [env[n] for n in SECRETS if env.get(n)]


def check(env, out=None, anchors_dir=None):
    """(problems, facts): every problem of the configuration ENV; on success the facts, and OUT written."""
    problems = []
    present = {}
    for name, kind in VARIABLES:
        if name not in env:
            problems.append(Problem("MACOS-CONFIG-MISSING", name, "is not set",
                                    "Add it as a %s of the macos-release environment (%s)" % (kind, DOC)))
        elif env[name] == "":
            problems.append(Problem("MACOS-CONFIG-MISSING", name, "is empty (GitHub Actions gives an undefined %s as an "
                                    "empty value): an empty credential" % kind,
                                    "Define it as a %s of the macos-release environment (%s)" % (kind, DOC)))
        else:
            present[name] = env[name]

    team = present.get("APPLE_TEAM_ID")
    for name, checker in (("APPLE_NOTARY_KEY_ID", check_key_id), ("APPLE_NOTARY_ISSUER_ID", check_issuer_id),
                          ("APPLE_TEAM_ID", check_team_id)):
        if name in present:
            try:
                checker(present[name])
            except Problem as p:
                problems.append(p)
    if "MACOS_BUNDLE_ID" in present:
        try:
            bundle.check_identifier(present["MACOS_BUNDLE_ID"])
        except bundle.Refused as r:
            problems.append(Problem(r.code, "", str(r).split(": ", 1)[1],
                                    "Set MACOS_BUNDLE_ID to the game's reverse-DNS identifier, and never change it "
                                    "between releases"))

    identity = None
    if "MACOS_CERTIFICATE_P12_BASE64" in present:
        try:
            p12 = strict_base64("MACOS_CERTIFICATE_P12_BASE64", present["MACOS_CERTIFICATE_P12_BASE64"])
            plain = classify_p12_bytes(p12)
            if plain:
                raise plain
            if "MACOS_CERTIFICATE_PASSWORD" in present:
                identity = check_identity(p12, present["MACOS_CERTIFICATE_PASSWORD"], team, anchors_dir)
                identity["p12"] = p12
        except Problem as p:
            problems.append(p)
        except ProblemList as pl:
            problems.extend(pl.problems)

    notary = None
    if "APPLE_NOTARY_KEY_BASE64" in present:
        try:
            raw = strict_base64("APPLE_NOTARY_KEY_BASE64", present["APPLE_NOTARY_KEY_BASE64"])
            notary = check_notary_key(raw)
        except Problem as p:
            problems.append(p)

    if problems:
        return problems, None
    facts = {
        "anchors": "test" if anchors_dir else "apple",
        "identity": {k: v for k, v in identity.items() if k != "p12"},
        "notary": dict(notary[1], key_id=present["APPLE_NOTARY_KEY_ID"], issuer_id=present["APPLE_NOTARY_ISSUER_ID"]),
        "team": team,
        "bundle_id": present["MACOS_BUNDLE_ID"],
    }
    if out:
        os.makedirs(out, mode=0o700, exist_ok=True)
        os.chmod(out, 0o700)
        for name, data in (("identity.p12", identity["p12"]), ("notary-key.p8", notary[0].encode())):
            path = os.path.join(out, name)
            fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
            with os.fdopen(fd, "wb") as f:
                f.write(data)
            os.chmod(path, stat.S_IRUSR | stat.S_IWUSR)
        with open(os.path.join(out, "identity.json"), "w") as f:
            json.dump(facts, f, indent=1, sort_keys=True)
    return [], facts


def main(argv):
    import argparse
    p = argparse.ArgumentParser(prog="credentials.py")
    sub = p.add_subparsers(dest="command", required=True)
    c = sub.add_parser("check")
    c.add_argument("--out")
    c.add_argument("--trust-anchors")
    a = p.parse_args(argv)
    if a.trust_anchors:
        print("credentials.py: TEST TRUST ANCHORS (%s): no Apple certificate is checked; this is no release" % a.trust_anchors)
    problems, facts = check(dict(os.environ), a.out, a.trust_anchors)
    if problems:
        print("The macOS release's configuration has %d problem(s); nothing was signed or sent to Apple:" % len(problems))
        for prob in problems:
            print(prob.render())
        return 1
    i, n = facts["identity"], facts["notary"]
    print("MACOS_CERTIFICATE_P12_BASE64: a PKCS#12 container, decrypted with MACOS_CERTIFICATE_PASSWORD")
    print("   identity: %s (%s key, matching the certificate), SHA-1 %s" % (i["subject"], i["key"], i["sha1"]))
    print("   issued by: %s (%s), valid %s to %s" % (i["issuer"], i["intermediate"], i["not_before"][:10], i["not_after"][:10]))
    print("   team: %s = APPLE_TEAM_ID" % i["team"])
    print("APPLE_NOTARY_KEY_BASE64: a PEM PKCS#8 %s private key" % n["algorithm"])
    print("APPLE_NOTARY_KEY_ID: %s; APPLE_NOTARY_ISSUER_ID: %s (well-formed; Apple's service decides they name this key)"
          % (n["key_id"], n["issuer_id"]))
    print("MACOS_BUNDLE_ID: %s" % facts["bundle_id"])
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

#!/usr/bin/env python3
"""fixtures.py -- synthetic credentials for the macOS release's tests
(ICY-TOWER-MACOS-APP-MILESTONE-1.md, "Synthetic credential fixtures").

    python3 -I fixtures.py dry-run DIR

Everything here is made on the spot by the cryptography package: a test
root and a test intermediate named "Developer ID Certification Authority"
(so a leaf issued by it looks like Apple's to every check but the one that
asks who issued the intermediate), leaf certificates of every kind a
developer could export by mistake (Developer ID Application, Installer,
Apple Development, Apple Distribution, expired, another team's, self-signed),
PKCS#12 containers of them (modern AES and Keychain Access's legacy
3DES/SHA-1), and App Store Connect-shaped keys (EC P-256 PKCS#8) and their
wrong relatives (SEC1, RSA, P-384, Ed25519, public, encrypted).

No fixture is Apple's or can pass for it: credentials.py accepts a
synthetic identity only when it is told to trust the test root
(--trust-anchors DIR), which a release refuses -- the tests show that the
same identity is rejected under Apple's anchors.

`dry-run DIR` writes the throwaway identity ordinary CI signs with
(release.py --mode dry-run): DIR/anchors/ (root.cer, devid.cer) and
DIR/env, the release's seven configuration variables as KEY=VALUE lines.
"""
import base64
import datetime
import os
import sys
import uuid

from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec, ed25519, rsa
from cryptography.hazmat.primitives.serialization import pkcs12
from cryptography.x509.oid import ExtendedKeyUsageOID, NameOID

TEAM = "TEST123456"
OTHER_TEAM = "OTHER98765"
PASSWORD = "correct horse battery staple"
KEY_ID = "ABCDE12345"
ISSUER_ID = "57246542-96fe-1a63-e053-0824d011072a"
BUNDLE_ID = "org.botlish.examples.icy-tower"
NOW = datetime.datetime.now(datetime.timezone.utc)

APPLICATION = "1.2.840.113635.100.6.1.13"
INSTALLER = "1.2.840.113635.100.6.1.14"
DEVELOPMENT = "1.2.840.113635.100.6.1.12"
DISTRIBUTION = "1.2.840.113635.100.6.1.4"

_keys = {}


def rsa_key(name):
    if name not in _keys:
        _keys[name] = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    return _keys[name]


def name(cn, ou=None, o=None, uid=None):
    attrs = []
    if uid:
        attrs.append(x509.NameAttribute(NameOID.USER_ID, uid))
    attrs.append(x509.NameAttribute(NameOID.COMMON_NAME, cn))
    if ou:
        attrs.append(x509.NameAttribute(NameOID.ORGANIZATIONAL_UNIT_NAME, ou))
    attrs.append(x509.NameAttribute(NameOID.ORGANIZATION_NAME, o or "Icy Tower Test"))
    attrs.append(x509.NameAttribute(NameOID.COUNTRY_NAME, "US"))
    return x509.Name(attrs)


class Authority:
    def __init__(self):
        self.root_key = rsa_key("root")
        self.root = (x509.CertificateBuilder().subject_name(name("Icy Tower Test Root CA", "Test Certification Authority"))
                     .issuer_name(name("Icy Tower Test Root CA", "Test Certification Authority"))
                     .public_key(self.root_key.public_key()).serial_number(1)
                     .not_valid_before(NOW - datetime.timedelta(days=3650)).not_valid_after(NOW + datetime.timedelta(days=3650))
                     .add_extension(x509.BasicConstraints(ca=True, path_length=None), critical=True)
                     .add_extension(x509.KeyUsage(False, False, False, False, False, True, True, False, False), critical=True)
                     .sign(self.root_key, hashes.SHA256()))
        self.ca_key = rsa_key("ca")
        self.ca_name = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, "Developer ID Certification Authority"),
                                  x509.NameAttribute(NameOID.ORGANIZATIONAL_UNIT_NAME, "G2"),
                                  x509.NameAttribute(NameOID.ORGANIZATION_NAME, "Apple Inc."),
                                  x509.NameAttribute(NameOID.COUNTRY_NAME, "US")])
        self.ca = (x509.CertificateBuilder().subject_name(self.ca_name).issuer_name(self.root.subject)
                   .public_key(self.ca_key.public_key()).serial_number(2)
                   .not_valid_before(NOW - datetime.timedelta(days=3000)).not_valid_after(NOW + datetime.timedelta(days=3000))
                   .add_extension(x509.BasicConstraints(ca=True, path_length=0), critical=True)
                   .add_extension(x509.KeyUsage(False, False, False, False, False, True, True, False, False), critical=True)
                   .sign(self.root_key, hashes.SHA256()))

    def write(self, directory):
        os.makedirs(directory, exist_ok=True)
        for fname, cert in (("root.cer", self.root), ("devid.cer", self.ca)):
            with open(os.path.join(directory, fname), "wb") as f:
                f.write(cert.public_bytes(serialization.Encoding.DER))

    def leaf(self, cn, team=TEAM, marker=APPLICATION, key=None, expired=False, codesign=True, self_signed=False, serial=10):
        key = key or rsa_key("leaf")
        subject = name(cn, team, "Icy Tower Test", team)
        before = NOW - datetime.timedelta(days=400 if expired else 30)
        after = NOW - datetime.timedelta(days=2) if expired else NOW + datetime.timedelta(days=365)
        b = (x509.CertificateBuilder().subject_name(subject).issuer_name(subject if self_signed else self.ca_name)
             .public_key(key.public_key()).serial_number(serial).not_valid_before(before).not_valid_after(after)
             .add_extension(x509.BasicConstraints(ca=False, path_length=None), critical=True)
             .add_extension(x509.KeyUsage(True, False, False, False, False, False, False, False, False), critical=True))
        if codesign:
            b = b.add_extension(x509.ExtendedKeyUsage([ExtendedKeyUsageOID.CODE_SIGNING]), critical=True)
        if marker:
            b = b.add_extension(x509.UnrecognizedExtension(x509.ObjectIdentifier(marker), b"\x05\x00"), critical=True)
        return b.sign(key if self_signed else self.ca_key, hashes.SHA256())


def p12(cert, key, password=PASSWORD, legacy=False, chain=None):
    if legacy:
        enc = (serialization.PrivateFormat.PKCS12.encryption_builder().kdf_rounds(2048)
               .key_cert_algorithm(pkcs12.PBES.PBESv1SHA1And3KeyTripleDESCBC).hmac_hash(hashes.SHA1()).build(password.encode()))
    else:
        enc = serialization.BestAvailableEncryption(password.encode())
    return pkcs12.serialize_key_and_certificates(b"Developer ID Application", key, cert, chain, enc)


def pem_private(key, fmt=serialization.PrivateFormat.PKCS8, enc=None):
    return key.private_bytes(serialization.Encoding.PEM, fmt, enc or serialization.NoEncryption())


def notary_key():
    if "notary" not in _keys:
        _keys["notary"] = ec.generate_private_key(ec.SECP256R1())
    return _keys["notary"]


def b64(data):
    return base64.b64encode(data).decode()


def leaf_names():
    return {
        "application": "Developer ID Application: Icy Tower Test (%s)" % TEAM,
        "installer": "Developer ID Installer: Icy Tower Test (%s)" % TEAM,
        "development": "Apple Development: Icy Tower Test (%s)" % TEAM,
        "distribution": "Apple Distribution: Icy Tower Test (%s)" % TEAM,
        "other-team": "Developer ID Application: Someone Else (%s)" % OTHER_TEAM,
    }


def good_env(authority):
    cert = authority.leaf(leaf_names()["application"])
    return {
        "MACOS_CERTIFICATE_P12_BASE64": b64(p12(cert, rsa_key("leaf"))),
        "MACOS_CERTIFICATE_PASSWORD": PASSWORD,
        "APPLE_NOTARY_KEY_BASE64": b64(pem_private(notary_key())),
        "APPLE_NOTARY_KEY_ID": KEY_ID,
        "APPLE_NOTARY_ISSUER_ID": ISSUER_ID,
        "APPLE_TEAM_ID": TEAM,
        "MACOS_BUNDLE_ID": BUNDLE_ID,
    }


def damaged_inside(data, password):
    """DATA (a PKCS#12) with one byte of its largest encrypted value changed and its MAC computed again with
    PASSWORD: the password is right, the contents are damaged."""
    sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "examples", "games",
                                    "icy-tower", "macos"))
    import credentials as c
    import hashlib
    import hmac
    authsafe, mac = c.pfx_structure(data)
    start = data.index(authsafe)
    candidates = []

    def walk(buf, s, e, base):
        for tag, a, b in c.children(buf, s, e):
            if tag & 0x20:
                walk(buf, a, b, base)
                continue
            if tag == 0x04:
                try:
                    if buf[a] == 0x30 and c.read_tlv(buf, a, b)[3] == b:
                        walk(buf, a, b, base)
                        continue
                except c.Malformed:
                    pass
            if tag in (0x04, 0x80) and b - a > 64:
                candidates.append((b - a, base + a))
    walk(authsafe, 0, len(authsafe), start)
    size, at = max(candidates)
    damaged = bytearray(data)
    damaged[at + size // 2] ^= 0x5A
    authsafe2 = bytes(damaged[start:start + len(authsafe)])
    hname, block = c.HASHES[mac["hash"]]
    key = c.pkcs12_kdf(hname, block, password, mac["salt"], 3, mac["iterations"], hashlib.new(hname).digest_size)
    digest = hmac.new(key, authsafe2, hname).digest()
    j = bytes(damaged).index(mac["digest"])
    damaged[j:j + len(digest)] = digest
    return bytes(damaged)


def dry_run(directory):
    a = Authority()
    a.write(os.path.join(directory, "anchors"))
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    cert = a.leaf("Developer ID Application: Icy Tower Dry Run (DRYRUN0000)", team="DRYRUN0000", key=key)
    password = uuid.uuid4().hex
    env = {
        "MACOS_CERTIFICATE_P12_BASE64": b64(p12(cert, key, password, legacy=True)),
        "MACOS_CERTIFICATE_PASSWORD": password,
        "APPLE_NOTARY_KEY_BASE64": b64(pem_private(ec.generate_private_key(ec.SECP256R1()))),
        "APPLE_NOTARY_KEY_ID": "DRYRUN0000",
        "APPLE_NOTARY_ISSUER_ID": str(uuid.uuid4()),
        "APPLE_TEAM_ID": "DRYRUN0000",
        "MACOS_BUNDLE_ID": BUNDLE_ID + ".dry-run",
    }
    with open(os.path.join(directory, "env"), "w") as f:
        for k, v in env.items():
            f.write("%s=%s\n" % (k, v))
    print("dry-run identity: %s (a throwaway test certificate, never Apple's); %s/env, %s/anchors"
          % ("Developer ID Application: Icy Tower Dry Run (DRYRUN0000)", directory, directory))


if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] != "dry-run":
        sys.exit("usage: fixtures.py dry-run DIR")
    dry_run(sys.argv[2])

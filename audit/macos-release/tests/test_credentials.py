#!/usr/bin/env python3
"""test_credentials.py -- the credential preflight against synthetic
credentials (ICY-TOWER-MACOS-APP-MILESTONE-1.md, "Credential negative
tests"):

    python3 -I audit/macos-release/tests/test_credentials.py [-v]

Each negative case changes one thing of a valid synthetic configuration
-- the mistakes a developer makes entering the seven GitHub values -- and
runs credentials.py check as the release runs it (a process, the values
in its environment). Each must exit 1 with the expected stable code, name
the offending variable, carry a remedy, print no part of any secret, and
write nothing (no decoded file: nothing a signing or notarization step
could go on with). The positive cases pass every local check under the
test trust anchors, and the same identity is refused under Apple's.
"""
import base64
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, os.path.join(HERE, "..", "tools"))
import fixtures as fx  # noqa: E402
from cryptography.hazmat.primitives import serialization  # noqa: E402
from cryptography.hazmat.primitives.asymmetric import ec, ed25519, rsa  # noqa: E402

CREDENTIALS = os.path.join(ROOT, "examples", "games", "icy-tower", "macos", "credentials.py")
AUTHORITY = fx.Authority()
NAMES = fx.leaf_names()


def windows(value, size=16):
    """Every SIZE-character piece of VALUE: none may appear in any output."""
    value = value.replace("\n", "")
    if len(value) <= size:
        return [value] if len(value) >= 6 else []
    return [value[i:i + size] for i in range(0, len(value) - size + 1, 4)]


def pem_lines(env):
    out = []
    try:
        text = base64.b64decode(env.get("APPLE_NOTARY_KEY_BASE64", ""), validate=False).decode("utf-8", "replace")
    except Exception:
        return out
    for line in text.splitlines():
        if len(line) >= 16 and not line.startswith("-----"):
            out.append(line)
    return out


class Preflight(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.mkdtemp(prefix="creds-test.")
        cls.anchors = os.path.join(cls.tmp, "anchors")
        AUTHORITY.write(cls.anchors)

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(cls.tmp, ignore_errors=True)

    def run_check(self, env, anchors=True):
        out = tempfile.mkdtemp(dir=self.tmp)
        shutil.rmtree(out)
        cmd = [sys.executable, "-I", CREDENTIALS, "check", "--out", out]
        if anchors:
            cmd += ["--trust-anchors", self.anchors]
        clean = {k: v for k, v in os.environ.items() if not k.startswith(("MACOS_", "APPLE_"))}
        clean.update(env)
        r = subprocess.run(cmd, env=clean, capture_output=True, text=True, timeout=120)
        return r.returncode, r.stdout + r.stderr, out

    def assertNoSecrets(self, env, output):
        for name in ("MACOS_CERTIFICATE_P12_BASE64", "APPLE_NOTARY_KEY_BASE64", "MACOS_CERTIFICATE_PASSWORD"):
            v = env.get(name) or ""
            for piece in windows(v):
                self.assertNotIn(piece, output, "a piece of %s was printed" % name)
        for line in pem_lines(env):
            self.assertNotIn(line, output, "a line of the private key was printed")
        self.assertNotIn("PRIVATE KEY-----\n", output)

    def refused(self, env, code, variable, text=None, anchors=True):
        status, output, out = self.run_check(env, anchors)
        self.assertEqual(status, 1, output)
        self.assertIn(code + ":", output)
        self.assertRegex(output, r"%s: %s\b" % (re.escape(code), re.escape(variable)) if variable else re.escape(code))
        if text:
            self.assertRegex(output, text)
        self.assertRegex(output, r"\n    \S", "no remedy")
        self.assertNoSecrets(env, output)
        self.assertFalse(os.path.exists(os.path.join(out, "identity.p12")), "a decoded file was written")
        self.assertFalse(os.path.exists(os.path.join(out, "notary-key.p8")), "a decoded file was written")
        return output

    def env(self, **changes):
        e = fx.good_env(AUTHORITY)
        for k, v in changes.items():
            if v is None:
                e.pop(k, None)
            else:
                e[k] = v
        return e

    def p12_env(self, data, **more):
        return self.env(MACOS_CERTIFICATE_P12_BASE64=fx.b64(data), **more)

    # --- positive -------------------------------------------------------------

    def test_valid_synthetic_passes_every_local_check(self):
        env = self.env()
        status, output, out = self.run_check(env)
        self.assertEqual(status, 0, output)
        self.assertIn("Developer ID Application: Icy Tower Test (TEST123456)", output)
        self.assertIn("EC P-256", output)
        self.assertNoSecrets(env, output)
        import json
        with open(os.path.join(out, "identity.json")) as f:
            facts = json.load(f)
        self.assertEqual(facts["anchors"], "test")
        self.assertEqual(facts["identity"]["team"], fx.TEAM)
        self.assertEqual(oct(os.stat(out).st_mode & 0o777), "0o700")
        for n in ("identity.p12", "notary-key.p8"):
            self.assertEqual(oct(os.stat(os.path.join(out, n)).st_mode & 0o777), "0o600")
        with open(os.path.join(out, "identity.json")) as f:
            self.assertNotIn(fx.PASSWORD, f.read())

    def test_legacy_keychain_export_passes(self):
        cert = AUTHORITY.leaf(NAMES["application"])
        status, output, _ = self.run_check(self.p12_env(fx.p12(cert, fx.rsa_key("leaf"), legacy=True)))
        self.assertEqual(status, 0, output)

    def test_wrapped_base64_accepted(self):
        env = self.env()
        v = env["MACOS_CERTIFICATE_P12_BASE64"]
        env["MACOS_CERTIFICATE_P12_BASE64"] = "\n".join(v[i:i + 76] for i in range(0, len(v), 76)) + "\n"
        status, output, _ = self.run_check(env)
        self.assertEqual(status, 0, output)

    def test_synthetic_identity_refused_under_apple_anchors(self):
        # Generic PKCS#12 success is not Developer ID acceptance.
        self.refused(self.env(), "MACOS-CERTIFICATE-IDENTITY", "MACOS_CERTIFICATE_P12_BASE64",
                     r"not issued by Apple's Developer ID Certification Authority", anchors=False)

    def test_self_signed_refused(self):
        key = fx.rsa_key("self")
        cert = AUTHORITY.leaf(NAMES["application"], key=key, self_signed=True)
        self.refused(self.p12_env(fx.p12(cert, key)), "MACOS-CERTIFICATE-IDENTITY", "MACOS_CERTIFICATE_P12_BASE64",
                     r"not issued by Apple's Developer ID")

    # --- presence -------------------------------------------------------------

    def test_missing_p12(self):
        self.refused(self.env(MACOS_CERTIFICATE_P12_BASE64=None), "MACOS-CONFIG-MISSING", "MACOS_CERTIFICATE_P12_BASE64", "is not set")

    def test_empty_p12(self):
        self.refused(self.env(MACOS_CERTIFICATE_P12_BASE64=""), "MACOS-CONFIG-MISSING", "MACOS_CERTIFICATE_P12_BASE64", "empty credential")

    def test_missing_p8(self):
        self.refused(self.env(APPLE_NOTARY_KEY_BASE64=None), "MACOS-CONFIG-MISSING", "APPLE_NOTARY_KEY_BASE64")

    def test_every_missing_value_named(self):
        output = self.refused({}, "MACOS-CONFIG-MISSING", "APPLE_TEAM_ID")
        for name in ("MACOS_CERTIFICATE_P12_BASE64", "MACOS_CERTIFICATE_PASSWORD", "APPLE_NOTARY_KEY_BASE64",
                     "APPLE_NOTARY_KEY_ID", "APPLE_NOTARY_ISSUER_ID", "MACOS_BUNDLE_ID"):
            self.assertIn("MACOS-CONFIG-MISSING: %s" % name, output)

    # --- Base64 -----------------------------------------------------------------

    def test_invalid_base64_character(self):
        v = fx.good_env(AUTHORITY)["MACOS_CERTIFICATE_P12_BASE64"]
        self.refused(self.env(MACOS_CERTIFICATE_P12_BASE64=v[:40] + "#" + v[41:]), "MACOS-CREDENTIAL-BASE64",
                     "MACOS_CERTIFICATE_P12_BASE64", r"not valid Base64")

    def test_invalid_base64_padding(self):
        v = fx.good_env(AUTHORITY)["MACOS_CERTIFICATE_P12_BASE64"].rstrip("=")
        if len(v) % 4 == 0:
            v = v[:-1]
        self.refused(self.env(MACOS_CERTIFICATE_P12_BASE64=v), "MACOS-CREDENTIAL-BASE64", "MACOS_CERTIFICATE_P12_BASE64", r"padding")

    def test_url_safe_alphabet(self):
        v = fx.good_env(AUTHORITY)["MACOS_CERTIFICATE_P12_BASE64"].replace("+", "-").replace("/", "_")
        self.refused(self.env(MACOS_CERTIFICATE_P12_BASE64=v), "MACOS-CREDENTIAL-BASE64", "MACOS_CERTIFICATE_P12_BASE64", r"URL-safe")

    def test_path_instead_of_base64(self):
        self.refused(self.env(MACOS_CERTIFICATE_P12_BASE64="/Users/me/Desktop/DeveloperIDApplication.p12"),
                     "MACOS-CREDENTIAL-BASE64", "MACOS_CERTIFICATE_P12_BASE64", r"file name or path")

    def test_command_instead_of_output(self):
        self.refused(self.env(APPLE_NOTARY_KEY_BASE64="base64 < AuthKey_ABCDE12345.p8 | tr -d '\\n'"),
                     "MACOS-CREDENTIAL-BASE64", "APPLE_NOTARY_KEY_BASE64", r"shell command")

    def test_raw_pem_instead_of_base64(self):
        pem = fx.pem_private(fx.notary_key()).decode()
        self.refused(self.env(APPLE_NOTARY_KEY_BASE64=pem), "MACOS-CREDENTIAL-BASE64", "APPLE_NOTARY_KEY_BASE64", r"PEM text itself")

    # --- the .p12 ---------------------------------------------------------------

    def test_base64_of_text_file(self):
        self.refused(self.p12_env(b"My Developer ID certificate, exported 2026-10-30\nKeep it safe.\n"),
                     "MACOS-CREDENTIAL-FORMAT", "MACOS_CERTIFICATE_P12_BASE64", r"decoded to text")

    def test_base64_of_path_string(self):
        self.refused(self.p12_env(b"/Users/me/Desktop/DeveloperIDApplication.p12"), "MACOS-CREDENTIAL-FORMAT",
                     "MACOS_CERTIFICATE_P12_BASE64", r"file name or path")

    def test_base64_of_pem_certificate(self):
        cert = AUTHORITY.leaf(NAMES["application"])
        self.refused(self.p12_env(cert.public_bytes(serialization.Encoding.PEM)), "MACOS-CREDENTIAL-FORMAT",
                     "MACOS_CERTIFICATE_P12_BASE64", r"decoded to a PEM certificate, not a binary PKCS#12 container")

    def test_double_encoded_p12(self):
        once = fx.good_env(AUTHORITY)["MACOS_CERTIFICATE_P12_BASE64"].encode()
        self.refused(self.p12_env(once), "MACOS-CREDENTIAL-FORMAT", "MACOS_CERTIFICATE_P12_BASE64", r"encoded twice")

    def test_truncated_p12(self):
        data = base64.b64decode(fx.good_env(AUTHORITY)["MACOS_CERTIFICATE_P12_BASE64"])
        self.refused(self.p12_env(data[:len(data) // 2]), "MACOS-CREDENTIAL-FORMAT", "MACOS_CERTIFICATE_P12_BASE64",
                     r"not a PKCS#12 container \(\.p12\): truncated")

    def test_trailing_data_after_p12(self):
        data = base64.b64decode(fx.good_env(AUTHORITY)["MACOS_CERTIFICATE_P12_BASE64"])
        self.refused(self.p12_env(data + b"\0" * 8), "MACOS-CREDENTIAL-FORMAT", "MACOS_CERTIFICATE_P12_BASE64", r"unexpected data")

    def test_wrong_password(self):
        output = self.refused(self.env(MACOS_CERTIFICATE_PASSWORD="not the password"), "MACOS-CERTIFICATE-DECRYPT",
                              "MACOS_CERTIFICATE_P12_BASE64", r"password may be wrong, or the exported file may be damaged")
        self.assertNotIn("not the password", output)

    def test_password_with_trailing_newline(self):
        self.refused(self.env(MACOS_CERTIFICATE_PASSWORD=fx.PASSWORD + "\n"), "MACOS-CERTIFICATE-DECRYPT",
                     "MACOS_CERTIFICATE_P12_BASE64", r"ends with white space or a line break")

    def test_damaged_contents_right_password(self):
        cert = AUTHORITY.leaf(NAMES["application"])
        data = fx.damaged_inside(fx.p12(cert, fx.rsa_key("leaf")), fx.PASSWORD)
        self.refused(self.p12_env(data), "MACOS-CERTIFICATE-DECRYPT", "MACOS_CERTIFICATE_P12_BASE64", r"the password is right")

    def test_certificate_only(self):
        cert = AUTHORITY.leaf(NAMES["application"])
        data = serialization.pkcs12.serialize_key_and_certificates(b"x", None, cert, None,
                                                                   serialization.BestAvailableEncryption(fx.PASSWORD.encode()))
        self.refused(self.p12_env(data), "MACOS-CERTIFICATE-IDENTITY", "MACOS_CERTIFICATE_P12_BASE64", r"no private key")

    def test_unrelated_key_and_certificate(self):
        cert = AUTHORITY.leaf(NAMES["application"])
        data = serialization.pkcs12.serialize_key_and_certificates(b"x", fx.rsa_key("unrelated"), None, [cert],
                                                                   serialization.BestAvailableEncryption(fx.PASSWORD.encode()))
        self.refused(self.p12_env(data), "MACOS-CERTIFICATE-IDENTITY",
                     "MACOS_CERTIFICATE_P12_BASE64", r"does not match its certificate")

    def test_expired_certificate(self):
        cert = AUTHORITY.leaf(NAMES["application"], expired=True)
        self.refused(self.p12_env(fx.p12(cert, fx.rsa_key("leaf"))), "MACOS-CERTIFICATE-IDENTITY",
                     "MACOS_CERTIFICATE_P12_BASE64", r"expired on")

    def test_developer_id_installer(self):
        cert = AUTHORITY.leaf(NAMES["installer"], marker=fx.INSTALLER)
        self.refused(self.p12_env(fx.p12(cert, fx.rsa_key("leaf"))), "MACOS-CERTIFICATE-IDENTITY",
                     "MACOS_CERTIFICATE_P12_BASE64", r"Developer ID Installer certificate")

    def test_apple_development(self):
        cert = AUTHORITY.leaf(NAMES["development"], marker=fx.DEVELOPMENT)
        self.refused(self.p12_env(fx.p12(cert, fx.rsa_key("leaf"))), "MACOS-CERTIFICATE-IDENTITY",
                     "MACOS_CERTIFICATE_P12_BASE64", r"Apple Development certificate")

    def test_apple_distribution(self):
        cert = AUTHORITY.leaf(NAMES["distribution"], marker=fx.DISTRIBUTION)
        self.refused(self.p12_env(fx.p12(cert, fx.rsa_key("leaf"))), "MACOS-CERTIFICATE-IDENTITY",
                     "MACOS_CERTIFICATE_P12_BASE64", r"Apple Distribution certificate")

    def test_name_without_apple_marker(self):
        cert = AUTHORITY.leaf(NAMES["application"], marker=None)
        self.refused(self.p12_env(fx.p12(cert, fx.rsa_key("leaf"))), "MACOS-CERTIFICATE-IDENTITY",
                     "MACOS_CERTIFICATE_P12_BASE64", r"without Apple's Developer ID Application extension")

    def test_no_code_signing_usage(self):
        cert = AUTHORITY.leaf(NAMES["application"], codesign=False)
        self.refused(self.p12_env(fx.p12(cert, fx.rsa_key("leaf"))), "MACOS-CERTIFICATE-IDENTITY",
                     "MACOS_CERTIFICATE_P12_BASE64", r"does not include code signing")

    def test_team_mismatch(self):
        self.refused(self.env(APPLE_TEAM_ID=fx.OTHER_TEAM), "MACOS-TEAM-MISMATCH", "APPLE_TEAM_ID", r"TEST123456's")

    def test_other_teams_certificate(self):
        cert = AUTHORITY.leaf(NAMES["other-team"], team=fx.OTHER_TEAM)
        self.refused(self.p12_env(fx.p12(cert, fx.rsa_key("leaf"))), "MACOS-TEAM-MISMATCH", "APPLE_TEAM_ID", r"OTHER98765")

    # --- the .p8 ----------------------------------------------------------------

    def p8_env(self, text):
        return self.env(APPLE_NOTARY_KEY_BASE64=fx.b64(text if isinstance(text, bytes) else text.encode()))

    def test_double_encoded_p8(self):
        self.refused(self.p8_env(fx.good_env(AUTHORITY)["APPLE_NOTARY_KEY_BASE64"]), "MACOS-NOTARY-KEY-FORMAT",
                     "APPLE_NOTARY_KEY_BASE64", r"encoded twice")

    def test_truncated_pem(self):
        pem = fx.pem_private(fx.notary_key()).decode()
        self.refused(self.p8_env(pem[:pem.index("-----END")]), "MACOS-NOTARY-KEY-FORMAT", "APPLE_NOTARY_KEY_BASE64", r"truncated PEM")

    def test_damaged_pem_body(self):
        pem = fx.pem_private(fx.notary_key()).decode()
        lines = pem.splitlines()
        lines[1] = lines[1][:-3]
        self.refused(self.p8_env("\n".join(lines) + "\n"), "MACOS-NOTARY-KEY-FORMAT", "APPLE_NOTARY_KEY_BASE64", r"not valid Base64|not a well-formed")

    def test_literal_backslash_n(self):
        pem = fx.pem_private(fx.notary_key()).decode()
        self.refused(self.p8_env(pem.strip().replace("\n", "\\n")), "MACOS-NOTARY-KEY-FORMAT", "APPLE_NOTARY_KEY_BASE64",
                     r"literal \\n sequences instead of line breaks")

    def test_crlf_accepted(self):
        pem = fx.pem_private(fx.notary_key()).decode()
        status, output, _ = self.run_check(self.p8_env(pem.replace("\n", "\r\n")))
        self.assertEqual(status, 0, output)

    def test_public_key(self):
        pub = fx.notary_key().public_key().public_bytes(serialization.Encoding.PEM, serialization.PublicFormat.SubjectPublicKeyInfo)
        self.refused(self.p8_env(pub), "MACOS-NOTARY-KEY-FORMAT", "APPLE_NOTARY_KEY_BASE64", r"public key, not the private key")

    def test_rsa_key(self):
        self.refused(self.p8_env(fx.pem_private(fx.rsa_key("leaf"))), "MACOS-NOTARY-KEY-FORMAT", "APPLE_NOTARY_KEY_BASE64",
                     r"RSA key: wrong key algorithm")

    def test_ed25519_key(self):
        self.refused(self.p8_env(fx.pem_private(ed25519.Ed25519PrivateKey.generate())), "MACOS-NOTARY-KEY-FORMAT",
                     "APPLE_NOTARY_KEY_BASE64", r"wrong key algorithm")

    def test_wrong_curve(self):
        self.refused(self.p8_env(fx.pem_private(ec.generate_private_key(ec.SECP384R1()))), "MACOS-NOTARY-KEY-FORMAT",
                     "APPLE_NOTARY_KEY_BASE64", r"secp384r1 curve: wrong curve")

    def test_sec1_container(self):
        sec1 = fx.pem_private(fx.notary_key(), serialization.PrivateFormat.TraditionalOpenSSL)
        self.refused(self.p8_env(sec1), "MACOS-NOTARY-KEY-FORMAT", "APPLE_NOTARY_KEY_BASE64",
                     r"EC private key but is not the expected PKCS#8 PEM \.p8 format")

    def test_encrypted_key(self):
        enc = fx.pem_private(fx.notary_key(), enc=serialization.BestAvailableEncryption(b"x"))
        self.refused(self.p8_env(enc), "MACOS-NOTARY-KEY-FORMAT", "APPLE_NOTARY_KEY_BASE64", r"encrypted private key")

    def test_extra_pem_block(self):
        pem = fx.pem_private(fx.notary_key()).decode()
        cert = AUTHORITY.leaf(NAMES["application"]).public_bytes(serialization.Encoding.PEM).decode()
        self.refused(self.p8_env(pem + cert), "MACOS-NOTARY-KEY-FORMAT", "APPLE_NOTARY_KEY_BASE64", r"2 PEM blocks")

    def test_extra_text(self):
        pem = fx.pem_private(fx.notary_key()).decode()
        self.refused(self.p8_env("Key for notarization:\n" + pem), "MACOS-NOTARY-KEY-FORMAT", "APPLE_NOTARY_KEY_BASE64",
                     r"unexpected text")

    def test_certificate_in_p8_slot(self):
        cert = AUTHORITY.leaf(NAMES["application"]).public_bytes(serialization.Encoding.PEM)
        self.refused(self.p8_env(cert), "MACOS-NOTARY-KEY-FORMAT", "APPLE_NOTARY_KEY_BASE64", r"certificate, not the notarization")

    def test_p12_in_p8_slot(self):
        data = base64.b64decode(fx.good_env(AUTHORITY)["MACOS_CERTIFICATE_P12_BASE64"])
        self.refused(self.p8_env(data), "MACOS-NOTARY-KEY-FORMAT", "APPLE_NOTARY_KEY_BASE64", r"PKCS#12 container")

    # --- identifiers ------------------------------------------------------------

    def test_malformed_key_id(self):
        self.refused(self.env(APPLE_NOTARY_KEY_ID="abc 123"), "MACOS-NOTARY-CONFIG", "APPLE_NOTARY_KEY_ID", r"not a Key ID")

    def test_key_id_file_name(self):
        self.refused(self.env(APPLE_NOTARY_KEY_ID="AuthKey_ABCDE12345.p8"), "MACOS-NOTARY-CONFIG", "APPLE_NOTARY_KEY_ID",
                     r"file name, not its Key ID")

    def test_key_id_quoted(self):
        self.refused(self.env(APPLE_NOTARY_KEY_ID='"ABCDE12345"'), "MACOS-NOTARY-CONFIG", "APPLE_NOTARY_KEY_ID", r"quoted")

    def test_malformed_issuer(self):
        self.refused(self.env(APPLE_NOTARY_ISSUER_ID="57246542-96fe-1a63-e053"), "MACOS-NOTARY-CONFIG",
                     "APPLE_NOTARY_ISSUER_ID", r"not a valid UUID")

    def test_issuer_in_braces(self):
        self.refused(self.env(APPLE_NOTARY_ISSUER_ID="{%s}" % fx.ISSUER_ID), "MACOS-NOTARY-CONFIG", "APPLE_NOTARY_ISSUER_ID", r"braces")

    def test_issuer_with_line_break(self):
        self.refused(self.env(APPLE_NOTARY_ISSUER_ID=fx.ISSUER_ID + "\n"), "MACOS-NOTARY-CONFIG", "APPLE_NOTARY_ISSUER_ID",
                     r"line break")

    def test_malformed_team_id(self):
        self.refused(self.env(APPLE_TEAM_ID="TEST12"), "MACOS-NOTARY-CONFIG", "APPLE_TEAM_ID", r"not a Team ID")

    def test_invalid_bundle_id(self):
        self.refused(self.env(MACOS_BUNDLE_ID="icy tower"), "MACOS-BUNDLE-METADATA", "", r"MACOS_BUNDLE_ID holds a space")

    def test_bundle_id_with_path(self):
        self.refused(self.env(MACOS_BUNDLE_ID="com.example/icy-tower"), "MACOS-BUNDLE-METADATA", "", r"path separator")

    def test_bundle_id_one_component(self):
        self.refused(self.env(MACOS_BUNDLE_ID="icytower"), "MACOS-BUNDLE-METADATA", "", r"reverse-DNS")

    def test_independent_problems_all_reported(self):
        output = self.refused(self.env(APPLE_NOTARY_KEY_ID="x", APPLE_NOTARY_ISSUER_ID="y", MACOS_CERTIFICATE_PASSWORD="z"),
                              "MACOS-NOTARY-CONFIG", "APPLE_NOTARY_KEY_ID")
        self.assertIn("MACOS-NOTARY-CONFIG: APPLE_NOTARY_ISSUER_ID", output)
        self.assertIn("MACOS-CERTIFICATE-DECRYPT", output)


class ApplePins(unittest.TestCase):
    def test_committed_apple_certificates(self):
        sys.path.insert(0, os.path.dirname(CREDENTIALS))
        import credentials
        root, intermediates = credentials.load_anchors()
        self.assertEqual(credentials.cn(root), "Apple Root CA")
        self.assertEqual(sorted(credentials.cn(c) for c in intermediates.values()),
                         ["Developer ID Certification Authority"] * 2)


if __name__ == "__main__":
    unittest.main()

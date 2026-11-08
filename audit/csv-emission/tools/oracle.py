#!/usr/bin/env python3
"""oracle.py -- the CSV emitters' outputs judged without Botlish
(CSV-EMISSION-VALIDATION-MILESTONE-1.md, sections 9, 10 and 14).

Nothing here reads a Botlish file: the profiles are restated from RFC 4180
and the milestone's Profile B policy, the parser is written from the ABNF,
and CPython's csv module is the established second opinion.

    python3 -I oracle.py check LINES ?--all?   every line of LINES (run.tcl's
                                           csvrun::write), judged; a summary
                                           on stdout (and the first 40
                                           failures, or --all), exit 1 on
                                           any failure
    python3 -I oracle.py export FILE       FILE as examples/dfa/csv/export.bot
                                           writes its table: strict UTF-8, no
                                           byte-order mark, the strict parser
                                           and csv.reader reading exactly the
                                           table, csv.writer (QUOTE_ALL, CRLF)
                                           writing exactly FILE
    python3 -I oracle.py selftest          the parser and the csv module on
                                           hand-written documents, valid and
                                           malformed; their disagreements
                                           listed (exit 1 when the strict
                                           parser itself is wrong)

For a completed run the oracle checks, independently:

  * expected   the run should have completed (no character outside the
               profile), with the final value the source returns;
  * reference  the output equals the reference serialization of the input,
               written here from the policy (always-quoted or selective;
               CRLF after every record, or between records), symbol for
               symbol;
  * strict     the strict parser of the profile reads the output back as
               exactly the input's records and fields;
  * csvmodule  csv.reader reads it back as the input (documents and
               fields); for the always-quoted kinds csv.writer with
               QUOTE_ALL and CRLF writes the same text;
  * utf8       a bytes output decodes as strict UTF-8 (Python's codec: no
               overlong form, no surrogate) and starts with no byte-order
               mark.

For a failed run:

  * expected   the input holds a character the profile cannot represent,
               and the failure names the first one (its index in its
               field and its value), or the input bytes are not UTF-8;
  * prefix     the partial output equals the reference serialization of
               everything before that character -- a viable prefix, never
               a complete document: the strict parser refuses it.
"""

import csv
import io
import sys

# ---------------------------------------------------------------------------
# Profiles, restated from RFC 4180 and the milestone's policy


def a_text(c):
    """RFC 4180 TEXTDATA = %x20-21 / %x23-2B / %x2D-7E."""
    o = ord(c)
    return 0x20 <= o <= 0x7E and o not in (0x22, 0x2C)


def a_quoted(c):
    """What an escaped field holds raw: TEXTDATA, COMMA, CR, LF."""
    return a_text(c) or c in ",\r\n"


def b_text(c):
    """Profile B: printable ASCII but '"' and ',', and every scalar from
    U+00A0 on but U+2028, U+2029 and U+FEFF."""
    o = ord(c)
    if 0xD800 <= o <= 0xDFFF:
        return False
    if o < 0x80:
        return a_text(c)
    return o >= 0xA0 and o not in (0x2028, 0x2029, 0xFEFF)


def b_quoted(c):
    """Profile B's quoted data: text, and ',', CR, LF, TAB, U+2028,
    U+2029, U+FEFF."""
    return b_text(c) or c in ",\r\n\t  ﻿"


PROFILES = {"A": (a_text, a_quoted), "B": (b_text, b_quoted)}

# KIND -> (profile, encoding, shape, policy)
#   encoding  scalar (one symbol per scalar value) or bytes (UTF-8)
#   shape     document (header + rows), rows, unterminated, field, frombytes
#   policy    quoted (always) or selective
KINDS = {
    "strict_document": ("A", "scalar", "document", "quoted"),
    "utf8_document": ("B", "scalar", "document", "quoted"),
    "bytes_document": ("B", "bytes", "document", "quoted"),
    "bytes_stream": ("B", "bytes", "rows", "quoted"),
    "bytes_unterminated": ("B", "bytes", "unterminated", "quoted"),
    "selective_document": ("B", "scalar", "document", "selective"),
    "selective_strict_document": ("A", "scalar", "document", "selective"),
    "strict_field": ("A", "scalar", "field", "quoted"),
    "utf8_field": ("B", "scalar", "field", "quoted"),
    "bytes_field": ("B", "bytes", "field", "quoted"),
    "selective_field": ("B", "scalar", "field", "selective"),
    "bytes_from_bytes": ("B", "bytes", "frombytes", "quoted"),
}

# ---------------------------------------------------------------------------
# The reference serialization (the policy, written from its statement)


def quote(v):
    return '"' + v.replace('"', '""') + '"'


def field_text(v, profile, policy):
    text, _ = PROFILES[profile]
    if policy == "selective" and v != "" and all(text(c) for c in v):
        return v
    return quote(v)


def serialize(records, profile, policy, terminated=True):
    lines = [",".join(field_text(f, profile, policy) for f in r) for r in records]
    if terminated:
        return "".join(line + "\r\n" for line in lines)
    return "\r\n".join(lines)


def first_unsupported(fields, profile):
    """(field number, index, value) of the first character no field of the
    profile can hold, in writing order, or None."""
    _, quoted = PROFILES[profile]
    for k, v in enumerate(fields):
        for i, c in enumerate(v):
            if c != '"' and not quoted(c):
                return k, i, ord(c)
    return None


# ---------------------------------------------------------------------------
# The strict parser, written from RFC 4180's ABNF and the profile


class Malformed(Exception):
    pass


def parse_field(s, i, profile):
    """(value, next index, quoted?) of the field at I."""
    text, quoted = PROFILES[profile]
    n = len(s)
    if i < n and s[i] == '"':
        i += 1
        out = []
        while True:
            if i >= n:
                raise Malformed("unterminated quoted field")
            c = s[i]
            if c == '"':
                if i + 1 < n and s[i + 1] == '"':
                    out.append('"')
                    i += 2
                    continue
                i += 1
                break
            if not quoted(c):
                raise Malformed("character U+%04X in a quoted field" % ord(c))
            out.append(c)
            i += 1
        if i < n and s[i] not in ",\r":
            raise Malformed("U+%04X after a closing quotation mark" % ord(s[i]))
        return "".join(out), i, True
    start = i
    while i < n and s[i] not in ",\r":
        if not text(s[i]):
            raise Malformed("character U+%04X in an unquoted field" % ord(s[i]))
        i += 1
    return s[start:i], i, False


def parse_document(s, profile, width=3):
    """The records of S: CRLF between records, the last one's optional; the
    empty text is no record. Raises Malformed."""
    if s.startswith("﻿"):
        raise Malformed("a byte-order mark")
    records = []
    n = len(s)
    i = 0
    if n == 0:
        return records
    while True:
        record = []
        while True:
            value, i, _ = parse_field(s, i, profile)
            record.append(value)
            if i < n and s[i] == ",":
                i += 1
                continue
            break
        if len(record) != width:
            raise Malformed("a record of %d fields" % len(record))
        records.append(record)
        if i == n:
            return records
        if s[i:i + 2] != "\r\n":
            raise Malformed("U+%04X where a record ends" % ord(s[i]))
        i += 2
        if i == n:
            return records


def parse_one_field(s, profile, require_quoted):
    value, i, was_quoted = parse_field(s, 0, profile)
    if i != len(s):
        raise Malformed("text after the field")
    if require_quoted and not was_quoted:
        raise Malformed("an unquoted field")
    if not was_quoted and value == "":
        raise Malformed("an empty field is no token")
    return value


def csv_rows(text):
    return list(csv.reader(io.StringIO(text, newline=""), delimiter=",", quotechar='"',
                           doublequote=True, strict=True))


def csv_quote_all(records):
    buf = io.StringIO(newline="")
    w = csv.writer(buf, quoting=csv.QUOTE_ALL, lineterminator="\r\n")
    w.writerows(records)
    return buf.getvalue()


# ---------------------------------------------------------------------------
# One line


def decode_input(kind, enc):
    shape = KINDS[kind][2]
    if shape in ("document", "rows", "unterminated"):
        rows = []
        if enc != "":
            for row in enc.split("|"):
                rows.append(["".join(chr(int(x)) for x in f.split()) for f in row.split(";")])
        return rows
    if shape == "frombytes":
        return bytes(int(x) for x in enc.split())
    return "".join(chr(int(x)) for x in enc.split())


def to_text(symbols, encoding):
    """The output as text: scalar symbols are characters; bytes are decoded
    strictly (UnicodeDecodeError when not UTF-8)."""
    if encoding == "scalar":
        return "".join(chr(x) for x in symbols)
    return bytes(symbols).decode("utf-8", errors="strict")


def to_symbols(text, encoding):
    if encoding == "scalar":
        return [ord(c) for c in text]
    return list(text.encode("utf-8"))


def judge(kind, enc, outcome, symbols):
    """{CHECK: ok | message} for one line."""
    profile, encoding, shape, policy = KINDS[kind]
    status, at, value, final = outcome.split()
    at, value, final = int(at), int(value), int(final)
    data = decode_input(kind, enc)
    results = {}

    # What the run should have been
    if shape == "frombytes":
        try:
            text_input = data.decode("utf-8", errors="strict")
        except UnicodeDecodeError:
            results["expected"] = "ok" if status == "invalid-utf8" and symbols == [] else \
                "input is not UTF-8, but the run was %s" % status
            return results
        data = text_input
    if shape == "field" or shape == "frombytes":
        records = None
        fields = [data]
    else:
        records = data
        fields = [f for r in records for f in r]
    bad = first_unsupported(fields, profile)
    terminated = shape != "unterminated"
    field_policy = policy

    def reference(upto=None):
        """The reference output; with UPTO=(field number, index), what is
        written before that character."""
        if records is None:
            ref = field_text(data, profile, field_policy)
            if upto is not None:
                k, i = upto
                return quote(data[:i])[:-1]
            return ref
        if upto is None:
            return serialize(records, profile, field_policy, terminated)
        k, i = upto
        out = []
        n = 0
        for r_index, r in enumerate(records):
            if shape == "unterminated" and r_index > 0:
                out.append("\r\n")
            for f_index, f in enumerate(r):
                if f_index > 0:
                    out.append(",")
                if n == k:
                    out.append(quote(f[:i])[:-1])
                    return "".join(out)
                out.append(field_text(f, profile, field_policy))
                n += 1
            if terminated:
                out.append("\r\n")
        raise AssertionError("unreachable")

    if bad is not None:
        k, i, v = bad
        if status == "quoting":
            # Stopped by another guard, with another declared error: nothing
            # wrong was written, but the error is not the profile's.
            results["expected"] = "guard: input has U+%04X at %d of field %d: expected unsupported, the run failed %s %d %d" % (
                v, i, k, status, at, value)
            return results
        if status != "unsupported" or at != i or value != v:
            results["expected"] = "input has U+%04X at %d of field %d: expected unsupported, got %s %d %d" % (
                v, i, k, status, at, value)
            return results
        results["expected"] = "ok"
        prefix = reference((k, i))
        results["prefix"] = "ok" if symbols == to_symbols(prefix, encoding) else \
            "partial output %r is not the reference prefix %r" % (symbols[:80], prefix[:80])
        # Never a complete document (or field).
        try:
            text = to_text(symbols, encoding)
        except UnicodeDecodeError:
            results["incomplete"] = "the partial output is not even UTF-8"
            return results
        try:
            if records is None:
                parse_one_field(text, profile, policy == "quoted")
            else:
                parse_document(text, profile)
            results["incomplete"] = "the partial output %r parses as complete" % text[:80]
        except Malformed:
            results["incomplete"] = "ok"
        return results

    if status != "ok":
        results["expected"] = "guard: input is representable, but the run was %s %d %d" % (status, at, value)
        return results
    expect_final = {"document": None, "rows": None, "unterminated": None}
    if records is None:
        want = len(data) if shape == "field" else 0
    elif shape == "document":
        want = len(records)
    else:
        want = len(records)
    results["expected"] = "ok" if final == want else "final: final value %d, expected %d" % (final, want)
    ref = reference()
    results["reference"] = "ok" if symbols == to_symbols(ref, encoding) else \
        "output differs from the reference %r" % ref[:80]
    try:
        text = to_text(symbols, encoding)
    except UnicodeDecodeError as e:
        results["utf8"] = "not strict UTF-8: %s" % e
        return results
    if encoding == "bytes":
        results["utf8"] = "ok" if not text.startswith("﻿") else "starts with a byte-order mark"
    try:
        if records is None:
            got = parse_one_field(text, profile, policy == "quoted")
            results["strict"] = "ok" if got == data else "strict parse %r != %r" % (got, data)
        else:
            got = parse_document(text, profile)
            results["strict"] = "ok" if got == records else "strict parse differs: %r" % got[:3]
    except Malformed as e:
        results["strict"] = "strict parser refuses it: %s" % e
    try:
        rows = csv_rows(text)
        want_rows = [[data]] if records is None else records
        results["csvmodule"] = "ok" if rows == want_rows else "csv.reader reads %r" % rows[:3]
        if policy == "quoted" and records is not None:
            qa = csv_quote_all(records) if terminated else csv_quote_all(records).removesuffix("\r\n")
            if records == [] and not terminated:
                qa = ""
            results["csvwriter"] = "ok" if qa == text else "csv.writer(QUOTE_ALL) writes %r" % qa[:80]
    except csv.Error as e:
        results["csvmodule"] = "csv.reader refuses it: %s" % e
    return results


def check(path, show=40):
    totals = {}
    failures = []
    lines = 0
    with open(path, encoding="utf-8", newline="\n") as f:
        for line in f:
            line = line.rstrip("\n")
            if not line:
                continue
            lines += 1
            parts = line.split("\t")
            kind, enc, outcome = parts[0], parts[1], parts[2]
            symbols = [int(x) for x in parts[3].split()] if len(parts) > 3 and parts[3] else []
            for name, verdict in judge(kind, enc, outcome, symbols).items():
                t = totals.setdefault(name, [0, 0])
                if verdict == "ok":
                    t[0] += 1
                else:
                    t[1] += 1
                    failures.append("%s %s: %s [%s]" % (kind, name, verdict, enc[:60]))
    print("lines %d" % lines)
    for name in sorted(totals):
        print("%-11s %6d ok %4d failed" % (name, totals[name][0], totals[name][1]))
    for f in failures[:show]:
        print("FAIL " + f)
    return 1 if failures else 0


# ---------------------------------------------------------------------------
# Self-test: the parser on hand-written documents, beside the csv module

SELFTEST = [
    # (document, profile, strict verdict: records or "malformed")
    ('', "A", []),
    ('"a","b","c"\r\n', "A", [["a", "b", "c"]]),
    ('"a","b","c"', "A", [["a", "b", "c"]]),
    ('a,b,c\r\n"x""y",",","\r\n"\r\n', "A", [["a", "b", "c"], ['x"y', ",", "\r\n"]]),
    (',,\r\n', "A", [["", "", ""]]),
    ('"",,""\r\n', "A", [["", "", ""]]),
    ('"a"b,c,d\r\n', "A", "malformed"),          # text after a closing quote
    ('"a,b,c\r\n', "A", "malformed"),             # unterminated
    ('a"b,c,d\r\n', "A", "malformed"),            # a quotation mark unquoted
    ('a,b\r\n', "A", "malformed"),                # two fields
    ('a,b,c,d\r\n', "A", "malformed"),            # four fields
    ('a,b,c\nd,e,f\n', "A", "malformed"),         # LF line ends
    ('a,b,c\rd,e,f\r', "A", "malformed"),         # CR line ends
    ('a,b,c\r\n\r\n', "A", "malformed"),          # an empty line
    ('"é",b,c\r\n', "A", "malformed"),       # outside ASCII
    ('"é",b,c\r\n', "B", [["é", "b", "c"]]),
    ('a\tb,c,d\r\n', "B", "malformed"),           # TAB unquoted
    ('"a\tb",c,d\r\n', "B", [["a\tb", "c", "d"]]),
    ('" ",b,c\r\n', "B", [[" ", "b", "c"]]),
    (' ,b,c\r\n', "B", "malformed"),         # LINE SEPARATOR unquoted
    ('﻿a,b,c\r\n', "B", "malformed"),        # a byte-order mark
    ('"\x00",b,c\r\n', "B", "malformed"),         # NUL
    ('"\x85",b,c\r\n', "B", "malformed"),         # C1 (NEL)
    ('"\U0001F600",b,c\r\n', "B", [["\U0001F600", "b", "c"]]),
    (' a ,b,c\r\n', "A", [[" a ", "b", "c"]]),    # spaces are data
]


def selftest():
    wrong = 0
    disagreements = []
    for doc, profile, want in SELFTEST:
        try:
            got = parse_document(doc, profile)
        except Malformed as e:
            got = "malformed"
        if got != want:
            wrong += 1
            print("WRONG %r (%s): strict parser %r, expected %r" % (doc, profile, got, want))
        try:
            py = csv_rows(doc)
        except csv.Error as e:
            py = "error: %s" % e
        if (want == "malformed") != isinstance(py, str) or (want != "malformed" and py != want):
            disagreements.append((doc, profile, want, py))
    print("selftest: %d documents, %d wrong" % (len(SELFTEST), wrong))
    print("csv.reader disagrees with the strict profile on %d:" % len(disagreements))
    for doc, profile, want, py in disagreements:
        print("  %r (%s): strict %r, csv.reader %r" % (doc, profile, want, py))
    return 1 if wrong else 0


# The table examples/dfa/csv/export.bot exports (its header first).
EXPORT_TABLE = [
    ["id", "name", "comment"],
    ["101", "Ada Lovelace", "First program, 1843"],
    ["102", 'Grace "Amazing Grace" Hopper', "COBOL"],
    ["103", 'hello","admin', "a value that tries to open a column"],
    ["104", 'x"\r\n"evil","=1+2","z', "a value that tries to end the record"],
    ["105", "=1+2", "+1+2"],
    ["106", "@SUM(1,2)", "-2+3"],
    ["107", "multi\r\nline\nvalue", "tab\there"],
    ["108", "caf\u00e9 na\u00efve \u20ac", "\U0001F600 and \u4e2d\u6587"],
    ["109", "", '""""'],
]


def check_export(path):
    data = open(path, "rb").read()
    problems = []
    if data.startswith(b"\xef\xbb\xbf"):
        problems.append("starts with a byte-order mark")
    try:
        text = data.decode("utf-8", errors="strict")
    except UnicodeDecodeError as e:
        print("not strict UTF-8: %s" % e)
        return 1
    try:
        got = parse_document(text, "B")
        if got != EXPORT_TABLE:
            problems.append("the strict parser reads %r" % got)
    except Malformed as e:
        problems.append("the strict parser refuses it: %s" % e)
    rows = csv_rows(text)
    if rows != EXPORT_TABLE:
        problems.append("csv.reader reads %r" % rows)
    if csv_quote_all(EXPORT_TABLE) != text:
        problems.append("csv.writer(QUOTE_ALL) writes something else")
    for p in problems:
        print("FAIL " + p)
    print("export: %d bytes, %d records, %s" % (len(data), len(rows), "ok" if not problems else "%d problems" % len(problems)))
    return 1 if problems else 0


if __name__ == "__main__":
    if len(sys.argv) >= 3 and sys.argv[1] == "export":
        sys.exit(check_export(sys.argv[2]))
    if len(sys.argv) >= 2 and sys.argv[1] == "selftest":
        sys.exit(selftest())
    if len(sys.argv) >= 3 and sys.argv[1] == "check":
        sys.exit(check(sys.argv[2], 10 ** 9 if "--all" in sys.argv[3:] else 40))
    print(__doc__)
    sys.exit(2)

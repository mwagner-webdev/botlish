"""audit/dotenv-interoperability: the python-dotenv adapter (theskumar/python-dotenv).

    python3 -I adapter.py --lib DIR --manifest FILE --config NAME

DIR holds the pinned python-dotenv (tools/setup.py: pip install
--require-hashes --no-deps --target DIR). The public API used is
dotenv.dotenv_values(PATH, interpolate=..., encoding="utf-8"): it parses and
returns a dict without writing os.environ (load_dotenv writes it). Values may
be None (a key without "="). Interpolation, on by default, reads os.environ
(with the file's earlier values taking precedence), so the harness controls
the environment the adapter starts in.

Configurations: default (interpolate=True, the library default) and
nointerp (interpolate=False). python-dotenv reports a line it cannot parse
as a logging warning on the "dotenv.main" logger; the adapter records those
warnings with the fixture.
"""

import json
import logging
import os
import sys


def arg(name, default=None):
    a = sys.argv
    return a[a.index(name) + 1] if name in a else default


class Capture(logging.Handler):
    def __init__(self):
        super().__init__(logging.DEBUG)
        self.records = []

    def emit(self, record):
        self.records.append(record.getMessage())


def emit(obj):
    sys.stdout.write(json.dumps(obj, ensure_ascii=True) + "\n")
    sys.stdout.flush()


def main():
    sys.path.insert(0, arg("--lib"))
    import dotenv
    from dotenv import dotenv_values
    try:
        from importlib.metadata import version
        lib_version = version("python-dotenv")
    except Exception:
        lib_version = getattr(dotenv, "__version__", None)
    config = arg("--config", "default")
    interpolate = config != "nointerp"
    emit({"type": "meta", "target": arg("--target", "python"), "config": config,
          "runtime": "CPython " + sys.version.split()[0], "library": "python-dotenv",
          "library_version": lib_version,
          "options": {"api": "dotenv_values(path, interpolate=%s, encoding='utf-8')" % interpolate,
                      "library_file": os.path.relpath(dotenv.__file__, arg("--lib"))}})
    capture = Capture()
    log = logging.getLogger("dotenv.main")
    log.addHandler(capture)
    log.setLevel(logging.DEBUG)
    log.propagate = False
    with open(arg("--manifest"), encoding="utf-8") as f:
        fixtures = json.load(f)["fixtures"]
    for fx in fixtures:
        capture.records = []
        before = dict(os.environ)
        out = {"type": "result", "id": fx["id"], "status": "ok", "assignments": [],
               "error": None, "warnings": [], "views": {}}
        try:
            values = dotenv_values(fx["path"], interpolate=interpolate, encoding="utf-8")
            out["assignments"] = [[k, v] for k, v in values.items()]
        except Exception as e:  # the parser's own failure, recorded as data
            out["status"] = "error"
            out["error"] = {"class": type(e).__module__ + "." + type(e).__qualname__, "message": str(e)}
        out["warnings"] = list(capture.records)
        if dict(os.environ) != before:
            out["warnings"].append("process environment changed by dotenv_values")
            os.environ.clear()
            os.environ.update(before)
        emit(out)


if __name__ == "__main__":
    main()

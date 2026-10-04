# VM opcode viability -- performance calibration

Evidence for section 12 of `VM-OPCODE-VIABILITY.md`: how fast a v1 bytecode
interpreter of the proposed design would run, compared with Botlish's native
code and with other non-JIT interpreters. Run time only; startup (the Tcl front
end down to NIR) is excluded everywhere. Nothing here is part of Botlish: the
prototype shares no code with `native/` and changes no compiler or runtime
behaviour.

| path | what |
|---|---|
| `prototype/` | a dependency-free Rust crate: the v1 dispatch loop (64-bit words, `match` dispatch, register stack with frame records, argument copy with unbox-on-entry, tagged-slot zeroing, ZF/CF in locals, tagged-Int fast paths), reduced to the 17 opcodes two micro-benchmarks need, running the VM code of the report's section 2. `src/main.rs`'s header lists what it reproduces and what it leaves out. |
| `interpreters/micro.{py,tcl,rb,pl,php,js}` | the same two programs (recursive `fib(30)`, a 10M-iteration integer loop) for CPython, Tcl 9, Ruby, Perl, PHP and node |
| `botlish/fib30.bot`, `botlish/loop.bot` | the Botlish versions |
| `botlish/measure.tcl` | native (Cranelift) best-of-5 time of those, through `native::measure` |

Commands, from the repository root, with `LANG=C.utf8 LC_ALL=C.utf8` and the
native backend built:

```sh
cargo run --release --manifest-path audit/vm-opcode-viability/prototype/Cargo.toml
tclsh9.0 audit/vm-opcode-viability/botlish/measure.tcl \
    audit/vm-opcode-viability/botlish/fib30.bot audit/vm-opcode-viability/botlish/loop.bot
cd audit/vm-opcode-viability/interpreters
python3 micro.py; tclsh9.0 micro.tcl; ruby micro.rb; perl micro.pl
php -d opcache.enable_cli=0 micro.php; node --jitless micro.js; node micro.js
```

The report's numbers were taken in a Claude Code cloud container (Intel Xeon
@ 2.1 GHz, 4 cores; rustc 1.97, Python 3.11.15, Tcl 9.0.1, Ruby 3.3.6 without
YJIT, Perl 5.38.2, PHP 8.3.6 with opcache off, node 22.22.0). The prototype's
timings moved by up to about 10% between builds of equivalent source, and by
1.7x when the `tail` handler was written with iterators instead of indexed
loops; treat its results as a range, not a point.

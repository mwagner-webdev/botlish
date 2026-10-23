# LSP-MILESTONE-1.md

Botlish's first usable Language Server Protocol implementation: a
Tcl-orchestrated stdio language server, sharing the compiler service's
semantic facts, with document synchronization, diagnostics, hover,
definition, references, and responsive analysis under active editing.

> An editor should be able to ask Botlish what a program means without
> running it, without implementing compiler semantics itself, and without
> becoming unresponsive while the compiler works. The CLI and LSP must agree
> on the program; the LSP adds transport, scheduling, and presentation, not
> another compiler.

This milestone builds on the compiler service (COMPILER-SERVICE-MILESTONE-1.md,
its census `../audit/compiler-service/COMPILER-SERVICE-CENSUS.md`) and the
canonical `std::` namespace (STD-NAMESPACE.md), both on `main` at `6df89a8e`,
where this work starts. It follows the service report's section 16 ("the
smallest stdio LSP") and keeps every contract that report lists.

No syntax, HIR node, registry, cache format, backend, daemon or incremental
mechanism was added. The compiler service gained one narrowly scoped pair of
calls -- `service::export` and `service::import`, a revision moved between
processes as text with its HIR in the HIR interchange format -- and
everything else is new code above the service, in `lsp/`.

## Contents

1. [Result](#1-result)
2. [Architecture](#2-architecture)
3. [Protocol](#3-protocol)
4. [Documents and revisions](#4-documents-and-revisions)
5. [Coordinates and URIs](#5-coordinates-and-uris)
6. [Scheduling decision](#6-scheduling-decision)
7. [Correctness](#7-correctness)
8. [Tests](#8-tests)
9. [Performance](#9-performance)
10. [Files and usage](#10-files-and-usage)
11. [Limitations](#11-limitations)
12. [Next milestone](#12-next-milestone)

MEASUREMENTS-PLACEHOLDER

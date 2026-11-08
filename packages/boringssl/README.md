# boringssl -- the BoringSSL provider of Botlish packages

`boringssl` carries one build of BoringSSL for the packages that link it:
today `http` (its TLS). A program does not import it to make TLS
connections -- it installs `http`, which depends on and locks this package
-- and the package manager puts one instance of it in the program's graph.

* **What it holds.** `native/libbotlish_boringssl.a`: BoringSSL's release
  tag 0.20261020.0 (commit d3bf4795ad5b79d646cddf2fec687da5b9b502db,
  `PIN`), built from upstream with its own CMake, unpatched and unprefixed,
  its `crypto` and `ssl` archives' members put in one archive of this
  package's own name (so no link takes a system OpenSSL's `libcrypto` or
  `libssl` for it), with one more member defining the provider's identity
  symbol, `botlish_boringssl_0_20261020_0_d3bf4795ad5b79d646cddf2fec687da5b9b502db`.
  `licenses/boringssl/LICENSE` is BoringSSL's license.
* **Identity.** A unit built against this provider (http's) references the
  identity symbol: linked with another BoringSSL, the link fails naming it,
  and a graph with another release of this package is a
  DEPENDENCY-CONFLICT. Its version is BoringSSL's tag.
* **Linking.** BoringSSL's TLS code is C++: a program linking it needs the
  C++ standard library's link name (`libstdc++.so`; on Ubuntu `g++` or
  `libstdc++-13-dev`), which this package declares as a system library.
* **Platforms.** Linux x86-64 (glibc) only.

How it is built: `tools/http-package.tcl` (the provider) and
`tools/package-repository.tcl`'s `author::boringssl` (the release);
HTTP-CLIENT-PACKAGE-MILESTONE-1.md in the repository's `docs/`.

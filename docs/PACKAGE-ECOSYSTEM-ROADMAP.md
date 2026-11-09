# PACKAGE-ECOSYSTEM-ROADMAP.md

## Installable libraries, portable native dependencies, and an independently verifiable package ecosystem

> Botlish packages are ordinary Botlish modules. The compiler consumes an assembled package tree; the package manager constructs and verifies that tree. Publishing and installing packages should become progressively more trustworthy without requiring more privileges from either compiler or application code.

## 1. Goals and boundaries

The package ecosystem has four goals, in priority order:

1. **Make packages useful now.** An application should be able to depend on SDL3, Raven or a pure-Botlish web framework without copying library code, invoking package-specific scripts or managing dependencies by hand.
2. **Make native dependencies genuinely portable.** A package author should be able to ship target-specific C bindings and either system-library requirements or authenticated bundled binaries, with the package manager handling their installation and deployment requirements.
3. **Make the supply chain independently verifiable.** Use developer signatures, TUF delegation, authenticated upstream source history, immutable publication and eventually independently witnessed transparency.
4. **Determine the right distribution model for compiler extensions.** Reuse package infrastructure where appropriate, but do not silently give ordinary packages authority over the compiler.

The first two goals must not depend on completion of the last two.

### Architectural invariants

- The compiler reads `.bot_modules`; it never reads `botlish.json`, resolves package versions or performs network access.
- Package imports remain downward-only and package-instance identities remain distinct. (Since SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md, a package of the application's resolved dependency graph is one instance, shared by every package that depends on it: its identity is canonical, and imports remain limited to declared dependencies.)
- `std::` remains compiler-owned. Third-party packages receive no stdlib-specific privileges.
- The package manager does not execute arbitrary installation scripts.
- Native libraries come from system-managed installations or authenticated bundled artifacts.
- Native package authors may use arbitrary external build systems, but consumers receive finished, verified artifacts.
- Published package versions are immutable. A release may be revoked, never overwritten.
- Published packages have exact compatible locks for every direct dependency, validated both at publication and installation.
- Compiler plugins are not implicitly activated by importing or installing a package.

Local, manually assembled `.bot_modules` trees remain supported without a manifest.

## 2. Starting position

The following foundations are already present in the repository:

- Canonical `std::` ownership and rooted namespaces.
- Package-scoped `.bot_modules`, downward-only resolution and package-instance identity.
- C FFI, generated bindings, native layouts, floats and callback support within the existing documented limits.
- Native compilation on multiple operating systems.
- Explicit native linkage, including static archives and Apple frameworks.
- An SDL3 binding and reusable `sdlkit` airlock demonstration.
- A Raven wrapper under `packages/raven`, with an existing specialized installation workflow.
- Native-library generation for C consumers.

These reduce the required package-manager work considerably.

The remaining problems are primarily distribution, resolution, authentication and native artifact handling.

## 3. Milestone sequence

| Milestone | Deliverable | Priority | Status |
|---|---|---|---|
| PM-1 | Local package manager and `botlish.json` | Immediate | done: PACKAGE-MANAGER-MILESTONE-1.md |
| PM-2 | Cross-platform native package consumption | Immediate | done: PACKAGE-MANAGER-MILESTONE-2.md |
| PM-3 | Native package authoring and verified artifacts | High | done: PACKAGE-MANAGER-MILESTONE-3.md (generic authoring commands, native audit, schema 3 run-time dependencies, unsigned provenance records, reproducible releases from a pinned author image) |
| PM-4 | Signed publication and TUF-backed registry | Medium | not started |
| PM-5 | Upstream history continuity and native provenance | Medium | not started (PM-3 records upstream Git identities, unchecked against history) |
| PM-6 | Independent attestations and transparency | Long-term | not started |
| PM-7 | Compiler-plugin distribution experiment | Parallel research after PM-2 | PM-7A done: EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md (external tools run only explicitly, out of process; declarative target support packages; the native library manifest as the artifact contract). In-process and privileged extensions: not started |

PM-1 through PM-3 constitute the first practically useful package ecosystem. PM-4 is required before treating a public registry as a trusted distribution channel.

PM-5 and PM-6 progressively strengthen protections against compromised upstream infrastructure, maintainers, build environments and registry operators.

---

## 4. PM-1: Local package management

**Objective:** Replace bespoke package installation scripts with one package-manager workflow.

### Package descriptor

Use one optional `botlish.json` file for the package manager.

Conceptual example:

```json
{
  "name": "myapp",
  "dependencies": {
    "sdlkit": "1.2",
    "web": "0.4"
  },
  "lock": {
    "sdlkit": "1.2.3",
    "web": "0.4.2"
  }
}
```

Version precision, not a range-operator language, determines compatibility:

- `1` accepts releases under major version 1.
- `1.2` accepts releases under major 1, minor 2.
- `1.2.3` specifies that exact release.

Do not introduce `^`, `~` or comparable version policies.

`dependencies` expresses the package author's requested compatibility. `lock` records exact resolutions.

A lock entry is created automatically by `botlish add` and preserved until an explicit update.

### Distributed locking

Each package carries its own direct-dependency requests and exact locks.

The root application does not enumerate the entire transitive dependency tree.

The package manager recursively validates a published package's locks before installation. An absent, contradictory or non-exact direct-dependency lock is an error, even if the package registry claims the release is valid.

Allow nested instances of the same package at different dependency-tree positions. Discourage unnecessary duplication, but do not force global version unification.

*Superseded by SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md* (LANGUAGE-DESIGN-PRINCIPLES.md, section 2): nested instances made independently authored libraries unable to share a dependency -- an event-loop driver whose context the application installs (HTTP-SHIPPING-CENSUS.md, section 6.2, decision D1). An application now has one dependency graph: one instance of each package, at the version every lock names, or a conflict. Global unification is the rule; the distributed locks stay binding, and a graph whose locks disagree is refused, never resolved by a second instance.

Optional consumer overrides of nested locks can be introduced later and must be explicit, narrowly scoped and recorded. (Not introduced: SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md keeps every author's lock binding, so an override would be a language-design decision of its own.)

### Operations

Implement:

- `botlish add`: resolve and install a dependency, update the file.
- `botlish install`: recreate the specified locked installation.
- `botlish update`: update selected locks within their declared precision.
- `botlish remove`: remove a dependency and its unneeded installed artifacts.
- `botlish verify`: check the installed tree against its available immutable metadata and integrity records.

Support local package directories and local package archives first.

Use deterministic dependency resolution, transactional installation, validated extraction, atomic replacement and a cache suitable for reuse.

Do not execute scripts from packages.

### Acceptance workloads

- Replace Raven's specialized package installation helper with the generic manager.
- Install `sdlkit` and its nested SDL3 binding dependency.
- Install a pure-Botlish library with no native dependencies.
- Demonstrate nested dependencies and two distinct versions of the same library.
- Verify compilation, cache correctness and package-instance identity after updates.
- Verify that a failed installation preserves the previous working tree.

### Explicit omissions

No remote registry, TUF, publishing, developer key management or native binary bundling.

The result should already be useful for local development and vendored package distribution.

**Exit criterion:** A project can recreate its complete pure-Botlish package tree from local immutable package artifacts and `botlish.json`, without package-specific installation logic.

---

## 5. PM-2: First-class cross-platform FFI packages

**Objective:** Make native-backed packages ordinary dependencies from the application's perspective.

This is the most urgent milestone after PM-1.

### Native dependency descriptors

Extend package metadata declaratively.

Two supported dependency origins:

**System:** A library managed by the target operating system or a trusted system package manager. Record the required ABI, version information when reliable, and target compatibility.

**Bundled:** A library distributed as an authenticated package artifact, with target-specific contents and integrity metadata.

Both must support static and shared linking where the target platform permits them. Apple frameworks and platform deployment conventions must be accommodated.

No arbitrary system-wide native library discovered through an uncontrolled search path automatically qualifies as system-managed.

### Separate Botlish target bindings from native binary artifacts

A package may contain:

- Portable Botlish wrapper source.
- Generated C bindings specific to an OS/architecture/ABI.
- Optional native thunk archives.
- Bundled static or shared native libraries.
- Required headers, notices and other non-executable resources.

The package manager must select or prepare a target-specific installed view deterministically.

Target selection is based on the compilation target, not merely the machine running the installer. Cross-compilation must be supported without accidentally selecting host binaries or headers.

A package should not need different public namespace names for every target when its public API is logically the same.

The compiler's existing module and link mechanisms should be reused wherever possible. Any necessary compiler extension must remain concerned with target-specific source or native linkage, not package versions.

### Native compatibility and deployment

Check:

- Operating system, architecture and calling convention.
- Binary file format and static-versus-import-library distinctions.
- ABI compatibility and platform runtime requirements.
- Link dependencies and exported symbols.
- Shared-library identity collisions across package instances.
- Relative loader paths and final runtime library selection.
- Framework and application signing requirements.

Do not assume that nested Botlish package isolation implies native library isolation.

Create a validated native link/deployment plan for the application builder. A package may supply native artifacts, but the application builder remains responsible for final executable or application-bundle placement and signing.

System-provided libraries remain subject to later operating-system updates; the manager must not claim their installation-time identity is a permanent runtime guarantee.

### Acceptance workloads

**SDL3 / sdlkit**

- One package distribution supports the available Linux, Windows and macOS targets.
- The appropriate generated bindings and C shims are selected.
- A consumer can use either a validated system SDL3 installation or a bundled library where supported.
- Icy Tower builds without bespoke binding staging.
- The existing context airlock and ownership rules remain intact.

**Raven**

- The wrapper installs through the same mechanism as SDL3.
- Its generated bindings, event bridge and native library dependencies are represented declaratively.
- Its native compatibility requirements are checked.
- The current Linux workloads continue to work.
- Missing target support produces a precise package-target diagnostic, not an implied portability claim.

**Pure Botlish**

A web-framework or similar package has no native configuration. Its installation should be materially simpler, not burdened by empty FFI metadata.

**Exit criterion:** Native and pure-Botlish packages use the same dependency-management workflow, with native-specific checks activated only where necessary.

---

## 6. PM-3: Safe native artifact authoring

**Objective:** Help package authors bundle native libraries safely without making the package manager a general-purpose native build system.

Introduce author-oriented operations, conceptually:

```text
botlish native add
botlish native audit
botlish package pack
```

### Native artifact import

An author supplies an already-built artifact and its declared target.

The manager inspects the binary without executing it, determines its format and architecture, inspects dependencies, validates supported ABI facts and generates draft native metadata.

Do not use mechanisms that can execute untrusted binaries merely to inspect them.

### Dependency closure analysis

Classify every relevant native dependency as:

- Explicitly bundled.
- Explicitly system-provided.
- Unresolved.

An unresolved dependency blocks publication.

Do not automatically bundle every dependency encountered. Some libraries are not suitable for redistribution, and some system libraries must remain system-provided.

Audit licensing and redistribution metadata, platform runtime assumptions, ABI requirements, signing requirements and loader-path behavior.

### Immutable artifacts

`botlish package pack` produces a deterministic, content-addressed release artifact covering source, metadata, generated bindings and native binaries.

The artifact format must be designed for later signed publication, even if PM-3 initially uses locally trusted artifacts.

Define stable artifact hashing, manifest serialization and signature payload domains now. Avoid inventing a private cryptographic scheme.

### Author-side execution

Authors may build their dependencies through their own trusted CMake, Make, CI or other build environments.

The package manager may inspect the resulting artifacts and authenticated provenance.

Consumers do not run the author's build process.

There is no package-provided `postinstall`, arbitrary build hook or implicit script execution.

**Exit criterion:** An SDL3 or Raven package author can turn existing native build outputs into a complete, validated, portable Botlish release artifact through a generic workflow.

---

## 7. PM-4: Signed publishing and TUF-backed registry

**Objective:** Introduce trusted remote package installation without changing the compiler or package format's ordinary dependency model.

Do not launch a public registry with a provisional, incompatible verification protocol.

### Registry requirements

- Immutable published versions and artifacts.
- Atomic publication of source, metadata and artifact references.
- Package-name ownership and authorized developer identities.
- Publication rejection for incomplete dependency locks.
- Independent installation-time lock validation.
- Permanent revocation records, rather than version overwriting.
- Explicit handling of package ownership transfer and signing-key rotation.

### TUF

Use the established TUF roles and verification process:

- Offline, threshold-protected root.
- Authenticated targets and delegations.
- Snapshot consistency.
- Timestamp freshness and rollback protection.
- Correct expiration, key rotation and recovery behavior.

TUF delegates package distribution authority, while separate developer-signature policy may impose additional requirements.

A registry's delegated authority must not silently override an independently pinned developer identity.

### Developer signatures and cross-signing

Support signatures over exact release identities and content digests.

Distinguish:

- Delegation of package publishing authority.
- Endorsement of a developer key.
- Approval of a particular release.
- Independent verification of a release's provenance.

Trust is scoped to particular packages or explicit sets of names. Do not create unrestricted transitive trust through endorsements.

Global trust configuration is the default. Project-specific policies may override it explicitly.

The package manager must distinguish local unverified packages from authenticated registry artifacts. A locally copied directory must not acquire registry-authenticated status merely because it has a familiar name.

### Update and revocation policy

Report outdated and revoked versions distinctly.

An outdated release is not necessarily unsafe. A newer release is not necessarily safer.

Revocation generates a prominent warning and policy-dependent enforcement. An invalid signature, failed authorization, altered artifact or missing required provenance is a hard verification failure.

There must be no silent substitution of a locked release.

**Exit criterion:** The package manager can install and verify independently signed, immutable remote releases through a TUF repository, while preserving the existing compiler and local-package workflows.

---

## 8. PM-5: Upstream source history continuity

**Objective:** Detect upstream source substitution, retrospective history rewriting and unexpected discrepancies between source distributions and authenticated Git history.

This directly addresses the compromised-SDL3-tarball scenario.

### Upstream anchors

Attach provenance to native releases recording, where applicable:

- Upstream repository identity.
- Git object hash algorithm.
- Full commit ID.
- Release tag and annotated tag object ID.
- Source tree identity.
- Independent SHA-256 digest of the actual build inputs.
- Previous authenticated upstream release anchor.

The Botlish registry preserves anchors from previously published releases.

Git's commit graph supplies the ancestry relation; there is no need to invent another blockchain.

### Update verification

Author tooling should:

1. Fetch new upstream source into an isolated verification environment.
2. Compare it against previous authenticated release anchors.
3. Verify Git object identity and relevant ancestry.
4. Detect moved tags and altered or unavailable historical anchors.
5. Verify that source archives correspond to declared Git source.
6. Produce an inspectable diff from the previously trusted release.
7. Highlight changed build instructions, generated files, dependencies and native binaries.

Any unexpected history discontinuity requires explicit authorization or fails under a stronger policy.

Legitimate backports, maintenance branches, source repository migrations and hash-format transitions must have documented paths through this process.

Do not blindly require every new release to descend from the immediately previous release; real upstream maintenance frequently uses several branches.

### Source authentication limitations

Continuity is not proof of benign code.

An attacker can append a malicious commit while preserving every previous anchor. Reproducible builds can then reproduce the malicious result.

The purpose is to expose substitutions and make source changes reviewable, not to certify that upstream source is safe.

**Exit criterion:** An SDL3 update based on a replaced tarball or rewritten upstream history is detected before publication, and an ancestry-preserving update produces evidence suitable for review.

---

## 9. PM-6: Independent evidence and transparency

**Objective:** Reduce dependence on the central registry and on any one developer's infrastructure.

Build on the immutable publication records from PM-4.

### Transparency

Introduce an append-only authenticated event history for:

- Package publication.
- Release revocation.
- Package ownership changes.
- Developer key authorization and rotation.
- Native upstream anchors.
- Independent build and review attestations.

Clients and monitors should be able to verify inclusion and consistency. Independent witnesses should make conflicting registry histories detectable.

TUF and transparency have distinct responsibilities. TUF authenticates a current repository view; transparency allows third parties to audit historical consistency.

### Independent attestations

Allow external developers and builders to contribute signed, digest-bound evidence that they:

- Independently reproduced a binary.
- Reviewed a source change.
- Verified a build process.
- Validated an upstream release's provenance.

The statement must describe what was verified. A second signature alone is not evidence of independent examination.

Support selective stronger policies without imposing multi-party review on every ordinary pure-Botlish package.

### Recovery and decentralization

Investigate mirrors, independent monitors, threshold signing, recovery after compromised keys and the portability of authenticated package identities across repositories.

Do not claim that a registry is fully decentralized merely because developers sign releases.

**Exit criterion:** A compromised registry cannot silently replace previously authenticated developer keys, artifacts or witnessed publication history without violating a client's configured trust requirements or leaving detectable evidence.

---

## 10. PM-7: Compiler-plugin distribution experiment

**Objective:** Determine empirically whether compiler plugins should share the ordinary package distribution model.

Do not decide this by analogy with package systems in other languages.

### Three candidates

**A. Ordinary library package**

The compiler or a trusted tool consumes a Botlish API from an installed package. It gets no privileged compiler access.

**B. Declarative extension package**

The package contributes schemas, tables, rules or other data interpreted by trusted compiler machinery, without executing untrusted extension code.

**C. Executable compiler extension**

The package supplies code invoked during compilation, potentially interpreting or transforming program representation.

These have different authority requirements.

### Experiment

Develop three realistic prototypes if the underlying compiler architecture supports them:

- A declarative extension.
- A Botlish-authored compile-time tool using a defined compiler-service interface.
- An extension requiring genuinely privileged compiler operations.

Measure required API stability, startup overhead, portability, cache invalidation, compiler version coupling, reproducibility and authority exposure.

Prefer an isolated process and a narrow protocol for executable extensions where practical. Loading arbitrary native plugins directly into the compiler should not become the default merely because ordinary FFI packages support native libraries.

### Decision rule

Reuse the ordinary package manager for artifact acquisition, versioning, signatures and integrity wherever feasible.

But **installation must never imply activation**.

Compiler extensions should require explicit enablement and a separate authority decision. They must not gain access to compiler process memory, arbitrary source files, secrets or native execution merely by appearing in `.bot_modules`.

An independent plugin registry is justified only if actual lifecycle or security requirements cannot be accommodated by distinct package kinds and activation policies.

**Exit criterion:** A documented evidence-based decision on common versus separate distribution infrastructure, with at least one working experiment and an explicit compiler-plugin authority model.

*PM-7A (EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md)* built candidates A and B and a narrow form of C: ordinary packages carry declarative target support (a runtime archive and its descriptor, read only when a compilation names it) and external tools (`botlish.json` schema 4), which only `botlish tool` runs, in a process of their own, against the documented artifact contract (the native library manifest, schema 2). The ordinary package manager distributes all of them; installation never implies activation. Executable extensions inside the compiler process, and any extension with privileged compiler access, remain undecided and unbuilt.

---

## 11. Cross-cutting validation

Every milestone should use real packages, not just synthetic manifests.

Maintain the following acceptance matrix:

| Workload | What it tests |
|---|---|
| Pure-Botlish library | Dependency resolution without native packaging overhead |
| Multi-package application | Nested locks, different instances, identity and update correctness |
| SDL3 / sdlkit | Generated bindings, static/shared linkage, desktop targets, native deployment |
| Raven | Large C binding surface, event bridge, native resources and target limitations |
| Deliberately malicious package archive | Extraction safety, symlinks, integrity and transactional installation |
| Compromised release fixture | Invalid signatures, altered dependencies, revocation and registry substitution |
| Rewritten Git-history fixture | Upstream continuity detection |
| Compiler-plugin prototype | Activation authority and build reproducibility |

Where possible, test Linux x86-64/AArch64, Windows x86-64 and macOS AArch64 using the existing CI architecture.

Do not infer successful execution from generation or cross-compilation alone.

Additional Android and iOS packaging should be introduced when those target pipelines become mature enough to validate real application deployment.

## 12. Security rules from the beginning

The earliest milestones should avoid creating behaviors that later security work has to undo.

Specifically:

- Never execute package installation hooks.
- Never interpret a package archive entry as an arbitrary destination path.
- Never treat a digest obtained from the same untrusted source as independent authentication.
- Never claim a locally supplied artifact has verified developer provenance without evidence.
- Never silently replace a locked dependency.
- Never permit installation or artifact metadata to grant compiler-specific privileges.
- Never confuse successful native linkage with verification of the runtime library that will actually load.
- Never confuse authenticated provenance with proof that source code is harmless.

These properties are practical even before remote registries or TUF exist.

## 13. First usable release boundary

The first package-manager release should include PM-1 through PM-3, not PM-4 through PM-6.

It should support:

- Local installation from verified or explicitly locally trusted artifacts.
- Pure-Botlish packages and nested dependencies.
- Exact distributed locks.
- Declarative native requirements.
- Target-aware generated bindings.
- System and bundled native libraries.
- Safe archive inspection, integrity checks and deployment metadata.
- SDL3 and Raven demonstrations without specialized installation scripts.

It should not claim registry-grade provenance or independent upstream authentication for arbitrary local artifacts.

This is a worthwhile release in its own right. Developers can distribute prebuilt packages through their existing infrastructure while the public registry is still being designed.

## 14. Long-term success criteria

The roadmap succeeds when an application can depend on a web framework, SDL3 and Raven through the same package manager, without making the compiler aware of package versions or giving third-party libraries special language privileges.

A package author can prepare and publish cross-platform native binaries with substantially less manual packaging work, while preserving inspectable provenance.

A package consumer can choose meaningful trust requirements—from ordinary authenticated registry installation to independently verified upstream source and builds.

The package registry can be compromised without automatically acquiring authority to replace independently trusted packages or rewrite witnessed history.

Finally, compiler extensions can benefit from the same distribution infrastructure without accidentally inheriting the same execution privileges as ordinary application libraries.

The guiding principle is:

> **Make ordinary package use simple; make authority explicit; make stronger verification progressively available; and never require a package to be more trusted than its role demands.**

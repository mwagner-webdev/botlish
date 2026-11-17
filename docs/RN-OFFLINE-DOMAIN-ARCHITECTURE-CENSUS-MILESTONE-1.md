# RN-OFFLINE-DOMAIN-ARCHITECTURE-CENSUS-MILESTONE-1.md

## An offline-first Botlish domain service for React Native: durable SQLite state, Hyper networking, reconciliation and React hooks (census)

Status: census, no implementation. It establishes the smallest correct
architecture for a React Native Android application whose offline-first
domain logic runs in Botlish, and the roadmap of milestones to build it.
Material: `../audit/rn-offline-domain/` (three probes and their runners).

This census does not build the Petstore application, a domain package, a
bridge or a port. Its probes are small, deterministic and confined to
`audit/rn-offline-domain/`. Nothing in the compiler, the runtime, the
standard library, a package, a test or a workflow changed.

**Revisions inspected.**

| What | Revision |
|---|---|
| Botlish | `main` at `db473ee` (2026-11-17). Main's latest runs were green or still in progress when this census began (tests, tests-arm64, macOS and Windows runs `44149413*` in progress; every other workflow green). |
| sqlite-botpkg | github.com/mwagner-webdev/sqlite-botpkg `0f83e67` (built by its author against Botlish `cdb751b`) |
| Android NDK | r29, `29.0.14206865`, the zip pinned by SHA-256 in `.github/workflows/c-bindgen.yml:82-83` |
| React Native | 0.88.1, `react-native-0.88.1.tgz` (SHA-256 `092228927de1b20001001f3bf1f494bd4bac5fff60da83f796655dc7b784489a`) and `@react-native/codegen` 0.88.1 (`354993e7...3d14dd5`), both read as published on npm |
| Petstore | the specifications and services as fetched 2026-11-17 20:28-20:35 UTC (section 3) |

**Evidence classes.** Every claim carries one:

- **observed**: run in this census's container, or a published service probed from it. The container is Linux x86-64 with 4 cores and an ext4 disk.
- **static**: read in source, a document or an artifact, with its path.
- **CI**: a completed workflow run, by run id and revision. GitHub's API was not available for sqlite-botpkg, so its run ids are as its repository records them.
- **projected**: proposed, not demonstrated.

Nothing in this census ran on an Android device or emulator. Android claims
are static, or observed only at the toolchain level: a compiler or linker
was run for the android-aarch64 target and its output inspected. A
successful compilation is never offered as evidence that something runs on
Android.

---

## 1. Executive recommendation

One Botlish package can own the whole offline-first domain: the domain
model, persistence policy, the durable outbox, reconciliation, the offline
policy and retry scheduling. React Native stays a thin presentation client.
Every part of the architecture exists in some form today. The open work is
mostly embedding, Android packaging and contracts, not language or compiler
features.

| Decision | Recommendation | Why |
|---|---|---|
| Service embedding | One persistent service per process: a **host-startable application library** (`NAME_main`) running an ordinary entry program on a host-owned thread, with its own installed contexts and event loop, for the whole life of the process (it outlives React Native reloads). | Probe E (section 20.3) runs this today on Linux, driven asynchronously by three host threads, with no compiler or runtime change: median round trip 38.9 µs, in order, refused across threads, clean stop, GC stress included. M4 worker threads cannot start inside a library today (`native/src/runtime/thread.rs:286-290`: a library's Vm has no thread factory). |
| Host to service | A generic **port package** of this repository's own (proposed `botlish_port`): an in-library C adapter holding bounded byte queues. Host threads submit through an export, which posts one record into the service's loop (`botlish_event_post2`). A host pump thread blocks on completions and notifications through another export. | Exports may not hold contexts or state (`hir/exports.tcl:206-213`), so the service cannot be a set of exports. Only `NAME_*` symbols leave a Botlish library (`native/library.tcl:507-514`), so the adapter is reached through exports, never directly. |
| React Native side | Extend `botlish_react_native`. A **service mode** for schema 3 application libraries generates Promise methods over the port: RN 0.88's `AsyncPromise`, resolved from the pump thread, and an `AsyncEventEmitter` for committed-revision notifications. A separate npm package `@botlish/react-service` provides hooks on `useSyncExternalStore`. | The generator today is synchronous only (`integrations/react-native/src/main.c:1043-1070`). It refuses schema 3 manifests (`:489-491`) and any library with native dependencies (`:538-540`), which includes SQLite, HTTP and even `liblog`. |
| Storage | **sqlite-botpkg**, extended in its own repository with android-aarch64. One writer connection owned by the service VM, `journal_mode=WAL`, `synchronous=FULL`, `temp_store=MEMORY`, `foreign_keys=ON`. | Its pinned SQLite 3.54.1 builds with NDK r29 at API 21 using its own flags. Zero diagnostics, bit-reproducible, 58 undefined symbols all in Bionic libc (observed). No `.bot` change is needed. Android has no usable temporary directory, hence `temp_store`. |
| Transport | **Hyper/BoringSSL (`http`) kept and ported.** An android-aarch64 view of `event_loop_linux`, BoringSSL built by the NDK with libc++ linked statically, LLVM tools in `rustunit::localize`, and an explicit decision on the Android trust source. | The Rust unit builds unchanged for `aarch64-linux-android` in the recipe's link-only mode, with zero warnings. Localized, it links with `-z defs -z text`, 16 KiB alignment and Bionic-only `NEEDED` (observed). The first hard blocker is the driver's `epoll_pwait2` (Bionic API 35+). |
| Reconciliation | **Revision-aware conditional writes** against a **controlled Petstore-compatible server** that pins the v3 1.0.27 contract and adds a revision, `If-Match`/412, `Idempotency-Key` and merge-patch. Client-side three-way field merge, with conflicts mediated by the user. Public Petstore serves only a labelled best-effort smoke profile. | The public services declare no concurrency control. Observed: v2 ignores `If-Match`, upserts on `PUT`, replaces whole resources and evicts pets. v3 returned 500 for every pet operation during the audit. 177 of 203 listed v2 ids exceed 2^53. |
| Identity at the JS boundary | Pet ids cross as **decimal strings**, never JS numbers. | 173 public ids collapse when parsed as float64 (observed). The generator's safe-integer rule would otherwise refuse them (`templates/Core.cpp.in:208-232`). |
| Offline kill switch | A durable policy, enforced at the **only** place that can start an exchange: a gate inside the service whose check and `start` run in one task step without suspension. Static authority (contexts, `inject`, privacy) makes the gate unavoidable; the policy is a run-time value. | A disabled button cannot stop a retry timer. An exchange already started may have been transmitted: its mutation becomes `unknown`, never "unsent". |

**Answers to the decision criteria (prompt section 27).**

| # | Question | Answer |
|---|---|---|
| 1 | Domain ownership | Yes, with the UI reduced to hooks over snapshots and commands (sections 4, 16, 17) |
| 2 | Durable offline behavior | Yes. An edit and its outbox intention commit in one IMMEDIATE transaction, or neither does. Probe A observes it across a process aborted mid-transaction (sections 7, 8, 20.1). |
| 3 | Kill switch | Yes, at the transport authorization boundary. An in-flight request is recorded as possibly transmitted, never retracted (section 6). |
| 4 | Reconciliation | Yes. Disjoint field changes merge and same-field changes conflict (probe B). Lost updates are excluded only under the controlled server's `If-Match` contract (sections 9, 10). |
| 5 | SQLite portability | Yes, the same API, source and SQL on Linux, macOS and Android. The Android work list is small and lives in sqlite-botpkg (section 12). |
| 6 | HTTP portability | Yes, with four concrete additions: the driver's epoll fallback, libc++ static, cross localization, and an Android trust source decision (section 11) |
| 7 | Worker architecture | A host-startable application library on a host thread, plus a port package. M4 threads are unavailable in libraries and not needed (sections 13, 14). |
| 8 | React hooks | Yes. All durable state, synchronization and reconciliation stay in Botlish (sections 15, 16). |
| 9 | Failure recovery | Yes, by the crash matrix of section 8. Exactly-once is not claimed; idempotency needs the server's key. |
| 10 | Implementation readiness | Seven milestones: the prompt's six, with the event loop's Android view split out. Three can start in parallel (section 24). |

---

## 2. Existing Botlish capability census

Each row names what exists at `db473ee`, whether it serves this architecture,
and the evidence.

### 2.1 Component dependency diagram (proposed architecture)

```
 React Native app (Hermes, New Architecture)              [projected]
   screens --> @botlish/react-service hooks (usePets, usePet, useUpdatePet,
               useOfflineMode, useSyncStatus, usePetConflicts)
                 |  useSyncExternalStore over a JS snapshot cache
                 v
   generated TurboModule (botlish_react_native, service mode)
     Promise methods (AsyncPromise)   onChange (AsyncEventEmitter)
                 |  submit/next_completion: Botlish exports (str/int)
=================|=========== libpetstore.so (one Botlish native library) ===
                 v
   botlish_port C adapter (bounded byte queues, one mutex, condvars)
       |  botlish_event_post2 (record: slot, gen, request id)
       v
   service VM (NAME_main on a host-owned thread)  -- installs its contexts:
     std::event_loop::Loop + event_loop_linux (android view)
     botlish_port::Port            sqlite::Engine (sqlite-botpkg)
     http::Http (Hyper/BoringSSL)  petstore_domain contexts (Storage,
                                   NetworkPolicy, PetRemote impl)
       |                        |                    |
       v                        v                    v
   libevent_loop_linux.a   libbotsqlite3.a    libbotlish_http.a + libssl/libcrypto
   (epoll, eventfd)        (SQLite 3.54.1)    (Hyper 1.12, BoringSSL pinned)
================================================================================
        |                       |                    |
     Bionic libc         app-private files dir    HTTPS --> Petstore server
                                                  (controlled profile / public)
```

### 2.2 Capability table

| Capability | State at db473ee | Serves this design? | Evidence |
|---|---|---|---|
| RN external tool `botlish_react_native` | Generates a Pure C++ TurboModule from a schema 2 manifest. Synchronous calls on the JS thread only. Instance owned by its creating thread. Destroyed on that thread (Reaper). Safe-integer and string-by-length rules. | Partly: the generator, core layering, affinity and reaping carry over. No async, no schema 3, no native dependencies. | static: `integrations/react-native/src/main.c:489-491, 532-540, 1043-1070`; `templates/Core.cpp.in:208-232, 279-411`; README.md:112. CI: run 43811752367 (2ed67336) green |
| Async in the generator | None. `CallInvoker` is forwarded to the base class only. No Promise, emitter or `invokeAsync`. | Gap | static: `templates/Module.h.in:22`, `Module.cpp.in:61-62`; BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md:1756-1775 |
| Export boundary types | `int`, `bool`, `Float64`, `str`, unit result. No contexts, captures, flags, variadics or suspension. | Enough for a byte/text port. Exports cannot touch SQLite or HTTP (both need contexts). | static: `hir/exports.tcl:48, 166-213` |
| Application library (`NAME_main`) | Runs an entry program on the calling thread, blocking, with its own contexts. Vm made and dropped inside the call. No bound on duration. Exports in the same library. Schema 3 manifest. | Yes: the service. | static: `native/src/runtime/library.rs:656-686`; `native/library.tcl:706-720, 972-991`; RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md. observed: probe E |
| Instance rules | Owner token per thread. WRONG-THREAD, REENTRANT-CALL, INVALID-INSTANCE refused. `NAME_main` refused only while this thread has an active call of the library. | Yes | static: `library.rs:196-370, 658-663`. observed: probe E (WRONG-THREAD) |
| Library to host notification | None. `callback c fn` is synchronous only, during a noescape C call. Exports cannot take function pointers. | Gap, closed by a blocking export (pump thread) | static: `native/src/runtime/callback.rs:29-30, 97-98`; C-CALLBACK-MILESTONE-1.md:904-914 |
| `std::thread` / M4 threads in a library | Thread entries compile, but `spawn` returns `-2-ENOSYS` (no Vm factory in libraries). The factory is set only for executables and the JIT. | Not available, not needed | static: `native/src/runtime/thread.rs:90-92, 286-290`; `native/src/runtime/aot.rs:302`; RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md:1125-1127 |
| Remote actors (`std::actor::remote`) | Typed, schema-fingerprinted, bounded, backpressured calls between Botlish VMs. Undelivered, ServiceEnded and Stale outcomes. | Not reachable from a foreign thread: no C ABI into the transport. M5's `botlish_thread_post` exists only in a census. | static: `stdlib/actor/remote.bot:75-524`; `thread.rs:1254-1300`; THREAD-ACTOR-ARCHITECTURE-CENSUS.md:322, 1387-1401. observed (doc): th-calls, th-transport |
| Event loop | `std::event_loop`: tasks, timers on the driver's clock, Lossy/Coalesce/Reliable sources, generation-checked revocation, the `Owner` resource. Deterministic driver for tests. | Yes | static: `stdlib/event_loop.bot:46-111, 259-267, 1698-1851`; `stdlib/event_loop/deterministic.bot` |
| Linux driver `event_loop_linux` 0.5.0 | epoll, eventfd, endpoints, one-shot watches, pumps. ABI 2 lets any thread post 4 scalars. | Yes on Linux. On Android it fails to compile below API 35 (`epoll_pwait2`). No Android view. | static: `packages/event_loop_linux/native/botlish_event_loop.h:32-107`, `event_loop_linux.c:715-729`. observed: NDK r29 compile at android21/24/28 fails, android35 passes |
| Sendable / `std::transfer` | Values copied between VMs as bytes. Payload enums sendable. | Not needed in the recommended design (one service VM). Kept for a future M4 worker. | static: SENDABILITY-AND-VALUE-COPY-MILESTONE-1.md:164-243 |
| Coroutines on android-aarch64 | Compiled (the AArch64 switch). An application library's entry running a coroutine was run under qemu-user. Never on a device. | Needed by the event loop's tasks | static: ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md:224; `tests/android-target.test:702-716` |
| Tagged heap pointers | Fixed: the address word keeps Android's top byte. | Yes | static: RN-ANDROID-TAGGED-POINTER-CORRECTNESS-MILESTONE-1.md; `native/src/codegen/target.rs:138-147` |
| Android packaging of a Botlish library | 16 KiB `max-page-size`, `-z defs -z text`, SONAME, Bionic-only `NEEDED`, the unload rule (pthread keys, `RTLD_NODELETE`). | Yes | static: `native/library.tcl:422-443, 468-514`; RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md:735-760 |
| sqlite-botpkg 0.1.0 | Engine context, generation-checked handles, scoped Transaction resource, typed values, savepoints. Linux x86-64 and macOS AArch64. | Yes: storage | static: sqlite-botpkg/sqlite/sqlite.bot. CI: its run 43608099240 at e5c6c03 (as its repository records it). observed: probe A |
| `http` 0.2.0 + `boringssl` 0.20261020.0 | Hyper 1.12 and BoringSSL driven by Botlish turns. Headers, cancel tokens, timeouts, body limits. Linux x86-64 only. One thread per process owns the runtime. | Yes, once ported | static: `packages/http/http.bot`, `native/src/*.rs`; `tools/package-repository.tcl:806` |
| JSON | No package. `examples/dfa/json/` has a declared recognizer, lexer and certified emitters, not a decoder to typed values. | Gap: Petstore bodies and the bridge's messages need one | static: `examples/dfa/json/` |
| Payload enums and exhaustive `match` | Present: Outcome, Resolution and Remote are payload enums in probe B. | Yes | static: PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md, PORTABILITY-EXHAUSTIVE-MATCH-MILESTONE-1.md. observed: probe B |

Three earlier documents disagree with the code. RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md
section 23 (`:1115-1119`) still lists tagged pointers as open; the tagged-pointer
milestone fixed them. REACT-NATIVE-TARGET-CENSUS.md:1151-1154 calls program
information thread-local and the context area process-wide; PER-THREAD-RUNTIME-STATE-MILESTONE-1.md
made both per-Vm. BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md:1757 projects
Promise methods on "a Botlish-owned thread (M4)"; no library can start one.

---

## 3. Petstore v2/v3 contract comparison and pinned selection

The specifications were downloaded verbatim. Both services were probed with
41 (v2) and 45 (v3) requests between 20:28 and 20:35 UTC on 2026-11-17. The
probes touched only pets created for the purpose, with random large ids and
distinctive names, and deleted them afterwards. The log is outside the
repository (the census's scratch directory). Its findings are below.

### 3.1 The published documents (observed)

| | v2 | v3 |
|---|---|---|
| URL | https://petstore.swagger.io/v2/swagger.json | https://petstore3.swagger.io/api/v3/openapi.json (also `openapi.yaml`, 22,091 bytes, same content) |
| Size, SHA-256 | 13,843 B, `0d4ed60cd5f3816bd0f2cc14f018a5e8a4f9a4d7e6ef161b843f6203ed1cb0a1` | 17,106 B, `00441c05add60f28da55eb4563d3fb6bbda364ba8eb7b381e2e2c98613005c82` |
| Format, version | `swagger: 2.0`, `info.version` 1.0.9 | `openapi: 3.0.4`, `info.version` 1.0.27 |
| Upstream | swagger-api/swagger-petstore tag `swagger-petstore-v2-1.0.9` = `ad934b2a1d4fe4bb22b54eeaaa2879e66bbb4083`, released on the day of the audit. The spec is generated at run time from JAX-RS annotations, so no spec file exists in the repository. | tag `swagger-petstore-v3-1.0.27` = `8f0dd286987880b4af7bce552aca3813166f3049` (2025-08-06). `src/main/resources/openapi.yaml` (SHA-256 `0d810997f6409d5cff6f0cf2c1466814ba52250a784cd841cacb93514c7a8502`) equals the deployed document except `x-swagger-router-*` and `servers[0].url`. Tag 1.0.29 differs only in `info.version`. |
| Local image | `swaggerapi/petstore:1.0.9` (`sha256:0e1dfe75...eb64649`) | `swaggerapi/petstore3:1.0.27` (`sha256:749432676c31cd05256f0d9e878302164debb94daa1c1223e193747e1b34e7d1`, amd64). In memory, with 10 seed pets, ids 1-10. |
| Cache headers | none: no ETag, no Last-Modified | none |

### 3.2 The contract (static, from the documents)

| Item | v2 1.0.9 | v3 1.0.27 |
|---|---|---|
| Base | `https://petstore.swagger.io/v2` | `servers: [{url: /api/v3}]` (relative) |
| Pet | `id` int64; `name` (required); `photoUrls` string[] (required); `category {id, name}`; `tags [{id, name}]`; `status` enum available/pending/sold | the same |
| List | `GET /pet/findByStatus?status=` an array (`multi`) | a single status |
| Read | `GET /pet/{petId}`: 200, 400, 404 | 200, 400, 404, default |
| Update | `PUT /pet` (the whole Pet): declares 400, 404, 405 only, no 200 | 200, 400, 404, 422, default |
| Field update | `POST /pet/{petId}` with form fields `name`, `status` | the same path, with **query** parameters |
| Create, delete | `POST /pet` (declares 405 only), `DELETE /pet/{petId}` | 200/400/422; delete 200/400 |
| Security | `petstore_auth` (OAuth2 implicit, `write:pets`) on writes; `api_key` header on `getPetById` | the same |
| Concurrency | **none**: no revision field, no ETag, `If-Match` or `Idempotency-Key` declared | **none** |

### 3.3 Behaviour (observed 2026-11-17 20:32-20:35 UTC)

| Question | v2 | v3 |
|---|---|---|
| Listing | 203 available pets (30 KB JSON). **177 ids exceed 2^53-1; 173 collapse when read as a JS number.** Max id 9223372036854775807. 59 lack a category, 1 lacks `photoUrls` (which is required). | `[]` (the seed pets were gone) |
| Statuses actually stored | `/store/inventory`: `"string":686`, `"unavailable":2`, `"8":1` beside the enum's values. `status=flying` is accepted on write and stored. | the query parameter is checked against the enum (400) |
| Several statuses | only the first `status=` value is used; comma-separated works | single status only |
| Ids beyond 2^53 | round-trip with exact digits (JSON and XML) | not testable: every pet read or write returned 500 |
| Read after write | create + 5 GETs, then PUT + 10 GETs over 12 s: every read fresh in this window. Nothing guarantees it: one in-memory map, `MAX_SIZE = 1000`, oldest evicted (static, upstream source). 203 became 202 in two minutes. | — |
| `If-Match: "bogus"` on PUT | **ignored**: 200, write applied | 500 |
| `If-None-Match` | ignored | 500 |
| PUT of a nonexistent id | **upsert**: 200, created | 500 (source: 404) |
| PUT `{id, name}` only | **whole replacement**: category and status removed; `photoUrls`, `tags` emptied | 500 (source: delete + add) |
| Form update | changes only `name`/`status`; an empty field is ignored; 404 for a missing pet | 500 (source: `status` set to null when omitted) |
| Authentication | not enforced: every write succeeded without credentials | no 401/403 seen |
| DELETE | 200, then GET 404, a second DELETE 404 | 500 (source: always 200) |
| Latency | median 0.18 s | median 0.17 s |

### 3.4 Selection

**Pin the v3 contract, 1.0.27.** The pin has three parts:

- the deployed document's URL and SHA-256 above;
- the upstream file `swagger-api/swagger-petstore@8f0dd286...:src/main/resources/openapi.yaml` (SHA-256 `0d810997...`);
- the local image `swaggerapi/petstore3@sha256:74943267...`.

v3 is a version that exists as a file in a tag, which v2 does not. Its
single-status query, its 200 and 422 declarations and its enum checks are
the better reference. v2 serves as reference only: generated at run time,
changed on the audit's day, declaring no success code for writes.

The public services offer neither profile what synchronization needs. There
is no revision, no conditional write and no idempotency key. Data is shared,
mutated and evicted, and holds off-enum values. During the audit v3 was down
for every pet operation. Section 10 therefore defines two profiles:

- **Controlled profile**, the test oracle: the v3 1.0.27 resources and operations plus an explicit concurrency contract.
- **Public profile**: the documented and observed public behaviour only, weaker and labelled so. Used only for a smoke test.

The public service is never modified, and no extension is ever claimed for it.

**Consequences for the domain** (observed facts, not assumptions):

- **Statuses.** A remote pet can carry a status outside the enum. The domain keeps it (`PetStatus::Other {text}`), displays it, and never invents one.
- **Full replacement.** `PUT` replaces the whole resource, so on the public profile a client that sends only `{id, name, status}` destroys category, tags and photos. The baseline therefore stores the full remote document, and a public-profile write sends that document with only the edited fields changed.
- **Identity.** Pet ids must never be JS numbers.

---

## 4. Intended product and domain model

### 4.1 The slice

Milestone 1 of the application implements exactly these ten features:

1. browse locally stored pets;
2. filter by status;
3. view a pet's details;
4. edit a pet's name and status;
5. save edits immediately, offline or not;
6. force offline mode (the kill switch);
7. see what is pending synchronization;
8. resume synchronization;
9. inspect synchronization failures;
10. resolve a conflict when the same field changed locally and remotely.

Pets enter the local database by refreshing from the server (list and
detail reads), never by local creation.

**Creation and deletion are deferred.** Edits to existing pets already
exercise durable persistence, conflict detection, retries, remote identity
and three-way reconciliation. Creation adds a second identity space:
client-provisional ids mapped to server ids, an idempotent create, and a
create racing a list refresh. Deletion adds tombstones and delete-versus-edit
conflicts. Remote *deletion* is still handled in milestone 1: a refresh or
send that finds a pet gone is an outcome (`RemoteDeleted`, probe B).

Out of scope, as the prompt says: media uploads, authentication workflows,
carts and orders.

### 4.2 The domain model (proposed Botlish; not compiled)

The domain model is neither a database row nor Petstore's JSON. Rows and
documents are its storage and its transport representations.

```botlish
# petstore_domain::model -- the domain's own values (proposed).
type RemoteIdValue = Int in 1..9223372036854775807

# A pet's stable identity: Petstore's id (milestone 1 has no local creation).
# It crosses the JS boundary as its decimal text, never as a number.
struct PetId:
    value: RemoteIdValue

enum PetStatus:
    Available,
    Pending,
    Sold,
    # A status the server holds outside the enum (observed: "string", "8"):
    # displayed and preserved, never chosen by an edit.
    Other {text: str},

# The editable fields: what reconciliation merges.
struct Fields:
    name: PetName
    status: PetStatus

# A server revision: opaque (the controlled profile's ETag), or none (the
# public profile has no revision).
enum Revision:
    Known {tag: str},
    Unversioned,

# The last state both sides confirmed: the fields, the revision, and the
# full remote document (category, tags, photoUrls and unknown members kept
# for a whole-resource write on the public profile).
struct Baseline:
    fields: Fields
    revision: Revision
    document: str

# A pet as the UI sees it: the local state, and where it stands.
struct Pet:
    id: PetId
    fields: Fields
    sync: SyncState
    conflict: bool

enum SyncState:
    Synced,
    Pending,
    Sending,
    Unknown,
    RetryWaiting {at_us: int},
    Conflicted,
    Rejected {reason: str},
```

**Validation, mutability and optional fields:**

- **Identity** is immutable.
- **Name** is required. `PetName` is a `refined type PetName = str` proved by a validator (1..100 Unicode scalar values, no control characters; the length rule is the census's proposal). Petstore declares no length; the controlled server enforces the same rule with 422.
- **Status** may be set by an edit only to the three enum cases. A remote `Other` value survives every merge in which the user did not edit the status.
- **Category, tags and photoUrls** are not modelled as editable. They live only in the baseline document.
- **Unknown members** of a remote JSON object are preserved in that document.
- **Optional fields** are `Revision::Unversioned` on the public profile, and the absence of a baseline before the first fetch. Neither is a null.

### 4.3 Realistic scenarios that shaped the design

| Scenario | What it forces |
|---|---|
| Edit pet A offline, then pet B offline | per-pet intentions, independent (section 8) |
| Edit the same pet several times before synchronization | one intention per pet, the base kept, the payload computed at send (probe A: `m-1`, base 1 kept across edits) |
| Close and reopen the app | everything durable is in SQLite; the JS cache is derived |
| Toggle forced offline mid-sync | the gate and the `unknown` state (section 6) |
| Server error 5xx | retry with backoff, bounded |
| A conflicting remote edit | 412 or a fetched remote state, then three-way merge |
| Resolve the conflict, then restart | the resolution is one transaction: base, local state, intention (probe B case 9, section 7) |
| Restart during a partly completed synchronization | `in_flight` becomes `unknown` and is resolved by a read before any resend (probe A: `recover`) |

---

## 5. Offline consistency guarantees

The UI reads committed local SQLite state, never the network. A local edit
is reported as saved when its transaction has committed. Remote
synchronization is a separate, failure-prone activity.

### 5.1 From edit to remote confirmation

| # | Stage | Durable effect | What the UI may say |
|---|---|---|---|
| 1 | Edit accepted by the domain (validated) | none | nothing yet |
| 2 | Local transaction committed: pet row, outbox intention, local revision | committed together or not at all | **saved** (locally), *pending* |
| 3 | Intention eligible: policy allows, not waiting for a retry, no conflict | none (derived) | pending |
| 4 | Selected for sending: `in_flight`, the sent snapshot and `attempts+1`, committed **before** the exchange starts | committed | syncing |
| 5 | Request transmitted (unknowable to the client) | — | syncing |
| 6 | Remote outcome received: 2xx, 412, 4xx, 5xx, or nothing | — | — |
| 7 | Outcome applied locally in one transaction: base, intention state, conflict | committed | synced, conflict, failed or retry |

The UI never shows "synced" for a pet whose intention is not gone. It never
treats stage 2 as stage 7, and never treats a lost response (stage 6 with
nothing) as stage 7 with a failure.

### 5.2 Guarantees offered

| Guarantee | Offered? | Owner |
|---|---|---|
| Read-your-writes (local) | Yes. Every read is a committed snapshot. The command that committed returns the new local revision; a later snapshot is at least that revision. | domain |
| Monotonic local snapshots | Yes. `local_revision` increases by one per committed change. Notifications carry it; the JS cache refuses a snapshot older than the newest it has seen. | domain + hooks |
| Per-pet mutation ordering | Yes. One intention per pet, compacted. The state sent is the newest local state at send time. | domain |
| Cross-pet ordering | No. Pets synchronize independently, and their order on the server is unspecified. | — |
| At-least-once delivery attempts | Yes, while the policy allows, the server is reachable and the attempt bound is not exhausted | domain |
| Idempotent server application | **Only on the controlled profile** (`Idempotency-Key`, section 10). The public profile retries a PUT that is idempotent in effect but last-writer-wins. | server |
| No lost update | **Only with `If-Match`** (controlled profile). The public profile has a race window between a read and a write (section 10.3). | server + domain |
| Eventual synchronization | Yes, if: the policy is eventually allowed; the server is eventually reachable and accepts the change (no permanent rejection); every conflict is eventually resolved by the user; and the attempt bound is not exhausted. | domain |
| Automatic resolution | Disjoint field changes only (section 9) | domain |
| User-mediated resolution | Same-field conflicts and remote deletion of an edited pet | domain + UI |
| Exactly-once remote execution | **Not claimed.** A key makes repeats harmless on a server that honours it; it does not make a request happen once. | — |

---

## 6. The offline kill switch

### 6.1 Two inputs, never merged

| Input | Meaning | Where it lives |
|---|---|---|
| Network **permission** (`network_policy`) | The user's choice: `allowed` or `forced_offline`. A phone with Wi-Fi can be forced offline. | durable: `sync_state`, committed before it takes effect |
| **Reachability** | What the last attempt taught: reachable, unreachable (connect failure, DNS failure), or untested | runtime only: the service's state, never persisted (a restart retests) |

### 6.2 State diagram (proposed)

```
                    setOffline(true)  [policy committed first]
     +-----------------------------------------------------------+
     |                                                           v
 +--------+  sync due   +--------------+  all done  +--------+  +-------------------+
 | ONLINE |-----------> | SYNCHRONIZING|----------->| ONLINE |  | FORCED_OFFLINE    |
 | ALLOWED|<----------- | (gate open)  |            | ALLOWED|  | gate closed;      |
 | (idle) |  nothing    +--------------+            +--------+  | timers revoked;   |
 +--------+  eligible     |  |   |                              | started exchanges |
   ^   ^                  |  |   | 412 / remote diverged        | cancelled, their  |
   |   |   transient fail |  |   v                              | intentions UNKNOWN|
   |   |   (5xx, timeout, |  | +------------------+             +-------------------+
   |   |    unreachable)  |  | | CONFLICT_PENDING |  (derived:          |
   |   |                  v  | | >= 1 conflict row|   orthogonal to     | setOffline(false)
   |   |    +-------------+  | +------------------+   the others)       | [policy committed]
   |   +----| RETRY_WAIT  |  |                                          v
   |  timer | (one timer, |  | 401/403/422: REJECTED (that intention    +-------------+
   |  fires | backoff +   |  |  stops; no retry)                        | RESUMING:   |
   |        | jitter)     |  |                                          | UNKNOWNs    |
   |        +-------------+  |                                          | first, by   |
   +-------------------------+------------------------------------------| reads; then |
                                                                        | jittered    |
                                                                        | sync        |
                                                                        +-------------+
```

`CONFLICT_PENDING` is derived (any conflict row) and coexists with every
other state: a conflicted pet's intention waits, others proceed.
`FORCED_OFFLINE` dominates: no transition leaves it but `setOffline(false)`.

### 6.3 What enabling forced offline does, in order

All of these steps run on the service VM's thread:

1. Commit `network_policy = forced_offline`. The reply to the command follows this commit.
2. Close the gate. It is a value the gate reads; the gate is the only code that holds the `http` client.
3. Revoke the retry timer (its `Owner`) and refuse new sync schedules.
4. Cancel every started exchange by releasing its `ExchangeOwner`. Hyper resets the HTTP/2 stream or closes the HTTP/1.1 connection (`packages/http/http.bot:1416-1420`; GUIDE.md:266-275).
5. Commit `state = 'unknown'` for each intention that was `in_flight`. Its request may have been transmitted and applied.

Local reads and writes continue unchanged throughout, and the outbox keeps every intention.

### 6.4 The cancellation race

The intention is committed `in_flight` before `start` (stage 4). From then
on the client cannot know whether bytes left, so:

| Ordering | Result |
|---|---|
| switch before the gate's check | no exchange; intention stays `pending` |
| exchange started, switch, response arrives before cancellation takes effect | **The response is applied.** A 2xx confirmation or a 412 conflict is information, not network activity. Applying it is correct and safe. |
| exchange started, switch, cancellation, no response | `unknown`: possibly applied remotely |
| exchange started, switch, cancellation, transport error | `unknown` |
| exchange started, process killed | `in_flight` on disk; `recover` at start makes it `unknown` (probe A) |
| switch off later | `unknown` intentions are resolved by a **read** (GET with the revision) before anything is resent; then a send with a fresh key if still needed |

The switch is a local policy boundary: it stops *initiation*. The UI
wording follows it: "Offline. 1 change may already have reached the server
and will be checked when you go online."

### 6.5 Enforcement

The prohibition is enforced where an exchange begins, inside the service,
never in React Native.

- **Static authority.** The domain modules never install or receive the `http` context. One transport module holds it, behind private functions (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md). The pure parts are wrapped in `inject context Storage:` blocks, so the compiler proves that local editing, reconciliation and recovery cannot reach the network (RESTRICTED-CONTEXT-INJECTION-MILESTONE-1.md). Contexts are static: they make the gate unavoidable, not revocable.
- **Dynamic policy.** Contexts select implementations once per program and are never revoked. The policy is therefore a value in the service's context-owned state, which the gate reads.
- **No race.** The gate's check and the exchange's `start` run in one task step with no suspension between them. Nothing on the loop's thread can change the policy in between, and no other thread can run Botlish code in that VM.
- **Paths that might bypass it.** A retry timer firing after the switch reaches the gate and is refused. An old queued task does the same. No reconnect callback exists: Hyper's connections are pooled per client, and the gate decides before `request`.

A product-level mutation test catches a bypass (section 22: "network send
after offline policy changed").

---

## 7. SQLite schema and transaction model

### 7.1 Proposed schema (concrete; probe A runs a reduced form of it)

```sql
-- One version row per applied migration; a migration and its row commit
-- together (SQLite DDL is transactional), so an interrupted migration
-- leaves the previous version whole.
CREATE TABLE schema_migrations (
  version     INTEGER PRIMARY KEY,
  applied_rev INTEGER NOT NULL            -- local_revision at application
);

-- The locally visible state: what the UI reads.
CREATE TABLE pets (
  pet_id    INTEGER PRIMARY KEY,           -- Petstore id (1..2^63-1)
  name      TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 100),
  status    TEXT NOT NULL,                 -- 'available'|'pending'|'sold'|other text
  local_rev INTEGER NOT NULL               -- local_revision of its last change
);

-- The last state both sides confirmed. Never written by a local edit.
CREATE TABLE pet_baselines (
  pet_id     INTEGER PRIMARY KEY REFERENCES pets(pet_id),
  name       TEXT NOT NULL,
  status     TEXT NOT NULL,
  remote_rev TEXT,                         -- ETag/revision; NULL: unversioned (public profile)
  document   TEXT NOT NULL,                -- full remote JSON (category, tags, photoUrls, unknown members)
  fetched_at INTEGER NOT NULL              -- wall-clock microseconds, for display only
);

-- One durable intention per pet with local changes since its base.
CREATE TABLE outbox (
  pet_id       INTEGER PRIMARY KEY REFERENCES pets(pet_id),
  mutation_key TEXT NOT NULL UNIQUE,       -- Idempotency-Key of the current send generation
  base_rev     TEXT,                       -- the precondition (If-Match) the payload was merged against
  state        TEXT NOT NULL CHECK (state IN
                 ('pending','in_flight','unknown','retry_wait','conflicted','rejected')),
  attempts     INTEGER NOT NULL DEFAULT 0,
  not_before   INTEGER,                    -- retry_wait: the loop clock's deadline, re-based at start
  sent_name    TEXT,                       -- the snapshot sent (in_flight/unknown)
  sent_status  TEXT,
  last_error   TEXT,                       -- a classified reason, never a request body
  created_rev  INTEGER NOT NULL,
  updated_rev  INTEGER NOT NULL
);

-- Unresolved conflicts; one per pet (a new detection replaces it).
CREATE TABLE conflicts (
  pet_id        INTEGER PRIMARY KEY REFERENCES pets(pet_id),
  kind          TEXT NOT NULL CHECK (kind IN ('fields','deleted')),
  fields        TEXT NOT NULL,             -- 'name', 'status', 'name,status' or ''
  base_name TEXT, base_status TEXT,
  local_name TEXT, local_status TEXT,
  remote_name TEXT, remote_status TEXT,
  remote_rev    TEXT,
  remote_document TEXT,
  detected_rev  INTEGER NOT NULL
);

-- Policy and counters: 'network_policy' ('allowed'|'forced_offline'),
-- 'local_revision', 'list_cursor', 'last_sync_ok_at', 'backoff_level'.
CREATE TABLE sync_state (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

The outbox carries **no copy of the edit**. It is the durable intention
"pet P has local changes since base revision R". The payload is computed at
send time from the pet and its base. Repeated edits therefore compact by
construction, and the base is never overwritten by a local edit. Probe A
runs a reduced form of this schema: one pet, no conflicts table, an integer
revision.

### 7.2 Transaction boundaries

There is exactly one writer, the service VM's connection. Every write is an
`IMMEDIATE` transaction (`sqlite::begin_immediate`,
`sqlite-botpkg/sqlite/sqlite.bot:1118`), which takes the write lock at
`BEGIN`. A busy condition can therefore surface only at `BEGIN`, never at
`COMMIT`. That matters because the package turns a busy `COMMIT` into a
rollback (`consumer/ac_transactions.bot:136-161`).

| Command | One transaction containing |
|---|---|
| `updatePet(id, fields)` | `UPDATE pets`; `local_revision += 1`; the outbox `INSERT ... ON CONFLICT(pet_id) DO NOTHING` from the base; a conflict row left as is (the edit is the user's newer local value) |
| select for send | `state = 'in_flight'`, `attempts += 1`, the sent snapshot; nothing else |
| apply a 2xx | base := sent snapshot @ new revision, merged into the stored document; the intention deleted if `pets` equals the new base, else back to `pending` against the new revision with a new key (probe A, `confirm`) |
| apply a conflict | the conflict row; the intention `conflicted`; the base unchanged |
| resolve | base := the conflict's remote state @ its revision; `pets` := the chosen state; the intention re-made against that revision, or deleted when the choice equals the remote state; the conflict row deleted |
| refresh (list or detail) | per pet: no intention, so adopt (base and `pets` := remote); with an intention, store the remote observation for the next send's merge, never overwriting `pets` |
| set offline | `network_policy`; then, in a second transaction after cancellation, `in_flight` becomes `unknown` |
| recover (start) | `in_flight` becomes `unknown` |

**The invariant.** A committed local edit and its durable synchronization
intention exist together, or neither does. Probe A observes it across a
process aborted between the two writes and the commit: the hot journal
rolls back, and the pet and the outbox are both unchanged.

### 7.3 Durability settings

| Setting | Choice | Why |
|---|---|---|
| Location | Android: the application's private files directory, an absolute path supplied by the platform entry. Linux tests: a temporary directory. | The domain never computes a path. On Android, SQLite's temporary-file search finds nothing writable (section 12). |
| `journal_mode` | `WAL`, persistent | With one writer, WAL's concurrency gain is nil. It saves fsyncs per commit and keeps a crashed writer's state recoverable. sqlite-botpkg has never exercised WAL (its oracle asserts DELETE, `scripts/oracle.sh:20`), so the storage milestone tests it. |
| `synchronous` | `FULL` | In WAL mode NORMAL keeps the database consistent but may lose the last commits on power loss. A commit the UI reported as saved must survive, so NORMAL is refused. |
| `temp_store` | `MEMORY` (pragma), or `-DSQLITE_TEMP_STORE=3` in the Android build | Android has no `TMPDIR` |
| `foreign_keys` | `ON` per connection | off by default |
| `busy_timeout` | 2000 ms | A single writer should never be busy. Another process (a debugger, a backup) waits briefly, then the command fails: never a false success. |
| Read connection | none in milestone 1 | All queries run on the service thread between turns. A second connection adds a thread question (connections never cross VMs: `Connection` is not sendable, THREAD-ENTRY-SIGNATURE) and no benefit at this scale. |

### 7.4 Failures

| Condition | Behaviour |
|---|---|
| `Busy`/`Locked` at `BEGIN` after the timeout | The command fails (`StorageBusy`); nothing changed; the UI keeps the user's input |
| `Full`, `IoErr` at a step or `COMMIT` | The transaction is rolled back by SQLite or by the Transaction's cleanup. The command fails (`StorageFull`/`StorageIo`) and is never reported saved. The original code surfaces at the failing step; a later `commit` reports "no transaction active" (static reading of sqlite.bot:1130-1140). The domain treats any failure inside the transaction as "not committed". |
| `Corrupt`/`NotADatabase` at open or later | The service enters `storage_failed` and serves no writes. The database is never deleted or "repaired" automatically. Export and reset come later. |
| Interrupted migration | rolled back (one transaction per version); the service refuses to start on an unknown future version |
| Close with an open transaction | `sqlite3_close_v2` rolls it back (static): the shutdown path closes after every command has finished |

### 7.5 Portability

The domain is identical on every platform: same SQL, same modules. The
platform entry installs `sqlite::engine()` and passes the database path.
Linux tests use a temporary directory; macOS works the same way. The
sqlite-botpkg agent's probe compiled an outbox program for
`-target android-aarch64` (`-check`, NIR with `link "botsqlite3"`, 36 C
calls) with no `.bot` change (observed).

---

## 8. Outbox and crash-recovery model

### 8.1 Durable mutation state machine

```
 local edit (txn: pets + intention)
          |
          v
     +---------+   eligible (policy allowed, no conflict, not waiting):
     | pending |---------------- select, commit in_flight + snapshot + attempt
     +---------+                            |
       ^  ^  ^                              v
       |  |  |                       +-----------+  2xx, pets == new base   +-----------+
       |  |  |                       | in_flight |------------------------->| (deleted) |
       |  |  |  2xx, pets edited     +-----------+                          | confirmed |
       |  |  +-- meanwhile: base := sent @ rev', new key, pending           +-----------+
       |  |                        |  |   |   |
       |  |   timer (not_before)   |  |   |   | 412/409, or the read shows divergence
       |  +---------+ retry_wait <-+  |   |   v
       |   transient | (backoff)      |   | +------------+ resolve (txn) --> pending or deleted
       |   (5xx, 429,|                |   | | conflicted |
       |   connect   |                |   | +------------+
       |   refused)  |                |   |
       |             |                |   +-- 401/403/422/404-on-update: rejected
       |             |                |       (stops; the user edits or discards)
       |             |                v
       |             |  timeout / reset after start / offline switch / crash (recover)
       |             |           +---------+   read (GET) resolves it:
       +-------------+-----------| unknown |   remote == sent  -> confirmed path
                                 +---------+   remote == base  -> pending (fresh key)
                                               otherwise       -> three-way merge
```

Every state but "eligible" and "confirmed" is persisted. Eligible is
derived; confirmed is the row's deletion, or its reset against a new base.
`unknown` is never sent again blindly. On the controlled profile a resend
with the **same** key is allowed instead of a read: the server replays the
stored response, so a duplicate is harmless (section 10).

### 8.2 Crash points and recovery

Every row assumes the process dies at that point and starts cold. "Probe A"
marks the rows its transcript observes (section 20.1).

| # | Crash point | Durable contents after restart | Allowed next action | Retry safe? | Inspect remote? | User? |
|---|---|---|---|---|---|---|
| 1 | Before the local transaction commits | The old pet; no intention for this edit (the hot journal rolled back: **probe A**) | none; the edit is lost and was never reported saved | — | no | The UI showed "saving" only. React Native also lost its state; the edit was not committed. |
| 2 | Immediately after the local commit | New pet + `pending` intention (**probe A**) | send when eligible | yes | no | no |
| 3 | After selecting a pending intention (the transaction that marks it `in_flight` committed) | `in_flight` + snapshot | `recover` makes it `unknown`; then read, or resend with the same key (controlled) | with the same key: yes; blind resend on the public profile: last-writer-wins | yes (public) | no |
| 4 | Before transmission | the same as 3: the client cannot tell 3, 4 and 5 apart | as 3 | as 3 | as 3 | no |
| 5 | During transmission | as 3 | as 3 | as 3 | as 3 | no |
| 6 | Server committed, response not received | as 3; the server holds the sent state at a new revision | as 3: the read finds remote == sent, so the base is adopted and the intention dropped or rebased | yes | yes | no |
| 7 | Response received, local acknowledgement not committed | as 3 | as 6 | yes | yes | no |
| 8 | While recording a conflict | `in_flight` (that transaction rolled back) | recover to `unknown`; the read sees the divergence again and records the conflict | yes | yes | no |
| 9 | During conflict resolution | The conflict row and the `conflicted` intention, untouched (resolution is one transaction) | The conflict is shown again | — | no | yes, to choose again |

The rule behind every row: **a timeout is never proof of non-application**,
and a crash between transmission and acknowledgement is resolved by reading
the server, never by assuming.

### 8.3 Idempotency

- The **mutation key** (`m-<local_revision>` in probe A; a random 128-bit value in production) is local. It identifies a send generation. A new key is made when the intention is rebased on a new revision.
- A key becomes an **idempotency key** only on a server that stores the response by key and replays it (section 10). On such a server an identical repeated update under the same key is safe. A repeated update under a new key is guarded by `If-Match`: it fails with 412 if anything changed meanwhile, including its own first application.
- On the public profile neither holds. A blind resend is last-writer-wins.

### 8.4 Retry policy

| Error class | Example | Policy |
|---|---|---|
| Not allowed | forced offline | no attempt; nothing counted |
| Unreachable before send | DNS failure, connection refused, `unreachable` | `retry_wait`, exponential backoff (1 s, 2 s, ... capped at 5 min), full jitter |
| Ambiguous after possible send | reset, timeout after the request began | `unknown`; resolved by a read (or a same-key resend, controlled profile) |
| TLS verification failure | `TrustFailed` | stop all sending (`rejected` reason `tls`): never retried in a loop, never downgraded |
| Unauthorized | 401/403 | stop all sending (`rejected` reason `auth`) until the configuration changes |
| Validation | 400/422 | that intention `rejected`, shown to the user; others proceed |
| Conflict | 412 (409 for a key reused with another body) | read, then merge (section 9) |
| Overload | 429/503 (honour `Retry-After`) | `retry_wait` with that delay as the floor |
| Missing | 404 on update | treated as remote deletion (section 9) |
| Permanent | anything else 4xx | `rejected` |

Attempts are bounded: after 8 failures in a row the intention stays
`retry_wait` and is resumed only by an explicit `syncNow` or a later policy
change.

**No retry storm.** When the switch turns back on, the service resolves
`unknown` intentions first, then schedules one sync after a random 0-2 s
delay. A sync processes intentions one pet at a time, with at most four
exchanges in flight.

Timer design is the event loop's (`std::event_loop` timers on the driver's
clock). One retry timer exists per service, never one per intention.

---

## 9. Reconciliation algorithm

### 9.1 Per field

`b`, `l`, `r` are a field's base, local and remote values.

| Case | Condition | Result | Example |
|---|---|---|---|
| unchanged | `l == b`, `r == b` | `b` | — |
| remote only | `l == b`, `r != b` | `r` | status `available` became `pending` remotely |
| local only | `l != b`, `r == b` | `l` | name `Milo` became `Milo Jr.` locally |
| both, equal | `l != b`, `r == l` | `l` (converged) | both renamed to `Max` |
| both, different | `l != b`, `r != b`, `l != r` | **conflict** | local `Milo Jr.`, remote `Max` |

Equality is the domain's own: names are compared as Strings, and statuses
by case, including `Other {text}` by its text. An `Other` status merges like
any other value. A local edit cannot produce one; it can only adopt or keep
one.

### 9.2 Per pet

| Remote observation | Field results | Outcome | Durable effect |
|---|---|---|---|
| Missing: 404 (or 410) on a read of the pet. Absence from a listing proves nothing: listings are filtered by status, and the public v2 service evicts. | local == base | `Drop` | pet, base and intention deleted |
| Missing | local != base | `RemoteDeleted {local}` | conflict row `kind = 'deleted'`; the user keeps it (re-create: deferred milestone) or discards |
| Present @ R | any field conflicts | `Conflict {names, base, local, remote, R}` | conflict row; intention `conflicted` |
| Present @ R | merged == remote | `Adopt {merged, R}` | base := remote @ R; `pets` := merged; intention deleted |
| Present @ R | merged != remote | `Send {merged, If-Match: R}` | `pets` := merged; intention `pending` against R (base_rev R) |

Probe B runs this table as written in ordinary Botlish, on all four
backends: ten scenarios, one value (section 20.2).

The prompt's two examples:

| | name | status | outcome |
|---|---|---|---|
| base | Milo | available | |
| local | Milo Jr. | available | |
| remote @2 | Milo | pending | **send** Milo Jr./pending if-match r2 (probe B case 1) |
| remote @3 | Max | available | **conflict** name r3 (probe B case 2) |

### 9.3 Resolution

The observed remote state becomes the new base at its revision, and the
chosen state becomes the local one. The same table then decides whether
anything is pending:

| Choice | Effect (probe B case 9) |
|---|---|
| Keep local | send Milo Jr. if-match r3 |
| Accept remote | adopt Max r3 (nothing to send) |
| Supply a merged value | send Milo II if-match r3, or adopt when it equals the remote state |
| Defer | nothing changes; the conflict persists across restarts (it is a row) |

### 9.4 When reconciliation runs

- **On a refresh** of a pet that has an intention: the remote observation is stored, and the merge runs at the next send.
- **On a 412**: GET the current state and revision, then merge. The result is either a send against the new revision, an adopt, or a conflict.
- **On `unknown`**: GET, then compare with the sent snapshot and the base (section 8.1).

---

## 10. Server concurrency and idempotency contract

### 10.1 The controlled profile (the authoritative test oracle)

A small server that keeps Petstore v3 1.0.27's resources and paths and adds
the contract below. Both the client and the tests depend on it; it is never
claimed of the public service.

| Request | Response |
|---|---|
| `GET /api/v3/pet/{id}` | 200 with the Pet plus `"revision": N` and `ETag: "N"`. 404 when absent (410 for a deleted pet that left a tombstone). `If-None-Match: "N"` gives 304. |
| `GET /api/v3/pet/findByStatus?status=S` | 200: Pets with their revisions |
| `PATCH /api/v3/pet/{id}`, `Content-Type: application/merge-patch+json`, `If-Match: "N"`, `Idempotency-Key: K`, body `{"name"?: ..., "status"?: ...}` | 200, the new Pet, `ETag: "N+1"`. An omitted member is never cleared. |
| — the same, revision moved | **412**, with the current Pet and its ETag in the body: the client merges without another GET |
| — no `If-Match` | **428** |
| — `K` seen before with an identical body | the **stored** response replayed: same status, same body, even if the revision moved since |
| — `K` seen before with another body | **422** (`idempotency_key_reused`) |
| — invalid name or status | **422**, with the field |
| — pet absent | 404 (410 tombstone): never an upsert |
| `PUT /api/v3/pet` | kept for compatibility, with the same `If-Match`/key rules; a missing id gives 404 |
| `POST /api/v3/pet` | 201 (creation is not used in milestone 1) |

Ids stay at or below 2^53-1 on the controlled server, though the client
never relies on it. Storage is durable, single-writer and never evicts. The
dataset is seeded and resettable through the control interface (section 19).

### 10.2 What each guarantee needs

| Guarantee | Needs |
|---|---|
| No lost update | `If-Match` + 412 |
| A safe resend after a lost response | `Idempotency-Key` with response replay |
| Correct detection of a response lost after commit | a read that returns the revision (ETag) |
| Field-level patch | merge-patch that never clears an omitted member (v3's form update sets `status` to null when omitted: upstream source) |

### 10.3 The public profile (weaker, labelled)

The public profile supports exactly one mode: **best-effort
last-writer-wins with read-before-write divergence detection.**

1. GET the pet and compare it with the base. Any difference goes through the section 9 merge, so a remote change made *before* the GET is never overwritten silently.
2. PUT the base document with the merged fields applied: the whole document, because PUT replaces whole resources (observed).

What it cannot do, stated in the product:

- A remote edit landing between the GET and the PUT is overwritten (there is no `If-Match`; observed: `If-Match` is ignored).
- A PUT for a pet the server evicted re-creates it (observed upsert).
- A response lost after commit can only be detected by a GET.
- Public data is shared, evicted, holds off-enum statuses and ids beyond 2^53, and v3 was unavailable during the audit.

The public profile therefore drives only a smoke test of the transport and
the TLS path: no assertion about another user's data, and no deterministic
regression test (section 19.4). An overwrite on this profile is never
reported as conflict-free reconciliation.

---

## 11. Hyper on Android: feasibility and the required port

**Verdict.** Feasible, without changing the Rust unit's source. What blocks
it is around the unit, in this order:

1. the driver's `epoll_pwait2`;
2. the C++ runtime BoringSSL needs;
3. host-only localization tools;
4. a trust source decision;
5. packaging and versioning;
6. the React Native tool's refusal of native dependencies (section 13).

### 11.1 Probe C: the unit for `aarch64-linux-android` (observed, NDK r29)

The probe worked on a copy of `packages/http/native` in scratch, with the
pinned rustc 1.100.0.

| Step | Result |
|---|---|
| `rustup target add aarch64-linux-android --toolchain 1.100.0`; `cargo tree --locked --target aarch64-linux-android -e normal` | Resolves. Tokio arrives only through hyper/h2/tokio-util with features `io-util` and `sync`: no runtime, no `net`, no mio, no socket2. |
| `cargo check --locked --target aarch64-linux-android`, no environment | **First failure:** `boring-sys-5.4.0/build/main.rs:293:18: Please set ANDROID_NDK_HOME for Android build`. This is boring-sys's vendored-CMake path, which the package never uses. |
| The recipe's link-only build (`tools/http-package.tcl:275-298`): empty `libcrypto.a`/`libssl.a`, the pinned headers, `BOTLISH_BORINGSSL_PROVIDER=0_20261020_0_d3bf4795...`, `ANDROID_NDK_HOME`, the NDK's `aarch64-linux-android24-clang` as CC, CXX and linker | `Finished release in 24.57s`, zero warnings; raw archive 29.7 MB. Link-only mode still needs `ANDROID_NDK_HOME`, because bindgen needs the NDK sysroot. |
| `rustunit::localize`'s host tools (`tools/rust-unit.tcl:256-264`) | GNU `ld -r`: `Relocations in generic ELF (EM: 183)`. GNU `objcopy`: `Unable to recognise the format`. |
| The same steps with `ld.lld -r --whole-archive` and `llvm-objcopy --strip-debug --redefine-sym DW.ref.rust_eh_personality=... --keep-global-symbols` | Exactly 20 global `bh_*`; the COMDAT group renamed; `rust_eh_personality` and the allocator shim local. 736 undefined symbols: BoringSSL's API, `_Unwind_*`, `__errno`, `__system_property_get`, sockets, pthread, weak `getrandom`/`memfd_create`/..., weak `botlish_event_post2`, the provider identity. **No glibc-only symbol.** |
| BoringSSL at the pinned commit, NDK CMake toolchain (arm64-v8a, android-24, Release, PIC) | 33 s |
| `-shared -Wl,-z,defs -Wl,-z,text -Wl,-z,max-page-size=16384`: the unit (whole archive), identity, libssl, libcrypto | Plain `clang` fails (`std::__ndk1::__libcpp_verbose_abort`, `operator delete`, `vtable for __cxxabiv1::__class_type_info`): BoringSSL is C++. **With `-static-libstdc++` (or `-lc++_static -lc++abi`) it links:** `NEEDED` = libm, libdl, libc; no TEXTREL; LOAD aligned 0x4000; 20 `bh_*`; 5.3 MB stripped. 388 libc++ exports would need hiding. `-lstdc++`, which `packages/boringssl/boringssl.bot:20` declares, gives `NEEDED libc++_shared.so`: no Bionic system library. Objects built at API 24 do not link at API 21 (`stderr`, `__write_chk`): build at the support package's `minimumApi`. |

### 11.2 Linux-only assumptions in and around the unit (static)

- **The unit has no `cfg(target_os)` at all.** Its only cfgs are `feature = "testing"` (`lib.rs:26`, `faults.rs:23-42`), so nothing is silently dropped on Android. The clean build confirms it.
- **Trust:** `SYSTEM_BUNDLES` lists five Linux PEM bundle paths (`packages/http/native/src/tls.rs:40-46`). None exists on Android, so `client()` fails with `NoSystemBundle`, reported as `TrustFailed`. Correctly: no fallback.
- **Error codes:** EAI/errno values cross raw (`net.rs:213`, `http.bot:106-116`). Bionic's `EAI_NONAME` is 8, glibc's is -2, so the module's classification needs per-target values.
- **Name resolution** is `getaddrinfo` on detached worker threads (`net.rs:115-231`). On Android this goes through netd and needs the `INTERNET` permission (projected), which React Native apps declare (`examples/react-native/app/android/app/src/main/AndroidManifest.xml:3`). The workers wake the loop through a weak `botlish_event_post2` (`notify.c:12-19`), exactly the integration ABI.
- **The driver:** `event_loop_linux.c:722` calls `epoll_pwait2`. Bionic declares it from API 35 (`sys/epoll.h:104`). Observed at android21, 24 and 28: "call to undeclared function 'epoll_pwait2'"; android35 compiles. eventfd, epoll and pthread keys compile at every level.
- **Packaging:** `boringssl` and `http` release for `linux-x86_64` only (`tools/package-repository.tcl:806`). `httppkg::Host`/`CheckTarget` refuse cross builds (`tools/http-package.tcl:122-134`). `author::cc` maps a foreign target to `aarch64-linux-gnu-gcc` (`package-repository.tcl:107-118`). The author image has Rust 1.97.0 without an Android target, but does have NDK r29 (`tools/package-build/Dockerfile:9, 79, 84-101`).

### 11.3 Event-loop integration

The unit never touches epoll. Its Botlish side asks the driver for four
things:

- one-shot watches with read/write interest, and readiness bits 1/2/4/8 (`http.bot:1131-1190`);
- an endpoint, its id and the loop handle, for foreign posts;
- `now_us`;
- a `std::event_loop::Driver`.

`Http` is created from `event_loop_linux::Native` (`http.bot:1043`), and
`with_timeout` requires it (`:771-772`).

| Option | Cost | Recommendation |
|---|---|---|
| An **android-aarch64 view of `event_loop_linux`** | `epoll_pwait` (millisecond timeout, rounded up as the existing fallback does) when the target's API is below 35. Never a raw syscall relying on ENOSYS: an older Android's seccomp filter may answer SIGSYS (projected). Plus an NDK branch in `author::cc`. The module is unchanged: no platform rule blocks it (`core/cabi.tcl:190`; the module imports no `std::linux`). | **Recommended for milestone 1.** Bionic is a Linux userspace over the Linux kernel. The driver needs kernel interfaces and POSIX threads, not glibc. |
| A portable `Driver` + `Native` context trait (HTTP-MACOS-AND-SSE-ESTIMATE.md section 3.2) | New releases of `event_loop_linux`, `http` and `process_linux` (exact locks) | Later, with macOS |
| ALooper | Only needed to share an Android Looper thread (`ALooper_addFd` of the epoll fd). The service owns its thread. | Not needed |

The adapter keeps per-thread state in a pthread-key destructor
(`close_owned`). That is safe because the library is never unloaded: it is
`NEEDED` by `libappmodules.so` (RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md
section 17, the unload rule). The same holds for the unit's ten
`thread_local!` blocks.

### 11.4 TLS trust on Android

The store is built explicitly (`tls.rs:127-164`): the first existing system
bundle plus the program's PEM anchors. There is no
`set_default_verify_paths` and no environment variable (`:13-19`).
Verification is always on: peer chain, TLS 1.2 minimum, SNI, host or IP
check, `NO_PARTIAL_WILDCARDS` (`:158-163, 332-339`).

Android has no PEM bundle. Its system anchors are individual files in
`/apex/com.android.conscrypt/cacerts` (Android 14+) or
`/system/etc/security/cacerts`: PEM followed by a text dump, named by
subject hash (projected from platform knowledge, unverified here).
BoringSSL's `by_dir` lookup tries both `X509_NAME_hash` and `_old`
(`crypto/x509/by_dir.cc:218`, static), so Android's old-hash names resolve.

The http package's rules forbid reading "another trust file" (AGENTS.md,
"The http and boringssl packages"). An Android trust source is therefore a
**design decision**, not a path addition: "the system's store, per target"
becomes Android's system CA directory. That decision must state four things:

- which directory, chosen by the API level found at run time;
- that user-installed CAs and Network Security Config are *not* honoured, so a corporate MITM CA or a debug override does not apply;
- that Conscrypt's distrust and revocation logic is not reproduced;
- the cost: about 140 files parsed per `client()`. The GUIDE measures bundle parsing at about 4 ms (`packages/http/GUIDE.md:77-78`). Directory lookup on demand avoids most of it.

No verification bypass, test hook or environment variable may join the
released unit. Tests pass their own anchors as data: the http package
already accepts program-passed PEM anchors (`tls.rs:144-154`).

### 11.5 Comparison of transports

| | A: Hyper/BoringSSL + Android driver | B: Hyper + platform verifier | C: Android HTTP stack behind a Botlish transport context | D: React Native `fetch` |
|---|---|---|---|---|
| Reuse | Highest: the same `http` package on Linux, macOS (next) and Android; the domain's transport is identical | rustls replaces BoringSSL (two providers) | A new Android-only package; the JNI side in the host | None: I/O leaves Botlish |
| Trust | System CA directory (decision above); no user CAs or NSC | Platform TrustManager over JNI | Platform: NSC, user CAs, proxy | Platform |
| Proxies, Doze, metering | No proxy support (`GUIDE.md:460-463`); sockets bypass the per-app proxy | as A | Platform | Platform |
| Botlish rules | Keeps every `http` rule but the trust-file clause | Breaks "one provider", the provider-identity link and the React Native tool's no-JNI rule; needs a JavaVM a library never gets | Needs callbacks or polling across a boundary the tool does not model | Fits today's synchronous contract, but splits retry, idempotency and offline policy between JS and Botlish |
| Native size | about 5.3 MB stripped (unit + BoringSSL + libc++) | larger | small | 0 |
| Offline policy enforcement | In the service's gate | In the gate | In the gate, if JNI calls go through the service | **In JS:** the domain no longer owns the network boundary |

**Recommendation: A.** It is the only option that keeps the domain's
transport, policy enforcement and failure classification in one Botlish
package across hosts. C is the documented fallback if the trust decision is
refused. D is rejected as the architecture (section 23), but stays useful as
a debugging comparison.

### 11.6 Features the domain needs, present today (static)

| Need | API |
|---|---|
| `If-Match`, `Idempotency-Key` | `header(name, value)`, `with_header` (`http.bot:688, 760`). Only hop-by-hop headers are forbidden (`:663-664`). |
| Reading `ETag` | `Response.headers`, names lowercased; `first(headers, "etag")` (`:715, 1427-1431`) |
| PATCH/PUT with JSON | `request("PATCH", uri)`, `with_body` (`:749, 763`) |
| Response size limit | `read_all(x, limit)` raises `BodyTooLarge` (`:1614-1640`); `Config.max_header_bytes` |
| Timeouts | `connect_timeout`, `idle_timeout`, per-request `deadline`/`with_timeout` (`:289-322, 766-772`) |
| Cancellation | `Cancel` tokens; releasing `ExchangeOwner` (h2 stream reset, h1 connection closed) (`:728-735, 1382-1420`) |
| Not supported | proxies, redirects, cookies, decompression, Happy Eyeballs (`GUIDE.md:460-463`) |

---

## 12. SQLite Android feasibility

**Verdict.** The package's source needs no change. The work is a build
target, one compile-time flag (or pragma), CI, and an Android acceptance
harness, all in sqlite-botpkg.

### 12.1 Probe D (observed, NDK r29, clang 21.0.0)

| Step | Result |
|---|---|
| Verify the committed amalgamation zip | SHA3-256 `92281c86e2957f9b9305890f9ac04204caa7b677cc868dc326d942689df28e30`, as `native/build.sh:9-11` requires |
| `aarch64-linux-android21-clang -O2 -fPIC -c sqlite3.c` with the package's own flags (`-DSQLITE_THREADSAFE=1 -DSQLITE_DQS=0 -DSQLITE_OMIT_LOAD_EXTENSION -DSQLITE_OMIT_SHARED_CACHE -DSQLITE_OMIT_DEPRECATED -DSQLITE_DEFAULT_MEMSTATUS=0 -DSQLITE_LIKE_DOESNT_MATCH_BLOBS -DSQLITE_USE_URI=0`) | exit 0, **no diagnostics**, 13.7 s |
| `llvm-ar rcs libbotsqlite3.a` | 1,605,492 bytes, SHA-256 `b24d4a490e1540e9ca20d1383b5bc6c3312543355a17be5c4a7078872d03994b`; identical when rebuilt elsewhere (reproducible) |
| Symbols | all 39 C functions `sqlite.bot` declares are defined. **58 undefined symbols, all in Bionic libc at API 21**; none needs libm or libdl. |
| A probe shared object with `-z defs -z text -z max-page-size=16384` | links; LOAD aligned 0x4000; no TEXTREL |
| `botlish native add ... -target android-aarch64` with all 39 `-symbol` checks | every symbol present. `native audit`: partially verified (two libc symbols expected from the platform). `package pack` succeeds. A consumer view derives. An outbox program passes `-check -target android-aarch64` and lowers to NIR with `link "botsqlite3"`. |
| Not done | Linking an Android application library or running it: no Android runtime archive or qemu roots in this container |

### 12.2 Work list (in sqlite-botpkg)

1. **Build:** a `native-android` CI job with NDK r29 pinned by SHA-256, `CC=aarch64-linux-android21-clang`. `build.sh` must honour `AR` (it hard-codes `ar`). `pack.sh --android-aarch64`. A new package version: one version, one artifact.
2. **Binding:** unchanged. Android is LP64 like linux-aarch64, `ULong` is 64 bits, `Char` is only a pointee. The botlish.json target entry declares no system library; the Android link's fixed list already holds libc (`native/support.tcl:144`).
3. **Temporary storage (must fix):** SQLite's Unix search order is `sqlite3_temp_directory`, `SQLITE_TMPDIR`, `TMPDIR`, `/var/tmp`, `/usr/tmp`, `/tmp`, then `.` (sqlite3.c:46918-46935, static). An Android app process is not guaranteed any of them (projected). Large sorts, temporary tables and statement journals over 64 KiB (sqlite3.c:24326) would fail with IOERR or CANTOPEN. Fix it in the build with `-DSQLITE_TEMP_STORE=3`, or with `PRAGMA temp_store = MEMORY` per connection (available under `OMIT_DEPRECATED`, sqlite3.c:145264-145275). The domain sets the pragma either way.
4. **Pages and mapping:** mmap is off by default (sqlite3.c:16312). WAL's shared-memory regions are sized from `sysconf`, so 16 KiB pages are fine (sqlite3.c:45451-45457, static).
5. **Acceptance:** Android builds only native libraries, so the 13 consumer programs cannot run as executables. They need an application-library harness (`NAME_main`) run on emulators of 4 KiB and 16 KiB pages, plus qemu-user for quick runs, as the Android milestones did. The tests must cover persistence across process restarts, WAL, `temp_store`, and an app-private absolute path.

### 12.3 Portability acceptance (projected)

One domain test corpus, the same `.bot` sources, run against SQLite on three
hosts:

- **Linux x86-64:** executables; GC stress.
- **macOS AArch64:** Botlish.app, AOT.
- **Android AArch64:** the application-library harness on emulators.

Each platform entry only installs `sqlite::engine()` and passes a path.
The SQL, the domain rules and the expected transcripts are identical, and
the probe A transcript format is the comparison.

---

## 13. Persistent Botlish service architecture

### 13.1 Decision matrix

| | A: M4 Botlish-owned worker | B: host-owned thread running `NAME_main` | C: persistent native-library instance with asynchronous dispatch | D: synchronous TurboModule methods |
|---|---|---|---|---|
| Possible today? | **No:** `spawn` fails in any library (no Vm factory: `thread.rs:286-290`); the RN tool refuses schema 3 | **Yes** (probe E, Linux) | **No:** exports hold no contexts or state (`hir/exports.tcl:206-213`; module bindings are no mutation places); AGENTS.md forbids a host-driven or resumable Vm | **No** for this domain: an export cannot use the SQLite Engine or the `http` context (EXPORT-ENVIRONMENT) |
| Compiler changes | none | none | a new embedding ABI (forbidden as designed) | none |
| Runtime changes | a Vm factory for library Vms, plus a C ABI into the transport (M5) | none | a host-driven Vm | none |
| ABI reuse | `NAME_main` to start; M4 for threads | `NAME_main` + exports + the event loop's integration ABI | — | the existing generator |
| M4 reuse | full | none needed (one VM) | — | — |
| Contexts | installed per worker entry | installed by the entry program | impossible | impossible |
| SQLite ownership | the worker VM | the service VM (one writer) | — | — |
| HTTP loop ownership | the worker | the service | — | none: no loop can run |
| Thread control | Botlish | the host creates the thread; Botlish runs everything on it | host | JS thread |
| Async messages | M4 transport (typed, but no foreign entry) | port: bytes in bounded queues | — | — |
| Cancellation | none in M4 (`rt_cancel` unused) | a port command (`cancel(id)`) the service honours | — | n/a |
| Backpressure | M4 grants | bounded queues; submit refused when full (probe E: 4 refusals plain, 141 under GC stress) | — | blocking |
| RN reload | the worker outlives it | the service outlives it (process-scoped) | — | instance recreated |
| Process shutdown | joins | a `shutdown` command; `NAME_main` returns; Vm dropped on its thread | — | — |
| Error transfer | transfer bytes | completion text/bytes, typed by the bridge | — | statuses |
| Android | threads never exercised on Android | Uses what the SDL3 2048 application runs (a long `NAME_main` on a host thread: RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md, CI run 43737218437 at bc31909c), plus the driver | — | as 2048 |
| Reuse by other hosts | Botlish hosts only | **Any C host:** desktop, native Android, a server process | — | RN only |
| Complexity | high: two runtime features | medium: a port package and a generator mode | — | — |

**Recommendation: B.** It is the only option that is possible without new
runtime machinery. It keeps every rule (no host-driven Vm, no export state,
instances on their own threads), and probe E demonstrates it end to end.

A becomes attractive later, if a domain needs several isolated workers
(for example a sync VM beside a query VM). The prerequisites are the Vm
factory for libraries and M5's foreign entry into the transport
(THREAD-ACTOR-ARCHITECTURE-CENSUS.md:1387-1401). It is not on this roadmap.

### 13.2 Thread and VM ownership (recommended)

```
 Android process (one libpetstore.so, never unloaded: NEEDED by libappmodules.so)
 ------------------------------------------------------------------------------
 mqt_v_js (JS thread)        "botlish-service" thread       "botlish-pump" thread
 created by React Native     created once per process        created with the service
                             by the generated core            by the generated core
   JS instance (NAME_create;   service VM: NAME_main(argc,      pump instance (NAME_create
   owned by mqt_v_js)          argv{data dir, port id})         on this thread)
     submit(port, text)  -->   installs Loop, Linux driver,       next_completion(port, ms)
       |  (copies bytes into   Port, Engine, Http, domain           |  blocks in the port's
       |   the port; posts a   contexts; runs the loop until        |  condition variable
       |   record; returns     a shutdown command)                  v
       |   the request id)       | takes requests on wake         AsyncPromise.resolve(...)
       v                         | completes, notifies  ------->  AsyncEventEmitter.emit(rev)
   AsyncPromise held in a        v                                  (both schedule onto the
   process-wide request table  SQLite connection (one writer)        JS thread through the
   keyed by request id         HTTP exchanges (Hyper tasks)          CallInvoker; dropped if
                                                                     that runtime is gone)
 ------------------------------------------------------------------------------
 Rules kept: every instance is called only on its owner thread (WRONG-THREAD
 otherwise: probe E); the service VM exists only inside one NAME_main call on
 its own thread; no Botlish code runs on any other thread; C++ never touches a
 Botlish heap; a JS runtime's objects are touched only on its JS thread.
```

### 13.3 The port package (proposed `botlish_port`; generic, no Petstore knowledge)

The package is a Botlish module plus a C adapter, versioned and released
like `event_loop_linux`. Probe E's `probe_bridge.c` and `service.bot` are
its prototype: 221 lines of C and 169 of Botlish.

- **Service side** (requires the installed `Port` context): `attach(port)`, `take() -> Request`, `complete(id, bytes)`, `notify(revision)`, `cancelled?(id)`, `detach()`.
- **Host side, as exports of the application library:** `open_port() -> int`, `submit(port, text) -> int` (an id, or a refusal code), `cancel(port, id)`, `next_completion(port, timeout_ms) -> str` (a completion or a coalesced notification), `shutdown(port)`.
- **Bounded queues:** requests are refused when full, and the host turns the refusal into an immediate rejected Promise (`ServiceBusy`). Completions must never be dropped. The probe sized the completion queue so it cannot fill. The product needs credit-based flow control: the service stops taking requests while the completion queue is full.
- **Notifications coalesce** in the adapter: only the newest committed revision is kept (section 15.3).
- **One port per process.** The adapter refuses a second service attaching while one is attached. That keeps one writer per database even if a new React Native instance appears while an old service is still shutting down.

### 13.4 What it reuses, and what it adds

| Piece | Status |
|---|---|
| `NAME_main` on a host thread, exports in the same library, instance affinity | existing (probe E) |
| The event loop's integration ABI (`botlish_event_post2`), a Reliable source, no polling | existing (probe E) |
| Byte borrowing for the copies in and out (`read noescape`, `write noescape`) | existing (probe E) |
| The port's queues, flow control, cancellation table, notification coalescing | new, in a package |
| The RN tool's service mode: schema 3, statically linked native dependencies, Promise methods, an event emitter, the process-scoped service holder, the pump thread | new, in the tool |
| A JSON codec for messages and Petstore bodies | new, a package (see 13.5) |
| An `event_loop_linux` android-aarch64 view | new, in the package (section 11.3) |

### 13.5 Message representation

The port carries opaque UTF-8 bytes; the bridge is payload-agnostic. Its
service mode, with the hooks package, uses one versioned JSON envelope:

```
{"v": 1, "op": "updatePet", "id": "<request id>", "args": {...}}
{"v": 1, "id": "<request id>", "ok": {...}} | {"v": 1, "id": ..., "error": {"code": ..., "message": ...}}
{"v": 1, "notify": {"revision": "<decimal>"}}
```

Hermes parses and produces JSON natively. On the Botlish side,
`std::transfer` bytes would be the typed alternative, but JavaScript has no
encoder for them.

Botlish has no JSON decoder to typed values today. `examples/dfa/json/` has
a declared recognizer, a lexer and certified emitters. The contract
milestone must decide between promoting it into a `json` package (a value
tree over payload enums and tree structs) and a narrow hand-written codec
for the two message shapes and Petstore's Pet. The census recommends the
package: the Petstore client needs it anyway, and the emitters' `emits`
certificates come along.

Identifiers and revisions cross as decimal strings (section 16.3).

---

## 14. M4 versus host-startable entry

| Question | M4 Botlish-owned thread | Host-startable entry (`NAME_main`) |
|---|---|---|
| Who creates the OS thread | the Botlish runtime (needs a Vm factory) | the host (React Native's C++, a desktop app, a server) |
| Available in a native library | **no** (`spawn` gives ENOSYS) | **yes** |
| Run on Android | never exercised ("compiled, not exercised": ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md:225) | the SDL3 2048 application runs a long `NAME_main` on SDLThread on emulators (RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md, CI) |
| Typed messages | yes (transfer bytes, fingerprinted) | bytes through the port; typed by the bridge's envelope |
| Foreign callers | no C ABI | exports reach the port from any host thread with its own instance |
| Stack | 64 MiB default reservation (`stdlib/thread.bot:156`); the Android document recommends about 8 MiB | The host chooses: the generated core would create the thread with an explicit stack (8 MiB proposed). A library's own prologue check bounds Botlish recursion (`native/library.tcl:723-729`). |
| Shutdown | cooperative stop and join (bounded only for executables) | a `shutdown` command; the entry returns; the host joins off the UI thread |
| What it would take | the factory in `library.rs`, the M5 foreign entry, Android exercise | a port package and a generator mode |

The two are not exclusive. A service started by `NAME_main` could later
start M4 workers once libraries get a factory. Milestone 1 needs one VM.

---

## 15. React Native Promise and notification lifecycle

### 15.1 What React Native 0.88.1 provides (static, from the published packages)

- **`AsyncPromise<T>`** (`ReactCommon/react/bridging/Promise.h:20`). It is constructed on the JS thread from the runtime and the module's `CallInvoker`.
  - `resolve`/`reject` may be called from any thread. They take a mutex, settle once, and reach JavaScript through an `AsyncCallback`.
- **`AsyncCallback::call`** (`ReactCommon/react/bridging/Function.h:22-74`) locks a *weak* reference to its callback wrapper.
  - Only when that succeeds does it `jsInvoker.invokeAsync(...)`.
  - Once the runtime has been torn down (its `LongLivedObjectCollection` cleared), the call is a no-op. Settling a Promise of a destroyed Hermes runtime is safe and does nothing.
- **`AsyncEventEmitter<T>`** (`ReactCommon/react/bridging/EventEmitter.h:70-110`). `emit` takes a mutex and calls every listener's `AsyncCallback`; a subscription removes its listener.
  - Codegen 0.88.1 generates a C++ TurboModule's emitter from a spec's `EventEmitter<T>` (`@react-native/codegen/lib/generators/modules/GenerateModuleH.js:420-424`; `Libraries/Types/CodegenTypes.js:49`).
- **A spec method returning `Promise<T>`** becomes a `jsi::Value` return in the C++ spec (`GenerateModuleH.js:232-233`). The implementation returns an `AsyncPromise`.

So the JS-engine side needs no invention. It needs a generated core that
never lets a Botlish VM and a JS runtime meet on the wrong thread.

### 15.2 A request's life (proposed generated code)

1. **JS thread.** `updatePet(...)` constructs an `AsyncPromise`, takes a process-wide request id (an atomic), and records `{id -> promise, runtime generation}` in a process-wide table under a mutex.
2. It calls the export `submit(port, json)` through the JS thread's own instance. That copies the bytes and posts a record. If the port refuses (`-EAGAIN`, or no service), the promise is rejected at once with `ServiceBusy` or `ServiceUnavailable`.
3. It returns `promise.get(rt)`.
4. **Service thread.** On the next turn the service takes the request, runs the command, commits, and completes it with `{id, ok|error}`. After the commit (never before) it posts a notification with the new local revision.
5. **Pump thread.** `next_completion` returns the completion. The pump removes the table entry and resolves or rejects. `AsyncPromise` schedules the settlement onto the JS thread, or drops it if that runtime is gone.
6. **JS thread.** The promise settles. Hooks read the result (section 16).

**Rules the generator enforces:**

- **Botlish VMs.** None is entered from a JS callback, a CallInvoker task or the pump, except each thread's own instance.
- **JS runtimes.** No JS object is touched outside its JS thread; `AsyncPromise` and `AsyncEventEmitter` cross by design.
- **Request ids** are decimal strings in the envelope. The table is the only place a promise lives outside the JS thread.

### 15.3 Change notifications

The service posts `notify(revision)` after every committed change: a local
edit, an applied sync outcome, a refresh, a resolution, a policy change.

- **Coalescing.** The port keeps only the newest unsent revision. A burst of commits yields one wakeup of the pump.
- **Delivery.** The pump emits `onChange({revision})` through every live module's `AsyncEventEmitter`, registered in a process-wide list that a module joins at construction and leaves at invalidation.
- **Content.** A notification carries no data and is a hint, never the state. A missed notification costs a delay, never a wrong state, because the next query returns the current state with its revision.
- **Rollbacks.** A rolled-back transaction posts nothing: the post follows `commit` returning. The mutation catalog checks this (section 22).

### 15.4 Reload, Hermes recreation, worker exit

| Event | What happens |
|---|---|
| `ReactHost.reload` / Hermes recreated | RN quits the JS thread, then invalidates the modules (BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md:232-240). The old module leaves the emitter list; the old JS instance is reaped on its thread (the existing Reaper). Its table entries are dropped: settling them would be a no-op anyway. **The service keeps running.** Commands the old runtime submitted still complete and commit, and the new runtime sees their effects in its first snapshot. The new module attaches to the process-wide service holder. |
| The service's `NAME_main` returns or fails | The holder marks the service ended and rejects every pending promise with `ServiceEnded`. It emits `serviceState: "stopped"` and restarts the service at most 3 times per minute; `recover` runs at each start, so this is safe. |
| Process death | Nothing to clean up: the outbox is durable; the next start recovers |
| A completion for an unknown id (an old runtime's) | dropped |

### 15.5 Cancellation

Local commands are short and not cancellable once submitted: they commit or
fail. `syncNow()` returns a request id that `cancel(id)` can target.

Cancelling a sync stops new exchanges and releases started ones, whose
intentions become `unknown` (section 6). The Promise then rejects with
`Cancelled`, unless the sync had already finished. JavaScript has no
Promise cancellation, so an `AbortSignal` option maps to `cancel(id)`.

---

## 16. Proposed hook API (TypeScript; not compiled)

### 16.1 Types

```ts
// @botlish/react-service + the generated petstore module (proposed).
export type PetId = string & { readonly __brand: 'PetId' };   // decimal int64 text
export type PetStatus = 'available' | 'pending' | 'sold' | { other: string };
export type SyncState =
  | { kind: 'synced' } | { kind: 'pending' } | { kind: 'sending' }
  | { kind: 'unknown' }                         // may have reached the server; checked when online
  | { kind: 'retryWaiting'; at: number }
  | { kind: 'conflicted' } | { kind: 'rejected'; reason: string };

export interface Pet {
  readonly id: PetId;
  readonly name: string;
  readonly status: PetStatus;
  readonly sync: SyncState;
  readonly conflict: boolean;
}

export interface PetConflict {
  readonly id: PetId;
  readonly kind: 'fields' | 'deleted';
  readonly fields: ReadonlyArray<'name' | 'status'>;
  readonly base: Pick<Pet, 'name' | 'status'>;
  readonly local: Pick<Pet, 'name' | 'status'>;
  readonly remote: Pick<Pet, 'name' | 'status'> | null;     // null: deleted remotely
  readonly actions: ReadonlyArray<'keepLocal' | 'acceptRemote' | 'merge' | 'defer'>;
}

export type Resolution =
  | { action: 'keepLocal' } | { action: 'acceptRemote' }
  | { action: 'merge'; name: string; status: Exclude<PetStatus, { other: string }> };

export class BotlishServiceError extends Error {
  readonly category: 'declared' | 'storage' | 'busy' | 'unavailable' | 'ended' | 'cancelled' | 'internal';
  readonly code: string;                        // e.g. 'InvalidName', 'StorageFull', 'NotFound'
}
```

### 16.2 Hooks

```ts
export function usePets(filter?: { status?: PetStatus }): {
  pets: readonly Pet[]; loading: boolean; error: BotlishServiceError | null;
  refresh(): Promise<void>;                     // a REMOTE refresh request (allowed only online)
};
export function usePet(id: PetId): { pet: Pet | null; loading: boolean; error: BotlishServiceError | null };
export function useUpdatePet(): {
  updatePet(id: PetId, change: { name?: string; status?: PetStatus }): Promise<{ revision: string }>;
  saving: boolean; error: BotlishServiceError | null;
};
export function useOfflineMode(): { offline: boolean; setOffline(on: boolean): Promise<void> };
export function useSyncStatus(): {
  pending: number; unknown: number; conflicts: number; syncing: boolean;
  lastSyncedAt: number | null; lastError: { code: string; message: string } | null;
  syncNow(options?: { signal?: AbortSignal }): Promise<void>;
};
export function usePetConflicts(): {
  conflicts: readonly PetConflict[];
  resolveConflict(id: PetId, resolution: Resolution): Promise<{ revision: string }>;
};
```

### 16.3 Semantics

| Question | Answer |
|---|---|
| When is `loading` true? | Until this view's first snapshot has arrived. Never during later refreshes: the previous snapshot stays visible. |
| `refresh` | A **remote** refresh: the service fetches when the policy allows, else rejects with `unavailable`. Local data is always current through notifications, so a local refresh never exists. |
| What `updatePet` resolves with | The local revision of the committed edit. "Saved locally" is the resolution; remote state shows in `pet.sync`. |
| Can a resolved edit still be pending remotely? | Yes, and always is until synchronized: `sync.kind` is `'pending'`. |
| An offline edit's visibility | It is in the snapshot of the revision `updatePet` resolved with. Any hook that sees that revision sees the edit. |
| Synchronization errors | `pet.sync` (per pet) and `useSyncStatus().lastError` (global); never thrown into the screen |
| Conflicts on the detail screen | `pet.conflict` with `usePetConflicts()` for the three values and the actions |
| Cleanup | Every hook subscribes through `useSyncExternalStore`, whose unsubscribe removes the listener. The last listener of a view releases that view's cache entry. |
| Several components on one pet | One normalized cache per module instance: every component sees the same snapshot revision |
| Changes made by other commands | They arrive as a notification, then the next snapshot. All subscribers update together. |
| Ids | `PetId` is text. A screen never does arithmetic on an id; the generator's safe-integer rule never sees one. |

### 16.4 `useSyncExternalStore` over the service

The JS store holds one immutable snapshot per view key: `{revision, data}`.
It is derived from SQLite and never written by a hook.

- `subscribe(listener)`:
  1. adds the listener;
  2. on the first listener, subscribes to `onChange`;
  3. *then* issues the view's query.

  Subscribing before reading closes the race: a commit between the two produces a notification with a newer revision, which triggers another query.
- `getSnapshot()` returns the cached object, the same identity until it changes, as React requires.
- A query result carries the revision it was read at, and is applied only if that revision is at least the cached one.
- While a query is in flight, the store remembers the highest notified revision. If the result is older, it queries again.

No hook generates SQL, merges, retries, chooses a baseline, manages the
outbox, validates beyond input hints, or decides whether to send. Those are
all Botlish's (section 17).

---

## 17. Context composition

### 17.1 Representative domain signatures (proposed Botlish; not compiled)

```botlish
# petstore_domain::store -- the durable model (sqlite-botpkg underneath).
context struct Storage:
    db: sqlite::Connection
    counters: MutableArray[int]        # local revision cache (F-08: no unbounded int field)

fn open_store(path: str, context e: sqlite::Engine) -> Storage errors StoreError
fn update_pet(id: PetId, change: Change, context st: Storage, e: sqlite::Engine) -> Committed errors StoreError, PetNotFound, InvalidChange
fn snapshot(view: View, context st: Storage, e: sqlite::Engine) -> Snapshot errors StoreError
fn resolve_conflict(id: PetId, r: Resolution, context st: Storage, e: sqlite::Engine) -> Committed errors StoreError, NoConflict
fn set_policy(p: NetworkPolicy, context st: Storage, e: sqlite::Engine) -> Committed errors StoreError
fn recover(context st: Storage, e: sqlite::Engine) -> int errors StoreError

# petstore_domain::reconcile -- pure (probe B is its executable model).
fn reconcile(base: Fields, local: Fields, remote: Remote) -> Outcome

# petstore_domain::remote -- what a transport provides; suspends on its loop.
context trait PetRemote:
    fn fetch(id: PetId) -> RemoteResult
    fn list(status: PetStatus) -> ListResult
    fn patch(id: PetId, change: Fields, if_match: Revision, key: str) -> PatchResult

# petstore_domain::sync -- the task the service adopts: the only caller of
# PetRemote, and only through the gate.
fn sync_task(context ev: std::event_loop::Loop, st: Storage, e: sqlite::Engine, r: PetRemote, ch: Changes) -> int errors ...
```

The `PetRemote` implementations suspend: they wait on the event loop. A
statically selected trait implementation contributes its yields and
protocols to its callers (AGENTS.md, "Traits"; TRAIT-IMPLEMENTATION-CONTEXT-REQUIREMENTS-MILESTONE-1.md),
so a suspending transport behind a context trait is checked like any other
call. `Changes` is a context trait with two implementations: the port's
notifier and a recording one for tests.

### 17.2 Compositions

| Entry | Installs |
|---|---|
| Android application library (`NAME_main`) | `std::event_loop::create`, `event_loop_linux::create()` + `native()` (android view), `botlish_port::attach(argv)`, `sqlite::engine()`, `http::Http` (Android trust source), `petstore_http::Hyper` (implements `PetRemote`), `petstore_service::PortChanges` (implements `Changes`) |
| Linux desktop or server entry (an executable or an application library) | the same, with the Linux driver and the system trust bundle |
| Deterministic test entry (Linux; every backend where possible) | `std::event_loop::create`, `std::event_loop::deterministic` (virtual clock, scripted records), `sqlite::engine()` with a temporary file, `petstore_testing::Scripted` (implements `PetRemote` against a scripted remote, with failure injection), `petstore_testing::Recorder` (implements `Changes`) |
| Controlled-server integration entry (Linux) | the production composition with the Linux driver, the controlled server's test anchor passed as data |

### 17.3 Static requirements preserved

- **Selection** is compile time: one implementation per context trait per program, so each entry is its own program.
- **Authority** is entry-specific: only entry programs install contexts.
- **Resources:** `sqlite::Transaction` is a resource rolled back at scope end; `http`'s `ExchangeOwner` releases its exchange; the event loop's `Owner` revokes its registration.
- **State** is per VM: the context area belongs to the service VM.
- **Sendability:** nothing in this design crosses VMs. The port carries bytes; a later M4 split would use `std::transfer`.
- **No hidden globals.** The port adapter's C state is the one process-wide object: explicit, a package's, and generation-checked like `event_loop_linux`'s handles.

**Two known language frictions** (from SQLITE-BOTPKG-LANGUAGE-FINDINGS.md):

- F-19: `std::test` cannot hold tests of context-using code, so the domain's tests use a custom harness, as sqlite-botpkg's consumer programs do.
- F-08: a context struct with an unbounded `int` field fails native lowering, so counters live in a `MutableArray`.

---

## 18. Android lifecycle and background execution

Synchronization is **foreground-managed** in the first release. The durable
outbox makes that correct.

| Event | Service behaviour |
|---|---|
| Cold start | The generated holder starts the service thread (8 MiB stack) with `NAME_main(argv: data directory, port)`. The service opens the database, migrates, recovers (`in_flight` to `unknown`), attaches the port and announces `ready`. The first snapshot query follows. |
| `AppState` to background | JS sends `setForeground(false)`, a runtime flag, not durable. The service stops initiating syncs, gives started exchanges up to 5 s, then cancels them (their intentions become `unknown`). The database stays open; every commit is already durable. |
| `AppState` to active | `setForeground(true)`: resolve `unknown` intentions, then a jittered sync, if the policy allows |
| Activity destroyed / process killed | No notice is guaranteed: recovery at the next start (section 8.2) |
| React Native reload, Hermes recreation | The service persists (section 15.4) |
| An open SQLite transaction | Never spans a suspension. Storage functions do not wait on the loop: a design rule, with a mutant (section 22). So no transaction is open between turns, and a kill mid-command loses only that command. |
| An in-flight HTTP request | becomes `unknown` on cancellation or death |
| Network changes | Milestone 1 has no Android connectivity API (it would need Java). Reachability is learned from attempts. An optional `networkHint(reachable)` command (for example from NetInfo in JS) can shorten a retry wait. It is a hint, never a permission. |

**The data directory.** The application must supply its private files
directory. The generated C++ has no JNI environment, and an Android app
process's working directory is `/`.

The recommended answer keeps Java out of the tool: the application, which
owns its `MainApplication`, passes `filesDir` to the module at start
(`startService({dataDirectory})`). The device builds already set an
environment variable in `MainApplication` (AGENTS.md, React Native
integration), so the precedent exists. The domain never computes a path.

WorkManager, background synchronization after process death and push
notifications are separate future milestones (section 23).

---

## 19. Controlled-server test design

The census specifies the server; the contract milestone builds it.

### 19.1 Form

- **Implementation:** a single-file Python 3 server, stdlib `http.server` and `ssl`. The http package's own tests already use independent Python peers (`tests/http-client.test`, asyncio, `h2`). HTTP/2 through `h2` is optional; Hyper negotiates by ALPN.
- **TLS:** a test CA made at test time, whose certificate the client passes as **data** (the http package's program anchors). Nothing turns verification off, on any host, emulator included.
- **API:** Petstore v3 1.0.27's paths plus the section 10.1 contract. State is persisted to a JSON file so a restart keeps it.
- **Control interface:** a second listener on loopback, never part of the API. It provides reset/seed, read the state, script faults, read the request log, and restart.

### 19.2 Deterministic injection (scripted per request: method, path, occurrence)

| Injection | Effect |
|---|---|
| server-side edit | change a pet's fields, bumping its revision, between two client requests |
| revision conflict | the next PATCH sees a newer revision: 412 with the current pet |
| delay | hold the response N ms (client timeouts) |
| close before processing | drop the connection after reading the request, state unchanged |
| close after commit | apply the change, then drop the connection: the client's `unknown` path |
| duplicate | the log shows a repeated `Idempotency-Key`, and whether its response was replayed |
| retryable failure | 503 with `Retry-After`, or 429 |
| permanent validation failure | 422 for a named field |
| out-of-order arrival | two scripted delays reorder two pets' PATCHes; the log records arrival order |
| server restart | stop and restart from the persisted state, mid-run |
| stale read | the next GET answers the previous revision once (read-after-write is not assumed) |

### 19.3 The independent oracle

Every test compares five views. None is the client's own claim about itself.

1. The local database, read by a separate reader (Python's sqlite3, as probe A's `inspect.py`).
2. The outbox rows and states (same reader).
3. The server's state and request log (control interface).
4. The conflict rows.
5. What the hooks expose: Jest over the TypeScript store with a scripted native module replaying recorded completions and notifications; on emulators, the app's own self-test (the pattern of `examples/react-native/app/src/SelfTest.tsx`).

A synchronization step passes only when the server's state and the local
base agree, and the outbox says what the server's log implies.

### 19.4 The public profile's smoke test

It is run manually or on a schedule, never as a regression gate. It
creates its own pet with a random id at or below 2^53-1, edits it, reads it
back and deletes it. It asserts only transport facts: TLS verified, status
codes in the documented set, JSON shape, id exactness. It never asserts
another user's data.

v3 returned 500 for every pet operation during the audit, so the smoke test
must report "service unavailable" as such, never as a client failure.

---

## 20. Feasibility probes and observations

All in `audit/rn-offline-domain/`. Run from the repository root with a
built native backend (`cargo build --release --manifest-path native/Cargo.toml`)
and `tclsh9.0`.

### 20.1 Probe A: SQLite domain mutation (observed)

`probes/outbox/run.sh SQLITE.botpkg`. The package was packed locally with
sqlite-botpkg's own `scripts/pack.sh`, given a wrapper that runs this
checkout's `main.tcl`. Its Linux archive's SHA-256 is `83fac6281928...`,
the same as the package's records. The artifact differs from the recorded
one (`0d3ffed3...` against `2784bbcf...`) because the CI artifact also
carries the macOS archive.

The runner installs the package into a fresh project (`botlish add`),
builds `outbox.bot` as an executable under `-warnings error`, and runs 13
steps, one process each. After every step Python's own sqlite3 reads the
database (`inspect.py`). The transcript must equal `expected.txt`, and it
does:

```
init -> 7                                 pets 1:Milo/available, base Milo/available@1, outbox []
edit 1 Milo Jr. available -> 1            outbox [1:pending:base1:att0:m-1]
edit 1 Milo III pending crash -> died (134)
    hot-journal ... pets 1:Milo Jr./available ... outbox [1:pending:base1:att0:m-1]   (unchanged)
edit 1 Milo III pending -> 1              outbox still m-1, base1: compacted
send 1 -> 1                               outbox [1:in_flight:att1:sent=Milo III/pending]
edit 1 Milo IV pending -> 1               edited while in flight; the intention keeps the sent snapshot
confirm 1 2 -> 0                          base := Milo III/pending@2; outbox [1:pending:base2:m-4] (not dropped)
send 1 -> 1; recover -> 1                 outbox [1:unknown:base2:att2:sent=Milo IV/pending]
init; edit 1 Rex sold; send; confirm 1 2 -> 1   base Rex/sold@2; outbox [] (dropped)
```

`pragma integrity_check` is `ok` after every step.

**Timing.** A full edit process takes a median of 3.57 ms (p90 3.72 ms).
That covers start, open, the IMMEDIATE transaction (update, counter,
outbox upsert), commit and close, of which process spawn alone is 0.95 ms.
A recover process takes 2.40 ms. This is a container's ext4, not a phone's
flash.

### 20.2 Probe B: pure reconciliation (observed)

`probes/run.sh probes/reconcile.bot` runs on interp, compile, cranelift and
cranelift-generic under `-warnings error`; all agree:

```
[true, "send Milo Jr./pending if-match r2", "conflict name r3", "adopt Max/available r4",
 "adopt Milo/sold r5", "send Bo/sold if-match r1", "remote-deleted Kept", "drop",
 "conflict name status r6", "conflict name r7", "send Milo Jr./available if-match r3",
 "adopt Max/available r3", "send Milo II/available if-match r3", "adopt Max/available r3"]
```

The cases, in order:

1. disjoint merge;
2. same-field conflict;
3. equal edits;
4. a reverted edit;
5. repeated edits against an unchanged remote, sending with the original base revision;
6. remote deletion with an edit, then without one;
7. both fields conflicting;
8. the name conflicting while the status merges;
9. the three resolutions;
10. a supplied value equal to the remote state.

It uses payload enums, exhaustive `match`, method syntax and a filtering
loop. The language needed no change; the probe needed no workaround but
`concat` for text (`+` adds Ints).

### 20.3 Probe E: a persistent service driven from foreign threads (observed)

`probes/service/run.sh` builds and runs everything in a temporary directory:

- `event_loop_linux` installed by `tools/event-loop-linux.tcl`;
- the C port compiled into `native/libprobe_bridge.a`;
- `service.bot` built as the application library `svc` (`-emit-native-library svc -application`, `-warnings error`);
- `host.c` linked against `libsvc.so`.

`host.c` runs three host threads. **service** calls `svc_main`. **client**
does 200 sequential round trips and then collects a burst. **main** submits
a burst of 500 without waiting, then `stop`.

| | plain | `BOTLISH_NATIVE_GC_STRESS=1` |
|---|---|---|
| round trip (submit, service turn, completion; two instance calls) | median **38.9 µs**, p99 93.9 µs, max 166.9 µs | median 58.1 µs, p99 106.6 µs, max 350.8 µs |
| burst of 500 submissions | 2.2 ms; slowest submit 93.5 µs; 4 refused (queue of 64 full), retried | 24.8 ms; 141 refused |
| completions | 500/500, in order, stop acknowledged | the same |
| submit through another thread's instance | status 4, `WRONG-THREAD` | the same |
| `svc_main`'s status | 0 (the VM made and dropped on the service thread) | 0 |

A second run of the runner gave a median of 39.3 µs plain and 55.2 µs under
GC stress, with every check holding.

What it establishes: a long-running entry program on a host thread, with
its own loop, a Reliable source, endpoint posts from foreign threads and no
polling, can serve concurrent host threads through exports today. It also
compiles for Android: `-check -target android-aarch64` is ok, and the NIR
links both archives statically.

The library's manifest is schema 3. It describes the application
(`execution: blocking-to-completion`), the three exports and two static
dependencies (`event_loop_linux`, `probe_bridge`). That is exactly the
manifest the React Native tool refuses twice today: for its schema
(`integrations/react-native/src/main.c:489-491`) and for its dependencies
(`:538-540`). Observed by reading the generated `svc.manifest.json`; the
tool was not run against it.

What it does not establish: anything on Android (the driver's C does not
compile below API 35, section 11.2), flow control on completions, or React
Native.

### 20.4 Probe C: Hyper for Android (observed at the toolchain level)

Section 11.1. The unit builds unchanged in the recipe's link-only mode,
localizes with LLVM tools to exactly its 20 `bh_*` globals, and links into
a Bionic-only, 16 KiB-aligned shared object once libc++ is static.

The first blocker is boring-sys's `ANDROID_NDK_HOME` check (an environment
fix). The first code blocker is the driver's `epoll_pwait2`.

### 20.5 Probe D: SQLite for Android (observed at the toolchain level)

Section 12.1. The pinned amalgamation compiles at API 21 with the package's
flags, with no diagnostics and reproducibly. Every symbol the binding
declares is present; every undefined symbol is in Bionic libc. The package
manager accepts the archive for `android-aarch64` with all 39 symbol checks
passing.

### 20.6 Probe F: the React Native notification path (static)

Section 15.1, read from the published 0.88.1 packages:

- `AsyncPromise`: resolvable from any thread, no-op after teardown;
- `AsyncEventEmitter`: any-thread `emit`, listener subscriptions;
- Codegen's `EventEmitter<T>` and `Promise<T>` for C++ TurboModules.

The generator (`integrations/react-native/`) uses none of them today.

No module was built or run against Hermes in this census.

---

## 21. Security and failure contracts

### 21.1 Security and privacy

| Concern | Contract |
|---|---|
| HTTPS | verified always: chain, host name, expiry, TLS 1.2+. No bypass for emulators or tests, which pass anchors as data. |
| Cleartext | The domain refuses a non-`https` base URL, except a loopback address in a test entry. Android's cleartext policy does not govern native sockets, so the domain must refuse it itself. |
| Android permissions | `INTERNET` only, which React Native apps already declare |
| Credentials | None in milestone 1. A later authentication milestone keeps tokens out of SQLite and out of the port's messages: Android Keystore through the application, passed per request. |
| Database placement | app-private files directory; never external storage |
| Backup | Exclude the database from Android Auto Backup in milestone 1. A restore onto another device would revive intentions and keys against a server that may have seen them. Safe on the controlled profile (replayed responses) but confusing; treated as a cold start if ever allowed. |
| SQL injection | bound parameters only (`bind`, `execute(sql, params)`). No SQL text is assembled from values (a mutant). |
| Malformed responses | A decode failure, a missing `name` or a wrong type is a transient server error. It never overwrites the base or `pets`. |
| Unbounded responses | `read_all(x, limit)`: 1 MiB per list page, 64 KiB per pet (proposed); `max_header_bytes`; `BodyTooLarge` is a server error |
| Retry amplification | bounded attempts, exponential backoff with full jitter, one timer, at most four exchanges in flight, `Retry-After` honoured |
| Identifiers | `PetId` parsed from decimal text: 1..2^63-1 or refused at the boundary. Never a JS number. |
| Integer conversions | revisions and ids are text across JS; Int64 domains inside |
| Logs | no request or response bodies, no pet names at the default level; ids and status codes only |
| Cryptography | none of the domain's own: BoringSSL's TLS only |
| Provenance | Every package is a recorded release (`packages/RELEASES.tsv`, sqlite-botpkg's digest). The RN tool checks the library's SHA-256 (`templates/CMakeLists.txt.in`) and refuses a manifest whose files differ. |

### 21.2 Failure and recovery matrix

| Failure | Durable before | Durable after | API behaviour | Acceptance evidence (milestone) |
|---|---|---|---|---|
| App killed after a local edit | edit + `pending` | the same | the edit is visible after restart and synchronizes later | emulator kill test; probe A rows 1-2 (domain) |
| App killed during an HTTP request | `in_flight` | `unknown` (recover) | "may have reached the server"; resolved by a read online | controlled server, close-after-commit and close-before-processing |
| Offline enabled during synchronization | `in_flight` | `unknown` for started exchanges; others `pending` | nothing new starts; a response that still arrives is applied | the server log shows no request after the policy commit (gate mutant) |
| Network restored | `pending`/`unknown` | resolved | `unknown` resolved first, then a jittered sync | the server log order |
| Remote pet changed | base @N | conflict or merge | merged send or a conflict row | 412 scripted; probe B tables |
| Same field changed twice locally | base @N, one intention | the same intention, base @N | one send against N | probe A (`m-1` kept) |
| SQLite busy | — | unchanged | the command fails `StorageBusy`; nothing reported saved | a second process holding the lock |
| SQLite full | — | unchanged | the command fails `StorageFull` | a small filesystem (Linux), and a full emulator disk |
| Invalid remote JSON | base @N | base @N | a transient error for that pet; the base protected | scripted body |
| HTTP 401/403 | intentions | `rejected` (`auth`) | sending stops; no loop | scripted status |
| HTTP 409/412 | `in_flight` | conflict, or rebased | reconciliation | scripted |
| Timeout after a remote commit | `in_flight` | `unknown`, then confirmed by a read or a same-key replay | no duplicate application (controlled profile) | close-after-commit, then the replay counter |
| React Native reload | — | — | old Promises dropped; the new runtime's first snapshot shows everything committed | emulator `ReactHost.reload` (the 2048 milestone's `dev-reload.sh`) |
| Service thread exits | whatever was committed | the same | pending Promises reject `ServiceEnded`; restart with recover | a fault entry in the service |
| Android background | `in_flight` | completed or `unknown` within 5 s | sync paused | emulator `am` lifecycle |
| Process death | anything | as committed | recovered at cold start | emulator kill during each crash point |

---

## 22. Performance, footprint and regression strategy

### 22.1 Measurements and proposed budgets

| Quantity | Observed (where) | Proposed acceptance threshold (on a mid-range arm64 phone) |
|---|---|---|
| Host to service round trip | 38.9 µs median, Linux x86-64 container (probe E) | < 1 ms p95 |
| Local edit, end to end through the bridge | not measured. A process-level edit is 3.57 ms here, including spawn and open. | < 20 ms p95 (fsync-bound) |
| Cross-VM message (M4, for comparison) | 7-10 µs one way; a remote call round trip about 20 µs (BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-MILESTONE-1.md, Linux) | — |
| Notification to re-render | — | within one frame after the snapshot arrives (16 ms) |
| Cold start to the first local list | — | < 300 ms after the JS bundle runs, for 1,000 pets |
| A sync batch of 50 changed pets (controlled server, LAN) | — | < 5 s; never blocks rendering |
| SQLite open + migration | — | < 50 ms |
| Service thread stack | the host chooses it: 8 MiB proposed | — |
| Memory per service VM | not measured | < 16 MiB resident for 1,000 pets |
| Native code: http unit + BoringSSL + libc++ | 5.3 MB stripped, arm64 (probe C) | — |
| SQLite | a 1,605,492-byte archive, unstripped (probe D) | — |
| APK growth over the 2048 app | — | < 10 MB compressed (projected from the two rows above plus the runtime) |

No measurement trades away a SQLite transaction. A locally committed edit
feels immediate because one transaction on one thread, never shared, is a
few milliseconds. Network work never runs on the JS thread: it runs on the
service thread, and the JS thread only copies bytes into the port.

### 22.2 Proposed mutation catalog (for the implementation milestones)

Every mutant has a named detector. "Layer" says what the detector needs.

| # | Mutant | Detector | Layer |
|---|---|---|---|
| 1 | local edit committed without its outbox intention | the outbox-after-edit check (independent reader) | SQLite on Linux |
| 2 | outbox intention committed without the edit | the same check, reversed | SQLite |
| 3 | a pending change lost on restart (the intention table not persisted, or recreated) | the kill-and-restart transcript | SQLite |
| 4 | the base overwritten by a local edit | probe-A-style compaction transcript | SQLite |
| 5 | a server response applied over a newer local edit (confirm sets `pets` := sent) | the edit-while-in-flight transcript (probe A's `confirm 1 2 -> 0`) | SQLite |
| 6 | a disjoint-field merge reported as a conflict | reconcile table case 1 | pure Botlish |
| 7 | a same-field conflict overwritten silently | reconcile table case 2 | pure Botlish |
| 8 | a network send after the offline policy changed (the gate skipped) | the server's request log after the policy commit | controlled server |
| 9 | an `in_flight` mutation recovered as `pending` (unsent) | the recover transcript | SQLite |
| 10 | a timeout treated as proof of non-application | close-after-commit, then a check for no duplicate side effect and a correct base | controlled server |
| 11 | a non-idempotent resend with a new key and no `If-Match` | the replay counter and 412 expectations | controlled server |
| 12 | a conflict resolution not durable (two transactions) | kill between resolution steps | SQLite |
| 13 | a notification emitted before commit (or on rollback) | a rollback-injection test: no notification, revision unchanged | pure Botlish + port |
| 14 | a subscription that misses an update between read and registration (query before subscribe) | the Jest store test with an interleaved notification | React Native/Jest |
| 15 | a Promise settled after Hermes destruction without the weak guard (a raw `jsi::Function` kept) | the emulator reload test, crash-free; an ASan host harness | Android emulator |
| 16 | the SQLite connection used from another thread | WRONG-THREAD from the port; the Engine is never sendable (compile error) | Linux |
| 17 | worker destroyed during an active transaction (a transaction across a suspension) | a kill test plus a static check that storage functions have no yield effect | SQLite + compiler |
| 18 | TLS verification disabled (a test hook in the release) | `http-unit-exports`-style export check; a self-signed server must fail | Linux + controlled server |
| 19 | an id silently rounded (a number across JS) | the TS type plus an id above 2^53 round trip | Jest + emulator |
| 20 | a native library manifest or digest ignored | the RN tool's refusal tests (RN-MANIFEST, digest mismatch) | Linux |
| 21 | SQL text assembled from a value | a name containing `'` and `;` round trip | SQLite |
| 22 | retry without a bound (attempt counter not incremented) | the scripted 503 storm: at most the bound | controlled server |
| 23 | the public profile reported as conflict-free reconciliation | the profile flag in the sync result | pure Botlish |

Layer key:

- **Pure Botlish:** probe B's form, all four backends.
- **SQLite on Linux:** probe A's form.
- **Controlled server:** Python, Linux.
- **React Native/Jest:** the TypeScript store.
- **Android emulator:** 4 KiB and 16 KiB images, translated arm64 as the existing workflows run it.
- **Native ARM hardware:** GC stress, timing budgets. The 2048 milestone's device builds are the precedent: a self-test button, run by hand.

---

## 23. Architecture decisions and rejected alternatives

### 23.1 Decision record

| Area | Decision | Reasons | Prerequisites | Complexity | Risks |
|---|---|---|---|---|---|
| Storage | **sqlite-botpkg extended to android-aarch64**, synchronous single-owner access from the service VM | It exists, is resource-safe and is tested on two hosts. Its Android build is clean (probe D). One writer needs no asynchronous storage. | temp store; WAL tested; an Android acceptance harness | low | WAL and fsync behaviour on real flash; 13 acceptance programs to port to a harness |
| Transport | **Hyper/BoringSSL Android port** behind a `PetRemote` context trait | One transport, one policy gate and one failure classification on every host. The unit builds unchanged (probe C). | the driver's Android view; libc++ static; LLVM localization; the trust decision; new releases | medium | the trust decision; no proxy or NSC; about 5.3 MB of native code |
| Service embedding | **Host-startable application library (`NAME_main`) on a host-owned thread + a port package** | Works today (probe E); keeps every library rule; reusable by any C host | the port package; the RN tool's service mode | medium | completion flow control; the data directory; first Android run of a long-lived loop with sockets |
| Reconciliation | **Revision-aware conditional writes + client three-way field merge + user-mediated conflicts**; public Petstore best-effort only | The public API cannot prevent lost updates (observed). Field merge removes needless conflicts (probe B). | the controlled server | low (domain) + low (server) | users facing conflicts; the public profile's weaker guarantees must stay visible |

### 23.2 Rejected alternatives

| Alternative | Why rejected |
|---|---|
| Synchronous TurboModule methods (option D) | Impossible for this domain: exports cannot use the SQLite Engine or the `http` context (EXPORT-ENVIRONMENT). Even if possible, fsync-bound commits on the JS thread would block rendering. |
| A persistent instance with asynchronous dispatch (option C) | Needs a host-driven, resumable Vm, which AGENTS.md forbids for application libraries; exports cannot hold state |
| An M4 worker started from the library (option A) now | No Vm factory in libraries (`thread.rs:286-290`) and no foreign entry into the transport. Two runtime features for no gain over B. |
| React Native `fetch` (transport D) | Moves the network boundary, the offline gate, idempotency and retry into JavaScript. The domain would no longer be host-independent. Kept as a comparison tool. |
| Android's HTTP stack via JNI (transport C) | Kept as the fallback if the trust decision is refused. It needs a callback boundary the tool does not model, and an Android-only package. |
| rustls-platform-verifier | A second TLS provider; JNI into Conscrypt needs a JavaVM a Botlish library never receives; breaks the provider-identity rule |
| Last-write-wins | Loses the other side's edit silently (section 10.3) |
| CRDTs / multi-device peer sync | Out of scope (the prompt's non-goals); the server is authoritative |
| A JS-side cache as the source of truth | Forks the state; the UI must observe committed SQLite state |
| A second (read) connection now | No benefit at this scale; adds a concurrency question (section 7.3) |
| Storing a copy of each edit in the outbox | Breaks compaction and invites applying stale payloads. The intention plus send-time computation is simpler and provably compacts (probe A). |
| Background sync (WorkManager), push notifications | Separate future milestones; foreground-managed sync is correct with a durable outbox (section 18) |
| A replacement SQLite wrapper, a new HTTP client, an ORM, an OpenAPI compiler, a new actor model or scheduler, new syntax | Non-goals; none needed |

---

## 24. Recommended milestone dependency graph

The census changes two of the prompt's provisional boundaries:

- **The feasibility questions of the HTTP milestone are answered here** (probe C), so it becomes an implementation milestone.
- **The `event_loop_linux` Android view is split out** as a small first milestone. Both the bridge (an Android service needs a loop even without HTTP) and HTTP depend on it.

```
   [1] RN-PETSTORE-CONTRACT-AND-RECONCILIATION-MILESTONE-1   (Linux; independent repo)
        |                                                    [2] RN-SQLITE-ANDROID-AARCH64-MILESTONE-1
        |                                                        (sqlite-botpkg)
        v                                                    [3] EVENT-LOOP-LINUX-ANDROID-AARCH64-MILESTONE-1
   [6] RN-PETSTORE-OFFLINE-DOMAIN-MILESTONE-1                    (Botlish main)
        (Linux; independent repo)                                 |                 |
        |                                                          v                 v
        |                                         [4] RN-HTTP-ANDROID-AARCH64   [5] RN-ASYNC-BOTLISH-SERVICE-
        |                                             -MILESTONE-1 (Botlish main)    BRIDGE-MILESTONE-1 (Botlish main)
        |                                                          |                 |
        +------------------------------+---------------------------+-----------------+
                                       v                ([2] also feeds here)
                       [7] RN-PETSTORE-OFFLINE-APP-MILESTONE-1   (independent repo)
```

**Parallel at the start:** [1], [2] and [3]. [6] needs only [1] and runs
entirely on Linux, against the existing `http` package and the existing
Linux SQLite. [4] and [5] need [3]. [7] needs [2], [4], [5] and [6].

### 24.1 The milestones

**[1] RN-PETSTORE-CONTRACT-AND-RECONCILIATION-MILESTONE-1**

- **Deliverable:**
  - the pinned contract (the v3 1.0.27 document, upstream commit, digests);
  - the controlled server (section 10.1, section 19) with its control interface;
  - the domain model's types (section 4.2);
  - the pure reconciliation module (probe B grown into the module, with an independent Python oracle of section 9's tables);
  - the durable state machine as an executable specification (section 8.1) with the crash matrix as test cases;
  - the JSON decision, recommended as a `json` package in Botlish main (`packages/json`) promoted from `examples/dfa/json/`, decoding to a value tree.
- **Scope:** Linux; pure Botlish and Python.
- **Non-goals:** storage, transport, Android, React Native.
- **Acceptance:** the reconciliation module and the oracle agree on a generated corpus; the server passes its own contract tests (412, 428, key replay, merge-patch, faults); every crash-matrix row has a test case.
- **Clean room:** the server and the oracle run from a fresh checkout with Python's standard library only (plus `h2` if HTTP/2 is tested).
- **Compiler/runtime:** none (the `json` package is a package).
- **Repository:** an independent repository (proposed `petstore-offline`), like sqlite-botpkg; the `json` package in Botlish main.

**[2] RN-SQLITE-ANDROID-AARCH64-MILESTONE-1**

- **Deliverable:** sqlite-botpkg 0.2.0 with linux-x86_64, macos-aarch64 and android-aarch64 archives (NDK r29 pinned); `temp_store`; WAL exercised; `AR` honoured; Android acceptance through an application-library harness on 4 KiB and 16 KiB emulator images plus qemu-user.
- **Non-goals:** a domain; React Native.
- **Acceptance:** the existing 257 checks' Android equivalents pass, including persistence across process restarts in app-private storage, WAL and a large sort; the archive is bit-reproducible; the release digest is recorded.
- **Clean room:** a consumer installs the `.botpkg` with the single-file compiler and builds the harness.
- **Compiler/runtime:** none expected (probe D).
- **Repository:** sqlite-botpkg.

**[3] EVENT-LOOP-LINUX-ANDROID-AARCH64-MILESTONE-1**

- **Deliverable:** event_loop_linux 0.6.0 with an android-aarch64 view: `epoll_pwait` below API 35 (no raw syscall), and an NDK branch in `author::cc`; process_linux re-locked if needed.
- **Acceptance:** the event-loop tests that do not need glibc-only facilities, run as an application library under qemu-user with Android roots, and on emulators (timers, endpoints posted from foreign threads, watches).
- **Compiler/runtime:** none.
- **Repository:** Botlish main.

**[4] RN-HTTP-ANDROID-AARCH64-MILESTONE-1**

- **Deliverable:**
  - first, the trust decision as a written rule (section 11.4);
  - boringssl and http releases with android-aarch64: BoringSSL built upstream by the NDK, libc++ static, exports hidden; the unit localized with LLVM tools (Linux bytes unchanged);
  - EAI codes per target; the author image with the Android Rust target.
- **Non-goals:** proxies, NSC, user CAs, HTTP/3.
- **Acceptance:** the http tests' Android subset against independent peers reachable from the emulator, using a test CA passed as data; a self-signed server refused; the release reproducible in the author image; the clean room.
- **Compiler/runtime:** none expected; package tooling only.
- **Repository:** Botlish main.

**[5] RN-ASYNC-BOTLISH-SERVICE-BRIDGE-MILESTONE-1**

- **Deliverable:**
  - `packages/botlish_port` (section 13.3: queues, flow control, cancellation, coalesced notifications, one service per process);
  - the RN tool's service mode: schema 3, statically linked dependencies, Promise methods over `AsyncPromise`, `AsyncEventEmitter`, the process-scoped holder, the pump thread, reload behaviour;
  - `@botlish/react-service`: the `useSyncExternalStore` store and base hooks.
- **Test workload:** a deliberately non-Petstore service, for example a persistent counter and log with timers and notifications.
- **Non-goals:** Petstore; SQLite; HTTP.
- **Acceptance:**
  - Linux host harnesses: probe E grown, with GC stress, flow control and cancellation;
  - Jest store tests, including the notification race (mutant 14);
  - emulators: Promises settle, notifications arrive, three reloads drop old Promises safely while the service persists, shutdown and restart;
  - the existing 2048 package still generates byte-identically.
- **Compiler/runtime:** none expected. Section 25 states a possible export-path simplification as a question.
- **Repository:** Botlish main (packages/, integrations/react-native/).

**[6] RN-PETSTORE-OFFLINE-DOMAIN-MILESTONE-1**

- **Deliverable:** the domain package: Storage over sqlite-botpkg, the sync task, the gate, the `PetRemote` trait with the Hyper implementation (Linux) and the scripted one, recovery, conflict resolution and the kill switch.
- **Acceptance:** every crash-matrix row; mutants 1-13, 16, 17 and 21-23 killed; the controlled-server suite with every injection; the public smoke test, reported separately; the same sources compile for android-aarch64 (`-check`).
- **Compiler/runtime:** none expected.
- **Repository:** the independent repository.

**[7] RN-PETSTORE-OFFLINE-APP-MILESTONE-1**

- **Deliverable:** the React Native app: list, filter, detail, edit, offline switch, sync status, failures, conflict resolution; hooks from section 16 over the generated module.
- **Acceptance:**
  - on 4 KiB and 16 KiB emulator images: offline edits survive kill and restart; the kill switch stops traffic (the server's log); conflicts resolve and survive restart;
  - mutants 14, 15 and 19 killed;
  - a device self-test run by hand on native ARM, reported as such;
  - the clean room from the single-file compiler and released packages.
- **Compiler/runtime:** none expected.
- **Repository:** the independent repository.

### 24.2 Platform support matrix

| Component | linux-x86_64 | linux-aarch64 | macos-aarch64 | android-aarch64 today | android-aarch64 after |
|---|---|---|---|---|---|
| Botlish native library (`exported c fn`) | yes | yes | no: libraries are made for Linux glibc, Android AArch64 and Windows x86-64 only (`native/src/codegen/library.rs:50-62`) | yes (RN 2048, emulators, translated) | — |
| Application library (`NAME_main`) | yes (probe E) | yes | no (no libraries) | yes (SDL3 2048, emulators) | — |
| Coroutines in a library | yes | yes | no (no libraries; executables have them) | compiled; qemu-user only | exercised in [3] |
| `std::thread` in a library | no (no factory) | no | no | no | no (not needed) |
| event_loop_linux | yes | yes | no (Linux kernel interfaces) | **no** (`epoll_pwait2`) | [3] |
| http + boringssl | yes | no release | no | **no** | [4] |
| sqlite-botpkg | yes | not packaged | yes | **no** (archive builds: probe D) | [2] |
| botlish_port | — (probe only) | — | — | — | [5] |
| RN tool service mode | — | — | — | **no** (schema 2, no dependencies, sync) | [5] |
| Domain package | — | — | — | — | [6] (Linux), [7] (Android) |

---

## 25. Remaining risks and unanswered questions

### 25.1 Risks

1. **No Android execution has backed any of this.** A long-lived event loop with sockets, coroutines and timers inside an application library has never run on Android. The emulator jobs translate arm64-v8a on x86_64 images, which is not native ARM. [3] and [5] must run it on emulators. A native ARM run stays a manual device self-test until CI has arm64 Android.
2. **The trust decision** may be refused. If it is, transport C (Android's stack via JNI in the host) is the fallback, at the cost of a new boundary. Accepting it means user CAs, Network Security Config and proxies do not apply, and some enterprise networks will fail. That must be documented, never hidden.
3. **Two C++ runtimes in one process:** BoringSSL's static libc++ (symbols hidden) beside React Native's `libc++_shared`. Hidden symbols should keep them apart (projected), but exceptions and RTTI crossing boundaries must not happen. Nothing crosses: the unit's API is C.
4. **Completion flow control** is unresolved (the probe sized its queue). A slow JS thread must not make the service drop a completion.
5. **The `http` runtime is one thread per process** (`ERR_OPEN_ELSEWHERE`). A second Botlish library in the same app that also used `http` would be refused. Acceptable for this app; a constraint on composition.
6. **Public Petstore** was down (v3) or polluted (v2) during the audit. Nothing may depend on it beyond a smoke test.
7. **WAL and `synchronous=FULL` costs** on real flash are unmeasured. A budget overrun must be answered by measurement, never by weakening durability.
8. **Android Auto Backup** could restore an old outbox onto another device (section 21.1).
9. **React Native upgrades:** the tool's version table is 0.88-only by design. An upgrade revalidates the async path (AsyncPromise's weak-wrapper guard is RN's internal behaviour, read in source).

### 25.2 Unanswered questions (each owned by a milestone)

| Question | Owner |
|---|---|
| Does the application supply the data directory through `MainApplication`, a tiny host native module, or another channel the tool may generate without Java? | [5]/[7] |
| Should the port's host side stay exports (a VM entry per submit: probe E's round trip includes two), or should the native link plan let a package declare host-callable C symbols beside `NAME_*`? The latter is a compiler/driver change; measure first. | [5] |
| One pump thread per process, or one per JS runtime? (Per process is recommended: the service is process-scoped.) | [5] |
| The JSON package's shape: a value tree; streaming or not; `emits` certificates for its emitters | [1] |
| Memory per service VM, cold-start time and APK growth on a real device | [7] |
| The exact `epoll_pwait` fallback precision under API 35 (millisecond timers) and the seccomp behaviour of Android's app filter on API 24-34 kernels | [3] |
| Whether `RemoteDeleted` offers "re-create" in the app's first release (it needs creation's identity work) | [7], deferred |
| Whether the controlled server should also expose a change feed (`?since=cursor`) for efficient refresh, or full lists suffice at the app's scale | [1] |

---

## Appendix: repository paths behind the main claims

| Claim | Path |
|---|---|
| A library Vm cannot start threads | `native/src/runtime/thread.rs:286-290`; `native/src/runtime/aot.rs:302` |
| `NAME_main` runs, then drops its Vm on the calling thread | `native/src/runtime/library.rs:656-686` |
| Instance affinity and reentrancy refusals | `native/src/runtime/library.rs:357-370, 718-738` |
| Export boundary types and environment | `hir/exports.tcl:48, 166-213` |
| Only `NAME_*` leaves a library | `native/library.tcl:507-514` (ValidateShared), `:299, 426` (localization) |
| The RN tool: schema 2 only, no dependencies, synchronous | `integrations/react-native/src/main.c:489-491, 538-540, 1043-1070` |
| The generated core's affinity and reaping | `integrations/react-native/templates/Core.cpp.in:279-411` |
| Safe-integer rule | `integrations/react-native/templates/Core.cpp.in:208-232` |
| Synchronous callbacks only | `native/src/runtime/callback.rs:29-30, 97-98`; C-CALLBACK-MILESTONE-1.md:904-914 |
| Foreign-thread posts into a loop | `packages/event_loop_linux/native/botlish_event_loop.h:32-98` |
| `epoll_pwait2` | `packages/event_loop_linux/native/event_loop_linux.c:715-729` |
| The http unit's trust bundles | `packages/http/native/src/tls.rs:40-46, 127-164` |
| http's headers, cancellation, limits | `packages/http/http.bot:663-772, 1382-1640` |
| http/boringssl release targets | `tools/package-repository.tcl:806` |
| sqlite transactions and cleanup | sqlite-botpkg `sqlite/sqlite.bot:1036-1169` |
| sqlite build flags and pin | sqlite-botpkg `native/build.sh:9-23`, `native/FLAGS.md` |
| RN 0.88.1 `AsyncPromise`, `AsyncCallback`, `AsyncEventEmitter` | `react-native/ReactCommon/react/bridging/Promise.h:20`, `Function.h:22-74`, `EventEmitter.h:70-110` (the published package) |
| Probes | `audit/rn-offline-domain/probes/` (README.md beside them) |

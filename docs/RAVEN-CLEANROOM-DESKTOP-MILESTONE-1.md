# RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md

## A real Raven GUI application from the single-file compiler and one prebuilt package

> A third-party GUI library is ready for Botlish when an application
> developer can install its prepared package, discover its API, write a
> graphical application, compile it and run it without knowing how the
> package's native implementation was built.

This milestone sits between PM-2 and PM-3 of PACKAGE-ECOSYSTEM-ROADMAP.md.
PM-2 made target-aware native packages consumable; this one checks what
that is worth to a developer who has nothing but the distributed compiler
and one artifact. It does three things:

1. **The release.** `raven` 0.3.1 is the first desktop-capable Raven
   package (0.3.0, its release candidate, is the one the experiment
   used): Raven's X11 platform and Vulkan renderer for linux-x86_64 and
   linux-aarch64 in one artifact, the same library also running Raven's
   headless configuration, libX11 a declared and verified system library,
   and the consumer's documentation and a checked example inside. One
   author operation makes it.
2. **The clean room.** A container holding only Ubuntu 24.04's own
   packages, the single-file compiler and the `.botpkg` -- no Botlish or
   Raven source, no Tcl, Rust, CMake or Ninja, no network -- installs the
   package, compiles and runs its documented programs, opens a real X11
   window drawn by Raven's Vulkan renderer (Mesa's lavapipe), drives it
   through the X server, reports a missing display or driver usefully, and
   runs a deployed executable after moving it and removing the package.
3. **The experiment.** An independent agent, given that environment and a
   task, wrote a new GUI application from the installed documentation.

Every claim is marked **Executed** (run here, output read), **Inspected**
(read from code or a binary without running the claim end to end) or
**Not done**. Everything executed ran on one Linux x86-64 container
(Ubuntu 24.04.5, glibc 2.39, Tcl 9.0.1, rustc 1.97, GCC 13.3, Mesa 25.2.8,
Xvfb 21.1.12, Docker 29.9.2).

Contents:

* [0. Before the change](#0-before-the-change)
* [A. Starting state](#a-starting-state)
* [B. The desktop package](#b-the-desktop-package)
* [C. The clean-room environment](#c-the-clean-room-environment)
* [D. Installation and compilation](#d-installation-and-compilation)
* [E. Real desktop execution](#e-real-desktop-execution)
* [F. The independent agent experiment](#f-the-independent-agent-experiment)
* [G. Deployment](#g-deployment)
* [H. Verification](#h-verification)
* [I. Remaining limitations](#i-remaining-limitations)
* [J. Developer-experience conclusion](#j-developer-experience-conclusion)
* [What to run when changing this](#what-to-run-when-changing-this)
* [Files](#files)

## 0. Before the change

Written from the code and from runs before anything changed (**Executed**
where a result is quoted):

| area | finding | class |
|---|---|---|
| The released library | `tools/package-repository.tcl`'s raven recipe took `tests/cffi/raven.tcl`'s default configuration for the host (`-DRAVEN_PLATFORM=null -DRAVEN_BACKEND_VULKAN=OFF`) and built AArch64 headless explicitly. `raven::start(raven::desktop())` over that library fails at once: `RavenFailed Rinit_ex: Raven was built without the Vulkan backend`. No consumer of 0.2.0 could open a window. | package construction |
| The desktop build | existed only for one test (`BOTLISH_RAVEN_CMAKE_FLAGS="" tclsh9.0 tests/cffi/raven.tcl`): CMake's defaults, with the Vulkan headers downloaded by Raven's own CMake by tag, unpinned. Its cache directory was keyed by a CRC of the flags, and a build was recognized by `libraven.so*` merely existing there (and anything under `BOTLISH_RAVEN_DIR`). | package construction |
| Headless from a desktop build | Raven compiles `src/platform/null` and `src/render/null` into every configuration (CMakeLists.txt), so one library could serve both -- untested until now. | (an opportunity) |
| Native dependencies | the desktop library's `DT_NEEDED` is `libm.so.6 libX11.so.6 libc.so.6 ld-linux-x86-64.so.2`; at run time it `dlopen`s `libvulkan.so.1` (the renderer), `libX11-xcb.so.1` (only for an XCB-only driver) and `libdbus-1.so.3` (accessibility, when asked for). PM-2's closure check would refuse the desktop library unless libX11 were declared. | native runtime prerequisite |
| The wrapper's startup errors | `start` reported only Raven's last error: `Rinit: cannot initialize the X11 window system` without a display, `Rinit: cannot initialize the Vulkan backend` without a driver. The cause Raven reported a moment earlier (`X11: cannot open the display (is DISPLAY set?)`, `Vulkan: the Vulkan library (libvulkan.so.1) was not found; is a Vulkan driver installed?`) sat unread in the bridge's queue and was cleared by `stop`. | Raven wrapper limitation |
| Consumer documentation | the package's README described the repository workflow (`tclsh9.0 tests/cffi/raven.tcl`, `tools/raven-package.tcl install`, `-L`, `LD_LIBRARY_PATH`): a developer with only the artifact could not follow any of it. The API was documented only by `raven.bot`'s comments; the artifact held no guide and no example. | documentation/discoverability |
| Immutability on the author's side | the tool packed with `-force 1`: re-running it over a repository holding a different `raven-0.2.0.botpkg` replaced that release silently under its version. It printed the digest but not the targets. | package construction |
| The compiler | nothing missing: the single-file compiler already had `add`, `native plan`, `native deploy`, `-runtime-path`, the native backends and Compilerpedia offline (`botlish -help`). It links a program that calls C with the host's `cc` (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md): a real host prerequisite, kept. | -- |

## A. Starting state

The PM-2 artifact was headless because the author's recipe was written for
the package's automated tests, which use Raven's null platform: the host's
library came from `tests/cffi/raven.tcl`'s default configuration, AArch64's
from a cross build with the same flags. That was enough for PM-2's
question (can a native package be consumed with no `-L` and no
`LD_LIBRARY_PATH`?) and nothing more: the release could not open a window
(the error above), so a clean-room developer could at most write a
headless program. Around that gap, the developer also lacked any
documentation they could use (the README was the repository's), a way to
tell from a failed start what was missing (the generic last error), and
an example to start from. The compiler and the package manager were not
the obstacle.

## B. The desktop package

### The release

| | |
|---|---|
| package | `raven` 0.3.1 (a new version: 0.2.0, the headless release, stays what it was) |
| artifact | `raven-0.3.1.botpkg`, 1,735,590 bytes, 56 files |
| SHA-256 | `9336738e652d741e5a2d4785dcc1dc36f2e0b6f4d24329a20a0707df28ac5812` |
| earlier candidate | `raven-0.3.0.botpkg`, sha256 `927f7850964507a279522b2c0810288841d187269dec733f75a84b0a8915485d`: packed by this milestone before the experiment, the artifact the independent agent used. Its contents never change under that version: the experiment's fixes (`checkbox_text`, three documentation points) made 0.3.1 |
| targets | linux-x86_64 (built, inspected, executed), linux-aarch64 (built, inspected; not executed) |
| made by | `tclsh9.0 tools/package-repository.tcl OUT raven` (section "The author's one operation") |

What it holds (**Executed**: `pw-raven-artifact-contents` checks the exact
list):

```
botlish.json  raven.bot  README.md  GUIDE.md  native/raven_bridge.c
examples/clicks/clicks.bot  examples/clicks/main.bot  examples/clicks/test.bot
targets/linux-x86_64/raven/*.bot          the generated binding (22 modules, committed generated/c/raven/linux-x86_64)
targets/linux-x86_64/native/libraven_bridge.a    the event bridge, built for the target
targets/linux-x86_64/native/libraven.so.0        Raven's desktop build, stripped
targets/linux-aarch64/...                  the same for AArch64
```

Nothing in it runs at installation: there is no script, hook or build
file, and the package manager executes nothing a package holds (PM-1).

### The desktop build

`tests/cffi/raven.tcl` now has two named configurations, each in its own
cache directory and recognized by the stamp it writes last (configuration,
Raven commit, flags, Vulkan headers commit), never by a library merely
present:

| configuration | flags | directory |
|---|---|---|
| `headless` (default) | `-DRAVEN_PLATFORM=null -DRAVEN_BACKEND_VULKAN=OFF` | `raven/cd228d8e...` |
| `desktop` | `-DRAVEN_PLATFORM=x11 -DRAVEN_BACKEND_VULKAN=ON -DRAVEN_FETCH_VULKAN_HEADERS=OFF -DRAVEN_VULKAN_INCLUDE_DIR=<pinned>` | `raven/cd228d8e...-desktop-b379292b2ab6` |

The Vulkan headers are Khronos's `Vulkan-Headers` v1.3.290 (the version
Raven's CMake asks for), fetched by tag and checked by commit
`b379292b2ab6df5771ba9870d53cf8b2c9295daf` with the repository's existing
fetcher (`::chdr::fetch`), never Raven's own tag-only download and never
whatever SDK the machine has. They are an author-side input only: Raven
needs headers to build its renderer, never a library (it `dlopen`s the
loader).

**One library for both configurations (Executed).** Raven compiles its
null platform and renderer into every build. The desktop library, with no
display, gives exactly the headless library's values for the example's
scripted counter, every event kind, the lifetime tests and the timers on
both native backends (`raven-desktop-headless`). So the release bundles
one library; there is no variant, feature flag or second artifact. The
cost is size: 1,767,912 bytes stripped against 1,603,400 for the headless
build.

**AArch64 (Executed: built and inspected; Not done: run).** The cross
build uses Raven's CMake with `aarch64-linux-gnu-gcc` and links against
AArch64's libX11, which the author's machine does not have: the tool takes
Ubuntu 24.04's arm64 packages (`libx11-6`, `libx11-dev`
2:1.8.7-1ubuntu0.1, `x11proto-dev` 2023.2-1) from ports.ubuntu.com,
pinned by SHA-256. The pinned digests are the archive index's, checked
when they were recorded against the index's signature: `gpgv` with the
Ubuntu archive key ("Good signature from Ubuntu Archive Automatic Signing
Key (2018)") over `InRelease`, whose SHA-256 of `Packages.gz` matched, whose
entries are the pins. They are a link-time stand-in for the target
system's libX11 and are never packed. The library is an ELF AArch64 shared
object needing `libm.so.6 libX11.so.6 libc.so.6 ld-linux-aarch64.so.1` and
exporting the same 951 functions as x86-64's. No AArch64 machine was
available: it has never run.

### Runtime dependencies in the metadata

```json
{"name": "raven", "origin": "bundled", "linkage": "shared",
 "file": "native/libraven.so.0", "identity": "libraven.so.0",
 "needs": ["libm.so.6", "libX11.so.6", "libc.so.6", "ld-linux-x86-64.so.2"],
 "symbols": ["Rinit_ex", "Rvulkan_get_instance"]},
{"name": "X11", "origin": "system", "linkage": "shared",
 "identity": "libX11.so.6", "symbols": ["XOpenDisplay"]}
```

(per target; AArch64's needs `ld-linux-aarch64.so.1`). Every fact here is
PM-2's existing vocabulary, checked by PM-2's existing code:

* `needs` is exactly the binary's `DT_NEEDED`, checked at packing and at
  every view.
* `symbols` makes "this is the desktop build" a checked fact:
  `Rvulkan_get_instance` exists only in a Vulkan build (raven_vulkan.h's
  functions), so a headless library packed in its place is refused
  (`pw-raven-metadata-checked`).
* libX11 is a **system** library: the bundled libraven's need of
  `libX11.so.6` must resolve (PM-2's closure rule refuses the release
  without the declaration: `pw-raven-metadata-checked`), and on the host
  `botlish add` verifies it by the distribution's metadata -- dpkg's
  `libx11-6` in the clean room, pkg-config's `x11.pc` on a machine with the
  development package -- then inspects the file (shared object, soname,
  `XOpenDisplay`).

What is deliberately **not** metadata:

* **The Vulkan loader** (`libvulkan.so.1`) is `dlopen`ed by Raven's
  renderer when a program starts it, not a loader dependency. Declaring it
  a system library would make installation fail where a headless program
  needs no Vulkan at all. PM-2 has no class for an optional, run-time
  loaded dependency (section I). It is documented in the package's README
  and reported by `start` when missing.
* **The driver** (an ICD: a GPU's, or Mesa's lavapipe) is not a library
  anything links; a loader with no usable driver is a different failure
  from no loader, and both are reported by `start` (section E).
* **The display** is an X server, not a file.

None of these is bundled: graphics drivers and the loader are the
operating system's.

### The wrapper's startup report

`raven::start` now fails with `RavenFailed {call, code, detail}` whose
`detail` is every error Raven reported while it tried to start, oldest
first: the bridge already recorded them as Error events (it watches
errors before `Rinit_ex`), and `start` reads them before `stop` clears the
queue (`startup_reasons`, `error_texts`; private, no new API). **Executed**
in the clean room and by `raven-desktop-no-display`/`-no-vulkan`:

| situation | detail |
|---|---|
| no display | `X11: cannot open the display (is DISPLAY set?); Rinit: cannot initialize the X11 window system` |
| a display, no Vulkan driver (`VK_ICD_FILENAMES` naming none) | `Vulkan: the driver cannot present to a window (no surface extension); Rinit: cannot initialize the Vulkan backend` |
| a display, no Vulkan loader | `Vulkan: the Vulkan library (libvulkan.so.1) was not found; is a Vulkan driver installed?; Rinit: cannot initialize the Vulkan backend` |
| a `libvulkan.so.1` that is no loader first on the path | `Vulkan: vkGetInstanceProcAddr is missing from the Vulkan library; Rinit: cannot initialize the Vulkan backend` |

None crashes. A missing libX11 (the one hard runtime dependency) stops the
program before it runs, with the system loader's own message; `botlish
add` refuses to install where it is missing and writes nothing
(**Executed** in a throwaway clean-room container with `libx11-6`
removed: "system library X11 (libX11.so.6 or libX11.so) is not
installed ...", exit 1, the project directory empty).

### The consumer's documentation

The artifact now carries what a developer reads, written for someone who
has only the artifact and the compiler:

* `README.md`: requirements by configuration, with Ubuntu package names;
  installation (`botlish add FILE.botpkg`); a complete first window;
  running (`-backend cranelift`: the default `interp` cannot call C);
  testing without a display; shipping an executable (deploy,
  `-runtime-path '$ORIGIN/lib'`, the loader's precedence); a table of
  startup failures; what is not supported.
* `GUIDE.md`: the API by task -- the shape of a program and which
  functions need the context `raven::Ui`, starting and stopping, windows,
  panels, every control with its event, the frame loop (a clause-less
  `fold` ended by `break`, or a self-tail-recursive function), the Event
  fields, errors, headless testing with synthetic input, actions, timers,
  themes, XML, the generated binding, and the pitfalls met while writing
  the examples.
* `examples/clicks/`: an application module, its desktop entry and its
  deterministic headless test.

Every ` ```botlish ` block of the two guides is a complete program;
`raven-package-docs` compiles them under `-warnings error` and runs the
test programs to the values the documents state. Language documentation
needed no new mechanism: `botlish -help primer` and `botlish -help QUERY`
(Compilerpedia, offline in the single-file compiler) answer it.

### The author's one operation

```
$ tclsh9.0 tools/package-repository.tcl OUT raven
packed raven 0.3.1: OUT/raven-0.3.1.botpkg
  sha256 9336738e652d741e5a2d4785dcc1dc36f2e0b6f4d24329a20a0707df28ac5812
  56 files, 1735590 bytes (4076210 bytes unpacked)
  target linux-aarch64: 32 files, libraries raven_bridge (bundled static), raven (bundled shared), X11 (system shared)
  target linux-x86_64: 32 files, libraries raven_bridge (bundled static), raven (bundled shared), X11 (system shared)
  targets linux-aarch64, linux-x86_64
```

It fetches the pinned Raven (`tools/c-bindgen.tcl fetch raven`), builds
the desktop configuration for the host (`cffi::ravenBuild desktop`) and
cross-builds AArch64's, checks each is the desktop build
(`author::checkDesktop`: the target's shared object, loading libX11.so.6,
exporting `Rvulkan_get_instance`) before anything is staged, builds the
bridge for each target, stages the committed generated binding of each
target, and packs with the standard writer, whose PM-2 checks validate the
native metadata against the files. No identity, digest or path is edited
by hand. **Executed**: the host's desktop build takes 14 s (Raven's
CMake and Ninja, the Vulkan headers fetched once), the first packing with
the AArch64 cross build (and the arm64 packages fetched) 19 s more; again
with the builds cached 1.4 to 1.6 s, and the artifact's bytes are
identical (`(unchanged)`, same SHA-256). It no longer forces: a
repository already holding a different `raven-0.3.1.botpkg` is refused (`EXISTS`, the file left as it was) unless
the author passes `-force` (`pw-raven-release-immutable`).

Author-side prerequisites: Tcl 9, git, CMake, Ninja, a C compiler, libX11's
development headers, the GNU AArch64 cross compiler and its C library
(Ubuntu: `gcc-aarch64-linux-gnu`, `libc6-dev-arm64-cross`), curl and
dpkg-deb (the arm64 packages), network access once. None of them reaches the
consumer.

## C. The clean-room environment

`audit/raven-cleanroom/` (**Executed**):

* **The image** (`Dockerfile`): `ubuntu:24.04` plus these packages (and
  their dependencies, without recommended ones): `gcc`,
  `libc6-dev` (the C compiler driver and the C library's link files: the
  native backend links a program that calls C with the system linker),
  `libx11-6` (libX11), `libvulkan1` (the loader), `mesa-vulkan-drivers`
  (lavapipe: there is no GPU), `xvfb` (a display without a monitor), and,
  for the test harness only, `python3` and `libxtst6`. A user `dev`.
* **A container** (`tools/cleanroom.sh run COMPILER BOTPKG OUT`) is
  created with `--network none` and no volume or bind mount. Exactly two
  Botlish inputs are copied in -- `single/out/botlish` (14,461,523 bytes)
  and the `.botpkg` -- and, for the automated acceptance, the harness:
  `inside.sh`, `window.bot` (the test's own application, written for it),
  `desktop-session.sh` and `xsession.py` (an X client).
* **Checked inside** (the transcript's first section): Ubuntu 24.04.5,
  glibc 2.39, the only network interface `lo`; `tclsh`, `tclsh9.0`,
  `cargo`, `rustc`, `cmake`, `ninja`, `git`, `curl`, `wget`, `clang` all
  absent; `find / -xdev` finds no `main.tcl`, `c-bindgen.tcl`,
  `raven-package.tcl`, `package-repository.tcl`, `Raven.h`,
  `raven_core.h` or Raven `CMakeLists.txt`; `/home` holds `dev` (and the
  image's `ubuntu`); `LD_LIBRARY_PATH` unset.

Host facilities versus Botlish/Raven build dependencies:

| needed in the clean room | why | a build dependency of Botlish or Raven? |
|---|---|---|
| `cc` + `libc6-dev` | the native backend links C-calling programs with the system linker | no: a host facility the single-file compiler retains (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md) |
| libX11 | libraven's DT_NEEDED | no: the system's |
| the Vulkan loader, a driver, a display | Raven's desktop configuration at run time | no |
| python3, libXtst | the harness's X client | no: the developer never needs them |

## D. Installation and compilation

From the clean room's transcript (**Executed**), as `dev`, in a fresh
project directory:

```
$ botlish add /home/dev/inputs/raven-0.3.1.botpkg
raven 0.3.1 (sha256 9336738e652d): installed
view linux-x86_64: derived (35 files, 3 native libraries)
added raven (request "0.3", lock 0.3.1)
$ botlish verify                      # exit 0
$ botlish native plan
  library raven_bridge: bundled static ...  library raven: bundled shared ...
    loads as libraven.so.0, needs libm.so.6, libX11.so.6, libc.so.6, ld-linux-x86-64.so.2
    requires GLIBC_2.38 or newer on the target system
  library X11: system shared (instance raven)
    ELF x86-64 shared object; dpkg package libx11-6, version 2:1.8.7-1ubuntu0.1
link: ... no -L is needed for bundled libraries
$ botlish install -target macos-aarch64       # UNSUPPORTED (the package's own list)
$ botlish install -target linux-aarch64       # the second view, from the same artifact
```

| step | what ran | outcome |
|---|---|---|
| installation | the package manager inside the single-file compiler: archive validation, the view, native inspection, dpkg lookup | no compiler, CMake, download or package script ran (none is installed; the container has no network) |
| source compilation | the front end over the application, `raven` and the 10 generated modules it imports | the example's three files and the acceptance program compile under `-warnings error` |
| native linking | the system linker (`cc`) with the bridge archive from the instance and `libraven.so` from the view's `.lib` | no `-L`, no environment variable |
| native execution | `-backend cranelift` and `cranelift-generic` | the example's test `["2", "2 clicks", "0", "0 clicks"]` on both; `interp` refuses (NATIVE-ONLY) |

## E. Real desktop execution

`desktop-session.sh` starts Xvfb, runs the program, and from then on acts
only through the X server, as a user would: `xsession.py` finds the
window by its title, reads its pixels (`XGetImage`), clicks the controls'
middles through XTest (`XTestFakeMotionEvent`, `XTestFakeButtonEvent`) and
asks the window to close as a window manager does (a `WM_PROTOCOLS` /
`WM_DELETE_WINDOW` client message). The program (`window.bot`, written
for the acceptance: a label, a checkbox and two buttons) reports its
state on standard output; nothing is injected into Raven.

**Executed**, in the clean room with the release (the `cranelift`
session; `audit/raven-cleanroom/results/acceptance/`), the same on
`cranelift-generic` and for the relocated executable (section G):

```
ok    ready frame 360 180                       Rwindow_capture of the first frame: the window's size
ok    window id 2097165 at 0,0 size 360x180      found by the X server
ok    rendered the window's pixels hold 307 colors (360x180)
ok    click-add -> state 1 false 1 clicks true   (count, shout, the label Raven holds, frame changed)
ok    pixels-changed 1937 pixels differ after the first click
ok    click-shout -> state 1 true 1 clicks! true
ok    click-add -> state 2 true 2 clicks! true
ok    click-reset -> state 0 true 0 clicks! true
ok    closed exit status 0, closed 0             WM_DELETE_WINDOW ended the frame loop, Raven stopped
PASS
```

* **Renderer**: Raven's Vulkan backend on Mesa's lavapipe (the libraries
  the running process mapped, read from `/proc/PID/maps`, include
  `libvulkan.so.1.3.275` and `libvulkan_lvp.so`). The null renderer could
  not have produced the pixels: it draws nothing and its capture is 0 x 0.
* **Input**: X11 button events through XTest, delivered by Raven's X11
  platform, recorded by the event bridge, read by the program after the
  frame.
* **Visible state**: every click changes the program's state and the label
  Raven holds, and the X server's copy of the window changes (1,768 to
  1,937 of 64,800 pixels after the first click in the three sessions --
  the button's hover state depends on timing; no pixel-exact comparison,
  which would depend on the driver too). `session-moved/*.png` are three
  of the captures.
* **Shutdown**: a window manager's close request ends `wait_frame`'s loop;
  `raven::stop`; exit status 0.

The same session runs on the development host as `raven-desktop-session`
(`tests/raven.test`), beside the earlier `raven-desktop` (synthetic input
on a real window, the captured frame). Headless runs are separate tests
(`raven-desktop-headless`, the example's test): a headless instance never
counts as a window here.

## F. The independent agent experiment

### Setup

* **The agent**: a fresh general-purpose agent (the same model as the
  session that ran this milestone), with no access to that session's
  conversation. Its whole brief is `audit/raven-cleanroom/results/
  agent-experiment/PROMPT.md`: the environment and how to reach it, the
  two inputs, the rules, the application to build and what to deliver.
  The brief names neither the package's documents, nor `botlish add`, nor
  `-backend cranelift`: finding them was part of the task.
* **The environment**: a clean-room container (`tools/cleanroom.sh
  start`) holding only the single-file compiler and
  `raven-0.3.0.botpkg` (sha256 `927f7850...`, the release candidate),
  with no network, nothing mounted, and none of the acceptance harness.
  The agent reached it only through one wrapper, `cr` (`docker exec` as
  `dev`), which appended every command and its output to a trace.
* **The task**: "Tasks", a task manager: a window titled "Tasks", a text
  input and an Add button (an empty text adds nothing; the input is
  cleared), one checkbox per task (checked = done), a status label "N
  tasks, M done", a "Clear done" button removing done tasks from the state
  and the window, a clean close, a deterministic test, and evidence of a
  real desktop window -- two control types and more, state, a change, a
  reset, shutdown, a test. Within the wrapper's functions: no callback, no
  custom painting, no virtual list.
* **Isolation, as it was.** The container's processes could not reach the
  repository. The agent itself ran on the development host, so its own
  tools could have: the brief allowed only Bash, and only to run the
  wrapper. A Bash-only agent type was defined, but the harness does not
  load new agent types mid-session. **Audit** (a script over the agent's
  transcript): 93 tool uses -- 92 Bash calls, each beginning with the
  wrapper (116 wrapper invocations in the trace), and the final report; no
  Read, Grep, Glob, Edit, Write, web or agent tool. **One contamination**,
  which the agent disclosed itself and its transcript confirms: the
  harness put the repository's AGENTS.md (this milestone's starting
  version, about 5,000 lines of contributor rules) into the agent's
  context as project instructions. It holds no Raven API (Raven appears in
  three lines naming test tools), so the result on Raven's discoverability
  stands; it does describe Botlish's language rules (folds, contexts,
  warnings, method resolution), so the result on learning the language is
  optimistic -- a real newcomer starts from `botlish -help primer`, which
  the agent also read first.

### What happened

From the trace (`commands.txt`, `trace.log`) and the agent's log
(`app/NOTES.md`): 06:52 to 07:15 UTC, 23 minutes, 116 commands.

1. **First contact**: `botlish` (usage), `botlish -help` (the index, with
   its "before you write a program" table), `botlish -help primer`.
2. **Installation**: `botlish add -help`, `-help cli.packages`, `botlish
   package inspect` of the artifact, then `botlish add
   ~/inputs/raven-0.3.0.botpkg` -- first try, no flag, no environment
   variable.
3. **Learning the package**: `.bot_modules/raven/README.md`, then
   `GUIDE.md` ("especially its Testing and Pitfalls sections"), `raven.bot`,
   `examples/clicks` (copied, `test.bot` run: the documented value), and a
   grep of the generated binding (`raven/controls.bot`) for checkbox
   functions.
4. **The application** (`tasks_app.bot`, 110 lines): the state an
   immutable `List[Task {text, done, box}]`; each frame's events folded into
   the next state (`handle`: Add or Enter adds, Toggled marks, Clear done
   destroys the done tasks' checkboxes and drops them), the status label
   set after each frame; the self-tail-recursive frame loop of the
   example. It and `main.bot` passed `botlish -check` the first time.
5. **The test** (`tasks_check.bot`, 13 steps, 27 checks; `test.bot`
   headless, `test_desktop.bot` on a real window with 4 more checks of the
   captured frames): after each step it compares the application's state
   and what Raven holds -- the label, the input, the panel's rows, each
   checkbox's text and checked state. The agent checked its test can fail:
   with the empty-text guard and `destroy()` removed, 25 of 27 checks fail.
6. **The desktop**: Xvfb and Mesa's lavapipe; with no X client tools in the
   environment it wrote `xdrive.py` (an X11 protocol client in Python's
   standard library: window list, screenshots, XTest input, the
   `WM_DELETE_WINDOW` close) and `layout_probe.bot` (widget centres from
   `rect()`), then `run-desktop-test.sh`: real typing and clicks into
   `main.bot` ("Buy milk", Add, an empty Add, "Write report" and Enter,
   check "Buy milk", Clear done, close), whose final value is exactly what
   those inputs lead to.
7. **Shipping**: `botlish native deploy` and `-emit-native-executable
   -runtime-path '$ORIGIN/lib'` from the README; `dist/tasks` opened the
   window and exited 0 when closed.

**Verified independently (Executed)** after the agent finished, in its
container: `./run-test.sh` prints `27 passed, 0 failed`, `value: "TEST
PASS: 27 checks"`, exit 0; `./run-desktop-test.sh` ends `main.bot exited
with status 0 ... value: "closed with 1 tasks, 0 done"`, `DESKTOP TEST
PASS`, exit 0. **The full task succeeded.** The source, tests, notes,
evidence and trace are `audit/raven-cleanroom/results/agent-experiment/`;
the agent's built executable was not kept, and the manual workflow
`tasks app (raven, manual)` (`.github/workflows/tasks-app.yml`) builds the
same sources with the current release in a clean-room container
(`audit/raven-cleanroom/tools/build-app.sh`: the headless test, deploy,
`-emit-native-executable`, a window opened and closed on a virtual
display) and publishes them as the artifact `tasks-linux-x86_64`.

### Obstacles, classified

| obstacle | class | what this milestone did |
|---|---|---|
| The wrapper reads a label's and an input's text but not a checkbox's; `label_text` of a checkbox is "" and an Error event. The agent read `Rcheckbox_get_text`'s C string itself (`readback.bot`): a native view over a 4096-byte layout, byte by byte to the NUL, behind a context of its own to mediate the direct authority -- correct, and exactly the raw-memory work a wrapper exists to hide. | Raven wrapper limitation | fixed in 0.3.1: `raven::checkbox_text` (`raven-texts`) |
| A widget added after a frame needs another frame before `click` can aim at it (inferred by the agent) | documentation | 0.3.1's GUIDE says so |
| How to check a real window from outside; no X client tools in the environment | documentation; native environment prerequisite | 0.3.1's GUIDE names the approach (XTest, `WM_DELETE_WINDOW`); no tool is shipped (the clean room's `xsession.py` is the repository's, a test harness) |
| `xs.length()` of a List with only `std::str` imported: a TYPE error naming `std::str::length`, no hint to import `std::list` (where no other `length` is visible, MISSING-IMPORT names the import: `.at` does) | compiler diagnostic defect | 0.3.1's GUIDE pitfall; the diagnostic is a follow-up |
| A program cannot set its exit status; a test reports its verdict as its value | Botlish language limitation (documented: `capability.process-exit-status`) | 0.3.1's GUIDE says so |
| A context struct's `int` field: CONTEXT-NATIVE-LOWERING-UNSUPPORTED (clearly explained) | Botlish native-backend limitation | none |
| Every run spends 8-10 s compiling (the front end over `raven` and the generated modules) | tooling cost | measured: the opt-in front-end cache (`BOTLISH_HIR_CACHE`) makes a repeated run 1.7 s; nothing tells a package consumer (follow-up) |
| Forward references, a `substring` bound proof, `Usize` versus `int`, `UChar` versus `Byte`, resource-escape, one-character-string and method-syntax warnings | language rules; "diagnostics were good" (each named its fix) | none |
| Shell quoting slips, an Xvfb started without `< /dev/null`, a `pkill -f` that killed its own shell | the agent's own mistakes | none (this milestone's author made the last one too) |

What the agent found on its own: all of it -- the install command, the
native backend, where the documentation is, the frame loop, events,
headless testing, deployment. It guessed no Raven name or signature
(three small inferences, each confirmed by the compiler: building
`raven::Widget {id: 0}`, `Bytes.length()` being a `Usize`, using the
binding's `Rwidget_get_child` for the panel's rows). It needed no
package-specific or manual command beyond starting Xvfb. It could test
without a human desktop: headless deterministically, and on a virtual
display with real input.

## G. Deployment

From the clean room's transcript (**Executed**):

```
$ botlish native deploy -target linux-x86_64 -out dist        # dist/lib/libraven.so.0
$ botlish -emit-native-executable -runtime-path '$ORIGIN/lib' window.bot
$ botlish -emit-native-executable -runtime-path '$ORIGIN/lib' test.bot
$ mv window test dist/ && mv dist /home/dev/elsewhere/deep/moved
$ readelf -d window   NEEDED libraven.so.0 libgcc_s.so.1 libm.so.6 libc.so.6 ld-linux-x86-64.so.2; RUNPATH [$ORIGIN/lib]
$ botlish remove raven                # the project's .bot_modules gone
$ find / -name 'libraven.so*'         # only /home/dev/elsewhere/deep/moved/lib/libraven.so.0
$ ldd moved/window | grep raven       libraven.so.0 => /home/dev/elsewhere/deep/moved/lib/libraven.so.0
$ moved/test                          ["2", "2 clicks", "0", "0 clicks"]     (no DISPLAY)
$ desktop-session.sh ... moved/window PASS (the session of section E)
  mapped: /home/dev/elsewhere/deep/moved/lib/libraven.so.0, /usr/lib/x86_64-linux-gnu/libX11.so.6.4.0,
          libvulkan.so.1.3.275, libvulkan_lvp.so, ...
```

That transcript predates PROGRAM-OUTPUT-MILESTONE-1.md, when an executable
printed its program's value. An executable now writes nothing of its own:
the acceptance runs `moved/test` with `BOTLISH_NATIVE_RESULT` and checks
the words of the result file's `value` line (`value list str 2 str 2
clicks str 0 str 0 clicks`).

No `LD_LIBRARY_PATH` and no package tree: the executable's RUNPATH found
the deployed library, and the running process's own memory map shows it
loaded that file (not a copy elsewhere: there is none). The system's X11
and graphics stack stayed installed, as they must.

**Loader precedence (Executed).** `LD_LIBRARY_PATH=/tmp/decoy ldd
moved/window` resolves `libraven.so.0 => /tmp/decoy/libraven.so.0`: glibc
searches `LD_LIBRARY_PATH` before RUNPATH, so a user's environment can
substitute the library. Deployment is relocation, not isolation; the
package's README says so. (`DT_RPATH` would precede `LD_LIBRARY_PATH` but
is deprecated and not what `-runtime-path` writes; neither prevents a
`LD_PRELOAD`.)

## H. Verification

All on Linux x86-64 (Ubuntu 24.04), `LANG=C.utf8 LC_ALL=C.utf8`, each test
file with a private `-tmpdir`. **Executed**:

| command | result |
|---|---|
| `audit/raven-cleanroom/tools/cleanroom.sh run single/out/botlish OUT/raven-0.3.1.botpkg DIR` | 33 checks, 33 passed (PASS), about 2 minutes; the transcript is `audit/raven-cleanroom/results/acceptance/` (and 33 of 33 with 0.3.0 before the experiment) |
| `tclsh9.0 tests/raven.test` | 19 tests, 19 passed, 0 skipped (desktop build, Xvfb, lavapipe, python3 and libXtst present) |
| `tclsh9.0 tests/package-workloads.test` | 19 tests: 12 passed (the 8 Raven workloads, both pure-Botlish and both event-loop ones), 7 skipped (the SDL3 workloads: no package-owned SDL3 built here), 0 failed |
| `tclsh9.0 tests/c-bindgen.test -match 'cb-raven-*'` | 6 passed |
| `tclsh9.0 audit/raven-cleanroom/tools/mutate.tcl` | 13 mutants, 13 killed |
| `tclsh9.0 tests/local.tcl tests/raven.test tests/package-workloads.test tests/c-bindgen.test tests/package-manager.test` | each file on interp and compile: 164 passed, 0 failed, 39 skipped on each pass (the SDL3 workloads and the c-bindgen tests of profiles whose sources are not fetched here); no golden suite holds their tests |
| `tclsh9.0 audit/golden/migration/merge.tcl -names audit/golden/migration/tcl-names.txt -check 1` | exit 0 (13 new census rows, KEEP-INTERNAL, -MULTI-PROGRAM or -NOT-EXPRESSIBLE) |
| `tclsh9.0 tools/compilerpedia.tcl check` | 1149 topics, 701 examples run, 0 problems |

The new tests, by the milestone's list (1-20):

| # | case | test |
|---|---|---|
| 1 | desktop package construction | `pw-raven-desktop-release`, `raven-desktop-build`; the clean room |
| 2 | version and immutable digest | `pw-raven-release-immutable` (identity printed, bytes reproduced, a different file refused without `-force`) |
| 3 | headless/desktop cache separation | `raven-build-configurations` |
| 4 | desktop runtime dependencies in metadata | `pw-raven-desktop-release`, `pw-raven-metadata-checked` |
| 5 | installation without development tools | the clean room (none installed); `pw-raven-installs-without-a-compiler` (PATH emptied) |
| 6 | binding and bridge presence | the clean room (`installed-binding`, `installed-bridge`); `pw-raven-artifact-contents` |
| 7 | bridge ABI compatibility | `raven-bridge-abi` (unchanged) |
| 8 | a real X11/Vulkan window | `raven-desktop-session`, `raven-desktop`; the clean room's three sessions |
| 9 | UI changes after a real event | the same (XTest clicks; state, label and pixels) |
| 10 | clean graphical shutdown | the same (`WM_DELETE_WINDOW`, exit status 0) |
| 11 | headless with the desktop library | `raven-desktop-headless`; the clean room's example test |
| 12 | missing X11 display | `raven-desktop-no-display`; clean room `no-display-actionable` |
| 13 | missing or unusable Vulkan | `raven-desktop-no-vulkan` (no driver; a fake loader); clean room `no-driver-actionable`; no loader at all **Executed** by hand (a bind mount over `libvulkan.so.1` in a mount namespace, section B), not a test: it needs privileges |
| 14 | unsupported targets | `pw-raven-targets`; clean room `unsupported-target` |
| 15 | no manual linker flags or library paths | `pw-raven-runs`, `pw-raven-deploy-relocates` (`LD_LIBRARY_PATH` empty); the clean room (none anywhere) |
| 16 | relocatable executable after package removal | `pw-raven-deploy-relocates`; clean room `desktop-moved`, `maps-deployed-library` |
| 17 | single-file compiler outside the checkout | the clean room |
| 18 | documentation and samples from installed artifacts | `raven-package-docs`; clean room `example-test`, `example-main-checks` |
| 19 | no package installation scripts | `pw-raven-artifact-contents`; PM-1's no-execution rule and tests |
| 20 | existing Raven tests still valid | `tests/raven.test` (the 11 earlier tests), `pw-raven-*`, `cb-raven-*` |
| -- | the experiment's wrapper gap | `raven-texts` (`checkbox_text`, and `label_text` of a checkbox refused by Raven) |

**Mutation testing** (`audit/raven-cleanroom/tools/mutate.tcl`, its own
harness: a private copy of the tree, each mutant's test files with a
`-match`): the cache recognizing a library without its stamp, the desktop
configuration in the headless directory, a stamp without the Vulkan
commit, the tool forcing over an existing release, packing the headless
library (with and without the desktop check: the pack's own metadata
checks catch the second), an extra script in the release, the version
left at 0.2.0, the X11 declaration dropped, `start` reporting only the last
error or only the first, the documented example's Reset broken, and
`checkbox_text` reading a label's text -- 13 mutants, 13 killed, each by
the test its line names.

**CI.** `.github/workflows/raven-cleanroom.yml` (new) builds the single
executable and the release and runs the clean room on a push touching
these files; `c-bindgen.yml` builds the pinned desktop configuration
(`tests/cffi/raven.tcl desktop`) and installs python3 and libXtst for
`raven-desktop-session`. **Executed on GitHub's ubuntu-24.04
runners**: the clean-room workflow's first run failed packing (the
AArch64 cross compiler needs `libc6-dev-arm64-cross`, which this
machine had and the workflow did not install: fixed); its second run
(41410971721) packed the release from scratch in 34 s, built the image
and passed all 33 checks. `c-bindgen.yml` did not run on this branch
(its triggers are main's).

**Reproducibility.** The runner's 0.3.1 has sha256 `4cb6c223...`
(1,735,598 bytes; the same 4,076,210 bytes unpacked), not this
machine's `9336738e...`. On one machine the operation is reproducible --
repeated packing gives identical bytes, and the desktop libraven built
in two different cache directories is byte-identical (the same GNU build
ID) -- so the difference is the runner's toolchain or library packages,
not paths. The release is the artifact this report records; a rebuild on
another machine is a different file and must not be published as 0.3.1
(the tool refuses to overwrite one in the same repository, but cannot
know about another machine's). Section I lists it.

**Hosts.** Only Linux x86-64 was available. Linux AArch64: built and
inspected only. macOS and Windows: the package refuses them (UNSUPPORTED);
nothing was attempted.

## I. Remaining limitations

**Defects or gaps of this milestone's own scope:**

* The release's AArch64 library has never run (no AArch64 host here; CI's
  arm64 workflow does not build the package).
* Author builds are reproducible on one machine, not across machines: a
  release's bytes depend on the build machine's compiler and libraries
  (section H). Nothing yet pins the author's toolchain (a container image
  for the recipe) or records it in the release (PM-3, PM-5).
* The clean room proves the absence of a checkout for the container's
  processes; the independent agent's own tools were restricted by
  instruction and audited afterwards (section F), not by enforcement.

**PM-3 (deliberately deferred):**

* The author's side is still a per-package recipe in
  `tools/package-repository.tcl` (a `switch` arm per package), with its
  own pins for Raven, the Vulkan headers and the arm64 libX11 packages.
* No metadata class for an optional, run-time loaded native dependency
  (Raven's `dlopen` of `libvulkan.so.1`): `native plan` cannot report the
  loader, only the documentation and `start` can.
* No provenance: nothing records how the bundled libraven was built.
* The pinned arm64 packages live on ports.ubuntu.com's pool, which drops a
  superseded version: the pin then fails loudly, and the author updates
  it (never silently).
* A package-manager diagnostic cascade (**Executed** in a throwaway
  clean-room container with `libx11-6` removed): `botlish add` correctly
  refuses and writes nothing, but after "system library X11 (libX11.so.6
  or libX11.so) is not installed" it adds "raven needs libX11.so.6, which
  is neither part of linux-x86_64's platform nor a library of this
  application's packages (declare it ... in the package that needs it)" --
  advice to the consumer about a declaration the package already has. The
  closure check should skip a need whose declared provider failed its own
  verification (pm/native.tcl's `Plan`).

**Language and compiler (not this milestone's):**

* Retained C callbacks (custom painting, virtual lists, drop acceptance,
  consuming raw input, worker tasks) -- RAVEN-BINDINGS.md 7.1,
  C-CALLBACK-MILESTONE-1.md.
* A local named like a function used with method syntax makes the call
  AMBIGUOUS-METHOD-CALL even when the local is no function
  (`add = raven::button("Add")` then `panel.add(x)`): calling a
  non-callable value is not rejected statically (only `NOT-CALLABLE` at
  run time), so the method decision keeps the local as an applicable
  candidate. Met while writing the example; a compiler diagnostic gap.
* No list concatenation; `int` to C `Int` needs a range proof at every
  call; one-character strings are characters -- frictions the guide's
  pitfalls list.

* Found by the experiment and left: the method-call diagnostic that names
  a visible function's failure but not the unimported module whose
  function would apply (`length`, `std::list`); no process exit status; no
  `int` field in a natively lowered context struct; 8-10 s of front-end
  work per run unless the opt-in cache is used.
* Not wrapped (RAVEN-BINDINGS.md, section 9): lists, trees, menus, the text
  editor, dialogs; a widget's children (the agent used the binding's
  `Rwidget_get_child`).

## J. Developer-experience conclusion

**Can a clean-room agent build a real Raven GUI application using only
the single-file compiler and a prebuilt package?** Yes. An independent
agent with only those two files, the compiler's built-in reference and the
installed package's documentation built a complete task manager -- a real
X11 window drawn by Vulkan, two control types and dynamic widgets, state,
change, reset, clean shutdown, a 27-check deterministic test, real input
under a virtual display and a deployed executable -- in 23 minutes,
without guessing an API, writing C or running a package-specific command.
Two qualifications: the agent had the repository's contributor rules
(language rules, no Raven API) in its context by the harness's doing, so
learning the language may be harder for a real newcomer; and it used the
release candidate 0.3.0, whose three gaps it found are fixed in 0.3.1.

**Can a package author produce that artifact in one documented workflow?**
Yes: `tclsh9.0 tools/package-repository.tcl OUT raven` builds Raven's
desktop configuration for both Linux targets, checks it, packs the
release with its native metadata verified, prints its identity,
reproduces its bytes from cached builds in under 2 s, and refuses to
replace a release under its version. It is still this repository's
recipe, with its own pins, not a generic authoring command (PM-3).

**What remains unnecessarily difficult?** Checking a real window from
outside (every developer writes an X client, as the agent did and as this
milestone's harness does); waiting 8-10 s per run when a cache would take
1.7 s; a wrapper whose coverage is only what earlier programs needed;
diagnostics that leave out the import that would fix a method call; tests
that must report their verdict as a value.

**PM-3 versus language and compiler.** PM-3's: a generic native authoring
workflow instead of the recipe; a metadata class for optional, run-time
loaded dependencies (the Vulkan loader); provenance of bundled builds; and
(a PM-2 fix that need not wait) the closure check's cascade after a failed
system library. The language's and compiler's, unrelated to packaging:
retained C callbacks, a process exit status, the method-call import hint,
a static NOT-CALLABLE check, `int` fields in native contexts, and the
front end's cost per run.

### Follow-ups, ranked by what the experiment showed

1. **Front-end cost per run**: make the front-end cache the default for
   package modules, or at least tell package consumers about
   `BOTLISH_HIR_CACHE` (8-10 s to 1.7 s, measured on the package's
   example).
2. **The import hint in method-call diagnostics**: when the decided
   candidate fails and an unimported module has a function the call would
   apply to, say so (`length` and `std::list`).
3. **A static NOT-CALLABLE check**: a non-callable local named like a
   function stops being an applicable method candidate (the `add` local
   this milestone's example met).
4. **Wrapper coverage driven by applications**: a public C-string copy (so
   no application writes `readback.bot` again: RAVEN-BINDINGS.md 7.3),
   a widget's children, then lists and menus.
5. **An exit status for programs** (tests in shells).
6. **Run the AArch64 release** on an arm64 host (CI's arm64 workflow).
   And **pin the author's toolchain** (the recipe in a fixed container
   image), so any machine reproduces a release's bytes.
7. **PM**: the cascade after a failed system library; an optional
   run-time dependency class (PM-3).
8. **Repeat the experiment without injected repository instructions**
   (an agent whose harness does not load the repository's AGENTS.md: a
   session without the repository), to measure learning the language from
   the compiler's reference alone.

## What to run when changing this

* `packages/raven` (module, guides, example, metadata): `tests/raven.test`
  and the `pw-raven-*` tests of `tests/package-workloads.test`; a change
  of the release's contents is a new version.
* `tests/cffi/raven.tcl`, the raven recipe of
  `tools/package-repository.tcl`: the same, and
  `tests/c-bindgen.test -match 'cb-raven-*'`.
* `audit/raven-cleanroom/` or anything above: `audit/raven-cleanroom/tools/
  mutate.tcl` (every mutant must still apply and be killed: update a
  mutant's text when you change the code it mutates, keeping it a mutant
  of the same rule), and the clean room (`tools/cleanroom.sh image`, then
  `run` with a single executable from `single/build.sh` and the release
  from `tools/package-repository.tcl`; the `raven clean room` workflow).

## Files

| path | |
|---|---|
| `packages/raven/botlish.json` | 0.3.1: the desktop libraven's needs and symbols, system X11, per target |
| `packages/raven/raven.bot` | `start`'s startup report (`startup_reasons`, `error_texts`); `checkbox_text` |
| `packages/raven/README.md`, `GUIDE.md`, `examples/clicks/` | the consumer's documentation and example, in the artifact |
| `tests/cffi/raven.tcl` | named, stamped build configurations; the pinned Vulkan headers |
| `tools/package-repository.tcl` | the raven recipe (desktop builds, the arm64 libX11 pins, `checkDesktop`), no forced overwrite, the identity printed |
| `tools/raven-package.tcl` | installs the same common files (development use) |
| `tests/raven.test`, `tests/raven/start-desktop.bot`, `tests/raven/texts.bot` | 8 new tests |
| `tests/package-workloads.test` | 5 new tests |
| `audit/raven-cleanroom/Dockerfile`, `tools/cleanroom.sh` | the clean room |
| `audit/raven-cleanroom/acceptance/` | `inside.sh`, `window.bot`, `desktop-session.sh` |
| `audit/raven-cleanroom/tools/xsession.py` | the X client (ctypes over libX11 and libXtst) |
| `audit/raven-cleanroom/tools/mutate.tcl`, `mutants.txt` | the mutation harness |
| `audit/raven-cleanroom/tools/build-app.sh`, `acceptance/build-inside.sh` | a Raven application built, smoke-run and packed in the clean room |
| `.github/workflows/tasks-app.yml` | manual: the agent's Tasks app built by `build-app.sh`, the artifact `tasks-linux-x86_64` |
| `audit/raven-cleanroom/results/` | the clean room's transcript and the agent experiment's trace, source and notes |
| `.github/workflows/raven-cleanroom.yml`, `c-bindgen.yml` | CI |

# audit/raven-cleanroom -- the raven release in a clean room

RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md's environment and evidence: the
desktop-capable `raven` release consumed with nothing but the single-file
compiler and the `.botpkg`.

| path | |
|---|---|
| `Dockerfile` | the image: Ubuntu 24.04 and operating-system facilities only (a C compiler driver, libX11, the Vulkan loader, Mesa's software Vulkan driver, Xvfb; python3 and libXtst for the harness) |
| `tools/cleanroom.sh` | `image` builds it; `run COMPILER BOTPKG OUT` runs the acceptance in a fresh container with no network and nothing mounted; `start COMPILER BOTPKG NAME` leaves one running with only the two inputs (the agent experiment's) |
| `acceptance/inside.sh` | the acceptance, run inside as the user `dev`: the environment checked, installation, the documented programs, failures without a display or a driver, real windows, deployment and relocation; a transcript and a check list |
| `acceptance/window.bot` | the test's own application: a label, a checkbox and two buttons, reporting its state on standard output |
| `acceptance/desktop-session.sh` | runs a program on a real X11 window under Xvfb and drives it only through the X server |
| `tools/xsession.py` | the X client: finds a window, reads its pixels, clicks through XTest, asks it to close (python3 ctypes over libX11 and libXtst) |
| `tools/build-app.sh`, `acceptance/build-inside.sh` | build a Raven application as a consumer does, in a fresh clean-room container: install the release, run its headless test, deploy, emit the executable, open and close its window on a virtual display, pack a tarball (the `tasks app (raven, manual)` workflow builds the agent's Tasks app with it) |
| `tools/mutate.tcl`, `tools/mutants.txt` | the milestone's mutation harness |
| `results/acceptance/` | the clean room's transcript, checks and window sessions for the release the report records |
| `results/agent-experiment/` | the independent agent's application, notes, report and command trace |

```sh
single/build.sh                                         # single/out/botlish
tclsh9.0 tools/package-repository.tcl repo raven        # repo/raven-0.4.0.botpkg
audit/raven-cleanroom/tools/cleanroom.sh image
audit/raven-cleanroom/tools/cleanroom.sh run single/out/botlish repo/raven-0.4.0.botpkg out
```

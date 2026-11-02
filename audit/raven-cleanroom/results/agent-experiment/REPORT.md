# The independent agent's final report

Verbatim: the agent's final answer (RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md,
section F, which checks its claims).

---

## Report: "Tasks" desktop app in Botlish + Raven

All requirements are met, with evidence below. I used only the `cr` wrapper. One disclosure about my context is in (g).

### (a) What I built (in /home/dev/app)
- `tasks_app.bot` is the application. Its state is an immutable `List[Task {text, done, box}]`. It builds the window, handles events and runs the frame loop.
  - **Add** (button, or Enter in the input) adds the input's text as a new checkbox and clears the input. Empty text adds nothing.
  - **Toggled** events set `done`.
  - **Clear done** destroys the checkboxes of done tasks and drops those tasks.
  - **Status label** reads exactly "N tasks, M done", so one task shows as "1 tasks".
- `main.bot` is the desktop program. When the window closes it prints the final status, e.g. "closed with 1 tasks, 0 done".
- Tests: `tasks_check.bot` is the shared scenario, `test.bot` runs it headless, `test_desktop.bot` runs it on a real X11/Vulkan window. `readback.bot` reads checkbox labels back from Raven.
- Desktop tooling: `layout_probe.bot` finds widget positions, and `xdrive.py` (Python stdlib only) is a small X11 client that clicks, types, takes screenshots and closes the window.
- Scripts: `run-test.sh` and `run-desktop-test.sh`. `README.md` says how to run everything.
- Outputs: `NOTES.md` (the development log), `evidence/` (PNGs, text renderings of them, logs) and `dist/tasks`, a standalone executable with `dist/lib/libraven.so.0`.

Requirement by requirement:
- **Window titled "Tasks":** xdrive.py found `0x0040000d mapped 0,0 420x360 'Tasks'`.
- **Add, empty add, checkboxes, status, Clear done:** all covered by the 27 headless checks, all PASS.
- **Clean close:** after the WM_DELETE_WINDOW message, main.bot exited by itself with status 0 and printed `value: "closed with 1 tasks, 0 done"`.
- **Standalone executable:** `dist/tasks` also opened the window and exited 0 when closed.
- **Without a display:** main.bot reports "Raven did not start: X11: cannot open the display ..." and exits 0 instead of crashing.

### (b) Testing
**Headless:** `./run-test.sh` runs `botlish -backend cranelift test.bot` and gives exit 0, printing `27 passed, 0 failed` and `value: "TEST PASS: 27 checks"`.
- The steps are: start, Add with empty text, typing, Add, Add plus Enter, check, check another, uncheck, Clear done, Clear done with nothing done, empty Add again, check all and clear, add after clearing.
- After each step it compares two things with what is expected:
  - the app's state;
  - what the window shows, read from Raven itself: the status label, the input text, the list panel's rows, and each row's checkbox text and checked state.
- I checked the test can fail: in a copy with the empty-text guard and `destroy()` removed, 25 of 27 checks failed and the script exited 1.

**Graphical:** `./run-desktop-test.sh` starts Xvfb (Mesa's software Vulkan driver) and exits 0 with "DESKTOP TEST PASS".
1. `test_desktop.bot` runs the same scenario on the real window: 31/31 PASS. The extra four checks read the rendered frames: 420x360 RGBA, and adding and clearing tasks changed the pixels.
2. It then starts `main.bot` and drives it from outside with real X11 input (XTEST): type "Buy milk", Add, an empty Add, "Write report" plus Enter, check "Buy milk", Clear done, close. The final value is exactly what those inputs lead to.
- Screenshots are in `evidence/*.png`. Text renderings in `evidence/*.zoom.txt` show the checked box, the task names, "2 tasks, 1 done" and later "1 tasks, 0 done".

### (c) Obstacles
| Obstacle | Classification |
|---|---|
| The raven module has `label_text` and `input_text` but no way to read a checkbox's text, and its C-string reader is private. `label_text` on a checkbox returns "" plus a Raven error event. I worked around it in `readback.bot` by reading `Rcheckbox_get_text` byte by byte through a native view behind its own context. | Raven wrapper limitation |
| A program cannot set its exit status or let an error reach the top level, so the test's verdict is its printed value and the shell scripts turn it into an exit status. This is documented. | Botlish language limitation |
| `xs.length()` on a List with only `std::str` imported gives a TYPE error naming `std::str::length`, with no hint to `import std::list`. | Compiler diagnostic (discoverability) |
| A context struct with an `int` field is refused by the native backend (CONTEXT-NATIVE-LOWERING-UNSUPPORTED). It was surprising but clearly explained; I used a `bool` field. | Native backend limitation |
| Minor and clearly diagnosed: no forward references, `substring` needs a bounds proof, `Usize` is not `int` (use `.value`), `UChar` is not `Byte` (use `std::byte::from_int`), a resource-escape warning, a one-character-string warning, a method-syntax warning. | Language rules; diagnostics were good |
| No X client tools exist in the environment (xdotool, xwd, xwininfo, ImageMagick, PIL), so I wrote `xdrive.py`. There is no window manager, so I close the window with the same message a window manager's close button sends. | Native environment prerequisite |
| Every run spends about 8–10 s compiling. | Tooling cost |
| Own mistakes: shell-quoting slips that appended a section of NOTES.md twice (then fixed); an Xvfb started without `< /dev/null` that did not survive; a `pkill -f` that killed its own shell. | My own mistakes |

### (d) Documentation
**Consulted:**
- The compiler: `botlish` usage, `-help` index, `-help primer`, `add -help`, `-help cli.packages` / `package`, `package inspect`.
- The package: its README.md, GUIDE.md, raven.bot, `examples/clicks/*`, and the generated binding files (`controls.bot`, `widget.bot`, `accessibility.bot`).
- `-help` topics: loops, contexts, print, `std::str`, `std::list`, `std::ffi::c`, native views and `element`, DIRECT, `std::byte`, `std::abi::Usize`, `std::abi::bytes`, `std::float64`, exit status, files.

The GUIDE (especially its Testing and Pitfalls sections) was excellent. **Missing:**
- A checkbox-text reader in the raven module.
- Any guidance on checking a desktop window from outside.
- Any explicit note that a widget added after a frame needs another frame before `click` can aim at it (I inferred this).

### (e) Guessed APIs
No raven name or signature was guessed: everything came from the GUIDE, raven.bot or the binding. A few small inferences were confirmed by the compiler: building `raven::Widget {id: 0}` from outside the module, that `Bytes.length()` exists and returns a `Usize`, and using `Rwidget_get_child` to read the panel's rows.

### (f) Installation
It was straightforward. `botlish add ~/inputs/raven-0.3.0.botpkg` worked first time with no flags; `verify`, `native plan`, `native deploy` and a fresh `install` from `botlish.json` all worked. The only manual setup was starting Xvfb and setting DISPLAY. I did not write any C.

### (g) Outside the environment
I ran no host command other than the wrapper, read no host file and used no web access. However, at the start of the session the harness automatically put a host project-instructions file (an AGENTS.md from a Botlish repository checkout) into my context, without my asking. I deliberately worked only from what the environment taught me, but I cannot entirely rule out that its general content influenced me.

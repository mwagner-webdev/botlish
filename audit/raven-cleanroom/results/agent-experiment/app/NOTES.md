# Tasks app -- development log

All work done inside the isolated environment through the `cr` wrapper.

## 1. First contact

- `ls ~/inputs`: `botlish` (14 MB single-file compiler) and `raven-0.3.0.botpkg`.
- `~/inputs/botlish` (no args): usage text. Lists -backend (interp, compile,
  cranelift, cranelift-generic), -emit-native-executable, -check, -help,
  and package commands `add|install|update|remove|verify|package`.
- `~/inputs/botlish -help`: Compilerpedia index (1149 topics). Has a
  "BEFORE YOU WRITE A PROGRAM" table of Python habits that differ.
- `~/inputs/botlish -help primer`: immutable bindings, no assignment,
  `if` is a value only on the right of `=`, loops collect lists, `fold`,
  method sugar `x.f(y)`, `nomethod fn`, `'x'` is a character.

## 2. Installing Raven

- `botlish add -help` and `botlish -help cli.packages`,
  `botlish -help package` (rule.package-modules): packages live in
  `.bot_modules/NAME`; target views in `.bot_modules/.targets/TARGET`.
- `botlish package inspect ~/inputs/raven-0.3.0.botpkg`: 56 files, targets
  linux-x86_64 and linux-aarch64, bundled libraven.so.0 and the static
  `libraven_bridge.a`, system libX11.
- `cd ~/app && botlish add ~/inputs/raven-0.3.0.botpkg` -- worked first
  time: wrote `botlish.json` (dependency "0.3", lock 0.3.0, source archive
  with sha256) and `.bot_modules/` (store + linux-x86_64 view). No manual
  setup, no -L, no LD_LIBRARY_PATH.

## 3. Learning the package

Read, in this order:
- `.bot_modules/raven/README.md` (requirements, a first window, headless
  testing, Xvfb, shipping, "When it does not start").
- `.bot_modules/raven/GUIDE.md` (API by task; section 9 Testing, section 12
  Pitfalls -- e.g. do not name a local `add` when calling `panel.add`).
- `.bot_modules/raven/raven.bot` (every public function, with comments).
- `.bot_modules/raven/examples/clicks/{clicks,main,test}.bot`.
- grep in `.bot_modules/.targets/linux-x86_64/raven/raven/controls.bot`
  (the generated C binding) for checkbox functions.

Sanity check: copied the clicks example into ~/try (own `botlish add`),
`botlish -backend cranelift test.bot` -> `["2", "2 clicks", "0", "0 clicks"]`
(about 9 s, mostly compilation). `DISPLAY=:99 botlish -backend cranelift
main.bot` under `Xvfb :99` stayed open until `timeout 30` killed it, so the
desktop configuration (Vulkan through Mesa's software driver) starts.

## 4. Writing the application

Files: `tasks_app.bot` (the application module: state, window, event
handling, frame loop), `main.bot` (desktop entry), `test.bot` (headless
test). Design: the state is an immutable `List[Task]`, `Task {text, done,
box}` where `box` is the task's checkbox; the frame loop folds every event
of a frame into the next state (`handle`), then sets the status label.
Add (button, or Enter = TextCommitted in the input) reads the input,
ignores "", makes `raven::checkbox(text)`, adds it to a vbox, clears the
input. Toggled events set `done` from `event.value == 1`. Clear done
destroys the done tasks' checkboxes (`widget.destroy()` removes them from
the panel: checked by experiment, child_count 2 -> 1) and drops them.

- `tasks_app.bot` + `main.bot` passed `botlish -check` on the first try.
- The status format is exactly "N tasks, M done" as specified (so "1 tasks").

Diagnostics that cost time:
- In an experiment, `evs.length()` on a `List` with only `std::str`
  imported: "argument 1 of native std::str::length requires str, but the
  receiver has type List[raven::Event] ... (CORE SEMANTIC TYPE)". Meaning:
  method sugar resolved `length` to the only visible `length`
  (std::str's); fix: `import std::list`. The message does not suggest the
  missing import.
- test.bot: "unbound name "joined": "joined" is declared later; forward
  references are not allowed" -- functions must be declared before use
  (callees first). Clear message; reordered.
- `line.substring(0, 4)` -> UNHANDLED-ERROR UpperOverrun (help:
  proof.slices). Replaced string-prefix matching by an `Outcome {pass,
  line}` struct.
- `main()` at top level raising my own error `TestsFailed` ->
  UNHANDLED-ERROR: a top-level call has no errors clause.
  `botlish -help "exit status"` (capability.process-exit-status): a
  program cannot choose its exit status at all. So the test's verdict is
  its value ("TEST PASS: ..."/"TEST FAIL: ..."), and `run-test.sh` turns
  it into an exit status.

Experiment (~/try/exp1.bot): `raven::label_text(checkbox)` returns "" and
Raven queues an Error event "Rlabel_get_text: expected a Label, got a
Checkbox". The `raven` module has `label_text` and `input_text` but no
accessor for a checkbox's text; the binding's `Rcheckbox_get_text`
returns a `Ptr[Char]`, and the module's C-string reader (`text_of`) is
private. (See section 5.)

First headless run of test.bot: 27 checks, all PASS (13 s, mostly
compilation).

Mutation check of the test (in a copy, /tmp/mut): removing the empty-text
guard in `add_task` and the `destroy()` in `clear_done` made 25 of 27
checks FAIL, with clear expected/observed lines, and `run-test.sh` exit 1.
So the test can fail.

## 5. Reading the checkboxes' text back from Raven (readback.bot)

To make the test compare *visible* text, not only my own state, I read
each checkbox's label from Raven: the binding's
`raven::controls::Rcheckbox_get_text(id) -> Ptr[Char]`, decoded with the
standard library. Learned from `botlish -help std::ffi::c`, `-help
std::binary::native::view`, `-help std::binary::element`, `-help DIRECT`,
`-help concept.contexts`, `-help std::byte`, `-help std::abi::Usize`.
The bytes are read one at a time through a native view of a 4096-byte
`array ... of std::ffi::c::UChar` layout, stopping at the NUL (no byte
past it is read). Making a view is direct authority, so the module
declares its own context struct `Readback` and the entry programs install
it (`with context readback::create()`), as raven.bot does with `Ui`.

Diagnostics on the way (each with a `help:` topic; all understandable):
- `function result does not prove declared type List[int[std::byte::Byte]]`
  (TYPE): a `UChar` is not a `Byte` without a proof; fixed with
  `std::byte::from_int(b)` (statically in range, so no handler needed).
- warning CONTEXT-RESOURCE-ESCAPE: my first version took the raw
  `Ptr[Char]` as a parameter from the entry program. The message says
  exactly what to do ("give module ... an operation that takes and returns
  values"): now `readback::checkbox_text(box: raven::Widget) -> str`.
- error CONTEXT-NATIVE-LOWERING-UNSUPPORTED: a context struct field of type
  `int` cannot be stored in a native context slot (it could be a big
  integer). Surprising, but the message explains it; changed the field to
  `ready: bool`. (Botlish/native backend limitation.)
- `std::int::to_string(bytes.length())` -> TYPE: `Bytes.length()` is a
  `std::abi::Usize` (a struct), not an int; use `.value`.
- warning ONE-CHAR-STRING-LITERAL for `.concat("x")` -> `.append_char('x')`.
- warning METHOD-ELIGIBLE for `raven::widget::Rwidget_get_child(panel.id, i)`
  -> `panel.id.Rwidget_get_child(i)`.

The test's "window" description is now read entirely from Raven: status
label text, input text, the list panel's child count, and, for each child
of the panel (`Rwidget_get_child`), its checkbox text and checked state.

## 6. Running as a real desktop window (Xvfb)

- No monitor/GPU: `Xvfb :99 -screen 0 1024x768x24` + Mesa's software
  Vulkan driver (lavapipe, `/usr/share/vulkan/icd.d/lvp_icd.json`).
  Raven's `desktop()` started without any extra configuration.
- Environment quirk (mine): the first Xvfb, started as
  `(setsid nohup Xvfb ... &)` without `< /dev/null`, did not survive the
  wrapper command; `setsid nohup Xvfb ... < /dev/null &` did. The first
  desktop test run therefore reported (correctly, via
  `raven::RavenFailed`): "X11: cannot open the display (is DISPLAY set?);
  Rinit: cannot initialize the X11 window system".
- I refactored the test into a module `tasks_check.bot` with
  `verdict(options)`, and two entries: `test.bot` (headless) and
  `test_desktop.bot` (desktop). On the desktop it also checks
  `window.capture()`: the frame is 420x360 RGBA (604800 bytes), and adding
  and clearing tasks changed the pixels. 31/31 PASS under Xvfb.
- Outside evidence: the environment has no X client tools at all (no
  xdotool, xwd, xwininfo, xprop, ImageMagick, PIL), so I wrote
  `xdrive.py`, a minimal X11 protocol client in Python's standard library:
  lists top-level windows with their titles (QueryTree, _NET_WM_NAME /
  WM_NAME), screenshots (GetImage -> PNG via zlib), real input through the
  XTEST extension (FakeInput: motion, button, key events with the
  server's keymap), and closing via the WM_DELETE_WINDOW client message a
  window manager's close button sends. It also renders a screenshot as
  text (`zoom`), since I cannot look at a PNG here.
- To know where to click, `layout_probe.bot` builds the same window on the
  desktop and prints each widget's centre (`widget.rect()`), with 0, 1 and
  2 tasks.
- `run-desktop-test.sh`: starts Xvfb :97, runs test_desktop.bot, then
  starts main.bot, waits for the mapped window titled "Tasks" (it is a
  real top-level X11 window, 420x360), types "Buy milk" + clicks Add,
  clicks Add with an empty input, types "Write report" + Enter, checks
  "Buy milk", clicks Clear done, screenshots each state, sends
  WM_DELETE_WINDOW. main.bot then ends by itself with exit status 0 and
  prints `value: "closed with 1 tasks, 0 done"` -- exactly the state those
  real inputs lead to. The text renderings of the screenshots
  (evidence/*.zoom.txt) show the checked box beside "Buy milk", "Write
  report", "2 tasks, 1 done" and, after Clear done, "Write report" and
  "1 tasks, 0 done".

## 7. A standalone executable

From README.md's "Shipping an executable":
`botlish native deploy -target linux-x86_64 -out dist` (copied
libraven.so.0 to dist/lib) and
`botlish -emit-native-executable -runtime-path '$ORIGIN/lib' main.bot`
(10 s), `mv main dist/tasks`. Under Xvfb, `dist/tasks` opened the window;
driven with xdrive.py (typed "Ship it", Enter, close) it printed
`"closed with 1 tasks, 0 done"` and exited 0.

## 8. Guesses, manual setup, what I could not do

- API names/signatures: I did not have to guess any raven function: all
  came from GUIDE.md, raven.bot and the generated binding files. Small
  inferences that the compiler confirmed: constructing `raven::Widget {id:
  0}` from outside the module (its struct is not opaque); that
  `Bytes.length()` exists (it returns a Usize); `Rwidget_get_child` /
  `Rwidget_get_child_count` from the binding for the panel's rows.
- Manual setup: none for the package (`botlish add` did everything). For
  the desktop: starting Xvfb myself and setting DISPLAY.
- Could not: set the program's exit status (no such facility: the test
  verdict is the program's value and the shell scripts read it); read a
  checkbox's text through the raven module (worked around, section 5);
  look at the screenshots with my eyes (text renderings instead); test
  with a real window manager (none installed; I send the same
  WM_DELETE_WINDOW message one sends).
- Timing: every `botlish -backend cranelift` run spends ~8-10 s compiling
  (the headless test takes ~13 s in total; the desktop script ~47 s).

Failure paths checked: with no DISPLAY, main.bot prints `"Raven did not
start: X11: cannot open the display (is DISPLAY set?); Rinit: cannot
initialize the X11 window system"` (handled, exit 0). With the default
`interp` backend it is rejected at run time with NATIVE-ONLY, as the
README says ("run with -backend cranelift").

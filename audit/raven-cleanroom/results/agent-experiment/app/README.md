# Tasks -- a small task manager in Botlish over Raven

A desktop window titled "Tasks": a text input and an "Add" button (Enter in
the input adds too), one checkbox per task, a status label "N tasks, M
done", and a "Clear done" button. Closing the window ends the program.

## Files

| file | what it is |
|---|---|
| `tasks_app.bot` | the application: state (`List[Task]`), the window, event handling, the frame loop |
| `main.bot` | the desktop program (prints "closed with N tasks, M done" when the window closes) |
| `tasks_check.bot` | the scripted test, shared by the two test entries below |
| `readback.bot` | reads a checkbox's text back from Raven (the raven module has no reader for it) |
| `test.bot` | the test, headless (no display): `./run-test.sh` |
| `test_desktop.bot` | the same test on a real X11 window (Vulkan renderer) |
| `layout_probe.bot` | prints where the desktop window puts its widgets, for xdrive.py |
| `xdrive.py` | a Python-stdlib X11 client: finds the window by title, clicks and types with XTEST, screenshots, closes |
| `run-test.sh` | runs test.bot; exit status 0 only for "TEST PASS" |
| `run-desktop-test.sh` | starts Xvfb, runs test_desktop.bot, then runs main.bot and drives it from outside |
| `evidence/` | screenshots (PNG) and main.bot's output from the last desktop run |
| `dist/` | a standalone executable `dist/tasks` with `dist/lib/libraven.so.0` |
| `NOTES.md` | the development log |

Packages: `botlish.json` and `.bot_modules/` were made by
`~/inputs/botlish add ~/inputs/raven-0.3.0.botpkg` (run `~/inputs/botlish
install` to recreate `.bot_modules` from botlish.json).

## Running

```sh
cd ~/app
# the application, on a display (here a virtual one)
Xvfb :99 -screen 0 1024x768x24 &
DISPLAY=:99 ~/inputs/botlish -backend cranelift main.bot

# the headless test (no display needed)
./run-test.sh                 # or: ~/inputs/botlish -backend cranelift test.bot

# the desktop tests (starts its own Xvfb on :97)
./run-desktop-test.sh

# the standalone executable (rebuild: see NOTES.md, section 7)
DISPLAY=:99 dist/tasks
```

Only the native backends can run it (`-backend cranelift` or
`cranelift-generic`): Raven is C, and `interp`/`compile` refuse C calls.

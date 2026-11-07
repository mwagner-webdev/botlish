# raven -- graphical user interfaces for Botlish programs

`raven` 0.4.0 is a Botlish package for [Raven](https://github.com/oscar-soirey/Raven)
0.1.3, a C11 GUI library: real desktop windows (X11, drawn by Raven's
Vulkan renderer) with labels, buttons, checkboxes, sliders, spin boxes,
text inputs and combo boxes, and a headless mode -- no display, nothing
drawn, synthetic input -- for deterministic tests. One prebuilt artifact
holds everything: the Botlish module `raven`, the generated binding of
Raven's whole C API (`raven::core`, `raven::window`, ...), a small C event
bridge and Raven itself. Nothing is built or run when you install it.

| file in the installed package | what it is |
|---|---|
| `README.md` | this page: requirements, installation, a first window, running, shipping |
| `GUIDE.md` | the API by task: lifetime, windows, controls, the frame loop, events, keyboard and mouse, errors, testing, files |
| `raven.bot` | the module `raven`; every public function has a comment saying what it does |
| `examples/clicks/` | a complete small application: `clicks.bot` (the program), `main.bot` (desktop), `test.bot` (headless test) |
| `raven/*.bot` | the generated binding, all 921 C functions, for what `raven` leaves out |
| `native/raven_bridge.c` | the event bridge's source (its archive is prebuilt) |

After `botlish add`, these are under `.bot_modules/raven/` of your project
(for the compiler, under `.bot_modules/.targets/linux-x86_64/raven/`).

## Requirements

Targets: **linux-x86_64** (built, tested and run by the package's
author) and **linux-aarch64** (built and inspected; not run by the
author). The package refuses macOS and Windows: no build exists.

On the machine that compiles and runs the program (Ubuntu 24.04 package
names):

| what | needed for | package |
|---|---|---|
| the Botlish compiler, a native backend | every program: run with `-backend cranelift` (the default `interp` backend and `compile` cannot call C) | -- |
| a C compiler driver `cc` and the C library's development files | the native backend links a program that calls C with the system's linker | `gcc`, `libc6-dev` |
| `libX11.so.6` | every program: libraven loads it. `botlish add` checks it | `libx11-6` |
| GNU C library 2.38 or newer | libraven was built against it | (Ubuntu 24.04 has 2.39) |
| an X11 display (`DISPLAY`) | `raven::desktop()` only | a desktop session, or `xvfb` (a virtual one) |
| the Vulkan loader `libvulkan.so.1` and a Vulkan driver | `raven::desktop()` only: Raven loads them when it starts | `libvulkan1`, and a GPU's driver or Mesa's software one, `mesa-vulkan-drivers` |

```sh
sudo apt-get install gcc libc6-dev libx11-6 libvulkan1 mesa-vulkan-drivers   # and xvfb for a virtual display
```

The display, the loader and the driver are not checked at installation
(a headless program needs none of them); when one is missing,
`raven::start(raven::desktop())` fails with `raven::RavenFailed`, whose
`detail` names it (section "When it does not start"). The package's
metadata says the same: libX11 is a system library its libraven loads
(checked by `botlish add`), and the Vulkan loader, a Vulkan driver, the X11
display, `libX11-xcb.so.1` (only for a driver that presents through XCB)
and `libdbus-1.so.3` (only for accessibility) are run-time dependencies,
which `botlish native plan` lists apart from the link with what this
machine has -- never a reason the installation fails.

## Installing

In your project's directory (or with `-project DIR`):

```sh
botlish add /path/to/raven-0.4.0.botpkg
```

This writes `botlish.json` and `.bot_modules/`, checks every native file
the artifact holds and that the system's libX11 is installed, and runs
nothing from the package. No `-L`, no `LD_LIBRARY_PATH`: the compiler finds
Raven in the installed package. `botlish native plan` shows what will be
linked and loaded; `botlish verify` checks the installation again.

## A first window

`main.bot`, beside `.bot_modules`:

```botlish
import raven

with context raven::create()

# The frame loop: sleep until something happens, then handle what did;
# false once the window is closed.
fn run(quit: raven::Widget):
    if not raven::wait_frame(-1.0):
        return unit
    ended = fold event in raven::events() with intermediate done false:
        done or (event.kind == raven::EventKind::Clicked and event.from?(quit))
    if ended:
        raven::quit(0)
    run(quit)

fn main(context ui: raven::Ui) -> str errors raven::RavenFailed:
    raven::start(raven::desktop())
    window = raven::window("Hello", 320, 120)
    quit = raven::button("Quit")
    window.set_content(raven::vbox().add(raven::label("Hello from Botlish")).add(quit))
    run(quit)
    raven::stop()
    "bye"

result = main():
    on raven::RavenFailed failure:
        failure.detail
result
```

```sh
botlish -backend cranelift main.bot
```

The window stays until it is closed or Quit is clicked; the program's
value is printed after it. `examples/clicks/` is a fuller application: copy
its three files beside `.bot_modules` and run `main.bot`, or `test.bot` to
test it with no display.

## Testing without a display

`raven::start(raven::headless())` uses Raven's null platform and renderer:
no window system, no GPU, no driver, the same widgets, layout and events.
Input is synthetic (`window.click(widget)`, `inject_text`, `inject_key`,
`inject_move`, `inject_button`, `inject_wheel`), each delivered by the
next `raven::draw_frame()`. See GUIDE.md, "Testing",
and `examples/clicks/test.bot`.

To drive the real desktop configuration without a monitor, run the
program under a virtual display:

```sh
Xvfb :99 -screen 0 1024x768x24 & DISPLAY=:99 botlish -backend cranelift main.bot
```

## Shipping an executable

```sh
botlish native deploy -target linux-x86_64 -out dist      # dist/lib/libraven.so.0
botlish -emit-native-executable -runtime-path '$ORIGIN/lib' main.bot
mv main dist/
dist/main                                                  # wherever dist is moved
```

The executable finds `libraven.so.0` in `lib/` beside itself (its ELF
RUNPATH is `$ORIGIN/lib`); the event bridge is linked into it. The target
system still needs libX11, the C library and, for the desktop, a display,
the Vulkan loader and a driver. Note the loader's order: an
`LD_LIBRARY_PATH` set when the program runs is searched before RUNPATH, so
a different `libraven.so.0` there would be loaded instead.

## When it does not start

`raven::RavenFailed {call, code, detail}`: `detail` lists what Raven
reported while it started, cause first.

| detail begins with | cause | what to do |
|---|---|---|
| `X11: cannot open the display (is DISPLAY set?)` | no X11 display | run in a desktop session, set `DISPLAY`, start `Xvfb`, or use `raven::headless()` |
| `Vulkan: the Vulkan library (libvulkan.so.1) was not found` | no Vulkan loader | install `libvulkan1` |
| `Vulkan: the driver cannot present to a window`, `Vulkan: no graphics device found` | the loader found no usable driver | install a Vulkan driver (`mesa-vulkan-drivers` gives a software one); check `VK_ICD_FILENAMES` |
| `native/libraven_bridge.a is not the event bridge` | a mismatched installation | reinstall the package |

A program whose libraven cannot be loaded at all (no libX11) does not
start: the system's loader reports the missing library.

## Licenses

Raven is the Apache License 2.0's, and its library includes third-party
components under their own terms (stb: MIT or the Unlicense; the Roboto
font: Apache 2.0; Roboto Mono: the SIL Open Font License 1.1). The package
states it (`botlish package inspect`: `license Apache-2.0 AND OFL-1.1 AND
(MIT OR Unlicense)`) and carries the texts their terms require to travel
with the library, under `licenses/raven/` of the installed package: Raven's
LICENSE and NOTICE, THIRD_PARTY.md and each component's license. An
application that ships `libraven.so.0` (`botlish native deploy`) ships
those notices with it.

## What it does not do

* **No Botlish callbacks inside Raven.** Raven reports what happens by
  calling C; the package's bridge records it and your program reads the
  records after each frame (`raven::events()`). So a program cannot paint
  its own widgets, feed a virtual list, decide whether to accept a drop or
  to consume raw input, or run Raven's worker tasks.
* **Wrapped**: windows, vertical and horizontal panels, labels, buttons,
  checkboxes, sliders, spin boxes, one-line text inputs, combo boxes,
  themes, actions, timers, XML interfaces, a window's keyboard, mouse and
  wheel (events and the current state: GUIDE.md, "Keyboard, mouse and
  wheel"), synthetic input. **Not wrapped**: menus, list and tree views,
  the text editor, docking, dialogs (the file dialog too: it runs a modal
  loop of its own, and a program reads a file name from a text input
  instead), the color picker, timeline and node graph, styles, fonts,
  textures, translations, accessibility. Files are the standard library's
  (`std::linux::fs`: GUIDE.md, "Saving and loading files"). The generated binding reaches all of Raven's
  C API (`raven::controls::Rlabel_set_markdown(label.id, 1)`: a handle's
  `id` is the C handle); functions taking callbacks or pointers you cannot
  supply stay out of reach.
* **One thread.** Raven runs on the thread that started it; so does the
  program.
* **No macOS or Windows build.**

## For package authors

The artifact is made from the Botlish repository with one command,
`tclsh9.0 tools/package-repository.tcl OUT raven`, which builds Raven's
desktop configuration for both targets, the bridge, and packs the release.
Consumers never run it.

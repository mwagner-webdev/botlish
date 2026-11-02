# The raven package: a guide by task

What a program over `raven` looks like, and what each part of the module
does. README.md has the requirements, installation and shipping;
`raven.bot` has every function with its comment; `examples/clicks/` is a
complete application with its test. Botlish itself: `botlish -help primer`
(the language in one page) and `botlish -help QUERY` (any rule, diagnostic
code or standard-library function).

Contents: 1. The shape of a program -- 2. Starting and stopping -- 3.
Windows -- 4. Panels and layout -- 5. Controls -- 6. The frame loop -- 7.
Events -- 8. Errors -- 9. Testing -- 10. Actions, timers, themes, XML -- 11.
The generated binding -- 12. Pitfalls.

## 1. The shape of a program

```
import raven                       # the module (its handles, controls, events)

with context raven::create()       # the entry program installs Raven's context once

fn main(context ui: raven::Ui) -> ... errors raven::RavenFailed, ...:
    raven::start(raven::desktop())     # or raven::headless()
    ... build windows and controls ...
    ... the frame loop ...
    raven::stop()
```

* **The context `raven::Ui`.** Raven needs native memory for a few calls
  (its start descriptor, out-parameters), which the context owns. The
  functions that need it declare `context ui: raven::Ui`: `start`, `stop`,
  `running?`, `last_error`, `size`, `rect`, `capture` and `click`. A
  function of yours that calls one declares the same parameter (it is
  passed implicitly: you never write it at the call). Everything else --
  making windows and controls, frames, events -- needs no context.
* **Handles.** `raven::Window`, `raven::Widget` (panels and controls) and
  `raven::Timer` are values naming one Raven object each. Copy them freely;
  Raven checks every handle, so a destroyed object's handle is reported (an
  Error event), never a crash.
* **Method syntax.** `window.set_content(panel)` is
  `raven::set_content(window, panel)`; the functions that make something
  from a text or a number (`raven::window`, `raven::label`,
  `raven::button`, ...) are written with their name only.
* **Native backends only.** Run with `-backend cranelift` (or
  `cranelift-generic`); `interp` and `compile` refuse a C call
  (NATIVE-ONLY).
* **One thread.** The program's thread is Raven's UI thread.

## 2. Starting and stopping

| call | what it does |
|---|---|
| `raven::start(raven::desktop())` | real windows (X11), drawn by the GPU through Vulkan; needs a display, the Vulkan loader and a driver |
| `raven::start(raven::headless())` | no window system, nothing drawn, no worker threads: tests and scripted runs |
| `raven::start(raven::Options {backend: raven::Backend::Null, headless: true, worker_threads: -1, ui_scale: 0.0})` | the same, written out: `backend` `Vulkan` or `Null`; `headless` false for real windows; `worker_threads` 0 (one per spare core) or a count, negative for none; `ui_scale` 0.0 for the monitor's |
| `raven::stop()` | destroys every window, widget and timer and forgets every event not taken; stopping a stopped Raven does nothing |
| `raven::running?()` | whether `start` succeeded and `stop` was not called since |
| `raven::version()` | Raven's version, "0.1.3" |

`start` fails with `raven::RavenFailed` (section 8). Starting a started
Raven changes nothing. Raven can be started again after `stop`.

## 3. Windows

| call | |
|---|---|
| `raven::window(title, width, height)` | a window with content `width` x `height` (logical units); closing it from its title bar closes it |
| `window.set_content(widget)` | the window's one content widget (usually a panel) |
| `window.set_title(text)` | |
| `window.keep_open(true)` | a close request then only reports `CloseRequested` (value 0); the program decides (`destroy_window`, or not) |
| `window.request_close()` | as the title bar's close button would |
| `window.destroy_window()` | |
| `window.open?()` | whether the window still exists |
| `window.find(name)` | the widget named `name` in it (`widget.set_name(name)`, or an XML `Name="..."`) |
| `window.size()` | its content size, `raven::Size {width, height}` (needs `Ui`) |
| `window.capture()` | its last rendered frame, `raven::Image {width, height, pixels}`: RGBA, `4 * width * height` bytes; 0 x 0 with the null renderer (needs `Ui`) |

`width` and `height` are C ints (`std::ffi::c::Int`): a literal works as it
is; an `int` variable must be proven to fit (section 12).

When the last window closes, the frame functions return false (section 6).

## 4. Panels and layout

```
row = raven::hbox().add(ok).add(cancel)          # children side by side
column = raven::vbox().add(title).add(row)       # one below another
window.set_content(column)
```

| call | |
|---|---|
| `raven::vbox()`, `raven::hbox()` | a vertical, a horizontal panel |
| `panel.add(child)` | adds `child` at the end; returns `panel`, so adds chain; the panel owns the child |
| `panel.set_spacing(12.0)` | the space between children (`errors NonFiniteFloat`) |
| `widget.set_padding(left, top, right, bottom)` | the space around a widget in its slot (`errors NonFiniteFloat`) |
| `widget.child_count()` | |
| `widget.destroy()` | deletes it and its children (remove a row of a list you build) |
| `widget.valid?()` | whether it still exists |
| `widget.set_name(name)`, `widget.set_enabled(flag)`, `widget.set_tooltip(text)` | |
| `widget.rect()` | where the last frame laid it out, `raven::Rect {x, y, width, height}` (Float64s, needs `Ui`, `errors NonFiniteFloat`) |

Controls keep their natural size: a button is as wide as its text.

## 5. Controls

Each control the module makes is watched: what the user does with it is
an event (section 7). What the program does itself (`set_text`,
`set_checked`, `select`, setting a value) is no event.

| make | read and change | its event |
|---|---|---|
| `raven::label(text)` | `label.set_text(text)`, `label.label_text()` | none |
| `raven::button(text)` | | `Clicked` |
| `raven::checkbox(text)` | `box.checked?()`, `box.set_checked(flag)`, `box.checkbox_text()` | `Toggled`: `value` 1 checked, 0 not |
| `raven::text_input(text)` | `input.input_text()`, `input.set_input_text(text)` | `TextChanged` on every edit, `TextCommitted` on Enter: `text` |
| `raven::combo_box(["A", "B"])` | `combo.selected()` (-1: none), `combo.select(index)` | `Selected`: `value`, the index |
| `raven::slider(0.0, 100.0)` (`errors NonFiniteFloat`) | `slider.slider_value()`, `slider.set_slider_value(x)` (both `errors NonFiniteFloat`) | `ValueChanged`: `number` |
| `raven::spin_box(0.0, 10.0)` | `spin.spin_box_value()` (`errors NonFiniteFloat`), `spin.set_spin_box_value(x)` | `ValueChanged`: `number` |

A slider holds a C float and a spin box a C double: `slider_raw_value` and
`spin_box_raw_value` give them as they are (`std::ffi::c::RawFloat`,
`RawDouble`), every bit, where an infinity or a NaN matters.

## 6. The frame loop

Raven has no loop of its own: the program asks for frames.

| call | |
|---|---|
| `raven::wait_frame(-1.0)` | sleeps until something happens (input, a timer, a window change), then processes it and draws; false once `quit` was called or the last window closed. A positive timeout (seconds) wakes it then anyway |
| `raven::draw_frame()` | the same without sleeping |
| `raven::quit(code)` | the next frame returns false; `raven::exit_code()` is `code` |

Events are taken after a frame. The loop carries the program's state
from frame to frame: a `fold` with no clause runs until `break`, and its
value is the last state (`botlish -help fold`):

```
final = fold with intermediate state initial:
    if not raven::wait_frame(-1.0):
        break
    next = fold event in raven::events() with intermediate s state:
        app.handle(s, event)
    app.show(next)
    next
```

`handle` returns the state after one event; `show` updates the widgets;
the body's value is the next frame's state. The same loop can be a
function that calls itself last, which the native backends run as a loop
(`examples/clicks/clicks.bot`'s `run`):

```
fn run(app: App, state: State) -> State errors NonFiniteFloat:
    if not raven::wait_frame(-1.0):
        return state
    app.run(app.step(state))
```

## 7. Events

`raven::events()` returns every event recorded since the last call,
oldest first (`errors NonFiniteFloat`). A `raven::Event` has:

| field | |
|---|---|
| `kind` | a `raven::EventKind`: `Clicked`, `Toggled`, `ValueChanged`, `TextChanged`, `TextCommitted`, `Selected`, `Action`, `CloseRequested`, `Resized`, `TimerElapsed`, `Error` |
| `source` | the C handle of the widget, window or timer it happened to |
| `value`, `extra` | ints: a checkbox's state, a selection's index, a window's new width and height (`Resized`), an error's code and severity (`Error`) |
| `number` | a slider's or a spin box's value |
| `text` | a text input's text, an action's name, an error's description |

Which control: `event.from?(widget)`, `event.from_window?(window)`,
`event.from_timer?(timer)`. Compare kinds with `==`:
`event.kind == raven::EventKind::Clicked`. `raven::pending()` counts the
events waiting.

`CloseRequested` comes from a window's close button: `value` 1 when it
closed, 0 when `keep_open(true)` kept it open. `Error` events report what
Raven refused (an invalid handle, a malformed XML interface), with its
text.

## 8. Errors

| error | from | |
|---|---|---|
| `raven::RavenFailed {call, code, detail}` | `start` | Raven did not start: `detail` is every error Raven reported while it tried, cause first (README.md, "When it does not start") |
| `NonFiniteFloat` | functions passing or reading C floats: `events`, `rect`, `click`, `inject_click`, `set_spacing`, `set_padding`, `slider`, `slider_value`, `set_slider_value`, `spin_box_value` | a number outside a C float's range, or one Raven reported that is no Float64 (an infinity, a NaN) |

A function that calls one either handles the error or declares it
(`errors NonFiniteFloat`); the compiler says which when one is missing.
Handling looks like this:

```
outcome = main():
    on raven::RavenFailed failure:
        "Raven did not start: ".concat(failure.detail)
    on NonFiniteFloat:
        "a number Raven reported is no Float64"
```

`raven::last_error()` (needs `Ui`) is Raven's last error as
`raven::Report {code, severity, detail}`.

## 9. Testing

A test starts Raven headless, makes the same windows, injects input,
delivers it with a frame and reads the result back. Nothing needs a
display, and the result is the same on every run.

| call | |
|---|---|
| `raven::draw_frame()` | lays the windows out and delivers injected input: call it once after building, before `click`, and after each injection. `click` aims at where the *last* frame put a widget: after adding widgets, draw a frame before clicking one of them |
| `window.click(widget)` | a left click at the middle of where the last frame laid `widget` out (needs `Ui`, `errors NonFiniteFloat`) |
| `window.inject_click(x, y)` | a left click at a point of the window |
| `window.inject_text(text)` | text typed into the focused widget (click a text input first) |
| `window.inject_key(key, modifiers)` | a key pressed and released: `raven::window::R_KEY_ENTER`, ... (`import raven::window`); modifiers `raven::window::R_MOD_*` or 0 |
| `label.label_text()`, `input.input_text()`, `box.checkbox_text()`, `box.checked?()`, `widget.child_count()`, ... | the widgets' state as Raven holds it, to compare with what you expect |

A complete test, the program of `examples/clicks/` driven headless:

```botlish
import clicks
import raven
import std::int

with context raven::create()

fn press(screen: clicks::Screen, button: raven::Widget, count: int, context ui: raven::Ui) -> int errors NonFiniteFloat:
    screen.window.click(button)
    drawn = raven::draw_frame()
    screen.step(count)

fn main(context ui: raven::Ui) -> List[str] errors raven::RavenFailed, NonFiniteFloat:
    raven::start(raven::headless())
    screen = clicks::build()
    laid_out = raven::draw_frame()
    one = screen.press(screen.add, 0)
    shown = raven::label_text(screen.status)
    raven::stop()
    [std::int::to_string(one), shown]

result = main():
    on raven::RavenFailed failure:
        ["RavenFailed", failure.detail]
    on NonFiniteFloat:
        ["NonFiniteFloat"]
result
```

Its value is `["1", "1 click"]`. A program's value is printed after it
runs, so a test can be a program whose value you compare.

The same synthetic input works with `raven::desktop()` under a virtual
display (`Xvfb`, README.md), where `window.capture()` also returns the
pixels the renderer drew -- compare two captures to see that a change was
drawn (`before.pixels != after.pixels`). To drive the real window from
outside instead, as a user would, use an X client that sends input through
the XTest extension (`xdotool`, where installed) and closes the window
with the `WM_DELETE_WINDOW` message a window manager's close button sends;
the package ships none.

A Botlish program cannot choose its exit status: a test reports its
verdict as its value (`botlish` prints it), which a script can check.

## 10. Actions, timers, themes, XML

* **Actions** are named commands: `widget.set_action("file.save")` gives a
  widget's main event (a click, a change, Enter) the action, and its
  event is `Action` with `text` "file.save"; `raven::fire_action(name)`
  fires one from the program. An action nobody else handles is an
  `Action` event anyway once Raven is started; `raven::bind_action(name)`
  makes `name` one even where other code (an XML interface's own
  handlers) binds it.
* **Timers**: `raven::timer(0.5, true)` is a `raven::Timer` whose ticks are
  `TimerElapsed` events, every 0.5 s (false: once); `timer.cancel()`.
  `wait_frame` wakes for them.
* **Themes**: `raven::apply_theme(raven::Theme::Light)` (`Dark`, `Light`,
  `GlassDark`, `GlassLight`, `HighContrastDark`, `HighContrastLight`).
* **XML interfaces**: `raven::window_from_xml(text)` makes a window from
  Raven's XML (`<Window Title="Hello" Width="400" Height="200"><VBox
  Spacing="12"><Label Name="status">...</Label><Button Name="go"
  Text="Go" OnClicked="app.go"/></VBox></Window>`); `window.find(name)`
  finds its widgets, and `OnClicked="..."` actions are `Action` events.

## 11. The generated binding

`import raven::controls` (`raven::core`, `raven::window`,
`raven::widget`, `raven::layout`, `raven::style`, ... -- the files under
`raven/` of the package) gives Raven's C functions as they are, for what
the module leaves out:

```
import raven::controls

raven::controls::Rlabel_set_markdown(label.id, 1)   # a handle's id is the C handle
```

The binding takes C types (`std::ffi::c::Int`, `UInt`, `Float`, strings
as Botlish strings) and its enumerations are plain constants
(`raven::widget::R_WIDGET_VBOX`). A function that takes a pointer the
binding knows nothing about (an out-parameter, a descriptor) is raw
authority: calling it makes your module `direct` (`botlish -help
DIRECT`); functions taking C callbacks cannot be given a Botlish function
here.

## 12. Pitfalls

* **Don't name a local like a function you call with method syntax.**
  With `add = raven::button("Add")`, a later `panel.add(x)` is
  AMBIGUOUS-METHOD-CALL (the local `add` is a candidate too). Name it
  `add_button`.
* **C ints.** `raven::window(title, w, h)` takes `std::ffi::c::Int`s. A
  literal is fine; an `int` parameter is not provably in range. Declare
  the parameter `w: std::ffi::c::Int` (`import std::ffi::c`), or check
  the range first (`if w < 0 or w > 2147483647: ...`).
* **Several contexts** go in one section: `context io: std::io::IO, ui:
  raven::Ui`.
* **Unused results.** A call whose result you do not need is bound to a
  name (`drawn = raven::draw_frame()`).
* **One-character strings** are character literals: `'!'`, and
  `text.append_char('!')` adds one.
* **No list concatenation**: build a `List` with one literal or a `loop`
  that collects.
* **`int` to text**: `std::int::to_string(n)` (`import std::int`).
* **Import what a method belongs to.** `xs.length()` of a `List` needs
  `import std::list`; with only `std::str` imported, the call resolves to
  `std::str::length` and the error names that function. The same holds for
  every module's functions used with method syntax.

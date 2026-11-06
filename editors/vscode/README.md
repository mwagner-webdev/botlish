# Botlish for VS Code

A VS Code extension for Botlish's language server (`main.tcl -lsp`,
LSP-MILESTONE-1.md): the `.bot` language, and one language client per
window that starts the server. What you get is what the server answers:

* the compiler's diagnostics, errors and warnings, as you type (after a
  short pause and a whole-program analysis);
* hover: a function's signature, a binding's type;
* go to definition, into the program, its modules and the standard
  library;
* find references within the analyzed program.

A program that does not load at all -- an import that finds no module,
say a generated binding that was never staged -- answers nothing anywhere;
its error is then also shown at the import in your file that leads to it,
with a link to the line where it is.

There is no syntax highlighting (the repository has no grammar), and no
completion, rename or formatting (the server implements none). Comment
toggling, bracket matching and spaces for indentation are configured
(a tab in indentation is a Botlish syntax error).

## What it needs

* A Botlish checkout: the extension runs its `main.tcl`.
* A Tcl 9 interpreter. The repository's baseline is 9.0.1 (AGENTS.md,
  "Installing Tcl 9"). On Windows, `tests/platform/setup-windows.ps1`
  builds it into `C:\botlish-tcl` (Visual Studio's C++ tools needed; the
  language server needs no Rust, so that step of the script can fail
  harmlessly). Magicsplat's Tcl 9 installer works too; check its version
  with `'puts [info patchlevel]' | tclsh90` (PowerShell). A later 9.0 runs the
  server, but its Unicode tables may differ from 9.0.1's (macOS's port
  records Homebrew's newer Tcl breaking the Unicode 16 semantics), so a
  fact about case-mapped or astral text can differ from CI's.
* Node.js and npm, only to build the extension.

## Installing it

From the checkout:

```bash
cd editors/vscode
npm ci
npm run package
code --install-extension botlish-0.1.0.vsix
```

Then, in your user settings (`Preferences: Open User Settings (JSON)`), say
where the checkout is; Windows paths take doubled backslashes:

```json
"botlish.main": "C:\\Users\\YOU\\dev\\botlish\\main.tcl"
```

Open a `.bot` file and the server starts; the **Botlish** output channel
shows the command it was started with. `Botlish: Restart Language Server`
restarts it, and so does any change of a `botlish.*` setting.

To try the extension without installing it, start VS Code with it loaded
from the checkout, where it finds `main.tcl` by itself:

```bash
code --extensionDevelopmentPath=PATH/TO/botlish/editors/vscode PATH/TO/project
```

## How it finds the server

1. `botlish.server.command`, when set (for example `["botlish", "-lsp"]`).
2. A Tcl 9 running `main.tcl -lsp`, where `main.tcl` is `botlish.main` or,
   for the extension loaded from a checkout's `editors/vscode`, that
   checkout's, and the Tcl is `botlish.tclsh` or the first that exists of
   `tclsh9.0` (Windows: `tclsh9.0.exe`, `tclsh90.exe`) on PATH,
   `%LOCALAPPDATA%\Apps\Tcl90\bin\tclsh90.exe` (Magicsplat's per-user
   install) and `C:\botlish-tcl\bin\tclsh9.0.exe` (setup-windows.ps1's).
3. The single executable, `botlish -lsp`, when `botlish` is on PATH (Linux
   and macOS; there is none for Windows).

`-warnings` (`botlish.warnings`) and `-target` (`botlish.target`) are
appended. When nothing applies the extension says what to set. On Linux
the server gets a UTF-8 locale (`LC_ALL=C.utf8`) when the environment has
none, as Tcl 9 needs (AGENTS.md).

| Setting | Default | |
|---|---|---|
| `botlish.main` | (the checkout holding the extension) | `main.tcl` of a checkout |
| `botlish.tclsh` | (searched, above) | the Tcl 9 interpreter |
| `botlish.server.command` | `[]` | the whole command instead |
| `botlish.target` | the host's | `-target`, e.g. `linux-x86_64` |
| `botlish.warnings` | `default` | `-warnings`: `default`, `off` or `error` |
| `botlish.debounce` | `250` | ms after the last change before an analysis |

The analysis is for the host's target unless `botlish.target` says
otherwise: on Windows a program importing `linux::*` (the 2048 demo, Icy
Tower's Linux entry) reports UNSUPPORTED-PLATFORM; set `botlish.target` to
`linux-x86_64` to edit one. In a restricted (untrusted) workspace,
`botlish.main`, `botlish.tclsh` and `botlish.server.command` are read from
your user settings only.

**WSL.** In a VS Code window connected to WSL (the WSL extension), install
the `.vsix` in that window: the extension and the server then run in
Linux, and `botlish.main` is a Linux path (`/mnt/c/...`). A Windows window
cannot use a server inside WSL: the server reads file URIs by its own
host's rules, so a Windows path names no file there.

## Tests

```bash
npm test
```

runs the command resolution's tests (Windows layouts simulated) and a
session with the real server (`tclsh9.0` on PATH, or `BOTLISH_TCLSH`):
VS Code's transport library, its client capabilities and CRLF text.

```bash
xvfb-run -a npm run test:vscode
```

runs the extension in VS Code itself (1.143.1, downloaded into
`.vscode-test/`; `BOTLISH_VSCODE_VERSION` picks another), loaded from the
checkout and as an installed copy with `botlish.main` set: diagnostics,
hover, definition into a module and into the standard library,
references, an unsaved fix and a restart. Drop `xvfb-run -a` where there
is a display. CI runs neither.

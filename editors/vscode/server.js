// server.js -- the command that starts Botlish's language server
// (main.tcl -lsp, LSP-MILESTONE-1.md), worked out from the extension's
// settings, its own directory and the environment. It has no VS Code
// dependency, so test/ runs it as it is.
//
// The command is, in order:
//
//   1. botlish.server.command, when set;
//   2. TCLSH MAIN -lsp, where MAIN is botlish.main or, when the extension
//      sits in a checkout (editors/vscode), that checkout's main.tcl, and
//      TCLSH is botlish.tclsh or the first Tcl 9 interpreter found (Tcl9Names
//      on PATH, then KnownTcl9);
//   3. the single executable, botlish -lsp, when it is on PATH;
//
// with -warnings and, when set, -target appended. Nothing is guessed past
// that: when none applies the error says what to set.

'use strict';

const fs = require('fs');
const path = require('path');

function Tcl9Names(platform) {
  return platform === 'win32' ? ['tclsh9.0.exe', 'tclsh90.exe'] : ['tclsh9.0'];
}

// Where a Tcl 9 is installed when it is not on PATH: Magicsplat's per-user
// installer, and tests/platform/setup-windows.ps1's default prefix.
function KnownTcl9(env, platform) {
  if (platform !== 'win32') return [];
  const known = [];
  const local = Env(env, platform, 'LOCALAPPDATA');
  if (local) {
    known.push(path.win32.join(local, 'Apps', 'Tcl90', 'bin', 'tclsh90.exe'));
  }
  known.push('C:\\botlish-tcl\\bin\\tclsh9.0.exe');
  return known;
}

function Paths(platform) {
  return platform === 'win32' ? path.win32 : path.posix;
}

// An environment variable; Windows' names are case-insensitive.
function Env(env, platform, name) {
  if (platform !== 'win32') return env[name];
  const key = Object.keys(env).find((k) => k.toUpperCase() === name);
  return key === undefined ? undefined : env[key];
}

function IsFile(p) {
  try {
    return fs.statSync(p).isFile();
  } catch {
    return false;
  }
}

function OnPath(names, env, platform, isFile) {
  const p = Paths(platform);
  const dirs = (Env(env, platform, 'PATH') || '').split(p.delimiter).filter(Boolean);
  for (const dir of dirs) {
    for (const name of names) {
      const candidate = p.join(dir, name);
      if (isFile(candidate)) return candidate;
    }
  }
  return null;
}

// An executable setting: an absolute or relative path that must exist, or a
// bare name looked up on PATH.
function Executable(setting, what, env, platform, isFile) {
  const p = Paths(platform);
  if (setting.includes('/') || setting.includes(p.sep)) {
    if (isFile(setting)) return setting;
    throw new Error(`${what} "${setting}" does not exist`);
  }
  const names = platform === 'win32' && !/\.exe$/i.test(setting) ? [`${setting}.exe`, setting] : [setting];
  const found = OnPath(names, env, platform, isFile);
  if (found) return found;
  throw new Error(`${what} "${setting}" is not on PATH`);
}

function Tclsh(settings, env, platform, isFile) {
  if (settings.tclsh) return Executable(settings.tclsh, 'botlish.tclsh', env, platform, isFile);
  const found = OnPath(Tcl9Names(platform), env, platform, isFile)
    || KnownTcl9(env, platform).find((p) => isFile(p));
  if (found) return found;
  const looked = Tcl9Names(platform).join(' or ') + ' on PATH'
    + KnownTcl9(env, platform).map((p) => `, ${p}`).join('');
  throw new Error(`no Tcl 9 interpreter found (looked for ${looked}): set botlish.tclsh`);
}

// main.tcl of the checkout this extension sits in, when it sits in one.
function OwnCheckout(extensionPath, platform, isFile) {
  const p = Paths(platform);
  const root = p.resolve(extensionPath, '..', '..');
  const main = p.join(root, 'main.tcl');
  return isFile(main) && isFile(p.join(root, 'lsp', 'server.tcl')) ? main : null;
}

// {command, args, env, via}: what to spawn, the environment to give it (the
// extension's own, plus a UTF-8 locale on Linux when it has none: Tcl 9
// falls back to iso8859-1 there, AGENTS.md), and which rule chose it.
function resolveServer({ settings, extensionPath, env, platform, isFile = IsFile }) {
  const p = Paths(platform);
  let command;
  let args;
  let via;
  if (settings.command && settings.command.length > 0) {
    [command, ...args] = settings.command;
    via = 'botlish.server.command';
  } else {
    let main = null;
    if (settings.main) {
      if (!isFile(settings.main)) throw new Error(`botlish.main "${settings.main}" does not exist`);
      main = p.resolve(settings.main);
      via = 'botlish.main';
    } else {
      main = OwnCheckout(extensionPath, platform, isFile);
      via = 'the checkout holding this extension';
    }
    if (main) {
      command = Tclsh(settings, env, platform, isFile);
      args = [main, '-lsp'];
    } else {
      command = OnPath([platform === 'win32' ? 'botlish.exe' : 'botlish'], env, platform, isFile);
      if (!command) {
        throw new Error('no Botlish found: set botlish.main to the main.tcl of a Botlish checkout'
          + ' (or botlish.server.command)');
      }
      args = ['-lsp'];
      via = 'the single executable on PATH';
    }
  }
  args.push('-warnings', settings.warnings || 'default');
  if (settings.target) args.push('-target', settings.target);

  const childEnv = { ...env };
  if (platform === 'linux') {
    const locale = env.LC_ALL || env.LC_CTYPE || env.LANG || '';
    if (!/utf-?8/i.test(locale)) childEnv.LC_ALL = 'C.utf8';
  }
  return { command, args, env: childEnv, via };
}

module.exports = { resolveServer };

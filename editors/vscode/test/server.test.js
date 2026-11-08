// server.test.js -- the command server.js works out, on simulated hosts:
// which rule applies, what is found where, and what is appended.

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { resolveServer } = require('../server');

const none = { tclsh: '', main: '', command: [], target: '', warnings: 'default' };

function Files(...paths) {
  const set = new Set(paths);
  return (p) => set.has(p);
}

const winExtension = 'C:\\Users\\someone\\.vscode\\extensions\\botlish.botlish-0.1.0';
const winEnv = { Path: 'C:\\Windows\\system32;C:\\Windows', LOCALAPPDATA: 'C:\\Users\\someone\\AppData\\Local' };
const magicsplat = 'C:\\Users\\someone\\AppData\\Local\\Apps\\Tcl90\\bin\\tclsh90.exe';

test('windows: a Tcl installed per user by Magicsplat, botlish.main set', () => {
  const r = resolveServer({
    settings: { ...none, main: 'C:\\dev\\botlish\\main.tcl' },
    extensionPath: winExtension,
    env: winEnv,
    platform: 'win32',
    isFile: Files(magicsplat, 'C:\\dev\\botlish\\main.tcl'),
  });
  assert.equal(r.command, magicsplat);
  assert.deepEqual(r.args, ['C:\\dev\\botlish\\main.tcl', '-lsp', '-warnings', 'default']);
  assert.equal(r.via, 'botlish.main');
  assert.equal(r.env.LC_ALL, undefined);
});

test('windows: a Tcl 9 on PATH comes before the known places', () => {
  const r = resolveServer({
    settings: { ...none, main: 'C:\\dev\\botlish\\main.tcl' },
    extensionPath: winExtension,
    env: { ...winEnv, Path: 'C:\\Tcl\\bin;C:\\Windows' },
    platform: 'win32',
    isFile: Files(magicsplat, 'C:\\Tcl\\bin\\tclsh90.exe', 'C:\\dev\\botlish\\main.tcl'),
  });
  assert.equal(r.command, 'C:\\Tcl\\bin\\tclsh90.exe');
});

test('windows: setup-windows.ps1\'s prefix', () => {
  const r = resolveServer({
    settings: { ...none, main: 'C:\\dev\\botlish\\main.tcl' },
    extensionPath: winExtension,
    env: winEnv,
    platform: 'win32',
    isFile: Files('C:\\botlish-tcl\\bin\\tclsh9.0.exe', 'C:\\dev\\botlish\\main.tcl'),
  });
  assert.equal(r.command, 'C:\\botlish-tcl\\bin\\tclsh9.0.exe');
});

test('windows: the extension loaded from a checkout\'s editors\\vscode finds its main.tcl', () => {
  const r = resolveServer({
    settings: { ...none, tclsh: magicsplat, target: 'linux-x86_64', warnings: 'off' },
    extensionPath: 'C:\\dev\\botlish\\editors\\vscode',
    env: winEnv,
    platform: 'win32',
    isFile: Files(magicsplat, 'C:\\dev\\botlish\\main.tcl', 'C:\\dev\\botlish\\lsp\\server.tcl'),
  });
  assert.equal(r.command, magicsplat);
  assert.deepEqual(r.args,
    ['C:\\dev\\botlish\\main.tcl', '-lsp', '-warnings', 'off', '-target', 'linux-x86_64']);
  assert.equal(r.via, 'the checkout holding this extension');
});

test('windows: botlish.tclsh as a bare name is looked up on PATH, .exe added', () => {
  const r = resolveServer({
    settings: { ...none, tclsh: 'tclsh90', main: 'C:\\dev\\botlish\\main.tcl' },
    extensionPath: winExtension,
    env: { ...winEnv, Path: 'C:\\Tcl\\bin' },
    platform: 'win32',
    isFile: Files('C:\\Tcl\\bin\\tclsh90.exe', 'C:\\dev\\botlish\\main.tcl'),
  });
  assert.equal(r.command, 'C:\\Tcl\\bin\\tclsh90.exe');
});

test('windows: no Tcl 9 anywhere names what was looked for', () => {
  assert.throws(() => resolveServer({
    settings: { ...none, main: 'C:\\dev\\botlish\\main.tcl' },
    extensionPath: winExtension,
    env: winEnv,
    platform: 'win32',
    isFile: Files('C:\\dev\\botlish\\main.tcl'),
  }), /no Tcl 9 interpreter found \(looked for tclsh9\.0\.exe or tclsh90\.exe on PATH, .*Tcl90.*tclsh90\.exe, C:\\botlish-tcl.*\): set botlish\.tclsh/);
});

test('windows: neither a checkout nor botlish on PATH asks for botlish.main', () => {
  assert.throws(() => resolveServer({
    settings: none,
    extensionPath: winExtension,
    env: winEnv,
    platform: 'win32',
    isFile: Files(magicsplat),
  }), /set botlish\.main/);
});

test('missing settings are errors, never passed over', () => {
  assert.throws(() => resolveServer({
    settings: { ...none, main: '/nowhere/main.tcl' },
    extensionPath: '/ext',
    env: { PATH: '/usr/bin' },
    platform: 'linux',
    isFile: Files('/usr/bin/tclsh9.0'),
  }), /botlish\.main "\/nowhere\/main\.tcl" does not exist/);
  assert.throws(() => resolveServer({
    settings: { ...none, tclsh: '/opt/tcl/bin/tclsh9.0', main: '/src/botlish/main.tcl' },
    extensionPath: '/ext',
    env: { PATH: '/usr/bin' },
    platform: 'linux',
    isFile: Files('/usr/bin/tclsh9.0', '/src/botlish/main.tcl'),
  }), /botlish\.tclsh "\/opt\/tcl\/bin\/tclsh9\.0" does not exist/);
});

test('the single executable on PATH, when no checkout is named', () => {
  const r = resolveServer({
    settings: none,
    extensionPath: '/home/someone/.vscode/extensions/botlish.botlish-0.1.0',
    env: { PATH: '/usr/bin:/home/someone/bin', LANG: 'en_US.UTF-8' },
    platform: 'linux',
    isFile: Files('/home/someone/bin/botlish'),
  });
  assert.equal(r.command, '/home/someone/bin/botlish');
  assert.deepEqual(r.args, ['-lsp', '-warnings', 'default']);
  assert.equal(r.env.LC_ALL, undefined);
});

test('botlish.server.command is used as given, the analysis options appended', () => {
  const r = resolveServer({
    settings: { ...none, command: ['wrapper', 'botlish', '-lsp'], target: 'linux-aarch64' },
    extensionPath: '/ext',
    env: { PATH: '/usr/bin', LANG: 'C.UTF-8' },
    platform: 'linux',
    isFile: Files(),
  });
  assert.equal(r.command, 'wrapper');
  assert.deepEqual(r.args, ['botlish', '-lsp', '-warnings', 'default', '-target', 'linux-aarch64']);
});

test('linux: a UTF-8 locale for Tcl when the environment has none', () => {
  const r = resolveServer({
    settings: { ...none, main: '/src/botlish/main.tcl' },
    extensionPath: '/ext',
    env: { PATH: '/usr/bin' },
    platform: 'linux',
    isFile: Files('/usr/bin/tclsh9.0', '/src/botlish/main.tcl'),
  });
  assert.equal(r.command, '/usr/bin/tclsh9.0');
  assert.equal(r.env.LC_ALL, 'C.utf8');
});

// suite.js -- runs inside VS Code (run.js starts it), through VS Code's own
// API only: the .bot language, the server's diagnostics, hover, definition
// (into the module and into the standard library), references, an unsaved
// fix, the restart command, and no file written.

'use strict';

const assert = require('assert');
const fs = require('fs');
const path = require('path');
const vscode = require('vscode');

async function WaitFor(what, probe, timeout = 120000) {
  const start = Date.now();
  for (;;) {
    const value = await probe();
    if (value) return value;
    if (Date.now() - start > timeout) throw new Error(`no ${what} within ${timeout} ms`);
    await new Promise((resolve) => setTimeout(resolve, 100));
  }
}

function Errors(uri) {
  return vscode.languages.getDiagnostics(uri).filter((d) => d.severity === vscode.DiagnosticSeverity.Error);
}

function Target(location) {
  return {
    file: path.basename((location.targetUri || location.uri).fsPath),
    start: (location.targetSelectionRange || location.range || location.targetRange).start,
  };
}

async function HoverText(uri, position) {
  const hovers = await vscode.commands.executeCommand('vscode.executeHoverProvider', uri, position);
  return hovers.flatMap((h) => h.contents.map((c) => (typeof c === 'string' ? c : c.value))).join('\n');
}

async function run() {
  const project = process.env.BOTLISH_VSCODE_PROJECT;
  const main = vscode.Uri.file(path.join(project, 'main.bot'));
  const onDisk = fs.readFileSync(main.fsPath, 'utf8');

  const document = await vscode.workspace.openTextDocument(main);
  assert.equal(document.languageId, 'botlish');
  assert.equal(document.eol, vscode.EndOfLine.CRLF);
  const editor = await vscode.window.showTextDocument(document);
  assert.equal(editor.options.insertSpaces, true);
  await WaitFor('activation', () => vscode.extensions.getExtension('botlish.botlish').isActive);

  const errors = await WaitFor('diagnostics', () => Errors(main).length > 0 && Errors(main));
  assert.equal(errors.length, 1);
  assert.equal(errors[0].message, 'unbound name "nosuch"');
  assert.deepEqual([errors[0].range.start.line, errors[0].range.start.character], [5, 8]);

  const area = new vscode.Position(3, 13);
  assert.ok((await HoverText(main, area)).includes('fn shapes::area(w: int, h: int) -> int'));

  const definitions = await vscode.commands.executeCommand('vscode.executeDefinitionProvider', main, area);
  const shapes = Target(definitions[0]);
  assert.deepEqual([shapes.file, shapes.start.line, shapes.start.character], ['shapes.bot', 0, 3]);

  const get = new vscode.Position(4, 16);
  const library = Target((await vscode.commands.executeCommand('vscode.executeDefinitionProvider', main, get))[0]);
  assert.equal(library.file, 'list.bot');

  const references = await vscode.commands.executeCommand('vscode.executeReferenceProvider', main, area);
  assert.deepEqual(references.map((r) => `${path.basename(r.uri.fsPath)}:${r.range.start.line}`).sort(),
    ['main.bot:3', 'shapes.bot:0']);

  const at = document.getText().indexOf('nosuch');
  await editor.edit((e) => e.replace(
    new vscode.Range(document.positionAt(at), document.positionAt(at + 'nosuch'.length)), '0'));
  await WaitFor('the fix', () => Errors(main).length === 0);
  assert.ok(document.isDirty);

  await vscode.commands.executeCommand('botlish.restartServer');
  await WaitFor('an answer after the restart',
    async () => (await HoverText(main, area)).includes('fn shapes::area'));

  assert.equal(fs.readFileSync(main.fsPath, 'utf8'), onDisk);
}

module.exports = { run };

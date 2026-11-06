// session.test.js -- the language server started as the extension starts it
// (server.js's command, this checkout's main.tcl), driven over its stdio by
// vscode-jsonrpc, the transport vscode-languageclient uses, with the
// capabilities VS Code's client announces and the CRLF text a Windows
// editor sends: diagnostics, hover, definition, references, an unsaved fix
// and the shutdown. Skipped when no Tcl 9 interpreter is found.

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawn } = require('child_process');
const { pathToFileURL } = require('url');
const rpc = require('vscode-jsonrpc/node');
const { resolveServer } = require('../server');

const extensionPath = path.resolve(__dirname, '..');
const settings = { tclsh: process.env.BOTLISH_TCLSH || '', main: '', command: [], target: '', warnings: 'default' };

let server = null;
let unavailable = null;
try {
  server = resolveServer({ settings, extensionPath, env: process.env, platform: process.platform });
} catch (e) {
  unavailable = e.message;
}

function Crlf(text) {
  return text.replace(/\n/g, '\r\n');
}

// The first notification of METHOD that ACCEPT takes, within TIMEOUT ms.
function Next(waiters, method, accept, timeout = 120000) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error(`no ${method} within ${timeout} ms`)), timeout);
    waiters.push({ method, accept, resolve: (v) => { clearTimeout(timer); resolve(v); } });
  });
}

test('a session as VS Code has it', { skip: unavailable ? `no server: ${unavailable}` : false }, async () => {
  assert.equal(server.via, 'the checkout holding this extension');
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'botlish vscode '));
  try {
    const shapes = 'fn area(w: int, h: int) -> int:\n    w * h\n';
    const main = 'import shapes\nimport std::list\n\na = shapes::area(3, 4)\nb = std::list::get([1, 2], 5, 0)\na + b + nosuch\n';
    fs.writeFileSync(path.join(dir, 'shapes.bot'), Crlf(shapes));
    fs.writeFileSync(path.join(dir, 'main.bot'), Crlf(main));
    const mainUri = pathToFileURL(path.join(dir, 'main.bot')).href;

    const child = spawn(server.command, server.args, { env: server.env, stdio: ['pipe', 'pipe', 'pipe'] });
    let stderr = '';
    child.stderr.on('data', (d) => { stderr += d; });
    const exited = new Promise((resolve) => child.on('exit', (code) => resolve(code)));
    const connection = rpc.createMessageConnection(
      new rpc.StreamMessageReader(child.stdout), new rpc.StreamMessageWriter(child.stdin));
    const waiters = [];
    connection.onNotification((method, params) => {
      const i = waiters.findIndex((w) => w.method === method && w.accept(params));
      if (i >= 0) waiters.splice(i, 1)[0].resolve(params);
    });
    connection.listen();

    const init = await connection.sendRequest('initialize', {
      processId: process.pid,
      clientInfo: { name: 'Visual Studio Code', version: '1.106.0' },
      locale: 'en',
      rootUri: pathToFileURL(dir).href,
      workspaceFolders: [{ uri: pathToFileURL(dir).href, name: path.basename(dir) }],
      capabilities: {
        general: { positionEncodings: ['utf-16'] },
        workspace: { configuration: true, workspaceFolders: true, didChangeConfiguration: { dynamicRegistration: true } },
        textDocument: {
          synchronization: { dynamicRegistration: true, willSave: true, willSaveWaitUntil: true, didSave: true },
          hover: { dynamicRegistration: true, contentFormat: ['markdown', 'plaintext'] },
          definition: { dynamicRegistration: true, linkSupport: true },
          references: { dynamicRegistration: true },
          publishDiagnostics: { relatedInformation: true, versionSupport: false, tagSupport: { valueSet: [1, 2] } },
        },
        window: { workDoneProgress: true, showMessage: {}, showDocument: { support: true } },
      },
      initializationOptions: { debounce: 250 },
      trace: 'off',
    });
    assert.equal(init.capabilities.positionEncoding, 'utf-16');
    assert.deepEqual(init.capabilities.textDocumentSync, { openClose: true, change: 1, save: { includeText: false } });
    connection.sendNotification('initialized', {});
    // What VS Code's client sends besides: notifications the server drops.
    connection.sendNotification('$/setTrace', { value: 'off' });
    connection.sendNotification('workspace/didChangeConfiguration', { settings: null });

    const first = Next(waiters, 'textDocument/publishDiagnostics', (p) => p.uri === mainUri);
    connection.sendNotification('textDocument/didOpen', {
      textDocument: { uri: mainUri, languageId: 'botlish', version: 1, text: Crlf(main) },
    });
    const diagnostics = (await first).diagnostics;
    assert.equal(diagnostics.length, 1, JSON.stringify(diagnostics));
    assert.equal(diagnostics[0].message, 'unbound name "nosuch"');
    assert.deepEqual(diagnostics[0].range.start, { line: 5, character: 8 });

    const at = { textDocument: { uri: mainUri }, position: { line: 3, character: 13 } };
    const hover = await connection.sendRequest('textDocument/hover', at);
    assert.deepEqual(hover.contents,
      { kind: 'markdown', value: '```botlish\nfn shapes::area(w: int, h: int) -> int\n```' });

    const definition = await connection.sendRequest('textDocument/definition', at);
    const target = Array.isArray(definition) ? definition[0] : definition;
    assert.equal(path.basename(new URL(target.uri).pathname), 'shapes.bot');
    assert.deepEqual(target.range.start, { line: 0, character: 3 });

    const references = await connection.sendRequest('textDocument/references',
      { ...at, context: { includeDeclaration: true } });
    assert.deepEqual(references.map((r) => `${path.basename(new URL(r.uri).pathname)}:${r.range.start.line}`),
      ['shapes.bot:0', 'main.bot:3']);

    const fixed = Next(waiters, 'textDocument/publishDiagnostics', (p) => p.uri === mainUri);
    connection.sendNotification('textDocument/didChange', {
      textDocument: { uri: mainUri, version: 2 },
      contentChanges: [{ text: Crlf(main.replace('nosuch', '0')) }],
    });
    assert.deepEqual((await fixed).diagnostics.filter((d) => d.severity === 1), []);

    assert.equal(await connection.sendRequest('shutdown'), null);
    connection.sendNotification('exit');
    assert.equal(await exited, 0, stderr);
    connection.dispose();
    // The editor's buffers are the server's: it wrote nothing.
    assert.equal(fs.readFileSync(path.join(dir, 'main.bot'), 'utf8'), Crlf(main));
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
});

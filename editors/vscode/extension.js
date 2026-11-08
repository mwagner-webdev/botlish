// extension.js -- Botlish's language server in VS Code (LSP-MILESTONE-1.md).
//
// The `.bot` language and one language client, started with the command
// server.js works out, for every Botlish file of the window. The server
// answers diagnostics, hover, go to definition and references; everything
// else here is VS Code's.

'use strict';

const vscode = require('vscode');
const { LanguageClient } = require('vscode-languageclient/node');
const { resolveServer } = require('./server');

let client = null;
let output = null;
let starting = Promise.resolve();

function Settings() {
  const c = vscode.workspace.getConfiguration('botlish');
  return {
    tclsh: c.get('tclsh', ''),
    main: c.get('main', ''),
    command: c.get('server.command', []),
    target: c.get('target', ''),
    warnings: c.get('warnings', 'default'),
    debounce: c.get('debounce', 250),
  };
}

async function Start(context) {
  const settings = Settings();
  let server;
  try {
    server = resolveServer({
      settings,
      extensionPath: context.extensionPath,
      env: process.env,
      platform: process.platform,
    });
  } catch (e) {
    output.error(`not started: ${e.message}`);
    // Not awaited: the message stays until it is dismissed, and activation
    // must not wait for that.
    vscode.window.showErrorMessage(`Botlish: ${e.message}`, 'Open Settings').then((choice) => {
      if (choice) vscode.commands.executeCommand('workbench.action.openSettings', 'botlish');
    });
    return;
  }
  output.info(`starting (${server.via}): ${[server.command, ...server.args].join(' ')}`);
  client = new LanguageClient(
    'botlish',
    'Botlish',
    { command: server.command, args: server.args, options: { env: server.env } },
    {
      // The server reads files only: an untitled buffer is no program.
      documentSelector: [{ scheme: 'file', language: 'botlish' }],
      initializationOptions: { debounce: settings.debounce },
      outputChannel: output,
    },
  );
  try {
    await client.start();
  } catch (e) {
    output.error(`failed to start: ${e.message}`);
    vscode.window.showErrorMessage(`Botlish: the language server did not start (${e.message}); see the Botlish output.`);
    client = null;
  }
}

async function Stop() {
  if (client) {
    const stopping = client;
    client = null;
    try {
      await stopping.stop();
    } catch (e) {
      output.error(`stopping: ${e.message}`);
    }
  }
}

function Restart(context) {
  starting = starting.then(() => Stop()).then(() => Start(context));
  return starting;
}

function activate(context) {
  // A log channel: the language client writes its own records to it.
  output = vscode.window.createOutputChannel('Botlish', { log: true });
  context.subscriptions.push(
    output,
    vscode.commands.registerCommand('botlish.restartServer', () => Restart(context)),
    vscode.workspace.onDidChangeConfiguration((e) => {
      if (e.affectsConfiguration('botlish')) Restart(context);
    }),
  );
  return Restart(context);
}

function deactivate() {
  return starting.then(() => Stop());
}

module.exports = { activate, deactivate };

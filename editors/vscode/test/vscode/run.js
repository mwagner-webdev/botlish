// run.js -- the extension in a real VS Code (npm run test:vscode): downloads
// the pinned release into .vscode-test/ (BOTLISH_VSCODE_VERSION picks
// another), opens a two-module project in a directory whose name has a space
// and a non-ASCII letter, its files with CRLF line ends as on Windows, and
// runs suite.js inside it twice: the extension loaded from this checkout's
// editors/vscode (it finds main.tcl itself), and a copy of it elsewhere, as a
// .vsix installs it, told where main.tcl is by botlish.main. Linux needs a
// display: xvfb-run -a npm run test:vscode.

'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const { runTests } = require('@vscode/test-electron');

const extension = path.resolve(__dirname, '..', '..');
const checkoutMain = path.resolve(extension, '..', '..', 'main.tcl');
const shapes = 'fn area(w: int, h: int) -> int:\n    w * h\n';
const main = 'import shapes\nimport std::list\n\na = shapes::area(3, 4)\nb = std::list::get([1, 2], 5, 0)\na + b + nosuch\n';

function Temporary(prefix) {
  return fs.mkdtempSync(path.join(os.tmpdir(), prefix));
}

async function Scenario(name, extensionDevelopmentPath, settings) {
  const project = Temporary('botlish vscode é ');
  const userData = Temporary('botlish-vscode-user-');
  try {
    fs.writeFileSync(path.join(project, 'shapes.bot'), shapes.replace(/\n/g, '\r\n'));
    fs.writeFileSync(path.join(project, 'main.bot'), main.replace(/\n/g, '\r\n'));
    fs.mkdirSync(path.join(userData, 'User'));
    fs.writeFileSync(path.join(userData, 'User', 'settings.json'), JSON.stringify(settings));
    const launchArgs = [project, '--disable-extensions', '--disable-workspace-trust',
      '--user-data-dir', userData, '--skip-welcome', '--skip-release-notes'];
    if (process.platform === 'linux' && process.getuid() === 0) launchArgs.push('--no-sandbox');
    const code = await runTests({
      version: process.env.BOTLISH_VSCODE_VERSION || '1.143.1',
      extensionDevelopmentPath,
      extensionTestsPath: path.resolve(__dirname, 'suite.js'),
      extensionTestsEnv: { BOTLISH_VSCODE_PROJECT: project },
      launchArgs,
    });
    console.log(`${name}: ${code === 0 ? 'passed' : `failed (${code})`}`);
    return code;
  } finally {
    fs.rmSync(project, { recursive: true, force: true });
    fs.rmSync(userData, { recursive: true, force: true });
  }
}

async function Run() {
  let failed = 0;
  if (await Scenario('from the checkout', extension, {}) !== 0) failed++;

  const installed = path.join(Temporary('botlish-vscode-installed-'), 'botlish.botlish-0.1.0');
  try {
    fs.cpSync(extension, installed, {
      recursive: true,
      filter: (source) => !['test', '.vscode-test'].includes(path.basename(source)) && !source.endsWith('.vsix'),
    });
    if (await Scenario('installed, botlish.main set', installed, { 'botlish.main': checkoutMain }) !== 0) failed++;
  } finally {
    fs.rmSync(path.dirname(installed), { recursive: true, force: true });
  }
  process.exitCode = failed === 0 ? 0 : 1;
}

Run().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});

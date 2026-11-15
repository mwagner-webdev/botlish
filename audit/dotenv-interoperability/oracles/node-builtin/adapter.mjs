// audit/dotenv-interoperability: Node.js's own dotenv parser.
//
//   node adapter.mjs --manifest FILE [--target NAME]
//
// util.parseEnv(content) (Node 20.12+, 21.7+) is the parser behind --env-file
// and process.loadEnvFile, exposed as a pure function of a string: it writes
// nothing. The adapter reads each fixture as fs.readFileSync(path, "utf8")
// (invalid UTF-8 becomes U+FFFD before the parser sees it: the --env-file
// target, which reads the file itself, observes the bytes path).
//
// The --env-file behavior is a separate target (node-envfile): the harness
// starts `node --env-file=FIXTURE dump.mjs` once per fixture in a controlled
// environment and compares the environment dump.mjs prints with the one it
// supplied.
import fs from "node:fs";
import util from "node:util";

const arg = (name, fallback) => {
  const i = process.argv.indexOf(name);
  return i >= 0 ? process.argv[i + 1] : fallback;
};
const emit = (o) => fs.writeSync(1, JSON.stringify(o) + "\n");

emit({type: "meta", target: arg("--target", "node-builtin"), config: "default",
      runtime: "Node.js " + process.version, library: "node:util", library_version: process.version,
      options: {api: "util.parseEnv(fs.readFileSync(path, 'utf8'))"}});
const {fixtures} = JSON.parse(fs.readFileSync(arg("--manifest"), "utf8"));
for (const fx of fixtures) {
  const out = {type: "result", id: fx.id, status: "ok", assignments: [], error: null, warnings: [], views: {}};
  try {
    const parsed = util.parseEnv(fs.readFileSync(fx.path, "utf8"));
    out.assignments = Object.entries(parsed);
  } catch (e) {
    out.status = "error";
    out.error = {class: e && e.constructor ? e.constructor.name : typeof e, message: String(e && e.message)};
  }
  emit(out);
}

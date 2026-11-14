// audit/dotenv-interoperability: the npm dotenv adapter (motdotla/dotenv).
//
//   node adapter.cjs --lib NODE_MODULES --manifest FILE --config NAME
//
// The public API used is dotenv.parse(src[, options]): a pure function of the
// file's text; it returns an object and writes nothing (config() populates
// process.env; expansion is the separate dotenv-expand package and is not
// part of this target). The adapter reads the file exactly as config() does,
// fs.readFileSync(path, {encoding: "utf8"}).
//
// Configurations: default (parse(src)) and fast (parse(src, {fast: true}):
// dotenv 18's hand-written parser, selected by the `fast` option or the
// DOTENV_FAST / DOTENV_CONFIG_FAST environment variables in config()).
const fs = require("node:fs");
const path = require("node:path");
const arg = (name, fallback) => {
  const i = process.argv.indexOf(name);
  return i >= 0 ? process.argv[i + 1] : fallback;
};
const emit = (o) => fs.writeSync(1, JSON.stringify(o) + "\n");
const lib = arg("--lib");
const dotenv = require(path.join(lib, "dotenv"));
const version = JSON.parse(fs.readFileSync(path.join(lib, "dotenv", "package.json"), "utf8")).version;
const config = arg("--config", "default");
const options = config === "fast" ? {fast: true} : undefined;

emit({type: "meta", target: arg("--target", "node-dotenv"), config,
      runtime: "Node.js " + process.version, library: "dotenv", library_version: version,
      options: {api: options ? "dotenv.parse(src, {fast: true})" : "dotenv.parse(src)",
                read: "fs.readFileSync(path, {encoding: 'utf8'})"}});
const {fixtures} = JSON.parse(fs.readFileSync(arg("--manifest"), "utf8"));
for (const fx of fixtures) {
  const out = {type: "result", id: fx.id, status: "ok", assignments: [], error: null, warnings: [], views: {}};
  try {
    out.assignments = Object.entries(dotenv.parse(fs.readFileSync(fx.path, {encoding: "utf8"}), options));
  } catch (e) {
    out.status = "error";
    out.error = {class: e && e.constructor ? e.constructor.name : typeof e, message: String(e && e.message)};
  }
  emit(out);
}

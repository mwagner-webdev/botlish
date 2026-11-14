// audit/dotenv-interoperability: prints the process environment as one JSON
// object. Run as `node --env-file=FIXTURE dump.mjs` (target node-envfile) and
// `bun --no-env-file --env-file=FIXTURE dump.mjs` (target bun); the harness
// subtracts the environment it supplied. The runtime and its version are
// printed beside it.
import fs from "node:fs";
const runtime = typeof Bun !== "undefined" ? "Bun " + Bun.version : "Node.js " + process.version;
fs.writeSync(1, JSON.stringify({runtime, env: {...process.env}}) + "\n");

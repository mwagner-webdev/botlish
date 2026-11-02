# The independent agent experiment

RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md, section F.

| file | |
|---|---|
| `PROMPT.md` | the brief the agent was given, verbatim |
| `REPORT.md` | the agent's final report, verbatim |
| `app/` | everything the agent wrote in the clean room's `/home/dev/app` (its `.bot_modules` and its `dist/` executable left out): the application, its tests and scripts, `NOTES.md` (its development log), `evidence/` |
| `trace.log` | every command the agent ran in the clean room, with its full output and exit status, as the wrapper recorded it |
| `commands.txt` | the same commands, one line each |

The environment: the clean-room image (`../../Dockerfile`), started by
`tools/cleanroom.sh start` with only `/home/dev/inputs/botlish` (the
single-file compiler, sha256 f27e9d2c...) and
`/home/dev/inputs/raven-0.3.0.botpkg` (sha256 927f7850..., the release
candidate the milestone packed before the experiment; its fixes are
raven 0.3.1), no network, nothing mounted. The agent reached it only
through the wrapper `cr` (`docker exec` as `dev`, appending to
`trace.log`).

`evidence/*.png` and `evidence/main-run.log` were last written by the
milestone's own rerun of the agent's `run-test.sh` and
`run-desktop-test.sh` after the agent finished (both passed); the
`*.zoom.txt` text renderings are the agent's.

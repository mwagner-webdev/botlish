// game_core.cpp -- the host harness of the generated core layer of the 2048
// package (BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md, "Native ABI
// ownership", "Thread affinity and lifecycle"): the generator's
// cpp/BotlishGameCore.cpp, compiled unchanged on the Linux host against the
// host build of the same Botlish library (whose header is byte-identical to
// the Android one's), driven without any JavaScript engine.
//
//   game_core play SEED DIRECTIONS   one snapshot per line: the new game, then
//                                    one per move (DIRECTIONS: digits 0-3)
//   game_core checks                 every contract below, one line each
//   game_core stress N               N games of moves, restarts and failures
//
// Each check prints "ok NAME" or "FAIL NAME: why"; the exit status is the
// number of failures (capped at 100).
#include "BotlishGameCore.h"

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <limits>
#include <string>
#include <thread>

using botlish_rn_botlishgame::BotlishGameCore;
using botlish_rn_botlishgame::Failure;

static int failures = 0;

static void check(const char *name, bool ok, const std::string &why = "") {
  if (ok) {
    std::printf("ok %s\n", name);
  } else {
    std::printf("FAIL %s: %s\n", name, why.c_str());
    failures++;
  }
}

// The failure F raises, or a Failure whose category is "none".
static Failure failureOf(const std::function<void()> &f) {
  try {
    f();
  } catch (const Failure &e) {
    return e;
  }
  Failure none;
  none.category = "none";
  return none;
}

static std::string describe(const Failure &f) {
  return f.jsClass + " " + f.code + " " + f.category + " " + f.identity + " \"" + f.message + "\"";
}

// A JSON number member of DIAGNOSTICS (no JSON library: the text is ours).
static long long counter(const std::string &json, const char *key) {
  std::string k = std::string("\"") + key + "\": ";
  size_t at = json.find(k);
  if (at == std::string::npos) return -1;
  return std::atoll(json.c_str() + at + k.size());
}

static bool balanced(const std::string &d) {
  return counter(d, "resultsAcquired") == counter(d, "resultsReleased") &&
         counter(d, "errorsAcquired") == counter(d, "errorsReleased");
}

static int play(int argc, char **argv) {
  if (argc < 4) return 2;
  BotlishGameCore core;
  std::string s = core.newGame(std::atof(argv[2]));
  std::printf("%s\n", s.c_str());
  for (const char *d = argv[3]; *d; d++) {
    s = core.move(s, *d - '0');
    std::printf("%s\n", s.c_str());
  }
  return 0;
}

static int checks() {
  BotlishGameCore core;
  std::string s = core.newGame(42);
  check("new-game-snapshot", s.rfind("2048/1 ", 0) == 0, s);
  check("score-number", core.score(s) == 0.0);
  std::string played = s;
  for (int i = 0; i < 10; i++) played = core.move(played, i % 4);
  std::string first = core.diagnostics();
  check("one-instance-per-module", counter(first, "instancesCreated") == 1 && counter(first, "serial") == 1 &&
      counter(first, "calls") == 12, first);

  // Declared errors keep their canonical identities.
  Failure f = failureOf([&] { core.move("2048/1 nonsense", 0); });
  check("declared-invalid-snapshot", f.category == "declared" && f.identity == "InvalidSnapshot" && f.jsClass == "Error" &&
      f.code == "BOTLISH_DECLARED", describe(f));
  f = failureOf([&] { core.move(s, 7); });
  check("declared-invalid-direction", f.category == "declared" && f.identity == "InvalidDirection", describe(f));
  f = failureOf([&] { core.place(s, 9, 0, 2); });
  check("declared-invalid-placement", f.identity == "InvalidPlacement", describe(f));
  std::string empty = "2048/1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0";
  std::string placed = core.place(empty, 1, 2, 4);
  f = failureOf([&] { core.place(placed, 1, 2, 2); });
  check("declared-namespaced-identity", f.category == "declared" && f.identity == "game2048::CellOccupied", describe(f));
  check("declared-method", f.method == "place" && f.message.rfind("place: ", 0) == 0, describe(f));

  // Numbers: never rounded, never NaN, never beyond 2^53 - 1.
  f = failureOf([&] { core.newGame(1.5); });
  check("int-fraction-refused", f.jsClass == "RangeError" && f.code == "BOTLISH_ARGUMENT_RANGE" && f.category == "argument", describe(f));
  f = failureOf([&] { core.newGame(std::numeric_limits<double>::quiet_NaN()); });
  check("int-nan-refused", f.jsClass == "RangeError" && f.identity == "ARGUMENT-NOT-SAFE-INTEGER", describe(f));
  f = failureOf([&] { core.newGame(std::numeric_limits<double>::infinity()); });
  check("int-infinity-refused", f.jsClass == "RangeError", describe(f));
  f = failureOf([&] { core.newGame(-std::numeric_limits<double>::infinity()); });
  check("int-negative-infinity-refused", f.jsClass == "RangeError", describe(f));
  f = failureOf([&] { core.newGame(9007199254740992.0); });
  check("int-unsafe-refused", f.jsClass == "RangeError", describe(f));
  check("int-safe-limit-accepted", core.newGame(9007199254740991.0).rfind("2048/1 ", 0) == 0);
  check("int-negative-zero", core.newGame(-0.0) == core.newGame(0.0));
  check("int-negative-seed", core.newGame(-1).rfind("2048/1 ", 0) == 0);

  // Strings: lengths, never NUL termination; UTF-8 checked by the library.
  std::string nul = s;
  nul.insert(7, 1, '\0');
  f = failureOf([&] { core.move(nul, 0); });
  check("string-embedded-nul-crosses", f.identity == "InvalidSnapshot", describe(f));
  f = failureOf([&] { core.move(std::string("2048/1 \xff\xfe", 9), 0); });
  check("string-invalid-utf8-boundary", f.category == "boundary" && f.code == "BOTLISH_BOUNDARY", describe(f));
  f = failureOf([&] { core.move("", 0); });
  check("string-empty", f.identity == "InvalidSnapshot", describe(f));
  f = failureOf([&] { core.move(std::string(1 << 20, '9'), 0); });
  check("string-large", f.identity == "InvalidSnapshot", describe(f));

  // Ownership: every owned result and error released.
  std::string d = core.diagnostics();
  check("ownership-balanced", balanced(d), d);
  check("ownership-errors-counted", counter(d, "errorsAcquired") == 8, d);

  // Thread affinity: the instance belongs to this thread.
  Failure other;
  std::thread([&] { other = failureOf([&] { core.score(s); }); }).join();
  check("wrong-thread-refused", other.category == "invocation" && other.identity == "WRONG-THREAD" && other.jsClass == "Error",
      describe(other));
  check("owner-thread-still-works", core.score(s) == 0.0);

  // Lifecycle: a module destroyed on its thread destroys its instance.
  long long destroyedBefore = counter(core.diagnostics(), "instancesDestroyed");
  {
    BotlishGameCore local;
    local.newGame(1);
  }
  check("destroyed-on-owner-thread", counter(core.diagnostics(), "instancesDestroyed") == destroyedBefore + 1, core.diagnostics());

  // A module destroyed on another thread: orphaned, never destroyed there;
  // its own thread destroys it at its next call.
  auto *moved = new BotlishGameCore();
  moved->newGame(2);
  long long orphanedBefore = counter(core.diagnostics(), "orphaned");
  long long reapedBefore = counter(core.diagnostics(), "reapedOnCall");
  destroyedBefore = counter(core.diagnostics(), "instancesDestroyed");
  std::thread([&] { delete moved; }).join();
  d = core.diagnostics();
  check("foreign-destruction-orphans", counter(d, "orphaned") == orphanedBefore + 1 &&
      counter(d, "instancesDestroyed") == destroyedBefore, d);
  core.score(s);
  d = core.diagnostics();
  check("orphan-reaped-on-owner-call", counter(d, "reapedOnCall") == reapedBefore + 1 &&
      counter(d, "instancesDestroyed") == destroyedBefore + 1, d);

  // A thread that ends before its module: the instance is destroyed at the
  // thread's exit, on that thread; the module, destroyed later anywhere,
  // destroys nothing twice.
  BotlishGameCore *early = nullptr;
  std::thread([&] {
    early = new BotlishGameCore();
    early->newGame(3);
  }).join();
  d = core.diagnostics();
  long long atExit = counter(d, "reapedAtExit");
  check("reaped-at-thread-exit", atExit >= 1, d);
  destroyedBefore = counter(d, "instancesDestroyed");
  f = failureOf([&] { early->score(s); });
  check("dead-owner-refused", f.category == "invocation" && f.identity == "INSTANCE-GONE", describe(f));
  delete early;
  d = core.diagnostics();
  check("no-double-destroy", counter(d, "instancesDestroyed") == destroyedBefore && counter(d, "destroyFailed") == 0, d);

  // Invalidation: no later call succeeds.
  BotlishGameCore gone;
  gone.newGame(4);
  gone.invalidate();
  f = failureOf([&] { gone.newGame(5); });
  check("invalidated-refused", f.category == "invocation" && f.identity == "INVALIDATED", describe(f));
  gone.invalidate();
  d = core.diagnostics();
  check("double-invalidate-harmless", counter(d, "destroyFailed") == 0, d);

  // Several modules on one thread: independent instances.
  BotlishGameCore a, b;
  check("independent-instances", a.newGame(9) == b.newGame(9));
  d = core.diagnostics();
  check("final-ownership-balanced", balanced(d), d);
  return failures > 100 ? 100 : failures;
}

static int stress(int n) {
  std::string first;
  for (int g = 0; g < n; g++) {
    BotlishGameCore core;
    std::string s = core.newGame(g);
    for (int m = 0; m < 200; m++) {
      s = core.move(s, (m * 7 + g) % 4);
      if (m % 50 == 0) failureOf([&] { core.move("broken", 0); });
    }
    if (g == 0) first = s;
    std::printf("%d %s\n", g, s.c_str());
  }
  BotlishGameCore core;
  std::string d = core.diagnostics();
  std::printf("diagnostics %s\n", d.c_str());
  return balanced(d) ? 0 : 1;
}

int main(int argc, char **argv) {
  if (argc >= 2 && !std::strcmp(argv[1], "play")) return play(argc, argv);
  if (argc >= 2 && !std::strcmp(argv[1], "checks")) return checks();
  if (argc >= 3 && !std::strcmp(argv[1], "stress")) return stress(std::atoi(argv[2]));
  std::fprintf(stderr, "usage: game_core play SEED DIRECTIONS | checks | stress N\n");
  return 2;
}

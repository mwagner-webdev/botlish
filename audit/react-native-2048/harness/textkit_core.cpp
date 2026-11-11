// textkit_core.cpp -- the host harness of the generated core layer of the
// second, unrelated library (BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md,
// "An independent second library"): the generator's
// cpp/BotlishTextkitCore.cpp, compiled unchanged against the host build of
// examples/react-native/textkit/textkit.bot -- and, linked with the 2048
// core too, both libraries' cores in one process (their namespaces, symbols
// and instances apart).
//
//   textkit_core checks     every contract below, one line each
//
// Each check prints "ok NAME" or "FAIL NAME: why"; the exit status is the
// number of failures.
#include "BotlishTextkitCore.h"
#ifdef WITH_GAME
#include "BotlishGameCore.h"
#endif

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <limits>
#include <string>

using botlish_rn_botlishtextkit::BotlishTextkitCore;
using botlish_rn_botlishtextkit::Failure;
using botlish_rn_botlishtextkit::Field;

static int failures = 0;

static void check(const char *name, bool ok, const std::string &why = "") {
  if (ok) {
    std::printf("ok %s\n", name);
  } else {
    std::printf("FAIL %s: %s\n", name, why.c_str());
    failures++;
  }
}

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
  return f.jsClass + " " + f.code + " " + f.category + " " + f.identity + " \"" + f.message + "\" fields " +
         std::to_string(f.fields.size());
}

static long long counter(const std::string &json, const char *key) {
  std::string k = std::string("\"") + key + "\": ";
  size_t at = json.find(k);
  return at == std::string::npos ? -1 : std::atoll(json.c_str() + at + k.size());
}

int main() {
  BotlishTextkitCore t;
  // Int, Bool, str results; Unicode scalars, never bytes or UTF-16 units.
  check("int-result", t.scalarCount("a\xf0\x9f\x98\x80" "b") == 3.0);
  check("str-astral-reversed", t.reversed("h\xc3\xa9llo \xf0\x9f\x98\x80") == "\xf0\x9f\x98\x80 oll\xc3\xa9h");
  check("str-embedded-nul", t.reversed(std::string("a\0b", 3)) == std::string("b\0a", 3));
  check("str-empty", t.reversed("").empty() && t.scalarCount("") == 0.0);
  std::string big(1 << 20, 'x');
  big[0] = 'y';
  std::string back = t.reversed(big);
  check("str-large", back.size() == big.size() && back.back() == 'y' && back[0] == 'x');
  check("bool-true", t.palindrome("a\xc3\xb1" "a") == true);
  check("bool-false", t.palindrome("abc") == false);
  // Float64 arguments and results.
  check("float64-result", t.mean(1.5, 2.0) == 1.75);
  check("float64-negative-zero", !std::signbit(t.mean(-0.0, -0.0)));
  Failure f = failureOf([&] { t.mean(std::numeric_limits<double>::quiet_NaN(), 1); });
  check("float64-nan-refused", f.jsClass == "RangeError" && f.identity == "ARGUMENT-NOT-FINITE", describe(f));
  f = failureOf([&] { t.mean(1, std::numeric_limits<double>::infinity()); });
  check("float64-infinity-refused", f.jsClass == "RangeError", describe(f));
  f = failureOf([&] { t.mean(1.7e308, 1.7e308); });
  check("float64-overflow-declared", f.category == "declared" && f.identity == "NonFiniteFloat", describe(f));
  check("float64-overflow-field-other", f.fields.size() == 1 && f.fields[0].name == "result" && f.fields[0].kind == Field::Other,
      describe(f));
  check("float64-share", std::fabs(t.alnumShare("a\xf0\x9f\x98\x80" "b!") - 0.5) < 1e-12);
  // A declared error's typed payload.
  f = failureOf([&] { t.repeated("ab", 3, 4); });
  bool payload = f.identity == "TooLong" && f.fields.size() == 2;
  for (const auto &field : f.fields) {
    if (field.name == "limit") payload = payload && field.kind == Field::Int && field.integer == 4;
    else if (field.name == "length") payload = payload && field.kind == Field::Int && field.integer == 6;
    else payload = false;
  }
  check("declared-payload-fields", payload, describe(f));
  f = failureOf([&] { t.repeated("", 3, 4); });
  check("declared-no-payload", f.identity == "EmptyText" && f.fields.empty(), describe(f));
  check("str-repeated", t.repeated("ab", 3, 10) == "ababab");
  f = failureOf([&] { t.repeated("ab", 2.5, 10); });
  check("int-fraction-refused", f.jsClass == "RangeError" && f.code == "BOTLISH_ARGUMENT_RANGE", describe(f));
  // A unit result.
  t.requireText("x");
  check("unit-result", true);
  f = failureOf([&] { t.requireText(""); });
  check("unit-declared-error", f.identity == "EmptyText", describe(f));
  std::string d = t.diagnostics();
  check("ownership-balanced", counter(d, "resultsAcquired") == counter(d, "resultsReleased") &&
      counter(d, "errorsAcquired") == counter(d, "errorsReleased") && counter(d, "errorsAcquired") == 4, d);
#ifdef WITH_GAME
  // Both generated cores in one process: separate namespaces, libraries,
  // instances and counters.
  botlish_rn_botlishgame::BotlishGameCore game;
  std::string s = game.newGame(42);
  check("coexist-game", s.rfind("2048/1 ", 0) == 0);
  check("coexist-textkit", t.scalarCount(s) == static_cast<double>(s.size()));
  std::string gd = game.diagnostics();
  check("coexist-separate-counters", counter(gd, "instancesCreated") == 1 && counter(d, "instancesCreated") == 1, gd);
#endif
  return failures;
}

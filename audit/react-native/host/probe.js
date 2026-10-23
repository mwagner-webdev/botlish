// probe.js -- what an app's JS does with the probe module: under the New
// Architecture TurboModuleRegistry.getEnforcing(name) is
// global.__turboModuleProxy(name). Prints one line per call.
const BotlishProbe = globalThis.__turboModuleProxy('BotlishProbe');
if (BotlishProbe == null) throw new Error('BotlishProbe not registered');
function attempt(label, f) {
  try { print(label, '=>', JSON.stringify(f())); }
  catch (e) { print(label, 'threw', e.name, e.code, JSON.stringify(e.message)); }
}
attempt('add(2, 3)', () => BotlishProbe.add(2, 3));
attempt('add(-7, 2**52)', () => BotlishProbe.add(-7, 2 ** 52));
attempt('add(2**53 - 1, 1)', () => BotlishProbe.add(2 ** 53 - 1, 1));
attempt('add(1.5, 1)', () => BotlishProbe.add(1.5, 1));
attempt('add(NaN, 1)', () => BotlishProbe.add(NaN, 1));
attempt('add("2", 1)', () => BotlishProbe.add('2', 1));
attempt('add(1)', () => BotlishProbe.add(1));
attempt('reverse("héllo, wörld")', () => BotlishProbe.reverse('héllo, wörld'));
attempt('reverse("a😀b")', () => BotlishProbe.reverse('a\u{1F600}b'));
attempt('reverse("\\ud800")', () => BotlishProbe.reverse('\ud800'));
attempt('reverse("")', () => BotlishProbe.reverse(''));
attempt('requirePositive(5)', () => BotlishProbe.requirePositive(5));
attempt('requirePositive(-1)', () => BotlishProbe.requirePositive(-1));
attempt('depth(1000)', () => BotlishProbe.depth(1000));
// Deeper than the JS thread's stack: the library's runtime error NATIVE LIMIT
// STACK (a JS Error), never the end of the process, and the instance goes on.
for (const n of [5000, 10000, 20000, 50000, 100000, 10000000]) {
  attempt(`depth(${n})`, () => BotlishProbe.depth(n));
}
attempt('depth(10)', () => BotlishProbe.depth(10));
attempt('same("añb", "añb")', () => BotlishProbe.same('añb', 'añb'));
attempt('same("a", "b")', () => BotlishProbe.same('a', 'b'));
attempt('pick(true, "left", "right")', () => BotlishProbe.pick(true, 'left', 'right'));
attempt('pick(false, "left", "right")', () => BotlishProbe.pick(false, 'left', 'right'));
attempt('pick(1, "left", "right")', () => BotlishProbe.pick(1, 'left', 'right'));
let last = '';
const t0 = Date.now();
for (let i = 0; i < 100000; i++) last = BotlishProbe.reverse('x' + i + 'y');
print('100000 reverse calls, last =>', JSON.stringify(last), 'in', Date.now() - t0, 'ms');

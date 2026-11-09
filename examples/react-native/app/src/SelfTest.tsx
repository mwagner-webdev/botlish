// SelfTest.tsx -- what the CI's Android run reads (BOTLISH-REACT-NATIVE-2048-
// PACKAGE-MILESTONE-1.md, "Android execution"): every line is logged as
// `BOTLISH_RN ...` (logcat tag ReactNativeJS), and the last one is
// `BOTLISH_RN selftest done failures=N`.
//
//   1. the environment: Hermes, React Native's version, the packages;
//   2. the 2048 oracle through the module: newGame(seed), then every move of
//      src/directions.ts, one `oracle I SNAPSHOT` line each -- the CI
//      compares them with the Botlish interpreter's;
//   3. the same game through the hook (useBotlish2048), one `hook I SNAPSHOT`
//      line per state the component rendered;
//   4. the contracts: declared errors and their identities, argument and
//      result checks, strings, the second library, ownership counters;
//   5. timings: calls per second through the module, time inside the C ABI.
import React, { useEffect, useRef, useState } from 'react';
import { Platform, Text, View } from 'react-native';
import * as Game from 'react-native-botlish-game';
import NativeGame from 'react-native-botlish-game/src/NativeBotlishGame';
import * as Text_ from 'react-native-botlish-textkit';

import { now } from './clock';
import { directions, seed } from './directions';
import { useBotlish2048, type Direction } from './useBotlish2048';

const names: Direction[] = ['left', 'right', 'up', 'down'];
let failures = 0;

function log(line: string) {
  console.log(`BOTLISH_RN ${line}`);
}

function expect(name: string, ok: boolean, detail = '') {
  if (!ok) {
    failures++;
  }
  log(`${ok ? 'ok' : 'FAIL'} ${name}${detail ? ` ${detail}` : ''}`);
}

// The error F throws, or null.
function thrown(f: () => unknown): any {
  try {
    f();
  } catch (e) {
    return e;
  }
  return null;
}

// Whether E is a KIND error (of CODE, when given).
function errorOf(e: any, kind: ErrorConstructor | RangeErrorConstructor | TypeErrorConstructor, code?: string): boolean {
  const c = e?.code;
  return e instanceof kind && (code === undefined || c === code);
}

function describe(e: any): string {
  return e === null ? 'nothing thrown' : `${e.name} ${e.code} ${e.category ?? ''} ${e.identity ?? ''} ${JSON.stringify(e.message)}`;
}

function environment() {
  const hermes = (globalThis as any).HermesInternal != null;
  const version = (Platform.constants as any).reactNativeVersion;
  log(`env hermes=${hermes} reactNative=${version.major}.${version.minor}.${version.patch} os=${Platform.OS} api=${Platform.Version}`);
  log(`env game ${JSON.stringify(Game.library)}`);
  log(`env textkit ${JSON.stringify(Text_.library)}`);
  expect('env-hermes', hermes);
  expect('env-native-module', NativeGame != null);
  // The first call creates the module's Botlish instance on this thread.
  const t0 = now();
  Game.newGame(1);
  const t1 = now();
  Game.newGame(1);
  const t2 = now();
  Text_.scalarCount('a');
  const t3 = now();
  log(`timing first call ${(t1 - t0).toFixed(3)} ms (the game instance created), second ${(t2 - t1).toFixed(3)} ms; textkit's first ${(t3 - t2).toFixed(3)} ms`);
}

function oracle(): string[] {
  const states: string[] = [];
  let s = Game.newGame(seed);
  states.push(s);
  log(`oracle 0 ${s}`);
  for (let i = 0; i < directions.length; i++) {
    s = Game.move(s, Number(directions[i]));
    states.push(s);
    log(`oracle ${i + 1} ${s}`);
  }
  return states;
}

function contracts() {
  const s = Game.newGame(7);
  let e = thrown(() => Game.move('2048/1 nonsense', 0));
  expect('declared-invalid-snapshot', e instanceof Game.BotlishError && e.category === 'declared' && e.identity === 'InvalidSnapshot' && e.code === 'BOTLISH_DECLARED', describe(e));
  e = thrown(() => Game.move(s, 7));
  expect('declared-invalid-direction', Game.isBotlishError(e, 'InvalidDirection'), describe(e));
  const empty = '2048/1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0';
  const placed = Game.place(empty, 1, 2, 4);
  e = thrown(() => Game.place(placed, 1, 2, 2));
  expect('declared-namespaced-identity', Game.isBotlishError(e, 'game2048::CellOccupied') && e.method === 'place' && e.library === 'game', describe(e));
  expect('declared-errors-listed', Game.declaredErrors.place.join(',') === 'InvalidPlacement,InvalidSnapshot,game2048::CellOccupied');
  // The win and the end, decided by the library.
  const won = Game.move('2048/1 0 0 0 0 0 0 1024 1024 0 0 0 0 0 0 0 0 0 0 0 0 0 0', 0);
  expect('win', won.split(' ')[6] === '1' && won.split(' ')[2] === '2048' && won.split(' ')[7] === '2048', won);
  const over = Game.move('2048/1 7 100 10 1 0 0 2 4 2 4 4 2 4 2 8 16 8 16 32 16 8 0', 1);
  expect('game-over', over.split(' ')[5] === '1', over);
  const stuck = Game.move(over, 0);
  expect('game-over-no-change', stuck.split(' ')[4] === '0' && stuck.split(' ').slice(7).join(' ') === over.split(' ').slice(7).join(' '), stuck);
  // A snapshot whose facts are not its board's is refused.
  e = thrown(() => Game.move('2048/1 0 0 0 0 1 0 1024 1024 0 0 0 0 0 0 0 0 0 0 0 0 0 0', 0));
  expect('snapshot-facts-checked', Game.isBotlishError(e, 'InvalidSnapshot'), describe(e));
  // Arguments, checked before the library sees them.
  e = thrown(() => Game.newGame(1.5));
  expect('int-fraction', errorOf(e, RangeError, 'BOTLISH_ARGUMENT_RANGE'), describe(e));
  e = thrown(() => Game.newGame(NaN));
  expect('int-nan', errorOf(e, RangeError), describe(e));
  e = thrown(() => Game.newGame(Infinity));
  expect('int-infinity', errorOf(e, RangeError), describe(e));
  e = thrown(() => Game.newGame(-Infinity));
  expect('int-negative-infinity', errorOf(e, RangeError), describe(e));
  e = thrown(() => Game.newGame(2 ** 53));
  expect('int-unsafe', errorOf(e, RangeError), describe(e));
  expect('int-safe-limit', Game.newGame(2 ** 53 - 1).startsWith('2048/1 '));
  e = thrown(() => Game.newGame('1' as any));
  expect('int-wrong-type', errorOf(e, TypeError, 'BOTLISH_ARGUMENT_TYPE'), describe(e));
  e = thrown(() => Game.move(null as any, 0));
  expect('null-refused', errorOf(e, TypeError, 'BOTLISH_ARGUMENT_TYPE'), describe(e));
  e = thrown(() => (Game.newGame as any)());
  expect('missing-argument', errorOf(e, TypeError, 'BOTLISH_ARGUMENT_COUNT'), describe(e));
  e = thrown(() => (Game.newGame as any)(1, 2));
  expect('extra-argument', errorOf(e, TypeError, 'BOTLISH_ARGUMENT_COUNT'), describe(e));
  e = thrown(() => (Game as any).noSuchMethod(1));
  expect('unknown-method', errorOf(e, TypeError), describe(e));
  // The native module itself, bypassing index.ts: its C++ checks hold too.
  e = thrown(() => NativeGame!.newGame(1.5));
  expect('native-int-fraction', errorOf(e, RangeError, 'BOTLISH_ARGUMENT_RANGE'), describe(e));
  e = thrown(() => NativeGame!.move(s, 9));
  expect('native-declared', errorOf(e, Error) && e.name === 'BotlishError' && e.identity === 'InvalidDirection' && e.category === 'declared', describe(e));
  e = thrown(() => (NativeGame as any).newGame());
  expect('native-missing-argument', errorOf(e, Error), describe(e));
  // Strings.
  e = thrown(() => Game.move(s.slice(0, 7) + '\u0000' + s.slice(7), 0));
  expect('string-embedded-nul', Game.isBotlishError(e, 'InvalidSnapshot'), describe(e));
  e = thrown(() => Game.move('', 0));
  expect('string-empty', Game.isBotlishError(e, 'InvalidSnapshot'), describe(e));
  e = thrown(() => Game.move('9'.repeat(1 << 20), 0));
  expect('string-large', Game.isBotlishError(e, 'InvalidSnapshot'), describe(e));
  // The second library: every boundary type.
  expect('textkit-int', Text_.scalarCount('a😀b') === 3);
  expect('textkit-astral', Text_.reversed('héllo 😀') === '😀 olléh');
  expect('textkit-nul', Text_.reversed('a\u0000b') === 'b\u0000a');
  expect('textkit-empty', Text_.reversed('') === '');
  const big = 'y' + 'x'.repeat((1 << 20) - 1);
  const back = Text_.reversed(big);
  expect('textkit-large', back.length === big.length && back.endsWith('y'));
  expect('textkit-lone-surrogate', Text_.reversed('a\uD800') === '�a', JSON.stringify(Text_.reversed('a\uD800')));
  expect('textkit-bool', Text_.palindrome('aña') === true && Text_.palindrome('abc') === false);
  expect('textkit-float64', Text_.mean(1.5, 2) === 1.75);
  e = thrown(() => Text_.mean(1.7e308, 1.7e308));
  expect('textkit-nonfinite', Text_.isBotlishError(e, 'NonFiniteFloat') && e.fields.result === null, describe(e));
  e = thrown(() => Text_.mean(NaN, 1));
  expect('textkit-float64-nan', errorOf(e, RangeError), describe(e));
  e = thrown(() => Text_.repeated('ab', 3, 4));
  expect('textkit-payload', Text_.isBotlishError(e, 'TooLong') && e.fields.limit === 4 && e.fields.length === 6, describe(e) + ' ' + JSON.stringify(e?.fields));
  e = thrown(() => Text_.requireText(''));
  expect('textkit-unit-error', Text_.isBotlishError(e, 'EmptyText'), describe(e));
  expect('textkit-unit', Text_.requireText('x') === undefined);
  expect('textkit-not-game-error', !Game.isBotlishError(e) && e instanceof Text_.BotlishError);
}

function timings() {
  const before = Game.diagnostics().process;
  let s = Game.newGame(1);
  const n = 2000;
  const t0 = now();
  for (let i = 0; i < n; i++) {
    s = Game.move(s, i % 4);
    if (Game.newGame(1) === '' || s === '') {
      break;
    }
  }
  const t1 = now();
  const after = Game.diagnostics().process;
  const calls = after.calls - before.calls;
  const native = (after.nativeNanos - before.nativeNanos) / 1e3 / calls;
  const total = ((t1 - t0) * 1e3) / calls;
  log(`timing game ${calls} calls: ${total.toFixed(2)} us per call from JavaScript, ${native.toFixed(2)} us of it in the C ABI, ${(total - native).toFixed(2)} us JSI and adapter`);
  const t2 = now();
  for (let i = 0; i < 10000; i++) {
    Text_.scalarCount('abc');
  }
  // now() is in milliseconds: microseconds per call over 10,000 calls.
  log(`timing textkit 10000 scalarCount calls: ${(((now() - t2) * 1e3) / 10000).toFixed(2)} us per call`);
}

function ownership() {
  for (const [name, d] of [['game', Game.diagnostics()], ['textkit', Text_.diagnostics()]] as const) {
    const p = d.process;
    log(`diagnostics ${name} ${JSON.stringify(d)}`);
    expect(`ownership-${name}`, p.resultsAcquired === p.resultsReleased && p.errorsAcquired === p.errorsReleased, JSON.stringify(p));
    expect(`thread-${name}`, d.module.created && d.module.ownerThread === d.thread, `owner ${d.module.ownerThread} caller ${d.thread}`);
  }
}

// The oracle again, through the hook: each move is made in an effect after
// the previous state rendered, and every rendered state is logged.
function HookDriver({ expected, onDone }: { expected: string[]; onDone: (ok: boolean) => void }) {
  const step = useRef(0);
  const mismatches = useRef(0);
  const game = useBotlish2048({ seed });
  const text = game.snapshot?.text ?? null;
  useEffect(() => {
    if (text === null) {
      return;
    }
    const i = step.current;
    log(`hook ${i} ${text}`);
    if (text !== expected[i]) {
      mismatches.current++;
    }
    if (i < directions.length) {
      step.current = i + 1;
      game.move(names[Number(directions[i])]);
    } else {
      onDone(mismatches.current === 0 && i === expected.length - 1);
    }
    // One move per rendered state.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [game.snapshot]);
  return null;
}

export default function SelfTest() {
  const [status, setStatus] = useState('running');
  const [expected, setExpected] = useState<string[] | null>(null);
  useEffect(() => {
    try {
      environment();
      const states = oracle();
      contracts();
      timings();
      setExpected(states);
    } catch (e) {
      expect('selftest-threw', false, describe(e));
      log(`selftest done failures=${failures}`);
      setStatus('failed');
    }
  }, []);
  const done = (ok: boolean) => {
    expect('hook-matches-module', ok);
    ownership();
    log(`selftest done failures=${failures}`);
    setStatus(failures === 0 ? 'passed' : `failed (${failures})`);
  };
  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
      <Text accessibilityLabel="selftest">Botlish self-test: {status}</Text>
      {expected !== null && status === 'running' ? <HookDriver expected={expected} onDone={done} /> : null}
    </View>
  );
}

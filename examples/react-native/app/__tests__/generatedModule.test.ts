/**
 * The generated package's entry point (react-native-botlish-game/src/
 * index.ts, written by botlish-react-native): arguments are checked before
 * the native module sees them, and what the native module throws becomes a
 * BotlishError -- tested with the native module replaced by a recorder.
 *
 * @format
 */
const native = {
  calls: [] as string[],
  newGame(seed: number) {
    native.calls.push(`newGame ${seed}`);
    return '2048/1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0';
  },
  move(_state: string, direction: number): string {
    native.calls.push(`move ${direction}`);
    if (direction === 3) {
      throw new TypeError('not a BotlishError');
    }
    const e = new Error('move: the direction is no direction') as any;
    e.name = 'BotlishError';
    e.code = 'BOTLISH_DECLARED';
    e.category = 'declared';
    e.identity = 'InvalidDirection';
    e.method = 'move';
    e.fields = {};
    throw e;
  },
  score() {
    return 2 ** 53 - 1;
  },
  place() {
    return '';
  },
  botlishDiagnostics() {
    return '{"process": {"calls": 0}}';
  },
};

jest.mock('react-native-botlish-game/src/NativeBotlishGame', () => ({ __esModule: true, default: native }));

import * as Game from 'react-native-botlish-game';

function thrown(f: () => unknown): any {
  try {
    f();
  } catch (e) {
    return e;
  }
  return null;
}

beforeEach(() => {
  native.calls = [];
});

test('a safe integer crosses; -0 is 0', () => {
  Game.newGame(2 ** 53 - 1);
  Game.newGame(-0);
  expect(native.calls).toEqual([`newGame ${2 ** 53 - 1}`, 'newGame 0']);
});

test.each([1.5, NaN, Infinity, -Infinity, 2 ** 53, -(2 ** 53)])('the int argument %p is a RangeError, never sent', x => {
  const e = thrown(() => Game.newGame(x));
  expect(e).toBeInstanceOf(RangeError);
  expect(e.code).toBe('BOTLISH_ARGUMENT_RANGE');
  expect(native.calls).toEqual([]);
});

test.each(['1', null, undefined, true, {}])('the int argument %p is a TypeError, never sent', x => {
  const e = thrown(() => Game.newGame(x as any));
  expect(e).toBeInstanceOf(TypeError);
  expect(e.code).toBe('BOTLISH_ARGUMENT_TYPE');
  expect(native.calls).toEqual([]);
});

test('a missing or extra argument is a TypeError', () => {
  expect(thrown(() => (Game.newGame as any)()).code).toBe('BOTLISH_ARGUMENT_COUNT');
  expect(thrown(() => (Game.newGame as any)(1, 2)).code).toBe('BOTLISH_ARGUMENT_COUNT');
  expect(thrown(() => (Game.move as any)('x')).code).toBe('BOTLISH_ARGUMENT_COUNT');
  expect(native.calls).toEqual([]);
});

test('a string argument must be a string', () => {
  const e = thrown(() => Game.move(42 as any, 0));
  expect(e).toBeInstanceOf(TypeError);
  expect(e.code).toBe('BOTLISH_ARGUMENT_TYPE');
});

test('a native BotlishError keeps its identity and becomes the class', () => {
  const e = thrown(() => Game.move('s', 1));
  expect(e).toBeInstanceOf(Game.BotlishError);
  expect(Game.isBotlishError(e, 'InvalidDirection')).toBe(true);
  expect(e.category).toBe('declared');
  expect(e.code).toBe('BOTLISH_DECLARED');
  expect(e.method).toBe('move');
  expect(e.library).toBe('game');
  expect(e.message).toBe('move: the direction is no direction');
});

test('any other native error passes unchanged', () => {
  const e = thrown(() => Game.move('s', 3));
  expect(e).toBeInstanceOf(TypeError);
  expect(e).not.toBeInstanceOf(Game.BotlishError);
});

test('the declared errors and the metadata are the manifest\'s', () => {
  expect(Game.declaredErrors.move).toEqual(['InvalidDirection', 'InvalidSnapshot']);
  expect(Game.library.name).toBe('game');
  expect(Game.library.abis).toEqual(['arm64-v8a']);
  expect(Game.library.sharedSha256).toMatch(/^[0-9a-f]{64}$/);
});

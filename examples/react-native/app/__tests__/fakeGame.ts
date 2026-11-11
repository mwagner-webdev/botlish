// fakeGame.ts -- a stand-in for the Botlish library in Jest (no native
// module runs there). It is no 2048: each snapshot records how it was made,
// so a test sees exactly which native calls the hook made, in which order,
// from which snapshot. The real rules are tested against the Botlish
// interpreter (tests/react-native-package.test, the Android self-test).
export const calls: string[] = [];

/** Set by a test component while it renders: a native call then is a
 * defect (React may render any number of times). */
export const state = { rendering: false };

function enter(what: string) {
  if (state.rendering) {
    throw new Error(`${what} called while rendering`);
  }
}

function snapshot(rng: number, moves: number, cells: number[]): string {
  return ['2048/1', rng, moves * 4, moves, moves > 0 ? 1 : 0, 0, 0, ...cells].join(' ');
}

export function reset() {
  calls.length = 0;
  state.rendering = false;
}

export function newGame(seed: number): string {
  enter('newGame');
  calls.push(`newGame ${seed}`);
  const cells = new Array(16).fill(0);
  cells[0] = 2;
  return snapshot(seed, 0, cells);
}

export function move(text: string, direction: number): string {
  enter('move');
  calls.push(`move ${direction} from ${text.split(' ')[3]}`);
  if (typeof direction !== 'number' || direction < 0 || direction > 3) {
    const e = new Error('move: InvalidDirection');
    e.name = 'BotlishError';
    throw e;
  }
  const f = text.split(' ').map(Number);
  const moves = f[3] + 1;
  const cells = f.slice(7);
  cells[moves % 16] = 2;
  return snapshot(f[1], moves, cells);
}

// snapshot.ts -- reads a 2048 snapshot (examples/react-native/2048/game.bot)
// for presentation. A snapshot is the game the Botlish library returned:
//
//     2048/1 RNG SCORE MOVES CHANGED OVER WON C0 C1 ... C15
//
// This module only reads it: every rule -- moves, merges, scoring, spawning,
// the end and the win -- is the library's. A text that is not a version 1
// snapshot is an error here, never repaired.

export type Snapshot = {
  /** The text the library returned, which the next move is given. */
  readonly text: string;
  /** The sixteen cells, row by row: 0 an empty cell, else its tile. */
  readonly cells: readonly number[];
  readonly score: number;
  /** The number of moves that changed the board. */
  readonly moves: number;
  /** Whether the last move changed the board (a new game's did not). */
  readonly changed: boolean;
  readonly gameOver: boolean;
  /** Whether a tile of 2048 or more is on the board. */
  readonly won: boolean;
};

export function readSnapshot(text: string): Snapshot {
  const fields = text.split(' ');
  if (fields.length !== 23 || fields[0] !== '2048/1') {
    throw new Error(`not a 2048/1 snapshot: ${JSON.stringify(text)}`);
  }
  const numbers = fields.slice(1).map(f => {
    if (!/^(0|[1-9][0-9]*)$/.test(f)) {
      throw new Error(`not a 2048/1 snapshot: ${JSON.stringify(text)}`);
    }
    return Number(f);
  });
  const [, score, moves, changed, over, won] = numbers;
  return {
    text,
    cells: numbers.slice(6),
    score,
    moves,
    changed: changed === 1,
    gameOver: over === 1,
    won: won === 1,
  };
}

/** The cells as four rows of four. */
export function rows(cells: readonly number[]): number[][] {
  return [0, 1, 2, 3].map(r => cells.slice(r * 4, r * 4 + 4));
}

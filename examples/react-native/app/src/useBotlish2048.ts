// useBotlish2048.ts -- the 2048 game as React state, played by the Botlish
// library through its generated React Native module (react-native-botlish-
// game). The hook holds the game's latest snapshot and asks the library for
// the next one; it computes nothing of the rules itself.
//
// React correctness:
//   * no native call happens while rendering: the first game is made in an
//     effect, every move and restart in the event that asks for it;
//   * the latest snapshot is also kept in a ref, so that moves made before
//     React renders again (fast swipes) each continue from the one before,
//     exactly once -- never from a stale snapshot, never twice;
//   * an effect that runs twice (React's Strict Mode) makes one game;
//   * unmounting destroys nothing native: the module and its Botlish
//     instance are React Native's and outlive any component.
import { useCallback, useEffect, useRef, useState } from 'react';
import * as Game from 'react-native-botlish-game';

import { readSnapshot, type Snapshot } from './snapshot';

export type Direction = 'left' | 'right' | 'up' | 'down';

/** The library's direction codes. */
export const directionCodes: Record<Direction, number> = { left: 0, right: 1, up: 2, down: 3 };

export type Botlish2048 = {
  /** The sixteen cells, row by row (empty while the first game is made). */
  board: readonly number[];
  score: number;
  moves: number;
  gameOver: boolean;
  won: boolean;
  /** Whether the last move changed the board. */
  changed: boolean;
  /** The seed of the game in play. */
  seed: number;
  snapshot: Snapshot | null;
  /** The last failure, until the next successful move or restart. */
  error: Error | null;
  move: (direction: Direction) => Snapshot | null;
  restart: (seed?: number) => Snapshot | null;
};

export type Options = {
  seed?: number;
  /** A snapshot to begin from instead of a new game (a puzzle, a test);
   * the library checks it at the first move. */
  start?: string;
  /** Called with every snapshot the library returns (logging, tests). */
  onSnapshot?: (snapshot: Snapshot, cause: string) => void;
};

export function useBotlish2048(options: Options = {}): Botlish2048 {
  const initialSeed = options.seed ?? 2048;
  const start = useRef(options.start);
  const [snapshot, setSnapshot] = useState<Snapshot | null>(null);
  const [seed, setSeed] = useState(initialSeed);
  const [error, setError] = useState<Error | null>(null);
  const latest = useRef<Snapshot | null>(null);
  const seedRef = useRef(initialSeed);
  const onSnapshot = useRef(options.onSnapshot);
  onSnapshot.current = options.onSnapshot;

  const publish = useCallback((next: Snapshot, cause: string) => {
    latest.current = next;
    setSnapshot(next);
    setError(null);
    onSnapshot.current?.(next, cause);
    return next;
  }, []);

  const restart = useCallback(
    (nextSeed?: number) => {
      const s = nextSeed ?? seedRef.current + 1;
      try {
        const next = readSnapshot(Game.newGame(s));
        seedRef.current = s;
        setSeed(s);
        return publish(next, `restart ${s}`);
      } catch (e) {
        setError(e as Error);
        return null;
      }
    },
    [publish],
  );

  useEffect(() => {
    if (latest.current === null) {
      if (start.current !== undefined) {
        try {
          publish(readSnapshot(start.current), 'start');
        } catch (e) {
          setError(e as Error);
        }
      } else {
        restart(initialSeed);
      }
    }
    // The first game only: later seeds come from restart().
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const move = useCallback(
    (direction: Direction) => {
      const current = latest.current;
      if (current === null) {
        return null;
      }
      try {
        return publish(readSnapshot(Game.move(current.text, directionCodes[direction])), `move ${direction}`);
      } catch (e) {
        setError(e as Error);
        return null;
      }
    },
    [publish],
  );

  return {
    board: snapshot?.cells ?? [],
    score: snapshot?.score ?? 0,
    moves: snapshot?.moves ?? 0,
    gameOver: snapshot?.gameOver ?? false,
    won: snapshot?.won ?? false,
    changed: snapshot?.changed ?? false,
    seed,
    snapshot,
    error,
    move,
    restart,
  };
}

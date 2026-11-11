/**
 * The hook's React contract (src/useBotlish2048.ts), with the Botlish
 * module replaced by __tests__/fakeGame.ts: no native call while rendering,
 * one game however often effects run, every move applied once and from the
 * latest snapshot, nothing native done on unmount.
 *
 * @format
 */
import React, { StrictMode } from 'react';
import ReactTestRenderer from 'react-test-renderer';

import * as fake from './fakeGame';
import { readSnapshot } from '../src/snapshot';
import { useBotlish2048, type Botlish2048 } from '../src/useBotlish2048';

jest.mock('react-native-botlish-game', () => require('./fakeGame'));

let renderCalls: number[] = [];

function Probe({ onGame, seed = 5 }: { onGame: (g: Botlish2048) => void; seed?: number }) {
  renderCalls.push(fake.calls.length);
  fake.state.rendering = true;
  try {
    const game = useBotlish2048({ seed });
    onGame(game);
  } finally {
    fake.state.rendering = false;
  }
  return null;
}

function mount(element: React.ReactElement) {
  let renderer: ReactTestRenderer.ReactTestRenderer;
  ReactTestRenderer.act(() => {
    renderer = ReactTestRenderer.create(element);
  });
  return renderer!;
}

beforeEach(() => {
  fake.reset();
  renderCalls = [];
});

test('the first game is made after the first render, not during it', () => {
  let game: Botlish2048 | null = null;
  mount(<Probe onGame={g => (game = g)} />);
  expect(renderCalls[0]).toBe(0);
  expect(fake.calls).toEqual(['newGame 5']);
  expect(game!.board).toHaveLength(16);
  expect(game!.seed).toBe(5);
});

test('Strict Mode makes one game', () => {
  let game: Botlish2048 | null = null;
  mount(
    <StrictMode>
      <Probe onGame={g => (game = g)} />
    </StrictMode>,
  );
  expect(fake.calls).toEqual(['newGame 5']);
  expect(game!.snapshot).not.toBeNull();
});

test('rerendering calls nothing native and keeps the game', () => {
  let game: Botlish2048 | null = null;
  const r = mount(<Probe onGame={g => (game = g)} />);
  ReactTestRenderer.act(() => {
    game!.move('left');
  });
  const text = game!.snapshot!.text;
  for (let i = 0; i < 5; i++) {
    ReactTestRenderer.act(() => {
      r.update(<Probe onGame={g => (game = g)} />);
    });
  }
  expect(fake.calls).toEqual(['newGame 5', 'move 0 from 0']);
  expect(game!.snapshot!.text).toBe(text);
});

test('moves made before React renders again each continue from the one before, once', () => {
  let game: Botlish2048 | null = null;
  mount(<Probe onGame={g => (game = g)} />);
  ReactTestRenderer.act(() => {
    game!.move('left');
    game!.move('up');
    game!.move('down');
  });
  expect(fake.calls).toEqual(['newGame 5', 'move 0 from 0', 'move 2 from 1', 'move 3 from 2']);
  expect(game!.moves).toBe(3);
});

test('Strict Mode does not repeat a move', () => {
  let game: Botlish2048 | null = null;
  mount(
    <StrictMode>
      <Probe onGame={g => (game = g)} />
    </StrictMode>,
  );
  ReactTestRenderer.act(() => {
    game!.move('right');
  });
  expect(fake.calls).toEqual(['newGame 5', 'move 1 from 0']);
});

test('restart makes the next seed\'s game; a given seed is kept', () => {
  let game: Botlish2048 | null = null;
  mount(<Probe onGame={g => (game = g)} />);
  ReactTestRenderer.act(() => {
    game!.restart();
  });
  ReactTestRenderer.act(() => {
    game!.restart(100);
  });
  expect(fake.calls).toEqual(['newGame 5', 'newGame 6', 'newGame 100']);
  expect(game!.seed).toBe(100);
  expect(game!.moves).toBe(0);
});

test('a failure is shown and changes no state', () => {
  let game: Botlish2048 | null = null;
  mount(<Probe onGame={g => (game = g)} />);
  const before = game!.snapshot;
  // A direction the hook has no code for reaches the (fake) library, which
  // refuses it, as the generated module refuses a non-number.
  ReactTestRenderer.act(() => {
    expect(game!.move('nowhere' as any)).toBeNull();
  });
  expect(game!.snapshot).toBe(before);
  expect(game!.error).not.toBeNull();
  ReactTestRenderer.act(() => {
    game!.move('left');
  });
  expect(game!.error).toBeNull();
});

test('unmounting makes no native call', () => {
  const r = mount(<Probe onGame={() => {}} />);
  const before = fake.calls.length;
  ReactTestRenderer.act(() => {
    r.unmount();
  });
  expect(fake.calls.length).toBe(before);
});

test('two consumers play their own games; unmounting one leaves the other', () => {
  let a: Botlish2048 | null = null;
  let b: Botlish2048 | null = null;
  const ra = mount(<Probe onGame={g => (a = g)} seed={1} />);
  mount(<Probe onGame={g => (b = g)} seed={2} />);
  ReactTestRenderer.act(() => {
    a!.move('left');
  });
  ReactTestRenderer.act(() => {
    ra.unmount();
  });
  const before = fake.calls.length;
  ReactTestRenderer.act(() => {
    b!.move('up');
  });
  expect(fake.calls.slice(before)).toEqual(['move 2 from 0']);
  expect(b!.moves).toBe(1);
  expect(fake.calls.filter(c => c.startsWith('newGame'))).toEqual(['newGame 1', 'newGame 2']);
});

test('the snapshot reader reads the library\'s text and refuses anything else', () => {
  const s = readSnapshot('2048/1 7 12 3 1 0 1 2 0 0 0 0 4 0 0 0 0 2048 0 0 0 0 2');
  expect(s.score).toBe(12);
  expect(s.moves).toBe(3);
  expect(s.changed).toBe(true);
  expect(s.gameOver).toBe(false);
  expect(s.won).toBe(true);
  expect(s.cells).toEqual([2, 0, 0, 0, 0, 4, 0, 0, 0, 0, 2048, 0, 0, 0, 0, 2]);
  expect(() => readSnapshot('2048/2 0')).toThrow();
  expect(() => readSnapshot('2048/1 x 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0')).toThrow();
});

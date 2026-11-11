/**
 * Without the native module (any platform but Android arm64-v8a with the
 * New Architecture), every call is a BotlishError of category unavailable:
 * nothing falls back to JavaScript.
 *
 * @format
 */
jest.mock('react-native-botlish-game/src/NativeBotlishGame', () => ({ __esModule: true, default: null }));

import * as Game from 'react-native-botlish-game';

test('no native module, no game', () => {
  let e: any = null;
  try {
    Game.newGame(1);
  } catch (x) {
    e = x;
  }
  expect(e).toBeInstanceOf(Game.BotlishError);
  expect(e.category).toBe('unavailable');
  expect(e.code).toBe('BOTLISH_UNAVAILABLE');
});

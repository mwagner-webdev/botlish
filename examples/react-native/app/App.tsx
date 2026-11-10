// App.tsx -- 2048, played by Botlish (BOTLISH-REACT-NATIVE-2048-PACKAGE-
// MILESTONE-1.md). The rules run in the Botlish native library `game`
// (examples/react-native/2048/game.bot) through its generated React Native
// module; this screen draws the board, reads swipes and buttons, and shows
// the score, the end and the win.
//
// The launch option `mode` (MainActivity passes the intent's extras) picks
// the screen: `play` (the default) or `selftest` (src/SelfTest.tsx, which
// the CI's Android run reads from logcat); `start`, a snapshot, begins the
// game there (the acceptance run's win and game-over positions). `device`
// (plain or gc-stress) is a device build's (android/app/build.gradle,
// -PbotlishDevice): the game shows a Self-test button, whose result is on
// the screen, and says whether the build runs Botlish under GC stress.
import React, { useEffect, useMemo, useRef, useState } from 'react';
import {
  PanResponder,
  Pressable,
  StatusBar,
  StyleSheet,
  Text,
  View,
} from 'react-native';

import { now } from './src/clock';
import SelfTest from './src/SelfTest';
import { rows } from './src/snapshot';
import { type Direction, useBotlish2048 } from './src/useBotlish2048';

const tileColors: Record<number, string> = {
  0: '#cdc1b4',
  2: '#eee4da',
  4: '#ede0c8',
  8: '#f2b179',
  16: '#f59563',
  32: '#f67c5f',
  64: '#f65e3b',
  128: '#edcf72',
  256: '#edcc61',
  512: '#edc850',
  1024: '#edc53f',
  2048: '#edc22e',
};

function Tile({ value }: { value: number }) {
  const background = tileColors[value] ?? '#3c3a32';
  const color = value <= 4 ? '#776e65' : '#f9f6f2';
  const size = value >= 1024 ? 24 : value >= 128 ? 30 : 36;
  return (
    <View style={[styles.tile, { backgroundColor: background }]} accessibilityLabel={`tile ${value}`}>
      {value > 0 ? <Text style={[styles.tileText, { color, fontSize: size }]}>{value}</Text> : null}
    </View>
  );
}

// The direction of a swipe of DX, DY, or null for a tap.
function swipeDirection(dx: number, dy: number): Direction | null {
  if (Math.max(Math.abs(dx), Math.abs(dy)) < 24) {
    return null;
  }
  if (Math.abs(dx) > Math.abs(dy)) {
    return dx > 0 ? 'right' : 'left';
  }
  return dy > 0 ? 'down' : 'up';
}

function Game({ start, device, onSelfTest }: { start?: string; device?: string; onSelfTest?: () => void }) {
  const pending = useRef<{ direction: Direction; at: number } | null>(null);
  const game = useBotlish2048({
    seed: 42,
    start,
    onSnapshot: (s, cause) => console.log(`BOTLISH_RN snapshot ${cause} ${s.text}`),
  });
  const { move } = game;

  // Input to render: from a swipe's release to the commit of its result.
  useEffect(() => {
    const p = pending.current;
    if (p !== null && game.snapshot !== null) {
      pending.current = null;
      console.log(`BOTLISH_RN latency ${p.direction} ${(now() - p.at).toFixed(3)} ms`);
    }
  }, [game.snapshot]);

  const play = useMemo(
    () => (direction: Direction) => {
      pending.current = { direction, at: now() };
      console.log(`BOTLISH_RN input ${direction}`);
      move(direction);
    },
    [move],
  );

  const responder = useMemo(
    () =>
      PanResponder.create({
        onStartShouldSetPanResponder: () => true,
        onMoveShouldSetPanResponder: () => true,
        onPanResponderRelease: (_event, gesture) => {
          const direction = swipeDirection(gesture.dx, gesture.dy);
          if (direction !== null) {
            play(direction);
          }
        },
      }),
    [play],
  );

  return (
    <View style={styles.screen}>
      <View style={styles.header}>
        <Text style={styles.title}>2048</Text>
        <View style={styles.scoreBox}>
          <Text style={styles.scoreLabel}>SCORE</Text>
          <Text style={styles.score} accessibilityLabel="score">
            {game.score}
          </Text>
        </View>
        <Pressable style={styles.button} onPress={() => game.restart()} accessibilityLabel="restart">
          <Text style={styles.buttonText}>New game</Text>
        </Pressable>
      </View>
      <Text style={styles.subtitle}>The rules run in Botlish. Swipe to move.</Text>
      <View style={styles.board} {...responder.panHandlers} accessibilityLabel="board">
        {rows(game.board.length === 16 ? game.board : new Array(16).fill(0)).map((row, r) => (
          <View key={r} style={styles.row}>
            {row.map((value, c) => (
              <Tile key={c} value={value} />
            ))}
          </View>
        ))}
        {game.gameOver ? (
          <View style={styles.overlay} accessibilityLabel="game over">
            <Text style={styles.overlayText}>Game over</Text>
          </View>
        ) : null}
      </View>
      {game.won ? (
        <Text style={styles.won} accessibilityLabel="won">
          2048 reached: you won. Keep going!
        </Text>
      ) : null}
      <View style={styles.arrows}>
        {(['left', 'up', 'down', 'right'] as const).map(d => (
          <Pressable key={d} style={styles.arrow} onPress={() => play(d)} accessibilityLabel={`move ${d}`}>
            <Text style={styles.buttonText}>{{ left: '←', up: '↑', down: '↓', right: '→' }[d]}</Text>
          </Pressable>
        ))}
      </View>
      <Text style={styles.status} accessibilityLabel="status">
        {game.error ? `Error: ${game.error.message}` : `Moves: ${game.moves} · seed ${game.seed}`}
      </Text>
      {onSelfTest !== undefined ? (
        <View style={styles.device}>
          <Text style={styles.status} accessibilityLabel="device build">
            {device === 'gc-stress' ? 'GC-stress build' : 'Device build'}
          </Text>
          <Pressable style={styles.button} onPress={onSelfTest} accessibilityLabel="self-test">
            <Text style={styles.buttonText}>Self-test</Text>
          </Pressable>
        </View>
      ) : null}
    </View>
  );
}

export default function App(props: { mode?: string; start?: string; device?: string }) {
  const [selfTest, setSelfTest] = useState(props.mode === 'selftest');
  const device = props.device === 'plain' || props.device === 'gc-stress' ? props.device : undefined;
  return (
    <>
      <StatusBar barStyle="dark-content" />
      {selfTest ? (
        <SelfTest device={device} onClose={device !== undefined ? () => setSelfTest(false) : undefined} />
      ) : (
        <Game start={props.start} device={device} onSelfTest={device !== undefined ? () => setSelfTest(true) : undefined} />
      )}
    </>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: '#faf8ef', alignItems: 'center', paddingTop: 48 },
  header: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  title: { fontSize: 48, fontWeight: 'bold', color: '#776e65' },
  subtitle: { color: '#776e65', marginVertical: 12 },
  scoreBox: { backgroundColor: '#bbada0', borderRadius: 6, paddingHorizontal: 12, paddingVertical: 4, alignItems: 'center' },
  scoreLabel: { color: '#eee4da', fontSize: 12, fontWeight: 'bold' },
  score: { color: '#ffffff', fontSize: 22, fontWeight: 'bold' },
  button: { backgroundColor: '#8f7a66', borderRadius: 6, paddingHorizontal: 12, paddingVertical: 10 },
  buttonText: { color: '#f9f6f2', fontWeight: 'bold', fontSize: 16 },
  board: { backgroundColor: '#bbada0', borderRadius: 8, padding: 6 },
  row: { flexDirection: 'row' },
  tile: { width: 72, height: 72, margin: 5, borderRadius: 6, alignItems: 'center', justifyContent: 'center' },
  tileText: { fontWeight: 'bold' },
  overlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(238, 228, 218, 0.73)',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 8,
  },
  overlayText: { fontSize: 40, fontWeight: 'bold', color: '#776e65' },
  won: { marginTop: 12, fontSize: 18, fontWeight: 'bold', color: '#f65e3b' },
  arrows: { flexDirection: 'row', gap: 12, marginTop: 16 },
  arrow: { backgroundColor: '#8f7a66', borderRadius: 6, width: 56, height: 48, alignItems: 'center', justifyContent: 'center' },
  status: { marginTop: 12, color: '#776e65' },
  device: { flexDirection: 'row', alignItems: 'center', gap: 12, marginTop: 12 },
});

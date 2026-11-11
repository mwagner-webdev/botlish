/**
 * Device builds (android/app/build.gradle's -PbotlishDevice; App.tsx): the
 * Self-test button under the game, the way back, and the default build --
 * the one the acceptance runs -- without either. The self-test itself is
 * replaced by a stand-in (it needs the native modules: the Android run
 * tests it). digest() is the self-test's comparison with the interpreter.
 *
 * @format
 */
import React from 'react';
import ReactTestRenderer from 'react-test-renderer';

import App from '../App';
import { digest } from '../src/digest';

jest.mock('react-native-botlish-game', () => require('./fakeGame'));
jest.mock('../src/SelfTest', () => {
  const { Pressable, Text } = require('react-native');
  const react = require('react');
  return {
    __esModule: true,
    default: ({ device, onClose }: { device?: string; onClose?: () => void }) =>
      react.createElement(
        Pressable,
        { accessibilityLabel: 'selftest stand-in', onPress: onClose },
        react.createElement(Text, null, `self-test device=${device} back=${onClose !== undefined}`),
      ),
  };
});

// The game logs every snapshot for the Android run; not here.
beforeAll(() => {
  jest.spyOn(console, 'log').mockImplementation(() => {});
});

function mount(element: React.ReactElement) {
  let renderer: ReactTestRenderer.ReactTestRenderer;
  ReactTestRenderer.act(() => {
    renderer = ReactTestRenderer.create(element);
  });
  return renderer!;
}

// The pressable labelled LABEL (its outermost element), or undefined.
function labelled(renderer: ReactTestRenderer.ReactTestRenderer, label: string) {
  return renderer.root.findAll(node => node.props.accessibilityLabel === label && typeof node.props.onPress === 'function')[0];
}

function texts(renderer: ReactTestRenderer.ReactTestRenderer): string {
  return renderer.root
    .findAll(node => (node.type as unknown) === 'Text')
    .map(node => [node.props.children].flat().join(''))
    .join(' | ');
}

function press(renderer: ReactTestRenderer.ReactTestRenderer, label: string) {
  const target = labelled(renderer, label);
  expect(target).toBeDefined();
  ReactTestRenderer.act(() => {
    target.props.onPress();
  });
}

test('the default build has no Self-test button', () => {
  const r = mount(<App />);
  expect(labelled(r, 'self-test')).toBeUndefined();
  expect(texts(r)).not.toMatch(/build/);
  expect(texts(r)).toMatch(/Swipe to move/);
});

test('a value of device that is no device build is ignored', () => {
  const r = mount(<App device="debug" />);
  expect(labelled(r, 'self-test')).toBeUndefined();
});

test('a GC-stress build opens the self-test from the game and goes back', () => {
  const r = mount(<App device="gc-stress" />);
  expect(texts(r)).toMatch(/GC-stress build/);
  press(r, 'self-test');
  expect(texts(r)).toBe('self-test device=gc-stress back=true');
  press(r, 'selftest stand-in');
  expect(texts(r)).toMatch(/Swipe to move/);
  expect(labelled(r, 'self-test')).toBeDefined();
});

test('a plain device build says so', () => {
  const r = mount(<App device="plain" />);
  expect(texts(r)).toMatch(/Device build/);
  press(r, 'self-test');
  expect(texts(r)).toBe('self-test device=plain back=true');
});

test('the self-test launched by the acceptance (mode selftest) has no way back', () => {
  const r = mount(<App mode="selftest" />);
  expect(texts(r)).toBe('self-test device=undefined back=false');
});

test('digest is FNV-1a of the lines joined by newlines', () => {
  expect(digest([])).toBe('811c9dc5');
  expect(digest([''])).toBe('811c9dc5');
  expect(digest(['a'])).toBe('e40c292c');
  expect(digest(['foobar'])).toBe('bf9cf968');
  expect(digest(['a', 'b'])).toBe(digest(['a\nb']));
  expect(digest(['a', 'b'])).not.toBe(digest(['ab']));
});

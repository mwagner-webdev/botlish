// clock.ts -- milliseconds from React Native's high-resolution clock
// (performance.now, Hermes'), else Date's.
export function now(): number {
  const performance = (globalThis as { performance?: { now(): number } }).performance;
  return performance !== undefined ? performance.now() : Date.now();
}

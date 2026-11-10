// digest.ts -- FNV-1a (32 bits) of LINES joined by newlines, as 8 hex
// digits: how the self-test compares the module's 401 snapshots with the
// Botlish interpreter's on a device, where nothing reads its log
// (directions.ts's oracleDigest; tests/react-native-package.test computes the
// interpreter's the same way). The snapshots are ASCII, so a UTF-16 code
// unit is a byte.
export function digest(lines: string[]): string {
  const text = lines.join('\n');
  let h = 0x811c9dc5;
  for (let i = 0; i < text.length; i++) {
    h ^= text.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;
  }
  return h.toString(16).padStart(8, '0');
}

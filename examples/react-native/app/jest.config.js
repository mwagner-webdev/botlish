module.exports = {
  preset: '@react-native/jest-preset',
  // The generated Botlish packages are TypeScript sources: transform them as
  // React Native's own.
  transformIgnorePatterns: ['node_modules/(?!((jest-)?react-native|@react-native(-community)?|react-native-botlish-[a-z0-9-]+)/)'],
  testPathIgnorePatterns: ['/node_modules/', '__tests__/fakeGame.ts'],
};

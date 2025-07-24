// You can override this with:  flutter run --dart-define=SERVER_URL=http://<host>:4000
// const String kServerUrl = String.fromEnvironment(
//   'SERVER_URL',
//   defaultValue: 'http://localhost:4000',
// );

const String kServerUrl = String.fromEnvironment(
  'SERVER_URL',
  defaultValue: 'https://api.deepfake.petaproc.com',
);

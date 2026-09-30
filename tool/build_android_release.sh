#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
if [ ! -f android/key.properties ] || [ ! -f android/upload-keystore.jks ]; then
  echo "Restore the local release signing files from your secure backup." >&2
  exit 1
fi
if [ ! -f config/local.json ]; then
  echo "Create config/local.json from config/local.example.json and set RAPIDAPI_KEY." >&2
  exit 1
fi
flutter_bin="${FLUTTER_BIN:-flutter}"
exec "$flutter_bin" build appbundle --release --dart-define-from-file=config/local.json "$@"

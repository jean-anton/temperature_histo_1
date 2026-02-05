#!/bin/bash

set -e

echo "🛠️ Building Flutter web..."
# flutter build web
flutter clean
flutter pub get
flutter build web  --wasm --release
# flutter build web  --release

# Modifier <base href="/">
if [ ! -d "build/web" ]; then
    echo "❌ Error: build/web directory not found."
    exit 1
fi

firebase deploy
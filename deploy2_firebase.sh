#!/bin/bash

set -e

echo "🛠️ Building Flutter web..."
# flutter build web
flutter clean
flutter pub get
# Build and prepare the FULL app
#flutter build web --dart-define=INCLUDE_CLIMATE=true --wasm --release
flutter build web --dart-define=INCLUDE_CLIMATE=true --release
if [ ! -d "build/web" ]; then
    echo "❌ Error: build/web directory not found."
    exit 1
fi
rm -rf build/web_full && mv build/web build/web_full

# Build and prepare the WEATHER app
#flutter build web --dart-define=INCLUDE_CLIMATE=false --wasm --release
flutter build web --dart-define=INCLUDE_CLIMATE=false --release
if [ ! -d "build/web" ]; then
    echo "❌ Error: build/web directory not found."
    exit 1
fi
rm -f build/web/assets/assets/data/climatologie_*.csv 2>/dev/null
rmdir build/web/assets/assets/data 2>/dev/null || true
rm -rf build/web_weather && mv build/web build/web_weather

# Deploy BOTH to their respective sites
firebase deploy
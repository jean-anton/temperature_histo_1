#!/bin/bash
# Build script for AeroClim Weather (without climate features)
# This builds the app WITHOUT climate/historical temperature comparison features

echo "Building AeroClim Weather (without climate features)..."

# Android build
echo "Building Android APK..."
#flutter build apk --flavor weather --dart-define=INCLUDE_CLIMATE=false

# Web build
echo "Building Web..."
flutter build web --dart-define=INCLUDE_CLIMATE=false --wasm --release

# Remove climate data assets from web build (not needed for weather-only variant)
echo "Removing climate data assets from web build..."
rm -f build/web/assets/assets/data/climatologie_*.csv 2>/dev/null
rmdir build/web/assets/assets/data 2>/dev/null || true

echo "Build complete!"
#echo "Android APK: build/app/outputs/flutter-apk/app-weather-release.apk"
echo "Web: build/web/"

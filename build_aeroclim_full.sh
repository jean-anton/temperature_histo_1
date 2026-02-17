#!/bin/bash
# Build script for AeroClim Full (with climate features)
# This builds the app with climate/historical temperature comparison features

echo "Building AeroClim Full (with climate features)..."

# Android build
echo "Building Android APK..."
#flutter build apk --flavor full --dart-define=INCLUDE_CLIMATE=true

# Web build
echo "Building Web..."
flutter build web --dart-define=INCLUDE_CLIMATE=true

echo "Build complete!"
echo "Android APK: build/app/outputs/flutter-apk/app-full-release.apk"
echo "Web: build/web/"

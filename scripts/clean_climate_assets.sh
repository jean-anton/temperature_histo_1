#!/bin/bash
# Post-build script to remove climate data assets from weather-only build
# This script should be run after flutter build web with INCLUDE_CLIMATE=false

BUILD_DIR="${1:-build/web}"

echo "Removing climate data assets from $BUILD_DIR..."

# Remove climate CSV files
rm -f "$BUILD_DIR/assets/assets/data/climatologie_"*.csv 2>/dev/null

# Remove the climate data directory if empty
if [ -d "$BUILD_DIR/assets/assets/data" ]; then
    rmdir "$BUILD_DIR/assets/assets/data" 2>/dev/null || true
fi

echo "Climate assets removed successfully."

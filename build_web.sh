#!/bin/bash

set -e

echo "🛠️ Building Flutter web..."
# flutter build web
#flutter build web  --wasm --release
flutter build web  --release

dhttpd --path build/web --host 0.0.0.0 --port 5001
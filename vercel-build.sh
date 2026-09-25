#!/bin/bash
set -e

echo "=== Installing Flutter SDK for Vercel Deployment ==="

FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Cloning Flutter SDK (stable branch)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
else
  echo "Flutter SDK already exists in cache."
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "=== Flutter Environment Info ==="
flutter config --no-analytics
flutter config --enable-web
flutter --version

echo "=== Fetching Flutter Dependencies ==="
flutter pub get

echo "=== Building Flutter Web for Production ==="
flutter build web --release --dart-define=BACKEND_URL=https://genomic-cancer-intelligence.onrender.com

echo "=== Flutter Web build complete! Output directory: build/web ==="

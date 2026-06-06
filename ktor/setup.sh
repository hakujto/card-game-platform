#!/bin/bash
set -e

if ! command -v java &>/dev/null; then
  echo "Java is not installed. Install it first:"
  echo "  macOS:  brew install --cask temurin"
  echo "  Ubuntu: sudo apt install openjdk-21-jdk"
  exit 1
fi

if ! command -v gradle &>/dev/null; then
  echo "Gradle is not installed. Install it first:"
  echo "  macOS:  brew install gradle"
  echo "  Ubuntu: sudo apt install gradle"
  echo "  Or use the wrapper: ./gradlew (if present)"
  exit 1
fi

echo "→ Building with Gradle..."
gradle build -x test

echo ""
echo "✓ Setup complete!"
echo "  Run: gradle run"
echo "  API: http://localhost:8080/api/"

#!/bin/bash
set -e

if ! command -v sbt &>/dev/null; then
  echo "SBT is not installed. Install it first:"
  echo "  macOS:  brew install sbt"
  echo "  Ubuntu: sudo apt install sbt"
  exit 1
fi

echo "→ Compiling with SBT..."
sbt compile

echo ""
echo "✓ Setup complete!"
echo "  Run: sbt run"
echo "  API: http://localhost:9000/api/"

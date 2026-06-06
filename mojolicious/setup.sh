#!/bin/bash
set -e

if ! command -v cpanm &>/dev/null; then
  echo "→ Installing cpanm..."
  curl -fsSL https://cpanmin.us | perl - App::cpanminus
fi

echo "→ Installing Perl dependencies..."
cpanm --installdeps .

echo ""
echo "✓ Setup complete!"
echo "  Run: perl script/cards_project daemon -l http://*:3000"
echo "  API: http://localhost:3000/api/"
echo "  Dev: morbo script/cards_project"

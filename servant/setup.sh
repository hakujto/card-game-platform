#!/usr/bin/env bash
set -e

echo "==> Creating DB directory..."
mkdir -p db

echo "==> Running migrations..."
cat schema.sql | sqlite3 db/cards-project.db

echo "==> Updating Hackage package list..."
cabal update

echo "==> Building project (this may take a while on first run)..."
cabal build

echo ""
echo "==> Starting server..."
echo "    API: http://localhost:8080/api/"
echo ""
cabal run cards-project

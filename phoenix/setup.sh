#!/usr/bin/env bash
set -e

echo "==> Installing dependencies..."
mix deps.get

echo "==> Creating DB directory..."
mkdir -p db

echo "==> Creating and migrating database..."
mix ecto.setup

echo ""
echo "==> Starting server..."
echo "    API:  http://localhost:4000/api/"
echo ""
mix phx.server

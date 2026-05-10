#!/usr/bin/env bash
set -e

echo "==> Creating DB directory..."
mkdir -p db

echo "==> Running migrations..."
clojure -M:migrate

echo ""
echo "==> Starting server..."
echo "    API: http://localhost:3000/api/"
echo ""
clojure -M:run

#!/usr/bin/env bash
set -e

echo "=== Installing shards ==="
shards install

echo "=== Running server ==="
crystal run src/cards_project.cr

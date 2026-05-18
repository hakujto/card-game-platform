#!/usr/bin/env bash
set -e

echo "=== Installing dependencies ==="
go mod tidy

echo "=== Running server ==="
go run .

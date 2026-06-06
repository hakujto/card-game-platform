#!/bin/bash
set -e
echo "==> Building cards_project..."
rebar3 compile
echo "==> Starting Mnesia schema..."
mkdir -p data/mnesia
echo "==> Done. Run: rebar3 shell"

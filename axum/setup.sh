#!/usr/bin/env bash
# One-shot setup: install sqlx-cli, run migrations, build and start the server.
set -e

cd "$(dirname "$0")"

command -v cargo &>/dev/null || { echo "Error: Rust/Cargo not found. Install from https://rustup.rs"; exit 1; }

echo "==> Installing sqlx-cli (if not present)..."
cargo install sqlx-cli --no-default-features --features sqlite 2>/dev/null || true

export PATH="$HOME/.cargo/bin:$PATH"
export DATABASE_URL=${DATABASE_URL:-sqlite://app.db}

echo "==> Running migrations..."
rm -f app.db
touch app.db
sqlx migrate run --source migrations

echo "==> Preparing sqlx offline cache..."
DATABASE_URL=sqlite:app.db cargo sqlx prepare

echo "==> Building project..."
cargo build

echo ""
echo "==> Starting server at http://localhost:8080"
echo "    API: http://localhost:8080/api/"
echo ""
cargo run

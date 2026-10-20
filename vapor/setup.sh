#!/bin/bash
set -e
echo "Setting up cards_project (Vapor/Swift)..."

# Start DB
docker compose up -d db
echo "Waiting for PostgreSQL..."
until docker compose exec db pg_isready -U vapor; do sleep 1; done

# Run migrations
swift run App migrate --yes

echo "Setup complete. Run: swift run"

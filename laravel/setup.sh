#!/usr/bin/env bash
set -e
echo "=== Installing dependencies ==="
composer install --no-interaction
chmod +x artisan
echo "=== Creating .env ==="
cp -n .env.example .env || true
echo "=== Generating app key ==="
php artisan key:generate --ansi
echo "=== Creating SQLite database ==="
mkdir -p database
touch database/database.sqlite
echo "DB_DATABASE=$(pwd)/database/database.sqlite" >> .env
echo "=== Running migrations ==="
php artisan migrate --no-interaction
echo "=== Done. Start server with: ==="
echo "    php artisan serve"

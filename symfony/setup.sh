#!/usr/bin/env bash
set -e
echo "=== Installing dependencies ==="
composer install --no-interaction
echo "=== Creating database schema ==="
php bin/console doctrine:schema:drop --force --no-interaction 2>/dev/null || true
php bin/console doctrine:schema:create --no-interaction
echo "=== Done. Start server with: ==="
echo "    php -S localhost:8000 -t public/"

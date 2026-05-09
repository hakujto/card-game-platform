#!/bin/bash
set -e

if [ ! -f .env ]; then
  echo "→ Creating .env from .env.example..."
  cp .env.example .env
fi

echo "→ Installing dependencies..."
npm install

echo "→ Generating Prisma client..."
npm run db:generate

echo "→ Pushing schema to database..."
npm run db:push

echo ""
echo "✓ Setup complete!"
echo "  Run: npm run dev"
echo "  API: http://localhost:3000/api/"

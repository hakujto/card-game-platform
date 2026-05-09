#!/bin/bash
set -e

echo "→ Restoring packages..."
dotnet restore

echo "→ Applying migrations (EnsureCreated via Program.cs startup)..."
dotnet run --project CardsProject/CardsProject.csproj &
SERVER_PID=$!
sleep 3
kill $SERVER_PID 2>/dev/null || true

echo "→ Building..."
dotnet build -c Release

echo ""
echo "✓ Setup complete!"
echo "  Run: dotnet run --project CardsProject/CardsProject.csproj"
echo "  API: http://localhost:5000/api/"
echo "  Swagger: http://localhost:5000/swagger"

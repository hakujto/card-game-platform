#!/bin/bash
set -e

if ! command -v mvn &>/dev/null; then
  echo "Maven is not installed. Install it first:"
  echo "  macOS:  brew install maven"
  echo "  Ubuntu: sudo apt install maven"
  echo "  Or download from https://maven.apache.org/download.cgi"
  exit 1
fi

echo "→ Building with Maven..."
mvn clean package -DskipTests

echo ""
echo "✓ Setup complete!"
echo "  Run: mvn spring-boot:run"
echo "  API:     http://localhost:8080/api/"
echo "  Swagger: http://localhost:8080/swagger-ui.html"

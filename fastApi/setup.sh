#!/usr/bin/env bash
set -e

echo "==> Creating virtual environment..."
python -m venv venv
source venv/bin/activate

echo "==> Installing dependencies..."
pip install -r requirements.txt

echo ""
echo "==> Starting server..."
echo "    API:   http://localhost:8000/api/"
echo "    Docs:  http://localhost:8000/docs"
echo ""
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

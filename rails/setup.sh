#!/bin/bash
set -e
chmod +x bin/*
bundle install
bin/rails db:create db:migrate
echo ""
echo "✓ Ready. Run: bin/rails server"

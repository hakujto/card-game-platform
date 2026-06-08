#!/usr/bin/env bash
set -e

echo "==> Installing OCaml dependencies..."
opam install --yes dream caqti caqti-lwt caqti-driver-sqlite3 yojson ppx_deriving_yojson lwt lwt_ppx alcotest cohttp-lwt-unix str sqlite3 2>/dev/null || true

echo "==> Building project..."
dune build

echo "==> Running migrations..."
./_build/default/migrate.exe

echo ""
echo "==> Starting server on http://localhost:3000"
echo ""
./_build/default/main.exe

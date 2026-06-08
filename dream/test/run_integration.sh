#!/usr/bin/env bash
# Integration test runner for \`dune test\` — starts the server, waits a
# moment for it to come up, runs the Alcotest HTTP suite against it, then tears
# the server down.
set -u

DB_FILE="cards_project.db"
SERVER_PID=""

cleanup() {
  if [ -n "$SERVER_PID" ]; then
    kill "$SERVER_PID" >/dev/null 2>&1
    wait "$SERVER_PID" 2>/dev/null
  fi
  rm -f "$DB_FILE"
}
trap cleanup EXIT

rm -f "$DB_FILE"
./../migrate.exe >/dev/null 2>&1

./../main.exe >server.log 2>&1 &
SERVER_PID=$!

sleep 2

./run_tests.exe -e
STATUS=$?

exit $STATUS

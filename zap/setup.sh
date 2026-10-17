#!/usr/bin/env bash
set -e

echo "=== Fetching dependencies ==="
zig build --fetch 2>/dev/null || true

# Patch zap build.zig for Zig 0.17+ compatibility
# std.process.getEnvVarOwned was removed in Zig 0.17
ZAP_BUILD=$(find zig-pkg -name "build.zig" -path "*/zap-*" 2>/dev/null | head -1)
if [ -n "$ZAP_BUILD" ] && grep -q "getEnvVarOwned" "$ZAP_BUILD" 2>/dev/null; then
  chmod +w "$ZAP_BUILD"
  sed -i.bak \
    's/if (std\.process\.getEnvVarOwned(b\.allocator, "ZAP_USE_OPENSSL")) |val| {/if (std.posix.getenv("ZAP_USE_OPENSSL")) |val| {/' \
    "$ZAP_BUILD"
  sed -i.bak \
    '/defer b\.allocator\.free(val);/d' \
    "$ZAP_BUILD"
  echo "Patched: $ZAP_BUILD"
fi

# Patch facil.io/build.zig for Zig 0.17+ compatibility
# OptimizeMode enum values are now lowercase (.debug vs .Debug)
FACILIO_BUILD=$(find zig-pkg -name "build.zig" -path "*/facil.io*" 2>/dev/null | head -1)
if [ -n "$FACILIO_BUILD" ] && grep -q "\.Debug" "$FACILIO_BUILD" 2>/dev/null; then
  chmod +w "$FACILIO_BUILD"
  sed -i.bak \
    's/optimize != \.Debug/optimize != .debug/g' \
    "$FACILIO_BUILD"
  echo "Patched: $FACILIO_BUILD"
fi

# Patch zap/build.zig to use createModule for examples+tests (Zig 0.17 forbids duplicate addModule names)
if [ -n "$ZAP_BUILD" ] && grep -q 'const exe_mod = b.addModule(ex_name' "$ZAP_BUILD" 2>/dev/null; then
  chmod +w "$ZAP_BUILD"
  sed -i.bak \
    's/const exe_mod = b\.addModule(ex_name,/const exe_mod = b.createModule(/' \
    "$ZAP_BUILD"
  sed -i.bak \
    's/const tests_module = self\.b\.addModule(test_name,/const tests_module = self.b.createModule(/' \
    "$ZAP_BUILD"
  echo "Patched createModule: $ZAP_BUILD"
fi

echo "=== Building cards_project (Zig/Zap) ==="
zig build

echo "=== Running ==="
./zig-out/bin/cards_project

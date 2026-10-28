#!/usr/bin/env bash
# Collects the project dashboard's data into build/codemap/*.json:
# test and analyzer results first, then the code map itself.
set -euo pipefail
cd "$(dirname "$0")/.."

FLUTTER=${FLUTTER:-flutter}
DART="$(dirname "$(command -v "$FLUTTER")")/dart"
OUT=build/codemap
mkdir -p "$OUT"

"$FLUTTER" test --machine > "$OUT/test-events.jsonl" || true
"$FLUTTER" analyze > "$OUT/analyze.txt" 2>&1 || true
"$DART" run tool/codemap.dart

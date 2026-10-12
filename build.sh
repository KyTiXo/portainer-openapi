#!/usr/bin/env bash
# Bundle every split-OpenAPI-3 Portainer spec (CE + EE) into self-contained JSON under ./site.
set -euo pipefail
BASE=https://api-docs.portainer.io
OUT=${1:-site}
mkdir -p "$OUT"
for ed in ce ee; do
  # Split OAS3 versions are the ones whose entry file is versions/<ed>/<ver>/openapi.yaml; the rest are Swagger 2.0.
  vers=$(curl -fsS "$BASE/$ed-versions.json" | jq -r --arg ed "$ed" '.[] | select(.file == "versions/\($ed)/\(.id)/openapi.yaml") | .id')
  [ -n "$vers" ] || { echo "no $ed versions"; exit 1; }
  for ver in $vers; do
    f="$OUT/$ed/$ver.json"
    # Upstream occasionally drops a ref fetch; retry before failing the run.
    for try in 1 2 3; do
      bunx @redocly/cli@2.62.1 bundle "$BASE/versions/$ed/$ver/openapi.yaml" --ext json -o "$f" >/dev/null && break
      [ "$try" = 3 ] && exit 1; sleep 5
    done
    # Executor needs only local refs and exactly one literal server; mark it unofficial (zlib: altered versions must be marked).
    jq -e '.servers == [{"url":"/api"}] and ([.. | objects | .["$ref"]? // empty | select(startswith("#/") | not)] | length == 0)' "$f" >/dev/null || { echo "invalid: $f"; exit 1; }
    jq --arg src "$BASE/versions/$ed/$ver/openapi.yaml" '.info.description = "Unofficial bundled copy of \($src). Not affiliated with Portainer.\n\n" + (.info.description // "")' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    echo "$ed $ver"
  done
done
find "$OUT" -name '*.json' ! -name index.json | sed "s|^$OUT/||" | sort | jq -Rn '[inputs]' > "$OUT/index.json"

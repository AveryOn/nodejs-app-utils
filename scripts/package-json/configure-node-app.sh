#!/usr/bin/env bash

set -euo pipefail

TARGET_DIR="${1:-.}"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

cd "$TARGET_DIR"

if [[ ! -f "package.json" ]]; then
  echo "Error: package.json was not found in: $(pwd)" >&2
  echo "Run 'npm init -y' before using this script." >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "Error: npm is not installed or is not available in PATH." >&2
  exit 1
fi

echo "Configuring package.json in: $(pwd)"

npm pkg set private=true --json
npm pkg set type="module"
npm pkg set main="./dist/main.js"
npm pkg set engines.node=">=24.0.0"

npm pkg set scripts.dev="tsx watch --clear-screen=false src/main.ts"
npm pkg set scripts.build="tsup"
npm pkg set scripts.start="node dist/main.js"
npm pkg set scripts.typecheck="tsc --noEmit"

echo "package.json configured successfully."
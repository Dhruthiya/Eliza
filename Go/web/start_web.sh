#!/bin/bash

cd "$(dirname "$0")/.."

echo ""
echo "╔════════════════════════════════════════╗"
echo "║      Starting ELIZA Go Web...         ║"
echo "╚════════════════════════════════════════╝"
echo ""

go run ./cmd/eliza --web

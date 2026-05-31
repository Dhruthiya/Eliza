#!/bin/bash

cd "$(dirname "$0")"

echo ""
echo "╔════════════════════════════════════════╗"
echo "║      Starting ELIZA Rust Web...       ║"
echo "╚════════════════════════════════════════╝"
echo ""

cargo run -- --web

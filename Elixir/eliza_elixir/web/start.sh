#!/bin/bash

cd "$(dirname "$0")"

echo ""
echo "╔════════════════════════════════════════╗"
echo "║      Starting ELIZA Web Server...     ║"
echo "╚════════════════════════════════════════╝"
echo ""

./server.exs

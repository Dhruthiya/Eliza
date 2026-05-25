#!/bin/bash

export PATH="/home/cse/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin:$PATH"
cd "/home/cse/eliza/Rust"

echo ""
echo "╔════════════════════════════════════════╗"
echo "║      Starting ELIZA Rust Web...       ║"
echo "╚════════════════════════════════════════╝"
echo ""

cargo run -- --web

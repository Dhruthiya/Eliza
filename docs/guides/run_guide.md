# ELIZA Run Guide

This guide explains how to run the different implementations of ELIZA. All code is located in the `implementations/` directory.

## Go Implementation
The Go version can be run as a CLI or a Web Server.

```bash
cd implementations/go
# Run CLI mode
go run ./cmd/eliza

# Run Web mode
go run ./cmd/eliza --web --port 4000
```
**Default URL:** `http://localhost:4000`

---

## Rust Implementation
The Rust version supports both CLI and Web modes.

```bash
cd implementations/rust
# Run CLI mode
cargo run

# Run Web mode
cargo run -- --web
```
**Default URL:** `http://localhost:4000`

---

## Elixir Implementation
The Elixir version includes a CLI and a web server.

```bash
cd implementations/elixir
# Run CLI mode
mix run run_cli.exs

# Start Web Server
cd web
./start.sh
```
**Default URL:** `http://localhost:4000`

---

## JavaScript Implementation
The JavaScript version is purely browser-based.

1. Navigate to `implementations/javascript/`
2. Open `index.html` in any web browser.

---

## Data Configuration
All implementations are configured to look for the ELIZA logic (keywords, synonyms, etc.) in the following locations:
1. `shared/data/` (Recommended)
2. `data/` (Legacy/Symlink)

If you encounter an error locating the data directory, you can set an environment variable:
```bash
export ELIZA_DATA_PATH=$(pwd)/shared/data
```

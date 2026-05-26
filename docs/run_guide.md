# ELIZA Web Run Guide

Commands below assume the repository is checked out at:

```bash
/home/admin-aiml/WingsAI/eliza
```

## Go

```bash
cd /home/admin-aiml/WingsAI/eliza/Go
go run ./cmd/eliza --web
```

Optional custom port:

```bash
go run ./cmd/eliza --web --port 4001
```

Default URL:

```text
http://localhost:4000
```

## Elixir

```bash
cd /home/admin-aiml/WingsAI/eliza/Elixir/eliza_elixir/web
./server.exs
```

Alternative:

```bash
./start.sh
```

Default URL:

```text
http://localhost:4000
```

## Rust

```bash
cd /home/admin-aiml/WingsAI/eliza/Rust
cargo run -- --web
```

Default URL:

```text
http://localhost:4000
```

## Data Path Note

The Elixir and Rust web code currently hardcodes the old data path:

```text
/home/cse/eliza/data
```

On this machine, the actual data path is:

```text
/home/admin-aiml/WingsAI/eliza/data
```

The Go version is the most likely to run cleanly as-is. The Elixir and Rust
versions may need the hardcoded data path updated before they start successfully.

# Go ELIZA Implementation Details

This document describes the implementation that exists in `Go/`. It is based on the source code, not only on the implementation plan.

## Project Layout

- `go.mod` defines module `eliza-go`.
- `cmd/eliza/main.go` is the CLI and web entry point.
- `internal/script/types.go` defines script data types.
- `internal/script/loader.go` loads and parses the shared JSON script files.
- `internal/engine/normalize.go` normalizes user input.
- `internal/engine/decomposer.go` matches input words against decomposition patterns.
- `internal/engine/transformer.go` performs post substitutions and reassembly.
- `internal/engine/state.go` stores response counters and memory.
- `internal/engine/engine.go` coordinates response generation.
- `internal/web/server.go` provides the HTTP API.
- `tests/` contains decomposer and partial golden transcript tests.

## Data and Path Resolution

`script.LoadScript(basePath string)` loads the shared script JSON files. Data path resolution is:

1. Use the explicit `basePath` argument when provided.
2. Use `ELIZA_DATA_PATH` when set.
3. Try relative candidates: `../../data`, `../data`, and `./data`.

This supports running from `Go/`, from Go package test working directories such as `Go/tests`, or from the repository root with an explicit or environment path.

Loaded files:

- `elizaInitials.json`
- `elizaFinals.json`
- `elizaQuits.json`
- `elizaPres.json`
- `elizaPosts.json`
- `elizaSynons.json`
- `elizaKeywords.json`
- `elizaPostTransforms.json`

`pres` and `posts` are converted from pair arrays into maps. Keywords are parsed into `script.Keyword` values and sorted by descending rank.

## Pattern Model

Go uses typed pattern tokens:

- `TokenLiteral`: exact word match.
- `TokenWildcard`: created from `*`.
- `TokenSynonym`: created from tokens starting with `@`.

This means the Go implementation does implement synonym matching for patterns such as `@sad` or `@belief`. The matched synonym word is captured as a component.

Memory rules are detected when a pattern starts with `$`; the `$` is stripped and `IsMemoryRule` is set.

## Runtime Flow

`engine.Engine.Transform(input string)` is the main entry point.

1. Lock the engine mutex so one engine instance can be used safely by the web server.
2. Normalize input with `NormalizeInput`.
3. Split normalized text into words.
4. If a quit word appears, return a final response and `quit=true`.
5. Search ranked keywords, skipping `xnone` during normal keyword search.
6. Try each matching keyword rule in file order.
7. Match words against the rule pattern with `engine.Match`.
8. Transform captured components using `posts`.
9. Select the next reassembly template cyclically with `ConversationState.NextResponseIndex`.
10. If the template starts with `goto `, redirect to the target keyword rules.
11. Otherwise substitute `(1)`, `(2)`, and similar placeholders.
12. If the rule is a memory rule, enqueue the response and keep searching.
13. If no normal response is found, fallback pops memory FIFO, then chooses from `xnone`.

Greeting, final, and fallback `xnone` selection can be random or deterministic. The `--deterministic` flag makes `pickString` return the first option for repeatable tests.

## Normalization Semantics

`NormalizeInput` does the following:

1. Lowercase input.
2. Apply `pres` substitutions using `strings.ReplaceAll`.
3. Substitution keys are processed longest first.
4. Replace punctuation matching `[^\w\s]` with spaces.
5. Collapse whitespace with `strings.Fields`.

This order differs from Elixir, which removes punctuation before applying `pres`.

## Decomposition Semantics

`engine.Match` uses recursive backtracking.

- Literals must match exactly.
- Literals are not captured.
- Wildcards capture zero or more words as one string.
- A final wildcard captures the rest of the sentence.
- Consecutive wildcards make the current wildcard capture an empty string.
- Synonym tokens match their synonym list or the class name itself and capture the matched word.

## State

`ConversationState` stores:

- `ResponseIndex`: cyclic counters keyed by keyword and rule index.
- `Memory`: FIFO memory responses.

The state object has its own mutex; the engine also has a mutex around full transforms.

## Interfaces

CLI:

```bash
go run ./cmd/eliza
```

Useful flags:

- `--web`: run HTTP server.
- `--data /path/to/data`: explicit data path.
- `--port 4000`: web port.
- `--deterministic`: deterministic greeting/final selection.

Web:

- `GET /` serves `web/index.html`.
- `POST /chat` accepts `{"message":"..."}` and returns `{"response":"..."}`.
- `POST /reset` resets conversation state.
- `GET /healthz` returns `{"status":"ok"}`.

## Verification Status

`go test ./...` passes from `Go/` after the path fix. The test suite includes decomposer tests and a partial golden transcript test.

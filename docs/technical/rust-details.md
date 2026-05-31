# Rust ELIZA Implementation Details

This document describes the implementation that exists in `Rust/`. It is based on the source code, not only on the implementation plan.

## Project Layout

- `Cargo.toml` defines package `eliza`.
- `src/main.rs` selects CLI or web mode.
- `src/lib.rs` exports the library modules.
- `src/script.rs` defines script data types.
- `src/parser.rs` resolves the data path and loads JSON files.
- `src/decomposer.rs` matches input words against decomposition patterns.
- `src/transformer.rs` performs post substitutions and reassembly.
- `src/state.rs` stores response counters and memory.
- `src/engine.rs` coordinates response generation.
- `src/cli.rs` provides the REPL.
- `src/web_server.rs` provides the HTTP API.
- `tests/` contains decomposer and golden transcript tests.

## Data and Path Resolution

`ScriptLoader::resolve_data_directory` locates the shared repository `data/` directory. Resolution order is:

1. Use an explicit path when one is passed.
2. Use `ELIZA_DATA_PATH` when set.
3. Try relative candidates from the current working directory: `data`, `../data`, `../../data`, and `Rust/../data`.

The resolver validates that the directory contains core ELIZA JSON files before returning it. CLI and web mode now use this resolver instead of a hardcoded user-specific path.

Loaded files:

- `elizaInitials.json`
- `elizaFinals.json`
- `elizaQuits.json`
- `elizaPres.json`
- `elizaPosts.json`
- `elizaSynons.json`
- `elizaKeywords.json`

The Rust script struct currently does not store `elizaPostTransforms.json`.

`pres` and `posts` are converted from pair arrays into `HashMap<String, String>`. Keywords are parsed into a `HashMap<String, Keyword>`. `Script::keywords_by_rank` returns keyword references sorted by descending rank, then name ascending for stable ordering.

## Pattern Model

Patterns are stored as `Vec<String>` rather than typed tokens. The decomposer interprets tokens at match time:

- `*` and `0` are indefinite wildcards.
- Positive numeric tokens capture exactly that many words.
- Tokens starting with `@` are synonym classes.
- All other tokens are literals.

Memory rules are detected when a pattern starts with `$`; the `$` is stripped and `is_memory_rule` is set.

## Runtime Flow

`ElizaEngine::transform(input)` is the main entry point.

1. Normalize input.
2. Split normalized input into words.
3. If no words remain, return `Please say something.`.
4. If any quit word appears, return the first final message.
5. Search keywords sorted by rank. `xnone` is included in this search if reached by rank/order.
6. Try each matching keyword rule in file order.
7. Match words against the rule pattern with `Decomposer::decompose`.
8. Transform captured components with `Transformer::transform_components` using `posts`.
9. Select a reassembly template through `ConversationState::get_next_response_index`.
10. If the template starts with `goto `, redirect to that keyword.
11. Otherwise substitute `(1)`, `(2)`, and similar placeholders.
12. If the rule is a memory rule, save the response and continue searching.
13. If no response is found, pop memory.
14. If there is no memory, try `xnone` fallback.
15. If that fails, return `I am not sure I understand you fully.`.

## Normalization Semantics

`ElizaEngine::normalize_input` does the following:

1. Lowercase input.
2. Replace characters matching `[^a-z0-9'\s]` with spaces. Apostrophes are preserved.
3. Split into words.
4. Apply `pres` substitutions word by word.
5. Join words with single spaces.

This differs from Go and Elixir because substitutions happen after punctuation cleanup and only on full words.

## Decomposition Semantics

`Decomposer::decompose` uses recursive backtracking.

- `*` and `0` capture zero or more words.
- The current wildcard tries shorter captures first, from zero words upward.
- Positive numeric tokens capture exactly that many words.
- Synonym tokens match entries from `script.synons` or the synonym class name itself; the matched word is captured.
- Literal tokens match case-insensitively and are not captured.

## Transformation and Reassembly

`Transformer::transform_components` reflects captured components using `posts`. Each component is split into words, each lowercased word is looked up in `posts`, and the result is joined with spaces.

`Transformer::reassemble` replaces placeholders like `(1)` with one-based component indexes. If a placeholder references a missing component, the current implementation leaves that placeholder text unchanged.

## State

`ConversationState` stores:

- A bounded FIFO memory queue with max size `20`.
- Response counters keyed by `keyword:rule_index`.
- A `use_random` flag.

When `use_random` is false, response selection and memory retrieval are deterministic and FIFO/cyclic. When true, response and memory selection are random.

## Interfaces

CLI:

```bash
cargo run
```

Web:

```bash
cargo run -- --web
```

or:

```bash
./start_web.sh
```

Web routes:

- `GET /` serves `web/index.html`.
- `POST /chat` accepts `{"message":"..."}` and returns `{"response":"..."}`.

The web server binds to `0.0.0.0:4000`.

## Verification Status

`cargo test` passes from `Rust/`. Tests cover wildcard matching, synonym capture, and a golden transcript subset.

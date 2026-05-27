# Elixir ELIZA Implementation Details

This document describes the implementation that exists in `Elixir/eliza_elixir`. It is based on the source code, not only on the implementation plan.

## Project Layout

- `eliza_elixir/mix.exs` defines the Mix project and the `jason` dependency.
- `lib/eliza_elixir/script.ex` defines the script data structs.
- `lib/eliza_elixir/script_loader.ex` loads the shared JSON script files.
- `lib/eliza_elixir/decomposer.ex` matches input words against decomposition patterns.
- `lib/eliza_elixir/transformer.ex` applies post substitutions and reassembles replies.
- `lib/eliza_elixir/state.ex` stores cyclic response counters and memory.
- `lib/eliza_elixir/engine.ex` coordinates the full ELIZA response pipeline.
- `lib/eliza_elixir/cli.ex`, `run_cli.exs`, and `chat.exs` provide CLI entry points.
- `web/server.exs` and `web/index.html` provide the web interface.

## Data Loading

`Eliza.ScriptLoader.load_script/1` loads data from the shared repository `data/` directory by default. The default path is computed relative to `lib/eliza_elixir/script_loader.ex` as `../../../../data`.

Loaded files:

- `elizaInitials.json`
- `elizaFinals.json`
- `elizaQuits.json`
- `elizaPres.json`
- `elizaPosts.json`
- `elizaSynons.json`
- `elizaKeywords.json`
- `elizaPostTransforms.json`

`elizaPres.json` and `elizaPosts.json` are loaded as pair arrays and converted into maps. Keywords are converted into `%Eliza.Script.Keyword{}` structs and sorted by descending rank. Rules are converted into `%Eliza.Script.Rule{}` structs.

Pattern parsing is simple:

- `*` becomes `:wildcard`.
- Any other token is lowercased and treated as a literal.
- `$` at the start of a pattern marks a memory rule and is stripped.

Although synonyms and post transforms are loaded into the script struct, the current Elixir matcher does not apply synonym expansion or post-transform cleanup.

## Runtime Flow

`Eliza.Engine.transform/2` is the main entry point.

1. Lowercase the input.
2. Replace punctuation matching `[^\w\s]` with spaces.
3. Apply `pres` substitutions with plain `String.replace/3` over the full text.
4. Split the normalized text into lowercase words.
5. If any quit word appears in the words, return `{:quit, final}` where `final` is randomly selected from `script.finals`.
6. Search keywords in descending rank order. A keyword is considered only if its name appears in the input words, except `xnone`, which is also allowed.
7. For the selected keyword, try rules in file order.
8. Use `Eliza.Decomposer.match/2` to match the words against a rule pattern.
9. Transform captured components with `Eliza.Transformer.transform_components/2` using `posts`.
10. Select a reassembly template using `Eliza.State.get_next_response_index/3`.
11. If the template starts with `goto `, process rules for the target keyword.
12. Otherwise replace `(1)`, `(2)`, and similar placeholders with transformed components.
13. If the rule is a memory rule, save the generated response and continue looking for a normal response.
14. If no normal response is found, fallback first pops memory, then picks a random `xnone` response.

## Decomposition Semantics

`Eliza.Decomposer` uses recursive backtracking.

- Literal tokens must match exact words.
- Literal tokens are not captured.
- Wildcards capture zero or more words as a single string.
- If a wildcard is the last pattern token, it captures the rest of the sentence.
- Consecutive wildcards cause the current wildcard to capture an empty string.
- When a wildcard is followed by a literal, the matcher tries occurrences of that literal from first to last.

## State

`Eliza.State` is an `Agent` started by the OTP application or by standalone scripts. It stores:

- `response_index`: cyclic response counters keyed by `{keyword_name, rule_index}`.
- `memory`: saved memory-rule responses.

Memory is saved by prepending to the list and retrieved FIFO by reversing internally.

## Interfaces

CLI options:

- `mix run lib/run.exs` inside `Elixir/eliza_elixir` after dependencies are installed.
- `./run_cli.exs` or `./chat.exs` from `Elixir/eliza_elixir`.

Web interface:

- `web/server.exs` installs `jason`, `plug`, and `bandit` at runtime.
- `GET /` serves `web/index.html`.
- `POST /chat` accepts `{"message":"..."}` and returns `{"response":"..."}`.
- Default port is `4000`, overridable with `PORT`.

## Verification Status

The tests are ExUnit tests under `test/`. In this workspace, `mix test` requires `mix deps.get` first because `jason` is not currently installed in the Mix dependency directory.

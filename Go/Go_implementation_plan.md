# ELIZA Go Implementation Plan

This plan is based on the current implementation in `/home/cse/eliza/Elixir/eliza_elixir` and the original JavaScript reference in `/home/cse/eliza/Elixir/eliza_script`.

The goal is to build a Go version that matches the current Elixir behavior first, including the web interface, and then optionally close the known gaps between the Elixir port and the original JavaScript ELIZA.

## 1. What The Elixir Version Actually Implements

The Elixir codebase is small and organized around a straightforward pipeline:

1. `script_loader.ex`
   Loads JSON files from `/home/cse/eliza/data` into native structs.

2. `script.ex`
   Defines the core data structures:
   - `Script`
   - `Keyword`
   - `Rule`

3. `decomposer.ex`
   Implements greedy wildcard matching over tokenized input.
   Important behavior:
   - wildcards are captured
   - literal keywords are matched but not captured
   - matching uses backtracking

4. `transformer.ex`
   Applies post substitutions to captured components and fills `(n)` placeholders in response templates.

5. `state.ex`
   Tracks:
   - cyclic response selection per keyword/rule
   - memory queue for deferred responses

6. `engine.ex`
   Orchestrates the ELIZA flow:
   - normalize input
   - apply `pres`
   - detect quit words
   - find ranked keyword
   - try decomposition rules
   - handle `goto`
   - use memory fallback
   - fall back to `xnone`

7. `cli.ex` and `run_cli.exs`
   Provide a terminal REPL.

8. `web/server.exs` and `web/index.html`
   Provide a minimal web app:
   - `GET /` serves the HTML
   - `POST /chat` accepts `{"message":"..."}` and returns `{"response":"..."}`

## 2. Behavior To Preserve In Go

The Go implementation should preserve these Elixir behaviors exactly in v1:

- Script data loaded from the shared `data/` directory.
- Keyword ranking sorted descending.
- Input normalization by:
  - lowercasing
  - punctuation removal
  - applying `pres` substitutions
- Quit detection before normal reply generation.
- Greedy wildcard decomposition with backtracking.
- Capturing only wildcard segments, not literal keywords.
- Pronoun reflection via `posts`.
- Cyclic response selection per decomposition rule.
- `goto` redirects.
- Memory-rule support.
- `xnone` fallback when nothing matches.
- CLI mode and web mode in the same project.

## 3. Known Gaps In Elixir That Go Should Track Explicitly

The original JavaScript implementation includes features that the current Elixir version does not fully implement:

- Synonym expansion for patterns such as `@sad`
- Full post-transform cleanup driven by `elizaPostTransforms.json`
- More exact normalization semantics from the JavaScript reference
- Historically accurate golden transcript parity across the full sample conversation

Recommendation:

- `v1`: Match current Elixir behavior.
- `v1.1`: Add synonym expansion and full post-transform parity with the JavaScript reference.

## 4. Proposed Go Project Structure

Create a dedicated Go module under `/home/cse/eliza/Go`.

Suggested layout:

```text
Go/
  go.mod
  cmd/
    eliza/
      main.go
  internal/
    script/
      types.go
      loader.go
    engine/
      normalize.go
      decomposer.go
      transformer.go
      engine.go
      state.go
    web/
      server.go
      handlers.go
  web/
    index.html
    start_web.sh
  tests/
    golden_transcript_test.go
    decomposer_test.go
  Go_implementation_plan.md
```

## 5. Data Model In Go

Define structs that mirror the Elixir structs closely:

```go
type Rule struct {
    Pattern      []PatternToken
    Reassembly   []string
    IsMemoryRule bool
}

type Keyword struct {
    Name  string
    Rank  int
    Rules []Rule
}

type Script struct {
    Initials       []string
    Finals         []string
    Quits          []string
    Pres           map[string]string
    Posts          map[string]string
    Synons         map[string][]string
    Keywords       []Keyword
    PostTransforms []PostTransform
}
```

For patterns, use a dedicated token representation instead of raw strings:

```go
type PatternToken struct {
    Kind  TokenKind
    Value string
}
```

Where `TokenKind` is something like:

- `TokenLiteral`
- `TokenWildcard`
- later optionally `TokenSynonym`

This gives room for clean synonym expansion in `v1.1`.

## 6. Core Engine Design In Go

### 6.1 Script Loader

Implement a loader that:

- reads the JSON files in `/home/cse/eliza/data`
- converts pair arrays into maps for `pres` and `posts`
- parses keyword rules into internal `Rule` structs
- sorts keywords descending by rank

Responsibilities:

- `LoadScript(basePath string) (*Script, error)`
- `parsePattern(pattern string) []PatternToken`

In `v1`, parse `*` into wildcards and lowercase literals.

In `v1.1`, expand `@synon` references into matcher-compatible structures.

### 6.2 Normalization

Create a normalization pipeline that matches the Elixir implementation first:

- lowercase input
- replace non-word punctuation with spaces
- apply `pres`
- split into words

Later, optionally align more closely with the JavaScript reference:

- sentence splitting on punctuation
- handling of `but`
- more exact spacing cleanup

### 6.3 Decomposer

Implement a recursive or iterative backtracking matcher.

Required semantics:

- exact literal matches
- greedy wildcard behavior
- only wildcard captures become components
- return `no match` when pattern cannot be satisfied

Recommended API:

```go
func Match(words []string, pattern []PatternToken) ([]string, bool)
```

Test first:

- exact literal match
- trailing wildcard
- wildcard in the middle
- multiple wildcards
- greedy capture cases
- mismatch cases

### 6.4 Transformer

Implement two responsibilities:

1. Transform captured components using `posts`
2. Reassemble a selected template by substituting `(1)`, `(2)`, etc.

Recommended API:

```go
func TransformComponents(components []string, posts map[string]string) []string
func Reassemble(template string, components []string) string
```

In `v1.1`, add full post-transform processing after reassembly.

### 6.5 Stateful Conversation Engine

Unlike the Elixir web server, Go should make the conversation state design explicit.

The Elixir version has one global `State` process that drives:

- response cycling
- memory queue

For Go, define:

```go
type ConversationState struct {
    ResponseIndex map[RuleKey]int
    Memory        []string
    mu            sync.Mutex
}
```

Where `RuleKey` is:

```go
type RuleKey struct {
    Keyword string
    Rule    int
}
```

Recommended methods:

- `NextResponseIndex(keyword string, ruleIndex int, size int) int`
- `SaveMemory(response string)`
- `PopMemory() (string, bool)`
- `Reset()`

## 7. Engine Flow In Go

Implement the same high-level flow as Elixir:

1. Normalize input
2. Tokenize
3. Check quit expressions
4. Scan keywords by descending rank
5. For matching keyword candidates, try each rule
6. If a rule matches:
   - transform components
   - select cyclic reassembly
   - process `goto` if present
   - store in memory if it is a memory rule
   - otherwise return response
7. If no direct match:
   - return oldest memory if present
   - otherwise use `xnone`
   - otherwise return a hardcoded fallback

Recommended API:

```go
type Engine struct {
    Script *script.Script
    State  *ConversationState
}

func (e *Engine) Transform(input string) (response string, quit bool, err error)
```

## 8. CLI Implementation

The Go CLI should match the Elixir CLI UX closely.

Requirements:

- load script from `/home/cse/eliza/data`
- print a random initial greeting
- read from stdin in a loop
- print ELIZA responses
- stop after quit input and print a final response

Suggested command:

```bash
go run ./cmd/eliza
```

Optional flags:

- `--web`
- `--data /path/to/data`
- `--port 4000`
- `--deterministic`

## 9. Web Version Plan

The Elixir web version is intentionally simple. The Go web version should keep the same contract and improve the state model.

### 9.1 HTTP Endpoints

Required endpoints:

- `GET /`
  Serve `web/index.html`

- `POST /chat`
  Request:
  ```json
  {"message":"Hello"}
  ```
  Response:
  ```json
  {"response":"How do you do. Please tell me your problem."}
  ```

Optional endpoints:

- `POST /reset`
  Resets conversation state

- `GET /healthz`
  Returns a simple health response for quick verification

### 9.2 State Strategy For Web

There are two valid approaches:

1. Single shared conversation state
   Matches current Elixir behavior most closely.

2. Per-session conversation state
   Better web design.

Recommendation:

- `v1`: Single shared state for parity with Elixir
- `v1.1`: Add per-session state via cookie-based session IDs or an in-memory session map

Suggested design for per-session state:

```go
type SessionStore struct {
    sessions map[string]*ConversationState
    mu       sync.RWMutex
}
```

### 9.3 HTTP Server Choice

Use Go standard library first:

- `net/http`
- `http.ServeMux`

This is sufficient and keeps the implementation small.

If routing grows later, `chi` is a reasonable upgrade, but it is not necessary for v1.

### 9.4 Frontend

Reuse the existing web structure from Elixir:

- retro terminal-style HTML
- JS `fetch()` to `POST /chat`
- initial greeting rendered on page load

For Go, place static assets under `Go/web/`.

Minor improvements worth making:

- use relative fetch path `/chat` instead of hardcoding `http://localhost:4000/chat`
- optionally render the engine-provided initial greeting instead of duplicating it in the frontend

## 10. Testing Plan

### 10.1 Unit Tests

Mirror the Elixir decomposer tests:

- exact match
- single wildcard
- wildcard in the middle
- no match

Add more cases than Elixir currently has:

- empty input
- multiple adjacent wildcards
- trailing literal mismatch
- memory-rule behavior
- `goto` resolution

### 10.2 Golden Transcript Test

Port the existing Elixir golden transcript test into Go.

Target:

- in `v1`, pass the same partial transcript expectations the Elixir version passes
- in `v1.1`, expand to the full Weizenbaum sample once synonyms and post-transforms are complete

### 10.3 HTTP Tests

Add handler tests for:

- `GET /` returns HTML
- `POST /chat` returns JSON
- invalid JSON returns `400`
- empty body handling
- optional `/reset` behavior

### 10.4 Manual Verification

CLI:

```bash
go run ./cmd/eliza
```

Web:

```bash
go run ./cmd/eliza --web
curl http://localhost:4000
curl -X POST http://localhost:4000/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello"}'
```

## 11. Delivery Phases

### Phase 1: Project Setup

- initialize Go module
- create package layout
- add data model types
- add script loader

Definition of done:

- script loads successfully from `/home/cse/eliza/data`
- keywords parse and sort correctly

### Phase 2: Core Matching And Transformation

- implement normalization
- implement decomposer
- implement transformer

Definition of done:

- decomposer unit tests pass
- basic template substitution works

### Phase 3: Stateful Engine

- implement response cycling
- implement memory queue
- implement keyword scan and rule execution
- implement `goto`
- implement `xnone` fallback

Definition of done:

- CLI test inputs produce sensible ElIZA responses
- partial golden transcript test passes

### Phase 4: CLI

- add terminal REPL
- add random initial and final messages
- add flags for `--data` and `--deterministic`

Definition of done:

- local interactive chat works from terminal

### Phase 5: Web Version

- add HTTP server
- serve `index.html`
- add `POST /chat`
- add startup script

Definition of done:

- browser chat works on `http://localhost:4000`
- curl test against `/chat` returns valid JSON

### Phase 6: Parity Improvements

- synonym expansion
- post-transform support
- fuller transcript parity
- optional per-session web state

Definition of done:

- Go behavior exceeds current Elixir behavior and moves closer to the original JavaScript ELIZA

## 12. Recommended Build Order

Implement in this order:

1. Script types and loader
2. Decomposer tests and matcher
3. Transformer
4. State manager
5. Engine orchestration
6. CLI
7. Web server
8. Golden transcript and parity improvements

This order keeps the core logic isolated and testable before adding interfaces.

## 13. Suggested Initial Commands

When implementation starts, these are the first commands to run:

```bash
cd /home/cse/eliza/Go
go mod init eliza-go
mkdir -p cmd/eliza internal/script internal/engine internal/web web tests
```

Then implement and verify with:

```bash
go test ./...
go run ./cmd/eliza
go run ./cmd/eliza --web
```

## 14. Final Recommendation

Do not translate the Elixir project line by line.

Instead:

- preserve the current behavior and test expectations
- keep the Go packages small and explicit
- make state management clearer than the Elixir global `Agent`
- keep the web API contract identical
- treat synonym expansion and post-transforms as a deliberate second phase

That gives a clean Go v1 with feature parity to the current Elixir version, while leaving a clear path to historical parity with the original JavaScript ELIZA.

# What Is STILL NOT Fully Known

This is the important part.

The script defines:

- DATA
- RULES

But not the exact:

- EXECUTION SEMANTICS

These are still unresolved.

## 1. Exact Wildcard Matching Rules

We still do NOT know precisely:

**Is matching greedy?**

Example:

> * i * you *

Input:

> I think you hate you

How are captures split?

This is undefined.

**Can `*` match empty strings?**

Example:

> * i remember *

Does:

> “I remember”

match?

Unclear.

**Token-based or regex-based matching?**

Huge implementation difference.

Still unresolved.

## 2. Exact Capture Numbering Semantics

We infer:

> (2)

means second wildcard capture.

But:

- are literals counted?
- are synonym groups counted?
- are empty captures counted?

Not formally specified.

## 3. Exact Synonym Expansion Behavior

We know:

>  @belief

maps to synonyms.

But we do NOT know:

- stemming?
- plural handling?
- case sensitivity?
- exact-token matching only?

Still undefined.

## 4. Memory System Details

The `$` marker implies memory.

But we do NOT know:

- queue structure
- retrieval timing
- priority rules
- persistence duration
- eviction policy

This is still missing.

## 5. Response Selection Policy

When multiple responses exist:

```
[
 "Why do you ask?",
 "What do you think?"
]
```

We still don’t know:

- random?
- cyclic?
- weighted?
- repetition avoidance?

This matters a LOT.

## 6. Exact Keyword Selection Algorithm

Suppose input contains:

- multiple keywords
- equal priorities

We still don’t know:

- first match?
- longest keyword?
- highest priority only?
- backtracking?

Still unresolved.

## 7. Sentence Segmentation Rules

Input:

> I am sad. My mother hates me.

How does ELIZA split clauses?

Unknown:

- punctuation logic
- clause precedence
- multi-sentence handling

## 8. Exact Reflection Algorithm

We know the mappings.

But not:

- replacement ordering
- collision prevention
- temporary placeholders
- token boundary handling

Without this:

> “you” ↔ “I” loops happen

## 9. Exact Historical ELIZA Semantics

Your script is:

- a JS port
- not the original implementation

Some historical behaviors may already be lost.

Still needed:

- original MAD-SLIP behavior
- original DOCTOR script semantics

## 10. Formal Grammar of ELIZA DSL

You still do NOT have a formal specification for:

- `*`
- `@`
- `()`
- `goto`
- `$`

Right now it’s inferred informally.

You need:

- actual grammar rules

## 11. Runtime State Model

Still undefined:

- session state
- memory scope
- response history
- recursion limits
- loop prevention

## 12. Failure Behavior

Unknown:

- malformed rules
- missing `goto` targets
- recursive `goto` loops
- invalid captures

Need explicit behavior.

## 13. Canonical Test Behavior

You still do NOT know:

- expected outputs for many edge cases

Meaning:

- ports may diverge

You need:

- golden transcript tests

## So In One Sentence

You have already recovered:

**ELIZA’s knowledge representation system**

But you have NOT fully recovered:

**ELIZA’s execution semantics**

That is the main missing piece.

## What You Know vs Don’t Know

| Area                     | Status        |
| ------------------------ | ------------- |
| Greeting/farewell system | ✅ Known      |
| Keyword system           | ✅ Known      |
| Synonym system           | ✅ Known      |
| Reflection tables        | ✅ Known      |
| Decomposition rules      | ✅ Known      |
| Template system          | ✅ Known      |
| `goto` behavior          | ✅ Mostly known|
| Cleanup transforms       | ✅ Known       |
| Wildcard semantics       | ❌ Unclear    |
| Capture indexing rules   | ❌ Unclear    |
| Memory implementation    | ❌ Incomplete |
| Response rotation policy | ❌ Unknown    |
| Exact parser behavior    | ❌ Unknown    |
| Reflection ordering      | ❌ Unknown    |
| Runtime state model      | ❌ Unknown    |
| Historical accuracy      | ❌ Partial    |

## What You Should Do Next

Your next priority should be:

**Step 1 — Define the ELIZA DSL Formally**

Document:

- `*`
- `@`
- `(n)`
- `goto`
- `$`

**Step 2 — Define Execution Semantics**

Specify:

- matching
- captures
- ranking
- reflection
- memory
- randomness

**Step 3 — Build a Reference Interpreter**

ONLY ONE implementation first.

Recommended:

- Go

because parser engineering is easiest there.

**Step 4 — Create Golden Tests**

Then port to:

- Elixir
- Crystal

using the same transcript suite.

## Biggest Insight

The difficult part of ELIZA is NOT the dialogue data.

It is defining:

**the exact meaning of the rule language**

That is what you are actually reverse-engineering now.

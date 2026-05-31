# ELIZA Project - Aasifa Learning Log
## Language Research- 

### Go
- Simple syntax, compiled language with built-in concurrency
-  Learned: goroutines, interface patterns

### Rust
- Forced precise modeling of ELIZA logic
- Learned: ownership/borrowing,pattern matching


### Elixir
- Immutable data, pipeline operator for data flow
- Learned: pattern matching, process-based state, functional composition

## ELIZA History

- Created by Joseph Weizenbaum at MIT (1964-1966) for IBM 7094
- Published in CACM January 1966, DOCTOR script simulated therapist
- One of the first conversational programs
- **The ELIZA Effect:** Humans attribute understanding to simple pattern matching

### Key Historical Discoveries
- Original MIT source revealed hidden implementation details
-  LIMIT variable cycles 1→2→3→4→1, memory recalled only at LIMIT == 4
- HASH function makes memory selection deterministic (not random)

## Core Technical Concepts

### Pattern Matching & Regex
- Decomposition patterns with wildcards: 0 (zero or more), N (exactly N words)
- Groups: (* SAD UNHAPPY) matches any listed word
- Greedy matching captures longest possible string

### NLP Fundamentals
- Tokenization, normalization, pattern matching, substitution
- Rule-based approach (not statistical/neural)

### Word Reflections
- Pre-transforms: "I'm" → "I am", "don't" → "do not"
- Post-transforms: "I" → "you", "my" → "your"
- Creates conversational illusion by mirroring perspective

### Memory System
- FIFO queue stores responses for later recall
- One MEMORY keyword with four transformation rules
- HASH function selects which rule deterministically
- Recalled when LIMIT == 4 and no keyword matches

## Processing Pipeline

1. Normalize - Clean input, apply pre-transformations
2. Scan Keywords - Find and rank by precedence
3. Match Patterns - Try decomposition rules with greedy wildcards
4. Select Reassembly - Choose response template
5. Substitute - Fill template with captured fragments
6. Post-Transform - Apply reflections
7. Output - Return response, save to memory if needed

## Key Learnings

Technical:
- Simple concepts, complex implementation detail.
- Same algorithm, different expressions across languages

Conceptual:
- Pattern matching creates intelligence illusion without understanding
- Good design beats complex algorithms
- Historical systems teach foundational principles clearly

## Final Takeaways

1. Simple ≠ Easy - details matter enormously
2. Research first - understand before coding
3. Test behavior, not implementation
4. Iterate safely - keep working versions
5. Language choice reveals different insights
6. Design over complexity
7. Doing teaches more than reading

